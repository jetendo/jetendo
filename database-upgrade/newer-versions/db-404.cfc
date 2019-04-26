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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `inquiries`   
	ADD COLUMN `inquiries_rating_email_sent_count` INT(11) UNSIGNED DEFAULT 0 NOT NULL AFTER `inquiries_import_file_id`,
	ADD COLUMN `inquiries_rating_email_set` CHAR(1) DEFAULT '0' NOT NULL AFTER `inquiries_rating_email_sent_count`,
	ADD COLUMN `inquiries_rating` INT UNSIGNED NOT NULL AFTER `inquiries_rating_email_set`,
	ADD COLUMN `inquiries_rating_hash` VARCHAR(64) NOT NULL AFTER `inquiries_rating`")){		return false;	}  
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `inquiries_rating_setting` (
	  `inquiries_rating_setting_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
	  `site_id` int(11) NOT NULL,
	  `inquiries_rating_inquiries_type_id` int(11) NOT NULL DEFAULT 0,
	  `inquiries_rating_setting_email_subject` varchar(255) NOT NULL,
	  `inquiries_rating_setting_header_text` text NOT NULL,
	  `inquiries_rating_setting_body_text` longtext NOT NULL,
	  `inquiries_rating_setting_footer_text` text NOT NULL,
	  `inquiries_rating_setting_email_delay_in_minutes` int(11) NOT NULL DEFAULT 0,
	  `inquiries_rating_setting_email_resend_limit` int(11) NOT NULL DEFAULT 0,
	  `inquiries_rating_setting_type` int(11) NOT NULL DEFAULT 0,
	  `inquiries_rating_setting_low_rating_number` int(11) NOT NULL DEFAULT 0,
	  `inquiries_rating_setting_low_rating_thanks_heading` varchar(255) NOT NULL,
	  `inquiries_rating_setting_low_rating_thanks_body` longtext NOT NULL,
	  `inquiries_rating_setting_thanks_cfc_object` varchar(255) NOT NULL,
	  `inquiries_rating_setting_thanks_cfc_method` varchar(100) NOT NULL,
	  `inquiries_rating_setting_deleted` int(11) NOT NULL DEFAULT 0,
	  PRIMARY KEY (`site_id`,`inquiries_rating_setting_id`),
	  KEY `inquiries_rating_setting_id` (`inquiries_rating_setting_id`),
	  KEY `NewIndex1` (`site_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8")){		return false;	}  
	
	
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger(request.zos.zcoreDatasource, "inquiries_rating_setting", "inquiries_rating_setting_id");
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>