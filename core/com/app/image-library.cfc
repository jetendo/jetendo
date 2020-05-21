<!--- 
SCHEDULE DAILY TASK: /z/_com/app/image-library?method=deleteInactiveImageLibraries
		
--->
<cfcomponent>  
<cfoutput>
<!--- application.zcore.imageLibraryCom.registerSize(image_library_id, size, crop); --->
<cffunction name="registerSize" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfargument name="size" type="string" required="yes">
	<cfargument name="crop" type="numeric" required="no" default="#0#">
	<cfscript>
	if(arguments.image_library_id EQ "" or isnumeric(arguments.image_library_id) EQ false){
		return;
		//application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - registerSize() failed because arguments.image_library_id is not a number greater then or equal to zero.");
	}
	if(structkeyexists(request, 'app') and structkeyexists(application.sitestruct[request.zos.globals.id].imageLibraryStruct.sizeStruct, arguments.image_library_id&"-"&arguments.size&"-"&arguments.crop) EQ false){
	    application.sitestruct[request.zos.globals.id].imageLibraryStruct.sizeStruct[arguments.image_library_id&"-"&arguments.size&"-"&arguments.crop]=true;
	}
	</cfscript>
</cffunction>

<!--- /z/_com/app/image-library?method=remoteDeleteImageId&image_id=#image_id# --->
<cffunction name="remoteDeleteImageId" localmode="modern" access="remote" returntype="any" output="no">
	<cfscript> 
	this.deleteImageId(application.zcore.functions.zso(form, 'image_id'));
	writeoutput('{"success":"1"}');
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>


<cffunction name="getNewLibraryId" localmode="modern" access="public" returntype="any" output="no">
	<cfscript>
	var image_library_id=0;
	var ts=structnew();
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="image_library";
	ts.struct=structnew();
	ts.struct.site_id=request.zos.globals.id;
	ts.struct.image_library_active=0;
	ts.struct.image_library_hash=hash(application.zcore.functions.zGenerateStrongPassword(80,200), 'sha-256'); 
	ts.struct.image_library_approved=1;
	//ts.debug=true;
	ts.struct.image_library_datetime=request.zos.mysqlnow;
	image_library_id=application.zcore.functions.zInsert(ts);
	if(image_library_id EQ false){
		throw("Error: zcorerootmapping.com.app.image-library.cfc - getNewLibraryId() failed to insert into image_library.");
	}
	return image_library_id;
	</cfscript>
</cffunction>

<!--- application.zcore.imageLibraryCom.ActivateLibraryId(image_library_id); --->
<cffunction name="ActivateLibraryId" localmode="modern" returntype="any" output="no">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="UPDATE #db.table("image_library", request.zos.zcoreDatasource)# 
	SET image_library_active = #db.param('1')#,
	image_library_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE image_library_id=#db.param(arguments.image_library_id)# and 
	image_library_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("q");
	</cfscript>
</cffunction>

<cffunction name="approveLibraryId" localmode="modern" returntype="any" output="no">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="UPDATE #db.table("image_library", request.zos.zcoreDatasource)# 
	SET image_library_approved = #db.param('1')#,
	image_library_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE image_library_id=#db.param(arguments.image_library_id)# and 
	image_library_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("q");
	
	db.sql="UPDATE #db.table("image", request.zos.zcoreDatasource)# 
	SET image_approved = #db.param('1')#,
	image_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE image_library_id=#db.param(arguments.image_library_id)# and 
	image_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("q");
	</cfscript>
</cffunction>

<cffunction name="unapproveLibraryId" localmode="modern" returntype="any" output="no">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="UPDATE #db.table("image_library", request.zos.zcoreDatasource)# 
	SET image_library_approved = #db.param('0')#,
	image_library_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE image_library_id=#db.param(arguments.image_library_id)# and 
	image_library_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("q");
	
	db.sql="UPDATE #db.table("image", request.zos.zcoreDatasource)# 
	SET image_approved = #db.param('0')#,
	image_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE image_library_id=#db.param(arguments.image_library_id)# and 
	image_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("q");
	
	db.sql="select * from #db.table("image_cache", request.zos.zcoreDatasource)#  
	WHERE image_library_id=#db.param(arguments.image_library_id)# and 
	image_cache_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qCache=db.execute("qCache");
	for(row in qCache){
		application.zcore.functions.zdeletefile(request.zos.globals.privatehomedir&"zupload/library/"&row.image_library_id&"/"&row.image_cache_file);
	}
	db.sql="delete from #db.table("image_cache", request.zos.zcoreDatasource)# 
	WHERE image_library_id=#db.param(arguments.image_library_id)# and 
	image_cache_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>


<cffunction name="getImageLinkFromQuery" localmode="modern" access="public" returntype="any" output="yes">
	<cfargument name="qImage" type="string" required="yes">
	<cfargument name="row" type="numeric" required="no" default="#1#">
	<cfargument name="size" type="string" required="yes">
	<cfargument name="crop" type="numeric" required="no" default="#0#">
	<cfscript>
	var filePath=0;
	var info=0;
	var ext=0;
	if(qImage.recordcount LT arguments.row){
		application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - getImageLinkFromQuery() failed because qImage.recordcount is 0.");
	}
	loop query="arguments.qImage" startrow="#arguments.row#" endrow="#arguments.row#"{
		if(arguments.size EQ "original"){
			return 	"/zupload/library/"&arguments.qImage.image_library_id&"/"&arguments.qImage.image_file&"?ztv=#dateformat(arguments.qImage.image_updated_datetime, "yyyymmdd")&timeformat(arguments.qImage.image_updated_datetime, "HHmmss")#";
		}
		if(structkeyexists(application.sitestruct[request.zos.globals.id].imageLibraryStruct.sizeStruct, arguments.qImage.image_library_id&"-"&arguments.size&"-"&arguments.crop) EQ false){
			// check for global size to avoid errors for requests without http referrers
			if(structkeyexists(application.sitestruct[request.zos.globals.id].imageLibraryStruct.sizeStruct, "0-"&arguments.size&"-"&arguments.crop) EQ false){ 
				//application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - getImageLink() failed because "&arguments.image_library_id&"-"&arguments.size&"-"&arguments.crop&" doesn't exist in the sizeStruct. Use application.zcore.imageLibraryCom.registerSize(image_library_id, size, crop).");
			}
		}
		ext=lcase(application.zcore.functions.zGetFileExt(arguments.qImage.image_file));
		if(ext EQ "jpeg"){
			ext="jpg";
		}
		filePath="zupload/library/"&image_library_id&"/"&application.zcore.functions.zURLEncode(application.zcore.functions.zLimitStringLength(arguments.qImage.image_caption, 70),'-')&"-"&arguments.qImage.image_id&"-"&arguments.size&"-"&arguments.crop&"."&ext;
		if(fileexists(request.zos.globals.privatehomedir&filePath)){
			return "/"&filePath&"?ztv=#dateformat(arguments.qImage.image_updated_datetime, "yyyymmdd")&timeformat(arguments.qImage.image_updated_datetime, "HHmmss")#";
		}else{
			return replace("/z/_com/app/image-library?method=generateImage&image_library_id="&arguments.qImage.image_library_id&"&image_id="&arguments.qImage.image_id&"&size="&arguments.size&"&crop="&arguments.crop&"&ztv="&gettickcount(),"&","&amp;","ALL");
		}
	}
	</cfscript>
</cffunction>

<!--- application.zcore.imageLibraryCom.getImageLink(image_library_id, image_id, size, crop, captionAvailable, image_caption, image_file, image_updated_datetime); --->
<cffunction name="getImageLink" localmode="modern" access="public" returntype="any" output="no">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfargument name="image_id" type="string" required="yes">
	<cfargument name="size" type="string" required="yes">
	<cfargument name="crop" type="numeric" required="no" default="#0#">
	<cfargument name="captionAvailable" type="boolean" required="no" default="#false#">
	<cfargument name="image_caption" type="string" required="no" default="">
	<cfargument name="image_file" type="string" required="no" default="">
	<cfargument name="image_updated_datetime" type="string" required="no" default="">
	<cfargument name="pregenerate" type="boolean" required="no" default="#false#">
	<cfscript>
	var filePath=0;
	var ext=0;
	var info=0;
	var db=request.zos.queryObject;
	var qImage=structnew();
	
	if(structkeyexists(application.sitestruct[request.zos.globals.id].imageLibraryStruct.sizeStruct, arguments.image_library_id&"-"&arguments.size&"-"&arguments.crop) EQ false){
		// check for global size to avoid errors for requests without http referrers
		if(structkeyexists(application.sitestruct[request.zos.globals.id].imageLibraryStruct.sizeStruct, "0-"&arguments.size&"-"&arguments.crop) EQ false){ 
			//application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - getImageLink() failed because "&arguments.image_library_id&"-"&arguments.size&"-"&arguments.crop&" doesn't exist in the sizeStruct. Use application.zcore.imageLibraryCom.registerSize(image_library_id, size, crop).");
		}
	}
	if(arguments.captionAvailable){
		qImage.image_caption=arguments.image_caption;
		qImage.image_file=arguments.image_file;
		qImage.recordcount=1;
		qImage.image_updated_datetime=arguments.image_updated_datetime;
	}else{
		db.sql="SELECT * FROM #db.table("image", request.zos.zcoreDatasource)# image 
		WHERE image_library_id=#db.param(arguments.image_library_id)# and 
		image_id = #db.param(arguments.image_id)# and 
		image_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qImage=db.execute("qImage");
	}
	if(qImage.recordcount EQ 0){
		return false;	
	}else{
		ext=lcase(application.zcore.functions.zGetFileExt(qImage.image_file));
		if(ext EQ "jpeg"){
			ext="jpg";
		}
		filePath="zupload/library/"&arguments.image_library_id&"/"&application.zcore.functions.zURLEncode(application.zcore.functions.zLimitStringLength(qImage.image_caption, 70),'-')&"-"&arguments.image_id&"-"&arguments.size&"-"&arguments.crop&"."&ext;
	}


	tempPath=request.zos.globals.privatehomedir&filePath;
	/*
	// this logic is not foolproof on certain operations.
	if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath) EQ false or application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath] EQ false){
		tempExists=fileexists(tempPath);
	}else{
		tempExists=application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath];
	} */


	if(fileexists(tempPath)){
		//application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath]=tempPath;
		return "/"&filePath&"?ztv=#dateformat(qImage.image_updated_datetime, "yyyymmdd")&timeformat(qImage.image_updated_datetime, "HHmmss")#";
	}else{
		if(arguments.pregenerate){
			rs=generateImage(arguments.image_library_id, arguments.image_id, arguments.size, arguments.crop, true);
			if(rs.success){
				return "/"&filePath;
			}else{
				// ignore rs.errorMessage and return not available image instead
				return '/z/a/listing/images/image-not-available.jpg';
			}
		}else{
			return replace("/z/_com/app/image-library?method=generateImage&image_library_id=#arguments.image_library_id#&image_id=#arguments.image_id#&size=#arguments.size#&crop=#arguments.crop#&ztv=#gettickcount()#","&","&amp;","ALL");
		}
	}
	</cfscript>
</cffunction>

