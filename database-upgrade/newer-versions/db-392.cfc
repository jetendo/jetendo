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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_import_log`   
  ADD COLUMN `inquiries_import_log_name` VARCHAR(100) NOT NULL AFTER `user_id_siteidtype`")){		return false;	} 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>