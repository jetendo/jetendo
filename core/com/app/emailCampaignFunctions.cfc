<cfcomponent>
<cfoutput>
<!--- All the functions in this component are incomplete and/or not tested --->
<cffunction name="runEmailCampaign" localmode="modern" access="remote" returntype="void" output="yes" hint="Function designed to be a scheduled task that sends out email campaigns continuously.">
	<cfscript>
	// FUTURE: maybe i should give a warning when scheduling email campaigns within 1 week of each other
	// maybe i should store on disk a final version of the email html and plain text for archival reasons
	var ts=0;
	var qemail=0;
	var sendEmailCount='';
	var timeoutSeconds='';
	var qList='';
	var offset='';
	var qE='';
	var result='';
	var db=request.zos.queryObject;
	var ts='';
	var arrE='';
	var rs=0;
	var start=getTickCount();
	var i=0;
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	if(structkeyexists(form, 'sendEmailCount') EQ false){
		sendEmailCount=20; // hardcoded number of emails to send per request.
	}
	if(structkeyexists(form, 'timeoutSeconds') EQ false){
		timeoutSeconds=50; // limit length of request
	}
	if(request.zos.istestserver){
		application.zcore.template.fail("Run email campaign was disabled on the test server.");
	}
	//application.zcore.functions.zabort(); // temporarily cancel all email campaigns
	// get the next scheduled email campaign
	db.sql="SELECT * FROM #db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign 
	WHERE zemail_campaign_scheduled = #db.param('1')# and 
	zemail_campaign_scheduled_datetime  < #db.param(request.zos.mysqlnow)# and 
	zemail_campaign_status IN (#db.param('0')#,#db.param('1')#) and 
	zemail_campaign_deleted = #db.param(0)# 
	order by zemail_campaign_status desc, zemail_campaign_scheduled_datetime 
	LIMIT #db.param(0)#,#db.param(1)# ";
	qEmail=db.execute("qEmail");
	if(qEmail.recordcount eq 0){
		// no email campaign need to be run
		return;
	}else if(qEmail.zemail_campaign_status eq '0'){
		// running new email campaign, set status to 1 "running"
		db.sql="UPDATE #db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign 
		SET zemail_campaign_status = #db.param('1')#,
		zemail_campaign_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE zemail_campaign_id=#db.param(qEmail.zemail_campaign_id)# and 
		zemail_campaign_deleted = #db.param(0)#";
		db.execute("q");
		// always send to opt in server administrators first here
		// query user_server_administrator where user_confirm='1'
		// send email template for this campaign.
	}		
	// get one zemail_list that isn't complete. (where zemail_list_x_campaign_sent=0)
	db.sql="SELECT * FROM #db.table("zemail_list_x_campaign", request.zos.zcoreDatasource)# zemail_list_x_campaign, 
	#db.table("zemail_list", request.zos.zcoreDatasource)# zemail_list 
	WHERE zemail_list_x_campaign.zemail_campaign_id = #db.param(qemail.zemail_campaign_id)# and 
	zemail_list.zemail_list_id = zemail_list_x_campaign.zemail_list_id and 
	zemail_list_x_campaign.site_id =#db.param(qEmail.site_id)# and 
	zemail_list_x_campaign_deleted = #db.param(0)# and 
	zemail_list_x_campaign_complete=#db.param('0')# 
	LIMIT #db.param(0)#,#db.param(1)#";
	qList=db.execute("qList");
	if(qList.recordcount EQ 0){
		// all lists are complete, campaign is finished
		// update campaign status to 3 (complete)
		db.sql="UPDATE #db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign 
		SET zemail_campaign_status = #db.param('3')#, 
		zemail_campaign_completed_datetime = #db.param(request.zos.mysqlnow)#,
		zemail_campaign_updated_datetime=#db.param(request.zos.mysqlnow)#  
		WHERE zemail_campaign_id=#db.param(qEmail.zemail_campaign_id)# and 
		zemail_campaign_deleted = #db.param(0)# ";
		db.execute("q");
		this.runEmailCampaign();
		return;
	}
	offset=qList.zemail_list_x_campaign_offset;
	
	// check for system lists
	if(qList.zemail_list_id eq '1'){ 
		// this is the "Everyone" list, get all user_ids for this site
		db.sql="SELECT user_id FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE site_id = #db.param(qemail.site_id)# and 
		user_deleted = #db.param(0)#
		order by user_id asc 
		LIMIT #db.param(offset)#,#db.param(sendEmailCount)#";
		qE=db.execute("qE");
	}else{
		// this is a user list, get the user_ids
		db.sql="SELECT user_id 
		FROM #db.table("zemail_list_x_user", request.zos.zcoreDatasource)# zemail_list_x_user 
		WHERE zemail_list_id = #db.param(qlist.zemail_list_id)# and 
		site_id = #db.param(qemail.site_id)# and 
		zemail_list_x_user_deleted = #db.param(0)# 
		order by user_id asc 
		LIMIT #db.param(offset)#,#db.param(sendEmailCount)#";
		qE=db.execute("qE");
	}
	
	if(qE.recordcount EQ 0){
		// this list is complete, set email list to complete
		db.sql="UPDATE #db.table("zemail_list_x_campaign", request.zos.zcoreDatasource)# zemail_list_x_campaign 
		SET zemail_list_x_campaign_complete = #db.param('1')#,
		zemail_list_x_campaign_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE zemail_campaign_id=#db.param(qEmail.zemail_campaign_id)# and 
		site_id = #db.param(qemail.site_id)# and 
		zemail_list_x_campaign_deleted = #db.param(0)# ";
		db.execute("q");
		// re-run email campaign to check for next list.
		this.runEmailCampaign();
		return;
	}else{
		// loop users and send emails			
		for(i=1;i LTE qE.recordcount;i++){
			// check for server scope status change before sending each email
			if(isdefined('application.zcore.changeEmailCampaignStatus'&qemail.zemail_campaign_id)){
				s=application.zcore['changeEmailCampaignStatus'&qemail.zemail_campaign_id];
				db.sql="UPDATE #db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign 
				SET zemail_campaign_status = #db.param(s)#,
				zemail_campaign_updated_datetime=#db.param(request.zos.mysqlnow)# 
				WHERE zemail_campaign_id=#db.param(qEmail.zemail_campaign_id)# and 
				zemail_campaign_deleted = #db.param(0)#";
				db.execute("q");
				if(s neq 1){
					break;
				}
			}
			if((gettickcount()-start)/1000 gt timeoutSeconds){
				break;
			}
			// record sent record
			 db.sql="INSERT INTO #db.table("zemail_campaign_x_user", request.zos.zcoreDatasource)#  
			 SET zemail_campaign_id=#db.param(qemail.zemail_campaign_id)#, 
			 zemail_campaign_x_user_updated_datetime=#db.param(request.zos.mysqlnow)#,
			 user_id=#db.param(qe.user_id[i])#, 
			 site_id=#db.param(qEmail.site_id)#";
			result=db.insert("q", request.zOS.insertIDColumnForSiteIDTable);
			// ignore duplicate errors since email campaign was already sent to that user_id
			if(result.success){
				ts=StructNew();
				ts.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qE.site_id[i]);
				ts.user_id=qE.user_id[i]; // DEBUGsend to myself only
				ts.site_id=qemail.site_id;
				//ts.preview=true;
				ts.zemail_template_id = qEmail.zemail_template_id;
				ts.from=qemail.zemail_campaign_from;
				ts.forceOptInDatetime=qemail.zemail_campaign_force_optin_datetime;
				if(qemail.zemail_campaign_optin_reminder EQ 0){
					ts.showOptInReminder=false;
				}else{
					ts.showOptInReminder=true;
				}
				// force plus addressing for the failto: (return-path header) so it includes the user_id in bounces.
				ts.failto=replace(qemail.zemail_campaign_from,"@","+"&qE.user_id[i]&"_"&qemail.zemail_campaign_id&"_"&((qE.user_id[i]*3)+243)&"_"&qemail.site_id&"@");
				ts.zemail_campaign_id=qEmail.zemail_campaign_id;
				rCom=this.sendEmailTemplate(ts);
				if(rCom.isOK() EQ false){
					 db.sql="DELETE FROM #db.table("zemail_campaign_x_user", request.zos.zcoreDatasource)#  
					 WHERE zemail_campaign_id=#db.param(qemail.zemail_campaign_id)# and 
					 user_id=#db.param(qe.user_id[i])# and 
					 zemail_campaign_x_user_deleted = #db.param(0)#";
					 db.execute("q");
					arrE=rCom.getErrorIds();
					if(arraylen(arrE) eq 1 and arrE[1] eq 5){
						offset++;
						continue; // skip opt in errors.
					}
					 db.sql="UPDATE #db.table("zemail_list_x_campaign", request.zos.zcoreDatasource)# zemail_list_x_campaign 
					 SET zemail_list_x_campaign_offset = #db.param((offset-1))#,
					 zemail_list_x_campaign_updated_datetime=#db.param(request.zos.mysqlnow)# 
					 WHERE zemail_campaign_id=#db.param(qEmail.zemail_campaign_id)# and 
					 site_id=#db.param(qEmail.site_id)# and 
					 zemail_list_x_campaign_deleted = #db.param(0)# ";
					 db.execute("q");
					// update email campaign status to be 2 which is "error"
					 db.sql="UPDATE #db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign 
					 SET zemail_campaign_status = #db.param('2')#,
					 zemail_campaign_updated_datetime=#db.param(request.zos.mysqlnow)# 
					 WHERE zemail_campaign_id=#db.param(qEmail.zemail_campaign_id)# and 
					 zemail_campaign_deleted = #db.param(0)#";
					 db.execute("q");
					rCom.fail('Email Campaign Failed to send an email for the following reason(s):<br /><br />'&arraytolist(rCom.getErrors(),'<br />'));
					// consider generating error or email alert here.
				}else{
					writeoutput('email sent for zemail_list_id='&qlist.zemail_list_id&' offset='&offset&'<br />');
				}
			}
			offset++;
		}
		// update offset
		db.sql="UPDATE #db.table("zemail_list_x_campaign", request.zos.zcoreDatasource)# zemail_list_x_campaign 
		SET zemail_list_x_campaign_offset = #db.param(offset)#,
		zemail_list_x_campaign_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE zemail_campaign_id=#db.param(qEmail.zemail_campaign_id)# and 
		site_id=#db.param(qEmail.site_id)# and 
		zemail_list_x_campaign_deleted = #db.param(0)#";
		db.execute("q");
	}
	//application.zcore.functions.zdump(request.zos.arrQueryLog);
	</cfscript>
