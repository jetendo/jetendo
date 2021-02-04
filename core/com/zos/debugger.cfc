<cfcomponent displayname="Debugger" output="no">
<cfoutput><cffunction name="init" localmode="modern" returntype="any" output="false">
  <cfscript>
		var i = 0;
		if(request.zos.isdeveloper or request.zos.istestserver){
			if(Request.zOS.debuggerEnabled EQ false){
				return "";
			}
			if(not request.zos.istestserver){
				application.zcore.functions.zNoCache();
			}
			if(isDefined('request.zsession.modes') EQ false){
				request.zsession.modes = StructNew();
			}
			if(structkeyexists(form, 'zOS_mode')){
				if(form.zOS_Mode EQ 'VerifyQueries'){
					if(form.zOS_modeValue EQ "true"){
						request.zsession.verifyQueries=true;
					}else{
						request.zsession.verifyQueries=false;
					}
				}else if(form.zOS_MODE EQ "debugleadrouting"){
					if(form.zOS_modeValue EQ "true"){
						request.zsession.debugleadrouting=true;
					}else{
						structdelete(request.zsession, 'debugleadrouting');
					}
				}else if(form.zOS_MODE EQ "forceHealthFailure"){
					if(form.zOS_modeValue EQ "true"){
						request.zsession.forceHealthFailure=true;
						application.zcore.serverDown=true;
					}else{
						structdelete(application.zcore, 'serverDown');
						structdelete(request.zsession, 'forceHealthFailure');
					}
				}else if(form.zOS_MODE EQ "forceHealthFailure2"){
					if(form.zOS_modeValue EQ "true"){
						request.zsession.forceHealthFailure2=true;
						application.zcore.serverDown2=true;
					}else{
						structdelete(application.zcore, 'serverDown2');
						structdelete(request.zsession, 'forceHealthFailure2');
					}

				}else if(form.zOS_MODE EQ "enableReadOnlyMode"){
					if(form.zOS_modeValue EQ "true"){
						application.zReadOnlyModeEnabled=true;
					}else{
						structdelete(application, 'zReadOnlyModeEnabled');
					}
				}else if(form.zOS_MODE EQ "enableThrowOnRedirect"){
					if(form.zOS_modeValue EQ "true"){
						application.zEnableThrowOnRedirect=true;
					}else{
						structdelete(application, 'zEnableThrowOnRedirect');
					}

				}
				if(structkeyexists(form, 'zOS_modeValue') and form.zOS_modeValue){
					request.zsession.modes[form.zOS_Mode] = true;
					if(form.zOS_Mode EQ 'varDump' and structkeyexists(form, 'zOS_modeVarDumpName')){
						request.zsession.modes.varDumpName = form.zOS_modeVarDumpName;
					} 
				}else{
					StructDelete(request.zsession.modes, form.zOS_Mode);
				}
			}
		}
		</cfscript>
</cffunction>

<cffunction name="outputDebugBarTag" localmode="modern" output="yes" returntype="string">
	<cfscript>
	if((request.zos.isDeveloper or request.zos.isTestServer) and application.zcore.user.checkAllCompanyAccess()){
		echo('##zDebugBar##');
	}
	</cfscript>
</cffunction>

