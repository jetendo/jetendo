<cfcomponent>
<cfoutput>

<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	application.zcore.functions.zSetModalWindow(); 
	// decided i shouldn't call init
	//feedbackCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.feedback");
	//feedbackCom.init();

	form.inquiries_from=application.zcore.functions.zso(form, 'inquiries_from');
	form.inquiries_to=application.zcore.functions.zso(form, 'inquiries_to');
	form.inquiries_bcc=application.zcore.functions.zso(form, 'inquiries_bcc');
	form.inquiries_cc=application.zcore.functions.zso(form, 'inquiries_cc');
	form.inquiries_subject=application.zcore.functions.zso(form, 'inquiries_subject');
	form.inquiries_message=application.zcore.functions.zso(form, 'inquiries_message'); 

	// convert the to/cc/bcc addresses to contact id if they aren't already.

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
	myForm.inquiries_bcc.allownull = true;
	myForm.inquiries_bcc.email=true;
	myForm.inquiries_subject.required = true;
	myForm.inquiries_subject.allownull = false;
	myForm.inquiries_message.required = true;
	myForm.inquiries_feedback_datetime.createDateTime = true;
	result = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/feedback/view?zPageId=#form.zPageId#&zsid=#Request.zsid#&inquiries_id=#form.inquiries_id#");
	}
	form.user_id = request.zsession.user.id;
	form.site_id = request.zOS.globals.id;
	
	form.inquiries_feedback_from=form.inquiries_from;
	form.inquiries_feedback_to=form.inquiries_to;
	form.inquiries_feedback_bcc=form.inquiries_bcc;
	form.inquiries_feedback_subject=form.inquiries_subject;
	form.inquiries_feedback_comments=form.inquiries_message;


	if(form.inquiries_id EQ 0){
		// store new inquiries_id with very basic information and no lead routing alerts.

		// this is used to record a lead, without redirecting anywhere.
		form.inquiries_type_id=1;
		form.inquiries_type_id_siteIdType=4;
		form.inquiries_email="test@test.com";
		form.inquiries_subject="New Inquiry on #request.zos.globals.shortdomain#";
		ts={
			disableAssign:true
		};
		ts={
			inquiries_first_name:"",
			// other fields
		};
		application.zcore.functions.zImportLead(ts);
		/*

			rs.assignEmail="";
			rs.user_id=arguments.ss.assignUserId;
			rs.user_id_siteIDType=arguments.ss.assignUserIdSiteIdType; 
			 db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE ";
			if(rs.user_id_siteIDType EQ 1){
				db.sql&=" site_id = #db.param(request.zos.globals.id)# and ";
			}else{
				db.sql&=" site_id = #db.param(request.zos.globals.parentId)# and ";
			}
			db.sql&=" user_active= #db.param(1)# and 
			user_deleted = #db.param(0)# and  
			user_id =#db.param(rs.user_id)# ";
			qAssignUser=db.execute("qAssignUser"); 
			if(qAssignUser.recordcount EQ 0){
				// assign to default email
				rs.assignEmail=application.zcore.functions.zvarso('zofficeemail');
				m='process assigned lead to zofficeemail: #rs.assignEmail#<br />';
				arrayAppend(arrDebug, m);
				if(structkeyexists(request.zos, 'debugleadrouting')){
					echo(m);
				}
			}else{
				if(qAssignUser.office_id CONTAINS ","){
					rs.office_id=listGetAt(qAssignUser.office_id, 1, ",");
				}
				if(qAssignUser.user_alternate_email NEQ ""){
					rs.cc=qAssignUser.user_alternate_email;
				}
		*/
	}
	
	inputStruct = StructNew();
	inputStruct.struct=form;
	inputStruct.table = "inquiries_feedback";
	inputstruct.datasource=request.zos.zcoreDatasource;
	form.inquiries_feedback_id = application.zcore.functions.zInsert(inputStruct); 
	if(form.inquiries_feedback_id EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Email send failed.", form,true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/feedback/view?zPageId=#form.zPageId#&zsid=#request.zsid#&inquiries_id=#form.inquiries_id#");
	}else{
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Email sent.");
		if(qCheck.inquiries_status_id EQ 2){
			form.inquiries_status_id=3;		
		}else if(qCheck.inquiries_status_id EQ 1){
			form.inquiries_status_id=6;		
		}else{
			form.inquiries_status_id=3;
		}
		db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries SET 
		inquiries_updated_datetime = #db.param(form.inquiries_feedback_datetime)#, 
		inquiries_status_id = #db.param(form.inquiries_status_id)# 
		WHERE inquiries_id = #db.param(form.inquiries_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)#";
		q=db.execute("q");
	}
	mail to="#form.inquiries_to#" from="#form.inquiries_from#" bcc="#form.inquiries_bcc#" subject="#form.inquiries_subject#"{
		writeoutput(form.inquiries_message);
	}
	application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid='&request.zsid);
	</cfscript>
