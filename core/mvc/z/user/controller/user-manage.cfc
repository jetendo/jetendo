<cfcomponent>
<cfoutput>
<!--- 
TODO:
sort users within an office instead of entire site.

sub-users can only be assigned to one or more of the offices that the manager user has access to.

finish simplifying this script.
 --->
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	// it's very important this function is called for all features of this file, to avoid a security leak.
	db=request.zos.queryObject;

	if(not application.zcore.user.checkGroupAccess("user")){
		application.zcore.functions.zRedirect("/z/user/preference/index");
	}

	if(request.zsession.user.site_id NEQ request.zos.globals.id){
		// must be a higher rights dev account or multiple site account.  These types of accounts only work in the full site manager interface.
		application.zcore.functions.zRedirect("/z/user/preference/index");
	}
	if(structkeyexists(application.siteStruct[request.zos.globals.id], 'metaCache') and structkeyexists(application.siteStruct[request.zos.globals.id]['metaCache'], 'metaObjectCache') and structkeyexists(application.siteStruct[request.zos.globals.id]['metaCache']['metaObjectCache'], 'user')){
		variables.metaFieldInUse=true;
		variables.metaCom=createObject("component", "zcorerootmapping.com.zos.meta");
	}else{
		variables.metaFieldInUse=false;
	}
 
	db.sql="select * from #db.table("user_group", request.zos.zcoreDatasource)# WHERE 
	user_group_id=#db.param(request.zsession.user.group_id)# and 
	user_group_deleted=#db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	qGroup=db.execute("qGroup"); 


	if(qGroup.recordcount EQ 0){
		throw("Invalid user group id for user: #request.zsession.user.id# group id: #request.zsession.user.group_id#");
	}
	if(qGroup.user_group_manage_full_subuser_group_id_list EQ "" and qGroup.user_group_manage_partial_subuser_group_id_list EQ ""){
		if(application.zcore.user.checkGroupAccess("administrator")){
			application.zcore.functions.zRedirect("/z/admin/member/showPublicUsers");
		}else{
			application.zcore.functions.z404("Access denied for this user group: #qGroup.user_group_name#");
		}
	}
	request.managedGroupStruct={};
	request.managedFullGroupStruct={};
	arrGroup=listToArray(qGroup.user_group_manage_full_subuser_group_id_list, ",");
	for(group in arrGroup){
		request.managedGroupStruct[group]=true;
		request.managedFullGroupStruct[group]=true;
	}
	arrGroup=listToArray(qGroup.user_group_manage_partial_subuser_group_id_list, ",");
	for(group in arrGroup){
		request.managedGroupStruct[group]=true;
	}
	request.managedUserGroupList=structkeylist(request.managedGroupStruct, ",");

	// also use this to restrict which offices in add/edit user
	request.arrLoggedInUserOffice=listToArray(request.zsession.user.office_id, ",");

	request.userOfficeLookupStruct={};
	if(request.zsession.user.office_id NEQ ""){
		db.sql="select * from #db.table("office", request.zos.zcoreDatasource)# 
		WHERE
		office_deleted=#db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		office_id in (#db.trustedSQL(request.zsession.user.office_id)#) 
		ORDER BY office_name ASC";
		request.qLoggedInUserOffices=db.execute("qOffice");
		for(row in request.qLoggedInUserOffices){
			request.userOfficeLookupStruct[row.office_id]=row;
		}
	}
	request.userFullEditAccess=false;
	form.user_id=application.zcore.functions.zso(form, 'user_id', true, 0);
	if(form.user_id NEQ 0){
		request.userStruct=application.zcore.user.getUserById(form.user_id, request.zos.globals.id);

		if(structcount(request.userStruct) EQ 0){
			application.zcore.status.setStatus(request.zsid, "You don't have access to manage this user.", form, true);
			application.zcore.functions.zRedirect("/z/user/user-manage/index?zsid=#request.zsid#");
		}
		// check if this user is in an office this user can manage.
		arrEditedUserOffice=listToArray(request.userStruct.office_id, ",");
		match=false;
		for(office_id in arrEditedUserOffice){
			for(tempOfficeId in request.arrLoggedInUserOffice){
				if(office_id EQ tempOfficeId){
					match=true;
					break;
				}
			}
			if(match){
				break;
			}
		}

		// check if form.user_id's primary user_group_id is in one of the groups this user can manage.
		if(not structkeyexists(request.managedGroupStruct, request.userStruct.user_group_id) or not match){
			application.zcore.status.setStatus(request.zsid, "You don't have access to manage this user.", form, true);
			application.zcore.functions.zRedirect("/z/user/user-manage/index?zsid=#request.zsid#");
		}
		if(structkeyexists(request.managedFullGroupStruct, request.userStruct.user_group_id)){
			request.userFullEditAccess=true; 
		}

	}
	request.userAdminCom=createObject("component", "zcorerootmapping.mvc.z.admin.controller.member");
	
 
	form.zIndex=application.zcore.functions.zso(form,'zIndex',true,1);
	form.ugid=application.zcore.functions.zso(form, 'ugid');
	form.searchtext=trim(application.zcore.functions.zso(form,'searchtext')); 
	form.site_id=request.zos.globals.id; 


	variables.queueSortStruct = StructNew();
	variables.queueSortStruct.tableName = "user";
	variables.queueSortStruct.datasource=request.zos.zcoreDatasource;
	variables.queueSortStruct.sortFieldName = "member_sort";
	variables.queueSortStruct.primaryKeyName = "user_id";
	variables.queueSortStruct.where="user.site_id = '#request.zos.globals.id#'  and 
	member_public_profile='1' and user_deleted='0' ";

	variables.queueSortStruct.ajaxTableId='sortRowTable';
	variables.queueSortStruct.ajaxURL='/z/user/user-manage/index';
	
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	variables.queueSortCom.init(variables.queueSortStruct);
	variables.queueSortCom.returnJson(); 
	
	db.sql="select * FROM #db.table("site", request.zos.zcoreDatasource)# site 
	where site_id <> #db.param(request.zos.globals.id)# and 
	site_deleted = #db.param(0)# and
	site_parent_id = #db.param(request.zos.globals.id)# 
	ORDER BY site_short_domain";
	variables.qPAll323=db.execute("qPAll323");
	</cfscript>
</cffunction>
 

