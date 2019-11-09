<cfcomponent extends="zcorerootmapping.com.zos.controller">
	<cfproperty name="menuModel" type="zcorerootmapping.mvc.z.admin.model.menuModel">
<cfoutput>

<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	form.site_id=request.zos.globals.id;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Menus");	

	if(structkeyexists(form, 'menu_button_id') or structkeyexists(form, 'menu_id')){
		variables.queueSortStruct = StructNew();
		// required
		if(structkeyexists(form, 'menu_button_id') and form.method NEQ "manageMenu" and form.method NEQ "deleteItem" and form.method NEQ "insertItem" and form.method NEQ "updateItem"){
			variables.queueSortStruct.tableName = "menu_button_link";
			variables.queueSortStruct.sortFieldName = "menu_button_link_sort";
			variables.queueSortStruct.primaryKeyName = "menu_button_link_id";
			variables.queueSortStruct.where="site_id = '#application.zcore.functions.zescape(form.site_id)#' and 
			menu_button_id='"&application.zcore.functions.zescape(form.menu_button_id)&"' and menu_button_link_deleted='0' ";
			
		}else if(structkeyexists(form, 'menu_id')){
			variables.queueSortStruct.tableName = "menu_button";
			variables.queueSortStruct.sortFieldName = "menu_button_sort";
			variables.queueSortStruct.primaryKeyName = "menu_button_id";
			variables.queueSortStruct.where="site_id = '#application.zcore.functions.zescape(form.site_id)#' and 
			menu_id='"&application.zcore.functions.zescape(form.menu_id)&"' and menu_button_deleted='0' ";
		}
		// optional
		variables.queueSortStruct.disableRedirect=true;
		variables.queueSortStruct.datasource=request.zos.zcoreDatasource;
		variables.queueSortStruct.ajaxTableId="menuLinkTable";
		if(form.method EQ "manageItemLinks"){
			variables.queueSortStruct.ajaxURL='/z/admin/menu/manageItemLinks?menu_id=#form.menu_id#&menu_button_id=#form.menu_button_id#';
		}else if(form.method EQ "manageMenu"){
			variables.queueSortStruct.ajaxURL='/z/admin/menu/manageMenu?menu_id=#form.menu_id#';
		} 
		
		variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
		
		if(structkeyexists(variables.queueSortStruct,'tableName')){
			variables.queueSortCom.init(variables.queueSortStruct);
		}
		if(structkeyexists(form, 'zQueueSort')){
			application.zcore.functions.zMenuClearCache({all=true});
			application.zcore.functions.zredirect(request.cgi_script_name&"?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
		}
		if(structkeyexists(form, 'zQueueSortAjax')){
			application.zcore.functions.zMenuClearCache({all=true});
			variables.queueSortCom.returnJson();
		}
	}
	</cfscript>
</cffunction>

<cffunction name="copy" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var n2=0;
	var i=0;
	var arrI=0;
	var arrF=0;
	var qId=0;
	var newcodename22=0;
	var q=0;
	var sql=0;
	var qC=0;
	var arrT=0;
	var qS2=0;
	var n=0;
	var qI=0;
	var newmenubuttonid=0;
	var cfcatch=0;
	var buttonidstruct=0;
	var newmenuid=0;
	var qT=0;
	var arrS=0;
	var qS=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.3.6");
	</cfscript>
	<h2>Copy Menu</h2>
	<cfif application.zcore.functions.zso(form, 'newname') EQ "">
		<cfscript>
		qS=variables.menuModel.getById(form.menu_id);
		</cfscript>
		Selected Menu: #qs.menu_name#<br />
		<br />
		<form class="zFormCheckDirty" action="/z/admin/menu/copy" method="get">
			<input type="hidden" name="menu_id" value="#htmleditformat(form.menu_id)#" />
			<table style="border-spacing:0px; padding:5px;">
				<tr>
					<td>New Menu Name: </td>
					<td><input type="text" name="newname" value="#htmleditformat(qs.menu_name)#" /></td>
				</tr>
				<cfif application.zcore.user.checkServerAccess()>
					<tr>
						<td> New Site: </td>
						<td><cfscript>
						application.zcore.functions.zGetSiteSelect('newsiteid');
						</cfscript></td>
					</tr>
				</cfif>
				<tr>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td>Rename existing menu: </td>
					<td><input type="checkbox" name="renameexisting" value="1" />
						(Only happens if there is a menu matching the name entered above.)</td>
				</tr>
				<tr>
					<td>Remove all links: </td>
					<td><input type="checkbox" name="removelinks" value="1" />
						(All menu links will be reset to ##.)</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td><input type="submit" name="submit1" value="Copy Menu" />
						<input type="button" name="button1" value="Cancel" onclick="window.location.href='/z/admin/menu/index';" /></td>
				</tr>
			</table>
		</form>
	<cfelse>
		<cfscript>
		application.zcore.adminSecurityFilter.requireFeatureAccess("Menus", true);	
		if(application.zcore.user.checkServerAccess()){
			form.newsiteid=application.zcore.functions.zso(form, 'newsiteid', false);
			if(form.newsiteid EQ ""){
				form.newsiteid=request.zos.globals.id;
			}
		}else{
	        form.newsiteid=request.zos.globals.id;
		}
        
		qS=variables.menuModel.getById(form.menu_id);
		for(row in qS){
			menuStruct=row;
		}
		qT=variables.menuModel.getMenuButtons(form.menu_id);
		if(application.zcore.functions.zso(form, 'renameexisting', true, 0) EQ 1){
			qS2=variables.menuModel.getMenuByNameAndSiteId(form.newName, newSiteId);
			if(qS2.recordcount NEQ 0){
				newcodename22=qS2.menu_name&" (renamed on "&dateformat(now(),"m/d/yy")&" at "&timeformat(now(),"HH:mm:ss")&")";

				variables.menuModel.copyUpdateMenuName(qs2.menu_id, newcodename22, qs2.site_id);
			}
		}
		
		arrS=listtoarray(lcase(qS.columnlist));
		arrT=listtoarray(lcase(qT.columnlist));
		
		
		
		try{
			local.rs=variables.menuModel.insertMenuWithArray(arrS, form.newname, form.newsiteid, menuStruct);
			if(local.rs.success){
				newmenuid=local.rs.result;
			}       
		}catch(Any local.e){
			local.rs={success:false, errorMessage:e.detail};
		}
		if(not local.rs.success){
			application.zcore.status.setStatus(request.zsid, "Failed to copy menu.  Make sure the new code name is unique. Error Message: "&local.rs.errorMessage, form,true);
			application.zcore.functions.zRedirect("/z/admin/menu/index?zsid=#request.zsid#");	
		}
		
		buttonidstruct=structnew();
		for(menuButton in qT){
			local.rs=variables.menuModel.insertMenuButtonWithArray(arrT, newmenuid, form.newsiteid, menuButton);
			if(local.rs.success){
				newmenubuttonid=local.rs.result;
			}else{
				throw("menu_button failed to insert");
			}
			if(application.zcore.functions.zso(form, 'removelinks', true, 0) NEQ 1){
				qI=variables.menuModel.getMenuButtonLinksByButtonId(menuButton.menu_button_id);
				
				arrI=listtoarray(lcase(qI.columnlist));
				for(menuButtonLink in qI){
					variables.menuModel.insertMenuButtonLinkWithArray(arrI, newmenuid, newMenuButtonId, form.newsiteid, menuButtonLink);
					
				}
			}
		}
		
		if (DirectoryExists(application.zcore.functions.zvar('privatehomedir',form.newsiteid)&'zupload/menu/') EQ false) {
			application.zcore.functions.zCreateDirectory(application.zcore.functions.zvar('privatehomedir',form.newsiteid)&'zupload/menu');
		}
		if (DirectoryExists(application.zcore.functions.zvar('privatehomedir',form.newsiteid)&'zupload/menu/#newmenuid#/') EQ false) {
			application.zcore.functions.zCreateDirectory(application.zcore.functions.zvar('privatehomedir',form.newsiteid)&'zupload/menu/#newmenuid#');
		}
		if(directoryexists(application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/menu/#form.menu_id#')){
			application.zcore.functions.zCopyDirectory(application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/menu/#form.menu_id#', application.zcore.functions.zvar('privatehomedir',form.newsiteid)&'zupload/menu/#newmenuid#');
		}
		menuFunctionsCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.menuFunctions");
		menuFunctionsCom.publishMenu(newmenuid, form.newsiteid);
		application.zcore.status.setStatus(request.zsid, "Menu copied");
		application.zcore.functions.zRedirect("/z/admin/menu/index?zsid=#request.zsid#");
		</cfscript>
	</cfif>
</cffunction>

<cffunction name="insertItemLink" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.updateItemLink();
	</cfscript>
</cffunction>

<cffunction name="updateItemLink" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var tempURL=0;
	var ts=0;
	var qC=0;
	var errors=0;
	var myForm=structnew();
	var qCheck=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Menus", true);	
	if(form.method EQ 'updateItemLink'){
		db.sql="SELECT * FROM #db.table("menu_button_link", request.zos.zcoreDatasource)# menu_button_link 
		WHERE menu_button_link_id = #db.param(form.menu_button_link_id)# and 
		menu_button_link_deleted = #db.param(0)# and 
		site_id = #db.param(form.site_id)# ";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this menu.',false,true);
			application.zcore.functions.zRedirect('/z/admin/menu/index?zsid=#request.zsid#');
		}
	}
	myForm.menu_button_link_url.required=true;
	myForm.menu_button_link_text.required=true;
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	if(errors){
		if(form.method EQ "updateItemLink"){
			application.zcore.functions.zRedirect("/z/admin/menu/editItemLink?menu_id=#form.menu_id#&menu_button_id=#form.menu_button_id#&menu_button_link_id=#form.menu_button_link_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/admin/menu/addItemLink?menu_id=#form.menu_id#&menu_button_id=#form.menu_button_id#&zsid="&request.zsid);
		}
	}
	ts=StructNew();
	ts.struct=form;
	ts.table="menu_button_link";
	ts.datasource=request.zos.zcoreDatasource;
	
	if(form.method EQ 'insertItemLink'){
		db.sql="select count(menu_button_link_id) count from #db.table("menu_button_link", request.zos.zcoreDatasource)# menu_button_link 
		WHERE menu_button_id = #db.param(form.menu_button_id)# and 
		menu_button_link_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#";
		qC=db.execute("qC");
		if(qC.recordcount NEQ 0){
			form.menu_button_link_sort=qC.count+1;	
		}
		form.menu_button_link_id = application.zcore.functions.zInsert(ts);
		if(form.menu_button_link_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'link with this URL already exists.  Please type a unique URL',form,true);
			application.zcore.functions.zRedirect('/z/admin/menu/addItemLink?zsid=#request.zsid#&menu_id=#form.menu_id#&menu_button_id=#form.menu_button_id#');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'link with this URL already exists.  Please type a unique URL',form,true);
			application.zcore.functions.zRedirect('/z/admin/menu/editItemLink?zsid=#request.zsid#&menu_button_id=#form.menu_button_id#');
		}
	}
	menuFunctionsCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.menuFunctions");
	menuFunctionsCom.publishMenu(form.menu_id);
	application.zcore.functions.zMenuClearCache({all=true});

	if(form.method EQ 'insertItemLink'){
		application.zcore.status.setStatus(request.zsid, "link added.");
	}else{
		application.zcore.status.setStatus(request.zsid, "link updated.");
	}
	/*if(structkeyexists(form, 'menu_button_link_id') and isDefined('request.zsession.menu_button_link_return'&form.menu_button_link_id)){	
		tempURL = request.zsession['menu_button_link_return'&form.menu_button_link_id];
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		StructDelete(request.zsession, 'menu_button_link_return'&form.menu_button_link_id, true);
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
	}else{	*/
		application.zcore.functions.zRedirect('/z/admin/menu/manageItemLinks?menu_id=#form.menu_id#&menu_button_id=#form.menu_button_id#&zsid=#request.zsid#');
	//}
	</cfscript>
</cffunction>

<cffunction name="insertItem" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.updateItem();
	</cfscript>
</cffunction>

<cffunction name="updateItem" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var tempURL=0;
	var imagePath=0;
	var image123=0;
	var q=0;
	var qC=0;
	var arrList=0;
	var ts=0;
	var getNewImageSize=0;
	var errors=0;
	var myForm=structnew();
	var qCheck=0;
	var qMenu2=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Menus", true);	
	db.sql="SELECT * FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu_id = #db.param(form.menu_id)# and 
	menu_deleted = #db.param(0)# and 
	site_id = #db.param(form.site_id)#";
	qMenu2=db.execute("qMenu2");
	if(form.method EQ "updateItem"){
		db.sql="SELECT * FROM #db.table("menu_button", request.zos.zcoreDatasource)# menu_button 
		WHERE menu_button_id = #db.param(form.menu_button_id)# and 
		menu_button_deleted = #db.param(0)# and 
		site_id = #db.param(form.site_id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this menu.',false,true);
			application.zcore.functions.zRedirect('/z/admin/menu/index?zsid=#request.zsid#');
		}
	}
	if(not structkeyexists(form, 'menu_button_type_id')){
 		form.menu_button_type_id=0;
 		form.menu_button_type_tid=0;
 	}
	if(form.menu_button_type_id EQ 1){
		form.menu_button_type_tid=application.zcore.functions.zso(form, 'menu_button_type_tid1');
	}else if(form.menu_button_type_id EQ 3){
		form.menu_button_type_tid=application.zcore.functions.zso(form, 'menu_button_type_tid3');
	}else if(form.menu_button_type_id EQ 4){
		form.menu_button_type_tid=application.zcore.functions.zso(form, 'menu_button_type_tid4');
	}else{
		form.menu_button_type_tid=0;
	}
	
	myForm.menu_button_text.required=true;
	myForm.menu_button_link.required=true;
	myForm.menu_button_type_id.required=true;
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	if(errors){
		if(form.method EQ "updateItem"){
			application.zcore.functions.zRedirect("/z/admin/menu/editItem?menu_id=#form.menu_id#&menu_button_id=#form.menu_button_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/admin/menu/addItem?menu_id=#form.menu_id#&zsid="&request.zsid);
		}
	}


	arrList=ArrayNew(1);
	if(form.method EQ 'insertItem'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_button_url", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth,qMenu2.menu_size_limit)#x500","","","",request.zos.zcoreDatasource);
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_button_url", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth,qMenu2.menu_size_limit)#x500", 'menu_button', 'menu_button_id', "menu_button_url_delete",request.zos.zcoreDatasource);
	}
	getNewImageSize=false;
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid background image format or corrupted file.  Please upload a small to medium siapplication.zcore.functions.ze JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'menu_button_url');
		StructDelete(variables,'menu_button_url');
	}else if(ArrayLen(arrList) NEQ 0){
		form.menu_button_url=arrList[1];
		if(form.menu_button_url NEQ ""){
			getNewImageSize=true;
		}
	}else{
		StructDelete(form,'menu_button_url');
		StructDelete(variables,'menu_button_url');
	}
	arrList=ArrayNew(1);
	if(form.method EQ 'insertItem'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_button_over_url", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth,qMenu2.menu_size_limit)#x500","","","",request.zos.zcoreDatasource);
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_button_over_url", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth,qMenu2.menu_size_limit)#x500", 'menu_button', 'menu_button_id', "menu_button_over_url_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid background image format or corrupted file.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'menu_button_over_url');
		StructDelete(variables,'menu_button_over_url');
	}else if(ArrayLen(arrList) NEQ 0){
		form.menu_button_over_url=arrList[1];
	}else{
		StructDelete(form,'menu_button_over_url');
		StructDelete(variables,'menu_button_over_url');
	}



	ts=StructNew();
	ts.struct=form;
	ts.table="menu_button";
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ 'insertItem'){
		db.sql="select count(menu_button_id) count 
		from #db.table("menu_button", request.zos.zcoreDatasource)# menu_button 
		WHERE menu_id = #db.param(form.menu_id)# and 
		menu_button_deleted = #db.param(0)# and 
		site_id =#db.param(request.zos.globals.id)#";
		qC=db.execute("qC");
		if(qC.recordcount NEQ 0){
			form.menu_button_sort=qC.count+1;	
		}
		form.menu_button_id = application.zcore.functions.zInsert(ts);
		if(form.menu_button_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Button with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect('/z/admin/menu/addItem?zsid=#request.zsid#&menu_id=#form.menu_id#');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Button with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect('/z/admin/menu/editItem?zsid=#request.zsid#&menu_id=#form.menu_id#');
		}
	}


	if (DirectoryExists(request.zos.globals.privatehomedir&'zupload/menu/') EQ false) {
		application.zcore.functions.zCreateDirectory(request.zos.globals.privatehomedir&'zupload/menu');
	}
	if (DirectoryExists(request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/') EQ false) {
		application.zcore.functions.zCreateDirectory(request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#');
	}
	imagePath=request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/';
	image123=structnew();
	if(getNewImageSize){ 
		image123=application.zcore.functions.zGetImageSize(request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/'&form.menu_button_url);
		// image source="#imagePath##form.menu_button_url#" action="info" structname="image123";
		form.menu_button_width=image123.width;
		form.menu_button_height=image123.height;
		db.sql='UPDATE #db.table("menu_button", request.zos.zcoreDatasource)# menu_button 
		SET menu_button_width=#db.param(image123.width)#, 
		menu_button_height=#db.param(image123.height)#, 
		menu_button_url = #db.param(form.menu_button_url)# 
		WHERE menu_button_id = #db.param(form.menu_button_id)# and 
		menu_button_deleted = #db.param(0)# and
		site_id=#db.param(form.site_id)#';
		q=db.execute("q");
	}
	variables.queueSortCom.sortAll();
	
	menuFunctionsCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.menuFunctions");
	menuFunctionsCom.publishMenu(form.menu_id);
	application.zcore.functions.zMenuClearCache({all=true});
	
	if(form.method EQ 'insertItem'){
		application.zcore.status.setStatus(request.zsid, "Button added.");
	}else{
		application.zcore.status.setStatus(request.zsid, "Button updated.");
	}
	/*if(structkeyexists(form, 'menu_button_id') and isDefined('request.zsession.menu_button_return'&form.menu_button_id)){	
		tempURL = request.zsession['menu_button_return'&form.menu_button_id];
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		StructDelete(request.zsession, 'menu_button_return'&form.menu_button_id, true);
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
	}else{	*/
		application.zcore.functions.zRedirect('/z/admin/menu/manageMenu?menu_id=#form.menu_id#&zsid=#request.zsid#');
	//}
	</cfscript>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var tempURL=0;
	var ts=0;
	var arrList=0;
	var qCheck=0;
	var myForm=structnew();
	var errors=0;
	variables.init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Menus", true);	
	if(form.method EQ 'update'){
		db.sql="SELECT * FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
		WHERE menu_id = #db.param(form.menu_id)# and 
		menu_deleted = #db.param(0)# and
		site_id = #db.param(form.site_id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this menu.',false,true);
			application.zcore.functions.zRedirect('/z/admin/menu/index?zsid=#request.zsid#');
		}
	} 
	if(form.menu_character_length EQ 0){
		form.menu_character_length=10000;
	}
	if(application.zcore.functions.zso(form, 'menu_codename') EQ ''){
		form.menu_codename='code'&dateformat(now(),'yyyy-mm-dd')&'-'&timeformat(now(),'HH:mm:ss');
	}
	myForm.menu_name.required=true;
	myForm.menu_link_limit.required=true;
	myForm.menu_size_limit.required=true;
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	if(errors){
		application.zcore.status.setStatus(request.zsid,false,form,true);
		if(form.method EQ "update"){
			application.zcore.functions.zRedirect("/z/admin/menu/edit?menu_id=#form.menu_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/admin/menu/add?zsid="&request.zsid);
		}
	}
	
	

	ts=StructNew();
	ts.table="menu";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ 'insert'){
		form.menu_id = application.zcore.functions.zInsert(ts);
		if(form.menu_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Menu with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect('/z/admin/menu/add?zsid=#request.zsid#');
		}
	}
	application.zcore.functions.zcreatedirectory(request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/');
		
	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_popup_background_image", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth, form.menu_size_limit)#x500","","","",request.zos.zcoreDatasource);
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_popup_background_image", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth, form.menu_size_limit)#x500", 'menu', 'menu_id', "menu_popup_background_image_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid background image format or corrupted file.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'menu_popup_background_image');
		StructDelete(variables,'menu_popup_background_image');
	}else if(ArrayLen(arrList) NEQ 0){
		form.menu_popup_background_image=arrList[1];
	}else{
		StructDelete(form,'menu_popup_background_image');
		StructDelete(variables,'menu_popup_background_image');
	}
	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_popup_background_over_image", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth,form.menu_size_limit)#x500","","","", request.zos.zcoreDatasource);
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_popup_background_over_image", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth,form.menu_size_limit)#x500", 'menu', 'menu_id', "menu_popup_background_over_image_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid background over image format or corrupted file.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'menu_popup_background_over_image');
		StructDelete(variables,'menu_popup_background_over_image');
	}else if(ArrayLen(arrList) NEQ 0){
		form.menu_popup_background_over_image=arrList[1];
	}else{
		StructDelete(form,'menu_popup_background_over_image');
		StructDelete(variables,'menu_popup_background_over_image');
	}
	
	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_background_image", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth,form.menu_size_limit)#x500","","","",request.zos.zcoreDatasource);
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_background_image", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth,form.menu_size_limit)#x500", 'menu', 'menu_id', "menu_background_image_delete",request.zos.zcoreDatasource);
	}
	
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid background image format or corrupted file.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'menu_background_image');
		StructDelete(variables,'menu_background_image');
	}else if(ArrayLen(arrList) NEQ 0){
		form.menu_background_image=arrList[1];
	}else{
		StructDelete(form,'menu_background_image');
		StructDelete(variables,'menu_background_image');
	}
	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_background_over_image", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth, form.menu_size_limit)#x500","","","",request.zos.zcoreDatasource);
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_background_over_image", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth, form.menu_size_limit)#x500", 'menu', 'menu_id', "menu_background_over_image_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid background over image format or corrupted file.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'menu_background_over_image');
		StructDelete(variables,'menu_background_over_image');
	}else if(ArrayLen(arrList) NEQ 0){
		form.menu_background_over_image=arrList[1];
	}else{
		StructDelete(form,'menu_background_over_image');
		StructDelete(variables,'menu_background_over_image');
	}


	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_selected_background_image", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth, form.menu_size_limit)#x500","","","",request.zos.zcoreDatasource);
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("menu_selected_background_image", request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', "#max(request.zos.globals.maximagewidth, form.menu_size_limit)#x500", 'menu', 'menu_id', "menu_selected_background_image_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid background over image format or corrupted file.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'menu_selected_background_image');
		StructDelete(variables,'menu_selected_background_image');
	}else if(ArrayLen(arrList) NEQ 0){
		form.menu_selected_background_image=arrList[1];
	}else{
		StructDelete(form,'menu_selected_background_image');
		StructDelete(variables,'menu_selected_background_image');
	}
	
	
	ts=StructNew();
	ts.struct=form;
	ts.table="menu";
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zUpdate(ts) EQ false){
		application.zcore.status.setStatus(request.zsid, 'Menu with this name already exists.  Please type a unique name',form,true);
		application.zcore.functions.zRedirect('/z/admin/menu/edit?zsid=#request.zsid#&menu_id=#form.menu_id#');
	}
	
	menuFunctionsCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.menuFunctions");
	menuFunctionsCom.publishMenu(form.menu_id);
	application.zcore.functions.zMenuClearCache({all=true});
	if(form.method EQ 'insert'){
		application.zcore.status.setStatus(request.zsid, "Menu added.");
	}else{
		application.zcore.status.setStatus(request.zsid, "Menu updated.");
	}
	if(structkeyexists(form, 'menu_id') and isDefined('request.zsession.menu_return'&form.menu_id)){	
		tempURL = request.zsession['menu_return'&form.menu_id];
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		StructDelete(request.zsession, 'menu_return'&form.menu_id, true);
		application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
	}else{	
		application.zcore.functions.zRedirect('/z/admin/menu/index?zsid=#request.zsid#');
	}
	</cfscript>
