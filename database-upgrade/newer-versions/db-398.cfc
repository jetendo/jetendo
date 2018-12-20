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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_import_file`   
  ADD COLUMN `inquiries_import_file_import_user_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `inquiries_import_file_id`,
  ADD COLUMN `inquiries_import_file_import_user_id_siteidtype` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `inquiries_import_file_import_user_id`")){		return false;	}  
    
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>