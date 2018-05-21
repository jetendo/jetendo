<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
    application.zcore.adminSecurityFilter.requireFeatureAccess("Ecommerce", false);
	</cfscript>
	<h2>Ecommerce Manager</h2>
	 <ul class="z-t-18">
		<li><a href="/admin/order-log-admin/index">Orders</a></li>
		<li><a href="/admin/product-admin/index">Products</a></li>
		<li><a href="/admin/product-category-admin/index">Product Categories</a></li>
		<!--- <li><a href="/admin/product-global-option-type-admin/index">Global Product Options</a></li> --->
		<li><a href="/admin/ecommerce-client-config-admin/index">Ecommerce Settings</a></li>
		<li><a href="/admin/tax-admin/index">State Tax</a></li>
	</ul>
</cffunction>
	
<cffunction name="ipnLog" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	form.zLogIndex=application.zcore.functions.zso(form, 'zLogIndex', true, 1);

	db.sql="select count(paypal_ipn_log_id) count 
	from #db.table("paypal_ipn_log", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	paypal_ipn_log_deleted = #db.param(0)# ";
	qCount=db.execute("qCount");
	db.sql="select * from #db.table("paypal_ipn_log", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	paypal_ipn_log_deleted = #db.param(0)# 
	ORDER BY paypal_ipn_log_datetime ASC
	LIMIT #db.param((form.zLogIndex-1)*30)#, #db.param(30)# ";
	qIPN=db.execute("qIPN");
	echo('<table class="table-list">
		<tr>
		<th>ID</td>
		<th>Date</th>
		<th>Admin</th>
		</tr>');
	for(row in qIPN){
		echo('<tr>
		<td>#row.paypal_ipn_log_id#</td>
		<td>#dateformat(row.paypal_ipn_log_datetime, "m/d/yyyy")# at #timeformat(row.paypal_ipn_log_datetime, "h:mm tt")#</td>
		<td><a href="/z/ecommerce/admin/ecommerce-admin/ipnView?paypal_ipn_log_id=#row.paypal_ipn_log_id#">View</a></td>
		</tr>');
	}
	echo('</table>');
 
	if(qCount.count GT 30){
		// required
		searchStruct = StructNew();
		searchStruct.count = qCount.count;
		searchStruct.index = form.zLogIndex;
		// optional
		searchStruct.url = Request.zos.originalURL;
		searchStruct.buttons = 5;
		searchStruct.perpage = 30;
		searchStruct.indexName= "zLogIndex";
		// stylesheet overriding
		searchStruct.tableStyle = "table-list tiny";
		searchStruct.linkStyle = "tiny";
		searchStruct.textStyle = "tiny";
		searchStruct.highlightStyle = "highlight tiny";
		
		searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	}else{
		searchNav = "";
	}
	writeoutput(searchNav);
	</cfscript>
</cffunction>
	
<cffunction name="ipnView" localmode="modern" access="remote" roles="member">

	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("paypal_ipn_log", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	paypal_ipn_log_deleted = #db.param(0)# 
	LIMIT #db.param(0)#, #db.param(30)#";
	qIPN=db.execute("qIPN");
	echo('<table class="table-list">
		<tr><th>ID</th><td>#row.paypal_ipn_log_id#</td></tr>
		<tr><th>Date</th><td>#dateformat(row.paypal_ipn_log_datetime, "m/d/yyyy")# at #timeformat(row.paypal_ipn_log_datetime, "h:mm tt")#</td></tr>
		<tr><th>Verified</th><td>#row.paypal_ipn_log_verified#</td></tr>
		<tr><th>ID</th><td></td></tr>
		<tr><th>ID</th><td></td></tr>
		<tr><th>Data</th><td>
		');
	for(row in qIPN){
		struct=deserializeJson(row.paypal_ipn_log_data);
		echo('<table class="table-list">
			<tr><th>Field</th><th>Value</th></tr>');
		for(i in struct){
			if(not isSimpleValue(struct[i])){
				savecontent variable="v"{
					writedump(struct[i]);
				}
			}else{
				v=struct[i];
			}
			echo('<tr><td>#i#</td><td>#v#</td></tr>');
		}
		echo('</table>');
	}
	echo('</td></tr>
	</table>');
	</cfscript>
</cffunction>
	
</cfoutput>
</cfcomponent>