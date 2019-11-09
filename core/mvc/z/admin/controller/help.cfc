<cfcomponent>
<cfoutput>
<cffunction name="init" access="private" localmode="modern">
	<cfscript>
	application.zcore.skin.includeCSS("/z/stylesheets/zdoc.css");
	</cfscript>
</cffunction>
<cffunction name="index" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	application.zcore.template.setTag("title", "Documentation");
	application.zcore.template.setTag("pagetitle", "Documentation");
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<div class="zhelp-manager-div">
		<p>Please choose one of the following resources to begin to learn more about managing the web site.</p>
		<ul>
			<li><a href="/z/admin/help/quickStart">Quick Start Guide</a></li>
			<li><a href="/z/admin/video-training/index">Video Training Documentation</a></li>
			<cfif request.zos.istestserver>
				<li><a href="/z/admin/manual/view/0/index.html">Full Documentation</a></li>
			</cfif>
			<li><a href="/z/admin/help/incontext">In-context Help Features</a></li>
		</ul>
		<cfif request.zos.istestserver>
			#searchForm()#
		</cfif>
	</div>
</cffunction>

<cffunction name="searchForm" access="private" localmode="modern">

	<h1>Documentation Search</h1>
	<form action="/z/admin/help/search" method="get">
	<p><input type="text" name="searchtext" value="#application.zcore.functions.zso(form, 'searchtext')#" style="width:70%;" /> <input type="submit" name="submit112" value="Search" /></p>
	</form>
</cffunction>
	

