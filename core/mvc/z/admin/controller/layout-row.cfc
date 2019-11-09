<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	
	form.layout_page_id=application.zcore.functions.zso(form, 'layout_page_id', true, 0); 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	var queueSortStruct = StructNew(); 
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	queueSortStruct.tableName = "layout_row";
	queueSortStruct.datasource="#request.zos.zcoreDatasource#";
	queueSortStruct.sortFieldName = "layout_row_sort";
	queueSortStruct.primaryKeyName = "layout_row_id";
	queueSortStruct.where="site_id = '#request.zos.globals.id#' and 
	layout_page_id = '#application.zcore.functions.zEscape(form.layout_page_id)#' and 
	layout_row_deleted='0' ";
	queueSortStruct.ajaxURL="/z/admin/layout-row/index?layout_page_id=#form.layout_page_id#";
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
	db.sql="SELECT * FROM #db.table("layout_row", request.zos.zcoreDatasource)# 
	WHERE layout_row_id= #db.param(application.zcore.functions.zso(form,'layout_row_id'))# and 
	layout_row_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Row no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/admin/layout-row/index?layout_page_id=#form.layout_page_id#&zsid=#request.zsid#');
	}
	if(structkeyexists(form,'confirm')){ 
		db.sql="DELETE FROM #db.table("layout_row", request.zos.zcoreDatasource)#  
		WHERE layout_row_id= #db.param(application.zcore.functions.zso(form, 'layout_row_id'))# and 
		layout_row_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");

		variables.queueSortCom.sortAll();
		if(form.returnJson EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else{
			application.zcore.status.setStatus(Request.zsid, 'Row deleted');
			application.zcore.functions.zRedirect('/z/admin/layout-row/index?layout_page_id=#form.layout_page_id#&zsid=#request.zsid#');
		} 
	}else{
		echo('<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this row?<br />
			<br />
			#qCheck.layout_row_id#<br />
			<br />
			<a href="/z/admin/layout-row/delete?confirm=1&amp;layout_page_id=#form.layout_page_id#&layout_row_id=#form.layout_row_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/admin/layout-row/index?layout_page_id=#form.layout_page_id#">No</a> 
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
	ts.layout_page_id.required = true;
	ts.layout_row_active.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/admin/layout-row/add?layout_page_id=#form.layout_page_id#&zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/admin/layout-row/edit?layout_page_id=#form.layout_page_id#&layout_row_id=#form.layout_row_id#&zsid=#request.zsid#');
		}
	}
	ts=StructNew();
	ts.table='layout_row';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.layout_row_id = application.zcore.functions.zInsert(ts);
		if(form.layout_row_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save row.',form,true);
			application.zcore.functions.zRedirect('/z/admin/layout-row/add?layout_page_id=#form.layout_page_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Row saved.');
			variables.queueSortCom.sortAll();
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save row.',form,true);
			application.zcore.functions.zRedirect('/z/admin/layout-row/edit?layout_page_id=#form.layout_page_id#&layout_row_id=#form.layout_row_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Row updated.');
		}
		
	} 
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect('/z/admin/layout-row/getReturnLayoutRowHTML?layout_page_id=#form.layout_page_id#&layout_row_id=#form.layout_row_id#');
	}else{
		application.zcore.functions.zRedirect('/z/admin/layout-row/index?layout_page_id=#form.layout_page_id#&zsid=#request.zsid#');
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
	if(application.zcore.functions.zso(form,'layout_row_id') EQ ''){
		form.layout_row_id = -1;
	}
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "layout_row_return"&form.layout_row_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	db.sql="SELECT * FROM #db.table("layout_row", request.zos.zcoreDatasource)# 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	layout_row_deleted = #db.param(0)# and 
	layout_row_id=#db.param(form.layout_row_id)#";
	qRoute=db.execute("qRoute");
	application.zcore.functions.zQueryToStruct(qRoute, form, 'layout_page_id');
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
	Row</h2>
	<cfscript>
	if(form.layout_row_active EQ ""){
		form.layout_row_active=1;
	}

	</cfscript>
	<form class="zFormCheckDirty" action="/z/admin/layout-row/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?layout_page_id=#form.layout_page_id#&amp;layout_row_id=#form.layout_row_id#" method="post">
		<input type="hidden" name="modalpopforced" value="#form.modalpopforced#" />
		<table style="width:100%;" class="table-list">
			<tr>
				<th>Active</th>
				<td>#application.zcore.functions.zInput_Boolean("layout_row_active")#</td>
			</tr>
			<!--- <tr>
				<th style="width:1%; white-space:nowrap;" class="table-white">Photos:</th>
				<td colspan="2" class="table-white"><cfscript>
				ts=structnew();
				ts.name="layout_row_image_library_id";
				ts.value=form.layout_row_image_library_id;
				application.zcore.imageLibraryCom.getLibraryForm(ts);
				</cfscript></td>
			</tr>  --->
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm">Save</button>
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<button type="button" name="cancel" onclick="window.location.href = '/z/admin/layout-row/index?layout_page_id=#form.layout_page_id#';">Cancel</button>
					</cfif>
				</td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="getReturnLayoutRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	var db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("layout_row", request.zos.zcoreDatasource)# event 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	layout_page_id=#db.param(form.layout_page_id)# and 
	layout_row_deleted = #db.param(0)# and 
	layout_row_id=#db.param(form.layout_row_id)#";
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
	echo('<td>#row.layout_row_id#</td> 
	<td>Preview Not Implemented</td>
	<td>');
		if(row.layout_row_active EQ 1){
			echo('Yes');
		}else{
			echo('No');
		}
	echo('</td>  
	<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(row.layout_row_id)#</td>
	<td> 
	<a href="/z/admin/layout-row/edit?layout_page_id=#form.layout_page_id#&amp;layout_row_id=#row.layout_row_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit</a> | 
	<a href="/z/admin/layout-column/index?layout_page_id=#form.layout_page_id#&amp;layout_row_id=#row.layout_row_id#&amp;modalpopforced=1">Manage Columns</a> | 
	<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/admin/layout-row/delete?layout_page_id=#form.layout_page_id#&amp;layout_row_id=#row.layout_row_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a></td>');
	</cfscript>
</cffunction>

	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	//application.zcore.functions.zSetPageHelpId("5.4"); 
	db.sql="select * from #db.table("layout_page", request.zos.zcoreDatasource)# 
	WHERE 
	layout_page_id=#db.param(form.layout_page_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_page_deleted = #db.param(0)#  ";
	qPage=db.execute("qPage");  
	db.sql="select * from #db.table("layout_row", request.zos.zcoreDatasource)# 
	WHERE  
	layout_page_id=#db.param(form.layout_page_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_row_deleted = #db.param(0)# 
	ORDER BY layout_row_sort ASC ";
	qLayout=db.execute("qLayout");  
	application.zcore.functions.zStatusHandler(request.zsid); 
	</cfscript>
	<h2>Manage Rows for Custom Layout Page</h2>
	<p><a href="/z/admin/layout-page/index?layout_page_id=#qPage.layout_page_id#">#qPage.layout_page_name#</a> /</h2>
	<!--- <p><a href="/z/admin/layout-row/add?layout_page_id=#form.layout_page_id#">Add Row</a></p> --->
	<p><a href="##" onclick="if(window.confirm('Are you sure you want to add a row?')){ window.location.href='/z/admin/layout-row/insert?layout_row_active=1&amp;layout_page_id=#form.layout_page_id#'; } return false;">Add Row</a></p>
	<cfif qLayout.recordcount EQ 0>
		<p>No rows have been added.</p>
	<cfelse>
		<table id="sortRowTable" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Preview</th> 
				<th>Active</th> 
				<th>Sort</th>
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfscript>
				for(row in qLayout){ 
					echo('<tr #variables.queueSortCom.getRowHTML(row.layout_row_id)# ');
					if(qLayout.currentRow MOD 2 EQ 0){
						echo('class="row2"');
					}else{
						echo('class="row1"');
					}
					echo('>');
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