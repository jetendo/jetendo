<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" returntype="any">
	<cfscript>
	request.zsession.zPopinquiryPopCompleted=true;
	if(application.zcore.app.siteHasApp("listing") EQ false){
		application.zcore.functions.z404('listing app not enabled');	
	}
	if(application.zcore.app.siteHasApp("content") EQ false){
		application.zcore.functions.z301redirect('/');	
	}
	Request.zPageDebugDisabled=true;
	application.zcore.tracking.backOneHit();
	form.modalpopforced=1;//application.zcore.functions.zso(form, 'modalpopforced');
	form.action=application.zcore.functions.zso(form, 'action',false,'form');
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zSetModalWindow();
	}
	</cfscript>
</cffunction>

<cffunction name="send" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var arrName=0;
	var ts=0;
	var rs=0;
	variables.init();
	form.inquiries_spam=0;
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		form.inquiries_spam=1;
		form.inquiries_spam_description="Fake form fields not empty"; 
		//application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#");
	}
	/*if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		form.inquiries_spam=1; 
		form.inquiries_spam_description="zset9 was wrong";
		//application.zcore.functions.zredirect('/');
	}*/
	if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
		form.inquiries_spam=1; 
		form.inquiries_spam_description="js3811 value not set"; 
		//writeoutput('~n~');application.zcore.functions.zabort();
	}
	if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
		form.inquiries_spam=1; 
		form.inquiries_spam_description="Form hash value was wrong"; 
		//application.zcore.status.setStatus(request.zsid, "Your session has expired.  Please submit the form again.",form,true);
		//application.zcore.functions.zRedirect("/z/listing/inquiry-pop/index?zsid="&request.zsid);
	}
	request.zsession.zPopinquiryPopSent=true;
	form.inquiries_datetime=request.zos.mysqlnow;
	form.inquiries_email=application.zcore.functions.zso(form, 'email');
	if(application.zcore.functions.zEmailValidate(form.inquiries_email) EQ false){
		application.zcore.status.setStatus(request.zsid, "Invalid email address.", form,true);
		application.zcore.functions.zRedirect("/z/listing/inquiry-pop/index?zsid=#request.zsid#");	
	}
	form.inquiries_phone1=application.zcore.functions.zso(form, 'phone');
	arrName=listtoarray(application.zcore.functions.zso(form, 'name')," ");
	if(arraylen(arrName) NEQ 0){
		form.inquiries_first_name=arrName[1];
		arraydeleteat(arrName,1);
		form.inquiries_last_name=arraytolist(arrName," ");
	}
	form.inquiries_price_low=application.zcore.functions.zso(form, 'inquiries_price_low');
	form.inquiries_price_high=application.zcore.functions.zso(form, 'inquiries_price_high');
	form.inquiries_bedrooms=application.zcore.functions.zso(form, 'bedrooms');
	form.inquiries_bathrooms=application.zcore.functions.zso(form, 'bathrooms');
	form.inquiries_sqfoot=application.zcore.functions.zso(form, 'sqft');
	form.inquiries_when_move=application.zcore.functions.zso(form, 'timeframe');
	if(application.zcore.functions.zso(form, 'pool') EQ "yes"){
		form.inquiries_pool=1;
	}else{
		form.inquiries_pool=0;
	}
	form.inquiries_garage=application.zcore.functions.zso(form, 'garage');
	form.inquiries_comments="";//"Under Market Value Email Alert Sign Up.#chr(10)# Interested in receiving these types of listings: ";
	/*if(application.zcore.functions.zso(form, 'Foreclosures') EQ 1){
		form.inquiries_comments&=" Foreclosures, ";
	}
	if(application.zcore.functions.zso(form, 'BankOwned') EQ 1){
		form.inquiries_comments&=" Bank Owned, ";
	}
	if(application.zcore.functions.zso(form, 'ShortSales') EQ 1){	
		form.inquiries_comments&=" Short Sales, ";
	}*/
	if(application.zcore.functions.zso(form, 'timeframe') NEQ ""){	
		form.inquiries_comments&=chr(10)&" Buying:  "&form.timeframe;
	}
	form.inquiries_session_id=application.zcore.session.getSessionId();
	form.inquiries_comments&="#chr(10)#Comments: "&application.zcore.functions.zso(form, 'comments'); 
	form.inquiries_type_id = 10;
	form.inquiries_type_id_siteIdType=4;
	form.inquiries_status_id = 1;
	form.site_id = request.zOS.globals.id; 
	form.inquiries_id=application.zcore.functions.zInsertLead();
	
	ts=structnew();
	ts.name="zPOPInquiryCompleted";
	ts.value="1";
	ts.expires="never";
	application.zcore.functions.zCookie(ts);
	
	application.zcore.tracking.setUserEmail(form.inquiries_email);
	application.zcore.tracking.setConversion('inquiry pop',form.inquiries_id);
	
	if(application.zcore.functions.zso(form, 'inquiries_email') EQ "" or application.zcore.functions.zEmailValidate(form.inquiries_email) EQ false){
		form.inquiries_email=request.fromemail;
	} 
	form.contact_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew()));
	ts=structnew();
	ts.inquiries_id=form.inquiries_id;
	ts.subject="Pop-up lead capture form submitted on #request.zos.currentHostName#";
	// send the lead
	rs=application.zcore.functions.zAssignAndEmailLead(ts);
	if(rs.success EQ false){
		// failed to assign/email lead
		//zdump(rs);
	} 
	application.zcore.functions.zredirect('/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#');
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var inquiryTextMissing=0;
	var r1=0;
	var ts=0;
	var db=request.zos.queryObject;
	init();
	inquiryTextMissing=false;
	ts=structnew();
	ts.content_unique_name='/z/listing/inquiry-pop/index';
	ts.disableLinks=true;
	r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
	if(r1 EQ false){
		inquiryTextMissing=true;
	}
	</cfscript>
	<cfif inquiryTextMissing>

		<cfscript>
		application.zcore.template.setTag("title","Find the hottest new listings");
		application.zcore.template.setTag("pagetitle","Find the hottest new listings"); 
		application.zcore.functions.zStatusHandler(Request.zsid, true);
		</cfscript>
		We can help you find the best deals on real estate.
		<!---  Submit the form below to begin receiving our affordable homes newsletter. --->
 	</cfif>

	<cfif application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1>
		<script type="text/javascript">/* <![CDATA[ */
		function checkit2(){
			if(document.getElementById('name').value == '' || document.getElementById('Email').value == '' || document.getElementById('Phone').value == ''){
				alert('Name, Email and Phone are required fields.');	
				return false;
			}
			return true;
		}/* ]]> */
		</script>
	<cfelse>
		<script type="text/javascript">/* <![CDATA[ */
		function checkit2(){
			if(document.getElementById('name').value == '' || document.getElementById('Email').value == ''){
				alert('Name and Email are required fields.');	
				return false;
			}
			return true;
		}/* ]]> */
		</script>
	</cfif>
	<cfscript>application.zcore.template.appendtag("meta",'<style type="text/css">
	/* <![CDATA[ */ html,body{border:0px; margin:0px; border-collapse:collapse;}
	h1{padding:0px; margin:0px;} 
	form{margin:0px; padding:0px;} /* ]]> */
	</style>');
	form.set9=application.zcore.functions.zGetHumanFieldIndex(); 
	</cfscript>
	<form class="zFormCheckDirty" action="/z/listing/inquiry-pop/send" method="post" id="name22" style="margin:0px; padding:0px;padding-top:5px;"  onsubmit="zSet9('zset9_#form.set9#');return checkit2();">
	<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
	 #application.zcore.functions.zFakeFormFields()#
	<cfscript>application.zcore.template.appendTag("meta",'<style type="text/css">	/* <![CDATA[ */ select, input, textarea, .tinypop td{ font-size:11px; line-height:14px; } /* ]]> */	</style>');
	</cfscript>
  
	<table style="border-spacing:4px;width:450px;" class="tinypop">
	
	<!--- <tr>
	<td colspan="4" >I am Interested in: 
	
	<input type="checkbox" name="Foreclosures" id="Foreclosures2" value="1" />
	Foreclosures 
	<input type="checkbox" name="BankOwned" id="BankOwned" value="1" />
	Bank Owned
	<input type="checkbox" name="ShortSales" id="Short" value="1" /> 
	Short Sales</td>
	</tr> --->
	<tr>
	<td>City:</td>
	<td>
	<input type="text" name="inquiries_city" value="#application.zcore.functions.zso(form, 'inquiries_city')#" />
	</td>
	<td>Type:</td>
	<td> 
	<cfscript>
	ts = StructNew();
	ts.name = "inquiries_property_type";
	ts.listLabels = "Single Family,Townhouse,Condo,Land,Commercial,No Preference";
	ts.listValues = ts.listLabels;
	ts.listLabelsDelimiter = ","; 
	ts.listValuesDelimiter = ",";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript>  
	</td>
	</tr>
	<tr>
	<td>Min Price:
	</td>
	<td>
	<cfscript>
	ts = StructNew();
	ts.name = "inquiries_price_low";
	ts.listLabels = "$0|$25,000|$50,000|$75,000|$100,000|$125,000|$150,000|$175,000|$200,000|$250,000|$275,000|$300,000|$350,000|$400,000|$450,000|$500,000|$550,000|$600,000|$650,000|$700,000|$800,000|$900,000|$1,000,000|$1,250,000|$1,500,000|$2,000,000|$2,500,000|$3,000,000|$3,500,000|$4,000,000|$5,000,000";
	ts.listValues = ts.listLabels;
	ts.listLabelsDelimiter = "|"; 
	ts.listValuesDelimiter = "|";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript> 
	</td>
	<td>Min Bed:</td>
	<td>
	<cfscript>
	ts = StructNew();
	ts.name = "bedrooms";
	ts.listLabels = "1,2+,3+,4+,5+,6+";
	ts.listValues = ts.listLabels;
	ts.listLabelsDelimiter = ","; 
	ts.listValuesDelimiter = ",";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript>  
	</td>
	</tr>
	<tr>
	<td>Max Price: </td>
	<td>
	<cfscript>
	ts = StructNew();
	ts.name = "inquiries_price_high";
	ts.listLabels = "$0|$25,000|$50,000|$75,000|$100,000|$125,000|$150,000|$175,000|$200,000|$250,000|$275,000|$300,000|$350,000|$400,000|$450,000|$500,000|$550,000|$600,000|$650,000|$700,000|$800,000|$900,000|$1,000,000|$1,250,000|$1,500,000|$2,000,000|$2,500,000|$3,000,000|$3,500,000|$4,000,000|$5,000,000+";
	ts.listValues = ts.listLabels;
	ts.listLabelsDelimiter = "|"; 
	ts.listValuesDelimiter = "|";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript> 
	</td>
	<td>Min Bath:</td>
	<td>
	<cfscript>
	ts = StructNew();
	ts.name = "bathrooms";
	ts.listLabels = "1+,2+,3+,4+,5+";
	ts.listValues = ts.listLabels;
	ts.listLabelsDelimiter = ","; 
	ts.listValuesDelimiter = ",";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript>  
	</td>
	</tr>
	
	<tr>
	<td> Sq Feet: </td>
	<td>
	<cfscript>
	ts = StructNew();
	ts.name = "sqft";
	ts.listLabels = "Under 1000,1000+,1500+,2000+,2500+,3000+,3500+,4000+,5000+,7500+,10000+,No Preference";
	ts.listValues = ts.listLabels;
	ts.listLabelsDelimiter = ","; 
	ts.listValuesDelimiter = ",";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript> </td>
	<td>Garage:</td>
	<td><label for="garage3"></label>
	
	<cfscript>
	ts = StructNew();
	ts.name = "garage";
	ts.listLabels = "1+,2+,3+,4+";
	ts.listValues = ts.listLabels;
	ts.listLabelsDelimiter = ","; 
	ts.listValuesDelimiter = ",";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript> </td>
	</tr>
	<tr>
	<td>Buying: </td>
	<td>
	
	<cfscript>
	ts = StructNew();
	ts.name = "timeframe";
	ts.listLabels = "Immediately,1-2 Months,2-3 Months,3-6 Months,Over 6 Months";
	ts.listValues = ts.listLabels;
	ts.listLabelsDelimiter = ","; 
	ts.listValuesDelimiter = ",";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript>  
	</td>
	<td colspan="2"> Pool:
	<input type="radio" value="Yes" name="Pool" <cfif application.zcore.functions.zso(form, 'pool') EQ "Yes">checked="checked"</cfif> /> Yes 
	<input type="radio" name="Pool" value="No" <cfif application.zcore.functions.zso(form, 'pool') NEQ "Yes">checked="checked"</cfif> /> No/Maybe  
	Any</td>
	</tr>
	<tr>
	<td> Name: 
	</td>
	<td>
	<input name="name" type="text" class="formtxt" id="name" value="<cfif application.zcore.functions.zso(form, 'name') NEQ "">#form.name#<cfelseif not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_first_name')# #application.zcore.functions.zso(request.zsession, 'inquiries_last_name')#</cfif>" />
	</td>
	<td style="vertical-align:top;" colspan="2" rowspan="3">Additional Features/Comments:
	<label for="comments"></label>
	<textarea name="comments" id="comments" cols="27" rows="3">#application.zcore.functions.zso(form, 'comments')#</textarea>
	</td>
	</tr>
	<tr>
	<td> Phone: 
	</td>
	<td>
	<input name="Phone" id="Phone" type="text" class="formtxt" value="<cfif application.zcore.functions.zso(form, 'phone') NEQ "">#form.phone#<cfelseif not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_phone1')#</cfif>" />
	</td>
	</tr>
	<tr>
	<td> Email: 
	
	</td>
	<td>
	<input name="Email" type="text" class="formtxt" id="Email" value="<cfif application.zcore.functions.zso(form, 'email') NEQ "">#form.email#<cfelseif not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_email')#</cfif>" />
	</td>
	</tr>
	<tr><td colspan="4"><input type="submit" style="font-size:14px; padding:5px; line-height:14px;" name="search1" value="Submit" /> 
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_inquiry_pop_forced EQ 0>
	<input type="button" name="cancel1" value="No Thanks" onclick="window.parent.zCloseModal();" /> </cfif> | 
	<a href="/z/user/privacy/index" rel="external" onclick="window.open('/z/user/privacy/index');return false;" class="zPrivacyPolicyLink">Privacy Policy</a></td></tr>
	<tr><td colspan="4">
        <div class="zPrivacyPolicyMessage">
   			#application.zcore.functions.zvarso("Form Privacy Message")#
		</div></td></tr>
	</table>
	
	
		<input type="hidden" name="js3811" id="js3811" value="" />
		<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
	</form>
</cffunction>
</cfoutput>
</cfcomponent>
