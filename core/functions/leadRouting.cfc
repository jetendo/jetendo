<cfcomponent extends="zcorerootmapping.functions.macro">
<cfoutput>
<!--- application.zcore.functions.zSetOfficeIdForAutoresponder(officeId); --->
<cffunction name="zSetOfficeIdForAutoresponder" localmode="modern" access="public"> 
	<cfargument name="officeId" type="string" required="yes" hint="This is not the same as office_id, it is site specific.">
	<cfscript>
	request.autoresponderOfficeId=arguments.officeId;
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zSetOfficeIdForInquiryId(inquiries_id, office_id); --->
<cffunction name="zSetOfficeIdForInquiryId" localmode="modern" access="public">
	<cfargument name="inquiries_id" type="string" required="yes">
	<cfargument name="office_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	if(arguments.office_id EQ "" or arguments.office_id EQ "0"){
		return;
	}
	db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# 
	SET 
	office_id=#db.param(arguments.office_id)#,
	inquiries_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_deleted=#db.param(0)# and 
	inquiries_id=#db.param(arguments.inquiries_id)# ";
	db.execute("qUpdate");
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zMarkFinalLead(originalInquiriesId, finalInquiriesId); --->
<cffunction name="zMarkFinalLead" localmode="modern" access="public">
	<cfargument name="originalInquiriesId" type="string" required="yes">
	<cfargument name="finalInquiriesId" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	SET inquiries_final_inquiries_id=#db.param(arguments.finalInquiriesId)#,
	inquiries_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE inquiries_id=#db.param(arguments.originalInquiriesId)# and 
	inquiries_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	db.execute("q"); 
	</cfscript>
</cffunction>

<!--- 
<cfscript>
// this is used to record a lead, without redirecting anywhere.
form.inquiries_type_id=1;
form.inquiries_type_id_siteIdType=4;
form.inquiries_email="test@test.com";
form.inquiries_subject="New Inquiry on #request.zos.globals.shortdomain#";
application.zcore.functions.zRecordLead();
</cfscript>
 --->
<cffunction name="zRecordLead" localmode="modern" access="public">
	<cfscript>
	var db=request.zos.queryObject;
	form.inquiries_type_id = application.zcore.functions.zso(form, 'inquiries_type_id',false,1);
	form.inquiries_type_id_siteIdType = application.zcore.functions.zso(form, 'inquiries_type_id_siteIdType',false,4);
	if(form.inquiries_type_id EQ "" or form.inquiries_type_id_siteIDType EQ ""){
		form.inquiries_type_id = 1;
		form.inquiries_type_id_siteIdType=4;
	}
	form.inquiries_status_id = 1; 
	form.site_id = request.zOS.globals.id;
	 
	form.inquiries_session_id=application.zcore.session.getSessionId();
 
	//	Insert Into Inquiry Database
	form.inquiries_id=application.zcore.functions.zInsertLead();
	if(form.inquiries_id NEQ false){
		application.zcore.tracking.setUserEmail(form.inquiries_email);
		application.zcore.tracking.setConversion('inquiry',form.inquiries_id);
		form.contact_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew()));
		  
		ts=structnew();
		ts.inquiries_id=form.inquiries_id;
		if(structkeyexists(form, 'inquiries_subject')){
			ts.subject=form.inquiries_subject;
		}else{
			ts.subject="New Inquiry on #request.zos.globals.shortdomain#";
		}
		// send the lead
		rs=application.zcore.functions.zAssignAndEmailLead(ts);
		if(rs.success EQ false){
			// failed to assign/email lead
			//zdump(rs);
		} 
	}
	</cfscript>
</cffunction>


<cffunction name="zBeforeInquiryInsertUpdate" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	ss.inquiries_email=application.zcore.functions.zso(ss, 'inquiries_email');
	ss.inquiries_phone1_formatted=application.zcore.functions.zFormatInquiryPhone(application.zcore.functions.zso(ss, 'inquiries_phone1'));
	ss.inquiries_phone2_formatted=application.zcore.functions.zFormatInquiryPhone(application.zcore.functions.zso(ss, 'inquiries_phone2'));
	ss.inquiries_phone3_formatted=application.zcore.functions.zFormatInquiryPhone(application.zcore.functions.zso(ss, 'inquiries_phone3'));
	ss.inquiries_priority=application.zcore.functions.zso(ss, 'inquiries_priority', true, 5);
	ss.site_id = request.zOS.globals.id; 

	ss.contact_id=application.zcore.functions.zso(ss, 'contact_id', true);
	if(ss.contact_id EQ 0){
		if(trim(ss.inquiries_email&ss.inquiries_phone1_formatted&ss.inquiries_phone2_formatted&ss.inquiries_phone3_formatted) NEQ ""){
			contactCom=createobject("component", "zcorerootmapping.com.app.contact");

			tsContact={ 
				dataStruct:ss,
				site_id:ss.site_id
			};
			rsContact=contactCom.storeContactForInquiry(tsContact);
			if(rsContact.success){
				ss.contact_id=rsContact.contact_id;
			}
		}
	}
	</cfscript>
</cffunction>

 <!--- 
// this function is used to insert correctly formatted data to the inquiries table.  It will run some last reformatting / validation as a consolidated filter.
application.zcore.functions.zInsertLead();
  --->
<cffunction name="zInsertLead" localmode="modern" access="public">
	<cfscript>

	form.inquiries_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	application.zcore.functions.zBeforeInquiryInsertUpdate(form); 
	inputStruct = StructNew();
	inputStruct.table = "inquiries";
	inputstruct.datasource=request.zos.zcoreDatasource;
	inputStruct.struct=form;
	inquiries_id = application.zcore.functions.zInsert(inputStruct); 
 
	ds=application.zcore.functions.zGetInquiryById(inquiries_id);

	if(structcount(ds) GT 0 and ds.inquiries_email NEQ ""){
		// send autoresponder
		ts={
			// required
			inquiries_type_id:ds.inquiries_type_id,
			inquiries_type_id_siteidtype:ds.inquiries_type_id_siteidtype,
			to:ds.inquiries_email,
			from:request.officeEmail,
			dataStruct:{
				firstName:ds.inquiries_first_name,
				email:ds.inquiries_email,
				interestedInModel:ds.inquiries_interested_in_model,  
				//officeName:"",
				//officeFullInfo:"",
				officeID:application.zcore.functions.zso(request, 'autoresponderOfficeId')
			} 
		}; 
		autoResponderCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.autoresponder");
		rs=autoResponderCom.sendAutoresponder(ts);  
	}  

	return inquiries_id;
	</cfscript>
</cffunction>

<!--- 
ts={
	inquiries_first_name:"",
	// other fields
};
application.zcore.functions.zImportLead(ts); --->
<cffunction name="zImportLead" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	form.inquiries_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	application.zcore.functions.zBeforeInquiryInsertUpdate(ss);  

	inputStruct = StructNew();
	inputStruct.table = "inquiries";
	inputstruct.datasource=request.zos.zcoreDatasource;
	inputStruct.struct=ss;
	inquiries_id = application.zcore.functions.zInsert(inputStruct); 

	return inquiries_id;
	</cfscript>
</cffunction>

 <!--- 
// this function is used to update correctly formatted data to the inquiries table.  It will run some last reformatting / validation as a consolidated filter.
application.zcore.functions.zUpdateLead();
  --->
<cffunction name="zUpdateLead" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss; 
	application.zcore.functions.zBeforeInquiryInsertUpdate(ss);  

	inputStruct = StructNew();
	inputStruct.table = "inquiries";
	inputstruct.datasource=request.zos.zcoreDatasource;
	inputStruct.struct=ss;
	return application.zcore.functions.zUpdate(inputStruct); 
	</cfscript>
</cffunction>
	
<cffunction name="zGetInquiryById" localmode="modern" access="public">
	<cfargument name="inquiries_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	inquiries_id = #db.param(arguments.inquiries_id)# and 
	inquiries_deleted=#db.param(0)#";
	qInquiry=db.execute("qInquiry");
	for(row in qInquiry){
		return row;
	};
	return {};
	</cfscript>
