<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" returntype="any">
	<cfscript>
	request.zos.currentURLISAListingPage=true;
	if(isDefined('request.zHideInquiryForm') EQ false){
		request.zHideInquiryForm=true;
		form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',false,0);
	}
	</cfscript>
</cffunction>
<cffunction name="send" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var toEmail=0;
	var myForm=0;
	var result=0;
	var inputStruct=0;
	var rs=0;
	var ts=0;
	variables.init();
	form.inquiries_spam=0;
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
	toEmail = request.officeEmail;
	myForm=structnew();
	if(structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1){
		myForm.inquiries_email.required = true;
		myForm.inquiries_email.friendlyName = "Email Address";
		myForm.inquiries_email.email = true;
	}
	myForm.inquiries_city.required = true;
	myForm.inquiries_city.friendlyName = "City";	
	myForm.inquiries_property_address.required = true;
	myForm.inquiries_property_address.friendlyName = "Address";
	myForm.inquiries_first_name.required = true;
	myForm.inquiries_first_name.friendlyName = "First Name";
	if(application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1){
		myForm.inquiries_phone1.required = true;
		myForm.inquiries_phone1.friendlyName = "Phone";
	}
	myForm.inquiries_datetime.createDateTime = true;
	form.inquiries_type_id = 6;
	form.inquiries_type_id_siteIdType=4;
	form.inquiries_status_id = 1;
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/listing/cma-inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#&action=form");
	}
	if(find("@", form.inquiries_first_name) NEQ 0){
		form.inquiries_spam=1;
		form.inquiries_spam_description="@ symbol in first name";
		//application.zcore.status.setStatus(Request.zsid, "Invalid Request",form,true);
		//application.zcore.functions.zRedirect("/z/listing/cma-inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#&action=form");
	}
	if(structkeyexists(form, 'inquiries_comments') and (findnocase("[/url]", form.inquiries_comments) NEQ 0 or findnocase("http://", form.inquiries_comments) NEQ 0)){
		form.inquiries_spam=1;
		form.inquiries_spam_description="Comments had url";
		//application.zcore.status.setStatus(Request.zsid, "Invalid Request",form,true);
		//application.zcore.functions.zRedirect("/z/listing/cma-inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#&action=form");
	}
	form.site_id = request.zOS.globals.id;
	form.inquiries_session_id=application.zcore.session.getSessionId();
	form.property_id=''; 
	form.inquiries_id=application.zcore.functions.zInsertLead();
	if(form.inquiries_id EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Your inquiry has not been sent due to an error.", false,true);
		application.zcore.functions.zRedirect("/z/listing/cma-inquiry/index?modalpopforced=#form.modalpopforced#&action=form&zsid="&request.zsid);
	}else{
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Your inquiry has been sent.", false,true);
	}	
	application.zcore.tracking.setUserEmail(form.inquiries_email);
	application.zcore.tracking.setConversion('cma inquiry', form.inquiries_id);
	if(application.zcore.functions.zso(form, 'inquiries_email') EQ "" or application.zcore.functions.zEmailValidate(form.inquiries_email) EQ false){
		form.inquiries_email=request.fromemail;
	}
	//if(form.inquiries_spam EQ 0){
		ts=structnew();
		ts.inquiries_id=form.inquiries_id;
		ts.subject="New CMA Inquiry on #request.zos.globals.shortdomain#";
		// send the lead
		rs=application.zcore.functions.zAssignAndEmailLead(ts);
		if(rs.success EQ false){
			// failed to assign/email lead
			//zdump(rs);
		}
	//}
	application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#&zsid="&request.zsid);//&searchId=#form.searchid#
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var inquiryTextMissing=0;
	var r1=0;
	var ts=0;
	var qInquiries=0;
	var selectStruct=0;
	variables.init();
	if(form.modalpopforced EQ 1){
		application.zcore.template.setTag("pagetitle","Get your free home evaluation");
		application.zcore.template.setTag("title","Get your free home evaluation");
		application.zcore.functions.zSetModalWindow();
	}
	inquiryTextMissing=false;
	if(application.zcore.app.siteHasApp("content")){
		ts=structnew();
		ts.content_unique_name='/z/listing/cma-inquiry/index';
		ts.disableContentMeta=false;
		ts.disableLinks=true;
		if(request.cgi_SCRIPT_NAME EQ '/z/listing/cma-inquiry/index'){
			r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		}else{
			r1=application.zcore.app.getAppCFC("content").includeContentByName(ts);
		}
		if(r1 EQ false){
			inquiryTextMissing=true;
		}
	}else{
		inquiryTextMissing=true;
	}
	if(inquiryTextMissing){
		if(request.cgi_SCRIPT_NAME EQ '/z/listing/cma-inquiry/index'){
			application.zcore.template.setTag("title","Get your free home evaluation");
			application.zcore.template.setTag("pagetitle","Get your free home evaluation");
		}else{
			writeoutput('<h2>Get your free home evaluation.</h2>');
		}
		writeoutput('<p>Please complete the following form to get a free estimate on your home''s value. Upon receiving your request,we will perform a Comparative Market Analysis (CMA) for your home and return the report to you shortly.</p>');
	}
	db.sql="SELECT *
	from #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# inquiries
	WHERE inquiries_id = #db.param(-1)# and 
	inquiries_deleted=#db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	qInquiries=db.execute("qInquiries");
	application.zcore.functions.zQueryToStruct(qInquiries, form, 'inquiries_email');
	application.zcore.functions.zStatusHandler(request.zsid, true);
	form.inquiries_email=application.zcore.functions.zso(form, 'inquiries_email');

	form.set9=application.zcore.functions.zGetHumanFieldIndex();
	</cfscript>
	<form class="zFormCheckDirty" id="myForm" action="/z/listing/cma-inquiry/send?modalpopforced=#form.modalpopforced#" method="post" onsubmit="zSet9('zset9_#form.set9#');" style="margin:0px; padding:0px;">
		<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
		#application.zcore.functions.zFakeFormFields()#
		<table style="border-spacing:5px;">
			<tr>
				<td colspan="2"><span style="font-size:14px; font-weight:bold; ">Comparative Market Analysis Form</span></td>
			</tr>
			<tr id="zcma-row1">
				<td colspan="2"> Select your relation to this property:
					<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_owner_relationship";
			selectStruct.listValues = "I am the owner,My business owns it,A friend owns it,A relative owns it";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
					<br />
					<br />
					If you aren't the owner of this property, what is the taxpayer's name?
					<input name="inquiries_owner" type="text" size="30" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_owner')#" />
					<br /></td>
			</tr>
			<tr id="zcma-row2">
				<td>First Name:</td>
				<td><input name="inquiries_first_name" type="text" size="30" maxlength="50" value="<cfif form.inquiries_first_name EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_first_name')#<cfelse>#form.inquiries_first_name#</cfif>" />
					<span class="highlight"> * Required</span></td>
			</tr>
			<tr id="zcma-row3">
				<td>Last Name:</td>
				<td><input name="inquiries_last_name" type="text" size="30" maxlength="50" value="<cfif form.inquiries_last_name EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_last_name')#<cfelse>#form.inquiries_last_name#</cfif>" />
					<span class="highlight"> * Required</span></td>
			</tr>
			<tr id="zcma-row4">
				<td>Email:</td>
				<td><input name="inquiries_email" type="text" size="30" maxlength="50" value="<cfif form.inquiries_email EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_email')#<cfelse>#form.inquiries_email#</cfif>" />
					<cfif structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1>
						<span class="highlight"> * Required</span>
					</cfif></td>
			</tr>
			<tr id="zcma-row5">
				<td>Phone:</td>
				<td><input name="inquiries_phone1" type="text" size="30" maxlength="50" value="<cfif form.inquiries_phone1 EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_phone1')#<cfelse>#form.inquiries_phone1#</cfif>" />
					<cfif application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1>
						<span class="highlight"> * Required</span>
					</cfif></td>
			</tr>
			<tr id="zcma-row6">
				<td> Property Type</td>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "inquiries_property_type";
					selectStruct.listValues = "Home,Business,Condo,Duplex,Townhouse,Co-operative,Vacant Lot,Vacant Acreage";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					Other:
					<input type="text" name="inquiries_type_other" value="#application.zcore.functions.zso(form, 'inquiries_type_other')#" /></td>
			</tr>
			<tr id="zcma-row7">
				<td> Address</td>
				<td><input type="text" name="inquiries_property_address" value="#application.zcore.functions.zso(form, 'inquiries_property_address')#" />
					* required </td>
			</tr>
			<tr id="zcma-row8">
				<td> City Name</td>
				<td><input type="text" name="inquiries_city" value="#application.zcore.functions.zso(form, 'inquiries_city')#" />
					* required </td>
			</tr>
			<tr id="zcma-row9">
				<td> State</td>
				<td><input type="text" name="inquiries_state" value="#application.zcore.functions.zso(form, 'inquiries_state')#" /></td>
			</tr>
			<tr id="zcma-row10">
				<td> ZIP Code</td>
				<td><input type="text" name="inquiries_zip" value="#application.zcore.functions.zso(form, 'inquiries_zip')#" />
					* required </td>
			</tr>
			<tr id="zcma-row11">
				<td> Year Built</td>
				<td><input type="text" name="inquiries_year_built" value="#application.zcore.functions.zso(form, 'inquiries_year_built')#" /></td>
			</tr>
			<tr id="zcma-row12">
				<td>Bedrooms</td>
				<td><cfscript>
				selectStruct = StructNew();
				selectStruct.name = "inquiries_bedrooms";
				selectStruct.selectLabel = "Select";
				selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10";
				application.zcore.functions.zInputSelectBox(selectStruct);
			  	</cfscript></td>
			</tr>
			<tr id="zcma-row12-2">
				<td> Baths</td>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "inquiries_bathrooms";
					selectStruct.selectLabel = "Select";
					selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10";
					application.zcore.functions.zInputSelectBox(selectStruct);
				  	</cfscript></td>
			</tr>
			<tr id="zcma-row13">
				<td>Home Size </td>
				<td><cfscript>
				selectStruct = StructNew();
				selectStruct.name = "inquiries_sqfoot";
				selectStruct.selectLabel = "-- Select --";
				selectStruct.listLabels="< 1000,1000 - 1500,1500 - 2000,2000 - 2500,2500 - 3000,3000 - 3500,3500 - 4000,4000 - 4500,4500 - 5000,5000 - 6000,6000 - 7000,7000 - 8000,8000 - 9000,9000 - 10000,10000 +";
				selectStruct.listValues = "1-999,1000-1500,1500-2000,2000-2500,2500-3000,3000-3500,3500-4000,4000-4500,4500-5000,5000-6000,6000-7000,7000-8000,8000-9000,9000-10000,10000-900000";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
					(Square Feet)</td>
			</tr>
			<tr id="zcma-row14">
				<td>Lot Size </td>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "inquiries_lot_sqfoot";
					selectStruct.selectLabel = "-- Select --";
					selectStruct.listLabels="< 1000,1000 - 1500,1500 - 2000,2000 - 2500,2500 - 3000,3000 - 3500,3500 - 4000,4000 - 4500,4500 - 5000,5000 - 6000,6000 - 7000,7000 - 8000,8000 - 9000,9000 - 10000,10000 +";
					selectStruct.listValues = "1-999,1000-1500,1500-2000,2000-2500,2500-3000,3000-3500,3500-4000,4000-4500,4500-5000,5000-6000,6000-7000,7000-8000,8000-9000,9000-10000,10000-900000";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					(Square Feet)</td>
			</tr>
			<tr id="zcma-row15">
				<td>Garage </td>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "inquiries_garage";
					selectStruct.selectLabel = "-- Select --";
					selectStruct.listValues = "None,1 car,1.5 car,2 car,2.5 car,3 car,3.5 car,4 car";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
			</tr>
			<tr id="zcma-row16">
				<td>Location(s) </td>
				<td> 1.
					<cfscript>
					selectStruct = StructNew();
					selectStruct.name = "inquiries_location";
					selectStruct.selectLabel = "-- Select --";
					selectStruct.listValues = "Waterfront,Lake Access,Historic District,Golf Frontage,Golf Community,Riverfront,Wooded,Park Like,Mountain,Equestrian Area,Rural,Subdivision,City,Farm,Airport,Marina,Hilltop,Valley";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					2.
					<cfscript>
					selectStruct = StructNew();
					selectStruct.name = "inquiries_location2";
					selectStruct.selectLabel = "-- Select --";
					selectStruct.listValues = "Waterfront,Lake Access,Historic District,Golf Frontage,Golf Community,Riverfront,Wooded,Park Like,Mountain,Equestrian Area,Rural,Subdivision,City,Farm,Airport,Marina,Hilltop,Valley";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					3.
					<cfscript>
					selectStruct = StructNew();
					selectStruct.name = "inquiries_location3";
					selectStruct.selectLabel = "-- Select --";
					selectStruct.listValues = "Waterfront,Lake Access,Historic District,Golf Frontage,Golf Community,Riverfront,Wooded,Park Like,Mountain,Equestrian Area,Rural,Subdivision,City,Farm,Airport,Marina,Hilltop,Valley";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
			</tr>
			<tr id="zcma-row17">
				<td>Have a Pool? </td>
				<td> Yes
					<input type="radio" name="inquiries_pool" style="border:none; background:none;" value="1" <cfif application.zcore.functions.zso(form, 'inquiries_pool') EQ 1>checked="checked"</cfif> />
					No
					<input type="radio" name="inquiries_pool" style="border:none; background:none;" value="0" <cfif application.zcore.functions.zso(form, 'inquiries_pool',true) EQ 0>checked="checked"</cfif> /></td>
			</tr> 
			<tr id="zcma-row17-2">
				<td>Target Price</td>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "inquiries_target_price";
					selectStruct.selectLabel = "-- Select --";
					selectStruct.listLabels="$25,000|$50,000|$75,000|$100,000|$125,000|$150,000|$175,000|$200,000|$225,000|$250,000|$275,000|$300,000|$325,000|$350,000|$375,000|$400,000|";
					selectStruct.listValues="25000|50000|75000|100000|125000|150000|175000|200000|225000|250000|275000|300000|325000|350000|375000|400000|";
					arrPriceLabel=[];
					arrPriceValue=[];
					for(i=1;i LTE 71;i++){
						arrayAppend(arrPriceLabel, "$"&numberformat(400000+(i*50000)));
						arrayAppend(arrPriceValue, 400000+(i*50000));
					}
					arrayAppend(arrPriceLabel, "$4,000,000 or more");
					arrayAppend(arrPriceValue, "4000000");
					selectStruct.listLabels&=arrayToList(arrPriceLabel, "|");
					selectStruct.listValues&=arrayToList(arrPriceValue, "|");
					selectStruct.listLabelsDelimiter = "|"; 
					selectStruct.listValuesDelimiter = "|";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
				</td>
			</tr> 
			<tr id="zcma-row18-2">
				<td style="vertical-align:top; ">&nbsp;</td>
				<td>Other special upgrades or considerations on your home like solar?  Describe them below.</td>
			</tr>
			<tr id="zcma-row18">
				<td style="vertical-align:top; ">Comments:</td>
				<td><textarea name="inquiries_comments" cols="50" rows="5">#form.inquiries_comments#</textarea></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td><button type="submit" name="submit">Submit CMA Request</button>
					&nbsp;&nbsp;<a href="#request.zos.currentHostName#/z/user/privacy/index" target="_blank" class="zPrivacyPolicyLink">Privacy Policy</a></td>
			</tr>
			<tr id="zcma-row19">
				<td colspan="2">
        <div class="zPrivacyPolicyMessage">
   			#application.zcore.functions.zvarso("Form Privacy Message")#
		</div></td>
			</tr>
		</table>
	</form>
</cffunction>
</cfoutput>
</cfcomponent>
