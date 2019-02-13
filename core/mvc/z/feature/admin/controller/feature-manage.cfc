<cfcomponent>
<cfoutput> 
<!--- TODO: convert to the manager-base eventually --->
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	featureSchemaCom=createobject("component", "feature-schema");
	featureSchemaCom.displayoptionAdminNav();
	</cfscript>
</cffunction>
      

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	application.zcore.functions.zSetPageHelpId("2.11.1");
	application.zcore.functions.zstatushandler(request.zsid); 
	db.sql="SELECT * 
	FROM #db.table("feature", "jetendofeature")#, 
	#db.table("site", request.zos.zcoreDatasource)#  
	WHERE
	feature.feature_deleted = #db.param(0)# and  
	feature.site_id = site.site_id and 
	site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# 
	order by feature.feature_display_name ASC ";
	qFeature=db.execute("qFeature"); 
	</cfscript>
	<p>
		<a href="/z/feature/admin/feature-manage/add">Add Feature</a> 
	</p> 
	<table style="border-spacing:0px;" class="table-list" >
		<tr>
			<th>ID</th>
			<th>Feature Name</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qFeature">
		<tr <cfif qFeature.currentrow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
			<td>#qFeature.feature_id#</td>
			<td>#qFeature.feature_variable_name#</td> 
			<td>
				<cfif qFeature.site_id NEQ request.zos.globals.id>
					Manage feature on <a href="#qFeature.site_domain#/manager/">#qFeature.site_domain#</a>
				<cfelse>
					<a href="/z/feature/admin/feature-manage/edit?feature_id=#qFeature.feature_id#">Edit</a> | 
					<a href="/z/feature/admin/feature-schema/index?feature_id=#qFeature.feature_id#">Manage Schemas</a> | 
					<a href="/z/feature/admin/feature-manage/delete?feature_id=#qFeature.feature_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Delete</a>
				</cfif>
			</td>
		</tr>
		</cfloop>
	</table>
</cffunction>