</cffunction>


<cffunction name="zGetInquiryByExternalId" localmode="modern" access="public">
	<cfargument name="inquiries_external_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	inquiries_external_id = #db.param(arguments.inquiries_external_id)# and 
	inquiries_deleted=#db.param(0)#";
	qInquiry=db.execute("qInquiry");
	for(row in qInquiry){
		return row;
	};
	return {};
	</cfscript>
</cffunction>

<!--- zGetInquiryCustomField(inquiries_id, "field", "default"); --->
<cffunction name="zGetInquiryCustomField" localmode="modern" access="public">
	<cfargument name="inquiries_id" type="string" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="defaultValue" type="string" required="no" default="">
	<cfscript>
	inquiryStruct=application.zcore.functions.zGetInquiryById(arguments.inquiries_id);
	if(structcount(inquiryStruct) NEQ 0){
		struct=deserializeJSON(inquiryStruct.inquiries_custom_json);
		if(structkeyexists(struct, 'arrCustom')){
			for(i=1;i LTE arraylen(struct.arrCustom);i++){
				c=struct.arrCustom[i];
				if(c.label EQ arguments.fieldName){
					return c.value;
				}
			}
		}
	}
	return arguments.defaultValue;
	</cfscript>
</cffunction>



<cffunction name="zSetInquiryCustomJsonFromStruct" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	if(structcount(ss) NEQ 0){
		ts={ arrCustom:[] };
		for(i in ss){
			arrayAppend(ts.arrCustom, { label:i, value:trim(ss[i]) });
		}
		return serializeJson(ts);
	}else{
		return "";
	}
	</cfscript>
</cffunction> 

<!--- 
ts=structnew();
ts.inquiries_id=inquiries_id;
ts.subject="New Lead";
// optional
ts.disableDebugAbort=false;
ts.assignEmail="";
ts.office_id=form.office_id;
ts.user_id=request.zsession.user.id;
ts.user_id_siteIDType=1; 
ts.forceAssign=false;
ts.arrAttachments=[];
application.zcore.functions.zAssignAndEmailLead(ts);
 --->
<cffunction name="zAssignAndEmailLead" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var rs=structnew();
	var iemailcom=0;
	var db=request.zos.queryObject;
	var rs2=structnew();
	var inquiries_id=arguments.ss.inquiries_id;
	arrDebug=[];
	if(not structkeyexists(arguments.ss, 'arrAttachments')){
		arguments.ss.arrAttachments=[];
	}
	rs.inquiries_id=arguments.ss.inquiries_id; 
	if(not structkeyexists(arguments.ss, 'disableDebugAbort')){
		arguments.ss.disableDebugAbort=false;
	} 
	if(structkeyexists(arguments.ss, 'forceAssign') and arguments.ss.forceAssign){
		rs.cc=""; 
		if(structkeyexists(arguments.ss, 'assignEmail')){
			rs.assignEmail=arguments.ss.assignEmail;
			rs.user_id=0;
			rs.user_id_siteIDType=0; 
		}else{
			rs.assignEmail="";
			rs.user_id=arguments.ss.assignUserId;
			rs.user_id_siteIDType=arguments.ss.assignUserIdSiteIdType; 
			 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE ";
			if(rs.user_id_siteIDType EQ 1){
				db.sql&=" site_id = #db.param(request.zos.globals.id)# and ";
			}else{
				db.sql&=" site_id = #db.param(request.zos.globals.parentId)# and ";
			}
			db.sql&=" user_active= #db.param(1)# and 
			user_deleted = #db.param(0)# and  
			user_id =#db.param(rs.user_id)# ";
			qAssignUser=db.execute("qAssignUser"); 
			if(qAssignUser.recordcount EQ 0){
				// assign to default email
				rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
				m='process assigned lead to zofficeemail: #rs.assignEmail#<br />';
				arrayAppend(arrDebug, m);
				if(structkeyexists(request.zos, 'debugleadrouting')){
					echo(m);
				}
			}else{
				if(qAssignUser.office_id CONTAINS ","){
					rs.office_id=listGetAt(qAssignUser.office_id, 1, ",");
				}
				if(qAssignUser.user_alternate_email NEQ ""){
					rs.cc=qAssignUser.user_alternate_email;
				}
				// assign to default user instead
				rs.assignEmail=qAssignUser.user_username;  
				m='process assigned lead to zofficeemail user_id: #qAssignUser.user_id# site_id: #qAssignUser.site_id# | #rs.assignEmail#<br />';
				arrayAppend(arrDebug, m);
				if(structkeyexists(request.zos, 'debugleadrouting')){
					echo(m);
				}
			}
		}
		if(structkeyexists(arguments.ss, 'leadEmail')){
			rs.leadEmail=arguments.ss.leadEmail;
		}else if(structkeyexists(form, 'inquiries_email')){
			rs.leadEmail=form.inquiries_email;	
		}else{
			rs.leadEmail="";
		}
		rs.bcc="";
		m='force assign to #rs.assignEmail#<br />';
		arrayAppend(arrDebug, m);
		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo(m);
		}
	}else{
		rs=application.zcore.functions.zFindLeadRouteForInquiryId(rs);
		if(rs.success EQ false){
			rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
			rs.user_id=0;
			rs.user_id_siteIDType=0; 
			if(rs.assignEmail EQ ""){
				rs.assignEmail=request.zos.developerEmailTo;
			}
			m='failed to find lead route | assigning to #rs.assignEmail#<br />';
			arrayAppend(arrDebug, m);
			if(structkeyexists(request.zos, 'debugleadrouting')){
				echo(m);
			}
			//writeoutput(rs.errorMessage);
		}else{
			rs=application.zcore.functions.zProcessLeadRoute(rs);
		}
		if(structkeyexists(rs, 'arrDebug')){
			for(i=1;i LTE arraylen(rs.arrDebug);i++){
				arrayAppend(arrDebug, rs.arrDebug[i]);
			}
		}
	}
	if(not structkeyexists(rs, 'bcc')){
		rs.cc="";
	}
	if(not structkeyexists(rs, 'bcc')){
		rs.bcc="";
	}
	if(rs.user_id EQ 0){
		 db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
		SET inquiries_assign_email=#db.param(rs.assignemail)#,
		inquiries_status_id=#db.param(2)#,
		office_id=#db.param(application.zcore.functions.zso(rs, 'office_id', true))#,
		inquiries_updated_datetime=#db.param(request.zos.mysqlnow)#  
		WHERE inquiries_id=#db.param(arguments.ss.inquiries_id)# and 
		inquiries_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		db.execute("q");
	}else{
		db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
		SET user_id=#db.param(rs.user_id)#, 
		inquiries_status_id=#db.param(2)#,
		office_id=#db.param(application.zcore.functions.zso(rs, 'office_id', true))#,
		user_id_siteIDType=#db.param(rs.user_id_siteIDType)#,
		inquiries_updated_datetime=#db.param(request.zos.mysqlnow)#  
		WHERE inquiries_id=#db.param(arguments.ss.inquiries_id)# and 
		inquiries_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		db.execute("q"); 
	} 
	if(structkeyexists(request.zos, 'debugleadrouting')){
		writedump(rs);
		if(not arguments.ss.disableDebugAbort){
			echo("Aborted before sending lead email because debug lead routing is enabled.");
			abort;
		}
	}
	rs.office_id=application.zcore.functions.zso(rs, 'office_id', true);
	form.inquiries_id=inquiries_id;
	if(not structkeyexists(request.zos, 'debugleadrouting')){
  
		contactCom=createobject("component", "zcorerootmapping.com.app.contact");
		ts=contactCom.getDefaultMessageConfig(); 
		ts.contact_id=application.zcore.functions.zso(form, 'contact_id', true);
		//ts.debug=false;
		ts.inquiries_id=form.inquiries_id;
		if(rs.user_id EQ 0){ 
			assignEmail=rs.assignEmail;
			assignName="";
			ts.jsonStruct.subject="Lead ###form.inquiries_id# assigned to #rs.assignEmail# on #request.zos.globals.shortDomain#";
		}else{
			userStruct=application.zcore.user.getUserById(rs.user_id, application.zcore.functions.zGetSiteIdFromSiteIdType(rs.user_id_siteIDType));
			assignName="#userStruct.user_first_name# #userStruct.user_last_name#";
			assignEmail=userStruct.user_username;
			if(userStruct.user_first_name&userStruct.user_last_name EQ ""){
				name=userStruct.user_username;
			}else{
				name=userStruct.user_first_name&' '&userStruct.user_last_name;
			}
			ts.jsonStruct.subject="Lead ###form.inquiries_id# assigned to #name# on #request.zos.globals.shortDomain#";
		}
		if(application.zcore.functions.zvar("enablePlusEmailRouting", request.zos.globals.id, 0) EQ 1){
			// this should be happening on live server when the new lead interface is all done
			request.noleadsystemlinks=true;
		}
		savecontent variable="htmlWeb"{ 
			echo('<p>&nbsp;</p>');
		}
		savecontent variable="emailHTML"{
			iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		    iemailCom.getEmailTemplate("", false);
		} 

		ts.jsonStruct.html=emailHTML;
		ts.jsonStruct.htmlWeb=htmlWeb;
		ts.messageStruct.site_id=request.zos.globals.id;
		ts.filterContacts.managers=true; 
		ts.privateMessage=true;
		ts.enableCopyToSelf=true;

		ts.jsonStruct.from={
			name:assignName,
			email:assignEmail
		};
		ts.jsonStruct.to=[{
			name:assignName,
			email:assignEmail,
			plusId:"",
			originalEmail:assignEmail
		}];
 		ts.emailFileAttachments=arguments.ss.arrAttachments;

		// slightly inaccurate since it doesn't include all fields and attachment sizes
		ts.jsonStruct.size=len(ts.jsonStruct.subject&ts.jsonStruct.html);  
		//ts.debug=true;
		if(rs.office_id NEQ "0"){
			ts.filterContacts.offices=[rs.office_id];
		}
		if(structkeyexists(request.zos, 'manageLeadGroupIdList')){
			ts.filterContacts.userGroupIds=listToArray(request.zos.manageLeadGroupIdList, ",");
		}  
		//writedump(ts);    abort; 
	  
		rs=contactCom.processMessage(ts);   
		/*
		mail spoolenable="no" to="#rs.assignEmail#" cc="#rs.cc#" bcc="#rs.bcc#" from="#request.fromemail#" replyto="#rs.leademail#" subject="#arguments.ss.subject#" type="html"{
			for(n=1;n<=arrayLen(arguments.ss.arrAttachments);n++){
				mailparam file="#arguments.ss.arrAttachments[n]#" disposition="attachment";
			}
			iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		    iemailCom.getEmailTemplate("", true);
		}*/
	}else{
		echo("Would send email to #rs.assignEmail#<br />");
	}
	rs2.arrDebug=arrDebug;
	rs2.success=true;
	if(structkeyexists(request.zos.debugLeadRoutingSiteIdStruct, request.zos.globals.id)){
		savecontent variable="debugout"{
			echo('<html><body>');
			writedump(rs2, true, 'simple');
			writedump(request.zos.cgi, true, 'simple');
			echo('</body></html>');
		}
		mail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmaiLFrom#" subject="Assign debugging info for #request.zos.globals.shortDomain#" type="html"{
			echo(replace(debugout, '>', '>'&chr(10), "all"));
		}
	}
	return rs2;
	</cfscript>
