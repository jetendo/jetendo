<cfcomponent>
<!--- 
/z/admin/files-import/reset
/z/admin/files-import/index
/z/admin/files-import/cacheImageSizes
 --->
<cffunction name="reset" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	echo('disabled');
	// this was designed to only run once.
	abort;
	/*
	db=request.zos.queryObject;
	// loop all active sites
	db.sql="TRUNCATE TABLE #db.table("virtual_file", request.zos.zcoreDatasource)# ";
	qs=db.execute("qs");
	db.sql="TRUNCATE TABLE #db.table("virtual_folder", request.zos.zcoreDatasource)# ";
	qs=db.execute("qs");
	
	echo('Virtual File/Folder reset.');
	abort;*/
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	echo('disabled');
	// this was designed to only run once.
	abort;
	/*
	setting requesttimeout="100000";
	db=request.zos.queryObject;
	// loop all active sites
	db.sql="select * FROM #db.table("site", request.zos.zcoreDatasource)#  
	where site.site_active =#db.param('1')# and 
	site_deleted = #db.param(0)# and 
	site_id <> #db.param(-1)#";
	qs=db.execute("qs");
	
	arrPath=["zupload/user/", "zuploadsecure/user/"];
	count=0;
	folderCount=0;
	for(siteRow in qS){
		if(siteRow.site_id NEQ 23){
		//	continue;
		}
		tempPath=application.zcore.functions.zGetDomainWritableInstallPath(siteRow.site_short_domain);
		
		for(tempUserPath in arrPath){
			currentPath=tempPath&tempUserPath;
			qFile=directorylist(currentPath, true, 'query');
			
			parentIdStruct={};
			parentIdStruct[left(currentPath, len(currentPath)-1)]=0;
			// create all directories first, so we have a lookup table for all of them.
			for(row in qFile){
				if(row.type EQ "dir"){
					absoluteFilePath=row.directory&"/"&row.name;
					dbPath=replace(absoluteFilePath, currentPath, "");
					ts={
						table:"virtual_folder",
						datasource:request.zos.zcoreDatasource,
						struct:{
							site_id:siteRow.site_id,
							virtual_folder_name:row.name,
							virtual_folder_parent_id:parentIdStruct[row.directory],
							virtual_folder_path:dbPath,
							virtual_folder_deleted:0,
							virtual_folder_updated_datetime:request.zos.mysqlnow
						}
					}
					if(tempUserPath CONTAINS "secure"){
						ts.struct.virtual_folder_secure=1;
					} 
					virtual_folder_id=application.zcore.functions.zInsert(ts);
					parentIdStruct[row.directory&"/"&row.name]=virtual_folder_id;
					folderCount++;
					// comment this out after verifying script works.
					//break;
				}
				
			} 
			for(row in qFile){
				if(row.type EQ "file"){
					absoluteFilePath=row.directory&"/"&row.name;
					dbPath=replace(absoluteFilePath, currentPath, "");
					ext=application.zcore.functions.zGetFileExt(absoluteFilePath); 
					ts={
						table:"virtual_file",
						datasource:request.zos.zcoreDatasource,
						struct:{
							site_id:siteRow.site_id,
							virtual_file_deleted:0,
							virtual_file_name:row.name,
							virtual_file_updated_datetime:request.zos.mysqlnow,
							virtual_file_folder_id:parentIdStruct[row.directory],
							virtual_file_path:dbPath,
							virtual_file_secure:0,
							virtual_file_download_secret:hash(application.zcore.functions.zGenerateStrongPassword(80,200), 'sha-256'),
							virtual_file_last_modified_datetime:dateformat(row.dateLastModified, "yyyy-mm-dd")&" "&timeformat(row.dateLastModified, "HH:mm:ss"),
							virtual_file_size:row.size
						}
					}
					if(tempUserPath CONTAINS "secure"){
						ts.struct.virtual_file_secure=1;
					} 
					virtual_file_id=application.zcore.functions.zInsert(ts);
					count++;
					// comment this out after verifying script works.
					//break;
				}
			}
			
			// comment this out after verifying script works an entire site.
			//break;
		}
	}
	
	echo("#count# Files imported and #folderCount# Folders imported");
	abort;*/
	</cfscript>
</cffunction>

<cffunction name="cacheImageSizes" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	echo('disabled');abort;
	// this was designed to only run once.
	/*
	db=request.zos.queryObject;
	setting requesttimeout="100000";
	
	db.sql="select * FROM 
	#db.table("site", request.zos.zcoreDatasource)#,
	#db.table("virtual_file", request.zos.zcoreDatasource)# 
	where site.site_id = virtual_file.site_id and 
	site_deleted=#db.param(0)# and 
	virtual_file_deleted=#db.param(0)# and 
	virtual_file_image_width=#db.param(0)# and 
	(virtual_file_name like #db.param("%.jpg")# or 
	virtual_file_name like #db.param("%.jpeg")# or 
	virtual_file_name like #db.param("%.gif")# or 
	virtual_file_name like #db.param("%.png")# )
	and 
	site.site_id <> #db.param('-1')#";
	qs=db.execute("qs");
	count=0;
	for(row in qs){ 
		tempPath=application.zcore.functions.zGetDomainWritableInstallPath(row.site_short_domain);
		if(row.virtual_file_secure EQ 1){
			path=(tempPath&"zuploadsecure/user/"&row.virtual_file_path);
		}else{
			path=(tempPath&"zupload/user/"&row.virtual_file_path);
		}
		rs=application.zcore.functions.zGetImageSize(path);
		if(not rs.success){
			contents=application.zcore.functions.zReadFile(path);
			if(contents CONTAINS '</html>'){
				form.deleteOne=1;
			}
			if(structkeyexists(form, 'deleteOne')){
				structdelete(form, 'deleteOne');
				application.zcore.functions.zDeleteFile(path);
				db.sql="delete from #db.table("virtual_file", request.zos.zcoreDatasource)# 
				where site_id = #db.param(row.site_id)# and 
				virtual_file_id = #db.param(row.virtual_file_id)# and 
				virtual_file_deleted=#db.param(0)# ";
				db.execute("qDelete");
				continue;
			}else{
				echo("zGetImageSize Failed: "&path&"<br>");  
				echo(rs.errorMessage);
				echo('<br><a href="/z/admin/files-import/cacheImageSizes?deleteOne=1">Click here to delete this file and continue.</a>');

			}
			abort;
		}
		db.sql="update #db.table("virtual_file", request.zos.zcoreDatasource)# SET 
		virtual_file_image_width=#db.param(rs.width)#,
		virtual_file_image_height=#db.param(rs.height)# 
		WHERE site_id = #db.param(row.site_id)# and 
		virtual_file_id=#db.param(row.virtual_file_id)# and 
		virtual_file_deleted=#db.param(0)# ";
		db.execute("qUpdate"); 
		count++;
		// comment this out after verifying script works an entire site.
		//break;
	}
	
	echo("#count# Images updated");
	*/
	</cfscript>
</cffunction>

</cfcomponent>