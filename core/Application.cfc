<cfcomponent displayname="Application" output="no" hint="Handle the application.">  
<cfscript>
// config.cfc has all the configurable options.
// DO NOT EDIT Application.cfc unless you are going to change the behavior of the Jetendo Core.


// BEGIN override cfml admin settings
// regional
// default locale used for formating dates, numbers ...
this.sessionStorage = "memory";

// client scope enabled or not
this.clientManagement = false; 
this.clientTimeout = createTimeSpan( 1, 0, 0, 0 );
this.clientStorage = "cookie";

// using domain cookies or not
this.setDomainCookies = false; 
this.setClientCookies = false; 

// disable sessions and cookies when using ab.exe benchmarking to prevent timeouts of this failed request type: length
if(cgi.user_agent CONTAINS "apachebench"){
	form.zab=1;
}
if(structkeyexists(form,'zab')){
    this.SessionManagement = false;
    this.setDomainCookies = false; 
    this.setClientCookies = false;
}

// prefer the local scope at unscoped write
this.localMode = "classic"; 

// buffer the output of a tag/function body to output in case of a exception
this.bufferOutput = true; 
this.compression = false;
this.suppressRemoteComponentContent = false;

// If set to false cfml ignores type defintions with function arguments and return values
this.typeChecking = true;
// request
// max lifespan of a running request
this.requestTimeout=createTimeSpan(0,0,0,25); 

// charset
this.charset.web="UTF-8";
this.charset.resource="UTF-8";

this.scopeCascading = "standard";


// END override cfml admin settings

</cfscript>

<cffunction name="requestLogEntry" localmode="modern" output="no">
	<cfargument name="message" type="string" required="yes">
	<cfscript>
	time=gettickcount('nano');
	arrayappend(request.zos.arrRunTime, {time:time, name:arguments.message});
	if(not structkeyexists(request, 'lastTickCount')){
		request.lastTickCount=request.zos.startTime;
	}
	timeOut=((time-request.lastTickCount)/1000000000)&' seconds';
	request.lastTickCount=time;
	</cfscript>
	<cfif not structkeyexists(application, 'zcoreIsInit')>
		<cffile action="append" file="#request.zos.zcoreRootCachePath#jetendo-start-log.txt" output="#dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "h:mm tt")# | #timeOut# | #arguments.message#" addNewLine="true" charset="utf-8" mode="770">
	</cfif>
</cffunction> 

<cffunction name="setupGlobals" localmode="modern" output="no">
	<cfargument name="tempCGI" type="struct" required="yes">
	<cfscript>

	configCom=createobject("component", "zcorerootmapping.config-default");
	defaultStruct=configCom.getConfig(arguments.tempCGI, true);
	structdelete(defaultStruct.zos, 'serverStruct');

	configCom=createobject("component", "zcorerootmapping.config");
	ts=configCom.getConfig(arguments.tempCGI, false);
	if(not structkeyexists(ts.zos, 'enableSiteOptionGroupCache')){
        ts.zos.enableSiteOptionGroupCache=true;
    }
    if(not structkeyexists(ts.zos,'enableSiteTemplateCache')){
    	ts.zos.enableSiteTemplateCache=true;
    }
	if(structkeyexists(ts, 'timezone')){
		this.timezone=ts.timezone;
	}
	if(structkeyexists(ts, 'locale')){
		this.locale=ts.locale;
	}
	structappend(ts, defaultStruct, false);
	structappend(ts.zos, defaultStruct.zos, false);
    ts.zos.databaseVersion=1; // increment manually when database structure changes

	ts.zos.isServer=false;
	ts.zos.isDeveloper=false;

	// mail server options are here only for legacy sites at the moment
	ts.zmailserver="mailserver";
	ts.zmailserverusername="username";
	ts.zmailserverpassword="password";
	ts.httpCompressionType="deflate;q=0.5";
	ts.inMemberArea=false;
	
	ts.searchServerCollectionName="entiresite_verity";
	ts.zos.disableSystemCaching=false;
	ts.zos.trackingspider=false;
	ts.zos.arrScriptInclude=arraynew(1);
	ts.zos.jsIncludeUniqueStruct={};
	ts.zos.cssIncludeUniqueStruct={};
	ts.zos.arrScriptIncludeLevel=arraynew(1);
	ts.zos.newMetaTags=false;
	ts.zos.arrQueryQueue=arraynew(1);
	ts.zos.queryQueueThreadIndex=1;
	ts.zos.includePackageStruct=structnew();
	ts.zos.arrJSIncludes=arraynew(1);
	ts.zos.arrCSSIncludes=arraynew(1);
	ts.zos.tempObj=structnew();
	ts.zos.tableFieldsCache=structnew();
	ts.zos.arrQueryLog=arraynew(1);
	ts.zos.tempRequestCom=structnew();
	ts.zos.importMlsStruct={};
	ts.zos.widgetInstanceOffset=0;
	ts.zos.widgetInstanceLoadCache={};
	
	structappend(request, duplicate(ts));
    structappend(this, configCom.getDatasources(arguments.tempCGI));
	</cfscript>
