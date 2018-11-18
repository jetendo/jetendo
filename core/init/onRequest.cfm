<cffunction name="OnRequest" localmode="classic" access="public" returntype="void" output="true" hint="Fires after pre page processing is complete."><cfargument name="TargetPage" type="string" required="true" />
 	<cfscript>
	var local=structnew();
	var template=0;
	var e=0; 
	var cfcatch=0;
	/*
	// used to debug request start-up performance by running it many times.
	for(local.i=1;local.i LTE 200;local.i++){
		if(structkeyexists(application.zcore,'template')) application.zcore.template.init2();
		onRequestStart(arguments.targetpage);
	}
	writeoutput('done');
	application.zcore.functions.zabort();*/ 
	savecontent variable="request.zos.onRequestOutput"{
		if(structkeyexists(form, request.zos.urlRoutingParameter) EQ false){
			include template="#arguments.targetpage#";
			return;
		} 
		if(request.zos.routingIsCFC EQ false){
			if(right(request.zos.scriptNameTemplate,4) EQ ".cfc" or right(request.zos.scriptNameTemplate,4) EQ ".lucee" or right(request.zos.scriptNameTemplate,4) EQ ".lc"){ 
				if(left(request.zos.scriptNameTemplate, 16) EQ "/jetendo-themes/"){
					local.tempCom9999=application.zcore.functions.zcreateobject("component",replace(mid(request.zos.cgi.SCRIPT_NAME, 2, len(request.zos.cgi.SCRIPT_NAME)-5), "/",".","all"));
				}else{
					local.tempCom9999=application.zcore.functions.zcreateobject("component",request.zRootCFCPath&replace(mid(request.zos.cgi.SCRIPT_NAME, 2, len(request.zos.cgi.SCRIPT_NAME)-5), "/",".","all"));
				}
				local.tempCom9999[form.method]();
			}else if(right(request.zos.scriptNameTemplate,6) EQ ".lucee"){  
				if(left(request.zos.scriptNameTemplate, 16) EQ "/jetendo-themes/"){
					local.tempCom9999=application.zcore.functions.zcreateobject("component",replace(mid(request.zos.cgi.SCRIPT_NAME, 2, len(request.zos.cgi.SCRIPT_NAME)-7), "/",".","all"));
				}else{
					local.tempCom9999=application.zcore.functions.zcreateobject("component",request.zRootCFCPath&replace(mid(request.zos.cgi.SCRIPT_NAME, 2, len(request.zos.cgi.SCRIPT_NAME)-7), "/",".","all"));
				}
				local.tempCom9999[form.method]();
			}else if(right(request.zos.scriptNameTemplate,3) EQ ".lc"){ 
				if(left(request.zos.scriptNameTemplate, 16) EQ "/jetendo-themes/"){
					local.tempCom9999=application.zcore.functions.zcreateobject("component",replace(mid(request.zos.cgi.SCRIPT_NAME, 2, len(request.zos.cgi.SCRIPT_NAME)-4), "/",".","all"));
				}else{
					local.tempCom9999=application.zcore.functions.zcreateobject("component",request.zRootCFCPath&replace(mid(request.zos.cgi.SCRIPT_NAME, 2, len(request.zos.cgi.SCRIPT_NAME)-4), "/",".","all"));
				}
				local.tempCom9999[form.method]();
			}else{
				if(structkeyexists(form,'__zcoreinternalroutingpath') and form.__zcoreinternalroutingpath NEQ ""){
					application.zcore.template.prependErrorContent("There was an error while running #expandpath('zcorerootmapping')#/#form.__zcoreinternalroutingpath#.");
					try{
						include template="/zcorerootmapping/#form.__zcoreinternalroutingpath#"
					}catch(any e){
						if(request.zos.isdeveloper or cfcatch.type NEQ "missinginclude"){
							rethrow;
						}
						application.zcore.functions.z404("The requested template doesn't exist in onRequest. Path: /zcorerootmapping/#form.__zcoreinternalroutingpath#");	
					}
					application.zcore.template.replaceErrorContent("");
				}else{
					if(request.zos.scriptNameTemplate CONTAINS "/railo-context/"){
						application.zcore.functions.z404("cfml admin can't be visited through a public port.");	
					}else if(left(request.zos.scriptNameTemplate, 7) EQ "/lucee/"){
						application.zcore.functions.z404("cfml admin can't be visited through a public port.");	
					}
					if(request.zos.globals.id EQ request.zos.globals.serverid){
						request.zos.scriptNameTemplate=replace(request.zos.scriptNameTemplate, '/'&request.zos.globals.servershortdomain,'/zcorerootmapping/');	
					}
					var ext=right(request.zos.scriptNameTemplate, 4);
					if(ext NEQ ".cfm"){
						if(ext EQ ".xml"){
							var p=request.zos.globals.homedir&removechars(request.zos.originalURL, 1, 1);
							if(fileexists(p)){
								echo(application.zcore.functions.zReadFile(p));
								abort;
							}
						}else if(ext EQ "html"){
							var p=request.zos.globals.homedir&removechars(request.zos.originalURL, 1, 1);
							if(fileexists(p)){
								echo(application.zcore.functions.zReadFile(p));
								abort;
							}
						}
						application.zcore.functions.z404("onRequest missing include. "&request.zos.scriptNameTemplate);
					}
					try{
						include template="#request.zos.scriptNameTemplate#";
					}catch(missinginclude e){
						application.zcore.functions.z404("onRequest missing include. Path:"&request.zos.scriptNameTemplate);
					}
				}
			}
		}
		request.zos.onrequestcompleted=true;
	}
	</cfscript>
</cffunction>