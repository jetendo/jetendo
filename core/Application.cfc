<!--- <cfcomponent displayname="Application" hint="Handle the application.">
<cfscript>
	echo('<style>body{background-color:##000; color:##FFFFFF;}</style>');
 //  var n2="test"; 
 // echo(n2&"<br>");  

 maGIC="true";
 echo("eye"&getString2(maGIC));
//  local.iAmLocal2=3;
//  var iAmLocal="cool";   
//  local.isneat=true;      
// echo(local.iAmLocal); 
// echo(local.iAmLocal2); 
// // echo(local.iAmLocal);
//  echo(isneat);
 // echo(isneat);
//    jetendo.myVar=10;
// for (jetendo.memberDoubleStatic = 1; jetendo.memberDoubleStatic <= jetendo.myVar; jetendo.addOneMemberDouble()) {
// 	echo("neat:"&jetendo.memberDoubleStatic);
// }    
//    jetendo.myVar="1";
//    jetendo.myVar=[true];

//    writedump(jetendo.myVar);

//    jetendo.myVar=JavaCast("Object", 1);
//    jetendo.myVar=JavaCast("Object", "1");
//    jetendo.myVar=JavaCast("Object", [true]);

//    writedump(jetendo.myVar);
//    jetendo.myVar=JavaCast("Object", {cool:true});
//    writedump(jetendo.myVar);
//    jetendo.myVar= [true];
//    jetendo.myVar= [true, false];
//    writedump(jetendo.myvar);
//    abort;

//   echo("test"); 
// jetendo.cacheFunction=jetendo.getFunction(this, getString2);
// jetendo.result2=getString2();
// jetendo.result=jetendo.runFunction(jetendo.cacheFunction, jetendo.result2);

// echo(jetendo.result); 
// request.test=1;   
// echo(request.test);
// echo(cookie._ga);
// echo(cgi.http_host); 
    
// jetendo.struct={test:{test2:true}};
// jetendo.struct.test.test2=false; 
// writedump(jetendo.struct);
// abort; 

// jetendo.newDouble10="newDouble cool";   
// jetendo.newDouble11=5;  
// jetendo.reloadComponents();  
// n3=jetendo.getString();   
  
// echo(n3&jetendo.newDouble10&" : "&jetendo.newDouble11&"test"); 

// //echo(n3&jetendo.newDouble10&jetendo.newDouble11&requestLogEntry2(" fine ")&" literal "&jetendo.newDouble10&jetendo.getJavaString()&jetendo.getString());  


// server.jetCom=createobject("component", "jet");
// jetendo.cacheFunction2=jetendo.getFunction(server.jetCom, getString2);


// 	jetendo.limitCount=1000;
// 	stime = getTickCount('nano');
// 	limitCount=1000;
// 	for (g = 1; g <=3; g++) {
			 
// 		// stime = getTickCount('nano');  
// 		// varString="a much longer string a much longer string a much longer string a much longer string a much longer string a much longer string ";
// 		// for (i = 1; i <= limitCount; i++) {
// 		// 	a=varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString&varString;
// 		// } 
// 		// echo("<br>" & ((getTickCount('nano') - stime) / 1000000) & "ms for lucee variable string concat<br>");
			 
// 		// stime = getTickCount('nano'); 
// 		// jetendo.varString="a much longer string a much longer string a much longer string a much longer string a much longer string a much longer string ";
// 		// for (jetendo.i = 1; jetendo.i <= jetendo.limitCount; jetendo.i=jetendo.i+1) {
// 		// 	a=jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString&jetendo.varString;
// 		// } 
// 		// echo("<br>" & ((getTickCount('nano') - stime) / 1000000) & "ms for lucee java local variable string concat<br>");

// 		stime = getTickCount('nano'); 
// 		for (jetendo.i = 1; jetendo.i <= jetendo.limitCount; jetendo.i=jetendo.i+1) {
// 			jetendo.runFunction(jetendo.cacheFunction, jetendo.result2);
// 		} 
// 		echo("<br>" & ((getTickCount('nano') - stime) / 1000000) & "ms for java runFunction<br>");
// 		stime = getTickCount('nano'); 
// 		for (jetendo.i = 1; jetendo.i <= jetendo.limitCount; jetendo.i=jetendo.i+1) {
// 			server.jetCom.getString2(jetendo.result2);
// 		} 
// 		echo("<br>" & ((getTickCount('nano') - stime) / 1000000) & "ms for lucee external runFunction<br>");
// 		jetendo.jetCom=server.jetCom;
// 		stime = getTickCount('nano'); 
// 		for (jetendo.i = 1; jetendo.i <= jetendo.limitCount; jetendo.i=jetendo.i+1) {
// 			jetendo.jetCom.getString2(jetendo.result2);
// 		} 
// 		echo("<br>" & ((getTickCount('nano') - stime) / 1000000) & "ms for java local external runFunction<br>");

