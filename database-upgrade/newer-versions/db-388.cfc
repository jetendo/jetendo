<cfcomponent implements="zcorerootmapping.interface.databaseVersion">
<cfoutput>
<cffunction name="getChangedTableArray" localmode="modern" access="public" returntype="array">
	<cfscript>
	arr1=[];
	return arr1;
	</cfscript>
</cffunction>

<cffunction name="executeUpgrade" localmode="modern" access="public" returntype="boolean">
	<cfargument name="dbUpgradeCom" type="component" required="yes">
	<cfscript>         
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
  CHANGE `inquiries_import_file` `inquiries_import_file_id` VARCHAR(255) CHARSET utf8 COLLATE utf8_general_ci NOT NULL")){		return false;	}

	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `inquiries_import_log`(  
  `inquiries_import_log_id` INT(11) UNSIGNED NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL,
  `user_id` INT(11) UNSIGNED NOT NULL,
  `user_id_siteidtype` INT(11) UNSIGNED NOT NULL,
  `inquiries_import_log_filename` VARCHAR(100) NOT NULL,
  `inquiries_import_log_record_count` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `inquiries_import_log_error_count` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `inquiries_import_log_error_status` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `inquiries_import_log_updated_datetime` DATETIME NOT NULL,
  `inquiries_import_log_completed_datetime` DATETIME NOT NULL,
  `inquiries_import_log_deleted` INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`inquiries_import_log_id`, `site_id`),
  UNIQUE INDEX `NewIndex1` (`site_id`),
  INDEX `NewIndex2` (`site_id`, `user_id`, `user_id_siteidtype`)
)")){		return false;	}

	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "inquiries_import_log", "inquiries_import_log_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>