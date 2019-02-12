<cfcomponent>
<cfoutput>
<!--- 
deep copy for Feature Schemas
	two ways to handle this.
		create a "linked record" that will replace the original and maintain the same URL and original parent record ID, but all site_x_option_group_id ids will change, and the 
			complications?
				I should show modal window while version is being created, with loading animation, and maybe status feedback.   It might take a minute to copy some kinds of records.  Prevent double click.
			
				with versions, you could have multiple drafts, and one primary record that is "live".   
				administrator needs to be able to preview a record temporarily for their session -  the retrieval of data across entire system would have to be able to swap in these temporary records without changing the site code.
					non-primary records with "preview" session flag set must always be in memory, even if memory is disabled so it avoids extra queries to retrieve them.


When making a version the primary record, it will have option to preserve the original URL, meta tags.   Also, an option to delete the original afterwards, so that old versions don't clutter or confuse you later.
					
				because versions are stored in memory, we must limit the number of active versions.  archived versions are not stored in memory, and can't be previewed.  Users must "archive" 1 or more versions, to bring an archived one back to active or draft state.
					
				they can only work on the groups with parent_id = 0 because relationships with other records would break if we didn't restrict this.
				
				a "Version" is an inactive copy of the data. 
				site_x_option_group_set_version
					all the same fields as site_x_option_group_set with site_x_option_group_set_version prefix
					plus:
					site_x_option_group_set_version_status char(1) default 0 | 0 is archived | 1 is primary | 2 is primary preview  - there can only be 1 record at a time that is value 1, and 1 that is value 2.   preview records are only visible for logged in user with manager privileges.
					site_x_option_group_set_id
				site_x_option_group_set
					site_x_option_group_set_master_set_id (refers to the main site_x_option_group_set_id record)  
						if this is 0, then it is the master, else it is a version, and should not be included in the main arrays and query results that are used for site output.   
						when non-zero, the full tree of data for this record and its child records should ALWAYS be cached in memory if the version record for this id is not archived.
				site_x_option_group
					no changes.
				
			versions can only be viewed/edited/deleted on the version page.   The version page could be made into a modal window instead of a separate page.  This makes it easier to stay where you where, similar to edit.
			
			new fields:
				feature_schema_enable_versioning
				feature_schema_enable_version_limit int(11) default 0,  0 is unlimited, default this to 10 to reduce wasted space usage.
			
			"Make Primary" link, opens modal window, that has options for preserving specific data.
				i.e. Meta Tags, URL, more later.
					
					
		OR I can create a full copy, but force the unique url field blank so it doesn't conflict.
			simpler, but leads to SEO mistakes, and complications with losing relationships to other records.
			
		
 ---> 

