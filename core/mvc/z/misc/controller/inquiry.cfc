<cfcomponent>
<cfoutput>
<cffunction name="submit" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var local=structnew();
	structappend(form, url, false);
	
	form.inquiries_spam=0;
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',false,0);
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		form.inquiries_spam=1;
		form.inquiries_spam_description="Fake form fields not empty"; 
		//application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#");
	}
	form.content_id=application.zcore.functions.zso(form, 'content_id');
	
	if(application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1){
		if(not application.zcore.functions.zVerifyRecaptcha()){
			application.zcore.status.setStatus(request.zsid, "The ReCaptcha security phrase wasn't entered correctly. Please try again.", form, true);
			application.zcore.functions.zRedirect("/z/misc/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#&content_id=#form.content_id#");
		}
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
			//application.zcore.functions.zRedirect("/z/misc/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#&content_id=#form.content_id#");
		}
	}
	local.pos=findnocase("</",application.zcore.functions.zso(form, 'inquiries_comments'));
	if(local.pos NEQ 0){
		form.inquiries_spam=1;
		form.inquiries_spam_description="html found in comments";
		//application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#");
	}
	/*	if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		form.inquiries_spam=1; 
		form.inquiries_spam_description="zset9 was wrong";
		//application.zcore.functions.zredirect('/');
	}*/
	if(structkeyexists(form, 'inquiries_start_date_month')){
		form.inquiries_start_date=application.zcore.functions.zGetDateSelect("inquiries_start_date");
		form.inquiries_start_date=dateformat(form.inquiries_start_date, "yyyy-mm-dd");
	}
	if(structkeyexists(form, 'inquiries_end_date_month')){
		form.inquiries_end_date=application.zcore.functions.zGetDateSelect("inquiries_end_date");
		form.inquiries_end_date=dateformat(form.inquiries_end_date, "yyyy-mm-dd");
	}
	local.toEmail = request.officeEmail;
	// form validation struct
	local.myForm=structnew();
	form.inquiries_referer=application.zcore.functions.zso(form, 'inquiries_referer');
	if(left(form.inquiries_referer, 1) EQ "/"){
		form.inquiries_referer=request.zos.currentHostName&form.inquiries_referer;
	}
	form.inquiries_referer2=request.zos.cgi.http_referer;
	if(structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1){
		local.myForm.inquiries_email.required = true;
		local.myForm.inquiries_email.friendlyName = "Email Address";
		local.myForm.inquiries_email.email = true;
	}
	if(structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_comments_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_comments_required EQ 1){
		local.myForm.inquiries_comments.required = true;
		local.myForm.inquiries_comments.friendlyName = "Comments";
	}
	local.myForm.inquiries_first_name.required = true;
	local.myForm.inquiries_first_name.friendlyName = "First Name";
	local.myForm.inquiries_last_name.required = true;
	local.myForm.inquiries_last_name.friendlyName = "Last Name";
	if(application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1){
		local.myForm.inquiries_phone1.required = true;
		local.myForm.inquiries_phone1.friendlyName = "Phone";
	}
	local.myForm.inquiries_datetime.createDateTime = true;
	
	form.Address_Line_1=application.zcore.functions.zso(form, 'inquiries_address');
	form.City=application.zcore.functions.zso(form, 'inquiries_city');
	form.State=application.zcore.functions.zso(form, 'inquiries_state');
	form.Country=application.zcore.functions.zso(form, 'inquiries_country');
	form.Postal_Code=application.zcore.functions.zso(form, 'inquiries_zip');
	
	form.content_id=application.zcore.functions.zso(form, 'selected_content_id');
	
	form.inquiries_type_id = application.zcore.functions.zso(form, 'inquiries_type_id',false,1);
	form.inquiries_type_id_siteIdType = application.zcore.functions.zso(form, 'inquiries_type_id_siteIdType',false,4);
	if(form.inquiries_type_id EQ "" or form.inquiries_type_id_siteIDType EQ ""){
		form.inquiries_type_id = 1;
		form.inquiries_type_id_siteIdType=4;
	}
	form.inquiries_status_id = 1;
	local.result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(local.result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/misc/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#&content_id=#form.content_id#");
	}
	if(Find("@", form.inquiries_first_name) NEQ 0){
		form.inquiries_spam=1;
		form.inquiries_spam_description="@ symbol in first name";
		// application.zcore.status.setStatus(Request.zsid, "Invalid Request",form,true);
		//application.zcore.functions.zRedirect("/z/misc/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#&content_id=#form.content_id#");
	}
	if(application.zcore.functions.zso(form, 'qualifyRequired') EQ 1 and (application.zcore.functions.zso(form, 'inquiries_property_type') EQ "" or (application.zcore.functions.zso(form, 'inquiries_price_low') EQ 0 and application.zcore.functions.zso(form, 'inquiries_price_high') EQ 100000000))){
		application.zcore.status.setStatus(request.zsid,"Property Type and Price Range are required.",form,true);
		application.zcore.functions.zRedirect("/z/misc/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#request.zsid#&content_id=#form.content_id#");
	}
	form.site_id = request.zOS.globals.id;
	form.inquiries_session_id=application.zcore.session.getSessionId();
	 
	//	Insert Into Inquiry Database
	form.inquiries_id=application.zcore.functions.zInsertLead();
	
	if(form.inquiries_id EQ false){
		application.zcore.status.setStatus(Request.zsid, "Your inquiry has not been sent due to an error.", false,true);
		application.zcore.functions.zRedirect("/z/misc/inquiry/index?modalpopforced=#form.modalpopforced#&content_id=#form.content_id#&zsid="&request.zsid);
	}
	
	
	application.zcore.tracking.setUserEmail(form.inquiries_email);
	application.zcore.tracking.setConversion('inquiry',form.inquiries_id);
	
	if(application.zcore.functions.zso(form, 'inquiries_email') EQ "" or application.zcore.functions.zEmailValidate(form.inquiries_email) EQ false){
		form.inquiries_email=request.fromemail;
	}
	form.contact_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew()));
	//if(form.inquiries_spam EQ 0){
		local.ts=structnew();
		local.ts.inquiries_id=form.inquiries_id;
		local.ts.subject="New Inquiry on #request.zos.globals.shortdomain#";
		// send the lead
		local.rs=application.zcore.functions.zAssignAndEmailLead(local.ts);
		if(local.rs.success EQ false){
			// failed to assign/email lead
			//zdump(local.rs);
		}
	//}
	//if(form.inquiries_spam EQ 0){
		if(application.zcore.app.siteHasApp("rental") and application.zcore.app.getAppData("rental").optionstruct.rental_config_lodgix_email_to NEQ ""){
			local.rentalFrontCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.rental.controller.rental-front");
			local.rentalFrontCom.lodgixInquiryTemplate();
		}
	//}
	redirectURL=application.zcore.functions.zso(form, 'redirect_url');
	if(redirectURL NEQ ""){
		application.zcore.functions.zRedirect(redirectURL);
	}else{
		application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#");
	}
	</cfscript>

