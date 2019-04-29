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
	ADD COLUMN `inquiries_rating_setting_high_rating_comments_form` CHAR(1) DEFAULT '0' NOT NULL AFTER `inquiries_rating_setting_active`,
	ADD COLUMN `inquiries_rating_setting_low_rating_comments_form` CHAR(1) DEFAULT '0' NOT NULL AFTER `inquiries_rating_setting_high_rating_comments_form`")){		return false;	}  
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>