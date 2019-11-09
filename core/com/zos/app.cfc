<cfcomponent output="no" hint="Provides methods to associate applications with different sites.">
<cfoutput>
<cffunction name="instanceConfirmDelete" localmode="modern" access="remote" roles="serveradministrator"  returntype="void" hint="display confirmation dialog before remove app from site.">
	<cfscript>
	var qa=0;
	var db=request.zos.queryObject;
	var pagenav=0;
	
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	</cfscript> 
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("app", request.zos.zcoreDatasource)# app,
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	WHERE app.app_id=app_x_site.app_id and 
	app_x_site_deleted = #db.param(0)# and 
	app_deleted = #db.param(0)# and 
	app_x_site_id = #db.param(form.app_x_site_id)# and 
	app.app_built_in=#db.param(0)# and 
	app_x_site.site_id = #db.param(form.sid)#
	</cfsavecontent><cfscript>qa=db.execute("qa");
	if(qa.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Application instance no longer exists.");
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=instanceList&app_id=#form.app_id#","zsid=#request.zsid#");
	}
	</cfscript>
	
	<cfsavecontent variable="pagenav">
	<a href="#request.cgi_script_name#?method=appList">Applications</a> / <a href="#request.cgi_script_name#?method=instanceList&app_id=#form.app_id#">#qa.app_name# Application Instances</a> /
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("pagenav",pagenav);
	application.zcore.template.setTag("pagetitle","Confirm Deletion of Application Instance, #qa.app_name#");
	</cfscript>
	<p>Deleting this application instance will permanently delete all configuration data associated with it.</p>
	
	<p>Are you sure you want to delete this application instance?</p>
	<p><button type="button" name="button1" onclick="window.location.href='#request.cgi_script_name#?method=instanceDelete&app_id=#form.app_id#&amp;sid=#form.sid#&amp;app_x_site_id=#form.app_x_site_id#';">Delete Application Instance</button>&nbsp;&nbsp;&nbsp;
	<button type="button" name="button2" onclick="window.location.href='/z/_com/zos/app?method=instanceSiteList&sid=#form.sid#';">Cancel</button></p>
</cffunction>


<!--- application.zcore.app.setAdminMenuPermissionUpdated(); --->
<cffunction name="setAdminMenuPermissionUpdated" localmode="modern" access="public" roles="member" returntype="any" hint="used to set a flag that the current site has updated its custom manager feature permissions.">
	<cfscript>
	request.zos.adminMenuPermissionUpdated=true;
	</cfscript>
</cffunction>

<cffunction name="getAdminMenu" localmode="modern" access="public" roles="member" returntype="any" hint="display the admin links">
	<cfargument name="sharedStruct" type="struct" required="no" default="#structnew()#">
	<cfscript>
	var qI=0;
	
	var ts=0;
	var i=0;
	var configCom=0;
	var qSiteOptionGroup=0;
	var db=request.zos.queryObject;
	var adminURL="";
	if(structkeyexists(application.sitestruct[request.zos.globals.id].app, 'appCache')){
		for(i in application.sitestruct[request.zos.globals.id].app.appCache){
			if(structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache, i)){
				configCom=application.zcore.functions.zcreateobject("component", application.zcore.appComPathStruct[i].cfcPath, true);
				configCom.site_id=request.zos.globals.id;
				arguments.sharedStruct=configCom.getAdminLinks(arguments.sharedStruct);
			}
		}
	}
	if(structkeyexists(request.zos,'adminMenuStruct')){
		structappend(arguments.sharedStruct, request.zos.adminMenuStruct, true);
	}
	if(application.zcore.user.checkServerAccess()){
		if(not application.zcore.user.hasSourceAdminAccess()){
			ts=structnew();
			ts.link="/z/admin/site-backup/index"; 
			ts.children=structnew();
			arguments.sharedStruct["Backup"]=ts;
		}else{
			ts=structnew();
			ts.link="/z/server-manager/admin/server-home/index"; 
			ts.children=structnew();
			arguments.sharedStruct["Server Manager"]=ts;

			curStruct=arguments.sharedStruct["Server Manager"];
			ts=structnew();
			ts.link="/z/server-manager/admin/server-home/index";
			curStruct.children["Dashboard"]=ts;
			ts=structnew();
			ts.link="/z/server-manager/admin/site-select/index";
			curStruct.children["Sites"]=ts;
			
			if(application.zcore.user.checkAllCompanyAccess() and request.zos.isTestServer){
				ts=structnew();
				ts.link="/z/_com/zos/app?method=appList";
				curStruct.children["Apps"]=ts;
				ts=structnew();
				ts.link="/z/server-manager/admin/log/index?sid=";
				curStruct.children["Logs"]=ts;
				ts=structnew();
				ts.link="/z/server-manager/admin/deploy/index";
				curStruct.children["Deploy"]=ts;
				ts=structnew();
				ts.link="/z/server-manager/admin/deploy/index?sid="&request.zos.globals.id;
				curStruct.children["Deploy This Site"]=ts;
			}
			ts.link="/z/server-manager/admin/site-select/index?action=select&sid="&request.zos.globals.id;
			curStruct.children["Edit This Site"]=ts;
			ts=structnew();
		}
	}
	
	if((structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "agent"))){// or (structkeyexists(request.zos.userSession.groupAccess, "agent") EQ false)){
		// ANYONE can access these
		
		if(structkeyexists(arguments.sharedStruct, "Leads") EQ false){
			ts=structnew();
			ts.featureName="Leads";
			ts.link="/z/inquiries/admin/manage-inquiries/index";
			ts.children=structnew();
			arguments.sharedStruct["Leads"]=ts;
		}
		if(structkeyexists(arguments.sharedStruct["Leads"].children,"Leads") EQ false){
			ts=structnew();
			ts.featureName="Leads";
			ts.link="/z/inquiries/admin/manage-inquiries/index";
			arguments.sharedStruct["Leads"].children["Leads"]=ts;
		}
		if(request.zos.isTestServer){
			if(structkeyexists(arguments.sharedStruct["Leads"].children,"Add Contact") EQ false){
				ts=structnew();
				ts.featureName="Leads";
				ts.link="/z/inquiries/admin/manage-contact/add";
				arguments.sharedStruct["Leads"].children["Add Contact"]=ts;
			}
			if(structkeyexists(arguments.sharedStruct["Leads"].children,"Contacts") EQ false){
				ts=structnew();
				ts.featureName="Leads";
				ts.link="/z/inquiries/admin/manage-contact/index";
				arguments.sharedStruct["Leads"].children["Contacts"]=ts;
			}
		}
		if(structkeyexists(arguments.sharedStruct["Leads"].children,"Lead Review Autoresponders") EQ false){
			ts=structnew();
			ts.featureName="Lead Review Autoresponders";
			ts.link="/z/inquiries/admin/review-autoresponder-settings/index";
			arguments.sharedStruct["Leads"].children["Lead Review Autoresponders"]=ts;
		}
		if(structkeyexists(arguments.sharedStruct["Leads"].children,"Add Lead") EQ false){
			ts=structnew();
			ts.featureName="Leads";
			ts.link="/z/inquiries/admin/manage-inquiries/index?zManagerAddOnLoad=1";
			arguments.sharedStruct["Leads"].children["Add Lead"]=ts;
		}
		if(structkeyexists(arguments.sharedStruct["Leads"].children,"Lead Export") EQ false){
			ts=structnew();
			ts.featureName="Lead Export";
			ts.link="/z/inquiries/admin/manage-inquiries/index##exportLeadDiv";
			arguments.sharedStruct["Leads"].children["Lead Export"]=ts;
		} 
		if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
			if(structkeyexists(arguments.sharedStruct["Leads"].children,"Import Leads") EQ false){
				ts=structnew();
				ts.featureName="Leads";
				ts.link="/z/inquiries/admin/import-leads/index";
				arguments.sharedStruct["Leads"].children["Import Leads"]=ts;
			}
			if(structkeyexists(arguments.sharedStruct["Leads"].children,"Search Engine Keyword Lead Report") EQ false){
				ts=structnew();
				ts.featureName="Lead Reports";
				ts.link="/z/inquiries/admin/search-engine-keyword-report/index";
				arguments.sharedStruct["Leads"].children["Search Engine Keyword Lead Report"]=ts;
			} 
			if(structkeyexists(arguments.sharedStruct["Leads"].children,"Lead Template Emails") EQ false){
				ts=structnew();
				ts.featureName="Lead Templates";
				ts.link="/z/inquiries/admin/lead-template/index";
				arguments.sharedStruct["Leads"].children["Lead Template Emails"]=ts;
			} 
			if(structkeyexists(arguments.sharedStruct["Leads"].children,"Lead Types") EQ false){
				ts=structnew();
				ts.featureName="Lead Types";
				ts.link="/z/inquiries/admin/types/index";
				arguments.sharedStruct["Leads"].children["Lead Types"]=ts;
			} 
			if(structkeyexists(arguments.sharedStruct["Leads"].children,"Lead Routing") EQ false){
				ts=structnew();
				ts.featureName="Lead Routing";
				ts.link="/z/inquiries/admin/routing/index";
				arguments.sharedStruct["Leads"].children["Lead Routing"]=ts;
			} 
			if(structkeyexists(arguments.sharedStruct["Leads"].children,"Lead Autoresponders") EQ false){
				ts=structnew();
				ts.featureName="Lead Autoresponders";
				ts.link="/z/inquiries/admin/autoresponder/index";
				arguments.sharedStruct["Leads"].children["Lead Autoresponders"]=ts;
			} 
			if(structkeyexists(arguments.sharedStruct["Leads"].children,"Mailing List Export") EQ false){
				ts=structnew();
				ts.featureName="Mailing List Export";
				ts.link="/z/admin/mailing-list-export/index";
				arguments.sharedStruct["Leads"].children["Mailing List Export"]=ts;
			} 
			if(structkeyexists(arguments.sharedStruct["Leads"].children,"Lead Source Report") EQ false){
				ts=structnew();
				ts.featureName="Lead Reports"
				ts.link="/z/inquiries/admin/lead-source-report/index";
				arguments.sharedStruct["Leads"].children["Lead Source Report"]=ts;
			} 
		}
		
		
		if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
			if(structkeyexists(arguments.sharedStruct, "Users") EQ false){
				ts=structnew();
				ts.featureName="Users";
				ts.link="/z/admin/member/index"; 
				ts.children=structnew();
				arguments.sharedStruct["Users"]=ts;
			}
			if(structkeyexists(arguments.sharedStruct["Users"].children,"Site Manager Users") EQ false){
				ts=structnew();
				ts.featureName="Users";
				ts.link="/z/admin/member/index";
				arguments.sharedStruct["Users"].children["Site Manager Users"]=ts;
			}
			if(structkeyexists(arguments.sharedStruct["Users"].children,"Public Users") EQ false){
				ts=structnew();
				ts.featureName="Users";
				ts.link="/z/admin/member/showPublicUsers";
				arguments.sharedStruct["Users"].children["Public Users"]=ts;
			}
			if(structkeyexists(arguments.sharedStruct["Users"].children,"Offices") EQ false){
				ts=structnew();
				ts.featureName="Offices";
				ts.link="/z/admin/office/index";
				arguments.sharedStruct["Users"].children["Offices"]=ts;
			}
			if(structkeyexists(arguments.sharedStruct["Users"].children,"Add Office") EQ false){
				ts=structnew();
				ts.featureName="Offices";
				ts.link="/z/admin/office/index?zManagerAddOnLoad=1";
				arguments.sharedStruct["Users"].children["Add Office"]=ts;
			}
			if(structkeyexists(arguments.sharedStruct["Users"].children,"Add User") EQ false){
				ts=structnew();
				ts.featureName="Users";
				ts.link="/z/admin/member/add";
				arguments.sharedStruct["Users"].children["Add User"]=ts;
			}
			if(structkeyexists(arguments.sharedStruct["Users"].children,"View Public Profiles") EQ false){
				ts=structnew();
				ts.link="/z/misc/members/index";
				ts.target="_blank";
				arguments.sharedStruct["Users"].children["View Public Profiles"]=ts;
			}
			if(structkeyexists(arguments.sharedStruct["Users"].children,"View Public User Home Page") EQ false){
				ts=structnew();
				ts.link="/z/user/home/index";
				ts.target="_blank";
				arguments.sharedStruct["Users"].children["View Public User Home Page"]=ts;
			}
			if(not request.zos.globals.enableDemoMode){
				if(structkeyexists(arguments.sharedStruct["Users"].children,"Import Users") EQ false){
					ts=structnew();
					ts.link="/z/admin/member/import";
					ts.target="_blank";
					arguments.sharedStruct["Users"].children["Import Users"]=ts;
				}
			} 
	
		}else if(structkeyexists(request.zos.userSession.groupAccess, "agent") and application.zcore.app.siteHasApp("content")){ 
			if(structkeyexists(arguments.sharedStruct,"Update Profile") EQ false){
				ts=structnew();
				ts.featureName="Users";
				ts.link=application.zcore.functions.zvar('domain',request.zsession.user.site_id)&"/z/admin/member/index";
				ts.children=structnew();
				arguments.sharedStruct["Update Profile"]=ts;
			}
		}

		if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
			arguments.sharedStruct=application.zcore.siteOptionCom.getAdminLinks(arguments.sharedStruct);
			arguments.sharedStruct=application.zcore.featureCom.getAdminLinks(arguments.sharedStruct);
		}
	}
	if(structkeyexists(arguments.sharedStruct, "Help") EQ false){
		ts=structnew();
		ts.link="/z/admin/help/index"; 
		ts.children=structnew();
		arguments.sharedStruct["Help"]=ts;
	}
	/*if(structkeyexists(arguments.sharedStruct["Help"].children,"Quick Start Guide") EQ false){
		ts=structnew();
		ts.link="/z/admin/help/quickStart";
		arguments.sharedStruct["Help"].children["Quick Start Guide"]=ts;
	} */
	if(structkeyexists(arguments.sharedStruct["Help"].children,"Documentation") EQ false){
		ts=structnew();
		ts.link="/z/admin/help/index";
		arguments.sharedStruct["Help"].children["Documentation"]=ts;
	} 
	/*if(structkeyexists(arguments.sharedStruct["Help"].children,"Support") EQ false){
		ts=structnew();
		ts.link="/z/admin/help/support";
		arguments.sharedStruct["Help"].children["Support"]=ts;
	} */
	if(request.zos.istestserver){
		if(structkeyexists(arguments.sharedStruct["Help"].children,"Help for this page") EQ false){
			ts=structnew();
			ts.onclick="return zGetHelpForThisPage(this);";
			ts.link="/z/admin/help/helpForThisPage";
			ts.target="_blank";
			arguments.sharedStruct["Help"].children["Help for this page"]=ts;
		} 
	}
	/*if(structkeyexists(arguments.sharedStruct["Help"].children,"In-Context Help Features") EQ false){
		ts=structnew();
		ts.link="/z/admin/help/incontext";
		arguments.sharedStruct["Help"].children["In-Context Help Features"]=ts;
	} */

	if(structkeyexists(request.zos.globals,'enableSSIPublish') and request.zos.globals.enableSSIPublish EQ 1){
		ts=structnew();
		ts.featureName="Pages";
		ts.link="/z/admin/ssi-skin/index";
		ts.children=structnew();
		if(structkeyexists(arguments.sharedStruct, "Content Manager")){
			arguments.sharedStruct["Content Manager"].children["Re-publish SSI Includes"]=ts;
		}else{
			arguments.sharedStruct["Re-publish SSI Includes"]=ts;
		}
	}
	return arguments.sharedStruct;
	</cfscript>
