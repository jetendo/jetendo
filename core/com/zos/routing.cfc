<cfcomponent output="no">
<cfoutput>
<cffunction name="processRequestURL" localmode="modern" access="public" output="true" returntype="string"><cfargument name="theURL" type="string" required="yes"><cfscript>
		var cfcMethodForced=false;
		  
		request.zos.currentController="";
		request.zos.routingIsCFC=false; 
		request.zos.routingIsLucee=false;
		request.zos.routingIsLC=false;
		request.zos.routingArrArguments=arraynew(1);
		request.zos.routingArgumentsStruct=structnew();
		request.zos.routingDisableComponentInvoke=false;
		request.zos.routingCfcMethodWasMissing=false;
		if((request.zos.isdeveloper EQ false and request.zos.isserver EQ false) or structkeyexists(form,'zdebugurl2') EQ false){
			zdebugurl2=false;
		}else{
			zdebugurl2=form.zdebugurl2;
			structdelete(form, 'zdebugurl2');
		}
		
		if(structkeyexists(form,request.zos.urlRoutingParameter)){
			request.zos.cgi.query_string=replace(request.zos.cgi.query_string, request.zos.urlRoutingParameter&"="&form[request.zos.urlRoutingParameter], "","all");
			if(left(request.zos.cgi.query_string,1) EQ "&"){
				request.zos.cgi.query_string=removechars(request.zos.cgi.query_string,1,1);
			}
		} 
		if(arguments.theURL EQ ""){
			application.zcore.functions.z404("Path doesn't exist or is a directory.");
		}else if((not structkeyexists(form,'__zcoreinternalroutingpath') or trim(form.__zcoreinternalroutingpath) EQ "")){
			// notCFC=false;
			// if(find(".cfc", arguments.theURL) EQ 0 and find(".lucee", arguments.theURL) EQ 0 and find(".lc", arguments.theURL) EQ 0){
			// 	notCFC=true;
			// }
			siteStruct=application.sitestruct[request.zos.globals.id];
			ctemp1=request.zos.globals.homedir&removechars(arguments.theURL,1,1);
			if(not structkeyexists(siteStruct.fileExistsCache, ctemp1)){
				siteStruct.fileExistsCache[ctemp1]=fileexists(ctemp1);
			}
			/*
			// this code was unnecessary
			if(not structkeyexists(siteStruct.fileExistsCache, arguments.theURL)){
				siteStruct.fileExistsCache[arguments.theURL]=fileexists(arguments.theURL);
			}*/
			request.zos.routingDisableComponentInvoke=true;
			if(siteStruct.fileExistsCache[ctemp1]){// or siteStruct.fileExistsCache[arguments.theURL]
				if(right(arguments.theURL,4) EQ ".cfc"){
					request.zos.routingIsCFC=true;
					if(structkeyexists(form,'method') EQ false){
						form.method="index";	
						request.zos.routingCfcMethodWasMissing=true;
					}
					request.zos.routingDisableComponentInvoke=false;
					if(zdebugurl2){
						writeoutput('url was a cfc :'&arguments.theURL&'<br />');
					}
				}else if(right(arguments.theURL,6) EQ ".lucee"){
					request.zos.routingIsCFC=true;
					request.zos.routingIsLucee=true;
					if(structkeyexists(form,'method') EQ false){
						form.method="index";	
						request.zos.routingCfcMethodWasMissing=true;
					}
					request.zos.routingDisableComponentInvoke=false;
					if(zdebugurl2){
						writeoutput('url was a lucee cfc :'&arguments.theURL&'<br />');
					}
				}else if(right(arguments.theURL,3) EQ ".lc"){
					request.zos.routingIsCFC=true;
					request.zos.routingIsLC=true;
					if(structkeyexists(form,'method') EQ false){
						form.method="index";	
						request.zos.routingCfcMethodWasMissing=true;
					}
					request.zos.routingDisableComponentInvoke=false;
					if(zdebugurl2){
						writeoutput('url was a lc cfc :'&arguments.theURL&'<br />');
					}
				}
			}else{
				form.__zcoreinternalroutingpath=removechars(arguments.theURL,1,1);
				//form.__zcoreinternalroutingpath=removechars(form[request.zos.urlRoutingParameter],1,1);
				arrURL=listtoarray(form.__zcoreinternalroutingpath,"/",true);
				// find a matching registered controller
				curURLData="";
				urlPathCount=arraylen(arrURL);
				isUsingMVCAppScope=true;
				controllerFound=true;
				routingISMVC=false;
				for(i4=1;i4 LTE urlPathCount;i4++){
					lastURLData=curURLData;
					curURLData&="/"&arrURL[1];
					curURLPath=arrURL[1];
					arraydeleteat(arrURL, 1);
					
						if(zdebugurl2){
								writeoutput('curdata:'&curURLData&'<br />');
						}
					if(structkeyexists(siteStruct.registeredControllerStruct, "/controller"&curURLData)){
						if(zdebugurl2){
							writeoutput("Found controller in application scope: "&"/controller"&curURLData&".cfc<br />");
						}
						break;
					}else if(structkeyexists(siteStruct.registeredControllerPathStruct, curURLData) EQ false){
						
						cfcLookupName=lastURLData&"/controller/"&curURLPath;
						cfcURLName=lastURLData&"/"&curURLPath;
						
						if(isUsingMVCAppScope and structkeyexists(siteStruct.registeredControllerStruct, cfcLookupName)){
							routingISMVC=true;
							request.zos.routingIsCFC=true;
							request.zos.scriptNameTemplate=siteStruct.registeredControllerStruct[cfcLookupName];
							if(zdebugurl2){
								writeoutput("Found controller in site struct: "&curURLData&"<br />");
							}
						}else{
							if(zdebugurl2){
								writeoutput("Missing controller in application scope: "&curURLData&" | switching to global application struct<br />");
							}
							controllerFound=false;
						}
						break;
					}
				}
				if(controllerFound EQ false){
					lastURLData="";
					curURLData="";
					arrURL=listtoarray(form.__zcoreinternalroutingpath,"/",true);
					for(i4=1;i4 LTE urlPathCount;i4++){
						lastURLData=curURLData;
						curURLData&="/"&arrURL[1];
						curURLPath=arrURL[1];
						arraydeleteat(arrURL, 1);
						
						if(structkeyexists(application.zcore.registeredControllerStruct, "/controller"&curURLData)){
							if(zdebugurl2){
								writeoutput("Found controller in site struct: "&"/controller"&curURLData&".cfc<br />");
							}
							isUsingMVCAppScope=false;
							break;
						}else if(structkeyexists(application.zcore.registeredControllerStruct, curURLData) EQ false){
							if(zdebugurl2){
								writeoutput("Missing path: "&curURLData&" | switching to global application struct<br />");
							}
							isUsingMVCAppScope=false;
							if(structkeyexists(application.zcore.registeredControllerPathStruct, curURLData) EQ false){
								break;
							}
						}
					}
				}
				
				cfcLookupName=lastURLData&"/controller/"&curURLPath;
				cfcURLName=lastURLData&"/"&curURLPath;
				
				if(zdebugurl2){
					writeoutput('cfcLookupName:'&cfcLookupName&'<br />cfcURLName:'&cfcURLName&"<br />isUsingMVCAppScope:"&isUsingMVCAppScope&"<br />");
					writeoutput('Application MVC Cache<br />');
					writeoutput('application.zcore.registeredControllerPathStruct<br />');
					writedump(application.zcore.registeredControllerPathStruct);
					writeoutput('application.zcore.registeredControllerStruct<br />');
					writedump(application.zcore.registeredControllerStruct);
					writeoutput('Application MVC Cache<br />siteStruct.registeredControllerPathStruct<br />');
					writedump(siteStruct.registeredControllerPathStruct);
					writeoutput('siteStruct.registeredControllerStruct<br />');
					writedump(siteStruct.registeredControllerStruct);
				}
				routingISMVC=false;
				if(isUsingMVCAppScope and structkeyexists(siteStruct.registeredControllerStruct, cfcLookupName)){
					routingISMVC=true;
					request.zos.routingIsCFC=true;
					request.zos.scriptNameTemplate=siteStruct.registeredControllerStruct[cfcLookupName];
				}else{
					if(structkeyexists(application.zcore.registeredControllerStruct, cfcLookupName)){
						routingISMVC=true;
						request.zos.routingIsCFC=true;
						request.zos.scriptNameTemplate=application.zcore.registeredControllerStruct[cfcLookupName];
					}
				}
				if(routingISMVC){
					request.zos.cgi.SCRIPT_NAME="/"&form.__zcoreinternalroutingpath;
					//arraydeleteat(arrURL,1);
					request.zos.routingCfcMethodWasMissing=true;
					request.zos.routingDisableComponentInvoke=false;
					if(zdebugurl2){
						writeoutput("Running MVC Component:"&request.zos.scriptNameTemplate&"<br />");
					}
					if(arraylen(arrURL) GTE 1 and trim(arrURL[1]) NEQ ""){
						form.method=arrURL[1];
						arraydeleteat(arrURL,1);
						if(zdebugurl2){
							writeoutput("method:"&form.method&"<br />");
							writedump("Remaining url string: "&arraytolist(arrURL, "/"));
							writedump(arrURL);
						}
						if(arraylen(arrURL) EQ 1){
							if(trim(arrURL[1]) EQ ""){
								if(request.zos.cgi.query_string NEQ ""){
									if(zdebugurl2){
										writeoutput("1 - redirecting to "&cfcURLName&"/"&form.method&"?"&request.zos.cgi.query_string); 
										application.zcore.functions.zabort();
									}
									application.zcore.functions.z301redirect(cfcURLName&"/"&form.method&"?"&request.zos.cgi.query_string);
								}else{
									if(zdebugurl2){
										writeoutput("2 - redirecting to "&cfcURLName&"/"&form.method&""); 
										application.zcore.functions.zabort();
									}
									application.zcore.functions.z301redirect(cfcURLName&"/"&form.method&"");	
								}
							}
						}else if(arraylen(arrURL) GTE 1 and trim(arrURL[arraylen(arrURL)]) EQ ""){
							arraydeleteat(arrURL,arraylen(arrURL));
							if(request.zos.cgi.query_string NEQ ""){
								if(zdebugurl2){
									writeoutput("3 - redirecting to "&cfcURLName&"/"&form.method&"/"&arraytolist(arrURL,"/")&"?"&request.zos.cgi.query_string); 
									application.zcore.functions.zabort();
								}
								application.zcore.functions.z301redirect(cfcURLName&"/"&form.method&"/"&arraytolist(arrURL,"/")&"?"&request.zos.cgi.query_string);
							}else{
								if(zdebugurl2){
									writeoutput("4 - redirecting to "&cfcURLName&"/"&form.method&"/"&arraytolist(arrURL,"/")); 
									application.zcore.functions.zabort();
								}
								application.zcore.functions.z301redirect(cfcURLName&"/"&form.method&"/"&arraytolist(arrURL,"/"));
							}
						}
					}else{
						form.method="index";
						if(len(request.zos.cgi.query_string)){
							if(zdebugurl2){
								writeoutput("5 - redirecting to "&cfcURLName&"/"&form.method&"?"&request.zos.cgi.query_string); 
								application.zcore.functions.zabort();
							}
							application.zcore.functions.z301redirect(cfcURLName&"/"&form.method&"?"&request.zos.cgi.query_string);
						}else{
							if(zdebugurl2){
								writeoutput("6 - redirecting to "&cfcURLName&"/"&form.method); 
								application.zcore.functions.zabort();
							}
							application.zcore.functions.z301redirect(cfcURLName&"/"&form.method);
						}
						cfcMethodForced=true;
					}
					request.zos.routingArrArguments=arrURL;
				}
				if(zdebugurl2){
					abort;
				}
			}
			structdelete(form,'__zcoreinternalroutingpath');
		}else{
			if(form.__zcoreinternalroutingpath CONTAINS "www." or trim(form.__zcoreinternalroutingpath) CONTAINS " " or form.__zcoreinternalroutingpath CONTAINS "'" or form.__zcoreinternalroutingpath CONTAINS '"' or form.__zcoreinternalroutingpath CONTAINS "mailto:" or form.__zcoreinternalroutingpath CONTAINS "/undefined.cfm" or form.__zcoreinternalroutingpath CONTAINS "/.cfm" or right(form.__zcoreinternalroutingpath,9) EQ ".html.cfm" or right(form.__zcoreinternalroutingpath,8) EQ ".txt.cfm" or right(form.__zcoreinternalroutingpath,8) EQ ".cfm.cfm" or right(form.__zcoreinternalroutingpath,8) EQ ".php.cfm" or form.__zcoreinternalroutingpath CONTAINS "javascript:"){
				application.zcore.functions.z404("An invalid url was matched in routing() before further processing occurred.");	
			}
			// clean up query string
			var p=findnocase("__zcoreinternalroutingpath",request.zos.cgi.query_string);
			var p2=find("&",request.zos.cgi.query_string,p);
			if(p NEQ 0){
				if(p2 EQ 0){
					request.zos.cgi.query_string="";
				}else{
					request.zos.cgi.query_string=removeChars(request.zos.cgi.query_string,p,(p2-p)+1);
				}
			}

			// writeDump( 'FINALLY' );
			// writeDump( form );
			// abort;
			if ( left( form.__zcoreinternalroutingpath, 3 ) EQ '-vl' ) {
				this.processEmailClickURL();
			} else if ( left( form.__zcoreinternalroutingpath, 3 ) EQ '-vf' ) {
				this.processEmailClickURL();
			} else if ( left( form.__zcoreinternalroutingpath, 3 ) EQ '-df' ) {
				this.processEmailClickURL();
			} else if ( left( form.__zcoreinternalroutingpath, 2 ) EQ '-e' ) {
				// check for email click links
				this.processEmailClickURL();
			} else {
				// process all other mvc and zcore urls
				request.zos.scriptNameTemplate="/zcorerootmapping/#form.__zcoreinternalroutingpath#";
				if(right(form.__zcoreinternalroutingpath,4) NEQ ".cfm" and right(form.__zcoreinternalroutingpath,4) NEQ ".cfc"){
					request.zos.cgi.script_name=form.__zcoreinternalroutingpath;
				}else{
					if(len(form.__zcoreinternalroutingpath)-4 LTE 0){
						application.zcore.functions.z301redirect('/');	
					}
					request.zos.cgi.script_name="/z/_#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
				}
				
				if(find(","&left(form.__zcoreinternalroutingpath,4)&",", ',com/,') NEQ 0){
					request.zos.routingIsCFC=true;
				}else{
					writeoutput('old mvc is not supposed to happen - there is a problem.<br />URL:'&form.__zcoreinternalroutingpath);
					application.zcore.functions.zabort();
				}
			}
		}
		if(request.zos.routingIsCFC and structkeyexists(form,'method')){
			rs=this.checkCFCSecurity(request.zos.scriptNameTemplate, form.method); 
			request.zos.requestLogEntry('routing.cfc after checkCFCSecurity');
			request.zos.currentController=request.zos.scriptNameTemplate;
			//writeoutput('in isCFC'&request.zos.routingDisableComponentInvoke);
			if(request.zos.routingDisableComponentInvoke EQ false){  
				request.zArrErrorMessages=["#form.method#() function of #request.zos.currentController# was called in routing.cfc"];
				if(structcount(request.zos.routingArgumentsStruct) EQ 0){
					rs.routingCurrentComponentObject[form.method]();
				}else{
					rs.routingCurrentComponentObject[form.method](argumentcollection=request.zos.routingArgumentsStruct);
				}
				request.zArrErrorMessages=[];
				request.zos.onrequestcompleted=true;
				if(request.zos.routingCfcMethodWasMissing){
					// disable the default introspection feature of coldfusion CFCs and end the request now.
					return;
					//throw("cfc method missing: #request.zos.currentController#", "custom");
					//server["zcore_"&request.zos.installPath&"_functionscache"].onRequestEnd();
					//abort;
				}
			}
		}
		</cfscript>
	</cffunction>

     
    <cffunction name="checkCFCSecurity" localmode="modern" output="no" returntype="any">
    	<cfargument name="scriptName" type="string" required="yes">
    	<cfargument name="method" type="string" required="yes">
    	<cfscript> 
		var isTestCFC=false;
		var isServerCFC=false; 
		var comTempPath=arguments.scriptName;
		rs={};
		arguments.method=arguments.method;
		siteStruct=application.sitestruct[request.zos.globals.id];
		cacheStruct=siteStruct.cfcMetaDataCache;
		if(request.zos.routingIsLucee){
			comPath=replace(replace(replace(mid(comTempPath,2,len(comTempPath)-7),"\",".","ALL"),"/",".","ALL"), request.zRootDomain&".", request.zRootCFCPath);
		}else if(request.zos.routingIsLC){
			comPath=replace(replace(replace(mid(comTempPath,2,len(comTempPath)-4),"\",".","ALL"),"/",".","ALL"), request.zRootDomain&".", request.zRootCFCPath);
		}else{
			comPath=replace(replace(replace(mid(comTempPath,2,len(comTempPath)-5),"\",".","ALL"),"/",".","ALL"), request.zRootDomain&".", request.zRootCFCPath);
		}
		if(left(comPath, 17) EQ "zcorerootmapping."){
			isServerCFC=true;
			cacheStruct=application.zcore.cfcMetaDataCache;
		}else if(len(request.zRootCFCPath) and left(comPath, len(request.zRootCFCPath)) NEQ request.zRootCFCPath){ 
			if(compare(request.zos.globals.id, request.zos.globals.serverid) EQ 0){
				comPath="zcorerootmapping."&comPath;
			}else{
				if(left(comPath, 15) NEQ "jetendo-themes."){
					comPath=request.zRootCFCPath&comPath;	
				}
			}
		}
		if(comPath CONTAINS ".test."){
			isTestCFC=true;
			if(request.zos.istestserver EQ false){
				throw("Running tests in production is not allowed.");	
			}
			request.znotemplate=true;
		}
		notFound=true; 
		if(request.zos.enableSiteTemplateCache){
			if(isServerCFC EQ false and structkeyexists(siteStruct.controllerComponentCache, comPath)){
				rs.routingCurrentComponentObject=duplicate(siteStruct.controllerComponentCache[comPath]);
				notFound=false;
			}else if(structkeyexists(application.zcore.controllerComponentCache, comPath)){
				rs.routingCurrentComponentObject=duplicate(application.zcore.controllerComponentCache[comPath]);
				notFound=false;
			}else if(Structkeyexists(siteStruct.comCache, comPath)){
				rs.routingCurrentComponentObject=duplicate(siteStruct.comCache[comPath]);
				notFound=false;
			}
			if(notFound){
				rs.routingCurrentComponentObject=application.zcore.functions.zcreateobject("component",comPath);
				siteStruct.comCache[comPath]=rs.routingCurrentComponentObject;
			}
		}else{ 
			rs.routingCurrentComponentObject=createobject("component",comPath);
		} 
		if(structkeyexists(rs.routingCurrentComponentObject,arguments.method) EQ false){
			application.zcore.functions.z404("Component method doesn't exist. Method = ""#arguments.method#""");
		} 
		if(not request.zos.enableSiteTemplateCache or structkeyexists(cacheStruct, comPath) EQ false){
			commeta=GetMetaData(rs.routingCurrentComponentObject);
			cacheStruct[comPath]=commeta; 
			tempcommeta=GetMetaData(rs.routingCurrentComponentObject[arguments.method]);
			cacheStruct[comPath&":"&arguments.method]=tempcommeta;
		}else{
			commeta=cacheStruct[comPath];
			if(structkeyexists(cacheStruct, comPath&":"&arguments.method)){
				tempcommeta=cacheStruct[comPath&":"&arguments.method];
			}else{
				tempcommeta=GetMetaData(rs.routingCurrentComponentObject[arguments.method]);
				cacheStruct[comPath&":"&arguments.method]=tempcommeta;
			}
		}
		if(tempcommeta.access NEQ 'remote'){
			application.zcore.functions.z404("The component method must have access=""remote"" to be called directly via the URL. Please change access to remote for Method, ""#arguments.method#"", in #arguments.scriptName# if you need this function to be access remotely.");
		}
		if(isTestCFC EQ false){
			for(i=1;i LTE arraylen(tempcommeta.parameters);i++){
				if(tempcommeta.parameters[i].type NEQ "string" and tempcommeta.parameters[i].required EQ "yes"){
					application.zcore.functions.z404("All parameters of a Component method that have access=""remote"" must have the data type=""string"" or required=""no"" to prevent errors with unexpected data (robots &amp; pci scans, etc). Please change the argument, ""#tempcommeta.parameters[i].name#"", in method, ""#arguments.method#"" in #arguments.scriptName#.");
				}
			}
		}

		if(structkeyexists(rs.routingCurrentComponentObject, '__injectDependencies')){
			ds={
				context:application.zcore.componentObjectCache.context
			};
			if(structkeyexists(comMeta, 'properties')){
				for(i=1;i LTE arraylen(comMeta.properties);i++){
					property=comMeta.properties[i];
					if(right(property.name, 5) EQ "Model" and find(".model.", property.type) NEQ false){
						if(left(property.type, 5) EQ "root."){
							if(not request.zos.istestserver and structkeyexists(siteStruct.modelDataCache.modelComponentCache, property.type)){
								ds[property.name]=siteStruct.modelDataCache.modelComponentCache[property.type];
							}else{
								ds[property.name]=application.zcore.functions.zcreateobject("component", replace(property.type, "root.", request.zRootCFCPath), true);
							}
						}else{
							if(not request.zos.istestserver and structkeyexists(application.zcore.modelDataCache.modelComponentCache, property.type)){
								ds[property.name]=application.zcore.modelDataCache.modelComponentCache[property.type];
							}else{
								ds[property.name]=application.zcore.functions.zcreateobject("component", property.type, true);
							}
						}
					}
				}
			}
			rs.routingCurrentComponentObject.__injectDependencies(ds);
		}
		for(i=1;i LTE arraylen(request.zos.routingArrArguments);i++){
			if(i LTE arraylen(tempcommeta.parameters)){
				request.zos.routingArgumentsStruct[tempcommeta.parameters[i].name]=request.zos.routingArrArguments[i];
			}else{
				// additional parameters with undefined arguments are sent in as an array
				if(structkeyexists(request.zos.routingArgumentsStruct, "_zExtraArguments") EQ false){
					request.zos.routingArgumentsStruct["_zExtraArguments"]=arraynew(1);
				}
				arrayappend(request.zos.routingArgumentsStruct["_zExtraArguments"], request.zos.routingArrArguments[i]);
			}
		}
		if(structkeyexists(tempcommeta,'roles') and application.zcore.user.checkSiteAccess() EQ false and application.zcore.user.checkServerAccess() EQ false){
			// only one user group role can be defined even though coldfusion supports more. Example: roles="member"
			arrLoginRoles=listtoarray(tempcommeta.roles,",");
			curRole="";
			for(i=1;i LTE arraylen(arrLoginRoles);i++){
				curRole=trim(arrLoginRoles[i]);
				tempLoginSkip=false;
				if(application.zcore.user.checkGroupAccess(curRole) EQ false){
					break;
				}else{
					curRole="";	
				}
			}
			if(curRole NEQ ""){
				request.zos.inMemberArea=true;
				application.zcore.skin.disableMinCat();
				request.disableShareThis=true;
				inputStruct = StructNew();
				inputStruct.user_group_name=curRole;
				if(request.zos.globals.requireSecureLogin EQ 1){
					inputStruct.secureLogin=true;
				}else{
					inputStruct.secureLogin=false;
				}
				inputStruct.noRedirect=false;
				inputStruct.template="zcorerootmapping.templates.blank";
				inputStruct.site_id = request.zos.globals.id;
				application.zcore.user.checkLogin(inputStruct); 
				
			} 
		}
		if(structkeyexists(tempcommeta,'roles') and tempcommeta.roles NEQ ""){
			if(tempcommeta.roles NEQ "user"){
				application.zcore.template.setTemplate("zcorerootmapping.templates.administrator",true,true);
				request.zos.inMemberArea=true;
				application.zcore.skin.disableMinCat();
				application.zcore.functions.zDisableContentTransition();
			}
		}
		return rs;
		</cfscript>
    </cffunction>
    
    <cffunction name="processEmailClickURL" localmode="modern" output="no" returntype="any">
    	<cfscript>
		var arrpath='';
		var qE='';
		var inputStruct='';
		var ts='';
		var i=0;
		var qM=0;
		var t=0;
		var urlType=0;
		var db=request.zos.queryObject;
		var mailUserType=false;

		if ( left( form.__zcoreinternalroutingpath, 3 ) EQ '-vl' ) {
			form.__zcoreinternalroutingpath_new='mvc/z/misc/controller/system.cfc';
			form.method="redirectToLink";
			arrPath=listtoarray(form.__zcoreinternalroutingpath,'.');
			if(arrayLen(arrPath) LT 2){
				application.zcore.functions.z404("Invalid request");
			}
			form.short_link_id=arrPath[2]; 
			request.zos.routingIsCFC=true; 
		}else if ( left( form.__zcoreinternalroutingpath, 3 ) EQ '-vf' ) {
			form.__zcoreinternalroutingpath_new='mvc/z/misc/controller/download.cfc';
			form.method="serveFileById";
			arrPath=listtoarray(form.__zcoreinternalroutingpath,'.');
			if(arrayLen(arrPath) LT 6){
				application.zcore.functions.z404("Invalid request");
			}
			form.virtual_file_secure=arrPath[2];
			// form.futureUse1=arrPath[3];
			// form.futureUse2=arrPath[4];
			form.virtual_file_id=arrPath[5];
			form.virtual_file_download_secret=arrPath[6];
			request.zos.routingIsCFC=true; 
			
		} else if ( left( form.__zcoreinternalroutingpath, 3 ) EQ '-df' ) {
			form.__zcoreinternalroutingpath_new='mvc/z/misc/controller/download.cfc';
			form.method="downloadFileById";
			arrPath=listtoarray(form.__zcoreinternalroutingpath,'.');
			if(arrayLen(arrPath) LT 6){
				application.zcore.functions.z404("Invalid request");
			}
			form.virtual_file_secure=arrPath[2];
			// form.futureUse1=arrPath[3];
			// form.futureUse2=arrPath[4];
			form.virtual_file_id=arrPath[5];
			form.virtual_file_download_secret=arrPath[6];
			request.zos.routingIsCFC=true;
		} else {

			// START REGULAR HANDLING

			key=mid(form.__zcoreinternalroutingpath,3,2);

			//request.zos.znoredirect=true; // uncomment to debug redirects

			if(mid(form.__zcoreinternalroutingpath,5,1) EQ 'm'){
				mailUserType=true;
				var t=mid(form.__zcoreinternalroutingpath,6,len(form.__zcoreinternalroutingpath)-5);
				arrpath=listtoarray(t,'.');
				if(arraylen(arrpath) GTE 2){
					form.contact_id=arrpath[1];
					urlType=key;
					if(urlType EQ 'ck' or urlType EQ 'in'){
						form.contact_key=arrpath[2];
					}else{
						form.zemail_campaign_id=arrpath[2];
						form.contact_key=arrpath[3];
					}
					db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)#  
					WHERE contact_id=#db.param(form.contact_id)# and 
					contact_deleted = #db.param(0)# and 
					contact_key=#db.param(form.contact_key)# and 
					site_id=#db.param(request.zos.globals.id)#";
					qM=db.execute("qM"); 
					if(qM.recordcount EQ 0){
						application.zcore.functions.zredirect('/');
					}else{
						request.zsession.inquiries_email=qm.contact_email;
						request.zsession.inquiries_first_name=qm.contact_first_name;
						request.zsession.inquiries_last_name=qm.contact_last_name;
						request.zsession.inquiries_phone1=qm.contact_phone1;
					}
				}else{
					application.zcore.functions.zredirect('/');
				}
				if(key EQ 'in'){
					db.sql="update #db.table("user", request.zos.zcoreDatasource)# user 
					set user_confirm=#db.param(1)#, 
					user_pref_email=#db.param(1)#, 
					user_confirm_datetime=#db.param(request.zos.mysqlnow)#, 
					user_confirm_ip=#db.param(request.zos.cgi.remote_addr)#,
					user_updated_datetime=#db.param(request.zos.mysqlnow)#  
					WHERE user_username=#db.param(qM.contact_email)# and 
					user_deleted = #db.param(0)# and
					site_id=#db.param(request.zos.globals.id)#";
					db.execute("q"); 
					db.sql="update #db.table("contact", request.zos.zcoreDatasource)#  
					set contact_opt_in=#db.param(1)#, 
					contact_opt_out=#db.param(0)#, 
					contact_confirm=#db.param(1)#,
					contact_updated_datetime=#db.param(request.zos.mysqlnow)#  
					WHERE contact_id=#db.param(form.contact_id)# and 
					contact_deleted = #db.param(0)# and 
					contact_key=#db.param(form.contact_key)# and 
					site_id=#db.param(request.zos.globals.id)#";
					db.execute("q"); 
					// opt in any extra contact records with same email address
					db.sql="select contact_id, contact_email from #db.table("contact", request.zos.zcoreDatasource)#  WHERE 
					contact_id=#db.param(form.contact_id)# and 
					contact_deleted = #db.param(0)# and 
					contact_key=#db.param(form.contact_key)# and 
					site_id=#db.param(request.zos.globals.id)#";
					qContact=db.execute("qContact");
					for(row in qContact){
						if(row.contact_email NEQ ""){
							 db.sql="update #db.table("contact", request.zos.zcoreDatasource)#  
							 set contact_opt_in=#db.param(1)#, 
							 contact_opt_out=#db.param(0)#, 
							 contact_confirm=#db.param(1)#,  
							 contact_confirm_datetime=#db.param(request.zos.mysqlnow)#, 
							 contact_confirm_ip=#db.param(request.zos.cgi.remote_addr)#,
							 contact_updated_datetime=#db.param(request.zos.mysqlnow)#  
							WHERE contact_id<>#db.param(form.contact_id)# and 
							contact_email=#db.param(row.contact_email)# and 
							contact_deleted = #db.param(0)# and  
							site_id=#db.param(request.zos.globals.id)#";
							db.execute("qUpdate");
						}
					}
					form.__zcoreinternalroutingpath_new='mvc/z/user/controller/in.cfc';
					form.method="simple_confirmed";
					request.zos.routingIsCFC=true;
				}else if(key EQ 'ou'){
					db.sql="update #db.table("user", request.zos.zcoreDatasource)# user 
					set user_pref_email=#db.param(0)#, 
					user_confirm=#db.param(1)#, 
					user_confirm_datetime=#db.param(request.zos.mysqlnow)#, 
					user_confirm_ip=#db.param(request.zos.cgi.remote_addr)#,
					user_updated_datetime=#db.param(request.zos.mysqlnow)#  
					WHERE user_username=#db.param(qM.contact_email)# and 
					user_deleted = #db.param(0)# and 
					site_id=#db.param(request.zos.globals.id)#";
					db.execute("q"); 
					 db.sql="update #db.table("contact", request.zos.zcoreDatasource)#  
					 set contact_opt_out=#db.param(1)#, 
					 contact_confirm=#db.param(1)#,  
					 contact_confirm_datetime=#db.param(request.zos.mysqlnow)#, 
					 contact_confirm_ip=#db.param(request.zos.cgi.remote_addr)#,
					 contact_updated_datetime=#db.param(request.zos.mysqlnow)#  
					WHERE contact_id=#db.param(form.contact_id)# and 
					contact_deleted = #db.param(0)# and 
					contact_key=#db.param(form.contact_key)# and 
					site_id=#db.param(request.zos.globals.id)#";
					db.execute("q");

					// opt out any extra contact records with same email address
					db.sql="select contact_id from #db.table("contact", request.zos.zcoreDatasource)#  WHERE 
					contact_id=#db.param(form.contact_id)# and 
					contact_deleted = #db.param(0)# and 
					contact_key=#db.param(form.contact_key)# and 
					site_id=#db.param(request.zos.globals.id)#";
					qContact=db.execute("qContact");
					for(row in qContact){
						if(row.contact_email NEQ ""){
							 db.sql="update #db.table("contact", request.zos.zcoreDatasource)#  
							 set contact_opt_out=#db.param(1)#, 
							 contact_confirm=#db.param(1)#,  
							 contact_confirm_datetime=#db.param(request.zos.mysqlnow)#, 
							 contact_confirm_ip=#db.param(request.zos.cgi.remote_addr)#,
							 contact_updated_datetime=#db.param(request.zos.mysqlnow)#  
							WHERE contact_id<>#db.param(form.contact_id)# and 
							contact_email=#db.param(row.contact_email)# and 
							contact_deleted = #db.param(0)# and  
							site_id=#db.param(request.zos.globals.id)#";
							db.execute("qUpdate");
						}
					}

					form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
					form.method="unsubscribed";
					request.zos.routingIsCFC=true;
				}else if(key EQ 'vm'){
					form.__zcoreinternalroutingpath_new='mvc/z/user/controller/view.cfc';
					form.method="simple";
					//request.zEmailViewOnline=true;
					request.zos.routingIsCFC=true;
				}else if(key EQ 'ck'){
					request.zEmailClickThrough=true;
				}
			}else{
				loginEnabled=true;
				if(key EQ 'up'){
					// show reset password form
					loginEnabled=false;
					form.__zcoreinternalroutingpath=mid(form.__zcoreinternalroutingpath,5,len(form.__zcoreinternalroutingpath)-4);
					arrpath=listtoarray(form.__zcoreinternalroutingpath,'.');
					if(arraylen(arrpath) GTE 2){
						form.user_id=arrpath[1];
						form.user_reset_key=arrpath[2];

						form.__zcoreinternalroutingpath_new='mvc/z/user/controller/reset-password.cfc';
						form.method="setNewPassword";
						request.zos.routingIsCFC=true;

					}else{
						application.zcore.functions.z404("Invalid update password request.");
					}
				}else if(key EQ 'in'){
					// confirm opt in
					form.__zcoreinternalroutingpath_new='mvc/z/user/controller/in.cfc';
					form.method="index";
					request.zos.routingIsCFC=true;
				}else if(key EQ 'ou'){
					// opt out
					form.__zcoreinternalroutingpath_new='mvc/z/user/controller/out.cfc';
					form.method="index";
					request.zos.routingIsCFC=true;
					request.zEmailUnsubscribe=true;
				}else if(key EQ 'rp'){
					// reset password confirm by email
					form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
					form.method="index";
					request.zos.routingIsCFC=true;
					form.npw=1;
				}else if(key EQ 'ce'){
					// 
					form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
					form.method="index";
					request.zos.routingIsCFC=true;
					form.nea=1;
				}else if(key EQ 'pr'){
					// show preference form
					form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
					request.zos.routingIsCFC=true;
					form.method="form";
				}else if(key EQ 'vm'){
					// view email
					form.__zcoreinternalroutingpath_new='mvc/z/user/controller/view.cfc';
					form.method="index";
					request.zEmailViewOnline=true;
					request.zos.routingIsCFC=true;
				}else if(key EQ 'ck'){
					// email click redirect
					request.zEmailClickThrough=true;
				}else{
					form.__zcoreinternalroutingpath_new='e/pref.cfm';
				}
				if(structkeyexists(request, 'zEmailViewOnline') or structkeyexists(request, 'zEmailUnsubscribe')){
					form.__zcoreinternalroutingpath=mid(form.__zcoreinternalroutingpath,5,len(form.__zcoreinternalroutingpath)-4);
					arrpath=listtoarray(form.__zcoreinternalroutingpath,'.');
					if(arraylen(arrpath) GTE 2){
						form.user_id=arrpath[1];
						form.zemail_campaign_id=arrpath[2];
						if(structkeyexists(request, 'zEmailViewOnline') and arraylen(arrpath) EQ 2){
							application.zcore.functions.zredirect('/');
						}else{
							if(arraylen(arrpath) GTE 3 or structkeyexists(request, 'zEmailViewOnline')){
								form.user_key=arrpath[3];
							}else{
								form.user_key=false;	
							}
							if(arraylen(arrpath) GTE 4){
								form.email_template_type_id=arrpath[4];
								if(form.email_template_type_id EQ 3){
									if(arraylen(arrpath) GTE 5){
										form.mls_saved_search_id=arrpath[5];
									}
								}
							}
								
						}
						// don't try to login again if already logged in
						if(form.user_key NEQ false){
							db.sql="SELECT user_username, user_key, user_password 
							FROM #db.table("user", request.zos.zcoreDatasource)# user 
							WHERE user_id = #db.param(form.user_id)# and 
							user_deleted = #db.param(0)# and
							user_active= #db.param(1)# and 
							(user_server_administrator= #db.param(1)# or 
							site_id = #db.param(request.zos.globals.id)#) and 
							user_key = #db.param(form.user_key)# ";
							qE=db.execute("qE"); 
							if(qE.recordcount NEQ 0){
								form.e=qE.user_username;
								form.k=qE.user_key;
								if(isDefined('request.zsession.user.id') EQ false or request.zsession.user.id NEQ form.user_id){
									form.zusername=qE.user_username;
									form.zpassword=qE.user_password;
									inputStruct = StructNew();
									inputStruct.user_group_name = "user";
									inputStruct.noRedirect=true;
									inputStruct.disableSecurePassword=true;
									inputStruct.secureLogin=false;
									inputStruct.site_id = request.zos.globals.id;
									application.zcore.user.checkLogin(inputStruct);
								}
							}
						}
					}else{
						application.zcore.functions.zredirect('/');
					}
					if(isDefined('request.zEmailUnsubscribe')){
						db.sql="INSERT INTO #db.table("zemail_campaign_click", request.zos.zcoreDatasource)#  
						SET zemail_campaign_click_type=#db.param(2)#, 
						zemail_campaign_click_html=#db.param(0)#, 
						zemail_campaign_click_offset=#db.param(0)#, 
						zemail_campaign_click_ip=#db.param(request.zos.cgi.remote_addr)#, 
						zemail_campaign_click_datetime=#db.param(request.zOS.mysqlnow)#, 
						zemail_campaign_click_updated_datetime=#db.param(request.zos.mysqlnow)#,
						zemail_campaign_id=#db.param(form.zemail_campaign_id)#,
						 user_id=#db.param(form.user_id)#,
						 site_id=#db.param(request.zos.globals.id)#";
						 db.execute("q"); 
						db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
						WHERE user_id = #db.param(form.user_id)# and 
						user_deleted = #db.param(0)# and
						(user_key=#db.param(form.user_key)# or 
						site_id = #db.param(request.zos.globals.id)#) ";
						qE=db.execute("qE"); 
						if(qE.recordcount EQ 0){
							application.zcore.functions.zRedirect('/z/user/out/index');
						}
						form.e=qE.user_username;
					}
				}else if(loginEnabled){
					if(structkeyexists(form,'user_id') EQ false or structkeyexists(form,'user_key') EQ false){
						// /z/_eck1.3423923.3.1.cfm
						form.__zcoreinternalroutingpath=mid(form.__zcoreinternalroutingpath,5,len(form.__zcoreinternalroutingpath)-4);
						arrpath=listtoarray(form.__zcoreinternalroutingpath,'.');
						if(arraylen(arrpath) GTE 2){
							form.user_id=arrpath[1];
							form.user_key=arrpath[2];
						}else{
							application.zcore.functions.zredirect('/');
						}
					}
					// don't try to login again if already logged in
					 db.sql="SELECT user_username, user_key, user_password 
					 FROM #db.table("user", request.zos.zcoreDatasource)# user 
					WHERE user_id = #db.param(form.user_id)# and 
					user_deleted = #db.param(0)# and 
					(user_server_administrator= #db.param(1)# or 
					site_id = #db.param(request.zos.globals.id)#) and 
					user_key = #db.param(form.user_key)# ";
					qE=db.execute("qE");
					if(qE.recordcount NEQ 0){
						form.e=qE.user_username;
						form.k=qE.user_key;
						if(isDefined('request.zsession.user.id') EQ false or request.zsession.user.id NEQ form.user_id){
							form.zusername=qE.user_username;
							form.zpassword=qE.user_password;
							inputStruct = StructNew();
							inputStruct.user_group_name = "user";
							inputStruct.noRedirect=true;
							inputStruct.disableSecurePassword=true;
							inputStruct.secureLogin=false;
							inputStruct.site_id = request.zos.globals.id;
							// perform check 
							application.zcore.user.checkLogin(inputStruct);
						}
					}
				}
			}

			// END REGULAR HANDLING

		}

		if(structkeyexists(request,'zEmailClickThrough')){
			if(arraylen(arrpath) GTE 6){
				ts=StructNew();
				if(mailUserType EQ false){
					ts.user_id=arrpath[1];
					ts.user_key=arrpath[2];
					ts.contact_id='';
					ts.contact_key='';
				}else{
					ts.user_id='';
					ts.user_key='';
					ts.contact_id=arrpath[1];
					ts.contact_key=arrpath[2];
				}
				ts.zemail_campaign_id=arrpath[3];
				ts.zemail_campaign_click_html=arrpath[4];
				ts.zemail_campaign_click_offset=arrpath[5]; // zero = opened email (logged via hidden image or after click)
				ts.zemail_campaign_click_ip=request.zos.cgi.remote_addr;
				ts.zemail_campaign_click_datetime=request.zOS.mysqlnow;
				form.zr="";
				for(i=6;i LTE arraylen(arrpath);i++){
					if(i NEQ 6){
						form.zr&='.'&arrpath[i];
					}else{
						form.zr&=arrpath[i];
					}
				}
				if(ts.zemail_campaign_id NEQ 0 and ts.zemail_campaign_id NEQ ""){
					if(isNumeric(ts.zemail_campaign_click_html) EQ false or isNumeric(ts.zemail_campaign_id) EQ false or (isNumeric(ts.contact_id) EQ false and isNumeric(ts.user_id) EQ false) or isNumeric(ts.zemail_campaign_click_offset) EQ false){
						writeoutput('Access Denied');
						application.zcore.functions.zabort();
					}
					// used to track conversions
					application.zcore.tracking.setEmailCampaign(ts.zemail_campaign_id);
					
					// set type 1=open, 2=unsubscribe, 3=bounce, 4=click, 5=conversion, 6=outofoffice, 7=temporaryBounce, 8=challengeresponse, 9=antispamBounce, 10=other/replies - bounce must be handled by checking failed account and return emails
					if(left(form.zr,10) EQ '/z/_eou'){
						ts.zemail_campaign_click_type=2;
					}else if(ts.zemail_campaign_click_offset EQ 0){
						ts.zemail_campaign_click_type=1; 
	
					}else{
						ts.zemail_campaign_click_type=4;
					}
					db.sql="INSERT INTO #db.table("zemail_campaign_click", request.zos.zcoreDatasource)#  
					SET zemail_campaign_click_type=#db.param(ts.zemail_campaign_click_type)#, 
					zemail_campaign_click_html=#db.param(ts.zemail_campaign_click_html)#, 
					zemail_campaign_click_offset=#db.param(ts.zemail_campaign_click_offset)#,
					 zemail_campaign_click_ip=#db.param(ts.zemail_campaign_click_ip)#, 
					 zemail_campaign_click_datetime=#db.param(ts.zemail_campaign_click_datetime)#,
					 zemail_campaign_id=#db.param(ts.zemail_campaign_id)#,
					 user_id=#db.param(ts.user_id)#, 
					zemail_campaign_click_updated_datetime=#db.param(request.zos.mysqlnow)#, 
					 contact_id=#db.param(ts.contact_id)#,
					 site_id=#db.param(request.zos.globals.id)#";
					db.execute("q"); 
				}
				if(ts.zemail_campaign_click_offset EQ 0){
					// output tracking image and abort();
					application.zcore.functions.zImageOutput(request.zos.installPath&'public/a/images/s.gif','image/gif');
				}else{
					application.zcore.functions.zredirect(replacenocase(replacenocase(form.zr, "http:/","http://","all"), "https:/","https://","all"));
				}
			}else{
				// invalid request - redirect to home page
				application.zcore.functions.zredirect('/');
			}
		}
		form.__zcoreinternalroutingpath=form.__zcoreinternalroutingpath_new;
		request.zos.scriptNameTemplate="/zcorerootmapping/#form.__zcoreinternalroutingpath#";
		if(len(form.__zcoreinternalroutingpath)-4 LTE 0){
			application.zcore.functions.z301redirect('/');	
		}
		if(left(form.__zcoreinternalroutingpath,3) EQ "mvc"){
			request.zos.cgi.script_name="/z/#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
		}else{
			request.zos.cgi.script_name="/z/_#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
		}
		</cfscript>
    </cffunction>
    
    
    
<cffunction name="zProcessURLRoute" localmode="modern" output="yes" returntype="any"><cfscript>
	var zemail='';
	var arrpath='';
	var qE='';
	var inputStruct='';
	var db=request.zos.queryObject;
	var ts='';
	var zOverrideTitle='';
	var zTemplates='';

	if(structkeyexists(form,'__zcoreinternalroutingpath') EQ false){
		application.zcore.functions.zRedirect('/');
	}
	if(right(form.__zcoreinternalroutingpath,4) EQ '.cfm' and fileexists(expandpath('/zcorerootmapping/'&form.__zcoreinternalroutingpath)) EQ false){
		application.zcore.functions.z301redirect('/');
	}
	if(left(form.__zcoreinternalroutingpath,2) EQ '-e'){
		key=mid(form.__zcoreinternalroutingpath,3,2);
		if(key EQ 'in'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/in.cfc';
			form.method="index";
		}else if(key EQ 'ou'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/out.cfc';
			form.method="index";
			request.zEmailUnsubscribe=true;
		}else if(key EQ 'rp'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
			form.method="index";
			form.npw=1;
		}else if(key EQ 'ce'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
			form.method="index";
			form.nea=1;
		}else if(key EQ 'pr'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/preference.cfc';
			form.method="form";
		}else if(key EQ 'vm'){
			form.__zcoreinternalroutingpath_new='mvc/z/user/controller/view.cfc';
			form.method="index";
			request.zEmailViewOnline=true;
		}else if(key EQ 'ck'){
			application.zcore.functions.zEndOfRunningScript();
			// url format
			// zemail.openImageUrl="#zemail.domain#/zcorerootmapping/_eck#user_id#.#user_key#.#arguments.ss.zemail_campaign_id#.1.0.cfm?zr="&URLEncodedFormat("/zcorerootmapping/a/images/s2.gif");
			request.zEmailClickThrough=true;
		}else{
			form.__zcoreinternalroutingpath_new='e/pref.cfm';
		}
		if(isDefined('request.zEmailViewOnline') or isDefined('request.zEmailUnsubscribe')){
			form.__zcoreinternalroutingpath=mid(form.__zcoreinternalroutingpath,5,len(form.__zcoreinternalroutingpath)-4);
			arrpath=listtoarray(form.__zcoreinternalroutingpath,'.');
			if(arraylen(arrpath) GTE 2){
				form.user_id=arrpath[1];
				form.zemail_campaign_id=arrpath[2];
				if(isDefined('request.zEmailViewOnline') and arraylen(arrpath) EQ 2){
					application.zcore.functions.zRedirect('/');
				}else{
					if(arraylen(arrpath) GTE 3 or isDefined('request.zEmailViewOnline')){
						form.user_key=arrpath[3];
					}else{
						form.user_key=false;	
					}
					if(arraylen(arrpath) GTE 4){
						form.zemail_template_type_id=arrpath[4];
						if(form.zemail_template_type_id EQ 3){
							if(arraylen(arrpath) GTE 5){
								form.mls_saved_search_id=arrpath[5];
							}
						}
					}
						
				}
				// don't try to login again if already logged in
				if(form.user_key NEQ false){
					 db.sql="SELECT user_username, user_key, user_password 
					 FROM #db.table("user", request.zos.zcoreDatasource)# user 
					WHERE user_id = #db.param(form.user_id)# and 
					user_deleted = #db.param(0)# and 
					((user_server_administrator= #db.param(1)# and 
					site_id=#db.param(Request.zos.globals.serverId)#) or 
					site_id = #db.param(request.zos.globals.id)#) and 
					user_key = #db.param(form.user_key)# ";
					qE=db.execute("qE");
					if(qE.recordcount NEQ 0){
						form.e=qE.user_username;
						form.k=qE.user_key;
						if(isDefined('request.zsession.user.id') EQ false or request.zsession.user.id NEQ form.user_id){
							form.zusername=qE.user_username;
							form.zpassword=qE.user_password;
							inputStruct = StructNew();
							inputStruct.user_group_name = "user";
							inputStruct.noRedirect=true;
							inputStruct.secureLogin=false;
							inputStruct.disableSecurePassword=true;
							inputStruct.site_id = request.zos.globals.id;
							// perform check 
							application.zcore.user.checkLogin(inputStruct);
						}
					}
				}
			}else{
				application.zcore.functions.zRedirect('/');
			}
			if(isDefined('request.zEmailUnsubscribe')){
				db.sql="INSERT INTO #db.table("zemail_campaign_click", request.zos.zcoreDatasource)#  
				SET zemail_campaign_click_type=#db.param(2)#, 
				zemail_campaign_click_html=#db.param(0)#, 
				zemail_campaign_click_offset=#db.param(0)#, 
				zemail_campaign_click_ip=#db.param(request.zos.cgi.remote_addr)#, 
				zemail_campaign_click_datetime=#db.param(request.zos.mysqlnow)#, 
				zemail_campaign_id=#db.param(form.zemail_campaign_id)#, 
				zemail_campaign_click_updated_datetime=#db.param(request.zos.mysqlnow)#, 
				user_id=#db.param(form.user_id)#,
				site_id=#db.param(request.zos.globals.id)#";
				db.execute("q"); 
				 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE user_id = #db.param(form.user_id)# and 
				user_deleted = #db.param(0)# and 
				((user_server_administrator= #db.param(1)# and 
				site_id=#db.param(Request.zos.globals.serverId)#) or 
				site_id = #db.param(request.zos.globals.id)#) ";
				qE=db.execute("qE");
				if(qE.recordcount EQ 0){
					application.zcore.functions.zRedirect('/z/user/out/index');
				}
				form.e=qE.user_username;
			}
		}else{
			if(structkeyexists(form,'user_id') EQ false or structkeyexists(form,'user_key') EQ false){
				// /z/_eck1.3423923.3.1.cfm
				form.__zcoreinternalroutingpath=mid(form.__zcoreinternalroutingpath,5,len(form.__zcoreinternalroutingpath)-4);
				arrpath=listtoarray(form.__zcoreinternalroutingpath,'.');
				if(arraylen(arrpath) GTE 2){
					form.user_id=arrpath[1];
					form.user_key=arrpath[2];
				}else{
					application.zcore.functions.zRedirect('/');
				}
			}
			// don't try to login again if already logged in
			db.sql="SELECT user_username, user_key, user_password FROM 
			#db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_id = #db.param(form.user_id)# and 
			((user_server_administrator= #db.param(1)# and 
			site_id=#db.param(Request.zos.globals.serverId)#) or 
			site_id = #db.param(request.zos.globals.id)#) and 
			user_deleted = #db.param(0)# and
			user_key = #db.param(form.user_key)# ";
			qE=db.execute("qE"); 
			if(qE.recordcount NEQ 0){
				form.e=qE.user_username;
				form.k=qE.user_key;
				if(isDefined('request.zsession.user.id') EQ false or request.zsession.user.id NEQ form.user_id){
					form.zusername=qE.user_username;
					form.zpassword=qE.user_password;
					inputStruct = StructNew();
					inputStruct.user_group_name = "user";
					inputStruct.noRedirect=true;
					inputStruct.secureLogin=false;
					inputStruct.disableSecurePassword=true;
					inputStruct.site_id = request.zos.globals.id;
					// perform check 
					application.zcore.user.checkLogin(inputStruct);
				}
			}
			if(structkeyexists(request,'zEmailClickThrough')){
				if(arraylen(arrpath) GTE 6 and isDefined('request.zsession.user.id')){
					ts=StructNew();
					ts.user_id=arrpath[1];
					ts.user_key=arrpath[2];
					ts.zemail_campaign_id=arrpath[3];
					ts.zemail_campaign_click_html=arrpath[4];
					ts.zemail_campaign_click_offset=arrpath[5]; // zero = opened email (logged via hidden image or after click)
					ts.zemail_campaign_click_ip=request.zos.cgi.remote_addr;
					ts.zemail_campaign_click_datetime=request.zos.mysqlnow;
					form.zr="";
					for(i=6;i LTE arraylen(arrpath);i++){
						if(i NEQ 6){
							form.zr&='.'&arrpath[i];
						}else{
							form.zr&=arrpath[i];
						}
					}
					if(isNumeric(ts.zemail_campaign_click_html) EQ false or isNumeric(ts.zemail_campaign_id) EQ false or isNumeric(ts.user_id) EQ false or isNumeric(ts.zemail_campaign_click_offset) EQ false){
						writeoutput('Access Denied');
						application.zcore.functions.zabort();
					}
					// used to track conversions
					application.zcore.tracking.setEmailCampaign(ts.zemail_campaign_id);
					
					// set type 1=open, 2=unsubscribe, 3=bounce, 4=click, 5=conversion, 6=outofoffice, 7=temporaryBounce, 8=challengeresponse, 9=antispamBounce, 10=other/replies - bounce must be handled by checking failed account and return emails
					if(left(form.zr,10) EQ '/zsa2/_eou'){ // kept for legacy behavior
						ts.zemail_campaign_click_type=2;
					}else if(left(form.zr,22) EQ '/zcorerootmapping/_eou'){
						ts.zemail_campaign_click_type=2;
					}else if(ts.zemail_campaign_click_offset EQ 0){
						ts.zemail_campaign_click_type=1; 
					}else{
						ts.zemail_campaign_click_type=4;
					}
					db.sql="INSERT INTO #db.table("zemail_campaign_click", request.zos.zcoreDatasource)#  
					SET zemail_campaign_click_type=#db.param(ts.zemail_campaign_click_type)#, 
					zemail_campaign_click_html=#db.param(ts.zemail_campaign_click_html)#, 
					zemail_campaign_click_offset=#db.param(ts.zemail_campaign_click_offset)#, 
					zemail_campaign_click_ip=#db.param(ts.zemail_campaign_click_ip)#, 
					zemail_campaign_click_datetime=#db.param(ts.zemail_campaign_click_datetime)#, 
					zemail_campaign_id=#db.param(ts.zemail_campaign_id)#, 
					user_id=#db.param(ts.user_id)#, 
					zemail_campaign_click_updated_datetime=#db.param(request.zos.mysqlnow)#,
					site_id=#db.param(request.zos.globals.id)#";
					db.execute("q"); 
					if(ts.zemail_campaign_click_offset EQ 0){
						// output tracking image and abort
						application.zcore.functions.zImageOutput(request.zos.globals.serverhomedir&'/a/images/s.gif','image/gif');
					}else{
						application.zcore.functions.zRedirect(replacenocase(replacenocase(form.zr,'http:/','http://'),'http:///','http://'));
					}
				}else{
					// invalid request - redirect to home page
					application.zcore.functions.zRedirect('/');
				}
			}
		}
		form.__zcoreinternalroutingpath=form.__zcoreinternalroutingpath_new;
		request.zos.tempScriptInclude="/zcorerootmapping/#form.__zcoreinternalroutingpath#";
		if(len(form.__zcoreinternalroutingpath)-4 LTE 0){
			application.zcore.functions.z301redirect('/');	
		}
		request.cgi_script_name="/z/_#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
	}else{
		request.zos.tempScriptInclude="/zcorerootmapping/#form.__zcoreinternalroutingpath#";
		if(len(form.__zcoreinternalroutingpath)-4 LTE 0){
			application.zcore.functions.z301redirect('/');	
		}
		request.cgi_script_name="/z/_#left(form.__zcoreinternalroutingpath,len(form.__zcoreinternalroutingpath)-4)#";
		Request.zOS.forceScriptName=request.zos.tempScriptInclude;
		if(find(","&left(form.__zcoreinternalroutingpath,4)&",", ',com/,') NEQ 0){
			request.zos.iscfc=true;
			Request.zOS.forceScriptName=listgetat(Request.zOS.forceScriptName,1,";");
			if(right(request.zos.forceScriptName,4) NEQ ".cfc"){
				request.zos.forceScriptName=request.zos.forceScriptName&".cfc";
			}
		}else if(find(","&left(form.__zcoreinternalroutingpath,2)&",", ',e/,') NEQ 0){
			// path is ok continue...
		}else{
			// server admin access denied - redirect to home page
			application.zcore.functions.zredirect('/');
		}
	}
	if(structkeyexists(request.zos,'iscfc') and structkeyexists(form,'method') and right(Request.zOS.forceScriptName,4) EQ '.cfc'){
		//application.zcore.template.prependErrorContent("There was an error while creating the component: #Request.zOS.forceScriptName#.");
		request.zos.tempcom=application.zcore.functions.zcreateobject("component",replace(replace(mid(Request.zOS.forceScriptName,2,len(Request.zOS.forceScriptName)-5),"\",".","ALL"),"/",".","ALL"), true);
		//application.zcore.template.replaceErrorContent("");
		if(structkeyexists(request.zos.tempcom,form.method) EQ false){
			application.zcore.template.fail("Method, #db.param(form.method)#, doesn't exist in #Request.zOS.forceScriptName#.");
		}
		request.zos.tempcommeta=GetMetaData(request.zos.tempcom[form.method]);
		if(request.zos.tempcommeta.access NEQ 'remote'){
			application.zcore.template.fail("Method, #db.param(form.method)#, doesn't allow 'remote' access in #Request.zOS.forceScriptName#. Access is set to '#request.zos.tempcommeta.access#'");
		}
		if(structkeyexists(request.zos.tempcommeta,'roles') and request.zos.tempcommeta.roles NEQ ""){
			if(request.zos.tempcommeta.roles NEQ "user"){
				request.zos.inMemberArea=true;
				application.zcore.skin.disableMinCat();
			}
			request._tempLoginRoles=request.zos.tempcommeta.roles;
			request._tempLoginSkip=false;
			if(request.zos.tempcommeta.roles EQ 'serveradministrator'){
				if(application.zcore.user.checkServerAccess()){
					request._tempLoginSkip=true;
				}else{
					request._tempLoginRoles="member";
				}
			}else if(request.zos.tempcommeta.roles EQ 'siteadministrator'){
				if(application.zcore.user.checkSiteAccess()){
					request._tempLoginSkip=true;
				}else{
					request._tempLoginRoles="member";
				}
			}
			if(request._tempLoginSkip EQ false){
				request.disableShareThis=true;
				inputStruct = StructNew();
				inputStruct.user_group_name=request._tempLoginRoles;
				if(request.zos.globals.requireSecureLogin EQ 1){
					inputStruct.secureLogin=true;
				}else{
					inputStruct.secureLogin=false;
				}
				inputStruct.noRedirect=false;
				inputStruct.site_id = request.zos.globals.id;
				application.zcore.user.setCustomTable(false);
				application.zcore.user.checkLogin(inputStruct); 
				application.zcore.template.setTemplate("zcorerootmapping.templates.administrator",true,true);
			}
		}
		request.zos.tempcom[form.method]();
	}else{
		cfinclude(template="/zcorerootmapping/#form.__zcoreinternalroutingpath#");
	}
	</cfscript></cffunction>



<cffunction name="generateModProxyRewriteRules" localmode="modern" output="yes" returntype="any">
	<cfargument name="theC" type="string" required="yes">
	<cfargument name="proxyURL" type="string" required="yes">
	<cfscript>
    
    arguments.theC=replace(arguments.theC,chr(13),"","all");
    arguments.theC=replace(arguments.theC,chr(9)," ","all");
    arguments.theC=replace(arguments.theC,chr(10)&chr(10),chr(10),"all");
    arguments.theC=replace(arguments.theC,chr(10)&chr(10),chr(10),"all");
    a1=listtoarray(arguments.theC,chr(10));
    b="/";
    c2="";
    r=arraynew(1);
    for(i=1;i LTE arraylen(a1);i++){
		a1[i]=replace(a1[i],"\\",chr(10),"all");
		a1[i]=replace(a1[i],"\ ",chr(9),"all");
        a2=listtoarray(trim(a1[i])," ",false);
		for(i4=1;i4 LTE arraylen(a2);i4++){
			a2[i4]=replace(replace(a2[i4],chr(10),"\\","all"),chr(9),"\ ","all");	
		}
        c="";
        if(arraylen(a2) NEQ 0){
            if(a2[1] CONTAINS "RewriteEngine") continue;
            if(a2[1] CONTAINS "RewriteMap") continue;
            if(a2[1] CONTAINS "RewriteBase"){
                continue;
            }else if(left(trim(a1[i]),1) EQ "##" or a2[1] CONTAINS "RewriteCond"){
				c2=a1[i]&chr(10);
				
                arrayappend(r, c2);
            }else if(a2[1] CONTAINS "RewriteRule"){
                arraydeleteat(a2, 1);
                if(left(trim(a2[1]),1) EQ "^"){
                    a2[1]=replace(a2[1],"^","^"&b,"one");
                }else{
                    a2[1]=b&a2[1];
                }
				if(left(a2[1],2) EQ "//"){
                	a2[1]=replace(a2[1],"//","/","one");
				}
                a2[2]=b&a2[2];
                    c&=chr(10)&'RewriteRule '&a2[1]&' ';
                a2[2]=replace(a2[2],"//","/","all");
                a2[2]=replace(a2[2],"/http:/","http://","all");
                a2[2]=replace(a2[2],"/https:/","https://","all");
				if(trim(a2[2]) EQ "/-"){
					a2[2]="-";	
				}
                if(arraylen(a2) EQ 2){
                	arrayappend(a2,'[L,QSA]');
				}
				if(a2[3] CONTAINS "R=301"){
                    // 301
                    c&=a2[2]&' [L,R=301,QSA]'&chr(10);
                }else{
                    t2=replace(a2[2],"\?","","ALL");
                    a3=listtoarray(t2,"?");
                    if(a2[3] CONTAINS "P," or (a2[3] CONTAINS ",P" and a2[3] DOES NOT CONTAIN ",PT") or a3[1] CONTAINS ".cfm" or a3[1] CONTAINS ".cfc"){
                        // passthrough coldfusion	
                        c&=' '&arguments.proxyURL&a2[2]&' [L,P,QSA]'&chr(10);
                    }else{
                        // static or non-cfml proxy
                        c&=' '&a2[2]&' '&a2[3]&chr(10);
                    }
                }
                arrayappend(r, c);
            }else{
                application.zcore.template.fail('Unknown rewriterule: '&a1[i]&'<br />');	
            }
        }
    }
    return arraytolist(r,"")&chr(10);
    </cfscript>
</cffunction>


<cffunction name="initRewriteRuleApplicationStruct" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	
	var ts=arguments.ss;
	var row=0;
	t9=structnew();
	ts2=structnew();
	ts2.uniqueURLStruct=structnew();
	ts2.reservedAppUrlIdStruct=structnew();
	t9.urlStruct=structnew();
	
	
	this.convertRewriteToStruct(ts2);
	

	application.zcore.siteOptionCom.setURLRewriteStruct(ts2);

	
	// loop apps and call the function with ts sharedstruct
	 db.sql="SELECT app.app_id, app_x_site.site_id 
	 FROM #db.table("app", request.zos.zcoreDatasource)# app, 
	 #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	WHERE app_x_site.site_id = #db.param(request.zos.globals.id)# and 
	app.app_built_in=#db.param(0)# and 
	app_x_site.app_x_site_status = #db.param('1')# and 
	app_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and
	app.app_id=app_x_site.app_id ";
	qApps=db.execute("qApps");
	for(row in qApps){
		configCom=application.zcore.functions.zcreateobject("component",application.zcore.appComPathStruct[row.app_id].cfcPath, true);
		configCom.setURLRewriteStruct(row.site_id,ts2);
	}
	
	if(fileexists(request.zos.globals.homedir&"index.cfc")){
		t9.scriptName="/index.cfc";
		t9.urlStruct.method="index";
	}else if(fileexists(request.zos.globals.homedir&"index.cfm")){
		t9.scriptName="/index.cfm";
	}else if(fileexists(request.zos.globals.homedir&"content/index.cfm")){
		t9.scriptName="/content/index.cfm";
	}else if(fileexists(request.zos.globals.homedir&"home/index.cfm")){
		t9.scriptName="/home/index.cfm";
	}else if(fileexists(request.zos.globals.homedir&"index.html")){
		t9.scriptName="/index.html";
	}else{
		t9.scriptName="";
	}
	if(t9.scriptName NEQ ""){
		ts2.uniqueURLStruct["/"]=t9;
	}
	ts.urlRewriteStruct=ts2;
	</cfscript>
</cffunction>


<cffunction name="deleteSiteOptionGroupSetUniqueURL" localmode="modern" output="yes" returntype="any">
	<cfargument name="site_x_option_group_set_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoredatasource)# site_x_option_group_set
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	site_x_option_group_set_id = #db.param(arguments.site_x_option_group_set_id)# ";
	qS=db.execute("qS");
	if(qS.recordcount NEQ 0){
		if(qS.site_x_option_group_set_override_url NEQ ""){
			structdelete(application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct, trim(qS.site_x_option_group_set_override_url));
		}
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateSiteOptionGroupSetUniqueURL" localmode="modern" output="yes" returntype="any">
	<cfargument name="site_x_option_group_set_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoredatasource)# site_x_option_group_set
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	site_x_option_group_set_id = #db.param(arguments.site_x_option_group_set_id)# and 
	site_x_option_group_set.site_x_option_group_set_approved=#db.param(1)# ";
	qS=db.execute("qS");
	if(qS.recordcount NEQ 0){
		t9=structnew();
		t9.scriptName="/z/misc/display-site-option-group/index";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/index";
		t9.urlStruct.site_x_option_group_set_id=qS.site_x_option_group_set_id;
		application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct[trim(qS.site_x_option_group_set_override_url)]=t9;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="deleteFeatureSchemaSetUniqueURL" localmode="modern" output="yes" returntype="any">
	<cfargument name="feature_data_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="select * from #db.table("feature_data", "jetendofeature")# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	feature_data_deleted = #db.param(0)# and
	feature_data_master_set_id = #db.param(0)# and 
	feature_data_id = #db.param(arguments.feature_data_id)# ";
	qS=db.execute("qS");
	if(qS.recordcount NEQ 0){
		if(qS.feature_data_override_url NEQ ""){
			structdelete(application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct, trim(qS.feature_data_override_url));
		}
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateFeatureSchemaSetUniqueURL" localmode="modern" output="yes" returntype="any">
	<cfargument name="feature_data_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="select * from #db.table("feature_data", "jetendofeature")# feature_data
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	feature_data_deleted = #db.param(0)# and
	feature_data_master_set_id = #db.param(0)# and 
	feature_data_id = #db.param(arguments.feature_data_id)# and 
	feature_data_override_url<>#db.param("")# and 
	feature_data.feature_data_approved=#db.param(1)# ";
	qS=db.execute("qS");
	if(qS.recordcount NEQ 0){
		t9=structnew();
		t9.scriptName="/z/feature/feature-display/index";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/feature/feature-display/index";
		t9.urlStruct.feature_data_id=qS.feature_data_id;
		application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct[trim(qS.feature_data_override_url)]=t9;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="processInternalURLRewrite" localmode="modern" output="yes" returntype="any">
	<cfargument name="theURL" type="string" required="yes">
	<cfscript>
	
	newScriptName="";
	isDir=false;
	entireURL=trim(arguments.theURL);
	if(structkeyexists(form, 'zdebugurl') EQ false or form.zdebugurl EQ false){
		zdebugurl=false;
	}else{
		zdebugurl=form.zdebugurl;
	} 
	if(newScriptName EQ ""){
		if(structkeyexists(application.sitestruct[request.zos.globals.id],'zcorecustomfunctions') and structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'processURL')){
			tempVar=application.sitestruct[request.zos.globals.id].zcorecustomfunctions.processURL(arguments.theURL, true);
			if(tempVar.scriptName NEQ ""){
				newScriptName=tempVar.scriptName;
				if(zdebugurl){
					writeoutput('zcorecustomfunctions match:'&newScriptName&'<br />');
				}
			}
		}
	}
	if(newScriptName EQ ""){
		if(structkeyexists(application.zcore.urlRewriteStruct.redirectStruct, entireURL)){
			tempVar=application.zcore.urlRewriteStruct.redirectStruct[entireURL];
			if(structkeyexists(tempVar, 'urlStruct')){
				structappend(form, tempVar.urlStruct, true);
			}
			structdelete(form, request.zos.urlRoutingParameter);
			structdelete(form, 'fieldnames');
			structdelete(form, 'zdebugurl');
			arrU=[];
			for(i in form){
				if(isSimpleValue(form[i])){
					arrayappend(arrU, lcase(i)&"="&urlencodedformat(form[i]));
				}
			}
			tempLink=tempVar.url;
			if(arraylen(arrU)){
				tempLink&="?"&arraytolist(arrU, "&");	
			}
			if(zdebugurl){
				writeoutput('server redirectStruct match1<br />'&tempLink);
				application.zcore.functions.zabort();
			}else{
				application.zcore.functions.z301redirect(tempLink);
			}
		}
		if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct,'customRules')){
			if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.redirectStruct, entireURL)){
					if(zdebugurl) writeoutput('customRules.redirectStruct match<br />');
				application.zcore.functions.z301redirect(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.redirectStruct[entireURL]);	
			}
			if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.uniqueStruct, entireURL)){
				if(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.uniqueStruct[entireURL].cfml){
					if(zdebugurl) writeoutput('customRules.uniqueStruct match<br />');
					// set vars	
					structappend(form, application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.uniqueStruct[entireURL].vs, true);
					newScriptName=application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.uniqueStruct[entireURL].url;
				}else{
					path=application.zcore.functions.zGetDomainInstallPath(application.zcore.functions.zvar("shortDomain", request.zos.globals.id))&removechars(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.uniqueStruct[entireURL].url,1,1);
					writeoutput(application.zcore.functions.zreadfile(path));
					application.zcore.functions.zabort();
				}
			}
			for(i in application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.wildcardRedirectStruct){
				if(compare(left(entireURL, len(i)), i) EQ 0){
					application.zcore.functions.z301redirect(application.sitestruct[request.zos.globals.id].urlRewriteStruct.customRules.wildcardRedirectStruct[i]);
				}
			}
		}
		
		if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct, entireURL)){
			backupOriginal=form[request.zos.urlRoutingParameter];
			if(zdebugurl) writeoutput("unique url match:"&entireURL&"<br />");
			if(zdebugurl) writedump(application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct[entireURL]);
			curApp=application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct[entireURL];
			if(right(curApp.scriptName,5) EQ ".html"){
				writeoutput(application.zcore.functions.zreadfile(request.zos.globals.homedir&removeChars(curApp.scriptName,1,1)));
				application.zcore.functions.zabort();
			}
			structappend(url,  curApp.urlStruct, true);
			structappend(form, curApp.urlStruct, true);
			newScriptName=curApp.scriptName;
			form[request.zos.urlRoutingParameter]=backupOriginal;
			if(entireURL EQ "/" and request.zos.globals.id EQ request.zos.globals.serverId){
				request.zos.scriptNameTemplate="zcorerootmapping/"&removechars(newScriptName,1,1);
				if(structkeyexists(form,'method') EQ false){
					form.method="index";
				}
			}
		}else{
			if(right(entireURL, 5) EQ ".html"){
				ext="html";
			}else if(right(entireURL, 4) EQ ".xml"){
				ext="xml";	
			}else if(right(entireURL, 4) EQ ".cfm"){
				ext="cfm";	
			}else{
				ext="";	
			}
			if(zdebugurl) writeoutput("ext:"&ext&"<br />");
			if(left(entireURL, 5) EQ "/z/_e"){
				form.__zcoreinternalroutingpath=mid(entireURL,5, len(entireURL)-4)&".cfm";
				newScriptName=entireURL;
				if(zdebugurl) writeoutput(form.__zcoreinternalroutingpath&"|1<br />");
				
			}else if(left(entireURL, 7) EQ "/z/_com"){
				form.__zcoreinternalroutingpath=mid(entireURL,5, len(entireURL)-4)&".cfc";
				if(zdebugurl) writeoutput(form.__zcoreinternalroutingpath&"|2<br />");
				newScriptName=entireURL;
			}else if(left(entireURL, 6) EQ "/z/-vl"){
				form.__zcoreinternalroutingpath="-"&mid(entireURL,5, len(entireURL)-4);
				newScriptName=entireURL; 
			}else if(left(entireURL, 6) EQ "/z/-vf"){
				form.__zcoreinternalroutingpath="-"&mid(entireURL,5, len(entireURL)-4);
				newScriptName=entireURL;
				if(zdebugurl) writeoutput(form.__zcoreinternalroutingpath&"|4<br />");
			}else if(left(entireURL, 6) EQ "/z/-df"){
				form.__zcoreinternalroutingpath="-"&mid(entireURL,5, len(entireURL)-4);
				newScriptName=entireURL;
				if(zdebugurl) writeoutput(form.__zcoreinternalroutingpath&"|4<br />");
			}else if(left(entireURL, 5) EQ "/z/-e"){
				form.__zcoreinternalroutingpath="-"&mid(entireURL,5, len(entireURL)-4);
				newScriptName=entireURL;
				if(zdebugurl) writeoutput(form.__zcoreinternalroutingpath&"|3<br />");
			}else if(right(entireURL,1) EQ "/"){
				tempPath=Request.zOSHomeDir&removeChars(entireURL,1,1);
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath&"index.cfm") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.cfm"]=fileexists(tempPath&"index.cfm");
				} 
				
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath&"index.cfc") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.cfc"]=fileexists(tempPath&"index.cfc");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath&"index.htm") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.htm"]=fileexists(tempPath&"index.htm");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath&"index.html") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.html"]=fileexists(tempPath&"index.html");
				}
				if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.cfm"]){
					newScriptName=entireURL&"index.cfm";
					request.zos.scriptNameTemplate=request.zRootPath&removechars(newScriptName,1,1);
					form.__zcoreinternalroutingpath="";
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.cfc"]){
					newScriptName=entireURL&"index.cfc";
					request.zos.scriptNameTemplate=request.zRootPath&removechars(newScriptName,1,1);
					form.__zcoreinternalroutingpath="";
					if(structkeyexists(form,'method') EQ false){
						form.method="index";
					}
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.htm"]){
					writeoutput(application.zcore.functions.zreadfile(request.zos.globals.homedir&removeChars(entireURL,1,1)&"index.htm"));
					abort;
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.html"]){
					writeoutput(application.zcore.functions.zreadfile(request.zos.globals.homedir&removeChars(entireURL,1,1)&"index.html"));
					abort;
				}else{
					
					// if(request.zos.themePath NEQ ""){
					// 	newScriptName=request.zos.themePath&"index.cfc";
					// 	request.zos.scriptNameTemplate=request.zos.themePath&removechars(newScriptName,1,1);
					// 	form.__zcoreinternalroutingpath="";
					// 	if(structkeyexists(form,'method') EQ false){
					// 		form.method="index";
					// 	}
					// }else{
						isDir=true;
					// }
				}
				if(zdebugurl) writeoutput('got in4:'&entireURL&"<br />");
			}else if(ext EQ "cfm" or ext EQ "cfc"){
				tempPath=Request.zOSHomeDir&removeChars(entireURL,1,1);
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath) EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath]=fileexists(tempPath);
				}
				if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath]){
					newScriptName=entireURL;
					request.zos.scriptNameTemplate=request.zRootPath&removechars(newScriptName,1,1);
					form.__zcoreinternalroutingpath="";
					if(structkeyexists(form,'method') EQ false){
						form.method="index";
					}
				}else{
					if(zdebugurl){
						writeoutput(expandpath(entireURL)&"| was 404 - second one<br />");
						application.zcore.functions.zabort();
					}else{
						application.zcore.functions.z404("processInternalURLRewrite(): "&expandpath(entireURL)&"| was 404 - second one<br />");
					}
				}
			}else if(ext EQ "html" or ext EQ "xml"){
				if(ext EQ "html"){
					arrT=listtoarray(left(entireURL, len(entireURL)-5), "-",true);
				}else{
					arrT=listtoarray(left(entireURL, len(entireURL)-4), "-",true);
				}
				count=arraylen(arrT);
				if(zdebugurl) writeoutput('got in3:'&entireURL&"<br />");
				urlMatched=false;
				if(count GTE 3){
					// check for title-1-2
					dataId=arrT[count];
					appId=arrT[count-1];
					arraydeleteat(arrT,count);
					arraydeleteat(arrT,count-1);
					urlTitle=removechars(arraytolist(arrT,"-"),1,1);
					
					if(zdebugurl) writeoutput('dataID:'&dataID&'<br />appId:'&appId&'<br />urlTitle:'&urlTitle&'<br />');
					if(zdebugurl) writeoutput('got in2:'&entireURL&"<br />");
					if(structkeyexists(application.sitestruct[request.zos.globals.id].urlRewriteStruct.reservedAppUrlIdStruct, appId)){
						if(zdebugurl) writeoutput('got in:'&entireURL&"<br />");
						
						if(zdebugurl) writedump(application.sitestruct[request.zos.globals.id].urlRewriteStruct.reservedAppUrlIdStruct[appId]);
						
						for(n=1;n LTE arraylen(application.sitestruct[request.zos.globals.id].urlRewriteStruct.reservedAppUrlIdStruct[appId]);n++){
							curApp=application.sitestruct[request.zos.globals.id].urlRewriteStruct.reservedAppUrlIdStruct[appId][n];
							newScriptName=curApp.scriptName;
							if(structkeyexists(curApp, 'ifStruct')){
								// test conditions - it doesn't match, then continue;
								ifMatch=true;
								for(i2 in curApp.ifStruct){
                                     if(curApp.type EQ 3){ 
                                          if(listGetAt(local[i2], 1, '_') NEQ curApp.ifStruct[i2]){ 
                                               ifMatch=false; 
                                               break; 
                                          } 
                                     }else{ 
                                          if(local[i2] NEQ curApp.ifStruct[i2]){ 
                                               ifMatch=false; 
                                               break; 
                                          } 
                                     }
								}
								if(ifMatch EQ false){
									continue;
								}
							}
							if(curApp.type EQ 1){
								// numeric
								if(isNumeric(dataId)){
									urlMatched=true;	
								}
							}else if(curApp.type EQ 2){
								// alphanumeric (including other punctuation like underscore - always match
								urlMatched=true;
							}else if(curApp.type EQ 3){
								// numeric with optional pagenav
								arrDataId=listToArray(dataId,"_");
								dataIdCount=arraylen(arrDataId);
								if(dataIdCount EQ 1){
									dataId=arrDataId[1];
									urlMatched=true;	
								}else if(dataIdCount EQ 2){
									// has pagenav set
									dataId=arrDataId[1];
									dataId2=arrDataId[2];
									urlMatched=true;	
								}else{
									// unknown multiple page nav or other
								}
							}else if(curApp.type EQ 4){
								// blog archive date
								if(count GTE 5){
									tempYear=arrT[count-3];
									tempMonth=arrT[count-2];
									if(len(tempYear) EQ 4 and len(tempMonth) EQ 2 and isNumeric(tempYear) and isNumeric(tempMonth)){
										dataId2=tempYear&"-"&tempMonth;
										urlMatched=true;	
									}
								}
							}else if(curApp.type EQ 5){
								// rental photo url
								if(count GTE 5){
									if(arrT[count-3] EQ "Photo"){
										dataId2=arrT[count-2];
										urlMatched=true;
									}
								}
							}else if(curApp.type EQ 6){
								// 2 numerics with optional pagenav
								arrDataId=listToArray(dataId,"_");
								dataIdCount=arraylen(arrDataId);
								if(dataIdCount EQ 2){
									dataId=arrDataId[1];
									dataId2=arrDataId[2];
									urlMatched=true;	
								}else if(dataIdCount EQ 3){
									// has pagenav set
									dataId=arrDataId[1];
									dataId2=arrDataId[2];
									dataId3=arrDataId[3];
									urlMatched=true;	
								}else{
									// unknown multiple page nav or other
								}
							}
							if(urlMatched){ 
								if(zdebugurl) writeoutput('Matched: '&n&'<br />');
								// copy urlStruct to url
								structappend(form,  curApp.urlStruct, true);
								structappend(form, curApp.urlStruct, true);
								for(i2 in curApp.mapStruct){
									if(structkeyexists(local, i2)){
										form[curApp.mapStruct[i2]]=local[i2];
									}else{
										if(zdebugurl) writedump(i2&' doesn''t exist<br />');
									}
								}
								if(zdebugurl) writedump(form);
								break;
							}
						}
					}
				}else{
					// some other kind of url	
				}
				if(urlMatched EQ false){
					// unknown url
					if(zdebugurl){
						writeoutput('not matched:'&entireURL&'<br />');
					}
				}else{
					if(zdebugurl){
						writedump(form);
						writeoutput('advanced match:'&newScriptName&'<br />');
					}
				}
			}
		}
	}
	//writedump(application.sitestruct[request.zos.globals.id].urlRewriteStruct);
	if(newScriptName EQ ""){
		if(structkeyexists(application.sitestruct[request.zos.globals.id],'zcorecustomfunctions') and structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'processURL')){
			tempVar=application.sitestruct[request.zos.globals.id].zcorecustomfunctions.processURL(arguments.theURL, false);
			if(tempVar.scriptName NEQ ""){
				newScriptName=tempVar.scriptName;
				if(zdebugurl){
					writeoutput('zcorecustomfunctions match:'&newScriptName&'<br />');
				}
			}
		}
	}
	if(newScriptName EQ ""){
		tempPath=Request.zOSHomeDir&removeChars(entireURL,1,1);
		if(structkeyexists(application.sitestruct[request.zos.globals.id].directoryExistsCache, tempPath) EQ false){
			try{
				application.sitestruct[request.zos.globals.id].directoryExistsCache[tempPath]=directoryexists(tempPath);
			}catch(Any e){
				application.zcore.functions.z404("#tempPath# is not an accessible directory.");
			}
		}
		if(application.sitestruct[request.zos.globals.id].directoryExistsCache[tempPath]){
			if(right(entireURL,1) NEQ "/"){
				tempPath=Request.zOSHomeDir&removeChars(entireURL,1,1)&"/";
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath&"index.cfm") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.cfm"]=fileexists(tempPath&"index.cfm");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath&"index.cfc") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.cfc"]=fileexists(tempPath&"index.cfc");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath&"index.php") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.php"]=fileexists(tempPath&"index.php");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath&"index.htm") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.htm"]=fileexists(tempPath&"index.htm");
				}
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath&"index.html") EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.html"]=fileexists(tempPath&"index.html");
				}
				// might still have .cfm or .cfc index
				if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.cfm"]){
					newPath=entireURL&"/";
					application.zcore.functions.z301redirect(newPath);
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.cfc"]){
					newPath=entireURL&"/";
					application.zcore.functions.z301redirect(newPath);
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.php"]){
					newPath=entireURL&"/";
					application.zcore.functions.z301redirect(newPath);
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.htm"]){
					newPath=entireURL&"/";
					application.zcore.functions.z301redirect(newPath);
				}else if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath&"index.html"]){
					newPath=entireURL&"/";
					application.zcore.functions.z301redirect(newPath);
				}else{
					// application.zcore.functions.z404("processInternalURLRewrite() newScriptName was empty and there was no default index file");
				}
			}else{
				application.zcore.functions.z404("processInternalURLRewrite() newScriptName was empty and this is not a directory.");
			}
		}else{
			newScriptName=arguments.theURL;
		}
	}
	if(newScriptName EQ ""){
		if(zdebugurl){
			writeoutput('unknown url:'&entireURL&'<br />');
			application.zcore.functions.zabort();
		}
	}else{
		if(request.zos.isDeveloper){
			if(zdebugurl){
				writedump(url);//, true, 'simple');
				writedump(cgi);//, true, 'simple');
				
				writeoutput('going to be this url:'&newScriptName&'<br />');
				
			}
		}
		request.zos.scriptNameTemplate=newScriptName;
	}
	//n=c;
	if(zdebugurl){
		writeoutput("original:"&entireURL&"<br />translated:"&newScriptName&"<br />__zcoreinternalroutingpath:"&application.zcore.functions.zso(form, '__zcoreinternalroutingpath'));
		writeoutput('<hr />');
	}
	return newScriptName;
	
	</cfscript>
    
