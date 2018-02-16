<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	form.sid=application.zcore.functions.zso(form, 'sid');
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	db.sql="SELECT * FROM #db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server
	WHERE deploy_server_id= #db.param(application.zcore.functions.zso(form,'deploy_server_id'))# and 
	deploy_server_deleted = #db.param(0)#  ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'deploy_server no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/server-manager/admin/deploy-server/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript> 
		db.sql="UPDATE #db.table("site_x_deploy_server", request.zos.zcoreDatasource)#  
		set site_x_deploy_server_deleted = #db.param(1)#,
		site_x_deploy_server_updated_datetime=#db.param(request.zos.mysqlnow)#
		WHERE deploy_server_id= #db.param(form.deploy_server_id)#  and 
		site_id <> #db.param(-1)#";
		q=db.execute("q");
		db.sql="UPDATE #db.table("deploy_server", request.zos.zcoreDatasource)#  
		set deploy_server_deleted = #db.param(1)#,
		deploy_server_updated_datetime=#db.param(request.zos.mysqlnow)#
		WHERE deploy_server_id= #db.param(form.deploy_server_id)#  ";
		q=db.execute("q"); 
		application.zcore.functions.zUpdateDomainRedirectCache();
		application.zcore.status.setStatus(Request.zsid, 'server deleted');
		application.zcore.functions.zRedirect('/z/server-manager/admin/deploy-server/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this server?<br />
		The deployment configuration for this server will be removed from all sites using it.<br />
			<br />
			#qCheck.deploy_server_host#<br />
			<br />
			<a href="/z/server-manager/admin/deploy-server/delete?confirm=1&amp;deploy_server_id=#form.deploy_server_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/server-manager/admin/deploy-server/index">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var ts={};
	var result=0; 
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init(); 
	ts.deploy_server_group.required = true;
	ts.deploy_server_ssh_host.required = true;
	ts.deploy_server_ssh_port.required = true;
	ts.deploy_server_ssh_username.required = true;
	ts.deploy_server_private_key_path.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	
	if(not structkeyexists(form, 'deploy_server_deploy_enabled')){
		form.deploy_server_deploy_enabled=0;
	}
	/*if(not fileexists(form.deploy_server_private_key_path)){
		application.zcore.status.setStatus(request.zsid, "The private key path, ""#form.deploy_server_private_key_path#"", doesn't exist.  You must specify a path to a valid RSA key generated using ssh-keygen.  This file will be used by ssh to connect with the remote deploy server securely.", form, true);
		result=true;
	}*/
	if(form.deploy_server_ssh_host EQ ""){
		application.zcore.status.setStatus(request.zsid, "SSH Host is required.", form, true);
		result=true;
	}
	if(form.deploy_server_ssh_username EQ ""){
		application.zcore.status.setStatus(request.zsid, "SSH Username is required.", form, true);
		result=true;
	}
	var currentServer=replace(replace(request.zos.globals.serverdomain, 'http://',''), 'https://','');
	if(form.deploy_server_host EQ "/" or currentServer EQ form.deploy_server_host){
		application.zcore.status.setStatus(request.zsid, "You can't add the current instance, ""#currentServer#"", as a deploy server.  You can only add remote servers.", form, true);
		result=true;
	}
	// TODO: need to implement a password verification system for api calls that DOESN'T store login in the session scope.
	/*
		how to handle API for plug-ins?  Just put them in the usual place but in an api sub-directory.  All the cfcs under a directory name "api" are tagged as API for login/security system to modify it's data types / error handling.
		
		if API code is in same project for all plugins, then I can't move the API or that would multiply the work to do this.
	allow disabling session storage for user.cfc - just return the data, and put it in the cache, and request scope.   Allow mvc security to use the request scope object instead of session if it is using session currently.
		
	when security error occurs on mvc function call, we should recognize it was an API call, and return a response object, instead of an exception or 404.
		
	rest path based api is easier for static caching, since the order of parameters is guaranteed.
		
	successful api logins should be cached as these are trusted hosts calling the server from a server.  
	
	require an javascript and CFML script include stands between the developer and my server which enforces the throttling limits.  If an app tries bypasses the limits, they get banned for a while and an email alert to developer is generated.
		var app
		
		instead of causing the third party's server to be hit on every request, it could do a single API verification request to it's own server that calls my server on the first request and passes the public user's ip address along to my server.  This would allow associating that user with the api key I've provided to the third party developer.   This token it returns to the javascript public user would expire every so often, to prevent easy abuse.   We'd heavily throttle individual users to prevent scraping, but they would be able to visit our server directly, allowing the third party to have a lower performance server while using our API.
			instead of this, you could just serve everything through an iframe, but integration / customization is reduced.
		ideas to protect api from abuse: http://blog.programmableweb.com/2007/04/02/12-ways-to-limit-an-api/
		limit the number of listings downloaded by a single user over time.
		
		technically: return instantly with a 500 response on throttling.  The javascript api will be set to retry throttled requests again automatically every second until a timeout is reached, then the user will see that the service is unavailable, and isAvailable will start to return false.
		
		update the version of the javascript file that handles ajax throttling each day, and change filename so that the browser is forced to download it.  In the file, make sure a unique randomized variable name with a randomized value is created.  This value gets passed to the server for all api calls.  If that value doesn't match the server's value, the request will be blocked.  This prevents users from modifying the Javascript api I let them link to.
		
		make the server configuration for API able to have different max post size, etc.  This actually requires running it in separate domain, and separate context probably.
		
		All the features that support uploads would have to be changed to use a different domain, and that domain would return an ID that will let the app associate that data with the record.
		
		if(not app.isAvailable()){
			// display alternate content	
		}
		var requestObj=app.newRequest();
		requestObj.setCallback(obj, 'method');
		requestObj.setAction("/z/api/listing/search");
		dataObj={
			"minBedrooms":2,
			"maxBedrooms":4
		};
		requestObj.setData(dataObj);
		requestObj.execute(); // verifies that callback, action are set first.
		
		obj.method=function(responseObj){
			if(!responseObj.success){
				// handle error
			}
			responseObj.count
			responseObj.arrListing
		}
		
	We must be able to add a developer to the server manager.
		Name, Company, Email, Developer ID, API key (generateStrongPassword 40 to 60 chars), Allowed IP address list.   Throttling (Request per minute, request per hour, Concurrent request limit, Priority)
	provide no way to log out- to avoid bypassing the performance boost of the API.  A high traffic server would only verify the API key and IP.
		the cache will be based on a single hash 256 of 
		var key=hash(request.zos.cgi.remote_addr&":"&form.username&":"&form.password, "sha-256");
		var requireLogin=true;
		var request.zos
		if(structkeyexists(loginCache, key)){
			if(datecompare(now(), loginCache[key].loginDatetime) GT 1?){
				requireLogin=false;
			}
		}
		if(requireLogin){
			var rs=checkAPILogin();
			returnStruct.success=rs.success;
			if(rs.success){
				loginCache[key]=rs.data;
			}
		}
		
		if(
	allow batch API requests on day 1.
		pseudo code
			arrAction=[{
				action:"/z/api/login/index",	
				username="",
				password=""
			},
			{
				action: "/z/api/server-manager/server/getConfig"
			},
			{
				action: "/z/api/server-manager/site/getActive"
			},
			]
		
		
	soap xml
	
	
	*/
	
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/server-manager/admin/deploy-server/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/server-manager/admin/deploy-server/edit?deploy_server_id=#form.deploy_server_id#&zsid=#request.zsid#');
		}
	}
	ts=StructNew();
	ts.table='deploy_server';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){ 
		form.deploy_server_id = application.zcore.functions.zInsert(ts); 
		if(form.deploy_server_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save server.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/deploy-server/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'server saved.'); 
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save server.',form,true);
			application.zcore.functions.zRedirect('/z/server-manager/admin/deploy-server/edit?deploy_server_id=#form.deploy_server_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'server updated.');
		}
		
	} 
	application.zcore.functions.zUpdateDomainRedirectCache();
	application.zcore.functions.zRedirect('/z/server-manager/admin/deploy-server/index?zsid=#request.zsid#');
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var ts=0;
	var db=request.zos.queryObject; 
	var currentMethod=form.method;
	var htmlEditor=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.4.2");
	if(application.zcore.functions.zso(form,'deploy_server_id') EQ ''){
		form.deploy_server_id = -1;
	}
	db.sql="SELECT * FROM #db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server 
	WHERE 
	deploy_server_id=#db.param(form.deploy_server_id)# and 
	deploy_server_deleted = #db.param(0)#";
	var qD=db.execute("qD");
	application.zcore.functions.zQueryToStruct(qD, form);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript> 
	<h2><cfif currentMethod EQ "edit">Edit<cfelse>Add</cfif> Deploy Server</h2>
	<form class="zFormCheckDirty" action="/z/server-manager/admin/deploy-server/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?deploy_server_id=#form.deploy_server_id#" method="post"> 
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<td class="table-list">Group *</td>
				<td class="table-white"><input type="text" name="deploy_server_group" size="100" value="#htmleditformat(form.deploy_server_group)#" /><br>(Groups can be deployed separately)</td>
			</tr> 
			<tr>
				<td class="table-list">Host</td>
				<td class="table-white"><input type="text" name="deploy_server_host" size="100" value="#htmleditformat(form.deploy_server_host)#" /><br>(i.e. www.host.com excluding http://)</td>
			</tr>  
			<tr>
				<td class="table-list">Require SSL</td>
				<td class="table-white">#application.zcore.functions.zInput_Boolean("deploy_server_secure")#</td>
			</tr> 
			<tr>
				<td class="table-list">Email</td>
				<td class="table-white"><input type="text" name="deploy_server_email" size="100" value="#htmleditformat(form.deploy_server_email)#" /></td>
			</tr>  
			<tr>
				<td class="table-list">Password</td>
				<td class="table-white"><input type="password" name="deploy_server_password" size="100" value="#htmleditformat(form.deploy_server_password)#" /></td>
			</tr> 
			<tr>
				<td class="table-list">SSH Host *</td>
				<td class="table-white"><input type="text" name="deploy_server_ssh_host" size="100" value="#htmleditformat(form.deploy_server_ssh_host)#" /></td>
			</tr>  
			<tr>
				<td class="table-list">SSH Port *</td>
				<td class="table-white"><input type="text" name="deploy_server_ssh_port" size="100" value="#htmleditformat(form.deploy_server_ssh_port)#" /><br>(usually 22)</td>
			</tr> 
			<tr>
				<td class="table-list">SSH Username *</td>
				<td class="table-white"><input type="text" name="deploy_server_ssh_username" size="100" value="#htmleditformat(form.deploy_server_ssh_username)#" /></td>
			</tr>  
			<tr>
				<td class="table-list">SSH Private Key Path *</td>
				<td class="table-white"><input type="text" name="deploy_server_private_key_path" size="100" value="#htmleditformat(form.deploy_server_private_key_path)#" /><br>This absolute file reference should be a private key file generated by the ssh-keygen command line application (i.e. ssh-keygen -t rsa -pubout -b 2048 -f /path/to/key).  The public key should be installed in the ~/.ssh/authorized_keys file on the remote server.</td>
			</tr>  
			<tr>
				<td class="table-list">Deploy Enabled</td>
				<td class="table-white"><input type="checkbox" name="deploy_server_deploy_enabled" size="100" value="1" <cfif form.deploy_server_deploy_enabled EQ 1>checked="checked"</cfif> /><br>(When not checked, this server will be excluded from deployment.)</td>
			</tr>  
			<tr>
				<td class="table-list">&nbsp;</td>
				<td class="table-white"><button type="submit" name="submitForm">Save</button>
					<button type="button" name="cancel" onclick="window.location.href = '/z/server-manager/admin/deploy-server/index';">Cancel</button></td>
			</tr>
		</table>
	</form>  
</cffunction>



<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.4.1"); 
	application.zcore.functions.zStatusHandler(request.zsid); 
	db.sql="SELECT * 
	FROM #db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server WHERE 
	deploy_server_deleted = #db.param(0)#
	order by deploy_server_group, deploy_server_host";
	qDeploy=db.execute("qDeploy");
	</cfscript>
	<h2>Manage Deploy Servers</h2>
		<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tr class="table-list"><td>
			<a href="/z/server-manager/admin/deploy-server/add">Add Deploy Server</a>
			</td></tr>
		<tr class="table-list"><td> 
	<cfif qDeploy.recordcount EQ 0>
		<p>No Deploy Servers have been added.</p>
		<cfelse>
		<table  class="table-list">
			<tr>
				<th>Group</th> 
				<th>SSH Host</th> 
				<th>Jetendo Web Host</th> 
				<th>Admin</th>
			</tr>
			<cfloop query="qDeploy">
				<cfscript>
				var p="http://";
				if(qDeploy.deploy_server_secure EQ 1){
					p="https://";	
				}
				</cfscript>
				<tr <cfif qDeploy.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>> 
					<td>#qDeploy.deploy_server_group#</td>
					<td>#qDeploy.deploy_server_ssh_host#</td>
					<td><a href="#p&qDeploy.deploy_server_host#/" target="_blank">#qDeploy.deploy_server_host#</a></td> 
					<td>
					<a href="/z/server-manager/admin/deploy-server/edit?deploy_server_id=#qDeploy.deploy_server_id#">Edit</a> | 
					<a href="/z/server-manager/admin/deploy-server/delete?deploy_server_id=#qDeploy.deploy_server_id#">Delete</a></td>
				</tr>
			</cfloop>
		</table>
	</cfif>
			</td></tr>
			</table>
</cffunction>
</cfoutput>
</cfcomponent>