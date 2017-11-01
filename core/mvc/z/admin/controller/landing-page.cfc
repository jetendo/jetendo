<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>
	<!--- 
TODO: layout editor 
https://www.jetendo.com/layout-editor/row-editor
https://www.jetendo.com/layout-editor/index
D:\desktop\layout.ai

	 --->
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	form.section_id=application.zcore.functions.zso(form, 'section_id');
	form.landing_page_parent_id=application.zcore.functions.zso(form, 'landing_page_parent_id');
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	var queueSortStruct = StructNew(); 
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	queueSortStruct.tableName = "landing_page";
	queueSortStruct.datasource="#request.zos.zcoreDatasource#";
	queueSortStruct.sortFieldName = "landing_page_sort";
	queueSortStruct.primaryKeyName = "landing_page_id";
	queueSortStruct.where="site_id = '#request.zos.globals.id#' and 
	landing_page_parent_id='#application.zcore.functions.zEscape(form.landing_page_parent_id)#' and 
	section_id = '#application.zcore.functions.zEscape(form.section_id)#' and 
	landing_page_deleted='0' ";
	queueSortStruct.ajaxURL="/z/admin/landing-page/index?section_id=#form.section_id#&landing_page_parent_id=#form.landing_page_parent_id#";
	queueSortStruct.ajaxTableId="sortRowTable";
	variables.queueSortCom.init(queueSortStruct);
	variables.queueSortCom.returnJson();
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts", true);	  
	db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("landing_page", request.zos.zcoreDatasource)# 
	WHERE landing_page_id= #db.param(application.zcore.functions.zso(form,'landing_page_id'))# and 
	landing_page_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Custom Landing Page no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/admin/landing-page/index?section_id=#form.section_id#&landing_page_parent_id=#form.landing_page_parent_id#&zsid=#request.zsid#');
	}
	if(structkeyexists(form,'confirm')){
		//application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.landing_page_image_library_id);
		db.sql="DELETE FROM #db.table("landing_page", request.zos.zcoreDatasource)#  
		WHERE landing_page_id= #db.param(application.zcore.functions.zso(form, 'landing_page_id'))# and 
		landing_page_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");
		variables.queueSortCom.sortAll();
		if(form.returnJson EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else{
			application.zcore.status.setStatus(Request.zsid, 'Custom Landing Page deleted');
			application.zcore.functions.zRedirect('/z/admin/landing-page/index?section_id=#form.section_id#&landing_page_parent_id=#form.landing_page_parent_id#&zsid=#request.zsid#');
		} 
	}else{
		echo('<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this custom landing page?<br />
			<br />
			#qCheck.landing_page_meta_title#<br />
			<br />
			<a href="/z/admin/landing-page/delete?confirm=1&amp;section_id=#form.section_id#&amp;landing_page_parent_id=#form.landing_page_parent_id#&amp;landing_page_id=#form.landing_page_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/admin/landing-page/index?section_id=#form.section_id#&landing_page_parent_id=#form.landing_page_parent_id#&">No</a> 
		</div>');
	}
	</cfscript>
	
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>  
	init();
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts", true);	
	form.site_id = request.zos.globals.id;
	ts.landing_page_meta_title.required = true;
	ts.section_id.required = true;
	ts.section_content_type_id.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/admin/landing-page/add?section_id=#form.section_id#&zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/admin/landing-page/edit?section_id=#form.section_id#&landing_page_id=#form.landing_page_id#&zsid=#request.zsid#');
		}
	}
	ts=StructNew();
	ts.table='landing_page';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.landing_page_id = application.zcore.functions.zInsert(ts);
		if(form.landing_page_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save custom landing page.',form,true);
			application.zcore.functions.zRedirect('/z/admin/landing-page/add?section_id=#form.section_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Custom Landing Page saved.');
			variables.queueSortCom.sortAll();
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save custom landing page.',form,true);
			application.zcore.functions.zRedirect('/z/admin/landing-page/edit?section_id=#form.section_id#&landing_page_id=#form.landing_page_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Custom Landing Page updated.');
		}
		
	}
	//application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'landing_page_image_library_id'));
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect('/z/admin/landing-page/getReturnLandingRowHTML?section_id=#form.section_id#&landing_page_id=#form.landing_page_id#');
	}else{
		application.zcore.functions.zRedirect('/z/admin/landing-page/index?section_id=#form.section_id#&landing_page_parent_id=#form.landing_page_parent_id#&&zsid=#request.zsid#');
	}
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member"> 
	<cfscript> 
	init();
	db=request.zos.queryObject; 
	currentMethod=form.method; 
	//application.zcore.functions.zSetPageHelpId("5.5");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	if(application.zcore.functions.zso(form,'landing_page_id') EQ ''){
		form.landing_page_id = -1;
	}

	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "landing_page_return"&form.landing_page_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	db.sql="SELECT * FROM #db.table("landing_page", request.zos.zcoreDatasource)# 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	landing_page_deleted = #db.param(0)# and 
	section_id=#db.param(form.section_id)# and 
	landing_page_id=#db.param(form.landing_page_id)#";
	qLanding=db.execute("qLanding");
	application.zcore.functions.zQueryToStruct(qLanding, form, 'section_id,landing_page_parent_id');
	application.zcore.functions.zStatusHandler(request.zsid,true); 
	</cfscript>
	<h2>
		<cfif currentMethod EQ "add">
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		<cfelse>
			Edit
		</cfif>
		Custom Landing Page</h2>
	<form class="zFormCheckDirty" action="/z/admin/landing-page/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?landing_page_parent_id=#form.landing_page_parent_id#&amp;landing_page_id=#form.landing_page_id#" method="post">
		<input type="hidden" name="modalpopforced" value="#form.modalpopforced#" />
		<table style="width:100%;" class="table-list">
			<tr>
				<th>Section</th>
				<td>
					<cfscript> 
					db.sql="select * from #db.table("section", request.zos.zcoreDatasource)# 
					WHERE 
					site_id = #db.param(request.zos.globals.id)# and 
					section_deleted = #db.param(0)# 
					ORDER BY section_parent_id ASC, section_name ASC ";
					qSection=db.execute("qSection");   
					selectStruct = StructNew();
					selectStruct.name = "section_id";
					selectStruct.query = qSection;

					if(qSection.recordcount EQ 0){
						application.zcore.status.setStatus(request.zsid, "You must add at least 1 section first.", form, true);
						application.zcore.functions.zRedirect("/z/section/admin/section-admin/index?zsid=#request.zsid#");
					}
					//selectStruct.queryParseLabelVars=true;
					selectStruct.queryLabelField = "section_name";
					selectStruct.queryValueField = "section_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript> 
				</td>
			</tr>
			<cfif form.layout_page_id NEQ "" and form.layout_page_id NEQ "0"> 
				<tr>
					<th>Layout</th>
					<td>#form.layout_page_id# | <a href="/z/admin/layout-row/index?layout_page_id=#form.layout_page_id#">Manage</a></td>
				</tr>
			</cfif>
			<tr>
				<th>Content&nbsp;Type</th>
				<td> 
					<cfscript> 
					db.sql="SELECT * FROM #db.table("section_content_type", request.zos.zcoreDatasource)# 
					WHERE 
					section_content_type_deleted = #db.param(0)# 
					ORDER BY section_content_type_name ASC";
					qType=db.execute("qType");  
					selectStruct = StructNew();
					selectStruct.name = "section_content_type_id";
					selectStruct.query = qType;
					//selectStruct.queryParseLabelVars=true;
					selectStruct.queryLabelField = "section_content_type_name";
					selectStruct.queryValueField = "section_content_type_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
				</td> 
			</tr>
			<tr>
				<th>Parent</th>
				<td>
					<cfscript> 
					db.sql="SELECT * FROM #db.table("landing_page", request.zos.zcoreDatasource)# 
					WHERE site_id =#db.param(request.zos.globals.id)# and 
					landing_page_deleted = #db.param(0)# and 
					landing_page_id <> #db.param(form.landing_page_id)# and 
					section_id=#db.param(form.section_id)#
					ORDER BY landing_page_sort ASC";
					qLandingPages=db.execute("qLandingPages");  
					selectStruct = StructNew();
					selectStruct.name = "landing_page_parent_id";
					selectStruct.query = qLandingPages;
					//selectStruct.queryParseLabelVars=true;
					selectStruct.queryLabelField = "landing_page_meta_title";
					selectStruct.queryValueField = "landing_page_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
				</td>
			</tr>
			<tr>
				<th>Meta Title</th>
				<td><input type="text" name="landing_page_meta_title" value="#htmleditformat(form.landing_page_meta_title)#" /></td>
			</tr>
			<tr>
				<th>Meta Keywords</th>
				<td><input type="text" name="landing_page_metakey" value="#htmleditformat(form.landing_page_metakey)#" /></td>
			</tr>
			<tr>
				<th>Meta Description</th>
				<td><input type="text" name="landing_page_metadesc" value="#htmleditformat(form.landing_page_metadesc)#" /></td>
			</tr> 
			<!--- select menu for user_group_id --->
			<!--- <tr>
				<th>Breakpoints</th>
				<td><input type="text" name="landing_page_breakpoint_list" value="#htmleditformat(form.landing_page_breakpoint_list)#" /><br />Comma separated list. I.e. 320,992,1362</td> 
			</tr>  --->
			<!--- <tr>
				<th>Active</th>
				<td>#application.zcore.functions.zInput_Boolean("landing_page_active", form.landing_page_active)#</td>
			</tr> --->
			<tr>
				<th>Unique URL</th>
				<td>
					<cfif form.method EQ "tagAdd">
						#application.zcore.functions.zInputUniqueUrl("landing_page_unique_url", true)#
					<cfelse>
						#application.zcore.functions.zInputUniqueUrl("landing_page_unique_url")#
					</cfif>
				</td>
			</tr> 
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<button type="button" name="cancel" onclick="window.location.href = '/z/admin/landing-page/index?section_id=#form.section_id#&amp;landing_page_parent_id=#form.landing_page_parent_id#';">Cancel</button>
					</cfif>
				</td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="getReturnLandingRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	var db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("landing_page", request.zos.zcoreDatasource)# event 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	landing_page_deleted = #db.param(0)# and 
	landing_page_id=#db.param(form.landing_page_id)#";
	qLanding=db.execute("qLanding"); 
	 
	savecontent variable="rowOut"{
		for(row in qLanding){
			getLandingRowHTML(row);
		}
	}

	echo('done.<script type="text/javascript">
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>

<cffunction name="getLandingPageURL" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.landing_page_unique_url NEQ ""){
		return row.landing_page_unique_url;
	}else{
		// TODO need to finish enabling layout as a new application in jetendo so the URL can be configured per site.
		urlId=1
		// urlId=layout_config_landing_page_url_id;
		return "/"&application.zcore.functions.zURLEncode(row.landing_page_meta_title, '-')&'-#urlId#-'&row.landing_page_id&".html";
	}
	</cfscript>
