<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',false,0);
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zSetModalWindow();
	}
	</cfscript>
</cffunction>

 
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	
	this.init();
	</cfscript>
	<cfif application.zcore.app.siteHasApp("content")>
		<cfscript>
		local.inquiryTextMissing=false;
		local.ts=structnew();
		if(form.modalpopforced EQ 1){
			local.ts.editLinksEnabled=false;
		}
		local.ts.content_unique_name='/z/misc/mailing-list/index';
		local.r1=application.zcore.app.getAppCFC("content").includePageContentByName(local.ts);
		if(local.r1 EQ false){
			local.inquiryTextMissing=true;
		}
		</cfscript>
		<cfif local.inquiryTextMissing>
			
			<cfscript>
			application.zcore.template.setTag("title","Join Our Mailing List");
			application.zcore.template.setTag("pagetitle","Join Our Mailing List");
			</cfscript>
		</cfif>
	</cfif>
	<cfscript>
	application.zcore.functions.zStatusHandler(request.zsid,true);
	
		form.set9=application.zcore.functions.zGetHumanFieldIndex();
		</cfscript>
	<form class="zFormCheckDirty" action="/z/misc/mailing-list/process" onsubmit="zSet9('zset9_#form.set9#');" method="get">
		<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" /> 
		<cfif form.modalpopforced EQ 1>
			<input type="hidden" name="modalpopforced" value="1" />
			<input type="hidden" name="js3811" id="js3811" value="" />
			<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
		</cfif>
		#application.zcore.functions.zFakeFormFields()#
	  <p>Your Email Address: 
		<input type="text" name="user_username" size="40" value="#htmleditformat(application.zcore.functions.zso(form, 'email'))#" />
		</p>
		<p>
			<input type="submit" name="submit1" value="Subscribe" />
		</p>
        <div class="zPrivacyPolicyMessage">
   			By submitting this form, you agree to receive mailing list emails from us. #application.zcore.functions.zvarso("Form Privacy Message")#
		</div>
		<p><a href="/z/user/privacy/index" class="zPrivacyPolicyLink" target="_blank">Privacy Policy</a></p>
	</form>
	
	
</cffunction>

<cffunction name="process" localmode="modern" access="remote">
	<cfscript> 
	this.init();
	form.returnJson = application.zcore.functions.zso(form, 'returnJson', true, 0);
	form.return_url = application.zcore.functions.zso(form, 'return_url');
	form.error_url=application.zcore.functions.zso(form, 'error_url');
	if(form.return_url EQ ""){
		form.return_url="/z/misc/mailing-list/thankyou?modalpopforced=#form.modalpopforced#";
	}
	if(form.error_url EQ ""){
		form.error_url="/z/misc/mailing-list/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#";
	}else{
		form.error_url=application.zcore.functions.zURLAppend(form.error_url, 'zsid=#Request.zsid#');
	}
	
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		ts={
			success:false,
			errorMessage:"Invalid request ##3."
		};
		application.zcore.functions.zReturnJson(ts);
		application.zcore.functions.zRedirect("/z/misc/mailing-list/thankyou?modalpopforced=#form.modalpopforced#");
	}

	
	if(form.modalpopforced EQ 1){
		if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
			if(form.returnJson EQ 1){
				ts={
					success:false,
					errorMessage:"Invalid request ##1."
				};
				application.zcore.functions.zReturnJson(ts);
			}
			writeoutput('~n~');application.zcore.functions.zabort();
		}
		if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
			if(form.returnJson EQ 1){
				ts={
					success:false,
					errorMessage:"Your session has expired.  Please submit the form again."
				};
				application.zcore.functions.zReturnJson(ts);
			}
			application.zcore.status.setStatus(request.zsid, "Your session has expired.  Please submit the form again.",form,true);
			application.zcore.functions.zRedirect(form.error_url);
		}
	}
	/*	if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		if(form.returnJson EQ 1){
			ts={
				success:false,
				errorMessage:"Invalid request ##2."
			};
			application.zcore.functions.zReturnJson(ts);
		}
		application.zcore.functions.zredirect('/');
	} */
	form.user_pref_list=1;
	form.inquiries_email_opt_in=1;
	form.user_first_name=application.zcore.functions.zso(form, 'user_first_name');
	form.user_last_name=application.zcore.functions.zso(form, 'user_last_name');
	form.user_username=application.zcore.functions.zso(form, 'user_username');
	if(form.user_username EQ "" or application.zcore.functions.zEmailValidate(form.user_username) EQ false){
		if(form.returnJson EQ 1){
			ts={
				success:false,
				errorMessage:"A valid email address is required."
			};
			application.zcore.functions.zReturnJson(ts);
		}
		application.zcore.status.setStatus(request.zsid, "A valid email address is required.", true);
		application.zcore.functions.zRedirect(form.error_url);	
	} 

	form.contact_id=application.zcore.user.automaticAddUser(form); 
	
	ts={
		// required
		inquiries_type_id:18, // should be "Join Our Mailing List" - You need to manually fix your db if it isn't.
		inquiries_type_id_siteidtype:4,
		to:form.user_username,
		from:request.officeEmail,
		dataStruct:{
			firstName:form.user_first_name,
			email:form.user_username,
			interestedInModel:"",  
			officeId:application.zcore.functions.zso(request, 'autoresponderOfficeId'),
			//officeName:"",
			//officeFullInfo:""
		} 
	}; 
	autoResponderCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.autoresponder");
	rs=autoResponderCom.sendAutoresponder(ts);  

	if(form.returnJson EQ 1){
		ts={
			success:true
		};
		application.zcore.functions.zReturnJson(ts);
	}
	application.zcore.functions.zRedirect(form.return_url);	
	</cfscript>
