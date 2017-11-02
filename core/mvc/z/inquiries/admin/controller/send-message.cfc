<cfcomponent>
<cfoutput>

<cffunction name="init" localmode="modern" access="private">
	<cfscript>
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

	if(form.inquiries_id EQ 0){
		// ok to add lead
	}else{
		// test if user has access to inquiries_id
		db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# 
		WHERE inquiries_id = #db.param(form.inquiries_id)# and 
		site_id = #db.param(request.zos.globals.id)# ";
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


<cffunction name="send" localmode="modern" access="remote">
	<cfscript>
	result=init(); 
	if(not result){
		return;
	}

	form.inquiries_from=form.inquiries_from;
	form.inquiries_feedback_to=form.inquiries_to;
	form.inquiries_feedback_cc=form.inquiries_cc; 
	form.inquiries_feedback_bcc=form.inquiries_bcc;
	form.inquiries_feedback_subject=form.inquiries_subject;
	form.inquiries_feedback_comments=form.inquiries_message;

	db=request.zos.queryObject;
	myForm={};
	qCheck=0;
	result=0;
	inputStruct=0;
	q=0;  
	//form.leadEmailUseSubmission=true;
	// form validation struct
	myForm.inquiries_id.required = true;
	myForm.inquiries_id.friendlyName = "Inquiry ID";
	// i removed these fields.
	myForm.inquiries_from.required = true;
	myForm.inquiries_from.email=true;
	myForm.inquiries_to.required = true;
	myForm.inquiries_to.email=true; 
	myForm.inquiries_subject.required = true;
	myForm.inquiries_subject.allownull = false;
	myForm.inquiries_message.required = true;
	myForm.inquiries_feedback_datetime.createDateTime = true;
	result = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.status.displayReturnJson(request.zsid); 
	}
	form.user_id = request.zsession.user.id;
	form.site_id = request.zOS.globals.id;
	
	form.inquiries_feedback_from=form.inquiries_from;
	form.inquiries_feedback_to=form.inquiries_to;
	form.inquiries_feedback_cc=form.inquiries_cc; 
	form.inquiries_feedback_bcc=form.inquiries_bcc;
	form.inquiries_feedback_subject=form.inquiries_subject;
	form.inquiries_feedback_comments=form.inquiries_message;
 
	writedump(form);
	if(form.inquiries_id EQ 0){
		// store new inquiries_id with very basic information and no lead routing alerts.
		ts={ 
			inquiries_first_name:variables.contact.contact_first_name,
			inquiries_last_name:variables.contact.contact_last_name,
			inquiries_phone1:variables.contact.contact_phone1,
			contact_id:form.contact_id,

			inquiries_type_id:19, // type: Email
			inquiries_type_id_siteIdType:4, 

			user_id:request.zsession.user.id,
			user_id_siteidtype:application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id), 

			inquiries_email:form.inquiries_feedback_to,
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
		writedump(ts);
		abort;
		inquiries_id=application.zcore.functions.zImportLead(ts); 
	}
	abort;
	inputStruct = StructNew();
	inputStruct.struct=form;
	inputStruct.table = "inquiries_feedback";
	inputstruct.datasource=request.zos.zcoreDatasource;
	form.inquiries_feedback_id = application.zcore.functions.zInsert(inputStruct); 
	if(form.inquiries_feedback_id EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Failed to send email.", form,true);
		application.zcore.status.displayReturnJson(request.zsid); 
	}
	/*mail to="#form.inquiries_to#" from="#form.inquiries_from#" bcc="#form.inquiries_bcc#" subject="#form.inquiries_subject#"{
		writeoutput(form.inquiries_message);
	}*/
	application.zcore.functions.zReturnJson({success:true});
	</cfscript>
</cffunction> 

