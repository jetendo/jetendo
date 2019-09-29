<cfcomponent>
<cfoutput>
<cffunction name="copySchemaRecursive" localmode="modern" access="public" roles="member">
	<cfargument name="feature_data_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="rowStruct" type="struct" required="yes">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=arguments.rowStruct;
	row.feature_data_override_url="";
	row.feature_data_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');
	row.site_id = arguments.site_id;
	mainSchema=arguments.groupStruct[row.feature_schema_id].data;
	dataFields=application.zcore.featureCom.parseFieldData(row);

	if(row.feature_data_image_library_id NEQ 0){

		logCopyMessage('Copying image library for set ###arguments.feature_data_id#');
		row.feature_data_image_library_id=application.zcore.imageLibraryCom.copyImageLibrary(row.feature_data_image_library_id, row.site_id);
	}

	logCopyMessage('Copying set ###arguments.feature_data_id#');
	db.sql="select * from 
	#db.table("feature_field", request.zos.zcoreDatasource)# WHERE 
	feature_schema_id = #db.param(row.feature_schema_id)# and 
	feature_field_deleted=#db.param(0)# 
	ORDER BY feature_field_sort ASC";
	qField=db.execute("qField");
	typeCache={};
	tempPath=application.zcore.functions.zvar('privatehomedir', arguments.site_id);
	arrFieldOrder=[];
	arrDataOrder=[];
	for(row2 in qField){
		value=dataFields[row2.feature_field_variable_name];
		if(value NEQ ""){
			if(structkeyexists(arguments.typeStruct, row2.feature_field_id)){
				typeId=arguments.typeStruct[row2.feature_field_id].data.feature_field_type_id;
				if(typeId EQ 9){
					tempFieldStruct=arguments.typeStruct[row2.feature_field_id].type;
					path=tempPath;
					if(application.zcore.functions.zso(tempFieldStruct, 'file_securepath') EQ 'Yes'){
						path&='zuploadsecure/feature-options/';
					}else{
						path&='zupload/feature-options/';
					}
				}else if(typeId EQ 3){
					path=tempPath&'zupload/feature-options/';
				}else if(typeId EQ 23){ 
					dataFields[row2.feature_field_variable_name]=application.zcore.imageLibraryCom.copyImageLibrary(value, row2.site_id);
				}else if(typeId EQ 21){
					db.sql="select * from #db.table("mls_saved_search", request.zos.zcoreDatasource)# WHERE 
					site_id = #db.param(row2.site_id)# and 
					mls_saved_search_id=#db.param(value)# and 
					mls_saved_search_deleted=#db.param(0)# ";
					qV=db.execute("qV");
					for(r2 in qV){
						structdelete(r2, 'mls_saved_search_id');
						r2.mls_saved_search_updated_datetime=request.zos.mysqlnow;
						ts=structnew();
						ts.struct=r2;
						ts.datasource=request.zos.zcoreDatasource;
						ts.table="mls_saved_search";
						dataFields[row2.feature_field_variable_name]=application.zcore.functions.zInsert(ts);
					}
				}
				if(typeId EQ 3){
					arrValue=listToArray(value, chr(9));
					if(arrValue[1] NEQ ""){
						newPath=application.zcore.functions.zcopyfile(path&arrValue[1]);
						arrValue[1]=getfilefrompath(newPath); 
					}
					if(arrayLen(arrValue) EQ 2 and arrValue[2] NEQ ""){
						newPath=application.zcore.functions.zcopyfile(path&arrValue[2]);
						arrValue[2]=getfilefrompath(newPath);
					}
					dataFields[row2.feature_field_variable_name]=arrayToList(arrValue, chr(9));
				}else if(typeId EQ 9){
					newPath=application.zcore.functions.zcopyfile(path&value);
					dataFields[row2.feature_field_variable_name]=getfilefrompath(newPath); 
				}
			}
		}
		arrayAppend(arrFieldOrder, row2.feature_field_id);
		arrayAppend(arrDataOrder, dataFields[row2.feature_field_variable_name]);
	}
	row.feature_data_field_order=arrayToList(arrFieldOrder, chr(13));
	row.feature_data_data=arrayToList(arrDataOrder, chr(13));
	ts=structnew();
	ts.struct=row;
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="feature_data";
	newSetId=application.zcore.functions.zInsert(ts);


	db.sql="select * from 
	#db.table("feature_data", request.zos.zcoreDatasource)# WHERE 
	feature_data_parent_id = #db.param(arguments.feature_data_id)# and 
	feature_data_master_set_id = #db.param(0)# and 
	feature_data_deleted=#db.param(0)#  and 
	site_id = #db.param(arguments.site_id)# ";
	qChild=db.execute("qChild");
	typeCache={};
	for(row3 in qChild){
		row3.feature_data_parent_id=newSetId;
		childSetId=this.copySchemaRecursive(row3.feature_data_id, arguments.site_id, row3, arguments.groupStruct, arguments.typeStruct);
		// if current record is merge, then update 
		if(mainSchema.feature_schema_enable_merge_interface EQ 1){
			db.sql="UPDATE #db.table("feature_data", request.zos.zcoreDatasource)# 
			SET 
			feature_data_merge_schema_id=#db.param(row3.feature_schema_id)#,
			feature_data_merge_data_id=#db.param(childSetId)# 
			WHERE 
			site_id=#db.param(request.zos.globals.id)# and 
			feature_data_id=#db.param(newSetId)# and 
			feature_data_deleted=#db.param(0)# ";
			db.execute("qUpdate");
		}
	}
	return newSetId;
	</cfscript>
