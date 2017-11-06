<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
<cfscript>
var tempPageNav=0;
var ts=0;
var tempTitle=0;
var selectStruct=0;
var qInquiries=0;
var tempMeta=0;
		var db=request.zos.queryObject;
form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
if(form.modalpopforced EQ 1){
	application.zcore.template.setTag("pagetitle","Free Mortgage Quote");
	application.zcore.template.setTag("title","Free Mortgage Quote");
	application.zcore.functions.zSetModalWindow();
}
</cfscript> 
<cfsavecontent variable="tempPageNav">
<a href="/">Home</a> / 
</cfsavecontent>
<cfsavecontent variable="tempMeta">
<meta name="Keywords" content="free mortgage quote home loan equity" />
<meta name="Description" content="Submit our form and we'll find the lowest rate for your new mortgage." />
</cfsavecontent>
<cfif form.modalpopforced NEQ 1>
<cfscript>
tempTitle = 'Free Mortgage Quote';
application.zcore.template.setTag("title",tempTitle);
application.zcore.template.setTag("pagetitle",tempTitle);
application.zcore.template.setTag("meta",tempMeta);
application.zcore.template.setTag("pagenav",tempPageNav);
if(application.zcore.app.siteHasApp("content")){
	ts=structnew();
	ts.content_unique_name='/z/misc/mortgage-quote/index';
	application.zcore.app.getAppCFC("content").includePageContentByName(ts);
}else{
	writeoutput('<p>Shopping for a great deal on a home loan? Compare mortgage rates from top national lenders with our custom mortgage quotes.</p><p>Submit our form and we''ll find the lowest rate for your new mortgage.</p>');	
}
</cfscript>
</cfif>
<cfscript>
application.zcore.template.setTag("pagenav",tempPageNav);
</cfscript>

    <cfsavecontent variable="db.sql">
    SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE inquiries_id = #db.param(-1)# and 
	site_id = #db.param('0')# and 
	inquiries_deleted = #db.param(0)#
    </cfsavecontent>
	<cfscript>
    qInquiries=db.execute("qInquiries");
    
    application.zcore.functions.zQueryToStruct(qInquiries, form);
    application.zcore.functions.zStatusHandler(request.zsid, true);
    
	form.set9=application.zcore.functions.zGetHumanFieldIndex();
	</cfscript>
            <p>* denotes required field.</p>
	<form class="zFormCheckDirty" id="myForm" action="/z/misc/mortgage-quote/send" method="post" onsubmit="zSet9('zset9_#form.set9#');" style="margin:0px; padding:0px;">
    <input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
    #application.zcore.functions.zFakeFormFields()#
