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
		var triggerRow=0;
		var fieldRow=0;
		var qTable=0;
		var qTrigger=0;
		var curStatement=0;
		var qKey=0;
		var keyRow=0;
		var debug=false;
		if(arguments.datasource EQ ""){
			arguments.datasource=request.zos.zcoreDatasource;
		}

		if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
			application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
		}
		
		// var triggerTemplate="BEGIN    
		// 	IF (NEW.`##keyName##` > 0) THEN
		// 		SET @zLastInsertId = NEW.`##keyName##`;
		// 	ELSE
		// 		SET @zLastInsertId=(
		// 				SELECT IFNULL(
		// 				(MAX(`##keyName##`) - (MAX(`##keyName##`) MOD @@auto_increment_increment))+@@auto_increment_increment+(@@auto_increment_offset-1), @@auto_increment_offset)  
		// 				FROM `##tableName##` 
		// 				WHERE `##tableName##`.site_id = NEW.site_id
		// 			);
		// 		SET NEW.`##keyName##`=@zLastInsertId;
		// 	END IF;
		// END";
		var triggerTemplate="BEGIN    
		IF (NEW.`##keyName##` > 0) THEN
			SET @zLastInsertId = NEW.`##keyName##`;
		ELSE 
			SET @zLastInsertId=(
				SELECT table_increment_table_id 
				FROM `#request.zos.zcoreDatasource#`.`table_increment` 
				WHERE `table_increment`.site_id = NEW.site_id and 
				table_increment_table = '##tableName##' FOR UPDATE
			) ;
			IF (@zLastInsertId IS NULL) THEN
				INSERT INTO `table_increment` (site_id, table_increment_table, table_increment_table_id) SELECT 
				NEW.site_id, 
				'##tableName##', 
				IFNULL(MAX(`##keyName##`), 0)  as value
				FROM `##tableName##` 
				WHERE `##tableName##`.site_id = NEW.site_id;
				SET @zLastInsertId=(
					SELECT table_increment_table_id
					FROM `#request.zos.zcoreDatasource#`.`table_increment` 
					WHERE `table_increment`.site_id = NEW.site_id and 
					table_increment_table = '##tableName##' FOR UPDATE
				) ; 
			END IF;
			SET @zLastInsertId=(@zLastInsertId - (@zLastInsertId MOD @@auto_increment_increment))+@@auto_increment_increment+(@@auto_increment_offset-1);
			UPDATE `#request.zos.zcoreDatasource#`.`table_increment` SET table_increment_table_id=@zLastInsertId 
			WHERE `table_increment`.site_id = NEW.site_id and 
			table_increment_table = '##tableName##';
			SET NEW.`##keyName##`=@zLastInsertId;
		END IF; 
		END";
		setting requesttimeout="3000";
		triggerTemplate=rereplace(triggerTemplate, "\s+", "", "all");

		//writeoutput(triggerTemplate);
		//for(i=1;i LTE arraylen(application.zcore.arrGlobalDatasources);i++){
			//local.curDatasource=application.zcore.arrGlobalDatasources[i];
			local.curDatasource=arguments.datasource;
			local.c=application.zcore.db.getConfig();
			local.c.autoReset=false;
			local.c.datasource=local.curDatasource;
			local.c.verifyQueriesEnabled=false;
			db=application.zcore.db.newQuery(local.c);
			db.sql="SHOW TRIGGERS FROM `#local.curDatasource#`";
			qTrigger=db.execute("qTrigger");
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
						local.autoIncrementFixSQL="CHANGE `#fieldRow.field#` `#fieldRow.field#` INT(11) UNSIGNED DEFAULT 0  NOT NULL";
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
					for(keyRow in qKey){
						if(keyRow.non_unique EQ 0 and keyRow.key_name NEQ "primary"){
							if(not structkeyexists(local.uniqueStruct, keyRow.key_name)){
								local.uniqueStruct[keyRow.key_name]=structnew();
							}
							local.uniqueStruct[keyRow.key_name][keyRow.column_name]=true;
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
						
					if(local.autoIncrementFound){
						arrayAppend(arrError, local.curDatasource&"."&local.curTableName&" had auto_increment enabled for the primary key index and it shouldn't have in this table because the trigger increments it based on the site_id.  This has been auto-corrected.");
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
					}else if(local.autoIncrementFound){
						db.sql="ALTER TABLE`"&local.curDatasource&"`.`"&local.curTableName&"` 
						#local.autoIncrementFixSQL#";
						if(not debug) db.execute("qFix");
					}
					
					// this table must have a trigger, verify it exists
					local.triggerFound=false;
					local.triggerMatch=false;
					for(triggerRow in qTrigger){
						if(triggerRow.table EQ local.curTableName){
							// verify trigger is correct
							local.curTriggerTemplate=replace(replace(replace(triggerTemplate, "##keyName##", local.curPrimaryKeyId, "all"), "##tableName##", local.curTableName, "all"), "##databaseName##", local.curDatasource, "all");
							curStatement=rereplace(triggerRow.statement, "\s+", "", "all");
							if(compare(curStatement, local.curTriggerTemplate) NEQ 0){
								local.triggerMatch=false;
								arrayAppend(arrError, "Trigger for #local.curTable# table doesn't match template:<br />"&local.curTriggerTemplate&"<br /><br />"&curStatement);
							}else{
								local.triggerMatch=true;
							}
							local.triggerFound=true;	
							break;
						}
					}
					if((not local.triggerFound or not local.triggerMatch)){
							// create new trigger
							db.sql="DROP TRIGGER /*!50032 IF EXISTS */ `"&local.curDatasource&"`.`#local.curTableName#_auto_inc`";
							if(not debug) db.execute("q");
							db.sql="CREATE TRIGGER `"&local.curDatasource&"`.`#local.curTableName#_auto_inc` BEFORE INSERT ON `#local.curTableName#` 
							    FOR EACH ROW BEGIN
								IF (NEW.`#local.curPrimaryKeyId#` > 0) THEN
									SET @zLastInsertId = NEW.`#local.curPrimaryKeyId#`;
								ELSE 
									SET @zLastInsertId=(
										SELECT table_increment_table_id 
										FROM `#request.zos.zcoreDatasource#`.`table_increment` 
										WHERE `table_increment`.site_id = NEW.site_id and 
										table_increment_table = '#local.curTableName#' FOR UPDATE
									) ;
									IF (@zLastInsertId IS NULL) THEN
										INSERT INTO `table_increment` (site_id, table_increment_table, table_increment_table_id) SELECT 
										NEW.site_id, 
										'#local.curTableName#', 
										IFNULL(MAX(`#local.curPrimaryKeyId#`), 0)  as value
										FROM `#local.curTableName#` 
										WHERE `#local.curTableName#`.site_id = NEW.site_id;
										SET @zLastInsertId=(
											SELECT table_increment_table_id
											FROM `#request.zos.zcoreDatasource#`.`table_increment` 
											WHERE `table_increment`.site_id = NEW.site_id and 
											table_increment_table = '#local.curTableName#' FOR UPDATE
										) ; 
									END IF;
									SET @zLastInsertId=(@zLastInsertId - (@zLastInsertId MOD @@auto_increment_increment))+@@auto_increment_increment+(@@auto_increment_offset-1);
									UPDATE `#request.zos.zcoreDatasource#`.`table_increment` SET table_increment_table_id=@zLastInsertId 
									WHERE `table_increment`.site_id = NEW.site_id and 
									table_increment_table = '#local.curTableName#';
									SET NEW.`#local.curPrimaryKeyId#`=@zLastInsertId;
								END IF;
							END";
							// old version was broken
							// db.sql="CREATE TRIGGER `"&local.curDatasource&"`.`#local.curTableName#_auto_inc` BEFORE INSERT ON `#local.curTableName#` 
							//     FOR EACH ROW BEGIN
							// 		IF (NEW.`#local.curPrimaryKeyId#` > 0) THEN
							// 			SET @zLastInsertId = NEW.`#local.curPrimaryKeyId#`;
							// 		ELSE
							// 			SET @zLastInsertId=(
							// 				SELECT IFNULL(
							// 				(MAX(`#local.curPrimaryKeyId#`) - (MAX(`#local.curPrimaryKeyId#`) MOD @@auto_increment_increment))+@@auto_increment_increment+(@@auto_increment_offset-1), @@auto_increment_offset)  
							// 				FROM `#local.curTableName#` 
							// 				WHERE `#local.curTableName#`.site_id = NEW.site_id
							// 			);
							// 			SET NEW.`#local.curPrimaryKeyId#`=@zLastInsertId;
							// 		END IF;
							// END";
							/* old simple method:
									ELSE
									SET @zLastInsertId=(
										SELECT IFNULL(MAX(`#local.curPrimaryKeyId#`)+1,1) 
										FROM `#local.curTableName#` 
										WHERE `#local.curTableName#`.site_id = NEW.site_id
										);
*/
							if(not debug) db.execute("q");
							
						if(not local.triggerMatch){
							arrayAppend(arrError, "Trigger for #local.curTable# table was dropped and recreated.");
						}else{
							arrayAppend(arrError, "Trigger for #local.curTable# table was created.");
						}
					}
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