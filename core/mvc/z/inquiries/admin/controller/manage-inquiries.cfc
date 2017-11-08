<cfcomponent extends="zcorerootmapping.com.app.manager-base">
<cfoutput>   
<cffunction name="getQuickLinks" localmode="modern" access="public">
	<cfscript>
	links=[]; 
	variables.hasLeadsAccess=application.zcore.adminSecurityFilter.checkFeatureAccess("Leads");
	if(variables.hasLeadsAccess){
		links=[
			{ link:"/z/inquiries/admin/manage-contact/add", label:"Add Contact" }, 
			{ link:"/z/inquiries/admin/manage-inquiries/index?zManagerAddOnLoad=1", label:"Add Lead"}, 
			{ link:"/z/inquiries/admin/manage-contact/index", label:"Contacts" }, 
			{ link:"/z/inquiries/admin/autoresponder/index", label:"Lead Autoresponders" }, 
			{ link:"/z/inquiries/admin/manage-inquiries/index##exportLeadDiv", label:"Lead Export" }, 
			{ link:"/z/inquiries/admin/routing/index", label:"Lead Routing" }, 
			{ link:"/z/inquiries/admin/lead-source-report/index", label:"Lead Source Report" }, 
			{ link:"/z/inquiries/admin/lead-template/index", label:"Lead Template Emails" }, 
			{ link:"/z/inquiries/admin/types/index", label:"Lead Types" }, 
			{ link:"/z/inquiries/admin/manage-inquiries/index", label:"Leads" }, 
			{ link:"/z/admin/mailing-list-export/index", label:"Mailing List Export" }, 
			{ link:"/z/inquiries/admin/search-engine-keyword-report/index", label:"Search Engine Keyword Lead Report" }
		]; 
	}
	return links;
	</cfscript>
</cffunction>


<cffunction name="getInitConfig" localmode="modern" access="private">
	<cfscript> 
	//variables.uploadPath=request.zos.globals.privateHomeDir&"zupload/inquiries/";
	//variables.displayPath="/zupload/inquiries/";
	ts={
		// required 
		customAddMethods:{"addBulk":"insertBulk", "userAddBulk":"userInsertBulk","userAdd":"userInsert","userEdit":"userUpdate"},
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
			executeDelete:'executeDelete',
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
		title:"Lead",
		requireFeatureAccess="Leads",
		prefixURL:"/z/inquiries/admin/manage-inquiries/",
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
			label:'Assigned User / Office'
		},{
			label:'Priority',
			field:'inquiries_priority',
			sortable:true
		},{
			label:'Status'
		},{
			label:'Received'
		},{
			label:'Last Updated'
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

<cffunction name="init" localmode="modern" access="private">
	<cfscript> 
	ts=getInitConfig();

	//FOR REG USER DO NOT WANT TO REDIRECT
	arrayAppend(ts.titleLinks, { 
			label:"Bulk Add",
			link:"/z/inquiries/admin/manage-inquiries/addBulk"
		}
	);
	arrayAppend(ts.titleLinks, {
		label:"Export",
		link:"/z/inquiries/admin/manage-inquiries/index##exportLeadDiv"
	});
	ts.quickLinks=getQuickLinks();
	ts.requireFeatureAccess="Leads";
	if(form.method EQ "viewContact"){
		ts.readOnlyRequest=true;
	}
	super.init(ts); 

	loadManageLeadGroupData();

	if(request.cgi_script_name CONTAINS "/z/inquiries/admin/manage-inquiries/"){
		hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		hCom.displayHeader();
	}
	</cfscript>
</cffunction>	 


<cffunction name="loadManageLeadGroupData" localmode="modern" access="public">
	<cfscript>
	request.userIdList="";  
	request.groupIdList="";
	found=false;
	groupStruct={};
	if(not structkeyexists(request, 'manageLeadUserGroupStruct')){
		request.manageLeadUserGroupStruct={};
	}
	request.zos.manageLeadGroupNameStruct={};
	request.zos.manageLeadGroupIdStruct={};
	userGroupCom=createobject("component", "zcorerootmapping.com.user.user_group_admin"); 
	for(i in request.manageLeadUserGroupStruct){
		request.zos.manageLeadGroupNameStruct[i]=true;
		request.zos.manageLeadGroupIdStruct[userGroupCom.getGroupId(i, request.zos.globals.id)]=true;
		if(isstruct(request.manageLeadUserGroupStruct[i])){
			for(n in request.manageLeadUserGroupStruct[i]){
				request.zos.manageLeadGroupNameStruct[n]=true;
				request.zos.manageLeadGroupIdStruct[userGroupCom.getGroupId(n, request.zos.globals.id)]=true;
			}
		}
		if(application.zcore.user.checkGroupAccess(i)){  
			if(isstruct(request.manageLeadUserGroupStruct[i])){
				for(n in request.manageLeadUserGroupStruct[i]){
					if(application.zcore.user.checkGroupAccess(n)){
						//echo("has access:"&n&"<br>");
						groupId=userGroupCom.getGroupId(n, request.zos.globals.id);
						groupStruct[groupId]=true;
					}
				}
			}
			found=true;
		}
	} 
	request.zos.manageLeadGroupIdList=structkeylist(request.zos.manageLeadGroupIdStruct);
	request.zos.manageLeadGroupNameList=structkeylist(request.zos.manageLeadGroupNameStruct);
	if(structcount(groupStruct) NEQ 0){
		groupIdList=structkeylist(groupStruct);
		// build a userIdList of user that belong to request.zsession.user.office_id and the user groups this user can manage 
		request.userIdList=getUserIdListByOfficeIdListAndGroupIdList(request.zsession.user.office_id, groupIdList); 
	}  
	if(not application.zcore.user.checkGroupAccess("member")){
		if(application.zcore.functions.zso(form, 'inquiries_id', true) NEQ 0){
			if(not userHasAccessToLead(form.inquiries_id)){
				found=false;
			}
		} 
		if(not found){  
			form.userLoginURL=application.zcore.functions.zso(request.zos.globals, 'userLoginURL');
			if(form.userLoginURL NEQ ""){
				application.zcore.status.setStatus(request.zsid, "You don't have access to this lead or need to login.", form, true);
				application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(form.userLoginURL, "zsid=#request.zsid#"));
			}else{
				application.zcore.status.setStatus(request.zsid, "You don't have access to this lead or need to login.", form, true);
				application.zcore.functions.zRedirect("/z/user/home/index?zsid=#request.zsid#");
			}
		}
	} 
	</cfscript>
</cffunction>	 

<cffunction name="userInit" localmode="modern" access="public">
	<cfscript>
	ts=getInitConfig(); 
	ts.disableAddButton=true;
 
	arrayAppend(ts.titleLinks, { 
			label:"Add",
			link:"/z/inquiries/admin/manage-inquiries/userAdd?modalpopforced=1",
			onclick:"zTableRecordAdd(this, 'sortRowTable', 'top'); return false;"
		}
	);
	arrayAppend(ts.titleLinks, { 
			label:"Bulk Add",
			link:"/z/inquiries/admin/manage-inquiries/userAddBulk"
		}
	); 
 
	if(request.zsession.user.office_id NEQ ""){
		if(not structkeyexists(request.zsession, 'selectedOfficeId')){
			request.zsession.selectedOfficeId=listGetAt(request.zsession.user.office_id, 1, ",");
		}
		form["office_id"] = request.zsession.selectedOfficeId;
	}

	arrayAppend(ts.titleLinks, {
		label:"Export",
		link:"/z/inquiries/admin/manage-inquiries/userIndex##exportLeadDiv"
	});
	ts.requireFeatureAccess="";
	super.init(ts); 
	
	application.zcore.skin.includeCSS("/z/font-awesome/css/font-awesome.min.css");
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");

	
	loadManageLeadGroupData();

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
		if(request.userIdList NEQ ""){
			echo(' (inquiries.user_id IN (#db.trustedSQL(request.userIdList)#) and inquiries.user_id_siteIdType=#db.param(1)#) or ');
		}
		// current user 
		echo(' (inquiries.user_id = #db.param(request.zsession.user.id)# and 
		inquiries.user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#)
		) ');
	}
	return out;
	</cfscript>
