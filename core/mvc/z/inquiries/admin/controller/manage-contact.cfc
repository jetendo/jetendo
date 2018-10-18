<cfcomponent extends="zcorerootmapping.com.app.manager-base">
<cfoutput>   
<cffunction name="getQuickLinks" localmode="modern" access="public">
	<cfscript>
	if(form.method EQ "userViewContact"){
		variables.inquiriesCom.userInit();
	}else if(structkeyexists(variables.inquiriesCom, 'init')){
		variables.inquiriesCom.init();
	}
	return variables.inquiriesCom.getQuickLinks();
	</cfscript>
</cffunction>


<cffunction name="getInitConfig" localmode="modern" access="private">
	<cfscript> 
	ts={
		// required 
		customAddMethods:{"addBulk":"insertBulk", "userAddBulk":"userInsertBulk","userAdd":"userInsert"},
		customEditMethods:{"userEdit":"userUpdate"},
		label:"Contact",
		pluralLabel:"Contacts",
		tableName:"contact",
		addListInsertPosition:"top",
		datasource:request.zos.zcoreDatasource,
		deletedField:"contact_deleted",
		primaryKeyField:"contact_id",
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
		editFormOverrideParams:[],
		customInsertUpdate:false, // true disables the normal zInsert/zUpdate calls, so you can implement them in afterInsert and afterUpdate instead
		sortField:"",
		hasSiteId:true,
		rowSortingEnabled:false,
		metaField:"",
		quickLinks:[],
		imageLibraryFields:[],
		validateFields:{
			//"contact_first_name":{	required:true }
		},
		imageFields:[],
		fileFields:[],
		// optional
		pagination:true,
		paginationIndex:"zIndex",
		pageZSID:"zPageId",
		perpage:30,
		title:"Contacts",
		requireFeatureAccess="Leads",
		prefixURL:"/z/inquiries/admin/manage-contact/",
		navLinks:[],
		titleLinks:[],
		columnSortingEnabled:true,
		columns:[{
			fields:[{
				label:'First',
				field:'contact_first_name',
				sortable:true
			},{
				label:" / "
			},{
				label:"Last",
				field:'contact_last_name',
				sortable:true
			},{
				label:" Name"
			}]
		},{
			label:'Company',
			field:'contact_company',
			sortable:true
		},{
			label:'Email',
			field:'contact_email',
			sortable:true
		},{
			label:'Phone'
		},{
			label:'City',
			field:'contact_city',
			sortable:true
		},{
			label:'Last Updated',
			field:'contact_datetime',
			sortable:true
		},{
			label:'Admin'
		}]
	};
	if(form.method EQ "userInsertBulk" or form.method EQ "insertBulk"){
		variables.methods.beforeReturnInsertUpdate = 'beforeReturnInsertUpdate';
	}
	variables.inquiriesCom=createObject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
	
	return ts;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="private">
	<cfscript> 
	ts=getInitConfig();
	ts.quickLinks=getQuickLinks();
	ts.requireFeatureAccess="Leads";
	super.init(ts); 

	if(request.cgi_script_name CONTAINS "/z/inquiries/admin/manage-contact/"){
		hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		hCom.displayHeader();
	}
	</cfscript>
</cffunction>	 