// 		stime = getTickCount('nano'); 
// 		for (jetendo.i = 1; jetendo.i <= jetendo.limitCount; jetendo.i=jetendo.i+1) {
// 			jetendo.runFunction(jetendo.cacheFunction2, jetendo.result2);
// 		} 
// 		echo("<br>" & ((getTickCount('nano') - stime) / 1000000) & "ms for java external runFunction<br>");

// 		stime = getTickCount('nano'); 
// 		for (jetendo.i = 1; jetendo.i <= jetendo.limitCount; jetendo.i=jetendo.i+1) {
// 			getString2(jetendo.result2);
// 		} 
// 		echo("<br>" & ((getTickCount('nano') - stime) / 1000000) & "ms for lucee runFunction<br>");

			 
// 	}  

// abort;

// OpString, LitStringImpl, CastString
//  jetendo.memberString="cool";   
//  // storeLocal     
//  jetendo.newMemberString="cooler"; 
//  echo(jetendo.memberString&"<br>");
//  // have to do this as loadLocal when reflection fails
//  echo(jetendo.newMemberString&"<br>"); 
//  // echo(newMemberString&"<br>");
//  jetendo.newMemberStruct={test:"cooler"};  
// echo(jetendo.newMemberStruct.test&"<br>");
//  // jetendo.newMemberStruct={sameButNot:"cooler2"}; 
// // echo(newMemberStruct.test&"<br>");
// // echo(newMemberStruct.sameButNot&"<br>");
//  jetendo.newMemberStruct=false; 
// echo(jetendo.newMemberStruct&"<br>"); 
// request.newStruct={newOne:3};
// newStruct2=request.newStruct;
// echo(newStruct2.newOne);
// jetendo.mylocal="sweet";
// jetendo.resultIs=requestLogEntry2("test"); 
// echo(jetendo.resultIs);
// jetendo.resultIs2=requestLogEntry2(jetendo.mylocal);
// echo(jetendo.resultIs2);
 // abort; 
</cfscript>    
<cffunction name="getString2">
	<cfargument name="magic" type="String" required="yes"> 
	<cfscript>
	return "t2"&arguments.magic;
	</cfscript>
</cffunction> 
</cfcomponent> --->
<cfcomponent displayname="Application" output="no" hint="Handle the application."><cfscript>
// BEGIN override cfml admin settings
// regional
if(structkeyexists(form, 'firstlineabort')){
	echo(1);//echo(replace(jetendo.showLuceeStartTime(), chr(10), "<br>", "all"));
	//echo(1);
	abort;
}
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



if(cgi.http_user_agent CONTAINS "SemrushBot" or cgi.http_user_agent CONTAINS "AhrefsBot" or cgi.http_user_agent CONTAINS "MJ12bot"){
	header statuscode="404" statustext="Page not found";
	abort;
}
// END override cfml admin settings
 
tempCGI=duplicate(CGI);
requestData=getHTTPRequestData();

if(structkeyexists(requestData.headers,'x-forwarded-for')){
	if(requestData.headers["x-forwarded-for"] CONTAINS ","){
		tempCGI.remote_addr=listGetAt(requestData.headers["x-forwarded-for"], 1, ",");
	}else{
		tempCGI.remote_addr=requestData.headers["x-forwarded-for"];
	}
}else if(structkeyexists(requestData.headers,'remote_addr')){
	tempCGI.remote_addr=requestData.headers.remote_addr;
}
if(structkeyexists(requestData.headers,'http_host')){
	tempCGI.http_host=requestData.headers.http_host;
} 
setupGlobals(tempCGI);
request.zos.requestLogEntry=requestLogEntry;
request.zos.requestData=requestData;
request.zos.cgi=tempCGI; 
this.onCoreRequest(); 
</cfscript>

<cffunction name="requestLogEntry" localmode="modern" output="no">
	<cfargument name="message" type="string" required="yes">
	<cfscript>
	time=gettickcount('nano');
	zos=request.zos;
	arrayappend(zos.arrRunTime, {time:time, name:arguments.message});
	if(not structkeyexists(request, 'lastTickCount')){
		request.lastTickCount=zos.startTime;
	}
	timeOut=((time-request.lastTickCount)/1000000000)&' seconds';
	request.lastTickCount=time;
	</cfscript>
	<cfif not structkeyexists(application, 'zcoreIsInit')>
		<cffile action="append" file="#zos.zcoreRootCachePath#jetendo-start-log.txt" output="#dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "h:mm tt")# | #timeOut# | #arguments.message#" addNewLine="true" charset="utf-8" mode="770">
	</cfif>
</cffunction> 

