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
	ADD COLUMN `ecommerce_config_authorize_net_client_key` VARCHAR(255) NOT NULL AFTER `ecommerce_config_authorize_net_signature_key`")){		return false;	}   
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event`   
	DROP COLUMN `event_registration_payment_url`, 
	ADD COLUMN `form_id` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `event_enable_registration`")){		return false;	}   
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `ecommerce_payment_log` (
	  `ecommerce_payment_log_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	  `site_id` int(11) unsigned NOT NULL,
	  `ecommerce_payment_log_datetime` datetime NOT NULL,
	  `ecommerce_payment_log_updated_datetime` datetime NOT NULL,
	  `ecommerce_payment_log_data` text NOT NULL,
	  `ecommerce_payment_log_name` VARCHAR(100) NOT NULL,
	  `ecommerce_payment_log_type` varchar(100) NOT NULL,
	  `ecommerce_payment_log_deleted` char(1) NOT NULL DEFAULT '0',
	  PRIMARY KEY (`site_id`,`ecommerce_payment_log_id`),
	  KEY `NewIndex1` (`site_id`),
	  KEY `ecommerce_payment_log_id` (`ecommerce_payment_log_id`)
	) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8")){		return false;	}   
	
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `form` (  
	  `form_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	  `form_name` VARCHAR(255) NOT NULL,
	  `form_field_data` LONGTEXT NOT NULL,
	  `form_standalone` CHAR(1) NOT NULL DEFAULT '0',
	  `form_updated_datetime` DATETIME NOT NULL,
	  `form_deleted` INT(0) UNSIGNED NOT NULL,
	  `site_id` INT(11) UNSIGNED NOT NULL,
	   KEY(`form_id`),
	  PRIMARY KEY (`site_id`, `form_id`),
	  INDEX `newindex1` (`site_id`),
	  UNIQUE INDEX `newindex2` (`site_id`, `form_name`)
	)")){		return false;	}   


	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>