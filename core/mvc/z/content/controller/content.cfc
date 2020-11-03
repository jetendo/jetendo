<!--- 
TODO:
prevent duplicate search criteria or titles
make a script that lets you browse for another file to link to on this page.
drag and drop sorting and content tree heirarchy interface
more options for the site owner to reconfigure the site
add fields to set location of content (listing) on google map (using address or lat/long or mls lat/long)
 ---->
<cfcomponent displayname="content" hint="Content Application">
<cfoutput>
<cfscript>
this.app_id=12;
</cfscript>

<cffunction name="onSiteStart" localmode="modern" output="no" access="public"  returntype="struct" hint="Runs on application start and should return arguments.sharedStruct">
	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
	<cfscript>
	updateContentAccessCache(arguments.sharedStruct);
	return arguments.sharedStruct;
	</cfscript>
</cffunction>

<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
</cffunction>

<cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="initExcludeContentId" localmode="modern" output="no" returntype="any">
	<cfscript>
	request.cArrExcludedContentIDs=arraynew(1);
	</cfscript>
</cffunction>

<cffunction name="getExcludeContentId" localmode="modern" output="no" returntype="array">
	<cfscript>
	return request.cArrExcludedContentIDs;
	</cfscript>
</cffunction>
<cffunction name="excludeContentId" localmode="modern" output="no" returntype="any">
	<cfargument name="content_id" type="string" required="yes">
	<cfscript>
	arrayappend(request.cArrExcludedContentIDs, arguments.content_id);
	</cfscript>
</cffunction>


<cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	var qa="";
	var rs="";
	var c1="";
	var db=request.zos.queryObject;
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	where site_id = #db.param(arguments.site_id)# and 
	app_x_site_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qa=db.execute("qa");
	if(application.zcore.functions.zvar('live',qa.site_id) EQ 1){
		rs&="Sitemap: "&application.zcore.functions.zvar('domain',qa.site_id)&"/sitemap.xml.gz"&chr(10);
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
	<cfargument name="arrUrl" type="array" required="yes">
	<cfscript>
	var ts=application.zcore.app.getInstance(this.app_id);
	var db=request.zos.queryObject;
	</cfscript>
	<cfsavecontent variable="returnText">
		<cfsavecontent variable="db.sql">
		SELECT *, count(*) count 
		FROM #db.table("content", request.zos.zcoreDatasource)# content, 
		#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s 
		WHERE content.site_id = #db.param(request.zos.globals.id)# and 
		content_parent_id = #db.param(0)# and 
		content_for_sale <> #db.param(2)# and 
		content_deleted=#db.param(0)# and 
		content_user_group_id =#db.param(0)# and 
		content_show_site_map = #db.param(1)# and 
		content.site_x_option_group_set_id <> #db.param(0)# and 
		content.site_x_option_group_set_id = s.site_x_option_group_set_id and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		content.site_id = s.site_id and 
		s.site_x_option_group_set_deleted = #db.param(0)#
		group by content.site_x_option_group_set_id
		order by s.site_x_option_group_set_title ASC
		</cfsavecontent><cfscript>qsection=db.execute("qsection");
		</cfscript>
		<cfloop query="qsection">
			<cfscript>
			pages=ceiling(qsection.count/10);
			t2=StructNew();
			t2.groupName="Content Sections";
			currentLink=request.zos.currentHostName&getSectionHomeLink(qsection.site_x_option_group_set_id);
			t2.url=currentLink;
			t2.title=qsection.site_x_option_group_set_title&" Pages";
			arrayappend(arguments.arrUrl,t2);
			for(i=2;i LTE pages;i++){
				t2=StructNew();
				t2.groupName="Page Sections";
				t2.url=request.zos.currentHostName&currentLink&"?zIndex=#i#";
				t2.title=qsection.site_x_option_group_set_title&" Pages (page #i#)";
				arrayappend(arguments.arrUrl,t2);
			}
			</cfscript>
		</cfloop>

		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE content.site_id = #db.param(request.zos.globals.id)# and 
		content_parent_id = #db.param(0)# and 
		content_for_sale <> #db.param(2)# and 
		content_deleted=#db.param(0)# and 
		content_user_group_id =#db.param(0)#
		and content_show_site_map = #db.param(1)#
		ORDER BY content_name ASC
		</cfsavecontent><cfscript>qContent=db.execute("qContent");
		request.allTempIds=StructNew();
		childStruct=application.zcore.app.getAppCFC("content").getAllContent(qContent,0,0,structnew(),false," and content_for_sale <> 2 and content_show_site_map = 1 ",true);//and content_hide_link = #db.param(0)# ");
		for(i=1;i LTE arraylen(childStruct.arrContentId);i++){
			t2=StructNew();
			t2.groupName="Content";
			if(childStruct.arrContentUrlOnly[i] NEQ ''){
				t2.url=application.zcore.functions.zForceAbsoluteURL(request.zos.currentHostName, childStruct.arrContentUrlOnly[i]);
			}else if(childStruct.arrContentUniqueName[i] NEQ ''){
				t2.url=request.zos.currentHostName&childStruct.arrContentUniqueName[i];
			}else{
				if(childStruct.arrIndent[i] NEQ ""){
					c1=replace(childStruct.arrContentName[i], childStruct.arrIndent[i],"","one");
				}else{
					c1=childStruct.arrContentName[i];
				}
				t2.url=request.zos.currentHostName&"/#application.zcore.functions.zURLEncode(c1,'-')#-#ts.optionStruct.content_config_url_article_id#-#childStruct.arrContentId[i]#.html";
			}
			if(isdate(childStruct.arrContentUpdatedDatetime[i])){
				t2.lastmod=dateformat(childStruct.arrContentUpdatedDatetime[i],'yyyy-mm-dd');//2005-05-10T17:33:30+08:00
			}else{
				t2.lastmod=dateformat(now(),'yyyy-mm-dd');//2005-05-10T17:33:30+08:00
			}
			t2.indent=replace(childStruct.arrIndent[i],"_","  ","ALL");
			t2.title=replace(childStruct.arrContentName[i],"_"," ","ALL");
			arrayappend(arguments.arrUrl,t2);
		}
		</cfscript>	
	</cfsavecontent>
	<cfreturn arguments.arrUrl>
</cffunction>

<!--- recurse all content_id and build an array of struct.name struct.id ---->
<!--- application.zcore.app.getAppCFC("content").getAllContent(qAll,0,content_id); --->
<cffunction name="getAllContent" localmode="modern" output="yes" returntype="any">
<cfargument name="arrQuery" required="yes" type="query">
<cfargument name="level" required="no" type="any" default="#0#">
<cfargument name="filterId" required="no" type="any" default="#false#">
<cfargument name="usedId" required="no" type="struct" default="#structnew()#">
<cfargument name="cropTitle" required="no" type="boolean" default="#true#">
<cfargument name="whereSQL" required="no" type="string" default="">
<cfscript>
	var cs=StructNew();
	var i=0;
	var g=0;
	var qChildren="";
	var rs=StructNew();
	var allowId=false;
	var spaces="";
	var db=request.zos.queryObject;

	rs.arrContentName=ArrayNew(1);
	rs.arrContentId=ArrayNew(1);
	rs.arrContentUrlOnly=ArrayNew(1);
	rs.arrContentUniqueName=ArrayNew(1);
	rs.arrContentUpdatedDatetime=ArrayNew(1);
	rs.arrIndent=ArrayNew(1);
	for(g=0;g LT arguments.level;g=g+1){
		spaces=spaces&"__";
	}
	loop query="arguments.arrQuery"{
		if(arguments.arrQuery.content_id EQ 0){
			throw("This site has a content record where content_id=0.  It must be manually deleted;<br>
			delete from content where content_id = 0 and site_id = #request.zos.globals.id#;");
		}
		if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false){
			allowId=false;
			if(structkeyexists(request.allTempIds,arguments.arrQuery.content_id) EQ false){
				allowId=true;
				StructInsert(request.allTempIds, arguments.arrQuery.content_id,true,true);
			}
		}else{
			allowId=true;
		}
		if(allowId){
			if(arguments.cropTitle){
				ArrayAppend(rs.arrContentName, spaces&left(replace(arguments.arrQuery.content_name,chr(9)," ","ALL"),80));
			}else{
				ArrayAppend(rs.arrContentName, spaces&replace(arguments.arrQuery.content_name,chr(9)," ","ALL"));
			}
			ArrayAppend(rs.arrIndent, spaces);
			ArrayAppend(rs.arrContentId, arguments.arrQuery.content_id); 
			ArrayAppend(rs.arrContentUrlOnly, arguments.arrQuery.content_url_only);
			ArrayAppend(rs.arrContentUniqueName, arguments.arrQuery.content_unique_name);
			if(arguments.arrQuery.content_updated_datetime EQ ""){
				ArrayAppend(rs.arrContentUpdatedDatetime, request.zos.mysqlnow);
			}else{
				ArrayAppend(rs.arrContentUpdatedDatetime, arguments.arrQuery.content_updated_datetime);
			}
			if(arguments.filterID NEQ arguments.arrQuery.content_id){
				db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				content_parent_id = #db.param(arguments.arrQuery.content_id)# and 
				content_deleted=#db.param(0)#  ";
				if(arguments.whereSQL NEQ ""){
					db.sql&=" #db.trustedsql(arguments.whereSQL)# ";
				}
				db.sql&=" ORDER BY content_name ASC";
				qChildren=db.execute("qChildren"); 
				if(qchildren.recordcount NEQ 0){
					cs=getAllContent(qChildren,arguments.level+1,arguments.filterId,arguments.usedid,arguments.cropTitle, arguments.whereSQL);
					for(i=1;i LTE ArrayLen(cs.arrContentName);i++){
						ArrayAppend(rs.arrIndent, cs.arrIndent[i]);
						ArrayAppend(rs.arrContentName, cs.arrContentName[i]);
						ArrayAppend(rs.arrContentId, cs.arrContentId[i]);
						ArrayAppend(rs.arrContentUrlOnly, cs.arrContentUrlOnly[i]);
						ArrayAppend(rs.arrContentUniqueName, cs.arrContentUniqueName[i]);
						if(cs.arrContentUpdatedDatetime[i] EQ ""){
							ArrayAppend(rs.arrContentUpdatedDatetime, request.zos.mysqlnow);
						}else{
							ArrayAppend(rs.arrContentUpdatedDatetime, cs.arrContentUpdatedDatetime[i]);
						} 
					}
				}
			}
		}
	}
	return rs;
	</cfscript>
</cffunction>



<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	var ts=0;
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		if(structkeyexists(arguments.linkStruct,"Content Manager") EQ false){
			ts=structnew();
			ts.featureName="Content Manager";
			ts.link='/z/content/admin/content-admin/index';
			ts.children=structnew();
			arguments.linkStruct["Content Manager"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Pages") EQ false){
			ts=structnew();
			ts.featureName="Pages";
			ts.link='/z/content/admin/content-admin/index';
			arguments.linkStruct["Content Manager"].children["Pages"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Add Page") EQ false){
			ts=structnew();
			ts.featureName="Pages";
			ts.link='/z/content/admin/content-admin/add';
			arguments.linkStruct["Content Manager"].children["Add Page"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Files &amp; Images") EQ false){
			ts=structnew();
			ts.featureName="Files & Images";
			ts.link="/z/admin/files/index";  
			arguments.linkStruct["Content Manager"].children["Files &amp; Images"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Video Library") EQ false){
			ts=structnew();
			ts.featureName="Video Library";
			ts.link="/z/_com/app/video-library?method=videoform";  
			arguments.linkStruct["Content Manager"].children["Video Library"]=ts;
		} 
		if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Short Links") EQ false){
			ts=structnew();
			ts.featureName="Short Links";
			ts.link="/z/admin/short-link/index";  
			arguments.linkStruct["Content Manager"].children["Short Links"]=ts;
		} 
		/*
		if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Advanced Spell/Grammar Check") EQ false){
			ts=structnew();
			ts.featureName="Pages";
			ts.link="/z/admin/admin-home/spellCheck";
			arguments.linkStruct["Content Manager"].children["Advanced Spell/Grammar Check"]=ts;
		}
		*/
		if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Site Options") EQ false){
			ts=structnew();
			ts.featureName="Site Options";
			ts.link="/z/admin/site-options/index";
			arguments.linkStruct["Content Manager"].children["Site Options"]=ts;
		}  
		if(application.zcore.functions.zso(request.zos.globals, 'enableManageSlideshow', true, 0) EQ 1){
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Slideshows") EQ false){
				ts=structnew();
				ts.featureName="Slideshows";
				ts.link="/z/admin/slideshow/index";
				arguments.linkStruct["Content Manager"].children["Slideshows"]=ts;
			}
		}   
		if(request.zos.isdeveloper){
			if(structkeyexists(arguments.linkStruct["Content Manager"].children, "Settings") EQ false){
				ts=structnew();
				ts.featureName="Settings";
				ts.link="/z/admin/settings/index";  
				arguments.linkStruct["Content Manager"].children["Settings"]=ts;
			} 
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Custom Groups") EQ false){
				ts=structnew();
				ts.featureName="Groups";
				ts.link="/z/admin/site-option-group/index?site_option_app_id=0";
				arguments.linkStruct["Content Manager"].children["Custom Groups"]=ts;
			}    
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Features") EQ false){
				ts=structnew();
				ts.featureName="Features";
				ts.link="/z/feature/admin/feature-manage/index";
				arguments.linkStruct["Content Manager"].children["Features"]=ts;
			} 
		}
		/*if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Add Slideshow") EQ false){
			ts=structnew();
			ts.featureName="Slideshows";
			ts.link="/z/admin/slideshow/add";
			arguments.linkStruct["Content Manager"].children["Add Slideshow"]=ts;
		}	*/
		if(application.zcore.functions.zso(request.zos.globals, 'enableManageMenu', true, 0) EQ 1){
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Menus") EQ false){
				ts=structnew();
				ts.featureName="Menus";
				ts.link="/z/admin/menu/index";
				arguments.linkStruct["Content Manager"].children["Menus"]=ts;
			}   
		}
		if(application.zcore.functions.zso(request.zos.globals, 'lockTheme', true, 1) EQ 0){
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Themes") EQ false){
				ts=structnew();
				ts.featureName="Themes";
				ts.link="/z/admin/theme/index";
				arguments.linkStruct["Content Manager"].children["Themes"]=ts;
			}	
		}
		/*if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Add Menu") EQ false){
			ts=structnew();
			ts.featureName="Menus";
			ts.link="/z/admin/menu/add";
			arguments.linkStruct["Content Manager"].children["Add Menu"]=ts;
		}*/
		if(application.zcore.functions.zso(request.zos.globals, 'enableProblemLinkReport', true, 0) EQ 1){
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Problem Link Report") EQ false){
				ts=structnew();
				ts.featureName="Problem Link Report";
				ts.link="/z/admin/site-report/index";
				arguments.linkStruct["Content Manager"].children["Problem Link Report"]=ts;
			}
		}
		if(request.zos.isdeveloper){ 
			if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Layouts") EQ false){
				ts=structnew();
				ts.featureName="Layouts";
				ts.link="/z/admin/layout-page/index";
				arguments.linkStruct["Content Manager"].children["Layouts"]=ts;
			}
			if(request.zos.istestserver){
				/*
				if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Sections") EQ false){
					ts=structnew();
					ts.featureName="Sections";
					ts.link="/z/section/admin/section-admin/index";
					arguments.linkStruct["Content Manager"].children["Sections"]=ts;
				}*/
				/*
				if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Theme Options") EQ false){
					ts=structnew();
					ts.featureName="Theme Options";
					ts.link="/z/admin/theme-options/index";
					arguments.linkStruct["Content Manager"].children["Theme Options"]=ts;
				}*/
				/*if(structkeyexists(arguments.linkStruct["Content Manager"].children,"Design &amp; Layout") EQ false){
					ts=structnew();
					ts.featureName="Design & Layout";
					ts.link="/z/admin/template/index";
					arguments.linkStruct["Content Manager"].children["Design &amp; Layout"]=ts;
				}*/
			} 
		}
	}
	return arguments.linkStruct;
	</cfscript>
</cffunction>

<cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfscript>
	var qdata=0;
	var ts=StructNew();
	var qdata=0;
	var arrcolumns=0;
	var i=0;
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("content_config", request.zos.zcoreDatasource)# content_config 
	where 
	site_id = #db.param(arguments.site_id)# and 
	content_config_deleted = #db.param(0)#";
	qData=db.execute("qData");
	for(row in qData){
		return row;
	}
	throw("config_config record is missing for site_id=#arguments.site_id#.");
	</cfscript>
</cffunction>

<cffunction name="isContentPage" localmode="modern" output="no" returntype="boolean">
	<cfscript>
	if(request.cgi_script_name EQ "/z/content/content/viewPage"){
		return true;	
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var theText="";
	var qconfig=0;
	var t9=0;
	var qcontent=0;
	var link=0;
	var t999=0;
	var pos=0;
	db.sql="SELECT * FROM #db.table("content_config", request.zos.zcoreDatasource)# content_config, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_id = app_x_site.site_id and 
	app_x_site.site_id = content_config.site_id and 
	content_config.site_id = #db.param(arguments.site_id)# and 
	content_config_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	site_deleted = #db.param(0)#";
	qConfig=db.execute("qConfig");
	db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content WHERE
	content_system_url=#db.param(0)# and 
	 site_id = #db.param(qConfig.site_id)# and 
	 content_unique_name <> #db.param('')# and  
	 content_unique_name <> #db.param('/')# and 
	 content_unique_name NOT LIKE #db.param('/z/%')# and 
	 content_deleted=#db.param(0)# 
	ORDER BY content_deleted ASC, content_for_sale ASC, content_unique_name DESC, content_url_only ASC ";
	qContent=db.execute("qContent");
	 // content_url_only = #db.param('')# and 
	loop query="qConfig"{
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.content_config_url_article_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.content_config_url_section_id]=[];
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/content/content/viewPage";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/viewPage";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="content_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.content_config_url_article_id],t9);
		if(qConfig.content_config_url_listing_user_id NEQ 0 and qConfig.content_config_url_listing_user_id NEQ ""){
			arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.content_config_url_listing_user_id]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/listing/agent-listings/index";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/listing/agent-listings/index";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="content_listing_user_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.content_config_url_listing_user_id],t9);
		}
		t999=application.zcore.functions.zvar('contenturlid',qConfig.site_id);
		if(t999 NEQ 0 and t999 NEQ ''){
			arguments.sharedStruct.reservedAppUrlIdStruct[t999]=arraynew(1);
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/content/content/viewPage";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/viewPage";
			t9.mapStruct=structnew();
			t9.mapStruct.entireURL="content_unique_name";
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="content_listing_user_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[t999],t9);
			
		}

		if(qConfig.content_config_url_section_id NEQ 0){
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/content/content/displayContentSection";
			t9.ifStruct=structnew();
			t9.ifStruct.ext="html";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/displayContentSection";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			t9.mapStruct.dataId="site_x_option_group_set_id";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.content_config_url_section_id],t9);
		}
	}
	loop query="qContent"{
		t9=structnew();
		t9.scriptName="/z/content/content/viewPage";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/viewPage";
		t9.urlStruct.content_id=qcontent.content_id;
		arguments.sharedStruct.uniqueURLStruct[trim(qContent.content_unique_name)]=t9;
	}
	</cfscript>
</cffunction>



<cffunction name="updateRewriteRuleContent" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content WHERE
	content_system_url=#db.param(0)# and 
	 site_id = #db.param(request.zos.globals.id)# and 
	 content_unique_name <> #db.param('')# and  
	 content_unique_name <> #db.param('/')# and 
	 content_unique_name NOT LIKE #db.param('/z/%')# and 
	 content_url_only = #db.param('')# and  
	 content_id = #db.param(arguments.id)# and 
	 content_deleted=#db.param(0)# ";
	qF=db.execute("qF"); 
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/content/content/viewPage";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/content/content/viewPage";
		t9.urlStruct.content_id=qF.content_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.content_unique_name)]=t9;
	}
	return true;
	</cfscript>