</cffunction>

	
<!--- 
// zemail_campaign_status | 1 = running, 2 = error, 3 = complete, 4 paused
emailCom.setEmailCampaignStatus(zemail_campaign_id, zemail_campaign_status, site_id); 
 --->
<cffunction name="setEmailCampaignStatus" localmode="modern" returntype="boolean" output="no" hint="Used to cancel a running email campaign.">
	<cfargument name="zemail_campaign_id" type="numeric" required="yes">
	<cfargument name="zemail_campaign_status" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="no" default="#request.zos.globals.id#">
	<cfscript>
	
	var qcheck='';
	var db=request.zos.queryObject;
	</cfscript>
	<cfsavecontent variable="db.sql">
	select * from #db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign 
	WHERE zemail_campaign_id = #db.param(arguments.zemail_campaign_id)# and 
	site_id = #db.param(arguments.site_id)# and 
	zemail_campaign_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qcheck=db.execute("qCheck");</cfscript>
	<cfif qcheck.recordcount eq 1>
		<cfscript>
		// set server scope so next email loop will update the email campaign status
		application.zcore['changeEmailCampaignStatus'&arguments.zemail_campaign_id]=arguments.zemail_campaign_status;
		</cfscript>
		<cfreturn true>
	</cfif>
	<cfreturn false>
