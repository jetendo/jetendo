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
	CHANGE `inquiries_external_id` `inquiries_external_id` VARCHAR(256) CHARSET utf8 COLLATE utf8_general_ci NOT NULL")){		return false;	}  
	
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `inquiries_parse_config` (  
	  `inquiries_parse_config_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	  `site_id` INT(11) UNSIGNED NOT NULL,
	  `inquiries_parse_config_inquiries_type_id` INT(11) UNSIGNED NOT NULL,
	  `inquiries_parse_config_inquiries_type_id_siteidtype` INT(11) UNSIGNED NOT NULL,
	  `inquiries_parse_config_name` VARCHAR(100) NOT NULL,
	  `inquiries_parse_config_email` VARCHAR(100) NOT NULL,
	  `inquiries_parse_config_updated_datetime` DATETIME NOT NULL,
	  `inquiries_parse_config_deleted` INT(11) NOT NULL DEFAULT 0,
	  `inquiries_parse_config_subject_exclude` TEXT NOT NULL,
	  `inquiries_parse_config_body_exclude` TEXT NOT NULL,
	  PRIMARY KEY (`inquiries_parse_config_id`, `site_id`),
	  INDEX `NewIndex1` (`site_id`),
	  UNIQUE INDEX `NewIndex2` (`site_id`, `inquiries_parse_config_name`),
	  UNIQUE INDEX `NewIndex3` (`site_id`, `inquiries_parse_config_email`)
	)")){		return false;	}  

	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>