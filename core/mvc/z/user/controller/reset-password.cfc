<cfcomponent>
<cfoutput>
<cffunction name="verifyUserReset" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject;  
	link="/z/user/reset-password/index?zsid=#request.zsid#";
	if(len(form.user_reset_key) NEQ 64){
		application.zcore.status.setStatus(request.zsid, "The reset password link is formatted wrong.  Be sure to include the full link from the email.", form, true);
		if(structkeyexists(form, 'x_ajax_id')){
			application.zcore.functions.zReturnJSON({success:false, redirectURL:link}); 
		}else{
			application.zcore.functions.zRedirect(link);
		}
	}

	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# 
	WHERE user_id=#db.param(form.user_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	user_reset_key=#db.param(form.user_reset_key)# and 
	user_deleted = #db.param(0)# and 
	user_active=#db.param(1)# ";
	qUser=db.execute("qUser");   
	if(qUser.recordcount EQ 0){ 
		application.zcore.status.setStatus(request.zsid, "The reset password link is invalid.  Please try again.", form, true);
		if(structkeyexists(form, 'x_ajax_id')){
			application.zcore.functions.zReturnJSON({success:false, redirectURL:link}); 
		}else{
			application.zcore.functions.zRedirect(link);
		}
	}
	form.email=qUser.user_username;
	expireDate=dateadd("d", 1, qUser.user_reset_datetime);
	if(datecompare(now(), expireDate) EQ 1){ 
		application.zcore.status.setStatus(request.zsid, "The reset password link has expired.  Please try again.", form, true);
		if(structkeyexists(form, 'x_ajax_id')){
			application.zcore.functions.zReturnJSON({success:false, redirectURL:link}); 
		}else{
			application.zcore.functions.zRedirect(link);
		}
	}
	return qUser;
	</cfscript>
</cffunction>

