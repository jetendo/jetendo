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
	
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	var queueSortStruct = StructNew(); 
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts", true);	  
	db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("layout_page", request.zos.zcoreDatasource)# 
	WHERE layout_page_id= #db.param(application.zcore.functions.zso(form,'layout_page_id'))# and 
	layout_page_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Custom Layout page no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/admin/layout-page/index?zsid=#request.zsid#');
	}
	if(structkeyexists(form,'confirm')){
		//application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.layout_page_image_library_id);
		db.sql="DELETE FROM #db.table("layout_page", request.zos.zcoreDatasource)#  
		WHERE layout_page_id= #db.param(application.zcore.functions.zso(form, 'layout_page_id'))# and 
		layout_page_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");
		// variables.queueSortCom.sortAll();
		if(form.returnJson EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else{
			application.zcore.status.setStatus(Request.zsid, 'Custom Layout deleted');
			application.zcore.functions.zRedirect('/z/admin/layout-page/index?zsid=#request.zsid#');
		} 
	}else{
		echo('<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this custom layout page?<br />
			<br />
			#qCheck.layout_page_name#<br />
			<br />
			<a href="/z/admin/layout-page/delete?confirm=1&amp;layout_page_id=#form.layout_page_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/admin/layout-page/index">No</a> 
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
	ts.layout_page_name.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/admin/layout-page/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/admin/layout-page/edit?layout_page_id=#form.layout_page_id#&zsid=#request.zsid#');
		}
	}
	ts=StructNew();
	ts.table='layout_page';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.layout_page_id = application.zcore.functions.zInsert(ts);
		if(form.layout_page_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save custom layout page.',form,true);
			application.zcore.functions.zRedirect('/z/admin/layout-page/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Custom Layout saved.');
			//variables.queueSortCom.sortAll();
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save custom layout page.',form,true);
			application.zcore.functions.zRedirect('/z/admin/layout-page/edit?layout_page_id=#form.layout_page_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Custom Layout updated.');
		}
		
	}
	//application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'layout_page_image_library_id'));
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect('/z/admin/layout-page/getReturnLayoutRowHTML?layout_page_id=#form.layout_page_id#');
	}else{
		application.zcore.functions.zRedirect('/z/admin/layout-page/index?zsid=#request.zsid#');
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
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	if(application.zcore.functions.zso(form,'layout_page_id') EQ ''){
		form.layout_page_id = -1;
	}

	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "layout_page_return"&form.layout_page_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	db.sql="SELECT * FROM #db.table("layout_page", request.zos.zcoreDatasource)# 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	layout_page_deleted = #db.param(0)# and 
	layout_page_id=#db.param(form.layout_page_id)#";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	if(form.layout_page_active EQ ""){
		form.layout_page_active=1;
	}
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
		Custom Layout Page</h2>
	<form class="zFormCheckDirty" action="/z/admin/layout-page/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?layout_page_id=#form.layout_page_id#" method="post">
		<input type="hidden" name="modalpopforced" value="#form.modalpopforced#" />
		<table style="width:100%;" class="table-list">
			<tr>
				<th>Name</th>
				<td><input type="text" name="layout_page_name" value="#htmleditformat(form.layout_page_name)#" /></td>
			</tr>
			<tr>
				<th>Breakpoints</th>
				<td><input type="text" name="layout_page_breakpoint_list" value="#htmleditformat(form.layout_page_breakpoint_list)#" /><br />Comma separated list. I.e. 320,992,1362</td>
				<!--- TODO: make a way of changing breakpoint from old to new value later --->
			</tr> 
			<tr>
				<th>Active</th>
				<td>#application.zcore.functions.zInput_Boolean("layout_page_active", form.layout_page_active)#</td>
			</tr>
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save Layout</button>
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<button type="button" name="cancel" onclick="window.location.href = '/z/admin/layout-page/index';">Cancel</button>
					</cfif>
				</td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="getReturnLayoutRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	var db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("layout_page", request.zos.zcoreDatasource)# event 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	layout_page_deleted = #db.param(0)# and 
	layout_page_id=#db.param(form.layout_page_id)#";
	qLayout=db.execute("qLayout"); 
	 
	savecontent variable="rowOut"{
		for(row in qLayout){
			getLayoutRowHTML(row);
		}
	}

	echo('done.<script type="text/javascript">
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>


<cffunction name="getLayoutRowHTML" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	echo('<td>#row.layout_page_id#</td> 
	<td>Category</td>  
	<td>#row.layout_page_name#</td>  
	<td> 
	<a href="/z/admin/layout-page/edit?layout_page_id=#row.layout_page_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit</a> | 
	<a href="/z/admin/layout-row/index?layout_page_id=#row.layout_page_id#">Manage Rows</a> | 
	<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/admin/layout-page/delete?layout_page_id=#row.layout_page_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a></td>');
	</cfscript>
</cffunction>

<cffunction name="nav" localmode="modern" access="public" roles="member">
	<cfscript>
	sectionCom=createobject("component", "zcorerootmapping.mvc.z.section.admin.controller.section-admin");
	sectionCom.nav();
	</cfscript> 

</cffunction>
	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	//application.zcore.functions.zSetPageHelpId("5.4");
	form.layout_page_parent_id=application.zcore.functions.zso(form, 'layout_page_parent_id', true, 0);
 
//layout_page_parent_id = #db.param(form.layout_page_parent_id)# and 
	db.sql="select * from #db.table("layout_page", request.zos.zcoreDatasource)# 
	WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_page_deleted = #db.param(0)# 
	ORDER BY layout_page_name ASC ";
	qLayout=db.execute("qLayout");  
	application.zcore.functions.zStatusHandler(request.zsid); 

	nav(); 
	</cfscript> 
	<h2>Manage Custom Layout Pages</h2>
	<h2>WARNING: this feature is incomplete.</h2>
	<p><a href="/z/admin/layout-page/add">Add Custom Layout Page</a></p>
	<cfif qLayout.recordcount EQ 0>
		<p>No custom layout pages have been added.</p>
	<cfelse>
		<table id="sortRowTable" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Category</th> 
				<th>Name</th> 
				<!--- <th>Sort</th> --->
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfscript>
				for(row in qLayout){
					echo('<tr>');
					getLayoutRowHTML(row);
					echo('</tr>');
				}
				</cfscript> 
			</tbody>
		</table>
	</cfif>
</cffunction>
	
</cfoutput>
</cfcomponent>