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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "INSERT INTO app SET app_id='21', app_name ='Feature', app_built_in='1', app_updated_datetime='2019-02-13 00:00:00', app_deleted='0'")){		return false;	}  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>