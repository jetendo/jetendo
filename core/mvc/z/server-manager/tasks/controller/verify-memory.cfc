<cfcomponent>
<cfoutput>
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();
	db=request.zos.queryObject;
	setting requesttimeout="100000";
	db.sql="select site_id, site_domain from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_id<>#db.param(-1)# and 
	site_deleted=#db.param(0)# and 
	site_active=#db.param(1)# ";
	qSite=db.execute("qSite");
	start=gettickcount();
	for(site in qSite){
		echo(site.site_domain&"<br>");
		application.zcore.functions.zOS_cacheSiteAndUserGroups(site.site_id);
	}
	echo('Done in #(gettickcount()-start)/1000# seconds.');abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>