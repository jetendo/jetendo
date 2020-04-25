<cfcomponent>
<cfoutput>
<cffunction name="updateApplicationCFCFunctions" access="private" localmode="modern">

	<!--- <cfinclude template="/#request.zos.zcoremapping#/init/onServerStart.cfm"> --->
	<cfinclude template="/#request.zos.zcoremapping#/init/onCFCRequest.cfm">
	<cfinclude template="/#request.zos.zcoremapping#/init/onApplicationStart.cfm">
	<!--- <cfinclude template="/#request.zos.zcoremapping#/init/onApplicationEnd.cfm"> --->
	<cfinclude template="/#request.zos.zcoremapping#/init/onRequestStart.cfm">
	<cfinclude template="/#request.zos.zcoremapping#/init/onRequestEnd.cfm">
	<cfinclude template="/#request.zos.zcoremapping#/init/onError.cfm">
	<cfinclude template="/#request.zos.zcoremapping#/init/onMissingTemplate.cfm">
	<!--- don't waste memory if we don't need to --->
	<!--- <cfinclude template="/#request.zos.zcoremapping#/init/onSessionStart.cfm">
	<cfinclude template="/#request.zos.zcoremapping#/init/onSessionEnd.cfm"> --->
	<cfinclude template="/#request.zos.zcoremapping#/init/onRequest.cfm">
	<cfscript>
	tfunctions=structnew();
	//tFunctions.onServerStart=onServerStart;
	//tFunctions.onApplicationEnd=onApplicationEnd;
	//tFunctions.onSessionStart=onSessionStart;
	//tFunctions.onSessionEnd=onSessionEnd;
	tfunctions.loadDbCFC=loadDbCFC;
	tfunctions.loadSite=loadSite;
	tfunctions.getSiteId=getSiteId;
	tfunctions.setSiteRequestGlobals=setSiteRequestGlobals;
	tFunctions.showInitStatus=showInitStatus;
	tFunctions.OnInternalApplicationStart=OnInternalApplicationStart;
	tFunctions.loadNextSite=loadNextSite;
	tFunctions.OnApplicationListingStart=OnApplicationListingStart;
	tFunctions.loadNextListingSite=loadNextListingSite; 
	tFunctions.checkDomainRedirect=checkDomainRedirect; 
	tFunctions.onCustomApplicationStart=onCustomApplicationStart;
	tFunctions.onRequestStart=onRequestStart; 
	tFunctions.onRequestStart1=onRequestStart1; 
	tFunctions.onRequestStart12=onRequestStart12;
	tFunctions.onRequestStart2=onRequestStart2;
	tFunctions.onRequestStart3=onRequestStart3;
	tFunctions.onRequestStart4=onRequestStart4;
	tFunctions.unloadSitesByAccessDate=unloadSitesByAccessDate;
	tFunctions.onExecuteCacheReset=onExecuteCacheReset;
	tFunctions.onCodeDeploy=onCodeDeploy;
	tFunctions.onRequestEnd=onRequestEnd;
	tFunctions.onRequest=onRequest;
	tFunctions.onError=onError;
	tFunctions._zTempEscape=_zTempEscape;
	tFunctions._zTempErrorHandlerDump=_zTempErrorHandlerDump;
	tFunctions._handleError=_handleError;
	
	tFunctions.onMissingTemplate=onMissingTemplate;
	
	tFunctions.setupAppGlobals1=setupAppGlobals1;
	tFunctions.setupAppGlobals2=setupAppGlobals2;
	server["zcore_"&request.zos.installPath&"_functionscache"]=tFunctions;
	</cfscript>
</cffunction>