<cffunction name="updatePassword" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;  
	form.pw=application.zcore.functions.zso(form, 'password1');
	form.pw2=application.zcore.functions.zso(form, 'password2');
	form.user_id=application.zcore.functions.zso(form, 'uid', true);
	form.user_reset_key=application.zcore.functions.zso(form, 'urk');

	if(len(form.pw) < 8){
		application.zcore.functions.zReturnJSON({success:false, errorMessage:"The password must be at least 8 characters."});
	}
	if(compare(form.pw, form.pw2) NEQ 0){
		application.zcore.functions.zReturnJSON({success:false, errorMessage:"The passwords don't match."});
	}

	qUser=verifyUserReset();

	user_salt=application.zcore.functions.zGenerateStrongPassword(256,256); 
	user_key=hash(user_salt, "sha");
	if(request.zos.globals.plainTextPassword EQ 0){
		user_password_version = request.zos.defaultPasswordVersion;
		form.pw=application.zcore.user.convertPlainTextToSecurePassword(form.pw, user_salt, request.zos.defaultPasswordVersion, false);
	}else{
		user_password_version=0;
		user_salt="";	
	}

	db.sql="update #db.table("user", request.zos.zcoreDatasource)# 
	set user_reset_key=#db.param('')#, 
	user_password_version=#db.param(user_password_version)#,
	user_password=#db.param(form.pw)#,
	user_salt=#db.param(user_salt)#,
	user_key=#db.param(user_key)#,
	user_updated_datetime=#db.param(request.zos.mysqlnow)#
	WHERE user_id=#db.param(form.user_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	user_reset_key=#db.param(form.user_reset_key)# and 
	user_deleted = #db.param(0)# and 
	user_active=#db.param(1)# ";
	db.execute("qUpdate");  


	ts={};
	ts.to=form.email; 
	ts.from=request.fromemail;
	ts.subject="Password was reset for #application.zcore.functions.zvar('shortdomain')#";
	savecontent variable="ts.html"{
		echo('<!DOCTYPE html>
	<html>
	<head><title>Password reset</title></head>
	<body><h3>');
		if(qUser.user_first_name NEQ ""){
			echo('Dear '&qUser.user_first_name&" "&qUser.user_last_name);
		}else if(qUser.member_company NEQ ""){
			echo('Dear '&qUser.member_company);
		}else{
			echo('Hello');
		}
		link="#request.zos.currentHostName#/z/user/preference/index";
		writeoutput(',</h3>

<p>The password was successfully reset for your account, #qUser.user_username#, at <a href="#request.zos.currentHostName#">#request.zos.currentHostName#</a>.<p>

<p>If you didn''t reset the password and are concerned about the security of your account, please contact the web site owner / developer to make sure your account is secure.</p>

<p>You can login or change your password again in the future at this URL:</p>

<p><a href="#link#">#link#</a></p>
</body></html>');
	}
	rCom=application.zcore.email.send(ts);
	if(rCom.isOK() EQ false){
		rs.success=false;
		application.zcore.status.setStatus(request.zsid, "Failed to send email.  Is your email still valid?", form, true);
		application.zcore.functions.zReturnJSON({success:false, redirectURL:"/z/user/reset-password/index?zsid=#request.zsid#"}); 
	} 

	form.zusername=qUser.user_username;
	form.zpassword=form.pw;
	inputStruct = StructNew();
	inputStruct.user_group_name = "user";
	inputStruct.noRedirect=true;
	inputStruct.disableSecurePassword=true;
	inputStruct.secureLogin=true;
	inputStruct.site_id = request.zos.globals.id;
	// perform check 
	application.zcore.user.checkLogin(inputStruct);

	application.zcore.functions.zReturnJSON({success:true});
	</cfscript>		
</cffunction>

<cffunction name="setNewPassword" localmode="modern" access="remote">
	<cfscript> 
	var db=request.zos.queryObject;  
	form.user_id=application.zcore.functions.zso(form, 'user_id', true);
	form.user_reset_key=application.zcore.functions.zso(form, 'user_reset_key');
	verifyUserReset();

	//	application.zcore.template.setTemplate("zcorerootmapping.templates.nothing",true,true);
	application.zcore.template.setTag("title", "Set New Password");
	application.zcore.template.setTag("pagetitle", "Set New Password");
 

	form.set9=application.zcore.functions.zGetHumanFieldIndex();


	application.zcore.skin.includeCSS("/z/javascript/pwdmeter/css/pwdmeter-custom.css");
	application.zcore.skin.includeJS("/z/javascript/pwdmeter/js/pwdmeter-custom.js");
	</cfscript>
	<div id="errorMessage" style="display:none; width:100%; float:left; font-weight:bold; font-size:120%; line-height:1.3; padding-bottom:10px;">
	</div>
	<form class="zFormCheckDirty" id="myPasswordForm" action="" onsubmit="zSet9('zset9_#htmleditformat(form.set9)#'); zLogin.setNewPasswordSubmit(); return false;" method="post" style="margin:0px; padding:0px;">
            #application.zcore.functions.zFakeFormFields()#
		<input type="hidden" name="zset9" id="zset9_#htmleditformat(form.set9)#" value="" /> 
		<input type="hidden" name="js3811" id="js3811" value="" />
		<input type="hidden" name="js3812" id="js3812" value="#htmleditformat(application.zcore.functions.zGetFormHashValue())#" /> 
		<input type="hidden" name="uid" id="uid1" value="#htmleditformat(form.user_id)#" />
		<input type="hidden" name="urk" id="urk1" value="#htmleditformat(form.user_reset_key)#" />
		<div class="zmember-openid-buttons">
			<div style="float:left; width:100%; margin-bottom:10px;">
				<h2>Password:</h2>
				<input type="password" name="password1" id="passwordPwd" onkeyup="chkPass(this.value);zLogin.checkIfPasswordsMatch();" value="" />
			</div>
			<div style="float:left; width:100%; margin-bottom:10px;">
				<h2>Confirm Password:</h2>
				<input type="password" name="password2" id="passwordPwd2" onclick="tempValue=this.value;this.value='';" onkeyup="zLogin.checkIfPasswordsMatch();" value="" />
			</div>
			<div style="float:left; width:100%; margin-bottom:10px;">
				<span id="passwordMatchBox" style="display:none; background-color:##900; margin-left:0px; padding:7px; font-size:14px; line-height:14px; border:1px solid ##000; color:##FFF; float:left;border-radius:5px;">Passwords don't match</span>
			</div>
			<cfif application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1>
				<div style="float:left; width:100%; margin-bottom:10px;">#application.zcore.functions.zDisplayRecaptcha()#</div>
			</cfif>
			<div style="float:left; width:100%; margin-bottom:10px;">
				<button type="submit" name="submit1" value="" style="padding:5px; margin-bottom:5px;">Set Password &amp; Login</button>
			</div>
		</div>
		<div style="float:left; padding-top:20px;width:285px;">
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
	</form> 

	<script>
	zArrDeferredFunctions.push(function(){
	zLogin.setNewPasswordSubmit=function(){
		var pw1=$("##passwordPwd").val();
		var pw2=$("##passwordPwd2").val(); 
		var arrError=[];
		if(pw1.length<8){
			arrError.push("The password must be at least 8 characters.");
		}
		if(pw1 != pw2){
			arrError.push("The passwords don't match.");
		}
		if(arrError.length){
			$("##errorMessage").show().html(arrError.join("<br />"));
		}else{
			$("##errorMessage").hide();
		}
		var tempObj={};
		tempObj.id="zUpdatePassword";
		tempObj.postObj=zGetFormDataByFormId("myPasswordForm"); 
		tempObj.url="/z/user/reset-"+"password/updatePassword";
		tempObj.method="post";
		tempObj.callback=function(r){
			var r=JSON.parse(r);
			if(r.success){
				$("##errorMessage").hide();
				$("##myPasswordForm").hide();
				alert("Your password was reset.\nClick OK to login.");
				window.location.href='/z/user/home/index';
			}else{
				if(typeof r.redirectURL != "undefined"){
					window.location.href=r.redirectURL;
				}else{
					$("##errorMessage").show().html(r.errorMessage);
				}
			}
		};
		tempObj.cache=false;
		zAjax(tempObj);
	};
	});
	</script>
</cffunction>

<!--- 
rpCom=createobject("component", "zcorerootmapping.mvc.z.user.controller.reset-password");
rs=rpCom.sendPasswordResetEmail(email, request.zos.globals.id);
application.zcore.functions.zReturnJson(rs);
 --->
<cffunction name="sendPasswordResetEmail" localmode="modern" access="public">
	<cfargument name="email" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 
	rs={success:true}; 
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# 
	WHERE user_username=#db.param(arguments.email)# and 
	site_id = #db.param(arguments.site_id)# and
	user_deleted = #db.param(0)# and 
	user_active=#db.param(1)# ";
	qUser=db.execute("qUser");   
	if(qUser.recordcount EQ 0){ 
		return rs;
	}
	user_reset_key=hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256');
	db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# 
	SET 
	user_reset_key=#db.param(user_reset_key)#, 
	user_reset_datetime=#db.param(request.zos.mysqlnow)#,
	user_updated_datetime=#db.param(request.zos.mysqlnow)#
	WHERE user_id=#db.param(qUser.user_id)# and 
	site_id = #db.param(arguments.site_id)# and
	user_deleted = #db.param(0)# and 
	user_active=#db.param(1)# ";
	if(not db.execute("qUpdate")){
		rs.success=false;
		rs.errorMessage="Request failed";
		return rs;
	}
	if(arguments.site_id EQ request.zos.globals.id){
		domain=request.zos.currentHostName;
	}else{
		domain=application.zcore.functions.zvar('domain', arguments.site_id);
	}
	ts={};
	ts.to=arguments.email; 
	if(request.zos.isTestServer){
		ts.to=request.zos.developerEmailTo;
	}
	/*fromEmail=application.zcore.functions.zVarSO("zofficeemail", arguments.site_id);
	if(fromEmail EQ ""){
		if(not request.zos.isTestServer){
			throw("Warning: Reset email requires that zofficeemail is set.");
		}
	}*/
	ts.from=request.fromemail;

	ts.subject="Reset password for #application.zcore.functions.zvar('shortdomain', arguments.site_id)#";
	savecontent variable="ts.html"{
		echo('<!DOCTYPE html>
	<html>
	<head><title>Reset password</title></head>
	<body><h3>');
		if(qUser.user_first_name NEQ ""){
			echo('Dear '&qUser.user_first_name&" "&qUser.user_last_name);
		}else if(qUser.member_company NEQ ""){
			echo('Dear '&qUser.member_company);
		}else{
			echo('Hello');
		}
		link="#domain#/z/-eup#qUser.user_id#.#user_reset_key#";
		writeoutput(',</h3>

<p>A request to reset the password for #arguments.email# has been made from <a href="#domain#">#domain#</a>.<p>

<p>If you agree to reset the password, please click the link below and set your new password. </p>

<p><a href="#link#">#link#</a></p>

<p>If the link does not work, please copy and paste the entire link in your browser''s address bar and hit enter.    If you did not make this password reset request, you can ignore this email and the link will expire within 24 hours.</p>
</body></html>');
	} 
	rCom=application.zcore.email.send(ts);
	if(rCom.isOK() EQ false){
		rs.success=false;
		rs.errorMessage="Failed to send email.  Is your email still valid?";
		return rs;
	} 
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="processReset" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;  
	spam=false;
	rs={success:true};
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		rs.errorMessage="Invalid request.";
	}
	form.email=application.zcore.functions.zso(form, 'email');
	if(not application.zcore.functions.zEmailValidate(form.email)){
		rs.errorMessage="Invalid email format. Please try again.";
		spam=true;
	}
	if(application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1){
		if(not application.zcore.functions.zVerifyRecaptcha()){
			rs.errorMessage="The ReCaptcha security phrase wasn't entered correctly. Please refresh and try again.";
			spam=true;
		}
	}
	if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
		rs.errorMessage="Invalid request..";
		spam=true;
	}
	if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
		rs.errorMessage="Your session has expired.  Please refresh and try again.";
		spam=true;
	}
	/*if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		rs.errorMessage="Invalid request...";
		spam=true;
	}*/
	if(spam){
		rs.success=false;
		application.zcore.functions.zReturnJSON(rs); 
	}
	rs=sendPasswordResetEmail(form.email, request.zos.globals.id);



	application.zcore.functions.zReturnJSON(rs); 
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote"> 
	<cfscript>  
	form.email=application.zcore.functions.zso(form, 'email');

	//application.zcore.functions.zSetModalWindow();
	//	application.zcore.template.setTemplate("zcorerootmapping.templates.nothing",true,true);
	application.zcore.template.setTag("title", "Reset Password");
	application.zcore.template.setTag("pagetitle", "Reset Password");

	echo('<div id="topErrorMessage" style="width:100%; float:left;">');
	application.zcore.functions.zStatusHandler(request.zsid,true);
	echo('</div>');

	form.set9=application.zcore.functions.zGetHumanFieldIndex();
	</cfscript>
	<div id="errorMessage" style="display:none; width:100%; float:left; font-weight:bold; font-size:120%; line-height:1.3; padding-bottom:10px;">
	</div>
	<form class="zFormCheckDirty" id="myPasswordForm" action="" onsubmit="zSet9('zset9_#htmleditformat(form.set9)#'); zLogin.submitResetPasswordForm(); return false; " method="post" style="margin:0px; padding:0px;">
            #application.zcore.functions.zFakeFormFields()#
		<input type="hidden" name="zset9" id="zset9_#htmleditformat(form.set9)#" value="" /> 
		<input type="hidden" name="js3811" id="js3811" value="" />
		<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" /> 
		<div class="zmember-openid-buttons">
		<h2>Email:</h2>
		<input type="email" name="email" id="email" value="#htmleditformat(form.email)#" /></p>
		<cfif application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1>
			<div style="float:left; width:100%; margin-bottom:10px;">#application.zcore.functions.zDisplayRecaptcha()#</div>
		</cfif>
		<div style="width:100%; float:left;"><button type="submit" name="submit1" value="" style="padding:5px; margin-bottom:5px;">Send Reset Email</button></div>
		</div>
	</form>
	<div id="resetMessage" style="display:none;width:100%; float:left; ">
		If your email exists in our system, you will receive an email shortly that contains instructions on how to reset your password.
	</div>

	<script>
	zArrDeferredFunctions.push(function(){
	zLogin.submitResetPasswordForm=function(){ 
		var tempObj={};
		tempObj.id="zResetPassword";
		tempObj.postObj=zGetFormDataByFormId("myPasswordForm"); 
		tempObj.method="post";
		tempObj.url="/z/user/reset-"+"password/processReset";
		tempObj.callback=function(r){
			var r=JSON.parse(r);
			if(r.success){
				$("##topErrorMessage").hide();
				$("##errorMessage").hide();
				$("##myPasswordForm").hide();
				$("##resetMessage").show();
			}else{
				if(typeof r.redirectURL != "undefined"){
					window.location.href=r.redirectURL;
				}else{
					$("##errorMessage").show().html(r.errorMessage);
				} 
			}
		};
		tempObj.cache=false;
		zAjax(tempObj);
	};
	});
	</script>
</cffunction>
</cfoutput>
</cfcomponent> 