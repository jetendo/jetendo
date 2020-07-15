<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<!DOCTYPE html>
	<!--[if lt IE 7]> <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
	<!--[if IE 7]> <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
	<!--[if IE 8]> <html class="no-js lt-ie9"> <![endif]-->
	<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
	<head>
	<meta charset="utf-8" />
	<title>Server Manager</title>
	<link rel="stylesheet" type="text/css" href="/z/stylesheets/zOS.css" />
	<link rel="stylesheet" type="text/css" href="/z/stylesheets/css-framework.css" />
	<link rel="stylesheet" type="text/css" href="/z/a/stylesheets/style.css" />
	</head>
	<body>
		<div style="margin:30px; width:500px; margin:0 auto;">
			<h1>You're Almost Ready</h1>
			<h2>Pre-installation steps</h2>
			<ul>
				<li>#request.zos.installPath#scripts/jetendo.ini must be configured and installed to: /etc/php5/mods-available/jetendo.ini and you must run 
				php scripts/install-jetendo.php from the command line before running this script.  If this file doesn't exist, make a copy of #request.zos.installPath#scripts/jetendo.ini.default to create it.</li>
				<li>Make sure #request.zos.installPath#core/config.cfc is configured correctly before completing this form. If this file doesn't exist, make a copy of #request.zos.installPath#core/config-default.cfc to create it.</li>
			</ul>
			<h2>Installation</h2>
			<cfscript>
			if(structkeyexists(form, 'user_email')){
				if(validate()){
					install();
				}
			}
			ipStruct=application.zcore.functions.getSystemIpStruct();
			</cfscript>
			<form action="#request.zos.cgi.script_name#?#request.zos.cgi.query_string#" method="post">
				<table class="table-list" style="width:100%;">
					<tr>
						<th colspan="2"><h3>Server Manager Admin Site Configuration</h3></td>
					</tr>
					<tr>
						<th style="vertical-align:top; width:1%; white-space:nowrap;">IP Address:</th>
						<td>
							<cfscript>
							ipStruct=application.zcore.functions.getSystemIpStruct();

							if(application.zcore.functions.zso(form, 'site_ip_address') EQ ""){
								form.site_ip_address=ipStruct.defaultIp;
							}
							selectStruct = StructNew();
							selectStruct.name = "site_ip_address";
							selectStruct.listvalues=arraytolist(ipStruct.arrIp,",");
							echo('<select name="site_ip_address" size="1">');
							for(i=1;i LTE arraylen(ipStruct.arrIp);i++){
								if(form.site_ip_address EQ ipStruct.arrIp[i]){
									echo('<option value="'&ipStruct.arrIp[i]&'" selected="selected">'&ipStruct.arrIp[i]&'</option>');
								}else{
									echo('<option value="'&ipStruct.arrIp[i]&'">'&ipStruct.arrIp[i]&'</option>');
								}

							}
							echo('</select>');
							</cfscript>
						</td>
					</tr>
					<tr>
						<td colspan="2"><h3>Create Server Administrator User</h3>
						<p>This will be your login to manage the sites. It has the highest level of permissions granted.  Make sure your password is complex.</p></td>
					</tr>
					<tr>
						<th style="width:1%;">Email</th>
						<td><input type="text" name="user_email" value="#htmleditformat(application.zcore.functions.zso(form, "user_email", false, request.zos.developerEmailTo))#" /></td>
					</tr>
					<cfscript>
					pw=application.zcore.functions.zGenerateStrongPassword();
					</cfscript>
					<tr>
						<th>Password</th>
						<td><input type="text" name="user_password" value="#htmleditformat(application.zcore.functions.zso(form, "user_password", false, pw))#" /></td>
					</tr>
					<tr>
						<th>Confirm Password</th>
						<td><input type="text" name="user_confirm_password" value="#htmleditformat(application.zcore.functions.zso(form, "user_confirm_password", false, pw))#" /></td>
					</tr>
					<tr>
						<td>&nbsp;</td>
						<td><input type="submit" name="submit1" value="Complete Installation" style="padding:5px; font-size:14px;" /></td>
					</tr>
				</table>
			</form>
		</div>
	</body>
	</html>
	<cfscript>
	application.zcore.functions.zAbort();
	</cfscript>
</cffunction>