<cffunction name="getForm" localmode="modern" output="false" returntype="struct">
  <cfscript>
		var returnString = "";
		var returnString2="";
		var returnStruct = StructNew();
		var arrURL = ArrayNew(1);
		if(Request.zOS.debuggerEnabled EQ false){
			return {returnString:"", returnString2:""};
		}
		Request.zOS.modes.time.end = GetTickCount();

		link="";
		if(structkeyexists(form,  request.zos.urlRoutingParameter)){
			link=form[request.zos.urlRoutingParameter];
		}else{
			link=request.zos.cgi.script_name;
		}
		returnStruct = application.zcore.functions.zGetRepostStruct();
		if(returnStruct.urlString NEQ ""){
			link&="?#htmleditformat(replacenocase(returnStruct.urlString,'zdisablesystemcaching=','ztv=','all'))#";
		}

		if(request.zos.maintenance or structkeyexists(form, "zMaintenanceMode")){
			return {returnString:"", returnString2:""};
		}
		</cfscript>
  <cfsavecontent variable="returnString">
	<cfif request.zos.isdeveloper or request.zos.isTestserver>
	<br style="clear:both;" /> 
    <form name="zOS_mode_form" id="zOS_mode_form" onsubmit="return zOS_mode_check();" action="#link#" method="post">
      <input type="hidden" name="zOS_mode" id="zOS_mode" value="debug" />
      <input type="hidden" name="zOS_modeValue" id="zOS_modeValue" value="true" />
	#returnStruct.formString#  
		<cfif request.zos.globals.requireLogin EQ 1 and structkeyexists(request, 'bypassLoginIPStruct') and structkeyexists(request.bypassLoginIPStruct, request.zos.cgi.remote_addr)>
		
			<div style="width:99%; background-color:##FFF;padding:5px; float:left; font-weight:bold; font-size:18px; padding-bottom:10px; line-height:1.3; color:##FF0000;">
				Require Login is on.
			</div>

		</cfif> 
      <div style="width:99%; float:left; ">
        <div class="zOS_mode_table" id="zOS_mode_table_tag" style="width:100%;display:block; ">
			<div class="zOS_mode_td">DevTools | 
				<cfif request.zos.isTestServer or (structkeyexists(application.zcore, 'user') and application.zcore.user.hasSourceAdminAccess())>
					<cfif request.zos.isTestServer>
						<a href="/z/server-manager/admin/deploy/index?sid=#request.zos.globals.id#" class="z-manager-search-button" style="color:##FFF;" target="_blank">Deploy Site</a> 
					</cfif>


					Reset: 
					<a href="##" class="z-manager-search-button" style="color:##FFF;" onclick="zOS_mode_submit('reset','true','site');return false;"  >Site</a> 
					<a href="##" onclick="zOS_mode_submit('reset','true','code');return false;"  class="zOS_mode_link">Code</a> | 
					<a href="##" onclick="zOS_mode_submit('reset','true','app');return false;"  class="zOS_mode_link">App</a> | 
					<a href="##" onclick="zOS_mode_submit('reset','true','app', '&amp;zforce=1');return false;"  class="zOS_mode_link">App &amp; Skin</a> | 
					<a href="##" onclick="zOS_mode_submit('reset','true','app', '&amp;zforcelisting=1');return false;"  class="zOS_mode_link">App &amp; Listing</a> | 
					<a href="##" onclick="zOS_mode_submit('reset','true','app','&amp;zforcelisting=1&amp;zrebuildramtable=1');return false;"  >App &amp; DB Ram</a> | 
					<a href="##" onclick="zOS_mode_submit('reset','true','template');return false;"  class="zOS_mode_link">Template</a> | 
					<a href="##" onclick="zOS_mode_submit('reset','true','session');return false;" >Session</a> | 
					<a href="##" onclick="zOS_mode_submit('reset','true','all');return false;" >All</a> | 
					<!--- <a href="##" onclick="zOS_mode_submit('reset','true','all', '&amp;zforce=1');return false;"  class="zOS_mode_link">All &amp; Skin Cache Rebuild</a> |  --->

					<a href="##" onclick="zOS_mode_submit('reset','true','cache');return false;" >Rebuild Globals</a>
				<cfelse>
					Reset: <a href="##" class="z-manager-search-button" style="color:##FFF;" onclick="zOS_mode_submit('reset','true','site');return false;"  >Site</a> 

				</cfif>
				<cfif not request.zos.isTestServer>
					&nbsp;&nbsp;<a href="#replace(request.zos.globals.domain, 'https:', 'http:')#.local.zsite.info/" target="_blank"  class="z-manager-search-button" style="color:##FFF;">Test Site</a> 
				</cfif>
			</div>
          	<cfif request.zos.isTestServer or (structkeyexists(application.zcore, 'user') and application.zcore.user.hasSourceAdminAccess())>
	            <div class="zOS_mode_td"> 
	            	Debug:
	            
	              <cfif isDefined('request.zsession.modes.debug')>
	                <a href="##" onclick="zOS_mode_submit('debug','false');return false;" >On</a>
	                <cfelse>
	                <a href="##" onclick="zOS_mode_submit('debug','true');return false;" >Off</a>
	              </cfif>
	              | Time:
	              <cfset request.zsession.modes.time=true>
	              <cfif isDefined('request.zsession.modes.time')>
	                <a href="##" onclick="zOS_mode_submit('time','false');return false;" >On</a>
	                <cfelse>
	                <a href="##" onclick="zOS_mode_submit('time','true');return false;" >Off</a>
	              </cfif>
	              <br /><label for="zOS_modeVarDumpName">Var Dump</label>:
	              <cfif isDefined('request.zsession.modes.varDump')>
	#request.zsession.modes.varDumpName#                                                                            &nbsp; <a href="##" onclick="zOS_mode_submit('varDump','false');return false;" >On</a>
	                <input type="hidden" name="zOS_modeVarDumpName" id="zOS_modeVarDumpName" value="" class="zOS_modeInput" />
	                <cfelse>
	                <input type="text" name="zOS_modeVarDumpName" id="zOS_modeVarDumpName" value="" class="zOS_modeInput" />
	                &nbsp; <a href="##" onclick="zOS_mode_submit('varDump','true');return false;" >Off</a>
	              </cfif>
	              | Verify Queries: 
	            	<cfif isDefined('request.zsession.verifyQueries') and request.zsession.verifyQueries>
	                 <a href="##" onclick="zOS_mode_submit('VerifyQueries','false');return false;" >On</a>
	                <cfelse>
	                &nbsp; <a href="##" onclick="zOS_mode_submit('VerifyQueries','true');return false;" >Off</a>
	                </cfif>
				<br />
	              <a href="#application.zcore.functions.zURLAppend(link, "zdebugurl=1")#">Debug URL</a> 
	              | Debug Lead Routing: 
	            	<cfif isDefined('request.zsession.debugleadrouting') and request.zsession.debugleadrouting>
	                 <a href="##" onclick="zOS_mode_submit('debugleadrouting','false');return false;">On</a>
	                <cfelse>
	                &nbsp; <a href="##" onclick="zOS_mode_submit('debugleadrouting','true');return false;">Off</a>
	                </cfif>

	                <!--- this is not fully implemented yet
	              | Force Health Failure: 
	            	<cfif isDefined('request.zsession.forceHealthFailure') and request.zsession.forceHealthFailure>
	                 <a href="##" onclick="zOS_mode_submit('forceHealthFailure','false');return false;">On 1</a>
	                <cfelse>
	                &nbsp; <a href="##" onclick="zOS_mode_submit('forceHealthFailure','true');return false;">Off 1</a>
	                </cfif>
	            	<cfif isDefined('request.zsession.forceHealthFailure2') and request.zsession.forceHealthFailure2>
	                 <a href="##" onclick="zOS_mode_submit('forceHealthFailure2','false');return false;">On 2</a>
	                <cfelse>
	                &nbsp; <a href="##" onclick="zOS_mode_submit('forceHealthFailure2','true');return false;">Off 2</a>
	                </cfif> 
	                 --->
	              | <a title="Write access will be disabled for all users on all sites, but lead forms will continue to function.">Read-only Mode</a>: 
	                <cfif structkeyexists(application, 'zReadOnlyModeEnabled') and application.zReadOnlyModeEnabled>
	                 <a href="##" onclick="zOS_mode_submit('enableReadOnlyMode','false');return false;" title="Click to turn off read-only mode">On</a>
	                <cfelse>
	                &nbsp; <a href="##" onclick="zOS_mode_submit('enableReadOnlyMode','true');return false;" title="Click to turn on read-only mode">Off</a>
	                </cfif><br>
	                Throw on redirect: 
	                <cfif structkeyexists(application, 'zEnableThrowOnRedirect') and application.zEnableThrowOnRedirect>
		                <a href="##" onclick="zOS_mode_submit('enableThrowOnRedirect','false');return false;" title="Click to turn off throw on redirect">On</a>
		            <cfelse>
		                <a href="##" onclick="zOS_mode_submit('enableThrowOnRedirect','true');return false;" title="Click to turn on throw on redirect">Off</a>
		            </cfif>
	                <br />
	                <cfif structkeyexists(request.zos.requestData.headers, 'ssl_session_id')>
						<cfif structkeyexists(request.zsession, 'ssl_session_id')>
							<cfif request.zsession.ssl_session_id NEQ request.zos.requestData.headers.ssl_session_id>
	               				ssl_session_id changed<br />
	               			<cfelse>
	               				ssl_session_id reused
							</cfif>
						<cfelse>
							new session
	               		</cfif>
						<cfscript>
						request.zsession.ssl_session_id=request.zos.requestData.headers.ssl_session_id;
						</cfscript>
					</cfif> 
	               	<cfif structkeyexists(application, 'customSessionStruct')>
						#structcount(application.customSessionStruct)# Active Sessions
					</cfif>
             	 </div>
		    </cfif>
            <div class="zOS_mode_td">
              <cfif isDefined('request.zsession.tracking.track_user_hits')>Hits: #request.zsession.tracking.track_user_hits#</cfif>
              <cfif isDefined('request.zsession.zlistingpageviewcount')> Listing Pages: #request.zsession.zlistingpageviewcount#</cfif>
              <cfif isDefined('request.zsession.zlistingdetailhitcount2')>  Detail Hits: #request.zsession.zlistingdetailhitcount2#</cfif>
              
              <cfscript>
			if(structkeyexists(form, 'zOS_viewXHTMLError')){
				XMLParse(request.zos.debuggerFinalString);
				writeoutput('This page is XHTML 1.0 Compliant');
			}
			</cfscript>
              <cfif isDefined('request.zsession.modes.validateXHTML')>
                <cfscript>
			StructDelete(request.zsession.modes, 'validateXHTML');
			try{
				XMLParse(request.zos.debuggerFinalString);
				writeoutput('This page is XHTML 1.0 Compliant');
			}catch(Any excpt){
				writeoutput('XHTML 1.0 Validation failed. <a href="##" onclick="zOS_mode_submit(''validateXHTML'',''true'',''true'');return false;" >View Error</a>');//
			}
			</cfscript>
              </cfif>
	      ##zdebuggerTimeOutput##<br />
	      	<cfif structkeyexists(request.zos, 'queryCount')>
				queries: #request.zos.queryCount# | rows: #request.zos.queryRowCount#<br />
			</cfif>
			<cfif structkeyexists(application, 'zGeocodeCacheLimit')>
				geocodes: api: #application.zGeocodeCacheLimit# 
				<cfif structkeyexists(application, 'zGeocodeCacheLimitTotal')>
					total: #application.zGeocodeCacheLimitTotal#
				</cfif><br />
			</cfif>
			<cfif request.zos.isTestServer>
		    	<a href="/z/server-manager/admin/mobile-conversion/responsive?link=#urlencodedformat(request.zos.originalURL)#" target="_blank">Responsive Conversion</a>
	      </cfif>
	  </div>

          </div>
          </cfif>
  </cfsavecontent>
  <cfsavecontent variable="returnString2"><cfif request.zos.isdeveloper or request.zos.isTestServer></div></form></cfif></cfsavecontent>
  
  <cfset returnString = replace(returnString, chr(10), "", "ALL")>
  <cfset returnString = replace(returnString, chr(13), "", "ALL")>
  <cfset returnString = replace(returnString, chr(9), "", "ALL")>
  <cfif structkeyexists(form, 'zOS_viewAsXML')>
	<cfcontent type="text/xml">
	<cfscript>
	returnString = "";
	returnString2 = "";
	</cfscript>
  </cfif> 
  <cfreturn {returnString:returnString, returnString2:returnString2}>
