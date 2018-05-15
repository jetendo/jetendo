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
  ADD COLUMN `ecommerce_config_product_url_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `ecommerce_config_paypal_custom_ipn_url_id`,
  ADD COLUMN `ecommerce_config_category_url_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `ecommerce_config_product_url_id`,
  ADD COLUMN `ecommerce_config_misc_url_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `ecommerce_config_category_url_id`,
  ADD COLUMN `ecommerce_config_stripe_secret_key` VARCHAR(100) NOT NULL AFTER `ecommerce_config_misc_url_id`,
  ADD COLUMN `ecommerce_config_stripe_public_key` VARCHAR(100) NOT NULL AFTER `ecommerce_config_stripe_secret_key`")){		return false;	}
  
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>