</cffunction>

<!--- 
ts=structnew();
ts.leadEmail="email@address.com";
rs=application.zcore.functions.zGetNewMemberLeadRouteStruct(ts);
 --->
<cffunction name="zGetNewMemberLeadRouteStruct" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var rs=structnew();
	var ts=structnew();
	var i=0;
	var c=0;
	arguments.ss.assignUserId=0;
	arguments.ss.autoAssignMember=false;
	arguments.ss.autoAssignOffice=false;
	arguments.ss.routeIndex=0;
	if(structkeyexists(application.sitestruct[request.zos.globals.id].leadRoutingStruct, 'arrData')){
		for(i=1;i LTE arraylen(application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData);i++){
			c=application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData[i];
			if(c.data.inquiries_type_name EQ "New User Registration" and c.data.inquiries_type_id_siteIDType EQ 0){
				arguments.ss.routeIndex=i;
				break;
			}
		}
	}
	return application.zcore.functions.zProcessLeadRoute(arguments.ss);
	</cfscript>
</cffunction>



<cffunction name="zGetLeadRouteForInquiriesTypeId" localmode="modern" output="no" returntype="any">
	<cfargument name="toEmailAddress" type="string" required="yes">
	<cfargument name="inquiries_type_id" type="numeric" required="yes">
	<cfargument name="inquiries_type_id_siteIDType" type="numeric" required="yes">
	<cfscript>
	var rs=structnew();
	var ts=structnew();
	var i=0;
	var c=0;
	arguments.ss.assignUserId=0;
	arguments.ss.autoAssignMember=false;
	arguments.ss.autoAssignOffice=false;
	arguments.ss.routeIndex=0;
	arguments.ss.leadEmail=arguments.toEmailAddress;
	if(structkeyexists(application.sitestruct[request.zos.globals.id].leadRoutingStruct, 'arrData')){
		for(i=1;i LTE arraylen(application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData);i++){
			c=application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData[i];
			if(c.data.inquiries_type_id EQ arguments.inquiries_type_id and c.data.inquiries_type_id_siteIDType EQ arguments.inquiries_type_id_siteIDType){
				arguments.ss.routeIndex=i;
				break;
			}
		}
		if(arguments.ss.routeIndex EQ 0){
			for(i=1;i LTE arraylen(application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData);i++){
				c=application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData[i];
				if(c.data.inquiries_type_id EQ "0" or c.data.inquiries_type_id EQ ""){
					arguments.ss.routeIndex=i;
					break;
				}
			}
		}
	}
	return application.zcore.functions.zProcessLeadRoute(arguments.ss);
	</cfscript>
</cffunction>

<cffunction name="zCompareListingWithSavedSearch" localmode="modern" output="no" returntype="any">
	see if listing.listing_id fits within criteria in mls_saved_search.mls_saved_search_id
</cffunction>