</cffunction>
	 
<cfscript>
local.tempCGI=duplicate(CGI);
requestData=getHTTPRequestData();

if(structkeyexists(requestData.headers,'x-forwarded-for')){
	if(requestData.headers["x-forwarded-for"] CONTAINS ","){
		local.tempCGI.remote_addr=listGetAt(requestData.headers["x-forwarded-for"], 1, ",");
	}else{
		local.tempCGI.remote_addr=requestData.headers["x-forwarded-for"];
	}
}else if(structkeyexists(requestData.headers,'remote_addr')){
	local.tempCGI.remote_addr=requestData.headers.remote_addr;
}
if(structkeyexists(requestData.headers,'http_host')){
	local.tempCGI.http_host=requestData.headers.http_host;
}
setupGlobals(local.tempCGI);
request.zos.requestLogEntry=requestLogEntry;
request.zos.requestData=requestData;
request.zos.cgi=local.tempCGI;
</cfscript>

<cffunction name="onCoreRequest" localmode="modern" returntype="any" output="no">
    <cfscript>
    var local=structnew();
	request.zos.arrRunTime=arraynew(1);
    request.zos.startTime=gettickcount('nano');
	request.zos.isDeveloperIpMatch=false;
    if(structkeyexists(request.zos.adminIpStruct,request.zos.cgi.remote_addr)){
		request.zos.isDeveloperIpMatch=true;
        if(request.zos.adminIpStruct[request.zos.cgi.remote_addr] EQ false){
			if(request.zos.isTestServer){
				request.zos.isDeveloper=true;
				request.zos.isDeveloperIpMatch=true;
			}else{
				if(structkeyexists(cookie, 'zdeveloper') and cookie.zdeveloper EQ 1){
					request.zos.isDeveloper=true;
				}else{
					request.zos.isDeveloper=false;  
				}
			}
			request.zos.isServer=false;
        }else{
            request.zos.isDeveloper=false;
            request.zos.isServer=true;	
        } 
    }
	if(request.zos.isTestServer and request.zos.cgi.HTTP_USER_AGENT CONTAINS 'Mozilla/' and request.zos.cgi.HTTP_USER_AGENT DOES NOT CONTAIN 'Jetendo'){
        request.zos.isDeveloper=true;
        request.zos.isServer=false;	
	} 
    structappend(form, url, false);
    if(structkeyexists(form,'zreset') EQ false){
        request.zos.zreset="";
    }else{
        request.zos.zreset=form.zreset;
    }
    </cfscript>
    <cfif structkeyexists(form,'zab')>
        <!--- force a quick timeout for load testing benchmarking --->
        <cfsetting requesttimeout="10">
    </cfif>
    <!--- 
    disable abusive blocks until i'm sure it doesn't block important users.
    <cfif isDefined('server.#request.zos.zcoremapping#.abusiveBlockedIpStruct') and structkeyexists(server[request.zos.zcoremapping].abusiveBlockedIpStruct, request.zos.cgi.remote_addr)>
        <cfheader statuscode="403" statustext="Forbidden"><cfabort>
    </cfif> --->
            
    <cfscript>
    zreset=request.zos.zreset;
    </cfscript>
    <cfif structkeyexists(server, "zcore_"&request.zos.installPath&"_functionscache") EQ false or zreset EQ "code" or zreset EQ 'app' or zreset EQ 'all'>
		<cfinclude template="/#request.zos.zcoremapping#/init/onCFCRequest.cfm">
		<cfinclude template="/#request.zos.zcoremapping#/init/onApplicationStart.cfm">
		<cfinclude template="/#request.zos.zcoremapping#/init/onRequestStart.cfm">
		<cfinclude template="/#request.zos.zcoremapping#/init/onRequestEnd.cfm">
		<cfinclude template="/#request.zos.zcoremapping#/init/onError.cfm">
		<cfinclude template="/#request.zos.zcoremapping#/init/onMissingTemplate.cfm">
		<cfinclude template="/#request.zos.zcoremapping#/init/onRequest.cfm">
		<cfscript>
		local.tfunctions=structnew();
		local.tfunctions.loadDbCFC=loadDbCFC;
		local.tfunctions.loadSite=loadSite;
		local.tfunctions.getSiteId=getSiteId;
		local.tfunctions.setSiteRequestGlobals=setSiteRequestGlobals;
		local.tFunctions.showInitStatus=showInitStatus;
		local.tFunctions.OnInternalApplicationStart=OnInternalApplicationStart;
		local.tFunctions.loadNextSite=loadNextSite;
		local.tFunctions.OnApplicationListingStart=OnApplicationListingStart;
		local.tFunctions.loadNextListingSite=loadNextListingSite; 
		local.tFunctions.checkDomainRedirect=checkDomainRedirect; 
		local.tFunctions.onApplicationStart=onApplicationStart;
		local.tFunctions.onApplicationStart=onApplicationStart;
		local.tFunctions.onExecuteCacheReset=onExecuteCacheReset;
		local.tFunctions.onRequestStart=onRequestStart;
		local.tFunctions.onRequestStart1=onRequestStart1;
		local.tFunctions.onRequestStart12=onRequestStart12;
		local.tFunctions.onRequestStart2=onRequestStart2;
		local.tFunctions.onRequestStart3=onRequestStart3;
		local.tFunctions.onRequestStart4=onRequestStart4;
		local.tFunctions.onCodeDeploy=onCodeDeploy;
		local.tFunctions.onRequestEnd=onRequestEnd;
		local.tFunctions.onRequest=onRequest;
		local.tFunctions.onError=onError;
		local.tFunctions._zTempEscape=_zTempEscape;
		local.tFunctions._zTempErrorHandlerDump=_zTempErrorHandlerDump;
		local.tFunctions._handleError=_handleError;
		
		local.tFunctions.onMissingTemplate=onMissingTemplate;
		
		local.tFunctions.setupAppGlobals1=setupAppGlobals1;
		local.tFunctions.setupAppGlobals2=setupAppGlobals2;
		server["zcore_"&request.zos.installPath&"_functionscache"]=local.tFunctions; 
		</cfscript>
			
    <cfelse>
        <cfscript>
        structappend(variables,server["zcore_"&request.zos.installPath&"_functionscache"],true); 
        </cfscript>
    </cfif>
    <cfscript>
    if(structkeyexists(form,request.zos.urlRoutingParameter)){
        form[request.zos.urlRoutingParameter]=listtoarray(form[request.zos.urlRoutingParameter],",", true);
        form[request.zos.urlRoutingParameter]=form[request.zos.urlRoutingParameter][1];
		request.zos.originalURL=form[request.zos.urlRoutingParameter];
        this.SessionManagement = false;
		/*if(request.zos.isTestServer){
        }else{
        	this.SessionManagement = true;
        }*/
    }else{
        this.Name = request.zos.cgi.http_host;
        this.ApplicationTimeout = CreateTimeSpan( 30, 0, 0, 0 );
        this.SessionTimeout=CreateTimeSpan(0,0,20,0); 
        this.SessionManagement = true;
        return;
    }
    
       
        
    if(request.zos.cgi.http_host CONTAINS ":"){
        request.zos.cgi.http_host=listgetat(request.zos.cgi.http_host,1,":");
    }
    request.zos.currentHostName=request.zos.cgi.http_host;
    if(structkeyexists(cgi, 'server_port_secure') and cgi.server_port_secure EQ 1){
        request.zos.cgi.server_port="443";
    }
    local.zOSTempVar=replace(replacenocase(replacenocase(request.zos.cgi.http_host,'www.',''),'.'&request.zos.testDomain,''),".","_","all");
    Request.zOSHomeDir = request.zos.sitesPath&local.zOSTempVar&"/";
    Request.zOSPrivateHomeDir = request.zos.sitesWritablePath&local.zOSTempVar&"/";
    
    setEncoding("form","UTF-8");
    setEncoding("url","UTF-8");

    request.zRootDomain=replace(replace(lcase(request.zOS.CGI.http_host),"www.",""),"."&request.zos.testDomain,"");
    request.zCookieDomain=replace(lcase(request.zOS.CGI.http_host),"www.","");
    request.zRootPath="/"&replace(request.zRootDomain,".","_","all")&"/"; 
    request.zRootSecureCfcPath="jetendo-sites-writable."&replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";
    request.zRootCfcPath=replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&"."; 
    request.cgi_script_name=replacenocase(cgi.script_name,request.zRootPath,"/");  
    for(local.i in form){
        if(isSimpleValue(form[local.i])){
            form[local.i]=trim(form[local.i]);  
        }
    }
    request.zos.lastTime=request.zos.startTime;
    request.zOS.now=now();
    Request.zOS.modes.time.begin = request.zos.startTime;
    request.zOS.mysqlnow=DateFormat(request.zos.now,'yyyy-mm-dd')&' '&TimeFormat(request.zos.now,'HH:mm:ss');
     
	request.zos.queryCount=0;
	request.zos.queryRowCount=0; 
    variables.getApplicationConfig(); 
    </cfscript>
