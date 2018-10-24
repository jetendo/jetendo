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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `table_increment` (
	  `table_increment_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
	  `site_id` int(11) unsigned NOT NULL,
	  `table_increment_table` varchar(100) NOT NULL,
	  `table_increment_table_id` int(11) unsigned NOT NULL,
	  PRIMARY KEY (`table_increment_id`),
	  UNIQUE KEY `NewIndex1` (`site_id`,`table_increment_table`),
	  KEY `NewIndex2` (`site_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>