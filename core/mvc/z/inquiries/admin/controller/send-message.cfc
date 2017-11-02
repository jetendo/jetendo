<cfcomponent>
<cfoutput>
<!--- 

// TODO: possibly support file attachments someday.  We would need to protect it slightly from abuse through size and file type filters.
 --->

<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	application.zcore.functions.zSetModalWindow(); 
	// decided i shouldn't call init
	//feedbackCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.feedback");
	//feedbackCom.init();



	form.contact_id=application.zcore.functions.zso(form, 'contact_id');
	form.inquiries_from=application.zcore.functions.zso(form, 'inquiries_from');
	form.inquiries_to=application.zcore.functions.zso(form, 'inquiries_to');
	form.inquiries_bcc=application.zcore.functions.zso(form, 'inquiries_bcc');
	form.inquiries_cc=application.zcore.functions.zso(form, 'inquiries_cc');
	form.inquiries_subject=application.zcore.functions.zso(form, 'inquiries_subject');
	form.inquiries_message=application.zcore.functions.zso(form, 'inquiries_message'); 

	// convert the to/cc/bcc addresses to contact id if they aren't already.


	variables.contactCom=createobject("component", "zcorerootmapping.com.app.contact");
	variables.contact = variables.contactCom.getContactById(form.contact_id, request.zos.globals.id);
	if(structcount(variables.contact) EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid contact selected.", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/manage-contact/index?zsid=#request.zsid#");
	}

	form.inquiries_id=application.zcore.functions.zso(form, 'inquiries_id', true, 0);

	variables.manageInquiryCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");

	if(form.inquiries_id EQ 0){
		// ok to add lead
	}else{
		if(form.method EQ "userSend"){
			variables.manageInquiryCom.userInit();
		}

		// test if user has access to inquiries_id
		db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# 
		WHERE inquiries_id = #db.param(form.inquiries_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)# ";
		if(form.method EQ "userSend"){ 
			db.sql&=variables.manageInquiryCom.getUserLeadFilterSQL(db); 
		}
		variables.qCheck = db.execute("qCheck");
		if(variables.qCheck.recordcount EQ 0 or variables.qCheck.inquiries_status_id EQ 4 or variables.qCheck.inquiries_status_id EQ 5 or variables.qCheck.inquiries_status_id EQ 7){
			echo('<h2>This inquiry can no longer be updated.</h2>
			<p>Closing this window in 3 seconds.</p>
				<script type="text/javascript">
			zArrDeferredFunctions.push(function(){
				setTimeout(function(){
					window.parent.zCloseModal();
				}, 3000);
			});
			</script>');
			return false;
		}
	}
	return true;
	</cfscript>
</cffunction>


<cffunction name="userSend" localmode="modern" access="remote" roles="user">
	<cfscript>
	send();
	</cfscript>
</cffunction>

<cffunction name="send" localmode="modern" access="remote" roles="member">
	<cfscript>
	result=init(); 
	if(not result){
		return;
	}
	debug=false;

	form.inquiries_from=form.inquiries_from;
	/*
	form.inquiries_feedback_to=form.inquiries_to;
	form.inquiries_feedback_cc=form.inquiries_cc; 
	form.inquiries_feedback_bcc=form.inquiries_bcc;
	form.inquiries_feedback_subject=form.inquiries_subject;
	form.inquiries_feedback_comments=form.inquiries_message;
	*/
	db=request.zos.queryObject;
	myForm={};
	qCheck=0;
	result=0;
	inputStruct=0;
	q=0;   
	myForm.inquiries_subject.required = true; 
	myForm.inquiries_message.required = true; 
	result = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.status.displayReturnJson(request.zsid); 
	} 
	form.site_id = request.zOS.globals.id; 
	form.user_id=request.zsession.user.id;
	form.user_id_siteidtype=application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
	if(debug){
	 	writedump(request.zsession.user);
		writedump(form);
	}
	if(form.inquiries_id EQ 0){
		// store new inquiries_id with very basic information and no lead routing alerts.
		ts={ 
			inquiries_first_name:variables.contact.contact_first_name,
			inquiries_last_name:variables.contact.contact_last_name,
			inquiries_phone1:variables.contact.contact_phone1,
			contact_id:form.contact_id,

			inquiries_type_id:19, // type: Email
			inquiries_type_id_siteIdType:4, 

			user_id:form.user_id,
			user_id_siteidtype:form.user_id_siteidtype, 

			inquiries_email:variables.contact.contact_email,
			inquiries_status_id:3,
			inquiries_datetime:request.zos.mysqlnow,
			inquiries_updated_datetime:request.zos.mysqlnow,
			inquiries_primary:1,
			site_id:request.zos.globals.id,
			inquiries_priority:5
		}; 
		
		if(structkeyexists(request.zsession, 'selectedOfficeId')){
			ts.office_id = request.zsession.selectedOfficeId;
		}
		if(debug){
			writedump(ts); 
		}else{
			form.inquiries_id=application.zcore.functions.zImportLead(ts); 

			if(form.inquiries_id EQ false){
				application.zcore.status.setStatus(request.zsid, "Failed to send email. Please try again later.", form, true);
				application.zcore.status.displayReturnJson(request.zsid);
			}
		}
	}
 
	ts={  
		contact_id:request.zsession.user.contact_id,  
		debug:false,
		inquiries_id:form.inquiries_id, 
		validHash:true, 
		jsonStruct:{
		   "headers":{
		      "raw":"",
		      "parsed":{ 
		      }
		   },
		   "from":{
		      "name":request.zsession.user.first_name&" "&request.zsession.user.last_name,
		      "email":request.zsession.user.email
		   },
		   "to":[
		      {
		         "name":variables.contact.contact_first_name&" "&variables.contact.contact_last_name,
		         "email":variables.contact.contact_email,
		         "plusId":"",
		         "originalEmail":variables.contact.contact_email
		      }
		   ],
		   "cc":[],
		   "bcc":[],
		   "subject":form.inquiries_subject,
		   "html":form.inquiries_message,
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
		   },
			"htmlProcessed":""
		},
		messageStruct:{
			site_id:request.zos.globals.id
		}
	};

	ts2={
		inquiries_to:"to",
		inquiries_cc:"cc",
		inquiries_bcc:"bcc"
	};
	for(field in ts2){
		if(form[field] NEQ ""){
			arrTemp=listToArray(form[field], ",");
			for(email in arrTemp){
				arrEmail=listToArray(email, chr(9));
				ts3={
					name:"",
					plusId:""
				};
				if(arrayLen(arrEmail) EQ 2){
					ts3.name=arrEmail[1];
					ts3.email=arrEmail[2];
				}else{
					ts3.email=email;
				}
				ts.originalEmail=email; 
				arrayAppend(ts.jsonStruct[ts2[field]], ts3);
			}
		}
	} 
	if(debug){
		writedump(ts);
		abort;
	}
	/*if(request.zos.isTestServer){
		// modify to/cc/bcc to prevent accident emails to real people from test server
		ts.jsonStruct.from.name="From Developer";
		ts.jsonStruct.from.email=request.zos.developerEmailFrom;
		ts.jsonStruct.to=[{
			"name":"To Developer",
			"email":request.zos.developerEmailTo,
			"plusId":"",
			"originalEmail":request.zos.developerEmailTo
		}];
		ts.jsonStruct.cc=[];
		ts.jsonStruct.bcc=[];
	}*/
	// slightly inaccurate since it doesn't include all fields and attachment sizes
	ts.jsonStruct.size=len(ts.jsonStruct.subject&ts.jsonStruct.html);  
	//ts.debug=true;
	rs=variables.contactCom.processMessage(ts);
	if(not rs.success){
		// TODO: might want to delete the lead that was just inserted if the emails never went out to avoid clutter / confusion.  Be sure not to delete existing leads though.
		application.zcore.status.setStatus(request.zsid, "Failed to send email. Please try again later.", form, true);
		application.zcore.status.displayReturnJson(request.zsid);
	}
 
	application.zcore.status.setStatus(request.zsid, "Email sent");
	if(form.method EQ "send"){
		application.zcore.functions.zReturnJson({success:true, redirect:1, redirectLink:"/z/inquiries/admin/manage-inquiries/index?zsid=#request.zsid#"});
	}else{
		application.zcore.functions.zReturnJson({success:true, redirect:1, redirectLink:"/z/inquiries/admin/manage-inquiries/userIndex?zsid=#request.zsid#"});
	}
	</cfscript>
