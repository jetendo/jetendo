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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_option_group`   
  ADD COLUMN `site_option_group_java_name` VARCHAR(100) NOT NULL AFTER `site_id`
")){		return false;	}  
    
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_option`   
  ADD COLUMN `site_option_variable_name` VARCHAR(255) NOT NULL AFTER `site_option_display_name`")){		return false;	}  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>