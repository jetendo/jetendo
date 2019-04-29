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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_rating_setting`   
	CHANGE `inquiries_rating_setting_high_rating_active` `inquiries_rating_setting_active` CHAR(1) CHARSET utf8 COLLATE utf8_general_ci DEFAULT '0' NOT NULL")){		return false;	}  
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>