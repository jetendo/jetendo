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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `mlsgrid_media` (
  `mlsgrid_media_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `mls_id` int(11) unsigned NOT NULL,
  `mlsgrid_media_key` varchar(50) NOT NULL,
  `listing_id` varchar(25) NOT NULL,
  `mlsgrid_media_url` varchar(255) NOT NULL,
  `mlsgrid_media_order` int(11) NOT NULL,
  `mlsgrid_media_updated_datetime` datetime NOT NULL,
  `mlsgrid_media_deleted` int(11) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`mlsgrid_media_id`),
  KEY `NewIndex2` (`mls_id`,`mlsgrid_media_key`),
  KEY `NewIndex3` (`listing_id`,`mlsgrid_media_order`)
) ENGINE=InnoDB AUTO_INCREMENT=8207160 DEFAULT CHARSET=utf8")){		return false;	}  

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>