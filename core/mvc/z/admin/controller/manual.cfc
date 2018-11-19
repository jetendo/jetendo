<cfcomponent output="yes">
<cfoutput>
<cffunction name="init" access="public" localmode="modern" output="yes">
	<cfscript>
	
	var s=0;
	ts={parentIdStruct:{}, idStruct:{}};
	showAll=application.zcore.functions.zso(form, 'showAllJetendoDocumentation', false, false);
	if(showAll EQ false){
		if(not application.zcore.user.checkGroupAccess("user")){
			structdelete(request.zsession, 'zManualStruct');
			ts = StructNew();
			ts.secureLogin=true;
			ts.usernameLabel = "E-Mail Address";
			ts.loginMessage = "Please login";
			ts.template = "zcorerootmapping.templates.blank";
			ts.user_group_name = "user";
			rs=application.zcore.user.checkLogin(ts);
		}
		if(left(request.cgi_script_name, 16) EQ "/z/admin/manual/"){
			application.zcore.template.setTemplate("zcorerootmapping.templates.administrator",true,true);
		}
		request.zos.inMemberArea=true;
		application.zcore.skin.disableMinCat();
		application.zcore.functions.zDisableContentTransition();
	} 
	application.zcore.skin.includeCSS("/z/javascript/prettify/src/sons-of-oblivion.css");
	application.zcore.skin.includeCSS("/z/stylesheets/zdoc.css"); 
	application.zcore.skin.includeJS("/z/javascript/jquery/response.0.6.0.min.js");
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery.rwdImages.min.js");
	application.zcore.skin.includeJS("/z/javascript/iscroll-lite.js");
	application.zcore.skin.includeJS("/z/javascript/prettify/src/prettify.js");
	application.zcore.skin.includeJS("/z/javascript/zDocumentation.js");

	if(request.zos.zreset EQ ""){
		if(application.zcore.user.checkGroupAccess("user") and structkeyexists(request.zsession, 'zManualStruct')){
			request.zos.siteManagerManual=request.zsession.zManualStruct;
			return;
		}else if(showAll and structkeyexists(application.zcore, 'manualStruct')){
			request.zos.siteManagerManual=application.zcore.manualStruct;
			return;
		}
	}
	</cfscript>
	<!--- This component will store the structure of all document files and their heirarchy by using meaningful whitespace to organize the docs
	each project should have it's own navigation structure
format is title(tab)url


zdoc css style documentation
.zdoc-container
.zdoc-sidebar
	section navigation ul/li for jump links within page

.zdoc-main-column	
	child page navigation box:
	.zdoc-contents-box with ul/li links
	
 li
.zdoc-main-column ul, .zdoc-main-column ol
.zdoc-sidebar a:link, .zdoc-sidebar a:visited
.zdoc-sidebar a:hover
.zdoc-main-column
.zdoc-section-box
.zdoc-section-box ul
.zdoc-contents-box
.zdoc-important
.zdoc-important h3
.zdoc-tip
.zdoc-tip h3
.zdoc-caution
.zdoc-caution h3
.zdoc-warning
.zdoc-warning h3
.zdoc-container pre
.zdoc-container .prettyprint
.zdoc-container a:link, .zdoc-container a:visited
.zdoc-codetext

.zdoc-search-box
.zdoc-container strong
.zdoc-buttontext
.zdoc-menutext
.zdoc-rightarrowbox 
	position: relative;
	margin-right:2px;
	border:none;
	padding: 3px;
	padding-bottom: 1px;
	padding-right:12px;
	background-image:url(/z/images/doc/rightarrow.jpg);
	background-position:top right;
	background-repeat:no-repeat;
}
.zdoc-console
		 --->
         
    <!--- make this personalized to each user based on request.zsession.user.limitManagerFeatureStruct --->
	<cfscript>
	arrS=getManualArray(showAll);
 
	arrParent=arraynew(1);
	for(i=1;i LTE arraylen(arrS);i++){
		ns=arrS[i];
		spaceCount=refind("[0-9]", trim(ns.id));
		if(spaceCount-1){ 
			ns.parentId=arrParent[spaceCount-1];
		}else{
			ns.parentId="";
		}
		if(not structkeyexists(ns, 'target')){
			ns.target="_self";
		}
		ns.id=replace(ns.id, "_", "", "all");
		ts.idStruct[ns.id]=ns;
		arrParent[spaceCount]=ns.id;
		if(not structkeyexists(ts.parentIdStruct, ns.parentId)){
			ts.parentIdStruct[ns.parentId]=[];
		}
		arrayappend(ts.parentIdStruct[ns.parentId], ns.id);
	}
	if(application.zcore.user.checkGroupAccess("user")){
		request.zsession.zManualStruct=ts;
	}else{
		application.zcore.manualStruct=ts;
	}
	request.zos.siteManagerManual=ts;
	
	</cfscript>
</cffunction>