</cffunction>



<!--- 
ts=StructNew();
ts.update=false;
ts.zemail_campaign_id=""; // required when updating
// required for inserting
ts.zemail_campaign_name=""; // doesn't have to be unique
ts.zemail_template_id=""; // will be copied to a new record
// optional
ts.zemail_campaign_scheduled=0; // set to 1 to run ASAP or set zemail_campaign_scheduled_datetime to a future date below
ts.zemail_campaign_scheduled_datetime=request.zos.mysqlnow; // will be scheduled to run in next available slot after the scheduled time.
ts.user_id=user_id;
ts.site_id=request.zos.globals.id;
ts.arrEmailListIds=arraynew(1); // array with 1 or more zemail_list_id
rs=emailCom.saveEmailCampaign(ts);
if(rs.isOK()){
	// rs.getData().zemail_campaign_id;
}else{
}
 --->
<!--- updating uses the email_template that was copied --->
<cffunction name="saveEmailCampaign" localmode="modern" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qE='';
	var result='';
	var db=request.zos.queryObject;
	// FUTURE: maybe i should give a warning when scheduling email campaigns within 1 week of each other
	// maybe i should store a final version of the email html and plain text for archival reasons
	var ts=StructNew();
	var ts2=StructNew();
	var ns=0;
	var qEmailTemplate=0;
	var nowDate=request.zos.mysqlnow;
	var update=false;
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var rs=structnew();
	var t2=0;
	ts.update=false;
	ts.site_id=request.zos.globals.id;
	ts.zemail_campaign_scheduled=0;
	ts.zemail_template_id=0;
	ts.zemail_campaign_scheduled_datetime=false;
	ts.zemail_campaign_from=false;
	//ts.arrEmailListIds=arrayNew(1);
	ts.user_id=request.zsession.user.id; // email campaigns always require a logged in user
	StructAppend(arguments.ss,ts,false);
	structdelete(arguments.ss,'zemail_campaign_status');
	// zemail_campaign_status | 1 = running, 2 = error, 3 = complete, 4 paused
	if(arguments.ss.update){
		db.sql="select * from #db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign 
		where zemail_campaign_id = #db.param(arguments.ss.zemail_campaign_id)# and 
		site_id = #db.param(arguments.ss.site_id)# and 
		zemail_campaign_deleted = #db.param(0)# ";
		qE=db.execute("qE");
		if(qE.recordcount EQ 0){
			rCom.setError("Couldn't save email campaign because the ID doesn't exist.",2);
			return rCom;
		}else if(qE.zemail_campaign_status EQ 1){
			rCom.setError("You can't update an email campaign that is already running.",3);
			return rCom;
		}else if(qE.zemail_campaign_status EQ 2){
			rCom.setError("This email campaign has had an error. It must be resolved and you must restart the campaign.",4);
			return rCom;
		}else if(qE.zemail_campaign_status EQ 3){
			rCom.setError("You can't update an email campaign that is already completely sent out.",5);
			return rCom;
		}else if(qE.zemail_campaign_status EQ 4){
			rCom.setError("You can't update an email campaign that is already running.",6);
			return rCom;
		}	
		arguments.ss.zemail_template_id=qe.zemail_template_id;
	}else{
		if(arguments.ss.zemail_template_id eq 0){
			rCom.setError("You must specify an email template we're when saving an email campaign.",1);
			return rCom;
		}
	}
	if(arguments.ss.zemail_campaign_from EQ false){
		arguments.ss.zemail_campaign_from=application.zcore.functions.zvar('emailCampaignFrom',arguments.ss.site_id); // set to default
		if(trim(arguments.ss.zemail_campaign_from) EQ ''){
			rCom.setError("You must specify the From E-Mail Address for this email campaign.",7);
			return rCom;
		}
	}
	if(structkeyexists(arguments.ss,'zemail_campaign_name') EQ false or trim(arguments.ss.zemail_campaign_name) EQ ''){
		rCom.setError("Email Campaign Name is required.",8);
		return rCom;
	}else{
		arguments.ss.zemail_campaign_name=trim(arguments.ss.zemail_campaign_name);
	}
	if(arguments.ss.zemail_campaign_scheduled EQ 1 and arguments.ss.zemail_campaign_scheduled_datetime EQ false){
		arguments.ss.zemail_campaign_scheduled_datetime=nowDate;
	/*}else if(arguments.ss.zemail_campaign_scheduled_datetime NEQ false){
		arguments.ss.zemail_campaign_scheduled=1;*/
	}
	if(arguments.ss.update EQ false){
		// create a copy of zemail_template so that it can't be edited while sending
		db.sql="SELECT * FROM #db.table("zemail_template", request.zos.zcoreDatasource)# zemail_template 
		WHERE zemail_template_id = #db.param(arguments.ss.zemail_template_id)# and 
		site_id = #db.param(arguments.ss.site_id)# and 
		zemail_template_deleted = #db.param(0)# ";
		qEmailTemplate=db.execute("qEmailTemplate");
		if(qEmailTemplate.recordcount EQ 0){
			rCom.setError("Email template doesn't exist.",9);
			return rCom;
		}
		ns=StructNew();
		t2=structnew();
		application.zcore.functions.zQueryToStruct(qEmailTemplate,t2);
		ns.struct=t2;
		ns.struct.zemail_template_active=0;
		ns.table="zemail_template";
		ns.datasource="#request.zos.zcoreDatasource#";
		arguments.ss.zemail_template_id=application.zcore.functions.zInsert(ns);
		if(arguments.ss.zemail_template_id EQ false){
			rCom.setError("Failed to create a copy of email template.",10);
			return rCom;
		}
	}
	ns=structnew();
	ns.table="zemail_campaign";
	ns.datasource="#request.zos.zcoreDatasource#";
	ns.struct=arguments.ss;
	if(arguments.ss.update){
		result=application.zcore.functions.zUpdate(ns);
		rs.zemail_campaign_id=arguments.ss.zemail_campaign_id;
	}else{
		ns.struct.zemail_campaign_created_datetime=nowDate;
		rs.zemail_campaign_id=application.zcore.functions.zInsert(ns);
		result=rs.zemail_campaign_id;
	}
	if(result EQ false){
		// delete the template copy
		db.sql="DELETE FROM #db.table("zemail_template", request.zos.zcoreDatasource)#  
		WHERE zemail_template_id = #db.param(arguments.ss.zemail_template_id)# and 
		site_id = #db.param(arguments.ss.site_id)# and 
		zemail_template_deleted = #db.param(0)#";
		db.execute("q");
		rCom.setError("Failed to save email campaign.",11);
		return rCom;
	}
	db.sql="UPDATE #db.table("zemail_template", request.zos.zcoreDatasource)# zemail_template 
	SET zemail_campaign_id = #db.param(rs.zemail_campaign_id)#,
	zemail_template_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE zemail_template_id = #db.param(arguments.ss.zemail_template_id)# and 
	site_id = #db.param(arguments.ss.site_id)# and 
	zemail_template_deleted = #db.param(0)#";
	db.execute("q");
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>



