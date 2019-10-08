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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event`   
	ADD COLUMN `event_enable_registration` CHAR(1) DEFAULT '0' NOT NULL AFTER `event_metadesc`,
	ADD COLUMN `event_registration_limit` INT(11) DEFAULT 0 NOT NULL AFTER `event_enable_registration`,
	ADD COLUMN `event_registration_user_group_id_list` VARCHAR(255) NOT NULL AFTER `event_registration_limit`,
	ADD COLUMN `event_registration_payment_url` VARCHAR(255) NOT NULL AFTER `event_registration_user_group_id_list`,
	ADD COLUMN `event_registration_start_datetime` DATETIME NOT NULL AFTER `event_registration_payment_url`,
	ADD COLUMN `event_registration_end_datetime` DATETIME NOT NULL AFTER `event_registration_start_datetime`,
	ADD COLUMN `event_registration_custom_fields` LONGTEXT NOT NULL AFTER `event_registration_end_datetime`,
	ADD COLUMN `event_coordinator_name` VARCHAR(255) NOT NULL AFTER `event_registration_custom_fields`,
	ADD COLUMN `event_coordinator_email` VARCHAR(100) NOT NULL AFTER `event_coordinator_name`,
	ADD COLUMN `event_coordinator_phone` VARCHAR(20) NOT NULL AFTER `event_coordinator_email`,
	ADD COLUMN `event_registration_email_subject` VARCHAR(100) NOT NULL AFTER `event_coordinator_phone`,  
	ADD COLUMN `event_registration_email_message` LONGTEXT NOT NULL AFTER `event_registration_email_subject`,
	ADD COLUMN `event_registration_thank_you_heading` VARCHAR(255) NOT NULL AFTER `event_registration_email_message`,
	ADD COLUMN `event_registration_thank_you_body` LONGTEXT NOT NULL AFTER `event_registration_thank_you_heading`")){		return false;	}   
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `event_registration` (  
	  `event_registration_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	  `site_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `event_id` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  `event_registration_first_name` VARCHAR(100) NOT NULL,
	  `event_registration_last_name` VARCHAR(100) NOT NULL,
	  `event_registration_email` VARCHAR(100) NOT NULL,
	  `event_registration_phone` VARCHAR(20) NOT NULL,
	  `event_registration_registered_datetime` DATETIME NOT NULL,
	  `event_registration_meta` LONGTEXT NOT NULL,
	  `event_registration_sha2_hash` VARCHAR(64) NOT NULL,
	  `event_registration_deleted` INT(11) UNSIGNED NOT NULL DEFAULT 0,
	  PRIMARY KEY (`event_registration_id`, `site_id`)
	)")){		return false;	}   

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>