</cffunction>

<cffunction name="deleteItemLink" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qMenuItemLinkDel=0;
	var qCheck=0;
	variables.init();
	db.sql="SELECT * FROM #db.table("menu_button_link", request.zos.zcoreDatasource)# menu_button_link 
	WHERE menu_button_link_id = #db.param(form.menu_button_link_id)# and 
	menu_button_link_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		application.zcore.adminSecurityFilter.requireFeatureAccess("Menus", true);	
		db.sql="DELETE FROM #db.table("menu_button_link", request.zos.zcoreDatasource)# 
		WHERE menu_button_link_id = #db.param(form.menu_button_link_id)# and 
		menu_button_link_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)#;";
		qMenuItemLinkDel=db.execute("qMenuItemLinkDel");
		application.zcore.status.setStatus(request.zsid, 'Button deleted.');
		variables.queueSortCom.sortAll();
		menuFunctionsCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.menuFunctions");
		menuFunctionsCom.publishMenu(form.menu_id);
		application.zcore.functions.zMenuClearCache({all=true});
		application.zcore.functions.zRedirect('/z/admin/menu/manageItemLinks?menu_id=#form.menu_id#&menu_button_id=#form.menu_button_id#&zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this menu link?<br />
			<br />
			Title: #qCheck.menu_button_link_url# <br />
			<br />
			<a href="/z/admin/menu/deleteItemLink?confirm=1&amp;menu_id=#form.menu_id#&amp;menu_button_id=#form.menu_button_id#&amp;menu_button_link_id=#form.menu_button_link_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/admin/menu/manageItemLinks?menu_id=#form.menu_id#&amp;menu_button_id=#form.menu_button_id#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="deleteItem" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qMenuDel=0;
	var qMenuItemDel=0;
	var qCheck=0;
	var tempURL=0;
	variables.init();
	if(structkeyexists(form,'return')){
		StructInsert(request.zsession, "menu_button_return"&form.menu_button_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	db.sql="SELECT * FROM #db.table("menu_button", request.zos.zcoreDatasource)# menu_button 
	WHERE menu_button.menu_button_id = #db.param(form.menu_button_id)# and 
	menu_button_deleted = #db.param(0)# and 
	menu_button.site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'This menu button no longer exists.',false,true);
		if(isDefined('request.zsession.menu_button_return'&form.menu_button_id)){
			tempURL = request.zsession['menu_button_return'&form.menu_button_id];
			StructDelete(request.zsession, 'menu_button_return'&form.menu_button_id, true);
			application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
		}else{
			application.zcore.functions.zRedirect('/z/admin/menu/index?zsid=#request.zsid#');
		}
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		application.zcore.adminSecurityFilter.requireFeatureAccess("Menus", true);	
		db.sql="DELETE FROM #db.table("menu_button_link", request.zos.zcoreDatasource)# 
		WHERE menu_button_id = #db.param(form.menu_button_id)# and 
		menu_button_link_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#;";
		qMenuItemDel=db.execute("qMenuItemDel");
		db.sql="DELETE FROM #db.table("menu_button", request.zos.zcoreDatasource)# 
		WHERE menu_button_id = #db.param(form.menu_button_id)# and 
		menu_button_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#;";
		qMenuItemDel=db.execute("qMenuItemDel");
		if(qCheck.menu_button_url NEQ ''){  
			application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/' & qCheck.menu_button_url);
		}
		if(qCheck.menu_button_over_url NEQ ''){  
			application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/' & qCheck.menu_button_over_url);
		}
		variables.queueSortCom.sortAll();
		menuFunctionsCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.menuFunctions");
		menuFunctionsCom.publishMenu(form.menu_id);
		application.zcore.functions.zMenuClearCache({all=true});
		application.zcore.status.setStatus(request.zsid, 'Menu button deleted.');
		application.zcore.functions.zRedirect('/z/admin/menu/manageMenu?menu_id=#form.menu_id#&zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this menu button?<br />
			<br />
			Title: #qCheck.menu_button_text# <br />
			<br />
			<a href="/z/admin/menu/deleteItem?confirm=1&amp;menu_id=#form.menu_id#&amp;menu_button_id=#form.menu_button_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/admin/menu/manageMenu?menu_id=#form.menu_id#">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qMenuDel=0;
	var qMenuItemDel=0;
	var qCheck=0;
	var tempURL=0;
	variables.init();
	if(structkeyexists(form,'return')){
		StructInsert(request.zsession, "menu_return"&form.menu_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	db.sql="SELECT * FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu.menu_id = #db.param(form.menu_id)# and 
	menu_deleted = #db.param(0)# and 
	menu.site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'This menu no longer exists.',false,true);
		if(isDefined('request.zsession.menu_return'&form.menu_id)){
			tempURL = request.zsession['menu_return'&form.menu_id];
			StructDelete(request.zsession, 'menu_return'&form.menu_id, true);
			application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(tempURL,"zsid=#request.zsid#"), true);
		}else{
			application.zcore.functions.zRedirect('/z/admin/menu/index?zsid=#request.zsid#');
		}
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript>
		application.zcore.adminSecurityFilter.requireFeatureAccess("Menus", true);	
		db.sql="DELETE menu_button_link, menu_button 
		FROM #db.table("menu_button_link", request.zos.zcoreDatasource)# menu_button_link, 
		#db.table("menu_button", request.zos.zcoreDatasource)# menu_button 
		WHERE menu_button.menu_button_id = menu_button_link.menu_button_id and 
		menu_button.menu_id = #db.param(form.menu_id)# and 
		menu_button_link_deleted = #db.param(0)# and 
		menu_button_deleted = #db.param(0)# and
		menu_button.site_id = #db.param(request.zos.globals.id)# and 
		menu_button_link.site_id = menu_button.site_id";
		qMenuItemDel=db.execute("qMenuItemDel");
		db.sql="DELETE FROM #db.table("menu_button", request.zos.zcoreDatasource)# 
		WHERE menu_id = #db.param(form.menu_id)# and 
		menu_button_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)# ";
		qMenuItemDel=db.execute("qMenuItemDel");
		db.sql="DELETE FROM #db.table("menu", request.zos.zcoreDatasource)# WHERE 
		menu_id = #db.param(form.menu_id)# and 
		menu_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)#";
		qMenuDel=db.execute("qMenuDel");
		if (DirectoryExists(request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/')) {
			application.zcore.functions.zdeletedirectory(request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/');
		}
		menuFunctionsCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.menuFunctions");
		menuFunctionsCom.publishMenu(form.menu_id);
		application.zcore.functions.zMenuClearCache({all=true});
		application.zcore.status.setStatus(request.zsid, 'Menu deleted.');
		application.zcore.functions.zRedirect('/z/admin/menu/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this menu?<br />
			<br />
			Title: #qCheck.menu_name# <br />
			<br />
			<a href="/z/admin/menu/delete?confirm=1&amp;menu_id=#form.menu_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/admin/menu/index">No</a> </h2>
	</cfif>
</cffunction>
<cffunction name="manageItemLinks" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qMenu=0;
	var qMenuButton=0;
	var qMenuProps=0;
	var qMenuItemLinks=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.3.4");
	db.sql="SELECT * FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu_id = #db.param(form.menu_id)# and 
	menu_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qMenu=db.execute("qMenu");
	application.zcore.functions.zStatusHandler(request.zsid,true);
	db.sql="SELECT * FROM #db.table("menu_button", request.zos.zcoreDatasource)# menu_button 
	WHERE menu_button_id = #db.param(form.menu_button_id)# and 
	menu_button_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qMenuButton=db.execute("qMenuButton");
	db.sql="SELECT * FROM #db.table("menu_button_link", request.zos.zcoreDatasource)# menu_button_link 
	WHERE menu_button_id = #db.param(form.menu_button_id)# AND 
	site_id = #db.param(request.zos.globals.id)# and
	menu_button_link_deleted = #db.param(0)# 
	ORDER BY menu_button_link_sort";
	qMenuItemLinks=db.execute("qMenuItemLinks");
	db.sql="SELECT menu_link_limit FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu_id = #db.param(form.menu_id)# AND 
	menu_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qMenuProps=db.execute("qMenuProps");
	</cfscript>
	<h2>Editing Menu: #qmenu.menu_name#</h2>
	<h2>Editing Menu Button: #qMenuButton.menu_button_text#</h2>
	<div style="width:65%; text-align:left; float:left;"><a href="/z/admin/menu/index">Manage Menus</a> / <a href="/z/admin/menu/manageMenu?menu_id=#form.menu_id#&amp;menu_button_id=#form.menu_button_id#">Edit Buttons</a> /</div>
	<div style="width:35%; text-align:right; float:right;">
		<cfif qMenuProps.menu_link_limit EQ 0 or qMenuItemLinks.recordcount LT qMenuProps.menu_link_limit >
			<a href="/z/admin/menu/addItemLink?menu_id=#form.menu_id#&amp;menu_button_id=#form.menu_button_id#">Add Link</a>
			<cfelse>
			Link Limit Reached
		</cfif>
	</div>
	<br />
	<br />
 
	<cfif qMenuItemLinks.recordcount NEQ 0>
		<table id="menuLinkTable" style="border-spacing:0px; width:100%;" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Text</th>
				<th>Link</th>
				<th>Sort</th>
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfloop query="qMenuItemLinks"> 
				<tr #variables.queueSortCom.getRowHTML(qMenuItemLinks.menu_button_link_id)# <cfif qMenuItemLinks.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<td style="vertical-align:top; width:30px; ">#qMenuItemLinks.menu_button_link_id#</td>
					<td style="vertical-align:top; ">#qMenuItemLinks.menu_button_link_text#</td>
					<td style="vertical-align:top; ">#application.zcore.functions.zLimitStringLength(qMenuItemLinks.menu_button_link_url, 80)#</td>
					<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(qMenuItemLinks.menu_button_link_id)#</td>
					<td style="vertical-align:top; white-space:nowrap;">
					<!--- #variables.queueSortCom.getLinks(qMenuItemLinks.recordcount, qMenuItemLinks.currentrow, 
					'/z/admin/menu/manageItemLinks?menu_id=#form.menu_id#&amp;menu_button_id=#qMenuItemLinks.menu_button_id#&amp;menu_button_link_id=#qMenuItemLinks.menu_button_link_id#', "vertical-arrows")#  --->
					<a href="/z/admin/menu/editItemLink?menu_id=#form.menu_id#&amp;menu_button_id=#qMenuItemLinks.menu_button_id#&amp;menu_button_link_id=#qMenuItemLinks.menu_button_link_id#&amp;return=1">Edit</a> | 
						
						<a href="/z/admin/menu/deleteItemLink?menu_id=#form.menu_id#&amp;menu_button_id=#qMenuItemLinks.menu_button_id#&amp;menu_button_link_id=#qMenuItemLinks.menu_button_link_id#&amp;return=1">Delete</a> 
						</td>
				</tr>
				</cfloop>
			</tbody>
		</table>
	</cfif>
</cffunction>

<cffunction name="manageMenu" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qMenu=0;
	var qMenuItems=0;
	var qMenuProps=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.3");
	db.sql="SELECT * FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu_id = #db.param(form.menu_id)# and 
	menu_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qMenu=db.execute("qMenu");
	application.zcore.functions.zStatusHandler(request.zsid,true);
	db.sql="SELECT * FROM #db.table("menu_button", request.zos.zcoreDatasource)# menu_button 
	WHERE menu_id = #db.param(form.menu_id)# AND 
	menu_button_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# 
	ORDER BY menu_button_sort";
	qMenuItems=db.execute("qMenuItems");
	db.sql="SELECT menu_size_limit FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu_id = #db.param(form.menu_id)# AND 
	menu_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qMenuProps=db.execute("qMenuProps");
	</cfscript>
	<h2>Editing Menu: #qmenu.menu_name#</h2>
	<div style="width:65%; text-align:left; float:left;"><a href="/z/admin/menu/index">Manage Menus</a> /</div>
	<div style="width:35%; text-align:right; float:right;">
		<cfif qMenuItems.recordcount LT qMenuProps.menu_size_limit >
			<a href="/z/admin/menu/addItem?menu_id=#form.menu_id#">Add Button</a>
		</cfif>
	</div>
	<br />
	<cfif qMenuItems.recordcount NEQ 0>
		<br />
		<table id="menuLinkTable" style="border-spacing:0px; width:100%;" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Name</th>
				<th>URL</th>
				<th>Sort</th>
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfloop query="qMenuItems">
					<cfscript>
	
					variables.queueSortCom.getRowStruct(qMenuItems.menu_button_id);
					</cfscript>
				<tr #variables.queueSortCom.getRowHTML(qMenuItems.menu_button_id)# <cfif qMenuItems.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<td style="vertical-align:top; width:30px; ">#qMenuItems.menu_button_id#</td>
					<td style="vertical-align:top; ">#qMenuItems.menu_button_text#</td>
					<td style="vertical-align:top;">#application.zcore.functions.zLimitStringLength(qMenuItems.menu_button_link, 80)#</td>
					<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(qMenuItems.menu_button_id)#</td>
					<td style="vertical-align:top; white-space:nowrap;">
						<!--- #variables.queueSortCom.getLinks(qMenuItems.recordcount, qMenuItems.currentrow, '/z/admin/menu/manageMenu?menu_id=#qMenuItems.menu_id#&menu_button_id=#qMenuItems.menu_button_id#', "vertical-arrows")#  --->
						<a href="/z/admin/menu/editItem?menu_id=#qMenuItems.menu_id#&amp;menu_button_id=#qMenuItems.menu_button_id#&amp;return=1">Edit</a> | 
						<cfif qMenu.menu_disable_popup EQ 0>
			
							<a href="/z/admin/menu/manageItemLinks?menu_id=#qMenuItems.menu_id#&amp;menu_button_id=#qMenuItems.menu_button_id#&amp;return=1">Edit Links</a> | 
						</cfif>
						<a href="/z/admin/menu/deleteItem?menu_id=#qMenuItems.menu_id#&amp;menu_button_id=#qMenuItems.menu_button_id#&amp;return=1">Delete</a> 
					</td>
				</tr>
				</cfloop>
			</tbody>
		</table>
	</cfif>
</cffunction>

<cffunction name="addItemLink" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.editItemLink();
	</cfscript>
</cffunction>

<cffunction name="editItemLink" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var qMenu=0;
	var qMenuItemLink=0;
	var currentMethod=form.method;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.3.5");
	form.menu_button_id=application.zcore.functions.zso(form, 'menu_button_id');
	form.menu_button_link_id=application.zcore.functions.zso(form, 'menu_button_link_id');	
	db.sql="SELECT * FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu_id = #db.param(form.menu_id)# AND 
	menu_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qMenu=db.execute("qMenu");
	if(qMenu.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid menu id");
		application.zcore.functions.zRedirect("/z/admin/menu/index?zsid=#request.zsid#");	
	}
	db.sql="SELECT menu_button_link_id, menu_button_link_url, menu_button_link_text, menu_button_link_target, menu_button_link_sort,  site_id 
	FROM #db.table("menu_button_link", request.zos.zcoreDatasource)# menu_button_link 
	WHERE menu_button_link_id = #db.param(form.menu_button_link_id)# AND 
	menu_button_link_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qMenuItemLink=db.execute("qMenuItemLink");
	if(currentMethod EQ 'editItemLink'){
		if(qMenuItemLink.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this menu.',false,true);
			application.zcore.functions.zRedirect('/z/admin/menu/index&zsid=#request.zsid#');
		}
	}
	application.zcore.functions.zQueryToStruct(qMenuItemLink, form,'menu_button_link_id,site_id');
	application.zcore.functions.zStatusHandler(request.zsid,true);
	if(structkeyexists(form,'return')){
		StructInsert(request.zsession, "menu_button_link_return"&form.menu_button_link_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	</cfscript>
	<h2>
		<cfif currentMethod EQ "addItemLink">
			Add
		<cfelse>
			Edit
		</cfif>
		Link</h2>
	<form class="zFormCheckDirty" enctype="multipart/form-data" action="/z/admin/menu/<cfif currentMethod EQ 'editItemLink'>updateItemLink<cfelse>insertItemLink</cfif>?menu_button_link_id=#form.menu_button_link_id#" method="post" name="blogform">
		<input type="hidden" name="menu_button_id" value="#form.menu_button_id#" />
		<input type="hidden" name="menu_id" value="#form.menu_id#" />
		<table style="border-spacing:0px; width:100%;" class="table-list">
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Text","member.menu.editItemLink menu_button_link_text")#</th>
				<td><input type="text" name="menu_button_link_text" maxlength="#qMenu.menu_character_length#" value="#HTMLEditFormat(form.menu_button_link_text)#" style="width:80%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("URL","member.menu.editItemLink menu_button_link_url")#</th>
				<td><input type="text" name="menu_button_link_url" value="#HTMLEditFormat(form.menu_button_link_url)#" style="width:80%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Target","member.menu.editItemLink menu_button_link_target")#</th>
				<td><cfscript>
					ts = structNew();
					ts.name = "menu_button_link_target";
					ts.selectLabel="-- Normal Link --";
					ts.listLabels = "New Window";
					ts.listValues = "_blank";
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<tr>
				<th style="width:100px;">&nbsp; </th>
				<td><cfif currentMethod EQ 'editItemLink'>
						<button type="submit" value="Update Menu">Update Link</button>
					<cfelse>
						<button type="submit" value="Add Menu">Add Link</button>
					</cfif>
					<button type="button" name="cancel" value="Cancel" onclick="window.location.href = '/z/admin/menu/manageItemLinks?menu_id=#form.menu_id#&amp;menu_button_id=#form.menu_button_id#';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="addItem" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.editItem();
	</cfscript>
</cffunction>

<cffunction name="editItem" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var qB=0;
	var qB2=0;
	var qC=0;
	var qMenu=0;
	var currentMethod=form.method;
	var qMenuItem=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.3.3");
	form.menu_id=application.zcore.functions.zso(form, 'menu_id');
	form.menu_button_id=application.zcore.functions.zso(form, 'menu_button_id');
	db.sql="SELECT * FROM #db.table("menu", request.zos.zcoreDatasource)# menu 
	WHERE menu_id = #db.param(form.menu_id)# AND 
	menu_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#;";
	qMenu=db.execute("qMenu");
	if(qMenu.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid menu id");
		application.zcore.functions.zRedirect("/z/admin/menu/index?zsid=#request.zsid#");	
	}
	db.sql="SELECT * FROM #db.table("menu_button", request.zos.zcoreDatasource)# menu_button 
	WHERE menu_button_id = #db.param(form.menu_button_id)# AND 
	menu_button_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qMenuItem=db.execute("qMenuItem");
	if(currentMethod EQ 'editItem'){
		if(qMenuItem.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this menu.',false,true);
			application.zcore.functions.zRedirect('/z/admin/menu/index?zsid=#request.zsid#');
		}
	}
	application.zcore.functions.zQueryToStruct(qMenuItem, form,'menu_button_id,site_id,menu_id');
	application.zcore.functions.zStatusHandler(request.zsid,true);
	if(structkeyexists(form,'return')){
		StructInsert(request.zsession, "menu_button_return"&form.menu_button_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	</cfscript>
	<h2>
		<cfif currentMethod EQ "addItem">
			Add
		<cfelse>
			Edit
		</cfif>
		Button</h2>
	<form class="zFormCheckDirty" enctype="multipart/form-data" action="/z/admin/menu/<cfif currentMethod EQ 'editItem'>updateItem<cfelse>insertItem</cfif>?menu_button_id=#form.menu_button_id#" method="post" name="blogform">
		<input type="hidden" name="menu_id" value="#form.menu_id#" />
		<table style="border-spacing:0px; width:100%;" class="table-list">
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Link Text","member.menu.editItem menu_button_text")#</th>
				<td><input type="text" name="menu_button_text" maxlength="#qMenu.menu_character_length#" value="#HTMLEditFormat(form.menu_button_text)#" style="width:80%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Image","member.menu.editItem menu_button_url")#</th>
				<td>#application.zcore.functions.zInputImage('menu_button_url', request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', request.zos.currentHostName&'/zupload/menu/#form.menu_id#/')# </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Over Image","member.menu.editItem menu_button_over_url")#</th>
				<td>#application.zcore.functions.zInputImage('menu_button_over_url', request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', request.zos.currentHostName&'/zupload/menu/#form.menu_id#/')# </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("URL","member.menu.editItem menu_button_link")#</th>
				<td><input type="text" name="menu_button_link" value="#HTMLEditFormat(form.menu_button_link)#" style="width:80%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Link Target","member.menu.editItem menu_button_target")#</th>
				<td><cfscript>
					ts = structNew();
					ts.name = "menu_button_target";
					ts.selectLabel="-- Normal Link --";
					ts.listLabels = "New Window";
					ts.listValues = "_blank";
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<cfif qMenu.menu_disable_popup EQ 0>
	
				<tr>
					<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Child Link Type","member.menu.editItem menu_button_type_id")#</th>
					<td><script>
						 /* <![CDATA[ */
						 function setLinkType(v){
							var d1= document.getElementById("btiContentDiv");
							var d3= document.getElementById("btiBlogCategoryDiv");
							var d4= document.getElementById("btiBlogTagDiv");
							var d5= document.getElementById("btiCountDiv");
							d1.style.display="none";
							d3.style.display="none";
							d4.style.display="none";
							d5.style.display="block";
							if(v==0){
								// hide other types	
								d5.style.display="none";
							}else if(v==1){
								// show content select box
								d1.style.display="block";
							}else if(v==3){
								// show blog category select box
								d3.style.display="block";
							}else if(v==4){
								// show blog tag select box
								d4.style.display="block";
							}
						 }
						 /* ]]> */
						 </script>
						<cfscript>
						ts = StructNew();
						ts.name="menu_button_type_id";
						ts.hideselect=true;
						ts.listValuesDelimiter="|";
						ts.listValues ="0";
						ts.listLabels ="Manual Links";
						if(application.zcore.app.siteHasApp("content")){
							ts.listValues &="|1";
							ts.listLabels &="|Content Links";
						}
						if(application.zcore.app.siteHasApp("blog")){
							ts.listValues &="|2|5|3|4";
							ts.listLabels &="|Recent Blog Links|Popular Blog Links|Blog Category|Blog Tag";
						}
						ts.listLabelsDelimiter="|";
						ts.onchange="setLinkType(this.value);";
						ts.output=true;
						application.zcore.functions.zInputSelectBox(ts);
						</cfscript>
						<br />
						<br />
						<div id="btiCountDiv"> #application.zcore.functions.zOutputHelpToolTip("Maximum number of links to show?","member.menu.editItem menu_button_type_count")#
							<cfscript>
							if(form.menu_button_type_count EQ ""){
								form.menu_button_type_count=10;
							}
							ts = StructNew();
							ts.name="menu_button_type_count";
							ts.hideselect=true;
							ts.listValuesDelimiter="|";
							ts.listValues ="0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20";
							ts.output=true;
							application.zcore.functions.zInputSelectBox(ts);
							</cfscript>
							<br />
							<br />
						</div>
						<cfscript>
						if(application.zcore.app.siteHasApp("content")){
							db.sql="SELECT content_id, content_name FROM #db.table("content", request.zos.zcoreDatasource)# content WHERE 
							site_id =#db.param(request.zos.globals.id)# and 
							content_deleted = #db.param(0)# 
							ORDER BY content_name ASC";
							qC=db.execute("qC");
						}
						if(application.zcore.app.siteHasApp("blog")){
							db.sql="SELECT blog_category_id, blog_category_name FROM #db.table("blog_category", request.zos.zcoreDatasource)# blog_category WHERE 
							site_id =#db.param(request.zos.globals.id)# and 
							blog_category_deleted = #db.param(0)# 
							ORDER BY blog_category_name ASC";
							qB=db.execute("qB");
							db.sql="SELECT blog_tag_id, blog_tag_name FROM #db.table("blog_tag", request.zos.zcoreDatasource)# blog_tag WHERE 
							site_id =#db.param(request.zos.globals.id)# and 
							blog_tag_deleted = #db.param(0)# 
							ORDER BY blog_tag_name ASC";
							qB2=db.execute("qB2");
						}
						</cfscript>
						<cfif application.zcore.app.siteHasApp("content")>
							<div id="btiContentDiv">#application.zcore.functions.zOutputHelpToolTip("Select a content parent page","member.menu.editItem menu_button_type_tid1")#:
								<cfscript>
								if(form.menu_button_type_id EQ 1){
									form.menu_button_type_tid1=form.menu_button_type_tid;
								}
								ts = StructNew();
								ts.name="menu_button_type_tid1";
								ts.query=qC;
								ts.queryLabelField="content_name";
								ts.queryValueField="content_id";
								ts.output=true;
								application.zcore.functions.zInputSelectBox(ts);
								</cfscript>
							</div>
						</cfif>
						<cfif application.zcore.app.siteHasApp("blog")>
							<!--- blog category --->
							<div id="btiBlogCategoryDiv">#application.zcore.functions.zOutputHelpToolTip("Select a blog category parent page","member.menu.editItem menu_button_type_tid3")#:
								<cfscript>
								if(form.menu_button_type_id EQ 3){
									form.menu_button_type_tid3=form.menu_button_type_tid;
								}
								ts = StructNew();
								ts.name="menu_button_type_tid3";
								ts.query=qB;
								ts.queryLabelField="blog_category_name";
								ts.queryValueField="blog_category_id";
								ts.output=true;
								application.zcore.functions.zInputSelectBox(ts);
								</cfscript>
							</div>
							
							<!--- blog tags --->
							<div id="btiBlogTagDiv">#application.zcore.functions.zOutputHelpToolTip("Select a blog tag parent page","member.menu.editItem menu_button_type_tid4")#:
								<cfscript>
								if(form.menu_button_type_id EQ 4){
									form.menu_button_type_tid4=form.menu_button_type_tid;
								}
								ts = StructNew();
								ts.name="menu_button_type_tid4";
								ts.query=qB2;
								ts.queryLabelField="blog_tag_name";
								ts.queryValueField="blog_tag_id";
								ts.output=true;
								application.zcore.functions.zInputSelectBox(ts);
								</cfscript>
							</div>
						</cfif>
						<script>setLinkType(#application.zcore.functions.zso(form, 'menu_button_type_id',true)#);</script><br />
						#application.zcore.functions.zOutputHelpToolTip("Sorting Method","member.menu.editItem menu_button_sorting")#:
						<cfscript>
						if(form.menu_button_type_id EQ 4){
							form.menu_button_type_tid4=form.menu_button_type_tid;
						}
						ts = StructNew();
						ts.name="menu_button_sorting";
						ts.hideSelect=true;
						ts.listLabels="Manual (default),Alphanumeric,Date Descending,Date Ascending";
						ts.listValues="0,1,2,3";
						ts.queryValueField="blog_tag_id";
						ts.output=true;
						application.zcore.functions.zInputSelectBox(ts);
						</cfscript>
						(Note: Some link types are presorted and this setting won't have an effect.) </td>
				</tr>
			</cfif>
			<tr>
				<th>&nbsp; </th>
				<td><cfif currentMethod EQ 'editItem'>
						<button type="submit" value="Update Menu">Update Button</button>
					<cfelse>
						<button type="submit" value="Add Menu">Add Button</button>
					</cfif>
					<button type="button" name="cancel" value="Cancel" onclick="window.location.href = '/z/admin/menu/manageMenu?menu_id=#form.menu_id#&amp;return=1';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var currentMethod=form.method;
	var qMenu=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.3.1");
	form.menu_id=application.zcore.functions.zso(form, 'menu_id');
	db.sql="SELECT * FROM #db.table("menu", request.zos.zcoreDatasource)# menu WHERE 
	menu_id = #db.param(form.menu_id)# AND 
	menu_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qMenu=db.execute("qMenu");
	if(currentMethod EQ 'edit'){
		if(qMenu.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this menu.',false,true);
			application.zcore.functions.zRedirect('/z/admin/menu/index&zsid=#request.zsid#');
		}
	}
	application.zcore.functions.zQueryToStruct(qMenu, form,'menu_id,site_id');
	application.zcore.functions.zStatusHandler(request.zsid,true);
	if(structkeyexists(form,'return')){
		StructInsert(request.zsession, "menu_return"&form.menu_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	application.zcore.functions.zIncludeJsColor();
	</cfscript>
	<h2>
		<cfif currentMethod EQ "add">
			Add
		<cfelse>
			Edit
		</cfif>
		Menu</h2>
	<form class="zFormCheckDirty" enctype="multipart/form-data" action="/z/admin/menu/<cfif currentMethod EQ 'edit'>update<cfelse>insert</cfif>?menu_id=#form.menu_id#" method="post" name="blogform">
		<table style="border-spacing:0px; width:100%;" class="table-list">
			<tr>
				<th style="width:50px;"> #application.zcore.functions.zOutputHelpToolTip("Menu Name","member.menu.edit menu_name")# </th>
				<td><cfif form.menu_locked EQ 1>
					#form.menu_name#
						<input type="hidden" name="menu_name" on value="#HTMLEditFormat(form.menu_name)#" />
						<cfelse>
						<input type="text" name="menu_name" on value="#HTMLEditFormat(form.menu_name)#" style="width:80%;">
						* Required
					</cfif></td>
			</tr>
			<tr>
				<th style="width:50px;"> #application.zcore.functions.zOutputHelpToolTip("Link Limit","member.menu.edit menu_link_limit")# </th>
				<td><input type="text" name="menu_link_limit" value="<cfif form.menu_link_limit EQ "">0<cfelse>#HTMLEditFormat(form.menu_link_limit)#</cfif>" style="width:10%;">
					* Required (Set to 0 for unlimited size.) </td>
			</tr>
			<tr>
				<th style="width:50px;"> #application.zcore.functions.zOutputHelpToolTip("Pixel Width/Height","member.menu.edit menu_size_limit")# </th>
				<td><input type="text" name="menu_size_limit" value="<cfif form.menu_size_limit EQ "">#request.zos.globals.maximagewidth#<cfelse>#HTMLEditFormat(form.menu_size_limit)#</cfif>" style="width:10%;">
					* Required (Set to 0 for unlimited size.) </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Max Character Length","member.menu.edit menu_character_length")#</th>
				<td><input type="text" name="menu_character_length" value="<cfif form.menu_character_length EQ 10000>0<cfelseif form.menu_character_length EQ "">50<cfelse>#HTMLEditFormat(form.menu_character_length)#</cfif>" style="width:10%;">
					* Required (Set to 0 for unlimited size.) </td>
			</tr>
			<tr>
				<th colspan="2">Menu Button Options</th>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Enable Responsive?","member.menu.edit menu_enable_responsive")#</th>
				<td><cfscript>
				writeoutput(application.zcore.functions.zInput_Boolean("menu_enable_responsive"));
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Button Margin","member.menu.edit menu_button_margin")#</th>
				<td><input type="text" name="menu_button_margin" value="#HTMLEditFormat(form.menu_button_margin)#" style="width:10%;"></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Font","member.menu.edit menu_font")#</th>
				<td><script>
				function setFont(div,v){
					var d1=document.getElementById(div);	
					d1.innerHTML=v;
					d1.style.fontFamily=v;
				}
				</script>
					<cfscript>
					if(form.menu_font EQ ""){
						form.menu_font='Verdana, Geneva, sans-serif';	
					}
					ts = structNew();
					ts.name = "menu_font";
					ts.hideSelect=true;
					ts.onchange="setFont('fontDiv',this.value);";
					ts.listValuesDelimiter="|";
					ts.selectedDelimiter="|";
					ts.listValues = 'Verdana, Geneva, sans-serif|Georgia, "Times New Roman", Times, serif|"Courier New", Courier, monospace|Arial, Helvetica, sans-serif|Tahoma, Geneva, sans-serif|"Trebuchet MS", Arial, Helvetica, sans-serif|"Times New Roman", Times, serif|"Lucida Console", Monaco, monospace';
					if(application.zcore.functions.zso(request.zos.globals,'fontlist') NEQ ""){
						ts.listValues&="|"&request.zos.globals.fontlist;
					}
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript>
					<div id="fontDiv" style="font-size:18px;"></div>
					<script>
					setFont('fontDiv','#htmleditformat(form.menu_font)#');
					</script></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Bold Font?","member.menu.edit menu_bold")#</th>
				<td><cfscript>
				writeoutput(application.zcore.functions.zInput_Boolean("menu_bold"));
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Padding Height","member.menu.edit menu_padding_height")#</th>
				<td><cfscript>
					if(form.menu_padding_height EQ ""){
						form.menu_padding_height=5;
					}
					ts = structNew();
					ts.name = "menu_padding_height";
					ts.hideSelect=true;
					ts.listValues = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30";
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Padding Width","member.menu.edit menu_padding_width")#</th>
				<td><cfscript>
					if(form.menu_padding_width EQ ""){
						form.menu_padding_width=10;
					}
					ts = structNew();
					ts.name = "menu_padding_width";
					ts.hideSelect=true;
					ts.listValues = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30";
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Button Font Size","member.menu.edit menu_button_font_size")#</th>
				<td><cfscript>
					if(form.menu_button_font_size EQ ""){
						form.menu_button_font_size=12;
					}
					ts = structNew();
					ts.name = "menu_button_font_size";
					ts.hideSelect=true;
					ts.listValues = "10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30";
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Font Color","member.menu.edit menu_font_color")#</th>
				<td>##
					<input class="zColorInput {required:false}" type="text" name="menu_font_color" value="<cfif form.menu_font_color EQ "">FFFFFF<cfelse>#HTMLEditFormat(form.menu_font_color)#</cfif>" style="width:10%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Background","member.menu.edit menuBackground")#</th>
				<td>#application.zcore.functions.zOutputHelpToolTip("Color","member.menu.edit menu_background_color")#: ##
					<input class="zColorInput {required:false}" type="text" name="menu_background_color" value="<cfif form.menu_background_color EQ "">000000<cfelse>#HTMLEditFormat(form.menu_background_color)#</cfif>" style="width:10%;">
					<br />
					or #application.zcore.functions.zOutputHelpToolTip("Image","member.menu.edit menu_background_image")#:<br />
					#application.zcore.functions.zInputImage('menu_background_image', request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', request.zos.currentHostName&'/zupload/menu/#form.menu_id#/')# 					</td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Divider Color","member.menu.edit menu_divider_color")#</th>
				<td>##
					<input class="zColorInput {required:false}" type="text" name="menu_divider_color" value="<cfif form.menu_font_color EQ "">FFFFFF<cfelse>#HTMLEditFormat(form.menu_divider_color)#</cfif>" style="width:10%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Rollover Font Color","member.menu.edit menu_font_over_color")#</th>
				<td>##
					<input class="zColorInput {required:false}" type="text" name="menu_font_over_color" value="<cfif form.menu_font_over_color EQ "">000000<cfelse>#HTMLEditFormat(form.menu_font_over_color)#</cfif>" style="width:10%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Rollover Background","member.menu.edit menu_background_over_color")#</th>
				<td>#application.zcore.functions.zOutputHelpToolTip("Color","member.menu.edit menu_background_over_color")#: ##
					<input class="zColorInput {required:false}" type="text" name="menu_background_over_color" value="<cfif form.menu_background_over_color EQ "">FFFFFF<cfelse>#HTMLEditFormat(form.menu_background_over_color)#</cfif>" style="width:10%;">
					<br />
					or #application.zcore.functions.zOutputHelpToolTip("Image","member.menu.edit menu_background_over_image")#:<br />
					#application.zcore.functions.zInputImage('menu_background_over_image', request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', request.zos.currentHostName&'/zupload/menu/#form.menu_id#/')# 					</td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Selected Font Color","member.menu.edit menu_selected_font_color")#</th>
				<td>##
					<input class="zColorInput {required:false}" type="text" name="menu_selected_font_color" value="<cfif form.menu_selected_font_color EQ "">000000<cfelse>#HTMLEditFormat(form.menu_selected_font_color)#</cfif>" style="width:10%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Selected Background","member.menu.edit menu_selected_background_over_color")#</th>
				<td>#application.zcore.functions.zOutputHelpToolTip("Color","member.menu.edit menu_selected_background_color")#: ##
					<input class="zColorInput {required:false}" type="text" name="menu_selected_background_color" value="<cfif form.menu_selected_background_color EQ "">FFFFFF<cfelse>#HTMLEditFormat(form.menu_selected_background_color)#</cfif>" style="width:10%;">
					<br />
					or #application.zcore.functions.zOutputHelpToolTip("Image","member.menu.edit menu_selected_background_image")#:<br />
					#application.zcore.functions.zInputImage('menu_selected_background_image', request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', request.zos.currentHostName&'/zupload/menu/#form.menu_id#/')# 					</td>
			</tr>
			<tr>
				<th colspan="2">Pop-up Options</th>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Disable pop-ups?","member.menu.edit menu_disable_popup")#</th>
				<td style="vertical-align:top; "><input type="radio" name="menu_disable_popup" value="1" <cfif form.menu_disable_popup EQ 1>checked="checked"</cfif> style="border:none; background:none;" />
					Yes
					<input type="radio" name="menu_disable_popup" value="0" <cfif form.menu_disable_popup EQ 0 or form.menu_disable_popup EQ ''>checked="checked"</cfif> style="border:none; background:none;" />
					No </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Popup Font","member.menu.edit menu_popup_font")#</th>
				<td><cfscript>
					if(form.menu_popup_font EQ ""){
						form.menu_popup_font='Verdana, Geneva, sans-serif';	
					}
					ts = structNew();
					ts.name = "menu_popup_font";
					ts.hideSelect=true;
					ts.onchange="setFont('fontPopupDiv',this.value);";
					ts.listValuesDelimiter="|";
					ts.selectedDelimiter="|";
					ts.listValues = 'Verdana, Geneva, sans-serif|Georgia, "Times New Roman", Times, serif|"Courier New", Courier, monospace|Arial, Helvetica, sans-serif|Tahoma, Geneva, sans-serif|"Trebuchet MS", Arial, Helvetica, sans-serif|"Times New Roman", Times, serif|"Lucida Console", Monaco, monospace';
					if(application.zcore.functions.zso(request.zos.globals,'fontlist') NEQ ""){
						ts.listValues&="|"&request.zos.globals.fontlist;
					}
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript>
					<div id="fontPopupDiv" style="font-size:18px;"></div>
					<script>
					setFont('fontPopupDiv','#form.menu_popup_font#');
					</script></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Popup Bold<br />Font?","member.menu.edit menu_popup_bold")#</th>
				<td><cfscript>
				writeoutput(application.zcore.functions.zInput_Boolean("menu_popup_bold"));
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:50px;"> #application.zcore.functions.zOutputHelpToolTip("Popup Padding<br />Height","member.menu.edit menu_popup_padding_height")#</th>
				<td><cfscript>
					if(form.menu_popup_padding_height EQ ""){
						form.menu_popup_padding_height=3;
					}
					ts = structNew();
					ts.name = "menu_popup_padding_height";
					ts.hideSelect=true;
					ts.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30";
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Popup Opacity","member.menu.edit menu_popup_opacity")#</th>
				<td><cfscript>
					if(form.menu_popup_opacity EQ ""){
						form.menu_popup_opacity=90;
					}
					ts = structNew();
					ts.name = "menu_popup_opacity";
					ts.hideSelect=true;
					ts.listLabels = "50%,60%,70%,75%,80%,85%,90%,95%,100%";
					ts.listValues = "50,60,70,75,80,85,90,95,100";
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Popup Divider Color","member.menu.edit menu_popup_divider_color")#</th>
				<td>##
					<input class="zColorInput {required:false}" type="text" name="menu_popup_divider_color" value="<cfif form.menu_popup_divider_color EQ "">999999<cfelse>#HTMLEditFormat(form.menu_popup_divider_color)#</cfif>" style="width:10%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;"> #application.zcore.functions.zOutputHelpToolTip("Popup Padding<br />Width","member.menu.edit menu_popup_padding_width")#</th>
				<td><cfscript>
					if(form.menu_popup_padding_width EQ ""){
						form.menu_popup_padding_width=10;
					}
					ts = structNew();
					ts.name = "menu_popup_padding_width";
					ts.hideSelect=true;
					ts.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30";
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Pop-up Font Size","member.menu.edit menu_popup_font_size")#</th>
				<td><cfscript>
					if(form.menu_popup_font_size EQ ""){
						form.menu_popup_font_size=12;
					}
					ts = structNew();
					ts.name = "menu_popup_font_size";
					ts.hideSelect=true;
					ts.listValues = "10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30";
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Pop-up Font Color","member.menu.edit menu_popup_font_color")#</th>
				<td>##
					<input class="zColorInput {required:false}" type="text" name="menu_popup_font_color" value="<cfif form.menu_popup_font_color EQ "">000000<cfelse>#HTMLEditFormat(form.menu_popup_font_color)#</cfif>" style="width:10%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;">#application.zcore.functions.zOutputHelpToolTip("Pop-up Background","member.menu.edit menuPopupBackground")#</th>
				<td>#application.zcore.functions.zOutputHelpToolTip("Color","member.menu.edit menu_popup_background_color")#: ##
					<input class="zColorInput {required:false}" type="text" name="menu_popup_background_color" value="<cfif form.menu_popup_background_color EQ "">FFFFFF<cfelse>#HTMLEditFormat(form.menu_popup_background_color)#</cfif>" style="width:10%;">
					<br />
					or #application.zcore.functions.zOutputHelpToolTip("Image","member.menu.edit menu_popup_background_image")#:<br />
					#application.zcore.functions.zInputImage('menu_popup_background_image', request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', request.zos.currentHostName&'/zupload/menu/#form.menu_id#/')# 					</td>
			</tr>
			<tr>
				<th style="width:50px;"> #application.zcore.functions.zOutputHelpToolTip("Pop-up Rollover<br />Font Color","member.menu.edit menu_popup_font_over_color")#</th>
				<td>##
					<input class="zColorInput {required:false}" type="text" name="menu_popup_font_over_color" 
					value="<cfif form.menu_popup_font_over_color EQ "">FFFFFF<cfelse>#HTMLEditFormat(form.menu_popup_font_over_color)#</cfif>" style="width:10%;">
					* Required </td>
			</tr>
			<tr>
				<th style="width:50px;"> #application.zcore.functions.zOutputHelpToolTip("Pop-up Rollover<br />Background","member.menu.edit menuPopupOverBackground")#</th>
				<td>#application.zcore.functions.zOutputHelpToolTip("Color","member.menu.edit menu_popup_background_over_color")#: ##
					<input class="zColorInput {required:false}" type="text" name="menu_popup_background_over_color" 
					value="<cfif form.menu_popup_background_over_color EQ "">000000<cfelse>#HTMLEditFormat(form.menu_popup_background_over_color)#</cfif>" style="width:10%;">
					<br />
					or #application.zcore.functions.zOutputHelpToolTip("Image","member.menu.edit menu_popup_background_over_image")#:<br />
					#application.zcore.functions.zInputImage('menu_popup_background_over_image', request.zos.globals.privatehomedir&'zupload/menu/#form.menu_id#/', 
					request.zos.currentHostName&'/zupload/menu/#form.menu_id#/')# 					</td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Layout:","member.menu.edit menu_vertical")#</th>
				<td style="vertical-align:top; "><input type="radio" name="menu_vertical" value="1" style="border:none; background:none;" <cfif form.menu_vertical EQ 1>checked="checked"</cfif> />
					Vertical (top to bottom)
					<input type="radio" name="menu_vertical" value="0" style="border:none; background:none;" <cfif form.menu_vertical EQ 0 or form.menu_vertical EQ ''>checked="checked"</cfif> />
					Horizontal (left to right) </td>
			</tr>
			<cfif application.zcore.user.checkSiteAccess()>
				<tr>
					<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Lock menu?","member.menu.edit menu_locked")#</th>
					<td style="vertical-align:top; "><input type="radio" name="menu_locked" value="1" <cfif form.menu_locked EQ 1 or form.menu_locked EQ ''>checked="checked"</cfif> style="border:none; background:none;" />
						Yes
						<input type="radio" name="menu_locked" value="0" <cfif form.menu_locked EQ 0>checked="checked"</cfif> style="border:none; background:none;" />
						No </td>
				</tr>
			</cfif>
			<tr>
				<th style="width:100px;"> </th>
				<td><cfif currentMethod EQ 'edit'>
						<button type="submit" value="Update Menu">Update Menu</button>
					<cfelse>
						<button type="submit" value="Add Menu">Add Menu</button>
					</cfif>
					<button type="button" name="cancel" value="Cancel" onclick="window.location.href = '/z/admin/menu/index';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.3");
	</cfscript>
	<h2>Manage Menus</h2>
	<a href="/z/admin/menu/add">Add Menu</a><br />
	<br />
	<cfscript>
	application.zcore.functions.zStatusHandler(request.zsid,true);
	qSite=variables.menuModel.getAllMenus();
	</cfscript>
	<cfif qSite.recordcount NEQ 0>
		<table style="border-spacing:0px; width:100%;" class="table-list">
			<tr>
				<th>ID</th>
				<th>Name</th>
				<th>Admin</th>
			</tr>
			<cfloop query="qSite">
				<tr <cfif qSite.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<td style="vertical-align:top; width:30px; ">#qSite.menu_id#</td>
					<td style="vertical-align:top; ">#qSite.menu_name#</td>
					<td style="vertical-align:top; white-space:nowrap;">
					<a href="/z/admin/menu/edit?menu_id=#qSite.menu_id#&amp;return=1">Edit</a> | 
					<a href="/z/admin/menu/copy?menu_id=#qSite.menu_id#&amp;return=1">Copy</a> | 
					<a href="/z/admin/menu/manageMenu?menu_id=#qSite.menu_id#&amp;return=1">Edit Buttons</a> | 
					<a href="/z/admin/menu/view?menu_id=#qSite.menu_id#">View</a>
					<cfif qSite.menu_locked EQ 0>
						| <a href="/z/admin/menu/delete?menu_id=#qSite.menu_id#&amp;return=1">Delete</a>
						<cfelse>
						| <span style="color:##999999;">Delete Disabled</span>
					</cfif></td>
				</tr>
			</cfloop>
		</table>
	</cfif>
</cffunction>

<cffunction name="view" localmode="modern" access="remote" roles="member">
	<cfscript>
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.3.7");
	qView=variables.menuModel.getById(form.menu_id);
	</cfscript>
	<a href="/z/admin/menu/index">Manage Menus</a> /<br />
	<br />
	<h2>Menu: #qView.menu_name#</h2>
	<cfscript>
    ts=structnew();
    ts.menu_id=form.menu_id;
    rs=application.zcore.functions.zMenuInclude(ts);
    writeoutput(rs.output);
    </cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
