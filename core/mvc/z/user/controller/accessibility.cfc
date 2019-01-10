<cfcomponent>
 <cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript> 
	textMissing=false
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zSetModalWindow();
	}
	</cfscript>
	<cfsavecontent variable="zpagenav">
		<a href="/">Home</a> / 
	</cfsavecontent>
	<cfscript>
	application.zcore.template.setTag("title","Accessibility Statement");
	application.zcore.template.setTag("pagetitle","Accessibility Statement");
	application.zcore.template.setTag("pagenav",zpagenav);
	</cfscript>

	<cfif application.zcore.user.checkGroupAccess("administrator")>
		<div class="z-float" style="border:1px solid ##900; padding:10px;">
			Note for administrators: If you wish to override the content of this page, please create a page in the manager and override the url to be "/z/user/accessibility/index".
		</div>
	</cfif>
	<cfif application.zcore.app.siteHasApp("content")>
		<cfscript>
		ts=structnew();
		ts.content_unique_name='/z/user/accessibility/index';
		//ts.disableContentMeta=false;
		ts.disableLinks=true;
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		if(not r1){
			textMissing=true;
		}
		</cfscript>
	<cfelse>
		<cfset textMissing=true>
	</cfif>
	<cfif textMissing> 
		<p>We wish to provide an online experience that works well for everyone and we continue to improve our web site to work according to best practices. If you have any trouble using our web site, please contact us and help us improve.</p>

		<cfscript>
		signature=application.zcore.functions.zvar('emailSignature');
		curEmail=application.zcore.functions.zvar('zofficeemail');
		if(signature EQ "" and curEmail NEQ ""){
			email=listGetAt(curEmail, 1, ",");
			signature=application.zcore.functions.zEncodeEmail(email, true);
		}
		</cfscript>
		<cfif signature NEQ "">
			<h2>Company contact information:</h2>
			#application.zcore.functions.zparagraphformat(signature)#
	  	</cfif>
</cfif>
</cffunction>
</cfoutput>
</cfcomponent>