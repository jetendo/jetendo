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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `static_cache`   
	ADD COLUMN `static_cache_processed` CHAR(1) DEFAULT '0' NOT NULL AFTER `static_cache_priority`,
	ADD COLUMN `static_cache_deleted` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `static_cache_processed`, 
  ADD  UNIQUE INDEX `NewIndex3` (`site_id`, `static_cache_url`)")){		return false;	}  
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>