<cfcomponent>
<cfoutput> 
<cffunction name="index" localmode="modern" access="remote"><cfscript> 
	writeoutput('1 is OK');
	// This function is used for monitoring
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="generateImagePlaceholder" returntype="string" access="remote" localmode="modern">
	<cfscript>
	if(not structkeyexists(cookie, 'zenable')){
		application.zcore.functions.z404("No cookie set, so generateImagePlaceholder is prevented");
	}  
	form.width=application.zcore.functions.zso(form, 'width', true);
	form.height=application.zcore.functions.zso(form, 'height', true); 
	if(form.width EQ 0 or form.height EQ 0){
		application.zcore.functions.z404("Invalid width/height.");
	}
	application.zcore.functions.z404("Feature disabled");
	// i=ImageNew("#request.zos.installPath#public/images/widget/grey.png");
	// imageresize(i, form.width, form.height); 
	header name="content-Disposition" value="attachment; filename=placeholder.png";
	content variable="#i#"  type="image/png" reset="true";
	abort; 
	</cfscript>
</cffunction>

<cffunction name="closeModal" localmode="modern" access="remote">
	<script>window.parent.zCloseModal();</script><cfabort>
</cffunction>

<cffunction name="legal" localmode="modern" access="remote">
	<cfscript>
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',false,0);
    if(form.modalpopforced EQ 1){
		application.zcore.functions.zSetModalWindow();
    }
	application.zcore.template.setTag("title", "Legal Notices");
	application.zcore.template.setTag("pagetitle", "Legal Notices");
	textMissing=true;
	</cfscript>

	<cfif application.zcore.app.siteHasApp("content")>
		<cfscript>
		ts=structnew();
		ts.content_unique_name='/z/misc/system/legal';
		//ts.disableContentMeta=false;
		ts.disableLinks=true;
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		if(r1){
			textMissing=false;	
		}
		</cfscript>
	</cfif>
	<cfif textMissing>
		<h2>Public User Disclaimers</h2>
		<ul>
			<li><a href="/z/user/privacy/index" class="zPrivacyPolicyLink">Privacy Policy</a></li>
			<li><a href="/z/user/terms-of-use/index">Terms of Use</a></li>
		</ul>

		<cfif application.zcore.app.siteHasApp("listing")>
			<h2>Real Estate Listing Data Disclaimers</h2>
			#request.zos.listingCom.getDisclaimerText()#
		</cfif>
		<h2>About Copyright &amp; Intellectual Property Rights</h2>
		<p>According to the law in the United States, The UK, Russia and most countries in Western Europe, copyright protection is assigned to original author of the the work.</p>
		<p>Symbols such as &copy;, tm, sm or &reg; are not required to be displayed 
		since the year 1989 according to the "Berne Convention Implementation Act" (source: <a href="http://en.wikipedia.org/wiki/Copyright" target="_blank">Copyright on Wikipedia.com</a>). 
		<p>Copyright symbols and disclaimers only further clarify who owns the copyright and whether it has been further registered or not.</p>
		<p>If a special license is granted to some portion of the content on our web site, it will be clearly labeled, 
		and the license is limited to that specific information only.</p>
		<p>We also allow freely available public search engines to index our content in order to help people find our web site, 
		but users of those search engines have no right to copy the images, text, videos or other data they find from our web site through search engines.</p>
		<h3>When in doubt, you must assume your rights to the information on this web site are limited to viewing, printing and 
		caching the information using a web browser for your non-commercial personal use only.</p>
		<p>We reserve all other rights for ourselves except where explicitly noted otherwise.</h3>
		
		<h2>Reporting Abuse of Copyright.</h2>
		<p>If you have found that our web site is violating copyright law, the terms of a license agreement or misusing trademarks, 
		please report this problem immediately to us via the form below so that we may review your claim.</p>
		<p>A valid claim must identity the original copyright holder and you must tell us the location(s) you found this information on the web site 
		including any URLs or other identifying information you can list.</p>
		<p>Please describe the requested action you want us to take.</p>
		<p>We will honor removal of any information related to a claim that 1) provides reasonable evidence that we don't have the permission 
		to use the information and 2) if we fail to provide adequate evidence to deny the claim.</p>
		<p>The information you submit on this form will solely be used by the web developer and web site owner for the purpose of resolving the claim.</p>
		<p>We ask that you provide us a reasonable amount of time to respond and/or make corrections.</p>
		<p>Make sure your contact information is accurate, we are not able to respond to claims with incorrect contact information.</p>
		<h3>Copyright Abuse Form</h3>
		<p>* Denotes required field.</p>
		<cfscript>
		form.set9=application.zcore.functions.zGetHumanFieldIndex();
		</cfscript>
		<form class="zFormCheckDirty" id="myForm" action="/z/misc/system/processCopyrightAbuse" onsubmit="zSet9('zset9_#form.set9#');" method="post">
		<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
		#application.zcore.functions.zFakeFormFields()#
		<table class="zinquiry-form-table">
		<tr>
		    <th>First Name: *</th>
		    <td><input name="inquiries_first_name" id="inquiries_first_name" type="text" style="width:96%;" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_first_name')#" /></td>
		</tr>
		<tr>
		    <th>Last Name: *</th>
		    <td><input name="inquiries_last_name" type="text" style="width:96%;" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_last_name')#" /></td>
		</tr>
		<tr ><th>Company:</th>
		<td><input type="text" class="textinput" name="inquiries_company" style="width:96%;" maxlength="100" value="#application.zcore.functions.zso(form, 'inquiries_company')#" /></td></tr>
		<tr>
		    <th>Email: *</th>
		    <td><input name="inquiries_email" type="text" style="width:96%;" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_email')#" /></td>
		</tr>
		<tr>
		    <th>Phone: *</th>
		    <td><input name="inquiries_phone1" type="text" style="width:96%;" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_phone1')#" /></td>
		</tr>
	    <tr><th style="vertical-align:top; width:90px; ">Comments: *
	    </th><td>
	    <textarea name="inquiries_comments" cols="50" rows="5" style="width:96%; height:100px;">#application.zcore.functions.zso(form, 'inquiries_comments')#</textarea>
	    
	    </td></tr>
		<cfif application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1>
			<tr>
			<td>&nbsp;</td>
				<td>
				#application.zcore.functions.zDisplayRecaptcha()#
				</td>
			</tr>
		</cfif>
	
		<tr>
		<td>&nbsp;</td>
			<td><button type="submit" name="submit">Submit</button></td>
	        </tr>
		</table>
		</form>
	</cfif>
	
