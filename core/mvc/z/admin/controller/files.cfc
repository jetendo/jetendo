<cfcomponent>
<cfoutput>  
<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	if(not structkeyexists(request.zos, 'fileImage')){
		request.zos.fileImage={};
	}
	request.zos.fileImage.absDir=application.zcore.functions.zso(request.zos.fileImage, 'absDir', false, application.zcore.functions.zvar('privatehomedir')&'zupload/user/'); 
	request.zos.fileImage.siteRootDir=application.zcore.functions.zso(request.zos.fileImage, 'siteRootDir', false, '/zupload/user');
	request.zos.fileImage.forceRootFolder=application.zcore.functions.zso(request.zos.fileImage, 'forceRootFolder', false, "");
	request.zos.fileImage.editDisabled=application.zcore.functions.zso(request.zos.fileImage, 'editDisabled', false, false);
	request.zos.fileImage.deleteDisabled=application.zcore.functions.zso(request.zos.fileImage, 'deleteDisabled', false, false);
	request.zos.fileImage.addDisabled=application.zcore.functions.zso(request.zos.fileImage, 'addDisabled', false, false);
	request.zos.fileImage.enableDownload=application.zcore.functions.zso(request.zos.fileImage, 'enableDownload', false, true);
	request.zos.fileImage.hideTitle=application.zcore.functions.zso(request.zos.fileImage, 'hideTitle', false, false);
	if(directoryexists(request.zos.fileImage.absDir) EQ false){
		application.zcore.functions.zCreateDirectory(request.zos.fileImage.absDir);
	}

	if(not structkeyexists(variables, 'disableManagerSecurity')){
		application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images");	
	}

	application.zcore.template.appendTag("meta",'<style type="text/css">
	/* <![CDATA[ */
		body, .fi-gallery-table{ background-color:##FFFFFF; color:##000000; }
	.fi-gallery-table a:link { color:##336699; }
	.fi-gallery-table a:visited { color:##225588; }
	.fi-gallery-table a:hover { color:##FF0000;} /* ]]> */
	</style>');
	  
 
	if(request.zos.isDeveloper and structkeyexists(form, 'reloadCache')){
		request.zos.siteVirtualFileCom.reloadCache(application.siteStruct[request.zos.globals.id]);
	}
	form.virtual_folder_id=application.zcore.functions.zso(form, 'virtual_folder_id', true);
	form.virtual_file_id=application.zcore.functions.zso(form, 'virtual_file_id', true);
	variables.currentFile={};
	// force current file or folder to be loaded
	if(form.virtual_file_id NEQ 0){
		rs=request.zos.siteVirtualFileCom.getFileById(form.virtual_file_id);
		if(not rs.success){
			application.zcore.status.setStatus(request.zsid, "You don't have access to that file or it no longer exists.", form, true);
			application.zcore.functions.zRedirect("/z/admin/files/index?zsid=#request.zsid#");
		}
		variables.currentFile=rs.data;
		form.virtual_folder_id=rs.data.virtual_file_folder_id;
	}
	if(form.virtual_folder_id NEQ 0){
		rs=request.zos.siteVirtualFileCom.getFolderById(form.virtual_folder_id);
		if(not rs.success){
			application.zcore.status.setStatus(request.zsid, "You don't have access to that folder or it no longer exists.", form, true);
			application.zcore.functions.zRedirect("/z/admin/files/index?zsid=#request.zsid#");
		}
		variables.currentFolder=rs.data;
		variables.currentDir=request.zos.globals.privateHomeDir&"zupload/user/"&variables.currentFolder.virtual_folder_path;
		variables.currentPath=variables.currentFolder.virtual_folder_path;
	}else{
		variables.currentDir=request.zos.globals.privateHomeDir&"zupload/user/";
		variables.currentPath="";
	}
	

	form.fileGalleryMode=application.zcore.functions.zso(form, 'fileGalleryMode',false,false);
	form.galleryMode=application.zcore.functions.zso(form, 'galleryMode',false,false);
	if(form.fileGalleryMode EQ false and form.galleryMode EQ false){
		application.zcore.template.setTag("title","Files &amp; Images Manager");
	}  
	// default image upload resize sizes can be overriden for each site in zcoreCustomFunctions onRequestStart
	if(structkeyexists(request,'imageSizes') EQ false){
		request.imageSizes=ArrayNew(1);
		ts=StructNew();
		ts.label="Small";
		ts.value="120x200";
		ArrayAppend(request.imageSizes, ts);
		ts=StructNew();
		ts.label="Medium";
		ts.value="250x400";
		ArrayAppend(request.imageSizes, ts);
		ts=StructNew();
		ts.label="Large";
		if(application.zcore.functions.zso(request.zos.globals, 'maximagewidth',true) NEQ 0){
			ts.value="#request.zos.globals.maximagewidth#x2000";
		}else{
			ts.value="760x2000";
		}
		ts.default=true;
		ArrayAppend(request.imageSizes, ts);
		ts=StructNew();
		ts.label="Keep Original Size";
		ts.value="5000x5000";
		ArrayAppend(request.imageSizes, ts);
	}
	if(left(request.zos.originalURL, 15) EQ "/z/admin/files/"){
		if(not form.fileGalleryMode and form.galleryMode EQ false and request.zos.fileImage.hideTitle EQ false){
			writeoutput('<h2>Files &amp; Images</h2>');
		}
	}
	if(form.fileGalleryMode or form.galleryMode or form.method EQ "fileGalleryViewFile" or form.method EQ "fileGalleryAddFolder" or form.method EQ "fileGalleryAdd" or form.method EQ "galleryAdd" or form.method EQ "galleryAddFolder" or form.method EQ "galleryAddFile"){
		request.zPageDebugDisabled=true;
	}  

	if(form.fileGalleryMode){
		form.curListMethod="fileGallery";
	}else if(form.galleryMode EQ false){
		form.curListMethod="index";
	}else{
		form.curListMethod="gallery";
	} 

	rs=request.zos.siteVirtualFileCom.getParentFolders(form.virtual_folder_id);
	if(not rs.success){
		throw(rs.errorMessage);
	}
	arrLinks=[];
	if(form.virtual_folder_id EQ 0 and (form.method EQ "index" or form.method EQ "gallery" or form.method EQ "fileGallery")){
	    ArrayAppend(arrLinks, 'Root /');
	}else{
	    ArrayAppend(arrLinks, '<a href="/z/admin/files/#form.curListMethod#">Root</a> /');
	}
	for(i=arrayLen(rs.arrFolder);i>0;i--){
		row=rs.arrFolder[i];
		arrayAppend(arrLinks, '<a href="/z/admin/files/#form.curListMethod#?virtual_folder_id=#row.virtual_folder_id#">#row.virtual_folder_name#</a> / ');
	}
	if(form.virtual_folder_id NEQ 0){
		arrayAppend(arrLinks, variables.currentFolder.virtual_folder_name);
	}
	arrRoot=listToArray(request.zos.fileImage.forceRootFolder, "/");
	for(i=2;i<=arraylen(arrRoot);i++){
		arrayDeleteAt(arrLinks,1);
	}
	
	if(left(request.zos.originalURL, 15) EQ "/z/admin/files/"){
		writeoutput('<div class="z-float" style="border-bottom:1px solid ##CCC; margin-bottom:5px; border-spacing:0px; padding-bottom:5px;">');
		writeoutput(ArrayToList(arrLinks,' '));
		writeoutput('</div>'); 
	}
	</cfscript>
</cffunction>

<cffunction name="fileGallery" localmode="modern" access="remote" roles="member">
	<cfscript> 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images");	
	form.fileGalleryMode=true; 
	request.zos.fileImage.absDir=application.zcore.functions.zvar('privatehomedir')&'zupload/user/'; 
	request.zos.fileImage.siteRootDir='/zupload/user';
	Request.zOS.debuggerEnabled=false;  
	
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
	 
	this.index(); 

	application.zcore.template.setTemplate('zcorerootmapping.templates.blank',true,true);
	</cfscript>
	<script type="text/javascript">
	if(window.parent.Sizer){
		window.parent.Sizer.ResizeDialog(650,480);
	}
	</script>
</cffunction>

<cffunction name="gallery" localmode="modern" access="remote" roles="member">
<cfscript> 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images");	
	form.galleryMode=true; 
	Request.zOS.debuggerEnabled=false;
	request.zos.fileImage.absDir=application.zcore.functions.zvar('privatehomedir')&'zupload/user/'; 
	request.zos.fileImage.siteRootDir='/zupload/user';
	Request.zOS.debuggerEnabled=false;
	request.imageSizes=ArrayNew(1);
	ts=StructNew();
	ts.label="Small";
	ts.value="120x200";
	ArrayAppend(request.imageSizes, ts);
	ts=StructNew();
	ts.label="Medium";
	ts.value="250x400";
	ArrayAppend(request.imageSizes, ts);
	ts=StructNew();
	ts.label="Large";
	if(application.zcore.functions.zso(request.zos.globals, 'maximagewidth',true) NEQ 0){
		ts.value="#request.zos.globals.maximagewidth#x2000";
	}else{
		ts.value="760x2000";
	}
	ts.default=true;
	ArrayAppend(request.imageSizes, ts);
	ts=StructNew();
	ts.label="Keep Original Size";
	ts.value="10000x10000";
	ArrayAppend(request.imageSizes, ts);
	
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
	
	if(form.method EQ "gallery"){
		this.index();
	}
	application.zcore.template.setTemplate('zcorerootmapping.templates.blank',true,true);
	</cfscript>
	<script type="text/javascript">
	if(window.parent.Sizer){
		window.parent.Sizer.ResizeDialog(650,480);
	}
	</script>
</cffunction>

<cffunction name="sharedDocuments" localmode="modern" access="remote" roles="member">
	<cfscript>
	if(application.zcore.app.siteHasApp("content")){
	    ts=structnew();
	    ts.content_unique_name="/z/admin/files/sharedDocuments";
	    r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
	}else{
		r1=false;
	}
	if(r1 EQ false){
	    application.zcore.template.setTag("title","Shared Documents");
	    application.zcore.template.setTag("pagetitle","Shared Documents");
		writeoutput('<p>This files are provided for your convenience.</p>');
	}
	request.zos.fileImage.forceRootFolder="/Shared Documents";
	request.zos.fileImage.editDisabled=true;
	request.zos.fileImage.deleteDisabled=true;
	request.zos.fileImage.enableDownload=true;
	request.zos.fileImage.addDisabled=true;
	index();
</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images", true);
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>  
		rs=request.zos.siteVirtualFileCom.deleteFile(form.virtual_file_id);
		if(not rs.success){
			application.zcore.status.setStatus(request.zsid, "Failed to delete file: "&rs.errorMessage, form, true);
			application.zcore.functions.zRedirect("/z/admin/files/index?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#");
		} 
		application.zcore.status.setStatus(request.zsid,"File Deleted Successfully");
		application.zcore.functions.zRedirect('/z/admin/files/index?zsid=#request.zsid#&virtual_folder_id=#form.virtual_folder_id#');
		</cfscript>
	<cfelse>
		<div style="font-size:14px; text-align:center; ">Are you sure you want to delete this file?
			<br /><br />
			#variables.currentFile.virtual_file_path#	
			<br /><br />
			<a href="/z/admin/files/delete?confirm=1&amp;virtual_folder_id=#form.virtual_folder_id#&amp;virtual_file_id=#form.virtual_file_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/admin/files/index?virtual_folder_id=#form.virtual_folder_id#">No</a>
		</div>
	</cfif>
</cffunction>

<cffunction name="deleteFolder" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images", true);
    /*
    if(request.zos.siteVirtualFileCom.folderHasChildren(form.virtual_folder_id)){
		application.zcore.status.setStatus(request.zsid,"This directory has files or folders in it and cannot be deleted until they are removed invidually.");
		application.zcore.functions.zRedirect('/z/admin/files/index?zsid=#request.zsid#&virtual_folder_id=#form.virtual_folder_id#');
    }*/
	</cfscript>
    <cfif structkeyexists(form, 'confirm')>
    	<cfscript>
		request.zos.siteVirtualFileCom.deleteFolder(form.virtual_folder_id); 
		application.zcore.status.setStatus(request.zsid,"Directory Deleted Successfully");
		application.zcore.functions.zRedirect('/z/admin/files/index?zsid=#request.zsid#&virtual_folder_id=#variables.currentFolder.virtual_folder_parent_id#');
		</cfscript>
    <cfelse>
		<div style="font-size:14px; text-align:center; ">Are you sure you want to delete this directory?
		<br /><br />
		#htmleditformat(variables.currentFolder.virtual_folder_path)#	
		<cfif request.zos.siteVirtualFileCom.folderHasChildren(form.virtual_folder_id)>
			<br><br><strong>WARNING: This folder has files/folders in it, and they will also be permanently deleted.</strong>
		</cfif>
		<br /><br />
		<a href="/z/admin/files/deleteFolder?confirm=1&amp;virtual_folder_id=#form.virtual_folder_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/admin/files/index?virtual_folder_id=#variables.currentFolder.virtual_folder_parent_id#">No</a>
		</div> 
    </cfif> 
</cffunction>

<cffunction name="fileGalleryInsertFile" localmode="modern" access="remote" roles="member">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="insertFile" localmode="modern" access="remote" roles="member">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="updateFile" localmode="modern" access="remote" roles="member">
	<cfscript>
	update();  
	</cfscript>
</cffunction>

<cffunction name="galleryInsert" localmode="modern" access="remote" roles="member">
<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
<cfscript>
	
	var photoResize=0;
	var overwrite=0;
	var fileName=0;
	var t=0;
	var tPath=0;
	var qDir=0;
	var arrE=0;
	var fExt=0;
	var n2=0;
	var oldFilePath=0;
	var image_file=0;
	var arrList=0;
	init();
	if(request.zos.isTestServer){
		setting requesttimeout="5";
	}else{
		setting requesttimeout="300";
	}
    application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images", true); 
	if(form.method EQ "update"){
		successMethod="edit";
		returnMethod="edit";
	}else if(form.method EQ "fileGalleryInsertFile"){
		successMethod="fileGallery";
		returnMethod="fileGalleryAdd";
	}else if(form.method EQ "insertFile"){
		successMethod="index";
		returnMethod="addFile";
	}else if(form.method EQ "updateFile"){
		successMethod="index";
		returnMethod="editFile"; 
	}else if(form.method EQ "galleryInsert"){
		successMethod="gallery";
		returnMethod="galleryAdd";
	}else{
		successMethod="index";
		returnMethod="add";
	}
	// TODO - need to allow saving file without uploading a file
	if(structkeyexists(form, 'image_file') EQ false or trim(form.image_file) EQ ''){
		application.zcore.status.setStatus(request.zsid,"No File was uploaded.");
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/admin/files/#returnMethod#?zsid=#request.zsid#&virtual_folder_id=#form.virtual_folder_id#&virtual_file_id=#form.virtual_file_id#');	
		}else{
			application.zcore.functions.zRedirect('/z/admin/files/edit?zsid=#request.zsid#&virtual_folder_id=#form.virtual_folder_id#&virtual_file_id=#form.virtual_file_id#');
		}
	}
	form.image_size_width=application.zcore.functions.zso(form, 'image_size_width', true, 0);
	form.image_size_height=application.zcore.functions.zso(form, 'image_size_height', true, 0);
	if(form.method EQ "insert" or form.method EQ "galleryInsert"){
		if(isNumeric(form.image_size_width) and isNumeric(form.image_size_height)){
			form.image_size_width=max(10,min(5000,form.image_size_width));
			form.image_size_height=max(10,min(5000,form.image_size_height));
		}else{
			application.zcore.status.setStatus(request.zsid,"Invalid image size");
			application.zcore.functions.zRedirect('/z/admin/files/#successMethod#?zsid=#request.zsid#');
		}
		if(form.image_size_width EQ 5000 and form.image_size_height EQ 5000){
			form.image_size_width=0;
			form.image_size_height=0;
		}
	}
	/* TODO: consider implementing "overwrite" feature again
	if(application.zcore.functions.zso(form, 'image_overwrite') EQ 1){
		overwrite=true;
	}else{
		overwrite=false;
	}
	*/
	form.virtual_file_secure=application.zcore.functions.zso(form, 'virtual_file_secure', true, 0);
	form.virtual_file_user_group_list=application.zcore.functions.zso(form, 'virtual_file_user_group_list');

	if(form.method EQ "update" or form.method EQ "updateFile"){
		// restrict upload to just one file
		ts={
			update:true,
			virtual_file_id:form.virtual_file_id,
			field:'image_file',
			enableUnzip:false, 
			path:getDirectoryFromPath(variables.currentFile.virtual_file_path),
			secure:form.virtual_file_secure, // set to 1 to require login
			user_group_list:form.virtual_file_user_group_list, // comma separated user_group_id
			imageWidth:form.image_size_width, // will resize image and preserve ratio if not zero
			imageHeight:form.image_size_height // will resize image and preserve ratio if not zero
		}
		rs=request.zos.siteVirtualFileCom.uploadFiles(ts);

	}else{
		ts={
			update:false,
			field:'image_file',
			enableUnzip:true, // Set to true to auto-unzip and delete the zip.  Only safe files in the zip will be uploaded to the path specified.
			path:variables.currentPath,
			secure:form.virtual_file_secure, // set to 1 to require login
			user_group_list:form.virtual_file_user_group_list, // comma separated user_group_id
			imageWidth:form.image_size_width, // will resize image and preserve ratio if not zero
			imageHeight:form.image_size_height // will resize image and preserve ratio if not zero
		}
		if(form.method EQ "insertFile"){
			ts.enableUnzip=false;
		}
		rs=request.zos.siteVirtualFileCom.uploadFiles(ts);
	}
	if(rs.success EQ false){
		throw("Failed to create file");
	}
	count=arrayLen(rs.arrFile);
	if(arrayLen(rs.arrError)){
		for(message in rs.arrError){
			application.zcore.status.setStatus(request.zsid, message);
		}
	}

	application.zcore.status.setStatus(request.zsid,count&" files saved");
	application.zcore.functions.zRedirect('/z/admin/files/#successMethod#?zsid=#request.zsid#&virtual_folder_id=#form.virtual_folder_id#&virtual_file_id=#form.virtual_file_id#');
	</cfscript>	
</cffunction>



<cffunction name="getVirtualFileCom" localmode="modern" access="public">
	<cfscript> 
	init();
	return request.zos.siteVirtualFileCom;
	</cfscript>
</cffunction>

<cffunction name="updateFolder" localmode="modern" access="remote" roles="member">
	<cfscript> 
	this.insertFolder();
	</cfscript>
</cffunction>

<cffunction name="fileGalleryInsertFolder" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.insertFolder();
	</cfscript>
</cffunction>

<cffunction name="galleryInsertFolder" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.insertFolder();
	</cfscript>
</cffunction>

<cffunction name="insertFolder" localmode="modern" access="remote" roles="member">
	<cfscript> 
	init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Files & Images", true);
	try{
		newdir=application.zcore.functions.zDirectoryStringFormat(form.folder_name);
	}catch(Any e){
		newdir="";
	}
	if(structkeyexists(form, 'folder_name') EQ false or newdir EQ ""){
		application.zcore.status.setStatus(request.zsid,"Valid folder name required.",false,true);
		if(form.method EQ 'insertFolder'){
			application.zcore.functions.zRedirect('/z/admin/files/addFolder?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
		}else if(form.method EQ 'galleryInsertFolder'){ 
			application.zcore.functions.zRedirect('/z/admin/files/galleryAddFolder?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
		}else if(form.method EQ 'fileGalleryInsertFolder'){
			application.zcore.functions.zRedirect('/z/admin/files/fileGalleryAddFolder?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
		}else if(form.method EQ 'updateFolder'){
			application.zcore.functions.zRedirect('/z/admin/files/editFolder?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/admin/files/index?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
		}
	}
	if(form.method EQ 'insertFolder' or form.method EQ 'galleryInsertFolder' or form.method EQ 'fileGalleryInsertFolder'){
		ts={
			data:{
				virtual_folder_name:newdir,
				virtual_folder_secure:0,
				virtual_folder_user_group_list:""
			}
		}
		if(form.virtual_folder_id EQ 0){
			ts.data.virtual_folder_path=newdir;
		}else{
			ts.data.virtual_folder_path=variables.currentFolder.virtual_folder_path&"/"&newdir;
		}
		rs=request.zos.siteVirtualFileCom.createFolder(ts);
		if(rs.success EQ false){ 
			application.zcore.status.setStatus(request.zsid, rs.errorMessage,false,true);
			if(form.method EQ 'insertFolder'){
				application.zcore.functions.zRedirect('/z/admin/files/addFolder?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
			}else if(form.method EQ 'galleryInsertFolder'){ 
				application.zcore.functions.zRedirect('/z/admin/files/galleryAddFolder?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
			}else if(form.method EQ 'fileGalleryInsertFolder'){
				application.zcore.functions.zRedirect('/z/admin/files/fileGalleryAddFolder?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
			}else if(form.method EQ 'updateFolder'){
				application.zcore.functions.zRedirect('/z/admin/files/editFolder?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
			}else{
				application.zcore.functions.zRedirect('/z/admin/files/index?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
			}
		}
		form.virtual_folder_id=rs.virtual_folder_id;
	}else{
		path=getDirectoryFromPath(variables.currentFolder.virtual_folder_path);
		if(path EQ "/"){
			path=newdir;
		}else if(right(path, 1) EQ "/"){
			path&=newdir;
		} 
		ts={
			data:{
				virtual_folder_id:form.virtual_folder_id,
				virtual_folder_name:newdir,
				virtual_folder_path:path,
				virtual_folder_secure:0,
				virtual_folder_user_group_list:""
			}
		};
		rs=request.zos.siteVirtualFileCom.updateFolder(ts);
		if(not rs.success){
			application.zcore.status.setStatus(request.zsid, rs.errorMessage,false,true);
			if(form.method EQ 'updateFolder'){
				application.zcore.functions.zRedirect('/z/admin/files/editFolder?virtual_folder_id=#form.virtual_folder_id#&zsid=#request.zsid#');
			}
		} 
	}
	if(form.method EQ 'insertFolder' or form.method EQ 'galleryInsertFolder' or form.method EQ 'fileGalleryInsertFolder'){
		application.zcore.status.setStatus(request.zsid,"Folder Created Successfully");
	}else{
		application.zcore.status.setStatus(request.zsid,"Folder Updated Successfully");
	}
	if(form.method EQ 'fileGalleryInsertFolder'){
		application.zcore.functions.zRedirect('/z/admin/files/fileGallery?zsid=#request.zsid#&virtual_folder_id=#form.virtual_folder_id#');
	}else if(form.method EQ 'galleryInsertFolder'){
		application.zcore.functions.zRedirect('/z/admin/files/gallery?zsid=#request.zsid#&virtual_folder_id=#form.virtual_folder_id#');
	}else{
		application.zcore.functions.zRedirect('/z/admin/files/index?zsid=#request.zsid#&virtual_folder_id=#form.virtual_folder_id#');
	}
	</cfscript>
</cffunction>

<cffunction name="galleryAdd" localmode="modern" access="remote" roles="member">
	<cfscript>
	edit();
	application.zcore.template.setTemplate("zcorerootmapping.templates.blank", true, true);
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript> 
	currentMethod=form.method;
	application.zcore.functions.zSetPageHelpId("2.5.2");
	form.image_size_width=request.zos.globals.maxImageWidth;
	form.image_size_height=5000;
	init();

	if(currentMethod EQ "edit" and (not structkeyexists(variables, 'currentFile') or structcount(variables.currentFile) EQ 0)){
		application.zcore.status.setStatus(request.zsid, "Invalid request", form, true);
		application.zcore.functions.zRedirect("/z/admin/files/index?zsid=#request.zsid#");
	}
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<cfif currentMethod EQ 'edit'>
	    <cfscript>
		viewLink=request.zos.siteVirtualFileCom.getViewLink(variables.currentFile);
		downloadLink=request.zos.siteVirtualFileCom.getDownloadLink(variables.currentFile);
		db=request.zos.queryObject;
		db.sql="SELECT * FROM #db.table("virtual_file", request.zos.zcoreDatasource)# WHERE 
		virtual_file_id = #db.param(form.virtual_file_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		virtual_file_deleted=#db.param(0)# ";
		qFile=db.execute("qFile");
		if(qFile.recordcount EQ 0){
			application.zcore.functions.z404("Invalid file id");
		}
		</cfscript>  
	    <h2>Current Image: #qFile.virtual_file_path#</h2>
		<img src="#viewLink#" alt="Image" style="max-width:200px; max-height:200px;" /><br />
		Actual dimensions: #variables.currentFile.virtual_file_image_width#x#variables.currentFile.virtual_file_image_height# | <a href="#viewLink#" target="_blank">View Full Size Image</a><br /><br /> 
	    <h3>Embed image in a web site or email:</h3><br />
	    <textarea style="width:100%; height:40px; font-size:14px;" onclick="this.select();">#application.zcore.functions.zvar('domain')##viewLink#</textarea><br />
	    <br />
	    
	    <h3>URL to force image to download:</h3>
	    <textarea style="width:100%; height:40px; font-size:14px;" onclick="this.select();">#request.zos.currentHostName##downloadLink#</textarea><br />
	    <br />
	<cfelse>
		<h2>Upload Image</h2> 
    </cfif>

	<div id="imageForm2" style="display:none; font-size:18px; line-height:24px;">Uploading, please wait...</div>
	<div id="imageForm">

	<form class="zFormCheckDirty" action="/z/admin/files/<cfif currentMethod EQ 'galleryAdd'>galleryInsert<cfelseif currentMethod EQ 'add'>insert<cfelse>update</cfif>?virtual_folder_id=#form.virtual_folder_id#&amp;virtual_file_id=#form.virtual_file_id#" method="post" enctype="multipart/form-data" onsubmit="return submitImageForm();">
	<cfif currentMethod EQ 'edit'>
		<h3>Replace Image</h3>
		All references to it on the site will be updated to the new image.<br />
		If you want to add an image instead, <a href="/z/admin/files/add?virtual_folder_id=#form.virtual_folder_id#">click here</a><br /> 
    </cfif>  
	<p>Select a .jpg, .png or .gif image<cfif currentMethod NEQ 'edit'> or a .zip archive with .jpg, .png and/or .gif files inside</cfif>.</p>

	<p>Select File: <input type="file" name="image_file"></p>


	Resize Image:  
	<script type="text/javascript">
	/* <![CDATA[ */var arrWidth=new Array();
	var arrHeight=new Array();
	function setWH(n){	
	    w=document.getElementById("image_size_width");
	    h=document.getElementById("image_size_height");
	    w.value=arrWidth[n];
	    h.value=arrHeight[n];
	    fixValue(w);
	    fixValue(h);
	}
	function submitImageForm(){
	    var r=onSub();
	    if(r == false){
		return false;	
	    }else{
		var d1=document.getElementById("imageForm");
		var d2=document.getElementById("imageForm2");
		d1.style.display="none";
		d2.style.display="block";
		return true;
	    }
	}
	function fixValue(t){
	    t.value=parseInt(t.value);
	    if(t.value > 5000){
		t.value=5000;
	    }
	    if(t.value < 10){
		t.value="";
	    }
	    if(t.value=="NaN"){
		t.value="";
	    }
	}
	function onSub(){
	    w=document.getElementById("image_size_width");
	    h=document.getElementById("image_size_height");
	    fixValue(w);
	    fixValue(h);
	    if(w.value=="" || h.value==""){
		alert("Width and height are required.");
		return false;
	    }
	    return true;
	}
	<cfloop from="1" to="#ArrayLen(request.imageSizes)#" index="i">
	<cfscript>
	ts=request.imageSizes[i];
	arrS=listtoarray(ts.value,'x');
	</cfscript>
	arrWidth.push('#arrS[1]#');arrHeight.push('#arrS[2]#');
	</cfloop>
		/* ]]> */
	</script>
	<cfloop from="1" to="#ArrayLen(request.imageSizes)#" index="i">
	    <cfscript>
	    ts=request.imageSizes[i];
	    arrS=listtoarray(ts.value,'x');
	    </cfscript>
	    <input type="radio" name="image_size" onclick="setWH(#i-1#);" value="#i#" <cfif application.zcore.functions.zso(form, 'image_size', true) EQ i or (application.zcore.functions.zso(form, 'image_size', true) EQ '' and structkeyexists(ts,'default') and ts.default)>checked="checked"<cfset form.image_size_width=arrS[1]><cfset form.image_size_height=arrS[2]><cfelse><cfset width=false></cfif> style="background:none; border:none;"/> #ts.label# 
	</cfloop><br />
	<br />
	Pixel Size: Width: <input type="text" size="5" name="image_size_width" id="image_size_width"<!---  onkeyup="fixValue(this);" ---> value="#application.zcore.functions.zso(form, 'image_size_width')#"> Height: <input type="text" size="5" name="image_size_height" id="image_size_height"<!---  onkeyup="fixValue(this);" ---> value="#application.zcore.functions.zso(form, 'image_size_height')#"> (preserves ratio)
	<br />
	<br />
	<!--- <cfif currentMethod NEQ 'edit'>
		Overwrite Existing Files? <input type="radio" name="image_overwrite" value="1" <cfif application.zcore.functions.zso(form, 'image_overwrite') EQ 1>checked="checked"</cfif> style="border:none; background:none;" /> Yes <input type="radio" name="image_overwrite" value="0" <cfif application.zcore.functions.zso(form, 'image_overwrite') EQ 0 or application.zcore.functions.zso(form, 'image_overwrite') EQ ''>checked="checked"</cfif> style="border:none; background:none;" /> No 
		<br />
		<br />
	</cfif> --->
	<input type="submit" name="image_submit" value="Upload Image" class="z-manager-search-button" /> 
		<input type="button" name="cancel" value="Cancel" onclick="window.location.href ='/z/admin/files/<cfif form.method EQ "galleryAdd">gallery<cfelse>index</cfif>?virtual_folder_id=#form.virtual_folder_id#';" class="z-manager-search-button" />
	</form>
</cffunction>

<cffunction name="fileGalleryAdd" localmode="modern" access="remote" roles="member">
	<cfscript>
	addFile();
	application.zcore.template.setTemplate("zcorerootmapping.templates.blank", true, true);
	</cfscript>
</cffunction>

<cffunction name="addFile" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.zSetPageHelpId("2.5.1");
	currentMethod=form.method;
	init();
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h1>Upload File</h1>

	<form class="zFormCheckDirty" action="/z/admin/files/<cfif currentMethod EQ "fileGalleryAdd">fileGalleryInsertFile<cfelseif currentMethod EQ 'addFile'>insertFile</cfif>?virtual_folder_id=#form.virtual_folder_id#" method="post" enctype="multipart/form-data">

	Select file(s):
	<input type="file" name="image_file" multiple="multiple" />
	<br />
	<br />
	<!--- TODO: set user_group_id multiple select --->
	<input type="submit" name="image_submit" value="Upload File" class="z-manager-search-button" /> 
	<input type="button" name="cancel" value="Cancel" onclick="window.location.href ='/z/admin/files/<cfif currentMethod EQ "fileGalleryAdd">fileGallery<cfelse>index</cfif>?virtual_folder_id=#form.virtual_folder_id#';" class="z-manager-search-button" />
	</form>
</cffunction>

<cffunction name="fileGalleryViewFile" localmode="modern" access="remote" roles="member">
	<cfscript> 
	init();
	application.zcore.template.setTemplate('zcorerootmapping.templates.blank',true,true);
	form.fileGalleryMode=true; 
	Request.zOS.debuggerEnabled=false;
	application.zcore.functions.zSetPageHelpId("2.5.5"); 

	if(structcount(variables.currentFile) EQ 0){
		application.zcore.functions.z404("currentFile was missing from request.");
	}

	viewLink=request.zos.siteVirtualFileCom.getViewLink(variables.currentFile);
	downloadLink=request.zos.siteVirtualFileCom.getDownloadLink(variables.currentFile);
	</cfscript>
	<form class="zFormCheckDirty" action="" onsubmit=" insertFile(); return false;">
		<h3>File to Insert: #variables.currentFile.virtual_file_path#</h3>
		<input type="hidden" name="fileLink" id="fileLink" value="#htmleditformat("#request.zos.currentHostName##viewLink#")#">
		<p>Link Text: <input type="text" name="fileLabel" id="fileLabel" style="width:350px;" value="#htmleditformat("Download File (#variables.currentFile.virtual_file_name#)")#"></p>
		<input type="submit" name="submit1" value="Insert File Link" class="z-manager-search-button" /> 

		<input type="button" name="cancel" value="Cancel" class="z-manager-search-button" onclick="window.location.href ='/z/admin/files/fileGallery?virtual_folder_id=#form.virtual_folder_id#';" />
	</form>
	<script type="text/javascript">
	/* <![CDATA[ */
	if(!window.parent.zInsertGalleryFile){
	    alert('HTML Editor is missing');
	}
	function insertFile(){ 
		var fileLabel=$("##fileLabel").val();
		var fileLink=$("##fileLink").val();
		if(fileLabel.trim() == ""){
			alert("Link Text is required.");
			return false;
		}
	    var theHTML='<a href="'+fileLink+'" target="_blank">'+fileLabel+'</a>';
	    

		window.parent.zInsertGalleryFile(theHTML); 

	}
	/* ]]> */
	</script> 

</cffunction>
	

<cffunction name="editFile" localmode="modern" access="remote" roles="member">
	<cfscript> 
	init();
	application.zcore.functions.zSetPageHelpId("2.5.5");
	viewLink=request.zos.siteVirtualFileCom.getViewLink(variables.currentFile);
	downloadLink=request.zos.siteVirtualFileCom.getDownloadLink(variables.currentFile);

	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("virtual_file", request.zos.zcoreDatasource)# WHERE 
	virtual_file_id = #db.param(form.virtual_file_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
	virtual_file_deleted=#db.param(0)# ";
	qFile=db.execute("qFile");
	if(qFile.recordcount EQ 0){
		application.zcore.functions.z404("Invalid file id");
	}
	</cfscript> 
	<h2>#qFile.virtual_file_path#</h2>
	<h3>Embed document in a web site:</h3>
	<p><textarea style="width:100%; height:40px; font-size:14px;" onclick="this.select();">#request.zos.currentHostName##viewLink#</textarea></p>
	
	<h3>URL to force document to download:</h3>
	<p><textarea style="width:100%; height:40px; font-size:14px;" onclick="this.select();">#request.zos.currentHostName##downloadLink#</textarea></p>

	<p>Copy and Paste the above link into the URL field of the content manager to link to this file on any page of the site.</p>

	<h3>Replace File</h3>
	<p>All references to it on the site will be updated to the new file.</p>
	<form class="zFormCheckDirty" action="/z/admin/files/updateFile?virtual_folder_id=#form.virtual_folder_id#&amp;virtual_file_id=#form.virtual_file_id#" method="post" enctype="multipart/form-data"> 
		<cfif form.method EQ "editFile"> 
			<p>Select File: 
			<input type="file" name="image_file" /></p>
		<cfelse>
			<p>Select File(s): 
			<input type="file" name="image_file" multiple="multiple" /></p>
		</cfif>
 
		<p>
		<input type="submit" name="submit11" value="Save" style="padding:5px;" class="z-manager-search-button" /> 
		<input type="button" name="csubmit11" value="Cancel" class="z-manager-search-button" onclick="window.location.href='/z/admin/files/index?virtual_folder_id=#form.virtual_folder_id#';" style="padding:5px;" /> 
		</p>
	</form>
<!--- 
	<cfif right(form.f,3) EQ ".js" or right(form.f,4) EQ ".css" or right(form.f,4) EQ ".htm">
		<br />
		<cfscript>
		application.zcore.functions.zstatushandler(request.zsid, true);
		</cfscript>
		<cfif structkeyexists(form,'fifilecontents1')>
		<cfscript>
		application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&removechars(request.zos.fileImage.siteRootDir,1,1)&form.f, fifilecontents1);
		application.zcore.status.setStatus(request.zsid, "File updated.");
		application.zcore.functions.zRedirect("/z/admin/files/editFile?d="&urlencodedformat(form.d)&"&f="&urlencodedformat(form.f)&"&zsid=#request.zsid#");
		</cfscript>
		</cfif>
		<h2>Edit File Contents</h2>
		<cfscript>
		cc=application.zcore.functions.zreadfile(request.zos.globals.privatehomedir&removechars(request.zos.fileImage.siteRootDir,1,1)&form.f);
		</cfscript>
		<form class="zFormCheckDirty" action="/z/admin/files/editFile?virtual_folder_id=#form.virtual_folder_id#&amp;f=#urlencodedformat(form.f)#" method="post">
		<textarea name="fifilecontents1" cols="100" rows="10" style="width:100%; height:600px; " >#htmleditformat(cc)#</textarea><br />
		<br />
		<input type="submit" name="submit11" value="Save Changes" class="z-manager-search-button" style="padding:5px;" /> <input type="button" class="z-manager-search-button" name="csubmit11" value="Cancel" onclick="window.location.href='/z/admin/files/index';" style="padding:5px;" /> 
		</form>
	</cfif> --->
</cffunction>

<cffunction name="fileGalleryAddFolder" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.addFolder();
	application.zcore.template.setTemplate('zcorerootmapping.templates.blank',true,true);
	</cfscript>
</cffunction>

<cffunction name="galleryAddFolder" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.addFolder();
	application.zcore.template.setTemplate('zcorerootmapping.templates.blank',true,true);
	</cfscript>
</cffunction>

<cffunction name="editFolder" localmode="modern" access="remote" roles="member">
	<cfscript> 
	this.addFolder();
	</cfscript>
</cffunction>

<cffunction name="addFolder" localmode="modern" access="remote" roles="member">
<cfscript>
	var currentMethod=form.method;
	init();
	application.zcore.functions.zSetPageHelpId("2.5.3"); 
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h1><cfif currentMethod EQ 'editFolder'>Edit<cfelse>Create</cfif> Folder</h1>

	<form class="zFormCheckDirty" action="/z/admin/files/<cfif currentMethod EQ 'fileGalleryAddFolder'>fileGalleryInsertFolder<cfelseif currentMethod EQ 'galleryAddFolder'>galleryInsertFolder<cfelseif currentMethod EQ 'addFolder'>insertFolder<cfelse>updateFolder</cfif>?virtual_folder_id=#form.virtual_folder_id#" method="post" enctype="multipart/form-data">
	<cfif currentMethod EQ 'editFolder'>
	Current Folder Name: #htmleditformat(variables.currentFolder.virtual_folder_name)#<br /><br />
	</cfif>
	Type new name:
	<input type="text" name="folder_name" /> (Leave blank to keep it the same)
	<br /><br />   
	<!--- TODO: set user_group_id multiple select --->
	<input type="submit" name="image_submit" value="<cfif currentMethod EQ 'editFolder'>Update<cfelse>Create</cfif> Folder" class="z-manager-search-button" />
		<input type="button" name="cancel" value="Cancel" onclick="window.location.href ='/z/admin/files/<cfif currentMethod EQ 'fileGalleryAddFolder'>fileGallery<cfelseif currentMethod EQ 'galleryAddFolder'>gallery<cfelse>index</cfif>?virtual_folder_id=#form.virtual_folder_id#';" class="z-manager-search-button" />
	</form>
</cffunction>

<cffunction name="align" localmode="modern" access="remote" roles="member">
<cfscript>
	var output=0;
	var currentWidth=0;
	var currentHeight=0;
	gallery();
	init();


	viewLink=request.zos.siteVirtualFileCom.getViewLink(variables.currentFile);
	downloadLink=request.zos.siteVirtualFileCom.getDownloadLink(variables.currentFile);
	</cfscript>
	<a href="##" onclick="history.back(); return false;">Back</a>
	<table style="margin-left:auto; margin-right:auto; border-spacing:0px;width:100%;">
		<tr>
		<td>
		<script type="text/javascript">
	/* <![CDATA[ */

	if(!window.parent.zInsertGalleryImage){
	    alert('HTML Editor is missing');
	}
	function setImage(){
	    var radioGrp = document.iaform.image_align;
	    var a="";
	    for (var i = 0; i< radioGrp.length; i++) {
			if (radioGrp[i].checked) {
			    a=radioGrp [i].value;
			}
	    }
	    var theHTML="";
	    if(a==0){// left
		theHTML='<img src="#viewLink#" class="zImageLeft">';
	    }else if(a==3){ // default - none
		theHTML='<img src="#viewLink#" class="zImageDefault">';
	    }else if(a==2){ // right
		theHTML='<img src="#viewLink#" class="zImageRight">';
	    }else if(a==1){ // center
		theHTML='<div style="width:100%; float:none; text-align:center;"><img src="#viewLink#"></div>';
	    }

		window.parent.zInsertGalleryImage(theHTML); 

	}/* ]]> */
	</script>

		<table style="text-align:center;">
		<tr>
		<td style="text-align:center;">
			<img src="#viewLink#" alt="Image" style="max-height:150px; max-width:250px;" /><br />
			<cfscript> 
			echo('Resolution: '&variables.currentFile.virtual_file_image_width&"x"&variables.currentFile.virtual_file_image_height);
			</cfscript>
			<br />

			How do you want this image to align with the text on this page?<br /> 
			<form action="" name="iaform" id="iaform" method="get">

				<table style="margin-left:auto; margin-right:auto; border-spacing:0px;">
				<tr>
				<td>
				<a href="##" onclick="document.iaform.image_align[0].checked=true;setImage();" style="text-decoration:none;"><img src="/z/images/page/align-left.gif" /><br />
				<input type="radio" name="image_align" id="image_align" value="0"  style="background:none; border:none;" />Left</a>
				</td>
				<td>
				<a href="##" onclick="document.iaform.image_align[1].checked=true;setImage();" style="text-decoration:none;"><img src="/z/images/page/align-center.gif" /><br />
				<input type="radio" name="image_align" id="image_align" value="1" checked="checked" style="background:none; border:none;" />Center</a>
				</td>
				<td>
				<a href="##" onclick="document.iaform.image_align[2].checked=true;setImage();" style="text-decoration:none;"><img src="/z/images/page/align-right.gif" /><br />
				<input type="radio" name="image_align" id="image_align" value="2"  style="background:none; border:none;" />Right</a>
				</td>
				</tr>
				<tr><td colspan="3" style="text-align:center"><a href="##" onclick="document.iaform.image_align[3].checked=true;setImage();" style="text-decoration:none;"><input type="radio" name="image_align" id="image_align" value="3"  style="background:none; border:none;" /> 
				Click here for no alignment (<strong>recommended</strong>)</a></td></tr>
				</table>
			</form>
			</div>
		</td></tr></table>
	</td></tr></table>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript> 
	init();
	application.zcore.functions.zSetPageHelpId("2.5");
	application.zcore.functions.zStatusHandler(request.zsid);

	application.zcore.template.appendTag("meta",'<style type="text/css">
	/* <![CDATA[ */ .fi-1 {
	    background-color:##336699;
	    color:##FFFFFF;
	}
	.fi-1 a:link, .fi-1 a:visited {
	    color:##FFFFFF; text-decoration:none;
	}
	.fi-1 a:hover {
	    color:##FFFF00; text-decoration:underline;
	} /* ]]> */
	</style>');

	 
	// TODO: date sorting was disabled for now
	if ( structKeyExists( form, 'csort' ) ) {
		if ( form.csort EQ 'date' ) {
			// Order by Date
			request.zsession.fileManagerSortDate=1;
		} else {
			// Order by Name
			request.zsession.fileManagerSortDate=0;
		}
	} else {
		request.zsession.fileManagerSortDate=application.zcore.functions.zso(request.zsession, 'fileManagerSortDate', true, 0);
	}
	</cfscript>
	<cfif not request.zos.fileImage.editDisabled>
	    <table style="border-spacing:0px; width:100%; border-bottom:1px solid ##CCC; padding-bottom:5px; margin-bottom:5px;">
			<tr>
			<td style="font-weight:700;">
				<cfif form.galleryMode>
					<a href="/z/admin/files/galleryAddFolder?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;"><img src="/z/images/page/directory.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">Create Folder</a> | 
					<a href="/z/admin/files/galleryAdd?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;"><img src="/z/images/page/image.gif" style="vertical-align:bottom; padding-left:4px; padding-right:4px;">Upload Image</a> | 
					<a href="/z/admin/files/index?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;" target="_blank">Manage Files</a> | 
					 Sort by: 
					<cfif application.zcore.functions.zso(request.zsession, 'fileManagerSortDate',true) EQ 0>
						<a href="/z/admin/files/gallery?csort=date&amp;virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;">Date</a> | <span style="color:##999;">Name</span> | 
					<cfelse>
						<span style="color:##999;">Date</span> | <a href="/z/admin/files/gallery?csort=name&amp;virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;">Name</a> | 
					</cfif><!---   --->
					<a href="/z/admin/files/gallery?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;">Refresh</a>
				<cfelseif form.fileGalleryMode>
					<a href="/z/admin/files/fileGalleryAddFolder?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;"><img src="/z/images/page/directory.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">Create Folder</a> | 
					<a href="/z/admin/files/fileGalleryAdd?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;"><img src="/z/images/page/file.gif" style="vertical-align:bottom; padding-left:4px; padding-right:4px;">Upload File</a> | 
					<a href="/z/admin/files/index?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;" target="_blank">Manage Images</a> | 
					Sort by: 
					<cfif application.zcore.functions.zso(request.zsession, 'fileManagerSortDate',true) EQ 0>
						<a href="/z/admin/files/fileGallery?csort=date&amp;virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;">Date</a> | <span style="color:##999;">Name</span> | 
					<cfelse>
						<span style="color:##999;">Date</span> | <a href="/z/admin/files/fileGallery?csort=name&amp;virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;">Name</a> | 
					</cfif><!---   --->
					<a href="/z/admin/files/fileGallery?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;">Refresh</a>
				<cfelse>
					<a href="/z/admin/files/addFolder?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;"><img src="/z/images/page/directory.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">Create Folder</a> | 
					<a href="/z/admin/files/addFile?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;"><img src="/z/images/page/file.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">Upload File</a> | 
					<a href="/z/admin/files/add?virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;"><img src="/z/images/page/image.gif" style="vertical-align:bottom; padding-left:4px; padding-right:4px;">Upload Image</a> 
					<cfif request.zos.isDeveloper>
						| <a href="/z/admin/files/index?virtual_folder_id=#form.virtual_folder_id#&amp;reloadCache=1" style="text-decoration:none; color:##000;">Reload Cache</a>
					</cfif>
					| Sort by: 
					<cfif application.zcore.functions.zso(request.zsession, 'fileManagerSortDate',true) EQ 0>
						 <a href="/z/admin/files/index?csort=date&amp;virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;">Date</a> | <span style="color:##999;">Name</span>
					<cfelse>
						 <span style="color:##999;">Date</span> | <a href="/z/admin/files/index?csort=name&amp;virtual_folder_id=#form.virtual_folder_id#" style="text-decoration:none; color:##000;">Name</a> 
					</cfif><!---   --->
				</cfif> 
				 
				</td>
			</tr>
			</table>
	</cfif>
	<cfscript> 
	ts={
		type:"both", 
		virtual_folder_id:form.virtual_folder_id, 
		recursive:false, 
		orderDirection:"asc",
		limit:0
	};
	if(request.zsession.fileManagerSortDate EQ 1){
		ts.sortBy="date";
		ts.orderDirection="desc";
	}
	arrFolder=request.zos.siteVirtualFileCom.getChildrenByFolderId(ts);
	if(arrayLen(arrFolder) EQ 0){
	    echo('<p>This directory has no files or folders.</p>');
	}
	</cfscript>  
		<cfscript>
		imageTypeStruct={
			"png":true,
			"jpg":true,
			"jpeg":true,
			"gif":true
		}; 
		if(form.fileGalleryMode){
			echo('<table style="border-spacing:0px; width:100%;">');
			echo('<tr><td>');	
			arrDir=arraynew(1);
			arrFile=ArrayNew(1);
			for(i=1;i LTE arrayLen(arrFolder);i=i+1){
				row=arrFolder[i];
				if(structkeyexists(row, 'virtual_file_path')){
					if(not structkeyexists(imageTypeStruct, application.zcore.functions.zGetFileExt(row.virtual_file_name))){
						arrayAppend(arrFile, row);
					}
				}else{
					arrayAppend(arrDir, row);
				}
			}
			if(arraylen(arrDir) NEQ 0){
				echo('<strong>Subdirectories:</strong><br />
				<div class="z-float">'); 

				for(row in arrDir){ 
					if(row.virtual_folder_id NEQ 0){
						echo('<div style="width:33%; padding-bottom:3px; padding-right:10px; float:left;">');
						echo('<a href="/z/admin/files/#form.curListMethod#?virtual_folder_id=#row.virtual_folder_id#" class="z-button" style="text-align:left; background-color:##EEE; text-decoration:none; border:1px solid ##CCC; display:block; width:100%; float:left; border-radius:5px; padding:3px; color:##000000;">#row.virtual_folder_name#</a><br />');
						echo('</div>');
					}
				}
				echo('</div>');
			} 

			inputStruct = StructNew();
			inputStruct.colspan = 4;
			inputStruct.rowspan = ArrayLen(arrFile);
			inputStruct.vertical = true;
			myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
			if(ArrayLen(arrFile) NEQ 0){
				echo('<strong>Files:</strong><br />');
			}
			for(row in arrFile){
				tempImage=false;
				echo('<div style="width:100%; float:left; border-bottom:1px solid ##CCCCCC; padding:5px; ">
					<a href="/z/admin/files/fileGalleryViewFile?fileGalleryMode=true&amp;virtual_folder_id=#row.virtual_file_folder_id#&amp;virtual_file_id=#row.virtual_file_id#">#row.virtual_file_name#</a>
				</div>');
			}
			echo('</td></tr>');
		}else if(form.galleryMode){
			echo('<table style="border-spacing:0px; width:100%;">');
			echo('<tr><td>');
			arrDir=arraynew(1);
			arrFile=ArrayNew(1);
			for(i=1;i LTE arrayLen(arrFolder);i=i+1){
				row=arrFolder[i];
				if(structkeyexists(row, 'virtual_file_path')){
					if(structkeyexists(imageTypeStruct, application.zcore.functions.zGetFileExt(row.virtual_file_name))){
						arrayAppend(arrFile, row);
					}
				}else{
					arrayAppend(arrDir, row);
				}
			}
			if(arraylen(arrDir) NEQ 0){
				echo('<strong>Subdirectories:</strong><br />
				<div class="z-float">'); 

				for(row in arrDir){ 
					echo('<div style="width:33%; padding-bottom:3px; padding-right:10px; float:left;">');
					echo('<a href="/z/admin/files/#form.curListMethod#?virtual_folder_id=#row.virtual_folder_id#" class="z-button" style="text-align:left; background-color:##EEE; text-decoration:none; border:1px solid ##CCC; display:block; width:100%; float:left; border-radius:5px; padding:3px; color:##000000;">#row.virtual_folder_name#</a><br />');
					echo('</div>');
				}
				echo('</div>');
			} 

			inputStruct = StructNew();
			inputStruct.colspan = 4;
			inputStruct.rowspan = ArrayLen(arrFile);
			inputStruct.vertical = true;
			myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
			if(ArrayLen(arrFile) NEQ 0){
				echo('<strong>Images:</strong><br />');
			}
			for(i=1;i<=arrayLen(arrFile);i++){
				row=arrFile[i];
				tempImage=false;
				link=request.zos.siteVirtualFileCom.getViewLink(row);
				echo('<div style="width:100px; height:125px; float:left; text-align:center; overflow:hidden; border:1px solid ##CCCCCC; padding:0px; margin-right:10px; margin-bottom:10px;font-size:11px;">
					<a href="/z/admin/files/align?galleryMode=true&amp;virtual_file_id=#row.virtual_file_id#" title="#htmleditformat(row.virtual_file_name)#" style="text-decoration:none;">');
					echo('<span style="display:block; float:left; height:100px;margin-bottom:5px; width:100%;">');
					if(i < 10){
						// no lazy load for first 10 images
						echo('<img src="#link#" alt="Image" style="max-width:100px; max-height:100px;">');
					}else{
						echo('<img class="zLazyImage" alt="Image" src="/z/a/images/loading.gif" data-original="#link#" style="max-width:100px; max-height:100px;"  />');
					}
					echo('</span>');
					echo('<br>'&row.virtual_file_image_width&"x"&row.virtual_file_image_height);

				echo('</a>
				</div>');
			}
			echo('</td></tr>');
			echo('</table>');
		}else{
			echo('<table style="border-spacing:0px;" class="table-list">');
			arrDir=arraynew(1);
			arrFile=ArrayNew(1);
			for(i=1;i LTE arrayLen(arrFolder);i=i+1){
				row=arrFolder[i];
				if(structkeyexists(row, 'virtual_file_path')){
					arrayAppend(arrFile, row);
				}else{
					arrayAppend(arrDir, row);
				}
			}  
			for(row in arrDir){
				editLink='/z/admin/files/editFolder?virtual_folder_id=#row.virtual_folder_id#';
				echo('<tr><td colspan="4" style="vertical-align:top;">');
				echo('<a href="/z/admin/files/#form.curListMethod#?virtual_folder_id=#row.virtual_folder_id#" style="text-decoration:none; color:##000000;"><img src="/z/images/page/directory.gif" style="vertical-align:bottom;padding-left:4px; padding-right:4px;">#row.virtual_folder_name#</a>');
				echo('</td>');
				echo('<td>');
					echo('<a href="#editLink#">Edit</a> | ');
				if(request.zos.fileImage.deleteDisabled EQ false){
					echo('<a href="/z/admin/files/deleteFolder?virtual_folder_id=#row.virtual_folder_id#">Delete</a>');
					/*if(request.zos.siteVirtualFileCom.folderHasChildren(row.virtual_folder_id)){
						echo('Delete Contents First');
					}else{
						echo('<a href="/z/admin/files/deleteFolder?virtual_folder_id=#row.virtual_folder_id#">Delete</a>');
					}*/
				}
				echo('</td>');
				echo('</tr>');
			} 
			for(i=1;i<=arrayLen(arrFile);i++){
				row=arrFile[i];
				echo('<tr><td style="vertical-align:top; width:100px;">');
				fileext=application.zcore.functions.zGetFileExt(row.virtual_file_name);
				isAnImage=false;
				icon='file.gif';
				editLink='/z/admin/files/editFile?virtual_file_id=#row.virtual_file_id#';
				if('jpeg' EQ fileext or 'jpg' EQ fileext OR 'gif' EQ fileext or 'png' EQ fileext){
					isAnImage=true;
					icon='image.gif';
					editLink='/z/admin/files/edit?virtual_file_id=#row.virtual_file_id#';
				}
				viewLink=request.zos.siteVirtualFileCom.getViewLink(row);
				downloadLink=request.zos.siteVirtualFileCom.getDownloadLink(row);
					if(isAnImage){
						if(i < 10){
							// no lazy load for first 10 images
							echo('<a href="#viewLink#" alt="Image" target="_blank" style="text-decoration:none; color:##000000; vertical-align:top;"><img src="#viewLink#" style="max-width:100px; max-height:100px;vertical-align:bottom;padding-left:4px; padding-right:4px;"></a>');
						}else{
							echo('<a href="#viewLink#" alt="Image" target="_blank" style="text-decoration:none; color:##000000; vertical-align:top;"><img class="zLazyImage" src="/z/a/images/loading.gif" style="max-width:100px; max-height:100px;vertical-align:bottom;padding-left:4px; padding-right:4px;" data-original="#viewLink#"></a>');
						}
					}else{
						echo('<a href="#downloadLink#" target="_blank" style="text-decoration:none; color:##000000;"><img src="/z/images/page/#icon#" style="vertical-align:bottom;padding-left:4px; padding-right:4px;"></a>');
					}
				/*if(request.zos.fileImage.addDisabled EQ false){
				}else{
					if(request.zos.fileImage.enableDownload){
						echo('<a href="#viewLink#" target="_blank" style="text-decoration:none; color:##000000;"><img src="/z/images/page/#icon#" style="vertical-align:bottom;padding-left:4px; padding-right:4px;"></a>');
					}else{
						echo('<a href="#viewLink#" target="_blank" style="text-decoration:none; color:##000000;"><img src="/z/images/page/#icon#" style="vertical-align:bottom;padding-left:4px; padding-right:4px;"></a>');
					}
				}*/
				echo('</td>');
				echo('<td><a href="#viewLink#" target="_blank">#row.virtual_file_name#</a>');
				if(isAnImage){
					echo('<br>#row.virtual_file_image_width#x#row.virtual_file_image_height#');
				}
				echo('</td>');
				echo('<td>'&numberformat(row.virtual_file_size/1024/1024, '_.__')&'mb</td>');
				echo('<td style="vertical-align:top;">#DateFormat(row.virtual_file_last_modified_datetime,'m/d/yyyy')&' '&TimeFormat(row.virtual_file_last_modified_datetime,'h:mm tt')#</td>');
				echo('<td class="z-manager-admin" style="vertical-align:top;">
					<div class="z-manager-button-container">
						<a href="#viewLink#" target="_blank" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a>
					</div>
					<div class="z-manager-button-container">
						<a href="#editLink#" class="z-manager-edit" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a>
					</div>');

				if(request.zos.fileImage.deleteDisabled EQ false){ 
					echo('
					<div class="z-manager-button-container">
						<a href="/z/admin/files/delete?virtual_file_id=#row.virtual_file_id#" class="z-manager-delete" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></a>
					</div>');
				}
				echo(' 
					<div class="z-manager-button-container">
						<a href="#downloadLink#" target="_blank" class="z-manager-view" title="Download"><i class="fa fa-download" aria-hidden="true"></i></a>
					</div>
					');
				echo('</td>');
				echo('</tr>');
			}
			echo('</table>');
		}
		</cfscript> 
	<cfscript>
	application.zcore.skin.includeJS("/z/javascript/jquery/jquery-lazyload/jquery.lazyload.min.js");
	application.zcore.skin.addDeferredScript('
		var lazyImages=$("img.zLazyImage"); 
		if(typeof lazyImages.lazyload != "undefined"){
			lazyImages.lazyload(); 
		}
	');
	</cfscript>
</cffunction>

<cffunction name="serveFileByPath" localmode="modern" access="public" hint="This supports legacy path based file request">
	<cfargument name="virtual_file_path" type="string" required="yes">
	<cfscript>
	variables.disableManagerSecurity=true;
	init();
	rs=request.zos.siteVirtualFileCom.getFileByPath(arguments.virtual_file_path); 
	if(not rs.success){
		application.zcore.functions.z404("File doesn't exist, or user doesn't have access");
	}
	form.virtual_file_id=rs.data.virtual_file_id;
	form.virtual_file_secure=rs.data.virtual_file_secure;
	form.virtual_file_download_secret=rs.data.virtual_file_download_secret;
	request.zos.siteVirtualFileCom.serveVirtualFile();
	</cfscript>
</cffunction>
	
<cffunction name="downloadFileByPath" localmode="modern" access="public" hint="This supports legacy path based file request">
	<cfargument name="virtual_file_path" type="string" required="yes">
	<cfscript>
	variables.disableManagerSecurity=true;
	init();
	rs=request.zos.siteVirtualFileCom.getFileByPath(arguments.virtual_file_path);
	if(not rs.success){
		application.zcore.functions.z404("File doesn't exist, or user doesn't have access");
	}
	form.virtual_file_id=rs.data.virtual_file_id;
	form.virtual_file_secure=rs.data.virtual_file_secure;
	form.virtual_file_download_secret=rs.data.virtual_file_download_secret;
	request.zos.siteVirtualFileCom.downloadVirtualFile();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
