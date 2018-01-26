<cfcomponent>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	setting requesttimeout="10000";
	request.ignoreSlowScript=true;
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	db=request.zos.queryObject;
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_id<>#db.param(-1)# and 
	site_active=#db.param(1)# and 
	site_live=#db.param(1)# and 
	site_interspire_email_owner_id_list<> #db.param('')# and 
	site_deleted = #db.param(0)#";
	qSite=db.execute("qSite");

	js=[];
	siteStats={};
	for(siteRow in qSite){
		db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(siteRow.site_id)# and 
		contact_parent_id=#db.param(0)# and 
		contact_deleted = #db.param(0)# ";
		qContact=db.execute("qContact");

		siteStats[siteRow.site_domain]={contacts:0, users:0};
		uniqueStruct={};
		t2={
			ownerid:siteRow.site_interspire_email_owner_id_list,
			arrEmail:[]
		};
		loop query="qContact"{
			if(structkeyexists(uniqueStruct, qContact.contact_email)){
				continue;
			}
			uniqueStruct[qContact.contact_email]=true;
			ts={
				email:qContact.contact_email
			};
			if(qContact.contact_opt_out EQ 0){
				ts.optIn=true;
			}else{
				ts.optIn=false;
			}
			siteStats[siteRow.site_domain].contacts++;
			arrayAppend(t2.arrEmail, ts);
		}
		/*
		db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user_active=#db.param('1')# and 
		user_deleted = #db.param(0)# and 
		site_id=#db.param(siteRow.site_id)# ";
		qUser=db.execute("qUser");
		loop query="qUser"{
			if(structkeyexists(uniqueStruct, qUser.user_username)){
				continue;
			} 
			uniqueStruct[qUser.user_username]=true;
			ts={
				email:qUser.user_username
			};
			if(qUser.user_pref_email EQ 1){
				ts.optIn=true;
			}else{
				ts.optIn=false;
			}
			siteStats[siteRow.site_domain].users++;
			arrayAppend(t2.arrEmail, ts); 
		}*/
		arrayAppend(js, t2);
	}

	echo('<h2>Interspire import contacts</h2>');
	writedump(siteStats);
	//wriedump(js);	abort;
	if(structkeyexists(request.zos, 'interspireImportContactURL') and request.zos.interspireImportContactURL NEQ ""){
		link=request.zos.interspireImportContactURL; 
		jsonString=application.zcore.functions.zHttpJsonPost(link, serializeJson(js), 20);
		if(jsonString EQ false or not isJson(jsonString)){
			throw(jsonString);
		}
		echo("<h2>Response</h2>");
		echo(jsonString);
	}

	echo("<h2>Task Completed</h2>");
	abort;
	</cfscript>
</cffunction>
</cfcomponent>