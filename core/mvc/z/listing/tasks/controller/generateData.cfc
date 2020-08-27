<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;
	var whereSQL=0;
	var r=0;
	var arrC=0;
	var fileName=0;
	var arrM=0;
	var arrMlsId=0; 
	var arrvalues=0;
	var qC=0;
	var qCity=0;
	var arrOut=0;
	var uniqueIdStruct=0;
	var m=0;
	var r1=0;
	var dbMLS=0;
	var ts=0;
	var fourHoursAgo=0;
	var qM=0;
	var i=0;
	
	application.zcore.functions.checkIfCronJobAllowed();
	var city_x_mls_updated_datetime=0;
	setting requesttimeout="5000";
	local.c=application.zcore.db.getConfig();
	local.c.verifyQueriesEnabled=false;
	local.c.datasource=request.zos.zcoreDatasource;
	local.c.autoReset=false;
	dbMLS=application.zcore.db.newQuery(local.c);
	request.ignoreSlowScript=true;
	
	if(request.zos.globals.id EQ request.zos.globals.serverid){
		db.sql="SELECT site_short_domain, site_domain, app_x_site.app_id, 
		site.site_id, CAST(GROUP_CONCAT(mls_id SEPARATOR #db.param(',')# ) AS CHAR) mlsIdList, site.site_id 
		FROM #db.table("site", request.zos.zcoreDatasource)# site, 
		#db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls, 
		#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
		WHERE site.site_id = app_x_site.site_id and 
		site_deleted = #db.param(0)# and 
		app_x_mls_deleted = #db.param(0)# and 
		app_x_site_deleted = #db.param(0)# and 
		app_x_site.app_id = #db.param(11)# and 
		site.site_active=#db.param(1)# AND 
		app_x_site_status=#db.param(1)# and 
		site.site_id = app_x_mls.site_id 
		GROUP BY app_x_mls.site_id";
		qM=db.execute("qM"); 
	}else{
		db.sql="SELECT site_short_domain, site_domain, app_x_site.app_id, 
		site.site_id, CAST(GROUP_CONCAT(mls_id SEPARATOR #db.param(',')# ) AS CHAR) mlsIdList, site.site_id 
		FROM #db.table("site", request.zos.zcoreDatasource)# site, 
		#db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls, 
		#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
		WHERE site.site_id = app_x_site.site_id and 
		site_deleted = #db.param(0)# and 
		app_x_mls_deleted = #db.param(0)# and 
		app_x_site_deleted = #db.param(0)# and
		app_x_site.app_id = #db.param(11)# and 
		app_x_site_status=#db.param(1)# and 
		site.site_active=#db.param(1)# AND 
		site.site_id = app_x_mls.site_id and 
		app_x_mls.site_id = #db.param(request.zos.globals.id)#
		GROUP BY app_x_mls.site_id";
		qM=db.execute("qM"); 
	}
	db.sql="select listing_mls_id, city.city_name, city.city_id, count(city.city_id) count 
	from #db.table("city_memory", request.zos.zcoreDatasource)# city, 
	#db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	where city.city_id = listing.listing_city  and 
	city_deleted = #db.param(0)# and 
	listing_deleted = #db.param(0)# 
	group by listing_mls_id, city_id ";
	qCity=db.execute("qCity");
	arrvalues=arraynew(1);
	city_x_mls_updated_datetime=request.zos.mysqlnow;
	for(ts in qCity){
		arrayappend(arrvalues,"('#ts.city_id#','#application.zcore.functions.zescape(ts.city_name)#','#ts.count#','#ts.listing_mls_id#','#city_x_mls_updated_datetime#', '0')");
	}
	if(arrayLen(arrValues) EQ 0){
		echo("The city table may be empty since no records were found while generating the city_x_mls table.<br />");
	}else{
		db.sql="REPLACE INTO #db.table("city_x_mls", request.zos.zcoreDatasource)#  (city_id, city_name, city_x_mls_count, listing_mls_id,city_x_mls_updated_datetime, city_x_mls_deleted) VALUES #db.trustedSQL(arraytolist(arrValues))#";
		db.execute("q"); 
		db.sql="DELETE FROM #db.table("city_x_mls", request.zos.zcoreDatasource)#  WHERE 
		city_x_mls_updated_datetime<#db.param(city_x_mls_updated_datetime)# and 
		city_x_mls_deleted = #db.param(0)#";
		db.execute("q"); 
	}
	if(request.zos.globals.id EQ request.zos.globals.serverid){
		application.zcore.searchformresetdate=now();
	}
	application.sitestruct[request.zos.globals.id].searchformresetdate=now();
	fourHoursAgo=dateadd("h",-4,now());
	fourHoursAgo=dateformat(fourHoursAgo,"yyyy-mm-dd")&" "&timeformat(fourHoursAgo,"HH:mm:ss");
	uniqueIdStruct=structnew();
	db.sql="DELETE FROM #db.table("search_count", request.zos.zcoreDatasource)# 
	WHERE search_count_datetime <=#db.param(fourHoursAgo)# and 
	search_count_deleted = #db.param(0)#";
	qC=db.execute("qC"); 
	for(ts in qM){ 
		if(structkeyexists(application.siteStruct, ts.site_id)){
			if(application.siteStruct[ts.site_id].app.appCache[qM.app_id].sharedStruct.optionStruct.mls_option_disable_search EQ 0){
				uniqueIdStruct[ts.mlsidlist]=true;
				arrM=listtoarray(ts.mlsidlist);
				arraysort(arrM,"numeric","asc");
				fileName=arraytolist(arrM,"-")&".js";
				arrMlsId=arraynew(1);
				for(i=1;i LTE arraylen(arrM);i++){
					arrayappend(arrMlsId,"listing_id like '#arrM[i]#-%'");	
				}
				whereSQL="("&arraytolist(arrMLSId," or ")&")";
				m=structnew();
				arrC=arraynew(1);
				arrOut=arraynew(1);
				r1=application.zcore.functions.zdownloadlink(ts.site_domain&"/z/listing/search-form-js/index?searchDisableExpandingBox=false&searchDisableExpandingBox=false&searchFormLabelOnInput=1&searchFormEnabledDropDownMenus=true&searchFormHideCriteriaList=1");
				if(r1.success EQ false){
					application.zcore.template.fail("Failed to download: "&ts.site_domain&"/z/listing/search-form-js/index?searchDisableExpandingBox=false&searchDisableExpandingBox=false&searchFormLabelOnInput=1&searchFormEnabledDropDownMenus=true&searchFormHideCriteriaList=1");
				}
				arrayappend(arrOut, chr(10)&r1.cfhttp.FileContent);
				if(r1.cfhttp.FileContent CONTAINS "<!DOCTYPE"){
					writeoutput(ts.site_id&" | site requires login, not saved.");
				}else{
					r=application.zcore.functions.zwritefile(application.zcore.functions.zGetDomainWritableInstallPath(ts.site_short_domain)&'zcache/listing-search-form.js', arraytolist(arrOut,""));
					writeoutput(r&" | "&ts.site_id&" | "&'listing-search-form.js saved<br />');
				}
			}else{
				application.zcore.functions.zdeletefile(application.zcore.functions.zGetDomainWritableInstallPath(ts.site_short_domain)&'zcache/listing-search-form.js');
			}
		}
	}
	echo('Done.');
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
