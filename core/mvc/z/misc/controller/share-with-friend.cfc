<cfcomponent>
<cfoutput>

<!--- 
it is possible to do an ajax request to the submit function like this:
$("#formForward").on("submit", function(){
	function ajaxShareWithFriendResponse(r){ 
		var r=JSON.parse(r);
		if(r.success){
			alert('Your message has been sent.');
			// clear the form back to the default values
			$('#form_id').trigger("reset");
		}else{
			alert(r.errorMessage);
		}
	}
	var postObj=zGetFormDataByFormId("formForward");
	var tempObj={};
	tempObj.id="zShareFriend";
	tempObj.url="/z/misc/share-with-friendy/submit?ajax=1";
	tempObj.callback=ajaxShareWithFriendResponse;
	tempObj.cache=false;
	zAjax(tempObj);
});
 --->
<!--- <cffunction name="submit" localmode="modern" access="remote">
	<cfscript>  
	if(application.zcore.functions.zvar('enableSendToFriend', request.zos.globals.id) NEQ 1){
		application.zcore.functions.z404("Share with friend disabled because site globals doesn't have ""Enable Send To Friend"" enabled.");
	}
	// In the case of an embedded form and you want the resulting page to
	// include the site header and footer, add a hidden field to the form called
	// 'modalpopforced' and set it to '0'. By default this is normally handled
	// in a modal window, but needed to make adjustments for a special case.
	form.ajax=application.zcore.functions.zso(form, 'ajax', true, 0);
	form.trackingId=application.zcore.functions.zso(form, 'trackingId');

	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', false, 1);
	
	form.title=application.zcore.functions.zso(form, 'title');
	form.link=application.zcore.functions.zso(form, 'link');
	if(left(form.link, 4) NEQ "http"){
		form.link=request.zos.currentHostName&form.link;
	}
	if(form.title EQ "" and form.link EQ ""){
		if(form.ajax EQ 0){
			application.zcore.functions.z301redirect("/");	
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"Please enter all required fields."});
		}
	}
	if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
		if(form.ajax EQ 0){
			writeoutput('~n~');
			abort;
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"Invalid request."});
		}
	}
	request.zscriptname="/z/misc/share-with-friend/index?link=#urlencodedformat(form.link)#&title=#urlencodedformat(form.title)#";
	if(form.ajax EQ 0){
		if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
			application.zcore.status.setStatus(request.zsid, "Your session has expired.  Please submit the form again.",form,true);
			application.zcore.functions.zRedirect(request.zscriptname&"&zsid="&request.zsid);
		}
	}
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		if(form.ajax EQ 0){
			application.zcore.functions.zRedirect("/");
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"Invalid request"});
		}
	}
	if(application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1){
		if(application.zcore.functions.zVerifyRecaptcha() EQ false){
			if(form.ajax EQ 0){
				application.zcore.status.setStatus(request.zsid, "Recaptcha image was typed incorrectly.  Please try again.",form,true);
				application.zcore.functions.zRedirect(request.zscriptname&"&zsid="&request.zsid);
			}else{
				application.zcore.functions.zReturnJson({ success:false, errorMessage:"Recaptcha image was typed incorrectly.  Please try again."});
			}
		}
	}
	arrEmail = ArrayNew(1);
	error = false;
	pos=findnocase("</",application.zcore.functions.zso(form, 'inquiries_comments'));
	if(pos NEQ 0){
		if(form.ajax EQ 0){
			application.zcore.functions.zRedirect("/");
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"Invalid request."});
		}
	}
	if(structkeyexists(form, 'email_from') EQ false){
		if(form.ajax EQ 0){
			application.zcore.functions.zRedirect('/');
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"From Email is required."});
		}
	}

	if(application.zcore.functions.zso(form, 'friend_name') EQ ""){
		error = true;		
		if(form.ajax EQ 0){
			application.zcore.status.setStatus(request.zsid, "Friend's Name is required",form,true);
			application.zcore.functions.zRedirect(request.zscriptname&"&zsid="&request.zsid);
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"Friend's Name is required"});
		}
	}
	if(application.zcore.functions.zso(form, 'name') EQ ""){
		error = true;		
		if(form.ajax EQ 0){
			application.zcore.status.setStatus(request.zsid, "Your Name is required",form,true);
			application.zcore.functions.zRedirect(request.zscriptname&"&zsid="&request.zsid);
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"Your Name is required"});
		}
	}
	if(application.zcore.functions.zEmailValidate(form.email_from) EQ false){
		error = true;		
		if(form.ajax EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid ""From"" Email Address: "&form.email_from,form,true);
			application.zcore.functions.zRedirect(request.zscriptname&"&zsid="&request.zsid);
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"Invalid ""From"" Email Address: "&form.email_from});
		}
	}
	if(application.zcore.functions.zso(form, 'comments') EQ ""){ 
		error = true;		
		if(form.ajax EQ 0){
			application.zcore.status.setStatus(request.zsid, "Message is required",form,true);
			application.zcore.functions.zRedirect(request.zscriptname&"&zsid="&request.zsid);
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"Message is required"});
		}
	}
	form.email_to = replace(application.zcore.functions.zso(form, 'email_to')," ","","ALL");
	if(listLen(form.email_to) GT 10){	
		if(form.ajax EQ 0){	
			application.zcore.status.setStatus(request.zsid, "You can only send this email to ten friends at a time.",form,true);
			application.zcore.functions.zRedirect(request.zscriptname&"&zsid="&request.zsid);
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"You can only send this email to ten friends at a time."});
		}
	}
	arrFail=[];
	for(i=1;i LTE listLen(form.email_to);i=i+1){
		currentEmail = listGetAt(form.email_to, i);
		if(application.zcore.functions.zEmailValidate(currentEmail)){
			ArrayAppend(arrEmail, currentEmail);
		}else{
			error = true;
			if(form.ajax EQ 0){	
				application.zcore.status.setStatus(request.zsid, "Invalid ""To"" Email Address: "&currentEmail,form,true);
			}else{
				arrayAppend(arrFail, "Invalid ""To"" Email Address: "&currentEmail);
			}
		}
		if(error){
			if(form.ajax EQ 0){	
				application.zcore.status.setStatus(request.zsid, "Your email was not sent.",form,true);
				application.zcore.functions.zRedirect(request.zscriptname&"&zsid="&request.zsid);
			}else{
				application.zcore.functions.zReturnJson({ success:false, errorMessage:arrayToList(arrFail, "\n")});
			}
		}
	}
	if(arrayLen(arrEmail) EQ 0){
		if(form.ajax EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid ""To"" Email Address: "&form.email_to,form,true);
			application.zcore.functions.zRedirect(request.zscriptname&"&zsid="&request.zsid);
		}else{
			application.zcore.functions.zReturnJson({ success:false, errorMessage:"Invalid ""To"" Email Address: "&form.email_to});
		}
	}
	emailList = ArrayToList(arrEmail);
	</cfscript>
	<cfif error EQ false and emailList NEQ "">
		<cfscript>
		if(isDefined('request.zsession.friendEmailSent') EQ false){
			request.zsession.friendEmailSent = 0;
		}
		request.zsession.friendEmailSent = request.zsession.friendEmailSent+1;
		if(request.zsession.friendEmailSent GT 10){			
			if(form.ajax EQ 0){	
				application.zcore.status.setStatus(request.zsid, "You can only send 10 ""Email a Friend"" emails per request.zsession.",form,true);
				application.zcore.functions.zRedirect(request.zscriptname&"&zsid="&request.zsid);
			}else{
				application.zcore.functions.zReturnJson({ success:false, errorMessage:"You can only send 10 ""Email a Friend"" emails per request.zsession."});
			}
		}
		fromEmail=request.zos.globals.emailcampaignfrom;
		if(fromEmail EQ ""){
			fromEmail=request.officeemail;
		}
		</cfscript>
        
