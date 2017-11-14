<cfcomponent>
<!--- It took 4 minutes 20 to backup entire test server - 2.6gb compressed
TODO: figure out why site backup doesn't get compressed.
 --->
<cfoutput>

<cffunction name="downloadSite" localmode="modern" access="private">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="domainPath" type="string" required="yes">
	<cfargument name="tempPathName" type="string" required="yes">
	<cfscript>
	var fp=request.zos.backupDirectory&"site-archives/"&arguments.domainPath&"-"&arguments.tempPathName&'.tar.gz';
	if(not fileexists(fp)){
		echo('File doesn''t exist.  Check permissions: #fp#');
		abort;
	}
	header name="Content-Disposition" value="attachment; filename=#getfilefrompath(fp)#" charset="utf-8";
	content type="application/binary" deletefile="no" file="#fp#";
	abort;
	</cfscript>
</cffunction>

<cffunction name="downloadSiteUpload" localmode="modern" access="private">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="domainPath" type="string" required="yes">
	<cfargument name="tempPathName" type="string" required="yes">
	<cfscript>
	var fp=request.zos.backupDirectory&"site-archives/"&arguments.domainPath&"-zupload-"&arguments.tempPathName&'.tar.gz';
	if(not fileexists(fp)){
		echo('File doesn''t exist.  Check permissions: #fp#');
		abort;
	}
	header name="Content-Disposition" value="attachment; filename=#getfilefrompath(fp)#" charset="utf-8";
	content type="application/binary" deletefile="no" file="#fp#";
	abort;
	</cfscript>
</cffunction>


<cffunction name="downloadGlobal" localmode="modern" access="private">
	<cfscript>
	var fp=request.zos.backupDirectory&"global-database.tar.gz";
	if(not fileexists(fp)){
		echo('File doesn''t exist.  Check permissions: #fp#');
		abort;
	}
	header name="Content-Disposition" value="attachment; filename=#getfilefrompath(fp)#" charset="utf-8";
	content type="application/binary" deletefile="no" file="#fp#";
	abort;
	</cfscript>
</cffunction>

<cffunction name="getCreateTriggerSQLFromStruct" localmode="modern" output="no" access="public">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="row" type="struct" required="yes"> 
	<cfscript>
	return { 
		dropTriggerSQL: "DROP TRIGGER IF EXISTS `"&arguments.row.trigger&"`", 
		createTriggerSQL: "CREATE TRIGGER `"&arguments.row.table&"_auto_inc` "&arguments.row.timing&" "&arguments.row.event&" ON `"&arguments.row.table&"` FOR EACH ROW "&arguments.row.statement&";"
	};
	</cfscript>
</cffunction>

<cffunction name="getExcludedTableStruct" localmode="modern" access="public" returntype="struct">
	<cfscript>
	ts={ 
		"rets20_media": true, 
		"city_memory": true,
		"city_distance_memory": true,
		"listing_memory": true,
		"listing_meta_table": true,
		"geoip_block": true,
		"geoip_block_safe": true,
		"geoip_location": true,
		"geoip_location_safe": true,
		// marketing tables
		"newsletter_month":true,
		"newsletter_email":true,
		"keyword_ranking":true,
		"ga_month":true,
		"ga_month_keyword":true,
		"facebook_post":true,
		"facebook_page_month":true,
		"facebook_page":true,
		"facebook_month":true,
		"site_x_deploy_server":true
	};
	return ts;
	</cfscript>
</cffunction>

