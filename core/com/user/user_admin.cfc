<cfcomponent displayname="User Admin" output="no" hint="Used for administrating user.">
	<cfoutput><!--- 
	// this confirms change of email address, password or opt in status - never assume a user has opt-in unless you have done prior business with them.
	ts=StructNew();
	// required
	ts.email=""; // email address
	// required when ts.force=false;
	ts.key=""; // the only way to authenticate that the user owns the email address.
	// optional
	ts.login=false; // when true, automatically login after successful processing
	ts.redirectURL=""; // redirect after successful processing
	ts.zsid=request.zsid; // append to the current zsid or override with a new one.  A new one is created when this is not sent in.
	ts.force=false; // set to true to ignore key
	ts.site_id=request.zos.globals.id;
	rs=userAdminCom.confirm(ts);
	if(rs.success EQ false){
		application.zcore.status.setStatus(request.zsid, "Your email address was not confirmed for the following reasons:");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#");
	}else{
		// user is now authenticated, however you must force login manually or redirect back to system...
	}
	 --->
<cffunction name="confirm" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qcheckemail='';
	var inputstruct=structnew();
	var rs=StructNew();
	var ts=StructNew();
	var db=request.zos.queryObject;
	var qp="";
	var qIn=0;
	var datetime = request.zos.mysqlnow;
	rs.success=true;
	ts.force=false;
	ts.login=false;
	ts.site_id=request.zos.globals.id;
	StructAppend(arguments.ss, ts, false);
	if(structkeyexists(arguments.ss,'zsid') EQ false){
		arguments.ss.zsid=application.zcore.status.getNewId();
	}
	if(structkeyexists(arguments.ss,'email') EQ false){
		application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.user.user_admin.confirm(): arguments.ss.email is required.");
	}
	if(structkeyexists(arguments.ss,'key') EQ false){
		application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.user.user_admin.confirm(): arguments.ss.key is required when arguments.ss.force=false.");
	}
	</cfscript>
         <cfsavecontent variable="db.sql">
        select * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user_username = #db.param(arguments.ss.email)# and 
		user_deleted = #db.param(0)#
		<cfif arguments.ss.force EQ false> and user_key = #db.param(arguments.ss.key)# </cfif> and 
		site_id = #db.param(arguments.ss.site_id)#
        </cfsavecontent><cfscript>qcheckEmail=db.execute("qcheckemail");
        </cfscript>
		<cfif qcheckemail.recordcount EQ 0>
            <cfscript>
			if(qcheckemail.recordcount EQ 0){
				rs.success=false;
				application.zcore.status.setStatus(arguments.ss.zsid, "Your email address is not in our database yet. <a href=""/z/user/preference/index?e=#urlencodedformat(e)#&k=#urlencodedformat(k)#&action=form&zsid=#request.zsid#"">Click here</a> to set your communication preferences.");
				return rs;
			}
            </cfscript>
        </cfif>
        <cfsavecontent variable="db.sql">
        UPDATE #db.table("user", request.zos.zcoreDatasource)# user SET 
        <cfif qcheckemail.user_email_new NEQ ''>
		user_email = #db.param(qcheckemail.user_email_new)#,
		user_username = #db.param(qcheckemail.user_email_new)#, 
		user_email_new=#db.param('')#, 
		member_email = #db.param(qcheckemail.user_email_new)#, 
        </cfif>
        <!--- <cfif qcheckemail.user_password_new NEQ ''>
		user_password_version = #db.param(qcheckemail.user_password_new_version)#,
		user_password = #db.param(qcheckemail.user_password_new)#,
		user_salt = #db.param(qcheckemail.user_password_new_salt)#, 
		user_password_new=#db.param('')#, 
		user_password_new_version=#db.param('')#,
		user_password_new_salt=#db.param('')#,
		member_password = #db.param(qcheckemail.user_password_new)#, 
        </cfif> --->
	user_confirm =#db.param(1)#,  
	user_pref_list=#db.param(1)#, 
	user_confirm_datetime=#db.param(datetime)#, 
	user_confirm_ip=#db.param(request.zos.cgi.remote_addr)#, 
	user_updated_datetime=#db.param(datetime)#, 
	user_updated_ip=#db.param(request.zos.cgi.remote_addr)# 
	
	WHERE user_id = #db.param(qcheckemail.user_id)# and 
	user_deleted = #db.param(0)# and
	site_id = #db.param(arguments.ss.site_id)#
        </cfsavecontent><cfscript>qIn=db.execute("qIn");
		if(arguments.ss.login){
			// set checkLogin options
			form.zusername=qcheckemail.user_username;
			form.zpassword=qcheckemail.user_password;
			inputStruct = StructNew();
			inputStruct.user_group_name = "user";
			inputStruct.noRedirect=true;
			inputStruct.site_id = arguments.ss.site_id;
			inputStruct.secureLogin=true;
			// perform check 
			application.zcore.user.checkLogin(inputStruct); 
		}
		if(structkeyexists(arguments.ss,'redirectURL')){
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(replacenocase(arguments.ss.redirectURL,"zsid=","zsid2=","ALL"), "zsid="&request.zsid));
		}
		return rs;
        </cfscript>
    </cffunction>
        

	<cffunction name="applyUserUpdateSecurityFilter" localmode="modern">
		<cfargument name="str" type="struct" required="yes">
		<cfscript>
		str=arguments.str;
		if(not application.zcore.user.checkSiteAccess() and not application.zcore.user.checkServerAccess()){
			structdelete(str, 'user_limit_manager_features');
			structdelete(str, 'user_enable_widget_builder');
		}
		if(not application.zcore.user.checkServerAccess()){
			structdelete(str, 'user_server_admin_site_id_list');
		}else{
			if(structkeyexists(str, 'user_server_administrator') and str.user_server_administrator NEQ 1){
				str.user_server_admin_site_id_list="";
			}
		}
		</cfscript>
	</cffunction>
    
	<!--- To use a component, you create it as an object and call its methods like so...
	userCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.user_admin");
	userCom.add(inputStruct); 
	 --->

	<!---  
	inputStruct = structNew();
	// required 
	inputStruct.user_username = application.zcore.functions.zso(form, 'user_username'); // make same as email to use email as login
	inputStruct.user_password = application.zcore.functions.zso(form, 'user_password');
	inputStruct.site_id = application.zcore.functions.zVar('id'); 
	// optional
	inputStruct.user_first_name = application.zcore.functions.zso(form, 'user_first_name');
	inputStruct.user_last_name = application.zcore.functions.zso(form, 'user_last_name');
	inputStruct.user_email = application.zcore.functions.zso(form, 'user_email');
	inputStruct.user_group_id = 0; // set default user access level
	inputStruct.user_system = 0; // set to 1 to make system user.
	inputStruct.user_site_administrator = 0; // set to 1 to give user full access to all groups on a site
	inputStruct.user_server_administrator = 0; // set to 1 to give user full access to all sites & groups
	inputStruct.user_pref_email=1; // set to 0 to opt out of all email
	inputStruct.user_pref_list=1; // set to 0 to opt out of mailing list
	inputStruct.user_pref_sharing=0; // set to 1 to allow sharing of mailing list
	inputStruct.resetConfirmOptIn=true; // resend up to 3 optin emails
	inputStruct.zemail_template_id=false; // select the email template to send
	inputStruct.from=false; // the from email addess for the opt in notice
	inputStruct.autologin=false;
	inputStruct.createPassword=false;
	inputStruct.disablePasswordValidation=0; // used for invite user system to avoid having to set a password.
	user_id = userCom.add(inputStruct);
	if(user_id EQ false){
		// duplicate entry
	}else{
		// successful
	}
	--->
	<cffunction name="add" localmode="modern" output="no" returntype="any">	
		<cfargument name="inputStruct" required="yes" type="struct">
		<cfscript>
		var i = 0;
		var arrTemp = ArrayNew(1);
		var ls = "";
		var qUser = "";
		var tempStruct = StructNew();
		var local=structnew();
		var str = "";
		var inputStruct2= StructNew();
		var nowDate=now();
		var ts=0;
		var emailCom=0;
		var db=request.zos.queryObject;
		var qCheck=0;
		var qUpdate=0;
		var cfcatch=0;
		
		tempStruct.user_created_datetime = request.zos.mysqlnow;
		tempStruct.user_updated_datetime = request.zos.mysqlnow;
		tempStruct.user_system = 1;
		tempStruct.user_server_administrator = 0;
		tempStruct.user_site_administrator = 0;
		tempStruct.user_group_id = 0;
		tempStruct.user_access_site_children =0;
		tempStruct.user_pref_email=1;
		tempStruct.user_pref_list=1;
		tempStruct.user_pref_sharing=0;
		tempStruct.user_pref_html=1;
		tempStruct.user_created_ip = request.zos.cgi.remote_addr;
		tempStruct.user_active = 1;
		tempStruct.user_welcome_message='';
		tempStruct.user_invited=0;
		tempStruct.resetConfirmOptIn=true;
		tempStruct.zemail_template_id=false;
		tempStruct.from=false;
		tempStruct.autologin=false;
		tempStruct.createPassword=false;
		tempStruct.disablePasswordValidation=0;
		// override defaults
		StructAppend(arguments.inputStruct, tempStruct, false);
		str = arguments.inputStruct; // less typing
		variables.str = str; // force auto insert form to see the variables
		</cfscript>
		<cfif str.user_group_id EQ 0>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_admin.add: inputStruct.user_group_id can never be 0. Every user must belong to a user group.">
		</cfif>
		<cfif structkeyexists(str, 'user_username') EQ false>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_admin.add: inputStruct.user_username required.">
		</cfif>
        <cfscript>
		str.user_key=hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha');
		if(str.createPassword){
			str.user_password=application.zcore.functions.zGenerateStrongPassword(40,70);
		}
		</cfscript> 
		<cfif structkeyexists(str, 'user_password') EQ false>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_admin.add: inputStruct.user_password required.">
		</cfif>
		<cfif structkeyexists(str, 'site_id') EQ false>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_admin.add: inputStruct.site_id required.">
		</cfif>
		<cfscript>
		if(structkeyexists(str, 'sendConfirmOptIn') EQ false){
			if(application.zcore.functions.zvar('sendConfirmOptIn',str.site_id) EQ 1 and (str.user_pref_list EQ 1 or str.user_pref_sharing EQ 1)){
				str.sendConfirmOptIn=true;
			}else{
				str.sendConfirmOptIn=false;
			}
		}
		if(not structkeyexists(str, 'user_email')){
			str.user_email=str.user_username;
		}
		if(len(str.user_username) LT 5){
			// username must be 5 or more characters
			request.userAdminAddError="username must be 5 or more characters";
			return false;
		} 
		if(str.disablePasswordValidation EQ 0){
			if(len(str.user_password) LT 8){
				// password must be 8 or more characters
				request.userAdminAddError="password must be 8 or more characters";
				return false;
			}
		}
		if(str.user_invited EQ '1'){
			str.user_reset_key=hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256');
			str.user_invited_datetime=request.zos.mysqlnow;
		}
		if(application.zcore.functions.zso(str,'user_email') NEQ '' and application.zcore.functions.zEmailValidate(str.user_email) EQ false){
			// invalid email address
			request.userAdminAddError="invalid email address";
			return false;
		}
		if(str.user_access_site_children EQ 1){
			 db.sql="SELECT user_id FROM #db.table("user", request.zos.zcoreDatasource)# user, 
			 #db.table("site", request.zos.zcoreDatasource)# site 
			WHERE user_username = #db.param(str.user_username)# and 
			user_deleted = #db.param(0)# and 
			site_deleted = #db.param(0)# and 
			user.site_id = site.site_id and 
			site.site_parent_id = #db.param(str.site_id)# ";
			qUser=db.execute("qUser");
			if(qUser.recordcount NEQ 0){
				request.userAdminAddError="user_username must not already be in the child sites of the site the user is added to.";
				return false; // user_username must not already be in the child sites of the site the user is added to.
			}
		}
		if(str.user_server_administrator EQ 1){
			 db.sql="SELECT user_id FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_username = #db.param(str.user_username)# and 
			user_deleted = #db.param(0)# and 
			site_id = #db.param(application.zcore.functions.zVar('serverId'))# ";
			qUser=db.execute("qUser");
			if(qUser.recordcount NEQ 0){
				request.userAdminAddError="user_username must be unique for entire server for all server administrator usernames.";
				return false; // user_username must be unique for entire server for all server administrator usernames.
			}
		}else{
			db.sql="SELECT user_id FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_username = #db.param(str.user_username)# and 
			site_id = #db.param(application.zcore.functions.zVar('serverId'))#  and 
			user_deleted = #db.param(0)# and 
			user_server_administrator=#db.param(1)#";
			qUser=db.execute("qUser"); 
			if(quser.recordcount neq 0){
				request.userAdminAddError="user_username must not already be a server administrator.";
				return false; // user_username must not already be a server administrator.
			}
		}
		str.user_salt=application.zcore.functions.zGenerateStrongPassword(256,256);
		if(str.user_password EQ ""){
			str.user_password_version=request.zos.defaultPasswordVersion;
		}else{
			if(structkeyexists(str, 'user_password') EQ false){
				str.user_password=application.zcore.functions.zGenerateStrongPassword(10,20);
			}
			if(application.zcore.functions.zvar('plainTextPassword', str.site_id) EQ 0){
				str.user_password_version = request.zos.defaultPasswordVersion;
				str.user_password=application.zcore.user.convertPlainTextToSecurePassword(str.user_password, str.user_salt, request.zos.defaultPasswordVersion, false);
			}else{
				str.user_password_version =0;
				str.user_salt="";
			}
		}
		str.member_password=str.user_password;
		str.member_email=str.user_username; 

		if(not application.zcore.user.checkAllCompanyAccess()){
			if(isdefined('request.zsession.user.company_id')){
				str.company_id=request.zsession.user.company_id;
			}
		}

		applyUserUpdateSecurityFilter(str);
	
		inputStruct2.table = "user";
		inputStruct2.datasource=request.zos.zcoreDatasource;
		inputStruct2.struct = str;
		str.user_id = application.zcore.functions.zInsert(inputStruct2);
		if(str.user_id EQ false){
        	if(str.resetConfirmOptIn){
				db.sql="SELECT user_id,user_pref_html 
				FROM #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE user_username = #db.param(str.user_username)# and 
				site_id = #db.param(str.site_id)# and 
				user_deleted = #db.param(0)# and 
				user_confirm = #db.param('0')# and 
				user_confirm_count = #db.param('3')#";
				qCheck=db.execute("qCheck");
				if(qCheck.recordcount NEQ 0){
					ts=StructNew();
					// required
					ts.user_id = qCheck.user_id;					
					if(qCheck.user_pref_html EQ 1){
						ts.html=true;
					}else{
						ts.html=false;
					}
					// optional
					ts.zemail_template_id=str.zemail_template_id;
					ts.site_id=request.zos.globals.id;
					this.resetConfirmOptIn(ts);
				}
			}
			request.userAdminAddError="user_username wasn't unique for current site_id (query failed) ";
			return false; // user_username wasn't unique for current site_id (query failed) 
		}
		/*
		// we should never remove a contact record - this is legacy code
		 db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)#  
		WHERE contact_email=#db.param(str.user_email)# and 
		contact_deleted = #db.param(0)# and 
		site_id=#db.param(str.site_id)#";
		local.qU=db.execute("qU");
		if(local.qU.recordcount NEQ 0){
			db.sql="update #db.table("contact", request.zos.zcoreDatasource)#  
			set contact_deleted = #db.param(1)#,
			contact_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE contact_id=#db.param(local.qU.contact_id)# and 
			site_id=#db.param(local.qU.site_id)# and 
			contact_deleted=#db.param(0)#";
			db.execute("q"); 
		}*/
		</cfscript>

		<cfif str.user_invited EQ 1>
			<!--- send welcome email --->
			<cfscript>
			resendInvite(str.user_id);
			</cfscript>

		</cfif>
		<cfif application.zcore.user.checkGroupAccess("administrator")>
			<!--- don't send email --->
		<cfelse>
			<!--- notify site owner that a new user was added. --->
			<cfif application.zcore.functions.zso(request.zos.globals, 'disableNewUserEmail', true, 0) NEQ 1 and structkeyexists(request, 'fromemail') and structkeyexists(request, 'officeemail') and structkeyexists(request, 'zDisableNewMemberEmail') EQ false>
	        	<cftry>
