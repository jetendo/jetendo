<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	// var theTitle=0;
	// variables.allowGlobal=false; 
	// application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	// if(application.zcore.user.checkServerAccess()){
	// 	variables.allowGlobal=true;
	// 	variables.siteIdList="'0','"&request.zos.globals.id&"'";
	// } 
	// if(structkeyexists(form, 'returnURL')){
	// 	request.zsession["feature_return"&application.zcore.functions.zso(form, 'feature_id')]=application.zcore.functions.zso(form, 'returnURL');
	// }
	
	// if(not application.zcore.functions.zIsWidgetBuilderEnabled()){
	// 	application.zcore.functions.z301Redirect('/member/');
	// }
	// theTitle="Manage Feature Schemas";
	// application.zcore.template.setTag("title",theTitle);
	// application.zcore.template.setTag("pagetitle",theTitle);
	
	featureSchemaCom=createobject("component", "feature-schema");
	featureSchemaCom.displayoptionAdminNav();
	</cfscript>
</cffunction>
      

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qSchema=0;
	var qProp=0;
	var curParentId=0;
	var arrParent=0;
	var q1=0;
	var i=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.11.1");
	application.zcore.functions.zstatushandler(request.zsid);
	form.feature_parent_id=application.zcore.functions.zso(form, 'feature_parent_id',true);
	if(form.feature_parent_id NEQ 0){
		db.sql="select * from #db.table("feature", "jetendofeature")# feature 
		where feature_id=#db.param(form.feature_parent_id)# and 
		feature_deleted = #db.param(0)# and
		feature.feature_id =#db.param(form.feature_id)#";
		qSchema=db.execute("qSchema");
        if(qSchema.recordcount EQ 0){
            application.zcore.functions.z301redirect("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#");	
        }
	}
	db.sql="SELECT feature.*, if(child1.feature_id IS NULL, #db.param(0)#,#db.param(1)#) hasChildren 
	FROM #db.table("feature", "jetendofeature")# feature
	LEFT JOIN #db.table("feature", "jetendofeature")# child1 ON 
	feature.feature_id = child1.feature_parent_id and 
	child1.feature_id = feature.feature_id and 
	child1.feature_deleted = #db.param(0)# 
	WHERE
	feature.feature_deleted = #db.param(0)# and 
	feature.feature_id =#db.param(form.feature_id)# and 
	feature.feature_parent_id = #db.param(form.feature_parent_id)# 
	group by feature.feature_id 
	order by feature.feature_display_name ASC ";
	qProp=db.execute("qProp");
	if(form.feature_parent_id NEQ 0){
		writeoutput('<p><a href="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#">Manage Schemas</a> / ');
		curParentId=form.feature_parent_id;
		arrParent=arraynew(1);
		loop from="1" to="25" index="i"{
			db.sql="select * 
			from #db.table("feature", "jetendofeature")# feature 
			where feature_id = #db.param(curParentId)# and 
			feature_deleted = #db.param(0)# and
			feature_id=#db.param(form.feature_id)#";
			q1=db.execute("q1", "", 10000, "query", false);
			loop query="q1"{
				arrayappend(arrParent, '<a href="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&feature_parent_id=#q1.feature_id#">
				#application.zcore.functions.zFirstLetterCaps(q1.feature_display_name)#</a> / ');
				curParentId=q1.feature_parent_id;
			}
			if(q1.recordcount EQ 0 or q1.feature_parent_id EQ 0){
				break;
			}
		}
		for(i = arrayLen(arrParent);i GT 1;i--){
			writeOutput(arrParent[i]&' ');
		}
		if(form.feature_parent_id NEQ 0){
			writeoutput(application.zcore.functions.zFirstLetterCaps(qSchema.feature_display_name)&" /");
		}
		writeoutput('</p>');
	}
	</cfscript>
	<p><a href="/z/feature/admin/feature-schema/add?feature_parent_id=<cfif isquery(qgroup)>#qgroup.feature_id#</cfif>">Add Schema</a> 

	 | <a href="/z/admin/site-option-group-import/importSchema">Import Schema</a> 
	 
	<cfif isquery(qgroup) and qgroup.feature_id NEQ 0>
		| <a href="/z/feature/admin/feature-schema/displaySchemaCode?feature_id=<cfif isquery(qgroup)>#qgroup.feature_id#</cfif>" target="_blank">Display Schema Code</a>
	</cfif>
	<cfif isquery(qgroup)> | <a href="/z/feature/admin/features/manageFields?feature_id=#form.feature_id#&feature_id=#qgroup.feature_id#&feature_parent_id=#qgroup.feature_parent_id#">Manage Fields</a></cfif></p>
	<table style="border-spacing:0px;" class="table-list" >
		<tr>
			<th>ID</th>
			<th>Schema Name</th>
			<th>Disable Admin</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qProp">
		<tr <cfif qProp.currentrow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
			<td>#qProp.feature_id#</td>
			<td>#qProp.feature_variable_name#</td>
			<td><cfif qProp.feature_disable_admin EQ 1>
					Yes
				<cfelse>
					No
				</cfif>
			</td>
			<td>
				<cfif qProp.feature_admin_app_only EQ "0">
					<cfif qProp.feature_parent_id EQ 0>
	
						<a href="/z/feature/admin/features/manageSchema?feature_id=0&feature_id=#qProp.feature_id#">List/Edit</a> | 
						<a href="/z/feature/admin/features/import?feature_id=0&feature_id=#qProp.feature_id#">Import</a> | 
						<!--- <a href="/z/feature/admin/features/manageSchema?feature_id=0&feature_id=#qProp.feature_id#&amp;zManagerAddOnLoad=1">Add</a> |  --->
					</cfif>
				</cfif>
			<cfif qProp.site_id NEQ 0 or variables.allowGlobal>
					<a href="/z/feature/admin/feature-schema/add?feature_parent_id=#qProp.feature_id#">Add Sub-Schema</a> | 
					<a href="/z/feature/admin/features/manageFields?feature_id=#form.feature_id#&amp;feature_id=#qProp.feature_id#&amp;feature_parent_id=#qProp.feature_parent_id#">Fields</a> | 
					<cfif qProp.feature_allow_public NEQ 0>
						<cfif qProp.feature_public_form_url NEQ "">
							<a href="#htmleditformat(qProp.feature_public_form_url)#" target="_blank">Public Form</a> | 
						<cfelse>
							<a href="/z/misc/display-site-option-group/add?feature_id=#qProp.feature_id#" target="_blank">Public Form</a> | 
						</cfif>
					</cfif>
					<cfif application.zcore.user.checkServerAccess()>
						<a href="/z/feature/admin/feature-schema/export?feature_id=#qProp.feature_id#" target="_blank">Export CSV</a> | 
						<a href="/z/feature/admin/feature-schema/reindex?feature_id=#qProp.feature_id#" title="Will update site option group table for all records.  Useful after a config change.">Reprocess</a> | 
						<a href="/z/_com/app/siteSchemaFormGenerator?method=index&amp;feature_id=#qProp.feature_id#" target="_blank">Generate Custom DB Form</a> | 
					</cfif>
	
					<cfif qProp.hasChildren EQ 1>
						<a href="/z/feature/admin/feature-schema/index?feature_parent_id=#qProp.feature_id#">Sub-Schemas</a> |
					</cfif>
					<a href="/z/feature/admin/feature-schema/displaySchemaCode?feature_id=#qProp.feature_id#&amp;feature_parent_id=#qProp.feature_parent_id#" target="_blank">Display Code</a> |
					
					<cfif qProp.feature_map_fields_type NEQ 0>
						<a href="/z/feature/admin/feature-schema/mapFields?feature_id=#qProp.feature_id#">Map Fields</a>
						<cfscript>
						db.sql="select count(feature_map_id) count 
						from #db.table("feature_map", "jetendofeature")# feature_map WHERE 
						site_id = #db.param(qProp.site_id)# AND 
						feature_map_deleted = #db.param(0)# and
						feature_id = #db.param(qProp.feature_id)# ";
						qMap=db.execute("qMap");
						if(qMap.recordcount EQ 0 or qMap.count EQ 0){
							echo('<strong>(Not Mapped Yet)</strong> ');
						}
						</cfscript> | 
					</cfif>
					<a href="/z/feature/admin/feature-schema/edit?feature_id=#qProp.feature_id#&amp;feature_parent_id=#qProp.feature_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Edit</a> | 
					<cfif qProp.feature_parent_id EQ 0>
						<a href="/z/feature/admin/feature-schema/copySchemaForm?feature_id=#qProp.feature_id#">Copy</a> | 
					</cfif>
					<a href="/z/feature/admin/feature-schema/delete?feature_id=#qProp.feature_id#&amp;feature_parent_id=#qProp.feature_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Delete</a>
				</cfif></td>
		</tr>
		</cfloop>
	</table>
</cffunction>


<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var result=0;
	var qCheck=0;
	var theTitle=0;
	var tempLink=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	
	form.feature_id=application.zcore.functions.zso(form,'feature_id');
	db.sql="SELECT * FROM #db.table("feature", "jetendofeature")# feature WHERE 
	feature_id = #db.param(form.feature_id)# and 
	feature_deleted = #db.param(0)# and 
	feature_id=#db.param(form.feature_id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "group is missing");
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&zsid="&request.zsid);
	}
	if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index");
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		// TODO: fix group delete that has no options - it leaves a remnant in memory that breaks the application
		application.zcore.siteFieldCom.deleteSchemaRecursively(form.feature_id, true);
		application.zcore.status.setStatus(request.zsid, "Schema deleted successfully.");
		application.zcore.siteFieldCom.updateSchemaCacheBySchemaId(qCheck.feature_id);

		structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);
		//application.zcore.functions.zOS_cacheSiteAndUserSchemas(request.zos.globals.id); 
		if(structkeyexists(request.zsession, "feature_return"&form.feature_id) and request.zsession['feature_return'&form.feature_id] NEQ ""){
			tempLink=request.zsession["feature_return"&form.feature_id];
			structdelete(request.zsession,"feature_return"&form.feature_id);
			application.zcore.functions.z301Redirect(replace(tempLink, "zsid=", "ztv=", "all"));
		}else{
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&feature_parent_id=#form.feature_parent_id#&zsid="&request.zsid);
		}
		</cfscript>
	<cfelse>
		<cfscript>
		theTitle="Delete Schema";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<h2> Are you sure you want to delete this Schema?<br />
		<br />
		Schema: #qcheck.feature_display_name#<br />
		<br />
		<a href="/z/feature/admin/feature-schema/delete?confirm=1&feature_id=#form.feature_id#&amp;feature_id=#form.feature_id#&zrand=#gettickcount()#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&amp;feature_parent_id=#form.feature_parent_id#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">    
	<cfscript>
	var db=request.zos.queryObject;
	var errors=0;
	var tempLink=0;
	var qCheck=0;
	var ts=0;
	var redirecturl=0;
	var rCom=0;
	var myForm={};
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	
	myForm.feature_display_name.required=true;
	myForm.feature_display_name.friendlyName="Display Name";
	myForm.feature_variable_name.required=true;
	myForm.feature_variable_name.friendlyName="Code Name";
	errors=application.zcore.functions.zValidateStruct(form, myForm,request.zsid, true);
	
	form.feature_allow_delete_usergrouplist=application.zcore.functions.zso(form, 'feature_allow_delete_usergrouplist');
	form.feature_user_group_id_list=application.zcore.functions.zso(form, 'feature_user_group_id_list');
	form.feature_change_email_usergrouplist=application.zcore.functions.zso(form, 'feature_change_email_usergrouplist');

	if(form.method EQ "update"){
		db.sql="select * from #db.table("feature", "jetendofeature")# feature 
		where feature_id = #db.param(form.feature_id)# and 
		feature_deleted = #db.param(0)# and
		feature_id=#db.param(form.feature_id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#");
		}
		// force code name to never change after initial creation
		//form.feature_variable_name=qCheck.feature_variable_name;
	}
	if(application.zcore.functions.zso(form, 'feature_enable_unique_url', false, 0) EQ 1){
		if(form.feature_view_cfc_path EQ "" or form.feature_view_cfc_method EQ ""){
			application.zcore.status.setStatus(request.zsid, "View CFC Path and View CFC Method are required when ""Enable Unique Url"" is set to yes.", form, true);
			errors=true;
		}
	}
	if(form.feature_parent_id NEQ "" and form.feature_parent_id NEQ 0){
		form.feature_enable_new_button=0;
	} 
	
	form.feature_appidlist=","&application.zcore.functions.zso(form,'feature_appidlist')&",";
	 if(application.zcore.functions.zso(form,'optionSchemaglobal',false,0) EQ 1 and variables.allowGlobal){
		 form.site_id='0';
	 }else{
		 form.site_id=request.zos.globals.id;
	 }
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/add?feature_id=#form.feature_id#&feature_parent_id=#form.feature_parent_id#&zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/edit?feature_id=#form.feature_id#&feature_id=#form.feature_id#&feature_parent_id=#form.feature_parent_id#&zsid=#request.zsid#");
		}
	} 
	
	if(form.inquiries_type_id NEQ ""){
		local.arrTemp=listToArray(form.inquiries_type_id, '|');
		form.inquiries_type_id=local.arrTemp[1];
		form.inquiries_type_id_siteIDType=application.zcore.functions.zGetSiteIdType(local.arrTemp[2]);
	}
	 
	ts=StructNew();
	ts.table="feature";
	ts.struct=form;
	ts.datasource="jetendofeature";
	if(form.method EQ "insert"){
		form.feature_id = application.zcore.functions.zInsert(ts);
		if(form.feature_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Schema couldn't be added at this time.",form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/add?feature_id=#form.feature_id#&feature_parent_id=#form.feature_parent_id#&zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Schema added successfully.");
			redirecturl=("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&feature_parent_id=#form.feature_parent_id#&zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Schema failed to update.",form,true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/edit?feature_id=#form.feature_id#&feature_id=#form.feature_id#&feature_parent_id=#form.feature_parent_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Schema updated successfully.");
			redirecturl=("/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&feature_parent_id=#form.feature_parent_id#&zsid="&request.zsid);
		}
	}
	
	
	application.zcore.siteFieldCom.updateSchemaCacheBySchemaId(form.feature_id);
	//application.zcore.functions.zOS_cacheSiteAndUserSchemas(request.zos.globals.id);
	structclear(application.sitestruct[request.zos.globals.id].administratorTemplateMenuCache);
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	
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
	var db=request.zos.queryObject;
	var qRate=0;
	var theTitle=0;
	var qApp=0;
	var qG=0;
	var htmlEditor=0;
	var selectStruct=0;
	var ts=0;
	application.zcore.functions.zSetPageHelpId("2.11.2");
	
	var currentMethod=form.method;
	variables.init();
	form.feature_id=application.zcore.functions.zso(form,'feature_id',true);
	db.sql="SELECT * FROM #db.table("feature", "jetendofeature")# feature 
	WHERE feature_id = #db.param(form.feature_id)# and 
	feature_deleted = #db.param(0)# and
	feature_id =#db.param(form.feature_id)# ";
	qRate=db.execute("qRate");
	if(structkeyexists(form, 'feature_parent_id')){
		application.zcore.functions.zQueryToStruct(qRate,form,'feature_id,feature_parent_id'); 
	}else{
		application.zcore.functions.zQueryToStruct(qRate,form,'feature_id'); 
	}
	application.zcore.functions.zStatusHandler(request.zsid, true);
	
	if(currentMethod EQ "edit"){
		theTitle="Edit Schema";
	}else{
		theTitle="Add Schema";
	}
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	</cfscript>
				<cfscript>
				if(form.site_id EQ 0){
					form.optionSchemaglobal='1';
				}
				</cfscript> 
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/feature/admin/feature-schema/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?feature_id=#form.feature_id#&amp;feature_id=#form.feature_id#" method="post">

		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Public Form", "Landing Page", "Email & Mapping"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-site-option-group-edit");
		cancelURL="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#"; 
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table  style="border-spacing:0px;" class="table-list">
			<cfsavecontent variable="db.sql"> SELECT * FROM #db.table("feature", "jetendofeature")# feature WHERE 
			feature_id=#db.param(form.feature_id)# and 
			feature_deleted = #db.param(0)# 
			<!--- <cfif form.feature_id NEQ 0 and form.feature_id NEQ "">
				and feature_id <> #db.param(form.feature_id)# and 
				feature_parent_id <> #db.param(form.feature_id)#
			</cfif> --->
			ORDER BY feature_display_name </cfsavecontent>
			<cfscript>
			qG=db.execute("qG", "", 10000, "query", false); 
			</cfscript>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Parent Schema","member.site-option-group.edit feature_parent_id")#</th>
				<td><cfscript>
				arrData=[];
				for(row in qG){
					arrayAppend(arrData, { 
						parent:row.feature_parent_id, 
						label:row.feature_display_name, 
						value:row.feature_id
					});
				} 
				rs=application.zcore.functions.zGetRecursiveLabelValueForSelectBox(arrData);
				selectStruct=structnew();
				selectStruct.name="feature_parent_id"; 
				selectStruct.onchange="doParentCheck();";
				if(form.feature_id NEQ ""){
					selectStruct.onchange="if(this.options[this.selectedIndex].value=='#form.feature_id#'){alert('You can\'t select the same group you are editing.');this.selectedIndex=0;}"&selectStruct.onchange;
				}
				selectStruct.listValuesDelimiter=chr(9);
				selectStruct.listLabelsDelimiter=chr(9);
				selectStruct.listLabels=arrayToList(rs.arrLabel, chr(9));
				selectStruct.listValues=arrayToList(rs.arrValue, chr(9)); 
				application.zcore.functions.zInputSelectBox(selectStruct);
				/*
				selectStruct=structnew();
				selectStruct.name="feature_parent_id";
				selectStruct.query = qG;
				selectStruct.onchange="doParentCheck();";
				selectStruct.queryLabelField = "feature_display_name";
				selectStruct.queryValueField = "feature_id";
				application.zcore.functions.zInputSelectBox(selectStruct);*/
				</cfscript><br />
				<strong>Warning:</strong> If user data exists for this record, you should not change the Parent Schema, because the user data's parent group field will not be automatically updated.  You'd have to update the database and cache manually if you want to do this anyway. 
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Code Name","member.site-option-group.edit feature_variable_name")#</th>
				<td>
					<input name="feature_variable_name" id="feature_variable_name" size="50" type="text" value="#htmleditformat(form.feature_variable_name)#" maxlength="100" />
					<input type="hidden" name="feature_type" value="1" />
				<cfif currentMethod NEQ "add">
					<br><br><strong>WARNING:</strong> You should not change the "Name" on a live site unless you are ready to deploy the corrections to the source code immediately.  Editing the "Name" will also prevent the Sync feature from working.  Make sure to communicate with the other developers if you change the "Name".  Any code that refers to this name will start throwing undefined errors immediately after changing this.
				</cfif></td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Display Name","member.site-option-group.edit feature_display_name")#</th>
				<td><input name="feature_display_name" id="feature_display_name" size="50" type="text" value="#htmleditformat(form.feature_display_name)#" maxlength="100" />
				</td>
			</tr>  
			<!--- <tr>
				<th style="vertical-align:top; white-space:nowrap;">
					#application.zcore.functions.zOutputHelpToolTip("Allow Locked Delete?","member.site-option-group.edit feature_enable_locked_delete")#
				</th>
				<td>#application.zcore.functions.zInput_Boolean("feature_enable_locked_delete")# 
					(When a record is locked, setting this to yes will allow a non-developer to delete the record.)
				</td>
			</tr> --->
		</table>
		#tabCom.endFieldSet()# 
		#tabCom.endTabMenu()#
				 
				
		<cfif variables.allowGlobal EQ false>
			<input type="hidden" name="optionSchemaglobal" value="0" />
		</cfif>
	</form>
	<script type="text/javascript">
		/* <![CDATA[ */
		var arrD=[];<cfloop query="qG">arrD.push("#qG.site_id#");</cfloop>
		var firstLoad11=true;
		function doParentCheck(){
			var d1=document.getElementById("optionSchemaglobal1");
			var d0=document.getElementById("optionSchemaglobal0");
			var groupMenuName=document.getElementById("groupMenuNameId");
			var groupMenuName2=document.getElementById("groupMenuNameId2");
			var groupMenuNameField=document.getElementById("feature_menu_name");
			if(groupMenuNameField == null){
				return;
			}
			if(firstLoad11){
				firstLoad11=false;
				if(d1 != null){
					$(d1).bind("change",function(){ doParentCheck(); });
					$(d0).bind("change",function(){ doParentCheck(); });
				}
				
			}
			var a=document.getElementById("feature_parent_id");
			if(a.selectedIndex != 0){
				groupMenuNameField.value='';
				groupMenuName.style.display="none";
				groupMenuName2.style.display="block";

				if(d1 != null){
					if(arrD[a.selectedIndex-1] == 0){
						d1.checked=true;
						d0.checked=false;	
					}else{
						d1.checked=false;
						d0.checked=true;	
					}
				}
			}else{
				groupMenuName.style.display="block";
				groupMenuName2.style.display="none";
			}
		}
		zArrDeferredFunctions.push(function(){doParentCheck();});
		/* ]]> */
		</script>
</cffunction>
</cfoutput>
</cfcomponent>
