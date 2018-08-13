<cfcomponent>
<cfoutput>
<!--- 
All features of contact.cfc should allow specifying a different site_id, so that it can run in a single thread cron job or on a specific site.
 --->


<!--- 
ts={ 
	dataStruct:inquiryDataStruct,
	site_id:request.zos.globals.id
};
rs=storeContactForInquiry(ts);
if(rs.success){
	// associate to record
	// form.contact_id=rs.contact_id;
}
 --->
<cffunction name="storeContactForInquiry" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={
		site_id:request.zos.globals.id
	};
	ss=arguments.ss;
	ds=ss.dataStruct;
	structappend(ss, ts, false);
	db=request.zos.queryObject;
 
	phone=ds.inquiries_phone1_formatted;
	phone2=ds.inquiries_phone2_formatted;
	phone3=ds.inquiries_phone3_formatted;
	email=trim(ds.inquiries_email);

	if(len(phone) < 7 and len(phone2) < 7 and len(phone3) < 7 and len(email) < 5){
		// can't make a contact record without a unique phone or email.
		return { success:false};
	}

	db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)# where 
	(";
	if(phone NEQ ""){
		db.sql&=" contact_phone1_formatted = #db.param(phone)# or contact_phone2_formatted = #db.param(phone)# or contact_phone3_formatted = #db.param(phone)# ";
	}
	if(phone2 NEQ ""){
		if(phone NEQ ""){
			db.sql&=" or ";
		}
		db.sql&=" contact_phone1 = #db.param(phone2)# or contact_phone2_formatted = #db.param(phone2)# or contact_phone3_formatted = #db.param(phone2)# ";
	}
	if(phone3 NEQ ""){
		if(phone NEQ "" or phone2 NEQ ""){
			db.sql&=" or ";
		}
		db.sql&=" contact_phone1_formatted = #db.param(phone3)# or contact_phone2_formatted = #db.param(phone3)# or contact_phone3_formatted = #db.param(phone3)# ";
	}
	if(email NEQ ""){
		if(phone NEQ "" or phone2 NEQ "" or phone3 NEQ ""){
			db.sql&=" or ";
		}
		db.sql&=" contact_email=#db.param(email)# ";
	}
	db.sql&=" ) and 
	contact_deleted=#db.param(0)# and 
	site_id=#db.param(ss.site_id)# 
	ORDER BY contact_parent_id ASC
	LIMIT #db.param(0)#, #db.param(1)# ";
	qContact=db.execute("qContact");

	if(qContact.recordcount NEQ 0){
		return {success:true, contact_id:qContact.contact_id}
	} 
	cs={}; 
	cs=mapInquiryDataToContactData(ss.dataStruct, cs);
 	
	t2={
		struct:cs,
		datasource:request.zos.zcoreDatasource,
		table:"contact"
	}; 
	contact_id=application.zcore.functions.zInsert(t2);
	return {success:true, contact_id:contact_id}; 
	</cfscript>
</cffunction>

<cffunction name="mapInquiryDataToContactData" localmode="modern" access="public">
	<cfargument name="inquiryData" type="struct" required="yes">
	<cfargument name="contactData" type="struct" required="yes">
	<cfscript>
	ds=arguments.inquiryData;
	cs=arguments.contactData;
 
	cs.site_id=ds.site_id; 
	// need phone to be formatted here to guarantee a match
	/*
	if(cs.contact_phone1_formatted EQ phone or cs.contact_phone2_formatted EQ phone or cs.contact_phone3_formatted EQ phone){
		// leave as is
	}else if(cs.contact_phone1_formatted EQ ""){
		cs.contact_phone1=ds.inquiries_phone1;
		cs.contact_phone1_formatted=phone;
	}else if(cs.contact_phone2_formatted EQ ""){
		cs.contact_phone2=ds.inquiries_phone1;
		cs.contact_phone2_formatted=phone;
	}else if(cs.contact_phone3_formatted EQ ""){
		cs.contact_phone3=ds.inquiries_phone1;
		cs.contact_phone3_formatted=phone;		
	}
	if(cs.contact_email NEQ email){
		cs.contact_email=email;
	}*/

	cs.contact_deleted=0;
	cs.office_id=application.zcore.functions.zso(ds, 'office_id'); 

	cs.contact_company=application.zcore.functions.zso(ds, 'inquiries_company');
	//cs.contact_salutation
	cs.contact_first_name=application.zcore.functions.zso(ds, 'inquiries_first_name');
	cs.contact_last_name=application.zcore.functions.zso(ds, 'inquiries_last_name');
	cs.contact_address=application.zcore.functions.zso(ds, 'inquiries_address');
	cs.contact_city=application.zcore.functions.zso(ds, 'inquiries_city');
	cs.contact_state=application.zcore.functions.zso(ds, 'inquiries_state');
	cs.contact_country=application.zcore.functions.zso(ds, 'inquiries_country');
	cs.contact_postal_code=application.zcore.functions.zso(ds, 'inquiries_zip');

	cs.contact_email=application.zcore.functions.zso(ds, 'inquiries_email');
	cs.contact_phone1=application.zcore.functions.zso(ds, 'inquiries_phone1');
	cs.contact_phone2=application.zcore.functions.zso(ds, 'inquiries_phone2');
	cs.contact_phone3=application.zcore.functions.zso(ds, 'inquiries_phone3');
	cs.contact_phone1_formatted=application.zcore.functions.zso(ds, 'inquiries_phone1_formatted');
	cs.contact_phone2_formatted=application.zcore.functions.zso(ds, 'inquiries_phone2_formatted');
	cs.contact_phone3_formatted=application.zcore.functions.zso(ds, 'inquiries_phone3_formatted');
	cs.office_id=application.zcore.functions.zso(ds, 'office_id');

	cs.contact_interested_in_model=application.zcore.functions.zso(ds, 'inquiries_interested_in_model');
	cs.contact_interest_level=application.zcore.functions.zso(ds, 'inquiries_interest_level');
	cs.contact_interested_in_category=application.zcore.functions.zso(ds, 'inquiries_interested_in_category');

	cs.contact_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	cs.contact_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	cs.contact_key=hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256');
	cs.contact_des_key=GenerateSecretKey("des"); 

	// don't need these yet
	//cs.contact_suffix
	//cs.contact_job_title
	//cs.contact_birthday  
	//cs.contact_spouse_first_name
	//cs.contact_spouse_suffix
	//cs.contact_spouse_job_title
	//cs.contact_lead_source
	//cs.contact_form_name
	//cs.contact_received_date
	//cs.contact_interests
	/*cs.contact_interested_in_type
	cs.contact_interested_in_year
	cs.contact_interested_in_make
	cs.contact_interested_in_model
	cs.contact_interested_in_category
	cs.contact_interested_in_name
	cs.contact_interested_in_hin_vin
	cs.contact_interested_in_stock
	cs.contact_interested_in_length
	cs.contact_interested_in_currently_owned_type
	cs.contact_interested_in_read
	cs.contact_interested_in_age
	cs.contact_interested_in_email
	cs.contact_interested_in_email_alternate
	cs.contact_interested_in_bounce_reason
	cs.contact_interested_in_home_phone
	cs.contact_interested_in_work_phone
	cs.contact_interested_in_mobile_phone
	cs.contact_interested_in_fax
	cs.contact_interested_in_buying_horizon
	cs.contact_interested_in_status
	cs.contact_interested_in_interest_level
	cs.contact_interested_in_sales_stage
	cs.contact_interested_in_date_added
	cs.contact_interested_in_date_updated
	cs.contact_interested_in_contact_source
	cs.contact_interested_in_dealership
	cs.contact_interested_in_assigned_to
	cs.contact_interested_in_bounced_email
	cs.contact_interested_in_owners_magazine
	cs.contact_interested_in_purchased
	cs.contact_interested_in_service_date
	cs.contact_interested_in_date_delivered
	cs.contact_interested_in_date_sold
	cs.contact_interested_in_warranty_date
	cs.contact_interested_in_lead_comments
	*/
	return cs;
	</cfscript>
</cffunction>


<!--- 
contactCom.updateContactEmail(oldEmail, newEmail, site_id);
 --->
<cffunction name="updateContactEmail" localmode="modern" access="public">
	<cfargument name="oldEmail" type="string" required="yes">
	<cfargument name="newEmail" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	// we can't automatically eliminate old contact_id without possibly losing data or breaking the from addresses already distributed.
	// this code links all contact records together so that we can keep old contact_id forever, and still have a main record for the purposes of consolidating views of contacts.
	db.sql="SELECT contact_id from #db.table("contact", request.zos.zcoreDatasource)# 
	WHERE 
	contact_email = #db.param(arguments.newEmail)# and 
	site_id = #db.param(arguments.site_id)# and 
	contact_parent_id=#db.param(0)# and
	contact_deleted=#db.param(0)# ";
	qContact=db.execute("qContact");
	if(qContact.recordcount EQ 0){
		// update contact email 
		db.sql="update #db.table("contact", request.zos.zcoreDatasource)# SET 
		contact_email = #db.param(arguments.newEmail)#, 
		contact_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE 
		site_id = #db.param(arguments.site_id)# and 
		contact_email=#db.param(arguments.oldEmail)# and 
		contact_deleted=#db.param(0)# ";
		db.execute("qUpdate");
	}else{ 
		db.sql="update #db.table("contact", request.zos.zcoreDatasource)# SET 
		contact_email = #db.param(arguments.newEmail)#, 
		contact_parent_id=#db.param(qContact.contact_id)#, 
		contact_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE 
		site_id = #db.param(arguments.site_id)# and  
		contact_email = #db.param(arguments.oldEmail)# and 
		contact_deleted=#db.param(0)# ";
		db.execute("qUpdate");
	}
	</cfscript>
</cffunction>

<!---  
ts={ 
	contact_id:"", // required
	debug:false,
	inquiries_id:"", // required to exist
	validHash:true, 
	privateMessage:false,
	dontEmailFromContact:false, 
	enableCopyToSelf:false,  // set to true to allow the sender to receive a copy of his own message.
	messageStruct:{}, // queue_pop struct
	jsonStruct:{} // decoded json queue_pop_message_json
	// optionally filter the contacts by various parameters
	,
	filterContacts:{
		// remove one or more of these to remove filters. these filters use "or", not "and" logic
		managers:true,
		offices:[office_id],
		userGroupIds:[user_group_id]
	},
	emailFileAttachments:[]
	// optional set the new status id
	,inquiries_status_id:3
};
contactCom.processMessage(ts);
 --->
<cffunction name="processMessage" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>	
	db=request.zos.queryObject;
	ss=arguments.ss;
	ts={
		dontEmailFromContact:false
	};
	structappend(ss, ts, false);
	//echo('processMessage');
	//writedump(ss);
 	debug=false;
 	if(structkeyexists(ss, 'debug')){
 		debug=ss.debug;
 	} 
	// remember, we must individually address each email because from address must be different for each one

	//	get inquiries record
	db.sql="SELECT * FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(ss.messageStruct.site_id)# and 
	inquiries_deleted=#db.param(0)# and 
	inquiries_id=#db.param(ss.inquiries_id)#";
	qInquiry=db.execute("qInquiry");
	if(qInquiry.recordcount EQ 0){
		// invalid request, we can store this as a new lead, or discard the message.
		// for now, we discard the message by returning true
		// TODO: inquiry creation code was already handled in send-message if we ever want to integrate that here instead for incoming imap.
		if(debug){
			echo('inquiry missing<br>');
		}
		return {success:true};
	}
	inquiryStruct={};
	for(row in qInquiry){
		inquiryStruct=row;
	}

	notifyStruct=getNotificationListForInquiry(ss, inquiryStruct);
	emailSendStruct=notifyStruct.emailSendStruct;
	fromContact=notifyStruct.fromContact;
	mainContact=notifyStruct.mainContact;

	if(debug){
		echo('Final email list for outgoing email<br>');
		writedump(notifyStruct.emailSendStruct);
	}
	processedHTML=buildFeedbackWebmail(ss);
	if(structkeyexists(ss.jsonStruct, 'htmlWeb') and ss.jsonStruct.htmlWeb NEQ ""){
		ss.jsonStruct.htmlProcessed=ss.jsonStruct.htmlWeb;
	}else{
		ss.jsonStruct.htmlProcessed=processedHTML;
	}

	// insert to inquiries_feedback
	tsFeedback={
		table:"inquiries_feedback",
		datasource:request.zos.zcoreDatasource,
		struct:{
			inquiries_feedback_subject:ss.jsonStruct.subject,
			inquiries_feedback_comments:"", // leave empty because this is an email message.
			inquiries_feedback_datetime:ss.jsonStruct.date,
			inquiries_id:ss.inquiries_id,
			//user_id:user_id,
			contact_id:notifyStruct.fromContact.contact_id, 
			site_id:ss.messageStruct.site_id,
			//user_id_siteIDType:user_id_siteIDType, 
			inquiries_feedback_created_datetime:ss.jsonStruct.date,
			inquiries_feedback_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
			inquiries_feedback_deleted:0,
			inquiries_feedback_message_json:serializeJSON(ss.jsonStruct), 
			inquiries_feedback_draft:0,
			inquiries_feedback_download_key:hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256'),
			inquiries_feedback_type:1 // 0 is private note, 1 is email
		}
	} 
	if(ss.privateMessage){
		tsFeedback.struct.inquiries_feedback_type=0;
	}

	// build email html  
	inquiries_feedback_id=application.zcore.functions.zInsert(tsFeedback);
 

	ss.inquiries_feedback_id=inquiries_feedback_id;
	if(not inquiries_feedback_id){
		if(debug){
			echo('Failed to insert feedback record<br>');
		}
		return {success:false, errorMessage:"Failed to save to inquiries_feedback"};
	}
	if(debug){
		echo('Inserted feedback record<br>');
	}  
	arrEmail=[];
	ss.inquiries_feedback_download_key=tsFeedback.struct.inquiries_feedback_download_key;  
	ss.jsonStruct.htmlProcessed=processedHTML; 
	if(request.zos.isdeveloper){
		//writedump(notifyStruct.emailSendStruct);
	} 
	for(type in notifyStruct.emailSendStruct){
		typeStruct=notifyStruct.emailSendStruct[type];
		for(i=1;i<=arraylen(typeStruct);i++){     
			if(structcount(notifyStruct.mainContact) EQ 0){
				rs=buildFeedbackEmail(ss, 0, typeStruct[i].email, typeStruct[i].isUser, typeStruct[i].isAssignedUser, typeStruct[i].isManagerUser);
			}else{
				rs=buildFeedbackEmail(ss, notifyStruct.mainContact.contact_id, typeStruct[i].email, typeStruct[i].isUser, typeStruct[i].isAssignedUser, typeStruct[i].isManagerUser);
			}
			rs.subject=ss.jsonStruct.subject;
			rs.from=typeStruct[i].email;
			rs.to=typeStruct[i].originalEmail;
			if(debug){
				echo(rs.html&'<hr>');
			}
			arrayAppend(arrEmail, rs);
		}
	}  
  
	// change inquiry status to contacted if it is still a new lead status and the response wasn't detected as a non-human reply or the original sender.
	ss.inquiries_status_id=application.zcore.functions.zso(ss, "inquiries_status_id", true, 0);
	if(ss.inquiries_status_id NEQ 0){ 
		db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# 
		SET inquiries_status_id=#db.param(ss.inquiries_status_id)#, 
		inquiries_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# 
		WHERE inquiries_id=#db.param(ss.inquiries_id)# and 
		site_id = #db.param(ss.messageStruct.site_id)# and  
		inquiries_deleted=#db.param(0)# ";
		db.execute("qUpdateInquiry");  
	}else if(not ss.privateMessage and (structcount(notifyStruct.mainContact) EQ 0 or notifyStruct.mainContact.contact_id NEQ notifyStruct.fromContact.contact_id) and ss.jsonStruct.humanReplyStruct.score > 0 and structkeyexists(notifyStruct.fromContact, 'isAssignedUser') and fromContact.isAssignedUser){ 
		if(qInquiry.inquiries_status_id EQ 2){
			newStatusId=3;		
		}else if(qInquiry.inquiries_status_id EQ 1){
			newStatusId=6;		
		}else{
			newStatusId=3;
		}
		db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# 
		SET inquiries_status_id=#db.param(newStatusId)#, 
		inquiries_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# 
		WHERE inquiries_id=#db.param(ss.inquiries_id)# and 
		inquiries_status_id IN (#db.param(1)#, #db.param(2)#) and 
		site_id = #db.param(ss.messageStruct.site_id)# and  
		inquiries_deleted=#db.param(0)# ";
		db.execute("qUpdateInquiry"); 
	}else{
		// update date
		db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# 
		SET 
		inquiries_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# 
		WHERE inquiries_id=#db.param(ss.inquiries_id)# and 
		site_id = #db.param(ss.messageStruct.site_id)# and 
		inquiries_deleted=#db.param(0)# ";
		db.execute("qUpdateInquiry"); 
	}
	inquiriesCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	inquiriesCom.indexInquiry(ss.inquiries_id, ss.messageStruct.site_id);

	if(request.zos.isdeveloper){
		//writedump(arrEmail);		abort;
	}
	arrError=[];
	for(emailStruct in arrEmail){
		if(request.zos.istestserver){
			emailStruct.html=replace(emailStruct.html, '</body>', '<p>Test server debug message: This email would have been sent to #emailStruct.to#</p></body>');
			emailStruct.to=request.zos.developerEmailTo;
			emailStruct.cc="";
			emailStruct.bcc="";  
		}
		if(application.zcore.functions.zvar("enablePlusEmailRouting", ss.messageStruct.site_id, 0) EQ 0){
			emailStruct.from=request.fromEmail;
			if(structcount(notifyStruct.mainContact) NEQ 0){
				emailStruct.replyTo=notifyStruct.mainContact.contact_email;
			}
		}
		/*
		// TODO: remove when we're done testing:
		emailStruct.to=request.zos.developerEmailTo;
		emailStruct.cc="";
		emailStruct.bcc="";
  		*/
  		if(structkeyexists(ss, 'emailFileAttachments')){
  			emailStruct.attachments=ss.emailFileAttachments;
  		}

		rCom=application.zcore.email.send(emailStruct);
		if(rCom.isOK() EQ false){
			savecontent variable="out"{
				writedump(emailStruct);
			}
			arrayAppend(arrError, '<h3>Failed to send email inquiries_feedback_id=#ss.inquiries_feedback_id#</h3><br>'&out);
		}
	}

	if(arraylen(arrError) NEQ 0){
		savecontent variable="out"{
			echo('<h3>Send email error - site_id: #ss.messageStruct.site_id# | inquiries_feedback_id: #ss.inquiries_feedback_id#</h3>');
			echo('<p>Note: This is no way automated way implemented to resend failed email(s).</p>'); 
			writedump(arrError); 
		}
		ts={
			type:"Custom",
			errorHTML:e,
			scriptName:'/z/com/app/contact/processMessage',
			url:request.zos.originalURL,
			exceptionMessage:'Failed to send email when processing a message',
			// optional
			lineNumber:'710'
		}
		application.zcore.functions.zLogError(ts);
	} 
 
	/*
	// maybe consider a queue email send method someday
	var ts = {
		forceUniqueType: true, // prevent multiple scheduled emails of the same type
		// required
		data: {
			inquiries_type_id: '',
			inquiries_type_id_siteIDType: '',
			email_queue_unique: '1', // 1 is unique and 0 allows multiple entries for this type for the same email_queue_to address.
			email_queue_from: jsonStruct.from.name & ' <' & jsonStruct.from.email & '>',
			email_queue_to: to,
			email_queue_subject: jsonStruct.subject,
			email_queue_html: jsonStruct.html,
			email_queue_send_datetime: dateAdd( 'm', 30, now() ),
			// optional
			email_queue_cc: cc,
			email_queue_bcc: '',
			email_queue_text: jsonStruct.text,
			site_id: ss.messageStruct.site_id
		}
	};

	writedump( ts );
	abort;

	// var rs = request.contactCom.scheduleLeadEmail( ts );

	var rs = {
		success: false
	}; 
	if ( rs.success ) {

	} else { 
	}
	*/
	if(debug){
		abort;
	}
	cs={
		success:true
	};
	return cs;
	</cfscript>
</cffunction>	


<cffunction name="getNotificationListForInquiry" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="inquiryStruct" type="struct" required="yes">
	<cfscript>	
	db=request.zos.queryObject;
	inquiryStruct=arguments.inquiryStruct;
	ss=arguments.ss; 
 	debug=false;
 	if(structkeyexists(ss, 'debug')){
 		debug=ss.debug;
 	} 
	emailStruct={};

	// get the from contact data
	fromContactId=ss.contact_id;
	fromContact = this.getContactById( fromContactId, ss.messageStruct.site_id );
	skipEmail="";
	if(structcount(fromContact) EQ 0){
		// we discard the message for now since this is a non-existant contact.
		if(debug){
			echo('from contact missing<br>');
		}
		fromContact={
			contact_id:0,
			isAssignedUser:false,
			addressType:""
		};
		//return {success:true};
	}else{
		// tested successfully
		if(fromContact.contact_email NEQ ""){
			skipEmail=fromContact.contact_email;
			ts={
				site_id:ss.messageStruct.site_id,
				contact_id:fromContact.contact_id,
				contact_des_key:fromContact.contact_des_key,
				contact_email:fromContact.contact_email,
				contact_first_name:fromContact.contact_first_name,
				contact_last_name:fromContact.contact_last_name, 
				office_id:fromContact.office_id,
				user_group_id:fromContact.user_group_id,
				user_id:fromContact.user_id,
				user_id_siteidtype:fromContact.user_id_siteidtype,
				isUser:fromContact.isUser,
				isManagerUser:fromContact.isManagerUser,
				addressTypeId:"1",
				addressType:"to" // to, cc, bcc (bcc is visible only to internal users)
			};

			if(ss.dontEmailFromContact EQ false){
				emailStruct[fromContact.contact_email]=ts;
			}
		}
		if(ss.jsonStruct.from.name NEQ ""){
			if(debug){
				echo('From contact id #fromContact.contact_id# From name is: #ss.jsonStruct.from.name# from email: #fromContact.contact_email# |  db version: #fromContact.contact_first_name# #fromContact.contact_last_name#<br>');
			}
			if(fromContact.contact_first_name EQ "" and fromContact.contact_last_name EQ ""){
				firstName="";
				lastName=""; 
				if(trim(ss.jsonStruct.from.name) CONTAINS " "){
					firstName=listGetAt(ss.jsonStruct.from.name, 1, " ");
					lastName=trim(listDeleteAt(ss.jsonStruct.from.name, 1, " "));
				}else{
					firstName=ss.jsonStruct.from.name;
				}  
				fromContact.contact_first_name=firstName;
				fromContact.contact_last_name=lastName;
				db.sql="update #db.table("contact", request.zos.zcoreDatasource)# SET 
				contact_first_name=#db.param(fromContact.contact_first_name)#, 
				contact_last_name=#db.param(fromContact.contact_last_name)#, 
				contact_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# 
				WHERE 
				contact_id = #db.param(fromContact.contact_id)# and 
				contact_deleted=#db.param(0)# and 
				site_id=#db.param(ss.messageStruct.site_id)#";
				db.execute("qUpdate"); 
				if(debug){
					echo('Fixed missing name on from contact<br>');
				}

			}
		}
	}
	// get the main contact who sent original message
	// tested successfully
	if(inquiryStruct.contact_id EQ 0){
		// convert inquiries_email into contact_id
		mainContact=getContactByEmail(inquiryStruct.inquiries_email, trim(inquiryStruct.inquiries_first_name&" "&inquiryStruct.inquiries_last_name), ss.messageStruct.site_id);
		if(structcount(mainContact) NEQ 0){
			db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# SET 
			contact_id=#db.param(mainContact.contact_id)#, 
			inquiries_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# 
			WHERE 
			inquiries_id = #db.param(ss.inquiries_id)# and 
			inquiries_deleted=#db.param(0)# and 
			site_id=#db.param(ss.messageStruct.site_id)#";
			db.execute("qUpdate"); 
			if(debug){
				echo('added contact_id, #mainContact.contact_id#, to inquiries for the main contact<br>');
			}
		}
	}else{
		mainContact = this.getContactById(inquiryStruct.contact_id, ss.messageStruct.site_id );
	}
	// tested successfully
	// send to main contact if they are not the current message sender.
	if(structcount(mainContact) NEQ 0){ 
		if(mainContact.contact_id NEQ fromContactId or (ss.enableCopyToSelf)){
			ts={
				site_id:ss.messageStruct.site_id,
				contact_id:mainContact.contact_id,
				contact_des_key:mainContact.contact_des_key,
				contact_email:mainContact.contact_email,
				contact_first_name:mainContact.contact_first_name,
				contact_last_name:mainContact.contact_last_name, 
				office_id:mainContact.office_id,
				user_group_id:mainContact.user_group_id,
				user_id:mainContact.user_id,
				user_id_siteidtype:mainContact.user_id_siteidtype,
				isUser:mainContact.isUser,
				isManagerUser:mainContact.isManagerUser,
				addressTypeId:"2",
				addressType:"to" // to, cc, bcc (bcc is visible only to internal users)
			};
			emailStruct[mainContact.contact_email]=ts;
			if(debug){
				echo('Added main contact, #mainContact.contact_email#, to outgoing email<br>');
			}
		}
	}
 

	// get all the contacts subscribed to the current inquiry
	// tested successfully
	parentId=application.zcore.functions.zvar("parentId", ss.messageStruct.site_id);
	db.sql="SELECT contact.*, inquiries_x_contact.*, user.user_group_id, user.office_id userOfficeId, user.user_id, user.site_id userSiteId FROM 
	(#db.table("contact", request.zos.zcoreDatasource)#, 
	#db.table("inquiries_x_contact", request.zos.zcoreDatasource)# )
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# ON 
	user_username=contact_email and 
	user.site_id IN (#db.param(ss.messageStruct.site_id)#, ";
	if(parentId NEQ 0){
		db.sql&=" #db.param(parentId)#, ";
	}
	db.sql&=" #db.param(request.zos.globals.serverId)# ) and
	user_active=#db.param(1)# and 
	user_deleted=#db.param(0)# 
	WHERE 
	inquiries_x_contact.site_id = contact.site_id and 
	inquiries_x_contact.contact_id = contact.contact_id and 
	inquiries_x_contact.inquiries_x_contact_deleted=#db.param(0)# and 
	contact.site_id = #db.param(ss.messageStruct.site_id)# and 
	contact_deleted=#db.param(0)# and 
	inquiries_x_contact.inquiries_id=#db.param(ss.inquiries_id)#";
	qContact=db.execute("qContact"); 
	subscribedStruct={};
	for(row in qContact){
		if(not structkeyexists(emailStruct, row.contact_email)){
			subscribedStruct[row.contact_email]=true;
			ts={
				site_id:ss.messageStruct.site_id,
				contact_id:row.contact_id,
				contact_des_key:row.contact_des_key,
				contact_email:row.contact_email,
				contact_first_name:row.contact_first_name,
				contact_last_name:row.contact_last_name,
				office_id:row.userOfficeId,
				user_id:0,
				user_id_siteidtype:0,
				user_group_id:row.user_group_id,
				isUser:false,
				isManagerUser:false,
				addressTypeId:"3",
				addressType:row.inquiries_x_contact_type // to, cc, bcc (bcc is visible only to internal users)
			};
			if(row.userSiteId NEQ ""){
				ts.user_id=row.user_id;
				ts.user_id_siteidtype=application.zcore.functions.zGetSiteIdType(row.userSiteId, ss.messageStruct.site_id);
				ts.isUser=true; 
				if(application.zcore.user.groupIdHasAccessToGroup(row.user_group_id, "member", row.userSiteId)){
					ts.isManagerUser=true;
				}else{
					ts.isManagerUser=false;
				}
			}
			emailStruct[row.contact_email]=ts;
			if(debug){
				echo('Added contact id, #row.contact_id# | #row.contact_email#, to outgoing email<br>');
			}
		}
	}

	assignedEmailStruct={};
	// tested successfully
	if(inquiryStruct.office_id NEQ 0){

		ts={
			ids:[inquiryStruct.office_id],
			site_id:ss.messageStruct.site_id
		}
		arrOffice=application.zcore.user.getOffices(ts); 
		for(row in arrOffice){
			if(row.office_manager_email_list EQ ""){
				continue;
			}
			arrEmail=listToArray(row.office_manager_email_list, ",");
			for(email in arrEmail){
				contact=getContactByEmail(trim(email), "", ss.messageStruct.site_id);
				if(structcount(contact) NEQ 0){
					ts={
						site_id:ss.messageStruct.site_id,
						contact_id:contact.contact_id,
						contact_des_key:contact.contact_des_key,
						contact_email:contact.contact_email,
						contact_first_name:contact.contact_first_name,
						contact_last_name:contact.contact_last_name, 
						office_id:contact.office_id,
						user_group_id:contact.user_group_id,
						user_id:contact.user_id,
						user_id_siteidtype:contact.user_id_siteidtype,
						isUser:contact.isUser,
						isManagerUser:contact.isManagerUser,
						addressTypeId:"4",
						addressType:"cc"
					};
					assignedEmailStruct[contact.contact_email]=true;
					emailStruct[contact.contact_email]=ts;
					if(debug){
						echo('Added office manager email list contact, #contact.contact_email#, to outgoing email<br>');
					}
				}
			}
		}
	}
	// tested successfully
	if(inquiryStruct.inquiries_assign_email NEQ ""){ 
		arrEmail=listToArray(inquiryStruct.inquiries_assign_email, ",");
		for(email in arrEmail){
			contact=getContactByEmail(trim(email), inquiryStruct.inquiries_assign_name, ss.messageStruct.site_id);
			if(structcount(contact) NEQ 0){
				ts={
					site_id:ss.messageStruct.site_id,
					contact_id:contact.contact_id,
					contact_des_key:contact.contact_des_key,
					contact_email:contact.contact_email,
					contact_first_name:contact.contact_first_name,
					contact_last_name:contact.contact_last_name, 
					office_id:contact.office_id,
					user_group_id:contact.user_group_id,
					user_id:contact.user_id,
					user_id_siteidtype:contact.user_id_siteidtype,
					isUser:contact.isUser,
					isManagerUser:contact.isManagerUser,
					addressTypeId:"5",
					addressType:"to"
				};
				assignedEmailStruct[contact.contact_email]=true;
				emailStruct[contact.contact_email]=ts; 
				if(debug){
					echo('Added inquiries assign email contact, #contact.contact_email#, to outgoing email<br>');
				}
			}
		}
	}
	// tested successfully
	if(inquiryStruct.user_id NEQ "0"){ 
		// get assigned user, and their user_alternate_email
		db.sql="select contact.*, user_alternate_email, user_username, user_first_name, user.office_id userOfficeId, user_last_name, user.user_id, user.user_group_id, user.site_id userSiteId from 
		#db.table("user", request.zos.zcoreDatasource)# 
		LEFT JOIN #db.table("contact", request.zos.zcoreDatasource)# ON 
		user_username=contact_email and  
		contact.site_id=#db.param(ss.messageStruct.site_id)# and 
		contact_deleted=#db.param(0)# 
		where 
		user.site_id = #db.param(application.zcore.functions.zGetSiteIdFromSiteIdType(inquiryStruct.user_id_siteIDType, ss.messageStruct.site_id))# and 
		user.user_id = #db.param(inquiryStruct.user_id)# and 
		user_active=#db.param(1)# and  
		user_deleted=#db.param(0)#"; // write query
		qUser=db.execute("qUser"); 
		for(row in qUser){
			if(row.user_alternate_email NEQ ""){
				// tested successfully
				arrTempEmail=listToArray(row.user_alternate_email, ",");
				for(email in arrTempEmail){
					contact=getContactByEmail(trim(email), trim(row.contact_first_name&" "&row.contact_last_name), ss.messageStruct.site_id);
					if(structcount(contact) NEQ 0){
						ts={
							site_id:ss.messageStruct.site_id,
							contact_id:contact.contact_id,
							contact_des_key:contact.contact_des_key,
							contact_email:contact.contact_email,
							contact_first_name:contact.contact_first_name,
							contact_last_name:contact.contact_last_name, 
							user_group_id:contact.user_group_id,
							office_id:contact.office_id,
							user_id:contact.user_id,
							user_id_siteidtype:contact.user_id_siteidtype,
							isUser:contact.isUser,
							isManagerUser:contact.isManagerUser,
							addressTypeId:"6",
							addressType:"to"
						};
						emailStruct[contact.contact_email]=ts;
						if(debug){
							echo('Added inquiry assigned user alternate cc contact, #contact.contact_email#, to outgoing email<br>');
						}
					}
				}
			}
			if(row.contact_id EQ ""){ 
				// tested successfully
				contact=getContactByEmail(trim(row.user_username), trim(row.user_first_name&" "&row.user_last_name), ss.messageStruct.site_id);
				if(structcount(contact) NEQ 0){ 
					ts={
						site_id:ss.messageStruct.site_id,
						contact_id:contact.contact_id,
						contact_des_key:contact.contact_des_key,
						contact_email:contact.contact_email,
						contact_first_name:contact.contact_first_name,
						contact_last_name:contact.contact_last_name,
						user_group_id:contact.user_group_id,
						office_id:contact.office_id,
						user_id:contact.user_id,
						user_id_siteidtype:contact.user_id_siteidtype,
						isUser:contact.isUser,
						isManagerUser:contact.isManagerUser,
						addressTypeId:"7",
						addressType:"to"
					};
					emailStruct[contact.contact_email]=ts; 
					row.contact_email=contact.contact_email;
					if(debug){
						echo('Added inquiry assigned user contact, #row.contact_email#, to outgoing email<br>');
					}
				}
			}else{
				ts={
					site_id:ss.messageStruct.site_id,
					contact_id:row.contact_id,
					contact_des_key:row.contact_des_key,
					contact_email:row.contact_email,
					contact_first_name:row.contact_first_name,
					contact_last_name:row.contact_last_name,
					user_group_id:row.user_group_id,
					office_id:row.userOfficeId,
					user_id:row.user_id,
					user_id_siteidtype:application.zcore.functions.zGetSiteIdType(row.userSiteId, ss.messageStruct.site_id),
					isUser:true,
					isManagerUser:false,
					addressTypeId:"8",
					addressType:"to"
				};

				if(application.zcore.user.groupIdHasAccessToGroup(row.user_group_id, "member", row.userSiteId)){
					ts.isManagerUser=true;
				}else{
					ts.isManagerUser=false;
				} 
				emailStruct[row.contact_email]=ts; 
				if(debug){
					echo('Added inquiry assigned user contact, #row.contact_email#, to outgoing email<br>');
				}
			}
		}
	}
	if(request.zos.isDeveloper){
		//writedump(emailStruct);	abort;
	}
	// anyone missing still who was addressed in the email? force creation of a new "contact" record, and add that email here. 
	// tested successfully
	arrType=["to", "cc"]; 
	for(type in arrType){
		for(row in ss.jsonStruct[type]){
			if(not structkeyexists(emailStruct, row.email) or (not structkeyexists(subscribedStruct, row.email) and row.email EQ fromContact.contact_email)){
				// insert to inquiries_x_contact as to
				contact=getContactByEmail(row.email, row.name, ss.messageStruct.site_id);
				if(structcount(contact) NEQ 0){
					ts={
						table:"inquiries_x_contact",
						datasource:request.zos.zcoreDatasource,
						struct:{
							contact_id:contact.contact_id, 
							inquiries_id:ss.inquiries_id, 
							site_id:ss.messageStruct.site_id, 
							inquiries_x_contact_type:type, 
							inquiries_x_contact_deleted:0,
							inquiries_x_contact_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss")
						}
					};
					application.zcore.functions.zInsert(ts); 
					if(debug){
						echo('Added email "#type#" contact, #contact.contact_email#, to inquiry for future replies only<br>');
					}
				}
			}
		}
	}
 	

	// MAYBE SOMEDAY, BUT NOT NOW: 
	//remove the person who sent the current message
	/*
		structdelete(emailStruct, skipEmail);
		if(debug){
			echo('Removed sender email contact, #skipEmail#, from outgoing email<br>');
		}
	}
	*/


	// loop all recipients
	emailSendStruct={
		to:[],
		cc:[],
		bcc:[]
	}; 
	allowedUserStruct={};
	if(structkeyexists(ss.filterContacts, 'offices') and arrayLen(ss.filterContacts.offices)){ 
		qOfficeUsers=application.zcore.user.getUsersByOfficeIdList(arrayToList(ss.filterContacts.offices, ","), ss.messageStruct.site_id); 
		for(row in qOfficeUsers){
			allowedUserStruct[row.user_id&"|"&application.zcore.functions.zGetSiteIdType(row.site_id, ss.messageStruct.site_id)]=row;
		}
	}
	allowedUserGroupIdStruct={};
	if(structkeyexists(ss.filterContacts, 'userGroupIds') and arrayLen(ss.filterContacts.userGroupIds)){
		for(group in ss.filterContacts.userGroupIds){
			allowedUserGroupIdStruct[group]=true;
		}
	} 
	enablePlusEmailRouting=application.zcore.functions.zvar("enablePlusEmailRouting", ss.messageStruct.site_id, "0");

	userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	for(i in emailStruct){
		contact=emailStruct[i];  
		if(structkeyexists(assignedEmailStruct, contact.contact_email)){
			// ok to email anyone
			if(debug){
				echo('sending to #contact.contact_email# | no filtering is being applied<br>');
			}
		}else if(structcount(ss.filterContacts) EQ 0){
			// ok to email anyone
			if(debug){
				echo('sending to #contact.contact_email# | no filtering is being applied<br>');
			}
		}else if(structkeyexists(ss.filterContacts, 'managers') and ss.filterContacts.managers and contact.isManagerUser){
			// ok to email
			if(debug){
				echo('sending to #contact.contact_email# | is a manager user<br>');
			}
		}else if(structkeyexists(ss.filterContacts, 'offices') and contact.isUser and structkeyexists(allowedUserStruct, contact.user_id&"|"&contact.user_id_siteidtype)){
			// ok to email
			if(debug){
				echo('sending to #contact.contact_email# | has access to assigned office<br>');
			}
		}else{
			if(structkeyexists(ss.filterContacts, 'userGroupIds') and arrayLen(ss.filterContacts.userGroupIds)){
				if(not contact.isUser){
					if(debug){
						echo('not sending to #contact.contact_email# | not a user<br>');
					}
					continue;
				}
				if(not structkeyexists(allowedUserGroupIdStruct, contact.user_group_id)){
					if(debug){
						echo('not sending to #contact.contact_email# | group not allowed: #contact.user_group_id#<br>');
					}
					continue;
				}
			}
			// contact not ok for private messages
			if(debug){
				echo('not sending to #contact.contact_email# | not an authorized user or has no access to assigned office<br>');
			}
			continue;
		} 
		contact.isAssignedUser=contact.isManagerUser; 
		if(not contact.isAssignedUser and inquiryStruct.user_id NEQ 0){
			if(inquiryStruct.user_id EQ contact.user_id and inquiryStruct.user_id_siteidtype EQ contact.user_id_siteidtype){
				// lead is assigned directly to the contact
				contact.isAssignedUser=true;
			}
		}
		if(not contact.isAssignedUser and inquiryStruct.office_id NEQ 0){
			if(contact.office_id NEQ "" and contact.office_id NEQ "0"){
				arrContactOffice=listToArray(contact.office_id, ",");
				for(contactOffice in arrContactOffice){
					if(inquiryStruct.office_id EQ contactOffice){
						// check if contact.user_group_id has permission to view the current lead
						contactGroupName=userGroupCom.getGroupName(contact.user_group_id, ss.messageStruct.site_id);
						if(structkeyexists(request.manageLeadUserGroupStruct, contactGroupName)){
							groupUserCanManageStruct=request.manageLeadUserGroupStruct[contactGroupName];
							if(inquiryStruct.user_id NEQ 0){ 
								assignedUserGroupName=userGroupCom.getGroupName(qUser.user_group_id, ss.messageStruct.site_id);
								if(structkeyexists(groupUserCanManageStruct, assignedUserGroupName)){
									// lead is assigned to an office and a group that the contact can manage leads for.
									contact.isAssignedUser=true;
									break;
								}
							}else{
								// lead is assigned to everyone in the office.
								contact.isAssignedUser=true;
								break;
							}
						}

					}
				}
			}
		} 
		if(fromContact.contact_id EQ contact.contact_id){
			fromContact.isAssignedUser=contact.isAssignedUser;
		}
		if(not structkeyexists(emailSendStruct, contact.addressType)){
			throw("Invalid contact.addressType: ""#contact.addressType#"".  Only to, cc, and bcc are valid values.");
		}

		// generate unique from address 
		idString=contact.contact_id&"."&ss.inquiries_id;

		if(enablePlusEmailRouting EQ 1){
			tempEmail=getFromAddressForContactByStruct(contact, idString); 
		}else{
			tempEmail=contact.contact_email;
		}
		if(debug){
			echo('#contact.contact_email# changed to #tempEmail#<br>');
		}
		if(debug){
			writedump(contact);
		}
		name=trim(contact.contact_first_name&" "&contact.contact_last_name);
		if(name NEQ ""){
			arrayAppend(emailSendStruct[contact.addressType], {email:application.zcore.email.formatEmailWithName(tempEmail, name), originalEmail:contact.contact_email,isUser:contact.isUser, isAssignedUser:contact.isAssignedUser, isManagerUser:contact.isManagerUser});
		}else{
			arrayAppend(emailSendStruct[contact.addressType], {email:tempEmail, originalEmail:contact.contact_email, isUser:contact.isUser, isAssignedUser:contact.isAssignedUser, isManagerUser:contact.isManagerUser});
		}  
	} 
	return {emailSendStruct:emailSendStruct, fromContact:fromContact, mainContact:mainContact};
	</cfscript>
</cffunction>

<cffunction name="getDefaultMessageConfig" localmode="modern" access="public" returntype="struct">
	<cfscript>
	ts={  
		contact_id:"",  
		debug:false,
		inquiries_id:"",
		validHash:true, 
		jsonStruct:{
		   "headers":{
			  "raw":"",
			  "parsed":{ 
			  }
		   },
		   "cc":[],
		   "bcc":[],
		   "subject":"", 
		   "html":"",
		   "htmlWeb":"",
		   "htmlProcessed":"",
		   "files":[/*
			  {
				 "size":2715,
				 "filePath":"elkdgjicjkbkdbjf2.jpg",
				 "fileName":"elkdgjicjkbkdbjf.jpg"
			  }*/
		   ],
		   "plusId":"", // nothing for internal mail
		   "size":0, // measure below
		   "date":request.zos.mysqlnow,
		   "version":1,
		   "humanReplyStruct":{
			  "isHumanReply":true,
			  "humanTriggers":[],
			  "roboScore":0,
			  "roboTriggers":[],
			  "score":1,
			  "humanScore":1
		   } 
		},
		messageStruct:{
			site_id:request.zos.globals.id
		},
		filterContacts:{},
		privateMessage:false,
		enableCopyToSelf:true
	};
	if(application.zcore.user.checkGroupAccess("user")){
		ts.jsonStruct.from={
		  "name":request.zsession.user.first_name&" "&request.zsession.user.last_name,
		  "email":request.zsession.user.email
		};
		ts.jsonStruct.to=[
			{
				"name":request.zsession.user.first_name&" "&request.zsession.user.last_name,
				"email":request.zsession.user.email,
				"plusId":"",
				"originalEmail":request.zsession.user.email
			}
		];
	}
	return ts;  
	</cfscript>
</cffunction>

<cffunction name="processHTMLEmail" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	allowInsecureAttachmentDownload=true;
	html=ss.jsonStruct.html;
	html=replacenocase(html,"<head>", " ", 'ALL');
	html=replacenocase(html,"</head>", " ", 'ALL');
	html=rereplacenocase(html,"<link[^>]*>", " ", 'ALL');
	html=rereplacenocase(html,"<meta[^>]*>", " ", 'ALL');
	html=rereplacenocase(html,"<html.*?>", "", 'ALL');
	html=replacenocase(html,"</html>", "", 'ALL');
	html=rereplacenocase(html,"<body.*?>", "", 'ALL');
	html=replacenocase(html,"</body>", "", 'ALL');
	html=rereplacenocase(html,"<!DOCTYPE.*?>", "", 'ALL');

	// This isn't going to work since monterey code isn't run by the cron job.  I'd have to convert this to site global
	domain=application.zcore.functions.zvar("publicUserManagerDomain", ss.messageStruct.site_id);
	if(domain EQ ""){
		domain=application.zcore.functions.zvar("domain", ss.messageStruct.site_id);
	}
	var fileIndex = 1;
	// this code might be fragile until we do real html parsing since the editor could rewrite the <p> tag to something else or add undesired line breaks. 
	previousPosition=find("## Please reply ABOVE THIS LINE", html); 
	if(previousPosition NEQ 0){
		// find the <p before this.
		beginHTML=reverse(left(html, previousPosition));
		previousPosition2=find(chr(10), beginHTML); 
		if(previousPosition2 NEQ 0){
			html=reverse(removeChars(beginHTML, 1, previousPosition2));  
		}else{
			// find the <p before this.
			beginHTML=reverse(left(html, previousPosition));
			previousPosition2=find(" p<", beginHTML);
			if(previousPosition2 NEQ 0){
				html=reverse(removeChars(beginHTML, 1, previousPosition2+2));  
			}
		}
	} 

	return html;
	</cfscript>
</cffunction>

<cffunction name="buildFeedbackWebmail" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes"> 
	<cfscript>
	ss=arguments.ss;
	db=request.zos.queryObject; 
	rs={};

	return processHTMLEmail(ss);
	</cfscript>
</cffunction>	

<cffunction name="buildFeedbackEmail" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="contact_id" type="string" required="yes">
	<cfargument name="email" type="string" required="yes">
	<cfargument name="isUser" type="boolean" required="yes"> 
	<cfargument name="isAssignedUser" type="boolean" required="yes"> 
	<cfargument name="isManagerUser" type="boolean" required="yes">
	<cfscript>
	ss=arguments.ss;
	db=request.zos.queryObject; 
	rs={};
	allowInsecureAttachmentDownload=true; 

	// This isn't going to work since monterey code isn't run by the cron job.  I'd have to convert this to site global
 
	domain=application.zcore.functions.zvar("publicUserManagerDomain", ss.messageStruct.site_id);
	if(domain EQ ""){
		domain=application.zcore.functions.zvar("domain", ss.messageStruct.site_id);
	} 
	if(arguments.isManagerUser){
		viewLeadLink="#domain#/z/inquiries/admin/manage-inquiries/view?inquiries_id=#ss.inquiries_id#";
		viewContactLink="#domain#/z/inquiries/admin/feedback/viewContact?contact_id=#arguments.contact_id#&inquiries_id=#ss.inquiries_id#";
	}else{
		viewLeadLink="#domain#/z/inquiries/admin/manage-inquiries/userView?inquiries_id=#ss.inquiries_id#";
		viewContactLink="#domain#/z/inquiries/admin/manage-inquiries/userViewContact?contact_id=#arguments.contact_id#&inquiries_id=#ss.inquiries_id#";
	} 
	if(arguments.contact_id EQ 0){	
		viewContactLink="";
	}

	attachments=[];
	fileIndex=1;
	html=ss.jsonStruct.htmlProcessed;
	if(not arguments.isAssignedUser){
		html=rereplace(html, "<!-- startadmincomments -->.*?<!-- endadmincomments -->","","ALL");
	}
	for ( messageFile in ss.jsonStruct.files ) { 
		// insert a key in url that bypasses authentication so that embedded files don't need authentication.
		if(html CONTAINS '"emailAttachShortURL"' & messageFile.filePath){
			html = reReplace( html, '"emailAttachShortURL"' & messageFile.filePath, domain & '/z/inquiries/download-attachment/index?fileId=' & ss.inquiries_feedback_id & '.' & fileIndex & '.' & ss.inquiries_feedback_download_key, 'all' ); 
		}else{ 
			if(allowInsecureAttachmentDownload){
				arrayAppend(attachments, '<a href="'&domain & '/z/inquiries/download-attachment/index?fileId=' & ss.inquiries_feedback_id & '.' & fileIndex& '.' & ss.inquiries_feedback_download_key&'">'&messageFile.fileName&'</a>');
			}else{
				arrayAppend(attachments, '<a href="'&domain & '/z/inquiries/download-attachment/index?fileId=' & ss.inquiries_feedback_id & '.' & fileIndex&'">'&messageFile.fileName&'</a>');
			}
		}
		fileIndex++;
	}
	enablePlusEmailRouting=application.zcore.functions.zvar("enablePlusEmailRouting", ss.messageStruct.site_id, "0");

	savecontent variable="rs.html"{
		echo('<!DOCTYPE html><html><head><title></title></head><body>');
		if(enablePlusEmailRouting EQ 1){
			echo('<p style="color:##999; font-size:13px;">## Please reply ABOVE THIS LINE to make a comment.</p>');
		}
		if(ss.jsonStruct.humanReplyStruct.score < 0){
			echo('<p>This message may be an auto-reply or spam. Score: #ss.jsonStruct.humanReplyStruct.score#</p>');
			if(request.zos.istestserver){
				writedump(ss.jsonStruct.humanReplyStruct);
			}
		}
		echo(html);
		if(arraylen(attachments) NEQ 0){
			echo('<hr><h3>Attachments</h3>');
			if(not allowInsecureAttachmentDownload){
				echo('<p>You will need to login to view the attachments.</p>');
			}
			for(i=1;i<=arraylen(attachments);i++){
				echo('<p>'&attachments[i]&'</p>');
			}
		}
		if(arguments.isAssignedUser and arguments.isUser){
			echo('<hr>
				<p><a href="#viewLeadLink#">View/Edit Lead</a>');
			if(viewContactLink NEQ ""){
				echo(' | <a href="#viewContactLink#">View Contact</a>');
			}
			echo('</p> 
			'); 
		}
		echo('</body></html>'); 
	} 
	return rs;
	</cfscript>
</cffunction>	

<cffunction name="emailArrayToList" localmode="modern" access="private">
	<cfargument name="emailArray" type="array" required="yes">
	<cfscript>
	var arrEmail=[];
	for(email in arguments.emailArray){
		if ( email.name EQ '' ) {
			arrayAppend(arrEmail, email.email);
		} else {
			arrayAppend(arrEmail, email.name & ' <' & email.email & '>');
		}
	}
	return arrayToList(arrEmail, ', ');
	</cfscript>
</cffunction>

<!--- 
// Probably not going to do this: The idea in delaying emails may allow the person to improve / fix their email before it goes to the group if they notice a mistake real quick.

// This api only works for leads that are generated from our system.  CRM / API integrations may need additional custom programming.
ts={
	forceUniqueType:true, // prevent multiple scheduled emails of the same type

	// required
	data:{
		inquiries_type_id:"",
		inquiries_type_id_siteIDType:"",
		email_queue_unique:"1", // 1 is unique and 0 allows multiple entries for this type for the same email_queue_to address.
		email_queue_from:"",
		email_queue_to:"",
		email_queue_subject:"",
		email_queue_html:"",
		email_queue_send_datetime:dateadd("m", 30, now())
		// optional
		email_queue_cc:"",
		email_queue_bcc:"",
		email_queue_text:"",
		site_id:request.zos.globals.id
	}
};
scheduleLeadEmail(ts);
 --->
<cffunction name="scheduleLeadEmail" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	db=request.zos.queryObject;
	throw("this is incomplete - pseudocode - lets not implement this one");
	// add email to an email queue table that will go out at specific time.  
	// table has full html. 

	ss.email_queue_send_datetime=dateformat(ss.email_queue_send_datetime, "yyyy-mm-dd")&" "&timeformat(ss.email_queue_send_datetime, "HH:mm:ss");

	ts={
		table:"email_queue",
		datasource:request.zos.zcoreDatasource,
		struct:ss
	};

	update=false;
	if(ss.forceUniqueType){
		// if email already exists, run update instead of insert
		update=true;
	}
	if(update){
		ts.struct.email_queue_id=qCheck.email_queue_id;
		application.zcore.functions.zUpdate(ts);
	}else{
		email_queue_id=application.zcore.functions.zInsert(ts);
	}

	return {success:true, email_queue_id:email_queue_id};
	</cfscript>
</cffunction>


<cffunction name="rescheduleLeadEmail" localmode="modern" access="public">
	<cfscript>
	// the scheduled time should be relative to session expiration, not the initial entry.

	</cfscript>
</cffunction>

<cffunction name="cancelScheduledLeadEmail" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;

	// delete email from email queue table whether it exists or not 
	</cfscript>
</cffunction>	

<!--- getContactByEmail(email, name, site_id); --->
<cffunction name="getContactByEmail" localmode="modern" access="public">
	<cfargument name="email" type="string" required="yes">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	arguments.email=trim(arguments.email);
	if(not application.zcore.functions.zEmailValidate(arguments.email)){
		return {};
	}
	arguments.name=trim(arguments.name);
	db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)# WHERE 
	contact_email = #db.param(arguments.email)# and 
	contact_deleted = #db.param(0)# and
	site_id = #db.param(arguments.site_id)# 
	ORDER BY contact_parent_id ASC 
	LIMIT #db.param(0)#, #db.param(1)#";
	qContact=db.execute("qContact");
	if(qContact.recordcount EQ 0){ 
		firstName="";
		lastName="";
		if(trim(arguments.name) CONTAINS " "){
			firstName=listGetAt(arguments.name, 1, " ");
			lastName=trim(listDeleteAt(arguments.name, 1, " "));
		}else{
			firstName=arguments.name;
		}  
		ts={
			table:"contact",
			datasource:request.zos.zcoreDatasource,
			struct:{
				site_id:arguments.site_id,
				contact_email:arguments.email,
				contact_deleted:0,
				contact_first_name:firstName,
				contact_last_name:lastName,
				contact_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				contact_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				contact_key:hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256'),
				contact_des_key:GenerateSecretKey("des")
			}
		};
		result=application.zcore.functions.zInsert(ts); 
		db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)# WHERE 
		contact_email = #db.param(arguments.email)# and 
		contact_deleted = #db.param(0)# and
		site_id = #db.param(arguments.site_id)# 
		ORDER BY contact_parent_id ASC 
		LIMIT #db.param(0)#, #db.param(1)#";
		qContact=db.execute("qContact");
	}

	for(row in qContact){
		parentId=application.zcore.functions.zVar("parentId", arguments.site_id);
		db.sql="select user_id, user_group_id, office_id, site_id from #db.table("user", request.zos.zcoreDatasource)# WHERE 
		user_username = #db.param(row.contact_email)# and 
		user_active=#db.param(1)# and 
		user_deleted = #db.param(0)# and
		site_id IN (#db.param(arguments.site_id)#, ";
		if(parentId NEQ 0){
			db.sql&=" #db.param(parentId)#, ";
		}
		db.sql&=" #db.param(request.zos.globals.serverId)# ) 
		LIMIT #db.param(0)#, #db.param(1)#";
		qUser=db.execute("qUser"); 
		if(qUser.recordcount EQ 0){
			row.isUser=false;
			row.isManagerUser=false; 
			row.user_id=0;
			row.office_id="";
			row.user_id_siteidtype=0;
			row.user_group_id=0;
		}else{
			row.isUser=true;
			// test if qUser.user_group_id is manager or not
			if(application.zcore.user.groupIdHasAccessToGroup(qUser.user_group_id, "member", qUser.site_id)){
				row.isManagerUser=true;
			}else{
				row.isManagerUser=false;
			}
			row.office_id=qUser.office_id;
			row.user_group_id=qUser.user_group_id;
			row.user_id=qUser.user_id;
			row.user_id_siteidtype=application.zcore.functions.zGetSiteIdType(qUser.site_id, arguments.site_id); 
		}
		return row;
	}
	throw("Failed to force creation of contact: #arguments.email# | site_id:#arguments.site_id#");
	</cfscript>
</cffunction> 

<cffunction name="getContactById" localmode="modern" access="public">
	<cfargument name="contact_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	if(trim(arguments.contact_id) EQ "" or arguments.contact_id EQ 0){
		return {};
	}
	db.sql="select * from #db.table("contact", request.zos.zcoreDatasource)# WHERE 
	contact_id = #db.param(arguments.contact_id)# and 
	contact_deleted = #db.param(0)# and
	site_id = #db.param(arguments.site_id)#";
	qContact=db.execute("qContact");
	row={};
	if(not structkeyexists(request.zos, 'contactIDCache')){
		request.zos.contactIDCache={};
	}
	if(structkeyexists(request.zos.contactIDCache, arguments.contact_id&"."&arguments.site_id)){
		return request.zos.contactIDCache[arguments.contact_id&"."&arguments.site_id];
	}
	if(qContact.recordcount){

		for(row2 in qContact){
			parentId=application.zcore.functions.zVar("parentId", arguments.site_id);
			db.sql="select user_id, user_group_id, office_id, site_id from #db.table("user", request.zos.zcoreDatasource)# WHERE 
			user_username = #db.param(row2.contact_email)# and 
			user_active=#db.param(1)# and 
			user_deleted = #db.param(0)# and
			site_id IN (#db.param(arguments.site_id)#, ";
			if(parentId NEQ 0){
				db.sql&=" #db.param(parentId)#, ";
			}
			db.sql&=" #db.param(request.zos.globals.serverId)# ) 
			LIMIT #db.param(0)#, #db.param(1)#";
			qUser=db.execute("qUser"); 
			row=row2;
			if(qUser.recordcount EQ 0){ 
				row.isUser=false;
				row.isManagerUser=false; 
				row.user_id=0;
				row.office_id="";
				row.user_id_siteidtype=0;
				row.user_group_id=0;
			}else{
				row.isUser=true;
				// test if qUser.user_group_id is manager or not
				if(application.zcore.user.groupIdHasAccessToGroup(qUser.user_group_id, "member", qUser.site_id)){
					row.isManagerUser=true;
				}else{
					row.isManagerUser=false;
				}
				row.office_id=qUser.office_id;
				row.user_group_id=qUser.user_group_id;
				row.user_id=qUser.user_id;
				row.user_id_siteidtype=application.zcore.functions.zGetSiteIdType(qUser.site_id, qUser.site_id);
			}
			request.zos.contactIDCache[arguments.contact_id&"."&arguments.site_id]=row;
		}
	}
	return row;
	</cfscript>
</cffunction> 

<cffunction name="getDESKeyByContactId" localmode="modern" access="public">
	<cfargument name="contact_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	var db = request.zos.queryObject;
	contactStruct=this.getContactById(arguments.contact_id, arguments.site_id);
	if(structcount(contactStruct) EQ 0){
		return {success:false, errorMessage:"Contact doesn't exist."};
	}else{
		if(contactStruct.contact_des_key EQ ""){
			contact_des_key=GenerateSecretKey("des");
			db.sql="update #db.table("contact", request.zos.zcoreDatasource)# SET 
			contact_des_key=#db.param(contact_des_key)#, 
			contact_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE
			contact_id = #db.param(arguments.contact_id)# and 
			site_id = #db.param(arguments.site_id)# and 
			contact_deleted=#db.param(0)# ";
			db.execute("qUpdate");
		}else{
			contact_des_key=contactStruct.contact_des_key;
		}
		return {success:true, contact_des_key:contact_des_key}
	}
	</cfscript>
</cffunction>

 
<!--- 
ts={ 
     email: "someone@somewhere.com", 
     phone: "badly formatted number",
     site_id:request.zos.globals.id
}; 
contactCom=createobject("component", "zcorerootmapping.com.app.contact");
rs=contactCom.getContact(ts); 
if(rs.success){ 
     // do stuff with rs.contactStruct; 
}else{ 
     // fail 
}
 --->
<cffunction name="getContact" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var db = request.zos.queryObject;
	var ss = arguments.ss;
	var response = structNew();
	response.success = false;

	if ( NOT structKeyExists( ss, 'email' ) or NOT structKeyExists( ss, 'phone' ) or NOT structKeyExists( ss, 'site_id' ) ) {
		throw( 'getContact() - ss.site_id, ss.email and ss.phone are required' );
	}
	if(trim(ss.email&ss.phone) EQ ""){
		return response;
	} 
	ss.phone = application.zcore.functions.zFormatInquiryPhone( ss.phone );

	db.sql = 'SELECT *
	FROM #db.table( 'contact', request.zos.zcoreDatasource )#
	WHERE site_id = #db.param( ss.site_id )# ';

	if(ss.email NEQ ""){
		db.sql&=" AND contact_email = #db.param( ss.email )# ";
	}
	if(ss.phone NEQ ""){
		db.sql&=" AND (
			contact_phone1_formatted = #db.param( ss.phone )#
			OR contact_phone2_formatted = #db.param( ss.phone )#
			OR contact_phone3_formatted = #db.param( ss.phone )#
		) ";
	}
	db.sql&="
	AND contact_deleted = #db.param( 0 )#
	LIMIT #db.param( 1 )# ";
	qContact = db.execute( 'qContact' );

	contactStruct = structNew();

	for ( row in qContact ) {
		response.success = true;
		response.contactStruct = row;
		return response;
	}

	return response;
	</cfscript>
</cffunction>


<!--- 
contactCom.getFromAddressForContactByStruct(contact, idString);
 --->
<cffunction name="getFromAddressForContactByStruct" localmode="modern" access="public">
	<cfargument name="contact" type="struct" required="yes"> 
	<cfargument name="idString" type="string" required="yes">
	<cfscript> 
	contact=arguments.contact;
	if(application.zcore.functions.zVar('enablePlusEmailRouting', contact.site_id) EQ 1 ){ 
		plusEmail=application.zcore.functions.zVar('plusEmailAddress', contact.site_id);
		if(plusEmail NEQ ""){ 
			// build plus addressing url
			arrEmail=listToArray(plusEmail, "@");
			if(contact.contact_des_key EQ ""){
				rs=getDESKeyByContactId(contact.contact_id, contact.site_id);
				if ( rs.success ) {
					contact.contact_des_key=rs.contact_des_key;
				}else{
					return contact.contact_email;
				}
			} 
			return arrEmail[1]&"+"&"1.C"&contact.contact_id&"."&dESEncryptValueLimit16("C"&contact.contact_id&"."&arguments.idString, contact.contact_des_key)&"."&arguments.idString&"@"&arrEmail[2];
		}  
	} 
	return contact.contact_email;
	</cfscript> 
</cffunction>

<!--- 
email=contactCom.getFromAddressForContactById(contact_id, site_id, idString);
 --->
<cffunction name="getFromAddressForContactById" localmode="modern" access="public">
	<cfargument name="contact_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="idString" type="string" required="yes">
	<cfscript> 
	if(application.zcore.functions.zVar('enablePlusEmailRouting', arguments.site_id) EQ 1 ){
		plusEmail=application.zcore.functions.zVar('plusEmailAddress', arguments.site_id);
		if(plusEmail NEQ ""){
			// build plus addressing url
			arrEmail=listToArray(plusEmail, "@");
			rs=getDESKeyByContactId(arguments.contact_id, arguments.site_id);
			if ( rs.success ) {
				return arrEmail[1]&"+"&"1.C"&arguments.contact_id&"."&dESEncryptValueLimit16("C"&arguments.contact_id&"."&arguments.idString, rs.contact_des_key)&"."&arguments.idString&"@"&arrEmail[2];
			}
		} 
	}

	contact = this.getContactById( arguments.contact_id, arguments.site_id );
	if(structcount(contact) EQ 0){
		rs={success:false, errorMessage:"Contact doesn't exist."};
	}else{
		rs={success:true, contact.contact_email};
	}
	return rs;
	</cfscript>
	
</cffunction>

<cffunction name="verifyDESLimit16FromAddressForContact" localmode="modern" access="public">
	<cfargument name="contact_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="idString" type="string" required="yes">
	<cfargument name="desHashLimit16" type="string" required="yes">
	<cfscript>  
	rs=getDESKeyByContactId(arguments.contact_id, arguments.site_id);
	if ( rs.success ) {
		if(arguments.desHashLimit16 EQ dESEncryptValueLimit16("C"&arguments.contact_id&"."&arguments.idString, rs.contact_des_key)){
			return true;
		}
	}
	return false;
	</cfscript>
	
</cffunction> 

<!--- desEncryptValueLimit16(id, key); --->
<cffunction name="desEncryptValueLimit16" localmode="modern" access="public">
	<cfargument name="id" type="string" required="yes"> 
	<cfargument name="key" type="string" required="yes">
	<cfscript> 
	return left(encrypt(arguments.id, arguments.key, "des", "hex"), 16);
	// echo(application.zcore.functions.zGenerateStrongPassword(16,16, true));
	</cfscript>
</cffunction> 


<!--- 
<cfscript>
// run this when a user is being assigned to an inquiry
ts={
	contact_id:contact_id, // the contact being shared
	accessible_by_contact_id: request.zsession.user.contact_id, // the user who will have access to the contact
	site_id: request.zos.globals.id
};
contactCom.addContactToContact(ts);
</cfscript>
--->
<cffunction name="addContactToContact" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	db=request.zos.queryObject;
	db.sql="SELECT count(contact_id) count FROM #db.table("contact_x_contact", request.zos.zcoreDatasource)# WHERE 
	contact_id = #db.param(ss.contact_id)# and 
	contact_x_contact_accessible_by_contact_id=#db.param(ss.accessible_by_contact_id)# and 
	site_id = #db.param(ss.site_id)# and 
	contact_x_contact_deleted=#db.param(0)# ";
	qI=db.execute("qI");
	if(qI.recordcount EQ 0 or qI.count EQ 0){
		db.sql="INSERT IGNORE INTO #db.table("contact_x_contact", request.zos.zcoreDatasource)# SET 
		site_id=#db.param(ss.site_id)#,
		contact_id=#db.param(ss.contact_id)#, 
		contact_x_contact_accessible_by_contact_id=#db.param(ss.accessible_by_contact_id)#, 
		contact_x_contact_deleted=#db.param(0)# ";
		db.execute("qDelete");		
	}
	</cfscript>
</cffunction>

<!--- 
<cfscript>
// run this when a user is being unassigned from an inquiry
ts={
	contact_id:contact_id, // the contact being shared
	user_id: user_id, // the user who had access
	user_id_siteIdType: user_id_siteIdType,
	accessible_by_contact_id: request.zsession.user.contact_id, // the contact_id for the user who had access
	site_id: request.zos.globals.id
};
contactCom.removeContactFromContact(ts);
</cfscript>
--->
<cffunction name="removeContactFromContact" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	db=request.zos.queryObject;
	db.sql="SELECT count(inquiries_id) count FROM #db.table("inquiries", request.zos.zcoreDatasource)# WHERE 
	contact_id = #db.param(ss.contact_id)# and 
	site_id = #db.param(ss.site_id)# and 
	inquiries_deleted=#db.param(0)# and 
	user_id=#db.param(ss.user_id)# and 
	user_id_siteIdType=#db.param(ss.user_id_siteIdType)#";
	qI=db.execute("qI");
	if(qI.recordcount EQ 0 or qI.count EQ 0){
		db.sql="delete FROM #db.table("contact_x_contact", request.zos.zcoreDatasource)# WHERE 
		site_id=#db.param(ss.site_id)# and 
		contact_x_contact_accessible_by_contact_id=#db.param(ss.accessible_by_contact_id)# and 
		contact_x_contact_deleted=#db.param(0)# ";
		db.execute("qDelete");
		
	}
	</cfscript>
</cffunction>

</cfoutput>	
</cfcomponent>