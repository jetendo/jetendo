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
	ADD COLUMN `feature_schema_preview_image` VARCHAR(255) NOT NULL AFTER `feature_schema_merge_image_field`")){		return false;	}   
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>