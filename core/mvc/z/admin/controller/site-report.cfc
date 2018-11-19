<cfcomponent>
<cfoutput>
<!--- 
TODO:
strip <script>.*?</script>

done: reduce the load on server by using sleep after each zVerifyLink
done: make it able to avoid recrawling urls that were already checked.
done: no external link crawling
done: make the report able to show only 1 site's data.
not done: allow client to run report for only their site. - it must be queued and happen after everyone else's report is done.

more?

 --->

<cffunction name="zVerifyHTMLLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfargument name="theHTML" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
    <cfscript>
	
	var db=request.zos.queryObject;
	local.arrR=arraynew(1);
	local.links=rereplacenocase(rereplacenocase(replace(replace(arguments.theHTML,chr(9),' ','ALL'),chr(10),'','ALL'),'<script [^>]*>.*?</script>',' ','all'),'<style [^>]*>.*?</style>',' ','all');
	//local.links=replace(rereplacenocase(arguments.theHTML,'<script>.*?</script>',' ','all'),chr(9),' ','ALL');
	//local.links=replace(local.links,chr(10),'','ALL');
	local.cp=1;
	local.arrLinks=arraynew(1);
	
	while(true){
		local.v22=refindnocase("<.*?((src|href)\s*=\s*?(""|')*)([^\3^>\^'^\""]*)((\3)*)", local.links, local.cp, true);
		if(local.v22.pos[1] EQ 0) break;
		local.n=mid(local.links, local.v22.pos[5], local.v22.len[5]);
		local.cp=local.v22.pos[5]+local.v22.len[5];
		arrayappend(local.arrLinks, urldecode(replace(replace(local.n, "&amp;","&","all"),"/../","/","all")));
	}
	if(arraylen(local.arrLinks) NEQ 0){
		for(local.i=1;local.i LTE arraylen(local.arrLinks);local.i++){
			if(replacelist(local.arrLinks[local.i],'>,javascript:,mailto:,data:',',,') EQ local.arrLinks[local.i] and left(trim(local.arrLinks[local.i]),1) NEQ "##"){
				local.a1=listtoarray(local.arrLinks[local.i],"##",true);
				local.arrLinks[local.i]=local.a1[1];
				local.t1=application.zcore.functions.zForceAbsoluteURL(application.zcore.functions.zvar('domain',arguments.site_id), local.arrLinks[local.i]);
				if(structkeyexists(request.tempUniqueLinkStruct99, local.t1) EQ false){
					request.tempUniqueLinkStruct99[local.t1]=true;
					if(this.zIsLinkHashAlreadyChecked(local.t1) EQ false){
						if(request.zos.istestserver EQ false){
							sleep(50);
						}
						if(local.t1 DOES NOT CONTAIN "/z/index.php" and local.t1 DOES NOT CONTAIN "/z/_a/"){
							//writeoutput("curlink:"&local.t1&"<br />");
							local.r1=application.zcore.functions.zVerifyLink(local.t1,'', 10);	
							if(local.r1 EQ false){
								request.tempUniqueLinkStruct99[local.t1]=false;
								arrayappend(local.arrR, local.t1);
								this.zStoreLinkHash(local.t1, 0);
							}else{
								this.zStoreLinkHash(local.t1, 1);
							}
						}
					}
				}else{
					if(request.tempUniqueLinkStruct99[local.t1] EQ false){
						arrayappend(local.arrR, local.t1);
					}
				}
			}
		}
	}
	return local.arrR;
	</cfscript>
</cffunction>

<cffunction name="zStoreLinkStatus" localmode="modern" output="yes" access="private" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	
	var db=request.zos.queryObject;
	local.dt=request.zos.mysqlnow;
	</cfscript>
    
    <cfsavecontent variable="db.sql">
    INSERT INTO #request.zos.queryObject.table("link_verify_status", request.zos.zcoreDatasource)#  SET 
    site_id =#db.param(arguments.ss.site_id)#, 
    link_verify_status_table=#db.param(arguments.ss.table)#, 
    link_verify_status_tableid=#db.param(arguments.ss.tableid)#, 
    link_verify_status_status=#db.param(arguments.ss.status)#,
    link_verify_status_links=#db.param(arguments.ss.links)#, 
    link_verify_status_datetime=#db.param(local.dt)#, 
	link_verify_status_updated_datetime=#db.param(request.zos.mysqlnow)#
    ON DUPLICATE KEY UPDATE 
    link_verify_status_status=#db.param(arguments.ss.status)#,
    link_verify_status_links=#db.param(arguments.ss.links)#, 
    link_verify_status_datetime=#db.param(local.dt)#, 
	link_verify_status_updated_datetime=#db.param(request.zos.mysqlnow)#
    </cfsavecontent><cfscript>local.qI=db.execute("qI");</cfscript>
</cffunction>


