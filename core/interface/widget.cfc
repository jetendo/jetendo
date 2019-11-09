<cfinterface>  

<cffunction name="getHTML" localmode="modern" access="public" output="no"> 
	<cfargument name="ds" type="struct" required="yes">
	<!--- 
	Implementation Example:
	<cfscript>
	ds=arguments.dataFields;
	</cfscript>
	<cfsavecontent variable="out">
		<div class="test-example-1">
			<div class="test-example-2">
				<div class="test-example-3">#ds.Heading#</div>
				<div class="test-example-4">
					#ds["Body Text"]#
				</div>
			</div>
			<div class="test-example-5">
				<cfif ds["Image"] NEQ ""> 
					<img class="test-example-6" src="#ds["Image"]#" alt="Broker">
				</cfif>
			</div>
		</div>
	</cfsavecontent>
	<cfscript>
	return out;
	</cfscript> --->
</cffunction>
	

<cffunction name="getCSS" localmode="modern" access="public" output="no">
	<cfargument name="layoutFields" type="struct" required="yes">
	<!--- 
	<cfscript>
	cs=arguments.layoutFields;
	</cfscript>
	Implementation Example 1:
	<cfreturn application.zcore.functions.zReadFile("/path/to/css.css")>
	
	Implementation Example 2: 
	<style>
	<cfsavecontent variable="out">
	.css{float:left;}
	</cfsavecontent>
	</style>
	<cfscript>
	return out;
	</cfscript>
	--->
</cffunction> 


<cffunction name="getJS" localmode="modern" access="public" output="no">  
	<cfargument name="widgetContainer" type="string" required="yes">
	<!--- 
	Implementation Example:
	<cfscript>
	ds=arguments.dataFields;
	</cfscript>
	<script>
	<cfsavecontent variable="out">
	zArrDeferredFunctions.push(function(){
		var e="testWidgetJS";
		console.log(e);
	});
	</cfsavecontent>
	</script>
	<cfscript>
	return out;
	</cfscript>
	--->
</cffunction>

<cffunction name="getConfig" localmode="modern" access="public" output="no">
	<!--- 
	<cfscript>
	cs={};
	// define all the html and css variable field names, types and options
	cs.dataFields=[];
	cs.layoutFields=[];
	return cs;
	</cfscript>

	--->
</cffunction>
	
<cffunction name="index" localmode="modern" roles="serveradministrator">
</cffunction> 
</cfinterface>