</cffunction>
	
<cffunction name="updateRewriteRules" localmode="modern" output="no" access="public" returntype="boolean">
	<cfscript>
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	return true;
	</cfscript>
</cffunction>

<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from config table.">
	<!--- delete all content and content_group and images? --->
	<cfscript>
	var db=request.zos.queryObject;
	var qconfig=0;
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	db.sql="DELETE FROM #db.table("content_config", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	content_config_deleted = #db.param(0)#	";
	qConfig=db.execute("qConfig");
	return rCom;
	</cfscript>   
</cffunction>

<cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="validate" required="no" type="boolean" default="#false#">
	<cfscript>
	var field="";
	var i=0;
	var error=false;
	var df=structnew();
	df.content_config_url_article_id="6";
	for(i in df){	
		if(arguments.validate){
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
				error=true;
				field=trim(lcase(replacenocase(replacenocase(i,"content_config_",""),"_"," ","ALL")));
				application.zcore.status.setStatus(request.zsid,"#field# is required.",form);
			}
		}else{
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){			
				form[i]=df[i];
			}
		}
	}
	if(error){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="configSave" localmode="modern" output="no" access="remote" returntype="any" hint="saves the application data submitted by the change() form.">
	<cfscript>
	var ts=StructNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var result='';
	if(this.loadDefaultConfig(true) EQ false){
		rCom.setError("Please correct the above validation errors and submit again.",1);
		return rCom;
	}	
	ts=StructNew();
	ts.arrId=arrayNew(1);
	arrayappend(ts.arrId,trim(form.content_config_url_article_id));
	arrayappend(ts.arrId,trim(form.content_config_url_section_id));
	if(form.content_config_url_listing_user_id NEQ ""){
		arrayappend(ts.arrId,trim(form.content_config_url_listing_user_id));
	}
	form.site_id=form.sid;
	ts.site_id=form.site_id;
	ts.app_id=this.app_id;
	rCom=application.zcore.app.reserveAppUrlId(ts);
	if(rCom.isOK() EQ false){
		return rCom;
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=configForm&app_x_site_id=#this.app_x_site_id#&zsid=#request.zsid#");
		application.zcore.functions.zabort();
	}		
	ts.table="content_config";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zso(form, 'content_config_id',true) EQ 0){ // insert
		result=application.zcore.functions.zInsert(ts);
		if(result EQ false){
			rCom.setError("Failed to save configuration.",2);
			return rCom;
		}
	}else{ // update
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			rCom.setError("Failed to save configuration.",3);
			return rCom;
		}
	}
	application.zcore.status.setStatus(request.zsid,"Configuration saved.");
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
   	<cfscript>
	var db=request.zos.queryObject;
	var ts='';
	var selectStruct='';
	var rs=structnew();
	var qConfig='';
	var theText='';
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	savecontent variable="theText"{
		db.sql="SELECT * FROM #db.table("content_config", request.zos.zcoreDatasource)# content_config 
		WHERE site_id = #db.param(form.sid)# and 
		content_config_deleted = #db.param(0)#";
		qConfig=db.execute("qConfig");
		application.zcore.functions.zQueryToStruct(qConfig);//, "configStruct");
		if(qConfig.recordcount EQ 0){
			this.loadDefaultConfig();
		}
		application.zcore.functions.zStatusHandler(request.zsid,true);
		echo('<input type="hidden" name="content_config_id" value="#form.content_config_id#" />
		<table style="border-spacing:0px;" class="table-list">
		<tr>
		<th>URL Article ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("content_config_url_article_id", form.content_config_url_article_id, this.app_id));
		echo('</td>
		</tr>
		<tr>
		<th>Sidebar Tag</th>
		<td>');
		ts=StructNew();
		ts.label="";
		ts.name="content_config_sidebar_tag";
		ts.size="20";
		application.zcore.functions.zInput_Text(ts);
		echo(' (i.e. type "sidebar" for &lt;z_sidebar&gt;)</td>
		</tr>
		
		<tr>
		<th>Default Parent Page<br />Link Layout</th>
		<td>');
		selectStruct = StructNew();
		selectStruct.name = "content_config_default_parentpage_link_layout";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Invisible,Top with numbered columns,Top with columns,Top on one line";//,Bottom with summary (default),Bottom without summary,Left Sidebar,Right Sidebar";
		selectStruct.listValues = "7,2,3,4";//,0,1,5,6";
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>
		<tr>
		<th>Default Sub-page<br />Link Layout</th>
		<td>');
		if(application.zcore.functions.zso(form, 'content_config_default_subpage_link_layout') EQ ''){
			form.content_config_default_subpage_link_layout=0;
		}
		selectStruct = StructNew();
		selectStruct.name = "content_config_default_subpage_link_layout";
		selectStruct.hideSelect=true;
		selectStruct.listLabels="Invisible,Bottom with summary (default),Bottom without summary,Top with numbered columns,Top with columns,Top on one line,Custom";//,Left Sidebar,Right Sidebar";
		selectStruct.listValues = "7,0,1,2,3,4,13";//,5,6";
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo('</td>
		</tr>
		<tr>
		<th>URL Agent ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("content_config_url_listing_user_id", form.content_config_url_listing_user_id, this.app_id));
		echo(' (This is used for viewing agent listings)</td>
		</tr>
		<tr>
		<th>URL Section ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("content_config_url_section_id", form.content_config_url_section_id, this.app_id));
		echo(' </td>
		</tr>
		<tr>
		<th>Section Title Affix:</th>
		<td>');
		ts = StructNew();
		ts.name = "content_config_section_title_affix";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		
		<tr>
		<th>Child Display Limit</th>
		<td>');
		form.content_config_child_display_limit=application.zcore.functions.zso(form, 'content_config_child_display_limit', true, 20);
		if(form.content_config_child_display_limit EQ 0){
			form.content_config_child_display_limit=20;
		}
		ts = StructNew();
		ts.name = "content_config_child_display_limit";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Contact Links?</th>
		<td>');
		form.content_config_contact_links=application.zcore.functions.zso(form, 'content_config_contact_links',true,0);
		if(form.content_config_contact_links EQ ""){
			form.content_config_contact_links=0;
		}
		ts = StructNew();
		ts.name = "content_config_contact_links";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' (No, Removes the options from entire site)</td>
		</tr>
		<tr>
		<th>Inquiry Qualify?</th>
		<td>');
		form.content_config_inquiry_qualify=application.zcore.functions.zso(form, 'content_config_inquiry_qualify',true);
		ts = StructNew();
		ts.name = "content_config_inquiry_qualify";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' (On sites with listing application, it will display additional fields on inquiry form to qualify the lead.)</td>
		</tr>
		<tr>
		<th>Override Listing Stylesheet?:</th>
		<td>');
		form.content_config_override_stylesheet=application.zcore.functions.zso(form, 'content_config_override_stylesheet',true);
		ts = StructNew();
		ts.name = "content_config_override_stylesheet";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' Note: Checking yes will disable the built-in listing stylesheet.</td>
		</tr>
		<tr>
		<th>Viewable By Default Group:</th>
		<td>');
		form.content_config_viewable_by_default_group=application.zcore.functions.zso(form, 'content_config_viewable_by_default_group',true);
		db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group WHERE 
		user_group_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		if(not application.zcore.app.siteHasApp("listing")){ 
			db.sql&=" and user_group_name NOT IN (#db.param('broker')#, #db.param('agent')#)";
		}
		db.sql&=" ORDER BY user_group_name ASC";
		qUserGroups=db.execute("qUserGroups");
		selectStruct = StructNew();
		selectStruct.name = "content_config_viewable_by_default_group";
		selectStruct.query = qUserGroups; 
		selectStruct.queryLabelField = "user_group_friendly_name";
		selectStruct.queryValueField = "user_group_id";
		application.zcore.functions.zInputSelectBox(selectStruct); 
		echo(' Note: selecting a user group here will force new pages to have "Viewable by" set to this group.</td>
		</tr>
		
		<tr>
		<th>Detail CFC Path:</th>
		<td>');
		form.content_config_detail_cfc_path=application.zcore.functions.zso(form, 'content_config_detail_cfc_path');
		ts = StructNew();
		ts.name = "content_config_detail_cfc_path"; 
		application.zcore.functions.zInput_Text(ts);
		echo(' (i.e. root.mvc.controller.member)</td>
		</tr>
		<tr>
		<th>Detail CFC Method:</th>
		<td>');
		form.content_config_detail_cfc_method=application.zcore.functions.zso(form, 'content_config_detail_cfc_method');
		ts = StructNew();
		ts.name = "content_config_detail_cfc_method"; 
		application.zcore.functions.zInput_Text(ts);
		echo(' (i.e. view - function should have userStruct and listingStruct arguments with struct data type)</td>
		</tr>
		<tr> 
		<th>Hide Inquiring About?:</th>
		<td> ');
		form.content_config_hide_inquiring_about=application.zcore.functions.zso(form,'content_config_hide_inquiring_about',true,0);
		ts = StructNew();
		ts.name = "content_config_hide_inquiring_about";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' (Affects all contact forms).</td>
		</tr>
		<tr>
		<th>Phone Number Required?:</th>
		<td>');
		form.content_config_phone_required=application.zcore.functions.zso(form, 'content_config_phone_required',true,1);
		ts = StructNew();
		ts.name = "content_config_phone_required";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' (Affects all contact forms).</td>
		</tr>
		<tr>
		<th>Comments Required?:</th>
		<td>');
		form.content_config_comments_required=application.zcore.functions.zso(form, 'content_config_comments_required',true,1);
		ts = StructNew();
		ts.name = "content_config_comments_required";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' (Affects all contact forms).</td>
		</tr>
		<tr>
		<th>E-Mail Required?:</th>
		<td>');
		form.content_config_phone_required=application.zcore.functions.zso(form,'content_config_email_required',true,1);
		if(form.content_config_email_required EQ ""){
			form.content_config_email_required=1;
		}
		ts = StructNew();
		ts.name = "content_config_email_required";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' (Affects all contact forms).</td>
		</tr>
		<tr>
		<th>Thumbnail Image Size:</th>
		<td>');
		form.content_config_thumbnail_width=application.zcore.functions.zso(form, 'content_config_thumbnail_width',true,250);
		form.content_config_thumbnail_height=application.zcore.functions.zso(form, 'content_config_thumbnail_height',true,200);
		form.content_config_thumbnail_crop=application.zcore.functions.zso(form, 'content_config_thumbnail_crop',true,0);
		echo(' <p>Width: <input type="text" name="content_config_thumbnail_width" value="#htmleditformat(form.content_config_thumbnail_width)#" /></p>
		<p>Height: <input type="text" name="content_config_thumbnail_height" value="#htmleditformat(form.content_config_thumbnail_height)#" /></p>
		<p>Crop: ');
		ts = StructNew();
		ts.name = "content_config_thumbnail_crop";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo('(Default is 250x250, uncropped).</p></td>
		</tr>
		</table>');
	}
	rs.output=theText;
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>




<cffunction name="forceInitialContentSetup" localmode="modern" output="no" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;
	curInstance=application.zcore.app.getInstance(this.app_id);
	curInstance.initialcontentsetup=true;
	arrDefaultTitle=listtoarray('Home,Contact Us,Thank You For Your Inquiry,Join Our Mailing List,Thank You For Joining Our Mailing List,User Home Page',',');
	arrDefaultURL=listtoarray('/,/z/misc/inquiry/index,/z/misc/thank-you/index,/z/misc/mailing-list/index,/z/misc/mailing-list/thankyou,/z/user/home/index',',');
	
	if(application.zcore.app.siteHasApp("rental")){
		var rentalStruct=application.zcore.app.getAppData("rental");
		var rentalInstance=application.zcore.app.getAppCFC("rental");
		rentalInstance.onRequestStart();
		arrayappend(arrDefaultTitle,'Our Rentals');
		arrayappend(arrDefaultURL, rentalInstance.getRentalHomeLink());
		arrayappend(arrDefaultTitle,'Rental Reservation Policies');
		arrayappend(arrDefaultURL,'/Rental-Reservation-Policies-'&rentalStruct.optionStruct.rental_config_misc_url_id&'-1.html');
		arrayappend(arrDefaultTitle,'Compare Rental Amenities');
		arrayappend(arrDefaultURL,'/Compare-Rental-Amenities-'&rentalStruct.optionStruct.rental_config_misc_url_id&'-2.html');
	}
	if(application.zcore.app.siteHasApp("listing")){
		arrayappend(arrDefaultTitle,'Meet Our Agents');
		arrayappend(arrDefaultURL,'/z/misc/members/index');
		arrayappend(arrDefaultTitle,'Mortgage Calculator');
		arrayappend(arrDefaultURL,'/z/misc/mortgage-calculator/index');
		arrayappend(arrDefaultTitle,'Find Your Property''s Value');
		arrayappend(arrDefaultURL,'/z/listing/cma-inquiry/index');
		arrayappend(arrDefaultTitle,'Property Inquiry');
		arrayappend(arrDefaultURL,'/z/listing/inquiry/index'); 
	}
	for(i=1;i LTE arraylen(arrDefaultTitle);i++){
		if(arrDefaultURL[i] EQ "/z/misc/thank-you/index" or arrDefaultURL[i] EQ "/z/misc/search-site/results" or arrDefaultURL[i] EQ "/z/misc/search-site/no-results"){
			siteMap=0;	
			hideLink=1;
		}else{
			siteMap=1;
			hideLink=0;
		}
		db.sql="SELECT content_id FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		content_unique_name = #db.param(arrDefaultURL[i])# and 
		content_deleted=#db.param(0)#";
		qIdCheck=db.execute("qIDCheck");
		if(qIdCheck.recordcount EQ 0){
			db.sql="INSERT INTO #db.table("content", request.zos.zcoreDatasource)#  
			SET `content_text` = #db.param('')#,
			`content_summary` = #db.param('')#,
			`content_metakey` = #db.param('')#,
			`content_metadesc` = #db.param('')#,
			`content_name` = #db.param(arrDefaultTitle[i])#,
			`content_name2` = #db.param('')#,
			`content_unique_name` = #db.param(arrDefaultURL[i])#,
			`content_parent_id` = #db.param(0)#,
			`content_locked` = #db.param(0)#,
			`content_mls_price` = #db.param(1)#,
			`content_created_datetime` = #db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(),'HH:mm:ss'))#,
			`content_updated_datetime` =#db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(),'HH:mm:ss'))#,
			`content_sort` = #db.param(i)#,
			`content_datetime` = #db.param('')#,
			`content_hide_link` = #db.param(hideLink)#,
			`content_show_site_map` = #db.param(siteMap)#,
			`content_hide_modal` = #db.param(0)#,
			`content_for_sale` = #db.param(1)#,
			`content_mls_override` = #db.param(1)#,
			`content_search_mls` = #db.param(0)#,
			`content_search` = "&db.param(arrDefaultTitle[i])&",
			`content_child_sorting` = #db.param(0)#,
			`content_mix_sold` = #db.param(0)#,
			`content_user_group_id` = #db.param('')#, 
			`content_text_position` = #db.param(0)#,
			`content_parentpage_link_layout` = #db.param(7)#, 
			content_deleted=#db.param(0)#, 
			site_id="&db.param(request.zos.globals.id)&" ";
			db.execute("qInsert");
		}
	}
	updateContentAccessCache(application.siteStruct[request.zos.globals.id]);
	</cfscript>
</cffunction>

<cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
	<cfscript>
	var db=request.zos.queryObject;
	var tmpUsrId='';
	var qc='';
	var ts='';
	var db=request.zos.queryObject;
	if(request.zos.allowRequestCFC){
		request.zos.tempObj.contentInstance=structnew();
		structappend(request.zos.tempObj.contentInstance, application.sitestruct[request.zos.globals.id].app.appCache[this.app_id]);
		request.zos.tempObj.contentInstance.configCom=this;
	}
	if(isDefined('cookie.inquiries_email') and isDefined('cookie.inquiries_first_name') and isDefined('cookie.inquiries_phone1')){
		if(cookie.inquiries_email NEQ ""){
			request.zsession.inquiries_email = cookie.inquiries_email;
		}
		if(cookie.inquiries_first_name NEQ ""){
			request.zsession.inquiries_first_name=cookie.inquiries_first_name;
		}
		if(cookie.inquiries_phone1 NEQ ""){
		request.zsession.inquiries_phone1=cookie.inquiries_phone1;	
		}
	}
	
	if(structkeyexists(form, 'zlogout') EQ false){
		if(isDefined('request.zsession.user.id') and isDefined('request.zsession.user.site_id')){
			if(structkeyexists(request.zsession, 'zUserInquiryInfoLoaded') EQ false){
				tmpUsrId=request.zsession.user.id;
				db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE user_id = #db.param(request.zsession.user.id)# and 
				user_active=#db.param(1)# and 
				user_deleted=#db.param(0)# and 
				site_id = #db.param(request.zsession.user.site_id)#";
				qc=db.execute("qc");
				ts=structnew();
				ts.name="z_user_id";
				ts.value=tmpUsrId;
				ts.expires="never";
				application.zcore.functions.zCookie(ts);
				ts=structnew();
				ts.name="z_user_key";
				ts.value=qc.user_key;
				ts.expires="never";
				application.zcore.functions.zCookie(ts);
				ts=structnew();
				ts.name="z_user_siteIDType";
				ts.value=application.zcore.user.getSiteIdTypeFromLoggedOnUser();
				ts.expires="never";
				application.zcore.functions.zCookie(ts);
				request.zsession.zUserInquiryInfoLoaded=true;
			}
		}else if(application.zcore.functions.zso(cookie, 'inquiries_email') EQ "" and application.zcore.functions.zso(cookie, 'z_user_id') NEQ "" and application.zcore.functions.zso(cookie, 'z_user_key') NEQ ""){
			tmpUsrId=cookie.z_user_id;
			db.sql="SELECT user_username, user_first_name, user_last_name, user_phone 
			FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_id = #db.param(cookie.z_user_id)# and 
			user_key = #db.param(cookie.z_user_key)# and 
			user_active=#db.param(1)# and 
			user_deleted=#db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)#";
			qc=db.execute("qc");
		}
		if(isquery(qc) and qc.recordcount NEQ 0){
			request.zsession.inquiries_email=qc.user_username;
			request.zsession.inquiries_first_name=qc.user_first_name;
			request.zsession.inquiries_last_name=qc.user_last_name;
			request.zsession.inquiries_phone1=qc.user_phone;
			ts=structnew();
			ts.name="inquiries_email";
			ts.value="";
			ts.expires="now";
			application.zcore.functions.zCookie(ts);
			ts=structnew();
			ts.name="inquiries_first_name";
			ts.value="";
			ts.expires="now";
			application.zcore.functions.zCookie(ts);
			ts=structnew();
			ts.name="inquiries_last_name";
			ts.value="";
			ts.expires="now";
			application.zcore.functions.zCookie(ts);
			ts=structnew();
			ts.name="inquiries_phone1";
			ts.value="";
			ts.expires="now";
			application.zcore.functions.zCookie(ts);
			request.zsession.zUserInquiryInfoLoaded=true;
		}
	}
	
	if(structkeyexists(application.sitestruct[request.zos.globals.id].app.appCache[this.app_id],'initialcontentsetup') EQ false){
		this.forceInitialContentSetup();
	}
	</cfscript>
</cffunction>

<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
	<cfscript>
	
	</cfscript>
</cffunction>

<!--- 
ts=structnew();
ts.content_unique_name="";
qContent=application.zcore.app.getAppCFC("content").getContentByName(ts);
if(isQuery(qContent)){
	
}
 --->
<cffunction name="getContentByName" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	var db=request.zos.queryObject;
	var qC=0;
	var ts=structnew();
	ts.idOnly=true;
	ts.content_unique_name='';
	structappend(arguments.ss,ts,false);
	if(trim(arguments.ss.content_unique_name) EQ ''){
		return false;
	}
	db.sql="SELECT ";
	if(arguments.ss.idOnly){
		db.sql&=" content_id";
	}else{
		db.sql&="*";
	}
	db.sql&=" FROM #db.table("content", request.zos.zcoreDatasource)# content 
	WHERE content_deleted=#db.param(0)# and 
	content_for_sale <> #db.param(2)# and 
	content_unique_name = #db.param(arguments.ss.content_unique_name)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	qC=db.execute("qC");
	if(qC.recordcount NEQ 0){
		return qc;
	}else{
		return false;	
	}
	</cfscript>
</cffunction>

<!--- template variables are ##link## and ##linktext##

<a href="#link#">#linktext#</a>
<z_if var="photo" validate="notempty"><img src="#photo#"><z_else><img src="/images/shell/not-available.jpg"></z_if> #summary#

 --->
<cffunction name="getSidebar" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	var db=request.zos.queryObject;
	var p=0;
	var p2=0;
	var qpar=0;
	var arrL=arraynew(1);
	var image=0;
	var tmp="";
	var ts=structnew();
	var t9=structnew();
	var arrImages=0;
	var rs=structnew();
	var useSummary=true;
	var qc='';
	var summarylen='';
	var rs2=structnew();
	var parseStruct=structnew();
	rs.arrLink=arraynew(1);
	rs.arrText=arraynew(1);
	rs.arrID=arraynew(1);
	rs.arrStatus=arraynew(1);
	rs.arrLot=arraynew(1);
	ts.limit=0; // 0 is unlimited
	ts.delimiter="<br />";
	ts.beforeCode="";
	ts.afterCode="";
	ts.disableMoreLink=false;
	ts.cropTitleAt="";
	ts.forceLinkForCurrentPage=false;
	ts.sortAlpha=false;
	ts.returnData=false;
	ts.dateSortAsc=false;
	ts.dateSortDesc=false;
	ts.linkTextLength=0;
	ts.showHidden=false;
	ts.summaryTextLength=250;
	ts.insertAtPercent=0;
	ts.insertAtHTML='';
	ts.appendUrl="";
	ts.content_parent_id=0;
	ts.site_x_option_group_set_id=0;
	ts.content_unique_name="";
	ts.moretemplate="";
	ts.template="";
	structappend(arguments.ss,ts, false);
	if(arguments.ss.content_unique_name NEQ ""){
		t9.content_unique_name=arguments.ss.content_unique_name;
		qc=this.getContentByName(t9);
		if(isQuery(qc) and qc.recordcount NEQ 0){
			arguments.ss.content_parent_id=qc.content_id;
		}else{
			if(arguments.ss.returnData){
				return rs;
			}else{
				return "";
			}
		}
	}
	if(findnocase("##summary##",arguments.ss.template) EQ 0){
		useSummary=false;
	}
	
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="content.content_image_library_id";
	ts.count =  1; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="SELECT ";
	if(useSummary){
		db.sql&=" *";
	}else{
		db.sql&=" content_id, content_lot_number, content_for_sale, content_unique_name, content_name, 
		content_menu_title, content_url_only, content_image_library_id";
	}
	db.sql&=" #db.trustedsql(rs2.select)# 
	FROM #db.table("content", request.zos.zcoreDatasource)# content 
	#db.trustedsql(rs2.leftJoin)# 
	where content_parent_id = #db.param(arguments.ss.content_parent_id)# ";
	if(arguments.ss.showHidden EQ false){
		db.sql&=" and content_hide_link=#db.param(0)#";
	}
	db.sql&=" and 
	content_for_sale <>#db.param(2)# and 
	content_deleted = #db.param(0)# and 
	content.site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_group_set_id = #db.param(arguments.ss.site_x_option_group_set_id)# 
	GROUP BY content.content_id
	ORDER BY ";
	if(arguments.ss.sortAlpha){
		db.sql&=" trim(if(content_menu_title <>#db.param('')#,content_menu_title,content_name)) ";
	}else if(arguments.ss.dateSortAsc){
		db.sql&="  content_datetime ASC ";
	}else if(arguments.ss.dateSortDesc){
		db.sql&="  content_datetime DESC ";
	}else{
		db.sql&=" content_sort ";
		if(arguments.ss.limit NEQ 0){
			db.sql&=" LIMIT #db.param(0)#,#db.param(arguments.ss.limit)# ";
		}
	}
	qpar=db.execute("qpar", "", 10000, "query", false);
	loop query="qpar"{
		if(arguments.ss.disablemorelink OR qpar.currentrow NEQ arguments.ss.limit){
			parseStruct=structnew();
			parseStruct.content_id=qpar.content_id;
			if(qpar.content_url_only NEQ ''){
				parseStruct.link=application.zcore.functions.zForceAbsoluteURL(request.zos.currentHostName, qpar.content_url_only);
			}else if(qpar.content_unique_name NEQ ''){
				parseStruct.link=qpar.content_unique_name;
			}else{
				parseStruct.link="/#application.zcore.functions.zURLEncode(qpar.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#qpar.content_id#.html";
			}
			if(arguments.ss.appendUrl NEQ ""){
				application.zcore.functions.zURLAppend(parseStruct.link, arguments.ss.appendUrl);
			}
			
			ts=structnew();
			ts.image_library_id=qpar.content_image_library_id;
			ts.output=false;
			ts.query=qpar;
			ts.row=qpar.currentrow;
			ts.size="250x187";
			ts.count = 1;
			arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts);
			parseStruct.image=request.zos.currentHostName&"/z/a/images/s.gif";
			if(arraylen(arrImages) NEQ 0){
				parseStruct.image=request.zos.currentHostName&arrImages[1].link;
			}
			if(qpar.content_menu_title NEQ ""){
				parseStruct.linktext=qpar.content_menu_title;
			}else{
				parseStruct.linktext=qpar.content_name;
			}
			if(arguments.ss.cropTitleAt NEQ ""){
				p=findnocase(arguments.ss.cropTitleAt, parseStruct.linktext)-1;
				if(p GTE 1){
					parseStruct.linktext=left(parseStruct.linktext,p);
				}
			}
			if(arguments.ss.linkTextLength NEQ 0){
				p=reverse(left(parseStruct.linktext,arguments.ss.linkTextLength));
				if(len(parseStruct.linktext) GT arguments.ss.linkTextLength){
					p2=find(" ",p);
					if(p2 NEQ 0){
						p='... '&removechars(p,1,p2);
					}
				}
				parseStruct.linktext=reverse(p);
			}
			if(useSummary){
				parseStruct.summary=qpar.content_summary;
				if(qpar.content_summary EQ ""){
					parseStruct.summary=qpar.content_text;
				}
				parseStruct.summary=rereplace(parseStruct.summary,"<[^>]*>"," ","ALL");
				summarylen=len(parseStruct.summary);
				parseStruct.summary=left(parseStruct.summary,arguments.ss.summaryTextLength);
				if(summarylen GT arguments.ss.summaryTextLength){
					parseStruct.summary&="...";	
				}
			}
			ts=structnew();
			ts.image_library_id=qpar.content_image_library_id;
			ts.output=false;
			ts.query=qpar;
			ts.row=qpar.currentrow;
			ts.size="200x140";
			//ts.crop=1;
			ts.count = 1; // how many images to get
			//zdump(ts);
			arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts);
			parseStruct.photo=""; 
			if(arraylen(arrImages) NEQ 0){
				parseStruct.photo=(arrImages[1].link);
			}
			parseStruct.link=htmleditformat(parseStruct.link);
			parseStruct.linktext=htmleditformat(parseStruct.linktext);
			if(arguments.ss.template NEQ ""){
				tmp=application.zcore.functions.zParseVariables(arguments.ss.template, false, parseStruct);
			}else if(not arguments.ss.forceLinkForCurrentPage and (request.zos.originalURL EQ parseStruct.link or request.zos.originalURL EQ qpar.content_url_only)){
				tmp='<span>'&parseStruct.linkText&'</span>';
			}else{
				tmp='<a href="#parseStruct.link#">#parseStruct.linktext#</a>';
			}
			tmp=arguments.ss.beforeCode&tmp&arguments.ss.afterCode&arguments.ss.delimiter;
			if(arguments.ss.insertAtPercent NEQ 0){
				p=(qpar.currentrow/qpar.recordcount)*100;
				if(p GTE arguments.ss.insertAtPercent){
					arguments.ss.insertAtPercent=0;
					arrayappend(arrL,arguments.ss.insertAtHTML);
				}
			}
			arrayappend(arrL,tmp);
			if(arguments.ss.returnData){
				arrayappend(rs.arrId,qpar.content_id);
				arrayappend(rs.arrLink,parseStruct.link); 
				arrayappend(rs.arrLot, qpar.content_lot_number); 
				arrayappend(rs.arrStatus,qpar.content_for_sale);
				arrayappend(rs.arrText,parseStruct.linktext);
			}
		}
	}
	if(arguments.ss.disableMoreLink EQ false and qpar.recordcount EQ arguments.ss.limit){
		// you must have a group by in your query or it may miss rows
		ts=structnew();
		ts.image_library_id_field="content.content_image_library_id";
		ts.count =  100; // how many images to get
		rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
		db.sql="SELECT * #db.trustedsql(rs2.select)# 
		FROM #db.table("content", request.zos.zcoreDatasource)# content 
		#db.trustedsql(rs2.leftJoin)# where ";
		if(arguments.ss.content_parent_id EQ 0){
			db.sql&=" content_unique_name = #db.param('/')# ";
		}else{
			db.sql&="  content_id = #db.param(arguments.ss.content_parent_id)# ";
		}
		if(arguments.ss.showHidden EQ false){
			db.sql&=" and content_hide_link=#db.param(0)#";
		}
		db.sql&="  and content_for_sale=#db.param(1)# and 
		content_deleted = #db.param(0)# and 
		content.site_id = #db.param(request.zos.globals.id)# and 
		site_x_option_group_set_id = #db.param(arguments.ss.site_x_option_group_set_id)#
		GROUP BY content.content_id";
		qpar=db.execute("qpar");
		loop query="qpar"{
			parseStruct=structnew();
			parseStruct.content_id=qpar.content_id;
			parseStruct.summary="";
			parseStruct.photo="";
			if(qpar.content_url_only NEQ ''){
				parseStruct.link=application.zcore.functions.zForceAbsoluteURL(request.zos.currentHostName, qpar.content_url_only);
			}else if(qpar.content_unique_name NEQ ''){
				parseStruct.link=qpar.content_unique_name;
			}else{
				parseStruct.link="/#application.zcore.functions.zURLEncode(qpar.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#qpar.content_id#.html";
			}
			if(arguments.ss.appendUrl NEQ ""){
				parseStruct.link=application.zcore.functions.zURLAppend(parseStruct.link, arguments.ss.appendUrl);
			}
			ts=structnew();
			ts.image_library_id=qpar.content_image_library_id;
			ts.output=false;
			ts.query=qpar;
			ts.row=qpar.currentrow;
			ts.size="250x187";
			ts.count = 1;
			arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts);
			parseStruct.image=request.zos.currentHostName&"/z/a/images/s.gif";
			if(arraylen(arrImages) NEQ 0){
				parseStruct.image=request.zos.currentHostName&arrImages[1].link;
			}
			parseStruct.linktext="Click here for more";
			parseStruct.link=htmleditformat(parseStruct.link);
			parseStruct.linktext=htmleditformat(parseStruct.linktext);
			if(arguments.ss.moretemplate NEQ ""){
				tmp=application.zcore.functions.zParseVariables(arguments.ss.moretemplate, false, parseStruct);
			}else if(arguments.ss.template NEQ ""){
				tmp=application.zcore.functions.zParseVariables(arguments.ss.template, false, parseStruct);
			}else{
				tmp='<a href="#parseStruct.link#">#parseStruct.linktext#</a>';
			}
			tmp=arguments.ss.beforeCode&tmp&arguments.ss.afterCode;
			if(arguments.ss.insertAtPercent NEQ 0){
				p=(qpar.currentrow/qpar.recordcount)*100;
				if(p GTE arguments.ss.insertAtPercent){
					arguments.ss.insertAtPercent=0;
					arrayappend(arrL,arguments.ss.insertAtHTML);
				}
			}
			arrayappend(arrL,tmp);
			if(arguments.ss.returnData){
				arrayappend(rs.arrId,  qpar.content_id);
				arrayappend(rs.arrLink,parseStruct.link);
				arrayappend(rs.arrLot, qpar.content_lot_number);
				arrayappend(rs.arrStatus, qpar.content_for_sale);
				arrayappend(rs.arrText,parseStruct.linktext);
			}
		}
	}
	if(arguments.ss.returnData){
		return rs;
	}else{
		return arraytolist(arrL,"");
	}
	</cfscript>
</cffunction>


<!--- 
ts=structnew();
ts.content_id="";
configCom.includeContent(ts);
 --->
<cffunction name="includeContent" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfargument name="query" type="any" required="no" default="#false#">
	<cfscript>
	var r1=0;
	var qc=0;
	var ts=structnew();
	var ts19156=duplicate(application.zcore.contentDefaultConfigStruct);
	ts19156.contentWasIncluded=true;
	if(trim(arguments.ss.content_id) EQ ''){
		return false;
	}
	ts.hideTitle=false;
	ts.disableLinks=false;
	ts.simpleFormat=false;
	ts.forceH1=false;
	structappend(arguments.ss,ts,false);
	if(arguments.ss.simpleFormat){
		ts19156.contentSimpleFormat=true;	
		ts19156.disableChildContentSummary=true;
		ts19156.contentEmailFormat=true;
	}
	if(arguments.ss.hideTitle){
		ts19156.contentHideTitle=true;
	}
	if(arguments.ss.forceH1){
		ts19156.forceH1=true;
	}
	if(arguments.ss.disableLinks){
		ts19156.contentDisableLinks=true;
	}
	ts19156.contentForceOutput=true;
	application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts19156);
	r1=application.zcore.app.getAppCFC("content").getPropertyInclude(arguments.ss.content_id, arguments.query, []);
	return r1;
	</cfscript>
</cffunction>

<!--- 
ts=structnew();
ts.content_id="";
ts.disableContentMeta=false;
configCom.includePageContent(ts);
 --->
<cffunction name="includePageContent" localmode="modern" output="yes" returntype="boolean">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	var r1=0;
	var ts19156=duplicate(application.zcore.contentDefaultConfigStruct);
	ts19156.contentWasIncluded=true;
	structappend(arguments.ss, ts19156, false);
	application.zcore.app.getAppCFC("content").setContentIncludeConfig(arguments.ss);
	r1=this.includeFullContent();
	
	if(r1){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<cffunction name="viewPage" localmode="modern" access="remote" output="yes" returntype="boolean">
	<cfscript>
	var r1=0;
	var output="";
	var ts19156=duplicate(application.zcore.contentDefaultConfigStruct);
	ts19156.content_id=application.zcore.functions.zso(form,'content_id');
	ts19156.content_unique_name=application.zcore.functions.zso(form,'content_unique_name');
	application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts19156);
	r1=this.includeFullContent();
	if(r1){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
	
<!--- 
ts=structnew();
ts.content_unique_name="";
ts.disableContentMeta=false;
configCom.includePageContentByName(ts);
 --->
<cffunction name="includePageContentByName" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	var r1=0;
	var qc=0;
	var db=request.zos.queryObject;
	var ts19156=duplicate(application.zcore.contentDefaultConfigStruct);
	ts19156.contentWasIncluded=true;
	if(trim(arguments.ss.content_unique_name) EQ ''){
		return false;
	}
	db.sql="SELECT content_id FROM #db.table("content", request.zos.zcoreDatasource)# content 
	WHERE content_deleted=#db.param(0)# and 
	content_for_sale <> #db.param(2)# and 
	content_unique_name = #db.param(arguments.ss.content_unique_name)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	qC=db.execute("qC"); 
	if(qC.recordcount NEQ 0){
		structappend(arguments.ss, ts19156, false);
		arguments.ss.content_id=qc.content_id;
		application.zcore.app.getAppCFC("content").setContentIncludeConfig(arguments.ss);
		r1=this.includeFullContent();
		if(r1){
			return true;
		}else{
			return false;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<!--- 
ts=structnew();
ts.content_unique_name="";
ts.disableContentMeta=false;
configCom.includeContentByName(ts);
 --->
<cffunction name="includeContentByName" localmode="modern" output="yes" returntype="boolean">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	var r1=0;
	var qc=0;
	var db=request.zos.queryObject;
	if(trim(arguments.ss.content_unique_name) EQ ''){
		return false;
	}
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="content.content_image_library_id";
	ts.count =  100; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="SELECT *  #db.trustedsql(rs.select)# FROM #db.table("content", request.zos.zcoreDatasource)# content 
	#db.trustedsql(rs.leftJoin)#
	WHERE content_deleted=#db.param(0)# and 
	content_for_sale <> #db.param(2)# and 
	content_unique_name = #db.param(arguments.ss.content_unique_name)# and 
	content.site_id=#db.param(request.zos.globals.id)# 
	GROUP BY content.content_id";
	qc=db.execute("qC");
	if(qC.recordcount NEQ 0){
		arguments.ss.content_id=qc.content_id;
		r1=this.includeContent(arguments.ss, qc);
		if(r1){
			return true;
		}else{
			return false;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<!--- getUserGroupIdForContentId(content_id, site_id); --->
<cffunction name="getUserGroupIdForContentId" localmode="modern" returntype="numeric" hint="This is used to find the user group required to view the content id provided.">
	<cfargument name="content_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	if(not structkeyexists(request.zos, 'contentParentIdGroupIdLookup')){
		request.zos.contentParentIdGroupIdLookup={};
	}
	count=0;
	parentId=arguments.content_id;
	while(true){
		if(structkeyexists(request.zos.contentParentIdGroupIdLookup, parentId)){
			if(request.zos.contentParentIdGroupIdLookup[parentId].groupId NEQ 0){
				return request.zos.contentParentIdGroupIdLookup[parentId].groupId;
			}
			parentId=request.zos.contentParentIdGroupIdLookup[parentId].parentId;
		}else{
			db.sql="SELECT content_id, content_parent_id, content_user_group_id 
			FROM #db.table("content", request.zos.zcoreDatasource)# 
			WHERE  
			content.site_id = #db.param(arguments.site_id)# and 
			content_id = #db.param(parentId)# and 
			content_deleted=#db.param(0)#";
			qC=db.execute("qC", "", 10000, "query", false);  
			if(qC.content_user_group_id NEQ 0){
				return qC.content_user_group_id;
			}
			request.zos.contentParentIdGroupIdLookup[qC.content_id]={
				groupId:qC.content_user_group_id,
				parentId:qC.content_parent_id
			};
			parentId=qC.content_parent_id;
		}
		if(parentId EQ 0){
			return 0;
		}
		count++;
		if(count GT 255){
			throw("Infinite loop detected when searching for the topmost content_parent_id for content_id=#arguments.content_id#.");
		}
	}
	return 0;
	</cfscript>
</cffunction>
	
<!--- application.zcore.app.getAppCFC("content").searchReindexContent(false, true); --->
<cffunction name="searchReindexContent" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexEverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
 

	while(true){
		db.sql="SELECT content.*, content_config_url_article_id FROM #db.table("content", request.zos.zcoreDatasource)# content,
		#db.table("content_config", request.zos.zcoreDatasource)# content_config
		WHERE 
		content_config.site_id = content.site_id ";
		if(arguments.indexEverything EQ false){
			db.sql&=" and content.site_id = #db.param(request.zos.globals.id)# ";
		}else{
			db.sql&=" and content.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and content_id = #db.param(arguments.id)# ";
		}
		db.sql&=" and content_for_sale <> #db.param(2)# and 
		content_hide_link =#db.param(0)# and 
		content_deleted=#db.param(0)# and 
		content_config_deleted =#db.param(0)#	
		LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteContent(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.content_name&" "&row.content_summary&" "&row.content_text&" "&row.content_text2&" "&row.content_text3;
				ds.search_title=row.content_name;
				ds.search_summary=row.content_summary;
				if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.content_text;
				}
				
				if(row.content_url_only NEQ ''){
					ds.search_url=application.zcore.functions.zForceAbsoluteURL(request.zos.currentHostName, row.content_url_only);
				}else if(row.content_unique_name NEQ ''){
					ds.search_url=row.content_unique_name;
				}else{
					ds.search_url="/#application.zcore.functions.zURLEncode(row.content_name,'-')#-#row.content_config_url_article_id#-#row.content_id#.html";
				} 
				if(row.content_user_group_id NEQ 0){
					ds.user_group_id=row.content_user_group_id;
				}else{
					ds.user_group_id=getUserGroupIdForContentId(row.content_id, row.site_id);
				}
				ds.search_table_id=row.content_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=dateformat(row.content_updated_datetime, "yyyy-mm-dd")&" "&timeformat(row.content_updated_datetime, "HH:mm:ss");
				ds.site_id=row.site_id;  
				searchCom.saveSearchIndex(ds); 
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and 
		search_deleted = #db.param(0)# and
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>
	
	
<!--- application.zcore.app.getAppCFC("content").searchIndexDeleteContent(content_id); --->
<cffunction name="searchIndexDeleteContent" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)#  and
	search_table_id = #db.param(arguments.id)# and 
	search_deleted = #db.param(0)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>
	
	
	
<cffunction name="setRequestThumbnailSize" localmode="modern" output="no" returntype="struct">
	<cfargument name="width" type="numeric" required="yes">
	<cfargument name="height" type="numeric" required="yes">
	<cfargument name="crop" type="numeric" required="yes">
	<cfscript>
	thumbnailStruct={};
	thumbnailStruct.width=arguments.width;
	thumbnailStruct.height=arguments.height;
	thumbnailStruct.crop=arguments.crop;
	if(thumbnailStruct.width EQ 0){
		thumbnailStruct.width=application.zcore.functions.zso(application.zcore.app.getAppData("content").optionstruct, 'content_config_thumbnail_width', true, 0);
		thumbnailStruct.height=application.zcore.functions.zso(application.zcore.app.getAppData("content").optionstruct, 'content_config_thumbnail_height', true, 0);
		thumbnailStruct.crop=application.zcore.functions.zso(application.zcore.app.getAppData("content").optionstruct, 'content_config_thumbnail_crop', true, 0);
	}
	if(thumbnailStruct.width EQ 0){
		thumbnailStruct.width=400;
		thumbnailStruct.height=300;
		thumbnailStruct.crop=1;
	}
	request.zos.thumbnailSizeStruct=thumbnailStruct;
	return thumbnailStruct;
	</cfscript>
</cffunction>
	
	
<cffunction name="getPropertyIncludeHTML" localmode="modern">
	<cfargument name="contentConfig" type="struct" required="yes">
	<cfargument name="contentPhoto99" type="string" required="yes">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="cityName" type="string" required="yes">
	<cfargument name="propertyLink" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	contentConfig=arguments.contentConfig;
	contentPhoto99=arguments.contentPhoto99;
	row=arguments.row;
	cityName=arguments.cityName;
	propertyLink=arguments.propertyLink;
	echo('<div ');
	if(len(contentConfig.tablestyle)){
		echo(contentConfig.tablestyle);
	}else{
	
		echo(' class="zcontent-subpage-div" ');
	}
	echo('>');
	if(contentPhoto99 NEQ ""){
		echo('<div class="zcontent-imagethumbwidth" style="width:#request.zos.thumbnailSizeStruct.width#px;">');
		if(contentConfig.contentDisableLinks EQ false){
			echo('<a href="#propertyLink#">');
		}
		echo('<img src="#request.zos.currentHostName&contentPhoto99#" alt="#htmleditformat(row.content_name)#" ');
		if(contentConfig.contentEmailFormat or application.zcore.functions.zso(request, 'contentUseSmallThumbnails',false,false) NEQ false){
			echo('width="120"');
		}
		echo(' style="border:none; max-width:100%;" />');
		if(contentConfig.contentDisableLinks EQ false){
			echo('</a>');
		}
		echo('</div>');
	}
	
	echo('<div class="z-content-text-div" style="">');
	if(application.zcore.functions.zso(form, 'content_id') NEQ row.content_id or contentConfig.contentForceOutput){
		if(application.zcore.functions.zso(form, 'contentHideTitle',false,false) EQ false){
			if(application.zcore.functions.zso(contentConfig, "forceH1", false, false)){
				echo('<h1>');
			}else{
				echo('<h2>');
			}
			if(contentConfig.contentDisableLinks EQ false){
				echo('<a href="#propertyLink#">');
			}
			echo(htmleditformat(row.content_name));
			if(contentConfig.contentDisableLinks EQ false){
				echo('</a>');
			}
			if(application.zcore.functions.zso(contentConfig, "forceH1", false, false)){
				echo('</h1>');
			}else{
				echo('</h2>');
			}
		}
	}
	if(contentConfig.disableChildContentSummary EQ false){
		if(row.content_is_listing EQ 1){
			echo('<div style="width:100%; float:left;">
			<div>');
			if(row.content_property_bedrooms NEQ 0){
				echo('#row.content_property_bedrooms# Bedroom');
			}
			if(row.content_property_type_id NEQ 0 and row.content_property_type_id NEQ ""){
				db.sql="SELECT * FROM #db.table("content_property_type", request.zos.zcoreDatasource)# content_property_type 
				WHERE content_property_type_id = #db.param(row.content_property_type_id)# and 
				content_property_type_deleted = #db.param(0)#";
				qCp3i2=db.execute("qCp3i2");
				if(qCp3i2.recordcount NEQ 0){
					echo('<br />#qCp3i2.content_property_type_name#');
				}
			}
			echo('</div><div style="white-space:nowrap;">');
			if(row.content_property_bathrooms NEQ 0 or row.content_property_half_baths NEQ 0){
				echo('#row.content_property_bathrooms# Bath ');
				if(row.content_property_half_baths NEQ 0){
					echo('<br />#row.content_property_half_baths# half&nbsp;baths');
				}
			}
			echo('</div><div style="white-space:nowrap;">');
			if(row.content_property_sqfoot NEQ "" and row.content_property_sqfoot NEQ 0){
				echo('#row.content_property_sqfoot# SQFT<br />');
			}
			arr1=arraynew(1);
			if(row.content_address NEQ ""){ 
				arrayappend(arr1,row.content_address);
			}
			if(cityName NEQ ""){ 
				arrayappend(arr1,cityName);
			}
			if(row.content_property_state NEQ ""){ 
				arrayappend(arr1,row.content_property_state);
			}
			if(arraylen(arr1) NEQ 0){
				writeoutput(arraytolist(arr1, ", "));
			}
			if(row.content_property_zip NEQ ""){ 
				writeoutput(" "&row.content_property_zip);
			}
			if(row.content_property_country NEQ "" and row.content_property_country NEQ "US"){ 
				writeoutput(" "&row.content_property_country);
			}
			echo('</div></div>');

			if(row.content_price NEQ 0 and row.content_for_sale EQ 1){
				echo('<span style="font-size:14px; font-weight:bold;">Priced at #dollarformat(row.content_price)#</span>');
			}
			if(row.content_for_sale EQ '3'){
				echo('<span style="color:##FF0000; font-size:14px; font-weight:bold;">This listing is SOLD</span><br /><br />');
			}else if(row.content_for_sale EQ '4'){
				echo('<span style="color:##FF0000; font-size:14px; font-weight:bold;">This listing is UNDER CONTRACT</span><br /><br />');
			}
			if(row.content_datetime NEQ ''){
				echo('<strong class="news-date">');
				if(isdate(row.content_datetime)){
					echo(DateFormat(row.content_datetime,'m/d/yyyy'));
				}
				if(row.content_datetime NEQ '' and Timeformat(row.content_datetime,'HH:mm:ss') NEQ '00:00:00'){
					echo(" at "&TimeFormat(row.content_datetime,'h:mm tt'));
				}
			}
			echo('</strong> <br />'); 
		}
		shortSummary="";
		if(row.content_id NEQ application.zcore.functions.zso(form, 'content_id')){
			if(row.content_summary EQ ""){
				if(request.cgi_script_name EQ "/z/misc/search-site/results"){ 
					shortSummary=left(rereplace(row.content_text,"<[^>]*>"," ","ALL"),250);  
				}
			}else{
				shortSummary=row.content_summary;
			}
		}
		writeoutput(shortSummary); 
		if(row.content_is_listing EQ 1){
			echo('<div style="font-weight:bold; font-size:13px;">');
			detailShown=false;
			if(contentConfig.contentDisableLinks EQ false and row.content_id NEQ application.zcore.functions.zso(form, 'content_id')){
				echo('<a href="#propertyLink#" class="zcontent-readmore-link">Read More</a>');
				detailShown=true;
			}
			if(contentConfig.contentEmailFormat EQ false){
				if(detailShown){
					echo(' | ');
				}
				if(contentConfig.contentDisableLinks EQ false){
					echo('<a href="#application.zcore.functions.zblockurl('/z/misc/inquiry/index?content_id=#row.content_id#')#" style="font-size:14px; font-weight:bold;">Inquire about this property</a>');
				}
			}
			if( row.content_virtual_tour NEQ ''){
				echo(' | <a href="#application.zcore.functions.zblockurl(row.content_virtual_tour)#" rel="nofollow" onclick="window.open(this.href); return false;">View 360&deg; Virtual Tour</a>');
			}
			echo('</div>');
		}else if(contentConfig.contentDisableLinks EQ false){
			echo('<p class="zcontent-readmore-link"><strong><a href="#propertyLink#">Read More</a></strong></p>');
		}
	}
	echo('</div></div>');
	if(row.content_id NEQ application.zcore.functions.zso(form, 'content_id')){
		echo('<hr />');
	}
	</cfscript>
</cffunction>
 
<cffunction name="getContentInclude2ColumnHorizontal" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	enableLinks=arguments.ss.enableLinks;
	arrData=arguments.ss.arrData;
	</cfscript>
	<cfif arguments.ss.hasImages> 
		<section class="section-1 z-pv-40">
			<div class="z-row">
				<div class="z-pv-20 z-equal-heights"> 
					<cfloop from="1" to="#arraylen(arrData)#" index="i"> 
						<cfscript>
						d=arrData[i];
						</cfscript>
						<div class="z-hide-at-992 z-1of2">
							<div class=" z-row z-table">
								<div class="z-1of2  z-left-sidebar z-m-0 z-p-0">
									<cfif d.image NEQ ""> 
										<cfif enableLinks>
											<a href="#d.link#"><img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" /></a>
										<cfelse>
											<img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" />
										</cfif>
									<cfelse>
										&nbsp;
									</cfif>
								</div>
								<div class="z-column   z-ml-0 ">
									<div class=" z-fp-20">
										<div class="z-h-24">
											<cfif enableLinks>
												<a href="#d.link#">#d.heading#</a>
											<cfelse>
												#d.heading#
											</cfif>
										</div>
										<div class="z-t-16">#d.summary#</div>
										<cfif enableLinks>
											<a href="#d.link#" class="z-content-subpage-button z-float-left z-pt-40 z-fpb-20">Read More</a>
										</cfif>
									</div>
								</div>
							</div>
						</div>
					</cfloop> 
				</div>
				<div class="z-show-at-992 z-pv-10 z-equal-heights" data-children-class=".childEqualHeights">
					
					<cfloop from="1" to="#arraylen(arrData)#" index="i"> 
						<cfscript>
						d=arrData[i];
						</cfscript>
						<div class="z-column z-p-0 z-mb-20" style="display:table;">
							<div class="z-1of3 z-m-0 z-p-0 z-fluid-at-767">
								<cfif d.image NEQ ""> 
									<cfif enableLinks>
										<a href="#d.link#"><img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" /></a>
									<cfelse>
										<img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" />
									</cfif>
								<cfelse>
									&nbsp;
								</cfif>
	
							</div>
							<div class="z-2of3 z-m-0 "  >
								<div class="z-float-left z-fp-20">
									<div class="z-h-24">
										<cfif enableLinks>
											<a href="#d.link#">#d.heading#</a>
										<cfelse>
											#d.heading#
										</cfif>
									</div>
									<div class="z-t-16">#d.summary#</div>
									<cfif enableLinks>
										<a href="#d.link#" class="z-content-subpage-button z-float-left z-pt-40 z-fpb-20">Read More</a>
									</cfif>
								</div>
							</div>
						</div>
					</cfloop>
				</div>
			</div> 
		</section>
	<cfelse>

		<section class="section-1 z-pv-40">
			<div class="z-container">
				<div class="z-pv-20 z-equal-heights"> 
					<cfloop from="1" to="#arraylen(arrData)#" index="i"> 
						<cfscript>
						d=arrData[i];
						</cfscript>
						<div class="z-1of2">
							<div class=" z-container z-bg-white"> 
								<div class="z-column">
									<div class=" z-fp-20">
										<div class="z-h-24">
											<cfif enableLinks>
												<a href="#d.link#">#d.heading#</a>
											<cfelse>
												#d.heading#
											</cfif>
										</div>
										<div class="z-t-16">#d.summary#</div>
										<cfif enableLinks>
											<a href="#d.link#" class="z-float-left z-pt-40 z-fpb-20">Read More</a>
										</cfif>
									</div>
								</div>
							</div>
						</div>
					</cfloop> 
				</div>
			</div> 
		</section>
	</cfif>

</cffunction>


<cffunction name="getContentInclude3ColumnHorizontal" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	enableLinks=arguments.ss.enableLinks;
	arrData=arguments.ss.arrData;
	</cfscript>
	<cfif arguments.ss.hasImages> 
		<section class="section-1 z-pv-40">
			<div class="z-row">
				<div class="z-pv-20 z-equal-heights"> 
					<cfloop from="1" to="#arraylen(arrData)#" index="i"> 
						<cfscript>
						d=arrData[i];
						</cfscript>
						<div class="z-hide-at-992 z-1of3">
							<div class=" z-row z-table">
								<div class="z-1of3  z-left-sidebar z-m-0 z-p-0">
									<cfif d.image NEQ ""> 
										<cfif enableLinks>
											<a href="#d.link#"><img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" /></a>
										<cfelse>
											<img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" />
										</cfif>
									<cfelse>
										&nbsp;
									</cfif>
								</div>
								<div class="z-column   z-ml-0 ">
									<div class=" z-fp-20">
										<div class="z-h-24">
											<cfif enableLinks>
												<a href="#d.link#">#d.heading#</a>
											<cfelse>
												#d.heading#
											</cfif>
										</div>
										<div class="z-t-16">#d.summary#</div>
										<cfif enableLinks>
											<a href="#d.link#" class="z-content-subpage-button z-float-left z-pt-40 z-fpb-20">Read More</a>
										</cfif>
									</div>
								</div>
							</div>
						</div>
					</cfloop> 
				</div>
				<div class="z-show-at-992 z-pv-10 z-equal-heights" data-children-class=".childEqualHeights">
					
					<cfloop from="1" to="#arraylen(arrData)#" index="i"> 
						<cfscript>
						d=arrData[i];
						</cfscript>
						<div class="z-column z-p-0 z-mb-20" style="display:table;">
							<div class="z-1of3 z-m-0 z-p-0 z-fluid-at-767">
								<cfif d.image NEQ ""> 
									<cfif enableLinks>
										<a href="#d.link#"><img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" /></a>
									<cfelse>
										<img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" />
									</cfif>
								<cfelse>
									&nbsp;
								</cfif>
	
							</div>
							<div class="z-2of3 z-m-0 "  >
								<div class="z-float-left z-fp-20">
									<div class="z-h-24">
										<cfif enableLinks>
											<a href="#d.link#">#d.heading#</a>
										<cfelse>
											#d.heading#
										</cfif>
									</div>
									<div class="z-t-16">#d.summary#</div>
									<cfif enableLinks>
										<a href="#d.link#" class="z-content-subpage-button z-float-left z-pt-40 z-fpb-20">Read More</a>
									</cfif>
								</div>
							</div>
						</div>
					</cfloop>
				</div>
			</div> 
		</section>
	<cfelse>

		<section class="section-1 z-pv-40">
			<div class="z-container">
				<div class="z-pv-20 z-equal-heights"> 
					<cfloop from="1" to="#arraylen(arrData)#" index="i"> 
						<cfscript>
						d=arrData[i];
						</cfscript>
						<div class="z-1of3">
							<div class=" z-container z-bg-white"> 
								<div class="z-column">
									<div class=" z-fp-20">
										<div class="z-h-24">
											<cfif enableLinks>
												<a href="#d.link#">#d.heading#</a>
											<cfelse>
												#d.heading#
											</cfif>
										</div>
										<div class="z-t-16">#d.summary#</div>
										<cfif enableLinks>
											<a href="#d.link#" class="z-float-left z-pt-40 z-fpb-20">Read More</a>
										</cfif>
									</div>
								</div>
							</div>
						</div>
					</cfloop> 
				</div>
			</div> 
		</section>
	</cfif>

</cffunction>
 
<cffunction name="getContentInclude2ColumnVertical" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	enableLinks=arguments.ss.enableLinks;
	arrData=arguments.ss.arrData;
	</cfscript> 
	<section class="section-1 z-pv-40">
		<div class="z-row">
			<div class="z-pv-20 z-equal-heights"> 
				<cfloop from="1" to="#arraylen(arrData)#" index="i"> 
					<cfscript>
					d=arrData[i];
					</cfscript>
					<div class="z-1of2">
						<div class=" z-float"> 
							<cfif arguments.ss.hasImages and d.image NEQ ""> 
								<cfif enableLinks>
									<a href="#d.link#"><img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" /></a>
								<cfelse>
									<img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" />
								</cfif> 
							</cfif>

						</div>
						<div class=" z-float"> 
							<div class=" z-pt-20">
								<div class="z-h-24">
									<cfif enableLinks>
										<a href="#d.link#">#d.heading#</a>
									<cfelse>
										#d.heading#
									</cfif>
								</div>
								<div class="z-t-16">#d.summary#</div>
								<cfif enableLinks>
									<a href="#d.link#" class="z-content-subpage-button z-float-left z-pt-40 z-fpb-20">Read More</a>
								</cfif>
							</div>
						</div>
					</div>
				</cfloop> 
			</div> 
		</div> 
	</section> 

</cffunction>

 
<cffunction name="getContentInclude3ColumnVertical" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	enableLinks=arguments.ss.enableLinks;
	arrData=arguments.ss.arrData;
	</cfscript> 
	<section class="section-1 z-pv-40">
		<div class="z-row">
			<div class="z-pv-20 z-equal-heights"> 
				<cfloop from="1" to="#arraylen(arrData)#" index="i"> 
					<cfscript>
					d=arrData[i];
					</cfscript>
					<div class="z-1of3">
						<div class=" z-float"> 
							<cfif arguments.ss.hasImages and d.image NEQ ""> 
								<cfif enableLinks>
									<a href="#d.link#"><img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" /></a>
								<cfelse>
									<img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" />
								</cfif> 
							</cfif>

						</div>
						<div class=" z-float"> 
							<div class=" z-pt-20 ">
								<div class="z-h-24">
									<cfif enableLinks>
										<a href="#d.link#">#d.heading#</a>
									<cfelse>
										#d.heading#
									</cfif>
								</div>
								<div class="z-t-16">#d.summary#</div>
								<cfif enableLinks>
									<a href="#d.link#" class="z-content-subpage-button z-float-left z-pt-40 z-fpb-20">Read More</a>
								</cfif>
							</div>
						</div>
					</div>
				</cfloop> 
			</div> 
		</div> 
	</section> 

</cffunction>

 
<cffunction name="getContentInclude4ColumnVertical" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	enableLinks=arguments.ss.enableLinks;
	arrData=arguments.ss.arrData;
	</cfscript> 
	<section class="section-1 z-pv-40">
		<div class="z-row">
			<div class="z-pv-20 z-equal-heights"> 
				<cfloop from="1" to="#arraylen(arrData)#" index="i"> 
					<cfscript>
					d=arrData[i];
					</cfscript>
					<div class="z-1of4">
						<div class=" z-float"> 
							<cfif arguments.ss.hasImages and d.image NEQ ""> 
								<cfif enableLinks>
									<a href="#d.link#"><img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" /></a>
								<cfelse>
									<img src="#d.image#" alt="#htmleditformat(d.heading)#" class="z-fluid z-float-left" />
								</cfif> 
							</cfif>

						</div>
						<div class=" z-float"> 
							<div class=" z-pt-20 ">
								<div class="z-h-24">
									<cfif enableLinks>
										<a href="#d.link#">#d.heading#</a>
									<cfelse>
										#d.heading#
									</cfif>
								</div>
								<div class="z-t-16">#d.summary#</div>
								<cfif enableLinks>
									<a href="#d.link#" class="z-content-subpage-button z-float-left z-pt-40 z-fpb-20">Read More</a>
								</cfif>
							</div>
						</div>
					</div>
				</cfloop> 
			</div> 
		</div> 
	</section> 

</cffunction>

<cffunction name="getPropertyInclude" localmode="modern" output="yes" returntype="boolean">
	<cfargument name="argContentId" type="string" required="yes">
	<cfargument name="query" type="any" required="no" default="#false#">
	<cfargument name="arrOutputStruct" type="array" required="no" default="#[]#">
	<cfargument name="limit" type="numeric" required="no" default="#0#">
	<cfargument name="disableChildLinks" type="boolean" required="no" default="#false#">
	<cfargument name="layoutType" type="numeric" required="no" default="#0#">
	<cfscript>
	var db=request.zos.queryObject;
	var contentConfig=application.zcore.app.getAppCFC("content").getContentIncludeConfig();
	includeLoopCount=0;
	if(arguments.disableChildLinks){
		contentConfig.contentDisableLinks=true;
	}

	if(not structkeyexists(request.zos, 'thumbnailSizeStruct')){
		this.setRequestThumbnailSize(0,0,0); 
		if(contentConfig.contentEmailFormat or application.zcore.functions.zso(request, 'contentUseSmallThumbnails',false,false) NEQ false){
			request.zos.thumbnailSizeStruct.width=120;
			request.zos.thumbnailSizeStruct.height=90;
		}
	}
	if(isQuery(arguments.query) EQ false){
		// you must have a group by in your query or it may miss rows
		ts=structnew();
		ts.image_library_id_field="content.content_image_library_id";
		ts.count =  100;  
		rs=application.zcore.imageLibraryCom.getImageSQL(ts);
		db.sql="SELECT *  #db.trustedsql(rs.select)# 
		FROM #db.table("content", request.zos.zcoreDatasource)# content 
		#db.trustedsql(rs.leftJoin)# 
		WHERE content.site_id = #db.param(request.zos.globals.id)# and 
		content_id =#db.param(arguments.argContentId)# ";
		if(application.zcore.functions.zso(request.zsession, 'zcontentshowinactive') EQ 0){
			db.sql&=" and content_for_sale <> #db.param(2)# ";
		}
		db.sql&=" and content_deleted = #db.param(0)# 
		GROUP BY content.content_id ";
		qContent=db.execute("qContent");
		tempQueryName=qContent;
	}else{
		tempQueryName=arguments.query;
	}
	tempIndex=0;

	hasImages=false;
	arrData=[];


	for(row in tempQueryName){
		if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){
			echo('<p>Outputting child page: #row.content_id#</p>');
		}
		tempIndex++;
		if(arguments.limit NEQ 0 and tempIndex GT arguments.limit){
			break;
		}
		ts=structnew();
		ts.image_library_id=row.content_image_library_id;
		ts.output=false;
		ts.query=tempQueryName;
		ts.row=tempIndex;
		ts.size=request.zos.thumbnailSizeStruct.width&"x"&request.zos.thumbnailSizeStruct.height;
		ts.crop=request.zos.thumbnailSizeStruct.crop;
		ts.count = 1; 
		arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts);
		contentPhoto99=""; 
		if(arraylen(arrImages) NEQ 0){
			contentPhoto99=(arrImages[1].link);
			hasImages=true;
		}
		savecontent variable="output"{

			if(structkeyexists(request.zos, 'propertyIncludeIndex') EQ false){
				request.zos.propertyIncludeIndex=0;
			}
			request.zos.propertyIncludeIndex++;
			
			if(row.content_url_only NEQ ''){
				propertyLink=row.content_url_only;
			}else if(row.content_unique_name NEQ ''){
				propertyLink=row.content_unique_name;
			}else{
				propertyLink="/#application.zcore.functions.zURLEncode(row.content_name,'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_article_id#-#row.content_id#.html";
			}
			if(application.zcore.functions.zso(form, 'zsearchtexthighlight') NEQ ""){
				if(propertyLink DOES NOT CONTAIN "?"){
					propertyLink&="?ztv1=1";	
				}
				propertyLink&="&zsearchtexthighlight=#urlencodedformat(form.zsearchtexthighlight)#";
			}
			isListing=false;
			
			propertyLink=htmleditformat(propertyLink);
			cityName="";
			// listing layout is ugly and slow
			/*if(application.zcore.app.siteHasApp("listing")){
				propertyIncludeStruct=application.zcore.app.getAppCFC("listing").getListingPropertyInclude(row, contentConfig, contentPhoto99, propertyLink, isListing);
				cityname=propertyIncludeStruct.cityName;
				isListing=propertyIncludeStruct.isListing;
			}*/
			if(isListing EQ false){
				if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){
					echo("<p>Child page layout: regular: #row.content_id#</p>");
				}
				if(arguments.layoutType EQ 0 or arguments.layoutType EQ 1){
					beginEditLink(contentConfig, row.content_id, false);
					getPropertyIncludeHTML(contentConfig, contentPhoto99, row, cityName, propertyLink);
					endEditLink(contentConfig);
				}else if(arguments.layoutType GTE 14 and arguments.layoutType LTE 18){
					ts={
						heading:row.content_name,  
						summary:row.content_summary,
						link:propertyLink,
						image:contentPhoto99
					};
					arrayAppend(arrData, ts);
					contentConfig.contentForceOutput=true;
				}
			}
		}
		if(contentConfig.contentForceOutput EQ false){
			ts=StructNew();
			ts.output=output;
			if(row.content_price EQ 0){
				ts.price=1000000000;
			}else{
				ts.price=row.content_price;
			}
			ts.id=row.content_mls_number;
			ts.name=row.content_name;
			ts.sort=row.content_sort;
			application.zcore.app.getAppCFC("content").excludeContentId(row.content_id);
			arrayAppend(arguments.arrOutputStruct, ts);
		}else{
			if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){
				echo("<p>Child page output forced: #row.content_id#</p>");
			}
			writeoutput(output);	
		}
		includeLoopCount++;	
	}
	/* 
	14 = 2 column horizontal image/text panels
	15 = 3 column horizontal image/text panels
	16 = 2 column vertical image/text panels
	17 = 3 column vertical image/text panels  
	18 = 4 column vertical image/text panels  
	*/  
	if(arguments.layoutType EQ 14){
		ts={
			hasImages:hasImages,
			arrData:arrData,
			enableLinks:!contentConfig.contentDisableLinks
		};
		getContentInclude2ColumnHorizontal(ts);
	}else if(arguments.layoutType EQ 15){
		ts={
			hasImages:hasImages,
			arrData:arrData,
			enableLinks:!contentConfig.contentDisableLinks
		};
		getContentInclude3ColumnHorizontal(ts);
	}else if(arguments.layoutType EQ 16){
		ts={
			hasImages:hasImages,
			arrData:arrData,
			enableLinks:!contentConfig.contentDisableLinks
		};
		getContentInclude2ColumnVertical(ts);
	}else if(arguments.layoutType EQ 17){
		ts={
			hasImages:hasImages,
			arrData:arrData,
			enableLinks:!contentConfig.contentDisableLinks
		};
		getContentInclude3ColumnVertical(ts); 
	}else if(arguments.layoutType EQ 18){
		ts={
			hasImages:hasImages,
			arrData:arrData,
			enableLinks:!contentConfig.contentDisableLinks
		};
		getContentInclude4ColumnVertical(ts); 
	}
	return includeLoopCount;
	</cfscript>
</cffunction>

<cffunction name="searchCurrentParentLinks" localmode="modern" output="no" returntype="boolean" access="public">
	<cfargument name="theURL" type="string" required="yes">
	<cfscript> 
	if(structkeyexists(request.zos,'arrContentParentURLStruct')){
		for(i=arraylen(request.zos.arrContentParentURLStruct);i GTE 1;i--){
			if(compare(arguments.theURL, request.zos.arrContentParentURLStruct[i]) EQ 0 and request.zos.arrContentParentURLStruct[i] NEQ "/"){
				return true;	
			}
		}
	}
	return false;
	</cfscript>
</cffunction>
	
<cffunction name="getParentId" localmode="modern" output="no" returntype="boolean" access="public">
	<cfscript>
	if(structkeyexists(request.zos,'arrContentParentIDStruct')){
		return request.zos.arrContentParentIDStruct[arraylen(request.zos.arrContentParentIDStruct)];
	}
	return 0;
	</cfscript>
</cffunction>

<cffunction name="searchCurrentParentIds" localmode="modern" output="no" returntype="boolean" access="public">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	if(structkeyexists(request.zos,'arrContentParentIDStruct')){
		for(i=arraylen(request.zos.arrContentParentIDStruct);i GTE 1;i--){
			if(compare(arguments.id, request.zos.arrContentParentIDStruct[i]) EQ 0){
				return true;	
			}
		}
	}
	return false;
	</cfscript>
</cffunction>
	
<cffunction name="getSectionHomeLink" localmode="modern" access="public" output="no" returntype="string">
	<cfargument name="site_x_option_group_set_id" type="string" required="yes">
	<cfscript>
	application.zcore.functions.z404("getSectionHomeLink disabled");
	struct=application.zcore.functions.zGetSiteOptionGroupSetById(arguments.site_x_option_group_set_id);
	return "/#application.zcore.functions.zURLEncode(struct.__title,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_section_id#-#arguments.site_x_option_group_set_id#.html";
	</cfscript>
</cffunction>

<cffunction name="displayContentSection" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.functions.z404("displayContentSection disabled");
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);

	struct=application.zcore.functions.zGetSiteOptionGroupSetById(form.site_x_option_group_set_id);
	if(structcount(struct) EQ 0){
		application.zcore.functions.z404("form.site_x_option_group_set_id, ""#form.site_x_option_group_set_id#"" doesn't exist, so displayContentSection can't load.");
	}

	curLink=getSectionHomeLink(form.site_x_option_group_set_id);
	actualLink="/#application.zcore.functions.zso(form, 'zUrlName')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_section_id#-#form.site_x_option_group_set_id#.html";
	if(compare(curLink,actualLink) neq 0){
		application.zcore.functions.z301Redirect(curLink);
	}
/*
	ts=structnew(); 
	ts.showHidden=true;
	ts.beforeCode="";
	ts.afterCode="";
	ts.delimiter="";
	ts.linkTextLength=50; 
	ts.forceLinkForCurrentPage=true;
	ts.returnData=true; 
	ts.disableMoreLink=true;
	ts.site_x_option_group_set_id=form.site_x_option_group_set_id;
	ts.content_parent_id=0;
	r1=request.zos.tempObj.contentInstance.configCom.getSidebar(ts);
	writedump(r1);*/

	tempPageNav='<a href="/">#application.zcore.functions.zvar("homelinktext")#</a> / ';
	if(structkeyexists(struct, '__url')){
		tempPageNav&=' <a href="#struct.__url#">#struct.__title#</a> /';
	}
	application.zcore.template.setTag("pagenav",tempPageNav);
	affix=application.zcore.functions.zso(application.zcore.app.getAppData("content").optionStruct, 'content_config_section_title_affix');
	if(affix NEQ ""){
		title=struct.__title&" "&affix;
	}else{
		title=struct.__title&" Content Section";
	}
	application.zcore.template.setTag("pagetitle", title);
	application.zcore.template.setTag("title", title);



	application.zcore.app.getAppCFC("content").setContentIncludeConfig({});
	contentConfig=application.zcore.app.getAppCFC("content").getContentIncludeConfig();
	arrOutputStruct=[];
	ts1={
		content_subpage_link_layout:0,
		content_parentpage_link_layout:7,
		content_id:0,
		content_parent_id:0,
		content_include_listings:''
	};


	parentThumbnailSize={width:0, height:0, crop:0};
	setRequestThumbnailSize(parentThumbnailSize.width, parentThumbnailSize.height, parentThumbnailSize.crop);
	initExcludeContentId();

	curParentSorting=0;
	ts =structnew();
	ts.image_library_id_field="content.content_image_library_id";
	ts.count =  1; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="SELECT * ";
	if(curParentSorting EQ "3"){
		db.sql&=", if(content.content_menu_title = #db.param('')#, content.content_name, content.content_menu_title) as _sortName ";
	}
	db.sql&=" #db.trustedSQL(rs.select)# FROM #db.table("content", request.zos.zcoreDatasource)# content 
	#db.trustedSQL(rs.leftJoin)# 
	WHERE content.site_id = #db.param(request.zos.globals.id)# and 
	site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)#  and 
	content.content_parent_id =#db.param(0)# ";
	if(structkeyexists(form,'preview') EQ false and structkeyexists(request.zos, 'zcontentshowinactive') and request.zos.zcontentshowinactive EQ false){
		db.sql&=" and content_for_sale <> #db.param(2)#";
	}
	db.sql&=" and content_deleted = #db.param(0)# and 
	content_hide_link =#db.param(0)#";
	if(contentConfig.hideContentSold){
		db.sql&=" and content_for_sale =#db.param(1)#";
	}
	db.sql&=" GROUP BY content.content_id 
	ORDER BY ";
	if(curParentSorting EQ "3"){
		db.sql&=" _sortName ASC ";
	}else if(curParentSorting EQ "1"){
		db.sql&=" content_price desc ";
	}else if(curParentSorting EQ "2"){
		db.sql&=" content_price asc ";
	}else{
		db.sql&=" content_sort ASC, content_datetime DESC, content_created_datetime DESC ";
	}
	qContentChild=db.execute("qContentChild", "", 10000, "query", false);
	menuLinkStruct=getSectionDisplayMenuLinks(ts1, contentConfig, curParentSorting, qContentChild, 0, arrOutputStruct);
	

	uniqueChildStruct3838=structnew();
	for(i=1;i LTE arraylen(arrOutputStruct);i++){
		c=arrOutputStruct[i];
		if(c.id EQ "" or structkeyexists(uniqueChildStruct3838, c.id) EQ false){
			uniqueChildStruct3838[c.id]=true;
			writeoutput(c.output);
		}
	}
	/*
	outputStruct={};
	for(i=1;i LTE arraylen(arrOutputStruct);i++){
		outputStruct[i]=arrOutputStruct[i];
	}
	try{
		if(isNumeric(curParentSorting) EQ false){
			arrOrder=structsort(outputStruct,"numeric","asc","sort");
		}else if(curParentSorting EQ 1){
			arrOrder=structsort(outputStruct,"numeric","desc","price");
		}else if(curParentSorting EQ 2){
			arrOrder=structsort(outputStruct,"numeric","asc","price");
		}else if(curParentSorting EQ 3){
			arrOrder=structsort(outputStruct,"text","asc","name");
		}else if(curParentSorting EQ 0){
			arrOrder=structsort(outputStruct,"numeric","asc","sort");
		}else{
			arrOrder=structkeyarray(outputStruct);
			arraysort(arrOrder, "numeric", "asc");
		}
	}catch(Any excpt){
		arrOrder=structkeyarray(outputStruct);
		arraysort(arrOrder, "numeric", "asc");
	}
	if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){
		echo("curParentSorting: "&curParentSorting&"<br />");
		echo('Initial sort order: <br />');
		for(i in outputStruct){
			echo('##'&i&' id:'&outputStruct[i].id&' | sort: '&outputStruct[i].sort&'<br />');
		}
		echo('<br />Final sort order: <br />');
		for(i=1;i LTE arraylen(arrOrder);i++){
			echo('##'&i&' id:'&outputStruct[arrOrder[i]].id&' | sort: '&outputStruct[arrOrder[i]].sort&'<br />');
		}
		echo('<br />');
		
	}
	
	uniqueChildStruct3838=structnew();
	for(i=1;i LTE arraylen(arrOrder);i++){
		c=outputStruct[arrOrder[i]];
		if(c.id EQ "" or structkeyexists(uniqueChildStruct3838, c.id) EQ false){
		uniqueChildStruct3838[c.id]=true;
			writeoutput(c.output);
		}
	}*/
	</cfscript>

	
</cffunction>



<cffunction name="getSectionDisplayMenuLinks" localmode="modern" access="private">
	<cfargument name="qContent" type="any" required="yes">
	<cfargument name="contentConfig" type="struct" required="yes">
	<cfargument name="curParentSorting" type="numeric" required="yes">
	<cfargument name="qContentChild" type="any" required="yes">
	<cfargument name="propertyCount" type="numeric" required="yes">
	<cfargument name="arrOutputStruct" type="array" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	subpageLinkLayoutBackup=arguments.qContent.content_subpage_link_layout;
	parentpageLinkLayoutBackup=arguments.qContent.content_parentpage_link_layout;
	ts =structnew();
	out99="";
	ts.output=false;
	if(structkeyexists(request, 'zsidebarwidth')){
		ts.width=request.zsidebarwidth;
	}else{
		ts.width=225;
	}
	ts.arrLinks=arraynew(1);
	selectedContentId=arguments.qContent.content_id;
	selectedIndex=1;
	if(arguments.contentConfig.disableChildContent EQ false){
		if(arguments.qContent.content_parent_id NEQ 0){
			db.sql="SELECT * ";
			if(arguments.curParentSorting EQ "3"){
				db.sql&=" , if(content.content_menu_title = #db.param('')#, content.content_name, content.content_menu_title) as _sortName";
			}
			db.sql&=" FROM #db.table("content", request.zos.zcoreDatasource)# content 
			WHERE content.site_id = #db.param(request.zos.globals.id)# and 
			content.content_parent_id =#db.param(arguments.qContent.content_parent_id)# ";
			if(structkeyexists(form, 'preview') EQ false and request.zos.zcontentshowinactive EQ false){
				db.sql&=" and content_for_sale <> #db.param(2)# ";
		   	} 
		   	db.sql&=" and content_deleted = #db.param(0)# and 
		   	content_hide_link =#db.param(0)# ";
		   	if(arguments.contentConfig.hideContentSold){
		   		db.sql&=" and content_for_sale =#db.param(1)#";
		   	}
			db.sql&=" ORDER BY ";
			if(arguments.curParentSorting EQ "3"){
				db.sql&=" _sortName ASC ";
			}else if(arguments.curParentSorting EQ "1"){
				db.sql&=" content_price desc ";
			}else if(arguments.curParentSorting EQ "2"){
				db.sql&=" content_price asc ";
			}else{
				db.sql&=" content_sort ASC, content_datetime DESC, content_created_datetime DESC ";
			}
			qParent5=db.execute("qParent5");
			loop query="qParent5"{
				t2=structnew();
				t2.text=qParent5.content_name;
				if(qParent5.content_menu_title NEQ ""){
					t2.text=qParent5.content_menu_title;	
				}
				t2.photo="";
				t2.isparent=true;
				if(qParent5.content_id EQ selectedContentId){
					t2.type="selected";
					selectedIndex=arraylen(ts.arrLinks)+1;
				}else{
					t2.type="tab";
				}
				if(qParent5.content_url_only NEQ ''){
					t2.url=request.zos.currentHostName&qParent5.content_url_only;
				}else if(qParent5.content_unique_name NEQ ''){
					t2.url=request.zos.currentHostName&qParent5.content_unique_name;
				}else{ 
					t2.url=request.zos.currentHostName&"/#application.zcore.functions.zURLEncode(qParent5.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#qParent5.content_id#.html"; 
				}
				arrayappend(ts.arrLinks,t2);
			}
			if(qParent5.recordcount NEQ 0){
				ts.link_layout=parentpageLinkLayoutBackup;
				out99&=this.displayMenuLinks(ts);
			}
		}


		ts.arrLinks=arraynew(1);
		index=0;
		if(arguments.qContentChild.recordcount){
			for(row in arguments.qContentChild){
				index++;
				ts3=structnew();
				ts3.image_library_id=row.content_image_library_id;
				ts3.output=false;
				ts3.query=arguments.qContentChild;
				ts3.row=index;
				ts3.size=request.zos.thumbnailSizeStruct.width&"x"&request.zos.thumbnailSizeStruct.height;
				ts3.crop=request.zos.thumbnailSizeStruct.crop; 
				ts3.count = 1;
				arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts3);
				t2=structnew();
				t2.photo=""; 
				if(arraylen(arrImages) NEQ 0){
					t2.photo=(arrImages[1].link);
				}
				t2.text=row.content_name;
				if(row.content_menu_title NEQ ""){
					t2.text=row.content_menu_title;	
				}

				if(row.content_text EQ ''){
					t2.summary=row.content_summary;
				}else{
					t2.summary=row.content_text;
				}
				t2.summary=application.zcore.email.convertHTMLToText(t2.summary);
				t2.isparent=false;
				t2.type="subtab";
				if(row.content_url_only NEQ ""){
					t2.url=row.content_url_only;
				}else if(row.content_unique_name NEQ ''){
					t2.url=request.zos.currentHostName&row.content_unique_name;
				}else{ 
					t2.url=request.zos.currentHostName&"/#application.zcore.functions.zURLEncode(row.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#row.content_id#.html"; 
				}
				selectedIndex++;
				if(arraylen(ts.arrLinks) LT selectedIndex){
					arrayappend(ts.arrLinks,t2);
				}else{
					arrayinsertat(ts.arrLinks,selectedIndex,t2);
				}
			}
			if(arguments.qContentChild.recordcount NEQ 0){
				ts.link_layout=subpageLinkLayoutBackup;
				out99&=this.displayMenuLinks(ts);
			}

			
			if(subpageLinkLayoutBackup EQ 8 or subpageLinkLayoutBackup EQ 9 or subpageLinkLayoutBackup EQ 10){
				writeoutput(out99);
			}else if(application.zcore.app.getAppData("content").optionStruct.content_config_sidebar_tag NEQ ""){
				application.zcore.template.setTag(application.zcore.app.getAppData("content").optionStruct.content_config_sidebar_tag,out99);
			}else{
				application.zcore.template.prependtag("content",out99);
			}
			if(subpageLinkLayoutBackup EQ 1 or subpageLinkLayoutBackup EQ 0){
				if(subpageLinkLayoutBackup EQ 1){
					ts43=structnew();
					ts43.disableChildContentSummary=true;
					application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts43);
				}
				if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){
					echo('<p>Outputting children for page: #arguments.qContent.content_id#</p>');
				}
				application.zcore.app.getAppCFC("content").getPropertyInclude(row.content_id, false, arguments.arrOutputStruct);//, arguments.qContentChild, arguments.arrOutputStruct);
			}
			structdelete(request.zos,'contentPropertyIncludeQueryName');
		}
		/*if(arguments.qContent.content_include_listings NEQ ''){
			echo('<br style="clear:both;" />');
			if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){
				echo('<p>Outputting content_include_listings: #arguments.qContent.content_include_listings#</p>');
			}
			arrListings=listToArray(arguments.qContent.content_include_listings, ",");
			arguments.propertyCount+=arraylen(arrListings);
			for(i=1;i LTE arraylen(arrListings);i++){
				application.zcore.app.getAppCFC("content").getPropertyInclude(arrListings[i], false, arguments.arrOutputStruct);
			}
		}*/
	}
	return { propertyCount: arguments.propertyCount };
	</cfscript>
</cffunction>
	
<!--- split all the globals into function calls - then worry about mvc principles after it works with all the globals being updated. --->
<cffunction name="includeFullContent" localmode="modern" access="public" output="yes" returntype="boolean">
	<cfscript>
	var content_id=0;
	var db=request.zos.queryObject;
	var contentConfig=application.zcore.app.getAppCFC("content").getContentIncludeConfig();
	// uncomment to enable cache
	//application.zcore.cache.enableCache();
	// application.zcore.cache.setExpiration(seconds);
	/*cacheString=application.zcore.functions.zStructToCacheString(contentConfig);
	if(structkeyexists(application.sitestruct[request.zos.globals.id].contentPageCache, cacheString) and application.zcore.user.checkGroupAccess("member") EQ false){
		// needs to output the title, meta, stylesheets and script in struct instead of only the output!
		writeoutput(application.sitestruct[request.zos.globals.id].contentPageCache[cacheString]);
		return true;
	}*/
	application.zcore.app.getAppCFC("content").initExcludeContentId();
	if(structkeyexists(contentConfig, 'content_unique_name') and len(contentConfig.content_unique_name)){
		ts =structnew();
		ts.content_unique_name=contentConfig.content_unique_name;
		qContent=application.zcore.app.getAppCFC("content").getContentByName(ts);
		if(isQuery(qContent)){// and (contentConfig.disableContentMeta EQ false)){
			content_id=qContent.content_id;
		}else{
			return 0;
		}
	}else{
		if((contentConfig.disableContentMeta EQ false) and len(contentConfig.content_id)){
			content_id=contentConfig.content_id;
		}
	}/**/
	
	/*if(structkeyexists(application.sitestruct[request.zos.globals.id].contentPageIdCache, content_id) EQ false){
		application.sitestruct[request.zos.globals.id].contentPageIdCache[content_id]=structnew();
	}
	application.sitestruct[request.zos.globals.id].contentPageIdCache[content_id][cacheString]=true;
	*/
	if(not contentConfig.contentWasIncluded){
		if(len(content_id) EQ false or content_id EQ 0){
			if(contentConfig.disableContentMeta EQ false){
				application.zcore.functions.z301Redirect('/');
			}else{
				return 0;
			}
		}
	}
	if(structkeyexists(request.zos.userSession.groupAccess, "member")){
		if(structkeyexists(form, 'zcontentshowinactive')){
			request.zsession.zcontentshowinactive=form.zcontentshowinactive;
		}else{
			request.zsession.zcontentshowinactive=application.zcore.functions.zso(request.zsession, 'zcontentshowinactive',true);	
		}
		request.zos.zcontentshowinactive=true;
	}else{
		request.zos.zcontentshowinactive=false;
	}
	request.zos.requestLogEntry('content.cfc viewPage 1');
	//savecontent variable="output"{
		// you must have a group by in your query or it may miss rows
		ts =structnew();
		ts.image_library_id_field="content.content_image_library_id";
		ts.count =  1; // how many images to get
		rs=application.zcore.imageLibraryCom.getImageSQL(ts);
		db.sql="SELECT * #db.trustedsql(rs.select)# 
		FROM #db.table("content", request.zos.zcoreDatasource)# content  
		#db.trustedsql(rs.leftJoin)#  
		WHERE content.site_id = #db.param(request.zos.globals.id)#
		and content.content_id = #db.param(content_id)# ";
		if(structkeyexists(form, 'preview') EQ false and request.zos.zcontentshowinactive EQ false){
			db.sql&=" and content_for_sale <> #db.param(2)#";
		}
		db.sql&=" and content_deleted=#db.param(0)# 
		GROUP BY content.content_id ";
	   	qContent=db.execute("qContent");
		if(qContent.recordcount EQ 0 and contentConfig.disableContentMeta EQ false){
			application.zcore.functions.z404("Content record was missing in includeFullContent");
		} 
	   	if(qContent.site_x_option_group_set_id NEQ 0){
	   		form.site_x_option_group_set_id=qContent.site_x_option_group_set_id;
	   	}
		returnCountTotal=qContent.recordcount;
		ts994824713=structnew();
		application.zcore.functions.zQueryToStruct(qContent,ts994824713);
		 
		application.zcore.siteOptionCom.setCurrentOptionAppId(ts994824713.content_site_option_app_id);
		contentSearchMLS=ts994824713.content_search_mls;
		
		request.zos.zPrimaryContentId=content_id;
		parentChildSorting=ts994824713.content_child_sorting;
		if(not contentConfig.contentWasIncluded){
			if(ts994824713.content_unique_name EQ ""){
				if(structkeyexists(form, 'zurlname') and structkeyexists(form, 'forcecontent') EQ false and compare(application.zcore.functions.zURLEncode(ts994824713.content_name,'-'), form.zURLName) NEQ 0){
					application.zcore.functions.z301Redirect('/#application.zcore.functions.zURLEncode(ts994824713.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#ts994824713.content_id#.html');
				}
				currentContentURL='/#application.zcore.functions.zURLEncode(ts994824713.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#ts994824713.content_id#.html';
			}else{
				if(compare(ts994824713.content_unique_name, request.zos.originalURL) NEQ 0){
					application.zcore.functions.z301Redirect(ts994824713.content_unique_name);
				}
				currentContentURL=ts994824713.content_unique_name;
			}
			if(ts994824713.content_url_only NEQ "" and (left(ts994824713.content_url_only,1) EQ '/' or left(ts994824713.content_url_only,4) EQ 'http')){
				if(ts994824713.content_unique_name EQ "" or ts994824713.content_unique_name NEQ ts994824713.content_url_only){
					if('/#application.zcore.functions.zURLEncode(ts994824713.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#ts994824713.content_id#.html' NEQ ts994824713.content_url_only){
						application.zcore.functions.z301Redirect(ts994824713.content_url_only);	
					}
				}
			}
		}
		if(ts994824713.content_hide_modal EQ 1){
			application.zcore.functions.zModalCancel();	
		} 
		if(trim(ts994824713.content_engine_name) NEQ ''){
			request.engineName=ts994824713.content_engine_name;
		}
		mlsListingIncluded=false;
	
		form.content_parent_id = ts994824713.content_parent_id;

		request.zos.requestLogEntry('content.cfc viewPage 2'); 
		// savecontent variable="theContentHTMLSection"{

		if(ts994824713.content_image_library_layout EQ 11){
			echo('<div class="z-1of2 z-fluid-at-992 z-p-0">');
		}
		beginEditLink(contentConfig, ts994824713.content_id, true);
		if(ts994824713.content_image_library_layout NEQ 11 and (not application.zcore.imageLibraryCom.isBottomLayoutType(ts994824713.content_image_library_layout) or application.zcore.imageLibraryCom.isAlwaysDisplayedLayoutType(ts994824713.content_image_library_layout))){
			ts =structnew();
			ts.defaultAltText=ts994824713.content_name;
			ts.image_library_id=ts994824713.content_image_library_id;
			ts.size="#request.zos.globals.maximagewidth#x2000";
			ts.crop=0; 
			ts.top=true;
			ts.offset=0;
			if(ts994824713.content_image_library_layout EQ 7 or ts994824713.content_image_library_layout EQ 9){
				ts.limit=1;
			}
			ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(ts994824713.content_image_library_layout);
			application.zcore.imageLibraryCom.displayImages(ts); 
		}
		if(ts994824713.content_slideshow_id NEQ 0){
			echo('<table style="width:100%;" class="zContentSlideShowDiv"><tr><td style="text-align:center;">');
			application.zcore.functions.zEmbedSlideShow(ts994824713.content_slideshow_id);
			echo('</td></tr></table>');
		}
		application.zcore.app.getAppCFC("content").excludeContentId(ts994824713.content_id);
		rs=hasAccessToContentId(ts994824713.content_id); 
		request.zos.requestLogEntry('content.cfc viewPage 3');
		if(not rs.hasAccess or rs.forceLogin){ 
			actionVar=request.zos.originalURL;
			if(request.zos.cgi.query_string NEQ ""){
				actionVar&="?"&request.zos.cgi.query_string;
			}
			application.zcore.functions.zredirect("/z/user/preference/index?returnURL=#urlencodedformat(actionVar)#");
		}
		request.zos.arrContentParentIDStruct=arraynew(1);
		request.zos.arrContentParentURLStruct=arraynew(1);
		arrayappend(request.zos.arrContentParentIDStruct, ts994824713.content_id);
		if(ts994824713.content_url_only NEQ ''){
			arrayappend(request.zos.arrContentParentURLStruct, ts994824713.content_url_only);
		}else if(ts994824713.content_unique_name NEQ ''){
			arrayappend(request.zos.arrContentParentURLStruct, ts994824713.content_unique_name);
		}else{
			arrayappend(request.zos.arrContentParentURLStruct, "/#application.zcore.functions.zURLEncode(ts994824713.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#ts994824713.content_id#.html");
		}


		parentLinkStruct=getParentLinks(qContent);


		tempMeta='<meta name="Keywords" content="#htmleditformat(ts994824713.content_metakey)#" />
		<meta name="Description" content="#htmleditformat(ts994824713.content_metadesc)#" />';
		if(contentConfig.disableContentMeta EQ false){
			if(trim(ts994824713.content_metatitle) NEQ ""){
				application.zcore.template.setTag('title',ts994824713.content_metatitle);
			}else{
				application.zcore.template.setTag('title',ts994824713.content_name);
			}
			application.zcore.template.setTag('meta',tempMeta);
			application.zcore.template.setTag('pagetitle',replacenocase(replacenocase(ts994824713.content_name,"<br />"," ","ALL"),"<br />"," ","ALL"));
			application.zcore.template.setTag('menutitle',replacenocase(replacenocase(ts994824713.content_menu_title,"<br />"," ","ALL"),"<br />"," ","ALL"));
			application.zcore.template.setTag('pagenav', parentLinkStruct.pagenav);
		}
		if(ts994824713.content_name2 NEQ ''){
			echo('<h2>#htmleditformat(ts994824713.content_name2)#</h2>');
		} 
		if(ts994824713.content_datetime NEQ ''){
			echo('<strong class="news-date">Date: ');
			if(isdate(ts994824713.content_datetime)){
				echo(DateFormat(ts994824713.content_datetime,'m/d/yyyy'));
			}
			if(ts994824713.content_datetime NEQ '' and Timeformat(ts994824713.content_datetime,'HH:mm:ss') NEQ '00:00:00'){
				echo(TimeFormat(ts994824713.content_datetime,'h:mm tt'));
			}
			echo('</strong> <br /><br />');
		}
		if(ts994824713.content_for_sale EQ '3'){
			echo('<span style="color:##FF0000; font-size:14px; font-weight:bold;">This listing is SOLD</span><br /><br />');
		}else if(ts994824713.content_for_sale EQ '4'){
			echo('<span style="color:##FF0000; font-size:14px; font-weight:bold;">This listing is UNDER CONTRACT</span><br /><br />');
		}
		if(fileexists(request.zos.globals.homedir&'images/files/'&ts994824713.content_file)){
			echo('<table style="border-spacing:5px; width:150px;">
			<tr><td>');
			if(ts994824713.content_file_caption NEQ ''){
				echo(ts994824713.content_file_caption&'<br />');
			}
			echo('<a href="/images/files/#ts994824713.content_file#">Download File</a>
			</td></tr>
			</table>');
		}
		if(ts994824713.content_text EQ ''){
			ct1948=ts994824713.content_summary;
		}else{
			ct1948=ts994824713.content_text;
		} 
		ct1948_2=ts994824713.content_text2;
		ct1948_3=ts994824713.content_text3;
		if(application.zcore.app.siteHasApp("content") and application.zcore.app.getAppData("content").optionStruct.content_config_contact_links EQ 1 and ts994824713.content_disable_contact_links EQ 1){
			ct1948=rereplacenocase(ct1948,"(\b)(contact)(\b)",'\1<a href="/z/misc/inquiry/index" title="Contact Us">\2</a>\3',"ALL");
			ct1948=rereplacenocase(ct1948,"(\b)(email)(\b)",'\1<a href="/z/misc/inquiry/index" title="Email Us">\2</a>\3',"ALL");
			ct1948=rereplacenocase(ct1948,"(\b)(e-mail)(\b)",'\1<a href="/z/misc/inquiry/index" title="Email Us">\2</a>\3',"ALL");

			ct1948_2=rereplacenocase(ct1948_2,"(\b)(contact)(\b)",'\1<a href="/z/misc/inquiry/index" title="Contact Us">\2</a>\3',"ALL");
			ct1948_2=rereplacenocase(ct1948_2,"(\b)(email)(\b)",'\1<a href="/z/misc/inquiry/index" title="Email Us">\2</a>\3',"ALL");
			ct1948_2=rereplacenocase(ct1948_2,"(\b)(e-mail)(\b)",'\1<a href="/z/misc/inquiry/index" title="Email Us">\2</a>\3',"ALL");

			ct1948_3=rereplacenocase(ct1948_3,"(\b)(contact)(\b)",'\1<a href="/z/misc/inquiry/index" title="Contact Us">\2</a>\3',"ALL");
			ct1948_3=rereplacenocase(ct1948_3,"(\b)(email)(\b)",'\1<a href="/z/misc/inquiry/index" title="Email Us">\2</a>\3',"ALL");
			ct1948_3=rereplacenocase(ct1948_3,"(\b)(e-mail)(\b)",'\1<a href="/z/misc/inquiry/index" title="Email Us">\2</a>\3',"ALL");
		}
		if(ts994824713.content_metacode NEQ ""){
			application.zcore.template.appendTag("meta", ts994824713.content_metacode);
		}
		defaultLimit=application.zcore.functions.zso(application.zcore.app.getAppData("content").optionStruct,'content_config_child_display_limit', true, 20);
		if(defaultLimit EQ 0){
			defaultLimit=20;
		}
		form.offset=application.zcore.functions.zso(form, 'offset', true, 0);
		form.count=application.zcore.functions.zso(form, 'count', true, defaultLimit);
		
		request.zos.requestLogEntry('content.cfc viewPage 4');
		childContentStruct=displayChildContent(ts994824713, contentConfig, ct1948, form.offset, form.count);
		if(form.offset LT 0 or (form.offset NEQ 0 and childContentStruct.qContentChild.recordcount EQ 0)){
			application.zcore.functions.z301Redirect(request.zos.originalURL);
		}
		ct1948=childContentStruct.bodyText;
		request.zos.requestLogEntry('content.cfc viewPage 5');
		if(arraylen(contentConfig.arrContentReplaceKeywords)){
			for(i=1;i LTE arraylen(contentConfig.arrContentReplaceKeywords);i++){
				if(isDefined(contentConfig.arrContentReplaceKeywords[i])){
					ct1948=replacenocase(ct1948,"##"&contentConfig.arrContentReplaceKeywords[i]&"##",evaluate(contentConfig.arrContentReplaceKeywords[i]));
				}
			}
		}
		if(ts994824713.content_html_text_bottom EQ 0 and ts994824713.content_html_text NEQ ""){
			writeoutput(ts994824713.content_html_text&'<br style="clear:both;" />');
			if(application.zcore.app.siteHasApp("listing") and contentSearchMLS EQ 1){
				echo('<hr />');
			}
		}
		pcount=0;  
	 
		if(application.zcore.app.siteHasApp("listing") and qContent.content_search_mls EQ 1 and qContent.content_show_map EQ 1 and application.zcore.functions.zso(form, 'hidemls',true) EQ 0){
			application.zcore.listingStruct.functions.zListingDisplaySavedSearchMapSummary(ts994824713.content_saved_search_id);
		}   
		if(ts994824713.content_text_position EQ 0){
			column2Empty=application.zcore.functions.zIsEditorHTMLEmpty(qContent.content_text2);
			column3Empty=application.zcore.functions.zIsEditorHTMLEmpty(qContent.content_text3);
			if(application.zcore.functions.zso(request.zos.globals, 'enableCSSFramework', true, 0) EQ 1){
				if(column2Empty and not column3Empty){
					// only 1 and 3
					echo('<div class="z-float"><div class="z-1of2 z-p-0 z-ml-0">#ct1948#</div><div class="z-1of2 z-p-0 z-ml-0">#ct1948_3#</div></div>');
				}else if(not column2Empty and column3Empty){
					// only 1 and 2
					echo('<div class="z-float"><div class="z-1of2 z-p-0 z-ml-0">#ct1948#</div><div class="z-1of2 z-p-0 z-ml-0">#ct1948_2#</div></div>');
				}else if(not column2Empty and not column3Empty){
					// 1, 2 and 3
					echo('<div class="z-float"><div class="z-1of3 z-p-0 z-ml-0">#ct1948#</div><div class="z-1of3 z-p-0 z-ml-0">#ct1948_2#</div><div class="z-1of3 z-p-0 z-ml-0">#ct1948_3#</div></div>');
				}else{
					echo(ct1948);
				}
			}else{
				if(column2Empty and not column3Empty){
					// only 1 and 3
					echo('<div style="width:100%; float:left;"><div class="zContentColumn1of2">#ct1948#</div><div class="zContentColumn1of2">#ct1948_3#</div></div>');
				}else if(not column2Empty and column3Empty){
					// only 1 and 2
					echo('<div style="width:100%; float:left;"><div class="zContentColumn1of2">#ct1948#</div><div class="zContentColumn1of2">#ct1948_2#</div></div>');
				}else if(not column2Empty and not column3Empty){
					// 1, 2 and 3
					echo('<div style="width:100%; float:left;"><div class="zContentColumn1of3">#ct1948#</div><div class="zContentColumn1of3">#ct1948_2#</div><div class="zContentColumn1of3">#ct1948_3#</div></div>');
				}else{
					echo(ct1948);
				}
			}
			if(ct1948 NEQ ""){
				echo('<br style="clear:both;" />');
			}
		}
		endEditLink(contentConfig);
		 
		if(application.zcore.imageLibraryCom.isBottomLayoutType(ts994824713.content_image_library_layout) or application.zcore.imageLibraryCom.isAlwaysDisplayedLayoutType(ts994824713.content_image_library_layout)){
			echo('<div style="clear:both; width:100%; float:left;">');
			if(ts994824713.content_image_library_layout EQ 7 or ts994824713.content_image_library_layout EQ 9){ 
				ts =structnew();
				ts.defaultAltText=ts994824713.content_name;
				ts.image_library_id=ts994824713.content_image_library_id;
				ts.size="#request.zos.globals.maximagewidth#x2000";
				ts.crop=0;  
				ts.offset=1;
				ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(ts994824713.content_image_library_layout);
				application.zcore.imageLibraryCom.displayImages(ts);  
			}else{
				ts =structnew();
				ts.defaultAltText=ts994824713.content_name;
				ts.image_library_id=ts994824713.content_image_library_id;
				ts.size="#request.zos.globals.maximagewidth#x2000";
				ts.crop=0; 
				ts.top=true;
				ts.offset=0;
				if(ts994824713.content_image_library_layout EQ 7 or ts994824713.content_image_library_layout EQ 9){
					ts.limit=1;
				}
				ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(ts994824713.content_image_library_layout);
				application.zcore.imageLibraryCom.displayImages(ts);
			}
			echo('</div>');
		}
		if(ts994824713.content_html_text_bottom EQ 1 and ts994824713.content_html_text NEQ ""){
			writeoutput('<div style="width:100%; float:left;">'&ts994824713.content_html_text&'</div>');
		}
		if(structkeyexists(request.zos,'listingApp') and structkeyexists(request.zos,'listingApp') and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_compliantidx',false,true) EQ true and ts994824713.content_firm_name NEQ ''){
			echo('<br />Listing courtesy of #ts994824713.content_firm_name#');
		}

	if(ts994824713.content_image_library_layout EQ 11){
		echo('</div><div class="z-1of2 z-fluid-at-992 z-p-0">');
		ts =structnew();
		ts.defaultAltText=ts994824713.content_name;
		ts.image_library_id=ts994824713.content_image_library_id;
		ts.size="960x2000";
		ts.crop=0; 
		ts.offset=0;
		ts.limit=0;
		ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(ts994824713.content_image_library_layout);
		application.zcore.imageLibraryCom.displayImages(ts);
		echo('</div>');
	}
	//}
	// }
	// if(structkeyexists(form, 'zsearchtexthighlight') AND contentConfig.searchincludebars EQ false and form[request.zos.urlRoutingParameter] NEQ "/z/misc/search-site/results"){
	// 	t99=application.zcore.functions.zHighlightHTML(form.zsearchtexthighlight,theContentHTMLSection);
	// }else{
	// 	t99=theContentHTMLSection;
	// }
	// writeoutput(t99);
	if(request.zos.currentContentIncludeConfigStruct.contentWasIncluded EQ false and application.zcore.functions.zIsExternalCommentsEnabled()){
		 // display external comments
		 writeoutput(application.zcore.functions.zDisplayExternalComments(application.zcore.app.getAppData("content").optionstruct.app_x_site_id&"-"&ts994824713.content_id, ts994824713.content_name, request.zos.globals.domain&currentContentURL));
	}
	arrOutputStruct=[];
	menuLinkStruct=getDisplayMenuLinks(ts994824713, contentConfig, parentLinkStruct.curParentSorting, childContentStruct.qContentChild, pcount, arrOutputStruct, form.count);
	pcount=menuLinkStruct.propertyCount;
	if(pcount NEQ 0){
		//echo('<br style="clear:both;" />');
	}



	uniqueChildStruct3838=structnew();
	for(i=1;i LTE arraylen(arrOutputStruct);i++){
		c=arrOutputStruct[i];
		if(c.id EQ "" or structkeyexists(uniqueChildStruct3838, c.id) EQ false){
			uniqueChildStruct3838[c.id]=true;
			writeoutput(c.output);
		}
	}

	if(ts994824713.content_subpage_link_layout NEQ 13 and ts994824713.content_subpage_link_layout NEQ 7){
		savecontent variable="out1"{
			if(form.offset-form.count GTE 0){
				if(form.offset-form.count EQ 0){
					link=request.zos.originalURL;
				}else{
					link="#request.zos.originalURL#?offset=#form.offset-form.count#";
				}
				echo('<a href="#link#" style="padding:5px; display:block; float:left; border-radius:5px; background-color:##FFF; color:##000; border:1px solid ##999; text-decoration:none;">Previous</a>');
			}
			if(childContentStruct.hasMoreRecords){
				echo('<a href="#request.zos.originalURL#?offset=#form.offset+form.count#" style="padding:5px; display:block; float:right; border-radius:5px; background-color:##FFF; color:##000; border:1px solid ##999; text-decoration:none;">Next</a>');
			}
		}
		if(out1 NEQ ""){
			echo('<div style="clear:both;float:left; width:100%; margin-top:20px;  ">#out1#</div>');
		}
	} 
	if(application.zcore.app.siteHasApp("listing") and contentSearchMLS EQ 1){
		application.zcore.listingStruct.functions.zListingDisplaySavedSearch(ts994824713.content_saved_search_id);
	}

	if(ts994824713.content_text_position EQ 1){
		beginEditLink(contentConfig, ts994824713.content_id, false);
		writeoutput(ct1948);
		if(trim(ct1948) NEQ ""){
			writeoutput('<br style="clear:both;" />');
		}
		endEditLink(contentConfig);
		this.resetContentIncludeConfig();
	}
	//writeoutput(output);
	//application.sitestruct[request.zos.globals.id].contentPageCache[cacheString]=output;
	return returnCountTotal;
	</cfscript>
</cffunction>

<cffunction name="beginEditLink" localmode="modern" access="public">
	<cfargument name="contentConfig" type="struct" required="yes">
	<cfargument name="content_id" type="numeric" required="yes">
	<cfargument name="primary" type="boolean" required="yes" hint="If true, the h1 will be assigned to this record.">
	<cfscript>
	if(arguments.contentConfig.contentEmailFormat EQ false and arguments.contentConfig.editLinksEnabled){
	//structkeyexists(request.zos.userSession.groupAccess, "administrator") and 
		writeoutput('<div style="display:block; float:left; width:100%;"  id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit zEditorHTML" data-editurl="/z/content/admin/content-admin/edit?content_id=#arguments.content_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">');
		if(arguments.primary){
			application.zcore.template.prependTag('pagetitle','<span style="display:inline;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/content/admin/content-admin/edit?content_id=#arguments.content_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">');
			application.zcore.template.appendTag('pagetitle','</span>');
		}
	}
	</cfscript>
</cffunction>

<cffunction name="endEditLink" localmode="modern" access="public">
	<cfargument name="contentConfig" type="struct" required="yes">
	<cfscript>
	if(arguments.contentConfig.contentEmailFormat EQ false and arguments.contentConfig.editLinksEnabled){
	//structkeyexists(request.zos.userSession.groupAccess, "administrator") and 
		writeoutput('</div>');
	}
	</cfscript>
</cffunction>


<cffunction name="updateContentAccessCache" localmode="modern" access="public">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT content_id, content_user_group_id, content_parent_id 
	FROM #db.table("content", request.zos.zcoreDatasource)# content 
	WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	(content_parent_id <> #db.param(0)# or 
	content_user_group_id<>#db.param(0)#
	) and 
	content_deleted=#db.param(0)# ";
	qParent=db.execute("qParent");
	ts={};
	for(row in qParent){
		ts[row.content_id]={
			content_user_group_id: row.content_user_group_id,
			content_parent_id: row.content_parent_id
		};
	}
	arguments.sharedStruct.contentAccessCache=ts;
	</cfscript>
</cffunction>


<cffunction name="hasAccessToContentId" localmode="modern" access="public">
	<cfargument name="content_id" type="string" required="yes">
	<cfscript>
	if(not structkeyexists(application.siteStruct[request.zos.globals.id], 'contentAccessCache')){
		updateContentAccessCache(application.siteStruct[request.zos.globals.id]);
	}
	ts=application.siteStruct[request.zos.globals.id].contentAccessCache;
	cid=arguments.content_id;
	count=0;
	arrAllowGroupIds=[];
	while(true){
		count++;
		if(count EQ 100){
			throw("Infinite loop detected for arguments.content_id parent ids.");
		}
		if(structkeyexists(ts, cid)){
			curStruct=ts[cid];
			ArrayAppend(arrAllowGroupIds, cid);	
			cid=curStruct.content_parent_id;	
			if(curStruct.content_user_group_id EQ 0){
				continue;
			}else if(not application.zcore.user.checkGroupIdAccess(curStruct.content_user_group_id)){
				return { hasAccess:true, forceLogin:true, arrAllowGroupIds:arrAllowGroupIds  };
			}
			if(cid EQ 0){
				return { hasAccess:true, forceLogin:false, arrAllowGroupIds:arrAllowGroupIds };
			}
		}else{
			return { hasAccess:true, forceLogin:false, arrAllowGroupIds:arrAllowGroupIds };
		}
	}
	</cfscript>
</cffunction>

	
<cffunction name="displayChildContent" localmode="modern" access="private">
	<cfargument name="qContent" type="any" required="yes">
	<cfargument name="contentConfig" type="struct" required="yes">
	<cfargument name="bodyText" type="string" required="yes">
	<cfargument name="offset" type="numeric" required="no" default="#0#">
	<cfargument name="count" type="numeric" required="no" default="#10#">
	<cfscript>
	db=request.zos.queryObject;
	if(arguments.offset > 1000){
		application.zcore.functions.z404("Invalid offset: #arguments.offset#");
	}
	subpageLinkLayoutBackup=arguments.qContent.content_subpage_link_layout;
	if(arguments.contentConfig.disableChildContent EQ false){
		// you must have a group by in your query or it may miss rows
		ts =structnew();
		ts.image_library_id_field="content.content_image_library_id";
		ts.count =  1; // how many images to get
		rs=application.zcore.imageLibraryCom.getImageSQL(ts);
		db.sql="SELECT * ";
		if(arguments.qContent.content_child_sorting EQ "3"){
			db.sql&=", if(content.content_menu_title = #db.param('')#, content.content_name, content.content_menu_title) as _sortName ";
		}
		db.sql&=" #db.trustedSQL(rs.select)# FROM #db.table("content", request.zos.zcoreDatasource)# content 
		#db.trustedSQL(rs.leftJoin)# 
		WHERE content.site_id = #db.param(request.zos.globals.id)# and 
		content_id <> #db.param(arguments.qContent.content_id)#  and ";
		if(arguments.qContent.content_include_listings NEQ ""){
			arrId=listToArray(arguments.qContent.content_include_listings, ",");
			for(i=1;i LTE arraylen(arrId);i++){
				arrId[i]="'"&application.zcore.functions.zescape(arrId[i])&"'";
			}
			db.sql&=" (content.content_id IN (#db.trustedSQL(arrayToList(arrId, ","))#) or content.content_parent_id =#db.param(arguments.qContent.content_id)# ) ";
		}else{
			db.sql&=" content.content_parent_id =#db.param(arguments.qContent.content_id)# ";
		}
		
		if(structkeyexists(form,'preview') EQ false and request.zos.zcontentshowinactive EQ false){
			db.sql&=" and content_for_sale <> #db.param(2)#";
		}
		db.sql&=" and content_deleted = #db.param(0)# and 
		content_hide_link =#db.param(0)#";
		if(arguments.contentConfig.hideContentSold){
			db.sql&=" and content_for_sale =#db.param(1)#";
		}
		db.sql&=" GROUP BY content.content_id 
		ORDER BY ";
		if(arguments.qContent.content_child_sorting EQ "3"){
			db.sql&=" _sortName ASC ";
		}else if(arguments.qContent.content_child_sorting EQ "1"){
			db.sql&=" content_price desc ";
		}else if(arguments.qContent.content_child_sorting EQ "2"){
			db.sql&=" content_price asc ";
		}else{
			db.sql&=" content_sort ASC, content_datetime DESC, content_created_datetime DESC ";
		}
		if(arguments.count NEQ 0){
			db.sql&=" LIMIT #db.param(arguments.offset)#, #db.param(arguments.count+1)#";
		}
		qContentChild=db.execute("qContentChild", "", 10000, "query", false);
		if((subpageLinkLayoutBackup EQ "11" or subpageLinkLayoutBackup EQ "12") and arguments.bodyText CONTAINS '%child_links%'){
			savecontent variable="theChildLinkHTML"{
				if(subpageLinkLayoutBackup EQ "12"){
					writeoutput('<ul id="zcontent-child-links">');
				}
				index=1;
				for(row in qContentChild){
					ts=structnew();
					ts.image_library_id=row.content_image_library_id;
					ts.output=false;
					ts.query=qContentChild;
					ts.row=index;
					ts.size=request.zos.thumbnailSizeStruct.width&"x"&request.zos.thumbnailSizeStruct.height;
					ts.crop=request.zos.thumbnailSizeStruct.crop;
					ts.count = 1;
					arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts);
					t2=structnew();
					t2.photo=""; 
					if(arraylen(arrImages) NEQ 0){
						t2.photo=(arrImages[1].link);
					}
					t2.text=row.content_name;
					if(row.content_menu_title NEQ ""){
						t2.text=row.content_menu_title;	
					}
					t2.isparent=false;
					t2.type="subtab";
					if(row.content_url_only NEQ ''){
						t2.url=request.zos.currentHostName&row.content_url_only;
					}else if(row.content_unique_name NEQ ''){
						t2.url=request.zos.currentHostName&row.content_unique_name;
					}else{ 
						t2.url=request.zos.currentHostName&"/#application.zcore.functions.zURLEncode(row.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#row.content_id#.html"; 
					}
					if(subpageLinkLayoutBackup EQ "11"){
						writeoutput('<a href="#t2.url#">#t2.text#</a><br />');
					}else if(subpageLinkLayoutBackup EQ "12"){
						writeoutput('<li><a href="#t2.url#">#t2.text#</a></li>');
					}
					index++;
				}
				if(subpageLinkLayoutBackup EQ "12"){
					writeoutput('</ul>');
				}
			}
			arguments.bodyText=rereplacenocase(arguments.bodyText,"%child_links%", theChildLinkHTML,"ONE");
		
		}
	}else{
		qContentChild={ recordcount:0};
	}
	if(qContentChild.recordcount GT arguments.count){
		hasMoreRecords=true;
	}else{
		hasMoreRecords=false;
	}
	return { bodyText: arguments.bodyText, qContentChild: qContentChild, hasMoreRecords:hasMoreRecords  };
	</cfscript>
</cffunction>

<cffunction name="getParentLinks" localmode="modern" access="private" returntype="struct">
	<cfargument name="qContent" type="any" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	arrParentLinks=[];
	curParentSortingSet=false;
	curParentSorting=0;
	arrNav=ArrayNew(1);
	cpi=arguments.qContent.content_parent_id;
	parentThumbnailSize={width:0, height:0, crop:0};
	if(arguments.qContent.content_thumbnail_width EQ 0){
		setRequestThumbnailSize(parentThumbnailSize.width, parentThumbnailSize.height, parentThumbnailSize.crop);
	}else{
		setRequestThumbnailSize(arguments.qContent.content_thumbnail_width, arguments.qContent.content_thumbnail_height, arguments.qContent.content_thumbnail_crop);
	}
	theTemplate="";
	if(arguments.qContent.content_template NEQ "" and arguments.qContent.content_template NEQ 'default' and theTemplate EQ ''){
		theTemplate=arguments.qContent.content_template;
		application.zcore.template.setTemplate(arguments.qContent.content_template,true,true);
	}
	for(g=1;g LTE 255;g++){
		db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
		where ";
		if(cpi NEQ 0){
			db.sql&=" content_id = #db.param(cpi)#";
		}else{
			db.sql&=" content_unique_name = #db.param('/')#";
		}
		db.sql&=" and content.site_id = #db.param(request.zos.globals.id)# and 
		content_deleted=#db.param(0)# ";
		if(structkeyexists(form, 'preview') EQ false and request.zos.zcontentshowinactive EQ false){
			db.sql&=" and content_for_sale <> #db.param(2)# ";
		}
		db.sql&=" and content_hide_link=#db.param(0)# ";
		qpar=db.execute("qpar");
		if(qpar.recordcount EQ 0){
			break;
		}
		if(parentThumbnailSize.width EQ 0 and parentThumbnailSize.height EQ 0 and 
			(qpar.content_thumbnail_width NEQ 0 or qpar.content_thumbnail_height NEQ 0)){
			parentThumbnailSize.width=qpar.content_thumbnail_width;
			parentThumbnailSize.height=qpar.content_thumbnail_height;
			parentThumbnailSize.crop=qpar.content_thumbnail_crop;
		}
		if(not curParentSortingSet){
			curParentSorting=qpar.content_child_sorting;
		}if(qpar.content_template NEQ "" and qpar.content_template NEQ 'default' and theTemplate EQ ''){
			theTemplate=qpar.content_template;
			application.zcore.template.setTemplate(qpar.content_template,true,true);
		}
		if(cpi EQ 0){
			break;
		}
		arrayappend(request.zos.arrContentParentIDStruct, qpar.content_id);
		if(qpar.content_url_only NEQ ""){
			arrayappend(request.zos.arrContentParentURLStruct, qpar.content_url_only);
			arrayappend(arrNav, '<a href="#qpar.content_url_only#">#qpar.content_name#</a> / ');
		}else if(qpar.content_unique_name NEQ ''){
			arrayappend(request.zos.arrContentParentURLStruct, qpar.content_unique_name);
			arrayappend(arrNav, '<a href="#qpar.content_unique_name#">#qpar.content_name#</a> / ');
		}else{
			arrayappend(request.zos.arrContentParentURLStruct, "/#application.zcore.functions.zURLEncode(qpar.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#qpar.content_id#.html");
			arrayappend(arrNav, '<a href="/#application.zcore.functions.zURLEncode(qpar.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#qpar.content_id#.html">#qpar.content_name#</a> / ');
		}
		cpi=qpar.content_parent_id;
	
		t2=structnew();
		t2.type="tab";
		t2.text=qpar.content_name;
		if(qpar.content_url_only NEQ ""){
			t2.url=qpar.content_url_only;
		}else if(qpar.content_unique_name NEQ ''){
			t2.url=request.zos.currentHostName&qpar.content_unique_name;
		}else{ 
			t2.url=request.zos.currentHostName&"/#application.zcore.functions.zURLEncode(qpar.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#qpar.content_id#.html"; 
		}
		arrayprepend(arrParentLinks, t2);
		if(g GT 200){
			application.zcore.template.fail("Infinite loop on parent links");	
		}
		if(cpi EQ 0){
			break;
		}
	}
	savecontent variable="pagenav"{
		echo(' <a href="/">#application.zcore.functions.zvar('homelinktext')#</a> / ');
		for(i=arraylen(arrNav);i GTE 1;i=i-1){
			writeoutput(arrNav[i]);
		}
	}
	return { curParentSorting: curParentSorting, pagenav: pagenav };
	</cfscript>
</cffunction>

	

	
	
<cffunction name="getDisplayMenuLinks" localmode="modern" access="private">
	<cfargument name="qContent" type="any" required="yes">
	<cfargument name="contentConfig" type="struct" required="yes">
	<cfargument name="curParentSorting" type="numeric" required="yes">
	<cfargument name="qContentChild" type="any" required="yes">
	<cfargument name="propertyCount" type="numeric" required="yes">
	<cfargument name="arrOutputStruct" type="array" required="yes">
	<cfargument name="limit" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	subpageLinkLayoutBackup=arguments.qContent.content_subpage_link_layout;
	parentpageLinkLayoutBackup=arguments.qContent.content_parentpage_link_layout;
	ts =structnew();
	out99="";
	ts.output=false;
	if(structkeyexists(request, 'zsidebarwidth')){
		ts.width=request.zsidebarwidth;
	}else{
		ts.width=225;
	}
	ts.arrLinks=arraynew(1);
	selectedContentId=arguments.qContent.content_id;
	selectedIndex=1;
	if(arguments.contentConfig.disableChildContent EQ false){
		if(arguments.qContent.content_parent_id NEQ 0){
			db.sql="SELECT * ";
			if(arguments.curParentSorting EQ "3"){
				db.sql&=" , if(content.content_menu_title = #db.param('')#, content.content_name, content.content_menu_title) as _sortName";
			}
			db.sql&=" FROM #db.table("content", request.zos.zcoreDatasource)# content 
			WHERE content.site_id = #db.param(request.zos.globals.id)# and 
			content.content_parent_id =#db.param(arguments.qContent.content_parent_id)# ";
			if(structkeyexists(form, 'preview') EQ false and request.zos.zcontentshowinactive EQ false){
				db.sql&=" and content_for_sale <> #db.param(2)# ";
		   	} 
		   	db.sql&=" and content_deleted = #db.param(0)# and 
		   	content_hide_link =#db.param(0)# ";
		   	if(arguments.contentConfig.hideContentSold){
		   		db.sql&=" and content_for_sale =#db.param(1)#";
		   	}
			db.sql&=" ORDER BY ";
			if(arguments.curParentSorting EQ "3"){
				db.sql&=" _sortName ASC ";
			}else if(arguments.curParentSorting EQ "1"){
				db.sql&=" content_price desc ";
			}else if(arguments.curParentSorting EQ "2"){
				db.sql&=" content_price asc ";
			}else{
				db.sql&=" content_sort ASC, content_datetime DESC, content_created_datetime DESC ";
			}
			qParent5=db.execute("qParent5");
			loop query="qParent5"{
				t2=structnew();
				t2.text=qParent5.content_name;
				if(qParent5.content_menu_title NEQ ""){
					t2.text=qParent5.content_menu_title;	
				}
				t2.photo="";
				t2.isparent=true;
				if(qParent5.content_id EQ selectedContentId){
					t2.type="selected";
					selectedIndex=arraylen(ts.arrLinks)+1;
				}else{
					t2.type="tab";
				}
				if(qParent5.content_url_only NEQ ''){
					t2.url=request.zos.currentHostName&qParent5.content_url_only;
				}else if(qParent5.content_unique_name NEQ ''){
					t2.url=request.zos.currentHostName&qParent5.content_unique_name;
				}else{ 
					t2.url=request.zos.currentHostName&"/#application.zcore.functions.zURLEncode(qParent5.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#qParent5.content_id#.html"; 
				}
				arrayappend(ts.arrLinks,t2);
			}
			if(qParent5.recordcount NEQ 0){
				ts.link_layout=parentpageLinkLayoutBackup;
				out99&=this.displayMenuLinks(ts);
			}
		}


		ts.arrLinks=arraynew(1);
		index=0;
		if(arguments.qContentChild.recordcount){
			for(row in arguments.qContentChild){
				index++;
				if(index GT arguments.limit){
					break;
				}
				ts3=structnew();
				ts3.image_library_id=row.content_image_library_id;
				ts3.output=false;
				ts3.query=arguments.qContentChild;
				ts3.row=index;
				ts3.size=request.zos.thumbnailSizeStruct.width&"x"&request.zos.thumbnailSizeStruct.height;
				ts3.crop=request.zos.thumbnailSizeStruct.crop; 
				ts3.count = 1;
				arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts3);
				t2=structnew();
				t2.photo=""; 
				if(arraylen(arrImages) NEQ 0){
					t2.photo=(arrImages[1].link);
				}
				t2.text=row.content_name;
				if(row.content_menu_title NEQ ""){
					t2.text=row.content_menu_title;	
				}

				if(row.content_text EQ ''){
					t2.summary=row.content_summary;
				}else{
					t2.summary=row.content_text;
				}
				t2.summary=application.zcore.email.convertHTMLToText(t2.summary);
				t2.isparent=false;
				t2.type="subtab";
				if(row.content_url_only NEQ ""){
					t2.url=row.content_url_only;
				}else if(row.content_unique_name NEQ ''){
					t2.url=request.zos.currentHostName&row.content_unique_name;
				}else{ 
					t2.url=request.zos.currentHostName&"/#application.zcore.functions.zURLEncode(row.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#row.content_id#.html"; 
				}
				selectedIndex++;
				if(arraylen(ts.arrLinks) LT selectedIndex){
					arrayappend(ts.arrLinks,t2);
				}else{
					arrayinsertat(ts.arrLinks,selectedIndex,t2);
				}
			}
			if(arguments.qContentChild.recordcount NEQ 0){
				ts.link_layout=subpageLinkLayoutBackup;
				out99&=this.displayMenuLinks(ts);
			}

			
			if(subpageLinkLayoutBackup EQ 8 or subpageLinkLayoutBackup EQ 9 or subpageLinkLayoutBackup EQ 10){
				writeoutput(out99);
			}else if(application.zcore.app.getAppData("content").optionStruct.content_config_sidebar_tag NEQ ""){
				application.zcore.template.setTag(application.zcore.app.getAppData("content").optionStruct.content_config_sidebar_tag,out99);
			}else{
				application.zcore.template.prependtag("content",out99);
			}
			if(subpageLinkLayoutBackup EQ 1 or subpageLinkLayoutBackup EQ 0 or subpageLinkLayoutBackup EQ 14 or subpageLinkLayoutBackup EQ 15 or subpageLinkLayoutBackup EQ 16 or subpageLinkLayoutBackup EQ 17 or subpageLinkLayoutBackup EQ 18){
				if(subpageLinkLayoutBackup EQ 1){
					ts43=structnew();
					ts43.disableChildContentSummary=true;
					application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts43);
				}
				if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){
					echo('<p>Outputting children for page: #arguments.qContent.content_id#</p>');
				}

				// need to disable child links somehow, using 
				disableChildLinks=false;
				if(arguments.qContent.content_child_disable_links EQ 1){
					disableChildLinks=true;
				}

				application.zcore.app.getAppCFC("content").getPropertyInclude(arguments.qContent.content_id, arguments.qContentChild, arguments.arrOutputStruct, arguments.limit, disableChildLinks, subpageLinkLayoutBackup);
			}
			structdelete(request.zos,'contentPropertyIncludeQueryName');
		}
		/*if(arguments.qContent.content_include_listings NEQ ''){
			echo('<br style="clear:both;" />');
			if(request.zos.isDeveloper and structkeyexists(form, 'zdebug')){
				echo('<p>Outputting content_include_listings: #arguments.qContent.content_include_listings#</p>');
			}
			arrListings=listToArray(arguments.qContent.content_include_listings, ",");
			arguments.propertyCount+=arraylen(arrListings);
			for(i=1;i LTE arraylen(arrListings);i++){
				application.zcore.app.getAppCFC("content").getPropertyInclude(arrListings[i], false, arguments.arrOutputStruct);
			}
		}*/
	}
	return { propertyCount: arguments.propertyCount };
	</cfscript>