<cffunction name="getManualArray" access="public" localmode="modern">
	<cfargument name="showAll" type="boolean" required="yes">
	<cfscript>
	showAll=arguments.showAll;

	arrS=[];
	arrayAppend(arrS, { id:"0", url:"/index.html", title:"Documentation"});
	arrayAppend(arrS, { id:"_1", url:"/site-manager-dashboard.html", title:"Site Manager Dashboard"});
	arrayAppend(arrS, { id:"__1.1", url:"/documentation-template.html", title:"Documentation Template"});
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Content Manager")){
		arrayAppend(arrS, { id:"_2", url:"/content-manager.html", title:"Content Manager"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Pages")){
		arrayAppend(arrS, { id:"__2.1", url:"/manage-pages.html", title:"Pages"});
	}
	if(showAll or application.zcore.user.checkServerAccess()){
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Pages")){
			arrayAppend(arrS, { id:"___2.1.1", url:"/import-pages.html", title:"Import Pages"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Pages")){
			arrayAppend(arrS, { id:"___2.1.2", url:"/manage-page-permissions.html", title:"Page Permissions"});
		}
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Pages")){
		arrayAppend(arrS, { id:"__2.2", url:"/add-edit-page.html", title:"Add/Edit Page"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Menus")){
		arrayAppend(arrS, { id:"__2.3", url:"/manage-menus.html", title:"Menus"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Menus")){
		arrayAppend(arrS, { id:"___2.3.1", url:"/add-edit-menu.html", title:"Add/Edit Menu"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Menus")){
		arrayAppend(arrS, { id:"___2.3.2", url:"/manage-menu-buttons.html", title:"Menu Buttons"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Menus")){
		arrayAppend(arrS, { id:"___2.3.3", url:"/add-edit-menu-buttons.html", title:"Add/Edit Menu Button"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Menus")){
		arrayAppend(arrS, { id:"___2.3.4", url:"/manage-menu-button-links.html", title:"Menu Button Links"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Menus")){
		arrayAppend(arrS, { id:"___2.3.5", url:"/add-edit-menu-button-links.html", title:"Add/Edit Menu Button Links"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Menus")){
		arrayAppend(arrS, { id:"___2.3.6", url:"/copy-menu.html", title:"Copy Menu"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Menus")){
		arrayAppend(arrS, { id:"___2.3.7", url:"/view-menu.html", title:"View Menu"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Slideshows")){
		arrayAppend(arrS, { id:"__2.4", url:"/manage-slideshows.html", title:"Slideshows"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Slideshows")){
		arrayAppend(arrS, { id:"___2.4.1", url:"/add-edit-slideshow.html", title:"Add/Edit Slideshow"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Slideshows")){
		arrayAppend(arrS, { id:"___2.4.2", url:"/manage-slideshow-tabs.html", title:"Slideshow Tabs"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Slideshows")){
		arrayAppend(arrS, { id:"___2.4.3", url:"/add-edit-slideshow-tab.html", title:"Add/Edit Slideshow Tabs"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Slideshows")){
		arrayAppend(arrS, { id:"___2.4.4", url:"/manage-slideshow-photos.html", title:"Slideshow Photos"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Slideshows")){
		arrayAppend(arrS, { id:"___2.4.5", url:"/add-edit-slideshow-photo.html", title:"Add/Edit Slideshow Photo"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Slideshows")){
		arrayAppend(arrS, { id:"___2.4.6", url:"/copy-slideshow.html", title:"Copy Slideshow"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Files & Images")){
		arrayAppend(arrS, { id:"__2.5", url:"/files-and-images.html", title:"Files And Images"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Files & Images")){
		arrayAppend(arrS, { id:"___2.5.1", url:"/add-file.html", title:"Add File"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Files & Images")){
		arrayAppend(arrS, { id:"___2.5.2", url:"/add-edit-image.html", title:"Add/Edit Image"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Files & Images")){
		arrayAppend(arrS, { id:"___2.5.3", url:"/add-folder.html", title:"Add Folder"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Files & Images")){
		arrayAppend(arrS, { id:"___2.5.4", url:"/delete-folder.html", title:"Delete Folder"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Files & Images")){
		arrayAppend(arrS, { id:"___2.5.5", url:"/view-file.html", title:"View File"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Files & Images")){
		arrayAppend(arrS, { id:"___2.5.6", url:"/delete-file.html", title:"Delete File"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Problem Link Report")){
		arrayAppend(arrS, { id:"__2.6", url:"/problem-link-report.html", title:"Problem Link Report"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Site Options")){
		arrayAppend(arrS, { id:"__2.7", url:"/site-options.html", title:"Site Options"});
	}
	if(showAll or application.zcore.user.checkServerAccess()){
		arrayAppend(arrS, { id:"___2.7.1", url:"/manage-site-option-groups.html", title:"Site Option Groups"});
		arrayAppend(arrS, { id:"____2.7.1.1", url:"/manage-site-option-group-import.html", title:"Import Site Option Group Data"});
		arrayAppend(arrS, { id:"____2.7.1.2", url:"/copy-site-option-group.html", title:"Copy Site Option Group"});
		arrayAppend(arrS, { id:"____2.7.1.3", url:"/manage-site-option-group-display-code.html", title:"Display Code"});
		arrayAppend(arrS, { id:"___2.7.2", url:"/add-edit-site-option-group.html", title:"Add/Edit Site Option Group"});
		arrayAppend(arrS, { id:"___2.7.3", url:"/manage-site-options.html", title:"Site Options"});
		arrayAppend(arrS, { id:"___2.7.4", url:"/add-edit-site-options.html", title:"Add/Edit Site Options"});
		arrayAppend(arrS, { id:"___2.7.5", url:"/sync-site-option-structure.html", title:"Sync Site Option Structure"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Video Library")){
		arrayAppend(arrS, { id:"__2.8", url:"/video-library.html", title:"Video Library"});
	} 
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Settings")){
		arrayAppend(arrS, { id:"__2.9", url:"/settings.html", title:"Settings"});
	} 
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Short Links")){
		arrayAppend(arrS, { id:"__2.10", url:"/short-links.html", title:"Short Links"});
	} 
	/*if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Themes")){
		arrayAppend(arrS, { id:"__2.10", url:"/themes.html", title:"Themes"});
	}*/
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Articles")){
		arrayAppend(arrS, { id:"_3", url:"/blog.html", title:"Blog"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Articles")){
		arrayAppend(arrS, { id:"__3.1", url:"/manage-blog-articles.html", title:"Blog Articles"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Articles")){
		arrayAppend(arrS, { id:"__3.2", url:"/add-edit-blog-article.html", title:"Add/Edit Blog Article"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Articles")){
		arrayAppend(arrS, { id:"__3.3", url:"/manage-blog-comments.html", title:"Comments"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Articles")){
		arrayAppend(arrS, { id:"___3.3.1", url:"/manage-blog-comments.html", title:"Review Comment"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Categories")){
		arrayAppend(arrS, { id:"__3.4", url:"/manage-blog-categories.html", title:"Blog Categories"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Categories")){
		arrayAppend(arrS, { id:"__3.5", url:"/add-edit-blog-category.html", title:"Add/Edit Blog Category"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Tags")){
		arrayAppend(arrS, { id:"__3.6", url:"/manage-blog-tags.html", title:"Blog Tags"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Blog Tags")){
		arrayAppend(arrS, { id:"__3.7", url:"/add-edit-blog-tag.html", title:"Add/Edit Blog Tag"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Leads")){
		arrayAppend(arrS, { id:"_4", url:"/leads.html", title:"Leads"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Leads")){
		arrayAppend(arrS, { id:"__4.1", url:"/manage-leads.html", title:"Leads"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Leads")){
		arrayAppend(arrS, { id:"___4.1.1", url:"/view-lead.html", title:"View Lead"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Leads")){
		arrayAppend(arrS, { id:"___4.1.2", url:"/assign-lead.html", title:"Assign Lead"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Leads")){
		arrayAppend(arrS, { id:"__4.2", url:"/add-edit-lead.html", title:"Add/Edit Lead"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Lead Types")){
		arrayAppend(arrS, { id:"__4.3", url:"/manage-lead-types.html", title:"Lead Types"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Lead Types")){
		arrayAppend(arrS, { id:"__4.4", url:"/add-edit-lead-type.html", title:"Add/Edit Lead Type"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Lead Templates")){
		arrayAppend(arrS, { id:"__4.5", url:"/manage-lead-template-emails.html", title:"Lead Template Emails"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Lead Templates")){
		arrayAppend(arrS, { id:"__4.6", url:"/add-edit-lead-template-email.html", title:"Add/Edit Lead Template Email"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Lead Export")){
		arrayAppend(arrS, { id:"__4.7", url:"/export-all-leads-as-csv.html", title:"Export All Leads As CSV"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Lead Source Report")){
		arrayAppend(arrS, { id:"__4.8", url:"/lead-source-report.html", title:"Lead Source Report"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Mailing List Export")){
		arrayAppend(arrS, { id:"__4.9", url:"/mailing-list-export.html", title:"Mailing List Export"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Lead Reports")){
		arrayAppend(arrS, { id:"__4.10", url:"/search-engine-keyword-lead-report.html", title:"Search Engine Keyword Lead Report"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Lead Autoresponders")){
		arrayAppend(arrS, { id:"__4.11", url:"/lead-autoresponders.html", title:"Lead Autoresponders"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Users")){
		arrayAppend(arrS, { id:"_5", url:"/users.html", title:"Users"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Users")){
		arrayAppend(arrS, { id:"__5.1", url:"/manager-users.html", title:"Users"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Users")){
		arrayAppend(arrS, { id:"__5.2", url:"/add-edit-user.html", title:"Add/Edit User"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Users")){
		arrayAppend(arrS, { id:"__5.3", url:"/import-users.html", title:"Import Users"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Offices")){
		arrayAppend(arrS, { id:"__5.4", url:"/manage-offices.html", title:"Offices"});
	}
	if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Offices")){
		arrayAppend(arrS, { id:"__5.5", url:"/add-edit-office.html", title:"Add/Edit Office"});
	}
	if(showAll or application.zcore.app.siteHasApp("listing")){
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Listings")){
			arrayAppend(arrS, { id:"_6", url:"/listings.html", title:"Listings"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Listings")){
			arrayAppend(arrS, { id:"__6.1", url:"/manage-listings.html", title:"Listings"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Listings")){
			arrayAppend(arrS, { id:"__6.2", url:"/add-new-listing.html", title:"Add/Edit Listing"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Listing Research Tool")){
			arrayAppend(arrS, { id:"__6.3", url:"/listing-research-tool.html", title:"Listing Research Tool"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Listing Search Filter")){
			arrayAppend(arrS, { id:"__6.4", url:"/listing-search-filter.html", title:"Listing Search Filter"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Saved Listing Searches")){
			arrayAppend(arrS, { id:"__6.5", url:"/managed-saved-searches.html", title:"Saved Listing Searches"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Real Estate Widgets and Links")){
			arrayAppend(arrS, { id:"__6.6", url:"/widget-for-other-sites.html", title:"Real Estate Widgets and Links"});
		}
	}
	if(application.zcore.app.siteHasApp("rental")){
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Rentals")){
			arrayAppend(arrS, { id:"_7", url:"/rentals.html", title:"Rentals"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Rentals")){
			arrayAppend(arrS, { id:"__7.1", url:"/manage-rentals.html", title:"Rentals"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Rentals")){
			arrayAppend(arrS, { id:"__7.2", url:"/add-edit-rental.html", title:"Add/Edit Rental"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Rental Calendars")){
			arrayAppend(arrS, { id:"__7.3", url:"/edit-rental-calendar.html", title:"Edit Rental Calendar"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Rental Categories")){
			arrayAppend(arrS, { id:"__7.4", url:"/manage-rental-categories.html", title:"Rental Categories"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Rental Categories")){
			arrayAppend(arrS, { id:"__7.5", url:"/add-edit-rental-category.html", title:"Add/Edit Rental Category"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Rental Amenities")){
			arrayAppend(arrS, { id:"__7.6", url:"/manage-amenities.html", title:"Amenities"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Rental Amenities")){
			arrayAppend(arrS, { id:"__7.7", url:"/add-edit-amenities.html", title:"Add/Edit Amenities"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Rental Calendars")){
			arrayAppend(arrS, { id:"__7.8", url:"/view-all-calendars.html", title:"View All Calendars"});
		}
	}
	if(showAll or application.zcore.user.checkServerAccess()){
		arrayAppend(arrS, { id:"_8", url:"/server-manager.html", title:"Server Manager"});
		arrayAppend(arrS, { id:"__8.1", url:"/server-manager-sites.html", title:"Sites"});
		arrayAppend(arrS, { id:"___8.1.1", url:"/server-manager-site-dashboard.html", title:"Site Dashboard"});
		arrayAppend(arrS, { id:"____8.1.1.1", url:"/server-manager-site-globals.html", title:"Globals"});
		arrayAppend(arrS, { id:"____8.1.1.2", url:"/server-manager-site-domain-redirects.html", title:"Domain Redirects"});
		arrayAppend(arrS, { id:"_____8.1.1.2.1", url:"/server-manager-site-add-edit-domain-redirect.html", title:"Add/Edit Domain Redirect"});
		arrayAppend(arrS, { id:"____8.1.1.3", url:"/server-manager-site-deploy.html", title:"Deploy"});
		arrayAppend(arrS, { id:"_____8.1.1.3.1", url:"/server-manager-edit-site-deployment-configuration.html", title:"Edit Site Deployment Configuration"});
		arrayAppend(arrS, { id:"____8.1.1.4", url:"/server-manager-site-dreamweaver-ste.html", title:"Dreamweaver STE"});
		arrayAppend(arrS, { id:"_____8.1.1.4.1", url:"/server-manager-site-generate-all-dreamweaver-ste-files.html", title:"Generate All Dreamweaver STE Files"});
		arrayAppend(arrS, { id:"____8.1.1.5", url:"/server-manager-site-backup.html", title:"Backup"});
		arrayAppend(arrS, { id:"____8.1.1.6", url:"/server-manager-site-users.html", title:"Users"});
		arrayAppend(arrS, { id:"_____8.1.1.6.1", url:"/server-manager-site-view-users-in-user-group.html", title:"View Users in User Group"});
		arrayAppend(arrS, { id:"______8.1.1.6.1.1", url:"/server-manager-site-add-edit-user.html", title:"Add/Edit User"});
		arrayAppend(arrS, { id:"______8.1.1.6.1.2", url:"/server-manager-site-activate-deactivate-user.html", title:"Activate/Deactivate User"});
		arrayAppend(arrS, { id:"_____8.1.1.6.2", url:"/server-manager-site-permissions.html", title:"Permissions"});
		arrayAppend(arrS, { id:"_____8.1.1.6.3", url:"/server-manager-site-add-edit-user-group.html", title:"Add/Edit User Group"});
		arrayAppend(arrS, { id:"____8.1.1.7", url:"/server-manager-site-applications.html", title:"Applications"});
		arrayAppend(arrS, { id:"____8.1.1.8", url:"/server-manager-site-rewrite-rules.html", title:"Rewrite Rules"});
		arrayAppend(arrS, { id:"____8.1.1.9", url:"/server-manager-site-robots-txt.html", title:"Robots.txt"});
		arrayAppend(arrS, { id:"_____8.1.1.9.1", url:"/server-manager-site-robots-txt.html", title:"Robots.txt"});
		arrayAppend(arrS, { id:"______8.1.1.9.1.1", url:"/server-manager-edit-global-robots-txt.html", title:"Edit Server Manager Global Robots.txt"});
		arrayAppend(arrS, { id:"____8.1.1.10", url:"/server-manager-site-hardcoded-urls.html", title:"Hardcoded URLs"});
		arrayAppend(arrS, { id:"___8.1.2", url:"/server-manager-import-site.html", title:"Import Site"});
		arrayAppend(arrS, { id:"___8.1.3", url:"/server-manager-import-global-database.html", title:"Import Global Database"});
		arrayAppend(arrS, { id:"__8.2", url:"/server-manager-applications.html", title:"Applications"});
		arrayAppend(arrS, { id:"___8.2.1", url:"/server-manager-add-edit-application.html", title:"Add/Edit Application"});
		arrayAppend(arrS, { id:"___8.2.2", url:"/server-manager-manage-application-instances.html", title:"Application Instances"});
		arrayAppend(arrS, { id:"____8.2.2.1", url:"/server-manager-add-edit-application-instance.html", title:"Add/Edit Application Instance"});
		arrayAppend(arrS, { id:"____8.2.2.2", url:"/server-manager-edit-application-options.html", title:"Edit Application Options"});
		// add a options documentation page for each app
		arrayAppend(arrS, { id:"__8.3", url:"/server-manager-logs.html", title:"Logs"});
		arrayAppend(arrS, { id:"___8.3.1", url:"/server-manager-recent-request-history.html", title:"Recent Request History"});
		arrayAppend(arrS, { id:"___8.3.2", url:"/server-manager-abusive-ips.html", title:"Abusive IPs"});
		arrayAppend(arrS, { id:"___8.3.3", url:"/server-manager-view-log-entry.html", title:"View Log Entry"});
		arrayAppend(arrS, { id:"__8.4", url:"/server-manager-deploy.html", title:"Deploy"});
		arrayAppend(arrS, { id:"___8.4.1", url:"/server-manager-manage-deploy-servers.html", title:"Deploy Servers"});
		arrayAppend(arrS, { id:"___8.4.2", url:"/server-manager-add-edit-deploy-server.html", title:"Add/Edit Deploy Server"});
		arrayAppend(arrS, { id:"___8.4.3", url:"/server-manager-edit-deployment-configuration-for-all-sites.html", title:"Edit Deployment Configuration For All Sites"});
		arrayAppend(arrS, { id:"___8.4.4", url:"/server-manager-deploy-all-sites.html", title:"Deploy All Sites"});
		arrayAppend(arrS, { id:"___8.4.5", url:"/server-manager-deploy-core.html", title:"Deploy Core"});
		arrayAppend(arrS, { id:"___8.4.6", url:"/server-manager-deploy-sourceless-archive.html", title:"Deploy Sourceless Archive"});
	}
	if(showAll or application.zcore.user.checkServerAccess()){
		arrayAppend(arrS, { id:"_9", url:"/jetendeo-cms-developer-documentation.html", title:"Jetendo CMS Developer Documentation"});
		arrayAppend(arrS, { id:"__9.1", url:"/intro.html", title:"Introduction"});
		arrayAppend(arrS, { id:"___9.1.1", url:"/documentation-template.html", title:"Jetendo CMS Documentation Template"});
		arrayAppend(arrS, { id:"__9.2", url:"/standalone-projects.html", title:"Standalone Projects"});
		arrayAppend(arrS, { id:"___9.2.1", url:"/db-dot-cfc.html", title:"db-dot-cfc Documentation"});
		arrayAppend(arrS, { id:"___9.2.2", url:"/cssSpriteMap-dot-cfc.html", title:"cssSpriteMap-dot-cfc Documentation"});
		arrayAppend(arrS, { id:"___9.2.3", url:"/status-dot-cfc.html", title:"status-dot-cfc Documentation"});
		arrayAppend(arrS, { id:"___9.2.4", url:"/jquery-parallax-slider.html", title:"jQuery Parallax Slider Documentation"});
		arrayAppend(arrS, { id:"____9.2.4.1", url:"/jquery-parallax-slider-examples.html", title:"jQuery Parallax Slider Examples", target:"_blank"});
		arrayAppend(arrS, { id:"__9.3", url:"/integration.html", title:"Integration"});
		arrayAppend(arrS, { id:"___9.3.1", url:"/wordpress-integration.html", title:"Wordpress Integration with SSI and Proxy"});
		arrayAppend(arrS, { id:"__9.4", url:"/security.html", title:"Security"});
	}

	if(showAll or application.zcore.app.siteHasApp("event")){
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Events")){
			arrayAppend(arrS, { id:"_10", url:"/events.html", title:"Events"});
		}
		if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Events")){
			arrayAppend(arrS, { id:"__10.1", url:"/manage-events.html", title:"Events"});
			arrayAppend(arrS, { id:"__10.2", url:"/add-edit-event.html", title:"Add/Edit Event"});
			arrayAppend(arrS, { id:"__10.3", url:"/manage-event-calendars.html", title:"Event Calendars"});
			arrayAppend(arrS, { id:"__10.4", url:"/add-edit-event.html", title:"Add/Edit Event Calendar"});
			arrayAppend(arrS, { id:"__10.5", url:"/manage-event-categories.html", title:"Event Categories"});
			arrayAppend(arrS, { id:"__10.6", url:"/add-edit-event.html", title:"Add/Edit Event Category"});
			arrayAppend(arrS, { id:"__10.7", url:"/manage-event-widgets.html", title:"Event Widgets"});
		} 
	}

	if(showAll or application.zcore.app.siteHasApp("job")){
		// TODO: Job documentation.
		if ( request.zos.istestserver ) {
			if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Jobs")){
				arrayAppend(arrS, { id:"_11", url:"/jobs.html", title:"Jobs"});
			}
			if(showAll or application.zcore.adminSecurityFilter.checkFeatureAccess("Jobs")){
				arrayAppend(arrS, { id:"__11.1", url:"/manage-jobs.html", title:"Jobs"});
				arrayAppend(arrS, { id:"__11.2", url:"/add-edit-job.html", title:"Add/Edit Job"});
				arrayAppend(arrS, { id:"__11.3", url:"/manage-job-categories.html", title:"Job Categories"});
				arrayAppend(arrS, { id:"__11.4", url:"/add-edit-job.html", title:"Add/Edit Job Category"});
			} 
		}
	}

	return arrS;
	</cfscript>
</cffunction>


<cffunction name="getSiteMap" access="public" localmode="modern">
	<cfargument name="arrURL" type="array" required="yes">
	<cfscript>
	init();
    arrKey=structkeyarray(request.zos.siteManagerManual);
    arraysort(arrKey, "text");
    for(n2=1;n2 LTE arraylen(arrKey);n2++){
        n=arrKey[n2];
        arrKey2=structkeyarray(request.zos.siteManagerManual.idStruct);
        arraysort(arrKey2, "text");
        for(i2=1;i2 LTE arraylen(arrKey2);i2++){
            i=arrKey2[i2];
            cs=request.zos.siteManagerManual.idStruct[i];
            if(cs.id EQ 0){
                curTitle=cs.title;
            }else{
                curTitle=cs.id&". "&cs.title;
            }
			indentCount=(len(i) - len(replace(i,".","","all")))*4;
			
            t2=StructNew();
            t2.groupName="Documentation";
            t2.url=request.zos.currentHostName&'/z/admin/manual/view/'&cs.id&cs.url;
            t2.title=curTitle;
			if(indentCount){
				t2.indent=ljustify("", indentCount);
			}
            arrayappend(arguments.arrUrl,t2);
        }
    }
	return arguments.arrURL;
	</cfscript>
</cffunction>

<cffunction name="getDocLink" access="public" localmode="modern" returntype="struct">
    <cfargument name="id" type="string" required="yes">
    <cfscript>
	if(not structkeyexists(request.zos.siteManagerManual.idStruct, arguments.id)){
		return { success:false, errorMessage:"This documentation page doesn't exist yet." };
	}else{
		cs=request.zos.siteManagerManual.idStruct[arguments.id];
		return { success:true, link:'/z/admin/manual/view/'&cs.id&cs.url };
	}
	</cfscript>
</cffunction>
	
<cffunction name="reindexDocumentation" access="public" localmode="modern">
	<cfscript>
	db=request.zos.queryObject;
	app_id=9;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	arrS=getManualArray(true);

	//tableId=1;
	for(i=1;i LTE arrayLen(arrS);i++){
		s=arrS[i];
		searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
		ds=searchCom.getSearchIndexStruct(); 
		html=getDocPageHTML(s.id);
		ds.app_id=app_id; 
		id=replace(s.id, '_', '', 'all');
		ds.search_table_id="global-documentation-"&id;
		ds.site_id=0;
		ds.search_content_datetime=startDate;
		ds.search_url='/z/admin/manual/view/'&id&s.url;
		ds.search_title=s.title;
		ds.search_summary=s.title&" "&html;
		ds.search_fulltext=s.title&" "&html;
		searchCom.saveSearchIndex(ds); 
		//tableId++;
	}
	db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# where 
	search_updated_datetime < #db.param(startDate)# and 
	app_id =#db.param(app_id)# and 
	site_id = #db.param(0)# and 
	search_deleted=#db.param(0)#";
	qDelete=db.execute("qDelete"); 
	</cfscript>
	
</cffunction>


<cffunction name="getDocPageHTML" access="public" localmode="modern">
    <cfargument name="id" type="string" required="yes">
	<cfscript>

	html="";
	id=replace(arguments.id, '_', '', 'all');
	p=find(".", id);
	if(p EQ 0){
		dir=id;
	}else{
		dir=left(id, p-1);
	}
	tempIdFS=replace(id,".","-","all");
	dirFS=replace(dir,".","-","all");
	request.examplePath=request.zos.installPath&"core/manual-files/"&dirFS&"/"&tempIdFS&"/examples/";  
	if(fileexists(request.zos.installPath&"core/manual-files/"&dirFS&"/"&tempIdFS&"/"&tempIdFS&".cfc")){ 
		temppath="zcorerootmapping.manual-files."&dirFS&"."&tempIdFS&"."&tempIdFS;
		savecontent variable="html"{
			tempCom=application.zcore.functions.zcreateobject("component", tempPath);
			request.manual=this;
			tempCom.index();
		}
	} 
	return html;
	</cfscript>
</cffunction>
	
<cffunction name="findDoc" access="private" localmode="modern">
    <cfargument name="id" type="string" required="yes">
	<cfargument name="docLink" type="string" required="yes"><cfscript>
	if(arguments.id EQ ""){
		arguments.id=0;
	}
	if(not structkeyexists(request.zos.siteManagerManual.idStruct, arguments.id)){
		request.zos.functions.z404(arguments.id&" is not a valid id in request.zos.siteManagerManual.");
	}
	rs={ docStruct:request.zos.siteManagerManual.idStruct[arguments.id] };
	p=find(".", arguments.id);
	id=replace(arguments.id, '_', '', 'all');
	if(p EQ 0){
		dir=id;
	}else{
		dir=left(id, p-1);
	}
	tempIdFS=replace(id,".","-","all");
	dirFS=replace(dir,".","-","all");
	request.examplePath=request.zos.installPath&"core/manual-files/"&dirFS&"/"&tempIdFS&"/examples/";
	//echo(request.zos.installPath&"core/manual-files/"&dirFS&"/"&tempIdFS&"/"&tempIdFS&".cfc");
	if(fileexists(request.zos.installPath&"core/manual-files/"&dirFS&"/"&tempIdFS&"/"&tempIdFS&".cfc")){
		temppath="zcorerootmapping.manual-files."&dirFS&"."&tempIdFS&"."&tempIdFS;
		savecontent variable="rs.html"{
			tempCom=application.zcore.functions.zcreateobject("component", tempPath);
			request.manual=this;
			tempCom.index();
		}
	}else{
		rs.html="<p>There is nothing written for this page yet.</p>"
	}
	if(structkeyexists(request.zos.siteManagerManual.parentIdStruct, arguments.id)){
		rs.arrChild = request.zos.siteManagerManual.parentIdStruct[arguments.id];
	}else{
		rs.arrChild=[];
	}
	rs.arrSectionLinks=[];
	rs.arrParent=[];
	cs=rs.docStruct;
	for(i=1;i LTE 100;i++){
		if(cs.parentID EQ ""){
			break;
		}else if(i EQ 100){
			throw("There is an infinite loop in the parent ID configuration for the manual.","custom");	
		}
		arrayappend(rs.arrParent, cs.parentID);
		cs=request.zos.siteManagerManual.idStruct[cs.parentID];
	}
	if(compare("/"&arguments.docLink, rs.docStruct.url) NEQ 0){
		request.zos.functions.z301redirect('/z/admin/manual/view/'&arguments.id&rs.docStruct.url);	
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getParentLinks" access="private" output="yes" localmode="modern">
	<cfargument name="manualStruct" type="struct" required="yes">
    <cfscript>
	if(arguments.manualStruct.docStruct.id EQ 0){
		return;
	}
	for(i=arraylen(arguments.manualStruct.arrParent);i GTE 1;i--){
		cs=request.zos.siteManagerManual.idStruct[arguments.manualStruct.arrParent[i]];
		if(cs.id EQ 0){
			curTitle=cs.title;
		}else{
			curTitle=cs.id&". "&cs.title;
		}
		writeoutput('<a href="/z/admin/manual/view/'&cs.id&cs.url&'">'&curTitle&'</a> / ');
	}
	</cfscript>
</cffunction>

<cffunction name="getContentsBox" access="private" output="yes" localmode="modern">
	<cfargument name="manualStruct" type="struct" required="yes">
	<cfscript>
	
	childCount=arraylen(arguments.manualStruct.arrChild);
	</cfscript>
    <cfif childCount>
        <div class="zdoc-contents-box">
        <h3>Table of Contents</h3>
        <ul>
        <cfscript>
        for(i=1;i LTE childCount;i++){
            cs=request.zos.siteManagerManual.idStruct[arguments.manualStruct.arrChild[i]];
            writeoutput('<li><a href="/z/admin/manual/view/'&cs.id&cs.url&'" target="'&cs.target&'">'&cs.id&". "&cs.title&'</a> ');
			arrayappend(arguments.manualStruct.arrSectionLinks, '<li><a href="/z/admin/manual/view/'&cs.id&cs.url&'" target="'&cs.target&'">'&cs.id&". "&cs.title&'</a></li>');
            if(structkeyexists(request.zos.siteManagerManual.parentIdStruct, cs.id)){
                arrChild = request.zos.siteManagerManual.parentIdStruct[cs.id];
                writeoutput('&nbsp;<a href="##" class="zdoc-toggle-ul">+-</a> <ul>');
                for(n=1;n LTE arraylen(arrChild);n++){
                    cs2=request.zos.siteManagerManual.idStruct[arrChild[n]];
                    writeoutput('<li><a href="/z/admin/manual/view/'&cs2.id&cs2.url&'" target="'&cs2.target&'">'&cs2.id&". "&cs2.title&'</a></li>');
                }
                writeoutput('</ul>');
            }
            writeoutput('</li>');
        }
        </cfscript>
        </ul>
        </div>
    </cfif>
</cffunction>

<cffunction name="codeExample" output="yes" access="public" localmode="modern">
	<cfargument name="filePath" type="string" required="yes">
    <cfscript>
	var ext=request.zos.functions.zgetfileext(arguments.filePath);
	var absPath=request.examplePath&arguments.filePath;
	var t=0;
	if(not fileexists(absPath)){
		throw("The file, "&absPath&", doesn't exist.", "custom");
	}
	t=request.zos.functions.zreadfile(absPath);
	writeoutput('<div style="width:100%; float:left; margin-top:-25px;"><div style="float:right; width:120px; background-color:##FFF; font-size:11px; text-align:right;"><a href="##" data-codeexample="'&htmleditformat(t)&'" onclick="copyToClipboard(this.getAttribute(''data-codeexample'')); return false;">Copy '&ucase(ext)&' Example</a></div>');
	if(ext EQ 'cfm' or ext EQ 'cfc'){
		writeoutput('<pre class="prettyprint lang-html linenums prettyprinted"><code>');
	}else if(ext EQ 'php'){
		writeoutput('<pre class="prettyprint lang-php linenums prettyprinted"><code>');
	}else if(ext EQ 'sql'){
		writeoutput('<pre class="prettyprint lang-sql linenums prettyprinted"><code>');
	}else if(ext EQ 'js'){
		writeoutput('<pre class="prettyprint lang-js linenums prettyprinted"><code>');
	}else if(ext EQ 'css'){
		writeoutput('<pre class="prettyprint lang-css linenums prettyprinted"><code>');
	}else if(ext EQ 'html' or ext EQ "txt"){
		writeoutput('<pre class="prettyprint lang-html linenums prettyprinted"><code>');
    }
	writeoutput(htmleditformat(t)&'</code></pre></div>');
	</cfscript>
</cffunction>

<cffunction name="getSectionBox" access="private" output="yes" localmode="modern">
	<cfargument name="manualStruct" type="struct" required="yes">
    <cfscript>
	
	</cfscript>
    <div class="zdoc-section-box">
        <h3>Full Documentation</h3>
        
        <!--- <h3>Search Our Site</h3>
        <div class="zdoc-search-box">
            <form action="##" method="get" onsubmit="zContentTransition.gotoURL('/search/index?q='+escape(document.getElementById('googlesearchtext832').value)); return false;"><input type="text" name="googlesearchtext" id="googlesearchtext832" value="" style="width:145px;padding:3px; font-size:1.0em; margin-right:5px;" /> <input type="submit" name="submit3822" value="Go" style="padding:3px; padding-bottom:1px; font-size:1.0em; border:1px solid ##136;cursor:pointer;  background-color:##369; border-radius:5px; color:##FFF;" /> 
            </form>
        </div> --->
        <cfscript>
		arrSectionLinks=[];
		sectionCount=arraylen(arguments.manualStruct.arrSectionLinks);
		if(sectionCount){
			arrayappend(arrSectionLinks, '<ul>');
			for(i=1;i LTE sectionCount;i++){
				arrayappend(arrSectionLinks, arguments.manualStruct.arrSectionLinks[i]);
			}
			arrayappend(arrSectionLinks, '</ul>');
		}
		writeoutput('<h3>Section Navigation</h3>');
		if(structkeyexists(request.zos.siteManagerManual.parentIdStruct, arguments.manualStruct.docStruct.parentId)){
			arrChild = request.zos.siteManagerManual.parentIdStruct[arguments.manualStruct.docStruct.parentId];
			if(arguments.manualStruct.docStruct.parentId NEQ ""){
				cs=request.zos.siteManagerManual.idStruct[arguments.manualStruct.docStruct.parentId];
				if(cs.id EQ 0){
					writeoutput('<a href="/z/admin/manual/view/'&cs.id&cs.url&'" target="'&cs.target&'">'&cs.title&'</a>');
				}else{
					writeoutput('<a href="/z/admin/manual/view/'&cs.id&cs.url&'" target="'&cs.target&'">'&cs.id&". "&cs.title&'</a>');
				}
			}
			writeoutput('<ul>');
			for(n=1;n LTE arraylen(arrChild);n++){
				cs2=request.zos.siteManagerManual.idStruct[arrChild[n]];
				if(arguments.manualStruct.docStruct.id EQ cs2.id){
					writeoutput('<li>');
					if(cs2.id EQ 0){
						writeoutput(cs2.title);
					}else{
						writeoutput(cs2.id&". "&cs2.title);
					}
					writeoutput(arraytolist(arrSectionLinks, ""));
					writeoutput('</li>');
				}else{
					writeoutput('<li><a href="/z/admin/manual/view/'&cs2.id&cs2.url&'" target="'&cs2.target&'">'&cs2.id&". "&cs2.title&'</a></li>');
				}
			}
			writeoutput('</ul>');
		}else{
			writeoutput(arraytolist(arrSectionLinks, ""));
		}
		</cfscript>
    </div>
</cffunction>

 <cffunction name="renderTable" access="public" output="yes" localmode="modern">
 	<cfargument name="arrColumn" type="array" required="yes">
 	<cfargument name="arrRow" type="array" required="yes">
    <cfscript>
	
	rowCount=arraylen(arguments.arrRow);
	columnCount=arraylen(arguments.arrColumn);
	writeoutput('<table class="zdoc-table">');
	writeoutput('<tr>');
	for(n=1;n LTE columnCount;n++){
		writeoutput('<th>'&arguments.arrColumn[n]&'</th>');
	}
	writeoutput('</tr>');
	for(i=1;i LTE rowCount;i++){
		if(i MOD 2 EQ 0){
			writeoutput('<tr class="zdoc-table-row-even">');
		}else{
			writeoutput('<tr class="zdoc-table-row-odd">');
		}
		for(n=1;n LTE columnCount;n++){
			writeoutput('<td>'&arguments.arrRow[i][arguments.arrColumn[n]]&'</td>');
		}
		writeoutput('</tr>');
	}
	writeoutput('</table>');
	</cfscript>
 </cffunction>

<cffunction name="view" access="remote" output="yes" localmode="modern">
    <cfargument name="id" type="string" required="no" default="">
    <cfargument name="docLink" type="string" required="no" default=""><cfscript>
	var manualStruct=0;
	var curTitle=0;
	var curTitle2=0;
	var theParent=0;
	init();
	manualStruct=this.findDoc(arguments.id, arguments.docLink);
	curTitle=manualStruct.docStruct.id&". "&manualStruct.docStruct.title;
	curTitle2=manualStruct.docStruct.id&". "&manualStruct.docStruct.title;
	if(manualStruct.docStruct.id EQ 0){
		curTitle=manualStruct.docStruct.title;
		curTitle2=manualStruct.docStruct.title;
	}
	request.zos.template.setTag("title", curTitle);
	request.zos.template.setTag("pagetitle", curTitle2);
	</cfscript>
    <cfif manualStruct.docStruct.target EQ "_blank">
        #manualStruct.html#
    <cfelse>
        <div class="zdoc-container ieWidthDivClass">
        <!--- <div class="zdoc-sidebar"> --->
        <!--- </div> --->
        <div class="zdoc-main-column ieWidthDivClass4">
		<h3>The documentation features were just added 2/8/2014, and we hope to fill them in over time.  
		For now, if you need help that isn't here, please contact the web developer for assistance.</h3>
            <cfsavecontent variable="theParent"><a href="/z/admin/help/index">Help</a> / #this.getParentLinks(manualStruct)#</cfsavecontent>
            <cfscript>request.zos.template.setTag("pagenav", theParent);</cfscript>
            
            #this.getContentsBox(manualStruct)#
            
            #manualStruct.html#
            <cfif structkeyexists(form, 'generateDocs')>
            <p>For the latest info, vist this page on the web: <a href="#request.zos.currentHostName##form[request.zos.urlRoutingParameter]#">#request.zos.currentHostName##form[request.zos.urlRoutingParameter]#</a></p>
            </cfif><!--- 
	        <cfscript>
	        if(request.zos.functions.zIsExternalCommentsEnabled()){
	            writeoutput('<div style="width:100%; float:left;border-top:1px dotted ##CCC; margin-top:10px; padding-top:10px;">'&request.zos.functions.zDisplayExternalComments(form[request.zos.urlRoutingParameter], curTitle, request.zos.globals.domain&form[request.zos.urlRoutingParameter])&'</div>');
	        }
	        </cfscript> --->
        </div>
        #this.getSectionBox(manualStruct)#
        </div>
	</cfif>
</cffunction>


    </cfoutput>
</cfcomponent>