<cffunction name="zVerifyInternalContentsLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
	
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("content", request.zos.zcoreDatasource)# content 
		WHERE content_deleted=#db.param(0)# and 
		site_id IN (#db.trustedSQL(request.siteIdListTemp99)#) ORDER BY site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        
        <cfset application.siteReportCurrentPosition="zVerifyInternalContentsLinks:"&local.lastOffset>
        <!--- <cfset application.siteReportCurrentOut=""> --->
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
	        <cfset application.siteReportCurrentSiteId=site_id>
            <cfscript>
            local.arrLinks=arraynew(1);
            if(content_summary NEQ ""){
                local.arrR=this.zVerifyHTMLLinks(content_summary, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Summary Text"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/content/admin/content-admin/edit?content_id="&content_id);
            }
            if(content_text NEQ ""){
                local.arrR=this.zVerifyHTMLLinks(content_text, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Body Text"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/content/admin/content-admin/edit?content_id="&content_id);
            }
            if(content_url_only NEQ ""){
                local.t1=application.zcore.functions.zForceAbsoluteURL(application.zcore.functions.zvar('domain',site_id), content_url_only);
				if(structkeyexists(request.tempUniqueLinkStruct99, local.t1) EQ false){
					request.tempUniqueLinkStruct99[local.t1]=true;
					if(this.zIsLinkHashAlreadyChecked(local.t1) EQ false){
						if(request.zos.istestserver EQ false or local.t1 CONTAINS "."&request.zos.testDomain){
							//application.siteReportCurrentOut&=(local.t1&' | '&content_url_only&'<br />');
							local.r1=application.zcore.functions.zVerifyLink(urldecode(replace(replace(local.t1, "&amp;","&","all"),'/../','/','all')),'', 10);
							//local.r1=true;
							if(local.r1 EQ false){
								this.zStoreLinkHash(local.t1, 0);
								request.tempUniqueLinkStruct99[local.t1]=false;
								arrayappend(local.arrLinks, "External URL"&chr(9)&local.t1&chr(9)&"/z/content/admin/content-admin/edit?content_id="&content_id);
							}else{
								this.zStoreLinkHash(local.t1, 1);
							}
						}
					}
				}else{
					if(request.tempUniqueLinkStruct99[local.t1] EQ false){
						arrayappend(local.arrLinks, "External URL"&chr(9)&local.t1&chr(9)&"/z/content/admin/content-admin/edit?content_id="&content_id);
					}
				}
            }
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="content";
				local.ts.tableid=content_id;
				if(arraylen(local.arrLinks) EQ 0){
					local.ts.status=1;
				}else{
					local.ts.status=0;
				}
				local.ts.site_id=site_id;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>


<cffunction name="zVerifyInternalBlogArticleLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT * from #request.zos.queryObject.table("blog", request.zos.zcoreDatasource)# blog 
		WHERE blog_story <> #db.param('')# and 
		blog_deleted = #db.param(0)# and 
		site_id IN (#db.trustedSQL(request.siteIdListTemp99)#) 
		ORDER BY site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        <cfset application.siteReportCurrentPosition="zVerifyInternalBlogArticleLinks:"&local.lastOffset>
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
	        <cfset application.siteReportCurrentSiteId=site_id>
            <cfscript>
            local.arrLinks=arraynew(1);
            if(blog_story NEQ ""){
                local.arrR=this.zVerifyHTMLLinks(blog_story, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Body Text"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/blog/admin/blog-admin/articleEdit?blog_id="&blog_id);
            }
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="blog";
				local.ts.tableid=blog_id;
				if(arraylen(local.arrLinks) EQ 0){local.ts.status=1;}else{local.ts.status=0;}
				local.ts.site_id=site_id;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>


<cffunction name="zVerifyInternalBlogCategoryLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("blog_category", request.zos.zcoreDatasource)# blog_category 
		WHERE blog_category_description <> #db.param('')# and 
		blog_category_deleted = #db.param(0)# and
		site_id IN (#db.trustedSQL(request.siteIdListTemp99)#) ORDER BY site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        <cfset application.siteReportCurrentPosition="zVerifyInternalBlogCategoryLinks:"&local.lastOffset>
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
	        <cfset application.siteReportCurrentSiteId=site_id>
            <cfscript>
            local.arrLinks=arraynew(1);
            if(blog_category_description NEQ ""){
                local.arrR=this.zVerifyHTMLLinks(blog_category_description, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Description"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/blog/admin/blog-admin/categoryEdit?blog_category_id="&blog_category_id);
            }
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="blog_category";
				local.ts.tableid=blog_category_id;
				if(arraylen(local.arrLinks) EQ 0){local.ts.status=1;}else{local.ts.status=0;}
				local.ts.site_id=site_id;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>

<cffunction name="zVerifyInternalBlogTagLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
	
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("blog_tag", request.zos.zcoreDatasource)# blog_tag 
		WHERE blog_tag_description <> #db.param('')# and 
		blog_tag_deleted = #db.param(0)# and
		site_id IN (#db.trustedSQL(request.siteIdListTemp99)#) ORDER BY site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        <cfset application.siteReportCurrentPosition="zVerifyInternalBlogTagLinks:"&local.lastOffset>
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
	        <cfset application.siteReportCurrentSiteId=site_id>
            <cfscript>
            local.arrLinks=arraynew(1);
            if(blog_tag_description NEQ ""){
                local.arrR=this.zVerifyHTMLLinks(blog_tag_description, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Description"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/blog/admin/blog-admin/tagEdit?blog_tag_id="&blog_tag_id);
            }
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="blog_tag";
				local.ts.tableid=blog_tag_id;
				if(arraylen(local.arrLinks) EQ 0){local.ts.status=1;}else{local.ts.status=0;}
				local.ts.site_id=site_id;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>


<cffunction name="zVerifyInternalMenuButtonLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("menu_button", request.zos.zcoreDatasource)# menu_button, 
		#request.zos.queryObject.table("menu_button_link", request.zos.zcoreDatasource)# 
		WHERE menu_button_link <> #db.param('')# and 
		menu_button_deleted = #db.param(0)# and 
		menu_button_link_deleted = #db.param(0)# and
		menu_button.site_id = menu_button_link.site_id and 
		menu_button.site_id IN (#db.trustedSQL(request.siteIdListTemp99)#) 
		ORDER BY menu_button.site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        <cfset application.siteReportCurrentPosition="zVerifyInternalMenuButtonLinks:"&local.lastOffset>
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
	        <cfset application.siteReportCurrentSiteId=local.qC.site_id>
            <cfscript>
            local.arrLinks=arraynew(1);
            if(local.qC.menu_button_link NEQ ""){
                local.t1=application.zcore.functions.zForceAbsoluteURL(application.zcore.functions.zvar('domain',local.qC.site_id), local.qC.menu_button_link);
				if(structkeyexists(request.tempUniqueLinkStruct99, local.t1) EQ false){
					request.tempUniqueLinkStruct99[local.t1]=true;
					if(this.zIsLinkHashAlreadyChecked(local.t1) EQ false){
						if(request.zos.istestserver EQ false or local.t1 CONTAINS "."&request.zos.testDomain){
							local.r1=application.zcore.functions.zVerifyLink(urldecode(replace(replace(local.t1, "&amp;","&","all"),'/../','/','all')),'', 10);
							if(local.r1 EQ false){
								this.zStoreLinkHash(local.t1, 0);
								request.tempUniqueLinkStruct99[local.t1]=false;
								arrayappend(local.arrLinks, "URL"&chr(9)&local.t1&chr(9)&"/z/admin/menu/editItem?menu_id="&local.qC.menu_id&"&menu_button_id="&local.qC.menu_button_id);
							}else{
								this.zStoreLinkHash(local.t1, 1);
							}
						}
					}
				}else{
					if(request.tempUniqueLinkStruct99[local.t1] EQ false){
						arrayappend(local.arrLinks, "URL"&chr(9)&local.t1&chr(9)&"/z/admin/menu/editItem?menu_id="&local.qC.menu_id&"&menu_button_id="&local.qC.menu_button_id);
					}
				}
            }
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="menu_button";
				local.ts.tableid=local.qC.menu_button_id;
				if(arraylen(local.arrLinks) EQ 0){local.ts.status=1;}else{local.ts.status=0;}
				local.ts.site_id=local.qC.site_id;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>

<cffunction name="zVerifyInternalMenuButtonLinkLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("menu_button_link", request.zos.zcoreDatasource)# menu_button_link, 
		#request.zos.queryObject.table("menu_button", request.zos.zcoreDatasource)# menu_button 
		WHERE menu_button_link.menu_button_id = menu_button.menu_button_id and 
		menu_button_link_deleted = #db.param(0)# and 
		menu_button_deleted = #db.param(0)# and
		menu_button_link_url <> #db.param('')# and 
		menu_button_link.site_id = menu_button.site_id and 
		menu_button_link.site_id IN (#db.trustedSQL(request.siteIdListTemp99)#) 
		ORDER BY menu_button_link.site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        <cfset application.siteReportCurrentPosition="zVerifyInternalMenuButtonLinkLinks:"&local.lastOffset>
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
	        <cfset application.siteReportCurrentSiteId=site_id>
            <cfscript>
            local.arrLinks=arraynew(1);
            if(menu_button_link_url NEQ ""){
                local.t1=application.zcore.functions.zForceAbsoluteURL(application.zcore.functions.zvar('domain',site_id), menu_button_link_url);
				if(structkeyexists(request.tempUniqueLinkStruct99, local.t1) EQ false){
					request.tempUniqueLinkStruct99[local.t1]=true;
					if(this.zIsLinkHashAlreadyChecked(local.t1) EQ false){
						if(request.zos.istestserver EQ false or local.t1 CONTAINS "."&request.zos.testDomain){
							local.r1=application.zcore.functions.zVerifyLink(urldecode(replace(replace(local.t1, "&amp;","&","all"),'/../','/','all')),'', 10);
							if(local.r1 EQ false){
								this.zStoreLinkHash(local.t1, 0);
								request.tempUniqueLinkStruct99[local.t1]=false;
								arrayappend(local.arrLinks, "URL"&chr(9)&local.t1&chr(9)&"/z/admin/menu/editItemLink?menu_id="&menu_id&"&menu_button_id="&menu_button_id&"&menu_button_link_id="&menu_button_link_id);
							}else{
								this.zStoreLinkHash(local.t1, 1);
							}
						}
					}
				}else{
					if(request.tempUniqueLinkStruct99[local.t1] EQ false){
						arrayappend(local.arrLinks, "URL"&chr(9)&local.t1&chr(9)&"/z/admin/menu/editItemLink?menu_id="&menu_id&"&menu_button_id="&menu_button_id&"&menu_button_link_id="&menu_button_link_id);
					}
				}
            }
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="menu_button_link";
				local.ts.tableid=menu_button_link_id;
				if(arraylen(local.arrLinks) EQ 0){local.ts.status=1;}else{local.ts.status=0;}
				local.ts.site_id=site_id;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>



<cffunction name="zVerifyInternalSiteOptionLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT *, site_x_option.site_id curSiteId 
		FROM #request.zos.queryObject.table("site_option", request.zos.zcoreDatasource)# site_option, 
		#request.zos.queryObject.table("site_x_option", request.zos.zcoreDatasource)# site_x_option 
		WHERE site_option_name NOT IN (#db.param('Visitor Tracking Code')#,#db.param('Lead Conversion Tracking Code')#) and 
		site_option_deleted = #db.param(0)# and 
		site_x_option_deleted = #db.param(0)# and 
		site_option.site_option_id = site_x_option.site_option_id and 
		site_option.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("site_x_option.site_option_id_siteIDType"))# and 
		site_x_option_value <> #db.param('')#  and 
		site_x_option.site_id IN (#db.trustedSQL(request.siteIdListTemp99)#) 
		ORDER BY site_x_option.site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        <cfset application.siteReportCurrentPosition="zVerifyInternalSiteOptionLinks:"&local.lastOffset>
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
	        <cfset application.siteReportCurrentSiteId=curSiteId>
            <cfscript>
            local.arrLinks=arraynew(1);
            if(site_x_option_value CONTAINS "</"){
                local.arrR=this.zVerifyHTMLLinks(site_x_option_value, curSiteId);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, site_option_name&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/admin/site-options/index##soid_"&site_option_id);
            }else if(left(site_x_option_value, 5) EQ "http:" or left(site_x_option_value, 6) EQ "https:"){
                local.t1=application.zcore.functions.zForceAbsoluteURL(application.zcore.functions.zvar('domain',curSiteId), site_x_option_value);
				if(structkeyexists(request.tempUniqueLinkStruct99, local.t1) EQ false){
					request.tempUniqueLinkStruct99[local.t1]=true;
					if(this.zIsLinkHashAlreadyChecked(local.t1) EQ false){
						if(request.zos.istestserver EQ false or local.t1 CONTAINS "."&request.zos.testDomain){
							local.r1=application.zcore.functions.zVerifyLink(urldecode(replace(replace(local.t1, "&amp;","&","all"),'/../','/','all')),'', 10);
							if(local.r1 EQ false){
								this.zStoreLinkHash(local.t1, 0);
								request.tempUniqueLinkStruct99[local.t1]=false;
								arrayappend(local.arrLinks, site_option_name&chr(9)&local.t1&chr(9)&"/z/admin/site-options/index##soid_"&site_option_id);
							}else{
								this.zStoreLinkHash(local.t1, 1);
								
							}
						}
					}
				}else{
					if(request.tempUniqueLinkStruct99[local.t1] EQ false){
						arrayappend(local.arrLinks, site_option_name&chr(9)&local.t1&chr(9)&"/z/admin/site-options/index##soid_"&site_option_id);
					}
				}
			}
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="site_x_option";
				local.ts.tableid=site_x_option_id;
				if(arraylen(local.arrLinks) EQ 0){local.ts.status=1;}else{local.ts.status=0;}
				local.ts.site_id=curSiteId;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>

<cffunction name="zVerifyInternalSiteOptionGroupLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT *, site_x_option_group.site_id curSiteId FROM 
		#request.zos.queryObject.table("site_option", request.zos.zcoreDatasource)# site_option, 
		#request.zos.queryObject.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group, 
		#request.zos.queryObject.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set 
		WHERE site_x_option_group.site_x_option_group_set_id = site_x_option_group_set.site_x_option_group_set_id and 
		site_option_deleted = #db.param(0)# and 
		site_x_option_group_deleted = #db.param(0)# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		site_x_option_group_set_deleted = #db.param(0)# and
		site_option.site_option_id = site_x_option_group.site_option_id and 
		site_option.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("site_x_option_group.site_option_id_siteIDType"))# and 
		site_x_option_group_set.site_id = site_x_option_group.site_id and 
		site_x_option_group_value <> #db.param('')#  and 
		site_x_option_group.site_id IN (#db.param(request.siteIdListTemp99)#) 
         ORDER BY site_x_option_group.site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        <cfset application.siteReportCurrentPosition="zVerifyInternalSiteOptionGroupLinks:"&local.lastOffset>
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
	        <cfset application.siteReportCurrentSiteId=curSiteId>
            <cfscript>
            local.arrLinks=arraynew(1);
            if(site_x_option_group_value CONTAINS "</"){
                local.arrR=this.zVerifyHTMLLinks(site_x_option_group_value, curSiteId);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, site_option_name&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/admin/site-options/editGroup?site_option_group_id="&site_option_group_id&"&site_x_option_group_set_id="&site_x_option_group_set_id&"&site_x_option_group_set_parent_id="&site_x_option_group_set_parent_id);
            }else if(left(site_x_option_group_value, 5) EQ "http:" or left(site_x_option_group_value, 6) EQ "https:"){
                local.t1=application.zcore.functions.zForceAbsoluteURL(application.zcore.functions.zvar('domain',curSiteId), site_x_option_group_value);
				if(structkeyexists(request.tempUniqueLinkStruct99, local.t1) EQ false){
					request.tempUniqueLinkStruct99[local.t1]=true;
					if(this.zIsLinkHashAlreadyChecked(local.t1) EQ false){
						if(request.zos.istestserver EQ false or local.t1 CONTAINS "."&request.zos.testDomain){
							local.r1=application.zcore.functions.zVerifyLink(urldecode(replace(replace(local.t1, "&amp;","&","all"),'/../','/','all')),'', 10);
							if(local.r1 EQ false){
								this.zStoreLinkHash(local.t1, 0);
								request.tempUniqueLinkStruct99[local.t1]=false;
								arrayappend(local.arrLinks, site_option_name&chr(9)&local.t1&chr(9)&"/z/admin/site-options/editGroup?site_option_group_id="&site_option_group_id&"&site_x_option_group_set_id="&site_x_option_group_set_id&"&site_x_option_group_set_parent_id="&site_x_option_group_set_parent_id);
							}else{
								this.zStoreLinkHash(local.t1, 1);
							}
						}
					}
				}else{
					if(request.tempUniqueLinkStruct99[local.t1] EQ false){
						arrayappend(local.arrLinks, site_option_name&chr(9)&local.t1&chr(9)&"/z/admin/site-options/editGroup?site_option_group_id="&site_option_group_id&"&site_x_option_group_set_id="&site_x_option_group_set_id&"&site_x_option_group_set_parent_id="&site_x_option_group_set_parent_id);
					}
				}
			}
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="site_x_option_group";
				local.ts.tableid=site_x_option_group_id;
				if(arraylen(local.arrLinks) EQ 0){local.ts.status=1;}else{local.ts.status=0;}
				local.ts.site_id=curSiteId;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>


<cffunction name="zVerifySiteLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
		WHERE site_id IN (#db.trustedSQL(request.siteIdListTemp99)#) and 
		site_deleted = #db.param(0)#
		ORDER BY site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
        	<cfset application.siteReportCurrentPosition="zVerifySiteLinks:"&(local.lastOffset+currentrow-1)>
	        <cfset application.siteReportCurrentSiteId=site_id>
            <cfscript>
            local.arrLinks=arraynew(1);
			local.r9=application.zcore.functions.zDownloadLink(site_domain&"/", 20);
			if(local.r9.success){
                local.arrR=this.zVerifyHTMLLinks(local.r9.cfhttp.FileContent, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Home Page Links"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"-");
            }else{
				application.zcore.functions.zerror("Failed to download: "&site_domain&"/");
            }
			local.r9=application.zcore.functions.zDownloadLink(site_domain&"/z/misc/inquiry/index", 20);
			if(local.r9.success){
                local.arrR=this.zVerifyHTMLLinks(local.r9.cfhttp.FileContent, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Sub Page Links"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"-");
            }else{
				application.zcore.functions.zerror("Failed to download: "&site_domain&"/z/misc/inquiry/index");	
			}
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="site";
				local.ts.tableid=site_id;
				if(arraylen(local.arrLinks) EQ 0){local.ts.status=1;}else{local.ts.status=0;}
				local.ts.site_id=site_id;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>


<cffunction name="zVerifyInternalRentalLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
	
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
		WHERE site_id IN (#db.param(request.siteIdListTemp99)#) and 
		rental_deleted = #db.param(0)# 
		ORDER BY site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        
        <cfset application.siteReportCurrentPosition="zVerifyInternalRentalLinks:"&local.lastOffset>
        <!--- <cfset application.siteReportCurrentOut=""> --->
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
	        <cfset application.siteReportCurrentSiteId=site_id>
            <cfscript>
            local.arrLinks=arraynew(1);
            if(rental_description NEQ ""){
                local.arrR=this.zVerifyHTMLLinks(rental_description, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Summary Text"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/rental/admin/rates/editRental?rental_id="&rental_id);
            }
            if(rental_text NEQ ""){
                local.arrR=this.zVerifyHTMLLinks(rental_text, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Full Text"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/rental/admin/rates/editRental?rental_id="&rental_id);
            }
            if(rental_amenities_text NEQ ""){
                local.arrR=this.zVerifyHTMLLinks(rental_amenities_text, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Amenities Text"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/rental/admin/rates/editRental?rental_id="&rental_id);
            }
            if(rental_rate_text NEQ ""){
                local.arrR=this.zVerifyHTMLLinks(rental_rate_text, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Rate Description"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/rental/admin/rates/editRental?rental_id="&rental_id);
            }
			
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="rental";
				local.ts.tableid=rental_id;
				if(arraylen(local.arrLinks) EQ 0){
					local.ts.status=1;
				}else{
					local.ts.status=0;
				}
				local.ts.site_id=site_id;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>


<cffunction name="zVerifyInternalRentalCategoryLinks" localmode="modern" output="yes" access="private" returntype="any">
	<cfscript>
    local=structnew();
	var db=request.zos.queryObject;
    local.curDate1=dateformat(now(),'yyyy-mm-dd')&' 00:00:00';
	local.lastOffset=0;
	
    </cfscript>
    <cfloop condition="#true#">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category 
		WHERE site_id IN (#db.trustedSQL(request.siteIdListTemp99)#) and 
		rental_category_deleted = #db.param(0)# 
		ORDER BY site_id ASC
        limit #db.param(local.lastOffset)#, #db.param(request.tempPerLoop99)#
        </cfsavecontent><cfscript>local.qC=db.execute("qC");</cfscript>
        
        <cfset application.siteReportCurrentPosition="zVerifyInternalRentalCategoryLinks:"&local.lastOffset>
        <!--- <cfset application.siteReportCurrentOut=""> --->
        <cfif local.qC.recordcount EQ 0><cfreturn></cfif>
        <cfscript>request.tempUniqueLinkStruct99=structnew();</cfscript>
        <cfloop query="local.qC">
	        <cfset application.siteReportCurrentSiteId=site_id>
            <cfscript>
            local.arrLinks=arraynew(1);
            if(rental_category_text NEQ ""){
                local.arrR=this.zVerifyHTMLLinks(rental_category_text, site_id);
                if(arraylen(local.arrR) NEQ 0) arrayappend(local.arrLinks, "Full Text"&chr(9)&arraytolist(local.arrR,chr(9))&chr(9)&"/z/rental/admin/rental-category/edit?rental_category_id="&rental_category_id);
            }
			
			if(arraylen(local.arrLinks) NEQ 0){
				local.ts=structnew();
				local.ts.links=arraytolist(local.arrLinks, chr(10));
				local.ts.table="rental_category";
				local.ts.tableid=rental_category_id;
				if(arraylen(local.arrLinks) EQ 0){
					local.ts.status=1;
				}else{
					local.ts.status=0;
				}
				local.ts.site_id=site_id;
				zStoreLinkStatus(local.ts);
			}
            </cfscript>
            <cfif structkeyexists(application,'cancelSiteReport')><cfscript>structdelete(application,'siteReportRunning');structdelete(application,'cancelSiteReport');application.zcore.functions.zabort();</cfscript></cfif>
        </cfloop>
        <cfscript>
		local.lastOffset+=request.tempPerLoop99;
		</cfscript>
    </cfloop>
</cffunction>

<cffunction name="zIsLinkHashAlreadyChecked" localmode="modern" output="yes" access="private" returntype="any">
	<cfargument name="link" type="any" required="yes">
    <cfscript>
	
	var db=request.zos.queryObject;
	
	local.p=find("/", arguments.link, 10);
	if(local.p EQ 0){
		arguments.link&="/";
		local.p=len(arguments.link);
		//application.zcore.functions.zabort();
	}
	local.link2=left(arguments.link, local.p-1);
	if(structkeyexists(domainUniqueStruct, local.link2) EQ false){
		//writeoutput('not local link:'&arguments.link&'<br />');
		return true;
	}
	local.hashLink=hash(arguments.link);
	</cfscript>
    <cfsavecontent variable="db.sql">
    SELECT link_verify_link_id FROM 
	#request.zos.queryObject.table("link_verify_link", request.zos.zcoreDatasource)# link_verify_link 
	WHERE link_verify_link_url=#db.param(local.hashLink)# and 
	link_verify_link_deleted = #db.param(0)# and
	((link_verify_link_status = #db.param(1)# and 
	link_verify_link_datetime>#db.param(variables.oneWeekAgoMysql)# ) or 
	(link_verify_link_status = #db.param(0)# and 
	link_verify_link_datetime>#db.param(variables.oneTimeAgoMysql)# ))
	</cfsavecontent><cfscript>local.qR=db.execute("qR");</cfscript>
    <cfif local.qR.recordcount EQ 0>
    	<cfreturn false>
    <cfelse>
    	<cfreturn true>
    </cfif>
</cffunction>

<cffunction name="zStoreLinkHash" localmode="modern" output="no" returntype="any" roles="member">
	<cfargument name="link" type="any" required="yes">
	<cfargument name="status" type="any" required="yes">
    <cfscript>
	
	var db=request.zos.queryObject;
	local.hashLink=hash(arguments.link);
	</cfscript>
    <cfsavecontent variable="db.sql">
    INSERT INTO #request.zos.queryObject.table("link_verify_link", request.zos.zcoreDatasource)#  
	SET link_verify_link_url=#db.param(local.hashLink)#, 
	link_verify_link_status=#db.param(arguments.status)#, 
	link_verify_link_datetime=#db.param(request.zos.mysqlnow)#, 
	link_verify_link_updated_datetime=#db.param(request.zos.mysqlnow)#
    ON DUPLICATE KEY UPDATE link_verify_link_status=#db.param(arguments.status)#, 
	link_verify_link_datetime=#db.param(request.zos.mysqlnow)# , 
	link_verify_link_updated_datetime=#db.param(request.zos.mysqlnow)#
    </cfsavecontent><cfscript>local.qR=db.execute("qR");</cfscript>
</cffunction>


<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qR=0;
	var searchStruct=0;
	var qDD=0;
	var arrR2=0;
	var oneTimeAgo=0;
	var i2=0;
	var qSites=0;
	var qd=0;
	var start=0;
	var qRCount=0;
	var arrR=0;
	var i=0;
	var searchNav=0;
	var db=0;
	var oneWeekAgo=0;
	application.zcore.functions.zSetPageHelpId("2.6");

	application.zcore.adminSecurityFilter.requireFeatureAccess("Problem Link Report");	
	db=request.zos.queryObject;
	form.action=application.zcore.functions.zso(form,'action',false,'list');
	if(request.zos.isDeveloper EQ false or structkeyexists(form, 'testnondev')){
		form.action="list";
	}
	
	oneWeekAgo=dateadd("d",-7, now());
	variables.oneWeekAgoMysql=dateformat(oneWeekAgo,"yyyy-mm-dd")&" "&timeformat(oneWeekAgo, "HH:mm:ss");
	oneTimeAgo=dateadd("h",-10, now());
	variables.oneTimeAgoMysql=dateformat(oneTimeAgo,"yyyy-mm-dd")&" "&timeformat(oneTimeAgo, "HH:mm:ss");
	</cfscript>
	
	<cfif form.action EQ "deleteLinkVerifyCache">
		<cfsavecontent variable="db.sql">
		truncate table `link_verify_link`
		</cfsavecontent><cfscript>qR=db.execute("qR");
		application.zcore.status.setStatus(request.zsid, "Link verify cache deleted");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#");
		</cfscript>
	</cfif>
	
	<cfif form.action EQ "cancelReport">
		<cfscript>
		application.cancelSiteReport=true;
		application.zcore.status.setStatus(request.zsid, "Cancelling the current site report in progress.");
		application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#");
		</cfscript>
	</cfif>
	<cfif form.action EQ "runReport">
		<cfsetting requesttimeout=79200> <!--- 22 hour timeout --->
		<cfscript>
		if(structkeyexists(application, 'siteReportRunning')){
			if(request.zos.zreset EQ "app" or request.zos.zreset EQ "all"){
				application.cancelSiteReport=true;
				if(structkeyexists(form, 'force')){
					structdelete(application, 'siteReportRunning');
				}
				application.zcore.status.setStatus(request.zsid, "Cancelling the current site report in progress.");
				application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#");
			}else{
				application.zcore.status.setStatus(request.zsid, "The site report is already running.  You must let it complete.");
				application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#");
			}
		}else{
			structdelete(application,'siteReportCancel');
		}
		</cfscript>
		<cfsavecontent variable="db.sql">
		SELECT group_concat(site.site_id SEPARATOR #db.param(",")#) idlist, 
		group_concat(site.site_domain SEPARATOR #db.param(",")#) didlist, 
		group_concat(site.site_securedomain SEPARATOR #db.param(",")#) d2idlist 
		FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site, 
		#request.zos.queryObject.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
		WHERE app_x_site.site_id = site.site_id and 
		app_x_site.app_id =#db.param('12')# and 
		site.site_active=#db.param('1')# and 
		site.site_id <>#db.param('1')# and 
		site_deleted = #db.param(0)# and 
		app_x_site_deleted = #db.param(0)# 
		<cfif structkeyexists(form, 'siteOnly')> and site.site_id = #db.param(request.zos.globals.id)# 
		<cfelse>
		<cfif structkeyexists(application,'siteReportCurrentSiteId')> and site.site_id >=#db.param(application.siteReportCurrentSiteId)# </cfif> 
		
		</cfif>
		ORDER BY site.site_id ASC
		</cfsavecontent><cfscript>qSites=db.execute("qSites");
		
		db.sql="delete from #db.table('link_verify_status', request.zos.zcoreDatasource)# WHERE 
		link_verify_status_deleted = #db.param(0)# and ";
		if(structkeyexists(form, 'siteOnly')){
			db.sql&=" site_id = "&db.param(request.zos.globals.id);
		}else{
			db.sql&=" site_id <> "&db.param(-1);
		}
		db.execute("qDelete");
		</cfscript>
		<cftry>
			<cfscript>
			request.siteIdListTemp99=qSites.idlist;
			if(request.siteIdListTemp99 NEQ ""){
				arr2=listtoarray(qsites.didlist&","&qsites.d2idlist,",");
				domainUniqueStruct=structnew();
				for(i=1;i LTE arraylen(Arr2);i++){
					if(arr2[i] NEQ ""){
						domainUniqueStruct[arr2[i]]=true;	
					}
				}
				request.siteIdListTemp99=qSites.idlist;
				request.tempPerLoop99=50;
				application.siteReportCurrentPosition="Report Beginning";
				application.siteReportRunning=true;
				
				this.zVerifyInternalContentsLinks();
				
				this.zVerifyInternalBlogArticleLinks();
				
				this.zVerifyInternalBlogCategoryLinks();
				
				this.zVerifyInternalBlogTagLinks();
				this.zVerifyInternalMenuButtonLinks();
				
				this.zVerifyInternalMenuButtonLinkLinks();
				this.zVerifyInternalSiteOptionLinks();
				this.zVerifyInternalSiteOptionGroupLinks();
				this.zVerifyInternalRentalLinks();
				this.zVerifyInternalRentalCategoryLinks();
				this.zVerifySiteLinks();
			}
			</cfscript>
			<cfcatch type="any">
				<cfscript>
				structdelete(application,'siteReportCurrentSiteId');
				structdelete(application,'siteReportCurrentPosition');
				structdelete(application,'siteReportRunning');
				structdelete(application,'siteReportCancel');
				</cfscript>
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfscript>
		structdelete(application,'siteReportCurrentSiteId');
		structdelete(application,'siteReportCurrentPosition');
		structdelete(application,'siteReportRunning');
		structdelete(application,'siteReportCancel');
		</cfscript>
		Report Complete.<cfscript>application.zcore.functions.zabort();</cfscript>
	</cfif>
	<!--- also check home page and /z/misc/site-map/index for dead links because hardcoded links can and do fail too! --->
	
	<cfsavecontent variable="db.sql">
	SELECT group_concat(site.site_id SEPARATOR #db.param(",")#) idlist FROM 
	#request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site, 
	#request.zos.queryObject.table("app_x_site", request.zos.zcoreDatasource)# app_x_site 
	WHERE app_x_site.site_id = site.site_id and 
	app_x_site.app_id =#db.param('12')# and 
	site.site_active=#db.param('1')#  and 
	site.site_id <>#db.param('1')# and 
	site_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)#
	ORDER BY site.site_id ASC
	</cfsavecontent><cfscript>qSites=db.execute("qSites");
	request.siteIdListTemp99=qSites.idlist;
	</cfscript>
	<cfif request.zos.isDeveloper>
		<cfsavecontent variable="db.sql">
		DELETE FROM #request.zos.queryObject.table("link_verify_status", request.zos.zcoreDatasource)#  
		WHERE site_id NOT IN (#db.trustedSQL(request.siteIdListTemp99)#) and 
		link_verify_status_deleted = #db.param(0)#
		</cfsavecontent><cfscript>qd=db.execute("qd");</cfscript>
	</cfif>
	
	<cfsavecontent variable="db.sql">
	SELECT count(*) count FROM #request.zos.queryObject.table("link_verify_status", request.zos.zcoreDatasource)# link_verify_status 
	WHERE link_verify_status_status = #db.param(0)# and 
	link_verify_status_deleted = #db.param(0)# and
	site_id IN (#db.trustedSQL(request.siteIdListTemp99)#)
	<cfif request.zos.isDeveloper EQ false or structkeyexists(form, 'testnondev')>
	and site_id = #db.param(request.zos.globals.id)# 
	<cfelse>
	and site_id <> #db.param('-1')#
	</cfif>
	</cfsavecontent><cfscript>qRCount=db.execute("qRCount");
	// required 
	searchStruct = StructNew(); 
	// optional 
	searchStruct.showString = "Articles "; 
	// allows custom url formatting 
	//searchStruct.parseURLVariables = true; 
	searchStruct.indexName = 'zIndex'; 
	if(structkeyexists(form, 'testnondev')){
		searchStruct.url = request.cgi_script_name&"?testnodev=1";  
	}else{
		searchStruct.url = request.cgi_script_name;  
	}
	searchStruct.buttons = 5; 
	// set from query string or default value 
	searchStruct.perpage = 30;	
	searchStruct.count=qRCount.count;
	searchStruct.index = application.zcore.functions.zso(form, "zIndex",true,1); 
	start = searchStruct.perpage * searchStruct.index - 30;
	if(qRCount.count LTE 30){
		searchNav="";
	}else{
		searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #request.zos.queryObject.table("link_verify_status", request.zos.zcoreDatasource)# link_verify_status 
	WHERE link_verify_status_status = #db.param(0)# and 
	link_verify_status_deleted = #db.param(0)#
	<cfif request.zos.isDeveloper EQ false or structkeyexists(form, 'testnondev')>
	and site_id = #db.param(request.zos.globals.id)# 
	<cfelse>
	and site_id <> #db.param('-1')#
	</cfif>
	LIMIT #db.param(start)#, #db.param(searchStruct.perpage)#
	</cfsavecontent><cfscript>qR=db.execute("qR");</cfscript>
	
	<cfsavecontent variable="db.sql">
	SELECT max(link_verify_status_datetime) md FROM 
	#request.zos.queryObject.table("link_verify_status", request.zos.zcoreDatasource)# link_verify_status 
	WHERE link_verify_status_status = #db.param(0)# and 
	link_verify_status_deleted = #db.param(0)# 
	<cfif request.zos.isDeveloper EQ false or structkeyexists(form, 'testnondev')>
	and site_id = #db.param(request.zos.globals.id)# 
	<cfelse>
	and site_id <> #db.param('-1')#
	</cfif>
	</cfsavecontent><cfscript>qDD=db.execute("qDD");</cfscript>
	<h2>Problem Link Report (all 40x/50x HTTP errors)</h2> 
	<cfif qDD.recordcount NEQ 0 and isnull(qdd.md) EQ false and qdd.md NEQ "" and isdate(qDD.md)>
	<p>Last run: #dateformat(qDD.md,'m/d/yy')&' '&timeformat(qdd.md,'h:mm tt')#</p>
	<!--- <cfelse>
	<p>Report has not run yet.</p> --->
	</cfif>
	<p>Please view the urls and determine if they need to be fixed or removed from the content.  If you think a URL should be working, please contact the developer.</p>
	<cfscript>
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<cfif request.zos.isDeveloper and structkeyexists(form, 'testnondev') EQ false>
		<p><a href="#request.cgi_script_name#?action=list&testnondev=1">View Non-Dev Report</a> | <a href="#request.cgi_script_name#?action=deleteLinkVerifyCache" title="The link verify cache keeps track of whether links were valid or not the last time they were crawled.">Delete Link Verify Cache</a> | 
		<cfif structkeyexists(application, 'siteReportRunning')>Reporting Running (Current Status: #application.siteReportCurrentPosition#) | <a href="#request.cgi_script_name#?action=cancelReport">Cancel Report</a>
		<cfif request.zos.isDeveloper> | <a href="#request.cgi_script_name#?action=runReport&zreset=app&force=1">Force Cancel Report</a> </cfif>
		<cfelse> <a href="#request.cgi_script_name#?action=runReport" target="_blank">Run Global Report</a> | <a href="#request.cgi_script_name#?action=runReport&siteOnly=1" target="_blank">Run Site Report</a></cfif>
		</p>
		<!--- <cfif isDefined('application.siteReportCurrentOut')><p>#application.siteReportCurrentOut#</p></cfif> --->
		<cfif isDefined('application.siteReportCurrentSiteId')><p>Current site id: #application.siteReportCurrentSiteId#</p></cfif>
	</cfif>
	
	<cfif qR.recordcount EQ 0>
	<p>No errors were found after the last report was run.</p>
	<cfelse>
	#searchNav#
	  <table style="border-spacing:0px; padding:5px;width:100%;" class="table-list">
	<tr><th>Field Name</th>
	<th>Problem URL</th>
	<th>Admin</th>
	</tr>
	<cfloop query="qR">
		<cfscript>
		arrR=listtoarray(qR.link_verify_status_links,chr(10),false);
		</cfscript>
		<cfloop from="1" to="#arraylen(arrR)#" index="i">
			<cfscript>
			arrR2=listtoarray(arrR[i], chr(9));
			</cfscript>
			<tr>
			<td style="vertical-align:top;">#arrR2[1]#</td>
			<td style="vertical-align:top;">
			<div style="width:700px;overflow:auto;"><cfloop from="2" to="#arraylen(arrR2)-1#" index="i2">
			<a href="#htmleditformat(arrR2[i2])#" target="_blank">#removechars(arrR2[i2], 1, find("/",arrR2[i2],10)-1)#</a><br />
			</cfloop>
			</div>
			</td>
			<td style="vertical-align:top;"><cfif arrR2[arraylen(arrR2)] NEQ "-"><a href="#application.zcore.functions.zvar("domain",qR.site_id)##htmleditformat(arrR2[arraylen(arrR2)])#" target="_blank">Edit</a></cfif></td>
			</tr>
		</cfloop>
	</cfloop> 
	</table>
	#searchNav#
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>