</cffunction>
	
	

<!--- 
<cfscript>
ts=structnew();
ts.width=190;
ts.arrLinks=[];
ts.output=true;
ts.tabClass="";
ts.subTabClass="";
ts.selectedClass="";
ts.columnClass="";
ts.containerClass="";
ts.columnContainerClass="";
displayMenuLinks(ts);
</cfscript>
 --->
<cffunction name="displayMenuLinks" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var arrOut=arraynew(1);
	var ts=structnew();
	var i=1;
	var c=0;
	var c2=0;
	var c3="";
	var c4="";
	var c5="";
	var c6="";
	var cw=0;
	var columnOutput=false;
	var lineCount=0;
	var lines=0; 
	ts.width=200;
	ts.fontSize=10;
	ts.output=false;
	ts.delimiter='<span class="zcontent-sublink-link-delimiter"> | </span>';
	ts.tabClass="zcontent-sublink-tab";
	ts.link_layout=0;
	ts.subLinkClass="zcontent-sublink-link";
	ts.subLinkSelectedClass="zcontent-sublink-link-selected";
	ts.subTabClass="zcontent-sublink-subtab";
	ts.selectedClass="zcontent-sublink-selected";
	ts.columnClass="zcontent-sublink-column";
	ts.containerClass="zcontent-sublink-container";
	ts.thumbnailContainerClass="zcontent-sublink-thumbnail-container";
	ts.thumbnailClass="zcontent-sublink-thumbnail";
	ts.thumbnailTextClass="zcontent-sublink-thumbnail-text";
	ts.columnContainerClass="zcontent-sublink-columncontainer";
	ts.tableofContentClass="zcontent-sublink-tableofcontents";
	structappend(arguments.ss, ts,false);
	if(arraylen(arguments.ss.arrLinks) EQ 0){
		return "";	
	}
	if(arguments.ss.link_layout EQ 13){
		request.zos.arrContentMenuLinks=arguments.ss.arrLinks;
		return '';
	}
	if(arguments.ss.link_layout EQ 7 or arguments.ss.link_layout EQ 0 or arguments.ss.link_layout EQ 1){
		// normal functionality...
		return "";
	}else if(arguments.ss.link_layout EQ 10){
		arrayappend(arrOut,'<div class="#arguments.ss.thumbnailContainerClass#">');
		for(i=1;i LTE arraylen(arguments.ss.arrLinks);i++){
			c=arguments.ss.arrLinks[i];
			arrayappend(arrOut,'<a href="'&htmleditformat(c.url)&'" class="#arguments.ss.thumbnailClass#"><img src="#c.photo#" alt="'&htmleditformat(c.text)&'" /><br /><span class="#arguments.ss.thumbnailTextClass#">'&htmleditformat(c.text)&'</span></a>');
		}
		arrayappend(arrOut,'</div>');
		
	}else if(arguments.ss.link_layout EQ 2 or arguments.ss.link_layout EQ 3 or arguments.ss.link_layout EQ 8 or arguments.ss.link_layout EQ 9){
		//Top with columns	
		if(arguments.ss.link_layout NEQ 3){
			c5='<ul class="zcontent-sublink-number-ul">';
			c6="</ul>";
		}else{
			c5='<ul class="zcontent-sublink-ul">';
			c6="</ul>";
		}
		arrayappend(arrOut, '<div class="#arguments.ss.columnContainerClass#"><div class="#arguments.ss.tableofContentClass#">TABLE OF CONTENTS</div>');
		arrayappend(arrOut,'<div class="#arguments.ss.columnClass#">#c5#');
		cw=(request.zos.globals.maximagewidth/2)-20;
		cw=cw/(arguments.ss.fontSize*1.4);
		lineCount=0;
		for(i=1;i LTE arraylen(arguments.ss.arrLinks);i++){
			lines=ceiling(len(arguments.ss.arrLinks[i].text)/cw);
			lineCount+=lines;
		}
		c2=ceiling((lineCount)/2);
		columnOutput=false;
		lineCount=0;
		for(i=1;i LTE arraylen(arguments.ss.arrLinks);i++){
			c=arguments.ss.arrLinks[i];
			lines=ceiling(len(arguments.ss.arrLinks[i].text)/cw);
			if(arguments.ss.link_layout NEQ 3 and arguments.ss.link_layout NEQ 9){
				c3='<li><span class="zcontent-sublink-number-style">'&i&'.</span><span class="zcontent-sublink-number-link">';
				c4="</span></li>";
			}else{
				c3="<li>";	
				c4="</li>";
			}
			if(columnOutput EQ false and lineCount GTE c2){
				columnOutput=true;
				// output new column	
				arrayappend(arrOut, '#c6#</div><div class="#arguments.ss.columnClass#">#c5#');
			}
			lineCount+=lines;
			if(c.type EQ "tab"){
				arrayappend(arrOut,'#c3#<a href="#c.url#" class="#arguments.ss.tabClass#">#c.text#</a>#c4#');
			}else if(c.type EQ 'subtab'){
				arrayappend(arrOut,'#c3#<a href="#c.url#" class="#arguments.ss.subTabClass#">#c.text#</a>#c4#');
			}else if(c.type EQ 'selected'){
				arrayappend(arrOut,'#c3#<span class="#arguments.ss.selectedClass#">#c.text#</span>#c4#');
			}else{
				application.zcore.template.fail("Invalid link type, #c.type#");	
			}
			
			
		}
		arrayappend(arrOut, '#c6#</div>');
		arrayappend(arrOut, '<br style="clear:both;" /></div>');
	}else if(arguments.ss.link_layout EQ 4){
		// Top on one line
		arrayappend(arrOut, '<div class="#arguments.ss.columnContainerClass#"><div class="#arguments.ss.tableofContentClass#">TABLE OF CONTENTS</div>');
		arrayappend(arrOut, '<div class="#arguments.ss.containerClass#">');
		for(i=1;i LTE arraylen(arguments.ss.arrLinks);i++){
			if(i EQ arraylen(arguments.ss.arrLinks)){
				arguments.ss.delimiter="";
			}
			c=arguments.ss.arrLinks[i]; 
			if(c.type EQ "tab"){
				arrayappend(arrOut,'<a href="#c.url#" class="#arguments.ss.subLinkClass#">#c.text#</a>#arguments.ss.delimiter#');
			}else if(c.type EQ 'subtab'){
				arrayappend(arrOut,'<a href="#c.url#" class="#arguments.ss.subLinkClass#">#c.text#</a>#arguments.ss.delimiter#');
			}else if(c.type EQ 'selected'){
				arrayappend(arrOut,'<span class="#arguments.ss.subLinkSelectedClass#">#c.text#</span>#arguments.ss.delimiter#');
			}else{
				application.zcore.template.fail("Invalid link type, #c.type#");	
			}
		}
		arrayappend(arrOut, '<br style="clear:both;" /></div>');
		arrayappend(arrOut, '</div>');
	}else if(arguments.ss.link_layout EQ 5){
		// create a left sidebar...
		
	}else if(arguments.ss.link_layout EQ 6){
		// create a right sidebar...
		
	}
	c=arraytolist(arrOut,"");
	if(arguments.ss.output){
		writeoutput(c);
	}else{
		return c;
	}
	</cfscript>
