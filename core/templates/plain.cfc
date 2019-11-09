<cfcomponent implements="zcorerootmapping.interface.view">
<cfoutput>
<cffunction name="init" access="public" returntype="string" localmode="modern">
	<cfscript> 
	</cfscript>
</cffunction>
<cffunction name="render" access="public" returntype="string" localmode="modern">
	<cfargument name="tagStruct" type="struct" required="yes">
	<cfscript>
	var tagStruct=arguments.tagStruct;

	tempPath=request.zos.globals.homedir&"stylesheets/zblank.css";
	if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath)){
		stylesheetExists=application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath];
	}else{
		stylesheetExists=fileexists(tempPath);
		application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath]=stylesheetExists;
	}
	</cfscript>
	<cfsavecontent variable="output">
	<cfscript>
	request.znotemplate=1;
	if(not request.zos.istestserver){
		application.zcore.functions.zheader("X-UA-Compatible", "IE=edge,chrome=1");
	}
	</cfscript>#application.zcore.functions.zHTMLDoctype()#
	<head>
	    <meta charset="utf-8" />
	    <title>#tagStruct.title ?: ""#</title>
	 	<style>/* <![CDATA[ */ 
	 	<cfif request.zos.cgi.http_user_agent CONTAINS "ipad" or request.zos.cgi.http_user_agent CONTAINS "iphone" or request.zos.cgi.http_user_agent CONTAINS "ipod">
	 	html, body{ width: 100%; height: 100%; overflow: auto; -webkit-overflow-scrolling: touch; }
	 	</cfif>



	 	body{ font-family:Verdana, Geneva, sans-serif; font-size:13px; line-height:1.3;margin:0px; } 
	 	h1{ font-size:18px; line-height:1.3;} 
	 	h2{ font-size: 14px; line-height:1.3; }
		@media only screen and (max-width: 992px) {  
	 		body{ font-size:16px;}
		 	h1{ font-size:21px; } 
		 	h2{ font-size:18px; }
			textarea, select, button, input {
			    font-size: 16px;
			    line-height: 1.5;
			}
		}
	 	 /* ]]> */</style>
		#tagStruct.stylesheets ?: ""#
		#tagStruct.meta ?: ""#
		<cfif stylesheetExists>
		#application.zcore.skin.includeCSS(tempPath)#
		</cfif>
	</head>
	<body class="zblanktemplatebody">
	<!--- #tagStruct.topcontent ?: ""# --->
	<cfif application.zcore.template.getTagContent("pagetitle") NEQ "">
		<h1>#tagStruct.pagetitle ?: ""#</h1>
	</cfif>
	<div style="float:none;">
	#tagStruct.content ?: ""#
	#tagStruct.scripts ?: ""#</div>
	<cfif not structkeyexists(request, 'zDisableTrackingCode')>
		#application.zcore.functions.zvarso('Visitor Tracking Code')#
	</cfif>
	</body>
	</html>
	</cfsavecontent>
	<cfreturn output>
</cffunction>
</cfoutput>
</cfcomponent>