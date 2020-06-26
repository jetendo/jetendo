<cfcomponent> 
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
        form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
	application.zcore.template.setTag("pagetitle","Sign-up for new listing email alerts");
	application.zcore.template.setTag("title","Sign-up for new listing email alerts");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" returntype="any"> 
	<cfscript>
	var ts=0;
	var theFinalHTML=0;
	var r1=0;
	var i=0;
	var ss=0;
	variables.init();
        if(form.modalpopforced EQ 1){
		application.zcore.functions.zSetModalWindow();
        }else{ 
		ts=structnew();
		ts.content_unique_name='/z/listing/new-listing-email-signup/index';
		ts.disableContentMeta=false;
		ts.disableLinks=true;
		ts.showmlsnumber=true; 
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		application.zcore.template.prependTag('meta','<meta name="robots" content="noindex,follow" />'); 
	}
	application.zcore.functions.zstatushandler(request.zsid, true);
	</cfscript>
	<cfsavecontent variable="request.theSearchFormTemplate">
	
            <cfscript>
            form.set9=application.zcore.functions.zGetHumanFieldIndex();
            </cfscript>
            <form class="zFormCheckDirty" id="myForm" action="/z/listing/new-listing-email-signup/process" onsubmit="zSet9('zset9_#form.set9#');" method="post" style="margin:0px; padding:0px;">
            <input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
            #application.zcore.functions.zFakeFormFields()# 
