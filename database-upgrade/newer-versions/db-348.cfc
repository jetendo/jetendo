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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `contact`   
	  ADD COLUMN `contact_assigned_user_id` INT NOT NULL AFTER `contact_des_key`,
	  ADD COLUMN `contact_assigned_user_id_siteidtype` INT NOT NULL AFTER `contact_assigned_user_id`, 
	  ADD  INDEX `NewIndex4` (`site_id`, `contact_assigned_user_id`, `contact_assigned_user_id_siteidtype`)")){		return false;	}
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>