<cffunction name="generateSchemaBackup" localmode="modern" output="no" access="public">
	<cfargument name="datasource" type="string" required="yes">
	<cfargument name="dsStruct" type="struct" required="yes">
	<cfscript>
	var i2=arguments.datasource;
	var arrSchema=[];
	var qT=0;
	var i=0;
	var n=0;
	var qC=0;
	var tempStruct=0;
	var row=0; 
	setting requesttimeout="5000";
	query name="qT" datasource="#i2#"{
		echo("SHOW TABLES IN `"&application.zcore.functions.zescape(i2)&"`");
	}
	ts=getExcludedTableStruct();
	for(local.row in qT){
		n=local.row["Tables_in_"&i2];
		if(not structkeyexists(ts, n)){
			arrayAppend(arrSchema, "drop table if exists `"&n&"`;");
			query name="qC" datasource="#i2#"{
				echo("show create table `"&application.zcore.functions.zescape(i2)&"`.`"&application.zcore.functions.zescape(n)&"`");
			}
			arrayAppend(arrSchema, qC["Create Table"]&";");
		}
	} 
	query name="qT" datasource="#i2#"{
		echo("SHOW TRIGGERS FROM `"&application.zcore.functions.zescape(i2)&"`");
	}

	for(row in qT){
		if(not structkeyexists(ts, n)){
			local.curTrigger=this.getCreateTriggerSQLFromStruct(i2, row);
			arrayAppend(arrSchema, local.curTrigger.dropTriggerSQL);
			arrayAppend(arrSchema, local.curTrigger.createTriggerSQL); 
		}
	} 
	
	tempStruct=structnew();
	tempStruct.databaseVersion=application.zcore.databaseVersion;
	tempStruct.fieldStruct=structnew();
	tempStruct.keyStruct=structnew();
	tempStruct.tableStruct=structnew();
	for(n in arguments.dsStruct.globalTableStruct[i2]){
		tempStruct.tableStruct[i2&"."&n]=arguments.dsStruct.tableStruct[i2&"."&n];
		tempStruct.triggerStruct[i2&"."&n]=arguments.dsStruct.triggerStruct[i2&"."&n];
		tempStruct.keyStruct[i2&"."&n]=arguments.dsStruct.keyStruct[i2&"."&n];
		tempStruct.fieldStruct[i2&"."&n]=arguments.dsStruct.fieldStruct[i2&"."&n];
	}
	for(n in arguments.dsStruct.siteTableStruct[i2]){
		tempStruct.tableStruct[i2&"."&n]=arguments.dsStruct.tableStruct[i2&"."&n];
		tempStruct.triggerStruct[i2&"."&n]=arguments.dsStruct.triggerStruct[i2&"."&n];
		tempStruct.keyStruct[i2&"."&n]=arguments.dsStruct.keyStruct[i2&"."&n];
		tempStruct.fieldStruct[i2&"."&n]=arguments.dsStruct.fieldStruct[i2&"."&n];
	} 
	return { sql: arrayToList(arrSchema, chr(10)), struct: tempStruct };
	</cfscript>
</cffunction>