</cffunction>

<cffunction name="getWhitelabelStruct" localmode="modern" access="public" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	if(structkeyexists(application.siteStruct[request.zos.globals.id], 'whiteLabelStruct')){
		return application.siteStruct[request.zos.globals.id].whiteLabelStruct;
	}	

	if(structkeyexists(request, 'whiteLabelStruct')){
		return request.whiteLabelStruct;
	}
	db.sql=" SELECT * FROM #request.zos.queryObject.table("whitelabel", request.zos.zcoreDatasource)# whitelabel 
	WHERE 
	whitelabel_deleted=#db.param(0)# and ";
	if(structkeyexists(request.zsession, 'user')){
		db.sql&=" user_id IN (#db.param(0)#, #db.param(request.zsession.user.id)#) and ";
	}
	db.sql&=" site_id = #db.param(request.zos.globals.id)# 
	ORDER BY user_id DESC 
	LIMIT #db.param(0)#, #db.param(1)#";
	qData=db.execute("qData");
	if(qData.recordcount EQ 0){
		if(request.zos.globals.parentId NEQ 0){
			db.sql=" SELECT * FROM #request.zos.queryObject.table("whitelabel", request.zos.zcoreDatasource)# whitelabel 
			WHERE 
			whitelabel_deleted=#db.param(0)# and 
			user_id =#db.param(0)# and 
			site_id = #db.param(request.zos.globals.parentId)# 
			ORDER BY user_id DESC 
			LIMIT #db.param(0)#, #db.param(1)#";
			qData=db.execute("qData");
		}
		if(qData.recordcount EQ 0 and request.zos.globals.serverId NEQ request.zos.globals.id and request.zos.globals.parentId NEQ request.zos.globals.serverId){
			db.sql=" SELECT * FROM #request.zos.queryObject.table("whitelabel", request.zos.zcoreDatasource)# whitelabel 
			WHERE 
			whitelabel_deleted=#db.param(0)# and 
			user_id =#db.param(0)# and 
			site_id = #db.param(request.zos.globals.serverId)# 
			ORDER BY user_id DESC 
			LIMIT #db.param(0)#, #db.param(1)#";
			qData=db.execute("qData");
		}
	}
	ts={};
	application.zcore.functions.zQueryToStruct(qData, ts);
	ts.imagePath=application.zcore.functions.zvar('domain', ts.site_id)&"/zupload/whitelabel/";
	ts.arrPublicButton=[];
	ts.arrAdminButton=[];

	if(qData.recordcount NEQ 0){  
		db.sql="select * from #request.zos.queryObject.table("whitelabel_button", request.zos.zcoreDatasource)# whitelabel_button 
		WHERE whitelabel_id = #db.param(qData.whitelabel_id)# and 
		whitelabel_button_deleted=#db.param(0)# and 
		site_id = #db.param(qData.site_id)# 
		ORDER BY whitelabel_button_public ASC, whitelabel_button_sort ASC";
		qButton=db.execute("qButton");
		for(row in qButton){
			row.whitelabel_button_image128=row.whitelabel_button_image128;
			if(row.whitelabel_button_public EQ "1"){
				arrayAppend(ts.arrPublicButton, row);
			}else{
				arrayAppend(ts.arrAdminButton, row);
			}
		}

	}
	application.siteStruct[request.zos.globals.id].whiteLabelStruct=ts;
	request.whiteLabelStruct=ts;
	if(ts.whitelabel_css NEQ ""){
		ts.whitelabel_css=replaceNoCase(ts.whitelabel_css, "url(/", "url("&application.zcore.functions.zvar("domain", qData.site_id)&"/", "all");
	}
	return ts;
	</cfscript>
</cffunction>
	
<!--- application.zcore.app.setAdminMenu(sharedMenuStruct); --->
<cffunction name="setAdminMenu" localmode="modern" returntype="any" output="yes">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	if(structkeyexists(request.zos,'adminMenuStruct') EQ false){
		request.zos.adminMenuStruct=structnew();
	}
	structappend(request.zos.adminMenuStruct, arguments.sharedStruct, true);
	</cfscript>	
</cffunction>

