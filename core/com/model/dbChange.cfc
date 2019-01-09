<cfcomponent>
<!--- 

//dbChange.cfc 
purpose of this component
	create multiple database and file records as one transaction.
	allow these records to be synchronized with another server in both directions (multiple master replication).
	store the entire changeset as a semi-permanent version record that can be restored by the cms user.
	allowing disabling server sync & versioning in one place in the application

	rewrite the app to generate a schema change set using getNewId and structs in memory, instead of applying live changes to database in each component.
		requires a new version of all related components
			call them contentNew.cfc, imageLibraryNew.cfc until it's done everywhere.
		pass a dbChange object to each component so that it can append additional change operations to it.


	if a file has been deleted or changed, we need to preserve the previous version by renaming it, so robots/users can't see it while it is archived, but it still exists.

	if you restore from version table, then it will need to rename those files back to the original name, but also guarantee they are not conflicting, and update the database at the same time.
		each record that touches a file has to be upgraded to understand this process, so it would be better if all files were stored in a single table, so all the code is shared, otherwise each component would have to implement the same functions, which is more efficient, but prone to bugs.
			favor the more efficient approach because it doesn't add query overhead in display of records.
	

usage:
dbChange=request.zos.dbChange;
dbChange.setTable(request.zos.zcoreDatasource, "content");
ts={
	schema:request.zos.zcoreDatasource,
	table:"content",
	struct:{
		field:"value"
	},
	whereStruct:{
		primaryKey:"value",
		site_id:"value"
	}
}
dbChange.update(ts);

ts={
	schema:request.zos.zcoreDatasource,
	table:"content",
	struct:{
		field:"value"
	}
}
content_id=dbChange.insert(ts);

ts={
	schema:request.zos.zcoreDatasource,
	table:"content",
	struct:{
		field:"value"
	}
}
dbChange.replace(ts);

ts={
	schema:request.zos.zcoreDatasource,
	table:"content",
	whereStruct:{
		primaryKey:"value",
		site_id:"value"
	}
}
dbChange.delete(ts);
dbChange.setPreview("title", "summary HTML");

ts={
	type:"site",
	site_id:request.zos.globals.id
};
dbChange.clearCache(ts);

transactionResult=dbChange.commit();
if(!transactionResult){
	// delete temporary files
	application.zcore.functions.zdeletefile(filePath);
	request.zos.imageLibraryCom.deleteCurrentRequestFiles();

	// redirect with error
	application.zcore.status.setStatus(request.zsid, "Failed to save X", form, true);
	if(form.method EQ "insert"){
		application.zcore.functions.zRedirect("/z/admin/content/add?zsid=#request.zsid#");
	}else{
		application.zcore.functions.zRedirect("/z/admin/content/edit?zsid=#request.zsid#&content_id=#content_id#");
	}
}

 --->

<cffunction name="storeChange" access="private" localmode="modern">
	<cfargument name="type" type="string" requires="yes">
	<cfargument name="struct" type="struct" requires="yes">
	<cfscript>
	if(not structkeyexists(variables, 'arrChange')){
		variables.arrChange=[];
		variables.preview_title="Untitled Version";
		variables.preview_html="";
		variables.arrFileChange=[];
		variables.arrFileArchive=[];
	}
	tableStruct=application.zcore.versionSyncTableStruct[arguments.struct.schema][arguments.struct.table];
	if(tableStruct.hasSiteId){
		if(arguments.type EQ "delete" or arguments.type EQ "update"){
			if(not structkeyexists(arguments.struct.whereStruct, 'site_id')){
				throw("arguments.struct.whereStruct.site_id is required when arguments.type is delete or update.");
			}
			sid=arguments.struct.whereStruct["site_id"];
		}else{
			if(not structkeyexists(arguments.struct.struct, 'site_id')){
				throw("arguments.struct.struct.site_id is required when arguments.type is insert or replace.");
			}
			sid=arguments.struct.struct["site_id"];
		}
	}else{
		sid="";
	}
	originalData=application.zcore.functions.zGetDataById(arguments.type, arguments.struct.schema, arguments.struct.table, tableStruct.primaryKey, arguments.struct[tableStruct.primaryKey], sid);
	timestamp=dateformat(now(), 'yyyymmdd')&NumberFormat(timeformat(now(), 'HHmmssl'),"000");
	structappend(arguments.struct, originalData, false);
	for(field in tableStruct.fileFieldStruct){
		if(compare(originalData[field], arguments.struct[field]) NEQ 0){
			filePath=tableStruct.fileFieldStruct[field](originalData);
			fileName="zarchived-"&createuuid()&"."&application.zcore.functions.zGetFileExt(getFileFromPath(filePath));
			path=getDirectoryFromPath(filePath);
			ts={
				originalPath: filePath,
				newPath: path&fileName
			}
			arrayAppend(variables.arrFileArchive, ts);
			if(arguments.struct[field] NEQ ""){
				arrayAppend(variables.arrFileChange, arguments.struct[field]);
			}
		}
	}
	
	arrayAppend(variables.arrChange, {
		type: arguments.type,
		data: arguments.struct,
		originalData: originalData // used for restoring previous state
	});
	</cfscript>
