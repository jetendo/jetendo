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
	ADD COLUMN `feature_schema_enable_merge_interface` CHAR(1) DEFAULT '0' NOT NULL AFTER `feature_schema_change_cfc_children`,
	ADD COLUMN `feature_schema_merge_group_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `feature_schema_enable_merge_interface`,
	ADD COLUMN `feature_schema_merge_title_field` VARCHAR(100) NOT NULL AFTER `feature_schema_merge_group_id`,
	ADD COLUMN `feature_schema_merge_image_field` VARCHAR(100) NOT NULL AFTER `feature_schema_merge_title_field`")){		return false;	}   
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>