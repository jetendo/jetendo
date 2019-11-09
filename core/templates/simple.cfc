<cfcomponent implements="zcorerootmapping.interface.view">
<cfoutput>

<cffunction name="init" access="public" returntype="string" localmode="modern">
	<cfscript> 
	savecontent variable="meta"{ 
		if(fileexists(request.zos.globals.homedir&"stylesheets/zblank.css")){
			echo(application.zcore.skin.includeCSS("/stylesheets/zblank.css"));
		}
	}
	application.zcore.template.prependTag("meta", meta);
	</cfscript>
</cffunction>

<cffunction name="render" access="public" returntype="string" localmode="modern">
	<cfargument name="tagStruct" type="struct" required="yes">
	<cfscript>
	var tagStruct=arguments.tagStruct;
	</cfscript>
	<cfsavecontent variable="output">
	<cfscript>
	request.znotemplate=1;
	if(application.zcore.functions.zIsTestServer() EQ false){
		application.zcore.functions.zheader("X-UA-Compatible", "IE=edge,chrome=1");
	}
	</cfscript>#application.zcore.functions.zHTMLDoctype()#
	<head>
	    <meta charset="utf-8" />
	<title>#tagStruct.title ?: ""#</title>
	#tagStruct.stylesheets ?: ""#
	#tagStruct.meta ?: ""#
	<style>/* <![CDATA[ */ body{margin:0px;  } /* ]]> */</style>
	</head>
	<body class="zblanktemplatebody">
	#tagStruct.content ?: ""#
	#tagStruct.scripts ?: ""#
	</body>
	</html>
	</cfsavecontent>
	<cfreturn output>
</cffunction>
</cfoutput>
</cfcomponent>