</cffunction>

<cffunction name="getSchemas" localmode="modern" access="public" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	groupStruct={};
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# WHERE 
	feature_id=#db.param(form.feature_id)# and 
	feature_schema_deleted=#db.param(0)#";
	qSchema=db.execute("qSchema");
	for(row in qSchema){
		groupStruct[row.feature_schema_id]={
			data: row
		}
	}
	return groupStruct;
	</cfscript>
	
</cffunction>

<cffunction name="getFields" localmode="modern" access="public" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	typeStruct={};
	db.sql="select * from #db.table("feature_field", request.zos.zcoreDatasource)# WHERE 
	feature_id=#db.param(form.feature_id)# and 
	feature_field_deleted=#db.param(0)# and 
	feature_schema_id <> #db.param(0)#";
	qField=db.execute("qField");
	for(row in qField){
		typeStruct[row.feature_field_id]={
			data: row,
			type: deserializeJson(row.feature_field_type_json)
		}
	}
	return typeStruct;
	</cfscript>
</cffunction>

<cffunction name="getCopyMessage" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	rs={
		success:true,
		message:application.zcore.functions.zso(request.zsession, 'siteSchemaDeepCopyMessage')
	};
	application.zcore.functions.zReturnJSON(rs);
	</cfscript>
</cffunction>
	
<cffunction name="logCopyMessage" localmode="modern" access="public" roles="member">
	<cfargument name="message" type="string" required="yes">
	<cfscript>
	request.zsession.siteSchemaDeepCopyMessage=arguments.message;
	application.zcore.session.put(request.zsession);
	</cfscript>
</cffunction>

<cffunction name="createVersion" localmode="modern" access="remote" roles="member">
	<cfscript>
	form.createVersion=1;
	copySchema();
	</cfscript>
</cffunction>


