<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	application.zcore.functions.checkIfCronJobAllowed();
	application.zcore.template.setPlainTemplate();
	</cfscript>
</cffunction>
<cffunction name="getMVCLandingPages" localmode="modern" access="public">
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
</cffunction>

<cffunction name="getSiteLinks" localmode="modern" access="public">
	<cfscript>
	siteMapCom=createobject("component", "zcorerootmapping.mvc.z.misc.controller.site-map");
	arrLinks=siteMapCom.getLinks(); 
	arrCache=[];
	arr1=application.zcore.arrLandingPage; 
	for(i=1;i<=arraylen(arr1);i++){
		arrayAppend(arrCache, request.zos.globals.domain&arr1[i]);
	}
	arr1=application.sitestruct[request.zos.globals.id].arrLandingPage; 
	for(i=1;i<=arraylen(arr1);i++){
		arrayAppend(arrCache, request.zos.globals.domain&arr1[i]);
	}
	for(i=1;i<=arraylen(arrLinks);i++){
		link=arrLinks[i].url;
		ext=application.zcore.functions.zGetFileExt(link);
		if(ext EQ "xml" or ext EQ "gz"){
			continue;
		}
		arrayAppend(arrCache, link);
	} 
	return arrCache;
	</cfscript>	
</cffunction>

<cffunction name="getCrawlProgress" localmode="modern" access="public">
	<cfscript>
	
	if(not structkeyexists(application, 'zCacheRobot')){
		return "Not running";
	}else{
		return application.zCacheRobot.progressCount&" of "&application.zCacheRobot.totalCount&" links have been published.";
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

<cffunction name="getSiteContentReport" localmode="modern" access="remote">
	<cfscript>
	init();
	setting requesttimeout="5000";

	db=request.zos.queryObject;
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_id <> #db.param(-1)# and 
	site_active = #db.param(1)# and 
	site_deleted=#db.param(0)# ";
	if(not request.zos.istestserver){
		db.sql&=" and site_live = #db.param(1)# ";
	}
	qSite=db.execute("qSite");
 
	totalCount=0;
	echo('<table class="table-list">');
	for(s in qSite){

		rs=application.zcore.functions.zDownloadLink(s.site_domain&"/z/server-manager/tasks/cache-robot/getSiteContentCount");
		if(rs.success){
			j=deserializeJSON(rs.cfhttp.filecontent);
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
		<a href="##" class="beginPublishLink">Begin Publishing</a> | 
		<a href="/z/server-manager/tasks/cache-robot/getSiteContentReport">Site Content Count Report</a>
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
		echo("disabled");abort;
	setting requesttimeout="5000";
	request.ignoreSlowScript=true;

	cachePath=request.zos.globals.privateHomeDir&"zcache/html/";
	application.zcore.functions.zCreateDirectory(cachePath);
 
	arrCache=getSiteLinks(); 

	application.zCacheRobot={
		totalCount:arrayLen(arrCache),
		progressCount:0
	};
	for(i=1;i LTE arraylen(arrCache);i++){
		link=arrCache[i];
		//echo(link&"<br>"); 

		// linkCachePath=application.zcore.cache.getLinkCachePath(link);
		destinationPath=cachePath&getDirectoryFromPath(linkCachePath);
		application.zcore.functions.zCreateDirectory(destinationPath);
		try{
			application.zcore.functions.zHTTPtoFile(link, cachePath&linkCachePath, 10, true);
			application.zCacheRobot.progressCount++;
		}catch(Any e){
			structdelete(application, 'zCacheRobot');
			savecontent variable="out"{
				echo('<h1>Failed to crawl link: '&link&"</h1>");
				writedump(e);
			}
			rs={success:false, message:out};
			application.zcore.functions.zReturnJson(rs);
		}
	}
	structdelete(application, 'zCacheRobot');
	rs={
		success:true,
		message:"Site publishing complete"
	}
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
	 
</cffunction>
</cfoutput>
</cfcomponent>