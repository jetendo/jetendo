<!--- 
need to connect page-admin, section-link and more to this
 --->

<cfcomponent extends="zcorerootmapping.com.zos.controller">
	<cfproperty name="sectionModel" type="zcorerootmapping.mvc.z.admin.model.sectionModel">
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	if(not application.zcore.app.siteHasApp("section")){
		application.zcore.functions.z404("Section app not enabled on this site.");
	}
	
	application.zcore.adminSecurityFilter.requireFeatureAccess("Sections");	
	var queueSortStruct = StructNew();
	/*variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	queueSortStruct.tableName = "section";
	queueSortStruct.datasource="#request.zos.zcoreDatasource#";
	queueSortStruct.sortFieldName = "section_sort";
	queueSortStruct.primaryKeyName = "section_id";
	queueSortStruct.where="site_id = '#request.zos.globals.id#' and section_deleted='0' ";
	queueSortStruct.ajaxURL="/z/section/admin/section-admin/index";
	queueSortStruct.ajaxTableId="sortRowTable";
	variables.queueSortCom.init(queueSortStruct);
	variables.queueSortCom.returnJson();*/
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Sections", true);	  
	db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("section", request.zos.zcoreDatasource)# section
	WHERE section_id= #db.param(application.zcore.functions.zso(form,'section_id'))# and 
	section_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'section no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/section/admin/section-admin/index?zsid=#request.zsid#');
	}
	if(structkeyexists(form,'confirm')){
		//application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.section_image_library_id);
		db.sql="DELETE FROM #db.table("section", request.zos.zcoreDatasource)#  
		WHERE section_id= #db.param(application.zcore.functions.zso(form, 'section_id'))# and 
		section_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");
		//variables.queueSortCom.sortAll();
		if(form.returnJson EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else{
			application.zcore.status.setStatus(Request.zsid, 'Section deleted');
			application.zcore.functions.zRedirect('/z/section/admin/section-admin/index?zsid=#request.zsid#');
		} 
	}else{
		echo('<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this section?<br />
			<br />
			#qCheck.section_name#<br />
			<br />
			<a href="/z/section/admin/section-admin/delete?confirm=1&amp;section_id=#form.section_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/section/admin/section-admin/index">No</a> 
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
	application.zcore.adminSecurityFilter.requireFeatureAccess("Sections", true);	
	form.site_id = request.zos.globals.id;
	ts.section_name.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/section/admin/section-admin/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/section/admin/section-admin/edit?section_id=#form.section_id#&zsid=#request.zsid#');
		}
	}
	ts=StructNew();
	ts.table='section';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.section_id = application.zcore.functions.zInsert(ts);
		if(form.section_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save section.',form,true);
			application.zcore.functions.zRedirect('/z/section/admin/section-admin/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Section saved.');
			//variables.queueSortCom.sortAll();
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save section.',form,true);
			application.zcore.functions.zRedirect('/z/section/admin/section-admin/edit?section_id=#form.section_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Section updated.');
		}
		
	}
	//application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'section_image_library_id'));
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect('/z/section/admin/section-admin/getReturnSectionRowHTML?section_id=#form.section_id#');
	}else{
		application.zcore.functions.zRedirect('/z/section/admin/section-admin/index?zsid=#request.zsid#');
	}
	</cfscript>
</cffunction>

<!--- add array support to select input function --->

<cffunction name="getSectionRecursiveArray" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * FROM #db.table("section", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	section_deleted=#db.param(0)# 
	ORDER BY section_parent_id ASC, section_name ASC ";
	qAllSection=db.execute("qAllSection");
	sections={};
	arrSection=[];
	for(row in qAllSection){
		if(not structkeyexists(sections, row.section_parent_id)){
			sections[row.section_parent_id]=[];
		}
		arrayAppend(sections[row.section_parent_id], row);
		// sections[row.section_id] 
	}
	getSectionSelectChildren(sections, arrSection, 0, 0);
	return arrSection;
	</cfscript>
