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
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog`   
  ADD COLUMN `blog_other_author` VARCHAR(100) NOT NULL AFTER `blog_og_image`")){		return false;	}
	
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_version`   
  ADD COLUMN `blog_other_author` VARCHAR(100) NOT NULL AFTER `blog_version_deleted`")){		return false;	} 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>