<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	
	form.feature_id=application.zcore.functions.zso(form,'feature_id');
	db.sql="SELECT feature.*, if(feature_schema_id IS NULL, #db.param(0)#, #db.param(1)#) hasSchema 
	FROM #db.table("feature", "jetendofeature")# 
	LEFT JOIN #db.table("feature_schema", "jetendofeature")# ON 
	feature.feature_id = feature_schema.feature_id and 
	feature_schema_deleted=#db.param(0)#  
	WHERE 
	feature.feature_id = #db.param(form.feature_id)# and 
	feature.site_id = #db.param(request.zos.globals.id)# and 
	feature_deleted = #db.param(0)# 
	GROUP BY feature.feature_id ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Feature is missing");
		application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/index?zsid="&request.zsid);
	}
	if(qCheck.feature_schema_id NEQ ""){
		application.zcore.status.setStatus(request.zsid, "You must delete all schema for this feature before you can delete it.");
		application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/index?zsid="&request.zsid);
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript> 
		application.zcore.status.setStatus(request.zsid, "Feature deleted successfully.");
		form.site_id = request.zos.globals.id;
		application.zcore.functions.zDeleteRecord("feature", "feature_id,site_id", "jetendofeature");

		structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);
		//application.zcore.functions.zOS_cacheSiteAndUserSchemas(request.zos.globals.id); 
		if(structkeyexists(request.zsession, "feature_return"&form.feature_id) and request.zsession['feature_return'&form.feature_id] NEQ ""){
			tempLink=request.zsession["feature_return"&form.feature_id];
			structdelete(request.zsession,"feature_return"&form.feature_id);
			application.zcore.functions.z301Redirect(replace(tempLink, "zsid=", "ztv=", "all"));
		}else{
			application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/index?zsid="&request.zsid);
		}
		</cfscript>
	<cfelse>
		<cfscript>
		theTitle="Delete Feature";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<h2> Are you sure you want to delete this Feature?<br />
		<br />
		Feature: #qcheck.feature_display_name#<br />
		<br />
		<a href="/z/feature/admin/feature-manage/delete?confirm=1&feature_id=#form.feature_id#&zrand=#gettickcount()#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/feature/admin/feature-manage/index">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">    
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	 
	errors=false;
	if(form.feature_display_name EQ ""){
		application.zcore.status.setStatus(request.zsid, "Display Name is required.", form, true);
		errors=true;
	}
	if(form.feature_variable_name EQ ""){
		application.zcore.status.setStatus(request.zsid, "Variable Name must be a valid Java/CFML variable name.", form, true);
		errors=true;
	} 
	if(form.method EQ "update"){
		db.sql="select feature.*, 
		if(feature_schema_id IS NULL, #db.param(0)#, #db.param(1)#) hasSchema 
		FROM #db.table("feature", "jetendofeature")# 
		LEFT JOIN #db.table("feature_schema", "jetendofeature")# ON 
		feature.feature_id = feature_schema.feature_id and 
		feature_schema_deleted=#db.param(0)# 
		where 
		feature.feature_deleted = #db.param(0)# and 
		feature.site_id = #db.param(request.zos.globals.id)# and 
		feature.feature_id=#db.param(form.feature_id)# 
		GROUP BY feature.feature_id ";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid feature_id", form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/index?zsid=#request.zsid#");
		}
		if(qCheck.hasSchema EQ 1){
			// force code name to never change after initial creation if there is a schema
			form.feature_variable_name=qCheck.feature_variable_name;
		}
	} 
	form.site_id=request.zos.globals.id;
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/add?zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/edit?feature_id=#form.feature_id#&zsid=#request.zsid#");
		}
	} 

	// TODO: remove this later when feature is part of main database
	request.tablesWithSiteIdStruct["jetendofeature"&"."&"feature"]=true;
	ts=StructNew();
	ts.table="feature";
	ts.struct=form;
	ts.datasource="jetendofeature";
	if(form.method EQ "insert"){
		form.feature_id = application.zcore.functions.zInsert(ts);
		if(form.feature_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Feature couldn't be added at this time.",form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/add?zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Feature added successfully.");
			redirecturl=("/z/feature/admin/feature-manage/index?feature_id=#form.feature_id#&zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Feature failed to update.",form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/edit?feature_id=#form.feature_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Feature updated successfully.");
			redirecturl=("/z/feature/admin/feature-manage/index?zsid="&request.zsid);
		}
	}
	
	if(form.method EQ "insert" and structkeyexists(request.zsession, "feature_return") and request.zsession['feature_return'] NEQ ""){
		tempLink=request.zsession["feature_return"];
		structdelete(request.zsession,"feature_return");
		application.zcore.functions.z301Redirect(replace(tempLink, "zsid=", "ztv=", "all"));
	}else if(structkeyexists(request.zsession, "feature_return"&form.feature_id)){
		tempLink=request.zsession["feature_return"&form.feature_id];
		structdelete(request.zsession,"feature_return"&form.feature_id);
		if(tempLink NEQ ""){
			application.zcore.functions.z301Redirect(replace(tempLink, "zsid=", "ztv=", "all"));
		}
	}
	application.zcore.functions.zRedirect(redirecturl);
	</cfscript>
</cffunction>


<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.functions.zSetPageHelpId("2.11.2");
	currentMethod=form.method;
	init();
	form.feature_id=application.zcore.functions.zso(form,'feature_id',true);
	db.sql="SELECT feature.*, if(feature_schema_id IS NULL, #db.param(0)#, #db.param(1)#) hasSchema FROM #db.table("feature", "jetendofeature")# 
	LEFT JOIN #db.table("feature_schema", "jetendofeature")# ON 
	feature.feature_id = feature_schema.feature_id and 
	feature_schema_deleted=#db.param(0)# 
	WHERE 
	feature.feature_deleted = #db.param(0)# and 
	feature.site_id=#db.param(request.zos.globals.id)# and
	feature.feature_id =#db.param(form.feature_id)# ";
	qEdit=db.execute("qEdit");
	application.zcore.functions.zQueryToStruct(qEdit, form, 'feature_id'); 
	application.zcore.functions.zStatusHandler(request.zsid, true);
	
	if(currentMethod EQ "edit"){
		theTitle="Edit Feature";
	}else{
		theTitle="Add Feature";
	}
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	</cfscript> 
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/feature/admin/feature-manage/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?feature_id=#form.feature_id#" method="post">

		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic"]);
		tabCom.setMenuName("member-feature-manage-edit");
		cancelURL="/z/feature/admin/feature-manage/index"; 
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table  style="border-spacing:0px;" class="table-list"> 
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Variable Name</th>
				<td>
					<cfif currentMethod EQ "add" or qEdit.hasSchema EQ 0>
						<input name="feature_variable_name" id="feature_variable_name" size="100" type="text" value="#htmleditformat(form.feature_variable_name)#" maxlength="100" />
						<input type="hidden" name="feature_type" value="1" />
						<cfif currentMethod NEQ "add">
							<br><br><strong>WARNING:</strong> You should not change the "Variable Name" on a live site unless you are ready to deploy the corrections to the source code immediately.  Editing the "Variable Name" will also prevent the Sync feature from working if the other server is not manually corrected first.  Make sure to communicate with the other developers if you change the "Variable Name".  Any code that refers to this name will start throwing undefined errors immediately after changing this.
						</cfif>
					<cfelse>
						#form.feature_variable_name# (You must delete all schemas to edit the variable name)
					</cfif>
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Display Name</th>
				<td><input name="feature_display_name" id="feature_display_name" size="100" type="text" value="#htmleditformat(form.feature_display_name)#" maxlength="100" />
				</td>
			</tr>   
		</table>
		#tabCom.endFieldSet()# 
		#tabCom.endTabMenu()# 
	</form> 
</cffunction>
</cfoutput>
</cfcomponent>