<cfmail   charset="utf-8" from="#trim(request.fromemail)#" to="#trim(request.officeEmail)#" subject="New User on #request.zos.globals.shortdomain#">
New User on #request.zos.globals.shortdomain#

User E-Mail Address: #str.user_username#

This user has signed up for a service on your web site.   This is not a direct sales inquiry.

To view more info about this new user, click the following link:
#request.zos.currentHostName#/z/admin/member/edit?user_id=#str.user_id#
</cfmail>	
				<cfcatch type="any">
<cfmail   charset="utf-8" from="#request.zos.developerEmailTo#" to="#request.zos.developerEmailTo#" subject="Failed: New User on #request.zos.globals.shortdomain#">
This is an alert that the new user email failed.
request.fromemail: #request.fromemail#
request.officeEmail: #request.officeEmail#

New User on #request.zos.globals.shortdomain#

User E-Mail Address: #str.user_username#

This user has signed up for a service on your web site.   This is not a direct sales inquiry.

To view more info about this new user, click the following link:
#request.zos.currentHostName#/z/admin/member/edit?user_id=#str.user_id#
</cfmail>	
				</cfcatch></cftry>
			</cfif>
		</cfif>
		<cfscript>
		if(str.autoLogin){
			// set checkLogin options
			form.zusername=str.user_username;
			form.zpassword=str.user_password;
			inputStruct = StructNew();
			inputStruct.user_group_name = "user";
			inputStruct.noRedirect=true;
			inputStruct.site_id = str.site_id;
			inputStruct.secureLogin=true;
			inputStruct.disableSecurePassword=true;
			// perform check 
			application.zcore.user.checkLogin(inputStruct);
		}
		// only happens if user didn't exist yet
		if(str.sendConfirmOptIn){
			ts=StructNew();
			// optional
			ts.site_id=str.site_id;
			if(str.zemail_template_id NEQ false){
				ts.zemail_template_id = str.zemail_template_id;
			}else{
				ts.zemail_template_type_name = 'confirm opt-in';
			}
			if(str.user_pref_html EQ 1){
				ts.html=true;
			}else{
				ts.html=false;
			}
			ts.from="";
			if(str.from NEQ false){
				ts.from=str.from;
			}else if(request.zos.globals.emailCampaignFrom NEQ ""){
				ts.from=request.zos.globals.emailCampaignFrom;
			}
			if(ts.from NEQ ""){
				ts.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(str.site_id);
				ts.user_id=str.user_id;
				emailCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.app.email");
				emailCom.sendEmailTemplate(ts); // should i continue ignoring failures?
			}
		}
		statusChanged=true;
		if(structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'userStatusChange') and statusChanged){
			application.sitestruct[request.zos.globals.id].zcorecustomfunctions.userStatusChange(str.user_id, "add");
		}
		return str.user_id;
		</cfscript>
		
	</cffunction>
	
	<!--- resendInvite(user_id); --->
	<cffunction name="resendInvite" localmode="modern" output="no" returntype="any"> 
    	<cfargument name="user_id" type="string" required="yes">
        <cfscript>
        db=request.zos.queryObject;
        key=hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256');
        db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# SET 
        user_invited_datetime=#db.param(request.zos.mysqlnow)#, 
        user_reset_key=#db.param(key)#, 
        user_reset_datetime=#db.param(request.zos.mysqlnow)# 
        WHERE user_active=#db.param(1)# and 
        user_invited=#db.param(1)# and 
        user_deleted=#db.param(0)# and 
        user_id=#db.param(arguments.user_id)# and 
        site_id=#db.param(request.zos.globals.id)#";
        db.execute("qUpdate");

        return sendInvite(arguments.user_id);
        </cfscript>
	</cffunction>

	<cffunction name="sendInvite" localmode="modern" output="no" returntype="any"> 
    	<cfargument name="user_id" type="string" required="yes">
        <cfscript>
        db=request.zos.queryObject;
        db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# 
        WHERE user_active=#db.param(1)# and 
        user_invited=#db.param(1)# and 
        user_deleted=#db.param(0)# and 
        user_id=#db.param(arguments.user_id)# and 
        site_id=#db.param(request.zos.globals.id)#";
        qUser=db.execute("qUser");
        if(qUser.recordcount EQ 0){
        	return false;
        } 
        </cfscript>
