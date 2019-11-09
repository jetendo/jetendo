<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var repostStruct=0;
	variables.userAdminCom = CreateObject("component", "zcorerootmapping.com.user.user_admin");
	variables.userGroupAdminCom = CreateObject("component", "zcorerootmapping.com.user.user_group_admin");
	if(structkeyexists(form, 'zid') EQ false){
		form.zid = application.zcore.status.getNewId(); 
		if(structkeyexists(form, 'sid')){
			application.zcore.status.setField(form.zid, 'site_id',form.sid);
		}
	}
	form.sid = application.zcore.status.getField(form.zid, 'site_id');
	if(form.sid EQ ''){
		application.zcore.functions.zRedirect('/z/server-manager/admin/site-select/index');
	}
	
	
	if(structkeyexists(form, 'returnId') EQ false){
		form.returnId = application.zcore.status.getNewId();
		application.zcore.status.setField(form.returnId, "url",application.zcore.functions.zFilterURL("zsid"));
	}else{
		form.returnId = form.returnId;
	}
	if(structkeyexists(form, 'zsaUsersOnly')){
		if(form.zsaUsersOnly EQ 1 or isDefined('request.zsession.zsaUsersOnly') EQ false){
			request.zsession.zsaUsersOnly = 1;
		}else if(form.zsaUsersOnly EQ 0){
			StructDelete(request.zsession, 'zsaUsersOnly');
		}
		StructDelete(form, "zsaUsersOnly");
	}
	repostStruct = application.zcore.functions.zGetRepostStruct();
	</cfscript>
	<h2>Manage Users</h2>
	<form name="userForm2" id="userForm2" action="#request.cgi_script_name#?#htmleditformat(repostStruct.urlString)#" method="post">
		#repostStruct.formString#
		<table style="border-spacing:0px; width:100%;" class="table-list">
			<tr>
				<td><a href="/z/server-manager/admin/user/index?zid=#form.zid#&amp;sid=#form.sid#">User Groups</a> | 
				<a href="/z/server-manager/admin/user/editSitePermissions?zid=#form.zid#&amp;sid=#form.sid#&amp;returnId=#form.returnId#">Site Permissions</a> | 
				<a href="/z/server-manager/admin/user/addUser?zid=#form.zid#&amp;sid=#form.sid#&amp;returnId=#form.returnId#">Add User</a> | 
				<a href="/z/server-manager/admin/user/addUserGroup?zid=#form.zid#&amp;sid=#form.sid#&amp;returnId=#form.returnId#">Add User Group</a> |
				<a href="/z/server-manager/admin/user/addUser?zid=#form.zid#&amp;sid=#request.zos.globals.serverId#&amp;returnId=#form.returnId#&amp;user_server_administrator=1">Add Server Administrator</a> | 
				<a href="/z/server-manager/admin/user/index?zid=#form.zid#&amp;sid=#request.zos.globals.serverId#">Manage Server Administrators</a> | 
				<cfif isDefined('request.zsession.zsaUsersOnly')>
					<a href="/z/server-manager/admin/user/index?zid=#form.zid#&amp;sid=#form.sid#&amp;zsaUsersOnly=0">Hide Server Manager Users.</a>
				<cfelse>
					<a href="/z/server-manager/admin/user/index?zid=#form.zid#&amp;sid=#form.sid#&amp;zsaUsersOnly=1">Show Server Manager Users.</a>
				</cfif>
				</td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="activate" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var qUser=0;
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.6.1.2");
	db.sql="SELECT site_id, user_first_name, user_last_name, user_ip_blocked 
	FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_id = #db.param(application.zcore.functions.zso(form, 'user_id'))# and 
	site_id =#db.param(form.sid)# and 
	user_deleted = #db.param(0)#";
	qUser=db.execute("qUser");
	if(qUser.recordcount EQ 0){	
		application.zcore.status.setStatus(Request.zsid, "User no longer exists.",false,true);		
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>		
		variables.userAdminCom.setActive(application.zcore.functions.zso(form, 'user_id'), form.sid);	
		application.zcore.forceUserUpdateSession[form.sid&":"&form.user_id]=true;
		application.zcore.status.setStatus(Request.zsid, "User activated and IP was unblocked.");
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));
		</cfscript>
	<cfelse>
		<div style="text-align:center;"><span class="medium">
			<cfif qUser.user_ip_blocked EQ 1>
				Do you want to activate this user?
			<cfelse>
				Do you want to unblock the IP and activate this user?
			</cfif>
			<br />
			<br />
			#qUser.user_first_name# #qUser.user_last_name# 			<br />
			<br />
			<a href="/z/server-manager/admin/user/activate?zid=#form.zid#&sid=#form.sid#&returnId=#form.returnId#&confirm=1&user_id=#form.user_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="#application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#")#">No</a></span></div>
	</cfif>
</cffunction>

<cffunction name="deactivate" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qUser=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.6.1.2");
	db.sql=" SELECT site_id, user_first_name, user_last_name FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_id = #db.param(application.zcore.functions.zso(form, 'user_id'))# and 
	site_id = #db.param(form.sid)# and 
	user_deleted = #db.param(0)#";
	qUser=db.execute("qUser");
	if(qUser.recordcount EQ 0){	
		application.zcore.status.setStatus(Request.zsid, "User no longer exists.",false,true);
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>		
		if(structkeyexists(form, 'user_ip_block')){
			variables.userAdminCom.setInactive(application.zcore.functions.zso(form, 'user_id'), form.sid,true);	
			application.zcore.status.setStatus(Request.zsid, "User deactivated and their last IP was blocked.");
		}else{
			variables.userAdminCom.setInactive(application.zcore.functions.zso(form, 'user_id'), form.sid);	
			application.zcore.status.setStatus(Request.zsid, "User deactivated.");
		}
		application.zcore.forceUserUpdateSession[form.sid&":"&form.user_id]=true;
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));
		</cfscript>
	<cfelse>
		<div style="text-align:center;"><span class="medium"> Deactivate user?<br />
			<br />