<!--- 
ts=StructNew();
// optional used for update
// ts.zemail_list_id=0;
// required
ts.zemail_list_name="";
// optional
ts.site_id=request.zos.globals.id;
rCom=emailCom.saveEmailList(ts);
if(rCom.isOK()){
	zemail_list_id=rCom.getData().zemail_list_id;
}else{
	rCom.setStatusErrors(request.zsid);
	application.zcore.functions.zStatusHandler(request.zsid);
	application.zcore.functions.zabort();
}
--->
<cffunction name="saveEmailList" localmode="modern" output="yes" returntype="any" hint="Create or update an email list">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var result="";
	var ts=StructNew();
	var rs=StructNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	ts.site_id=request.zos.globals.id;
	ts.zemail_campaign_id=0;
	ts.arrEmailListIds=arrayNew(1);
	ts.zemail_list_id=0;
	ts.user_id=request.zsession.user.id; // email campaigns always require a logged in user
	StructAppend(arguments.ss,ts,false);
	if(trim(arguments.ss.zemail_list_name) EQ ""){
		rCom.setError("Email list name is required.",1);
		return rCom;
	}
	ts=StructNew();
	ts.datasource="#request.zos.zcoreDatasource#";
	ts.table="zemail_list";
	ts.struct=arguments.ss;
	if(arguments.ss.zemail_list_id NEQ 0){
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			rCom.setError("Failed to update email list",2);
		}
		rs.zemail_list_id=arguments.ss.zemail_list_id;	
	}else{
		result=application.zcore.functions.zInsert(ts);
		if(result EQ false){
			rCom.setError("Failed to create email list",3);
		}
		rs.zemail_list_id=result;			
	}
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>

<!--- 
ts=StructNew();
ts.zemail_campaign_id=0;
ts.arrEmailListIds=arrayNew(1); // empty array will clear the selected email lists
rs=emailCom.setEmailList(ts);
if(rs.isOK()){
	writeoutput('setEmailList successfull<br />');
}else{
	//zdump(rs.arrErrors);
}
 --->