<cffunction name="copySchema" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	qSet=getSet();
	setting requesttimeout="10000";
	form.newSiteId=request.zos.globals.id;
	form.createVersion=application.zcore.functions.zso(form, 'createVersion', true, 0);
	logCopyMessage('Copy Initializing.');
	groupStruct=getSchemas();
	typeStruct=getFields();

	try{
		for(row in qSet){
			tempSchema=groupStruct[row.feature_schema_id];
			if(tempSchema.data.feature_schema_enable_sorting EQ 1){
				db.sql="select max(feature_data_sort) maxSort from #db.table("feature_data", request.zos.zcoreDatasource)# 
				WHERE feature_data_parent_id = #db.param(row.feature_data_parent_id)# and 
				site_id = #db.param(row.site_id)# and 
				feature_data_deleted=#db.param(0)# and 
				feature_data_master_set_id = #db.param(0)#";
				qSort=db.execute("qSort");
				for(row2 in qSort){
					row.feature_data_sort=qSort.maxSort+1;
				}
			}
			row.feature_data_copy_id=form.feature_data_id;
			if(form.createVersion EQ 1){
				if(tempSchema.data.feature_schema_enable_versioning EQ 0){
					application.zcore.status.setStatus(request.zsid, "Versioning is not allowed.", form, true);
					application.zcore.functions.zRedirect("/z/feature/admin/features/index?feature_id=#form.feature_id#&zsid=#request.zsid#");
				}
				if(tempSchema.data.feature_schema_version_limit NEQ 0){
					db.sql="select count(feature_data_id) count from #db.table("feature_data", request.zos.zcoreDatasource)# 
					WHERE feature_data_master_set_id = #db.param(row.feature_data_id)# and 
					site_id = #db.param(row.site_id)# and 
					feature_data_deleted=#db.param(0)# ";
					qVersionCount=db.execute("qVersionCount");
					if(qVersionCount.recordcount NEQ 0 and tempSchema.data.feature_schema_version_limit LTE qVersionCount.count){
						application.zcore.status.setStatus(request.zsid, "Version limit reached. You must delete a version before creating a new one.", form, true);
						application.zcore.functions.zRedirect("/z/feature/admin/feature-deep-copy/versionList?feature_id=#form.feature_id#&feature_data_id=#row.feature_data_id#&zsid=#request.zsid#");
					}
				}
				db.sql="select feature_data_id from #db.table("feature_data", request.zos.zcoreDatasource)# 
				WHERE feature_data_master_set_id = #db.param(row.feature_data_id)# and 
				site_id = #db.param(row.site_id)# and 
				feature_data_deleted=#db.param(0)# and 
				feature_data_version_status = #db.param(1)#";
				qVersionStatus=db.execute("qVersionStatus");
				if(qVersionStatus.recordcount EQ 0){
					row.feature_data_version_status=1;
				}
				row.feature_data_master_set_id=form.feature_data_id;
			}
			this.copySchemaRecursive(form.feature_data_id, form.newSiteId, row, groupStruct, typeStruct);
		}

		if(form.newSiteID NEQ request.zos.globals.id){
			featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
			featureCacheCom.rebuildFeatureStructCache(form.feature_id, application.zcore); 
		}else{
			featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
			featureCacheCom.updateSchemaCache();
		}

	}catch(Any e){
		logCopyMessage('An error occured while copying.');
		savecontent variable="out"{
			echo('<h2>An error occured while copying.</h2>');
			writedump(e);
		}
		ts={
			type:"Custom",
			errorHTML:out,
			scriptName:request.zos.originalURL,
			url:request.zos.globals.domain&request.zos.originalURL,
			exceptionMessage:'An error occured while copying.',
			// optional
			lineNumber:''
		};
		application.zcore.functions.zLogError(ts);
		rs={
			success:false,
			errorMessage:"An error occurred while copying."
		};
		application.zcore.functions.zReturnJSON(rs);
	}
	logCopyMessage('');
	rs={
		success:true
	};
	if(form.createVersion EQ 1){
		rs.redirectURL="/z/feature/admin/feature-deep-copy/versionList?feature_id=#qSet.feature_id#&feature_data_id=#qSet.feature_data_id#";
	}else{
		rs.redirectURL="/z/feature/admin/features/manageSchema?feature_data_parent_id=#qSet.feature_data_parent_id#&feature_id=#qSet.feature_id#&feature_schema_id=#qSet.feature_schema_id#&zsid=#request.zsid#";
	}
	application.zcore.functions.zReturnJSON(rs);
	</cfscript>
</cffunction>

<cffunction name="isVersionLimitReached" localmode="modern" access="public">
	<cfargument name="setId" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select feature_schema_id, count(site_id) count from #db.table("feature_data", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(arguments.site_id)# and 
	feature_data_deleted=#db.param(0)# and 
	feature_data_master_set_id=#db.param(arguments.setId)#";
	qVersion=db.execute("qVersion");
	if(qVersion.recordcount EQ 0){
		return false;
	}else{
		if(qVersion.count EQ 0){
			return false;
		}
		db.sql="select feature_schema_version_limit from 
		#db.table("feature_schema", request.zos.zcoreDatasource)# WHERE 
		feature_id=#db.param(form.feature_id)# and 
		feature_schema_deleted=#db.param(0)# and 
		feature_schema_id=#db.param(qVersion.feature_schema_id)#";
		qSchema=db.execute("qSchema");
		if(qSchema.feature_schema_version_limit EQ 0){
			return false;
		}else if(qVersion.count LT qSchema.feature_schema_version_limit){
			return false;
		}else{
			return true;
		}
	}
	</cfscript>
