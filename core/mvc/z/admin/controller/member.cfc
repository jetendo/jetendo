<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Users");	
	var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	form.zIndex=application.zcore.functions.zso(form,'zIndex',true,1);
	form.ugid=application.zcore.functions.zso(form, 'ugid', true);
	form.searchtext=trim(application.zcore.functions.zso(form,'searchtext'));
	form.returnMethod=application.zcore.functions.zso(form, 'returnMethod', false, "");
	if(form.method EQ "showPublicUsers"){
		form.returnMethod="showPublicUsers";
	}
	if(not application.zcore.user.checkGroupAccess("administrator") and not structkeyexists(request.zos.userSession.groupAccess, "manager")){
		if(form.method EQ "index"){
			application.zcore.functions.zRedirect("/z/admin/member/edit?user_id=#request.zsession.user.id#");
		}
		form.user_id = request.zsession.user.id;
		if(form.method EQ 'delete' or form.method EQ 'insert' or form.method EQ 'list' or form.method EQ 'add'){
			application.zcore.status.setStatus(Request.zsid, 'Permission Denied', false,true);
			application.zcore.functions.zRedirect('/z/admin/member/#form.returnMethod#?zsid=#request.zsid#');
		}
	}
	form.site_id=request.zos.globals.id;
	form.user_group_id2 = userGroupCom.getGroupId('agent',request.zos.globals.id);
	memberUserGroupId= userGroupCom.getGroupId('member',request.zos.globals.id);
	variables.userUserGroupIdCopy = userGroupCom.getGroupId('user',request.zos.globals.id);
	db.sql="SELECT * FROM 
#db.table("user_group_x_group", request.zos.zcoreDatasource)# 
WHERE user_group_id = #db.param(form.ugid)# and 
user_group_child_id=#db.param(memberUserGroupId)# and 
user_group_x_group_deleted=#db.param(0)# and 
site_id = #db.param(request.zos.globals.id)# ";
	qGroupCheck=db.execute("qGroupCheck");

	db.sql="SELECT user_group_id FROM 
