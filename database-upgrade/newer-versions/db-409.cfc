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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries_routing`   
	CHANGE `inquiries_routing_assign_to_email` `inquiries_routing_assign_to_email` TEXT CHARSET utf8 COLLATE utf8_general_ci NOT NULL")){		return false;	}  

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
	ADD COLUMN `inquiries_rating_comments` TEXT NOT NULL AFTER `inquiries_rating_email_sent_datetime`")){		return false;	}  
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>