<cfoutput>

<cffunction name="onCodeDeploy" localmode="modern" access="public" returntype="any">
	<cfscript>
	// recreate CFCs if they date doesn't match
	application.zcore.functions.zClearCFMLTemplateCache();
	codeDeployCom=createobject("component", "zcorerootmapping.com.zos.codeDeploy");
	codeDeployCom.onCodeDeploy();
	</cfscript>
</cffunction>

<cffunction name="onExecuteCacheReset" localmode="modern" access="public">
	<cfscript>
	setting requesttimeout="3000";
	ts={
		success:true,
		reset:application.zcore.functions.zso(form, 'reset')
	};
	request.zos.zreset=ts.reset;
	backupGlobals=duplicate(request.zos.globals);
	// make sure file permissions are updated
	if(fileexists(request.zos.globals.privatehomedir&'__zdeploy-complete.txt')){
		while(true){
			sleep(100);
			if((gettickcount()-start)/1000 GT 30){
				break;
			}
			if(not fileexists(request.zos.globals.privatehomedir&'__zdeploy-complete.txt')){
				break;
			}
		}
	}
	if(request.zos.zreset EQ "site"){
		form.zForce=true;
		form.zreset="site";
	}
	
	if(request.zos.zreset EQ "code" or request.zos.zreset EQ "app" or request.zos.zreset EQ "site" or request.zos.zreset EQ "all"){
		onCodeDeploy(); 
	}
	if(request.zos.zreset EQ "app" or request.zos.zreset EQ "all"){
		onApplicationStart(); 
		OnInternalApplicationStart();
		OnApplicationListingStart();
	}
	if(request.zos.zreset EQ "site" or request.zos.zreset EQ "all"){
		local.temp34=structnew();
		local.temp34.site_id=request.zos.globals.id;
		local.temp34.globals=application.zcore.siteGlobals[request.zos.globals.id];//request.zos.globals;  
		local.temp34=application.zcore.functions.zGetSite(local.temp34);
		application.sitestruct[request.zos.globals.id]=local.temp34; 
	}else{
		request.zos.globals=backupGlobals;
	}
	if(request.zos.zreset EQ "all" or request.zos.zreset EQ "site" or request.zos.zreset EQ "app"){
		lock name="#request.zos.zcoreRootPath#-compilePackage" type="exclusive" timeout="30" throwontimeout="yes"{
			application.zcore.skin.compilePackage();
		}
	}
	if(request.zos.zreset EQ "cache"){
		application.zcore.functions.zOS_rebuildCache(); 
	}
	if(request.zos.zreset EQ "session" or request.zos.zreset EQ "all"){
		application.zcore.user.logOut(false, true);
		application.zcore.session.clear();
	}
	
	application.zcore.functions.zReturnJson(ts);
	</cfscript>
</cffunction>

<cffunction name="showInitStatus" localmode="modern" access="public">
	<cfscript>
	echo('<h2>Jetendo Init Status</h2>'); 
	echo('<p>'&structcount(application.zcoreSitesLoaded)&" of "&structcount(application.zcoreSiteDataStruct)&' sites loaded.</p>');

	if(structkeyexists(application,'OnInternalApplicationStartRunning')){
		echo('<p>Init is running. Please wait for it to complete.  You can refresh this page.</p>');
	}else{
		echo('<p>Init is NOT running</p>');
		echo('<p>Did the server fail to load properly? <a href="/?zReset=app&zforce=1&zcoreRunFirstInit=1" target="_blank">Run Init Again</a> | <a href="/z/server-manager/tasks/sync-sessions/index?testInitAllSites=1" target="_blank">Test Loading All Sites</a></p>');
	}

	if(structkeyexists(application, 'zcoreIsInit')){
		echo('<p>Jetendo Core is loaded</p>');
	}else{
		echo('<p>Jetendo Core is NOT loaded</p>');
	}
	if(structkeyexists(application, 'serverStartTickCount')){
		timeSinceStart=gettickcount()-application.serverStartTickCount;
		echo('<p>Server has been up for '&(timeSinceStart/1000)&' seconds.</p>');
		if(structkeyexists(application, 'serverStartCompletedTickCount')){
			timeCompleted=application.serverStartCompletedTickCount-application.serverStartTickCount;
			echo('<p>Jetendo initialization process completed in '&(timeCompleted/1000)&' seconds.</p>');
		}
	}
	totalTime=0;
	savecontent variable="out"{
		echo('<table><tr><th style="text-align:left;">Domain</th><th style="text-align:left;">Seconds to Load</th></tr>');
		for(id in application.zcoreSitesLoaded){
			row=application.zcoreSiteDataStruct[id];
			echo('<tr>');
			echo('<td><a href="#row.site_domain#" target="_blank">'&row.site_domain&'</a></td>');
			echo('<td>'&(application.zcoreSitesLoaded[id]/1000)&'</td>');
			echo('</tr>');
			totalTime+=application.zcoreSitesLoaded[id];
		}
		echo('</table>');
	}
	echo('<h3>Total to load sites: '&(totalTime/1000)&' seconds</h3>');
	echo(out);
	abort;
	</cfscript>
</cffunction>

<cffunction name="setSiteRequestGlobals" localmode="modern" access="public">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	id=arguments.site_id;
	row=application.zcoreSiteDataStruct[id];
	request.zos.cgi.http_host=replace(replace(row.site_domain, 'https://', ''), 'http://', '');
    local.zOSTempVar=replace(replacenocase(replacenocase(request.zos.cgi.http_host,'www.',''),'.'&request.zos.testDomain,''),".","_","all");
    Request.zOSHomeDir = request.zos.sitesPath&local.zOSTempVar&"/";
    Request.zOSPrivateHomeDir = request.zos.sitesWritablePath&local.zOSTempVar&"/";
    request.cgi_script_name=replacenocase(cgi.script_name,request.zRootPath,"/");  
    request.zRootDomain=replace(replace(lcase(request.zOS.CGI.http_host),"www.",""),"."&request.zos.testDomain,"");
    request.zCookieDomain=replace(lcase(request.zOS.CGI.http_host),"www.","");
    request.zRootPath="/"&replace(request.zRootDomain,".","_","all")&"/"; 
    request.zRootSecureCfcPath="jetendo-sites-writable."&replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";
    request.zRootCfcPath=replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";  
	</cfscript>
</cffunction>


<cffunction name="loadSite" localmode="modern" access="public">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	id=arguments.site_id;
	siteStartTickCount=getTickCount();
	ts=structnew(); 
	ts.globals=duplicate(application.zcore.serverglobals); 
	// consider loading this fresh right here instead of in zcore OnInternalApplicationStart
	row=application.zcoreSiteDataStruct[id]; 

	tempPath=application.zcore.functions.zGetDomainInstallPath(row.site_short_domain);
	tempPath2=application.zcore.functions.zGetDomainWritableInstallPath(row.site_short_domain);

	if(not fileexists(tempPath2&"_cache/scripts/global.json")){
		application.zcore.functions.zOS_cacheSiteAndUserGroups(id);
		application.zcore.functions.zCacheJsonSiteAndUserGroup(id, ts.globals);
		if(not fileexists(tempPath2&"_cache/scripts/global.json")){
			throw("Unable to publish global.json for site_id=#id#");
		}
	} 
	tempGlobal=deserializeJson(application.zcore.functions.zreadfile(tempPath2&"_cache/scripts/global.json"));
	structappend(tempGlobal, application.zcore.serverGlobals, false);
	tempGlobal.homeDir=tempPath;
	tempGlobal.secureHomeDir=tempPath;
	tempGlobal.privateHomeDir=tempPath2; 
	application.zcore.siteglobals[id]=tempGlobal;

	structappend(ts.globals, application.zcore.siteGlobals[id],true);
	
	ts.site_id=id;

	// temporarily force all the site globals so zGetSite can work correctly.
	request.zos.globals=application.zcore.siteglobals[id];
	setSiteRequestGlobals(id);

	// zGetSite MIGHT require the same domain to have been called
	ts=application.zcore.functions.zGetSite(ts);
	arrayClear(request.zos.arrQueryLog);
	application.siteStruct[id]=ts; 

	// storing how long it took to load this site
	application.zcoreSitesLoaded[id]=getTickCount()-siteStartTickCount;
	application.zcoreSitesListingLoaded[id]=application.zcoreSitesLoaded[id];

	structdelete(application.zcoreSitesPriorityLoadStruct, id);
	structdelete(application.zcoreSitesNotLoaded, id);
	structdelete(application.zcoreSitesNotListingLoaded, id);
	application.lastSiteLoad=now();
	</cfscript>	