</cffunction> 

<cffunction name="index" localmode="modern" access="remote">
	<cfscript> 
	result=init(); 
	if(not result){
		return;
	}
	db=request.zos.queryObject;
	init();
	</cfscript>
	<div class="z-float z-mb-10">
		<h2 style="display:inline;">Send Email</h2>
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
			echo('#qAgent.member_first_name# #qAgent.member_last_name##chr(10)##qAgent.member_title##chr(10)##qAgent.member_phone##chr(10)##qAgent.member_website#');
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
	var greeting="#JSStringFormat('Hello '&trim(application.zcore.functions.zFirstLetterCaps(form.inquiries_first_name))&','&chr(10)&chr(10)&chr(9))#";
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
	originalMessage=chr(10)&chr(10)&"----------------------"&chr(10)&"This message was in response your original inquiry ###form.inquiries_id#."&chr(10)&chr(10)&(originalMessage);
	</cfscript>
	var originalMessage="#jsstringformat(originalMessage)#";
	var signature="";//#jsstringformat(chr(10)&chr(10)&'---------------------------------------'&chr(10)&trim(signature))#";
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
		<form class="zFormCheckDirty" name="sendEmailForm" id="sendEmailForm" action="/z/inquiries/admin/feedback/sendemail?inquiries_id=#form.inquiries_id#&amp;zPageId=#form.zPageId#" method="post">
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
				<td><input name="inquiries_from" id="inquiries_from" type="text" size="50" maxlength="50" value="#htmleditformat(form.member_email)#" ></td>
			</tr> 
			<tr>
				<td>To Email:</td>
				<td><input name="inquiries_to" id="inquiries_to" type="text" size="50" maxlength="50" value="#htmleditformat(form.inquiries_to)#" ></td>
			</tr>
			<tr>
				<td>Bcc:</td>
				<td><input name="inquiries_bcc" id="inquiries_bcc" type="text" size="50" maxlength="50" value="#htmleditformat(form.inquiries_bcc)#" ></td>
			</tr>
			<tr>
				<td>Subject:</td>
				<td><input name="inquiries_subject" id="inquiries_subject" type="text" size="50" maxlength="50" value="#htmleditformat(form.inquiries_subject)#" /></td>
			</tr>
			<tr>
				<td colspan="2">Message:<br />
					<textarea name="inquiries_message" id="inquiries_message" style="width:98%; height:200px; ">#htmleditformat(form.inquiries_message)#</textarea></td>
			</tr>
			<tr>
				<td colspan="2"><button type="submit" name="submitForm">Send Email</button>
					<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button></td>
			</tr>
		</form>
	</table>
	<!--- <script type="text/javascript">
	/* <![CDATA[ */<cfif application.zcore.functions.zso(form, 'leadEmailUseSubmission') EQ ''>
	updateEmailForm('');
	</cfif>/* ]]> */
	</script> 
	<br /> --->
</cffunction>
</cfoutput>
</cfcomponent>			