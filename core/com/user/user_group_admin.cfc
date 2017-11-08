<cfcomponent displayname="User Group Admin" output="no" hint="Used for administrating user groups">
	<cfoutput><cfscript>
	this.comName='zcorerootmapping.com.user.user_group_admin.cfc';
	</cfscript>
	<!--- To use a component, you create it as an object and call its methods like so...
	userGroupCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.user_group");
	userGroupCom.getPermissions(user_group_id, site_id);
	 --->
	 
	<!---  
	inputStruct = structNew();
	// required 
	inputStruct.user_group_name = application.zcore.functions.zso(form, 'user_group_name');
	inputStruct.site_id = application.zcore.functions.zVar('id'); 
	// optional
	inputStruct.user_group_friendly_name = application.zcore.functions.zso(form, 'user_group_friendly_name');
	user_group_id = userGroupCom.add(inputStruct);
	if(user_group_id EQ false){
		// duplicate entry
	}else{
		// successful
	}
	--->
	<cffunction name="add" localmode="modern" output="false" returntype="any">
		<cfargument name="inputStruct" required="yes" type="struct">
		<cfscript>
		var i = 0;
		var arrTemp = ArrayNew(1);
		var ls = "";
		var qReplace = "";
		var qGetUserServerAdmin = "";
		var qGetUserAdmin = "";
		var tempStruct = StructNew();
		var inputStruct2 = StructNew();
		var str = "";
		
		// override defaults
		StructAppend(arguments.inputStruct, tempStruct, false);
		str = arguments.inputStruct; // less typing 
		</cfscript>
		<cfif structkeyexists(str, 'user_group_name') EQ false>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_group.add: inputStruct.user_group_name required.">
		</cfif>
		<cfif structkeyexists(str, 'site_id') EQ false>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_group.add: inputStruct.site_id required.">
		</cfif>
		
		<cfscript>
		str.user_group_name = application.zcore.functions.zURLEncode(str.user_group_name,"_");
		variables.str = str;
		inputStruct2.table = "user_group";
		inputStruct2.datasource="#request.zos.zcoreDatasource#";
		inputStruct2.struct = str;
		str.user_group_id = application.zcore.functions.zInsert(inputStruct2);
		if(str.user_group_id EQ false){
			return false; // session name not unique for current site_id
		}
		this.setDefaultPermissions(str.user_group_id, str.site_id);
		return str.user_group_id;		
		</cfscript>
	</cffunction>
	
	
	
	<!---  
	inputStruct = structNew();
	// required 
	inputStruct.user_group_name = application.zcore.functions.zso(form, 'user_group_name');
	inputStruct.site_id = application.zcore.functions.zVar('id'); 
	// optional
	inputStruct.user_group_friendly_name = application.zcore.functions.zso(form, 'user_group_friendly_name');
	if(userGroupCom.update(inputStruct) EQ false){
		// duplicate entry
	}else{
		// successful
	}
	--->
	<cffunction name="update" localmode="modern" output="false" returntype="any">
		<cfargument name="inputStruct" required="yes" type="struct">
		<cfscript>
		var i = 0;
		var arrTemp = ArrayNew(1);
		var ls = "";
		var str = "";
		var qReplace = "";
		var qGetUserServerAdmin = "";
		var qGetUserAdmin = "";
		var tempStruct = StructNew();
		var inputStruct2 = StructNew();
		
		// override defaults
		StructAppend(arguments.inputStruct, tempStruct, false);
		str = arguments.inputStruct; // less typing
		</cfscript>
		<cfif isDefined('str.user_group_name') EQ false>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_group.update: inputStruct.user_group_name required.">
		</cfif>
		<cfif isDefined('str.user_group_id') EQ false>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_group.update: inputStruct.user_group_id required.">
		</cfif>
		<cfif isDefined('str.site_id') EQ false>
			<cfthrow type="exception" message="Error: COMPONENT: zcorerootmapping.com.user.user_group.update: inputStruct.site_id required.">
		</cfif>
		
		<cfscript>
		str.user_group_name = application.zcore.functions.zURLEncode(str.user_group_name,"_");
		variables.str = str;
		inputStruct2.table = "user_group";
		inputStruct2.datasource="#request.zos.zcoreDatasource#";
		inputStruct2.struct = str;
		if(application.zcore.functions.zUpdate(inputStruct2) EQ false){
			return false; // session name not unique for current site_id
		}else{
			this.setDefaultPermissions(str.user_group_id, str.site_id);
			return true;
		}
		</cfscript>	
	</cffunction>
	
	
	<!--- userGroupCom.delete(user_group_id, site_id); --->
	<cffunction name="delete" localmode="modern" output="false" returntype="any">
		<cfargument name="user_group_id" type="string" required="yes">
		<cfargument name="site_id" type="string" required="yes">
		<cfscript>
		var local=structnew();
		var qAdmin=0;
		var db=request.zos.queryObject;
		var qDelete = "";
		</cfscript>
		<cfsavecontent variable="db.sql">
		DELETE FROM #db.table("user_group", request.zos.zcoreDatasource)#  
		WHERE user_group_id = #db.param(arguments.user_group_id)# and 
		user_group_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#
		</cfsavecontent><cfscript>qDelete=db.execute("qDelete");</cfscript>
		<cfsavecontent variable="db.sql">
		DELETE FROM #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
		WHERE user_group_id = #db.param(arguments.user_group_id)# and 
		user_group_x_group_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#
		</cfsavecontent><cfscript>qDelete=db.execute("qDelete");</cfscript>
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
		WHERE user_group_name = #db.param('administrator')# and 
		user_group_deleted = #db.param(0)# and 
		site_id = #db.param(Request.zos.globals.serverId)# 
		</cfsavecontent><cfscript>qAdmin=db.execute("qAdmin");</cfscript>
		<cfsavecontent variable="db.sql">
		DELETE FROM #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
		WHERE user_group_child_id = #db.param(arguments.user_group_id)# and 
		user_group_x_group_deleted = #db.param(0)# and
		(site_id = #db.param(arguments.site_id)# or 
		user_group_id = #db.param(qAdmin.user_group_id)#)
		</cfsavecontent><cfscript>qDelete=db.execute("qDelete");</cfscript>
		<cfsavecontent variable="db.sql">
		UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
		SET user_group_id = #db.param(0)# 
		WHERE user_group_id = #db.param(arguments.user_group_id)# and 
		user_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#
		</cfsavecontent><cfscript>qDelete=db.execute("qDelete");</cfscript>
		<cfreturn true>	
	</cffunction>
	
	
	<!--- userAccessCom.getPrimary(site_id); --->
	<cffunction name="getPrimary" localmode="modern" output="false" returntype="any">
		<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
        <cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		</cfscript>
		<cfsavecontent variable="db.sql">
		SELECT user_group_id FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
		WHERE user_group_primary = #db.param(1)# and 
		user_group_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)# 
		</cfsavecontent><cfscript>qPrimary=db.execute("qPrimary");
		if(qPrimary.recordcount EQ 0){
			application.zcore.template.fail("#this.comName#: getPrimary: No primary user group for site_id, #arguments.site_id#.");
		}
		</cfscript>
		<cfreturn qPrimary.user_group_id>
	</cffunction>
	
	<!--- userAccessCom.setPrimary(user_group_id, site_id); --->
	<cffunction name="setPrimary" localmode="modern" output="false" returntype="any">
		<cfargument name="user_group_id" type="string" required="yes">
		<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
        <cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
		</cfscript>
			<cfsavecontent variable="db.sql">
			UPDATE #db.table("user", request.zos.zcoreDatasource)# user_group 
			SET user_group_primary = #db.param(0)# 
			WHERE site_id = #db.param(arguments.site_id)# and 
			user_group_deleted = #db.param(0)#
			</cfsavecontent><cfscript>qFlush=db.execute("qFlush");</cfscript>
			<cfsavecontent variable="db.sql">
			UPDATE #db.table("user", request.zos.zcoreDatasource)# user_group 
			SET user_group_primary = #db.param(1)# 
			WHERE user_group_id = #db.param(user_group_id)# and 
			site_id = #db.param(arguments.site_id)# and 
			user_group_deleted = #db.param(0)#
			</cfsavecontent><cfscript>qUpdate=db.execute("qUpdate");</cfscript>
	</cffunction>
	
	
	
	
	<!--- userAccessCom.getPermissions(user_group_id, site_id); --->
	<cffunction name="getPermissions" localmode="modern" output="false" returntype="any">
		<cfargument name="user_group_id" type="string" required="yes">
		<cfargument name="site_id" type="string" required="yes">
        <cfscript>
		var db=request.zos.queryObject;
		var local=structnew();
		</cfscript>
		<!--- option: all sites or current site only! --->
		<cfsavecontent variable="db.sql">
		SELECT user_group_x_group.*, user_group.* 
		FROM #db.table("user_group_x_group", request.zos.zcoreDatasource)# user_group_x_group, 
		#db.table("user_group", request.zos.zcoreDatasource)# user_group 
		WHERE user_group.user_group_id = user_group_x_group.user_group_id and 
		user_group.site_id = user_group_x_group.site_id and 
		user_group_x_group.site_id = #db.param(arguments.site_id)#  and 
		user_group_x_group.user_group_id = #db.param(arguments.user_group_id)# and 
		user_group_deleted = #db.param(0)# and 
		user_group_x_group_deleted = #db.param(0)# 
		</cfsavecontent><cfscript>qAccess=db.execute("qAccess");</cfscript>
		<cfreturn qAccess>
	</cffunction>
	
	
	
	<!--- userAccessCom.setPermissions(user_group_id, site_id, user_group_id_list, user_group_id_modify_user, user_group_share_user, user_group_x_group_type); --->
	<cffunction name="setPermissions" localmode="modern" output="true" returntype="any">
		<cfargument name="user_group_id" type="string" required="yes">
		<cfargument name="site_id" type="string" required="yes">
		<cfargument name="user_group_id_login_access" type="string" required="yes">
		<cfargument name="user_group_id_modify_user" type="string" required="yes">
		<cfargument name="user_group_share_user" type="string" required="yes">
		<cfargument name="user_group_x_group_type" type="string" required="yes">
		<cfscript>
		var qDelete = "";
		var db=request.zos.queryObject;
		var modifyUser=0;
		var result=0;
		var current=0;
		var shareUser=0;
		var i=0;
		var local=structnew();
		var db=request.zos.queryObject;
		</cfscript>
		<cfsavecontent variable="db.sql">
		DELETE FROM #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
		WHERE user_group_id = #db.param(arguments.user_group_id)# and 
		user_group_child_id <> #db.param(arguments.user_group_id)# and 
		site_id =#db.param(arguments.site_id)# and 
		user_group_x_group_deleted = #db.param(0)#
		</cfsavecontent><cfscript>qDelete=db.execute("qDelete");</cfscript>
		<cfsavecontent variable="db.sql">
		UPDATE #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
		SET user_group_share_user=#db.param(0)#, 
		user_group_modify_user =#db.param(0)# 
		WHERE user_group_id = #db.param(arguments.user_group_id)# and 
		user_group_child_id = user_group_id and 
		site_id =#db.param(arguments.site_id)# and 
		user_group_x_group_deleted = #db.param(0)# 
		</cfsavecontent><cfscript>qDelete=db.execute("qDelete");
		if(arguments.user_group_id_login_access NEQ ""){
			for(i=1;i LTE listLen(arguments.user_group_id_login_access);i=i+1){
				current = listGetAt(arguments.user_group_id_login_access,i);
				modifyUser='0';
				shareUser='0';
				if(arguments.user_group_id_modify_user NEQ ""){
					for(n=1;n LTE listLen(arguments.user_group_id_modify_user);n=n+1){
						if(listGetAt(user_group_id_modify_user,n) EQ current){
							modifyUser='1';
							listDeleteAt(user_group_id_modify_user,n);
							break;
						}
					}
				}
				if(arguments.user_group_share_user NEQ ""){
					for(n=1;n LTE listLen(arguments.user_group_share_user);n=n+1){
						if(listGetAt(user_group_share_user,n) EQ current){
							shareUser='1';
							listDeleteAt(user_group_share_user,n);
							break;
						}
					}
				}
				db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
				SET user_group_id = #db.param(arguments.user_group_id)#, 
				user_group_child_id = #db.param(current)#, 
				user_group_login_access = #db.param(1)#, 
				user_group_modify_user = #db.param(modifyUser)#, 
				user_group_share_user = #db.param(shareUser)#, 
				user_group_x_group_updated_datetime=#db.param(request.zos.mysqlnow)# ,
				site_id = #db.param(arguments.site_id)#, 
				user_group_x_group_deleted=#db.param(0)# ";
	   			result=db.insert("qInsert", request.zOS.insertIDColumnForSiteIDTable);
				if(not result.success){
					 db.sql="UPDATE #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
					 SET user_group_login_access = #db.param(1)#, 
					 user_group_modify_user = #db.param(modifyUser)#, 
					 user_group_share_user = #db.param(shareUser)#,
					 user_group_x_group_updated_datetime=#db.param(request.zos.mysqlnow)#  
					WHERE user_group_id = #db.param(arguments.user_group_id)# and  
					user_group_child_id = #db.param(current)# and  
					site_id = #db.param(arguments.site_id)# and 
					user_group_x_group_deleted = #db.param(0)#";
					result=db.execute("result");
				}
			}
		}
		if(arguments.user_group_id_modify_user NEQ ""){
			for(i=1;i LTE listLen(arguments.user_group_id_modify_user);i=i+1){
				current = listGetAt(user_group_id_modify_user,i);
				shareUser='0';
				if(arguments.user_group_share_user NEQ ""){
					for(n=1;n LTE listLen(arguments.user_group_share_user);n=n+1){
						if(listGetAt(user_group_share_user,n) EQ current){
							shareUser='1';
							listDeleteAt(user_group_share_user,n);
							break;
						}
					}
				}
				 db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
				 SET user_group_id = #db.param(arguments.user_group_id)#, 
				 user_group_child_id = #db.param(current)#, 
				 user_group_modify_user = #db.param(1)#, 
				 user_group_share_user = #db.param(shareUser)#, 
				 user_group_x_group_updated_datetime=#db.param(request.zos.mysqlnow)# ,
				 site_id = #db.param(arguments.site_id)#, 
				user_group_x_group_deleted=#db.param(0)# ";
	   			result=db.insert("qInsert", request.zOS.insertIDColumnForSiteIDTable);
				if(not result.success){ 
					db.sql="UPDATE #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
					SET user_group_modify_user = #db.param(1)#, 
					user_group_share_user = #db.param(shareUser)#,
					user_group_x_group_updated_datetime=#db.param(request.zos.mysqlnow)# 
					WHERE user_group_id = #db.param(arguments.user_group_id)# and  
					user_group_child_id = #db.param(current)# and  
					site_id = #db.param(arguments.site_id)# and 
					user_group_x_group_deleted = #db.param(0)# ";
					result=db.execute("result");
				}
			}
		}
		if(arguments.user_group_share_user NEQ ""){
			for(i=1;i LTE listLen(arguments.user_group_share_user);i=i+1){
				current = listGetAt(user_group_share_user,i);
				 db.sql="INSERT INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
				 SET user_group_id = #db.param(arguments.user_group_id)#, 
				 user_group_child_id = #db.param(current)#, 
				 user_group_share_user = #db.param(1)#, 
				user_group_x_group_updated_datetime=#db.param(request.zos.mysqlnow)#, 
				 site_id = #db.param(arguments.site_id)#, 
				user_group_x_group_deleted=#db.param(0)# ";
	    			result=db.insert("qInsert", request.zOS.insertIDColumnForSiteIDTable);
				if(not result.success){				
					 db.sql="UPDATE #db.table("user_group_x_group", request.zos.zcoreDatasource)#  SET 
					user_group_share_user = #db.param('1')#,
					user_group_x_group_updated_datetime=#db.param(request.zos.mysqlnow)# 
					WHERE user_group_id = #db.param(arguments.user_group_id)# and  
					user_group_child_id = #db.param(current)# and  
					site_id = #db.param(arguments.site_id)# and 
					user_group_x_group_deleted = #db.param(0)#";
					db.execute("q");
				}
			}
		}
		</cfscript>
		<cfreturn true>
	</cffunction>
	
	
	<!--- userAccessCom.setDefaultPermissions(user_group_id); --->
	<cffunction name="setDefaultPermissions" localmode="modern" output="true" returntype="any">
		<cfargument name="user_group_id" type="string" required="yes">
		<cfargument name="site_id" type="string" required="yes">
		<cfscript>
		var qAdmin = "";
		var db=request.zos.queryObject;
		var qGroup=0;
		var cfcatch=0;
		var local=structnew();
		db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
		WHERE user_group_id = #db.param(arguments.user_group_id)# and 
		site_id = #db.param(arguments.site_id)# and 
		user_group_deleted = #db.param(0)#";
		qGroup=db.execute("qGroup");
		db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
		WHERE user_group_name = #db.param('administrator')# and 
		site_id = #db.param(Request.zos.globals.serverId)# and 
		user_group_deleted = #db.param(0)#";
		qAdmin=db.execute("qAdmin");
		// allow server manager administrators to access all groups
		db.sql="REPLACE INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
		SET user_group_id = #db.param(qAdmin.user_group_id)#, 
		user_group_child_id = #db.param(arguments.user_group_id)#, 
		user_group_login_access = #db.param(1)#, 
		user_group_modify_user = #db.param(0)#, 
		user_group_share_user = #db.param(0)#, 
		site_id = #db.param(Request.zos.globals.serverId)# and 
		user_group_x_group_deleted = #db.param(0)#"; 
		 db.execute("q"); 
		// allow the group to access itself
		 db.sql="REPLACE INTO #db.table("user_group_x_group", request.zos.zcoreDatasource)#  
		 SET user_group_id = #db.param(arguments.user_group_id)#, 
		 user_group_child_id = #db.param(arguments.user_group_id)#, 
		 user_group_login_access = #db.param('1')#, 
		user_group_modify_user = #db.param(0)#, 
		user_group_share_user = #db.param(0)#, 
		 site_id = #db.param(qGroup.site_id)# and 
		 user_group_x_group_deleted = #db.param(0)#"; 
		 db.execute("q"); 
		</cfscript>
		<cfreturn true>
	</cffunction>
	
	
	
	<!--- userGroupCom.getPrimaryId(user_group_id, site_id); --->
	<cffunction name="getPrimaryId" localmode="modern" returntype="any" output="false">
		<cfscript>
		return request.zos.globals.user_group.primary;
		</cfscript>
	</cffunction>
	
	<!--- userGroupCom.getGroupName(user_group_id, site_id); --->
	<cffunction name="getGroupName" localmode="modern" returntype="any" output="false">
		<cfargument name="user_group_id" type="string" required="yes">
		<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
        <cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		if(request.zos.globals.id NEQ arguments.site_id){
			db.sql="SELECT user_group_name FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
			WHERE user_group_id=#db.param(arguments.user_group_id)# and 
			user_group_deleted = #db.param(0)# and 
			site_id=#db.param(arguments.site_id)#";
			qSite=db.execute("qSite");
			try{
				return qSite.user_group_name;
			}catch(Any excpt){
				application.zcore.template.fail("#this.comName#: getGroupId: user_group_name, #arguments.user_group_name#, doesn't exist.");
			}
		}else{
			try{
				return request.zos.globals.user_group.ids[arguments.user_group_id];
			}catch(Any excpt){
				application.zcore.template.fail("#this.comName#: getGroupId: user_group_id, #user_group_id#, doesn't exist.");
			}
		}
		</cfscript>
	</cffunction>
	
	<!--- userGroupCom.getGroupDisplayName(user_group_id, site_id); --->
	<cffunction name="getGroupDisplayName" localmode="modern" returntype="any" output="false">
		<cfargument name="user_group_id" type="string" required="yes">
		<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
        <cfscript>
		var local=structnew();
		var db=request.zos.queryObject;
		</cfscript>
		<cfif request.zos.globals.id NEQ arguments.site_id>
			<cfsavecontent variable="db.sql">
			SELECT user_group_name, user_group_friendly_name FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
			WHERE user_group_id=#db.param(arguments.user_group_id)# and 
			user_group_deleted = #db.param(0)# and 
			site_id=#db.param(arguments.site_id)#
			</cfsavecontent><cfscript>qSite=db.execute("qSite");
			try{
				if(qSite.user_group_friendly_name NEQ ""){
					return qSite.user_group_friendly_name;
				}else{
					return qSite.user_group_name;
				}
			}catch(Any excpt){
				application.zcore.template.fail("#this.comName#: getGroupId: user_group_name, #arguments.user_group_name#, doesn't exist.");
			}
			</cfscript>
		<cfelse>
			<cfscript>
			try{
				if(structkeyexists(request.zos.globals.user_group, 'ids_names')){
					return request.zos.globals.user_group.ids_names[arguments.user_group_id];
				}else{
					return request.zos.globals.user_group.ids[arguments.user_group_id];
				}
			}catch(Any excpt){
				throw("#this.comName#: getGroupId: user_group_id, #user_group_id#, doesn't exist.");
			}
			</cfscript>
		</cfif>
	</cffunction>
	