<!--- only use in <img> tags
/z/_com/app/image-library?method=generateImage&amp;image_library_id=&amp;image_id=&amp;size=&amp;crop=0 --->
<cffunction name="generateImage" localmode="modern" access="remote" returntype="any" output="yes">
	<cfargument name="image_library_id" type="string" required="no" default="#application.zcore.functions.zso(form, 'image_library_id',false,'')#">
	<cfargument name="image_id" type="string" required="no" default="#application.zcore.functions.zso(form, 'image_id',false,'')#">
	<cfargument name="size" type="string" required="no" default="#application.zcore.functions.zso(form, 'size',false,'')#">
	<cfargument name="crop" type="string" required="no" default="#application.zcore.functions.zso(form, 'crop',false,0)#">
	<cfargument name="returnJson" type="boolean" required="no" default="#false#">
	<cfscript>
	var ext=0;
	var db=request.zos.queryObject;
	var qImage=0;
	var destination="zupload/library/#arguments.image_library_id#/";
	var arrFiles=0;
	var newFileName="";
	var sql="";
	var arrSize=0;
	var image_intermediate_file=0;
	var ts=0;
	var arrList=0;
	var zDebug=application.zcore.functions.zso(form, 'zDebug', false, false);
	if(not isnumeric(arguments.image_library_id)){
		application.zcore.functions.z404("Invalid image_library_id: #arguments.image_library_id#");
	}
	if(not request.zos.isDeveloper){
		zDebug=false;
	}
	setting requesttimeout="1000";

	if(not structkeyexists(cookie, 'zenable')){
		application.zcore.functions.z404("No cookie set, so generateImage is prevented to avoid hotlinks to dynamic image requests.");
	}  
	if(arguments.crop NEQ 1 and arguments.crop NEQ 0){
		application.zcore.functions.z404("Invalid request: zcorerootmapping.com.app.image-library.cfc - getImageLink() failed because arguments.crop must be a 1 or 0 and it is: #arguments.crop#.");
	}
	if(arguments.crop EQ 0){
		arguments.crop =0;
	}else{
		arguments.crop=1;	
	}
	
	arrSize=listtoarray(arguments.size,"x");
	if(arraylen(arrSize) NEQ 2){
		if(request.zos.cgi.QUERY_STRING CONTAINS "&amp;size=" or arguments.size EQ ""){
			// invalid spider request not html compatible.
			if(zdebug){
				writeoutput('404 invalid request1: /z/a/listing/images/image-not-available.jpg');
				application.zcore.functions.zabort();
			}
			if(arguments.returnJson){
				return {success:false, "invalid request - amp; in url - wrong url encoding" };
			}else{
				application.zcore.functions.zheader("Content-Type","image/jpeg");
				if(cgi.SERVER_SOFTWARE EQ "" or cgi.SERVER_SOFTWARE CONTAINS "nginx"){
					application.zcore.functions.zXSendFile("/z/a/listing/images/image-not-available.jpg");
				}else{
					application.zcore.functions.zXSendFile("#request.zos.zcoreRootPath#static/a/listing/images/image-not-available.jpg");
				}
			}
		}else{
			application.zcore.functions.z404("Invalid request: zcorerootmapping.com.app.image-library.cfc - getImageLink() failed because arguments.size: #arguments.size# must be formatted like widthxheight i.e. 250x160.");
		}
	} 
	db.sql="SELECT * FROM #db.table("image_cache", request.zos.zcoreDatasource)#  
	WHERE 
	image_id = #db.param(arguments.image_id)# and 
	image_cache_width=#db.param(arrSize[1])# and  
	image_cache_height=#db.param(arrSize[2])# and  
	image_cache_crop=#db.param(arguments.crop)# and 
	image_cache_deleted = #db.param(0)# and 
	site_id =#db.param(request.zos.globals.id)#";
	qCache=db.execute("qCache");
	if(qCache.recordcount NEQ 0){
		// serve cached image instead - test that it works on image update still
		ext=application.zcore.functions.zGetFileExt(qCache.image_cache_file);
		type="image/jpeg";
		if(ext EQ "png"){
			type="image/png";
		}else if(ext EQ "gif"){
			type="image/gif";
		} 
		if(arguments.returnJson){
			return {success:true, filePath:"/"&destination&qCache.image_cache_file };
		}else{
			application.zcore.functions.zheader("Content-Type", type);
			if(cgi.SERVER_SOFTWARE EQ "" or cgi.SERVER_SOFTWARE CONTAINS "nginx"){
				application.zcore.functions.zXSendFile("/"&destination&qCache.image_cache_file);
			}else{
				application.zcore.functions.zXSendFile(request.zos.globals.privatehomedir&destination&qCache.image_cache_file);
			}
		}
	}

	
	/*
	// registering image size prevents extra images from being generated then are officially allowed.
	if(structkeyexists(application.sitestruct[request.zos.globals.id].imageLibraryStruct.sizeStruct, arguments.image_library_id&"-"&arguments.size&"-"&arguments.crop) EQ false){
		// check for global size to avoid errors for requests without http referrers
		if(structkeyexists(application.sitestruct[request.zos.globals.id].imageLibraryStruct.sizeStruct, "0-"&arguments.size&"-"&arguments.crop) EQ false){ 
			//application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - getImageLink() failed because "&arguments.image_library_id&"-"&arguments.size&"-"&arguments.crop&" doesn't exist in the sizeStruct. Use application.zcore.imageLibraryCom.registerSize(image_library_id, size, crop).");
		}
	}*/
	db.sql="select image.* from #db.table("image", request.zos.zcoreDatasource)# image 
	 WHERE ";
	if(not variables.hasAccessToImageLibraryId(arguments.image_library_id)){
		db.sql&=" image_approved = #db.param('1')#  and ";
	}
	 db.sql&="image.image_id = #db.param(arguments.image_id)# and 
	 image_deleted = #db.param(0)# and 
	 image.site_id=#db.param(request.zos.globals.id)#";
	qImage=db.execute("qImage");
	if(qImage.recordcount EQ 0 or qImage.image_file EQ ""){
		if(zdebug){ 
			writeoutput('404 image not in image table: /z/a/listing/images/image-not-available.jpg');
			writedump(qImage);
			application.zcore.functions.zabort();
		}
		if(arguments.returnJson){
			return {success:false, errorMessage:"Not found in image table" };
		}else{
			application.zcore.functions.zheader("Content-Type","image/jpeg");
			if(cgi.SERVER_SOFTWARE EQ "" or cgi.SERVER_SOFTWARE CONTAINS "nginx"){
				application.zcore.functions.zXSendFile("/z/a/listing/images/image-not-available.jpg");
			}else{
				application.zcore.functions.zXSendFile("#request.zos.zcoreRootPath#static/a/listing/images/image-not-available.jpg");
			} 
		}
	} 
	
	application.zcore.functions.zCreateDirectory(request.zos.globals.privatehomedir&destination);
	ext=lcase(application.zcore.functions.zGetFileExt(qImage.image_file));
	if(ext EQ "jpeg"){
		ext="jpg";
	}
	newFileName=application.zcore.functions.zURLEncode(application.zcore.functions.zLimitStringLength(qImage.image_caption, 70),'-')&"-"&arguments.image_id&"-"&arguments.size&"-"&arguments.crop&"."&ext;
	
	if(arrSize[1] GT request.zos.globals.maximagewidth){
		// very large file requested, use original max resolution file
		image_intermediate_file=qImage.image_file;
	}else if(qImage.image_intermediate_file EQ ""){
		// generate missing intermediates
		arrList = application.zcore.functions.zResizeImage(request.zos.globals.privatehomedir&destination&qImage.image_file,request.zos.globals.privatehomedir&destination,"#request.zos.globals.maximagewidth#x2000",0); 
		if(isarray(arrList) EQ false){
			application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - generateImage() failed because zResizeImage() failed.");
		}else if(ArrayLen(arrList) EQ 1){
			image_intermediate_file=arrList[1];
			db.sql="UPDATE #db.table("image", request.zos.zcoreDatasource)#  
			SET image_intermediate_file=#db.param(image_intermediate_file)# ,
			image_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE image_id = #db.param(arguments.image_id)# and 
			image_deleted = #db.param(0)# and 
			site_id =#db.param(request.zos.globals.id)#";
			db.execute("q");
			if(zdebug){
				writeoutput('intermediate image created<br />');
			}
		}
	}else{
		// normal size requested, use low res intermediate file to generate the new image.
		image_intermediate_file=qImage.image_intermediate_file;
	}
	if((not zdebug or not request.zos.isDeveloper) and fileexists(request.zos.globals.privatehomedir&destination&newFileName)){
		ext=application.zcore.functions.zGetFileExt(qImage.image_file);
		if(ext EQ "jpeg"){
			ext="jpg";
		}
		type="image/jpeg";
		if(ext EQ "png"){
			type="image/png";
		}else if(ext EQ "gif"){
			type="image/gif";
		} 
		if(qImage.image_approved EQ 0){
			if(arguments.returnJson){
				return {success:true, filePath:"/"&destination&newFileName };
			}else{
				application.zcore.functions.zheader("Content-Type", type);
				//content type="#type#" file="#request.zos.globals.privatehomedir&destination&newFileName#";
				if(cgi.SERVER_SOFTWARE EQ "" or cgi.SERVER_SOFTWARE CONTAINS "nginx"){
					application.zcore.functions.zXSendFile("/"&destination&newFileName);
				}else{
					application.zcore.functions.zXSendFile("#request.zos.globals.privatehomedir&destination&newFileName#"); 
				}
			}
		}else{
			if(arguments.returnJson){
				return {success:true, filePath:"/"&destination&newFileName };
			}else{
				application.zcore.functions.zheader("Content-Type","image/jpeg");
				if(cgi.SERVER_SOFTWARE EQ "" or cgi.SERVER_SOFTWARE CONTAINS "nginx"){
					application.zcore.functions.zXSendFile("/"&destination&newFileName);
				}else{
					application.zcore.functions.zXSendFile(request.zos.globals.privatehomedir&destination&newFileName);
				}
			}
		} 
	}  
	if(fileexists(request.zos.globals.privatehomedir&destination&qImage.image_file)){
		arrList = application.zcore.functions.zResizeImage(request.zos.globals.privatehomedir&destination&qImage.image_file,request.zos.globals.privatehomedir&destination,arguments.size,arguments.crop,true,newFileName); 
		if(isarray(arrList) EQ false){
			throw("Error: zcorerootmapping.com.app.image-library.cfc - getImageLink() failed because zResizeImage() failed.");
		}else if(ArrayLen(arrList) EQ 1){ 
			newFileName=arrList[1];
			ts=structnew();
			ts.datasource=request.zos.zcoreDatasource;
			ts.table="image_cache";
			ts.struct=structnew();
			ts.struct.site_id=request.zos.globals.id;
			ts.struct.image_cache_file=newFileName;
			// we had to use the arguments.size here instead of actual size, because images smaller then arguments.size would result in missing db entries
			ts.struct.image_cache_width		= arrSize[1];//request.arrLastImageWidth[1];
			ts.struct.image_cache_height	= arrSize[2];//request.arrLastImageHeight[1];

			ts.struct.image_cache_crop		= arguments.crop;
			ts.struct.image_library_id		= arguments.image_library_id;
			ts.struct.image_cache_deleted	= 0;
			ts.struct.image_id				= arguments.image_id;
			application.zcore.functions.zInsert(ts);  
			if(zdebug){
				writeoutput('image resized: /#destination&newFileName#<br /><img src="/#destination&newFileName#" />');
				application.zcore.functions.zabort();
			}
			ext=application.zcore.functions.zGetFileExt(qImage.image_file);
			if(ext EQ "jpeg"){
				ext="jpg";
			}
			type="image/jpeg";
			if(ext EQ "png"){
				type="image/png";
			}else if(ext EQ "gif"){
				type="image/gif";
			}
			if(qImage.image_approved EQ 0){
				tempPath=request.zos.globals.privatehomedir&destination&newFileName;
				application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath]=true;
			} 
			if(arguments.returnJson){
				return {success:true, filePath:"/"&destination&newFileName };
			}else{ 
				application.zcore.functions.zheader("Content-Type", type);
				if(cgi.SERVER_SOFTWARE EQ "" or cgi.SERVER_SOFTWARE CONTAINS "nginx"){
					application.zcore.functions.zXSendFile("/"&destination&newFileName);
				}else{
					application.zcore.functions.zXSendFile(request.zos.globals.privatehomedir&destination&newFileName);
				}
			}
		}else{
			throw("Error: zcorerootmapping.com.app.image-library.cfc - getImageLink() failed because zResizeImage() returned an unexpected value.");
		}
	}else{
		if(zdebug){
			writeoutput('404 original file on disk doesn''t exist: #request.zos.globals.privatehomedir&destination&qImage.image_file#<br>Show image not found: /z/a/listing/images/image-not-available.jpg<br />');
			application.zcore.functions.zabort();
		}
		if(arguments.returnJson){
			return {success:false, errorMessage:"Original file doesn't exist on disk." };
		}else{ 
			application.zcore.functions.zheader("Content-Type","image/jpeg");
			if(cgi.SERVER_SOFTWARE EQ "" or cgi.SERVER_SOFTWARE CONTAINS "nginx"){
				application.zcore.functions.zXSendFile("/z/a/listing/images/image-not-available.jpg");
			}else{
				application.zcore.functions.zXSendFile("#request.zos.zcoreRootPath#static/a/listing/images/image-not-available.jpg");
			}
		}
	}
	</cfscript>
</cffunction>

<!--- this.getLibraryById(image_library_id, newOnMissing); --->
<cffunction name="getLibraryById" localmode="modern" returntype="any" output="yes">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfargument name="newOnMissing" type="boolean" required="no" default="#true#">
	<cfscript>
	var qLibrary=0;
	var db=request.zos.queryObject;
	if(not structkeyexists(request.zos, 'imageLibraryIdQueryCache')){
		request.zos.imageLibraryIdQueryCache={};
	}
	if(structkeyexists(request.zos.imageLibraryIdQueryCache, arguments.image_library_id)){
		return request.zos.imageLibraryIdQueryCache[arguments.image_library_id];
	}else{
		db.sql="SELECT * FROM #db.table("image_library", request.zos.zcoreDatasource)# image_library 
		WHERE image_library_id = #db.param(arguments.image_library_id)# and 
		image_library_deleted = #db.param(0)# and 
		site_id =#db.param(request.zos.globals.id)#";
		qLibrary=db.execute("qLibrary");
		if(qLibrary.recordcount EQ 0){
			if(arguments.newOnMissing){
				arguments.image_library_id=this.getNewLibraryId();
				db.sql="SELECT * FROM #db.table("image_library", request.zos.zcoreDatasource)# image_library 
				WHERE image_library_id = #db.param(arguments.image_library_id)# and 
				image_library_deleted = #db.param(0)# and 
				site_id =#db.param(request.zos.globals.id)#";
				qLibrary=db.execute("qLibrary");
			}else{
				return false;
			}
		}
		request.zos.imageLibraryIdQueryCache[arguments.image_library_id]=qLibrary;
		return qLibrary;
	}
	</cfscript>
</cffunction>


<cffunction name="allowPublicEditingForImageLibraryId" localmode="modern">
	<cfargument name="image_library_id" type="numeric" required="yes">
	<cfscript>
	application.zcore.session.forceEnable();
	if(not structkeyexists(request.zsession, 'publicImageLibraryIdStruct')){
		request.zsession.publicImageLibraryIdStruct={};
	}
	request.zsession.publicImageLibraryIdStruct[arguments.image_library_id]=true;
	</cfscript>
</cffunction>
	
<!---  
// use this for "add" form action, but not for "edit" action
application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();

