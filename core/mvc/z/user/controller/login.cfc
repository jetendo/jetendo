<cfcomponent>
 <cfoutput>
 <cffunction name="process" localmode="modern" access="remote" output="yes">
 	<cfscript>
	
	var errorMessage="";
	var success=false;
	var rs=0;
	var inputStruct=0;
	var jsonText=0;



	//local.debugSQL="";
	request.znotemplate=1;
    application.zcore.functions.zNoCache();
	if(structkeyexists(form,'z_tmpusername2') EQ false or structkeyexists(form,'z_tmppassword2') EQ false){
		writeoutput("Invalid Request");
		application.zcore.functions.zabort();
	}
	form.zusername=form.z_tmpusername2;
	form.zpassword=form.z_tmppassword2; 
	inputStruct = StructNew();
	if(application.zcore.functions.zso(form, 'zIsMemberArea') EQ 1){
		inputStruct.user_group_name = "member";
	}else{
		inputStruct.user_group_name = "user";
	}
	inputStruct.noLoginForm=true;
	//if(request.zos.globals.requireSecureLogin EQ 1){
		inputStruct.secureLogin=true;
	/*}else{
		inputStruct.secureLogin=false;
	}*/
	inputStruct.site_id = request.zos.globals.id; 
	rs=application.zcore.user.checkLogin(inputStruct);  
	local.isDeveloper="0";
	if(rs.success){
		success=true;
		if(request.zos.userSession.site_id EQ request.zos.globals.serverID and application.zcore.user.checkServerAccess()){
			local.isDeveloper="1";
		}
	}else if(rs.error EQ 4){
		errorMessage="Your account requires Open ID authentication.";
	}else if(rs.error EQ 3){
		errorMessage="Your account was inactive for too long.  You must reset your password.";
	}else if(rs.error EQ 1){
		errorMessage="Invalid Login";
	}else if(rs.error EQ 2){
		errorMessage="Account disabled,<br />call webmaster.";
	}else{
		errorMessage="Unknown Error";	
	}
	rs={
		success:success,
		errorMessage:errorMessage,
		developer: local.isDeveloper
		// uncomment to debug this
		//,userStruct:application.zcore.functions.zso(request.zsession, 'user')
	};
	if(request.zos.isdeveloper and structkeyexists(form, 'zdebug')){
		rs.arrDebugLog=rs.arrDebugLog;
		rs.debugsql=arraytolist(request.zos.arrQueryLog, "; ");
	}
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>