<cffunction name="setEmailList" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var i=0;
	var db=request.zos.queryObject;
	var ts=StructNew();
	var rs=StructNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	ts.site_id=request.zos.globals.id;
	ts.zemail_campaign_id=0;
	ts.arrEmailListIds=arrayNew(1);
	ts.user_id=request.zsession.user.id; // email campaigns always require a logged in user
	StructAppend(arguments.ss,ts,false);
	if(isarray(arguments.ss.arrEmailListIds) EQ false){
		rCom.setError("You must specify one or more email list.",1);
		return rCom;
	}
	if(arguments.ss.zemail_campaign_id EQ 0){
		rCom.setError("You must specify an email campaign to set the lists for.",2);
		return rCom;
	}
	 db.sql="DELETE FROM #db.table("zemail_list_x_campaign", request.zos.zcoreDatasource)#  
	 WHERE zemail_campaign_id =#db.param(arguments.ss.zemail_campaign_id)# and 
	 site_id = #db.param(arguments.ss.site_id)# and 
	 zemail_list_x_campaign_deleted = #db.param(0)# ";	
	 db.execute("q");
	for(i=1;i LTE arrayLen(arguments.ss.arrEmailListIds);i++){
		db.sql="INSERT INTO #db.table("zemail_list_x_campaign", request.zos.zcoreDatasource)#  
		SET zemail_campaign_id =#db.param(arguments.ss.zemail_campaign_id)#, 
		zemail_list_id=#db.param(arguments.ss.arrEmailListIds[i])#, 
		zemail_list_x_campaign_updated_datetime=#db.param(request.zos.mysqlnow)#,
		site_id = #db.param(arguments.ss.site_id)#";			
		db.execute("q");
	}
	return rCom;
	</cfscript>
</cffunction>


<!--- 
ts=StructNew();
// array of IDs or Names, but not both
ts.arrEmailListIds=arrayNew(1);
ts.arrEmailListNames=arrayNew(1);
// optional
ts.site_id=0; // set to zero to get default system email lists.
ts.selectAll=true; // set to false to only select zemail_list_id
rs=emailCom.getEmailList(ts);
if(rs.isOK()){
	writeoutput('getEmailList successfull<br />');
}else{
	//zdump(rs.arrErrors);
}
 --->
<cffunction name="getEmailList" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=StructNew();
	var rs=StructNew();
	var db=request.zos.queryObject;
	var qE=0;
	var db=request.zos.queryObject;
	var fields="*";
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	ts.site_id=request.zos.globals.id;
	ts.arrEmailListIds=arrayNew(1);
	ts.arrEmailListNames=arrayNew(1);
	ts.selectAll=true;
	ts.user_id=request.zsession.user.id; // email campaigns always require a logged in user
	StructAppend(arguments.ss,ts,false);
	if(arguments.ss.selectAll EQ false){
		fields="zemail_list_id";
	}else{
		fields="*";
	}
	if(arraylen(arguments.ss.arrEmailListIds) neq 0){
		ts.list="'"&replace(application.zcore.functions.zescape(arraytolist(arguments.ss.arrEmailListIds,",")),",","','","all")&"'";
		db.sql="SELECT #fields# FROM #db.table("zemail_list", request.zos.zcoreDatasource)# zemail_list 
		WHERE zemail_list_id in (#db.trustedSQL(ts.list)#) and 
		zemail_list_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.ss.site_id)# ";
		qE=db.execute("qE");
	}else if(arraylen(arguments.ss.arrEmailListNames) neq 0){
		ts.list="'"&replace(application.zcore.functions.zescape(arraytolist(arguments.ss.arrEmailListNames,",")),",","','","all")&"'";
		db.sql="SELECT #fields# FROM #db.table("zemail_list", request.zos.zcoreDatasource)# zemail_list 
		WHERE zemail_list_name in (#db.trustedSQL(ts.list)#) and 
		zemail_list_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.ss.site_id)# ";
		qE=db.execute("qE");
	}else{
		rCom.setError("You must select one or more email lists.",1);
		return rCom;
	}
	if(isQuery(qE)){
		if(qE.recordcount EQ 0){
			rCom.setError("Selected email lists no longer exist.",2);
			return rCom;
		}else{
			rs.query=qE;
		}
	}else{
		rCom.setError("Invalid email list selection.",3);
		return rCom;
	}
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>


<!--- 
ts=StructNew();
ts.popserver=application.zcore.functions.zvar('emailPopserver',arguments.ss.site_id);
ts.username=application.zcore.functions.zvar('emailusername',arguments.ss.site_id);
ts.password=application.zcore.functions.zvar('emailpassword',arguments.ss.site_id);
ts.siteIdDefault=0;
ts.emailCampaignDefault=0;
emailCom.processBounces(ts);
--->
<cffunction name="processBounces" localmode="modern" output="yes" returntype="void">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var smtpStatusCodes='';
	var esmtpStatusCodes='';
	var db=request.zos.queryObject;
	var arrSmtpCodes='';
	var bcheck='';
	var arrBCheckOrder='';
	var arrBCheckClickType='';
	var otherReplies='';
	var arrDeleteEmail='';
	var i='';
	var g='';
	var debug='';
	var zemail_campaign_click_html='';
	var qHeader='';
	var db=request.zos.queryObject;
	var ts=structnew();
	ts.popserver="";
	ts.username="";
	ts.password="";
	//ts.zemail_campaign_id=false;
	ts.siteIdDefault=0;
	ts.emailCampaignDefault=0;
	StructAppend(arguments.ss,ts,false);
	
smtpStatusCodes=structnew();
smtpStatusCodes["211"]="System status, or system help reply";
smtpStatusCodes["214"]="Help message [Information on how to use the receiver or the meaning of a particular non-standard command; this reply is useful only to the human user]";
smtpStatusCodes["220"]="<domain> Service ready";
smtpStatusCodes["221"]="<domain> Service closing transmission channel";
smtpStatusCodes["250"]="Requested mail action okay, completed";
smtpStatusCodes["251"]="User not local; will forward to <forward-path>";

