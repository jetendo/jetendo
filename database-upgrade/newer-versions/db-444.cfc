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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `job_config`   
	ADD COLUMN `job_config_enable_schema_data` CHAR(1) DEFAULT '0' NOT NULL AFTER `job_config_image_library_size_list`,
	ADD COLUMN `job_config_schema_company` VARCHAR(50) NOT NULL AFTER `job_config_enable_schema_data`,
	ADD COLUMN `job_config_schema_website` VARCHAR(100) NOT NULL AFTER `job_config_schema_company`,
	ADD COLUMN `job_config_schema_logo` VARCHAR(100) NOT NULL AFTER `job_config_schema_website`")){		return false;	}  

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `job`   
	ADD COLUMN `job_telecommute` CHAR(1) DEFAULT '0' NOT NULL AFTER `job_apply_url`,
	ADD COLUMN `job_work_hours` VARCHAR(100) NOT NULL AFTER `job_telecommute`")){		return false;	}   
	
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>