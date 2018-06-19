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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `listing_media`(  
  `listing_media_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `listing_mls_id` INT(11) UNSIGNED NOT NULL,
  `listing_id` INT(11) UNSIGNED NOT NULL,
  `listing_media_list` TEXT NOT NULL,
  `listing_media_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
  `_updated_datetime` DATETIME NOT NULL,
  PRIMARY KEY (`listing_media_id`),
  INDEX `NewIndex1` (`listing_mls_id`),
  UNIQUE INDEX `NewIndex2` (`listing_id`)
)")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>