</cffunction>

<cffunction name="processCopyrightAbuse" localmode="modern" access="remote">
	<cfscript>
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',false,0);
 	/*if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
 		application.zcore.functions.z404("Invalid request");
 	}*/
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){ 
 		application.zcore.functions.z404("Invalid request");
	}
	if(application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1){
		if(not application.zcore.functions.zVerifyRecaptcha()){
			application.zcore.status.setStatus(request.zsid, "The ReCaptcha security phrase wasn't entered correctly. Please try again.", form, true);
			application.zcore.functions.zRedirect("/z/misc/system/legal?modalpopforced=#form.modalpopforced#");
		}
	}
	if(not application.zcore.functions.zEmailValidate(application.zcore.functions.zso(form, 'inquiries_email'))){
		application.zcore.status.setStatus(request.zsid, "A valid email address is required.", form, true);
		application.zcore.functions.zRedirect("/z/misc/system/legal?modalpopforced=#form.modalpopforced#");
	}
	cc=application.zcore.functions.zvarso('zofficeemail');

	mail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" 
	cc="#cc#" replyto="#application.zcore.functions.zso(form, 'inquiries_email')#" 
	subject="Copyright Abuse Submission on #request.zos.globals.shortDomain#"{
		echo('The copyright abuse form has been submitted from the following URL:'&chr(10));
		echo('#request.zos.currentHostName#/z/misc/system/legal'&chr(10)&chr(10));
		echo('First Name: '&application.zcore.functions.zso(form, 'inquiries_first_name')&chr(10));
		echo('Last Name: '&application.zcore.functions.zso(form, 'inquiries_last_name')&chr(10));
		echo('Phone: '&application.zcore.functions.zso(form, 'inquiries_phone1')&chr(10));
		echo('Email: '&application.zcore.functions.zso(form, 'inquiries_email')&chr(10));
		echo('Comments: '&application.zcore.functions.zso(form, 'inquiries_comments')&chr(10));
		echo('Ip Address: '&request.zos.cgi.remote_addr&chr(10));
		echo('Date: '&dateformat(now(), 'm/d/yyyy')&' '&timeformat(now(), 'h:mm tt')&chr(10)&chr(10));
		echo('This information has been sent to the web developer and the list of email addresses which are assigned to receive inquiries from this web site.'&chr(10)&chr(10));
		echo('The web developer requires the web site account owner to make an initial reply to all parties regarding this inquiry ');
		echo('within 5 business days or the web developer will attempt to resolve the matter as it sees fit and charge the ');
		echo('client for any costs associated with resolving the claim.  If you are not the web site account owner, ');
		echo('please forward this email to them immediately.');
	}
	application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#");
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRules" localmode="modern" access="remote">
	<cfscript>
if(structkeyexists(form, 'zforceapplicationurlrewriteupdate')){
    application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
}
</cfscript>Done.<cfscript>application.zcore.functions.zabort();</cfscript>
</cffunction>