</cffunction>



<cffunction name="loadNextListingSite" localmode="modern" access="public">
	<cfscript>
	// load sites in priority order
	arrPriority=duplicate(application.zcoreSitesArrPriorityListingLoad);
	application.zcoreSitesArrPriorityListingLoad=[]; 
	for(id in arrPriority){
		if(structkeyexists(application.zcoreSitesLoaded, id)){
			// site already loaded
			continue;
		}
		loadSite(id);
	}

	if(structkeyexists(form, 'testInitAllSites') or not request.zos.isTestServer){
		// load other site using db or sitePath
		for(id in application.zcoreSitesNotListingLoaded){
			loadSite(id);
			return true;
		} 
	}
	return false;
	</cfscript>
</cffunction>

<cffunction name="loadNextSite" localmode="modern" access="public">
	<cfscript>
	// load sites in priority order 
	arrPriority=duplicate(application.zcoreSitesArrPriorityLoad);
	application.zcoreSitesArrPriorityLoad=[]; 
	for(id in arrPriority){
		if(structkeyexists(application.zcoreSitesLoaded, id)){
			// site already loaded
			continue;
		}
		loadSite(id);
	}
	if(structkeyexists(form, 'testInitAllSites') or not request.zos.isTestServer){
		// load other site using db or sitePath
		for(id in application.zcoreSitesNotLoaded){
			loadSite(id);
			return true;
		} 
	}
	return false;
	</cfscript>
</cffunction>

<cffunction name="getSiteId" localmode="modern" access="public">
	<cfscript>
	site_id=0;
	temphomedir=Request.zOSHomeDir;  
	temphomedir=Request.zOSHomeDir;//replace(expandpath('/'),"\","/","all");
	tempdomain="http://"&lcase(request.zos.cgi.server_name);
	tempsecuredomain="https://"&lcase(request.zos.cgi.server_name); // need to be able to override this.

	request.zos.originalFormScope=duplicate(form);
	for(i in form){
		if(isSimpleValue(form[i])){
			form[i]=replace(replace(form[i], tempdomain&"/", '/', 'all'), tempsecuredomain&"/", '/', 'all');
		}
	} 

	if(structkeyexists(application, 'zcoreSitePaths')){
		if(structkeyexists(application.zcoreSitePaths, temphomedir)){
			site_id=application.zcoreSitePaths[temphomedir];
		}else if(structkeyexists(application.zcoreSitePaths, tempdomain)){
			// this is used for when the domain doesn't match the primary domain in the site globals
			site_id=application.zcoreSitePaths[tempdomain];
		}else if(structkeyexists(application.zcoreSitePaths, tempsecuredomain)){
			// this is used for when the domain doesn't match the primary domain in the site globals
			site_id=application.zcoreSitePaths[tempsecuredomain]; 
		}else if(request.zos.cgi.http_host EQ "127.0.0.2" or request.zos.cgi.http_host EQ "127.0.0.3"){
			site_id=1;
		} 
		// all domain redirects will fail until app and site are fully loaded.
		if(request.zos.isTestServer or (not structkeyexists(application.zcoreSitesLoaded, site_id) and not structkeyexists(application.zcoreSitesPriorityLoadStruct, site_id))){ 
			if(site_id NEQ 0){
				application.zcoreSitesPriorityLoadStruct[site_id]=true;
				if(structkeyexists(application.zcoreSitesNotListingLoaded, site_id)){
					arrayAppend(application.zcoreSitesArrPriorityListingLoad, site_id);
				}else{
					arrayAppend(application.zcoreSitesArrPriorityLoad, site_id);
				}
			}
		}
	} 
	return site_id;
</cfscript>
</cffunction>
	
