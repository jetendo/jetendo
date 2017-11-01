<cfcomponent>
<cfoutput>
<cffunction name="view" localmode="modern" access="remote">
	<cfscript>
	writedump(form);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>