<cffunction name="zFindLeadRouteForInquiryId" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var local=structnew();
	var rs=structnew();
	var i=0;
	var c=0;
	var qI2=0;
	var t9=0;
	var tempCount=0;
	var r9=0;
	var qmember=0;
	var qi=0;
	var db=request.zos.queryObject;
	rs.inquiries_id = arguments.ss.inquiries_id;
	rs.success=true;
	rs.routeIndex=0;
	rs.assignUserId=0;
	rs.autoAssignMember=false;
	rs.autoAssignOffice=false;
	rs.arrDebug=[];
	if(structkeyexists(form, 'inquiries_email')){
		rs.leadEmail=form.inquiries_email;	
	}
	db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE inquiries_id = #db.param(rs.inquiries_id)# and 
	inquiries_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qI=db.execute("qI"); 
	if(qI.recordcount EQ 0){
		m='inquiry doesn''t exist<br />';
		arrayAppend(rs.arrDebug, m);
		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo(m);
		}
		rs.errorMessage="Inquiry doesn't exist.";
		rs.success=false;
		return rs;
	}
	//rs.qInquiry=qI;
	rs.leadEmail=qI.inquiries_email;
	//application.zcore.functions.zdump(qi);

	/*
	// i removed the reassign to same person feature because it interferes with the bcc and other features maybe.
	if(qI.inquiries_email NEQ ""){
		// auto-assign to same member if they are still active and the last inquiry was within 6 months.
		 db.sql="select user.user_username, user.site_id, user.user_id 
		 from (#db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
		 #db.table("user", request.zos.zcoreDatasource)# user) 
		WHERE user.user_id = inquiries.user_id and 
		user.user_active= #db.param(1)# and 
		user_deleted = #db.param(0)# and 
		inquiries_deleted = #db.param(0)# and
		inquiries_email = #db.param(qI.inquiries_email)# and 
		inquiries_id <> #db.param(rs.inquiries_id)# and 
		inquiries_datetime >=#db.param(dateformat(dateadd("m",-6,now()),"yyyy-mm-dd")&" 00:00:00")# and 
		inquiries.site_id = #db.param(request.zos.globals.id)#  and 
		user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# 
		ORDER BY inquiries_datetime DESC 
		LIMIT #db.param(0)#,#db.param(1)# ";
		qI2=db.execute("qI2");
		if(qI2.recordcount NEQ 0){
			rs.assignEmail=qI2.user_username;
			rs.assignUserId=qI2.user_id;
			rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qI2.site_id);

			m='reassign lead to same member: #rs.assignEmail#<br />';
			arrayAppend(rs.arrDebug, m);
			if(structkeyexists(request.zos, 'debugleadrouting')){
				echo(m);
			}
			return rs;
		}
	} */
	if(structkeyexists(application.sitestruct[request.zos.globals.id].leadRoutingStruct, 'arrData')){
		for(i=1;i LTE arraylen(application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData);i++){
			c=application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData[i];
			//writeoutput('loop ##'&i&'|'&c.data.inquiries_type_id&'|'&qI.inquiries_type_id&'<br />');
			if(qI.inquiries_type_id_siteIDType EQ c.data.inquiries_type_id_siteIDType and qI.inquiries_type_id EQ c.data.inquiries_type_id){
				// ok
			}else if(c.data.inquiries_type_id NEQ "" and c.data.inquiries_type_id NEQ "0"){
				// didn't matched lead type, so skip this lead route.
				continue;
			}
			if(application.zcore.app.siteHasApp("listing")){
				if(c.data.inquiries_routing_search_mls EQ 1){
					if(ql.property_id NEQ ""){
						t9=structnew();
						//request.zdebugMlsSearch=true;
						t9.returnQueryOnly=true;
						t9.extraCriteria=structnew();
						t9.extraCriteria.arrMLSPID=listtoarray(qI.property_id,",");
						tempCount=arraylen(t9.extraCriteria.arrMLSPID);
						r9=request.zos.listing.functions.zMLSSearchOptionsDisplay(c.data.mls_saved_search_id,t9);
						if(r9.count NEQ 0 and r9.count EQ tempCount){
							// lead's listings matched saved search.
							if(c.data.inquiries_routing_member_auto_assign EQ 1 or c.data.inquiries_routing_office_auto_assign EQ 1){
								// compare agent name with member names
								db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user 
								WHERE member_mlsagentid = #db.param(r9.query.listing_agent[1])# and 
								user.site_id = #db.param(request.zos.globals.id)# and 
								user_deleted = #db.param(0)# and
								user_active=#db.param('1')#";
								qMember=db.execute("qMember"); 
								if(qMember.recordcount NEQ 0){
									// override to use member auto-assign feature
									if(c.data.inquiries_routing_office_auto_assign EQ 1){
										rs.autoAssignOffice=true;
										// member or email will be determined by route type id
										m='autoAssignOffice<br />';
										arrayAppend(rs.arrDebug, m);
										if(structkeyexists(request.zos, 'debugleadrouting')){
											echo(m);
										}
									}else{
										rs.autoAssignMember=true;
										if(qMember.user_alternate_email NEQ ""){
											rs.cc=qMember.user_alternate_email;
										}
										rs.assignEmail=qMember.user_username;
										rs.assignUserId=qMember.user_id; // this will fail until implemented.
										rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qMember.site_id);
										m='autoAssignMember: #rs.assignEmail#<br />';
										arrayAppend(rs.arrDebug, m);
										if(structkeyexists(request.zos, 'debugleadrouting')){
											echo(m);
										}
									}
									rs.routeIndex=i;
									return;
								}
							}
							// apply the normal selected inquiries_routing_type_id condition
							rs.routeIndex=i;
							m='applied rs.routeIndex=#i# | 1<br />';
							arrayAppend(rs.arrDebug, m);
							if(structkeyexists(request.zos, 'debugleadrouting')){
								echo(m);
							}
							return;
						}else{
							// one or more listings was not an exact match.	so this route doesn't apply.
							continue;
						}
					}else{
						// not a property inquiry, skip lead route.
						continue;	
					}
				}
			}
			
			// this route is the right one
			m='applied rs.routeIndex=#i# | 2<br />';
			arrayAppend(rs.arrDebug, m);
			if(structkeyexists(request.zos, 'debugleadrouting')){
				echo(m);
			}
			rs.routeIndex=i;
			return rs;
		}
	}
	rs.success=true;
	return rs;
	</cfscript>
</cffunction>