#qUser.user_first_name# #qUser.user_last_name# 			<br />
			<br />
			<a href="/z/server-manager/admin/user/deactivate?zid=#form.zid#&sid=#form.sid#&returnId=#form.returnId#&user_ip_block=1&confirm=1&user_id=#form.user_id#">Yes, and block their last IP</a>&nbsp;&nbsp;&nbsp; 
			<a href="/z/server-manager/admin/user/deactivate?zid=#form.zid#&sid=#form.sid#&returnId=#form.returnId#&confirm=1&user_id=#form.user_id#">Yes, and don't block IP</a>
			&nbsp;&nbsp;&nbsp; <a href="#application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#")#">No</a></span></div>
	</cfif>
</cffunction>

<cffunction name="deleteUser" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qUser=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	db.sql=" SELECT site_id, user_first_name, user_last_name FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_id = #db.param(application.zcore.functions.zso(form, 'user_id'))# and 
	site_id = #db.param(form.sid)# and 
	user_deleted = #db.param(0)#";
	qUser=db.execute("qUser");
	if(qUser.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, "User no longer exists.",false,true);
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>		
		if(variables.userAdminCom.delete(application.zcore.functions.zso(form, 'user_id'), form.sid)){		
			application.zcore.status.setStatus(Request.zsid, "User, #qUser.user_first_name# #qUser.user_last_name#, deleted.");
		}else{		
			application.zcore.status.setStatus(Request.zsid, "User failed to delete.",false,true);
		}
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));
		</cfscript>
	<cfelse>
		<div style="text-align:center;"><span class="medium"> Are you sure you want to delete this user?<br />
			<br />
#qUser.user_first_name# #qUser.user_last_name# 			<br />
			<br />
			<a href="/z/server-manager/admin/user/deleteUser?zid=#form.zid#&sid=#form.sid#&returnId=#form.returnId#&confirm=1&user_id=#form.user_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="#application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#")#">No</a></span></div>
	</cfif>
</cffunction>

<cffunction name="deleteUserGroup" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qGroup=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	db.sql=" SELECT site_id, user_group_name FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE user_group_id = #db.param(application.zcore.functions.zso(form, 'user_group_id'))# and 
	site_id = #db.param(form.sid)# and 
	user_group_deleted = #db.param(0)#";
	qGroup=db.execute("qGroup");
	if(qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, "User Group no longer exists.",false,true);
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>		
		if(variables.userGroupAdminCom.delete(application.zcore.functions.zso(form, 'user_group_id'), form.sid)){		
			application.zcore.status.setStatus(Request.zsid, "User Group, #qGroup.user_group_name#, deleted.");
		}else{		
			application.zcore.status.setStatus(Request.zsid, "User Group failed to delete.",false,true);
		}
		application.zcore.functions.zOS_cacheSiteAndUserGroups(form.sid);
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));
		</cfscript>
	<cfelse>
		<div style="text-align:center;"><span class="medium"> Are you sure you want to delete this access level <br />
			and the user permissions attached to it?<br />
			<br />
#qGroup.user_group_name# 			<br />
			<br />
			<a href="/z/server-manager/admin/user/deleteUserGroup?zid=#form.zid#&sid=#form.sid#&returnId=#form.returnId#&confirm=1&user_group_id=#form.user_group_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="#application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#")#">No</a></span></div>
	</cfif>
</cffunction>

<cffunction name="insertUser" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.updateUser();
	</cfscript>
</cffunction>