<cfmail   charset="utf-8" from="#trim(request.fromemail)#" to="#trim(qUser.user_email)#" subject="Invitation to join #request.zos.globals.shortdomain#">
Hi<cfif qUser.user_first_name NEQ ""> #trim(qUser.user_first_name&" "&qUser.user_last_name)#</cfif>, 

You've been invited by <cfif request.zsession.user.first_name NEQ "">#trim(request.zsession.user.first_name&" "&request.zsession.user.last_name)#, </cfif>#request.zsession.user.email#, to create an account at #request.zos.globals.shortdomain#

<cfif qUser.user_welcome_message NEQ "">#qUser.user_welcome_message&chr(10)&chr(10)#</cfif>Your account's email address is:
#qUser.user_username#

Click the following link to create a password and login to our web site.
#request.zos.currentHostName#/z/user/invited?uid=#qUser.user_id#&key=#urlencodedformat(qUser.user_reset_key)#

This invitation will expire in 7 days.  If you need a new invitation, please contact the site owner.

Thank you from #request.zos.globals.shortdomain#
</cfmail>	
		<cfscript>
		return true;
		</cfscript>
	</cffunction>


    <!--- 
	ts=StructNew();
	// required
	ts.user_id = user_id;
	// optional
	ts.zemail_template_id=false;
	ts.site_id=request.zos.globals.id;
	userAdminCom.resetConfirmOptIn(ts);
	 --->
	<cffunction name="resetConfirmOptIn" localmode="modern" output="no" returntype="any"> 
    	<cfargument name="ss" type="struct" required="yes">
        <cfscript>
		var local=structnew();
		var ts=StructNew();
		var qCheck=0;
		var qUpdate=0;
		var db=request.zos.queryObject;
		var emailCom=0;
		ts.zemail_template_id=false;
		ts.site_id = request.zos.globals.id;
		structappend(arguments.ss,ts,false);
		if(structkeyexists(arguments.ss,'user_id') EQ false){
			application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.user.user_admin.add: arguments.ss.user_id required.");
		}
		if(arguments.ss.site_id EQ ''){
			application.zcore.template.fail("Error: COMPONENT: zcorerootmapping.com.user.user_admin.add: arguments.ss.site_id required.");
		}
		</cfscript>        
        <cfsavecontent variable="db.sql">
        SELECT user_id FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user_username = #db.param(str.user_username)# and 
		site_id = #db.param(str.site_id)# and 
		user_confirm = #db.param('0')# and 
		user_deleted = #db.param(0)# and
		user_confirm_count = #db.param('3')#
        </cfsavecontent><cfscript>qCheck=db.execute("qCheck");</cfscript>
        <cfif qCheck.recordcount NEQ 0>
            <cfsavecontent variable="db.sql">
            UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
			SET user_confirm_count = #db.param('0')#, 
			user_sent_datetime=#db.param('0000-00-00 00:00:00')# 
			WHERE user_username = #db.param(str.user_username)# and 
			user_deleted = #db.param(0)# and
			site_id = #db.param(str.site_id)#
            </cfsavecontent><cfscript>qUpdate=db.execute("qUpdate");			
            ts=StructNew();
            // optional
            ts.site_id=arguments.ss.site_id;
            if(arguments.ss.zemail_template_id NEQ false){
                ts.zemail_template_id = arguments.ss.zemail_template_id;
            }else{
                ts.zemail_template_type_name = 'confirm opt-in';
            }
			ts.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(arguments.ss.site_id);
            ts.user_id=arguments.ss.user_id;
            emailCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.app.email");
            emailCom.sendEmailTemplate(ts); // should i continue ignoring failures?
            </cfscript>
        </cfif>
	</cffunction>	
	
	<!---  
	inputStruct = structNew();
	// required
	inputStruct.user_id = application.zcore.functions.zso(form, 'user_id');
	inputStruct.site_id = application.zcore.functions.zVar('id'); 
	// optional
	inputStruct.user_username = application.zcore.functions.zso(form, 'user_username'); // make same as email to use email as login
	inputStruct.user_password = application.zcore.functions.zso(form, 'user_password');
	inputStruct.user_first_name = application.zcore.functions.zso(form, 'user_first_name');
	inputStruct.user_last_name = application.zcore.functions.zso(form, 'user_last_name');
	inputStruct.user_email = application.zcore.functions.zso(form, 'user_email'); 
	inputStruct.user_group_id = 0; // set default user access level
	inputStruct.user_system = 0; // set to 1 to make system user.
	inputStruct.user_site_administrator = 0; // set to 1 to give user full access to all groups on a site
	inputStruct.user_server_administrator = 0; // set to 1 to give user full access to all sites & groups
	inputStruct.sendConfirmOptIn=false;
	inputStruct.zemail_template_id=false; // select the email template to send
	inputStruct.from=false; // the from email addess for the opt in notice
	//inputStruct.user_pref_list=1; // don't send unless user opts in
	//inputStruct.user_pref_html=1; // email type when sending
	if(userCom.update(inputStruct) EQ false){
		// duplicate entry
	}else{
		// successful
	}
	--->
	<cffunction name="update" localmode="modern" output="no" returntype="any">	
		<cfargument name="inputStruct" required="yes" type="struct">
		<cfscript>
		var i = 0;
		var arrTemp = ArrayNew(1);
		var ls = "";
		var qCheck = "";
		var qUser = "";
		var str = StructNew();
		var tempStruct = StructNew();
		var inputStruct2 = StructNew();
		var ts=0;
		var db=request.zos.queryObject;
		var local=structnew();
		tempStruct.site_id = request.zos.globals.id;
		tempStruct.user_updated_datetime = request.zos.mysqlnow;
		tempStruct.user_updated_ip = request.zos.cgi.remote_addr;
		tempStruct.user_group_id = 0;
		tempStruct.sendConfirmOptIn=false;
		tempStruct.zemail_template_id=false;
		tempStruct.from=false;
		// override defaults
		StructAppend(arguments.inputStruct, tempStruct, false);
		str = arguments.inputStruct; // less typing 
		StructDelete(str, "user_created_datetime",true);
		StructDelete(str, "user_created_ip",true);
		variables.str = str;
		</cfscript>
		<cfif str.user_group_id EQ 0>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_admin.update: arguments.inputStruct.user_group_id can never be 0. Every user must belong to a user group.">
		</cfif>
		<cfif structkeyexists(str, 'site_id') EQ false>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_admin.update: arguments.inputStruct.site_id required.">
		</cfif>
		<cfif structkeyexists(str, 'user_id') EQ false>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_admin.update: arguments.inputStruct.user_id required.">
		</cfif>
		
		<cfsavecontent variable="db.sql">
		SELECT *  FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user_id = #db.param(str.user_id)# and 
		user_deleted = #db.param(0)# and
		site_id = #db.param(arguments.inputStruct.site_id)# 
		</cfsavecontent><cfscript>qCheck=db.execute("qCheck");</cfscript>
		<cfif qCheck.recordcount EQ 0>
        	<cfscript>if(request.zos.isDeveloper){ application.zcore.functions.zError("user_admin.cfc user doesn't exist."); }</cfscript>
			<cfreturn false> <!--- user doesn't exist. --->
		</cfif>
		<cfscript>	
		statusChanged=false;
		if(structkeyexists(str, 'user_active') and qCheck.user_active NEQ str.user_active){
			statusChanged=true;
		}	
		if(structkeyexists(str, 'sendConfirmOptIn') EQ false){
			if(application.zcore.functions.zvar('sendConfirmOptIn',str.site_id) EQ 1){
				if(((structkeyexists(str, 'user_pref_list') and str.user_pref_list EQ 1) or (structkeyexists(str, 'user_pref_sharing') and str.user_pref_sharing EQ 1)) and qCheck.user_confirm EQ 0){
					str.user_confirm_count=0;
					str.user_sent_datetime='0000-00-00 00:00:00'; 
					str.sendConfirmOptIn=true;
				}
			}else{
				str.sendConfirmOptIn=false;
			}
		}
		if(len(str.user_username) LT 5){
			// username must be 5 or more characters
        	if(request.zos.isDeveloper){ application.zcore.functions.zError("user_admin.cfc username must be 5 or more characters."); }
			return false;
		}
		if(trim(application.zcore.functions.zso(str,'user_password')) EQ ""){
			structdelete(str, 'user_password');
			structdelete(str, 'user_salt');
			structdelete(str, 'member_password');
		}
		if(application.zcore.functions.zso(str,'user_password') NEQ "" and len(str.user_password) LT 8){
			// password must be 8 or more characters
        	if(request.zos.isDeveloper){ application.zcore.functions.zError("user_admin.cfc password must be 8 or more characters."); }
			return false;
		}
		if(application.zcore.functions.zso(str,'user_email') NEQ '' and application.zcore.functions.zEmailValidate(str.user_email) EQ false){
			// invalid email address
        	if(request.zos.isDeveloper){ application.zcore.functions.zError("user_admin.cfc invalid email address."); }
			return false;
		}
		if(qCheck.user_access_site_children EQ 1){
			 db.sql="SELECT user_id, user.site_id FROM #db.table("user", request.zos.zcoreDatasource)# user, 
			 #db.table("site", request.zos.zcoreDatasource)# site 
			WHERE user_username = #db.param(str.user_username)# and 
			user_deleted = #db.param(0)# and
			user.site_id = site.site_id and 
			site_deleted=#db.param(0)# and 
			site.site_parent_id = #db.param(str.site_id)# ";
			qUser=db.execute("qUser");
			if(qUser.recordcount NEQ 0){
        			if(request.zos.isDeveloper){ application.zcore.functions.zError("user_admin.cfc username already exists in a child site."); }
				return false; // user_username must not already be in the child sites of the site the user is added to.
			}
		}
		if(qCheck.user_server_administrator EQ 1 and application.zcore.functions.zVar('serverId') NEQ str.site_id){
			 db.sql="SELECT user_id FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_username = #db.param(str.user_username)# and 
			user_deleted = #db.param(0)# and
			site_id = #db.param(application.zcore.functions.zVar('serverId'))# ";
			qUser=db.execute("qUser");
			if(qUser.recordcount NEQ 0){
				if(request.zos.isDeveloper){ 
					application.zcore.functions.zError("user_admin.cfc user_username must be unique on entire server for server administrators."); 
				}
				return false; // user_username must be unique for entire server for all server administrator usernames.
			}
		}
		if(structkeyexists(str, 'user_password')){
			if(application.zcore.functions.zvar('plainTextPassword', str.site_id) EQ 0){
				str.user_salt=application.zcore.functions.zGenerateStrongPassword(256,256);
				str.user_password_version = request.zos.defaultPasswordVersion;
				str.user_password=application.zcore.user.convertPlainTextToSecurePassword(str.user_password, str.user_salt, request.zos.defaultPasswordVersion, false);
				str.member_password=str.user_password;
			}else{
				str.user_password_version =0;
				str.member_password=str.user_password;
			}
		}
		if(not application.zcore.user.checkAllCompanyAccess()){
			if(isdefined('request.zsession.user.company_id')){
				str.company_id=request.zsession.user.company_id;
			}
		}
		applyUserUpdateSecurityFilter(str);
		inputStruct2.table = "user";
		inputStruct2.datasource="#request.zos.zcoreDatasource#";
		inputStruct2.struct = str;
		try{
			result=application.zcore.functions.zUpdate(inputStruct2);
		}catch(Any e){
			result=false;
		}
		if(result EQ false){
			/*if(request.zos.isDeveloper){ 
				application.zcore.functions.zError("user_admin.cfc update query failed."); 
			}*/
			return false;
		}
		if(str.sendConfirmOptIn){
			ts=StructNew();
			// optional
			ts.site_id=str.site_id;
			if(str.zemail_template_id NEQ false){
				ts.zemail_template_id = str.zemail_template_id;
			}else{
				ts.zemail_template_type_name = 'confirm opt-in';
			}
			if((structkeyexists(str, 'user_pref_html') and str.user_pref_html EQ 1) or qcheck.user_pref_html EQ 1){
				ts.html=true;
			}else{
				ts.html=false;
			}
			if(str.from NEQ false){
				ts.from=str.from;
			}
			ts.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(str.site_id);
			ts.user_id=str.user_id;
			emailCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.app.email");
			emailCom.sendEmailTemplate(ts); // should i continue ignoring failures?
		}
		if(structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'userStatusChange') and statusChanged){
			application.sitestruct[request.zos.globals.id].zcorecustomfunctions.userStatusChange(str.user_id, "update");
		}
		return true;
		</cfscript>
	</cffunction>
	
	
	
	
	<!--- userCom.setActive(user_id, site_id, blockIp); --->
	<cffunction name="setActive" localmode="modern" output="false" returntype="any">
		<cfargument name="user_id" type="string" required="yes">
		<cfargument name="site_id" type="string" required="yes">
		<cfargument name="unblockip" type="boolean" required="no" default="#false#">
		<cfscript>
		var qActive = "";
		var local=structnew();
		var db=request.zos.queryObject;
		</cfscript>
		<cfsavecontent variable="db.sql">
		UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
		SET user_active = #db.param('1')# ,
		user_ip_blocked = #db.param(0)# 
		WHERE user_id = #db.param(arguments.user_id)# and 
		user_deleted = #db.param(0)# and
		site_id = #db.param(arguments.site_id)# 
		</cfsavecontent><cfscript>qActive=db.execute("qActive");</cfscript>
		<!--- do code for IP block... --->
		<cfif arguments.unblockip>
		
		</cfif>
		<cfreturn true>
	</cffunction>
	
	<!--- userCom.setInactive(user_id, site_id, blockIp); --->
	<cffunction name="setInactive" localmode="modern" output="false" returntype="any">
		<cfargument name="user_id" type="string" required="yes">
		<cfargument name="site_id" type="string" required="yes">
		<cfargument name="blockip" type="boolean" required="no" default="#false#">
		<cfscript>
		var qInactive = "";
		var local=structnew();
		var db=request.zos.queryObject;
		</cfscript>
		<cfsavecontent variable="db.sql">
		UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
		SET user_active = #db.param('0')# 
		<cfif arguments.blockip>
		,user_ip_blocked = #db.param('1')# 
		</cfif> 
		WHERE user_id = #db.param(arguments.user_id)# and 
		user_deleted = #db.param(0)# and
		site_id = #db.param(arguments.site_id)# 
		</cfsavecontent><cfscript>qInactive=db.execute("qInactive");</cfscript>
		<!--- do code for IP block... --->
		<cfif arguments.blockip>
		
		</cfif>
		<cfreturn true>
	</cffunction>
	
