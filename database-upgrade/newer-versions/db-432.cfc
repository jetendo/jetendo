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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `listing_track`   
	ADD COLUMN `listing_track_external_timestamp` VARCHAR(25) NOT NULL AFTER `listing_track_sysid`,
	ADD COLUMN `listing_track_external_photo_timestamp` VARCHAR(25) NOT NULL AFTER `listing_track_external_timestamp`")){		return false;	}  
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>