<!--- sites with their own database need ALL data backed up - not just siteIdTables --->
<cffunction name="index" localmode="modern" access="remote">
	<cfscript> 
	var db=request.zos.noVerifyQueryObject;
	setting requesttimeout="5000"; 

 	if(form.method EQ "getSiteDatabaseBackup" or form.method EQ "getSiteUploadsBackup"){

 	}else{
		if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
			application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
		}
	}
	// forces clean up even on local server to save space.
	savecontent variable="out"{
		// ignore output
		deleteOldBackups();
	}
 
	curDate=dateformat(now(), "yyyymmdd")&"-"&timeformat(now(),"HHmmss");
	
	variables.tempPathName="-temp";
	local.backupGlobal=1;
	//form.createNew=application.zcore.functions.zso(form, 'createNew', false, 0);
	form.createNew=1;
	form.backupType=application.zcore.functions.zso(form, 'backupType');
	if(form.backupType EQ 1 or form.backupType EQ 2){
		variables.tempPathName="";
		local.backupGlobal=0;
	}else if(form.backupType EQ "" or form.backupType EQ 3){
		local.backupGlobal=1;
	}
	form.sid=application.zcore.functions.zso(form, 'sid', true, 0);
	if(form.createNew EQ 0 and form.backupType EQ 3){
		if(fileexists(request.zos.backupDirectory&"global-database.tar")){
			variables.downloadGlobal();
		}
	}
	request.ignoreSlowScript=true;
	backupDatabaseStruct=structnew();
	for(i=1;i LTE arraylen(application.zcore.arrGlobalDatasources);i++){
		backupDatabaseStruct[application.zcore.arrGlobalDatasources[i]]=0; 
	}
	local.siteSQL="";
	if(form.sid NEQ 0){
		local.siteSQL=" and site.site_id='"&application.zcore.functions.zescape(form.sid)&"'";	
	}
	
	db.sql="select * from #db.table("site", request.zos.zcoredatasource)# site 
	where site_active='1' and 
	site_deleted = #db.param(0)#
	#local.siteSQL# ";
	qs=db.execute("qs"); 
	local.sitePathStruct={};
	local.sitePathMySQLStruct={};
	local.siteRestoreStruct={};
	for(local.row in qs){
		curDomainOriginal=replace(replace(local.row.site_short_domain,"www.",""),"."&request.zos.testDomain,"");
		curDomain=replace(curDomainOriginal, ".", "_", "all");
		local.tempPath=request.zos.backupDirectory&"site-archives#variables.tempPathName#/"&curDomain&"/";
		/*if(form.createNew EQ 0){
			if(form.backupType EQ 1){
				if(fileexists(request.zos.backupDirectory&"site-archives#variables.tempPathname#/"&curDomain&'.tar')){
					variables.downloadSite(form.sid, curDomain, curDate);
				}
			}
		}*/
		if(form.backupType EQ 2){
			tempPathUpload=request.zos.backupDirectory&"site-archives/"&curDomain&"-zupload-"&curDate&'.tar.gz';
			if(form.createNew EQ 1 or not fileexists(tempPathUpload)){
				result=application.zcore.functions.zSecureCommand("tarZipSiteUploadPath"&chr(9)&curDomain&chr(9)&curDate, 3600);
			}
			variables.downloadSiteUpload(form.sid, curDomain, curDate);
		}
		if(variables.tempPathName EQ ""){
			application.zcore.functions.zdeletedirectory(local.tempPath);
		}
		local.sitePathStruct[local.row.site_id]=local.tempPath;
		local.sitePathMySQLStruct[local.row.site_id]=request.zos.mysqlBackupDirectory&"site-archives#variables.tempPathName#/"&curDomain&"/";
		if(structkeyexists(form, 'zdebug')){
			echo('Creating: '&local.tempPath&'<br />');
			echo('Creating: '&local.tempPath&'database/'&'<br />');
		}
		application.zcore.functions.zcreatedirectory(local.tempPath);
		if(not directoryexists(local.tempPath)){
			echo("Failed to create directory: "&local.tempPath&"<br>");
			abort;
		}
		application.zcore.functions.zcreatedirectory(local.tempPath&"database/");
		local.siteRestoreStruct[local.row.site_id]=[];
		application.zcore.functions.zwritefile(local.tempPath&"globals.json", serializeJSON(local.row));
	}
	db.sql="SELECT site_id, site_datasource FROM `#request.zos.zcoreDatasource#`.`site`  site
	WHERE site_active='1' AND
	site_id <> -1 AND 
	site_datasource<>'' and 
	site_deleted = #db.param(0)#
	#local.siteSQL#
	GROUP BY site_datasource";
	qSites=db.execute("qSites");
	for(local.row in qSites){
		if(not structkeyexists(backupDatabaseStruct, local.row.site_datasource)){
			if(not structkeyexists(request.zos.excludeDatasourcesFromBackup, local.row.site_datasource)){
				backupDatabaseStruct[local.row.site_datasource]=local.row.site_id;
			}
		}
	}
	arrDatasource=structkeyarray(backupDatabaseStruct);
	curDSStruct=structnew();
	for(x1=1;x1 LTE arraylen(arrDatasource);x1++){
		ds=arrDatasource[x1];
		if(not structkeyexists(request.zos.excludeDatasourcesFromBackup, ds) and structkeyexists(backupDatabaseStruct, ds)){
			curDSStruct=application.zcore.functions.zGetDatabaseStructure(ds, curDSStruct);
		}
	}
	
	d=arraynew(1);
	d2=arraynew(1);
	d3=arraynew(1);
	dbauth=' --host="hostdevmachine" --user="devadmin" --password="3292hay"';
	if(variables.tempPathName NEQ ""){
		application.zcore.functions.zDeleteDirectory("#request.zos.backupDirectory#site-archives-old/");
		application.zcore.functions.zDeleteDirectory("#request.zos.backupDirectory#site-archives#variables.tempPathName#/");
		application.zcore.functions.zcreatedirectory("#request.zos.backupDirectory#site-archives#variables.tempPathName#/");
	}
	if(local.backupGlobal EQ 1){
		application.zcore.functions.zDeleteDirectory("#request.zos.backupDirectory#database-global-backup/");
		application.zcore.functions.zcreatedirectory("#request.zos.backupDirectory#database-global-backup/");
	}
	application.zcore.functions.zDeleteDirectory("#request.zos.backupDirectory#database-schema/");
	application.zcore.functions.zcreatedirectory("#request.zos.backupDirectory#database-schema/");
	outfileOptions="FIELDS TERMINATED BY '\t' ENCLOSED BY '""' ESCAPED BY '\\' LINES TERMINATED BY '\n' ";
	if(request.zos.istestserver){
		limitSQL="";
		//	limitSQL=" LIMIT 0,10"; // comment to test all data
	}else{
		limitSQL="";	
	}
	arrayClear(request.zos.arrQueryLog);
	
	local.zeroSiteIdTableBackupCacheStruct={};
	
	application.zcore.functions.zcreatedirectory("#request.zos.backupDirectory#database-global-backup/");
	application.zcore.functions.zCreateDirectory(request.zos.backupDirectory&"database-schema/");
	for(i2 in backupDatabaseStruct){
		local.schemaStruct=this.generateSchemaBackup(i2, curDSStruct);
		application.zcore.functions.zwritefile(request.zos.backupDirectory&"database-schema/"&i2&".sql", local.schemaStruct.sql);
		application.zcore.functions.zwritefile(request.zos.backupDirectory&"database-schema/"&i2&".json", serializeJson(local.schemaStruct.struct)); 
	}
	for(i2 in curDSStruct.globalTableStruct){
		/*if(i2 EQ request.zos.zcoreDatasource){
			continue; // this is a structure only database - skip it
		}*/
		local.curSiteId=backupDatabaseStruct[i2];
		if(local.curSiteId NEQ 0){
			if(structkeyexists(form, 'zdebug')){
				echo('Creating: '&local.sitePathStruct[local.curSiteId]&"database/"&i2&"/<br />");
			}
			application.zcore.functions.zcreatedirectory(local.sitePathStruct[local.curSiteId]&"database/"&i2&"/");
		}else if(local.backupGlobal EQ 1){
			if(structkeyexists(form, 'zdebug')){
				echo('Creating: '&"#request.zos.backupDirectory#database-global-backup/"&i2&"/");
			}
			application.zcore.functions.zcreatedirectory("#request.zos.backupDirectory#database-global-backup/"&i2&"/");
		}
		for(n in curDSStruct.globalTableStruct[i2]){
			if(structkeyexists(request.zos.backupStructureOnlyTables, i2&"."&n)){
				continue;	
			}
			if(structkeyexists(application.zcore.memoryTableStruct, n)){
				continue;
			}
			local.tempColumnList="`"&arrayToList(curDSStruct.fieldArrayStruct[i2&"."&n], "`, `")&"`";
			if(local.curSiteId NEQ 0){
				db.sql="select #local.tempColumnList# from `"&i2&"`.`"&n&"`"&limitSQL&" 
				into outfile '#local.sitePathMySQLStruct[local.curSiteId]#database/"&i2&"/"&n&".tsv' #outfileOptions#;";
				db.execute("qd");
				
				local.sql="truncate table `"&i2&"`.`"&n&"`;";
				arrayappend(local.siteRestoreStruct[local.curSiteId], local.sql);
				local.sql="load data local infile '/ZIMPORTPATH/database/"&i2&"/"&n&".tsv' 
				into table `"&i2&"`.`"&n&"` #outfileOptions# (#local.tempColumnList#);";
				arrayappend(local.siteRestoreStruct[local.curSiteId], local.sql);
			}else if(local.backupGlobal EQ 1){
				db.sql="select #local.tempColumnList# from `"&i2&"`.`"&n&"`"&limitSQL&" 
				into outfile '#request.zos.mysqlBackupDirectory#database-global-backup/"&i2&"/"&n&".tsv' #outfileOptions#;";
				db.execute("qd");
				
				local.sql="truncate table `"&i2&"`.`"&n&"`;";
				arrayappend(d3, local.sql);
				local.sql="load data local infile '/ZIMPORTPATH/database-global-backup/"&i2&"/"&n&".tsv' 
				into table `"&i2&"`.`"&n&"` #outfileOptions# (#local.tempColumnList#);";
				arrayappend(d3, local.sql);
			}
		}
	}
	
	for(i2 in curDSStruct.siteTableStruct){
		local.curSiteId=backupDatabaseStruct[i2];
		for(n in curDSStruct.siteTableStruct[i2]){
			if(structkeyexists(request.zos.backupStructureOnlyTables, i2&"."&n)){
				continue;	
			}
			db.sql="select site_id from #db.table(n, i2)# site";
			if(form.sid NEQ 0){
				db.sql&=" where site_id in (#db.param(0)#, #db.param(form.sid)#) ";
			}
			db.sql&=" group by site.site_id";
			qs=db.execute("qs"); 
			if(qs.recordcount NEQ 0){
				local.tempColumnList="`"&arrayToList(curDSStruct.fieldArrayStruct[i2&"."&n], "`, `")&"`";
				for(g=1;g LTE qs.recordcount;g++){
					if(qs.site_id[g] NEQ 0 and not structkeyexists(local.sitePathStruct, qs.site_id[g])){
						continue; // inactive site_id
					}
					if(qs.site_id[g] NEQ 0 and not directoryexists(local.sitePathStruct[qs.site_id[g]]&"database/"&i2&"/")){
						application.zcore.functions.zcreatedirectory(local.sitePathStruct[qs.site_id[g]]&"database/"&i2&"/");
					}
					if(qs.site_id[g] EQ 0){
						 if(local.backupGlobal EQ 1 and local.curSiteId EQ 0  and not structkeyexists(local.zeroSiteIdTableBackupCacheStruct, i2&"."&n)){
							local.zeroSiteIdTableBackupCacheStruct[i2&"."&n]=true;
							application.zcore.functions.zcreatedirectory("#request.zos.backupDirectory#database-global-backup/"&i2&"/");
							db.sql="select #local.tempColumnList# from `"&i2&"`.`"&n&"` where site_id ='0' "&limitSQL&" 
							into outfile '#request.zos.mysqlBackupDirectory#database-global-backup/"&i2&"/"&n&".tsv' #outfileOptions#;";
							qd=db.execute("qd");
							local.sql="delete from `"&i2&"`.`"&n&"` WHERE site_id = '0';";
							arrayappend(d3, local.sql);
							local.sql="load data local infile '/ZIMPORTPATH/database-global-backup/"&i2&"/"&n&".tsv' into table `"&i2&"`.`"&n&"` #outfileOptions# (#local.tempColumnList#);";
							arrayappend(d3, local.sql);
						}
					}else{
						db.sql="select #local.tempColumnList# from `"&i2&"`.`"&n&"` where site_id ='"&qs.site_id[g]&"' "&limitSQL&" 
						into outfile '#local.sitePathMySQLStruct[qs.site_id[g]]#database/"&i2&"/"&n&".tsv' #outfileOptions#;";
						qd=db.execute("qd");
						local.sql="load data local infile '/ZIMPORTPATH/database/"&i2&"/"&n&".tsv' into table `"&i2&"`.`"&n&"` #outfileOptions# (#local.tempColumnList#);";
						arrayappend(local.siteRestoreStruct[qs.site_id[g]], local.sql);
					}
				}
			}
		}
	}
	if(local.backupGlobal EQ 1){
		for(i=1;i LTE arraylen(d3);i++){
			d3[i]=replace(replace(d3[i], chr(10), " ", "all"), chr(13), "", "all");
		}
		application.zcore.functions.zwritefile(request.zos.backupDirectory&"restore-global-database.sql", arraytolist(d3, chr(10)));
	}
	for(i2 in local.siteRestoreStruct){
		for(i=1;i LTE arraylen(local.siteRestoreStruct[i2]);i++){
			local.siteRestoreStruct[i2][i]=replace(replace(local.siteRestoreStruct[i2][i], chr(10), " ", "all"), chr(13), "", "all");
		}
		application.zcore.functions.zwritefile(local.sitePathStruct[i2]&"restore-site-database.sql", arraytolist(local.siteRestoreStruct[i2], chr(10)));
	}
	
	
	db.sql="select site.*, group_concat(app_x_site.app_id SEPARATOR #db.param(',')#) appidlist 
	from `#request.zos.zcoreDatasource#`.`site` 
	left join #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site ON 
	app_x_site.site_id = site.site_id and 
	app_x_site_deleted = #db.param(0)#
	WHERE site_active=#db.param('1')# AND 
	site.site_id <> #db.param(request.zos.globals.serverid)# and 
	site_deleted = #db.param(0)#
	#local.siteSQL#
	GROUP BY site.site_id ";
	qSites2=db.execute("qSites2");
	
	
	
	for(row in qSites2){
		arr7z=arraynew(1);
		arrD=listtoarray(row.appidlist,',');
		appIdStruct=structnew();
		for(i=1;i LTE arraylen(arrD);i++){
			appIdStruct[arrD[i]]=true;
		}
		curDomainOriginal=replace(replace(row.site_short_domain,"www.",""),"."&request.zos.testDomain,"");
		curDomain=replace(curDomainOriginal, ".", "_", "all");
		curTableStruct=structnew();
		curTableStruct[request.zos.zcoreDatasource]=true;
		if(structkeyexists(appIdStruct, 11)){
			// has listing app
			curTableStruct[request.zos.zcoreDatasource]=true;
			curTableStruct[request.zos.zcoreDatasource]=true;
		}
		if(structkeyexists(appIdStruct, 13)){
			// has rental app
			curTableStruct[request.zos.zcoreDatasource]=true;
		}
		if(row.site_datasource NEQ ""){
			curTableStruct[row.site_datasource]=true;
		}
		for(i2 in curTableStruct){
			arrayappend(arr7z, '"database-schema/#i2#.sql" ');
			arrayappend(arr7z, '"database-schema/#i2#.json" ');
		}
		/*if(local.backupGlobal EQ 1){
			application.zcore.functions.zdeletefile(request.zos.backupDirectory&'site-archives#variables.tempPathName#/'&curDomain&'-#variables.tempPathName#-global.tar.gz');
			application.zcore.functions.zSecureCommand("tarZipSiteUploadPath"&chr(9)&curDomain, 3600);
		}*/


		if(form.backupIncludeType EQ "filesAndDatabase"){
			r1=application.zcore.functions.zSecureCommand("tarZipSitePath"&chr(9)&curDomain&chr(9)&curDate&chr(9)&"1", 3600);
		}else{
			r1=application.zcore.functions.zSecureCommand("tarZipSitePath"&chr(9)&curDomain&chr(9)&curDate&chr(9)&"0", 3600);
		}
		application.zcore.functions.zDeleteDirectory(request.zos.backupDirectory&'site-archives#variables.tempPathName#/#curDomain#/');
		if(request.zos.istestserver){
			break; // uncomment for faster debugging of backup script.
		}
	}
	if(local.backupGlobal EQ 1){
		changeToAbsoluteDirectory=request.zos.backupDirectory;
		absolutePathToTar=request.zos.backupDirectory&"restore-global-database.sql"; // other paths to tar: database-global-backup/ database-schema/
		tarAbsoluteFilePath=request.zos.backupDirectory&"global-database.tar.gz";
		application.zcore.functions.zSecureCommand("tarZipGlobalDatabase", 7200);
		application.zcore.functions.zDeleteDirectory("#request.zos.backupDirectory#database-schema/");
		application.zcore.functions.zDeleteDirectory("#request.zos.backupDirectory#database-global-backup/");
		application.zcore.functions.zDeleteFile("#request.zos.backupDirectory#restore-global-database.sql");
	}
	if(variables.tempPathName NEQ ""){
		if(directoryexists("#request.zos.backupDirectory#site-archives/")){
			directoryRename("#request.zos.backupDirectory#site-archives/", "#request.zos.backupDirectory#site-archives-old/");
		}
		directoryRename("#request.zos.backupDirectory#site-archives#variables.tempPathName#/", "#request.zos.backupDirectory#site-archives/");
		application.zcore.functions.zDeleteDirectory("#request.zos.backupDirectory#site-archives-old/");
	}
	if(form.backupType EQ 1){ 
		downloadSite(form.sid, curDomain, curDate);
	}else if(form.backupType EQ 3){
		downloadGlobal();
	}else{
		writeoutput('Done');
	}
	</cfscript>
</cffunction>


<cffunction name="deleteOldBackups" localmode="modern" access="remote">
	<cfscript> 
	var db=request.zos.noVerifyQueryObject;
	setting requesttimeout="5000"; 
 	if(application.zcore.user.checkServerAccess()){

 	}else if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	path="#request.zos.backupDirectory#site-archives/";
 	directory name="qDir" directory="#path#" recurse="no" action="list"; 
 	deleteCount=0;
 	for(row in qDir){
 		if(row.name EQ "." or row.name EQ ".."){
 			continue;
 		}
 		if(row.type EQ "dir"){
 			echo("Deleting "&path&row.name&"<br>");
 			application.zcore.functions.zDeleteDirectory(path&row.name);
 			deleteCount++;
 		}else{
	 		if(dateformat(row.dateLastModified, "yyyymmdd") LTE dateformat(dateadd("d", -1, now()), "yyyymmdd")){
	 			echo("Deleting "&path&row.name&"<br>");
	 			application.zcore.functions.zDeleteFile(path&row.name);
	 			deleteCount++;
	 		}
	 	}
 	}
 	echo('Deleted '&deleteCount&' files');
 	
 	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>