<cffunction name="copySchemaRecursive" localmode="modern" access="public" roles="member">
	<cfargument name="option_group_set_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="rowStruct" type="struct" required="yes">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=arguments.rowStruct;
	row.site_x_option_group_set_override_url="";
	row.site_x_option_group_set_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');
	row.site_id = arguments.site_id;

	if(row.site_x_option_group_set_image_library_id NEQ 0){

		logCopyMessage('Copying image library for set ###arguments.option_group_set_id#');
		row.site_x_option_group_set_image_library_id=application.zcore.imageLibraryCom.copyImageLibrary(row.site_x_option_group_set_image_library_id, row.site_id);
	}
	ts=structnew();
	ts.struct=row;
	ts.datasource="jetendofeature";
	ts.table="site_x_option_group_set";
	newSetId=application.zcore.functions.zInsert(ts);

	logCopyMessage('Copying set ###arguments.option_group_set_id#');
	db.sql="select * from 
	#db.table("site_x_option_group", "jetendofeature")# WHERE 
	site_x_option_group_set_id = #db.param(arguments.option_group_set_id)# and 
	site_x_option_group_deleted=#db.param(0)# and 
	site_id = #db.param(arguments.site_id)# ";
	qValue=db.execute("qValue");
	typeCache={};
	tempPath=application.zcore.functions.zvar('privatehomedir', arguments.site_id);
	for(row2 in qValue){

		structdelete(row2, 'site_x_option_group_id');  
		row2.site_x_option_group_set_id=newSetId;
		row2.site_id=arguments.site_id;
		row2.site_x_option_group_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');

		if(row2.site_x_option_group_value NEQ ""){
			if(structkeyexists(arguments.optionStruct, row2.feature_field_id)){
				typeId=arguments.optionStruct[row2.feature_field_id].data.feature_field_type_id;
				if(typeId EQ 9){
					tempFieldStruct=arguments.optionStruct[row2.feature_field_id].type;
					path=tempPath;
					if(application.zcore.functions.zso(tempFieldStruct, 'file_securepath') EQ 'Yes'){
						path&='zuploadsecure/site-options/';
					}else{
						path&='zupload/site-options/';
					}
				}else if(typeId EQ 3){
					path=tempPath&'zupload/site-options/';
				}else if(typeId EQ 23){ 
					row2.site_x_option_group_value=application.zcore.imageLibraryCom.copyImageLibrary(row2.site_x_option_group_value, row2.site_id);
				}else if(typeId EQ 21){
					db.sql="select * from #db.table("mls_saved_search", "jetendofeature")# WHERE 
					site_id = #db.param(row2.site_id)# and 
					mls_saved_search_id=#db.param(row2.site_x_option_group_value)# and 
					mls_saved_search_deleted=#db.param(0)# ";
					qV=db.execute("qV");
					for(r2 in qV){
						structdelete(r2, 'mls_saved_search_id');
						r2.mls_saved_search_updated_datetime=request.zos.mysqlnow;
						ts=structnew();
						ts.struct=r2;
						ts.datasource="jetendofeature";
						ts.table="mls_saved_search";
						row2.site_x_option_group_value=application.zcore.functions.zInsert(ts);
					}
				}
				if(typeId EQ 9 or typeId EQ 3){
					newPath=application.zcore.functions.zcopyfile(path&row2.site_x_option_group_value);
					row2.site_x_option_group_value=getfilefrompath(newPath); 
					if(row2.site_x_option_group_original NEQ ""){
						newPath=application.zcore.functions.zcopyfile(path&row2.site_x_option_group_original);
						row2.site_x_option_group_original=getfilefrompath(newPath);
					}
				}
			}
		}
		ts=structnew();
		ts.struct=row2;
		ts.datasource="jetendofeature";
		ts.table="site_x_option_group";
		newValueId=application.zcore.functions.zInsert(ts);

	}


	db.sql="select * from 
	#db.table("site_x_option_group_set", "jetendofeature")# WHERE 
	site_x_option_group_set_parent_id = #db.param(arguments.option_group_set_id)# and 
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	site_x_option_group_set_deleted=#db.param(0)#  and 
	site_id = #db.param(arguments.site_id)# ";
	typeCache={};
	qChild=db.execute("qChild");
	for(row3 in qChild){
		row3.site_x_option_group_set_parent_id=newSetId;
		this.copySchemaRecursive(row3.site_x_option_group_set_id, arguments.site_id, row3, arguments.groupStruct, arguments.optionStruct);
	}
	</cfscript>
</cffunction>

