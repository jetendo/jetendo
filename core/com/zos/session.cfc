
<cfcomponent>
<!--- usage
struct=application.zcore.session.get();
application.zcore.session.put(struct);
application.zcore.session.clear();
application.zcore.session.deleteOld();	
application.zcore.session.pullNewer();
application.zcore.functions.getSessionsNewerThen(date);

ssl session - lost on browser close - lost on server reboot
	useful as an option on manager and more secure features (ecommerce), not for all requests.
	we can use non-session cookies for tracking user in other ways.

--->

<cffunction name="testSession" access="public" localmode="modern">
	<cfscript>
	clear();
	dataStruct=get();
	backupSessionId=request[request.zos.serverSessionVariable];
	echo("<hr />Dump should be empty struct<br />");
	writedump(dataStruct);
	// this should throw exception about data types.
	//dataStruct.cfcTest=createobject("component", "zcorerootmapping.com.zos.session");
	//put(dataStruct);

	dataStruct.newData=1;
	put(dataStruct);
	echo("<hr />Dump should be struct with newData=1<br />");
	writedump(get());
	clear();
	dataStruct=get();
	dataStruct.newData2=1;
	echo("<hr />Dump should be struct with newData2=1<br />");
	writedump(dataStruct);

	// force session to expire
	application.customSessionStruct[request[request.zos.serverSessionVariable]].date=dateadd("n", -(request.zos.sessionExpirationInMinutes+10), now());
	deleteOld();
	dataStruct=get();
	echo("<hr />Dump should be empty struct<br />");
	writedump(dataStruct);
	echo("<hr />Session id #request[request.zos.serverSessionVariable]# should be different from #backupSessionId# <br />");
	dataStruct.newData3=1;
	put(dataStruct);
	syncStruct=getSessionsNewerThen(dateadd("n", -request.zos.sessionExpirationInMinutes, now()));
	echo("<hr />Dump should be sessionID key ""#request[request.zos.serverSessionVariable]#"" with struct with key newData3=1<br />");
	writedump(syncStruct);
	abort;


	</cfscript>

</cffunction>


<cffunction name="pullNewer" access="public" localmode="modern">
	<cfscript>
	if(structcount(request.zos.serverStruct) EQ 1){
		return;
	}else if(structcount(request.zos.serverStruct) EQ 2){
		for(i in request.zos.serverStruct){
			if(application.zcore.currentServerID NEQ i){
				pullFromServer(i);
			}
		}
	}else{
		// use 1 thread per server
		arrThread=[];
		for(i in request.zos.serverStruct){
			if(application.zcore.currentServerID NEQ i){
				threadName="sessionThread#i#_#gettickcount()#";
				arrayAppend(arrThread, threadName);
				thread action="run" name="#threadName#" timeout="20" i="#i#"{
					pullFromServer(i);
				}
			}
		}
		if(arrayLen(arrThread)){
			thread action="join" name="#arrayToList(arrThread, ",")#";
			// TODO: validate the threads finished successfully...
			for(i2=1;i2 LTE arraylen(arrThread);i2++){
				ct=evaluate(arrThread[i2]);
				if(ct.status EQ "TERMINATED"){
					savecontent variable="out"{
						writedump(ct.error);
					}
					throw("Failed to run pullFromServer() thread named ""#i2#"": "&out);
				}
			}
		}
	}
	</cfscript>
</cffunction>

