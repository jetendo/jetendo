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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
  ADD COLUMN `inquiries_disable_detailed_lead_email` CHAR(1) DEFAULT '0' NOT NULL AFTER `inquiries_priority`")){		return false;	}
 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_option_group`   
  ADD COLUMN `site_option_group_disable_detailed_lead_email` CHAR(1) DEFAULT '0' NOT NULL AFTER `site_option_group_disable_export`")){		return false;	}

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>