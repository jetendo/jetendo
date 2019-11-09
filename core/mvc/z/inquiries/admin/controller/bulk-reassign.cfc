<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	request.inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
	request.inquiriesCom.inquiriesSearchInit();
	</cfscript>
</cffunction>
  
<cffunction name="userAssign" localmode="modern" access="remote">
	<cfscript> 
	inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
	inquiriesCom.userInit();
	assign();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>  
	init();
	var db=request.zos.queryObject;  
	var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	application.zcore.functions.zSetPageHelpId("4.1.2");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Leads"); 
	form.zPageId=application.zcore.functions.zso(form, 'zPageId');

	qs=request.inquiriesCom.getFilterQS();
	application.zcore.functions.zStatusHandler(request.zsid);

	count=getCount();
	if(count EQ 0){
		application.zcore.status.setStatus(request.zsid, "No leads were selected for reassignment", form, true);
		if(form.method EQ "index"){
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/userIndex?zPageId=#form.zPageId#&zsid="&request.zsid);
		}
	}  
	</cfscript>
	<form class="zFormCheckDirty" name="sendEmailForm" id="sendEmailForm" action="/z/inquiries/admin/bulk-reassign/<cfif form.method EQ "index">assign<cfelse>userAssign</cfif>?#qs#" method="post"> 
		<div class="z-float z-p-10 z-bg-white z-index-3" style="visibility:hidden;">
			<button type="submit" name="submitForm" class="z-manager-search-button" style="font-size:150%;">Assign</button>
			<button type="button" name="cancel" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Cancel</button> 
		</div> 
		<div class="z-float z-p-10 z-bg-white z-index-3" >
			<button type="submit" name="submitForm" class="z-manager-search-button" style="font-size:150%;">Assign</button>
			<button type="button" name="cancel" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Cancel</button> 
		</div> 
		<div class="z-manager-edit-errors z-float"></div>
	  	<div class="z-1of2 z-fluid-at-767 z-p-0" style="padding:5px;"> 
		 	<cfscript>
		 	assignCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.assign");
			if(form.method EQ "userAssign"){
				assignCom.getAssignLead("user");
			}else{
				assignCom.getAssignLead("member");
			}
			</cfscript> 
		
 		<div class="z-float">
			<h3 style="color:##369; font-weight:normal;">Private Comments (Optional)</h3>
			<cfif application.zcore.functions.zvar("enablePlusEmailRouting", request.zos.globals.id, 0) EQ 1>
				<p>Only people who can manage this lead will see these comments.</p>
			<cfelse>
				<p>To prevent accidental sharing of private notes with public contacts, these notes will not be visible unless the assigned user logs in to view the lead online.  If you assign the lead to an email instead of a user, they won't be able to see the note at all.</p>
			</cfif> 
			<cfscript>
			htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
			htmlEditor.instanceName	= "inquiries_admin_comments";
			htmlEditor.value			= "";
			htmlEditor.width			= "100%";
			htmlEditor.height		= 150;
			htmlEditor.createSimple();
			</cfscript> 
		</div>
	</div>
	<div class="z-1of2 z-fluid-at-767 z-p-0" style="padding:5px;"> 
		<h2 style="font-weight:normal; color:##369;">Re-Assign #getCount()# Leads</h2>  
  	</div>
	</form>
	
	
	<script>
	zArrDeferredFunctions.push( function() {  
		function emailSentCallback(r){
			window.parent.location.reload();
		}
		$("##sendEmailForm").on("submit", function(e){ 
			var valid3=true;
			if($("##inquiries_subject").val()=="" || $("##inquiries_message").val()==""){
				alert("Subject and message are required.");
				valid3=false;
			}
			if(!valid3){
				return false;
			}
			return true;// zSubmitManagerEditForm(this, emailSentCallback); 
		});
	});
	</script> 
</cffunction>


<cffunction name="userIndex" localmode="modern" access="remote">
	<cfscript> 
	inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
	inquiriesCom.userInit();
	index();
	</cfscript>
