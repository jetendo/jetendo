<cfcomponent output="no">
<cffunction name="init" localmode="modern" access="public" output="no" returntype="struct">
	<cfscript> 
	return createobject("component", "zcorerootmapping.com.zos.functions");

    //var ts={}; 

	//functions=createobject("component", "zcorerootmapping.com.zos.functions");
	//structappend(ts, functions, true);
	/*
	var arrFunctionFile=['object', 'codeExport', 'database', 'dateAndTime', 'display', 'fileAndDirectory', 'form', 'macro', 'navigation', 'os', 'publishing', 'searchEngineSafeURLs', 'session', 'string', 'validation', 'xml', 'leadRouting'];
	var i=0;
	var count=arraylen(arrFunctionFile);
	var com=0;
	for(i=1;i LTE count;i++){
		com=createobject("component", "zcorerootmapping.functions."&arrFunctionFile[i]);
		structappend(ts, com, true);
	}
	*/
	//return ts;
	</cfscript>   
</cffunction>
</cfcomponent>