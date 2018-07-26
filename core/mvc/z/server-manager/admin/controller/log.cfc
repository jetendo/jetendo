<cfcomponent>
<cfoutput>
<cffunction name="view" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	form.action="view";
	index();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qSortCom=0;
	var i=0;
	var searchStruct=0;
	var qLogCount=0;
	var qLog=0;
	var searchNav=0;
	var qFix=0;
	var quser=0;
	var selectStruct=0; 
	var qUpdate=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	form.action=application.zcore.functions.zso(form, 'action',false,"list");
	</cfscript>
<cfif structkeyexists(form, 'action')>
	<cfscript>
	qSortCom = CreateObject("component","zcorerootmapping.com.display.querySort");
	form.zPageId = qSortCom.init("zPageId");
	if(structkeyexists(form, 'zLogIndex')){
		application.zcore.status.setField(form.zPageId, "zLogIndex", form.zLogIndex);
	}else{
		form.zLogIndex = application.zcore.status.getField(form.zPageId, "zLogIndex");
		if(form.zLogIndex EQ ""){
			form.zLogIndex = 1;
			qSortCom.setDefault("log_datetime", "DESC");
		}
	}
	Request.zScriptName = request.cgi_script_name&"?zPageId=#form.zPageId#";
	</cfscript>

<cfif form.action NEQ "abusiveips">
	<table style="border-spacing:0px;width:100%;" class="table-list">
	<tr>
	<td><h2 style="display:inline;">Logs</h2> &nbsp;&nbsp; 
		<a href="/z/server-manager/admin/recent-requests/index" class="z-manager-search-button">Recent Request History</a> 
		<a href="#Request.zScriptName#&action=view" class="z-manager-search-button">View Most Recent Error</a>
	<!--- | <a href="#request.cgi_script_name#?action=abusiveips">Abusive IPs</a> ---> </td>
	</tr>
	</table>
</cfif>
<!--- 
<cfif form.action EQ "abusiveips">
	<cfscript>
	application.zcore.functions.zSetPageHelpId("8.3.2");
	if(structkeyexists(form, 'removeip')){
		structdelete(application.zcore.abusiveIPStruct[application.zcore.abusiveIPDate],removeip);
		 db.sql="update #db.table("ip_block", request.zos.zcoreDatasource)#  
		 set ip_block_deleted = #db.param(1)#,
		ip_block_updated_datetime=#db.param(request.zos.mysqlnow)#
		WHERE ip_block_ip = #db.param(removeip)#";
		db.execute("q");
	}
	</cfscript>
	<h2>Abusive IPs</h2>
    <p>These IP addresses are actively being tracked or blocked.  This list is stored in "application" scope so it is deleted when the CFML server is restarted.</p>
    <table style="border-spacing:0px;">
    <tr>
    <td>IP Address</td>
    <td>Hits</td>
    <td>Admin</td>
    </tr>
	<cfscript>
	if(structcount(application.zcore.abusiveIPStruct) EQ 0){
		writeoutput('<tr><td colspan="3">No IP Addresses are currently being blocked.</td></tr>');
	}
	for(i in application.zcore.abusiveIPStruct){
		for(n in application.zcore.abusiveIPStruct[i]){
			writeoutput('<tr><td>#n#</td><td>#application.zcore.abusiveIPStruct[i][n]#</td><td><a href="#request.cgi_script_name#?action=abusiveips&removeip=#n#">Delete</a></td></tr>');
		}
	}
	</cfscript>
	</table>

</cfif> --->

<cfif form.action EQ "addHostFilter">
	<cfscript>
	if(isDefined('request.zsession.zCFError_host_filter') EQ false or structkeyexists(form, 'reset')){
		request.zsession.zCFError_host_filter = ArrayNew(1);
	}
	for(n=1;n LTE ListLen(form.log_hostfilter);n=n+1){
		currentHost = ListGetAt(form.log_hostfilter, n);
		exists = false;
		for(i=1;i LTE arrayLen(request.zsession.zCFError_host_filter);i=i+1){
			if(request.zsession.zCFError_host_filter[i] EQ currentHost){
				exists = true;
			}
		}
		if(exists EQ false){
			ArrayAppend(request.zsession.zCFError_host_filter, currentHost);
		}
	}
	application.zcore.status.setStatus(request.zsid, "Host(s) added to filter.");
	application.zcore.functions.zRedirect("#Request.zScriptName#&action=list&zsid=#request.zsid#", true);
	</cfscript>
	
