<cfcomponent>
<cfoutput>
<!--- 
// it will take 8 hours to publish 48,000 in single thread, 4 threads would be 2 hours.
// priority is the home page urls though which should be done in 1 to 2 hours each time. 
// TODO: need to move 404.html publishing from zcache to /zupload/statichtml, so nginx and backblaze can serve it
// done: parse links from home page to augment and crawl first before crawling the rest.  exclude external and # links.
// done: maybe home page more often
// TODO: individual site publish feature due to programmer wanting to force an update faster.
// TODO: maybe delete cache feature - to empty statichtml directory except for 404.html and empty statichtml table

 --->
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();
	request.ignoreSlowScript=true;
	application.zcore.template.setPlainTemplate();
	</cfscript>
</cffunction>
<!--- <cffunction name="getMVCLandingPages" localmode="modern" access="public">
	<cfargument name="arrUrl" type="array" required="yes">
	<cfscript>
	
	arrMVC=listToArray(request.zos.globals.mvcPaths, ",");
	mvcPathStruct={};
	for(i=1;i<=arraylen(arrMVC);i++){
		mvcPathStruct[arrMVC[i]]=true;
	}
	qD=directoryList(request.zos.globals.homedir, true, 'query', "*.cfc");
 
	for(row in qD){
		cfcPath=replace(row.directory&"/"&row.name, request.zos.globals.homedir, "");
		cfcPath=replace(replace(left(cfcPath, len(cfcPath)-4), "/", ".", "all"), "\", ".", "all"); 
		a=getcomponentmetadata(request.zRootCFCPath&cfcPath);//request.zRootCFCPath&"mvc.controller.about");
		//writedump(a);
		if(not structkeyexists(a, 'functions')){
			continue;
		}
		for(i=1;i<=arraylen(a.functions);i++){
			f=a.functions[i];
			if(not structkeyexists(f, 'jetendo-landing-page') or not f["jetendo-landing-page"]){
				// only cache explicitly labeled functions
				continue;
			}
			if(cfcPath EQ "index" and f.name EQ "index"){
				// home page
				continue;
			}
			arrPath=listToArray(cfcPath, ".");
			if(arrayLen(arrPath) GT 1 and structkeyexists(mvcPathStruct, arrPath[1])){
				// mvc url
				link="/"&replace(replace(removechars(cfcPath, 1, len(arrPath[1])+1), ".", "/", "all"), 'controller/', '')&"/"&f.name;
				arrayAppend(arguments.arrURL, link); 
			}else{
				// cfc url - don't crawl these
				continue;
				// arrayAppend(arrExtra, "/"&replace(cfcPath, ".", "/", "all")&".cfc?method="&f.name);
			}
		} 
	} 
	return arguments.arrURL;
	</cfscript>
</cffunction> --->

<cffunction name="getSiteLinks" localmode="modern" access="public">
	<cfscript>
	link=request.zos.globals.domain&"/?zMaintenanceMode=1";
	rs=application.zcore.functions.zDownloadLink(link);

	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("static_cache", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	static_cache_deleted=#db.param(0)# ";
	qCache=db.execute("qCache");
	cacheLookup={};
	for(row in qCache){
		cacheLookup[row.static_cache_url]=row;
	}
	staticCachePath=request.zos.globals.privateHomeDir&"zupload/statichtml/";
	application.zcore.functions.zCreateDirectory(staticCachePath);
	uniqueLink={};
	if(rs.success){
		ts={
			table:"static_cache",
			datasource:request.zos.zcoreDatasource,
			struct:{
				static_cache_url:request.zos.globals.domain&"/",
				static_cache_filename_md5:hash("/"),
				static_cache_hash:hash(rs.cfhttp.filecontent),
				static_cache_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				static_cache_priority:1,
				site_id:request.zos.globals.id,
				static_cache_processed:1,
				static_cache_deleted:0
			}
		};
		if(structkeyexists(cacheLookup, request.zos.globals.domain&"/")){
			if(ts.struct.static_cache_hash NEQ cacheLookup[request.zos.globals.domain&"/"].static_cache_hash){
				ts.struct.static_cache_id=cacheLookup[request.zos.globals.domain&"/"].static_cache_id;
				application.zcore.functions.zWriteFile(staticCachePath&ts.struct.static_cache_filename_md5&".html", rs.cfhttp.filecontent);
				application.zcore.functions.zUpdate(ts);
			}
		}else{ 
			application.zcore.functions.zWriteFile(staticCachePath&ts.struct.static_cache_filename_md5&".html", rs.cfhttp.filecontent);
			application.zcore.functions.zInsert(ts);
		}
		arrCache=listToArray( application.zcore.functions.zExtractLinksFromHTML(rs.cfhttp.filecontent), chr(9));
		arrayPrepend(arrCache, request.zos.globals.domain&"/");
 	}else{
 		throw("Failed to cache home page for #request.zos.globals.domain#");
	} 

	// arr1=application.zcore.arrLandingPage; 
	// for(i=1;i<=arraylen(arr1);i++){
	// 	arrayAppend(arrCache, arr1[i]);
	// }
	// arr1=application.sitestruct[request.zos.globals.id].arrLandingPage; 
	// for(i=1;i<=arraylen(arr1);i++){
	// 	arrayAppend(arrCache, arr1[i]);
	// }
	siteMapCom=createobject("component", "zcorerootmapping.mvc.z.misc.controller.site-map");
	arrLinks=siteMapCom.getLinks();  
	for(i=1;i<=arraylen(arrLinks);i++){
		link=replace(arrLinks[i].url, request.zos.globals.domain, ""); 
		ext=application.zcore.functions.zGetFileExt(link);
		if(ext EQ "xml" or ext EQ "gz"){
			continue;
		}
		ts={
			table:"static_cache",
			datasource:request.zos.zcoreDatasource,
			struct:{
				static_cache_url:request.zos.globals.domain&link,
				static_cache_filename_md5:hash(link),
				static_cache_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				static_cache_priority:3,
				site_id:request.zos.globals.id,
				static_cache_processed:0,
				static_cache_deleted:0
			}
		};
		if(structkeyexists(cacheLookup, request.zos.globals.domain&link)){
			ts.struct.static_cache_id=cacheLookup[request.zos.globals.domain&link].static_cache_id;
			structdelete(cacheLookup, request.zos.globals.domain&link); 
			application.zcore.functions.zUpdate(ts);
		}else{
			application.zcore.functions.zInsert(ts);
		}
		arrayAppend(arrCache, link);
	}  
	arrCache=getInternalLinks(arrCache, request.zos.globals.domain);
	arrCacheNew=[]; 
	for(link in arrCache){
		if(structkeyexists(uniqueLink, link)){
			continue;
		}
		if(link EQ "/"){
			continue;
		}
		uniqueLink[link]=true;
		// some of these db updates are redundant, but we need to set the priority to 2 for the home page links
		ts={
			table:"static_cache",
			datasource:request.zos.zcoreDatasource,
			struct:{
				static_cache_url:request.zos.globals.domain&link,
				static_cache_filename_md5:hash(link),
				static_cache_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				static_cache_priority:2,
				site_id:request.zos.globals.id,
				static_cache_processed:0,
				static_cache_deleted:0
			}
		};
		if(structkeyexists(cacheLookup, request.zos.globals.domain&link)){
			ts.struct.static_cache_id=cacheLookup[request.zos.globals.domain&link].static_cache_id;
			structdelete(cacheLookup, request.zos.globals.domain&link); 
			application.zcore.functions.zUpdate(ts);
		}else{
			application.zcore.functions.zInsert(ts);
		}
		arrayAppend(arrCacheNew, link);
	}
	arrCache=arrCacheNew; 
	for(link in cacheLookup){
		// delete statichtml file and database entry for urls no longer needed
		application.zcore.functions.zDeleteFile(staticCachePath&cacheLookup[link].static_cache_filename_md5&".html");
		db.sql="DELETE FROM #db.table("static_cache", request.zos.zcoreDatasource)# WHERE 
		static_cache_id=#db.param(cacheLookup[link].static_cache_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		static_cache_deleted=#db.param(0)#";
		db.execute("qDelete"); 
	}
	return arrCache;
	</cfscript>	
</cffunction>

<cffunction name="getCrawlProgress" localmode="modern" access="public">
	<cfscript>
	
	if(not structkeyexists(application, 'zCacheRobot')){
		return "Not running";
	}else{
		return application.zCacheRobot.progressCount&" of "&application.zCacheRobot.totalCount&" uncached links have been published.";
	}
	</cfscript>
</cffunction>
	
<cffunction name="getCrawlProgressJson" localmode="modern" access="remote">
	<cfscript>
	init();
	rs={ success:true, message: getCrawlProgress() };
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>


<cffunction name="getSiteContentCount" localmode="modern" access="remote">
	<cfscript>
	init();
	arrCache=getSiteLinks(); 
	rs={ success:true, count: arraylen(arrCache) };
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>

<cffunction name="getInternalLinks" localmode="modern" access="remote">
	<cfargument name="arrLink" type="array" required="yes">
	<cfargument name="domain" type="string" required="yes">
	<cfscript>
	arrNew=[];
	d=arguments.domain;
	d2=replace(d, "www.", "");
	d3=replace(d, "https:", "http:");
	d4=replace(d2, "https:", "http:");
 
 	uniqueStruct={};
	for(link in arrLink){
		link=trim(link);
		if(left(link, 1) EQ "##"){
			continue;
		}
		if(left(link, 11) EQ "javascript:"){
			continue;
		}
		// remove domain prefix
		link=replace(link, d, "");
		link=replace(link, d2, "");
		link=replace(link, d3, "");
		link=replace(link, d4, "");
		if(left(link, 6) EQ "https:" or left(link, 5) EQ "http:"){
			continue;
		}
		if(left(link, 1) NEQ "/"){
			link="/"&link;
		}
		link=replace(link, "/./", "/", "all");
		link=replace(link, "/../", "/", "all");
		arrLinkTemp=listToArray(link, "##");
		link=arrLinkTemp[1];
		uniqueStruct[link]=true;
	}
	arrNew=structkeyarray(uniqueStruct);
	return arrNew;
	</cfscript>
</cffunction>

<cffunction name="getSiteContentReport" localmode="modern" access="remote">
	<cfscript>
	init(); 
	setting requesttimeout="50000";



	db=request.zos.queryObject;
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_id <> #db.param(-1)# and 
	site_active = #db.param(1)# and 
	site_deleted=#db.param(0)# ";
	if(not request.zos.istestserver){
		db.sql&=" and 
	company_id=#db.param(2)# and site_live = #db.param(1)# ";
	}else{
		// force my site for faster debugging
		db.sql&=" and site_id = #db.param(23)# ";
	}
	qSite=db.execute("qSite");
 
	totalCount=0;
	echo('<table class="table-list">');
	for(s in qSite){
		link=s.site_domain&"/z/server-manager/tasks/cache-robot/getSiteContentCount"
		rs=application.zcore.functions.zDownloadLink(link);
		if(rs.success){
			try{
				j=deserializeJSON(rs.cfhttp.filecontent);
			}catch(Any e){
				savecontent variable="out"{
					echo("Failed: #link#<br>");
					echo("You may have to disable site live if this site is not meant to be cached<br>");
					writedump(e);
				}
				throw(out);
			}
			count=j.count;
			totalCount+=count;
			echo('<tr><td>'&s.site_short_domain&'</td><td>'&count&'</td></tr>');
		} 
	}
	echo('</table>');
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	init();
	a=getCrawlProgress();
	</cfscript>
	<h2>Cache Robot</h2>
	<div style="width:100%; float:left; height:30px;">
		<cfif request.zos.isTestServer>
		<a href="##" class="beginPublishLink">Begin Publishing</a> | 
		<cfelse>
			Publishing always runs on production as cron job once per minute | 
		</cfif>
		<a href="/z/server-manager/tasks/cache-robot/getSiteContentReport" target="_blank">Queue Site Content and Return Count Report</a>
	</div>
	<div class="outputDiv">#a#</div>
	<script>
	zArrDeferredFunctions.push(function(){ 
		var crawlProgressId=false;  
		function setupProgressInterval(){
			crawlProgressId=setInterval(function(){
				var tempObj={};
				tempObj.id="zRobotCacheProgress";
				tempObj.url="/z/server-manager/tasks/cache-robot/getCrawlProgressJson";
				tempObj.errorCallback=function(data){
					$(".outputDiv").html(data.responseText);
				};
				tempObj.callback=function(data){
					var r=eval('('+data+')');  
					$(".outputDiv").html(r.message); 
				};
				zAjax(tempObj);
			}, 1000);
		}
		$(".beginPublishLink").bind("click", function(e){
			e.preventDefault();
			$(this).hide();
			var tempObj={};
			tempObj.id="zRobotCache";
			tempObj.url="/z/server-manager/tasks/cache-robot/crawl";
			tempObj.errorCallback=function(data){
				clearInterval(crawlProgressId); 
				$(".beginPublishLink").show();
				$(".outputDiv").html(data.responseText);
			};
			tempObj.callback=function(data){
				var r=eval('('+data+')');
				$(".beginPublishLink").show();
				clearInterval(crawlProgressId); 
				$(".outputDiv").html(r.message); 
			};
			tempObj.cache=false;
			zAjax(tempObj);
			setupProgressInterval();

		});
		if($(".outputDiv").html() != "Not running"){
			setupProgressInterval();
		}
	});
	</script>
</cffunction>

<cffunction name="crawl" localmode="modern" access="remote">
	<cfscript>
	init(); 
	setting requesttimeout="50000";
	request.ignoreSlowScript=true;
 
  
	db=request.zos.queryObject;
	db.sql="SELECT count(static_cache_id) count FROM #db.table("static_cache", request.zos.zcoreDatasource)# WHERE 
	site_id <> #db.param(-1)# and 
	static_cache_deleted=#db.param(0)# and 
	static_cache_processed=#db.param(0)#";
	qCount=db.execute("qCount", "", 10000, "query", false);
	db.sql="SELECT * FROM #db.table("static_cache", request.zos.zcoreDatasource)# WHERE 
	site_id <> #db.param(-1)# and 
	static_cache_deleted=#db.param(0)# and 
	static_cache_processed=#db.param(0)#  
	ORDER BY static_cache_priority ASC 
	LIMIT #db.param(0)#, #db.param(1000)#";
	qCache=db.execute("qCache", "", 10000, "query", false);

	start=gettickcount();
	application.zCacheRobot={
		totalCount:qCount.count,
		progressCount:0,
		failCount:0
	};
	for(row in qCache){
		staticCachePath=application.zcore.functions.zvar("privateHomeDir", row.site_id)&"zupload/statichtml/";
		try{
			rs=application.zcore.functions.zDownloadLink(application.zcore.functions.zURLAppend(row.static_cache_url, "?zMaintenanceMode=1"));
			if(rs.success){
				static_cache_hash=hash(rs.cfhttp.filecontent);
				if(static_cache_hash NEQ row.static_cache_hash){
					application.zcore.functions.zWriteFile(staticCachePath&row.static_cache_filename_md5&".html", rs.cfhttp.filecontent);
				}
				db.sql="UPDATE #db.table("static_cache", request.zos.zcoreDatasource)# 
				SET 
				static_cache_processed=#db.param(1)#, 
				static_cache_hash=#db.param(static_cache_hash)#, 
				static_cache_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# 
				WHERE 
				site_id = #db.param(row.site_id)# and 
				static_cache_deleted=#db.param(0)# and 
				static_cache_id=#db.param(row.static_cache_id)# ";
				db.execute("qUpdate");
			}else{
				application.zCacheRobot.failCount++;
				// mark it as failed
				db.sql="UPDATE #db.table("static_cache", request.zos.zcoreDatasource)# 
				SET 
				static_cache_processed=#db.param(2)#, 
				static_cache_hash=#db.param('')#, 
				static_cache_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# 
				WHERE 
				site_id = #db.param(row.site_id)# and 
				static_cache_deleted=#db.param(0)# and 
				static_cache_id=#db.param(row.static_cache_id)# ";
				db.execute("qUpdate");
			}
			application.zCacheRobot.progressCount++;
		}catch(Any e){
			structdelete(application, 'zCacheRobot');
			savecontent variable="out"{
				echo('<h1>Failed to crawl link: '&row.static_cache_url&"</h1>");
				writedump(e);
			}
			rs={success:false, message:out};
			application.zcore.functions.zReturnJson(rs);
		}
		if(gettickcount()-start GT 57000){
			// stop publishing after 1 minute to let this task run again.
			break;
		}
	}
	rs={
		success:true,
		message:"Site publishing may still be running, but this one is done."
	}
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
	 
</cffunction>
</cfoutput>
</cfcomponent>