</cffunction>
    
    
<cffunction name="index" localmode="modern" access="remote">

	<cfscript>
	var temp=structnew();
	var r1=0;
	var ts=structnew();
	var rs=structnew();
	var inquiryTextMissing=0;
	var i=0;
	var db=request.zos.queryObject;
	var primaryCityId=0;
	var rs2=0;
	var arrLabel=0;
	var qCity=0;
	var cityIdList=0;
	var qType=0;
	var cityUnq=0;
	var selectedCityCount=0;
	var arrKeys=0;
	var arrValue=0;
	var selectStruct=0;
	// support legacy form urls that used "action=send" - DO NOT REMOVE
	if(structkeyexists(form, 'action') and form.action EQ "send"){
		this.submit();
		return;	
	}
	if(structkeyexists(request.zos, 'zHideInquiryForm')){
		return;	
	}
        request.zHideInquiryForm=true;
        form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
        if(form.modalpopforced EQ 1){
            application.zcore.template.setTag("pagetitle","Contact Us");
            application.zcore.template.setTag("title","Contact Us");
			application.zcore.functions.zSetModalWindow();
        }
        </cfscript>
 
	<cfif request.cgi_SCRIPT_NAME EQ '/z/misc/inquiry/index'>
		<cfsavecontent variable="temp.pageNav">
		<a href="/">#request.zos.globals.homelinktext#</a> /
		</cfsavecontent>
		<cfscript> 
		application.zcore.template.setTag("pagenav",temp.pageNav);
		</cfscript>
	</cfif>
	
	<cfset inquiryTextMissing=true>
	<cfscript>
	structappend(form, application.zcore.functions.zNewRecord(request.zos.zcoreDatasource, "inquiries"), false);
	application.zcore.functions.zStatusHandler(request.zsid, true);
	for(i in url){
		if(left(i,10) EQ "inquiries_"){
			form[i]=url[i];
		}
	}
	</cfscript>
        
        <a id="cjumpform"></a>
        
        <cfif form.modalpopforced NEQ 1 and not structkeyexists(request, 'disableContactContent')>
			<cfif (structkeyexists(form, 'inquiries_email') EQ false or form.inquiries_email EQ "") and structkeyexists(form,  'zsid') EQ false>
                <cfif application.zcore.app.siteHasApp("content")>
                    <cfscript>
                    ts=structnew();
                    ts.content_unique_name='/z/misc/inquiry/index';
                    ts.disableContentMeta=false;
                    ts.disableLinks=true;
                    if(form[request.zos.urlRoutingParameter] EQ '/z/misc/inquiry/index'){
                        r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
                        application.zcore.template.prependTag('meta','<meta name="robots" content="noindex,follow" />');
                    }else{
                        r1=application.zcore.app.getAppCFC("content").includeContentByName(ts);
                    }
                    if(r1 EQ false){
                        inquiryTextMissing=true;
                    }else{
                        inquiryTextMissing=false;	
                    }
                    </cfscript>
                </cfif>
            </cfif>
            <cfif inquiryTextMissing>
                <cfscript>
                if(request.cgi_SCRIPT_NAME EQ '/z/misc/inquiry/index'){
                    application.zcore.template.setTag("title","Contact Us");
                    application.zcore.template.setTag("pagetitle","Contact Us");
                }else{
                    writeoutput('<h2>Contact Us</h2>');
                }
                </cfscript>
                <p>Please fill out the form below and we will respond to your inquiry shortly.</p>
            
            </cfif>
        </cfif>
        <cfscript>
		inquiryHeaderMessage=application.zcore.functions.zso(form, 'inquiryHeaderMessage');
		if(inquiryHeaderMessage NEQ ""){
			echo('<p>'&inquiryHeaderMessage&'</p>');
		}
		</cfscript>
        <p>* denotes required field.</p>
            <cfscript>
            form.set9=application.zcore.functions.zGetHumanFieldIndex();
            </cfscript>
            <form class="zFormCheckDirty" id="myForm" action="/z/misc/inquiry/submit" onsubmit="zSet9('zset9_#form.set9#');" method="post" style="margin:0px; padding:0px;">
            <input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
            <input type="hidden" name="redirect_url" value="#htmleditformat(application.zcore.functions.zso(form, 'redirect_url'))#" />
            <input type="hidden" name="inquiryHeaderMessage" value="#htmleditformat(application.zcore.functions.zso(form, 'inquiryHeaderMessage'))#" />
            #application.zcore.functions.zFakeFormFields()#
            <input type="hidden" name="inquiries_referer" value="#HTMLEditFormat(request.zos.cgi.http_referer)#" />
            <table class="zinquiry-form-table">
            <tr>
                <th>First Name: *</th>
                <td><input name="inquiries_first_name" id="inquiries_first_name" type="text" style="width:96%;" maxlength="50" value="<cfif form.inquiries_first_name EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_first_name')#<cfelse>#form.inquiries_first_name#</cfif>" />
        <cfif structkeyexists(form, 'content_id') or structkeyexists(form, 'selected_content_id') or isDefined('request.zos.zPrimaryContentId')>
			<cfscript>
            if(application.zcore.functions.zso(form, 'content_id') NEQ ''){
                form.selected_content_id=form.content_id;
            }else{
                form.selected_content_id=application.zcore.functions.zso(form, 'selected_content_id',false,application.zcore.functions.zso(request.zos, 'zPrimaryContentId'));
            }
            </cfscript>
             <cfif form.selected_content_id NEQ ""> <input type="hidden" name="selected_content_id" value="#form.selected_content_id#" /></cfif></cfif></td>
            </tr>
            <tr>
                <th>Last Name: *</th>
                <td><input name="inquiries_last_name" type="text" style="width:96%;" maxlength="50" value="<cfif form.inquiries_last_name EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_last_name')#<cfelse>#form.inquiries_last_name#</cfif>" /></td>
            </tr>
          <tr id="zInquiryFormTRCompany"><th>Company:</th><td><input type="text" class="textinput" name="inquiries_company" style="width:96%;" maxlength="100" value="#application.zcore.functions.zso(form, 'inquiries_company')#" /></td></tr>
            <tr>
                <th>Email: <cfif structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1>*</cfif></th>
                <td><input name="inquiries_email" type="text" style="width:96%;" maxlength="50" value="<cfif form.inquiries_email EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_email')#<cfelse>#form.inquiries_email#</cfif>" /></td>
            </tr>
            <tr>
                <th>Phone: <cfif application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1>*</cfif></th>
                <td><input name="inquiries_phone1" type="text" style="width:96%;" maxlength="50" value="<cfif form.inquiries_phone1 EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_phone1')#<cfelse>#form.inquiries_phone1#</cfif>" /></td>
            </tr>
            
          <tr id="zInquiryFormTRAddress"><th>Address:</th><td><input type="text" class="textinput" name="inquiries_address" style="width:96%;" maxlength="100" value="#application.zcore.functions.zso(form, 'inquiries_address')#" /></td></tr>
          <tr id="zInquiryFormTRCity"><th>City:</th><td><input type="text" class="textinput" name="inquiries_city" style="width:96%;" maxlength="100" value="#application.zcore.functions.zso(form, 'inquiries_city')#" /></td></tr>
          <tr id="zInquiryFormTRState"><th>State:</th><td><input type="text" class="textinput" name="inquiries_state" style="width:96%;" maxlength="100" value="#application.zcore.functions.zso(form, 'inquiries_state')#" /></td></tr>
          <tr id="zInquiryFormTRCountry"><th>Country:</th><td><input type="text" class="textinput" name="inquiries_country" style="width:96%;" maxlength="100" value="#application.zcore.functions.zso(form, 'inquiries_country')#" /></td></tr>

          <tr id="zInquiryFormTRZip"><th>Zip:</th><td><input type="text" class="textinput" name="inquiries_zip" style="width:96%;" maxlength="100" value="#application.zcore.functions.zso(form, 'inquiries_zip')#" /></td></tr>
          
          <cfif application.zcore.app.siteHasApp("listing") and application.zcore.app.getAppData("content").optionstruct.content_config_inquiry_qualify EQ 1>
          </table><br />
        
            <table class="zinquiry-form-table" id="zls-inquiry-listing-qualify">
          <tr>	
            <td colspan="2"><h2>What type of property are you interested in?</h2>
            <cfif application.zcore.functions.zso(form, 'qualifyRequired') EQ 1>You must enter at least property type and price range.<input type="hidden" name="qualifyRequired" value="1" /></cfif></td>
            </tr>
            
            <cfscript>
            if(isDefined('request.zsession.zLastSearchId')){
                ts2=application.zcore.status.getStruct(request.zsession.zLastSearchId);
                ts=ts2.varstruct;
                form.inquiries_property_type = application.zcore.functions.zso(ts, 'property_type_code');
                form.inquiries_property_city=application.zcore.functions.zso(ts, 'city_id');
                form.inquiries_price_low=application.zcore.functions.zso(ts, 'rate_low');
                form.inquiries_price_high=application.zcore.functions.zso(ts, 'rate_high');
                form.inquiries_pool=application.zcore.functions.zso(ts, 'with_pool');
                form.inquiries_bedrooms=application.zcore.functions.zso(ts, 'bedrooms');
                form.inquiries_bathrooms=application.zcore.functions.zso(ts, 'bathrooms');
                if(isDefined('ts.sqfoot_low') and isDefined('ts.sqfoot_high')){
                    form.inquiries_sqfoot=ts.sqfoot_low&'-'&ts.sqfoot_high;
                }
            }
            </cfscript>
            <tr>
            
            <td colspan="2">
            <table  style="border-spacing:5px;">
            <tr>
        <td>Property Type</td>
        <td colspan="3">Choose Price Between</td>
        </tr>
        <tr>
        <td> 
                
                <cfscript>
                selectStruct = StructNew();
                selectStruct.name = "inquiries_property_type";
                selectStruct.listValues = "Acreage,Apartments,Business,Commercial,Commercial Lot,Condominium,Duplex,Farm,Industrial,Lake Access Lot,Lake Front Lot,Mobile Home Lot,Multi-Family Home,River Access Lot,Single Family Home,Townhouse,Vacant Lot";
                selectStruct.listValuesDelimiter = ",";
                application.zcore.functions.zInputSelectBox(selectStruct);
                </cfscript></td><td colspan="3"> 
                  <cfscript>
                    selectStruct = StructNew();
                    selectStruct.name = "inquiries_price_low";
                    selectStruct.hideSelect = true;
                    selectStruct.selectedValues = application.zcore.functions.zso(form, 'inquiries_price_low',true,"0");
                    selectStruct.listLabels = "Any|50000|100000|150000|200000|250000|300000|350000|400000|500000|600000|700000|800000|900000|1000000|2000000|3000000|4000000|5000000|10000000";
                    selectStruct.listValues = "0|50000|100000|150000|200000|250000|300000|350000|400000|500000|600000|700000|800000|900000|1000000|2000000|3000000|4000000|5000000|10000000";
                    selectStruct.listLabelsDelimiter = "|";
                    selectStruct.listValuesDelimiter = "|";
                    selectStruct.dollarFormatLabels = true;
                    application.zcore.functions.zInputSelectBox(selectStruct);
                  </cfscript>and<cfscript>
                    selectStruct = StructNew();
                    selectStruct.name = "inquiries_price_high";
                    selectStruct.hideSelect = true;
                    selectStruct.selectedValues = application.zcore.functions.zso(form, 'inquiries_price_high',false,"100000000");
                    selectStruct.listLabels = "Any|50000|100000|150000|200000|250000|300000|350000|400000|500000|600000|700000|800000|900000|1000000|2000000|3000000|4000000|5000000|10000000";
                    selectStruct.listValues = "100000000|50000|100000|150000|200000|250000|300000|350000|400000|500000|600000|700000|800000|900000|1000000|2000000|3000000|4000000|5000000|10000000";
                    selectStruct.listLabelsDelimiter = "|";
                    selectStruct.listValuesDelimiter = "|";
                    selectStruct.dollarFormatLabels = true;
                    application.zcore.functions.zInputSelectBox(selectStruct);
                  </cfscript></td>
        </tr><tr>
        <td>City Name</td>
        <td>Beds</td>
        <td>Baths</td>
        <td>Square Feet</td>
        </tr>
        <tr><td>
                
                
        <cfscript>
        primaryCityId=application.zcore.app.getAppData("listing").sharedStruct.mls_primary_city_id;
        selectedCityCount=1;
        if(application.zcore.functions.zso(form, 'search_city_id') NEQ ""){
            cityIdList="'"&replace(form.search_city_id,",","','","ALL")&"'";
            g=listgetat(form.search_city_id,1);
            selectedCityCount=listlen(form.search_city_id);
            if(isnumeric(g)){
                primaryCityId=g;	
            }
            
        }else{
            cityIdList="'"&replace(primaryCityId,",","','","ALL")&"'";
        }
        
            arrLabel=arraynew(1);
            arrValue=arraynew(1);
            rs2=structnew();
            rs2.labels="";
            rs2.values="";
            cityUnq=structnew();
            </cfscript>
            <cfsavecontent variable="db.sql">
            SELECT cast(group_concat(distinct listing_city SEPARATOR #db.param("','")#) AS CHAR) idlist 
			from #db.table("listing_memory", request.zos.zcoreDatasource)# listing where
            listing_deleted = #db.param(0)# and 
            #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
            listing_city not in (#db.trustedSQL("'','0'")#) 
            <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)#  
            </cfsavecontent>
            <cfscript>
            qType=db.execute("qType");
            
            db.sql="select city_x_mls.city_name label, city_x_mls.city_id value 
			from #db.table("city_x_mls", request.zos.zcoreDatasource)# city_x_mls 
			where city_x_mls.city_id IN (#db.trustedSQL("'#qtype.idlist#'")#) and 
			city_x_mls_deleted = #db.param(0)# and 
			#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))# ";
			qCity=db.execute("qCity"); 
            </cfscript>
            <cfloop query="qCity"><cfscript>if(structkeyexists(cityUnq,qCity.label) EQ false){cityUnq[qCity.label]=qCity.value;}</cfscript></cfloop>
        
        <cfscript>
        arrKeys=structkeyarray(cityUnq);
        arraysort(arrKeys,"text","asc");
        for(i=1;i LTE arraylen(arrKeys);i++){
            arrayappend(arrLabel,arrKeys[i]);
            arrayappend(arrValue,cityUnq[arrKeys[i]]);
        }
	rs2=structnew();
        rs2.labels=arraytolist(arrLabel,chr(9));
        rs2.values=arraytolist(arrValue,chr(9));
        ts.listLabels=rs2.labels;
        ts.listValues =rs2.values;
        
                selectStruct = StructNew();
                selectStruct.name = "inquiries_property_city";
                //selectStruct.listLabels=rs2.labels;
                selectStruct.listValues =rs2.labels;;//rs2.values;
                //ts.listLabelsDelimiter = chr(9);
                selectStruct.listValuesDelimiter = chr(9);
                application.zcore.functions.zInputSelectBox(selectStruct);
                </cfscript></td><td> 
                  <cfscript>
                    selectStruct = StructNew();
                    selectStruct.name = "inquiries_bedrooms";
                    selectStruct.selectLabel = "Any";
                    selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10";
                    application.zcore.functions.zInputSelectBox(selectStruct);
                  </cfscript>
                 </td><td>
                  <cfscript>
                    selectStruct = StructNew();
                    selectStruct.name = "inquiries_bathrooms";
                    selectStruct.selectLabel = "Any";
                    selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10";
                    application.zcore.functions.zInputSelectBox(selectStruct);
                  </cfscript>
                 </td><td>
            <cfscript>
            selectStruct = StructNew();
            selectStruct.name = "inquiries_sqfoot";
            selectStruct.selectLabel = "Any";
            selectStruct.listLabels="< 1000,1000 - 1500,1500 - 2000,2000 - 2500,2500 - 3000,3000 - 3500,3500 - 4000,4000 - 4500,4500 - 5000,5000 - 6000,6000 - 7000,7000 - 8000,8000 - 9000,9000 - 10000,10000 +";
            selectStruct.listValues = "1-999,1000-1500,1500-2000,2000-2500,2500-3000,3000-3500,3500-4000,4000-4500,4500-5000,5000-6000,6000-7000,7000-8000,8000-9000,9000-10000,10000-900000";
            application.zcore.functions.zInputSelectBox(selectStruct);
            </cfscript></td> 
        </tr>
        <tr><td> Want a Pool? 
            
              <input type="radio" name="inquiries_pool" class="input-plain" value="1" <cfif application.zcore.functions.zso(form, 'inquiries_pool') EQ 1>checked="checked"</cfif> /> Yes
              <input type="radio" name="inquiries_pool" class="input-plain" value="0" <cfif application.zcore.functions.zso(form, 'inquiries_pool',true) EQ 0>checked="checked"</cfif> /> No 
              </td><td colspan="3">
              View/Frontage: 
              <select name="inquiries_view" size="1">
              <option value="">Any</option>
              <option>Canalfront</option>
              <option>Garden view</option>
              <option>Golf course view</option>
              <option>Lakefront</option>
              <option>Ocean access</option>
              <option>Ocean view</option>
              <option>Oceanfront</option>
              <option>River view</option>
              <option>Riverfront</option>
              <option>Swimming pool view</option>
              <option>Water view</option>
              <option>Mountain view</option>
              </select>
        </td></tr>
        </table>
                
            
            </td>
            </tr>   
            <tr>	
            <td colspan="2"><h2>Getting ready to move soon?</h2></td>
            </tr>
            <tr>	
            <td colspan="2">
                <div style="float:left; width:220px; padding-bottom:5px; ">
                When do you want to move? 
                </div>
                <div style="float:left; width:240px; padding-bottom:5px; ">
            Are you currently working with an agent?
                </div>
                <div style="float:left; clear:both; width:220px; padding-bottom:10px; ">
              <cfscript>
                selectStruct = StructNew();
                selectStruct.name = "inquiries_when_move";
                selectStruct.selectLabel = "-- Select --";
                selectStruct.listValues = "Less than 30 days,1 Month,2 Months,3 Months,4 Months,5 Months,6 Months,7 Months,8 Months,9 Months,10 Months,11 Months,12 Months +";
                application.zcore.functions.zInputSelectBox(selectStruct);
              </cfscript>
              </div>
              
              <div style="float:left; width:240px; padding-bottom:10px; ">
            Yes
              <input type="radio" name="inquiries_other_realtors" class="input-plain" value="1" <cfif application.zcore.functions.zso(form, 'inquiries_other_realtors') EQ 1>checked="checked"</cfif> /> No
              <input type="radio" name="inquiries_other_realtors" class="input-plain" value="0" <cfif application.zcore.functions.zso(form, 'inquiries_other_realtors',true) EQ 0>checked="checked"</cfif> />
              </div>
              
              <br style="clear:both;" />
                <div style="float:left; width:220px; padding-bottom:10px; ">
                How long have you been looking?
                </div>
                <div style="float:left; width:240px; padding-bottom:10px; ">
            Have you been prequalified?
                </div>
              <div style="float:left; width:220px; clear:both; padding-bottom:10px; ">
            <cfscript>
                selectStruct = StructNew();
                selectStruct.name = "inquiries_look_time";
                selectStruct.selectLabel = "-- Select --";
                selectStruct.listValues = "Less than 30 days,1 Month,2 Months,3 Months,4 Months +";
                application.zcore.functions.zInputSelectBox(selectStruct);
              </cfscript>
                </div>
                
                
                <div style="float:left; width:220px; padding-bottom:10px; ">
                
            Yes
              <input type="radio" name="inquiries_prequalified" class="input-plain" value="1" <cfif application.zcore.functions.zso(form, 'inquiries_prequalified') EQ 1>checked="checked"</cfif> /> No
              <input type="radio" name="inquiries_prequalified" class="input-plain" value="0" <cfif application.zcore.functions.zso(form, 'inquiries_prequalified',true) EQ 0>checked="checked"</cfif> /> 
            </div>
            
            </td>
            </tr>
          </table><br />
        
            <table  style="border-spacing:2px;width:100%;">
            <tr><td colspan="2">Please enter in any other preferred property information such as school zoning, county, acreage, zip code, mls ##, year built in the comments field below.</td></tr>
            </cfif>
          
        
        <tr><th style="vertical-align:top; width:90px; ">Comments:
            <cfif structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_comments_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_comments_required EQ 1>*</cfif>
        </th><td>
		<cfsavecontent variable="content2">
			<cfif structkeyexists(form, 'inquiries_comments')>#htmleditformat(form.inquiries_comments)#
			<cfelse>#htmleditformat(application.zcore.functions.zso(form, 'inquiries_comments'))#
			</cfif>
		</cfsavecontent>
        <textarea name="inquiries_comments" cols="50" rows="5" style="width:96%; height:100px;">#trim(content2)#</textarea>
        
        </td></tr>
 
    <tr class="znewslettercheckbox">
		<th>&nbsp;</th>
		<td><input type="checkbox" name="inquiries_email_opt_in" id="inquiries_email_opt_in" value="1" <cfif application.zcore.functions.zso(form, 'inquiries_email_opt_in',false,0) EQ "1">checked="checked"</cfif> style="background:none; border:none;" /> <label for="inquiries_email_opt_in"><cfif application.zcore.functions.zvarso("Newsletter Signup Text") EQ "">
				Please check the box to join our mailing list.
			<cfelse>
				#application.zcore.functions.zvarso("Newsletter Signup Text")#
			</cfif></label></td>
	</tr>
	
	<cfif application.zcore.functions.zso(request.zos.globals, 'requireCaptcha', true, 0) EQ 1>
		<tr>
		<th>&nbsp;</th>
			<td>
			#application.zcore.functions.zDisplayRecaptcha()#
			</td>
		</tr>
	</cfif>
	<tr>
	<th>&nbsp;</th>
		<td><button type="submit" name="submit">Send Inquiry</button>&nbsp;&nbsp; <a href="/z/user/privacy/index" class="zPrivacyPolicyLink" target="_blank">Privacy Policy</a><br /><br /> 
        <div class="zPrivacyPolicyMessage">
   			#application.zcore.functions.zvarso("Form Privacy Message")#
		</div></td>
        </tr>
	</table>
    <cfif form.modalpopforced EQ 1>
	<input type="hidden" name="modalpopforced" value="1" />
	<input type="hidden" name="js3811" id="js3811" value="" />
	<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
    </cfif>
	</form>
	</cffunction>
    </cfoutput>
</cfcomponent>