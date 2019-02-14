<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
		echo("done");
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger("jetendofeature", "feature_data", "feature_data_id");
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger("jetendofeature", "feature", "feature_id");
	application.zcore.functions.zCreateSiteIdPrimaryKeyTrigger("jetendofeature", "feature_x_site", "feature_x_site_id");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>