<cffunction name="onCodeDeploy" access="public" localmode="modern">
	<cfscript>
	application.codeDeployModeEnabled=true;
	zos=request.zos;
	zcore=application.zcore;
	try{
		zos.requestLogEntry('onCodeDeploy1');
		if(structkeyexists(application.zcore, 'allcomponentcache')){
			structclear(zcore.allcomponentcache);
		}
		if(structkeyexists(application.zcore, 'templateCFCCache')){
			for(i in zcore.templateCFCCache){
				structclear(zcore.templateCFCCache[i]);
			}
		}

		configCom=createobject("component", "zcorerootmapping.config-default");
		defaultStruct=configCom.getConfig(zos.cgi, true);
		structdelete(defaultStruct.zos, 'serverStruct');

		configCom=createobject("component", "zcorerootmapping.config");
		ts=configCom.getConfig(zos.cgi, false);

		structappend(ts.zos, defaultStruct.zos, false);
		structappend(request.zos, ts.zos, true);
	    


		variables.updateApplicationCFCFunctions();
		
		tempVar=createobject("component","zcorerootmapping.functionInclude");
		functions=tempVar.init();
		zos.functions=functions;
		zcore.functions=functions; 
		
		zos.requestLogEntry('onCodeDeploy2');
		
		componentObjectCache=structnew();
		componentObjectCache.cloudFile=CreateObject("component","zcorerootmapping.com.zos.cloudFile");
		componentObjectCache.context=CreateObject("component","zcorerootmapping.com.zos.context");
		componentObjectCache.cache=CreateObject("component","zcorerootmapping.com.zos.cache");
		componentObjectCache.session=CreateObject("component","zcorerootmapping.com.zos.session");
		componentObjectCache.tracking=CreateObject("component","zcorerootmapping.com.app.tracking");
		componentObjectCache.template=CreateObject("component","zcorerootmapping.com.zos.template");
		componentObjectCache.routing=CreateObject("component", "zcorerootmapping.com.zos.routing");
		componentObjectCache.debugger=CreateObject("component","zcorerootmapping.com.zos.debugger");
		componentObjectCache.user=CreateObject("component","zcorerootmapping.com.user.user");
		componentObjectCache.skin=CreateObject("component","zcorerootmapping.com.display.skin");
		componentObjectCache.status=CreateObject("component","zcorerootmapping.com.zos.status");
		componentObjectCache.email=CreateObject("component","zcorerootmapping.com.app.email");
		componentObjectCache.siteOptionCom=CreateObject("component","zcorerootmapping.com.app.site-option");
		componentObjectCache.imageLibraryCom=CreateObject("component","zcorerootmapping.com.app.image-library");
		componentObjectCache.hook=CreateObject("component","zcorerootmapping.com.zos.hook");
		componentObjectCache.app=CreateObject("component","zcorerootmapping.com.zos.app");
		componentObjectCache.db=createobject("component","zcorerootmapping.com.model.db");
		componentObjectCache.paypal=createobject("component","zcorerootmapping.com.ecommerce.paypal");
		componentObjectCache.adminSecurityFilter=createobject("component","zcorerootmapping.com.app.adminSecurityFilter");
		componentObjectCache.grid=createobject("component","zcorerootmapping.com.grid.grid");
		componentObjectCache.virtualFile=createobject("component","zcorerootmapping.com.zos.virtualFile");
		componentObjectCache.featureCom=CreateObject("component","zcorerootmapping.mvc.z.feature.feature");

		componentObjectCache.siteOptionCom.init("site", "site");
 
 		zcore.cloudVendor=componentObjectCache.cloudFile.getCloudVendors();

		if(zos.isdeveloper and structkeyexists(request.zsession, 'verifyQueries') and request.zsession.verifyQueries){
			local.verifyQueriesEnabled=true;
		}else{
			local.verifyQueriesEnabled=false;
		}
		dbInitConfigStruct={
			insertIdSQL:"select last_insert_id() id",
			datasource:zos.globals.serverdatasource,
			parseSQLFunctionStruct:{checkSiteId:functions.zVerifySiteIdsInDBCFCQuery},
			verifyQueriesEnabled:local.verifyQueriesEnabled,
			cacheStructKey:'zcore.queryCache'
		}
		componentObjectCache.db.init(dbInitConfigStruct);
		
		zcore.componentObjectCache=componentObjectCache;
		structappend(application.zcore, zcore.componentObjectCache);
		zcore.featureData.fieldTypeStruct=componentObjectCache.featureCom.getFieldTypes();
		zcore.featureData.arrCustomDelete=componentObjectCache.featureCom.getTypeCustomDeleteArray(zcore.featureData);
		
		soGroupData={
			optionTypeStruct:componentObjectCache.siteOptionCom.getOptionTypes()
		};
		soGroupData.arrCustomDelete=componentObjectCache.siteOptionCom.getTypeCustomDeleteArray(soGroupData);
		zcore.soGroupData=soGroupData;
		// themeTypeData={
		// 	optionTypeStruct:{}
		// };
		// zcore.themeTypeData=themeTypeData;
		// widgetTypeData={
		// 	optionTypeStruct:{}
		// };
		// zcore.widgetTypeData=widgetTypeData;
		if(zos.allowRequestCFC){
			structappend(request.zos, zcore.componentObjectCache, true);
		}
		
		zos.requestLogEntry('onCodeDeploy3');
		
		
		zcore.skin.onCodeDeploy();//zcore.skinObj);
		zos.requestLogEntry('onCodeDeploy4');
		zcore.listingCom=createobject("component","zcorerootmapping.mvc.z.listing.controller.listing");
		zcore.listingStruct.configCom=zcore.listingCom;
		// loop all app CFCs
		for(i in zcore.appComPathStruct){
			currentCom=createobject("component", zcore.appComPathStruct[i].cfcPath);
			if(structkeyexists(currentCom, 'onCodeDeploy')){
				currentCom.onCodeDeploy(application.zcore);
			}
		}
		zos.requestLogEntry('onCodeDeploy5');
		

		zos.functions.zUpdateGlobalMVCData(application.zcore, true);
		
		backupStruct={
			zRootPath:request.zRootPath,
			zRootDomain:request.zRootDomain,
			zRootCFCPath:request.zRootCFCPath,
			zRootSecureCfcPath:request.zRootSecureCfcPath, 
		};
		// loop all sitestruct
		threadStruct={
			siteCodeDeployThread0:[],
			siteCodeDeployThread1:[],
			siteCodeDeployThread2:[],
			siteCodeDeployThread3:[]
		};

		reloadEnabled=false;
		if(request.zos.customCFMLVersion EQ server.lucee.version){
			reloadEnabled=true;
		}

		for(n in application.siteStruct){
			ss=application.siteStruct[n];
			ss.comCache={};
			ss.fileExistsCache={};
			if(not structkeyexists(ss, 'globals')){
				continue;
			}
			request.zRootDomain=replace(replace(ss.globals.shortDomain,'www.',''),"."&zos.testDomain,"");
			request.zRootPath="/"&replace(request.zRootDomain, ".","_","all")&"/"; 
			request.zRootSecureCfcPath="jetendo-sites.writable."&replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";
			request.zRootCfcPath=replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";

			functions.zUpdateSiteMVCData(ss);
			if(structkeyexists(ss, 'app')){
				for(i in ss.app.appCache){
					currentCache=ss.app.appCache[i];
					if(reloadEnabled and structkeyexists(currentCache, 'cfcCached')){ 
						currentCom=reloadComponent(currentCache.cfcCached, true);
					}else{ 
						currentCom=createObject("component", zcore.appComPathStruct[i].cfcPath);
					}
					if(i NEQ 11 and i NEQ 13){ // rental and listing apps are not thread-safe yet due to cfinclude (listing detail includes) and var scoping
						currentCache.cfcCached=currentCom;
					}
					currentCom.site_id=zos.globals.id;
					if(structkeyexists(currentCom, 'onSiteCodeDeploy')){
						currentCom.onSiteCodeDeploy(currentCache);
					}
				}	
			}
			ss.dbComponents=functions.getSiteDBObjects(ss.globals);
			ts={site_id:n, globals:ss.globals};
			functions.zUpdateCustomSiteFunctions(ts);
			structappend(ss, ts, true);
					
		}

		structappend(request, backupStruct, true);
		zos.requestLogEntry('onCodeDeploy6');

		versionCom=createobject("component", "zcorerootmapping.version");
	    ts2=versionCom.getVersion();

		zos.requestLogEntry('onCodeDeploy7');
		runDatabaseUpgrade=false;
	    if(not structkeyexists(zcore, 'databaseVersion') or zcore.databaseVersion NEQ ts2.databaseVersion){
	    	// do database upgrade
	    	runDatabaseUpgrade=true;
		}else{
			db=zos.queryObject;
			db.sql="select * from #db.table("jetendo_setup", zos.zcoreDatasource)# 
			WHERE jetendo_setup_deleted = #db.param(0)# 
			LIMIT #db.param(0)#, #db.param(1)#";
			qSetup=db.execute("qSetup");
		}
	    zcore.databaseVersion=ts2.databaseVersion;
	    zcore.sourceVersion=ts2.sourceVersion;
		if(runDatabaseUpgrade or qSetup.recordcount EQ 0 or qSetup.jetendo_setup_database_version NEQ zcore.databaseVersion){
			dbUpgradeCom=createobject("component", "zcorerootmapping.mvc.z.server-manager.admin.controller.db-upgrade");
			if(not dbUpgradeCom.checkVersion()){
				if(zos.isTestServer or zos.isDeveloper){
					echo('Database upgrade failed');
					abort;
				}
			}
		}
	}catch(Any e){
		structdelete(application, 'codeDeployModeEnabled');
		rethrow;
	}
	structdelete(application, 'codeDeployModeEnabled'); 
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>