<cffunction name="pullFromServer" access="private" localmode="modern">
	<cfargument name="serverId" type="numeric" required="yes">
	<cfscript>
	if(not structkeyexists(application.zcore, 'sessionSyncStruct')){
		application.zcore.sessionSyncStruct={};
	}
	if(not structkeyexists(application.zcore.sessionSyncStruct, arguments.serverId)){
		application.zcore.sessionSyncStruct[arguments.serverId]=dateadd("n", -request.zos.sessionExpirationInMinutes, now());
	}
	currentDate=application.zcore.sessionSyncStruct[arguments.serverId];
	newDate=dateformat(currentDate, "yyyy-mm-dd")&" "&timeformat(currentDate, "HH:mm:ss");
	link=request.zos.serverStruct[arguments.serverId].apiURL&"sync/downloadNewerSessions?newerThenDate="&urlencodedFormat(newDate);
	r1=application.zcore.functions.zdownloadlink(link, 10);
	if(r1.success){
		syncStruct=evaluate(r1.cfhttp.filecontent);
		for(i in syncStruct){
			if(structkeyexists(application.customSessionStruct, i)){
				c=application.customSessionStruct[i];
				if(datecompare(syncStruct[i].date, c.date) LTE 0){
					continue; // skip sync if date is same or newer on current server.
				}
			}
			if(datecompare(syncStruct[i].date, currentDate) EQ 1){
				currentDate=syncStruct[i].date;
			}
			application.customSessionStruct[i]=c;
		}
	}
	application.zcore.sessionSyncStruct[arguments.serverId]=currentDate;
	</cfscript>
</cffunction>

<cffunction name="getSessionsNewerThen" access="public" localmode="modern">
	<cfargument name="date" type="date" required="yes">
	<cfscript>
	syncStruct={};
	for(i in application.customSessionStruct){
		c=application.customSessionStruct[i];
		if(datecompare(c.date, arguments.date) GT 0){
			syncStruct[i]=duplicate(c);
		}
	}
	return syncStruct;
	</cfscript>
</cffunction>


<cffunction name="forceEnable" access="public" localmode="modern">
	<cfscript>
	request.zos.forceEnableSession=true;
	backupSession={};
	if(structkeyexists(request, 'zsession')){
		backupSession=request.zsession;
	}
	request.zsession=application.zcore.session.get();
	structappend(request.zsession, backupSession, true);
	</cfscript>
</cffunction>
		