</cffunction>

<cffunction name="confirmVersionActive" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.z404("feature disabled");
	
	db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	</cfscript>
	<form class="zFormCheckDirty" action="/z/feature/admin/feature-deep-copy/setVersionActive" method="post">
		<input type="hidden" name="feature_id" value="#form.feature_id#">
		<input type="hidden" name="feature_data_id" value="#form.feature_data_id#" />
		<input type="hidden" name="feature_data_master_set_id" value="#form.feature_data_master_set_id#" />
		<cfscript>
	db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# 

	where 
	site_id=#db.param(request.zos.globals.id)# and 
	feature_data_id = #db.param(form.feature_data_id)# and 
	feature_data_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qVersion=db.execute("qVersion");
		form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id');
		form.feature_data_master_set_id=application.zcore.functions.zso(form, 'feature_data_master_set_id');
		form.preserveURL=application.zcore.functions.zso(form, 'preserveURL', true, 1);
		form.preserveMeta=application.zcore.functions.zso(form, 'preserveMeta', true, 1);
		</cfscript>
		<!--- TODO: consider showing new/old values to help user understand what is being asked. --->
		<h2>Are you sure you want to make this version active?</h2>
		<p>The active record will be made inactive, and this record will take its place.</p>
		<p>ID: #qVersion.feature_data_id# | Title: #qVersion.feature_data_title#</p>

		<p>URL: <cfif qVersion.feature_data_override_url EQ "">
			(Default/Automatic)
		<cfelse>
			#qVersion.feature_data_override_url#
		</cfif></p>
		<p>Meta Title: #qVersion.feature_data_metatitle#</p>
		<p>Meta Keywords: #qVersion.feature_data_metakey#</p>
		<p>Meta Description: #qVersion.feature_data_metadesc#</p>
		<h3>Keep URL the same?
		#application.zcore.functions.zInput_Boolean("preserveURL")#</h3>
		<h3>Keep Meta Tags the same?
		#application.zcore.functions.zInput_Boolean("preserveMeta")#</h3>

		<p><input type="submit" name="submit1" value="Make Primary" />
		<input type="button" name="cancel1" onclick="window.location.href='/z/feature/admin/feature-deep-copy/versionList?feature_id=#form.feature_id#&feature_data_id=#qVersion.feature_data_master_set_id#';" value="Cancel" /></p>
	</form>
</cffunction>

