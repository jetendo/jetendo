<cfcomponent>
<cfoutput>
<!--- 
ts=structnew();
ts.menu_name="Main Menu";
menuCom.init(ts);
 --->
<cffunction name="init" localmode="modern" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={};
	var db=request.zos.queryObject;
	ts.menu_name="";
	ts.site_id=request.zos.globals.id;
	ts.idPrefix="";
	structappend(arguments.ss,ts,false);
	variables.menuName=arguments.ss.menu_name;
	application.zcore.functions.zRequireJquery();
	if(structkeyexists(application.sitestruct[request.zos.globals.id],'menuIdCacheStruct') EQ false){
		application.sitestruct[request.zos.globals.id].menuIdCacheStruct=structnew();	
		application.sitestruct[request.zos.globals.id].menuNameCacheStruct=structnew();	
	}
	if(structkeyexists(application.sitestruct[request.zos.globals.id].menuNameCacheStruct, arguments.ss.idPrefix&variables.menuName) and structkeyexists(application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.ss.idPrefix&variables.menuName], 'qView')){
		variables.qView=application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.ss.idPrefix&variables.menuName].qView;
	}else{
		db.sql="SELECT * FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
		LEFT JOIN #db.table("menu_button", request.zos.zcoreDatasource)# menu_button ON 
		menu.menu_id = menu_button.menu_id and 
		menu_button_deleted=#db.param(0)# and 
		menu_button.site_id = menu.site_id 
		WHERE menu.menu_name=#db.param(arguments.ss.menu_name)#  AND 
		menu.site_id = #db.param(arguments.ss.site_id)# and 
		menu_deleted = #db.param(0)# 
		ORDER BY menu_button_sort";
		variables.qView=db.execute("qView"); 
		application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.ss.idPrefix&variables.menuName]={
			qView:variables.qView
		};
	}
	if(variables.qView.recordcount NEQ 0){
		savecontent variable="theMenuMeta"{
			if(variables.qView.menu_vertical EQ 1){
				echo('<script type="text/javascript">/* <![CDATA[ */
zMenu#variables.qView.menu_id#Vertical=true;/* ]]> */</script>');
			}
			if(structkeyexists(request, 'zMenuMetaIncluded') EQ false){
				request.zMenuMetaIncluded=true;
				echo('<!--[if lte IE 7]>
				<style>.zMenuBarDiv ul a {height: 1%;}</style>
				<![endif]-->
				<!--[if lte IE 6]>
				<style>.zMenuBarDiv li ul{width:1% !important; white-space:nowrap !important;}</style>
				<![endif]-->');
			}
		}
		application.zcore.template.appendTag("meta",trim(theMenuMeta));
	}
	</cfscript>
</cffunction>



<cffunction name="publishMenu" localmode="modern" output="no" returntype="any">
	<cfargument name="menu_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
    <cfscript>
	
	var qview2=0;
	var ts=structnew();
	var theCSS=0;
	var db=request.zos.queryObject;
	var qView=0;
	</cfscript>
<cfsavecontent variable="theCSS">
	<cfscript>
	db.sql="SELECT *, menu.site_id FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu.menu_id = #db.param(arguments.menu_id)# AND 
	menu_deleted = #db.param(0)# and 
	menu.site_id = #db.param(arguments.site_id)#";
	qView=db.execute("qView");
	</cfscript> 

<cfif qView.recordcount NEQ 0>
.zMenuClear {clear: both;height: 0px;line-height: 0.0px; font-size:0px;}

##zMenuDiv#qView.menu_id#, ##zMenuDiv#qView.menu_id# ul {
	padding: 0px;
	margin: 0px;
	list-style: none;
}
##zMenuDiv#qView.menu_id# a {
	display: block;
	text-decoration: none;
	padding: #qView.menu_padding_height#px <cfif qView.menu_enable_responsive EQ 1>0px<cfelse>#qView.menu_padding_width#px</cfif> 
	#qView.menu_padding_height#px <cfif qView.menu_enable_responsive EQ 1>0px<cfelse>#qView.menu_padding_width#px</cfif>;
	color: ###qview.menu_font_color#;
}
##zMenuDiv#qView.menu_id# a.trigger {
	border-left: 1px solid ###qview.menu_divider_color#;
	padding: #qView.menu_padding_height#px <cfif qView.menu_enable_responsive EQ 1>0px<cfelse>#qView.menu_padding_width#px</cfif> 
	#qView.menu_padding_height#px <cfif qView.menu_enable_responsive EQ 1>0px<cfelse>#qView.menu_padding_width#px</cfif>;
    <cfif qView.menu_bold EQ 1>font-weight:bold;</cfif>
    font-family: #qView.menu_font#;
    font-size:#qView.menu_button_font_size#px !important;
    background:none;
}
##zMenuDiv#qView.menu_id# a.imagetrigger {
	padding:0px;
} 
##zMenuDiv#qView.menu_id# li ul li  { 
	width:100%;
	<cfif qView.menu_popup_background_image NEQ "">
	background-image: url(/zupload/menu/#qView.menu_id#/#qView.menu_popup_background_image#);
    <cfelse>
    background:none;
    background-color: ###qView.menu_popup_background_color#;
    </cfif>
    opacity: #qView.menu_popup_opacity/100#; 
  filter: alpha(opacity = #qView.menu_popup_opacity#);
  
  border-bottom:1px solid ###qView.menu_popup_divider_color#;

    color:###qView.menu_popup_font_color# !important;
}
##zMenuDiv#qView.menu_id# li li{
	float: left;
	width:100%;
	clear:both;
}
##zMenuDiv#qView.menu_id# li{
	float: left;
}
##zMenuDiv#qView.menu_id# ul li a  {
	background:none;
	color: ###qView.menu_popup_font_color# !important;
	border-right: 0;
    font-size:#qView.menu_popup_font_size#px !important;
    font-family: #qView.menu_popup_font#;
    <cfif qView.menu_popup_bold EQ 1>font-weight:bold;</cfif>
	padding: #qView.menu_popup_padding_height#px #qView.menu_popup_padding_width#px #qView.menu_popup_padding_height#px #qView.menu_popup_padding_width#px;
}
##zMenuDiv#qView.menu_id# li ul {
	position: absolute;
	display: none;
	z-index:2000;
    opacity: #qView.menu_popup_opacity/100#;
  filter: alpha(opacity = #qView.menu_popup_opacity#);
	background-color: ###qView.menu_popup_background_color#;
	border-right: 1px solid ###qView.menu_popup_font_color#;
	border-bottom: 1px solid ###qView.menu_popup_font_color#;
}
##zMenuDiv#qView.menu_id# li {position: relative;}