</cffunction>

<cffunction name="getUserIdListByOfficeIdListAndGroupIdList" localmode="modern" access="public">
    <cfargument name="officeIdList" type="string" required="yes">
    <cfargument name="groupIdList" type="string" required="yes">
    <cfscript> 
    db=request.zos.queryObject;

    arrOfficeId=listToArray(arguments.officeIdList, ",");
    arrGroupId=listToArray(arguments.groupIdList, ",");

    db.sql="SELECT group_concat(distinct user_id SEPARATOR #db.param(',')#) idlist 
    FROM #db.table("user", request.zos.zcoreDatasource)# 
    WHERE site_id = #db.param(request.zos.globals.id)# AND 
    user_active=#db.param(1)# and 
    user_deleted=#db.param(0)# and ";
    if(arrayLen(arrGroupId) EQ 0){
    	db.sql&=" user_group_id=#db.param(-1)# ";
    }else{
    	db.sql&=" user_group_id IN (";
        for(i=1;i LTE arraylen(arrGroupId);i++){
            id=arrGroupId[i];
            if(i NEQ 1){
            	db.sql&=", ";
            }
            db.sql&=db.param(id);
        }
        db.sql&=" ) "; 
    }
    db.sql&=" and ";
    if(arrayLen(arrOfficeId) EQ 0){
    	db.sql&=" office_id=#db.param(-1)# ";
    }else{
    	db.sql&=" office_id IN (";
        for(i=1;i LTE arraylen(arrOfficeId);i++){
            id=arrOfficeId[i];
            if(i NEQ 1){
            	db.sql&=", ";
            }
            db.sql&=db.param(id);
        }
        db.sql&=" ) "; 
    }
    db.sql&=" ORDER BY user_first_name ASC, user_last_name ASC";
    qUser=db.execute("qUser");  
    if(quser.idlist EQ ""){
    	return "";
    }else{
	    return qUser.idlist;
	}
    </cfscript>
</cffunction>



<cffunction name="userExport" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	exportCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.export");
	exportCom.index();
	</cfscript>
	
</cffunction>
<cffunction name="userView" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	feedbackCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.feedback");
	feedbackCom.view();
	</cfscript>
	
</cffunction> 