<cffunction name="OnRequestStart" localmode="modern" access="public" returntype="any" output="true" hint="Fires at first part of page processing.">
  <cfargument name="TargetPage" type="string" required="true" /><cfscript>   
	if(request.zos.isDeveloperIpMatch and request.zos.cgi.HTTP_USER_AGENT CONTAINS 'Mozilla/' and request.zos.cgi.HTTP_USER_AGENT DOES NOT CONTAIN 'Jetendo'){
		if(structkeyexists(form, 'zInitStatus')){
			showInitStatus();
		}
	}   

	if(request.zos.isTestServer){
		// only on test server for now.
		request.zos.enableNewLeadManagement=true;
	}
	if((request.zos.isDeveloperIpMatch or request.zos.isServer)){
		if(structkeyexists(form, 'zForceReset')){
			structdelete(application,'onInternalApplicationStartRunning');
		}
 
		if(request.zos.originalURL EQ "/z/server-manager/tasks/sync-sessions/index"){
			// no site can take longer then 30 seconds to load - loading must have stopped
			if(structcount(application.zcoreSitesLoaded) NEQ structcount(application.zcoreSiteDataStruct)){
				if(dateCompare(application.lastSiteLoad, dateAdd("s", -30, now()) ) EQ -1){
					structdelete(application, 'onInternalApplicationStartRunning');
				}
				if(not structkeyexists(application,'onInternalApplicationStartRunning')){
					// once per minute, force init to run again if the sites are not all loaded yet and it is not already running.
					form.zcoreRunFirstInit=true;  
				}
			} 
		}
		if(structkeyexists(form, 'zcoreRunFirstInit')){ 
			application.serverStartTickCount=gettickcount();
			if(structkeyexists(application,'onInternalApplicationStartRunning') and not structkeyexists(form, 'zforce')){
				echo('Another request is running the application init process already, please wait for it to complete.');
				abort;
			}
			application.onInternalApplicationStartRunning=true;
			if(not structkeyexists(application, 'zcoreSitesArrPriorityLoad') or structkeyexists(form, 'zreset')){
				onApplicationStart();
			}  
			onInternalApplicationStart();
			site_id=getSiteId();    
			if(structkeyexists(form, 'testInitAllSites') or not request.zos.isTestServer or arrayLen(application.zcoreSitesArrPriorityLoad)){
				while(true){
					result=loadNextSite();
					if(result EQ false){
						// all sites loaded
						break;
					}
				}
			}
			if(structkeyexists(form, 'testInitAllSites') or not request.zos.isTestServer or arrayLen(application.zcoreSitesArrPriorityListingLoad)){
				// delay loading listing sites until the end
				OnApplicationListingStart();
				while(true){
					result=loadNextListingSite();
					if(result EQ false){
						// all sites loaded
						break;
					}
				}
			}
			structDelete(application, 'onInternalApplicationStartRunning');
			echo('Init Complete');
			if(request.zos.isTestServer){
				echo('<br>Want to test loading all sites? <a href="/z/server-manager/tasks/sync-sessions/index?testInitAllSites=1">Click here</a>');
			}
			abort;
		}else{
			site_id=getSiteId();
		}
	}else{
		site_id=getSiteId();
	}  
	// TODO need to avoid running this if the core is not fully loaded yet.
	if(request.zos.isTestServer and not structkeyexists(application,'onInternalApplicationStartRunning')){ 
		if(site_id NEQ 0){
			if(not structkeyexists(application,'zcore') or not structkeyexists(application.zcore,'functions')){
				onApplicationStart();
				OnInternalApplicationStart();
				loadSite(application.zcore.serverGlobals.serverid);
			}
			if(not structkeyexists(application.zcoreSitesLoaded, site_id)){ 
				setSiteRequestGlobals(site_id); 
				if(structkeyexists(application.zcoreSitesNotListingLoaded, site_id)){
					onApplicationListingStart(); 
					result=loadNextListingSite(); 
				}else{ 
					result=loadNextSite();
				}
				setSiteRequestGlobals(site_id);
			} 
		}
	}
	if(site_id EQ 0){
		checkDomainRedirect(); 
	}  
	if(not structkeyexists(application, request.zos.installPath&":displaySetupScreen")){
		if(not structkeyexists(application, 'zcoreIsInit') or not structkeyexists(application.zcoreSitesLoaded, site_id)){
			if(request.zos.isDeveloperIpMatch and request.zos.cgi.HTTP_USER_AGENT CONTAINS 'Mozilla/' and request.zos.cgi.HTTP_USER_AGENT DOES NOT CONTAIN 'Jetendo'){ 
				showInitStatus();
			}
			header statuscode="503" statustext="Service Temporarily Unavailable";
	    	header name="retry-after" value="60";
			echo('<h1>Service Temporarily Unavailable</h1>');
			if(request.zos.isdeveloper){
				writeoutput('<p>application.cfc OnInternalApplicationStart() is running. Site not loaded yet</p>');
			}
			abort;
		}
	}else{
		// continue so that first time setup will be able to run
	}
 
  	// output a cookie to enable hotlink protection on mls images and more.  Other scripts can abort request if cookie doesn't exist.
	ts={};
	ts.name="zenable";
	ts.value=1;
	ts.expires=CreateTimeSpan(0,0,request.zos.sessionExpirationInMinutes,0);
	application.zcore.functions.zCookie(ts);  
	/*
	// this may be causing the startup crash problem
	if(structkeyexists(application, 'zcoreLoadAgain') or (not structkeyexists(application, 'zcoreIsInit') and (request.zos.isserver or request.zos.isdeveloper or request.zos.istestserver))){
		structdelete(application, 'zcoreLoadAgain');
		lock name="#request.zos.installPath#|loadApplication" timeout="200" type="exclusive"{
			if(not structkeyexists(application, 'zcoreIsInit')){
				onApplicationStart();
			}
		}
	}
	if(not structkeyexists(application, 'zcoreIsInit') or not structkeyexists(application, 'zcore') or not structkeyexists(application.zcore, 'sitePaths')){
		header statuscode="503" statustext="Service Temporarily Unavailable";
    	header name="retry-after" value="60";
		echo('<h1>Service Temporarily Unavailable');abort;
	}*/

	s=gettickcount('nano'); 

	application.zcore.functions.zheader("P3P", "CP='Not using P3P, find the privacy policy on our site instead.'");
	 

	// TODO: figure out how to remove so I can use CFFLUSH in next version also in onRequest and onRequestEnd
	savecontent variable="local.output"{
		request.zos.requestLogEntry('Application.cfc onRequestStart begin');
		if(structkeyexists(application, 'zDeployExclusiveLock') and ((request.zos.isDeveloper EQ false and request.zos.isServer EQ false) or not structkeyexists(form, 'zreset') or form.zreset EQ "")){	
			setting requesttimeout="350";
			lock type="exclusive" timeout="300" throwontimeout="no" name="#request.zos.installPath#-zDeployExclusiveLock"{};
		} 
		request.zos.inMemberArea=false;
		request.zos.inServerManager=false;
		
		if(left(request.zos.originalURL, len("/z/server-manager/")) EQ "/z/server-manager/" or left(request.zos.originalURL, len("/z/_com/zos/app")) EQ "/z/_com/zos/app"){
			request.zos.inServerManager=true;
		}
		
		//local.s=gettickcount('nano');
		Request.zOSBeginFile=ArrayNew(1);
		Request.zOSEndFile=ArrayNew(1);
		request.zos.whiteSpaceEnabled=false;
		  
		if(not structkeyexists(application.zcore, 'session')){
			application.zcore.session=createobject("component", "zcorerootmapping.com.zos.session");
		}
		request.zsession=application.zcore.session.get();  
 
		if(structkeyexists(form,request.zos.urlRoutingParameter) EQ false){	
			return;	
		}
		request.zos.migrationMode=false;
		if(not request.zos.isDeveloper and (not structkeyexists(request.zsession, 'user') or not structkeyexists(request.zsession.user, 'company_id') or request.zsession.user.company_id NEQ 0)){
			request.zos.zreset="";
		}else{
			if(request.zos.isServer){
				request.zos.isServer=false;
				request.zos.isDeveloper=true;
			}
		}
		if(request.zos.isServer){
			application.zcore.functions.zNoCache();
		}else if(request.zos.isDeveloper or request.zos.isTestServer){
			// TODO add a way of testing nginx proxy cache here
			if(not structkeyexists(request.zos, 'testProxyCache') or not request.zos.testProxyCache){
				application.zcore.functions.zNoCache();
			}
		}
		if(request.zos.isDeveloper or request.zos.istestserver){
			if(isDefined('request.zsession.verifyQueries') EQ false and request.zos.istestserver){
				request.zsession.verifyQueries=true;
			}
			if(structkeyexists(form,'zDisableSystemCaching')){
				if(form.zDisableSystemCaching){
					request.zsession.zDisableSystemCaching=true;
					request.zos.disableSystemCaching=true;
				}else{
					structdelete(request.zsession,'zDisableSystemCaching');
				}
			}
			if(isDefined('request.zsession.zDisableSystemCaching')){
				request.zos.disableSystemCaching=true;
			}else{
				request.zos.disableSystemCaching=false;
			}
		}else{
			if(request.zos.isServer EQ false){
				request.zos.zreset="";
			}
			request.zos.disableSystemCaching=false;
		}
		if(request.zos.disableSystemCaching or not structkeyexists(application,'zcore') or not structkeyexists(application.zcore,'functions') or (request.zos.zreset EQ "app" or request.zos.zreset EQ "all")){
			onApplicationStart();
			OnInternalApplicationStart();
			OnApplicationListingStart();
		}
		if(request.zos.allowRequestCFC){
			request.zos.functions=application.zcore.functions;
		}
		//writeoutput(((gettickcount('nano')-local.s)/1000000000)&' seconds0restore session<br />');	local.s=gettickcount('nano');
		 
		 /*
		local.timeSpan=CreateTimeSpan( 0,0,request.zos.sessionExpirationInMinutes,0);
		if(structkeyexists(request.zsession, 'cfid') and structkeyexists(request.zsession, 'cftoken')){
			try{
				application.zcore.functions.zCookie({name:'cfid', value:request.zsession.cfid, expires: local.timeSpan });
				application.zcore.functions.zCookie({name:'cftoken', value:request.zsession.cftoken, expires:local.timeSpan });
				//application.zcore.functions.zCookie({name:'jsessionid', value:request.zsession.sessionid, expires:local.timeSpan });
			}catch(Any e){
				// ignore session cookie errors.
			}
		}*/

		if(structkeyexists(application, request.zos.installPath&":displaySetupScreen")){
			gs={
				datasource: request.zos.zcoreDatasource
			};
			t9=application.zcore.functions.getSiteDBObjects(gs);
			request.zos.db=t9.cacheEnabledDB;
			request.zos.dbNoVerify=t9.cacheEnabledNoVerifyDB;
			request.zos.queryObject=application.zcore.db.newQuery();
			request.zos.noVerifyQueryObject=request.zos.dbNoVerify.newQuery();
			setupCom=createobject("zcorerootmapping.setup");
			setupCom.index();
		}
		if(request.zos.allowRequestCFC){
			structappend(request.zos, application.zcore.componentObjectCache, true);
		}
		
		if(request.zos.disableSystemCaching or structkeyexists(application,'sitestruct') EQ false or structkeyexists(application.sitestruct, local.site_id) EQ false or  not structkeyexists(application.sitestruct[local.site_id], 'getSiteRan') or (request.zos.zreset EQ "site" or request.zos.zreset EQ "all")){
			local.temp34=structnew();
			local.temp34.site_id=local.site_id;
			local.temp34.globals=application.zcore.siteGlobals[local.site_id];//request.zos.globals;  
			local.temp34=application.zcore.functions.zGetSite(local.temp34);
			application.sitestruct[local.site_id]=local.temp34; 
		} 
		if(request.zos.allowRequestCFC){
			request.app=application.sitestruct[local.site_id];
		} 
		request.zos.globals=application.sitestruct[local.site_id].globals;  
		
		if(structkeyexists(application.zcore, 'databaseRestarted')){
			structdelete(application.zcore, 'databaseRestarted');
			form.zforce=true;
			form.zrebuildramtable=true;
			application.zcore.listingStruct=application.zcore.listingCom.onApplicationStart({});
		}
		request.zos.site_id=local.site_id;
		if(request.zos.isdeveloper and isDefined('request.zsession.verifyQueries') and request.zsession.verifyQueries){
			local.verifyQueriesEnabled=true;
		}else{
			local.verifyQueriesEnabled=false;
		}
		if(isDefined('request.zsession.user')){
			request.zos.db=application.sitestruct[request.zos.globals.id].dbComponents.cacheDisabledDB;
			request.zos.dbNoVerify=application.sitestruct[request.zos.globals.id].dbComponents.cacheDisabledNoVerifyDB;
		}else{
			request.zos.db=application.sitestruct[request.zos.globals.id].dbComponents.cacheEnabledDB;
			request.zos.dbNoVerify=application.sitestruct[request.zos.globals.id].dbComponents.cacheEnabledNoVerifyDB;
		}
		
		request.zos.queryObject=request.zos.db.newQuery();
		request.zos.noVerifyQueryObject=request.zos.dbNoVerify.newQuery();
		
		if(structkeyexists(form,'form_last_name') and len(form.form_last_name)){
			writeoutput('.<!-- stop spamming -->'); 
			application.zcore.functions.zabort();
		}
		if(structkeyexists(form,'zosdomainvalidation')){
			writeoutput('OK');
			application.zcore.functions.zabort();
		}
		variables.nowDate=request.zOS.mysqlnow;
		request.zos.onrequestcompleted=false;
		
		if(request.zos.allowRequestCFC){
			StructAppend(variables, request.zos.functions);
		}
		
		if(request.zos.isDeveloper and isdefined('request.zsession.debugleadrouting')){
			request.zos.debugleadrouting=true;
		}
		
		
		if(request.zos.isDeveloper or request.zos.isTestServer){
			if(structkeyexists(form, 'zOSDebuggerLastOutput')){
				form.znotemplate=1;
				if(isDefined('request.zsession.zOSDebuggerLastOutput')){
					writeoutput(request.zsession.zOSDebuggerLastOutput);
				}else{
					writeoutput('No debugging output available');
				}
				application.zcore.functions.zabort();
			}
		}else{
			request.zos.zreset="";
			form.zdebugurl=false;
		}
		if(not request.zos.enableSiteTemplateCache and request.zos.zreset EQ ""){
			application.zcore.functions.zUpdateSiteMVCData(application.sitestruct[request.zos.globals.id]);
			if(structkeyexists(application.zcore, 'compiledSiteTemplatePathCache')){
				structdelete(application.zcore.compiledSiteTemplatePathCache, request.zos.globals.id);
			}
			if(structkeyexists(application.zcore, 'templateCFCCache')){
				structdelete(application.zcore.templateCFCCache, request.zos.globals.id);
			}
		}


		ts2={
			enableCache:"everything", // One of these values: disabled, folders, everything |  keeps database record in memory for all operations
			storageMethod:"localFilesystem", // localFilesystem or cloudFile 

			// localFilesystem options
			publicRootAbsolutePath:request.zos.globals.privateHomeDir&"zupload/user/", 
			publicRootRelativePath:"/zupload/user/",
			internalRootRelativePath:"/zuploadinternal/user/"
		}; 
		// duplicate to avoid thread safety issues
		request.zos.siteVirtualFileCom = duplicate(application.zcore.componentObjectCache.virtualFile);
		//request.zos.siteVirtualFileCom = createobject("component", "zcorerootmapping.com.zos.virtualFile");
		request.zos.siteVirtualFileCom.init(ts2); 
		// force cache to exist
		if(not structkeyexists(application.siteStruct[request.zos.globals.id], 'virtualFileCache')){
			request.zos.siteVirtualFileCom.reloadCache(application.siteStruct[request.zos.globals.id]);
		}


		//writeoutput(((gettickcount('nano')-local.s)/1000000000)&' seconds0simple stuff<br />');	local.s=gettickcount('nano');
		//writeoutput(((gettickcount('nano')-local.s)/1000000000)&' seconds0<br />');	local.s=gettickcount('nano');
		request.zos.requestLogEntry('Application.cfc onRequestStart before onRequestStart1');
		variables.onRequestStart1();
		request.zos.requestLogEntry('Application.cfc onRequestStart before onRequestStart12');
		//writeoutput(((gettickcount('nano')-local.s)/1000000000)&' seconds1<br />');	local.s=gettickcount('nano');
		variables.onRequestStart12();
		request.zos.requestLogEntry('Application.cfc onRequestStart before onRequestStart2');
		//writeoutput(((gettickcount('nano')-local.s)/1000000000)&' seconds12<br />');	local.s=gettickcount('nano');
		variables.onRequestStart2();
		request.zos.requestLogEntry('Application.cfc onRequestStart before onRequestStart3');
		//writeoutput(((gettickcount('nano')-local.s)/1000000000)&' seconds2<br />');	local.s=gettickcount('nano');
		variables.onRequestStart3();
		request.zos.requestLogEntry('Application.cfc onRequestStart before onRequestStart4');
		//writeoutput(((gettickcount('nano')-local.s)/1000000000)&' seconds3<br />');	local.s=gettickcount('nano');
		variables.onRequestStart4();
		request.zos.requestLogEntry('Application.cfc onRequestStart after onRequestStart4');
		//writeoutput(((gettickcount('nano')-local.s)/1000000000)&' seconds4<br />');	local.s=gettickcount('nano');
	}
	if(request.zos.isDeveloper and structkeyexists(form, 'displayRunTime')){
		if(isDefined('request.zos.arrRunTime')){
			writeoutput('<h2>Script Run Time Measurements</h2>');
			arrayprepend(request.zos.arrRunTime, {time:request.zos.startTime, name:'Application.cfc onCoreRequest Start'});
			for(i=2;i LTE arraylen(request.zos.arrRunTime);i++){
				writeoutput(((request.zos.arrRunTime[i].time-request.zos.arrRunTime[i-1].time)/1000000000)&' seconds | '&request.zos.arrRunTime[i].name&'<br />');	
			}
		}
		abort; 
	} 
	//writeoutput(trim(local.output));
	request.zos.onRequestOutput="";
	request.zos.onRequestStartOutput=local.output;
	</cfscript>
