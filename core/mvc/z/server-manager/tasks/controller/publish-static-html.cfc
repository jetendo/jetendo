<cfcomponent>
<cfoutput>
<cffunction name="getNginxCachePath" localmode="modern" access="public">
	<cfargument name="absoluteURL" type="string" required="yes">
	<cfscript>
	h=lcase(hash(arguments.absoluteURL));
	return "/var/jetendo-server/nginx/cache/"&right(h, 1)&"/"&mid(h, len(h)-2, 2)&"/"&h;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.functions.checkIfCronJobAllowed();
	setting requesttimeout="5000";
	request.ignoreSlowScript=true;

	arrURL=[];
	arrURL=application.zcore.app.getSiteMap(arrUrl);
	for(i=1;i LTE arraylen(arrURL);i++){
		link=arrURL[i].url;
		path=getNginxCachePath(link);
		echo(path&"<br>");
		/*if(fileexists(path)){
			echo("Path exists: "&path&"<br>");
		}*/
	}
	abort;


	writedump(arrURL);

	/*	
	db.sql="select * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
	where site.site_active =#db.param('1')# and 
	site_deleted = #db.param(0)# and 
	site_id <> #db.param('1')#";
	qs=db.execute("qs");
	for(row in qS){
		local.tempPath=application.zcore.functions.zGetDomainWritableInstallPath(row.site_short_domain);
		if(directoryexists(local.tempPath)){
			application.zcore.functions.zCreateDirectory(local.tempPath&'zupload/statichtml/');
			r=application.zcore.functions.zhttptofile("#row.site_domain#/z/misc/system/missing", local.tempPath&'zupload/statichtml/404.html');
		}
	}
	writeoutput('missing published');
	*/
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>