smtpStatusCodes["354"]="Start mail input; end with <CRLF>.<CRLF>";

smtpStatusCodes["421"]="<domain> Service not available, closing transmission channel [This may be a reply to any command if the service knows it must shut down]";
smtpStatusCodes["450"]="Requested mail action not taken: mailbox unavailable [E.g., mailbox busy]";
smtpStatusCodes["451"]="Requested action aborted: local error in processing";
smtpStatusCodes["452"]="Requested action not taken: insufficient system storage";

smtpStatusCodes["500"]="Syntax error, command unrecognized [This may include errors such as command line too long]";
smtpStatusCodes["501"]="Syntax error in parameters or arguments";
smtpStatusCodes["502"]="Command not implemented";
smtpStatusCodes["503"]="Bad sequence of commands";
smtpStatusCodes["504"]="Command parameter not implemented";
smtpStatusCodes["550"]="Requested action not taken: mailbox unavailable [E.g., mailbox not found, no access]";
smtpStatusCodes["551"]="User not local; please try <forward-path>";
smtpStatusCodes["552"]="Requested mail action aborted: exceeded storage allocation";
smtpStatusCodes["553"]="Requested action not taken: mailbox name not allowed [E.g., mailbox syntax incorrect]";
smtpStatusCodes["554"]="Transaction failed";

esmtpStatusCodes[".1.0"]="Other address status";
esmtpStatusCodes[".1.1"]="Bad destination mailbox address";
esmtpStatusCodes[".1.2"]="Bad destination system address";
esmtpStatusCodes[".1.3"]="Bad destination mailbox address syntax";
esmtpStatusCodes[".1.4"]="Destination mailbox address ambiguous";
esmtpStatusCodes[".1.5"]="Destination mailbox address valid";
esmtpStatusCodes[".1.6"]="Mailbox has moved";
esmtpStatusCodes[".1.7"]="Bad sender's mailbox address syntax";
esmtpStatusCodes[".1.8"]="Bad sender's system address";

esmtpStatusCodes[".2.0"]="Other or undefined mailbox status";
esmtpStatusCodes[".2.1"]="Mailbox disabled, not accepting messages";
esmtpStatusCodes[".2.2"]="Mailbox full";
esmtpStatusCodes[".2.3"]="Message length exceeds administrative limit.";
esmtpStatusCodes[".2.4"]="Mailing list expansion problem";

esmtpStatusCodes[".3.0"]="Other or undefined mail system status";
esmtpStatusCodes[".3.1"]="Mail system full";
esmtpStatusCodes[".3.2"]="System not accepting network messages";
esmtpStatusCodes[".3.3"]="System not capable of selected features";
esmtpStatusCodes[".3.4"]="Message too big for system";

esmtpStatusCodes[".4.0"]="Other or undefined network or routing status";
esmtpStatusCodes[".4.1"]="No answer from host";
esmtpStatusCodes[".4.2"]="Bad connection";
esmtpStatusCodes[".4.3"]="Routing server failure";
esmtpStatusCodes[".4.4"]="Unable to route";
esmtpStatusCodes[".4.5"]="Network congestion";
esmtpStatusCodes[".4.6"]="Routing loop detected";
esmtpStatusCodes[".4.7"]="Delivery time expired";

esmtpStatusCodes[".5.0"]="Other or undefined protocol status";
esmtpStatusCodes[".5.1"]="Invalid command";
esmtpStatusCodes[".5.2"]="Syntax error";
esmtpStatusCodes[".5.3"]="Too many recipients";
esmtpStatusCodes[".5.4"]="Invalid command arguments";
esmtpStatusCodes[".5.5"]="Wrong protocol version";

esmtpStatusCodes[".6.0"]="Other or undefined media error";
esmtpStatusCodes[".6.1"]="Media not supported";
esmtpStatusCodes[".6.2"]="Conversion required and prohibited";
esmtpStatusCodes[".6.3"]="Conversion required but not supported";
esmtpStatusCodes[".6.4"]="Conversion with loss performed";
esmtpStatusCodes[".6.5"]="Conversion failed";

esmtpStatusCodes[".7.0"]="Other or undefined security status";
esmtpStatusCodes[".7.1"]="Delivery not authorized, message refused";
esmtpStatusCodes[".7.2"]="Mailing list expansion prohibited";
esmtpStatusCodes[".7.3"]="Security conversion required but not possible";
esmtpStatusCodes[".7.4"]="Security features not supported";
esmtpStatusCodes[".7.5"]="Cryptographic failure";
esmtpStatusCodes[".7.6"]="Cryptographic algorithm not supported";
esmtpStatusCodes[".7.7"]="Message integrity failure";



arrSmtpCodes=structkeyarray(smtpStatusCodes);