// image library form:
ts=structnew();
ts.name="image_library_id";
ts.value=image_library_id;
application.zcore.imageLibraryCom.getLibraryForm(ts); --->
<cffunction name="getLibraryForm" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	if(arguments.ss.value EQ "" or arguments.ss.value EQ "0"){
		image_library_id=0;
		qImageCount={count:0};
	}else{
		if(structkeyexists(arguments.ss, 'allowPublicEditing') and arguments.ss.allowPublicEditing){
			qLibrary=this.getLibraryById(arguments.ss.value);
			var image_library_id=qLibrary.image_library_id;
			if(not structkeyexists(request.zsession, 'publicImageLibraryIdStruct')){
				request.zsession.publicImageLibraryIdStruct={};
			}
			request.zsession.publicImageLibraryIdStruct[image_library_id]=true;	
		}else{
			if(not application.zcore.user.checkGroupAccess("user")){
				application.zcore.functions.z404("No access allow to image library when not logged in.");
			}
			qLibrary=this.getLibraryById(arguments.ss.value);
			var image_library_id=qLibrary.image_library_id;
		}
		db.sql="SELECT count(*) count from #db.table("image", request.zos.zcoreDatasource)# 
		WHERE image_library_id = #db.param(image_library_id)# and 
		image_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)# ";
		qImageCount=db.execute("qImageCount");
	}
	if(not structkeyexists(request, 'imageLibraryFieldIndex')){
		request.imageLibraryFieldIndex=0;
	}
	request.imageLibraryFieldIndex++;
	</cfscript>
	<input type="hidden" name="#arguments.ss.name#" id="zImageLibraryFieldId#request.imageLibraryFieldIndex#" value="#image_library_id#" />
	<strong style="font-size:120%;"><a href="##" onclick="zShowImageUploadWindow(document.getElementById('zImageLibraryFieldId#request.imageLibraryFieldIndex#').value, 'zImageLibraryFieldId#request.imageLibraryFieldIndex#', 'imageLibraryDivCount#request.imageLibraryFieldIndex#'); return false;">Open Image Uploader</a></strong>
	<div id="imageLibraryDivCount#request.imageLibraryFieldIndex#">#qImageCount.count# images in library</div>
</cffunction>


<!--- application.zcore.imageLibraryCom.saveImageId(); --->
<cffunction name="saveImageId" localmode="modern" access="remote" returntype="any" output="no">
	<cfscript>
	var ts=structnew(); 
	var s9=structnew();
	var newFileName='';
	var filePath='';
	var oldFileName='';
	var db=request.zos.queryObject; 
	if(not variables.hasAccessToImageLibraryId(form.image_library_id)){
		application.zcore.functions.z404("No access to image_library_id");	
	}

	var destination=request.zos.globals.privatehomedir&"zupload/library/"&form.image_library_id&"/";
	var qCheck=0;
	var oldFilePath="";
	var arrList=0;
	var ext=0;
	var clearcache=false;
	request.lastUploadFileName="";
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="image";
	s9.image_datetime=request.zos.mysqlnow;
	s9.image_updated_datetime=request.zos.mysqlnow;

	if(structkeyexists(form, 'image_caption')){
		s9.image_caption=form.image_caption;
	}else if(structkeyexists(form,'image_caption')){
		s9.image_caption=form.image_caption;
	}
	if(structkeyexists(form, 'image_id')){
		s9.image_id=form.image_id;
	}else if(structkeyexists(form,'image_id')){
		s9.image_id=form.image_id;
	}
	if(structkeyexists(form, 'image_library_id')){
		s9.image_library_id=form.image_library_id;
	}else if(structkeyexists(form,'image_library_id')){
		s9.image_library_id=form.image_library_id;
	} 
	qLibrary=this.getLibraryById(s9.image_library_id, false);
	form.image_approved=qLibrary.image_library_approved;
	
	if(structkeyexists(form, 'action') and form.action EQ "update"){
		db.sql="SELECT * FROM #db.table("image", request.zos.zcoreDatasource)# image 
		WHERE image_library_id = #db.param(s9.image_library_id)# and 
		image_id = #db.param(s9.image_id)# and 
		image_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#"; 
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - saveImageId() failed because image_id: #s9.image_id# doesn't exist.");
		}
		newFileName="";
		if(compare(qCheck.image_caption, s9.image_caption) NEQ 0){
			ext=lcase(application.zcore.functions.zGetFileExt(qCheck.image_file));
			if(ext EQ "jpeg"){
				ext="jpg";
			}
			newFileName=application.zcore.functions.zURLEncode(application.zcore.functions.zLimitStringLength(s9.image_caption, 70),'-')&"-"&s9.image_id&"."&ext;
			application.zcore.functions.zRenameFile(destination&qCheck.image_file, destination&newFileName);
			s9.image_file=newFileName;
			if(qCheck.image_intermediate_file NEQ ""){
				newFileName=application.zcore.functions.zURLEncode(application.zcore.functions.zLimitStringLength(s9.image_caption, 70),'-')&"-"&s9.image_id&"-int."&ext;
				application.zcore.functions.zRenameFile(destination&qCheck.image_intermediate_file, destination&newFileName);
				s9.image_intermediate_file=newFileName;
			}
			clearcache=true;
			
		}
		if(clearcache){
			this.clearImageIdCache(s9.image_id);
		}
		s9.site_id=request.zos.globals.id;
		ts.struct=s9;
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - saveImageId() failed to update the database.");
		}else{
			writeoutput('{success:"1"}');
			// return true;
		    }
		    application.zcore.functions.zabort();
	}else{
		oldFilePath="";
		db.sql="SELECT max(image_sort) maxsort FROM #db.table("image", request.zos.zcoreDatasource)# image 
		WHERE image_library_id = #db.param(s9.image_library_id)# and 
		image_deleted = #db.param(0)# and 
		site_id=#db.param(request.zos.globals.id)#"; 
		qCheck=db.execute("qCheck");
		s9.image_sort=1;
		if(qCheck.recordcount NEQ 0 and qCheck.maxsort NEQ ""){
			s9.image_sort=qCheck.maxsort+1;
		}
		if(application.zcore.functions.zso(form, 'skipSaveImageIdUpload', false, false) EQ false){
			if(structkeyexists(form, "image_file") and fileexists(form.image_file)){
				if(form.image_file CONTAINS getTempDirectory()){
					filePath=application.zcore.functions.zUploadFile("image_file", destination);
				}else{
					newFileName=getfilefrompath(form.image_file);
					filePath=destination&newFileName;
					ext=application.zcore.functions.zgetfileext(newFileName);
					if(ext EQ "jpeg"){
						ext="jpg";
					}
					curName=application.zcore.functions.zgetfilename(newFileName);
					offset=1;
					if(fileexists(filePath)){
						while(fileexists(filePath)){
							newFileName=curName&offset&"."&ext;
							filePath=destination&newFileName;
							offset++;
							if(offset GT 500){
								application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - saveImageId() failed. Too many similar files in directory - There is a limit of 500 loops until giving up.  Upload again with a unique file name.");
							}
						}
					}
					application.zcore.functions.zRenameFile(form.image_file, filePath);
					filePath=getfilefrompath(filePath);	
				}
				if(filePath EQ false){ 
					application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - saveImageId() failed to upload the image.");
				}
				oldFilePath=destination&filePath; 
				s9.image_file=filePath;
				local.imageSize=application.zcore.functions.zGetImageSize(oldFilePath);        
				if(local.imageSize.success){
					s9.image_latitude 		= local.imageSize.image_latitude;
	    			s9.image_longitude 		= local.imageSize.image_longitude;
	    			s9.image_altitude		= local.imageSize.image_altitude;
	    			s9.image_taken_datetime	= local.imageSize.image_taken_datetime;
				}
				/*
				writedump(form.image_file);
				writedump(destination&filePath);
				writedump(destination);
				abort;
				*/
			 	
				arrList = application.zcore.functions.zResizeImage(destination&s9.image_file,destination,"#request.zos.globals.maximagewidth#x2000",0); 

				if(isarray(arrList) EQ false){
					application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - saveImageId() failed because zResizeImage() failed.");
				}else if(ArrayLen(arrList) EQ 1){
					s9.image_intermediate_file=arrList[1];

				}
				
			}else{
				structdelete(form,'image_file');
			}
		}else{
			s9.image_file=form.image_file;
		}
		if(not structkeyexists(s9, 'image_file')){
			application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - saveImageId() failed to insert to database.");
		}
		local.imageSizeStruct=application.zcore.functions.zGetImageSize(destination&s9.image_file);    

    	if(not local.imageSizeStruct.success){
			throw(local.imageSizeStruct.errorMessage);
		}
		s9.image_width=local.imageSizeStruct.width;
		s9.image_height=local.imageSizeStruct.height;
		s9.site_id=request.zos.globals.id;
		ts.struct=s9;
		s9.image_id=application.zcore.functions.zInsert(ts);
		if(s9.image_id EQ false){
			application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - saveImageId() failed to insert to database.");
		}
		// only rename now if caption was set
		if(s9.image_caption NEQ "" and oldFilePath NEQ ""){
			ext=lcase(application.zcore.functions.zGetFileExt(oldFilePath));
			if(ext EQ "jpeg"){
				ext="jpg";
			}
			s9.image_file=application.zcore.functions.zURLEncode(application.zcore.functions.zLimitStringLength(s9.image_caption, 70),'-')&"-"&s9.image_id&"."&ext;
			application.zcore.functions.zRenameFile(oldFilePath,destination&s9.image_file); 
			db.sql="UPDATE #db.table("image", request.zos.zcoreDatasource)#  
			SET image_file = #db.param(s9.image_file)#,
			image_updated_datetime=#db.param(request.zos.mysqlnow)# 
			WHERE image_id = #db.param(s9.image_id)# and 
			image_deleted = #db.param(0)# and 
			site_id=#db.param(request.zos.globals.id)#";
			db.execute("q");
		}
		return s9.image_id;
	}
	</cfscript>
</cffunction>

    
<cffunction name="addImageToLibrary" localmode="modern" access="public" returntype="any" output="yes">
	<cfargument name="image_file" type="string" required="yes">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfargument name="image_caption" type="string" required="no" default="">
	<cfscript>
	form.image_file=arguments.image_file;
	form.image_caption=arguments.image_caption;
	form.image_library_id=arguments.image_library_id;
	form.disableImageProcessOutput=true;
	return this.imageprocessform();
    	</cfscript>
</cffunction>


<cffunction name="copyImageLibrary" localmode="modern" access="public" returntype="any" output="yes">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	if(not isnumeric(arguments.image_library_id)){
		application.zcore.functions.z404("Invalid image_library_id: #arguments.image_library_id#");
	}
	db.sql="select * from #db.table("image_library", request.zos.zcoreDatasource)# WHERE 
	image_library_id = #db.param(arguments.image_library_id)# and 
	image_library_deleted=#db.param(0)# and 
	site_id = #db.param(arguments.site_id)#";
	qLibrary=db.execute("qLibrary");
	for(row in qLibrary){
		row.image_library_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');
		structdelete(row, 'image_library_id');
		ts=structnew();
		ts.struct=row;
		ts.struct.image_library_hash=hash(application.zcore.functions.zGenerateStrongPassword(80,200), 'sha-256'); 
		ts.datasource=request.zos.zcoreDatasource;
		ts.table="image_library";
		newLibraryId=application.zcore.functions.zInsert(ts);

		oldPath=application.zcore.functions.zvar('privateHomedir', arguments.site_id)&'zupload/library/'&arguments.image_library_id&'/';
		path=application.zcore.functions.zvar('privateHomedir', arguments.site_id)&'zupload/library/'&newLibraryId&'/';
		application.zcore.functions.zcreatedirectory(path);

		db.sql="select * from #db.table("image", request.zos.zcoreDatasource)# WHERE 
		image_library_id = #db.param(arguments.image_library_id)# and 
		image_deleted=#db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		qImage=db.execute("qImage");
		for(row2 in qImage){
			structdelete(row2, 'image_id');
			row2.image_library_id=newLibraryId;
			newPath=application.zcore.functions.zcopyfile(oldPath&row2.image_file, path&row2.image_file, false);
			row2.image_file=getfilefrompath(newPath);  
			newPath=application.zcore.functions.zcopyfile(oldPath&row2.image_intermediate_file, path&row2.image_intermediate_file, false);
			row2.image_intermediate_file=getfilefrompath(newPath); 
			row2.image_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');
			ts=structnew();
			ts.struct=row2;
			ts.datasource=request.zos.zcoreDatasource;
			ts.table="image";
			newImageId=application.zcore.functions.zInsert(ts);
		}
		return newLibraryId;
	}
	return "0";
	</cfscript>
</cffunction>
	
