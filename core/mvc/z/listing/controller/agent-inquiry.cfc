<cfcomponent>
<cfoutput>


<cffunction name="index" access="remote" localmode="modern">
	<cfscript> 
	request.zos.currentURLISAListingPage=true;
	db=request.zos.queryObject;
    application.zcore.template.setTag("pagetitle","Contact Us");
    application.zcore.template.setTag("title","Contact Us");
	application.zcore.functions.zStatusHandler(request.zsid, true);
	form.user_id=application.zcore.functions.zso(form, 'user_id');
	form.user_id_siteIdType=application.zcore.functions.zso(form, 'user_id_siteIdType');
 
	site_id=application.zcore.functions.zGetSiteIdFromSiteIdType(form.user_id_siteIdType);
	if(site_id EQ request.zos.globals.id or (request.zos.globals.parentId NEQ 0 and site_id EQ request.zos.globals.parentId)){
		// ok
	}else{
		application.zcore.functions.z404("Invalid user id");
	}

	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(site_id)# and 
	user_active=#db.param(1)# and 
	user_deleted=#db.param(0)# and 
	user_id = #db.param(form.user_id)# and 
	member_public_profile=#db.param(1)# ";
	qUser=db.execute("qUser"); 
	for(row in qUser){
	    application.zcore.template.setTag("pagetitle","Contact "&row.user_first_name&" "&row.user_last_name);
	    application.zcore.template.setTag("title","Contact "&row.user_first_name&" "&row.user_last_name);
	}
	displayAgentInquiryForm(form.user_id, form.user_id_siteIdType);
	</cfscript>
</cffunction>
	
<!--- 
agentCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.agent-inquiry");
user_id=0;
user_id_siteIdType=application.zcore.functions.zGetSiteIdType(qUser.site_id);
agentCom.displayAgentInquiryForm(user_id, user_id_siteIdType);
 --->