<script>/* <![CDATA[ */ zArrDeferredFunctions.push(function(){zFormData["zMLSSearchForm"]=new Object(); zFormData["zMLSSearchForm"].arrFields=[]; });/* ]]> */</script>
	<p>* Denotes required field.</p>
	<div style="float:left; width:100%; padding-bottom:20px; "> 
	<table style="border-spacing:0px;" class="table-list">
	<cfif isDefined('request.zsession.user.id')>
		<tr><td style="vertical-align:top;">Email Address:</td>
		<td>Logged in as #request.zsession.user.email#<br />
		Want to use a different account? <a href="#request.cgi_script_name#?zlogout=1">Click Here to Logout</a>
		<input type="hidden" name="saved_search_email" value="#request.zsession.user.email#" /></td>
		</tr>
	<cfelse>
            <tr>
                <th>First Name: *</th>
                <td><input name="inquiries_first_name" aria-label="First Name" type="text" style="max-width:300px;" maxlength="50" value="<cfif application.zcore.functions.zso(form,'inquiries_first_name') EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_first_name')#<cfelse>#application.zcore.functions.zso(form,'inquiries_first_name')#</cfif>" /></td>
            </tr>
            <tr>
                <th>Last Name: *</th>
                <td><input name="inquiries_last_name" aria-label="Last Name" type="text" style="max-width:300px;" maxlength="50" value="<cfif application.zcore.functions.zso(form,'inquiries_last_name') EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_last_name')#<cfelse>#application.zcore.functions.zso(form, 'inquiries_last_name')#</cfif>" /></td>
            </tr>
		<tr><td style="vertical-align:top;">Email Address: *</td>
		<td><input type="text" name="saved_search_email" aria-label="Email Address" style="max-width:300px;" value="<cfif isDefined('request.zsession.saved_search_email')>#request.zsession.saved_search_email#<cfelseif not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_email')#</cfif>" />
		</td>
		</tr>
            <tr>
                <th>Phone: <cfif application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1>*</cfif></th>
                <td><input name="inquiries_phone1" aria-label="Phone" type="text" style="max-width:300px;" maxlength="50" value="<cfif application.zcore.functions.zso(form,'inquiries_phone1') EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_phone1')#<cfelse>#application.zcore.functions.zso(form, 'inquiries_phone1')#</cfif>" /></td>
            </tr>
	</cfif> 
	<tr>
	<td>Format:</td>
	<td><input type="radio" aria-label="Format" name="saved_search_format" value="1" style="background:none; border:0px; " <cfif application.zcore.functions.zso(form, 'saved_search_format') EQ '1' or application.zcore.functions.zso(form, 'saved_search_format') EQ ''>checked="checked"</cfif> /> <label for="saved_search_format1">HTML Text w/Photos</label> 
		<input type="radio" name="saved_search_format" id="saved_search_format0" value="0" <cfif application.zcore.functions.zso(form, 'saved_search_format') EQ '0'>checked="checked"</cfif> style="background:none; border:0px; " /> <label for="saved_search_format0">Plain Text</label></td>
	</tr>
	<tr>
	<td>Frequency:</td>
	<td><input type="radio" name="saved_search_frequency" id="saved_search_frequency0" value="0" style="background:none; border:0px; " <cfif application.zcore.functions.zso(form, 'saved_search_frequency') EQ '0' or application.zcore.functions.zso(form, 'saved_search_frequency') EQ ''>checked="checked"</cfif> /> <label for="saved_search_frequency0">Every Day</label> 
		<input type="radio" name="saved_search_frequency" id="saved_search_frequency1" value="1" <cfif application.zcore.functions.zso(form, 'saved_search_frequency') EQ '1'>checked="checked"</cfif> style="background:none; border:0px; " /> <label for="saved_search_frequency1">Fridays</label></td>
	</tr>
	</table><!--- <h3>EMAIL ADDRESS:</h3>  <input type="text" name="inquiries_email" style="width:100%; max-width:300px; float:left;" value="#htmleditformat(form.inquiries_email)#" /> --->
	</div>
	<div style="float:left; width:100%; padding-bottom:10px; "> 
	<cfscript>
	ss={
		search_bathrooms: { label: "Baths", count:1},
		search_year_built: { label: "Year Built", count:1},
		search_sqfoot: { label: "Square Feet", count:2},
		search_city_id: { label: "City", count:1},
		search_status: { label: "Status", count:1},
		search_listing_type_id: { label: "Property Type", count:1},
		search_listing_sub_type_id: { label: "Property Sub Type", count:1},
		search_view: { label: "View", count:1},
		search_bedrooms: { label: "Beds", count:1},
		search_county: { label: "County", count:1},
		search_rate: { label: "Price Range", count:2}, 
		search_style: { label: "Style", count:1},
		search_frontage: { label: "Frontage", count:1},
		search_acreage: { label: "Acreage", count:1}  
	};
	local.arrS=structkeyarray(ss);
	arraysort(local.arrS, "text", "asc");
	writeoutput('<div style="width:280px; padding-right:10px; float:left;">');
	local.n=0;
	local.rowCount=0;
	for(i=1;i LTE arraylen(local.arrS);i++){ 
		if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, local.arrS[i]) EQ 1){
			local.rowCount+=ss[local.arrS[i]].count;
		}
	}
	local.column1=ceiling(local.rowCount/2)+1;
	local.columnOutput=false;
	for(i=1;i LTE arraylen(local.arrS);i++){ 
		if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, local.arrS[i]) EQ 1){
			local.n+=ss[local.arrS[i]].count; 
			if(local.n GTE local.column1 and not local.columnOutput){
				local.columnOutput=true;
				writeoutput('</div> <div style="width:280px; padding-right:10px;float:left;">');
			}
			//writeoutput('<h3>'&ss[local.arrS[i]].label&'</h3>');
			writeoutput('##'&local.arrS[i]&'##');
		}
	}
	writeoutput('</div>');
	</cfscript>
	</div> 
	
	<div style="float:left; clear:both; width:100%;">
	<input type="submit" name="submitQuick1" value="Submit Form" style="font-size:18px; line-height:24px; margin-right:15px;" /> <a href="/z/user/privacy/index" class="zPrivacyPolicyLink">Privacy Policy</a>
	    </div>
	    <br style="clear:both;">
	
		<cfif form.modalpopforced EQ 1>
			<input type="hidden" name="modalpopforced" value="1" />
			<input type="hidden" name="js3811" id="js3811" value="" />
			<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
		</cfif>  
	</form> 
	</cfsavecontent>
	<cfsavecontent variable="theFinalHTML">
	<cfscript>
	ts=structnew();
	ts.output=true;
	ts.advancedSearch=true;
	ts.disablejavascript=true;
	ts.searchFormLabelOnInput=true;
	ts.searchDisableExpandingBox=true;
	ts.searchFormEnabledDropDownMenus=false;
	ts.searchReturnVariableStruct=true;
	/*ts.searchFormHideCriteria=structnew();
	ts.searchFormHideCriteria["more_options"]=true;*/
	application.zcore.listingCom.includeSearchForm(ts);
	</cfscript>
	</cfsavecontent>
	<cfscript>
	writeoutput(theFinalHTML);
	request.zHideInquiryForm=true;
	</cfscript>