<cffunction name="getSchemas" localmode="modern" access="public" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	groupStruct={};
	db.sql="select * from #db.table("feature_schema", "jetendofeature")# WHERE 
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
	optionStruct={};
	db.sql="select * from #db.table("feature_field", "jetendofeature")# WHERE 
	feature_id=#db.param(form.feature_id)# and 
	feature_field_deleted=#db.param(0)# and 
	feature_schema_id <> #db.param(0)#";
	qField=db.execute("qField");
	for(row in qField){
		optionStruct[row.feature_field_id]={
			data: row,
			type: deserializeJson(row.feature_field_type_json)
		}
	}
	return optionStruct;
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
	optionStruct=getFields();

	try{
		for(row in qSet){
			tempSchema=groupStruct[row.feature_schema_id];
			if(tempSchema.data.feature_schema_enable_sorting EQ 1){
				db.sql="select max(site_x_option_group_set_sort) maxSort from #db.table("site_x_option_group_set", "jetendofeature")# 
				WHERE site_x_option_group_set_parent_id = #db.param(row.site_x_option_group_set_parent_id)# and 
				site_id = #db.param(row.site_id)# and 
				site_x_option_group_set_deleted=#db.param(0)# and 
				site_x_option_group_set_master_set_id = #db.param(0)#";
				qSort=db.execute("qSort");
				for(row2 in qSort){
					row.site_x_option_group_set_sort=qSort.maxSort+1;
				}
			}
			row.site_x_option_group_set_copy_id=form.site_x_option_group_set_id;
			if(form.createVersion EQ 1){
				if(tempSchema.data.feature_schema_enable_versioning EQ 0){
					application.zcore.status.setStatus(request.zsid, "Versioning is not allowed.", form, true);
					application.zcore.functions.zRedirect("/z/feature/admin/features/index?zsid=#request.zsid#");
				}
				if(tempSchema.data.feature_schema_version_limit NEQ 0){
					db.sql="select count(site_x_option_group_set_id) count from #db.table("site_x_option_group_set", "jetendofeature")# 
					WHERE site_x_option_group_set_master_set_id = #db.param(row.site_x_option_group_set_id)# and 
					site_id = #db.param(row.site_id)# and 
					site_x_option_group_set_deleted=#db.param(0)# ";
					qVersionCount=db.execute("qVersionCount");
					if(qVersionCount.recordcount NEQ 0 and tempSchema.data.feature_schema_version_limit LTE qVersionCount.count){
						application.zcore.status.setStatus(request.zsid, "Version limit reached. You must delete a version before creating a new one.", form, true);
						application.zcore.functions.zRedirect("/z/feature/admin/feature-deep-copy/versionList?site_x_option_group_set_id=#row.site_x_option_group_set_id#&zsid=#request.zsid#");
					}
				}
				db.sql="select site_x_option_group_set_id from #db.table("site_x_option_group_set", "jetendofeature")# 
				WHERE site_x_option_group_set_master_set_id = #db.param(row.site_x_option_group_set_id)# and 
				site_id = #db.param(row.site_id)# and 
				site_x_option_group_set_deleted=#db.param(0)# and 
				site_x_option_group_set_version_status = #db.param(1)#";
				qVersionStatus=db.execute("qVersionStatus");
				if(qVersionStatus.recordcount EQ 0){
					row.site_x_option_group_set_version_status=1;
				}
				row.site_x_option_group_set_master_set_id=form.site_x_option_group_set_id;
			}
			this.copySchemaRecursive(form.site_x_option_group_set_id, form.newSiteId, row, groupStruct, optionStruct);
		}

		if(form.newSiteID NEQ request.zos.globals.id){
			application.zcore.functions.zOS_cacheSiteAndUserSchemas(form.newSiteId);
		}else{
			siteStruct=application.zcore.functions.zGetSiteGlobals(form.newSiteId);
			application.zcore.siteFieldCom.updateSchemaCache(siteStruct);
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
		rs.redirectURL="/z/feature/admin/feature-deep-copy/versionList?site_x_option_group_set_id=#qSet.site_x_option_group_set_id#";
	}else{
		rs.redirectURL="/z/feature/admin/features/manageSchema?site_x_option_group_set_parent_id=#qSet.site_x_option_group_set_parent_id#&feature_id=#qSet.feature_id#&feature_schema_id=#qSet.feature_schema_id#&zsid=#request.zsid#";
	}
	application.zcore.functions.zReturnJSON(rs);
	</cfscript>
</cffunction>

<cffunction name="isVersionLimitReached" localmode="modern" access="public">
	<cfargument name="setId" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select feature_schema_id, count(site_id) count from #db.table("site_x_option_group_set", "jetendofeature")# WHERE 
	site_id = #db.param(arguments.site_id)# and 
	site_x_option_group_set_deleted=#db.param(0)# and 
	site_x_option_group_set_master_set_id=#db.param(arguments.setId)#";
	qVersion=db.execute("qVersion");
	if(qVersion.recordcount EQ 0){
		return false;
	}else{
		if(qVersion.count EQ 0){
			return false;
		}
		db.sql="select feature_schema_version_limit from #db.table("feature_schema", "jetendofeature")# WHERE 
		site_id = #db.param(arguments.site_id)# and 
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
	
	db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	</cfscript>
	<form class="zFormCheckDirty" action="/z/feature/admin/feature-deep-copy/setVersionActive" method="post">
		<input type="hidden" name="site_x_option_group_set_id" value="#form.site_x_option_group_set_id#" />
		<input type="hidden" name="site_x_option_group_set_master_set_id" value="#form.site_x_option_group_set_master_set_id#" />
		<cfscript>
	db.sql="select * from #db.table("site_x_option_group_set", "jetendofeature")# 
	where site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qVersion=db.execute("qVersion");
		form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
		form.site_x_option_group_set_master_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_master_set_id');
		form.preserveURL=application.zcore.functions.zso(form, 'preserveURL', true, 1);
		form.preserveMeta=application.zcore.functions.zso(form, 'preserveMeta', true, 1);
		</cfscript>
		<!--- TODO: consider showing new/old values to help user understand what is being asked. --->
		<h2>Are you sure you want to make this version active?</h2>
		<p>The active record will be made inactive, and this record will take its place.</p>
		<p>ID: #qVersion.site_x_option_group_set_id# | Title: #qVersion.site_x_option_group_set_title#</p>

		<p>URL: <cfif qVersion.site_x_option_group_set_override_url EQ "">
			(Default/Automatic)
		<cfelse>
			#qVersion.site_x_option_group_set_override_url#
		</cfif></p>
		<p>Meta Title: #qVersion.site_x_option_group_set_metatitle#</p>
		<p>Meta Keywords: #qVersion.site_x_option_group_set_metakey#</p>
		<p>Meta Description: #qVersion.site_x_option_group_set_metadesc#</p>
		<h3>Keep URL the same?
		#application.zcore.functions.zInput_Boolean("preserveURL")#</h3>
		<h3>Keep Meta Tags the same?
		#application.zcore.functions.zInput_Boolean("preserveMeta")#</h3>

		<p><input type="submit" name="submit1" value="Make Primary" />
		<input type="button" name="cancel1" onclick="window.location.href='/z/feature/admin/feature-deep-copy/versionList?site_x_option_group_set_id=#qVersion.site_x_option_group_set_master_set_id#';" value="Cancel" /></p>
	</form>
</cffunction>

<cffunction name="setVersionActive" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	// TODO: consider more security checks here are necessary

	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	form.site_x_option_group_set_master_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_master_set_id');
	form.preserveURL=application.zcore.functions.zso(form, 'preserveURL', true, 1);
	form.preserveMeta=application.zcore.functions.zso(form, 'preserveMeta', true, 1);

	db.sql="select * from #db.table("site_x_option_group_set", "jetendofeature")# 
	where site_x_option_group_set_id = #db.param(form.site_x_option_group_set_master_set_id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qMaster=db.execute("qMaster");

	db.sql="select * from #db.table("site_x_option_group_set", "jetendofeature")# 
	where site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and
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
		application.zcore.functions.zRedirect("/z/feature/admin/features/index?zsid=#request.zsid#");
	}


	backupMasterSetId=tempMaster.site_x_option_group_set_id;
	backupVersionSetId=tempVersion.site_x_option_group_set_id;


	structdelete(tempMaster, 'site_x_option_group_set_id');
	tempMaster.site_x_option_group_set_master_set_id=backupMasterSetId;
	tempMaster.site_x_option_group_set_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');

	if(form.preserveURL EQ 1 and tempMaster.site_x_option_group_set_override_url NEQ ""){
		tempVersion.site_x_option_group_set_override_url=tempMaster.site_x_option_group_set_override_url;
		tempMaster.site_x_option_group_set_override_url="";
	}
	ts={
		table:"site_x_option_group_set",
		datasource:"jetendofeature",
		struct:tempMaster
	};
	tempVersion.site_x_option_group_set_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss');
	if(form.preserveMeta EQ 1){
		tempVersion.site_x_option_group_set_metatitle=tempMaster.site_x_option_group_set_metatitle;
		tempVersion.site_x_option_group_set_metakey=tempMaster.site_x_option_group_set_metakey;
		tempVersion.site_x_option_group_set_metadesc=tempMaster.site_x_option_group_set_metadesc;
	}

	writedump(ts);
	writedump(tempVersion);
	abort;

	newMasterId=application.zcore.functions.zInsert(ts);
	transaction action="begin"{
		try{
			db.sql="delete from #db.table("site_x_option_group_set", "jetendofeature")# where 
			site_id = #db.param(tempMaster.site_id)# and 
			site_x_option_group_set_id = #db.param(backupMasterSetId)# and 
			site_x_option_group_set_deleted=#db.param(0)#";
			db.execute("qDelete");
			db.sql="update site_x_option_group set 
			site_x_option_group_set_id = #db.param(newMasterId)#, 
			site_x_option_group_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))#
			where site_x_option_group_set_id = #db.param(backupMasterSetId)# and 
			site_id = #db.param(tempMaster.site_id)# and 
			site_x_option_group_deleted=#db.param(0)# ";
			db.execute("qUpdate");
			db.sql="update site_x_option_group_set set 
			site_x_option_group_set_parent_id = #db.param(newMasterId)#, 
			site_x_option_group_set_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))#
			where site_x_option_group_set_parent_id = #db.param(backupMasterSetId)# and 
			site_id = #db.param(tempMaster.site_id)# and 
			site_x_option_group_deleted=#db.param(0)# ";
			db.execute("qUpdate");

			db.sql="update site_x_option_group_set set 
			site_x_option_group_set_id = #db.param(backupMasterSetId)#, 
			site_x_option_group_set_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))#
			where site_x_option_group_set_id = #db.param(backupVersionSetId)# and 
			site_id = #db.param(tempVersion.site_id)# and 
			site_x_option_group_deleted=#db.param(0)# ";
			db.execute("qUpdate");
			db.sql="update site_x_option_group set 
			site_x_option_group_set_id = #db.param(backupMasterSetId)#, 
			site_x_option_group_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))#
			where site_x_option_group_set_id = #db.param(backupVersionSetId)# and 
			site_id = #db.param(tempVersion.site_id)# and 
			site_x_option_group_deleted=#db.param(0)# ";
			db.execute("qUpdate");
			db.sql="update site_x_option_group_set set 
			site_x_option_group_set_parent_id = #db.param(backupMasterSetId)#, 
			site_x_option_group_set_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))#
			where site_x_option_group_set_parent_id = #db.param(backupVersionSetId)# and 
			site_id = #db.param(tempVersion.site_id)# and 
			site_x_option_group_deleted=#db.param(0)# ";
			db.execute("qUpdate");

			tempVersion.site_x_option_group_set_id=backupMasterSetId;
			tempVersion.site_x_option_group_set_master_set_id=0;

			ts={
				table:"site_x_option_group_set",
				datasource:"jetendofeature",
				struct:tempVersion
			};
			application.zcore.functions.zUpdate(ts);

		}catch(Any e){
			transaction action="rollback";
			db.sql="delete from #db.table("site_x_option_group_set", "jetendofeature")# where 
			site_id = #db.param(tempMaster.site_id)# and 
			site_x_option_group_set_id = #db.param(newMasterId)# and 
			site_x_option_group_set_deleted=#db.param(0)#";
			db.execute("qDelete");
			rethrow;
		}
		transaction action="commit";
	}

	application.zcore.siteFieldCom.updateSchemaCacheBySchemaId(qMaster.feature_schema_id);
	//application.zcore.functions.zOS_cacheSiteAndUserSchemas(request.zos.globals.id);

	application.zcore.status.setStatus(request.zsid, "Successfully changed selected version to be the primary record.");
	application.zcore.functions.zRedirect("/z/feature/admin/feature-deep-copy/versionList?site_x_option_group_set_id=#backupMasterSetId#");
	</cfscript>
	
