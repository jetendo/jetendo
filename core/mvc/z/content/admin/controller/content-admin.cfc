<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public" roles="member">
	<cfscript>
	form.site_id=request.zos.globals.id;

	form.searchOn=application.zcore.functions.zso(form, 'searchOn', true, 0);
	form.contentStatus = application.zcore.functions.zso(form, "contentStatus", false, "");
    application.zcore.adminSecurityFilter.requireFeatureAccess("Pages");
	if(structcount(application.zcore.app.getAppData("content")) EQ 0){
		application.zcore.status.setStatus(request.zsid,"Access denied");
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	form.content_parent_id=application.zcore.functions.zso(form, 'content_parent_id',true);
	variables.queueSortStruct = StructNew();
	// required
	variables.queueSortStruct.tableName = "content";
	variables.queueSortStruct.sortFieldName = "content_sort";
	variables.queueSortStruct.primaryKeyName = "content_id";
	// optional 
	variables.queueSortStruct.datasource="#request.zos.zcoreDatasource#";
	variables.queueSortWhere="site_id = '#application.zcore.functions.zescape(request.zos.globals.id)#' and content_deleted=0 ";
	if(form.contentStatus EQ "1"){
		variables.queueSortWhere&=" and content_for_sale<>2 ";
	}else if(form.contentStatus EQ "0"){
		variables.queueSortWhere&=" and content_for_sale=2 ";
	}
	variables.queueSortStruct.where = variables.queueSortWhere&" and content_parent_id='#application.zcore.functions.zescape(form.content_parent_id)#' ";
	if(form.contentStatus EQ "1"){
		variables.queueSortStruct.where&=" and content_for_sale<>2 ";
	}else if(form.contentStatus EQ "0"){
		variables.queueSortStruct.where&=" and content_for_sale=2 ";
	}
	variables.queueSortStruct.disableRedirect=true;

	variables.queueSortStruct.ajaxTableId='sortRowTable';
	variables.queueSortStruct.ajaxURL='/z/content/admin/content-admin/#form.method#?content_parent_id=#form.content_parent_id#';
	
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	variables.queueSortCom.init(variables.queueSortStruct);
	

	request.qSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.querySort");
	form.zPageId = request.qSortCom.init("zPageId"); 
	request.sortComSQL=request.qSortCom.getorderby(false);  

	if(structkeyexists(form, 'zQueueSort')){
		application.zcore.functions.zMenuClearCache({content=true});
		application.zcore.functions.zredirect("/z/content/admin/content-admin/index?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
	}
	if(structkeyexists(form, 'zQueueSortAjax')){
		application.zcore.functions.zMenuClearCache({content=true});
		variables.queueSortCom.returnJson();
	}
	application.zcore.template.appendTag("meta",'<style type="text/css">
	/* <![CDATA[ */ .monodrop {
	font-family:"Lucida Console",Courier,Monospace;
	font-size:11px; 
	} /* ]]> */
	</style>');
	request.nofake32=false;
	form.defaultContentId=0;
	</cfscript>
</cffunction>
    
    
<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var qCheck=0;
	var res=0;
	var qChildren=0;
	var qParent=0;
	var db=request.zos.queryObject;
	this.init();
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
    application.zcore.adminSecurityFilter.requireFeatureAccess("Pages", true);
    application.zcore.siteOptionCom.requireSectionEnabledSetId([""]); 
	request.zsession["content_return"&form.content_id]=application.zcore.functions.zso(form, "returnURL");	 
	db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
	WHERE content_id = #db.param(form.content_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	content_deleted=#db.param(0)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		if(form.returnJson){
			application.zcore.functions.zReturnJson({ success:false, errorMessage:'You don''t have permission to delete this content.'});
		}else{
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to delete this content.',false,true);
			if(structkeyexists(request.zsession, 'content_return'&form.content_id) and request.zsession['content_return'&form.content_id] NEQ ""){
				tempURL = request.zsession['content_return'&form.content_id];
				StructDelete(request.zsession, 'content_return'&form.content_id);
				application.zcore.functions.zRedirect(replace(tempURL, "zsid=", "ztv=", "all"), true);
			}else{
				application.zcore.functions.zRedirect('/z/content/admin/content-admin/index?zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
			}
		}
	}
	if(structkeyexists(form, 'confirm')){

		if(request.zos.istestserver){
			application.zcore.grid.deleteGridId(qCheck.content_grid_id, request.zos.globals.id);
		}

		application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.content_image_library_id);
		if(application.zcore.app.siteHasApp("listing")){
			request.zos.listing.functions.zMLSSearchOptionsUpdate('delete',qcheck.content_saved_search_id);
		}
		// don't delete because rewrite rules must persist
		application.zcore.app.getAppCFC("content").searchIndexDeleteContent(form.content_id);
		db.sql="UPDATE #db.table("content", request.zos.zcoreDatasource)# content 
		SET content_deleted=#db.param(1)#, 
		content_updated_datetime=#db.param(request.zos.mysqlnow)#  
		WHERE content_id = #db.param(form.content_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		content_deleted=#db.param(0)# ";
		db.execute("q"); 
		application.zcore.status.setStatus(request.zsid, 'Page deleted.');
		if(qCheck.content_file NEQ ''){
			application.zcore.functions.zDeleteFile(request.zos.globals.homedir&'images/files/'&qCheck.content_file);
		}
		variables.queueSortStruct.where = variables.queueSortWhere&" and content_parent_id='#qcheck.content_parent_id#' and content_deleted='0' ";
		variables.queueSortCom.init(variables.queueSortStruct);
		variables.queueSortCom.sortAll();
		application.zcore.functions.zDeleteUniqueRewriteRule(qCheck.content_unique_name);

		application.zcore.functions.zMenuClearCache({content=true});
		application.zcore.app.getAppCFC("content").updateContentAccessCache(application.siteStruct[request.zos.globals.id]);
		db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE content_id = #db.param(qcheck.content_parent_id)# and 
		content_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qParent=db.execute("qParent");
		db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE content_parent_id = #db.param(qcheck.content_parent_id)# and 
		content_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qChildren=db.execute("qChildren");
		if(form.returnJson){
			application.zcore.functions.zReturnJson({ success:true});
		}else{
			if(structkeyexists(request.zsession, 'content_return'&form.content_id) and request.zsession['content_return'&form.content_id] NEQ ""){ 
				tempURL = request.zsession['content_return'&form.content_id];
				StructDelete(request.zsession, 'content_return'&form.content_id);
				tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
				application.zcore.functions.zRedirect(tempURL, true);
			}else{
				if(qchildren.recordcount EQ 0){
					application.zcore.functions.zRedirect('/z/content/admin/content-admin/index?content_parent_id=#qparent.content_parent_id#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
				}else{
					application.zcore.functions.zRedirect('/z/content/admin/content-admin/index?content_parent_id=#qcheck.content_parent_id#&zsid=#request.zsid#&site_x_option_group_set_id=#form.site_x_option_group_set_id#');
				}
			}	
		}
	}else{
		local.link="/z/content/admin/content-admin/delete?confirm=1&amp;content_id=#form.content_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#";
		if(qcheck.content_parent_id NEQ 0){
			local.link&="&amp;content_parent_id=#qcheck.content_parent_id#";
		}
		writeoutput('<h2>Are you sure you want to delete this content?<br /><br />
		Title: #qCheck.content_name# <br /><br />
		<a href="#local.link#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/content/admin/content-admin/index?content_parent_id=#qcheck.content_parent_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">No</a></h2>');
	}
	</cfscript>
</cffunction>
    
<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var myForm=structnew();
	var photoResize=0; 
	var uniqueChanged=0;
	var qC=0;
	var errors=0;
	var qcheck=0;
	var res=0;
	var tempUrl=0;
	var ts=0;
	var i=0;
	var csn=0;
	var db=request.zos.queryObject;
	this.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Pages", true);
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	for(i in form){
		if(isSimpleValue(form[i])){
			form[i]=trim(form[i]);	
		}
	}
	form.modalpopforced=application.zcore.functions.zso(form, "modalpopforced",true, 0);

	form.content_datetime = application.zcore.functions.zGetDateSelect("content_datetime");
	if(structkeyexists(form, 'content_datetime') and form.content_datetime NEQ false){
		if(isdate(form.content_datetime) EQ false or (form.content_datetime NEQ '' and isdate(form.content_datetime) EQ false)){		
			application.zcore.status.setStatus(request.zsid, 'Invalid Time Format.  Please format like 1:30 pm',form,true);
			if(form.method EQ "update"){
				application.zcore.functions.zRedirect("/z/content/admin/content-admin/edit?content_id=#form.content_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
			}else{
				application.zcore.functions.zRedirect("/z/content/admin/content-admin/add?zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
			}
		}else{
			form.content_datetime=parsedatetime(dateformat(form.content_datetime,'yyyy-mm-dd')&' '&Timeformat(form.content_datetime,'HH:mm:ss'));
			form.content_datetime=DateFormat(form.content_datetime,'yyyy-mm-dd')&' '&Timeformat(form.content_datetime,'HH:mm:ss');
		}
	}
	if(structkeyexists(form, 'content_image_url') and trim(form.content_image_url) EQ 'http://'){
		form.content_image_url='';
	}
	if(structkeyexists(form, 'content_image_url2') and trim(form.content_image_url2) EQ 'http://'){
		form.content_image_url2='';
	}
	if(application.zcore.functions.zso(form, 'request.zos.globals.maximagewidth',true) NEQ 0){
		photoResize="250x500,#request.zos.globals.maximagewidth#x2000";
	}else{
		photoResize='250x500,760x2000';
	}
	
	uniqueChanged=false;
	oldURL='';
	parentChanged=0;
	if(form.method EQ 'insert' and application.zcore.functions.zso(form, 'content_unique_name') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ 'update'){
		db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE content_id = #db.param(form.content_id)# and 
		content_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qCheck=db.execute("qCheck", "", 10000, "query", false);
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'Invalid page.',form,true);
			application.zcore.functions.zRedirect('/z/content/admin/content-admin/index?zsid=#request.zsid#');
		}
		oldURL=qCheck.content_unique_name;
		if(application.zcore.user.checkServerAccess() EQ false and qCheck.content_locked EQ 1){
			form.content_locked=qCheck.content_locked;
		}else{
			if(structkeyexists(form, 'content_unique_name') and qcheck.content_unique_name NEQ form.content_unique_name){
				uniqueChanged=true;	
			}
		}
		if(form.content_parent_id NEQ qCheck.content_parent_id){
			parentChanged=1;
		}
		if(form.content_id EQ form.content_parent_id){
			form.content_parent_id=0; // prevent infinite loop errors.	
		}
	}
	if(form.method EQ 'insert' or qcheck.content_parent_id NEQ form.content_parent_id){
		db.sql="SELECT count(content_id) count 
		FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE content_parent_id = #db.param(form.content_parent_id)# and 
		content_deleted= #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		qC=db.execute("qC");
		form.content_sort=qC.count+1;
	}
	
	myForm.content_metakey.allowNull=true;
	myForm.content_metadesc.allowNull=true;
	myForm.content_name.required=true;
	myForm.content_name.friendlyName="Title";
	myForm.content_metakey.html=true;
	myForm.content_metadesc.html=true;
	errors = application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	if(application.zcore.functions.zso(form,'content_unique_name') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'content_unique_name'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		errors=true;
	}
	if(errors){
		application.zcore.status.setStatus(request.zsid,false,form,true);
		if(form.method EQ "update"){
			application.zcore.functions.zRedirect("/z/content/admin/content-admin/edit?content_id=#form.content_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
		}else{
			application.zcore.functions.zRedirect("/z/content/admin/content-admin/add?zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
		}
	}
	/*
	if(trim(application.zcore.functions.zso(form, 'content_metakey')) EQ ""){
		form.content_metakey=replace(replace(form.content_name,"|"," ","ALL"),","," ","ALL");
	}
	if(trim(application.zcore.functions.zso(form, 'content_metadesc')) EQ ""){
		form.content_metadesc=left(replace(replace(rereplacenocase(trim(form.content_text&" "&form.content_summary),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
	}
	*/
	/*
	if(form.method EQ "update"){
		
		if(application.zcore.functions.zso(form, 'content_metakey') EQ qCheck.content_metakey and qCheck.content_metakey NEQ ""){
			if(replace(replace(qCheck.content_name,"|"," ","ALL"),","," ","ALL") EQ qCheck.content_metakey){
				form.content_metakey=replace(replace(form.content_name,"|"," ","ALL"),","," ","ALL");
			}
		}
		if(application.zcore.functions.zso(form, 'content_metadesc') EQ qCheck.content_metadesc and qCheck.content_metadesc NEQ ""){
			if(left(replace(replace(rereplacenocase(trim(qcheck.content_text&" "&qcheck.content_summary),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150) EQ qCheck.content_metakey){
				form.content_metadesc=left(replace(replace(rereplacenocase(trim(form.content_text&" "&form.content_summary),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
			}
		}
	} */
	csn=form.content_name&" "&form.content_id&" "&form.property_id&" ";
	if(structkeyexists(form, 'content_address')){
		csn&=form.content_address&" ";	
	}
	csn&=form.content_text&" "&form.content_text2&" "&form.content_text3;
	form.content_search=application.zcore.functions.zCleanSearchText(csn, true);
	
	form.content_image_list=trim(application.zcore.functions.zExtractImagesFromHTML(form.content_text)&" "&application.zcore.functions.zExtractImagesFromHTML(form.content_text2)&" "&application.zcore.functions.zExtractImagesFromHTML(form.content_text3));
	
	if(application.zcore.functions.zso(form, 'content_mls_number') NEQ '' and application.zcore.functions.zso(form, 'content_mls_provider') NEQ '' and application.zcore.functions.zso(form, 'content_mls_price') NEQ ''){
		form.content_mls_number=form.content_mls_provider&"-"&form.content_mls_number;
		if(form.content_mls_number NEQ '' and form.content_mls_price EQ 1){
			db.sql="select listing_price,listing_longitude,listing_latitude 
			 from #db.table("listing", request.zos.zcoreDatasource)# listing 
			WHERE listing_id = #db.param(form.content_mls_number)# and 
			listing_deleted = #db.param(0)#";
			qP=db.execute("qP");
			if(qP.recordcount NEQ 0){
				form.content_price=qP.listing_price;
				if(qP.listing_longitude NEQ ""){
					form.content_latitude=qP.listing_latitude;
					form.content_longitude=qP.listing_longitude;	
				}
			}
		}
	}else{
		form.content_mls_provider="";
		form.content_mls_number="";
	}
	
	if(structkeyexists(form, 'content_file')){
		if(form.content_file NEQ ''){
			form.content_file=application.zcore.functions.zUploadFile("content_file", request.zos.globals.homedir&'images/files/', false);
			if(form.content_file EQ false){
				application.zcore.status.setStatus(request.zsid, 'Failed to upload file',form,true);
				if(form.method EQ "update"){
					application.zcore.functions.zRedirect("/z/content/admin/content-admin/edit?content_id=#form.content_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
				}else{
					application.zcore.functions.zRedirect("/z/content/admin/content-admin/add?zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
				}
			}
		}else{
			StructDelete(form, 'content_file');
			StructDelete(form,  'content_file');
			StructDelete(variables, 'content_file');
			if(structkeyexists(form, 'content_file_delete')){
				application.zcore.functions.zDeleteFile(request.zos.globals.homedir&'images/files/'&qCheck.content_file);
				form.content_file='';
			}
		}
	}
	
	if(application.zcore.app.siteHasApp("listing")){
		if(application.zcore.app.siteHasApp("listing")){
			if(isquery(qcheck) and structkeyexists(qcheck, 'recordcount')){
				form.content_saved_search_id=qcheck.content_saved_search_id;
			}else{
				form.content_saved_search_id="";
			}
			if(form.content_search_mls EQ 1) {
				form.content_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', form.content_saved_search_id, '', form);
			} else {
				form.content_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('delete', form.content_saved_search_id);
			}
		}
	}
	if(application.zcore.functions.zso(form, 'convertLinks') EQ 1){
		form.content_text=application.zcore.functions.zProcessAndStoreLinksInHTML(form.content_name, form.content_text);
		form.content_text2=application.zcore.functions.zProcessAndStoreLinksInHTML(form.content_name, form.content_text2);
		form.content_text3=application.zcore.functions.zProcessAndStoreLinksInHTML(form.content_name, form.content_text3);
		form.content_summary=application.zcore.functions.zProcessAndStoreLinksInHTML(form.content_name, form.content_summary);
	}
	
	ts=StructNew();
	ts.table="content";
	ts.struct=form;
	ts.datasource="#request.zos.zcoreDatasource#";
	form.content_updated_datetime=request.zos.mysqlnow;
	if(form.method EQ 'insert'){
		form.content_created_datetime = form.content_updated_datetime;
		form.content_id = application.zcore.functions.zInsert(ts);
		if(form.content_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Page with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect("/z/content/admin/content-admin/add?zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
		}
		variables.queueSortStruct.where = variables.queueSortWhere&" and content_parent_id='#application.zcore.functions.zescape(form.content_parent_id)#' and content_deleted='0' ";
		variables.queueSortCom.init(variables.queueSortStruct);
		variables.queueSortCom.sortAll();
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Page with this name already exists.  Please type a unique name',form,true);
			application.zcore.functions.zRedirect("/z/content/admin/content-admin/edit?content_id=#form.content_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
		}
		if(qcheck.content_parent_id NEQ form.content_parent_id){
			variables.queueSortStruct.where = variables.queueSortWhere&" and content_parent_id='#qcheck.content_parent_id#' and content_deleted='0'";
			variables.queueSortCom.init(variables.queueSortStruct);
			variables.queueSortCom.sortAll();
		}
	}
	
	ts=StructNew();
	ts.struct=form;
	ts.table="content_version";
	ts.datasource="#request.zos.zcoreDatasource#";
	application.zcore.functions.zInsert(ts);
	
	application.zcore.siteOptionCom.activateOptionAppId(application.zcore.functions.zso(form, 'content_site_option_app_id'));
	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'content_image_library_id'));
	
 
	application.zcore.app.getAppCFC("content").searchReindexContent(form.content_id, false);
	//writedump(childStruct);abort;
	if(form.method EQ "update"){
		childStruct=application.zcore.app.getAppCFC("content").getAllContent(qCheck,0, 0); 
		if(qCheck.content_user_group_id NEQ form.content_user_group_id){
			// get all child content_id
			for(contentId in childStruct.arrContentId){
				application.zcore.app.getAppCFC("content").searchReindexContent(contentId, false); 
			}
		}
	} 
	if(uniqueChanged){
		res=application.zcore.app.getAppCFC("content").updateRewriteRuleContent(form.content_id, oldURL);	
		if(res EQ false){
			throw("Failed to process rewrite URLs for content_id = #db.param(form.content_id)# and 
			content_unique_name = #db.param(application.zcore.functions.zso(form, 'content_unique_name'))#.");
		}
	} 
	
	application.zcore.functions.zMenuClearCache({content=true});
	application.zcore.app.getAppCFC("content").updateContentAccessCache(application.siteStruct[request.zos.globals.id]);
	
	if(form.method EQ 'insert'){
		application.zcore.status.setStatus(request.zsid, "Page added.");
		if(structkeyexists(request.zsession, 'content_return') and request.zsession['content_return'] NEQ ""){
			tempURL = request.zsession['content_return'];
			StructDelete(request.zsession, 'content_return');
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}
	}else{
		application.zcore.status.setStatus(request.zsid, "Page updated.");
	}
	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect("/z/content/admin/content-admin/getReturnLayoutRowHTML?content_id=#form.content_id#&mode=#form.mode#&site_x_option_group_set_id=#form.site_x_option_group_set_id#&parentChanged=#parentChanged#");
	}else{
		if(structkeyexists(form, 'content_id') and structkeyexists(request.zsession, 'content_return'&form.content_id) and request.zsession['content_return'&form.content_id] NEQ "" and uniqueChanged EQ false){	
			tempURL = request.zsession['content_return'&form.content_id];
			StructDelete(request.zsession, 'content_return'&form.content_id);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}else{	
			link=application.zcore.functions.zBuildURL('/z/content/admin/content-admin/index', {
				zsid: request.zsid,
				site_x_option_group_set_id:form.site_x_option_group_set_id
			});
			application.zcore.functions.zRedirect(link);
		}
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
	var currentMethod=form.method;
	var db=request.zos.queryObject;
	application.zcore.functions.zSetPageHelpId("2.2");
	this.init();
	if(currentMethod EQ 'Add Content'){
		currentMethod='add'; 
	}
	form.mode=application.zcore.functions.zso(form, "mode", false, "sorting");
	form.modalpopforced=application.zcore.functions.zso(form, "modalpopforced",true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);


	form.content_id=application.zcore.functions.zso(form, 'content_id');
	if(currentMethod EQ "add" or currentMethod EQ "Add Content"){
		application.zcore.template.appendTag('scripts','<script type="text/javascript">/* <![CDATA[ */ 
		var zDisableBackButton=true;
		zArrDeferredFunctions.push(function(){
			zDisableBackButton=true;
		});
		/* ]]> */</script>');
	}
	
	if(application.zcore.functions.zso(form, 'content_parent_id',true) EQ 0){
		form.content_parent_id=0;	
	}
	db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
	WHERE content_id = #db.param(form.content_id)# and 
	content_deleted=#db.param(0)# and 
	content.site_id = #db.param(request.zos.globals.id)# ";
	qContent=db.execute("qContent");
	if(currentMethod EQ 'edit'){
		if(qContent.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this content.',false,true);
			application.zcore.functions.zRedirect('/z/content/admin/content-admin/index?zsid=#request.zsid#');
		}
	}
	
	local.cpi10=form.content_parent_id;
	if(form.method EQ "add" and structkeyexists(form, 'content_parent_id')){
		local.backupContentParentId=form.content_parent_id;
	}
	application.zcore.functions.zQueryToStruct(qContent, form,'content_id,site_id,site_x_option_group_set_id');
	application.zcore.functions.zStatusHandler(request.zsid,true, false, form);
	if(application.zcore.status.getErrorCount(request.zsid) NEQ 0){
		form.content_datetime = application.zcore.functions.zGetDateSelect("content_datetime");	
	}
	request.zsession["content_return"&form.content_id]=application.zcore.functions.zso(form, "returnURL");	 
	if(currentMethod EQ 'add'){
		writeoutput('<h2>Add Page</h2>');
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
	}else{
		writeoutput('<h2>Edit Page</h2>');
	}
	ts=StructNew();
	ts.name="zMLSSearchForm";
	ts.ajax=false;
	if(currentMethod EQ 'add'){
		newAction="insert";
	}else{
		newAction="update";
	}
	ts.class="zFormCheckDirty";
	ts.enctype="multipart/form-data";
	ts.action="/z/content/admin/content-admin/#newAction#?content_id=#form.content_id#&modalpopforced=#form.modalpopforced#&mode=#form.mode#";
	ts.method="post";
	ts.successMessage=false;
	if(application.zcore.app.siteHasApp("listing")){
		ts.onLoadCallback="loadMLSResults";
		ts.onChangeCallback="getMLSCount";
	}
	application.zcore.functions.zForm(ts);
	
	application.zcore.siteOptionCom.setIdHiddenField();

	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
	tabCom.init();
	tabCom.setTabs(["Basic", "Navigation/Layout", "Advanced"]); 
	tabCom.setMenuName("member-content-edit");
	cancelURL=application.zcore.functions.zso(request.zsession, 'content_return'&form.content_id); 
	if(cancelURL EQ ""){
		cancelURL="/z/content/admin/content-admin/index?site_x_option_group_set_id=#form.site_x_option_group_set_id#";
	}
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();
	if(form.modalpopforced EQ 1){
		echo('
		<script type="text/javascript">
		zArrDeferredFunctions.push(function(){
			$(".tabCancelButton").on("click", function(e){
				e.preventDefault();
				window.parent.zCloseModal();
				return false;
			});
		});
		</script>
		');
	}
	</cfscript>
	#tabCom.beginTabMenu()#
	#tabCom.beginFieldSet("Basic")# 
	<table style="width:100%; border-spacing:0px;" class="table-list">
		<tr> 
			<th style="vertical-align:top; ">
				Title *</th>
			<td style="vertical-align:top; ">
				<input type="text" name="content_name" value="#HTMLEditFormat(form.content_name)#" maxlength="150" size="100" />
			</td>
		</tr>

		<tr> 
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Summary Text","member.content.edit content_summary")#</th>
			<td style="vertical-align:top; ">
				<cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "content_summary";
				htmlEditor.value			= form.content_summary;
				htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
				htmlEditor.height		= 250;
				htmlEditor.create();
				</cfscript>   
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Body Column 1","member.content.edit content_text")#</th>
			<td style="vertical-align:top; "> 
				<cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "content_text";
				htmlEditor.value			= form.content_text;
				htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
				htmlEditor.height		= 400;
				htmlEditor.create();
				</cfscript>  
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Body Column 2","member.content.edit content_text2")#</th>
			<td style="vertical-align:top; ">
				<cfif application.zcore.functions.zIsEditorHTMLEmpty(form.content_text2)>
					<p class="bodyColumn2Add"><a href="##" onclick="$('.bodyColumn2').show(); $('.bodyColumn2Add').hide(); return false;">Edit Column 2 (optional)</a></p>
				</cfif>
	
				<div class="bodyColumn2" style="<cfif application.zcore.functions.zIsEditorHTMLEmpty(form.content_text2)>display:none;</cfif>">
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "content_text2";
					htmlEditor.value			= form.content_text2;
					htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
					htmlEditor.height		= 400;
					htmlEditor.create();
					</cfscript>
				</div>  
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Body Column 3","member.content.edit content_text3")#</th>
			<td style="vertical-align:top; "> 
				<cfif application.zcore.functions.zIsEditorHTMLEmpty(form.content_text3)>
					<p class="bodyColumn3Add"><a href="##" onclick="$('.bodyColumn3').show(); $('.bodyColumn3Add').hide(); return false;">Edit Column 3 (optional)</a></p>
				</cfif>
	
				<div class="bodyColumn3" style="<cfif application.zcore.functions.zIsEditorHTMLEmpty(form.content_text3)>display:none;</cfif>">
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "content_text3";
					htmlEditor.value			= form.content_text3;
					htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
					htmlEditor.height		= 400;
					htmlEditor.create();
					</cfscript>  
				</div>
			</td>
		</tr>

		<tr>
			<th style="width:1%; white-space:nowrap;">Cache External Images:</th>
			<td>
			<cfscript>
			form.convertLinks=application.zcore.functions.zso(form, 'convertLinks', true, 0); 
			ts = StructNew();
			ts.name = "convertLinks";
			ts.radio=true;
			ts.separator=" ";
			ts.listValuesDelimiter="|";
			ts.listLabelsDelimiter="|";
			ts.listLabels="Yes|No";
			ts.listValues="1|0";
			application.zcore.functions.zInput_Checkbox(ts);
			</cfscript> | Selecting "Yes", will cache the external images in the html editor to this domain.
			</td>
		</tr>
		<tr>
			<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photos","member.content.edit content_image_library_id")#</th>
			<td>
				<cfscript>
				ts=structnew();
				ts.name="content_image_library_id";
				ts.value=form.content_image_library_id;
				application.zcore.imageLibraryCom.getLibraryForm(ts);
				</cfscript>
			</td>
		</tr>

		<tr>
			<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photo Layout","member.content.edit content_image_library_layout")#</th>
			<td>
				<cfscript>
				ts=structnew();
				ts.name="content_image_library_layout";
				ts.value=form.content_image_library_layout;
				application.zcore.imageLibraryCom.getLayoutTypeForm(ts);
				</cfscript>
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("META Title","member.content.edit content_metatitle")#</th>
			<td style="vertical-align:top; ">
				<input type="text" name="content_metatitle" value="#HTMLEditFormat(form.content_metatitle)#" maxlength="150" size="100" /><br /> (Meta title is optional and overrides the &lt;TITLE&gt; HTML element to be different from the visible page title.)
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Keywords","member.content.edit content_metakey")#</th>
			<td style="vertical-align:top; "> 
				<textarea name="content_metakey" rows="5" cols="60">#form.content_metakey#</textarea>
			</td>
		</tr>
		<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Description","member.content.edit content_metadesc")#</th>
			<td style="vertical-align:top; "> 
				<textarea name="content_metadesc" cols="60" rows="5">#form.content_metadesc#</textarea>
			</td>
		</tr>		
		<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Status","member.content.edit content_for_sale")#</th>
			<td style="vertical-align:top; ">
				<input type="radio" name="content_for_sale" value="1" <cfif application.zcore.functions.zso(form, 'content_for_sale') EQ 1 or application.zcore.functions.zso(form, 'content_for_sale',true) EQ '0'>checked="checked"</cfif> style="border:none; background:none;" /> Active 
				
				<cfif application.zcore.app.siteHasApp("listing")>
				<input type="radio" name="content_for_sale" value="3" <cfif application.zcore.functions.zso(form, 'content_for_sale') EQ 3>checked="checked"</cfif> style="border:none; background:none;" /> Sold
				<input type="radio" name="content_for_sale" value="4" <cfif application.zcore.functions.zso(form, 'content_for_sale') EQ 4>checked="checked"</cfif> style="border:none; background:none;" /> Under Contract
				</cfif>
				<input type="radio" name="content_for_sale" value="2" <cfif application.zcore.functions.zso(form, 'content_for_sale') EQ 2>checked="checked"</cfif> style="border:none; background:none;" /> Inactive
			</td>
		</tr>
		<cfscript>
		if(local.cpi10 NEQ "" and local.cpi10 NEQ "0"){
			db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
			WHERE content_id=#db.param(local.cpi10)# and 
			site_id = #db.param(request.zos.globals.id)# and 
			content_deleted = #db.param(0)#";
			qParent=db.execute("qParent");
		}else{
			qParent=structnew();
			qParent.recordcount=0;
		}
		db.sql="SELECT content_id FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE content_featured_listing_parent_page= #db.param(1)# and 
		content_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)# ";
		qFeaturedListingCheck=db.execute("qFeaturedListingCheck");
		if(qFeaturedListingCheck.recordcount NEQ 0){
			featuredListingParentId=qFeaturedListingCheck.content_id;
		}else{
			featuredListingParentId=0;
		}
		</cfscript>
		<cfif application.zcore.app.siteHasApp("listing")>
			<tr> 
				<th style="vertical-align:top; ">
					#application.zcore.functions.zOutputHelpToolTip("Show Map &amp;<br /> Statistics on <br />Landing Page?","member.content.edit content_show_map")#</th>
				<td style="vertical-align:top; ">
					<input type="radio" name="content_show_map" value="1" <cfif form.content_show_map EQ 1> checked="checked" </cfif> style="border:none; background:none;" /> Yes 
					<input type="radio" name="content_show_map" value="0" <cfif form.content_show_map EQ 0 or form.content_show_map EQ ''> checked="checked" </cfif> onclick="showOptions(0);" style="border:none; background:none;" /> No
				</td>
			</tr>
			<cfif featuredListingParentId NEQ 0 and (qParent.recordcount EQ 0 or qParent.content_featured_listing_parent_page NEQ 1)>
			<cfelse>
				<cfscript>
				if(featuredListingParentId NEQ 0 and (qParent.recordcount NEQ 0 or qParent.content_featured_listing_parent_page EQ 0)){
					form.content_is_listing=1;
				}
				</cfscript>
				<tr> 
					<th style="vertical-align:top; ">
						#application.zcore.functions.zOutputHelpToolTip("Is This a Listing?","member.content.edit content_is_listing")#</th>
					<td style="vertical-align:top; ">
						<input type="radio" name="content_is_listing" value="1" onclick="showOptions(1);" <cfif application.zcore.functions.zso(form, 'content_is_listing') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes 
						<cfif featuredListingParentId NEQ 0 and (qParent.recordcount NEQ 0 or qParent.content_featured_listing_parent_page EQ 0)><cfelse><input type="radio" name="content_is_listing" value="0" <cfif application.zcore.functions.zso(form, 'content_is_listing') EQ 0 or application.zcore.functions.zso(form, 'content_is_listing') EQ ''>checked="checked"</cfif> onclick="showOptions(0);" style="border:none; background:none;" /> No</cfif>
					</td>
				</tr>
			</cfif>
		</cfif>
		</table>
		<script type="text/javascript">
		/* <![CDATA[ */
		function showOptions(n){
			var t=document.getElementById("listingTableId");
			if(n==1){
				t.style.display="block";
			}else{
				t.style.display="none";
			}
		}
		/* ]]> */
		</script>
		<table id="listingTableId" class="table-list" style="width:100%; border-spacing:0px; <cfif application.zcore.functions.zso(form, 'content_is_listing',true) EQ 0>display:none;</cfif> border:0px solid ##999;">
			<tr> 
				<th style="vertical-align:top;">
					#application.zcore.functions.zOutputHelpToolTip("Body Text Position","member.content.edit content_text_position")#</th>
				<td style="vertical-align:top; ">
					<input type="radio" name="content_text_position" value="0" <cfif application.zcore.functions.zso(form, 'content_text_position') EQ 0 or application.zcore.functions.zso(form, 'content_text_position') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> Above related page/listings <input type="radio" name="content_text_position" value="1" <cfif application.zcore.functions.zso(form, 'content_text_position') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Below related pages/listings.
				</td>
			</tr>
		<tr>
			<th style="vertical-align:top;">
				#application.zcore.functions.zOutputHelpToolTip("Property Template","member.content.edit content_property_template")#
			</th>
			<td>
				<select name="content_property_template" size="1">
					<option value="1">Default</option>
					<option value="2">Template 1</option>
				</select>
			</td>
		</tr>

		<cfif application.zcore.app.siteHasApp("listing")>
			<cfscript>
			db.sql="SELECT * FROM (#db.table("mls", request.zos.zcoreDatasource)# mls, 
			#db.table("app_x_mls", request.zos.zcoreDatasource)# app_x_mls, 
			#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site) 
			WHERE mls.mls_id = app_x_mls.mls_id and 
			app_x_mls.site_id = app_x_site.site_id and 
			mls_deleted = #db.param(0)# and 
			app_x_mls_deleted = #db.param(0)# and 
			app_x_site_deleted = #db.param(0)# and
			app_x_site.site_id=#db.param(request.zos.globals.id)# and 
			mls_status = #db.param('1')#";
			qMLS=db.execute("qMLS", "", 10000, "query", false);
			</cfscript>

			<tr> 
			<th style="vertical-align:top;">
				#application.zcore.functions.zOutputHelpToolTip("MLS Providers","member.content.edit content_mls_provider")#</th>
			<td style="vertical-align:top; ">
				<cfscript>
				if(qmls.recordcount EQ 1){
					writeoutput('<input type="hidden" name="content_mls_provider" id="content_mls_provider" value="#qmls.mls_id#"> #qmls.mls_name#');
				}else{
					if(form.content_mls_number CONTAINS '-'){
						form.content_mls_provider=listgetat(form.content_mls_number,1,'-');
						form.content_mls_number=listgetat(form.content_mls_number,2,'-');
					}
					// get the primary mls id from app cache variable?
					if(form.content_mls_provider EQ '' or form.content_mls_provider EQ '0'){
						form.content_mls_provider=application.zcore.app.getAppData("listing").sharedStruct.primaryMlsId;
					}
					selectStruct = StructNew();
					selectStruct.name = "content_mls_provider";
					selectStruct.selectedValues=form.content_mls_provider;
					selectStruct.query=qmls;
					selectStruct.queryLabelField="mls_name";
					selectStruct.queryValueField="mls_id";
					selectStruct.onChange="setMLSDiv();";
					application.zcore.functions.zInputSelectBox(selectStruct);
				}
				</cfscript>
			</td></tr>
			<tr> 
			<th style="vertical-align:top;">
				#application.zcore.functions.zOutputHelpToolTip("MLS ##","member.content.edit content_mls_number")#</th>
			<td style="vertical-align:top; ">
				<cfscript>
				if(form.content_mls_number CONTAINS '-'){
					form.content_mls_number=listgetat(form.content_mls_number,2,"-");
				}
				</cfscript>
			
				<input type="text" name="content_mls_number" id="content_mls_number" value="#HTMLEditFormat(form.content_mls_number)#" onkeyup="setMLSDiv();" size="15" /> <div id="mlslinkdiv" ></div>
				<script type="text/javascript">
				/* <![CDATA[ */
				function trim11 (str) {
					str = str.replace(/^\s+/, '');
					for (var i = str.length - 1; i >= 0; i--) {
						if (/\S/.test(str.charAt(i))) {
							str = str.substring(0, i + 1);
							break;
						}
					}
					return str;
				}
				function setMLSDiv(){
					var d3=document.getElementById('content_mls_provider');
					var d2=document.getElementById('content_mls_number');
					var d=document.getElementById('mlslinkdiv');
					if(this.value==''){
						d.style.display='none';
					}else{
						d.style.display='block';
					}
					if(d3.type=="select"){
						var v1=trim11(d3.options[d3.selectedIndex].value);
					}else{
						var v1=d3.value;	
					}
					var v2=trim11(d2.value);
					if(v1 != "" && v2 != ''){
						v1=arrMId3[v1];
						d.innerHTML='<a href="/property-'+v1+'-'+v2+'.html" target="_blank">Click here to view this mls listing<\/a>';
					}else{
						d.innerHTML='';
					}
				}
				var arrMId3=new Array();
				<cfscript>
				for(local.row in qMLS){
					writeoutput("arrMId3['#local.row.mls_id#']='#local.row.app_x_mls_url_id#';");
				}
				</cfscript>
				setMLSDiv();
				/* ]]> */
				</script>
			</td>
			</tr>
			<tr> 
				<th style="vertical-align:top;">
					#application.zcore.functions.zOutputHelpToolTip("Firm Name","member.content.edit content_firm_name")#</th>
				<td style="vertical-align:top; ">
					<input type="text" name="content_firm_name" value="#HTMLEditFormat(form.content_firm_name)#" style="padding:0px;" size="15" /> 
					<script type="text/javascript">
					/* <![CDATA[ */
					function setPrice(n){
						return;
						var p=document.getElementById("priceTD");
						if(n == 1){
							p.style.display="none";
						}else{
							p.style.display="block";
						}
					}
					/* ]]> */
					</script>
				</td>
			</tr>
			<tr> 
				<th style="vertical-align:top;">
					#application.zcore.functions.zOutputHelpToolTip("Use MLS Price?","member.content.edit content_mls_price")#</th>
				<td style="vertical-align:top; ">
					<input type="radio" name="content_mls_price" onclick="setPrice(1);" value="1" <cfif application.zcore.functions.zso(form, 'content_mls_price') EQ 1 or application.zcore.functions.zso(form, 'content_mls_price') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> Yes 
					<input type="radio" name="content_mls_price" onclick="setPrice(0);" value="0" <cfif application.zcore.functions.zso(form, 'content_mls_price') EQ 0>checked="checked"</cfif> style="border:none; background:none;" /> No 
				</td>
			</tr>
			<tr> 
				<th style="vertical-align:top;">
					#application.zcore.functions.zOutputHelpToolTip("Override MLS?","member.content.edit content_mls_override")#</th>
				<td style="vertical-align:top; ">
					<input type="radio" name="content_mls_override" value="1" <cfif application.zcore.functions.zso(form, 'content_mls_override') EQ 1 or application.zcore.functions.zso(form, 'content_mls_override') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> Yes, show instead of MLS information. 
					<input type="radio" name="content_mls_override" value="0" <cfif application.zcore.functions.zso(form, 'content_mls_override') EQ 0>checked="checked"</cfif> style="border:none; background:none;" /> No, show MLS info only.
				</td>
			</tr>
		</cfif>

		<tr id="priceTD">
			<th style="vertical-align:top;">
				#application.zcore.functions.zOutputHelpToolTip("Price","member.content.edit content_price")#</th>
			<td>
				<input type="text" name="content_price" value="<cfif form.content_price NEQ 0>#HTMLEditFormat(form.content_price)#</cfif>" size="15" />
				<cfif application.zcore.app.siteHasApp("listing")>
				<script type="text/javascript">
				/* <![CDATA[ */
				<cfscript>
				if(application.zcore.functions.zso(form, 'content_mls_price') EQ 1 or application.zcore.functions.zso(form, 'content_mls_price') EQ ''){
					writeoutput('setPrice(1);');
				}else{
					writeoutput('setPrice(0);');
				}
				</cfscript>
				/* ]]> */
				</script>
				</cfif></td>
		</tr>
		<tr>
		<th style="vertical-align:top;">
			#application.zcore.functions.zOutputHelpToolTip("Beds","member.content.edit content_property_bedrooms")#</th><td>
			<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "content_property_bedrooms";
			selectStruct.selectedValues=form.content_property_bedrooms;
			selectStruct.selectLabel = "Any";
			selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		</td></tr>
		<tr><th style="vertical-align:top;">
			#application.zcore.functions.zOutputHelpToolTip("Baths","member.content.edit content_property_bathrooms")#</th><td>
			<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "content_property_bathrooms";
			selectStruct.selectedValues=form.content_property_bathrooms;
			selectStruct.selectLabel = "Any";
			selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		</td></tr>
		<tr><th style="vertical-align:top;">
			#application.zcore.functions.zOutputHelpToolTip("Half Baths","member.content.edit content_property_half_baths")#</th><td>
			<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "content_property_half_baths";
			selectStruct.selectedValues=form.content_property_half_baths;
			selectStruct.selectLabel = "Any";
			selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		</td></tr>
		<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Square Feet","member.content.edit content_property_sqfoot")#</th><td>
			<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "content_property_sqfoot";
			selectStruct.selectedValues=form.content_property_sqfoot;
			selectStruct.selectLabel = "-- Select --";
			selectStruct.listLabels="< 1000,1000 - 1500,1500 - 2000,2000 - 2500,2500 - 3000,3000 - 3500,3500 - 4000,4000 - 4500,4500 - 5000,5000 - 6000,6000 - 7000,7000 - 8000,8000 - 9000,9000 - 10000,10000 +";
			selectStruct.listValues = "1-999,1000-1500,1500-2000,2000-2500,2500-3000,3000-3500,3500-4000,4000-4500,4500-5000,5000-6000,6000-7000,7000-8000,8000-9000,9000-10000,10000-900000";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		</td></tr>
		<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Address","member.content.edit content_address")#</th>
		<td><input type="text" name="content_address" value="#HTMLEditFormat(form.content_address)#" size="40" /></td>
		</tr>
		<cfscript>
		arrLabel=arraynew(1);
		arrValue=arraynew(1);
		rs2=structnew();
		rs2.labels="";
		rs2.values="";
		cityUnq=structnew();
		preLabels="";
		preValues="";
		</cfscript>

		<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("City","member.content.edit content_property_city")#</th>
		<td>
		<cfif application.zcore.app.siteHasApp("listing")>
			<cfscript>
			db.sql="SELECT cast(group_concat(distinct listing_city SEPARATOR #db.param("','")#) AS CHAR) idlist 
			from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
			WHERE 
			#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
			listing_deleted = #db.param(0)# and 
			listing_city not in #db.trustedSQL("('','0','#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#')")#";
			if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
				db.sql&=" and listing_status LIKE '%,7,%' ";
			}
			if(structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')){
				db.sql&=" #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# ";
			}
			qType=db.execute("qType");
			db.sql="select city_x_mls.city_name label, city_x_mls.city_id value 
			from #db.table("city_x_mls", request.zos.zcoreDatasource)# city_x_mls 
			WHERE city_x_mls.city_id IN (#db.trustedSQL("'#qtype.idlist#'")#) and 
			#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))#  and 
			city_x_mls_deleted = #db.param(0)# and
			city_id NOT IN (#db.trustedSQL("'#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#'")#)  ";
			qCity=db.execute("qCity");
			for(local.row in qCity){
				if(structkeyexists(cityUnq,local.row.label) EQ false){
					cityUnq[local.row.label]=local.row.value;
				}
			}
			db.sql="select city.city_name label, city.city_id value 
			from #db.table("city_memory", request.zos.zcoreDatasource)# city 
			WHERE city_id IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list)#'")#) and 
			city_deleted = #db.param(0)#
			ORDER BY label ";
			qCity10=db.execute("qCity10");
			arrK2=arraynew(1);
			arrK3=arraynew(1);
			sOut=Structnew();
			if(qCity10.recordcount NEQ 0){
				for(local.row in qCity10){
					sOut[local.row.label]=true;
					arrayappend(arrK2,local.row.label);
					arrayappend(arrK3,local.row.value);
				}
				preLabels=arraytolist(arrK2,chr(9))&chr(9)&"-----------";
				preValues=arraytolist(arrK3,chr(9))&chr(9);
			}
			
			arrKeys=structkeyarray(cityUnq);
			arraysort(arrKeys,"text","asc");
			for(i=1;i LTE arraylen(arrKeys);i++){
				if(structkeyexists(sOut,arrKeys[i]) EQ false){
					sOut[arrKeys[i]]=true;
					arrayappend(arrLabel,arrKeys[i]);
					arrayappend(arrValue,cityUnq[arrKeys[i]]);
				}
			}
			
			rs2.labels=trim(preLabels&chr(9)&arraytolist(arrLabel,chr(9)));
			rs2.values=trim(preValues&chr(9)&arraytolist(arrValue,chr(9)));
			ts.listLabels=rs2.labels;
			ts.listValues =rs2.values;
			ts = StructNew();
			ts.name="content_property_city";
			ts.selectedValues=form.content_property_city;
			ts.enableTyping=false;
			ts.enableClickSelect=false;
			ts.overrideOnKeyUp=true;
			ts.onkeyup="application.zcore.functions.zMlsCheckCityLookup(event, this,document.getElementById(this.id+'v'),'city_id'); application.zcore.functions.zKeyboardEvent(event, this,document.getElementById(this.id+'v'));";
			ts.onButtonClick="var e2=new Object();e2.keyCode=13;e2.which=13; application.zcore.functions.zKeyboardEvent(e2, document.getElementById('#ts.name#_zmanual'),document.getElementById('#ts.name#_zmanualv'),true);";
			ts.range=false;
			ts.allowAnyText=false;
			ts.onlyOneSelection=true;
			ts.disableSpider=true;
			ts.listLabelsDelimiter = chr(9);
			ts.listValuesDelimiter = chr(9);
			ts.listLabels=rs2.labels;
			ts.listValues =rs2.values;
			ts.inputstyle="padding:0px;font-size:10px; margin:0px;";
			application.zcore.functions.zInputLinkBox(ts);
			</cfscript>
		<cfelse>
			<input type="text" name="content_property_city" value="#form.content_property_city#">
		</cfif></td></tr>


		<cfscript>
		db.sql="SELECT * FROM #db.table("state", request.zos.zcoreDatasource)# state 
		ORDER BY state_state ASC";
		qState=db.execute("qState");
		</cfscript>
		<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("State","member.content.edit content_property_state")#</th><td>
			<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "content_property_state";
			selectStruct.query = qState;
			selectStruct.queryLabelField = "state_state";
			selectStruct.queryValueField = "state_code";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript></td>
		</tr>
		<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Country","member.content.edit content_property_country")#</th><td>
			<cfscript>
			db.sql="SELECT * FROM #db.table("country", request.zos.zcoreDatasource)# country 
			ORDER BY country_name ASC";
			qcountry=db.execute("qcountry");
			selectStruct = StructNew();
			selectStruct.name = "content_property_country";
			selectStruct.query = qcountry;
			selectStruct.queryLabelField = "country_name";
			selectStruct.queryValueField = "country_code";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript></td>
		</tr>
		<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Zip","member.content.edit content_property_zip")#</th>
		<td><input type="text" name="content_property_zip" value="#HTMLEditFormat(application.zcore.functions.zso(form, 'content_property_zip'))#" size="10" />   </td></tr>
		<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Virtual Tour","member.content.edit content_virtual_tour")#</th>
		<td><input type="text" name="content_virtual_tour" value="<cfif form.content_virtual_tour NEQ 0>#HTMLEditFormat(form.content_virtual_tour)#</cfif>" size="50" /></td>
		</tr>
		<tr>
		<th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Diagonal Image<br />Message","member.content.edit content_diagonal_message")#</th><td><table style="width:100%;">
		<tr><td style="width:1%; vertical-align:top;"><textarea cols="30" rows="3" name="content_diagonal_message" onkeyup="document.getElementById('zFlashDiagonalStatusMessageId').innerText=this.value; zMLSShowFlashMessage();">#htmleditformat(form.content_diagonal_message)#</textarea>
		</td><td style="vertical-align:top; ">
		<div style="width:125px; height:125px;" id="zFlashDiagonalStatusMessageId" class="zFlashDiagonalStatusMessage">
		#htmleditformat(form.content_diagonal_message)#</div>
		</td><td style="vertical-align:top;padding-left:5px;">Make sure your message fits in the preview to the side.  Multiple lines are supported.  If entered, this field will override any other messages set like Sold or Under Contract. </td></tr>
		</table></td>
		</tr>
		<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Property ID","member.content.edit property_id")#</th>
		<td><input type="text" name="property_id" value="<cfif form.property_id NEQ 0>#HTMLEditFormat(form.property_id)#</cfif>" size="10" /> (Optional way to identify property for the user)</td>
		</tr>
		
		<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Lot Number","member.content.edit content_lot_number")#</th>
		<td><input type="text" name="content_lot_number" value="#HTMLEditFormat(form.content_lot_number)#" size="10" /></td>
		</tr>
		<cfif application.zcore.app.siteHasApp("rental")>
		<tr> 
		<th style="vertical-align:top;">Rental Features:</th>
		<td style="vertical-align:top; ">
		Select yes to enable the features below and then they will become available for visitors and management.<br />
		#application.zcore.functions.zOutputHelpToolTip("Rental Rates","member.content.edit content_property_enable_rates")#: <input type="radio" name="content_property_enable_rates" value="1" <cfif application.zcore.functions.zso(form, 'content_property_enable_rates') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes <input type="radio" name="content_property_enable_rates" value="0" <cfif application.zcore.functions.zso(form, 'content_property_enable_rates') EQ 0 or application.zcore.functions.zso(form, 'content_property_enable_rates') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> No<br />
		
		#application.zcore.functions.zOutputHelpToolTip("Availability Calendars","member.content.edit content_property_enable_calendar")#:  <input type="radio" name="content_property_enable_calendar" value="1" <cfif application.zcore.functions.zso(form, 'content_property_enable_calendar') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes <input type="radio" name="content_property_enable_calendar" value="0" <cfif application.zcore.functions.zso(form, 'content_property_enable_calendar') EQ 0 or application.zcore.functions.zso(form, 'content_property_enable_calendar') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> No<br />
		
		#application.zcore.functions.zOutputHelpToolTip("Accept Online Reservations","member.content.edit content_property_enable_reservation")#:          
		<input type="radio" name="content_property_enable_reservation" value="1" <cfif application.zcore.functions.zso(form, 'content_property_enable_reservation') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes <input type="radio" name="content_property_enable_reservation" value="0" <cfif application.zcore.functions.zso(form, 'content_property_enable_reservation') EQ 0 or application.zcore.functions.zso(form, 'content_property_enable_calendar') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> No
		</td>
		</tr>
	</cfif>
	<tr> 
	<th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Mix Sold?","member.content.edit content_mix_sold")#</th>
	<td style="vertical-align:top; ">
		<input type="radio" name="content_mix_sold" value="1" <cfif application.zcore.functions.zso(form, 'content_mix_sold') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes 
		<input type="radio" name="content_mix_sold" value="0" <cfif application.zcore.functions.zso(form, 'content_mix_sold') EQ 0 or application.zcore.functions.zso(form, 'content_mix_sold') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> No | This will display random listings mixed between other included active listings
	</td>
	</tr>
	<cfscript>
	userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	usergid = userGroupCom.getGroupId('agent',request.zos.globals.id);
	db.sql="SELECT *, user.site_id userSiteId FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE  user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# 
	and (user_server_administrator=#db.param('0')# )   and 
	user_deleted = #db.param(0)# and 
	#db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# 
	ORDER BY member_first_name ASC, member_last_name ASC";
	qAgents=db.execute("qAgents", "", 10000, "query", false);
	</cfscript>
	<tr><th style="vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Listing Agent","member.content.edit content_listing_user_id")#</th>
		<td>
			<script type="text/javascript">
			/* <![CDATA[ */
			function showAgentPhoto(id){
				var d1=document.getElementById("agentPhotoDiv");
				if(id!="" && arrAgentPhoto[id]!=""){
					d1.innerHTML='<img src="'+arrAgentPhoto[id]+'" width="100" alt="Image" />';
				}else{
					d1.innerHTML="";	
				}
			}
			var arrAgentPhoto=new Array();
			<cfscript>
			for(local.row in qAgents){
				if(qAgents.member_photo NEQ ""){
					writeoutput('arrAgentPhoto["#local.row.user_id#"]="'&jsstringformat(application.zcore.functions.zvar("domain",local.row.userSiteId)&request.zos.memberImagePath&local.row.member_photo)&'";');
				}else{
					writeoutput('arrAgentPhoto["#local.row.user_id#"]="";');
				}
			}
			</cfscript>
			/* ]]> */
			</script>
			<cfscript>
			selectStruct = StructNew();
			selectStruct.name = "content_listing_user_id";
			selectStruct.selectedValues=form.content_listing_user_id;
			selectStruct.query = qAgents;
			selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##)";
			selectStruct.onchange="showAgentPhoto(this.options[this.selectedIndex].value);";
			selectStruct.queryParseLabelVars = true;
			selectStruct.queryValueField = 'user_id';
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript> | Note: to add an agent, go to "<a href="/z/admin/member/index">members</a>" first.
			<br />
			<div id="agentPhotoDiv"></div>
			<cfif application.zcore.functions.zso(form, 'content_listing_user_id',true) NEQ 0>
				<script type="text/javascript">showAgentPhoto(#form.content_listing_user_id#);</script>
			</cfif>
		</td>
	</tr>
	<tr> 
		<th style="vertical-align:top;">Property Type:</th>
		<td style="vertical-align:top; ">
			<cfscript>
			db.sql="SELECT * FROM #db.table("content_property_type", request.zos.zcoreDatasource)# content_property_type 
			WHERE content_property_type_deleted = #db.param(0)#
			ORDER BY content_property_type_name ASC";
			qPType=db.execute("qPType");
			selectStruct = StructNew();
			selectStruct.name = "content_property_type_id";
			selectStruct.selectedValues=form.content_property_type_id;
			selectStruct.query=qPType;
			selectStruct.queryLabelField = "content_property_type_name";
			selectStruct.queryValueField = "content_property_type_id";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript>
		</td>
	</tr>
	</table>
	#tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Navigation/Layout")# 
	<table style="width:100%; border-spacing:0px;" class="table-list">

	<cfif featuredListingParentId EQ 0 or (qParent.recordcount EQ 0 or qParent.content_featured_listing_parent_page NEQ 1)>
		<cfscript>
		db.sql="SELECT *, if(content_user_group_access=#db.param('')# or content_parent_id =#db.param(0)#,#db.param(0)#,#db.param(1)#) groupAccessSet  
		FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE site_id = #db.param(request.zos.globals.id)#
		and content_url_only = #db.param('')#  and 
		content_parent_id = #db.param(0)# and 
		content_deleted=#db.param(0)# 
		ORDER BY groupAccessSet ASC, content_name ASC";
		qAll=db.execute("qAll");
		request.allTempIds=StructNew();
		childStruct=application.zcore.app.getAppCFC("content").getAllContent(qAll,0,form.content_id);
		</cfscript>	
		<cfif qALL.recordcount EQ 0>
			<cfif local.cpi10 NEQ "0">
				<cfif qparent.recordcount NEQ 0>
					<tr> 
						<th style="vertical-align:top; ">Parent Page Title:</th>
						<td style="vertical-align:top; ">		
							#qParent.content_name#
							<input type="hidden" name="content_parent_id" value="#local.cpi10#" /> 
						</td>
					</tr>
				<cfelse>
					<input type="hidden" name="content_parent_id" value="0" /> 
				</cfif>
			<cfelse>
				<input type="hidden" name="content_parent_id" value="#local.cpi10#" /> 
			</cfif>
		<cfelse>
			<tr> 
				<th style="vertical-align:top; ">
					<cfscript>
					if(form.method EQ "add" and structkeyexists(local, 'backupContentParentId')){
						form.content_parent_id=local.backupContentParentId;
					}
					</cfscript>
					#application.zcore.functions.zOutputHelpToolTip("Change Parent Page","member.content.edit content_parent_id")#</th>
				<td style="vertical-align:top; ">		
					<script type="text/javascript">
					function preventSameParent(o,id){
						if(o.options[o.selectedIndex].value == id){
							alert('You can\'t select the same page you are editing.\nPlease select a different page.');
							o.selectedIndex--;
						}
					}
					</script>
					<cfif form.defaultContentId EQ form.content_id>
						This is the root page of your content area and cannot be changed.
						<input type="hidden" name="content_parent_id" value="#local.cpi10#" />
					<cfelse>
						<cfscript>
						selectStruct = StructNew();
						selectStruct.name = "content_parent_id";
						if(local.cpi10 NEQ 0){
							selectStruct.selectedValues=form.content_parent_id;
						}else{
							selectStruct.selectedValues=form.content_parent_id;
						}
						selectStruct.selectLabel ="-- Home Page --";
						selectStruct.listLabels = ArrayToList(childStruct.arrContentName,chr(9));
						selectStruct.listValues = ArrayToList(childStruct.arrContentId,chr(9));
						selectStruct.listLabelsDelimiter = chr(9); 
						selectStruct.listValuesDelimiter = chr(9);
						if(currentMethod EQ 'edit'){
							selectStruct.onChange="preventSameParent(this, #form.content_id#);";
						}
						application.zcore.functions.zInputSelectBox(selectStruct);
						</cfscript><br />Associate this page with another page.
					</cfif>
				</td>
			</tr>
		</cfif>
		<tr>
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Parent Page Link Layout","member.content.edit content_parentpage_link_layout")#</th>
			<td style="vertical-align:top; ">
				<cfscript>
				if(currentMethod EQ "add" and application.zcore.functions.zso(form, 'content_parentpage_link_layout') EQ ""){
					if(local.cpi10 NEQ "0" and qparent.recordcount NEQ 0){
						form.content_parentpage_link_layout=qparent.content_parentpage_link_layout;
					}else if(application.zcore.app.getAppData("content").optionStruct.content_config_default_parentpage_link_layout NEQ ""){
						form.content_parentpage_link_layout=application.zcore.app.getAppData("content").optionStruct.content_config_default_parentpage_link_layout;
					}
				}
				selectStruct = StructNew();
				selectStruct.name = "content_parentpage_link_layout";
				selectStruct.selectedValues=form.content_parentpage_link_layout;
				selectStruct.hideSelect=true;
				selectStruct.listLabels="Invisible,Top with numbered columns,Top with columns,Top on one line,Custom";
				selectStruct.listValues = "7,2,3,4,13";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
		</tr>
		<tr>
		<th style="vertical-align:top; ">
			#application.zcore.functions.zOutputHelpToolTip("Sub-page Link Layout","member.content.edit content_subpage_link_layout")#</th>
		<td style="vertical-align:top; ">
			<cfscript>
			if(currentMethod EQ "add" and application.zcore.functions.zso(form, 'content_subpage_link_layout') EQ ""){
				if(local.cpi10 NEQ "0" and qparent.recordcount NEQ 0){
					form.content_subpage_link_layout=qparent.content_subpage_link_layout;
				}else if(application.zcore.app.getAppData("content").optionStruct.content_config_default_subpage_link_layout NEQ ""){
					form.content_subpage_link_layout=application.zcore.app.getAppData("content").optionStruct.content_config_default_subpage_link_layout;
				}else{
					form.content_subpage_link_layout=0;
				}
			}
			selectStruct = StructNew();
			selectStruct.name = "content_subpage_link_layout";
			selectStruct.selectedValues=form.content_subpage_link_layout;
			selectStruct.hideSelect=true;
			selectStruct.listLabels="Invisible,Bottom with summary (default),Bottom without summary,Bottom with numbered columns,Bottom with columns,Bottom as thumbnails,Top with numbered columns,Top with columns,Top on one line,Find/replace keyword with line breaks,Find/replace keyword with bullets,2 column horizontal image/text panels,3 column horizontal image/text panels,2 column vertical image/text panels,3 column vertical image/text panels,4 column vertical image/text panels,Custom";
			selectStruct.listValues = "7,0,1,8,9,10,2,3,4,11,12,14,15,16,17,18,13";
 
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript> <br />(Note: If you select the "Find/replace" options, please insert %child_links% in the body text field 
		WHERE you want the links to appear.)</td>
		</tr>
		<tr>
		<th style="vertical-align:top; ">
			#application.zcore.functions.zOutputHelpToolTip("Disable child page links?","member.content.edit content_child_disable_links")#</th>
		<td style="vertical-align:top; ">
			#application.zcore.functions.zInput_Boolean("content_child_disable_links")# (Yes will disable the links, but still display the subpages.)
			</td>
		</tr>

		<cfif application.zcore.app.siteHasApp("listing")>
			<tr>
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Sub-Page Sort Method","member.content.edit content_child_sorting")#
			</th>
			<td style="vertical-align:top; ">
				Pages or listings that are associated with this page will automatically sort according to the selected method.<br />
				<input type="radio" name="content_child_sorting" value="0" style="border:none; background:none;" <cfif application.zcore.functions.zso(form, 'content_child_sorting',true) EQ 0>checked="checked"</cfif> /> Manually Sorted <input type="radio" name="content_child_sorting" value="1" style="border:none; background:none;" <cfif application.zcore.functions.zso(form, 'content_child_sorting',true) EQ 1>checked="checked"</cfif> />  Price Descending <input type="radio" name="content_child_sorting" value="2" style="border:none; background:none;" <cfif application.zcore.functions.zso(form, 'content_child_sorting',true) EQ 2>checked="checked"</cfif> /> Price Ascending <input type="radio" name="content_child_sorting" value="3" style="border:none; background:none;" <cfif application.zcore.functions.zso(form, 'content_child_sorting',true) EQ 3>checked="checked"</cfif> />  Alphabetic</td>
			</tr>
		<cfelse>
			<tr>
			<th style="vertical-align:top; ">
				#application.zcore.functions.zOutputHelpToolTip("Sub-Page Sort Method","member.content.edit content_child_sorting")#
			</th>
			<td style="vertical-align:top; ">
				Pages or listings that are associated with this page will automatically sort according to the selected method.<br />
				<input type="radio" name="content_child_sorting" value="0" style="border:none; background:none;" <cfif application.zcore.functions.zso(form, 'content_child_sorting',true) EQ 0>checked="checked"</cfif> /> Manually Sorted <input type="radio" name="content_child_sorting" value="3" style="border:none; background:none;" <cfif application.zcore.functions.zso(form, 'content_child_sorting',true) EQ 3>checked="checked"</cfif> />  Alphabetic</td>
			</tr>
		</cfif>
	<cfelse>
		<input type="hidden" name="content_parent_id" value="#local.cpi10#" />
	</cfif>
	<tr> 
	<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Hide Link?","member.content.edit content_hide_link")#</th>
	<td style="vertical-align:top; ">
		<input type="radio" name="content_hide_link" value="1" <cfif application.zcore.functions.zso(form, 'content_hide_link') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes, remove from all site navigation <input type="radio" name="content_hide_link" value="0" <cfif application.zcore.functions.zso(form, 'content_hide_link',true) EQ 0>checked="checked"</cfif> style="border:none; background:none;" /> No <br />
	</td>
	</tr>
	<tr> 
		<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Show on site map?","member.content.edit content_show_site_map")#</th>
		<td style="vertical-align:top; ">
			<input type="radio" name="content_show_site_map" value="1" <cfif application.zcore.functions.zso(form, 'content_show_site_map') EQ 1 or application.zcore.functions.zso(form, 'content_show_site_map') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> Yes 
			<input type="radio" name="content_show_site_map" value="0" <cfif application.zcore.functions.zso(form, 'content_show_site_map') EQ 0>checked="checked"</cfif> style="border:none; background:none;" /> No 
		</td>
	</tr> 
        <tr>
        <th>Thumbnail Image Size:</th>
        <td>
		<p>Leave as zero to inherit default size</p>
		<p>Width: <input type="text" name="content_thumbnail_width" value="#htmleditformat(form.content_thumbnail_width)#" /> </p>
		<p>Height: <input type="text" name="content_thumbnail_height" value="#htmleditformat(form.content_thumbnail_height)#" /> </p>
		<p>Crop: 
		<cfscript>
		if(form.content_thumbnail_crop EQ ""){
			form.content_thumbnail_crop=0;
		}
		ts = StructNew();
		ts.name = "content_thumbnail_crop";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		</cfscript> (Default is 250x250, uncropped).</p>
		</td>
        </tr>
	<cfif application.zcore.app.getAppData("content").optionStruct.content_config_contact_links EQ 1>
		<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Enable Contact Links?","member.content.edit content_disable_contact_links")#</th>
			<td style="vertical-align:top; ">
				<input type="radio" name="content_disable_contact_links" value="1" <cfif application.zcore.functions.zso(form, 'content_disable_contact_links') EQ 1 or application.zcore.functions.zso(form, 'content_disable_contact_links') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> Yes 
				<input type="radio" name="content_disable_contact_links" value="0" <cfif application.zcore.functions.zso(form, 'content_disable_contact_links') EQ 0>checked="checked"</cfif> style="border:none; background:none;" /> No (Note, if your text says "Email" "Call" or "Contact us", they will be made into clickable links if you select "Yes".)
		</td>
		</tr>
	</cfif>

	<cfif application.zcore.user.checkServerAccess() and structkeyexists(request.zos,'listing')>
		<tr> 
		<th style="vertical-align:top; ">
			#application.zcore.functions.zOutputHelpToolTip("Featured listing page?","member.content.edit content_featured_listing_parent_page")#</th>
		<td style="vertical-align:top; ">
			<input type="radio" name="content_featured_listing_parent_page" value="1" <cfif application.zcore.functions.zso(form, 'content_featured_listing_parent_page') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes 
			<input type="radio" name="content_featured_listing_parent_page" value="0" <cfif application.zcore.functions.zso(form, 'content_featured_listing_parent_page',true) EQ 0>checked="checked"</cfif> style="border:none; background:none;" /> No <br />
			Note: If you select Yes, no other page on the site can be used to create new listings.  This will add an "Add Listing" link to the Real Estate manager menu to simplify adding listings.
		</td>
		</tr>
	</cfif>
	<tr>
		<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Template","member.content.edit content_template")#</th>
		<td>
			<cfscript>
			if(directoryexists(request.zos.globals.homedir&"templates/")){
				directory name="qTemplate" directory="#request.zos.globals.homedir#templates/" filter="*.cfm";
				directory name="qTemplate2" directory="#request.zos.globals.homedir#templates/" filter="*.cfc";
			}else{
				qTemplate=querynew("name");
				qTemplate2=querynew("name");
			}
			arrTemplate=[];
			for(row in qTemplate){
				arrayAppend(arrTemplate, row.name);
			}
			for(row in qTemplate2){
				arrayAppend(arrTemplate, "root.templates."&left(row.name, len(row.name)-4));
			}
			selectStruct = StructNew();
			selectStruct.name = "content_template";
			selectStruct.selectedValues=form.content_template;
			selectStruct.output = true;
			selectStruct.listLabels = arrayToList(arrTemplate, ",");
			selectStruct.listValues = selectStruct.listLabels;
			selectStruct.listLabelsDelimiter = ","; 
			selectStruct.listValuesDelimiter = ",";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript> (Leave blank to inherit default template)
		</td>
	</tr> 
	</table>
	#tabCom.endFieldSet()#
	#tabCom.beginFieldSet("Advanced")# 
	<table style="width:100%; border-spacing:0px;" class="table-list">
	<tr> 
		<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Unique URL","member.content.edit content_unique_name")#</th>
		<td style="vertical-align:top; "> 	
			<cfif currentMethod EQ "add">
				#application.zcore.functions.zInputUniqueUrl("content_unique_name", true)#
			<cfelse>
				#application.zcore.functions.zInputUniqueUrl("content_unique_name")#
			</cfif>
		</td>
	</tr>
	<tr> 
		<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("URL Rewriting","member.content.edit content_system_url")#</th>
		<td style="vertical-align:top; ">
			<input type="radio" name="content_system_url" value="0" <cfif application.zcore.functions.zso(form, 'content_system_url') EQ 0 or application.zcore.functions.zso(form, 'content_system_url') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> On 
			<input type="radio" name="content_system_url" value="1" <cfif application.zcore.functions.zso(form, 'content_system_url') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Off (Turn off to allow system urls to continue functioning).
		</td>
	</tr>
	<tr> 
		<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Code","member.content.edit content_metacode")#</th>
		<td style="vertical-align:top; "> 
			<textarea name="content_metacode" cols="60" rows="5">#form.content_metacode#</textarea>
		</td>
	</tr>	

	<tr> 
		<th style="vertical-align:top; ">
			#application.zcore.functions.zOutputHelpToolTip("Subheading","member.content.edit content_name2")#</th>
		<td style="vertical-align:top; ">
			<input type="text" name="content_name2" value="#HTMLEditFormat(form.content_name2)#" maxlength="150" size="100" />
		</td>
	</tr>
	<tr>
		<th style="vertical-align:top; ">
			#application.zcore.functions.zOutputHelpToolTip("Menu Title","member.content.edit content_menu_title")#</th>
		<td style="vertical-align:top; ">
			<input type="text" name="content_menu_title" value="#HTMLEditFormat(form.content_menu_title)#" maxlength="50" size="50" /><br /> (Overrides title in some menus)
		</td>
	</tr>
	<tr> 
		<th style="vertical-align:top; ">
			#application.zcore.functions.zOutputHelpToolTip("External Link","member.content.edit content_url_only")#:</th>
		<td style="vertical-align:top; ">
			<input type="text" name="content_url_only" value="#HTMLEditFormat(form.content_url_only)#" size="100" /> <br />
			Note: External Link is a way to link to another page without duplicating content.  All other fields will not be displayed if you use this field.
		</td>
	</tr>
	<cfif application.zcore.functions.zso(request.zos.globals, 'enableManageSlideshow', true, 0) EQ 1>
		
		<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Slideshow","member.content.edit content_slideshow_id")#</th>
			<td style="vertical-align:top; ">
				<cfscript>
				db.sql="SELECT * FROM #db.table("slideshow", request.zos.zcoreDatasource)# slideshow 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				slideshow_deleted = #db.param(0)#
				ORDER BY slideshow_name ASC";
				qslide=db.execute("qslide");
				selectStruct = StructNew();
				selectStruct.name = "content_slideshow_id";
				selectStruct.selectedValues=form.content_slideshow_id;
				selectStruct.query = qslide;
				selectStruct.selectLabel="-- Select --";
				selectStruct.queryLabelField = "slideshow_name";
				selectStruct.queryValueField = "slideshow_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript> | 
				<a href="##" onclick="if(document.getElementById('content_slideshow_id').selectedIndex != 0){ window.open('/z/admin/slideshow/edit?slideshow_id='+document.getElementById('content_slideshow_id').options[document.getElementById('content_slideshow_id').selectedIndex].value); } return false; " rel="external">Edit selected slideshow</a> | 
				<a href="/z/admin/slideshow/add" rel="external" onclick="window.open(this.href); return false;">Create a slideshow</a>
			</td>
		</tr>
	</cfif>
	<tr> 
	<th style="vertical-align:top; ">
		#application.zcore.functions.zOutputHelpToolTip("Included Page IDs","member.content.edit content_include_listings")#</th>
	<td style="vertical-align:top; ">
		<input type="text" name="content_include_listings" value="#HTMLEditFormat(form.content_include_listings)#" size="15" /><br /> Comma separated list of other listings
	</td>
	</tr>
	<tr>
		<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Hide Modal Windows?","member.content.edit content_hide_modal")#</th>
		<td style="vertical-align:top; ">
			<input type="radio" name="content_hide_modal" value="1" <cfif application.zcore.functions.zso(form, 'content_hide_modal') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes
			<input type="radio" name="content_hide_modal" value="0" <cfif application.zcore.functions.zso(form, 'content_hide_modal') EQ 0 or application.zcore.functions.zso(form, 'content_hide_modal') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> No (Modal windows that automatically appear will be disabled for this page if you select "Yes".)
		</td>
	</tr>

	<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator")>
		<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Viewable by","member.content.edit content_user_group_id")#</th>
			<td style="vertical-align:top; ">
				
				<cfscript>
				// find the parent pages...
				qUserGroups 
				tempParentId=form.content_parent_id;
				count=0;
				db.sql="SELECT * FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group WHERE 
				user_group_deleted = #db.param(0)# and 
				site_id = #db.param(request.zos.globals.id)#";
				if(not application.zcore.app.siteHasApp("listing")){ 
					db.sql&=" and user_group_name NOT IN (#db.param('broker')#, #db.param('agent')#)";
				}
				db.sql&=" ORDER BY user_group_name ASC";
				qUserGroups=db.execute("qUserGroups", "", 10000, "query", false);
				groupStruct={};
				for(row in qUserGroups){
					groupStruct[row.user_group_id]=row.user_group_name;
				}
				hasGroupId=false;
				groupName="Anyone";
				while(true){
					count++;
					if(form.content_parent_id EQ 0){
						break;
					}else{
						if(count GT 200){
							throw("Infinite loop detected for content_id: #form.content_id# - This must be manually fixed by the developer.");
						}
						db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# 
						WHERE content_id=#db.param(tempParentId)# and 
						site_id = #db.param(request.zos.globals.id)# and 
						content_deleted = #db.param(0)#";
						qParent=db.execute("qParent");
						if(qParent.recordcount EQ 0){
							break;
						}else{
							tempParentId=qParent.content_parent_id;
							if(qParent.content_user_group_id NEQ 0){
								if(structkeyexists(groupStruct, qParent.content_user_group_id)){
									echo("<h3>A parent page has set ""Viewable by"" to: "&groupStruct[qParent.content_user_group_id]&'</h3>');
									echo('<p>You can override the group below or leave it blank to inherit the setting from the parent page.</p>');
									groupName=groupStruct[qParent.content_user_group_id];
									hasGroupId=true;
								}
								break;
							}
						}
					}
				} 
				if(not hasGroupId){
					if(form.method EQ "add" and (form.content_user_group_id EQ "" or form.content_user_group_id EQ "0")){
						form.content_user_group_id=application.zcore.functions.zso(application.zcore.app.getAppData("content").optionStruct, 'content_config_viewable_by_default_group');
					}
				}
				echo('<p>User group:');
				selectStruct = StructNew();
				selectStruct.name = "content_user_group_id";
				selectStruct.selectedValues=form.content_user_group_id;
				selectStruct.query = qUserGroups;
				if(groupName NEQ "Anyone"){
					selectStruct.selectLabel="Inherit: #groupName#";
				}else{
					selectStruct.selectLabel="-- #groupName# --";
				}
				selectStruct.queryLabelField = "user_group_friendly_name";
				selectStruct.queryValueField = "user_group_id";
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript> </p>
				<p>Note: Only users with access to this group will be able to view this page and its children.</p>
			</td>
		</tr>
	</cfif>
	<tr> 
	<th style="vertical-align:top; ">
		#application.zcore.functions.zOutputHelpToolTip("Insert<br />Advanced Code","member.content.edit content_html_text")#</th>
	<td style="vertical-align:top; ">
		ADVANCED USERS ONLY! Please put only Complex Javascript HTML Code in the field below.  This is useful for embedding javascript, maps, videos, flash widgets without the editor breaking / filtering the content. <br /><br />
		<textarea cols="100" rows="10" name="content_html_text">#htmleditformat(form.content_html_text)#</textarea><br /><br />
		Show at the <input type="radio" name="content_html_text_bottom" value="1" <cfif form.content_html_text_bottom EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Bottom <input type="radio" name="content_html_text_bottom" value="0" <cfif form.content_html_text_bottom EQ 0 or form.content_html_text_bottom EQ "">checked="checked"</cfif> style="border:none; background:none;" /> Top
	</td>
	</tr>
	
	<cfif application.zcore.user.checkServerAccess()>
		<tr> 
			<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Lock content?","member.content.edit content_locked")#</th>
			<td style="vertical-align:top; ">
				<input type="radio" name="content_locked" value="1" <cfif form.content_locked EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes <input type="radio" name="content_locked" value="0" <cfif form.content_locked EQ 0 or form.content_locked EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> No
			</td>
		</tr> 
	</cfif>

	<cfscript>
	db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# 
	WHERE site_option_appidlist like #db.param('%,12,%')# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_option_deleted=#db.param(0)#";
	qOptionCheck=db.execute("qOptionCheck");

	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_option_group_appidlist like #db.param('%,12,%')# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_deleted=#db.param(0)#";
	qGroupCheck=db.execute("qGroupCheck");
	</cfscript>
	<cfif qOptionCheck.recordcount or qGroupCheck.recordcount>
	
		<tr>
			<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Custom Fields","member.content.edit content_site_option_app_id")#</th>
			<td>
				<cfscript>
				ts=structnew();
				ts.name="content_site_option_app_id";
				ts.app_id=application.zcore.app.getAppCFC("content").app_id;
				ts.value=form.content_site_option_app_id;
				application.zcore.siteOptionCom.getOptionForm(ts);
				</cfscript>
			</td>
		</tr>
	</cfif>
	</table>


	<cfif application.zcore.app.siteHasApp("listing")>
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<td>
					<strong>MLS Search Options</strong><br />
					<cfscript>
					request.zos.listing.functions.zMLSSearchOptions(form.content_saved_search_id, "content_search_mls", form.content_search_mls);
					</cfscript>
				</td>
			</tr>
		</table>
	</cfif>
	#tabCom.endFieldSet()#
	#tabCom.endTabMenu()#
	#application.zcore.functions.zEndForm()#
	
	<cfif application.zcore.app.siteHasApp("listing")>
		<script type="text/javascript">/* <![CDATA[ */ 
		zArrDeferredFunctions.push(function(){getMLSCount('zMLSSearchForm');}); 
		/* ]]> */</script>
	</cfif>
</cffunction>

<cffunction name="processimport" localmode="modern" access="remote" roles="member">
	<cfscript>
    application.zcore.adminSecurityFilter.requireFeatureAccess("Pages", true);
	var db=request.zos.queryObject;
	if(structkeyexists(form, 'filepath') EQ false or form.filepath EQ ""){
		application.zcore.status.setStatus(request.zsid, "You must upload a CSV file", true);
		application.zcore.functions.zRedirect("/z/content/admin/content-admin/import?zsid=#request.zsid#");
	}
	f1=application.zcore.functions.zuploadfile("filepath",request.zos.globals.privatehomedir&"/zupload/user/",false);
	fileContents=application.zcore.functions.zreadfile(request.zos.globals.privatehomedir&"/zupload/user/"&f1);
	d1=application.zcore.functions.zdeletefile(request.zos.globals.privatehomedir&"/zupload/user/"&f1);
	
	t38=structnew();
	t38["title"]=true;
	t38["parenturl"]=true;
	t38["menutitle"]=true;
	t38["url"]=true;
	t38["parentid"]=true;
	t38["text"]=true;
	dataImportCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.dataImport");
	dataImportCom.parseCSV(fileContents);
	dataImportCom.getFirstRowAsColumns();
	for(n=1;n LTE arraylen(dataImportCom.arrColumns);n++){
		if(structkeyexists(t38, dataImportCom.arrColumns[n]) EQ false){
			application.zcore.status.setStatus(request.zsid, "#dataImportCom.arrColumns[n]# is not a valid column name. The first row must have the page title and it may also have the following columns: menutitle, url, parenturl", true);
			application.zcore.functions.zRedirect("/z/content/admin/content-admin/import?zsid=#request.zsid#");
		}
	}	
	ts=StructNew();
	ts["title"] = "title";
	ts["menutitle"] = "menutitle";
	ts["parenturl"] = "parenturl";
	ts["parentid"] = "parentid";
	ts["url"] = "url";
	ts["text"] = "text";
	dataImportCom.mapColumns(ts);
	arrData=arraynew(1);
	local.curCount=dataImportCom.getCount();
	for(g=1;g  LTE local.curCount;g++){
		ts=dataImportCom.getRow();	
		for(i in ts){
			ts[i]=trim(ts[i]);	
		}
		if(ts.title EQ ""){
			application.zcore.status.setStatus(request.zsid, "All imported rows must have a title. Import cancelled.", true);
			application.zcore.functions.zRedirect("/z/content/admin/content-admin/import?zsid=#request.zsid#");
		}
		if(ts.url NEQ "" and left(ts.url,1) NEQ "/"){
			application.zcore.status.setStatus(request.zsid, "All imported urls must start with / (root relative). Import cancelled.", true);
			application.zcore.functions.zRedirect("/z/content/admin/content-admin/import?zsid=#request.zsid#");
		}
		if(ts.parenturl NEQ "" and left(ts.parenturl,1) NEQ "/"){
			application.zcore.status.setStatus(request.zsid, "All imported urls must start with / (root relative). Import cancelled.", true);
			application.zcore.functions.zRedirect("/z/content/admin/content-admin/import?zsid=#request.zsid#");
		}
		if(ts.parenturl NEQ "" or (ts.parentid NEQ "" and ts.parentid NEQ "0")){
			arrayappend(arrData, ts);
		}else{
			arrayinsertat(arrData, 1,ts);
		}
	}

	for(i=1;i LTE arraylen(arrData);i++){
		if(arrData[i].url NEQ ""){
			db.sql="SELECT content_id FROM #db.table("content", request.zos.zcoreDatasource)# content 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			content_unique_name = #db.param(arrData[i].url)# and 
			content_for_sale = #db.param(1)# and 
			content_deleted=#db.param(0)#";
			qIdCheck=db.execute("qIdCheck");
		}

		if(arrData[i].url EQ "" or qIdCheck.recordcount EQ 0){
			if(arrData[i].parentid NEQ 0 and arrData[i].parentid NEQ ""){
				db.sql="SELECT content_id FROM #db.table("content", request.zos.zcoreDatasource)# content 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				content_id = #db.param(arrData[i].parentid)# and 
				content_for_sale = #db.param(1)# and 
				content_deleted=#db.param(0)#";
				qIdCheck2=db.execute("qIdCheck2");
				if(qIdCheck2.recordcount EQ 0){
					application.zcore.status.setStatus(request.zsid, "The parent page for title, """&arrData[i].title&""", doesn't exist.", form,true);
					arrData[i].parentid="0";
				}
			}else if(arrData[i].parenturl NEQ ""){
				db.sql="SELECT content_id FROM #db.table("content", request.zos.zcoreDatasource)# content 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				content_unique_name = #db.param(arrData[i].parenturl)# and 
				content_for_sale = #db.param(1)# and 
				content_deleted=#db.param(0)#";
				qIdCheck2=db.execute("qIdCheck2");
				if(qIdCheck2.recordcount EQ 0){
					application.zcore.status.setStatus(request.zsid, "The parent page for title, """&arrData[i].title&""", doesn't exist.", form,true);
					arrData[i].parentid="0";
				}else{
					arrData[i].parentid=qIdCheck2.content_id;
				}
			}else{
				arrData[i].parentid="0";
			} 
			db.sql="SELECT max(content_sort) sortnum 
			FROM #db.table("content", request.zos.zcoreDatasource)# content 
			WHERE site_id = #db.param(request.zos.globals.id)# and 
			content_parent_id = #db.param(arrData[i].parentid)# and 
			content_for_sale = #db.param(1)# and 
			content_deleted=#db.param(0)#";
			qIdCheck3=db.execute("qIdCheck3");
			if(qIdCheck3.recordcount EQ 0 or qIdCheck3.sortnum EQ ""){
				form.content_sort="1";
			}else{
				form.content_sort=qIdCheck3.sortnum+1;
			}
			if(arrData[i].url EQ "/z/misc/search-site/results" or arrData[i].url EQ "/z/misc/search-site/no-results"){
				siteMap='0';
				hideLink='1';
			}else{
				siteMap='1';
				hideLink='0';				
			} 
			db.sql="INSERT INTO #db.table("content", request.zos.zcoreDatasource)#  
			SET `content_text` = #db.param(arrData[i].text)#,
			`content_name` = #db.param(arrData[i].title)#,
			`content_unique_name` = #db.param(arrData[i].url)#,
			`content_parent_id` = #db.param(arrData[i].parentid)#,
			`content_locked` = #db.param(0)#,
			`content_mls_price` = #db.param(1)#,
			`content_created_datetime` = #db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(),'HH:mm:ss'))#,
			`content_updated_datetime` = #db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(),'HH:mm:ss'))#,
			`content_sort` = #db.param(form.content_sort)#,
			`content_datetime` = #db.param('')#,
			`content_hide_link` = #db.param(hideLink)#,
			`content_show_site_map` = #db.param(siteMap)#,
			`content_html_text` = #db.param('')#,
			`content_hide_modal` = #db.param(0)#,
			`content_for_sale` = #db.param(1)#,
			`content_mls_provider` = #db.param('')#,
			`content_mls_number` = #db.param('')#,
			`content_mls_override` = #db.param(1)#,
			`content_search` = #db.param(arrData[i].title)#,
			`content_menu_title` = #db.param(arrData[i].menutitle)#,
			`content_subpage_link_layout` = #db.param(0)#,
			`content_parentpage_link_layout` = #db.param(7)#,
			site_id=#db.param(request.zos.globals.id)# ";
			db.execute("q");
		}
	}
	application.zcore.app.getAppCFC("content").updateContentAccessCache(application.siteStruct[request.zos.globals.id]);
	application.zcore.status.setStatus(request.zsid, "Import complete.");
	application.zcore.functions.zRedirect("/z/content/admin/content-admin/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>


<cffunction name="processtitleimport" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var arrTitle=0;
	var qIdCheck3=0;
	var content_sort=0;
	var css1=0;
	var i=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Pages", true);
	arrTitle=listtoarray(form.titlecontent,chr(10),false);
	db.sql="SELECT max(content_sort) sortnum 
	FROM #db.table("content", request.zos.zcoreDatasource)# content 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	content_parent_id = #db.param(0)# and 
	content_for_sale = #db.param(1)# and 
	content_deleted=#db.param('0')#";
	qIdCheck3=db.execute("qIdCheck3");
	if(qIdCheck3.recordcount EQ 0 or qIdCheck3.sortnum EQ ""){
		css1=0;
	}else{
		css1=qIdCheck3.sortnum;
	}
	for(i=1;i LTE arraylen(arrTitle);i++){
		content_sort=css1+i;
		db.sql="INSERT INTO #db.table("content", request.zos.zcoreDatasource)#  
		SET `content_name` = #db.param(arrTitle[i])#,
		`content_parent_id` = #db.param(0)#,
		`content_locked` = #db.param(0)#,
		`content_mls_price` = #db.param(1)#,
		`content_address` = #db.param('')#,
		`content_created_datetime` = #db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(),'HH:mm:ss'))#,
		`content_updated_datetime` = #db.param(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(),'HH:mm:ss'))#,
		`content_sort` = #db.param(content_sort)#,
		`content_hide_link` = #db.param(0)#,
		`content_show_site_map` = #db.param(1)#,
		`content_for_sale` = #db.param(1)#,
		`content_mls_override` = #db.param(1)#,
		`content_search_mls` = #db.param(0)#,
		`content_search` = #db.param(arrTitle[i])#,
		`content_child_sorting` = #db.param(0)#,
		`content_mix_sold` = #db.param(0)#, 
		`content_property_enable_rates` = #db.param(0)#,
		`content_property_enable_calendar` = #db.param(0)#,
		`content_property_enable_reservation` = #db.param(0)#,
		`content_deleted` = #db.param(0)#,
		`content_property_template` = #db.param(1)#,
		`content_image_library_layout` = #db.param(0)#,
		`content_subpage_link_layout` = #db.param(0)#,
		`content_parentpage_link_layout` = #db.param(7)#,
		site_id=#db.param(request.zos.globals.id)# ";
		db.execute("q");
	}
	application.zcore.app.getAppCFC("content").updateContentAccessCache(application.siteStruct[request.zos.globals.id]);
	application.zcore.status.setStatus(request.zsid, "Pages created successfully.");
	application.zcore.functions.zRedirect("/z/content/admin/content-admin/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="import" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.zStatusHandler(request.zsid,true, false, form);
    application.zcore.adminSecurityFilter.requireFeatureAccess("Pages");
	application.zcore.functions.zSetPageHelpId("2.1.1");
	</cfscript>
	<h2>Import Pages</h2>
	<p>You can upload a file with separate columns or enter titles to create new pages below.</p>
	<h3>File Import</h3>
	<p><a href="/z/a/images/page-import-template.csv" rel="external" onclick="window.open(this.href); return false;">Download Page Import Template CSV</a></p>
	<p>CSV columns should be: title, menutitle, url, parenturl, parentid, text</p>
	<p>If the parentid field is not in the CSV, then the parenturl field will be used to determine the parentid.  If the parent page can't be found, then the page will be imported without being associated to another page. The parentid should match the id column of an existing page on <a href="/z/content/admin/content-admin/index">manage pages</a>. To ensure the parent page lookup works, make sure the child pages are below their parent in the CSV.</p>
	<p>Parent URL must start with a forward slash (root relative URL, i.e. /my-page.html)</p>
	<form class="zFormCheckDirty" action="/z/content/admin/content-admin/processimport" enctype="multipart/form-data" method="post">
		<input type="file" name="filepath" value="" /> <input type="submit" name="submit1" value="Import CSV" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
			<div id="pleaseWait" style="display:none;">Please wait...</div>
	</form>
	<hr />
	<br />
	
	<h3>Title Only Import</h3>
	<p>Enter one title on each line to create new pages in bulk.</p>
	<form class="zFormCheckDirty" action="/z/content/admin/content-admin/processtitleimport" method="post">
		<textarea name="titlecontent" rows="20" cols="100">#htmleditformat(application.zcore.functions.zso(form, 'titlecontent'))#</textarea><br />
		<input type="submit" name="submit1" value="Create Pages" />
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 

	application.zcore.template.setTag("title", "Pages");

	/*
	savecontent variable="navOut"{
		linkStruct=application.zcore.app.getAppCFC("content").getAdminLinks({});

		if(structkeyexists(linkStruct, "Content Manager")){
			childStruct=linkStruct["Content Manager"].children;
			echo('<h2>Content Manager</h2> <div style="float:left; margin-bottom:10px;width:100%;">');
			arrKey=structkeyarray(childStruct);
			arraySort(arrKey, "text", "asc");
			count=0;
			for(i=1;i LTE arraylen(arrKey);i++){
				i2=arrKey[i];
				if(application.zcore.adminSecurityFilter.checkFeatureAccess(childStruct[i2].featureName)){
					if(count NEQ 0){
						echo(' | ');
					}
					count++;
					echo('<a href="#childStruct[i2].link#">'&i2&'</a>');
				}
			}
			echo('</div>');
		}
	}
	*/
	if(not application.zcore.adminSecurityFilter.checkFeatureAccess("Pages")){
		return;
	}
	application.zcore.functions.zSetPageHelpId("2.1"); 
	this.init();
	//echo(navOut);
	application.zcore.siteOptionCom.requireSectionEnabledSetId([""]);
	//application.zcore.siteOptionCom.displaySectionNav();
	application.zcore.functions.zStatusHandler(request.zsid,true, false, form); 
	form.mode=application.zcore.functions.zso(form, 'mode', false, 'sorting');
	form.searchText=replace(application.zcore.functions.zso(form, 'searchText'), '+', ' ', 'all');
	form.searchTextOriginal=replace(replace(replace(form.searchText, '+', ' ', 'all'), '@', '_', 'all'), '"', '', "all");
	form.searchText=application.zcore.functions.zCleanSearchText(form.searchText, true);
	if(form.searchText NEQ "" and isNumeric(form.searchText) EQ false and len(form.searchText) LTE 2){
		application.zcore.status.setStatus(request.zsid,"The search searchText must be 3 or more characters.",form);
		application.zcore.functions.zRedirect("/z/content/admin/content-admin/index?zsid=#request.zsid#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#");
	}
	if(form.searchText EQ ""){
		form.searchText=form.searchTextOriginal;
	}
	searchTextReg=rereplace(form.searchText,"[^A-Za-z0-9[[:white:]]]*",".","ALL");
	searchTextOReg=rereplace(form.searchTextOriginal,"[^A-Za-z0-9 ]*",".","ALL");
	Request.zScriptName2 = "/z/content/admin/content-admin/index?searchOn=#form.searchOn#&contentStatus=#form.contentStatus#&searchtext=#urlencodedformat(application.zcore.functions.zso(form, 'searchtext'))#&content_parent_id=#application.zcore.functions.zso(form, 'content_parent_id')#";
	 
	writeoutput('
	<div class="z-manager-list-view">
		<div class="z-float">
			<h2 id="pages_regular" style="display:inline-block;">Pages</h2>');
 
	echo(' &nbsp;&nbsp; ');
	echo('<a href="/z/content/admin/content-admin/add?content_parent_id=#application.zcore.functions.zso(form, 'content_parent_id')#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#" class="z-button">Add</a> ');
	if(request.sortComSQL NEQ ''){
		echo('<a href="/z/content/admin/content-admin/index?site_x_option_group_set_id=#form.site_x_option_group_set_id#" class="z-button">Reset Sorting</a>');
	}
	echo(' Mode: ');
	if(form.mode EQ "sorting"){
		echo('Sorting');
	}else{
		echo('<a href="/z/content/admin/content-admin/index?mode=sorting" title="Click to enable page sorting">Sorting</a>');
	}
	echo(' | ');
	if(form.mode EQ "sitemap"){
		echo('Site Map');
	}else{
		echo('<a href="/z/content/admin/content-admin/index?mode=sitemap" title="Click to view page heirarchy">Site Map</a>');
	}
	if(application.zcore.user.checkServerAccess()){
		writeoutput(' | 
		<a href="/z/content/admin/content-admin-new/import">Import</a>
		 | <a href="/z/content/admin/content-admin-new/index?forceContentInit=1&amp;rt29=#gettickcount()#">Initialize Content</a> 
		');
	} 
	 
	writeoutput('	</div>');

 
	if(form.content_parent_id NEQ 0){
		db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE content_id = #db.param(form.content_parent_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
		content_deleted=#db.param(0)#  ";
		qcontentp=db.execute("qcontentp");
		if(qcontentp.recordcount EQ 0){
			application.zcore.functions.zredirect("/z/content/admin/content-admin/index");
		}
		request.parentChildSorting=qcontentp.content_child_sorting;
	}else{
		request.parentChildSorting=0;
	}
	searchColumn="concat(content.content_name,' ',cast(content.content_price as char(11)),' ',content.content_address,' ',cast(content.content_id as char(11)),' ',content.content_search)";
	ts=structnew();
	ts.image_library_id_field="content.content_image_library_id";
	ts.count =  1; 
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT *, 
	#db.trustedSQL("if(content.content_price = 0,0.00,content.content_price) content_price2, 
	if(content.content_mls_number = #db.param('')#,'z',content.content_mls_number) content_mls_number2, 
	if(content.content_address = #db.param('')#,'z',content.content_address) content_address2, ")#
	<cfif form.searchText NEQ ''>
	
		<cfif application.zcore.enableFullTextIndex>
			MATCH(content.content_search) AGAINST (#db.param(form.searchText)#) as score , 
			MATCH(content.content_search) AGAINST (#db.param(form.searchTextOriginal)#) as score2 , 
		</cfif>
		if(content.content_id = #db.param(form.searchText)#, #db.param(1)#,#db.param(0)#) matchingId, 
		#db.trustedSQL("if(concat(content.content_id,' ',cast(content.content_price as char(11)),' ',content.content_address,' ',content.content_mls_number)")# like #db.param('%#form.searchTextOriginal#%')#,#db.param(1)#,#db.param(0)#) as matchPriceAddress, 
	</cfif>
	count(c2.content_id) children 
	#db.trustedSQL(rs2.select)#  
	FROM ( #db.table("content", request.zos.zcoreDatasource)# content ) 
	#db.trustedSQL(rs2.leftJoin)#
	LEFT JOIN #db.table("content", request.zos.zcoreDatasource)# c2 ON 
	c2.content_parent_id = content.content_id and 
	c2.content_deleted= #db.param(0)# and 
	c2.site_id = content.site_id 
	
	WHERE 
	content.site_id = #db.param(request.zos.globals.id)#
	<cfif form.searchText NEQ ''> 
		and 
		
		(#db.trustedSQL("concat(content.content_id,' ',cast(content.content_price as char(11)),' ',content.content_address,' ',content.content_mls_number)")# like 
		#db.param('%#form.searchTextOriginal#%')#  or 
		content.content_text like #db.param('%#form.searchTextOriginal#%')# or 
		(
		((
		<cfif application.zcore.enableFullTextIndex>
			MATCH(content.content_search) AGAINST (#db.param(form.searchText)#) or 
			MATCH(content.content_search) AGAINST (#db.param('+#replace(trim(replace(replace(form.searchText, '-', ' ', 'all'), '  ', ' ', 'all')),' ','* +','ALL')#*')# IN BOOLEAN MODE) 
		<cfelse>
			content.content_search like #db.param('%#replace(form.searchText,' ','%','ALL')#%')#
		</cfif>
		) or (
		
		<cfif application.zcore.enableFullTextIndex>
			MATCH(content.content_search) AGAINST (#db.param(form.searchTextOriginal)#) or 
			MATCH(content.content_search) AGAINST (#db.param('+#replace(trim(replace(replace(form.searchTextOriginal, '-', ' ', 'all'), '  ', ' ', 'all')),' ','* +','ALL')#*')# IN BOOLEAN MODE)
		<cfelse>
			content.content_search like #db.param('%#replace(form.searchTextOriginal,' ','%','ALL')#%')#
		</cfif>
		)) 
		)) 
	<cfelse> 
		<cfif form.mode EQ "sorting" and form.searchOn EQ "0">
	
			<cfif structkeyexists(form, 'content_parent_id')> 
				and content.content_parent_id = #db.param(form.content_parent_id)#
			<cfelse>
				and content.content_parent_id = #db.param('0')#
			</cfif> 
		</cfif>
	</cfif> 
	<cfif form.contentStatus NEQ "">
		<cfif form.contentStatus EQ 1> 
			and content.content_for_sale<>#db.param('2')#
		<cfelseif form.contentStatus EQ 0> 
			and content.content_for_sale=#db.param('2')#
		</cfif>
	</cfif>
	and content.content_deleted = #db.param('0')# and 
	content.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# 

	<cfif not application.zcore.user.checkServerAccess()>
		and content.content_hide_edit = #db.param(0)# 
	</cfif>
	
	GROUP BY content.content_id 
	ORDER BY 
	<cfif form.mode EQ "sorting">
		<cfif request.sortComSQL NEQ ''>
			#request.sortComSQL# content.content_sort
		<cfelse>
			<cfif form.searchText NEQ ''>
				matchPriceAddress DESC ,matchingId DESC 
				<cfif application.zcore.enableFullTextIndex>
					 ,score2 DESC, score DESC  
				</cfif>, 
			</cfif>
			<cfif request.parentChildSorting EQ 1>
			content.content_price DESC
			<cfelseif request.parentChildSorting EQ 2>
			content.content_price ASC
			<cfelseif request.parentChildSorting EQ 3>
			content.content_name ASC
			<cfelseif request.parentChildSorting EQ 0>
			content.content_parent_id ASC, content.content_sort ASC, content.content_datetime DESC, content.content_created_datetime DESC
			</cfif>
		</cfif> 
	<cfelse>
		content.content_parent_id ASC, content.content_sort ASC, content.content_datetime DESC, content.content_created_datetime DESC
	</cfif>
	
	</cfsavecontent><cfscript>
	qSite=db.execute("qSite"); 

	form.searchText=form.searchTextOriginal;
	</cfscript>  

	<cfscript>
	g="";
	arrNav=ArrayNew(1);
	if(application.zcore.functions.zso(form, 'searchtext') EQ ''){
		if(qsite.recordcount EQ 0){
			cpi=application.zcore.functions.zso(form, 'content_parent_id',true);
		}else{
			cpi=qsite.content_parent_id;
		}
	}else{
		cpi=0;
	}
	arrName=ArrayNew(1);
	parentparentid='0';
	parentChildGroupId=0; 
	for(g=1;g LTE 255;g++){
		db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE content_id = #db.param(cpi)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		content_deleted=#db.param(0)# ";
		qpar=db.execute("qpar");
		if(qpar.recordcount EQ 0){
			break;
		}
		if(g EQ 1){
			parentParentId=qpar.content_parent_id;
		}
		ArrayAppend(arrName, qpar.content_name);
		arrayappend(arrNav, '<a href="/z/content/admin/content-admin/index?content_parent_id=#qpar.content_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">#qPar.content_name#</a> / ');
		cpi=qpar.content_parent_id;
		if(cpi EQ 0){
			break;
		}
	}
	</cfscript>


	<div class="z-float z-mb-10"> 
		<cfscript>
		if(form.site_x_option_group_set_id NEQ 0){
			if((structkeyexists(form, 'content_parent_id') EQ false or form.content_parent_id EQ 0) and application.zcore.functions.zso(form, 'searchtext') EQ ''){
				echo ('Section Root');
			}else{
				echo('<a href="/z/content/admin/content-admin/index?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Section Root</a> / ');
			}
		}else{
			if((structkeyexists(form, 'content_parent_id') EQ false or form.content_parent_id EQ 0) and application.zcore.functions.zso(form, 'searchtext') EQ ''){
				writeoutput('Home /');
			}else{
				writeoutput('<a href="/z/content/admin/content-admin/index">Home</a> / ');
			}
		}
		for(i=arraylen(arrNav);i GTE 2;i=i-1){
			writeoutput(arrNav[i]);
		}
		if(ArrayLen(arrNav) NEQ 0){
			writeoutput(arrName[1]);
		}
		</cfscript> 
	</div>

	<cfscript>
	arrSearch=listtoarray(form.searchtext," ");
	if(arraylen(arrSearch) EQ 0){
		arrSearch[1]="";	
	}
	</cfscript>
	
	<cfif application.zcore.app.siteHasApp("listing") and form.content_parent_id NEQ 0>
		<div style="float:left;">Sorting method: <cfif request.parentChildSorting EQ 1>Price Descending<cfelseif request.parentChildSorting EQ 2>Price Ascending<cfelseif request.parentChildSorting EQ 3>Alphabetic<cfelse>Manual (Click black arrows)</cfif> | </div>
		<div style="float:left; width:150px;"><a href="/z/content/admin/content-admin/edit?content_id=#application.zcore.functions.zso(form, 'content_parent_id')#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#&amp;mode=#form.mode#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">#application.zcore.functions.zOutputHelpToolTip("Change Sorting Method","member.content.list changeSortingMethod")#</a></div><br />
	</cfif> 

	<form name="myForm22" action="/z/content/admin/content-admin/index" method="GET" style="margin:0px;"> 
		<input type="hidden" name="site_x_option_group_set_id" value="#form.site_x_option_group_set_id#">
		<input type="hidden" name="searchOn" value="1">
		#application.zcore.siteOptionCom.setIdHiddenField()#
		<div class="z-float-left z-pr-10 z-pb-10">
			Search: 
			<input type="text" name="searchtext" id="searchtext" value="#htmleditformat(application.zcore.functions.zso(form, 'searchtext'))#" style="min-width:100px; width:300px;max-width:100%; min-width:auto;" size="20" maxchars="10" /> 
		</div>
		<div class="z-float-left z-pr-10 z-pb-10">
			Active: #application.zcore.functions.zInput_Boolean("contentStatus", form.contentStatus)# 
			</div>
			<div class="z-float-left z-pr-10 z-pb-10">
			<input type="submit" name="searchForm" value="Search" class="z-manager-search-button" /> 
			<cfif application.zcore.functions.zso(form, 'searchOn') EQ '1'>
				<input type="button" name="searchForm2" value="Clear Search" class="z-manager-search-button" onclick="window.location.href='/z/content/admin/content-admin/index?site_x_option_group_set_id=#form.site_x_option_group_set_id#';" />
			</cfif>
		</div>
		<input type="hidden" name="zIndex" value="1" />
	</form>
	<cfif qSite.recordcount EQ 0>
		<div class="z-float z-mb-10">No content added yet. </div>
	<cfelse>
		<table <cfif form.mode EQ "sorting">id="sortRowTable"</cfif> style="border-spacing:0px; width:100%;" class="table-list">
			<thead>
			<tr>
				<th class="z-hide-at-767"><a href="#request.qSortCom.getColumnURL("content.content_id", Request.zScriptName2)#">ID</a> #request.qSortCom.getColumnIcon("content.content_id")#</th>
				<th class="z-hide-at-767">Photo</th>
				<th>
					<a href="#request.qSortCom.getColumnURL("content.content_name", Request.zScriptName2)#">Title</a> #request.qSortCom.getColumnIcon("content.content_name")# 
					<cfif application.zcore.app.siteHasApp("listing")>
						/ <a href="#request.qSortCom.getColumnURL("content_address2", Request.zScriptName2)#">Address</a>
						 #request.qSortCom.getColumnIcon("content_address2")# / 
						 <a href="#request.qSortCom.getColumnURL("content_mls_number2", Request.zScriptName2)#">MLS ##</a> 
						 #request.qSortCom.getColumnIcon("content_mls_number2")# / 
						 <a href="#request.qSortCom.getColumnURL("content_price2", Request.zScriptName2)#">Price</a> #request.qSortCom.getColumnIcon("content_price2")#
					 </cfif>
				 </th> 
				<th>Last Updated</th> 
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
			<cfscript>
			contentLookupStruct={}; 
			request.parentLookupStruct={}; 
			arrOrder=[];
			currentRow=0;
 
			if(form.mode EQ "sorting"){ 
				for(row in qSite){ 
					arrayAppend(arrOrder, row);
				} 
			}else{
				for(row in qSite){ 
					if(not structkeyexists(contentLookupStruct, row.content_parent_id)){
						contentLookupStruct[row.content_parent_id]=[];
					}
					arrayAppend(contentLookupStruct[row.content_parent_id], row); 
					request.parentLookupStruct[row.content_id]=row.content_parent_id;
				} 
				getContentSiteMapOrder(arrOrder, 0, contentLookupStruct);  
			}
			for(i12=1;i12<=arraylen(arrOrder);i12++){
				row=arrOrder[i12];
				currentRow++;
				echo('<tr ');
				if(form.mode EQ "sorting"){
					echo(variables.queueSortCom.getRowHTML(row.content_id));
				}
				if(currentrow MOD 2 EQ 0){
					echo('class="row1"');
				}else{
					echo('class="row2"');
				}
				echo('>');
				getLayoutRowHTML(row);
				echo('</tr>');
			}
			</cfscript>
			</tbody>
		</table> 
	</cfif> 

	<cfscript>
	
	if(application.zcore.adminSecurityFilter.checkFeatureAccess("Site Options")){
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		site_option_group_parent_id=#db.param(0)# and 
		site_option_group_enable_unique_url=#db.param(1)# and 
		site_option_group_deleted=#db.param(0)# 
		ORDER BY site_option_group_display_name ASC";
		qGroup=db.execute("qGroup");
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		site_option_group_parent_id=#db.param(0)# and 
		site_option_group_allow_public=#db.param(1)# and 
		site_option_group_deleted=#db.param(0)# 
		ORDER BY site_option_group_display_name ASC";
		qGroupPublic=db.execute("qGroupPublic");
	
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		site_option_group_parent_id=#db.param(0)# and 
		site_option_group_enable_unique_url=#db.param(0)# and  
		site_option_group_allow_public=#db.param(0)# and 
		site_option_group_deleted=#db.param(0)# 
		ORDER BY site_option_group_display_name ASC";
		qGroupCustom=db.execute("qGroupCustom");

		echo('
			<div class="z-float z-mt-10">
			<h2>Other Site Content</h2>
			<ul style="margin-top:0px;">
				');

		if(qGroup.recordcount){
			echo('<li><a href="##pages_custom">Custom Landing Pages</a></li> ');
		}
		if(qGroupCustom.recordcount){
			echo('<li><a href="##pages_customtypes">Custom Content Types</a></li> ');
		}

		echo('<li><a href="##pages_publicforms">Public Forms</a></li> 
			<li><a href="##pages_builtin">Built-in Landing Pages</a></li> 
		</ul></div>'); 
	}
	</cfscript>
	<div style="float:left; width:100%; line-height:1.7; font-size:16px; padding-top:20px;">
		<cfif application.zcore.adminSecurityFilter.checkFeatureAccess("Site Options")>
		 
			<cfif qGroup.recordcount>
				<h2 id="pages_custom">Custom Landing Pages</h2>
				<p>Your web site has additional custom made landing pages that can be edited at the following locations:</p>
				<ul>
				<cfloop query="qGroup">
					<li><a href="/z/admin/site-options/manageGroup?site_option_group_id=#qGroup.site_option_group_id#">#qGroup.site_option_group_display_name#<cfif qGroup.site_option_group_limit NEQ 1 and right(qGroup.site_option_group_display_name, 1) NEQ "s">(s)</cfif></a></li>
				</cfloop>
				</ul>
			</cfif>
 
			<cfif qGroupCustom.recordcount>
				<h2 id="pages_customtypes">Custom Content Types</h2>
				<p>Your web site has additional custom content types that can be edited at the following locations:</p>
				<ul>
				<cfloop query="qGroupCustom">
					<li><a href="/z/admin/site-options/manageGroup?site_option_group_id=#qGroupCustom.site_option_group_id#">#qGroupCustom.site_option_group_display_name#<cfif qGroupCustom.site_option_group_limit NEQ 1 and right(qGroupCustom.site_option_group_display_name, 1) NEQ "s">(s)</cfif></a></li>
				</cfloop>
				</ul>
			</cfif>
	
		</cfif>

		<h2 id="pages_publicforms">Public Forms</h2>
		<cfscript>
		echo('<ul>');
		// qGroupPublic
		if(application.zcore.adminSecurityFilter.checkFeatureAccess("Site Options")){
			for(row in qGroupPublic){
				link=row.site_option_group_public_form_url;
				if(link EQ ""){
					link="/z/misc/display-site-option-group/add?site_option_group_id="&row.site_option_group_id;
				}	
				echo('<li><a href="'&link&'" target="_blank">'&row.site_option_group_display_name&'</a></li>');
			}
		}

		echo('<li><a href="/z/misc/inquiry/index" target="_blank">Inquiry Form</a></li>
		<li><a href="/z/misc/mailing-list/index" target="_blank">Mailing List Signup Form</a></li>
		<li><a href="/z/misc/loan-calculator/index" target="_blank">Loan Calculator Form</a></li>
		<li><a href="/z/misc/mortgage-quote/index" target="_blank">Mortgage Quote Form</a></li>');
		if(request.zos.globals.enableSendToFriend EQ 1){
			echo('<li><a href="/z/misc/share-with-friend/index?link=#request.zos.globals.domain#" target="_blank">Share With Friend Form</a></li>');
		}
		if(application.zcore.app.siteHasApp("rental")){
			link=application.zcore.app.getAppCFC("rental").getRentalInquiryLink();
			echo('<li><a href="#link#" target="_blank">Rental - Inquiry Form</a></li>');
		}


		if(application.zcore.app.siteHasApp("listing")){
			echo('
			<li><a href="/z/misc/mortgage-calculator/index" target="_blank">Real Estate - Mortgage Calculator</a></li> 
			<li><a href="/z/listing/cma-inquiry/index" target="_blank">Real Estate - CMA Inquiry Form</a></li>
			<li><a href="/z/listing/new-listing-email-signup/index" target="_blank">Real Estate - New Listings By Email Signup Form</a></li>');
		}
		echo('</ul>');
		</cfscript>

		<h2 id="pages_builtin">Built-in Landing Pages</h2>
		<cfscript>
		echo('<ul>');
		echo('
		<li><a href="/z/misc/system/missing" target="_blank">404 Not Found Page</a></li>
		<li><a href="/z/misc/system/legal" target="_blank">Legal Notices</a></li>
		<li><a href="/z/misc/members/index" target="_blank">Our Team - Public User Profiles</a></li> 
		<li><a href="/z/user/privacy/index" target="_blank">Privacy Policy</a></li>
		<li><a href="/z/user/preference/register" target="_blank">Public User Create Account</a> (You have to logout to view this)</li>
		<li><a href="/z/user/home/index" target="_blank">Public User Home Page</a></li>
		<li><a href="/z/user/preference/index" target="_blank">Public User Login</a> (You have to logout to view this)</li>
		<li><a href="/z/user/out/index" target="_blank">Public User Opt Out Form</a></li> 
		<li><a href="/z/user/preference/form" target="_blank">Public User Preferences</a></li>
		<li><a href="/z/user/reset-password/index" target="_blank">Public User Reset Password</a></li>
		<li><a href="/z/misc/search-site/search" target="_blank">Search Site</a></li> 
		<li><a href="/z/misc/site-map/index" target="_blank">Site Map</a></li>
		<li><a href="/z/user/terms-of-use/index" target="_blank">Terms of Use</a></li>');
		if(application.zcore.app.siteHasApp("listing")){
			echo('<li><a href="/z/listing/map-fullscreen/index" target="_blank">Real Estate - Fullscreen Map Search</a></li>
			<li><a href="/z/listing/search-form/index" target="_blank">Real Estate - Search Results</a></li>
			<li><a href="/z/listing/advanced-search/index" target="_blank">Real Estate - Advanced Search</a></li>
			<li><a href="/z/listing/property/your-saved-searches/index" target="_blank">Real Estate - Your Saved Searches</a></li>
			<li><a href="/z/listing/sl/view" target="_blank">Real Estate - Your Saved Listings</a></li>

			');
		}
		if(application.zcore.app.siteHasApp("rental")){
			link=application.zcore.app.getAppCFC("rental").getRentalHomeLink();
			echo('<li><a href="#link#" target="_blank">Rental - Home Page</a></li>');

		}
		echo('</ul>');
		</cfscript>
	</div>
	</div>
</cffunction>

<cffunction name="getReturnLayoutRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript> 
	init();


	var db=request.zos.queryObject; 
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);
	form.content_id=application.zcore.functions.zso(form, "content_id", true, 0);
	form.mode=application.zcore.functions.zso(form, 'mode', false, 'sorting');
	form.parentChanged=application.zcore.functions.zso(form, 'parentChanged', true, 0);

	ts=structnew();
	ts.image_library_id_field="content.content_image_library_id";
	ts.count =  1; 
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);  
	db.sql="SELECT *, 
	count(c2.content_id) children 
	#db.trustedSQL(rs2.select)#  
	FROM #db.table("content", request.zos.zcoreDatasource)#

	LEFT JOIN #db.table("content", request.zos.zcoreDatasource)# c2 ON 
	c2.content_parent_id = content.content_id and 
	c2.content_deleted= #db.param(0)# and 
	c2.site_id = content.site_id 
	#db.trustedSQL(rs2.leftJoin)#
	WHERE   
	content.content_deleted = #db.param(0)# and  
	content.content_id=#db.param(form.content_id)# and 
	content.site_id=#db.param(request.zos.globals.id)# 
	GROUP BY content.content_id ";
	qcontent=db.execute("qcontent");

	indent=0;
	request.parentLookupStruct={};
	if(qcontent.content_parent_id NEQ 0){
		db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
		WHERE content_id = #db.param(qcontent.content_parent_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
		content_deleted=#db.param(0)#  ";
		qcontentp=db.execute("qcontentp");
		if(qcontentp.recordcount EQ 0){
			application.zcore.functions.zredirect("/z/content/admin/content-admin/index");
		} 
		request.parentChildSorting=qcontentp.content_child_sorting;
	}else{ 
		request.parentChildSorting=0;
	}

	 
	savecontent variable="rowOut"{
		for(row in qcontent){
			getLayoutRowHTML(row);
		}
	}
	if(form.parentChanged EQ 1){
		echo('<script type="text/javascript">
		window.parent.location.reload(false);
		</script>');
	}else{
		echo('<script type="text/javascript">
		window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
		window.parent.zCloseModal();
		</script>');
	}
	abort;
	</cfscript>
</cffunction>

<cffunction name="getLayoutRowHTML" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;  
	indentCount=0;
	parentId=row.content_parent_id;
	loopCount=0;
	indentChars="";
	while(true){
		if(parentId NEQ 0 and structkeyexists(request, 'parentLookupStruct') and structkeyexists(request.parentLookupStruct, parentId)){
			parentId=request.parentLookupStruct[parentId];
			indentCount++;
			indentChars&="&nbsp;&nbsp;&nbsp;&nbsp;";
		}else{
			break;
		}
		loopCount++;
		if(loopCount > 50){
			throw("Infinite loop detected. content_id:#row.content_id#");
		}
	} 

	ts=structnew();
	ts.image_library_id=row.content_image_library_id;
	ts.output=false;
	ts.struct=row;
	ts.size="100x70";
	ts.crop=1;
	ts.count = 1;
	arrImages=application.zcore.imageLibraryCom.displayImageFromStruct(ts);
	contentphoto99=""; 
	if(arraylen(arrImages) NEQ 0){
		contentphoto99=(arrImages[1].link);
	}
	</cfscript>
	<td class="z-hide-at-767" style="vertical-align:top; width:30px; ">#row.content_id#</td>
	<td class="z-hide-at-767" style="vertical-align:top; width:100px; ">
		<cfif contentphoto99 NEQ "">
			<img alt="Image" src="#request.zos.currentHostName&contentphoto99#" style="max-width:100%;" /></a>
		<cfelse>
			&nbsp;
		</cfif></td>
	<td style="vertical-align:top; padding-left:#indentCount*20#px;">
		<!--- #indentChars# --->

		<cfsavecontent variable="title">
			#row.content_name#
			<cfif application.zcore.app.siteHasApp("listing")><br />
				<cfif row.content_address NEQ ''>#row.content_address# | </cfif>
				<cfif row.content_mls_number CONTAINS '-'>MLS ##:#listgetat(row.content_mls_number,2,"-")# | </cfif>
				<cfif row.content_price NEQ 0>#DollarFormat(row.content_price)#</cfif>
			</cfif>
		</cfsavecontent>
		<!--- <cfif form.mode EQ "sorting">

			<cfif row.children NEQ 0><a href="/z/content/admin/content-admin/index?content_parent_id=#row.content_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#"></cfif>
				#title#	
			<cfif row.children NEQ 0></a></cfif>
		<cfelse> --->
			#title#
		<!--- </cfif> --->
		<!--- <br /><span style="color:##999; font-size:11px;">

		<cfif row.content_property_type_id NEQ "0">
			<cfsavecontent variable="db.sql">
			SELECT * FROM #db.table("content_property_type", request.zos.zcoreDatasource)# content_property_type 
			WHERE content_property_type_id= #db.param(row.content_property_type_id)#
			
			</cfsavecontent><cfscript>qPType=db.execute("qPType");</cfscript><cfif qPType.recordcount NEQ 0> | #qPType.content_property_type_name#</cfif></cfif>  
		
		</span> --->
		<!--- <cfif row.content_unique_name NEQ ""><br /><span style="font-size:10px; color:##999999;">#row.content_unique_name#
			<cfif row.content_unique_name EQ "/">
				(Home Page)
			</cfif>
			</span>
		</cfif> --->
		<!--- <cfif form.searchtext NEQ "">
			<cfscript>
			cT="";
			if(row.content_summary neq ''){
				cT=rereplacenocase(row.content_summary,"<.*?>", " ", 'ALL');
			}else if(row.content_text NEQ ""){
				cT=rereplacenocase(row.content_text,"<.*?>", " ", 'ALL');
			}
			pos=findnocase(arrSearch[1], cT);
			ofs=200;
			if(pos EQ 0){
				pos=1;
			}
			// find the phrase and go back and forwards.  
			prev=pos-ofs;
			next=pos+ofs;
			// find the previous space
			for(i=1;i<100;i++){
				prev--;
				if(prev LT 1){
					prev=1;
					break;
				}
				if(mid(cT,prev,1) EQ ' '){
					break;
				}
			}
			// find the next space
			for(i=1;i<100;i++){
				next++;
				if(next GT len(cT)){
					next=max(1,len(cT));
					break;
				}
				if(mid(cT,next,1) EQ ' '){
					break;
				}
			}
			cT=mid(cT, prev, next-prev);
			prevDots=false;
			if(prev NEQ 1){
				prevDots=true;
			}
			if(next NEQ len(cT)){
				cT=cT&" ...";
			}
			if(prevDots){
				cT="..."&cT;
			}
			</cfscript>
			<br />
			<span style="line-height:10px; font-size:10px; color:##666666;font-style:italic; display:block; min-width:300px;">#cT#</span>
		</cfif> --->

</td>
<!--- <td>
	<cfif row.content_for_sale EQ "1">Active
	<cfelseif row.content_for_sale EQ "2"><strong>Inactive</strong>
	<cfelseif row.content_for_sale EQ '3'><strong>SOLD</strong>
	<cfelseif row.content_for_sale EQ '4'><strong>UNDER CONTRACT</strong>
	</cfif>
</td> --->

<td>#application.zcore.functions.zTimeSinceDate(row.content_updated_datetime)#</td>
<td style="vertical-align:top; " class="z-manager-admin">

	<cfif form.mode EQ "sorting">
		<cfif request.parentChildSorting EQ 0 and application.zcore.functions.zso(form, 'searchtext') EQ '' and request.sortComSQL EQ ''> 
			<div class="z-manager-button-container">
				#variables.queueSortCom.getAjaxHandleButton(row.content_id)#
			</div>
			
		</cfif>
	</cfif>
	<cfif row.content_for_sale EQ 2>
		<div class="z-manager-button-container">
			<a title="Inactive"><i class="fa fa-times-circle" aria-hidden="true" style="color:##900;"></i></a>
		</div>
	<cfelse> 
		<div class="z-manager-button-container">
			<a title="<cfif row.content_for_sale EQ '3'>Sold<cfelseif row.content_for_sale EQ '4'>Under Contract<cfelse>Active</cfif>"><i class="fa fa-check-circle" aria-hidden="true" style="color:##090;"></i></a>
		</div>
	</cfif>
	<div class="z-manager-button-container"> 
		<a href="<cfif row.content_url_only NEQ ''>#row.content_url_only#<cfelse><cfif row.content_unique_name NEQ ''>#row.content_unique_name#<cfelse>/#application.zcore.functions.zURLEncode(row.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#row.content_id#.html</cfif></cfif><cfif row.content_for_sale EQ 2>?preview=1</cfif>" class="z-manager-view" target="_blank" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a> 
	</div>
	<cfscript>
	deleteDisabled=true;
	if(row.content_locked EQ 0 or application.zcore.user.checkSiteAccess()){
		if(row.children EQ 0){
			deleteDisabled=false;
		}
	}
	</cfscript>
	<div class="z-manager-button-container">

		<a href="##" class="z-manager-edit" id="z-manager-edit#row.content_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
		<div class="z-manager-edit-menu">
			<a href="/z/content/admin/content-admin/edit?content_id=#row.content_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;modalpopforced=1&amp;mode=#form.mode#" onclick="zTableRecordEdit(this);  return false;">Edit Page</a>
			<cfif (structkeyexists(form, 'qcontentp') EQ false or qcontentp.content_featured_listing_parent_page NEQ 1)>
				<a href="/z/content/admin/content-admin/add?content_parent_id=#row.content_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">New Child Page</a>
			</cfif>
			<cfif form.mode EQ "sorting" and row.children NEQ 0>
				<a href="/z/content/admin/content-admin/index?content_parent_id=#row.content_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Manage #row.children# Sub-Pages</a>
			</cfif>
			<cfif request.zos.isTestServer>
				<cfscript>
				ts=structnew();
				ts.saveIdURL="/z/content/admin/content-admin/saveGridId?content_id=#row.content_id#";
				ts.grid_id=row.content_grid_id;
				application.zcore.grid.getGridForm(ts); 
				</cfscript> 
			</cfif>
			<cfif application.zcore.app.siteHasApp("listing") and row.content_search_mls EQ 1>
				<a href="#request.zos.globals.domain##application.zcore.functions.zURLAppend(request.zos.listing.functions.getSearchFormLink(), "zsearch_cid=#row.content_id#")#" target="_blank">Search Results Only</a>
			</cfif>
			<cfif application.zcore.app.siteHasApp("listing")>
				<a href="<cfif row.content_url_only NEQ ''>#row.content_url_only#<cfelse><cfif row.content_unique_name NEQ ''>#row.content_unique_name#<cfelse>/#application.zcore.functions.zURLEncode(row.content_name,'-')#-#application.zcore.app.getAppData("content").optionStruct.content_config_url_article_id#-#row.content_id#.html</cfif></cfif>?<cfif row.content_for_sale EQ 2>preview=1&amp;</cfif>hidemls=1" target="_blank">View (w/o MLS)</a>
			</cfif> 

			<cfif application.zcore.user.checkServerAccess()>
				<cfif row.content_hide_edit EQ 1>
					<a href="/z/content/admin/content-admin/changeEdit?show=0&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#&amp;content_id=#row.content_id#">Show This Page</a>
				<cfelse>
					<a href="/z/content/admin/content-admin/changeEdit?show=1&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#&amp;content_id=#row.content_id#">Hide This Page</a>
				</cfif> 
			</cfif>
			<cfif deleteDisabled>
				<a href="##">Delete Disabled</a>
			</cfif>

		</div>
	</div> 
	<cfif form.mode EQ "sorting" and row.children NEQ 0>
		<div class="z-manager-button-container">
			<a class="z-manager-edit" title="Manage #row.children# pages connected to this page" href="/z/content/admin/content-admin/index?content_parent_id=#row.content_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#"><i class="fa fa-sitemap" aria-hidden="true"></i></a>
		</div>
	</cfif>

	<cfif not deleteDisabled>
		<div class="z-manager-button-container">
			<a href="##" class="z-manager-delete" title="Delete" onclick="zDeleteTableRecordRow(this, '/z/content/admin/content-admin/delete?content_id=#row.content_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;returnJson=1&amp;confirm=1'); return false;"><i class="fa fa-trash" aria-hidden="true"></i></a>
		</div>
	</cfif>
</td>
</cffunction>

<cffunction name="getContentSiteMapOrder" localmode="modern" access="public">
	<cfargument name="arrOrder" type="array" required="yes">
	<cfargument name="parentId" type="string" required="yes"> 
	<cfargument name="contentLookupStruct" type="struct" required="yes">
	<cfscript>
	arrChildren=arguments.contentLookupStruct[arguments.parentId];
/*
	if(arguments.parentId NEQ 0){
writedump(arrChildren);abort;
		//writedump(arguments);abort;
	}*/
	for(row in arrChildren){
		arrayAppend(arguments.arrOrder, row);
		//arrayAppend(arguments.arrOrder, row.content_id&" | "&row.content_sort&" | "&row.content_name);
		if(structkeyexists(arguments.contentLookupStruct, row.content_id)){
			getContentSiteMapOrder(arguments.arrOrder, row.content_id, arguments.contentLookupStruct);
		}
	}
	</cfscript>
</cffunction>

<cffunction name="changeEdit" localmode="modern" roles="serveradministrator" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	form.show=application.zcore.functions.zso(form, 'show', true, 0);
	form.content_id=application.zcore.functions.zso(form, 'content_id', true, 0);
	db.sql="update #db.table("content", request.zos.zcoreDatasource)# 
	SET content_hide_edit=#db.param(form.show)# 
	WHERE content_id =#db.param(form.content_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	content_deleted=#db.param(0)#";
	db.execute("qUpdate");
	
	link=request.zos.cgi.HTTP_REFERER;
	application.zcore.functions.zredirect(link);
	
	</cfscript>
</cffunction>

<cffunction name="saveGridId" access="remote" localmode="modern">
	<cfscript>
	db=request.zos.queryObject;
	form.content_id=application.zcore.functions.zso(form, 'content_id');

	// verify user has access to id
	if(not application.zcore.adminSecurityFilter.checkFeatureAccess("Pages")){
		return;
	}
	db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("grid", request.zos.zcoreDatasource)# ON 
	grid.site_id = content.site_id and 
	grid.grid_deleted=#db.param(0)#  
	WHERE content_id = #db.param(form.content_id)# and 
	content_deleted=#db.param(0)# and 
	content.site_id = #db.param(request.zos.globals.id)# ";
	qContent=db.execute("qContent");
	if(qContent.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid id", form, true);
		application.zcore.functions.zRedirect("/z/content/admin/content-admin/index?zsid=#request.zsid#");
	} 
	if(qContent.grid_id EQ "" or qContent.grid_id EQ 0){

		// get new grid_id
		rs=application.zcore.grid.getGridById(0, true);

		// set the grid_id in the parent record
		db.sql="UPDATE #db.table("content", request.zos.zcoreDatasource)# SET 
		content_grid_id=#db.param(rs.qGrid.grid_id)#, 
		content_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE 
		content_id=#db.param(form.content_id)# and 
		content_deleted=#db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		if(not db.execute("qUpdate")){
			throw("Failed to save grid id");
		}

		// redirect to editor
		application.zcore.grid.redirectToEditor(rs.qGrid.grid_id);
	}else{

		// redirect to editor
		application.zcore.grid.redirectToEditor(qContent.grid_id);
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>