</cffunction>

<cffunction name="process" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	variables.init(); 
	form.inquiries_spam=0;
	form.saved_search_email=application.zcore.functions.zso(form, 'saved_search_email');
	form.saved_search_format=application.zcore.functions.zso(form, 'saved_search_format', true, 1);
	form.saved_search_frequency=application.zcore.functions.zso(form, 'saved_search_frequency', true, 0);
	if(application.zcore.user.checkGroupAccess("user")){
		form.saved_search_email=request.zsession.user.email;
		form.inquiries_first_name=request.zsession.user.first_name;
		form.inquiries_last_name=request.zsession.user.last_name;
	}


	local.myForm=structnew();  
	local.myForm.saved_search_email.required = true;
	local.myForm.saved_search_email.friendlyName = "Email Address";
	local.myForm.saved_search_email.email = true; 
    local.myForm.inquiries_first_name.required = true;
    local.myForm.inquiries_first_name.friendlyName = "First Name";
    if(not application.zcore.user.checkGroupAccess("user")){
        if(application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1){
            local.myForm.inquiries_phone1.required = true;
            local.myForm.inquiries_phone1.friendlyName = "Phone";
        }
    }
    local.myForm.inquiries_datetime.createDateTime = true;  
    local.result = application.zcore.functions.zValidateStruct(form, local.myForm, Request.zsid,true);
    if(local.result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/listing/new-listing-email-signup/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
    } 
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		form.inquiries_spam=1;
		form.inquiries_spam_description="Fake form fields not empty"; 
		//application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#");
	} 
	if(form.modalpopforced EQ 1){
		if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
			form.inquiries_spam=1; 
			form.inquiries_spam_description="js3811 value not set"; 
			//writeoutput('~n~');application.zcore.functions.zabort();
		}
		if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
			form.inquiries_spam=1; 
			form.inquiries_spam_description="Form hash value was wrong"; 
			//application.zcore.status.setStatus(request.zsid, "Your session has expired.  Please submit the form again.",form,true);
			//application.zcore.functions.zRedirect("/z/listing/new-listing-email-signup/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#");
		}
	} 
    /*if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		form.inquiries_spam=1; 
		form.inquiries_spam_description="zset9 was wrong";
		//application.zcore.functions.zredirect('/');
    }*/
	form.inquiries_email=form.saved_search_email;
	application.zcore.tracking.setUserEmail(form.saved_search_email);  
	form.inquiries_type_id = 14;
	form.inquiries_type_id_siteIdType=4; 
    form.inquiries_status_id = 1;
    form.site_id = request.zOS.globals.id;
	form.inquiries_session_id=application.zcore.session.getSessionId();
         
    //	Insert Into Inquiry Database
	form.inquiries_id=application.zcore.functions.zInsertLead();
    
    if(form.inquiries_id EQ false){
		application.zcore.status.setStatus(Request.zsid, "Your inquiry has not been sent due to an error.", false,true);
		application.zcore.functions.zRedirect("/z/misc/inquiry/index?modalpopforced=#form.modalpopforced#&content_id=#form.content_id#&zsid="&request.zsid);
    }
	
	 
	application.zcore.tracking.setConversion('inquiry',form.inquiries_id); 
	form.saved_search_format=application.zcore.functions.zso(form, 'saved_search_format', true, 1);
	form.saved_search_last_sent_date=request.zos.mysqlnow; 
	form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', 0, form.saved_search_email, form);  
	form.contact_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew())); 
	//if(form.inquiries_spam EQ 0){
		local.ts=structnew();
		local.ts.inquiries_id=form.inquiries_id;
		local.ts.subject="New listing email alert signup on #request.zos.globals.shortdomain#"; 
		local.rs=application.zcore.functions.zAssignAndEmailLead(local.ts);  
	//}
	form.inquiries_email=form.saved_search_email;
	request.zsession.inquiries_email=form.saved_search_email;
	local.tempEmail=application.zcore.functions.zvarso('zofficeemail');  
	application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#");
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent> 