<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.zSetPageHelpId("6.6");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Real Estate Widgets and Links");
	application.zcore.template.settag("title","Real Estate Widgets and Links");
	</cfscript>
	<h1>Widgets for other web sites</h1>
	<p>Sometimes you have a profile on another web site such as facebook, where adding a custom page is desirable to draw customers to your web site.  Feel free to insert one of the widget code snippets below in order to achieve dynamic features that integrate with your web site.</p>
	<h1>Quick Search</h1>
	<p>HTML CODE</p>
	<textarea name="quicksearch1" cols="80" rows="5"  onclick="this.select();" style="width:100%; height:30px;">
	#htmleditformat('<script src="#request.zos.currentHostName#/z/listing/quick-search/index"></script>')#
	</textarea>
	<p>Widget Example</p>
	<script src="#request.zos.currentHostName#/z/listing/quick-search/index"></script>
	<hr />
	<!--- <p>More widgets will be available in the future.</p> --->

	<h2>Other Built-in Real Estate Features/Links</h2>

	<p><a href="/z/listing/cma-inquiry/index">CMA Inquiry Form</a></p>
	<p><a href="/z/listing/map-fullscreen/index">Fullscreen Map Search</a></p>
	<p><a href="/z/misc/mortgage-calculator/index">Mortgage Calculator</a></p>
	<p><a href="/z/misc/mortgage-quote/index">Mortgage Quote Form</a></p>
	<p><a href="/z/listing/new-listing-email-signup/index">New Listings By Email Signup Form</a></p>
	<p><a href="/z/listing/advanced-search/index">Search Form</a></p>
	<p><a href="/z/listing/property/your-saved-searches/index">Your Saved Searches</a></p>
	<p><a href="/z/listing/sl/view">Your Saved Listings</a></p>
</cffunction>
</cfoutput>
</cfcomponent>