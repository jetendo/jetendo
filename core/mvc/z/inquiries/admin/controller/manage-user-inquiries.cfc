<cfcomponent extends="zcorerootmapping.com.app.manager-base">
<cfoutput>   
<cffunction name="getQuickLinks" localmode="modern" access="public">
	<cfscript>
	links=[]; 
	return links;
	</cfscript>
</cffunction>
<cffunction name="getInitConfig" localmode="modern" access="private">
	<cfscript> 
	//variables.uploadPath=request.zos.globals.privateHomeDir&"zupload/inquiries/";
	//variables.displayPath="/zupload/inquiries/";
	ts={
		// required 
		customAddMethods:{"userAdd":"userInsert","userEdit":"userUpdate"},
		label:"Lead",
		pluralLabel:"Leads",
		tableName:"inquiries",
		addListInsertPosition:"top",
		datasource:request.zos.zcoreDatasource,
		deletedField:"inquiries_deleted",
		primaryKeyField:"inquiries_id",
		methods:{ // callback functions to customize the manager data and layout
			getListData:'getListData', 
			getListReturnData:'getListReturnData',
			getListRow:'getListRow', // function receives struct named row 
			getEditData:'getEditData',
			getEditForm:'getEditForm',
			beforeUpdate:'beforeUpdate',
			afterUpdate:'afterUpdate',
			beforeInsert:'beforeInsert',
			afterInsert:'afterInsert',
			getDeleteData:'getDeleteData',
			executeDelete:'',
			beforeReturnInsertUpdate:''
		},

		//optional
		disableAddEdit:false, // true disables add/edit/insert/update of leads
		requiredParams:[],
		
		editFormOverrideParams:["inquiries_type_id", "user_id"],
		customInsertUpdate:true, // true disables the normal zInsert/zUpdate calls, so you can implement them in afterInsert and afterUpdate instead
		sortField:"",
		hasSiteId:true,
		rowSortingEnabled:false,
		metaField:"",
		quickLinks:[],
		imageLibraryFields:[],

		validateFields:{
			//"inquiries_first_name":{	required:true }
		},
		imageFields:[],
		fileFields:[],
		// optional
		pagination:true,
		paginationIndex:"zIndex",
		pageZSID:"zPageId",
		perpage:30,
		title:"Ticket Manager",
		requireFeatureAccess="Leads",
		prefixURL:"/z/inquiries/admin/manage-user-inquiries/",
		navLinks:[],
		titleLinks:[],
		columnSortingEnabled:true,
		columns:[{
			fields:[{
				label:'First',
				field:'inquiries_first_name',
				sortable:true
			},{
				label:" / "
			},{
				label:"Last",
				field:'inquiries_last_name',
				sortable:true
			},{
				label:" Name"
			}]
		},{
			label:'Phone'
		},{
			label:'Received'
		},{
			label:'Last Updated'
		},{
			label:'Status'
		},{
			label:'Type'
		},{
			label:'Admin'
		}]
	};
	form.editSource=application.zcore.functions.zso(form, 'editSource');
	if(form.method EQ "userInsertBulk" or form.method EQ "insertBulk" or form.editSource EQ "contact"){
		variables.methods.beforeReturnInsertUpdate = 'beforeReturnInsertUpdate';
	}
	application.zcore.template.setTag("title","Leads");
	
	return ts;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="public">
	<cfscript>
		ts=getInitConfig(); 
		ts.disableAddButton=true;
 
 		if(structkeyexists(request, 'customTicketAddURL')){
 			link=request.customTicketAddURL;
 		}else{
 			link="/z/inquiries/admin/manage-user-inquiries/userAdd";
 		}
		arrayAppend(ts.titleLinks, { 
				label:"Add",
				link:link
			}
		);
		if(request.zsession.user.office_id NEQ ""){
			if(not structkeyexists(request.zsession, 'selectedOfficeId')){
				request.zsession.selectedOfficeId=listGetAt(request.zsession.user.office_id, 1, ",");
			}
			form["office_id"] = request.zsession.selectedOfficeId;
		}

		ts.requireFeatureAccess="";
		super.init(ts); 
		
		application.zcore.skin.includeCSS("/z/font-awesome/css/font-awesome.min.css");
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");

	</cfscript>
</cffunction>

<cffunction name="isTicketManager" localmode="modern" access="public">
	<cfscript>
	if(structkeyexists(request, 'customTicketAllowLeadTypes')){
		return true;
	}
	return false;
	</cfscript>
</cffunction>

<cffunction name="ticketFilterSQL" localmode="modern" access="public">
	<cfargument name="db" type="component" required="yes">
	<cfscript>
	db=arguments.db;

	db.sql&=" AND ((inquiries.contact_id <> #db.param(0)# and inquiries.contact_id = #db.param(request.zsession.user.contact_id)#) or inquiries.inquiries_email = #db.param(request.zsession.user.email)#  ";
	if(structkeyexists(request, 'customTicketAllowLeadTypes')){
		for(type in request.customTicketAllowLeadTypes){
			arrType=listToArray(type, "|");
			db.sql&=" or (inquiries.inquiries_type_id = #db.param(arrType[1])# and inquiries.inquiries_type_id_siteidtype=#db.param(arrType[2])#) ";
		} 
	}
	db.sql&=" ) ";
	</cfscript>
</cffunction>

<cffunction name="getUserLeadFilterSQL" localmode="modern" access="public">
	<cfargument name="db" type="component" required="yes">
	<cfscript>
	db=arguments.db;

	savecontent variable="out"{
		echo(' and ( ');

		if(request.zsession.user.office_id NEQ ""){
			echo(' (inquiries.user_id=#db.param(0)# and inquiries.office_id IN (#db.trustedSQL(request.zsession.user.office_id)#) ) or ');
		}
		// current user 
		echo(' (inquiries.user_id = #db.param(request.zsession.user.id)# and 
		inquiries.user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#)
		) ');
	}
	return out;
	</cfscript>
</cffunction>

<cffunction name="userView" localmode="modern" access="remote" roles="user">
	<cfscript>
	init();
	view();
	</cfscript>
	
</cffunction> 

<cffunction name="userInsertPrivateNote" localmode="modern" access="remote" roles="user">
	<cfscript>
	init();
	insertPrivateNote();
	</cfscript>
</cffunction> 

