<cfcomponent>
<cfoutput>
<cffunction name="getSiteJson" localmode="modern" returntype="struct" access="public"> 
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	var row=arguments.row;
	if(row.deploy_server_secure EQ 1){
		link="https://"&row.deploy_server_host;
	}else{
		link="http://"&row.deploy_server_host;
	}
	safeLink=link&"/z/server-manager/api/site/getSiteById?sid=#row.site_x_deploy_server_remote_site_id#";
	newLink=safeLink&"&zusername=#urlencodedformat(row.deploy_server_email)#&zpassword=#urlencodedformat(row.deploy_server_password)#"; 
	r1=application.zcore.functions.zDownloadLink(newLink, 30); 
	rs={success:true};
	if(not r1.success){
		rs.success=false;
		rs.errorMessage='API call failed: <a href="#safeLink#" target="_blank">#safeLink#</a>';
	}else{
		try{
			rs.dataStruct=deserializeJson(r1.cfhttp.filecontent);
		}catch(Any e){
			writedump('Failed to deserializeJson on getSiteById response for sid=#row.site_x_deploy_server_remote_site_id#');
			writedump(r1);
			writedump(e);
			abort;
		}
		if(not rs.dataStruct.success){
			rs.success=false;
			rs.errorMessage='API call returned error message: #rs.dataStruct.errorMessage# | API Call URL: <a href="#safeLink#" target="_blank">#safeLink#</a>';
		}
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="deploySite" localmode="modern" access="remote" roles="serveradministrator"> 
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	form.deploy_server_group=application.zcore.functions.zso(form, 'deploy_server_group');
	if(form.method EQ "deploySite"){
		setting requesttimeout="150";
	}
	if(not application.zcore.user.hasDeployAdminAccess(false)){
		echo("You don't have access to deploy sites at this time of day.");
		abort;
	}
	if(not structkeyexists(application.siteStruct, form.sid)){

		db.sql="select * from #db.table("site", request.zos.zcoreDatasource)#
		WHERE site_id=#db.param(form.sid)# and 
		site_active=#db.param(1)# and 
		site_deleted = #db.param(0)#"; 
		qSite=db.execute("qSite");
		if(qSite.recordcount EQ 0){
			throw("Invalid site_id");
		}
		application.zcore.functions.zredirect(qSite.site_domain&"/z/server-manager/admin/deploy/deploySite?sid=#form.sid#"); 
	} 
	var db=request.zos.queryObject;
	db.sql="select * from #db.table("site_x_deploy_server", request.zos.zcoreDatasource)# site_x_deploy_server,
	#db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server 
	WHERE deploy_server.deploy_server_id = site_x_deploy_server.deploy_server_id and 
	site_x_deploy_server.site_id = #db.param(form.sid)# and 
	site_x_deploy_server_deleted = #db.param(0)# and 
	deploy_server_group=#db.param(form.deploy_server_group)# and 
	deploy_server_deleted = #db.param(0)#";
	var qDeploy=db.execute("qDeploy");
	if(qDeploy.recordcount EQ 0){
		throw("No deploy servers has been configured for this site yet.");
	}

	for(var row in qDeploy){
		// required to ensure the rsync command sends file to correct remote path.
		if(row.deploy_server_host EQ ""){
			// don't need to verify
			if(row.site_x_deploy_server_remote_site_id EQ 0 or row.site_x_deploy_server_remote_path EQ ""){
				throw("No deploy servers has been configured for this site yet.");
			}
		}else{
			rs=variables.getSiteJson(row);
			if(not rs.success){
				throw(rs.errorMessage);
			}
			/*
			disabled for now since it isn't working.  this would need to run after everything instead of before in the future.
			link=rs.dataStruct.domain&"/z/server-manager/api/server/executeCacheReset?zusername=#urlencodedformat(row.deploy_server_email)#&zpassword=#urlencodedformat(row.deploy_server_password)#&reset=site&zforce=1";  
			r1=application.zcore.functions.zdownloadlink(link, 120); 
			if(r1.success EQ false or r1.cfhttp.statuscode NEQ "200 OK"){ 
				application.zcore.status.setStatus(request.zsid, "Site files deployed, but the site cache failed to reset on the remote server.  You should manually verify the web site is still working.", form, true);
			} */
			db.sql="update #db.table("site_x_deploy_server", request.zos.zcoreDatasource)# 
			set site_x_deploy_server_remote_path = #db.param(rs.dataStruct.installPath)#,
			site_x_deploy_server_updated_datetime=#db.param(request.zos.mysqlnow)#  
			where site_id = #db.param(row.site_id)# and 
			site_x_deploy_server_id = #db.param(row.site_x_deploy_server_id)# and 
			site_x_deploy_server_deleted=#db.param(0)# ";
			db.execute("qUpdate");
		}
	}
	application.zcore.functions.zdeletefile(application.zcore.functions.zvar("privatehomedir", form.sid)&'__zdeploy-error.txt');
	application.zcore.functions.zdeletefile(application.zcore.functions.zvar("privatehomedir", form.sid)&'__zdeploy-complete.txt');
	if(structkeyexists(form, 'preview')){
		application.zcore.functions.zwritefile(application.zcore.functions.zvar("privatehomedir", form.sid)&'__zdeploy-preview.txt', '1');
	}
	application.zcore.functions.zwritefile(application.zcore.functions.zvar("privatehomedir", form.sid)&'__zdeploy-executed.txt', form.deploy_server_group);
	application.zcore.functions.zwritefile(request.zos.sharedPath&'__zdeploysite-executed.txt', "1");
	
	var start=gettickcount();
	while(true){
		if((gettickcount()-start)/1000 GT 120){
			if(structkeyexists(form, 'disableRedirect')){
				return false;
			}else{
				application.zcore.status.setStatus(request.zsid, "Deployment took longer then 120 seconds, and may still be running at #timeformat(now(), "h:mm:ss tt")#. Please verify that the site is working correct on the remote server(s) and clear any cached data that may need to be cleared.", form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/deploy/index?sid=#form.sid#&zsid=#request.zsid#");
			}
		}
		if(fileexists(application.zcore.functions.zvar("privatehomedir", form.sid)&'__zdeploy-error.txt')){
			e=application.zcore.functions.zReadFile(application.zcore.functions.zvar("privatehomedir", form.sid)&'__zdeploy-error.txt');
			if(structkeyexists(form, 'disableRedirect')){
				return false;
			}else{
				application.zcore.status.setStatus(request.zsid, "Deployment failed: "&e, form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/deploy/index?sid=#form.sid#&zsid=#request.zsid#");
			}

		}
		if(fileexists(application.zcore.functions.zvar("privatehomedir", form.sid)&'__zdeploy-complete.txt')){
			if(structkeyexists(form, 'preview') and form.method NEQ "deploySite"){
				application.zcore.status.setStatus(request.zsid, "Preview mode: No changes were made.  Review the potential changes at "&application.zcore.functions.zvar("privatehomedir", form.sid)&'__zdeploy-changes.txt');
			}
			application.zcore.functions.zdeletefile(application.zcore.functions.zvar("privatehomedir", form.sid)&'__zdeploy-complete.txt');
			break;
		}
		sleep(100);
	}
	if(structkeyexists(form, 'disableRedirect')){
		return true;
	}else{
		application.zcore.status.setStatus(request.zsid, "Deployment completed at #timeformat(now(), "h:mm:ss tt")#. Please verify that the site is working correct on the remote server(s) and clear any cached data that may need to be cleared.");
		application.zcore.functions.zRedirect("/z/server-manager/admin/deploy/index?sid=#form.sid#&zsid=#request.zsid#");
	}
	</cfscript>
</cffunction>

<!--- <cffunction name="deployAllSites" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	application.zcore.functions.zSetPageHelpId("8.4.4"); 
	</cfscript>
	<h2>Deploy All Sites</h2>
	<p>Are you sure you want to deploy all the following sites?</p>
	<p>WARNING: This process may take between minutes and hours depending on how much data has changed.</p>
	
	<p id="deployStatusId" style="display:none;">Please wait while the deploy process executes. (This could take a while if the changed files were large.)</p>
	<h2 id="deployButtonsId"><a href="/z/server-manager/admin/deploy/deployAllSites?confirm=1&amp;preview=1" onclick="document.getElementById('deployButtonsId').style.display='none';document.getElementById('deployStatusId').style.display='block';" class="z-manager-search-button">Preview Changes</a>&nbsp; &nbsp; &nbsp;<a href="/z/server-manager/admin/deploy/deployAllSites?confirm=1" onclick="document.getElementById('deployButtonsId').style.display='none';document.getElementById('deployStatusId').style.display='block';">Confirm</a>&nbsp; &nbsp; &nbsp;<a href="/z/server-manager/admin/deploy/index" class="z-manager-search-button">Cancel</a></h2>
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select *, replace(site_short_domain, #db.param('www.')#, #db.param('')#) shortDomain from 
	#db.table("site", request.zos.zcoreDatasource)# site,
	#db.table("site_x_deploy_server", request.zos.zcoreDatasource)# site_x_deploy_server,
	#db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server 
	where deploy_server.deploy_server_id = site_x_deploy_server.deploy_server_id and 
	deploy_server_deleted = #db.param(0)# and 
	site_x_deploy_server_deleted = #db.param(0)# and 
	deploy_server.deploy_server_deploy_enabled = #db.param(1)# and
	site.site_active = #db.param(1)# and 
	site_x_deploy_server.site_id = site.site_id and 
	site_deleted=#db.param(0)# and 
	site.site_id <> #db.param(-1)# ";
	if(structkeyexists(form, 'confirm')){
		db.sql&=" GROUP BY site.site_id ";
	}
	db.sql&=" ORDER BY shortDomain asc, deploy_server_host";
	var qDeploy=db.execute("qDeploy");
	if(structkeyexists(form, 'confirm')){
		setting requesttimeout="5000";
		arrError=[];
		for(row in qDeploy){
			form.sid=row.site_id;
			form.disableRedirect=true;
			result=deploySite();
			if(not result){
				arrayAppend(arrError, 'Failed to deploy: '&row.site_short_domain);
			}
		}
		if(arrayLen(arrError)){
			application.zcore.status.setStatus(request.zsid, arrayToList(arrError, "<br>"), form, true);
		}else{
			application.zcore.status.setStatus(request.zsid, "All sites deployed successfully.");
		}
		application.zcore.functions.zRedirect('/z/server-manager/admin/deploy/index?zsid=#request.zsid#');
	}else{
		echo('
		<h2>Current Deployment Configuration</h2>
		<table class="table-list">
		<tr>
		<th>Local Site</th>
		<th>Sync Type</th>
		<th>Deploy Host</th>
		<th>Remote Site</th>
		</tr>');
		for(row in qDeploy){
			echo('<tr>
			<td>#replace(replace(row.site_short_domain, "."&request.zos.testDomain, ""), "www.", "")#</td>
			<td>');
			if(row.site_x_deploy_server_source_only EQ 1){
				echo('Source Only');
			}else{
				echo('Source &amp; Files');
			}
			echo('</td>
			<td>'&row.deploy_server_host&'</td>
			<td>');
			if(row.site_x_deploy_server_remote_path EQ ""){
				echo(row.site_x_deploy_server_remote_site_id);
			}else{
				echo(row.site_x_deploy_server_remote_path);
			}
			echo('</td>
			</tr>');
		}
		echo('</table>');
	}
	</cfscript>
</cffunction> --->


<cffunction name="saveSite" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	index=0;
	while(true){
		index++;
		if(not structkeyexists(form, 'deploy_server_id'&index)){
			break;
		}
		if(form["site_x_deploy_server_remote_path#index#"] EQ ""){
			form["site_x_deploy_server_remote_path#index#"]=application.zcore.functions.zvar("homedir", form.sid);
		}
		/*if(application.zcore.functions.zso(form, "site_x_deploy_server_remote_site_id#index#", true, 0) EQ 0){
			continue;
		}*/
		db.sql=" replace into #db.table("site_x_deploy_server", request.zos.zcoreDatasource)# set 
		site_id=#db.param(form.sid)#, 
		site_x_deploy_server_deleted=#db.param(0)#,
		site_x_deploy_server_updated_datetime=#db.param(request.zos.mysqlnow)#,
		deploy_server_id =#db.param(form["deploy_server_id#index#"])#,
		site_x_deploy_server_remote_site_id=#db.param(form["site_x_deploy_server_remote_site_id#index#"])#,
		site_x_deploy_server_remote_path=#db.param(form["site_x_deploy_server_remote_path#index#"])#,
		site_x_deploy_server_source_only=#db.param(form["site_x_deploy_server_source_only#index#"])#";
		db.execute("qReplace");
	}
	application.zcore.status.setStatus(request.zsid, "Site deployment configuration saved.");
	application.zcore.functions.zRedirect("/z/server-manager/admin/deploy/index?sid=#form.sid#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="saveAllSites" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	if(not application.zcore.user.hasDeployAdminAccess(true)){
		echo("You don't have permission to use the import site feature.");
		abort;
	}
	var db=request.zos.queryObject; 
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	index=0;
	while(true){
		index++;
		if(not structkeyexists(form, 'deploy_server_id'&index)){
			break;
		}
		if(application.zcore.functions.zso(form, "site_x_deploy_server_remote_site_id#index#", true, 0) EQ 0){
			continue;
		}
		db.sql=" replace into #db.table("site_x_deploy_server", request.zos.zcoreDatasource)# set 
		site_id=#db.param(form["sid#index#"])#, 
		site_x_deploy_server_deleted=#db.param(0)#,
		site_x_deploy_server_updated_datetime=#db.param(request.zos.mysqlnow)#,
		deploy_server_id =#db.param(form["deploy_server_id#index#"])#,
		site_x_deploy_server_remote_site_id=#db.param(form["site_x_deploy_server_remote_site_id#index#"])#,
		site_x_deploy_server_source_only=#db.param(form["site_x_deploy_server_source_only#index#"])#";
		db.execute("qReplace");
	}
	application.zcore.status.setStatus(request.zsid, "Deployment configuration saved for all sites.");
	application.zcore.functions.zRedirect("/z/server-manager/admin/deploy/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>


<cffunction name="editAllSites" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	if(not application.zcore.user.hasDeployAdminAccess(true)){
		echo("You don't have permission to use the edit all sites feature.");
		abort;
	}
	var db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess(true);
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zStatusHandler(request.zsid);
	if(form.sid EQ ""){
		application.zcore.functions.zSetPageHelpId("8.4.3"); 
	}else{
		application.zcore.functions.zSetPageHelpId("8.1.1.3.1");
	}
	db.sql="select * from 
	#db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server 
	WHERE deploy_server_deploy_enabled = #db.param(1)# and 
	deploy_server_deleted = #db.param(0)#
	ORDER BY deploy_server_host asc";
	var qDeployServer=db.execute("qDeployServer");
	db.sql="select *, replace(site.site_short_domain, #db.param('www.')#, #db.param('')#) shortDomain from 
	(#db.table("site", request.zos.zcoreDatasource)# site, 
	#db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server)
	LEFT JOIN #db.table("site_x_deploy_server", request.zos.zcoreDatasource)# site_x_deploy_server 
	ON deploy_server.deploy_server_id = site_x_deploy_server.deploy_server_id and 
	site_x_deploy_server.site_id = site.site_id  and 
	site_x_deploy_server_deleted = #db.param(0)#
	WHERE site.site_active = #db.param(1)# and 
	site.site_id <> #db.param(-1)# and 
	site_deleted=#db.param(0)# and 
	deploy_server_deleted = #db.param(0)#  and 
	deploy_server_deploy_enabled = #db.param(1)#
	ORDER BY shortDomain asc, deploy_server_host asc";
	var qDeploy=db.execute("qDeploy");
	writeoutput('
	<h2>Edit Deployment Configuration For All Sites</h2>
	<form class="zFormCheckDirty" action="/z/server-manager/admin/deploy/saveAllSites" method="post">
	<input type="hidden" name="sid" value="#htmleditformat(form.sid)#" />
	<table class="table-list">');
	apiError=false;
	arrDeployServer=[];
	for(var row in qDeployServer){
		if(row.deploy_server_host EQ ""){
			continue;
		}
		if(row.deploy_server_secure EQ 1){
			link="https://"&row.deploy_server_host;
		}else{
			link="http://"&row.deploy_server_host;
		}
		link=link&"/z/server-manager/api/server/getConfig?zusername=#urlencodedformat(row.deploy_server_email)#&zpassword=#urlencodedformat(row.deploy_server_password)#"; 
		r1=application.zcore.functions.zDownloadLink(link, 30);
		writeoutput('<tr class="table-white">'); 
		if(not r1.success){ 
			writeoutput('<td colspan="2">Failed to download configuration.  <a href="/z/server-manager/admin/deploy-server/edit?deploy_server_id=#row.deploy_server_id#">Verify server configuration</a></td>');
			apiError=true;
		}else{ 
			// loop 
			try{
				dataStruct=deserializeJson(r1.cfhttp.filecontent); 
			}catch(Any excpt){
				savecontent variable="output"{
					writeoutput('Failed to execute deserializeJSON after calling <a href="#link#" target="_blank">#link#</a>.');
					writedump(r1);
					writedump(excpt);
				}
				throw(output);
			}
			arrLabel=[];
			arrValue=[];
			if(not structkeyexists(dataStruct, 'success')){
				writeoutput('<td colspan="2">API call returned invalid format.</td>');
				apiError=true;
			}else if(not dataStruct.success){
				writeoutput('<td colspan="2">API call returned error message: #dataStruct.errorMessage#</td>');
				apiError=true;
			}else{
				siteIdLookup={};
				for(i=1;i LTE arraylen(dataStruct.arrSite);i++){
					curSite=dataStruct.arrSite[i];
					siteIdLookup[curSite.shortDomain]=curSite.id;
					arrayAppend(arrLabel, curSite.shortDomain);
					arrayAppend(arrValue, curSite.id);
				}
				ts={
					siteIdLookup=siteIdLookup,
					labelsList:arrayToList(arrLabel, chr(9)),
					valuesList:arrayToList(arrValue, chr(9)),
					row: row,
					struct: dataStruct
				};
				arrayAppend(arrDeployServer, ts);
			}
		}
		echo('</tr>');
	}
	if(not apiError){
		echo('<tr>
		<th>SSH Host</th>
		<th>Remote Host</th>
		<th>Local Site</th>
		<th>Remote Site</th>
		<th>Sync Type</th>
		</tr>');
		index=0;
		for(row in qDeploy){
			index++;
			deployServer={};
			for(g=1;g LTE arraylen(arrDeployServer);g++){
				if(arrDeployServer[g].row.deploy_server_id EQ row.deploy_server_id){
					deployServer=arrDeployServer[g];
					break;
				}
			}
			curDomain=replace(replace(row.site_short_domain, '.'&request.zos.testDomain, ''), "www.", "");
			if(structcount(deployServer) EQ 0){
				if(row.deploy_server_host EQ ""){
					continue; // safe to ignore the jetendodev entries.
				}
				echo('<tr><td colspan="2">Couldn''t find deploy server. Database was corrected manually for site_id: #row.site_id#</td><td colspan="3">'&curDomain&'</td></tr>');
				continue;
			}
			echo('<tr>
			<td>'&deployServer.row.deploy_server_ssh_host&'</td>
			<td>'&deployServer.row.deploy_server_host&'</td>
			<td>'&curDomain&'</td><td>');
			if(row.site_x_deploy_server_remote_site_id NEQ ""){
				form["site_x_deploy_server_remote_site_id#index#"]=row.site_x_deploy_server_remote_site_id;
			}else{
				if(structkeyexists(deployServer.siteIdLookup, curDomain)){
					form["site_x_deploy_server_remote_site_id#index#"]=deployServer.siteIdLookup[curDomain];
				}else{
					form["site_x_deploy_server_remote_site_id#index#"]='';
				}
			}
			writeoutput('<input type="hidden" name="deploy_server_id#index#" value="#htmleditformat(row.deploy_server_id)#" />');
			writeoutput('<input type="hidden" name="sid#index#" value="#htmleditformat(row.site_id)#" />');
			writeoutput('<input type="hidden" name="site_x_deploy_server_remote_path#index#" value="#htmleditformat(row.site_x_deploy_server_remote_path)#" />');
			
			
			ts = StructNew();
			ts.name = "site_x_deploy_server_remote_site_id#index#";
			ts.listLabels = deployServer.labelsList;
			ts.listValues =deployServer.valuesList;
			ts.listLabelsDelimiter = chr(9); // tab delimiter
			ts.listValuesDelimiter = chr(9);
			ts.selectedValues=row.site_x_deploy_server_remote_site_id;
			application.zcore.functions.zInputSelectBox(ts);
			writeoutput('</td><td>');
			writeoutput('<input type="radio" name="site_x_deploy_server_source_only#index#" ');
			if(row.site_x_deploy_server_source_only EQ 1){
				echo('checked="checked"');
			}
			echo('value="1" /> Source Only 
			<input type="radio" name="site_x_deploy_server_source_only#index#" ');
			if(row.site_x_deploy_server_source_only EQ 0 or row.site_x_deploy_server_source_only EQ ''){
				echo('checked="checked"');
			}
			echo(' value="0" /> Source &amp; Files ');
			echo('</tr>');
		}
		writeoutput('<tr><td colspan="4"><input type="submit" name="submit1" value="Save" /> 
		<input type="button" name="cancel" onclick="window.location.href=''/z/server-manager/admin/deploy/index'';" value="Cancel" />
		</td></tr>');
	}
	writeoutput('</table>
	</form>');
	//<input type="submit" name="button" onclick="window.location.href='';" value="Deploy To All Servers" />
	</cfscript>
	
</cffunction>

<cffunction name="editSite" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	form.sid=application.zcore.functions.zso(form, 'sid');
	application.zcore.functions.zStatusHandler(request.zsid);
	if(form.sid EQ ""){
		application.zcore.status.setStatus(request.zsid, "form.sid is required.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/deploy/index?zsid=#request.zsid#");	
	}
	
	db.sql="select * from 
	#db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server 
	LEFT JOIN #db.table("site_x_deploy_server", request.zos.zcoreDatasource)# site_x_deploy_server 
	ON deploy_server.deploy_server_id = site_x_deploy_server.deploy_server_id and 
	site_x_deploy_server.site_id = #db.param(form.sid)#  and 
	site_x_deploy_server_deleted = #db.param(0)#
	WHERE 
	deploy_server_deleted = #db.param(0)#";
	var qDeploy=db.execute("qDeploy");
	writeoutput('
	<h2>Edit Site Deployment Configuration</h2>
	<form class="zFormCheckDirty" action="/z/server-manager/admin/deploy/saveSite" method="post">
	<input type="hidden" name="sid" value="#htmleditformat(form.sid)#" />
	<table class="table-list"><tr>
	<th>SSH Host</th>
	<th>Remote Host</th>
	<th>Local Site</th>
	<th>Remote Site</th>
	<th>Sync Type</th>
	</tr>');
	index=0;
	for(var row in qDeploy){
		index++;
		writeoutput('<tr class="table-white">
		<td>'&row.deploy_server_ssh_host&'</td>
		<td>#row.deploy_server_host#</td>
		<td>#replace(replace(application.zcore.functions.zvar("shortDomain", form.sid), "."&request.zos.testDomain, ""), "www.", "")#</td>'); 

		if(row.deploy_server_host EQ ""){

			echo(' 
			<td><input type="text" name="site_x_deploy_server_remote_site_id#index#" value="#row.site_x_deploy_server_remote_site_id#" style="min-width:100%; max-width:100%; width:100%;">
			<input type="hidden" name="site_x_deploy_server_remote_path#index#" value="">
				</td>');

		}else{
			if(row.deploy_server_secure EQ 1){
				link="https://"&row.deploy_server_host;
			}else{
				link="http://"&row.deploy_server_host;
			}
			link=link&"/z/server-manager/api/server/getConfig?zusername=#urlencodedformat(row.deploy_server_email)#&zpassword=#urlencodedformat(row.deploy_server_password)#"; 
			r1=application.zcore.functions.zDownloadLink(link, 30);
			if(not r1.success){ 
				writeoutput('<td colspan="2">Failed to download configuration.  <a href="/z/server-manager/admin/deploy-server/edit?deploy_server_id=#row.deploy_server_id#">Verify server configuration</a></td>');
			}else{ 
				// loop 
				try{
					dataStruct=deserializeJson(r1.cfhttp.filecontent); 
				}catch(Any excpt){
					savecontent variable="output"{
						writeoutput('Failed to execute deserializeJSON after calling <a href="#link#" target="_blank">#link#</a>.');
						writedump(r1);
						writedump(excpt);
					}
					throw(output);
				}
				arrLabel=[];
				arrValue=[];
				if(not structkeyexists(dataStruct, 'success')){
					writeoutput('<td colspan="2">API call returned invalid format.</td>');
				}else if(not dataStruct.success){
					writeoutput('<td colspan="2">API call returned error message: #dataStruct.errorMessage#</td>');
				}else{
					curDomain=replace(replace(application.zcore.functions.zvar('shortdomain', form.sid), '.'&request.zos.testDomain, ''), "www.", "");
					if(row.site_x_deploy_server_remote_site_id NEQ ""){
						form["site_x_deploy_server_remote_site_id#index#"]=row.site_x_deploy_server_remote_site_id;
					}else{
						form["site_x_deploy_server_remote_site_id#index#"]='';
					}
					for(i=1;i LTE arraylen(dataStruct.arrSite);i++){
						curSite=dataStruct.arrSite[i];
						if(form["site_x_deploy_server_remote_site_id#index#"] EQ '' and curDomain EQ curSite.shortDomain){
							form["site_x_deploy_server_remote_site_id#index#"]=curSite.id;
						}
						arrayAppend(arrLabel, curSite.shortDomain);
						arrayAppend(arrValue, curSite.id);
					}
					writeoutput('<td>');
					writeoutput('<input type="hidden" name="site_x_deploy_server_remote_path#index#" value="#htmleditformat(row.site_x_deploy_server_remote_path)#" />');
					
					ts = StructNew();
					ts.name = "site_x_deploy_server_remote_site_id#index#";
					ts.listLabels = arrayToList(arrLabel, chr(9));
					ts.listValues = arrayToList(arrValue, chr(9));
					ts.listLabelsDelimiter = chr(9); // tab delimiter
					ts.listValuesDelimiter = chr(9);
					ts.selectedValues=row.site_x_deploy_server_remote_site_id;
					application.zcore.functions.zInputSelectBox(ts);
					writeoutput('</td>');

				}
			}
		}
		echo('<td>');
		echo('<input type="hidden" name="deploy_server_id#index#" value="#htmleditformat(row.deploy_server_id)#" />');
		writeoutput('<input type="radio" name="site_x_deploy_server_source_only#index#" ');
		if(row.site_x_deploy_server_source_only EQ 1){
			echo('checked="checked"');
		}
		echo('value="1" /> Source Only 
		<input type="radio" name="site_x_deploy_server_source_only#index#" ');
		if(row.site_x_deploy_server_source_only EQ 0 or row.site_x_deploy_server_source_only EQ ''){
			echo('checked="checked"');
		}
		echo(' value="0" /> Source &amp; Files '); 
		echo('</tr>');
	}
	writeoutput('<tr><td colspan="5"><input type="submit" name="submit1" value="Save" /> 
	<input type="button" name="cancel" onclick="window.location.href=''/z/server-manager/admin/deploy/index?sid=#form.sid#'';" value="Cancel" />
	</td></tr>');
	writeoutput('</table>
	</form>');
	//<input type="submit" name="button" onclick="window.location.href='';" value="Deploy To All Servers" />
	</cfscript>
	
</cffunction>



<cffunction name="processDeployCore" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	if(not application.zcore.user.hasDeployAdminAccess(true)){
		echo("You don't have permission to use the deploy core feature.");
		abort;
	}
	db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	form.deploy_server_group=application.zcore.functions.zso(form, 'deploy_server_group');
	startTime=gettickcount();
	db.sql="select * from #db.table("deploy_server", request.zos.zcoredatasource)# 
	where deploy_server_deploy_enabled=#db.param(1)# and 
	deploy_server_group=#db.param(form.deploy_server_group)# and 
	deploy_server_deleted = #db.param(0)#";
	qDeploy=db.execute("qDeploy");
	if(qDeploy.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "No deployment servers are enabled. Create and enable a deploy server first.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/deploy/index?deploy_server_group=#form.deploy_server_group#&zsid=#request.zsid#");
	}
	setting requesttimeout="500";
	application.zcore.functions.zdeletefile(request.zos.sharedPath&'__zdeploy-core-complete.txt');
	if(structkeyexists(form, 'preview')){
		application.zcore.functions.zwritefile(request.zos.sharedPath&'__zdeploy-core-preview.txt', '1');
	}
	application.zcore.functions.zwritefile(request.zos.sharedPath&'__zdeploy-core-executed.txt', form.deploy_server_group);
	
	var start=gettickcount();
	failed=false;
	while(true){
		if((gettickcount()-start)/1000 GT 200){
			application.zcore.status.setStatus(request.zsid, "Deployment took longer then 200 seconds, and may still be running at #timeformat(now(), "h:mm:ss tt")#. Please verify that the site is working correct on the remote server(s) and clear any cached data that may need to be cleared.", form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/deploy/deployCore?deploy_server_group=#form.deploy_server_group#&zsid=#request.zsid#");
		}
		if(fileexists(request.zos.sharedPath&'__zdeploy-core-complete.txt')){
			application.zcore.functions.zdeletefile(request.zos.sharedPath&'__zdeploy-core-complete.txt');
			break;
		}else if(fileexists(request.zos.sharedPath&'__zdeploy-core-failed.txt')){
			e=application.zcore.functions.zReadFile(request.zos.sharedPath&'__zdeploy-core-failed.txt');
			application.zcore.status.setStatus(request.zsid, "Deployment failed: "&e, form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/deploy/deployCore?deploy_server_group=#form.deploy_server_group#&zsid=#request.zsid#");

			application.zcore.functions.zdeletefile(request.zos.sharedPath&'__zdeploy-core-failed.txt');
			failed=true;
			break;
		}
		sleep(100);
	}
	cacheReset=false;
	if(not failed and not structkeyexists(form, 'preview')){
		// later this needs to be non blocking so multiple servers update at once
		for(row in qDeploy){
			if(row.deploy_server_host EQ ""){
				continue;
			}
			if(row.deploy_server_secure EQ 1){
				adminDomain="https://"&row.deploy_server_host;
			}else{
				adminDomain="http://"&row.deploy_server_host;
			}
			adminDomain=adminDomain&"/z/server-manager/api/server/executeCacheReset?zusername=#urlencodedformat(row.deploy_server_email)#&zpassword=#urlencodedformat(row.deploy_server_password)#"; 
			// always clear all the source code
			if(form.clearcache EQ ""){
				link=adminDomain&"&reset=code";
			}else if(form.clearcache EQ "app"){
				link=adminDomain&"&reset=app";
			}else if(form.clearcache EQ "app,listing"){
				link=adminDomain&"&reset=app&zforcelisting=1";
			}else if(form.clearcache EQ "app,skin"){
				link=adminDomain&"&reset=app&zforce=1";
			}else if(form.clearcache EQ "all"){
				link=adminDomain&"&reset=all";
			}else if(form.clearcache EQ "all,skin"){
				link=adminDomain&"&reset=all&zforce=1";
			}
			r1=application.zcore.functions.zdownloadlink(link, 120);
			if(r1.success EQ false or r1.cfhttp.statuscode NEQ "200 OK"){
				savecontent variable="output"{
					if(structkeyexists(r1, 'cfhttp') and structkeyexists(r1.cfhttp, 'filecontent')){
						echo(r1.cfhttp.filecontent);
					}else{
						writedump(r1);
					}
				}
				throw("#request.zos.installPath#core/ synced, but failed to clear cache: #form.clearcache# for <a href=""#link#"">#link#</a>   at #timeformat(now(), "h:mm:ss tt")#.  You should manually verify the web sites on the target server are still working. Output: #output#");
			} 
			cacheReset=true;
		}
		application.zcore.status.setStatus(request.zsid, "#request.zos.installPath#core/ synced in #((gettickcount()-startTime)/1000)# seconds.  Completed at #timeformat(now(), "h:mm:ss tt")#. Please verify that the remote server(s) are working correctly.");
	
	}else{
		application.zcore.status.setStatus(request.zsid, "#request.zos.installPath#core/ preview changes completed.");
	}
	if(not cacheReset){
		application.zcore.status.setStatus(request.zsid, "Remote cache was not reset. You must do this manually.");
	}
	application.zcore.functions.zRedirect("/z/server-manager/admin/deploy/deployCore?deploy_server_group=#form.deploy_server_group#&zsid=#request.zsid#");
	</cfscript>
	
</cffunction>


<cffunction name="deployCore" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	if(not application.zcore.user.hasDeployAdminAccess(true)){
		echo("You don't have permission to use the deploy core feature.");
		abort;
	}
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	form.deploy_server_group =application.zcore.functions.zso(form, 'deploy_server_group');
	application.zcore.functions.zSetPageHelpId("8.4.5"); 
	if(request.zos.isTestServer EQ false){
		writeoutput('Deploy can''t be run on a production server since it is designed to deploy from the test server to the production server. 
			<a href="#request.zos.zcoreTestAdminDomain#/z/server-manager/admin/deploy/index">Go to test server deploy page</a>.');
		application.zcore.functions.zabort();
	}
	application.zcore.functions.zStatusHandler(request.zsid);

	db=request.zos.queryObject;
	db.sql="SELECT * 
	FROM #db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server WHERE 
	deploy_server_deleted = #db.param(0)#
	group by deploy_server_group 
	order by deploy_server_group asc ";
	qDeploy=db.execute("qDeploy");
	</cfscript>
	<p><a href="/z/server-manager/admin/deploy/index">Deploy</a> /</p>
	<h2>Deploy Core Application</h2>
	<p>Select the kind of cache to clear after deployment, and click "Submit".</p>
	<p>When changing the core, it is recommended to verify conventions before deploying.  This helps retain integration and compatibility.</p>

	<h3>
		<cfscript>
		offset=1;
		for(row in qDeploy){
			echo('<input type="radio" name="deploy_server_group" class="deployServerGroup" id="deploy_server_group#offset#" value="#htmleditformat(row.deploy_server_group)#" ');
			if((form.deploy_server_group EQ "" and offset EQ 1) or form.deploy_server_group EQ row.deploy_server_group){
				echo('checked="checked"');
			}
			echo('> <label for="deploy_server_group#offset#">#row.deploy_server_group#</label> ');
			offset++;
		}
		</cfscript>
	</h3>
	<hr>
	<p>Clear Cache:
		<input type="radio" class="clearCacheCoreDeploy" name="clearcache" value="" checked="checked" />
		Code
		<input type="radio" class="clearCacheCoreDeploy" name="clearcache" value="app" />
		App
		<input type="radio" class="clearCacheCoreDeploy" name="clearcache" value="app,skin" />
		App &amp; Skin
		<input type="radio" class="clearCacheCoreDeploy" name="clearcache" value="app,listing" />
		App &amp; Listing 	
		<input type="radio" name="clearcache" value="all" />
		All
		<input type="radio" name="clearcache" value="all,skin" />
		All &amp; Skin Cache Rebuild</p>

		<div id="pleaseWait" style="display:none;">Please wait up to 200 seconds...</div>
		<div id="deployLinkDiv" style="width:100%; float:left">
			<h2><a href="##" class="deployCoreButton z-manager-search-button">Deploy Core</a>
			&nbsp;&nbsp;&nbsp;
			<a href="##" class="previewDeployCoreButton z-manager-search-button">Preview Changes</a>
			&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/tasks/verify-conventions/index" target="_blank" class="z-manager-search-button">Verify Conventions</a>
			</h2>
		</div>
		<cfscript>
		filePath=request.zos.sharedPath&"__zdeploy-core-changes.txt";
		if(fileexists(filePath)){
			curDate=application.zcore.functions.zGetFileAttrib(filePath).datelastmodified;
			echo('<h2>Itemized Changes (updated #dateformat(curDate, "m/d/yyyy")&" at "&timeformat(curDate, "h:mm:ss tt")#)</h2>
				<p>Note: If you see host key authentication error the first time using this on a new server, you may need to run the command once as root via ssh to accept the server''s key.</p>
			<textarea name="changes" cols="100" row="20" style="width:95% !important; height:200px;">'&application.zcore.functions.zreadfile(filePath)&'</textarea>');
		}
		</cfscript>
		<script type="text/javascript">
		zArrDeferredFunctions.push(function(){
			$(".deployCoreButton").on("click", function(e){
				e.preventDefault();
				document.getElementById('deployLinkDiv').style.display='none';
				document.getElementById('pleaseWait').style.display='block'; 
				group="";
				$(".deployServerGroup").each(function(){
					if(this.checked){
						group=this.value;
					}
				});
				window.location.href='/z/server-manager/admin/deploy/processDeployCore?clearcache='+$('.clearCacheCoreDeploy:checked').val()+'&deploy_server_group='+escape(group); 
			});
			$(".previewDeployCoreButton").on("click", function(e){
				e.preventDefault();
				document.getElementById('deployLinkDiv').style.display='none';
				document.getElementById('pleaseWait').style.display='block'; 
				group="";
				$(".deployServerGroup").each(function(){
					if(this.checked){
						group=this.value;
					}
				});
				window.location.href='/z/server-manager/admin/deploy/processDeployCore?preview=1&clearcache='+$('.clearCacheCoreDeploy:checked').val()+'&deploy_server_group='+escape(group); 

			});
		});
		</script>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
 
	if(form.sid EQ ""){
		application.zcore.functions.zSetPageHelpId("8.4");
	}else{
		application.zcore.functions.zSetPageHelpId("8.1.1.3");
	}
	form.deploy_server_group =application.zcore.functions.zso(form, 'deploy_server_group');
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	if(not request.zos.isTestServer){
		writeoutput('Deploy can''t be run on a production server since it is designed to deploy from the test server to the production server. 
			<a href="#request.zos.zcoreTestAdminDomain#/z/server-manager/admin/deploy/index">Go to test server deploy page</a>');
		application.zcore.functions.zabort();
	}
	application.zcore.functions.zStatusHandler(request.zsid);
	if(form.sid NEQ "" and not structkeyexists(application.siteStruct, form.sid)){

		db.sql="select * from #db.table("site", request.zos.zcoreDatasource)#
		WHERE site_id=#db.param(form.sid)# and 
		site_active=#db.param(1)# and 
		site_deleted = #db.param(0)#"; 
		qSite=db.execute("qSite");
		if(qSite.recordcount EQ 0){
			throw("Invalid site_id");
		}
		application.zcore.functions.zredirect(qSite.site_domain&"/z/server-manager/admin/deploy/index?sid=#form.sid#"); 
	}
	</cfscript>
		<h2>Deploy Site</h2>  
		<div style="font-size:120%; line-height:1.3;  width:100%; float:left;">
	<cfif application.zcore.functions.zso(form, 'sid') NEQ ""> 
			<p id="deployStatusId" class="deployStatusId" style="display:none;">Please wait while the deploy process executes. (This could take a while if the changed files were large.)</p>
		<cfscript>
		db.sql="select * from 
		#db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server, 
		#db.table("site_x_deploy_server", request.zos.zcoreDatasource)# site_x_deploy_server 
		WHERE deploy_server.deploy_server_id = site_x_deploy_server.deploy_server_id and 
		site_x_deploy_server.site_id = #db.param(form.sid)#  and 
		deploy_server_deleted = #db.param(0)# and 
		site_x_deploy_server_deleted = #db.param(0)# 
		GROUP BY deploy_server_group, site_x_deploy_server_id 
		ORDER BY deploy_server_group ASC";
		var qDeploy=db.execute("qDeploy");
		</cfscript>
   
		<!--- <cfif request.zos.isTestServer>
			<h3>Current Server: Test Server</h3>
		<cfelse>
			<h3>Current Server: Live Server</h3>
		</cfif> --->
		<cfscript> 
		if(qDeploy.recordcount EQ 0){
			echo('<p>No servers have been configured for this site.</p>');
		}
		echo('<div class="z-float">');
		for(row in qDeploy){
			echo('<table class="table-list z-mr-10 z-mb-10" style="float:left;">'); 
			if(row.site_id NEQ ""){
				echo("
				<tr>
				<th>Group</th> 
				<td>#row.deploy_server_group#</td>
				</tr>
				<tr>
				<th>Local Site</th> 
				<td>#application.zcore.functions.zvar("shortDomain", form.sid)#</td>
				</tr>
				<tr>
				<th>Remote Site</th>
				<td>");
				allowDeploy=true;
				if(row.deploy_server_host EQ ""){
					echo(application.zcore.functions.zvar("shortDomain", form.sid));
				}else{
					rs=variables.getSiteJson(row);
					if(rs.success){
						echo(rs.dataStruct.shortDomain);
					}else{
						allowDeploy=false;
						echo(rs.errorMessage);
					}
				}
				echo('</td></tr>');

				if(allowDeploy and application.zcore.user.hasDeployAdminAccess(false)){
					echo('<tr><th>&nbsp;</th><td><span id="deployButtonsId" class="deployButtonsId"><a href="/z/server-manager/admin/deploy/deploySite?deploy_server_group=#urlencodedformat(row.deploy_server_group)#&sid=#form.sid#" onclick="$(''.deployButtonsId'').hide();$(''.deployStatusId'').show();" class="z-manager-search-button">Deploy</a> <a href="/z/server-manager/admin/deploy/deploySite?deploy_server_group=#urlencodedformat(row.deploy_server_group)#&sid=#form.sid#&amp;preview=1" onclick="$(''.deployButtonsId'').hide();$(''.deployStatusId'').show();" class="z-manager-search-button">Preview Changes</a></span></td></tr>');
				}
			}
			echo ('</table> ');
		}
		echo('</div>');

		filePath=application.zcore.functions.zGetDomainWritableInstallPath(application.zcore.functions.zvar('shortDomain', form.sid))&"__zdeploy-changes.txt";
		if(fileexists(filePath)){
			curDate=application.zcore.functions.zGetFileAttrib(filePath).datelastmodified;
			echo('<h3>Itemized Changes (updated #dateformat(curDate, "m/d/yyyy")&" at "&timeformat(curDate, "h:mm:ss tt")#)</h3>
				<p>Note: If you see host key authentication error the first time using this on a new server, you may need to run the command once as root via ssh to accept the server''s key.</p>
			<textarea name="changes" cols="100" row="20" style="width:95% !important; height:200px;">'&application.zcore.functions.zreadfile(filePath)&'</textarea>');
		}
		</cfscript>
		
		<p><a href="/z/server-manager/admin/deploy/editSite?sid=#form.sid#" class="z-manager-search-button">Edit Site Deployment Configuration</a> 
			<cfif application.zcore.user.hasDeployAdminAccess(true)>
				<a href="/z/server-manager/admin/deploy/editAllSites" class="z-manager-search-button">Edit All Sites At Once</a> 
				<a href="/z/server-manager/tasks/verify-conventions/verifySiteConventions?sid=#form.sid#" target="_blank" class="z-manager-search-button">Verify Conventions</a> 
				<a href="/z/server-manager/admin/compress-images/compressSiteHomedirImages?sid=#form.sid#" target="_blank" class="z-manager-search-button">Compress Homedir Images</a>
			</cfif>
			</p> 
		<p>Configure excluded directories and files for this site on the <a href="/z/server-manager/admin/site/edit?sid=#form.sid#">globals</a> page.</p>
	<cfelse> 
		<cfif application.zcore.user.hasDeployAdminAccess(true)>
			<p><a href="/z/server-manager/admin/deploy-server/index">Manage Deploy Server(s)</a></p>
			<p><a href="/z/server-manager/admin/deploy/editAllSites">Edit Deployment Configuration For All Sites</a></p>
			<!--- <p><a href="/z/server-manager/admin/deploy/deployAllSites">Deploy All Sites</a></p> --->
			<p><a href="/z/server-manager/admin/deploy/deployCore">Deploy Core</a></p> 
		</cfif>
		<p>For site deployment, <a href="/z/server-manager/admin/site-select/index?sid=">select a site</a> and click deploy</p>
		<!--- <cfif not request.zos.isExecuteEnabled or not request.zos.cfmlAdminWriteEnabled or not request.zos.cfmlAdminReadEnabled>
			<p>Deploy Sourceless Archive: Disabled | This feature requires request.zos.isExecuteEnabled, request.zos.cfmlAdminWriteEnabled  and request.zos.cfmlAdminReadEnabled to be set to true in Application.cfc.</p>
		<cfelse>
			<p><a href="/z/server-manager/tasks/deploy-archive/index">Deploy Sourceless Archive</a></p>
		</cfif>
		<p><strong>About Deploy Sourceless Archive:</strong> If you choose to deploy via an source-less archive, the cfml server will have to compile and upload all the source code as a zip file which can be slower then <a href="/z/server-manager/admin/deploy/deployCore">Deploy #request.zos.installPath#core/</a> which relies on rsync to send only the source code that has changed.  An archive also causes the cfml server to run out of perm gen memory faster on the target server since more class files are replaced (This was true before the cfml server ran on OSGi class loaders at least even with java agent enabled).  Why use a sourceless archive? It can be more secure since your code doesn't exist as plain text on the target server.</p>  --->
	</cfif> 
	</div>
</cffunction>

</cfoutput>
</cfcomponent>