</cffunction>
        
<cffunction name="getApplicationConfig" localmode="modern" output="no">
    <cfscript>
    var ts=structnew();
    var local=structnew();
    if(structkeyexists(server, "zcore_"&request.zos.installPath&"_cache") and request.zos.zreset NEQ 'app' and request.zos.zreset NEQ 'all'){
        structappend(this, server["zcore_"&request.zos.installPath&"_cache"], true);
        return;
    }

    // lookup the app name.
    ts.Name = "zcore_"&request.zos.installPath;
    ts.ApplicationTimeout = CreateTimeSpan( 30, 0, 0, 0 );
    ts.SessionTimeout=CreateTimeSpan(0,0,request.zos.sessionExpirationInMinutes,0); 
	
    server["zcore_"&request.zos.installPath&"_cache"]=ts;
    structappend(this, ts, true);
	
    </cfscript>
</cffunction> 
<cfscript> 
this.onCoreRequest(); 
</cfscript>
	
<cffunction name="onAbort" localmode="modern" access="public" output="yes">
	<cfargument name="template" type="string" required="yes" />
	<cfscript>
	if(isdefined('application.zcore.functions.zabort') and structkeyexists(request.zos, 'globals')){
		application.zcore.functions.zabort();
	}
	</cfscript>
</cffunction>
</cfcomponent>