<cffunction name="isSessionEnabled" access="public" localmode="modern">
	<cfscript>
	if(structkeyexists(request.zos, 'forceEnableSession')){
		return true;
	}else if(structkeyexists(cookie, 'zsource') or structkeyexists(form, 'zsource')){
		return true;
	}else if(structkeyexists(cookie, 'ztoken')){
		return true;
	}else if(structkeyexists(cookie, request.zos.serverSessionVariable) and cookie[request.zos.serverSessionVariable] NEQ ""){
		return true;
	}else if(request.zos.cgi.request_method EQ "post"){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="get" access="public" localmode="modern">
	<cfargument name="forceEnable" type="boolean" required="false">
	<cfscript>
	if(not isSessionEnabled()){
		return {};
	}
	// allow session cookie output
	if(not structkeyexists(request, request.zos.serverSessionVariable)){
		getSessionId();
	}
	if(structkeyexists(application.customSessionStruct, request[request.zos.serverSessionVariable])){
		return duplicate(application.customSessionStruct[request[request.zos.serverSessionVariable]].data);
	}else{
		// return empty struct if no session exists yet, otherwise: (threadsafe - no locking needed)
		return {};
	}
	</cfscript>
</cffunction>

<cffunction name="getSessionId" access="public" localmode="modern">
	<cfscript>
	if(structkeyexists(request, request.zos.serverSessionVariable)){
		return request[request.zos.serverSessionVariable];
	}
	if(not structkeyexists(application, 'customSessionStruct')){
		application.customSessionStruct={};
	}
	if(structkeyexists(form, request.zos.serverSessionVariable)){
		currentId=form[request.zos.serverSessionVariable];
	}else if(structkeyexists(cookie, request.zos.serverSessionVariable)){
		currentId=cookie[request.zos.serverSessionVariable];
	}else{
		currentId='';
	}
	// we use createUUID here for sessionID because we know Railo is using generateRandomBasedUUID() java method, which *should* be secure.
	if(currentId EQ "" or not structkeyexists(application.customSessionStruct, currentID)){
		currentId=createUUID();
	}else{
		// verify security
		c=application.customSessionStruct[currentID];
		if(c.userAgent NEQ request.zos.cgi.http_user_agent){
			currentId=createUUID();
		}else if(c.ip NEQ request.zos.cgi.remote_addr){
			currentId=createUUID();
		}
		/*if(structkeyexists(request.zos.requestData.headers, 'ssl_session_id')){
			if(c.sslSessionId NEQ request.zos.requestData.headers.ssl_session_id){
				currentId=createUUID();
			}
		}*/
	}
	timeSpan=CreateTimeSpan(0, 0, request.zos.sessionExpirationInMinutes, 0);
	application.zcore.functions.zCookie({name:request.zos.serverSessionVariable, value:currentId, expires: timeSpan, httponly:true });
	request[request.zos.serverSessionVariable]=currentId;
	return currentId;
	</cfscript>
</cffunction>

<cffunction name="clear" access="public" localmode="modern">
	<cfscript>
	put({});
	</cfscript>
</cffunction>

<cffunction name="put" access="public" localmode="modern">
	<cfargument name="struct" type="any" required="yes">
	<cfscript>
	if(not isSessionEnabled()){
		return;
	}
	zos=request.zos;
	if(not structkeyexists(request, zos.serverSessionVariable)){
		getSessionId();
	}
	if(zos.trackingspider or structcount(arguments.struct) EQ 0){
		structdelete(application.customSessionStruct, request[zos.serverSessionVariable]);
		structdelete(cookie, zos.serverSessionVariable);
		return;
	}
	if(not request.zos.enableSiteTemplateCache and zos.isTestServer){
		// verify recursively all data being put is array, struct, string, boolean, numeric.  No complex types or java allowed
		checkStruct(arguments.struct);
	}
	ts={
		date: now(),
		userAgent: zos.cgi.http_user_agent,
		ip: zos.cgi.remote_addr,
		data: arguments.struct
		//,		sslSessionId:''
	};
	/*
	if(structkeyexists(zos.requestData.headers, 'ssl_session_id')){
		ts.sslSessionId=zos.requestData.headers.ssl_session_id;
	}*/
	request.zsession=ts.data;
	application.customSessionStruct[request[zos.serverSessionVariable]]=ts;
	</cfscript>
</cffunction>

<cffunction name="deleteOld" access="public" localmode="modern">
	<cfscript>
	oldDate=dateadd("n", -request.zos.sessionExpirationInMinutes, now());
	for(i in application.customSessionStruct){
		try{
			c=application.customSessionStruct[i];
			if(datecompare(c.date, oldDate) LTE 0){
				structdelete(application.customSessionStruct, i);
			}
		}catch(Any e){
			// ignore errors due to uncommon multiple thread issues.
		}
	}
	</cfscript>
</cffunction>


<cffunction name="checkStruct" access="private" localmode="modern" returntype="boolean">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	struct=arguments.struct;
	for(i in struct){
		checkType(struct[i]);
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="throwTypeError" access="private" localmode="modern">
	<cfargument name="v" type="any" required="yes">
	<cfscript>
	savecontent variable="meta"{
		try{
		writedump(getmetadata(arguments.v));//, true, 'simple');
		}catch(e){
			writedump(e);
		}
		writedump(arguments.v);//, true, 'simple');
	}
	throw("Session data type must be struct, array or a simple value to allow safe replication/serialization and the following type was found:<br />"&meta);
	</cfscript>
</cffunction>

<cffunction name="checkType" access="private" localmode="modern">
	<cfargument name="v" type="any" required="yes">
	<cfscript>
	v=arguments.v;
	if(isNull(v)){

	}else if(isStruct(v)){
		r=checkStruct(v);
		if(not r){
			throwTypeError(v);
		}
	}else if(isArray(v)){
		r=checkArray(v);
		if(not r){
			throwTypeError(v);
		}
	}else if(not isSimpleValue(v)){
		throwTypeError(v);
	}
	</cfscript>
</cffunction>

<cffunction name="checkArray" access="private" localmode="modern" returntype="boolean">
	<cfargument name="v" type="array" required="yes">
	<cfscript>
	v=arguments.v;
	for(i=1;i LTE arraylen(v);i++){
		checkType(v[i]);
	}
	return true;
	</cfscript>
</cffunction>



</cfcomponent>