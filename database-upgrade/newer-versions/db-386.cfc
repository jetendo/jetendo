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
  CHANGE `inquiries_start_date` `inquiries_start_date` DATE NOT NULL,
  CHANGE `inquiries_end_date` `inquiries_end_date` DATE NOT NULL,
  CHANGE `inquiries_adults` `inquiries_adults` VARCHAR(10) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `inquiries_children` `inquiries_children` VARCHAR(10) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `inquiries_phone2ext` `inquiries_phone2ext` VARCHAR(10) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `inquiries_address2` `inquiries_address2` VARCHAR(100) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `region` `region` VARCHAR(30) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `services` `services` VARCHAR(30) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `water_activities` `water_activities` VARCHAR(30) CHARSET utf8 COLLATE utf8_general_ci NOT NULL,
  CHANGE `date_of_trip` `date_of_trip` VARCHAR(30) CHARSET utf8 COLLATE utf8_general_ci NOT NULL")){		return false;	}

	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>