<cffunction name="delete" localmode="modern" access="remote" >
	<cfscript>
	var db=request.zos.queryObject; 
	init();
	db.sql="SELECT *, user.site_id userSiteId FROM #db.table("user", request.zos.zcoreDatasource)# user  
	WHERE user.user_id = #db.param(application.zcore.functions.zso(form,'user_id'))# and 
	user_deleted = #db.param(0)# and 
	site_id =#db.param(request.zos.globals.id)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Member no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/user/user-manage/index?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript> 
		if(qCheck.member_photo NEQ ""){
			application.zcore.functions.zDeleteFile(application.zcore.functions.zVar('privatehomedir',qCheck.userSiteId)&removechars(request.zos.memberImagePath,1,1)&qCheck.member_photo);
		}
		if(variables.metaFieldInUse){
			structappend(form, variables.metaCom.getData("user", form), false); 
			rsDelete=variables.metaCom.delete("user", form); 
			if(not rsDelete.success){
				application.zcore.functions.zReturnJson({success:false, errorMessage:rs.errorMessage});
			}
		}
		db.sql="DELETE FROM #db.table("user", request.zos.zcoreDatasource)#  WHERE 
		user_id = #db.param(qCheck.user_id)# and 
		user_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");
		if(application.zcore.app.siteHasApp("listing")){
			application.zcore.listingCom.updateAgentIdStruct(qCheck.user_id);
		}
		if(structkeyexists(qCheck,'member_public_profile') and qCheck.member_public_profile EQ 1){
			variables.queueSortCom.sortAll();
		}
		application.zcore.status.setStatus(Request.zsid, 'Member deleted');
		application.zcore.functions.zRedirect('/z/user/user-manage/index?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this user?<br />
			<br />
			#qCheck.member_first_name# #qCheck.member_last_name# (#qcheck.member_email#)<br />
			<br />
			<a href="/z/user/user-manage/delete?confirm=1&amp;user_id=#form.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&amp;searchtext=#URLEncodedFormat(form.searchtext)#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/user/user-manage/index?zIndex=#form.zIndex#&amp;ugid=#form.ugid#&amp;searchtext=#URLEncodedFormat(form.searchtext)#">No</a> </div>
	</cfif>
</cffunction>



<cffunction name="insert" localmode="modern" access="remote" >
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" >
	<cfscript>
	var db=request.zos.queryObject; 
	init();
	if(application.zcore.functions.zso(form, 'member_website') EQ "/"){
		form.member_website=request.zos.currentHostName&"/";	
	}
	form.office_id=application.zcore.functions.zso(form, 'office_id');

	error=false;
	arrOffice=listToArray(form.office_id, ",");
	if(form.office_id EQ ""){
		application.zcore.status.setStatus(request.zsid, "You must select one or more offices for this user.", form, true);
		error=true;
	}
	foundValidOfficeId=false;
	for(id in arrOffice){
		if(not isnumeric(id)){
			application.zcore.status.setStatus(request.zsid, "Invalid office id.", form, true);
			error=true;
		}
		// TODO: check for logged in user having access to manage this office
		if(structkeyexists(request.userOfficeLookupStruct, id)){
			foundValidOfficeId=true;
		}
	}
	if(not foundValidOfficeId){
		error=true;
		application.zcore.status.setStatus(request.zsid, "You don't have access to manage one of the selected offices.", form, true);
	}
	if(not error){
		db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# office 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		office_deleted = #db.param(0)# and 
		office_id IN (#db.trustedSQL(arrayToList(arrOffice, ","))#) ";
		qOffice=db.execute("qOffice");

		arrOfficeNew=[];
		for(row in qOffice){
			arrayAppend(arrOfficeNew, row.office_id);
		}
		form.office_id=arrayToList(arrOfficeNew, ",");
	} 
	if(variables.metaFieldInUse){
		arrError=variables.metaCom.validate("user", form);
		if(arrayLen(arrError)){
			error=true;
			for(e in arrError){
				application.zcore.status.setStatus(request.zsid, e, form, true);
			}
		}
	}
	if(error){
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}else{
			application.zcore.functions.zRedirect('/z/user/user-manage/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}
	}

	form.user_invited=application.zcore.functions.zso(form, 'user_invited', true, 0);
	if(form.method EQ "insert" and form.user_invited EQ 1){
		// do nothing
	}else{
		form.member_password=trim(form.member_password);
		form.member_password_confirm=trim(form.member_password_confirm);
		if(form.method EQ "insert"){
			if(form.member_password EQ ""){
				application.zcore.status.setStatus(Request.zsid, "Password is required",form,true);
				if(form.method EQ 'insert'){
					application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}else{
					application.zcore.functions.zRedirect('/z/user/user-manage/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}
			}else if(compare(form.member_password, form.member_password_confirm) NEQ 0){
				application.zcore.status.setStatus(Request.zsid, "Passwords don't match. Please re-enter the password and confirm password fields.",form,true);
				if(form.method EQ 'insert'){
					application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}else{
					application.zcore.functions.zRedirect('/z/user/user-manage/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}
			}
		}else{
			if(trim(form.member_password) NEQ "" and compare(form.member_password, form.member_password_confirm) NEQ 0){
				application.zcore.status.setStatus(Request.zsid, "Passwords don't match. Please re-enter the password and confirm password fields.",form,true);
				if(form.method EQ 'insert'){
					application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}else{
					application.zcore.functions.zRedirect('/z/user/user-manage/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}
			}
		}
	}  
	ts=StructNew();
	ts.member_email.required= true;
	ts.member_email.email=true;
	fail = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);

	arrEmail=listToArray(application.zcore.functions.zso(form, 'user_alternate_email'), ",");
	arrEmail2=[];
	for(i=1;i<=arraylen(arrEmail);i++){
		e=trim(arrEmail[i]);
		if(e NEQ ""){
			if(not application.zcore.functions.zEmailValidate(e)){
				fail=true;
				application.zcore.status.setStatus(Request.zsid, e&" is not a valid email",form,true);
			}else{
				arrayAppend(arrEmail2, e);
			}
		}
	}
	form.user_alternate_email=arrayToList(arrEmail2, ",");
	if(fail){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}else{
			application.zcore.functions.zRedirect('/z/user/user-manage/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}
	}
	if(form.method NEQ 'insert'){
		db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user_id = #db.param(form.user_id)# and 
		user_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qU2=db.execute("qU2");
	}
	form.member_phone=application.zcore.functions.zso(form, 'member_phone');
	structappend(ts,form);

	ts.user_active=application.zcore.functions.zso(form, 'user_active', false, '1');
	ts.user_phone=form.member_phone;
	ts.user_openid_required=0;//application.zcore.functions.zso(form,'user_openid_required',false,0); 
	ts.user_first_name = application.zcore.functions.zso(form,'member_first_name');
	ts.user_last_name = application.zcore.functions.zso(form,'member_last_name');
	ts.user_email = application.zcore.functions.zso(form,'member_email');
	ts.user_username = ts.user_email;
	ts.user_password = application.zcore.functions.zso(form,'member_password');
	ts.user_confirm=1; // force opt-in
	ts.site_id = request.zos.globals.id;
	if(len(ts.user_username) LT 5){
		application.zcore.status.setStatus(request.zsid, "Username must be 5 or more characters");
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}else{
			application.zcore.functions.zRedirect('/z/user/user-manage/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}
	}
	if(form.method EQ "insert" and form.user_invited EQ 1){
		// do nothing
	}else{
		if(ts.user_password NEQ "" and len(ts.user_password) LT 8){
			application.zcore.status.setStatus(request.zsid, "Password must be 8 or more characters");
			if(form.method EQ 'insert'){
				application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
			}else{
				application.zcore.functions.zRedirect('/z/user/user-manage/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
			}
		}
	}

	if(not structkeyexists(request.managedGroupStruct, form.user_group_id)){
		application.zcore.status.setStatus(request.zsid, "Invalid Access Rights selected", form, true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}else{
			application.zcore.functions.zRedirect('/z/user/user-manage/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}
	}

	ts.sendConfirmOptIn=false;
	userAdminCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_admin");
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") and structkeyexists(request.zos.userSession.groupAccess, "client")){
		if(structkeyexists(form,'member_client_access') EQ false){
			form.member_client_access="''";
		}else{
			arrGroup=listToArray(form.member_client_access);
			arrGroup2=arrayNew(1);
			for(i=1;i LTE ArrayLen(arrGroup);i=i+1){
				ArrayAppend(arrGroup2,"'"&arrGroup[i]&"'");
			}
			form.member_client_access=arraytolist(arrGroup2,",");
		}
	} 
	StructDelete(variables,'member_photo');
	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("member_photo", application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.memberImagePath,1,1), '165x300');
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("member_photo", application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.memberImagePath,1,1), '165x300', 'user', 'user_id', "member_photo_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'member_photo');
		StructDelete(variables,'member_photo');
	}else if(ArrayLen(arrList) NEQ 0){
		form.member_photo=arrList[1];
	}else{
		StructDelete(form,'member_photo');
	}
	if(application.zcore.functions.zso(form,'member_photo_delete',true) EQ 1){
		form.member_photo='';	
	}
	if(trim(ts.user_password) EQ ""){
		structdelete(ts,'user_password');
		structdelete(form,'user_password');	
		structdelete(variables,'user_password');	
		structdelete(ts,'user_salt');
		structdelete(form,'user_salt');	
		structdelete(variables,'user_salt');
		structdelete(ts,'member_password');
		structdelete(form,'member_password');	
		structdelete(variables,'member_password');		
	}
	if(variables.metaFieldInUse){
		form.user_meta_json=variables.metaCom.save("user", form); 
	}
	ts.site_id=request.zos.globals.id; 
	if(form.method EQ "update"){
		ts.user_id = form.user_id;
		result = userAdminCom.update(ts);
		if(result EQ false){
			application.zcore.status.setStatus(Request.zsid, 'Another user is already using that email address.',form,true);
			application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}
	}else{

		if(form.method EQ "insert" and form.user_invited EQ 1){
			ts.disablePasswordValidation=true;
			ts.user_invited=1;
			ts.user_password="";
			ts.user_welcome_message=application.zcore.functions.zso(form, 'user_welcome_message');
		}
		result = userAdminCom.add(ts);
		if(result EQ false){
			application.zcore.status.setStatus(Request.zsid, 'Another user is already using that email address.',form,true);
			application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}
		form.user_id = result;
	}
	if(form.method EQ 'update'){
		if(qU2.user_username NEQ application.zcore.functions.zso(form,'member_email') and structkeyexists(request.zos,'listing')){
			request.zos.listing.functions.zMLSSearchOptionsUpdateEmail(qU2.user_username,application.zcore.functions.zso(form,'member_email'));
		}
	}
	if(directoryexists(application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.memberImagePath,1,1)) EQ false){
		application.zcore.functions.zCreateDirectory(application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.memberImagePath,1,1));	
	}
	if(structkeyexists(request.zos,'listing')){
		arrM=listtoarray(application.zcore.functions.zso(form, 'mls_id'));
		arrM2=arraynew(1);
		for(i=1;i LTE arraylen(arrM);i++){
			m1=arrM[i];
			if(application.zcore.functions.zso(form, 'mlsagentid#m1#') NEQ ''){
				arrayappend(arrM2,m1&'-'&application.zcore.functions.zso(form,'mlsagentid#m1#'));
			}
		}
		form.member_mlsagentid=","&arraytolist(arrM2)&",";
	}
	db.sql="select member_id FROM #db.table("user", request.zos.zcoreDatasource)# user 
	where user_id =#db.param(form.user_id)# and 
	user_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qu99=db.execute("qu99");
	if(qu99.recordcount NEQ 0 and qu99.member_id EQ 0){
		form.member_id=form.user_id;
	}
	structdelete(ts,'user_password');
	structdelete(form,'user_password');	
	structdelete(variables,'user_password');	
	structdelete(ts,'user_salt');
	structdelete(form,'user_salt');	
	structdelete(variables,'user_salt');
	structdelete(ts,'member_password');
	structdelete(form,'member_password');	
	structdelete(variables,'member_password');	
	ts=structnew();
	ts.struct=form;
	ts.table="user";
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zUpdate(ts) EQ false){
		application.zcore.status.setStatus(request.zsid, 'User failed to update.',form,true);
		application.zcore.functions.zRedirect('/z/user/user-manage/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#');
	}else{
		if(form.method EQ "insert" and form.user_invited EQ 1){
			application.zcore.status.setStatus(request.zsid, 'User was created and the email invitation was sent.');
		}else{
			application.zcore.status.setStatus(request.zsid, 'User saved.');
		}
	}

	structdelete(application.siteStruct[request.zos.globals.id].administratorTemplateMenuCache, request.zos.globals.id&"_"&form.user_id);
	
	application.zcore.forceUserUpdateSession[request.zos.globals.id&":"&form.user_id]=true;
	

	if(application.zcore.app.siteHasApp("listing")){
		db.sql="select site_domain from #db.table("site", request.zos.zcoreDatasource)# site, 
		#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site  
		where site.site_id = app_x_site.site_id and 
		app_x_site_deleted = #db.param(0)# and 
		site_deleted = #db.param(0)# and
		app_x_site.app_id = #db.param(11)# and 
		site_parent_id = #db.param(request.zos.globals.id)# and 
		site_active=#db.param(1)# ";
		qS=db.execute("qS");
		for(i=1;i LTE qS.recordcount;i++){
			application.zcore.functions.zdownloadlink(qS.site_domain[i]&'/z/listing/listing/updateAgentIdStructRemote?user_id='&form.user_id);
		}
		application.zcore.listingCom.updateAgentIdStruct(form.user_id);
	} 


	application.zcore.functions.zRedirect('/z/user/user-manage/index?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#'); 
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" >
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" >
	<cfscript>
	var db=request.zos.queryObject; 
	var currentMethod=form.method;
	init();

	backupMethod=form.method;
	application.zcore.functions.zSetPageHelpId("5.2");
	form.user_id=application.zcore.functions.zso(form, 'user_id');
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user  
	WHERE user.user_id = #db.param(form.user_id)# and 
	user_deleted = #db.param(0)# and
	site_id=#db.param(request.zos.globals.id)# ";
	qMember=db.execute("qMember");
	application.zcore.functions.zQueryToStruct(qMember);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	if(variables.metaFieldInUse){
		structappend(form, variables.metaCom.getData("user", form), false); 
	}
	</cfscript>
	<h2>
		<cfif currentMethod EQ 'add'>
			Add
		<cfelse>
			Edit
		</cfif>
		User</h2>
	Email and Password are used for login.  Fields with &quot;*&quot; are required.<br />
	<br />
	<form class="zFormCheckDirty" action="/z/user/user-manage/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?user_id=#form.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&amp;searchtext=#URLEncodedFormat(form.searchtext)#" method="post" enctype="multipart/form-data">
		<cfscript> 
			cancelURL="/z/user/user-manage/index?zIndex=#form.zIndex#&amp;ugid=#form.ugid#&amp;searchtext=#URLEncodedFormat(form.searchtext)#"; 
		</cfscript> 
		<table  class="table-list"> 
			<cfscript> 
			if(variables.metaFieldInUse){
				metaFields=variables.metaCom.displayForm("user", "Basic", "first", true);
				if(arraylen(metaFields)){ 
					for(i=1;i<=arraylen(metaFields);i++){
						echo('<tr><th>#metaFields[i].label#');
						if(metaFields[i].required){
							echo(' *');
						}
						echo('</th><td>#metaFields[i].field#</td></tr>');
					}
				}
			}
			</cfscript>
			<cfscript> 
			if(variables.metaFieldInUse){
				metaFields=variables.metaCom.displayForm("user", "Advanced", "first", true);
				if(arraylen(metaFields)){ 
					for(i=1;i<=arraylen(metaFields);i++){
						echo('<tr><th>#metaFields[i].label#');
						if(metaFields[i].required){
							echo(' *');
						}
						echo('</th><td>#metaFields[i].field#</td></tr>');
					}
				}
			}
			</cfscript>
			<cfscript>
			db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group WHERE 
			user_group_deleted = #db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# and 
			user_group_id IN (#db.trustedSQL(request.managedUserGroupList)#)
			ORDER BY user_group_name ASC";
			qUserGroups=db.execute("qUserGroups");
			</cfscript>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Access Rights","member.member.edit user_group_id")#</th>
				<td style="vertical-align:top; "><cfscript> 
				selectStruct = StructNew();
				selectStruct.name = "user_group_id";
				selectStruct.query = qUserGroups;
				selectStruct.hideSelect=true;
				selectStruct.queryLabelField = "user_group_friendly_name";
				selectStruct.queryValueField = "user_group_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
			</tr> 
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Office","member.member.edit office_id")#</th>
				<td><cfscript>
					db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# office 
					WHERE site_id = #db.param(request.zos.globals.id)# and 
					office_deleted = #db.param(0)# ";
					if(arraylen(request.arrLoggedInUserOffice) EQ 0){
						db.sql&=" and office_id =#db.param(-1)# ";
					}else{
						db.sql&=" and office_id IN (#db.trustedSQL(arrayToList(request.arrLoggedInUserOffice, ","))#) ";
					}
					db.sql&=" ORDER BY office_name";
					qOffice=db.execute("qOffice");
					if(qOffice.recordcount EQ 1){
						form.office_id=qOffice.office_id;
					}
					selectStruct = StructNew();
					selectStruct.hideSelect=true;
					selectStruct.name = "office_id";
					selectStruct.query = qOffice;
					selectStruct.queryParseLabelVars=true;
					selectStruct.queryLabelField = "##office_name##, ##office_address##";
					selectStruct.queryValueField = "office_id";
					selectStruct.multiple=true;
					application.zcore.functions.zSetupMultipleSelect(selectStruct.name, application.zcore.functions.zso(form, 'office_id'));
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript> *</td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("First Name","member.member.edit member_first_name")#</th>
				<td><input type="text" name="member_first_name" value="<cfif form.member_first_name EQ ''>#form.user_first_name#<cfelse>#form.member_first_name#</cfif>" size="30" /></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Last Name","member.member.edit member_last_name")#</th>
				<td><input type="text" name="member_last_name" value="<cfif form.member_last_name EQ ''>#form.user_last_name#<cfelse>#form.member_last_name#</cfif>" size="30" /></td>
			</tr>
			<tr class="zUserManageOptionalProfile">
				<th>#application.zcore.functions.zOutputHelpToolTip("Company","member.member.edit member_company")#</th>
				<td><input type="text" name="member_company" value="#form.member_company#" size="30" /></td>
			</tr>
			<tr class="zUserManageOptionalProfile">
				<th>#application.zcore.functions.zOutputHelpToolTip("Title","member.member.edit member_title")#</th>
				<td><input type="text" name="member_title" value="#form.member_title#" size="30" /></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Email","member.member.edit member_email")#</th>
				<td><input type="text" name="member_email" value="<cfif form.member_email EQ ''>#form.user_username#<cfelse>#form.member_email#</cfif>" size="30" /> *</td>
			</tr>
			<cfif backupMethod EQ "add">
				<tr>
					<th>&nbsp;</th>
					<td>
						<div class="z-float z-mb-10">
						<input type="radio" name="user_invited" id="user_invited1" value="1" onclick="$('##inviteUserDiv1').show();$('##setPasswordTable1').hide();" checked="checked"> <label for="user_invited1">Invite User</label>
						<input type="radio" name="user_invited" id="user_invited2" value="0" onclick="$('##inviteUserDiv1').hide();$('##setPasswordTable1').show();"> <label for="user_invited2">Set Password</label>
						</div>
						<div id="inviteUserDiv1" class="z-float">
						<p>For better security, it is recommended to invite users instead of setting the password for them.</p>
						<h2>Invite Info</h2> 
						<p>The user will receive a welcome email instructing them to finish creating their account.</p>
						<p>Invitations expire after 7 days.  You can reinvite them from the manage users page.</p>
						<p>You can add your own welcome message to this email below:</p>
						<p><strong>Welcome message</strong></p>
						<textarea name="user_welcome_message" cols="10" rows="5" style="width:96%;">#application.zcore.functions.zso(form, 'user_welcome_message', false, 'You have been invited to create an account on this web site.')#</textarea>
						</div>
					</td>
				</tr>
				<tr>
					<th>&nbsp;</th>
					<td><table id="setPasswordTable1" class="table-list" style="display:none;">
						<tr>
							<th>Password</th>
							<td><input type="password" name="member_password" id="member_password" value="" size="30" /> 
								<cfif backupMethod EQ "add">
									*
								</cfif></td>
						</tr>
						<tr>
							<th>#application.zcore.functions.zOutputHelpToolTip("Confirm Password","member.member.edit member_password_confirm")#</th>
							<td><input type="password" name="member_password_confirm" id="member_password_confirm" value="" size="30" /> 
								<cfif backupMethod EQ "add">
									*
								</cfif></td>
						</tr>
					</table></td>
				</tr>
			<cfelse>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Password","member.member.edit member_password")#</th>
					<td><input type="password" name="member_password" id="member_password" value="" size="30" /> 
						<cfif backupMethod EQ "add">
							*
						</cfif>
						<cfif currentMethod EQ "edit">
							<br />Leave empty unless you wish to change the password.
						</cfif></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Confirm Password","member.member.edit member_password_confirm")#</th>
					<td><input type="password" name="member_password_confirm" id="member_password_confirm" value="" size="30" /> 
						<cfif backupMethod EQ "add">
							*
						</cfif></td>
				</tr> 
			</cfif>
		<cfif request.userFullEditAccess> 
			<tr class="zUserManageOptionalProfile">
				<th>#application.zcore.functions.zOutputHelpToolTip("CC Email(s)","member.member.edit user_alternate_email")#</th>
				<td><input type="text" name="user_alternate_email" maxlength="255" value="#htmleditformat(form.user_alternate_email)#"  />
				<br />Note: Updates to assigned leads will be CC'd to this list of emails.  Comma separate multiple email addresses. You can't login as this user with alternate emails.</td>
			</tr>
			<tr class="zUserManageOptionalProfile">
				<th>#application.zcore.functions.zOutputHelpToolTip("Phone","member.member.edit member_phone")#</th>
				<td><input type="text" name="member_phone" value="<cfif form.member_phone EQ ''>#form.user_phone#<cfelse>#form.member_phone#</cfif>" size="30" /></td>
			</tr>
			<tr class="zUserManageOptionalProfile">
				<th>#application.zcore.functions.zOutputHelpToolTip("Web Site","member.member.edit member_website")#</th>
				<td><input type="text" name="member_website" value="#form.member_website#" size="30" />
					<br />(URLs Must begin with http:// or https://)</td>
			</tr> 

			<tr class="zUserManageOptionalProfile">
				<th>#application.zcore.functions.zOutputHelpToolTip("Photo","member.member.edit member_photo")#</th>
				<td>#application.zcore.functions.zInputImage('member_photo', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.memberImagePath,1,1), request.zos.globals.siteroot&request.zos.memberImagePath)# </td>
			</tr>
			<tbody class="zUserManageOptionalProfile">
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Description","member.member.edit member_description")#</th>
					<td><cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "member_description";
					htmlEditor.value			= form.member_description;
					htmlEditor.width			= "100%";
					htmlEditor.height		= 400;
					htmlEditor.create();
					</cfscript></td>
				</tr> 
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Twitter URL","member.member.edit user_twitter_url")#</th>
					<td><input type="text" name="user_twitter_url" value="#form.user_twitter_url#" size="30" /></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Facebook URL","member.member.edit user_facebook_url")#</th>
					<td><input type="text" name="user_facebook_url" value="#form.user_facebook_url#" size="30" /></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Instagram URL","member.member.edit user_instagram_url")#</th>
					<td><input type="text" name="user_instagram_url" value="#form.user_instagram_url#" size="30" /></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("LinkedIn URL","member.member.edit user_linkedin_url")#</th>
					<td><input type="text" name="user_linkedin_url" value="#form.user_linkedin_url#" size="30" /></td>
				</tr> 
				<cfif application.zcore.app.siteHasApp("listing")>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Sort Listings","member.member.edit user_listing_sort")#</th>
						<td><input type="radio" style="border:none; background:none;"  name="user_listing_sort" value="2" <cfif form.user_listing_sort EQ '2' or form.user_listing_sort EQ ''>checked="checked"</cfif> />
							Price Ascending&nbsp;&nbsp;&nbsp;&nbsp;
							<input type="radio" style="border:none; background:none;"  name="user_listing_sort" value="1" <cfif form.user_listing_sort EQ '1'>checked="checked"</cfif> />
							Price Descending </td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("MLS Agent ID","member.member.edit mlsagentid")#</th>
						<td>Please type the agent id for each MLS database or leave it blank: 
							<cfscript>
							db.sql="SELECT * FROM #db.table("mls", request.zos.zcoreDatasource)# mls, 
							#db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls 
							WHERE mls.mls_id = app_x_mls.mls_id and 
							app_x_mls_deleted = #db.param(0)# and 
							mls_deleted = #db.param(0)# and
							app_x_mls.site_id=#db.param(request.zos.globals.id)# and 
							mls_status = #db.param('1')#
							ORDER BY mls_name";
							qMLS=db.execute("qMLS");
							mAIstruct=structnew();
							if(form.member_mlsagentid NEQ ''){
								arrP=listtoarray(form.member_mlsagentid,',');
								for(i=1;i LTE arraylen(arrP);i++){
									if(arrP[i] NEQ ""){
										arrI=listtoarray(arrP[i],'-');
										if(arraylen(arrI) EQ 2){
											mAIstruct[arrI[1]]=arrI[2];
										}
									}
								}
							}
							</cfscript>
							<script>/* <![CDATA[ */ 
								zmlsagentidarray=new Array();
								 /* ]]> */
								 </script>
								<table style="border-spacing:0px;">
									<cfloop query="qmls">
									<tr <cfif qmls.currentrow MOD 2 EQ 0>style="background-color:##EFEFEF;"</cfif>>
										<td><script>/* <![CDATA[ */ 
											zmlsagentidarray[#qmls.mls_id#]="mlsagentid#qmls.mls_id#";
											 /* ]]> */
											 </script> 
											#qmls.mls_name#:
											<input type="hidden" name="mls_id" value="#qmls.mls_id#" /></td>
										<td><input type="text" name="mlsagentid#qmls.mls_id#" id="mlsagentid#qmls.mls_id#" 
										value="<cfif application.zcore.functions.zso(form, 'mlsagentid#qmls.mls_id#') NEQ ''>#application.zcore.functions.zso(form, 'mlsagentid#qmls.mls_id#')#<cfelseif structkeyexists(mAIstruct, qmls.mls_id)>#mAIstruct[qmls.mls_id]#</cfif>" /></td>
									</tr>
									</cfloop>
								</table>
								<br /><br /><script>
							/* <![CDATA[ */ 
							function lookupAgentIdCallback(r){
								var myObj=eval('('+r+')');
								if(myObj.success){
									if(typeof(zmlsagentidarray[myObj.mlsproviderid])!="undefined"){
										var c=document.getElementById(zmlsagentidarray[myObj.mlsproviderid]);
										c.value=myObj.agentid;
									}
								}
								alert(myObj.message);
							}
							function lookupAgentId(){
									
								var tempObj={};
								tempObj.id="zMapListing";
								tempObj.url="/z/user/user-manage/lookupagentid?zmlsnum="+escape(document.getElementById("zmlsnum").value);
								tempObj.callback=lookupAgentIdCallback;
								tempObj.cache=false;
								zAjax(tempObj);
							}
							 /* ]]> */
							 </script>
							<h3>Agent Id Lookup</h3>
							<p>Enter the MLS ## for one of this agent's listings to find their agent id.  This also works if you have multiple MLS providers, but you must have one MLS ## from each mls provider.</p>
							<p>
								<input type="text" name="zmlsnum" id="zmlsnum" value="" />
								<input type="button" name="b1111" value="Lookup" onclick="lookupAgentId();" />
						
						</td>
					</tr>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Auto-assign Listing Inquiries","member.member.edit user_autoassign_listing_inquiry")#</th>
						<td>#application.zcore.functions.zInput_Boolean("user_autoassign_listing_inquiry", form.user_autoassign_listing_inquiry)#
							| If set to yes, this agent's listing inquiries will automatically be assigned to them in the future.  The MLS Agent ID above must be correct for this to work.
						</td>
					</tr> 

				</cfif> 
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Phone","member.member.edit user_pref_phone")#</th>
					<td><input type="radio" style="border:none; background:none;"  name="user_pref_phone"  value="1" <cfif form.user_pref_phone EQ '1' or form.user_pref_phone EQ ''>checked="checked"</cfif> />
						yes&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" style="border:none; background:none;"  name="user_pref_phone" value="0" <cfif form.user_pref_phone EQ '0'>checked="checked"</cfif> />
						no</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Email Mailing List","member.member.edit user_pref_list")#</th>
					<td><input type="radio" style="border:none; background:none;"  name="user_pref_list" value="1" <cfif form.user_pref_list EQ '1' or form.user_pref_list EQ ''>checked="checked"</cfif> />
						yes&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" style="border:none; background:none;"  name="user_pref_list" value="0" <cfif form.user_pref_list EQ '0'>checked="checked"</cfif> />
						no</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Personal Emails","member.member.edit user_pref_email")#</th>
					<td><input type="radio" style="border:none; background:none;"  name="user_pref_email" value="1" <cfif form.user_pref_email EQ '1' or form.user_pref_email EQ ''>checked="checked"</cfif> />
						yes&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" style="border:none; background:none;"  name="user_pref_email" value="0" <cfif form.user_pref_email EQ '0'>checked="checked"</cfif> />
						no</td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Physical Mail","member.member.edit user_pref_mail")#</th>
					<td><input type="radio" style="border:none; background:none;"  name="user_pref_mail" value="1" <cfif form.user_pref_mail EQ '1' or form.user_pref_mail EQ ''>checked="checked"</cfif> />
						yes&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" style="border:none; background:none;"  name="user_pref_mail" value="0" <cfif form.user_pref_mail EQ '0'>checked="checked"</cfif> />
						no</td>
					<td></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Fax","member.member.edit user_pref_fax")#</th>
					<td><input type="radio" style="border:none; background:none;"  name="user_pref_fax" value="1" <cfif form.user_pref_fax EQ '1' or form.user_pref_fax EQ ''>checked="checked"</cfif> />
						yes&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" style="border:none; background:none;"  name="user_pref_fax" value="0" <cfif form.user_pref_fax EQ '0'>checked="checked"</cfif> />
						no</td>
				</tr> 
				<cfif structkeyexists(request,'realestateprefform')> 
					<tr> 
						<td colspan="2">
					Are you already working with another real estate professional?<br />
					<input type="radio" style="border:none; background:none;"  name="user_pref_realtor" value="1" <cfif form.user_pref_realtor EQ '1'>checked="checked"</cfif> />
					yes&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" style="border:none; background:none;"  name="user_pref_realtor" value="0" <cfif form.user_pref_realtor EQ '0' or form.user_pref_realtor EQ ''>checked="checked"</cfif> />
					no
					</td>
					</tr>
					<tr><td colspan="2">
					Would you like notified when there are new Hot Deals?<br />
					<input type="radio" style="border:none; background:none;"  name="user_pref_hotdeals" value="1" <cfif form.user_pref_hotdeals EQ '1' or form.user_pref_hotdeals EQ ''>checked="checked"</cfif> />
					yes&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" style="border:none; background:none;"  name="user_pref_hotdeals" value="0" <cfif form.user_pref_hotdeals EQ '0'>checked="checked"</cfif> />
					no
					</td>
					</tr>
				</cfif>
				<tr><td colspan="2">
					Are you interested in receiving information on new products &amp; services we may have in the future?<br />
					<input type="radio" style="border:none; background:none;"  name="user_pref_new" value="1" <cfif form.user_pref_new EQ '1' or form.user_pref_new EQ ''>checked="checked"</cfif> />
					yes&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" style="border:none; background:none;"  name="user_pref_new" value="0" <cfif form.user_pref_new EQ '0'>checked="checked"</cfif> />
					no
					<cfif structkeyexists(request,'realestateprefform') eq false>
						
						</td>
						</tr>
						<tr><td colspan="2">
						May we share your contact information with our partners who may offer you related products and services?<br />
						<input type="radio" style="border:none; background:none;"  name="user_pref_sharing" value="1" <cfif form.user_pref_sharing EQ '1'>checked="checked"</cfif> />
						yes&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" style="border:none; background:none;"  name="user_pref_sharing" value="0" <cfif form.user_pref_sharing EQ '0' or form.user_pref_sharing EQ ''>checked="checked"</cfif> />
						no
					</cfif>
				</td>
				</tr>
				<tr><td colspan="2">
					What email format do you prefer?<br />
					<input type="radio" style="border:none; background:none;"  name="user_pref_html" value="1" <cfif form.user_pref_html EQ '1' or form.user_pref_html EQ ''>checked="checked"</cfif> />
					HTML&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" style="border:none; background:none;"  name="user_pref_html" value="0" <cfif form.user_pref_html EQ '0'>checked="checked"</cfif> />
					Plain Text<br />
					<br />
				</td>
				</tr>
				<cfif form.user_fax neq ''>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Fax","member.member.edit user_fax")#</th>
						<td><input type="text" name="user_fax" value="#form.user_fax#" /></td>
					</tr>
				</cfif>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Address","member.member.edit user_street")#</th>
					<td><input type="text" name="user_street" value="#form.user_street#" /></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Address 2","member.member.edit user_street2")#</th>
					<td><input type="text" name="user_street2" value="#form.user_street2#" /></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("City","member.member.edit user_city")#</th>
					<td><input type="text" name="user_city" value="#form.user_city#" /></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("State","member.member.edit user_state")#</th>
					<td><cfscript>
					writeoutput(application.zcore.functions.zStateSelect("user_state", application.zcore.functions.zso(form, 'user_state')));
					</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Country","member.member.edit user_country")#</th>
					<td><cfscript>
					writeoutput(application.zcore.functions.zCountrySelect("user_country", application.zcore.functions.zso(form, 'user_country')));
					</cfscript></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Zip Code","member.member.edit user_zip")#</th>
					<td><input type="text" name="user_zip" value="#form.user_zip#" /></td>
				</tr> 
			</tbody>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Active","member.member.edit user_active")#</th>
				<td>#application.zcore.functions.zInput_Boolean("user_active", form.user_active)#</td>
			</tr> 
		</cfif>
			<tr><td colspan="2">
				<button name="saveButton" type="submit">Save</button>
				<button name="cancelButton" type="button" onclick="window.location.href='#cancelURL#';">Cancel</button>

			</td></tr>
			<cfscript> 
			if(variables.metaFieldInUse){
				metaFields=variables.metaCom.displayForm("user", "Basic", "last", true);
				if(arraylen(metaFields)){ 
					for(i=1;i<=arraylen(metaFields);i++){ 
						echo('<tr><th>#metaFields[i].label#');
						if(metaFields[i].required){
							echo(' *');
						}
						echo('</th><td>#metaFields[i].field#</td></tr>');
					}
				}
			}
			</cfscript>
			<cfscript> 
			if(variables.metaFieldInUse){
				metaFields=variables.metaCom.displayForm("user", "Advanced", "last", true);
				if(arraylen(metaFields)){ 
					for(i=1;i<=arraylen(metaFields);i++){ 
						echo('<tr><th>#metaFields[i].label#');
						if(metaFields[i].required){
							echo(' *');
						}
						echo('</th><td>#metaFields[i].field#</td></tr>');
					}
				}
			}
			</cfscript>
		</table>  
	</form>
</cffunction>

<cffunction name="resendInvite" localmode="modern" access="remote" >
	<cfscript>
	init();
	var db=request.zos.queryObject; 

	form.user_id=application.zcore.functions.zso(form, 'user_id', true);
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# 
	WHERE user_id=#db.param(form.user_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	user_invited=#db.param(1)# and 
	user_deleted = #db.param(0)# and 
	user_active=#db.param(1)# ";
	qUser=db.execute("qUser");   
	if(qUser.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid user", form, true);
		application.zcore.functions.zRedirect("/z/user/user-manage/index?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#");
	}
	rpCom=createobject("component", "zcorerootmapping.com.user.user_admin");
	result=rpCom.resendInvite(qUser.user_id);
	if(result){
		application.zcore.status.setStatus(request.zsid, "Invitation email was resent to #qUser.user_username#");
	}else{
		application.zcore.status.setStatus(request.zsid, "Failed to send invitation email", form, true);
	}
	application.zcore.functions.zRedirect("/z/user/user-manage/index?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#");
	</cfscript>
</cffunction>

<cffunction name="sendUserPasswordResetEmail" localmode="modern" access="remote" >
	<cfscript>
	init();
	var db=request.zos.queryObject; 

	form.user_id=application.zcore.functions.zso(form, 'user_id', true);
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# 
	WHERE user_id=#db.param(form.user_id)# and 
	site_id = #db.param(request.zos.globals.id)# and
	user_deleted = #db.param(0)# and 
	user_active=#db.param(1)# ";
	qUser=db.execute("qUser");   
	if(qUser.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid user", form, true);
		application.zcore.functions.zRedirect("/z/user/user-manage/index?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#");
	}
	rpCom=createobject("component", "zcorerootmapping.mvc.z.user.controller.reset-password");
	rs=rpCom.sendPasswordResetEmail(qUser.user_username, qUser.site_id);
	if(rs.success){
		application.zcore.status.setStatus(request.zsid, "Password reset email sent to #qUser.user_username#");
	}else{
		application.zcore.status.setStatus(request.zsid, rs.errorMessage, form, true);
	}
	application.zcore.functions.zRedirect("/z/user/user-manage/index?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&searchtext=#URLEncodedFormat(form.searchtext)#");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" >
	<cfscript>
	var db=request.zos.queryObject; 
	init();
	application.zcore.functions.zSetPageHelpId("5.1");
	application.zcore.functions.zStatusHandler(request.zsid);
	db.sql="SELECT count(user.user_id) count FROM #db.table("user", request.zos.zcoreDatasource)#, 
	#db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE 
	user_deleted = #db.param(0)# and 
	user_group_deleted=#db.param(0)# and 
	user.site_id = #db.param(request.zos.globals.id)# and
	user.site_id = user_group.site_id and 
	user.user_group_id = user_group.user_group_id and 
	user.site_id = #db.param(request.zos.globals.id)# and 
	user_server_administrator = #db.param('0')# and 
	user.user_group_id IN (#db.trustedSQL(request.managedUserGroupList)#) ";
	db.sql&=" and ( ";
	for(i=1;i<=arraylen(request.arrLoggedInUserOffice);i++){
		office_id=request.arrLoggedInUserOffice[i];
		if(i NEQ 1){
			db.sql&=" or ";
		}
		db.sql&=" user.office_id = #db.param(request.arrLoggedInUserOffice[i])# ";
	}
	db.sql&=" ) "; 
	if(structkeyexists(form, 'ugid') and trim(form.ugid) NEQ ''){
		db.sql&=" and user.user_group_id = #db.param(form.ugid)# ";
	}
	if(structkeyexists(form, 'searchtext') and trim(form.searchtext) NEQ ''){
		db.sql&=" and concat(user.user_id,#db.param(' ')#, #db.param(' ')#, member_company, #db.param(' ')#,
		user_first_name,#db.param(' ')#,user_last_name,#db.param(' ')#,user_username) like #db.param("%#form.searchtext#%")#";
	} 
	qCount=db.execute("qCount");
	db.sql="SELECT *, user.site_id usersiteid, user.site_id membersiteid 
	FROM #db.table("user", request.zos.zcoreDatasource)#  , 
	#db.table("user_group", request.zos.zcoreDatasource)#  
	WHERE 
	user_deleted = #db.param(0)# and 
	user_group_deleted = #db.param(0)# and 
	user.site_id = user_group.site_id and 
	user.user_group_id = user_group.user_group_id and 
	user.site_id = #db.param(request.zos.globals.id)# and 
	user_server_administrator = #db.param('0')# and 
	user.user_group_id IN (#db.trustedSQL(request.managedUserGroupList)#) ";
	db.sql&=" and ( ";
	for(i=1;i<=arraylen(request.arrLoggedInUserOffice);i++){
		if(i NEQ 1){
			db.sql&=" or ";
		}
		db.sql&=" user.office_id = #db.param(request.arrLoggedInUserOffice[i])# ";
	}
	db.sql&=" ) "; 
	if(structkeyexists(form, 'ugid') and trim(form.ugid) NEQ ''){
		db.sql&=" and user.user_group_id = #db.param(form.ugid)# ";
	}
	if(structkeyexists(form, 'searchtext') and trim(form.searchtext) NEQ ''){
		db.sql&=" and concat(user.user_id,#db.param(' ')#, #db.param(' ')#, member_company, #db.param(' ')#,
		user_first_name,#db.param(' ')#,user_last_name,#db.param(' ')#,user_username) like #db.param("%#form.searchtext#%")#";
	}
	db.sql&=" ORDER BY member_sort asc, user_first_name, user_last_name 
	LIMIT #db.param((form.zIndex-1)*30)#,#db.param(30)# ";
	qMember=db.execute("qMember"); 

	db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	user_group_deleted = #db.param(0)# and 
	user_group_id IN (#db.trustedSQL(request.managedUserGroupList)#)
	ORDER BY user_group_name";
	qUserGroup=db.execute("qUserGroup"); 
    </cfscript>
    <div class="z-float">
	    <div class="z-1of2 z-m-0 z-p-0 z-pb-10">
			<h2 style="display:inline; ">Manage Users</h2>
		</div>
		<div class="z-1of2 z-m-0 z-p-0 z-pb-10 z-text-right">
			<button type="button" name="addButton" class="z-button" onclick="window.location.href='/z/user/user-manage/add';">Add User</button>
		</div>
	</div>
	<form action="/z/user/user-manage/index" method="post" enctype="multipart/form-data">
		<table style="width:100%;" class="table-list">
			<tr>
				<th style="vertical-align:middle;">Search Name: 
					<input type="text" name="searchtext" style="min-width:auto; width:250px;" value="#application.zcore.functions.zso(form, 'searchtext')#" size="30" />
				</th>
				<th style="vertical-align:middle;">
					Access Rights:  
					<cfscript>
					// groups i have access to
					selectStruct = StructNew();
					selectStruct.name = "ugid";
					selectStruct.query = qUserGroup;
					selectStruct.queryLabelField = "user_group_friendly_name";
					selectStruct.queryValueField = "user_group_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
				</th>
				<th>
					<input type="submit" name="submitForm" value="Search" class="z-manager-search-button" />
					<input type="button" name="cancel" value="Clear Search" class="z-manager-search-button" onclick="window.location.href='/z/user/user-manage/index';" /></th>
			</tr>
		</table>
	</form>
	<cfscript>
	if(qmember.recordcount EQ 0 and form.zIndex NEQ 1){
		application.zcore.functions.zredirect('/z/user/user-manage/index?zindex='&max(1, form.zIndex-1));
	}
	searchStruct = StructNew();
	searchStruct.count = qcount.count;
	searchStruct.index = form.zIndex;
	searchStruct.showString = "Results ";
	searchStruct.url ="/z/user/user-manage/index";
	searchStruct.indexName = "zIndex";
	searchStruct.buttons = 5;	
		searchStruct.perpage = 30;
	if(searchStruct.count LTE searchStruct.perpage){
		searchNav="";
	}else{
		searchNav = '<table class="table-list" style="width:100%; border-spacing:0px;" >		
	<tr><td style="padding:0px;">'&application.zcore.functions.zSearchResultsNav(searchStruct)&'</td></tr></table>';
	}
	</cfscript>
	#searchNav#
	<table id="sortRowTable" style="width:100%;"  class="table-list">
		<thead>
		<tr>
			<th>ID</th>
			<th>Office</th> 
			<th>Name/Access Rights</th>
			<th>Status</th>
			<!--- <th>Sort</th> --->
			<th>Admin</th>
		</tr>
		</thead>
		<tbody>
			<cfloop query="qMember"> 
				<cfscript>
				row={};
				structappend(row, qMember); 
				</cfscript>
			<tr #variables.queueSortCom.getRowHTML(qMember.user_id)# <cfif qMember.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
				<td>#qMember.user_id#</td> 
				<td>
					<cfscript>
					arrOffice=listToArray(qMember.office_id, ",");
					first=true;
					savecontent variable="out"{
						for(office_id in arrOffice){
							if(structkeyexists(request.userOfficeLookupStruct, office_id)){
								if(not first){
									echo(", ");
								}
								first=false;
								echo(request.userOfficeLookupStruct[office_id].office_name);
							}
						}
					}
					echo('<a title="#htmleditformat(out)#">'&application.zcore.functions.zLimitStringLength(out, 77)&'</a>');
					</cfscript>&nbsp;</td> 
				<td><cfif qMember.user_first_name NEQ ''>
						#qMember.user_first_name# #qMember.user_last_name#<br />
					<cfelseif qMember.member_company NEQ "">
						#qMember.member_company#<br />
					<cfelse>
						#qMember.member_email#<br />
					</cfif>
					#qMember.user_group_friendly_name#
				</td>  
				<td><cfif qMember.user_active EQ 1>Active<cfelse>Inactive</cfif></td>
				<!--- <td><cfif qMember.member_public_profile EQ 1>#variables.queueSortCom.getAjaxHandleButton(qMember.user_id)#</cfif></td>  --->
				<td> 
					<cfif request.zos.globals.enableDemoMode>
						DEMO | Admin disabled
					<cfelse> 
						<a href="##" onclick="if(window.confirm('Are you sure you want to send a password reset email to #qMember.user_username#?')){ window.location.href='/z/user/user-manage/sendUserPasswordResetEmail?user_id=#qMember.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&amp;searchtext=#URLEncodedFormat(form.searchtext)#'; } return false;">Send Reset Password Email</a> | 
						<cfif qMember.user_invited EQ 1>
							<a href="##" onclick="if(window.confirm('Are you sure you want to send a new invitation email to #qMember.user_username#?')){ window.location.href='/z/user/user-manage/resendInvite?user_id=#qMember.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&amp;searchtext=#URLEncodedFormat(form.searchtext)#'; } return false;">Re-send Invite</a> | 
						</cfif>


						<a href="/z/user/user-manage/edit?user_id=#qMember.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&amp;searchtext=#URLEncodedFormat(form.searchtext)#">Edit</a>  
						<cfif application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_url_author_id', true) NEQ 0> 
							 | <a href="#application.zcore.app.getAppCFC("blog").getAuthorLink(row)#" target="_blank">Articles</a>
						</cfif>

						<cfif qMember.usersiteid EQ qMember.memberSiteId and (request.zsession.user.id NEQ qMember.user_id or request.zsession.user.site_id NEQ request.zos.globals.id)>
							| <a href="/z/user/user-manage/delete?user_id=#qMember.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&amp;searchtext=#URLEncodedFormat(form.searchtext)#">Delete</a>
						</cfif> 
					</cfif>
					&nbsp;</td>
			</tr>
		</cfloop>
		</tbody>
	</table>
	#searchNav#
</cffunction>


</cfoutput>
</cfcomponent>