<cffunction name="setVersionActive" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.functions.z404("feature disabled");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	// TODO: consider more security checks here are necessary

	form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id');
	form.feature_data_master_set_id=application.zcore.functions.zso(form, 'feature_data_master_set_id');
	form.preserveURL=application.zcore.functions.zso(form, 'preserveURL', true, 1);
	form.preserveMeta=application.zcore.functions.zso(form, 'preserveMeta', true, 1);

	db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# 
	where
	site_id=#db.param(request.zos.globals.id)# and 
	feature_data_id = #db.param(form.feature_data_master_set_id)# and 
	feature_data_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qMaster=db.execute("qMaster");

	db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# 
	where 
	site_id=#db.param(request.zos.globals.id)# and 
	feature_data_id = #db.param(form.feature_data_id)# and 
	feature_data_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qVersion=db.execute("qVersion");

	tempVersion={};
	tempMaster={};
	for(row in qVersion){
		tempVersion=row;
	}
	for(row in qMaster){
		tempMaster=row;
	}
	if(structcount(tempVersion) EQ 0 or structcount(tempMaster) EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid request", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/features/index?feature_id=#form.feature_id#&zsid=#request.zsid#");
	}


	backupMasterSetId=tempMaster.feature_data_id;
	backupVersionSetId=tempVersion.feature_data_id;


	structdelete(tempMaster, 'feature_data_id');
	tempMaster.feature_data_master_set_id=backupMasterSetId;
	tempMaster.feature_data_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');

	if(form.preserveURL EQ 1 and tempMaster.feature_data_override_url NEQ ""){
		tempVersion.feature_data_override_url=tempMaster.feature_data_override_url;
		tempMaster.feature_data_override_url="";
	}
	ts={
		table:"feature_data",
		datasource:request.zos.zcoreDatasource,
		struct:tempMaster
	};
	tempVersion.feature_data_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');
	if(form.preserveMeta EQ 1){
		tempVersion.feature_data_metatitle=tempMaster.feature_data_metatitle;
		tempVersion.feature_data_metakey=tempMaster.feature_data_metakey;
		tempVersion.feature_data_metadesc=tempMaster.feature_data_metadesc;
	}

	newMasterId=application.zcore.functions.zInsert(ts);
	transaction action="begin"{
		try{
			db.sql="delete from #db.table("feature_data", request.zos.zcoreDatasource)# where 
			site_id = #db.param(tempMaster.site_id)# and 
			feature_data_id = #db.param(backupMasterSetId)# and 
			feature_data_deleted=#db.param(0)#";
			db.execute("qDelete");
			db.sql="update #db.table("feature_data", request.zos.zcoreDatasource)# SET 
			feature_data_parent_id = #db.param(newMasterId)#, 
			feature_data_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))#
			where feature_data_parent_id = #db.param(backupMasterSetId)# and 
			site_id = #db.param(tempMaster.site_id)# and 
			feature_data_deleted=#db.param(0)# ";
			db.execute("qUpdate");

			db.sql="update #db.table("feature_data", request.zos.zcoreDatasource)# SET 
			feature_data_id = #db.param(backupMasterSetId)#, 
			feature_data_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))#
			where feature_data_id = #db.param(backupVersionSetId)# and 
			site_id = #db.param(tempVersion.site_id)# and 
			feature_data_deleted=#db.param(0)# ";
			db.execute("qUpdate");
			db.sql="update #db.table("feature_data", request.zos.zcoreDatasource)# SET 
			feature_data_parent_id = #db.param(backupMasterSetId)#, 
			feature_data_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))#
			where feature_data_parent_id = #db.param(backupVersionSetId)# and 
			site_id = #db.param(tempVersion.site_id)# and 
			feature_data_deleted=#db.param(0)# ";
			db.execute("qUpdate");

			tempVersion.feature_data_id=backupMasterSetId;
			tempVersion.feature_data_master_set_id=0;

			ts={
				table:"feature_data",
				datasource:request.zos.zcoreDatasource,
				struct:tempVersion
			};
			application.zcore.functions.zUpdate(ts);

		}catch(Any e){
			transaction action="rollback";
			db.sql="delete from #db.table("feature_data", request.zos.zcoreDatasource)# where 
			site_id = #db.param(tempMaster.site_id)# and 
			feature_data_id = #db.param(newMasterId)# and 
			feature_data_deleted=#db.param(0)#";
			db.execute("qDelete");
			rethrow;
		}
		transaction action="commit";
	}

	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	featureCacheCom.updateSchemaCacheBySchemaId(tempMaster.feature_id, tempMaster.feature_schema_id);

	application.zcore.status.setStatus(request.zsid, "Successfully changed selected version to be the primary record.");
	application.zcore.functions.zRedirect("/z/feature/admin/feature-deep-copy/versionList?feature_id=#form.feature_id#&feature_data_id=#backupMasterSetId#");
	</cfscript>
	
</cffunction>

