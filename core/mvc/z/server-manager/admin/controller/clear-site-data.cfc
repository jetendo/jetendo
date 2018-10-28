<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("You can only use this feature on the test server");
	}
	</cfscript>
</cffunction>

<!--- /z/server-manager/admin/clear-site-data/index?sid=#form.sid# --->
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init();
	application.zcore.functions.zStatusHandler(request.zsid);
	var db=request.zos.queryObject;
	form.sid=application.zcore.functions.zso(form, 'sid', true, 0);
	if(form.sid EQ 0){
		throw("Invalid site id");
	}
	db.sql="select * from #db.table("site", request.zos.zcoredatasource)# WHERE 
	site_deleted=#db.param(0)# and 
	site_id=#db.param(form.sid)#";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){
		throw("Site doesn't exist");
	}

	</cfscript>
	<cfif request.zos.isTestServer>
		<h2>Current Server: Test Server</h2>
	<cfelse>
		<h2>Current Server: Live Server</h2>
	</cfif>
	<h2>Clear Data For #qSite.site_domain#</h2>
	<p>Check the boxes for any data you wish to clear from this site.  Note, all database records and files associated to these records will be deleted.  If you have image libraries attached to records and you don't clear all the image libraries, they may continue to exist, but they will be orphaned and invisible.</p>
	<form id="clearDataForm" action="/z/server-manager/admin/clear-site-data/process?sid=#form.sid#" method="post">
		<p><input type="button" name="clearCheckAll" class="clearCheckAll" value="Check All Boxes"></p>
		<p><input type="checkbox" name="clearBlog" id="clearBlog" value="1" /> <label for="clearBlog">Clear Blog?</label></p>
		<p><input type="checkbox" name="clearCustomGroupFieldsAndData" id="clearCustomGroupFieldsAndData" value="1" /> <label for="clearCustomGroupFieldsAndData">Clear Custom Group Fields and Data?</label></p>
		<p><input type="checkbox" name="clearCustomGroupData" id="clearCustomGroupData" value="1" /> <label for="clearCustomGroupData">Clear Custom Group Data?</label></p>
		<p><input type="checkbox" name="clearEvents" id="clearEvents" value="1" /> <label for="clearEvents">Clear Events?</label></p>

		<p><input type="checkbox" name="clearJobs" id="clearJobs" value="1" /> <label for="clearJobs">Clear Jobs?</label></p>
		<p><input type="checkbox" name="clearFilesImages" id="clearFilesImages" value="1" /> <label for="clearFilesImages">Clear Files, Images and Videos?</label></p>

		<p><input type="checkbox" name="clearImageLibraries" id="clearImageLibraries" value="1" /> <label for="clearImageLibraries">Clear Image Libraries?</label></p>
		<p><input type="checkbox" name="clearLeadConfigAndData" id="clearLeadConfigAndData" value="1" /> <label for="clearLeadConfigAndData">Clear Lead Config and Data?</label></p>
		<p><input type="checkbox" name="clearLeadData" id="clearLeadData" value="1" /> <label for="clearLeadData">Clear Lead Data?</label></p>
		<p><input type="checkbox" name="clearMarketingConfigAndData" id="clearMarketingConfigAndData" value="1" /> <label for="clearMarketingConfig">Clear Marketing Config and Data?</label></p>
		<p><input type="checkbox" name="clearMarketingReportData" id="clearMarketingReportData" value="1" /> <label for="clearMarketingReportData">Clear Marketing Data?</label></p>
		<p><input type="checkbox" name="clearMenus" id="clearMenus" value="1" /> <label for="clearMenus">Clear Menus?</label></p>
		<p><input type="checkbox" name="clearMenuButtons" id="clearMenuButtons" value="1" /> <label for="clearMenuButtons">Clear Menu Buttons?</label></p>
		<p><input type="checkbox" name="clearPages" id="clearPages" value="1" /> <label for="clearPages">Clear Pages?</label></p>
		<p><input type="checkbox" name="clearSiteOptions" id="clearSiteOptions" value="1" /> <label for="clearSiteOptions">Clear Site Options?</label></p>
		<p><input type="checkbox" name="clearRealEstateSearches" id="clearRealEstateSearches" value="1" /> <label for="clearRealEstateSearches">Clear Real Estate Searches?</label></p>
		<p><input type="checkbox" name="clearRentals" id="clearRentals" value="1" /> <label for="clearRentals">Clear Rentals?</label></p>
		<p><input type="checkbox" name="clearUsers" id="clearUsers" value="1" /> <label for="clearUsers">Clear Users?</label></p>
		<p><input type="checkbox" name="clearUserTracking" id="clearUserTracking" value="1" /> <label for="clearUserTracking">Clear User Tracking?</label></p> 

		<p><input type="button" name="clearData" class="clearDataSubmit" value="Clear Data"></p>
		<h2 class="clearDataWait" style="display:none;">Please wait while this data is being cleared.</h2>
	</form>

	<cfscript>
	arrKey=structkeyarray(application.zcore.tablesWithSiteIdStruct);
	arraySort(arrKey, "text", "asc");
	echo('<h2>Filesystem usage summary</h2>');
	homeUsage=application.zcore.functions.zGetDiskUsage(request.zos.globals.homedir);
	privatehomeUsage=application.zcore.functions.zGetDiskUsage(request.zos.globals.privatehomedir);
	echo("<h3>Source code & static files: "&homeUsage&'</h3>');
	echo("<h3>Site uploads / cache: "&privatehomeUsage&'</h3>');
	echo('<h2>Database usage summary</h2><p>This shows the total number of records for this site in all tables, except ones that are empty.</p>');
	for(t in arrKey){
		arrT=listToArray(t, ".");
		db.sql="SELECT count(*) count from #db.table(arrT[2], arrT[1])# WHERE site_id = #db.param(form.sid)# and #arrT[2]#_deleted=#db.param(0)#";
		qCount=db.execute("qCount");
		if(qCount.count NEQ 0){
			echo(arrT[1]&"."&arrT[2]&" has #qCount.count# records<br>");
		}
	}
	</cfscript>
	<script type="text/javascript">
	zArrDeferredFunctions.push(function(){
		$(".clearCheckAll").on("click", function(){
			$("##clearDataForm input").each(function(){
				if(this.type == "checkbox"){
					this.checked=true;
				}
			});
		});
		$(".clearDataSubmit").on("click", function(){
			if(window.confirm("Are you sure you want to clear this data permanently?")){
				$("##clearDataForm").trigger("submit");
				$(this).hide();
				$(".clearDataWait").show();
			}
		});
	});
	</script>