</cffunction>

<cffunction name="thankyou" localmode="modern" access="remote">
	<cfscript>
	
	this.init();
	</cfscript>
	<cfif application.zcore.app.siteHasApp("content")>
		<cfscript>
		local.inquiryTextMissing=false;
		local.ts=structnew();
		local.ts.content_unique_name='/z/misc/mailing-list/thankyou';
		local.r1=application.zcore.app.getAppCFC("content").includePageContentByName(local.ts);
		if(local.r1 EQ false){
			local.inquiryTextMissing=true;
		}
		</cfscript>
		<cfif local.inquiryTextMissing>
			
			<cfscript>
			application.zcore.template.setTag("title","Thank You For Joining Our Mailing List");
			application.zcore.template.setTag("pagetitle","Thank You For Joining Our Mailing List");
			</cfscript>
		</cfif>
	</cfif>
	
	<cfif structkeyexists(form,'modalpopforced') and form.modalpopforced EQ 1>
		<p>Closing window in 3 seconds.</p>
		<script type="text/javascript">/* <![CDATA[ */ 
		setTimeout(function(){ zCloseThisWindow(); },3000);
		/* ]]> */
		</script>
	</cfif>
	#application.zcore.functions.zVarSO("Lead Conversion Tracking Code")#
</cffunction>

<!--- 
this is for custom mailing-list forms
<cfscript>
mailingListCom=createobject("component", "zcorerootmapping.mvc.z.misc.controller.mailing-list");
ss={
	enableAjax:true,
	successURL:"/z/misc/thank-you/index",
	errorURL:"/z/misc/thank-you/error"
};
mailingListCom.outputStartForm(ss);
</cfscript>
<p>Your Email Address: 
<input type="text" name="user_username" size="40" value="#htmleditformat(application.zcore.functions.zso(form, 'email'))#" />
</p>
<p>
	<input type="submit" name="submit1" value="Subscribe" />
</p>
<div class="zPrivacyPolicyMessage">
		By submitting this form, you agree to receive mailing list emails from us. #application.zcore.functions.zvarso("Form Privacy Message")#
</div>
<p><a href="/z/user/privacy/index" class="zPrivacyPolicyLink" target="_blank">Privacy Policy</a></p>
<cfscript>
mailingListCom.outputEndForm();
</cfscript>
 --->
<cffunction name="outputStartForm" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	init();
	application.zcore.functions.zStatusHandler(request.zsid,true);

	form.set9=application.zcore.functions.zGetHumanFieldIndex();
	</cfscript>
	<script type="text/javascript">
	function zMailingListAjaxCallback(r){
		var r=eval("("+r+")"); 
		zSetDirty(false);
		if(r.success){
			var link=$("##mailingListSuccessURL").val();
			window.location.href=link;
		}else{
			alert(r.errorMessage);
		}
	}
	function zProcessMailingListAjax(){
		var postObj=zGetFormDataByFormId("mailingListForm");

		var tempObj={};
		tempObj.id="zMailingListAjax";
		tempObj.url="/z/misc/mailing-list/process";
		tempObj.callback=zMailingListAjaxCallback;
		tempObj.cache=false;
		tempObj.postObj=postObj;
		tempObj.method="post";
		zAjax(tempObj);
	}
	</script>
	<form class="zFormCheckDirty" id="mailingListForm" action="/z/misc/mailing-list/process" onsubmit="zSet9('zset9_#form.set9#'); <cfif application.zcore.functions.zso(ss, 'enableAjax', false, false)>zProcessMailingListAjax(); return false; </cfif>" method="post">
		<input type="hidden" name="returnJson" value="<cfif application.zcore.functions.zso(ss, 'enableAjax', false, false)>1<cfelse>0</cfif>" />
		<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
		<input type="hidden" name="success_url" id="mailingListSuccessURL" value="#ss.successURL#">
		<input type="hidden" name="error_url" value="#ss.errorURL#">
		<cfif form.modalpopforced EQ 1>
			<input type="hidden" name="modalpopforced" value="1" />
			<input type="hidden" name="js3811" id="js3811" value="" />
			<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
		</cfif>
		#application.zcore.functions.zFakeFormFields()#
</cffunction>

<cffunction name="outputEndForm" localmode="modern" access="public">
	</form>
</cffunction>

</cfoutput>
</cfcomponent>