<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public">
	<cfscript>	
	var db=request.zos.queryObject;
	setting requesttimeout="100000";
	if(not request.zos.istestserver){
		echo('You can only run this command on the test environment.');
		abort;
	}
	form.skipSyncUploads=application.zcore.functions.zso(form, 'skipSyncUploads', true, 0);
	form.sid=application.zcore.functions.zso(form, 'sid');
	form.selectedWritable=application.zcore.functions.zso(form, 'selectedWritable');
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(form.sid)# and 
	site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# ";
	request.qSite=db.execute("qSite");
	if(request.qSite.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid site selected", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	request.site_homedir=application.zcore.functions.zGetDomainInstallPath(request.qSite.site_sitename);
	request.site_privatehomedir=application.zcore.functions.zGetDomainWritableInstallPath(request.qSite.site_sitename); 

	domainPath=replace(request.site_homedir, request.zos.sitesPath, "");
	request.domainPath=left(domainPath, len(domainPath)-1);
	domainWritablePath=replace(request.site_privatehomedir, request.zos.sitesWritablePath, "");
	request.domainWritablePath=left(domainWritablePath, len(domainWritablePath)-1);

	db.sql="select * from #db.table("site_x_deploy_server", request.zos.zcoreDatasource)# site_x_deploy_server,
	#db.table("deploy_server", request.zos.zcoreDatasource)# deploy_server 
	WHERE deploy_server.deploy_server_id = site_x_deploy_server.deploy_server_id and 
	site_x_deploy_server.site_id = #db.param(form.sid)# and 
	site_x_deploy_server_deleted = #db.param(0)# and 
	deploy_server_deleted = #db.param(0)# "; 
	var qDeploy=db.execute("qDeploy");
	if(qDeploy.recordcount EQ 0){
		throw("No deploy servers has been configured for this site: #request.qSite.site_domain#");
	}
	//form.gitCloneLink=application.zcore.functions.zso(form, 'gitCloneLink');
	form.gitCloneLink=request.qSite.site_primary_git_repository;
	deployCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.deploy");
	for(row in qDeploy){
		rs=deployCom.getSiteJson(row);
		if(not rs.success){
			throw(rs.errorMessage);
		}
		request.remoteSiteId=row.site_x_deploy_server_remote_site_id;
		request.remotePath=rs.dataStruct.installPath;
		request.remoteWritablePath=rs.dataStruct.installPath;
		request.deploy_server_secure=row.deploy_server_secure;
		request.deploy_server_host=row.deploy_server_host;
		request.deploy_server_email=row.deploy_server_email;
		request.deploy_server_password=row.deploy_server_password;
		form.gitCloneLink=application.zcore.functions.zso(rs.dataStruct, 'primaryGitRepository');
		if(form.gitCloneLink EQ ""){
			echo("<h2>You must enter the ""Primary Git Repository"" with a valid bitbucket clone URL on the remote server manager for this site's globals configuration.</h2>");
			abort;
		}
		/*
		writedump("request.remotePath:"&request.remotePath);
		writedump("request.remoteWritablePath:"&request.remoteWritablePath);
		writedump("form.gitCloneLink:"&form.gitCloneLink);
		*/
	}
	bitbucketUserName=application.zcore.functions.zso(request.zos, 'bitbucketUsername');
	bitbucketPassword=application.zcore.functions.zso(request.zos, 'bitbucketPassword');
	if(bitbucketUserName EQ "" or bitbucketPassword EQ ""){
		throw("request.zos.bitbucketUsername and request.zos.bitbucketPassword must be defined in zcorerootmapping.config.cfc");
	}
	</cfscript>
</cffunction>


<cffunction name="cancelled" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2>Full Sync Operation Cancelled</h2>

</cffunction>
<cffunction name="cancelFullSyncInProgress" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	application.cancelFullSyncInProgress=true;
	application.zcore.functions.zReturnJson({success:true});
	</cfscript> 
</cffunction>


<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	init();
	</cfscript> 
	<div id="fullSyncHeader">
		<h2>Full Sync</h2>
		<h3>Please Confirm Full Sync Operation</h3>
		<h3>Selected Site: #request.qSite.site_sitename# (#request.qSite.site_domain#)</h3> 
		<h2><span style="color:##900;">WARNING:</span> PERMANENT DESTRUCTION of the following information will occur if you click YES.</h2>
		<ul>
			<li>Entire database for this test site will be deleted</li>
			<li>Entire git repository will be deleted</li>
			<li>Entire local set of files for this test site will be deleted</li>
		</ul>
	</div>
	<form id="fullSyncForm" class="zFormCheckDirty" action="/z/server-manager/admin/sync-download/processFullSync?sid=#form.sid#&amp;gitCloneLink=#urlencodedformat(form.gitCloneLink)#" method="post">
		<!--- TODO: show list of zupload and zuploadsecure directories to optionally rsync --->
		<cfdirectory action="list" name="qUpload" directory="#request.site_privatehomedir#zupload/" recurse="false">
		<cfdirectory action="list" name="qUploadSecure" directory="#request.site_privatehomedir#zuploadsecure/" recurse="false">
		<cfscript>
		uploadStruct={
			"/zupload/autoresponder/":true, 
			"/zupload/library/":true, 
			"/zupload/member/":true, 
			"/zupload/settings/":true, 
			"/zupload/site-options/":true, 
			"/zupload/user/":true
		};
		secureUploadStruct={
			"/zuploadsecure/email-attachments/":true
		};
		for(row in qUpload){
			if(row.name EQ "." or row.name EQ ".."){
				continue;
			}
			uploadStruct["/zupload/"&row.name&"/"]=true;
		}
		for(row in qUploadSecure){
			if(row.name EQ "." or row.name EQ ".."){
				continue;
			}
			secureUploadStruct["/zuploadsecure/"&row.name&"/"]=true;
		}
		</cfscript>
		<p>Parent Site: 
		<cfscript>
		if(structkeyexists(cookie, 'sidParent')){
			form.sidParent=cookie.sidParent;
		}
		db.sql="SELECT site_id, replace(replace(site_short_domain, #db.param('.#request.zos.testDomain#')#, #db.param('')#), 
			#db.param('www.')#, #db.param('')#) site_short_domain 
		FROM #db.table("site", request.zos.zcoreDatasource)# site 
		WHERE site_id <> #db.param(-1)# and  
		site_deleted = #db.param(0)#
		ORDER BY site_short_domain ASC";
		qSites=db.execute("qSites");
		selectStruct = StructNew();
		selectStruct.name = "sidParent";
		selectStruct.query = qSites;
		selectStruct.queryLabelField = "site_short_domain";
		selectStruct.queryValueField = "site_id";
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript> (Leave unselected if this site is not connected to another site).</p>
		<p><input type="checkbox" name="ignoreDBErrors" id="ignoreDBErrors" value="1" /> <label for="ignoreDBErrors">Ignore Database Structure Errors?</label></p>
		<p><input type="checkbox" name="skipSyncUploads" id="skipSyncUploads" value="1" /> <label for="skipSyncUploads">Skip syncing uploads?</label></p>
	 
		<!--- <h3>Exclude Writable Paths</h3>
		<p>You can check the boxes below of some paths to exclude some of the upload paths to save time on syncing if you don't need some of the files.</p>
	
		<cfscript>
		i=0;
		for(path in uploadStruct){
			i++;
			echo('<p><input type="checkbox" name="selectedWritable" id="selectedWritable#i#" value="#htmleditformat(path)#"><label for="selectedWritable#i#">#path#</label></a></p>');
		}
		for(path in secureUploadStruct){
			i++;
			echo('<p><input type="checkbox" name="selectedWritable" id="selectedWritable#i#" value="#htmleditformat(path)#"><label for="selectedWritable#i#">#path#</label></a></p>');
		}
		</cfscript>  --->
		<button type="button" name="submit1" id="submit1" style="padding:10px;" onclick="if(window.confirm('Are you sure you want to permanently delete this test site and clone it from the live version?')){ $('##fullSyncForm').trigger('submit'); } return false;">Yes, permanently delete test site and perform full sync</button>
		<br><br>
		<button type="button" name="cancel1" style="cursor:pointer; padding:10px;" onclick="window.location.href='/z/server-manager/admin/sync-download/cancelled?sid=#form.sid#'; return false;">Cancel</button>

	</form>
	<div id="fullSyncFormLoading" style="display:none;">
		<h2>Full Sync</h2>
		<div class="fullSyncStatus" style="width:100%; float:left; margin-bottom:20px; font-size:18px;">Starting...</div>
		<div style="width:100%; float:left; margin-bottom:20px; font-size:18px;">
			<a href="##" id="cancelFullSync">Cancel Full Sync</a>
		</div>
	</div>

	<script>
	var fullSyncIntervalId=0;
	zArrDeferredFunctions.push(function(){
		$("##cancelFullSync").on("click", function(e){
			e.preventDefault();
			var obj={
				id:"ajaxCancelFullSync",
				method:"post",
				postObj:{},
				ignoreOldRequests:false,
				callback:function(r){
					var r=JSON.parse(r);
					if(r.success){
						clearInterval(fullSyncIntervalId);
						$(".fullSyncStatus").html("Cancelling full sync");
					}
				},
				errorCallback:function(r){
					alert("Error with cancelling full sync");
				},
				url:'/z/server-manager/admin/sync-download/cancelFullSyncInProgress'
			}; 
			zAjax(obj);
			return false;
		});
		$("##fullSyncForm").on("submit", function(e){
			e.preventDefault();
			var postObj=zGetFormDataByFormId("fullSyncForm"); 
			zSetCookie({key:"sidParent",value:$("##sidParent").val(),futureSeconds:365*60 * 60 * 24 * 7,enableSubdomains:false}); 
			// update status via ajax
			fullSyncIntervalId=setInterval(function(){
				var obj={
					id:"ajaxProcessFullSyncStatus",
					method:"post",
					postObj:{},
					ignoreOldRequests:false,
					callback:function(r){
						var r=JSON.parse(r);
						if(r.success){
							$(".fullSyncStatus").html(r.statusMessage);
						}
					},
					errorCallback:function(r){
						alert("Error with full sync");
					},
					url:'/z/server-manager/admin/sync-download/getFullSyncStatus'
				}; 
				zAjax(obj);
			}, 2000);

			// begin full sync main request
			var obj={
				id:"ajaxProcessFullSync",
				method:"post",
				postObj:postObj,
				ignoreOldRequests:false,
				callback:function(r){ 
					var r=JSON.parse(r);
					clearInterval(fullSyncIntervalId); 
					if(r.success){
						setTimeout(function(){
							$(".fullSyncStatus").html("Full sync completed successfully");
						}, 500);
						$("##cancelFullSync").hide();
					}else{
						$(".fullSyncStatus").html("Full sync failed: "+r.errorMessage);
					} 
				},
				errorCallback:function(r){
					alert("Error with full sync");
				},
				url:this.action
			}; 
			zAjax(obj);

			// prevent submitting the form twice
			$("##fullSyncForm").hide();
			$("##fullSyncHeader").hide();
			$("##fullSyncFormLoading").show();
			zJumpToId("fullSyncFormLoading");
		});
	});
	</script>

</cffunction>


<cffunction name="formatBitbucketCloneURL" localmode="modern" access="public">
	<cfargument name="link" type="string" required="yes">
	<cfargument name="username" type="string" required="yes">
	<cfargument name="password" type="string" required="yes">
	<cfscript>
	link=replace(arguments.link, chr(9), "", "all");
	if(link CONTAINS "git clone "){
		// convert to https
		link="https://#urlencodedformat(arguments.username)#:#urlencodedformat(arguments.password)#@bitbucket.org/"&listGetAt(link, 2, ":");
	}else{
		arrLink=listToArray(removeChars(link, 1, 8), "/", true);
		arrayDeleteAt(arrLink, 1);
		link="https://#urlencodedformat(arguments.username)#:#urlencodedformat(arguments.password)#@bitbucket.org/"&arrayToList(arrLink, "/");
	} 
	return link;
	</cfscript>
</cffunction>


<cffunction name="getFullSyncStatus" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>	
	rs={
		success:true,
		statusMessage:application.zcore.functions.zso(application, 'fullSyncDownloadStatus')
	};
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>

<cffunction name="processFullSync" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>	
	structdelete(application, 'cancelFullSyncInProgress');
	application.fullSyncDownloadStatus="Get remote site configuration"; 
	init();

	//throw("not fully implemented");
	// secure and validate the paths
	arrPath=listToArray(form.selectedWritable, ",");
	arrPathFinal=[];
	for(path in arrPath){
		path=replace(path, "/zupload/", "~-~zupload~", "all");
		path=replace(path, "/zuploadsecure/", "~-~zuploadsecure~", "all");
		path=replace(path, "/", "", "all");
		path=replace(path, "\", "", "all");
		path=replace(path, chr(10), "", "all");
		path=replace(path, chr(13), "", "all");
		path=replace(path, chr(9), "", "all");
		path=replace(path, "~-~zupload~", "/zupload/", "all");
		path=replace(path, "~-~zuploadsecure~", "/zuploadsecure/", "all");
		path=trim(path);
		if(path != ""){
			arrayAppend(arrPathFinal, path);
		}
	}
	finalPaths=arrayToList(arrPathFinal, chr(10)); 

	// download remote site database to local files

	curDate=dateformat(now(), "yyyymmdd")&"-"&timeformat(now(),"HHmmss");
	siteBackupPath=request.zos.backupDirectory&"site-archives/"&curDate&"/";
	application.zcore.functions.zCreateDirectory(siteBackupPath);
	if(request.deploy_server_secure EQ 1){
		link="https://"&request.deploy_server_host;
	}else{
		link="http://"&request.deploy_server_host;
	}
	newLink=link&"/z/server-manager/api/site/getSiteDatabaseBackup?sid=#request.remoteSiteId#&zusername=#urlencodedformat(request.deploy_server_email)#&zpassword=#urlencodedformat(request.deploy_server_password)#";  
	newUploadsLink=link&"/z/server-manager/api/site/getSiteUploadsBackup?sid=#request.remoteSiteId#&zusername=#urlencodedformat(request.deploy_server_email)#&zpassword=#urlencodedformat(request.deploy_server_password)#";  

 
	if(structkeyexists(application, 'cancelFullSyncInProgress')){
		application.zcore.functions.zDeleteDirectory(siteBackupPath);
		application.fullSyncDownloadStatus="Full sync cancelled";
		application.zcore.functions.zReturnJson({success:false, errorMessage:'Full sync cancelled'});
	}
	application.fullSyncDownloadStatus="Downloading remote site database and configuration files";
 
 	cfhttpresult={};  
 	try{ 
 		result=application.zcore.functions.zHTTPtoFile(newLink, siteBackupPath&"siteDatabaseBackup.tar.gz", 1000, true, true);
 		if(not result){
 			throw("PHP HTTP connection failed.");
 		}
 		/*
		HTTP METHOD="GET" URL="#newLink#" path="#siteBackupPath#" file="siteDatabaseBackup.tar.gz" result="cfhttpresult" redirect="yes" timeout="1000" resolveurl="no" charset="utf-8" useragent="Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3 GoogleToolbarFF 3.1.20080730 Jetendo CMS" getasbinary="auto" throwonerror="yes"{ 
		} */ 
	}catch(Any e){
		savecontent variable="out"{
			writedump(e);
		}
		//application.zcore.functions.zDeleteDirectory(siteBackupPath);
		application.zcore.functions.zReturnJson({success:false, errorMessage:'Failed to download site database backup'&out});  
	}    

	// run site-import code
	if(structkeyexists(application, 'cancelFullSyncInProgress')){
		application.zcore.functions.zDeleteDirectory(siteBackupPath);
		application.fullSyncDownloadStatus="Full sync cancelled";
		application.zcore.functions.zReturnJson({success:false, errorMessage:'Full sync cancelled'});
	}
	application.fullSyncDownloadStatus="Importing site database and configuration files";
 

	// run the same function as import site, but make it able to return json status instead of redirect.
  	form.tarFile=siteBackupPath&"siteDatabaseBackup.tar.gz";
	form.ipAddress="127.0.0.2";
	form.importType="update";
	form.sidParent=application.zcore.functions.zso(form, 'sidParent');
	form.ignoreDBErrors=application.zcore.functions.zso(form,'ignoreDBErrors', false, false);
	form.forceReturnJson=true;

	siteImportCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.site-import");
	rs=siteImportCom.process();
	if(not rs.success){
		application.zcore.functions.zDeleteDirectory(siteBackupPath); 
		application.zcore.functions.zReturnJson({success:false, errorMessage:"Failed to import site: "&rs.errorMessage});  
	} 

	// gitClone will wipe and recreate the local directory so that we can clone from scratch 

	// make zSecureCommand gitClone, pass the encoded git url to it
	formattedGitCloneLink=formatBitbucketCloneURL(form.gitCloneLink, request.zos.bitbucketUsername, request.zos.bitbucketPassword);
	//echo('formattedGitCloneLink:'&formattedGitCloneLink&'<br>');

	//echo("gitClone"&chr(9)&formattedGitCloneLink&chr(9)&request.site_homedir&'<br>');
	//result="1";
	if(structkeyexists(application, 'cancelFullSyncInProgress')){
		application.zcore.functions.zDeleteDirectory(siteBackupPath);
		application.fullSyncDownloadStatus="Full sync cancelled";
		application.zcore.functions.zReturnJson({success:false, errorMessage:'Full sync cancelled'});
	}
	application.fullSyncDownloadStatus="Cloning local files from bitbucket";
	result=application.zcore.functions.zSecureCommand("gitClone"&chr(9)&formattedGitCloneLink&chr(9)&request.site_homedir, 1000);
	arrResult=listToArray(result, "|");
 
	if(arraylen(arrResult) LTE 1){
		application.zcore.functions.zDeleteDirectory(siteBackupPath);
		application.zcore.functions.zReturnJson({success:false, errorMessage: "Git clone failed.  Make sure the files are not locked."});  
	}else if(arrResult[1] EQ 0){
		application.zcore.functions.zDeleteDirectory(siteBackupPath);
		application.zcore.functions.zReturnJson({success:false, errorMessage:"Git clone failed with error: #arrResult[1]#.  Make sure the files are not locked."}); 
	}


	if(form.skipSyncUploads NEQ 1){
		if(structkeyexists(application, 'cancelFullSyncInProgress')){
			application.zcore.functions.zDeleteDirectory(siteBackupPath);
			application.fullSyncDownloadStatus="Full sync cancelled";
			application.zcore.functions.zReturnJson({success:false, errorMessage:'Full sync cancelled'});
		}
		application.fullSyncDownloadStatus="Downloading sites-writable files";
	 
	 	cfhttpresult={}; 
	 	// TODO: make it possible to exclude directory from site uploads import
	 	if(finalPaths NEQ ""){
			echo('writable paths to exclude<br>'&finalPaths&'<br>');
			//application.zcore.functions.zWriteFile(request.site_privatehomedir&"__deploy-full-sync.txt", finalPaths);
		}
	 	try{
	 		result=application.zcore.functions.zHTTPtoFile(newUploadsLink, siteBackupPath&"siteUploadsBackup.tar.gz", 2000, true, true);
	 		if(not result){
	 			throw("PHP HTTP connection failed.");
	 		}
			/*HTTP METHOD="GET" URL="#newUploadsLink#" path="#siteBackupPath#" file="siteUploadsBackup.tar.gz" result="cfhttpresult" redirect="yes" timeout="1000" resolveurl="no" charset="utf-8" useragent="Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3 GoogleToolbarFF 3.1.20080730 Jetendo CMS" getasbinary="auto" throwonerror="yes"{ 
			}*/
		}catch(Any e){ 
			savecontent variable="out"{
				writedump(e);
			}
			application.zcore.functions.zDeleteDirectory(siteBackupPath);
			application.zcore.functions.zReturnJson({success:false, errorMessage:'Failed to download site zupload/zuploadsecure files'&out}); 
		}  

		// import the site uploads
		if(structkeyexists(application, 'cancelFullSyncInProgress')){
			application.zcore.functions.zDeleteDirectory(siteBackupPath);
			application.fullSyncDownloadStatus="Full sync cancelled";
			application.zcore.functions.zReturnJson({success:false, errorMessage:'Full sync cancelled'});
		}
		application.fullSyncDownloadStatus="Importing sites-writable files";

		theUploadFile=siteBackupPath&"siteUploadsBackup.tar.gz";

		application.zcore.functions.zSecureCommand("importSiteUploads#chr(9)##request.domainWritablePath##chr(9)##siteBackupPath##chr(9)#siteUploadsBackup.tar.gz", 10600); 
		application.zcore.functions.zDeleteFile(theUploadFile);
	}

	if(structkeyexists(application, 'cancelFullSyncInProgress')){
		application.zcore.functions.zDeleteDirectory(siteBackupPath);
		application.fullSyncDownloadStatus="Full sync cancelled";
		application.zcore.functions.zReturnJson({success:false, errorMessage:'Full sync cancelled'});
	}
	application.fullSyncDownloadStatus="Applying final changes.";

	// force some helpful fixes
	// delete zofficeemail
	// delete lead routing
	// delete visitor tracking code
	// more...
	 

	application.zcore.functions.zDeleteDirectory(siteBackupPath);
	structdelete(application, 'fullSyncDownloadStatus');
	application.zcore.functions.zReturnJson({success:true});
	</cfscript>
</cffunction>

</cfoutput>	
</cfcomponent>