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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_import_log`   
  CHANGE `inquiries_import_log_id` `inquiries_import_file_id` INT(11) UNSIGNED NOT NULL,
  ADD COLUMN `office_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `site_id`,
  ADD COLUMN `inquiries_autoresponder_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `user_id_siteidtype`,
  ADD COLUMN `inquiries_type_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `inquiries_autoresponder_id`,
  ADD COLUMN `inquiries_type_id_siteidtype` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `inquiries_type_id`,
  CHANGE `inquiries_import_log_name` `inquiries_import_file_name` VARCHAR(100) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `inquiries_import_log_filename` `inquiries_import_file_filename` VARCHAR(100) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `inquiries_import_log_record_count` `inquiries_import_file_record_count` INT(11) UNSIGNED DEFAULT 0 NOT NULL,
  CHANGE `inquiries_import_log_import_count` `inquiries_import_file_import_count` INT(11) UNSIGNED DEFAULT 0 NOT NULL,
  CHANGE `inquiries_import_log_error_count` `inquiries_import_file_error_count` INT(11) UNSIGNED DEFAULT 0 NOT NULL,
  CHANGE `inquiries_import_log_error_status` `inquiries_import_file_status` INT(11) UNSIGNED DEFAULT 0 NOT NULL,
  CHANGE `inquiries_import_log_updated_datetime` `inquiries_import_file_updated_datetime` DATETIME NOT NULL,
  CHANGE `inquiries_import_log_completed_datetime` `inquiries_import_file_completed_datetime` DATETIME NOT NULL,
  CHANGE `inquiries_import_log_deleted` `inquiries_import_file_deleted` INT(11) DEFAULT 0 NOT NULL")){		return false;	}  
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "RENAME TABLE `inquiries_import_log` TO `inquiries_import_file`")){		return false;	} 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>