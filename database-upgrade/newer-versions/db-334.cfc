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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE section_link (
	`section_link_id` int(11) unsigned NOT NULL, 
	`section_id` int(11) unsigned NOT NULL, 
	`section_link_parent_id` int(11) unsigned NOT NULL, 
	`site_id` int(11) unsigned NOT NULL, 
	`section_link_link_text` text NOT NULL, 
	`section_link_url` text NOT NULL, 
	`section_link_sort` int(11) unsigned NOT NULL, 
	`section_link_created_datetime` datetime NOT NULL, 
	`section_link_updated_datetime` datetime NOT NULL, 
	`section_link_deleted` int(11) unsigned NOT NULL DEFAULT '0', 
	 PRIMARY KEY (`site_id`,`section_link_id`),
	KEY `NewIndex1` (`site_id`) ,
	KEY `newIndex2` (`section_link_parent_id`) ,
	KEY `newIndex3` (`site_id`, `section_id`) 
	) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC")){		return false;	}

	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "section_link", "section_link_id");
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>