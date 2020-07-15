<cfcomponent>

<!--- 
note this cfc is incomplete - not fully functional yet.

TODO: consider allowing cloudFile to recursively sync an entire directory to cloud, without modifying the application's storing behavior.
	replace fileExists and other file function with cloud aware versions for those applications
		files & images
		site options
		events
		image library
		member
		rental
		job
		etc

	consider integrating with the named file lock, so that cloud sync on those locked files doesn't occur at the same time.
	consider excluding all the "tmp" files that have hash "#" or other extensions so cloud sync ignores files that are not fully written yet.
	consider delaying cloud sync after file lastModifiedDate is at least 1 minute old to ensure activity to that file is idle.

	instead of indexing on a schedule, cloudFile can receive change notifications from the application, which are cached in memory (struct)
		application.zcore.cloudFile.fileNotify(path, "write");
		application.zcore.cloudFile.fileNotify(path, "delete");
		application.zcore.cloudFile.fileNotify(path, "lock", 15); // lock for 15 seconds / prevents local write/delete during this time
		application.zcore.cloudFile.fileNotify(path, "unlock");

	requires making containers lookup table, which compares paths instead of relying on application integration to set the cloud_file_container_local_name

	add this function to ease integration:
		getRemoteURL()

for recovering deleted files:
/z/_com/zos/cloudFile?method=listDeletedFiles

setup cfml task job once per day (need another function that loops all sites)
/z/_com/zos/cloudFile?method=purgeOldFiles

show the containers in order to make files available offline for site backup
/z/_com/zos/cloudFile?method=listContainers

TODO: wherever we do insert/add file or do things like fileExists or zUpload, we need to do this:
	rs=cloudFile.getFileByPath(path);
	if(rs.success){ 
		// return duplicate error
	}
consider storing "Stub" zero byte files on filesystem to handle uniqueness.

cloud file doesn't care if file already exists - it processes new copies of files each time putFile is called.  It doesn't make if they are identical.   

TODO: consider storing md5 hash of file, to compare contents and avoid duplication / unnecessary versions. 

TODO: make new rewrite that direct downloads from files that are publicly available. 

// might want this to track which server the file was stored on.   Each developer machine and server must have a unique id to do this.  Perhaps in a new file.  We could force developer machines to store locally only, to simplify and then we only need a test/live check
cloud_file_server_id

TODO: make available offline has async feature, so that we can schedule them all to be downloaded, and report progress in realtime to user.

TODO: add queue_http_priority field, and ORDER BY queue_http_priority ASC and give the cloud file upload/download priority of 10 to avoid delaying other more important api calls / lead notifications.

TODO: add queue_http_enable_parallel to support multi-threaded processing of queue. limit to 4 simultaneous.

TODO: convert queue_http to php streaming http, to increase multi-threading to get closer to the higher API limits.
	on queue-http: implement some kind of api limit tracking system - probably need a table to do it correctly.
		need to rebuild queue-http executeQueuedTasks and executeHTTPRequest in php so that we can do multiple threads.

TODO: convert the other calls to make available offline to async when it works.

TODO: add listContainers link in site globals server manager navigation somewhere ("Cloud")

TODO: add field cloud_file_disable_online char(1) 0 - when set to 1, storeOnline is disabled.  Make Available offline will be augmented with a new setOfflineOnly function
 
// rackspace , microsoft and google have object "name", which is url encoded if you want slashes, etc

TODO: modify site backup so that it eliminates the cloud_file_url data from the table and maybe other fields.

TODO: exclude queue_http from site backup

# this table is incomplete in its design:
user_dir
	user_dir_id
	user_dir_name
	user_dir_hash varchar 64 sha256
	user_dir_cloud_url
	user_dir_updated_datetime
	user_dir_deleted
	site_id
user_file
	user_file_id
	user_file_name
	user_file_hash varchar 64 sha256
	user_file_cloud_url
	user_file_updated_datetime
	user_file_deleted
	site_id

// make a function that migrates files from one vendor to another automatically.
  


// usage
cloudFileCom=application.zcore.cloudFile;
ts={
	relativeFilePath:"/zupload/user/testFile.txt", // path should be relative to the localPath directory passed to the init function.
	onlineOnly:false, // true will delete local copy of file after it is synced with remote server.
	offlineOnly:false, // true will disable syncing the file to the remote server.
	secure:true, // true prevents direct download
	async:false, // sync with remote server will occur later
	container:"", // friendly name to group these files for easier backup/restore.
	configId:1 // sets which root directory configuration to use | 1 is privatehomedir | 2 is ?
}
rs=cloudFileCom.putFile(ts);
if(not rs.success){
	throw(rs.errorMessage);
}
cloudFileCom.isOnline(path);
cloudFileCom.isLocal(path);
cloudFileCom.getFileByPath(path);
cloudFileCom.getFileById(path);
cloudFileCom.getTemporaryFile(path);
cloudFileCom.setOnlineOnly(path, true);
cloudFileCom.deleteFile(path);
cloudFileCom.fileExists(path);
cloudFileCom.purgeFile(path);
cloudFileCom.downloadFile(path);
---> 
<cffunction name="getCloudVendors" localmode="modern" access="public">
	<cfscript>
	ts={
		"1":createObject("component", "zcorerootmapping.com.cloud.local"),
		"2":createObject("component", "zcorerootmapping.com.cloud.rackspace"),
		//"3":createObject("component", "zcorerootmapping.com.cloud.google"),
		//"4":createObject("component", "zcorerootmapping.com.cloud.microsoft"),
		//"5":createObject("component", "zcorerootmapping.com.cloud.amazon"),
	};
	return ts;
	</cfscript>
