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
	ADD COLUMN `inquiries_rating_setting_from_email` VARCHAR(100) NOT NULL AFTER `inquiries_rating_setting_low_rating_comments_form`,
	ADD COLUMN `inquiries_rating_setting_comments_email` TEXT NOT NULL AFTER `inquiries_rating_setting_from_email` 
	")){		return false;	}  
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>