<cffunction name="index" localmode="modern" access="remote">
	<cfscript> 
	result=init(); 
	if(not result){
		return;
	}
	db=request.zos.queryObject; 
	</cfscript>
	<div class="z-float z-mb-10">
		<h2 style="display:inline;">Send Email</h2> &nbsp;&nbsp; 
		<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator")> 
			<a href="/z/inquiries/admin/lead-template/index" class="z-manager-search-button" target="_blank">Edit Templates</a> 
			<a href="/z/inquiries/admin/lead-template/add?inquiries_lead_template_type=2&amp;siteIDType=1" class="z-manager-search-button" target="_blank">Add Email Template</a> 
		</cfif>
	</div> 
	<cfscript>
	tags=StructNew(); 
	signature="";
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE user_id = #db.param(request.zsession.user.id)# and 
	#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL("user", request.zos.globals.id))# and 
	user_server_administrator=#db.param('0')# and 
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
				echo('#qAgent.user_first_name# #qAgent.user_last_name##chr(10)#');
				if(qAgent.member_title NEQ ""){
					echo('#qAgent.member_title##chr(10)#');
				}
				if(qAgent.member_company NEQ ""){
					echo('#qAgent.member_company##chr(10)#');
				}
				if(qAgent.member_phone NEQ ""){
					echo('#qAgent.member_phone##chr(10)#');
				}
				if(qAgent.user_email NEQ ""){
					echo('#qAgent.user_email##chr(10)#');
				}
				if(qAgent.member_website NEQ ""){
					echo('#qAgent.member_website#');
				}
			}
		}
		tags=StructNew();
		tags['{agent name}']=qAgent.member_first_name&' '&qAgent.member_last_name;
		tags["{agent's company}"]=qAgent.member_company;
	}else{
		tags=structnew();
		signature="";
	}
	</cfscript> 
	<script type="text/javascript">
	/* <![CDATA[ */
	var arrEmailTemplate=[];
	var greeting="#JSStringFormat(trim('Hello '&application.zcore.functions.zFirstLetterCaps(variables.contact.contact_first_name))&','&chr(10)&chr(10))#";
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
	originalMessage=chr(10)&chr(10)&"--"&chr(10)&"This message was in response your original inquiry ###form.inquiries_id#."&chr(10)&chr(10)&(originalMessage);
	</cfscript>
	var originalMessage="#jsstringformat(originalMessage)#";
	var signature="#jsstringformat(chr(10)&chr(10)&'--'&chr(10)&trim(signature))#";
	function updateEmailForm(v){
		if(v!=""){
			document.myForm2.inquiries_subject.value=arrEmailTemplate[v].subject;
			document.myForm2.inquiries_message.value=greeting+arrEmailTemplate[v].message+signature+originalMessage;
		}else{
			document.myForm2.inquiries_subject.value="";
			document.myForm2.inquiries_message.value=greeting+signature+originalMessage;
		}
	}
	/* ]]> */
	</script>
	<table class="table-list" style="width:100%; border-left:2px solid ##999;border-right:1px solid ##999;">
		<form class="zFormCheckDirty" name="sendEmailForm" id="sendEmailForm" action="/z/inquiries/admin/feedback/sendemail?inquiries_id=#form.inquiries_id#" method="post">
			<input type="hidden" name="contact_id" value="#htmleditformat(form.contact_id)#">
			<tr>
				<th colspan="2"> Select a template or fill in the following fields:</th>
			</tr>
			<tr>
				<td style="width:100px;">Template:</td>
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
			<tr>
				<td>From:</td>
				<td>#request.zsession.user.first_name# #request.zsession.user.last_name# (#request.zsession.user.email#)

					<!--- <input name="inquiries_from" id="inquiries_from" type="text" size="50" maxlength="50" value="#htmleditformat(form.member_email)#" > ---></td>
			</tr> 
			<tr>
				<td>To Email:</td>
				<td>#variables.contact.contact_first_name# #variables.contact.contact_last_name# (#variables.contact.contact_email#)
					<!--- probably lock this to the selected contact instead --->
					<!--- <input name="inquiries_to" id="inquiries_to" type="text" size="50" maxlength="50" value="#htmleditformat(form.inquiries_to)#" > ---></td>
			</tr>
			<tr>
				<td>Cc:</td>
				<td><input name="inquiries_cc" id="inquiries_cc" type="text" size="50" maxlength="255" value="#htmleditformat(form.inquiries_cc)#" ></td>
			</tr>
			<tr>
				<td>Bcc:</td>
				<td><input name="inquiries_bcc" id="inquiries_bcc" type="text" size="50" maxlength="255" value="#htmleditformat(form.inquiries_bcc)#" ></td>
			</tr>
			<tr>
				<td>Subject:</td>
				<td><input name="inquiries_subject" id="inquiries_subject" type="text" size="50" maxlength="255" value="#htmleditformat(form.inquiries_subject)#" /></td>
			</tr>
			<tr>
				<td colspan="2">Message:<br />
					<textarea name="inquiries_message" id="inquiries_message" style="width:98%; height:200px; ">#htmleditformat(form.inquiries_message)#</textarea></td>
			</tr>
			<tr>
				<td colspan="2"><button type="submit" name="submitForm" class="z-manager-search-button">Send Email</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Cancel</button></td>
			</tr>
		</form>
	</table>
	<script type="text/javascript">
	zArrDeferredFunctions.push(function(){
		function processSendEmailResponse(r){
			var r=JSON.parse(r);
			console.log(r);
			if(r.success){
				alert('Email sent');
			}else{
				// displayReturnJson??
				alert('Email not sent');
			}
		}
		function sendEmail(){
				
			var tempObj={};
			tempObj.formId="sendEmailForm";
			tempObj.id="sendEmailForm";
			tempObj.url="/z/inquiries/admin/send-message/send";
			tempObj.method="post"; 
			tempObj.callback=processSendEmailResponse;
			tempObj.cache=false;
			zAjax(tempObj);
		}
		$("##sendEmailForm").on("submit", function(e){
			e.preventDefault();
			sendEmail();
		});
	});
	</script>
	<script type="text/javascript">
	/* <![CDATA[ */<cfif application.zcore.functions.zso(form, 'leadEmailUseSubmission') EQ ''>
	updateEmailForm('');
	</cfif>/* ]]> */
	</script> 
	<br /><!---  --->
</cffunction>
</cfoutput>
</cfcomponent>			