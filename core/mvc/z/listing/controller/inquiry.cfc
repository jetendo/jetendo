<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" returntype="any">
	<cfscript>
	request.zos.currentURLISAListingPage=true;
	var db=request.zos.queryObject;
	var ts=0;
	var propDisplayCom=0;
	var arrMlsListings=0;
	var ps=0;
	var returnstruct=0;
	var pos=0;
	var propertyDataCom=0;
	form.inquiries_spam=0;
	variables.actionBackup=application.zcore.functions.zso(form,'method');
	if(request.cgi_script_name EQ "/z/listing/inquiry/index" or request.cgi_script_name EQ "/z/listing/sl/index"){
		form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', false, 1);
		
		request.zHideInquiryForm=true;
		if(form.modalpopforced EQ 1){
			application.zcore.template.setTag("pagetitle","Ask A Question About This Listing");
			application.zcore.template.setTag("title","Ask A Question About This Listing");
			application.zcore.functions.zSetModalWindow();
		}
		if(application.zcore.app.siteHasApp("listing") EQ false){
			application.zcore.functions.z301redirect('/');	
		}
	}
	variables.propertyHTML="";
	form.content_id=application.zcore.functions.zso(form, 'content_id');
	form.listing_id=application.zcore.functions.zso(form, 'listing_id');
	if(form.method NEQ "sent"){
		if(form.content_id&form.listing_id EQ ""){
			application.zcore.functions.z404("form.content_id and/or form.listing_id are undefined.");
		}
	}
	if(application.zcore.functions.zso(form, 'listing_id') NEQ ""){
		application.zcore.functions.zStatusHandler(request.zsid,true,true);
		form.method=variables.actionBackup;
		if(form.method NEQ 'sent' and form[request.zos.urlRoutingParameter] NEQ '/z/listing/property/detail/index'){
			propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
			ts = StructNew();
			if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
				form.inquiries_spam=1;
				form.inquiries_spam_description="Fake form fields not empty";
				//application.zcore.functions.zRedirect("/z/misc/thank-you/index");
			}
			pos=findnocase("</",application.zcore.functions.zso(form, 'inquiries_comments'));
			
			if(pos NEQ 0){
				form.inquiries_spam=1;
				form.inquiries_spam_description="Comments had html";
				//application.zcore.functions.zRedirect("/z/misc/thank-you/index");
			}
			// get select properties based on mls_id and listing_id
			ps=StructNew();
			ts.arrMLSPID=listtoarray(application.zcore.functions.zso(form, 'listing_id'));
			//ts.debug=true;
			arrMlsListings=ts.arrMLSPID;
			ts.showInactive=true;
			ts.perpage=200;
			returnStruct = propertyDataCom.getProperties(ts);
			if(returnStruct.count EQ 0){
				application.zcore.functions.zRedirect(request.zos.globals.siteroot&'/');
			}
			propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
			
			ts = StructNew();
			ts.baseCity = 'db';
			ts.datastruct=returnstruct;
			ts.searchScript=false;
			ts.compact=true;
			ts.emailFormat=true;
			propDisplayCom.init(ts);
		
			variables.propertyHTML = propDisplayCom.displayTop();	
		}
	}
	variables.contentidlist=replace(replace(application.zcore.functions.zso(form, 'content_id'),"'","","ALL"),",","','","ALL");
	if(variables.contentidlist NEQ ""){
		local.ts =structnew();
		local.ts.image_library_id_field="content.content_image_library_id";
		local.ts.count =  1; // how many images to get
		local.rs=application.zcore.imageLibraryCom.getImageSQL(local.ts);
		db.sql="SELECT * #db.trustedSQL(local.rs.select)# 
		FROM #db.table("content", request.zos.zcoreDatasource)# content 
		#db.trustedSQL(local.rs.leftJoin)# 
		WHERE content.site_id = #db.param(request.zos.globals.id)# and 
		content_id IN (#db.param((variables.contentidlist))#)  and 
		content_for_sale <> #db.param(2)# and 
		content_deleted = #db.param(0)# GROUP BY content.content_id 
		ORDER BY content_sort ASC, content_datetime DESC, content_created_datetime DESC ";
		variables.qC39821n=db.execute("qC39821n");
	}else{
		variables.qC39821n=structnew();
		variables.qC39821n.recordcount=0;
	}
	</cfscript>
</cffunction>
		
<cffunction name="send" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var myForm=structnew();
	var result=0;
	var qCity=0;
	var inputStruct=0;
	var arrList=0;
	var qinquiry=0;
	var ts=0;
	var rs=0;
	variables.init(); 
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', false, 0);
	if(application.zcore.functions.zso(form, 'inquiries_city_id') NEQ ''){
		db.sql="SELECT * FROM #db.table("city", request.zos.zcoreDatasource)# WHERE city_id = #db.param(form.inquiries_city_id)# WHERE
		city_deleted = #db.param(0)#";
		qCity=db.execute("qCity");
		if(qCity.recordcount NEQ 0){
			inquiries_property_city= qCity.city_name;
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
			//application.zcore.functions.zRedirect("/z/listing/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#&content_id=#form.content_id#&listing_id=#form.listing_id#");
		}
	}
	/*if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		form.inquiries_spam=1; 
		form.inquiries_spam_description="zset9 was wrong";
		//application.zcore.functions.zredirect('/');
	}*/
	// form validation struct
	if(structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1){
		myForm.inquiries_email.required = true;
		myForm.inquiries_email.friendlyName = "Email Address";
		myForm.inquiries_email.email = true;
	}
	myForm.inquiries_first_name.required = true;
	myForm.inquiries_first_name.friendlyName = "First Name";
	myForm.inquiries_last_name.required=true;
	myForm.inquiries_last_name.friendlyName = "Last Name";
	if(application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1){
		myForm.inquiries_phone1.required = true;
		myForm.inquiries_phone1.friendlyName = "Phone";
	}
	myForm.inquiries_datetime.createDateTime = true;
	form.inquiries_type_id = 9;
	form.inquiries_type_id_siteIdType=4;
	form.inquiries_status_id = 1;
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result eq true){	
		if(structkeyexists(form, 'x_ajax_id')){
	  		application.zcore.functions.zheader("x_ajax_id", form.x_ajax_id);
			rs={success:false, errorMessage:"Please fully complete the form and try again." };
			application.zcore.functions.zReturnJson(rs);
		}else{
			application.zcore.status.setStatus(Request.zsid, false,form,true);
			application.zcore.functions.zRedirect("/z/listing/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#&content_id=#form.content_id#&listing_id=#form.listing_id#");
		}
	}
	if(Find("@", form.inquiries_first_name) NEQ 0){
		form.inquiries_spam=1;
		form.inquiries_spam_description="@ symbol in first name";
		//application.zcore.status.setStatus(Request.zsid, "Invalid Request",form,true);
		//application.zcore.functions.zRedirect("/z/listing/inquiry/index?modalpopforced=#form.modalpopforced#&zsid=#Request.zsid#&content_id=#form.content_id#&listing_id=#form.listing_id#");
	}
	form.inquiries_session_id=application.zcore.session.getSessionId();
	 
	form.user_id=0;
	//	Insert Into Inquiry Database
	form.site_id = request.zOS.globals.id;
	form.property_id = form.listing_id;
	form.inquiries_datetime = dateformat(now(), 'yyyy-mm-dd') &" "&timeformat(now(), 'HH:mm:ss'); 
	form.inquiries_id=application.zcore.functions.zInsertLead();
	if(form.inquiries_id EQ false){
		if(structkeyexists(form, 'x_ajax_id')){
	  		application.zcore.functions.zheader("x_ajax_id", form.x_ajax_id);
			rs={success:false, errorMessage:"Please fully complete the form and try again." };
			application.zcore.functions.zReturnJson(rs);
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Your inquiry has not been sent due to an error.", false,true);
			application.zcore.functions.zRedirect("/z/listing/inquiry/index?modalpopforced=#form.modalpopforced#&content_id=#form.content_id#&listing_id=#form.listing_id#&zsid="&request.zsid);
		}
	}
	arrList=listtoarray(form.listing_id);
	db.sql="SELECT * FROM (#db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
	#db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status) 
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
	inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#) and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	inquiries_type_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id  and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE inquiries.site_id = #db.param(request.zOS.globals.id)# and 	
	inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
	inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_deleted = #db.param(0)# and 
	inquiries_status_deleted = #db.param(0)#
	 ";
	qinquiry=db.execute("qinquiry");
	application.zcore.functions.zQueryToStruct(qinquiry);

	application.zcore.tracking.setUserEmail(form.inquiries_email);
	application.zcore.tracking.setConversion('property inquiry', form.inquiries_id);
	
	if(application.zcore.functions.zso(form, 'inquiries_email') EQ "" or application.zcore.functions.zEmailValidate(form.inquiries_email) EQ false){
		form.inquiries_email=request.fromemail;
	} 
	ts=structnew();
	ts.inquiries_id=form.inquiries_id;
	ts.subject="New Property Inquiry on #request.zos.globals.shortdomain#";

	if(form.listing_id DOES NOT CONTAIN "," and form.listing_id CONTAINS "-"){ 
		db.sql="select listing_agent from #db.table("listing_memory", request.zos.zcoreDatasource)# 
		WHERE listing_id = #db.param(form.listing_id)# and 
		listing_deleted = #db.param(0)# ";
		qListing=db.execute("qListing");

		db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# 
		WHERE user_deleted = #db.param(0)# and 
		member_mlsagentid LIKE #db.param(',#listgetat(form.listing_id, 1, "-")#-#qListing.listing_agent#,')# and 
		user_active = #db.param(1)# and 
		user_autoassign_listing_inquiry = #db.param(1)# and 
		(site_id = #db.param(request.zos.globals.id)# or 
		site_id = #db.param(request.zos.globals.parentId)#)";
		qUser=db.execute("qUser"); 
		if(qUser.recordcount){
			ts.forceAssign=true;
			ts.assignUserId=qUser.user_id;
			if(qUser.site_id EQ request.zos.globals.id){
				ts.assignUserIdSiteIdType=1;
			}else{
				ts.assignUserIdSiteIdType=2;
			}
			//ts.assignEmail=qUser.user_username;
		}
	} 
	form.contact_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew()));	
	// send the lead
	rs=application.zcore.functions.zAssignAndEmailLead(ts);
	if(rs.success EQ false){
		// failed to assign/email lead
		//zdump(rs);
	} 
	ts=StructNew();
	ts.listing_type_id = application.zcore.functions.zso(form, 'inquiries_property_type');
	ts.city_id=application.zcore.functions.zso(form, 'inquiries_property_city');
	ts.rate_low=application.zcore.functions.zso(form, 'inquiries_price_low');
	ts.rate_high=application.zcore.functions.zso(form, 'inquiries_price_high');
	ts.with_pool=application.zcore.functions.zso(form, 'inquiries_pool');
	ts.bedrooms=application.zcore.functions.zso(form, 'inquiries_bedrooms');
	ts.bathrooms=application.zcore.functions.zso(form, 'inquiries_bathrooms');
	if(application.zcore.functions.zso(form, 'inquiries_sqfoot') NEQ '' and listlen(form.inquiries_sqfoot,'-') EQ 2){
		ts.sqfoot_low=listgetat(form.inquiries_sqfoot,1,'-');
		ts.sqfoot_high=listgetat(form.inquiries_sqfoot,2,'-');
	}
	ts.zIndex = 1;
	form.searchId = application.zcore.status.getNewId();
	application.zcore.status.setStatus(form.searchid,false,ts);
	

	if(structkeyexists(form, 'x_ajax_id')){
  		application.zcore.functions.zheader("x_ajax_id", form.x_ajax_id);
		rs={success:true, message:"Your inquiry was received" };
		application.zcore.functions.zReturnJson(rs);
	}else{
		application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#&zsid="&request.zsid); 
  	}
	</cfscript>
