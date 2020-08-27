<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<!--- this should be a scheduled task that runs every 15 minutes --->
	<!--- grab 1 url that hasn't pinged since last update --->
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();
	if(request.zos.isDeveloper and not application.zcore.user.checkAllCompanyAccess()){
		application.zcore.status.setStatus(request.zsid, "Access denied.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	if(request.zos.isTestServer){
		echo('This is the test server, so no actual remote pings are made.<br />');
	}
	var db=request.zos.queryObject;
	setting requesttimeout="5000";
	db.sql="SELECT blog.*, blog_config_url_article_id 
	FROM (#request.zos.queryObject.table("blog", request.zos.zcoreDatasource)# blog,
	#request.zos.queryObject.table("blog_config", request.zos.zcoreDatasource)# blog_config, 
	#request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site) WHERE 
	blog_deleted = #db.param(0)# and 
	blog_config_deleted = #db.param(0)# and 
	blog_config.site_id = blog.site_id and 
	blog_config.site_id = site.site_id and 
	site.site_active=#db.param('1')# and 
	site.site_live=#db.param('1')# and 
	 blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd'))# and 
	 blog_status <> #db.param(2)# and 
	blog_update_datetime < #db.param(dateformat(dateadd("n",-15,now()),'yyyy-mm-dd')&' '&timeformat(dateadd("n",-15,now()),'HH:mm:ss'))# and 
	 (blog_ping_datetime = #db.param('0000-00-00 00:00:00')# or 
	 blog_ping_datetime < blog_update_datetime)  
	LIMIT #db.param(0)#,#db.param(3)#";
	qB=db.execute("qB");
	loop query="qB"{
		pingUrl=application.zcore.functions.zvar('domain',qB.site_id)&"/z/blog/blog/ping?blog_id=#qB.blog_id#&forceping=1";
		writeoutput(pingUrl&"<br />");
		http url="#pingUrl#" method="get" timeout="250" resolveurl="yes" throwonerror="no"{
		}
	}
	if(qB.recordcount EQ 0){
		writeoutput('All pings are complete.');
	}else{
		writeoutput('Ping executed. Waiting to ping again.');
	}
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>