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
	CHANGE `feature_schema_disable_feature_map` `feature_schema_disable_site_map` CHAR(1) CHARSET utf8 COLLATE utf8_general_ci DEFAULT '0' NOT NULL")){		return false;	}   

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>