<cffunction name="outputAdminMenu" localmode="modern" returntype="any" output="yes">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfargument name="insertLinkList" type="string" required="no" default="">
	<cfscript>
	var i=0;
	var arrKey=0;
	var arrKey2=0;
	var target="";
	var n=0;
	arrLink=[];
	writeoutput('<div class="zMenuWrapper"><ul id="zMenuDivDefault" class="zMenuBarDiv">');
	writeoutput('<li><a class="trigger" href="/z/admin/admin-home/index">Dashboard</a></li> ');

	arrayAppend(arrLink, { link:"/z/admin/admin-home/index", label:"Dashboard" });
	arrKey2=structkeyarray(arguments.sharedStruct);
	arrKey=[];
	for(i=1;i LTE arraylen(arrKey2);i++){
		if(arrKey2[i] NEQ "Help"){
			arrayAppend(arrKey, arrKey2[i]);
		}
	}
	arraysort(arrKey,"text","asc");
	arrayAppend(arrKey, "Help"); 
	for(i=1;i LTE arraylen(arrKey);i++){
		link=arguments.sharedStruct[arrKey[i]];
		if(structkeyexists(link, 'featureName')){
			if(not application.zcore.adminSecurityFilter.checkFeatureAccess(link.featureName)){
				continue;
			}
		}
		target="";
		if(structkeyexists(link,"target")){
			target=link.target;	
		}
		onclick="";
		if(structkeyexists(link,"onclick")){
			onclick=link.onclick;	
		}


		writeoutput('<li><a class="trigger" #onclick# href="'&htmleditformat(link.link)&'" ');
		if(structkeyexists(link,"target") and target EQ "_blank"){
			arrLink[arrayLen(arrLink)].target="_blank";
			writeoutput(' target="_blank"');	
		}
		writeoutput('>'&arrKey[i]&'</a> '&chr(10));
		if(structcount(link.children) NEQ 0){
			arrChildLink=[];
			writeoutput('<ul> '&chr(10));
		}
		arrKey2=structkeyarray(link.children);
		arraysort(arrKey2,"text","asc");
		for(n=1;n LTE arraylen(arrKey2);n++){
			childLink=link.children[arrKey2[n]];
			if(structkeyexists(childLink, 'featureName')){
				if(not application.zcore.adminSecurityFilter.checkFeatureAccess(childLink.featureName)){
					continue;
				}
			}
			target="";
			arrayAppend(arrChildLink, { link:childLink.link, label:arrKey2[n] });
			onclick="";
			echo('<li><a href="'&htmleditformat(childLink.link)&'" ');
			if(structkeyexists(childLink,"onclick")){
				arrChildLink[arrayLen(arrChildLink)].onclick=childLink.onclick; 
				echo(' onclick="#htmleditformat(onclick)#"');
			}
			if(structkeyexists(childLink,"target") and target EQ "_blank"){  
				echo('target="_blank"');
				arrChildLink[arrayLen(arrChildLink)].target="_blank"; 
			}
			echo('>'&arrKey2[n]&'</a></li> '&chr(10));
		}
		if(structcount(link.children) NEQ 0){
			writeoutput('</ul> '&chr(10));
			arrayAppend(arrLink, { link:link.link, label:arrKey[i], arrLink:arrChildLink, closed:true });
		}else{
			arrayAppend(arrLink, { link:link.link, label:arrKey[i] });
		}
		writeoutput('</li>'&chr(10));
	}
	arrInsert=listToArray(arguments.insertLinkList, ">");
	for(i=1;i<=arraylen(arrInsert);i+=2){
		
		current=arrInsert[i]; // <a href=""
		target="";
		if(current CONTAINS "_blank"){
			target=' target="_blank"';
			current=replace(arrInsert[i], ' target="_blank"', '', 'all'); // <a href=""
		}
		next=arrInsert[i+1]; // Link text</a
		arrCurrent=listToArray(current, '"');
		arrNext=listToArray(next, '<'); 
		if(arraylen(arrCurrent) GTE 2 and arraylen(arrNext) EQ 2){
			if(target NEQ ""){
				arrayAppend(arrLink, { link:arrCurrent[2], label:arrNext[1], target:"_blank" });
			}else{
				arrayAppend(arrLink, { link:arrCurrent[2], label:arrNext[1] });
			}
			echo('<li><a class="trigger" href="#arrCurrent[2]#" #target#>#arrNext[1]#</a></li>');
		} 
	}
	//writeoutput(arguments.insertLinkList);
	writeoutput('</ul><div id="zMenuAdminClearUniqueId" class="zMenuClear"></div></div>');

	return arrLink;
	</cfscript>
</cffunction>

<cffunction name="instanceDelete" localmode="modern" access="remote" roles="serveradministrator"  returntype="void" hint="remove app from site.">
	<cfscript>
	var configCom=0;
	var qa=0;
	var qremove=0;
	var rCom=0;
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	
	db.sql="SELECT * FROM #db.table("app", request.zos.zcoreDatasource)# app,
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	WHERE app.app_id=app_x_site.app_id and 
	app.app_built_in=#db.param(0)# and 
	app_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	app_x_site_id = #db.param(form.app_x_site_id)# and 
	app_x_site.site_id = #db.param(form.sid)#";
	qa=db.execute("qa");
	if(qa.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Application instance no longer exists.");
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=instanceList&app_id=#form.app_id#","zsid=#request.zsid#");
	}
	db.sql="DELETE FROM #db.table("app_reserve", request.zos.zcoreDatasource)#  
	WHERE 
	app_id=#db.param(qa.app_id)# and 
	site_id = #db.param(form.sid)# and 
	app_reserve_deleted = #db.param(0)#";
	qRemove=db.execute("qRemove");
	form.sid=qa.site_id;
	form.site_id=qa.site_id;
	form.app_x_site_id=form.app_x_site_id;
	configCom=application.zcore.functions.zcreateobject("component",application.zcore.appComPathStruct[qa.app_id].cfcPath, true);
	configCom.initAdmin();
	rCom=configCom.configDelete();
	if(rCom.isOK()){
		application.zcore.functions.zDeleteRecord("app_x_site","app_x_site_id,site_id", request.zos.zcoreDatasource);
		appUpdateCache(qa.site_id);
		application.zcore.status.setStatus(request.zsid,"Application instance deleted.");
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=instanceList&app_id=#qa.app_id#","zsid=#request.zsid#");
	}else{
		rCom.setStatusErrors(request.zsid);
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=instanceList&app_id=#qa.app_id#","zsid=#request.zsid#");
	}
	</cfscript>
</cffunction> 

	
	
	
	
