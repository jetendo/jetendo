<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var qC=0;
	var a1=0;
	var r1=0;
	application.zcore.functions.checkIfCronJobAllowed();
	request.ignoreSlowScript=true;
	setting requesttimeout="5000";
	db.sql="select site.site_id, site_domain 
	from #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site, 
	#request.zos.queryObject.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#request.zos.queryObject.table("app", request.zos.zcoreDatasource)# app 
	where site.site_active =#db.param('1')# and 
	site.site_live =#db.param('1')# and 
	app.app_name=#db.param('content')# and 
	app_x_site.app_id = app.app_id and 
	app_x_site.site_id = site.site_id and 
	site_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	app_deleted = #db.param(0)#";
	qC=db.execute("qC");
	a1=arraynew(1);
	loop query="qc"{
		r1=application.zcore.functions.zdownloadlink(qc.site_domain&'/z/misc/site-map/xmloutput', 30, true);
		if(r1.success EQ false){
			arrayappend(a1, qc.site_domain&'/z/misc/site-map/xmloutput');
		}
		sleep(100);
	}
	if(arraylen(a1) NEQ 0){
		mail from="#request.zos.developerEmailFrom#" to="#request.zos.developerEmailTo#" subject="Sitemap publishing failed."{
writeoutput('The following urls failed to publish:
#arraytolist(a1, chr(10))#');
		}
	}
	</cfscript>
	Done.
</cffunction>
</cfoutput>
</cfcomponent>