<cffunction name="logJavascriptError" localmode="modern" access="remote">
    <cfscript>
	form.errorStacktrace=application.zcore.functions.zso(form, 'errorStacktrace');
	form.errorMessage=application.zcore.functions.zso(form, 'errorMessage');
	form.errorURL=application.zcore.functions.zso(form, 'errorUrl');
	form.requestURL=application.zcore.functions.zso(form, 'requestURL');
	form.errorLineNumber=application.zcore.functions.zso(form, 'errorLineNumber');
	form.errorObj=application.zcore.functions.zso(form, 'errorObj');
	if(form.errorMessage NEQ ""){
		var ts={
			type:'javascript-error',
			scriptName: form.errorURL,
			lineNumber: form.errorLineNumber, 
			url:form.requestURL,
			exceptionMessage: form.errorMessage
		}
		if(left(ts.url, 1) EQ "/"){
			ts.url=request.zos.currentHostName&ts.url;
		}
		if(left(ts.scriptName, 1) EQ "/"){
			ts.scriptName=request.zos.currentHostName&ts.scriptName;
		}
		savecontent variable="ts.errorHTML"{
			echo("Error Message: "&application.zcore.functions.zParagraphFormat(form.errorMessage)&'<br />');
			echo("Line Number: "&form.errorLineNumber&'<br />');
			if(form.errorObj NEQ ""){
				echo("Error Object:"&form.errorObj&"<br />");
			}
			if(form.errorStacktrace NEQ ""){
				echo("Stacktrace: "&application.zcore.functions.zParagraphFormat(form.errorStacktrace)&'<br />');
			}
		}
		application.zcore.functions.zLogError(ts);
		application.zcore.functions.zReturnJson({success:true});
	}
	application.zcore.functions.zReturnJson({success:false});
	</cfscript>
</cffunction>
	
	
<cffunction name="getSplitTemplate" localmode="modern" access="remote" hint="Currently used for ssi template generation.">
	<cfscript>
	application.zcore.functions.zDisableContentTransition();
	request.zPageDebugDisabled=true;
	writeoutput('~SSISPLIT~');
	</cfscript>
</cffunction>

<cffunction name="ext" localmode="modern" access="remote" hint="This function forwards user to new url, but has some security added to prevent an open redirect attack.">
	<cfscript>
	request.znotemplate=true;
	application.zcore.tracking.backOneHit();
	application.zcore.functions.zModalCancel();
	// form.n is a url
	link=application.zcore.functions.zso(form, 'n');
	form.k=application.zcore.functions.zso(form, 'k');
	verifyK=hash(request.zos.redirectSecretKey&link); 
	if(compare(form.k, verifyK) NEQ 0){
		application.zcore.functions.z404("Sorry, this redirect link has expired.");
	}
	if(left(link,1) EQ "/"){
		application.zcore.functions.zRedirect(link);
	}else if(left(link,7) NEQ "http://" and left(link,8) NEQ "https://"){
		application.zcore.functions.z301redirect('/');	
	}else{
		application.zcore.functions.zRedirect(link);	
	}
	</cfscript>
</cffunction>

<cffunction name="missing" localmode="modern" access="remote">
	
	<cfscript>
	application.zcore.template.setTag("title",'Sorry, this page no longer exists.');
	application.zcore.template.setTag("pagetitle",'Sorry, this page no longer exists.');
	//application.zcore.template.setTag("meta",tempMeta);
	//application.zcore.template.setTag("pagenav",tempPageNav);

	if(application.zcore.app.siteHasApp("content")){
		ts=structnew();
		ts.content_unique_name='/z/misc/system/missing'; 
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		if(not r1){
			echo('Please browse our site or go back and try a different link.<br /><br />');
		}
	}else{
		echo('Please browse our site or go back and try a different link.<br /><br />');
	}
	</cfscript>
</cffunction>


<cffunction name="checkHealth" localmode="modern" access="remote">
	<cfscript>
	if(structkeyexists(application.zcore, 'serverDown')){
		if(structkeyexists(request.zsession, 'forceHealthFailure')){
			application.zcore.functions.z404("Server is down due to turning on force health failure in debug toolbar.");
		}else{
			application.zcore.functions.z404("Server is down.");
		}
	}else{
		echo("OK");
		abort;
	}
	</cfscript>

</cffunction>

<cffunction name="checkHealth2" localmode="modern" access="remote">
	<cfscript>
	if(structkeyexists(application.zcore, 'serverDown2')){
		if(structkeyexists(request.zsession, 'forceHealthFailure2')){
			application.zcore.functions.z404("Server is down due to turning on force health failure in debug toolbar (2).");
		}else{
			application.zcore.functions.z404("Server is down (2).");
		}
	}else{
		echo("OK");
		abort;
	}
	</cfscript>

</cffunction>

<cffunction name="getConversionCode" localmode="modern" access="remote">
	<cfscript>
  	application.zcore.functions.zheader("x_ajax_id", application.zcore.functions.zso(form, 'x_ajax_id'));
	echo(application.zcore.functions.zvarso('Lead Conversion Tracking Code'));
	abort;
</cfscript>
</cffunction>



<cffunction name="redirectToLink" localmode="modern" access="remote">
	<cfscript>
	form.short_link_id=application.zcore.functions.zso(form, 'short_link_id', true, 0);
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("short_link", request.zos.zcoreDatasource)# WHERE 
	short_link_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	short_link_id=#db.param(form.short_link_id)#";
	qLink=db.execute("qLink");
	if(qLink.recordcount EQ 0){
		application.zcore.functions.z301Redirect("/");
	} 
	application.zcore.tracking.backOneHit(); 
	application.zcore.functions.z301Redirect(qLink.short_link_url);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>