</cffunction>

<cffunction name="getOutput" localmode="modern" output="false" returntype="string">
  <cfscript>
		var returnString = "";
		var styleString = "";
		var dumpcode = "";
		if(Request.zOS.debuggerEnabled EQ false){
			return "";
		}
		</cfscript>
  
  <cfsavecontent variable="styleString">
  <style>
			.zOS_mode_table {
				background-color:##FFFFFF;
				color:##000000;
				font-family: Arial, Helvetica, sans-serif;
				font-size: 10px;
				border: 1px solid ##999999;
			}
			.zOS_mode_td {
				background-color:##FFFFFF;
				color:##000000;
				font-family: Arial, Helvetica, sans-serif;
				font-size: 10px;
				border: 0px solid ##999999;
				font-weight:bold;
			}
			body {
			margin-left: 0px;
			margin-top: 0px;
			margin-right: 0px;
			margin-bottom: 0px;
			}
			</style>
  </cfsavecontent>
  <cfsavecontent variable="returnString">
  <cfscript>
			try{
				if(isDefined('request.zsession.modes.varDump')){
					writeoutput('Dumping: '&request.zsession.modes.varDumpName&'<br /><br />');
					if(find("(", request.zsession.modes.varDumpName) EQ 0){ 
						if(isDefined(request.zsession.modes.varDumpName)){ 
							application.zcore.functions.zDump(evaluate(request.zsession.modes.varDumpName),request.zsession.modes.varDumpName,false);
						
						}else if(isDefined('Request.zOS.currentScript.variables.#request.zsession.modes.varDumpName#')){
							application.zcore.functions.zDump(Request.zOS.currentScript.variables[request.zsession.modes.varDumpName],request.zsession.modes.varDumpName,false);
						
						}else{
							writeoutput("{missing variable}");
						}
					}
					writeoutput("</td></tr><tr><td style=""vertical-align:top; border:1px solid ##999999"">");
				}
			}catch(Any excpt){
				// nothing
			}
			if(isDefined('session')){
				request._______mysession = duplicate(request.zsession);
				if(isDefined('request._______myrequest.zsession')){
					StructDelete(request._______myrequest.zsession, 'statusstruct');
					StructDelete(request._______myrequest.zsession, 'ZOSDEBUGGERLASTOUTPUT');
				}
			}
			if(isDefined('application.zcore.functions.zdump')){
				request.tempZdump = application.zcore.functions.zdump;
			}
			StructDelete(request, 'cfdumpinited');
			</cfscript>
  <cfif isDefined('request.zsession.modes.debug')>
    Debug Output (Components and functions were removed)<br />
    <br />
    <cfif isDefined('form') and StructCount(form) NEQ 0>
      <cfscript>
					writeoutput(request.tempZdump(form,'FORM',false));
					</cfscript>
      <br />
      <br />
    </cfif>
    <cfif isDefined('request._______mysession')>
      <cfscript>
					writeoutput(request.tempZdump(request._______mysession,'SESSION',false));
					</cfscript>
      <br />
      <br />
    </cfif>
    <cfif isDefined('cookie')>
      <cfscript>
					writeoutput(request.tempZdump(cookie,'COOKIE',false));
					</cfscript>
      <br />
      <br />
    </cfif>
    <cfif isDefined('Request.zOS.currentScript.variables') and StructCount(Request.zOS.currentScript.variables) NEQ 0>
      <cfscript>
				tempVars = StructNew();
				for(__i in Request.zOS.currentScript.variables){
					if(__i NEQ 'copyStruct' and isObject(Request.zOS.currentScript.variables[__i]) EQ false and isCustomFunction(Request.zOS.currentScript.variables[__i]) EQ false and __i NEQ "this" and __i NEQ "__content" and __i NEQ "arguments" and __i NEQ '__zTemplate' and __i NEQ '__path' and __i NEQ '__rethrow' and __i NEQ '__reset' and __i NEQ '__i' and __i NEQ '__include'){
						StructInsert(tempVars, __i, Request.zOS.currentScript.variables[__i],true);
					}
				}
				
					writeoutput(request.tempZdump(tempVars,'VARIABLES',false));
					</cfscript>
      <br />
      <br />
    </cfif>
    <!--- <cfif StructCount(Request) NEQ 0>
      <cfdump var="#request#" showudfs="no" hide="zos,_______mysession" label="REQUEST">
     <br />
      <br />
    </cfif> --->
    <cfscript>
				writeoutput(request.tempZdump(cgi,'CGI',false));
				</cfscript>
    <br />
    <br />
  </cfif>
  </cfsavecontent>
  <cfset dumpcode="">
  <cfscript> 
		if(len(trim(returnString)) EQ 0){
			request.zsession.zOSDebuggerLastOutput = '';
			return '';
		}else{
			returnString = '#application.zcore.functions.zHTMLDoctype()#<head><title>Debugger</title></head><body><table class="zOS_mode_table" style="width:100%;"><tr><td 
style="vertical-align:top; " class="zOS_mode_td">#returnString#</td></tr></table></body></html>';
			request.zsession.zOSDebuggerLastOutput = styleString&returnString;
			return '<iframe width="700" height="500" src="#request.cgi_script_name#?zOSDebuggerLastOutput=1">No output</iframe>';
		}
		</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