<cffunction name="index" localmode="modern" access="remote" output="yes">
 	<cfscript>
	
	application.zcore.tracking.backOneHit();
	application.zcore.functions.zModalCancel();
	request.disablesharethis=true;
	request.zpagedebugdisabled=true;
	application.zcore.template.setTag("title","Service Login");
	application.zcore.template.setTemplate("zcorerootmapping.templates.simple",true,true); 
	application.zcore.template.appendTag("meta",'<style type="text/css">
	/* <![CDATA[ */ body,table{margin:0px; font-family:Verdana, Geneva, sans-serif; font-size:11px; line-height:14px; background-color:##FFF; color:##000;}
	input{ font-size:11px;} /* ]]> */
	</style>');
    writeoutput(this.displayLoginForm());
    </cfscript>
</cffunction>
<cffunction name="displayLoginForm" localmode="modern" output="no" returntype="string">
	<cfscript>
	var theHTMLContent=0;
	</cfscript>
	<cfsavecontent variable="theHTMLContent">
	<cfscript>
	application.zcore.functions.zRequireJquery();
	form.zIsMemberArea=application.zcore.functions.zso(form, 'zIsMemberArea',true,0);
	form.styleslabels=application.zcore.functions.zso(form, 'styleslabels',false,"");
	form.stylesinputs=application.zcore.functions.zso(form, 'stylesinputs',false,"");
	form.usernameLabel=application.zcore.functions.zso(form, 'usernameLabel',false,"Email:");
	form.passwordLabel=application.zcore.functions.zso(form, 'passwordLabel',false,"Password:");
	</cfscript>
	<form id="zLoginForm" onsubmit="return zLogin.autoLoginConfirm();" autocomplete="off" action="##" style="margin:0px; padding:0px;">
    <cfif form[request.zos.urlRoutingParameter] EQ "/z/user/login/index">
    <div style="display:none; clear:both; color:##000; font-size:120%;" id="statusDiv"></div>
    </cfif>
    <div class="zmember-openid-buttons" style="width:100%;">
	<cfif form.styleslabels NEQ false><h2 class="#form.styleslabels#"></cfif>#form.usernameLabel#<cfif form.styleslabels NEQ false></h2></cfif>
	<input type="text" name="z_tmpusername2" id="z_tmpusername2" onkeyup="document.getElementById('statusDiv').innerHTML='Please Login';" value="<cfif request.zos.istestserver and request.zos.isdeveloper>#request.zos.developerEmailTo#</cfif>" size="20" <cfif form.stylesinputs NEQ false>class="#form.stylesinputs#"</cfif>  />
	<script type="text/javascript">
	/* <![CDATA[ */ document.getElementById("z_tmpusername2").focus(); /* ]]> */
	</script>&nbsp;</div>
    <div class="zmember-openid-buttons" style="width:100%;">
	<cfif form.styleslabels NEQ false><h2 class="#form.styleslabels#"></cfif>#form.passwordLabel#<cfif form.styleslabels NEQ false></h2></cfif>
    <input type="password" name="z_tmppassword2" onkeyup="document.getElementById('statusDiv').innerHTML='Please Login';" id="z_tmppassword2" value="" size="20" <cfif form.stylesinputs NEQ false>class="#form.stylesinputs#"</cfif>  />
    </div>
	<div class="zmember-openid-buttons" style="width:100%;padding-top:5px; padding-bottom:10px;">
		<input type="checkbox" name="zRememberLogin" id="zRememberLogin" style="cursor:pointer; display:inline-block; margin:0px; margin-right:5px; width:20px; height:20px; padding:4px; border:none; background:none;" value="1" /> <label for="zRememberLogin" style="cursor:pointer;padding-top:2px;display:block;">Remember Login?</label>
	</div>
	<div class="zmember-openid-buttons" style="width:100%;"><input type="hidden" name="zIsMemberArea" id="zIsMemberArea" value="#form.zIsMemberArea#" />

	  <button name="submitForm" id="submitForm" onclick="zLogin.autoLoginConfirm();zLogin.disableLoginButtons();return false;" type="submit">Login</button>
	  
      <button name="submitForm2" id="submitForm2" class="zResetPasswordButton" onclick="window.location.href='/z/user/reset-password/index?email='+escape($('##z_tmpusername2').val());" type="button">Forgot password?</button>
      </div>
    
    
	</form></cfsavecontent>
    <cfcookie name="z_user_id" value="" expires="now">
    <cfcookie name="z_user_siteIdType" value="" expires="now">
    <cfcookie name="z_user_key" value="" expires="now">
    <cfcookie name="z_tmpusername2" value="" expires="now">
    <cfcookie name="z_tmppassword2" value="" expires="now">
    <cfcookie name="inquiries_email" value="" expires="now">
    <cfcookie name="inquiries_first_name" value="" expires="now">
    <cfcookie name="inquiries_last_name" value="" expires="now">
    <cfcookie name="inquiries_phone1" value="" expires="now">
    <cfreturn theHTMLContent>
</cffunction>

	<cffunction name="displayOpenIdLoginForm" localmode="modern" output="no" returntype="string">
    	<cfargument name="returnToURL" type="string" required="yes">
    	<cfscript>
		var theOutput="";
		</cfscript>
		<cfsavecontent variable="theOutput">
        <div class="zmember-openid" style="float:left; width:100%; max-width:375px;<cfif request.zos.globals.disableOpenID EQ 1 or (request.zos.globals.parentID NEQ 0 and application.zcore.functions.zvar('disableOpenId', request.zos.globals.parentID) EQ 1)>display:none;</cfif>">
        <h2><span style="display:block;float:left;">Sign in with OpenID </span> <span style="color:##F00;font-size:12px; margin-top:-5px; margin-left:3px; display:block; float:left;">New</span></h2><br style="clear:both;" />
        <cfscript>
        local.openIdCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.openid");
        writeoutput(local.openIdCom.displayProviderLinks(arguments.returnToURL));
        if(structkeyexists(form, 'providerId')){
            if(request.zos.globals.disableOpenID EQ 1){
                application.zcore.functions.z404("OpenID login is disabled in server manager for this site.");
            }
            local.openIdCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.openid");
            writeoutput(local.openIdCom.verifyOpenIdLogin());
			if(application.zcore.user.checkGroupAccess("user")){
				application.zcore.functions.zredirect('/z/user/home/index?modalpopforced=#form.modalpopforced#&reloadOnNewAccount=#form.reloadOnNewAccount#');
			}else{
				// openid login failed	
			}
        }
        </cfscript>
        </div>
        </cfsavecontent>
        <cfreturn theOutput>
    </cffunction>
    
        
    <cffunction name="parentToken" localmode="modern" access="remote" returntype="any">
        <cfscript>
        application.zcore.functions.zNoCache();
	application.zcore.functions.zheader("content-type", "application/javascript");
	application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, 'x_ajax_id'));
	if(structkeyexists(cookie, 'ztoken') and application.zcore.user.checkGroupAccess("user")){
		application.zcore.tempTokenCache[cookie.ztoken]={date:now(), user_id:request.zsession.user.id, site_id:request.zsession.user.site_id};
		local.isDeveloper=0;
		if(request.zos.userSession.site_id EQ request.zos.globals.serverID and application.zcore.user.checkServerAccess()){
			local.isDeveloper="1";
		}
		writeoutput('zLoginParentToken={"loggedIn":true, "token":"#jsstringformat(cookie.ztoken)#", "developer": #local.isDeveloper#}');
	}else{
		writeoutput('zLoginParentToken={"loggedIn":false}');//,"loginURL":"#application.zcore.functions.zvar("domain", request.zos.globals.parentId)#/member/"}');
	}
	application.zcore.functions.zAbort();
	</cfscript>
	</cffunction>
    
    <cffunction name="serverToken" localmode="modern" access="remote" returntype="any">
        <cfscript>
        application.zcore.functions.zNoCache();
	application.zcore.functions.zheader("content-type", "application/javascript");
	application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, 'x_ajax_id'));
	if(structkeyexists(cookie, 'ztoken') and application.zcore.user.checkGroupAccess("user")){
		application.zcore.tempTokenCache[cookie.ztoken]={date:now(), user_id:request.zsession.user.id, site_id:request.zsession.user.site_id};
		local.isDeveloper=0;
		if(request.zos.userSession.site_id EQ request.zos.globals.serverID and application.zcore.user.checkServerAccess()){
			local.isDeveloper="1";
		}
		writeoutput('zLoginServerToken={"loggedIn":true, "token":"#jsstringformat(cookie.ztoken)#", "developer": #local.isDeveloper#}');
	}else{
		writeoutput('zLoginServerToken={"loggedIn":false}');//,"dev":request.zos.isDeveloper,"loginURL":"#application.zcore.functions.zvar("domain", request.zos.globals.serverId)#/"}');
	}
        application.zcore.functions.zAbort();
        </cfscript>
    </cffunction>
    