bcheck=StructNew();
// bouncePostmaster
bcheck["temporaryBounce"]["body"]=["over quota","quota exceeded","exceeded quota","mailbox full","could not be delivered because they are not accepting mail with attachments or embedded images"];
// challenge response checks
bcheck["challengeResponse"]["header"]=["Unverified email to"];
bcheck["challengeResponse"]["body"]=["verified sender","verification process","link to verify","complete this verification","is being held because the address","Active Spam Killer"];
bcheck["challengeResponse"]["cc"]=["you verify"];
// Out Of Office checks
bcheck["outOfOffice"]["subject"]=["out of office","out of the office"];
bcheck["outOfOffice"]["body"]=["out of the office","Out of office"];
bcheck["outOfOffice"]["body"]=["out of the office","I am away until"];
bcheck["outOfOffice"]["header"]=["autoresponder"];
// anti-spam bounce checks
bcheck["antiSpamBounce"]["subject"]=["bulk email"];
bcheck["antiSpamBounce"]["body"]=["spam firewall","rejected as likely spam","Spam SLS/RBL","is refused. See","vip-antispam","content rejected","URL in the content of your message"];
bcheck["antiSpamBounce"]["from"]=["antivirus","content filter rejected"];
// bounce checks
bcheck["bounce"]["subject"]=["Delivery Status Notification (Failure)","Delivery reports about your email","failure delivery","failure notice","Mail delivery failed","Message you sent blocked","Delivery Status Notification","Undelivered Mail Returned to Sender","Returned mail","Mail Delivery Problem","Delivery to the following recipients failed"];
bcheck["bounce"]["body"]=["address rejected"];
// bounce2
bcheck["bounce2"]["subject"]=["Delivery Notification","Undeliverable","Delivery Failure"];
bcheck["bounce2"]["body"]=["Could not deliver mail to this user","message did not reach the following recipients","Reflexion Total Control"];
// bouncePostmaster
bcheck["bouncePostmaster"]["from"]=["postmaster@","mailer-daemon@"];
/*
// skp postmaster
bcheck["bounceMisc"]["from"]=["postmaster@mail.escapees.com"];
bcheck["bounceMisc"]["subject"]=["postmaster@escapees.com"];
// cox bounce
bcheck["bounceMisc"]["header"]=["From: Mail Administrator <Postmaster@cox.net>"];
// cc bounce
bcheck["bounceMisc"]["header"]=["MAILER-DAEMON@catalog.com"];
*/
arrBCheckOrder=["temporaryBounce","challengeResponse","antiSpamBounce","bounce","bounce2","bouncePostmaster","outOfOffice"];
arrBCheckClickType=[7,8,9,3,3,3,6];
otherReplies=10;

arrDeleteEmail=arraynew(1);
</cfscript>
	<CFPOP 
	ACTION="getall"
	NAME="qHeader"
	SERVER="#arguments.ss.popserver#"
	USERNAME="#arguments.ss.username#"
	PASSWORD="#arguments.ss.password#" 
	timeout="300" 
	><!---  --->
