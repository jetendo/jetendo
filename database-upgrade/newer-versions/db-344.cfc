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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `zdir_city`   
  ADD COLUMN `zdir_city_deleted` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `zdir_city_updated_datetime`")){		return false;	}
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>