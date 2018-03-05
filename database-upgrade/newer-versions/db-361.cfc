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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `image`   
  ADD COLUMN `image_latitude` DECIMAL(25,18) NOT NULL AFTER `image_deleted`,
  ADD COLUMN `image_longitude` DECIMAL(25,18) NOT NULL AFTER `image_latitude`,
  ADD COLUMN `image_altitude` INT(11) UNSIGNED NOT NULL AFTER `image_longitude`,
  ADD COLUMN `image_taken_datetime` DATETIME NOT NULL AFTER `image_altitude`")){		return false;	}


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>