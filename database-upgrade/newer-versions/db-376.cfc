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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `contact_x_contact`(  
	  `contact_x_contact_id` INT(11) UNSIGNED NOT NULL,
	  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `contact_id` INT(11) UNSIGNED NOT NULL,
	  `contact_x_contact_accessible_by_contact_id` INT(11) UNSIGNED NOT NULL,
	  `contact_x_contact_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  PRIMARY KEY (`site_id`, `contact_x_contact_id`),
	  INDEX `NewIndex1` (`site_id`),
	  INDEX `NewIndex2` (`site_id`, `contact_id`),
		UNIQUE INDEX `NewIndex3` (`site_id`, `contact_id`, `contact_x_contact_accessible_by_contact_id`)
	)")){		return false;	}
  
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "contact_x_contact", "contact_x_contact_id");
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>