<cffunction name="userHasAccessToLead" localmode="modern" access="public" roles="user">
	<cfargument name="inquiries_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	if(not structkeyexists(request.zsession, 'user')){
		return false;
	}
	db.sql="select inquiries_id from #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE inquiries_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_id = #db.param(arguments.inquiries_id)# ";

	db.sql&=getUserLeadFilterSQL(db); 
	qCheckLead=db.execute("qCheckLead"); 
	if(qCheckLead.recordcount GT 0){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="userChangeStatus" localmode="modern" access="remote" roles="user">
	<cfscript>
	changeStatus();
	</cfscript>
</cffunction>

<cffunction name="userShowAllFeedback" localmode="modern" access="remote" roles="user">
	<cfscript>
	showAllFeedback();
	</cfscript>
	
</cffunction>
	 
<cffunction name="userIndex" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	index();
	</cfscript>
	
</cffunction>

<cffunction name="changeStatus" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qIn=0;
	currentMethod=form.method;
	if(currentMethod EQ "userChangeStatus"){
		userInit();
	}else{
		init();
	}
	// TODO: need user security here
	db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	SET inquiries_status_id= #db.param(form.inquiries_status_id)#,
	inquiries_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE inquiries_id= #db.param(form.inquiries_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_deleted=#db.param(0)#";
	qIn=db.execute("qIn");
	application.zcore.status.setStatus(request.zsid,'Status Updated');
	application.zcore.functions.zRedirect('/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid=#request.zsid#');
	</cfscript>
</cffunction>


<cffunction name="showAllFeedback" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qFeedback=0;
	var searchNav=0;
	var searchStruct=0;
	var qFeedbackCount=0;
	currentMethod=form.method;
	if(currentMethod EQ "userShowAllFeedback"){
		application.zcore.functions.z404("userShowAllFeedback is disabled for non-admin users");
		userInit();
	}else{
		init();
		if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
			application.zcore.status.setStatus(request.zsid,"Access denied.");
			application.zcore.functions.zRedirect("/member/?zsid=#request.zsid#");	
		}
	}
	form.zPageId3=application.zcore.functions.zso(form, 'zPageId3');
	form.zIndex = application.zcore.status.getField(form.zPageId3, "zIndex", 1, true);
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2>All Feedback</h2>
	<table  style="width:100%; border-spacing:0px;" class="table-white">
		<form action="/z/inquiries/admin/manage-inquiries/showAllFeedback" method="get" id="owner_lookup_form">
			<tr>
				<td>Type a name or phrase
					<input type="text" name="searchtext" value="#application.zcore.functions.zso(form, 'searchtext')#" size="20" maxchars="10" />
					<button type="submit" name="searchForm" value="Search" class="z-manager-search-button">Search</button>
					<button type="button" name="searchForm2" value="Clear" class="z-manager-search-button" onclick="window.location.href='/z/inquiries/admin/manage-inquiries/showallfeedback';">Clear</button>
					<input type="hidden" name="zIndex" value="1" />
					<input type="hidden" name="zPageId3" value="#form.zPageId3#" /></td>
			</tr>
		</form>
	</table>
	<cfsavecontent variable="db.sql"> 
	SELECT count(inquiries.inquiries_id) count 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
	#db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback
	WHERE 
	inquiries_deleted = #db.param(0)# and 
	inquiries_feedback_deleted = #db.param(0)# and 
	inquiries.inquiries_id = inquiries_feedback.inquiries_id and
	<cfif trim(application.zcore.functions.zso(form, 'searchtext')) NEQ ''>
		(inquiries_feedback_comments LIKE #db.param('%#form.searchtext#%')# or 
		inquiries_feedback_subject LIKE #db.param('%#form.searchtext#%')# or 
		concat(inquiries_first_name,#db.param(' ')#,inquiries_last_name) LIKE #db.param('%#form.searchtext#%')# or 
		inquiries_email LIKE #db.param('%#form.searchtext#%')#) and
	</cfif>
	inquiries.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_feedback.site_id = inquiries.site_id </cfsavecontent>
	<cfscript>
	qFeedbackCount=db.execute("qFeedbackCount");
	</cfscript>
	<cfsavecontent variable="db.sql"> 
	SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
	#db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries_feedback.user_id and 
	user_deleted = #db.param(0)# and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_feedback.user_id_siteIDType"))# WHERE 
	inquiries_deleted = #db.param(0)# and 
	inquiries_feedback_deleted = #db.param(0)# and 
	inquiries.inquiries_id = inquiries_feedback.inquiries_id and
	<cfif trim(application.zcore.functions.zso(form, 'searchtext')) NEQ ''>
		(inquiries_feedback_comments LIKE #db.param('%#form.searchtext#%')# or 
		inquiries_feedback_subject LIKE #db.param('%#form.searchtext#%')# or 
		concat(inquiries_first_name,#db.param(' ')#,inquiries_last_name) LIKE #db.param('%#form.searchtext#%')# or 
		inquiries_email LIKE #db.param('%#form.searchtext#%')#) and
	</cfif>
	inquiries.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_feedback.site_id = inquiries.site_id 
	ORDER BY inquiries_feedback_datetime DESC 
	LIMIT #db.param((form.zIndex-1)*10)#,#db.param(10)# </cfsavecontent>
	<cfscript>
	qFeedback=db.execute("qFeedback");
	</cfscript>
	<cfif qFeedBack.recordcount NEQ 0>
		<hr />
		<cfscript>
		searchStruct = StructNew();
		searchStruct.count = qFeedbackCount.count;
		searchStruct.index = form.zIndex;
		searchStruct.showString = "Results ";

		searchStruct.url = "/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#";
		searchStruct.indexName = "zIndex";
		searchStruct.buttons = 5;
		searchStruct.perpage = 10;
		if(searchStruct.count LTE searchStruct.perpage){
			searchNav="";
		}else{
			searchNav = '<table class="table-list" style="width:100%; border-spacing:0px;" ><tr><td style="padding:0px;">'&application.zcore.functions.zSearchResultsNav(searchStruct)&'</td></tr></table>';
		}
		</cfscript>
		#searchNav#<br />
		<table style="width:100%; border-spacing:0px;">
			<cfloop query="qFeedback">
				<cfif qFeedback.inquiries_feedback_subject NEQ ''>
					<tr>
						<td style="border:1px solid ##999999; background-color:##EFEFEF; ">#qFeedback.inquiries_feedback_subject#</td>
					</tr>
				</cfif>
				<cfif qFeedback.inquiries_feedback_comments NEQ ''>
					<tr>
						<td style=" border:1px solid ##999999;">#application.zcore.functions.zParagraphFormat(qFeedback.inquiries_feedback_comments)#</td>
					</tr>
				</cfif>
				<tr>
					<td style="border:1px solid ##999999; border-top:0px; ">By
						<cfif qFeedback.user_email EQ "">
							Unknown User
						<cfelse>
							<a href="mailto:#qFeedback.user_email#">#qFeedback.user_first_name# #qFeedback.user_last_name#</a>
						</cfif>
						on #DateFormat(qFeedback.inquiries_feedback_datetime, 'm/d/yyyy')&' at '&TimeFormat(qFeedback.inquiries_feedback_datetime, 'h:mm tt')# | 
						<a href="/z/inquiries/admin/feedback/view?inquiries_id=#qFeedback.inquiries_id#">View Lead</a> | 
						<a href="/z/inquiries/admin/feedback/deleteFeedback?inquiries_feedback_id=#qFeedback.inquiries_feedback_id#&amp;inquiries_id=#qFeedback.inquiries_id#">Delete</a></td>
				</tr>
				<tr>
					<td>&nbsp;</td>
				</tr>
			</cfloop>
		</table>
		#searchNav#
	</cfif>
</cffunction> 

<cffunction name="userInsertPrivateNote" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
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
		echo('<table cellpadding="0" cellspacing="0" border="0"><tr><td style="background:##f7df9e; font-size:12px; padding:5px 15px 5px 15px; color:##b68500;">PRIVATE NOTE</td></tr></table>');
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
		//writedump(ts);abort;
		//writedump(ts);	abort; 
	 
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
	if(form.method EQ "userInsertPrivateNote"){
		if(form.editSource EQ "contact"){
			link="/z/inquiries/admin/feedback/userViewContact?contactTab=4&contact_id=#form.contact_id#&inquiries_id=#form.inquiries_id#";
		}else{
			link="/z/inquiries/admin/manage-inquiries/userView?inquiries_id=#form.inquiries_id#";
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
	userInit();
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
	db.sql="SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template
	LEFT JOIN #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)# inquiries_lead_template_x_site ON 
	inquiries_lead_template_x_site.inquiries_lead_template_id = inquiries_lead_template.inquiries_lead_template_id and 
	inquiries_lead_template_x_site_deleted = #db.param(0)# and 
	inquiries_lead_template_x_site_siteidtype=#db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_lead_template.site_id"))# and 
	inquiries_lead_template_x_site.site_id = #db.param(request.zos.globals.id)# 
	WHERE inquiries_lead_template_x_site.site_id IS NULL and 
	inquiries_lead_template_deleted = #db.param(0)# and 
	inquiries_lead_template_type = #db.param('1')# and 
	inquiries_lead_template.site_id IN (#db.param('0')#, #db.param(request.zos.globals.id)#)";
	if(application.zcore.app.siteHasApp("listing") EQ false){
		db.sql&=" and inquiries_lead_template_realestate = #db.param('0')#";
	}
	db.sql&=" ORDER BY inquiries_lead_template_sort ASC, inquiries_lead_template_name ASC ";
	qTemplate=db.execute("qTemplate");
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
	<form class="zFormCheckDirty" name="sendEmailForm" id="sendEmailForm" action="/z/inquiries/admin/manage-inquiries/<cfif form.method EQ "userAddPrivateNote" or form.method EQ "userView">userInsertPrivateNote<cfelse>insertPrivateNote</cfif>?contact_id=#form.contact_id#&amp;inquiries_id=#form.inquiries_id#"  method="post" enctype="multipart/form-data">
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
		<div class="z-float z-p-10">
			Submitting this form will add a private note that is not visible to the outside contacts.
		</div>

		<div class="z-manager-edit-errors z-float"></div>  
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
				document.sendEmailForm.inquiries_feedback_subject.value=arrNoteTemplate[v].subject;
				tinymce.get('inquiries_feedback_comments').setContent(arrNoteTemplate[v].message); 
			}else{
				document.sendEmailForm.inquiries_feedback_subject.value='';
				tinymce.get('inquiries_feedback_comments').setContent(arrNoteTemplate[v].message); 
			}
		}
		/* ]]> */
		</script> 
		<table class="table-list" style="width:100%; "> 
			<tr>
				<th style="width:100px;" title="Selecting a template will prefill the subject and message with a prewritten response.">Template:</th>
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


<cffunction name="userSubscribeToLead" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	subscribeToLead();
	</cfscript>
</cffunction>


<cffunction name="subscribeToLead" localmode="modern" access="remote" roles="member">
	<cfscript>
	form.inquiries_id=application.zcore.functions.zso(form, 'inquiries_id', true, 0);
	if(form.method EQ "subscribeToLead"){
		init(); 
	}
	form.contact_id=application.zcore.functions.zso(form, 'contact_id', true, request.zsession.user.contact_id);
	if(form.contact_id NEQ request.zsession.user.contact_id and not application.zcore.user.checkGroupAccess("administrator")){
		application.zcore.functions.zReturnJson({succcess:false, errorMessage:"You don't have permission to do this."});
	}
	db=request.zos.queryObject;
	db.sql="select * from #db.table("inquiries_x_contact", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_id=#db.param(form.inquiries_id)# and
	contact_id=#db.param(form.contact_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_x_contact_deleted=#db.param(0)#";
	qContact=db.execute("qContact");
	if(qContact.recordcount EQ 0){
		ts={
			table:"inquiries_x_contact",
			datasource:request.zos.zcoreDatasource,
			struct:{
				inquiries_id:form.inquiries_id,
				contact_id:form.contact_id,
				site_id:request.zos.globals.id,
				inquiries_x_contact_deleted:0,
				inquiries_x_contact_type:"to",
				inquiries_x_contact_updated_datetime:request.zos.mysqlnow
			}
		};
		application.zcore.functions.zInsert(ts);
	}
	application.zcore.functions.zReturnJson({success:true, subscribed:true});
	</cfscript>
</cffunction>

<cffunction name="userUnsubscribeToLead" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	unsubscribeToLead();
	</cfscript>
</cffunction>


<cffunction name="unsubscribeToLead" localmode="modern" access="remote" roles="member">
	<cfscript>
	form.inquiries_id=application.zcore.functions.zso(form, 'inquiries_id', true, 0);
	form.contact_id=application.zcore.functions.zso(form, 'contact_id', true, request.zsession.user.contact_id);
	if(form.contact_id NEQ request.zsession.user.contact_id and not application.zcore.user.checkGroupAccess("administrator")){
		application.zcore.functions.zReturnJson({succcess:false, errorMessage:"You don't have permission to do this."});
	}
	if(form.method EQ "unsubscribeToLead"){
		init(); 
	}
	db=request.zos.queryObject;
	db.sql="delete from #db.table("inquiries_x_contact", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_id=#db.param(form.inquiries_id)# and
	contact_id=#db.param(form.contact_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_x_contact_deleted=#db.param(0)#";
	db.execute("qDelete");
	application.zcore.functions.zReturnJson({success:true, subscribed:false});
	</cfscript>
</cffunction>

<cffunction name="view" localmode="modern" access="remote" roles="member">
	<cfscript>  
	var db=request.zos.queryObject; 
	currentMethod=form.method;
	if(currentMethod EQ "userView"){
		userInit();
	}else{
		init();
	}
	db.sql="SELECT * FROM (#db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
	#db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status) 
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
	inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	inquiries_type_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id and user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE inquiries.site_id = #db.param(request.zos.globals.id)# and 	
	inquiries_status_deleted = #db.param(0)# and 
	inquiries_deleted = #db.param(0)# and 
	inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
	(( inquiries_id = #db.param(form.inquiries_id)# and 
	inquiries_parent_id = #db.param(0)# ) or 
	(inquiries_parent_id = #db.param(form.inquiries_id)# )) ";
	if(currentMethod EQ "userView"){
		db.sql&=getUserLeadFilterSQL(db);
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	qinquiry=db.execute("qinquiry");
	if(qinquiry.recordcount EQ 0){		
		request.zsid = application.zcore.status.setStatus(Request.zsid, "This inquiry doesn't exist.", false,true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
	} 
	contactCom=createobject("component", "zcorerootmapping.com.app.contact");
	if(qInquiry.inquiries_email NEQ ""){
		contact = contactCom.getContactByEmail(qInquiry.inquiries_email, qInquiry.inquiries_first_name&" "&qInquiry.inquiries_last_name, request.zos.globals.id);
	}
	</cfscript>

<script type="text/javascript">
zArrDeferredFunctions.push(function(){
	function placeLeadMenu(){
		setTimeout(function(){
			// must delay to ensure it happens last
			var p=zGetAbsPosition(document.getElementById("leadDetailMenuBarPlaceholder"));   
			var top=0;
			var left=0;
			var $mobileHeader=$(".z-mobile-header");
			if(zWindowSize.width < 479){
				$(".zLeadEditButton").hide();
				$(".zLeadAssignButton").hide();
			}
			$("##leadDetailMenuBarPlaceholder").css({
				"height":$("##leadDetailMenuBar").height()+"px"
			});
			if($mobileHeader.length && $mobileHeader.css("position")=="fixed"){
				if(zScrollPosition.top > p.y-$mobileHeader.height()){
					var top=Math.max(zScrollPosition.top+$mobileHeader.height(), p.y);
				}else{
					var top=p.y;
				}
			}else{
				var top=Math.max(zScrollPosition.top, p.y);
			}
			$("##leadDetailMenuBar").css({
				"width":p.width+"px",
				"top":top+"px",
				"left":p.x+"px"
			});
		},1);
	}
	zArrScrollFunctions.push({functionName:placeLeadMenu});
	zArrResizeFunctions.push({functionName:placeLeadMenu});
	$("##leadDetailMenuBar").show();
	placeLeadMenu();
});
</script>
	<cfif currentMethod EQ "userViewContact" or currentMethod EQ "viewContact">
		<div id="leadDetailMenuBarPlaceholder" class="z-float " style="height:37px; position:relative;">
		</div>
		<div id="leadDetailMenuBar" style="position:absolute; top:0px; left:0px; z-index:1000; display:none; width:100px; background-color:##FFF; padding:5px; ">
			<h3 style="display:inline-block;">Lead ###form.inquiries_id#</h3> &nbsp;&nbsp;

			<cfif currentMethod EQ "userView" or currentMethod EQ "userViewContact"> 
				<cfif request.zos.isTestServer and qInquiry.inquiries_email NEQ "">
					<a href="/z/inquiries/admin/send-message/userIndex?inquiries_id=#qinquiry.inquiries_id#&amp;contact_id=#contact.contact_id#" class="z-manager-search-button" onclick="zShowModalStandard(this.href, 4000, 4000, true, true); return false;" title="Reply" style=" text-decoration:none;"><i class="fa fa-mail-reply" aria-hidden="true" style="padding-right:5px;"></i><span>Reply</span></a> 
				</cfif>
				<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserAssign', true, 0) EQ 1>
					<a href="/z/inquiries/admin/assign/userIndex?inquiries_id=#qinquiry.inquiries_id#&amp;zPageId=#form.zPageId#" class="z-manager-search-button" title="Assign Lead" style=" text-decoration:none;"><i class="fa fa-mail-forward" aria-hidden="true" style="padding-right:5px;"></i><span>Assign</span></a> 
				</cfif> 
				<a href="/z/inquiries/admin/manage-inquiries/userAddPrivateNote?inquiries_id=#form.inquiries_id#&amp;modalpopforced=1&editSource=contact"  onclick="zShowModalStandard(this.href, 4000, 4000, true, true); return false;" class="z-manager-search-button" title="Click here to add a private note"><i class="fa fa-comment" aria-hidden="true"></i> Add Note</a> 
			<cfelseif currentMethod EQ "view" or currentMethod EQ "viewContact">
		
				<cfif qinquiry.inquiries_readonly EQ 1>
					<!--- | Read-only | Edit is disabled --->
				<cfelse>
					<a href="/z/inquiries/admin/manage-inquiries/edit?inquiries_id=#form.inquiries_id#&modalpopforced=1&editSource=contact" onclick="zShowModalStandard(this.href, 4000, 4000, true, true); return false;" class="z-manager-search-button">Edit</a>
				</cfif>  
				<cfif request.zos.isTestServer and qInquiry.inquiries_email NEQ "">
					<a href="/z/inquiries/admin/send-message/index?inquiries_id=#qinquiry.inquiries_id#&amp;contact_id=#contact.contact_id#" class="z-manager-search-button" onclick="zShowModalStandard(this.href, 4000, 4000, true, true); return false;" title="Reply" style=" text-decoration:none;"><i class="fa fa-mail-reply" aria-hidden="true" style="padding-right:5px;"></i><span>Reply</span></a> 
				</cfif>
				<a href="/z/inquiries/admin/assign/index?inquiries_id=#qinquiry.inquiries_id#&amp;zPageId=#form.zPageId#" class="z-manager-search-button" title="Assign Lead" style=" text-decoration:none;"><i class="fa fa-mail-forward" aria-hidden="true" style="padding-right:5px;"></i><span>Assign</span></a> 
				<a href="/z/inquiries/admin/manage-inquiries/addPrivateNote?inquiries_id=#form.inquiries_id#&amp;modalpopforced=1"  onclick="zShowModalStandard(this.href, 4000, 4000, true, true); return false;" class="z-manager-search-button" title="Click here to add a private note"><i class="fa fa-comment" aria-hidden="true"></i> Add Note</a> 
	 
			</cfif> 
		</div> 
		<div class="z-float z-contact-container">
			<cfscript> 
			viewIncludeCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
			viewIncludeCom.getViewInclude(qinquiry, true);
	        </cfscript>
	    </div>
	<cfelse>
		<p><a href="/z/inquiries/admin/manage-inquiries/<cfif currentMethod EQ "userView">userIndex<cfelse>index</cfif>">Leads</a> /</p>
		<cfloop query="qinquiry">
			<div class="z-float  z-mb-10">
				<div class="z-float-left">
					<h2 style="display:inline;">Lead</h2>
				</div>
				<div class="z-float-left z-pt-10">
					<cfif currentMethod EQ "userView">
						<div class="z-manager-button-container">
							<cfif request.zos.isTestServer and qInquiry.inquiries_email NEQ "">
								<a href="/z/inquiries/admin/send-message/userIndex?inquiries_id=#qinquiry.inquiries_id#&amp;contact_id=#contact.contact_id#" class="z-manager-assign" onclick="zShowModalStandard(this.href, 4000, 4000, true, true); return false;" title="Reply" style=" text-decoration:none;"><i class="fa fa-mail-reply" aria-hidden="true" style="padding-right:5px;"></i><span>Reply</span></a> 
							</cfif>
							<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserAssign', true, 0) EQ 1>
								<a href="/z/inquiries/admin/assign/userIndex?inquiries_id=#qinquiry.inquiries_id#&amp;zPageId=#form.zPageId#" class="z-manager-assign" title="Assign Lead" style=" text-decoration:none;"><i class="fa fa-mail-forward" aria-hidden="true" style="padding-right:5px;"></i><span>Assign</span></a> 
							</cfif>
						</div>
					<cfelseif currentMethod EQ "view">
				
						<cfif qinquiry.inquiries_readonly EQ 1>
							<!--- | Read-only | Edit is disabled --->
						<cfelse>
							<!--- <div class="z-manager-button-container">
								<a href="/z/inquiries/admin/manage-inquiries/edit?inquiries_id=#qinquiry.inquiries_id#&amp;zPageId=#form.zPageId#" class="z-manager-edit" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a>
							</div> --->
						</cfif> 
						<div class="z-manager-button-container">
							<cfif request.zos.isTestServer and qInquiry.inquiries_email NEQ "">
								<a href="/z/inquiries/admin/send-message/index?inquiries_id=#qinquiry.inquiries_id#&amp;contact_id=#contact.contact_id#" class="z-manager-assign" onclick="zShowModalStandard(this.href, 4000, 4000, true, true); return false;" title="Reply" style=" text-decoration:none;"><i class="fa fa-mail-reply" aria-hidden="true" style="padding-right:5px;"></i><span>Reply</span></a> 
							</cfif>
							<a href="/z/inquiries/admin/assign/index?inquiries_id=#qinquiry.inquiries_id#&amp;zPageId=#form.zPageId#" class="z-manager-assign" title="Assign Lead" style=" text-decoration:none;"><i class="fa fa-mail-forward" aria-hidden="true" style="padding-right:5px;"></i><span>Assign</span></a>
						</div>
						<!--- <cfif qinquiry.inquiries_reservation EQ 1>
							<a href="/z/rental/admin/reservations/cancel?inquiries_id=#qinquiry.inquiries_id#">Cancel Reservation</a>
						</cfif> --->
			 
					</cfif>
				</div>
			</div>
			<cfscript> 
			viewIncludeCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
			viewIncludeCom.getViewInclude(qinquiry, true);
	        </cfscript>
		</cfloop>
	</cfif>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	super.delete();
	</cfscript>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="insertBulk" localmode="modern" access="remote" roles="member">
	<cfscript>
	update();
	</cfscript>
</cffunction>
<cffunction name="userInsertBulk" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	super.update();
	</cfscript>
</cffunction>


<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	super.update();
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	super.edit();
	</cfscript>
</cffunction>

<cffunction name="addBulk" localmode="modern" access="remote" roles="member">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="userAddBulk" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	variables.disableAddEdit = false;
	super.edit();
	</cfscript>
</cffunction>

<cffunction name="userAdd" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	super.edit();
	</cfscript>
</cffunction>

<cffunction name="userEdit" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	super.edit();
	</cfscript>
</cffunction>

<cffunction name="userInsert" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit(); 
	super.update();
	</cfscript>
</cffunction>

<cffunction name="userUpdate" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	super.update();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript> 
 	init();
	super.index();
	</cfscript>


	<cfif application.zcore.user.checkGroupAccess("member") or form.method EQ "userIndex">
	
		<script type="text/javascript">
		/* <![CDATA[ */
		function loadExport(){
			var wf=document.getElementById("whichfields1");	
			var whichfields="0";
			if(wf.checked){
				whichfields="1";
			}
			var et=document.getElementById("exporttype1");	
			var et2=document.getElementById("exporttype2");	
			var exporttype="0";
			if(et.checked){
				exporttype="1";
			}else if(et2.checked){
				exporttype="2";
			}
			var format="html";
			et=document.getElementById("exportformat1");	
			if(et.checked){
				format="csv";	
			}
			window.open("<cfif form.method EQ "index">/z/inquiries/admin/export/index<cfelse>/z/inquiries/admin/manage-inquiries/userExport</cfif>?uid=#form.uid#&inquiries_status_id=#form.inquiries_status_id#&inquiries_type_id=#application.zcore.functions.zso(form, 'inquiries_type_id')#&inquiries_name=#urlencodedformat(application.zcore.functions.zso(form, 'inquiries_name'))#&inquiries_start_date=#urlencodedformat(dateformat(form.inquiries_start_date,'yyyy-mm-dd'))#&inquiries_end_date=#urlencodedformat(dateformat(form.inquiries_end_date,'yyyy-mm-dd'))#&format="+format+"&exporttype="+exporttype+"&whichfields="+whichfields);
		}
		/* ]]> */
		</script> 
		<div id="exportLeadDiv" class="z-pt-20 z-float">
			<h2>Export Leads</h2>
			<p>Note: Only the leads in the above report will be exported.</p>
			<p>Format: 
			<input type="radio" name="exportformat" id="exportformat1" value="1" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 1>checked="checked"</cfif> style="vertical-align:middle; margin:0px; background:none; border:none;" />
			CSV
			<input type="radio" name="exportformat" value="0" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 0>checked="checked"</cfif> style="vertical-align:middle; background:none; margin:0px;margin-left:10px; border:none;" />
			HTML</p>
			<p>Fields: 
			<input type="radio" name="whichfields" id="whichfields1" value="1" <cfif application.zcore.functions.zso(form, 'whichfields',false,1) EQ 1>checked="checked"</cfif> style="vertical-align:middle; margin:0px; background:none; border:none;" />
			All Fields
			<cfif request.zos.istestserver>
	
				<input type="radio" name="whichfields" value="0" <cfif application.zcore.functions.zso(form, 'whichfields',false,1) EQ 0>checked="checked"</cfif> style="vertical-align:middle; background:none; margin:0px;margin-left:10px; border:none;" /> Basic Fields 
			</cfif></p>
			<p>Filter:
			<input type="radio" name="exporttype" id="exporttype1" value="1" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 1>checked="checked"</cfif> style="vertical-align:middle; background:none; margin:0px; border:none;" />
			Unique Emails Only
			<input type="radio" name="exporttype" id="exporttype2" value="2" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 2>checked="checked"</cfif> style="vertical-align:middle; background:none;  margin:0px;margin-left:10px; border:none;" />
			Unique Phone Numbers Only
			<input type="radio" name="exporttype" value="0" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 0>checked="checked"</cfif> style="vertical-align:middle; background:none; margin:0px;margin-left:10px; border:none;" />
			Export All Results</p>
			<p><button type="button" name="submit11" onclick="loadExport();" class="z-manager-search-button">Export</button></p>
			<!--- <cfif form.searchType NEQ "">
			</cfif> --->
		</div>
	</cfif> 
</cffunction> 

<cffunction name="executeDelete" localmode="modern" access="private">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss; 
	application.zcore.functions.z404("Delete is disabled");
	var db=request.zos.queryObject; 
	/*
	db.sql="DELETE FROM #db.table("inquiries", variables.datasource)#  
	WHERE inquiries_id= #db.param(application.zcore.functions.zso(form, 'inquiries_id'))# and 
	inquiries_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	q=db.execute("q");
	*/
	return {success:true};
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
	if(application.zcore.functions.zso(form,'inquiries_type_id') EQ '' and application.zcore.functions.zso(form,'inquiries_type_other') EQ ''){
		application.zcore.status.setStatus(Request.zsid, 'Source is required',form,true);
		return {success:false};
	}
	if(application.zcore.functions.zso(form,'inquiries_type_other') NEQ ''){
		form.inquiries_type_id=0;
		form.inquiries_type_id_siteIdType=4;
	}else{
		local.arrType=listToArray(form.inquiries_type_id,"|");
		form.inquiries_type_id=local.arrType[1];
		form.inquiries_type_id_siteIDType=local.arrType[2];
	}
	form.inquiries_status_id = application.zcore.functions.zso(form, 'inquiries_status_id', true);
	if(form.inquiries_status_id EQ 0){
		form.inquiries_status_id=1;
	} 

	if(form.method EQ "userInsert" or structkeyexists(variables.reverseCustomAddMethods, form.method)){
		// user version of assign check 
		arrUser=listToArray(form.user_id, "|");
		if(arraylen(arrUser) EQ 2){
			form.user_id=arrUser[1];
			form.user_id_siteIDType=arrUser[2];
			// TODO: maybe it could be secured with assign's qAgent stuff | is this a user i have access to
			// NOT TODAY
		}else{
			if(form.user_id NEQ ""){
				throw("Invalid user_id format");
			}
		}
		//	form.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
	}else{ 
		if(not application.zcore.user.checkGroupAccess("administrator")){
			form.user_id=request.zsession.user.id;
			form.user_id_siteIDType=application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
			form.inquiries_status_id=2;
		}
	} 
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
	db.sql="SELECT * FROM #db.table("inquiries", request.zos.zcoreDatasource)#
	WHERE inquiries_deleted = #db.param(0)# and  
	inquiries_id=#db.param(form.inquiries_id)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	qData=db.execute("qData");
	if(qData.recordcount NEQ 0){
		// used by beforeReturnInsertUpdate when method is update
		form.contact_id=qData.contact_id;
	}
	return {success:true, qData:qData};
	</cfscript>
</cffunction>

<cffunction name="beforeReturnInsertUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>   
	urlPage = "";
	if(form.method EQ "update"){
		if(form.contact_id EQ 0){
			link="/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid=#request.zsid#";
		}
		link="/z/inquiries/admin/feedback/viewContact?contactTab=4&contact_id=#form.contact_id#&inquiries_id=#form.inquiries_id#";
		return {success:true, id:form.inquiries_id, redirect:1,redirectLink: link};
	}else if(form.method EQ "userUpdate"){
		if(form.contact_id EQ 0){
			link="/z/inquiries/admin/manage-inquiries/userIndex?zPageId=#form.zPageId#&zsid=#request.zsid#";
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
	rs={success:true}; 
	result=application.zcore.functions.zUpdateLead();  
	if(result EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead failed to be updated.", false,true);
		application.zcore.status.displayReturnJson(request.zsid);
	}else{
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead Updated.");
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="beforeInsert" localmode="modern" access="private" returntype="struct">
	<cfscript> 
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
	form.inquiries_status_id = 1;

	form.inquiries_id=application.zcore.functions.zInsertLead(); 
	if(form.inquiries_id EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead failed to be added.", false,true);
		application.zcore.status.displayReturnJson(request.zsid);
	}else{
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead Added.");
	}
	return rs;
	</cfscript>
</cffunction>


<cffunction name="getDeleteData" localmode="modern" access="private">
	<cfscript>
	application.zcore.functions.z404("Delete is disabled");
	/*var db=request.zos.queryObject; 
	rs={};
	db.sql="SELECT * FROM #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE inquiries_id= #db.param(application.zcore.functions.zso(form,'inquiries_id'))# and 
	inquiries_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	rs.qData=db.execute("qData");
	return rs;
	*/
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
	inquiries_id=#db.param(form.inquiries_id)#";
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" and user_id = #db.param(request.zsession.user.id)# and user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#";
	}
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
	arrayAppend(fs, {label:'', hidden:true, field:'<input type="hidden" name="editSource" value="#htmleditformat(application.zcore.functions.zso(form, 'editSource'))#">'}); 
	savecontent variable="field"{
		if(form.inquiries_type_id DOES NOT CONTAIN "|"){
			form.inquiries_type_id=form.inquiries_type_id&"|"&form.inquiries_type_id_siteIDType;
		}
		selectStruct = StructNew();
		selectStruct.name = "inquiries_type_id";
		selectStruct.query = variables.qTypes;
		selectStruct.queryLabelField = "inquiries_type_name";
		selectStruct.queryParseValueVars=true;
		selectStruct.queryValueField = "##inquiries_type_id##|##inquiries_type_id_siteIDType##";
		application.zcore.functions.zInputSelectBox(selectStruct);
		echo(' or Other:
		<input type="text" name="inquiries_type_other" style="min-width:auto; max-width:300px; " value="#application.zcore.functions.zso(form,'inquiries_type_other')#" /> ');
	}
	arrayAppend(fs, {label:'Source', required:true, field:field}); 
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
		echo('<input type="text" name="inquiries_phone2" value="#htmleditformat(form.inquiries_phone2)#" />');
	}
	arrayAppend(fs, {label:'Cell Phone', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="inquiries_phone3" value="#htmleditformat(form.inquiries_phone3)#" />');
	}
	arrayAppend(fs, {label:'Home Phone', field:field});
 
	savecontent variable="field"{
		echo('<input type="text" name="inquiries_address" value="#htmleditformat(form.inquiries_address)#" />');
	}
	arrayAppend(fs, {label:'Address', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="inquiries_address2" value="#htmleditformat(form.inquiries_address2)#" />');
	}
	arrayAppend(fs, {label:'Address 2', field:field});

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

	savecontent variable="field"{  
		db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status 
		WHERE inquiries_status_deleted = #db.param(0)#
		ORDER BY inquiries_status_name ";
		qInquiryStatus=db.execute("qInquiryStatus");
		selectStruct = StructNew();
		selectStruct.name = "inquiries_status_id";
		selectStruct.query = qInquiryStatus;
		selectStruct.queryLabelField = "inquiries_status_name";
		selectStruct.queryValueField = 'inquiries_status_id';
		application.zcore.functions.zInputSelectBox(selectStruct);
	}
	arrayAppend(fs, {label:'Status', field:field});

	savecontent variable="field"{
		echo('<textarea name="inquiries_admin_comments" cols="50" rows="5">#htmleditformat(form.inquiries_admin_comments)#</textarea>');
	}
	arrayAppend(fs, {label:'Private Notes', field:field});

	/*if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		savecontent variable="field"{  
			userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
			db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
			user_deleted = #db.param(0)# and
			user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and (user_server_administrator=#db.param(0)# )
			ORDER BY member_first_name ASC, member_last_name ASC ";
			qAgents=db.execute("qAgents");
			selectStruct = StructNew();
			selectStruct.name = "user_id";
			selectStruct.query = qAgents;
			selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##)";
			selectStruct.queryParseLabelVars = true;
			selectStruct.queryValueField = 'user_id';
			application.zcore.functions.zInputSelectBox(selectStruct);
		}
	}*/
	var ass = new Assign();
		savecontent variable="field"{  
			echo(ass.getAssignLead(""));
		}
	arrayAppend(fs, {label:'Assign To', field:field});
	//arrayAppend(fs, {label:'Assign To', field:field});

	rs.tabs.basic.fields=fs;
	// advanced fields
	/*
	fs=[];
	savecontent variable="field"{
		echo('<input type="text" name="inquiries_advanced" value="#htmleditformat(form.inquiries_advanced)#" />');
	}
	arrayAppend(fs, {label:'Advanced Field', field:field});

	rs.tabs.advanced.fields=fs; 
	*/

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

	form.search_office_id=application.zcore.functions.zso(form, 'search_office_id', true, "0");
	if(application.zcore.functions.zso(request.zsession, "selectedofficeid", true, 0) NEQ 0){
		form.search_office_id=request.zsession.selectedofficeid;
	} 
	form.search_email=application.zcore.functions.zso(form, 'search_email');
	form.search_phone=application.zcore.functions.zso(form, 'search_phone');
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id');
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
	/*if(structkeyexists(form, 'viewspam')){
		request.zsession.leadviewspam=form.viewspam;
	}else if(not structkeyexists(request.zsession, 'leadviewspam')){*/
		request.zsession.leadviewspam=0;	
	//}

 
	db.sql="select min(inquiries_datetime) as inquiries_datetime 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	where site_id = #db.param(request.zos.globals.id)# and  
	inquiries.inquiries_datetime <> #db.param('')# and 
	inquiries_parent_id = #db.param(0)# and 
	inquiries_deleted = #db.param(0)# ";
	if(form.method EQ "userIndex"){
		db.sql&=getUserLeadFilterSQL(db);
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	if(form.selected_user_id NEQ '0'){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ";
	}
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
	inquiries_id maxid, inquiries_datetime maxdatetime, #db.param('1')# inquiryCount
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
	if(form.search_office_id NEQ "0"){
		db.sql&=" and inquiries.office_id = #db.param(form.search_office_id)# ";
	}
	if(form.inquiries_status_id EQ ""){ 
		db.sql&=" and inquiries.inquiries_status_id <> #db.param(0)# ";
	}else{
		db.sql&=" and inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# ";
	}
	db.sql&=" and inquiries_parent_id = #db.param(0)# ";

	if(form.method EQ "userIndex"){
		db.sql&=" #getUserLeadFilterSQL(db)#";
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	if(form.selected_user_id NEQ 0){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)# ";
	}
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
	if(form.inquiries_status_id EQ ""){ 
		if(request.zsession.leadcontactfilter EQ 'new'){
			db.sql&=" and inquiries.inquiries_status_id =#db.param('1')#  ";
		}else if(request.zsession.leadcontactfilter EQ 'email'){
			db.sql&=" and inquiries_phone1 =#db.param('')# and inquiries_phone_time=#db.param('')#";
		}else if(request.zsession.leadcontactfilter EQ 'phone'){
			db.sql&=" and inquiries_phone1 <>#db.param('')# and inquiries_phone_time=#db.param('')#";
		}else if(request.zsession.leadcontactfilter EQ 'forced'){
			db.sql&=" and inquiries_phone_time<>#db.param('')# ";
		} 
	} 
	sortColumnSQL=getSortColumnSQL();
	if(sortColumnSQL NEQ ''){
		db.sql&=" ORDER BY #sortColumnSQL# inquiries_id ASC";
	}else{
		db.sql&=" ORDER BY maxdatetime DESC ";
	}
	db.sql&=" LIMIT #db.param(max(0,(form.zIndex-1))*30)#,#db.param(30)#";
	rs.qData=db.execute("qData");  

	db.sql="SELECT count(inquiries.inquiries_email) count 
	from #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE inquiries.site_id = #db.param(request.zos.globals.id)# and ";
	if(form.inquiries_status_id EQ ""){ 
		db.sql&=" inquiries.inquiries_status_id <> #db.param(0)# and  ";
	}else{
		db.sql&=" inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# and ";
	}
	db.sql&=" inquiries_deleted = #db.param(0)# 
	and inquiries_parent_id = #db.param(0)#"; 
	if(form.method EQ "userIndex"){
		db.sql&=" #getUserLeadFilterSQL(db)#";
	}else if(structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false and structkeyexists(request.zos.userSession.groupAccess, "manager") eq false){
		db.sql&=" AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())# ";
	}
	if(form.selected_user_id NEQ 0){
		db.sql&=" and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#";
	}
	if(form.search_office_id NEQ "0"){
		db.sql&=" and inquiries.office_id = #db.param(form.search_office_id)# ";
	}
	if(form.search_phone NEQ ""){
		db.sql&=" and inquiries.inquiries_phone1 like #db.param("%"&form.search_phone&"%")# ";
	}
	if(form.search_email NEQ ""){
		db.sql&=" and inquiries.inquiries_email like #db.param("%"&form.search_email&"%")# ";
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
	if(form.inquiries_status_id EQ ""){ 
		if(request.zsession.leadcontactfilter EQ 'new'){
			db.sql&=" and inquiries.inquiries_status_id =#db.param('1')#";
		}else if(request.zsession.leadcontactfilter EQ 'email'){
			db.sql&=" and inquiries_phone1 =#db.param('')# and inquiries_phone_time=#db.param('')#";
		}else if(request.zsession.leadcontactfilter EQ 'phone'){
			db.sql&=" and inquiries_phone1 <>#db.param('')# and inquiries_phone_time=#db.param('')#";
		}else if(request.zsession.leadcontactfilter EQ 'forced'){
			db.sql&=" and inquiries_phone_time<>#db.param('')#";
		} 
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
	savecontent variable="statusField"{
		db.sql="SELECT * from #db.table("inquiries_status", request.zos.zcoreDatasource)# 
		WHERE   
		inquiries_status_deleted = #db.param(0)# "; 
		db.sql&="ORDER BY inquiries_status_name ASC ";
		qStatus=db.execute("qStatus");
		selectStruct = StructNew();
		selectStruct.name = "inquiries_status_id";
		selectStruct.inlineStyle="width:100%;";
		selectStruct.query = qStatus;
		selectStruct.queryLabelField = "inquiries_status_name"; 
		selectStruct.queryValueField = "inquiries_status_id";
		application.zcore.functions.zInputSelectBox(selectStruct);
	}
	arrayAppend(rs.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Name",
			formField:'<input type="search" name="inquiries_name" id="inquiries_name" value="#htmleditformat(application.zcore.functions.zso(form, 'inquiries_name'))#"> ',
			field:"inquiries_first_name",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Email",
			formField:'<input type="text" name="search_email" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_email')#" /> ',
			field:"search_email",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Phone",
			formField:'<input type="text" name="search_phone" style="min-width:200px; width:200px;" value="#application.zcore.functions.zso(form, 'search_phone')#" />',
			field:"search_phone",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Type",
			formField:typeField,
			field:"inquiries_type_id",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"Status",
			formField:statusField,
			field:"inquiries_status_id",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		}]
	});
	arrayAppend(rs.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Start",
			formField:'<input type="date" name="inquiries_start_date" value="#dateformat(form.inquiries_start_date, 'yyyy-mm-dd')#">',
			field:"",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"End",
			formField:'<input type="date" name="inquiries_end_date" value="#dateformat(form.inquiries_end_date, 'yyyy-mm-dd')#">',
			field:"",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		}]
	});

	arrOffice=application.zcore.user.getOfficesByOfficeIdList(request.zsession.user.office_id, request.zos.globals.id); 
	if(application.zcore.user.checkGroupAccess("administrator") or arrayLen(arrOffice)){
		savecontent variable="officeField"{
			selectStruct = StructNew();
			selectStruct.name = "search_office_id"; 
			selectStruct.arrData = arrOffice;
			selectStruct.size=3; 
			selectStruct.queryLabelField = "office_name";
			selectStruct.inlineStyle="width:100%; max-width:100%;";
			selectStruct.queryValueField = 'office_id';

			if(arrayLen(arrOffice) GT 3){
				echo('Office:<br>
					Type to filter offices: <input type="text" name="#selectStruct.name#_InputField" id="#selectStruct.name#_InputField" value="" style="min-width:auto;width:200px; max-width:100%; margin-bottom:5px;"><br />Select Office:<br>');
				application.zcore.functions.zInputSelectBox(selectStruct);
		   		application.zcore.skin.addDeferredScript("  $('###selectStruct.name#').filterByText($('###selectStruct.name#_InputField'), true); ");
	   		}else{
	   			selectStruct.size=1;
				echo('<div style="width:60px; float:left;">Office:</div><div style="width:200px;float:left;">');
				application.zcore.functions.zInputSelectBox(selectStruct);
				echo('</div>');
	   		}
	   	}
		arrayAppend(rs.searchFields, { 
			groupStyle:'width:280px; max-width:100%; ',
			fields:[ { label:"", formField:officeField, field:'search_office_id'} ] 
		});
	}

	if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
		user_group_id = userGroupCom.getGroupId('agent',request.zos.globals.id);
		db.sql="SELECT user_id, user_username, member_company, user_first_name, user_last_name, site_id, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL('user.site_id'))# as siteIdType 
		FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))#  
		 and (user_server_administrator=#db.param(0)# ) and 
		 user_deleted = #db.param(0)#
		ORDER BY member_first_name ASC, member_last_name ASC";
		qAgents=db.execute("qAgents");
		savecontent variable="userField"{
			echo('<script type="text/javascript">
			/* <![CDATA[ */
			var agentSiteIdTypeLookup=[];')
			loop query="qAgents"{
				if(qAgents.site_id EQ request.zos.globals.id){
					echo(' agentSiteIdTypeLookup.push("1"); ');
				}else{
					echo(' agentSiteIdTypeLookup.push("2"); ');
				}
			}
			echo('
			/* ]]> */
			</script>
			Assignee:<br>Type to filter assignees: '); 
			selectStruct = StructNew();
			selectStruct.name = "uid";
			echo('<input type="text" name="#selectStruct.name#_InputField" id="#selectStruct.name#_InputField" value="" style="min-width:auto;width:200px; max-width:100%; margin-bottom:5px;"><br />Select assigness:<br>');
			form.user_id=form.uid; 
			selectStruct.query = qAgents;
			selectStruct.size=3;
			selectStruct.selectedValues=form.user_id;
			selectStruct.queryLabelField = "##user_first_name## ##user_last_name## / ##user_username## / ##member_company##";
			selectStruct.queryParseLabelVars = true;
			selectStruct.queryParseValueVars = true; 
			selectStruct.inlineStyle="width:100%; max-width:100%;";
			selectStruct.queryValueField = '##user_id##|##siteIdType##';
			application.zcore.functions.zInputSelectBox(selectStruct);
	   		application.zcore.skin.addDeferredScript("  $('###selectStruct.name#').filterByText($('###selectStruct.name#_InputField'), true); ");
	   	}
		arrayAppend(rs.searchFields, { 
			groupStyle:'width:280px; max-width:100%; ',
			fields:[ { label:"", formField:userField, field:'uid'}]
		});
	} 
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
		if(form.method EQ "index"){
			echo('<a href="/z/inquiries/admin/feedback/view?inquiries_id=#row.inquiries_id#&amp;zPageId=#form.zPageId#">#row.inquiries_first_name# #row.inquiries_last_name#</a>');
		}else{
			echo('<a href="/z/inquiries/admin/manage-inquiries/userView?inquiries_id=#row.inquiries_id#&amp;zPageId=#form.zPageId#">#row.inquiries_first_name# #row.inquiries_last_name#</a>');
		}
	}
	arrayAppend(columns, {field: field});
 
	arrayAppend(columns, {field: row.inquiries_phone1});  
	savecontent variable="field"{
		if(row.inquiries_assign_email NEQ ''){

			arrEmail=listToArray(row.inquiries_assign_email, ",");
			for(i=1;i<=arraylen(arrEmail);i++){
				e=arrEmail[i];
				if(i NEQ 1){
					echo(', '); 
				}
				echo('<a href="mailto:#e#">');
				if(row.inquiries_assign_name neq '' and arraylen(arrEmail) EQ 1){
					echo(row.inquiries_assign_name);
				}else{
					echo(e);
				}
				echo('</a> ');
			}
		}else{
			if(row.user_id NEQ 0){
				echo('<a href="mailto:#row.user_username#">');
				if(row.user_first_name NEQ ""){
					echo('#row.user_first_name# #row.user_last_name# ');
				}
				if(row.member_company NEQ ""){
					echo('(#row.member_company#)');
				}
				if(row.member_company EQ "" and row.user_first_name EQ ""){
					echo(row.user_username);
				}
				echo('</a>');
			}
			if(application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1){
				if(structkeyexists(variables.officeLookup, row.office_id)){
					echo('<br>'&variables.officeLookup[row.office_id].office_name);
				}
			}
		}
	}
	arrayAppend(columns, {field: field});  
	arrayAppend(columns, {field: row.inquiries_priority});  
	savecontent variable="field"{
		echo(variables.statusName[row.inquiries_status_id]);
		if(row.inquiries_spam EQ 1){
			echo(', <strong>Marked as Spam</strong>');
		}
	}
	arrayAppend(columns, {field: field});  
	arrayAppend(columns, {field: DateFormat(row.inquiries_datetime, "m/d/yy")&" "&TimeFormat(row.inquiries_datetime, "h:mm tt")}); 
	arrayAppend(columns, {field: DateFormat(row.inquiries_updated_datetime, "m/d/yy")&" "&TimeFormat(row.inquiries_updated_datetime, "h:mm tt")}); 
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
	if(form.method EQ "index" or form.method EQ "update" or form.method EQ "insert"){
		arrayAppend(adminButtons, {
			title:"View",
			icon:"eye",
			link:'/z/inquiries/admin/feedback/view?inquiries_id=#row.inquiries_id#&amp;zPageId=#form.zPageId#',
			label:""
		}); 

		if(row.inquiries_readonly EQ 1){
			// Edit Disabled
		}else{
			arrayAppend(adminButtons, {
				title:"Edit",
				icon:"cog",
				link:variables.prefixURL&"edit?inquiries_id=#row.inquiries_id#&modalpopforced=1",
				label:"",
				enableEditAjax:true // only possible for the link that replaces the current row
			});
		}
		if(structkeyexists(request.zos.userSession.groupAccess, "administrator") or structkeyexists(request.zos.userSession.groupAccess, "manager")){
			if(row.inquiries_status_id NEQ 4 and row.inquiries_status_id NEQ 5 and row.inquiries_status_id NEQ 7 and row.inquiries_status_id NEQ 8){

				arrayAppend(adminButtons, {
					title:"Assign Lead",
					icon:"mail-forward",
					link:"/z/inquiries/admin/assign/index?inquiries_id=#row.inquiries_id#&amp;zPageId=#form.zPageId#",
					label:"Assign"
				}); 
			}
		}

	}else{
		arrayAppend(adminButtons, {
			title:"View",
			icon:"eye",
			link:'/z/inquiries/admin/manage-inquiries/userView?inquiries_id=#row.inquiries_id#&amp;zPageId=#form.zPageId#',
			label:""
		}); 
		if(application.zcore.functions.zso(request.zos.globals, 'enableUserAssign', true, 0) NEQ ""){

			arrayAppend(adminButtons, {
				title:"Assign Lead",
				icon:"mail-forward",
				link:"/z/inquiries/admin/assign/userIndex?inquiries_id=#row.inquiries_id#&amp;zPageId=#form.zPageId#",
				label:"Assign"
			});  
		}

	} 
	savecontent variable="field"{
		ts={
			buttons:adminButtons
		}; 
		displayAdminMenu(ts);

	}
	arrayAppend(columns, {field: field, class:"z-manager-admin", style:"width:200px; max-width:100%;"});
	</cfscript> 
</cffunction>

<cffunction name="userInquiryTokenSearch" localmode="modern" access="remote" roles="user">
	<cfscript>
	inquiryTokenSearch();
	</cfscript>
</cffunction>

<!--- 
this was a previous way to use tokenize server-side, but it is not used currently.  it would reduce the initial bandwidth, but increase server load for searching
<cffunction name="inquiryTokenSearch" localmode="modern" access="remote" roles="member">
	<cfscript>
	form.search = application.zcore.functions.zso( form, 'search' );
	form.start = application.zcore.functions.zso( form, 'start', true, 0 );

	var db = request.zos.queryObject;

	userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# 
	WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
	user_deleted = #db.param(0)# and ";
	if(form.start EQ 1){
		db.sql&=" ( user_email like #db.param(form.search&"%")# or concat(user_first_name, #db.param(" ")#, user_last_name) like #db.param(form.search&"%")# ) ";
	}else{
		db.sql&=" concat(user_first_name, user_last_name, user_email) like #db.param("%"&form.search&"%")# ";
	}
	if(form.method EQ "userInquiryTokenSearch"){
		// grab all the people in the offices this user has access to,  of if office disabled, only themselves.
		//db.sql&=" user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# ";
	}
	db.sql&=" and (user_server_administrator=#db.param(0)# )
	ORDER BY member_first_name ASC, member_last_name ASC ";
	qAgents=db.execute("qAgents");

	response = [];

	for ( row in qAgents ) { 
		arrayAppend( response, { text: row.user_email, value: row.user_email } ); 
	}

	echo( serializeJSON( response ) );
	abort;
	</cfscript>
</cffunction> --->

</cfoutput>
</cfcomponent>