<table style="border-spacing:0px; width:98%;" class="zinquiry-form-table">
	<tr>
		<td>First Name<span class="highlight"> *</span></td>
		<td><input name="inquiries_first_name" type="text" size="30" style="width:100%" maxlength="50" value="#form.inquiries_first_name#" /></td>
	</tr>
	<tr>
		<td>Last Name</td>
		<td><input name="inquiries_last_name" type="text" size="30" style="width:100%" maxlength="50" value="#form.inquiries_last_name#" /></td>
	</tr>
	<tr>
		<td>Email <cfif structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1><span class="highlight"> *</span> </cfif></td>
		<td><input name="inquiries_email" type="text" size="30" style="width:100%" maxlength="50" value="#form.inquiries_email#" /></td>
	</tr>
	<tr>
		<td>Phone<cfif application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1><span class="highlight"> * </span></cfif></td>
		<td><input name="inquiries_phone1" type="text" size="30" style="width:100%" maxlength="50" value="#form.inquiries_phone1#" /></td>
	</tr>
		  <tr><td>
		Address</td>
		<td><input type="text" name="inquiries_property_address" style="width:100%" value="#htmleditformat(form.inquiries_property_address)#" /> <!--- * required --->
		  </td>
		  </tr>
		  <tr><td>
		City Name</td>
		<td><input type="text" name="inquiries_city" style="width:100%" value="#htmleditformat(form.inquiries_city)#" /> <!--- * required --->
		  </td>
		  </tr>
		  <tr><td>
		State</td>
		<td><input type="text" name="inquiries_state" style="width:100%" value="#htmleditformat(form.inquiries_state)#" /> 
		  </td>
		  </tr>
		  <tr><td>
		ZIP Code</td>
		<td><input type="text" name="inquiries_zip" style="width:100%" value="#htmleditformat(form.inquiries_zip)#" /> <!--- * required --->
		  </td>
		  </tr>
		<tr><td>&nbsp;
		</td>
		<td>
			<p>Please type the city/state of the new property's location:</p> 
			<p><input type="text" name="inquiries_loan_city" style="width:100%" value="#htmleditformat(form.inquiries_loan_city)#" /></p>
		</td>
		</tr>
		<tr><td>&nbsp;
		</td>
		<td>
		<p>Do you currently own or rent your home?</p>
		<p><input type="radio" name="inquiries_loan_own" value="own" style="border:none; background:none;" /> Own <input type="radio" name="inquiries_loan_own" value="rent" style="border:none; background:none;" /> Rent</p></td>
		
		  </tr>
		  <tr><td>
		Purchase Price</td>
		<td><input type="text" name="inquiries_loan_price" style="width:100%" value="#htmleditformat(form.inquiries_loan_price)#" />
		  </td>
		  </tr>
		  <tr><td>
		Loan Amount</td>
		<td><input type="text" name="inquiries_loan_amount" style="width:100%" value="#htmleditformat(form.inquiries_loan_amount)#" />
		  </td>
		  </tr>
		  <tr><td>
		Loan Program</td>
		<td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_loan_program";
			selectStruct.selectLabel = "Select";
			selectStruct.listValues = "30 Year Fixed,20 Year Fixed,15 Year Fixed,Adjustable,FHA/VA";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript>
		  </td>
		  </tr>
		  <tr><td>
		Property Use</td>
		<td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_loan_property_use";
			selectStruct.selectLabel = "Select";
			selectStruct.listValues = "Primary Residence,Second Home,Rental,Investment";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript>
		  </td>
		  </tr>
		  <tr><td>
		Property Type</td>
		<td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_loan_property_type";
			selectStruct.selectLabel = "Select";
			selectStruct.listValues = "Single Family,Condo/Town Home,Vacant Land";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript>
		  </td>
		  </tr>
	<tr>
		<td style="vertical-align:top; ">Comments:</td>
		<td><textarea name="inquiries_comments" cols="50" rows="5">#form.inquiries_comments#</textarea></td>
	</tr>	
<tr><td>&nbsp;</td>
	<td>
	<button type="submit" name="submit">Submit Request For Free Quote</button><br />
<br /> 
        <div class="zPrivacyPolicyMessage">
   			#application.zcore.functions.zvarso("Form Privacy Message")#
		</div>
</td>
	</tr>
	</table>
    <cfif form.modalpopforced EQ 1>
	<input type="hidden" name="modalpopforced" value="1" />
	<input type="hidden" name="js3811" id="js3811" value="" />
	<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
    </cfif>
	</form>
    
</cffunction>


