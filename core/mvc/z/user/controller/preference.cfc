<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" output="yes">
	<cfscript>
	var zpagenav=0;
	var userGroupAdminCom=0;
	var db=request.zos.queryObject;
	var ugid=0;
	if(structkeyexists(form,"x_ajax_id")){
		application.zcore.functions.zHeader("x_ajax_id",form.x_ajax_id);
	}
	form.e=trim(application.zcore.functions.zso(form, 'e'));
	if(form.e EQ ""){
		form.e=trim(application.zcore.functions.zso(form, 'user_email'));
	}
	form.k=application.zcore.functions.zso(form, 'k');
	variables.nowDate = now();
	request.zscriptname="/z/user/preference/index";
	variables.emailfrom1=request.fromemail;
	form.redirectOnLogin=application.zcore.functions.zso(form, 'redirectOnLogin',false);
	form.reloadOnNewAccount=application.zcore.functions.zso(form, 'reloadOnNewAccount',false,0);
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',false,0);
	if(form.modalpopforced EQ 1){
		application.zcore.template.setTag("pagetitle","User Registration");
		application.zcore.template.setTag("title","User Registration");
		application.zcore.functions.zSetModalWindow();
	}
	savecontent variable="zpagenav"{
		writeoutput('<a href="/">Home</a> / <a href="/z/user/home/index">User Dashboard</a> / ');
		if(application.zcore.functions.zso(form, 'e') NEQ ''){
			writeoutput('<a href="/z/user/preference/index">Communication Preferences</a> /');
		}
	}
	application.zcore.template.setTag("title","Edit Profile");
	application.zcore.template.setTag("pagetitle","Edit Profile");
	application.zcore.template.setTag("pagenav",zpagenav);
	if(form.e NEQ '' and isDefined('request.zsession.user.email') and form.e NEQ request.zsession.user.email){
		if(structkeyexists(form,"x_ajax_id") EQ false){
			application.zcore.user.logOut();
		}
	}
	userGroupAdminCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	ugid=userGroupAdminCom.getGroupId("user");
	db.sql="select * FROM #db.table("user", request.zos.zcoreDatasource)# user 
	where user_username = #db.param(form.e)# and 
	user_deleted = #db.param(0)# and
	#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# ";
	variables.qcheckemail=db.execute("qcheckemail");
	variables.secureLogin=false;
	if(form.e EQ '' and form.k EQ '' and  structkeyexists(request.zsession, "user") and structkeyexists(request.zos.userSession.groupAccess, "user")){
		db.sql="select * FROM #db.table("user", request.zos.zcoreDatasource)# user
		where user_id = #db.param(request.zsession.user.id)# and 
		site_id=#db.param(request.zsession.user.site_id)# and 
		user_deleted=#db.param(0)# ";
		variables.qcheckemail=db.execute("qcheckemail");

		variables.secureLogin=true;
		form.e=variables.qcheckemail.user_email;
		variables.secureLogin=true;
	}else if(variables.qcheckemail.recordcount NEQ 0 and form.e NEQ ''){
		if(variables.qcheckemail.user_server_administrator EQ 1){
			if(structkeyexists(form,"x_ajax_id")){
				writeoutput('{success:false,errorMessage:"The email address, #form.e#, can''t be updated through this interface because you are a server administrator."}');
				application.zcore.functions.zabort();		
			}else{
				application.zcore.status.setStatus(request.zsid, "The email address, #form.e#, can't be updated through this interface because you are a server administrator.",true);
				application.zcore.functions.zRedirect("/z/user/preference/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&zsid=#request.zsid#");
			}
		}
		if(structkeyexists(form, 'user_password') EQ false){
			form.user_password=variables.qcheckemail.user_password;
		}
		if(structkeyexists(form, 'user_username') EQ false){
			form.user_username=variables.qcheckemail.user_username;
		}
		if(trim(variables.qcheckemail.user_key) EQ ''){
			form.user_key = hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha');
			db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
			set user_key =#db.param(form.user_key)#,
			user_updated_datetime=#db.param(request.zos.mysqlnow)# 
			WHERE user_id = #db.param(variables.qcheckemail.user_id)# and 
			site_id=#db.param(variables.qcheckemail.site_id)# and 
			user_deleted=#db.param(0)# ";
			addKey=db.execute("addKey");
		}
		if(structkeyexists(request.zsession, "user") and structkeyexists(request.zos.userSession.groupAccess, "user")){
			if(form.e NEQ request.zsession.user.email){
				application.zcore.user.logOut();
			}else{
				variables.secureLogin=request.zsession.secureLogin;
			}
		}else if(form.k NEQ ''){
			if(variables.qcheckemail.user_key EQ form.k){
				variables.secureLogin=false;
				inputStruct = StructNew();
				inputStruct.user_group_name = "user";
				inputStruct.noRedirect=true;
				inputStruct.noLoginForm=true;
				inputStruct.disableSecurePassword=true;
				inputStruct.site_id = request.zos.globals.id;
				application.zcore.user.checkLogin(inputStruct); 
				if(structkeyexists(request.zsession, "user") and structkeyexists(request.zos.userSession.groupAccess, "user")){
				    variables.secureLogin=true;
				}else{
					structdelete(form, 'user_username');
					structdelete(form, 'user_password');	
				}
			}else{
				// this prevents login abuse
				application.zcore.user.setloginlog(0);
				structdelete(form, 'user_username');
				structdelete(form, 'user_password');	
			}
		}
	}
	if(structkeyexists(request.zsession, 'secureLogin') and request.zsession.secureLogin EQ false){
		variables.secureLogin=false;
	}
	/*if(variables.qcheckemail.recordcount NEQ 0){
		if(structkeyexists(form, 'npw') and trim(variables.qcheckemail.user_password_new) NEQ ''){
			form.user_updated_datetime = request.zos.mysqlnow;
			db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
			SET user_password = #db.param(variables.qcheckemail.user_password_new)#, 
			user_password_version = #db.param(variables.qcheckemail.user_password_new_version)#,
			user_salt = #db.param(variables.qcheckemail.user_password_new_salt)#,
			user_password_new = #db.param('')#,
			user_password_new_version = #db.param('')#,
			user_password_new_salt = #db.param('')#,
			user_updated_ip = #db.param(request.zos.cgi.remote_addr)#, 
			user_updated_datetime = #db.param(form.user_updated_datetime)#, 
			member_password = #db.param(variables.qcheckemail.user_password_new)# 
			WHERE user_username = #db.param(form.e)# and 
			user_deleted = #db.param(0)# and
			#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# ";
			qP=db.execute("qP");
			
			form.zusername=variables.qcheckemail.user_username;
			form.zpassword=variables.qcheckemail.user_password_new;
			inputStruct = StructNew();
			inputStruct.user_group_name = "user";
			inputStruct.noRedirect=true;
			inputStruct.secureLogin=false;
			inputStruct.disableSecurePassword=true;
			inputStruct.noLoginForm=true;
			inputStruct.site_id = request.zos.globals.id;
			// perform check 
			application.zcore.user.checkLogin(inputStruct); 
			variables.secureLogin=true;
			application.zcore.status.setStatus(request.zsid, "Password has been reset.");
			application.zcore.functions.zRedirect("/z/user/home/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
		}
	}*/
	if(request.zos.originalURL NEQ "/z/user/out/update"){
		if(variables.secureLogin and variables.qcheckemail.recordcount NEQ 0){
			if(structkeyexists(form, 'nea') and trim(variables.qcheckemail.user_email_new) NEQ ''){
				form.user_updated_datetime = request.zos.mysqlnow;
				
				if(application.zcore.app.siteHasApp("listing")){
					request.zos.listing.functions.zMLSSearchOptionsUpdateEmail(variables.qcheckemail.user_email,variables.qcheckemail.user_email_new);
				}
				db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
				SET user_confirm=#db.param('1')#, 
				user_username = #db.param(variables.qcheckemail.user_email_new)#, 
				user_email = #db.param(variables.qcheckemail.user_email_new)#, 
				user_email_new = #db.param('')#, 
				user_updated_ip = #db.param(request.zos.cgi.remote_addr)#, 
				user_updated_datetime = #db.param(form.user_updated_datetime)#, 
				user_confirm_ip = #db.param(request.zos.cgi.remote_addr)#, 
				user_confirm_datetime = #db.param(form.user_updated_datetime)# , 
				member_email = #db.param(variables.qcheckemail.user_email_new)# 
				WHERE user_username = #db.param(form.e)# and 
				user_deleted = #db.param(0)# and
				#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())#";
				qP=db.execute("qP");
				
				form.zusername=variables.qcheckemail.user_email_new;
				form.zpassword=variables.qcheckemail.user_password;
				inputStruct = StructNew();
				inputStruct.user_group_name = "user";
				inputStruct.noRedirect=true;
				inputStruct.noLoginForm=true;
				inputStruct.disableSecurePassword=true;
				inputStruct.site_id = request.zos.globals.id;
				// perform check 
				application.zcore.user.checkLogin(inputStruct); 
				variables.secureLogin=true;
				application.zcore.status.setStatus(request.zsid, "Your new email address, #variables.qcheckemail.user_email_new#, has been confirmed.");
				application.zcore.functions.zRedirect("/z/user/home/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(variables.qcheckemail.user_email_new)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
			}
		}
	}
	</cfscript>
</cffunction>

<cffunction name="accountcreated" localmode="modern" access="remote" output="yes">
	<cfscript>
	this.init();
	
	application.zcore.template.setTag("title","Account Created");
	application.zcore.template.setTag("pagetitle","Account Created");
	</cfscript>
	<!--- <p>Please confirm your new account by clicking the link in the email we send you.</p> --->
	<cfif form.modalpopforced EQ 1>
		<p>Closing window in 3 seconds.</p>
		<script type="text/javascript">
		/* <![CDATA[ */ 
		setTimeout(function(){ zCloseThisWindow(true); },3000);
		/* ]]> */
		</script>
	<cfelse>
		<p>You have been logged in to your new account.</p>
	</cfif>
</cffunction>

<cffunction name="update" localmode="modern" access="remote">
	<cfscript>
	var inputStruct=0;
	var db=request.zos.queryObject;
	var local=structnew();
	var qcheckemail10=0;
	this.init();
	form.submitPref=application.zcore.functions.zso(form, 'submitPref',false,'Update Communication Preferences');
	form.returnurl=application.zcore.functions.zso(form, 'returnurl');


	
	form.user_password=trim(replace(application.zcore.functions.zso(form, 'user_password'),chr(160),"","all"));
	if(trim(form.user_password) EQ ''){
		structdelete(variables, 'user_password');
		structdelete(form,  'user_password');		
		structdelete(form, 'user_password');
	}
	
	if(len(trim(application.zcore.functions.zso(form, 'e'))) EQ 0 or application.zcore.functions.zEmailValidate(form.e) EQ false){
		if(structkeyexists(form, 'x_ajax_id')){
			writeoutput('{success:false,errorMessage:"Email Address is required."}');
			application.zcore.functions.zabort();		
		}else{
			application.zcore.status.setStatus(request.zsid, "Email Address is required.",false,true);
			application.zcore.functions.zRedirect("/z/user/preference/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&zsid=#request.zsid#");
		}
	}

	// secure the member_signature html, and limit which tags are allowed.
	form.member_signature=application.zcore.email.cleanHTML(application.zcore.functions.zso(form, 'member_signature'));
	
	if(form.submitPref EQ 'Create Password'){
		form.submitPref ='Update Communication Preferences';
	}
	db.sql="select * FROM #db.table("user", request.zos.zcoreDatasource)# user 
	where user_username = #db.param(form.e)# and 
	user_deleted = #db.param(0)# and
	#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# ";
	qcheckemail10=db.execute("qcheckemail10");
	if(qcheckemail10.recordcount neq 0 and (form.submitPref EQ 'Login' or (form.submitPref EQ 'Update Communication Preferences' and trim(application.zcore.functions.zso(form, 'user_password')) NEQ ''))){
        	if(trim(application.zcore.functions.zso(form, 'user_password')) NEQ '' and variables.secureLogin eq false){
			// set checkLogin options
			form.zusername=qcheckemail10.user_username;
			form.zpassword=form.user_password;
			inputStruct = StructNew();
			inputStruct.user_group_name = "user";
			inputStruct.noRedirect=true;
			inputStruct.noLoginForm=true;
			inputStruct.site_id = request.zos.globals.id;
			// perform check 
			application.zcore.user.checkLogin(inputStruct); 
			if(structkeyexists(request.zos.userSession.groupAccess, "user")){
				if(form.submitPref NEQ 'Update Communication Preferences'){
					application.zcore.status.setStatus(request.zsid, "Login successful");
					application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
				}
				variables.secureLogin=true;
			}
		}
		if(variables.secureLogin EQ false){
			application.zcore.user.logOut(true);
			application.zcore.status.setStatus(request.zsid, "This email address and password combination is not a valid login.  Please try again or click reset password.",true);
			application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
		}
	}
	/*if(form.submitPref EQ "Reset Password"){
		if(qcheckemail10.recordcount EQ 0){
			if(structkeyexists(form, 'x_ajax_id')){
				writeoutput('{success:false,errorMessage:"No user account exists for the email address provided."}');
				application.zcore.functions.zabort();		
			}else{
				application.zcore.status.setStatus(request.zsid, "No user account exists for the email address provided.",false,true);
				application.zcore.functions.zRedirect("/z/user/preference/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&zsid=#request.zsid#");
			}
		}else if(qcheckemail10.user_openid_required EQ 1){
			if(structkeyexists(form, 'x_ajax_id')){
				writeoutput('{success:false,errorMessage:"This account requires OpenID authentication.  Password login has been disabled."}');
				application.zcore.functions.zabort();		
			}else{
				application.zcore.status.setStatus(request.zsid, "This account requires OpenID authentication.  Password login has been disabled.",false,true);
				application.zcore.functions.zRedirect("/z/user/preference/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&zsid=#request.zsid#");
			}
		}else{
			this.resetPasswordUpdate();
		}
	}else */
	if(form.submitPref EQ "Update Communication Preferences"){ 
		this.updatePreferences();
	}else if(form.submitPref EQ "Unsubscribe"){
		this.unsubscribeUpdate();
	}
	</cfscript>
</cffunction>
<!--- 
<cffunction name="resetPasswordUpdate" localmode="modern" access="private">
	<cfscript>
	var qP=0;
	var db=request.zos.queryObject;
	if(len(trim(application.zcore.functions.zso(form, 'user_password'))) LT 8){
		if(structkeyexists(form, 'x_ajax_id')){
			writeoutput('{success:false,errorMessage:"Please type your new password before clicking \"Reset Password\". Your password must be 8 or more characters."}');
			application.zcore.functions.zabort();		
		}else{
			application.zcore.status.setStatus(request.zsid, "Please type your new password before clicking ""Reset Password"". Your password must be 8 or more characters.",form,true);
			application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
		}
	}
	form.user_password_new_salt=application.zcore.functions.zGenerateStrongPassword(256,256);
	form.user_password_new_version=request.zos.defaultPasswordVersion;
	if(request.zos.globals.plainTextPassword EQ 0){
		form.user_password=application.zcore.user.convertPlainTextToSecurePassword(form.user_password, form.user_password_new_salt, form.user_password_new_version, false);
	}else{
		form.user_password_new_version=0;
		form.user_password_new_salt="";
	}
	if(trim(form.user_password) EQ variables.qcheckemail.user_password){
		form.zusername=variables.qcheckemail.user_username;
		form.zpassword=form.user_password;
		inputStruct = StructNew();
		inputStruct.user_group_name = "user";
		inputStruct.noRedirect=true;
		inputStruct.noLoginForm=true;
		
		if(isDefined('request.zsession.user.site_id')){
			inputStruct.site_id = request.zsession.user.site_id;
		}else{
			inputStruct.site_id=request.zos.globals.id;
		}
		// perform check 
		application.zcore.user.checkLogin(inputStruct); 
		application.zcore.status.setStatus(request.zsid, "The new password is the same as the old password and no change has been made.");
		if(structkeyexists(request.zos.userSession.groupAccess, "user")){
			application.zcore.status.setStatus(request.zsid, "Login successful");
			variables.secureLogin=true;
		}
		if(structkeyexists(form, 'x_ajax_id')){
			writeoutput('{success:false,errorMessage:"The new password is the same as the old password and no change has been made."}');
			application.zcore.functions.zabort();		
		}else{
			application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
		}
	}
	var user_key=hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256'); 
	db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
	SET user_password_new = #db.param(form.user_password)#, 
	user_password_new_salt= #db.param(form.user_password_new_salt)#, 
	user_password_new_version= #db.param(form.user_password_new_version)#, 
	user_confirm_count=#db.param(1)#, 
	user_key=#db.param(user_key)#,
	user_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE user_username = #db.param(form.e)# and 
	user_deleted = #db.param(0)# and
	#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# ";
	qP=db.execute("qP");
	db.sql="select * from  #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_id = #db.param(variables.qcheckemail.user_id)# and 
	site_id= #db.param(variables.qcheckemail.site_id)# and
	user_deleted = #db.param(0)# ";
	variables.qcheckemail=db.execute("qcheckemail");
	mail  charset="utf-8" to="#form.e#" from="#variables.emailfrom1#" subject="Reset Password for #application.zcore.functions.zvar('shortdomain')#"{
		writeoutput('Hello,

A request to reset the password for #form.e# has been made from #request.zos.currentHostName#.

If you agree to reset the password, please click the link below. 

#request.zos.currentHostName#/z/-erp#variables.qcheckemail.user_id#.#variables.qcheckemail.user_key# 

If the link does not work, please copy and paste the entire link in your browser''s address bar and hit enter.    If you did not make this request, you can ignore this email.');
	}
	if(structkeyexists(form, 'x_ajax_id')){
		writeoutput("{success:true}");
		application.zcore.functions.zabort();		
	}else{
		application.zcore.status.setStatus(request.zsid, "An email was sent to #form.e#.  Please check your email and click the link in that email in order to update your password.");
		application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&zsid=#request.zsid#&e=#urlencodedformat(form.e)#");
	}
	</cfscript>
</cffunction> --->

<cffunction name="updatePreferences" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject;
	var arrPref=0;
	var userGroupCom=0;
	var loginStruct=0;
	var addKey=0;
	var rs=0;
	var ts=0;
	var useraddednow=false;
	var inputStruct=0;
	var sendConfirmEmail=true;
	var sendEmailChangeEmail=false;
	var qU=0;
	if(variables.qcheckemail.recordcount NEQ 0 and variables.secureLogin EQ false){
		application.zcore.status.setStatus(request.zsid,"The email/password combination was incorrect. Try again or reset your password to continue.");
		application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&zsid=#request.zsid#&e=#application.zcore.functions.zso(form, 'user_email')#");
	}
	if(structkeyexists(form,'e')){
		form.user_email=form.e;	
	}
	arrPref = arraynew(1);
	form.user_updated_datetime = dateformat(variables.nowDate, "yyyy-mm-dd")&" "&timeformat(variables.nowDate, "HH:mm:ss");
	form.user_updated_ip =request.zos.cgi.remote_addr;
	if(isDefined('request.zsession.user.site_id')){
		form.site_id = request.zsession.user.site_id;
	}else{
		form.site_id=request.zos.globals.id;
	}
	structdelete(form, 'user_site_administrator');
	structdelete(form, 'user_server_administrator');
	structdelete(form, 'user_group_id');
	structdelete(form, 'user_parent_id');
	//form.user_email = form.e;
	inputStruct = StructNew();
	inputStruct.table = 'user';
	inputStruct.datasource = '#request.zos.zcoreDatasource#';
	inputStruct.struct=form;
	if(variables.qcheckemail.recordcount EQ 0 or variables.qcheckemail.user_confirm_count GTE 3){
		form.user_confirm_count=1;
	}
	// create member record so the login will work
	form.member_updated_datetime=form.user_updated_datetime;
	form.member_address=application.zcore.functions.zso(form, 'user_street');
	form.member_address2=application.zcore.functions.zso(form, 'user_street2');
	form.member_city=application.zcore.functions.zso(form, 'user_city');
	form.member_state=application.zcore.functions.zso(form, 'user_state');
	form.member_zip=application.zcore.functions.zso(form, 'user_zip');
	form.member_country=application.zcore.functions.zso(form, 'user_country');
	form.member_phone=application.zcore.functions.zso(form, 'user_phone');
	form.member_fax=application.zcore.functions.zso(form, 'user_fax');
	form.member_affiliate_opt_in=application.zcore.functions.zso(form, 'user_pref_sharing');
	form.member_first_name = application.zcore.functions.zso(form, 'user_first_name');
	form.member_last_name = application.zcore.functions.zso(form, 'user_last_name');

	arrEmail=listToArray(application.zcore.functions.zso(form, 'user_alternate_email'), ",");
	arrEmail2=[];
	fail=false;
	for(i=1;i<=arraylen(arrEmail);i++){
		e=trim(arrEmail[i]);
		if(e NEQ ""){
			if(not application.zcore.functions.zEmailValidate(e)){
				fail=true;
				application.zcore.status.setStatus(Request.zsid, e&" is not a valid email",form,true);
			}else{
				arrayAppend(arrEmail2, e);
			}
		}
	}
	if(fail){
		application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
	}
	form.user_alternate_email=arrayToList(arrEmail2, ",");
	
	/*
	// we should never remove a contact record - this is legacy code
	db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)#  
	where contact_email=#db.param(form.user_email)# and 
	contact_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)#";
	qU=db.execute("qU"); 
	if(qU.recordcount NEQ 0){
		db.sql="update #db.table("contact", request.zos.zcoreDatasource)#  
		set contact_deleted = #db.param(qU.contact_id)#,
		contact_updated_datetime=#db.param(request.zos.mysqlnow)#
		where contact_id=#db.param(qU.contact_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		contact_deleted=#db.param(0)# ";
		db.execute("q"); 
	}
	*/
	
	form.user_salt=application.zcore.functions.zGenerateStrongPassword(256,256);

	
	if(variables.qcheckemail.recordcount eq 0){
		if(len(trim(application.zcore.functions.zso(form, 'user_password'))) LT 8){
			application.zcore.status.setStatus(request.zsid, "Your password must be 8 or more characters.",form,true);
			application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
		}
		form.user_confirm_count=1;
		form.user_active=1;
		form.user_key=hash(form.user_salt, "sha");
		form.user_password_version = request.zos.defaultPasswordVersion;
		if(request.zos.globals.plainTextPassword EQ 0){
			form.user_password=application.zcore.user.convertPlainTextToSecurePassword(form.user_password, form.user_salt, request.zos.defaultPasswordVersion, false);
		}else{
			form.user_password_version=0;
			form.user_salt="";	
		}
	
		userGroupCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.user_group_admin");
		form.user_group_id=userGroupCom.getGroupId("user");
		form.user_username=form.user_email;
		form.user_sent_datetime=form.user_updated_datetime;
		form.user_created_datetime = form.user_updated_datetime;
		form.user_created_ip = request.zos.cgi.remote_addr;
		form.member_active='1';
		form.member_created_datetime=form.user_updated_datetime;
		form.member_email = application.zcore.functions.zso(form, 'user_email');
		form.member_password = application.zcore.functions.zso(form, 'user_password');
		
		form.user_id = application.zcore.functions.zInsert(inputStruct);
		useraddednow=true;
		if(form.user_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to set your preferences, please try again",form,true);
			application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
		}			
		form.zusername=form.user_email;
		form.zpassword=form.user_password;
		loginStruct = StructNew();
		loginStruct.user_group_name = "user";
		loginStruct.disableSecurePassword=true;
		loginStruct.noRedirect=true;
		loginStruct.noLoginForm=true;
		loginStruct.site_id = request.zos.globals.id;
		
		
		application.zcore.tracking.setUserEmail(application.zcore.functions.zso(form, 'user_email'));
		application.zcore.tracking.setConversion('new user');
		// perform check 
		local.rs=application.zcore.user.checkLogin(loginStruct); 
		variables.secureLogin=true;
		sendConfirmEmail=false;
		application.zcore.functions.zSendUserAutoresponder(form.user_id);
	}else{
		if(trim(application.zcore.functions.zso(form, 'user_password')) EQ ''){
			structdelete(form,'user_password');
			structdelete(variables,'user_password');
			structdelete(url,'user_password');
			structdelete(form,'user_salt');
			structdelete(variables,'user_salt');
			structdelete(url,'user_salt');
		}
	
		if(structkeyexists(form, 'user_email') and application.zcore.functions.zEmailValidate(form.user_email) EQ false){
			application.zcore.status.setStatus(request.zsid, "#form.user_email# is not a valid email address.  Please update and try again.",form,true);
			application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
		}
		if(structkeyexists(form, 'user_password') and trim(form.user_password) NEQ '' and len(trim(application.zcore.functions.zso(form, 'user_password'))) LT 8){
			application.zcore.status.setStatus(request.zsid, "Your password must be 8 or more characters.",form,true);
			application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
		}
		form.user_password_version = request.zos.defaultPasswordVersion;
		if(request.zos.globals.plainTextPassword EQ 0){
			if(application.zcore.functions.zso(form, 'user_password') NEQ ""){
				form.user_password=application.zcore.user.convertPlainTextToSecurePassword(form.user_password, form.user_salt, request.zos.defaultPasswordVersion, false);
			}
		}else{
			form.user_password_version=0;
			form.user_salt="";
		}
		if(trim(application.zcore.functions.zso(form, 'user_password')) NEQ '' and (form.user_password EQ variables.qcheckemail.user_password or variables.qcheckemail.user_password EQ '')){
			// force login
			form.zusername=form.user_email;
			form.zpassword=form.user_password;
			loginStruct = StructNew();
			loginStruct.user_group_name = "user";
			loginStruct.noLoginForm=true;
			loginStruct.disableSecurePassword=true;
			loginStruct.noRedirect=true;
			loginStruct.site_id = request.zos.globals.id;
			// perform check 
			application.zcore.user.checkLogin(loginStruct); 
			variables.secureLogin=true;
		}
	
		if(structkeyexists(form, 'user_email') and form.user_email NEQ variables.qcheckemail.user_email){
			db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_email =#db.param(form.user_email)# and 
			user_deleted = #db.param(0)# and 
			#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())#";
			qU=db.execute("qU"); 
			if(qU.recordcount NEQ 0){
				application.zcore.status.setStatus(request.zsid, "Your email address can't be changed to #form.user_email# because this email address is already used for a different account.",form,true);
				application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
			}
			// email changed - need to reset opt-in status until new address is confirmed.
			form.user_email_new=form.user_email;
			form.user_email=variables.qcheckemail.user_email;
			form.user_confirm_count=1;
			application.zcore.status.setStatus(request.zsid, "We sent an email to both the new and old email addresses to confirm your changes.   In order to receive mailings at your new email address, you must click the confirmation link in the email.");
			sendEmailChangeEmail=true;				
		}
		form.user_id = variables.qcheckemail.user_id;
		// sync member table with user
		if(trim(application.zcore.functions.zso(form, 'user_password')) NEQ '' and variables.qcheckemail.user_password NEQ form.user_password){
			form.member_password = application.zcore.functions.zso(form, 'user_password');
		}
		if(structkeyexists(form, 'user_openid_required') EQ false){
			form.user_openid_required=0;
		}
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to set your preferences, please try again",form,true);
			application.zcore.functions.zRedirect("/z/user/preference/form?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(variables.qcheckemail.user_key)#&zsid=#request.zsid#");
		}
	}
	if(useraddednow){
		ts=structnew();
		ts.leadEmail=form.user_email;
		rs=application.zcore.functions.zGetNewMemberLeadRouteStruct(ts);

		if(application.zcore.functions.zso(request.zos.globals, 'disableNewUserEmail', true, 0) NEQ 1 and structkeyexists(request, 'fromemail') and structkeyexists(request, 'officeemail') and structkeyexists(request, 'zDisableNewMemberEmail') EQ false){
			mail   charset="utf-8" from="#request.fromemail#" to="#rs.assignEmail#" cc="#rs.cc#" subject="New User on #request.zos.globals.shortdomain#"{
writeoutput('New User on #request.zos.globals.shortdomain# User E-Mail Address: #form.user_username# This user has signed up as a user on your web site.   This is not a direct sales inquiry.

To view more info about this new user, click the following link: 

#request.zos.currentHostName#/z/admin/member/edit?user_id=#form.user_id#');
			}
		}
	}
	if(variables.qcheckemail.recordcount eq 0){
		form.user_key = hash(dateformat(variables.nowDate, "yyyymmdd")&timeformat(variables.nowDate, "hhmmss")&'_'&form.user_id, 'sha-256');
		db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
		set user_key =#db.param(form.user_key)#,
		user_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE user_username = #db.param(form.e)# and 
		user_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)# ";
		addKey=db.execute("addKey");
		db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user_username = #db.param(form.e)# and 
		user_deleted = #db.param(0)# and
		site_id=#db.param(request.zos.globals.id)#";
		qU=db.execute("qU"); 
		form.user_id=qU.user_id;
		form.user_key=qU.user_key;
	}else{
		form.user_id=variables.qcheckemail.user_id;
		form.user_key = variables.qcheckemail.user_key;
	}
	if(sendEmailChangeEmail){
		mail  charset="utf-8" to="#form.user_email_new#" cc="#form.user_email#" from="#variables.emailfrom1#" subject="Please confirm your registration."{
			writeoutput('Hello,

You''ve asked to change your email address from #form.user_email# to #form.user_email_new#.  In order to ensure your privacy, we request that you confirm your change by clicking the link below. 

#request.zos.currentHostName#/z/-ece#form.user_id#.#form.user_key# 

If the link does not work, please copy and paste the entire link in your browser''s address bar and hit enter.  If you did not make this request, you can ignore this email.');
		}
	}else if(sendConfirmEmail and variables.qcheckemail.recordcount EQ 0 or (variables.qcheckemail.user_pref_list EQ '0' and application.zcore.functions.zso(form, 'user_pref_list',false,0) EQ '1')){
		// send a confirmation email if the mailing list status has changed or if this is a new user. 
		mail  charset="utf-8" to="#form.e#" from="#variables.emailfrom1#" subject="Please confirm your registration."{
			writeoutput('Hello,

Thank you for you interest in joining our mailing list.  In order to ensure your privacy, we request that you confirm your request by clicking the link below. 

#request.zos.currentHostName#/z/-ein#form.user_id#.#form.user_key# 

If the link does not work, please copy and paste the entire link in your browser''s address bar and hit enter.    If you did not make this request, you can ignore this email.');
		}
	}
	if(form.reloadOnNewAccount EQ 1){
		application.zcore.status.setStatus(request.zsid, "Your preferences have been updated.");
		application.zcore.functions.zRedirect("/z/user/preference/accountcreated?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&zsid=#request.zsid#");
	}else{
		application.zcore.status.setStatus(request.zsid, "Your preferences have been updated.");
		application.zcore.functions.zRedirect("/z/user/home/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&zsid=#request.zsid#");
	}
        </cfscript>
</cffunction>

<cffunction name="unsubscribeUpdate" localmode="modern" access="private">
	<cfscript>	
	var db=request.zos.queryObject;	
	var userGroupCom=0;
	form.e=application.zcore.functions.zso(form, 'e');
	if(application.zcore.functions.zEmailValidate(form.e) EQ false){
		application.zcore.status.setStatus(request.zsid, "Invalid email address");
		application.zcore.functions.zRedirect("/z/user/preference/index?zsid=#request.zsid#");	
	}
	form.user_salt=application.zcore.functions.zGenerateStrongPassword(256,256);
	form.contact_key=hash(form.user_salt, "sha-256");
	db.sql="INSERT INTO #db.table("contact", request.zos.zcoreDatasource)# (contact_confirm , contact_opt_in, contact_email,contact_key, 
	site_id , contact_sent_datetime , contact_datetime , contact_confirm_datetime , contact_confirm_count, contact_updated_datetime, contact_opt_out, contact_deleted)
	VALUES( #db.param(0)#, #db.param(0)#, #db.param(form.e)#, #db.param(form.contact_key)#, 
	#db.param(request.zos.globals.id)#, #db.param(request.zos.mysqlnow)#, #db.param(request.zos.mysqlnow)#, 
	#db.param(request.zos.mysqlnow)#, #db.param(3)#, #db.param(request.zos.mysqlnow)#, #db.param(1)#, #db.param(0)# )
	
	ON DUPLICATE KEY UPDATE contact_opt_in=#db.param('0')#, 
	contact_opt_out=#db.param(1)#, 
	contact_confirm_count=#db.param(3)#,  
	contact_deleted=#db.param(0)#, 
	contact_confirm_datetime = #db.param(request.zos.mysqlnow)# ";
	db.execute("qInsert");
	if(variables.qcheckemail.recordcount NEQ 0){
		form.user_updated_datetime = request.zos.mysqlnow;
		userGroupCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
		form.user_group_id=userGroupCom.getGroupId("user");
		form.user_key=hash(form.user_salt, "sha");
		form.user_password=application.zcore.functions.zGenerateStrongPassword(10,20);
		form.user_password_version =request.zos.defaultPasswordVersion;
		if(request.zos.globals.plainTextPassword EQ 0){
			form.user_password=application.zcore.user.convertPlainTextToSecurePassword(form.user_password, form.user_salt, request.zos.defaultPasswordVersion, false);
		}else{
			form.user_password_version=0;
			form.user_salt="";
		}
		db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
		set member_affiliate_opt_in=#db.param('0')#, 
		user_confirm=#db.param(0)#, 
		user_pref_list=#db.param('0')#, 
		user_pref_sharing=#db.param('0')#, 
		user_password_version = #db.param(form.user_password_version)#,
		user_updated_ip=#db.param(request.zos.cgi.remote_addr)#, 
		user_updated_datetime = #db.param(form.user_updated_datetime)#, 
		user_confirm_count=#db.param('3')# 
		where user_username = #db.param(form.e)# and 
		user_deleted = #db.param(0)# and
		#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())#";
		qUpdateOut=db.execute("qUpdateOut");
	}
	application.zcore.functions.zRedirect("/z/user/preference/unsubscribed?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#");
	</cfscript>
</cffunction>

<cffunction name="unsubscribed" localmode="modern" access="remote">
	<cfscript>
	this.init();
	</cfscript>
	<h2>You have been unsubscribed from our mailing list.</h2>
	<p>If you submit your contact information on our web site again or have used a different email account in the past to contact us, you may continue to receive mailings from us.  We won't know to remove you unless you click the opt-out link in the email or enter your email addresses in the <a href="/z/user/out/index">opt out form</a>.</p>
</cffunction>

<cffunction name="logout" localmode="modern" access="remote">
	<cfscript>
	this.init();
	</cfscript>
	<h2>You have been logged out, you may close your browser or continue browsing.</h2>
	<hr />
	<p><a href="/z/user/preference/index">Click here to login again.</a></p>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var loginCom=0;
	// init must run first because reset password and other features rely on this!
        this.init();
        application.zcore.functions.zStatusHandler(request.zsid);
	if(application.zcore.user.checkGroupAccess("user")){

		if(application.zcore.user.checkGroupAccess("user") and application.zcore.functions.zso(form, 'redirectOnLogin') NEQ ""){
			application.zcore.functions.zRedirect(form.redirectOnLogin);
		}else{
		  	application.zcore.functions.zRedirect("/z/user/home/index");
		}
	}
        application.zcore.template.setTag("title", "Your Account");
        application.zcore.template.setTag("pagetitle", "Your Account");
        </cfscript>
	<div style="display:none; clear:both; color:##000; font-size:120%;" id="statusDiv"></div>
	<cfif structkeyexists(form, 'returnURL')>
		<form name="zRepostForm" id="zRepostForm" method="get" action="#htmleditformat(form.returnURL)#">
	<cfelse>
		<form name="zRepostForm" id="zRepostForm" method="post" action="#htmleditformat("/z/user/home/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#")#">
	</cfif>
	</form>
	<div style="width:100%; float:left; padding-bottom:10px;">
		<div style="width:185px; float:left;">
			<cfscript>
		      loginCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.user.controller.login");
		      writeoutput(loginCom.displayLoginForm());
		      </cfscript>
		</div>
		<div style="width:300px; float:left;">
			<cfscript>
		      writeoutput(loginCom.displayOpenIdLoginForm(request.zos.currentHostName&"/z/user/preference/index?disableOpenIDLoginRedirect=1"));
		      </cfscript>
		</div>
	</div>
	<div class="zUserLoginCreateAccount zmember-openid-buttons" style="float:left; width:100%; padding-bottom:15px;width:100%;border-top:1px solid ##999; padding-top:15px;">
		<h3>If you don't have an account:</h3>
		<button type="submit" name="submitPref" value="Unsubscribe" onclick="window.location.href='/z/user/preference/register?modalpopforced=#form.modalpopforced#&amp;redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#'">Create Free Account</button>
	</div>
	<div class="zUserLoginUnsubscribe" style="float:left;width:100%; border-top:1px solid ##999; padding-top:15px;">
		<form class="zFormCheckDirty" name="getEmailUnsubscribe" action="/z/user/preference/update?modalpopforced=#form.modalpopforced#&amp;redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#" method="post">
			<h3>Unsubscribe From Our Mailing List</h3>
			<div class="zmember-openid-buttons">Email Address:&nbsp;<br />
				<input type="text" name="e" size="30" />
			</div>
			<div style="clear:both;" class="zmember-openid-buttons">
				<button type="submit" name="submitPref" value="Unsubscribe">Unsubscribe</button>
			</div>
		</form>
	</div>
</cffunction>

<cffunction name="form" localmode="modern" access="remote">
	<cfscript>
	var c2=0;
	var openIdCom=0;
	this.init();
	
	if(isdefined('variables.qcheckemail')){
		application.zcore.functions.zquerytostruct(variables.qcheckemail, form);
	}
	application.zcore.functions.zStatusHandler(request.zsid,true);
	
	if(form.e NEQ '' and application.zcore.functions.zEmailValidate(form.e) EQ false){
		application.zcore.status.setStatus(request.zsid, "#form.e# is not a valid email address.  Please check your spelling and try again (i.e. email@yourdomain.com)",form,true);
		application.zcore.functions.zRedirect("/z/user/preference/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
	}
	</cfscript>
	<cfif structkeyexists(form, 'zSignupMessage')>
		<h2>#form.zSignupMessage#</h2>
		<br />
	</cfif>
	<cfif variables.qcheckemail.recordcount eq 0>
		<cfelseif variables.qcheckemail.user_confirm EQ 0 and variables.qcheckemail.user_confirm_count GTE 3>
		<span style="font-size:130%; font-weight:bold;">You have been removed from our mailing list.<br />
		<br />
		To join our list again, you can update the form below.</span>
		<hr />
		<br />
	</cfif>
	
	<form class="zFormCheckDirty" name="defineContact" action="/z/user/preference/update?e=#urlencodedformat(form.e)#&amp;k=#urlencodedformat(form.k)#&amp;modalpopforced=#form.modalpopforced#&amp;redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#" method="post">
		<div style=" width:100%; float:left;">
		<cfif structkeyexists(form, 'custommarketingmessage')>
			<div style="width:100%;float:left;">#form.custommarketingmessage#</div>
		<cfelseif variables.qcheckemail.recordcount eq 0 and form.user_password EQ ''>
			<cfset c2=application.zcore.functions.zvarso("New Account Marketing Information")>
			<div style="width:100%;float:left;">
				<cfif c2 EQ "">
					<p>Please complete the form below to create an account on our web site.</p>
				<cfelse>
#c2#
				</cfif>
			</div>
		</cfif>
		<cfscript>
		openIdEnabled=true;
		if(request.zos.globals.disableOpenID EQ 1 or (request.zos.globals.parentID NEQ 0 and application.zcore.functions.zvar('disableOpenId', request.zos.globals.parentID) EQ 1)){
			openIdEnabled=false;
		}
		openIdCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.openid");
		</cfscript>
		<cfif openIdEnabled>
			<cfsavecontent variable="local.openIdOutput">
			<cfscript>
			writeoutput(openIdCom.displayOpenIdProviderForUser(variables.qcheckemail.user_id, variables.qcheckemail.site_id));
			</cfscript>
			</cfsavecontent>
		</cfif>
		<cfif variables.qcheckemail.recordcount eq 0 and form.user_password EQ ''>
			<div class="z-user-preference-left">
			<p style="font-size:130%; font-weight:bold;">Your Personal Information</p>
			<cfset local.hideAllPrefFields=false>
		<cfelseif openIdCom.isAdminChangeAllowed() EQ false>
			<h2>Please login again to verify your identity</h2>
			<div style="float:left; padding-right:0px;width:100%;">
			<cfset local.hideAllPrefFields=true>
		<cfelse>
			<div class="z-user-preference-left">
			<p style="font-size:130%; font-weight:bold;">Your Personal Information</p>
			<cfset local.hideAllPrefFields=false>
		</cfif>
		<cfif variables.qcheckemail.recordcount NEQ 0 and local.hideAllPrefFields>
			<cfif openIdEnabled>
			<div class="zmember-openid">#local.openIdOutput# </div>
			<br style="clear:both;" />
			<hr />
			</cfif>
			<h3><cfif openIdEnabled>Or </cfif>Login with your password:</h3>
			<div class="zmember-openid-buttons">Email: #form.e#</div>
			<br />
			<br />
			<div class="zmember-openid-buttons">Password:</div>
			<br />
			<div class="zmember-openid-buttons">
				<input type="password" name="user_password" value="" />
			</div>
			<br style="clear:both;" />
			<div class="zmember-openid-buttons">
				<cfif variables.qcheckemail.recordcount eq 0 or variables.qcheckemail.user_password EQ ''>
					<button type="submit" name="submitPref" value="Create Password" style="font-size:120%; padding:5px; margin-bottom:5px;">Create Password</button>
				<cfelse>
					<button type="submit" name="submitPref" value="Login" style="font-size:120%; padding:5px; margin-bottom:5px;">Login</button>
					<br />
					<button type="button" name="submitPref" onclick="window.location.href='/z/user/reset-password/index?email=#urlencodedformat(form.e)#';" value="Reset Password" style="font-size:120%; padding:5px; margin-bottom:5px;">Forgot password?</button>
				</cfif>
			</div>
			</div>
			<div class="zmember-openid-buttons">
				<button type="button" name="submitPref3" onclick="window.location.href='/z/user/preference/index?zlogout=1';" value="" style="font-size:120%; padding:5px; margin-bottom:5px;">Logout</button>
			</div>
			<cfif not openIdCom.isAdminChangeAllowed()>
				<cfset local.hideAllPrefFields=true>
			</cfif>
		<cfelse>
			<table style="border-spacing:0px; width:98%;" class="zinquiry-form-table">
				<tr>
					<td><span style=" font-weight:bold;">Email</span></td>
					<td><input type="text" name="user_email" style=" width:100%;" value="<cfif form.user_email EQ ''>#htmleditformat(form.e)#<cfelse>#htmleditformat(form.user_email)#</cfif>" /></td>
				</tr>
				<tr>
					<td><span style=" font-weight:bold;">Password</span>&nbsp;</td>
					<td><input type="password" style=" width:100%;" onclick="tempValue=this.value;this.value='';" onblur="if(this.value == ''){ this.value='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';}" name="user_password" value="<cfif len(form.user_password) NEQ 0>#(replace(ljustify('',8),' ','&nbsp;','ALL'))#</cfif>" /></td>
				</tr>
				<tr>
					<td><span style=" font-weight:bold;">Alternative Email(s)</span></td>
					<td><input type="text" name="user_alternate_email" style=" width:100%;" value="#htmleditformat(form.user_alternate_email)#" /><br />Note: you can separate multiple emails with commas.</td>
				</tr> 
				<tr>
					<td>First Name</td>
					<td><input type="text" name="user_first_name" value="#htmleditformat(form.user_first_name)#" style=" width:100%;" /></td>
				</tr>
				<tr>
					<td>Last Name</td>
					<td><input type="text" name="user_last_name" value="#htmleditformat(form.user_last_name)#" style=" width:100%;" /></td>
				</tr>
				<tr>
					<td>Company</td>
					<td><input type="text" name="member_company" value="#htmleditformat(form.member_company)#" style=" width:100%;" /></td>
				</tr>
				<tr>
					<td>Phone</td>
					<td><input type="text" name="user_phone" style=" width:100%;" value="#htmleditformat(form.user_phone)#" /></td>
				</tr>
				<tr>
					<td>Fax</td>
					<td><input type="text" name="user_fax" style=" width:100%;" value="#htmleditformat(form.user_fax)#" /></td>
				</tr>
				<tr>
					<td>Address&nbsp;</td>
					<td><input type="text" name="user_street" style=" width:100%;" value="#htmleditformat(form.user_street)#" /></td>
				</tr>
				<tr>
					<td>Address 2&nbsp;</td>
					<td><input type="text" name="user_street2" style=" width:100%;" value="#htmleditformat(form.user_street2)#" /></td>
				</tr>
				<tr>
					<td>City&nbsp;</td>
					<td><input type="text" name="user_city" style=" width:100%;" value="#htmleditformat(form.user_city)#" /></td>
				</tr>
				<tr>
					<td>State&nbsp;</td>
					<td><cfscript>
					writeoutput(application.zcore.functions.zStateSelect("user_state", application.zcore.functions.zso(form, 'user_state'), "width:100%;"));
					</cfscript></td>
				</tr>
				<tr>
					<td>Country&nbsp;</td>
					<td><cfscript>
					writeoutput(application.zcore.functions.zCountrySelect("user_country", application.zcore.functions.zso(form, 'user_country'), "width:100%;"));
					</cfscript></td>
				</tr>
				<tr>
					<td>Zip Code</td>
					<td><input type="text" name="user_zip" style=" width:100%;" value="#htmleditformat(form.user_zip)#" /></td>
				</tr>
				<tr>
					<td colspan="2">Email Signature&nbsp;<br> 

						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "member_signature";
						htmlEditor.value			= form.member_signature;
						htmlEditor.width			= "100%";
						htmlEditor.height		= 150;
						htmlEditor.createSimple();
						</cfscript>  
					</td>
				</tr>
			</table>
		</cfif>
		<cfif local.hideAllPrefFields EQ false>
			<cfif variables.qcheckemail.recordcount eq 0 and form.user_password EQ ''>
				<cfscript>
				    application.zcore.template.setTag("title","Create A Free Account");
				    application.zcore.template.setTag("pagetitle","Create A Free Account");
				    </cfscript>
			</cfif>
			</div>
			<div class="z-user-preference-right">
				<p style="font-size:130%; font-weight:bold;">How may we reach you?</p>
				<table style="border-spacing:0px; width:98%;" class="zinquiry-form-table">
					<tr>
						<td>Phone</td>
						<td><input type="radio" style="border:none; background:none;"  name="user_pref_phone"  value="1" <cfif form.user_pref_phone EQ '1' or form.user_pref_phone EQ ''>checked="checked"</cfif> />
							yes&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" style="border:none; background:none;"  name="user_pref_phone" value="0" <cfif form.user_pref_phone EQ '0'>checked="checked"</cfif> />
							no</td>
					</tr>
					<tr>
						<td>Email Mailing List</td>
						<td><input type="radio" style="border:none; background:none;"  name="user_pref_list" value="1" <cfif form.user_pref_list EQ '1' or form.user_pref_list EQ ''>checked="checked"</cfif> />
							yes&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" style="border:none; background:none;"  name="user_pref_list" value="0" <cfif form.user_pref_list EQ '0'>checked="checked"</cfif> />
							no</td>
					</tr>
					<tr>
						<td>Personal Emails</td>
						<td><input type="radio" style="border:none; background:none;"  name="user_pref_email" value="1" <cfif form.user_pref_email EQ '1' or form.user_pref_email EQ ''>checked="checked"</cfif> />
							yes&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" style="border:none; background:none;"  name="user_pref_email" value="0" <cfif form.user_pref_email EQ '0'>checked="checked"</cfif> />
							no</td>
					</tr>
					<tr>
						<td>Physical Mail</td>
						<td><input type="radio" style="border:none; background:none;"  name="user_pref_mail" value="1" <cfif form.user_pref_mail EQ '1' or form.user_pref_mail EQ ''>checked="checked"</cfif> />
							yes&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" style="border:none; background:none;"  name="user_pref_mail" value="0" <cfif form.user_pref_mail EQ '0'>checked="checked"</cfif> />
							no</td>
					</tr>
					<tr>
						<td>Fax</td>
						<td><input type="radio" style="border:none; background:none;"  name="user_pref_fax" value="1" <cfif form.user_pref_fax EQ '1' or form.user_pref_fax EQ ''>checked="checked"</cfif> />
							yes&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" style="border:none; background:none;"  name="user_pref_fax" value="0" <cfif form.user_pref_fax EQ '0'>checked="checked"</cfif> />
							no</td>
					</tr>
				</table>
				<cfif isDefined('request.realestateprefform')>
					<hr />
					Are you already working with another real estate professional?<br />
					<input type="radio" style="border:none; background:none;"  name="user_pref_realtor" value="1" <cfif form.user_pref_realtor EQ '1'>checked="checked"</cfif> />
					yes&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" style="border:none; background:none;"  name="user_pref_realtor" value="0" <cfif form.user_pref_realtor EQ '0' or form.user_pref_realtor EQ ''>checked="checked"</cfif> />
					no
					<hr />
					Would you like notified when there are <br />
					new Hot Deals?<br />
					<input type="radio" style="border:none; background:none;"  name="user_pref_hotdeals" value="1" <cfif form.user_pref_hotdeals EQ '1' or form.user_pref_hotdeals EQ ''>checked="checked"</cfif> />
					yes&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" style="border:none; background:none;"  name="user_pref_hotdeals" value="0" <cfif form.user_pref_hotdeals EQ '0'>checked="checked"</cfif> />
					no
				</cfif>
				<hr />
				Receive info on new products &amp; services?<br />
				<input type="radio" style="border:none; background:none;"  name="user_pref_new" value="1" <cfif form.user_pref_new EQ '1' or form.user_pref_new EQ ''>checked="checked"</cfif> />
				yes&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" style="border:none; background:none;"  name="user_pref_new" value="0" <cfif form.user_pref_new EQ '0'>checked="checked"</cfif> />
				no
				<cfif isDefined('request.realestateprefform') eq false>
					<hr />
					May we share your information with our partners who offer related services?<br />
					<input type="radio" style="border:none; background:none;"  name="user_pref_sharing" value="1" <cfif form.user_pref_sharing EQ '1'>checked="checked"</cfif> />
					yes&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" style="border:none; background:none;"  name="user_pref_sharing" value="0" <cfif form.user_pref_sharing EQ '0' or form.user_pref_sharing EQ ''>checked="checked"</cfif> />
					no
				</cfif>
				<hr />
				What email format do you prefer?<br />
				<input type="radio" style="border:none; background:none;"  name="user_pref_html" value="1" <cfif form.user_pref_html EQ '1' or form.user_pref_html EQ ''>checked="checked"</cfif> />
				HTML&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" style="border:none; background:none;"  name="user_pref_html" value="0" <cfif form.user_pref_html EQ '0'>checked="checked"</cfif> />
				Plain Text
				<hr />
				<p>We respect your privacy<br />
					<a href="/z/user/privacy/index" onclick="window.open(this.href); return false;" title="View our privacy policy in a new window." class="zPrivacyPolicyLink">View Our Privacy Policy</a></p>
			</div>
		</cfif>
		<cfif openIdEnabled and variables.qcheckemail.recordcount NEQ 0 and openIdCom.isAdminChangeAllowed()>
			<div class="zmember-openid" style="width:100%; float:left; padding-bottom:0px;">
				<p style="font-size:130%; font-weight:bold;">OpenID Options</p>
				#local.openIdOutput#
			</div>
		</cfif>
		<cfif local.hideAllPrefFields EQ false>
			<div class="zmember-openid-buttons" style="width:100%; float:left; padding-top:5px;">
				<hr />
				<input type="hidden" name="returnurl" value="<cfif application.zcore.functions.zso(form, 'returnurl') NEQ "">#htmleditformat(application.zcore.functions.zso(form, 'returnurl'))#<cfelseif request.zos.cgi.http_referer DOES NOT CONTAIN "/z/user/preference/index">#htmleditformat(request.zos.cgi.http_referer)#</cfif>" />
				<button type="submit" name="submitPref" value="Update Communication Preferences" style="font-size:120%; padding:5px; margin-bottom:5px;">
				<cfif form.e NEQ ''>
					Save
				<cfelse>
					Register
				</cfif>
				</button>
					<button type="button" name="cancelb" value="" onclick="window.location.href='/z/user/preference/index';" style="font-size:120%; padding:5px; margin-bottom:5px;">Cancel</button>
			</div>
		</cfif>
		</div>
	</form>
	<!--- <cfif application.zcore.user.checkGroupAccess("member")>
		<div class="z-float" style="font-size:130%; "><a href="/member/">Site Manager</a> | <a href="/">Home Page</a></div>
	</cfif> --->
</cffunction>

<cffunction name="newMemberWelcome" localmode="modern" access="remote">
	<cfscript>
	var local=structnew();
	application.zcore.template.setTag("title","Registration Successful.");
	application.zcore.template.setTag("pagetitle","Registration Successful.");
	</cfscript>
	<p>You are now logged in to our web site.</p>
	<cfif structkeyexists(form,'modalpopforced') and form.modalpopforced EQ 1>
		<cfscript>
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
	</cfscript>
		<p>Closing window in 3 seconds.</p>
		<script type="text/javascript">/* <![CDATA[ */ 
		setTimeout(function(){ zCloseThisWindow(); },3000);
		/* ]]> */
		</script>
	</cfif>
	#application.zcore.functions.zVarSO("Lead Conversion Tracking Code")#
</cffunction>

<cffunction name="register" localmode="modern" access="remote">
	<cfscript>
	var theMeta=0;
	var c2=0;
	var local=structnew();

	customURL=application.zcore.functions.zso(request.zos.globals, 'customCreateAccountURL');
	if(customURL NEQ ""){
		application.zcore.functions.z301redirect(application.zcore.functions.zURLAppend(customURL, "modalpopforced=#application.zcore.functions.zso(form, 'modalpopforced', true)#&redirectOnLogin=#urlencodedformat(application.zcore.functions.zso(form, 'redirectOnLogin'))#&reloadOnNewAccount=#application.zcore.functions.zso(form, 'reloadOnNewAccount')#"));
	}

	this.init();
	

	textMissing=false;
	if(application.zcore.app.siteHasApp("content")){
		ts=structnew();
		ts.content_unique_name='/z/user/preference/register';
		ts.disableContentMeta=false;
		ts.disableLinks=true; 
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
	}else{
		r1=false;
	}
	if(r1 EQ false){

		application.zcore.template.setTag("title","Create A Free Account");
		application.zcore.template.setTag("pagetitle","Create A Free Account");
	}
	
	application.zcore.functions.zStatusHandler(request.zsid,true);
	
	if(form.e NEQ '' and application.zcore.functions.zEmailValidate(form.e) EQ false){
		application.zcore.status.setStatus(request.zsid, "#form.e# is not a valid email address.  Please check your spelling and try again (i.e. email@yourdomain.com)",form,true);
		application.zcore.functions.zRedirect("/z/user/preference/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#&e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&zsid=#request.zsid#");
	}
	</cfscript>
	<cfif structkeyexists(form, 'zSignupMessage')>
		<h2>#form.zSignupMessage#</h2>
		<br />
	</cfif>
	<form class="zFormCheckDirty" name="defineContact" action="/z/user/preference/update?e=#urlencodedformat(form.e)#&k=#urlencodedformat(form.k)#&modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#" method="post">
		<div style=" width:100%; float:left;">
		<cfif structkeyexists(form, 'custommarketingmessage')>
			<div style="width:100%;float:left;">#form.custommarketingmessage#</div>
		<cfelseif variables.qcheckemail.recordcount eq 0>
			<cfset c2=application.zcore.functions.zvarso("New Account Marketing Information")>
			<div style="width:100%;float:left;">
				<cfif c2 EQ "">
					<p>Please complete the form below to create an account on our web site.</p>
				<cfelse>
#c2#
				</cfif>
			</div>
		</cfif>
		<cfsavecontent variable="theMeta">
		<style type="text/css">
		  .zmember-openid-buttons{ width:auto;}
		  .zmember-openid-buttons a:link, .zmember-openid-buttons a:visited{ width:auto;}
		  ##openidurl{width:255px !important;}
		  </style> 
		#application.zcore.skin.includeCSS("/z/javascript/pwdmeter/css/pwdmeter-custom.css")# #application.zcore.skin.includeJS("/z/javascript/pwdmeter/js/pwdmeter-custom.js")# 		</cfsavecontent>
		<cfscript>
		application.zcore.template.appendTag("meta", theMeta);
		</cfscript>
		<cfif application.zcore.user.checkGroupAccess("user")>
			<div style="width:100%; float:left;">
				<h2>You're already logged into another account.</h2>
				<p>If you want to create a new account, please <a href="/z/user/preference/register?zlogout=1">click here to logout and register</a></p>
			</div>
			</div>
			<cfreturn>
		</cfif>

		<cfif request.zos.globals.disableOpenID EQ 0 or (request.zos.globals.parentID NEQ 0 and application.zcore.functions.zvar('disableOpenId', request.zos.globals.parentID) EQ 0)>
	
			<h2>Sign in with OpenID</h2>
			<p>Click the button to register with an existing account.</p>
			<div style="width:100%; float:left;">
				<div class="z-user-preference-left">
					<cfscript>
					local.openIdCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.openid");
					local.openIdCom.disableDeveloperLoginLinks();
					local.openIdCom.enableRegistrationLoginLinks();
					writeoutput(local.openIdCom.displayProviderLinks(request.zos.currentHostName&"/z/user/preference/register?disableOpenIDLoginRedirect=1"));
					if(structkeyexists(form, 'zRegisterAccount')){
						if(request.zos.globals.disableOpenID EQ 1){
							application.zcore.functions.z404("OpenID login is disabled in server manager for this site.");
						}
						local.openIdCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.openid");
						writeoutput(local.openIdCom.verifyOpenIdLogin());
						if(application.zcore.user.checkGroupAccess("user")){
							if(local.openIdCom.userExisted()){
								application.zcore.functions.zredirect('/z/user/home/index?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#');
							}else{
								application.zcore.functions.zredirect('/z/user/preference/newMemberWelcome?modalpopforced=#form.modalpopforced#&redirectOnLogin=#urlencodedformat(form.redirectOnLogin)#&reloadOnNewAccount=#form.reloadOnNewAccount#');
							}
						}
					}
					</cfscript>
				</div>
				<div class="z-user-preference-right">
					<h3>About OpenID</h3>
					<ul>
						<li>Faster and can be more secure</li>
						<li>Consolidate your accounts</li>
						<li>You won't need a password here</li>
						<li>Free open standard</li>
						<li>Used by over 50,000 web sites</li>
						<li><a href="http://openid.net/get-an-openid/what-is-openid/" target="_blank">Learn More (new window)</a></li>
					</ul>
				</div>
			</div>
		</cfif>
		<div style="width:100%;clear:both; float:left;border-top:1px dotted ##999; padding-top:10px;">
			<div class="z-user-preference-left">
				<cfif request.zos.globals.disableOpenID EQ 0 or (request.zos.globals.parentID NEQ 0 and application.zcore.functions.zvar('disableOpenId', request.zos.globals.parentID) EQ 0)>
					<div style="width:100%; float:left;">If you don't have one of the above accounts:</div>
				</cfif>
	
				<h2 style="margin-top:0px; padding-top:0px;">Create a new account</h2>
				<div class="zmember-openid-buttons" style="width:100%; float:left;">
					<div class="z-float"><strong>Email</strong><br />
						<input type="text" name="user_email" style=" width:260px;" value="<cfif structkeyexists(form, 'e')>#htmleditformat(form.e)#</cfif>" />
					</div>
					<div class="z-float"><strong>Password</strong> <span style="display:block;width:187px; float:right; height:20px;"><span id="passwordMatchBox" style="display:none; background-color:##900; margin-left:0px; padding:7px; font-size:14px; line-height:14px; border:1px solid ##000; color:##FFF; float:left;border-radius:5px;">Passwords don't match</span></span> <br />
						<input type="password" id="passwordPwd" onkeyup="chkPass(this.value);zLogin.checkIfPasswordsMatch();" style=" width:260px;" onclick="tempValue=this.value;this.value='';" name="user_password" value="" />
					</div>
					<div class="z-float"><strong>Confirm Password</strong><br />
						<input type="password" id="passwordPwd2" style=" width:260px;" onclick="tempValue=this.value;this.value='';" onkeyup="zLogin.checkIfPasswordsMatch();" name="user_password" value="" />
					</div>
					<div class="z-float" style="width:100%; float:left; padding-top:5px;">
						<input type="hidden" name="returnurl" value="" />
						<button type="submit" name="submitPref" value="Update Communication Preferences" style="padding:5px; margin-bottom:5px;"> Register </button>
					</div>
				</div>
			</div>
			<div class="z-user-preference-right">
				<div style="width:100%; float:left; margin-bottom:0px; padding-bottom:5px;"><strong>Password Stength</strong></div>
				<div style="width:100%; float:left;">
					<div id="scorebarBorder">
						<div id="score">0%</div>
						<div id="scorebar">&nbsp;</div>
					</div>
					<div style="width:100%; float:left;" id="complexity">Too Short</div>
				</div>
				<div style="width:100%; float:left;">
					<ul>
						<li>Minimum 8 characters in length</li>
						<li>Try to use upper and lower case letters, numbers and symbols</li>
					</ul>
				</div>
			</div>
		</div>
	</div>
	</form>
	<div style="width:100%; float:left;"> Use of this web site requires acceptance of our <a href="/z/user/privacy/index" onclick="window.open(this.href); return false;" title="View our privacy policy in a new window." class="zPrivacyPolicyLink">Privacy Policy</a>.</div>
	</form>
	<hr />
	<h2>Already have an account? <a href="/z/user/preference/index" target="_top">Log in</a></h2>
</cffunction>
</cfoutput>
</cfcomponent>