<!--- 
<cffunction name="zProcessLeadRouteForInquiryId" localmode="modern" output="no" returntype="struct">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var local=structnew();
	var rs=structnew();
	var db=request.zos.queryObject;
	var qI=arguments.ss.qInquiry;
	var qUser=0;
	var arrCCType=0;
	var routingCCStruct=structnew();
	var qAssignUser=0;
	var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	var c=0;
	rs.inquiries_id = arguments.ss.inquiries_id;
	rs.inquiriesEmail=qI.inquiries_email;
	rs.user_id=0;
	rs.cc="";
	rs.assignEmail="";
	if(arguments.ss.routeIndex EQ 0 or arraylen(application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData) LT arguments.ss.routeIndex){
		c=structnew();
		c.data=structnew();
		c.data.inquiries_routing_autoresponder_enabled=1;
		c.data.inquiries_routing_autoresponder_html="";
		c.data.inquiries_routing_autoresponder_text="";
		c.data.inquiries_routing_assign_to_email="";
		c.data.inquiries_routing_cc0="";
		c.data.inquiries_routing_type_id=0;
		
	}else{
		c=application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData[arguments.ss.routeIndex];	
	}
	
	
	// detect if autoresponder was sent yet by querying user table
	 db.sql="select user_id from #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_username = #db.param(qI.inquiries_email)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	user_deleted = #db.param(0)#";
	qUser=db.execute("qUser");
	if(qUser.recordcount EQ 0){
		if(c.data.inquiries_routing_autoresponder_enabled EQ 1 and (c.data.inquiries_routing_autoresponder_html NEQ "" or c.data.inquiries_routing_autoresponder_text NEQ "")){
			// setup custom confirm opt-in autoresponder
			/*			
			inquiries_routing_autoresponder_html
			inquiries_routing_autoresponder_text
			*/
		}else{
			// setup default confirm opt-in alert assuming site has this option enabled.
		}
		// create new user for the lead email address
		/*
		ts=application.zcore.functions.zUserMapFormFields(structnew());
		ts.site_id = request.zos.globals.id;
		ts.autoLogin=true;
		ts.createPassword=true;
		userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
		ts.user_group_id = userGroupCom.getGroupId('user',request.zos.globals.id);
		if(structkeyexists(request,'userOptOut')){
			ts.user_pref_list=0;
		}
		//ts.user_pref_html=1;
		// not all forms require an email address
		if(structkeyexists(ts,'user_username')){
			userAdminCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_admin");
			user_id = userAdminCom.add(ts);
		}
		*/
	}
	
	if(arguments.ss.assignUserId NEQ 0){
		// force assignment and return with no logic
		rs.assignEmail=arguments.ss.assignEmail;
		rs.user_id_siteIDType=arguments.ss.user_id_siteIDType;
		rs.user_id=arguments.ss.assignUserId;
		return rs;
	}
	
	if(c.data.inquiries_routing_type_id EQ 0){
		// assign to zofficeemail
		db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		user_active= #db.param(1)# and 
		user_deleted = #db.param(0)# and
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
		user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))# 
		 LIMIT #db.param(0)#,#db.param(1)#";
		qAssignUser=db.execute("qAssignUser"); 
		if(qAssignUser.recordcount EQ 0){
			// assign to default email
			rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
		}else{
			// assign to default user instead
			rs.assignEmail=qAssignUser.user_username;
			rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
			rs.user_id=qAssignUser.user_id;
		}
	}else if(c.data.inquiries_routing_type_id EQ 1){
		// round robin from member table
		 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		user_active= #db.param(1)# and 
		user_deleted = #db.param(0)# and 
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# 	
		ORDER BY user_next_lead DESC, user_id asc 
		LIMIT #db.param(0)#,#db.param(1)#";
		qAssignUser=db.execute("qAssignUser");
		if(qAssignUser.recordcount EQ 0 or application.zcore.functions.zEmailValidate(qAssignUser.user_email) EQ false){
			 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			user_active= #db.param(1)# and 
			user_deleted = #db.param(0)# and
			user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
			user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))# 	
			ORDER BY user_next_lead DESC, user_id asc 
			LIMIT #db.param(0)#,#db.param(1)#";
			qAssignUser=db.execute("qAssignUser");
			if(qAssignUser.recordcount EQ 0){
				db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				user_active= #db.param(1)# and 
				user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
				user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))# 
				 LIMIT #db.param(0)#,#db.param(1)#";
				qAssignUser=db.execute("qAssignUser"); 
				if(qAssignUser.recordcount EQ 0){
					// assign to default email
					rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
				}else{
					// assign to default user instead
					rs.assignEmail=qAssignUser.user_username;
					rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
					rs.user_id=qAssignUser.user_id;
				}
			}else{
				rs.assignEmail=qAssignUser.user_username;
				rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
				rs.user_id=qAssignUser.user_id;
			}
		}else{
			rs.assignEmail=qAssignUser.user_username;
			rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
			rs.user_id=qAssignUser.user_id;
		}
		// round robin doesn't work in user is in parent site. should it?
		db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
		SET user_next_lead = user_next_lead+1,
		user_updated_datetime=#db.param(request.zos.mysqlnow)#  
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		user_active= #db.param(1)# and 
		user_deleted = #db.param(0)# and
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# ";
		db.execute("q"); 
		db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
		SET user_next_lead = #db.param(0)#,
		user_updated_datetime=#db.param(request.zos.mysqlnow)#  
		WHERE user_id = #db.param(qAssignUser.user_id)# and 
		user_deleted = #db.param(0)# and 
		site_id = #db.param(qAssignUser.site_id)#";
		db.execute("q"); 
	}else if(c.data.inquiries_routing_type_id EQ 2){
		// assign to user id
		db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		user_active= #db.param(1)# and 
		user_deleted = #db.param(0)# and 
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
		user_id =#db.param(c.data.inquiries_routing_assign_to_user_id)# 	
		ORDER BY user_next_lead DESC, user_id asc 
		LIMIT #db.param(0)#,#db.param(1)#";
		qAssignUser=db.execute("qAssignUser"); 
		if(qAssignUser.recordcount EQ 0 or application.zcore.functions.zEmailValidate(qAssignUser.user_email) EQ false){
			db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			user_active= #db.param(1)# and 
			user_deleted = #db.param(0)# and
			user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
			user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))# 	
			ORDER BY user_next_lead DESC, user_id asc 
			LIMIT #db.param(0)#,#db.param(1)#";
			qAssignUser=db.execute("qAssignUser"); 
			if(qAssignUser.recordcount EQ 0){
				rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
			}else{
				rs.assignEmail=qAssignUser.user_username;
				rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
				rs.user_id=qAssignUser.user_id;
			}
		}else{
			rs.assignEmail=qAssignUser.user_username;
			rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
			rs.user_id=qAssignUser.user_id;
		}
	}else if(c.data.inquiries_routing_type_id EQ 3){
		// assign to email address
		rs.assignEmail=c.data.inquiries_routing_assign_to_email;
	}else{
		application.zcore.template.fail("Invalid inquiries_routing_type_id");	
	}
	if(rs.assignEmail EQ ""){
		rs.assignEmail=request.zos.developeremailto;
	}
	
	if(c.data.inquiries_routing_cc0 NEQ ""){
		rs.bcc=c.data.inquiries_routing_cc0;	
	}
	
	return rs;
	</cfscript>
</cffunction>
 --->


