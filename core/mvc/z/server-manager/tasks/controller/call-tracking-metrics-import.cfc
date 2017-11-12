<cfcomponent>
<cffunction name="progress" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	m=application.zcore.functions.zso(application, 'callTrackingMetricsImportProgress');
	//echo('<h2>CallTrackingMetrics Import Progress</h2>');
	if(m EQ ""){
		m="Not running";
	}
	return m;
	//echo('<p>'&m&'</p>');
	</cfscript>
	
</cffunction>

<cffunction name="cancel" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	m=application.zcore.functions.zso(application, 'callTrackingMetricsImportProgress');
	//echo('<h2>CallTrackingMetrics Import Progress</h2>');
	if(m NEQ ""){
		application.callTrackingMetricsImportCancel=true;
		application.zcore.status.setStatus(request.zsid, "CallTrackingMetrics Import has been set to be cancelled.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}else{
		application.zcore.status.setStatus(request.zsid, "CallTrackingMetrics Import wasn't running yet.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");

	}
	</cfscript>
	
</cffunction>


	
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	setting requesttimeout="80000";
	request.ignoreSlowScript=true;
	db=request.zos.queryobject; 

	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_calltrackingmetrics_enable_import = #db.param(1)# and 
	site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)# and 
	site_active = #db.param(1)#";
	qSite=db.execute("qSite");
	for(row in qSite){
		u=row.site_domain&"/z/server-manager/tasks/call-tracking-metrics-import/callImport";
		rs=application.zcore.functions.zdownloadlink(u, 5000);
		if(not rs.success){ 
			throw("Failed to download: #u#");
		}else{
			echo("Downloaded: #u#<br />");
			echo(rs.cfhttp.filecontent&"<hr />");
		}
		if(structkeyexists(application, 'callTrackingMetricsImportCancel')){
			echo('Import was cancelled');
			structdelete(application, 'callTrackingMetricsImportCancel');
			structdelete(application, 'callTrackingMetricsImportProgress');
			abort;
		}
	}
	echo('Import complete');
	structdelete(application, 'callTrackingMetricsImportProgress');
	abort;
	</cfscript>
</cffunction>