<cfsavecontent variable="request.zTempNewEmailPlainText">
#form.name# (#form.email_from#) has shared the following link with you from our web site:

#form.title#

#form.link#

They provided the following comments:

#application.zcore.functions.zso(form, 'comments')#

You can reply to #form.name# by replying to this email.
</cfsavecontent>
        <cfsavecontent variable="request.zTempNewEmailHTML">
        <p style="font-weight:bold;">#form.name# (#form.email_from#) has shared the following link with you from our web site:</p>
        <p><a href="#form.link#">#form.title#</a></p>
        <p><a href="#form.link#">#form.link#</a></p>
        <p>#form.name# provided the following comments:</p>
        <p><em>"#application.zcore.functions.zparagraphFormat(application.zcore.functions.zso(form, 'comments'))#"</em></p>
        <p>You can reply to #form.name# by replying to this email.</p>
        </cfsavecontent>
			<cfscript>
			debug=false;
			for(i333=1;i333 LTE arraylen(arrEmail);i333++){
				ts=StructNew();
				ts.hideViewEmailUrl=true;
				ts.site_id=request.zos.globals.id;
				ts.subject="#application.zcore.functions.zso(form, 'name')# has shared a link with you.";
				ts.from=fromEmail;
				ts.replyTo=form.email_from;
				// change this to be a custom script in the database, so that the variables read in.
				ts.zemail_template_type_name="General";
				ts.html=true;
				/*ts.arrParameters=arraynew(1);
				arrayappend(ts.arrParameters,t9.mls_saved_search_id);
				*/
				if(debug){
					ts.to=request.zos.developerEmailTo;
				}else{
					ts.to=arrEmail[i333];
				}
				//ts.bcc="#request.zos.developerEmailFrom#";
				//writedump(ts);
				rCom=application.zcore.email.sendEmailTemplate(ts);
				if(rCom.isOK() EQ false){
					if(form.ajax EQ 0){	
						rCom.setStatusErrors(request.zsid);
						application.zcore.functions.zstatushandler(request.zsid);
						abort;
					}else{
						application.zcore.functions.zReturnJson({ success:false, errorMessage:"Failed to send email."});
					}
				}
				if(debug){
					writedump(rCom);
					abort;
				}
			}
            </cfscript> 
	</cfif>
	<cfscript>
	if(form.ajax EQ 0){	
		application.zcore.status.setStatus(request.zsid, "The email has been sent.");
		thankYouURL=application.zcore.functions.zso(request.zos.globals, 'shareWithFriendThankYouUrl')
		if(thankYouURL EQ ""){
			thankYouURL="/z/misc/thank-you/index";
		}
		application.zcore.functions.zredirect(application.zcore.functions.zURLAppend(thankYouURL, "trackingID=#urlencodedformat(form.trackingId)#&modalpopforced=#form.modalpopforced#")); 
	}else{
		application.zcore.functions.zReturnJson({ success:true });
	}
	</cfscript>
