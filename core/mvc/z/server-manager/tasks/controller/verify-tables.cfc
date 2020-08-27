<cfcomponent>
	<cffunction name="index" localmode="modern" access="remote">
		<cfargument name="returnErrors" type="boolean" required="false" default="#false#">
		<cfargument name="datasource" type="string" required="false" default="">
		<cfscript>
		var i=0;
		var q=0;
		var row=0;
		var arrError=[];
		var db=request.zos.noVerifyQueryObject;
		var fieldRow=0;
		var qTable=0;
		var curStatement=0;
		var qKey=0;
		var keyRow=0;
		var debug=false;
		if(arguments.datasource EQ ""){
			arguments.datasource=request.zos.zcoreDatasource;
		}
		application.zcore.functions.checkIfCronJobAllowed();
		 
		setting requesttimeout="3000";
		//for(i=1;i LTE arraylen(application.zcore.arrGlobalDatasources);i++){
			//local.curDatasource=application.zcore.arrGlobalDatasources[i];
			local.curDatasource=arguments.datasource;
			local.c=application.zcore.db.getConfig();
			local.c.autoReset=false;
			local.c.datasource=local.curDatasource;
			local.c.verifyQueriesEnabled=false;
			db=application.zcore.db.newQuery(local.c);
			db.sql="SHOW TABLES IN `#local.curDatasource#`";
			qTable=db.execute("qTable");
			for(row in qTable){
				local.curTableName=row["Tables_in_"&local.curDatasource];
				local.curTable=local.curDatasource&"."&local.curTableName;
				if(structkeyexists(application.zcore.verifyTablesExcludeStruct, local.curDatasource) and structkeyexists(application.zcore.verifyTablesExcludeStruct[local.curDatasource], local.curTableName)){ 
					continue; // skip tables that have their own primary key generation method
				}
				db.sql="show fields from `"&local.curDatasource&"`.`"&local.curTableName&"`";
				local.qFields=db.execute("qFields");
				local.siteIdFound=false;
				local.primaryIdFound=false;
				local.siteIdKeyFound=false;
				local.primaryIdKeyFound=false;
				local.autoIncrementFound=false;
				local.autoIncrementFixSQL="";
				if(structkeyexists(application.zcore.primaryKeyMapStruct, local.curTable)){
					local.curPrimaryKeyId=application.zcore.primaryKeyMapStruct[local.curTable];
					//writeoutput('map found:'&local.curPrimaryKeyId&"<br>");
				}else{
					local.curPrimaryKeyId="#local.curTableName#_id";
				}
				for(fieldRow in local.qFields){
					if(fieldRow.extra CONTAINS "auto_increment"){
						local.autoIncrementFixSQL="CHANGE `#fieldRow.field#` `#fieldRow.field#` INT(11) UNSIGNED  NOT NULL AUTO_INCREMENT";
						local.autoIncrementFound=true;
					}
					if(fieldRow.field EQ "site_id"){
						local.siteIdFound=true;
						if(fieldRow.key EQ "PRI"){
							local.siteIdKeyFound=true;
						}
					}else if(fieldRow.field EQ local.curPrimaryKeyId){
						local.primaryIdFound=true;
						if(fieldRow.key EQ "PRI"){
							local.primaryIdKeyFound=true;
						}
					}
				}
				if(local.siteIdFound){
					db.sql="SHOW KEYS FROM `"&local.curDatasource&"`.`"&local.curTableName&"`";
					qKey=db.execute("qKey");
					local.uniqueStruct=structnew();
					nonUniqueKeys={};
					for(keyRow in qKey){
						if(keyRow.non_unique EQ 1){
							if(not structkeyexists(local.uniqueStruct, keyRow.key_name)){
								nonUniqueKeys[keyRow.key_name]=structnew();
							}
							nonUniqueKeys[keyRow.key_name][keyRow.column_name]=true;
						}
						if(keyRow.non_unique EQ 0 and keyRow.key_name NEQ "primary"){
							if(not structkeyexists(local.uniqueStruct, keyRow.key_name)){
								local.uniqueStruct[keyRow.key_name]=structnew();
							}
							local.uniqueStruct[keyRow.key_name][keyRow.column_name]=true;
						}
					}
					foundTableIdKey=false;
					for(keyName in nonUniqueKeys){
						if(structcount(nonUniqueKeys[keyName]) EQ 1){
							for(columnName in nonUniqueKeys[keyName]){
								if(columnName EQ local.curPrimaryKeyId){
									foundTableIdKey=true;
								}
							}
						}
					}
					for(local.k IN local.uniqueStruct){
						local.siteIdFoundForKey=false;
						for(local.k2 IN local.uniqueStruct[local.k]){
							if(local.k2 EQ "site_id"){
								local.siteIdFoundForKey=true;
							}
						}
						if(not local.siteIdFoundForKey){
							local.uniqueStruct[local.k].site_id=true;
							db.sql="ALTER TABLE `"&local.curDatasource&"`.`"&local.curTableName&"` 
							DROP INDEX `"&local.k&"`, 
							ADD UNIQUE INDEX `"&local.k&"` (`"&structkeylist(local.uniqueStruct[local.k], "`, `")&"`)";
							//writeoutput(db.sql&"<hr />");
							if(not debug) db.execute("qCreateUniqueKey");
							arrayAppend(arrError, local.curDatasource&"."&local.curTableName&" didn't contain the site_id column in the unique key index and this has been auto-corrected.");
						}
					}
					if(local.curTableName EQ "site" and local.curDatasource EQ request.zos.zcoreDatasource){
						continue; // ignore the site table
					}
					if(not local.primaryIdFound){
						arrayAppend(arrError, "The #local.curTable#  table may not be following the naming convention of ""tableName"" + ""_id"" for it's unique key field and this MUST be manually corrected by changing the table or adding an exception to the application.zcore.primaryKeyMapStruct struct.");
						continue;
					}
					if(not local.primaryIdKeyFound and not local.siteIdKeyFound){
						// compound primary key index must be created
						if(local.autoIncrementFound){
							local.autoIncrementFixSQL&=", ";
						}
						db.sql="ALTER TABLE `"&local.curDatasource&"`.`"&local.curTableName&"` 
						#local.autoIncrementFixSQL#
						DROP PRIMARY KEY, 
						ADD PRIMARY KEY (`site_id`, `#local.curPrimaryKeyId#`)";
						if(not debug) db.execute("qCreatePrimaryKey");
						arrayAppend(arrError, local.curDatasource&"."&local.curTableName&" didn't contain a primary key index and this has been auto-corrected.");
					}else if(not local.siteIdKeyFound){
						if(local.autoIncrementFound){
							local.autoIncrementFixSQL&=", ";
						}
						// delete primary key, and recreate as compound primary key	
						db.sql="ALTER TABLE `"&local.curDatasource&"`.`"&local.curTableName&"` 
						#local.autoIncrementFixSQL#
						DROP PRIMARY KEY, 
						ADD PRIMARY KEY (`site_id`, `#local.curPrimaryKeyId#`)";
						if(not debug) db.execute("qRecreatePrimaryKey");
						arrayAppend(arrError, local.curDatasource&"."&local.curTableName&" didn't contain a site_id column in the primary key index and this has been auto-corrected.");
					}else if(not local.autoIncrementFound){
						keyString="";
						if(not foundTableIdKey){
							keyString=", ADD KEY(`#local.curPrimaryKeyId#`)";
						}
						// arrayAppend(arrError, "ALTER TABLE`"&local.curDatasource&"`.`"&local.curTableName&"` 
						// CHANGE `#local.curPrimaryKeyId#` `#local.curPrimaryKeyId#` INT(11) UNSIGNED  NOT NULL AUTO_INCREMENT #keyString#;");
						db.sql="ALTER TABLE`"&local.curDatasource&"`.`"&local.curTableName&"` 
						CHANGE `#local.curPrimaryKeyId#` `#local.curPrimaryKeyId#` INT(11) UNSIGNED  NOT NULL AUTO_INCREMENT #keyString#;";
						if(not debug) db.execute("qFix");
					}
					db.sql="DROP TRIGGER IF EXISTS `"&local.curTableName&"_auto_inc`";
					if(not debug) db.execute("qDropTrigger");
					
				}
			}
			//break;
		//}

		if(not structkeyexists(request.zos, 'disableVerifyTablesVerify')){
			tempFile2=request.zos.sharedPath&"database/jetendo-schema-current.json";
			dbUpgradeCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.db-upgrade");
			if(not dbUpgradeCom.verifyDatabaseStructure(tempFile2, arguments.datasource)){
				arrayAppend(arrError, "<hr />Database schema didn't match source code schema file: #tempFile2#.  
					This is a serious problem that must be manually fixed before performing an upgrade. 
					The queries to run to fix the schema were generated above.<br />");
			}
			if(request.zos.isDeveloper){
				if(arraylen(arrError)){
					writeoutput('<h2>The following errors were detected with the database table structure.</h2><ul>');
					for(i=1;i LTE arraylen(arrError);i++){
						writeoutput('<li>'&arrError[i]&"</li>");
					}
					writeoutput('</ul>');
				}else{
					writeoutput('All tables verified successfully');
				}
				if(not arguments.returnErrors){
					application.zcore.functions.zabort();
				}
			}
			if(arguments.returnErrors){
				return arrError;
			}
		}
		</cfscript>
	</cffunction>


</cfcomponent>