<cffunction name="instanceSiteList" localmode="modern" access="remote" roles="serveradministrator"  returntype="void" hint="List all instances of the selected application.">
	<cfscript>
	var qapp=0;
	var qa=0;
	var pagenav=0;
	var qapps=0;
	var selectstruct=0;
	
	var db=request.zos.queryObject;
	var ___zr=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.1.1.7");
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id = #db.param(form.sid)# and 
	site_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qapp=db.execute("qapp");
	if(qapp.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid site id.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("app", request.zos.zcoreDatasource)# app
	
	WHERE 
	app_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	app_x_site.app_id = app.app_id and 
	app.app_built_in=#db.param(0)# and 
	app_x_site.site_id = #db.param(form.sid)# and 
	app_x_site_status IN (#db.param('0')#,#db.param('1')#) 
	ORDER BY app_name
	</cfsavecontent><cfscript>qa=db.execute("qa");</cfscript>
	<cfsavecontent variable="pagenav">
	<cfif application.zcore.user.checkAllCompanyAccess()>
		<a href="#request.cgi_script_name#?method=appList">Applications</a> /
	</cfif>
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("pagenav",pagenav);
	application.zcore.template.setTag("pagetitle","Application Instances");
	</cfscript>
	To create an application instance, Select an application and then click "Add Instance".<br /><br /> 
	
	
	<form action="#request.cgi_script_name#" method="get"  style="display:inline;">
	<input type="hidden" name="method" value="instanceForm">
	<input type="hidden" name="app_x_site_id" value="0">
	<input type="hidden" name="sid" value="#form.sid#">
	<input type="hidden" name="___zr" value="#request.cgi_script_name#?method=instanceSiteList&sid=#form.sid#">
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("app", request.zos.zcoreDatasource)# app  WHERE
	app.app_built_in=#db.param(0)# and 
	app_deleted = #db.param(0)#
	ORDER BY app_name
	</cfsavecontent><cfscript>qapps=db.execute("qapps");</cfscript>
	Application: 
	<cfscript>
	selectStruct = StructNew();
	selectStruct.name = "app_id";
	// options for query data
	selectStruct.style="tiny";
	selectStruct.query = qapps;
	selectStruct.queryLabelField = "app_name";
	selectStruct.queryValueField = "app_id";	
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript>
	<input type="submit" name="submitAdd" value="Add Instance">
	
	</form><br /><br />

	<cfscript>
	___zr=urlencodedformat("#request.cgi_script_name#?method=instanceSiteList&sid=#form.sid#");
	</cfscript>
	<table class="table-list" style="border-spacing:0px;">
	<tr><th>ID</th><th>Application Name</th><th>Status</th><th>Admin</th></tr>
	<cfloop query="qa">
	<tr>
	<td>#qa.app_x_site_id#</td>
	<td>#qa.app_name#</td>
	<td><cfif qa.app_x_site_status EQ 1>Enabled<cfelse>Disabled</cfif></td>
	
	<td>
	<a href="#request.cgi_script_name#?method=instanceForm&app_id=#qa.app_id#&sid=#qa.site_id#&app_x_site_id=#qa.app_x_site_id#&___zr=#___zr#">Edit</a> | 
	<a href="#request.cgi_script_name#?method=config&configMethod=configForm&app_id=#qa.app_id#&sid=#qa.site_id#&app_x_site_id=#qa.app_x_site_id#&___zr=#___zr#">Options</a> | 
	<a href="#request.cgi_script_name#?method=instanceConfirmDelete&app_id=#qa.app_id#&sid=#qa.site_id#&app_x_site_id=#qa.app_x_site_id#&___zr=#___zr#">Delete</a> </td>
	</tr>
	</cfloop>
	</table>
</cffunction>
	
<cffunction name="instanceList" localmode="modern" access="remote" roles="serveradministrator"  returntype="void" hint="List all instances of the selected application.">
	<cfscript>
	var qapp=0;
	var qa=0;
	var pagenav=0;
	var qsites=0;
	var selectstruct=0;
	var db=request.zos.queryObject;
	var ___zr=0;
	
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.2.2"); 
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("app", request.zos.zcoreDatasource)# app 
	WHERE app_id = #db.param(form.app_id)# and 
	app_deleted = #db.param(0)# and 
	app.app_built_in=#db.param(0)# 
	</cfsavecontent><cfscript>qapp=db.execute("qapp");
	if(qapp.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid application id.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM (#db.table("site", request.zos.zcoreDatasource)# site, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("app", request.zos.zcoreDatasource)# app) 
	
	WHERE app_x_site.site_id = site.site_id and 
	site_deleted = #db.param(0)# and 
	app_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and
	app_x_site.app_id = app.app_id and 
	 app.app_built_in=#db.param(0)# and 
	app.app_id = #db.param(form.app_id)# and 
	app_x_site_status IN (#db.param('0')#,#db.param('1')#) 
	<cfif application.zcore.functions.zso(form,'sid',true) NEQ 0> 
		and app_x_site.site_id = #db.param(form.sid)# 
	</cfif>
	ORDER BY site_domain, app_name
	</cfsavecontent><cfscript>qa=db.execute("qa");</cfscript>
	<cfsavecontent variable="pagenav">
	<a href="#request.cgi_script_name#?method=appList">Applications</a> /
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("pagenav",pagenav);
	application.zcore.template.setTag("pagetitle","#qapp.app_name# Application Instances");
	</cfscript>
	To create an application instance, Select a site and then click "Add Instance".<br /><br /> 
	
	
	<form name="addForm" action="#request.cgi_script_name#" method="get"  style="display:inline;">
	<input type="hidden" name="method" value="instanceForm">
	<input type="hidden" name="app_x_site_id" value="0">
	<input type="hidden" name="app_id" value="#form.app_id#">
	<input type="hidden" name="___zr" value="#request.cgi_script_name#?method=instanceList&app_id=#form.app_id#">
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_deleted = #db.param(0)#
	ORDER BY site_domain 
	</cfsavecontent><cfscript>qSites=db.execute("qSites");</cfscript>&nbsp;&nbsp;
	 Site: 
	<cfscript>
	selectStruct = StructNew();
	selectStruct.name = "sid";
	// options for query data
	selectStruct.style="tiny";
	selectStruct.query = qSites;
	selectStruct.queryLabelField = "site_domain";
	selectStruct.queryValueField = "site_id";	
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript>
	<input type="button" name="submitAdd" value="Add Instance" onclick="document.addForm.___zr.value+='&sid='+document.addForm.sid.options[document.addForm.sid.selectedIndex].value;document.addForm.submit();">
	
	</form><br /><br />

	<cfscript>
	if(structkeyexists(form, 'sid')){
		___zr=urlencodedformat("#request.cgi_script_name#?method=instanceList&sid=#form.sid#&app_id=#form.app_id#");
	}else{
		___zr=urlencodedformat("#request.cgi_script_name#?method=instanceList&app_id=#form.app_id#");
	}
	</cfscript>
	<table class="table-list" style="border-spacing:0px;">
	<tr><th>ID</th><th>Application Name</th><th>Status</th><th>Domain</th><th>Admin</th></tr>
	<cfloop query="qa">
	<tr>
	<td>#qa.app_x_site_id#</td>
	<td>#qa.app_name#</td>
	<td><cfif qa.app_x_site_status EQ 1>Enabled<cfelse>Disabled</cfif></td>
	<td>#qa.site_domain#</td>
	<td>
	<a href="#request.cgi_script_name#?method=instanceForm&app_id=#qa.app_id#&sid=#qa.site_id#&app_x_site_id=#qa.app_x_site_id#&___zr=#___zr#">Edit</a> | 
	<a href="#request.cgi_script_name#?method=config&configMethod=configForm&app_id=#qa.app_id#&sid=#qa.site_id#&app_x_site_id=#qa.app_x_site_id#&___zr=#___zr#">Options</a> | 
	<a href="#request.cgi_script_name#?method=instanceConfirmDelete&app_id=#qa.app_id#&sid=#qa.site_id#&app_x_site_id=#qa.app_x_site_id#&___zr=#___zr#">Delete</a> </td>
	</tr>
	</cfloop>
	</table>
</cffunction>
	
<cffunction name="instanceSave" localmode="modern" access="remote" roles="serveradministrator"  returntype="void">
	<cfscript>
	var ts=0;
	//var myForm=0;
	var finalAppId=0;
	var finalAppXSiteId=0;
	var updateType=0;
	var result=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	form.app_x_site_id=application.zcore.functions.zso(form, 'app_x_site_id',true);
	finalAppXSiteId=form.app_x_site_id;
	form.app_id=application.zcore.functions.zso(form, 'app_id',true);
	finalAppId=form.app_id;
	form.sid=application.zcore.functions.zso(form, 'sid',true);
	ts=StructNew();
	ts.table="app_x_site";
	ts.datasource="#request.zos.zcoreDatasource#";
	form.site_id=form.sid;
	ts.struct=form;
	updateType="update";
	if(form.app_x_site_id EQ 0){
		updateType="insert";
		result=application.zcore.functions.zInsert(ts);
		if(result EQ false){
			application.zcore.status.setStatus(request.zsid,"Unable to create application instance. Note: The code name must be unique across all applications on a site.",form,true);
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=instanceForm&app_id=#form.app_id#&sid=#form.sid#&app_x_site_id=#form.app_x_site_id#&zsid=#request.zsid#");
		}
		form.app_x_site_id=result;
		finalAppXSiteId=form.app_x_site_id;
		application.zcore.status.setStatus(request.zsid,"Application instance created.");
	}else{
		ts.forceWhereFields="app_x_site_id,site_id,app_id";
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			application.zcore.status.setStatus(request.zsid,"Unable to update application instance. Note: The code name must be unique across all applications on a site.",form,true);
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=instanceForm&app_id=#form.app_id#&sid=#form.sid#&app_x_site_id=#form.app_x_site_id#&zsid=#request.zsid#");
		}
		application.zcore.status.setStatus(request.zsid,"Application instance updated.");
	}
	appUpdateCache(form.site_id);
	if(updateType EQ "insert"){
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=config&configMethod=configForm&app_id=#finalAppId#&sid=#form.sid#&app_x_site_id=#finalAppXSiteId#");
	}else{
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=instanceList&sid=#form.sid#&app_id=#finalAppId#","zsid=#request.zsid#");
	}
	</cfscript>

</cffunction>
	
<cffunction name="instanceForm" localmode="modern" access="remote" roles="serveradministrator"  returntype="void">
	<cfscript>
	var qa=0;
	var qdata=0;
	var db=request.zos.queryObject;
	
	var pagenav=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.2.2.1"); 
	form.app_x_site_id=application.zcore.functions.zso(form, 'app_x_site_id',true);
	form.app_id=application.zcore.functions.zso(form, 'app_id',true);
	form.sid=application.zcore.functions.zso(form, 'sid',true);
	
	try{
		application.zcore.functions.zvar('id',form.sid);
	}catch(Any excpt){
		application.zcore.status.setStatus(request.zsid,"Invalid site id.",false,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=instanceList&app_id=#form.app_id#&zsid=#request.zsid#");
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("app", request.zos.zcoreDatasource)# app 
	WHERE app_id = #db.param(form.app_id)# and 
	app_deleted = #db.param(0)# and
 app.app_built_in=#db.param(0)# 
	</cfsavecontent><cfscript>qa=db.execute("qa");
	if(qa.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid application id.",false,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	}
	</cfscript>
	
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	WHERE app_x_site_id = #db.param(form.app_x_site_id)# and 
	app_id=#db.param(form.app_id)# and 
	app_x_site_deleted = #db.param(0)# and 
	site_id = #db.param(form.sid)# 
	</cfsavecontent><cfscript>qData=db.execute("qData");
	//local.app_x_site_id=form.app_x_site_id;
	application.zcore.functions.zQueryToStruct(qData, form, 'app_id,app_x_site_id');
	application.zcore.functions.zstatushandler(request.zsid);
	application.zcore.functions.zstatushandler(request.zsid,true,true);
	</cfscript>
	
	<cfsavecontent variable="pagenav">
	<a href="#request.cgi_script_name#?method=appList">Applications</a> / <a href="#request.cgi_script_name#?method=instanceList&amp;app_id=#form.app_id#">#qa.app_name# Application Instances</a> /
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("pagenav",pagenav);
	if(form.app_x_site_id EQ 0){
		application.zcore.template.setTag("pagetitle","Install Application");
		writeoutput("<p>Are you sure you want to install the application, ""#qa.app_name#"", on this site?</p>");
	}else{
		application.zcore.template.setTag("pagetitle","Edit Application: ""#qa.app_name#""");
	}
	</cfscript> 
	<form class="zFormCheckDirty" action="#request.cgi_script_name#?method=instanceSave&app_id=#form.app_id#&amp;sid=#form.sid#&amp;app_x_site_id=#form.app_x_site_id#" method="post" style="display:inline;">
	<table class="table-list" style="border-spacing:0px;">
	
	<cfif qData.recordcount NEQ 0>
	<tr> 
	<th>Enabled:</th>
	  <td style="vertical-align:top;"><input type="radio" name="app_x_site_status" value="1" <cfif application.zcore.functions.zso(form, 'app_x_site_status') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes <input type="radio" name="app_x_site_status" value="0" <cfif application.zcore.functions.zso(form, 'app_x_site_status',true) EQ 0>checked="checked"</cfif>  style="border:none; background:none;" /> No 
	</td>
	</tr>
	</cfif>
	</table>
	<cfif qData.recordcount EQ 0>
	<input type="hidden" name="app_x_site_status" value="0" />
	</cfif>
	<br style="clear:both;" /><button type="submit" name="submitForm"><cfif form.app_x_site_id EQ 0>Yes<cfelse>Save</cfif></button> <button type="button" name="cancelForm" onclick="window.location.href='/z/_com/zos/app?method=instanceSiteList&amp;sid=#form.sid#';">Cancel</button>
	</form>
	
</cffunction>
	
	
	
<cffunction name="config" localmode="modern" access="remote" roles="serveradministrator"  returntype="void">
	<!--- how does it know which component to use --->
	<!--- should this be the function that calls all the config methods? --->
	<cfscript>
	var configCom=0;
	var qa=0;
	var db=request.zos.queryObject;
	var pagenav=0;
	var rCom=0;
	var enabledScript=0;
	var d=0;
	var cancelLink=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.2.2.1"); 
	if(structkeyexists(form, 'configMethod') EQ false){
		application.zcore.status.setStatus(request.zsid,"You must specify an application configuration method.",false,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	}
	form.app_id=application.zcore.functions.zso(form, 'app_id',true);
	form.sid=application.zcore.functions.zso(form, 'sid',true);
	
	form.app_x_site_id=application.zcore.functions.zso(form, 'app_x_site_id',true);
	local.app_id=form.app_id;
	local.sid=form.sid;
	local.app_x_site_id=form.app_x_site_id;
	try{
		application.zcore.functions.zvar('id',local.sid);
	}catch(Any excpt){
		application.zcore.status.setStatus(request.zsid,"Invalid site id.",false,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	}
	db.sql="SELECT * FROM #db.table("app", request.zos.zcoreDatasource)# app, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	WHERE app.app_id = app_x_site.app_id and 
	app.app_built_in=#db.param(0)# and 
	app_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	app_x_site.app_x_site_id = #db.param(local.app_x_site_id)#  and 
	app_x_site.site_id =#db.param(local.sid)#";
	qa=db.execute("qa");
	if(qa.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid application id.",false,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	}
	configCom=application.zcore.functions.zcreateobject("component",application.zcore.appComPathStruct[qa.app_id].cfcPath, true);
	configCom.initAdmin();
	request.zos.tempcommeta=GetMetaData(configCom[form.configMethod]);
	if(request.zos.tempcommeta.access NEQ 'remote'){
		application.zcore.template.fail("The method, '#form.configMethod#', doesn't allow remote access.  Access is set to #request.zos.tempcommeta.access#");
	}
	</cfscript>
	
	<cfsavecontent variable="pagenav">
	<cfif application.zcore.user.checkAllCompanyAccess()>
	<a href="#request.cgi_script_name#?method=appList">Applications</a> / <a href="#request.cgi_script_name#?method=instanceList&amp;app_id=#local.app_id#">#qa.app_name# Application Instances</a> /
	</cfif>
	
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("pagenav",pagenav);
	application.zcore.template.setTag("pagetitle",'Configuring "#qa.app_name#" instance');
	
	rCom=configCom[form.configMethod]();
	</cfscript>
	<cfsavecontent variable="enabledScript">
	<table style="width:300px;" class="table-list">
	<tr> 
	<th style="width:140px;">Enabled:</th>
	  <td style="vertical-align:top;"><input type="radio" name="app_x_site_status" value="1" <cfif qa.app_x_site_status EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes <input type="radio" name="app_x_site_status" value="0" <cfif qa.app_x_site_status EQ 0>checked="checked"</cfif>  style="border:none; background:none;" /> No 
	</td>
	</tr>
	</table>
	</cfsavecontent>
	
	<cfscript>  
	if(rCom.isOK()){ 
		if(form.configmethod eq 'configSave'){
			db.sql="UPDATE #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
			SET app_x_site_status = #db.param(form.app_x_site_status)#,
			app_x_site_updated_datetime=#db.param(request.zos.mysqlnow)#  
			WHERE app_x_site_id=#db.param(local.app_x_site_id)# and 
			app_x_site_deleted = #db.param(0)# and 
			site_id =#db.param(local.sid)#";
			db.execute("q"); 
			appUpdateCache(qa.site_id);
			application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=instanceSiteList&site_id=#local.sid#&app_id=#qa.app_id#","zsid=#request.zsid#");
		}
		d=rCom.getData();
		if(structkeyexists(d,'output')){
			if(form.configmethod eq 'configForm'){
				if(structkeyexists(form, '___zr') EQ false){
					cancelLink="#request.cgi_script_name#?method=instanceList&app_id=#form.app_id#&sid=#local.sid#";
				}else{
					cancelLink=form.___zr;
				}
				writeoutput('<form class="zFormCheckDirty" name="zAppForm" id="zAppForm" action="#request.cgi_script_name#?method=config&configMethod=configSave&app_id=#local.app_id#&sid=#local.sid#&app_x_site_id=#local.app_x_site_id#" method="post" style="display:inline;">#d.output#<br />#enabledScript#<br style="clear:both;" /><button type="submit" name="submitForm">Save</button> <button type="button" name="cancel" onclick="window.location.href=''#cancelLink#'';">Cancel</button></form>');
			}else{
				writeoutput(d.output);
			}
		}
	}else{
		structdelete(form, 'config');
		structdelete(form, 'configMethod');
		form.configMethod="configForm";
		application.zcore.status.setStatus(request.zsid,false,form);
		rCom.setStatusErrors(request.zsid); 
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=config&configMethod=configForm&zsid=#request.zsid#&app_id=#local.app_id#&sid=#local.sid#&app_x_site_id=#local.app_x_site_id#");
	}
	</cfscript>
	
</cffunction>

	
	
	
	
<cffunction name="appList" localmode="modern" access="remote" roles="serveradministrator"  returntype="void" hint="display a list of application for the selected site.">
	<cfscript>
	var qa=0;
	var qapps=0;
	var selectStruct=0;
	var qsites=0;
	var db=request.zos.queryObject;
	
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.2"); 
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT *, app.app_id, count(app_x_site.app_id) count 
	FROM #db.table("app", request.zos.zcoreDatasource)# app 
	LEFT JOIN #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	ON app_x_site.app_id = app.app_id  and 

	 app.app_built_in=#db.param(0)# and 
	app_x_site.site_id <>#db.param(-1)# and 
	app_x_site_deleted = #db.param(0)#
	WHERE app_deleted = #db.param(0)#
	group by app.app_id
	ORDER BY app_name
	</cfsavecontent><cfscript>qa=db.execute("qa");
	application.zcore.template.setTag("pagetitle","Applications");
	</cfscript>
	<p><a href="#request.cgi_script_name#?method=appForm">Add Application</a> | Note: An application must have all instances deleted before it can be deleted.</p>
	
	
	<form action="#request.cgi_script_name#" method="get"  style="display:inline; padding:5px; border:1px solid ##999999;">
	<input type="hidden" name="method" value="instanceForm">
	<input type="hidden" name="app_x_site_id" value="0">
	<input type="hidden" id="zreturn" name="___zr" value="#request.cgi_script_name#?method=appList">
	<strong>Add Application Instance | </strong>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("app", request.zos.zcoreDatasource)# app 
	WHERE 
	app_built_in = #db.param(0)# and 
	app_deleted = #db.param(0)#
	ORDER BY app_name
	</cfsavecontent><cfscript>qapps=db.execute("qapps");</cfscript>
	Application: 
	<cfscript>
	selectStruct = StructNew();
	selectStruct.name = "app_id";
	// options for query data
	selectStruct.style="tiny";
	selectStruct.query = qapps;
	selectStruct.queryLabelField = "app_name";
	selectStruct.queryValueField = "app_id";	
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)#
	ORDER BY site_domain 
	</cfsavecontent><cfscript>qSites=db.execute("qSites");</cfscript>&nbsp;&nbsp;
	 Site: 
	<cfscript>
	selectStruct = StructNew();
	selectStruct.name = "sid";
	// options for query data
	selectStruct.style="tiny";
	selectStruct.query = qSites;
	selectStruct.onChange="document.getElementById('zreturn').value='#request.cgi_script_name#?method=instanceSiteList&sid='+this.options[this.selectedIndex].value;";
	selectStruct.queryLabelField = "site_domain";
	selectStruct.queryValueField = "site_id";	
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript>
	<input type="submit" name="submitAdd" value="Add Instance">
	
	</form><br /><br />
	
	<table class="table-list" style="border-spacing:0px;">
	<tr><th>Application Name</th><th>Admin</th></tr>
	<cfloop query="qa">
	<tr>
	<td>#qa.app_name#</td><td>
	<a href="#request.cgi_script_name#?method=appForm&app_id=#qa.app_id#">Edit</a> | 
	
	<cfif qa.count NEQ 0>
	<a href="#request.cgi_script_name#?method=instanceList&app_id=#qa.app_id#">Instances</a> 
	<cfelse>
	<a href="#request.cgi_script_name#?method=appConfirmDelete&app_id=#qa.app_id#">Delete</a>
	</cfif></td>
	</tr>
	</cfloop>
	</table>
</cffunction>
	
<cffunction name="getAppCFC" localmode="modern"  returntype="struct" output="no">
	<cfargument name="app_name" type="string" required="yes">
	<cfscript>
	if(structkeyexists(application.zcore.appComName, arguments.app_name)){
		var id=application.zcore.appComName[arguments.app_name];
		if(structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache, id)){
			// return application.sitestruct[request.zos.globals.id].app.appCache[id].cfcCached;
 			
 			// if i attempt to reuse these objects on multiple requests, it is able to cause horrible performance or crash.  too much contention probably.
			if(not structkeyexists(request.zos.tempRequestCom, id)){
				request.zos.tempRequestCom[id]=application.zcore.functions.zcreateobject("component", application.zcore.appComPathStruct[id].cfcPath);
			}
			return request.zos.tempRequestCom[id];
		}else{
			throw("arguments.app_name, ""#arguments.app_name#"", is not installed on this site, but it is installed globally. Add it to this site in the Server Manager.");
		}
	}else{
		throw("arguments.app_name, ""#arguments.app_name#"", is not installed on this installation.");
	}
	</cfscript>
</cffunction>

<cffunction name="structHasApp" localmode="modern"  returntype="boolean" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="app_name" type="string" required="yes">
	<cfscript>
	if(structkeyexists(application.zcore.appComName, arguments.app_name) and structkeyexists(arguments.ss.app.appCache, application.zcore.appComName[arguments.app_name])){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="siteHasApp" localmode="modern"  returntype="boolean" output="no">
	<cfargument name="app_name" type="string" required="yes">
	<cfscript>
	if(structkeyexists(request.zos.globals, 'id') and structkeyexists(application.zcore.appComName,arguments.app_name) and structkeyexists(application.sitestruct, request.zos.globals.id) and structkeyexists(application.sitestruct[request.zos.globals.id], 'app') and structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache, application.zcore.appComName[arguments.app_name])){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="getAppData" localmode="modern"  returntype="struct" output="no">
	<cfargument name="app_name" type="string" required="yes">
	<cfscript>
	// structkeyexists(application.zcore.appComName,arguments.app_name) and 
	appCache=application.sitestruct[request.zos.globals.id].app.appCache;
	name=application.zcore.appComName[arguments.app_name];
	if(structkeyexists(appCache, name)){
		return appCache[name];
	}else{
		return structnew();
	}
	</cfscript>
</cffunction>

<cffunction name="getAppById" localmode="modern"  returntype="struct" output="no">
	<cfargument name="app_id" type="numeric" required="yes">
	<cfscript>
	if(structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache,arguments.app_id)){
		return application.sitestruct[request.zos.globals.id].app.appCache[arguments.app_id];
	}else{
		return structnew();
	}
	</cfscript>
</cffunction>

<cffunction name="getInstance" localmode="modern"  returntype="struct" output="no">
	<cfargument name="app_id" type="numeric" required="yes">
	<cfscript>
	if(structkeyexists(application.sitestruct[request.zos.globals.id].app,"appCache") and structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache,arguments.app_id)){
		return application.sitestruct[request.zos.globals.id].app.appCache[arguments.app_id];
	}else{
		application.zcore.template.fail("Access denied for non-existent app_id, #arguments.app_id#, on site_id, #arguments.site_id#.");
	}
	</cfscript>
</cffunction>

<cffunction name="getInstanceOptions" localmode="modern"  returntype="struct" output="no">
	<cfargument name="app_id" type="numeric" required="yes">
	<cfscript>
	if(structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache,arguments.app_id)){
		return application.sitestruct[request.zos.globals.id].app.appCache[arguments.app_id].optionStruct;
	}else{
		return structnew();
	}
	</cfscript>
</cffunction>

<cffunction name="appendSharedStruct" localmode="modern"  returntype="boolean" output="no" hint="Returns false when application instance doesn't exist, otherwise true.">
	<cfargument name="app_id" type="numeric" required="yes">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	if(structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache,arguments.app_id)){
		StructAppend(application.sitestruct[request.zos.globals.id].app.appCache[arguments.app_id].sharedStruct,arguments.sharedStruct,true);
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
<cffunction name="replaceSharedStruct" localmode="modern"  returntype="boolean" output="no" hint="Returns false when application instance doesn't exist, otherwise true.">
	<cfargument name="app_id" type="numeric" required="yes">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	if(structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache,arguments.app_id)){
		application.sitestruct[request.zos.globals.id].app.appCache[arguments.app_id].sharedStruct=arguments.sharedStruct;
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
	
	
<cffunction name="appConfirmDelete" localmode="modern" access="remote" roles="serveradministrator"  returntype="void" hint="display confirmation dialog before deleting application.">
	<cfscript>
	var qa=0;
	
	var db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="SELECT *, count(app_x_site_id) count 
	FROM #db.table("app", request.zos.zcoreDatasource)# app 
	LEFT JOIN #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	ON app.app_id=app_x_site.app_id and
	app_x_site.site_id <> #db.param(-1)#  and 
	 app_x_site_deleted = #db.param(0)#
	WHERE app.app_id = #db.param(form.app_id)# and 
	 app.app_built_in=#db.param(0)# and 
	 app_deleted = #db.param(0)#
	GROUP BY app.app_id";
	qa=db.execute("qa");
	if(qa.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Application no longer exists.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	}
	if(qa.count NEQ 0){
		application.zcore.status.setStatus(request.zsid,"This application still has instances that must be deleted first.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	}
	</cfscript>
	<cfsavecontent variable="pagenav">
	<a href="#request.cgi_script_name#?method=appList">Applications</a> /
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("pagenav",pagenav);
	application.zcore.template.setTag("pagetitle","Confirm Deletion of Application , #qa.app_name#");
	</cfscript>
	
	<p>Deleting this application will permanently delete all configuration data associated with it.</p>
	
	<p>Are you sure you want to delete this application?</p>
	<p><button type="button" name="button1" onclick="window.location.href='#request.cgi_script_name#?method=appDelete&app_id=#form.app_id#';">Delete Application</button>&nbsp;&nbsp;&nbsp;
	<button type="button" name="button2" onclick="window.location.href='#request.cgi_script_name#?method=appList';">Cancel</button></p>
</cffunction>
	
<cffunction name="appDelete" localmode="modern" access="remote" roles="serveradministrator"  returntype="void" hint="delete application.">
	<cfscript>
	var qa=0;
	var db=request.zos.queryObject;
	
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	db.sql="SELECT *, count(app_x_site_id) count 
	FROM #db.table("app", request.zos.zcoreDatasource)# app 
	LEFT JOIN #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	ON app.app_id=app_x_site.app_id  and 
	app_x_site_deleted = #db.param(0)# and 
	app_x_site.site_id <> #db.param(-1)#
	WHERE app.app_id = #db.param(form.app_id)# and 
	app.app_built_in=#db.param(0)# and 
	app_deleted = #db.param(0)#
	GROUP BY app.app_id";
	qa=db.execute("qa");
	if(qa.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Application no longer exists.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	}
	if(qa.count NEQ 0){
		application.zcore.status.setStatus(request.zsid,"This application still has instances that must be deleted first.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	}
	application.zcore.functions.zDeleteRecord("app","app_id", request.zos.zcoreDatasource);
	application.zcore.status.setStatus(request.zsid,"Application deleted.");
	application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	</cfscript>
</cffunction> 
	
	
	
<cffunction name="appSave" localmode="modern" access="remote" roles="serveradministrator"  returntype="void" hint="saves the application data submitted by the appForm() form.">
	<cfscript>
	var ts=0;
	var d=0;
	var inheritsCorrectly=false;
	var extending=0;
	var g=0;
	var dcur=0;
	var result=0;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	form.app_id=application.zcore.functions.zso(form, 'app_id',true,'-1');
	ts=StructNew();
	ts.table="app";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(trim(form.app_name) eq ''){
		application.zcore.status.setStatus(request.zsid,"Application name is required.",form,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appForm&zsid=#request.zsid#&app_id=#form.app_id#");
	}
	if(form.app_id GT 0){ // update
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			application.zcore.status.setStatus(request.zsid,"Application must be unique and this name already exists.",form,true);
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appForm&zsid=#request.zsid#&app_id=#form.app_id#");
		}
	}else{ // insert
		form.app_id=application.zcore.functions.zInsert(ts);
		if(form.app_id EQ false){
			application.zcore.status.setStatus(request.zsid,"Application must be unique and this name already exists.",form,true);
			application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appForm&zsid=#request.zsid#&app_id=#form.app_id#");
		}
	}
	application.zcore.status.setStatus(request.zsid,"Application saved.");
	application.zcore.functions.zRedirect(request.cgi_script_name&"?method=appList&zsid=#request.zsid#");
	</cfscript>	
</cffunction>


<cffunction name="appForm" localmode="modern" access="remote" roles="serveradministrator"  returntype="void" hint="displays a form to add/edit applications.">
	<cfscript>
	
	var qdata=0;
	var pagenav=0;
	var db=request.zos.queryObject;
	application.zcore.user.requireAllCompanyAccess();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	application.zcore.functions.zSetPageHelpId("8.2.1"); 
	if(structkeyexists(form, 'app_id') EQ false){
		form.app_id='0';
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("app", request.zos.zcoreDatasource)# app 
	WHERE app_id = #db.param(form.app_id)# and 
	app_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qData=db.execute("qData");
	application.zcore.functions.zQueryToStruct(qData);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<cfsavecontent variable="pagenav">
	<a href="#request.cgi_script_name#?method=appList">Applications</a> /
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("pagenav",pagenav);
	if(form.app_id EQ 0){
		application.zcore.template.setTag("pagetitle","Add Application Instance");
	}else{
		application.zcore.template.setTag("pagetitle","Edit Application Instance");
	}
	</cfscript>
	<form class="zFormCheckDirty" action="#request.cgi_script_name#?method=appSave&app_id=#form.app_id#" method="post">
	<table class="table-list" style="border-spacing:0px;">
	<tr>
	<th>Name:</th>
	<td><input type="text" name="app_name" value="#form.app_name#"></td>
	</tr>
<tr>
<th>Built In</th>
<td>#application.zcore.functions.zInput_Boolean("app_built_in")#</td>
</tr>
	</table>
	<br />
	<button type="submit" name="submitForm">Save</button> <button type="button" name="cancel" onclick="window.location.href='#request.cgi_script_name#?method=appList';">Cancel</button>
	
	
	</form>
</cffunction>


<cffunction name="resetApplicationScope" localmode="modern" output="yes" roles="serveradministrator" access="remote" returntype="void" hint="publish the application cache">
   	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	this.onSiteStart();
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="appUpdateCache" localmode="modern" output="yes" access="public" returntype="struct" hint="publish the application cache">
	<cfargument name="site_id" type="string" required="no" default="0">
	<cfscript> 
	var db=request.zos.queryObject; 
	
	var ts=StructNew();
	db.sql="SELECT app.app_id
	FROM #db.table("site", request.zos.zcoreDatasource)# site, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("app", request.zos.zcoreDatasource)# app 
	WHERE
	app_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	site_deleted = #db.param(0)# and 
	app_x_site.site_id = site.site_id and 
	app_x_site.app_x_site_status = #db.param('1')# and 
	app.app_built_in=#db.param(0)# and 
	app.app_id=app_x_site.app_id and 
	site_active= #db.param(1)# and 
	site.site_id = #db.param(arguments.site_id)# 
	GROUP BY app_x_site.app_id";
	qa=db.execute("qa");
	siteStruct=structnew();
	if(qa.recordcount EQ 0){
		local.tempPath=application.zcore.functions.zGetDomainWritableInstallPath(application.zcore.functions.zvar("shortDomain", arguments.site_id));
		application.zcore.functions.zcreatedirectory(local.tempPath&"_cache");
		application.zcore.functions.zcreatedirectory(local.tempPath&"_cache/scripts");
		objectsave(siteStruct, local.tempPath&'_cache/scripts/appcache.bin');
		application.zcore.functions.zClearCFMLTemplateCache();
		return siteStruct;
	}
	loop query="qa"{
		siteStruct[qa.app_id]={
			sharedStruct:{site_id:arguments.site_id}
		};
	}
	arrOut=arraynew(1);
	for(n in siteStruct){
		form.app_id=n;
		form.sid=arguments.site_id;
		configCom=application.zcore.functions.zcreateobject("component", application.zcore.appComPathStruct[n].cfcPath, true);
		ts=StructNew();
		siteStruct[n].optionStruct=configCom.getCacheStruct(arguments.site_id);
	}
	if(arguments.site_id NEQ 0){
		local.tempPath=application.zcore.functions.zGetDomainWritableInstallPath(application.zcore.functions.zvar("shortDomain", arguments.site_id));
		application.zcore.functions.zcreatedirectory(local.tempPath&'_cache');
		application.zcore.functions.zcreatedirectory(local.tempPath&'_cache/scripts');
		objectsave(siteStruct, local.tempPath&'_cache/scripts/appcache.bin');
		application.zcore.functions.zClearCFMLTemplateCache();
	}
	application.zcore.resetApplicationTrackerStruct[arguments.site_id]=true;
	return siteStruct;
	</cfscript>
</cffunction>


<!--- application.zcore.app.getAvailableAppUrlIds(count); --->
<cffunction name="getAvailableAppUrlIds" localmode="modern" output="no" access="public" roles="serveradministrator" returntype="array">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="count" type="numeric" required="no" default="#1#">
	<cfscript>
	var countIndex=0;
	
	var qcheck=0;
	var siteList="";
	var lists="";
	var arrIds=0;
	var i=0;
	var n=0;
	var db=request.zos.queryObject;
	var cs=0;
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT CAST(group_concat(app_reserve_url_id SEPARATOR #db.param(',')#) AS CHAR) list 
	FROM #db.table("app_reserve", request.zos.zcoreDatasource)# app_reserve 
	WHERE site_id = #db.param(arguments.site_id)# and 
	app_reserve_deleted = #db.param(0)# 
	</cfsavecontent><cfscript>qCheck=db.execute("qCheck");
	siteList=application.zcore.functions.zvar("reservedUrlAppIds",arguments.site_id);
	lists=sitelist&qcheck.list;
	if(siteList NEQ "" and qcheck.list NEQ ""){
		lists=sitelist&","&qcheck.list;
	}
	arrIds=listtoarray(lists);
	cs=structnew();
	for(i=1;i LTE arraylen(arrIds);i++){
		cs[arrIds[i]]=1;
	}
	arrIds=arraynew(1);
	for(n=1;n LTE 250;n++){
		if(structkeyexists(cs,n) EQ false){
			arrayappend(arrIds,n);
			countIndex++;
		}
		if(countIndex GTE arguments.count){
			break;
		}
	}
	return arrIds;
	</cfscript>


</cffunction>

<!--- 
ts=StructNew();
ts.arrId=arrayNew(1);
ts.site_id=site_id;
ts.app_id=this.app_id;
rCom=application.zcore.app.reserveAppUrlId(ts);
if(rCom.isOK() EQ false){
	rCom.setStatusErrors(request.zsid);
	application.zcore.functions.zstatushandler(request.zsid);
	application.zcore.functions.zabort();
}
//application.zcore.functions.zdump(rCom.getData());
 --->
<cffunction name="reserveAppUrlId" localmode="modern" output="no" access="public" roles="serveradministrator" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qCheck="";
	var ts=StructNew();
	var rs=structnew();
	
	var fail=0;
	var n=0;
	var db=request.zos.queryObject;
	var i=0;
	var list=0;
	var arrIgnoreIds=0;

	for(id in arguments.ss.arrId){
		if(id EQ 50){
			throw("URL ID 50 is required for the feature schema system. Choose another number.");
		}
	}

	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return", true);
	if(structkeyexists(arguments.ss,'arrId') EQ false){
		rCom.setError("arguments.ss.arrId is required.",1);
		return rCom;
	}
	if(structkeyexists(arguments.ss,'app_id') EQ false){
		rCom.setError("arguments.ss.app_id is required.",2);
		return rCom;
	}
	if(structkeyexists(arguments.ss,'site_id') EQ false){
		rCom.setError("arguments.ss.site_id is required.",3);
		return rCom;
	}
	list=arraytolist(arguments.ss.arrId,"','");
	
	// check for manual site override
	fail=false;
	arrIgnoreIds=listtoarray(application.zcore.functions.zvar("reservedURLAppIds", arguments.ss.site_id));
	for(i=1;i LTE arraylen(arguments.ss.arrId);i++){
		for(n=1;n LTE arraylen(arrIgnoreIds);n++){
			if(arguments.ss.arrId[i] EQ arrIgnoreIds[n]){
				rCom.setError("Application URL ID, #arguments.ss.arrId[i]#, is already reserved.  Please select a different number.",4);
				fail=true;
			}
		}
	}
	db.sql="SELECT app_reserve_url_id FROM #db.table("app_reserve", request.zos.zcoreDatasource)# app_reserve 
	WHERE app_reserve_url_id IN (#db.trustedSQL("'#(list)#'")#) and 
	app_reserve_deleted = #db.param(0)# and
	site_id = #db.param(arguments.ss.site_id)# and 
	app_id <> #db.param(arguments.ss.app_id)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0 and fail EQ false){
		for(i=1;i LTE arraylen(arguments.ss.arrId);i++){
			ts=StructNew();
			ts.struct=structnew();
			ts.struct.app_reserve_url_id=arguments.ss.arrId[i];
			ts.struct.app_id=arguments.ss.app_id;
			ts.struct.site_id=arguments.ss.site_id;
			ts.table="app_reserve";
			ts.datasource=request.zos.zcoreDatasource;
			application.zcore.functions.zInsert(ts);
		}
		db.sql="DELETE FROM #db.table("app_reserve", request.zos.zcoreDatasource)#  
		WHERE app_reserve_url_id NOT IN (#db.trustedSQL("'#(list)#'")#) and 
		app_reserve_deleted = #db.param(0)# and
		site_id = #db.param(arguments.ss.site_id)# and 
		app_id = #db.param(arguments.ss.app_id)# ";
		qCheck=db.execute("qCheck");
		return rCom;
	}else{
			loop query="qCheck"{
			rCom.setError("Application URL ID, #qCheck.app_reserve_url_id#, is already reserved.  Please select a different number.",5);
		}
		return rCom;
	}
	return rCom;
	</cfscript>
</cffunction>

<cffunction name="selectAppUrlId" localmode="modern" returntype="string" roles="serveradministrator" output="no">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="selectedValue" type="string" required="yes">
	<cfargument name="app_id" type="string" required="yes">
	<cfargument name="excludeList" type="string" required="no" default="">
	<cfscript>
	var qD="";
	
	var i=0;
	var out="";
	var arrid=0;
	var arrManualIds=0;
	var db=request.zos.queryObject;
	var jsFunctionCallCode=0;
	db.sql="select CAST(group_concat(app_reserve_url_id SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("app_reserve", request.zos.zcoreDatasource)# app_reserve
	WHERE app_id <> #db.param(arguments.app_id)# and 
	app_reserve_deleted = #db.param(0)# and
	site_id = #db.param(form.sid)# ";
	qD=db.execute("qD");
	</cfscript>
	<cfsavecontent variable="out">
	<cfif not structkeyexists(request.zos, 'selectAppUrlIdOutputScript')>
		<cfscript>
		request.zos.selectAppUrlIdOutputScript=true;
		request.zos.selectAppUrlIdCount=0;
		request.zos.selectAppUrlIdNameStruct=structnew(); 
		savecontent variable="out2"{
			writeoutput('arrId[50]=1;'); // 50 is reserved for the feature system
			arrId=listtoarray(qD.idlist);
			for(i=1;i LTE arraylen(arrId);i++){
				writeoutput('arrId[#arrId[i]#]=1;');
			}
			arrManualIds=listtoarray(application.zcore.functions.zvar("reservedUrlAppIds", form.sid));
			for(i=1;i LTE arraylen(arrManualIds);i++){
				writeoutput('arrId[#arrManualIds[i]#]=1;');
			}
			if(arguments.excludeList NEQ ""){
				arrExclude=listtoarray(arguments.excludeList,",");
				for(i=1;i LTE arraylen(arrExclude);i++){
					arrExclude[i]=trim(arrExclude[i]);
					if(arrExclude[i] NEQ ""){
						writeoutput('arrId[#arrExclude[i]#]=1;');
					}
				}
			}
		} 
		</cfscript>
		<script>/* <![CDATA[ */
		var zapp_selectAppUrlIdCount=0;
		var zapp_selectAppUrlIdF=new Array();
		var zapp_selectAppUrlIdFI=new Array();
		var zapp_selectAppUrlIdC2=new Array(); 
		var zapp_selectAppUrlFirstLoad=true;
		function zapp_selectAppUrlIdC(o){
			if(o != undefined){ 
				zapp_selectAppUrlIdC2[o.name]=parseInt(o.options[o.selectedIndex].value);
			}
			for(var i=0;i<zapp_selectAppUrlIdF.length;i++){
				zapp_selectAppUrlId(zapp_selectAppUrlIdF[i],zapp_selectAppUrlIdFI[i]);
			}
			if(zapp_selectAppUrlFirstLoad){
				zapp_selectAppUrlFirstLoad=false;
				for(var i=0;i<zapp_selectAppUrlIdF.length;i++){
					zapp_selectAppUrlId(zapp_selectAppUrlIdF[i],zapp_selectAppUrlIdFI[i]);
				}
			}
		} 
		function zapp_selectAppUrlId(name, id){
			var arrId=new Array();
			#out2#
			var arrT=['<select name="'+name+'" id="'+name+'" size="1" onchange="zapp_selectAppUrlIdC(this)">'];
			var arrSkip=[];
			for(var n=0;n<zapp_selectAppUrlIdF.length;n++){
				if(zapp_selectAppUrlIdF[n] != name && typeof zapp_selectAppUrlIdC2[zapp_selectAppUrlIdF[n]] != "undefined"){
					arrSkip[zapp_selectAppUrlIdC2[zapp_selectAppUrlIdF[n]]]=1;
				}
			} 
			for(var i=1;i<=250;i++){
				var ch=""; 
				if(zapp_selectAppUrlIdC2[name] != undefined && zapp_selectAppUrlIdC2[name] == i){
					var ch=" selected ";
				} 

				if(typeof arrId[i] == "undefined" && typeof arrSkip[i] == "undefined"){ 
					if(typeof zapp_selectAppUrlIdC2[name] == "undefined"){
						zapp_selectAppUrlIdC2[name]=i; 
					} 
					arrT.push('<option value="'+i+'" '+ch+'>'+i+'<\/option>');
				}
			} 
			arrT.push('<\/select>');
			var hd=document.getElementById('zapp_selectAppUrlIdDiv'+id);
			hd.innerHTML=arrT.join("");
		}/* ]]> */
		</script>
		<cfscript>
		jsFunctionCallCode='<script>/* <![CDATA[ */zapp_selectAppUrlIdC();/* ]]> */</script>';
		application.zcore.template.appendTag("content", jsfunctionCallCode);
		</cfscript>
	</cfif>
	<cfscript>
	request.zos.selectAppUrlIdCount++;
	if(structkeyexists(request.zos.selectAppUrlIdNameStruct,arguments.name)){
		application.zcore.template.fail("The name, ""#arguments.name#"", has already been used with another function call.  Please make it unique.");
	}
	request.zos.selectAppUrlIdNameStruct[arguments.name]=true;
	</cfscript>
	<div id="zapp_selectAppUrlIdDiv#request.zos.selectAppUrlIdCount#"></div>
	<script>/* <![CDATA[ */
	<cfscript>
	if(arguments.selectedValue NEQ ""){
		writeoutput('zapp_selectAppUrlIdC2["'&arguments.name&'"]=parseInt("#jsstringformat(arguments.selectedValue)#");');
	}
	</cfscript>
	zapp_selectAppUrlIdF.push("#arguments.name#");
	zapp_selectAppUrlIdFI.push(#request.zos.selectAppUrlIdCount#);
	/* ]]> */
	</script>
	</cfsavecontent>
	<cfscript>
	return out;
	</cfscript>
</cffunction>
	
	
<cffunction name="onSiteStart" localmode="modern" access="public" output="yes" returntype="void" hint="initialize application scope for current site.">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=0;
	var i=0;
	var configCom=0;
	var cfcatch=0;
	var n=0;
	var e=0;
	var loaded=false;
	var fileOldAbsPath=request.zos.globals.privatehomedir&'_cache/scripts/appsettings.bin';
	var fileAbsPath=request.zos.globals.privatehomedir&'_cache/scripts/appcache.bin';
	ts=StructNew();			
	if(fileexists(fileOldAbsPath)){
		application.zcore.functions.zDeleteFile(fileOldAbsPath);
	}
	if(fileexists(fileAbsPath)){
		try{
			ts=objectload(fileAbsPath);
			loaded=true;
		}catch(Any local.e){
			application.zcore.functions.zdeletefile(fileAbsPath);
		}
	}
	if(not loaded){
		ts=this.appUpdateCache(arguments.ss.site_id);
	}
	for(i in ts){
		configCom=createobject("component", application.zcore.appComPathStruct[i].cfcPath); 
		configCom.site_id=request.zos.globals.id;   
		ts[i].sharedStruct=configCom.onSiteStart(ts[i].sharedStruct);   
		if(application.zcore.appComPathStruct[i].cache){
			ts[i].cfcCached=configCom;
		}
	}
	arguments.ss.app={appCache:ts, functionCompleted:true}; 
	</cfscript>
</cffunction>
	
	
<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var i=0;
	var n=0;
	var db=request.zos.queryObject;
	var configCom=0;
	var r='<script>zBindEvent(window, ''load'', zWindowOnLoad);</script>';
	var qI=0;
	
	//arrayappend(arguments.ss.js, "/z/javascript/jquery/balupton-history/scripts/uncompressed/json2.js");
	
	// check for jquery ui
	if(structkeyexists(request.zos.globals,'enableJqueryUI') and request.zos.globals.enableJqueryUI EQ 1){
		arrayappend(arguments.ss.js, "/z/javascript/jquery/jquery-ui/jquery-ui-1.10.3.min.js");
		arrayappend(arguments.ss.css, "/z/javascript/jquery/jquery-ui/jquery-ui-1.10.3.min.css");
	}
	
	// check for slideshows
	db.sql="select slideshow_id from #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	slideshow_deleted = #db.param(0)#";
	qI=db.execute("qI"); 
	if(qI.recordcount NEQ 0){
		arrayappend(arguments.ss.js, "/z/javascript/jquery/jquery.cycle.all.js");
		arrayappend(arguments.ss.js, "/z/javascript/jquery/Slides/source/slides.jquery-new.js");
	}
	arrayprepend(arguments.ss.css, "/z/stylesheets/zOS.css"); 
	
	arrayappend(arguments.ss.css, "/z/stylesheets/css-framework.css");
	arrayappend(arguments.ss.css, "/z/javascript/jquery/galleryview-1.1/jquery.galleryview-3.0-dev.css");
	arrayappend(arguments.ss.js, "/z/javascript/jquery/jquery.easing.1.3.js");
	arrayappend(arguments.ss.js, "/z/javascript/jquery/galleryview-1.1/jquery.galleryview-3.0-dev.js");
	arrayappend(arguments.ss.js, "/z/javascript/jquery/galleryview-1.1/jquery.timers-1.2.js"); 
	
	for(i in application.sitestruct[request.zos.globals.id].app.appCache){
		configCom=application.zcore.functions.zcreateobject("component", application.zcore.appComPathStruct[i].cfcPath, true);
		configCom.site_id=request.zos.globals.id;
		configCom.getCSSJSIncludes(arguments.ss);
	} 
	for(i=1;i LTE arraylen(application.zcore.arrJsFiles);i++){
		arrayappend(arguments.ss.js, application.zcore.arrJsFiles[i]);
	}
	if(not structkeyexists(request.zos, 'includeManagerStylesheet') and not request.zos.inMemberArea){ 
		/*if(structkeyexists(request.zos.globals, 'enableCSSFramework') and request.zos.globals.enableCSSFramework EQ 1){
			arrayappend(arguments.ss.css, "/z/stylesheets/enable-css-framework.css");
		}*/
		arrayappend(arguments.ss.css, "/zupload/layout-global.css");
	}else{
		if(request.zos.isTestServer){
			link=request.zos.zcoreTestAdminDomain&application.zcore.skin.getVersionURL("/zupload/layout-global.css");
		}else{
			link=request.zos.zcoreAdminDomain&application.zcore.skin.getVersionURL("/zupload/layout-global.css");
		}
		arrayappend(arguments.ss.css, link);
	}
	if(not structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, request.zos.globals.privatehomedir&"zcache/zsystem.css")){
		application.sitestruct[request.zos.globals.id].fileExistsCache[request.zos.globals.privatehomedir&"zcache/zsystem.css"]=fileexists(request.zos.globals.privatehomedir&"zcache/zsystem.css");
	}
	if(application.sitestruct[request.zos.globals.id].fileExistsCache[request.zos.globals.privatehomedir&"zcache/zsystem.css"]){
		arrayappend(arguments.ss.css, "/zcache/zsystem.css");
	}
	
	</cfscript>
</cffunction>

	
<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="sitemap the adhere to sitemaps.org protocol">
	<cfargument name="arrUrl" type="array" required="no" default="#arraynew(1)#">
	<cfscript>
	var configCom=0;
	var i=0;
	var n=0;
	if(structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'getSiteMap')){
		arguments.arrUrl=application.sitestruct[request.zos.globals.id].zcorecustomfunctions.getSiteMap(arguments.arrUrl);
	}
	arguments.arrURL=application.zcore.siteOptionCom.getSiteMap(arguments.arrURL);
	arguments.arrURL=application.zcore.featureCom.getSiteMap(arguments.arrURL);

	//arguments.arrURL=getMVCLandingPages(arguments.arrURL);
	
	for(i in application.sitestruct[request.zos.globals.id].app.appCache){
		configCom=createObject("component", application.zcore.appComPathStruct[i].cfcPath);
		configCom.site_id=request.zos.globals.id;
		arguments.arrURL=configCom.getSiteMap(arguments.arrUrl);
	}
	return arguments.arrURL;
	</cfscript>
</cffunction>
	
<cffunction name="onRequestEnd" localmode="modern" output="no" access="public"  returntype="string">
	<cfscript>
	var i=0;
	var output="";		
	savecontent variable="output"{
		for(i in application.sitestruct[request.zos.globals.id].app.appCache){
			if(structkeyexists(request.zos.tempRequestCom, i)){
				request.zos.tempRequestCom[i].onRequestEnd();
			}
		}
	}
	return trim(output);
	</cfscript>
</cffunction>
	
<cffunction name="onRequestStart" localmode="modern" output="no" access="public"  returntype="string">
	<cfscript>
	var n=0;
	var i=0;
	var curVersion=1; // change this number to force all application scope component to re-generate
	var output="";		
	var zrst=request.zos.zreset;
	savecontent variable="output"{
		if(structkeyexists(application.zcore,'runMemoryDatabaseStart')){
			structdelete(application.zcore, 'runMemoryDatabaseStart');
			for(i in application.zcore.appComPathStruct){
				currentCom=createobject("component", application.zcore.appComPathStruct[i].cfcPath);
				if(structkeyexists(currentCom, 'onMemoryDatabaseStart')){
					currentCom.onMemoryDatabaseStart();
				}
			}
		}
		if(structkeyexists(application.sitestruct[request.zos.globals.id].app, 'functionCompleted') EQ false){
			this.onSiteStart(application.sitestruct[request.zos.globals.id]);
		}
		for(i in application.sitestruct[request.zos.globals.id].app.appCache){
			if(i EQ 11 or i EQ 13){ // rental and listing apps are not thread-safe yet due to cfinclude and var scoping
				request.zos.tempRequestCom[i]=createObject("component", application.zcore.appComPathStruct[i].cfcPath);
			}else{
				if(structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache[i], 'cfcCached') EQ false){
					request.zos.tempRequestCom[i]=createObject("component", application.zcore.appComPathStruct[i].cfcPath);
				}else{
					request.zos.tempRequestCom[i]=application.sitestruct[request.zos.globals.id].app.appCache[i].cfcCached;
				}
			}
			request.zos.tempRequestCom[i].site_id=request.zos.globals.id;
		}
		for(i in application.sitestruct[request.zos.globals.id].app.appCache){
			request.zos.tempRequestCom[i].onRequestStart();
		}
	}
	return trim(output);
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>