<cffunction name="validate" localmode="modern" access="private" returntype="boolean">
	<cfscript>
	success=true;
	arrError=[];

    if(request.zOS.zcoreAdminDomain EQ "" or right(request.zos.zcoreAdminDomain, 1) EQ "/"){
    	throw("request.zOS.zcoreAdminDomain is required and must not end with a forward slash.");
    }
    if(request.zOS.zcoreTestAdminDomain EQ "" or right(request.zos.zcoreTestAdminDomain, 1) EQ "/"){
    	throw("request.zOS.zcoreAdminDomain is required and must not end with a forward slash.");
    }
    // consider verifying the rest of the config.cfc values before completing installation

	if(form.site_ip_address EQ ""){
		arrayAppend(arrError, "IP Address is required.");
		success=false;
	}
	if(form.user_email EQ "" or application.zcore.functions.zEmailValidate(form.user_email) EQ ""){
		arrayAppend(arrError, "Email is required.");
		success=false;
	}
	if(form.user_password EQ "" or compare(form.user_password, form.user_confirm_password) NEQ 0 or len(form.user_password) LT 10){
		arrayAppend(arrError, "A password with at least 10 characters is required and confirm password must match it.");
		success=false;
	}
	if(arraylen(arrError)){
		echo('<div style="width:99%; float:left; border:1px solid ##000;">
			<div style="width:96%;float:left; padding:2%; background-color:##900; color:##FFF;">Please correct these problems and try again</div>
			<div style="width:96%; float:left; padding:2%; ">');
		for(i=1;i LTE arraylen(arrError);i++){
			if(i NEQ 1){
				echo("<hr />");
			}
			echo(arrError[i]);
		}
		echo('</div></div>');
	}
	return success;
	</cfscript>
</cffunction>

<cffunction name="install" localmode="modern" access="private">
	<cfscript>

	t9={};

	if(request.zos.isTestServer){
		t9.site_domain=request.zos.zcoreTestAdminDomain;
		t9.site_live=0;
	}else{
		t9.site_domain=request.zos.zcoreAdminDomain;
		t9.site_live=1;
	}
	t9.site_ip_address=form.site_ip_address;
	t9.site_lock_theme=1;
	t9.site_sitename=replace(replace(replace(replace(t9.site_domain, "http://", ""), "https://", ""),"www.",""), "."&request.zos.testDomain, "");
	t9.site_short_domain=t9.site_sitename;
	t9.site_homedir=application.zcore.functions.zGetDomainInstallPath(t9.site_sitename);
	t9.site_privatehomedir=application.zcore.functions.zGetDomainWritableInstallPath(t9.site_sitename);
	t9.site_datasource=request.zos.zcoreDatasource;
	t9.site_homelinktext='Home';
	t9.site_email_campaign_from=request.zos.developerEmailFrom;
	t9.site_admin_email=request.zos.developerEmailTo;
	t9.site_active='1';
	t9.site_debug_enabled='1';
	t9.site_editor_stylesheet='/stylesheets/style-manager.css';
	if(not request.zos.isTestServer){
		t9.site_username=replace(replace(listdeleteat(t9.site_sitename, listlen(t9.site_sitename, "."), "."),"www.",""),".","","all");
		t9.site_password=application.zcore.functions.zGenerateStrongPassword();
	}
	ts={
		table:"site",
		datasource: request.zos.zcoreDatasource,
		struct: t9,
		debug: true
	};
	query name="qSite" datasource="#request.zos.zcoreDatasource#"{
		echo("SELECT site_id FROM `site` WHERE site_domain = '"&t9.site_domain&"' ");
	}
	if(qSite.recordcount EQ 0){
		form.site_id=application.zcore.functions.zInsert(ts);
		siteCom=createobject("zcorerootmapping.mvc.z.server-manager.admin.controller.site");
		siteCom.createUserBlogContent(form.site_id);
	}else{
		ts.struct.site_id=qSite.site_id;
		form.site_id=qSite.site_id;
		application.zcore.functions.zUpdate(ts);
	}
	
	application.zcore.functions.zSecureCommand("verifySitePaths", 40);
	application.zcore.functions.zcreatedirectory(t9.site_privatehomedir&'zupload');
	application.zcore.functions.zcreatedirectory(t9.site_privatehomedir&'zcache');
	application.zcore.functions.zcreatedirectory(t9.site_privatehomedir&'_cache');
	application.zcore.functions.zcreatedirectory(t9.site_privatehomedir&'_cache/html');
	application.zcore.functions.zcreatedirectory(t9.site_privatehomedir&'_cache/scripts');
	application.zcore.functions.zcreatedirectory(t9.site_privatehomedir&'_cache/scripts/sentenceData');
	application.zcore.functions.zcreatedirectory(t9.site_privatehomedir&'_cache/scripts/skins');
	application.zcore.functions.zcreatedirectory(t9.site_privatehomedir&'_cache/scripts/templates');
	application.zcore.functions.zcreatedirectory(t9.site_privatehomedir&'_cache/scripts/emailTemplates');
	application.zcore.functions.zSecureCommand("installThemeToSite"&chr(9)&"default"&chr(9)&t9.site_homedir, 20);

	application.zcore.functions.zOS_cacheSiteAndUserGroups(form.site_id);
	application.zcore.functions.zOS_cacheSitePaths();
	application.zcore.app.appUpdateCache(form.site_id);
	rs=application.zcore.functions.zGenerateNginxMap();

	inputStruct = structNew();
	inputStruct.user_username = form.user_email; // make same as email to use email as login
	inputStruct.user_password = form.user_password;
	inputStruct.site_id = form.site_id; 
	inputStruct.user_email = application.zcore.functions.zso(form, 'user_email');

	query name="qGroup" datasource="#request.zos.zcoreDatasource#"{
		echo("SELECT * FROM user_group WHERE site_id = '"&application.zcore.functions.zescape(form.site_id)&"' and 
		user_group_name = 'Administrator' ");
	}
	inputStruct.user_group_id = qGroup.user_group_id;
	inputStruct.member_password=inputStruct.user_password;
	inputStruct.sendConfirmOptIn=false;
	inputStruct.user_openid_provider = "";
	inputStruct.user_openid_id = "";
	inputStruct.user_openid_email = "";
	inputStruct.user_openid_required=0;
	inputStruct.user_access_site_children = 1;
	inputStruct.user_site_administrator = 1;
	inputStruct.user_server_administrator = 1;
	inputStruct.user_intranet_administrator =1;	
	inputStruct.user_system = 1; // remove when used on any other app
	userAdminCom=createobject("component", "zcorerootmapping.com.user.user_admin");

	query name="qUser" datasource="#request.zos.zcoreDatasource#"{
		echo("SELECT * FROM user WHERE site_id = '"&application.zcore.functions.zescape(form.site_id)&"' and 
		user_server_administrator = '1' LIMIT 0,1");
	}
	if(qUser.recordcount EQ 0){
		form.user_id = userAdminCom.add(inputStruct);
	}else{
		inputStruct.user_id=qUser.user_id;
		userAdminCom.update(inputStruct);
	}

	structdelete(application, request.zos.installPath&":displaySetupScreen");

	application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>