<!--- /z/_com/app/image-library?method=imageprocessform --->
<cffunction name="imageprocessform" localmode="modern" access="remote" returntype="any" output="yes">
	<cfscript>
	var filePath='';
	var newFileName=''; 
	var t="";
	var ext="";
	var fileName="";
	var tPath="";
	var qDir="";
	var arrE="";
	var imagePath="";
	var offset="";
	var n2="";
	var cfcatch=0;
	var arrList="";
	var e=0;
	var currentDir="";
	var image_id=0;
	var arrErrors=[];
	var imageCount=0;
	var returnValue=0;
	var arrOut=arraynew(1); 

	setting requesttimeout="10000";
	form.disableImageProcessOutput=application.zcore.functions.zso(form, 'disableImageProcessOutput', false, false);
	form.image_caption=application.zcore.functions.zso(form, 'image_caption');
	form.image_file=application.zcore.functions.zso(form, 'image_file');
	form.image_library_id=application.zcore.functions.zso(form, 'image_library_id');
	if(not isnumeric(form.image_library_id)){
		application.zcore.functions.z404("Invalid image_library_id: #form.image_library_id#");
	}
	if(not variables.hasAccessToImageLibraryId(form.image_library_id)){
		if(form.disableImageProcessOutput){
			return {
				success:false,
				errorMessage:"No access to image_library_id"
			};
		}else{
			application.zcore.functions.z404("No access to image_library_id");	
		}
	}
	if(not fileexists(form.image_file)){
		if(form.disableImageProcessOutput){
			return {
				success:false,
				errorMessage:"Image file or image library id was not defined."
			};
		}else{
			writeoutput('Invalid Request.');
			application.zcore.functions.zabort();
		}
	}
	currentDir=request.zos.globals.privatehomedir&"zupload/library/"&form.image_library_id&"/";
	application.zcore.functions.zCreateDirectory(currentDir);
	//writeoutput('curdir:'&currentDir&'<br />');
	tempPath=request.zos.globals.serverprivatehomedir&'_cache/temp_files/';
	if(form.image_file CONTAINS getTempDirectory()){
		fileName = application.zcore.functions.zUploadFile("image_file", tempPath);
		ext=application.zcore.functions.zGetFileExt(filename); 
	}else{ 
		fileName=getfilefrompath(form.image_file);
		/*application.zcore.functions.zcreatedirectory(tempPath);
		var copyResult=application.zcore.functions.zCopyFile(form.image_file, tempPath&fileName, false);
		form.image_file=tempPath&fileName;
		if(copyResult EQ false){
			if(form.disableImageProcessOutput){
				return {
					success:false,
					errorMessage:"Failed to copy file"
				};
			}else{
				application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - imageprocessform() failed to copy file.");
			}
		}*/
		ext=application.zcore.functions.zGetFileExt(form.image_file); 
	}
	if(ext EQ 'zip'){
		if(fileName EQ false or left(fileName,6) EQ 'Error:'){
			if(form.disableImageProcessOutput){
				return {
					success:false,
					errorMessage:"Failed to upload zip file"
				};
			}else{
				application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - imageprocessform() failed to upload zip file.");
			}
		}
		t=dateformat(now(),'yyyymmdd')&timeformat(now(),'HHmmss')&"-"&hash(fileName);
		tPath=tempPath&t&'/';
		application.zcore.functions.zcreatedirectory(tPath);
		zip action="unzip" file="#tempPath&fileName#" storepath="no"  destination="#tPath#";
		
		application.zcore.functions.zdeletefile(tempPath&fileName);
		qDir=application.zcore.functions.zReadDirectory(tPath);
		if(isSimpleValue(qDir) and qDir EQ false){
			if(form.disableImageProcessOutput){
				return {
					success:false,
					errorMessage:"Failed to uncompress zip archive"
				};
			}else{
				application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - imageprocessform() failed to uncompress zip archive.");
			}
		} 
		for(row in qDir){
			if(row.name NEQ "." and row.name neq ".." and left(row.name,2) NEQ "._" and row.name NEQ ".DS_Store" and row.type EQ "file"){
				imagePath=tPath&row.name;
				ext=application.zcore.functions.zgetfileext(row.name);
				if(ext EQ 'gif' or ext EQ 'jpg' or ext EQ 'png' or ext EQ 'jpeg'){
					// don't resize or convert	a gif
					filePath=currentDir&row.name;
					newFileName=row.name;
					offset=1;
					if(fileexists(filePath)){
						while(fileexists(filePath)){
							newFileName=application.zcore.functions.zgetfilename(row.name)&offset&"."&application.zcore.functions.zgetfileext(row.name);
							filePath=currentDir&newFileName;
							offset++;
							if(offset GT 500){
								if(form.disableImageProcessOutput){
									return {
										success:false,
										errorMessage:"Too many similar files in directory - There is a limit of 500 loops until giving up.  Upload again with a unique file name."
									};
								}else{
									application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - imageprocessform() failed. Too many similar files in directory - There is a limit of 500 loops until giving up.  Upload again with a unique file name.");
								}
							}
						}
					}
					application.zcore.functions.zRenameFile(imagePath, filePath);
					form.image_file=newFileName;
					form.skipSaveImageIdUpload=true;
					form.action="insert";
					try{
						image_id=this.saveImageId();
						arrayappend(arrOut,'{"message":"Image saved with image id ###image_id#.","image_id":"#image_id#","image_link":"#application.zcore.imageLibraryCom.getImageLink(form.image_library_id, image_id, "200x128", "0", false, '', '', now())#"}');
					}catch(Any e){
						arrayappend(arrErrors,"Error Message: failed to save #newFileName#");
					}
					imageCount++;
				}
			}
		}
		application.zcore.functions.zdeletedirectory(tPath); 
		if(form.disableImageProcessOutput){
			return {
				success:false,
				errorMessage:"Failed to save image to database"
			};
		}else{
			if(structkeyexists(request, 'imageLibraryHTMLUpload')){
				application.zcore.status.setStatus(request.zsid, arraytoList(arrErrors, '<br />'));
			}else{
				errorString="";
				if(arraylen(arrErrors)){
					errorString=',"arrErrors":["'&arraytoList(arrErrors, '","')&'"]';
				}
				returnValue=('{"arrImages":['&arraytolist(arrOut,",")&']#errorString#}');
			}
		}
	}else if(ext EQ "jpg" or ext EQ "jpeg" or ext EQ "png" or ext EQ "gif"){
		form.action="insert";
		try{
			deletePath=tempPath&fileName;
			image_id=this.saveImageId();
			returnValue=('{"arrImages":[{"message":"Image saved with image id ###image_id#.","image_id":"#image_id#","image_link":"#application.zcore.imageLibraryCom.getImageLink(form.image_library_id, image_id, "200x128", "0", false, '', '', now())#"}]}'); 
			if(fileexists(deletePath)){
				application.zcore.functions.zdeletefile(deletePath);
			}
		}catch(Any e){
			if(fileexists(deletePath)){
				application.zcore.functions.zdeletefile(deletePath);
			}
			if(form.disableImageProcessOutput){
				return {
					success:false,
					errorMessage:"Failed to save image to database."
				};
			}else{
				if(request.zos.isTestServer or request.zos.isDeveloper){
					rethrow;
				}
				arrayappend(arrErrors,"Error Message: failed to save #request.lastUploadFileName#");
				if(structkeyexists(request, 'imageLibraryHTMLUpload')){
					application.zcore.status.setStatus(request.zsid, arraytoList(arrErrors, '<br />'));
				}else{
					errorString="";
					if(arraylen(arrErrors)){
						errorString=',"arrErrors":["'&arraytoList(arrErrors, '","')&'"]';
					}
					returnValue=('{"arrImages":[]#errorString#}');
				}
			}
		}
	}else{
		arrayappend(arrErrors,"Error Message: Invalid file type.");
		if(form.disableImageProcessOutput){
			return {
				success:false,
				errorMessage:"Image was an invalid file type"
			};
		}else{
			if(structkeyexists(request, 'imageLibraryHTMLUpload')){
				application.zcore.status.setStatus(request.zsid, arraytoList(arrErrors, '<br />'));
			}else{
				errorString="";
				if(arraylen(arrErrors)){
					errorString=',"arrErrors":["'&arraytoList(arrErrors, '","')&'"]';
				}
				returnValue=('{"arrImages":[]#errorString#}');
			}
		}
	}
	if(form.disableImageProcessOutput){
		return {
			success:true,
			errorMessage:""
		};
	}else{
		if(structkeyexists(request, 'imageLibraryHTMLUpload')){
			if(arraylen(arrErrors)){
				return false;
			}else{
				return true;
			}
		}else{
			writeoutput(returnValue);
			application.zcore.functions.zabort();
		}
	}
	</cfscript>
</cffunction>
    
    
<!--- 
ts=structnew();
ts.image_library_id;
ts.output=true;
ts.query=qImages;
ts.row=currentrow;
ts.size="250x160";
ts.crop=0;
ts.count = 1; // how many images to get
application.zcore.imageLibraryCom.displayImageFromSQL(ts);
 --->
<cffunction name="displayImageFromSQL" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qImages=0;
	var arrImageFile=0;
	var g2=0;
	var arrOutput=arraynew(1);
	var ts=structnew();
	var rs=structnew();
	var count=0;
	var arrId=arraynew(1);
	var arrCaption=arraynew(1);
	ts.output=true;
	ts.row=1;
	ts.crop=0;
	ts.size="#request.zos.globals.maximagewidth#x2000";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.query.imageIdList[arguments.ss.row] EQ ""){
		arguments.ss.count=0;
	}else{
		arguments.ss.count=min(arguments.ss.count,arraylen(listtoarray(arguments.ss.query.imageIdList[arguments.ss.row],chr(9),true)));
	}
	if(arguments.ss.count EQ 0){
		return arrOutput;
	}
	if(arguments.ss.image_library_id EQ 0){
		if(arguments.ss.output){
			return;
		}else{
			return arrOutput;
		}
	}
	application.zcore.imageLibraryCom.registerSize(arguments.ss.image_library_id, arguments.ss.size, arguments.ss.crop);
	if(arguments.ss.output){
		loop query="arguments.ss.query" startrow="#arguments.ss.row#" endrow="#arguments.ss.row#"{
			arrCaption=listtoarray(arguments.ss.query.imageCaptionList,chr(9),true);
			arrId=listtoarray(arguments.ss.query.imageIdList,chr(9),true);
			arrImageFile=listtoarray(arguments.ss.query.imageFileList,chr(9),true);
			arrApproved=listtoarray(arguments.ss.query.imageApprovedList, chr(9), true);
			arrUpdatedDate=listtoarray(arguments.ss.query.imageUpdatedDateList, chr(9), true);
			loop from="1" to="#arguments.ss.count#" index="g2"{
				if(arrApproved[g2] EQ 1){
					writeoutput('<img src="#application.zcore.imageLibraryCom.getImageLink(arguments.ss.image_library_id, arrId[g2], arguments.ss.size, arguments.ss.crop, true, arrCaption[g2], arrImageFile[g2], arrUpdatedDate[g])#" ');
					if(image_caption NEQ ""){
						writeoutput('alt="#htmleditformat(arrCaption[g2])#"');
					}
					echo('style="border:none;" />');
					if(arrCaption[g2] NEQ ""){
						echo('<br /><div style="padding-top:5px;">#arrCaption[g2]#</div>');
					}
					echo('<br /><br />');
				}
			}
		}
	}else{
		loop query="arguments.ss.query" startrow="#arguments.ss.row#" endrow="#arguments.ss.row#"{
			arrCaption=listtoarray(arguments.ss.query.imageCaptionList,chr(9),true);
			arrId=listtoarray(arguments.ss.query.imageIdList,chr(9),true);
			arrImageFile=listtoarray(arguments.ss.query.imageFileList,chr(9),true);
			arrApproved=listtoarray(arguments.ss.query.imageApprovedList, chr(9), true);
			arrImageUpdatedDate=listtoarray(arguments.ss.query.imageUpdatedDateList, chr(9), true);
			if(arraylen(arrCaption) EQ 0){ arrayappend(arrCaption,""); }
			if(arraylen(arrId) EQ 0){ arrayappend(arrId,""); }
			if(arraylen(arrImageFile) EQ 0){ arrayappend(arrImageFile,""); }
			if(arraylen(arrApproved) EQ 0){ arrayappend(arrApproved,""); }
			if(arraylen(arrImageUpdatedDate) EQ 0){ arrayappend(arrImageUpdatedDate, ""); }
			loop from="1" to="#arguments.ss.count#" index="g2"{
				if(arrApproved[g2] EQ 1){
					ts=structnew();
					ts.link=application.zcore.imageLibraryCom.getImageLink(arguments.ss.image_library_id, arrId[g2], arguments.ss.size, arguments.ss.crop, true, arrCaption[g2], arrImageFile[g2], arrImageUpdatedDate[g2]);
					ts.caption=arrCaption[g2];
					ts.id=arrId[g2];
					arrayappend(arrOutput,ts);
				}
			}
		}
		return arrOutput;
	}
	</cfscript>
</cffunction>

<!--- 
ts=structnew();
ts.image_library_id;
ts.output=true;
ts.struct={};
ts.size="250x160";
ts.crop=0;
ts.count = 1; // how many images to get
application.zcore.imageLibraryCom.displayImageFromSQL(ts);
 --->
<cffunction name="displayImageFromStruct" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qImages=0;
	var arrImageFile=0;
	var g2=0;
	var arrOutput=arraynew(1);
	var ts=structnew();
	var rs=structnew();
	var count=0;
	var arrId=arraynew(1);
	var arrCaption=arraynew(1);
	ts.output=true;
	ts.row=1;
	ts.crop=0;
	struct=arguments.ss.struct;
	ts.size="#request.zos.globals.maximagewidth#x2000";
	structappend(arguments.ss,ts,false);
	if(struct.imageIdList EQ ""){
		arguments.ss.count=0;
	}else{
		arguments.ss.count=min(arguments.ss.count,arraylen(listtoarray(struct.imageIdList,chr(9),true)));
	}
	if(arguments.ss.count EQ 0){
		return arrOutput;
	}
	if(arguments.ss.image_library_id EQ 0){
		if(arguments.ss.output){
			return;
		}else{
			return arrOutput;
		}
	}
	application.zcore.imageLibraryCom.registerSize(arguments.ss.image_library_id, arguments.ss.size, arguments.ss.crop);
	if(arguments.ss.output){
		arrCaption=listtoarray(struct.imageCaptionList,chr(9),true);
		arrId=listtoarray(struct.imageIdList,chr(9),true);
		arrImageFile=listtoarray(struct.imageFileList,chr(9),true);
		arrApproved=listtoarray(struct.imageApprovedList, chr(9), true);
		arrUpdatedDate=listtoarray(struct.imageUpdatedDateList, chr(9), true);
		loop from="1" to="#arguments.ss.count#" index="g2"{
			if(arrApproved[g2] EQ 1){
				writeoutput('<img src="#application.zcore.imageLibraryCom.getImageLink(arguments.ss.image_library_id, arrId[g2], arguments.ss.size, arguments.ss.crop, true, arrCaption[g2], arrImageFile[g2], arrUpdatedDate[g])#" ');
				if(image_caption NEQ ""){
					writeoutput('alt="#htmleditformat(arrCaption[g2])#"');
				}
				echo('style="border:none;" />');
				if(arrCaption[g2] NEQ ""){
					echo('<br /><div style="padding-top:5px;">#arrCaption[g2]#</div>');
				}
				echo('<br /><br />');
			}
		}
	}else{
		arrCaption=listtoarray(struct.imageCaptionList,chr(9),true);
		arrId=listtoarray(struct.imageIdList,chr(9),true);
		arrImageFile=listtoarray(struct.imageFileList,chr(9),true);
		arrApproved=listtoarray(struct.imageApprovedList, chr(9), true);
		arrImageUpdatedDate=listtoarray(struct.imageUpdatedDateList, chr(9), true);
		if(arraylen(arrCaption) EQ 0){ arrayappend(arrCaption,""); }
		if(arraylen(arrId) EQ 0){ arrayappend(arrId,""); }
		if(arraylen(arrImageFile) EQ 0){ arrayappend(arrImageFile,""); }
		if(arraylen(arrApproved) EQ 0){ arrayappend(arrApproved,""); }
		if(arraylen(arrImageUpdatedDate) EQ 0){ arrayappend(arrImageUpdatedDate, ""); }
		loop from="1" to="#arguments.ss.count#" index="g2"{
			if(arrApproved[g2] EQ 1){
				ts=structnew();
				ts.link=application.zcore.imageLibraryCom.getImageLink(arguments.ss.image_library_id, arrId[g2], arguments.ss.size, arguments.ss.crop, true, arrCaption[g2], arrImageFile[g2], arrImageUpdatedDate[g2]);
				ts.caption=arrCaption[g2];
				ts.id=arrId[g2];
				arrayappend(arrOutput,ts);
			}
		}
		return arrOutput;
	}
	</cfscript>