</cffunction>

<!--- 
<cffunction name="getSectionRecursiveSelectArray" localmode="modern" access="public">
	<cfscript>
	arrSection=getSectionRecursiveArray;
	arrLabel=[];
	arrValue=p
	for(row in arrSection){

	}
	return arrSection;
	</cfscript>
</cffunction> --->

<cffunction name="getSectionSelectChildren" localmode="modern" access="private">
	<cfargument name="sections" type="struct" required="yes">
	<cfargument name="arrSection" type="array" required="yes">
	<cfargument name="sectionParentId" type="string" required="yes">
	<cfargument name="indentLevel" type="numeric" required="yes">
	<cfscript>
	sections=arguments.sections;
	arrSection=arguments.arrSection;
	if(not structkeyexists(sections, arguments.sectionParentId)){
		return;
	}
	ps=sections[arguments.sectionParentId];
	for(section in ps){
		arrayAppend(arrSection, section);
		if(structkeyexists(sections, section.section_id)){
			getSectionSelectChildren(ts, arrSection, section.section_id, arguments.indentLevel+1);
		}
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
	db=request.zos.queryObject; 
	currentMethod=form.method; 
	//application.zcore.functions.zSetPageHelpId("5.5");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Sections");	
	if(application.zcore.functions.zso(form,'section_id') EQ ''){
		form.section_id = -1;
	}
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "section_return"&form.section_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	db.sql="SELECT * FROM #db.table("section", request.zos.zcoreDatasource)# section 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)# and 
	section_id=#db.param(form.section_id)#";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute);
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
		Section</h2>


	<form class="zFormCheckDirty" action="/z/section/admin/section-admin/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?section_id=#form.section_id#" method="post">
		<input type="hidden" name="modalpopforced" value="#form.modalpopforced#" />
		<table style="width:100%;" class="table-list">
			<tr>
				<th>Parent Section</th>
				<td> 
					<cfscript> 
					selectStruct = StructNew();
					selectStruct.name = "section_parent_id";  
					selectStruct.arrData=getSectionRecursiveArray();
					selectStruct.selectLabel ="-- No Parent --";
					selectStruct.queryLabelField = "section_name";
					selectStruct.queryValueField = "section_id";
					if(currentMethod EQ 'edit'){
						selectStruct.onChange="preventSameParent(this, #form.section_id#);";
					} 
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					<script type="text/javascript">
					function preventSameParent(o,id){
						if(o.options[o.selectedIndex].value == id){
							alert('You can\'t select the same page you are editing.\nPlease select a different page.');
							o.selectedIndex--;
						}
					}
					</script>
				</td>
			</tr>
			<tr>
				<th>Name</th>
				<td><input type="text" name="section_name" value="#htmleditformat(form.section_name)#" /></td>
			</tr>
			<!--- <tr>
				<th style="width:1%; white-space:nowrap;" class="table-white">Photos:</th>
				<td colspan="2" class="table-white"><cfscript>
				ts=structnew();
				ts.name="section_image_library_id";
				ts.value=form.section_image_library_id;
				application.zcore.imageLibraryCom.getLibraryForm(ts);
				</cfscript></td>
			</tr>  --->
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save Section</button>
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<button type="button" name="cancel" onclick="window.location.href = '/z/section/admin/section-admin/index';">Cancel</button>
					</cfif>
				</td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="getReturnSectionRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("section", request.zos.zcoreDatasource)# event 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)# and 
	section_id=#db.param(form.section_id)#";
	qSection=db.execute("qSection"); 
	 
	savecontent variable="rowOut"{
		for(row in qSection){
			getSectionRowHTML(row);
		}
	}

	echo('done.<script type="text/javascript">
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>


<cffunction name="getSectionRowHTML" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	echo('<td>#row.section_id#</td> 
	<td>#row.section_name#</td>  
	<td class="z-manager-admin"> 

	<div class="z-manager-button-container">

		<a href="##" class="z-manager-edit" id="z-manager-edit#row.section_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
		<div class="z-manager-edit-menu"> 
			<a href="/z/section/admin/section-admin/edit?section_id=#row.section_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;" class="z-manager-edit" target="_blank" title="Edit">Edit</a> 
			<a href="/z/admin/landing-page/index?section_id=#row.section_id#&section_parent_id=0">Manage Content</a>   
			<a href="/z/section/admin/page-admin/index?section_id=#row.section_id#&section_parent_id=0">Manage Pages</a>   
			<a href="/z/section/admin/section-link/index?section_id=#row.section_id#&section_parent_id=0">Manage Menu Links</a>   
		</div>
	</div>
	<div class="z-manager-button-container">
		<a href="##" class="z-manager-delete" title="Delete" onclick="zDeleteTableRecordRow(this, ''/z/section/admin/section-admin/delete?section_id=#row.section_id#&amp;returnJson=1&amp;confirm=1''); return false;"><i class="fa fa-trash" aria-hidden="true"></i></a>
	</div>

	</td>');
	</cfscript>
</cffunction>

<cffunction name="nav" localmode="modern" access="public" roles="member"> 
	<p> 
		<a href="/z/admin/layout-breakpoint/index">Breakpoints</a> | 
		<a href="/z/admin/layout-global/index">Global Layout Settings</a> | 
		<a href="/z/admin/layout-global/instanceList">Manage Settings Instances</a> | 
		<a href="/z/admin/layout-page/index">Manage Layouts</a>  | 
		<a href="/z/admin/layout-page/index">Manage Sections</a>  | 
		<a href="/z/admin/landing-page/index">Manage Custom Landing Pages</a> | 
		<a href="/z/admin/widget/index">Manage Widgets</a> |
		<a href="https://www.jetendo.com/layout-editor/row-editor" target="_blank">Row Editor</a> |
		<a href="https://www.jetendo.com/layout-editor/index" target="_blank">Editor Notes</a>
		<!--- <a href="/z/admin/layout-preset/index">Landing Presets</a> |  --->
	</p>

</cffunction>
	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	//application.zcore.functions.zSetPageHelpId("5.4");
	form.section_parent_id=application.zcore.functions.zso(form, 'section_parent_id', true, 0);

	//viewData={};
	//viewData.qSection=variables.sectionModel.getChildren(form.section_parent_id);
	//writedump(viewData);

	db.sql="select * from #db.table("section", request.zos.zcoreDatasource)# 
	WHERE section_parent_id = #db.param(form.section_parent_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)# 
	ORDER BY section_name ASC ";
	qSection=db.execute("qSection");  
	application.zcore.functions.zStatusHandler(request.zsid); 

	nav();
	</cfscript>
	<style type="text/css">
	</style>

	<div class="z-float">
		<div class="z-manager-quick-menu">
			<h2>Sections</h2>
			<div class="z-manager-quick-menu-links">
				<a href="##">Link 1</a>
				<a href="##">Link 2</a>
			</div>
		</div>
		<div class="z-manager-quick-menu-side-links">
			<a href="/z/section/admin/section-admin/add" class="z-manager-search-button">Add</a>
		</div>
	</div>
	<cfif qSection.recordcount EQ 0>
		<p>No sections have been added.</p>
	<cfelse>
		<table id="sortRowTable" width="100%" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Name</th> 
				<!--- <th>Sort</th> --->
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfscript>
				for(row in qSection){
					echo('<tr>');
					getSectionRowHTML(row);
					echo('</tr>');
				}
				</cfscript>
				<!--- <cfloop query="qSection">
				<tr> #variables.queueSortCom.getRowHTML(qSection.section_id)# <cfif qSection.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
					
				</tr>
				</cfloop> --->
			</tbody>
		</table>
	</cfif>
</cffunction>
	
</cfoutput>
</cfcomponent>