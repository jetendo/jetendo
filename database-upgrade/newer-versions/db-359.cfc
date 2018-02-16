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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `deploy_server`   
  ADD COLUMN `deploy_server_group` VARCHAR(100) NOT NULL AFTER `deploy_server_deleted`")){		return false;	}
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `deploy_server`   
  ADD COLUMN `deploy_server_ssh_port` INT UNSIGNED NOT NULL AFTER `deploy_server_group`")){		return false;	}

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>