</cffunction>

<!--- 
// you must have a group by in your query or it may miss rows
ts=structnew();
ts.image_library_id_field="rental.rental_image_library_id";
ts.count = 1; // how many images to get
application.zcore.imageLibraryCom.getImageSQL(ts);
 --->
<cffunction name="getImageSQL" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	var arrOutput=arraynew(1);
	var ts=structnew();
	var rs=structnew(); 
	ts.image_library_id_field="";
	ts.count=1;
	structappend(arguments.ss,ts,false);
	ss=arguments.ss;
	if(structkeyexists(ss, 'db')){
		db=ss.db;
	}else{
		db=request.zos.queryObject;
	}
	if(not structkeyexists(request.zos, 'imageLibraryGetImageSQLIndex')){
		request.zos.imageLibraryGetImageSQLIndex=0;
	}
	request.zos.imageLibraryGetImageSQLIndex++;
	i=request.zos.imageLibraryGetImageSQLIndex;
	if(ss.image_library_id_field EQ ""){
		application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - displayImages() failed because ss.image_library_id_field is required.");	
	}
	rs.leftJoin="LEFT JOIN "&db.table("image", request.zos.zcoreDatasource)&" image#i# FORCE INDEX(`newIndex3`) ON 
	"&ss.image_library_id_field&" = image#i#.image_library_id and ";
	if(ss.count){
		rs.leftJoin&=" image#i#.image_sort <= '#application.zcore.functions.zescape(ss.count)#' and ";
	}
	rs.leftJoin&=" image#i#.site_id = '#application.zcore.functions.zescape(request.zos.globals.id)#' and 
	image#i#.image_deleted = 0 ";
	rs.select=", cast(GROUP_CONCAT(image#i#.image_id ORDER BY image#i#.image_sort SEPARATOR '\t') as char) imageIdList, 
	cast(GROUP_CONCAT(image#i#.image_caption ORDER BY image#i#.image_sort SEPARATOR '\t') as char) imageCaptionList, 
	cast(GROUP_CONCAT(image#i#.image_file ORDER BY image#i#.image_sort SEPARATOR '\t') as char) imageFileList, 
	cast(GROUP_CONCAT(image#i#.image_approved ORDER BY image#i#.image_sort SEPARATOR '\t') as char) imageApprovedList, 
	cast(GROUP_CONCAT(image#i#.image_updated_datetime ORDER BY image#i#.image_sort SEPARATOR '\t') as char) imageUpdatedDateList";
	return rs;
	</cfscript>
</cffunction>

<cffunction name="enableGalleryCaptions" localmode="modern" output="no" returntype="any">
	<cfscript>
	request.zos.forceImageGalleryCaptions=true;
	</cfscript>
</cffunction>

<!--- application.zcore.imageLibraryCom.getLayoutType(layout_type); --->
<cffunction name="getLayoutType" localmode="modern" output="no" returntype="any">
	<cfargument name="layout_type" type="string" required="yes">
	<cfscript>
	if(arguments.layout_type EQ ""){
		return "";	
	}else if(arguments.layout_type EQ "11"){
		return "galleryview-1.1";	
	}else if(arguments.layout_type EQ "10"){
		return "large-images-at-top";	
	}else if(arguments.layout_type EQ "1" or arguments.layout_type EQ "3"){
		return "galleryview-1.1";
	}else if(arguments.layout_type EQ "2" or arguments.layout_type EQ "4"){
		return "thumbnails-and-lightbox";
	}else if(arguments.layout_type EQ "5" or arguments.layout_type EQ "6"){
		return "contentflow";
	}else if(arguments.layout_type EQ "7"){
		return "thumbnail-left-and-other-photos";
	}else if(arguments.layout_type EQ "9"){
		return "thumbnail-right-and-other-photos";
	}else if(arguments.layout_type EQ "8"){
		return "custom";
	}else{
		return "";
	}
	</cfscript>
</cffunction>


<cffunction name="isAlwaysDisplayedLayoutType" localmode="modern" output="no" returntype="any">
	<cfargument name="layoutTypeId" type="string" required="yes">
	<cfscript>
	if(arguments.layoutTypeId EQ "7" or arguments.layoutTypeId EQ "9"){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<cffunction name="isBottomLayoutType" localmode="modern" output="no" returntype="any">
	<cfargument name="layoutTypeId" type="string" required="yes">
	<cfscript>
	if(arguments.layoutTypeId EQ "0" or arguments.layoutTypeId EQ "1" or arguments.layoutTypeId EQ "2" or arguments.layoutTypeId EQ "5"){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
	

<!--- 
ts=structnew();
ts.name="layout_type";
ts.value=layout_type;
application.zcore.imageLibraryCom.getLayoutTypeForm(ts); --->
<cffunction name="getLayoutTypeForm" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts= StructNew();
	ts.name = arguments.ss.name;
	ts.size = 1; // more for multiple select
	ts.output = true; // set to false to save to variable
	ts.hideSelect = true; // hide first element
	ts.selectedValues =  arguments.ss.value;
	ts.selectedDelimiter = ","; // change if comma conflicts...
	// options for list data
	ts.listLabels = "Large Photos At Bottom,Large Photos At Top,Gallery Slideshow At Bottom,Gallery Slideshow At Top,Gallery Slideshow At Right,Thumbnails and Lightbox At Bottom,Thumbnails and Lightbox At Top,ContentFlow At Bottom,ContentFlow At Top,Thumbnail On Top Left - Other Large Photos At Bottom,Thumbnail On Top Right - Other Large Photos At Bottom,Custom";
	ts.listValues = "0,10,1,3,11,2,4,5,6,7,9,8";
	ts.listLabelsDelimiter = ","; // tab delimiter
	ts.listValuesDelimiter = ",";
	
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript>
</cffunction>

<!--- 
ts=structnew();
ts.output=true;
ts.defaultAltText="Image";
ts.image_library_id=image_library_id;
ts.layoutType=""; // thumbnail-left-and-other-photos,thumbnail-right-and-other-photos,contentflow,thumbnails-and-lightbox,galleryview-1.1
ts.image_id = 0; // only use this if you want a specific image.
ts.size="#request.zos.globals.maximagewidth#x2000";
ts.pregenerate=false; // true will force all images to be resized before returning
ts.disableMouseWheel=false; // set to true to disable mousewheel for contentflow gallery.
ts.crop=0;
ts.offset=0;
ts.reverse=false; // true will sort them in the opposite direction
ts.limit=0; // zero will return all images
application.zcore.imageLibraryCom.displayImages(ts);
 --->
<cffunction name="displayImages" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var topMeta="";
	var arrT='';
	var thumbnailWidth='';
	var thumbnailHeight='';
	var newSize='';
	var newHeight='';
	var db=request.zos.queryObject;
	
	var theJS='';
	var qImages=0;
	var thumbnailCrop=0;
	var arrOutput=arraynew(1);
	var ts=structnew();
	ts.defaultAltText="Image";
	ts.pregenerate=false;
	ts.output=true;
	ts.slideshowTimeout=4000;
	ts.forceSize=false;
	ts.layoutType="";
	ts.top=false;
	ts.reverse=false;
	ts.size="#request.zos.globals.maximagewidth#x2000";
	ts.crop=0;
	//ts.thumbSize="110x60";
	ts.image_id="";
	ts.offset=0;
	ts.limit=0;
	ts.site_id=request.zos.globals.id;
	structappend(arguments.ss,ts,false);
	arrT=listtoarray(arguments.ss.size,"x");
	if(arguments.ss.layoutType EQ "custom"){
        request.zos.currentImageLibraryId=arguments.ss.image_library_id;
		if(arguments.ss.output){
			return;
		}else{
			return arrOutput;	
		}
    }
	if(arguments.ss.image_library_id EQ 0){
		if(arguments.ss.output){
			return;
		}else{
			return arrOutput;	
		}
	}
	if(isNumeric(arguments.ss.offset) EQ false){
		application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - displayImages() failed because arguments.ss.offset must be a number.");	
	}
	if(isNumeric(arguments.ss.limit) EQ false){
		application.zcore.template.fail("Error: zcorerootmapping.com.app.image-library.cfc - displayImages() failed because arguments.ss.limit must be a number.");	
	}
	</cfscript><cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("image", request.zos.zcoreDatasource)# image 
	WHERE image_library_id = #db.param(arguments.ss.image_library_id)#   
	<cfif not this.hasAccessToImageLibraryId(arguments.ss.image_library_id)>
		 and image_approved = #db.param(1)#  
	</cfif>
	<cfif arguments.ss.image_id NEQ ""> 
		and image_id=#db.param(arguments.ss.image_id)# 
	</cfif> 
	and site_id = #db.param(arguments.ss.site_id)# and 
	image_deleted = #db.param(0)#
	ORDER BY image_sort <cfif arguments.ss.reverse>DESC</cfif>, image_caption, image_id 
	<cfif arguments.ss.offset NEQ 0 or arguments.ss.limit NEQ 0>LIMIT #db.param(arguments.ss.offset)# 
		<cfif arguments.ss.limit NEQ 0>, #db.param(arguments.ss.limit)#<cfelse>,#db.param(1000)#</cfif>
	</cfif>
	</cfsavecontent><cfscript>
	qImages=db.execute("qImages", "", 10000, "query", false);
	if(qImages.recordcount EQ 0){
		if(arguments.ss.output){
			return;
		}else{
			return arrOutput;	
		}
	}
	if(arguments.ss.layoutType EQ "large-images-at-top"){
		if(arguments.ss.top){
			arguments.ss.layoutType="";
		}else{
			if(arguments.ss.output){
				return;
			}else{
				return [];
			}
		}
	}else if((arguments.ss.layoutType EQ "thumbnail-left-and-other-photos" or arguments.ss.layoutType EQ "thumbnail-right-and-other-photos") and not arguments.ss.top){
		arguments.ss.layoutType="";
	}
	</cfscript>
	<cfif arguments.ss.output>
		<cfif arguments.ss.layoutType EQ "thumbnail-left-and-other-photos" or arguments.ss.layoutType EQ "thumbnail-right-and-other-photos">
			<cfscript>
			application.zcore.app.getAppCFC("content").setRequestThumbnailSize(0,0,0);
			
			if(structkeyexists(request.zos, 'thumbnailSizeStruct')){ 
				thumbnailWidth=request.zos.thumbnailSizeStruct.width;
				thumbnailHeight=request.zos.thumbnailSizeStruct.height;
				thumbnailCrop=request.zos.thumbnailSizeStruct.crop;
			}else{
				if(arguments.ss.forceSize){
					thumbnailWidth=round(arrT[1]/2); 
					thumbnailHeight=round((arrT[2]/2)*.6);
				}else{
					thumbnailWidth=round(960/2);
					thumbnailHeight=round((960/2)*.6);
				}
			}
			thumbnailWidth*=2;
			thumbnailHeight*=2; 
			</cfscript>
			<cfloop query="qImages" startrow="1" endrow="1">
				<cfif arguments.ss.layoutType EQ "thumbnail-right-and-other-photos">
					<div class="zImageLibraryImageRight" style="width:#thumbnailWidth/1.5#px;">
				<cfelse>
					<div class="zImageLibraryImageLeft" style="width:#thumbnailWidth/1.5#px;">
				</cfif>
					<cfscript>
					caption=qImages.image_caption;
					if(caption EQ ""){
						caption=arguments.ss.defaultAltText;
					}
					</cfscript>
					<img class="content z-fluid" alt="#htmleditformat(caption)#" src="#application.zcore.imageLibraryCom.getImageLink(qImages.image_library_id, qImages.image_id, thumbnailWidth&"x"&thumbnailHeight, arguments.ss.crop, true, qImages.image_caption, qImages.image_file, qImages.image_updated_datetime, arguments.ss.pregenerate)#" data-lat="#qImages.image_latitude#" data-lon="#qImages.image_longitude#" data-altitude="#qImages.image_altitude#" data-date_taken="#DateFormat(qImages.image_taken_datetime,'mm/dd/yyyy')#" />
				</div>
			</cfloop>
		<cfelseif arguments.ss.layoutType EQ "contentflow">
			<cfscript>
			application.zcore.functions.zRequireContentFlowSlideshow();
			
			if(arguments.ss.forceSize){
				thumbnailWidth=round(arrT[1]/2);
				thumbnailHeight=round((arrT[2]/2)*.6);
			}else{
				thumbnailWidth=round(request.zos.globals.maximagewidth/2);
				thumbnailHeight=round((request.zos.globals.maximagewidth/2)*.6);
			}
			newSize=thumbnailWidth&"x"&thumbnailHeight;
			application.zcore.imageLibraryCom.registerSize(arguments.ss.image_library_id, newSize, arguments.ss.crop);
			</cfscript> 

			<div id="contentFlow#qImages.image_library_id#" class="ContentFlow">
				<div class="loadIndicator">
					<div class="indicator"></div>
				</div>
				<div class="flow">
					<cfloop query="qImages">
						<cfscript>
						caption=qImages.image_caption;
						if(caption EQ ""){
							caption=arguments.ss.defaultAltText;
						}
						</cfscript>
						<div class="item">
							<img class="content" alt="#htmleditformat(caption)#" src="#application.zcore.imageLibraryCom.getImageLink(qImages.image_library_id, qImages.image_id, thumbnailWidth&"x"&thumbnailHeight, arguments.ss.crop, true, qImages.image_caption, qImages.image_file, qImages.image_updated_datetime, arguments.ss.pregenerate)#"  data-lat="#qImages.image_latitude#" data-lon="#qImages.image_longitude#" data-altitude="#qImages.image_altitude#" data-date_taken="#DateFormat(qImages.image_taken_datetime,'mm/dd/yyyy')#" />
							<div class="caption">#htmleditformat(qImages.image_caption)#</div>
						</div>
					</cfloop>
				</div>
				<div class="globalCaption"></div>
			</div>
		    <script> 
			var myContentFlow#qImages.image_library_id# = new ContentFlow('contentFlow#qImages.image_library_id#', {
				circularFlow: true,
				loadingTimeout: 60000,
				scaleFactor:1.5

				<cfif application.zcore.functions.zso(arguments.ss, 'disableMouseWheel', false, false)>
					, scrollWheelSpeed :0
				</cfif>
			});
			zArrDeferredFunctions.push(function() {
				setTimeout(function(){
					if($("##contentFlow#qImages.image_library_id#").length != 0){
						function go_to_next_and_wait() {
							setTimeout(function() {
								myContentFlow#qImages.image_library_id#.moveTo('right');
								go_to_next_and_wait();
							}, #arguments.ss.slideshowTimeout#); // 5000ms = 5 seconds
						}
						go_to_next_and_wait();
						myContentFlow#qImages.image_library_id#.moveTo('right');
					}
				}, #arguments.ss.slideshowTimeout#); 
			});
		    </script>

		<cfelseif arguments.ss.layoutType EQ "thumbnails-and-lightbox">
			<cfsavecontent variable="topMeta">
	    
			<cfif structkeyexists(request,'zGalleryThumbnailLightboxIndex') EQ false>
				<cfset request.zGalleryThumbnailLightboxIndex=1>
				<cfscript>
				application.zcore.skin.includeJS("/z/javascript/Magnific-Popup/jquery.magnific-popup.min.js");
				application.zcore.skin.includeCSS("/z/javascript/Magnific-Popup/magnific-popup.css");
				</cfscript>
				<style>
				/* <![CDATA[ */ 
				.mfp-gallery{z-index:20001;}
				.mfp-bg{z-index:20000;}
				
				##zThumbnailLightgallery ul *{box-sizing:border-box;}
				##zThumbnailLightgallery ul {  width:100%; text-align:center; display:block; list-style: none; margin:0px !important; padding:0px !important; }
				##zThumbnailLightgallery ul li {  min-width:150px; width:32.8%; background-image:none !important; list-style:none !important; display: inline-block; margin:0px; padding:0px;}
				
				##zThumbnailLightgallery ul a {
				display:block; float:left;
				text-align:center;
				width:100%;
				margin-right:10px;
				margin-bottom:10px;
				}
				##zThumbnailLightgallery ul img {
				padding:4px;
				background-color:##FFF;
				max-width:100%;
				border: 1px solid ##DFDFDF; 
				}
				##zThumbnailLightgallery ul a:hover img {
				background-color:##000;
				border: 1px solid ##DFDFDF;  
				color: ##fff;
				}
				##zThumbnailLightgallery ul a:hover { color: ##fff; }

				.mfp-with-zoom .mfp-container,
				.mfp-with-zoom.mfp-bg {
				  opacity: 0;
				  -webkit-backface-visibility: hidden;
				  /* ideally, transition speed should match zoom duration */
				  -webkit-transition: all 0.3s ease-out; 
				  -moz-transition: all 0.3s ease-out; 
				  -o-transition: all 0.3s ease-out; 
				  transition: all 0.3s ease-out;
				}

				.mfp-with-zoom.mfp-ready .mfp-container {
				    opacity: 1;
				}
				.mfp-with-zoom.mfp-ready.mfp-bg {
				    opacity: 0.8;
				}

				.mfp-with-zoom.mfp-removing .mfp-container, 
				.mfp-with-zoom.mfp-removing.mfp-bg {
				  opacity: 0;
				}
				@media only screen and (max-width: 767px) { 
					##zThumbnailLightgallery ul li { min-width:250px; width:33.3%; }
				}
				 /* ]]> */
				</style>
				</cfif>
				<script>
				/* <![CDATA[ */ zArrDeferredFunctions.push(function(){

					/*$('##zThumbnailLightgallery').magnificPopup({
						type: 'image',
						closeOnContentClick: true,
						image: {
							verticalFit: false
						}
					});*/
					$('##zThumbnailLightgallery').magnificPopup({
						delegate: 'a',
						type: 'image',
						tLoading: 'Loading image ##%curr%...',
						mainClass: 'mfp-no-margins mfp-with-zoom mfp-fade zThumbnailLightboxPopupDiv',
						closeBtnInside: false,
						fixedContentPos: true,
						/*retina:{
							ratio:2,
							replaceSrc: function(item, ratio) {
								return item.el.attr("data-2x-image");
						      //return item.src.replace(/\.\w+$/, function(m) { return '@2x' + m; });
						    } // function that changes image source
						    
						},*/
						gallery: {
							enabled: true,
							navigateByImgClick: true,
							preload: [0,1] // Will preload 0 - before current, and 1 after the current image
						},
						image: {
							//verticalFit:false,
							tError: '<a href="%url%">The image ##%curr%</a> could not be loaded.',
							titleSrc: function(item) {
								return item.el.attr('title');
							}
						},
						zoom: {
							enabled: true, // By default it's false, so don't forget to enable it

							duration: 300, // duration of the effect, in milliseconds
							easing: 'ease-in-out', // CSS transition easing function 

							// The "opener" function should return the element from which popup will be zoomed in
							// and to which popup will be scaled down
							// By defailt it looks for an image tag:
							opener: function(openerElement) {
								// openerElement is the element on which popup was initialized, in this case its <a> tag
								// you don't need to add "opener" option if this code matches your needs, it's defailt one.
								return openerElement.is('img') ? openerElement : openerElement.find('img');
							}
						}
					});
				}); /* ]]> */
				</script>
				</cfsavecontent>
				<cfscript>
				application.zcore.functions.zRequireJQuery();
				application.zcore.template.appendTag("meta",topMeta);
				arrT=listtoarray(arguments.ss.size,"x");
				if(structkeyexists(arguments.ss, 'thumbSize')){
					arrT=listtoarray(arguments.ss.thumbSize,"x");
					thumbnailWidth=arrT[1];
					thumbnailHeight=arrT[2]; 
				}else{ 
					thumbnailWidth=round((arrT[1]-(3*15))/3);
					thumbnailHeight=round(thumbnailWidth*.6);
				}
				application.zcore.imageLibraryCom.registerSize(arguments.ss.image_library_id, thumbnailWidth&"x"&thumbnailHeight, 1);
				/*newSize="500x300";//arrT[1]&"x"&round(arrT[1]*.6);
				newHeight=round(arrT[1]*.6);
				application.zcore.imageLibraryCom.registerSize(arguments.ss.image_library_id, newSize, arguments.ss.crop);*/
				newSize="1900x1080";//arrT[1]&"x"&round(arrT[1]*.6); 
				application.zcore.imageLibraryCom.registerSize(arguments.ss.image_library_id, newSize, arguments.ss.crop);
				</cfscript>
		
				<div id="zThumbnailLightgallery">
				    <ul>
					<cfloop query="qImages">

						<cfscript>
						caption=qImages.image_caption;
						if(caption EQ ""){
							caption=arguments.ss.defaultAltText;
						}
						</cfscript>
						<li><a class="zNoContentTransition"
					 href="#application.zcore.imageLibraryCom.getImageLink(qImages.image_library_id, qImages.image_id, newSize, arguments.ss.crop, true, qImages.image_caption, qImages.image_file, qImages.image_updated_datetime, arguments.ss.pregenerate)#"
					 
					  title="#htmleditformat(caption)#"><img src="#application.zcore.imageLibraryCom.getImageLink(qImages.image_library_id, qImages.image_id, thumbnailWidth&"x"&thumbnailHeight, arguments.ss.crop, true, qImages.image_caption, qImages.image_file, qImages.image_updated_datetime, arguments.ss.pregenerate)#" alt="#htmleditformat(caption)#"  data-lat="#qImages.image_latitude#" data-lon="#qImages.image_longitude#" data-altitude="#qImages.image_altitude#" data-date_taken="#DateFormat(qImages.image_taken_datetime,'mm/dd/yyyy')#" /></a></li>
					</cfloop>
					  <!---  data-2x-image="#application.zcore.imageLibraryCom.getImageLink(qImages.image_library_id, qImages.image_id, newSize2, arguments.ss.crop, true, qImages.image_caption, qImages.image_file, qImages.image_updated_datetime, arguments.ss.pregenerate)#"  --->
				    </ul>
				</div>

		<cfelseif arguments.ss.layoutType EQ "galleryview-1.1">
			<cfsavecontent variable="topMeta">
				<cfif structkeyexists(request,'zGalleryViewSlideShowIndex') EQ false>
					<cfset request.zGalleryViewSlideShowIndex=1>
					<cfif structkeyexists(form, 'zajaxdownloadcontent') EQ false>
						#application.zcore.skin.includeCSS("/z/javascript/jquery/galleryview-1.1/jquery.galleryview-3.0-dev.css")#
						#application.zcore.skin.includeJS("/z/javascript/jquery/jquery.easing.1.3.js")#
						#application.zcore.skin.includeJS("/z/javascript/jquery/galleryview-1.1/jquery.galleryview-3.0-dev.js")#
						#application.zcore.skin.includeJS("/z/javascript/jquery/galleryview-1.1/jquery.timers-1.2.js")#
					</cfif>
				<cfelse>
					<cfscript>request.zGalleryViewSlideShowIndex++;</cfscript>
				</cfif>
			</cfsavecontent>
			<cfscript>
			
			application.zcore.template.appendTag("meta",topMeta); 
			application.zcore.functions.zRequireJQuery();
			application.zcore.imageLibraryCom.registerSize(arguments.ss.image_library_id, '160x80', 1);
			// arrT=listtoarray(arguments.ss.size,"x");
			// newSize=arrT[1]&"x"&round(arrT[1]*.6);
			// newHeight=round(arrT[1]*.6);
			application.zcore.imageLibraryCom.registerSize(arguments.ss.image_library_id, arguments.ss.size, arguments.ss.crop);
			hasCaptions=false;
			</cfscript> 
			<div class="z-center-children z-float">
				<div class="zGalleryViewSlideshowContainer" style="width:auto;">
					<ul id="zGalleryViewSlideshow#request.zGalleryViewSlideShowIndex#" class="zGalleryViewSlideshow">
					<cfloop query="qImages">
						<cfscript>
						caption=qImages.image_caption;
						if(caption EQ ""){
							caption=arguments.ss.defaultAltText;
						}
						</cfscript>
						<li><img data-frame="#application.zcore.imageLibraryCom.getImageLink(qImages.image_library_id, qImages.image_id, '160x80', 1, true, qImages.image_caption, qImages.image_file, qImages.image_updated_datetime, arguments.ss.pregenerate)#" src="#application.zcore.imageLibraryCom.getImageLink(qImages.image_library_id, qImages.image_id, arguments.ss.size, arguments.ss.crop, true, qImages.image_caption, qImages.image_file, qImages.image_updated_datetime, arguments.ss.pregenerate)#"  <cfif qImages.image_caption NEQ ""><cfset hasCaptions=true>alt="#htmleditformat(caption)#" title="#htmleditformat(caption)#"<cfelse>alt="#caption#" title=""</cfif> data-description="" /></li>
					</cfloop>
					</ul> 
				</div>
			</div>
			<script>
				var arrImages = {};
				zArrDeferredFunctions.push( function() {
					console.log($('window'));
					/*for(var x in $('window')){
						if(x.indexOf("gal") != -1){
							alert(x);
						}
					}
					*/
					//alert(window.galleryView);
				});
				<cfloop query="qImages">
					arrImages["#qImages.image_id#"] = {lat:"#qImages.image_latitude#", lon:"#qImages.image_longitude#", altitude:"#qImages.image_altitude#", taken:"#DateFormat(qImages.image_taken_datetime,'mm/dd/yyyy')#"}; 
				</cfloop>
			</script>  

			<cfsavecontent variable="theJS">
				{ 
				pause_on_hover: true,
				transition_speed: 1000, 		//INT - duration of panel/frame transition (in milliseconds)
				transition_interval: #arguments.ss.slideshowTimeout#, 		//INT - delay between panel/frame transitions (in milliseconds)
				easing: 'swing', 				//STRING - easing method to use for animations (jQuery provides 'swing' or 'linear', more available with jQuery UI or Easing plugin)
			
			<cfif arguments.ss.forceSize>
				panel_width: #arrT[1]#,
				panel_height: #arrT[2]#,
			<cfelse>
				panel_width: #request.zos.globals.maximagewidth#, 				//INT - width of gallery panel (in pixels)
				panel_height: #round(request.zos.globals.maximagewidth*.6)+45#, 				//INT - height of gallery panel (in pixels)
			</cfif> 
			panel_animation: 'crossfade', 		//STRING - animation method for panel transitions (crossfade,fade,slide,none)
			panel_scale: 'fit', 			//STRING - cropping option for panel images (crop = scale image and fit to aspect ratio determined by panel_width and panel_height, fit = scale image and preserve original aspect ratio)
			overlay_position: 'bottom', 	//STRING - position of panel overlay (bottom, top)
			pan_images: true,				//BOOLEAN - flag to allow user to grab/drag oversized images within gallery
			pan_style: 'track',				//STRING - panning method (drag = user clicks and drags image to pan, track = image automatically pans based on mouse position
			pan_smoothness: 15,				//INT - determines smoothness of tracking pan animation (higher number = smoother)
			start_frame: 1, 				//INT - index of panel/frame to show first when gallery loads
			show_filmstrip: true, 			//BOOLEAN - flag to show or hide filmstrip portion of gallery
			show_filmstrip_nav: true, 		//BOOLEAN - flag indicating whether to display navigation buttons
			enable_slideshow: true,			//BOOLEAN - flag indicating whether to display slideshow play/pause button
			autoplay: <cfif structkeyexists(arguments.ss, 'autoplay')>#arguments.ss.autoplay#<cfelse>true</cfif>,				//BOOLEAN - flag to start slideshow on gallery load
			<cfif hasCaptions and ((structkeyexists(arguments.ss, 'showCaptions') and arguments.ss.showCaptions) or structkeyexists(request.zos, 'forceImageGalleryCaptions'))>
		     enable_overlays: true,
		    </cfif>
			show_captions: <cfif hasCaptions and ((structkeyexists(arguments.ss, 'showCaptions') and arguments.ss.showCaptions) or structkeyexists(request.zos, 'forceImageGalleryCaptions'))>true<cfelse>false</cfif>, 			//BOOLEAN - flag to show or hide frame captions	
			filmstrip_size: 3, 				//INT - number of frames to show in filmstrip-only gallery
			filmstrip_style: 'scroll', 		//STRING - type of filmstrip to use (scroll = display one line of frames, scroll filmstrip if necessary, showall = display multiple rows of frames if necessary)
			filmstrip_position: 'bottom', 	//STRING - position of filmstrip within gallery (bottom, top, left, right)
			<cfif arguments.ss.forceSize>
				<cfscript>
				if(not structkeyexists(arguments.ss, 'thumbSize')){
					arguments.ss.thumbSize="110x60";
				}
				local.arrT2=listToArray(arguments.ss.thumbSize, 'x');
				</cfscript>
				frame_width: #local.arrT2[1]#, 
				frame_height: #local.arrT2[2]#, 
			<cfelse>
			frame_width: 110, 				//INT - width of filmstrip frames (in pixels)
			frame_height: 60, 				//INT - width of filmstrip frames (in pixels)
			</cfif>
			frame_opacity: 0.5, 			//FLOAT - transparency of non-active frames (1.0 = opaque, 0.0 = transparent)
			frame_scale: 'crop', 			//STRING - cropping option for filmstrip images (same as above)
			frame_gap: 5, 					//INT - spacing between frames within filmstrip (in pixels)
			show_infobar: false,				//BOOLEAN - flag to show or hide infobar
			infobar_opacity: 0.7				//FLOAT - transparency for info bar
			}
			</cfsavecontent>
			<input type="hidden" name="zGalleryViewSlideshow#request.zGalleryViewSlideShowIndex#_data" id="zGalleryViewSlideshow#request.zGalleryViewSlideShowIndex#_data" value="#htmleditformat(theJS)#" />
		<cfelse>
		    <cfscript>
			application.zcore.imageLibraryCom.registerSize(arguments.ss.image_library_id, arguments.ss.size, arguments.ss.crop);
			</cfscript>
			<cfloop query="qImages">

				<cfscript>
				caption=qImages.image_caption;
				if(caption EQ ""){
					caption=arguments.ss.defaultAltText;
				}
				</cfscript>
				<img src="#application.zcore.imageLibraryCom.getImageLink(qImages.image_library_id, qImages.image_id, arguments.ss.size, arguments.ss.crop, true, qImages.image_caption, qImages.image_file, qImages.image_updated_datetime, arguments.ss.pregenerate)#" alt="#htmleditformat(caption)#" style="border:none;"  data-lat="#qImages.image_latitude#" data-lon="#qImages.image_longitude#" data-altitude="#qImages.image_altitude#" data-date_taken="#DateFormat(qImages.image_taken_datetime,'mm/dd/yyyy')#" />
				<cfif qImages.image_caption NEQ ""><br /><div style="padding-top:5px;">#qImages.image_caption#</div></cfif><!--- <hr class="zdisplayimageshr" /> ---><br />
			</cfloop>
	    </cfif>
	<cfelse>
		<cfloop query="qImages">
			<cfscript>
			ts=structnew();
			ts.link=application.zcore.imageLibraryCom.getImageLink(qImages.image_library_id, qImages.image_id, arguments.ss.size, arguments.ss.crop, true, qImages.image_caption, qImages.image_file, qImages.image_updated_datetime, arguments.ss.pregenerate); 
			ts.caption=qImages.image_caption;
			if(ts.caption EQ ""){
				ts.caption=arguments.ss.defaultAltText;
			} 
			ts.originalLink="/zupload/library/"&qImages.image_library_id&"/"&qImages.image_file;
			ts.id=qImages.image_id;
			ts.file=qImages.image_file;
			ts.updatedDatetime=qImages.image_updated_datetime;
			arrayappend(arrOutput,ts);
			</cfscript>
		</cfloop>
		<cfscript>return arrOutput;</cfscript>
	</cfif>
</cffunction>

<!--- /z/_com/app/image-library?method=imageform --->
<cffunction name="imageform" localmode="modern" access="remote" returntype="any" output="yes">
	<cfscript>
	var db=request.zos.queryObject;
	
	var qImages=0;
	var r=0;
	var theMeta=0;
	setting requesttimeout="3600";
	application.zcore.template.setTag("title", "Image Library");
	form.image_library_id=application.zcore.functions.zso(form, 'image_library_id');
	tempId=form.image_library_id;
	if(form.image_library_id NEQ "" and not isnumeric(form.image_library_id)){
		application.zcore.functions.z404("Invalid request");
	}

	var qLibrary=this.getLibraryById(form.image_library_id);
	var i=0;
	var cffileresult=0;
	var rd=gethttprequestdata();
	form.image_library_id=qLibrary.image_library_id;
	if(tempId EQ 0){
		allowPublicEditingForImageLibraryId(form.image_library_id);
	}
	form.fieldId=application.zcore.functions.zso(form, 'fieldId');
	
	if(not variables.hasAccessToImageLibraryId(form.image_library_id)){
		application.zcore.functions.z404("No access to image_library_id");	
	}
	if(application.zcore.user.checkGroupAccess("member")){
		application.zcore.functions.zSetPageHelpId("2.9");
		request.zos.inMemberArea=true; 
	}
	//if(structkeyexists(form, 'image_file') and form.image_file NEQ ""){
		request.imageLibraryHTMLUpload=true;
		local.failed=false;
		/*if(not isArray(form.image_file) or fileexists(form.image_file)){
			r=this.imageprocessform();
			if(not r){
				local.failed=true;
			}
		}else{*/
	tempPath=request.zos.globals.serverprivatehomedir&'_cache/temp_files/';
	application.zcore.functions.zcreatedirectory(tempPath);
	if(structkeyexists(form, 'imagefiles') and form.imagefiles NEQ ""){
		// patched cfml server to support multiple file uploads
		file action="uploadAll" result="cffileresult" destination="#tempPath#" nameconflict="makeunique" filefield="imagefiles" charset="utf-8";

		arrFile=[];
		for(n=1;n LTE arraylen(cffileresult);n++){
			arrayAppend(arrFile, cffileresult[n].serverDirectory&"/"&cffileresult[n].clientfile);
		}
		arraySort(arrFile, "text", "asc");
		for(n=1;n LTE arraylen(arrFile);n++){
			form.image_file=arrFile[n];
			r=this.imageprocessform();
			if(not r){
				local.failed=true;
			}
		}
		if(not local.failed){
			application.zcore.status.setStatus(request.zsid, "Upload successful");
		}
		application.zcore.functions.zStatusHandler(request.zsid);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?method=imageform&image_library_id=#form.image_library_id#&zsid=#request.zsid#");
	}
	application.zcore.functions.zStatusHandler(request.zsid);
	application.zcore.imageLibraryCom.registerSize(form.image_library_id, "200x128", "0");
	
	application.zcore.functions.zSetModalWindow();
	application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);
	
	application.zcore.functions.zRequireJquery();
	application.zcore.functions.zRequireJqueryUI();
	db.sql="SELECT * FROM #db.table("image", request.zos.zcoreDatasource)# image 
		WHERE image_library_id = #db.param(form.image_library_id)# and 
		image_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# 
		ORDER BY image_sort, image_caption, image_id";
	qImages=db.execute("qImages", "", 10000, "query", false);
	</cfscript>
	<cfsavecontent variable="theMeta">
	#application.zcore.skin.includeCSS("/z/a/stylesheets/style.css")#
	<script>
	/* <![CDATA[ */
	var debugImageLibrary=false; 
	zArrDeferredFunctions.push(function() { 

		$( "##sortable" ).sortable({
			cancel:".captionbar",
			start: function(event, ui) {
				imageSortingStarted=true;
				imageSortingChanged=false;
			},
			stop: function(event, ui) {
				var image_id=ui.item[0].id.substr(5);
			    toggleImageCaptionUpdate("imagecaptionupdate"+image_id,'none',true);
				if(debugImageLibrary) document.getElementById("forimagedata").value+="sortable stopped.\n";
				if(imageSortingStarted && imageSortingChanged){
					imageSortingChanged=false;
					imageSortingStarted=false; 
					if(debugImageLibrary) document.getElementById("forimagedata").value+=("I moved from "+ui.originalPosition+" to "+ui.position+" - updating via ajax!\n");
					ajaxSaveSorting();
			   }
			   
			},
			change: function(event, ui) {
				if(debugImageLibrary) document.getElementById("forimagedata").value+="sortable changed.\n";
				imageSortingChanged=true;
			}
		});
		var f='#form.fieldId#';
		if(f != ""){
			var field=window.parent.document.getElementById(f);
			if(typeof field != "undefined"){
				field.value="#form.image_library_id#";
			}
		}
		zUpdateImageLibraryCount();
	});
	 /* ]]> */
	</script>
	<cfscript>application.zcore.template.appendTag("stylesheets",'<style>
	/* <![CDATA[ */
	##sortable { list-style-type: none; margin: 0; padding: 0; }
	##sortable li, .sortableli { margin-right:10px; margin-bottom:10px; padding: 5px; height:168px; float: left; }
	##sortable .captionbar{padding-top:8px; text-align:left;}
	##sortable .captionClass{width:141px; height:20px;padding:3px; font-size:10px; float:left; }
	##sortable .imagedivclass{margin-top:-25px; width:200px; height:128px; text-align:center; z-index:2;}
	##sortable .ui-state-default{cursor:move;}
	##sortable .imageclosebutton{ text-align:center; position:relative; cursor:pointer; top:0px; left:175px; z-index:3; height:25px; width:25px; padding:5px; background-color:##000; color:##FFF;}
	##sortable .imagecaptionupdate{display:none; cursor:pointer;float:left;border:1px solid ##CCC; font-size:10px; margin-left:5px; font-weight:bold; padding:3px; line-height:14px;}
	/* ]]> */
	</style>');</cfscript>
	<script>
	/* <![CDATA[ */
	var imageSortingStarted=false;
	var imageSortingChanged=false; 
	var currentImageLibraryId="#form.image_library_id#";
	var arrImageLibraryCaptions=new Array();
	<cfloop query="qImages">
	arrImageLibraryCaptions[#qImages.image_id#]="#JsStringFormat(qImages.image_caption)#";
	</cfloop>
	/* ]]> */
	</script>
	</cfsavecontent>
	<cfscript>
	application.zcore.template.appendTag("meta",theMeta);
	</cfscript>
	<h2>Upload Images</h2> 
	<style>
	.z-image-library-top{display:table; width:100%;}
	.z-image-library-left{display:table-cell; width:1%; min-width:250px; white-space:nowrap; vertical-align:top;}
	.z-image-library-right{display:table-cell; vertical-align:top; }
	.z-image-library-help{width:100%; float:left; display:none;}
	.z-image-library-top .z-manager-search-button{ display:block; float:left; color:##FFF !important;}
	@media screen and ( max-width: 992px ) {
		.z-image-library-left{display:block; float:left; }
		.z-image-library-right{display:block; float:left; } 
	}
	</style>
	<div class="z-image-library-top z-mb-10">

		<div class="z-image-library-left z-mb-10">
			<form id="form1" action="#request.cgi_script_name#?method=imageform&amp;image_library_id=#form.image_library_id#" enctype="multipart/form-data" method="post">
				<div class="z-float z-mb-10 z-pr-10">
					<div id="htmlFileUpload" class="z-float"> 
						<input type="file" name="imagefiles" id="imagefiles" multiple="multiple" style="width:100%;" />
					</div>
				</div> 
				<div class="z-float z-mb-10">
					<span id="submitDiv1">
						<input type="submit" name="submit222" value="Upload" class="z-manager-search-button" style="-webkit-appearance: none;" onclick="$('##submitDiv1').hide();$('##waitDiv1').show();" />
					</span>

					<span id="waitDiv1"  style="display:none;">Please Wait...</span>

					<a href="##" onclick="window.parent.zCloseModal(); return false;" class="z-manager-search-button">Close</a> 
				</div>
			</form>
		</div>
		<div class="z-image-library-right z-mb-10">

			<div class="z-float z-mb-10">
				<a href="##" onclick="$('.z-image-library-help').show();return false;" class="z-manager-search-button">View Help</a>
				 <a href="#application.zcore.imageLibraryCom.getViewOriginalImagesURL(form.image_library_id, qLibrary.image_library_hash)#" class="z-manager-search-button" target="_blank" title="Click here to view the original images on the web.">View Originals</a> <a href="/z/_com/app/image-library?method=downloadOriginalImages&amp;image_library_id=#form.image_library_id#" class="z-manager-search-button" target="_blank" title="Click here to download the original images in a zip file.">Download Zip</a>
			</div>
			<div class="z-image-library-help">
				<h2>Image Library Help</h2>
				<p>This tool lets you upload multiple images (.jpg, .gif or .png) at once.<br />
				You may also upload a compressed zip file with these image formats inside.<br />
				Please note any files inside the zip that are not jpg, gif or png will be discarded.<br />
				Type in image captions below. Drag the images to put them in your preferred sorting order.<br />
				Changes are saved instantly. Click "Close" when done.</p>
			</div>
		</div>
	</div>
 
	
	<div class="z-float z-mb-10">
		<ul id="sortable">
			<cfloop query="qImages">
			<li class="ui-state-default" id="image#qImages.image_id#"><div class="imageclosebutton" onclick="confirmDeleteImageId(#qImages.image_id#);">X</div><div class="imagedivclass"><img style="border:none; text-align:center; " src="#application.zcore.imageLibraryCom.getImageLink(qImages.image_library_id, qImages.image_id, "200x128", "0", true, qImages.image_caption, qImages.image_file, qImages.image_updated_datetime)#" /></div><div class="captionbar"><input class="captionClass" type="text" placeholder="Caption" name="caption#qImages.image_id#" id="caption#qImages.image_id#" value="#htmleditformat(qImages.image_caption)#" onkeyup="toggleImageCaptionUpdate('imagecaptionupdate#qImages.image_id#','block',true);" onblur="toggleImageCaptionUpdate('imagecaptionupdate#qImages.image_id#','none',false);"> <div id="imagecaptionupdate#qImages.image_id#" class="imagecaptionupdate">Update</div></div></li>
			</cfloop>
		</ul>
	</div> 
	<div class="z-float forimagedata2"><textarea name="forimagedata" id="forimagedata" style="display:none; width:800px; height:400px;"></textarea></div>
		<script>	
		/* <![CDATA[ */
		if(debugImageLibrary){
			document.getElementById("forimagedata2").style.display="block";
		}
		/* ]]> */
		</script>
</cffunction>

<!--- 
// image_library_hash is optional
application.zcore.imageLibraryCom.getViewOriginalImagesURL(image_library_id, image_library_hash); 
--->
<cffunction name="getViewOriginalImagesURL" localmode="modern" access="public">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfargument name="image_library_hash" type="string" required="no" default="">
	<cfscript>
	if(arguments.image_library_hash NEQ ""){
		return "/z/_com/app/image-library?method=viewOriginalImages&id=#arguments.image_library_id#&key=#arguments.image_library_hash#";
	}else{
		var qLibrary=this.getLibraryById(arguments.image_library_id); 
		if(isBoolean(qLibrary) and qLibrary EQ false){
			return "##";
		}else{
			return "/z/_com/app/image-library?method=viewOriginalImages&id=#arguments.image_library_id#&key=#qLibrary.image_library_hash#";
		}
	}
	</cfscript>
</cffunction>


<!--- /z/_com/app/image-library?method=downloadOriginalImages&image_library_id=#form.image_library_id#  --->
<cffunction name="downloadOriginalImages" localmode="modern" access="remote" returntype="any" output="yes">
	<cfscript>
	var db=request.zos.queryObject;
	
	var qImages=0;
	var r=0;
	var theMeta=0;
	setting requesttimeout="3600";  
	form.image_library_id=application.zcore.functions.zso(form, 'image_library_id');
	tempId=form.image_library_id;

	var qLibrary=this.getLibraryById(form.image_library_id); 
	if(isBoolean(qLibrary) or qLibrary.recordcount EQ 0){
		application.zcore.functions.z404("Invalid image_library_id");	
	}
	form.image_library_id=qLibrary.image_library_id; 
	
	if(not variables.hasAccessToImageLibraryId(form.image_library_id)){
		application.zcore.functions.z404("No access to image_library_id");	
	}  
	db.sql="SELECT * FROM #db.table("image", request.zos.zcoreDatasource)# image 
	WHERE image_library_id = #db.param(form.image_library_id)# and 
	image_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# 
	ORDER BY image_sort, image_caption, image_id";
	qImages=db.execute("qImages"); 
	if(qImages.recordcount EQ 0){
		echo('<h2>There are no images in this library yet.</h2>');
		abort;

	} 
	arrFile=[];
	for(row in qImages){ 
		p=request.zos.globals.privateHomedir&"zupload/library/#row.image_library_id#/#row.image_file#";
		if(fileexists(p)){
			arrayAppend(arrFile, p); 
		}

	} 
	if(arraylen(arrFile) EQ 0){
		echo('<h2>This library is missing all its images.</h2>');
		abort;

	} 

	tempZipPath=request.zos.globals.privateHomedir&"image-library-#form.image_library_id#.zip";
			// add file to zip
	zip action="zip" file="#tempZipPath#"{
		for(file in arrFile){
			zipparam source="#file#" recurse="yes";
		}
	}
	fileName=getFileFromPath(tempZipPath);

	header name="Content-Disposition"  value="attachment;filename=#Replace(replace(fileName, ",", " ", "all"), " ",  "_", "all")#";
	content deleteFile="yes" file="#tempZipPath#" type="application/x-zip-compressed";

	abort;
	</cfscript>   
</cffunction>


<!--- /z/_com/app/image-library?method=viewOriginalImages&id=#form.image_library_id#&key=1234 --->
<cffunction name="viewOriginalImages" localmode="modern" access="remote" returntype="any" output="yes">
	<cfscript>
	var db=request.zos.queryObject;
	
	var qImages=0;
	var r=0;
	var theMeta=0;
	setting requesttimeout="3600";  
	form.image_library_id=application.zcore.functions.zso(form, 'id');
	form.image_library_hash=application.zcore.functions.zso(form, 'key');
	tempId=form.image_library_id;

	var qLibrary=this.getLibraryById(form.image_library_id); 
	if(isBoolean(qLibrary) or qLibrary.recordcount EQ 0 or qLibrary.image_library_hash NEQ form.image_library_hash){
		application.zcore.functions.z404("Invalid image library id or key.");
	}
	form.image_library_id=qLibrary.image_library_id; 

	db.sql="SELECT * FROM #db.table("image", request.zos.zcoreDatasource)# image 
	WHERE image_library_id = #db.param(form.image_library_id)# and 
	image_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#  
	ORDER BY image_sort, image_caption, image_id";
	qImages=db.execute("qImages");  
	arrFile=[]; 
	if(qImages.recordcount EQ 0){
		echo('<h2>There are no images in this library yet.</h2>');
		abort;

	} 
	for(row in qImages){ 
		p=request.zos.globals.privateHomedir&"zupload/library/#row.image_library_id#/#row.image_file#";
		p2="/zupload/library/#row.image_library_id#/#row.image_file#";
		if(fileexists(p)){
			arrayAppend(arrFile, { file:p2, caption: row.image_caption}); 
		}

	} 
	if(arraylen(arrFile) EQ 0){
		echo('<h2>The images for this library are missing.</h2>');

	} 
	echo('<h2>Image Library Original Images</h2>');
	for(file in arrFile){
		echo('<p><img src="#file.file#" alt="image" style="max-width:100%;" /></p>');
		if(file.caption NEQ ""){
			echo("<h3>"&file.caption&"</h3>");
		}
		echo("<hr />");
	} 
 	
 	application.zcore.template.setPlainTemplate();
	</cfscript>   
</cffunction>


<!--- /z/_com/app/image-library?method=saveSortingPositions&image_library_id=&image_id_list= --->
<cffunction name="saveSortingPositions" localmode="modern" access="remote" returntype="any" output="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var qLibrary=this.getLibraryById(application.zcore.functions.zso(form, 'image_library_id'),false);
	var qCheck=0;
	var i=0;
	var arrImageId=0; 
	if(isQuery(qLibrary) EQ false){
		writeoutput('{"success":"0","errorMessage":"Invalid image_library_id"}');
		application.zcore.functions.zabort();
	}
	if(not variables.hasAccessToImageLibraryId(qLibrary.image_library_id)){
		application.zcore.functions.z404("No access to image_library_id");	
	}
	arrImageId=listtoarray(form.image_id_list,",");
	for(i=1;i LTE arraylen(arrImageId);i++){
		db.sql="UPDATE #db.table("image", request.zos.zcoreDatasource)#  
		SET image_sort = #db.param(i)#,
		image_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE image_library_id = #db.param(form.image_library_id)# and 
		image_deleted = #db.param(0)# and 
		image_id = #db.param(arrImageId[i])# and 
		site_id=#db.param(request.zos.globals.id)#";
		db.execute("q");
			
	}
	writeoutput('{"success":"1"}');
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>



<!--- /z/_com/app/image-library?method=deleteInactiveImageLibraries --->
<cffunction name="deleteInactiveImageLibraries" localmode="modern" access="remote" returntype="any" output="no">
	<cfargument name="dontAbort" type="string" required="no" default="#false#">
	<cfscript>
	var db=request.zos.queryObject;
	var qLibrary=0;
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	}
	var i=0; db.sql="SELECT * FROM #db.table("image_library", request.zos.zcoreDatasource)# image_library, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_active = #db.param(1)# and 
	image_library.site_id = site.site_id and 
	site.site_deleted = #db.param(0)# and 
	image_library_deleted = #db.param(0)# and 
	image_library_active=#db.param(0)# and 
	image_library_datetime <= #db.param(dateformat(dateadd("d",-1,now()),'yyyy-mm-dd')&" 00:00:00")#";
	qLibrary=db.execute("qLibrary");
	for(i=1;i LTE qLibrary.recordcount;i++){
		this.deleteImageLibraryId(qLibrary.image_library_id[i],qLibrary.site_id[i]);	
	}
	if(arguments.dontAbort){
		return true;	
	}
	writeoutput('done.');
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>


<!--- application.zcore.imageLibraryCom.deleteImageLibraryId(image_library_id); --->
<cffunction name="deleteImageLibraryId" localmode="modern" returntype="any" output="no">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var db=request.zos.queryObject;
	if(arguments.image_library_id NEQ 0 and arguments.image_library_id NEQ ""){
		application.zcore.functions.zdeletedirectory(application.zcore.functions.zvar('privatehomedir',arguments.site_id)&"zupload/library/"&application.zcore.functions.zURLEncode(arguments.image_library_id,"-")&"/");
		db.sql="DELETE FROM #db.table("image_cache", request.zos.zcoreDatasource)#  
		WHERE image_library_id = #db.param(arguments.image_library_id)# and 
		image_cache_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		db.execute("q");
		db.sql="DELETE FROM #db.table("image", request.zos.zcoreDatasource)#  
		WHERE image_library_id = #db.param(arguments.image_library_id)# and 
		image_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		db.execute("q");
		db.sql="DELETE FROM #db.table("image_library", request.zos.zcoreDatasource)#  
		WHERE image_library_id = #db.param(arguments.image_library_id)# and 
		image_library_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		db.execute("q");
	}
	</cfscript>
</cffunction>



<cffunction name="hasAccessToImageLibraryId" localmode="modern" returntype="boolean">
	<cfargument name="image_library_id" type="string" required="yes">
	<cfscript>
	if(application.zcore.user.checkGroupAccess("member")){
		return true;
	}else if(not structkeyexists(request.zsession, 'publicImageLibraryIdStruct')){
		return false;
	}else if(not structkeyexists(request.zsession.publicImageLibraryIdStruct, arguments.image_library_id)){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<!--- application.zcore.imageLibraryCom.deleteImageId(image_id); --->
<cffunction name="deleteImageId" localmode="modern" returntype="any" output="no">
	<cfargument name="image_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("image", request.zos.zcoreDatasource)# image 
	WHERE image_id = #db.param(arguments.image_id)# and 
	image_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qImages=db.execute("qImages");
	if(qImages.recordcount EQ 0){
		return;
	}
	if(not variables.hasAccessToImageLibraryId(qImages.image_library_id)){
		application.zcore.functions.z404("No access to image_library_id");	
	}

	db.sql="SELECT * FROM #db.table("image_cache", request.zos.zcoreDatasource)# 
	WHERE image_id = #db.param(arguments.image_id)# and 
	image_cache_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qCachedImages=db.execute("qCachedImages");
	for(row in qCachedImages){
		application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&"zupload/library/#qImages.image_library_id#/#row.image_cache_file#");
	}

	application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&"zupload/library/#qImages.image_library_id#/#qImages.image_file#");
	application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&"zupload/library/#qImages.image_library_id#/#qImages.image_intermediate_file#");
	this.clearImageIdCache(arguments.image_id);
	db.sql="DELETE FROM #db.table("image", request.zos.zcoreDatasource)#  
	WHERE image_id = #db.param(arguments.image_id)# and 
	image_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("q");
	</cfscript>
</cffunction>

<!--- application.zcore.imageLibraryCom.clearImageIdCache(image_id); --->
<cffunction name="clearImageIdCache" localmode="modern" returntype="any" output="no">
	<cfargument name="image_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("image_cache", request.zos.zcoreDatasource)# image_cache 
	WHERE image_id = #db.param(arguments.image_id)# and 
	image_cache_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	var qImages=db.execute("qImages");
	</cfscript>
	<cfloop query="qImages">
		<cfscript>
		application.zcore.functions.zDeleteFile(request.zos.globals.privatehomedir&"zupload/library/#qImages.image_library_id#/#qImages.image_cache_file#");
		</cfscript>
	</cfloop>
	<cfscript>
	db.sql="DELETE FROM #db.table("image_cache", request.zos.zcoreDatasource)#  
	WHERE image_id = #db.param(arguments.image_id)# and 
	image_cache_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("q"); 
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>