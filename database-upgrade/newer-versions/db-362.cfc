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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `image`   
  ADD COLUMN `image_latitude_integer` INT(11) NOT NULL AFTER `image_longitude`,
  ADD COLUMN `image_longitude_integer` INT(11) NOT NULL AFTER `image_latitude_integer`, 
  ADD  INDEX `NewIndex4` (`site_id`, `image_library_id`, `image_latitude`, `image_longitude`),
  ADD  INDEX `NewIndex5` (`site_id`, `image_library_id`, `image_latitude_integer`, `image_longitude_integer`);
")){		return false;	}

	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "UPDATE image SET image_latitude_integer = ROUND(image_latitude*100000), image_longitude_integer = ROUND(image_longitude*100000) WHERE site_id<>-1 AND image_latitude <> '0' ")){		return false;	}
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>