</cffunction>

<cffunction name="archiveVersion" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
	form.statusValue=application.zcore.functions.zso(form, 'statusValue', true, 0);
	form.site_x_option_group_set_master_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_master_set_id');
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');

	// verify the set is a version
	db.sql="select * from #db.table("site_x_option_group_set", "jetendofeature")# 
	WHERE feature_id=#db.param(form.feature_id)# and 
	site_x_option_group_set_id= #db.param(form.site_x_option_group_set_id)# and 
	site_x_option_group_set_master_set_id=#db.param(form.site_x_option_group_set_master_set_id)# and 
	site_x_option_group_set_deleted=#db.param(0)# ";
	qArchive=db.execute("qArchive");

	if(qArchive.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Version no longer exists.");
		application.zcore.functions.zRedirect("/z/feature/admin/feature-deep-copy/versionList?site_x_option_group_set_id=#form.site_x_option_group_set_master_set_id#");
	}

	transaction action="begin"{
		try{
			if(form.statusValue EQ 1){
				db.sql="update #db.table("site_x_option_group_set", "jetendofeature")# 
				SET 
				site_x_option_group_set_version_status=#db.param(0)#, 
				site_x_option_group_set_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))# 
				WHERE feature_id=#db.param(form.feature_id)# and 
				site_x_option_group_set_master_set_id=#db.param(form.site_x_option_group_set_master_set_id)# and 
				site_x_option_group_set_deleted=#db.param(0)# ";
				qUpdate=db.execute("qUpdate");
			}
			db.sql="update #db.table("site_x_option_group_set", "jetendofeature")# 
			SET 
			site_x_option_group_set_version_status=#db.param(form.statusValue)#, 
			site_x_option_group_set_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), 'HH:mm:ss'))# 
			WHERE feature_id=#db.param(form.feature_id)# and 
			site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)# and 
			site_x_option_group_set_master_set_id=#db.param(form.site_x_option_group_set_master_set_id)# and 
			site_x_option_group_set_deleted=#db.param(0)# ";
			qUpdate=db.execute("qUpdate");  
		}catch(Any e){
			transaction action="rollback"; 
			rethrow;
		}
		transaction action="commit";
	}


	// TODO: consider removing the version data from memory using structdelete instead of full rebuild:
	application.zcore.siteFieldCom.updateSchemaCacheBySchemaId(qArchive.feature_schema_id);
	//application.zcore.functions.zOS_cacheSiteAndUserSchemas(request.zos.globals.id);
	if(form.statusValue EQ 1){
		application.zcore.status.setStatus(request.zsid, "Version preview enabled.");
	}else{
		application.zcore.status.setStatus(request.zsid, "Version archived.");
	}
	application.zcore.functions.zRedirect("/z/feature/admin/feature-deep-copy/versionList?site_x_option_group_set_id=#form.site_x_option_group_set_master_set_id#");
	</cfscript>