</cffunction> 

<cffunction name="assign" localmode="modern" access="remote" roles="member">
	<cfscript> 
	var db=request.zos.queryObject;
	if(form.method EQ "assign"){ 
		application.zcore.adminSecurityFilter.requireFeatureAccess("Leads", true);
	}
	init();
	debug=false;
	form.fromSource=application.zcore.functions.zso(form, 'fromSource');
	form.office_id=application.zcore.functions.zso(form, 'office_id', true);
	form.assign_name=application.zcore.functions.zso(form, 'assign_name'); 
	form.assign_email=application.zcore.functions.zso(form, 'assign_email');

	qs=request.inquiriesCom.getFilterQS();
	if(form.method EQ "assign"){
		errorLink="/z/inquiries/admin/bulk-reassign/index?zsid=#request.zsid#&#qs#";
		returnLink="/z/inquiries/admin/manage-inquiries/index?zsid=#request.zsid#&#qs#";
	}else{
		errorLink="/z/inquiries/admin/manage-inquiries/userBulkReassign?zsid=#request.zsid#&#qs#";
		returnLink="/z/inquiries/admin/manage-inquiries/userIndex?zsid=#request.zsid#&#qs#";
	}

	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	if(application.zcore.functions.zso(form, 'user_id') EQ '' and application.zcore.functions.zso(form, 'assign_email') EQ ''){
		application.zcore.status.setStatus(request.zsid,"You forgot to type an email address or select a user from the drop down menu.",form,true);
		application.zcore.functions.zRedirect(errorLink); 
	}
	if(application.zcore.functions.zso(form, 'user_id') CONTAINS "|"){
		form.user_id_siteIDType=listGetAt(form.user_id, 2, "|");
		form.user_id=listGetAt(form.user_id, 1, "|");
		form.contact_assigned_user_id=form.user_id;
		form.contact_assigned_user_id_siteIdType=form.user_id_siteIdType;
	}else{
		form.user_id=0;
		form.user_id_siteIDType=0;
		form.contact_assigned_user_id=0;
		form.contact_assigned_user_id_siteIdType=0;
	} 
 
 
	if(application.zcore.functions.zso(form, 'assign_email') NEQ ''){
		arrEmail=listToArray(form.assign_email, ",");
		arrEmailFinal=[];
		for(i=1;i LTE arraylen(arrEmail);i++){
			e=trim(arrEmail[i]);
			if(e NEQ ""){
				if(application.zcore.functions.zEmailValidate(e) EQ false){
					application.zcore.status.setStatus(request.zsid,"Invalid email address format: #arrEmail[i]#",form,true);
					application.zcore.functions.zRedirect(errorLink); 
				}
				arrayAppend(arrEmailFinal, e);
			}
		}
		form.assign_email=arraytolist(arrEmailFinal, ", ");
	}else{
		db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# 
		WHERE site_id =#db.param(application.zcore.functions.zGetSiteIdFromSiteIdType(form.user_id_siteIDType))# and 
		user_id = #db.param(form.user_id)#  and 
		user_deleted=#db.param(0)# ";
		qMember=db.execute("qMember");

 
		if(qMember.recordcount EQ 0){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "User doesn't exist.",form,true);
			application.zcore.functions.zRedirect(errorLink);  
		}
		form.assign_name=qMember.user_first_name&" "&qMember.user_last_name;
		form.assign_email=qMember.user_username;
	}

	db.sql="SELECT group_concat(inquiries_id SEPARATOR #db.param("','")#) idlist, 
	group_concat(DISTINCT contact_id SEPARATOR #db.param("','")#) contactidlist 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries WHERE
	inquiries.site_id = #db.param(request.zOS.globals.id)# and  
	inquiries_deleted = #db.param(0)#  ";
	request.inquiriesCom.inquiriesSearchFilterSQL(db); 
	qInquiries=db.execute("qInquiries"); 
	if(qInquiries.recordcount NEQ 0){
		if(debug){
			writedump("'"&qInquiries.contactIdList&"'");
			writedump("'"&qInquiries.idlist&"'");
		}else{
			// remove contact
			db.sql="DELETE FROM #db.table("contact_x_contact", request.zos.zcoreDatasource)# WHERE 
			contact_id IN (#db.trustedSQL("'"&qInquiries.contactIdList&"'")#) and 
			contact_x_contact_deleted=#db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# ";
			db.execute("qDelete");

			db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# SET ";
			if(form.user_id EQ 0){
				db.sql&=" inquiries_assign_email = #db.param(form.assign_email)#, 
				inquiries_assign_name=#db.param(form.assign_name)#, 
				user_id = #db.param("")#, ";
			}else{
				db.sql&=" 
				inquiries_assign_name=#db.param("")#,
				inquiries_assign_email = #db.param("")#, 
				user_id = #db.param(form.user_id)#, 
				user_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(form.user_id_siteIDType))#, "; 
			}
			if(application.zcore.user.checkGroupAccess("administrator") and form.method EQ "assign" and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1){
				db.sql&=" office_id=#db.param(form.office_id)#, ";   
			}  
			db.sql&=" inquiries_updated_datetime=#db.param(request.zos.mysqlnow)# ";
			db.sql&=" WHERE inquiries_id IN (#db.trustedSQL("'"&qInquiries.idlist&"'")#) and 
			 site_id = #db.param(request.zos.globals.id)# and 
			 inquiries_deleted=#db.param(0)# ";
			db.execute("qUpdate");
		}

		if(qInquiries.contactIdList NEQ ""){
			contactCom=createobject("component", "zcorerootmapping.com.app.contact");
			contact=contactCom.getContactByEmail(form.assign_email, form.assign_name, request.zos.globals.id);
			arrContact=listToArray(replace(qInquiries.contactIdList, "'", "", "all"), ",", false);
			if(structcount(contact) NEQ 0){
				arrInsert=[];
				for(contact_id in arrContact){
					if(contact_id NEQ "" and contact_id NEQ 0){
						arrayAppend(arrInsert, " (#request.zos.globals.id#, '#application.zcore.functions.zescape(contact_id)#', #contact.contact_id#, 0) "); 
					}
				}
				if(arrayLen(arrInsert) NEQ 0){
					if(debug){
						writedump(arrInsert);
					}else{
						db.sql="INSERT IGNORE INTO #db.table("contact_x_contact")# 
						(site_id, contact_id, contact_x_contact_accessible_by_contact_id, contact_x_contact_deleted) 
						VALUES "&db.trustedSQL(arrayToList(arrInsert, ", "));
						db.execute("qInsert");
					}
				}
			} 
		}
		if(debug){
			abort;
		}
		
	}

	/*
	// TODO: might need this if i keep those fields someday
	if(qInquiry.contact_id NEQ 0){
		db.sql="UPDATE #db.table("contact", request.zos.zcoreDatasource)# SET 
		contact_assigned_user_id=#db.param(form.contact_assigned_user_id)#, 
		contact_assigned_user_id_siteIdType=#db.param(form.contact_assigned_user_id_siteIdType)# 
		WHERE contact_id = #db.param(form.contact_id)# and 
		contact_deleted=#db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#";
		db.execute("qUpdateContact");
	}
	 
	}*/
	application.zcore.functions.zRedirect(returnLink); 
	</cfscript>
</cffunction>
 

<cffunction name="getCount" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject; 
	db.sql="SELECT count(inquiries_id) count from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries WHERE
	inquiries.site_id = #db.param(request.zOS.globals.id)# and  
	inquiries_deleted = #db.param(0)# ";
	request.inquiriesCom.inquiriesSearchFilterSQL(db); 
	qInquiries=db.execute("qInquiries"); 
	if(qInquiries.recordcount NEQ 0){
		return qInquiries.count;
	}else{
		return 0;
	}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>