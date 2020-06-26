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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `track_user`   
	ADD COLUMN `track_user_filling_data` VARCHAR(150) NOT NULL AFTER `track_user_seconds_since_first_visit`")){		return false;	}  

	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>