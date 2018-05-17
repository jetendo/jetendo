<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	hCom=0;
	form.returnJSON=application.zcore.functions.zso(form, 'returnJSON', true, 0);

	variables.inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");

	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	if(form.method EQ "userView" or form.method EQ "userViewContact"){

	}else{
	    application.zcore.adminSecurityFilter.requireFeatureAccess("Leads");

	    if(form.method EQ "viewContact"){
		}else{
			if(structkeyexists(form, 'inquiries_id') EQ false){
				if(form.returnJSON EQ 1){
					application.zcore.functions.zReturnJson({ success:false, errorMessage:"You don't have access to manage this lead."});
				}else{
					application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index');
				}
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

		inquiriesCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		inquiriesCom.indexInquiry(form.inquiries_id, request.zos.globals.id);
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


<cffunction name="userViewContact" localmode="modern" access="remote" roles="user">
	<cfscript>
	// need to secure the contact_id by checking if user has access to 1 or more inquiries for this contact.
	// already wrote this somewhere else (send-message or manage-inquiries?)

	throw("not implemented yet");
	viewContact();
	</cfscript>
</cffunction>

<!--- 
http://www.montereyboats.com.127.0.0.2.nip.io/z/inquiries/admin/feedback/viewContact?contact_id=15
 --->
<cffunction name="viewContact" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject; 
	currentMethod=form.method;
	variables.init();
	// need to validate based on contact_id instead of inquiries_id,  init is disabled for now.
	//variables.init();

	application.zcore.skin.includeCSS("/z/font-awesome/css/font-awesome.min.css");
	form.inquiries_id=application.zcore.functions.zso(form, 'inquiries_id', true, 0);
	form.contact_id=application.zcore.functions.zso(form, 'contact_id', true, 0);
	form.contactTab=application.zcore.functions.zso(form, 'contactTab', true, 1); 
	contactCom=createobject("component", "zcorerootmapping.com.app.contact");
	contact = contactCom.getContactById(form.contact_id, request.zos.globals.id);
	if(structcount(contact) EQ 0){
		application.zcore.status.setStatus(request.zsid, "Contact doesn't exist.", form, true);
		if(request.zos.isTestServer){
			throw("contact missing - remove this when done");
		}
		application.zcore.functions.zRedirect("/z/inquiries/admin/manage-contact/index?zsid=#request.zsid#");
	} 
	contactName="";
	if(contact.contact_first_name EQ ""){
		if(contact.contact_email EQ ""){
			if(contact.contact_phone1 EQ ""){
				contactName="Contact ##"&contact.contact_id;
			}else{
				contactName=contact.contact_phone1;
			}
		}else{
			contactName=contact.contact_email;
		}
	}else{
		contactName=contact.contact_first_name&" "&contact.contact_last_name;
	}
	</cfscript>   
	<div class="z-float z-mb-10">
		<h3><a href="/z/inquiries/admin/manage-contact/index">Contacts</a> /  #contactName#</h3>
	</div>
	<div class="z-float z-manager-lead-tab-buttons">
		<ul>
			<li><a href="/z/inquiries/admin/feedback/#currentMethod#?contactTab=1&amp;contact_id=#form.contact_id#" class=" <cfif form.contactTab EQ 1>active</cfif>"><i class="fa fa-address-card" aria-hidden="true"></i> Contact</a></li>
			<li><a href="/z/inquiries/admin/feedback/#currentMethod#?contactTab=2&amp;contact_id=#form.contact_id#" class="<cfif form.contactTab EQ 2>active</cfif>"><i class="fa fa-list" aria-hidden="true"></i> Leads</a></li>
			<cfif form.inquiries_id NEQ 0>
				<li><div class="z-manager-lead-unclickable-button <cfif form.contactTab EQ 4>active</cfif>"><i class="fa fa-envelope-open" aria-hidden="true"></i> <div style="float:left;">Lead ###form.inquiries_id#</div> 
						<a href="/z/inquiries/admin/feedback/#currentMethod#?contactTab=2&amp;contact_id=#form.contact_id#" class="z-manager-lead-close-button"><i class="fa fa-times" aria-hidden="true" style="margin-right:0px;"></i></a>
					</div></li>
			</cfif>

			<cfif request.zos.isTestServer and contact.contact_email NEQ "">
				<cfif currentMethod EQ "userViewContact"> 
					<li><a href="/z/inquiries/admin/send-message/userIndex?contact_id=#contact.contact_id#"  onclick="zShowModalStandard(this.href, 4000, 4000, true, true); return false;" title="Compose" style=" text-decoration:none;"><i class="fa fa-pencil-square" aria-hidden="true" style="padding-right:5px;"></i><span>Compose</span></a></li>
				<cfelse>
					<li><a href="/z/inquiries/admin/send-message/index?contact_id=#contact.contact_id#" onclick="zShowModalStandard(this.href, 4000, 4000, true, true); return false;" title="Compose" style=" text-decoration:none;"><i class="fa fa-pencil-square" aria-hidden="true" style="padding-right:5px;"></i><span>Compose</span></a></li>
				</cfif>
			</cfif>
			<cfif request.zos.isTestServer and form.method EQ "#currentMethod#">
				<li><a href="/z/inquiries/admin/feedback/#currentMethod#?contactTab=3&amp;contact_id=#form.contact_id#" class="<cfif form.contactTab EQ 3>active</cfif>"><i class="fa fa-globe" aria-hidden="true"></i> Site Usage</a></li>
			</cfif>
		</ul>
	</div>
	<style type="text/css"> 
	.z-contact-container{ width:100%; display:table; border-spacing:0px;}
	.z-contact-row{width:100%; display:table-row;}
	.z-contact-label{ font-weight:bold; display:table-cell; padding-bottom:5px; width:15%;  white-space:nowrap;}
	.z-contact-value{ display:table-cell; padding-bottom:5px; float:left; }
	
	.z-manager-lead-tab-buttons ul{list-style:none;padding-left:0px;}
	.z-manager-lead-tab-buttons i{ float:left;}
	.z-manager-lead-unclickable-button i, .z-manager-lead-tab-buttons i{ margin-right:7px; margin-top:2px;}
	.z-manager-lead-unclickable-button, .z-manager-lead-tab-buttons ul li > a:link, .z-manager-lead-tab-buttons ul li > a:visited{ display:block; float:left; text-decoration:none; font-size:16px; padding:7px; background-color:##E2E2E2; color:##000; margin-right:5px; border-top-left-radius:5px; border-top-right-radius:5px;}
	.z-manager-lead-tab-buttons ul li{ padding:0px; padding-top:3px; float:left; display:block;}
	.z-manager-lead-tab-buttons ul li > a:hover{background-color:##FFF;}
	.z-manager-lead-tab-buttons div.active,	.z-manager-lead-tab-buttons ul li > a.active:link, .z-manager-lead-tab-buttons ul li > a.active:visited{
		background-color:##FFF !important;
	}
	.z-manager-lead-close-button{ display:block; float:right; color:##000; padding:5px !important; font-size:14px; line-height:14px; margin-top:-3px; margin-left:5px; margin-bottom:-5px; border-radius:30px !important;}
	.z-manager-lead-close-button:hover{ background-color:##CCC !important; color:##000 !important;}
	.z-manager-lead-tab{ background-color:##FFF; padding:10px; }
	@media only screen and (max-width: 992px) {   
	}
	@media only screen and (max-width: 767px) {   
	}
	@media only screen and (max-width: 479px) {   
	}
	</style>
	<cfif form.contactTab EQ 1>
		<div class="z-float z-contact-tab1 z-manager-lead-tab"> 
			<div class="z-float">
				<!--- allow editing a contact from here, and refresh the page here instead of manage-contact --->
				<h3 style="display:inline-block;">Contact</h3> &nbsp;&nbsp;
				<a href="/z/inquiries/admin/manage-contact/edit?contact_id=#form.contact_id#&modalpopforced=1&editSource=contact" onclick="zShowModalStandard(this.href, 4000, 4000, true, true); return false;" class="z-button z-contact-edit-button">Edit</a>
				TODO: Assign button?
			</div>
			<cfscript> 
			displayContact(contact);
			</cfscript> 
		</div>
	<cfelseif form.contactTab EQ 2>

		<div class="z-float z-contact-tab2 z-manager-lead-tab"> 
			<div class="z-float">
				<h3>Leads</h3>
			</div>
			<div class="z-float z-contact-container">
				<cfscript>
				ts={
					arrExcludeInquiriesId:[],
					contact_id:application.zcore.functions.zso(form, 'contact_id', true, 0), 
					inquiries_email:contact.contact_email, 
					inquiries_phone1:contact.contact_phone1,
					mode:"member"
				}; 
				if(currentMethod EQ "userViewContact"){
					ts.mode="user";
				}
				displayContactLeads(ts);
				</cfscript>
			</div>
		</div>
	<cfelseif form.contactTab EQ 3>		
		<div class="z-float z-contact-tab3 z-manager-lead-tab"> 
			<div class="z-float">
				<h3>Site Usage</h3>
			</div>
			<div class="z-float z-contact-container"> 
				<!--- user data like saved searches / site searches / first page / partial form data /  --->
				<cfscript>
				if(application.zcore.app.siteHasApp("listing")){
					echo('<h2>Saved Listing Searches</h2>');
					// TODO: pull from existing lead detail?
				}
				</cfscript> 
			</div>
		</div> 
	<cfelseif form.contactTab EQ 4>		
		<div class="z-float z-contact-tab3 z-manager-lead-tab"> 
			<div class="z-float">
				<div class="z-3of4 z-p-0">
					<cfscript> 
					variables.inquiriesCom.view(); 
			        </cfscript> 

					<cfscript>
					ts={
						inquiries_id:form.inquiries_id
					};
					displayLeadFeedback(ts);
					</cfscript>
			    </div>
			    <div class="z-1of4 z-p-0">
					<cfscript> 
					// display list of contacts attached to this lead. 
			 
					db.sql = 'SELECT inquiries_x_contact.inquiries_x_contact_type, contact.contact_id, contact.contact_email, contact.contact_first_name, contact.contact_last_name
						FROM (#db.table( 'inquiries_x_contact', request.zos.zcoreDatasource )#,
							#db.table( 'contact', request.zos.zcoreDatasource )#)
						WHERE inquiries_x_contact.site_id = #db.param( request.zos.globals.id )#
							AND inquiries_x_contact.inquiries_x_contact_deleted = #db.param( 0 )#
							AND contact.contact_id = inquiries_x_contact.contact_id
							AND inquiries_x_contact.inquiries_id=#db.param(form.inquiries_id)# 
							AND contact.site_id = inquiries_x_contact.site_id
							AND contact.contact_deleted = #db.param( 0 )#
						ORDER BY contact.contact_email ASC';
					qContact = db.execute( 'qContact' );

					toArray = [];
					ccArray = [];
					bccArray=[];

					isSubscribed=false;
					if ( qContact.recordcount GT 0 ) {
						for ( row in qContact ) {
							if(row.contact_id EQ request.zsession.user.contact_id){
								isSubscribed=true;
								continue;
							}
							if ( row.inquiries_x_contact_type EQ 'to' ) {
								arrayAppend( toArray, row );
							} else if ( row.inquiries_x_contact_type EQ 'cc' ) {
								arrayAppend( ccArray, row );
							} else if ( row.inquiries_x_contact_type EQ 'bcc' ) {
								arrayAppend( bccArray, row );
							}
						}
					} 
					echo('<h3>Notification List</h3>');
					echo('<p>These people will receive email alerts when this lead is updated.</p>');
					echo('<div class="z-float">');
						echo('<div class="leadSubscribeLinkContainer">');
							if(form.method EQ "viewContact"){
								unsubscribeLink="/z/inquiries/admin/manage-inquiries/unsubscribeToLead?inquiries_id=#form.inquiries_id#";
								subscribeLink="/z/inquiries/admin/manage-inquiries/subscribeToLead?inquiries_id=#form.inquiries_id#";
							}else{
								unsubscribeLink="/z/inquiries/admin/manage-inquiries/userUnsubscribeToLead?inquiries_id=#form.inquiries_id#"; 
								subscribeLink="/z/inquiries/admin/manage-inquiries/userSubscribeToLead?inquiries_id=#form.inquiries_id#";
							}
							if(isSubscribed){
								echo('<p>Me <a href="##" data-subscribe-link="#subscribeLink#" data-unsubscribe-link="#unsubscribeLink#" class="leadUnsubscribeLink z-manager-search-button">Unsubscribe</a></p>');
							}else{	
								echo('<p>You are not subscribed to this message yet.</p>'); 
								echo('<p><a href="##" data-subscribe-link="#subscribeLink#" data-unsubscribe-link="#unsubscribeLink#" class="leadSubscribeLink z-manager-search-button">Subscribe</a></p>');
							}
						echo('</div>');
						echo('<table class="table-list" style="width:100%;">');
						if(arraylen(toArray)){
							echo('<tr><th colspan="2">To:</th></tr>');
							for(row in toArray){
								displayContactNotifyButton(row);
							}
						}
						if(arraylen(ccArray)){
							echo('<tr><th colspan="2">Cc:</th></tr>');
							for(row in ccArray){
								displayContactNotifyButton(row);
							}
						}
						if(arraylen(bccArray)){
							echo('<tr><th colspan="2">Bcc:</th></tr>');
							for(row in bccArray){
								displayContactNotifyButton(row);
							}
						}
						echo('</table>');
					echo('</div>'); 
					</cfscript>
				</div>
			</div>
		</div>


	<script type="text/javascript">
	zArrDeferredFunctions.push( function() {   
		function setSubscribeHTML(self, r){
			var r=JSON.parse(r);
			if(r.success){
				var arrHTML=[];
				var unsubscribeLink=$(self).attr("data-unsubscribe-link");
				var subscribeLink=$(self).attr("data-subscribe-link");
				if(r.subscribed){
					arrHTML.push('<p>Me <a href="##" data-unsubscribe-link="'+unsubscribeLink+'" data-subscribe-link="'+subscribeLink+'" class="leadUnsubscribeLink z-manager-search-button">Unsubscribe</a></p>');
				}else{	
					arrHTML.push('<p>You are not subscribed to this message yet.</p>');
					arrHTML.push('<p><a href="##" data-unsubscribe-link="'+unsubscribeLink+'" data-subscribe-link="'+subscribeLink+'" class="leadSubscribeLink z-manager-search-button">Subscribe</a></p>');
				}
				$(".leadSubscribeLinkContainer").html(arrHTML.join(""));
			}else{
				alert(r.errorMessage);
			}
		}
		$(document).on("click", ".leadSubscribeLink", function(e){ 
			e.preventDefault();
			var tempObj={};
			tempObj.id="zLeadSubscribe";
			var self=this;
			tempObj.url=$(self).attr("data-subscribe-link");
			console.log(tempObj);
			tempObj.callback=function(r){
				setSubscribeHTML(self, r);
			};
			tempObj.cache=false;
			zAjax(tempObj); 
		});
		$(document).on("click", ".leadUnsubscribeLink", function(e){ 
			e.preventDefault();
			var tempObj={};
			tempObj.id="zLeadUnsubscribe";
			var self=this;
			tempObj.url=$(self).attr("data-unsubscribe-link");
			tempObj.callback=function(r){
				setSubscribeHTML(self, r);
			};
			tempObj.cache=false;
			zAjax(tempObj); 
		});
		$(document).on("click", ".leadUnsubscribeOtherLink", function(e){ 
			e.preventDefault();
			var containerId=$(this).attr("data-container-id");
			var tempObj={};
			tempObj.id="zLeadUnsubscribe";
			tempObj.url=this.href;
			var self=this;
			tempObj.callback=function(r){
				var r=JSON.parse(r);
				if(r.success){ 
					$("."+containerId).remove();
				}else{
					alert(r.errorMessage);
				}
			};
			tempObj.cache=false;
			zAjax(tempObj); 
		});
		
	});
	</script>
	</cfif> 
</cffunction>


<cffunction name="displayContactNotifyButton" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	if(form.method EQ "viewContact"){
		currentMethod="unsubscribeToLead";
	}else{
		currentMethod="userUnsubscribeToLead";
	}
	echo('<tr class="z-float leadUnsubscribeOtherLink#ss.contact_id#" style="margin-bottom:5px;">
		<th>
		#ss.contact_email#</th><td style="width:1%; white-space:nowrap;">
		');
	if(application.zcore.user.checkGroupAccess("administrator")){
		echo('<a href="/z/inquiries/admin/manage-inquiries/#currentMethod#?inquiries_id=#form.inquiries_id#&amp;contact_id=#ss.contact_id#" class="leadUnsubscribeOtherLink z-manager-lead-close-button" data-container-id="leadUnsubscribeOtherLink#ss.contact_id#" title="Click to remove this person from the lead."><i class="fa fa-times" aria-hidden="true"></i></a>');
	}
	echo('</td></tr>');
	</cfscript> 
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
	    db.sql&=variables.inquiriesCom.getUserLeadFilterSQL(db);
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
 
	</cfscript>

	<div class="z-float">
		<div class="z-3of5 z-ph-0"> 
			<cfscript> 
			hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
			hCom.view();  
			</cfscript>
		</div>
		<div class="z-2of5 z-ph-0"> 
			<div style="" class="z-inquiry-note-box">
				<cfscript>
				ts={};
				variables.inquiriesCom.displayAddNoteForm(ts);
				</cfscript>
			</div>
		</div> 
	</div> 
	<cfscript>
	ts={
		inquiries_id:form.inquiries_id
	};
	displayLeadFeedback(ts);
	</cfscript>

	<h2>Other inquiries from this contact</h2>
	<cfscript>
	ts={
		arrExcludeInquiriesId:[form.inquiries_id],
		contact_id:application.zcore.functions.zso(form, 'contact_id', true, 0), 
		inquiries_email:form.inquiries_email, 
		inquiries_phone1:form.inquiries_phone1,
		mode:"member"
	}; 
	if(form.method EQ "userView"){
		ts.mode="user";
	}
	displayContactLeads(ts);
	</cfscript>
</cffunction>
 
<cffunction name="displayContact" localmode="modern" access="public">
	<cfargument name="contact" type="struct" required="yes">
	<cfscript>
	contact=arguments.contact;
	db=request.zos.queryObject;
	</cfscript>

	<table style="width: 100%; border-spacing: 0px;" class="table-list"> 
		<cfif contact.office_id NEQ 0 and contact.office_id NEQ "">
			<cfscript> 
			db.sql="Select * from #db.table("office", request.zos.zcoreDatasource)# WHERE 
			office_id = #db.param(contact.office_id)# and 
			site_id=#db.param(contact.site_id)# and 
			office_deleted=#db.param(0)# ";
			qOffice=db.execute("qOffice");
			</cfscript>
			<tr>
				<th>Assigned Office</th>
				<td><cfif qOffice.recordcount>#qOffice.office_name#<cfelse>(Office deleted)</cfif></td>
			</tr>
		</cfif>
		<cfif contact.contact_company NEQ "">
			<tr>
				<th>Company</th>
				<td>#contact.contact_company#</td>
			</tr>
		</cfif>
		<tr>
			<th style="width: 140px;">Name</th>
			<td>
			<cfif contact.contact_salutation NEQ ""> 
				#contact.contact_salutation#
			</cfif>
			<cfif contact.contact_first_name NEQ ""> 
				#contact.contact_first_name#
			</cfif>
			<cfif contact.contact_last_name NEQ "">
				#contact.contact_last_name#
			</cfif>
			<cfif contact.contact_suffix NEQ "">
				#contact.contact_suffix#
			</cfif>
			</td>
		</tr>
		<cfif contact.contact_email NEQ "">
			<tr>
				<th>Email</th>
				<td><a href="mailto:#contact.contact_email#">#contact.contact_email#</a></td>
			</tr>
		</cfif>
		<cfif contact.contact_phone1 NEQ "">
			<tr>
				<th>Phone1</th>
				<td>#contact.contact_phone1#</td>
			</tr>
		</cfif>
		<cfif contact.contact_phone2 NEQ "">
			<tr>
				<th>Phone2</th>
				<td>#contact.contact_phone2#</td>
			</tr>
		</cfif>
		<cfif contact.contact_phone3 NEQ "">
			<tr>
				<th>Phone3</th>
				<td>#contact.contact_phone3#</td>
			</tr>
		</cfif>
		<cfif contact.contact_job_title NEQ "">
			<tr>
				<th>Job Title</th>
				<td>#contact.contact_job_title#</td>
			</tr>
		</cfif>
		<cfif contact.contact_address NEQ "">
			<tr>
				<th>Address</th>
				<td>#contact.contact_address#</td>
			</tr>
		</cfif>
		<cfif contact.contact_city NEQ "">
			<tr>
				<th>City</th>
				<td>#contact.contact_city#</td>
			</tr>
		</cfif>
		<cfif contact.contact_state NEQ "">
			<tr>
				<th>State</th>
				<td>#contact.contact_state#</td>
			</tr>
		</cfif>
		<cfif contact.contact_country NEQ "">
			<tr>
				<th>Country</th>
				<td>#contact.contact_country#</td>
			</tr>
		</cfif>
		<cfif contact.contact_postal_code NEQ "">
			<tr>
				<th>Postal Code</th>
				<td>#contact.contact_postal_code#</td>
			</tr>
		</cfif>
		<cfif contact.contact_birthday NEQ "">
			<tr>
				<th>Birthday</th>
				<td>#contact.contact_birthday#</td>
			</tr>
		</cfif>
		<cfif contact.contact_spouse_first_name NEQ "">
			<tr>
				<th>Spouse First Name</th>
				<td>#contact.contact_spouse_first_name#</td>
			</tr>
		</cfif>
		<cfif contact.contact_spouse_suffix NEQ "">
			<tr>
				<th>Spouse Suffix</th>
				<td>#contact.contact_spouse_suffix#</td>
			</tr>
		</cfif>
		<cfif contact.contact_spouse_job_title NEQ "">
			<tr>
				<th>Spouse Job Title</th>
				<td>#contact.contact_spouse_job_title#</td>
			</tr>
		</cfif>
		<cfsavecontent variable="interests">
			<cfif contact.contact_interests NEQ "">
				<tr>
					<th>Interests</th>
					<td>#contact.contact_interests#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_type NEQ "">
				<tr>
					<th>Interested in Type</th>
					<td>#contact.contact_interested_in_type#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_year NEQ "">
				<tr>
					<th>Interested in Year</th>
					<td>#contact.contact_interested_in_year#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_make NEQ "">
				<tr>
					<th>Interested in Make</th>
					<td>#contact.contact_interested_in_make#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_model NEQ "">
				<tr>
					<th>Interested in Model</th>
					<td>#contact.contact_interested_in_model#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_category NEQ "">
				<tr>
					<th>Interested in Category</th>
					<td>#contact.contact_interested_in_category#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_name NEQ "">
				<tr>
					<th>Interested in Name</th>
					<td>#contact.contact_interested_in_name#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_hin_vin NEQ "">
				<tr>
					<th>Interested in HIN VIN</th>
					<td>#contact.contact_interested_in_hin_vin#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_stock NEQ "">
				<tr>
					<th>Interested in Stock</th>
					<td>#contact.contact_interested_in_stock#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_length NEQ "">
				<tr>
					<th>Interested in Length</th>
					<td>#contact.contact_interested_in_length#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_currently_owned_type NEQ "">
				<tr>
					<th>Interested in Currently Owned Type</th>
					<td>#contact.contact_interested_in_currently_owned_type#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_read NEQ "">
				<tr>
					<th>Interested in Read</th>
					<td>#contact.contact_interested_in_read#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_age NEQ "">
				<tr>
					<th>Interested in Age</th>
					<td>#contact.contact_interested_in_age#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_bounce_reason NEQ "">
				<tr>
					<th>Interested in Bounce Reason</th>
					<td>#contact.contact_interested_in_bounce_reason#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_home_phone NEQ "">
				<tr>
					<th>Interested in Home Phone</th>
					<td>#contact.contact_interested_in_home_phone#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_work_phone NEQ "">
				<tr>
					<th>Interested in Work Phone</th>
					<td>#contact.contact_interested_in_work_phone#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_mobile_phone NEQ "">
				<tr>
					<th>Interested in Mobile Phone</th>
					<td>#contact.contact_interested_in_mobile_phone#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_fax NEQ "">
				<tr>
					<th>Interested in Fax</th>
					<td>#contact.contact_interested_in_fax#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_buying_horizon NEQ "">
				<tr>
					<th>Interested in Buying Horizon</th>
					<td>#contact.contact_interested_in_buying_horizon#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_status NEQ "">
				<tr>
					<th>Interested in Status</th>
					<td>#contact.contact_interested_in_status#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_interest_level NEQ "">
				<tr>
					<th>Interested in Interest Level</th>
					<td>#contact.contact_interested_in_interest_level#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_sales_stage NEQ "">
				<tr>
					<th>Interested in Sales Stage</th>
					<td>#contact.contact_interested_in_sales_stage#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_contact_source NEQ "">
				<tr>
					<th>Interested in Contact Source</th>
					<td>#contact.contact_interested_in_contact_source#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_dealership NEQ "">
				<tr>
					<th>Interested in Dealership</th>
					<td>#contact.contact_interested_in_dealership#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_assigned_to NEQ "">
				<tr>
					<th>Interested in Assigned To</th>
					<td>#contact.contact_interested_in_assigned_to#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_bounced_email EQ "1">
				<tr>
					<th>Bounced Email</th>
					<td>Yes</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_owners_magazine EQ "1">
				<tr>
					<th>Interested in Owners Magazine</th>
					<td>Yes</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_purchased EQ "1">
				<tr>
					<th>Interested in Purchased</th>
					<td>Yes</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_service_date NEQ "">
				<tr>
					<th>Interested in Service Date</th>
					<td>#contact.contact_interested_in_service_date#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_date_delivered NEQ "">
				<tr>
					<th>Interested in Date Delivered</th>
					<td>#contact.contact_interested_in_date_delivered#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_date_sold NEQ "">
				<tr>
					<th>Interested in Date Sold</th>
					<td>#contact.contact_interested_in_date_sold#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_warranty_date NEQ "">
				<tr>
					<th>Interested in Warranty Date</th>
					<td>#contact.contact_interested_in_warranty_date#</td>
				</tr>
			</cfif>
			<cfif contact.contact_interested_in_lead_comments NEQ "">
				<tr>
					<th>Interested in Lead Comments</th>
					<td>#contact.contact_interested_in_lead_comments#</td>
				</tr> 
			</cfif>
		</cfsavecontent>
		<cfif trim(interests) NEQ "">
			<tr>
				<th><h2>Interested In</h2>
				</th>
			</tr>
			#interests#
		</cfif>
		<cfif contact.contact_datetime NEQ "">
			<tr>
				<th>Date Created</th>
				<td>#dateformat(contact.contact_datetime, "m/d/yyyy")&" "&timeformat(contact.contact_datetime, "h:mm tt")#</td>
			</tr>
		</cfif> 
	</table>
</cffunction>


<!--- 
ts={
	// required
	inquiries_id:form.inquiries_id,
	//optional
	site_id:request.zos.globals.id,
	disableReadTracking:false,
	disablePrivateMessages:false
};
feedbackCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.feedback");
feedbackCom.displayLeadFeedback(ts);
 --->
<cffunction name="displayLeadFeedback" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	ts={
		site_id:request.zos.globals.id,
		disableReadTracking:false,
		disablePrivateMessages:false
	};
	ss=arguments.ss;
	structappend(ss, ts, false);
	</cfscript>
	<cfscript>  
	db.sql="SELECT inquiries_feedback.*, user.* ";

	if(not ss.disableReadTracking){
		db.sql&=" , 
		if(inquiries_feedback_x_user.inquiries_feedback_x_user_id IS NULL, #db.param(0)#, #db.param(1)#) isRead ";
	}else{
		db.sql&=", #db.param(1)# isRead ";
	}
	db.sql&=" from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# ON 
	user.user_id = inquiries_feedback.user_id and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_feedback.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)# ";
	if(not ss.disableReadTracking){
		db.sql&=" LEFT JOIN #db.table("inquiries_feedback_x_user", request.zos.zcoreDatasource)# ON 
		inquiries_feedback_x_user.inquiries_feedback_id = inquiries_feedback.inquiries_feedback_id and 
		inquiries_feedback_x_user.site_id = inquiries_feedback.site_id and 
		inquiries_feedback_x_user.user_id=#db.param(request.zsession.user.id)# and 
		inquiries_feedback_x_user.user_id_siteidtype=#db.param(application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id))# and 
		inquiries_feedback_x_user.inquiries_feedback_x_user_deleted=#db.param(0)# ";
	}
	db.sql&=" WHERE 
	inquiries_id = #db.param(ss.inquiries_id)# and 
	inquiries_feedback.site_id = #db.param(ss.site_id)# and 
	inquiries_feedback_deleted=#db.param(0)# ";
	if(ss.disablePrivateMessages){
		db.sql&=" and inquiries_feedback_type=#db.param(1)# ";
	}
	db.sql&=" ORDER BY inquiries_feedback_datetime DESC ";
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
.z-feedback-message{width:100%; padding:5px; background-color:##FFF; border-bottom-right-radius:5px; border-bottom-left-radius:5px; float:left;}
.z-feedback-private-container{width:100%; float:left; border-radius:8px; background-color:##fbf3de;}
.z-feedback-private-header{width:100%; float:left;border-top-left-radius:5px;border-top-right-radius:5px; background-color:##f7df9e; border-bottom:1px solid ##e3c473; padding:5px; font-weight:bold; color:##b68500; font-size:12px; line-height:15px;}
.z-feedback-private-container .z-feedback-header{ border-top-left-radius:0px;border-top-right-radius:0px; background-color:##f7df9e;}
.z-feedback-private-container .z-feedback-date{ color:##b68500;}
.z-feedback-show-all{padding:5px; padding-top:20px; padding-bottom:20px; font-size:18px; text-decoration:none; border-top:1px solid ##CCC; border-bottom:1px solid ##CCC; text-align:center; width:100%; float:left;}

.z-feedback-old .z-feedback-message{display:none;}
.z-feedback-old .z-feedback-attachments{display:none;}
.z-feedback-show-message .z-feedback-attachments{display:block !important;}
.z-feedback-show-message .z-feedback-message{display:block !important; background-color:##FFF;border-bottom-left-radius:5px; border-bottom-right-radius:5px; }
.z-feedback-show-message-button{ display:block; float:left; text-decoration:none; color:##369; background-color:##FFF; border-bottom-left-radius:5px; border-bottom-right-radius:5px; width:100%; padding:5px; }
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
		$(".z-feedback-show-message-button").remove();
		$(this).hide();
		resizeFrames();
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
		resizeFrames();
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
		<h3>Messages</h3>
		<cfscript>  
		showAllDisplayed=0;
		readCount=0;
		rowCount=0;
		for(row in qFeedback){
			rowCount++;
			echo('<div id="inquiriesFeedbackMessageId#row.inquiries_feedback_id#" class="z-feedback-container ');
			
			if(row.isRead EQ 1 and row.inquiries_feedback_id NEQ qFeedback.inquiries_feedback_id[1]){  
				echo(' z-feedback-old ');
				readCount++;
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
			if(row.isRead EQ 1 and showAllDisplayed EQ 0){
				showAllDisplayed=rowCount;
				if(qFeedBack.recordcount GT 1 and qFeedback.recordcount NEQ readCount){
					echo('<div class="z-float z-mb-10 "><a href="##" class="z-manager-search-button z-feedback-show-all-button">Show All Older Messages</a></div>');
				}
			}

			if(not ss.disableReadTracking){
				if(row.isRead EQ 0){
					ts={
						table:"inquiries_feedback_x_user",
						datasource:request.zos.zcoreDatasource,
						struct:{
							user_id:request.zsession.user.id,
							user_id_siteidtype:application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id),
							inquiries_feedback_id:row.inquiries_feedback_id,
							inquiries_feedback_x_user_read:1,
							site_id:ss.site_id,
							inquiries_feedback_x_user_updated_datetime:request.zos.mysqlnow,
							inquiries_feedback_x_user_deleted:0
						}
					};
					application.zcore.functions.zInsert(ts);  
				} 
			}
		}
		if(qFeedBack.recordcount GT 1 and qFeedback.recordcount NEQ readCount and showAllDisplayed NEQ qFeedBack.recordcount){
			echo('<div class="z-float z-mb-10 "><a href="##" class="z-manager-search-button z-feedback-show-all-button">Show All Older Messages</a></div>');
		} 
		</cfscript>
		


		<script type="text/javascript">
			var theFrames;

			function resizeFrames() {
				for ( var i = 0, j = theFrames.length; i < j; i++ ) {
					theFrames[ i ].style.height = '120px';
					theFrames[ i ].style.height = ( theFrames[ i ].contentWindow.document.body.offsetHeight ) + 'px'; /// + 16 
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
						this.style.height = ( this.contentWindow.document.body.offsetHeight  ) + 'px'; // + 16
					} );
				}

				resizeFrames();

				$( window ).resize( function() {
					resizeFrames();
				} );
			} );
		</script>


	</cfif>
</cffunction>

<cffunction name="displayContactLeads" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject; 
	ss=arguments.ss;

	lookupData=variables.inquiriesCom.loadListLookupData();
	ss.mode=application.zcore.functions.zso(ss, 'mode', false, 'member');
	</cfscript>
	<cfif ss.contact_id NEQ 0 or ss.inquiries_email NEQ "" or ss.inquiries_phone1 NEQ "">
		<cfscript>
		db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)#  
		LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
		user.user_id = inquiries.user_id and 
		user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
		user_deleted = #db.param(0)#
		WHERE (";
			hasOne=false;
			if(ss.contact_id NEQ 0){
				hasOne=true;
				db.sql&=" inquiries.contact_id = #db.param(ss.contact_id)# ";
			}
			if(ss.inquiries_email NEQ ""){
				if(hasOne){
					db.sql&=" or ";
				}
				hasOne=true;
				db.sql&=" inquiries_email = #db.param(ss.inquiries_email)# ";
			}
			if(ss.inquiries_phone1 NEQ ""){
				if(hasOne){
					db.sql&=" or ";
				}
				hasOne=true;
				db.sql&=" inquiries_phone1 = #db.param(ss.inquiries_phone1)# ";
			}
			db.sql&=" ) and 
		inquiries_deleted = #db.param(0)# and 
		inquiries.site_id = #db.param(request.zos.globals.id)# ";
		if(arrayLen(ss.arrExcludeInquiriesId)){
			for(id in ss.arrExcludeInquiriesId){
				db.sql&=" and inquiries_id <> #db.param(id)# ";
			}
		}
		if(ss.mode EQ "user"){
	    	db.sql&=variables.inquiriesCom.getUserLeadFilterSQL(db);
		}else if(not application.zcore.user.checkGroupAccess("administrator")){
			db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
			inquiries.user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
		}
		db.sql&=" ORDER BY inquiries_id DESC ";
		qOther=db.execute("qOther");
 
		</cfscript>
		<div style="width:100%; float:left; padding:5px;">
			<cfif qOther.recordcount GTE 2>
				<table class="table-list z-radius-5" style="border-spacing:0px; width:100%; border:1px solid ##CCCCCC;">
					<tr>
						<th>Name</th>
						<th>Phone</th>
						<th>Priority</th>
						<th>Status</th>
						<th>Received</th>
						<th>Last Update</th>
						<th>Type</th>
						<!--- <th class="z-hide-at-767">Comments</th> --->
						<th>Assigned To</th>
						<th>Admin</th>
					</tr>
					<cfloop query="qOther">
						<tr>
							<td>#qOther.inquiries_first_name# #qOther.inquiries_last_name#</td>
							<td>#qOther.inquiries_phone1#</td>
							<td>#qOther.inquiries_priority#</td>
							<td><cfscript>
								echo(lookupData.statusName[qOther.inquiries_status_id]);
								if(qOther.inquiries_spam EQ 1){
									echo(', <strong>Marked as Spam</strong>');
								}
								</cfscript>
							</td>
							<td>#DateFormat(qOther.inquiries_datetime, "m/d/yy")&" "&TimeFormat(qOther.inquiries_datetime, "h:mm tt")#</td>
							<td>#DateFormat(qOther.inquiries_updated_datetime, "m/d/yy")&" "&TimeFormat(qOther.inquiries_updated_datetime, "h:mm tt")#</td>
							<td><cfscript>
								if(structkeyexists(lookupData.typeNameLookup, qOther.inquiries_type_id&"|"&qOther.inquiries_type_id_siteIdType)){
									echo(lookupData.typeNameLookup[qOther.inquiries_type_id&"|"&qOther.inquiries_type_id_siteIdType]);
								}else{
									echo(qOther.inquiries_type_other);
								}
								if(trim(qOther.inquiries_phone_time) NEQ ''){
									echo(' / <strong>Forced</strong>');
								}
								</cfscript>
							</td> 
								<!--- <cfscript>
								cm2=qOther.inquiries_comments;
								cm2=trim(rereplace(cm2,"<[^>]*?>"," ","ALL"));
								if(cm2 NEQ ""){
									writeoutput(left(cm2,350));
									if(len(cm2) GT 350){
										writeoutput("...");
									}
								}
								</cfscript> --->
							<td>
								<cfscript>
								
								if(qOther.inquiries_assign_email NEQ ''){

									arrEmail=listToArray(qOther.inquiries_assign_email, ",");
									for(i=1;i<=arraylen(arrEmail);i++){
										e=arrEmail[i];
										if(i NEQ 1){
											echo(', '); 
										}
										echo('<a href="mailto:#e#">');
										if(qOther.inquiries_assign_name neq '' and arraylen(arrEmail) EQ 1){
											echo(qOther.inquiries_assign_name);
										}else{
											echo(e);
										}
										echo('</a> ');
									}
								}else{
									if(qOther.user_id NEQ 0){
										echo('<a href="mailto:#qOther.user_username#">');
										if(qOther.user_first_name NEQ ""){
											echo('#qOther.user_first_name# #qOther.user_last_name# ');
										}
										if(qOther.member_company NEQ ""){
											echo('(#qOther.member_company#)');
										}
										if(qOther.member_company EQ "" and qOther.user_first_name EQ ""){
											echo(qOther.user_username);
										}
										echo('</a>');
									}
									if(application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1){
										if(structkeyexists(lookupData.officeLookup, qOther.office_id)){
											echo('<br>'&lookupData.officeLookup[qOther.office_id].office_name);
										}
									}
								}
								</cfscript> 
							</td>
							<td>
								<cfscript>
								if(form.method EQ "userViewContact" or form.method EQ "viewContact"){
									if(form.method EQ "userView"){
										echo('<div class="z-manager-button-container"><a href="/z/inquiries/admin/feedback/userViewContact?contactTab=4&amp;zPageId=#form.zPageId#&amp;contact_id=#qOther.contact_id#&amp;inquiries_id=#qOther.inquiries_id#" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a></div>');
									}else{
										echo('<div class="z-manager-button-container"><a href="/z/inquiries/admin/feedback/viewContact?contactTab=4&amp;zPageId=#form.zPageId#&amp;contact_id=#qOther.contact_id#&amp;inquiries_id=#qOther.inquiries_id#" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a></div>');
									}
								}else{
									if(form.method EQ "userView"){
										echo('<div class="z-manager-button-container"><a href="/z/inquiries/admin/manage-inquiries/userView?zPageId=#form.zPageId#&amp;zsid=#request.zsid#&amp;inquiries_id=#qOther.inquiries_id#" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a></div>');
									}else{
										echo('<div class="z-manager-button-container"><a href="/z/inquiries/admin/feedback/view?zPageId=#form.zPageId#&amp;zsid=#request.zsid#&amp;inquiries_id=#qOther.inquiries_id#" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a></div>');
									}
								}
								</cfscript>
							</td>
						</tr> 
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