/* hide from IE mac \*/
##zMenuDiv#qView.menu_id# li {position: static; width: auto;}
/* end hiding from IE5 mac */


##zMenuDiv#qView.menu_id# li:hover ul, ##zMenuDiv#qView.menu_id# li.zMenuHvr ul {
	display: block;
}
<!--- button links rollover --->
##zMenuDiv#qView.menu_id# li:hover a, ##zMenuDiv#qView.menu_id# a:focus,
##zMenuDiv#qView.menu_id# a:active, ##zMenuDiv#qView.menu_id# li.zMenuHvr a {
	color: ###qView.menu_font_over_color#;
	<cfif qView.menu_background_over_image NEQ ""> background-image:url(/zupload/menu/#qView.menu_id#/#qView.menu_background_over_image#); 
	background-position:top; </cfif>
    background-color: ###qView.menu_background_over_color#;
}
##zMenuDiv#qView.menu_id# li:hover ul a, ##zMenuDiv#qView.menu_id# li.zMenuHvr ul a {
	color: ###qView.menu_font_over_color#;
	background:none;
}
##zMenuDiv#qView.menu_id# ul a:hover {
	<cfif qView.menu_popup_background_over_image NEQ ""> 
		background-image:url(/zupload/menu/#qView.menu_id#/#qView.menu_popup_background_over_image#) !important; background-position:top; 
	<cfelse>
	    background:none;
		background-color: ###qView.menu_popup_background_over_color# !important;
    </cfif>
	color: ###qView.menu_popup_font_over_color# !important;

}
##zMenuDiv#qView.menu_id#{ float:left;
<cfif qView.menu_font_color NEQ "">color:###qView.menu_font_color#;<cfelse>color:##FFFFFF;</cfif>
background-color:###qView.menu_background_color#;
<cfif qView.menu_background_image NEQ "">background-image:url(/zupload/menu/#qview.menu_id#/#qview.menu_background_image#);
background-position:top; </cfif>
<cfif qView.menu_size_limit NEQ 0>width:#qView.menu_size_limit#px;</cfif> 
} 
##zMenuDiv#qView.menu_id# li li {font-size:#qView.menu_popup_font_size#px;} 
##zMenuDiv#qView.menu_id# li {font-size:#qView.menu_button_font_size#px;}
<cfif qView.menu_vertical EQ '1'>
##zMenuDiv#qView.menu_id# a.trigger {<cfif qView.menu_vertical EQ 1 and qView.menu_size_limit NEQ 0>width:#qView.menu_size_limit#px;</cfif> }
</cfif>
##zMenuDiv#qView.menu_id# a.trigger-selected {
	background-color:###qView.menu_selected_background_color# !important;
	<cfif qView.menu_selected_background_image NEQ ""> 
		background-image:url(/zupload/menu/#qView.menu_id#/#qView.menu_selected_background_image#) !important; background-position:top;
	</cfif> 
	color:###qView.menu_selected_font_color# !important;
}
.zMenuAppendTitle{ font-size:11px; }
<cfsavecontent variable="db.sql">
	SELECT * FROM (#db.table("menu", request.zos.zcoreDatasource)# menu, 
	#db.table("menu_button", request.zos.zcoreDatasource)# menu_button) 
	WHERE menu.menu_id = menu_button.menu_id and 
	menu.menu_id = #db.param(arguments.menu_id)# AND 
	menu.site_id = #db.param(arguments.site_id)# and 
	menu.site_id = menu_button.site_id and 
	menu_deleted = #db.param(0)# and 
	menu_button_deleted = #db.param(0)#
    ORDER BY menu_button_sort
</cfsavecontent><cfscript>qView2=db.execute("qView2");</cfscript> 
<cfloop query="qView2">
<cfif qView2.menu_button_url NEQ "">
##zMenu#qView2.menu_id#_#qView2.menu_button_id#, ##zMenu#qView2.menu_id#_#qView2.menu_button_id#:link, ##zMenu#qView2.menu_id#_#qView2.menu_button_id#:visited{ cursor:pointer; background-repeat:no-repeat;  background-image:url(/zupload/menu/#qView2.menu_id#/#qView2.menu_button_url#) !important;} 
##zMenu#qView2.menu_id#_#qView2.menu_button_id#:hover, ##zMenu#qView2.menu_id#_#qView2.menu_button_id#_preload{background-image:url(/zupload/menu/#qView2.menu_id#/#qView2.menu_button_over_url#) !important;}
##zMenu#qView2.menu_id#_#qView2.menu_button_id#{ padding:0px !important; }
##zMenu#qView2.menu_id#_#qView2.menu_button_id#Div{ width:#qView2.menu_button_width#px; height:#qView2.menu_button_height#px;clear:both; }
</cfif></cfloop>
</cfif>
</cfsavecontent>
<cfscript>
ts=structnew();
ts.uniquePhrase="zMenu#arguments.menu_id#";
ts.code=theCSS;
ts.site_id=arguments.site_id;
application.zcore.functions.zPublishCss(ts);
</cfscript>
	
</cffunction>

<cffunction name="getMenuLinkArray" localmode="modern" returntype="array" access="public">
	<cfargument name="idPrefix" type="string" required="yes">
	<cfscript>
	rs={
		affectedStruct:{}
	}
	if(structkeyexists(application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.idPrefix&variables.menuName], 'arrLink')){
		return application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.idPrefix&variables.menuName].arrLink;
	}
	db=request.zos.queryObject;
	arrLink=[];
	for(row in variables.qView){
		if(row.menu_button_text EQ ""){
			continue;
		}
		menuCharacterLength=max(1,row.menu_character_length);
		buttonStruct={
			id:"zMenu#row.menu_id#_#row.menu_button_id#",
			url:htmleditformat(row.menu_button_link),
			target:row.menu_button_target,
			text:row.menu_button_text,
			arrChildren:[]
		}
		blogSort="";
		contentSort="";
		if(row.menu_button_sorting EQ 0 or row.menu_button_sorting EQ ""){
			blogSort=" blog.blog_id asc ";
			contentSort=" menu_button_link_sort ";
		}else if(row.menu_button_sorting EQ 1){
			contentSort=" menu_button_link_text asc ";
			blogSort=" blog_title asc ";
		}else if(row.menu_button_sorting EQ 2){
			contentSort=" menu_button_link_id desc ";
			blogSort=" blog.blog_datetime desc ";
		}else if(row.menu_button_sorting EQ 3){
			contentSort=" menu_button_link_id asc ";
			blogSort=" blog_datetime asc ";
		}
		qB=false;
		db.sql="SELECT * FROM #db.table("menu_button_link", request.zos.zcoreDatasource)# menu_button_link 
		WHERE menu_button_id = #db.param(row.menu_button_id)# AND 
		site_id = #db.param(request.zos.globals.id)# and 
		menu_button_link_deleted = #db.param(0)#
		ORDER BY #contentSort#";
		qViewSubs=db.execute("qViewSubs");
		
		for(row2 in qViewSubs){
			subButtonStruct={
				url:row2.menu_button_link_url,
				text:htmleditformat(row2.menu_button_link_text),
				target:row2.menu_button_link_target,
				arrChildren:[]
			}
			arrayAppend(buttonStruct.arrChildren, subButtonStruct);
		}
		escapeEnabled=true;
		if(row.menu_button_type_id EQ 1){
			// content
			escapeEnabled=false;
			ts=structnew();
			if(row.menu_button_sorting EQ 0){
				// default
			}else if(row.menu_button_sorting EQ 1){
				ts.sortAlpha=true;
			}else if(row.menu_button_sorting EQ 2){
				ts.dateSortDesc=true;
			}else if(row.menu_button_sorting EQ 3){
				ts.dateSortAsc=true;
			}
			ts.showHidden=true;
			//ts.beforeCode="<li>";
			//ts.afterCode="</li>#chr(10)#";
			ts.delimiter="";
			ts.returnData=true;
			ts.linkTextLength=menuCharacterLength;
			ts.limit=row.menu_button_type_count;
			ts.forceLinkForCurrentPage=true;
			ts.content_parent_id=row.menu_button_type_tid;
			r1=application.zcore.app.getAppCFC("content").getSidebar(ts);
			for(i=1;i LTE arraylen(r1.arrLink);i++){
				subButtonStruct={
					url: r1.arrLink[i],
					target:"",
					text: r1.arrText[i],
					arrChildren:[]
				}
				arrayAppend(buttonStruct.arrChildren, subButtonStruct);
			}
			rs.affectedStruct["content"]=true;
		}else if(row.menu_button_type_id EQ 2){
			// recent blog 
			 db.sql="SELECT *
			 from #db.table("blog", request.zos.zcoreDatasource)# blog 
			WHERE blog.site_id = #db.param(request.zos.globals.id)# 
			and blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' 23:59:59')# and 
			blog_status <> #db.param(2)# and 
			blog_deleted = #db.param(0)#
			ORDER BY blog_datetime desc, #blogSort# 
			LIMIT #db.param(0)#,#db.param(row.menu_button_type_count)# ";
			qB=db.execute("qB");
			rs.affectedStruct["blogArticle"]=true;
		}else if(row.menu_button_type_id EQ 3){
			// blog category
			 db.sql="SELECT * from #db.table("blog", request.zos.zcoreDatasource)# blog, 
			 #db.table("blog_x_category", request.zos.zcoreDatasource)# blog_x_category 
			WHERE blog_x_category.site_id = blog.site_id and 
			blog_x_category.blog_id = blog.blog_id and 
			blog_x_category.blog_category_id = #db.param(row.menu_button_type_tid)# and 
			blog.site_id = #db.param(request.zos.globals.id)# 
			and blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' 23:59:59')# and 
			blog_status <> #db.param(2)# and 
			blog_deleted = #db.param(0)# and 
			blog_x_category_deleted = #db.param(0)# 
			ORDER BY #blogSort# 
			LIMIT #db.param(0)#, #db.param(row.menu_button_type_count)# ";
			qB=db.execute("qB");
			rs.affectedStruct["blogCategory"]=true;
		}else if(row.menu_button_type_id EQ 4){
			// blog tag 
			 db.sql="SELECT * from #db.table("blog", request.zos.zcoreDatasource)# blog, 
			 #db.table("blog_x_tag", request.zos.zcoreDatasource)# blog_x_tag 
			WHERE blog_x_tag.site_id = blog.site_id and 
			blog_x_tag.blog_id = blog.blog_id and 
			blog_x_tag.blog_tag_id = #db.param(row.menu_button_type_tid)# and 
			blog.site_id = #db.param(request.zos.globals.id)# 
			and blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' 23:59:59')# and 
			blog_status <> #db.param(2)# and 
			blog_deleted = #db.param(0)# and 
			blog_x_tag_deleted = #db.param(0)# 
			ORDER BY #blogSort# 
			LIMIT #db.param(0)#,#db.param(row.menu_button_type_count)# ";
			qB=db.execute("qB");
		}else if(row.menu_button_type_id EQ 5){
			// popular blog
			 db.sql="SELECT *
			 from #db.table("blog", request.zos.zcoreDatasource)# blog 
			WHERE blog.site_id = #db.param(request.zos.globals.id)# 
			and blog_datetime<=#db.param(dateformat(now(),'yyyy-mm-dd')&' 23:59:59')# and 
			blog_status <> #db.param(2)# and 
			blog_deleted = #db.param(0)# 
			ORDER BY blog_views DESC, #blogSort# 
			LIMIT #db.param(0)#,#db.param(row.menu_button_type_count)# ";
			qB=db.execute("qB");
			rs.affectedStruct["blogArticle"]=true;
		}
		if(isQuery(qB) and qB.recordcount NEQ 0){
			for(row2 in qB){
				subButtonStruct={
					target:row.menu_button_target,
					arrChildren:[]
				}
				if(row2.blog_unique_name NEQ ""){
					subButtonStruct.url=request.zos.currentHostName&row2.blog_unique_name;
				}else{
					subButtonStruct.url=request.zos.currentHostName&application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,row2.blog_id,"html",row2.blog_title,row2.blog_datetime);
				}
				if(len(row2.blog_title) GT menuCharacterLength){
					subButtonStruct.text=left(row2.blog_title,menuCharacterLength)&"...";
				}else{
					subButtonStruct.text=row2.blog_title;
				}
				if(escapeEnabled){
					subButtonStruct.text=htmleditformat(subButtonStruct.text);
				}
				arrayAppend(buttonStruct.arrChildren, subButtonStruct);
			}
		}
		arrayAppend(arrLink, buttonStruct);
	}
	variables.arrLink=arrLink;
	application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.idPrefix&variables.menuName].arrLink=variables.arrLink;
	application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.idPrefix&variables.menuName].affectedStruct=rs.affectedStruct;
	return arrLink;
	</cfscript>