<cfelseif form.action EQ "clearHostFilter">
	<cfscript>
	structDelete(request.zsession, "zCFError_host_filter", true);
	application.zcore.status.setStatus(request.zsid, "Host filter cleared.");
	application.zcore.functions.zRedirect("#Request.zScriptName#&action=list&zsid=#request.zsid#", true);
	</cfscript>

</cfif>





<cfif form.action EQ "resolved">
	<cfsavecontent variable="db.sql">
	UPDATE #db.table("log", request.zos.zcoreDatasource)# log 
	SET log_status = #db.param('Resolved')# 
	WHERE log_id = #db.param(form.log_id)# and log_deleted=#db.param(0)# 
	</cfsavecontent><cfscript>qFix=db.execute("qFix");
	application.zcore.status.setStatus(request.zsid, "Error Status changed to resolved.");
	application.zcore.functions.zRedirect("#Request.zScriptName#&action=list&zsid=#request.zsid#", true);
	</cfscript>
	
	
<cfelseif form.action EQ "unresolved">
	<cfsavecontent variable="db.sql">
	UPDATE #db.table("log", request.zos.zcoreDatasource)# log 
	SET log_status = #db.param('New')# 
	WHERE log_id = #db.param(form.log_id)# and log_deleted=#db.param(0)# 
	</cfsavecontent><cfscript>qFix=db.execute("qFix");
	application.zcore.status.setStatus(request.zsid, "Error Status changed to unresolved.");
	application.zcore.functions.zRedirect("#Request.zScriptName#&action=list&zsid=#request.zsid#", true);
	</cfscript>
	
	
<cfelseif form.action EQ "multipleResolved">
	<cfscript>
	for(i=1;i LTE 30;i=i+1){
		if(structkeyexists(form, 'log_resolver'&i)){
				currentId = form['log_resolver'&i];
				 db.sql="UPDATE #db.table("log", request.zos.zcoreDatasource)# log 
				 SET log_status = #db.param('Resolved')#, 
				 log_updated_datetime=#db.param(request.zos.mysqlnow)#  
				WHERE log_id = #db.param(currentId)# and log_deleted=#db.param(0)# ";
				db.execute("q");
		}
	}
	application.zcore.status.setStatus(request.zsid, "Selected errors were marked as resolved.");
	application.zcore.functions.zRedirect("#Request.zScriptName#&action=list&zsid=#request.zsid#", true);
	application.zcore.functions.zabort();</cfscript>
	
</cfif>





<cfif form.action EQ "view">
	<cfscript>
	application.zcore.functions.zSetPageHelpId("8.3.3");
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("log", request.zos.zcoreDatasource)# log 
	WHERE log_deleted = #db.param(0)# 
	<cfif structkeyexists(form, 'log_id')>
		and log_id = #db.param(form.log_id)#  
		LIMIT #db.param(0)#,#db.param(1)#
	<cfelseif isDefined('request.zsession.zCFError_host_filter')>
		#variables.getSelectedHosts("log",false)# 
		ORDER BY log_datetime DESC
		LIMIT #db.param(0)#,#db.param(30)#
	<cfelse> 
		ORDER BY log_datetime DESC
		LIMIT #db.param(0)#,#db.param(30)#
	</cfif>
	</cfsavecontent><cfscript>qLog=db.execute("qLog");
	if(qLog.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Log entry no longer exists.", false, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/log/index?zPageId=#form.zPageId#&zsid=#request.zsid#");
	}
	application.zcore.functions.zQueryToStruct(qLog);
	</cfscript>
	<p>&nbsp;<br><a href="#Request.zScriptName#&amp;action=list">Log</a> /</p>
	<p><span class="highlight"><cfif form.log_status EQ "Resolved"><a href="#Request.zScriptName#&amp;action=unresolved&amp;log_id=#form.log_id#" class="z-manager-search-button">Mark as Unresolved</a><cfelse><a href="#Request.zScriptName#&amp;action=resolved&amp;log_id=#form.log_id#" class="z-manager-search-button">Mark as Resolved</a></cfif>
	</span></p>
	<h2>#form.log_host#</h2>
	<p>#DateFormat(form.log_datetime, "mm-dd-yyyy")# #TimeFormat(form.log_datetime, "HH:mm:ss")#</p>
	<p>#form.log_user_agent#</p>
	<p><a href="#form.log_title#" target="_blank">#form.log_title#</a></p>
	<cfif form.log_script_name NEQ "">
		<cfscript>
		curLink=form.log_script_name;
		</cfscript>
		<p>Script Name: <a href="#curLink#" target="_blank">#curLink#</a></p>
	</cfif>
	<div class="server-admin-data">
	#replace(form.log_message, ",", ", ", "all")#
	</div>
</cfif>

