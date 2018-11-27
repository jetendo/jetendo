<cfcomponent>
<cfoutput>
<cffunction name="siteSearch" localmode="modern" access="private" roles="serveradministrator">
	<cfargument name="word" type="any" required="yes">
	<cfargument name="defaultValue" type="any" required="no" default="">
	<cfscript>
	var found = false;
	/*if(find(" "&arguments.word, ss) NEQ 0){
		ss = replace(ss, " "&arguments.word,"","ALL");
		found = true;
	}
	if(found EQ false and find(" "&arguments.word&"s", ss) NEQ 0){
		ss = replace(ss, " "&arguments.word&"s","","ALL");
		found = true;
	}*/
	if(found){
		return true;
	}else{
		return arguments.defaultValue;
	}
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	var db=request.zos.queryObject;
	var i=0;
	var alphabet=0;  
	var qCount=0;
	var perpage=0;
	var inputStruct=0;
	var searchNav=0;
	var searchStruct=0;
	var myColumnOutput=0; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.1");
	form.zid=application.zcore.functions.zso(form, 'zid');
	form.action=application.zcore.functions.zso(form, 'action',false,'list');
	application.zcore.functions.zStatusHandler(request.zsid);

	if(not application.zcore.user.checkAllCompanyAccess()){
		form.company_id=request.zsession.user.company_id;
	}else{
		form.company_id=0;
	}
	</cfscript>
	<cfif form.action EQ "select">
		<br />
	</cfif>
	<cfif form.action EQ "list">
		<cfscript>
		structdelete(variables,"qsites");
		</cfscript>
		<cfif structkeyexists(form, 'site_search')>
			<cfscript>
			ss = application.zcore.functions.zso(form, 'site_search');
			/*users = siteSearch("user",false);
			pages = siteSearch("page",false);
			globals = siteSearch("global",false);
			apps = siteSearch("app",false);
			skins = siteSearch("skin",false);
			logs = siteSearch("log",false);*/
			db.sql="SELECT * FROM 
			#db.table("site", request.zos.zcoreDatasource)# site 
			LEFT JOIN #db.table("company", request.zos.zcoreDatasource)# company ON 
			company_deleted=#db.param(0)# and 
			company.company_id = site.company_id 
			WHERE site.site_id <> #db.param(-1)# and 
			site_deleted = #db.param(0)# and 
			(site_sitename LIKE #db.param('%#ss#%')# or 
			site_domain LIKE #db.param('%#ss#%')#) ";
			if(form.company_id NEQ "0"){
				db.sql&=" and site.company_id = #db.param(form.company_id)# ";
			}
			db.sql&=" ORDER BY company_name ASC, site_short_domain ASC"; 
			qSites = db.execute("qSites"); 
			perpage=qsites.recordcount;
			qCount=structnew();
			qCount.count=perpage;
			if(qSites.recordcount EQ 0){
				application.zcore.status.setStatus(Request.zsid, "No sites matched your search.");
				application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#Request.zsid#");
			}else if(qSites.recordcount EQ 1){
				form.sid = qSites.site_id;
				if(ss CONTAINS "users"){
					application.zcore.functions.zRedirect('/z/server-manager/admin/user/index?sid=#form.sid#');
				}else if(ss CONTAINS "globals"){
					application.zcore.functions.zRedirect('/z/server-manager/admin/site/edit?sid=#form.sid#');
				}else if(ss CONTAINS "apps"){
					application.zcore.functions.zRedirect('/z/_com/zos/app?method=instanceSiteList&sid=#form.sid#');
				}else{
					application.zcore.functions.zRedirect('/z/server-manager/admin/site-select/index?action=select&sid=#form.sid#');
				}
			}
			</cfscript>
		</cfif>
		
		<cfif structkeyexists(form, 'showInactiveSites')>
			<cfset request.zsession.showInactiveSites=form.showInactiveSites>
		</cfif>
		
		<form action="#request.cgi_script_name#?action=list" method="get">
			<table style="border-spacing:0px; width:100%;" class="table-list">
				<tr class="table-shadow">
					<td colspan="13" class="tiny"><h2 style="display:inline;">Sites</h2> &nbsp;&nbsp;
					<cfif request.zos.isTestServer or (not structkeyexists(request.zos, 'sourceAdminUserStruct') or structkeyexists(request.zos.sourceAdminUserStruct, request.zsession.user.id&"|"&request.zsession.user.site_id))> 
						<a href="/z/server-manager/admin/site/newDomain" class="z-manager-search-button">Add Site</a> 

						<cfif application.zcore.user.checkAllCompanyAccess()>
							<a href="/z/server-manager/admin/site-import/index" class="z-manager-search-button">Import Site</a>
							<a href="/z/server-manager/admin/company/index">Companies</a> 
						 
							| <a href="/z/server-manager/admin/global-import/index">Import Global Database</a>
						</cfif>
					</cfif>
					<!--- | <a href="#request.cgi_script_name#?action=manageBudget">Manage Budgets</a>  --->
						<cfif application.zcore.functions.zso(request.zsession, 'showInactiveSites', true, 0) EQ 1>
							| <a href="/z/server-manager/admin/site-select/index?showInactiveSites=0">Hide Inactive</a>
							<cfelse>
							| <a href="/z/server-manager/admin/site-select/index?showInactiveSites=1">Show Inactive</a>
						</cfif>
					</td>
					<td style="text-align:right" colspan="13" class="tiny"><input type="text" name="site_search" value="#application.zcore.functions.zso(form, 'site_search')#" style="min-width:100px; width:100%; max-width:200px;" size="35">
						<input type="submit" name="searchSubmit" value="Search" class="z-manager-search-button"> 
						<cfif application.zcore.functions.zso(form, 'site_search') NEQ "">
							<input type="button" name="name11" value="Clear" onclick="window.location.href='/z/server-manager/admin/site-select/index';" class="z-manager-search-button" />
						</cfif>
					</td>
				</tr>
				<tr>
					<cfscript>
	if(structkeyexists(form, 'selectedChar')){
		application.zcore.status.setField(form.zid, 'selectedChar', form.selectedChar);
	}
	selectedChar = application.zcore.status.getField(form.zid, 'selectedChar');
	alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	</cfscript>
					<cfloop from="1" to="26" index="i">
					<cfif selectedChar EQ mid(alphabet, i,1)>
						<td style="text-align:center; width:3%; cursor:pointer;" onMouseOver="this.className = 'table-site-select';" onMouseOut="this.className = 'table-error';" class="table-error" onClick="window.location.href = '#Request.zScriptName#&amp;selectedChar=';">#mid(alphabet, i,1)#</td>
						<cfelse>
						<td style="text-align:center; width:3%; cursor:pointer;" onMouseOver="this.className = 'table-site-select';" onMouseOut="this.className = 'table-list';" class="table-list" onClick="window.location.href = '#Request.zScriptName#&amp;selectedChar=#mid(alphabet, i,1)#';">#mid(alphabet, i,1)#</td>
					</cfif>
					</cfloop>
				</tr>
			</table>
		</form>
		<cfif structkeyexists(local, 'qSites') EQ false or qSites.recordcount EQ 0>
			<cfscript>
			db.sql="SELECT count(site_id) as count 
			FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
			WHERE site_id <> #db.param(-1)# and 
			site_deleted = #db.param(0)#";
			if(len(selectedChar) NEQ 0){
				db.sql&=" and left(site_sitename,#db.param(1)#) = #db.param(selectedChar)#";
			}
			if(application.zcore.functions.zso(request.zsession, 'showInactiveSites', true, 0) NEQ 1){
				db.sql&=" and site_active=#db.param(1)#";
			}
			if(form.company_id NEQ "0"){
				db.sql&=" and site.company_id = #db.param(form.company_id)# ";
			}
			qCount=db.execute("qCount");
			perpage = 200;
        	db.sql="SELECT * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
			LEFT JOIN #db.table("company", request.zos.zcoreDatasource)# company ON 
			company_deleted=#db.param(0)# and 
			company.company_id = site.company_id 
			WHERE site.site_id <> #db.param(-1)# and 
			site_deleted = #db.param(0)# ";
			if(len(selectedChar) NEQ 0){
				db.sql&=" and left(site_sitename,#db.param(1)#) = #db.param(selectedChar)#";
			}
			if(application.zcore.functions.zso(request.zsession, 'showInactiveSites') NEQ 1){
				db.sql&=" and site_active=#db.param(1)#";
			}
			if(form.company_id NEQ "0"){
				db.sql&=" and site.company_id = #db.param(form.company_id)# ";
			}
			db.sql&=" ORDER BY company_name ASC, site_sitename ASC 
			LIMIT #db.param((form.zIndex-1)*perpage)#, #db.param(perpage)# ";

			qSites=db.execute("qSites");
			</cfscript>
		<cfelse>
			<cfset qCount.count = qSites.recordcount>
		</cfif>
		<cfscript>
	if(qCount.count GT perpage){
		// required
		searchStruct = StructNew();
		searchStruct.count = qCount.count;
		searchStruct.index = form.zIndex;
		searchStruct.url = Request.zScriptName;
		searchStruct.buttons = 5;
		searchStruct.perpage = perpage;
		
		// stylesheet overriding
		searchStruct.tableStyle = "table-list";
		searchStruct.linkStyle = "tiny";
		searchStruct.textStyle = "tiny";
		searchStruct.highlightStyle = "tiny highlight";
		
		searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	}else{
		if(form.zIndex NEQ 1){
			// manual redirect when index is wrong
			application.zcore.functions.zRedirect(request.zScriptName&'&zIndex=1');
		}
		searchNav = "";
	}
	writeoutput(searchNav);
	</cfscript>
		<!--- could be used for ie7 to ie9 multi-column:
		<table style="width:100%; border-spacing:0px;" class="table-white">
			<cfscript>	
	inputStruct = StructNew();
	if(qSites.recordcount GT 40){
		inputStruct.colspan = 3;
	}else if(qSites.recordcount GT 30){
		inputStruct.colspan = 2;
	}else{
		inputStruct.colspan = 1;
	}
	inputStruct.rowspan = qSites.recordcount;
	inputStruct.vertical = true;
	myColumnOutput = CreateObject("component", "zcorerootmapping.com.display.loopOutput");
	myColumnOutput.init(inputStruct);
	</cfscript> --->
	<cfif application.zcore.functions.zso(request.zsession, 'showInactiveSites', true, 0) EQ 1>
		<br /><span style="color:##900;font-weight:bold;">Red</span> site links are inactive, <span style="color:##369;font-weight:bold;">Blue</span> are active<br />
	</cfif>
	
	<cfscript>
	lastCompany="-1";
	companyCount={};
	for(row in qSites){
		if(not structkeyexists(companyCount, row.company_id)){
			companyCount[row.company_id]=0;
		}
		companyCount[row.company_id]++;
	}
	styleFix="";
	if(qSites.recordcount GT 0){
		if(companyCount[qSites.company_id] LT 3){
			styleFix=" -moz-column-width: 1920px !important;     -webkit-column-width: 1920px !important;     column-width: 1920px !important;";
		}
	} 
	</cfscript>
	<div class="siteSelectDiv" style="#styleFix#">
			<cfloop query="qSites">
				<cfscript>
				if(lastCompany NEQ qSites.company_name){
					styleFix="";
					if(companyCount[qSites.company_id] LT 3){
						styleFix=" -moz-column-width: 1920px !important;     -webkit-column-width: 1920px !important;     column-width: 1920px !important;";
					}
					echo('</div>
						<div class="siteSelectCompany" style="clear:both; width:100%; float:left; font-size:200%; line-height:150%;">'&qSites.company_name&'</div>
						<div class="siteSelectDiv" style="#styleFix#">');
					lastCompany=qSites.company_name;
				}
				</cfscript>
				<div class="siteSelect1">
					<div class="siteSelect4">
					<div class="siteSelect2">
						<a href="##" onclick="window.location.href='#Request.zScriptName#&amp;action=select&amp;sid=#qSites.site_id#';return false;" style="text-decoration:none; <cfif qSites.site_active EQ 0>color:##900;</cfif>" title="Manage"><cfif qSites.site_domain CONTAINS "https:">https://</cfif>#qSites.site_sitename#</a>
					</div>
					<div class="site-links siteSelect3"> | <a href="#qSites.site_domain#" target="_blank" style="">View</a> | 
					<a href="##" onclick="window.location.href='#Request.zScriptName#&amp;action=select&amp;sid=#qSites.site_id#';return false;">Manage</a></div>
					</div>
				</div>
			</cfloop>
		</div>
		<script type="text/javascript">
		zArrDeferredFunctions.push(function(){
			$(".siteSelect1").bind("mouseover", function(){
				$('.site-links', this).css('visibility', 'visible');
			});
			$(".siteSelect1").bind("mouseout", function(){
				$('.site-links', this).css('visibility', 'hidden');
			});
		});
		</script>
		<cfscript>
	writeoutput(searchNav);
	application.zcore.template.appendTag("stylesheets", '<style type="text/css">
	.siteSelectDiv{float:left; width:100%;  -moz-column-width:300px; -webkit-column-width:300px; column-width:300px; padding-bottom:10px; padding-top:10px; }
	.siteSelect1{width:100%; clear:both;}
	.siteSelect1:hover{color:##FF0 !important; }
	.siteSelect4{padding:3px;float:left; width:100%; }
	.siteSelect1:hover .siteSelect4{ background-color:##69C !important; color:##FFF !important;}
	.siteSelect1:hover .siteSelect4 a:link, .siteSelect1:hover .siteSelect4 a:visited{ color:##FFF !important;}
	.siteSelect2{float:left;white-space: nowrap !important;width: 200px;}
	.siteSelect3{visibility:hidden;background-color:##69C !important; float:left;}
	</style>');
	</cfscript>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>
