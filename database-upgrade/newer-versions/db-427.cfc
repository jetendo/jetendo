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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   
	ADD COLUMN `site_company_link_home` TEXT NOT NULL AFTER `site_adwords_account_id`,
	ADD COLUMN `site_company_link_subpage` TEXT NOT NULL AFTER `site_company_link_home`")){		return false;	}  

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>