</cffunction>



<cffunction name="clearCache" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	if(not structkeyexists(arguments.struct, 'type')){
		throw('arguments.struct.type is required and must be "site" or "app".');
	}
	if(arguments.struct.type EQ "site" and not structkeyexists(arguments.struct, 'site_id')){
		throw('arguments.struct.site_id is required when form.type equals "site".');
	}
	arrayAppend(variables.arrClearCache, arguments.struct);

	</cfscript>
</cffunction>

<!--- 
arrId=getNewId(request.zos.zcoreDatasource, "content", "content_id", request.zos.globals.id, 1);
ts.struct.content_id=arrId[0];

generating the id is not required if I set the id to version_json_data struct prior to inserting the version record.   This getNewId just makes it faster, but then forces all work to use CFML for these tables.
 --->
<cffunction name="generateNewId" access="public" localmode="modern" returntype="array" hint="primary_key_id of versioned/synced records must be generated to avoid conflicts.  This also must be thread-safe and allow efficiently grabbing multiple ids at once.">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="count" type="string" required="yes">
	<cfscript>
	r=[];
	if(not structkeyexists(application.zcore.versionSyncTableStruct, arguments.schema)){
		throw('Schema, "#arguments.schema#", not defined in application.zcore.versionSyncTableStruct');
	}else if(not structkeyexists(application.zcore.versionSyncTableStruct[arguments.schema], arguments.table)){
		throw('Table, "#arguments.table#", not defined in application.zcore.versionSyncTableStruct["#arguments.schema#"]');
	}
	c=application.zcore.versionSyncTableStruct[arguments.schema][arguments.table];
	siteId="";
	idStruct=idGenerationStruct[schema][table];
	if(c.hasSiteId){
		siteId=arguments.site_id;
		if(not structkeyexists(idStruct, siteId)){
			idStruct[siteId]={};
		}
		idStruct=idStruct[siteId];
	}
	lock type="exclusive" name="#arguments.schema#-#arguments.table#-#siteId#-primary-key-generation" timeout="10"{
		for(i=0;i<arguments.count;i++){
			if(c.hasSiteID){
				idGenerationStruct[schema][table][siteId]+=application.zcore.databaseIncrementIncrement;
				nextId=idGenerationStruct[schema][table][siteId];
			}else{
				idGenerationStruct[schema][table]+=application.zcore.databaseIncrementIncrement;
				nextId=idGenerationStruct[schema][table];
			}
			arrayAppend(r, nextId);
		}
	}
	return r;
	</cfscript>
</cffunction>

<cffunction name="insert" access="public" localmode="modern" returntype="numeric">
	<cfargument name="struct" type="struct" requires="yes">
	<cfscript>
	tableStruct=application.zcore.versionSyncTableStruct[arguments.struct.schema][arguments.struct.table];
	if(tableStruct.hasSiteId){
		if(not structkeyexists(arguments.struct.struct, 'site_id')){
			throw("arguments.struct.struct.site_id is required");
		}
	}
	if(not structkeyexists(arguments.struct.struct, tableStruct.primaryKey)){
		// generate id
		if(tableStruct.hasSiteId){
			arrId=generateNewId(arguments.struct.schema, arguments.struct.table, tableStruct.primaryKey, arguments.struct.struct.site_id, 1);
		}else{
			arrId=generateNewId(arguments.struct.schema, arguments.struct.table, tableStruct.primaryKey, "", 1);
		}
		newId=arrId[0];
		arguments.struct.struct[tableStruct.primaryKey]=newId;
	}else{
		newId=arguments.struct.struct[tableStruct.primaryKey];
	}
	storeChange("insert", arguments.struct);
	return newId;
	</cfscript>