<cfif form.action EQ "hideResolved">
	<cfscript>
	StructDelete(request.zsession, "zCFError_hideResolved", true);
	application.zcore.functions.zRedirect(Request.zScriptName&"&action=list",true);
	</cfscript>
<cfelseif form.action EQ "showResolved">
	<cfset request.zsession.zCFError_hideResolved = true>
	<cfscript>
	application.zcore.functions.zRedirect(Request.zScriptName&"&action=list",true);
	</cfscript>
</cfif>

<cfif form.action EQ "list">
	<cfscript>
	application.zcore.functions.zSetPageHelpId("8.3");
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT COUNT(log_id) as count 
	FROM #db.table("log", request.zos.zcoreDatasource)# log 
    
	WHERE log_id <> #db.param(-1)# and 
	log_deleted = #db.param(0)#
	<cfif isDefined('request.zsession.zCFError_hideResolved') EQ false>
	and log_status <> #db.param('Resolved')#
	</cfif> 
	<cfif isDefined('request.zsession.zCFError_host_filter')>
		#db.trustedSQL(variables.getSelectedHosts("log"))#
	</cfif>
	</cfsavecontent><cfscript>qLogCount=db.execute("qLogCount");</cfscript>
	  
	<cfsavecontent variable="db.sql">
	SELECT log_id,log_host, log_title,log_ip,log_datetime,log_status,log_priority,log_type, 
	replace(log_host,#db.param("www.")#,#db.param("")#) as log_short_host 
	FROM #db.table("log", request.zos.zcoreDatasource)# log  
	WHERE log_id <> #db.param(-1)# and 
	log_deleted = #db.param(0)# 
	<cfif isDefined('request.zsession.zCFError_hideResolved') EQ false>
	and log_status <> #db.param('Resolved')#
	</cfif>
	<cfif isDefined('request.zsession.zCFError_host_filter')>
		#db.trustedSQL(variables.getSelectedHosts("log"))#
	</cfif>
	#qSortCom.getOrderBy()#
	LIMIT #db.param((form.zLogIndex-1)*30)#,#db.param(30)#
	</cfsavecontent><cfscript>qLog=db.execute("qLog");</cfscript>
	<table style="border-spacing:0px;width:100%;" class="table-list">
	<tr><td> 
	
	<cfif isDefined('request.zsession.zCFError_hideResolved') EQ false>
	 | <a href="#Request.zScriptName#&action=showResolved">Show Resolved</a>
	 <cfelse>
	 | <a href="#Request.zScriptName#&action=hideResolved">Hide Resolved</a>
	 </cfif>
	| <a href="#Request.zScriptName#&action=clearHostFilter">Clear Filter</a>
	| <a href="##" onClick="document.myForm.submit();">Add to Filter</a>
	| <a href="##" onClick="submitSelected();">Mark Selected as Resolved</a>
	
	</td></tr>
	</table>
	<script type="text/javascript">
	function submitSelected(){
		document.myForm.action.value = "multipleResolved";
		document.myForm.submit();
	}
	</script>
	<cfscript>
	if(qLogCount.count GT 30){
		// required
		searchStruct = StructNew();
		searchStruct.count = qLogCount.count;
		searchStruct.index = form.zLogIndex;
		// optional
		searchStruct.url = Request.zScriptName;
		searchStruct.buttons = 5;
		searchStruct.perpage = 30;
		searchStruct.indexName= "zLogIndex";
		// stylesheet overriding
		searchStruct.tableStyle = "table-list tiny";
		searchStruct.linkStyle = "tiny";
		searchStruct.textStyle = "tiny";
		searchStruct.highlightStyle = "highlight tiny";
		
		searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	}else{
		searchNav = "";
	}
	writeoutput(searchNav);</cfscript>
	<script type="text/javascript">
	function toggleSelect(){
		var t = document.myForm.log_hostfilter;
		if(document.myForm.checkall.checked){
			for(i=0;i < t.length;i++){
				t[i].checked=true;
				me = eval("document.myForm.log_resolver"+(i+1));
				me.disabled=false;
			}
		}else{
			for(i=0;i < t.length;i++){
				t[i].checked=false;
				me = eval("document.myForm.log_resolver"+(i+1));
				me.disabled=true;
			}
		}
	}
	</script>
	<form name="myForm" id="myForm" action="#Request.zScriptName#" method="post">
	<input type="hidden" name="action" id="action" value="addHostFilter">
	<table  style="width:100%; border-spacing:0px;" class="table-list">
	<tr>
	<td><input type="checkbox" name="checkall" id="checkall" onClick="toggleSelect();" value="1">&nbsp;</td>
	<td><a href="#qSortCom.getColumnURL("log_title", request.cgi_script_name)#">Title</a> #qSortCom.getColumnIcon("log_title")#</td>
	<td><a href="#qSortCom.getColumnURL("log_ip", request.cgi_script_name)#">IP</a>#qSortCom.getColumnIcon("log_ip")#</td>
	<td><a href="#qSortCom.getColumnURL("log_datetime", request.cgi_script_name)#">Date</a> #qSortCom.getColumnIcon("log_datetime")#</td>
	<td><a href="#qSortCom.getColumnURL("log_type", request.cgi_script_name)#">Type</a> #qSortCom.getColumnIcon("log_type")#</td>
	<td><a href="#qSortCom.getColumnURL("log_status", request.cgi_script_name)#">Status</a> #qSortCom.getColumnIcon("log_status")#</td>
	<td><a href="#qSortCom.getColumnURL("log_priority", request.cgi_script_name)#">Priority</a> #qSortCom.getColumnIcon("log_priority")#</td> 
	<td>Admin</td>
	</tr> 
	<cfloop query="qLog">
		<tr onMouseOver="this.className = 'table-white';" onMouseOut="this.className = 'table-bright';" class="table-bright">
		<td><input type="checkbox" name="log_hostfilter" value="#qLog.log_host#" onClick="setHidden(this, #qLog.currentRow#);"><input type="hidden" name="log_resolver#qLog.currentRow#" value="#qLog.log_id#" disabled></td>
		<td><cfif qLog.log_type EQ 'error'><a href="#qLog.log_title#" target="_blank">#qLog.log_host#</a><cfelse>#qLog.log_host#</cfif></td>
		<td>#qLog.log_ip#</td>
		<td>#dateformat(qLog.log_datetime,"m/dd")&" "&timeformat(qLog.log_datetime,"h:mm:ss")#</td>
		<td>#qLog.log_type#</td>
		<td><cfif qLog.log_status NEQ "New"><span class="highlight"></cfif>#qLog.log_status#<cfif qLog.log_status NEQ "New"></span></cfif></td>
		<td><cfif qLog.log_priority NEQ 0><span class="highlight"></cfif>#variables.getErrorPriority(qLog.log_priority)#<cfif qLog.log_priority NEQ 0></span></cfif></td> 
		<td><a href="#Request.zScriptName#&action=view&log_id=#qLog.log_id#" class="z-manager-search-button">View</a>
		 
		<span class="highlight"><cfif qLog.log_status EQ "Resolved">
			<a href="#Request.zScriptName#&action=unresolved&log_id=#qLog.log_id#" class="z-manager-search-button">Mark as Unresolved</a>
		<cfelse>
			<a href="#Request.zScriptName#&action=resolved&log_id=#qLog.log_id#" class="z-manager-search-button">Mark as Resolved</a>
		</cfif>
	</span></td>
		</tr>
	</cfloop>
	</table>
	</form>
	<cfscript>writeoutput(searchNav);</cfscript>
</cfif>
</cfif>
</cffunction>


<cffunction name="getSelectedHosts" localmode="modern" access="private" returntype="any" output="true" roles="serveradministrator">
	<cfargument name="table" type="any" required="no" default="zsites">
	<cfargument name="where" type="boolean" required="no" default="false">
	<cfscript>
	var arrFilter = ArrayNew(1);
	var i = 0;
	var current = "";
	if(isDefined("request.zsession.zCFError_host_filter")){
		for(i=1;i LTE ArrayLen(request.zsession.zCFError_host_filter);i=i+1){
			current = request.zsession.zCFError_host_filter[i];
			if(current NEQ -1){
				ArrayAppend(arrFilter, arguments.table&".log_host = '" & replace(replace(current, "\", "\\", "ALL"), "'", "''", "ALL") & "'");
			}
		}
		if(ArrayLen(arrFilter) EQ 0){
			return "";
		}else if(arguments.where EQ true){
			return " 
			 ("&ArrayToList(arrFilter, " or ")&")";
		}else{
			return " and ("&ArrayToList(arrFilter, " or ")&")";
		}
	}else{
		return "";
	}
	application.zcore.functions.zabort();</cfscript>
</cffunction>

<cffunction name="getErrorPriority" localmode="modern" access="private" returntype="any" output="false" roles="serveradministrator">
	<cfargument name="priority" type="any" required="yes">
	<cfscript>
	switch(arguments.priority){
		case 0: return "N/A";
		case 1: return "Low";
		case 2: return "Medium";
		case 3: return "High";
		case 4: return "Critical";
		default: return "N/A";
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>