<!--- userGroupCom.getGroupId(user_group_name, site_id); --->
<cffunction name="getGroupId" localmode="modern" returntype="any" output="false">
	<cfargument name="user_group_name" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var excpt=0;
	var cfcatch=0;
	var qSite=0;
	var local=structnew();
	var db=request.zos.queryObject;
	</cfscript>
	<cfif request.zos.globals.id NEQ arguments.site_id>
		<cfsavecontent variable="db.sql">
		SELECT user_group_id FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
		WHERE user_group_name=#db.param(arguments.user_group_name)# and 
		user_group_deleted = #db.param(0)# and 
		site_id=#db.param(arguments.site_id)#
		</cfsavecontent><cfscript>qSite=db.execute("qSite");
		try{
			return qSite.user_group_id;
		}catch(Any excpt){
			application.zcore.template.fail("#this.comName#: getGroupId: user_group_name, #arguments.user_group_name#, doesn't exist.");
		}
		</cfscript>
	<cfelse>
		<cfscript>
		try{
			return request.zos.globals.user_group.names[arguments.user_group_name];
		}catch(Any excpt){
			application.zcore.template.fail("#this.comName#: getGroupId: user_group_name, #arguments.user_group_name#, doesn't exist.");
		}
		</cfscript>
	</cfif>
</cffunction>
	
	</cfoutput>
</cfcomponent>