<cffunction name="search" access="remote" localmode="modern" roles="member">
	<cfscript>
	form.zindex=application.zcore.functions.zso(form, 'zindex', true, 1);
	form.searchtext=application.zcore.functions.zso(form, 'searchtext');
	db=request.zos.queryObject;
	perpage=10;
	//echo(application.zcore.app.siteHasApp("blog"));
	//writedump(application.siteStruct[request.zos.globals.id].adminFeatureMapStruct);

	db.sql="select * from #db.table("search", request.zos.zcoreDatasource)# WHERE 
	app_id=#db.param(9)# and 
	search_fulltext LIKE #db.param('%'&form.searchtext&'%')# and 
	site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	search_deleted=#db.param(0)#";
	if(structkeyexists(request.zsession, 'zManualStruct')){
		idlist="'global-documentation-"&structkeylist(request.zsession.zManualStruct.idstruct, "','global-documentation-")&"'"; 
		db.sql&=" and search_table_id IN (#db.trustedSQL(idlist)#) ";
	}
	db.sql&=" LIMIT #db.param((form.zindex-1)*perpage)#, #db.param(perpage)#";
	qSearch=db.execute("qSearch");

	db.sql="select count(search_id) count from #db.table("search", request.zos.zcoreDatasource)# WHERE 
	app_id=#db.param(9)# and 
	search_fulltext LIKE #db.param('%'&form.searchtext&'%')# and 
	site_id IN (#db.param(0)#, #db.param(request.zos.globals.id)#) and 
	search_deleted=#db.param(0)#";
	if(structkeyexists(request.zsession, 'zManualStruct')){
		idlist="'global-documentation-"&structkeylist(request.zsession.zManualStruct.idstruct, "','global-documentation-")&"'"; 
		db.sql&=" and search_table_id IN (#db.trustedSQL(idlist)#) ";
	}
	qCount=db.execute("qCount");
 
	searchStruct = StructNew();  
	searchStruct.indexName = 'zIndex'; 
	searchStruct.url = "/z/admin/help/search?searchtext=#urlencodedformat(form.searchtext)#";  
	searchStruct.buttons = 5; 
	searchStruct.index=form.zindex;
	searchStruct.count=qCount.count; 
	searchStruct.perpage = perpage;	
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);

	searchForm();

	echo('<h2>Search Results</h2>');
	if(qSearch.recordcount EQ 0){
		echo('No matches found.');
	}else{
		if(qCount.count GT perpage){
			echo(searchNav);
		}
		for(row in qSearch){
			echo('<div style="width:96%; border-bottom:1px solid ##CCC; padding:2%; float:left;">
				<div style="width:100%; float:left; padding-bottom:10px; font-size:18px; line-height:21px;"><a href="#row.search_url#">#row.search_title#</a></div>
				<div style="font-size:14px; line-height:18px;">#row.search_summary#</div>
			</div>');
		}
		if(qCount.count GT perpage){
			echo(searchNav);
		}
	}
	</cfscript>
</cffunction>
	
<cffunction name="quickStart" access="remote" localmode="modern" roles="member">
	<cfscript>
	init();
	application.zcore.template.setTag("title", "Quick Start Guide");
	application.zcore.template.setTag("pagetitle", "Quick Start Guide");
	</cfscript>
	<style>
	</style>
	<div class="zhelp-manager-div">
		
		<div style="width:100%; float:left; text-align:right;"><a href="##" onclick="window.print();">Print</a></div>
		<p>This guide attempts to introduce you to the most commonly used web site management features.</p>
		<p>If you need additional help, please contact the web developer for assistance.</p>

		<h2>Outline</h2>
		<ul>
			<li><a href="##video_training">Video Training Documentation</a></li>
			<li><a href="##help_compatbility">Compatibility</a></li>
			<li><a href="##help_general">Web Content / General Tips</a></li>
			<li><a href="##help_custom">Custom</a></li>
			<li><a href="##help_content">Content Manager</a></li>
			<li><a href="##help_blog">Blog</a></li>
			<li><a href="##help_lead">Leads</a></li>
			<li><a href="##help_user">Users</a></li> 
			<cfif application.zcore.app.siteHasApp("Event")>
				<li><a href="##help_event">Events</a></li>
			</cfif>
			<cfif application.zcore.app.siteHasApp("Listing")>
				<li><a href="##help_listing">Real Estate</a></li>
			</cfif>
			<cfif application.zcore.app.siteHasApp("Rental")>
				<li><a href="##help_rental">Rentals</a></li>
			</cfif>
			<li><a href="##help_support">Support</a></li> 

		</ul> 
		<p>The links below will open in a new window to help you keep your reading position.</p>

		<h2 id="video_training">Video Training Documentation</h2>
		<p>We've produced over 45 minutes of silent screen capture video to visually demonstrate the core features of the CMS.</p>
		<h3><a href="/z/admin/video-training/index" target="_blank">Watch Training Videos</a></h3>

		<h2 id="help_compatbility">Browser/Device Compatibility Using The Site Manager</h2>
		<p>The front of the web site is built to support a wider range of devices then the site manager.</p>
		<p>While we attempt to support a variety of browsers and devices, we do not guarantee that the manager will work as expected on a touchscreen device.</p>
		<p>It is highly recommended that you do not attempt to edit the web site using a touchscreen mobile device. Many operations are much easier with a mouse and keyboard.</p>
		<p>Please switch to using a computer with mouse and keyboard if you have any trouble using the manager with your mobile device.</p>
		<p>Also be sure to keep your computer software updated.  You will always have the best results using the site manager with the latest version of Chrome, Firefox, or Internet Explorer on Windows or Mac.  You can learn how to upgrade your browser <a href="http://www.whatbrowser.org/" target="_blank">here</a>.</p>
		<hr />
		<h2 id="help_general">Web Content / General Tips</h2>
		<p>We tried to make the software more intuitive by moving some of the advanced features to separate tabs or by hiding them.  Most of the forms have tabs to switch between Basic and Advanced options.  Any information changed on each tab will be saved all together when you save the record.  It is generally recommended that you avoid using the advanced fields unless you know what you are doing.</p>
		<p>Many of the forms allow changing the URL to reach that page to something else.  We recommend not changing these fields especially if there is already a value in the field, since it may break the site navigation.  These fields are there to allow us to setup the web site the way we need it or to preserve old links from a previous version of the web site.   Usually, the client should focus on making good titles for their content, and letting the system generate the URL based on the title.</p>
		<p>If a form is entered incorrectly, there will be an error message displayed at the top in a red box, or with a popup box describing the error.  Be sure to read these messages/errors, make the corrections and retry your submission.</p>
		<p>Meta Keywords / Meta Descriptions fields:  We suggest letting the system populate these fields or leave them empty.  It is more important that your other content is well written, and these hidden fields will rarely add any additional value.  We provide these fields because some people like to add them anyway.</p>
		<p>Copy and pasting into the Visual HTML Editor fields may cause problems if you have brought information in from a Word document, email or web site.   If you do have problems, we suggest deleting that information and copying it to a notepad file first.  Then you can copy and paste from notepad to the editor like normal.  This means you will have to reformat the document using the tools in the editor, but the end result will be a page that looks consistent with the other content on your web site.</p>
		<p>Save often.  The web site login session lasts about 30 minutes, which resets each time you view a page again.  To avoid losing your work, you should save periodically.  You shouldn't leave your computer for lunch or a meeting and expect it to still be logged in when you get back.</p>
		<p>You shouldn't attempt to write a long article directly into the web site editor.  To avoid losing work, please write time consuming content offline in a file on your computer.  After your work is complete, you can bring it to the web site and make final formatting changes / corrections.</p>
		<p>If there is any temporary problem with the Internet or the software, you may also lose the work you were about to submit.  If you have made time consuming changes on the current page view, we suggest making a backup outside the web site before saving to ensure you don't lose your work.</p>
		<p>It is generally not possible to retrieve a backup of information that is less then 24 hours old.  There also may be a fee to retrieve older information.  The web developer may also have trouble retrieving information that is very old, because backups are deleted periodically.  If you have accidentally deleted information or lost hard to recreate information, you may be able to retrieve it, but time is of the essence - so contact the web developer quickly.</p>
		<p>A lot of these tips apply to working with web sites, not just our software.</p>

		<hr />
		<h2 id="help_custom"><a href="/z/admin/site-options/index" target="_blank">Custom</a></h2>
		<p>If your web site has a "Custom" menu, there may be several types of content that you can edit in this section.</p>
		<p>Often any pages that have had a custom design will be updated through this set of records instead of other features in the CMS.</p>
		<p>We create these custom forms in order to make it easier to edit data without having to understand how to build complex layouts and preserve formatting.</p>
		<p>We try to name things in a way that helps you understand what it is.</p>
		<p>Always be sure to verify the front of the web site after making changes to be sure the changes you wanted are represented correctly.</p>

		<hr />
		<h2 id="help_content"><a href="/z/content/admin/content-admin/index" target="_blank">Content Manager</a></h2>
		<h3><a href="/z/content/admin/content-admin/index" target="_blank">Manage Pages</a></h3>
		<p>Most content on the web site can be managed/added with manage pages.</p>
		<h3><a href="/z/content/admin/content-admin/add" target="_blank">Add Page</a></h3>
		<p>When you add a page, it will not appear anywhere on the web site except the site map at first.  You may have to link to it from a menu or another page to get it to appear in the site navigation.</p>
		<h2><a href="/z/admin/files/index" target="_blank">Files &amp; Images</a></h2>
		<p>You can manage a set of files &amp; images that are hosted on the web site.</p>
		<p>The visual HTML editor fields in other parts of the manager integrate with the Files &amp; Images feature to allow you to embed file links and images directly in the HTML area.</p>
		<p>This is also where you can delete files/images, but be careful not to delete files which may be linked from other pages.  Those links will become broken if you do.</p>
		<h3>Add A File</h3>
		<p>After uploading a file, the interface will give you a way to get a link that you can place somewhere else on the web site to enable the user to download or view the file.</p>
		<p>Later, you can view this link again by click on "View" link next to the file.</p>
		<p>Be aware that uploaded files using this feature are not stored in a secure location.  Anyone on the Internet will be able to download the files you upload with this form.  If you need to have password protected files, be sure to work with the web developer to understand how to achieve that.</p>

		<h3>Add An Image</h3>
		<p>You can add images or a zip archive of images with this form. Each image is resized to the dimensions you specify with this form.  By default it tries to resize the image to a space that will fit the width of the most common content area on your web site.  It is important that images are sized appropriately so that the web site loads quickly even on a mobile device.</p>
		<h3>Create Folder</h3>
		<p>If you are planning to add many images &amp; files, it is wise to organize them into folders early on, to reduce the amount of looking around you need to do.</p>
		<h3>Other Ways to Add Images</h3>
		<p>Adding images using the HTML editor or Files &amp; Images is usually for special cases where you want to mix text &amp; image with a custom layout.</p>
		<p>Most of the other features in the manager also support adding images with the image library using the "Open Image Uploader" link or an individual image upload field.</p>
		<p>It is recommended to use the image library feature on blog, pages, and anywhere else you find it.  Each image library is attached to that specific content, which keeps it organized.  Those files are also automatically deleted if you delete the page.</p>


		<h2 id="help_blog"><a href="/z/blog/admin/blog-admin/articleList" target="_blank">Blog</a></h2>
		<h3><a href="/z/blog/admin/blog-admin/categoryAdd?site_x_option_group_set_id=0" target="_blank">Add Blog Category</a></h3>
		<p>The first time you use the blog, you will be required to create a category and it will redirect you to that page.</p>
		<h3><a href="/z/blog/admin/blog-admin/articleAdd?site_x_option_group_set_id=0" target="_blank">Add Blog Article</a></h3>
		<p>New blog articles will automatically appear on the blog home page if they are set to be published now or in the past.  If you set a blog article to publish at a future date, it will publish at that date instead.  Articles are also associated with categories, and this lets you create additional links on your site to group related content together.</p> 
		<h3><a href="/z/blog/admin/blog-admin/articleList" target="_blank">Manage Blog Articles</a></h3>
		<p>You can search for existing articles or browse to manage the articles</p>

		<hr />

		<h2 id="help_lead"><a href="/z/inquiries/admin/manage-inquiries/index" target="_blank">Leads</a></h2>
		<p>Usually the forms on the front of the web site will send an email with all the information submitted, and also store a copy of that information in the lead database.  This section of the web site lets you review past leads, change their status, add notes, assign leads and change where leads are sent.</p>
		<h3><a href="/z/inquiries/admin/routing/index" target="_blank">Lead Routing</a></h3>
		<p>The system generates an email with the full information provided by the prospect when an inquiry form is submitted on the web site.</p>
		<p>The system allows you to route these emails to different users or email addresses.</p>
		<p>To change the lead routing configuration, use the menu to go to: Manage Leads -> <a href="/z/inquiries/admin/routing/index" target="_blank">Lead Routing</a>.</p>
		<p>On this page, you'll be able to click a link to edit the "Office Email" at the bottom of the Content Manager -> <a href="/z/admin/site-options/index" target="_blank">Site Options</a> page, or add individual routes for specific types of leads.</p>
		<p>If you have a variety of departments within your organization, the lead routing tool can help you make sure that incoming requests go directly to the correct people.</p>
		<p>The system comes with a variety of built-in lead types depending on the features the web site has enabled, but additional forms and lead types can be added.</p>

		<h3><a href="/z/inquiries/admin/manage-inquiries/index?zManagerAddOnLoad=1" target="_blank">Add Lead</a></h3>
		<p>In addition to collecting leads through forms on your web site, it is also possible to manually add a lead.</p>
		<p>You may want to do this for leads that come via the phone, email or in-person meetings you have throughout the day so your team is able to share the information, make notes, and add replies through one system.</p>
		<p>Keeping all your leads and notes in one place is easy thanks to this feature.</p>
		<p>To add a lead, go to the menu: Manage Leads -> <a href="/z/inquiries/admin/manage-inquiries/index?zManagerAddOnLoad=1" target="_blank">Add Lead</a>.</p>
		<h3>Assigning Leads</h3>
		<p>Leads can be assigned by click assign next to the lead or on its detail page.  On the assign lead page, select from the list of users, or assign the lead to 1 or more email addresses.</p>
		<h3><a href="/z/admin/mailing-list-export/index" target="_blank">Export Mailing List</a></h3>
		<p>If the public forms are set to store whether someone has opt in to a newsletter, this data will be stored in the manager.  You can use this export feature to retrieve a CSV file of all the people who have signed up.  You can them import this data into other software to send email newsletters.</p>
		<h3>Export Leads</h3>
		<p>There are 2 ways to export leads.  1. You can export everything by going to Manage Leads -> <a href="/z/inquiries/admin/export" target="_blank">Export All Leads as CSV</a>.   2. You can go to <a href="z/inquiries/admin/manage-inquiries/index" target="_blank">manage leads</a>, and then perform a search.  After searching, there will be an Export button with export options.</p>
		<h3>Close A Lead</h3>
		<p>When viewing a lead, it is possible to change its status, including setting it to closed or spam.</p>
		<h3>View Lead</h3>
		<p>The view lead page lets you add notes and change the status of a lead in addition to showing you all the information submitted by the user.</p>

		<hr />
		<h2 id="help_user"><a href="/z/admin/member/index" target="_blank">Manage Users</a></h2>
		<p>It is possible to add additional users to manage the web site, with limited access to manage the web site's information.</p>
		<p>You can also create public profiles for members of your organization, to have a simple public page where they all appear with a photo, biography and contact info.</p>
		<h3><a href="/z/admin/member/add" target="_blank">Add User</a></h3>
		<p>If you want to add a user who has full access to edit all features of the web site, set "Access Rights" to "Administrator".</p>
		<p>If you want to create a user who can login and view only the leads assigned to them, set "Access Rights" to "Member".</p>   
		<p>If you want to create a user that can't login to the manager, but they can login to the front of the web site, set "Access Rights" to "User".</p>
		<p>On some web sites, we add other access rights types.  You may need to ask the web developer when/how to use them.  For example, a web site with a business directory may have a different type of group which should be selected to limit the access rights correctly.</p>
		<h3>Limiting Access</h3>
		<p>On the advanced tab of add/edit user, there is a "Limit Manager Features" option.  You can use this to restrict which features appear for the user.  It is recommended to verify their account after using this to see if you have used it correctly.</p>
		<h3>Making A Public Profile</h3>
		<p>This is an option for "Show Profile", on add/edit user, which will enable a public profile.</p>
		<h3>Public Users</h3>
		<p>When users create an account on your web site, you will be able to manage their account by clicking 
		on the "<a href="/z/admin/member/index?showallusers=1" target="_blank">Show Public Users</a>" link on the Users -> <a href="/z/admin/member/index" target="_blank">Manage Users</a> page.</p>


		<cfif application.zcore.app.siteHasApp("Event")>
			<hr />
			<h2 id="help_event">Events</h2>
			<p>You usually need to use events when you have events that occur in the future which should be listed in chronological order on the web site and automatically disappear when the date has passed.   Our web site features will automatically remove these events for you on the default landing page for events and any widgets we insert to show a short list of upcoming events.   When these events stop being displayed, they still exist on the site map and search features.  Users can also find past events by clicking to previous months when on the 30 day calendar view.</p>
			<h3><a href="/z/event/admin/manage-event-calendar/index" target="_blank">Manage Calendars</a></h3>
			<p>There must be at least one calendar created before adding events.</p>
			<p>A calendar can be configured to have a list view, a 30 day calendar view, and a search form.</p>
			<h3><a href="/z/event/admin/manage-event-category/index" target="_blank">Manage Categories</a></h3>
			<p>If you want to allow searching between different types of events on a single calendar, you should use the category feature to do this.</p>
			<p>Categories also have then other URL which behaves the same as creating a separate calendar</p>
			<h3><a href="/z/event/admin/manage-events/index" target="_blank">Manage Events</a></h3>
			<p>Each event must be associated to 1 or more calendars.  Using categories is optional.  An event can be set to have recurrence by clicking edit next to recurring event on the Add/Edit Event page.</p> 
			<p>Using the recurring event features saves you a lot of time by letting you define complex recurrence rules so you don't have to add an event multiple times if its schedule is consistently the same.  These recurring rules allow you to define rules for multiple modes including: daily, weekly, monthly and annually and you can even exclude specific dates from the schedule.</p>
			<p>It is important that the start and end date are set to be for a single occurence of the event.  If you need to stop when the event recurs so that it doesn't recur forever, there is a feature to do that in the edit recurring event options.</p>


		</cfif>


		<cfif application.zcore.app.siteHasApp("Job")>
			<cfif request.zos.isTestServer>
				<!--- TODO: Job documentation --->
				<hr />
				<h2 id="help_event">TODO: Jobs</h2>
			</cfif>
		</cfif>


		<cfif application.zcore.app.siteHasApp("Listing")>
			<hr />
			<h2 id="help_listing">Real Estate</h2>
			<p>We recommend working with the web developer before trying to use any of the features in the Real Estate menu.</p>
			<h3><a href="/z/listing/admin/search-filter/index" target="_blank">Listing Search Filter</a></h3>
			<p>This feature allows you to remove search criteria and listings from being visible on the front of the web site.  If you have office/agent listings that use the criteria you are trying to remove, it will not be possible to remove the criteria in some cases. This is a safety measure to prevent you from disabling access to view your own listings.</p>
			<p>We think this is an advanced feature, and you should work with the web developer to make sure it is configured correctly.</p>
		</cfif>
		<cfif application.zcore.app.siteHasApp("Rental")>
			<hr />
			<h2 id="help_rental"><a href="/z/rental/admin/rates/index" target="_blank">Rentals</a></h2>
			<p>The rentals section allows you to add rental, categories, and amenities.</p>
			<p><a href="/z/rental/admin/rates/index" target="_blank">Rentals</a> can have availability calendars, images, rates, and other descriptive info</p>
			<p><a href="/z/rental/admin/rental-category/index" target="_blank">Rental Categories</a> let you create different groupings of your rentals so you have a user and search engine friendly way to view those properties.</p>
			<p><a href="/z/rental/admin/rental-amenity/index" target="_blank">Rental Amenities</a> let you define one or more amenities that can be associated with a rental to show more bullet point features on that property.</p>
		</cfif>
		<h2 id="help_support">Questions And Support</h2>
		<p>We often customize web sites for individual clients.  You may have other custom features not listed in this documentation.</p>

		<p>If you have any questions or problems using the manager, let the web developer know.  Please contact the web developer to schedule a training session or submit an email/ticket with your question.</p>

	</div>
</cffunction>

<cffunction name="docs" access="remote" localmode="modern" roles="member">
	<cfscript>
	application.zcore.template.setTag("title", "Documentation");
	application.zcore.template.setTag("pagetitle", "Documentation");

	// integrate jetendo manual here.
	</cfscript>

</cffunction>

<cffunction name="support" access="remote" localmode="modern" roles="member">
	<cfscript>
	application.zcore.template.setTag("title", "Support");
	application.zcore.template.setTag("pagetitle", "Support");

	// output information from the vendor record later
	</cfscript>
	<p>We are available to provide support for your web site.</p>
	
</cffunction>


<cffunction name="incontext" access="remote" localmode="modern" roles="member">
	<cfscript>
	application.zcore.template.setTag("title", "In-context Help Features");
	application.zcore.template.setTag("pagetitle", "In-context Help Features");
	</cfscript>
	<p>We try to make the application intuitive by providing help tips directly next to the features throughout the software.</p>
	<h2>Tooltips</h2>
	<p><!--- SCREENSHOT OF TOOLTIP ICON:  --->You can rollover or click on a tooltip to display a description of what that feature is intended to do.</p>
	<!--- <h2>Sorting</h2>
	<p><!--- SCREENSHOT OF SORT ICONS:  --->These icons are used to move records up or down in their position.  
	Use these arrows to change the order of photos in a slideshow, or the order of links on a menu depending on the feature you use them on.</p> --->
	<cfif request.zos.istestserver>
	
		<h2>Help for this page</h2>
		<p><!--- SCREENSHOT OF HELP FOR THIS PAGE MENU:  --->To help you find the documentation for the page you are on, we have integrated the help system directly into the manager. 
		If you see go to Help -> Help For This Page, you will be taken directly to a new window with the documentation for that page.</p>
	</cfif>
	<h2>Descriptions on the page</h2>
	<p>Make sure you read all the text on the page, we often write important tips for helping you understand how the features work.</p>
</cffunction>


<!--- 
https://www.jetendo.com/z/admin/help/displayHelpVideo?path=seo-reports/calltrackingmetrics-report.mp4
 --->
<cffunction name="displayHelpVideo" access="remote" localmode="modern" roles="member">
	<cfscript>
	form.path=application.zcore.functions.zso(form, 'path');
	application.zcore.template.setPlainTemplate();
	application.zcore.template.setTag("title", "Video Training");
	//application.zcore.template.setTag("pagetitle", "Video Training");
	application.zcore.skin.includeCSS("/z/javascript/techsmith-video-player/skins/overlay/techsmith-smart-player.min.css");
	application.zcore.skin.includeJS("/z/javascript/techsmith-video-player/scripts/config_xml.js")
	</cfscript>

<div id="tscVideoContent" style="width:100% !important; max-width:100%; height:100% !important; margin:0 auto;">
   <img width="32px" height="32px" style="position: absolute; top: 50%; left: 50%; margin: -16px 0 0 -16px"
         src="data:image/gif;base64,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"><!---   --->
</div>
 
<script>
zArrDeferredFunctions.push(function(){
    (function (window) {
        function setup(TSC) {
            TSC.playerConfiguration.setFlashPlayerSwf("/z/javascript/techsmith-video-player/controller.swf");
             TSC.playerConfiguration.addMediaSrc("/zupload/user/video-training/#form.path#");
            // TSC.playerConfiguration.setXMPSrc("/z/javascript/techsmith-video-player/config.xml");
             
             TSC.playerConfiguration.setAutoHideControls(true);
             TSC.playerConfiguration.setBackgroundColor("##000000");
             TSC.playerConfiguration.setCaptionsEnabled(false);
             TSC.playerConfiguration.setSidebarEnabled(false);
             
             TSC.playerConfiguration.setAutoPlayMedia(false);
             //TSC.playerConfiguration.setPosterImageSrc("/z/javascript/techsmith-video-player/Frame.png");
             TSC.playerConfiguration.setIsSearchable(false);
             TSC.playerConfiguration.setEndActionType("stop");
             TSC.playerConfiguration.setEndActionParam("true");
             TSC.playerConfiguration.setAllowRewind(-1);
             

             TSC.localizationStrings.setLanguage(TSC.languageCodes.ENGLISH);
			  

            TSC.mediaPlayer.init("##tscVideoContent");
        }

        function loadScript(e,t){if(!e||!(typeof e==="string")){return}var n=document.createElement("script");if(typeof document.attachEvent==="object"){n.onreadystatechange=function(){if(n.readyState==="complete"||n.readyState==="loaded"){if(t){t()}}}}else{n.onload=function(){if(t){t()}}}n.src=e;document.getElementsByTagName("head")[0].appendChild(n)}

        loadScript('/z/javascript/techsmith-video-player/scripts/techsmith-smart-player.min.js', function() {
            setup(window["TSC"]);
        });
    }(window));
});
</script>

</cffunction>
 

</cfoutput>
</cfcomponent>