<cffunction name="updateUser" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var inputStruct = structNew();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	// required 
	inputStruct.user_username = application.zcore.functions.zso(form, 'user_username'); // make same as email to use email as login
	inputStruct.user_password = application.zcore.functions.zso(form, 'user_password');
	inputStruct.site_id = form.sid; 
	// optional
	inputStruct.user_first_name = application.zcore.functions.zso(form, 'user_first_name');
	inputStruct.user_last_name = application.zcore.functions.zso(form, 'user_last_name');
	inputStruct.user_email = application.zcore.functions.zso(form, 'user_email');
	inputStruct.user_group_id = application.zcore.functions.zso(form, 'user_group_id',true);


	if(not application.zcore.user.checkAllCompanyAccess()){
		form.company_id = request.zsession.user.company_id;
	}
	inputStruct.company_id=application.zcore.functions.zso(form, 'company_id', true);
	if(inputStruct.user_password EQ ""){
		structdelete(inputStruct, 'user_password');
	}else{
		inputStruct.member_password=inputStruct.user_password;
	}
	inputStruct.sendConfirmOptIn=false;
	if(inputStruct.user_group_id EQ 0){
		if(form.method EQ "insertUser"){
			application.zcore.status.setStatus(Request.zsid, "You must select a user group.",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/user/addUser?zid=#form.zid#&sid=#form.sid#"&"&returnId=#form.returnId#&zsid=#Request.zsid#");
		}else{
			application.zcore.status.setStatus(Request.zsid, "You must select a user group.",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/user/editUser?zid=#form.zid#&sid=#form.sid#"&"&returnId=#form.returnId#&user_id=#application.zcore.functions.zso(form, 'user_id')#&zsid=#Request.zsid#");
		}
	}

	
	inputStruct.user_openid_provider = application.zcore.functions.zso(form, 'user_openid_provider');
	inputStruct.user_openid_id = application.zcore.functions.zso(form, 'user_openid_id');
	inputStruct.user_openid_email = application.zcore.functions.zso(form, 'user_openid_email');
	
	form.user_group_id = application.zcore.functions.zso(form, 'uai');
	inputStruct.user_openid_required=application.zcore.functions.zso(form, 'user_openid_required',false,0);
	if(form.user_id EQ request.zsession.user.id and request.zsession.user.site_id EQ form.sid){
	}else{
		inputStruct.user_access_site_children = application.zcore.functions.zso(form, 'user_access_site_children',true); // set to 1 to give user full access to children sites
		inputStruct.user_site_administrator = application.zcore.functions.zso(form, 'user_site_administrator',true); // set to 1 to give user full access to all groups on a site
		inputStruct.user_server_administrator = application.zcore.functions.zso(form, 'user_server_administrator',true); // set to 1 to give user full access to all sites & groups
	}
	inputStruct.user_server_admin_site_id_list=application.zcore.functions.zso(form, 'user_server_admin_site_id_list');
	inputStruct.user_intranet_administrator = application.zcore.functions.zso(form, 'user_intranet_administrator',true);	
	if(form.method EQ "insertUser"){
		inputStruct.user_system = 1; // remove when used on any other app
		form.user_id = variables.userAdminCom.add(inputStruct);
		if(form.user_id EQ false){
			// duplicate entry			
			application.zcore.status.setStatus(Request.zsid, "Username must be unique.<br />Password must be 8 or more characters.<br />Email Address must be valid or left blank.",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/user/addUser?zid=#form.zid#&sid=#form.sid#"&"&returnId=#form.returnId#&zsid=#Request.zsid#");
		}
		application.zcore.status.setStatus(Request.zsid, "User added.");
	}else{
		inputStruct.user_id = application.zcore.functions.zso(form, 'user_id');
		if(variables.userAdminCom.update(inputStruct) EQ false){
			application.zcore.status.setStatus(Request.zsid, "Username must be unique.<br />Password must be 8 or more characters.<br />Email Address must be valid or left blank.",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/user/editUser?zid=#form.zid#&sid=#form.sid#"&"&returnId=#form.returnId#&zsid=#Request.zsid#");
		}
		application.zcore.status.setStatus(Request.zsid, "User updated.");
	}

	application.zcore.forceUserUpdateSession[form.sid&":"&form.user_id]=true;
	application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));	
	</cfscript>
</cffunction>

<cffunction name="insertUserGroup" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.updateUserGroup();
	</cfscript>
</cffunction>

<cffunction name="updateUserGroup" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var inputStruct = structNew();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	// required 
	inputStruct.user_group_name = application.zcore.functions.zso(form, 'user_group_name');
	inputStruct.user_group_manage_full_subuser_group_id_list=application.zcore.functions.zso(form, 'user_group_manage_full_subuser_group_id_list');
	inputStruct.user_group_manage_partial_subuser_group_id_list=application.zcore.functions.zso(form, 'user_group_manage_partial_subuser_group_id_list');
 
	inputStruct.site_id = form.sid; 
	// optional
	inputStruct.user_group_friendly_name = application.zcore.functions.zso(form, 'user_group_friendly_name');
	if(form.user_group_friendly_name EQ ""){
		application.zcore.status.setStatus(Request.zsid, "Friendly name is required",form,true);
		if(form.method EQ "insertUserGroup"){
			application.zcore.functions.zRedirect("/z/server-manager/admin/user/addUserGroup?zid=#form.zid#&sid=#form.sid#"&"&returnId=#form.returnId#&zsid=#Request.zsid#");
		}else{
			application.zcore.functions.zRedirect("/z/server-manager/admin/user/editUserGroup?zid=#form.zid#&sid=#form.sid#"&"&returnId=#form.returnId#&zsid=#Request.zsid#");
		}
	}

	if(form.method EQ "insertUserGroup"){
		if(variables.userGroupAdminCom.add(inputStruct) EQ false){
			// duplicate entry		
			application.zcore.status.setStatus(Request.zsid, "Unique user group name required.",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/user/addUserGroup?zid=#form.zid#&sid=#form.sid#"&"&returnId=#form.returnId#&zsid=#Request.zsid#");
		}	
		application.zcore.status.setStatus(Request.zsid, "User Group added.");
	}else{
		inputStruct.user_group_id = application.zcore.functions.zso(form, 'user_group_id');
		if(variables.userGroupAdminCom.update(inputStruct) EQ false){
			// duplicate entry		
			application.zcore.status.setStatus(Request.zsid, "Unique user group name required.",form,true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/user/editUserGroup?zid=#form.zid#&sid=#form.sid#"&"&returnId=#form.returnId#&zsid=#Request.zsid#");
		}	
		application.zcore.status.setStatus(Request.zsid, "User Group updated.");
	}
	application.zcore.functions.zOS_cacheSiteAndUserGroups(form.sid);
	application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));
	</cfscript>
</cffunction>

<cffunction name="updateSitePermissions" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qFlush=0;
	var qUpdate=0;
	var i=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	variables.init();
	if(application.zcore.functions.zso(form, 'user_group_primary') EQ ''){		
		application.zcore.status.setStatus(Request.zsid, "Primary User Group is required.",false,true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/user/editSitePermissions?zid=#form.zid#&sid=#form.sid#&zsid=#Request.zsid#");
	}
	db.sql=" UPDATE #db.table("user_group", request.zos.zcoreDatasource)# user_group 
	SET user_group_primary = #db.param(0)#,
	user_group_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE site_id = #db.param(form.sid)# and 
	user_group_deleted = #db.param(0)# ";
	qFlush=db.execute("qFlush");
	db.sql="UPDATE #db.table("user_group", request.zos.zcoreDatasource)# user_group 
	SET user_group_primary = #db.param(1)#,
	user_group_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE user_group_id = #db.param(form.user_group_primary)# and 
	user_group_deleted = #db.param(0)# and
	site_id = #db.param(form.sid)# ";
	qUpdate=db.execute("qUpdate");	
	if(application.zcore.functions.zso(form, 'user_group_id') NEQ ''){
		for(i=1;i LTE listLen(form.user_group_id);i=i+1){
			variables.userGroupAdminCom.setPermissions(listGetAt(form.user_group_id, i), form.sid, application.zcore.functions.zso(form, 'user_group_id_list'&i), application.zcore.functions.zso(form, 'user_group_id_user'&i), application.zcore.functions.zso(form, 'user_group_share_user'&i),application.zcore.functions.zso(form, 'user_group_x_group_type'&i));	
		}
	}
	application.zcore.status.setStatus(Request.zsid, "Site Permissions updated.");
	application.zcore.functions.zOS_cacheSiteAndUserGroups(form.sid);
	application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"), "zsid=#Request.zsid#"));
	</cfscript>
</cffunction>

<cffunction name="editSitePermissions" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qUserGroup=0;
	var sitename=0;
	var arrGroups=0;
	var qUserXGroup=0;
	var pid=0;
	var i=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.6.2");
	db.sql="SELECT user_group.* 
	FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE 
	user_group.site_id = #db.param(form.sid)# and 
	user_group_deleted = #db.param(0)#
	ORDER BY user_group_name ASC ";
	qUserGroup=db.execute("qUserGroup", "", 10000, "query", false);
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2>Edit Site Permissions</h2>
		<form class="zFormCheckDirty" action="/z/server-manager/admin/user/updateSitePermissions?zid=#form.zid#&amp;sid=#form.sid#&amp;returnId=#form.returnId#" name="myform" id="myform" method="post">
			
	<table style="border-spacing:0px;" class="table-list">
		<tr>
			<td colspan="#2+qUserGroup.recordcount#">Use this form to set what user group each user group are allowed to access. <br />
				The user groups going down will be able to access user groups that are selected going across.</td>
		</tr>
		<tr>
				<td style="width:130px;">&nbsp;</td>
				<td style="vertical-align:top;">Primary Group</td>
				<cfloop query="qUserGroup">
					<td style="vertical-align:top; border-left:1px solid ##CCC;"><cfif qUserGroup.user_group_friendly_name NEQ "">
						#application.zcore.functions.zFirstLetterCaps(qUserGroup.user_group_friendly_name)#
					<cfelse>
						#application.zcore.functions.zFirstLetterCaps(qUserGroup.user_group_name)#
					</cfif></td>
				</cfloop>
			</tr>
			<cfset sitename = "">
			<cfset arrGroups = ArrayNew(1)>
			<cfloop query="qUserGroup">
				<cfsavecontent variable="db.sql"> SELECT *, user_group_x_group.user_group_id as parentid FROM 
				#db.table("user_group", request.zos.zcoreDatasource)# user_group 
				LEFT JOIN #db.table("user_group_x_group", request.zos.zcoreDatasource)# user_group_x_group ON  
				user_group_x_group.site_id = user_group.site_id   
				and user_group_x_group.user_group_child_id = user_group.user_group_id  
				and user_group_x_group.user_group_id = #db.param(qUserGroup.user_group_id)# and 
				user_group_x_group_deleted = #db.param(0)#
				WHERE user_group.site_id = #db.param(form.sid)# and 
				user_group_deleted = #db.param(0)#
				ORDER BY user_group_name ASC </cfsavecontent>
				<cfscript>
				qUserXGroup=db.execute("qUserXGroup");
				i = qUserGroup.currentRow;
				</cfscript>
				<tr>
					<td style="width:130px;">
						<cfif qUserGroup.user_group_friendly_name NEQ "">
							#application.zcore.functions.zFirstLetterCaps(qUserGroup.user_group_friendly_name)#
						<cfelse>
							#application.zcore.functions.zFirstLetterCaps(qUserGroup.user_group_name)#
						</cfif>
						Permissions:
						<input type="hidden" name="user_group_id" id="user_group_id" value="#qUserGroup.user_group_id#"></td>
					<td style="text-align:center"><input type="radio" name="user_group_primary" value="#qUserGroup.user_group_id#" <cfif qUserGroup.user_group_primary EQ 1>checked="checked"</cfif>></td>
					<cfset pid = qUserGroup.user_group_id>
					<cfset form.user_group_x_group_type = 0>
					<cfloop query="qUserXGroup">
						<td  style="text-align:center;white-space:nowrap; ">
						<cfif pid NEQ qUserXGroup.user_group_id>
							<!--- Login Access: --->
							<input type="checkbox" name="user_group_id_list#i#" id="user_group_id_list#i#" value="#qUserXGroup.user_group_id#" <cfif pid EQ qUserXGroup.parentid and qUserXGroup.user_group_login_access EQ 1>checked="checked"</cfif> class="input-plain">
						</cfif>
						<!--- <br />
						Modify Users:
						<input type="checkbox" name="user_group_id_user#i#" id="user_group_id_user#i#" value="#qUserXGroup.user_group_id#" <cfif pid EQ qUserXGroup.parentid and qUserXGroup.user_group_modify_user EQ 1>checked="checked"</cfif> class="input-plain">
						<br />
						Share Users:
						<input type="checkbox" name="user_group_share_user#i#" id="user_group_share_user#i#" value="#qUserXGroup.user_group_id#" <cfif pid EQ qUserXGroup.parentid and qUserXGroup.user_group_share_user EQ 1>checked="checked"</cfif> class="input-plain"> ---></td>
					</cfloop>
				</tr>
			</cfloop>
			<tr>
				<td style="width:130px;">&nbsp;</td>
				<td colspan="#qUserGroup.recordcount+1#"><input type="submit" name="submit" value="Update Permissions">
					<input type="button" name="cancel" value="Cancel" onClick="window.location.href = '#application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#")#';"></td>
			</tr>
		</form>
	</table>
</cffunction>

<cffunction name="addUser" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.editUser();
	</cfscript>
</cffunction>

<cffunction name="editUser" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var currentMethod=form.method;
	var qUser=0;
	var selectStruct=0;
	var qGroup=0;
	var openIdCom=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.6.1.1");
	form.user_id = application.zcore.functions.zso(form, 'user_id',false,-1);
	db.sql=" SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_id = #db.param(form.user_id)# and 
	user_deleted=#db.param(0)# and 
	site_id =#db.param(form.sid)# ";
	qUser=db.execute("qUser");
	tempStruct={};
	application.zcore.functions.zQueryToStruct(qUser, tempStruct);
	structappend(form, tempStruct, false);

	form.company_id=application.zcore.functions.zso(form, 'company_id', true);
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	db.sql=" SELECT user_group.user_group_id, user_group.user_group_name, user_group.user_group_friendly_name 
	FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE site_id = #db.param(form.sid)# and 
	user_group_deleted=#db.param(0)# and 
	user_group_deleted = #db.param(0)# 
	ORDER BY user_group_friendly_name ASC ";
	qGroup=db.execute("qGroup");
	if(form.user_server_administrator EQ 1){
		form.user_site_administrator=1;
		form.user_access_site_children=1;
		for(row in qGroup){
			if(row.user_group_name EQ "administrator"){
				form.user_group_id=row.user_group_id;
			}
		}
	}
	</cfscript>
	<h2><cfif currentMethod EQ "editUser">
						Edit
					<cfelse>
						Add
					</cfif>
					User</h2>
	<form class="zFormCheckDirty" name="userForm" id="userForm" action="/z/server-manager/admin/user/<cfif currentMethod EQ "editUser">updateUser<cfelse>insertUser</cfif>?zid=#form.zid#&sid=#form.sid#&returnId=#form.returnId#" method="post" >
		<input type="hidden" name="user_id" value="#form.user_id#">
		<table style="border-spacing:0px; width:100%;"  class="table-shadow"> 
			<cfif application.zcore.user.checkAllCompanyAccess()>
	
				<tr>
					<td style="vertical-align:top; width:140px;">Company:</td>
					<td  #application.zcore.status.getErrorStyle(Request.zsid, "company_id", "table-error","")#>
					
					<cfscript>
					db.sql="SELECT *
					FROM #db.table("company", request.zos.zcoreDatasource)# company
					WHERE company_deleted = #db.param(0)# and
					company_deleted=#db.param(0)# 
					ORDER BY company_name ASC";
					qcompany=db.execute("qcompany");
					selectStruct = StructNew();
					selectStruct.name = "company_id";
					selectStruct.query = qCompany;
					selectStruct.queryLabelField = "company_name";
					selectStruct.queryValueField = "company_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					<br />Note: A user associated with a company can only edit data for sites that are associated with their company regardless of the other permissions set.</td>
				</tr>
			</cfif>
			<cfscript>
			db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
			WHERE site_id = #db.param(form.sid)# and 
			user_group_deleted=#db.param(0)# ";
			qGroup=db.execute("qGroup");
			</cfscript>
			<tr>
				<td style="vertical-align:top; width:140px;">User Group:</td>
				<td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "user_group_id";
			selectStruct.selectLabel = "-- No Selection --"; // override default first element text
			// options for query data
			selectStruct.query = qGroup;
			selectStruct.queryLabelField = "user_group_friendly_name";
			selectStruct.queryValueField = "user_group_id";	
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript></td>
			</tr>
			<tr>
				<td style="vertical-align:top; width:140px;">First Name:</td>
				<td><input name="user_first_name" type="text" size="30" maxlength="50" value="#form.user_first_name#"></td>
			</tr>
			<tr>
				<td style="vertical-align:top; width:140px;">Last Name:</td>
				<td><input name="user_last_name" type="text" size="30" maxlength="50" value="#form.user_last_name#"></td>
			</tr>
			<tr>
				<td style="vertical-align:top; width:140px;">Email:</td>
				<td><input name="user_email" type="text" size="30" maxlength="50" value="#form.user_email#"></td>
			</tr>
			<tr>
				<td style="vertical-align:top; width:140px;">Username:</td>
				<td><input name="user_username" type="text" size="30" maxlength="50" value="#form.user_username#"></td>
			</tr>
			<tr>
				<td style="vertical-align:top; width:140px;">Password:</td>
				<td><input name="user_password" type="password" size="30" value=""></td>
			</tr>
			<tr>
				<td style="vertical-align:top; width:140px;">Site Administrator:</td>
				<td>
					<cfif currentMethod EQ "editUser" and request.zsession.user.id EQ qUser.user_id and request.zsession.user.site_id EQ qUser.site_id>
						<span class="highlight">Disabled</span>, You must login as another user to change administrative settings for your own account
					<cfelse>
						<input name="user_site_administrator" id="user_site_administrator" type="checkbox" onClick="checkUser(1);" value="1" <cfif form.user_site_administrator EQ 1>checked="checked"</cfif>>
						(Full access to the site this user belong to.)
					</cfif></td>
			</tr>
			<tr>
				<td style="vertical-align:top; width:140px;">Access Site Children:</td>
				<td>
					<cfif currentMethod EQ "editUser" and request.zsession.user.id EQ qUser.user_id and request.zsession.user.site_id EQ qUser.site_id>
						<span class="highlight">Disabled</span>, You must login as another user to change administrative settings for your own account
					<cfelse>
						<input name="user_access_site_children" id="user_access_site_children" type="checkbox" onClick="checkUser(2);" value="1" <cfif form.user_access_site_children EQ 1>checked="checked"</cfif>>
						(Grants full access to the children sites)
					</cfif></td>
			</tr>
			<cfif form.sid EQ '1'>
				<tr>
					<td style="vertical-align:top; width:140px;">Server Administrator:</td>
					<td><cfif currentMethod EQ "editUser" and request.zsession.user.id EQ qUser.user_id and request.zsession.user.site_id EQ qUser.site_id>
							<span class="highlight">Disabled</span>, You must login as another user to change administrative settings for your own account
							<cfelse>
							<input name="user_server_administrator" id="user_server_administrator" type="checkbox" onClick="checkUser(2);" value="1" <cfif form.user_server_administrator EQ 1>checked="checked"</cfif>>
							(Full access to all sites on server.)<br />

							<div style="padding:10px; width:90%;float:left; clear:both;<cfif form.user_server_administrator NEQ 1>display:none;</cfif>" id="serverAdminDiv">
								Optionally, limit access to the following sites and disable access to server manager: <br />
								<cfscript>
								application.zcore.functions.zRequireJqueryUI();
								application.zcore.skin.includeCSS("/z/javascript/jquery/jquery-ui-multiselect-widget/jquery.multiselect.css");
								application.zcore.skin.includeCSS("/z/javascript/jquery/jquery-ui-multiselect-widget/jquery.multiselect.filter.css");
								application.zcore.skin.includeJS("/z/javascript/jquery/jquery-ui-multiselect-widget/src/jquery.multiselect.js", '', 2);
								application.zcore.skin.includeJS("/z/javascript/jquery/jquery-ui-multiselect-widget/src/jquery.multiselect.filter.js", '', 2);
								application.zcore.skin.addDeferredScript('
									$("##user_server_admin_site_id_list").multiselect().multiselectfilter();
								');
								db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
								WHERE site_id <> #db.param(form.sid)# and 
								site_deleted = #db.param(0)# and
								site_active = #db.param(1)# 
								ORDER BY site_sitename ASC";
								qSites=db.execute("qSites");
								selectStruct = StructNew();
								selectStruct.multiple=true;
								selectStruct.size=10;
								selectStruct.inlineStyle="width:300px;";
								selectStruct.name = "user_server_admin_site_id_list";
								selectStruct.query = qSites;
								selectStruct.queryLabelField = "site_sitename";
								selectStruct.queryValueField = "site_id";
								application.zcore.functions.zInputSelectBox(selectStruct);
								</cfscript><br />
								If no sites are selected, the user will have full access to all sites and features.
							</div>


						</cfif></td>
				</tr>
				<tr>
					<td style="vertical-align:top; width:140px;">Intranet Administrator:</td>
					<td><input name="user_intranet_administrator" id="user_intranet_administrator" type="checkbox" value="1" <cfif form.user_intranet_administrator EQ 1>checked="checked"</cfif>>
						(Required to see errors directly in browser)</td>
				</tr>
			</cfif>
			<cfif currentMethod EQ "editUser" and request.zsession.user.id EQ qUser.user_id and request.zsession.user.site_id EQ qUser.site_id>
				<script>
				/* <![CDATA[ */ 
				function checkUser(num){
					if(document.userForm.user_server_administrator.checked){
						document.getElementById("serverAdminDiv").style.display='block';
					}else{
						document.getElementById("serverAdminDiv").style.display='none';
					}
					if(num == 1){
						if(document.userForm.user_site_administrator.checked == false){
							document.userForm.user_server_administrator.checked = false;
						}
					}else{
						if(document.userForm.user_server_administrator.checked || document.userForm.user_access_site_children.checked){
							document.userForm.user_site_administrator.checked = true;
						}else{
							document.userForm.user_site_administrator.checked = false;
						}
					}
				} /* ]]> */
				</script>
			<cfelse>
				<script>
				/* <![CDATA[ */ 
				function checkUser(num){
					if(document.userForm.user_server_administrator.checked){
						document.getElementById("serverAdminDiv").style.display='block';
					}else{
						document.getElementById("serverAdminDiv").style.display='none';
					}
				} /* ]]> */
				</script>
			</cfif>
	
			<!--- <cfif currentMethod EQ "editUser">
				<tr>
					<td style="vertical-align:top; width:140px;">Sign In With:</td>
					<td><cfscript>
					    openIdCom=createobject("component", "zcorerootmapping.com.user.openid");
					    writeoutput(openIdCom.displayOpenIdProviderForUser(qUser.user_id, qUser.site_id));
					    </cfscript></td>
				</tr>
			</cfif> --->
			<tr>
				<td style="width:140px;">&nbsp;</td>
				<td><input type="submit" name="submit" value="<cfif currentMethod EQ "editUser">Update<cfelse>Add</cfif> User">
					<input type="button" name="cancel" value="Cancel" onClick="window.location.href = '#application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#")#';"></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="addUserGroup" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	this.editUserGroup();
	</cfscript>
</cffunction>

<cffunction name="editUserGroup" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qGroup=0;
	var currentMethod=form.method;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.6.3");
	form.user_group_id = application.zcore.functions.zso(form, 'user_group_id',false,-1);
	db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE user_group_id = #db.param(form.user_group_id)# and 
	user_group_deleted = #db.param(0)# and
	site_id = #db.param(form.sid)# ";
	qGroup=db.execute("qGroup");
	application.zcore.functions.zQueryToStruct(qGroup);
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
	<h2><cfif currentMethod EQ "editUserGroup">
						Edit
					<cfelse>
						Add
					</cfif>
					User Group</h2>
	<table style="border-spacing:0px; width:100%;" class="table-list">
		<form class="zFormCheckDirty" action="/z/server-manager/admin/user/<cfif currentMethod EQ "editUserGroup">updateUserGroup<cfelse>insertUserGroup</cfif>?zid=#form.zid#&sid=#form.sid#&returnId=#form.returnId#&user_group_id=#form.user_group_id#" method="post">
			<tr>
				<td style="vertical-align:top; width:120px;">Name:</td>
				<td><input name="user_group_name" type="text" size="50" maxlength="50" value="#form.user_group_name#"> *</td>
			</tr>
			<tr>
				<td style="vertical-align:top; width:120px;">Friendly Name:</td>
				<td><input name="user_group_friendly_name" type="text" size="50" maxlength="255" value="#form.user_group_friendly_name#"> *</td>
			</tr>
			<cfscript>
			var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin"); 
			userGroupId = userGroupCom.getGroupId('user',request.zos.globals.id);
			db.sql="SELECT *FROM #db.table("user_group", request.zos.zcoreDatasource)#  
			WHERE site_id = #db.param(form.sid)# and 
			user_group_deleted = #db.param(0)#
			ORDER BY user_group_name asc"; //  and 		user_group_id <> #db.param(userGroupId)# 
			var qGroup2=db.execute("qGroup2", "", 10000, "query", false);
			</cfscript>
			<tr>
				<th>Enable Full Subuser<br>Management For These User Groups:</th>
				<td>
				<cfscript>
				ts = StructNew();
				ts.name = "user_group_manage_full_subuser_group_id_list";
				ts.friendlyName="";
				// options for query data
				ts.multiple=true;
				ts.query = qGroup2;
				ts.queryLabelField = "user_group_friendly_name";
				ts.queryValueField = "user_group_id";
				application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'user_group_manage_full_subuser_group_id_list'));
				application.zcore.functions.zInputSelectBox(ts);
				</cfscript> (Note: the person managing these users must have access to the same office these users are in.)</td>
			</tr>
			<tr>
				<th>Enable Partial Subuser<br>Management For These User Groups:</th>
				<td>
				<cfscript>
				ts = StructNew();
				ts.name = "user_group_manage_partial_subuser_group_id_list";
				ts.friendlyName="";
				// options for query data
				ts.multiple=true;
				ts.query = qGroup2;
				ts.queryLabelField = "user_group_friendly_name";
				ts.queryValueField = "user_group_id";
				application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'user_group_manage_partial_subuser_group_id_list'));
				application.zcore.functions.zInputSelectBox(ts);
				</cfscript> (Note: the person managing these users must have access to the same office these users are in.)</td>
			</tr> 
			<tr>
				<td style="width:120px;">&nbsp;</td>
				<td><input type="submit" name="submit" value="<cfif currentMethod EQ "editUserGroup">Update<cfelse>Add</cfif> User Group">
					<input type="button" name="cancel" value="Cancel" onClick="window.location.href = '#application.zcore.status.getField(form.returnId, "url","/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#")#';"></td>
			</tr>
		</form>
	</table>
