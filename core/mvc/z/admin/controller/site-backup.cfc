<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true); 
	application.zcore.template.setTag("pagetitle", "Site Backup");
	</cfscript>
	<cfscript>
	curDomain=replace(replace(request.zos.globals.shortDomain, 'www.', ''), "."&request.zos.testDomain, "");
	if(fileexists("#request.zos.backupDirectory#site-archives/#curDomain#-zupload.7z")){
		totalSize=application.zcore.functions.zGetDiskUsage("#request.zos.backupDirectory#site-archives/#curDomain#-zupload.7z")&" | compressed";
		directory action="list" directory="#request.zos.backupDirectory#site-archives/" filter="#curDomain#-zupload.7z" name="qDir";
		totalSize&=" backup made on "&dateformat(qDir.dateLastModified, "yyyy-mm-dd")&" at "&timeformat(qDir.dateLastModified, "HH:mm:ss");
	}else{
		totalSize=application.zcore.functions.zGetDiskUsage("#application.zcore.functions.zGetDomainWritableInstallPath(request.zos.globals.shortDomain)#/zupload/")&" | not compressed yet";
	}
	</cfscript>
	<form class="zFormCheckDirty" name="editForm" action="/z/admin/site-backup/process" method="get" target="_blank" style="margin:0px;" id="zFormUniqueId1"> 
		<table style="width:100%; border-spacing:0px;" class="table-list"> 
		<tbody><tr>
		<td class="table-list" style="vertical-align:top; width:150px;">Backup Type</td>
		<td class="table-white">
		<input type="radio" name="backupIncludeType" id="backupIncludeType1" value="filesAndDatabase" checked="checked"> <label for="backupIncludeType1">Files &amp; Database</label>
		<input type="radio" name="backupIncludeType" id="backupIncludeType2" value="database"> <label for="backupIncludeType2">Database</label>
		</td>
		</tr>
		<tr>
		<td class="table-list" style="vertical-align:top; width:150px;">Backup Type:</td>
		<td class="table-white">
		<input type="radio" name="backupType" value="1" checked="checked"> Site Database &amp; Source (No backup exists yet.)<br>
		<input type="radio" name="backupType" value="2"> Site Uploads (#totalSize#)<br> 
		</td>
		</tr>
		<tr>
		<td class="table-list" style="width:70px;">&nbsp;</td>
		<td class="table-white">
		<input type="submit" name="submitAction" value="Download">
		</td>
		</tr>
		</tbody></table>
	</form>
</cffunction>

<cffunction name="process" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true); 
	form.sid=request.zos.globals.id;
	form.backupIncludeType=application.zcore.functions.zso(form, 'backupIncludeType');
	form.backupType=application.zcore.functions.zso(form, 'backupType');
	if(form.backupType NEQ 1 and form.backupType NEQ 2){
		echo("Permission denied");
		abort;
	} 

	siteBackupCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.download-site-backup");
	siteBackupCom.download();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