</cffunction> 

<cffunction name="userIndex" localmode="modern" access="remote" roles="user">
	<cfscript> 
	index();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript> 
	result=init(); 
	if(not result){
		return;
	}
	db=request.zos.queryObject; 
	application.zcore.skin.includeJS("/z/a/scripts/tiny_mce/tinymce.min.js");
	application.zcore.skin.includeJS( '/z/javascript/jquery/Tokenize2/tokenize2.min.js' );
	application.zcore.skin.includeCSS( '/z/javascript/jquery/Tokenize2/tokenize2.min.css' );
	application.zcore.skin.includeCSS( '/z/javascript/jquery/Tokenize2/custom.css' );

	</cfscript>

	<script type="text/javascript">
		zArrDeferredFunctions.push( function() {
			$('##inquiries_cc').attr( 'multiple', 'multiple' );
			$('##inquiries_cc').tokenize2( {
				dataSource: 'select',///z/inquiries/admin/manage-inquiries/inquiryTokenSearch',
				searchFromStart: false,
				tokensAllowCustom: true
			} );

			$('##inquiries_bcc').attr( 'multiple', 'multiple' );
			$('##inquiries_bcc').tokenize2( {
				dataSource: 'select',///z/inquiries/admin/manage-inquiries/inquiryTokenSearch',
				searchFromStart: false,
				tokensAllowCustom: true
			} );
		} );
	</script>

	<div class="z-manager-edit-head">
		<h2 style="display:inline;font-weight:normal; color:##369;">Send Email</h2> &nbsp;&nbsp; 
		<a href="/z/user/preference/form" class="z-manager-search-button" target="_blank">Edit Signature</a> 
		<cfif application.zcore.user.checkGroupAccess("administrator")> 
			<a href="/z/inquiries/admin/lead-template/index" class="z-manager-search-button" target="_blank">Edit Templates</a> 
			<a href="/z/inquiries/admin/lead-template/add?inquiries_lead_template_type=2&amp;siteIDType=1" class="z-manager-search-button" target="_blank">Add Template</a> 
		</cfif>
	</div> 
	<div class="z-manager-edit-errors z-float"></div>
	<cfscript>
	tags=StructNew(); 
	signature="";
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_id = #db.param(request.zsession.user.id)# and 
	site_id=#db.param(request.zsession.user.site_id)# and	 
	user_deleted = #db.param(0)# ";
	qAgent=db.execute("qAgent"); 

	db.sql="SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)# inquiries_lead_template_x_site ON 
	inquiries_lead_template_x_site.inquiries_lead_template_id = inquiries_lead_template.inquiries_lead_template_id and 
	inquiries_lead_template.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_lead_template_x_site.inquiries_lead_template_x_site_siteidtype"))# and 
	inquiries_lead_template_x_site.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_lead_template_x_site_deleted = #db.param(0)#
	WHERE inquiries_lead_template_x_site.site_id IS NULL and
	inquiries_lead_template_deleted = #db.param(0)# and  
	inquiries_lead_template_type = #db.param('2')# and 
	inquiries_lead_template.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#) ";
	if(application.zcore.app.siteHasApp("listing") EQ false){
		db.sql&=" and inquiries_lead_template_realestate = #db.param('0')# ";
	}
	db.sql&=" ORDER BY inquiries_lead_template_sort ASC, inquiries_lead_template_name ASC ";
	qTemplate=db.execute("qTemplate");
 
	if(qagent.recordcount NEQ 0){
		savecontent variable="signature"{
			if(qAgent.member_signature NEQ ""){
				echo(qAgent.member_signature); 
			}else{
				echo('#request.zsession.user.first_name# #request.zsession.user.last_name#<br>');
				if(qAgent.member_title NEQ ""){
					echo('#qAgent.member_title#<br>');
				}
				if(qAgent.member_company NEQ ""){
					echo('#qAgent.member_company#<br>');
				}
				if(qAgent.member_phone NEQ ""){
					echo('#qAgent.member_phone#<br>');
				}
				if(request.zsession.user.email NEQ ""){
					echo('#request.zsession.user.email#<br>');
				}
				if(qAgent.member_website NEQ ""){
					echo('#qAgent.member_website#<br>');
				}
			}
		}
		tags=StructNew();
		tags['{agent name}']="#request.zsession.user.first_name# #request.zsession.user.last_name#";
		tags["{agent's company}"]=qAgent.member_company;
	}else{
		tags=structnew();
		signature="";
	}
	</cfscript> 
	<script type="text/javascript">
	/* <![CDATA[ */
	var arrEmailTemplate=[];
	var greeting="#JSStringFormat(trim('Hello '&application.zcore.functions.zFirstLetterCaps(variables.contact.contact_first_name))&',<br><br>')#";
	<cfloop query="qTemplate">
		<cfscript>
		tm=qTemplate.inquiries_lead_template_message;
		for(i in tags){
			tm=replaceNoCase(tm,i,tags[i],'ALL');
		}
		</cfscript>
		arrEmailTemplate[#qTemplate.inquiries_lead_template_id#]={};
		arrEmailTemplate[#qTemplate.inquiries_lead_template_id#].subject="#jsstringformat(qTemplate.inquiries_lead_template_subject)#";
		arrEmailTemplate[#qTemplate.inquiries_lead_template_id#].message="#jsstringformat(tm)#";
	</cfloop>
	<cfscript>
	// TODO: might need to have some or all of the inquiry details in the reply someday.
	originalMessage="";//inquiryHTML;
	// remove admin comments
	/*
	originalMessage=rereplace(originalMessage,"<!-- startadmincomments -->.*?<!-- endadmincomments -->","","ALL");
	links="";
	badTagList="style|link|head|script|embed|base|input|textarea|button|object|iframe|form";
	originalMessage=rereplacenocase(originalMessage,"<(#badTagList#)[^>]*?>.*?</\1>", " ", 'ALL');			
	//originalMessage=rereplacenocase(originalMessage,"<a.*?href=""(.*)?"".*?>.*?</a>", " \1 ", 'ALL');	
	originalMessage=rereplacenocase(originalMessage,"<a.*?>(.*)?</a>", " \1 ", 'ALL');
	originalMessage=replacenocase(originalMessage,"last 2 pages:", " ", 'ALL');
	originalMessage=replacenocase(originalMessage,chr(10), " ", 'ALL');
	originalMessage=replacenocase(originalMessage,chr(13), "", 'ALL');
	originalMessage=replacenocase(originalMessage,chr(9), " ", 'ALL');
	originalMessage=replacenocase(originalMessage,"</tr>",chr(10),"ALL");
	originalMessage=rereplacenocase(originalMessage," +", " ", 'ALL');
	originalMessage=replacenocase(originalMessage,"| |", " ", 'ALL');
	
	originalMessage=rereplacenocase(originalMessage,"<.*?>", " ", 'ALL');
	originalMessage=rereplacenocase(originalMessage,"&[^\s]*?;", " ", 'ALL');
	originalMessage=replacenocase(originalMessage,"&nbsp;"," ","ALL");
	originalMessage=replacenocase(originalMessage,chr(10)&chr(10),chr(10),"ALL");
	if(form.inquiries_referer NEQ "" or form.inquiries_referer2 NEQ ""){
		originalMessage&=chr(10)&"Last 2 Pages Visited: "&chr(10)&form.inquiries_referer&chr(10)&chr(10)&form.inquiries_referer2;
	}
	arrM=listtoarray(originalMessage,chr(10),true);
	for(i=1;i LTE arrayLen(arrM);i++){
		arrM[i]=trim(arrM[i]);
	}
	originalMessage=arraytolist(arrM,chr(10));
	*/
	// put the full original message here with 
	if(form.inquiries_id NEQ 0){
		originalMessage="<br><br>This message was in response your original inquiry ###form.inquiries_id#.<br><br>"&originalMessage;
	}else{
		originalMessage="";
	}

	db.sql = 'SELECT inquiries_x_contact.inquiries_x_contact_id, inquiries_x_contact.inquiries_x_contact_type, contact.contact_id, contact.contact_email, concat(contact.contact_first_name, #db.param(" ")#, contact.contact_last_name) fullName
		FROM #db.table( 'contact', request.zos.zcoreDatasource )# 
		LEFT JOIN #db.table( 'inquiries_x_contact', request.zos.zcoreDatasource )# ON 
			inquiries_x_contact.inquiries_x_contact_deleted = #db.param( 0 )#
			AND contact.contact_id = inquiries_x_contact.contact_id
			AND contact.site_id = inquiries_x_contact.site_id
		WHERE
		contact.site_id = #db.param( request.zos.globals.id )#
		AND contact.contact_deleted = #db.param( 0 )#
		ORDER BY contact.contact_first_name ASC, contact.contact_last_name ASC, contact.contact_email ASC';
	qContact = db.execute( 'qContact' );
	/*
	db.sql = 'SELECT inquiries_x_contact.inquiries_x_contact_type, contact.contact_id, contact.contact_email, contact.contact_first_name, contact.contact_last_name
		FROM #db.table( 'inquiries_x_contact', request.zos.zcoreDatasource )# AS inquiries_x_contact,
			#db.table( 'contact', request.zos.zcoreDatasource )# AS contact
		WHERE inquiries_x_contact.site_id = #db.param( request.zos.globals.id )#
			AND inquiries_x_contact.inquiries_x_contact_deleted = #db.param( 0 )#
			AND contact.contact_id = inquiries_x_contact.contact_id
			AND contact.site_id = inquiries_x_contact.site_id
			AND contact.contact_deleted = #db.param( 0 )#
		ORDER BY contact.contact_email ASC';
	qContact = db.execute( 'qContact' );
	*/
	arrContact=[];
	arrTo=[];
	arrLabelTo=[];

	if ( qContact.recordcount GT 0 ) {
		for ( row in qContact ) {
			if(row.fullName NEQ ''){
				label=row.fullName&" <"&row.contact_email&">";
			}else{
				label=row.contact_email;
			}
			if(row.inquiries_x_contact_type EQ "to"){
				arrayAppend(arrTo, row.fullName&chr(9)&row.contact_email);
				arrayAppend(arrLabelTo, label);
			}
			if(row.inquiries_x_contact_id NEQ ""){
				arrayAppend(arrContact, {row:row, label:label, selected:true});
			}else{
				arrayAppend(arrContact, {row:row, label:label, selected:false});
			}
		}
	}
	if(form.method EQ "index"){
		action="send";
	}else{
		action="userSend";
	}
	</cfscript>
	var originalMessage="#jsstringformat(originalMessage)#";
	var signature="#jsstringformat('<br><br>--<br>#trim(signature)#')#";
	function updateEmailForm(v){
		if(v!=""){
			document.sendEmailForm.inquiries_subject.value=arrEmailTemplate[v].subject;
			document.sendEmailForm.inquiries_message.value=greeting+arrEmailTemplate[v].message+signature+originalMessage;
		}else{
			document.sendEmailForm.inquiries_subject.value="";
			document.sendEmailForm.inquiries_message.value=greeting+signature+originalMessage;
		}
	}
	/* ]]> */
	</script>
	<table class="table-list" style="width:100%; ">
		<form class="zFormCheckDirty" name="sendEmailForm" id="sendEmailForm" action="/z/inquiries/admin/send-message/#action#" method="post" enctype="multipart/form-data">
			<input type="hidden" name="contact_id" value="#htmleditformat(form.contact_id)#">
			<input type="hidden" name="inquiries_id" value="#htmleditformat(form.inquiries_id)#">
			<input type="hidden" name="inquiries_to" value="#htmleditformat(arrayToList(arrTo, ','))#">
			<cfif application.zcore.user.checkGroupAccess("member") and qTemplate.recordcount NEQ 0>
				<tr>
					<th colspan="2"> Select a template or fill in the following fields:</th>
				</tr>
				<tr>
					<th style="width:80px;">Template:</th>
					<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "inquiries_lead_template_id";
					selectStruct.query = qTemplate;
					selectStruct.onChange="updateEmailForm(this.options[this.selectedIndex].value);";
					selectStruct.queryLabelField = "inquiries_lead_template_name";
					selectStruct.queryValueField = 'inquiries_lead_template_id';
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
				</tr>
			</cfif> 
			<tr>
				<th>Inquiry</th>
				<td><cfif form.inquiries_id EQ 0>New Message<cfelse>###form.inquiries_id#</cfif></td>
			</tr>
			<tr>
				<th>From:</th>
				<td>#request.zsession.user.first_name# #request.zsession.user.last_name# (#request.zsession.user.email#)
				</td>
			</tr> 
			<tr>
				<th>To:</th>
				<td>#variables.contact.contact_first_name# #variables.contact.contact_last_name# (#variables.contact.contact_email#) 
					<cfif arrayLen(arrLabelTo) NEQ 0>
						and <span title="#arrayToList(arrLabelTo, chr(10))#">#arrayLen(arrLabelTo)# other<cfif arrayLen(arrLabelTo) GT 1>s</cfif></span>
					</cfif>
				</td>
			</tr>
			<tr>
				<th>Cc:</th>
				<td> 
					<select id="inquiries_cc" name="inquiries_cc" multiple="multiple" style="display:none;">
						<cfloop from="1" to="#arrayLen(arrContact)#" index="i">
							<cfscript>item = arrContact[i];</cfscript>
							<option value="#item.row.fullName&chr(9)&item.row.contact_email#" <cfif item.row.inquiries_x_contact_type EQ "cc" and item.selected>selected="selected"</cfif>>#htmleditformat(item.label)#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<th>Bcc:</th>
				<td> 
					<select id="inquiries_bcc" name="inquiries_bcc" multiple="multiple" style="display:none;">
						<cfloop from="1" to="#arrayLen( arrContact )#" index="i">
							<cfscript>item = arrContact[ i ];</cfscript>
							<option value="#item.row.fullName&chr(9)&item.row.contact_email#" <cfif item.row.inquiries_x_contact_type EQ "bcc" and item.selected>selected="selected"</cfif>>#htmleditformat(item.label)#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<th>Subject:</th>
				<td><input name="inquiries_subject" id="inquiries_subject" type="text" size="50" maxlength="255" value="#htmleditformat(form.inquiries_subject)#" /></td>
			</tr>
			<tr>
				<th>Message:</th>
				<td>
					<textarea name="inquiries_message" id="inquiries_message" style="width:98%; height:200px; ">#htmleditformat(form.inquiries_message)#</textarea></td>
			</tr>
			<tr>
				<th>&nbsp;</th>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">Send Email</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Cancel</button></td>
			</tr>
		</form>
	</table>

	<script type="text/javascript">
	zArrDeferredFunctions.push(function(){ 
		tinymce.init({
		  selector: '##inquiries_message',
		  height: 300,
		  menubar: false,
		  plugins: [
		    'advlist autolink lists link image charmap print preview anchor textcolor',
		    'searchreplace visualblocks code fullscreen',
		    'insertdatetime media table contextmenu paste code'
		  ],
		  toolbar: 'undo redo |  formatselect | bold italic | alignleft aligncenter alignright alignjustify | link bullist numlist outdent indent | removeformat',
		  content_css: []
		});
		function emailSentCallback(r){
			window.parent.location.reload();
		}
		$("##sendEmailForm").on("submit", function(e){
			//e.preventDefault();
			if($("##inquiries_subject").val()=="" || $("##inquiries_message").val()==""){
				alert("Subject and message are required.");
				return false;
			}
			return zSubmitManagerEditForm(this, emailSentCallback); 
		});
	});
	</script><!---  --->
	<script type="text/javascript">
	/* <![CDATA[ */<cfif application.zcore.functions.zso(form, 'leadEmailUseSubmission') EQ ''>
	updateEmailForm('');
	</cfif>/* ]]> */
	</script> 
	<br /><!---  --->
</cffunction>
</cfoutput>
</cfcomponent>			