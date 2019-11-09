<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>
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
	db.sql="SELECT * FROM #db.table("layout_breakpoint", request.zos.zcoreDatasource)# 
	WHERE layout_breakpoint_id= #db.param(application.zcore.functions.zso(form,'layout_breakpoint_id'))# and 
	layout_breakpoint_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Breakpoint no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/admin/layout-breakpoint/index?zsid=#request.zsid#');
	}
	if(structkeyexists(form,'confirm')){
		//application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.layout_breakpoint_image_library_id);
		db.sql="DELETE FROM #db.table("layout_breakpoint", request.zos.zcoreDatasource)#  
		WHERE layout_breakpoint_id= #db.param(application.zcore.functions.zso(form, 'layout_breakpoint_id'))# and 
		layout_breakpoint_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");
		// variables.queueSortCom.sortAll();
		if(form.returnJson EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else{
			application.zcore.status.setStatus(Request.zsid, 'deleted');
			application.zcore.functions.zRedirect('/z/admin/layout-breakpoint/index?zsid=#request.zsid#');
		} 
	}else{
		echo('<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this breakpoint?<br />
			<br />
			#qCheck.layout_breakpoint_value#<br />
			<br />
			<a href="/z/admin/layout-breakpoint/delete?confirm=1&amp;layout_breakpoint_id=#form.layout_breakpoint_id#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="/z/admin/layout-breakpoint/index">No</a> 
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
	ts.layout_breakpoint_value.required = true;
	ts.layout_breakpoint_value.friendlyName = "Width in Pixels";
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/admin/layout-breakpoint/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/admin/layout-breakpoint/edit?layout_breakpoint_id=#form.layout_breakpoint_id#&zsid=#request.zsid#');
		}
	}
	ts=StructNew();
	ts.table='layout_breakpoint';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.layout_breakpoint_id = application.zcore.functions.zInsert(ts);
		if(form.layout_breakpoint_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save breakpoint.',form,true);
			application.zcore.functions.zRedirect('/z/admin/layout-breakpoint/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Breakpoint saved.');
			//variables.queueSortCom.sortAll();
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save breakpoint.',form,true);
			application.zcore.functions.zRedirect('/z/admin/layout-breakpoint/edit?layout_breakpoint_id=#form.layout_breakpoint_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Breakpoint updated.');
		}
		
	}
	//application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'layout_breakpoint_image_library_id'));
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect('/z/admin/layout-breakpoint/getReturnLayoutRowHTML?layout_breakpoint_id=#form.layout_breakpoint_id#');
	}else{
		application.zcore.functions.zRedirect('/z/admin/layout-breakpoint/index?zsid=#request.zsid#');
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
	//application.zcore.functions.zSetBreakpointHelpId("5.5");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	if(application.zcore.functions.zso(form,'layout_breakpoint_id') EQ ''){
		form.layout_breakpoint_id = -1;
	}

	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "layout_breakpoint_return"&form.layout_breakpoint_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	db.sql="SELECT * FROM #db.table("layout_breakpoint", request.zos.zcoreDatasource)# 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	layout_breakpoint_deleted = #db.param(0)# and 
	layout_breakpoint_id=#db.param(form.layout_breakpoint_id)#";
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
		Breakpoint</h2>
	<form class="zFormCheckDirty" action="/z/admin/layout-breakpoint/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?layout_breakpoint_id=#form.layout_breakpoint_id#" method="post">
		<input type="hidden" name="modalpopforced" value="#form.modalpopforced#" />
		<table style="width:100%;" class="table-list">
			<tr>
				<th style="white-space:nowrap;">Width in Pixels</th>
				<td><input type="text" name="layout_breakpoint_value" value="#htmleditformat(form.layout_breakpoint_value)#" /></td>
			</tr>
			<!--- <tr>
				<th>Active</th>
				<td>#application.zcore.functions.zInput_Boolean("layout_breakpoint_active")#</td>
			</tr>  --->
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<button type="button" name="cancel" onclick="window.location.href = '/z/admin/layout-breakpoint/index';">Cancel</button>
					</cfif>
				</td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="getReturnLayoutRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("layout_breakpoint", request.zos.zcoreDatasource)# event 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	layout_breakpoint_deleted = #db.param(0)# and 
	layout_breakpoint_id=#db.param(form.layout_breakpoint_id)#";
	qLayout=db.execute("qLayout"); 
	 
	savecontent variable="rowOut"{
		for(row in qLayout){
			getLayoutRowHTML(row);
		}
	}

	echo('done.<script>
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
	echo('<td>#row.layout_breakpoint_id#</td> 
	<td>#row.layout_breakpoint_value#</td>  
	<td> 
	<a href="/z/admin/layout-breakpoint/edit?layout_breakpoint_id=#row.layout_breakpoint_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit</a> |  
	<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/admin/layout-breakpoint/delete?layout_breakpoint_id=#row.layout_breakpoint_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a></td>');
	</cfscript>
</cffunction>

	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	//application.zcore.functions.zSetBreakpointHelpId("5.4"); 
	db.sql="select * from #db.table("layout_breakpoint", request.zos.zcoreDatasource)# 
	WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_breakpoint_deleted = #db.param(0)# 
	ORDER BY layout_breakpoint_value ASC ";
	qLayout=db.execute("qLayout");  
	application.zcore.functions.zStatusHandler(request.zsid); 

	layoutCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.layout-page");
	layoutCom.nav();
	</cfscript>
	<h2>Manage Breakpoints</h2>
	<p><a href="/z/admin/layout-breakpoint/add">Add Breakpoint</a></p>
	<cfif qLayout.recordcount EQ 0>
		<p>No breakpoints have been added.</p>
	<cfelse>
		<table id="sortRowTable" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Width</th>  
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