<cffunction name="displayAgentInquiryForm" access="public" localmode="modern">
	<cfargument name="user_id" type="string" required="yes">
	<cfargument name="user_id_siteIdType" type="string" required="yes">
	<cfscript> 
	var db=request.zos.queryObject;  
    form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
    if(form.modalpopforced EQ 1){
        application.zcore.template.setTag("pagetitle","Contact Us");
        application.zcore.template.setTag("title","Contact Us");
		application.zcore.functions.zSetModalWindow();
    } 
	structappend(form, application.zcore.functions.zNewRecord(request.zos.zcoreDatasource, "inquiries"), false);
	if(request.zos.originalURL NEQ "/z/listing/agent-inquiry/index"){
		application.zcore.functions.zStatusHandler(request.zsid, true);
	}
	for(i in url){
		if(left(i,10) EQ "inquiries_"){
			form[i]=url[i];
		}
	}
	</cfscript>
    
    <a id="cjumpform"></a> 
    <p>* denotes required field.</p>
        <cfscript>
        form.set9=application.zcore.functions.zGetHumanFieldIndex();
        </cfscript>
        <form class="zFormCheckDirty" id="myForm" action="/z/listing/agent-inquiry/send" onsubmit="zSet9('zset9_#form.set9#');" method="post" style="margin:0px; padding:0px;">
        <input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
        <input type="hidden" name="redirect_url" value="#htmleditformat(application.zcore.functions.zso(form, 'redirect_url'))#" /> 
        #application.zcore.functions.zFakeFormFields()#
        <input type="hidden" name="inquiries_referer" value="#HTMLEditFormat(request.zos.cgi.http_referer)#" />
        <input type="hidden" name="user_id" value="#HTMLEditFormat(arguments.user_id)#" />
        <input type="hidden" name="user_id_siteIdType" value="#HTMLEditFormat(arguments.user_id_siteIdType)#" />
        <table class="zinquiry-form-table">
        <tr>
            <th>First Name: *</th>
            <td><input name="inquiries_first_name" id="inquiries_first_name" type="text" style="width:96%;" maxlength="50" value="<cfif form.inquiries_first_name EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_first_name')#<cfelse>#form.inquiries_first_name#</cfif>" /></td>
            </tr>
            <tr>
                <th>Last Name: *</th>
                <td><input name="inquiries_last_name" type="text" style="width:96%;" maxlength="50" value="<cfif form.inquiries_last_name EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_last_name')#<cfelse>#form.inquiries_last_name#</cfif>" /></td>
            </tr>
            <tr>
                <th>Email: <cfif structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1>*</cfif></th>
                <td><input name="inquiries_email" type="text" style="width:96%;" maxlength="50" value="<cfif form.inquiries_email EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_email')#<cfelse>#form.inquiries_email#</cfif>" /></td>
            </tr>
            <tr>
                <th>Phone: <cfif application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1>*</cfif></th>
                <td><input name="inquiries_phone1" type="text" style="width:96%;" maxlength="50" value="<cfif form.inquiries_phone1 EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_phone1')#<cfelse>#form.inquiries_phone1#</cfif>" /></td>
            </tr>
        
        <tr><th style="vertical-align:top; width:90px; ">Comments:
            <cfif structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_comments_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_comments_required EQ 1>*</cfif>
        </th><td>
		<cfsavecontent variable="content2">
			<cfif structkeyexists(form, 'inquiries_comments')>#htmleditformat(form.inquiries_comments)# 
			<cfelse>#htmleditformat(application.zcore.functions.zso(form, 'inquiries_comments'))#
			</cfif>
		</cfsavecontent>
        <textarea name="inquiries_comments" cols="50" rows="5" style="width:96%; height:100px;">#trim(content2)#</textarea>
        
        </td></tr>
 
    <tr class="znewslettercheckbox">
		<th>&nbsp;</th>
		<td><input type="checkbox" name="inquiries_email_opt_in" id="inquiries_email_opt_in" value="1" <cfif application.zcore.functions.zso(form, 'inquiries_email_opt_in',false,0) EQ "1">checked="checked"</cfif> style="background:none; border:none;" /> <label for="inquiries_email_opt_in"><cfif application.zcore.functions.zvarso("Newsletter Signup Text") EQ "">
				Please check the box to join our mailing list.
			<cfelse>
				#application.zcore.functions.zvarso("Newsletter Signup Text")#
			</cfif></label></td>
	</tr>
	
	<cfif application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1>
		<tr>
		<th>&nbsp;</th>
			<td>
			#application.zcore.functions.zDisplayRecaptcha()#
			</td>
		</tr>
	</cfif>
	<tr>
	<th>&nbsp;</th>
		<td><button type="submit" name="submit">Send Inquiry</button>&nbsp;&nbsp; <a href="/z/user/privacy/index" target="_blank" class="zPrivacyPolicyLink">Privacy Policy</a><br /><br />
        
        <div class="zPrivacyPolicyMessage">
   			#application.zcore.functions.zvarso("Form Privacy Message")#
		</div></td>
        </tr>
	</table>
    <cfif form.modalpopforced EQ 1>
		<input type="hidden" name="modalpopforced" value="1" />
		<input type="hidden" name="js3811" id="js3811" value="" />
		<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
    </cfif>
	</form>
</cffunction>