</cffunction> --->

<cffunction name="index" localmode="modern" access="remote">
<cfscript>
form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', false, 1);
form.trackingId=application.zcore.functions.zso(form, 'trackingId');
var theMeta=0;
if(application.zcore.functions.zvar('enableSendToFriend', request.zos.globals.id) NEQ 1){
	application.zcore.functions.z404("Share with friend disabled because site globals doesn't have ""Enable Send To Friend"" enabled.");
}

</cfscript>
<cfsavecontent variable="theMeta">
<meta name="robots" content="noindex,nofollow" />
</cfsavecontent>
<cfscript>
request.zos.debuggerEnabled=false;
application.zcore.template.setTag("pagetitle","Share With Friend(s)");
application.zcore.template.setTag("title","Share With Friend(s)");
application.zcore.template.setTag("meta",theMeta);
if(form.modalpopforced){
	application.zcore.functions.zSetModalWindow();
}

if(structkeyexists(form, 'title') EQ false){
	form.title="View Web Site";
}
if(structkeyexists(form, 'link') EQ false){
	form.link=request.zos.currentHostName&"/";
}
if(left(form.link, 4) NEQ "http"){
	form.link=request.zos.currentHostName&form.link;
}
</cfscript>  

  <p>You can share this link with your friends on facebook by clicking the Share button below.</p>

  <iframe src="https://www.facebook.com/plugins/share_button.php?href=#htmleditformat(form.link)#&layout=button_count&size=large&mobile_iframe=true&width=106&height=28" width="106" height="28" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true" allow="encrypted-media"></iframe>
  <!--- &appId=115495061846681 --->

<!--- 
	<cfscript>
	application.zcore.functions.zStatusHandler(request.zsid, true);
	</cfscript>
	<form class="zFormCheckDirty" action="/z/misc/share-with-friend/submit" method="post" name="formForward" id="formForward">
    <input type="hidden" name="trackingId" value="#htmleditformat(form.trackingId)#">
    #application.zcore.functions.zFakeFormFields()#
	<table style="border-spacing:0px; width:98%;" class="zinquiry-form-table">
    <tr><td style="vertical-align:top; width:115px;">Page Title:</td>
    <td style="font-size:90%;"><input type="text" readonly="readonly" name="title" value="#htmleditformat(application.zcore.functions.zso(form, 'title'))#" onfocus="this.readOnly=true;" style="width:100%; border:none;" /></td></tr>
    <tr><td style="vertical-align:top; ">Page URL:</td>
    <td style="font-size:90%;"><input type="text" readonly="readonly" name="link" value="#htmleditformat(application.zcore.functions.zso(form, 'link'))#" onfocus="this.readOnly=true;" style="width:100%;border:none;" /></td></tr>
	<tr><td>Friend's Name: *</td>
		<td><input type="text" name="friend_name" value="#application.zcore.functions.zso(form, 'friend_name')#" size="45" style="width:100%" maxlength="50" /></td>
	</tr>
	<tr>
		<td style="vertical-align:top;">Friend's Email: *</td>
		<td><input type="text" name="email_to" value="#application.zcore.functions.zso(form, 'email_to')#" size="45" style="width:100%" /><br />
        Enter up to 10 email addresses separated by commas</td>
	</tr>
	<tr><td>Your Name: *</td>
		<td><input type="text" name="name" value="#application.zcore.functions.zso(form, 'name')#" size="45" style="width:100%" maxlength="50" /></td>
	</tr>
	<tr>
		<td>Your Email: *</td>
		<td><input type="text" name="email_from" value="#application.zcore.functions.zso(form, 'email_from')#" size="45" style="width:100%" maxlength="50" /></td>
	</tr>
	<tr>
		<td style="vertical-align:top; ">Comments:</td>
		<td><textarea name="comments" rows="8" cols="50" style="width:100%">#application.zcore.functions.zso(form, 'comments')#</textarea></td>
	</tr>
	<cfif application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1>
	
		<tr>
			<td style="vertical-align:top; ">&nbsp;</td>
			<td>#application.zcore.functions.zDisplayRecaptcha()#</td>
		</tr>
	</cfif>
    
	<tr>
		<td>&nbsp;</td>
		<td><a href="/z/user/privacy/index" target="_blank" class="zPrivacyPolicyLink">Privacy Policy</a></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><button type="submit" value="Send" name="send">Send</button></td>
	</tr>
	</table>
	<input type="hidden" name="js3811" id="js3811" value="" />
	<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
	</form>--->

</cffunction>
</cfoutput> 
</cfcomponent>