#db.table("user_group_x_group", request.zos.zcoreDatasource)# 
WHERE user_group_child_id = #db.param(memberUserGroupId)# and  
user_group_x_group_deleted=#db.param(0)# and 
site_id = #db.param(request.zos.globals.id)# ";
	qMemberGroups=db.execute("qMemberGroups");
	memberAccessStruct={};
	arrMemberGroups=[];
	for(row in qMemberGroups){
		memberAccessStruct[row.user_group_id]=true;
		arrayAppend(arrMemberGroups, row.user_group_id);
	} 
	variables.memberAccessGroupIdList=arrayToList(arrMemberGroups, ", ");
	if(variables.memberAccessGroupIdList EQ ""){
		variables.memberAccessGroupIdList=0;
	}
	
	if(form.ugid NEQ "0" and qGroupCheck.recordcount EQ 0){
		form.showallusers=1;
	}
	if(isDefined('request.zsession.showallusers') EQ false){
		request.zsession.showallusers=false;
	}
	if(structkeyexists(form,'showallusers')){
		if(form.showallusers EQ 1){
			request.zsession.showallusers=true;
		}else{
			request.zsession.showallusers=false;
		}
	}
	if(request.zsession.showallusers){
		variables.userUserGroupId=0;
	}else{
		variables.userUserGroupId =variables.userUserGroupIdCopy;
	}
	variables.queueSortStruct = StructNew();
	variables.queueSortStruct.tableName = "user";
	variables.queueSortStruct.datasource=request.zos.zcoreDatasource;
	variables.queueSortStruct.sortFieldName = "member_sort";
	variables.queueSortStruct.primaryKeyName = "user_id";
	variables.queueSortStruct.where="user.site_id = '#request.zos.globals.id#'  and 
	member_public_profile='1' and user_deleted='0' and  
	user_deleted = 0 and  
	user_server_administrator = 0 and 
	user_group_id IN (#variables.memberAccessGroupIdList#) "; 
	variables.queueSortStruct.ajaxTableId='sortRowTable';
	variables.queueSortStruct.ajaxURL='/z/admin/member/#form.returnMethod#';
	
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

<cffunction name="lookupagentid" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	init();
	x_ajax_id=application.zcore.functions.zso(form, 'x_ajax_id');
	form.zmlsnum=trim(application.zcore.functions.zso(form, 'zmlsnum'));
	header name="x_ajax_id" value="#x_ajax_id#";
	propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	ts = StructNew();
	ts.offset = 0;
	ts.perpage = 1;
	ts.distance = 30; // in miles
	ts.disableCount=true;
	tempId = application.zcore.status.getNewId();
	ts9={
		search_mls_number_list:form.zmlsnum
	};
	propertyDataCom.setSearchCriteria(ts9);
	returnStruct = propertyDataCom.getProperties(ts);
	
	agentid="";
	mlsproviderid="";
	if(arrayLen(returnStruct.arrData) NEQ 0){
		agentid=jsstringformat(returnStruct.arrdata[1].listing_agent);
		mlsproviderid=jsstringformat(listgetat(returnStruct.arrdata[1].listing_id,1,"-"));
		writeoutput('{success:true,message:"Listing found, agent id has been set.",agentid:"#agentid#",mlsproviderid:"#mlsproviderid#"}');
	}else{
		writeoutput('{success:false,message:"No listing found.",agentid:"",mlsproviderid:""}');
	}
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="enable" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Users", true);	
	db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
	SET user_active = #db.param('1')#,
	user_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE user_id = #db.param(form.user_id)# and 
	user_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qUp=db.execute("qUp");
	application.zcore.status.setStatus(request.zsid,"User has been enabled.");
	application.zcore.functions.zRedirect("/z/admin/member/#form.returnMethod#?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#");
	</cfscript>
</cffunction>

<cffunction name="disable" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Users", true);	
	db.sql="UPDATE #db.table("user", request.zos.zcoreDatasource)# user 
	SET user_active = #db.param('0')#,
	user_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE user_id = #db.param(form.user_id)# and 
	user_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qUp=db.execute("qUp");
	application.zcore.status.setStatus(request.zsid,"User has been disabled.");
	application.zcore.functions.zRedirect("/z/admin/member/#form.returnMethod#?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#");
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var q=0;
	var qCheck=0;
	init();
	db.sql="SELECT *, user.site_id userSiteId FROM #db.table("user", request.zos.zcoreDatasource)# user  
	WHERE user.user_id = #db.param(application.zcore.functions.zso(form,'user_id'))# and 
	user_deleted = #db.param(0)# and 
	site_id =#db.param(request.zos.globals.id)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Member no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/admin/member/#form.returnMethod#?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		if(qCheck.member_photo NEQ ""){
			application.zcore.functions.zDeleteFile(application.zcore.functions.zVar('privatehomedir',qCheck.userSiteId)&removechars(request.zos.memberImagePath,1,1)&qCheck.member_photo);
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
		application.zcore.functions.zRedirect('/z/admin/member/#form.returnMethod#?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this user?<br />
			<br />
#qCheck.member_first_name# #qCheck.member_last_name# (#qcheck.member_email#) 			<br />
			<br />
			<a href="/z/admin/member/delete?confirm=1&amp;user_id=#form.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.returnMethod#&amp;searchtext=#URLEncodedFormat(form.searchtext)#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/admin/member/#form.returnMethod#?zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.returnMethod#&amp;searchtext=#URLEncodedFormat(form.searchtext)#">No</a> </div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Users", true);	
    arrSite2=arraynew(1);
	form.user_sync_site_id_list=application.zcore.functions.zso(form,'user_sync_site_id_list');
	if(form.member_website EQ "/"){
		form.member_website=request.zos.currentHostName&"/";	
	}
	form.office_id=application.zcore.functions.zso(form, 'office_id');
	arrOffice=listToArray(form.office_id, ',');
	arrOffice2=[];
	for(i=1;i LTE arraylen(arrOffice);i++){
		if(trim(arrOffice[i]) NEQ ""){
			arrayAppend(arrOffice2, arrOffice[i]);
		}
	}
	form.office_id=arrayToList(arrOffice2, ",");

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
					application.zcore.functions.zRedirect('/z/admin/member/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}else{
					application.zcore.functions.zRedirect('/z/admin/member/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}
			}else if(compare(form.member_password, form.member_password_confirm) NEQ 0){
				application.zcore.status.setStatus(Request.zsid, "Passwords don't match. Please re-enter the password and confirm password fields.",form,true);
				if(form.method EQ 'insert'){
					application.zcore.functions.zRedirect('/z/admin/member/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}else{
					application.zcore.functions.zRedirect('/z/admin/member/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}
			}
		}else{
			if(trim(form.member_password) NEQ "" and compare(form.member_password, form.member_password_confirm) NEQ 0){
				application.zcore.status.setStatus(Request.zsid, "Passwords don't match. Please re-enter the password and confirm password fields.",form,true);
				if(form.method EQ 'insert'){
					application.zcore.functions.zRedirect('/z/admin/member/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}else{
					application.zcore.functions.zRedirect('/z/admin/member/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
				}
			}
		}
	}
	if(request.zos.globals.parentid EQ 0){
		arrSite=listtoarray(form.user_sync_site_id_list,",");
		siteStruct=structnew();
		for(i=1;i LTE arraylen(arrSite);i++){
			siteStruct[arrSite[i]]=true;
		}
		for(local.row in variables.qPAll323){
			if(structkeyexists(siteStruct, local.row.site_id)){
				arrayappend(arrSite2, local.row.site_id); 
			}
		}
	}
	form.user_sync_site_id_list=","&arraytolist(arrSite2,",")&",";
	if(form.user_sync_site_id_list NEQ ",,"){
		db.sql="select * FROM #db.table("user", request.zos.zcoreDatasource)# user, 
		#db.table("site", request.zos.zcoreDatasource)# site 
		where user.site_id = site.site_id and 
		user_id <> #db.param(form.user_id)# and 
		user_deleted = #db.param(0)# and 
		site_deleted = #db.param(0)# and 
		user_username = #db.param(form.member_email)# and 
		site_parent_id=#db.param(request.zos.globals.id)#";
		qCheck99=db.execute("qCheck99"); 
		if(qCheck99.recordcount NEQ 0){
			application.zcore.status.setStatus(request.zsid, 'A user already exists for the E-Mail Address, "#form.member_email#", on "#application.zcore.functions.zvar('domain',qCheck99.site_id)#".  You must delete that user in that site''s manager, "<a href="#application.zcore.functions.zvar('domain',qCheck99.site_id)#/z/admin/member/#form.returnMethod#" rel="external" onclick="window.open(this.href); return false;">#application.zcore.functions.zvar('domain',qCheck99.site_id)#/z/admin/member/#form.returnMethod#</a>", first before enabling sync with this user.', form,true);
			if(form.method EQ 'insert'){
				application.zcore.functions.zRedirect('/z/admin/member/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
			}else{
				application.zcore.functions.zRedirect('/z/admin/member/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
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
			application.zcore.functions.zRedirect('/z/admin/member/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}else{
			application.zcore.functions.zRedirect('/z/admin/member/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}
	}
	if(form.method NEQ 'insert'){
		db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
		WHERE user_id = #db.param(form.user_id)# and 
		user_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qU2=db.execute("qU2");
		if(not application.zcore.user.checkGroupAccess("administrator")){
			// force same office
			form.office_id=qU2.office_id;
		}
	}
	form.member_phone=application.zcore.functions.zso(form, 'member_phone');
	structappend(ts,form);

	ts.user_phone=form.member_phone;
	ts.user_openid_required=application.zcore.functions.zso(form,'user_openid_required',false,0);
	ts.user_sync_site_id_list=application.zcore.functions.zso(form,'user_sync_site_id_list');
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
			application.zcore.functions.zRedirect('/z/admin/member/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}else{
			application.zcore.functions.zRedirect('/z/admin/member/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}
	}
	if(form.method EQ "insert" and form.user_invited EQ 1){
		// do nothing
	}else{
		if(ts.user_password NEQ "" and len(ts.user_password) LT 8){
			application.zcore.status.setStatus(request.zsid, "Password must be 8 or more characters");
			if(form.method EQ 'insert'){
				application.zcore.functions.zRedirect('/z/admin/member/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
			}else{
				application.zcore.functions.zRedirect('/z/admin/member/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
			}
		}
	}
	curGROUPID="";
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator") and (request.zsession.user.id NEQ form.user_id or request.zsession.user.site_id NEQ request.zos.globals.id)){
		db.sql="select user_group_id from #db.table("user_group", request.zos.zcoreDatasource)# user_group where 
		user_group_id = #db.param(form.user_group_id)# and 
		user_group_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#";
		qG=db.execute("qG");
		if(qG.recordcount EQ 1){
			ts.user_group_id=qG.user_group_id;
		}else{
			if(form.method EQ 'insert'){
				ts.user_group_id=form.user_group_id2;
			}else{
				structdelete(variables, 'user_group_id');
				structdelete(form,  'user_group_id');
				structdelete(ts,'user_group_id');
				ts.user_group_id=qU2.user_group_id;	
			}
		}
	}else if(form.method EQ "update"){
		ts.user_group_id=qU2.user_group_id;
	}
	form.user_group_id=ts.user_group_id;
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
	ts.site_id=request.zos.globals.id;
	if(application.zcore.user.checkGroupAccess("administrator") and structcount(request.zsession.user.limitManagerFeatureStruct) EQ 0){
		form.user_limit_manager_features=application.zcore.adminSecurityFilter.validateFeatureAccessList(application.zcore.functions.zso(form,'user_limit_manager_features'));
	}
	if(form.method EQ "update"){
		ts.user_id = form.user_id;
		result = userAdminCom.update(ts);
		if(result EQ false){
			application.zcore.status.setStatus(Request.zsid, 'Another user is already using that email address.',form,true);
			application.zcore.functions.zRedirect('/z/admin/member/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
		}


		contactCom=createobject("component", "zcorerootmapping.com.app.contact");
		contactCom.updateContactEmail(qU2.user_username, application.zcore.functions.zso(form,'member_email'), request.zos.globals.id);

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
			application.zcore.functions.zRedirect('/z/admin/member/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
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
		application.zcore.functions.zRedirect('/z/admin/member/add?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
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
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		returnMethod="index";
		if(form.returnMethod NEQ ""){
			returnMethod=form.returnMethod;
		}
		application.zcore.functions.zRedirect('/z/admin/member/#returnMethod#?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
	}else{ 
		application.zcore.functions.zRedirect('/z/admin/member/edit?user_id=#form.user_id#&zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#');
	}
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	var currentMethod=form.method;
	init();
	application.zcore.functions.zSetPageHelpId("5.2");
	form.user_id=application.zcore.functions.zso(form, 'user_id');
	db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user  
	WHERE user.user_id = #db.param(form.user_id)# and 
	user_deleted = #db.param(0)# and
	site_id=#db.param(request.zos.globals.id)# ";
	qMember=db.execute("qMember");
	application.zcore.functions.zQueryToStruct(qMember, form, "user_group_id");
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h2>
		<cfif currentMethod EQ 'add'>
			Add
		<cfelse>
			Edit
		</cfif>
		User</h2>
	Email and Password are used for login.  Be sure to write down your login should you wish to change it.  Fields with &quot;*&quot; are required. Please upload your photo in JPEG format.  It will automatically be resized.<br />
	<br />
	<form class="zFormCheckDirty" action="/z/admin/member/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?user_id=#form.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.returnMethod#&amp;searchtext=#URLEncodedFormat(form.searchtext)#" method="post" enctype="multipart/form-data">
		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-member-edit");
		if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
			cancelURL="/z/admin/member/#form.returnMethod#?ztv=1";
		}else{
			cancelURL="/z/admin/member/edit?user_id=#form.user_id#";
		}
		cancelURL&="&zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.returnMethod#&amp;searchtext=#URLEncodedFormat(form.searchtext)#";
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table  class="table-list">
			<cfif application.zcore.user.checkGroupAccess("administrator") and (request.zsession.user.id NEQ form.user_id or request.zsession.user.site_id NEQ request.zos.globals.id)>
				<cfscript>
				db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group WHERE 
				user_group_deleted = #db.param(0)# and 
				site_id = #db.param(request.zos.globals.id)#";
				if(not application.zcore.app.siteHasApp("listing")){ 
					db.sql&=" and user_group_name NOT IN (#db.param('broker')#)";// always allow agent: , #db.param('agent')#
				}
				db.sql&=" ORDER BY user_group_name ASC";
				qUserGroups=db.execute("qUserGroups");
				</cfscript>
				<tr>
					<th style="vertical-align:top; ">#application.zcore.functions.zOutputToolTip("Access Rights","<ul>
					<li>Administrator has access to everything, unless set to be limited.</li>
					<li>Agent can only update their own leads and profile.</li>
					<li>Member can login to the manager, but has access to nothing by default unless the developer provides them additional access.</li>
					<li>User doesn't have access to the manager, but can manage their account on the front of the web site.</li>
					<li>Other groups may have custom behavior, ask your web developer.</li>
					</ul>")#</th> 
					<td style="vertical-align:top; "><cfscript>
					if(form.user_group_id EQ "" or form.user_group_id EQ "0"){
						form.user_group_id=form.user_group_id2;
					}
					selectStruct = StructNew();
					selectStruct.name = "user_group_id";
					selectStruct.query = qUserGroups;
					selectStruct.hideSelect=true;
					selectStruct.queryLabelField = "user_group_friendly_name";
					selectStruct.queryValueField = "user_group_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>  
					</td>
				</tr>
			</cfif>
			<cfif application.zcore.user.checkGroupAccess("administrator")>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Office","member.member.edit office_id")#</th>
					<td><cfscript>
						db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# office 
						WHERE site_id = #db.param(request.zos.globals.id)# and 
						office_deleted = #db.param(0)# 
						ORDER BY office_name";
						qOffice=db.execute("qOffice");
						selectStruct = StructNew();
						selectStruct.name = "office_id";
						selectStruct.query = qOffice;
						selectStruct.hideSelect=true;
						selectStruct.queryParseLabelVars=true;
						selectStruct.queryLabelField = "##office_name##, ##office_address##";
						selectStruct.queryValueField = "office_id";
						selectStruct.multiple=true;
						application.zcore.functions.zSetupMultipleSelect(selectStruct.name, application.zcore.functions.zso(form, 'office_id'));
						application.zcore.functions.zInputSelectBox(selectStruct);
						</cfscript></td>
				</tr>
			</cfif>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("First Name","member.member.edit member_first_name")#</th>
				<td><input type="text" name="member_first_name" value="<cfif form.member_first_name EQ ''>#form.user_first_name#<cfelse>#form.member_first_name#</cfif>" size="30" /></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Last Name","member.member.edit member_last_name")#</th>
				<td><input type="text" name="member_last_name" value="<cfif form.member_last_name EQ ''>#form.user_last_name#<cfelse>#form.member_last_name#</cfif>" size="30" /></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Company","member.member.edit member_company")#</th>
				<td><input type="text" name="member_company" value="#form.member_company#" size="30" /></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Title","member.member.edit member_title")#</th>
				<td><input type="text" name="member_title" value="#form.member_title#" size="30" /></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Email","member.member.edit member_email")#</th>
				<td><input type="text" name="member_email" value="<cfif form.member_email EQ ''>#form.user_username#<cfelse>#form.member_email#</cfif>" size="30" /> *</td>
			</tr>
			<cfif currentMethod EQ "add">
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
							<td><input type="password" name="member_password" id="member_password" value="" size="30" /> *</td>
						</tr>
						<tr>
							<th>#application.zcore.functions.zOutputHelpToolTip("Confirm Password","member.member.edit member_password_confirm")#</th>
							<td><input type="password" name="member_password_confirm" id="member_password_confirm" value="" size="30" /> *</td>
						</tr>
					</table></td>
				</tr>
			<cfelse>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Password","member.member.edit member_password")#</th>
					<td><input type="password" name="member_password" id="member_password" value="" size="30" /> *
						<cfif currentMethod EQ "edit">
							<br />Leave empty unless you wish to change the password.
						</cfif></td>
				</tr>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Confirm Password","member.member.edit member_password_confirm")#</th>
					<td><input type="password" name="member_password_confirm" id="member_password_confirm" value="" size="30" /> *</td>
				</tr>

			</cfif>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("CC Email(s)","member.member.edit user_alternate_email")#</th>
				<td><input type="text" name="user_alternate_email" maxlength="255" value="#htmleditformat(form.user_alternate_email)#"  />
				<br />Note: Updates to assigned leads will be CC'd to this list of emails.  Comma separate multiple email addresses. You can't login as this user with alternate emails.</td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Phone","member.member.edit member_phone")#</th>
				<td><input type="text" name="member_phone" value="<cfif form.member_phone EQ ''>#form.user_phone#<cfelse>#form.member_phone#</cfif>" size="30" /></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Web Site","member.member.edit member_website")#</th>
				<td><input type="text" name="member_website" value="#form.member_website#" size="30" />
					<br />(URLs Must begin with http:// or https://)</td>
			</tr>
			<cfif application.zcore.app.siteHasApp("content") and application.zcore.app.getAppData("content").optionStruct.content_config_url_listing_user_id NEQ 0 and application.zcore.app.getAppData("content").optionStruct.content_config_url_listing_user_id NEQ "">
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Show Profile","member.member.edit member_public_profile")#</th>
					<td><input type="radio" name="member_public_profile" value="1" style="border:none; background:none;" <cfif form.member_public_profile EQ '1'>checked="checked"</cfif> />
						Yes (Make visible to public) |
						<input type="radio" name="member_public_profile" value="0" style="border:none; background:none;" <cfif form.member_public_profile EQ 0 or form.member_public_profile EQ ''>checked="checked"</cfif> />
						No </td>
				</tr>
			</cfif>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Hide Public Email?","member.member.edit user_hide_public_email")#</th>
				<td><input type="radio" name="user_hide_public_email" value="1" style="border:none; background:none;" <cfif form.user_hide_public_email EQ '1'>checked="checked"</cfif> />
					Yes |
					<input type="radio" name="user_hide_public_email" value="0" style="border:none; background:none;" <cfif form.user_hide_public_email EQ 0 or form.user_hide_public_email EQ ''>checked="checked"</cfif> />
					No </td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Photo","member.member.edit member_photo")#</th>
				<td>#application.zcore.functions.zInputImage('member_photo', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.memberImagePath,1,1), request.zos.globals.siteroot&request.zos.memberImagePath)# </td>
			</tr>
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
		</table>
		#tabCom.endFieldSet()# 
		#tabCom.beginFieldSet("Advanced")#
		<table style="  border-spacing:0px;" class="table-list">
			<cfif application.zcore.user.checkGroupAccess("administrator") and structcount(request.zsession.user.limitManagerFeatureStruct) EQ 0>
				<tr>
					<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Limit Manager Features","member.member.edit user_limit_manager_features")#</th>
					<td style="vertical-align:top; "> 
				<cfscript>
				adminSecurityFilterCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.adminSecurityFilter");
				adminSecurityFilterCom.getFormField("user_limit_manager_features");
				</cfscript>
				</td>
				</tr>
			</cfif>
			<cfif currentMethod EQ "edit" and request.zos.globals.disableOpenID EQ 0>
				<tr>
					<th>#application.zcore.functions.zOutputHelpToolTip("Sign In With","member.member.edit user_openid_provider")#</th>
					<td><cfscript>
					openIdCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.openid");
					writeoutput(openIdCom.displayOpenIdProviderForUser(qMember.user_id, qMember.site_id));
					</cfscript></td>
				</tr>
			</cfif>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Google+ URL","member.member.edit user_googleplus_url")#</th>
				<td><input type="text" name="user_googleplus_url" value="#form.user_googleplus_url#" size="30" /></td>
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
			<!--- <tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Alternate Contact Name","member.member.edit user_alternate_contact_name")#</th>
				<td><input type="text" name="user_alternate_contact_name" value="#htmleditformat(form.user_alternate_contact_name)#" size="30" /></td>
			</tr> --->
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
						<script type="text/javascript">/* <![CDATA[ */ 
							zmlsagentidarray=new Array();
							 /* ]]> */
							 </script>
							<table style="border-spacing:0px;">
								<cfloop query="qmls">
								<tr <cfif qmls.currentrow MOD 2 EQ 0>style="background-color:##EFEFEF;"</cfif>>
									<td><script type="text/javascript">/* <![CDATA[ */ 
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
							<br /><br /><script type="text/javascript">
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
							tempObj.url="/z/admin/member/lookupagentid?zmlsnum="+escape(document.getElementById("zmlsnum").value);
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
				<td colspan="2"><h2>Contact Preferences:</h2>
					<table class="table-list">
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
					</table>
					<cfif structkeyexists(request,'realestateprefform')>
						<hr size="1" />
						Are you already working with another real estate professional?<br />
						<input type="radio" style="border:none; background:none;"  name="user_pref_realtor" value="1" <cfif form.user_pref_realtor EQ '1'>checked="checked"</cfif> />
						yes&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" style="border:none; background:none;"  name="user_pref_realtor" value="0" <cfif form.user_pref_realtor EQ '0' or form.user_pref_realtor EQ ''>checked="checked"</cfif> />
						no
						<hr size="1" />
						Would you like notified when there are new Hot Deals?<br />
						<input type="radio" style="border:none; background:none;"  name="user_pref_hotdeals" value="1" <cfif form.user_pref_hotdeals EQ '1' or form.user_pref_hotdeals EQ ''>checked="checked"</cfif> />
						yes&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" style="border:none; background:none;"  name="user_pref_hotdeals" value="0" <cfif form.user_pref_hotdeals EQ '0'>checked="checked"</cfif> />
						no
					</cfif>
					<hr size="1" />
					Are you interested in receiving information on new products &amp; services we may have in the future?<br />
					<input type="radio" style="border:none; background:none;"  name="user_pref_new" value="1" <cfif form.user_pref_new EQ '1' or form.user_pref_new EQ ''>checked="checked"</cfif> />
					yes&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" style="border:none; background:none;"  name="user_pref_new" value="0" <cfif form.user_pref_new EQ '0'>checked="checked"</cfif> />
					no
					<cfif structkeyexists(request,'realestateprefform') eq false>
						<hr size="1" />
						May we share your contact information with our partners who may offer you related products and services?<br />
						<input type="radio" style="border:none; background:none;"  name="user_pref_sharing" value="1" <cfif form.user_pref_sharing EQ '1'>checked="checked"</cfif> />
						yes&nbsp;&nbsp;&nbsp;&nbsp;
						<input type="radio" style="border:none; background:none;"  name="user_pref_sharing" value="0" <cfif form.user_pref_sharing EQ '0' or form.user_pref_sharing EQ ''>checked="checked"</cfif> />
						no
					</cfif>
					<hr size="1" />
					What email format do you prefer?<br />
					<input type="radio" style="border:none; background:none;"  name="user_pref_html" value="1" <cfif form.user_pref_html EQ '1' or form.user_pref_html EQ ''>checked="checked"</cfif> />
					HTML&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" style="border:none; background:none;"  name="user_pref_html" value="0" <cfif form.user_pref_html EQ '0'>checked="checked"</cfif> />
					Plain Text<br />
					<br />
					<h2>Additional Contact Information:</h2>
					<table style="border-spacing:0px;">
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
					</table></td>
			</tr>
			<cfif request.zos.globals.parentid EQ 0 and variables.qPAll323.recordcount NEQ 0>
				<cfif (form.user_access_site_children EQ "" or form.user_access_site_children EQ 0)>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Sync User With<br />Your Other Web Sites","member.member.edit user_sync_site_id_list")#</th>
						<td><cfloop query="variables.qPAll323">
								<input type="checkbox" name="user_sync_site_id_list" value="#variables.qPAll323.site_id#" style="border:none; background:none;" <cfif find(",#variables.qPAll323.site_id#,", ","&form.user_sync_site_id_list&",") NEQ 0>checked="checked"</cfif> />
								#variables.qPAll323.site_short_domain#<br />
							</cfloop></td>
					</tr>
				<cfelse>
					<tr>
						<th>#application.zcore.functions.zOutputHelpToolTip("Sync User With<br />Your Other Web Sites","member.member.edit syncMemberWith")#</th>
						<td>Login Access Granted to These Domains:<br />
							#request.zos.globals.shortdomain#<br />
							<cfloop query="variables.qPAll323">
								#variables.qPAll323.site_short_domain#<br />
							</cfloop></td>
					</tr>
				</cfif>
			</cfif>
			<cfif application.zcore.user.checkServerAccess()>
				<tr>
					<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Enable Widget Builder?","member.member.edit user_enable_widget_builder")#</th>
					<td style="vertical-align:top; ">#application.zcore.functions.zInput_Boolean("user_enable_widget_builder", form.user_enable_widget_builder)#</td>
				</tr>
			</cfif>
	
		</table>
		#tabCom.endFieldSet()# 
		#tabCom.endTabMenu()#
	</form>
</cffunction>

<cffunction name="resendInvite" localmode="modern" access="remote" roles="member">
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
		application.zcore.functions.zRedirect("/z/admin/member/#form.returnMethod#?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#");
	}
	rpCom=createobject("component", "zcorerootmapping.com.user.user_admin");
	result=rpCom.resendInvite(qUser.user_id);
	if(result){
		application.zcore.status.setStatus(request.zsid, "Invitation email was resent to #qUser.user_username#");
	}else{
		application.zcore.status.setStatus(request.zsid, "Failed to send invitation email", form, true);
	}
	returnMethod="index";
	if(form.returnMethod NEQ ""){
		returnMethod=form.returnMethod;
	}
	application.zcore.functions.zRedirect("/z/admin/member/#returnMethod#?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#");
	</cfscript>
</cffunction>

<cffunction name="sendUserPasswordResetEmail" localmode="modern" access="remote" roles="member">
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
		application.zcore.functions.zRedirect("/z/admin/member/#form.returnMethod#?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#");
	}
	rpCom=createobject("component", "zcorerootmapping.mvc.z.user.controller.reset-password");
	rs=rpCom.sendPasswordResetEmail(qUser.user_username, qUser.site_id);
	if(rs.success){
		application.zcore.status.setStatus(request.zsid, "Password reset email sent to #qUser.user_username#");
	}else{
		application.zcore.status.setStatus(request.zsid, rs.errorMessage, form, true);
	}
	returnMethod="index";
	if(form.returnMethod NEQ ""){
		returnMethod=form.returnMethod;
	}
	application.zcore.functions.zRedirect("/z/admin/member/#returnMethod#?zsid=#request.zsid#&zIndex=#form.zIndex#&ugid=#form.ugid#&returnMethod=#form.returnMethod#&searchtext=#URLEncodedFormat(form.searchtext)#");
	</cfscript>
</cffunction>


<cffunction name="showPublicUsers" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	request.zsession.showallusers=true;
	//form.ugid=application.zcore.functions.zso(variables, 'userUserGroupId', true);
	index();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qMember=0;
	var searchStruct=0;
	var searchNav=0;
	var qCount=0;  
	perpage=30;
	if(form.method NEQ "showPublicUsers"){
		request.zsession.showallusers=false;
		init();
	}
	searchOn=false;
	form.showall=application.zcore.functions.zso(form, 'showall', true, 0);
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
	user_server_administrator = #db.param('0')#";
	if(structkeyexists(form, 'office_id') and trim(form.office_id) NEQ ''){
		db.sql&=" and FIND_IN_SET(#db.param(form.office_id)#, user.office_id) >= #db.param(1)#";
	}
	if(structkeyexists(form, 'ugid') and trim(form.ugid) NEQ '0'){
		db.sql&=" and user.user_group_id = #db.param(form.ugid)# ";
		searchOn=true;
	}else{
		if(form.method NEQ "showPublicUsers"){
			db.sql&=" and user.user_group_id IN (#db.trustedSQL(variables.memberAccessGroupIdList)#) ";
		}else{
			db.sql&=" and user.user_group_id NOT IN (#db.trustedSQL(variables.memberAccessGroupIdList)#) ";
		}

	}
	/*if(request.zsession.showallusers EQ false){
		db.sql&=" and user.user_group_id <> #db.param(variables.userUserGroupId)#";
	}*/
	if(structkeyexists(form, 'searchtext') and trim(form.searchtext) NEQ ''){
		searchOn=true;
		db.sql&=" and concat(user.user_id,#db.param(' ')#, #db.param(' ')#, member_company, #db.param(' ')#,
		user_first_name,#db.param(' ')#,user_last_name,#db.param(' ')#,user_username) like #db.param("%#form.searchtext#%")#";
	} 
	qCount=db.execute("qCount");  
	db.sql="SELECT *, user.site_id usersiteid, user.site_id membersiteid 
	FROM #db.table("user", request.zos.zcoreDatasource)# user , 
	#db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE  
	user_deleted = #db.param(0)# and 
	user_group_deleted = #db.param(0)# and 
	user.site_id = user_group.site_id and 
	user.user_group_id = user_group.user_group_id and 
	user.site_id = #db.param(request.zos.globals.id)# and 
	user_server_administrator = #db.param('0')#";
	if(structkeyexists(form, 'office_id') and trim(form.office_id) NEQ ''){
		db.sql&=" and FIND_IN_SET(#db.param(form.office_id)#, user.office_id) >= #db.param(1)#";
	}
	if(structkeyexists(form, 'ugid') and trim(form.ugid) NEQ '0'){
		db.sql&=" and user.user_group_id = #db.param(form.ugid)# ";
	}else{
		if(form.method NEQ "showPublicUsers"){
			db.sql&=" and user.user_group_id IN (#db.trustedSQL(variables.memberAccessGroupIdList)#) ";
		}else{
			db.sql&=" and user.user_group_id NOT IN (#db.trustedSQL(variables.memberAccessGroupIdList)#) ";
		}
	}
	/*if(request.zsession.showallusers EQ false){
		db.sql&=" and user.user_group_id <> #db.param(variables.userUserGroupId)#";
	}*/
	if(structkeyexists(form, 'searchtext') and trim(form.searchtext) NEQ ''){
		db.sql&=" and concat(user.user_id,#db.param(' ')#, #db.param(' ')#, member_company, #db.param(' ')#,
		user_first_name,#db.param(' ')#,user_last_name,#db.param(' ')#,user_username) like #db.param("%#form.searchtext#%")#";
	}
	db.sql&=" ORDER BY member_sort asc, user_first_name, user_last_name ";
	if(form.showall EQ 0){
		db.sql&=" LIMIT #db.param((form.zIndex-1)*perpage)#,#db.param(perpage)# ";
	}
	qMember=db.execute("qMember");

	/* todo: finish last login
	arrUsername=[];
	for(row in qMember){
		arrayAppend(arrUsername, row.user_email);
	}
	db.sql="select login_log_username, max(login_log_datetime) lastDate from #db.table("login_log", request.zos.zcoreDatasource)# WHERE 
	login_log_username in (#db.trustedSQL("'"&arrayToList(arrUsername, "','")&"'")#) and 
	site_id=#db.param(request.zos.globals.id)# and 
	login_log_deleted=#db.param(0)# ";
	qLoginLog=db.execute("qLoginLog");
*/

	db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	user_group_deleted = #db.param(0)# ";
	if(not application.zcore.app.siteHasApp("listing")){ 
		db.sql&=" and user_group_name NOT IN (#db.param('broker')#)";// always allow agent: , #db.param('agent')#
	}
	db.sql&=" ORDER BY user_group_name";
	qUserGroup=db.execute("qUserGroup");

	echo('<div class="z-manager-list-view">');

	form.user_group_id=application.zcore.functions.zso(form, 'user_group_id', true);
    </cfscript>
    <div class="z-float z-mb-10">
		<h2 style="display:inline; ">
			<cfif form.ugid NEQ 0>
				Search Users
			<cfelseif form.method EQ "showPublicUsers">
				Public Users
				<cfscript>
				if(form.user_group_id EQ "0"){
					form.user_group_id=variables.userUserGroupIdCopy;
				}
				</cfscript>
			<cfelse>
				Site Manager Users
			</cfif>
		</h2>
		&nbsp;&nbsp;
		<cfif not request.zos.globals.enableDemoMode>
			<a href="/z/admin/member/add?zIndex=#form.zIndex#&amp;user_group_id=#form.user_group_id#&amp;ugid=#form.ugid#&returnMethod=#form.returnMethod#&amp;searchtext=#URLEncodedFormat(form.searchtext)#" class="z-manager-search-button">Add</a>
		</cfif>
	</div>
		<!--- <cfif form.method EQ "showPublicUsers">
			<a href="/z/admin/member/index">Site Manager Users</a> | 
		<cfelse>
			<a href="/z/admin/member/showPublicUsers">Public Users</a> | 
		</cfif>
	<cfif not request.zos.globals.enableDemoMode>
		<a href="/z/admin/member/add?zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.returnMethod#&amp;searchtext=#URLEncodedFormat(form.searchtext)#">Add User</a> |
		<cfif application.zcore.user.checkGroupAccess("administrator")>
			<a href="/z/admin/member/import">Import Users</a> |
		</cfif>
	</cfif> 
	<a href="/z/misc/members/index" target="_blank">View Public Profiles</a>	| 
	<a href="/z/user/home/index" target="_blank">View Public User Home Page</a> | 
	<a href="/z/admin/office/index">Manage Offices</a><br />
	<br />  --->
	<form action="/z/admin/member/#form.method#" method="get" enctype="multipart/form-data">
		<div class="z-float z-mb-10">
			<div class="z-float-left z-pr-10 z-pb-10">Keyword: 
					<input type="text" name="searchtext" style="min-width:auto; width:250px;" value="#application.zcore.functions.zso(form, 'searchtext')#" size="30" />
			</div>
			<div class="z-float-left z-pr-10 z-pb-10">
				Access Rights:  
				<cfscript>
				selectStruct = StructNew();
				selectStruct.name = "ugid";
				selectStruct.query = qUserGroup; 
				selectStruct.queryLabelField = "user_group_friendly_name";
				selectStruct.queryValueField = "user_group_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
			</div>
			<cfif application.zcore.user.checkGroupAccess("administrator")>
				<div class="z-float-left z-pr-10 z-pb-10">
				#application.zcore.functions.zOutputHelpToolTip("Office","member.member.edit office_id")#:  
				<cfscript>
					db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# office 
					WHERE site_id = #db.param(request.zos.globals.id)# and 
					office_deleted = #db.param(0)# 
					ORDER BY office_name";
					qOffice=db.execute("qOffice");
					selectStruct = StructNew();
					selectStruct.name = "office_id";
					selectStruct.query = qOffice;
					selectStruct.hideSelect=false;
					selectStruct.queryParseLabelVars=true;
					selectStruct.queryLabelField = "##office_name##, ##office_address##";
					selectStruct.queryValueField = "office_id";
					selectStruct.multiple=false;
					application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
			</div>
			</cfif>

			<div class="z-float-left z-pr-10 z-pb-10">
					<input type="submit" name="submitForm" value="Search" class="z-manager-search-button" />
				<cfif searchOn>
					<input type="button" name="cancel" value="Clear Search" class="z-manager-search-button" onclick="window.location.href='/z/admin/member/#form.returnMethod#';" />
				</cfif>
			</div>
		</div>
	</form>
	<cfscript>
	if(qmember.recordcount EQ 0 and form.zIndex NEQ 1){
		application.zcore.functions.zredirect('/z/admin/member/#form.returnMethod#?zindex='&max(1, form.zIndex-1));
	}
	searchNav="";
	if(form.showall EQ 0){
		searchStruct = StructNew();
		searchStruct.count = qcount.count;
		searchStruct.index = form.zIndex;
		searchStruct.showString = "Results ";
		searchStruct.url ="/z/admin/member/#form.method#?searchtext=#URLEncodedFormat(form.searchtext)#&ugid=#form.ugid#&returnMethod=#form.returnMethod#";
		searchStruct.indexName = "zIndex";
		searchStruct.buttons = 5;	
			searchStruct.perpage = perpage;
		if(searchStruct.count LTE searchStruct.perpage){
			searchNav="";
		}else{
			searchNav = '<div class="z-float z-mb-10">'&application.zcore.functions.zSearchResultsNav(searchStruct)&'</div>';
		}
	}
	</cfscript>
	#searchNav# 
	<table id="sortRowTable" style="width:100%;"  class="table-list">
		<thead>
		<tr>
			<th>ID</th>
			<th>Office(s)</th>
			<th>Company</th>
			<th>Name</th>
			<th>Email</th>
			<th>Phone</th>
			<th>Access Rights</th>
			<th>Photo</th>
			<th>Last Login</th> 
			<th>Updated</th> 
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
				<cfif qMember.office_id NEQ "">
					<cfscript>
						var sInTag 	= " AND office_id IN (#qMember.office_id#)"
						var sOffice	= "";
						db.sql="SELECT office_name 
						FROM #db.table("office", request.zos.zcoreDatasource)# office 
						WHERE site_id = #db.param(request.zos.globals.id)# 
						AND office_deleted = #db.param(0)# 
						#db.trustedSQL(sInTag)#
						ORDER BY office_name";
						qOfficeData = db.execute("qOfficeData");
						for(office in qOfficeData){
							sOffice &= office.office_name & ",";
						}
						if(LEN(sOffice) GT 1){
							sOffice = Mid(sOffice,1,LEN(sOffice)-1);
						}
						if(LEN(sOffice) GT 50){
							//FIND LAST COMMA
							pos = Find(",", sOffice,40);
							if(pos NEQ 0)
								sOffice = Mid(sOffice,1,pos-1) & "...";
							else
								sOffice &= "...";
						}
					</cfscript>
					<td>#sOffice#</td>	
				<cfelse>
					<td>No Office</td>
				</cfif>
				<td>#qMember.member_company#&nbsp;</td>
				<td><cfif qMember.member_first_name EQ ''>
						#qMember.user_first_name# #qMember.user_last_name#
					<cfelse>
						#qMember.member_first_name# #qMember.member_last_name#
					</cfif>
					&nbsp;</td>
				<td><cfif qMember.member_email EQ ''>
						#qMember.user_username#
					<cfelse>
						#qMember.member_email#
					</cfif>
					&nbsp;</td>
				<td>#qMember.member_phone#&nbsp;</td>
				<td>#qMember.user_group_friendly_name#</td>
				<td><cfif qMember.member_photo NEQ ''>
						<img src="#application.zcore.functions.zvar('domain',qMember.userSiteId)##request.zos.memberImagePath##qMember.member_photo#" width="90" />
					<cfelse>
						&nbsp;
					</cfif></td> 
				<td>#dateformat(qMember.user_last_login_datetime, "m/d/yyyy")&" "&timeformat(qMember.user_last_login_datetime, "h:mm tt")#</td>  
				<td>#application.zcore.functions.zTimeSinceDate(qMember.user_updated_datetime)#</td>
				<td class="z-manager-admin">
					<cfif (qCount.count LTE perpage or form.showall EQ 1) and qMember.member_public_profile EQ 1 and qMember.user_group_id NEQ variables.userUserGroupId>#variables.queueSortCom.getAjaxHandleButton(qMember.user_id)#</cfif> 
					<cfif variables.userUserGroupIdCopy EQ qMember.user_group_id>
						<cfif qMember.user_active EQ 1> 

							<div class="z-manager-button-container">
								<a href="/z/admin/member/disable?user_id=#qMember.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.returnMethod#&amp;searchtext=#URLEncodedFormat(form.searchtext)#" class="z-manager-view" title="Enabled, click to disable"><i class="fa fa-check-circle" aria-hidden="true" style="color:##090;"></i></a>
							</div>
						<cfelse>

							<div class="z-manager-button-container">
								<a href="/z/admin/member/enable?user_id=#qMember.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.returnMethod#&amp;searchtext=#URLEncodedFormat(form.searchtext)#" class="z-manager-view" title="Disabled, click to enable"><i class="fa fa-times-circle" aria-hidden="true" style="color:##900;"></i></a>
							</div>
						</cfif> 
					<cfelse>
						<cfif qMember.member_public_profile EQ 1>
							<cfif application.zcore.functions.zso(application.zcore.app.getAppData("content").optionstruct,'content_config_url_listing_user_id',true) NEQ 0>
								<div class="z-manager-button-container"> 
									<a href="/#application.zcore.functions.zURLEncode(lcase(qMember.member_first_name&'-'&qMember.member_last_name),'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id#-#qMember.user_id#.html" class="z-manager-view" target="_blank" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a>
								</div>
							</cfif>
						</cfif>
					</cfif>
					<cfif request.zos.globals.enableDemoMode>
						DEMO | Admin disabled
						<cfelse>
						<cfif qMember.userSiteId EQ qMember.memberSiteId>

							<div class="z-manager-button-container"> 
								<a href="##" class="z-manager-edit" id="z-manager-edit#row.user_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
								<div class="z-manager-edit-menu">
									<a href="/z/admin/member/edit?user_id=#qMember.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.method#&amp;searchtext=#URLEncodedFormat(form.searchtext)#" title="Edit">Edit</i></a>  
									<a href="##" onclick="if(window.confirm('Are you send you want to send a password reset email to #qMember.user_username#?')){ window.location.href='/z/admin/member/sendUserPasswordResetEmail?user_id=#qMember.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.method#&amp;searchtext=#URLEncodedFormat(form.searchtext)#'; } return false;">Send Reset Password Email</a>
									<cfif qMember.user_invited EQ 1> 
										<a href="##" onclick="if(window.confirm('Are you send you want to send a new invitation email to #qMember.user_username#?')){ window.location.href='/z/admin/member/resendInvite?user_id=#qMember.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.method#&amp;searchtext=#URLEncodedFormat(form.searchtext)#'; } return false;">Re-send Invite</a>
									</cfif>
									<cfif application.zcore.app.siteHasApp("blog") and application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_url_author_id', true) NEQ 0 and application.zcore.functions.zso(application.zcore.app.getAppData("blog").optionStruct, 'blog_config_disable_author', true, 0) EQ 0> 
										<a href="#application.zcore.app.getAppCFC("blog").getAuthorLink(row)#" target="_blank">Articles</a>
									</cfif>
								</div> 
							</div>  
 

							<cfif qMember.usersiteid EQ qMember.memberSiteId and (request.zsession.user.id NEQ qMember.user_id or request.zsession.user.site_id NEQ request.zos.globals.id)>
								<div class="z-manager-button-container"> 
									<a href="/z/admin/member/delete?user_id=#qMember.user_id#&amp;zIndex=#form.zIndex#&amp;ugid=#form.ugid#&returnMethod=#form.method#&amp;searchtext=#URLEncodedFormat(form.searchtext)#" class="z-manager-delete"><i class="fa fa-trash" aria-hidden="true"></i></a>
								</div>
							</cfif>
						<cfelse>
							<div class="z-manager-button-container"> 
								<a href="##" class="z-manager-edit" id="z-manager-edit#row.user_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
								<div class="z-manager-edit-menu">
									<a href="#application.zcore.functions.zvar('domain',qMember.userSiteId)#/z/admin/member/edit?user_id=#qMember.user_id#" rel="external" onclick="window.open(this.href); return false;">Edit on Parent Site</a>
								</div>
							</div>
						</cfif>
					</cfif>
					&nbsp;</td>
			</tr>
		</cfloop>
		</tbody>
	</table>
	#searchNav#
	</div>
</cffunction>


<cffunction name="getImportUserFields" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Users");	
	rs={
		arrRequired:listToArray("user_email	user_password", chr(9)),
		arrOptional:listToArray("user_first_name	user_last_name	user_phone	user_fax	user_street	user_street2	user_city	user_state	user_country	user_zip	user_pref_html	user_pref_phone	user_pref_fax	user_pref_list	user_pref_mail	user_pref_email	user_pref_new	user_pref_sharing	user_googleplus_url	user_twitter_url	user_facebook_url	user_openid_id	user_openid_provider	user_openid_email	user_openid_required	user_birthday	user_gender	user_alternate_email	user_alternate_contact_name", chr(9))
	};
	return rs;
	</cfscript>
</cffunction>

<cffunction name="import" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var row=0;
	var qOption=0;
	var db=request.zos.queryObject;  
	application.zcore.functions.zSetPageHelpId("5.3");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Users");	
	rs=this.getImportUserFields();
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<p><a href="/z/admin/member/index">Manage Users</a> /</p>
	<h2>Import Users</h2> 
	<p>The first row of the CSV file should contain the required fields and as many optional fields as you wish.</p>
	<p>Any extra columns in the CSV file will cause an error and that data will not be imported.</p>
	<p><strong>Important:</strong> passwords must be 8 or more characters.  Password encoding takes around half a second per password.  It is intentionally slow to improve security.</p>
	<p>Required fields:<br /><textarea type="text" cols="100" rows="2" name="a1">#arrayToList(rs.arrRequired, chr(9))#</textarea></p>
	<p>Optional fields:<br /><textarea type="text" cols="100" rows="2" name="a2">#arrayToList(rs.arrOptional, chr(9))#</textarea></p>
	<form class="zFormCheckDirty" action="/z/admin/member/processImport" enctype="multipart/form-data" method="post">
		<h2>Select a user group for these users to be assigned to:</h2> 
		<p><cfscript> 
		db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		user_group_deleted = #db.param(0)# 
		ORDER BY user_group_name";
		qUserGroup=db.execute("qUserGroup");
		selectStruct = StructNew();
		selectStruct.name = "user_group_id";
		selectStruct.query = qUserGroup;
		selectStruct.queryLabelField = "user_group_name";
		selectStruct.queryValueField = "user_group_id";
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript> *</p>
		<h2>Select a properly formatted CSV file to upload</h2>
		<p><input type="file" name="filepath" value="" /></p>
		<cfif request.zos.isDeveloper>
			<h2>Specify optional CFC filter.</h2>
			<p>A struct with each column name as a key will be passed as the first argument to your custom function.</p>
			<p>Code example<br />
			<textarea type="text" cols="100" rows="4" name="a3">#htmleditformat('<cfcomponent>
			<cffunction name="importFilter" localmode="modern" roles="member">
			<cfargument name="struct" type="struct" required="yes">
			<cfscript>
			if(arguments.struct["user_first_name"] EQ "bad value"){
				arguments.struct["user_first_name"]="correct value";
			}
			</cfscript>
			</cffunction>
			</cfcomponent>')#</textarea></p>
			<p>Filter CFC CreateObject Path: <input type="text" name="cfcPath" value="" /> (i.e. root.myImportFilter)</p>
			<p>Filter CFC Method: <input type="text" name="cfcMethod" value="" /> (i.e. functionName)</p>
		</cfif>
		<h2>Then click Import CSV</h2>
		<p><input type="submit" name="submit1" value="Import CSV" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
		<div id="pleaseWait" style="display:none;">Please wait...</div>
		</p>
		
	</form>
</cffunction>


<cffunction name="processImport" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;  
	application.zcore.adminSecurityFilter.requireFeatureAccess("Users", true);	
	setting requesttimeout="30000";
	defaultStruct={}; 
	defaultStruct.user_group_id=application.zcore.functions.zso(form, 'user_group_id');
	db.sql="select * from #db.table("user_group", request.zos.zcoreDatasource)# WHERE 
	user_group_id = #db.param(defaultStruct.user_group_id)# and 
	user_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qS=db.execute("qS");
	if(qS.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "User group doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/admin/member/import?zsid=#request.zsid#");
	}
	rs=this.getImportUserFields();
	requiredStruct={};
	optionalStruct={}; 
	dataStruct={};
	
	
	for(i=1;i LTE arraylen(rs.arrRequired);i++){
		requiredStruct[rs.arrRequired[i]]=true;
		defaultStruct[rs.arrRequired[i]]="";
	}
	for(i=1;i LTE arraylen(rs.arrOptional);i++){
		optionalStruct[rs.arrOptional[i]]=true;
		defaultStruct[rs.arrOptional[i]]="";
	}
	if(structkeyexists(form, 'filepath') EQ false or form.filepath EQ ""){
		application.zcore.status.setStatus(request.zsid, "You must upload a CSV file", true);
		application.zcore.functions.zRedirect("/z/admin/member/import?zsid=#request.zsid#");
	}
	f1=application.zcore.functions.zuploadfile("filepath", request.zos.globals.privatehomedir&"/zupload/user/",false);
	fileContents=application.zcore.functions.zreadfile(request.zos.globals.privatehomedir&"/zupload/user/"&f1);
	d1=application.zcore.functions.zdeletefile(request.zos.globals.privatehomedir&"/zupload/user/"&f1);
	 
	dataImportCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.dataImport");
	dataImportCom.parseCSV(fileContents);
	dataImportCom.getFirstRowAsColumns(); 
	requiredCheckStruct=duplicate(requiredStruct); 
	ts=StructNew();
	for(n=1;n LTE arraylen(dataImportCom.arrColumns);n++){
		dataImportCom.arrColumns[n]=trim(dataImportCom.arrColumns[n]);
		if(not structkeyexists(defaultStruct, dataImportCom.arrColumns[n]) ){
			application.zcore.status.setStatus(request.zsid, "#dataImportCom.arrColumns[n]# is not a valid column name.  Please rename columns to match the supported fields or delete extra columns so no data is unintentionally lost during import.", false, true);
			application.zcore.functions.zRedirect("/z/admin/member/import?zsid=#request.zsid#");
		}
		structdelete(requiredCheckStruct, dataImportCom.arrColumns[n]);
		if(structkeyexists(ts, dataImportCom.arrColumns[n])){
			application.zcore.status.setStatus(request.zsid, "The column , ""#dataImportCom.arrColumns[n]#"",  has 1 or more duplicates.  Make sure only one column is used per field name.", false, true);
			application.zcore.functions.zRedirect("/z/admin/member/import?zsid=#request.zsid#");
		}
		ts[dataImportCom.arrColumns[n]]=dataImportCom.arrColumns[n];
	}
	if(structcount(requiredCheckStruct)){
		application.zcore.status.setStatus(request.zsid, "The following required fields were missing in the column header of the CSV file: "&structKeyList(requiredCheckStruct)&".", false, true);
		application.zcore.functions.zRedirect("/z/admin/member/import?zsid=#request.zsid#"); 
	} 
	dataImportCom.mapColumns(ts);
	arrData=arraynew(1);
	curCount=dataImportCom.getCount();
	for(g=1;g  LTE curCount;g++){
		ts=dataImportCom.getRow();	
		for(i in requiredStruct){
			if(trim(ts[i]) EQ ""){
				application.zcore.status.setStatus(request.zsid, "#i# was empty on row #g# and it is a required field.  Make sure all required fields are entered and re-import.", false, true);
				application.zcore.functions.zRedirect("/z/admin/member/import?zsid=#request.zsid#"); 
			}
		}
	}
	dataImportCom.resetCursor();
	//dataImportCom.skipLine();
	filterEnabled=false;
	if(request.zos.isDeveloper){
		if(form.cfcPath NEQ "" and form.cfcMethod NEQ ""){
			if(left(form.cfcPath, 5) EQ "root."){
				form.cfcPath=request.zrootcfcpath&removechars(form.cfcPath, 1, 5);
			}
			filterInstance=application.zcore.functions.zcreateobject("component", form.cfcPath, true);	
			filterEnabled=true;
		}
	}
	userAdminCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.user_admin");
	request.zDisableNewMemberEmail=true;
	for(g=1;g  LTE curCount;g++){
		ts=dataImportCom.getRow();	
		for(i in ts){
			ts[i]=trim(ts[i]);
			if(len(ts[i]) EQ 0){
				structdelete(ts, i);
			}
		}
		if(filterEnabled){
			filterInstance[form.cfcMethod](ts);
		}
		ts.user_updated_datetime = request.zos.mysqlnow;
		ts.user_updated_ip =request.zos.cgi.remote_addr;
		ts.member_updated_datetime=ts.user_updated_datetime;
		ts.member_address=application.zcore.functions.zso(ts, 'user_street');
		ts.member_address2=application.zcore.functions.zso(ts, 'user_street2');
		ts.member_city=application.zcore.functions.zso(ts, 'user_city');
		ts.member_state=application.zcore.functions.zso(ts, 'user_state');
		ts.member_zip=application.zcore.functions.zso(ts, 'user_zip');
		ts.member_country=application.zcore.functions.zso(ts, 'user_country');
		ts.member_phone=application.zcore.functions.zso(ts, 'user_phone');
		ts.member_fax=application.zcore.functions.zso(ts, 'user_fax');
		ts.member_affiliate_opt_in=application.zcore.functions.zso(ts, 'user_pref_sharing');
		ts.member_first_name = application.zcore.functions.zso(ts, 'user_first_name');
		ts.member_last_name = application.zcore.functions.zso(ts, 'user_last_name');
		if(not application.zcore.functions.zEmailValidate(ts.user_email)){
			application.zcore.status.setStatus(request.zsid, "Line ###g# has an invalid email address, ""#ts.user_email#"", and it was not imported.", form, true);
			continue;
		} 
		ts.user_username=ts.user_email;
		ts.sendConfirmOptIn=false;
		structappend(ts, defaultStruct, false);  
		ts.site_id=request.zos.globals.id;
		//writedump(ts);		writedump(form);		abort; 
		user_id = userAdminCom.add(ts);
		if(user_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Line ###g# with email address, ""#ts.user_email#"", failed to be imported. Make sure the email is valid and the password is 8 or more characters.", form, true);
		}
		arrayClear(request.zos.arrQueryLog);
	} 
	application.zcore.status.setStatus(request.zsid, "Import complete.");
	application.zcore.functions.zRedirect("/z/admin/member/import?zsid=#request.zsid#");
	 
	</cfscript>
</cffunction> 


</cfoutput>
</cfcomponent>