</cffunction>

<!--- application.zcore.app.getAppCFC("content").resetContentIncludeConfig(); --->
<cffunction name="resetContentIncludeConfig" localmode="modern" output="no" returntype="any">
	<cfscript>
	request.zos.currentContentIncludeConfigStruct={
		disableContentMeta=false,
		arrContentReplaceKeywords=[],
		searchincludebars=false,
		disableChildContentSummary=false,
		hideContentSold=false,
		disableChildContent=false,
		contentForceOutput=false,
		contentDisableLinks=false,
		contentSimpleFormat=false,
		tablestyle="",
		content_id="",
		contentWasIncluded=false,
		showmlsnumber=false,
		contentEmailFormat=false,
		editLinksEnabled=true
	};
	</cfscript>
</cffunction>

<!--- application.zcore.app.getAppCFC("content").getContentIncludeConfig(); --->
<cffunction name="getContentIncludeConfig" localmode="modern" output="no" returntype="struct">
	<cfscript>
	var ts=0;
	
	if(not structkeyexists(request.zos, 'currentContentIncludeConfigStruct') or not isStruct(request.zos.currentContentIncludeConfigStruct)){
		request.zos.currentContentIncludeConfigStruct={
			disableContentMeta=false,
			arrContentReplaceKeywords=[],
			searchincludebars=false,
			disableChildContentSummary=false,
			hideContentSold=false,
			disableChildContent=false,
			contentForceOutput=false,
			contentDisableLinks=false,
			contentSimpleFormat=false,
			tablestyle="",
			content_id="",
			contentWasIncluded=false,
			showmlsnumber=false,
			contentEmailFormat=false,
			editLinksEnabled=true
		};
	} 
	return request.zos.currentContentIncludeConfigStruct;
	</cfscript>
</cffunction>

<!--- application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts); --->
<cffunction name="setContentIncludeConfig" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	if(structkeyexists(request.zos, 'currentContentIncludeConfigStruct') EQ false){
		request.zos.currentContentIncludeConfigStruct={
			disableContentMeta=false,
			arrContentReplaceKeywords=[],
			searchincludebars=false,
			disableChildContentSummary=false,
			hideContentSold=false,
			disableChildContent=false,
			contentForceOutput=false,
			contentDisableLinks=false,
			contentSimpleFormat=false,
			tablestyle="",
			content_id="",
			contentWasIncluded=false,
			showmlsnumber=false,
			contentEmailFormat=false,
			editLinksEnabled=true
		};
	}
	structappend(request.zos.currentContentIncludeConfigStruct, arguments.ss, true);
	</cfscript>
</cffunction>


</cfoutput>
</cfcomponent>