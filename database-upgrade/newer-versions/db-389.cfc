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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `mls`   
  ADD COLUMN `mls_file_charset` VARCHAR(30) DEFAULT 'UTF-8' NOT NULL AFTER `mls_deleted`")){		return false;	}
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>