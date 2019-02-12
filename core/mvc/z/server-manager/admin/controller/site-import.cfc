<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public">
	<cfscript> 
	if(not application.zcore.user.hasSourceAdminAccess()){
		echo("You don't have permission to use the import site feature.");
		abort;
	}
	</cfscript>
</cffunction>
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var selectStruct=0;
	init();
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.1.2");
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	
	<form id="siteImportForm" action="/z/server-manager/admin/site-import/process" method="post" enctype="multipart/form-data">
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<td colspan="2" style="padding:10px; padding-bottom:0px;"><span class="large"><h2>Site Import</h2></span>
				</td>
			</tr>
			<tr>
				<td colspan="2" style="padding-left:10px;">

				<cfif request.zos.isTestServer>
					<h2>Current Server: Test Server</h2>
				<cfelse>
					<h2>Current Server: Live Server</h2>
				</cfif>
				<!--- <p>Choosing an existing site or click "Add Site" to create one.  The site id columns will be automatically updated as needed.</p> --->
				<h2>WARNINGS - Be sure to have a backup!</h2>
				<ul>
					<li>Make sure you have made backups before updating an existing site.</li>
					<li>If lead reminders are enabled, they will be disabled.</li> 
				</ul>
				<!--- <p>If you are adding a new site, it won't work immediately after import.  You'll need to click on globals and then click save to make the site active.</p> --->
			</td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">Site Tar File:</td>
				<td class="table-white"><input type="file" name="tarFile" /><br>
				(Required | This file must be generated by a Site Backup task in the Jetendo Server Manager).
				</td>
			</tr>
			<!---
			process untar function not implemented yet.
			 <tr>
				<td class="table-list" style="vertical-align:top; width:140px;">Site Uploads Tar File:</td>
				<td class="table-white"><input type="file" name="theUploadFile" /> (Optional | A simple 7-zip file contain the files in /zupload directory.  If not specified, an existing zupload folder will be retained.)
				</td>
			</tr> --->
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">Select IP Address: </td>
				<td class="table-white">
				<cfscript>
				ipStruct=application.zcore.functions.getSystemIpStruct();

				if(application.zcore.functions.zso(form,'ipAddress') EQ ""){
					form.ipAddress=ipStruct.defaultIp;
				}
				ipStruct2={};
				if(structkeyexists(request.zos, 'arrAdditionalLocalIp')){
					for(i=1;i LTE arraylen(request.zos.arrAdditionalLocalIp);i++){
						ipStruct2[request.zos.arrAdditionalLocalIp[i]]=true;
					}
				}
				for(i=1;i LTE arraylen(ipStruct.arrIp);i++){
					ipStruct2[ipStruct.arrIp[i]]=true;
				}
				arrIp=structkeyarray(ipStruct2);
				arraySort(arrIp, "text", "asc");
				selectStruct = StructNew();
				selectStruct.name = "ipAddress";
				selectStruct.listvalues=arraytolist(arrIp,",");
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
				</td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">Select Parent Site: </td>
				<td class="table-white">
				<cfscript>
				if(structkeyexists(cookie, 'sidParent')){
					form.sidParent=cookie.sidParent;
				}
				db.sql="SELECT site_id, replace(replace(site_short_domain, #db.param('.#request.zos.testDomain#')#, #db.param('')#), 
					#db.param('www.')#, #db.param('')#) site_short_domain 
				FROM #db.table("site", request.zos.zcoreDatasource)# site 
				WHERE site_id <> #db.param(-1)# and 
				site_active=#db.param(1)# and
				site_deleted = #db.param(0)#
				ORDER BY site_short_domain ASC";
				qSites=db.execute("qSites", "", 10000, "query", false);
				selectStruct = StructNew();
				selectStruct.name = "sidParent";
				selectStruct.query = qSites;
				selectStruct.queryLabelField = "site_short_domain";
				selectStruct.queryValueField = "site_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript> (Leave unselected if this site is not connected to another site).
				</td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">Import Type:</td>
				<td class="table-white">
				<input type="radio" name="importType" value="update" checked="checked" /> Update Existing Site 
				<!--- 
				disabled because it is easier for things to go wrong with add site.
				<input type="radio" name="importType" value="insert" /> Add New Site --->
				</td>
			</tr>
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">Overwrite Site:</td>
				<td class="table-white">
				<cfscript>
				selectStruct = StructNew();
				selectStruct.name = "sid";
				selectStruct.query = qSites;
				selectStruct.queryLabelField = "site_short_domain";
				selectStruct.queryValueField = "site_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript> (Only applies when you select "Update Existing Site" above)
				</td>
			</tr>
			<cfif not request.zos.istestserver>
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">Linux Username:</td>
				<td class="table-white"><input type="text" name="linuxUser" value="" /> (Optional, only needed when there is a conflict with existing user)
				</td>
			</tr>
			</cfif>
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">&nbsp;</td>
				<td class="table-white">
					<p><input type="checkbox" name="ignoreDBErrors" value="1" /> <label for="ignoreDBErrors">Ignore Database Structure Errors?</label></p>
					
				</td>
			</tr>
			<!--- <tr>
				<td class="table-list" style="vertical-align:top; width:140px;">Backup Site Before Import?</td>
				<td class="table-white"><input type="checkbox" name="backupSite" value="1" />
				</td>
			</tr> --->
			<tr>
				<td class="table-list" style="vertical-align:top; width:140px;">&nbsp;</td>
				<td class="table-white">
				<input type="button" name="submit1" value="Import Site" onclick="var r=window.confirm('Double check the form. This operation will replace the source code and database for the selected site. Do you want to continue with the import?'); if(r){ document.getElementById('siteImportForm').submit(); }  " />
				</td>
			</tr>
		</table>
		
	</form>
