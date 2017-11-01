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
  ADD COLUMN `blog_og_image` VARCHAR(255) NOT NULL AFTER `blog_comment_count`;
")){		return false;	}
 
	if(!arguments.dbUpgradeCom.executeQuery(this.datasource, "ALTER TABLE `blog_version`   
  ADD COLUMN `blog_og_image` VARCHAR(255) NOT NULL AFTER `blog_comment_count`;
")){		return false;	}
 
	return true;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>