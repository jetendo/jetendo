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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "CREATE TABLE `webfont` (  
	  `webfont_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
	  `webfont_name` VARCHAR(100) NOT NULL,
	  `webfont_family` VARCHAR(100) NOT NULL,
	  `webfont_weight` VARCHAR(30) NOT NULL,
	  `webfont_style` VARCHAR(30) NOT NULL,
	  `webfont_code` TEXT NOT NULL,
	  `webfont_stylesheet` VARCHAR(255) NOT NULL,
	  `webfont_updated_datetime` DATETIME NOT NULL,
	  `webfont_deleted` INT(11) UNSIGNED NOT NULL,
	  `webfont_heading_scale` DECIMAL(10,2) UNSIGNED NOT NULL,
	  `webfont_text_scale` DECIMAL(10,2) UNSIGNED NOT NULL,
	  PRIMARY KEY (`webfont_id`)
	)")){		return false;	}  

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>