<cffunction name="zProcessLeadRoute" localmode="modern" output="yes" returntype="struct">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var local=structnew();
	var rs=structnew();
	var qUser=0;
	var arrCCType=0;
	var routingCCStruct=structnew();
	var qAssignUser=0;
	var db=request.zos.queryObject;
	var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	var c=0;
	rs.leademail=arguments.ss.leademail;
	rs.user_id=0;
	rs.bcc="";
	rs.cc="";
	rs.arrDebug=[];
	rs.assignEmail="";

	if(arguments.ss.routeIndex EQ 0 or arraylen(application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData) LT arguments.ss.routeIndex){
		c=structnew();
		c.data=structnew();
		c.data.inquiries_routing_autoresponder_enabled=1;
		c.data.inquiries_routing_autoresponder_html="";
		c.data.inquiries_routing_autoresponder_text="";
		c.data.inquiries_routing_assign_to_email="";
		c.data.inquiries_routing_cc0="";
		c.data.inquiries_routing_type_id=0;
		
	}else{
		c=application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData[arguments.ss.routeIndex];	
	}
	if(structkeyexists(request.zos, 'debugleadrouting')){
		echo('application leadRoutingStruct count: '&arraylen(application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData)&' LT routeIndex:'&arguments.ss.routeIndex&'<br>');
		writedump(c);
	}
	
	
	// detect if autoresponder was sent yet by querying user table
	 db.sql="select user_id from #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_username = #db.param(arguments.ss.leadEmail)# and 
	user_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qUser=db.execute("qUser");
	if(qUser.recordcount EQ 0){
		if(c.data.inquiries_routing_autoresponder_enabled EQ 1 and (c.data.inquiries_routing_autoresponder_html NEQ "" or c.data.inquiries_routing_autoresponder_text NEQ "")){
			// setup custom confirm opt-in autoresponder
			/*			
			inquiries_routing_autoresponder_html
			inquiries_routing_autoresponder_text
			*/
		}else{
			// setup default confirm opt-in alert assuming site has this option enabled.
		}
		// create new user for the lead email address
		/*
		ts=application.zcore.functions.zUserMapFormFields(structnew());
		ts.site_id = request.zos.globals.id;
		ts.autoLogin=true;
		ts.createPassword=true;
		userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
		ts.user_group_id = userGroupCom.getGroupId('user',request.zos.globals.id);
		if(structkeyexists(request,'userOptOut')){
			ts.user_pref_list=0;
		}
		//ts.user_pref_html=1;
		// not all forms require an email address
		if(structkeyexists(ts,'user_username')){
			userAdminCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_admin");
			user_id = userAdminCom.add(ts);
		}
		*/
	}
	

	if(c.data.inquiries_routing_cc0 NEQ ""){
		rs.bcc=c.data.inquiries_routing_cc0;	
	}

	if(arguments.ss.assignUserId NEQ 0){
		// force assignment and return with no logic
		rs.assignEmail=arguments.ss.assignEmail;
		rs.user_id_siteIDType=arguments.ss.user_id_siteIDType;
		rs.user_id=arguments.ss.assignUserId;
		m='process assigned lead to #rs.assignEmail#<br />';
		arrayAppend(rs.arrDebug, m);
		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo(m);
		}
		return rs;
	}
	
	if(structkeyexists(request.zos, 'debugleadrouting')){ 
		echo('showing the type inquiries_routing_type_id = #c.data.inquiries_routing_type_id#<br />');
	}
	if(c.data.inquiries_routing_type_id EQ 0){
		// assign to zofficeemail
		 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		user_active= #db.param(1)# and 
		user_deleted = #db.param(0)# and 
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
		user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))#  
		LIMIT #db.param(0)#,#db.param(1)#";
		qAssignUser=db.execute("qAssignUser");
		if(qAssignUser.recordcount EQ 0){
			// assign to default email
			rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
			m='process assigned lead to zofficeemail: #rs.assignEmail#<br />';
			arrayAppend(rs.arrDebug, m);
			if(structkeyexists(request.zos, 'debugleadrouting')){
				echo(m);
			}
		}else{
			// assign to default user instead
			rs.assignEmail=qAssignUser.user_username;
			if(qAssignUser.user_alternate_email NEQ ""){
				rs.cc=qAssignUser.user_alternate_email;
			}
			rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
			rs.user_id=qAssignUser.user_id;
			m='process assigned lead to zofficeemail user_id: #qAssignUser.user_id# site_id: #qAssignUser.site_id# | #rs.assignEmail#<br />';
			arrayAppend(rs.arrDebug, m);
			if(structkeyexists(request.zos, 'debugleadrouting')){
				echo(m);
			}
		}
	}else if(c.data.inquiries_routing_type_id EQ 1){
		// round robin from member table
		db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		user_active= #db.param(1)# and 
		user_deleted = #db.param(0)# and
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# 	
		ORDER BY user_next_lead DESC, user_id asc LIMIT #db.param(0)#,#db.param(1)#";
		qAssignUser=db.execute("qAssignUser"); 
		if(qAssignUser.recordcount EQ 0 or application.zcore.functions.zEmailValidate(qAssignUser.user_email) EQ false){
			db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			user_active= #db.param(1)# and 
			user_deleted = #db.param(0)# and 
			user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
			user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))# 	
			ORDER BY user_next_lead DESC, user_id asc LIMIT #db.param(0)#,#db.param(1)#";
			qAssignUser=db.execute("qAssignUser"); 
			if(qAssignUser.recordcount EQ 0){
				db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				user_active= #db.param(1)# and 
				user_deleted = #db.param(0)# and
				user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
				user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))#  
				LIMIT #db.param(0)#,#db.param(1)#";
				qAssignUser=db.execute("qAssignUser"); 
				if(qAssignUser.recordcount EQ 0){
					// assign to default email
					rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
					m='process assigned lead to default zofficeemail #rs.assignEmail#<br />';
					arrayAppend(rs.arrDebug, m);
					if(structkeyexists(request.zos, 'debugleadrouting')){
						echo(m);
					}
				}else{
					// assign to default user instead
					rs.assignEmail=qAssignUser.user_username;
					if(qAssignUser.user_alternate_email NEQ ""){
						rs.cc=qAssignUser.user_alternate_email;
					}
					rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
					rs.user_id=qAssignUser.user_id;
					m='process assigned lead to default user_id: #rs.user_id# | site_id: #qAssignUser.site_id# | assignEmail: #rs.assignEmail#<br />';
					arrayAppend(rs.arrDebug, m);
					if(structkeyexists(request.zos, 'debugleadrouting')){
						echo(m);
					}
				}
			}else{
				rs.assignEmail=qAssignUser.user_username;
				if(qAssignUser.user_alternate_email NEQ ""){
					rs.cc=qAssignUser.user_alternate_email;
				}
				rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
				rs.user_id=qAssignUser.user_id;
				m='process assigned lead to next user in rotation: user_id: #rs.user_id# | site_id: #qAssignUser.site_id# | #rs.assignEmail#<br />';
				arrayAppend(rs.arrDebug, m);
				if(structkeyexists(request.zos, 'debugleadrouting')){
					echo(m);
				}
			}
		}else{
			rs.assignEmail=qAssignUser.user_username;
			if(qAssignUser.user_alternate_email NEQ ""){
				rs.cc=qAssignUser.user_alternate_email;
			}
			rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
			rs.user_id=qAssignUser.user_id;
		}
		// round robin doesn't work in user is in parent site. should it?
		 db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
		 SET user_next_lead = user_next_lead+#db.param(1)#,
		 user_updated_datetime=#db.param(request.zos.mysqlnow)#  
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		user_active= #db.param(1)# and 
		user_deleted = #db.param(0)# and
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# ";
		db.execute("q");
		 db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
		 SET user_next_lead = #db.param(0)#, 
		 user_updated_datetime=#db.param(request.zos.mysqlnow)#  
		WHERE user_id = #db.param(qAssignUser.user_id)# and 
		user_deleted = #db.param(0)# and
		site_id = #db.param(qAssignUser.site_id)#";
		db.execute("q");
	}else if(c.data.inquiries_routing_type_id EQ 2){
		// assign to user id
		 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		user_active= #db.param(1)# and 
		user_deleted = #db.param(0)# and
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
		user_id =#db.param(c.data.inquiries_routing_assign_to_user_id)# 	
		ORDER BY user_next_lead DESC, user_id asc LIMIT #db.param(0)#,#db.param(1)#";
		qAssignUser=db.execute("qAssignUser");
		if(qAssignUser.recordcount EQ 0 or application.zcore.functions.zEmailValidate(qAssignUser.user_email) EQ false){
			 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			user_active= #db.param(1)# and 
			user_deleted = #db.param(0)# and
			user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
			user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))# 	
			ORDER BY user_next_lead DESC, user_id asc 
			LIMIT #db.param(0)#,#db.param(1)#";
			qAssignUser=db.execute("qAssignUser");
			if(qAssignUser.recordcount EQ 0){
				rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
				m='process assigned lead to default #rs.assignEmail#<br />';
				arrayAppend(rs.arrDebug, m);
				if(structkeyexists(request.zos, 'debugleadrouting')){
					echo(m);
				}
			}else{
				rs.assignEmail=qAssignUser.user_username;
				if(qAssignUser.user_alternate_email NEQ ""){
					rs.cc=qAssignUser.user_alternate_email;
				}
				rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
				rs.user_id=qAssignUser.user_id;
				m='process assigned lead to default user_id: #rs.user_id# | site_id: #qAssignUser.site_id# | assignEmail: #rs.assignEmail#<br />';
				arrayAppend(rs.arrDebug, m);
				if(structkeyexists(request.zos, 'debugleadrouting')){
					echo(m);
				}
			}
		}else{
			rs.assignEmail=qAssignUser.user_username;
			if(qAssignUser.user_alternate_email NEQ ""){
				rs.cc=qAssignUser.user_alternate_email;
			}
			rs.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(qAssignUser.site_id);
			rs.user_id=qAssignUser.user_id;
			m='process assigned lead to next user in rotation: user_id: #rs.user_id# | site_id: #qAssignUser.site_id# | assignEmail: #rs.assignEmail#<br />';
			arrayAppend(rs.arrDebug, m);
			if(structkeyexists(request.zos, 'debugleadrouting')){
				echo(m);
			}
		}
		
	}else if(c.data.inquiries_routing_type_id EQ 3){
		// assign to email address
		rs.assignEmail=c.data.inquiries_routing_assign_to_email;
		m='process assigned lead to specific email | assignEmail: #rs.assignEmail#<br />';
		arrayAppend(rs.arrDebug, m);
		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo(m);
		}
	}else{
		application.zcore.template.fail("Invalid inquiries_routing_type_id");	
	}
	if(rs.assignEmail EQ ""){
		rs.assignEmail=request.zos.developeremailto;
		m='process failed to assign lead. Assigning to developer: #rs.assignEmail#<br />';
		arrayAppend(rs.arrDebug, m);
		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo(m);
		}
	}
	
	
	return rs;
	</cfscript>
</cffunction>


<!--- 
all status change events:

ts=structnew();
ts.inquiries_id=inquiries_id;
ts.inquiries_log_description="Lead assigned to user id###user_id# #user_first_name# #user_last_name# (#user_username#)";
application.zcore.functions.zLeadRecordLog(ts);

ts=structnew();
ts.inquiries_id=inquiries_id;
ts.inquiries_log_description="Lead reassigned to user id###user_id# #user_first_name# #user_last_name# (#user_username#)";
application.zcore.functions.zLeadRecordLog(ts);


ts=structnew();
ts.inquiries_id=inquiries_id;
ts.inquiries_log_description="Lead edited by user id###user_id# #user_first_name# #user_last_name# (#user_username#)";
application.zcore.functions.zLeadRecordLog(ts);


ts=structnew();
ts.inquiries_id=inquiries_id;
ts.inquiries_log_description="Lead replied to by user id###user_id# #user_first_name# #user_last_name# (#user_username#)";
application.zcore.functions.zLeadRecordLog(ts);



ts=structnew();
ts.inquiries_id=inquiries_id;
ts.inquiries_log_description="Lead assigned to external E-Mail Address: #assignEmail#";
application.zcore.functions.zLeadRecordLog(ts);


