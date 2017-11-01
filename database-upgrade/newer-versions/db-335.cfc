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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `section_config` (
  `section_config_id` int(11) unsigned NOT NULL DEFAULT '0',
  `section_config_url_page_id` int(11) unsigned NOT NULL DEFAULT '0',
  `app_x_site_id` int(11) unsigned NOT NULL DEFAULT '0',
  `site_id` int(11) unsigned NOT NULL DEFAULT '0',
  `section_config_updated_datetime` datetime NOT NULL,
  `section_config_deleted` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`site_id`,`section_config_id`),
  UNIQUE KEY `NewIndex1` (`site_id`,`section_config_deleted`),
  KEY `site_id` (`site_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT IGNORE INTO `app` (`app_id`, `app_name`, `app_updated_datetime`) VALUES ('20', 'Section', '2017-10-29 13:55:16')")){		return false;	}

	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "section_config", "section_config_id");
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>