<cffunction name="setupGlobals" localmode="modern" output="yes">
	<cfargument name="tempCGI" type="struct" required="yes">
	<cfscript> 
	if(structkeyexists(server, "zcore_configCacheStruct") and not structkeyexists(form, 'zreset')){
		ts=server["zcore_configCacheStruct"];
		ds=server["zcore_configCacheDatasourceStruct"];
	}else{ 
		if(not structkeyexists(server, "zcore_configcache") or structkeyexists(form, 'zreset')){ 
			server["zcore_configcache"]={
				defaultConfigCom:createobject("component", "zcorerootmapping.config-default"),
				configCom:createobject("component", "zcorerootmapping.config")
			}
		} 
		configCache=server["zcore_configcache"];
		defaultStruct=configCache.defaultConfigCom.getConfig(arguments.tempCGI, true);
		structdelete(defaultStruct.zos, 'serverStruct');

		ts=configCache.configCom.getConfig(arguments.tempCGI, false);
		if(not structkeyexists(ts.zos, 'enableSiteOptionGroupCache')){
	        ts.zos.enableSiteOptionGroupCache=true;
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
		 
		ts.zos.httpCompressionType="deflate;q=0.5";  
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
		// new ones
		ts.zos.deployResetEnabled=false;
		ts.zos.debuggerEnabled = true;
		ts.zos.autoresponderImagePath="/zupload/autoresponder/";
		ts.zos.memberImagePath="/zupload/member/";
		
		ds=configCache.configCom.getDatasources(ts.zos.isTestServer);
		server["zcore_configCacheDatasourceStruct"]=ds;
		server["zcore_configCacheStruct"]=ts;
	}
	structappend(request, duplicate(ts, true));
    if(not structkeyexists(request.zos,'enableSiteTemplateCache') or structkeyexists(form, 'luceedebug') or cgi.http_user_agent CONTAINS "ApacheBench"){
    	request.zos.enableSiteTemplateCache=true;
    }
    structappend(this, ds);
	</cfscript>
</cffunction>

<cffunction name="onCoreRequest" localmode="modern" returntype="any" output="yes">
    <cfscript> 
    zos=request.zos;
    zcgi=zos.cgi;
	zos.arrRunTime=arraynew(1);
    zos.startTime=gettickcount('nano');
	zos.isDeveloperIpMatch=false;
    if(structkeyexists(zos.adminIpStruct,zcgi.remote_addr)){
		zos.isDeveloperIpMatch=true;
        if(zos.adminIpStruct[zcgi.remote_addr] EQ false){
			if(zos.isTestServer){
				zos.isDeveloper=true;
				zos.isDeveloperIpMatch=true;
			}else{
				if(structkeyexists(cookie, 'zdeveloper') and cookie.zdeveloper EQ 1){
					zos.isDeveloper=true;
				}else{
					zos.isDeveloper=false;  
				}
			}
			zos.isServer=false;
        }else{
            zos.isDeveloper=false;
            zos.isServer=true;	
        } 
    }
	if(zos.isTestServer and zcgi.HTTP_USER_AGENT CONTAINS 'Mozilla/' and zcgi.HTTP_USER_AGENT DOES NOT CONTAIN 'Jetendo'){
        zos.isDeveloper=true;
        zos.isServer=false;	
	} 
    structappend(form, url, false);
    if(structkeyexists(form,'zreset') EQ false){
        zos.zreset="";
    }else{
        zos.zreset=form.zreset;
    }
    </cfscript>
    <cfif structkeyexists(form,'zab')>
        <!--- force a quick timeout for load testing benchmarking --->
        <cfsetting requesttimeout="10">
    </cfif>
    <!--- 
    disable abusive blocks until i'm sure it doesn't block important users.
    <cfif isDefined('server.#zos.zcoremapping#.abusiveBlockedIpStruct') and structkeyexists(server[zos.zcoremapping].abusiveBlockedIpStruct, zcgi.remote_addr)>
        <cfheader statuscode="403" statustext="Forbidden"><cfabort>
    </cfif> --->
            
    <cfscript>
    zreset=zos.zreset;
    </cfscript>
    <cfif structkeyexists(server, "zcore_"&zos.installPath&"_functionscache") EQ false or zreset EQ "code" or zreset EQ 'app' or zreset EQ 'all'>
		<cfinclude template="/#zos.zcoremapping#/init/onCFCRequest.cfm">
		<cfinclude template="/#zos.zcoremapping#/init/onApplicationStart.cfm">
		<cfinclude template="/#zos.zcoremapping#/init/onRequestStart.cfm">
		<cfinclude template="/#zos.zcoremapping#/init/onRequestEnd.cfm">
		<cfinclude template="/#zos.zcoremapping#/init/onError.cfm">
		<cfinclude template="/#zos.zcoremapping#/init/onMissingTemplate.cfm">
		<cfinclude template="/#zos.zcoremapping#/init/onRequest.cfm">
		<cfscript>
		tfunctions=structnew();
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
		tFunctions.onApplicationStart=onApplicationStart;
		tFunctions.onApplicationStart=onApplicationStart;
		tFunctions.onExecuteCacheReset=onExecuteCacheReset;
		tFunctions.onRequestStart=onRequestStart; 
		tFunctions.onRequestStart1=onRequestStart1; 
		tFunctions.onRequestStart12=onRequestStart12;
		tFunctions.onRequestStart2=onRequestStart2;
		tFunctions.onRequestStart3=onRequestStart3;
		tFunctions.onRequestStart4=onRequestStart4;
		tFunctions.unloadSitesByAccessDate=unloadSitesByAccessDate;
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
		server["zcore_"&zos.installPath&"_functionscache"]=tFunctions; 
		</cfscript>
			
    <cfelse>
        <cfscript>
        structappend(variables,server["zcore_"&zos.installPath&"_functionscache"],true); 
        </cfscript>
    </cfif>
    <cfscript>
    if(structkeyexists(form,zos.urlRoutingParameter)){
        form[zos.urlRoutingParameter]=listtoarray(form[zos.urlRoutingParameter],",", true);
        form[zos.urlRoutingParameter]=form[zos.urlRoutingParameter][1];
		zos.originalURL=form[zos.urlRoutingParameter];
        this.SessionManagement = false;
		/*if(zos.isTestServer){
        }else{
        	this.SessionManagement = true;
        }*/
    }else{
        this.Name = zcgi.http_host;
        this.ApplicationTimeout = CreateTimeSpan( 30, 0, 0, 0 );
        this.SessionTimeout=CreateTimeSpan(0,0,30,0); 
        this.SessionManagement = true;
        return;
    }
    
       
        
    if(zcgi.http_host CONTAINS ":"){
        zcgi.http_host=listgetat(zcgi.http_host,1,":");
    }
    zos.currentHostName=zcgi.http_host;
    if(structkeyexists(cgi, 'server_port_secure') and cgi.server_port_secure EQ 1){
        zcgi.server_port="443";
    }
    zOSTempVar=replace(replacenocase(replacenocase(zcgi.http_host,'www.',''),'.'&zos.testDomain,''),".","_","all");
    Request.zOSHomeDir = zos.sitesPath&zOSTempVar&"/";
    Request.zOSPrivateHomeDir = zos.sitesWritablePath&zOSTempVar&"/";
    
    setEncoding("form","UTF-8");
    setEncoding("url","UTF-8");

    request.zRootDomain=replace(replace(lcase(zcgi.http_host),"www.",""),"."&zos.testDomain,"");
    request.zCookieDomain=replace(lcase(zcgi.http_host),"www.","");
    request.zRootPath="/"&replace(request.zRootDomain,".","_","all")&"/"; 
    request.zRootSecureCfcPath="jetendo-sites-writable."&replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&".";
    request.zRootCfcPath=replace(replace(request.zRootDomain,".","_","all"),"/",".","ALL")&"."; 
    request.cgi_script_name=replacenocase(cgi.script_name,request.zRootPath,"/");  
    for(i in form){
        if(isSimpleValue(form[i])){
            form[i]=trim(form[i]);  
        }
    }
    zos.lastTime=zos.startTime;
    zos.now=now();
    zos.modes.time.begin = zos.startTime;
    zos.mysqlnow=DateFormat(zos.now,'yyyy-mm-dd')&' '&TimeFormat(zos.now,'HH:mm:ss');
     
	zos.queryCount=0;
	zos.queryRowCount=0; 
    variables.getApplicationConfig(); 
    </cfscript>
</cffunction>
        
<cffunction name="getApplicationConfig" localmode="modern" output="no">
    <cfscript>
    var ts=structnew();
    
    zos=request.zos;
    if(structkeyexists(server, "zcore_"&zos.installPath&"_cache") and zos.zreset NEQ 'app' and zos.zreset NEQ 'all'){
        structappend(this, server["zcore_"&zos.installPath&"_cache"], true);
        return;
    }

    // lookup the app name.
    ts.Name = "zcore_"&zos.installPath;
    ts.ApplicationTimeout = CreateTimeSpan( 30, 0, 0, 0 );
    ts.SessionTimeout=CreateTimeSpan(0,0,zos.sessionExpirationInMinutes,0); 
	
    server["zcore_"&zos.installPath&"_cache"]=ts;
    structappend(this, ts, true);
	
    </cfscript>
</cffunction> 
	
<cffunction name="onAbort" localmode="modern" access="public" output="yes">
	<cfargument name="template" type="string" required="yes" />
	<cfscript>
	if(isdefined('application.zcore.functions.zabort') and structkeyexists(request.zos, 'globals')){
		application.zcore.functions.zabort();
	}
	</cfscript>
</cffunction>

</cfcomponent>
