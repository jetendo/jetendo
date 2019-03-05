<cfcomponent>  
<cffunction name="init" localmode="modern" access="public">
	<cfcontent type="text/html; UTF-8"> 
	<cfscript>
	echo('<style>body{background-color:##000; color:##FFFFFF;} a{ color:##FFF;}</style>');  
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>    
	// init();
	return ("My web server loaded this");
	</cfscript>
</cffunction>
</cfcomponent>