</cffunction>

<cffunction name="onRequestStart1" localmode="modern" output="yes"><cfscript>

	if(not structkeyexists(request.zos.globals, 'enableNginxProxyCache') or request.zos.globals.enableNginxProxyCache EQ 0){
		application.zcore.functions.zNoCache();
	}
	if((request.zos.zreset EQ "session" or request.zos.zreset EQ "all")){
		application.zcore.user.logOut(false, true);
		application.zcore.session.clear();
	}
	variables.site_id=application.sitestruct[request.zos.globals.id].site_id; 
	
	request.zos.deployResetEnabled=false;
	
	if(structkeyexists(application.zcore.searchFormCache, request.zos.globals.id) EQ false){
		application.zcore.searchFormCache[request.zos.globals.id]=structnew();
	}

	if(structkeyexists(application.zcore, 'mlsImportIsRunning')){
		request.zos.mlsImportIsRunning=true;
	}else{
		request.zos.mlsImportIsRunning=false;
	}
	
	Request.zOS.debuggerEnabled = true;
	request.zos.autoresponderImagePath="/zupload/autoresponder/";
	request.zos.memberImagePath="/zupload/member/";
	
	// apply the default theme
	themeName=application.zcore.functions.zso(request.zos.globals, 'themeName', false, "custom");
	if(themeName EQ ""){
		themeName="custom";
	}
	if(structkeyexists(request.zsession, 'zCurrentTheme')){
		themeName=request.zsession.zCurrentTheme;
	}  
	if(themeName NEQ "custom"){	
		if(themeName CONTAINS "/" or themeName CONTAINS "\" or themeName CONTAINS "."){
			throw("Invalid theme name.  Cannot contain forward or backward slashes or period as these are reserved by the system.");
		}
		request.zos.themePath="/jetendo-themes/"&themeName&"/";
		request.zos.themeCFCPath="/jetendo-themes."&themeName&".";
		
		if(not application.sitestruct[request.zos.globals.id].hasTemplates){
			application.zcore.template.setTemplate(request.zos.themeCFCPath&"templates.default");
		}
	}else{
		request.zos.themePath="";
		request.zos.themeCFCPath="";
	}
	application.zcore.cache.init();
	
	if(structkeyexists(application.zcore,'resetApplicationTrackerStruct') and structkeyexists(application.zcore.resetApplicationTrackerStruct, variables.site_id)){
		structdelete(application.zcore.resetApplicationTrackerStruct, variables.site_id);
		local.temp34=structnew();
		local.temp34.site_id=variables.site_id;
		local.temp34.globals=request.zos.globals;
		local.temp34=application.zcore.functions.zGetSite(local.temp34);
		application.sitestruct[variables.site_id]=local.temp34;
		application.sitestruct[request.zos.globals.id]=application.sitestruct[variables.site_id];
	}
	
	
	request.zos.msieCheck = FindNoCase("msie", CGI.HTTP_USER_AGENT);
	if (request.zos.msieCheck){
	   request.zos.msieVersNum = Val(RemoveChars(CGI.HTTP_USER_AGENT, 1, request.zos.msieCheck + 4));
	   if (request.zos.msieVersNum LTE 6){
			application.zcore.template.disableDate();
		}
	}
	if(request.zos.cgi.SERVER_PORT NEQ "443"){
		if(1 EQ 1 or request.zos.istestserver or (structkeyexists(request.zos.globals,'multidomainenabled') and request.zos.globals.multidomainenabled EQ 0)){
			request.zos.staticFileDomain="";
		}else{
			request.zos.staticFileDomain="http://"&request.zos.globals.shortdomain&".flre.us";
		}
	}else{
		request.zos.staticFileDomain="";	
	}
	if(request.zos.isServer or request.zos.isDeveloper or request.zos.istestserver){
		if(structkeyexists(form,'znotemplate')){
			request.zOS.templateData.notemplate=true;
			request.znotemplate=true;
		}
		if(structkeyexists(form, 'zregeneratemodelcache')){
			local.tempCom=createobject("component","zcorerootmapping.com.model.base");
			local.tempCom._generateModels(application.sitestruct[request.zos.globals.id]);
			/*
			application.zcore.tracking.showTimer("Model cache regenerated");
			application.zcore.functions.zabort();
			*/
			structdelete(form,'zregeneratemodelcache');
		}
	}else{
		request.znotemplate=false;
	}
	
	
	request.zos.page=structnew();
	request.zos.page.setActions=application.zcore.functions.legacySetActions;
	request.zos.page.setDefaultAction=application.zcore.functions.legacySetDefaultAction;
	application.zcore.user.customSet = false;
	application.zcore.user.customStruct = StructNew();
	
	
	</cfscript>