ts=structnew();
ts.inquiries_id=inquiries_id;
ts.inquiries_log_description="1st follow-up reminder notice sent";
application.zcore.functions.zLeadRecordLog(ts);


ts=structnew();
ts.inquiries_id=inquiries_id;
ts.inquiries_log_description="Lead note added by user id###user_id# #user_first_name# #user_last_name# (#user_username#)";
application.zcore.functions.zLeadRecordLog(ts);

ts=structnew();
ts.inquiries_id=inquiries_id;
ts.inquiries_log_description="Lead closed by user id###user_id# #user_first_name# #user_last_name# (#user_username#)";
application.zcore.functions.zLeadRecordLog(ts);



ts=structnew();
ts.inquiries_id=0;
ts.inquiries_log_description="";
application.zcore.functions.zLeadRecordLog(ts);
 --->
<cffunction name="zLeadRecordLog" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=structnew();
	ts.table="inquiries_log";
	ts.datasource="#request.zos.zcoreDatasource#";
	ts.struct=structnew();
	ts.site_id=request.zos.globals.id;
	structappend(ts.struct,arguments.ss,true);
	ts.struct.inquiries_log_datetime=request.zos.mysqlnow;
	application.zcore.functions.zInsert(ts);
	</cfscript>
</cffunction>

<cffunction name="zLeadRouteStatusChange" localmode="modern" output="no" returntype="any">
	<cfscript>
	var rs=structnew();
	application.zcore.template.fail("zLeadRouteStatusChange() is not complete");
	// check if current inquiry is setup to send cc email regarding lead changes.
	
	// only do these on a scheduled task.
	if(structkeyexists(routingCCStruct, 2)){
		// On other status changes (i.e. edits/notes/replies)<br />
		rs.subjectPrefix="Lead status change: ";
		rs.bcc=c.inquiries_routing_cc;
	}
	</cfscript>
</cffunction>

<cffunction name="zLeadRouteReminderScheduledTask" localmode="modern" output="no" returntype="any">
    <cfscript>
	var local=structnew();
	var c=0;
	var qRoute=0;
	var qI=0;
	var t9=0;
	var rs=0;
	var totalReminders=0;
	var reminderPrefix=0;
	var sendReminder=0;
	var finalReminder=0;
	var qAssignUser=0;
	var db=request.zos.queryObject;
	var curDate=0;
	var hoursSinceUpdate=0;
	var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	// figure out a way to only query leads that need to have reminder logic or cc for inactivity
	 db.sql="select count(inquiries_routing_id) c 
	 from #db.table("inquiries_routing", request.zos.zcoreDatasource)# inquiries_routing 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	inquiries_routing_deleted = #db.param(0)# ";
	qRoute=db.execute("qRoute");
	if(qRoute.recordcount EQ 0 or qRoute.c EQ 0){
		return; // no routing reminders needed for this web site.
	}
	
	// only future inquiries that aren't closed
	db.sql="SELECT * FROM #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	inquiries_status_id NOT IN (#db.param('4')#,#db.param('5')#,#db.param('7')#) AND 
	user_id <> #db.param('0')# and 
	inquiries_deleted = #db.param(0)# and
	inquiries_datetime > #db.param('2010-02-08 14:00:00')# ";
	qI=db.execute("qI"); 
	</cfscript><cfloop query="qI"><cfscript>
	
	// find lead route
	t9=structnew();
	t9.inquiries_id=inquiries_id;
	rs=application.zcore.functions.zFindLeadRouteForInquiryId(t9);
	if(rs.routeIndex NEQ 0){
		/*
		rs.inquiries_id = arguments.ss.inquiries_id;
		rs.success=true;
		rs.assignUserId=0;
		rs.autoAssignMember=false;
		rs.autoAssignOffice=false;
		rs.routeIndex=0;
		*/
		c=application.sitestruct[request.zos.globals.id].leadRoutingStruct.arrData[rs.routeIndex];
		curDate=parsedatetime(dateformat(inquiries_updated_datetime,"yyyy-mm-dd")&" "&timeformat(inquiries_updated_datetime,"HH:mm:ss"));
		hoursSinceUpdate=(datediff("m",curDate,now()))/60;
		
		if(c.inquiries_routing_cc_inactive_hours NEQ 0 and structkeyexists(routingCCStruct, 3) and hoursSinceUpdate GTE c.inquiries_routing_cc_inactive_hours){
			// inactive for hours
			rs.subjectPrefix="Inactive for #c.inquiries_routing_cc_inactive_hours# hours: ";
			rs.bcc=c.inquiries_routing_cc;
		}
		
		if(user_id NEQ 0){
			if(c.inquiries_routing_reminder_enabled EQ 1){
				totalReminders=0;
				sendReminder=false;
				finalReminder=false;
				reminderprefix="";
				if(c.inquiries_routing_reminder_hours1 NEQ 0 and hoursSinceUpdate GTE c.inquiries_routing_reminder_hours1){
					totalReminders++;
					if(inquiries_reminders_sent LT totalReminders){
						sendReminder=true;
						reminderprefix="1st follow-up reminder: ";
					}
				}
				if(c.inquiries_routing_reminder_hours2 NEQ 0 and hoursSinceUpdate GTE c.inquiries_routing_reminder_hours2){
					totalReminders++;
					if(inquiries_reminders_sent LT totalReminders){
						sendReminder=true;
						reminderprefix="2nd follow-up reminder: ";
					}
				}
				if(c.inquiries_routing_reminder_hours3 NEQ 0 and hoursSinceUpdate GTE c.inquiries_routing_reminder_hours3){
					totalReminders++;
					if(inquiries_reminders_sent LT totalReminders){
						sendReminder=true;
						reminderprefix="3rd follow-up reminder: ";
					}
				}
				if(c.inquiries_routing_reminder_hours_final NEQ 0 and hoursSinceUpdate GTE c.inquiries_routing_reminder_hours_final){
					totalReminders++;
					if(inquiries_reminders_sent LT totalReminders){
						sendReminder=true;
						finalReminder=true;
						reminderprefix="Lead reassigned to you: ";
					}
				}
				if(finalReminder){
					// reassign
					if(c.inquiries_routing_reassignment_type_id EQ 0){
						// assign to zofficeemail
						 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
						WHERE site_id = #db.param(request.zos.globals.id)# and 
						user_active= #db.param(1)# and 
						user_deleted = #db.param(0)# and
						user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
						user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))#  
						LIMIT #db.param(0)#,#db.param(1)#";
						qAssignUser=db.execute("qAssignUser");
						if(qAssignUser.recordcount EQ 0){
							// assign to default email
							rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
						}else{
							// assign to default user instead
							rs.user_id=qAssignUser.user_id;
							if(qAssignUser.user_alternate_email NEQ ""){
								rs.cc=qAssignUser.user_alternate_email;
							}
						}
					}else if(c.inquiries_routing_reassignment_type_id EQ 1){
						// round robin from member table
						 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
						WHERE site_id = #db.param(request.zos.globals.id)# and 
						user_active= #db.param(1)# and 
						user_deleted = #db.param(0)# and
						user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# 	
						ORDER BY user_next_lead DESC, user_id asc 
						LIMIT #db.param(0)#,#db.param(1)#";
						qAssignUser=db.execute("qAssignUser");
						if(qAssignUser.recordcount EQ 0 or application.zcore.functions.zEmailValidate(qAssignUser.user_email) EQ false){
							 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
							WHERE site_id = #db.param(request.zos.globals.id)# and 
							user_active= #db.param(1)# and 
							user_deleted = #db.param(0)# and
							user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
							user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))#  
							LIMIT #db.param(0)#,#db.param(1)#";
							qAssignUser=db.execute("qAssignUser");
							if(qAssignUser.recordcount EQ 0){
								// assign to default email
								rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
							}else{
								// assign to default user instead
								rs.user_id=qAssignUser.user_id;
								if(qAssignUser.user_alternate_email NEQ ""){
									rs.cc=qAssignUser.user_alternate_email;
								}
							}
						}else{
							// assign to the round robin user
							rs.user_id=qAssignUser.user_id;
							db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
							SET user_next_lead = user_next_lead+#db.param(1)#,
							user_updated_datetime=#db.param(request.zos.mysqlnow)#  
							WHERE site_id = #db.param(request.zos.globals.id)# and 
							user_active= #db.param(1)# and 
							user_deleted = #db.param(0)# and
							user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# ";
							db.execute("q");
							 db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
							 SET user_next_lead = #db.param(0)#,
							 user_updated_datetime=#db.param(request.zos.mysqlnow)#  
							WHERE user_id = #db.param(qAssignUser.user_id)# and 
							user_deleted = #db.param(0)# and
							site_id = #db.param(request.zos.globals.id)#";
							db.execute("q");
						}
					}else if(c.inquiries_routing_reassignment_type_id EQ 2){
						// assign to user id
						db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
						WHERE site_id = #db.param(request.zos.globals.id)# and 
						user_active= #db.param(1)# and 
						user_deleted = #db.param(0)# and
						user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
						user_id =#db.param(c.inquiries_routing_assign_to_user_id)# 	
						ORDER BY user_next_lead DESC, user_id asc 
						LIMIT #db.param(0)#,#db.param(1)#";
						qAssignUser=db.execute("qAssignUser"); 
						if(qAssignUser.recordcount EQ 0 or application.zcore.functions.zEmailValidate(qAssignUser.user_email) EQ false){
							 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
							WHERE site_id = #db.param(request.zos.globals.id)# and 
							user_active= #db.param(1)# and 
							user_deleted = #db.param(0)# and
							user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
							user_username =#db.param(application.zcore.functions.zvarso('zofficeemail'))# 	
							ORDER BY user_next_lead DESC, user_id asc 
							LIMIT #db.param(0)#,#db.param(1)#";
							qAssignUser=db.execute("qAssignUser");
							if(qAssignUser.recordcount EQ 0){
								rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
							}else{
								rs.user_id=qAssignUser.user_id;
								if(qAssignUser.user_alternate_email NEQ ""){
									rs.cc=qAssignUser.user_alternate_email;
								}
							}
						}else{
							rs.user_id=qAssignUser.user_id;
							if(qAssignUser.user_alternate_email NEQ ""){
								rs.cc=qAssignUser.user_alternate_email;
							}
						}
						
					}else if(c.inquiries_routing_reassignment_type_id EQ 3){
						// assign to email address
						rs.assignEmail=c.inquiries_routing_reassignment_to_email;
					}else{
						application.zcore.template.fail("Invalid inquiries_routing_type_id");	
					}
					if(inquiries_routing_cc2 NEQ ""){
						// send copy due to reassignment
						rs.bcc=inquiries_routing_cc2;	
					}
					 db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
					set inquiries_updated_datetime=#db.param(request.zos.mysqlnow)#, 
					inquiries_reminders_sent=#db.param(0)# 
					WHERE inquiries_id = #db.param(inquiries_id)# and 
					site_id=#db.param(request.zos.globals.id)# and 
					inquiries_deleted = #db.param(0)#";
					db.execute("q");
					
					
				}else if(sendReminder){
					db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
					WHERE site_id = #db.param(request.zos.globals.id)# and 
					user_active= #db.param(1)# and 
					user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and 
					user_id =#db.param(c.inquiries_routing_assign_to_user_id)# and 
					user_deleted = #db.param(0)# 	
					ORDER BY user_next_lead DESC, user_id asc 
					LIMIT #db.param(0)#,#db.param(1)#";
					qAssignUser=db.execute("qAssignUser");
					if(qAssignUser.recordcount NEQ 0){
						rs.to=qAssignUser.user_username;
						if(qAssignUser.user_alternate_email NEQ ""){
							rs.cc=qAssignUser.user_alternate_email;
						}
						rs.subjectPrefix=reminderprefix;
					}else{
						rs.subjectPrefix="Inactive User. You must manually reassign lead: ";
						rs.to=application.zcore.functions.zvarso('zofficeemail');
					}
					 db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
					 set inquiries_updated_datetime=#db.param(request.zos.mysqlnow)#, 
					 inquiries_reminders_sent=#db.param(totalReminders)# 
					WHERE inquiries_id = #db.param(inquiries_id)# and 
					site_id = #db.param(request.zos.globals.id)# and 
					inquiries_deleted = #db.param(0)#";
					db.execute("q");
				}
			}
		}
	}
	</cfscript></cfloop><cfscript> 
	return rs;
	</cfscript>
