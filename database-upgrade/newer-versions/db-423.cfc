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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `ecommerce_config`   
	ADD COLUMN `ecommerce_config_authorize_net_enabled` CHAR(1) DEFAULT '0' NOT NULL AFTER `ecommerce_config_merchant_account`,
	ADD COLUMN `ecommerce_config_authorize_net_login_id` VARCHAR(50) NOT NULL AFTER `ecommerce_config_authorize_net_enabled`,
	ADD COLUMN `ecommerce_config_authorize_net_transaction_key` VARCHAR(255) NOT NULL AFTER `ecommerce_config_authorize_net_login_id`,
	ADD COLUMN `ecommerce_config_authorize_net_signature_key` VARCHAR(255) NOT NULL AFTER `ecommerce_config_authorize_net_transaction_key`")){		return false;	}   

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>