</cffunction>

<cffunction name="onRequestStart12" localmode="modern" output="yes">
	<cfscript>
	var loginCom=0;
	if(structkeyexists(form,'zlogout')){
		application.zcore.user.logOut();
	}
	if(structkeyexists(cookie, 'ztoken')){
		application.zcore.user.verifyToken();
	}
	if(application.zcore.user.checkGroupAccess("user") and structkeyexists(application.zcore, 'forceUserUpdateSession')){
		if(structkeyexists(application.zcore.forceUserUpdateSession, request.zsession.user.site_id&":"&request.zsession.user.id)){
			application.zcore.user.updateSession({site_id:request.zos.globals.id});
		}
	}
	if(structkeyexists(request.zsession, 'user')){
		ts=structnew();
		ts.name="zLoggedIn";
		request.zos.userSession=duplicate(request.zsession.user);
		ts.value="1";
		ts.expires=this.sessiontimeout;
		application.zcore.functions.zCookie(ts); 

		ts=structnew();
		ts.name="zSessionExpireDate";
		ts.value=getHttpTimeString(now()+this.sessiontimeout);
		ts.expires=this.sessiontimeout;
		application.zcore.functions.zCookie(ts); 

		if(structkeyexists(request.zsession, 'user') and structkeyexists(request.zsession.user.groupAccess, "administrator")){
			ts=structnew();
			ts.name="zIsAdmin";
			ts.value="1";
			ts.expires=this.sessiontimeout;
			application.zcore.functions.zCookie(ts); 
		}else{
			ts=structnew();
			ts.name="zIsAdmin";
			ts.value="";
			ts.expires=this.sessiontimeout;
			application.zcore.functions.zCookie(ts); 
		}
		application.zcore.functions.zNoCache();
	}else{
		request.zos.userSession={groupAccess:{}};
	}

	if(form[request.zos.urlRoutingParameter] EQ "/z/user/login/confirmToken"){
		loginCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.user.controller.login");
		loginCom.confirmToken();
	}
	// structkeyexists(cookie,'zparentlogincheck') EQ false and 
	/*if(application.zcore.user.checkGroupAccess("user") EQ false){
		application.zcore.user.displayTokenScripts();
	} */
	
	if(request.zos.isDeveloper and structkeyexists(request.zos,'userSession') and structkeyexists(request.zos.userSession.groupAccess, "member")){
		application.zcore.skin.disableMinCat();
	}

	if(structkeyexists(application.zcore.skin, 'checkGlobalHeadCodeForUpdate')){
		application.zcore.skin.checkGlobalHeadCodeForUpdate();
	}
	if(structkeyexists(application.sitestruct[request.zos.globals.id],'globalHTMLHeadSourceArrCSS') EQ false or (structkeyexists(application.sitestruct[request.zos.globals.id],'app') and (request.zos.zreset EQ "all" or request.zos.zreset EQ "site" or request.zos.zreset EQ "app") or structkeyexists(application.sitestruct[request.zos.globals.id].skinObj,'curCompiledVersionNumber') EQ false)){
		lock name="#request.zos.zcoreRootPath#-compilePackage" type="exclusive" timeout="30" throwontimeout="yes"{
			if(structkeyexists(application.sitestruct[request.zos.globals.id],'globalHTMLHeadSourceArrCSS') EQ false or (structkeyexists(application.sitestruct[request.zos.globals.id],'app') and (request.zos.zreset EQ "all" or request.zos.zreset EQ "site" or request.zos.zreset EQ "app") or structkeyexists(application.sitestruct[request.zos.globals.id].skinObj,'curCompiledVersionNumber') EQ false)){
					application.zcore.skin.compilePackage();
			}
		}
	}
	
	if(request.zos.istestserver){
		request.searchServerCollectionName="entiresite-"&variables.site_id;
	} 
	request.zos.sslManagerEnabled=false;
	request.zos.currentHostName=request.zos.globals.domain;
	if(application.zcore.functions.zso(request.zos.globals, 'sslManagerDomain') NEQ ""){
		if(request.zos.globals.sslManagerDomain EQ request.zos.cgi.http_host){
			if(request.zos.cgi.server_port EQ 443){
				request.zos.domainAliasMatchFound=true; 
				request.zos.currentHostName='https://'&lcase(request.zos.cgi.http_host); 
				request.zRootDomain=request.zos.globals.sslManagerDomain;
				request.zCookieDomain=request.zos.globals.sslManagerDomain;
				request.zRootPath=replace(request.zos.globals.homedir, request.zos.sitesPath, '');
				request.zRootSecurePath=replace(request.zos.globals.privatehomedir, request.zos.sitesWritablePath, '');
				request.zOSHomeDir=request.zos.sitesPath&request.zRootPath; 
				request.zRootPath="/"&request.zRootPath;
				request.zRootCfcPath="jetendo-sites-writable."&replace(replace(request.zRootSecurePath,".","_","all"),"/",".","ALL")&".";  
				request.zos.sslManagerEnabled=true;
			}else{
				redirectURL='https://'&lcase(request.zos.globals.sslManagerDomain)&request.zos.originalURL&"?"&request.zos.cgi.query_string;  
				application.zcore.functions.z301Redirect(redirectURL);
			}
		}else if(application.zcore.user.checkGroupAccess("member")){
			redirectURL='https://'&lcase(request.zos.globals.sslManagerDomain)&request.zos.originalURL&"?"&request.zos.cgi.query_string;  
			application.zcore.functions.z301Redirect(redirectURL);
		}
	}  
	/*
	writedump(request.zos.globals.id);
	writedump(request.zos.globals.domainaliases);
	writedump(request.zos.cgi);
	abort;*/
	if(not request.zos.sslManagerEnabled){
		if(not request.zos.istestserver and variables.site_id EQ request.zos.globals.serverid){
			
			/*disabled while out of town.
			if(structkeyexists(request.zos.adminIpStruct, request.zos.cgi.remote_addr) EQ false){
				writeoutput('Access Denied');
				application.zcore.functions.zabort();
			}*/
			if(request.zos.cgi.server_port NEQ 443 and request.zos.isServer EQ false){
				//application.zcore.functions.z301redirect(request.zOS.zcoreAdminDomain&request.cgi_script_name&'?'&cgi.QUERY_STRING);	
			}
		}else if(request.zos.cgi.server_port EQ 443){
			if(replace(replace(request.zos.globals.securedomain,"http://",""),"https://","") NEQ request.zos.cgi.http_host){
				if(request.zos.globals.domainaliases NEQ ""){
					request.zos.arrDomainAliases=listtoarray(request.zos.globals.domainaliases,",");
					request.zos.domainAliasMatchFound=false;
					for(request.zos.__t99=1;request.zos.__t99 LTE arraylen(request.zos.arrDomainAliases);request.zos.__t99++){
						if(request.zos.cgi.http_host EQ request.zos.arrDomainAliases[request.zos.__t99]){
							request.zos.domainAliasMatchFound=true;
							break;	
						}
					}
					if(request.zos.domainAliasMatchFound EQ false){
						application.zcore.functions.z404("Secure domain doesn't match http_host and domain alias match not found");
					}
				}else{
					application.zcore.functions.z404("Secure domain doesn't match http_host.");	
				}
			}
			request.zos.currentHostName='https://'&lcase(request.zos.cgi.http_host); 
		    request.zRootDomain=replace(replace(lcase(replace(replace(request.zos.globals.domain, "http://",""), "https://", "")),"www.",""),"."&request.zos.testDomain,"");
		    request.zCookieDomain=replace(lcase(request.zRootDomain),"www.","");
		    request.zRootPath="/"&replace(request.zRootDomain,".","_","all")&"/";
		    request.zOSHomeDir=request.zos.sitesPath&replace(request.zRootDomain,".","_","all")&"/"; 
		    request.zRootSecureCfcPath="jetendo-sites-writable."&replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";
		    request.zRootCfcPath=replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";  
		}else if(replace(replace(request.zos.globals.domain,"http://",""),"https://","") NEQ request.zos.cgi.http_host){
			if(request.zos.globals.domainaliases NEQ ""){
				request.zos.arrDomainAliases=listtoarray(request.zos.globals.domainaliases,",");
				request.zos.domainAliasMatchFound=false;
				for(request.zos.__t99=1;request.zos.__t99 LTE arraylen(request.zos.arrDomainAliases);request.zos.__t99++){
					if(request.zos.cgi.http_host EQ request.zos.arrDomainAliases[request.zos.__t99]){
						request.zos.domainAliasMatchFound=true;
						request.zos.currentHostName='http://'&lcase(request.zos.cgi.http_host); 
						    request.zRootDomain=replace(replace(lcase(replace(replace(request.zos.globals.domain, "http://",""), "https://", "")),"www.",""),"."&request.zos.testDomain,"");
						    request.zCookieDomain=replace(lcase(request.zRootDomain),"www.","");
						    request.zRootPath="/"&replace(request.zRootDomain,".","_","all")&"/";
						    request.zOSHomeDir=request.zos.sitesPath&replace(request.zRootDomain,".","_","all")&"/"; 
						    request.zRootSecureCfcPath="jetendo-sites-writable."&replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";
						    request.zRootCfcPath=replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";  
						break;	
					}
				}
				if(request.zos.domainAliasMatchFound EQ false){
					application.zcore.functions.z404("Domain alias match not found");
				}
			}else{
				application.zcore.functions.z404("System domain (#replace(replace(request.zos.globals.domain,"http://",""),"https://","")# doesn't match host name (#request.zos.cgi.http_host#).");	
			}
		}
	}
	request.zos.templateData=structnew();
	application.zcore.template.init2(); 
	if(structkeyexists(form,request.zos.urlRoutingParameter) and form[request.zos.urlRoutingParameter] NEQ ""){
		 request.cgi_script_name=application.zcore.routing.processInternalURLRewrite(form[request.zos.urlRoutingParameter]);
		if(structkeyexists(form,'zdebugurl') and form.zdebugurl){
			writedump(form);
			writeoutput('processInternalURLRewrite:'&form[request.zos.urlRoutingParameter]&"<br />"&request.cgi_script_name&"<br />");
		}
	}
	request.zos.cgi.script_name=request.cgi_script_name;
	
	
	if(structkeyexists(form,'__zcoreinternalroutingpath') and len(form.__zcoreinternalroutingpath)-4 GT 0){
		request.zos.cgi.SCRIPT_NAME="/z/_#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
	}
	//request.zos.globals.domain=request.zos.currentHostName;
	request.officeEmail=request.zos.globals.emailCampaignFrom;
	if(application.zcore.functions.zvarso('zofficeemail') NEQ ""){
		request.officeEmail= application.zcore.functions.zvarso('zofficeemail');
	}
	if(request.zos.isTestServer){
		request.fromEmail=request.zos.developerEmailFrom;
	}else if(request.zos.globals.emailCampaignFrom NEQ ""){
		request.fromemail=request.zos.globals.emailCampaignFrom;
	}else if(request.zos.globals.adminEmail EQ ""){ 
		request.fromemail=request.zos.globals.adminEmail;
	}else{
		throw("Can't set request.fromemail for this site. Email Campaign From and Admin Email are required in site globals.");
	} 
	</cfscript>
</cffunction>

<cffunction name="onRequestStart2" localmode="modern" output="yes">
	<cfscript>
	if(request.zos.zreset EQ "cache"){
		setting requesttimeout="3000";
		application.zcore.functions.zOS_rebuildCache();
		application.zcore.functions.zredirect("/");
	}
	
	request.zos.emailData={
		sitePath:'/e/attachments/',
		from:'',
		absPath:request.zos.globals.serverhomedir&'static/e/attachments/',
		popserver:request.zos.globals.emailpopserver,
		username:request.zos.globals.emailusername,
		password:request.zos.globals.emailpassword,
		zemail_account_id:false
	};
	
	request.zos.httpCompressionType="deflate;q=0.5";
	request.zos.searchServerCollectionName="entiresite_verity";
	
	if(request.zos.istestserver){
		request.zos.searchServerCollectionName="entiresite-"&variables.site_id;
	}
	if(structkeyexists(form,'zab')){
		Request.zOS.debuggerEnabled=false;
		request.zos.trackingDisabled=true;
	}
	
	// stores a temporary return url
	if(structkeyexists(form, '___zr')){
		request.zsession.___zr=form.___zr;
	}
	if(structkeyexists(form, 'zsid') EQ false or isNumeric(form.zsid) EQ false){
		Request.zsid = application.zcore.status.getNewId();
	}else{
		Request.zsid = form.zsid;
	}
	
	
	if(left(request.zos.originalURL, len("/z/server-manager/api/")) EQ "/z/server-manager/api/"){
		
		ts = StructNew();
		ts.secureLogin=true;
		ts.noRedirect=true;
		ts.noLoginForm=true;
		ts.usernameLabel = "E-Mail Address";
		ts.loginMessage = "Please login";
		ts.template = "zcorerootmapping.templates.blank";
		ts.user_group_name = "serveradministrator";
		rs=application.zcore.user.checkLogin(ts);
		if(not rs.success){
			ts={
				success:false,
				errorMessage: "API login failed."
			}
			application.zcore.functions.zReturnJSON(ts);	
		}
		if(request.zos.originalURL EQ "/z/server-manager/api/server/executeCacheReset"){
			// manually execute reset because on needing to call functions that are in Application.cfc
			onExecuteCacheReset();
		}
		
	}
	if(request.zos.zreset EQ "code" or request.zos.zreset EQ "all"){
		variables.onCodeDeploy();
	}else if(structkeyexists(application.zcore, 'runOnCodeDeploy')){
		structdelete(application.zcore, 'runOnCodeDeploy');
		variables.onCodeDeploy();
	}
	
	//request.zOS.page.forceSynchronization = true;
	
	if(variables.site_id EQ request.zos.globals.serverid){
		if(structkeyexists(form,'zOpenIdDomain')){
			application.zcore.functions.zredirect(application.zcore.functions.zURLAppend(form.zOpenIdDomain, "zOpenIdGlobalLogin=1&zOpenIdDomainOriginal="&urlencodedformat(form.zOpenIdDomain)&"&"&request.zos.cgi.QUERY_STRING));
		}
	}
	request.zos.inMemberArea=false;
	local.requireMemberAreaLogin=false;
	if(left(request.cgi_script_name, 8) EQ "/member/" or (variables.site_id EQ request.zos.globals.serverid and request.zos.isServer EQ false and form[request.zos.urlRoutingParameter] NEQ "/z/user/login/serverToken")){
		local.requireMemberAreaLogin=true;	
	}
	if(local.requireMemberAreaLogin and structkeyexists(request.zos.adminIpStruct, request.zos.cgi.remote_addr) and request.zos.adminIpStruct[request.zos.cgi.remote_addr] EQ false and left(form[request.zos.urlRoutingParameter], 39) EQ "/z/server-manager/tasks/deploy-archive/"){
		local.requireMemberAreaLogin=false;	
	}
	var ipStruct={};
	var loginBypassIp=application.zcore.functions.zso(request.zos.globals, 'requireLoginByPassIpList');
	if(loginBypassIp NEQ ""){
		var arrIp=listToArray(loginBypassIp, ",");
		for(var i=1;i LTE arrayLen(arrIp);i++){
			ipStruct[arrIp[i]]=true;
		}
	} 
	if(request.zos.globals.parentId NEQ 0){
		loginBypassIp=application.zcore.functions.zvar('requireLoginByPassIpList', request.zos.globals.parentId);
		if(loginBypassIp NEQ ""){
			var arrIp=listToArray(loginBypassIp, ",");
			for(var i=1;i LTE arrayLen(arrIp);i++){
				ipStruct[arrIp[i]]=true;
			}
		} 
	}
	request.bypassLoginIPStruct=ipStruct;


	if(not request.zos.isServer and ((request.zos.globals.requireLogin EQ 1 and not structkeyexists(ipStruct, request.zos.cgi.remote_addr) and request.zos.cgi.HTTP_USER_AGENT DOES NOT CONTAIN "W3C_Validator") or local.requireMemberAreaLogin)){
		if(left(request.zos.originalURL, len("/z/user/invited")) NEQ "/z/user/invited" and request.cgi_script_name NEQ "/z/user/login/parentToken" and request.cgi_script_name NEQ "/z/user/login/serverToken" and request.cgi_script_name NEQ "/z/user/login/confirmToken" and left(request.cgi_script_name, 24) NEQ '/z/server-manager/tasks/'){
			if(request.zos.migrationMode){
				writeoutput('<h2>Server Migration In Progress</h2><p>Please try again in a few hours.</p>');
				application.zcore.functions.zabort();
			}
			if(local.requireMemberAreaLogin){
				request.zos.inMemberArea=true;
				application.zcore.skin.disableMinCat(); 
				if(application.zcore.functions.zso(request.zos.globals, 'sslManagerDomain') NEQ "" and not request.zos.sslManagerEnabled and request.zos.globals.sslManagerDomain NEQ request.zos.currentHostName){
					redirectURL='https://'&lcase(request.zos.globals.sslManagerDomain)&request.zos.originalURL&"?"&request.zos.cgi.query_string;  
					application.zcore.functions.z301Redirect(redirectURL);
				}
			}
			if(application.zcore.user.isCustomSet() EQ false){
				application.zcore.user.setCustomTable();
			}
			request.disablesharethis=true;
			// don't try to login again when already logged in
			if(not application.zcore.user.checkGroupAccess("user")){
				local.inputStruct = StructNew();
				if(request.zos.globals.requireSecureLogin EQ 1){
					inputStruct.secureLogin=true;
				}else{
					inputStruct.secureLogin=false;
				}
				local.inputStruct.usernameLabel = "E-Mail Address";
				local.inputStruct.loginMessage = "Please login";
				local.inputStruct.template = "zcorerootmapping.templates.blank";
				local.inputStruct.user_group_name = "user";
				application.zcore.user.checkLogin(local.inputStruct);
			}
			if(left(request.cgi_script_name, 8) EQ "/member/" or (variables.site_id EQ request.zos.globals.serverid and request.zos.isServer EQ false)){ 
				application.zcore.template.setTemplate("zcorerootmapping.templates.administrator",true,true);
			}
		}
	}else if(request.cgi_script_name EQ "/z/user/login/index"){ 
		request.zos.inMemberArea=true;
		application.zcore.skin.disableMinCat();
	}
	if(application.zcore.user.checkGroupAccess("user")){ 
		header name="Expires" value="0";
		header name="Pragma" value="no-cache";
		header name="Cache-Control" value="no-cache, no-store, must-revalidate";
		application.zcore.template.appendTag("scripts", '<script type="text/javascript">var zUserLoggedIn=true;</script>');
	}
	/*
	if(application.zcore.user.checkGroupAccess("member")){
		if(structkeyexists(form, 'zEnablePreviewMode')){
			request.zsession.enablePreviewMode=form.zEnablePreviewMode;
		}
	} */
	siteDomain=application.zcore.functions.zvar('domain');
	siteSecureDomain=application.zcore.functions.zvar('securedomain');
	if(siteSecureDomain EQ siteDomain){
		siteSecureDomain="";
	}
	siteDomain2=request.zos.currentHostName;
	if(siteDomain2 EQ siteDomain){
		siteDomain2="";
	}
	for(local.i in form){
		if(isSimpleValue(form[local.i])){
			if(form[local.i] CONTAINS siteDomain&"/"){
				form[local.i]=replacenocase(form[local.i], siteDomain&"/","/", "all");
			}
			if(len(siteSecureDomain)){
				if(form[local.i] CONTAINS siteSecureDomain&"/"){
					form[local.i]=replacenocase(form[local.i], siteSecureDomain&"/","/", "all");
				}
			}
			if(len(siteDomain2)){
				if(form[local.i] CONTAINS siteDomain2&"/"){
					form[local.i]=replacenocase(form[local.i], siteDomain2&"/","/", "all");
				}
			}
		}
	} 
	if(structkeyexists(form,'zab') EQ false){
		application.zcore.tracking.init();
	}
	application.zcore.functions.zRequireJquery();
	</cfscript>
</cffunction>

<cffunction name="onRequestStart3" localmode="modern" output="yes">
	<cfscript>
	/*if(isDefined('request.zsession.user.id')){
		request.zDBCacheTimeSpan=createtimespan(0,0,0,0);	
	}else{*/
		request.zDBCacheTimeSpan=createtimespan(0,0,0,0);
	// } 
	
	/*if(variables.site_id NEQ request.zos.globals.serverid){
		if(left(request.cgi_script_name, 18) EQ "/z/server-manager/"){
			if(request.zos.istestserver){
				application.zcore.functions.z404("Server manager is only accessible via <a href=""#request.zOS.zcoreTestAdminDomain#/"">#request.zOS.zcoreTestAdminDomain#/</a>.");	
			}else{
				application.zcore.functions.z404("Server manager is only accessible via <a href=""#request.zOS.zcoreAdminDomain#"">#request.zOS.zcoreAdminDomain#</a>.");	
			}
		}	
	}*/
	
	if(request.zos.istestserver and application.zcore.imageLibraryLastDeleteDate NEQ dateformat(now(),"yyyymmdd")){
		application.zcore.imageLibraryLastDeleteDate=dateformat(now(),"yyyymmdd");
		application.zcore.imageLibraryCom.deleteInactiveImageLibraries(true);
	}
  
	// zld = z login dump, this variable is a status session id that holds data from a login that is recreated after login
	if(structkeyexists(form, 'zld')){
		application.zcore.functions.zStatusHandler(form.zld,true,true);
	}
	application.zcore.template.prependContent(trim(application.zcore.app.onRequestStart()));
	application.zcore.template.prependTag("topcontent", '<div id="zTopContent" style="width:100%; float:left;"></div>');

	if(structkeyexists(request.zos,'scriptNameTemplate') EQ false){
		request.zos.scriptNameTemplate=cgi.script_name;
	}else{
		if(left(request.zos.scriptNameTemplate, 16) NEQ "/jetendo-themes/"){
			request.zos.scriptNameTemplate=request.zrootpath&removechars(request.zos.scriptNameTemplate,1,1);
		}
	}
	if(structkeyexists(form, 'zdebugurl') and form.zdebugurl){
		writeoutput("request.zos.scriptNameTemplate:"&request.zos.scriptNameTemplate&"<br />");
		application.zcore.functions.zabort();
	}
	
	if(request.zos.isDeveloper and request.zos.thisistestserver){
		if(form[request.zos.urlRoutingParameter] CONTAINS "/z/test/"){
			if(request.zos.globals.enableDemoMode NEQ "1"){
				application.zcore.template.fail("Test cases must be run on a demo web site with all application features enabled.");
			}
		}
	}
	</cfscript>

</cffunction>

<cffunction name="onRequestStart4" localmode="modern" output="yes"><cfscript>
	var local={};
	var i=0;
	var template=0;
	var cfcatch=0;
	// silenced output
	savecontent variable="local.output"{
		if(request.zos.inServerManager){
			application.zcore.functions.zNoCache();
			runningTask=false;
			if(left(request.cgi_script_name, 24) EQ '/z/server-manager/tasks/' and (request.zos.isServer or request.zos.cgi.remote_addr EQ "127.0.0.1")){
				runningTask=true;
			}
			if(not runningTask){
				if(not application.zcore.user.checkServerAccess()){
					ts = StructNew();
					ts.secureLogin=true;
					ts.noRedirect=true;
					ts.noLoginForm=true;
					ts.usernameLabel = "E-Mail Address";
					ts.loginMessage = "Please login";
					ts.template = "zcorerootmapping.templates.blank";
					ts.user_group_name = "serveradministrator";
					rs=application.zcore.user.checkLogin(ts);
				}else{
					if((left(request.cgi_script_name, 17) EQ '/z/listing/tasks/' or left(request.cgi_script_name, 24) EQ '/z/server-manager/tasks/') and structkeyexists(request.zsession, 'user') and not application.zcore.user.checkAllCompanyAccess()){
						application.zcore.status.setStatus(request.zsid, "Access denied.", form, true);
						application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
					}
				}
			}
			request.zos.requestLogEntry('Application.cfc onRequestStart4 after checkLogin');
			application.zcore.template.setTag("stylesheet","/z/stylesheets/manager.css",false);
			application.zcore.template.requireTag("title");
			application.zcore.template.setTag("title","Server Manager");
			if(not structkeyexists(request.zsession, 'global_zsites_id')){
				request.zsession.global_zsites_id = ",,,";
			}
			if(structkeyexists(form,'global_zsites_id1')){
				request.zsession.global_zsites_id = form.global_zsites_id1&","&form.global_zsites_id2&","&form.global_zsites_id3;
			}
			// init site navbar
			if(structkeyexists(form,'zid') EQ false){
				form.zid = application.zcore.status.getNewId();
			}
			if(structkeyexists(form,'zIndex')){
				application.zcore.status.setField(form.zid, "zIndex", form.zIndex);
			}else{
				form.zIndex = application.zcore.status.getField(form.zid, "zIndex");
				if(form.zIndex EQ ""){
					form.zIndex = 1;
				}
			}
			Request.zScriptName = request.cgi_script_name&"?zid=#form.zid#";
			if((isDefined('request.zsession.user.id') and not runningTask) and structkeyexists(form, 'zhidetopnav') eq false){
				application.zcore.template.setTag("secondnav",application.zcore.functions.zOS_getSiteNav(form.zid));
			}else if(not request.zos.isServer and not request.zos.isDeveloperIPMatch){
				application.zcore.functions.z404("Only logged on developer users or the server itself can access this url.");	
			}
		}
		if(structkeyexists(application.sitestruct[request.zos.globals.id],'zcorecustomfunctions')){
			structappend(variables, application.sitestruct[request.zos.globals.id].zcorecustomfunctions, true);
		}
		if(structkeyexists(application.sitestruct[request.zos.globals.id],'onSiteRequestStartEnabled') and application.sitestruct[request.zos.globals.id].onSiteRequestStartEnabled){
			application.sitestruct[request.zos.globals.id].zcorecustomfunctions.onSiteRequestStart(variables);
		}
		application.zcore.functions.zIncludeZOSFORMS();
		try{
			login applicationtoken="#application.applicationname#"{
			}
			if(isDefined('request.zsession.user.groupAccess') EQ false or structkeyexists(form,'zLogOut')){
				logout;
			}else if(structkeyexists(request.zsession, 'user')){
				if(request.zsession.secureLogin){
					local.roles = structkeylist(request.zsession.user.groupAccess);
				}else{
					local.roles="user";
				}
				local.pass=hash(request.zos.now&request.zos.zcoremapping&"+|secureKey");
				loginuser name="#request.zsession.user.email#" password="#local.pass#" roles="#local.roles#";
			}
		}catch(Any local.e){
			local.roles="";
		}
	}
	request.zos.requestLogEntry('Application.cfc onRequestStart4 before processRequestURL');
	application.zcore.routing.processRequestURL(request.zos.cgi.SCRIPT_NAME);
	</cfscript>
</cffunction>


<cffunction name="checkDomainRedirect" localmode="modern" access="public" output="yes">
	<cfscript>
	var host=request.zos.cgi.http_host;
	var ds=0;  
	if(not structkeyexists(application.zcore.domainRedirectStruct, host)){ 
		application.zcore.functions.z404("checkDomainRedirect resulted in 404 because the host name is not mapped to a site on this installation. Please configure the server manager."); 
		application.zcore.functions.zabort();
	}
	ds=application.zcore.domainRedirectStruct[host];
	var protocol='http://';
	if(ds.domain_redirect_secure EQ 1){
		protocol = 'https://';
	}
	var theURL=replace(replace(request.zos.originalURL, "https:/" , ""), "http:/" , "");
	//writedump(ds, true, 'simple');	abort;
	if(ds.domain_redirect_type EQ '3'){
		application.zcore.functions.z404("checkDomainRedirect resulted in 404 by intentional configuration by site_id = #ds.site_id#, domain: #ds.site_domain#."); 
	}else if(ds.domain_redirect_type EQ '2'){ // force to exact url
		if(ds.domain_redirect_mask EQ '1'){
			writeoutput('#application.zcore.functions.zHTMLDoctype()#
			<head><meta charset="utf-8" /><title>#htmleditformat(ds.domain_redirect_title)#</title>
			<style type="text/css">html{height:100%;}</style>
			</head><body style="margin:0px; height:100%;">
			<iframe frameborder="0" scrolling="auto" height="100%" width="100%" src="#protocol&ds.domain_redirect_new_domain#" />
			</body></html>');
			application.zcore.functions.zabort();
		}else{
			//writeoutput("force to exact url: #protocol&ds.domain_redirect_new_domain#");			abort;
			application.zcore.functions.z301Redirect("#protocol&ds.domain_redirect_new_domain#");
		}
	}else if(ds.domain_redirect_type EQ '1'){ // all to root
		if(ds.domain_redirect_mask EQ '1'){
			writeoutput('#application.zcore.functions.zHTMLDoctype()#<head><meta charset="utf-8" /><title>#htmleditformat(ds.domain_redirect_title)#</title>
			<style type="text/css">html{height:100%;}</style>
			</head><body style="margin:0px; height:100%;">
			<iframe frameborder="0" scrolling="auto" height="100%" width="100%" src="#protocol&ds.domain_redirect_new_domain#"/>
			</body></html>');
			application.zcore.functions.zabort();
		}else{
			//writeoutput('all to root: '&"#protocol&ds.domain_redirect_new_domain#/");			abort;
			application.zcore.functions.z301Redirect("#protocol&ds.domain_redirect_new_domain#/");
		}
	}else if(ds.domain_redirect_type EQ '0'){ // preserve url
		if(ds.domain_redirect_mask EQ '1'){
			writeoutput('#application.zcore.functions.zHTMLDoctype()#<head><meta charset="utf-8" /><title>#htmleditformat(ds.domain_redirect_title)#</title>
			<style type="text/css">html{height:100%;}</style>
			</head><body style="margin:0px; height:100%;">
			<iframe frameborder="0" scrolling="auto" height="100%" width="100%" src="#protocol&ds.domain_redirect_new_domain&theURL#"/>
			</body></html>');
			application.zcore.functions.zabort();
		}else{ 
			var tempUrl=theURL; 
			var a=[];
			for(var i in form){
				if(i NEQ "fieldnames" and i NEQ request.zos.urlRoutingParameter and not isNull(form[i]) and isSimpleValue(form[i])){
					arrayAppend(a, i&"="&urlencodedformat(form[i]));	
				}
			}
			var q=arrayToList(a, "&");
			if(len(q) NEQ 0){
				q="?"&q;
			}
			//writeoutput("no mask: #protocol&ds.domain_redirect_new_domain&tempURL&q#");			abort;
			application.zcore.functions.z301Redirect("#protocol&ds.domain_redirect_new_domain&tempURL&q#"); 
		}
	} 
	</cfscript>
</cffunction>
</cfoutput>