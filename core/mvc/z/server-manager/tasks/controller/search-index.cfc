<cfcomponent>
<cfoutput>
<!--- schedule this daily to ensure any bad records are cleared. --->
<cffunction name="index" localmode="modern" access="remote">
	<cfsetting requesttimeout="2000">
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();
	request.ignoreSlowScript=true;

 	db=request.zos.queryObject;
	db.sql="SELECT site.site_domain FROM 
	#db.table("site", request.zos.zcoreDatasource)#, 
	#db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE 
	site.site_id = site_option_group.site_id and 
	site.site_deleted = #db.param(0)# and 
	site_option_group.site_id <> #db.param(-1)# and 
	site_option_group_deleted = #db.param(0)# 
	GROUP BY site.site_domain";
	qSite=db.execute("qSite");
	for(row in qSite){
		//echo(row.site_domain&"/z/admin/site-options/searchReindex");
		application.zcore.functions.zdownloadlink(row.site_domain&"/z/admin/site-options/searchReindex");
		//abort;
	}
	//abort;

	manualCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.manual");
	manualCom.reindexDocumentation();
 

	blogCom=createobject("component", "zcorerootmapping.mvc.z.blog.controller.blog");
	blogCom.searchReindexBlogArticles(false, true);
	blogCom.searchReindexBlogCategories(false, true);
	blogCom.searchReindexBlogTags(false, true);
	
	rentalCom=createobject("component", "zcorerootmapping.mvc.z.rental.controller.rental");
	rentalCom.searchReindexRental(false, true);
	rentalCom.searchReindexRentalCategory(false, true);
	
	contentCom=createobject("component", "zcorerootmapping.mvc.z.content.controller.content");
	contentCom.searchReindexContent(false, true);
	
	
	
	echo('Done.');
	abort;
	</cfscript>
</cffunction>
</cfoutput>

</cfcomponent>