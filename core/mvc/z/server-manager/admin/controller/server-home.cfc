<cfcomponent>
<cfoutput> 
<cffunction name="unloadOtherSites" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("This can only be run on the test server.");
	}
	unloadCount=0;
	for(i in application.siteStruct){
		if(i EQ 1){
			continue;
		}
		if(i NEQ request.zos.globals.id){
			unloadCount++;
			structdelete(application.siteStruct, i);
			structdelete(application.siteAccessCache, i);
		}
	}
	echo(unloadCount&" sites unloaded");
	abort;
	</cfscript>
</cffunction>

<cffunction name="viewSharedMemory" access="remote" localmode="modern" roles="serveradministrator">
	
	<cfscript>
	setting requesttimeout="500";
	echo('<h1>Shared Memory Usage</h1>');
	db=request.zos.queryObject;
	db.sql="
	SELECT site_short_domain, site_option_group_name, site.site_id, COUNT(*) c 
	FROM #db.table("site", request.zos.zcoreDatasource)#, 
	#db.table("site_x_option_group", request.zos.zcoreDatasource)# s2, 
	#db.table("site_option_group", request.zos.zcoreDatasource)# s1  
	WHERE site_active=#db.param(1)# AND 
	site.site_deleted=#db.param(0)# and 
	s2.site_x_option_group_deleted=#db.param(0)# and 
	s1.site_option_group_deleted=#db.param(0)# and 
	s1.site_id = site.site_id AND 
	s1.site_option_group_id = s2.site_option_group_id AND 
	s1.site_id = s2.site_id AND 
	site_option_group_enable_cache = #db.param(1)# 
	GROUP BY site.site_id ";
	if(structkeyexists(form, 'groupReport')){
		db.sql&=", s1.site_option_group_id 
		ORDER BY c desc ";
	}else{
		db.sql&=" ORDER BY site_short_domain ASC";
	}
	qD=db.execute("qD");

	if(not structkeyexists(form, 'groupReport')){
		echo('<div style="width:450px; float:left; margin-right:20px;">');
		echo('<h2>## of cached values per site</h2>');
	}else{
		echo('<p><a href="/z/server-manager/admin/server-home/viewSharedMemory">Back to main report</a> /</p>');
		echo('<h2>## of cached values per site per group (note size column is for entire site, not the group)</h2>');
	}
	
	if(not structkeyexists(form, 'groupReport')){
		echo('<p><a href="/z/server-manager/admin/server-home/viewSharedMemory?groupReport=1">Show Top Groups Report</a></p>');
	}
	echo('<table class="table-list">
		<tr><th>Domain</th>');
	if(structkeyexists(form, 'groupReport')){
		echo('<th>Group</th>');
	}
	echo('<th>Count</th>
		<th>Size</th>
		</tr>');
	for(row in qD){
		echo('<tr><td>'&row.site_short_domain&'</td>');
		if(structkeyexists(form, 'groupReport')){
			echo('<td>#row.site_option_group_name#</td>');
		}
		echo('<td>'&row.c&'</td>
			<td>'&bytesToMB(sizeof(application.zcore.functions.zso(application.siteStruct, row.site_id)))&'mb</td>
		</tr>');
	}
	echo('</table>');

	if(not structkeyexists(form, 'groupReport')){


	echo('</div><div style="width:450px; float:left; margin-right:20px;">');
		/*

	 SELECT site_domain, COUNT(*) c FROM site, site_x_option_group_set s2, site_option_group s1  WHERE site_active='1' AND s1.site_id = site.site_id AND s1.site_option_group_id = s2.site_option_group_id AND s1.site_id = s2.site_id AND site_option_group_enable_cache = '1' GROUP BY site.site_id ORDER BY c DESC;

	 SELECT site_domain, COUNT(*) c FROM site, site_x_option_group s2, site_option_group s1  WHERE site_active='1' AND s1.site_id = site.site_id AND s1.site_option_group_id = s2.site_option_group_id AND s1.site_id = s2.site_id AND site_option_group_enable_cache = '1' GROUP BY site.site_id ORDER BY c DESC;
	  
		*/
		application.zcore.user.requireAllCompanyAccess();
		a=[request, application, server];
		a2=['request', 'application', 'server'];
		a=[application, server];
		a2=['application', 'server'];
		for(i=1;i LTE arraylen(a);i++){
			c=a[i];
			totalSize=0;
			echo('<h2>'&a2[i]&'</h2>');
			echo('<table class="table-list">
				<tr><th>Key</th>
				<th>Type</th>
				<th>Count</th>
				<th>Size</th>
				</tr>');
			for(n in c){
				if(n GT 500){
					// had to skip oversized key.
					continue;
				}
				f=c[n];
				type="string";
				count=1;
				if(isstruct(f)){
					type="struct";
					count=structcount(f);
				}else if(isarray(f)){
					type="array";
					count=arraylen(f); 
				}else{
					continue;
				}
				s=sizeof(f);
				echo('<tr><td>#n#</td>
				<td>#type#</td>
				<td>#count#</td>
				<td>#bytesToMB(s)#mb</td>
				</tr>'); 
				if(a2[i] EQ "application" and (n EQ "customSessionStruct" or n EQ "siteStruct")){
					continue;
				}
				for(n2 in f){
					f2=f[n2];
					type="string";
					count=1;
					s=sizeof(f2);
					totalSize+=s;
					if(isstruct(f2)){
						type="struct";
						count=structcount(f2);
					}else if(isarray(f2)){
						type=" array";
						count=arraylen(f2);  
					}else{
						continue;
					}
					echo('<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;#n2#</td>
					<td>#type#</td>
					<td>#count#</td>
					<td>#bytesToMB(s)#mb</td>
					</tr>');  
				}
			}
			echo('</table><br />');
			echo('<p><strong>Total Size for #a2[i]#: #bytesToMB(totalSize)#mb</strong></p><hr />');
			echo('</div><div style="width:450px; float:left; margin-right:20px;">');
		} 
		echo('</div>');
	}
	</cfscript>

</cffunction>

<cffunction name="bytesToMB" localmode="modern" access="public">
	<cfargument name="bytes" type="numeric" required="yes">
	<cfscript>
	return numberformat(arguments.bytes/1024/1024, "_.__");
	</cfscript>
</cffunction>
<cffunction name="viewErrors" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	</cfscript>
	<h2>Verify Sites Error Log</h2>
	<textarea name="name2" cols="100" rows="40">#application.zcore.functions.zreadfile(request.zos.globals.serverPrivateHomedir&"verifySitesLog.txt")#
	</textarea>
</cffunction>
<cffunction name="countAllSites" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var i=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	setting requesttimeout="1000";
	var db=request.zos.queryObject;
	db.sql="select replace(replace(site_short_domain, #db.param('www.')#, #db.param('')#), #db.param('.'&request.zos.testDomain)#, #db.param('')#) domain
	from #db.table("site", request.zos.zcoredatasource)#
	where site_active=#db.param(1)# and 
	site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)#
	ORDER BY domain ASC";
	local.qSite=db.execute("qSite");
	
	writeoutput('<h2>Source Code Line Count Report For All Sites</h2>
	<p>Currently counts only .CFM and .CFC files.</p>
	<table style="border-spacing:0px;" class="table-white">
	<tr>
	<th>Domain</th>
	<th>CFM</th>
	<th>CFC</th>
	<th>HTML</th>
	<th>Javascript</th>
	<th>CSS</th>
	<th>Total</th>
	</tr>');
	local.ts={
		cfcLines:0,
		cfmLines:0,
		htmlLines:0,
		jsLines:0,
		cssLines:0,
		totalLines:0
	}
	for(local.row in local.qSite){
		form.path=application.zcore.functions.zGetDomainInstallPath(local.row.domain);
		if(form.path NEQ "" and directoryexists(form.path) and form.path DOES NOT CONTAIN 'mxunit'){
			i++;
			if(i MOD 2 EQ 0){
				writeoutput('<tr class="table-white">');
			}else{
				writeoutput('<tr class="table-bright">');
			}
			local.rs=application.zcore.functions.zCountCFMLLinesInDirectory(form.path);
			local.ts.cfcLines+=local.rs.cfcLines;
			local.ts.cfmLines+=local.rs.cfmLines;
			local.ts.htmlLines+=local.rs.htmlLines;
			local.ts.jsLines+=local.rs.jsLines;
			local.ts.cssLines+=local.rs.cssLines;
			local.ts.totalLines+=local.rs.totalLines;
			writeoutput('
			<td>'&local.row.domain&'</td>
			<td>'&numberformat(local.rs.cfmLines)&'</td>
			<td>'&numberformat(local.rs.cfcLines)&'</td>
			<td>'&numberformat(local.rs.htmlLines)&'</td>
			<td>'&numberformat(local.rs.jsLines)&'</td>
			<td>'&numberformat(local.rs.cssLines)&'</td>
			<td>'&numberformat(local.rs.totalLines)&'</td>
			</tr>');
		}
	}
	writeoutput('<tr>
	<th><strong>Total</strong></th>
	<th>'&numberformat(local.ts.cfmLines)&'</th>
	<th>'&numberformat(local.ts.cfcLines)&'</th>
	<th>'&numberformat(local.ts.htmlLines)&'</th>
	<th>'&numberformat(local.ts.jsLines)&'</th>
	<th>'&numberformat(local.ts.cssLines)&'</th>
	<th>'&numberformat(local.ts.totalLines)&'</th>
	</tr>');
	writeoutput('</table>');
	</cfscript>
</cffunction>

<cffunction name="countLines" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	setting requesttimeout="1000";
	form.path=application.zcore.functions.zso(form, 'path');
	if(form.path NEQ "" and directoryexists(form.path)){
		local.rs=application.zcore.functions.zCountCFMLLinesInDirectory(form.path);
		writeoutput('<h2>Source Code Line Count Report</h2>
	<p>Currently counts only .CFM and .CFC files.</p><p>');
		for(local.i in local.rs){
			writeoutput(local.i&": "&numberformat(local.rs[local.i])&'<br />');
		}
		writeoutput('</p>');
	}
	</cfscript>
	<h2>CFML Line Counter</h2>
	<form action="/z/server-manager/admin/server-home/countLines" method="get">
	Directory: <input type="text" name="path" value="#form.path#" /> <input type="submit" name="submit1" value="Count Lines" />
	</form>
	<hr />
	<h2>Other Reports</h2>
	<p><a href="/z/server-manager/admin/server-home/countAllSites" target="_blank">Count Source Code Lines For All Sites</a></p>
</cffunction>


<cffunction name="prepareForDistribution" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	dbUpgradeCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.db-upgrade");
	result=dbUpgradeCom.dumpInitialDatabase();
	if(not result){
		application.zcore.status.setStatus(request.zsid, "Failed to dump initial database.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	application.zcore.status.setStatus(request.zsid, "The current installation is ready for distribution.");
	application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var selectStruct=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8");
	application.zcore.functions.zStatusHandler(request.zsid); 
	</cfscript>
	<cfsavecontent variable="local.theMeta"> 
		<style>
		/* <![CDATA[ */
		.zdashboard-container{padding:1%; width:98%; float:left; background-color:##FFF;}
		.zdashboard-panel{width:30%; min-width:300px; margin-right:1%; margin-bottom:1%; padding:1%; border:1px solid ##CCC; float:left;}
		/* ]]> */
		</style>
		</cfsavecontent>
		<cfscript> 
		application.zcore.template.setTag("meta", local.theMeta);
		</cfscript> 
		<div class="zdashboard-container">
		  <h2>Dashboard</h2>
	<cfif not application.zcore.user.checkAllCompanyAccess()>
		<p>Server manager access is currently limited to your company's sites and users. If you need additional access, please contact the server administrator in control of this server.</p>
		<h3><a href="/z/server-manager/admin/site-select/index?sid=">Manage Sites</a></h3>
	<cfelse>
	
		  <div class="zdashboard-panel">
		  	<h3>Debugging</h3>
		  	<p><a href="/z/server-manager/admin/debug-log/debugger/index">CFML Debugging Logs</a></p>
			  <h3>Customize</h3>
			<p><a href="/z/server-manager/admin/white-label/index" target="_blank">White Label Settings</a></p>
			<p><a href="/z/server-manager/admin/mobile-conversion/index">Mobile Conversion</a></p>
		  	<h3>Maintenance Scripts</h3>
		  	<cfif request.zos.isTestServer>
		  		<p><a href="/z/server-manager/admin/server-home/unloadOtherSites">Unload Other Sites</a> Note: You can use /z/server-manager/admin/server-home/unloadOtherSites on any specific site to unload the others to reduce VM memory usage)</p>
		  	</cfif>
		  	<!--- <p><a href="/z/server-manager/admin/verify-table-increment/index" target="_blank">Verify Table Increment</a></p> --->
			<p><a href="/?zInitStatus=1" target="_blank">Show Jetendo Init Status &amp; Statistics</a></p>
			<p><a href="/z/server-manager/api/git-status/index" target="_blank">Developer git status report</a></p>
		  	<p><a href="/z/server-manager/tasks/cache-robot/index" target="_blank">Cache Robot</a></p> 
		  	<p><a href="/z/server-manager/tasks/validate-site-option-groups/index" target="_blank">Validate Site Option Groups</a></p>
		  	<p><a href="/z/server-manager/admin/server-home/viewSharedMemory">View Shared Memory</a></p>
			<p><a href="/z/server-manager/tasks/publish-system-css/autoPublishAll" target="_blank">Re-publish Global Layout CSS Framework for all sites</a></p>
			<p><a href="/z/server-manager/tasks/publish-system-css/index" target="_blank">Re-publish System CSS (Menus and CSS Framework)</a></p>
			<p><a href="/z/server-manager/admin/site-import/index" target="_blank">Site Import</a></p>
			<p><a href="/z/server-manager/admin/server-home/countLines">CFML Line Counter</a></p> 
			<p><a href="/z/server-manager/admin/server-home/prepareForDistribution" target="_blank">Prepare For Distribution</a></p>
			<p><a href="/z/misc/geocode/index">Testing Geocoding Features</a></p>
			<cfif request.zos.istestserver>
				<p><a href="/z/server-manager/admin/generate-sublime-project/index" target="_blank">Generate Sublime Text Project Files</a></p>
				<p><a href="/z/server-manager/admin/db-upgrade/installDatabaseVersion">Install Test Database</a></p>
			</cfif>
			<p><a href="/z/server-manager/admin/site/publishNginxAllSitesConfig" target="_blank">Publish Nginx Config For All Sites</a></p>
			<h3>Scheduled Tasks</h3>
			<p><a href="/z/server-manager/tasks/password-expiration/index" target="_blank">Delete passwords for inactive accounts</a></p>
			<p><a href="/z/server-manager/tasks/verify-tables/index" target="_blank">Verify Table Structure</a></p>
			<p>Verify Sites: 
			<cfscript>
			if(fileexists(request.zos.globals.serverPrivateHomedir&"verifySitesLog.txt")){
				writeoutput('<a href="/z/server-manager/admin/server-home/viewErrors">View Error Log</a>');
			}else{
				writeoutput('No Errors Detected');
			}
			</cfscript>
			</p>
			<p><a href="/z/server-manager/tasks/renew-lets-encrypt-ssl/index" target="_blank">Renew LetsEncrypt.org Certificates Near Expiration</a> (<a href="/z/server-manager/tasks/renew-lets-encrypt-ssl/status" target="_blank">Status</a>)</p>
			<p><a href="/z/server-manager/tasks/send-contacts-to-interspire/index" target="_blank">Send Contacts To Interspire</a></p>
			<p><a href="/z/server-manager/tasks/update-exchange-rate/index" target="_blank">Update Exchange Rates</a></p>
			<p><a href="/z/server-manager/tasks/send-lead-reminders/index" target="_blank">Send Lead Reminders</a></p>
			<p><a href="/z/server-manager/tasks/execute-http-queue/index" target="_blank">Execute HTTP Queue</a> (<a href="/z/server-manager/tasks/execute-http-queue/viewErrors" target="_blank">View errors</a>)</p>
			<p><a href="/z/server-manager/tasks/publish-missing/index" target="_blank">Publish 404 pages</a></p>
			<p><a href="/z/server-manager/tasks/verify-conventions/index" target="_blank">Verify Conventions</a></p>
			<p><a href="/z/server-manager/tasks/update-sitemap/index" target="_blank">Update Sitemaps</a></p>
			<p><a href="/z/server-manager/tasks/resend-autoresponders/index" target="_blank">Resend Autoresponders / Confirm Opt-in</a></p>
			<!--- <p><a href="/z/blog/admin/ping/index" target="_blank">Blog Ping</a></p> --->
			<p><a href="/z/_com/display/skin?method=deleteOldCache">Delete Old Skin File Versioning Cache</a></p>
			<!--- <p><a href="/z/server-manager/tasks/memory-dump/index" target="_blank">Memory Dump</a></p> --->
			<p><a href="/z/misc/system/index" target="_blank">CFML server uptime and session clearing</a></p>
			<p><a href="/z/event/tasks/project-events/index" target="_blank">Project Events</a></p>
			<p><a href="/z/server-manager/tasks/site-backup/index" target="_blank">Backup All Sites</a></p>
			<p><a href="/z/server-manager/tasks/site-backup/deleteOldBackups" target="_blank">Delete Old Site Backups</a></p>

			<p><a href="/z/server-manager/tasks/search-index/index" target="_blank">Re-index All Site Content</a></p>
			<p><a href="/z/server-manager/tasks/call-tracking-metrics-import/index" target="_blank">CallTrackingMetrics Import</a> (
				<cfscript>
				metricsCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.call-tracking-metrics-import");
				r=metricsCom.progress();
				echo(r);
				if(r NEQ "Not running"){
					echo(' | <a href="/z/server-manager/tasks/call-tracking-metrics-import/cancel">Cancel</a>');	
				}
				</cfscript> 
				
				)</p>
			<p><a href="/z/server-manager/tasks/verify-apps/index" target="_blank">Verify Apps</a></p>
			<p><a href="/z/_com/zos/cloudFile?method=executePurgeOldFiles">Cloud Files - Purge Old Files</a></p>
			<p><a href="/z/server-manager/tasks/send-mailing-list-alerts/index?forceDebug=1" target="_blank">Debug Mailing List Alerts (Won't Send Email)</a></p>
			<cfif request.zos.istestserver>
				<h3>Unit Tests</h3>
				<cfscript>
				db.sql="select site_domain from #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
				where site_active=#db.param('1')#  and 
				site_unit_testing_domain=#db.param(1)# and 
				site_deleted = #db.param(0)# and 
				site_id <> #db.param(-1)# 
				LIMIT #db.param(0)#,#db.param(1)#";
				local.qm=db.execute("qm");
				</cfscript>
				<cfif local.qm.recordcount EQ 0>
					<p>You must setup a site with "Enable Unit Testing?" enabled on globals page to run the unit tests.  The CFML engine must allow Java calls for testing since mxunit uses Java. All features you wish to test should be setup for that site in the server manager first.</p>
				<cfelse>
					<p>Warning: Running all tests could take a long time to complete. You can run individual tests by calling the runTestRemote method as a normal MVC url for the test file such as:</p>
					<p style="font-size:10px; "><a href="#local.qm.site_domain#/z/test/functions/fileAndDirectory/zGetDiskUsageTest/runTestRemote" target="_blank">/z/test/functions/fileAndDirectory/zGetDiskUsageTest/runTestRemote</a></p>
					<p><a href="#local.qm.site_domain#/z/test/runAllTests/index" target="_blank">Run All Tests</a></p>
				</cfif>
				<p><a href="/z/event/event/testRules" target="_blank">Run Event Recurring Rule Tests</a></p>
			</cfif>
			<h3>Listing App</h3>
			<p>These tasks may take a while to complete. Be patient and don't run the same task multiple times simultaneously.</p>
			<cfscript>
			db.sql="select * from #request.zos.queryObject.table("mls", request.zos.zcoreDatasource)# mls 
			where mls_status=#db.param('1')# and 
			mls_deleted = #db.param(0)#
			order by mls_id";
			// disable lazy
			local.qm=db.execute("qm", "", 10000, "query", false);
			</cfscript>
			<p>Display fields not output for mls provider:
			  <cfscript>
				selectStruct = StructNew();
				selectStruct.name = "mls_provider1";
				selectStruct.query = local.qm;
				//selectStruct.style="monoMenu";
				selectStruct.queryLabelField = "mls_name";
				selectStruct.queryValueField = "mls_provider";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
			  <button type="button" name="button3243" onclick="gotoFieldNotOutput();">Run</button>
			</p>
			<p>Reset data import:
			  <cfscript>
				selectStruct = StructNew();
				selectStruct.name = "mls_id1";
				selectStruct.query = local.qm;
				//selectStruct.style="monoMenu";
				selectStruct.queryLabelField = "##mls_id## | ##mls_name##";
				selectStruct.queryparselabelvars=true;
				selectStruct.queryValueField = "mls_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
			  <button type="button" name="button3243a" onclick="gotoReimport();">Run</button>
			</p>
			<p><a href="/z/listing/idx/reimport?mls_id=all&amp;disableHashClear=1">Re-process all listing files, but retain hash</a></p>
			<p><a href="/z/listing/tasks/update-metadata/index" target="_blank">Update Metadata</a></p>
			<p><a href="/z/listing/admin/remap-data/index">Remap Real Estate Saved Search Data</a></p>
			<p><a href="/z/listing/tasks/sendListingAlerts/index" target="_blank">Send Email Alerts</a></p>
			<p><a href="/z/listing/tasks/importMLS/index" target="_blank">Import Data</a> 
			<p><a href="/z/listing/tasks/mls-grid/index" target="_blank">MLS Grid</a> 
			<cfif structkeyexists(application.zcore, 'mlsImportIsRunning')>
				(Running -
					<a href="/z/listing/tasks/importMLS/abortImport">Cancel</a> 
					<cfif structkeyexists(application.zcore, 'idxImportStatus')>
						| #application.zcore.idxImportStatus#
					</cfif> | 
				)
			</cfif>
			 | <a href="/z/listing/tasks/importMLS/checkImportTimer" target="_blank">Check Import Timer</a></p>
			<p><a href="/z/listing/tasks/generateData/index" target="_blank">Generate Cache Data</a></p>
			<p><a href="/z/listing/tasks/listingLookupBuilder/index" target="_blank">Update Lookup Tables</a></p>
			<p><a href="/z/listing/tasks/listingLookupBuilder/updateDistanceCache" target="_blank">Update City Distance Table</a></p>
			<p><a href="/z/listing/ajax-geocoder/index?debugajaxgeocoder=1" target="_blank">Ajax Geocoder (debug)</a></p>
			
		  </div>
		</cfif>
	</div>
</cffunction>
</cfoutput>
</cfcomponent>