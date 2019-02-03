<cfcomponent>
<cfoutput>
<cffunction name="formatUnit" returntype="string">
	<cfargument name="time" type="numeric" required="yes">
    
    <cfif time GTE 100000000><!--- 1000ms --->
    	<cfreturn int(time/1000000)&" ms">
    <cfelseif time GTE 10000000><!--- 100ms --->
    	<cfreturn (int(time/100000)/10)&" ms">
    <cfelseif time GTE 1000000><!--- 10ms --->
    	<cfreturn (int(time/10000)/100)&" ms">
    <cfelse><!--- 0ms --->
    	<cfreturn (int(time/1000)/1000)&" ms">
    </cfif>
    
    
    <cfreturn (time/1000000)&" ms">
</cffunction> 
    

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">	
	<cfscript>
	request.adminType="web";
	isWeb=true;
	</cfscript>   
	<cfadmin action="getLoggedDebugData" type="#request.adminType#" password=""	returnVariable="logs">
	<cfadmin action="getDebugEntry" type="#request.adminType#" password="" returnVariable="entries">
	<!--- <cfadmin action="getDebugSetting" type="#request.adminType#" password="" returnVariable="setting"> --->
	     
	<cfparam name="url.action2" default="list"> 
	<h2>CFML Debugging Logs</h2>   
	<p>The 10 most recent debugging logs will appear here.  Add /?luceedebug=1 to a request to enable the debugger for specific requests.</p>
	<cfif isWeb>  
		<table class="table-list">
			<thead>
				<tr>
					<th width="50%">Path</th>
					<th width="35%">Request Time</th>
					<th width="5%">Query</th>
					<th width="5%">App</th>
					<th width="5%">Total</th> 
				</tr>
				<tr>
				</tr>
			</thead> 
			<cfif not arrayIsEmpty(logs)>
				<tbody>
					<cfloop from="#arrayLen(logs)#" to="1" index="i" step="-1">
						<cfscript>
						el=logs[i];
						_total=0;
						loop query="el.pages"{
							_total+=el.pages.total;
						}
						_query=0;
						loop query="el.pages"{
							_query+=el.pages.query;
						}
						_app=0;
						loop query="el.pages"{
							_app+=el.pages.app;
						}
						_path=el.scope.cgi.SCRIPT_NAME& (len(el.scope.cgi.QUERY_STRING)?"?"& el.scope.cgi.QUERY_STRING:"");
						_path=replace(replace(_path, "/zcorerootmapping/index.cfm?_zsa3_path=", ""), "&", "?");
						</cfscript>
						<tr>
							<td><a href="/z/server-manager/admin/debug-log/debugger/view?id=#el.id#">#el.scope.cgi.http_host&_path#</a></td>
							<td>#LSDateFormat(el.starttime)# #LSTimeFormat(el.starttime)#</td>
							<td nowrap>#formatUnit(_query)#</td>
							<td nowrap>#formatUnit(_app)#</td>
							<td nowrap>#formatUnit(_total)#</td>
						</tr> 
					</cfloop>
				</tbody>
			</cfif>
		</table> 
	</cfif>
</cffunction>


<cffunction name="view" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	form.id=form.id?:"";
	</cfscript> 
	<p><a href="/z/server-manager/admin/debug-log/debugger/index">CFML Debugging Logs /</a>
	<h2>Debugging Log ###form.id#</h2>
	<cfscript> 
	setting showdebugoutput=false;
	admin action="getLoggedDebugData" f="web" id="#form.id#" returnVariable="log";
	
	modernCom=createObject('component',"modern"); 

	if(!isSimpleValue(log)) {
		c={};
		// writedump(log);
		modernCom.readDebug(c,log,"admin");
	} 
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>