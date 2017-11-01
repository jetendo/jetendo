<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	form.landing_page_id=application.zcore.functions.zso(form, 'landing_page_id');

	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	 
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	db=request.zos.queryObject; 
	//application.zcore.functions.zSetPageHelpId("5.4"); 

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
	layout_page_deleted = #db.param(0)#  ";
	qPage=db.execute("qPage");  

	db.sql="select * from #db.table("layout_row", request.zos.zcoreDatasource)# 
	WHERE  
	layout_page_id=#db.param(form.layout_page_id)# and 
	layout_row_active=#db.param(1)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_row_deleted = #db.param(0)# 
	ORDER BY layout_row_sort ASC ";
	qRow=db.execute("qRow");  
	application.zcore.functions.zStatusHandler(request.zsid); 
	</cfscript>
	<p>
		<a href="/z/section/admin/section-admin/index">Sections</a> / 
		<a href="/z/admin/landing-page/index?section_id=#form.section_id#">#qLanding.landing_page_meta_title#</a> /    
	</p>
	<h2>Manage Rows for Custom Layout Page</h2> 
	<!--- <p><a href="/z/admin/layout-row/add?layout_page_id=#form.layout_page_id#">Add Row</a></p> --->
	<!--- <p><a href="##" onclick="if(window.confirm('Are you sure you want to add a row?')){ window.location.href='/z/admin/layout-row/insert?layout_row_active=1&amp;landing_page_id=#form.landing_page_id#&amp;layout_page_id=#form.layout_page_id#'; } return false;">Add Row</a></p> --->
	<cfif qRow.recordcount EQ 0>
		<p>No rows have been added.</p>
	<cfelse>
		<table id="sortRowTable" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Preview</th>  
				<!--- <th>Sort</th> --->
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfscript>
				for(row in qRow){ 
					echo('<tr ');
					//echo('<tr #variables.queueSortCom.getRowHTML(row.layout_row_id)# ');
					if(qRow.currentRow MOD 2 EQ 0){
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


<cffunction name="getLayoutRowHTML" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	init();
	row=arguments.row;
	echo('<td>#row.layout_row_id#</td> 
	<td>Preview Not Implemented</td> 
	<td>  
	<a href="/z/admin/landing-page-column/index?landing_page_id=#form.landing_page_id#&amp;layout_page_id=#form.layout_page_id#&amp;layout_row_id=#row.layout_row_id#&amp;modalpopforced=1">Manage Columns</a> 
	</td>');
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>