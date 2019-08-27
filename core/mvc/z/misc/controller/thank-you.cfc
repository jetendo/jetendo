<cfcomponent>
<cfoutput>
<cffunction name="complete" localmode="modern" access="remote" output="yes">
	<cfscript>
	// this function is for disabling conversation tracking
	index();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" output="yes">
	<cfscript>
	var ts=0;
	var inquiryTextMissing=false;
	var r1=0;
	if(application.zcore.app.siteHasApp("content")){
		ts=structnew();
		ts.content_unique_name='/z/misc/thank-you/index';
		ts.disableContentMeta=false;
		ts.disableLinks=true;
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		if(r1 EQ false){
			inquiryTextMissing=true;
		}
	}else{
		inquiryTextMissing=true;
	}
	if(inquiryTextMissing){
		application.zcore.template.setTag("title","Thank you for your inquiry.");
		application.zcore.template.setTag("pagetitle","Thank you for your inquiry.");
		writeoutput('<p class="thanksMsg">Someone will respond to your inquiry soon.</p>');
	}
	</cfscript>
	<cfif structkeyexists(form,'modalpopforced') and form.modalpopforced EQ 1>
		<cfscript>
		application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
		</cfscript>
		<cfif not structkeyexists(request.zsession,'disableclosewindowmessage')>
	
			<p>Closing window in 3 seconds.</p>
			<script type="text/javascript">/* <![CDATA[ */ 
			setTimeout(function(){ zCloseThisWindow(); },3000);
			/* ]]> */
			</script>
		<cfelse>
			<cfscript>
			structdelete(request.zsession, 'disableclosewindowmessage');
			</cfscript>
		</cfif>
	</cfif>
	<cfif form.method NEQ "complete">
		#application.zcore.functions.zVarSO("Lead Conversion Tracking Code")#
	</cfif>
</cffunction>

<cffunction name="error" localmode="modern" access="remote" output="yes">
	<cfscript>
		application.zcore.template.setTag("title", "Sorry, your inquiry couldn't be processed");
		application.zcore.template.setTag("pagetitle", "Sorry, your inquiry couldn't be processed");
	</cfscript>
	<p>Please go back and try again, or contact us another way.</p>
</cffunction>
</cfoutput>
</cfcomponent>
