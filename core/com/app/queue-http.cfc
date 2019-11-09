<cfcomponent>
<cfoutput>
<!---  
ts={
	name:"", // Name is optional: Any previously queued http requests with the same name will be deleted.
	url:"",
	timeout:20,
	retry_interval:60,
	postVars:{},
	headerVars:{},
	priority:1, // set to a higher number to have a lower priority
	enableParallel:false, // if set to true, multiple simultaneous requests will be allowed
	apiId:0 // lookup id in queue_http_api table

}
queueHttpCom=createobject("component", "zcorerootmapping.com.app.queue-http");
r=queueHttpCom.queueHTTPRequest(ts);
if(not r){
	throw("Failed to queue http request");
}
 --->
<cffunction name="queueHTTPRequest" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=validateHTTPRequest(arguments.ss);
	
	ts={
		table:"queue_http",
		datasource:request.zos.zcoreDatasource,
		struct:{
			queue_http_created_datetime:request.zos.mysqlnow,
			queue_http_updated_datetime:request.zos.mysqlnow,
			queue_http_last_run_datetime:request.zos.mysqlnow,
			queue_http_deleted:0,
			site_id:request.zos.globals.id,
			queue_http_url:ss.url,
			queue_http_form_data:serializeJson(ss.postVars),
			queue_http_header_data:serializeJson(ss.headerVars),
			queue_http_fail_count:0,
			queue_http_timeout:ss.timeout,
			queue_http_retry_interval:ss.retry_interval,
			queue_http_response:"",
			queue_http_priority:ss.priority,
			queue_http_name:ss.name,
			queue_http_api_id:ss.apiId
		}
	}
	if(ss.enableParallel){
		ts.struct.queue_http_enable_parallel=1;
	}
	if(ts.struct.queue_http_name NEQ ""){
		deleteHTTPRequest(ts.struct.queue_http_name, request.zos.globals.id);
	}

	queue_http_id=application.zcore.functions.zInsert(ts);
	if(queue_http_id EQ false){
		return false;
	}else{
		return true;
	}
	</cfscript>	
</cffunction>

<cffunction name="deleteHTTPRequest" localmode="modern" access="public"> 
	<cfargument name="name" type="string" required="yes">
	<cfargument name="sid" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from 
	#db.table("queue_http", request.zos.zcoreDatasource)# WHERE 
	queue_http_deleted=#db.param(0)# and 
	queue_http_name=#db.param(arguments.name)# and 
	site_id =#db.param(arguments.sid)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>