</cffunction>


<cffunction name="zCheckLeadStatus" localmode="modern" output="no" returntype="any">
<!--- 
query all unclosed leads and send reminders if enabled.
inquiries_updated_datetime --->
</cffunction>
 
<!--- zGetLeadRoutesStruct(); --->
<cffunction name="zGetLeadRoutesStruct" localmode="modern" output="no" returntype="any">
    <cfscript>
	var db.sql="";
	var local=structnew();
	var ts=structnew();
	var rs=structnew();
	var arrC=arraynew(1);
	var arrM=arraynew(1);
	var i=0;
	var qm=0;
	var q=0;
	var db=request.zos.queryObject;
	</cfscript>
    <cfsavecontent variable="db.sql">
    SELECT * FROM #db.table("inquiries_routing", request.zos.zcoreDatasource)# inquiries_routing 
    LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
	inquiries_type.inquiries_type_id = inquiries_routing.inquiries_type_id and 
	inquiries_type_deleted = #db.param(0)# and
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_routing.inquiries_type_id_siteIDType"))#
     
	WHERE inquiries_routing.site_id =#db.param(request.zos.globals.id)# and 
	inquiries_routing_deleted = #db.param(0)#
	ORDER BY inquiries_routing_sort
    </cfsavecontent><cfscript>q=db.execute("q");
	rs.arrData=arraynew(1);
	if(q.recordcount NEQ 0){
		arrC=listtoarray(q.columnlist,",");
	}
	</cfscript>
    <cfloop query="q">
		<cfscript>
        ts=structnew();
        ts.data=structnew();
        for(i=1;i LTE arraylen(arrC);i++){
            ts.data[arrC[i]]=q[arrC[i]][q.currentrow];
        }
        </cfscript>
        <cfif q.inquiries_routing_type_id EQ 2>
            <cfsavecontent variable="db.sql">
            SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user.user_id = #db.param(q.inquiries_routing_assign_to_user_id)# and 
			user_deleted = #db.param(0)# and
			user.site_id =#db.param(request.zos.globals.id)# 
            </cfsavecontent><cfscript>qM=db.execute("qM");
            arrM=listtoarray(qM.columnlist,",");
            ts.assignToUserIdCount=qM.recordcount;
            for(i=1;i LTE arraylen(arrM);i++){
                if(qM.recordcount EQ 0){
                    ts.assignToUserIdStruct[arrM[i]]="";
                }else{
                    ts.assignToUserIdStruct[arrM[i]]=qM[arrM[i]][qm.currentrow];
                }
            }
            </cfscript>
        </cfif>
        <cfif q.inquiries_routing_reassignment_type_id EQ 2>
            <cfsavecontent variable="db.sql">
            SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user.user_id = #db.param(q.inquiries_routing_reassignment_to_user_id)# and 
			user_deleted = #db.param(0)# and
			user.site_id =#db.param(request.zos.globals.id)# 
            </cfsavecontent><cfscript>qM=db.execute("qM");
            arrM=listtoarray(qM.columnlist,",");
            ts.reassignmentToUserIdCount=qM.recordcount;
            for(i=1;i LTE arraylen(arrM);i++){
                if(qM.recordcount EQ 0){
                    ts.reassignmentToUserIdQuery[arrM[i]]="";
                }else{
                    ts.reassignmentToUserIdQuery[arrM[i]]=qM[arrM[i]][qm.currentrow];
                }
            }
            </cfscript>
        </cfif>
        <cfscript>
		arrayappend(rs.arrData, ts);
		</cfscript>
    </cfloop>
    <cfscript>
	return rs;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>