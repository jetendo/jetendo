<cfcomponent>
<cfoutput> 
<!--- TODO: convert to the manager-base eventually --->
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	featureSchemaCom=createobject("component", "feature-schema");
	featureSchemaCom.displayFeatureAdminNav();
	</cfscript>
</cffunction>
      
<cffunction name="getSiteFeatureQuery" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT * 
	FROM #db.table("feature", request.zos.zcoreDatasource)# 
	WHERE
	feature.feature_deleted = #db.param(0)# and  
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature")# 
	order by feature.feature_display_name ASC ";
	return db.execute("qFeature"); 
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	application.zcore.functions.zSetPageHelpId("2.11.1");
	application.zcore.functions.zstatushandler(request.zsid); 
	qFeature=getSiteFeatureQuery(); 
	</cfscript>
	<h2>Features</h2>
	<p>The following features are assigned to this site.</p>
	<p>
		<a href="/z/feature/admin/feature-manage/add" class="z-manager-search-button">Add Feature</a> 
		<a href="/z/feature/admin/feature-manage/assign" class="z-manager-search-button">Assign Feature</a> 
	</p> 
	<table style="border-spacing:0px;" class="table-list" >
		<tr>
			<th>ID</th>
			<th>Feature Name</th>
			<th>Active</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qFeature">
			<cfscript>
			siteId=application.zcore.featureCom.getFeatureSiteId(qFeature.feature_test_domain, qFeature.feature_live_domain);
			</cfscript>
			<tr <cfif qFeature.currentrow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
				<td>#qFeature.feature_id#</td>
				<td>#qFeature.feature_display_name#</td> 
				<td><cfif qFeature.feature_active EQ 1>Yes<cfelse>No</cfif></td>
				<td>
					<a href="/z/feature/admin/feature-schema/index?feature_id=#qFeature.feature_id#" class="z-manager-search-button">Schemas</a> 
					<cfif (request.zos.isTestServer and qFeature.feature_test_domain NEQ request.zos.globals.domain) or (not request.zos.isTestServer and qFeature.feature_live_domain NEQ request.zos.globals.domain)>
						<a href="##" onclick="if(confirm('Are you sure you want to unassign this feature?')){ window.location.href='/z/feature/admin/feature-manage/unassignSave?feature_id=#qFeature.feature_id#'; } return false;" target="_blank" class="z-manager-search-button">Unassign</a>
						<cfif request.zos.isTestServer>
							<a href="#qFeature.feature_test_domain#/z/feature/admin/feature-manage/index" target="_blank" class="z-manager-search-button" title="This feature is managed on #qFeature.feature_test_domain#">Configure</a>
						<cfelse>
							<a href="#qFeature.feature_live_domain#/z/feature/admin/feature-manage/index" target="_blank" class="z-manager-search-button" title="This feature is managed on #qFeature.feature_live_domain#">Configure</a>
						</cfif>
					<cfelse>
						<a href="/z/feature/admin/feature-manage/edit?feature_id=#qFeature.feature_id#" class="z-manager-search-button">Edit</a> 
						<a href="/z/feature/admin/feature-manage/delete?feature_id=#qFeature.feature_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#" class="z-manager-search-button">Delete</a>
					</cfif>
				</td>
			</tr>
		</cfloop>
	</table>
</cffunction>