</cffunction>


<cffunction name="displayPropertyInquiryForm" localmode="modern" access="remote">
	<cfscript>
	request.ajaxListingInquiryForm=1;
	index();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var inquiryTextMissing=0;
	var r1=0;
	var backupcontentid=0;
	var ts45=0;
	var qinquiries=0;
	variables.init();
	writeoutput('<a id="cjumpform"></a>');
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', true, 0);

	echo('<div class="zListingInquiryFormHeader">');
	if(form.modalpopforced NEQ 1){
		if(application.zcore.app.siteHasApp("content")){
			inquiryTextMissing=false;
			ts=structnew();
			ts.content_unique_name='/z/listing/inquiry/index';
			ts.disableContentMeta=false;
			ts.disableLinks=true;
			ts.showmlsnumber=true;
			if(form[request.zos.urlRoutingParameter] EQ '/z/listing/inquiry/index'){
				r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
				application.zcore.template.prependTag('meta','<meta name="robots" content="noindex,follow" />');
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
			if(form[request.zos.urlRoutingParameter] EQ '/z/listing/inquiry/index'){
				application.zcore.template.setTag("title","Property Inquiry");
				application.zcore.template.setTag("pagetitle","Property Inquiry");
			}else{
				writeoutput('<h2>Property Inquiry</h2>');
			}
			if(request.CGI_SCRIPT_NAME EQ '/z/listing/property/detail/index'){
				writeoutput('<p>Submit the form below to inquire about the above property.</p>');
			}else{
				writeoutput('<p>Use this form to tell us about your interest in the selected properties.</p>
				<h2>Let us help you negotiate the best price on this property.</h2>');
			}
		}
	}else{
		application.zcore.template.setTag("title","Property Inquiry");
		application.zcore.template.setTag("pagetitle","Property Inquiry");
	}
	writeoutput('<br style="clear:both;" />	#variables.propertyHTML#');
	echo('</div>
	<div id="listingInquiryErrorDiv" class="listingInquiryErrorDiv"></div>
	<div id="listingInquirySuccessDiv" class="listingInquirySuccessDiv"></div>');
	backupcontentid=application.zcore.functions.zso(form, 'content_id');
	ts45=structnew();
	ts45.disableChildContentSummary=true;
	application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts45);
	application.zcore.app.getAppCFC("content").getPropertyInclude(0, variables.qC39821n);
	writeoutput('<p style="clear:both;">* Denotes required field.</p>');
	db.sql="SELECT *
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	WHERE inquiries_id = #db.param(-1)# and 
	site_id = #db.param(request.zOS.globals.id)# and 
	inquiries_deleted=#db.param(0)# ";
	qInquiries=db.execute("qInquiries");
	if(isdefined('error_message') EQ false){
		application.zcore.functions.zQueryToStruct(qInquiries);
		application.zcore.functions.zStatusHandler(request.zsid,true);
		form.method=variables.actionBackup;
	}
	form.set9=application.zcore.functions.zGetHumanFieldIndex();
	</cfscript> 
	<form class="zFormCheckDirty" name="listingInquiryForm" id="listingInquiryForm" action="" onsubmit="zSet9('zset9_#form.set9#'); <cfif structkeyexists(request, 'ajaxListingInquiryForm')>return zSubmitListingInquiry();<cfelse>this.action='/z/listing/inquiry/send'; return true;</cfif>" method="post">
		<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
		#application.zcore.functions.zFakeFormFields()#
		<div style="border-spacing:0px; width:98%;" class="zinquiry-form-table table">
			<div class="tr">
				<div class="th" style="width:90px;">First Name:<span class="highlight"> *</span></div>
				<div class="td"><input name="inquiries_first_name" type="text" size="30" style="width:100%" maxlength="50" value="<cfif form.inquiries_first_name EQ ''>#application.zcore.functions.zso(request.zsession, 'inquiries_first_name')#<cfelse>#form.inquiries_first_name#</cfif>" /></div>
			
			</div>
			<div class="tr">
				<div class="th" style="width:90px;">Last Name:<span class="highlight"> *</span></div>
				<div class="td"><input name="inquiries_last_name" type="text" size="30" style="width:100%" maxlength="50" value="<cfif form.inquiries_last_name EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_last_name')#<cfelse>#form.inquiries_last_name#</cfif>" /></div>
			
			</div>
			<div class="tr">
			
				<div class="th">Email:
					<cfif structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1>
						<span class="highlight"> *</span>
					</cfif></div>
				<div class="td"><input name="inquiries_email" type="text" size="30" style="width:100%" maxlength="50" value="<cfif form.inquiries_email EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_email')#<cfelse>#form.inquiries_email#</cfif>" /></div>
			
			</div>
			<div class="tr">
			
				<div class="th">Phone:
					<cfif application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1>
						<span class="highlight"> * </span>
					</cfif></div>
				<div class="td"><input name="inquiries_phone1" type="text" size="30" style="width:100%" maxlength="50" value="<cfif form.inquiries_phone1 EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_phone1')#<cfelse>#form.inquiries_phone1#</cfif>" /></div>
			
			</div>
			<div class="tr">
			
				<div class="th" style="vertical-align:top; ">Comments:</div>
				<div class="td"><textarea name="inquiries_comments" cols="50" style="width:100%" rows="5"><cfif structkeyexists(form, 'inquiries_comments')>#form.inquiries_comments#<cfelse>#form.inquiries_comments#</cfif></textarea></div>
			</div>
			<div class="tr">
			
			
				<div class="th" style="vertical-align:top; ">You are:</div>
				<div class="td"><input type="radio" name="inquiries_buyer" value="1" style="background:none; border:0px; " checked="checked" />
					Buying
					<input type="radio" name="inquiries_buyer" value="0" style="background:none; border:0px; " />
					Selling </div>
			
			</div>
			<div class="tr">
				<div class="th">&nbsp;</div>
				<div class="td"><button type="submit" name="submit">Send Inquiry</button>
					&nbsp;&nbsp;<a href="#request.zos.currentHostName#/z/user/privacy/index" rel="external" onclick="window.open('/z/user/privacy/index');return false;" class="zPrivacyPolicyLink">Privacy Policy</a>
					<input type="hidden" name="listing_id" value="#htmleditformat(form.listing_id)#" />
					<cfif application.zcore.app.siteHasApp("listing")>
						<input type="hidden" name="content_id" value="#htmleditformat(variables.contentIdList)#" />
					</cfif></div>
			
			</div>
			
		</div>
			<cfscript>
			v=application.zcore.functions.zvarso("Form Privacy Message");
			if(v NEQ ""){ 
				echo('<div class="zPrivacyPolicyMessage">#v#</div>');
			}
			</cfscript>
		<cfif form.modalpopforced EQ 1>
			<input type="hidden" name="modalpopforced" value="1" />
			<input type="hidden" name="js3811" id="js3811" value="" />
			<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
		</cfif>
	</form> 
</cffunction> 
</cfoutput>
</cfcomponent>
