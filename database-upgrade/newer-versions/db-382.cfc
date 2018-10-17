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
  ADD COLUMN `site_lead_block_text` TEXT NOT NULL AFTER `site_contact_list_grouping`")){		return false;	}
   
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>