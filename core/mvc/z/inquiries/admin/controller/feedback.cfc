<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	hCom=0;
	form.returnJSON=application.zcore.functions.zso(form, 'returnJSON', true, 0);

	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	if(form.method EQ "userView"){

	}else{
	    application.zcore.adminSecurityFilter.requireFeatureAccess("Leads");

		if(structkeyexists(form, 'inquiries_id') EQ false){
			if(form.returnJSON EQ 1){
				application.zcore.functions.zReturnJson({ success:false, errorMessage:"You don't have access to manage this lead."});
			}else{
				application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index');
			}
		}
	}
	if(form.returnJSON EQ 0){
		if(request.cgi_script_name CONTAINS "/z/inquiries/admin/feedback/"){
			hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
			hCom.displayHeader();
		}
	}
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.zRedirect("/z/inquiries/admin/index");
	</cfscript>
</cffunction>

<cffunction name="getInquiriesFeedbackById" localmode="modern" access="public">
	<cfargument name="inquiries_feedback_id" type="string" required="yes">
	<cfscript>
		inquiries_feedback_id = arguments.inquiries_feedback_id;
		db = request.zos.queryObject;

		db.sql = 'SELECT *
			FROM #db.table( 'inquiries_feedback', request.zos.zcoreDatasource )# inquiries_feedback 
			WHERE site_id = #db.param(request.zos.globals.id)#
				AND inquiries_feedback_id = #db.param( inquiries_feedback_id )#
				AND inquiries_feedback_deleted = #db.param( 0 )#
			LIMIT #db.param( 1 )#';
		qInquiryFeedback = db.execute( 'qInquiryFeedback' );

		if ( qInquiryFeedback.recordcount EQ 0 ) {
			throw( 'Inquiry feedback not found' );
		} else {
			for ( row in qInquiryFeedback ) {
				return row;
			}
		}
	</cfscript>
</cffunction>

