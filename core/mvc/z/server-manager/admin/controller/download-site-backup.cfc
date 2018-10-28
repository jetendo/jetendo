<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="serveradministrator">
	<cfscript> 
	if(structkeyexists(form, 'zid') EQ false){
		form.zid = application.zcore.status.getNewId();
		if(structkeyexists(form, 'sid')){
			application.zcore.status.setField(form.zid, 'site_id', form.sid);
		}
	}
	form.sid = application.zcore.status.getField(form.zid, 'site_id');
	</cfscript>
</cffunction>

<cffunction name="download" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)# and 
	site_deleted=#db.param(0)#";
	qSite=db.execute("qSite");

	form.backupType=application.zcore.functions.zso(form, 'backupType');
	if(qSite.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid Site Selection");
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	if(not application.zcore.user.checkAllCompanyAccess()){ 
		if(qSite.company_id NEQ request.zsession.user.company_id){
			application.zcore.status.setStatus(request.zsid, "Access denied to download a backup of this site.", form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/download-site-backup/index?sid=#form.sid#&zsid=#request.zsid#");
		}
		if(form.backupType EQ 3){
			application.zcore.status.setStatus(request.zsid, "Access denied to download the global backup.", form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/download-site-backup/index?sid=#form.sid#&zsid=#request.zsid#");
		}
	}
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	var siteBackupCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.site-backup");
	siteBackupCom.index();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	setting requesttimeout="500";
	var qSite=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.init();
	application.zcore.functions.zSetPageHelpId("8.1.1.5");
	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)# and 
	site_deleted=#db.param(0)#";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid Site Selection");
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	if(not application.zcore.user.checkAllCompanyAccess()){ 
		if(qSite.company_id NEQ request.zsession.user.company_id){
			application.zcore.status.setStatus(request.zsid, "Access denied to this site.", form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
		}
	}
	application.zcore.functions.zStatusHandler(Request.zsid,true);
	</cfscript>
	<h2>Site Backup: #qsite.site_domain#</h2>
	<cfif request.zos.isTestServer>
		<h2>Current Server: Test Server</h2>
	<cfelse>
		<h2>Current Server: Live Server</h2>
	</cfif>
	<form class="zFormCheckDirty" name="editForm" action="/z/server-manager/admin/download-site-backup/download" method="get" target="_blank" style="margin:0px;">
		<input type="hidden" name="sid" id="sidHiddenField" value="#form.sid#" />
		<table style="width:100%; border-spacing:0px;" class="table-list"> 
			<!--- <tr>
				<td class="table-list" style="vertical-align:top; width:150px;">Create new backup?</td>
				<td class="table-white"><input type="checkbox" name="createNew" value="1" /></td>
			</tr> --->
			<tr>
				<td class="table-list" style="vertical-align:top; width:150px;">Backup Type</td>
				<td class="table-white">
					<input type="radio" name="backupIncludeType" id="backupIncludeType1" value="filesAndDatabase" checked="checked" /> <label for="backupIncludeType1">Files &amp; Database</label>
					<input type="radio" name="backupIncludeType" id="backupIncludeType2" value="database" /> <label for="backupIncludeType2">Database</label>
				</td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:150px;">Backup Type:</td>
				<td class="table-white">
				<cfscript>
				curDomain=replace(replace(qsite.site_short_domain, 'www.', ''), "."&request.zos.testDomain, "");
				if(fileexists("#request.zos.backupDirectory#site-archives/#curDomain#.tar")){
					totalSize=application.zcore.functions.zGetDiskUsage("#request.zos.backupDirectory#site-archives/#curDomain#.tar")&" | compressed";
					directory action="list" directory="#request.zos.backupDirectory#site-archives/" filter="#curDomain#.tar" name="qDir";
					totalSize&=" backup made on "&dateformat(qDir.dateLastModified, "yyyy-mm-dd")&" at "&timeformat(qDir.dateLastModified, "HH:mm:ss");
				}else{
					totalSize="No backup exists yet.";
				}
				</cfscript>
				<input type="radio" name="backupType" value="1" checked="checked" /> Site Database &amp; Source (#totalSize#)<br />
				<cfscript>
				if(fileexists("#request.zos.backupDirectory#site-archives/#curDomain#-zupload.7z")){
					totalSize=application.zcore.functions.zGetDiskUsage("#request.zos.backupDirectory#site-archives/#curDomain#-zupload.7z")&" | compressed";
					directory action="list" directory="#request.zos.backupDirectory#site-archives/" filter="#curDomain#-zupload.7z" name="qDir";
					totalSize&=" backup made on "&dateformat(qDir.dateLastModified, "yyyy-mm-dd")&" at "&timeformat(qDir.dateLastModified, "HH:mm:ss");
				}else{
					totalSize=application.zcore.functions.zGetDiskUsage("#application.zcore.functions.zGetDomainWritableInstallPath(qsite.site_short_domain)#/zupload/")&" | not compressed yet";
				}
				</cfscript>
				<input type="radio" name="backupType" value="2" /> Site Uploads (#totalSize#)<br />
				<cfscript>
				if(fileexists("#request.zos.backupDirectory#global-database.tar")){
					totalSize=application.zcore.functions.zGetDiskUsage("#request.zos.backupDirectory#global-database.tar")&" | compressed";
					directory action="list" directory="#request.zos.backupDirectory#" filter="global-database.tar" name="qDir";
					totalSize&=" backup made on "&dateformat(qDir.dateLastModified, "yyyy-mm-dd")&" at "&timeformat(qDir.dateLastModified, "HH:mm:ss");
				}else{
					totalSize="backup doesn't exist yet.";
				}
				</cfscript>
				<cfif application.zcore.user.checkAllCompanyAccess()>
					<input type="radio" name="backupType" value="3" /> Global Database (#totalSize# | Contains all non-site specific data)<br />
				</cfif>
				</td>
			</tr>
			<tr>
				<td class="table-list" style="width:70px;">&nbsp;</td>
				<td class="table-white">
				<input type="submit" name="submitAction" value="Download" />
				</td>
			</tr>
		</table>	
	</form>
</cffunction>
</cfoutput>
</cfcomponent>