</cffunction>
	

<cffunction name="writeLogEntry" localmode="modern" access="private" roles="serveradministrator">
	<cfargument name="message" type="string" required="yes">
	<cfscript>
	application.zcore.functions.zcreatedirectory(request.zos.backupDirectory&"import/");
	f=fileopen(request.zos.backupDirectory&"import/site-import.txt", "append", "utf-8");
	filewriteline(f, arguments.message);
	fileclose(f);
	</cfscript>
</cffunction>


<cffunction name="process" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var dbNoVerify=request.zos.noVerifyQueryObject; 
	var debug=false;
	init();
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	setting requesttimeout="3600";
	form.sid=application.zcore.functions.zso(form, 'sid');
	form.ipAddress=application.zcore.functions.zso(form, 'ipAddress');
	form.importType=application.zcore.functions.zso(form, 'importType');
	form.sidParent=application.zcore.functions.zso(form, 'sidParent');
	form.ignoreDBErrors=application.zcore.functions.zso(form,'ignoreDBErrors', false, false);
	form.forceReturnJson=application.zcore.functions.zso(form, 'forceReturnJson', false, false);
	//debug=true;


	ts={};
	ts.name="sidParent";
	ts.value=form.sidParent;
	ts.expires="never";
	application.zcore.functions.zCookie(ts); 

	if(form.importType EQ ""){
		message="Import type is required.";
		if(form.forceReturnJson){
			return {success:false, errorMessage:message};
		}else{
			application.zcore.status.setStatus(request.zsid, message, form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
		}
	}
	
	application.zcore.functions.zCreateDirectory(request.zos.backupDirectory&"import/");
	curDate=dateformat(now(), "yyyymmdd")&"-"&timeformat(now(),"HHmmss");
	writeLogEntry("---------------#chr(10)#Begin import: "&curDate);
	curImportPath=request.zos.backupDirectory&"import/"&curDate&"/";
	curMYSQLImportPath=request.zos.mysqlBackupDirectory&"import/"&curDate&"/";
	
	// create new directories
	application.zcore.functions.zCreateDirectory(curImportPath);
	application.zcore.functions.zCreateDirectory(curImportPath&"upload/");
	application.zcore.functions.zCreateDirectory(curImportPath&"temp/");
	
	
	writeLogEntry("Upload tarFile");
	if(form.forceReturnJson){
		fileName=getFileFromPath(form.tarFile);
		application.zcore.functions.zRenameFile(form.tarFile, curImportPath&"upload/"&fileName);
		filePath=fileName;
		lastClientFile=fileName;
	}else{
		filePath=application.zcore.functions.zUploadFile("tarFile", "#curImportPath#upload/");
		if(filePath EQ false){
			application.zcore.functions.zdeletedirectory(curImportPath);
			message="The site backup file failed to upload. Please try again";
			if(form.forceReturnJson){
				return {success:false, errorMessage:message};
			}else{
				application.zcore.status.setStatus(request.zsid, message, form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
			}
		}
		lastClientFile=request.zos.lastCFFileResult.clientfile;
	}
	fileName=filePath;
	filePath="#curImportPath#upload/"&filePath; 
	fileUploadName="";
	if(right(lastClientFile, 7) NEQ ".tar.gz"){
		application.zcore.functions.zdeletedirectory(curImportPath);
		message="A site backup file must end with "".tar.gz"", current filename was ""#filePath#"".  Only files generated by the site backup task are compatible with site import.  Don't try to package your own backup file.";
		if(form.forceReturnJson){
			return {success:false, errorMessage:message};
		}else{
			application.zcore.status.setStatus(request.zsid, message, form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
		}
	}
	writeLogEntry("untarZipSiteImportPath: "&fileName);
	result=application.zcore.functions.zSecureCommand("untarZipSiteImportPath"&chr(9)&fileName&chr(9)&curDate, 3600);
	writeLogEntry("untarZipSiteImportPath result: "&result);
	/*if(structkeyexists(form, 'theUploadFile') and form.theUploadFile NEQ ""){
		fileUploadPath=application.zcore.functions.zUploadFile("theUploadFile", "#curImportPath#upload/");
		if(fileUploadPath EQ false){
			application.zcore.functions.zdeletedirectory(curImportPath);
			message="The site uploads backup file failed to upload. Please try again";
			if(form.forceReturnJson){
				return {success:false, errorMessage:message};
			}else{
				application.zcore.status.setStatus(request.zsid, message, form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
			}
		}
		fileUploadName=fileUploadPath;
		fileUploadPath="#curImportPath#upload/"&fileUploadPath;
		writeLogEntry("Uploaded theUploadFile: "&fileUploadPath);
		if(right(request.zos.lastCFFileResult.clientfile, 7) NEQ ".tar.gz"){
			application.zcore.functions.zdeletedirectory(curImportPath);
			message="A site upload backup file must end with "".tar.gz"", current filename was ""#filePath#"".  Only files generated by the site backup task are compatible with site import.  Don't try to package your own backup file.";
			if(form.forceReturnJson){
				return {success:false, errorMessage:message};
			}else{
				application.zcore.status.setStatus(request.zsid, message, form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
			}
		}
		application.zcore.functions.zSecureCommand("untarZipSiteUploadPath"&chr(9)&fileUploadName&chr(9)&curDate, 3600);
	}*/

	
	globals=deserializeJson(application.zcore.functions.zreadfile(curImportPath&"temp/globals.json"));

	if(form.sid NEQ "" and form.importType EQ "update"){
		db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(form.sid)# and 
		site_deleted=#db.param(0)# ";
		qSite=db.execute("qSite");
		for(row in qSite){
			globals.site_domain=row.site_domain;
			globals.site_id=row.site_id;
			globals.site_securedomain=row.site_securedomain;
			globals.site_short_domain=row.site_short_domain;
			globals.site_domain=row.site_domain;
			globals.site_sitename=row.site_sitename;
			globals.site_domainaliases=row.site_domainaliases;
			globals.site_admin_email=row.site_admin_email;
			globals.site_email_campaign_from=row.site_email_campaign_from;
		}
	}

	// update the globals
	ts=structnew();
	ts.struct=globals;
	ts.struct.site_active=1;
	ts.struct.site_ip_address=form.ipAddress;
	if(request.zos.isTestServer){
		ts.struct.site_live=0;
		ts.struct.site_require_login=0;
		if(ts.struct.site_domain DOES NOT CONTAIN "."&request.zos.testDomain){
			ts.struct.site_domain=replace(ts.struct.site_domain&"."&request.zos.testDomain, "https://", "http://");
		}
		if(ts.struct.site_securedomain NEQ "" and ts.struct.site_securedomain DOES NOT CONTAIN "."&request.zos.testDomain){
			ts.struct.site_securedomain=replace(ts.struct.site_securedomain&"."&request.zos.testDomain, "https://", "http://");
		}
		if(ts.struct.site_short_domain DOES NOT CONTAIN "."&request.zos.testDomain){
			ts.struct.site_short_domain=replace(ts.struct.site_short_domain&"."&request.zos.testDomain, "https://", "http://");
		}
		ts.struct.site_username='';
		ts.struct.site_password='';
		ts.struct.site_admin_email=request.zOS.developerEmailTo;
		ts.struct.site_email_campaign_from=request.zOS.developerEmailTo;

		
	}else{
		if(ts.struct.site_domain CONTAINS "."&request.zos.testDomain){
			ts.struct.site_domain=replace(ts.struct.site_domain, "."&request.zos.testDomain, "");
		}
		if(ts.struct.site_securedomain NEQ "" and ts.struct.site_securedomain CONTAINS "."&request.zos.testDomain){
			ts.struct.site_securedomain=replace(ts.struct.site_securedomain, "."&request.zos.testDomain, "");
		}
		if(ts.struct.site_short_domain CONTAINS "."&request.zos.testDomain){
			ts.struct.site_short_domain=replace(ts.struct.site_short_domain, "."&request.zos.testDomain, "");
		}
		if(application.zcore.functions.zso(form, 'linuxUser', false,'') NEQ ""){
			ts.struct.site_username=form.linuxUser;
		}
		if(application.zcore.functions.zso(form, 'linuxPassword', false,'') NEQ ""){
			ts.struct.site_password=form.linuxPassword;
		}
	}  
	installPath=application.zcore.functions.zGetDomainInstallPath(globals.site_short_domain);
	installWritablePath=application.zcore.functions.zGetDomainWritableInstallPath(globals.site_short_domain);

	domainPath=replace(installPath, request.zos.sitesPath, "");
	domainPath=left(domainPath, len(domainPath)-1);

	if(form.sidParent NEQ ""){
		ts.struct.site_parent_id=form.sidParent;
	}else{
		// force parent site to be removed for enhanced security
		ts.struct.site_parent_id=0;
	}
	ts.table="site";
	ts.datasource=request.zos.zcoredatasource;
	if(form.importType EQ "update"){
		if(form.sid NEQ ""){
			ts.struct.site_id=form.sid;
		}
		db.sql="select * from #db.table("site", request.zos.zcoreDatasource)#
		where site_id =#db.param(ts.struct.site_id)# and 
		site_deleted=#db.param(0)#  ";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.functions.zdeletedirectory(curImportPath);
			message="Domain, #globals.site_short_domain#, doesn't exist in site table yet.  Please import with the ""Add Site"" option or select an existing site from the drop down menu.";
			if(form.forceReturnJson){
				return {success:false, errorMessage:message};
			}else{
				application.zcore.status.setStatus(request.zsid, message, form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
			}
		}
		if(not directoryexists(installPath)){
			application.zcore.functions.zdeletedirectory(curImportPath);
			message="Domain doesn't exist on the file system, but it is in the site table.  Please run the ""Verify Sites"" task from the Jetendo CMS Server Manager to repair the installation.";
			if(form.forceReturnJson){
				return {success:false, errorMessage:message};
			}else{
				application.zcore.status.setStatus(request.zsid, message, form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
			}
		}
	}else if(form.importType EQ "insert"){
		// verify domain doesn't exist in site table or on filesystem
		db.sql="select * from #db.table("site", request.zos.zcoreDatasource)#
		where site_short_domain = #db.param(globals.site_short_domain)# and 
		site_deleted = #db.param(0)# and 
		site_id <> #db.param(-1)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount NEQ 0){
			application.zcore.functions.zdeletedirectory(curImportPath);
			message="Domain already exists in site table.  You must delete the existing domain and files before importing.";
			if(form.forceReturnJson){
				return {success:false, errorMessage:message};
			}else{
				application.zcore.status.setStatus(request.zsid, message, form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
			}
		}
		if(not request.zos.istestserver){
			if(globals.site_username NEQ ""){
				// linux user must be unique
				db.sql="select * from #db.table("site", request.zos.zcoreDatasource)#
				where site_username = #db.param(globals.site_username)# and 
				site_deleted = #db.param(0)# and 
				site_id <> #db.param(-1)#";
				qCheck=db.execute("qCheck");
				if(qCheck.recordcount NEQ 0){
					application.zcore.functions.zdeletedirectory(curImportPath);
					message="Linux user, #globals.site_username#, already exists for domain, #qCheck.site_short_domain#.  You must specify a different linux user before importing again.";
					if(form.forceReturnJson){
						return {success:false, errorMessage:message};
					}else{
						application.zcore.status.setStatus(request.zsid, message, form, true);
						application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
					}
				}
			}
		}
		if(directoryexists(installPath) or directoryexists(installWritablePath)){
			application.zcore.functions.zdeletedirectory(curImportPath);
			message="";
			if(directoryexists(installPath)){
				message&="Domain already exists on file system: #installPath#<br>";
			}
			if(directoryexists(installWritablePath)){
				message&="Domain already exists on file system: #installWritablePath#"
			}
			if(form.forceReturnJson){
				return {success:false, errorMessage:message};
			}else{
				if(message NEQ ""){
					application.zcore.status.setStatus(request.zsid, message, form, true);
				}
				application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
			}
		}
		
	}else{
		application.zcore.functions.z404("Invalid request");
	}
	
	// process database restore
	restoreData=application.zcore.functions.zreadfile(curImportPath&"temp/restore-site-database.sql");
	arrRestore=listToArray(replace(restoreData, "/ZIMPORTPATH/", curMYSQLImportPath&"temp/", "ALL"), chr(10));
	
	// verify column list is compatible with current database structure before deleting
	directory action="list" directory="#curImportPath#temp/database-schema/" name="qDir" recurse="yes";
	arrError=[];
	
	skipDBStruct={};
	fixDBStruct={};
	for(row in qDir){
		if(right(row.name, 5) EQ ".json"){
			dsStruct=deserializeJson(application.zcore.functions.zreadfile(row.directory&"/"&row.name));
			for(n in dsStruct.fieldStruct){
				arrTable=listtoarray(replace(n, "`","", "all"), ".");
				if(form.ignoreDBErrors){
					// determine which columns be removed from the query and insert them into a struct
					dbNoVerify.sql="show fields from #dbNoVerify.table(arrTable[2], arrTable[1])#";
					try{
						qFields=dbNoVerify.execute("qFields");
					}catch(Any e){
						skipDBStruct[n]=true;
						continue;
					}
					fixDBStruct[n]={};
					for(row2 in qFields){
						found=false;
						for(g in dsStruct.fieldStruct[n]){
							if(row2.field EQ g){
								found=true;
							}
						}
						if(not found){
							fixDBStruct[n][row2.field]="@dummy";
						}
					}
					// loop the new struct when running the load data infile statements.  Will have to match the `db`.`table` first, then replace `#field#` with @dummy
				}else{
					columnList=structkeylist(dsStruct.fieldStruct[n], ", ");
					dbNoVerify.sql="select #columnList# from #dbNoVerify.table(arrTable[2], arrTable[1])# 
					where #dbNoVerify.param(1)#=#dbNoVerify.param(1)# ";
					if(structkeyexists(dsStruct.fieldStruct[n], "site_id")){
						dbNoVerify.sql&=" and site_id = #dbNoVerify.param(-1)#";
					}
					if(structkeyexists(dsStruct.fieldStruct[n], arrTable[2]&"_deleted")){
						dbNoVerify.sql&=" and `#arrTable[2]#_deleted` = #dbNoVerify.param(0)#";
					}
					dbNoVerify.sql&=" LIMIT #dbNoVerify.param(0)#, #dbNoVerify.param(1)#";
					try{
						dbNoVerify.execute("qCheck");
					}catch(Any e){
						arrayAppend(arrError, "Database structure exception when verifying #n#: "&e.message);
					}
				}
			}
		}
	}
	if(arraylen(arrError)){
		application.zcore.functions.zdeletedirectory(curImportPath);
		message=arrayToList(arrError, "<br />")&"<br /><br />There are a few ways to correct these errors and re-import this site:<br />A) Create the missing column(s) or table(s) in the database.<br />B) Import again with ""ignore database structure errors"" and the missing column data will not be imported.<br />C) Manually update the restore-site-database.sql file in the tar file, re-tar and re-import the file.";
		if(form.forceReturnJson){
			return {success:false, errorMessage:message};
		}else{
			application.zcore.status.setStatus(request.zsid, message, form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
		}
	}
	dsStruct={};
	for(i=1;i LTE arraylen(application.zcore.arrGlobalDatasources);i++){
		dsStruct[application.zcore.arrGlobalDatasources[i]]=[];
	}

	/*
	FLUSH TABLES WITH READ LOCK;
 

UNLOCK TABLES;
*/
	dsStruct[globals.site_datasource]=[];
	for(i=1;i LTE arrayLen(arrRestore);i++){
		skipTable=false;
		for(f in skipDBStruct){
			n="`"&replace(replace(f, "`","", "all"), ".", "`.`")&"`";
			if(arrRestore[i] CONTAINS n){
				skipTable=true;
				break;
			}
		}
		if(skipTable){
			continue;
		}
		for(f in fixDBStruct){
			n="`"&replace(replace(f, "`","", "all"), ".", "`.`")&"`";
			if(arrRestore[i] CONTAINS n){
				for(g IN fixDBStruct[f]){
					arrRestore[i]=replace(arrRestore[i], g, "@dummy");
				}
				break;
			}
		}
		curDatasource="";
		for(n in dsStruct){
			if(arrRestore[i] CONTAINS "`"&n&"`."){
				curDatasource=n;
				break;
			}
		}
		if(curDatasource EQ ""){
			application.zcore.functions.zdeletedirectory(curImportPath);
			message="Datasource in query didn't match a datasource on this installation.  You must create a matching datasource name or manually update the restore-site-database.sql file in the tar file and re-tar and re-import the file. - SQL: #arrRestore[i]#";
			if(form.forceReturnJson){
				return {success:false, errorMessage:message};
			}else{
				application.zcore.status.setStatus(request.zsid, message, form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
			}
		}
		arrayAppend(dsStruct[curDatasource], arrRestore[i]);
	}
	// all validation is done, do the actual changes now
	if(form.forceReturnJson){
		enableSitesImport="0";
	}else{
		enableSitesImport="1";
	}

	result=application.zcore.functions.zSecureCommand("importSite"&chr(9)&domainPath&chr(9)&curDate&chr(9)&fileName&chr(9)&fileUploadName&chr(9)&enableSitesImport, 3600);
	if(result EQ "0"){
		message="Failed to import the site. importSite"&chr(9)&globals.site_short_domain&chr(9)&curDate&chr(9)&fileName&chr(9)&fileUploadName&chr(9)&enableSitesImport;
		if(form.forceReturnJson){
			return {success:false, errorMessage:message};
		}else{
			application.zcore.status.setStatus(request.zsid, message, form, true);
			application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
		}
	}
	if(form.importType EQ "update"){
		application.zcore.functions.zUpdate(ts);
		form.sid=globals.site_id;
		writeLogEntry("site table: updated #form.sid#");
	}else{
		ts.debug=true;
		form.sid=application.zcore.functions.zInsert(ts);
		if(form.sid EQ false){
			throw("Failed to insert site.");
		}
		globals.site_id=form.sid;
		writeLogEntry("site table: inserted #form.sid#");
	}
	directory action="list" directory="#curImportPath#temp/database/" name="qDir" recurse="yes";
	for(row in qDir){
		if(row.directory NEQ "#curImportPath#temp/database" and row.name NEQ "." and row.name NEQ ".."){
			database=replace(replace(row.directory,"\","/","all"), "#curImportPath#temp/database/", "");
			curTable=left(row.name, len(row.name)-4);
			db.sql="show fields from #db.table(curTable, database)# ";
			qCheck=db.execute("qCheck");
			hasSiteId=false;
			hasDeleted=false;
			for(row in qCheck){
				if(row.field EQ "site_id"){
					hasSiteId=true;
				}else if(row.field EQ "#curTable#_deleted"){
					hasDeleted=true;
				}
			}
			db.sql="delete from #db.table(curTable, database)# 
			where #db.param(1)# = #db.param(1)# ";
			sql="delete from `#database#`.`#curTable#` where 1 = 1 ";
			if(hasSiteId){
				sql&=" and site_id = #globals.site_id# ";
				db.sql&=" and site_id = #db.param(globals.site_id)# ";
			}
			if(hasDeleted){
				sql&=" and `#curTable#_deleted`=0 ";
				db.sql&=" and `#curTable#_deleted`=#db.param(0)# ";
			}
			if(debug) writeoutput("#sql#;<br />");
			writeLogEntry("#sql#;");
			result=db.execute("qDelete");
			writeLogEntry("Result: #result#");
		}
	}
	for(n in dsStruct){
		// manually set datasource because the set variable queries don't use tables
		c=application.zcore.db.getConfig();
		c.autoReset=false;
		c.datasource=n;
		c.verifyQueriesEnabled=false;
		dbNoVerify=application.zcore.db.newQuery(c);
		for(i=1;i LTE arrayLen(dsStruct[n]);i++){
			dbNoVerify.sql=dsStruct[n][i];
			if(dbNoVerify.sql CONTAINS "`site_id`"){
				dbNoVerify.sql=replace(dbNoVerify.sql, ";", "")&" SET `site_id` = '"&form.sid&"'";
			}
			if(debug) writeoutput(dbNoVerify.sql&";<br />");
			writeLogEntry(";#dbNoVerify.sql#;");
			result=dbNoVerify.execute("qLoad");
			writeLogEntry("load result: #result#");
		}
	}
	
	// force system to self-heal
	db.sql="UPDATE #db.table("site", request.zos.zcoreDatasource)# 
	SET site_system_user_created=#db.param(0)#, 
	site_system_user_modified=#db.param(1)#, 
	site_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE site_id=#db.param(globals.site_id)# and 
	site_deleted = #db.param(0)#";
	db.execute("qUpdate");


	application.zcore.functions.zdeletedirectory(curImportPath);
	
	application.zcore.functions.zOS_cacheSitePaths();
	application.zcore.functions.zOS_cacheSiteAndUserGroups(globals.site_id);
	writeLogEntry("site cache updated");
	
	
	try{
		// might need to do this always - don't know yet
		application.zcore.app.appUpdateCache(globals.site_id);
	}catch(Any e){
		if(debug){
			writeoutput('done, but cache hasn''t updated yet.<a href="#globals.site_domain#/?zreset=site">Click here</a> to force it to update.');
		}else{
			message='Site import complete, but app cache hasn''t updated yet.  <a href="#globals.site_domain#/?zreset=site">Click here</a> to force it to update.';
			if(form.forceReturnJson){
				return {success:false, errorMessage:message};
			}else{
				application.zcore.status.setStatus(request.zsid, message);
				application.zcore.functions.zRedirect("/z/server-manager/admin/site-import/index?zsid=#request.zsid#");
			}
		}
	}
	
	
	if(debug){
		writeoutput('done');
	}else{
		message='Site import complete.';
		if(form.forceReturnJson){
			return {success:true};
		}else{
			application.zcore.status.setStatus(request.zsid, message);
			application.zcore.functions.zRedirect("/z/server-manager/admin/site-select/index?action=select&sid=#globals.site_id#&zsid=#request.zsid#");
		}
	}
	 </cfscript>
</cffunction>
</cfoutput> 
 </cfcomponent>