</cffunction>

<cffunction name="process" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	init();
	var db=request.zos.queryObject;
	form.sid=application.zcore.functions.zso(form, 'sid', true, 0);
	if(form.sid EQ 0){
		throw("Invalid site id");
	}
	form.clearSiteOptions=application.zcore.functions.zso(form, 'clearSiteOptions', true, 0);
	form.clearImageLibraries=application.zcore.functions.zso(form, 'clearImageLibraries', true, 0);
	form.clearMarketingConfigAndData=application.zcore.functions.zso(form, 'clearMarketingConfigAndData', true, 0);
	form.clearMarketingReportData=application.zcore.functions.zso(form, 'clearMarketingReportData', true, 0);
	form.clearUsers=application.zcore.functions.zso(form, 'clearUsers', true, 0);
	form.clearRentals=application.zcore.functions.zso(form, 'clearRentals', true, 0);
	form.clearFilesImages=application.zcore.functions.zso(form, 'clearFilesImages', true, 0);
	form.clearUserTracking=application.zcore.functions.zso(form, 'clearUserTracking', true, 0);
	form.clearBlog=application.zcore.functions.zso(form, 'clearBlog', true, 0);
	form.clearPages=application.zcore.functions.zso(form, 'clearPages', true, 0);
	form.clearLeadData=application.zcore.functions.zso(form, 'clearLeadData', true, 0);
	form.clearLeadConfigAndData=application.zcore.functions.zso(form, 'clearLeadConfigAndData', true, 0); 
	form.clearMenus=application.zcore.functions.zso(form, 'clearMenus', true, 0);
	form.clearMenuButtons=application.zcore.functions.zso(form, 'clearMenuButtons', true, 0);
	form.clearCustomGroupFieldsAndData=application.zcore.functions.zso(form, 'clearCustomGroupFieldsAndData', true, 0);
	form.clearCustomGroupData=application.zcore.functions.zso(form, 'clearCustomGroupData', true, 0);
	form.clearEvents=application.zcore.functions.zso(form, 'clearEvents', true, 0);
	form.clearJobs=application.zcore.functions.zso(form, 'clearJobs', true, 0);
	form.clearRealEstateSearches=application.zcore.functions.zso(form, 'clearRealEstateSearches', true, 0);

	privateHomeDir=application.zcore.functions.zVar("privatehomedir", form.sid); 
	if(form.clearUserTracking EQ 1){ 
		db.sql="DELETE FROM #db.table("track_user", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and track_user_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("track_user_x_convert", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and track_user_x_convert_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("track_page", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and track_page_deleted=#db.param(0)#";
		db.execute("qDelete"); 
	}
	if(form.clearRentals EQ 1){
		db.sql="DELETE FROM #db.table("rate", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and rate_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("rental", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and rental_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("rental_amenity", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and rental_amenity_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("rental_category", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and rental_category_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("rental_config", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and rental_config_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("rental_x_amenity", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and rental_x_amenity_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("rental_x_category", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and rental_x_category_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and search_deleted=#db.param(0)# and 
		app_id=#db.param(13)#";
		db.execute("qDelete");
	}

	if(form.clearSiteOptions EQ 1){
		db.sql="UPDATE #db.table("site_option", request.zos.zcoreDatasource)#,
		#db.table("site_x_option", request.zos.zcoreDatasource)# 
		SET site_x_option_value=site_option_default_value, 
		site_option_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_x_option.site_id=#db.param(form.sid)# and 
		site_x_option.site_option_id = site_option.site_option_id and 
		site_x_option_deleted = #db.param(0)# and
		site_option.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("site_x_option.site_option_id_siteIDType"))# and 
		site_option_deleted = #db.param(0)#";
		db.execute("qUpdate");
	}
	if(form.clearMarketingConfigAndData EQ 1){ 
		ts={};
		ts.table="site";
		ts.datasource=request.zos.zcoredatasource;
		ts.struct={};
		ts.struct.site_id=form.sid; 
		ts.struct.site_deleted=0;

		// disable marketing features
		ts.struct.site_semrush_label_primary="";
		ts.struct.site_semrush_label_list="";
		ts.struct.site_calltrackingmetrics_cfc_path="";
		ts.struct.site_calltrackingmetrics_cfc_method="";
		ts.struct.site_calltrackingmetrics_import_datetime="";
		ts.struct.site_calltrackingmetrics_account_id="";
		ts.struct.site_calltrackingmetrics_access_key="";
		ts.struct.site_calltrackingmetrics_secret_key="";
		ts.struct.site_calltrackingmetrics_enable_import=""; 
		ts.struct.site_seomoz_id_list="";
		ts.struct.site_semrush_id_list="";
		ts.struct.site_webposition_id_list="";
		ts.struct.site_semrush_last_import_datetime="";
		ts.struct.site_seomoz_last_import_datetime="";
		ts.struct.site_google_analytics_exclude_keyword_list="";
		ts.struct.site_semrush_domain="";
		ts.struct.site_google_search_console_domain="";
		ts.struct.site_google_search_console_last_import_datetime="";
		ts.struct.site_google_analytics_keyword_last_import_datetime="";
		ts.struct.site_google_analytics_organic_last_import_datetime="";
		ts.struct.site_google_api_account_email="";
		ts.struct.site_google_analytics_view_id="";
		ts.struct.site_google_analytics_overview_last_import_datetime="";
		ts.struct.site_report_company_name="";
		ts.struct.site_exclude_lead_type_list="";
		ts.struct.site_report_start_date="";
		ts.struct.site_phone_tracking_label_text="";
		ts.struct.site_interspire_email_owner_id_list="";
		ts.struct.site_interspire_email_last_import_datetime="";
		ts.struct.site_campaign_monitor_user_id_list="";
		ts.struct.site_campaign_monitor_last_import_datetime="";
		ts.struct.site_monthly_email_campaign_count="";
		ts.struct.site_monthly_email_campaign_alert_day_delay=""; 
		ts.struct.site_facebook_page_id_list="";
		ts.struct.site_facebook_last_import_datetime="";
		ts.struct.site_facebook_insights_start_date="";
		application.zcore.functions.zUpdate(ts);
	}
	if(form.clearMarketingConfigAndData EQ 1 or form.clearMarketingReportData EQ 1){ 

		db.sql="DELETE FROM #db.table("newsletter_month", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and newsletter_month_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("newsletter_email", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and newsletter_email_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("keyword_ranking", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and keyword_ranking_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("ga_month", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and ga_month_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("ga_month_keyword", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and ga_month_keyword_deleted=#db.param(0)#";
		db.execute("qDelete");  
		db.sql="DELETE FROM #db.table("facebook_month", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and facebook_month_deleted=#db.param(0)#";
		db.execute("qDelete");
	}
	if(form.clearFilesImages EQ 1){
		db.sql="DELETE FROM #db.table("video", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and video_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("virtual_file", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and virtual_file_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("virtual_folder", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and virtual_folder_deleted=#db.param(0)#";
		db.execute("qDelete");
		application.zcore.functions.zDeleteDirectory(privateHomeDir&"/zupload/user/");
		application.zcore.functions.zDeleteDirectory(privateHomeDir&"/zuploadsecure/user/");
		application.zcore.functions.zDeleteDirectory(privateHomeDir&"/zupload/video/");
	}

	if(form.clearUsers EQ 1){
		db.sql="DELETE FROM #db.table("office", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and office_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("user", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and user_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("user_token", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and user_token_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("contact", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and contact_deleted=#db.param(0)#";
		db.execute("qDelete");
		application.zcore.functions.zDeleteDirectory(privateHomeDir&"/zupload/member/");
	}
	if(form.clearBlog EQ 1){
		db.sql="DELETE FROM #db.table("blog", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and blog_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("blog_comment", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and blog_comment_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("blog_version", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and blog_version_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("blog_tag", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and blog_tag_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("blog_tag_version", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and blog_tag_version_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("blog_x_tag", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and blog_x_tag_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("blog_x_category", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and blog_x_category_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("blog_category", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and blog_category_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("blog_category_version", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and blog_category_version_deleted=#db.param(0)#";
		db.execute("qDelete");
	}
	if(form.clearPages EQ 1){
		db.sql="DELETE FROM #db.table("content", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and content_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("content_version", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and content_version_deleted=#db.param(0)#";
		db.execute("qDelete");
	}
	if(form.clearLeadConfigAndData EQ 1){
		db.sql="DELETE FROM #db.table("inquiries_type", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and inquiries_type_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and inquiries_lead_template_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("inquiries_routing", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and inquiries_routing_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and inquiries_lead_template_x_site_deleted=#db.param(0)#";
		db.execute("qDelete");


	}
	if(form.clearLeadData EQ 1 or form.clearLeadConfigAndData EQ 1){
		db.sql="DELETE FROM #db.table("inquiries_feedback", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and inquiries_feedback_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("inquiries", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and inquiries_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and inquiries_autoresponder_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and inquiries_autoresponder_drip_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("inquiries_autoresponder_drip_log", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and inquiries_autoresponder_drip_log_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("inquiries_autoresponder_subscriber", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and inquiries_autoresponder_subscriber_deleted=#db.param(0)#";
		db.execute("qDelete");

	} 
	if(form.clearCustomGroupFieldsAndData EQ 1){
		db.sql="DELETE FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and site_x_option_group_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and site_x_option_group_set_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("site_option_app", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and site_option_app_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("site_option_group_map", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and site_option_group_map_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("site_x_option", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and site_x_option_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and search_deleted=#db.param(0)# and 
		app_id=#db.param(14)#";
		db.execute("qDelete");
		application.zcore.functions.zDeleteDirectory(privateHomeDir&"/zupload/site-options/");
		application.zcore.functions.zDeleteDirectory(privateHomeDir&"/zuploadsecure/site-options/");
	}
	if(form.clearCustomGroupData EQ 1 or form.clearCustomGroupFieldsAndData EQ 1){
		db.sql="DELETE FROM #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and site_option_group_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("site_option", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and site_option_deleted=#db.param(0)#";
		db.execute("qDelete");
	}
	if(form.clearMenus EQ 1){
		db.sql="DELETE FROM #db.table("menu", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and menu_deleted=#db.param(0)#";
		db.execute("qDelete");
		application.zcore.functions.zDeleteDirectory(privateHomeDir&"zupload/menu");
	}
	if(form.clearMenuButtons EQ 1 or form.clearMenus EQ 1){
		db.sql="DELETE FROM #db.table("menu_button_link", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and menu_button_link_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("menu_button", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and menu_button_deleted=#db.param(0)#";
		db.execute("qDelete");
	} 
	if(form.clearEvents EQ 1){
		db.sql="DELETE FROM #db.table("event", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and event_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("event_recur", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and event_recur_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("event_category", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and event_category_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("event_calendar", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and event_calendar_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("event_x_category", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and event_x_category_deleted=#db.param(0)#";
		db.execute("qDelete"); 
		db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and search_deleted=#db.param(0)# and 
		app_id=#db.param(17)#";
		db.execute("qDelete");
	}
	if(form.clearJobs EQ 1){
		db.sql="DELETE FROM #db.table("job", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and job_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("job_category", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and job_category_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("job_x_category", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and job_x_category_deleted=#db.param(0)#";
		db.execute("qDelete");

		db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and search_deleted=#db.param(0)# and 
		app_id=#db.param(18)#";
		db.execute("qDelete");
	}
	if(form.clearRealEstateSearches EQ 1){
		db.sql="DELETE FROM #db.table("saved_listing", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and saved_listing_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and mls_saved_search_deleted=#db.param(0)#";
		db.execute("qDelete"); 
	}
	if(form.clearImageLibraries EQ 1){
		db.sql="DELETE FROM #db.table("image_cache", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and image_cache_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("image", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and image_deleted=#db.param(0)#";
		db.execute("qDelete");
		db.sql="DELETE FROM #db.table("image_library", request.zos.zcoreDatasource)# WHERE site_id = #db.param(form.sid)# and image_library_deleted=#db.param(0)#";
		db.execute("qDelete");


		db.sql="UPDATE #db.table("blog", request.zos.zcoreDatasource)#
		SET blog_image_library_id=#db.param('0')#
		WHERE site_id = #db.param(form.sid)# and blog_deleted=#db.param(0)#";
		db.execute("qUpdate");
		db.sql="UPDATE #db.table("content", request.zos.zcoreDatasource)#
		SET content_image_library_id=#db.param('0')#
		WHERE site_id = #db.param(form.sid)# and content_deleted=#db.param(0)#";
		db.execute("qUpdate");
		db.sql="UPDATE #db.table("blog_version", request.zos.zcoreDatasource)#
		SET blog_image_library_id=#db.param('0')#
		WHERE site_id = #db.param(form.sid)# and blog_version_deleted=#db.param(0)#";
		db.execute("qUpdate");
		db.sql="UPDATE #db.table("content_version", request.zos.zcoreDatasource)#
		SET content_image_library_id=#db.param('0')#
		WHERE site_id = #db.param(form.sid)# and content_version_deleted=#db.param(0)#";
		db.execute("qUpdate");
		db.sql="UPDATE #db.table("event", request.zos.zcoreDatasource)#
		SET event_image_library_id=#db.param('0')#
		WHERE site_id = #db.param(form.sid)# and event_deleted=#db.param(0)#";
		db.execute("qUpdate");
		db.sql="UPDATE #db.table("job", request.zos.zcoreDatasource)#
		SET job_image_library_id=#db.param('0')#
		WHERE site_id = #db.param(form.sid)# and job_deleted=#db.param(0)#";
		db.execute("qUpdate");
		db.sql="UPDATE #db.table("rental", request.zos.zcoreDatasource)#
		SET rental_image_library_id=#db.param('0')#
		WHERE site_id = #db.param(form.sid)# and rental_deleted=#db.param(0)#";
		db.execute("qUpdate");
		db.sql="UPDATE #db.table("site_x_option_group_set", request.zos.zcoreDatasource)#
		SET site_x_option_group_set_image_library_id=#db.param('0')#
		WHERE site_id = #db.param(form.sid)# and site_x_option_group_set_deleted=#db.param(0)#";
		db.execute("qUpdate");
		db.sql="UPDATE #db.table("site_x_option_group", request.zos.zcoreDatasource)#, 
		#db.table("site_option", request.zos.zcoreDatasource)#
		SET site_x_option_group_value=#db.param('')#,
		site_x_option_group_updated_datetime=#db.param(request.zos.mysqlnow)#
		WHERE 
		site_x_option_group.site_id=#db.param(form.sid)# and 
		site_x_option_group.site_option_id = site_option.site_option_id and 
		
		site_x_option_group.site_x_option_group_deleted = #db.param(0)# and
		site_option.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("site_x_option_group.site_option_id_siteIDType"))# and 
		site_option_deleted = #db.param(0)#
		";
		db.execute("qUpdate");
		db.sql="UPDATE #db.table("blog", request.zos.zcoreDatasource)#
		SET blog_image_library_id=#db.param('0')#
		WHERE site_id = #db.param(form.sid)# and blog_deleted=#db.param(0)#"; 
		db.execute("qUpdate");
		application.zcore.functions.zDeleteDirectory(privateHomeDir&"zupload/library");
		application.zcore.functions.zDeleteDirectory(privateHomeDir&"/zuploadsecure/library/");
	}
	application.zcore.functions.zOS_cacheSiteAndUserGroups(form.sid);


	application.zcore.status.setStatus(request.zsid, "Data cleared", form, true);
	application.zcore.functions.zRedirect("/z/server-manager/admin/clear-site-data/index?sid=#form.sid#&zsid=#request.zsid#");
	</cfscript>
</cffunction>
</cfoutput>	
</cfcomponent>