</cffunction>

<cffunction name="versionList" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	application.zcore.functions.zStatusHandler(request.zsid);
	siteFieldCom=createObject("component", "zcorerootmapping.mvc.z.feature.features");
	defaultStruct=siteFieldCom.getDefaultStruct(); 
	structappend(arguments.struct, defaultStruct, false);
	qSet=getSet(); 
	db=request.zos.queryObject;
	db.sql="select * from #db.table("site_x_option_group_set", "jetendofeature")#,
	#db.table("feature_schema", "jetendofeature")# WHERE 
	feature_schema.feature_schema_id = site_x_option_group_set.feature_schema_id and 
	feature_schema_deleted=#db.param(0)# and 
	feature_schema.site_id = site_x_option_group_set.site_id and 
	site_x_option_group_set.feature_id=#db.param(form.feature_id)# and 
	site_x_option_group_set_deleted=#db.param(0)# and 
	site_x_option_group_set_id=#db.param(form.site_x_option_group_set_id)#";
	qMaster=db.execute("qMaster");
	if(qMaster.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid request", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/features/index?zsid=#request.zsid#");
	}
	db.sql="select * from #db.table("feature_schema", "jetendofeature")# WHERE 
	feature_id=#db.param(form.feature_id)# and 
	feature_schema_deleted=#db.param(0)# and 
	feature_schema_id=#db.param(qMaster.feature_schema_id)# ";
	qSchema=db.execute("qSchema");

	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	echo('<p><a href="/z/feature/admin/features/manageSchema?feature_schema_id=#qMaster.feature_schema_id#">Manage #qSchema.feature_schema_display_name#</a> /</p>');
	echo('<h2>Showing versions for "'&qSet.site_x_option_group_set_title&'"</h2>');
	db.sql="select * from #db.table("site_x_option_group_set", "jetendofeature")# WHERE 
	feature_id=#db.param(form.feature_id)# and 
	site_x_option_group_set_deleted=#db.param(0)# and 
	site_x_option_group_set_master_set_id=#db.param(form.site_x_option_group_set_id)#";
	qVersion=db.execute("qVersion");


	limitReached=isVersionLimitReached(form.site_x_option_group_set_id, request.zos.globals.id);
	if(not limitReached){
		echo('<p><a href="/z/feature/admin/feature-deep-copy/index?createVersion=1&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#">Create new version</a></p>');
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
			<td>'&row.site_x_option_group_set_id&'</td>
			<td>'&row.site_x_option_group_set_title&'</td>');

		echo('
			<td>');
		if(row.site_x_option_group_set_version_status EQ 0){
			echo('Archived');
		}else{
			echo('Preview Enabled');
		}
		echo('</td>
		<td>'&application.zcore.functions.zGetLastUpdatedDescription(row.site_x_option_group_set_updated_datetime)&'</td>
			<td>');
		if(row.site_x_option_group_set_version_status EQ 0){
			// 0 is archived | 1 is primary
			echo('<a href="/z/feature/admin/feature-deep-copy/archiveVersion?site_x_option_group_set_id=#row.site_x_option_group_set_id#&site_x_option_group_set_master_set_id=#row.site_x_option_group_set_master_set_id#&amp;statusValue=1">Enable Preview</a>');
		}else{
			if(qMaster.feature_schema_enable_unique_url EQ 1){
				if(row.site_x_option_group_set_override_url NEQ ""){
					link=row.site_x_option_group_set_override_url;
				}else{
					var urlId=application.zcore.functions.zvar('optionSchemaUrlId', qMaster.site_id);
					if(urlId EQ "" or urlId EQ 0){
						throw("feature_schema_url_id is not set for site_id, #site_id#.");
					}
					link="/#application.zcore.functions.zURLEncode(row.site_x_option_group_set_title, '-')#-#urlId#-#row.site_x_option_group_set_id#.html";
				}
				echo('<a href="#link#" target="_blank">View</a> | ');
			}
			echo('<a href="/z/feature/admin/feature-deep-copy/archiveVersion?site_x_option_group_set_id=#row.site_x_option_group_set_id#&site_x_option_group_set_master_set_id=#row.site_x_option_group_set_master_set_id#&amp;statusValue=0">Disable Preview</a>');
		}
		echo(' | <a href="/z/feature/admin/feature-deep-copy/confirmVersionActive?site_x_option_group_set_id=#row.site_x_option_group_set_id#&site_x_option_group_set_master_set_id=#row.site_x_option_group_set_master_set_id#">Make Primary</a>');

		editLink=application.zcore.functions.zURLAppend(arguments.struct.editURL, "feature_id=#row.feature_id#&amp;feature_schema_id=#row.feature_schema_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#"); // &amp;modalpopforced=1&amp;disableSorting=1
		deleteLink=application.zcore.functions.zURLAppend(arguments.struct.deleteURL, "feature_id=#row.feature_id#&amp;feature_schema_id=#row.feature_schema_id#&amp;site_x_option_group_set_id=#row.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#row.site_x_option_group_set_parent_id#");

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
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	db.sql="select * from #db.table("site_x_option_group_set", "jetendofeature")# 
	where site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qSet=db.execute("qSet");
	if(qSet.recordcount EQ 0){
		if(structkeyexists(form, 'x_ajax_id')){
			rs={
				success:false,
				errorMessage:"Invalid request."
			};
			application.zcore.functions.zReturnJSON(rs);
		}
		application.zcore.status.setStatus(request.zsid, "Invalid request.", form, true);
		application.zcore.functions.zRedirect('/z/feature/admin/feature-schema/index?zsid=#request.zsid#');	
	}
	return qSet;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	qSet=getSet();
	</cfscript>

	<h2>Select Copy Method</h2>
	<p>Note: Creating a deep copy or a new version can take several seconds. Please be patient.</p>
	<p>Selected Record ID###form.site_x_option_group_set_id# | Title: #qSet.site_x_option_group_set_title#</p>
	<hr />
	<div id="copyMessageDiv">
		<h3><a href="##" onclick="doDeepCopy('/z/feature/admin/feature-deep-copy/copySchema?site_x_option_group_set_id=#form.site_x_option_group_set_id#'); return false;">Deep Copy</a></h3>
		<p>A deep copy will force the URL to be unique, but all other data including text, files And sub-records will be fully cloned.</p>
		<h3><a href="/z/feature/admin/features/addSchema?feature_id=#qSet.feature_id#&amp;feature_schema_id=#qSet.feature_schema_id#&amp;site_x_option_group_set_id=#form.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=#qSet.site_x_option_group_set_parent_id#">Shallow Copy</a></h3>
		<p>Shallow copy prefills the form for creating a new record with only this record's text.  All files and sub-records will be left blank on the new record.</p>
		<cfif request.zos.istestserver>
			<cfif isVersionLimitReached(form.site_x_option_group_set_id, qSet.site_id)>
				<h3>Version limit reached.  You must delete a previous version before creating a new one.</h3>
				<p><a href="/z/feature/admin/feature-deep-copy/versionList?site_x_option_group_set_id=#form.site_x_option_group_set_id#">List versions</a></p>
			<cfelse>
				<h3><a href="##" onclick="doDeepCopy('/z/feature/admin/feature-deep-copy/createVersion?site_x_option_group_set_id=#form.site_x_option_group_set_id#'); return false;">Create new version</a></h3>
				<p>A version is a deep copy that is linked with the original record.  The new record will be invisible to the public until finalized.  You will be able to preserve the URL and existing relationships that the original record had when you set the version to be the primary record.</p>
			</cfif>
		</cfif>
		<h3><a href="/z/feature/admin/features/manageSchema?feature_id=#qSet.feature_id#&amp;feature_schema_id=#qSet.feature_schema_id#">Cancel</a></h3>
	</div>
	 <!--- ajax for /z/feature/admin/feature-deep-copy/getCopyMessage until it returns "", then refresh page... --->

	<cfif structkeyexists(form, 'createVersion')>
		
		<script type="text/javascript">
		zArrDeferredFunctions.push(function(){
			doDeepCopy('/z/feature/admin/feature-deep-copy/createVersion?site_x_option_group_set_id=#form.site_x_option_group_set_id#');
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