<cffunction name="deleteFeedback" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	qCheck=0;
	variables.init();
	db.sql="SELECT * from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# 
	LEFT JOIN  #db.table("user", request.zos.zcoreDatasource)# ON 
	user.user_id = inquiries_feedback.user_id and 
	user.user_active=#db.param(1)# and 
	user_deleted=#db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_feedback.user_id_siteIDType"))#
	WHERE inquiries_feedback_id = #db.param(form.inquiries_feedback_id)# and 
	inquiries_id=#db.param(form.inquiries_id)# and 
	inquiries_feedback_deleted=#db.param(0)# and 
	inquiries_feedback.site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		if(form.returnJSON EQ 1){
			rs={
				success:true
			};
			application.zcore.functions.zReturnJson(rs);
		}else{
			application.zcore.status.setStatus(request.zsid, 'Feedback doesn''t exist');
			application.zcore.functions.zRedirect('/z/inquiries/admin/feedback/view?zsid=#request.zsid#&inquiries_id=#form.inquiries_id#');	
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		form.site_id=request.zos.globals.id;
		application.zcore.functions.zDeleteRecord("inquiries_feedback","inquiries_feedback_id,site_id",request.zos.zcoreDatasource);
		if(form.returnJSON EQ 1){
			rs={
				success:true
			};
			application.zcore.functions.zReturnJson(rs);
		}else{
			application.zcore.status.setStatus(request.zsid, 'Feedback deleted');
			application.zcore.functions.zRedirect('/z/inquiries/admin/feedback/view?zsid=#request.zsid#&inquiries_id=#form.inquiries_id#');	
		}
		</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this feedback?<br />
			<br />
			<cfscript>
			if(qCheck.inquiries_feedback_message_json NEQ ""){
				jsonStruct = deserializeJSON( qCheck.inquiries_feedback_message_json );
				echo('From: ');
				if ( jsonStruct.from.name EQ '' ) {
					email=jsonStruct.from.email;
				} else {
					email=jsonStruct.from.name & ' <' & jsonStruct.from.email & '>';
				}
				echo(email&'<br>');
				echo('Subject: #qCheck.inquiries_feedback_subject#<br />');
			}else{
				name=trim(qCheck.user_first_name&" "&qCheck.user_last_name);
				if ( name EQ '' ) {
					email=name;
				} else {
					email=name & ' <' & qCheck.user_username & '>';
				}
				echo(email&'<br>');
				echo('Subject: #qCheck.inquiries_feedback_subject#<br />');
			}
			</cfscript>
			
			<br />
			<a href="/z/inquiries/admin/feedback/deleteFeedback?inquiries_feedback_id=#form.inquiries_feedback_id#&amp;inquiries_id=#form.inquiries_id#&amp;confirm=1">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/inquiries/admin/feedback/view?inquiries_id=#form.inquiries_id#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	inputStruct=0;
	myForm={};
	qCheck=0;
	result=0;
	r=0;
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id', true, 1);
	variables.init();
	db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and 
	user.user_deleted=#db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))#
	WHERE inquiries.inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_deleted=#db.param(0)# and
	inquiries.site_id = #db.param(request.zos.globals.id)# ";
	qCheck = db.execute("qCheck"); 
	if(form.method EQ "insert"){
		errorReturnURL="/z/inquiries/admin/feedback/view?zPageId=#form.zPageId#&zsid=#Request.zsid#&inquiries_id=#form.inquiries_id#";
	}else{
		errorReturnURL="/z/inquiries/admin/manage-inquiries/userView?zPageId=#form.zPageId#&zsid=#Request.zsid#&inquiries_id=#form.inquiries_id#";
	}

	// form validation struct
	myForm.inquiries_id.required = true;
	myForm.inquiries_id.friendlyName = "Inquiry ID";
	myForm.inquiries_feedback_datetime.createDateTime = true;
	result = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true); 
		application.zcore.functions.zRedirect(errorReturnURL); 
	}
	if(form.inquiries_status_id EQ 4 or form.inquiries_status_id EQ 5 or form.inquiries_status_id EQ 7){		
		// ignore validation
	}else if(application.zcore.functions.zso(form, 'inquiries_feedback_comments') EQ '' and application.zcore.functions.zso(form, 'inquiries_feedback_subject') EQ ''){
		application.zcore.status.setStatus(Request.zsid, 'Please type a subject or message in the Add Note form.',form,true); 
		application.zcore.functions.zRedirect(errorReturnURL); 
	
	}
	form.user_id = request.zsession.user.id;
	form.user_id_siteIdType = application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
	form.site_id = request.zOS.globals.id;
	
	//	Insert Into Inquiry Database
	inputStruct = StructNew();
	inputStruct.struct=form;
	inputStruct.table = "inquiries_feedback";
	inputstruct.datasource=request.zos.zcoreDatasource;
	form.inquiries_feedback_id = application.zcore.functions.zInsert(inputStruct); 
	if(form.inquiries_feedback_id EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead failed to be updated.", false,true);
		application.zcore.functions.zRedirect(errorReturnURL); 
	}else{
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead updated.");
		if(structkeyexists(form,'inquiries_status_id') and (form.inquiries_status_id EQ 4 or form.inquiries_status_id EQ 5 or form.inquiries_status_id EQ 7)){								 
		}else if(qCheck.inquiries_status_id EQ 2){
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
		inquiries_deleted=#db.param(0)# ";
		r=db.execute("r");
	}
	if(form.user_id NEQ qCheck.user_id and qCheck.user_email NEQ ""){
		if(qCheck.recordcount NEQ 0){
			mail  to="#qCheck.user_email#" from="#request.fromemail#" subject="Your lead has been updated by the administrator."{
writeoutput('The administrator has added feedback to your lead.

Please login in and view your lead by clicking the following link: #request.zos.currentHostName#/z/inquiries/admin/feedback/view?inquiries_id=#form.inquiries_id# Do not reply to this email. ');
			}
		}
	}
	if(form.method EQ "insert"){
		application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid='&request.zsid);
	}else{
		application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/userIndex?zPageId=#form.zPageId#&zsid='&request.zsid);
	}
	</cfscript>
</cffunction>


<!--- 
http://www.montereyboats.com.127.0.0.2.nip.io/z/inquiries/admin/feedback/viewContact?contact_id=15
 --->
<cffunction name="viewContact" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject; 
	// need to validate based on contact_id instead of inquiries_id,  init is disabled for now.
	//variables.init();

	form.contact_id=application.zcore.functions.zso(form, 'contact_id', true, 0);
	form.contactTab=application.zcore.functions.zso(form, 'contactTab', true, 0);

	contactCom=createobject("component", "zcorerootmapping.com.app.contact");
	contact = contactCom.getContactById(form.contact_id, request.zos.globals.id);
	//writedump(contact);
	</cfscript> 
	<div class="z-float">
	<p><a href="##">Contacts</a> /</p>
	</div>
	<div class="z-float">
		<div class="z-float-right">
			<a href="##" class="z-button z-contact-new-button">New Message</a>
			<a href="##" class="z-button z-contact-reply-button">Reply</a> 
			<a href="##" class="z-button z-contact-edit-button">Edit Contact</a>
			<!--- 
			on lead only: 
			<a href="##" class="z-button z-contact-edit-lead-button">Edit Lead</a>
			<a href="##" class="z-button z-contact-add-note-button">Add Note</a>
			<a href="##" class="z-button z-contact-assign-lead-button">Assign</a>
			 --->
		</div>
		<h1>First Last</h1>
	</div>
	<div class="z-float">
	<ul>
		<li><a href="z-contact-tab1 <cfif form.contactTab EQ 1>active</cfif>">Overview</a></li>
		<li><a href="z-contact-tab2 <cfif form.contactTab EQ 2>active</cfif>">Leads</a></li>
		<li><a href="z-contact-tab3 <cfif form.contactTab EQ 3>active</cfif>">User Data</a></li> 
		<!--- saved searches, search criteria, etc --->
		<!--- <li><a href="tab4">?</a></li> --->
	</ul>
	</div>
	<style type="text/css">
	/*.z-contact-row{width:100%; float:left;}
	.z-contact-label{ font-weight:bold; float:left; padding:5px; width:15%;}
	.z-contact-value{ width:85%; padding:5px; float:left; }*/
	.z-contact-container{ width:100%; display:table; border-spacing:0px;}
	.z-contact-row{width:100%; display:table-row;}
	.z-contact-label{ font-weight:bold; display:table-cell; padding-bottom:5px; width:15%;  white-space:nowrap;}
	.z-contact-value{ display:table-cell; padding-bottom:5px; float:left; }
	@media only screen and (max-width: 992px) {  
		.z-contact-label{width:25%;}
		.z-contact-value{width:75%;}
	}
	@media only screen and (max-width: 767px) {  
		.z-contact-label{width:35%;}
		.z-contact-value{width:65%;}
	}
	@media only screen and (max-width: 479px) {  
		.z-contact-label{width:100%;padding-bottom:0px;}
		.z-contact-value{width:100%;}
		.z-contact-row{margin-bottom:5px;}
	}
	</style>
	<cfif form.contactTab EQ 1>
		<div class="z-float z-contact-tab1"> 
			<div class="z-float">
				<h2>Overview</h2>
			</div>
			<div class="z-float z-contact-container">
				<div class="z-contact-row">
					<div class="z-contact-label">
						Phone3
					</div>
					<div class="z-contact-value">
						Test
					</div>
				</div>
				<div class="z-contact-row">
					<div class="z-contact-label">
						Updated Datetime
					</div>
					<div class="z-contact-value">
						Test2
					</div>
				</div>
				<cfscript>
				savecontent variable="out"{
					for(i in contact){
						echo('<div class="z-contact-row">'&chr(10));
						echo(chr(9)&'<div class="z-contact-label">'&chr(10));
							echo(chr(9)&chr(9)&application.zcore.functions.zFirstLetterCaps(replace(replace(i, 'contact_', ' '), '_', ' ', 'all'))&chr(10));
						echo(chr(9)&'</div>'&chr(10));
						echo(chr(9)&'<div class="z-contact-value">'&chr(10));
							echo(chr(9)&chr(9)&'##contact.#i###'&chr(10));
						echo(chr(9)&'</div>'&chr(10));
						echo('</div>'&chr(10));
					}
				}
				echo(out);
				//echo('<pre>');echo(htmleditformat(out));echo('</pre>');
				</cfscript>
			</div>
		</div>
	<cfelseif form.contactTab EQ 2>

		<div class="z-float z-contact-tab2"> 
			<div class="z-float">
				<h2>Leads</h2>
			</div>
			<div class="z-float z-contact-container">
				<!--- show all leads with pagination? --->
			</div>
		</div>
	<cfelseif form.contactTab EQ 3>		
		<div class="z-float z-contact-tab3"> 
			<div class="z-float">
				<h2>User Data</h2>
			</div>
			<div class="z-float z-contact-container">
				<div class="z-contact-row">
					<!--- user data like  --->
				</div>
			</div>
		</div>
	</cfif>
</cffunction>

<cffunction name="view" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject; 
	variables.init();
	application.zcore.functions.zSetPageHelpId("4.1.1"); 
	if(application.zcore.functions.zso(form, 'inquiries_id') EQ ''){
		if(form.method EQ "userView"){
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/userIndex");
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index");
		}
	}
	inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");

	db.sql="SELECT *, if(inquiries.inquiries_status_id IN #db.trustedSQL("('4','5', '7'),1,0")#) closed 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
	inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#) and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	inquiries_type_deleted = #db.param(0)#
	LEFT JOIN #db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status
	ON inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
	inquiries_status_deleted = #db.param(0)#
	WHERE inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_deleted = #db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#";
	if(form.method EQ "userView"){
	    db.sql&=inquiriesCom.getUserLeadFilterSQL(db);
	}else if(structkeyexists(request.zos.userSession.groupAccess, 'administrator') EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#";
	}
	qInquiry=db.execute("qInquiry");
	if(qinquiry.recordcount EQ 0){		
		request.zsid = application.zcore.status.setStatus(Request.zsid, "This inquiry doesn't exist.", false,true);
		if(form.method EQ "userView"){
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/userIndex?zPageId=#form.zPageId#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
		}
	}
	application.zcore.functions.zQueryToStruct(qInquiry, form);
	application.zcore.functions.zStatusHandler(request.zsid,true);

	application.zcore.skin.includeJS( '/z/javascript/jquery/Tokenize2/tokenize2.min.js' );
	application.zcore.skin.includeCSS( '/z/javascript/jquery/Tokenize2/tokenize2.min.css' );
	application.zcore.skin.includeCSS( '/z/javascript/jquery/Tokenize2/custom.css' );

	</cfscript>

	<div class="z-float">
		<div class="z-3of5 z-ph-0">
		<!--- <cfif form.closed EQ 0> --->
			<!--- <table style="width:100%; border-spacing:0px;">
			<tr>
			<td style="vertical-align:top; width:70%;padding-left:0px;"> --->
		<!--- </cfif> --->
		<cfscript>
		hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
		hCom.view(); 
		</cfscript>
		</div>
		<div class="z-2of5 z-ph-0">
		<!--- <td style="vertical-align:top; width:30%;padding-left:10px; padding-right:0px;"> --->
			<cfsavecontent variable="db.sql"> SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template
			LEFT JOIN #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)# inquiries_lead_template_x_site ON 
			inquiries_lead_template_x_site.inquiries_lead_template_id = inquiries_lead_template.inquiries_lead_template_id and 
			inquiries_lead_template_x_site_deleted = #db.param(0)# and 
			inquiries_lead_template_x_site.site_id = #db.param(request.zos.globals.id)# 
			WHERE inquiries_lead_template_x_site.site_id IS NULL and 
			inquiries_lead_template_deleted = #db.param(0)# and 
			inquiries_lead_template_type = #db.param('1')# and 
			inquiries_lead_template.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#)
			<cfif application.zcore.app.siteHasApp("listing") EQ false>
				and inquiries_lead_template_realestate = #db.param('0')#
			</cfif>
			ORDER BY inquiries_lead_template_sort ASC, inquiries_lead_template_name ASC </cfsavecontent>
			<cfscript>
			qTemplate=db.execute("qTemplate");
			tags=StructNew();
			</cfscript>
			<script type="text/javascript">
			/* <![CDATA[ */
			var arrNoteTemplate=[];
			<cfloop query="qTemplate">
				<cfscript>
				tm=qTemplate.inquiries_lead_template_message;
				for(i in tags){
					tm=replaceNoCase(tm,i,tags[i],'ALL');
				}
				</cfscript>
			arrNoteTemplate[#qTemplate.inquiries_lead_template_id#]={};
			arrNoteTemplate[#qTemplate.inquiries_lead_template_id#].subject="#jsstringformat(qTemplate.inquiries_lead_template_subject)#";
			arrNoteTemplate[#qTemplate.inquiries_lead_template_id#].message="#jsstringformat(tm)#";
			</cfloop>
			function updateNoteForm(v){
				if(v!=""){
					document.myForm.inquiries_feedback_subject.value=arrNoteTemplate[v].subject;
					document.myForm.inquiries_feedback_comments.value=arrNoteTemplate[v].message;
				}else{
					document.myForm.inquiries_feedback_subject.value='';
					document.myForm.inquiries_feedback_comments.value='';
				}
			}
			/* ]]> */
			</script>
			
			<div style="" class="z-inquiry-note-box">
				<h2 style="display:inline;">
				Add Note
				<cfif application.zcore.user.checkGroupAccess("administrator")> 
					</h2>
					<a href="/z/inquiries/admin/lead-template/index" class="z-manager-search-button">Edit Templates</a> 
					<a href="/z/inquiries/admin/lead-template/add?inquiries_lead_template_type=1&amp;siteIDType=1" class="z-manager-search-button">Add Note Template</a>
				<cfelse>
					</h2>
				</cfif>
				<br />
				<br />
				<cfscript>
				db.sql="SELECT * from #db.table("inquiries_feedback", request.zos.zcoreDatasource)#  
				WHERE inquiries_feedback.inquiries_id = #db.param(form.inquiries_id)# and 
				inquiries_feedback.inquiries_feedback_id = #db.param(application.zcore.functions.zso(form, 'inquiries_feedback_id',false,''))# and 
				inquiries_feedback.site_id = #db.param(request.zos.globals.id)# and 
				inquiries_feedback.inquiries_feedback_deleted=#db.param(0)#"; 
				qFeedback=db.execute("qFeedback"); 
				application.zcore.functions.zQueryToStruct(qFeedback,form,'inquiries_id');
				</cfscript>
				<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/inquiries/admin/<cfif form.method EQ "userView">manage-inquiries/userInsertStatus<cfelse>feedback/insert</cfif>?inquiries_id=#form.inquiries_id#&amp;zPageId=#form.zPageId#" method="post">
					<table class="table-list" style="width:100%; ">
						<tr>
							<th colspan="2"> Select a template or fill in the following fields:</th>
						</tr>
						<tr>
							<td style="width:100px;">Template:</td>
							<td><cfscript>
							selectStruct = StructNew();
							selectStruct.name = "inquiries_lead_template_id";
							selectStruct.query = qTemplate;
							selectStruct.onChange="updateNoteForm(this.options[this.selectedIndex].value);";
							selectStruct.queryLabelField = "inquiries_lead_template_name";
							selectStruct.queryValueField = 'inquiries_lead_template_id';
							application.zcore.functions.zInputSelectBox(selectStruct);
							</cfscript></td>
						</tr>
						<tr>
							<td>Subject:</td>
							<td><input name="inquiries_feedback_subject" id="inquiries_feedback_subject" type="text" maxlength="50" value="" style="min-width:100%; width:100%; max-width:100%;" /></td> 
						</tr>
						<tr>
							<td colspan="2">Message:<br />
								<textarea name="inquiries_feedback_comments" id="inquiries_feedback_comments" style="width:98%; height:120px; min-width:100%; max-width:100%; ">#form.inquiries_feedback_comments#</textarea></td>
						</tr>
						<tr>
							<td colspan="2">Change lead status:<br />

								<cfscript> 
								db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status 
								WHERE inquiries_status_deleted = #db.param(0)# and 
								inquiries_status_id <> #db.param(1)# 
								ORDER BY inquiries_status_name ";
								qInquiryStatus=db.execute("qInquiryStatus");
								selectStruct = StructNew();
								selectStruct.hideSelect=true;
								selectStruct.name = "inquiries_status_id";
								selectStruct.query = qInquiryStatus;
								selectStruct.queryLabelField = "inquiries_status_name";
								selectStruct.queryValueField = 'inquiries_status_id';
								application.zcore.functions.zInputSelectBox(selectStruct); 
								</cfscript>
								<!--- <input type="radio" name="inquiries_status_id" value="1" class="input-plain" <cfif form.inquiries_status_id EQ 1>checked="checked"</cfif>>
								New
								<input type="radio" name="inquiries_status_id" value="2" class="input-plain" <!--- <cfif form.inquiries_status_id EQ 2>checked="checked"</cfif> --->>
								Assigned --->
								<!--- <div style="float:left; white-space:nowrap;">
									<input type="radio" name="inquiries_status_id" id="inquiries_status_id3" value="3" class="input-plain" <cfif form.inquiries_status_id EQ 2 or application.zcore.functions.zso(form, 'inquiries_status_id',false,3) EQ 3>checked="checked"</cfif>>
									<label for="inquiries_status_id3">Contacted</label>
								</div>
								<div style="float:left; white-space:nowrap;">
									<input type="radio" name="inquiries_status_id" id="inquiries_status_id4" value="4" class="input-plain" <cfif application.zcore.functions.zso(form, 'inquiries_status_id') EQ 4>checked="checked"</cfif>>
									<label for="inquiries_status_id4">Closed with No Sale</label>
								</div>
								<div style="float:left; white-space:nowrap;">
									<input type="radio" name="inquiries_status_id" id="inquiries_status_id5" value="5" class="input-plain"<cfif application.zcore.functions.zso(form, 'inquiries_status_id') EQ 5>checked="checked"</cfif>>
									<label for="inquiries_status_id5">Closed with Sale</label>
								</div>
								<div style="float:left; white-space:nowrap;">
									<input type="radio" name="inquiries_status_id" id="inquiries_status_id8" value="8" class="input-plain"<cfif application.zcore.functions.zso(form, 'inquiries_status_id') EQ 8>checked="checked"</cfif>>
									<label for="inquiries_status_id8">Closed as Service Request</label>
								</div> 
								<div style="float:left; white-space:nowrap;">
									<input type="radio" name="inquiries_status_id" id="inquiries_status_id7" value="7" class="input-plain"<cfif application.zcore.functions.zso(form, 'inquiries_status_id') EQ 7>checked="checked"</cfif>>
									<label for="inquiries_status_id7">Spam/Fake</label>
								</div> --->
							</td>
						</tr>
						<tr>
							<td colspan="2"><button type="submit" name="submitForm" class="z-manager-search-button">Add Note</button>
								<button type="button" name="cancel" onclick="window.location.href = '/z/inquiries/admin/manage-inquiries/<cfif form.method EQ "userView">userIndex<cfelse>index</cfif>?zPageId=#form.zPageId#';" class="z-manager-search-button">Cancel</button></td>
						</tr>
					</table>
				</form>
			</div>
		</div><!--- 
		</td>
		</tr>
		</table>  --->
	</div> 
	<cfscript>  
	db.sql="SELECT inquiries_feedback.*, user.*, if(inquiries_feedback_x_user.inquiries_feedback_x_user_id IS NULL, #db.param(0)#, #db.param(1)#) isRead
	from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# ON 
	user.user_id = inquiries_feedback.user_id and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_feedback.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	LEFT JOIN #db.table("inquiries_feedback_x_user", request.zos.zcoreDatasource)# ON 
	inquiries_feedback_x_user.inquiries_feedback_id = inquiries_feedback.inquiries_feedback_id and 
	inquiries_feedback_x_user.site_id = inquiries_feedback.site_id and 
	inquiries_feedback_x_user.user_id=#db.param(request.zsession.user.id)# and 
	inquiries_feedback_x_user.user_id_siteidtype=#db.param(application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id))# and 
	inquiries_feedback_x_user.inquiries_feedback_x_user_deleted=#db.param(0)# 
	WHERE 
	inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_feedback.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_feedback_deleted=#db.param(0)# 
	ORDER BY inquiries_feedback_datetime DESC ";
	qFeedback=db.execute("qFeedback");  
	</cfscript>
<style type="text/css">
.z-feedback-container{width:100%; float:left; margin-bottom:10px; border-radius:5px; border:1px solid ##CCC;}
.z-feedback-header{width:100%; padding:5px; float:left;border-top-left-radius:5px;border-top-right-radius:5px;border-bottom:1px solid ##CCC; background-color:##F3F3F3;}
.z-feedback-delete-div{float:right;}
.z-feedback-delete-button{border-radius:5px;}
.z-feedback-date{color:##999;}
.z-feedback-spam{width:100%; padding:5px; font-size:13px;color:##999; float:left; background-color:##F3F3F3; border-bottom:1px solid ##CCC; }
.z-feedback-attachments{width:100%; padding:5px; float:left;}
.z-feedback-message{width:100%; padding:5px; float:left;}
.z-feedback-private-container{width:100%; float:left; border-radius:8px; background-color:##fbf3de;}
.z-feedback-private-header{width:100%; float:left;border-top-left-radius:5px;border-top-right-radius:5px; background-color:##f7df9e; border-bottom:1px solid ##e3c473; padding:5px; font-weight:bold; color:##b68500; font-size:12px; line-height:15px;}
.z-feedback-private-container .z-feedback-header{ border-top-left-radius:0px;border-top-right-radius:0px; background-color:##f7df9e;}
.z-feedback-private-container .z-feedback-date{ color:##b68500;}
.z-feedback-show-all{padding:5px; padding-top:20px; padding-bottom:20px; font-size:18px; text-decoration:none; border-top:1px solid ##CCC; border-bottom:1px solid ##CCC; text-align:center; width:100%; float:left;}

.z-feedback-old .z-feedback-message{display:none;}
.z-feedback-old .z-feedback-attachments{display:none;}
.z-feedback-show-message .z-feedback-attachments{display:block !important;}
.z-feedback-show-message .z-feedback-message{display:block !important;}
.z-feedback-show-message-button{ display:block; float:left; text-decoration:none; color:##369; width:100%; padding:5px; }
</style>
<script type="text/javascript">
function setupInquiriesFeedback(){
	$(".z-feedback-show-all-button").on("click", function(e){
		e.preventDefault();
		if(typeof this.messageOpened == "undefined"){
			this.messageOpened=false;
		}   
		$(".z-feedback-container").addClass("z-feedback-show-message"); 
		$(".z-feedback-show-all-button").parent().remove();
		$(this).hide();
	});
	$(".z-feedback-show-message-button").on("click", function(e){
		e.preventDefault();
		if(typeof this.messageOpened == "undefined"){
			this.messageOpened=false;
		}  
		if(this.messageOpened){
			this.messageOpened=false;
			$(this).parent().removeClass("z-feedback-show-message");
		}else{
			this.messageOpened=true; 
			$(this).parent().addClass("z-feedback-show-message");
			$(this).hide();
		} 
	});
	$(".z-feedback-delete-button").on("click", function(e){
		e.preventDefault();
		var result=window.confirm("Are you sure you want to delete this message?");
		if(result){
			var feedbackId=$(this).attr("data-feedback-id");
			var tempObj={};
			tempObj.id="zDeleteFeedback";
			tempObj.url=$(this).attr("data-action");
			tempObj.callback=function(r){
				var r=JSON.parse(r);
				if(r.success){
					$("##inquiriesFeedbackMessageId"+feedbackId).remove();
				}else{
					alert("Sorry, there was an error deleting the message. Please try again later.");
				}
			};
			tempObj.errorCallback=function(){
				alert("Sorry, there was an error deleting the message. Please try again later..");
			};
			tempObj.cache=false;
			zAjax(tempObj); 
		} 
	});
	/*$(".z-feedback-old .z-feedback-header").on("click", function(e){
		e.preventDefault();
		if(typeof this.messageOpened == "undefined"){
			this.messageOpened=false;
		}  
		if(this.messageOpened){
			this.messageOpened=false;
			$(this).parent().removeClass("z-feedback-show-message");
		}else{
			this.messageOpened=true; 
			$(this).parent().addClass("z-feedback-show-message");
		} 
	});*/
}
zArrDeferredFunctions.push(function(){
	setupInquiriesFeedback();
});
</script>

	<cfif qFeedBack.recordcount NEQ 0>
		<hr />
		<h2>Emails &amp; Notes</h2>
		<cfscript>  
		showAllDisplayed=false;
		for(row in qFeedback){
			echo('<div id="inquiriesFeedbackMessageId#row.inquiries_feedback_id#" class="z-feedback-container ');
			
			if(row.isRead EQ 1 and row.inquiries_feedback_id NEQ qFeedback.inquiries_feedback_id[1]){  
				echo(' z-feedback-old ');
			}else{
				echo(' z-feedback-new ');
			}
			echo('">');
				if(row.inquiries_feedback_type EQ 0){
					echo('<div class="z-feedback-private-container">');
						echo('<div class="z-feedback-private-header">PRIVATE NOTE</div>'); 
 
				}
				echo('<div class="z-feedback-header">');
					if(form.method EQ "view"){
						echo('<div class="z-feedback-delete-div">
							<a  class="z-button z-feedback-delete-button" href="##" data-feedback-id="#row.inquiries_feedback_id#" data-action="/z/inquiries/admin/feedback/deleteFeedback?inquiries_feedback_id=#row.inquiries_feedback_id#&amp;inquiries_id=#row.inquiries_id#&confirm=1&returnjson=1">X</a>
						</div>');
					}
				if(row.inquiries_feedback_message_json NEQ ''){
					jsonStruct = deserializeJSON( row.inquiries_feedback_message_json );
						if ( jsonStruct.from.name EQ '' ) {
							email=jsonStruct.from.email;
						} else {
							email=jsonStruct.from.name & ' <' & jsonStruct.from.email & '>';
						}
					savecontent variable="messageHTML"{
						if(jsonStruct.humanReplyStruct.score < 0){
							echo('<div class="z-feedback-spam">This message may be an auto-reply or spam. Score: #jsonStruct.humanReplyStruct.score#</div>');
						}
						if(arrayLen(jsonStruct.files)){
							echo('<div class="z-feedback-attachments">');
							this.showFeedbackMessageAttachments( row, jsonStruct ); 
							echo('</div>');
						}
						echo('<div class="z-feedback-message">');
						this.showFeedbackMessageFrame( row, jsonStruct );
						echo('</div>'); 
					}
				}else{ 
					name=trim(row.user_first_name&" "&row.user_last_name);
					if ( name EQ '' ) {
						email=name;
					} else {
						email=name & ' <' & row.user_username & '>';
					}  
					savecontent variable="messageHTML"{
						echo('<div class="z-feedback-message">#application.zcore.functions.zParagraphFormat(row.inquiries_feedback_comments)#</div>'); 
					}

				}
				//<a href="mailto:#jsonStruct.from.email#" style="text-decoration:none; color:##000;">#email#</a>
				echo('<strong>#email#</strong> 
				<span class="z-feedback-date">#DateFormat(row.inquiries_feedback_datetime, 'm/d/yyyy')&' at '&TimeFormat(row.inquiries_feedback_datetime, 'h:mm tt')#</span>');

				if(row.inquiries_feedback_subject NEQ ''){
					echo('<br>#row.inquiries_feedback_subject#');
				}
			echo('</div>');
			echo(messageHTML);
			if(row.isRead EQ 1 and row.inquiries_feedback_id NEQ qFeedback.inquiries_feedback_id[1]){ 
				echo('<a href="##" class="z-feedback-show-message-button">Show message</a>'); 
			}
			if(row.inquiries_feedback_type EQ 0){
				echo('</div>');
			}
			echo('</div>');
			if(row.isRead EQ 0){
				ts={
					table:"inquiries_feedback_x_user",
					datasource:request.zos.zcoreDatasource,
					struct:{
						user_id:request.zsession.user.id,
						user_id_siteidtype:application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id),
						inquiries_feedback_id:row.inquiries_feedback_id,
						inquiries_feedback_x_user_read:1,
						site_id:request.zos.globals.id,
						inquiries_feedback_x_user_updated_datetime:request.zos.mysqlnow,
						inquiries_feedback_x_user_deleted:0
					}
				};
				application.zcore.functions.zInsert(ts); 
			}else{
				if(!showAllDisplayed and qFeedBack.recordcount GTE 1 and qFeedback.isRead EQ 1){
					echo('<div class="z-float z-mb-10 "><a href="##" class="z-manager-search-button z-feedback-show-all-button">Show All Older Messages</a></div>');
				}
				showAllDisplayed=true; 
			}
		}
		</cfscript>
		


		<script type="text/javascript">
			var theFrames;

			function resizeFrames() {
				for ( var i = 0, j = theFrames.length; i < j; i++ ) {
					theFrames[ i ].style.height = '120px';
					theFrames[ i ].style.height = ( theFrames[ i ].contentWindow.document.body.offsetHeight + 16 ) + 'px';
				}
			}

			zArrDeferredFunctions.push( function() {
				theFrames = $( 'iframe.resize' );

				if ( $.browser.safari || $.browser.opera ) {
					theFrames.load( function() {
						setTimeout( resizeFrames, 0 );
					} );

					for ( var i = 0, j = theFrames.length; i < j; i++ ) {
						var iSource = theFrames[ i ].src;
						theFrames[ i ].src = '';
						theFrames[ i ].src = iSource;
					}
				} else {
					theFrames.load( function() {
						this.style.height = '120px';
						this.style.height = ( this.contentWindow.document.body.offsetHeight + 16 ) + 'px';
					} );
				}

				resizeFrames();

				$( window ).resize( function() {
					resizeFrames();
				} );
			} );
		</script>


	</cfif>
	<cfif form.inquiries_email NEQ "">
		<cfscript>
		db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# 
		WHERE inquiries_email = #db.param(form.inquiries_email)# and 
		inquiries_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		if(form.method EQ "userView"){
	    	db.sql&=inquiriesCom.getUserLeadFilterSQL(db);
		}else if(structkeyexists(request.zos.userSession.groupAccess, 'administrator') EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
			db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
			user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
		}
		db.sql&=" ORDER BY inquiries_id DESC ";
		qOther=db.execute("qOther");

		db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# ";
		qstatus=db.execute("qstatus");
		statusName=structnew();
		loop query="qstatus"{
			statusName[qstatus.inquiries_status_id]=qstatus.inquiries_status_name;
		}
		</cfscript>
		<div style="width:100%; float:left; padding:5px;">
			<cfif qOther.recordcount GTE 2>
				<h2>Other inquiries from this email address</h2>
				<table class="table-list z-radius-5" style="border-spacing:0px; width:100%; border:1px solid ##CCCCCC;">
					<tr>
						<td>Date</td>
						<td class="z-hide-at-767">Comments</td>
						<td>Assigned To</td>
						<td>Admin</td>
					<cfloop query="qOther">
						<cfscript>
						savecontent variable="local.assignedHTML"{
							currentStatusName = application.zcore.functions.zso(statusName, qOther.inquiries_status_id, false, 'Unknown Status');
							if(qOther.user_id NEQ 0){
								db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user
								WHERE user_id = #db.param(qOther.user_id)# and 
								site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL(qOther.user_id_siteIDType))# and 
								user_deleted=#db.param(0)# ";
								local.qUserTemp=db.execute("qUserTemp");
								if(local.qUserTemp.recordcount NEQ 0){
									if(local.qUserTemp.user_first_name NEQ ""){
										echo(replace(currentStatusName, 'Assigned', 'Assigned to <a href="mailto:#local.qUserTemp.user_username#">#local.qUserTemp.user_first_name# #local.qUserTemp.user_last_name#</a>'));
									}else{
										echo(replace(currentStatusName, 'Assigned', 'Assigned to <a href="mailto:#local.qUserTemp.user_username#">#local.qUserTemp.user_username#</a>'));
									}
								}
							}else{
								writeoutput('#qOther.inquiries_assign_name# #qOther.inquiries_assign_email# ');
							}
						}
						</cfscript>
					<cfif qOther.inquiries_id EQ form.inquiries_id>
						<tr class="zCurrentInquiry">
							<td>#DateFormat(qOther.inquiries_datetime, "m/dd/yyyy")#</td>
							<td class="z-hide-at-767">Current Inquiry</td>
							<td>#local.assignedHTML#</td>
							<td>&nbsp;</td>
						</tr>
					<cfelse>
						<tr style="<cfif qOther.currentrow mod 2 EQ 0>background-color:##ECECEC;</cfif>">
							<td style="border-bottom:1px solid ##CCCCCC;width:80px;">#DateFormat(qOther.inquiries_datetime, "m/dd/yyyy")#</td>
							<td class="z-hide-at-767" style="border-bottom:1px solid ##CCCCCC;">
								<cfscript>
								cm2=qOther.inquiries_comments;
								cm2=trim(rereplace(cm2,"<[^>]*?>"," ","ALL"));
								if(cm2 NEQ ""){
									writeoutput(left(cm2,350));
									if(len(cm2) GT 350){
										writeoutput("...");
									}
								}
								</cfscript>&nbsp;</td>
							<td style="border-bottom:1px solid ##CCCCCC;">
							#local.assignedHTML#
							</td>
							<td style="border-bottom:1px solid ##CCCCCC; ">
								<cfscript>
								if(form.method EQ "userView"){
									echo('<div class="z-manager-button-container"><a href="/z/inquiries/admin/manage-inquiries/userView?zPageId=#form.zPageId#&amp;zsid=#request.zsid#&amp;inquiries_id=#qOther.inquiries_id#" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a></div>');
								}else{
									echo('<div class="z-manager-button-container"><a href="/z/inquiries/admin/feedback/view?zPageId=#form.zPageId#&amp;zsid=#request.zsid#&amp;inquiries_id=#qOther.inquiries_id#" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a></div>');
								}
								</cfscript>
							</td>
						</tr>
					</cfif>
					</cfloop>
				</table>
			</cfif>
		</div>
	</cfif> 
</cffunction>

<cffunction name="showFeedbackMessageFrame" localmode="modern" access="public">
	<cfargument name="qFeedback" type="struct" required="yes">
	<cfargument name="jsonStruct" type="struct" required="yes">
	<cfscript>
	qFeedback = arguments.qFeedback;
	fbID = qFeedback.inquiries_feedback_id;

	messageHTML = arguments.jsonStruct.htmlProcessed;

	savecontent variable="messageHTML"{
		echo('<!DOCTYPE html><html><head><title></title>
		<link rel="stylesheet" type="text/css" href="/z/a/stylesheets/style.css" />
		<style type="text/css">body{margin:0px; background-color:##FFF; color:##000; font-size:14px; line-height:1.3;}</style>
		</head><body>');
		echo(messageHTML); 
		echo('</body></html>');  
	}
	fileIndex = 1;
	for ( messageFile in arguments.jsonStruct.files ) {
		messageHTML = reReplace( messageHTML, '"emailAttachShortURL"' & messageFile.filePath, request.zos.globals.domain & '/z/inquiries/download-attachment/index?fileId=' & qFeedback.office_id & '.' & qFeedback.inquiries_feedback_id & '.' & fileIndex, 'all' );
		fileIndex++;
	}

	</cfscript>
	<iframe id="qFeedback_#fbID#" width="100%" class="resize" scrolling="no" frameborder="0" sandbox="allow-same-origin allow-top-navigation"></iframe>
	<script type="text/javascript">
	var iframe_#fbID# = document.getElementById( 'qFeedback_#fbID#' );
	iframe_#fbID# = iframe_#fbID#.contentWindow || ( iframe_#fbID#.contentDocument.document || iframe_#fbID#.contentDocument );

	iframe_#fbID#.document.open();
	iframe_#fbID#.document.write( '#encodeForJavaScript( messageHTML, true )#' );
	iframe_#fbID#.document.close();


	links_#fbID# = iframe_#fbID#.document.querySelectorAll( 'a' );

	for ( var i in links_#fbID# ) {
		links_#fbID#[ i ].target = '_top';
	}
	</script>
</cffunction>

<cffunction name="showFeedbackMessageAttachments" localmode="modern" access="public">
	<cfargument name="qFeedback" type="struct" required="yes">
	<cfargument name="jsonStruct" type="struct" required="yes">
	<cfscript>
	qFeedback = arguments.qFeedback;
	fbID = qFeedback.inquiries_feedback_id;
 
	messageFiles = arguments.jsonStruct.files;

	if ( arrayLen( messageFiles ) GT 0 ) {
		echo( '<div style="float:left; padding:5px; padding-left:0px;"><strong>' & arrayLen( messageFiles ) & ' Attachments:</strong></div> ' );
		fileIndex = 1;
		for ( messageFile in arguments.jsonStruct.files ) {
			if ( messageFile.size GTE ( 1024 * 1024 ) ) {
				fileSize = numberformat( messageFile.size / 1024 / 1024, "_.__" ) & 'mb';
			} else {
				fileSize = numberformat( messageFile.size / 1024, "_.__" ) & 'kb';
			}
			echo( '<a href="' & request.zos.globals.domain & '/z/inquiries/download-attachment/index?fileId=' & qFeedback.inquiries_feedback_id & '.' & fileIndex & '" class="z-manager-search-button" >' & messageFile.fileName & ' (' & fileSize & ')</a>' );
			fileIndex++;
		} 
	}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
