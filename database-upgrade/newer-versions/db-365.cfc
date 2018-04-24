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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event`   
  CHANGE `event_image_library_layout` `event_image_library_layout` INT(11) UNSIGNED DEFAULT 0 NOT NULL")){		return false;	}
  
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `job`   
  CHANGE `job_image_library_id` `job_image_library_id` INT(11) UNSIGNED NOT NULL,
  CHANGE `job_image_library_layout` `job_image_library_layout` INT(11) UNSIGNED NOT NULL")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>