<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="private">  
	<cfscript> 
	setting requestTimeout="100000";
	variables.userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36";

 	form.fpid=application.zcore.functions.zso(form, 'fpid', true, 0); 
 	form.fpid_other=application.zcore.functions.zso(form, 'fpid_other', true, 0); 
 	if(form.fpid_other NEQ 0){
 		form.fpid=0;
 	}
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	</cfscript>
	
</cffunction>

<cffunction name="status" localmode="modern" access="remote" roles="administrator">  
	<cfscript>  
	application.zcore.template.setTag("title", "Import Facebook Stats Status");
	application.zcore.template.setTag("pagetitle", "Import Facebook Stats Status"); 
	</cfscript>
	<p>Status: #application.zcore.functions.zso(application, 'facebookImportStatus')#</p>
	<p><a href="/z/inquiries/admin/facebook-test/cancelFacebookImport" target="_blank">Cancel Facebook Import</a>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">  
	<cfscript>  
	init();
	db=request.zos.queryObject;
 	application.zcore.template.setTag("title", "Import Facebook Stats");

	 
	db.sql="select * from #db.table("facebook_page", request.zos.zcoreDatasource)# WHERE 
	facebook_page_deleted=#db.param(0)# 
	ORDER BY facebook_page_name ASC";
	qPage=db.execute("qPage");

	db.sql="select * from #db.table("facebook_page", request.zos.zcoreDatasource)# WHERE 
	facebook_page_id=#db.param(form.fpid)# and
	facebook_page_deleted=#db.param(0)# 
	ORDER BY facebook_page_name ASC";
	qPageSelected=db.execute("qPageSelected");
	</cfscript>
	<h2>Import Facebook Stats</h2>
	<p><strong>Important:</strong> If a new page id was just added, this script currently requires importing all accounts the first time.</p>
	<p>By default, all pages will be imported.  If you select a page below, and then click the import link, it will import only the selected page. If the page doesn't exist yet, you must import all pages.</p>
	<div class="z-mb-20">
		<form action="" method="get">
			<p>
			<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "fpid";
			selectStruct.query = qPage; 
			//selectStruct.queryParseLabelVars=true;
			selectStruct.queryLabelField = "facebook_page_name";
			selectStruct.queryValueField = "facebook_page_id"; 
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript> 
			or type page ID: <input type="text" name="fpid_other" value=""></p>
			<p><input type="submit" name="select1" value="Select"></p>
		</form>
	</div>

	<cfif form.fpid_other NEQ 0>
		<h3>Page ID Selected: #form.fpid_other#</h3>
		<cfscript>
		form.fpid=form.fpid_other;
		</cfscript>
	<cfelseif qPageSelected.recordcount EQ 0>
		<h3>No Page Selected</h3>
	<cfelse>
		<h3>Page Selected: #qPageSelected.facebook_page_name#</h3>
	</cfif>
	<p>To pull more then 3 months of recent data, make sure "Facebook Insights Start Date" is site globals is set to an older date.</p>
	<p>These may take minutes to hours to finish.</p>
	<p><a href="/z/inquiries/admin/import-facebook-stats/status" target="_blank">Show status</a></p>
	<p><a href="/z/inquiries/admin/facebook-test/cancelFacebookImport" target="_blank">Cancel Facebook Import</a></p>
	<p><a href="/z/inquiries/admin/facebook-test/listFacebookAccounts" target="_blank">List Facebook Accounts</a></p>

	<h3>Import Facebook Pages</h3>
	<p><a href="/z/inquiries/admin/facebook-test/index?pullEverything=1&amp;fpid=#form.fpid#" target="_blank">1) Import Everything</a> or 
	<a href="/z/inquiries/admin/facebook-test/index?fpid=#form.fpid#" target="_blank">1) Import Last 3 Months</a></p> 
 
	<!--- <h3>Import Facebook Pages and Posts (100 times slower to finish)</h3>
	<p><a href="/z/inquiries/admin/facebook-test/index?pullEverything=1&amp;postsEnabled=1&amp;fpid=#form.fpid#" target="_blank">1) Import Everything</a> or 
	<a href="/z/inquiries/admin/facebook-test/index?postsEnabled=1&amp;fpid=#form.fpid#" target="_blank">1) Import Last 3 Months</a></p>
	<p><a href="/z/inquiries/admin/facebook-test/getPostDetails?fpid=#form.fpid#" target="_blank">2) Import Details For All Posts (Not used for current reporting)</a></p>    --->
	
	<!---
	not import until posts are needed
	 <h3>Import Facebook Pages and Posts - All 3 Steps At Once (100 times slower to finish)</h2>
	<p><a href="/z/inquiries/admin/import-facebook-stats/downloadFacebook?pullEverything=1&amp;postsEnabled=1&amp;fpid=#form.fpid#" target="_blank">Import Everything and All Steps</a> or 
	<a href="/z/inquiries/admin/import-facebook-stats/downloadFacebook?postsEnabled=1&amp;fpid=#form.fpid#" target="_blank">1) Import Last 3 Months and Step 2/3</a></p> --->
 	
 	<h3>Misc Tasks</h3>
	<p><a href="/z/inquiries/admin/facebook-test/calculatePageTotals?fpid=#form.fpid#" target="_blank">Reprocess Monthly Calculations For All Sites/Pages (Fast)</a></p> 
	<p><a href="/z/inquiries/admin/facebook-test/getPostDetails?fpid=#form.fpid#" target="_blank">2) Import Details For All Posts (Not used for current reporting)</a></p> 

</cffunction>

	
<!--- /z/inquiries/admin/import-facebook-stats/facebookInstallPageTab --->
<cffunction name="facebookInstallPageTab" access="remote" localmode="modern">

	<cfscript>
	setting requesttimeout="100000";
	init();

	// need to have admin privileges on page 
	// need 2000 or more fans to be able to do create tabs.

	

	// /v2.11/#pageId#/tabs
	facebookTestCom=createobject("component", "facebook-test");
	facebookTestCom.installPageTab();

	</cfscript>
</cffunction>

<cffunction name="downloadFacebook" access="remote" localmode="modern">

	<cfscript>
	setting requesttimeout="100000";
	init();
	db=request.zos.queryobject;
	facebookTestCom=createobject("component", "facebook-test");
	facebookTestCom.index();
	facebookTestCom.getPostDetails();
	facebookTestCom.calculatePageTotals();
	</cfscript> 
</cffunction>
 
</cfoutput>
</cfcomponent>