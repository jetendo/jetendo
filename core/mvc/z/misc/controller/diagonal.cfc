<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
<cfscript>
application.zcore.template.appendTag("stylesheets",'<style>html, body{ overflow:hidden;}</style>');
Request.zPageDebugDisabled=true;
application.zcore.template.setTemplate("zcorerootmapping.templates.simple",true,true);
</cfscript><cfif structkeyexists(form, 'newmessage')><div style="display:none;" class="zFlashDiagonalStatusMessage">#htmleditformat(form.newMessage)#</div></cfif>
</cffunction>
</cfoutput>
</cfcomponent>