</cffunction>
    


<cffunction name="convertRewriteToStruct" localmode="modern" output="no" returntype="any"><cfargument name="sharedStruct" type="struct" required="yes"><cfscript>
	
	var db=request.zos.queryObject;
	 db.sql="SELECT site.site_domain, rewrite_rule.* FROM #db.table("site", request.zos.zcoreDatasource)# site, 
	 #db.table("rewrite_rule", request.zos.zcoreDatasource)# rewrite_rule 
	WHERE site.site_id = rewrite_rule.site_id AND site.site_active= #db.param(1)# and 
	rewrite_rule_deleted = #db.param(0)# and 
	site_deleted = #db.param(0)# and 
	CONCAT(rewrite_rule_image,rewrite_rule_zsa, rewrite_rule_site) <> #db.param('')# and 
	site.site_id = #db.param(request.zos.globals.id)#";
	qR=db.execute("qR");
	specialRuleStruct=structnew();
	totalSpecialCount=0;
	loop query="qR"{
		rzsa=replacelist(rereplace(qR.rewrite_rule_zsa, "##[^\n]*","","all"),'^,\',',');
		rsite=replacelist(rereplace(qR.rewrite_rule_site, "##[^\n]*","","all"),'^,\',',');
		rimage=replacelist(rereplace(qR.rewrite_rule_image, "##[^\n]*","","all"),'^,\',',');
		arrR=arraynew(1);
		arrayappend(arrR,listtoarray(rzsa,chr(10),false));
		arrayAppend(arrR,listtoarray(rsite,chr(10),false));
		arrayAppend(arrR,listtoarray(rimage,chr(10),false));
		
		ts=structnew();
		ts.redirectStruct=structnew();
		ts.wildcardRedirectStruct=structnew();
		ts.wildcardSpecialStruct=structnew();
		ts.uniqueStruct=structnew();
		ts.requestStruct=structnew();
		
		
		tempSkipURL=structnew();
		tempSkipURL["/(.*(.gif|.jpg|.png|.css|.js))"]=true;
		tempSkipURL["/livezilla/.*"]=true;
		tempSkipURL["/(.*)/(.*).html"]=true;
		//tempSkipURL["/(.*).html"]=true;
		//tempSkipURL[""]=true;
	
		for(n=1;n LTE arraylen(arrR);n++){
			for(i=1;i LTE arraylen(arrR[n]);i++){
				// detect rewrite rule type
				cur=trim(arrR[n][i]);
				if(cur EQ "") continue;
				a301=false;
				aProxy=false;
				aWildCard=false;
				aWildCard2=false;
				aCFML=false;
				if(right(cur,10) CONTAINS 'R=301'){
					a301=true;
				}
				if(right(cur,10) CONTAINS ',P' or right(cur,10) CONTAINS 'P,' or right(cur,10) CONTAINS '[P' or right(cur,10) CONTAINS 'P]'){
					aProxy=true;
				}
				if(left(cur, len("RewriteRule")) EQ "RewriteRule"){
					cur="/"&removechars(cur, 1, len("RewriteRule")+1);
					arrC=listtoarray(cur, "$", true);
					newCount=arraylen(arrC);
					arrC[1]=trim(arrC[1]);
					if(right(arrC[1],2) EQ ".*"){
						aWildCard=true;
					}else if(arrC[1] CONTAINS ".*" or arrC[1] CONTAINS "[" or arrC[1] CONTAINS "*"){
						aWildCard2=true;	
					}
					sUrl=arrC[1];
					if(structkeyexists(tempSkipURL, sUrl)){
						continue;	
					}
					arraydeleteat(arrC,1);
					dUrl=arraytolist(arrC,"$");
					if(newCount GTE 2){
						pos=find("[", dUrl);
						if(pos NEQ 0){
							dUrl=left(dUrl, pos-1);
						}
						dUrl=trim(dUrl);
						if(left(dUrl,4) EQ "http"){
							// don't change url
						}else if(left(dUrl,1) NEQ "/"){
							dUrl="/"&dUrl;
						}
					// }else{
					// 	writeoutput('Broken url:'&cur&'<br />');	
					}
					if(dUrl EQ "/-"){
						dUrl="-";
					}
					if(dUrl CONTAINS ".cfm" or dUrl CONTAINS ".cfc"){
						aCFML=true;
					}
					if(aWildCard2){
						// writeoutput('special rule: '&sUrl&' | '&cur&'<br />');
						ts.wildcardSpecialStruct[sUrl]=dUrl;
					}else{
						if(a301){
							if(aWildCard){
								//writeoutput('wildcard: ');
								ts.wildcardRedirectStruct[left(sUrl,len(sUrl)-2)]=dUrl;
							}else{
								ts.redirectStruct[sUrl]=dUrl;
							}
						}else{
							if(aWildCard){
								application.zcore.template.fail('requestStruct is never used - wildcard: probably needs to be removed: '&sUrl&"<br />"&dUrl);
								t9=structnew();
								t9.url=dUrl;
								t9.cfml=aCFML;
								ts.requestStruct[sUrl]=t9;
								// writeoutput(' map '&sUrl&' to '&dUrl&'<br />');
							}else{
								t9=structnew();
								t9.url=replacelist(dUrl,"$1,$2,$3,$4,$5,$6",",,,,,");
								t9.cfml=aCFML;
								t9.vs=structnew();
								arrT=listtoarray(t9.url,"?");
								t9.url=arrT[1];
								//writeoutput(' setup unique '&sUrl&' to '&dUrl&'<br />');
								if(arraylen(arrT) EQ 2){
									arrTF=listtoarray(arrT[2], "&");
									for(i2=1;i2 LTE arraylen(arrTF);i2++){
										arrTFV=listToArray(arrTF[i2], "=", true);
										t9.vs[arrTFV[1]]=URLDecode(arrTFV[2]);
									}
								}else if(arraylen(arrT) GT 2){
									application.zcore.template.fail("invalid destination url:"&tempURL);
								}
								ts.uniqueStruct[sUrl]=t9;
							}
						}
					}
				// }else if(left(cur, len("RewriteRule")) EQ "RewriteCond"){
				// 	writeoutput('rewritecond:'&cur&'<br />');
				// }else{
				// 	writeoutput('unknown url:'& cur&'<br />');	
				}
				
			}
		}
		arguments.sharedStruct.customRules=ts;
	};
	return;
	</cfscript>
</cffunction>


    </cfoutput>
</cfcomponent>