</cffunction>

<cffunction name="getLandingRowHTML" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	link=getLandingPageURL(row);
	echo('<td>#row.landing_page_id#</td> 
	<td>#row.landing_page_meta_title#</td>  
	<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(row.landing_page_id)#</td>
	<td> 
	<a href="#link#" target="_blank">View</a> | 
	<a href="/z/admin/landing-page/edit?section_id=#row.section_id#&amp;landing_page_id=#row.landing_page_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit</a> | ');
	if(row.section_content_type_id EQ 1){
		echo('<a href="/z/admin/landing-page-row/index?landing_page_id=#row.landing_page_id#">Manage Rows</a> | ');
	}else{
		echo('Type (#row.section_content_type_id#) not implemented | ');
	}
	if(not application.zcore.functions.zIsForceDeleteEnabled(row.landing_page_unique_url)){
		echo(' | Delete disabled');
	}else{
		echo(' | <a href="##" onclick="zDeleteTableRecordRow(this, ''/z/admin/landing-page/delete?section_id=#row.section_id#&amp;landing_page_id=#row.landing_page_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a>');
	} 
	echo('</td>');
	</cfscript>
</cffunction>

	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	//application.zcore.functions.zSetPageHelpId("5.4");
	form.section_id=application.zcore.functions.zso(form, 'section_id', true, 0);
	form.landing_page_parent_id=application.zcore.functions.zso(form, 'landing_page_parent_id', true, 0);
 
//landing_page_parent_id = #db.param(form.landing_page_parent_id)# and 
	db.sql="select * from #db.table("landing_page", request.zos.zcoreDatasource)# 
	WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	landing_page_parent_id=#db.param(form.landing_page_parent_id)# and 
	landing_page_deleted = #db.param(0)# 
	ORDER BY landing_page_sort ASC ";
	qLanding=db.execute("qLanding");  
	application.zcore.functions.zStatusHandler(request.zsid); 


	db.sql="SELECT * FROM #db.table("section", request.zos.zcoreDatasource)# section 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)# and 
	section_id=#db.param(form.section_id)#";
	qSection=db.execute("qSection");
 
	</cfscript>
	<p><a href="/z/section/admin/section-admin/index">Sections</a> / 
	<cfif qSection.recordcount>
		#qSection.section_name# /
	</cfif>
	</p>
	<h2>Manage Custom Landing Pages
	<cfif qSection.recordcount>
		<br />Section: #qSection.section_name#
	</cfif></h2>
	<p><a href="/z/admin/landing-page/add?section_id=#form.section_id#&amp;landing_page_parent_id=#form.landing_page_parent_id#">Add Custom Landing Page</a></p>
	<cfif qLanding.recordcount EQ 0>
		<p>No custom landing pages have been added.</p>
	<cfelse>
		<table id="sortRowTable" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Name</th> 
				<th>Sort</th>
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfscript>
				for(row in qLanding){
					echo('<tr #variables.queueSortCom.getRowHTML(row.landing_page_id)#>');
					getLandingRowHTML(row);
					echo('</tr>');
				}
				</cfscript> 
			</tbody>
		</table>
	</cfif>
</cffunction>
	
</cfoutput>
</cfcomponent>