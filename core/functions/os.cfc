<cfcomponent extends="zcorerootmapping.functions.publishing">
<cfoutput>

<!--- application.zcore.functions.zSetPageHelpId("1.1"); --->
<cffunction name="zSetPageHelpId" access="public" localmode="modern" roles="member">
	<cfargument name="helpId" type="string" required="yes" hint="This is the numeric id for the help page resource.">
	<cfscript>
	if(not structkeyexists(request.zos, 'zPageHelpIdSet')){
		request.zos.zPageHelpIdSet=true;

		manualCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.admin.controller.manual");
		manualCom.init();
		cs=manualCom.getDocLink(arguments.helpid);
		if(cs.success){
			application.zcore.skin.addDeferredScript('zPageHelpId="'&jsStringFormat(cs.link)&'";');
		}
	}
	</cfscript>
</cffunction>

<cffunction name="getSystemIpStruct" localmode="modern" returntype="struct" access="public">

	<cfscript>
	d=application.zcore.functions.zSecureCommand("getSystemIpList", 10);
	
	arrD=listtoarray(d, chr(10));
	arrIp=arraynew(1);
	firstIp=false;
	defaultIpSet=false;
	defaultIp="";
	for(i=1;i LTE arraylen(arrD);i++){
		arrD[i]=trim(arrD[i]);
		if((arrD[i] DOES NOT CONTAIN "LOOPBACK" and arrD[i] DOES NOT CONTAIN "lo:") and defaultIpSet EQ false){
			firstIp=true;
		}
		if(left(arrD[i], 4) EQ "inet"){
			arrS=listtoarray(arrD[i], " ",false);
			arrS2=listtoarray(arrS[2], "/", false);
			arrayappend(arrIp, arrS2[1]);
			if(firstIp){
				defaultIp=arrS2[1];
				firstIp=false;
				defaultIpSet=true;
			}
		}
	} 
	if(not defaultIpSet){
		defaultIp=arrIp[1];	
	}
	return {
		defaultIp: defaultIp,
		arrIp=arrIp
	};
	</cfscript>
</cffunction>

 <!--- application.zcore.functions.zSecureCommand(command, timeoutInSeconds); --->
<cffunction name="zSecureCommand" localmode="modern" access="public" returntype="string">
	<cfargument name="command" type="string" required="yes">
	<cfargument name="timeoutInSeconds" type="numeric" required="yes">
	<cfscript>
	secureHashDate=hash(randrange(10000000, 90000000))&"-"&dateformat(now(),"yyyymmdd")&"-"&timeformat(now(),"HHmmss"); 
	startPath=request.zos.installPath&"execute/start/"&secureHashDate&".txt";
	activePath=request.zos.installPath&"execute/active/"&secureHashDate&".txt";
	completePath=request.zos.installPath&"execute/complete/"&secureHashDate&".txt";
	application.zcore.functions.zwritefile(startPath, arguments.command);
	
	startTime=gettickcount();
	arguments.timeoutInSeconds*=1000;
	while(true){
		sleep(100);
		if(fileexists(completePath)){
			contents=application.zcore.functions.zreadfile(completePath);
			application.zcore.functions.zdeletefile(activePath);
			application.zcore.functions.zdeletefile(completePath);
			return contents;
		}else if(gettickcount()-startTime GTE arguments.timeoutInSeconds){
			application.zcore.functions.zdeletefile(startPath);
			application.zcore.functions.zdeletefile(activePath);
			application.zcore.functions.zdeletefile(completePath);
			throw("Timeout occurred while running zSecureCommand: #listGetAt(arguments.command, 1, chr(9))#.  The temporary files were automatically deleted. You may need to verify the PHP cron job is working correctly if this command continues to fail.");
		}
	}
	</cfscript>
</cffunction>

<cffunction name="getSiteDBObjects" localmode="modern" access="public">
	<cfargument name="globalStruct" type="struct" required="yes">
	<cfscript>
	ts={};
	c=application.zcore.db.getConfig();
	c.cacheDisabled=false;
	if(request.zos.istestserver){
		c.verifyQueriesEnabled=true;
	}
	c.queryLogFunction=application.zcore.functions.zLogQuery;
	ts.cacheDisabledDB=duplicate(application.zcore.componentObjectCache.db);
	ts.cacheDisabledDB.init(c);
	
	c=application.zcore.db.getConfig();
	c.datasource=arguments.globalStruct.datasource;
	c.verifyQueriesEnabled=false;
	c.cacheDisabled=false;
	c.queryLogFunction=application.zcore.functions.zLogQuery;
	ts.cacheDisabledNoVerifyDB=duplicate(application.zcore.componentObjectCache.db);
	ts.cacheDisabledNoVerifyDB.init(c);
	
	c=application.zcore.db.getConfig();
	c.datasource=arguments.globalStruct.datasource;
	c.verifyQueriesEnabled=false;
	c.queryLogFunction=application.zcore.functions.zLogQuery;
	ts.cacheEnabledNoVerifyDB=duplicate(application.zcore.componentObjectCache.db);
	ts.cacheEnabledNoVerifyDB.init(c);
	
	c=application.zcore.db.getConfig();
	if(request.zos.istestserver){
		c.verifyQueriesEnabled=true;
	}
	c.datasource=arguments.globalStruct.datasource;
	c.queryLogFunction=application.zcore.functions.zLogQuery;
	ts.cacheEnabledDB=duplicate(application.zcore.componentObjectCache.db);
	ts.cacheEnabledDB.init(c);
	return ts;
	</cfscript>
</cffunction>

<cffunction name="zReturnJson" localmode="modern" access="public" output="yes">
	<cfargument name="data" type="any" required="yes">
	<cfscript>
	writeoutput(serializeJson(arguments.data));
	header name="x_ajax_id" value="#application.zcore.functions.zso(form, 'x_ajax_id')#";
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="zGenerateNginxMap" localmode="modern" access="public" output="no">
	<cfargument name="reloadNginx" type="boolean" required="no" default="#true#">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="select site_domain, site_enable_nginx_proxy_cache, site_short_domain, site_domainaliases, site_ssl_manager_domain from #db.table("site", request.zos.zcoreDatasource)# 
	where site_active=#db.param(1)# and 
	site_deleted = #db.param(0)# and 
	site_id <> #db.param(-1)# 
	GROUP BY site_short_domain 
	ORDER BY site_domain ";
	var qSite=db.execute("qSite");
	var arrTemp=[];
	arrTemp3=[];
	for(var row in qSite){
		var arrTemp2=listToArray(row.site_domainaliases,",");
		var primaryPath=replace(application.zcore.functions.zGetDomainInstallPath(row.site_short_domain), request.zos.installPath&"sites/", "");
		primaryPath=left(primaryPath, len(primaryPath)-1);
		var primaryDomain=replace(replace(row.site_domain, 'http://', ''), 'https://', '');
		arrayAppend(arrTemp, primaryDomain&' "'&primaryPath&'"; ## primary'&chr(10));
		for(var i=1;i LTE arrayLen(arrTemp2);i++){
			arrayAppend(arrTemp, trim(arrTemp2[i])&' "'&primaryPath&'";'&chr(10));
		}
		if(row.site_ssl_manager_domain NEQ ""){
			arrayAppend(arrTemp, trim(row.site_ssl_manager_domain)&' "'&primaryPath&'";'&chr(10));
		}
		arrayAppend(arrTemp, chr(10));
		if(row["site_enable_nginx_proxy_cache"] == "1"){
			arrayAppend(arrTemp3, "proxy_cache_path /var/jetendo-server/nginx/cache/#primaryPath# levels=1:2 keys_zone=#primaryPath#:1m max_size=500m inactive=5m;"&chr(10));
		}
	} 
	var output='map $http_host $zmaindomain {
	hostnames;
	default "No Host Matched";
	'&arrayToList(arrTemp, '')&'
	}'&chr(10)&arrayToList(arrTemp3, '');
	// let's make a backup only once.
	if(not fileexists(request.zos.sharedPath&'hostmap.conf.backup')){
		application.zcore.functions.zrenamefile(request.zos.sharedPath&'hostmap.conf', request.zos.sharedPath&'hostmap.conf.backup');
	}
	application.zcore.functions.zwritefile(request.zos.sharedPath&'hostmap.conf', output);
	
	db.sql="select * from #db.table("domain_redirect", request.zos.zcoreDatasource)# domain_redirect,
	#db.table("site", request.zos.zcoreDatasource)# site
	where site.site_active=#db.param(1)# and 
	site.site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)# and 
	domain_redirect_deleted = #db.param(0)# and 
	domain_redirect.site_id = site.site_id and 
	domain_redirect_deleted = #db.param(0)#  and 
	domain_redirect_type=#db.param(0)# and 
	domain_redirect_old_domain <> #db.param('')# and 
	domain_redirect_old_domain <> domain_redirect_new_domain
	GROUP BY domain_redirect_old_domain 
	ORDER BY domain_redirect_old_domain ";
	var qSite=db.execute("qSite");
	var arrTemp=[];
	for(var row in qSite){
		var primaryDomain=replace(replace(row.domain_redirect_old_domain, 'http://', ''), 'https://', '');
		var destinationDomain=replace(replace(row.domain_redirect_new_domain, 'http://', ''), 'https://', '');
		if(row.domain_redirect_secure EQ "1"){
			arrayAppend(arrTemp, primaryDomain&' "https://'&destinationDomain&'";'&chr(10));
		}else{
			arrayAppend(arrTemp, primaryDomain&' "http://'&destinationDomain&'";'&chr(10));
		}
	} 
	var output='map $http_host $zredirectdomain {
	hostnames;
	default "";
	'&arrayToList(arrTemp, '')&'
	}';
	if(not arguments.reloadNginx){
		return {success:true, message: "nginx hostmap published" };
	}
	application.zcore.functions.zwritefile(request.zos.sharedPath&'hostmap-redirect.conf', output);

	application.zcore.functions.zdeletefile(request.zos.sharedPath&'hostmap-execute-complete.txt');
	application.zcore.functions.zwritefile(request.zos.sharedPath&'hostmap-execute-reload.txt', "1");
	var start=gettickcount();
	while(true){
		if((gettickcount() - start)/1000 GT 10){
			return {success:false, message: "hostmap.conf published, but the 10 second timeout was reached while waiting for the web server to reload. Check that the cron job #request.zos.scriptsPath#newsite.php is still working." };
		}
		if(fileexists(request.zos.sharedPath&'/hostmap-execute-complete.txt')){
			var tempMessage=application.zcore.functions.zreadfile(request.zos.sharedPath&'/hostmap-execute-complete.txt');
			application.zcore.functions.zdeletefile(request.zos.sharedPath&'/hostmap-execute-complete.txt');
			return {success:true, message: tempMessage };
		}
		sleep(1);
	}
	</cfscript> 
</cffunction>

<cffunction name="zUpdateDomainRedirectCache" localmode="modern" access="public" output="no">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="SELECT domain_redirect.*, site.site_domain FROM 
	#db.table("domain_redirect", request.zos.zcoreDatasource)#, 
	#db.table("site", request.zos.zcoreDatasource)# 
	WHERE site.site_id = domain_redirect.site_id and 
	domain_redirect_deleted = #db.param(0)#  and 
	site_deleted = #db.param(0)# and 
	domain_redirect_deleted = #db.param(0)# and 
	site.site_id <> #db.param(-1)# ";
	var qDomain=db.execute("qDomain"); 
	var domainRedirectStruct={};
	for(var row in qDomain){
		domainRedirectStruct[row.domain_redirect_old_domain]=row;
	}
	application.zcore.domainRedirectStruct=domainRedirectStruct;

	</cfscript>
</cffunction>

<!--- 
var ts=application.zcore.functions.zGetEditableSiteOptionGroupSetById(["GroupName"], groupStruct.__setId);
ts.name="New name";
var rs=application.zcore.functions.zUpdateSiteOptionGroupSet(ts);
if(not rs.success){
	application.zcore.status.setStatus(rs.zsid, false, form, true);
	application.zcore.functions.zRedirect("/?zsid=#rs.zsid#");
}else{
	writeoutput('Success !');
}
 --->
<cffunction name="zUpdateSiteOptionGroupSet" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	return application.zcore.siteOptionCom.updateOptionGroupSet(arguments.struct);
	</cfscript>
</cffunction>


<cffunction name="zGetEditableSiteOptionGroupSetById" localmode="modern" access="public">
	<cfargument name="arrGroupName" type="array" required="yes">
	<cfargument name="site_x_option_group_set_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="no" default="#request.zos.globals.id#">  
	<cfscript>
	return application.zcore.siteOptionCom.getEditableOptionGroupSetById(arguments.arrGroupName, arguments.site_x_option_group_set_id, arguments.site_id);
	</cfscript>
</cffunction>