</cffunction>

<cffunction name="delete" access="public" localmode="modern">
	<cfargument name="struct" type="struct" requires="yes">
	<cfscript>
	storeChange("delete", arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="update" access="public" localmode="modern">
	<cfargument name="struct" type="struct" requires="yes">
	<cfscript>
	storeChange("update", arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="replace" access="public" localmode="modern">
	<cfargument name="struct" type="struct" requires="yes">
	<cfscript>
	storeChange("replace", arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="setTable" access="public" localmode="modern" hint="Setting the primary table for this dbChange set, allows the restore user interface to function.">
	<cfargument name="schema" type="string" required="yes">
	<cfargument name="table" type="string" required="yes">
	<cfscript>
	variables.schema=arguments.schema;
	variables.table=arguments.table;
	if(variables.schema NEQ request.zos.zcoreDatasource){
		throw('arguments.schema must be "#request.zos.zcoreDatasource#", and it was set to "#arguments.schema#".');
	}
	</cfscript>
</cffunction>

<cffunction name="setPreview" access="public" localmode="modern">
	<cfargument name="title" type="string" required="yes">
	<cfargument name="html" type="string" required="yes">
	<cfscript>
	variables.preview_title=arguments.title;
	variables.preview_html=arguments.html;
	</cfscript>
</cffunction>

<cffunction name="setSiteId" access="public" localmode="modern">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	variables.site_id=arguments.site_id;
	</cfscript>
</cffunction>

<cffunction name="commit" access="public" localmode="modern" returntype="boolean">
	<cfscript>
	if(not structkeyexists(variables, 'arrChange')){
		throw("You must run at least one change function before running commit.  I.e. insert, replace, update or delete.");
	}
	if(not structkeyexists(variables, 'schema')){
		throw("You must run fileService.setTable() before fileService.commit().");
	}
	if(not structkeyexists(variables, 'arrFileArchive')){
		variables.arrFileArchive=[];
	}
	if(not structkeyexists(variables, 'site_id')){
		variables.site_id=request.zos.globals.id;
	}
	for(i=1;i<=arraylen(variables.arrChange);i++){
		n=variables.arrChange[i];
		if(variables.schema NEQ n.data.schema){
			savecontent variable="out"{
				writedump(n);//, true, 'simple');
			}
			throw('All queries must be run against the primary datasource, "#variables.schema#" set with setTable. 
				The following database change struct schema didn''t match:<br />'&out);
		}
	}
	try{
		// start transaction
		transaction action="begin"{
			for(i=1;i<=arraylen(variables.arrChange);i++){
				n=variables.arrChange[i];
				if(n.type EQ "insert"){
					executeInsert(n.data);
				}else if(n.type EQ "update"){
					executeUpdate(n.data);
				}else if(n.type EQ "replace"){
					executeReplace(n.data);
				}else if(n.type EQ "delete"){
					executeDelete(n.data);
				}
			}

			if(request.zos.enableDatabaseVersioning){
				dataStruct={
					arrChange: variables.arrChange,
					arrFileChange: variables.arrFileChange,
					arrFileArchive: variables.arrFileArchive
				};
				ts={
					datasource: variables.schema,
					table: "version",
					struct:{
						version_datetime: request.zos.mysqlnow,
						version_json_data: serializeJson(dataStruct),
						server_id: request.zos.server_id,
						site_id: variables.site_id,
						version_uuid: createuuid(),
						version_preview_title: variables.preview_title,
						version_preview_html: variables.preview_html,
						version_schema: variables.schema,
						version_table: variables.table
					}
				}
				executeInsert(ts);
				variables.fileRenameStruct={};
				for(i=1;i<=arraylen(variables.arrFileArchive);i++){
					currentFile=variables.arrFileArchive[i];
					if(fileexists(currentFile.originalPath)){
						variables.fileRenameStruct[currentFile.originalPath]=currentFile.newPath;
						application.zcore.functions.zRenameFile(currentFile.originalPath, currentFile.newPath);
					}
				}
			}
			transaction action="commit";
		}
	}catch(Any e){
		// transaction failed.
		try{
			transaction action="rollback";
		}catch(Any e2){
			// ignore rollback failures
		}
		reset(true);
		return false;
	}
	reset(false);
	return true;
	</cfscript>
</cffunction>

<cffunction name="reset" localmode="modern" access="public">
	<cfargument name="restoreFiles" type="boolean" required="yes">
	<cfscript>
	if(arguments.restoreFiles && structkeyexists(variables, 'fileRenameStruct')){
		for(i in variables.fileRenameStruct){
			application.zcore.functions.zRenameFile(variables.fileRenameStruct[i], i);
		}
	}
	variables.fileRenameStruct={};
	variables.arrFileArchive=[];
	variables.arrChange=[];
	</cfscript>
</cffunction>

<cffunction name="dump" access="public" localmode="modern">
	<cfscript>
	writedump(variables);//, true, 'simple');
	</cfscript>
</cffunction>


<cffunction name="executeInsert" access="private" localmode="modern">
	<cfargument name="struct" type="struct" requires="yes">
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	n=arguments.struct;
	savecontent variable="db.sql"{
		echo("INSERT INTO #db.table(n.table, n.schema)# SET ");
		first=true;
		for(i in arguments.fieldStruct){
			if(!first){
				first=false;
				echo(", "&chr(10));
			}
			echo('`#application.zcore.functions.escape(i)#`=#db.param(n.struct[i])# ');
		}
	}
	qInsert=db.execute("qInsert");
	</cfscript>
</cffunction>


<cffunction name="executeReplace" access="private" localmode="modern">
	<cfargument name="struct" type="struct" requires="yes">
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	n=arguments.struct;
	savecontent variable="db.sql"{
		echo("REPLACE INTO #db.table(n.table, n.schema)# SET ");
		first=true;
		for(i in arguments.fieldStruct){
			if(!first){
				first=false;
				echo(", "&chr(10));
			}
			echo('`#application.zcore.functions.escape(i)#`=#db.param(n.struct[i])# ');
		}
	}
	qReplace=db.execute("qReplace");
	</cfscript>
</cffunction>

<cffunction name="executeUpdate" access="private" localmode="modern">
	<cfargument name="struct" type="struct" requires="yes">
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	n=arguments.struct;
	savecontent variable="db.sql"{
		echo("UPDATE #db.table(n.table, n.schema)# SET ");
		first=true;
		for(i in arguments.fieldStruct){
			if(structkeyexists(n.whereStruct, i)){
				continue;
			}
			if(!first){
				first=false;
				echo(", "&chr(10));
			}
			echo('`#application.zcore.functions.escape(i)#`=#db.param(n.struct[i])# ');
		}
		echo("WHERE ");
		first=true;
		for(i in n.whereStruct){
			if(!first){
				first=false;
				echo(" and "&chr(10));
			}
			echo('`#application.zcore.functions.escape(i)#`=#db.param(n.whereStruct[i])# ');
		}
	}
	qUpdate=db.execute("qUpdate");
	</cfscript>
</cffunction>

<cffunction name="executeDelete" access="private" localmode="modern">
	<cfargument name="struct" type="struct" requires="yes">
	<cfscript>
	db=request.zos.queryObject;
	n=arguments.struct;
	savecontent variable="db.sql"{
		echo("DELETE FROM #db.table(n.table, n.schema)# WHERE ");
		first=true;
		for(i in n.whereStruct){
			if(!first){
				first=false;
				echo(" and "&chr(10));
			}
			echo('`#application.zcore.functions.escape(i)#`=#db.param(n.whereStruct[i])# ');
		}
	}
	qDelete=db.execute("qDelete");
	</cfscript>
</cffunction>
</cfcomponent>