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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `mls_option`   
  ADD COLUMN `mls_option_listing_result_cfc_path` VARCHAR(255) NOT NULL AFTER `mls_option_email_listing_agent_only`,
  ADD COLUMN `mls_option_listing_result_cfc_method` VARCHAR(50) NOT NULL AFTER `mls_option_listing_result_cfc_path`,
  ADD COLUMN `mls_option_search_header_cfc_path` VARCHAR(255) NOT NULL AFTER `mls_option_listing_result_cfc_method`,
  ADD COLUMN `mls_option_search_header_cfc_method` VARCHAR(50) NOT NULL AFTER `mls_option_search_header_cfc_path`,
  ADD COLUMN `mls_option_search_footer_cfc_path` VARCHAR(255) NOT NULL AFTER `mls_option_search_header_cfc_method`,
  ADD COLUMN `mls_option_search_footer_cfc_method` VARCHAR(50) NOT NULL AFTER `mls_option_search_footer_cfc_path`")){		return false;	}

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>