<cffunction name="confirmToken" localmode="modern" access="remote" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;
	var inputStruct=0;
    application.zcore.functions.zNoCache();
	application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, 'x_ajax_id'));
	
	if(structkeyexists(form, 'tempToken')){
		if(structkeyexists(application.zcore.tempTokenCache, form.tempToken)){
			// force login for the token user_id
			user_id=application.zcore.tempTokenCache[form.tempToken].user_id;
			site_id=application.zcore.tempTokenCache[form.tempToken].site_id;
			structdelete(application.zcore.tempTokenCache, form.tempToken); // this was a one time use cache
			
			
			db.sql="select * from #request.zos.queryObject.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_id = #db.param(user_id)# and 
			site_id = #db.param(site_id)# and 
			user_deleted = #db.param(0)#";
			qUser=db.execute("qUser"); 
			if(qUser.recordcount EQ 0){
				writeoutput('{"success":false,"s":4}');
			}else{
				form.zautologin=1;
				form.zUsername=qUser.user_username;
				form.zPassword=qUser.user_password;
				inputStruct = StructNew();
				inputStruct.user_group_name = "user";
				inputStruct.noRedirect=true;
				inputStruct.secureLogin=true;
				inputStruct.noLoginForm=true;
				inputStruct.disableSecurePassword=true; 
				inputStruct.site_id = request.zos.globals.id;
				application.zcore.user.checkLogin(inputStruct); 
				if(application.zcore.user.checkGroupAccess("user")){
					writeoutput('{"success":true}');
				}else{
					structdelete(form, 'zUsername');
					structdelete(form, 'zPassword');
					writeoutput('{"success":false,"s":1}');
				}
			}
		}else{
			writeoutput('{"success":false,"s":2}');
		}
	}else{
		writeoutput('{"success":false,"s":3}');
	}
	application.zcore.functions.zAbort();
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>