</cffunction>

<cffunction name="getConfig" localmode="modern" access="public">
	<cfargument name="cloud_file_config_id" type="string" required="yes">
	<cfscript>
	id=arguments.cloud_file_config_id;
	if(id EQ 1){
		ts={
			localPath:request.zos.globals.privatehomedir,
			remotePath:request.zos.globals.privatehomedir&"zuploadsecure/cloud_files/",
			remoteURL:request.zos.globals.domain&"/zuploadsecure/cloud_files/",
			remoteRelativeURL:"/zuploadsecure/cloud_files/"
		};
		return ts;
	}else if(id EQ 2){
		ts={
			localPath:request.zos.globals.privatehomedir,
			remotePath:"",
			remoteURL:"",
			remoteRelativeURL:""
		};
		return ts;
	}else{
		throw("Not implemented");
	}
	</cfscript>
</cffunction>
	
<cffunction name="index" localmode="modern" access="remote">
	<cfscript> 
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("Access denied");
	}
	echo('<h2>Testing Cloud File</h2>');


	initialPath=request.zos.globals.privatehomedir&"testFile.txt";
	path=request.zos.globals.privatehomedir&"zupload/user/testFile.txt"; 
	result=application.zcore.functions.zcopyfile(initialPath, path, true);  
	path="/zupload/user/testFile.txt"; 

	cloudFileCom=this; 

	ts={
		relativeFilePath:path, // path should be relative to the localPath directory passed to the init function.
		onlineOnly:true, // true will delete local copy of file after it is synced with remote server.
		offlineOnly:false, // true will disable syncing the file to the remote server.
		secure:true, // true prevents direct download
		async:false, // sync with remote server will occur later
		container:"user files", // friendly name to group these files for easier backup/restore.
		configId:1 // sets which root directory configuration to use | 1 is privatehomedir | 2 is ?
	}
	rs=cloudFileCom.putFile(ts);
	if(not rs.success){
		throw(rs.errorMessage);
	}
	id=rs.data.cloud_file_id;
	fileData=rs.data;
	writedump(rs);
	echo('<h2>Put File</h2>'); 
	abort;

	rs=cloudFileCom.isOnline(path);
	echo('<h2>isOnline</h2>');
	writedump(rs);

	rs=cloudFileCom.getFileByPath(path);
	echo('<h2>getFileByPath</h2>');
	writedump(rs);

	rs=cloudFileCom.getFileById(id);
	echo('<h2>getFileById</h2>');
	writedump(rs); 

	rs=cloudFileCom.setOnlineOnly(path, true);
	echo('<h2>setOnlineOnly: true</h2>');
	writedump(rs);

	rs=cloudFileCom.setOnlineOnly(path, false);
	echo('<h2>setOnlineOnly: false</h2>');
	writedump(rs); 

	rs=cloudFileCom.fileExists(path);
	echo('<h2>fileExists</h2>');
	writedump(rs);

	rs=cloudFileCom.getTemporaryFile(path);
	echo('<h2>getTemporaryFile</h2>');
	writedump(rs);

	writedump('Deleted temp file:'&fileexists(rs.path));
	application.zcore.functions.zDeleteFile(rs.path);

	// uncomment to test download
	// cloudFileCom.downloadFile(fileData);


	rs=cloudFileCom.deleteFile(path);
	echo('<h2>deleteFile</h2>');
	writedump(rs);

	rs=cloudFileCom.getFileByPath(path);
	echo('<h2>getFileByPath - should fail</h2>');
	writedump(rs);

	// uncomment to test download
	echo('<p><a href="/z/_com/zos/cloudFile?method=downloadDeletedFile&cloud_file_id=#fileData.cloud_file_id#" target="_blank">Download Deleted File</a></p>');
 

	// comment when testing downloadDeletedFile
	/**/
	rs=cloudFileCom.purgeFile(fileData);
	echo('<h2>purgeFile</h2>');
	writedump(rs); 

	</cfscript>
</cffunction>