<cffunction name="userInit" localmode="modern" access="public">
	<cfscript>
	ts=getInitConfig(); 
	ts.disableAddButton=true;
 
	arrayAppend(ts.titleLinks, { 
			label:"Add",
			link:"/z/inquiries/admin/manage-contact/userAdd?modalpopforced=1",
			onclick:"zTableRecordAdd(this, 'sortRowTable', 'top'); return false;"
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
	if(not structkeyexists(request, 'manageLeadUserGroupStruct')){
		request.manageLeadUserGroupStruct={};
	}
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");

	found=false;
	groupStruct={};
	
	userGroupCom=createobject("component", "zcorerootmapping.com.user.user_group_admin"); 
	for(i in request.manageLeadUserGroupStruct){
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
	request.userIdList="";  
	if(structcount(groupStruct) NEQ 0){
		groupIdList=structkeylist(groupStruct);
		// build a userIdList of user that belong to request.zsession.user.office_id and the user groups this user can manage 
		request.userIdList=getUserIdListByOfficeIdListAndGroupIdList(request.zsession.user.office_id, groupIdList); 
	}  
	if(application.zcore.functions.zso(form, 'contact_id', true) NEQ 0){
		if(not userHasAccessToContact(form.contact_id)){
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

<cffunction name="userHasAccessToContact" localmode="modern" access="public" roles="user">
	<cfargument name="contact_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	if(not structkeyexists(request.zsession, 'user')){
		return false;
	}
	contactFilter=variables.inquiriesCom.getContactLeadFilterSQL(db); 
	db.sql="select contact.contact_id 
	FROM #db.table("contact", request.zos.zcoreDatasource)# 
	#db.trustedSQL(contactFilter.leftJoinSQL)#
	WHERE #db.trustedSQL(contactFilter.whereSQL)# 
	contact_deleted=#db.param(0)# and 
	contact.site_id = #db.param(request.zos.globals.id)# and 
	contact.contact_id = #db.param(arguments.contact_id)# 
	GROUP BY contact.contact_id ";
	qCheckLead=db.execute("qCheckLead"); 
	if(qCheckLead.recordcount GT 0){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<cffunction name="userIndex" localmode="modern" access="remote" roles="user">
	<cfscript>
	userInit();
	index();
	</cfscript>
	
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
	if(not request.zos.istestserver){
		echo("Managing contacts is not implemented yet. All the information should be in the lead. Please go back.");
		abort;
	}
 	init();
	super.index();
	</cfscript>
</cffunction> 

<cffunction name="executeDelete" localmode="modern" access="private">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss; 
	application.zcore.functions.z404("Delete is disabled");
	var db=request.zos.queryObject; 
	/*
	db.sql="DELETE FROM #db.table("contact", variables.datasource)#  
	WHERE contact_id= #db.param(application.zcore.functions.zso(form, 'contact_id'))# and 
	contact_deleted = #db.param(0)# and 
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
 
 	/*if(form.contact_email EQ "" and form.contact_phone1 EQ ""){
 		return {success:false, errorMessage:"Email and/or phone are required."};
 	}*/
	if(form.method EQ "insert" or form.method EQ "userInsert"){
		form.contact_datetime=request.zos.mysqlnow;
	}
	form.contact_parent_id=0;

	form.office_id=application.zcore.functions.zso(form, 'office_id', true);
	if(application.zcore.user.checkGroupAccess("administrator")){
		// allow posted office
	}else if(application.zcore.user.checkGroupAccess("agent")){
		arrOffice=listToArray(request.zsession.user.office_id, ",");
		found=false;
		for(officeId in arrOffice){
			if(form.office_id EQ officeId){
				found=true;
				break;
			}
		}
		if(not found){
			return {success:false, errorMessage:"You don't have access to the selected office."};
		}
	}else{
		if(not structkeyexists(request.zsession, 'selectedOfficeId')){
			request.zsession.selectedOfficeId=listGetAt(request.zsession.user.office_id, 1, ",");
		}
		form.office_id=request.zsession.selectedOfficeId;
		if(form.office_id EQ 0){
			return {success:false, errorMessage:"You don't have access to any offices so you can't create a contact."};
		}
	}
	if(form.office_id EQ 0){
		// no office selected
	}else{
		ts={
			ids:[form.office_id]
		};
		arrOffice=application.zcore.user.getOffices(ts);
		if(arrayLen(arrOffice) EQ 0){
			return {success:false, errorMessage:"Selected office is missing."};
		}
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
	db.sql="SELECT * FROM #db.table("contact", request.zos.zcoreDatasource)#
	WHERE contact_deleted = #db.param(0)# and  
	contact_id=#db.param(form.contact_id)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	qData=db.execute("qData");
	return {success:true, qData:qData};
	</cfscript>
</cffunction>



<cffunction name="afterInsert" localmode="modern" access="private" returntype="struct">
	<cfscript>
	rs=afterUpdate();
	return rs;
	</cfscript>
</cffunction>

<cffunction name="afterUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	db=request.zos.queryObject;

	contactCom=createObject("component", "zcorerootmapping.com.app.contact");
	if(application.zcore.user.checkGroupAccess("administrator") and form.contact_assigned_user_id NEQ ""){
		arr = listToArray(form.contact_assigned_user_id, "|");
		userId  				= arr[1];
		userSiteId	= arr[2];
	}else{
		userId  				= request.zsession.user.id;
    	userSiteId	= request.zsession.user.site_id;
    }	
    user=application.zcore.user.getUserById(userId, userSiteId);
    if(structcount(user) NEQ 0){
	    contact=contactCom.getContactByEmail(user.user_username, trim(user.user_first_name&" "&user.user_last_name), userSiteId);
	    ts={
			contact_id:form.contact_id, // the contact being shared
			accessible_by_contact_id: contact.contact_id, // the user who will have access to the contact
			site_id: request.zos.globals.id
		};
	    contactCom.addContactToContact(ts);
    }
	rs={success:true};
	return rs;
	</cfscript>
</cffunction>

<cffunction name="beforeReturnInsertUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>   
	urlPage = "";
	if(structKeyExists(variables.reverseCustomAddMethods, form.method)){
		urlPage = variables.reverseCustomAddMethods[form.method];
	} else{
		urlPage = form.method;
	}
	var link = "#variables.prefixURL#" & urlPage & "?modalpopforced=0&contact_id=#form.contact_id#&zsid=" & request.zsid;
	if(structkeyexists(form, "contact_assigned_user_id")){
		link &= "&contact_assigned_user_id=" & form.contact_assigned_user_id;
	}
	if(structkeyexists(form, "office_id") AND application.zcore.user.checkGroupAccess("administrator")){
		link &= "&office_id=" & form.office_id;
	}

	return {success:true, id:form[variables.primaryKeyField], redirect:1,redirectLink: link};
	</cfscript>
</cffunction>

<cffunction name="beforeInsert" localmode="modern" access="private" returntype="struct">
	<cfscript> 
		rs = validateInsertUpdate();
		if(not rs.success){
			application.zcore.status.displayReturnJson(request.zsid);
		}
		return {success:true};
	</cfscript>
</cffunction>

<cffunction name="getDeleteData" localmode="modern" access="private">
	<cfscript>
	application.zcore.functions.z404("Delete is disabled");
	/*var db=request.zos.queryObject; 
	rs={};
	db.sql="SELECT * FROM #db.table("contact", request.zos.zcoreDatasource)# 
	WHERE contact_id= #db.param(application.zcore.functions.zso(form,'contact_id'))# and 
	contact_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	rs.qData=db.execute("qData");
	return rs;
	*/
	</cfscript>
</cffunction>

<cffunction name="getEditData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 
	
	contactFilter=variables.inquiriesCom.getContactLeadFilterSQL(db);
			 
	form.contact_id=application.zcore.functions.zso(form, 'contact_id', true);
	rs={};
	db.sql="SELECT * 
	#db.trustedSQL(contactFilter.selectSQL)#
	FROM #db.table("contact", request.zos.zcoreDatasource)#
	#db.trustedSQL(contactFilter.leftJoinSQL)#
	WHERE 
	#db.trustedSQL(contactFilter.whereSQL)#
	contact.site_id =#db.param(request.zos.globals.id)# and 
	contact_deleted = #db.param(0)# and 
	contact.contact_id=#db.param(form.contact_id)# 
	GROUP BY contact.contact_id ";
	rs.qData=db.execute("qData");
 	
	if(form.method EQ 'edit'){
		application.zcore.template.setTag("title","Edit Contact");
	}else{
		application.zcore.template.setTag("title","Add Contact");
	} 
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListReturnData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject;  
 	contactFilter=variables.inquiriesCom.getContactLeadFilterSQL(db);
			 
	db.sql="SELECT * 
	#db.trustedSQL(contactFilter.selectSQL)#
	FROM #db.table("contact", request.zos.zcoreDatasource)#
	#db.trustedSQL(contactFilter.leftJoinSQL)#
	WHERE 
	#db.trustedSQL(contactFilter.whereSQL)# 
	contact.site_id = #db.param(request.zos.globals.id)# and 
	contact_deleted = #db.param(0)# and 
	contact.contact_id=#db.param(form.contact_id)#	
	GROUP BY contact.contact_id ";
	rs={};
	rs.qData=db.execute("qData");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getEditForm" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject; 

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

	savecontent variable="field"{
		echo('<input type="text" name="contact_email" value="#htmleditformat(form.contact_email)#" />');
	}
	arrayAppend(fs, {label:'Email', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_salutation" value="#htmlEditFormat( form.contact_salutation )#" />');
	}
	arrayAppend(fs, {label:'Salutation', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_first_name" value="#htmleditformat(form.contact_first_name)#" />');
	}
	arrayAppend(fs, {label:'First Name', field:field}); 

	savecontent variable="field"{
		echo('<input type="text" name="contact_last_name" value="#htmleditformat(form.contact_last_name)#" />');
	}
	arrayAppend(fs, {label:'Last Name', field:field}); 

	savecontent variable="field"{
		echo('<input type="text" name="contact_suffix" value="#htmlEditFormat( form.contact_suffix )#" />');
	}
	arrayAppend(fs, {label:'Suffix', field:field});


	savecontent variable="field"{
		echo('<input type="text" name="contact_phone1" value="#htmleditformat(form.contact_phone1)#" />');
	}
	arrayAppend(fs, {label:'Phone', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_phone2" value="#htmleditformat(form.contact_phone2)#" />');
	}
	arrayAppend(fs, {label:'Cell Phone', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_phone3" value="#htmleditformat(form.contact_phone3)#" />');
	}
	arrayAppend(fs, {label:'Home Phone', field:field});
 
	savecontent variable="field"{
		echo('<input type="text" name="contact_address" value="#htmleditformat(form.contact_address)#" />');
	}
	arrayAppend(fs, {label:'Address', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_city" value="#htmleditformat(form.contact_city)#" />');
	}
	arrayAppend(fs, {label:'City', field:field});

	savecontent variable="field"{
		echo(application.zcore.functions.zStateSelect("contact_state", application.zcore.functions.zso(form,'contact_state')));
	}
	arrayAppend(fs, {label:'State', field:field});

	savecontent variable="field"{
		echo(application.zcore.functions.zCountrySelect("contact_country", application.zcore.functions.zso(form,'contact_country')));
	}
	arrayAppend(fs, {label:'Country', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_postal_code" value="#htmleditformat(form.contact_postal_code)#" />');
	}
	arrayAppend(fs, {label:'Postal Code', field:field});
  
	// add more fields here
	savecontent variable="field"{
		echo('<input type="text" name="contact_company" value="#htmlEditFormat( form.contact_company )#" />');
	}
	arrayAppend(fs, {label:'Company', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_job_title" value="#htmlEditFormat( form.contact_job_title )#" />');
	}
	arrayAppend(fs, {label:'Job Title', field:field});

	savecontent variable="field"{
		echo( application.zcore.functions.zDateSelect( 'contact_birthday', 'contact_birthday', 1900, year( now() ), form.contact_birthday, false, true ) );
	}
	arrayAppend(fs, {label:'Birthday', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_spouse_first_name" value="#htmlEditFormat( form.contact_spouse_first_name )#" />');
	}
	arrayAppend(fs, {label:'Spouse First Name', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_spouse_suffix" value="#htmlEditFormat( form.contact_spouse_suffix )#" />');
	}
	arrayAppend(fs, {label:'Spouse Suffix', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_spouse_job_title" value="#htmlEditFormat( form.contact_spouse_job_title )#" />');
	}
	arrayAppend(fs, {label:'Spouse Job Title', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interests" value="#htmlEditFormat( form.contact_interests )#" />');
	}
	arrayAppend(fs, {label:'Interests', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_type" value="#htmlEditFormat( form.contact_interested_in_type )#" />');
	}
	arrayAppend(fs, {label:'Interested In Type', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_year" value="#htmlEditFormat( form.contact_interested_in_year )#" />');
	}
	arrayAppend(fs, {label:'Interested In Year', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_make" value="#htmlEditFormat( form.contact_interested_in_make )#" />');
	}
	arrayAppend(fs, {label:'Interested In Make', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_model" value="#htmlEditFormat( form.contact_interested_in_model )#" />');
	}
	arrayAppend(fs, {label:'Interested In Model', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_category" value="#htmlEditFormat( form.contact_interested_in_category )#" />');
	}
	arrayAppend(fs, {label:'Interested In Category', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_name" value="#htmlEditFormat( form.contact_interested_in_name )#" />');
	}
	arrayAppend(fs, {label:'Interested In Name', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_hin_vin" value="#htmlEditFormat( form.contact_interested_in_hin_vin )#" />');
	}
	arrayAppend(fs, {label:'Interested In Hin Vin', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_stock" value="#htmlEditFormat( form.contact_interested_in_stock )#" />');
	}
	arrayAppend(fs, {label:'Interested In Stock', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_length" value="#htmlEditFormat( form.contact_interested_in_length )#" />');
	}
	arrayAppend(fs, {label:'Interested In Length', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_currently_owned_type" value="#htmlEditFormat( form.contact_interested_in_currently_owned_type )#" />');
	}
	arrayAppend(fs, {label:'Interested In Currently Owned Type', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_read" value="#htmlEditFormat( form.contact_interested_in_read )#" />');
	}
	arrayAppend(fs, {label:'Interested In Read', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_age" value="#htmlEditFormat( form.contact_interested_in_age )#" />');
	}
	arrayAppend(fs, {label:'Interested In Age', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_bounce_reason" value="#htmlEditFormat( form.contact_interested_in_bounce_reason )#" />');
	}
	arrayAppend(fs, {label:'Interested In Bounce Reason', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_home_phone" value="#htmlEditFormat( form.contact_interested_in_home_phone )#" />');
	}
	arrayAppend(fs, {label:'Interested In Home Phone', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_work_phone" value="#htmlEditFormat( form.contact_interested_in_work_phone )#" />');
	}
	arrayAppend(fs, {label:'Interested In Work Phone', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_mobile_phone" value="#htmlEditFormat( form.contact_interested_in_mobile_phone )#" />');
	}
	arrayAppend(fs, {label:'Interested In Mobile Phone', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_fax" value="#htmlEditFormat( form.contact_interested_in_fax )#" />');
	}
	arrayAppend(fs, {label:'Interested In Fax', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_buying_horizon" value="#htmlEditFormat( form.contact_interested_in_buying_horizon )#" />');
	}
	arrayAppend(fs, {label:'Interested In Buying Horizon', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_status" value="#htmlEditFormat( form.contact_interested_in_status )#" />');
	}
	arrayAppend(fs, {label:'Interested In Status', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_interest_level" value="#htmlEditFormat( form.contact_interested_in_interest_level )#" />');
	}
	arrayAppend(fs, {label:'Interested In Interest Level', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_sales_stage" value="#htmlEditFormat( form.contact_interested_in_sales_stage )#" />');
	}
	arrayAppend(fs, {label:'Interested In Sales Stage', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_contact_source" value="#htmlEditFormat( form.contact_interested_in_contact_source )#" />');
	}
	arrayAppend(fs, {label:'Interested In Contact Source', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_dealership" value="#htmlEditFormat( form.contact_interested_in_dealership )#" />');
	}
	arrayAppend(fs, {label:'Interested In Dealership', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="contact_interested_in_assigned_to" value="#htmlEditFormat( form.contact_interested_in_assigned_to )#" />');
	}
	arrayAppend(fs, {label:'Interested In Assigned To', field:field});

	savecontent variable="field"{
		if ( form.contact_interested_in_bounced_email EQ '' ) {
			form.contact_interested_in_bounced_email = 0;
		}
		echo( application.zcore.functions.zInput_Boolean( 'contact_interested_in_bounced_email', application.zcore.functions.zso( form, 'contact_interested_in_bounced_email' ) ) );
	}
	arrayAppend(fs, {label:'Interested In Bounced Email', field:field});

	savecontent variable="field"{
		if ( form.contact_interested_in_owners_magazine EQ '' ) {
			form.contact_interested_in_owners_magazine = 0;
		}
		echo( application.zcore.functions.zInput_Boolean( 'contact_interested_in_owners_magazine', application.zcore.functions.zso( form, 'contact_interested_in_owners_magazine' ) ) );
	}
	arrayAppend(fs, {label:'Interested In Owners Magazine', field:field});

	savecontent variable="field"{
		if ( form.contact_interested_in_purchased EQ '' ) {
			form.contact_interested_in_purchased = 0;
		}
		echo( application.zcore.functions.zInput_Boolean( 'contact_interested_in_purchased', application.zcore.functions.zso( form, 'contact_interested_in_purchased' ) ) );
	}
	arrayAppend(fs, {label:'Interested In Purchased', field:field});

	savecontent variable="field"{
		echo( application.zcore.functions.zDateSelect( 'contact_interested_in_service_date', 'contact_interested_in_service_date', 1900, ( year( now() ) + 1 ), form.contact_interested_in_service_date, false, true ) );
	}
	arrayAppend(fs, {label:'Interested In Service Date', field:field});

	savecontent variable="field"{
		echo( application.zcore.functions.zDateSelect( 'contact_interested_in_date_delivered', 'contact_interested_in_date_delivered', 1900, ( year( now() ) + 1 ), form.contact_interested_in_date_delivered, false, true ) );
	}
	arrayAppend(fs, {label:'Interested In Date Delivered', field:field});

	savecontent variable="field"{
		echo( application.zcore.functions.zDateSelect( 'contact_interested_in_date_sold', 'contact_interested_in_date_sold', 1900, ( year( now() ) + 1 ), form.contact_interested_in_date_sold, false, true ) );
	}
	arrayAppend(fs, {label:'Interested In Date Sold', field:field});

	savecontent variable="field"{
		echo( application.zcore.functions.zDateSelect( 'contact_interested_in_warranty_date', 'contact_interested_in_warranty_date', 1900, ( year( now() ) + 1 ), form.contact_interested_in_warranty_date, false, true ) );
	}
	arrayAppend(fs, {label:'Interested In Warranty Date', field:field});

	savecontent variable="field"{
		echo('<textarea name="contact_interested_in_lead_comments" cols="100" rows="10">#htmlEditFormat( form.contact_interested_in_lead_comments )#</textarea>');
	}
	arrayAppend(fs, {label:'Interested In Lead Comments', field:field});

	var assignCom = createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.assign");
	savecontent variable="field"{   
		assignCom.getAssignContact();
	}
	arrayAppend(fs, {label:'Assign To', field:field});

	rs.tabs.basic.fields=fs;
	// advanced fields
	/*
	fs=[];
	savecontent variable="field"{
		echo('<input type="text" name="contact_advanced" value="#htmleditformat(form.contact_advanced)#" />');
	}
	arrayAppend(fs, {label:'Advanced Field', field:field});

	rs.tabs.advanced.fields=fs; 
	*/

	return rs;
	</cfscript>  
</cffunction>

<cffunction name="getListData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 
	rs={};

	form.search_office_id=application.zcore.functions.zso(form, 'search_office_id', true, "0");
	if(application.zcore.functions.zso(request.zsession, "selectedofficeid", true, 0) NEQ 0){
		form.search_office_id=request.zsession.selectedofficeid;
	} 
	form.search_email=application.zcore.functions.zso(form, 'search_email');
	form.search_phone=application.zcore.functions.zso(form, 'search_phone');
	form.contact_status_id=application.zcore.functions.zso(form, 'contact_status_id');
	form.selected_contact_id=application.zcore.functions.zso(form, 'cid', true);
	if(structkeyexists(form, 'leadcontactfilter')){
		request.zsession.leadcontactfilter=form.leadcontactfilter;		
	}else if(isDefined('request.zsession.leadcontactfilter') EQ false){
		request.zsession.leadcontactfilter='all';
	}
	if(structkeyexists(form, 'grouping')){
		request.zsession.leademailgrouping=form.grouping;
	}else if(structkeyexists(request.zsession, 'leademailgrouping') EQ false){
		request.zsession.leademailgrouping='0';
	}
	/*if(structkeyexists(form, 'viewspam')){
		request.zsession.leadviewspam=form.viewspam;
	}else if(not structkeyexists(request.zsession, 'leadviewspam')){*/
		request.zsession.leadviewspam=0;	
	//}

	contactFilter=variables.inquiriesCom.getContactLeadFilterSQL(db);
			
			
			

 
	db.sql="select min(contact_datetime) as contact_datetime  
	from (#db.table("contact", request.zos.zcoreDatasource)# ";
	if(application.zcore.user.checkGroupAccess("administrator")){
		if(form.selected_contact_id NEQ '0'){
			db.sql&=", #db.table("contact_x_contact", request.zos.zcoreDatasource)# ";
		}
	}
	db.sql&=" ) 
	#db.trustedSQL(contactFilter.leftJoinSQL)#  
	WHERE 
	contact.site_id = #db.param(request.zos.globals.id)# and  
	contact_parent_id = #db.param(0)# and 
	contact_deleted = #db.param(0)# 
	#db.trustedSQL(contactFilter.whereSQL)#
	";
	if(application.zcore.user.checkGroupAccess("administrator")){
		if(form.selected_contact_id NEQ '0'){
			db.sql&=" and 
			contact_x_contact_accessible_by_contact_id = #db.param(form.selected_contact_id)# and 
			contact_x_contact.contact_id = contact.contact_id and 
			contact_x_contact_deleted=#db.param(0)# and 
			contact_x_contact.site_id = contact.site_id  ";
		}
	}
	db.sql&=" GROUP BY contact.contact_id ";
	variables.qinquiriesFirst=db.execute("qinquiriesFirst"); 

	if(isnull(variables.qinquiriesFirst.contact_datetime) EQ false and isdate(variables.qinquiriesFirst.contact_datetime)){
		variables.inquiryFirstDate=variables.qinquiriesFirst.contact_datetime;
	}else{
		variables.inquiryFirstDate=dateFormat(now(), "yyyy-mm-dd")&" 00:00:00";
	}
	if(not structkeyexists(form, 'contact_start_date') or not isdate(form.contact_start_date)){  
		form.contact_start_date = "";
		form.contact_end_date = "";
	}
	if(IsDate(form.contact_start_date)){
		if(datediff("d",form.contact_start_date, variables.inquiryFirstDate) GT 0)
			form.contact_start_date=variables.inquiryFirstDate;
	}
	if(IsDate(form.contact_end_date) ){
		if(dateCompare(form.contact_start_date, form.contact_end_date) EQ 1)
			form.contact_end_date = form.contact_start_date;
	} 
 
			
			 
	db.sql="SELECT *, 
	contact.contact_id maxid, contact_datetime maxdatetime 
	#db.trustedSQL(contactFilter.selectSQL)# 
	FROM ( #db.table("contact", request.zos.zcoreDatasource)# ";
	if(application.zcore.user.checkGroupAccess("administrator")){
		if(form.selected_contact_id NEQ '0'){
			db.sql&=", #db.table("contact_x_contact", request.zos.zcoreDatasource)# ";
		}
	}
	db.sql&=" )
	#db.trustedSQL(contactFilter.leftJoinSQL)#
	WHERE 
	#db.trustedSQL(contactFilter.whereSQL)#
	contact_deleted = #db.param(0)# and 
	contact.site_id = #db.param(request.zos.globals.id)# 
	";
	if(application.zcore.user.checkGroupAccess("administrator")){
		if(form.selected_contact_id NEQ '0'){
			db.sql&=" and 
			contact_x_contact_accessible_by_contact_id = #db.param(form.selected_contact_id)# and 
			contact_x_contact.contact_id = contact.contact_id and 
			contact_x_contact_deleted=#db.param(0)# and 
			contact_x_contact.site_id = contact.site_id  ";
		}
	} 
	if(form.search_phone NEQ ""){
		db.sql&=" and contact.contact_phone1 like #db.param("%"&form.search_phone&"%")# ";
	}
	if(form.search_email NEQ ""){
		db.sql&=" and contact.contact_email like #db.param("%"&form.search_email&"%")# ";
	}
	if(form.search_office_id NEQ "0"){
		db.sql&=" and contact.office_id = #db.param(form.search_office_id)# ";
	}
 
	if(form.contact_start_date NEQ "" AND form.contact_end_date NEQ ""){
		db.sql&=" and (contact_datetime >= #db.param(dateformat(form.contact_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
		contact_datetime <= #db.param(dateformat(form.contact_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
	}
	if(application.zcore.functions.zso(form, 'contact_name') NEQ ""){
		db.sql&=" and concat(contact_first_name, #db.param(" ")#, contact_last_name) LIKE #db.param('%#form.contact_name#%')# ";
	}
	sortColumnSQL=getSortColumnSQL();
	db.sql&=" GROUP BY contact.contact_id ";
	if(sortColumnSQL NEQ ''){
		db.sql&=" ORDER BY #sortColumnSQL# contact.contact_id ASC";
	} else{
		db.sql&=" ORDER BY maxdatetime DESC ";
	}
	db.sql&=" LIMIT #db.param(max(0,(form.zIndex-1))*30)#,#db.param(30)#";

	rs.qData=db.execute("qData");   
			 
	db.sql="SELECT count(*) COUNT 
	from ( #db.table("contact", request.zos.zcoreDatasource)# ";
	if(application.zcore.user.checkGroupAccess("administrator")){
		if(form.selected_contact_id NEQ '0'){
			db.sql&=", #db.table("contact_x_contact", request.zos.zcoreDatasource)# ";
		}
	}
	db.sql&=" )
	#db.trustedSQL(contactFilter.leftJoinSQL)#
	WHERE 
	#db.trustedSQL(contactFilter.whereSQL)#
	contact.site_id = #db.param(request.zos.globals.id)# 
	";
	if(application.zcore.user.checkGroupAccess("administrator")){
		if(form.selected_contact_id NEQ '0'){
			db.sql&=" and 
			contact_x_contact_accessible_by_contact_id = #db.param(form.selected_contact_id)# and 
			contact_x_contact.contact_id = contact.contact_id and 
			contact_x_contact_deleted=#db.param(0)# and 
			contact_x_contact.site_id = contact.site_id  ";
		}
	}
	db.sql&=" and contact_deleted = #db.param(0)# and contact_parent_id = #db.param(0)# "; 
	if(form.search_office_id NEQ "0"){
		db.sql&=" and contact.office_id = #db.param(form.search_office_id)# ";
	}
	if(form.search_phone NEQ ""){
		db.sql&=" and contact.contact_phone1 like #db.param("%"&form.search_phone&"%")# ";
	}
	if(form.search_email NEQ ""){
		db.sql&=" and contact.contact_email like #db.param("%"&form.search_email&"%")# ";
	}
	if(form.contact_start_date NEQ "" AND form.contact_end_date NEQ ""){
		db.sql&=" and (contact_datetime >= #db.param(dateformat(form.contact_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
		contact_datetime <= #db.param(dateformat(form.contact_end_date, "yyyy-mm-dd")&' 23:59:59')#) ";
	}
	if(application.zcore.functions.zso(form, 'contact_name') NEQ ""){
		db.sql&=" and concat(contact_first_name, #db.param(" ")#, contact_last_name) LIKE #db.param('%#form.contact_name#%')#";
	}
	db.sql&=" GROUP BY contact.contact_id ";
	rs.qCount=db.execute("qCount");   
	rs.searchFields=[]; 


	arrayAppend(rs.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Name",
			formField:'<input type="search" name="contact_name" id="contact_name" value="#htmleditformat(application.zcore.functions.zso(form, 'contact_name'))#"> ',
			field:"contact_first_name",
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
		}]
	});
	arrayAppend(rs.searchFields, {
		groupStyle:'width:280px; max-width:100%; ',
		fields:[{
			label:"Start",
			formField:'<input type="date" name="contact_start_date" value="#dateformat(form.contact_start_date, 'yyyy-mm-dd')#">',
			field:"",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		},{
			label:"End",
			formField:'<input type="date" name="contact_end_date" value="#dateformat(form.contact_end_date, 'yyyy-mm-dd')#">',
			field:"",
			labelStyle:'width:60px;',
			fieldStyle:'width:200px;'
		}]
	});

	// TODO: there is code for contact_id search, but no search form element yet.  see manage-inquiries for this code?

	arrOffice=application.zcore.user.getOfficesByOfficeIdList(request.zsession.user.office_id, request.zos.globals.id); 
	if(application.zcore.user.checkGroupAccess("administrator") or arrayLen(arrOffice) GT 1){
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
		db.sql="SELECT contact.contact_id, user_id, user_username, member_company, user_first_name, user_last_name 
		FROM #db.table("user", request.zos.zcoreDatasource)# user, 
		#db.table("contact", request.zos.zcoreDatasource)# 
		WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
		contact.contact_email=user.user_username and 
		contact.site_id = user.site_id and 
		contact_deleted=#db.param(0)# and 
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))#  
		 and (user_server_administrator=#db.param(0)# ) and 
		 user_deleted = #db.param(0)#
		ORDER BY member_first_name ASC, member_last_name ASC";
		qAgents=db.execute("qAgents");
		savecontent variable="contactField"{
			echo('
			Assignee:<br>Type to filter assignees: '); 
			selectStruct = StructNew();
			selectStruct.name = "cid";
			echo('<input type="text" name="#selectStruct.name#_InputField" id="#selectStruct.name#_InputField" value="" style="min-width:auto;width:200px; max-width:100%; margin-bottom:5px;"><br />Select assigness:<br>');
			selectStruct.query = qAgents;
			selectStruct.size=3;
			selectStruct.queryLabelField = "##user_first_name## ##user_last_name## / ##user_username## / ##member_company##";
			selectStruct.queryParseLabelVars = true;
			selectStruct.queryParseValueVars = true; 
			selectStruct.inlineStyle="width:100%; max-width:100%;";
			selectStruct.queryValueField = '##contact_id##';
			application.zcore.functions.zInputSelectBox(selectStruct);
	   		application.zcore.skin.addDeferredScript("  $('###selectStruct.name#').filterByText($('###selectStruct.name#_InputField'), true); ");
	   	}
		arrayAppend(rs.searchFields, { 
			groupStyle:'width:280px; max-width:100%; ',
			fields:[ { label:"", formField:contactField, field:'cid'}]
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
			echo('<a href="/z/inquiries/admin/feedback/viewContact?contactTab=1&contact_id=#row.contact_id#&amp;zPageId=#form.zPageId#">#row.contact_first_name# #row.contact_last_name#</a>');
		}else{
			echo('<a href="/z/inquiries/admin/manage-contact/userView?contact_id=#row.contact_id#&amp;zPageId=#form.zPageId#">#row.contact_first_name# #row.contact_last_name#</a>');
		}
	}
	arrayAppend(columns, {field: field});
 
 	arrayAppend(columns, {field: row.contact_company});
 	arrayAppend(columns, {field: row.contact_email});
	arrayAppend(columns, {field: row.contact_phone1});
	arrayAppend(columns, {field: row.contact_city});
	arrayAppend(columns, {field: application.zcore.functions.zTimeSinceDate(row.contact_updated_datetime)}); 

	adminButtons=[];
	if(form.method EQ "userIndex" or form.method EQ "userUpdate" or form.method EQ "userInsert"){
		arrayAppend(adminButtons, {
			title:"View",
			icon:"eye",
			link:'/z/inquiries/admin/manage-inquiries/userViewContact?contactTab=1&contact_id=#row.contact_id#&amp;zPageId=#form.zPageId#',
			label:""
		}); 

		arrayAppend(adminButtons, {
			title:"Edit",
			icon:"cog",
			link:variables.prefixURL&"userEdit?contact_id=#row.contact_id#&modalpopforced=1",
			label:"",
			enableEditAjax:true // only possible for the link that replaces the current row
		});
	}else if(form.method EQ "index" or form.method EQ "update" or form.method EQ "insert"){
		arrayAppend(adminButtons, {
			title:"View",
			icon:"eye",
			link:'/z/inquiries/admin/feedback/viewContact?contactTab=1&contact_id=#row.contact_id#&amp;zPageId=#form.zPageId#',
			label:""
		}); 

		arrayAppend(adminButtons, {
			title:"Edit",
			icon:"cog",
			link:variables.prefixURL&"edit?contact_id=#row.contact_id#&modalpopforced=1",
			label:"",
			enableEditAjax:true // only possible for the link that replaces the current row
		});
	}else{
		arrayAppend(adminButtons, {
			title:"View",
			icon:"eye",
			link:'/z/inquiries/admin/manage-contact/userView?contact_id=#row.contact_id#&amp;zPageId=#form.zPageId#',
			label:""
		}); 
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

<cffunction name="inquiryTokenSearch" localmode="modern" access="remote">
	<cfscript>
		form.search = application.zcore.functions.zso( form, 'search' );
		form.start = application.zcore.functions.zso( form, 'start', true, 0 );

		var db = request.zos.queryObject;

		userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
		db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
		user_deleted = #db.param(0)# and
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and (user_server_administrator=#db.param(0)# )
		ORDER BY member_first_name ASC, member_last_name ASC ";
		qAgents=db.execute("qAgents");

		response = [];

		for ( row in qAgents ) {
			matches = reMatchNoCase( ( form.start ? '^' : '' ) & form.search, row.user_email );
			if ( arrayLen( matches ) GT 0 ) {
				arrayAppend( response, { text: row.user_email, value: row.user_email } );
			}
		}

		echo( serializeJSON( response ) );
		abort;
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>
