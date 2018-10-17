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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site_option_group`   
  ADD COLUMN `site_option_group_image_library_size_list` VARCHAR(255) NOT NULL AFTER `site_option_group_enable_archiving`")){		return false;	}
   
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_config`   
  ADD COLUMN `blog_config_image_library_size_list` VARCHAR(255) NOT NULL AFTER `blog_config_show_categories_on_articles`")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_config`   
  ADD COLUMN `event_config_image_size_list` VARCHAR(255) NOT NULL AFTER `event_config_no_event_message`")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `content_config`   
  ADD COLUMN `content_config_image_library_size_list` VARCHAR(255) NOT NULL AFTER `content_config_viewable_by_default_group`")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `job_config`   
  ADD COLUMN `job_config_image_library_size_list` VARCHAR(255) NOT NULL AFTER `job_config_home_metadesc`")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `rental_config`   
  ADD COLUMN `rental_config_image_library_size_list` VARCHAR(255) NOT NULL AFTER `rental_config_deleted`")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `site`   
  ADD COLUMN `site_image_library_size_list` VARCHAR(255) NOT NULL AFTER `site_lead_block_text`")){		return false;	}

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>