</cffunction>

<cffunction name="listGroup" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qUserList=0;
	var qGroup=0;
	var rollOverCode=0;
	var usergroupfriendlyname=0;
	var inputStruct=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.6.1");
	application.zcore.functions.zStatusHandler(Request.zsid);
	db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE user_group_id = #db.param(application.zcore.functions.zso(form, 'user_group_id'))# and 
	user_group_deleted = #db.param(0)# and 
	site_id =#db.param(form.sid)#";
	qGroup=db.execute("qGroup");
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user
	WHERE user_group_id = #db.param(application.zcore.functions.zso(form, 'user_group_id'))# and 
	user_deleted = #db.param(0)# and 
	site_id = #db.param(form.sid)#";
	if(isDefined('request.zsession.zsaUsersOnly')){
		db.sql&=" and user_system = #db.param('1')#";
	}
	db.sql&=" ORDER BY user_first_name ASC";
	qUserList=db.execute("qUserList"); 
	if(qGroup.recordcount EQ 0){		
		application.zcore.status.setStatus(Request.zsid, "This user group no longer exists.",false,true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#"&"&returnId=#form.returnId#&zsid=#Request.zsid#");
	}
	</cfscript>
	<h2>Manage Users</h2>
	<table style="border-spacing:0px;" class="table-list">
		<cfif qGroup.user_group_friendly_name NEQ "">
			<cfset usergroupfriendlyname = qGroup.user_group_friendly_name>
		<cfelse>
			<cfset usergroupfriendlyname = qGroup.user_group_name>
		</cfif>
		<tr>
			<td class="table-shadow" colspan="6">`#usergroupfriendlyname#` user group&nbsp;</td>
		</tr>
		<tr>
			<td>Name</td>
			<td>Username</td>
			<td>Permissions</td>
			<td>Created</td>
			<td>Admin</td>
		</tr>
		<cfif qUserList.recordcount EQ 0>
			<tr>
				<td  colspan="6">There are no users in this group.</td>
			</tr>
		</cfif>
		<cfloop query="qUserList">
			<cfscript>
			// create input structure
			inputStruct = StructNew();
			// required
			inputStruct.currentRow = qUserList.currentRow;
			inputStruct.style = "table-bright";
			inputStruct.style2 = "table-bright";
			inputStruct.styleOver = "table-white";
			inputStruct.output = false;
			inputStruct.name = "user_rollover"; // must follow variable naming conventions
			// run function
			rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
			</cfscript>
			<tr #rollOverCode#>
				<td >#qUserList.user_first_name# #qUserList.user_last_name#&nbsp;</td>
				<td >#qUserList.user_username#&nbsp;</td>
				<td><cfif qUserList.user_server_administrator EQ 1>
						Server
					<cfelseif qUserList.user_site_administrator EQ 1>
						Site
					<cfelse>
						Group
					</cfif></td>
				<td><cfif qUserList.user_system EQ 1>
						In Server Manager
					<cfelse>
						Custom User Script
					</cfif></td>
				<td ><cfif isDefined('request.zsession.user.id') and request.zsession.user.id NEQ qUserList.user_id>
						<cfif qUserList.user_active EQ 1>
							<a href="/z/server-manager/admin/user/deactivate?zid=#form.zid#&amp;sid=#form.sid#&amp;returnId=#form.returnId#&amp;user_id=#qUserList.user_id#">Deactivate</a>
						<cfelse>
							<a href="/z/server-manager/admin/user/activate?zid=#form.zid#&amp;sid=#form.sid#&amp;returnId=#form.returnId#&amp;user_id=#qUserList.user_id#">Activate</a>
						</cfif>
						|
					</cfif>
					<a href="/z/server-manager/admin/user/editUser?zid=#form.zid#&amp;sid=#form.sid#&amp;returnId=#form.returnId#&amp;user_id=#qUserList.user_id#">Edit</a> |
					<cfif isDefined('request.zsession.user.id') and request.zsession.user.id EQ qUserList.user_id and request.zsession.user.site_id EQ qUserList.site_id>
						<span class="highlight">Required</span>
					<cfelse>
						<a href="/z/server-manager/admin/user/deleteUser?zid=#form.zid#&amp;sid=#form.sid#&amp;returnId=#form.returnId#&amp;user_id=#qUserList.user_id#">Delete</a>
					</cfif></td>
			</tr>
		</cfloop>
	</table>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qUserList=0;
	var inputStruct=0;
	var rolloverCode=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.6");
	application.zcore.functions.zStatusHandler(Request.zsid);
	db.sql=" SELECT *
	FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE site_id = #db.param(form.sid)# and 
	user_group_deleted = #db.param(0)# 
	ORDER BY user_group_name ASC";
	qUserList=db.execute("qUserList");
	</cfscript>
	<h2>User Groups</h2>
	<table style="border-spacing:0px; width:100%;" class="table-list">
		<tr class="table-shadow">
			<td>Name</td>
			<td>Friendly Name</td>
			<td>Admin</td>
		</tr>
		<cfif qUserList.recordcount EQ 0>
			<tr>
				<td colspan="3">There are no user groups for this site.</td>
			</tr>
		</cfif>
		<cfloop query="qUserList">
			<cfscript>
			// create input structure
			inputStruct = StructNew();
			// required
			inputStruct.currentRow = qUserList.currentRow;
			inputStruct.style = "table-bright";
			inputStruct.style2 = "table-bright";
			inputStruct.styleOver = "table-white";
			inputStruct.output = false;
			inputStruct.name = "user_rollover"; // must follow variable naming conventions
			// run function
			rollOverCode = application.zcore.functions.zStyleRollOver(inputStruct);
			</cfscript>
			<tr #rollOverCode#>
				<td>#qUserList.user_group_name#&nbsp;</td>
				<td >#qUserList.user_group_friendly_name#&nbsp;</td>
				<td ><a href="/z/server-manager/admin/user/listGroup?zid=#form.zid#&amp;sid=#form.sid#&amp;user_group_id=#qUserList.user_group_id#">View Users</a> | 

				<a href="/z/server-manager/admin/user/sendUserGroupPasswordResetEmail?zid=#form.zid#&amp;sid=#form.sid#&amp;user_group_id=#qUserList.user_group_id#">Send Password Reset To Group</a> | 
				<a href="/z/server-manager/admin/user/editUserGroup?zid=#form.zid#&amp;sid=#form.sid#&amp;returnId=#form.returnId#&amp;user_group_id=#qUserList.user_group_id#">Edit</a> |
					<cfif isDefined('request.zsession.user.group_id') and request.zsession.user.group_id NEQ qUserList.user_group_id>
						<a href="/z/server-manager/admin/user/deleteUserGroup?zid=#form.zid#&amp;sid=#form.sid#&amp;returnId=#form.returnId#&amp;user_group_id=#qUserList.user_group_id#">Delete</a>
					<cfelse>
						<span class="highlight">Required</span>
					</cfif>
					&nbsp;</td>
			</tr>
		</cfloop>
	</table>
</cffunction>



<cffunction name="sendUserGroupPasswordResetEmail" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	variables.init();
	setting requesttimeout="10000";
	var db=request.zos.queryObject;
	form.confirm=application.zcore.functions.zso(form, 'confirm', true, 0);
	form.user_group_id=application.zcore.functions.zso(form, 'user_group_id', true);
	form.sid=application.zcore.functions.zso(form, 'sid', true);

	db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# 
	WHERE user_group_id=#db.param(form.user_group_id)# and 
	site_id = #db.param(form.sid)# and
	user_group_deleted = #db.param(0)#";
	qGroup=db.execute("qGroup");   
	if(qGroup.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid user group id", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#");
	}
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# 
	WHERE user_group_id=#db.param(form.user_group_id)# and 
	site_id = #db.param(form.sid)# and
	user_deleted = #db.param(0)# and 
	user_active=#db.param(1)# ";
	qUser=db.execute("qUser");  
	if(form.confirm EQ 1){
		if(request.zos.isTestServer){
			echo("This script would have sent password reset emails to "&qUser.recordcount&" users, but this function is disabled on the test server. We want to avoid accidentally bulk emailing real people invalid links.");
			abort;
		}
 
		rpCom=createobject("component", "zcorerootmapping.mvc.z.user.controller.reset-password");
		count=0;
		for(row in qUser){ 
			rs=rpCom.sendPasswordResetEmail(row.user_username, row.site_id);
			if(not rs.success){
				application.zcore.status.setStatus(request.zsid, "Error occurred for #qUser.user_username#: "&rs.errorMessage, form, true);
			}else{
				count++;
			}
		}

		application.zcore.status.setStatus(request.zsid, "#count# password reset emails sent to all users in the group: #qGroup.user_group_name#");
		application.zcore.functions.zRedirect("/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#&zsid=#request.zsid#");
	}else{
		echo('<h2>Are you sure you want to send a password reset email to all users in this group?<br /><br />
			Group: #qGroup.user_group_name#<br /><br />
			#qUser.recordcount# users<br /><br />
			<a href="/z/server-manager/admin/user/sendUserGroupPasswordResetEmail?confirm=1&user_group_id=#form.user_group_id#&zid=#form.zid#&sid=#form.sid#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/server-manager/admin/user/index?zid=#form.zid#&sid=#form.sid#">No</a></h2>');
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