<cffunction name="putFile" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={ 
		onlineOnly:false,
		offlineOnly:false,
		secure:false,
		async:false,
		container:"",
		configId:1
	}
	ss=arguments.ss;
	structappend(ss, ts, false);
	config=getConfig(ss.configId);
	absolutePath=config.localPath&removeChars(ss.relativeFilePath, 1, 1);
	if(not fileExists(absolutePath)){
		return {success:false, errorMessage:"Local file doesn't exist: #absolutePath#"};
	}

	fileInfo=getFileInfo(absolutePath);
	
	// delete existing file if any exist for this path - guarantees previous cloud file record is immutable
	deleteFile(ss.relativeFilePath); 

	t9={
		table:"cloud_file",
		datasource:request.zos.zcoreDatasource,
		struct:{
			cloud_file_name:getFileFromPath(ss.relativeFilePath),
			cloud_file_local_path:ss.relativeFilePath,
			cloud_file_server_id:1,
			cloud_vendor_id:1, // TODO: set vendor per site or globally somehow with a variable somewhere else.  for now, 1 is local, 2 is rackspace and the driver for put/get/delete will be created as separate objects per vendor to separate vendor from application
			cloud_file_created_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
			cloud_file_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
			cloud_file_deleted:0,
			cloud_file_is_local:1,
			cloud_file_hash:hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256'),
			cloud_file_is_online:0,
			cloud_file_is_secure:0,
			cloud_file_size:fileInfo.size,
			cloud_file_container_local_name:ss.container,
			cloud_file_width:0,
			cloud_file_height:0,
			cloud_file_remote_path:"",
			cloud_file_config_id:ss.configId,
			cloud_file_last_modified_datetime:dateformat(fileInfo.lastModified, "yyyy-mm-dd")&" "&timeformat(fileInfo.lastModified, "HH:mm:ss"),
			site_id:request.zos.globals.id
		}
	}
	t9.struct.config=config;
	ext=application.zcore.functions.zGetFileExt(t9.struct.cloud_file_local_path);
	if(ext EQ "png" or ext EQ "gif" or ext EQ "jpg" or ext EQ "jpeg"){
		// get width/height
		imageInfoStruct=application.zcore.functions.zGetImageSize(absolutePath);
		if(imageInfoStruct.success){
			t9.struct.cloud_file_width=imageInfoStruct.width;
			t9.struct.cloud_file_height=imageInfoStruct.height;
		}
	}
	if(ss.secure){
		t9.struct.cloud_file_is_secure=1;
	}
	if(ss.async){ 
		cloud_file_id=application.zcore.functions.zInsert(t9);
		if(cloud_file_id EQ false){
			return {success:false, errorMessage:"Failed to insert file"};
		}
		t9.struct.cloud_file_sync_to_remote=1;
		if(ss.onlineOnly){
			t9.struct.cloud_file_sync_delete_local=1;
		}
		t9.struct.cloud_file_id=cloud_file_id;
		t9.struct.cloud_file_remote_path=t9.struct.site_id&"-"&t9.struct.cloud_file_id&"-"&t9.struct.cloud_file_hash&"."&ext; 
		t9.struct.cloud_file_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
		application.zcore.functions.zUpdate(t9);


		seconds=round(10*(t9.struct.cloud_file_size/1024/1024));
		ts={
			name:"zCloudFile-#t9.struct.site_id#-#t9.struct.cloud_file_id#",
			url:request.zos.globals.domain&"/z/_com/zos/cloudFile?method=syncToServer&cloud_file_id=#t9.struct.cloud_file_id#",
			timeout:seconds,
			retry_interval:600,
			postVars:{},
			headerVars:{},
			apiId:1 // cloud files - local
		}
		queueHttpCom=createobject("component", "zcorerootmapping.com.app.queue-http");
		r=queueHttpCom.queueHTTPRequest(ts);
		if(not r){
			throw("Failed to queue http request to sync cloud file to server.");
		}
	}else{
		cloud_file_id=application.zcore.functions.zInsert(t9);
		if(cloud_file_id EQ false){
			return {success:false, errorMessage:"Failed to insert file"};
		}
		t9.struct.cloud_file_id=cloud_file_id;
		t9.struct.cloud_file_remote_path=t9.struct.site_id&"-"&t9.struct.cloud_file_id&"-"&t9.struct.cloud_file_hash&"."&ext; 
		rs=storeOnline(t9.struct);
		if(rs.success){ 
			t9.struct.cloud_file_is_online=1;
			t9.struct.cloud_file_url=rs.cloud_file_url;
			if(ss.onlineOnly){
				application.zcore.functions.zDeleteFile(absolutePath);
				t9.struct.cloud_file_is_local=0; 
				t9.struct.cloud_file_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
			}
		}
		application.zcore.functions.zUpdate(t9);
	}
	return {success:true, data:t9.struct};
	</cfscript>
</cffunction>