<cffunction name="send" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	rs={};
	myForm=structnew(); 
	form.inquiries_spam=0;
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', false, 0); 
	form.user_id=application.zcore.functions.zso(form, 'user_id');
	form.user_id_siteIdType=application.zcore.functions.zso(form, 'user_id_siteIdType');
	if(form.user_id_siteIdType NEQ 1 and form.user_id_siteIdType NEQ 2){
		application.zcore.status.setStatus(Request.zsid, "Invalid user.  Please try sending us a general inquiry instead.",form,true);
		application.zcore.functions.zRedirect("/z/misc/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
	}

	
	if(application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1){
		if(not application.zcore.functions.zVerifyRecaptcha()){
			application.zcore.status.setStatus(request.zsid, "The ReCaptcha security phrase wasn't entered correctly. Please try again.", form, true);
			application.zcore.functions.zRedirect(ulink);
		}
	}
	currentSiteId=application.zcore.functions.zGetSiteIdFromSiteIdType(form.user_id_siteIdType);
	if(form.modalpopforced EQ 1){
		if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
			form.inquiries_spam=1; 
			form.inquiries_spam_description="js3811 value not set";
		}
		if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
			form.inquiries_spam=1; 
			form.inquiries_spam_description="Form hash value was wrong";
		}
	}
	/*if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		form.inquiries_spam=1; 
		form.inquiries_spam_description="zset9 was wrong";
	} */

	db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# 
	WHERE user_deleted = #db.param(0)# and 
	user_id = #db.param(form.user_id)# and 
	user_active = #db.param(1)# and  
	site_id = #db.param(currentSiteId)#";
	qUser=db.execute("qUser"); 
	if(qUser.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, "Invalid user.  Please try sending us a general inquiry instead.",form,true);
		application.zcore.functions.zRedirect("/z/misc/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
	}
	userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin"); 
	user_group_id22 = userGroupCom.getGroupId('member',request.zos.globals.id);

	// verify that this is a user that has "member" or more user group permissions - so that the form can't be used to spam the other kinds of users
	db.sql="select * from #db.table("user_group_x_group", request.zos.zcoreDatasource)# 
	WHERE user_group_x_group_deleted = #db.param(0)# and 
	user_group_id = #db.param(qUser.user_group_id)# and 
	user_group_child_id = #db.param(user_group_id22)# and 
	site_id = #db.param(currentSiteId)# 
	LIMIT #db.param(0)#, #db.param(1)#";
	qUserGroup=db.execute("qUserGroup");  
	if(qUserGroup.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, "Invalid user.  Please try sending us a general inquiry instead.",form,true);
		application.zcore.functions.zRedirect("/z/misc/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
	}
	if(structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1){
		myForm.inquiries_email.required = true;
		myForm.inquiries_email.friendlyName = "Email Address";
		myForm.inquiries_email.email = true;
	}
	myForm.inquiries_first_name.required = true;
	myForm.inquiries_first_name.friendlyName = "First Name";
	if(application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1){
		myForm.inquiries_phone1.required = true;
		myForm.inquiries_phone1.friendlyName = "Phone";
	}
	myForm.inquiries_datetime.createDateTime = true;
	form.inquiries_type_id = 16;
	form.inquiries_type_id_siteIdType=4;
	form.inquiries_status_id = 1;
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result eq true){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/listing/agent-inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
	}
	if(Find("@", form.inquiries_first_name) NEQ 0){
		form.inquiries_spam=1;
		form.inquiries_spam_description="@ symbol in first name";
	}
	 
	form.inquiries_session_id=application.zcore.session.getSessionId();
	form.user_id=0;
	//	Insert Into Inquiry Database
	form.site_id = request.zOS.globals.id; 
	form.inquiries_datetime = dateformat(now(), 'yyyy-mm-dd') &" "&timeformat(now(), 'HH:mm:ss'); 
	form.inquiries_id=application.zcore.functions.zInsertLead();
	if(form.inquiries_id EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Your inquiry has not been sent due to an error.", false,true);
		application.zcore.functions.zRedirect("/z/listing/agent-inquiry/index?modalpopforced=#form.modalpopforced#&zsid="&request.zsid);
	} 
	/*
	db.sql="SELECT * FROM (#db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
	#db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status) 
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
	inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#) and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	inquiries_type_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id  and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE inquiries.site_id = #db.param(request.zOS.globals.id)# and 	
	inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
	inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_deleted = #db.param(0)# and 
	inquiries_status_deleted = #db.param(0)#
	 ";
	qinquiry=db.execute("qinquiry");
	application.zcore.functions.zQueryToStruct(qinquiry);
	*/
	application.zcore.tracking.setUserEmail(form.inquiries_email);
	application.zcore.tracking.setConversion('agent inquiry', form.inquiries_id);
	
	if(application.zcore.functions.zso(form, 'inquiries_email') EQ "" or application.zcore.functions.zEmailValidate(form.inquiries_email) EQ false){
		form.inquiries_email=request.fromemail;
	}
	form.contact_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew()));	  
	ts=structnew();
	ts.inquiries_id=form.inquiries_id;
	ts.subject="New Agent Inquiry on #request.zos.globals.shortdomain#";


	ts.forceAssign=true;
	ts.assignUserId=qUser.user_id; 
	ts.assignUserIdSiteIdType=form.user_id_siteIdType; 

	// send the lead
	rs=application.zcore.functions.zAssignAndEmailLead(ts);
	if(rs.success EQ false){
		// failed to assign/email lead
		//zdump(rs);
	} 
	
	application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#&zsid="&request.zsid); 
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>