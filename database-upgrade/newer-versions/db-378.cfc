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
  DROP COLUMN `contact_assigned_user_id`, 
  DROP COLUMN `contact_assigned_user_id_siteidtype`, 
  DROP INDEX `NewIndex4`")){		return false;	}
   
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>