<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	variables.siteBackupCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.site-backup");
	variables.outfileOptions="FIELDS TERMINATED BY '\t' ENCLOSED BY '""' ESCAPED BY '\\' LINES TERMINATED BY '\n' ";
	variables.curBackupDate=dateformat(now(), 'yyyymmdd')&timeformat(now(),'HHmmss');
	variables.databaseBackupPath="#request.zos.backupDirectory#upgrade/databaseBackup#variables.curBackupDate#/";
	variables.mysqlDatabaseBackupPath="#request.zos.mysqlBackupDirectory#upgrade/databaseBackup#variables.curBackupDate#/";
	//variables.tableVersionStruct=getTableVersionStruct();
	</cfscript>
</cffunction>

<cffunction name="verifyDatabaseStructure" localmode="modern" access="public">
	<cfargument name="schemaFilePath" type="string" required="yes">
	<cfargument name="datasource" type="string" required="no" default="">
	<cfscript>
	init();
	curDSStruct={};
	renameStruct={};
	if(arguments.datasource EQ ""){
		arguments.datasource=request.zos.zcoreDatasource;
	}
	query name="qVersion" datasource="#arguments.datasource#"{
		echo("SELECT * FROM jetendo_setup LIMIT 0,1");
	}
	// verify integrity of currentVersion to ensure upgrade will be successfull
	newDsStruct=deserializeJson(replace(application.zcore.functions.zreadfile(arguments.schemaFilePath), "zcoreDatasource.", arguments.datasource&".", "ALL"));
	if(newDsStruct.databaseVersion GTE qVersion.jetendo_setup_database_version){
		curDSStruct=application.zcore.functions.zGetDatabaseStructure(arguments.datasource, curDSStruct);
		schemaStruct=variables.siteBackupCom.generateSchemaBackup(arguments.datasource, curDSStruct); 
		
		existingDsStruct=schemaStruct.struct; 
		verifyStruct=runDatabaseUpgrade(arguments.datasource, renameStruct, existingDsStruct, newDsStruct, true);
		if(not verifyStruct.success){
			writeoutput('A database upgrade can''t be performed.<br />
				The current database schema (#newDSStruct.databaseVersion#)  doesn''t match 
				the installed version (#qVersion.jetendo_setup_database_version#) defined in #arguments.schemaFilePath#.<br />
				The differences must be manually fixed before running the upgrade process again.<hr />');
			return false;
		}
	}else{
		// installed database is older version then schema json file
		echo('Current database version ('&qVersion.jetendo_setup_database_version&') is older 
			then the current schema version ('&newDSStruct.databaseVersion&').<br />
			Schema can''t be validated.<br />
			A database upgrade can be performed on the test server only.<br />');
		if(not request.zos.isTestServer){
			return false;
		}
	}
	echo("Database structure verified successfully.<br />");
	return true;
	</cfscript>
</cffunction>

<cffunction name="checkVersion" localmode="modern" access="public">
	<cfscript>
	//if(not structkeyexists(application.zcore, 'databaseVersion')){
		versionCom=createobject("component", "zcorerootmapping.version");
	    ts2=versionCom.getVersion();
	    application.zcore.databaseVersion=ts2.databaseVersion;
	    application.zcore.sourceVersion=ts2.sourceVersion;
	//}
	try{
		query name="qCheck" datasource="#request.zos.zcoreDatasource#"{
			echo("SHOW TABLES IN `#request.zos.zcoreDatasource#` LIKE 'jetendo_setup'");
		}
	}catch(Any e){
		throw("request.zos.zcoreDatasource, ""#request.zos.zcoreDatasource#"", must be a valid datasource.");
	}
	tempFile=request.zos.sharedPath&"database/jetendo-schema-"&ts2.databaseVersion&".json";
	newFilePath=tempFile;
	tempFile2=request.zos.sharedPath&"database/jetendo-schema-current.json";
	if(not fileexists(tempFile2)){
		application.zcore.functions.zcopyfile(tempFile, tempFile2, true);
	}
	currentVersion=0;
	if(qCheck.recordcount NEQ 0){
		query name="qVersion" datasource="#request.zos.zcoreDatasource#"{
			echo("SELECT * FROM jetendo_setup LIMIT 0,1");
		}
		if(qVersion.recordcount EQ 0){
			query name="qInsert" datasource="#request.zos.zcoreDatasource#"{
				echo("INSERT INTO jetendo_setup SET jetendo_setup_database_version = '#application.zcore.databaseVersion#', jetendo_setup_updated_datetime='#request.zos.mysqlnow#' ");
			}
			currentVersion=application.zcore.databaseVersion;
			if(not structkeyexists(application, request.zos.installPath&":dbUpgradeCheckVersion")){
				return true;
			}
		}else{
			if(qVersion.jetendo_setup_database_version EQ application.zcore.databaseVersion){
				if(not structkeyexists(application, request.zos.installPath&":dbUpgradeCheckVersion")){
					return true;
				}
			}else if(qVersion.jetendo_setup_database_version GT application.zcore.databaseVersion){
				throw("Jetendo database is a newer version (#qVersion.jetendo_setup_database_version#) then application.zcore.databaseVersion (#application.zcore.databaseVersion#).  Please check that source code version is the same or newer then database.");
			}
			currentVersion=qVersion.jetendo_setup_database_version;
		}
		if(not fileexists(tempFile)){
			tempFile=request.zos.sharedPath&"database/jetendo-schema-"&currentVersion&".json";
			if(not fileexists(tempFile)){
				throw("checkVersion: The current database version's schema json file is missing: "&request.zos.sharedPath&"database/jetendo-schema-"&currentVersion&".json");
			}
		}
	}
	setting requesttimeout="500";
	application[request.zos.installPath&":dbUpgradeCheckVersion"]=true;

	// verify the rest of the config.cfc values before installing database & application.
	if(currentVersion EQ 0){
		installInitialDatabase();
		application.zcore.functions.zcopyfile(tempFile, tempFile2, true);
		query name="qInsert" datasource="#request.zos.zcoreDatasource#"{
			echo("INSERT INTO jetendo_setup SET jetendo_setup_database_version = '#application.zcore.databaseVersion#', jetendo_setup_updated_datetime='#request.zos.mysqlnow#' ");
		}
		application[request.zos.installPath&":displaySetupScreen"]=true;
		return true;
	}else if(currentVersion EQ application.zcore.databaseVersion){
		return true;
	}else{
		if(not request.zos.isTestServer){
		//	return true; // ignore upgrades for now.
		}
		echo('<h2>Database Upgrade Executed.</h2>');
		newDsStruct={};
		if(fileexists(tempFile)){
			newDsStruct=deserializeJson(replace(application.zcore.functions.zreadfile(tempFile), "zcoreDatasource.", request.zos.zcoreDatasource&".", "ALL"));
			if(newDsStruct.databaseVersion NEQ application.zcore.databaseVersion){
				if(not request.zos.isTestServer){
					echo('Database upgrade aborted during pre-upgrade phase (no changes were made).<br />
						Upgrading the database on a production server requires the schema version to match the source code version.<br />');
					return false;
				}
			}
		}
		if(not verifyDatabaseStructure(tempFile2)){
			return false;
		}
		backupStruct=backupAffectedTablesInVersionRange(currentVersion+1, application.zcore.databaseVersion);
		echo('Upgrading from database version: '&currentVersion&' to '&application.zcore.databaseVersion&'<br />');
		for(i=currentVersion+1;i LTE application.zcore.databaseVersion;i++){
			echo("Executing executeUpgrade() for version #i#<br />");
			upgradeCom=getDatabaseUpgradeComponent(i);
			upgradeCom.datasource=request.zos.zcoreDatasource;
			result=upgradeCom.executeUpgrade(this);
			if(not result){
				echo("Database upgrade aborted during upgrade phase. Changes may have been made.");
				restoreTables(backupStruct);
				return false;
			}else{
				echo('Upgrade scripts completed successfully for version: #i#.<br />');
			}
		}
		curDsStruct={};
		renameStruct={};
		curDSStruct=application.zcore.functions.zGetDatabaseStructure(request.zos.zcoreDatasource, curDSStruct);
		schemaStruct=variables.siteBackupCom.generateSchemaBackup(request.zos.zcoreDatasource, curDSStruct);  
		if(structkeyexists(newDsStruct, 'databaseVersion') and newDsStruct.databaseVersion NEQ application.zcore.databaseVersion){
			writeoutput('Database schema validation can''t be executed post-upgrade because this is a new version of the database on the test server. 
				It is safe to ignore this if you wanted to change the database structure with a newly written upgrade script.<br />');
		}else{
			existingDsStruct=schemaStruct.struct; 
			verifyStruct=runDatabaseUpgrade(request.zos.zcoreDatasource, renameStruct, existingDsStruct, newDsStruct, true);
			if(not verifyStruct.success){
				writeoutput('Database schema validation failed post-upgrade. Changes were made. 
				The upgrade scripts may be broken.  You must verify your installation is still working.');
				echo(" | disk current version: "&newDsStruct.databaseVersion&" | memory version:"&application.zcore.databaseVersion&" | database version: "&application.zcore.functions.zso(curDSStruct, 'databaseVersion'));
				restoreTables(backupStruct);
				writedump(verifyStruct);
				return false;
			}
		}

		query name="qUpdate" datasource="#request.zos.zcoreDatasource#"{
			echo("UPDATE jetendo_setup 
			SET jetendo_setup_database_version = '#application.zcore.databaseVersion#',
			jetendo_setup_updated_datetime='#request.zos.mysqlnow#' ");
		}

		jsonOutput=replace(serializeJson(schemaStruct.struct), request.zos.zcoreDatasource&".", "zcoreDatasource.", "ALL");
		if(not fileexists(newFilePath)){
			application.zcore.functions.zwritefile(newFilePath, jsonOutput);
		}
		application.zcore.functions.zwritefile(tempFile2, jsonOutput);
		
		application.zcore.functions.zUpdateTableColumnCache(application.zcore);

		echo('Database upgrade complete.<br /><br />
			<a href="/z/server-manager/admin/server-home/index">View Server Manager</a> | 
			<a href="/">View Home Page</a>');
		application.zcore.functions.zabort();
	}
	</cfscript>
</cffunction>

<cffunction name="getDatabaseUpgradeComponent" localmode="modern" access="public">
	<cfargument name="version" type="numeric" required="yes">
	<cfscript>
	if(not fileexists(request.zos.installPath&"database-upgrade/newer-versions/db-"&arguments.version&".cfc")){
		if(not fileexists(request.zos.installPath&"database-upgrade/older-versions/db-"&arguments.version&".cfc")){
			throw("No database upgrade CFC exists for version, #arguments.version#, in "&request.zos.installPath&"database-upgrade/");
		}else{
			comPath="jetendo-database-upgrade.older-versions.db-"&arguments.version;
		}
	}else{
		comPath="jetendo-database-upgrade.newer-versions.db-"&arguments.version;
	} 
	return createobject("component", comPath);
	</cfscript>
</cffunction>

<cffunction name="executeQuery" localmode="modern" access="public" returntype="any">
	<cfargument name="datasource" type="string" required="yes">
	<cfargument name="sql" type="string" required="yes">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	db.sql=arguments.sql;  
	try{
		result=db.execute("qExecute", arguments.datasource);
	}catch(Any e){
		echo("Failed to execute query against datasource: "&arguments.datasource&"<br />sql;<br />"&arguments.sql&";<hr />");
		writedump(e);
		result=false;
	}
	if(isBoolean(result) and not result){
		return false;
	}
	echo("executeQuery completed successfully: "&arguments.datasource&"<br />sql;<br />"&arguments.sql&";<hr />");
	return result;
	</cfscript>
</cffunction>

<cffunction name="tableExistsInDatabase" localmode="modern" access="public" returntype="boolean">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	db.sql="SHOW TABLES IN `#arguments.schema#` LIKE '#arguments.table#'";
	qTable=db.execute("qTable", arguments.schema);
	if(qTable.recordcount EQ 0){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="backupAffectedTablesInVersionRange" localmode="modern" access="public" returntype="struct">
	<cfargument name="startVersion" type="numeric" required="yes">
	<cfargument name="endVersion" type="numeric" required="yes">
	<cfscript>
	i=0; 
	backupStruct={};

	for(n=arguments.startVersion;n LTE arguments.endVersion;n++){
		upgradeCom=getDatabaseUpgradeComponent(n);
		upgradeCom.datasource=request.zos.zcoreDatasource;
		arrChanged=upgradeCom.getChangedTableArray();

		for(i=1;i LTE arrayLen(arrChanged);i++){
			if(not structkeyexists(backupStruct, arrChanged[i].schema)){
				backupStruct[arrChanged[i].schema]={};
			}
			if(tableExistsInDatabase(arrChanged[i].schema, arrChanged[i].table)){
				backupTable(arrChanged[i].schema, arrChanged[i].table);
				backupStruct[arrChanged[i].schema][arrChanged[i].table]=true;
			}else{
				backupStruct[arrChanged[i].schema][arrChanged[i].table]=false;
			}
		}
	}
	return backupStruct;
	</cfscript>
</cffunction>


<cffunction name="backupTable" localmode="modern" access="public" returntype="boolean">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfscript>
	echo('Backing up table: #arguments.schema#.#arguments.table#<br />');
	backupPath=request.zos.sharedPath&"database/backup/";
	application.zcore.functions.zcreatedirectory(backupPath);
	try{
		result=application.zcore.functions.zSecureCommand("mysqlDumpTable#chr(9)##arguments.schema##chr(9)##arguments.table#", 200);
	}catch(Any e){
		savecontent variable="output"{
			echo('Failed to backup table: #arguments.schema#.#arguments.table# | 
				zSecureCommand timed out or failed: mysqlDumpTable#chr(9)##arguments.schema##chr(9)##arguments.table#<br />');
			writedump(e);
		}
		throw(output); // prevent further execution
	}
	if(result NEQ "1"){
		throw('Failed to backup table: #arguments.schema#.#arguments.table# | 
			zSecureCommand failed: mysqlDumpTable#chr(9)##arguments.schema##chr(9)##arguments.table#<br />');
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="restoreTable" localmode="modern" access="public" returntype="boolean">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfscript>
	echo('Restoring table: #arguments.schema#.#arguments.table#<br />');
	try{
		result=application.zcore.functions.zSecureCommand("mysqlRestoreTable#chr(9)##arguments.schema##chr(9)##arguments.table#", 200);
	}catch(Any e){
		echo('Failed to restore table: #arguments.schema#.#arguments.table# | 
			zSecureCommand timed out or failed: mysqlRestoreTable#chr(9)##arguments.schema##chr(9)##arguments.table#<br />');
		writedump(e);
		return false;
	}
	if(result EQ "0"){
		echo('Failed to restore table: #arguments.schema#.#arguments.table# | 
			zSecureCommand failed: mysqlRestoreTable#chr(9)##arguments.schema##chr(9)##arguments.table#<br />');
		return false;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="restoreTables" localmode="modern" access="public" returntype="boolean">
	<cfargument name="backupStruct" type="struct" required="yes">
	<cfscript>
	success=true;
	for(schema in arguments.backupStruct){
		for(table in arguments.backupStruct[schema]){
			tableExists=arguments.backupStruct[schema][table];
			if(tableExists){
				try{
					result=restoreTable(schema, table);
				}catch(Any e){
					result=false;
					echo('Failed to restore: #schema#.#table#<br />');
					writedump(e);
				}
				if(not result){
					success=false;
				}else{
					echo('Restored: #schema#.#table#<br />');
				}
			}else{
				query name="qSelect" datasource="#schema#"{
					echo("SHOW TABLES IN `#schema#` LIKE '#application.zcore.functions.zescape(table)#'");
				}
				if(qSelect.recordcount NEQ 0){
					query name="qDrop" datasource="#schema#"{
						echo("DROP TABLE `#schema#`.`#table#`");
					}
				}
				echo('Restoration dropped table that didn''t exist previously: #schema#.#table#<br />');
			}
		}
	}
	if(success){
		echo('<h3>Database restored successfully.</h3>');
	}else{
		echo('<h3>Database may have only been partially restored.  Warning: there may be serious problems.  Verify your installation is still working.</h3>');
	}
	return success;
	</cfscript>
</cffunction>




<cffunction name="importTableData" localmode="modern">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="datasource" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfargument name="columnList" type="string" required="yes">
	<cfargument name="hasSiteId" type="boolean" required="yes">
	<cfscript>
	if(not fileexists(arguments.filePath)){
		throw("importTableData failed because arguments.filePath, ""#arguments.filePath#"", doesn't exist.");
	}
	try{
		if(arguments.hasSiteId){
			query name="qDelete" datasource="#arguments.datasource#"{
				echo(preserveSingleQuotes("delete from `#arguments.datasource#`.`#arguments.table#` 
				where site_id = 0"));
			}
			query name="qDisableTrigger" datasource="#arguments.datasource#"{
				echo(preserveSingleQuotes("set @zDisableTriggers=1"));
			}
		}else{
			query name="qTruncate" datasource="#arguments.datasource#"{
				echo("truncate table `#arguments.datasource#`.`#arguments.table#`");
			}
		}

		query name="qLoadData" datasource="#arguments.datasource#"{
			echo(preserveSingleQuotes("LOAD DATA LOCAL INFILE '#escape(arguments.filePath)#' 
			REPLACE INTO TABLE `#arguments.datasource#`.`#arguments.table#` 
			FIELDS TERMINATED BY ',' ENCLOSED BY '""' 
		 	ESCAPED BY '\\' LINES TERMINATED BY '\n' STARTING BY ''
			IGNORE 1 LINES (#arguments.columnList#)"));
		}
		if(arguments.hasSiteId){
			query name="qEnableTrigger" datasource="#arguments.datasource#"{
				echo(preserveSingleQuotes("set @zDisableTriggers=NULL"));
			}
		}
	}catch(Any e){
		if(arguments.hasSiteId){
			query name="qEnableTrigger" datasource="#arguments.datasource#"{
				echo(preserveSingleQuotes("set @zDisableTriggers=NULL"));
			}
		}
		rethrow;
	}

	</cfscript>
	
</cffunction>


<cffunction name="escape" localmode="modern" returntype="any" output="false">
	<cfargument name="string" type="string" required="yes">
	<cfreturn replace(replace(arguments.string, "\", "\\", "ALL"), "'", "''", "ALL")>
</cffunction>

<cffunction name="dumpTableData" localmode="modern" access="private">
	<cfargument name="filePath" type="string" required="yes">
	<cfargument name="datasource" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfargument name="columnList" type="string" required="yes">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	application.zcore.functions.zdeletefile(arguments.filePath);
	arrC=listToArray(arguments.columnList);
	for(i=1;i LTE arrayLen(arrC);i++){
		arrC[i]="'"&trim(arrC[i])&"'";
	}
	db.sql="SELECT "&arrayToList(arrC, ", ")&"
	UNION ALL
	SELECT #arguments.columnList#
	INTO OUTFILE '#escape(arguments.filePath)#' 
	FIELDS TERMINATED BY ',' ENCLOSED BY '""' 
 	ESCAPED BY '\\' LINES TERMINATED BY '\n' STARTING BY ''  
 	FROM `#arguments.datasource#`.`#arguments.table#` ";
	if(structkeyexists(application.zcore.tablesWithSiteIdStruct, arguments.datasource&"."&arguments.table)){
		db.sql&=" WHERE site_id = '0' ";
	}
	d=db.execute("qSelect", "", 100000, "query", false);
	</cfscript>
	
</cffunction>


<cffunction name="getCreateTableSQL" localmode="modern" access="private">
	<cfargument name="dsStruct" type="struct" required="yes">
	<cfscript>
	arrTableSQL=[];
	datasourceStruct={};
	for(i in arguments.dsStruct.tableStruct){
		arrTemp=listToArray(i, ".");
		if(arrTemp[1] EQ "zcore"){
			arrTemp[1]=request.zos.zcoreDatasource;
		}
		query name="qTables" datasource="#arrTemp[1]#"{
			echo("SHOW TABLES IN `"&arrTemp[1]&"`");
		}
		datasourceStruct[arrTemp[1]]={};
		for(row in qTables){
			table=row["Tables_in_"&arrTemp[1]];
			datasourceStruct[arrTemp[1]][table]=true;
		}
	} 

	for(i in arguments.dsStruct.tableStruct){
		arrTemp=listToArray(i, ".");
		if(arrTemp[1] EQ "zcore"){
			arrTemp[1]=request.zos.zcoreDatasource;
		}
		currentTable=arrTemp[2];
		if(not structkeyexists(datasourceStruct, arrTemp[1]) or structkeyexists(datasourceStruct[arrTemp[1]], arrTemp[2])){
			continue;
		}
		arrSQL=["CREATE TABLE `#arrTemp[1]#`.`#arrTemp[2]#` ("];
		fs=arguments.dsStruct.fieldStruct[i];
		arrKeys=structsort(fs, "numeric", "asc", "columnIndex");
		orderStruct={};
		for(n=1;n LTE arrayLen(arrKeys);n++){
			orderStruct[n]=arrKeys[n];
		}
		for(n=1;n LTE arrayLen(arrKeys);n++){
			field=arrKeys[n];
			if(n NEQ 1){
				arrayAppend(arrSQL, ", ");
			}
			arrayAppend(arrSQL,  "`#field#` "&createColumnSQL(fs[field], orderStruct, false));	
		}
		// build indices here
		for(n in arguments.dsStruct.keyStruct[i]){
			index=", ";
			if(arguments.dsStruct.keyStruct[i][n][1].index_type EQ "FULLTEXT"){
				index&="FULLTEXT KEY `#n#` (";
			}else if(n EQ "PRIMARY"){
				index&="PRIMARY KEY (";
			}else if(arguments.dsStruct.keyStruct[i][n][1].non_unique EQ "0"){
				index&="UNIQUE INDEX `#n#` (";
			}else{
				index&="INDEX `#n#` (";
			}
			for(g=1;g LTE arraylen(arguments.dsStruct.keyStruct[i][n]);g++){
				if(g NEQ 1){
					index&=", ";
				}
				index&="`"&arguments.dsStruct.keyStruct[i][n][g].column_name&"`";
			}
			arrayAppend(arrSQL, index&")");
		}
		
		arrayAppend(arrSQL, ") "&variables.createTableSQL(arguments.dsStruct.tableStruct[i])); 

		tableSQL=arrayToList(arrSQL, " ");
		query name="qCreateTable" datasource="#arrTemp[1]#"{
			echo(preserveSingleQuotes(tableSQL));
		}
	}
	</cfscript>
</cffunction>
	
<cffunction name="getDataTables" localmode="modern" access="private">
	<cfscript>
	dataTables={};
	dataTables["zcoreDatasource"]={
		"site_option": {
			columnList: "site_option_id, site_option_name, site_option_display_name, site_option_default_value, 
			site_option_type_id, site_id, site_option_line_breaks, site_option_edit_enabled, site_option_listing_only, 
			site_option_group_id, site_option_sort, site_option_primary_field, site_option_appidlist, site_option_admin_searchable, 
			site_option_required, site_option_validator_cfc, site_option_validator_method, site_option_url_title_field, 
			site_option_admin_search_default, site_option_admin_sort_field, site_option_allow_public, site_option_hide_label, 
			site_option_tooltip, site_option_public_searchable, site_option_search_summary_field, site_option_enable_search_index, 
			site_option_type_json, site_option_small_width"
		},
		"zemail_template_type": {
			columnList: "zemail_template_type_id,zemail_template_type_name,site_id"
		},
		"zipcode": {
			columnList: "city_name,city_type,state_abbr,country_code,zipcode_type,zipcode_zip,zipcode_latitude,zipcode_longitude"
		},
		"mls": {
			columnList: "mls_id,mls_name,mls_disclaimer_name,mls_mls_id,mls_offset,mls_status,mls_update_date,
			mls_download_date,mls_downloading,mls_frequency,mls_com,mls_skip_bytes,mls_delimiter,mls_csvquote,
			mls_first_line_columns,mls_file,mls_current_file_path,mls_primary_city_id,
			mls_login_url,mls_cleaned_date,mls_error_sent,mls_provider,mls_filelist"
		},
		"zemail_template": {
			columnList: "zemail_template_id, zemail_template_html,zemail_template_text,zemail_template_script, 
			zemail_template_subject,zemail_template_created_datetime,
			zemail_template_type_id,zemail_template_default,zemail_campaign_id,
			zemail_template_active,zemail_template_complete,site_id"
		},
		 "zemail_list": {
			columnList: "zemail_list_id,zemail_list_name,site_id"
		},
		"zemail_folder": {
			columnList: "zemail_folder_id,zemail_folder_name,site_id,user_id"
		},
		"track_convert": {
			columnList: "track_convert_id,track_convert_name,track_convert_display_name"
		},
		"state": {
			columnList: "state_code,state_state"
		
		},
		"inquiries_type": {
			columnList: "inquiries_type_id,inquiries_type_name,inquiries_type_sort,
			inquiries_type_manual,inquiries_type_locked,inquiries_type_realestate,inquiries_type_rentals,site_id"
		},
		"inquiries_status": {
			columnList: "inquiries_status_id,inquiries_status_name"
		},
		"inquiries_lead_template": {
			columnList: "inquiries_lead_template_id,inquiries_lead_template_name,
			inquiries_lead_template_subject,inquiries_lead_template_message,inquiries_lead_template_sort,
			inquiries_lead_template_type,inquiries_lead_template_realestate,site_id"
		},
		"far_feature": {
			columnList: "far_feature_code,far_feature_type,far_feature_description"
		},
		"currency": {
			columnList: "currency_id,currency_code,currency_name,currency_updated_datetime,currency_deleted"
		},
		"country": {
			columnList: "country_name,country_code"
		},
		"content_property_type": {
			columnList: "content_property_type_id, content_property_type_name"
		},
		"city_distance": {
			columnList: "city_parent_id,city_id,city_distance"
		},
		"city": {
			columnList: "city_id,city_mls_id,city_name,state_abbr,country_code,city_county,
			city_has_listings,city_region_id,city_destination_id,city_user_created,city_latitude,city_longitude"
		},
		"app": {
			columnList: "app_id,app_name,app_built_in"
		}
	};
	return dataTables;
	</cfscript>
</cffunction>

<cffunction name="dumpInitialDatabase" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	versionCom=createobject("component", "zcorerootmapping.version");
    ts2=versionCom.getVersion();
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	// dump json file or create sql
	application.zcore.functions.zcreatedirectory(request.zos.sharedPath&"database");
	application.zcore.functions.zcreatedirectory(request.zos.sharedPath&"database/data/");
	curDSStruct={};
	
	curDSStruct=application.zcore.functions.zGetDatabaseStructure(request.zos.zcoreDatasource, curDSStruct);
	siteBackupCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.site-backup");
	schemaStruct=siteBackupCom.generateSchemaBackup(request.zos.zcoreDatasource, curDSStruct);
	schemaString=replace(serializeJson(schemaStruct.struct), request.zos.zcoreDatasource&".", "zcoreDatasource.", "ALL");
	application.zcore.functions.zwritefile(request.zos.sharedPath&"database/jetendo-schema-"&ts2.databaseVersion&".json", schemaString); 
	application.zcore.functions.zwritefile(request.zos.sharedPath&"database/jetendo-schema-current.json", schemaString); 
	// these tables need a key that allows the infile to replace on unique values easily.

	dataTables=getDataTables();
	for(i in dataTables){
		datasource=i;
		datasource2=i;
		if(i EQ "zcoreDatasource"){
			datasource2="zcoreDatasource";
			datasource=request.zos.zcoreDatasource;
		}
		for(n in dataTables[i]){
			filePath=request.zos.sharedPath&"database/data/"&datasource2&"."&n&".csv";
			dumpTableData(filePath, datasource, n, dataTables[datasource2][n].columnList);
		}
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="restoreDataDumps" localmode="modern" access="private">
	<cfscript>
	tablesWithSiteIdStruct={};
	query name="qD" datasource="#request.zos.zcoredatasource#"{
		writeoutput("SELECT concat(TABLE_SCHEMA, '.', TABLE_NAME) `table` 
		FROM information_schema.COLUMNS 
		WHERE COLUMN_NAME = 'site_id' AND 
		TABLE_SCHEMA IN ('#preserveSingleQuotes(request.zos.zcoreDatasource)#') ");
	}
	for(row in qD){
		tablesWithSiteIdStruct[row.table]=true;
	}
	dataTables=getDataTables();
	for(i in dataTables){
		datasource=i;
		datasource2=i;
		if(i EQ "zcoreDatasource"){
			datasource2="zcoreDatasource";
			datasource=request.zos.zcoreDatasource;
		}
		for(n in dataTables[i]){
			filePath=request.zos.sharedPath&"database/data/"&datasource2&"."&n&".csv";
			hasSiteId=structkeyexists(tablesWithSiteIdStruct, datasource&"."&n);
			importTableData(filePath, datasource, n, dataTables[datasource2][n].columnList, hasSiteId);
		}
	}

	</cfscript>
	
</cffunction>

<!--- /z/server-manager/admin/db-upgrade/installDatabaseVersion --->
<cffunction name="installDatabaseVersion" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2>Install Test Database</h2>
	<p>You can use this form to install a second copy of the database for the purpose of testing the database upgrade scripts from version X to the current version where X is the version you select below.</p>
	<form class="zFormCheckDirty" action="/z/server-manager/admin/db-upgrade/processInstallDatabaseVersion" method="post">
		<table class="table-list">
			<tr><th>
		Version:</th><td><cfscript>
		versionCom=createobject("component", "zcorerootmapping.version");
	    ts2=versionCom.getVersion();
	    arrId=[];
		for(i=35;i LTE ts2.databaseVersion;i++){
			arrayAppend(arrId, i);
		}
		ts = StructNew();
		ts.name="version";
		ts.hideSelect=true;
		ts.listLabels=arrayToList(arrId, ",");
		ts.listValues=ts.listLabels;
		ts.output=true;
		application.zcore.functions.zInputSelectBox(ts);
		</cfscript></td>
		</tr>
		<tr><th>Datasource:</th><td>
		<input type="text" name="datasource" value="jetendotest" /> (This must exist as a valid datasource first.)
		</td>
		</tr>
		<tr><th>Action:</th><td>
		<input type="radio" name="action" value="install" checked="checked" /> Install
		<input type="radio" name="action" value="upgrade" /> Upgrade (Warning: No backups are made)
		</td>
		</tr> 
		<tr><th>&nbsp;</th><td>
		<input type="submit" name="submit1" value="Submit" /></td></tr>
		</table>
	</form>

</cffunction>

<cffunction name="processInstallDatabaseVersion" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	form.version=application.zcore.functions.zso(form, 'version', true, 0);
	form.datasource=application.zcore.functions.zso(form, 'datasource');
	form.action=application.zcore.functions.zso(form, 'action');

	if(not request.zos.isTestServer){
		application.zcore.status.setStatus(request.zsid, "This can only be run on the test server.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/db-upgrade/installDatabaseVersion?zsid=#request.zsid#");
	}
	if(form.datasource EQ "" or form.datasource EQ request.zos.zcoreDatasource){
		throw("The datasource must not be the same as request.zos.zcoreDatasource when testing an upgrade from an old version."); 
	}
	if(form.action EQ "upgrade"){
		checkTestVersion(form.datasource, form.version);
		return;
	}
	query name="qCheck" datasource="#form.datasource#"{
		echo("show tables in #form.datasource#");
	}
	if(qCheck.recordcount){
		application.zcore.status.setStatus(request.zsid, "The datasource must be empty before installing.<br />Please manually run:<br />
			drop database #form.datasource#;<br />create database #form.datasource#;", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/db-upgrade/installDatabaseVersion?zsid=#request.zsid#");
	}
	if(form.version LT 35){
		application.zcore.status.setStatus(request.zsid, "The version number must be 35 or higher because previous versions are not supported.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/db-upgrade/installDatabaseVersion?zsid=#request.zsid#");
	}
	tempFile=request.zos.installPath&"share/database/jetendo-schema-#form.version#.json";
	file charset="utf-8" action="read" file="#tempFile#" variable="contents";
	dsStruct=deserializeJson(replace(contents, "zcoreDatasource.", form.datasource&".", "ALL"));
	getCreateTableSQL(dsStruct);
	restoreDataDumps();

	query name="qInsert" datasource="#form.datasource#"{
		echo("INSERT INTO jetendo_setup SET jetendo_setup_database_version = '#form.version#', jetendo_setup_updated_datetime='#request.zos.mysqlnow#' ");
	}

	request.zos.disableVerifyTablesVerify=true;
	verifyCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.verify-tables");
	verifyCom.index(false, form.datasource);

	application.zcore.status.setStatus(request.zsid, "Database installed successfully");
	application.zcore.functions.zRedirect("/z/server-manager/admin/db-upgrade/installDatabaseVersion?zsid=#request.zsid#");
	</cfscript>
</cffunction>



<cffunction name="checkTestVersion" localmode="modern" access="public">
	<cfargument name="datasource" type="string" required="yes">
	<cfargument name="version" type="numeric" required="yes">
	<cfscript>
	versionCom=createobject("component", "zcorerootmapping.version");
    ts2=versionCom.getVersion(); 
	if(not request.zos.isTestServer){
		application.zcore.status.setStatus(request.zsid, "This can only be run on the test server.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/db-upgrade/installDatabaseVersion?zsid=#request.zsid#");
	}
	try{
		query name="qCheck" datasource="#arguments.datasource#"{
			echo("SHOW TABLES IN `#arguments.datasource#` LIKE 'jetendo_setup'");
		}
	}catch(Any e){
		throw("arguments.datasource, ""#arguments.datasource#"", must be a valid datasource.");
	}
	tempFile=request.zos.sharedPath&"database/jetendo-schema-"&ts2.databaseVersion&".json";
	tempFile2=request.zos.sharedPath&"database/jetendo-schema-"&arguments.version&".json";

	if(qCheck.recordcount NEQ 0){
		query name="qVersion" datasource="#arguments.datasource#"{
			echo("SELECT * FROM jetendo_setup LIMIT 0,1");
		}
		if(qVersion.recordcount EQ 0){
			throw("The database is not installed properly.  Please re-install.");
		}else{
			if(qVersion.jetendo_setup_database_version EQ ts2.databaseVersion){
				application.zcore.status.setStatus(request.zsid, "The database is already upgraded to the latest version", form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/db-upgrade/installDatabaseVersion?zsid=#request.zsid#");
			}else if(qVersion.jetendo_setup_database_version GT ts2.databaseVersion){
				application.zcore.status.setStatus(request.zsid, "The database is already upgraded to version that is newer then the source code (version #qVersion.jetendo_setup_database_version#).  Please upgrade the source code before running this again.", form, true);
				application.zcore.functions.zRedirect("/z/server-manager/admin/db-upgrade/installDatabaseVersion?zsid=#request.zsid#");
			}
			currentVersion=qVersion.jetendo_setup_database_version;
		}
	}else{
		application.zcore.status.setStatus(request.zsid, "You must install the test database first.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/db-upgrade/installDatabaseVersion?zsid=#request.zsid#");
	}
	setting requesttimeout="500";
	if(not fileexists(tempFile)){
		tempFile=request.zos.sharedPath&"database/jetendo-schema-"&currentVersion&".json";
		if(not fileexists(tempFile)){
			throw("The current database version's schema json file is missing: "&request.zos.sharedPath&"database/jetendo-schema-"&currentVersion&".json");
		}
	}
	

	newDsStruct=deserializeJson(replace(application.zcore.functions.zreadfile(tempFile), "zcoreDatasource.", arguments.datasource&".", "ALL"));
	if(newDsStruct.databaseVersion NEQ ts2.databaseVersion){
		if(not request.zos.isTestServer){
			echo('Database upgrade aborted during pre-upgrade phase (no changes were made).<br />
				Upgrading the database on a production server requires the schema version to match the source code version.<br />');
			return false;
		}
	}
	if(not verifyDatabaseStructure(tempFile2, arguments.datasource)){
		return false;
	} 
	echo('Upgrading from database version: '&currentVersion&' to '&application.zcore.databaseVersion&'<br />');
	for(i=currentVersion+1;i LTE ts2.databaseVersion;i++){
		echo("Executing executeUpgrade() for version #i#<br />");
		upgradeCom=getDatabaseUpgradeComponent(i);
		upgradeCom.datasource=arguments.datasource;
		result=upgradeCom.executeUpgrade(this);
		if(not result){
			echo("Database upgrade aborted during upgrade phase. Changes may have been made.");
			//restoreTables(backupStruct);
			return false;
		}else{
			echo('Upgrade scripts completed successfully for version: #i#.<br />');
		}
	}
	curDsStruct={};
	renameStruct={};
	curDSStruct=application.zcore.functions.zGetDatabaseStructure(arguments.datasource, curDSStruct);
	schemaStruct=variables.siteBackupCom.generateSchemaBackup(arguments.datasource, curDSStruct); 
	if(newDsStruct.databaseVersion NEQ ts2.databaseVersion){
		writeoutput('Database schema validation can''t be executed post-upgrade because this is a new version of the database on the test server. 
			It is safe to ignore this if you wanted to change the database structure with a newly written upgrade script.<br />');
	}else{
		existingDsStruct=schemaStruct.struct; 
		verifyStruct=runDatabaseUpgrade(arguments.datasource, renameStruct, existingDsStruct, newDsStruct, true);
		if(not verifyStruct.success){
			writeoutput('Database schema validation failed post-upgrade. Changes were made. 
			The upgrade scripts may be broken.  You must verify your installation is still working.');
			echo(" | disk current version: "&newDsStruct.databaseVersion&" | database version: "&application.zcore.functions.zso(curDSStruct, 'databaseVersion')); 
			writedump(verifyStruct);
			return false;
		}
	}

	query name="qUpdate" datasource="#arguments.datasource#"{
		echo("UPDATE jetendo_setup 
		SET jetendo_setup_database_version = '#ts2.databaseVersion#',
		jetendo_setup_updated_datetime='#request.zos.mysqlnow#' ");
	}
	echo("Database upgrade complete.");
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>


<cffunction name="installInitialDatabase" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	versionCom=createobject("component", "zcorerootmapping.version");
    ts2=versionCom.getVersion();
    application.zcore.databaseVersion=ts2.databaseVersion;
    if(structkeyexists(application.zcore, 'adminSecurityFilter')){
		application.zcore.user.requireAllCompanyAccess();
		application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	}
	tempFile=request.zos.installPath&"share/database/jetendo-schema-#application.zcore.databaseVersion#.json";
	file charset="utf-8" action="read" file="#tempFile#" variable="contents";
	dsStruct=deserializeJson(replace(contents, "zcoreDatasource.", request.zos.zcoreDatasource&".", "ALL"));
	getCreateTableSQL(dsStruct);
	restoreDataDumps();


	</cfscript>
</cffunction>

<!--- it would be more efficient to track the tables in schema that will be changed, and then only dump/restore those. --->
<cffunction name="dumpTables" localmode="modern" access="public">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="arrTable" type="array" required="yes">
	<cfargument name="arrDropTable" type="array" required="yes">
	<cfscript>
	var db=this.getDbObject(arguments.schema);
	var i=0;
	var table=0;
	var row=0;
	arrSQL=[]; 
	application.zcore.functions.zcreatedirectory("#request.zos.backupDirectory#upgrade");
	application.zcore.functions.zdeletedirectory(variables.databaseBackupPath);
	application.zcore.functions.zcreatedirectory(variables.databaseBackupPath);
	
	db.sql="SHOW TABLES IN `#arguments.schema#`";
	qTables=db.execute("qTables");
	tableExistsStruct={};
	for(row in qTables){
		tableExistsStruct[row["Tables_in_#arguments.schema#"]]=true;
	}
	for(i=1;i LTE arraylen(arguments.arrDropTable);i++){
	 	table=arguments.arrDropTable[i];
		arrayAppend(arrSQL, 'DROP TABLE IF EXISTS `#table#`');
	}
	for(i=1;i LTE arraylen(arguments.arrTable);i++){
	 	table=arguments.arrTable[i];
		if(structkeyexists(tableExistsStruct, table)){
			db.sql="SHOW CREATE TABLE `#arguments.schema#`.`#table#`";
			qCreate=db.execute("qCreate");
			arrayAppend(arrSQL, 'DROP TABLE IF EXISTS `#table#`');
			for(row in qCreate){
				arrayAppend(arrSQL, replace(replace(row['Create Table'], chr(10), ' ', 'all'), chr(13), '', 'all'));
			}
			db.sql="SHOW TRIGGERS FROM `#arguments.schema#`";
			qTrigger=db.execute("qTrigger");
			for(row in qTrigger){
				if(row.table EQ table){
					curTrigger=variables.siteBackupCom.getCreateTriggerSQLFromStruct(arguments.schema, row);
					arrayAppend(arrSQL, replace(replace(curTrigger.dropTriggerSQL, chr(10), ' ', 'all'), chr(13), '', 'all'));
					arrayAppend(arrSQL, replace(replace(curTrigger.createTriggerSQL, chr(10), ' ', 'all'), chr(13), '', 'all'));  
				}
			} 
			mysqlTsvPath="#variables.mysqlDatabaseBackupPath##arguments.schema#-#application.zcore.functions.zURLEncode(table,"-")#-data-backup.tsv";
			tsvPath="#variables.databaseBackupPath##arguments.schema#-#application.zcore.functions.zURLEncode(table,"-")#-data-backup.tsv";
			db.sql="select * from `#table#` 
			INTO OUTFILE '#mysqlTsvPath#'
			#variables.outfileOptions#";
			result=db.execute("qOutfile");
			if(not fileexists(tsvPath)){
				throw("Failed to backup `#arguments.schema#`.`#table#`", "Exception");
			}
			arrayAppend(arrSQL, replace(replace("LOAD DATA LOCAL INFILE '#mysqlTsvPath#' 
			REPLACE INTO TABLE `#arguments.schema#`.`#table#` 
			#variables.outfileOptions#", chr(10), ' ', 'all'), chr(13), '', 'all'));
		}
	}
	application.zcore.functions.zwritefile("#variables.databaseBackupPath##arguments.schema#-schema-backup.sql", arrayToList(arrSQL, chr(10)));  
	</cfscript>
</cffunction>

<cffunction name="getDbObject" localmode="modern" access="public">
	<cfargument name="schema" type="string" required="yes">
	<cfscript>
	var dbInitConfigStruct={ 
		datasource:arguments.schema,
		verifyQueriesEnabled:false,
		autoReset:false, 
		cacheEnabled:false
	}
	return application.zcore.db.newQuery(dbInitConfigStruct); 
	</cfscript>
</cffunction>

	
<cffunction name="runDatabaseUpgrade" localmode="modern" access="public">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="renameStruct" type="struct" required="yes">
	<cfargument name="existingDsStruct" type="struct" required="yes">
	<cfargument name="newDsStruct" type="struct" required="yes">
	<cfargument name="verifyStructureOnly" type="boolean" required="yes">
	<cfscript> 
	var i=0;
	changedTableStruct={};
	newTableStruct={};
	arrDiff=this.getDatabaseDiffAsSQLArray(arguments.schema, changedTableStruct, newTableStruct, arguments.renameStruct, arguments.existingDsStruct, arguments.newDsStruct, arguments.verifyStructureOnly);
	if(arguments.verifyStructureOnly){
		writeoutput('Structure comparison executed.<br />');
		if(arrayLen(arrDiff)){
			success=false;
			writeoutput('The following SQL changes were generated.<hr />');
			for(i=1;i LTE arraylen(arrDiff);i++){
				echo(arrDiff[i]&"; <hr />");
			}
		}else{
			success=true;
			writeoutput('No database changes were detected.<br />');
		}
		return {success:success, arrDiff:arrDiff};
	}
	if(arraylen(arrDiff)){
		// backup tables
		this.dumpTables(arguments.schema, structKeyArray(changedTableStruct), structKeyArray(newTableStruct));
	}
	return {success:true, arrDiff:arrDiff, changedTableStruct: changedTableStruct};
	</cfscript>
</cffunction>

<cffunction name="getDatabaseDiffAsSQLArray" localmode="modern" access="public">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="changedTableStruct" type="struct" required="yes">
	<cfargument name="newTableStruct" type="struct" required="yes">
	<cfargument name="renameStruct" type="struct" required="yes">
	<cfargument name="existingDsStruct" type="struct" required="yes">
	<cfargument name="newDsStruct" type="struct" required="yes">
	<cfargument name="verifyStructureOnly" type="boolean" required="yes">
	<cfscript>
	var i=0;
	var n=0;
	var g=0;
	rs={}; 
	rs.arrSQL=[];
	rs.arrSQL=this.generateRenameSQL(arguments.schema, arguments.changedTableStruct, arguments.newTableStruct, rs.arrSQL, arguments.existingDsStruct, arguments.newDsStruct, arguments.renameStruct, arguments.verifyStructureOnly);  
	 
	for(i in arguments.existingDsStruct.tableStruct){
		if(not structkeyexists(arguments.newDsStruct.tableStruct, i)){
			arrTemp=listToArray(i, ".");
			currentTable=arrTemp[2];
			if(structkeyexists(application.zcore.verifyTablesExcludeStruct, arguments.schema) and structkeyexists(application.zcore.verifyTablesExcludeStruct[arguments.schema], currentTable)){ 
				continue; // skip tables that have their own primary key generation method
			}
			arguments.changedTableStruct[currentTable]=true;
			arrayAppend(rs.arrSQL, "DROP TABLE `#replace(i, ".", "`.`")#`");
		}
	}
	siteBackupCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.tasks.controller.site-backup");
	excludeTableStruct=siteBackupCom.getExcludedTableStruct();
	for(i in arguments.newDsStruct.tableStruct){
		arrTemp=listToArray(i, ".");
		currentTable=arrTemp[2];
		if(structkeyexists(application.zcore.verifyTablesExcludeStruct, arguments.schema) and structkeyexists(application.zcore.verifyTablesExcludeStruct[arguments.schema], currentTable)){ 
			continue; // skip tables that have their own primary key generation method
		}
		if(structkeyexists(excludeTableStruct, currentTable)){
			continue;
		}	
		if(not structkeyexists(arguments.existingDsStruct.tableStruct, i)){
			arrSQL=["CREATE TABLE `#replace(i, ".", "`.`")#` ("];
			fs=arguments.newDsStruct.fieldStruct[i];
			arrKeys=structsort(fs, "numeric", "asc", "columnIndex");
			orderStruct={};
			for(n=1;n LTE arrayLen(arrKeys);n++){
				orderStruct[n]=arrKeys[n];
			}
			for(n=1;n LTE arrayLen(arrKeys);n++){
				field=arrKeys[n];
				if(n NEQ 1){
					arrayAppend(arrSQL, ", ");
				}
				arrayAppend(arrSQL,  "`#field#` "&createColumnSQL(fs[field], orderStruct, false));	
			}
			// build indices here
			for(n in arguments.newDsStruct.keyStruct[i]){
				index=", ";
				if(n EQ "PRIMARY"){
					index&="PRIMARY KEY (";
				}else if(arguments.newDsStruct.keyStruct[i][n][1].non_unique EQ "0"){
					index&="UNIQUE INDEX `#n#` (";
				}else{
					index&="INDEX `#n#` (";
				}
				for(g=1;g LTE arraylen(arguments.newDsStruct.keyStruct[i][n]);g++){
					if(g NEQ 1){
						index&=", ";
					}
					index&="`"&arguments.newDsStruct.keyStruct[i][n][g].column_name&"`";
				}
				arrayAppend(arrSQL, index&")");
			}
			
			arrayAppend(arrSQL, ") "&variables.createTableSQL(arguments.newDsStruct.tableStruct[i])); 
			arrayAppend(rs.arrSQL, arrayToList(arrSQL, " ")); 
		}else{
			// check if I should alter table
			alterEnabled=false;
			alterColumnStruct=getTableDiffAsSQL(arguments.existingDsStruct.fieldStruct[i], arguments.newDsStruct.fieldStruct[i]);
			arrAlterColumns=[];
			if(structcount(alterColumnStruct)){
				arrKey=structkeyarray(alterColumnStruct);
				arraySort(arrKey, "numeric", "asc");
				for(i2=1;i2 LTE arraylen(arrKey);i2++){
					arrayAppend(arrAlterColumns, alterColumnStruct[arrKey[i2]]);
				}
			}
			for(n in arguments.existingDsStruct.keyStruct[i]){
				if(not structkeyexists(arguments.newDsStruct.keyStruct[i], n)){
					arrayAppend(arrAlterColumns, "DROP INDEX `"&n&"`");
				}
			}
			for(n in arguments.newDsStruct.keyStruct[i]){
				if(not structkeyexists(arguments.existingDsStruct.keyStruct[i], n)){
					// add index
					index="";
					if(n EQ "PRIMARY"){
						index&="ADD PRIMARY KEY (";
					}else if(arguments.newDsStruct.keyStruct[i][n][1].non_unique EQ "0"){
						index&="ADD UNIQUE INDEX `#n#` (";
					}else{
						index&="ADD INDEX `#n#` (";
					}
					for(g=1;g LTE arraylen(arguments.newDsStruct.keyStruct[i][n]);g++){
						if(g NEQ 1){
							index&=", ";
						}
						index&="`"&arguments.newDsStruct.keyStruct[i][n][g].column_name&"`";
					}
					arrayAppend(arrAlterColumns, index&")");
				}else{
					// CHANGED: drop and add new index
					index="";
					if(n EQ "PRIMARY"){
						index&="DROP PRIMARY KEY, ADD PRIMARY KEY (";
					}else{
						if(arguments.newDsStruct.keyStruct[i][n][1].non_unique EQ "0"){
							index&="DROP INDEX `#n#`, ADD UNIQUE INDEX `#n#` (";
						}else{
							index&="DROP INDEX `#n#`, ADD INDEX `#n#` (";
						}
					}
					for(g=1;g LTE arraylen(arguments.newDsStruct.keyStruct[i][n]);g++){
						if(g NEQ 1){
							index&=", ";
						}
						index&="`"&arguments.newDsStruct.keyStruct[i][n][g].column_name&"`";
					}
					newIndex=index&")"
					index="";
					if(n EQ "PRIMARY"){
						index&="DROP PRIMARY KEY, ADD PRIMARY KEY (";
					}else{
						if(arguments.existingDsStruct.keyStruct[i][n][1].non_unique EQ "0"){
							index&="DROP INDEX `#n#`, ADD UNIQUE INDEX `#n#` (";
						}else{
							index&="DROP INDEX `#n#`, ADD INDEX `#n#` (";
						}
					}
					for(g=1;g LTE arraylen(arguments.existingDsStruct.keyStruct[i][n]);g++){
						if(g NEQ 1){
							index&=", ";
						}
						index&="`"&arguments.existingDsStruct.keyStruct[i][n][g].column_name&"`";
					}
					oldIndex=index&")";
					if(newIndex NEQ oldIndex){
						arrayAppend(arrAlterColumns, newIndex);
					}
				}
			}
			if(arrayLen(arrAlterColumns)){
				alterEnabled=true;
			}
			for(n in arguments.newDsStruct.tableStruct[i]){
				if(arguments.existingDsStruct.tableStruct[i][n] NEQ arguments.newDsStruct.tableStruct[i][n]){ 
					alterEnabled=true;
					break;
				}
			}
			if(alterEnabled){
				arguments.changedTableStruct[currentTable]=true;
				comma=" ";
				if(arrayLen(arrAlterColumns)){
					//echo('Previous table: '&currentTable&'<hr />');
					comma=", ";
				}
				arrayAppend(rs.arrSQL, "ALTER TABLE `#replace(i, ".", "`.`")#` "&arrayToList(arrAlterColumns, ", ")&comma&variables.createTableSQL(arguments.newDsStruct.tableStruct[i]));
			}
		}
	} 
	return rs.arrSQL;
	</cfscript>
</cffunction>
 


<cffunction name="createColumnSQL" localmode="modern" access="private">
	<cfargument name="columnStruct" type="struct" required="yes">
	<cfargument name="orderStruct" type="struct" required="yes">
	<cfargument name="enableAfter" type="boolean" required="no" default="#true#">
	<cfscript>
	column=arguments.columnStruct.type;
	if(arguments.columnStruct.null EQ "NO"){
		column&=" NOT NULL";
	}else{
		column&=" NULL";
	}
	if(arguments.columnStruct.default NEQ ""){
		if(isNumeric(arguments.columnStruct.default)){
			column&=" DEFAULT "&arguments.columnStruct.default;
		}else{
			column&=" DEFAULT '"&escape(arguments.columnStruct.default)&"'";
		}
	}
	if(arguments.columnStruct.extra NEQ ""){
		column&=" "&arguments.columnStruct.extra;
	}
	if(arguments.enableAfter){
		if(arguments.columnStruct.columnIndex-1 LT 1){
			column&=" FIRST";
		}else{ 
			column&=" AFTER `"&arguments.orderStruct[arguments.columnStruct.columnIndex-1]&"`";
		}
	}
	return column;
	</cfscript>
</cffunction>

<cffunction name="getTableDiffAsSQL" localmode="modern" access="private" returntype="struct">
	<cfargument name="oldTable" type="struct" required="yes">
	<cfargument name="newTable" type="struct" required="yes">
	<cfscript>
	columnStruct={};
	newOrderStruct={};
	for(i in arguments.newTable){
		newOrderStruct[arguments.newTable[i].columnIndex]=i;
	}
	dropIndex=10000;
	for(i in arguments.newTable){
		// find columns missing in new table, that exist in old table
		if(not structkeyexists(arguments.oldTable, i)){
			columnStruct[arguments.newTable[i].columnIndex]="ADD COLUMN `#i#` "&variables.createColumnSQL(arguments.newTable[i], newOrderStruct);
		}
	}
	for(i in arguments.oldTable){
		// find columns missing in new table, that exist in old table
		if(not structkeyexists(arguments.newTable, i)){
			columnStruct[dropIndex]="DROP COLUMN `#i#`";
			dropIndex++;
			continue;
		}
		// detect columns that have changed
		for(n in arguments.oldTable[i]){
			if(not structkeyexists(arguments.newTable[i], n)){
				arguments.newTable[i][n]="";
			}
			if(arguments.oldTable[i][n] NEQ arguments.newTable[i][n]){
				if(structkeyexists(form, 'zdebug')){
					writeoutput("Column struct is different: "&i&" for attribute '"&n&"' old:"&arguments.oldTable[i][n]&" new: "&arguments.newTable[i][n]&"<br>");
				}
				changeOrder=false;
				if(arguments.oldTable[i].columnIndex NEQ arguments.newTable[i].columnIndex){
					//writeoutput("Column order is different: "&i&":"&arguments.oldTable[i].columnIndex&" NEQ "&arguments.newTable[i].columnIndex&"<br>");
					changeOrder=true;
				}
				columnStruct[arguments.newTable[i].columnIndex]="CHANGE COLUMN `#i#` `#i#` "&variables.createColumnSQL(arguments.newTable[i], newOrderStruct, changeOrder);
				break;
			}
		} 
	}
	return columnStruct;
	</cfscript>
</cffunction>


	
<cffunction name="generateRenameSQL" localmode="modern" access="public" returntype="array">  
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="changedTableStruct" type="struct" required="yes">
	<cfargument name="newTableStruct" type="struct" required="yes">
	<cfargument name="arrSQL" type="array" required="yes">
	<cfargument name="existingTableStruct" type="struct" required="yes">
	<cfargument name="newTableStruct" type="struct" required="yes">
	<cfargument name="renameStruct" type="struct" required="yes"> 
	<cfscript>
	var schema=0;
	var table=0;
	var column=0;
	var i=0;
	var arrAlter=0;
	var newColumnName=0; 
	var columnDefinition=0;  
	var arrKey=structkeyarray(arguments.existingTableStruct);
	if(structkeyexists(arguments.renameStruct, arguments.schema)){
		for(table in arguments.renameStruct[arguments.schema]){
			if(structkeyexists(arguments.renameStruct[arguments.schema][table], 'renameColumnStruct') and structcount(arguments.renameStruct[arguments.schema][table].renameColumnStruct)){
				arrAlter=[];
				c=arguments.renameStruct[arguments.schema][table].renameColumnStruct;
				for(column in c){
					newColumnName=c[column];
					newTableName=table;
					if(structkeyexists(arguments.renameStruct[arguments.schema][table], 'renameTable')){
						// take on the new table's column structure during the rename field operation to reduce redundant work
						newTableName=arguments.renameStruct[arguments.schema][table].renameTable;
					}
					columnDefinition=this.createColumnSQL(arguments.newTableStruct.fieldStruct[arguments.schema&"."&newTableName][newColumnName], {}, false);
					
					// rename column in the tableStruct so verifyStructure operates on the renamed data
					
					arguments.existingTableStruct.fieldStruct[arguments.schema&"."&table][newColumnName]=arguments.newTableStruct.fieldStruct[arguments.schema&"."&newTableName][newColumnName];
					structdelete(arguments.existingTableStruct.fieldStruct[arguments.schema&"."&table], column);
					
					
					arrayAppend(arrAlter, 'CHANGE `#column#` `#newColumnName#`  #columnDefinition#');
				}
				arguments.changedTableStruct[table]=true;
				arrayAppend(arguments.arrSQL, 'ALTER TABLE `#arguments.schema#`.`#table#` '&arrayToList(arrAlter, ', '));
			}
			if(structkeyexists(arguments.renameStruct[arguments.schema][table], 'renameTable')){
				arrayAppend(arguments.arrSQL, 'rename table `#arguments.schema#`.`#table#` to `#arguments.schema#`.`#arguments.renameStruct[arguments.schema][table].renameTable#` '); 
				
				arguments.newTableStruct[arguments.renameStruct[arguments.schema][table].renameTable]=true;
				// rename table in the tableStruct so verifyStructure operates on the renamed data
				newSchemaTableName=arguments.schema&"."&arguments.renameStruct[arguments.schema][table].renameTable;
				for(i=1;i LTE arraylen(arrKey);i++){
					if(structkeyexists(arguments.existingTableStruct[arrKey[i]], arguments.schema&"."&table)){
						arguments.existingTableStruct[arrKey[i]][newSchemaTableName]=arguments.existingTableStruct[arrKey[i]][arguments.schema&"."&table]; 
						structdelete(arguments.existingTableStruct[arrKey[i]], arguments.schema&"."&table); 
					}
				}  
			}
		}
	}  
	return arguments.arrSQL;
	</cfscript>
</cffunction>		


<cffunction name="createTableSQL" localmode="modern" access="private">
	<cfargument name="tableStruct" type="struct" required="yes">
	<cfscript>
	tableSQL="ENGINE=#arguments.tableStruct.engine#, CHARSET=#arguments.tableStruct.charset#, COLLATE=#arguments.tableStruct.collation#";
	if(arguments.tableStruct.create_options NEQ ""){
		tableSQL&=", "&arguments.tableStruct.create_options;
	}
	return tableSQL;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>