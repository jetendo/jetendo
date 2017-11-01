<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>

	form.layout_page_id=application.zcore.functions.zso(form, 'layout_page_id', true, 0);
	form.layout_row_id=application.zcore.functions.zso(form, 'layout_row_id', true, 0);

	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	 
	</cfscript>
</cffunction>
  

<cffunction name="getLayoutRowHTML" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	init();
	row=arguments.row;
	echo('<td>#row.layout_column_id#</td> 
	<td>Preview Not Implemented</td>  
	<td>  
	<a href="/z/admin/landing-page-widget/edit?landing_page_id=#form.landing_page_id#&amp;layout_column_id=#row.layout_column_id#&amp;layout_row_id=#row.layout_row_id#&amp;modalpopforced=1">Manage Widgets</a> </td>');
	</cfscript>
</cffunction>

	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	//application.zcore.functions.zSetPageHelpId("5.4");
	form.landing_page_id=application.zcore.functions.zso(form, 'landing_page_id');

	db.sql="select * from #db.table("landing_page", request.zos.zcoreDatasource)# 
	WHERE 
	landing_page_id=#db.param(form.landing_page_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	landing_page_deleted = #db.param(0)#  ";
	qLanding=db.execute("qLanding");  

	form.section_id=qLanding.section_id;

	db.sql="select * from #db.table("section", request.zos.zcoreDatasource)# 
	WHERE 
	section_id=#db.param(form.section_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)#  ";
	qSection=db.execute("qSection");  

	form.layout_page_id=qLanding.layout_page_id;
  
	db.sql="select * from #db.table("layout_page", request.zos.zcoreDatasource)# 
	WHERE 
	layout_page_id=#db.param(form.layout_page_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_page_deleted = #db.param(0)# ";
	qPage=db.execute("qPage");  
	db.sql="select * from #db.table("layout_row", request.zos.zcoreDatasource)# 
	WHERE 
	layout_page_id=#db.param(form.layout_page_id)# and 
	layout_row_id=#db.param(form.layout_row_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_row_deleted = #db.param(0)#  ";
	qRow=db.execute("qRow");  
	db.sql="select * from #db.table("layout_column", request.zos.zcoreDatasource)# 
	WHERE 
	layout_page_id=#db.param(form.layout_page_id)# and 
	layout_row_id=#db.param(form.layout_row_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_column_deleted = #db.param(0)#  
	ORDER BY layout_column_sort ASC ";
	qColumn=db.execute("qColumn");  
	application.zcore.functions.zStatusHandler(request.zsid); 
 
	</cfscript>
	<p> 
	<a href="/z/section/admin/section-admin/index">Sections</a> / 
	<a href="/z/admin/landing-page/index?section_id=#form.section_id#">#qLanding.landing_page_meta_title#</a> /   
	<a href="/z/admin/landing-page-row/index?section_id=#form.section_id#&landing_page_id=#form.landing_page_id#&layout_row_id=#form.layout_row_id#">Row #qRow.layout_row_sort#</a> / 
	</p>
	<h2>Manage Columns for Custom Layout Page Row</h2>
	<!--- <p><a href="/z/admin/layout-page/index?layout_page_id=#qPage.layout_page_id#">#qPage.layout_page_name#</a> / 
	<a href="/z/admin/layout-row/index?layout_row_id=#qRow.layout_row_id#&amp;layout_page_id=#qPage.layout_page_id#">Row ###qRow.layout_row_sort# (ID###qRow.layout_row_id#)</a> /</p> --->
	<!--- <p><a href="/z/admin/layout-column/add?layout_page_id=#form.layout_page_id#">Add Column</a></p> --->
	<!--- <p><a href="##" onclick="if(window.confirm('Are you sure you want to add a column?')){ window.location.href='/z/admin/layout-column/insert?layout_row_id=#qRow.layout_row_id#&amp;layout_page_id=#form.layout_page_id#'; } return false;">Add Column</a></p> --->
	<cfif qColumn.recordcount EQ 0>
		<p>No columns have been added.</p>
	<cfelse>
		<table id="sortRowTable" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Preview</th>   
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfscript>
				for(row in qColumn){ 
					echo('<tr ');
					if(qColumn.currentRow MOD 2 EQ 0){
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