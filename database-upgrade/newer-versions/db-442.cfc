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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `office`   
	CHANGE `office_description` `office_description` LONGTEXT NOT NULL,
	ADD COLUMN `office_map_location` VARCHAR(100) NOT NULL AFTER `office_manager_email_list`,
	ADD COLUMN `office_hours` TEXT NULL AFTER `office_map_location`")){		return false;	}  


	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>