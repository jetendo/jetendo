<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var r=0;
	var qs=0;
	
	application.zcore.functions.checkIfCronJobAllowed();
	setting requesttimeout="5000";
	request.ignoreSlowScript=true;
	db.sql="select * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
	where site.site_active =#db.param('1')# and 
	site_deleted = #db.param(0)# and 
	site_id <> #db.param('1')#";
	qs=db.execute("qs");
	for(row in qS){
		local.tempPath=application.zcore.functions.zGetDomainWritableInstallPath(row.site_short_domain);
		if(directoryexists(local.tempPath)){
			application.zcore.functions.zCreateDirectory(local.tempPath&'_cache/html/');
			r=application.zcore.functions.zhttptofile("#row.site_domain#/z/misc/system/missing", local.tempPath&'_cache/html/404.html');
		}
	}
	writeoutput('missing published');
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>