<cfloop query="qHeader">
<cfscript>
ts=StructNew(); // store bounce tests
// check "to" for plus addressing
ts.site_id=arguments.ss.siteIdDefault;
ts.zemail_campaign_id=arguments.ss.emailCampaignDefault;
ts.user_id=rereplace(to,"[^\+]*\+([0-9]*)_([0-9]*)_([0-9]*)_([0-9]*)@.*", "\1	\2	\3	\4");
if(len(to) EQ len(ts.user_id)){
	ts.user_id=rereplace(to,"[^\+]*\+([0-9]*)@.*", "\1");
	if(len(to) EQ len(ts.user_id)){
		ts.user_id=0;
	}
}else if(listlen(ts.user_id,chr(9)) eq 4){
	ts.site_id=listgetat(ts.user_id,4,chr(9));
	ts.unique_key=listgetat(ts.user_id,3,chr(9));
	ts.zemail_campaign_id=listgetat(ts.user_id,2,chr(9));
	ts.user_id=listgetat(ts.user_id,1,chr(9));
	if(ts.unique_key NEQ ((ts.user_id*3)+243)){
		// someone is attacking the system - don't allow this bounce to opt-out our user!
		ts.user_id=0;
		ts.zemail_campaign_id=0;
		ts.site_id=0;
		ts.unique_key=0;
	}
}
// detect properly formatted bounce
ts.emptyReturnPath=false;
if(findnocase("Return-Path: <>", header) NEQ 0){
	ts.emptyReturnPath=true;
}else if(findnocase("Return-Path:", header) EQ 0){
	ts.emptyReturnPath=true;
}
ts.smtpStatusCode="";
ts.smtpStatusMessage="";
ts.smtpEnhancedStatusCode="";
ts.smtpEnhancedStatusMessage="";
for(i=1;i lte arraylen(arrSmtpCodes);i++){
	if(refind("\b"&arrSmtpCodes[i]&"\b", body) NEQ 0){
		ts.smtpStatusCode=arrSmtpCodes[i];
		ts.smtpStatusMessage=smtpStatusCodes[arrSmtpCodes[i]];
		/*if(ts.smtpStatusCode eq '551'){
			writeoutput('<hr />'&htmleditformat(header&'<br /><br />'&body));
		}*/
		ts.smtpEnhancedStatusCode=rematch("[2|4|5]\.[1-7]\.[0-8]",body);
		if(arraylen(ts.smtpEnhancedStatusCode) EQ 0){
			ts.smtpEnhancedStatusCode="";
		}else{
			ts.smtpEnhancedStatusCode=ts.smtpEnhancedStatusCode[1];
			if(structkeyexists(esmtpStatusCodes,removechars(ts.smtpEnhancedStatusCode,1,1))){
				ts.smtpEnhancedStatusMessage=esmtpStatusCodes[removechars(ts.smtpEnhancedStatusCode,1,1)];
			}
		}
		break;
	}
}
ts.type="";
for(g=1;g lte arraylen(arrBCheckOrder);g++){
	c=bcheck[arrBCheckOrder[g]];
	for(f in c){
		for(i=1;i lte arraylen(c[f]);i++){
			if(findnocase(c[f][i], qHeader[f][currentrow]) NEQ 0){
				ts.type=arrBCheckOrder[g];
				ts.clicktype=arrBCheckClickType[g];
				break;
			}
		}
		if(len(ts.type) NEQ 0){
			break;
		}
	}
	if(len(ts.type) NEQ 0){
		break;
	}
}
ts.matched=true;
debug=false;
ts.permanent=false;
if(len(ts.type) EQ 0){
	ts.matched=false;
	//writeoutput(findnocase("Return-Path: <>",header));
	if(ts.emptyReturnPath){
		ts.type="otherBounce";
		ts.clicktype=3;
		// this is probably a permanent bounce, but i can't know for sure yet.
		// ts.permanent=true;
		
		/*application.zcore.functions.zdump(ts);
		for(i=1;i lte listlen(qHeader.columnlist);i++){
			writeoutput(listgetat(qHeader.columnlist,i)&' = ');
			//zdump(qHeader[listgetat(qHeader.columnlist,i)][currentrow]);
			writeoutput('<hr />');
		}
		writeoutput('<br />');*/
	/*}else if(debug){
		for(i=1;i lte listlen(qHeader.columnlist);i++){
			writeoutput(listgetat(qHeader.columnlist,i)&' = ');
			application.zcore.functions.zdump(qHeader[listgetat(qHeader.columnlist,i)][currentrow]);
			writeoutput('<hr />');
		}
		writeoutput('<br />');*/
	}else{
		// a real reply or an unknown condition
		ts.clicktype=otherReplies;			
	}
}else{
	if(left(ts.smtpStatusCode,1) EQ '5'){
		ts.permanent=true;
		ts.clicktype=3;
	}else if(ts.smtpStatusCode EQ '' and (ts.type EQ 'bouncePostmaster' or ts.type EQ 'bounce' or ts.type EQ 'bounce2')){
		ts.permanent=true;
		ts.clicktype=3;
	}
	/*
	if(left(ts.smtpStatusCode,1) EQ '5'){
		//zdump(ts);
		
		for(i=1;i lte listlen(qHeader.columnlist);i++){
			writeoutput(listgetat(qHeader.columnlist,i)&' = ');
			//zdump(qHeader[listgetat(qHeader.columnlist,i)][currentrow]);
			writeoutput('<hr />');
		}
		writeoutput('<br />');
	}*/
}
ts.delete=false;
writeoutput(ts.clicktype&' | ');
if(ts.permanent){
	// never email this user again
	writeoutput('permanent | ');
	if(ts.user_id NEQ 0){
		//writeoutput("UPDATE #db.table("user", request.zos.zcoreDatasource)# user SET user_confirm=0, user_pref_list=0 where user_id =#db.param(ts.user_id)#<br />");
		application.zcore.template.fail("query is missing site_id here");
		db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
		SET user_confirm=#db.param(0)#, 
		user_pref_list=#db.param(0)#,
		user_updated_datetime=#db.param(request.zos.mysqlnow)# 
		where user_id =#db.param(ts.user_id)# and 
		user_deleted = #db.param(0)#";
		db.execute("q");
	}
	ts.delete=true;
}else if(ts.type EQ "outOfOffice" or ts.type EQ 'temporaryBounce' or left(ts.smtpStatusCode,1) EQ '4'){
	ts.delete=true;
}
if(ts.delete and ts.zemail_campaign_id NEQ 0){
	db.sql="INSERT INTO #db.table("zemail_campaign_click", request.zos.zcoreDatasource)#  
	SET zemail_campaign_click_type=#db.param(ts.clicktype)#, 
	zemail_campaign_click_html=#db.param('0')#,
	 zemail_campaign_click_offset=#db.param('0')#, 
	 zemail_campaign_click_ip=#db.param('')#, 
	 zemail_campaign_click_datetime=#db.param(request.zos.mysqlnow)#, 
	 zemail_campaign_id=#db.param(ts.zemail_campaign_id)#, 
	 zemail_campaign_click_updated_datetime=#db.param(request.zos.mysqlnow)#,
	user_id=#db.param(ts.user_id)#,
	site_id=#db.param(ts.site_id)#";
	db.execute("q");
}
	//application.zcore.functions.zdump(ts);
</cfscript> 

<cfif ts.delete>
	<cfscript>
	arrayappend(arrDeleteEmail,uid);
	</cfscript><!--- 
delete message | 
	   <CFPOP
		ACTION="Delete" 
		uid="#uid#"
		SERVER="#arguments.ss.popserver#"
		USERNAME="#arguments.ss.username#"
		PASSWORD="#arguments.ss.password#" 
		timeout="5"> --->
	<!--- 
		<cfcatch type="any">
		<!--- ignore delete errors --->
		</cfcatch> --->
	<!--- <cfelse><cfdump var="#ts#"> --->
</cfif>
subject: #subject#
<br />

<!--- <cfif currentrow mod 30 eq 0> <cfscript>application.zcore.functions.zabort();</cfscript></cfif> --->
</cfloop>
<!--- <cfdump var="#qHeader#"> --->
<cfloop from="1" to="#arraylen(arrDeleteEmail)#" index="i">
	   <CFPOP
		ACTION="Delete" 
		uid="#arrDeleteEmail[i]#"
		SERVER="#arguments.ss.popserver#"
		USERNAME="#arguments.ss.username#"
		PASSWORD="#arguments.ss.password#" 
		timeout="5">
</cfloop>
</cffunction>
</cfoutput>
</cfcomponent>