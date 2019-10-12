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
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `event_registration`   
	ADD COLUMN `event_registration_paid` CHAR(1) DEFAULT '0' NOT NULL AFTER `ecommerce_payment_log_id`")){		return false;	}   

	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `ecommerce_payment_log`   
	ADD COLUMN `ecommerce_payment_log_amount` DECIMAL(11,2) UNSIGNED NOT NULL AFTER `ecommerce_payment_log_deleted`")){		return false;	}  

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>