<cffunction name="archiveVersion" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.z404("feature disabled");
	db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	form.statusValue=application.zcore.functions.zso(form, 'statusValue', true, 0);
	form.feature_data_master_set_id=application.zcore.functions.zso(form, 'feature_data_master_set_id');
	form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id');

	// verify the set is a version
	db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# 
	WHERE 
	site_id=#db.param(request.zos.globals.id)# and 
	feature_id=#db.param(form.feature_id)# and 
	feature_data_id= #db.param(form.feature_data_id)# and 
	feature_data_master_set_id=#db.param(form.feature_data_master_set_id)# and 
	feature_data_deleted=#db.param(0)# ";
	qArchive=db.execute("qArchive");

	if(qArchive.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Version no longer exists.");
		application.zcore.functions.zRedirect("/z/feature/admin/feature-deep-copy/versionList?feature_id=#form.feature_id#&feature_data_id=#form.feature_data_master_set_id#");
	}

	transaction action="begin"{
		try{
			if(form.statusValue EQ 1){
				db.sql="update #db.table("feature_data", request.zos.zcoreDatasource)# 
				SET 
				feature_data_version_status=#db.param(0)#, 
				feature_data_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))# 
				WHERE 
				site_id=#db.param(request.zos.globals.id)# and 
				feature_id=#db.param(form.feature_id)# and 
				feature_data_master_set_id=#db.param(form.feature_data_master_set_id)# and 
				feature_data_deleted=#db.param(0)# ";
				qUpdate=db.execute("qUpdate");
			}
			db.sql="update #db.table("feature_data", request.zos.zcoreDatasource)# 
			SET 
			feature_data_version_status=#db.param(form.statusValue)#, 
			feature_data_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))# 
			WHERE 
			site_id=#db.param(request.zos.globals.id)# and 
			feature_id=#db.param(form.feature_id)# and 
			feature_data_id=#db.param(form.feature_data_id)# and 
			feature_data_master_set_id=#db.param(form.feature_data_master_set_id)# and 
			feature_data_deleted=#db.param(0)# ";
			qUpdate=db.execute("qUpdate");  
		}catch(Any e){
			transaction action="rollback"; 
			rethrow;
		}
		transaction action="commit";
	}


	// TODO: consider removing the version data from memory using structdelete instead of full rebuild:
	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	featureCacheCom.updateSchemaCacheBySchemaId(qArchive.feature_id, qArchive.feature_schema_id);
	if(form.statusValue EQ 1){
		application.zcore.status.setStatus(request.zsid, "Version preview enabled.");
	}else{
		application.zcore.status.setStatus(request.zsid, "Version archived.");
	}
	application.zcore.functions.zRedirect("/z/feature/admin/feature-deep-copy/versionList?feature_id=#form.feature_id#&feature_data_id=#form.feature_data_master_set_id#");
	</cfscript>
</cffunction>

