<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private"> 
    <cfscript>
    db=request.zos.queryObject;
    form.uid=application.zcore.functions.zso(form, 'uid', true);
    form.key=application.zcore.functions.zso(form, 'key'); 
    db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# 
    WHERE user_active=#db.param(1)# and 
    user_invited=#db.param(1)# and 
    user_deleted=#db.param(0)# and 
    user_id=#db.param(form.uid)# and 
    site_id=#db.param(request.zos.globals.id)#";
    qUser=db.execute("qUser");
    if(qUser.recordcount EQ 0){
    	echo('<h2>This invitation is no longer valid.</h2>  <p>If you need another invitation, please contact the web site administrator for assistance.</p>');
    	return false;
    }
    if(compare(qUser.user_reset_key, form.key) NEQ 0){
    	// if invited date is more then 7 days ago
    	if(datecompare(qUser.user_invited_datetime, dateadd("d", -7, now())) EQ -1){ 
        	echo('<h2>This invitation is no longer valid.</h2>  <p>If you need another invitation, please contact the web site administrator for assistance.</p>');
        	return false;	
        }
    }
    application.zcore.template.setTag("title", "Invitation to Create a New Account");
    application.zcore.template.setTag("pagetitle", "Invitation to Create a New Account");
    return qUser;
    </cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote"> 
    <cfscript>
    qUser=init();
    if(not isQuery(qUser)){
    	return;
    }
	form.set9=application.zcore.functions.zGetHumanFieldIndex();

	application.zcore.skin.includeCSS("/z/javascript/pwdmeter/css/pwdmeter-custom.css");
	application.zcore.skin.includeJS("/z/javascript/pwdmeter/js/pwdmeter-custom.js");
	</cfscript>
	<p>Please enter a new password twice for your account below and then click "Accept Invitation" below to get started with your new account.</p>

	<div id="errorMessage" style="display:none; width:100%; float:left; font-weight:bold; font-size:120%; line-height:1.3; padding-bottom:10px;">
	</div>
	<form id="myPasswordForm" action="" onsubmit="zSet9('zset9_#form.set9#');zLogin.setInviteNewPasswordSubmit(); return false;" method="post">
        #application.zcore.functions.zFakeFormFields()#
	<input type="hidden" name="uid" id="uid" value="#form.uid#" /> 
	<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" /> 
	<input type="hidden" name="js3811" id="js3811" value="" />
	<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" /> 

		<div style="float:left; padding-top:20px;width:285px;">  
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
					<button type="submit" name="submit1" value="" style="padding:5px; margin-bottom:5px;">Accept Invitation</button>
				</div>
			</div>
		</div>
		<div class="z-t-16" style="float:left; padding-top:20px;width:285px;">  
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
			<div class="z-t-16" style="float:left; width:100%; margin-bottom:10px;">
				<p>By submitting this form, you accept the <a href="/z/user/terms-of-use/index" target="_blank">terms of use</a> and <a href="/z/user/privacy/index" target="_blank">privacy policy</a>.</p>
			</div>
	</form>

	<script>
	zArrDeferredFunctions.push(function(){
		zLogin.setInviteNewPasswordSubmit=function(){

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
			tempObj.url="/z/user/invited"+"/inviteAccepted";
			tempObj.method="post";
			tempObj.callback=function(r){
				var r=JSON.parse(r);
				if(r.success){
					$("##errorMessage").hide();
					$("##myPasswordForm").hide();
					alert("Your account was created.\nClick OK to login.");
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

<cffunction name="inviteAccepted" localmode="modern" access="remote"> 
    <cfscript>
	var db=request.zos.queryObject;  
    qUser=init();
    if(not isQuery(qUser)){
    	return;
    }
    rs={success:false, errorMessage:""};
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		rs.errorMessage="Invalid request.";
	}
	if(application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1){
		if(not application.zcore.functions.zVerifyRecaptcha()){
			rs.errorMessage="The ReCaptcha security phrase wasn't entered correctly. Please refresh and try again."; 
		}
	}

	if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
		rs.errorMessage="Invalid request.."; 
	}
	if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
		rs.errorMessage="Your session has expired.  Please refresh and try again."; 
	}
	/*if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		rs.errorMessage="Invalid request..."; 
	}*/
	if(rs.errorMessage NEQ ""){ 
		application.zcore.functions.zReturnJSON(rs); 
	}
 
	form.pw=application.zcore.functions.zso(form, 'password1');
	form.pw2=application.zcore.functions.zso(form, 'password2'); 

	if(len(form.pw) < 8){
		application.zcore.functions.zReturnJSON({success:false, errorMessage:"The password must be at least 8 characters."});
	}
	if(compare(form.pw, form.pw2) NEQ 0){
		application.zcore.functions.zReturnJSON({success:false, errorMessage:"The passwords don't match."});
	}
 

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
	user_invited=#db.param(0)#,
	user_confirm=#db.param(1)#, 
	user_confirm_datetime=#db.param(request.zos.mysqlnow)#,
	user_confirm_ip=#db.param(request.zos.cgi.remote_addr)#, 
	user_password_version=#db.param(user_password_version)#,
	user_password=#db.param(form.pw)#,
	user_salt=#db.param(user_salt)#,
	user_key=#db.param(user_key)#,
	user_updated_datetime=#db.param(request.zos.mysqlnow)#
	WHERE user_id=#db.param(form.uid)# and 
	site_id = #db.param(request.zos.globals.id)# and  
	user_deleted = #db.param(0)# and 
	user_active=#db.param(1)# ";
	db.execute("qUpdate");  

 

	ts={};
	ts.to=qUser.user_email; 
	ts.from=request.fromemail;
	ts.subject="Welcome to #application.zcore.functions.zvar('shortdomain')#";
	savecontent variable="ts.html"{
		echo('<!DOCTYPE html>
	<html>
	<head><title></title></head>
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

<p>Your account at <a href="#request.zos.currentHostName#">#request.zos.currentHostName#</a> has been created.<p>

<p>You can login again in the future at this URL:</p>

<p><a href="#link#">#link#</a></p>
</body></html>');
	}
	rCom=application.zcore.email.send(ts);

	form.zusername=qUser.user_username;
	form.zpassword=form.pw2;
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
</cfoutput>
</cfcomponent>