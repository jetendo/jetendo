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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `job`   
  ADD COLUMN `job_apply_url` VARCHAR(255) NOT NULL AFTER `job_metadesc`")){		return false;	}
   
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>