<cffunction name="send" localmode="modern" access="remote" output="no" returntype="any">
	
	<cfscript>
	var toEmail=0;
	var myForm={};
	var result=0;
	var inputStruct=0;
	var ts=0;
	var rs=0;
		var db=request.zos.queryObject;
	form.inquiries_spam=0;
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
    if(form.modalpopforced EQ 1){
		if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
			form.inquiries_spam=1; 
			form.inquiries_spam_description="js3811 value not set"; 
			//writeoutput('~n~');	application.zcore.functions.zabort();
		}
		if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
			form.inquiries_spam=1; 
			form.inquiries_spam_description="Form hash value was wrong"; 
			//application.zcore.status.setStatus(request.zsid, "Your session has expired.  Please submit the form again.",form,true);
			//application.zcore.functions.zRedirect("/z/misc/mortgage-quote/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
		}
    }
	toEmail = request.officeEmail;
	// form validation struct
	if(structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1){
		myForm.inquiries_email.required = true;
		myForm.inquiries_email.friendlyName = "Email Address";
		myForm.inquiries_email.email = true;
	}
	//myForm.inquiries_zip.required = true;
	//myForm.inquiries_zip.friendlyName = "Zip Code";	
	//myForm.inquiries_city.required = true;
	//myForm.inquiries_city.friendlyName = "City";	
	//myForm.inquiries_property_address.required = true;
	//myForm.inquiries_property_address.friendlyName = "Address";
	myForm.inquiries_first_name.required = true;
	myForm.inquiries_first_name.friendlyName = "First Name";
	if(application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1){
		myForm.inquiries_phone1.required = true;
		myForm.inquiries_phone1.friendlyName = "Phone";
	}
	myForm.inquiries_datetime.createDateTime = true;
	form.inquiries_type_id = 7;
	form.inquiries_type_id_siteIdType=4;
	form.inquiries_status_id = 1;
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/misc/mortgage-quote/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
	}
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		
		form.inquiries_spam=1;
		form.inquiries_spam_description="Fake form fields not empty"; 
		//application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#&zsid="&request.zsid);
	}
	/*if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		form.inquiries_spam=1; 
		form.inquiries_spam_description="zset9 was wrong";
		//application.zcore.functions.zredirect('/');
	}*/
	if(Find("@", form.inquiries_first_name) NEQ 0){
		form.inquiries_spam=1;
		form.inquiries_spam_description="@ symbol in first name";
		//application.zcore.status.setStatus(Request.zsid, "Invalid Request",form,true);
		//application.zcore.functions.zRedirect("/z/misc/mortgage-quote/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
	}
	if(structkeyexists(form, 'inquiries_comments') and (findnocase("[/url]", form.inquiries_comments) NEQ 0 or findnocase("http://", form.inquiries_comments) NEQ 0)){
		form.inquiries_spam=1;
		form.inquiries_spam_description="Comment had a url in it";
		//application.zcore.status.setStatus(Request.zsid, "Invalid Request",form,true);
		//application.zcore.functions.zRedirect("/z/misc/mortgage-quote/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
	}
	form.property_id=''; 
	form.inquiries_session_id=application.zcore.session.getSessionId();
	form.site_id=request.zos.globals.id;
//	Insert Into Inquiry Database
	inputStruct = StructNew();
	if(application.zcore.app.siteHasApp("content")){ 
		form.inquiries_id=application.zcore.functions.zInsertLead();
	}else{ 
		inputStruct={}; // goes in the site datasource
		inputStruct.table = "inquiries";
		inputStruct.struct=form; 
		form.inquiries_id = application.zcore.functions.zInsert(inputStruct);  
	}
	if(form.inquiries_id EQ false){
		application.zcore.status.setStatus(Request.zsid, "Your inquiry has not been sent due to an error.", false,true);
		application.zcore.functions.zRedirect("/z/misc/mortgage-quote/index?modalpopforced=#form.modalpopforced#&zsid="&request.zsid);
	}else{
		application.zcore.status.setStatus(Request.zsid, "Your inquiry has been sent.", false,true);
	}
	application.zcore.tracking.setUserEmail(form.inquiries_email);
	application.zcore.tracking.setConversion('mortgage quote', form.inquiries_id);
	
	form.contact_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew()));
	if(application.zcore.functions.zso(form, 'inquiries_email') EQ "" or application.zcore.functions.zEmailValidate(form.inquiries_email) EQ false){
		form.inquiries_email=request.fromemail;
	}
	//if(form.inquiries_spam EQ 0){
		ts=structnew();
		ts.inquiries_id=form.inquiries_id;
		ts.subject="New Mortgage Quote Inquiry on #request.zos.globals.shortdomain#";
		// send the lead
		rs=application.zcore.functions.zAssignAndEmailLead(ts);
		if(rs.success EQ false){
			// failed to assign/email lead
			//zdump(rs);
		}
	//}
	
    if(form.modalpopforced EQ 1){
        application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#&zsid="&request.zsid);
    }else{
        application.zcore.functions.zRedirect("/z/misc/thank-you/index?zsid="&request.zsid);
    }
    </cfscript>	
	
	
</cffunction>

</cfoutput> 
</cfcomponent>