<cffunction name="displayHTTPQueueErrors" localmode="modern" access="public"> 
	<cfscript>
	db=request.zos.queryObject;
	form.action=application.zcore.functions.zso(form, 'action');
	form.queue_http_id=application.zcore.functions.zso(form, 'queue_http_id');
	form.sid=application.zcore.functions.zso(form, 'sid');
	if(form.action EQ "run"){
		db.sql="select * from 
		#db.table("queue_http", request.zos.zcoreDatasource)# WHERE 
		queue_http_deleted=#db.param(0)# and 
		queue_http_id=#db.param(form.queue_http_id)# and 
		site_id =#db.param(form.sid)#";
		qHttp=db.execute("qHttp");
		for(row in qHttp){
			ts={
				id:row.site_id&"-"&row.queue_http_id,
				url:row.queue_http_url,
				timeout:row.queue_http_timeout,
				retry_interval:row.queue_http_retry_interval,
				postVars:deserializeJson(row.queue_http_form_data),
				headerVars:deserializeJson(row.queue_http_header_data)
			}
			rs=executeHTTPRequest(ts); 
			if(rs.success){
				db.sql="DELETE FROM #db.table("queue_http", request.zos.zcoreDatasource)# 
				WHERE 
				queue_http_deleted=#db.param(0)# and 
				queue_http_id=#db.param(form.queue_http_id)# and 
				site_id = #db.param(form.sid)# ";
				db.execute("qDelete");
			}else{ 
				db.sql="update #db.table("queue_http", request.zos.zcoreDatasource)#
				SET queue_http_updated_datetime=#db.param(request.zos.mysqlnow)#, 
				queue_http_last_run_datetime=#db.param(request.zos.mysqlnow)#, 
				queue_http_fail_count=#db.param(row.queue_http_fail_count+1)#, 
				queue_http_response=#db.param(serializeJson(rs))#
				WHERE 
				queue_http_deleted=#db.param(0)# and 
				queue_http_id=#db.param(form.queue_http_id)# and 
				site_id = #db.param(form.sid)#";
				db.execute("qUpdate");
			}
		}
		application.zcore.functions.zRedirect("/z/server-manager/tasks/execute-http-queue/viewErrors");
	}else if(form.action EQ "reset"){ 
		db.sql="update #db.table("queue_http", request.zos.zcoreDatasource)#
		SET queue_http_updated_datetime=#db.param(request.zos.mysqlnow)#, 
		queue_http_fail_count=#db.param(0)#, 
		queue_http_response=#db.param('')#
		WHERE 
		queue_http_deleted=#db.param(0)# and 
		queue_http_id=#db.param(form.queue_http_id)# and 
		site_id = #db.param(form.sid)#";
		db.execute("qUpdate");
		application.zcore.functions.zRedirect("/z/server-manager/tasks/execute-http-queue/viewErrors");
	}else if(form.action EQ "delete"){
		db.sql="DELETE FROM #db.table("queue_http", request.zos.zcoreDatasource)# 
		WHERE 
		queue_http_deleted=#db.param(0)# and 
		queue_http_id=#db.param(form.queue_http_id)# and 
		site_id = #db.param(form.sid)# ";
		db.execute("qDelete"); 
		application.zcore.functions.zRedirect("/z/server-manager/tasks/execute-http-queue/viewErrors");
	}
	
	db.sql="select * from 
	#db.table("queue_http", request.zos.zcoreDatasource)# WHERE 
	queue_http_deleted=#db.param(0)# and 
	site_id <> #db.param(-1)# and 
	queue_http_fail_count>#db.param(0)#";
	qHttp=db.execute("qHttp");
	arrError=[];
	echo('<h2>HTTP Queue Errors</h2>');
	if(qHttp.recordcount){
		echo('<table class="table-list">
			<tr>
			<th>Domain</th>
			<th>URL</th>
			<th>Error</th>
			<th>Date</th>
			<th>Admin</th<
			</tr>');
		count=0;
		for(row in qHTTP){
			d=application.zcore.functions.zvar("shortDomain", row.site_id);
			echo('	<tr>
			<td>#d#</td>
			<td>#row.queue_http_url#</td>
			<td>');
			if(row.queue_http_response NEQ ''){
				echo('<a href="##" onclick="showErrorResponse(#count#); return false;">View</a>');
			}
			echo('</td>
			<td>#dateformat(row.queue_http_created_datetime, "m/d/yyyy")& " "&timeformat(row.queue_http_created_datetime, "h:mm tt")#</td>
			<td><a href="/z/server-manager/tasks/execute-http-queue/viewErrors?action=run&queue_http_id=#row.queue_http_id#&sid=#row.site_id#">Run</a> | 
			<a href="/z/server-manager/tasks/execute-http-queue/viewErrors?action=reset&queue_http_id=#row.queue_http_id#&sid=#row.site_id#">Reset</a> | 
			<a href="/z/server-manager/tasks/execute-http-queue/viewErrors?action=delete&queue_http_id=#row.queue_http_id#&sid=#row.site_id#">Delete</a></td<
			</tr>');
			rs=deserializeJson(row.queue_http_response);
			arrayAppend(arrError, application.zcore.functions.zso(rs, 'errorMessage'));
			count++;
		}
		echo('</table>');
	}else{
		echo('No errors detected');
	}
	</cfscript>	
	<script>
	var arrHttpQueueError=#serializeJson(arrError)#;
	function showErrorResponse(n){
		zShowModal(arrHttpQueueError[n], {width:"100%", height:600});
	}
	</script>
</cffunction>
 
<cffunction name="executeQueuedTasks" localmode="modern" access="public"> 
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("queue_http", request.zos.zcoreDatasource)# WHERE 
	queue_http_deleted=#db.param(0)# and 
	site_id <> #db.param(-1)# and 
	queue_http_fail_count <#db.param(3)# 
	ORDER BY queue_http_priority ASC";
	qHttp=db.execute("qHttp");

	request.ignoreSlowScript=true;
	setting requesttimeout="6000";
 
	startTime=gettickcount();
	count=0;
	failCount=0;

	db.sql="select * from #db.table("queue_http", request.zos.zcoreDatasource)# WHERE 
	queue_http_deleted=#db.param(0)# and 
	site_id <> #db.param(-1)# and 
	queue_http_fail_count >=#db.param(3)#";
	qHttpError=db.execute("qHttpError");
 	if(not structkeyexists(application, 'zExecuteHTTPQueueAlertDate')){
 		application.zExecuteHTTPQueueAlertDate=1;
 	}
 	if(application.zExecuteHTTPQueueAlertDate NEQ dateformat(now(), "yyyy-mm-dd") and qHttpError.recordcount NEQ 0){
 		application.zExecuteHTTPQueueAlertDate=dateformat(now(), "yyyy-mm-dd");
		savecontent variable="e"{
			echo('<h2>There are #qHttpError.recordcount# http request queue errors</h2>');
			echo('<p><a href="#request.zos.globals.serverDomain#/z/server-manager/tasks/execute-http-queue/viewErrors">View Errors</a></p>');
		} 
		ts={
			type:"Custom",
			errorHTML:e,
			scriptName:'/z/server-manager/tasks/execute-http-queue/viewErrors',
			url:request.zos.originalURL,
			exceptionMessage:'#qHttpError.recordcount# http request queue errors',
			// optional
			lineNumber:'180'
		}
		application.zcore.functions.zLogError(ts);
	}

	for(row in qHttp){
		if(((gettickcount()-startTime)/1000)+row.queue_http_timeout GT 599){
			break;
		}
		lastRunDateTime=parsedatetime(dateformat(row.queue_http_last_run_datetime, "yyyy-mm-dd")&" "&timeformat(row.queue_http_last_run_datetime, "HH:mm:ss"));
		nextRunDateTime=dateadd("s", row.queue_http_retry_interval, lastRunDateTime); 
		if(datecompare(nextRunDateTime, now()) LTE 0){
			count++;
			ts={
				id:row.site_id&"-"&row.queue_http_id,
				url:row.queue_http_url,
				timeout:row.queue_http_timeout,
				retry_interval:row.queue_http_retry_interval,
				postVars:deserializeJson(row.queue_http_form_data),
				headerVars:deserializeJson(row.queue_http_header_data)
			}
			rs=executeHTTPRequest(ts); 
			if(rs.success){
				db.sql="DELETE FROM #db.table("queue_http", request.zos.zcoreDatasource)# 
				WHERE 
				queue_http_deleted=#db.param(0)# and 
				queue_http_id=#db.param(row.queue_http_id)# and 
				site_id = #db.param(row.site_id)# ";
				db.execute("qDelete");
			}else{
				failCount++;
				db.sql="update #db.table("queue_http", request.zos.zcoreDatasource)#
				SET queue_http_updated_datetime=#db.param(request.zos.mysqlnow)#, 
				queue_http_last_run_datetime=#db.param(request.zos.mysqlnow)#, 
				queue_http_fail_count=#db.param(row.queue_http_fail_count+1)#, 
				queue_http_response=#db.param(serializeJson(rs))#
				WHERE 
				queue_http_deleted=#db.param(0)# and 
				queue_http_id=#db.param(row.queue_http_id)# and 
				site_id = #db.param(row.site_id)#";
				db.execute("qUpdate");
			}
		}
	}
	echo(count&' http requests executed (#failCount# failures)<br />');
	</cfscript>
</cffunction>
	
<cffunction name="validateHTTPRequest" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={
		name:"",
		timeout:20,
		retry_interval:60,
		postVars:{},
		headerVars:{},
		priority:1,
		enableParallel:false,
		apiID:0
	}
	ss=arguments.ss;
	structappend(ss, ts, false);
	ss.timeout=application.zcore.functions.zso(ss, 'timeout', true, 20);
	ss.priority=application.zcore.functions.zso(ss, 'priority', true, 1);
	if(ss.timeout>60){
		throw("arguments.ss.timeout must be 60 seconds or less");
	}
	ss.retry_interval=application.zcore.functions.zso(ss, 'retry_interval', true, 60);
	if(not structkeyexists(ss, 'url')){
		throw("arguments.ss.url is required");
	}
	for(i in ss.postVars){
		if(not isSimpleValue(ss.postVars[i])){
			throw("arguments.ss.postVars must have simple data types for all the values. ""#i#"" was not a simple value.  Encode complex data types to strings first.");
		}
	}
	for(i in ss.headerVars){
		if(not isSimpleValue(ss.headerVars[i])){
			throw("arguments.ss.headerVars must have simple data types for all the values.  ""#i#"" was not a simple value.  Encode complex data types to strings first.");
		}
	}
	return ss;
	</cfscript>
</cffunction>
	

<cffunction name="executeHTTPRequest" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	ss=validateHTTPRequest(arguments.ss);
	rs={success:true};
	if(not structkeyexists(application, 'zRunningQueueHTTPRequestStruct')){
		application.zRunningQueueHTTPRequestStruct={};
	}
	if(structkeyexists(application.zRunningQueueHTTPRequestStruct, ss.id)){
		return {success:false, errorMessage:"This http request is already running."};
	}
	application.zRunningQueueHTTPRequestStruct[ss.id]=true;

	try{
		if(isstruct(ss.postVars) and structcount(ss.postVars) GT 0){
			method="post";
		}else{
			method="get";
		}
		http result="httpresult" url="#ss.url#" method="#method#" timeout="#ss.timeout#" throwonerror="true"{
			for(i in ss.headerVars){
				httpparam name="#i#" type="header" value="#ss.headerVars[i]#";
			}
			for(i in ss.postVars){
				httpparam name="#i#" type="formfield" value="#ss.postVars[i]#";
			}
		}	
		if(not structkeyexists(httpresult, 'status_code') or httpresult.status_code NEQ "200"){
			savecontent variable="out"{
				echo('<h2>http request executed, but status code was not 200</h2>');
				writedump(httpresult);
			}
			rs.errorMessage=out;
		}
	}catch(Any e){
		rs.success=false;
		savecontent variable="out"{
			echo('<h2>http request failed to execute or the timeout was reached.</h2>');
			writedump(e);
		}
		rs.errorMessage=out;
	}
	structdelete(application.zRunningQueueHTTPRequestStruct, ss.id);
	return rs;
	</cfscript> 
</cffunction>

<cffunction name="viewQueue" localmode="modern" access="public">
	
</cffunction>
</cfoutput>
</cfcomponent>