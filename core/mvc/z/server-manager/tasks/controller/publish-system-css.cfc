<cfcomponent>
<cfoutput>
<cffunction name="autoPublishAll" localmode="modern" access="remote">
	<cfscript> 
	var db=request.zos.queryObject; 
	application.zcore.functions.checkIfCronJobAllowed();
	request.ignoreSlowScript=true;
	setting requesttimeout="5000";
	db.sql="select site.site_id, site_domain 
	from #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# 
	where site.site_active =#db.param('1')# and 
	site_mvcpaths <> #db.param('')# and 
	site_deleted = #db.param(0)# and 
	site_id <> #db.param(-1)# ";
	qC=db.execute("qC");
	// later loop all domains with this feature enabled in server manager.
	for(row in qC){
		r1=application.zcore.functions.zdownloadlink(row.site_domain&"/z/admin/layout-global/autoPublish");
		if(r1.success){
			echo(r1.cfhttp.FileContent&"<br>");
		}else{
			echo('<h2>Failed to publish global layout css: #row.site_domain#/z/admin/layout-global/autoPublish</h2>');
			writedump(r1.cfhttp);
		} 
	}
	writeoutput('Done');
	abort;
	</cfscript>
</cffunction>

<cffunction name="updateGlobalBreakpointCSS" localmode="modern" access="remote">
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();
	layoutGlobalCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.layout-global");
	layoutGlobalCom.updateGlobalBreakpointCSS();
	echo('Done');
	abort;
	</cfscript>	
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	setting requesttimeout="4000";
	var db=request.zos.queryObject;
	
	application.zcore.functions.checkIfCronJobAllowed();
	db.sql="SELECT * 
	FROM  
	#db.table("site", request.zos.zcoreDatasource)# 
	WHERE 
	site_deleted = #db.param(0)# and  
	site_mvcpaths <> #db.param('')# and 
	site_active=#db.param(1)# and 
	site_id <> #db.param(-1)# "; 
	qSite=db.execute("qSite");
	for(row in qSite){
		link=row.site_domain&"/z/server-manager/tasks/publish-system-css/updateGlobalBreakpointCSS";
		r1=application.zcore.functions.zdownloadlink(link);
		if(r1.success){
			echo("<p>"&row.site_domain&": "&r1.cfhttp.FileContent&"</p>");
		}else if(structkeyexists(r1, 'cfhttp') and r1.cfhttp.status_code EQ "404"){
			echo("<p>"&row.site_domain&": not a valid jetendo site or dns has changed.</p>");
		}else{
			echo('<h2>Failed to publish system CSS: <a href="#link#" target="_blank">#link#</a></h2>');
			writedump(r1);
			abort;
		} 
	} 

	db.sql="SELECT menu.menu_id, menu.site_id 
	FROM #db.table("menu", request.zos.zcoreDatasource)# menu,
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE 
	site_deleted = #db.param(0)# and 
	menu_deleted = #db.param(0)# and
	site.site_id = menu.site_id and 
	site.site_active=#db.param(1)#";
	local.q=db.execute("q");
	menuFunctionsCom=createobject("component", "zcorerootmapping.com.app.menuFunctions");
	for(local.row in local.q){
		menuFunctionsCom.publishMenu(local.row.menu_id, local.row.site_id);
	}
	
	db.sql="UPDATE #db.table("slideshow", request.zos.zcoreDatasource)# slideshow
	SET	slideshow_hash=#db.param('')#,
	slideshow_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE 
	slideshow_deleted = #db.param(0)# and 
	site_id <> #db.param(-1)#";
	local.q=db.execute("q");
	
	for(i in application.sitestruct){
		if(structkeyexists(application.sitestruct[i], 'slideshowNameCacheStruct')){
			structclear(application.sitestruct[i].slideshowNameCacheStruct);
		}
		if(structkeyexists(application.sitestruct[i], 'slideshowIdCacheStruct')){
			structclear(application.sitestruct[i].slideshowIdCacheStruct);
		}
	}
	writeoutput('Done');
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>