<cffunction name="callImport" localmode="modern" access="remote">
	<cfscript>
	debug=false;// set to true to debug this script
	/*if(request.zos.istestserver){
		debug=true;
	}*/
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	} 
	request.ignoreSlowScript=true;
	setting requesttimeout="10000";
	db=request.zos.queryobject; 
	if(application.zcore.functions.zso(request.zos.globals, 'calltrackingmetricsEnableImport', true, 0) EQ 0){
		throw("Call Tracking Metrics import is not enabled for this domain: #request.zos.globals.domain#.");
	}
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_calltrackingmetrics_enable_import = #db.param(1)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_deleted = #db.param(0)# and 
	site_active = #db.param(1)#";
	qSite=db.execute("qSite");
	accountId=request.zos.globals.calltrackingMetricsAccountId;
	startDate='2010-01-01';
	d=qSite.site_calltrackingmetrics_import_datetime;
	if(d NEQ "" and isdate(d)){
		d=dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss");
		d=parsedatetime(d);
		d=dateadd("d", -1, d);
		startDate=dateformat(d, "yyyy-mm-dd");
	}

 
	accessKey=request.zos.globals.calltrackingMetricsAccessKey; 
	secretKey=request.zos.globals.calltrackingMetricsSecretKey; 
 
	endDate=dateformat(dateadd("d", 2, now()), 'yyyy-mm-dd');

	qs={
		page:1, // the page offset to query
		// filter:"", // a search string to look for calls with specific callerid, caller_number, called_number, source name, etc...
		// "multi_tags[]":"", // you can use this query param to filter results by one or tag
		// "multi_agents[]":"", // you can use this query param to filter results by agent user id.
		// menu_key_press:"", // you can use this query param to filter results by a specific menu key
		// filter_visitor_data:"", // you can use this query param to filter results by either calls that include visitor data or calls that lack visitor data. e.g. filter_visitor_data=1 to include visitor data or filter_visitor_data=2 to exclude visitor data
		start_date:startDate, // a starting date offset to query
		end_date:endDate // a ending date offset to query
	};
	 

	insertCount=0;
	updateCount=0;
	/*
	// might be higher performance if we skip repeated authentication someday.  this code works for that:
	http url="https://api.calltrackingmetrics.com/api/v1/authentication" timeout="30" throwonerror="no" method="post"{
		httpparam type="formfield" name="token" value="#accessKey#";
		httpparam type="formfield" name="secret" value="#secretKey#";
	}
	writedump(cfhttp);
	if(isjson(cfhttp.filecontent)){
		authStruct=deserializeJSON(cfhttp.filecontent);
		if(not authStruct.success){
			savecontent variable="out"{
				echo('calltrackingmetrics Login failed');
				writedump(cfhttp);
			}
			throw(out);
		}
		qs.token=authStruct.token;
	}else{
		savecontent variable="out"{
			echo('calltrackingmetrics invalid response');
			writedump(cfhttp);
		}
		throw(out);
	}
	abort;
	*/
	if(application.zcore.functions.zso(request.zos.globals, 'calltrackingmetricsCfcPath') NEQ ""){
		importCom=createobject("component", replace(request.zos.globals.calltrackingmetricsCfcPath, "root.", request.zRootCFCPath));
	}
	formBackup=duplicate(form);
	lastTotal="Unknown";
	while(true){
		u="https://api.calltrackingmetrics.com/api/v1/accounts/#accountId#/calls.json?";
		for(i in qs){
			u&=i&"="&urlencodedformat(qs[i])&"&";
		}

		if(debug){
			js={
				calls: [{
					id: ":call_id",
					name: "firstname lastname",
					caller_number: "(ddd) ddd-dddd",
					search: "keywords searched",
					referrer: "",
					location: "http://example.com/",
					source: "Direct",
					likelihood: 82.0381,
					duration: 36,
					city: "a city",
					state: "CA",
					country: "US",
					called_at: "2012-08-17 10:24 AM",
					tracking_number: "(ddd) ddd-dddd",
					business_number: "(ddd) ddd-dddd",
					audio: "https://example.com/url/to/audio"
				}],
				page: 1,
				total_entries: 1963,
				total_pages: 197,
				per_page: 10,
				next_page: "https://api.calltrackingmetrics.com/api/v1/accounts/:account_id/calls.json?page=2",
				previous_page: "https://api.calltrackingmetrics.com/api/v1/accounts/:account_id/calls.json"
			};
		}else{ 
			application.callTrackingMetricsImportProgress="Downloading #u# | insertCount: #insertCount# | updateCount: #updateCount# | total: #lastTotal#"; 
			http url="#u#" timeout="30" throwonerror="no" method="get"{ 
				httpparam type="header" name="Authorization" value='Basic #ToBase64("#accessKey#:#secretKey#")#';
			} 
			if(not structkeyexists(cfhttp, 'statuscode') or left(cfhttp.statuscode,3) NEQ '200'){
				savecontent variable="out"{
					writedump(cfhttp);

				}
				throw("Failed to download calltrackingmetrics. cfhttp response:"&out);
			}
			js=deserializeJSON(cfhttp.filecontent); 
		}
		qs.page+=1;
		lastTotal=js.total_entries;


		excludeCallTrackingMetrics=application.zcore.functions.zso(request.zos, 'excludeCallTrackingMetrics', false, {});

		for(i=1;i LTE arraylen(js.calls);i++){
			if(structkeyexists(application, 'callTrackingMetricsImportCancel')){
				echo('Import was cancelled');
				abort;
			}
			structclear(form);
			call=js.calls[i]; 
			t9={};
			t9.inquiries_external_id="ctm-#call.id#";
			t9.site_id=request.zos.globals.id;
			t9.inquiries_deleted=0; 
			d=left(call.called_at, 19); 
			if(isdate(d)){
				t9.inquiries_datetime=dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss");
			}else{
				t9.inquiries_datetime=request.zos.mysqlnow;
			}

			t99={}; 
			for(i2 in call){
				if(not isNull(call[i2]) and isSimpleValue(call[i2])){
					t99[i2]=call[i2]; 
				/*}else{
					// we don't need the complex data for now.
					echo('<hr>');
					writedump(i2);
					writedump(call[i2]);*/
				}
			}
			t9.inquiries_phone1=call.caller_number; 
			t9.inquiries_email=application.zcore.functions.zso(call, 'email'); 

			if(structkeyexists(excludeCallTrackingMetrics, t9.inquiries_phone1)){
				continue;
			}
			if(request.zos.isdeveloper){
				echo(t9.inquiries_phone1&'<br>');
			}

			t9.inquiries_first_name=application.zcore.functions.zso(call, 'name');

			t9.inquiries_status_id=1;
			t9.inquiries_type_id=15;
			t9.inquiries_type_id_siteIDType=4; 
			if(application.zcore.functions.zso(request.zos.globals, 'calltrackingmetricsCfcPath') NEQ ""){
				importCom[request.zos.globals.calltrackingmetricsCfcMethod](call, t9, t99);
			} 
			structdelete(t99, 'email');
			structdelete(t99, 'billed_amount');
			structdelete(t99, 'billed_at');
			structdelete(t99, 'excluded');
			structdelete(t99, 'tracking_number_format');
			structdelete(t99, 'business_number_format');
			structdelete(t99, 'caller_number_format');
			structdelete(t99, 'alternative_number');
			structdelete(t99, 'caller_number_complete');
			structdelete(t99, 'caller_number');
			structdelete(t99, 'visitor');
			structdelete(t99, 'extended_lookup_on');
			structdelete(t99, 'receiving_number_id');
			structdelete(t99, 'tgid');
			structdelete(t99, 'source_id'); 
			structdelete(t99, 'account_id'); 
			structdelete(t99, 'id'); 
			if(structkeyexists(t99, 'audio')){
				t99.audio='<a href="'&t99.audio&'" target="_blank">'&t99.audio&'</a>';
			}
			t9.inquiries_readonly=1;

			if(structcount(t99)){
				arrKey=structkeyarray(t99);
				arraysort(arrKey, "text", "asc");
				t992={arrCustom:[]};
				for(i2=1;i2 LTE arraylen(arrKey);i2++){
					arrayAppend(t992.arrCustom, { label:arrKey[i2], value:t99[arrKey[i2]] });
				} 
				t9.inquiries_custom_json=serializeJson(t992);
			}

			db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
			WHERE inquiries_deleted=#db.param(0)# and 
			inquiries_external_id = #db.param(t9.inquiries_external_id)# and 
			inquiries_type_id = #db.param(15)# and 
			inquiries_type_id_siteIDType=#db.param(4)# and 
			site_id = #db.param(request.zos.globals.id)# ";
			qId=db.execute("qId");
			for(row in qId){
				structappend(form, row, false);
			}

			structappend(form, t9 , true);
			if(qId.recordcount){
				form.inquiries_id=qId.inquiries_id;
				structdelete(form, 'inquiries_status_id'); 
				updateCount++;
				application.zcore.functions.zUpdateLead(form);
			}else{ 
				insertCount++;
				application.zcore.functions.zInsertLead();
			}
			application.callTrackingMetricsImportProgress="Importing | insertCount: #insertCount# | updateCount: #updateCount# | total: #js.total_entries#";
		}  
		if(arraylen(js.calls) EQ 0 or (qs.page)*js.per_page GT js.total_entries){
			echo('All calls have been downloaded<br />last download url was: #u#<br />'); 
			break;
		}
		if(debug){
			// in debug mode, we only have 1 loop possible
			break;
		} 
	}

	form=formBackup;

	if(not debug){
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# set 
		site_calltrackingmetrics_import_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# WHERE  
		site_id = #db.param(request.zos.globals.id)# and 
		site_deleted = #db.param(0)# ";
		qSite=db.execute("qSite");
	}
	application.callTrackingMetricsImportProgress="Site import complete.";
	echo('CallTrackingMetrics.com import complete for account id #accountId#. Imported #insertCount# calls and updated #updateCount# calls.');
	abort;
	</cfscript>
	
</cffunction>
</cfcomponent>