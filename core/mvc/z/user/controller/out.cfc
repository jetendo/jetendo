<cfcomponent>
 <cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
 	<cfscript>
	var zpagenav='<a href="/">Home</a> /';
	application.zcore.template.setTag("title","Unsubscribe From Our Mailing List");
	application.zcore.template.setTag("pagetitle","Unsubscribe From Our Mailing List");
	application.zcore.template.setTag("pagenav",zpagenav);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	
	</cfscript>
	<form class="zFormCheckDirty" name="getEmail" action="/z/user/out/update" method="post">
	<p>To be removed from our mailing list, please type your email address below:</p>
	<p>Email Address:&nbsp;<input type="text" name="e" size="30" /></p>
	<button type="submit" name="submit" value="Unsubscribe">Unsubscribe</button>
	</form>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" output="yes">
	<cfscript>
	var c=0;
	form.e=application.zcore.functions.zso(form, 'e');
	form.k=application.zcore.functions.zso(form, 'k');
	if(len(trim(application.zcore.functions.zso(form, 'e'))) EQ 0 or application.zcore.functions.zEmailValidate(form.e) EQ false){
		application.zcore.status.setStatus(request.zsid, "Email Address is required.",false,true);
		application.zcore.functions.zRedirect("/z/user/out/index?zsid=#request.zsid#");
	}
	if(structkeyexists(form, 'e') and trim(form.e) NEQ ''){
		form.submitPref="Unsubscribe";
		c=createobject("component", "zcorerootmapping.mvc.z.user.controller.preference");
		c.update();
	}
	</cfscript>

</cffunction>
</cfoutput>
</cfcomponent>