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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `feature_schema`   
	ADD COLUMN `feature_schema_category` VARCHAR(100) NOT NULL AFTER `feature_schema_preview_image`")){		return false;	}   
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `feature_data`   
	ADD COLUMN `feature_data_merge_data_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `feature_data_level`,
	ADD COLUMN `feature_data_merge_schema_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `feature_data_merge_data_id`")){		return false;	}   

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>