</cffunction>
	


<cffunction name="getMobileMenuHTML" localmode="modern" returntype="string" output="no">
	<cfscript>
	if(structkeyexists(application.sitestruct[request.zos.globals.id].menuNameCacheStruct[variables.menuName], 'mobileHtmlOutput')){
		return application.sitestruct[request.zos.globals.id].menuNameCacheStruct[variables.menuName].mobileHtmlOutput;
	}
	arrLink=application.sitestruct[request.zos.globals.id].menuNameCacheStruct[variables.menuName].arrLink;
	savecontent variable="output"{
		linkCount=arrayLen(arrLink);
		if(linkCount){
			subOpen=false;
			echo(' <div id="zMobileMenuDiv#variables.qView.menu_id#" data-role="panel" class="zMobileMenuDiv jqm-nav-panel jqm-navmenu-panel" data-position="left" data-display="reveal" data-theme="d">');
			for(i=1;i LTE linkCount;i++){
				c=arrLink[i];
				subCount=arrayLen(c.arrChildren);
				if(subCount){
					if(not subOpen){
						echo('<div data-role="collapsible-set" data-theme="c" data-content-theme="c" data-inset="false" data-iconpos="right">');
						subOpen=true;
					}
					echo('<div data-role="collapsible"><h2>'&htmleditformat(c.text)&'</h2>
					<ul data-role="listview" data-theme="b" data-divider-theme="b">');// data-autodividers="true"
					for(n=1;n LTE subCount;n++){
						g=c.arrChildren[n];
						echo('<li><a href="#g.url#"');
						if(g.target EQ "_blank"){
							echo(' rel="external" target="_blank"');
						}
						echo('>#(g.text)#</a></li>');
					}
					echo('</ul></div>');
				}else{
					if(subOpen){
						echo('</div>');
						subOpen=false;
					}
					echo('<ul data-role="listview" data-inset="false" data-theme="c" data-divider-theme="c">
					<li data-icon="false"><a href="#c.url#"');
					if(c.target EQ "_blank"){
						echo(' rel="external" target="_blank"');
					}
					echo('>#(c.text)#</a></li>');
					echo('</ul>');
				}
			}
			if(subOpen){
				echo('</div>');
				subOpen=false;
			}
			echo('</div>');
		}
	}
	application.sitestruct[request.zos.globals.id].menuNameCacheStruct[variables.menuName].mobileHtmlOutput=output;
	return output;
	</cfscript> 
</cffunction>

<cffunction name="getMenuHTML" localmode="modern" returntype="string" output="no">
	<cfargument name="idPrefix" type="string" required="yes">
	<cfscript>
	if(structkeyexists(application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.idPrefix&variables.menuName], 'htmlOutput')){
		return application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.idPrefix&variables.menuName].htmlOutput;
	}
	arrLink=application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.idPrefix&variables.menuName].arrLink;
	savecontent variable="output"{
		linkCount=arrayLen(arrLink);
		if(linkCount){
			echo('<div class="zMenuWrapper');
			if(variables.qView.menu_enable_responsive EQ 1){
						echo(' zMenuEqualDiv');
			}
			echo('" data-button-margin="#variables.qView.menu_button_margin#">
			<ul id="#arguments.idPrefix#zMenuDiv#variables.qView.menu_id#" class="zMenuBarDiv');
			if(variables.qView.menu_enable_responsive EQ 1){
						echo(' zMenuEqualUL');
			}
			echo('">');
			for(i=1;i LTE linkCount;i++){
				c=arrLink[i];
				echo('<li id="#arguments.idPrefix##c.id#_mb" ');
				if(variables.qView.menu_enable_responsive EQ 1){
					echo('class="zMenuEqualLI"');
				}
				echo('>');
				echo('<a class="trigger');
				if(i EQ 1){
					echo(' firsttrigger');
				}else if(i EQ linkCount){
					echo(' lasttrigger');
				}
				echo(' ');
				if(variables.qView.menu_enable_responsive EQ 1){
					echo('zMenuEqualA');
				}
				echo('" href="#c.url#" ');
				if(c.target EQ "_blank"){
					echo('rel="external" target="_blank"');
				}
				echo('>#(c.text)#</a>');
				
				subCount=arrayLen(c.arrChildren);
				if(subCount){
					echo('<ul id="#arguments.idPrefix##c.id#_mb_menu">');
					for(n=1;n LTE subCount;n++){
						g=c.arrChildren[n];
						echo('<li><a href="#(g.url)#" ');
						if(g.target EQ "_blank"){
							echo(' rel="external" target="_blank"');
						}
						echo('>#(g.text)#</a></li>#chr(10)#');
					}
					echo('</ul>');
				}
				echo('</li>');
			}
			echo('</ul>');
			if(structkeyexists(request,'zMenuIncludeIndex') EQ false){
				request.zMenuIncludeIndex=1;
				echo('<div id="#arguments.idPrefix#zMenuAdminClearUniqueId" class="zMenuClear"></div>');
			}else{
				request.zMenuIncludeIndex++;
				echo('<div id="#arguments.idPrefix#zMenuAdminClearUniqueId#request.zMenuIncludeIndex#" class="zMenuClear"></div>');
			}
			echo('</div>');
		}
	}
	application.sitestruct[request.zos.globals.id].menuNameCacheStruct[arguments.idPrefix&variables.menuName].htmlOutput=application.zcore.functions.zRemoveHostName(output);
	return output;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>