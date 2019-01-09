<cffunction name="onCFCRequest" localmode="modern" access="public">
	<cfargument type="string" name="cfcname"> 
	<cfargument type="string" name="method"> 
	<cfargument type="struct" name="args"> 
	<cfscript>
	if(request.zos.istestserver){
		writeoutput('oncfcrequest');
		writedump(arguments);//, true, 'simple');
		abort;
	}
	</cfscript>
</cffunction>