<cffunction name="isOnline" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	rs=getFileByPath(arguments.path);
	if(not rs.success){
		throw("File doesn't exist: #arguments.path#");
	}
	if(rs.data.cloud_file_is_online EQ 1){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="isLocal" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	rs=getFileByPath(arguments.path);
	if(not rs.success){
		throw("File doesn't exist: #arguments.path#");
	}
	if(rs.data.cloud_file_is_local EQ 1){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<cffunction name="syncToServer" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer and server ips can access this");
	}

	form.cloud_file_id=application.zcore.functions.zso(form, 'cloud_file_id', true, 0);
	db=request.zos.queryObject;
	db.sql="select * from #db.table("cloud_file", request.zos.zcoreDatasource)# WHERE 
	cloud_file_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	cloud_file_sync_to_remote=#db.param(1)#";
	if(form.cloud_file_id NEQ 0){
		db.sql&=" and cloud_file_id=#db.param(form.cloud_file_id)# ";
	}
	qFile=db.execute("qFile");
	for(row in qFile){
		row.config=getConfig(row.cloud_file_config_id);

		rs=storeOnline(row);
		if(not rs.success){
			continue;
		}
		db.sql="update #db.table("cloud_file", request.zos.zcoreDatasource)# SET ";
		if(row.cloud_file_sync_delete_local EQ 1){
			application.zcore.functions.zDeleteFile(row.config.localPath&removeChars(row.cloud_file_local_path, 1, 1));
			db.sql&=" cloud_file_is_local=#db.param(0)#, ";
		}
		db.sql&=" cloud_file_is_online=#db.param(1)#, 
		cloud_file_sync_to_remote=#db.param(0)#,
		cloud_file_sync_delete_local=#db.param(0)#,
		cloud_file_url=#db.param(rs.cloud_file_url)#,
		cloud_file_updated_datetime=#db.param(request.zos.mysqlnow)#
		WHERE cloud_file_id=#db.param(row.cloud_file_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		cloud_file_deleted=#db.param(0)#";
		db.execute("qUpdate");
	}
	</cfscript>
</cffunction>

<!--- synchronous call to download or upload the file --->
<cffunction name="setOnlineOnly" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfargument name="onlineOnly" type="boolean" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	rs=getFileByPath(arguments.path);
	if(not rs.success){
		return rs;
	}
	fileData=rs.data;
	if(fileData.cloud_file_sync_to_remote EQ 1){
		return {success:false, errorMessage:'File sync to remote is already in progress. Please try again later.'};
	}
	if(arguments.onlineOnly){
		if(fileData.cloud_file_is_online EQ 1){
			application.zcore.functions.zDeleteFile(fileData.config.localPath&removeChars(fileData.cloud_file_local_path, 1, 1));
			return {success:true};
		}else{
			rs=storeOnline(fileData);
			if(not rs.success){
				return rs;
			}
			application.zcore.functions.zDeleteFile(fileData.config.localPath&removeChars(fileData.cloud_file_local_path, 1, 1));
			db.sql="update #db.table("cloud_file", request.zos.zcoreDatasource)# SET 
			cloud_file_is_online=#db.param(1)#, 
			cloud_file_is_local=#db.param(0)#, 
			cloud_file_url=#db.param(rs.cloud_file_url)#,
			cloud_file_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE cloud_file_id=#db.param(fileData.cloud_file_id)# and 
			site_id=#db.param(request.zos.globals.id)# and 
			cloud_file_deleted=#db.param(0)#";
			db.execute("qUpdate");
			return {success:true};
		}
	}else{
		if(fileData.cloud_file_is_local EQ 0){
			if(fileData.cloud_file_is_online EQ 0){
				throw("The file doesn't exist online or locally: #arguments.path#");
			}else{
				rs=makeFileAvailableOffline(fileData);
				if(rs.success){
					db.sql="update #db.table("cloud_file", request.zos.zcoreDatasource)# SET 
					cloud_file_is_local=#db.param(1)#, 
					cloud_file_updated_datetime=#db.param(request.zos.mysqlnow)#
					WHERE cloud_file_id=#db.param(fileData.cloud_file_id)# and 
					site_id=#db.param(request.zos.globals.id)# and 
					cloud_file_deleted=#db.param(0)#";
					db.execute("qUpdate");
				}
				return rs;
			}
		}else{
			return {success:true};
		}
	}
	
	</cfscript>
</cffunction>

<cffunction name="deleteFile" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	// mark file as deleted in db only. / purge occurs 30 days later
	rs=getFileByPath(arguments.path);
	if(not rs.success){
		return {success:false, errorMessage:"File already deleted"};
	}

	db.sql="select max(cloud_file_deleted) id from #db.table("cloud_file", request.zos.zcoreDatasource)# 
	WHERE cloud_file_deleted<>#db.param(0)# and 
	cloud_file_local_path=#db.param(arguments.path)# and 
	site_id=#db.param(request.zos.globals.id)#";
	qId=db.execute("qId");
	db=request.zos.queryObject;
	id=qId.id;
	while(true){
		id++;
		db.sql="update #db.table("cloud_file", request.zos.zcoreDatasource)# SET 
		cloud_file_deleted=#db.param(id)#,
		cloud_file_updated_datetime=#db.param(request.zos.mysqlnow)# ,
		cloud_file_deleted_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE 
		site_id=#db.param(request.zos.globals.id)# and 
		cloud_file_deleted=#db.param(0)# and 
		cloud_file_id=#db.param(rs.data.cloud_file_id)# ";
		update=db.execute("qUpdate");
		if(update){
			break;
		}
	}

	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="listDeletedFiles" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	if(not application.zcore.user.checkGroupAccess("administrator")){
		application.zcore.functions.z404("Access denied");
	}

	// if we store user_id for files, then we can let users recover deleted files, otherwise only administrators can

	db.sql="select * from #db.table("cloud_file", request.zos.zcoreDatasource)# 
	WHERE cloud_file_deleted<>#db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# 
	ORDER BY cloud_file_deleted_datetime DESC  
	LIMIT #db.param(0)#, #db.param(10)# ";
	qDeleted=db.execute("qDeleted");

	echo('<h2>Deleted Files</h2>
	<p>This is a list of all the deleted files in the last 30 days.</p>');
	// todo support pagination and search here
	echo('<table class="table-list">
		<tr>
		<th>File</th>
		<th>Size</th>
		<th>Deleted Date</th>
		<th>Admin</th>
		</tr>');
	for(row in qDeleted){
		echo('<tr>
			<td>#row.cloud_file_local_path#</td>
			<td>#row.cloud_file_size#</td>
			<td>#dateformat(row.cloud_file_deleted_datetime, 'm/d/yy')&" at "&timeformat(row.cloud_file_deleted_datetime, "h:mm tt")#</td>
			<td><a href="/z/_com/zos/cloudFile?method=downloadDeletedFile&cloud_file_id=#row.cloud_file_id#" target="_blank">Download</a></td>
			</tr>');
	}
	echo('</table>');
	</cfscript>
</cffunction>
	
<cffunction name="downloadDeletedFile" localmode="modern" access="remote">
	<cfscript> 
	if(not application.zcore.user.checkGroupAccess("administrator")){
		application.zcore.functions.z404("Access denied");
	}
	form.cloud_file_id=application.zcore.functions.zso(form, 'cloud_file_id', true);
	db=request.zos.queryObject;
	db.sql="select * from #db.table("cloud_file")# WHERE 
	cloud_file_id=#db.param(form.cloud_file_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	cloud_file_deleted<>#db.param(0)#";
	qFile=db.execute("qFile");
	for(row in qFile){
		row.config=getConfig(row.cloud_file_config_id);
		if(row.cloud_file_is_local EQ 1){
			application.zcore.functions.zXSendFile(row.cloud_file_local_path);
		}else{
			application.zcore.functions.zXSendFile(application.zcore.cloudVendor[row.cloud_vendor_id].getDownloadLink(row));
		}
		abort;
	}
	application.zcore.functions.z404("File doesn't exist.");
	</cfscript>
</cffunction>
	

<cffunction name="fileExists" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	rs=getFileByPath(arguments.path);
	if(rs.success){
		if(rs.data.cloud_file_deleted NEQ 0){
			return false;
		}else{
			return true;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<cffunction name="getTemporaryFile" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	rs=getFileByPath(arguments.path);
	if(not rs.success){
		return rs;
	}
	newPath=request.zos.globals.privateHomeDir&"zuploadsecure/cloud_files_temp/";
	application.zcore.functions.zCreateDirectory(newPath);

	ext=application.zcore.functions.zGetFileExt(rs.data.cloud_file_local_path);
	newFilePath=newPath&"tmp"&dateformat(now(), "yyyymmdd")&timeformat(now(), "HHmmss")&gettickcount()&"."&ext;
	localPath=rs.data.config.localPath&removeChars(rs.data.cloud_file_local_path, 1, 1);
	if(rs.data.cloud_file_is_local EQ 1){
		application.zcore.functions.zCopyFile(localPath, newFilePath, true);

		return {success:true, path:newFilePath};
	}else{
		rs=makeFileAvailableOffline(rs.data);
		if(rs.success){
			result=application.zcore.functions.zRenameFile(localPath, newFilePath);
			if(result){
				return {success:true, path:newFilePath};
			}
		}
	}

	return {success:false, errorMessage:"Failed to make temporary file"};
	</cfscript>

</cffunction>  

<cffunction name="directDownloadFile" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	rs=getFileByPath(arguments.path);
	if(rs.success){
		if(rs.data.cloud_file_is_secure EQ 1){
			application.zcore.functions.z404("Access denied");
		}
		application.zcore.functions.zXSendFile(application.zcore.cloudVendor[rs.data.cloud_vendor_id].getDownloadLink(rs.data));
	}
	</cfscript>
</cffunction>

<cffunction name="getFileById" localmode="modern" access="public">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("cloud_file")# WHERE 
	cloud_file_id=#db.param(arguments.id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	cloud_file_deleted=#db.param(0)#";
	qFile=db.execute("qFile");
	for(row in qFile){
		row.config=getConfig(row.cloud_file_config_id);
		return { success:true, data: row };
	}
	return {success:false, errorMessage:"File doesn't exist"};
	</cfscript>
</cffunction>

<cffunction name="getFileByPath" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("cloud_file")# WHERE 
	cloud_file_local_path=#db.param(arguments.path)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	cloud_file_deleted=#db.param(0)#";
	qFile=db.execute("qFile");
	for(row in qFile){
		row.config=getConfig(row.cloud_file_config_id);
		return { success:true, data: row };
	}
	return {success:false, errorMessage:"File doesn't exist"};
	</cfscript>
</cffunction>


<cffunction name="executePurgeOldFiles" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject; 
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	request.ignoreSlowScript=true;
	setting requesttimeout="5000";

	oldDate=dateadd("d", -30, now()); 

	db.sql="select site.site_id, site.site_domain from #db.table("cloud_file")#, 
	#request.zos.queryObject.table("site", request.zos.zcoreDatasource)#
	WHERE  
	cloud_file.site_id = site.site_id and 
	site.site_deleted=#db.param(0)# and 
	site.site_active=#db.param(1)# and  
	cloud_file_deleted_datetime<#db.param(dateformat(oldDate, "yyyy-mm-dd")&" "&timeformat(oldDate, "HH:mm:ss"))# and
	cloud_file_deleted<>#db.param(0)#  and 
	site.site_id <> #db.param(-1)# 
	GROUP BY site.site_id ";
	qC=db.execute("qC");
	// later loop all domains with this feature enabled in server manager.
	loop query="qC"{ 
		r1=application.zcore.functions.zdownloadlink(qC.site_domain&"/z/_com/zos/cloudFile/purgeOldFiles");
		if(r1.success){
			writeoutput(r1.cfhttp.FileContent);
		}else{
			writeoutput('<h2>Failed to purgeOldFiles</h2>');
			writedump(r1.cfhttp);
		}
	}
	writeoutput('Done');
	abort;
	</cfscript>
</cffunction>
	

<cffunction name="purgeOldFiles" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer and server ips can access this");
	}

	oldDate=dateadd("d", -1, now()); 

	newPath=request.zos.globals.privateHomeDir&"zuploadsecure/cloud_files_temp/";
	if(directoryexists(newPath)){
		qFile=directoryList(newPath, true, 'query');
		count=0;
		for(row in qFile){
			if(datecompare(row.dateLastModified, oldDate) EQ -1){
				echo('delete 1 day old temp file:'&newPath&row.name&'<br>');
				count++;
				application.zcore.functions.zDeleteFile(newPath&row.name);
			}
		}
	}
	oldDate=dateadd("d", -30, now()); 

	db.sql="select * from #db.table("cloud_file")# WHERE  
	site_id=#db.param(request.zos.globals.id)# and 
	cloud_file_deleted_datetime<#db.param(dateformat(oldDate, "yyyy-mm-dd")&" "&timeformat(oldDate, "HH:mm:ss"))# and
	cloud_file_deleted<>#db.param(0)#";
	qFile=db.execute("qFile"); 
	for(row in qFile){
		row.config=getConfig(row.cloud_file_config_id);
		echo('purging 30 day old file for path:'&row.cloud_file_local_path&'<br>');
		purgeFile(row);
		count++;
	}
	echo('#count# old files permanently deleted');
	abort;
	</cfscript>
</cffunction>

<cffunction name="listContainers" localmode="modern" access="public">
	<cfscript>
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("Disabled in production until completed");
	}
	if(not request.zos.isDeveloper){
		application.zcore.functions.z404("Only developer and server ips can access this");
	}
	form.sid=application.zcore.functions.zso(form, 'sid', true, request.zos.globals.id);
	echo('<h2>Cloud File Containers</h2>
		<h2>Warning - this feature is incomplete</h2>
	<p>You can use this tool to make a backup of a site''s cloud files by setting sync mode to "Local Filesystem Only" or "Both" below.  Once sync is complete you can use the regular site backup function in the server manager to download all the uploaded files.</p>
	<p>You can also use this tool to send all the local files for this site to the cloud and delete the local copy by selecting "Cloud Only" below.</p>
	<p>Warning: any active transfer / file processing may be interupted when you change the sync mode below.  It is recommended only to change sync setting during non-peak hours or on a test server.</p>
	<p>The setting you apply below will only be used to sync the existing files.  New files will be synced according to the application''s configuration.</p>
	<p>It may take a very long time to download/upload the files if there is a lot data stored. </p>

	<h3>Want to override how files are stored for 1 or more containers?</h3>
	<p>Select sync mode: 
	<input type="radio" name="mode" value="cloud"> Cloud Only 
	<input type="radio" name="mode" value="local"> Local Filesystem Only 
	<input type="radio" name="mode" value="both" checked="checked"> Both (default)</p>');
	db=request.zos.queryObject;
	db.sql="select cloud_file_container_local_name, 
	count(cloud_file_id) fileCount, 
	sum(cloud_file_size) totalSize,
	sum(cloud_file_is_local) localCount,
	sum(cloud_file_is_online) onlineCount
	from #db.table("cloud_file")# WHERE  
	site_id=#db.param(form.sid)#  and 
	cloud_file_deleted=#db.param(0)# 
	GROUP BY cloud_file_container_local_name";
	qContainer=db.execute("qContainer"); 
	echo('
		<form action="#application.zcore.functions.zVar("domain", form.sid)#/z/server-manager/admin/cloud-admin/processContainers" method="post">
		<table class="table-list">
		<tr>
		<td>&nbsp;</td>
		<th>Container</th>
		<th>## of Files</th>
		<th>Local Total</th>
		<th>Cloud Total</th>
		<th>Total Size</th>
	</tr>');
	for(row in qContainer){
	echo('
		<tr>
		<td><input type="checkbox" name="containers" value="#htmleditformat(row.cloud_file_container_local_name)#" checked="checked"></td>
		<td>#row.cloud_file_container_local_name#</td>
		<td>#row.fileCount#</td>
		<td>#row.localCount#</td>
		<td>#row.onlineCount#</td>
		<td>#numberformat(row.totalSize/1024/1024, '_.__')#mb</td>
	</tr>');
	}
	echo('</table>
		<div class="pleaseWaitDiv1 z-float z-bold z-p-10" style="display:none;">This may take a long time. Please Wait...</div>
		<div class="z-float z-p-10">
		<input type="submit" name="backup1" value="Sync Files Now" onclick="$(this).hide(); $(''.pleaseWaitDiv1'').show();" /> 
		</div>
		</form>');
	</cfscript>
</cffunction>

<cffunction name="processContainers" localmode="modern" access="public">
	<cfscript>
	if(not request.zos.isTestServer){
		application.zcore.functions.z404("Disabled in production until completed");
	}
	if(not request.zos.isDeveloper){
		application.zcore.functions.z404("Only developer and server ips can access this");
	}
	form.mode=application.zcore.functions.zso(form, 'mode');
	if(form.mode EQ ""){
		application.zcore.functions.z404("Invalid request");
	}
	if(form.mode EQ "local" or form.mode EQ "both"){
		// TODO consider a more efficient queue based approach that returns instantly so that the user can't abuse system.
		arrContainer=listToArray(application.zcore.functions.zso(form, 'containers'), ",");
		db=request.zos.queryObject;
		db.sql="select * from #db.table("cloud_file")# WHERE  
		site_id=#db.param(request.zos.globals.id)# and 
		cloud_file_is_local=#db.param(0)# ";
		if(arrayLen(arrContainer)){
			db.sql&=" and ( ";
			for(i=1;i<=arrayLen(arrContainer);i++){
				if(i NEQ 1){
					db.sql&=" or ";
				}
				db.sql&=" cloud_file_container_local_name=#db.param(arrContainer[i])# ";
			}
			db.sql&=" ) ";
		}
		db.sql&=" and cloud_file_deleted=#db.param(0)#";
		qFile=db.execute("qFile"); 
	 
		application.zcore.functions.zSetRequestTimeout(10000); 
		count=0;
		queueHttpCom=createobject("component", "zcorerootmapping.com.app.queue-http");
		for(row in qFile){
			row.config=getConfig(row.cloud_file_config_id);

			db.sql="update #db.table("cloud_file", request.zos.zcoreDatasource)# SET 
			cloud_file_sync_to_local=#db.param(1)#, ";
			if(form.mode EQ "local"){
				db.sql&=" cloud_file_disable_online=#db.param(1)#,
				cloud_file_sync_delete_remote=#db.param(1)#, ";
			}
			db.sql&=" cloud_file_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE cloud_file_id=#db.param(row.cloud_file_id)# and 
			site_id=#db.param(request.zos.globals.id)# and 
			cloud_file_deleted=#db.param(0)#";
			db.execute("qUpdate");

			seconds=round(10*(row.cloud_file_size/1024/1024)); 
			ts={
				name:"zCloudFile-#row.site_id#-#row.cloud_file_id#",
				url:request.zos.globals.domain&"/z/_com/zos/cloudFile?method=syncToLocal&cloud_file_id=#row.cloud_file_id#",
				timeout:seconds,
				retry_interval:60,
				postVars:{},
				headerVars:{},
				apiId:1 // cloud files - local
			}
			r=queueHttpCom.queueHTTPRequest(ts);

			/*
			rs=makeFileAvailableOffline(row); 
			if(rs.success){
				db.sql="update #db.table("cloud_file", request.zos.zcoreDatasource)# SET 
				cloud_file_is_local=#db.param(1)#, ";
				if(form.mode EQ "local"){
					db.sql&=" cloud_file_disable_online=#db.param(1)#, ";
				}
				db.sql&=" cloud_file_updated_datetime=#db.param(request.zos.mysqlnow)#
				WHERE cloud_file_id=#db.param(row.cloud_file_id)# and 
				site_id=#db.param(request.zos.globals.id)# and 
				cloud_file_deleted=#db.param(0)#";
				db.execute("qUpdate");
			}*/
			count++;
		}
		echo('#count# files made available offline for this site.');
	}
	if(form.mode EQ "cloud" or form.mode EQ "both"){
		db.sql="select * from #db.table("cloud_file")# WHERE  
		site_id=#db.param(request.zos.globals.id)# and 
		cloud_file_is_online=#db.param(0)# ";
		if(arrayLen(arrContainer)){
			db.sql&=" and ( ";
			for(i=1;i<=arrayLen(arrContainer);i++){
				if(i NEQ 1){
					db.sql&=" or ";
				}
				db.sql&=" cloud_file_container_local_name=#db.param(arrContainer[i])# ";
			}
			db.sql&=" ) ";
		}
		db.sql&=" and cloud_file_deleted=#db.param(0)#";
		qFile=db.execute("qFile"); 
	 
		application.zcore.functions.zSetRequestTimeout(10000); 
		count=0;
		for(row in qFile){
			db.sql="update #db.table("cloud_file", request.zos.zcoreDatasource)# SET ";
			if(form.mode EQ "cloud"){
				db.sql&=" cloud_file_sync_delete_local=#db.param(1)#, ";
			}
			db.sql&=" 
			cloud_file_sync_to_remote=#db.param(1)#, 
			cloud_file_disable_online=#db.param(0)#,
			cloud_file_updated_datetime=#db.param(request.zos.mysqlnow)#
			WHERE cloud_file_id=#db.param(row.cloud_file_id)# and 
			site_id=#db.param(request.zos.globals.id)# and 
			cloud_file_deleted=#db.param(0)#";
			db.execute("qUpdate");

			seconds=round(10*(row.cloud_file_size/1024/1024)); 
			ts={
				name:"zCloudFile-#row.site_id#-#row.cloud_file_id#",
				url:request.zos.globals.domain&"/z/_com/zos/cloudFile?method=syncToServer&cloud_file_id=#row.cloud_file_id#",
				timeout:seconds,
				retry_interval:600,
				postVars:{},
				headerVars:{},
				apiId:1 // cloud files - local
			}
			r=queueHttpCom.queueHTTPRequest(ts);
				/*
			row.config=getConfig(row.cloud_file_config_id);
			rs=storeOnline(row); 
			if(rs.success){
				db.sql="update #db.table("cloud_file", request.zos.zcoreDatasource)# SET 
				cloud_file_is_online=#db.param(1)#, 
				cloud_file_url=#db.param(rs.cloud_file_url)#,
				cloud_file_updated_datetime=#db.param(request.zos.mysqlnow)#
				WHERE cloud_file_id=#db.param(row.cloud_file_id)# and 
				site_id=#db.param(request.zos.globals.id)# and 
				cloud_file_deleted=#db.param(0)#";
				db.execute("qUpdate");
			}*/
			count++;
		}
		echo('#count# files synced to the cloud on this site.');
	}
	abort;
	</cfscript>
</cffunction>

<!--- Internal --->

<cffunction name="downloadFile" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript> 
	// guarantees cloud_file_url is never shared publicly, so we can "delete" files, without removing them from CDN
	
	// use X-Accel-Redirect and proxy_pass like this: http://distinctplace.com/infrastructure/2013/09/18/use-nginx-to-proxy-files-from-remote-location-using-x-accel-redirect/
	// be sure to hide the headers returned from cloud vendor for added security
	// also consider passing basic authentication parameters to proxy to further protect files 
	application.zcore.functions.zXSendFile(application.zcore.cloudVendor[arguments.ds.cloud_vendor_id].getDownloadLink(arguments.ds));
	</cfscript>
</cffunction>
 

<!--- vendor specific --->

<!--- synchronous call to download the file to local filesystem --->
<cffunction name="makeFileAvailableOffline" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript> 
	ds=arguments.ds;
	if(ds.cloud_file_is_local EQ 1){
		return {success:true};
	}
	if(ds.cloud_file_sync_delete_local EQ 1){
		return {success:false, errorMessage:'Sync is in progress, please try again later.'};
	}
	// allow 10 seconds per megabyte to download file
	seconds=round(10*(ds.cloud_file_size/1024/1024));
	application.zcore.functions.zSetRequestTimeout(seconds+5); 

	return application.zcore.cloudVendor[arguments.ds.cloud_vendor_id].makeFileAvailableOffline(arguments.ds);
	</cfscript>
</cffunction>

<cffunction name="purgeFile" localmode="modern" access="private">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds;
	result=application.zcore.cloudVendor[ds.cloud_vendor_id].purgeFile(ds);
	if(not result){
		return {success:false, errorMessage:'Failed to purge remote file for path: #db.cloud_file_local_path#'};
	}
	if(ds.cloud_file_is_local EQ 1){
		path=ds.config.localPath&removechars(ds.cloud_file_local_path, 1, 1);
		//echo('Delete local file: #path#<br>');
		application.zcore.functions.zdeletefile(path); 
	}
	db=request.zos.queryObject;
	db.sql="delete from #db.table("cloud_file", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	cloud_file_deleted<>#db.param(-1)# and 
	cloud_file_id=#db.param(ds.cloud_file_id)#";
	db.execute("qDelete");
	//echo('Record deleted for: #ds.cloud_file_local_path#<br>');
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="storeOnline" localmode="modern" access="private">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	// put file to cloud vendor 
	seconds=round(10*(arguments.ds.cloud_file_size/1024/1024));
	application.zcore.functions.zSetRequestTimeout(seconds+5); 

	return application.zcore.cloudVendor[arguments.ds.cloud_vendor_id].storeOnline(arguments.ds);
	</cfscript>
</cffunction>
</cfcomponent>