<cffunction name="zIsWidgetBuilderEnabled" localmode="modern" returntype="boolean" access="public">
	<cfscript>
	if(not application.zcore.user.hasSourceAdminAccess()){
		return false;
	}
	if(application.zcore.user.checkServerAccess()){
		return true;
	}else if(application.zcore.user.checkGroupAccess("administrator")){
		if(isdefined('request.zsession.user.enableWidgetBuilder') and request.zsession.user.enableWidgetBuilder EQ 1){
			return true;
		}else{
			return false;
		}
	}else if(application.zcore.functions.zso(request.zos.globals,'widgetBuilderEnabled',false,0) NEQ 1){
		 return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="zRequireTimePicker" localmode="modern" access="public">
	<cfscript>
	if(structkeyexists(request.zos, 'timePickerOutput')){
		return;
	}
	application.zcore.functions.zRequireJqueryUI();
	request.zos.timePickerOutput=true;
	application.zcore.skin.includeCSS("/z/javascript/jquery/timePicker/timePicker.css");
	application.zcore.skin.includeJS("/z/javascript/jquery/timePicker/jquery.timePicker.js");
	</cfscript>
</cffunction>

<cffunction name="zGetRootCFCPath" localmode="modern">
	<cfargument name="shortDomain" type="string" required="yes">
	<cfscript>
	var domain=replace(replace(arguments.shortDomain,'www.',''),"."&request.zos.testDomain,"");
	return replace(replace(domain,".","_","all"),"/",".","ALL")&".";
	</cfscript>
</cffunction>
<cffunction name="zRootSecureCfcPath" localmode="modern">
	<cfargument name="shortDomain" type="string" required="yes">
	<cfscript>
	var domain=replace(replace(arguments.shortDomain,'www.',''),"."&request.zos.testDomain,"");
	return "jetendo-sites-writable."&replace(replace(domain,".","_","all"),"/",".","ALL")&".";
	</cfscript>
</cffunction>

<cffunction name="zStatusHandler" localmode="modern" returntype="any" output="true">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="getVars" type="boolean" required="no" default="#false#">
	<cfargument name="silent" type="boolean" required="no" default="#false#">
	<cfargument name="targetStruct" type="struct" required="no" default="#form#">
	<cfscript>
	var statusStruct = StructNew();
	var arrErrors = ArrayNew(1);
	statusStruct = application.zcore.status.getStruct(arguments.id);
	arrErrors = application.zcore.status.getErrors(arguments.id);
	if(isDefined('statusStruct.arrMessages')){
		if(arguments.getVars){
			StructAppend(arguments.targetStruct, statusStruct.varStruct, true);
		}
		if(arguments.silent EQ false){
			if(ArrayLen(statusStruct.arrMessages) GT 0 or ArrayLen(arrErrors) GT 0){
				writeoutput('<div style="float:left;width:100%;"><div style=" width:100%; overflow:hidden; display:block; clear:both; margin-bottom:10px;">');
			}
			if(ArrayLen(statusStruct.arrMessages) GT 0){
				writeoutput('<div style="display:block; clear:both;float:left; color:##FFFFFF; width:98%; padding:1%; background-color:##990000; font-weight:bold;">Status:</div>');
				writeoutput('<div style="display:block; clear:both;float:left; color:##000000;width:98%; padding:1%; border-bottom:1px solid ##660000; background-color:##FFFFFF;"><p style="padding-bottom:0px;">'&ArrayToList(statusStruct.arrMessages, '</p><hr /><p style="padding-bottom:0px;">')&'</p></div>');
				if(ArrayLen(arrErrors) GT 0){
					writeoutput('');
				}
			}
			if(ArrayLen(arrErrors) GT 0){
				writeoutput('<div style="display:block; clear:both;float:left; color:##FFFFFF; width:98%; padding:1%; font-weight:bold; background-color:##993333;">The following errors occurred:</div>');
				writeoutput('<div style="display:block; clear:both;float:left; color:##000000; width:98%; padding:1%; border-bottom:1px solid ##660000; background-color:##FFFFFF;"><p style="padding-bottom:0px;">'&ArrayToList(arrErrors, '</p><hr /><p style="padding-bottom:0px;">')&'</p></div>');
			}
			if(ArrayLen(statusStruct.arrMessages) GT 0 or ArrayLen(arrErrors) GT 0){
				writeoutput('</div></div><br style="clear:both;" />');
			}
		}
	}
	</cfscript>
</cffunction>


<cffunction name="zIsDeveloper" localmode="modern" returntype="boolean" output="no">
	<cfscript>
	return request.zos.isDeveloper;
    </cfscript>
</cffunction>

<cffunction name="zUpdateCustomSiteFunctions" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	if(arguments.ss.site_id EQ request.zos.globals.serverId){
		com=application.zcore.functions.zcreateobject("component", "zcorerootmapping.zCoreCustomFunctions", true);
		//structappend(ts.zcorecustomfunctions, com, true);
		arguments.ss.zcorecustomfunctions=com;
		if(structkeyexists(arguments.ss.zcorecustomfunctions, 'onSiteRequestStart')){
			arguments.ss.onSiteRequestStartEnabled=true;
		}
		if(structkeyexists(arguments.ss.zcorecustomfunctions, 'onSiteRequestEnd')){
			arguments.ss.onSiteRequestEndEnabled=true;
			
		}
	}else if(fileexists(arguments.ss.globals.homedir&'zCoreCustomFunctions.cfc')){
		com=application.zcore.functions.zcreateobject("component", request.zRootCfcPath&"zCoreCustomFunctions", true);
		//structappend(arguments.ss.zcorecustomfunctions, com, true);
		arguments.ss.zcorecustomfunctions=com;
		if(structkeyexists(arguments.ss.zcorecustomfunctions, 'onSiteRequestStart')){
			arguments.ss.onSiteRequestStartEnabled=true;
		}
		if(structkeyexists(arguments.ss.zcorecustomfunctions, 'onSiteRequestEnd')){
			arguments.ss.onSiteRequestEndEnabled=true;
			
		}
	}else{
		arguments.ss.zcoreCustomFunctions={};
		arguments.ss.onSiteRequestStartEnabled=false;
		arguments.ss.onSiteRequestEndEnabled=false;
	}
	</cfscript>
</cffunction>

<cffunction name="zGetSite" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	
	var db2=0;
	var template=0;
	var ts=structnew();
	application.zcore.functions.zClearCFMLTemplateCache();
	request.zos.requestLogEntry('Application.cfc getSite begin');
	request.zos.globals=arguments.ss.globals;
	request.zos.site_id=request.zos.globals["id"];
	ts.globals=arguments.ss.globals;
	ts.site_id=arguments.ss.globals.id;
	request.zRootDomain=replace(replace(request.zos.globals.shortDomain,'www.',''),"."&request.zos.testDomain,"");
	request.zRootPath="/"&replace(request.zRootDomain, ".","_","all")&"/";
	request.zRootSecureCfcPath="jetendo-sites-writable."&replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";
	request.zRootCfcPath=replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";
	tempInstallPath=application.zcore.functions.zGetDomainInstallPath(request.zRootDomain);
	request.zos.globals.homedir=application.zcore.functions.zGetDomainInstallPath(request.zos.globals.shortDomain); 
	request.zos.globals.privatehomedir=application.zcore.functions.zGetDomainWritableInstallPath(request.zos.globals.shortDomain); 
	request.zos.globals.securehomedir=tempInstallPath; 
	if(request.zos.globals.disableCFML EQ 1){
		return ts;
	}
	ts.hasTemplates=false;
	if(directoryexists(request.zos.globals.homedir&"templates/")){
		ts.hasTemplates=true;
	}
	ts.administratorTemplateMenuCache={};

	request.zos.db=application.zcore.componentObjectCache.db;
	ts.dbComponents=application.zcore.functions.getSiteDBObjects(ts.globals);
	
	request.zos.queryObject=ts.dbComponents.cacheEnabledDB.newQuery();
	request.zos.noVerifyQueryObject=ts.dbComponents.cacheEnabledNoVerifyDB.newQuery();
	
	
	ts.comCache=structnew();
	ts.contentPageIDCache=structnew();
	ts.contentPageCache=structnew();
	ts.blogArticleIDCache=structnew();
	ts.blogArticleCache=structnew();
	ts.blogCategoryIDCache=structnew();
	ts.blogCategoryCache=structnew();
	ts.blogTagIDCache=structnew();
	ts.blogTagCache=structnew();
	ts.directoryExistsCache=structnew();
	ts.fileExistsCache=structnew();
	ts.onSiteRequestStartEnabled=false;
	ts.onSiteRequestEndEnabled=false;
	
	application.zcore.functions.zUpdateCustomSiteFunctions(ts);
	
	ts.menuIdCacheStruct=structnew();	
	ts.menuNameCacheStruct=structnew();	
	ts.slideshowIdCacheStruct=structnew();
	ts.slideshowNameCacheStruct=structnew();
 
	</cfscript>

	<cfsavecontent variable="request.zos.noVerifyQueryObject.sql">
	SHOW DATABASES like '#ts.globals.datasource#'
	</cfsavecontent><cfscript>qA=request.zos.noVerifyQueryObject.execute('qA');</cfscript>
	<cfif qA.recordcount EQ 0>
		<cfthrow type="exception" message="ERROR: The database and datasource name must be identical. #ts.globals.datasource# does not exist in database server. Please correct site globals.">
	</cfif>
	<cfscript>
	ts.cacheData={
		urlDatabaseCache={},
		databaseURLCache={}
	};
	if(not directoryexists(ts.globals.privatehomedir&"zupload")){
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zupload");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zupload/user");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zupload/library");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zupload/slideshow");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zupload/video");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zupload/ssi");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zupload/site-options");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zupload/member");
	}
	if(not directoryexists(ts.globals.privatehomedir&"zuploadsecure")){
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zuploadsecure");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zuploadsecure/user");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zuploadsecure/library");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zuploadsecure/slideshow");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zuploadsecure/video");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zuploadsecure/ssi");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zuploadsecure/site-options");
		application.zcore.functions.zcreatedirectory(ts.globals.privatehomedir&"zuploadsecure/member");
	}
	
	
	application.zcore.functions.zUpdateSiteMVCData(ts);

	
	ts.imageLibraryStruct=structnew();
	ts.imageLibraryStruct.sizeStruct=structnew();
	
	//structdelete(request,'app');
	if(request.zos.allowRequestCFC){
		request.zos.routing=application.zcore.componentObjectCache.routing;
	}
	routingCom= application.zcore.componentObjectCache.routing;
	routingCom.initRewriteRuleApplicationStruct(ts);
	
	appCom =application.zcore.app;
	appCom.onSiteStart(ts);
	ts.adminFeatureMapStruct=application.zcore.adminSecurityFilter.getFeatureMap(ts);
	
	skin=application.zcore.skin;
	skin.onSiteStart(ts);
	
	ts.leadRoutingStruct=application.zcore.functions.zGetLeadRoutesStruct();


	ts2={
		enableCache:"everything", // One of these values: disabled, folders, everything |  keeps database record in memory for all operations
		storageMethod:"localFilesystem", // localFilesystem or cloudFile 

		// localFilesystem options
		publicRootAbsolutePath:request.zos.globals.privateHomeDir&"zupload/user/", 
		publicRootRelativePath:"/zupload/user/",
		internalRootRelativePath:"/zuploadinternal/user/"
	}; 
	// duplicate to avoid thread safety issues
	virtualFileCom = duplicate(application.zcore.componentObjectCache.virtualFile);
	virtualFileCom.init(ts2);
	virtualFileCom.reloadCache(ts);
 
	if(fileexists(request.zos.globals.privateHomeDir&"zupload/settings/icon-logo-original.png")){
		ts.iconLogoExists=true;
	}

	if(structkeyexists(application.zcore, 'templateCFCCache') and structkeyexists(application.zcore.templateCFCCache, request.zos.globals.id)){
		structclear(application.zcore.templateCFCCache[request.zos.globals.id]);
	}
	if(structkeyexists(application.zcore, 'compiledSiteTemplatePathCache') and structkeyexists(application.zcore.compiledSiteTemplatePathCache, request.zos.globals.id)){
		structclear(application.zcore.compiledSiteTemplatePathCache[request.zos.globals.id]);
	}

	ts.getSiteRan=true;
	request.zos.requestLogEntry('Application.cfc getSite end');


	// update the jetendo init configuration
	query name="qS" datasource="#request.zos.zcoreDatasource#"{
		writeoutput("SELECT site.site_id, site_short_domain, site_domain,
		if(app_x_site_id is NULL, 0, 1) hasListingApp FROM `site` 
		LEFT JOIN app_x_site ON 
		app_x_site.site_id = site.site_id and  
		app_x_site_deleted='0' and 
		app_x_site.app_id='11' 
		WHERE site_active='1' and 
		site_deleted='0' and 
		site.site_id='#request.zos.globals.id#'
		GROUP BY site.site_id");
	} 
	for(row in qS){
		application.zcoreSiteDataStruct[row.site_id]=row;
		application.zcoreSitesLoaded[row.site_id]=0;
		if(row.hasListingApp EQ 1){
			application.zcoreSitesListingLoaded[row.site_id]=0;
		}
	}

	return ts;
	</cfscript>
</cffunction>

<cffunction name="zUpdateSiteMVCData" localmode="modern" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={};
	ts.cfcMetaDataCache=structnew();
	 
	ts.controllerComponentCache=structnew();
	ts.modelDataCache=structnew();
	ts.modelDataCache.modelComponentCache=structnew();
	ts.registeredControllerStruct=structnew();
	ts.registeredControllerPathStruct=structnew();
	ts.arrLandingPage=[];
	arrNewComPath=arraynew(1);
	 
	if(structkeyexists(arguments.ss.globals,'mvcPaths') and arguments.ss.globals.mvcPaths NEQ ""){
		arrMvcPaths=listtoarray(arguments.ss.globals.mvcPaths,",");
	}else{
		arrMvcPaths=arraynew(1);	
	}
	for(i=1;i LTE arraylen(arrMvcPaths);i++){
		arrMvcPaths[i]=request.zRootCFCPath&arrMvcPaths[i];
	} 
	if(directoryexists(request.zos.installPath&"themes/"&arguments.ss.globals.themeName&"/mvc/")){
		arrayAppend(arrMvcPaths, "jetendo-themes."&arguments.ss.globals.themeName&".mvc");
	}
	</cfscript>
	<!--- get all models, controllers and views in the mvc path and precache or precompile them into the application scope --->
	<cfloop from="1" to="#arraylen(arrMvcPaths)#" index="i2">
		<cfscript>
		i=i2;
		if(left(arrMvcPaths[i], 15) EQ "jetendo-themes."){
			curPath=replace(expandpath(request.zos.installPath&"themes/"&replace(removechars(arrMvcPaths[i], 1, 15),'.','/','all')),"\","/","all");
		}else{
			curPath=replace(expandpath('/'&replace(arrMvcPaths[i],'.','/','all')),"\","/","all");
		}
		</cfscript>
		<cfdirectory action="list" recurse="yes" directory="#curPath#" name="qD" filter="*.cfc"><!--- |*.html --->
		<!--- <cfif qd.recordcount>
			<cfdump var="#qD#"><cfabort>
		</cfif> --->
		<cfloop query="qD">
			<cfscript>
			if(qD.type EQ "file"){
				curPath2=removechars(replace(replace(qD.directory,"\","/","all"),curPath,""),1,1);
				arrPath2=listtoarray(curPath2,"/",false);
				fileType=listgetat(curPath2,1,"/");
				curPath3=replace(curPath2,"/",".","all");
				curPath4=listdeleteat(curPath3,1,".");
				curName=listgetat(qD.name,1,".");
				curExt=listgetat(qD.name,2,".");
				lastFolderName=listgetat(curPath2,listlen(curPath2, "/", true),"/");
				if(curName CONTAINS "."){
					application.zcore.functions.zerror(qD.directory&"/"&qD.name&" - A CFC file name can't have a period after the "".cfc"" is removed from the end.  Please remove the periods in the name, ""."", leave the "".cfc"" at the end and try again.");	
				}
				//writeoutput("lastfoldername:"&lastFolderName&"<br />curname:"&curName&"<br /> filetype:"&fileType&"<br />curpath3:"&curPath3&"<br />curPath4:"&curPath4&"<br />curPath2:"&curPath2&"<br />");
				
				// curPath3 is z.z2.controller  - which is perfect for mvcName lookup struct below: registeredControllerStruct
				if(lastFolderName EQ "controller"){
					if(curExt EQ "cfc"){
						comPath=arrMvcPaths[i]&"."&curPath3&"."&curName;
						tempCom=application.zcore.functions.zcreateobject("component", comPath, true);
						
						ts.controllerComponentCache[comPath]=tempCom;
						
						tempcommeta=GetMetaData(tempCom);
						ts.cfcMetaDataCache[comPath]=tempcommeta;
						if(structkeyexists(tempcommeta, 'functions')){
							for(i3=1;i3 LTE arraylen(tempcommeta.functions);i3++){
								c=tempcommeta.functions[i3]; 
								if(structkeyexists(c,"access") and c.access EQ "remote"){
									ts.cfcMetaDataCache[comPath&":"&c.name]=c;
									if(structkeyexists(c,"jetendo-landing-page") and c["jetendo-landing-page"]){
										arrayAppend(ts.arrLandingPage, replace("/"&curPath3&"/"&left(qD.name, len(qD.name)-4)&"/"&c.name, "/controller", ""));
									}
								}
							}
						}
						if(structkeyexists(tempCom,'mvcName')){
							curMvcName="/"&curpath2&"/"&tempCom.mvcName;
						}else{
							curMvcName="/"&curpath2&"/"&curName;
						}
						//writeoutput('<hr>'&curPath2&'<br />');
						//writeoutput("compath:"&comPath&"<br />curmvcname:"&curMvcName&"<br />");
						t42="";
						for(i4=1;i4 LTE arraylen(arrPath2);i4++){
							t42&="/"&arrPath2[i4];
							ts.registeredControllerPathStruct[t42]=true;
						}
						ts.registeredControllerStruct[curMvcName]="/"&replace(arrMvcPaths[i],'.','/','all')&"/"&curPath2&"/"&qD.name;
					}
				}else if(lastFolderName EQ "model"){
					
					if(curExt EQ "cfc"){
						comPath=arrMvcPaths[i]&"."&curPath3&"."&curName;
						ts.modelDataCache.modelComponentCache[replace(comPath, arrMvcPaths[i], "root")]=application.zcore.functions.zcreateobject("component", comPath, true);
					} 
				}
			}
			</cfscript>
		</cfloop>

	</cfloop>
	<cfscript> 
	structappend(arguments.ss, ts, true);
	structdelete(form, 'zregeneratemodelcache');
	
	</cfscript>
</cffunction>



<cffunction name="zImageOutput" localmode="modern" returntype="any" output="yes"><cfargument name="filePath" type="string" required="yes"><cfargument name="type" type="string" required="yes"><!--- image/jpeg or image/gif ---><cfif (arguments.type EQ 'image/jpeg' and right(arguments.filePath,4) EQ '.jpg') or (arguments.type EQ 'image/gif' and right(arguments.filePath,4) EQ '.gif')><cfheader name="Content-Disposition" value="inline; filename=#getfilefrompath(replace(arguments.filePath, ",", " ", "all"))#"><cfcontent type="#arguments.type#" deletefile="no" file="#arguments.filePath#"><cfelse><cfscript>application.zcore.template.fail("zImageOutput(): arguments.filePath must be an absolute path to a jpeg or gif with arguments.type equal to image/jpeg or image/gif.");</cfscript></cfif><cfscript>application.zcore.functions.zabort();</cfscript></cffunction>
<!---  --->

<!--- application.zcore.functions.zModalCancel(); --->
<cffunction name="zModalCancel" localmode="modern" output="no" returntype="any">
	<cfscript>
    if(structkeyexists(request.zos,'modalWindowCancelled') EQ false){
		request.zos.modalWindowCancelled=true;
		application.zcore.template.prependTag("content",'<script type="text/javascript">/* <![CDATA[ */ var zModalCancelFirst=true; /* ]]> */</script>');
		application.zcore.template.appendTag("meta",'<script type="text/javascript">/* <![CDATA[ */ var zModalCancelFirst=true; /* ]]> */</script>');
	}
	</cfscript>
</cffunction>
<cffunction name="zErrorMetaData" localmode="modern" output="no" returntype="any">
    <cfargument name="errorMessage" type="string" required="yes">
    <cfscript>
    if(structkeyexists(request,'zArrErrorMessages') EQ false){
        request.zArrErrorMessages=arraynew(1);	
    }
    arrayappend(request.zArrErrorMessages, arguments.errorMessage);
    </cfscript>
    
</cffunction>


<cffunction name="zRequireContentFlowSlideshow" localmode="modern" output="yes" returntype="any">
    <cfargument name="package" type="string" required="no" default="">
    <cfscript>
	var theOutput="";
    if(structkeyexists(request.zos, 'zRequireContentFlowSlideshowIncluded')) return;
	request.zos.zRequireContentFlowSlideshowIncluded=true;
	</cfscript> 
    <cfsavecontent variable="theOutput"> 
    <link type="text/css" href="/z/javascript/ContentFlow/contentflow_src.css" rel="stylesheet" />
    <script type="text/javascript" src="/z/javascript/ContentFlow/contentflow_src.js"></script> 
    </cfsavecontent>
    <cfscript>
	application.zcore.template.appendTag("meta",theOutput);
	</cfscript>
</cffunction>
 

<!--- application.zcore.functions.zExecuteCSSJSIncludes(); --->
<cffunction name="zExecuteCSSJSIncludes" localmode="modern" output="yes" returntype="any">
	<cfscript> 
	tout=""; 
	zos=request.zos;
	if(zos.inMemberArea or structkeyexists(zos, 'includeManagerStylesheet')){ 
		ts={
			type:"zIncludeZOSFORMS",
			url:"/z/a/stylesheets/style.css",
			package:"",
			forcePosition:""
		};
		if(arraylen(zos.arrCSSIncludes) GT 2){
			arrayInsertAt(zos.arrCSSIncludes, 3, ts);
		
		}else{
			arrayappend(zos.arrCSSIncludes, ts);
		}
	}
	
	jsLength=arraylen(zos.arrJSIncludes);
	cssLength=arraylen(zos.arrCSSIncludes);
	
	if(not structkeyexists(request, 'disableGlobalHTMLHeadCode') and zos.globals.enableMinCat EQ 0 or structkeyexists(zos.tempObj,'disableMinCat')){
		if(structkeyexists(zos,'inMemberArea') and zos.inMemberArea EQ false and structkeyexists(application.sitestruct[zos.globals.id], 'globalHTMLHeadSourceArrCSS')){
			for(i=1;i LTE arraylen(application.sitestruct[zos.globals.id].globalHTMLHeadSourceArrCSS);i++){
				tout&=application.zcore.skin.includeCSS(application.sitestruct[zos.globals.id].globalHTMLHeadSourceArrCSS[i],'last');
			}
			for(i=1;i LTE arraylen(application.sitestruct[zos.globals.id].globalHTMLHeadSourceArrJS);i++){
				tout&=application.zcore.skin.includeJS(application.sitestruct[zos.globals.id].globalHTMLHeadSourceArrJS[i],'last');
			}
		}
	}
	/*
	// determine if files in package have changed
	if(structkeyexists(application.sitestruct[zos.globals.id],'packageJSCacheStruct') EQ false){
		application.sitestruct[zos.globals.id].packageJSCacheStruct=StructNew();
		application.sitestruct[zos.globals.id].packageCSSCacheStruct=StructNew();
		// rebuild from disk the packages.
		for(i in zos.includePackageStruct){
			if(jsLength NEQ 0){ 
				application.sitestruct[zos.globals.id].packageJSCacheStruct[i]=false; 
			}
			if(cssLength NEQ 0){
				application.sitestruct[zos.globals.id].packageCSSCacheStruct[i]=false;
			}
		}
	}
	// this code doesn't do anything!
	pStructCSSChanged=structnew();
	pStructCSS=structnew();
	pStructJSChanged=structnew();
	pStructJS=structnew();
	for(i=1;i LTE jsLength;i++){
		p=zos.arrJSIncludes[i].package;
		if(structkeyexists(pStructJSChanged, p) EQ false and zos.arrJSIncludes[i].package NEQ ""){
			pStructJSChanged[p]=false;
			pStructJS[p]=structnew();
			pStructJS[p].arr1=arraynew(1);
			pStructJS[p].arr2=arraynew(1);
			pStructJS[p].arr3=arraynew(1);
			if(jsLength NEQ 0 and structkeyexists(application.sitestruct[zos.globals.id].packageJSCacheStruct,p) EQ false){
				application.sitestruct[zos.globals.id].packageJSCacheStruct[p]=false;
			}
		}
	}
	for(i=1;i LTE cssLength;i++){
		p=zos.arrCSSIncludes[i].package;
		if(structkeyexists(pStructCSSChanged, p) EQ false and zos.arrCSSIncludes[i].package NEQ ""){
			pStructCSSChanged[p]=false;
			pStructCSS[p]=structnew();
			pStructCSS[p].arr1=arraynew(1);
			pStructCSS[p].arr2=arraynew(1);
			pStructCSS[p].arr3=arraynew(1);
			if(cssLength NEQ 0 and structkeyexists(application.sitestruct[zos.globals.id].packageCSSCacheStruct,p) EQ false){
				application.sitestruct[zos.globals.id].packageCSSCacheStruct[p]=false;
			}
		}
	} */
	zos.arrJSIncludes=arrayreverse(zos.arrJSIncludes);
	zos.arrCSSIncludes=arrayreverse(zos.arrCSSIncludes);
	for(i=1;i LTE jsLength;i++){
		if(zos.arrJSIncludes[i].package EQ ""){ 
            application.zcore.skin.includeJS(request.zos.arrJSIncludes[i].url, 'first');//request.zos.arrJSIncludes[i].forcePosition));
			// arrayappend(request.zos.arrScriptIncludeLevel, 1);
			// arrayprepend(request.zos.arrScriptInclude, zos.arrJSIncludes[i].url);
		}
	}
	arrCSS=[];
	for(i=1;i LTE cssLength;i++){
		if(zos.arrCSSIncludes[i].package EQ ""){ 
		    application.zcore.skin.includeCSS(request.zos.arrCSSIncludes[i].url, 'first');//request.zos.arrCSSIncludes[i].forcePosition)); 
			// checkPath=zos.arrCSSIncludes[i].url;
			// if(left(checkPath, 1) EQ '/' and left(checkPath, 2) NEQ "//"){
			// 	arrayAppend(arrCSS, '<link rel="stylesheet" type="text/css" href="#request.zos.currentHostName##checkPath#" />'); 
			// }else{
			// 	arrayAppend(arrCSS, '<link rel="stylesheet" type="text/css" href="#checkPath#" />'); 
			// }
		}
	} 
	// application.zcore.template.prependTag("stylesheets", arrayToList(arrCSS, chr(10)), true);
	</cfscript>
</cffunction>

<cffunction name="zForceIncludePackage" localmode="modern" output="no" returntype="any">
    <cfargument name="type" type="string" required="yes">
    <cfargument name="package" type="string" required="no" default="">
	<cfscript>
	var i=1;
	zos=request.zos;
	if(arguments.package NEQ ""){
		zos.includePackageStruct[arguments.package]=true;
		for(i=1;i LTE arraylen(zos.arrJSIncludes);i++){
			if(zos.arrJSIncludes[i].type EQ arguments.type){
				zos.arrJSIncludes[i].package=arguments.package;	
			}
		}
		for(i=1;i LTE arraylen(zos.arrCSSIncludes);i++){
			if(zos.arrCSSIncludes[i].type EQ arguments.type){
				zos.arrCSSIncludes[i].package=arguments.package;	
			}
		}
	}
	</cfscript>
</cffunction>



<!--- application.zcore.functions.zRequireGoogleMaps(); --->
<cffunction name="zRequireGoogleMaps" localmode="modern" output="no" returntype="any"> 
	<cfscript>
	var theMeta="";
	var ts=structnew();
	zos=request.zos;
	if(structkeyexists(zos,'JavascriptRequiredGoogleMaps') EQ false){
		if(zos.globals.googleMapsApiKey NEQ ""){
			link="https://maps.googleapis.com/maps/api/js?v=3.exp&libraries=places&sensor=false&callback=zMapInit&key=#zos.globals.googleMapsApiKey#";
		}else if(right(zos.globals.domain, len(zos.productionTestDomain)) EQ zos.productionTestDomain){
			link="https://maps.googleapis.com/maps/api/js?v=3.exp&libraries=places&sensor=false&callback=zMapInit&key=#zos.googleMapsApiServerKeyTestDomain#"; 
		}else if(right(zos.globals.domain, len(zos.testDomain)) EQ zos.testDomain){
			link="https://maps.googleapis.com/maps/api/js?v=3.exp&libraries=places&sensor=false&callback=zMapInit&key=#zos.googleMapsApiServerKeyTestDomain#";   
		}else{
			link="https://maps.googleapis.com/maps/api/js?v=3.exp&libraries=places&sensor=false&callback=zMapInit";
		}
		application.zcore.skin.includeJS(link);

		geocodeCom=application.zcore.functions.zCreateObject("component", "zcorerootmapping.mvc.z.misc.controller.geocode");
		geocodeCom.processGeocodeQueue();
		zos.JavascriptRequiredGoogleMaps=true;
	}
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zRequireJquery(); --->
<cffunction name="zRequireJquery" localmode="modern" output="no" returntype="any">
    <cfargument name="package" type="string" required="no" default="">
	<cfscript>
	zos=request.zos;
	if(zos.globals.enableMinCat EQ 1 and zos.inMemberArea EQ false and structkeyexists(zos.tempObj,'disableMinCat') EQ false){
		return;
	}
    application.zcore.functions.zForceIncludePackage("zRequireJquery", arguments.package);
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zRequireJqueryCookie(); --->
<cffunction name="zRequireJqueryCookie" localmode="modern" output="no" returntype="any">
    <cfargument name="package" type="string" required="no" default="">
	<cfscript>
	if(request.zos.globals.enableMinCat EQ 1 and request.zos.inMemberArea EQ false and structkeyexists(request.zos.tempObj,'disableMinCat') EQ false){
		return;
	}
    application.zcore.functions.zForceIncludePackage("zRequireJqueryCookie", arguments.package);
    if(structkeyexists(request.zos,'JavascriptRequiredJqueryCookie') EQ false){
		ts=structnew("sync");
		ts.type="zRequireJqueryCookie";
		ts.url="/z/javascript/jquery/jquery.cookie.js";
		ts.package=arguments.package;
		ts.forcePosition="";
		arrayappend(request.zos.arrJSIncludes, ts);
	    request.zos.JavascriptRequiredJqueryCookie=true;
	}
    </cfscript>
</cffunction>


<!--- application.zcore.functions.zRequireJqueryMobile(); --->
<cffunction name="zRequireJqueryMobile" localmode="modern" output="no" returntype="any">
	<cfargument name="package" type="string" required="no" default="">
	<cfscript>
	if(request.zos.globals.enableMinCat EQ 1 and request.zos.inMemberArea EQ false and structkeyexists(request.zos.tempObj,'disableMinCat') EQ false){
		return;
	}
	var theMeta="";
	var ts=structnew();
	application.zcore.functions.zForceIncludePackage("zRequireJqueryMobile", arguments.package);
	if(structkeyexists(request.zos,'JavascriptRequiredJqueryMobile') EQ false){
		savecontent variable="theMeta"{
			application.zcore.functions.zRequireJquery();
			ts={};
			ts.type="zRequireJqueryMobile";
			ts.url="/z/javascript/jquery/jquery.mobile-1.3.2/jquery.mobile-1.3.2.min.js";
			ts.package=arguments.package;
			ts.forcePosition="";
			arrayappend(request.zos.arrJSIncludes, ts);
			ts={};
			ts=structnew();
			ts.type="zRequireJqueryMobile";
			ts.url="/z/javascript/jquery/jquery.mobile-1.3.2/jquery.mobile-1.3.2.min.css";
			ts.package=arguments.package;
			ts.forcePosition="";
			arrayappend(request.zos.arrCSSIncludes, ts);
		}
		request.zos.JavascriptRequiredJqueryMobile=true;
	}
	</cfscript>
</cffunction>


<cffunction name="zRequireDataTables" localmode="modern" access="public">
    <!--- <cfargument name="package" type="string" required="no" default=""> --->
	<cfscript>
	/*if(request.zos.globals.enableMinCat EQ 1 and request.zos.inMemberArea EQ false and structkeyexists(request.zos.tempObj,'disableMinCat') EQ false){
		return;
	}
    application.zcore.functions.zForceIncludePackage("zRequireDataTables", arguments.package);*/
    if(structkeyexists(request.zos,'JavascriptRequiredDataTables') EQ false){
    	application.zcore.skin.includeJS("/z/javascript/DataTables/media/js/jquery.dataTables.js", "", 1); 
    	application.zcore.skin.includeJS("/z/javascript/DataTables/extensions/Responsive/js/dataTables.responsive.min.js", "", 2); 
    	application.zcore.skin.includeCSS("/z/javascript/DataTables/media/css/jquery.dataTables.css", "", 1); 
    	application.zcore.skin.includeCSS("/z/javascript/DataTables/extensions/Responsive/css/dataTables.responsive.css", "", 2); 
	    request.zos.JavascriptRequiredDataTables=true;
	}
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zRequireJqueryUI(); --->
<cffunction name="zRequireJqueryUI" localmode="modern" output="no" returntype="any">
    <cfargument name="package" type="string" required="no" default="">
	<cfscript>
	if(request.zos.globals.enableMinCat EQ 1 and request.zos.inMemberArea EQ false and structkeyexists(request.zos.tempObj,'disableMinCat') EQ false){
		return;
	} 
    application.zcore.functions.zForceIncludePackage("zRequireJqueryUI", arguments.package);
    if(structkeyexists(request.zos,'JavascriptRequiredJqueryUI') EQ false){
		application.zcore.functions.zRequireJquery();
	    if(request.zos.istestserver){
			ts=structnew("sync");
			ts.type="zRequireJqueryUI";
			ts.url="/z/javascript/jquery/jquery-ui/jquery-ui-1.10.3.min.js";
			ts.package=arguments.package;
			ts.forcePosition="";
			arrayappend(request.zos.arrJSIncludes, ts);
			ts=structnew();
			ts.type="zRequireJqueryUI";
			ts.url="/z/javascript/jquery/jquery-ui/jquery-ui-1.10.3.min.css";
			ts.package=arguments.package;
			ts.forcePosition="";
			arrayappend(request.zos.arrCSSIncludes, ts);
			
		}else{
			ts=structnew("sync");
			ts.type="zRequireJqueryUI";
			ts.url="/z/javascript/jquery/jquery-ui/jquery-ui-1.10.3.min.js";
			//ts.url="//ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/jquery-ui.min.js";
			ts.package=arguments.package;
			ts.forcePosition="";
			arrayappend(request.zos.arrJSIncludes, ts);
			ts=structnew();
			ts.type="zRequireJqueryUI";
			ts.url="/z/javascript/jquery/jquery-ui/jquery-ui-1.10.3.min.css";
			//ts.url="//ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/themes/base/jquery-ui.css";
			ts.package=arguments.package;
			ts.forcePosition="";
			arrayappend(request.zos.arrCSSIncludes, ts);
	    }
	    request.zos.JavascriptRequiredJqueryUI=true;
	}
	</cfscript>
</cffunction>


<!--- 
ts={
	type:"Custom",
	errorHTML:'',
	scriptName:'',
	url:'',
	exceptionMessage:'',
	// optional
	lineNumber:''
}
application.zcore.functions.zLogError(ts);
 --->
<cffunction name="zLogError" access="public" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject; 
	log_id=0;
	
	currentMinute=timeformat(now(), "m");
	if(not structkeyexists(application, 'zErrorMinuteTime')){
		application.zErrorMinuteTime=currentMinute;
		application.zErrorMinuteCount=0;
	}
	if(currentMinute NEQ application.zErrorMinuteTime){
		application.zErrorMinuteCount=0;
		application.zErrorMinuteTime=currentMinute;
	}
	application.zErrorMinuteCount++;
	if(not structkeyexists(arguments.ss, 'errorHTML')){
		throw("arguments.ss.errorHTML is required.");
	}
	if(not structkeyexists(arguments.ss, 'type')){
		throw("arguments.ss.type is required.");
	}
	if(not structkeyexists(arguments.ss, 'scriptName')){
		throw("arguments.ss.scriptName is required.");
	}
	if(not structkeyexists(arguments.ss, 'url')){
		throw("arguments.ss.url is required.");
	}
	if(not structkeyexists(arguments.ss, 'lineNumber')){
		arguments.ss.lineNumber=0;
	}
	db.sql="INSERT INTO #db.table("log", request.zos.zcoreDatasource)# SET
        log_host = #db.param(request.zOS.CGI.http_host)#, 
        log_status = #db.param('New')#, 
        log_type = #db.param(arguments.ss.type)#, 
        log_datetime = #db.param(DateFormat(now(), "yyyy-mm-dd")&" "&TimeFormat(now(), "HH:mm:ss"))#,
        log_title = #db.param(arguments.ss.url)#,
        log_ip = #db.param(request.zos.cgi.remote_addr)#, 
        log_message = #db.param(arguments.ss.errorHTML)# , 
	log_user_agent=#db.param(request.zos.cgi.http_user_agent)# ,
	log_script_name=#db.param(arguments.ss.scriptName)#,
	log_line_number=#db.param(arguments.ss.lineNumber)#, 
	log_exception_message=#db.param(arguments.ss.exceptionMessage)#, 
	log_deleted=#db.param(0)#, 
	log_updated_datetime=#db.param(request.zos.mysqlnow)# ";
	rs=db.insert("qInsert");
	
	if(rs.success){
		log_id=rs.result;
	}else{
		throw("Failed to log error");	
	}
	// send email alert
	currentMinute=timeformat(now(), "m");
	if(not structkeyexists(application, 'zErrorMinuteCurrent')){
		application.zErrorMinuteTime=currentMinute;
	}
	if(application.zErrorMinuteTime NEQ currentMinute or not structkeyexists(application, 'zErrorMinuteCount')){
		application.zErrorMinuteCount=0;
		application.zErrorMinuteTime=currentMinute;
	}
	if(application.zErrorMinuteCount LTE request.zos.errorEmailAlertsPerMinute and arguments.ss.type NEQ "javascript-error"){
		ts=StructNew();
		
		ts.to=request.zos.developerEmailTo;
		ts.from=request.zos.developerEmailFrom;
		ts.subject=arguments.ss.type&" on "&request.zos.globals.shortDomain;
		savecontent variable="ts.html"{
			echo('#application.zcore.functions.zHTMLDoctype()#
			<head><title>Error</title>
			</head>
			<body>
			<span class="medium">#arguments.ss.type# on #request.zos.currentHostName#</span><br /><br />
		
			<a href="#request.zos.globals.serverDomain#/z/server-manager/admin/log/view?log_id=#log_id#">Click here</a> to view detailed information on this error.<br><br>
		
			You will have to login using an account with Server Administrator access.<br /><br />
			User''s IP: #request.zos.cgi.remote_addr# ');
			if(application.zErrorMinuteCount EQ request.zos.errorEmailAlertsPerMinute){
				echo('<br /><br />Error alert limit threshold of #request.zos.errorEmailAlertsPerMinute# alerts per minute was reached.  Further errors are only visible in server manager.');
			}
			echo('</body>
			</html>');
		}
		ts.site_id=request.zos.globals.id;
		rCom=application.zcore.email.send(ts);
		if(not rCom.isOK()){
			savecontent variable="errorHTML"{
				rCom.setStatusErrors(request.zsid);
			}
			throw("Failed to send log error email: "&errorHTML);
		}
	} 
	</cfscript>
</cffunction>


<cffunction name="zIncludeZOSFORMS" localmode="modern" output="yes" returntype="any">
	<!--- <cfargument name="output" type="boolean" required="no" default="#false#"> --->
    <cfargument name="package" type="string" required="no" default="">
	<cfscript>
	zos=request.zos;
    if(structkeyexists(request.zos,"zOSFORMSIncluded")){
    	return;
    }  
	// if(zos.globals.enableMinCat EQ 1 and zos.inMemberArea EQ false and structkeyexists(zos.tempObj,'disableMinCat') EQ false){
	// 	//return;
	// }
	application.zcore.functions.zRequireJquery(arguments.package);
	
	allowJs=true;
	if(application.zcore.skin.checkCompiledJS()){
		allowJs=false;
	}
	/*var c3="";
	if(zos.istestserver){
		c3="-src";	
	}*/
	//c3="-src";	
    application.zcore.functions.zForceIncludePackage("zIncludeZOSFORMS", arguments.package);
	zos.zOSFORMSIncluded=true;
	ts={
		type:"zIncludeZOSFORMS",
		url:"/z/stylesheets/zOS.css",
		package:arguments.package,
		forcePosition:"first"
	};
	arrayappend(zos.arrCSSIncludes, ts);
	ts={
		type:"zCSSFramework",
		url:"/z/stylesheets/css-framework.css",
		package:"",
		forcePosition:""
	};
	arrayappend(zos.arrCSSIncludes, ts);
	if(allowJs){
		/*ts={
			type:"zIncludeZOSFORMS",
			url:"/z/javascript/jquery/balupton-history/scripts/uncompressed/json2.js",
			package:arguments.package,
			forcePosition:""
		}
		arrayappend(zos.arrJSIncludes, ts);*/
		c=arraylen(application.zcore.arrJsFiles);
		for(i=1;i LTE c;i++){
			ts={
				type:"zIncludeZOSFORMS",
				url:application.zcore.arrJsFiles[i],
				package:arguments.package,
				forcePosition:""
			};
			arrayappend(zos.arrJSIncludes, ts);
		}
	}

	tempFile=zos.globals.privatehomedir&"zcache/zsystem.css";
	if(structkeyexists(application.sitestruct[zos.globals.id].fileExistsCache, tempFile) EQ false){
		application.sitestruct[zos.globals.id].fileExistsCache[tempFile]=fileexists(tempFile);
	}
	if(application.sitestruct[zos.globals.id].fileExistsCache[tempFile]){
		ts=structnew("sync");
		ts.type="zIncludeZOSFORMS";
		ts.url="/zcache/zsystem.css";
		ts.package=arguments.package;
		ts.forcePosition="";
		arrayappend(zos.arrCSSIncludes, ts);
	}
	</cfscript>
</cffunction>

<cffunction name="zRequireCSSFramework" localmode="modern" output="no" returntype="any">
	<cfscript> 
	if(not structkeyexists(request.zos, 'includeManagerStylesheet') and not request.zos.inMemberArea){  
		ts={
			type:"zCSSFramework",
			url:"/zupload/layout-global.css",
			package:"",
			forcePosition:""
		};
		arrayappend(request.zos.arrCSSIncludes, ts);  
	}else{
		if(request.zos.isTestServer){
			link=request.zos.zcoreTestAdminDomain&application.zcore.skin.getVersionURL("/zupload/layout-global.css");
		}else{
			link=request.zos.zcoreAdminDomain&application.zcore.skin.getVersionURL("/zupload/layout-global.css");
		}
		ts={
			type:"zCSSFramework",
			url:link,
			package:"",
			forcePosition:""
		};
		arrayappend(request.zos.arrCSSIncludes, ts);  
	}
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zRequireSWFObject(); --->
<cffunction name="zRequireSWFObject" localmode="modern" output="no" returntype="any">
    <cfargument name="package" type="string" required="no" default="">
	<cfscript>
	var theMeta="";
	var ts=structnew();
    application.zcore.functions.zForceIncludePackage("zRequireSWFObject", arguments.package);
    </cfscript>
    <cfif structkeyexists(request.zos,'JavascriptRequiredSWFObject') EQ false>
	<cfsavecontent variable="theMeta"><cfif request.zos.istestserver><cfscript>
	ts.type="zRequireSWFObject";
	ts.url="/z/javascript/swfobject.js";
	ts.package=arguments.package;
	ts.forcePosition="";
	arrayappend(request.zos.arrJSIncludes, ts);
    </cfscript>
	<cfelse><cfscript>
	ts.type="zRequireSWFObject";
	ts.url="/z/javascript/swfobject.js";
	ts.package=arguments.package;
	ts.forcePosition="";
	arrayappend(request.zos.arrJSIncludes, ts);
    </cfscript></cfif></cfsavecontent>
    <cfscript>request.zos.JavascriptRequiredSWFObject=true;</cfscript>
    </cfif>
</cffunction>




<cffunction name="zPublishCss" localmode="modern" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var contentCount=0;
	var ts=structnew();
	var endTag="";
	var pos=0;
	var pos2=0;
	var newCode="";
	var contents="";
	var newcontents="";
	var rightCount=0;
	ts.uniquephrase="";
	ts.code="";
	ts.site_id=request.zos.globals.id;
	structappend(arguments.ss,ts,false);
	tempCSSPath=application.zcore.functions.zGetDomainWritableInstallPath(application.zcore.functions.zvar("shortDomain", arguments.ss.site_id))&"zcache/zsystem.css";
	if(arguments.ss.uniquephrase EQ ""){
		application.zcore.template.fail("arguments.ss.beginphrase and arguments.ss.endphrase are required.");
	}
	if(trim(arguments.ss.code) EQ ""){
		newCode="";
	}else{
		newCode="/* start #arguments.ss.uniquephrase# */"&chr(10)&arguments.ss.code&chr(10)&"/* end #arguments.ss.uniquephrase# */";
	}
	if(fileexists(tempCSSPath) EQ false){
		contents="/* THIS FILE IS AUTOMATICALLY GENERATED, DO NOT EDIT */"&chr(10);
	}else{
		contents=application.zcore.functions.zreadfile(tempCSSPath);
	} 
	endTag="/* end #arguments.ss.uniquephrase# */";
	pos=find("/* start #arguments.ss.uniquephrase# */", contents);
	pos2=find(endTag, contents);
	if(pos NEQ 0 and pos2 NEQ 0){
		contentCount=len(contents);
		if(pos NEQ 1){
			newcontents=left(contents, pos-1)&newCode;
		}else{
			newcontents=newCode;	
		}
		rightCount=len(contents)-(pos2+len(endTag)-1);
		if(rightCount GT 0){
			newcontents&=right(contents, rightCount);
		}
		contents=newcontents;
	}else{
		contents&=newCode;	
	} 
	tempFile=tempCSSPath;
	application.zcore.functions.zwritefile(tempFile,trim(contents));
	application.sitestruct[request.zos.globals.id].fileExistsCache[tempFile]=true;
	if(form[request.zos.urlRoutingParameter] NEQ "/z/server-manager/tasks/publish-system-css/index"){
		//if(structkeyexists(application.zcore,'skin')) application.zcore.skin.verifyCache(application.sitestruct[request.zos.globals.id].skinObj);
		if(structkeyexists(application.zcore,'template')) application.zcore.template.findAndReplacePrependTag("meta", "/zcache/zsystem.css?zversion=", "/zcache/zsystem.css?zversion="&gettickcount());
	}
	</cfscript>
</cffunction>

<cffunction name="zIsTestServer" localmode="modern" returntype="boolean" output="no">
	<cfscript>if(request.zos.istestserver){return true;}else{return false;}</cfscript>
</cffunction>

<!--- application.zcore.functions.zEnableNewMetaTags(); --->
<cffunction name="zEnableNewMetaTags" localmode="modern" output="no" returntype="any" hint="Exists for legacy purposes only before stylesheets and scripts template tags were used."> 
</cffunction>





<cffunction name="zEscapeForRegEx" localmode="modern" output="no" returntype="string">
	<cfargument name="a" type="string" required="yes">
    <cfscript>
	var link=arguments.a;
	link=replace(link,"\","\\","ALL");
	link=replace(link,chr(9),"","ALL");
	link=replace(link,chr(10),"","ALL");;
	link=replace(link," ","","all");
	link=replace(link,"?","\?","ALL");
	link=replace(link,".","\.","ALL");
	
	link=replace(link,"(","\(","ALL");
	link=replace(link,")","\)","ALL");
	link=replace(link,"$","\$","ALL");
	link=replace(link,"[","\[","ALL");
	link=replace(link,"]","\]","ALL");
	link=replace(link,"{","\{","ALL");
	link=replace(link,"}","\}","ALL");
	link=replace(link,"*","\*","ALL");
	link=replace(link,"-","\-","ALL");
	link=replace(link,"|","\|","ALL");
	link=replace(link,"^","\^","ALL");
	link=replace(link,"+","\+","ALL");
	return link;
	</cfscript>
</cffunction>



<cffunction name="zReturnRedirect" localmode="modern" output="no" returntype="void" hint="Redirect to the return url in session memory or if it doesn't exist, redirect to the inputURL.">
	<cfargument name="inputURL" type="string" required="yes">
	<cfargument name="appendURL" type="string" required="no" default="">
    <cfscript>
	var zt="";
	if(structkeyexists(request.zsession,'___zr')){
		zt=request.zsession.___zr;
		structdelete(request.zsession,'___zr');
		application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(zt, arguments.appendURL));
	}else{
		application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.inputURL, arguments.appendURL));
	}
	</cfscript>
</cffunction>

<cffunction name="zGetStackTrace" localmode="modern" returntype="struct" output="no">
	<cftry><cfthrow message="fail" type="StackTrace">
    <cfcatch><cfscript>
	var rs=structnew();
	rs.StackTrace=cfcatch.stacktrace;
	rs.TagContext=cfcatch.tagcontext;
	return rs;
	</cfscript></cfcatch></cftry>
</cffunction>

<cffunction name="zVar" localmode="modern" output="false" returntype="string">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfargument name="defaultValue" type="string" required="no" default="">
	<cfscript>
	if(arguments.site_id EQ request.zos.globals.id){
		if(structkeyexists(Request.zOS.globals,arguments.name)){
			return Request.zOS.globals[arguments.name];
		}else{
			return arguments.defaultValue;	
		}
	}else{
		if(structkeyexists(application.zcore.siteGlobals, arguments.site_id)){
			if(structkeyexists(application.zcore.siteGlobals[arguments.site_id],arguments.name)){
				return application.zcore.siteGlobals[arguments.site_id][arguments.name];
			}else{
				return arguments.defaultValue;	
			}
		}else{
			backupSiteID=request.zos.globals.id;
			// TODO: might be better if we didn't have to call this
			application.zcore.functions.zOS_cacheSiteAndUserGroups(arguments.site_id);
			if(structkeyexists(application.zcore.siteglobals,backupSiteID)){
				request.zos.globals=application.zcore.siteglobals[backupSiteID];
			}
			setSiteRequestGlobals(backupSiteId);

			if(structkeyexists(application.zcore.siteGlobals, arguments.site_id)){
				if(structkeyexists(application.zcore.siteGlobals[arguments.site_id],arguments.name)){
					return application.zcore.siteGlobals[arguments.site_id][arguments.name];
				}else{
					return arguments.defaultValue;	
				}
			}else{
				return arguments.defaultValue;
			}
		}
	}
	</cfscript>
</cffunction>

<cffunction name="zGetUniqueNumber" localmode="modern" output="no" returntype="numeric">
	<cfscript>
	if(isDefined('request.zos.tempObj.uniquenumberindex') EQ false){
		request.zos.tempObj.uniquenumberindex=0;
	}
	request.zos.tempObj.uniquenumberindex++;
	return request.zos.tempObj.uniquenumberindex;
	</cfscript>
</cffunction>
 
     
<!--- application.zcore.functions.zGetSiteOptionGroupIdWithNameArray(["GroupName"]); --->
<cffunction name="zGetSiteOptionGroupIdWithNameArray" localmode="modern" output="no" returntype="numeric" hint="returns the group id for the last group in the array.">
	<cfargument name="arrGroupName" type="array" required="no" default="An array of site_option_group_name">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	return application.zcore.siteOptionCom.getOptionGroupIdWithNameArray(arguments.arrGroupName, arguments.site_id);
	</cfscript>
</cffunction>

<cffunction name="zGetSiteOptionGroupById" localmode="modern" output="yes" returntype="struct">
	<cfargument name="site_option_group_id" type="string" required="no" default="">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	return application.zcore.siteOptionCom.getOptionGroupById(arguments.site_option_group_id, arguments.site_id); 
	</cfscript>
</cffunction>
     <!--- 
<cffunction name="zGetSiteOptionGroupSetById" localmode="modern" output="yes" returntype="struct">
	<cfargument name="site_option_group_set_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfargument name="arrGroupName" type="array" required="no" default="#[]#">
	<cfargument name="showUnapproved" type="boolean" required="no" default="#false#">
	<cfscript> 
	if(request.zos.istestserver){
		throw("zGetSiteOptionGroupSetById() must be replaced with application.zcore.siteOptionCom.getOptionGroupSetById([""group""], set_id); for improved security.");
	}
	return application.zcore.siteOptionCom.getOptionGroupSetById(arguments.arrGroupName, arguments.site_option_group_set_id, arguments.site_id, arguments.showUnapproved); 
	</cfscript>
</cffunction> --->

<cffunction name="zSiteOptionGroupIdByName" localmode="modern" output="no" returntype="numeric">
	<cfargument name="groupName" type="string" required="yes">
	<cfargument name="site_option_group_parent_id" type="numeric" required="no" default="#0#">
	<cfargument name="site_id" type="numeric" required="no" default="#request.zos.globals.id#">
	<cfscript>
	return application.zcore.siteOptionCom.optionGroupIdByName(arguments.groupName, arguments.site_option_group_parent_id, arguments.site_id); 
	</cfscript>
</cffunction>

<cffunction name="zSiteOptionGroupStruct" localmode="modern" output="yes" returntype="array">
	<cfargument name="groupName" type="string" required="yes">
	<cfargument name="site_option_app_id" type="string" required="no" default="0">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfargument name="parentStruct" type="struct" required="no" default="#{__groupId=0,__setId=0}#">
	<cfscript> 
	return application.zcore.siteOptionCom.optionGroupStruct(arguments.groupName, arguments.site_option_app_id, arguments.site_id, arguments.parentStruct); 
	</cfscript>
</cffunction> 

<cffunction name="zNoCache" localmode="modern" output="false">
	<cfscript>
	if(not structkeyexists(request.zos, 'zNoCacheRan')){
		request.zos.zNoCacheRan=true;
		var ts=structnew();
		ts.name="zNoCache";
		ts.value="1";
		ts.expires=CreateTimeSpan(0,0,request.zos.sessionExpirationInMinutes,0);
		application.zcore.functions.zCookie(ts); 
	}
	</cfscript>
</cffunction>

<cffunction name="zVarSO" localmode="modern" output="false" returntype="string">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="">
	<cfargument name="disableEditing" type="boolean" required="no" default="#false#">
	<cfargument name="site_option_app_id" type="string" required="no" default="0">
     <cfscript>
	return application.zcore.siteOptionCom.var(arguments.name, arguments.site_id, arguments.disableEditing, arguments.site_option_app_id); 
	</cfscript>
</cffunction>






<!--- zFilterURL(filterList); --->
<cffunction name="zFilterURL" localmode="modern" output="false" returntype="any">
	<cfargument name="filterList" type="string" required="yes">
	<cfscript>
	var i=0;
	var theURL = request.cgi_script_name;
	var arrTemp = ArrayNew(1);
	for(i in url){
		if(listFindNoCase(arguments.filterList, i) EQ false and isSimpleValue(url[i])){
			ArrayAppend(arrTemp, i&'='&URLEncodedFormat(url[i]));
		}
	}
	if(ArrayLen(arrTemp) NEQ 0){
		return theURL&"?"&ArrayToList(arrTemp, '&');
	}else{
		return theURL;
	}
	</cfscript>
</cffunction>
<cffunction name="zError" localmode="modern" output="false" returntype="any">
	<cfargument name="message" type="string" required="no">
	<cfargument name="silent" type="boolean" required="no" default="#false#">
	<cfscript>
	var ts=0;
	var log_id=0;
	var zErrorTempURL="";
	</cfscript>
	<cfif arguments.silent>
	<cfsavecontent variable="zErrorTempURL"><cfif request.zos.cgi.SERVER_PORT NEQ "443">http://<cfelse>https://</cfif>#request.zos.cgi.http_host##request.cgi_script_name#<cfif request.zos.CGI.QUERY_STRING NEQ "">?#request.zos.CGI.QUERY_STRING#</cfif></cfsavecontent>
	<cfscript>
	ts=StructNew();
	ts.table="log";
	ts.datasource="#request.zos.zcoreDatasource#";   
	ts.struct.log_host=request.zos.cgi.http_host;   
	ts.struct.log_title=zErrorTempURL;
	ts.struct.log_message=arguments.message;
	ts.struct.log_ip=request.zos.cgi.remote_addr;
	ts.struct.log_datetime=request.zos.mysqlnow;
	ts.struct.log_status='New';
	ts.struct.log_priority='0';
	if(isdefined('request.zsession.user.id')){
		ts.struct.user_id = request.zsession.user.id;
	}
	ts.struct.log_type='error';
	ts.struct.site_id=request.zos.globals.id;
	log_id=application.zcore.functions.zInsert(ts);
	</cfscript>
<cfmail  from="#request.zos.developerEmailFrom#" to="#request.zos.developerEmailTo#" type="html" subject="#request.zos.cgi.http_host# has an error">
#application.zcore.functions.zHTMLDoctype()#
<body>
Error on #request.zos.cgi.http_host#<br />
<br />
<a href="#request.zos.globals.serverdomain#/server-manager/admin/log/view?log_id=#log_id#">Click here to view detailed information on this error.</a>
<br />
<br />
You will have to login using your Server Administrator password.
<br />
<br />
User's IP: #request.zos.cgi.remote_addr#
</body></html>
</cfmail>
	<cfelse>
		<cfthrow type="exception" message="#arguments.message#">
	</cfif>
</cffunction>

<cffunction name="zCGI" localmode="modern" output="false" returntype="any">
	<cfargument name="name" type="string" required="no">
	<cfscript>
		return request.zOS.CGI[arguments.name];
	/*try{
	}catch(Any excpt){ }
	try{
	// replace with my own struct when ready.
		return CGI[arguments.name];
	}catch(Any excpt){
		application.zcore.functions.zError(arguments.name&' is not a valid CGI variable.');
	}*/
	</cfscript>
</cffunction>

<!--- FUNCTION: application.zcore.functions.zGetRepostStruct(); --->
<cffunction name="zGetRepostStruct" localmode="modern" returntype="struct" output="yes">	
	<cfscript>
	var arrURL = ArrayNew(1);
	var urlString = "";
	var formString = "";
	var arrForm = ArrayNew(1);
	var returnStruct = StructNew();
	var i = 0;
	var repostVarsIgnoreStruct=application.zcore.repostVarsIgnoreStruct;
	/*if(structkeyexists(form, 'method')){
		structdelete(form,'method');	
	}*/
	for(i in FORM){
		if(structkeyexists(repostVarsIgnoreStruct, i) EQ false and isSimpleValue(form[i])){
			formString = formString&'<input type="hidden" name="'&i&'" value="'&htmlEditFormat(FORM[i])&'" />'&chr(10);
			arrayappend(arrForm, i&"="&urlencodedformat(FORM[i]));
		}
	}
	for(i in URL){
		if(structkeyexists(form, i) EQ false and structkeyexists(repostVarsIgnoreStruct, i) EQ false and isSimpleValue(url[i])){
			ArrayAppend(arrURL,i&'='&URLEncodedFormat(URL[i]));
		}
	}
	urlString = ArrayToList(arrURL,"&");
	returnStruct.urlString = urlString;
	returnStruct.formString = formString;
	returnStruct.cgiFormString=arrayToList(arrForm, '&');
	return returnStruct;
	</cfscript>
</cffunction>

<cffunction name="zCheckDebugIP" localmode="modern" output="false" returntype="boolean">
	<cfscript>
	if(structkeyexists(request.zos.adminIpStruct,request.zos.cgi.remote_addr) and request.zos.adminIpStruct[request.zos.cgi.remote_addr] EQ false){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
<cffunction name="zIsServer" localmode="modern" output="false" returntype="boolean">
	<cfscript>
	if((request.zos.cgi.remote_addr EQ '127.0.0.1' and (cgi.HTTP_USER_AGENT contains 'lucee' or cgi.HTTP_USER_AGENT contains 'railo' or cgi.HTTP_USER_AGENT EQ 'cfschedule' or cgi.HTTP_USER_AGENT EQ 'Coldfusion')) or
	 structkeyexists(request.zos.adminIpStruct,request.zos.cgi.remote_addr) and request.zos.adminIpStruct[request.zos.cgi.remote_addr]){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<cffunction name="zDump" localmode="modern" output="true" returntype="any">
	<cfargument name="varName" type="any" required="yes">
	<cfargument name="label" type="string" required="no" default="">
	<cfargument name="nodumpcode" type="boolean" required="no" default="#false#">
	<cfdump var="#arguments.varName#" showudfs="no" format="html" label="#arguments.label#">
	<cfif request.zos.cfmlServerKey EQ "railo">
		<style type="text/css"> 
		div.-railo-dump  td span {font-weight:bold !important;}
		div.-railo-dump table{ background-color:##FFF !important;font-family:Arial, Helvetica, sans-serif  !important; font-size:12px !important; empty-cells:show !important; color:##000 !important;border-spacing:0px !important;color:##000 !important;  border:none !important;}
		div.-railo-dump td.r99f {background-color:##FFF !important; border-right:1px solid ##CCC !important; border-bottom:1px solid ##CCC !important; padding:3px !important;}
		div.-railo-dump td.rc9c {background-color:##FFF !important; border-right:1px solid ##CCC !important; border-bottom:1px solid ##CCC !important; padding:3px !important;} 
		div.-railo-dump td.r99f:nth-child(even) {background-color:##F2F2F2 !important;  }
		div.-railo-dump td.rc9c:nth-child(even) {background-color:##F2F2F2 !important;  }
		div.-railo-dump td {background-color:transparent !important; padding:3px !important; border:none !important; border-right:1px solid ##CCC !important;border-bottom:1px solid ##CCC !important;}
		div.-railo-dump tr:nth-child(even) {background: ##F2F2F2  !important;}
		div.-railo-dump tr tr:nth-child(even) {background: ##F2F2F2  !important;}
		div.-railo-dump tr:hover{ background-color:##e6faeb !important;} 
		</style>
	<cfelse>
		<style type="text/css"> 
		div.-lucee-dump  td span {font-weight:bold !important;}
		div.-lucee-dump table{ background-color:##FFF !important;font-family:Arial, Helvetica, sans-serif  !important; font-size:12px !important; empty-cells:show !important; color:##000 !important;border-spacing:0px !important;color:##000 !important;  border:none !important;}
		div.-lucee-dump td.r99f {background-color:##FFF !important; border-right:1px solid ##CCC !important; border-bottom:1px solid ##CCC !important; padding:3px !important;}
		div.-lucee-dump td.rc9c {background-color:##FFF !important; border-right:1px solid ##CCC !important; border-bottom:1px solid ##CCC !important; padding:3px !important;} 
		div.-lucee-dump td.r99f:nth-child(even) {background-color:##F2F2F2 !important;  }
		div.-lucee-dump td.rc9c:nth-child(even) {background-color:##F2F2F2 !important;  }
		div.-lucee-dump td {background-color:transparent !important; padding:3px !important; border:none !important; border-right:1px solid ##CCC !important;border-bottom:1px solid ##CCC !important;}
		div.-lucee-dump tr:nth-child(even) {background: ##F2F2F2  !important;}
		div.-lucee-dump tr tr:nth-child(even) {background: ##F2F2F2  !important;}
		div.-lucee-dump tr:hover{ background-color:##e6faeb !important;} 
		</style>
	</cfif>
</cffunction>



<cffunction name="zCheckAccess" localmode="modern" returntype="any" output="false">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="permission" type="string" required="yes">
	<cfargument name="role" type="string" required="yes">
	<cfscript>
	try{
		if(arguments.permission EQ "read"){
			if(arguments.role EQ "owner"){
				if(arguments.struct.access_owner_read){
				return true;
				}else{
					return false;
				}
			}else if(arguments.role EQ "group"){
				if(arguments.struct.access_group_read){
				return true;
				}else{
					return false;
				}
			}else if(arguments.role EQ "public"){
				if(arguments.struct.access_public_read){
				return true;
				}else{
					return false;
				}
			}else{
				application.zcore.template.fail("The role you specified, `"&arguments.role&"`, must be owner, group or public.",true);
			}
		}else if(arguments.permission EQ "write"){
			if(arguments.role EQ "owner"){
				if(arguments.struct.access_owner_write){
				return true;
				}else{
					return false;
				}
			}else if(arguments.role EQ "group"){
				if(arguments.struct.access_group_write){
				return true;
				}else{
					return false;
				}
			}else if(arguments.role EQ "public"){
				if(arguments.struct.access_public_write){
				return true;
				}else{
					return false;
				}
			}else{
				application.zcore.template.fail("The role you specified, `"&arguments.role&"`, must be owner, group or public.",true);
			}
		
		}else if(arguments.permission EQ "delete"){
			if(arguments.role EQ "owner"){
				if(arguments.struct.access_owner_delete){
				return true;
				}else{
					return false;
				}
			}else if(arguments.role EQ "group"){
				if(arguments.struct.access_group_delete){
				return true;
				}else{
					return false;
				}
			}else if(arguments.role EQ "public"){
				if(arguments.struct.access_public_delete){
				return true;
				}else{
					return false;
				}
			}else{
				application.zcore.template.fail("The role you specified, `"&arguments.role&"`, must be owner, group or public.",true);
			}
		
		}else{
			application.zcore.template.fail("Error: FUNCTION: zCheckAccess: The permission you specified, `"&arguments.permission&"`, must be read, write or delete.",true);
		}
	}catch(Any excpt){
		//application.zcore.template.fail("Error: FUNCTION: zOS_accessToString: access must be a valid access struct containing access_owner/group/public_read/write/delete variables.",true);  
	}
	// don't care if its not defined anymore
		return false;
	</cfscript>
</cffunction>

<!--- FUNCTION: zOS_getAccessFromPost(struct, fieldName); --->
<cffunction name="zOS_getAccessFromPost" localmode="modern" returntype="any" output="true">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	var tempStruct = StructNew();
	tempStruct.access_owner_read = false;
	tempStruct.access_owner_write = false;
	tempStruct.access_owner_delete = false;
	tempStruct.access_group_read = false;
	tempStruct.access_group_write = false;
	tempStruct.access_group_delete = false;
	tempStruct.access_public_read = false;
	tempStruct.access_public_write = false;
	tempStruct.access_public_delete = false;
	if(isDefined('arguments.struct.#arguments.fieldName#_owner_read')){
		tempStruct.access_owner_read = true;
	}
	if(isDefined('arguments.struct.#arguments.fieldName#_owner_write')){
		tempStruct.access_owner_write = true;
	}
	if(isDefined('arguments.struct.#arguments.fieldName#_owner_delete')){
		tempStruct.access_owner_delete = true;
	}
	if(isDefined('arguments.struct.#arguments.fieldName#_group_read')){
		tempStruct.access_group_read = true;
	}
	if(isDefined('arguments.struct.#arguments.fieldName#_group_write')){
		tempStruct.access_group_write = true;
	}
	if(isDefined('arguments.struct.#arguments.fieldName#_group_delete')){
		tempStruct.access_group_delete = true;
	}
	if(isDefined('arguments.struct.#arguments.fieldName#_public_read')){
		tempStruct.access_public_read = true;
	}
	if(isDefined('arguments.struct.#arguments.fieldName#_public_write')){
		tempStruct.access_public_write = true;
	}
	if(isDefined('arguments.struct.#arguments.fieldName#_public_delete')){
		tempStruct.access_public_delete = true;
	}
	return tempStruct;
	</cfscript>
</cffunction>

<!--- FUNCTION: zOS_accessToString(access); --->
<cffunction name="zOS_accessToString" localmode="modern" returntype="string" output="false">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	var chmod=0;
	try{
		if(arguments.struct.access_owner_read)chmod=chmod+400;
		if(arguments.struct.access_owner_write)chmod=chmod+200;
		if(arguments.struct.access_owner_delete)chmod=chmod+100;
		if(arguments.struct.access_group_read)chmod=chmod+40;
		if(arguments.struct.access_group_write)chmod=chmod+20;
		if(arguments.struct.access_group_delete)chmod=chmod+10;
		if(arguments.struct.access_public_read)chmod=chmod+4;
		if(arguments.struct.access_public_write)chmod=chmod+2;
		if(arguments.struct.access_public_delete)chmod=chmod+1;
	}catch(Any excpt){
		application.zcore.template.fail("Error: FUNCTION: zOS_accessToString: access must be a valid access struct containing access_owner/group/public_read/write/delete variables.",true);
	}
	return chmod;
	</cfscript>
</cffunction>







<cffunction name="zOS_recurseSiteDir" localmode="modern" output="true" returntype="any">
	<cfargument name="dirPath" type="string" required="yes">
	<cfargument name="dirPathRoot" type="string" required="yes">
	<cfargument name="siteRoot" type="string" required="no">
	<cfargument name="debug" type="boolean" required="no" default="#false#">
	<cfargument name="level" type="numeric" required="no" default="#1#">
	<cfargument name="cfonly" type="boolean" required="no" default="#true#">
	<cfargument name="sortString" type="string" required="no" default="">
	<cfargument name="noimages" type="boolean" required="no" default="#false#">
	<cfscript>
	var n=0;
	var qDir = "";
	var i = 0;
	var arrDir = ArrayNew(1);
	var addStruct = StructNew();
	var arrTemp = ArrayNew(1);
	var returnStruct = StructNew();
	if(isDefined('arguments.siteRoot') EQ false){
		arguments.siteRoot = arguments.dirPathRoot;
	}
	</cfscript>
	<cfif arguments.sortString NEQ ''>
	<cfdirectory action="list" directory="#arguments.dirPath#" name="qDir" sort="#arguments.sortString#">
	<cfelse>
	<cfdirectory action="list" directory="#arguments.dirPath#" name="qDir" sort="#arguments.sortString#">
	</cfif>
	<cfscript> 
	for(i=1;i LTE qDir.recordcount;i=i+1){
		if(qDir["type"][i] EQ "dir"){// and (arguments.cfonly EQ false or left(qDir["name"][i],1) NEQ '_')){
			if(qDir["name"][i] NEQ ".svn"){
				if(arguments.noimages EQ false or qDir["name"][i] NEQ 'images'){
					if(arguments.debug){
						writeoutput(replace(ljustify(" ", arguments.level*4), " ", "&nbsp;","ALL")&qDir["name"][i]);
						writeoutput("/<br />");
					}
					addStruct = StructNew();
					addStruct.name = qDir["name"][i];
					addStruct.parent = removeChars(arguments.dirPathRoot, 1, len(arguments.siteRoot)-1);
					addStruct.parent = removeChars(addStruct.parent, len(addStruct.parent), 1);
					addStruct.coldfusionRoot = arguments.dirPathRoot&qDir["name"][i]&"/";
					addStruct.siteRoot = addStruct.parent&"/"&qDir["name"][i];
					addStruct.dateLastModified=qDir.dateLastModified[i];
					addStruct.size=qDir.size[i];
					if(addStruct.parent EQ ""){
						addStruct.parent = "/";
					}
					addStruct.path = arguments.dirPath&qDir["name"][i]&"/";
					addStruct.dir = true;
					arrayAppend(arrDir, addStruct);
					// recurse dir
					arrTemp = application.zcore.functions.zOS_recurseSiteDir(addStruct.path, addStruct.coldfusionRoot, arguments.siteRoot, arguments.debug, arguments.level+1,arguments.cfonly, arguments.sortString, arguments.noimages);
					// copy recursed array to current array.
					for(n=1;n LTE arrayLen(arrTemp);n=n+1){
						arrayAppend(arrDir, arrTemp[n]);
					}
					if(arguments.debug){
						writeoutput("<br />");
					}
				}
			}
		}else if(qDir["type"][i] EQ "file"){
			if(arguments.cfonly EQ false or ((right(qDir["name"][i],3) EQ "cfm" or right(qDir["name"][i],3) EQ "cfc") and left(qDir["name"][i],1) NEQ '_' and qDir["name"][i] NEQ 'Application.cfm' and qDir["name"][i] NEQ 'onRequestEnd.cfm')){
				if(arguments.debug){
					writeoutput(replace(ljustify(" ", arguments.level*4), " ", "&nbsp;","ALL")&qDir["name"][i]);
					writeoutput("<br />");
				}
				// ignore the current script
				if(replace(CGI.PATH_TRANSLATED,"\","/","ALL") NEQ arguments.dirPath&qDir["name"][i]){
					addStruct = StructNew();
					addStruct.name = qDir["name"][i];
					addStruct.dateLastModified=qDir.dateLastModified[i];
					addStruct.size=qDir.size[i];
					addStruct.parent = removeChars(arguments.dirPathRoot, 1, len(arguments.siteRoot)-1);
					addStruct.parent = removeChars(addStruct.parent, len(addStruct.parent), 1);
					addStruct.coldfusionRoot = arguments.dirPathRoot&qDir["name"][i];
					addStruct.siteRoot = addStruct.parent&"/"&qDir["name"][i];					
					if(addStruct.parent EQ ""){
						addStruct.parent = "/";
					}

					addStruct.path = arguments.dirPath&qDir["name"][i];
					addStruct.dir = false;
					arrayAppend(arrDir, addStruct);
				}
			}
		}
	}
	return arrDir;
	</cfscript>
</cffunction>

<!--- 
not used
 application.zcore.functions.zAppendSiteOptionGroupDefaults(dataStruct, site_option_group_id); --->
<!--- <cffunction name="zAppendSiteOptionGroupDefaults" localmode="modern" output="false" returntype="any">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="site_option_group_id" type="string" required="yes">
	<cfscript> 
	return application.zcore.siteOptionCom.appendOptionGroupDefaults(arguments.dataStruct, arguments.site_option_group_id); 
	</cfscript>
</cffunction> --->

<!--- re-create the site globals and user group cache --->
<cffunction name="zOS_cacheSiteAndUserGroups" localmode="modern" output="false" returntype="any">
	<cfargument name="site_id" type="string" required="yes">
    <cfscript>
	var tempStruct='';
	var curSetNumber='';
	var curSetNumber1='';
	
	var qSite=0;
	var qgroup=0;
	var qgroupx=0;
	var output="";
	var i=0;
	var qs=0;
	var result=0;
	var tempUniqueStruct=0;
	var id=0;
	var nk=0;
	var t9=0;
	var ts=0;
	var lastGroup="";
	var rgb=0;
	var qs2=0;
	var row=0;
	var firstTempStruct=structnew();
	var varName="";
	var pos="";
	var db=request.zos.queryObject;
	tempStruct=0;
	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(arguments.site_id)# and 
	site_deleted = #db.param(0)#";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){
		return;
	}
	tempPath=application.zcore.functions.zGetDomainInstallPath(qSite.site_short_domain);
	if(directoryExists(tempPath) EQ false){
		if(qSite.site_active EQ 1){
			// disable sites that are missing their source code.
			db.sql="UPDATE #db.table("site", request.zos.zcoreDatasource)# SET site_active=#db.param(0)#  
			WHERE site_id = #db.param(arguments.site_id)# and 
			site_deleted = #db.param(0)#";
			qSite=db.execute("qSite");
		}
		return;
	}
	// re-cache the site paths, this function is defined at top of page
	tempStruct = StructNew();
	application.zcore.functions.zQueryToStruct(qSite, tempStruct);
	if(tempStruct.site_siteroot NEQ ''){
		tempStruct.cfcSiteRoot = replace(removeChars(tempStruct.site_siteroot,1,1),'/','.','ALL')&'.';
	}else{
		tempStruct.cfcSiteRoot='';
	}
	//output = application.zcore.functions.zStructToString("Request.zOS.globals", tempStruct, true);
	for(i in tempStruct){
		if(left(i, 5) EQ "site_"){
			varName=mid(i, 5, len(i)-4);
		}else{
			varName=i;
		}
		varName = replace(varName, '_','','ALL');
		firstTempStruct[varName]=tempStruct[i];
	}
	tempStruct=firstTempStruct; 
	db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE site_id = #db.param(arguments.site_id)# and 
	user_group_deleted = #db.param(0)#";
	qGroup=db.execute("qGroup");
	db.sql="SELECT * FROM #db.table("user_group_x_group", request.zos.zcoreDatasource)# user_group_x_group, 
	#db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE 
	user_group_deleted = #db.param(0)# and 
	user_group_x_group_deleted = #db.param(0)# and 
	user_group_x_group.user_group_child_id = user_group.user_group_id and 
	user_group_x_group.site_id = #db.param(arguments.site_id)# and 
	user_group_x_group.site_id = user_group.site_id";
	qGroupX=db.execute("qGroupX");
	//tempStruct = StructNew();
	tempStruct.user_group.ids_names = StructNew();
	tempStruct.user_group.ids = StructNew();
	tempStruct.user_group.names = StructNew();
	tempStruct.user_group.access = StructNew();
	tempStruct.user_group.modify_user = StructNew();
	tempStruct.user_group.share_user = StructNew(); 
	for(row in qGroup){
		if(row["user_group_primary"] EQ 1){
			tempStruct.user_group.primary = row["user_group_id"];
		}
		tempStruct.user_group.names[row["user_group_name"]]=row["user_group_id"];
		if(row["user_group_friendly_name"] EQ ""){
			tempStruct.user_group.ids_names[row["user_group_id"]]=replace(row["user_group_name"], "_", " ", "all");
		}else{
			tempStruct.user_group.ids_names[row["user_group_id"]]=row["user_group_friendly_name"];
		}
		tempStruct.user_group.ids[row["user_group_id"]]=row["user_group_name"];
		// create the login access struct for each group
		tempStruct.user_group.access[row["user_group_id"]]={};
		tempStruct.user_group.modify_user[row["user_group_id"]]={};
		tempStruct.user_group.share_user[row["user_group_id"]]={};
		// force the parent group to have access to itself
		tempStruct.user_group.access[row["user_group_id"]][row["user_group_name"]]=row["user_group_id"]; 
	} 
	for(row in qGroupX){
		// add the child user groups to each access struct
		if(row.user_group_modify_user EQ 1){
			tempStruct.user_group.modify_user[row["user_group_id"]][row["user_group_name"]]=row["user_group_child_id"];		
		}
		if(row.user_group_login_access EQ 1){
			tempStruct.user_group.access[row["user_group_id"]][row["user_group_name"]]=row["user_group_child_id"];
		}
		if(row.user_group_share_user EQ 1){
			tempStruct.user_group.share_user[row["user_group_id"]][row["user_group_name"]]=row["user_group_child_id"];
		}
	}

	application.zcore.siteOptionCom.internalUpdateOptionAndGroupCache(tempStruct);

	tempStruct.themeData={};
	tempStruct.widgetData={};


	tempStruct.lastModifiedDate=now();
	curPrivatePath=application.zcore.functions.zGetDomainWritableInstallPath(qsite.site_short_domain);
	if(qsite.site_short_domain_previous NEQ ""){
		sdomain=lcase(replacenocase(replacenocase(qsite.site_short_domain_previous,"www.",""),"."&request.zos.testDomain,""));
		tempPrivatePath=request.zos.sitesWritablePath&sdomain&"/";
		if(directoryexists(tempPrivatePath)){
			curPrivatePath=tempPrivatePath;
		}
	}
	// don't need a lock for a temporary object
	//lock name="#request.zos.installPath#-zCacheJsonSiteAndUserGroup-serialize" type="exclusive" timeout="10"{
	a=serializeJson(tempStruct);
	//}
	application.zcore.functions.zWriteFile(curPrivatePath&'_cache/scripts/global.json', a);
	curSiteId=tempStruct.id;
	request.zos.globals=duplicate(application.zcore.serverglobals);
	structappend(Request.zos.globals, firstTempStruct, true);
	structappend(Request.zos.globals, tempStruct, true);
	
	tempStruct=structnew();
	tempStruct.site_id=arguments.site_id;
	tempStruct.globals=request.zos.globals;
	tempStruct=application.zcore.functions.zGetSite(tempStruct); 
	application.sitestruct[arguments.site_id]=tempStruct;
	application.zcore.siteGlobals[arguments.site_id]=tempStruct.globals;
	if(arguments.site_id EQ curSiteId){
		application.sitestruct[arguments.site_id].globals=request.zos.globals;
	}

	for(row in qSite){
		application.zcoreSiteDataStruct[arguments.site_id]=row;
	}
	application.zcoreSitePaths=deserializeJson(fileread(request.zos.zcoreRootPrivatePath&"_cache/scripts/sites.json", "utf-8"));
	application.zcoreSitesLoaded[arguments.site_id]=0;
	application.zcoreSitesListingLoaded[arguments.site_id]=application.zcoreSitesLoaded[arguments.site_id];
 
	structdelete(application.sitestruct[arguments.site_id],'administratorTemplateMenu');
	</cfscript>
</cffunction>

<cffunction name="zCacheJsonSiteAndUserGroup" localmode="modern">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="tempStruct" type="struct" required="yes">
	<cfscript>
	var shortDomain=application.zcore.functions.zvar('shortDomain', arguments.site_id);
	if(shortDomain EQ ""){
		throw("site_id, #arguments.site_id#, doesn't exist.");
	}
	var curPrivatePath=application.zcore.functions.zGetDomainWritableInstallPath(shortDomain);


	structappend(application.sitestruct[arguments.site_id].globals, arguments.tempStruct, true);
	application.zcore.siteglobals[arguments.site_id]=arguments.tempStruct;
	lock name="#request.zos.installPath#-zCacheJsonSiteAndUserGroup-serialize" type="exclusive" timeout="10"{
		a=serializeJson(arguments.tempStruct);
	}
	application.zcore.functions.zWriteFile(curPrivatePath&'_cache/scripts/global.json', a);
	</cfscript>
</cffunction>

<cffunction name="zUpdateGlobalMVCData" localmode="modern" access="public" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="forceUpdate" type="boolean" required="yes">
	<cfscript>
	ts={};
	ts.controllerComponentCache={};
	ts.modelDataCache={
		modelComponentCache:{}
	};
	ts.cfcMetaDataCache=structnew();
	ts.modelDataCache={
		modelComponentCache:{}
	};
	arrNewComPath=arraynew(1);
	ts.registeredControllerStruct=structnew();
	ts.registeredControllerPathStruct=structnew();
	ts.arrLandingPage=[];
	ts.hookAppCom=structnew();
	
	mvcFilesChanged=false;
	arrLocalFile=[]; 
	if(directoryexists(request.zos.installPath&"core/mvc/")){
		if(fileexists("#arguments.ss.serverglobals.serverprivatehomedir#_cache/mvc-cache.cfc")){
			output1=application.zcore.functions.zSecureCommand("getNewerCoreMVCFiles", 50); 
		}else{
			output1=1;
		}
		request.zos.requestLogEntry('Application.cfc onApplicationStart 3-4-2');
		if(output1 NEQ ""){
			directory action="list" recurse="yes" directory="#request.zos.installPath#core/mvc" name="qD" filter="*.cfc"; 
			ts434=structnew();
			arrFunction=['arrFile=variables.get1(arrFile);'];
			ts434.arrFile=['
				<cffunction name="get#arrayLen(arrFunction)#" localmode="modern" access="private">
					<cfargument name="arrFile" type="array" required="yes">
					<cfscript>
					arrFile=arguments.arrFile;
			'];
			if(qD.recordcount GT 1){
				arrLocalFile=[];
				tempCount=1;
				loop query="qD"{ 
					arrayAppend(ts434.arrFile, 'arrayAppend(arrFile, { type:"#qD.type#", directory:"#replace(qD.directory, "#request.zos.installPath#core/", "/")#", name:"#qD.name#", lastModified:"#qD.dateLastModified#"});');
					arrayappend(arrLocalFile, {"type":qD.type, "directory":replace(qD.directory, "#request.zos.installPath#core/", "/"), name:qD.name, lastModified:qD.dateLastModified});
					tempCount++;
					if(tempCount GTE 100){
						arrayAppend(arrFunction, 'arrFile=variables.get'&(arrayLen(arrFunction)+1)&'(arrFile);');
						arrayappend(ts434.arrFile, '
						return arrFile;
						</cfscript>
						</cffunction>
						<cffunction name="get#arrayLen(arrFunction)#" localmode="modern" access="private">
							<cfargument name="arrFile" type="array" required="yes">
							<cfscript>
							arrFile=arguments.arrFile;
						');	
						tempCount=1;
					} 
				}
				arrayappend(ts434.arrFile, '
					return arrFile;
					</cfscript>
					</cffunction>');
				//tempStructString=application.zcore.functions.zStructToString("local", ts434);
				tempComponentString='<cfcomponent>
				<cffunction name="get" localmode="modern" access="public" hint="DO NOT EDIT THIS FILE. It is automatically regenerated when the /zcorerootmapping/mvc directory has new or removed CFC files.  This is done so that we can automatically cache CFC metadata when the application is deployed to the production server without the CFML source.   "  returntype="array">
				<cfscript>
				
				arrFile=arraynew(1);
				'&arrayToList(arrFunction, '')&'
				return arrFile;
				</cfscript>
				</cffunction>
				'&arrayToList(ts434.arrFile, '')&'
				</cfcomponent>';   
				if(hash(tempComponentString) NEQ hash(application.zcore.functions.zreadfile("#arguments.ss.serverglobals.serverprivatehomedir#_cache/mvc-cache.cfc"))){
					application.zcore.functions.zwritefile(arguments.ss.serverglobals.serverprivatehomedir&"_cache/mvc-cache.cfc", tempComponentString);
					application.zcore.functions.zClearCFMLTemplateCache();
					mvcFilesChanged=true;
				} 
			}
			request.zos.requestLogEntry('Application.cfc onApplicationStart 3-5');
		}
	}
	if(arrayLen(arrLocalFile)){
		arrFile=arrLocalFile;
	}else{
		mvcCacheCom=application.zcore.functions.zcreateobject("component","zcorecachemapping.mvc-cache", true); 
		arrFile=mvcCacheCom.get();
	}
	if(structkeyexists(form, 'zforce')){//not request.zos.isTestServer or 
		mvcFilesChanged=true;
	} 
	// mvcFilesChanged=true; // TODO: temporary need to remove!
	if(mvcFilesChanged or (not structkeyexists(application, 'zcore') or not structkeyexists(application.zcore, 'controllerComponentCache') or structcount(application.zcore.hookAppCom) EQ 0)){ 
		threadCount=4;
		loopCount=ceiling(arrayLen(arrFile)/threadCount);
		loopOffset=1; 
		arrThread=[];
		for(n=1;n LTE threadCount;n++){
	        arrayAppend(arrThread, "mvcGlobalUpdateThread#n#");
	        thread name = "mvcGlobalUpdateThread#n#" timeout = "10000" componentObjectCache="#arguments.ss.componentObjectCache#" serverGlobals="#arguments.ss.serverGlobals#" arrFile="#arrFile#" ts="#ts#" startIndex="#loopOffset#" endIndex="#loopOffset+loopCount#"{
	        	endIndex=min(endIndex, arraylen(arrFile));
				for(i2=startIndex;i2 LTE endIndex;i2++){
					qD=arrFile[i2];
					if(left(qD.directory, 12) EQ '/mvc/z/test/'){
						continue;
					}
					
					i=i2;
					curPath=serverglobals.serverhomedir&removechars(qD.directory,1,1)&"/"&qD.name;
					curPath2="/zcorerootmapping"&qD.directory&"/"&qD.name;
					curPath22="/zcorerootmapping"&qD.directory&"/"&qD.name;
					if(qD.name EQ "hook.cfc"){
						ts.hookAppCom[qD.name]=application.zcore.functions.zcreateobject("component","zcorerootmapping."&replace(replace(qD.directory, serverglobals.serverhomedir, ""),"/",".","all")&"."&left(qD.name, len(qD.name)-4), true);
						ts.hookAppCom[qD.name].registerHooks(componentObjectCache.hook);
						continue;
					}
					if(qD.type EQ "file"){ 
						curPath2=removechars(replace(replace(replace(serverglobals.serverhomedir&removechars(qD.directory,1,1),"\","/","all"),curPath,""), serverglobals.serverhomedir&"mvc/",""),1,0);
						arrPath2=listtoarray(curPath2,"/",false);
						fileType=listgetat(curPath2,1,"/");
						curPath3=replace(curPath2,"/",".","all");
						curPath4=listdeleteat(curPath3,1,".");
						curName=listgetat(qD.name,1,".");
						curExt=listgetat(qD.name,2,".");
						lastFolderName=listgetat(curPath2,listlen(curPath2, "/", true),"/");
						if(curName CONTAINS "."){
							application.zcore.functions.zerror(qD.directory&"/"&qD.name&" - A CFC file name can't have a period after the "".cfc"" is removed from the end.  Please remove the periods in the name, ""."", leave the "".cfc"" at the end and try again.");	
						}
						
						if(lastFolderName EQ "controller"){
							if(curExt EQ "cfc"){
								comPath=replace(mid(curPath22,2,len(curPath22)-5),"/",".","all");
								tempCom=application.zcore.functions.zcreateobject("component", comPath, true);
								tempcommeta=GetMetaData(tempCom);
								ts.controllerComponentCache[comPath]=tempCom;
								ts.cfcMetaDataCache[comPath]=tempcommeta;
								if(structkeyexists(tempcommeta,'functions')){
									for(i3=1;i3 LTE arraylen(tempcommeta.functions);i3++){
										c=tempcommeta.functions[i3];
										if(structkeyexists(c,"access") and c.access EQ "remote"){
											ts.cfcMetaDataCache[comPath&":"&c.name]=c;
											if(structkeyexists(c,"jetendo-landing-page") and c["jetendo-landing-page"]){
												arrayAppend(ts.arrLandingPage, replace("/"&curPath3&"/"&left(qD.name, len(qD.name)-4)&"/"&c.name, "/controller", ""));
											}
										}
									}
								}
								if(structkeyexists(tempCom,'mvcName')){
									curMvcName="/"&curpath2&"/"&tempCom.mvcName;
								}else{
									curMvcName="/"&curpath2&"/"&curName;
								}
								curMvcName=replace(curMvcName, serverglobals.serverhomedir&"mvc/", "");
								t42="";
								for(i4=1;i4 LTE arraylen(arrPath2);i4++){
									t42&="/"&arrPath2[i4];
									ts.registeredControllerPathStruct[t42]=true;
								}
								ts.registeredControllerStruct[curMvcName]=replace(curPath, serverglobals.serverhomedir, "/zcorerootmapping/");
							}
							
						}else if(lastFolderName EQ "model"){
							if(curExt EQ "cfc"){
								comPath=replace(mid(curPath22,2,len(curPath22)-5),"/",".","all");
								ts.modelDataCache.modelComponentCache[comPath]=application.zcore.functions.zcreateobject("component", comPath, true);
							}/*
						}else if(lastFolderName EQ "view"){
							if(curExt EQ "html"){
								//writeoutput('application.zcore.skin.loadView("'&curPath3&"."&curName&'", "'&arrMvcPaths[i]&'");<br />');
								// application.zcore.skin.loadView("/"&curPath2&"/"&curName, arrMvcPaths[i]);
							}*/
						}
					}
				}
			}
			loopOffset+=loopCount+1;
		}
        thread action="join" name="#arraytolist(arrThread, ",")#" timeout="100000";
        for(t in arrThread){
        	if(cfthread[t].status NEQ "completed"){
	        	savecontent variable="out"{
		        	echo("<h2>Failed to Create MVC Objects</h2>");
		        	writedump(cfthread);
	        	}
        		throw(out);
        	}
	    } 
		structappend(arguments.ss, ts, true);
	}else{
		ts.hookAppCom=application.zcore.hookAppCom;
		ts.cfcMetaDataCache=application.zcore.functions.zso(application.zcore, 'cfcMetaDataCache', false, {});
		ts.controllerComponentCache=application.zcore.controllerComponentCache;
		ts.registeredControllerPathStruct=application.zcore.registeredControllerPathStruct;
		ts.registeredControllerStruct=application.zcore.registeredControllerStruct;
		structappend(arguments.ss, ts, true);
	}
	</cfscript>
</cffunction>

<cffunction name="zOS_rebuildCache" localmode="modern" output="no" returntype="any">
	<cfscript>
	
	var db=request.zos.queryObject;
	var qSite=0;
	application.zcore.functions.zOS_cacheSitePaths();
	db.sql="SELECT site_id from #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id <> #db.param(-1)# and 
	site_active = #db.param(1)# and 
	site_deleted = #db.param(0)#";
	qSite=db.execute("qSite");
	for(row in qSite){
	    application.zcore.functions.zOS_cacheSiteAndUserGroups(row.site_id);
	}
    </cfscript>
</cffunction>

<!--- re-create the server wide caching of site paths. --->
<cffunction name="zOS_cacheSitePaths" localmode="modern" output="no" returntype="any">
	<cfscript>
	
	var qSites = "";
	var output = "";
	var result = "";
	var i = 1;
	var row=0;
	var tempStruct = StructNew();
	var arrT=arraynew(1);
	var c="";
	var cs="";
	var ce="";
	var db=request.zos.queryObject;
	var endString="";
	var startString="";
	var theOut="";
	query name="qS" datasource="#request.zos.zcoreDatasource#"{
		writeoutput("SELECT site.site_id, site_short_domain, site_domain,
		if(app_x_site_id is NULL, 0, 1) hasListingApp FROM `site` 
		LEFT JOIN app_x_site ON 
		app_x_site.site_id = site.site_id and  
		app_x_site_deleted='0' and 
		app_x_site.app_id='11' 
		WHERE site_active='1' and 
		site_deleted='0'  
		GROUP BY site.site_id");
	}  
	for(row in qS){
		application.zcoreSiteDataStruct[row.site_id]=row; 
	}

	db.sql="SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)# and
	site_active=#db.param(1)#";
	qSites=db.execute("qSites");
	tempStruct = StructNew();
	for(row in qSites){
		if(trim(row.site_domain) NEQ ''){
			StructInsert(tempStruct, row.site_domain,row.site_id,true);
		}
		if(trim(row.site_securedomain) NEQ ''){
			StructInsert(tempStruct, row.site_securedomain,row.site_id,true);
		}
		tempPath=application.zcore.functions.zGetDomainInstallPath(row.site_short_domain);
		if(directoryexists(tempPath)){
			StructInsert(tempStruct, tempPath,row.site_id,true);
		}
		tempPath=application.zcore.functions.zGetDomainWritableInstallPath(row.site_short_domain);
		if(directoryexists(tempPath)){
			StructInsert(tempStruct, tempPath,row.site_id,true);
		}
	}
	for(row in qSites){
		var arrTemp=listToArray(row.site_domainaliases, ",", false);
		for(var i=1;i LTE arrayLen(arrTemp);i++){
			var p="http://";
			if(left(row.site_domain, 8) EQ "https://"){
				p="https://";
			}
			StructInsert(tempStruct, p&trim(arrTemp[i]), row.site_id, false);
		}
		if(row.site_ssl_manager_domain NEQ ""){
			StructInsert(tempStruct, 'https://'&trim(row.site_ssl_manager_domain), row.site_id, false);
		}
	}
	application.zcore.functions.zWriteFile(request.zos.globals.serverprivatehomedir&'_cache/scripts/sites.json', serializeJson(tempStruct));
	application.zcore.sitePaths=tempStruct;
	</cfscript>
</cffunction>

<cffunction name="zClearCFMLTemplateCache" localmode="modern">
	<cfscript>
	if(not structkeyexists(application,'onInternalApplicationStartRunning')){
		componentCacheClear();
		pagePoolClear();
		// ctCacheClear(); // custom tag cache
		//objectcache action="clear"; // query cache
	}
	</cfscript>
</cffunction>

<cffunction name="zGetDomainInstallPath" localmode="modern" access="public" returntype="string">
	<cfargument name="domain" type="string" required="yes">
	<cfscript>
	if(request.zos.istestserver){
		return request.zos.sitesPath&replace(replace(replace(arguments.domain, "www.","","all"), "."&request.zos.testDomain, ""), ".", "_", "all")&"/";
	}else{
		return request.zos.sitesPath&replace(replace(arguments.domain, "www.","","all"), ".", "_", "all")&"/";
	}
	</cfscript>
</cffunction>

<cffunction name="zGetDomainWritableInstallPath" localmode="modern" access="public" returntype="string">
	<cfargument name="domain" type="string" required="yes">
	<cfscript>
	if(request.zos.istestserver){
		return request.zos.sitesWritablePath&replace(replace(replace(arguments.domain, "www.","","all"), "."&request.zos.testDomain, ""), ".", "_", "all")&"/";
	}else{
		return request.zos.sitesWritablePath&replace(replace(arguments.domain, "www.","","all"), ".", "_", "all")&"/";
	}
	</cfscript>
</cffunction>

<cffunction name="zOS_getSiteNav" localmode="modern" returntype="any" output="false" hint="displays server admin site navigation">
	<cfargument name="zid" type="string" required="yes">
	<cfscript>
	
	var selectStruct='';
	var qSites='';
	var qSite='';
	var db=request.zos.queryObject;
	var content = "";
	var zsaHeader = "";

	if(not application.zcore.user.checkServerAccess()){
		application.zcore.status.setStatus(request.zsid, "You don't have access to the server manager.", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}

	</cfscript>
	<cfif structkeyexists(form,'sid') EQ false>
    	<cfset form.sid=application.zcore.status.getField(arguments.zid, 'site_id')>
		<cfset form.sid = form.sid>
    <cfelse>
    	<cfset form.sid=form.sid>
	</cfif>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)# and
	site_active= #db.param(1)# 
	ORDER BY site_domain
	</cfsavecontent><cfscript>qSites=db.execute("qSites");</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)# and 
	site_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qSite=db.execute("qSite");


	if(not application.zcore.user.checkAllCompanyAccess() and form.sid NEQ "" and form.sid NEQ "0"){
		if(request.zsession.user.company_id NEQ qSite.company_id){
			application.zcore.status.setStatus(request.zsid, "You don't have access to the server manager for this site_id: #form.sid#.", form, true);
			application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
		}
	}
	</cfscript>
	<cfsavecontent variable="zsaHeader">
	<script type="text/javascript">/* <![CDATA[ */
    function zOSGoToSite(id){
        if(id != ''){
            window.location.href='#request.cgi_script_name#?#replacenocase(cgi.QUERY_STRING,'sid=','zzzsid=','ALL')#&sid='+escape(id);
        }
    }
	/* ]]> */
    </script>
	<table style="width:100%; border-spacing:0px;margin-top:-10px; background-color:##DDD;" class="table-list">
		<tr><th style="background-color:##000 !important;color:##FFF; font-weight:bold; font-size:120%;padding:10px;">Server Manager


			<cfif request.zos.isTestServer>
				| Current Server: Test
			<cfelse>
				| Current Server: Live
			</cfif>
		</th></tr>
	<tr>
	<td style="padding:10px;"><a href="/z/server-manager/admin/server-home/index">Dashboard</a>
	<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator")>
	 | <a href="/z/server-manager/admin/site-select/index?sid=">Sites</a> 
	 <cfif application.zcore.user.checkAllCompanyAccess()>
	
		| <a href="/z/server-manager/admin/dns-group/index">DNS</a> 
		| <a href="/z/_com/zos/app?method=appList&amp;zid=#arguments.zid#&amp;sid=#form.sid#">Apps</a>
		| <a href="/z/server-manager/admin/log?sid=">Logs</a> 
		| <a href="/z/server-manager/admin/deploy/index">Deploy</a>
	</cfif>
     
	 </cfif>
	 </td>
	</tr>
	</table>
	</cfsavecontent>
	<cfscript>
	if(len(form.sid) EQ 0){
		application.zcore.status.setField(arguments.zid, "site_id", "");
		return zsaHeader;
	}else{
		application.zcore.status.setField(arguments.zid, "site_id", form.sid);
	}
	form.sid = application.zcore.status.getField(arguments.zid, 'site_id');
	</cfscript>
	<cfsavecontent variable="content"><cfif structkeyexists(request.zos.userSession.groupAccess, "administrator")>
	<table style="width:100%; background-color:##EEE;  border-spacing:0px;margin-bottom:10px;" class="table-list">
	<tr>
	<th style="font-weight:bold; font-size:120%;"><a href="#qSite.site_domain#" target="_blank">#qSite.site_sitename#</a> | Server Manager</th>
	<th style="text-align:right;" class="tiny"><a href="/z/server-manager/admin/site/delete?zid=#arguments.zid#">Deactivate Site</a></th>
	</tr>
	<tr>
	<td colspan="2" class="tiny-bold">
	<a href="/z/server-manager/admin/site/edit?zid=#arguments.zid#&amp;sid=#form.sid#">Globals</a>
	| <a href="/z/server-manager/admin/domain-redirect/index?zid=#arguments.zid#&amp;sid=#form.sid#">Domain Redirects</a>
	<cfif application.zcore.user.checkAllCompanyAccess()>
		| <a href="/z/server-manager/admin/deploy/index?zid=#arguments.zid#&amp;sid=#form.sid#">Deploy</a>
	</cfif>
	| <a href="/z/server-manager/admin/white-label/index?zid=#arguments.zid#&amp;sid=#form.sid#">White-Label</a>
	| <a href="/z/server-manager/admin/cloud-admin/listContainers?zid=#arguments.zid#&amp;sid=#form.sid#">Cloud</a>
	| <a href="/z/server-manager/admin/compress-images/compressSitePrivateHomedirImages?zid=#arguments.zid#&amp;sid=#form.sid#">Compress User Images</a>
	<cfif request.zos.isTestServer>
	| <a href="/z/server-manager/admin/generate-sublime-project/index?zid=#arguments.zid#&amp;sid=#form.sid#">Generate Sublime Project</a>
	</cfif>
	
	<!--- | <a href="/z/server-manager/admin/site/downloadste?zid=#arguments.zid#&amp;sid=#form.sid#">Dreamweaver STE</a> --->
	<cfif qSite.site_theme_sync_site_id NEQ 0> | <a href="/z/server-manager/admin/site/manualSync?zid=#arguments.zid#&amp;sid=#form.sid#">Sync Source Code</a></cfif>
	| <a href="/z/server-manager/admin/download-site-backup/index?zid=#arguments.zid#&amp;sid=#form.sid#">Backup</a>
	| <a href="/z/server-manager/admin/user/index?zid=#arguments.zid#&amp;sid=#form.sid#">Users</a> 
	| <a href="/z/_com/zos/app?method=instanceSiteList&amp;zid=#arguments.zid#&amp;sid=#form.sid#">Applications</a>
	| <a href="/z/server-manager/admin/imap-account/index?zid=#arguments.zid#&amp;sid=#form.sid#">IMAP Accounts</a>
	| <a href="/z/server-manager/admin/rewrite-rules/edit?zid=#arguments.zid#&amp;sid=#form.sid#">Rewrite Rules</a>
	| <a href="/z/server-manager/admin/robots/edit?zid=#arguments.zid#&amp;sid=#form.sid#">Robots.txt</a>
	| <a href="/z/server-manager/admin/ssl/index?zid=#arguments.zid#&amp;sid=#form.sid#">SSL</a>
	| <a href="/z/server-manager/admin/hardcoded-urls/edit?zid=#arguments.zid#&amp;sid=#form.sid#">Hardcoded URLs</a>
	| <a href="/z/server-manager/admin/clear-site-data/index?zid=#arguments.zid#&amp;sid=#form.sid#">Clear Data</a>
	<cfif request.zos.istestserver> 
		| <a href="/z/server-manager/admin/sync-download/index?zid=#arguments.zid#&amp;sid=#form.sid#">Sync</a>
	</cfif>
	</td>
	</tr>
	</table></cfif>
	</cfsavecontent>
	<cfreturn zsaHeader&content>
</cffunction>


<cffunction name="zMenuClearCache" localmode="modern" returntype="any" output="no">
	<cfargument name="affectedStruct" type="struct" required="yes">
	<cfscript>
	
	for(i IN application.sitestruct[request.zos.globals.id].menuIdCacheStruct){
		for(n IN arguments.affectedStruct){
			if(n EQ "all"){
				structdelete(application.sitestruct[request.zos.globals.id].menuIdCacheStruct, i);
				break;
			}else if(structkeyexists(application.sitestruct[request.zos.globals.id].menuIdCacheStruct[i].affectedStruct, n)){
				structdelete(application.sitestruct[request.zos.globals.id].menuIdCacheStruct, i);
				break;
			}
		}		
	}
	for(i IN application.sitestruct[request.zos.globals.id].menuNameCacheStruct){
		for(n IN arguments.affectedStruct){
			if(n EQ "all"){
				structdelete(application.sitestruct[request.zos.globals.id].menuNameCacheStruct, i);
				break;
			}else if(not structkeyexists(application.sitestruct[request.zos.globals.id].menuNameCacheStruct[i], 'affectedStruct') or structkeyexists(application.sitestruct[request.zos.globals.id].menuNameCacheStruct[i].affectedStruct, n)){
				structdelete(application.sitestruct[request.zos.globals.id].menuNameCacheStruct, i);
				break;
			}
		}		
	}
	</cfscript>
</cffunction>

<!--- 
ts=structnew();
ts.menu_id=5;
// or
ts.menu_name="";
ts.idPrefix="";
ts.returnLinkArray=false; // set to true to return link array instead of HTML
rs=zMenuInclude(ts);
// output html
writeoutput(rs.output);
// or
ts.menu_name="";
ts.idPrefix="";
ts.returnLinkArray=true; // set to true to return link array instead of HTML
arrLink=zMenuInclude(ts); 
linkCount=arrayLen(arrLink);
if(linkCount){  
	echo('<ul>');
	for(i=1;i LTE linkCount;i++){
		c=arrLink[i];
		echo('<li>'); 
		echo('<a href="#c.url#" ');
		if(c.target EQ "_blank"){
			echo('rel="external" target="_blank"');
		}
		echo('>#(c.text)#</a>'); 
		// uncomment for sublinks
		subCount=arrayLen(c.arrChildren);
		if(subCount){
			echo('<ul>');
			for(n=1;n LTE subCount;n++){
				g=c.arrChildren[n];
				echo('<li><a href="#(g.url)#" ');
				if(g.target EQ "_blank"){
					echo(' rel="external" target="_blank"');
				}
				echo('>#(g.text)#</a></li>#chr(10)#');
			}
			echo('</ul>');
		} 
		echo('</li>');
	} 
	echo('</ul>');
}
 --->
<cffunction name="zMenuInclude" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	menuCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.menuFunctions");
	menuCom.init(arguments.ss);
	idPrefix=application.zcore.functions.zso(arguments.ss, 'idPrefix');
	arrLink=menuCom.getMenuLinkArray(idPrefix); 
	if(application.zcore.functions.zso(arguments.ss, 'returnLinkArray', false, false)){
		return arrLink;
	} 

	rs={
		arrLink:arrLink,
		output:menuCom.getMenuHTML(idPrefix)
	};
	return rs;
	</cfscript>
</cffunction>



<!--- zGetSiteSelect(fieldName); --->
<cffunction name="zGetSiteSelect" localmode="modern" output="yes" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	
	var db=request.zos.queryObject;
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_active= #db.param(1)# and 
	site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)#
	ORDER BY site_sitename ASC
	</cfsavecontent><cfscript>qSites=db.execute("qSites");
    selectStruct = StructNew();
    selectStruct.name = arguments.fieldName;
    selectStruct.query = qSites;
    selectStruct.queryLabelField = "site_sitename";
    selectStruct.queryValueField = "site_id";
    application.zcore.functions.zInputSelectBox(selectStruct);
    </cfscript>
</cffunction>

<cffunction name="zRequireRespondJs" localmode="modern" access="public">
	<cfscript>
	application.zcore.template.appendTag("meta", '<!--[if lt IE 9]>
		<script src="/z/javascript/html5shiv.min.js"></script>
		<script src="/z/javascript/respond.min.js"></script>
	<![endif]-->');
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zGetSiteGlobals(site_id) --->
<cffunction name="zGetSiteGlobals" access="public" localmode="modern">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	if(not structkeyexists(application.zcore.siteglobals, arguments.site_id)){
		db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(arguments.site_id)# and 
		site_active = #db.param(0)#";
		qSite=db.execute("qSite");
		if(qSite.recordcount EQ 0){
			throw("site_id: #arguments.site_id#, doesn't exist.");
		}
		tempPath=application.zcore.functions.zGetDomainInstallPath(qSite.site_short_domain);
		tempPath2=application.zcore.functions.zGetDomainWritableInstallPath(qSite.site_short_domain);
		if(fileexists(tempPath2&"_cache/scripts/global.json")){
			siteStruct=deserializeJson(application.zcore.functions.zreadfile(tempPath2&"_cache/scripts/global.json"));
			siteStruct.homeDir=tempPath;
			siteStruct.secureHomeDir=tempPath;
			siteStruct.privateHomeDir=tempPath2; 
			structappend(siteStruct, application.zcore.serverGlobals, false);
		}else{
			throw("global.json is missing for site_id: #arguments.site_id#.  Please edit/save globals for this site in the server manager to correct the problem.");
		}
	}else{
		siteStruct=application.zcore.siteglobals[arguments.site_id];
	}
	return siteStruct;
	</cfscript>
</cffunction>


<cffunction name="zDeleteUniqueRewriteRule" localmode="modern" access="public">
	<cfargument name="uniqueURL" type="string" required="yes">
	<cfscript>
	if(arguments.uniqueURL NEQ ""){
		s=application.sitestruct[request.zos.globals.id];
		structdelete(s.urlRewriteStruct.uniqueURLStruct, trim(arguments.uniqueURL));
	}
	</cfscript>

</cffunction>

 <!--- application.zcore.functions.zIsForceDeleteEnabled(link) --->
<cffunction name="zIsForceDeleteEnabled" access="public" localmode="modern">
	<cfargument name="link" type="string" required="yes">
	<cfscript>
	if(arguments.link EQ ""){
		return true;
	}else if(application.zcore.user.checkServerAccess()){
		return true;
	}else if(application.zcore.user.checkGroupAccess("administrator") and application.zcore.functions.zso(request.zos.globals, 'administratorEnableForceDelete', true, 0) EQ 1){
		return true;
	}
	return false;
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zGetGoogleMapsAPIKey(); --->
<cffunction name="zGetGoogleMapsAPIKey" localmode="modern" output="no" returntype="any"> 
	<cfscript> 
	if(request.zos.globals.googleMapsApiKey NEQ ""){
		return request.zos.globals.googleMapsApiKey;
	}else if(right(request.zos.globals.domain, len(request.zos.productionTestDomain)) EQ request.zos.productionTestDomain){
		return request.zos.googleMapsApiServerKeyTestDomain; 
	}else if(right(request.zos.globals.domain, len(request.zos.testDomain)) EQ request.zos.testDomain){
		return request.zos.googleMapsApiServerKeyTestDomain;   
	}else{
		return "";
	}
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
</cfoutput>
</cfcomponent>