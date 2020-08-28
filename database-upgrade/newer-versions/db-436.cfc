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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `static_cache` (  
  `static_cache_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `static_cache_url` VARCHAR(255) NOT NULL,
  `static_cache_filename_md5` VARCHAR(32) NOT NULL,
  `static_cache_hash` VARCHAR(32) NOT NULL,
  `static_cache_updated_datetime` DATETIME NOT NULL,
  `static_cache_priority` INT(0) NOT NULL,
  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
   KEY(`static_cache_id`),
  PRIMARY KEY (`site_id`, `static_cache_id`),
  INDEX `NewIndex1` (`site_id`),
  INDEX `NewIndex2` (`site_id`, `static_cache_priority`)
)")){		return false;	}  

	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>