<cffunction name="versionList" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	application.zcore.functions.z404("feature disabled");
	application.zcore.functions.zStatusHandler(request.zsid);
	siteFieldCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.features");
	defaultStruct=siteFieldCom.getDefaultStruct(); 
	structappend(arguments.struct, defaultStruct, false);
	qSet=getSet(); 
	db=request.zos.queryObject;
	db.sql="select * from (#db.table("feature_data", request.zos.zcoreDatasource)#,
	#db.table("feature_schema", request.zos.zcoreDatasource)#) WHERE 
	feature_data.site_id=#db.param(request.zos.globals.id)# and 
	feature_schema.feature_schema_id = feature_data.feature_schema_id and 
	feature_schema_deleted=#db.param(0)# and 
	feature_data.feature_id=#db.param(form.feature_id)# and 
	feature_data_deleted=#db.param(0)# and 
	feature_data_id=#db.param(form.feature_data_id)#";
	qMaster=db.execute("qMaster");
	if(qMaster.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid request", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/features/index?feature_id=#form.feature_id#&zsid=#request.zsid#");
	}
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# WHERE 
	feature_id=#db.param(form.feature_id)# and 
	feature_schema_deleted=#db.param(0)# and 
	feature_schema_id=#db.param(qMaster.feature_schema_id)# ";
	qSchema=db.execute("qSchema");

	form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id');
	echo('<p><a href="/z/feature/admin/features/manageSchema?feature_schema_id=#qMaster.feature_schema_id#">Manage #qSchema.feature_schema_display_name#</a> /</p>');
	echo('<h2>Showing versions for "'&qSet.feature_data_title&'"</h2>');
	db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# WHERE 
	site_id=#db.param(request.zos.globals.id)# and 
	feature_id=#db.param(form.feature_id)# and 
	feature_data_deleted=#db.param(0)# and 
	feature_data_master_set_id=#db.param(form.feature_data_id)#";
	qVersion=db.execute("qVersion");


	limitReached=isVersionLimitReached(form.feature_data_id, request.zos.globals.id);
	if(not limitReached){
		echo('<p><a href="/z/feature/admin/feature-deep-copy/index?createVersion=1&amp;feature_id=#form.feature_id#&amp;feature_data_id=#form.feature_data_id#">Create new version</a></p>');
	}else{
		echo('<p>Version limit reached. To create a new version, please delete one of the previous versions.</p>');
	}
	echo('<p>Only 1 version can be set active at a time. When in preview mode, active versions will be displayed on the public web site instead of the original records.</p>');
	echo('<table class="table-list">
		<tr>
		<th>ID</th>
		<th>Title</th>');
	// loop columns
		echo('<th>Status</th>
			<th>Last Updated</th>
		<th>Admin</th>
		</tr>');
	for(row in qVersion){
		echo('<tr>
			<td>'&row.feature_data_id&'</td>
			<td>'&row.feature_data_title&'</td>');

		echo('
			<td>');
		if(row.feature_data_version_status EQ 0){
			echo('Archived');
		}else{
			echo('Preview Enabled');
		}
		echo('</td>
		<td>'&application.zcore.functions.zGetLastUpdatedDescription(row.feature_data_updated_datetime)&'</td>
			<td>');
		if(row.feature_data_version_status EQ 0){
			// 0 is archived | 1 is primary
			// echo('<a href="/z/feature/admin/feature-deep-copy/archiveVersion?feature_id=#row.feature_id#&feature_data_id=#row.feature_data_id#&feature_data_master_set_id=#row.feature_data_master_set_id#&amp;statusValue=1">Enable Preview</a> | ');
		}else{
			if(qMaster.feature_schema_enable_unique_url EQ 1){
				if(row.feature_data_override_url NEQ ""){
					link=row.feature_data_override_url;
				}else{
					link="/#application.zcore.functions.zURLEncode(row.feature_data_title, '-')#-50-#row.feature_data_id#.html";
				}
				echo('<a href="#link#" target="_blank">View</a> | ');
			}
			// echo('<a href="/z/feature/admin/feature-deep-copy/archiveVersion?feature_id=#form.feature_id#&feature_data_id=#row.feature_data_id#&feature_data_master_set_id=#row.feature_data_master_set_id#&amp;statusValue=0">Disable Preview</a> | ');
		}
		echo(' <a href="/z/feature/admin/feature-deep-copy/confirmVersionActive?feature_id=#form.feature_id#&feature_data_id=#row.feature_data_id#&feature_data_master_set_id=#row.feature_data_master_set_id#">Make Primary</a>');

		editLink=application.zcore.functions.zURLAppend(arguments.struct.editURL, "feature_id=#row.feature_id#&amp;feature_schema_id=#row.feature_schema_id#&amp;feature_data_id=#row.feature_data_id#&amp;feature_data_parent_id=#row.feature_data_parent_id#"); // &amp;modalpopforced=1&amp;disableSorting=1
		deleteLink=application.zcore.functions.zURLAppend(arguments.struct.deleteURL, "feature_id=#row.feature_id#&amp;feature_schema_id=#row.feature_schema_id#&amp;feature_data_id=#row.feature_data_id#&amp;feature_data_parent_id=#row.feature_data_parent_id#");

		echo(' | <a href="#editLink#">Edit</a>');
		//echo(' | <a href="##" onclick="zDeleteTableRecordRow(this, ''#deleteLink#'');  return false;">Delete</a>');
		echo(' | <a href="#deleteLink#">Delete</a>');
		echo('</td>
			</tr>');
	}
	echo('</table>');
	</cfscript>
</cffunction>
	
<cffunction name="getSet" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.functions.zSetPageHelpId("2.11.1.2");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id');
	db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# 
	where feature_data_id = #db.param(form.feature_data_id)# and 
	feature_data_deleted = #db.param(0)# and
	site_id=#db.param(request.zos.globals.id)# and 
	feature_id=#db.param(form.feature_id)# ";
	qSet=db.execute("qSet", "", 10000, "query", false);
	if(qSet.recordcount EQ 0){
		if(structkeyexists(form, 'x_ajax_id')){
			rs={
				success:false,
				errorMessage:"Invalid request."
			};
			application.zcore.functions.zReturnJSON(rs);
		}
		application.zcore.status.setStatus(request.zsid, "Invalid request.", form, true);
		application.zcore.functions.zRedirect('/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&zsid=#request.zsid#');	
	}
	return qSet;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	qSet=getSet();
	</cfscript>

	<h2>Select Copy Method</h2>
	<p>Note: Creating a deep copy <cfif request.zos.istestserver and false>or a new version</cfif> can take several seconds. Please be patient.</p>
	<p>Selected Record ID###form.feature_data_id# | Title: #qSet.feature_data_title#</p>
	<hr />
	<div id="copyMessageDiv">
		<h3><a href="##" onclick="doDeepCopy('/z/feature/admin/feature-deep-copy/copySchema?feature_id=#form.feature_id#&feature_data_id=#form.feature_data_id#'); return false;">Deep Copy</a></h3>
		<p>A deep copy will force the URL to be unique, but all other data including text, files And sub-records will be fully cloned.</p>
		<h3><a href="/z/feature/admin/features/addSchema?feature_id=#qSet.feature_id#&amp;feature_schema_id=#qSet.feature_schema_id#&amp;feature_data_id=#form.feature_data_id#&amp;feature_data_parent_id=#qSet.feature_data_parent_id#">Shallow Copy</a></h3>
		<p>Shallow copy prefills the form for creating a new record with only this record's text.  All files and sub-records will be left blank on the new record.</p>
		<!--- <cfif request.zos.istestserver>
			<cfif isVersionLimitReached(form.feature_data_id, qSet.site_id)>
				<h3>Version limit reached.  You must delete a previous version before creating a new one.</h3>
				<p><a href="/z/feature/admin/feature-deep-copy/versionList?feature_id=#form.feature_id#&feature_data_id=#form.feature_data_id#">List versions</a></p>
			<cfelse>
				<h3><a href="##" onclick="doDeepCopy('/z/feature/admin/feature-deep-copy/createVersion?feature_id=#form.feature_id#&feature_data_id=#form.feature_data_id#'); return false;">Create new version</a></h3>
				<p>A version is a deep copy that is linked with the original record.  The new record will be invisible to the public until finalized.  You will be able to preserve the URL and existing relationships that the original record had when you set the version to be the primary record.</p>
			</cfif>
		</cfif> --->
		<h3><a href="/z/feature/admin/features/manageSchema?feature_id=#qSet.feature_id#&amp;feature_schema_id=#qSet.feature_schema_id#">Cancel</a></h3>
	</div>
	 <!--- ajax for /z/feature/admin/feature-deep-copy/getCopyMessage until it returns "", then refresh page... --->

	<cfif structkeyexists(form, 'createVersion')>
		
		<script type="text/javascript">
		zArrDeferredFunctions.push(function(){
			doDeepCopy('/z/feature/admin/feature-deep-copy/createVersion?feature_id=#form.feature_id#&feature_data_id=#form.feature_data_id#');
		});
		</script>
	</cfif>
	 <script>
	 function ajaxMessageCallback(r){
	 	var r=eval('('+r+')');
	 	if(r.success){
	 		setMessage(r.message);
	 	}
	 }
	 function setMessage(m){
		var end = new Date().getTime();
		var time = end - start;
		$("##copyMessageDiv").html('<h2>Copying Status:</h2><p>'+m+'</p><p>Time elapsed: '+time+'</p>');
	 }
	 function ajaxCopyCallback(r){
	 	var r=eval('('+r+')');
	 	clearInterval(messageIntervalId);
	 	if(r.success){
	 		setMessage("Copy complete.");
	 		window.location.href=r.redirectURL;
	 	}else{
	 		setMessage(r.errorMessage);
	 	}
	 }
	 function checkMessage(){
		var obj={
			id:"ajaxGetMessage",
			method:"get",
			ignoreOldRequests:false,
			callback:ajaxMessageCallback,
			errorCallback:function(){
			 	clearInterval(messageIntervalId);
			 },
			url:"/z/feature/admin/feature-deep-copy/getCopyMessage"
		}; 
		zAjax(obj);
	 }
	 var messageIntervalId=false;
	 var start = new Date().getTime();

	 function doDeepCopy(link){
	 	start = new Date().getTime();
	 	setMessage("Starting deep copy");
		var obj={
			id:"ajaxDoCopy",
			method:"get",
			ignoreOldRequests:false,
			callback:ajaxCopyCallback,
			errorCallback:function(){
	 			clearInterval(messageIntervalId);
				alert("There was an error while copying.");
			},
			url:link
		}; 
		zAjax(obj);
		messageIntervalId=setInterval(checkMessage, 1000);
	 }
	 </script>
</cffunction>
 
</cfoutput>
</cfcomponent>