<cffunction name="unassignSave" localmode="modern" access="remote" roles="member">
	<cfscript>
	form.feature_id=application.zcore.functions.zso(form, 'feature_id', true);
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("feature_x_site", request.zos.zcoreDatasource)# WHERE 
	feature_id = #db.param(form.feature_id)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	db.execute("qDelete");
	application.zcore.featureCom.reloadFeatureCache();
	application.zcore.status.setStatus(request.zsid, "Feature Unassigned");
	application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="assignSave" localmode="modern" access="remote" roles="member">
	<cfscript>
	form.feature_id=application.zcore.functions.zso(form, 'feature_id', true);

	ts={
		datasource:request.zos.zcoreDatasource,
		table:"feature_x_site",
		struct:{
			feature_id:form.feature_id,
			feature_x_site_active:1,
			site_id:request.zos.globals.id
		}
	};
	feature_x_site_id=application.zcore.functions.zInsert(ts);
	application.zcore.featureCom.reloadFeatureCache();

	application.zcore.status.setStatus(request.zsid, "Feature assigned");
	application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="assign" localmode="modern" access="remote" roles="member">
	<cfscript>
	featureIdList=application.zcore.featureCom.getFeatureIdList();

	form.feature_category_id=application.zcore.functions.zso(form, "feature_category_id", true);

	db=request.zos.queryObject;
	db.sql="select * from #db.table("feature_category", request.zos.zcoreDatasource)# WHERE 
	feature_category_deleted=#db.param(0)# ";
	qCategory=db.execute("qCategory", "", 10000, "query", false);
	foundCustom=false;
	for(row in qCategory){
		if(row.feature_category_name EQ "Custom"){
			foundCustom=true;
		}
	}
	if(not foundCustom){
		throw("There must be a Feature Catgory with name=Custom and id=1, please add this to database manually and refresh.");
	}


	db.sql="select * from #db.table("feature", request.zos.zcoreDatasource)#, 
	#db.table("feature_category", request.zos.zcoreDatasource)# WHERE 
	feature_category.feature_category_id = feature.feature_category_id and 
	feature_category_deleted=#db.param(0)# and 
	feature_id NOT IN (#db.trustedSQL(featureIdList)#) and 
	feature_active=#db.param(1)# and 
	feature_deleted=#db.param(0)# ";
	if(form.feature_category_id NEQ 0){
		db.sql&=" and feature.feature_category_id =#db.param(form.feature_category_id)# ";
	}
	qFeature=db.execute("qFeature");
	</cfscript>

	<p><a href="/z/feature/admin/feature-manage/index">Features</a> / </p>
	<h2>Assign Feature</h2>
	<p>Here you can search and assign features to the current site.  Any features already assigned will not appear here.</p>

	<table style="border-spacing:0px; margin-bottom:10px;" class="table-list" >
		<tr>
			<td>
			<form action="##" method="get">
				<cfscript>
				selectStruct=structnew();
				selectStruct.name="feature_category_id";  
				selectStruct.query=qCategory;
 				selectStruct.queryLabelField = "feature_category_name";
 				selectStruct.queryValueField = "feature_category_id";
				application.zcore.functions.zInputSelectBox(selectStruct); 
				</cfscript>
				<input type="submit" name="search1" value="Search" class="z-manager-search-button"> 
				<cfif form.feature_category_id NEQ 0>
					<input type="button" name="searchAll" value="Show All" class="z-manager-search-button" onclick="window.location.href='/z/feature/admin/feature-manage/assign';">
				</cfif>
			</form>
			</td>
		</tr>
	</table>
	<cfif qFeature.recordcount EQ 0>
		<p>No unassigned features match this search.</p>
	<cfelse>
		<table style="border-spacing:0px; margin-bottom:10px;" class="table-list" >
			<tr>
				<th>ID</th>
				<th>Feature Name</th>
				<th>Category</th>
				<th>Admin</th>
			</tr>
			<cfloop query="qFeature">
				<cfscript>
				siteId=application.zcore.featureCom.getFeatureSiteId(qFeature.feature_test_domain, qFeature.feature_live_domain);
				</cfscript>
				<tr <cfif qFeature.currentrow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<td>#qFeature.feature_id#</td>
					<td>#qFeature.feature_display_name#</td> 
					<td>#qFeature.feature_category_name#</td> 
					<td>
						<a href="/z/feature/admin/feature-manage/assignSave?feature_id=#qFeature.feature_id#" class="z-manager-search-button">Assign</a>
					</td>
				</tr>
			</cfloop>
		</table> 
	</cfif>

	<input type="button" name="cancel" value="Cancel" class="z-manager-search-button" onclick="window.location.href='/z/feature/admin/feature-manage/index';">
	
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	
	form.feature_id=application.zcore.functions.zso(form,'feature_id');
	db.sql="SELECT feature.*, if(feature_schema_id IS NULL, #db.param(0)#, #db.param(1)#) hasSchema 
	FROM #db.table("feature", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("feature_schema", request.zos.zcoreDatasource)# ON 
	feature.feature_id = feature_schema.feature_id and 
	feature_schema_deleted=#db.param(0)#  
	WHERE 
	feature.feature_id = #db.param(form.feature_id)# and  
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

		db.sql="delete from #db.table("feature_x_site", request.zos.zcoreDatasource)# WHERE 
		feature_x_site.feature_id=#db.param(form.feature_id)# and 
		feature_x_site.site_id<>#db.param(-1)# and 
		feature_x_site_deleted=#db.param(0)# ";
		db.execute("qDelete");
		application.zcore.functions.zDeleteRecord("feature", "feature_id,site_id", request.zos.zcoreDatasource);

		application.zcore.featureCom.reloadFeatureCache();

		structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);

		featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
		featureCacheCom.rebuildFeaturesCache(application.zcore, false); 

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
		<a href="/z/feature/admin/feature-manage/delete?confirm=1&feature_id=#form.feature_id#&zrand=#gettickcount()#" class="z-manager-search-button">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/feature/admin/feature-manage/index" class="z-manager-search-button">No</a> </h2>
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
	if(form.method EQ "update"){
		db.sql="select feature.*, 
		if(feature_schema_id IS NULL, #db.param(0)#, #db.param(1)#) hasSchema 
		FROM #db.table("feature", request.zos.zcoreDatasource)# 
		LEFT JOIN #db.table("feature_schema", request.zos.zcoreDatasource)# ON 
		feature.feature_id = feature_schema.feature_id and 
		feature_schema_deleted=#db.param(0)# 
		where 
		feature.feature_deleted = #db.param(0)# and 
		feature.feature_id=#db.param(form.feature_id)# 
		GROUP BY feature.feature_id ";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid Feature ID", form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-manage/index?zsid=#request.zsid#");
		}
		if(qCheck.hasSchema EQ 1){
			// force code name to never change after initial creation if there is a schema
			form.feature_variable_name=qCheck.feature_variable_name;
		}
	} 
	if(form.feature_live_domain EQ ""){
		application.zcore.status.setStatus(request.zsid, "Live Short Domain is required.", form, true);
		errors=true;
	}
	if(form.feature_test_domain EQ ""){
		application.zcore.status.setStatus(request.zsid, "Test Short Domain is required.", form, true);
		errors=true;
	}
	if(form.feature_display_name EQ ""){
		application.zcore.status.setStatus(request.zsid, "Display Name is required.", form, true);
		errors=true;
	}
	if(form.feature_variable_name EQ ""){
		application.zcore.status.setStatus(request.zsid, "Variable Name must be a valid Java/CFML variable name.", form, true);
		errors=true;
	} 
	testShortDomain=replace(replace(replace(form.feature_test_domain, "www.", ""), "http://", ""), "https://", "");
	liveShortDomain=replace(replace(replace(form.feature_live_domain, "www.", ""), "http://", ""), "https://", "");
	if(right(testShortDomain, 1) EQ "/" or left(form.feature_test_domain, 4) NEQ "http"){
		application.zcore.status.setStatus(request.zsid, "Test Domain must not have a trailing slash and must start with http:// or https://.", form, true);
		errors=true;
	}
	if(right(liveShortDomain, 1) EQ "/" or left(form.feature_live_domain, 4) NEQ "http"){
		application.zcore.status.setStatus(request.zsid, "Live Domain must not have a trailing slash and must start with http:// or https://.", form, true);
		errors=true;
	}
	form.feature_test_absolute_path=application.zcore.functions.zGetDomainInstallPath(testShortDomain);
	form.feature_live_absolute_path=application.zcore.functions.zGetDomainInstallPath(liveShortDomain);
	if(not errors){
		site_id=application.zcore.featureCom.getFeatureSiteId(form.feature_test_domain, form.feature_live_domain);
		if(request.zos.isTestServer){
			feature_absolute_path=form.feature_test_absolute_path;
		}else{
			feature_absolute_path=form.feature_live_absolute_path;
		}
		if(!directoryexists(feature_absolute_path)){
			application.zcore.status.setStatus(request.zsid, "#feature_absolute_path# doesn't exist, please check your short domain fields are correct.", form, true);
			errors=true;
		}
	}
	form.feature_test_mapping_path=replace(testShortDomain, ".", "_", "all");
	form.feature_live_mapping_path=replace(liveShortDomain, ".", "_", "all");

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
	// request.tablesWithSiteIdStruct[request.zos.zcoreDatasource&"."&"feature"]=true;
	ts=StructNew();
	ts.table="feature";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
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
	db.sql="select * from #db.table("feature_x_site", request.zos.zcoreDatasource)# WHERE 
	site_id=#db.param(request.zos.globals.id)# and 
	feature_id=#db.param(form.feature_id)# and 
	feature_x_site_deleted=#db.param(0)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		ts={
			datasource:request.zos.zcoreDatasource,
			table:"feature_x_site",
			struct:{
				feature_id:form.feature_id,
				feature_x_site_active:1,
				site_id:request.zos.globals.id
			}
		};
		feature_x_site_id=application.zcore.functions.zInsert(ts);
	}

	application.zcore.featureCom.reloadFeatureCache();
	
	
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
	db.sql="SELECT feature.*, if(feature_schema_id IS NULL, #db.param(0)#, #db.param(1)#) hasSchema 
	FROM #db.table("feature", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("feature_schema", request.zos.zcoreDatasource)# ON 
	feature.feature_id = feature_schema.feature_id and 
	feature_schema_deleted=#db.param(0)# 
	WHERE 
	feature.feature_deleted = #db.param(0)# and 
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature")# and
	feature.feature_id =#db.param(form.feature_id)# ";
	qEdit=db.execute("qEdit");
	application.zcore.functions.zQueryToStruct(qEdit, form, 'feature_id'); 
	application.zcore.functions.zStatusHandler(request.zsid, true);
	
	if(currentMethod EQ "edit"){
		theTitle="Edit Feature";
	}else{
		theTitle="Add Feature";
		echo('<p>Most features should be added to a dedicated site where reusable features are developed. If you trying to add a customization to a specific client project, you might be using the wrong form.  In this case, you''d probably want to use the "Add Feature Schema" form and associate the Feature Schema to the "Custom" Feature.</p>');
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
				<th>Category</th>
				<td>
					<cfscript>
					var ts= StructNew();
					ts.name = "feature_category_id";
					ts.size = 1; // more for multiple select
					ts.output = true; // set to false to save to variable
					ts.hideSelect=true;
					ts.selectedDelimiter = ","; // change if comma conflicts...
					// options for list data
					ts.listLabels = "Custom";
					ts.listValues = "1";
					ts.listLabelsDelimiter = ","; // tab delimiter
					ts.listValuesDelimiter = ",";
					
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript>
				</td>
			</tr>
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
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Live Domain</th>
				<td><input name="feature_live_domain" id="feature_live_domain" size="100" type="text" value="#htmleditformat(form.feature_live_domain)#" maxlength="100" /><br>
					(This must be the exact domain with http:// or https:// and optionally www with no trailing slash)
				</td>
			</tr>   
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Test Domain</th>
				<td><input name="feature_test_domain" id="feature_test_domain" size="100" type="text" value="#htmleditformat(form.feature_test_domain)#" maxlength="100" /><br>
					(This must be the exact domain with http:// or https:// and optionally www with no trailing slash)
				</td>
			</tr> 
			<cfscript>
			if(form.feature_active EQ ""){
				form.feature_active=1;
			}
			</cfscript>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Active</th>
				<td>#application.zcore.functions.zInput_Boolean("feature_active", form.feature_active)#
				</td>
			</tr> 
		</table>
		#tabCom.endFieldSet()# 
		#tabCom.endTabMenu()# 
	</form> 
</cffunction>
</cfoutput>
</cfcomponent>