<cffunction name="importUserWithStruct" access="public" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ts=arguments.struct;
	ts.user_updated_datetime = request.zos.mysqlnow;
	ts.user_updated_ip =request.zos.cgi.remote_addr;
	ts.member_updated_datetime=ts.user_updated_datetime;
	ts.member_address=application.zcore.functions.zso(ts, 'user_street');
	ts.member_address2=application.zcore.functions.zso(ts, 'user_street2');
	ts.member_city=application.zcore.functions.zso(ts, 'user_city');
	ts.member_state=application.zcore.functions.zso(ts, 'user_state');
	ts.member_zip=application.zcore.functions.zso(ts, 'user_zip');
	ts.member_country=application.zcore.functions.zso(ts, 'user_country');
	ts.member_phone=application.zcore.functions.zso(ts, 'user_phone');
	ts.member_fax=application.zcore.functions.zso(ts, 'user_fax');
	ts.member_affiliate_opt_in=application.zcore.functions.zso(ts, 'user_pref_sharing');
	ts.member_first_name = application.zcore.functions.zso(ts, 'user_first_name');
	ts.member_last_name = application.zcore.functions.zso(ts, 'user_last_name');
	if(not structkeyexists(ts, 'user_email') or not application.zcore.functions.zEmailValidate(ts.user_email)){
		throw("struct.user_email must be a valid email address");
	} 
	ts.user_username=ts.user_email;
	ts.sendConfirmOptIn=false; 
	ts.site_id=application.zcore.functions.zso(ts, 'site_id', false, request.zos.globals.id); 
	request.zDisableNewMemberEmail=true;
	return this.add(ts);
	</cfscript>
</cffunction>
	
	<!--- userCom.delete(user_id, site_id); --->
	<cffunction name="delete" localmode="modern" output="false" returntype="any">
		<cfargument name="user_id" type="string" required="yes">
		<cfargument name="site_id" type="string" required="yes">
		<cfscript>
		var qDelete = "";
		var db=request.zos.queryObject;
		var local=structnew();
		</cfscript>
		<cfsavecontent variable="db.sql">
		DELETE FROM #db.table("user", request.zos.zcoreDatasource)#  
		WHERE user_id = #db.param(arguments.user_id)# and 
		user_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#
		</cfsavecontent><cfscript>qDelete=db.execute("qDelete");</cfscript>
		<cfreturn true>
	</cffunction>
	</cfoutput>
</cfcomponent>