<cffunction name="insertPrivateNote" localmode="modern" access="remote" roles="user">
	<cfscript>
	form.editSource=application.zcore.functions.zso(form, 'editSource');
	form.modalpopforced=application.zcore.functions.zso(form, "modalpopforced",true, 0);
	db=request.zos.queryObject; 
	myForm={}; 
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id', true, 1);
	backupStatusId=form.inquiries_status_id;
	if(form.method EQ "insertPrivateNote"){
		init(); 
	}
	db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and 
	user.user_deleted=#db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))#
	WHERE inquiries.inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_deleted=#db.param(0)# and
	inquiries.site_id = #db.param(request.zos.globals.id)# ";
	qCheck = db.execute("qCheck");  


	db.sql="select * from #db.table("inquiries_status", request.zos.zcoreDatasource)# WHERE 
	inquiries_status_id = #db.param(form.inquiries_status_id)#  and 
	inquiries_status_deleted=#db.param(0)# ";
	qStatus=db.execute("qStatus");
	if(qCheck.recordcount EQ 0){
		application.zcore.functions.zReturnJson({success:false, errorMessage:"Invalid inquiry"}); 
	}
	if(qStatus.recordcount EQ 0){
		application.zcore.functions.zReturnJson({success:false, errorMessage:"Invalid status"}); 
	} 
	if(not isTicketManager()){
		// prevent ticket owner from changing status.
		form.inquiries_status_id=qCheck.inquiries_status_id;
		if(qCheck.inquiries_email EQ request.zsession.user.email){
			closedStatus={
				8:true,
				4:true,
				5:true,
				7:true
			};
			if(structkeyexists(closedStatus, qCheck.inquiries_status_id)){
				// reopen the closed lead because the customer replied to it.
				form.inquiries_status_id=2;
			}
		}
	}
	// form validation struct
	myForm.inquiries_id.required = true;
	myForm.inquiries_id.friendlyName = "Inquiry ID";
	myForm.inquiries_feedback_datetime.createDateTime = true;
	result = application.zcore.functions.zValidateStruct(form, myForm, request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true); 
		application.zcore.status.displayReturnJson(Request.zsid);
	}

	if(backupStatusId EQ 4 or backupStatusId EQ 5 or backupStatusId EQ 7 or backupStatusId EQ 8){		
		// ignore validation
	}else if(application.zcore.functions.zso(form, 'inquiries_feedback_subject') EQ ''){
		application.zcore.status.setStatus(Request.zsid, 'Subject is required.'); 
		application.zcore.status.displayReturnJson(request.zsid);
	}
	form.user_id = request.zsession.user.id;
	form.user_id_siteIdType = application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
	form.contact_id=request.zsession.user.contact_id;
	form.site_id = request.zOS.globals.id; 

	savecontent variable="customNote"{
		//echo('<table cellpadding="0" cellspacing="0" border="0"><tr><td style="background:##f7df9e; font-size:12px; padding:5px 15px 5px 15px; color:##b68500;">PRIVATE NOTE</td></tr></table>');
		echo('<p>#request.zsession.user.first_name# #request.zsession.user.last_name# (#request.zsession.user.email#) replied to lead ###form.inquiries_id#:</p>
		<h3>#form.inquiries_feedback_subject#</h3>
		#form.inquiries_feedback_comments#');
	}
	if(request.zos.isTestServer){
		// this should be happening on live server when the new lead interface is all done
		request.noleadsystemlinks=true;
	}
	savecontent variable="emailHTML"{
		iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	    iemailCom.getEmailTemplate(customNote, true);
	} 
	if(false and request.zos.isTestServer){
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
			         "name":request.zsession.user.first_name&" "&request.zsession.user.last_name,
			         "email":request.zsession.user.email,
			         "plusId":"",
			         "originalEmail":request.zsession.user.email
			      }
			   ],
			   "cc":[],
			   "bcc":[],
			   "subject":"#form.inquiries_feedback_subject#", //[Lead ###form.inquiries_id# Updated] 
			   "html":emailHTML,
			   "htmlWeb":form.inquiries_feedback_comments,
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
			filterContacts:{ managers:true },
			inquiries_status_id:backupStatusId,
			privateMessage:true,
			enableCopyToSelf:true
		};  

		// slightly inaccurate since it doesn't include all fields and attachment sizes
		ts.jsonStruct.size=len(ts.jsonStruct.subject&ts.jsonStruct.html);  
		//ts.debug=true;
		if(qCheck.office_id NEQ "0"){
			ts.filterContacts.offices=[qCheck.office_id];
		}
		if(structkeyexists(request.zos, 'manageLeadGroupIdList')){
			ts.filterContacts.userGroupIds=listToArray(request.zos.manageLeadGroupIdList, ",");
		}  
	 
		contactCom=createobject("component", "zcorerootmapping.com.app.contact");
		rs=contactCom.processMessage(ts);  
	}else{

		if(backupStatusId NEQ 0){ 
			db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# 
			SET inquiries_status_id=#db.param(backupStatusId)#, 
			inquiries_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))# 
			WHERE inquiries_id=#db.param(form.inquiries_id)# and 
			site_id = #db.param(request.zos.globals.id)# and  
			inquiries_deleted=#db.param(0)# ";
			db.execute("qUpdateInquiry");  
		}

		// insert to inquiries_feedback
		tsFeedback={
			table:"inquiries_feedback",
			datasource:request.zos.zcoreDatasource,
			struct:{
				inquiries_feedback_subject:form.inquiries_feedback_subject,
				inquiries_feedback_comments:form.inquiries_feedback_comments, // leave empty because this is an email message.
				inquiries_feedback_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				inquiries_id:form.inquiries_id,
				//user_id:user_id,
				//contact_id:0, 
				site_id:request.zos.globals.id,
				//user_id_siteIDType:user_id_siteIDType, 
				inquiries_feedback_created_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				inquiries_feedback_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
				inquiries_feedback_deleted:0,
				inquiries_feedback_message_json:"", 
				inquiries_feedback_draft:0,
				inquiries_feedback_download_key:"",
				inquiries_feedback_type:1 // 0 is private note, 1 is email
			}
		} 

		fromUser=request.zsession.user.first_name&" "&request.zsession.user.last_name;
		if(trim(fromUser) EQ ""){
			fromUser=request.zsession.user.email;
		}

		ts={};
		ts.subject=form.inquiries_feedback_subject;
		savecontent variable="output"{
			echo('#application.zcore.functions.zHTMLDoctype()#
			<head>
			<meta charset="utf-8" />
			<title></title>
			</head>
			
			<body>
				<p>There was a reply to ticket ###form.inquiries_id#:</p>
				<p>From: #fromUser#</p>
				<p>Status: #qStatus.inquiries_status_name#</p>
				<p>Subject: #form.inquiries_feedback_subject#</p>
				<p>Message: #form.inquiries_feedback_comments#</p>
				<h2><a href="/z/event/admin/manage-user-inquiries/userView?inquiries_id=#form.inquiries_id#">Login to View or Reply to Ticket</a></h2>

				<p>This email was sent from the web site:<br /><a href="#request.zos.globals.domain#">#request.zos.globals.domain#</a></p>');
				

			echo('</body>
			</html>');
		}
		ts.html=output;
		if(structkeyexists(request, 'ticketFromEmail')){
			ts.from=request.ticketFromEmail;
		}else{
			ts.from=request.fromEmail; 
		}

		ts.to=qCheck.inquiries_email;
		if(structkeyexists(request, 'ticketFromEmail')){
			ts.cc=request.ticketFromEmail;
		}else{
			ts.cc=request.fromEmail; 
		} 
		rCom=application.zcore.email.send(ts);
		if(rCom.isOK() EQ false){
			rCom.setStatusErrors(request.zsid);
			application.zcore.functions.zstatushandler(request.zsid);
			application.zcore.functions.zabort();
		}

		// build email html  
		inquiries_feedback_id=application.zcore.functions.zInsert(tsFeedback); 
		if(not inquiries_feedback_id){ 
			return {success:false, errorMessage:"Failed to save note"};
		} 
		inquiriesCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		inquiriesCom.indexInquiry(form.inquiries_id, request.zos.globals.id);
	}
	if(form.method EQ "userInsertPrivateNote"){
		if(form.editSource EQ "contact"){
			link="/z/inquiries/admin/feedback/userViewContact?contactTab=4&contact_id=#form.contact_id#&inquiries_id=#form.inquiries_id#";
		}else{
			link="/z/inquiries/admin/manage-user-inquiries/userView?inquiries_id=#form.inquiries_id#";
		}
	}else{
		if(form.editSource EQ "contact"){
			link="/z/inquiries/admin/feedback/viewContact?contactTab=4&contact_id=#form.contact_id#&inquiries_id=#form.inquiries_id#";
		}else{
			link="/z/inquiries/admin/feedback/view?inquiries_id=#form.inquiries_id#";
		}
	}
	application.zcore.functions.zReturnJson({success:true, redirect:1, redirectLink:link}); 
	</cfscript>
</cffunction>



<cffunction name="userAddPrivateNote" localmode="modern" access="remote" roles="user">
	<cfscript>
	init();
	</cfscript>
</cffunction> 

<cffunction name="addPrivateNote" localmode="modern" access="remote" roles="member">
	<cfscript>
	if(form.method EQ "addPrivateNote"){
		init();
	}
	form.modalpopforced=application.zcore.functions.zso(form, "modalpopforced",true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	echo('<div class="z-float">');
	ts={};
	displayAddNoteForm(ts);
	echo('</div>');
	</cfscript>
</cffunction> 

<cffunction name="displayAddNoteForm" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
		db=request.zos.queryObject;
		ss=arguments.ss; 
		tags=StructNew();
		db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)#  
		WHERE inquiries_id = #db.param(form.inquiries_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)#"; 
		qInquiry=db.execute("qInquiry"); 

		db.sql="SELECT * from #db.table("inquiries_feedback", request.zos.zcoreDatasource)#  
		WHERE inquiries_feedback.inquiries_id = #db.param(form.inquiries_id)# and 
		inquiries_feedback.inquiries_feedback_id = #db.param(application.zcore.functions.zso(form, 'inquiries_feedback_id',false,''))# and 
		inquiries_feedback.site_id = #db.param(request.zos.globals.id)# and 
		inquiries_feedback.inquiries_feedback_deleted=#db.param(0)#"; 
		qFeedback=db.execute("qFeedback"); 
		application.zcore.functions.zQueryToStruct(qFeedback, form, 'inquiries_id');
	</cfscript>
	<form class="zFormCheckDirty" name="sendEmailForm" id="sendEmailForm" action="/z/inquiries/admin/manage-user-inquiries/<cfif form.method EQ "userAddPrivateNote" or form.method EQ "userView">userInsertPrivateNote<cfelse>insertPrivateNote</cfif>?contact_id=#form.contact_id#&amp;inquiries_id=#form.inquiries_id#"  method="post" enctype="multipart/form-data">
		<cfif form.method EQ "addPrivateNote" or form.method EQ "userAddPrivateNote">
			<div class="z-float z-p-10 z-bg-white z-index-3" style="visibility:hidden;">
				<button type="submit" name="submitForm" class="z-manager-search-button" style="font-size:150%;">Send</button>
				<button type="button" name="cancel" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Cancel</button>
				<cfif application.zcore.user.checkGroupAccess("administrator")>   
					<a href="/z/inquiries/admin/lead-template/index" target="_blank" class="z-manager-search-button">Templates</a> 
				</cfif>
			</div> 
			<div class="z-float z-p-10 z-bg-white z-index-3" style="position:fixed;">
				<button type="submit" name="submitForm" class="z-manager-search-button" style="font-size:150%;">Send</button>
						<button type="button" name="cancel" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Cancel</button>
				<cfif application.zcore.user.checkGroupAccess("administrator")>  
					<a href="/z/inquiries/admin/lead-template/index" target="_blank" class="z-manager-search-button">Templates</a> 
				</cfif>
			</div> 
		</cfif>
		<div class="z-manager-edit-errors z-float"></div>  
		<table class="table-list" style="width:100%; "> 
			<cfscript>
			if(form.inquiries_feedback_subject EQ ""){
				// get lead type of inquiry
				db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
				WHERE inquiries_type_deleted=#db.param(0)# and 
				inquiries_type_id=#db.param(qInquiry.inquiries_type_id)# and 
				site_id=#db.param(application.zcore.functions.zGetSiteIdFromSiteIdType(qInquiry.inquiries_type_id_siteidtype))# ";
				qType=db.execute("qType");
				if(qType.recordcount NEQ 0){
					defaultSubject="RE: Lead ###form.inquiries_id# - #qType.inquiries_type_name# submission on #request.zos.globals.shortDomain#";
				}else{
					defaultSubject="RE: Lead ###form.inquiries_id# on #request.zos.globals.shortDomain#";
				} 
				form.inquiries_feedback_subject=defaultSubject;
			}
			</cfscript>
			<tr>
				<th>Subject:</th>
				<td><input name="inquiries_feedback_subject" id="inquiries_feedback_subject" type="text" maxlength="50" value="#htmleditformat(form.inquiries_feedback_subject)#" style="min-width:100%; width:100%; max-width:100%;" /></td> 
			</tr>
			<tr>
				<th>Message:</th>
				<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "inquiries_feedback_comments";
					htmlEditor.value			= form.inquiries_feedback_comments;
					htmlEditor.width			= "100%";
					htmlEditor.height		= 150;
					htmlEditor.createSimple();
					</cfscript> 
				</td>
			</tr>
			<cfif isTicketManager()>
				<tr>
					<th>Status:</th>
					<td>
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
					</td>
				</tr>
			</cfif>
		</table>
		<cfif form.method EQ "view" or form.method EQ "userView">
			<div class="z-float z-p-10 z-bg-white z-index-3">
				<button type="submit" name="submitForm" class="z-manager-search-button" style="font-size:150%;">Send</button>
			</div> 
		</cfif>
	</form>
	<br>
	<script type="text/javascript">
	zArrDeferredFunctions.push( function() { 
		function emailSentCallback(r){
			window.parent.location.reload();
		}
		$("##sendEmailForm").on("submit", function(e){ 
			var valid3=true;
			if($("##inquiries_feedback_subject").val()==""){
				alert("Subject is required.");
				valid3=false;
			}
			if(!valid3){
				return false;
			}
			return zSubmitManagerEditForm(this, emailSentCallback); 
		});
	});
	</script>
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

		db.sql="SELECT * FROM (#db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
		#db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status) 
		LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
		user.user_id = inquiries.contact_id and user.site_id = #db.param(request.zos.globals.id)#  and 
		user_deleted = #db.param(0)#
		LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
		inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
		inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
		inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
		inquiries_type_deleted = #db.param(0)#
		WHERE inquiries.site_id = #db.param(request.zos.globals.id)# 
		AND inquiries_status_deleted = #db.param(0)#
		AND	inquiries_deleted = #db.param(0)# 
		AND inquiries.inquiries_status_id = inquiries_status.inquiries_status_id 
		AND (( inquiries_id = #db.param(form.inquiries_id)# and inquiries_parent_id = #db.param(0)# ) or 
		(inquiries_parent_id = #db.param(form.inquiries_id)# )) ";
		ticketFilterSQL(db);
		db.sql&=" 
		GROUP BY inquiries_id";
		qinquiry=db.execute("qinquiry");

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
 
	</cfscript>

	<div class="z-float">
		<div class="z-float"><a href="/z/inquiries/admin/manage-user-inquiries/userIndex">Ticket Manager/</a><br /><br /></div>
		<div class="z-float"><h3>Ticket Id #qinquiry.inquiries_id#</h3></div>
		<div class="z-3of5 z-ph-0"> 
			<table style="border-spacing:0px; width:100%;" class="table-list">
				<tbody>
					<tr>
						<th style="width:130px; text-align:left;">Name:</th>
						<td>#qinquiry.inquiries_first_name#&nbsp;#qinquiry.inquiries_last_name#</td>
					</tr>
					<tr>
						<th style="width:130px; text-align:left;">Email:</th>
						<td><a href="mailto:#qinquiry.inquiries_email#?subject=RE%3A%20Your%20web%20site%20inquiry&amp;body=" class="z-manager-search-button">#qinquiry.inquiries_email#</a>&nbsp;</td>
					</tr>
					<tr>
						<th style="width:130px; vertical-align:top;text-align:left;">Comments:</th>
						<td>#qinquiry.inquiries_comments#</td>
					</tr>
					<tr>
						<th style="width:130px; text-align:left;">Date Received:</th>
						<td>#DateTimeFormat(qinquiry.inquiries_datetime,"mm/dd/yyyy 'at' HH:nn tt")#</td>
					</tr>
					<tr>
						<th style="width:130px; text-align:left;">Status:</th>
						<td>#qinquiry.inquiries_status_name#</td>
					</tr>
					<cfif qinquiry.inquiries_comments NEQ "">
						<tr>
							<th style="width:130px; text-align:left;">Comments:</th>
							<td>#qinquiry.inquiries_comments#</td>
						</tr>
					</cfif>
					<cfif trim(qinquiry.inquiries_custom_json) NEQ ''>
						<cfscript>
						var jsonStruct=deserializejson(qinquiry.inquiries_custom_json);
						for(var i=1;i LTE arrayLen(jsonStruct.arrCustom);i++){
							if(jsonStruct.arrCustom[i].value EQ ""){
								continue;
							}
							if(len(jsonStruct.arrCustom[i].label) GT 30){
								writeoutput('
								<tr>
									<th style="width:130px; vertical-align:top;text-align:left;">&nbsp;</th>
									<td>
									<p>'&htmleditformat(jsonStruct.arrCustom[i].label)&'</p>
									<p>'&replace(jsonStruct.arrCustom[i].value, chr(10), "<br>", "all")&'</p></td>
								</tr>
								');	
							}else{
								writeoutput('
								<tr>
									<th style="width:130px;  vertical-align:top;text-align:left;">'&htmleditformat(jsonStruct.arrCustom[i].label)&'</th>
									<td>'&replace(jsonStruct.arrCustom[i].value, chr(10), "<br>", "all")&'</td>
								</tr>
								');	
							}
						}
						</cfscript>
					</cfif>
				</tbody>
			</table>		
		</div>	
		<div class="z-2of5 z-ph-0"> 
			<div style="" class="z-inquiry-note-box">
				<cfscript>
				ts={};
				displayAddNoteForm(ts);
				</cfscript>
			</div>
		</div> 
	</div> 
	<cfscript>
		ts={
			inquiries_id:form.inquiries_id
		};
		comFeedback = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.feedback");
		echo('<div class="z-float">');
			comFeedback.displayLeadFeedback(ts);
		echo('</div>');
	</cfscript>
</cffunction>

<cffunction name="userAdd" localmode="modern" access="remote" roles="user">
	<cfscript>
	init();
	//super.edit();
	userEdit();
	</cfscript>
</cffunction>

<cffunction name="userEdit" localmode="modern" access="remote" roles="user">
	<cfscript>
		init();
	  	form.inquiries_type_id 				= 1;	
	    form.inquiries_type_id_siteIdType 	= 4;	
	    form.inquiries_status_id			= 1;
	    form.inquiries_priority				= 5;
	    form.contact_id						= request.zsession.user.id;
		form.inquiries_subject				= "New Inquiry on #request.zos.globals.shortdomain#"; 
	    form.inquiries_first_name 			= request.zsession.user.first_name;
	    form.inquiries_last_name  			= request.zsession.user.last_name;
	    form.inquiries_email				= request.zsession.user.email;
		form.inquiries_phone1				= application.zcore.functions.zso(form, 'inquiries_phone1');
		form.inquiries_address				= application.zcore.functions.zso(form, 'inquiries_address');
		form.inquiries_city					= application.zcore.functions.zso(form, 'inquiries_city');
		form.inquiries_state				= application.zcore.functions.zso(form, 'inquiries_state');
		form.inquiries_country				= application.zcore.functions.zso(form, 'inquiries_country');
		form.inquiries_zip					= application.zcore.functions.zso(form, 'inquiries_zip');
		form.inquiries_comments				= application.zcore.functions.zso(form, 'inquiries_comments');
		form.inquiries_id					= application.zcore.functions.zso(form, 'inquiries_id', true,0);
		form.submitted						= application.zcore.functions.zso(form, 'submitted', true,0);
		form.inquiries_updated_datetime		= request.zos.mysqlnow;
		if(form.inquiries_id EQ 0 AND form.submitted EQ 1 AND form.inquiries_comments NEQ ""){
			//ts.struct.inquiries_datetime = request.zos.mysqlnow;
			form.inquiries_datetime 			= request.zos.mysqlnow;
			//form.inquiries_id = application.zcore.functions.zInsert(ts);
			application.zcore.functions.zRecordLead();
		}else if(form.inquiries_id GT 0 AND form.submitted EQ 1 AND form.inquiries_comments NEQ ""){
			var ts = {};
			ts.table			= 'inquiries';
			ts.datasource		= request.zos.zcoreDatasource;
			ts.struct			= { 
  			inquiries_type_id 				: 1,	
    		inquiries_type_id_siteIdType	: 4,
			inquiries_status_id				: 1, 
  			site_id 						: request.zos.globals.id,	
			contact_id 						: request.zsession.user.id, 
    		inquiries_first_name 			: request.zsession.user.first_name,
    		inquiries_last_name  			: request.zsession.user.last_name,
    		inquiries_email					: request.zsession.user.email,
    		inquiries_priority				: 5,
			inquiries_phone1				: form.inquiries_phone1,
			inquiries_address				: form.inquiries_address,
			inquiries_city					: form.inquiries_city,
			inquiries_state					: form.inquiries_state,
			inquiries_country				: form.inquiries_country,
			inquiries_zip					: form.inquiries_zip,
			inquiries_comments				: form.inquiries_comments,
			inquiries_id					: form.inquiries_type_id,
			inquiries_updated_datetime		: request.zos.mysqlnow };			
			application.zcore.functions.zUpdate(ts);
		}else{
			
		}
	</cfscript>
		<form id="frmTicketManager" action="/z/inquiries/admin/manage-user-inquiries/userEdit" method="post" onsubmit="return validateForm();">
			<input type="hidden" name="inquiries_id" value="#form.inquiries_id#" />
			<input type="hidden" name="submitted" id="submitted" value="#form.submitted#" />
			<div class="z-float">
			<div class="z-float z-pt-20">
				<cfif form.inquiries_id EQ 0><button type="submit" name="btnSave" value="Save" class="z-manager-search-button">Save</button></cfif>
				<button type="button" name="btnCancel" value="Cancel" class="z-manager-search-button" onclick="window.location.href='/z/inquiries/admin/manage-user-inquiries/userIndex';">Cancel</button>
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px;">* = required field</span>
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px;">First Name</span>
				<input READONLY type="text" name="inquiries_first_name" value="#htmleditformat(form.inquiries_first_name)#" />
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px;">First Name</span>
				<input READONLY type="text" name="inquiries_last_name" value="#htmleditformat(form.inquiries_last_name)#" />
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px;">Email *</span>
				<input READONLY type="text" name="inquiries_email" value="#htmleditformat(form.inquiries_email)#" />
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px;">Phone</span>			
				<input type="text" name="inquiries_phone1" value="#htmleditformat(form.inquiries_phone1)#" />
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px;">Address</span>
				<input type="text" name="inquiries_address" value="#htmleditformat(form.inquiries_address)#" />
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px;">City</span>
				<input type="text" name="inquiries_city" value="#htmleditformat(form.inquiries_city)#" />
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px;">State</span>
				#application.zcore.functions.zStateSelect("inquiries_state",'', 'width:250px;')#
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px;">Country</span>
				#application.zcore.functions.zCountrySelect("inquiries_country",'United States', 'width:250px;')#
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px;">Zip</span>
				<input type="text" name="inquiries_zip" value="#htmleditformat(form.inquiries_zip)#" />
			</div>
			<div class="z-float z-pt-20">
				<span style="display:inline-block; width:160px; vertical-align:top;">Comments</span>
				<textarea name="inquiries_comments" id="inquiries_comments" cols="50" rows="5">#htmleditformat(form.inquiries_comments)#</textarea>
			</div>
			<div class="z-float z-pt-20">
				<cfif form.inquiries_id EQ 0><button type="submit" name="btnSave" value="Save" class="z-manager-search-button">Save</button></cfif>
				<button type="button" name="btnCancel" value="Cancel" class="z-manager-search-button" onclick="window.location.href='/z/inquiries/admin/manage-user-inquiries/userIndex';">Cancel</button>
			</div>
		</div>	
		<script>
			function validateForm() {
				if ($("##inquiries_comments").val() == "") {
					alert("Please enter a comment.");
					return false;
				}
				$("##submitted").val("1");
				return true;
			}
		</script>	
		</form>

</cffunction> 

<cffunction name="userInsert" localmode="modern" access="remote" roles="user">
	<cfscript>
	init(); 
	super.update();
	</cfscript>
</cffunction>

<cffunction name="userUpdate" localmode="modern" access="remote" roles="user">
	<cfscript>
	init();
	super.update();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="user">
	<cfscript>
		userIndex();
	</cfscript>
</cffunction>

<cffunction name="userIndex" localmode="modern" access="remote" roles="user">
	<cfscript> 
		init();
		super.index();
	</cfscript>
</cffunction> 

<cffunction name="validateInsertUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript> 
	db=request.zos.queryObject;
	rs={success:true};
 


	var myForm={}; 
	myForm.inquiries_email.allowNull = true;
	myForm.inquiries_email.friendlyName = "Email Address";
	myForm.inquiries_email.email = true;
	myForm.inquiries_first_name.required = true;
	myForm.inquiries_first_name.friendlyName = "First Name";
	 
	//CHECK OTHER TYPES BESIDES INSERT
	if(form.method EQ "insert" or structKeyExists(variables.reverseCustomAddMethods,form.method)){
		myForm.inquiries_datetime.createDateTime = true;
	}
	if(application.zcore.functions.zso(form,'inquiries_type_other') NEQ ''){
		form.inquiries_type_id=0;
		form.inquiries_type_id_siteIdType=4;
	}else{
		local.arrType=listToArray(form.inquiries_type_id,"|");
		form.inquiries_type_id=local.arrType[1];
		form.inquiries_type_id_siteIDType=local.arrType[2];
	}
	if(application.zcore.functions.zso(form,'inquiries_type_id') EQ '' and application.zcore.functions.zso(form,'inquiries_type_other') EQ ''){
		application.zcore.status.setStatus(Request.zsid, 'Source is required',form,true);
		return {success:false};
	}
	form.inquiries_status_id = application.zcore.functions.zso(form, 'inquiries_status_id', true);
	if(form.inquiries_status_id EQ 0){
		form.inquiries_status_id=2;
	} 
	form.user_id=request.zsession.user.id;
	form.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
  	
  	form.inquiries_type_id = 1;
    form.inquiries_type_id_siteIdType = 4;
	result = application.zcore.functions.zValidateStruct(form, myForm,request.zsid,true);
	if(result){	
		return {success:false};
	}  

	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="beforeUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	db=request.zos.queryObject;
	rs=validateInsertUpdate();
	if(not rs.success){
		application.zcore.status.displayReturnJson(request.zsid);
	} 
	//SET THE contact_id
	form.contact_id = request.zsession.user.id;

	db.sql="SELECT * FROM #db.table("inquiries", request.zos.zcoreDatasource)#
	WHERE inquiries_deleted = #db.param(0)# and  
	inquiries_id=#db.param(form.inquiries_id)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	qData=db.execute("qData");
	return {success:true, qData:qData};
	</cfscript>
</cffunction>

<cffunction name="beforeReturnInsertUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>   
	urlPage = "";
	if(form.method EQ "update"){
		if(form.contact_id EQ 0){
			link="/z/inquiries/admin/manage-user-inquiries/index?zPageId=#form.zPageId#&zsid=#request.zsid#";
		}
		link="/z/inquiries/admin/feedback/viewContact?contactTab=4&contact_id=#form.contact_id#&inquiries_id=#form.inquiries_id#";
		return {success:true, id:form.inquiries_id, redirect:1,redirectLink: link};
	}else if(form.method EQ "userUpdate"){
		if(form.contact_id EQ 0){
			link="/z/inquiries/admin/manage-user-inquiries/userIndex?zPageId=#form.zPageId#&zsid=#request.zsid#";
		}
		link="/z/inquiries/admin/feedback/userViewContact?contactTab=4&contact_id=#form.contact_id#&inquiries_id=#form.inquiries_id#";
		return {success:true, id:form.inquiries_id, redirect:1,redirectLink: link};
	}
	if(structKeyExists(variables.reverseCustomAddMethods, form.method)){
		urlPage = variables.reverseCustomAddMethods[form.method];
	} else{
		urlPage = form.method;
	}
	var link = "#variables.prefixURL#" & urlPage & "?modalpopforced=0&inquiries_type_id=#form.inquiries_type_id&"|"&form.inquiries_type_id_siteIDType#&zsid=" & request.zsid;
	if(structkeyexists(form, "user_id")){
		link &= "&user_id=" & form.user_id;
	}
	if(structkeyexists(form, "office_id") AND application.zcore.user.checkGroupAccess("administrator")){
		link &= "&office_id=" & form.office_id;
	}

	return {success:true, id:form.inquiries_id, redirect:1,redirectLink: link};
	</cfscript>
</cffunction>


<cffunction name="afterUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	db=request.zos.queryObject; 
	savecontent variable="customNote"{
		//echo('<table cellpadding="0" cellspacing="0" border="0"><tr><td style="background:##f7df9e; font-size:12px; padding:5px 15px 5px 15px; color:##b68500;">PRIVATE NOTE</td></tr></table>');
		echo('<p>#request.zsession.user.first_name# #request.zsession.user.last_name# (#request.zsession.user.email#) replied to lead ###form.inquiries_id#:</p>
		<h3>#form.inquiries_feedback_subject#</h3>
		#form.inquiries_feedback_comments#');
	}
	if(request.zos.isTestServer){
		// this should be happening on live server when the new lead interface is all done
		request.noleadsystemlinks=true;
	}
	savecontent variable="emailHTML"{
		iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	    iemailCom.getEmailTemplate(customNote, true);
	} 
	if(request.zos.isTestServer){
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
			         "name":request.zsession.user.first_name&" "&request.zsession.user.last_name,
			         "email":request.zsession.user.email,
			         "plusId":"",
			         "originalEmail":request.zsession.user.email
			      }
			   ],
			   "cc":[],
			   "bcc":[],
			   "subject":"#form.inquiries_feedback_subject#", //[Lead ###form.inquiries_id# Updated] 
			   "html":emailHTML,
			   "htmlWeb":form.inquiries_feedback_comments,
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
			filterContacts:{ managers:true },
			privateMessage:true,
			enableCopyToSelf:true
		};  

		// slightly inaccurate since it doesn't include all fields and attachment sizes
		ts.jsonStruct.size=len(ts.jsonStruct.subject&ts.jsonStruct.html);  
		//ts.debug=true;
		if(qCheck.office_id NEQ "0"){
			ts.filterContacts.offices=[qCheck.office_id];
		}
		if(structkeyexists(request.zos, 'manageLeadGroupIdList')){
			ts.filterContacts.userGroupIds=listToArray(request.zos.manageLeadGroupIdList, ",");
		}  
		//writedump(ts);abort;
		//writedump(ts);	abort; 
	 
		contactCom=createobject("component", "zcorerootmapping.com.app.contact");
		rs=contactCom.processMessage(ts);  
	}else{ 
		// send email to the assigned user.
		toEmail=qCheck.user_email;
		if(request.zos.isTestServer){
			toEmail=request.zos.developerEmailTo;
		}
		ts={
			to:toEmail,
			from:request.fromEmail,
			subject:"#form.inquiries_feedback_subject#",
			html:emailHTML
		};
		application.zcore.email.send(ts);
	}
	</cfscript>
</cffunction>

<cffunction name="afterUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	db=request.zos.queryObject; 
	rs={success:true}; 
	result=application.zcore.functions.zUpdateLead(form);  
	if(result EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead failed to be updated.", false,true);
		application.zcore.status.displayReturnJson(request.zsid);
	}else{
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead Updated.");
	}
	//sendLeadUpdatedEmail("Lead ###form.inquiries_id# was updated");

	return rs;
	</cfscript>
</cffunction>

<cffunction name="beforeInsert" localmode="modern" access="private" returntype="struct">
	<cfscript> 
	//SET THE contact_id
	form.contact_id = request.zsession.user.id;
	rs=validateInsertUpdate();
	if(not rs.success){
		application.zcore.status.displayReturnJson(request.zsid);
	}
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="afterInsert" localmode="modern" access="private" returntype="struct">
	<cfscript>
	db=request.zos.queryObject; 
	rs={success:true}; 

	form.inquiries_session_id=application.zcore.session.getSessionId(); 

	form.inquiries_id=application.zcore.functions.zInsertLead(); 
	if(form.inquiries_id EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead failed to be added.", false,true);
		application.zcore.status.displayReturnJson(request.zsid);
	}else{
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead Added.");
	}
	//sendLeadUpdatedEmail("Lead ###form.inquiries_id# was added");
	return rs;
	</cfscript>
</cffunction>


<cffunction name="getDeleteData" localmode="modern" access="private">
	<cfscript>
	application.zcore.functions.z404("Delete is disabled");
	</cfscript>
</cffunction>

<cffunction name="getEditData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 

	form.inquiries_id=application.zcore.functions.zso(form, 'inquiries_id', true);
	rs={};
	db.sql="SELECT * FROM #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	inquiries_deleted = #db.param(0)# and 
	inquiries_id=#db.param(form.inquiries_id)# 
	  ";
	ticketFilterSQL(db);
	rs.qData=db.execute("qData");
	if(form.method EQ 'edit'){
		application.zcore.template.setTag("title","Edit Lead");
	}else{
		application.zcore.template.setTag("title","Add Lead");
	} 
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListReturnData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject;  
 
	loadListLookupData();
	db.sql="SELECT * 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE inquiries.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_deleted = #db.param(0)# and 
	inquiries_id=#db.param(form.inquiries_id)#	"; 
	if(form.method EQ "userInsert" or form.method EQ "userUpdate"){ 
		db.sql&=getUserLeadFilterSQL(db); 
	}else{
		if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
			db.sql&=" and inquiries.user_id = #db.param(request.zsession.user.id)# and user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#";
		}
	}
	rs={};
	rs.qData=db.execute("qData");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getEditForm" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject; 
	
	loadListLookupData();
	
	rs={
		javascriptChangeCallback:"",
		javascriptLoadCallback:"",
		tabs:{
			"Basic":{
				fields:[]
			},
			"Advanced":{
				fields:[]
			}
		}
	};
	// basic fields
	fs=[];
  	form.inquiries_type_id 				= 1;	
    form.inquiries_type_id_siteIdType 	= 4;	
    form.inquiries_first_name 			= request.zsession.user.first_name;
    form.inquiries_last_name  			= request.zsession.user.last_name;
    form.inquiries_email				= request.zsession.user.email;
	savecontent variable="field"{
		echo('<input type="text" name="inquiries_first_name" value="#htmleditformat(form.inquiries_first_name)#" />');
	}
	arrayAppend(fs, {label:'First Name', required:true, field:field}); 
	savecontent variable="field"{
		echo('<input type="text" name="inquiries_last_name" value="#htmleditformat(form.inquiries_last_name)#" />');
	}
	arrayAppend(fs, {label:'Last Name', field:field}); 


	savecontent variable="field"{
		echo('<input type="text" name="inquiries_email" value="#htmleditformat(form.inquiries_email)#" />');
	}
	arrayAppend(fs, {label:'Email', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="inquiries_phone1" value="#htmleditformat(form.inquiries_phone1)#" />');
	}
	arrayAppend(fs, {label:'Phone', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="inquiries_address" value="#htmleditformat(form.inquiries_address)#" />');
	}
	arrayAppend(fs, {label:'Address', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="inquiries_city" value="#htmleditformat(form.inquiries_city)#" />');
	}
	arrayAppend(fs, {label:'City', field:field});

	savecontent variable="field"{
		echo(application.zcore.functions.zStateSelect("inquiries_state", application.zcore.functions.zso(form,'inquiries_state')));
	}
	arrayAppend(fs, {label:'State', field:field});

	savecontent variable="field"{
		echo(application.zcore.functions.zCountrySelect("inquiries_country", application.zcore.functions.zso(form,'inquiries_country')));
	}
	arrayAppend(fs, {label:'Country', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="inquiries_zip" value="#htmleditformat(form.inquiries_zip)#" />');
	}
	arrayAppend(fs, {label:'Postal Code', field:field});
  
	savecontent variable="field"{
		echo('<textarea name="inquiries_comments" cols="50" rows="5">#htmleditformat(form.inquiries_comments)#</textarea>');
	}
	arrayAppend(fs, {label:'Comments', field:field});


	if(application.zcore.functions.zso(form, 'inquiries_priority', true, 0) EQ 0){
		form.inquiries_priority=5;
	}
	savecontent variable="field"{  
		selectStruct = StructNew();
		selectStruct.name = "inquiries_priority";
		selectStruct.listLabels = "1 (Low),2,3,4,5 (Default),6,7,8,9 (High)";
		selectStruct.listValues = "1,2,3,4,5,6,7,8,9";
		selectStruct.hideSelect=true;
		selectStruct.listLabelsDelimiter = ","; 
		selectStruct.listValuesDelimiter = ",";
		application.zcore.functions.zInputSelectBox(selectStruct);
	}
	arrayAppend(fs, {label:'Priority', field:field});
	rs.tabs.basic.fields=fs;
	return rs;
	</cfscript>  
</cffunction>

<cffunction name="loadListLookupData" localmode="modern" access="public" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# ";
	qstatus=db.execute("qstatus");
	variables.statusName={};
	loop query="qstatus"{
		variables.statusName[qstatus.inquiries_status_id]=qstatus.inquiries_status_name;
	}

	db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
	WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
	inquiries_type_deleted = #db.param(0)# ";
	if(not application.zcore.app.siteHasApp("listing")){
		db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
	}
	if(not application.zcore.app.siteHasApp("rental")){
		db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
	}
	db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
	variables.qTypes=db.execute("qTypes");
	loop query="variables.qTypes"{
		variables.typeNameLookup[variables.qTypes.inquiries_type_id&"|"&variables.qTypes.inquiries_type_id_siteIdType]=variables.qTypes.inquiries_type_name;
	}

	if(application.zcore.user.checkGroupAccess("administrator")){ 
		ts={
			sortBy:"name",
			returnType:"struct"
		};
		variables.officeLookup=application.zcore.user.getOffices(ts);
	}else{
		ts={
			ids:listToArray(request.zsession.user.office_id, ","),
			sortBy:"name",
			returnType:"struct"
		};
		variables.officeLookup=application.zcore.user.getOffices(ts); 
	} 

	return { statusName:variables.statusName, typeNameLookup:variables.typeNameLookup, officeLookup:variables.officeLookup};
	</cfscript> 

</cffunction>

<cffunction name="getListData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 
	rs={};
	loadListLookupData();

	form.search_email=application.zcore.functions.zso(form, 'search_email');
	form.search_phone=application.zcore.functions.zso(form, 'search_phone');
	form.inquiries_search=application.zcore.functions.zso(form, 'inquiries_search');
	searchTextOriginal=replace(replace(replace(form.inquiries_search, '+', ' ', 'all'), '@', '_', 'all'), '"', '', "all");
	if(not isnumeric(searchTextOriginal)){
		form.searchText=application.zcore.functions.zCleanSearchText(searchTextOriginal, true);
	}else{
		form.searchText=searchTextOriginal;
	}
	form.uid=application.zcore.functions.zso(form, 'uid');
	arrU=listToArray(form.uid, '|');
	form.selected_user_id=0;
	if(arrayLen(arrU) EQ 2){
		form.selected_user_id=arrU[1];
		form.selected_user_id_siteIDType=arrU[2];
	}
	if(structkeyexists(form, 'leadcontactfilter')){
		request.zsession.leadcontactfilter=form.leadcontactfilter;		
	}else if(isDefined('request.zsession.leadcontactfilter') EQ false){
		request.zsession.leadcontactfilter='all';
	} 
	request.zsession.leadviewspam=0;	

 
	db.sql="select min(inquiries_datetime) as inquiries_datetime 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	where site_id = #db.param(request.zos.globals.id)# and  
	inquiries.inquiries_datetime <> #db.param('')# and 
	inquiries_parent_id = #db.param(0)# and 
	inquiries_deleted = #db.param(0)#  ";
	ticketFilterSQL(db);
	variables.qinquiriesFirst=db.execute("qinquiriesFirst"); 

	if(isnull(variables.qinquiriesFirst.inquiries_datetime) EQ false and isdate(variables.qinquiriesFirst.inquiries_datetime)){
		variables.inquiryFirstDate=variables.qinquiriesFirst.inquiries_datetime;
	}else{
		variables.inquiryFirstDate=dateFormat(now(), "yyyy-mm-dd")&" 00:00:00";
	}
	if(not structkeyexists(form, 'inquiries_end_date') or not isdate(form.inquiries_end_date)){  
		form.inquiries_end_date=now();
	}
	if(not structkeyexists(form, 'inquiries_start_date') or not isdate(form.inquiries_start_date)){  
		form.inquiries_start_date=variables.inquiryFirstDate; 
	}
	if(form.inquiries_start_date EQ false or form.inquiries_end_date EQ false){
		form.inquiries_start_date = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");
		form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
	}
	if(datediff("d",form.inquiries_start_date, variables.inquiryFirstDate) GT 0){
			form.inquiries_start_date=variables.inquiryFirstDate;
	}
	if(dateCompare(form.inquiries_start_date, form.inquiries_end_date) EQ 1){
		form.inquiries_end_date = form.inquiries_start_date;
	} 
 
	db.sql="SELECT *, 
	inquiries_id maxid, inquiries_datetime maxdatetime, #db.param('1')# inquiryCount";
	if(searchTextOriginal NEQ ''){
		db.sql&=" , MATCH(inquiries.inquiries_search) AGAINST (#db.param(form.searchText)#) as score ";
	}
	db.sql&="
	FROM (#db.table("inquiries", request.zos.zcoreDatasource)#) 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE  
	inquiries_deleted = #db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# ";
	if(form.search_phone NEQ ""){
		db.sql&=" and inquiries.inquiries_phone1 like #db.param("%"&form.search_phone&"%")# ";
	}
	if(form.search_email NEQ ""){
		db.sql&=" and inquiries.inquiries_email like #db.param("%"&form.search_email&"%")# ";
	}
	if(searchTextOriginal NEQ ''){
		db.sql&=" and 
		(inquiries.inquiries_id = #db.param(searchTextOriginal)# or 
		MATCH(inquiries.inquiries_search) AGAINST (#db.param(form.searchText)#) 
		or inquiries.inquiries_search like #db.param('%#replace(form.searchText,' ','%','ALL')#%')# 
		) ";
	}
	db.sql&=" and inquiries_parent_id = #db.param(0)# ";
	ticketFilterSQL(db);

	if(form.inquiries_start_date EQ false){
		db.sql&=" and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
		inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#) ";
	}else{
		db.sql&=" and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
		inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
	}
	if(application.zcore.functions.zso(form, 'inquiries_name') NEQ ""){
		db.sql&=" and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name) LIKE #db.param('%#form.inquiries_name#%')# ";
	}
	if(application.zcore.functions.zso(form, 'inquiries_type_id') NEQ "" and form.inquiries_type_id CONTAINS "|"){
		db.sql&=" and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
		inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))# ";
	}
	if(searchTextOriginal NEQ ''){
		db.sql&=" ORDER BY score DESC, ";
	}else{
		db.sql&=" ORDER BY ";
	}
	sortColumnSQL=getSortColumnSQL();
	if(sortColumnSQL NEQ ''){
		db.sql&=" #sortColumnSQL# inquiries_id ASC";
	}else{
		db.sql&=" maxdatetime DESC ";
	}
	db.sql&=" LIMIT #db.param(max(0,(form.zIndex-1))*30)#,#db.param(30)#";
	rs.qData=db.execute("qData");    
	db.sql="SELECT count(inquiries.inquiries_email) count 
	from #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE inquiries.site_id = #db.param(request.zos.globals.id)# and ";
	db.sql&=" inquiries.inquiries_status_id <> #db.param(0)# and  ";
	db.sql&=" inquiries_deleted = #db.param(0)# 
	and inquiries_parent_id = #db.param(0)# ";
	ticketFilterSQL(db);
	if(form.selected_user_id NEQ 0){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#";
	}
	if(form.search_phone NEQ ""){
		db.sql&=" and inquiries.inquiries_phone1 like #db.param("%"&form.search_phone&"%")# ";
	}
	if(form.search_email NEQ ""){
		db.sql&=" and inquiries.inquiries_email like #db.param("%"&form.search_email&"%")# ";
	}
	if(searchTextOriginal NEQ ''){
		db.sql&=" and 
		(inquiries.inquiries_id = #db.param(searchTextOriginal)# or 
		MATCH(inquiries.inquiries_search) AGAINST (#db.param(form.searchText)#) 
		or inquiries.inquiries_search like #db.param('%#replace(form.searchText,' ','%','ALL')#%')# 
		) ";
	}
	if(form.inquiries_start_date EQ false){
		db.sql&=" and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
		inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)";
	}else{
		db.sql&=" and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
		inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)";
	}
	if(application.zcore.functions.zso(form, 'inquiries_name') NEQ ""){
		db.sql&=" and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name) LIKE #db.param('%#form.inquiries_name#%')#";
	}
	if(application.zcore.functions.zso(form, 'inquiries_type_id') NEQ "" and form.inquiries_type_id CONTAINS "|"){
		db.sql&=" and inquiries.inquiries_type_id = #db.param(listgetat(form.inquiries_type_id, 1, "|"))# and 
		inquiries_type_id_siteIDType = #db.param(listgetat(form.inquiries_type_id, 2, "|"))#";
	}
	rs.qCount=db.execute("qCount");   
	rs.searchFields=[]; 

	savecontent variable="typeField"{

		db.sql="SELECT *, 
		#db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_type.site_id"))# as 
		inquiries_type_id_siteIDType from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
		WHERE  site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
		inquiries_type_deleted = #db.param(0)# ";
		if(not application.zcore.app.siteHasApp("listing")){
			db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
		}
		if(not application.zcore.app.siteHasApp("rental")){
			db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
		}
		db.sql&="ORDER BY inquiries_type_sort ASC, inquiries_type_name ASC ";
		qTypes=db.execute("qTypes");
		selectStruct = StructNew();
		selectStruct.name = "inquiries_type_id";
		selectStruct.query = qTypes;
		selectStruct.inlineStyle="width:100%;";
		selectStruct.queryLabelField = "inquiries_type_name";
		selectStruct.queryParseValueVars=true;
		selectStruct.queryValueField = "##inquiries_type_id##|##inquiries_type_id_siteIDType##";
		application.zcore.functions.zInputSelectBox(selectStruct);
	}
	arrayAppend(rs.searchFields, {
		groupStyle:'width:300px; max-width:100%; ',
		fields:[{
			label:"Keyword",
			formField:'<input type="search" name="inquiries_search" style="min-width:200px; width:200px;" id="inquiries_search" value="#htmleditformat(application.zcore.functions.zso(form, 'inquiries_search'))#"> ',
			field:"inquiries_search",
			labelStyle:'width:80px;',
			fieldStyle:'width:200px;'
		},{
			label:"Name",
			formField:'<input type="search" name="inquiries_name" style="min-width:200px; width:200px;" id="inquiries_name" value="#htmleditformat(application.zcore.functions.zso(form, 'inquiries_name'))#"> ',
			field:"inquiries_first_name",
			labelStyle:'width:80px;',
			fieldStyle:'width:200px;'
		},{
			label:"Email",
			formField:'<input type="text" name="search_email" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_email')#" /> ',
			field:"search_email",
			labelStyle:'width:80px;',
			fieldStyle:'width:200px;'
		},{
			label:"Phone",
			formField:'<input type="text" name="search_phone" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_phone')#" />',
			field:"search_phone",
			labelStyle:'width:80px;',
			fieldStyle:'width:200px;'
		}]
	});
	arrayAppend(rs.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Start",
			formField:'<input type="date" name="inquiries_start_date" value="#dateformat(form.inquiries_start_date, 'yyyy-mm-dd')#">',
			field:"inquiries_start_date",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"End",
			formField:'<input type="date" name="inquiries_end_date" value="#dateformat(form.inquiries_end_date, 'yyyy-mm-dd')#">',
			field:"inquiries_end_date",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		}]
	});
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListRow" localmode="modern" access="private">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="columns" type="array" required="yes">
	<cfscript>
	row=arguments.row;

	columns=arguments.columns; 
	savecontent variable="field"{
		echo('<a href="#variables.prefixURL#userView/?inquiries_id=#row.inquiries_id#&amp;zPageId=#form.zPageId#">#row.inquiries_first_name# #row.inquiries_last_name#</a>');
	}
	arrayAppend(columns, {field: field});
 
	arrayAppend(columns, {field: row.inquiries_phone1});  
	arrayAppend(columns, {field: DateFormat(row.inquiries_datetime, "m/d/yy")&" "&TimeFormat(row.inquiries_datetime, "h:mm tt")}); 
	arrayAppend(columns, {field: DateFormat(row.inquiries_updated_datetime, "m/d/yy")&" "&TimeFormat(row.inquiries_updated_datetime, "h:mm tt")}); 

	savecontent variable="field"{
		echo(variables.statusName[row.inquiries_status_id]);
		if(row.inquiries_spam EQ 1){
			echo(', <strong>Marked as Spam</strong>');
		}
	}
	arrayAppend(columns, {field: field});  
	savecontent variable="field"{
		if(structkeyexists(variables.typeNameLookup, row.inquiries_type_id&"|"&row.inquiries_type_id_siteIdType)){
			echo(variables.typeNameLookup[row.inquiries_type_id&"|"&row.inquiries_type_id_siteIdType]);
		}else{
			echo(row.inquiries_type_other);
		}
		if(trim(row.inquiries_phone_time) NEQ ''){
			echo(' / <strong>Forced</strong>');
		}
	}
	arrayAppend(columns, {field: field}); 
	adminButtons=[];
	arrayAppend(adminButtons, {
		title:"View",
		icon:"eye",
		link:'#variables.prefixURL#userView?inquiries_id=#row.inquiries_id#&amp;zPageId=#form.zPageId#',
		label:""
	}); 
	savecontent variable="field"{
		ts={
			buttons:adminButtons
		}; 
		displayAdminMenu(ts);

	}
	arrayAppend(columns, {field: field, class:"z-manager-admin", style:"width:60px; max-width:100%;"});
	</cfscript> 
</cffunction>

<cffunction name="userInquiryTokenSearch" localmode="modern" access="remote" roles="user">
	<cfscript>
	inquiryTokenSearch();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
