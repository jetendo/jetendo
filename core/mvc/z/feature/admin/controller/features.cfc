<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject;
	var qSiteFieldApp=0; 
	variables.allowGlobal=false;

	form.site_id=request.zos.globals.id;
	variables.siteIdList="'"&request.zos.globals.id&"'";
	variables.publicSiteIdList="'0','"&request.zos.globals.id&"'";
	if(application.zcore.user.checkGroupAccess("user")){
		if(request.zos.isDeveloper){
			variables.allowGlobal=true;
			variables.siteIdList="'0','"&request.zos.globals.id&"'";
		}
	}
	if(not application.zcore.functions.zIsWidgetBuilderEnabled()){
		if(form.method EQ "manageFields" or form.method EQ "add" or form.method EQ "edit"){
			application.zcore.functions.z301Redirect('/member/');
		}
	}
	
	variables.recurseCount=0;
	if(form.method EQ "autoDeleteSchema" or 
		form.method EQ "publicAddSchema" or form.method EQ "publicEditSchema" or 
		form.method EQ "internalSchemaUpdate" or form.method EQ "publicMapInsertSchema" or 
		form.method EQ "publicInsertSchema" or form.method EQ "publicUpdateSchema" or 
		form.method EQ "publicAjaxInsertSchema"){

	}else{ 
		if(form.method EQ "archiveSchema" or form.method EQ "unarchiveSchema" or form.method EQ "manageSchema" or form.method EQ "addSchema" or form.method EQ "editSchema" or form.method EQ "deleteSchema" or form.method EQ "insertSchema" or form.method EQ "updateSchema" or form.method EQ "getRowHTML"){
			if(not application.zcore.adminSecurityFilter.checkFeatureAccess("Features")){
				// check if user has access to feature_schema_id only 
				groupId=application.zcore.functions.zso(form, 'feature_schema_id', true);
				i=0;
				while(true){
					i++;
					db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# WHERE 
					feature_id=#db.param(form.feature_id)# and 
					feature_schema_deleted=#db.param(0)# and 
					feature_schema_id=#db.param(groupId)#";
					qSchema=db.execute("qSchema");
					if(qSchema.feature_schema_parent_id EQ 0){
						break;
					}else{
						groupId=qSchema.feature_schema_parent_id;
					}
					if(i>255){
						throw("Infinite loop looking for feature_schema_parent_id=0");
					}
				} 
				if(form.method EQ "deleteSchema" or form.method EQ "insertSchema" or form.method EQ "updateSchema"){
					writeEnabled=true;
				}else{
					writeEnabled=false;
				} 
				application.zcore.adminSecurityFilter.requireFeatureAccess("Custom: "&qSchema.feature_schema_variable_name, writeEnabled);	 
			} 
		}else{
			application.zcore.adminSecurityFilter.requireFeatureAccess("Features");	
		}
	}

	if(structkeyexists(form, 'zQueueSortAjax')){
		return;
	}
	devToolsEnabled=false;
	if(application.zcore.user.checkGroupAccess("administrator") and application.zcore.functions.zIsWidgetBuilderEnabled()){
		allowedMethods={
			"manageSchema":true,
			"manageFields":true
		}
		if(structkeyexists(allowedMethods, form.method)){
			devToolsEnabled=true;
		}
	}
	</cfscript>
	<cfif devToolsEnabled> 
		<div class="z-float z-mb-10 z-site-option-devtools">
			DevTools:
			<cfif application.zcore.functions.zso(form, 'feature_schema_id') NEQ "">
				Current Schema:
				<a href="/z/feature/admin/feature-schema/edit?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#">Edit Schema</a> | 
				<a href="/z/feature/admin/features/manageFields?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#">Edit Fields</a> | 
				Manage: 
			</cfif> 
			<cfif application.zcore.user.checkServerAccess()>
				<a href="/z/feature/admin/features/searchReindex">Search Reindex</a> | 
			</cfif>
			<!--- <a href="/z/feature/admin/feature-sync/index">Sync</a> |  --->
			<a href="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#">Schemas</a> | 
			<a href="/z/feature/admin/feature-schema/add?feature_id=#form.feature_id#&returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Add Schema</a> 
		</div> 
	</cfif>
</cffunction>



<cffunction name="searchReindex" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	form.sid=request.zos.globals.id;
	application.zcore.featureCom.searchReindex();
	</cfscript>
	<h2>Search reindexed for this site only.</h2>
	<p><a href="/z/server-manager/tasks/search-index/index">Click here to reindex search on all sites</a></p>
</cffunction>
	

<cffunction name="import" localmode="modern" access="remote" roles="member">
	<cfscript>
	var row=0;
	var qField=0;
	var db=request.zos.queryObject;
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.11.1.1");
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id');
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# WHERE 
	feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qS=db.execute("qS");
	if(qS.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Feature Schema doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?zsid=#request.zsid#");
	}
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id');
	// all options except for html separator
	db.sql="select * from #db.table("feature_field", request.zos.zcoreDatasource)# WHERE 
	feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_field_type_id <> #db.param(11)# and 
	feature_field_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qField=db.execute("qField");
	arrRequired=arraynew(1);
	arrOptional=arraynew(1);
	for(row in qField){
		if(row.feature_field_required EQ 1){
			arrayAppend(arrRequired, row.feature_field_variable_name);	
		}else{
			arrayAppend(arrOptional, row.feature_field_variable_name);	
		}
	}
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h3>File Import for Schema: #qS.feature_schema_display_name#</h3> 
	<p>The first row of the CSV file should contain the required fields and as many optional fields as you wish.</p>
	<p>If a value doesn't match the system, it will be left blank when imported.</p> 
	<p>Required fields:<br /><textarea type="text" cols="100" rows="2" name="a1">#arrayToList(arrRequired, chr(9))#</textarea></p>
	<p>Optional fields:<br /><textarea type="text" cols="100" rows="2" name="a2">#arrayToList(arrOptional, chr(9))#</textarea></p>
	<form class="zFormCheckDirty" action="/z/feature/admin/features/processImport?feature_schema_id=#form.feature_schema_id#" enctype="multipart/form-data" method="post">
		<p><input type="file" name="filepath" value="" /></p>
		<cfif request.zos.isDeveloper>
			<h2>Specify optional CFC filter.</h2>
			<p>A struct with each column name as a key will be passed as the first argument to your custom function.</p>
			<p>Code example<br />
			<textarea type="text" cols="100" rows="4" name="a3">#htmleditformat('<cfcomponent>
			<cffunction name="importFilter" localmode="modern" roles="member">
			<cfargument name="struct" type="struct" required="yes">
			<cfscript>
			if(arguments.struct["column1"] EQ "bad value"){
				arguments.struct["column1"]="correct value";
			}
			return true; /* return false if you do not want to import this record. */
			</cfscript>
			</cffunction>
			</cfcomponent>')#</textarea></p>
			<p>Filter CFC CreateObject Path: <input type="text" name="cfcPath" value="" /> (i.e. root.myImportFilter)</p>
			<p>Filter CFC Method: <input type="text" name="cfcMethod" value="" /> (i.e. functionName)</p>
		</cfif>
		 <input type="submit" name="submit1" value="Import CSV" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
		<div id="pleaseWait" style="display:none;">Please wait...</div>
	</form>
</cffunction>

<cffunction name="processImport" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	
	setting requesttimeout="10000";
	form.feature_id=application.zcore.functions.zso(form, 'feature_id');
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id');
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# WHERE 
	feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qS=db.execute("qS");
	if(qS.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Feature Schema doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?zsid=#request.zsid#");
	}
	// all options except for html separator
	db.sql="select * from #db.table("feature_field", request.zos.zcoreDatasource)# WHERE 
	feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_field_deleted = #db.param(0)# and
	feature_field_type_id <> #db.param(11)# and 
	feature_id=#db.param(form.feature_id)# ";
	qField=db.execute("qField");
	arrRequired=arraynew(1);
	arrOptional=arraynew(1);
	requiredStruct={};
	optionalStruct={};
	defaultStruct={};
	var fieldIdLookupByName={}; 
	var dataStruct={};
	
	
	for(row in qField){
		fieldIdLookupByName[row.feature_field_variable_name]=row.feature_field_id;
		defaultStruct[row.feature_field_variable_name]=row.feature_field_default_value;
		
		typeStruct=deserializeJson(row.feature_field_type_json); 
		var currentCFC=application.zcore.featureCom.getTypeCFC(row.feature_field_type_id);
		dataStruct[row.feature_field_id]=currentCFC.onBeforeImport(row, typeStruct); 
		
		if(row.feature_field_required EQ 1){
			requiredStruct[row.feature_field_variable_name]="";	
		}else{
			optionalStruct[row.feature_field_variable_name]="";
		}
	}
	 
	if(structkeyexists(form, 'filepath') EQ false or form.filepath EQ ""){
		application.zcore.status.setStatus(request.zsid, "You must upload a CSV file", true);
		application.zcore.functions.zRedirect("/z/feature/admin/features/import?zsid=#request.zsid#&feature_schema_id=#form.feature_schema_id#");
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
			application.zcore.functions.zRedirect("/z/feature/admin/features/import?feature_schema_id=#form.feature_schema_id#&zsid=#request.zsid#");
		}
		structdelete(requiredCheckStruct, dataImportCom.arrColumns[n]);
		if(structkeyexists(ts, dataImportCom.arrColumns[n])){
			application.zcore.status.setStatus(request.zsid, "The column , ""#dataImportCom.arrColumns[n]#"",  has 1 or more duplicates.  Make sure only one column is used per field name.", false, true);
			application.zcore.functions.zRedirect("/z/feature/admin/features/import?feature_schema_id=#form.feature_schema_id#&zsid=#request.zsid#"); 
		}
		ts[dataImportCom.arrColumns[n]]=dataImportCom.arrColumns[n];
	}
	if(structcount(requiredCheckStruct)){
		application.zcore.status.setStatus(request.zsid, "The following required fields were missing in the column header of the CSV file: "&structKeyList(requiredCheckStruct)&".", false, true);
		application.zcore.functions.zRedirect("/z/feature/admin/features/import?feature_schema_id=#form.feature_schema_id#&zsid=#request.zsid#"); 
	} 
	dataImportCom.mapColumns(ts);
	arrData=arraynew(1);
	curCount=dataImportCom.getCount();
	for(g=1;g  LTE curCount;g++){
		ts=dataImportCom.getRow();	
		for(i in requiredStruct){
			if(trim(ts[i]) EQ ""){
				application.zcore.status.setStatus(request.zsid, "#i# was empty on row #g# and it is a required field.  Make sure all required fields are entered and re-import.", false, true);
				application.zcore.functions.zRedirect("/z/feature/admin/features/import?feature_schema_id=#form.feature_schema_id#&zsid=#request.zsid#"); 
			}
		}
		// check required fields are set for all rows
	}
	dataImportCom.resetCursor();
	//dataImportCom.skipLine();
	arrSiteFieldId=[];
	for(i in defaultStruct){
		arrayAppend(arrSiteFieldId, fieldIdLookupByName[i]); 
	}
	form.feature_data_id=0;
	form.site_id=request.zos.globals.id;
	form.feature_data_parent_id=0;
	form.feature_field_id=arraytolist(arrSiteFieldId, ",");
	
	filterEnabled=false;
	if(request.zos.isDeveloper){
		if(form.cfcPath NEQ "" and form.cfcMethod NEQ ""){
			if(left(form.cfcPath, 5) EQ "root."){
				form.cfcPath=request.zrootcfcpath&removechars(form.cfcPath, 1, 5);
			}
			filterInstance=application.zcore.functions.zcreateobject("component", form.cfcPath);	
			filterEnabled=true;
		}
	}
	request.zos.disableSiteCacheUpdate=true; 
	for(g=1;g  LTE curCount;g++){
		ts=dataImportCom.getRow();	
		for(i in ts){
			ts[i]=trim(ts[i]);
			if(len(ts[i]) EQ 0){
				structdelete(ts, i);
			}
		}
		if(filterEnabled){
			result=filterInstance[form.cfcMethod](ts);
			if(not result){
				continue;
			}
		}
		structappend(ts, defaultStruct, false);  
		for(i in ts){ 
			if(structkeyexists(dataStruct, fieldIdLookupByName[i]) and dataStruct[fieldIdLookupByName[i]].mapData){
				arrC=listToArray(ts[i], ",");
				arrC2=[];
				for(i2=1;i2 LTE arraylen(arrC);i2++){
					c=trim(arrC[i2]);
					if(structkeyexists(dataStruct[fieldIdLookupByName[i]].struct, c)){
						arrayAppend(arrC2, dataStruct[fieldIdLookupByName[i]].struct[c]);
					}
				}
				ts[i]=arrayToList(arrC2, ",");
			} 
			form['newvalue'&fieldIdLookupByName[i]]=ts[i];
		}   
		//writedump(ts);		writedump(form);		abort;
		form.feature_data_approved=1;
		rs=this.importInsertSchema(); 
		arrayClear(request.zos.arrQueryLog);
	} 
	// update cache only once for better performance.
	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	featureCacheCom.updateSchemaCacheBySchemaId(form.feature_id, form.feature_schema_id);
	application.zcore.status.setStatus(request.zsid, "Import complete.");
	application.zcore.functions.zRedirect("/z/feature/admin/features/import?feature_schema_id=#form.feature_schema_id#&zsid=#request.zsid#");
	 
	</cfscript>
</cffunction> 

 



<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	init();
	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);		 
	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)#
	WHERE feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)#";
	qSchema=db.execute("qSchema"); 
	db.sql="SELECT * FROM #db.table("feature_field", request.zos.zcoreDatasource)# feature_field 
	WHERE feature_field_id = #db.param(form.feature_field_id)# and 
	feature_field_deleted = #db.param(0)# and
	feature_schema_id=#db.param(form.feature_schema_id)#";
	qS2=db.execute("qS2");
	if(qS2.recordcount EQ 0 or qSchema.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, "Feature Field no longer exists.",false,true);
		if(structkeyexists(request.zsession, 'feature_return') and request.zsession['feature_return'] NEQ ""){
			tempURL = request.zsession['feature_return'];
			StructDelete(request.zsession, 'feature_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}else{
			application.zcore.functions.zRedirect('/z/feature/admin/features/manageFields?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&feature_schema_parent_id=#form.feature_schema_parent_id#&zsid=#request.zsid#');
		}
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		arrDeleteStruct=[];
		typeCFCStruct=application.zcore.featureCom.getTypeCFCStruct();
		hasCustomDelete=typeCFCStruct[qS2.feature_field_type_id].hasCustomDelete();
		typeCFC=application.zcore.featureCom.getTypeCFC(qS2.feature_field_type_id); 
		typeStruct=deserializeJson(qS2.feature_field_type_json);

		db.sql="SELECT * FROM #db.table("feature_data", request.zos.zcoreDatasource)# 
		WHERE feature_data.feature_schema_id=#db.param(form.feature_schema_id)# and 
		feature_data.site_id<>#db.param(-1)# and  
		feature_data_deleted = #db.param(0)#";
		qData=db.execute("qData"); 
		for(row in qData){
			// delete file if it is necessary

			arrField=listToArray(row.feature_data_field_order, chr(13), true);
			arrData=listToArray(row.feature_data_data, chr(13), true);
			arrNewField=[];
			arrNewData=[];
			for(i=1;i LTE arraylen(arrField);i++){
				if(arrField[i] NEQ qS2.feature_field_id){
					arrayAppend(arrNewField, arrField[i]);
					arrayAppend(arrNewData, arrData[i]);
				}else if(arrData[i] NEQ ""){
					typeCFC.onDelete(arrData[i], row.site_id, typeStruct); 
				}
			}
			db.sql="UPDATE #db.table("feature_data", request.zos.zcoreDatasource)# SET 
			feature_data_field_order=#db.param(arrayToList(arrNewField, chr(13)))#, 
			feature_data_data=#db.param(arrayToList(arrNewData, chr(13)))# 
			WHERE 
			feature_data_id=#db.param(row.feature_data_id)# and 
			site_id=#db.param(row.site_id)# and 
			feature_data_deleted=#db.param(0)# ";
			db.execute("qUpdate");
		}
			
		db.sql="DELETE FROM #db.table("feature_field", request.zos.zcoreDatasource)#  
		WHERE feature_field_id = #db.param(form.feature_field_id)# and 
		feature_field_deleted = #db.param(0)# ";
		q=db.execute("q"); 
		featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
		featureCacheCom.updateSchemaCacheBySchemaId(qS2.feature_id, qS2.feature_schema_id);
		if(qS2.feature_schema_id NEQ 0){
			queueSortStruct = StructNew();
			queueSortStruct.tableName = "feature_field";
			queueSortStruct.sortFieldName = "feature_field_sort";
			queueSortStruct.primaryKeyName = "feature_field_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			queueSortStruct.where ="  feature_schema_id = '#application.zcore.functions.zescape(qS2.feature_schema_id)#' and  
			feature_field_deleted='0' ";
			
			queueSortStruct.disableRedirect=true;
			queueComStruct = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
			queueComStruct.init(queueSortStruct);
			queueComStruct.sortAll();
		}
		application.zcore.status.setStatus(request.zsid, "Feature Field deleted.");
		if(structkeyexists(request.zsession, 'feature_return') and request.zsession['feature_return'] NEQ ""){
			tempURL = request.zsession['feature_return'];
			StructDelete(request.zsession, 'feature_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}else{
			application.zcore.functions.zRedirect('/z/feature/admin/features/manageFields?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&feature_schema_parent_id=#form.feature_schema_parent_id#&zsid=#request.zsid#');
		}
		</cfscript>
	<cfelse>
		<cfscript>
		request.zsession["feature_return"&form.feature_field_id]=application.zcore.functions.zso(form, 'returnURL');		
		theTitle="Delete Field";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<div style="text-align:center;"><span class="medium"> Are you sure you want to delete this Feature Field?<br />
			<br />
			<strong>WARNING: </strong>This cannot be undone and any saved values will be deleted and any references to the Feature Field on the web site will throw errors upon deletion.<br />
			<br />
			Make sure you have removed all hardcoded references from the source code before continuing!<br />
			<br />
			#qS2.feature_field_variable_name#<br />
			<br />
			<script type="text/javascript">
			/* <![CDATA[ */
			function confirmDelete(){
				var r=confirm("Are you sure you want to permanently delete this feature?");
				if(r){
					window.location.href='/z/feature/admin/features/delete?feature_id=#form.feature_id#&confirm=1&feature_schema_id=#form.feature_schema_id#&feature_schema_parent_id=#form.feature_schema_parent_id#&feature_field_id=#form.feature_field_id#<cfif structkeyexists(form, 'globalvar')>&globalvar=1</cfif>';	
				}else{
					window.location.href='/z/feature/admin/features/manageFields?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&feature_schema_parent_id=#form.feature_schema_parent_id#';
				}
			}
			/* ]]> */
			</script> 
			<a href="##" onclick="confirmDelete();return false;">Yes, delete this feature</a><br />
			<br />
			<a href="/z/feature/admin/features/manageFields?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&amp;feature_schema_parent_id=#form.feature_schema_parent_id#">No, don't delete this feature</a></span>
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	myForm=structnew();
	init();
	form.siteglobal=application.zcore.functions.zso(form,'siteglobal', false, 0);

	application.zcore.adminSecurityFilter.requireFeatureAccess("Features", true);	 
	if(form.method EQ 'insert'){
		formaction='add';	
	}else{
		formaction='edit';
	}
	if(structkeyexists(form, 'globalvar') or (form.siteglobal EQ 1 and variables.allowGlobal)){
		form.site_id=0;	
		returnAppendString="&globalvar=1";
	}else{
		returnAppendString="";
		form.site_id=request.zos.globals.id;
	}  
	
	if(form.method EQ "update"){
		db.sql="select * from #db.table("feature_field", request.zos.zcoreDatasource)# feature_field 
		where feature_field_id = #db.param(form.feature_field_id)# and 
		feature_field_deleted = #db.param(0)#"; 
		qCheck=db.execute("qCheck");
		if(qCheck.site_id EQ 0 and variables.allowGlobal EQ false){
			application.zcore.functions.zRedirect("/z/feature/admin/features/index?feature_id=#form.feature_id#");
		}
		// force code name to never change after initial creation
		//form.feature_field_variable_name=qCheck.feature_field_variable_name;
	}
	myForm.feature_field_display_name.required=true;
	myForm.feature_field_display_name.friendlyName="Display Name";
	myForm.feature_field_variable_name.required = true;
	myForm.feature_field_variable_name.friendlyName="Code Name";
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result eq true){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("/z/feature/admin/features/#formAction#?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&zsid=#Request.zsid#&feature_field_id=#form.feature_field_id#"&returnAppendString);
	}
	var rs=0;
	var currentCFC=application.zcore.featureCom.getTypeCFC(form.feature_field_type_id);
	form.feature_field_type_json="{}";
	// need this here someday: var rs=currentCFC.validateFormField(row, typeStruct, 'newvalue', form);
	rs=currentCFC.onUpdate(form);   
	if(not rs.success){ 
		application.zcore.functions.zRedirect("/z/feature/admin/features/#formAction#?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&zsid=#Request.zsid#&feature_field_id=#form.feature_field_id#"&returnAppendString);	
	}
	db.sql="SELECT *
	FROM #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# ";
	qSchema=db.execute("qSchema");
	if(qSchema.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid Schema ID", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/features/#formAction#?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&zsid=#Request.zsid#&feature_field_id=#form.feature_field_id#"&returnAppendString);
	}
	form.feature_id=qSchema.feature_id;
	db.sql="SELECT count(feature_field_id) count 
	FROM #db.table("feature_field", request.zos.zcoreDatasource)# feature_field 
	WHERE feature_field_variable_name = #db.param(form.feature_field_variable_name)# and 
	feature_field_deleted = #db.param(0)# and
	feature_schema_id =#db.param(form.feature_schema_id)# and 
	feature_field_id <> #db.param(form.feature_field_id)# and 
	feature_id = #db.param(form.feature_id)#";
	qDF=db.execute("qDF");
	if(qDF.count NEQ 0){
		application.zcore.status.setStatus(request.zsid,"Feature Field ""#form.feature_field_variable_name#"" already exists. Please make the name unique.",form);
		application.zcore.functions.zRedirect("/z/feature/admin/features/#formaction#?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&feature_field_id=#form.feature_field_id#&zsid=#request.zsid#"&returnAppendString);	
	}
	ts=structnew();
	ts.table="feature_field"; 
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ 'insert'){ 
		form.feature_field_id=application.zcore.functions.zInsert(ts); 
		if(form.feature_field_id EQ false){
			application.zcore.status.setStatus(request.zsid,"Failed to create Feature Field because ""#form.feature_field_variable_name#"" already exists or  the insert query failed.",form);
			application.zcore.functions.zRedirect("/z/feature/admin/features/#formaction#?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&zsid=#request.zsid#"&returnAppendString);
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid,"Failed to UPDATE #db.table("site", request.zos.zcoreDatasource)# Feature Field because ""#form.feature_field_variable_name#"" already exists. Please make the name unique.",form);
			application.zcore.functions.zRedirect("/z/feature/admin/features/#formaction#?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&feature_field_id=#form.feature_field_id#&zsid=#request.zsid#"&returnAppendString);	
		}
	}
	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	featureCacheCom.updateSchemaCacheBySchemaId(form.feature_id, form.feature_schema_id);
	if(form.method EQ 'insert'){
		if(form.feature_schema_id NEQ 0 and form.feature_schema_id NEQ ""){
			queueSortStruct = StructNew();
			queueSortStruct.tableName = "feature_field";
			queueSortStruct.sortFieldName = "feature_field_sort";
			queueSortStruct.primaryKeyName = "feature_field_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			queueSortStruct.where ="  feature_schema_id = '#application.zcore.functions.zescape(form.feature_schema_id)#' and  
			feature_field_deleted='0' ";
			
			queueSortStruct.disableRedirect=true;
			queueComStruct = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
			queueComStruct.init(queueSortStruct);
			queueComStruct.sortAll();
		}
		application.zcore.status.setStatus(request.zsid, "Feature Field added.");
		if(structkeyexists(request.zsession, 'feature_return')){
			tempURL = request.zsession['feature_return'];
			StructDelete(request.zsession, 'feature_return', true);
			tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
			application.zcore.functions.zRedirect(tempURL, true);
		}
	}else{
		application.zcore.status.setStatus(request.zsid, "Feature Field updated.");
	}
	if(structkeyexists(form, 'feature_field_id') and structkeyexists(request.zsession, 'feature_return'&form.feature_field_id) and request.zsession['feature_return'&form.feature_field_id] NEQ ""){	
		tempURL = request.zsession['feature_return'&form.feature_field_id];
		StructDelete(request.zsession, 'feature_return'&form.feature_field_id, true);
		tempUrl=application.zcore.functions.zURLAppend(replacenocase(tempURL,"zsid=","ztv1=","ALL"),"zsid=#request.zsid#");
		application.zcore.functions.zRedirect(tempURL, true);
	}else{	
		application.zcore.functions.zRedirect('/z/feature/admin/features/manageFields?feature_id=#form.feature_id#&zsid=#request.zsid#&feature_schema_id=#form.feature_schema_id#');
	}
	</cfscript>
</cffunction>

<cffunction name="autocompleteTips" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.template.setTag("pagetitle", "Field Autocomplete Tips");
	</cfscript>
	<p>The following phrases will automatically map to the corresponding field type until you override it when adding a new option. You can include any number of other words and it will still work.</p>
<table class="table-list">
<tr><th>Words</th>
<th>Field Type</th>
</tr>
<tr><td>"section" and "text"</td><td>html editor</td></tr>
<tr><td>html</td><td>html editor</td></tr>
<tr><td>heading</td><td>text</td></tr>
<tr><td>textarea</td><td>textarea</td></tr>
<tr><td>summary</td><td>html editor</td></tr>
<tr><td>title</td><td>text</td></tr>
<tr><td>subheading</td><td>text</td></tr>
<tr><td>sub-heading</td><td>text</td></tr>
<tr><td>email</td><td>email</td></tr>
<tr><td>map</td><td>map picker</td></tr>
<tr><td>location</td><td>map picker</td></tr>
<tr><td>state</td><td>state</td></tr>
<tr><td>country</td><td>country</td></tr>
<tr><td>color</td><td>color picker</td></tr>
<tr><td>email</td><td>email</td></tr>
<tr><td>url</td><td>url</td></tr>
<tr><td>image</td><td>image</td></tr>
<tr><td>photo</td><td>image</td></tr>
<tr><td>graphic</td><td>image</td></tr>
<tr><td>paragraph</td><td>html editor</td></tr>
<tr><td>"body" and "text"</td><td>html editor</td></tr>
<tr><td>date</td><td>date</td></tr>
<tr><td>file</td><td>file</td></tr>
<tr><td>time</td><td>time</td></tr>
<tr><td>user</td><td>user</td></tr>
</table>	
<br /> 
<h2>Other Autocomplete Features</h2>
	<p>You can make any field automatically become required by adding "*" to the end of the "Code Name" field. The "*" will be automatically removed once typed. Example:</p>
	<ul><li>Title*</li></ul>
	<p>Image, HTML Editor and Textarea support pasting in the dimensions to the "Code Name" field. Example:</p>
	<ul><li>Body Text 400x200</li>
	<li>Section 1 Text 400x300</li>
	</ul>
	<p>Image also lets you enable cropping by adding a third number set to 1. Example:</p>
	<ul><li>Image 250x150x1</li></ul>
	<p>The moment you paste the text, it will automatically remove the numbers from the "Code Name" field.</p>
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
	application.zcore.functions.zSetPageHelpId("2.11.4");
	form.feature_field_id=application.zcore.functions.zso(form, 'feature_field_id');
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id');
	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
	WHERE feature_schema_id = #db.param(form.feature_schema_id)#  and 
	feature_schema_deleted = #db.param(0)#";
	qSchema=db.execute("qSchema", "", 10000, "query", false);	
	if(qSchema.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Invalid Schema ID.");
		application.zcore.functions.zRedirect("/z/feature/admin/features/index?zsid=#request.zsid#");	
	}
	db.sql="SELECT * FROM #db.table("feature_field", request.zos.zcoreDatasource)# feature_field 
	WHERE feature_field_id = #db.param(form.feature_field_id)# and 
	feature_field_deleted = #db.param(0)# ";
	qS=db.execute("qS"); 
	request.zsession["feature_return"&form.feature_field_id]=application.zcore.functions.zso(form, 'returnURL');		
	if(currentMethod EQ 'edit' and qS.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid,"Feature Field doesn't exist.");
		application.zcore.functions.zRedirect("/z/feature/admin/features/index?zsid=#request.zsid#");	
	}
    application.zcore.functions.zQueryToStruct(qS, form, 'feature_id,feature_schema_id');
    application.zcore.functions.zstatusHandler(request.zsid,true);
	if(form.feature_schema_id NEQ "" and form.feature_schema_id NEQ 0){
		variables.allowGlobal=false;
	}
	if(currentMethod EQ 'add'){
		theTitle="Add Field";
	}else{
		theTitle="Edit Field";
	}
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
    </cfscript>
	<script type="text/javascript">
	/* <![CDATA[ */
	function setType(n){

		var count=parseInt(document.getElementById('optionTypeCount').value);	
		for(var i=0;i<=count;i++){
			var t=document.getElementById('typeFields'+i);	
			if(t!=null){
				if(i==n){
					t.style.display="block";
				}else{
					t.style.display="none";
				}
			}
		}
	}
	var displayDefault=<cfif currentMethod EQ 'edit'>false<cfelse>true</cfif>;
	function validateFieldType(){
		var postObj=zGetFormDataByFormId("siteFieldTypeForm");
		var typeId=postObj.feature_field_type_id;
		var arrError=[];  
		if(typeof window["validateFieldType"+typeId] == "undefined"){
			return true;
		}
		window["validateFieldType"+typeId](postObj, arrError);
		if(arrError.length){
			alert(arrError.join("\n"));
			return false;
		}
		return true;
	}
	/* ]]> */
	</script>

	<form class="zFormCheckDirty" name="siteFieldTypeForm" id="siteFieldTypeForm" onsubmit="return validateFieldType();" action="/z/feature/admin/features/<cfif currentMethod EQ "add">insert<cfelse>update</cfif>?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&feature_field_id=#form.feature_field_id#<cfif structkeyexists(form, 'globalvar')>&amp;globalvar=1</cfif>" method="post">
		<table style="border-spacing:0px;" class="table-list"> 
			<tr>
				<th>Schema:</th>
				<td>#qSchema.feature_schema_display_name#</td>
			</tr>
			<tr>
				<th>Code Name:</th>
				<td>
				<input type="text" size="50" name="feature_field_variable_name" id="feature_field_variable_name" value="#htmleditformat(form.feature_field_variable_name)#" onkeyup="var d1=document.getElementById('feature_field_display_name');if(displayDefault){d1.value=this.value;} autofillFieldType(this.value);" onblur="var d1=document.getElementById('feature_field_display_name');if(displayDefault){d1.value=this.value;}"><br />
				Note: <a href="/z/feature/admin/features/autocompleteTips" target="_blank">Autocomplete tips</a>
				<cfif currentMethod NEQ "add">
					<br><strong><span style="color:##900;">BE EXTREMELY CAREFUL.</span>
					If you EDIT the Code Name, you must manually change it on all servers.<br><br>

					Sync only works when the Code Name matches on both servers.  You may cause data loss if you forget about this and Sync incorrectly.
					<br><br>
					  It is not recommended to change the Code Name after a project is live.  Be sure to communicate these changes to the other developers.<br><br>
					  Any code that refers to the Code Name MUST be manually updated immediately after changing the name, or it will throw undefined errors.</strong>
					<!--- #form.feature_field_variable_name#<br />
					<input name="feature_field_variable_name" id="feature_field_variable_name" type="hidden" value="#htmleditformat(form.feature_field_variable_name)#"  />
					Note: Code Name can't be changed after initial creation to allow for simple syncing between sites &amp; servers. --->
				</cfif>

					<script type="text/javascript">
					var optionsSetByUser=false;
					function autofillFieldType(v){
						if(typeSelectedByUser){
							console.log('typeSelectedByUser was true, cancelling autofill.');
							return;
						}
						var arrWord=zStringReplaceAll(zStringReplaceAll(v.toLowerCase(), "\t", " "), "  ", " ").split(" ");
						var arrWordOriginal=zStringReplaceAll(zStringReplaceAll(v, "\t", " "), "  ", " ").split(" ");
						var arrMap=[
							{arrWord:['section', 'text'], type:"html editor"},
							{arrWord:['html'], type:"html editor"},
							{arrWord:['heading'], type:"text"},
							{arrWord:['textarea'], type:"textarea"},
							{arrWord:['summary'], type:"html editor"},
							{arrWord:['title'], type:"text"},
							{arrWord:['subheading'], type:"text"},
							{arrWord:['sub-heading'], type:"text"},
							{arrWord:['email'], type:"email"},
							{arrWord:['map'], type:"map picker"},
							{arrWord:['location'], type:"map picker"},
							{arrWord:['state'], type:"state"},
							{arrWord:['country'], type:"country"},
							{arrWord:['color'], type:"color picker"},
							{arrWord:['email'], type:"email"},
							{arrWord:['url'], type:"url"},
							{arrWord:['image'], type:"image"},
							{arrWord:['photo'], type:"image"},
							{arrWord:['graphic'], type:"image"},
							{arrWord:['paragraph'], type:"html editor"},
							{arrWord:['body', 'text'], type:"html editor"},
							{arrWord:['date'], type:"date"},
							{arrWord:['file'], type:"file"},
							{arrWord:['time'], type:"time"},
							{arrWord:['user'], type:"user"} 
						];
						if(v.substr(v.length-1, 1) == "*"){
							// mark it required and remove *
							$("##feature_field_required1")[0].checked=true;
							v=v.substr(0, v.length-1);
							$("##feature_field_variable_name").val(v);
						}
						var type="text";
						var options={}; 
						var arrWordMatch={};
						var arrWordMatchWord={};
						var removeWordIndex=-1;
						for(var n=0;n<arrMap.length;n++){
							arrWordMatch[n]=0;
							arrWordMatchWord[n]={};
						} 
						for(var i=0;i<arrWord.length;i++){
							w=arrWord[i];
							for(var n=0;n<arrMap.length;n++){
								words=arrMap[n].arrWord;
								for(var g=0;g<words.length;g++){
									var word=words[g];
									if(w == word){ 
										if(typeof arrWordMatchWord[n][word]=="undefined"){
											arrWordMatchWord[n][word]=true;
											arrWordMatch[n]++;
										}
									}
								} 
								if(arrWordMatch[n]==words.length){  
									options={};
									type=arrMap[n].type;
									if(type == "image"){
										for(var g=0;g<arrWord.length;g++){
											var word=arrWord[g];
											if(word.indexOf("x")!=-1){
												var arrSize=word.split("x");
												if(arrSize.length==2){
													// widthxheight
													if(!isNaN(parseInt(arrSize[0])) && !isNaN(parseInt(arrSize[1]))){
														options.imagewidth=arrSize[0];
														options.imageheight=arrSize[1];
														removeWordIndex=g;
													}

												}else if(arrSize.length==3){
													// widthxheightxcrop
													if(!isNaN(parseInt(arrSize[0])) && !isNaN(parseInt(arrSize[1])) && !isNaN(parseInt(arrSize[2]))){
														options.imagewidth=arrSize[0];
														options.imageheight=arrSize[1];
														if(arrSize[2] == "1"){
															options.imagecrop=1;
														}else if(arrSize[2] == "0"){
															options.imagecrop=0;
														}
														removeWordIndex=g;
													}
												}
											}
										}
										break;
									}else if(type == "html editor"){
										for(var g=0;g<arrWord.length;g++){
											var word=arrWord[g];
											if(word.indexOf("x")!=-1){ 
												var arrSize=word.split("x");
												if(arrSize.length==2){
													// widthxheight
													if(!isNaN(parseInt(arrSize[0])) && !isNaN(parseInt(arrSize[1]))){
														options.editorwidth=arrSize[0];
														options.editorheight=arrSize[1];
														removeWordIndex=g;
													}
												}
											}
										}
										break;
									}else if(type == "textarea"){
										for(var g=0;g<arrWord.length;g++){
											var word=arrWord[g];
											if(word.indexOf("x")!=-1){
												var arrSize=word.split("x");
												if(arrSize.length==2){
													// widthxheight
													if(!isNaN(parseInt(arrSize[0])) && !isNaN(parseInt(arrSize[1]))){
														options.editorwidth2=arrSize[0];
														options.editorheight2=arrSize[1];
														removeWordIndex=g;
													}
												}
											}
										}
										break;
									}
								}
							}
						}
						if(removeWordIndex != -1){
							optionsSetByUser=true;
							var arrNewWord=[];
							for(var i=0;i<arrWord.length;i++){
								if(removeWordIndex != i){
									arrNewWord.push(arrWordOriginal[i]);
								}
							}
							var v=arrNewWord.join(" ");
							$("##feature_field_variable_name").val(v);
						}
						if(type !=""){
							setFieldType(type, options);
						}
					} 
					function setFieldType(type, options){
						var arrMap={
							"text":"0",
							"textarea":"1",
							"email":"10",
							"map picker":"13",
							"state":"19",
							"country":"20",
							"color picker":"18",
							"email":"10",
							"url":"15",
							"image":"3",
							"file":"9",
							"date":"5",
							"time":"6",
							"user":"16",
							"html editor":"2"
						};  
						if(!optionsSetByUser){
							if(type == "html editor"){
								if(typeof options.editorwidth == "undefined"){ 
									options.editorwidth=600;
									options.editorheight=300;	
								}
							}else if(type == "textarea"){
								if(typeof options.editorwidth2 == "undefined"){
									options.editorwidth2=300;
									options.editorheight2=150;	
								}
							}
						}
						var fields=$("input[name='feature_field_type_id']");
						if(typeof arrMap[type] != "undefined"){
							var fieldId=arrMap[type];
							for(var i=0;i<fields.length;i++){
								var field=fields[i];
								if(field.value == fieldId){
									setType(parseInt(fieldId));
									field.checked=true; 
									break;
								}
							} 
							for(var i in options){ 
								if(i=="imagecrop"){
									if(options[i]=="1"){
										$("##imagecrop1")[0].checked=true;
									}else{
										$("##imagecrop0")[0].checked=false;
									}
								}else{
									$("##"+i).val(options[i]);
								}
							}
						} 
					}
					var typeSelectedByUser=false;
					zArrDeferredFunctions.push(function(){
						$("input[name='feature_field_type_id']").bind("click", function(){
							typeSelectedByUser=true;
						});
					});
					</script>
				</td>
			</tr>
			<tr>
				<th>Display Name:</th>
				<td><input type="text" size="50" name="feature_field_display_name" id="feature_field_display_name" value="#htmleditformat(form.feature_field_display_name)#" onkeyup="displayDefault=false;"></td>
			</tr>
			<cfscript>
			if(form.feature_field_type_json EQ ""){
				form.feature_field_type_json="{}";
			}
			var typeStruct=deserializeJson(form.feature_field_type_json); 
			</cfscript>
			<tr>
				<th>Type:</th>
				<td>
					<cfscript>
					if(form.feature_field_type_id EQ ""){
						form.feature_field_type_id=0;
					}
					var typeLookupStruct={};
					var i=0;
					var count=0;
					typeCFCStruct=application.zcore.featureCom.getTypeCFCStruct();
					for(i in typeCFCStruct){
						count++;
						typeLookupStruct[typeCFCStruct[i].getTypeName()]=i;
					}
					var arrTemp=structkeyarray(typeLookupStruct);
					arraySort(arrTemp, "text", "asc");
					for(i=1;i LTE arraylen(arrTemp);i++){
						var currentCFC=application.zcore.featureCom.getTypeCFC(typeLookupStruct[arrTemp[i]]);
						writeoutput(currentCFC.getTypeForm(form, typeStruct, 'feature_field_type_id'));
					}
					</cfscript> 
					<input type="hidden" id="optionTypeCount" value="#count#">
					<script type="text/javascript">
					/* <![CDATA[ */
					setType(#application.zcore.functions.zso(form, 'feature_field_type_id',true)#);
					/* ]]> */
					</script>
					</td>
			</tr>
			<tr>
				<th>Default Value:</th>
				<td><textarea cols="40" rows="5" name="feature_field_default_value">#htmleditformat(form.feature_field_default_value)#</textarea></td>
			</tr>
			<cfscript>
			if(form.site_id EQ 0){
				siteglobal=1;
			}else{
				siteglobal=0;
			}
			if(form.feature_field_line_breaks EQ ""){
				form.feature_field_line_breaks=0;	
			} 
			</cfscript> 
			<tr>
				<th>Show in List View:</th>
				<td>
					<input name="feature_field_primary_field" id="feature_field_primary_field1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'feature_field_primary_field', true, 0) EQ 1>checked="checked"</cfif> /> Yes
					<input name="feature_field_primary_field" id="feature_field_primary_field0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'feature_field_primary_field', true, 0) EQ 0>checked="checked"</cfif>  onclick="document.getElementById('feature_field_admin_searchable0').checked=true; document.getElementById('feature_field_admin_sort_field0').checked=true; " /> No</td>
			</tr>
			<tr>
				<th>Required:</th>
				<td>#application.zcore.functions.zInput_Boolean("feature_field_required")#</td>
			</tr>
				<tr>
					<th style="vertical-align:top; white-space:nowrap;">Allow Public?</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_field_allow_public")#</td>
				</tr>
			<!--- <cfif form.feature_schema_id NEQ '' and form.feature_schema_id NEQ 0> --->
				<tr>
					<th>Use for URL/Nav Title:</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_field_url_title_field")#</td>
				</tr>
				<cfif qSchema.feature_schema_enable_unique_url EQ 1>
					<tr>
						<th>Use for Search Summary:</th>
						<td>#application.zcore.functions.zInput_Boolean("feature_field_search_summary_field")#</td>
					</tr>
					<tr>
						<th>Enable Search Index:</th>
						<td>#application.zcore.functions.zInput_Boolean("feature_field_enable_search_index")#</td>
					</tr>
				</cfif>
				<tr>
					<th>Sort (admin):</th>
					<td>
						<cfif qSchema.feature_schema_enable_sorting EQ 1>
						
							<input name="feature_field_admin_sort_field" id="feature_field_admin_sort_field0" style="border:none; background:none;" value="0" type="hidden"> Can't be used when group sorting is enabled.
						<cfelse>
							<input name="feature_field_admin_sort_field" id="feature_field_admin_sort_field1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'feature_field_admin_sort_field', true, 0) EQ 1>checked="checked"</cfif>  onclick="document.getElementById('feature_field_primary_field1').checked=true;"  />  Ascending
							<input name="feature_field_admin_sort_field" id="feature_field_admin_sort_field2" style="border:none; background:none;" type="radio" value="2" <cfif application.zcore.functions.zso(form, 'feature_field_admin_sort_field', true, 0) EQ 2>checked="checked"</cfif>  onclick="document.getElementById('feature_field_primary_field1').checked=true;"  />  Descending
							<input name="feature_field_admin_sort_field" id="feature_field_admin_sort_field0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'feature_field_admin_sort_field', true, 0) EQ 0>checked="checked"</cfif> /> Disabled
					</cfif>
				</td>
				</tr>
				<tr>
					<th>Read-only:</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_field_readonly")#</td>
				</tr>
				<tr>
					<th>Searchable (public):</th>
					<td>
					<input name="feature_field_public_searchable" id="feature_field_public_searchable1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'feature_field_public_searchable', true, 0) EQ 1>checked="checked"</cfif>  /> Yes
					<input name="feature_field_public_searchable" id="feature_field_public_searchable0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'feature_field_public_searchable', true, 0) EQ 0>checked="checked"</cfif> /> No</td>
				</tr>
				<tr>
					<th>Searchable (admin):</th>
					<td>
					<input name="feature_field_admin_searchable" id="feature_field_admin_searchable1" style="border:none; background:none;" type="radio" value="1" <cfif application.zcore.functions.zso(form, 'feature_field_admin_searchable', true, 0) EQ 1>checked="checked"</cfif>  onclick="document.getElementById('feature_field_primary_field1').checked=true;" /> Yes
					<input name="feature_field_admin_searchable" id="feature_field_admin_searchable0" style="border:none; background:none;" type="radio" value="0" <cfif application.zcore.functions.zso(form, 'feature_field_admin_searchable', true, 0) EQ 0>checked="checked"</cfif> /> No</td>
				</tr>
				
				<!---
				not in use anywhere:
				 <tr>
					<th>Search Default (admin):</th>
					<td><input type="text" name="feature_field_admin_search_default" value="#htmleditformat(form.feature_field_admin_search_default)#" /></td>
				</tr> 
				<tr>
					<th>Validator CFC:</th>
					<td><cfscript>
					ts=StructNew();
					ts.name="feature_field_validator_cfc";
					ts.size=50;
					application.zcore.functions.zInput_Text(ts);
					</cfscript><br />
					(Must begin with zcorerootmapping or request.zRootCFCPath)</td>
				</tr>
				<tr>
					<th>Validator CFC Method:</th>
					<td><cfscript>
					ts=StructNew();
					ts.name="feature_field_validator_method";
					ts.size=50;
					application.zcore.functions.zInput_Text(ts);
					</cfscript></td>
				</tr>--->
			<!--- </cfif> --->

			<!--- 
			TODO: feature_field_user_group_id_list | this feature is not fully implemented yet
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Enable Data Entry<br />For User Schemas","member.feature-schema.edit feature_field_user_group_id_list")#</th>
				<td>
				<cfscript>
				db.sql="SELECT *FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
				WHERE feature_id=#db.param(form.feature_id)# and 
				user_group_deleted = #db.param(0)# 
				ORDER BY user_group_name asc"; 
				var qSchema2=db.execute("qSchema2"); 
				ts = StructNew();
				ts.name = "feature_field_user_group_id_list";
				ts.friendlyName="";
				// options for query data
				ts.multiple=true;
				ts.query = qSchema2;
				ts.queryLabelField = "user_group_friendly_name";
				ts.queryValueField = "user_group_id";
				application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'feature_field_user_group_id_list'));
				application.zcore.functions.zInputSelectBox(ts);
				</cfscript></td>
			</tr> --->
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Force Small Label Width","member.feature-schema.edit feature_field_small_width")#</th>
				<td>#application.zcore.functions.zInput_Boolean("feature_field_small_width")# (With yes selected, public forms will force the label column to be as small as possible.)</td>
			</tr>
			<tr>
				<th style="vertical-align:top; white-space:nowrap;">Hide Label?</th>
				<td>#application.zcore.functions.zInput_Boolean("feature_field_hide_label")#</td>
			</tr>
			<tr>
				<th>Add Line Breaks:</th>
				<td>#application.zcore.functions.zInput_Boolean("feature_field_line_breaks")# (Useful for textarea field type to force newlines to &lt;br&gt;)</td>
			</tr>
			<tr>
				<th>Use Original Value?</th>
				<td>#application.zcore.functions.zInput_Boolean("feature_field_use_original_value")# (Preserves links to this domain and spaces in the submitted form data)</td>
			</tr>
			<tr>
				<th>Label On Top?</th>
				<td>#application.zcore.functions.zInput_Boolean("feature_field_label_on_top")# (Allows putting longer labels above the field)</td>
			</tr>
			<!---
			Not implemented yet
			 <tr>
				<th>Add To Previous Row:</th>
				<td>#application.zcore.functions.zInput_Boolean("feature_field_add_to_previous_row")# (Allows putting multiple fields on the same row)</td>
			</tr> --->
			<tr>
				<th>Character Width:</th>
				<td><input type="text" size="10" style="width:auto; min-width:auto;" name="feature_field_character_width" id="feature_field_character_width" value="#htmleditformat(form.feature_field_character_width)#" onkeyup="displayDefault=false;"> (Only works for text/select input types)</td>
			</tr>
			<cfif variables.allowGlobal>
				<tr>
					<th>Listing Only:</th>
					<td>#application.zcore.functions.zInput_Boolean("feature_field_listing_only")#</td>
				</tr>
			</cfif>
			<cfif variables.allowGlobal>
				<cfscript>
				if(form.site_id EQ 0){
					form.siteglobal=1;
				}
				</cfscript>
				<tr>
					<th>Global:</th>
					<td>#application.zcore.functions.zInput_Boolean("siteglobal")#</td>
				</tr>
			</cfif>
			<tr>
				<th>Tooltip Help Box:</th>
				<td><cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
				htmlEditor.instanceName	= "feature_field_tooltip";
				htmlEditor.value			= form.feature_field_tooltip;
				htmlEditor.width			= "100%";
				htmlEditor.height		= 100;
				htmlEditor.create();
				</cfscript></td>
			</tr>
			<tr>
				<th>&nbsp;</th>
				<td><input type="submit" name="submitForm" value="Submit" class="z-manager-search-button" />
					<input type="button" name="cancel" value="Cancel" class="z-manager-search-button" onClick="window.location.href = '/z/feature/admin/features/manageFields?feature_id=#form.feature_id#&feature_schema_id=#application.zcore.functions.zso(form, 'feature_schema_id')#&amp;feature_schema_parent_id=#application.zcore.functions.zso(form, 'feature_schema_parent_id')#';" /></td>
			</tr>
		</table>
		<cfif variables.allowGlobal EQ false>
			<input type="hidden" name="siteglobal" value="0" />
		</cfif>
	</form> 
</cffunction>

<cffunction name="manageFields" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	init();
	application.zcore.functions.zSetPageHelpId("2.11.3");
    application.zcore.functions.zstatusHandler(request.zsid);
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id',true);
	form.feature_schema_parent_id=application.zcore.functions.zso(form, 'feature_schema_parent_id', true);
    db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
	WHERE feature_schema_id = #db.param(form.feature_schema_id)# and  
	feature_schema_deleted=#db.param(0)# ";
	qSchema=db.execute("qSchema", "", 10000, "query", false);
	queueComStruct=structnew();
	if(qSchema.recordcount EQ 0){
		application.zcore.functions.zredirect("/z/feature/admin/features/index");
	}  
	  
	form.feature_id=qSchema.feature_id;

	db.sql="select * from #db.table("feature", request.zos.zcoreDatasource)# 
	where feature_id=#db.param(form.feature_id)# and 
	feature_deleted = #db.param(0)# and
	#application.zcore.featureCom.filterSiteFeatureSQL(db, "feature")#";
	request.qFeature=db.execute("qFeature", "", 10000, "query", false);
	if(request.qFeature.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid feature id", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?zsid=#request.zsid#");
	}


	theTitle="Schema Fields: "&qSchema.feature_schema_display_name;
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	lastSchema="";
	loop query="qSchema"{
		lastSchema=qSchema.feature_schema_display_name;
		queueSortStruct = StructNew();
		queueSortStruct.tableName = "feature_field";
		queueSortStruct.sortFieldName = "feature_field_sort";
		queueSortStruct.primaryKeyName = "feature_field_id";
		//queueSortStruct.sortVarName="siteSchema"&qSchema.feature_schema_id;
		queueSortStruct.datasource=request.zos.zcoreDatasource;
		queueSortStruct.where ="  feature_schema_id = '#application.zcore.functions.zescape(qSchema.feature_schema_id)#' and 
		feature_field_deleted='0' ";

		
		queueSortStruct.ajaxTableId='sortRowTable';
		queueSortStruct.ajaxURL='/z/feature/admin/features/manageFields?feature_schema_parent_id=#form.feature_schema_parent_id#&feature_schema_id=#form.feature_schema_id#';

		queueSortStruct.disableRedirect=true;
		queueComStruct["obj"&qSchema.feature_schema_id] = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
		queueComStruct["obj"&qSchema.feature_schema_id].init(queueSortStruct);
		featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
		featureCacheCom.updateSchemaCacheBySchemaId(qSchema.feature_id, qSchema.feature_schema_id);
		if(structkeyexists(form, 'zQueueSort')){
			application.zcore.functions.zredirect(request.cgi_script_name&"?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
		}
		if(structkeyexists(form, 'zQueueSortAjax')){
			queueComStruct["obj"&qSchema.feature_schema_id].returnJson();
		}
	} 
	db.sql="SELECT * FROM #db.table("feature_field", request.zos.zcoreDatasource)# feature_field 
	LEFT JOIN #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema ON 
	feature_schema_deleted = #db.param(0)# and
	feature_schema.feature_schema_id = feature_field.feature_schema_id 
	WHERE 
	feature_field_deleted = #db.param(0)# and
	feature_field.feature_schema_id = #db.param(form.feature_schema_id)# 
	ORDER BY feature_schema.feature_schema_display_name asc, feature_field.feature_field_sort ASC, feature_field.feature_field_variable_name ASC";
	qS=db.execute("qS"); 
	writeoutput('<p><a href="/z/feature/admin/feature-manage/index">Features</a> / <a href="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#">#request.qFeature.feature_display_name#</a> /');
	if(qSchema.recordcount NEQ 0 and qSchema.feature_schema_parent_id NEQ 0){
		curParentId=qSchema.feature_schema_parent_id;
		arrParent=arraynew(1);
		loop from="1" to="25" index="i"{
			db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
			where feature_schema_id = #db.param(curParentId)# and 
			feature_schema_deleted = #db.param(0)#";
			q1=db.execute("q1", "", 10000, "query", false);
			loop query="q1"{
				arrayappend(arrParent, '<a href="/z/feature/admin/feature-schema/index?feature_id=#q1.feature_id#&feature_schema_parent_id=#q1.feature_schema_id#">#application.zcore.functions.zFirstLetterCaps(q1.feature_schema_display_name)#</a> / ');
				curParentId=q1.feature_schema_parent_id;
			}
			if(q1.recordcount EQ 0 or q1.feature_schema_parent_id EQ 0){
				break;
			}
		}
		for(i = arrayLen(arrParent);i GTE 1;i--){
			writeOutput(arrParent[i]&' ');
		}
		if(qSchema.feature_schema_parent_id NEQ 0){
			writeoutput(application.zcore.functions.zFirstLetterCaps(qSchema.feature_schema_display_name)&" / ");
		}
	}
	writeoutput('</p>');
	</cfscript>
	<cfif qSchema.recordcount NEQ 0>
		<p><a href="/z/feature/admin/features/add?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&amp;feature_schema_parent_id=#qSchema.feature_schema_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">Add Field</a> | <a href="/z/feature/admin/feature-schema/index?feature_id=#form.feature_id#&feature_schema_parent_id=#form.feature_schema_id#">Manage Child Schemas</a></p>
	</cfif>
	<table id="sortRowTable" class="table-list" style="width:100%;">
		<thead>
		<tr>
			<th>ID</th>
			<th>Name</th>
			<th>Type</th>
			<th>List View?</th>
			<th>Required</th>
			<th>Public</th>
			<cfif variables.allowGlobal>
				<th>Global</th>
			</cfif>
			<cfif lastSchema NEQ "">
				<th>Sort</th>
			</cfif>
			<th>Admin</th>
		</tr>
		</thead>
		<tbody>
		<cfscript>
		var row=0;
		for(row in qS){
			writeoutput('<tr #queueComStruct["obj"&qS.feature_schema_id].getRowHTML(qS.feature_field_id)# ');
			if(qS.currentrow MOD 2 EQ 0){
				writeoutput('class="row1"');
			}else{
				writeoutput('class="row2"');
			}
			writeoutput('>
				<td>#qS.feature_field_id#</td>
				<td>#qS.feature_field_variable_name#</td>
				<td>');
				var currentCFC=application.zcore.featureCom.getTypeCFC(qS.feature_field_type_id);
				writeoutput(currentCFC.getTypeName()); 
				writeoutput('</td>');
				if(row.feature_field_primary_field EQ 1){
					echo('<td>Yes</td>');
				}else{
					echo('<td>No</td>');
				}
				if(row.feature_field_required EQ 1){
					echo('<td>Yes</td>');
				}else{
					echo('<td>No</td>');
				}
				if(row.feature_field_allow_public EQ 1){
					echo('<td>Yes</td>');
				}else{
					echo('<td>No</td>');
				}
				if(variables.allowGlobal){
					writeoutput('<td>');
					if(qS.site_id EQ 0){
						writeoutput('Yes');
					}else{
						writeoutput('No');
					}
					writeoutput('</td>');
				}
				if(lastSchema NEQ ""){
					if(qS.site_id NEQ 0 or variables.allowGlobal){
						queueComStruct["obj"&qS.feature_schema_id].getRowStruct(qS.feature_field_id);
						echo('<td>');
							echo('#queueComStruct["obj"&qS.feature_schema_id].getAjaxHandleButton(qS.feature_field_id)#');
						echo('</td>');
					}
				}
				writeoutput('<td>');
				if(qS.site_id NEQ 0 or variables.allowGlobal){
					/*if(lastSchema NEQ ""){
						writeoutput('#queueComStruct["obj"&qS.feature_schema_id].getLinks(qS.recordcount, qS.currentrow, '/z/feature/admin/features/manageFields?feature_schema_parent_id=#qS.feature_schema_parent_id#&amp;feature_schema_id=#qS.feature_schema_id#&amp;feature_field_id=#qS.feature_field_id#', "vertical-arrows")#');
					}*/
					var globalTemp="";
					if(qS.site_id EQ 0){
						globalTemp="&amp;globalvar=1";
					}
					writeoutput('<a href="/z/feature/admin/features/edit?feature_id=#qS.feature_id#&feature_field_id=#qS.feature_field_id#&amp;feature_schema_id=#qS.feature_schema_id#&amp;feature_schema_parent_id=#qS.feature_schema_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)##globalTemp#">Edit</a> | 
					<a href="/z/feature/admin/features/delete?feature_id=#qS.feature_id#&feature_field_id=#qS.feature_field_id#&amp;feature_schema_id=#qS.feature_schema_id#&amp;feature_schema_parent_id=#qS.feature_schema_parent_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)##globalTemp#">Delete</a>');
				}
				writeoutput('</td>
			</tr>');
		}
		</cfscript>
		</tbody>
	</table>
</cffunction>
 

<cffunction name="internalSchemaUpdate" localmode="modern" access="public">
	<cfscript>
	form.method="internalSchemaUpdate";
	if(application.zcore.functions.zso(form, 'feature_data_id', true, 0) EQ 0){
		throw("Warning: form.feature_data_id must be a valid id.");
	}
	return this.updateSchema();
	</cfscript>
</cffunction> 

<cffunction name="importInsertSchema" localmode="modern" access="public" roles="member">
	<cfscript>
	form.method="importInsertSchema";
	return this.updateSchema();
	</cfscript>
</cffunction>
<cffunction name="publicMapInsertSchema" localmode="modern" access="public" roles="member">
	<cfscript>
	form.method="publicMapInsertSchema";
	return this.updateSchema();
	</cfscript>
</cffunction>


<cffunction name="userInsertSchema" localmode="modern" access="remote">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	validateUserSchemaAccess(); 
	this.updateSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="userUpdateSchema" localmode="modern" access="remote">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript> 
	validateUserSchemaAccess(); 
	this.updateSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="publicInsertSchema" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicInsertSchema";
	this.updateSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="publicAjaxInsertSchema" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicAjaxInsertSchema";
	return this.updateSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="publicUpdateSchema" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicUpdateSchema";
	if(application.zcore.functions.zso(form, 'feature_data_id', true, 0) EQ 0){
		throw("Warning: form.feature_data_id must be a valid id.");
	}
	this.updateSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="insertSchema" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.updateSchema();
	</cfscript>
</cffunction>

<cffunction name="updateSchema" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject; 
	var queueSortStruct=structnew(); 
	var nowDate=request.zos.mysqlnow;
	var methodBackup=form.method;
	form.mergeRecord=application.zcore.functions.zso(form, "mergeRecord", true, 0);

 
	if(methodBackup NEQ "publicMapInsertSchema"){
		// bug fix for multiple insert/updates in the same request where map to group is enabled.
		structdelete(form, 'disableSiteSchemaMap');
	}
	defaultStruct=getDefaultStruct();


	if(methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema"){
		// allow email to have attachments for public submissions
		request.zos.arrForceEmailAttachment=[];
	}
	if(methodBackup EQ "publicInsertSchema" or methodBackup EQ "insertSchema" or methodBackup EQ "userInsertSchema"){
		form.feature_data_id=0;
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', false, 0);
	request.zos.siteFieldInsertSchemaCache={};
	form.feature_id=application.zcore.functions.zso(form, 'feature_id', true, 0);
	if(methodBackup NEQ "publicMapInsertSchema" and methodBackup NEQ "importInsertSchema"){
		variables.init();
	}
	if(methodBackup EQ "internalSchemaUpdate" or methodBackup EQ "publicMapInsertSchema" or 
		methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema" or 
		methodBackup EQ "publicUpdateSchema" or methodBackup EQ "userInsertSchema"){
		application.zcore.adminSecurityFilter.auditFeatureAccess("Features", true);
	}else{
		setting requesttimeout="300";
	}
	errors=false;
	var debug=false;
	var startTime=0;
	if(debug) startTime=gettickcount();
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id', true);
	form.feature_data_parent_id=application.zcore.functions.zso(form, 'feature_data_parent_id', true);
	form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id', true);
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id=#db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qCheck=db.execute("qCheck", "", 10000, "query", false); 
	if(qCheck.recordcount EQ 0){
		application.zcore.functions.z404("Invalid feature_schema_id, #form.feature_schema_id#");	
	}


	if(methodBackup EQ "userInsertSchema" or methodBackup EQ "userUpdateSchema"){ 
		arrUserSchema=listToArray(qCheck.feature_schema_user_group_id_list, ",");
		hasAccess=false;
		for(i=1;i LTE arraylen(arrUserSchema);i++){
			if(application.zcore.user.checkSchemaIdAccess(arrUserSchema[i])){
				hasAccess=true;
				break;
			}
		}
		if(not hasAccess){
			application.zcore.functions.z404("feature_schema_id, #form.feature_schema_id#, doesn't allow public data entry.");
		}
	}
	if(qCheck.feature_schema_enable_approval EQ 0){
		form.feature_data_approved=1;
	}
	if((methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema") and not structkeyexists(request.zos, 'disableSpamCheck')){
		 
		if(qCheck.feature_schema_enable_public_captcha EQ 1){
			if(not application.zcore.functions.zVerifyRecaptcha()){
				application.zcore.status.setStatus(request.zsid, "The ReCaptcha security phrase wasn't entered correctly. Please try again.", form, true);
				errors=true;
			}
		}
		form.inquiries_spam=0;
		if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
			form.inquiries_spam=1;
			form.inquiries_spam_description="Fake form fields not empty";
			//application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
			//errors=true;
		}
		if(form.modalpopforced EQ 1){
			if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
				form.inquiries_spam=1;
				form.inquiries_spam_description="js3811 value not set";
				//application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
				//errors=true;
			}
			if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
				form.inquiries_spam=1;
				form.inquiries_spam_description="Form hash value was wrong"; 
				//application.zcore.status.setStatus(request.zsid, "Your session has expired.  Please submit the form again.",form,true);
				//errors=true;
			}
		}
		/* if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
			form.inquiries_spam=1;
			form.inquiries_spam_description="zset9 was wrong";
			//application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
			//errors=true;
		}*/
	}
	if(methodBackup EQ "userInsertSchema" or methodBackup EQ "userUpdateSchema"){
		if(qCheck.feature_schema_user_id_field NEQ ""){
			if(not structkeyexists(arguments.struct, 'arrForceFields')){
				arguments.struct.arrForceFields=[];
			}
			arrayAppend(arguments.struct.arrForceFields, qCheck.feature_schema_user_id_field);

		}
	}


	nowDate="#request.zos.mysqlnow#";
	db.sql="SELECT * FROM #db.table("feature_field", request.zos.zcoreDatasource)# feature_field 
	LEFT JOIN #db.table("feature_data", request.zos.zcoreDatasource)# feature_data ON 
	feature_data.feature_id=#db.param(form.feature_id)# and 
	feature_data.site_id = #db.param(request.zos.globals.id)# and 
	feature_data.feature_data_id=#db.param(form.feature_data_id)# and 
	feature_data_deleted = #db.param(0)# 
	WHERE 
	feature_field_deleted = #db.param(0)# and 
	feature_field.feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_field.feature_id=#db.param(form.feature_id)# 
	ORDER BY feature_field_sort ASC";
	qD=db.execute("qD", "", 10000, "query", false); 
	newDataStruct={};
	var typeStructCache={};
	form.siteFieldTitle="";
	form.siteFieldSummary="";
	form.feature_data_start_date='';
	form.feature_data_end_date='';
	hasTitleField=false;
	hasSummaryField=false;
	hasPrimaryField=false;
	hasUserField=false;
	originalValueStruct={};
	if(qD.feature_data_field_order NEQ ""){
		arrFieldOrder=listToArray(qD.feature_data_field_order, chr(13), true);
		arrFieldData=listToArray(qD.feature_data_data, chr(13), true);
		for(i=1;i<=arraylen(arrFieldOrder);i++){
			originalValueStruct[arrFieldOrder[i]]=arrFieldData[i];
		}
	}
	for(row in qD){
		var typeStruct=deserializeJson(row.feature_field_type_json);
		typeStructCache[row.feature_field_id]=typeStruct; 
		if(row.feature_field_search_summary_field EQ 1){
			hasSummaryField=true;
		}
		if(row.feature_field_url_title_field EQ 1){
			hasTitleField=true;
		}
		var currentCFC=application.zcore.featureCom.getTypeCFC(row.feature_field_type_id);
		if(structkeyexists(form, row.feature_field_variable_name)){
			form['newvalue'&row.feature_field_id]=form[row.feature_field_variable_name];
		}
		if(row.feature_field_primary_field EQ 1 and currentCFC.isSearchable()){
			hasPrimaryField=true;
		}
		nv=currentCFC.getFormValue(row, 'newvalue', form, originalValueStruct);
		if(row.feature_field_required EQ 1){
			if(nv EQ ""){
				application.zcore.status.setFieldError(request.zsid, "newvalue"&row.feature_field_id, true);
				application.zcore.status.setStatus(request.zsid, row.feature_field_display_name&" is a required field.", false, true);
				errors=true;
				continue;
			}
		}
		var rs=currentCFC.validateFormField(row, typeStruct, 'newvalue', form); 
		if(not rs.success){
			application.zcore.status.setFieldError(request.zsid, "newvalue"&row.feature_field_id, true);
			application.zcore.status.setStatus(request.zsid, rs.message, form, true);
			errors=true;
			continue;
		}
	}  
	if(application.zcore.functions.zso(form,'feature_data_override_url') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'feature_data_override_url'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		errors=true;
	}  
	if(errors){
		for(row in qD){
			typeStruct=typeStructCache[row.feature_field_id]; 
			currentCFC=application.zcore.featureCom.getTypeCFC(row.feature_field_type_id);
			currentCFC.onInvalidFormField(row, typeStruct, 'newvalue', form); 
		} 

		application.zcore.status.setStatus(request.zsid, false, form, true);
		if(methodBackup EQ "publicMapInsertSchema" or methodBackup EQ "publicAjaxInsertSchema" or 
			methodBackup EQ "internalSchemaUpdate" or methodBackup EQ "importInsertSchema"){
			return {success:false, errorMessage:"Invalid submission, please check your entries and try again.", zsid:request.zsid};
		}else if(methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicUpdateSchema"){
			
			if(structkeyexists(arguments.struct, 'returnURL')){
				application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.returnURL, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#"));
			}else{
				if(qCheck.feature_schema_public_form_url NEQ ""){
					application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(qCheck.feature_schema_public_form_url, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#"));
				}else{
					application.zcore.functions.zRedirect("/z/feature/feature-display/add?feature_schema_id=#form.feature_schema_id#&feature_schema_id=#form.feature_schema_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
				}
			}
		}else{
			if(methodBackup EQ "userInsertSchema"){
				newMethod="userAddSchema";
			}else if(methodBackup EQ "userUpdateSchema"){
				newMethod="userEditSchema";
			}else if(methodBackup EQ "insertSchema"){
				newMethod="addSchema";
			}else{
				newMethod="editSchema";
			}
			application.zcore.status.displayReturnJson(request.zsid);
			//application.zcore.functions.zRedirect("/z/feature/admin/features/#newMethod#?zsid=#request.zsid#&feature_schema_id=#form.feature_schema_id#&feature_data_parent_id=#form.feature_data_parent_id#&modalpopforced=#form.modalpopforced#");
		}
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1<br>'); startTime=gettickcount();
	var row=0;  
	// arrTempDataInsert=[];
	// arrTempDataUpdate=[];
	arrFieldOrder=[];
	arrFieldData=[];
	newDataMappedStruct={};
	newRecord=false;
	insertCount=0;
	updateCount=0;

	// TODO: important only the public fields are being stored, which causes the other stuff to be lost
	for(row in qD){

		if(methodBackup EQ "userInsertSchema" or methodBackup EQ "insertSchema" or methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema" or methodBackup EQ "publicMapInsertSchema" or methodBackup EQ "importInsertSchema"){
			newRecord=true;
			row.feature_data_created_datetime=request.zos.mysqlnow;
		}
		row.feature_data_updated_datetime=request.zos.mysqlnow;
		
		nv=application.zcore.functions.zso(form, 'newvalue'&row.feature_field_id);
		nvdate="";
		form.site_id=request.zos.globals.id;
		form.feature_data_disable_time=0;
		var typeStruct=typeStructCache[row.feature_field_id]; 
		dataFields=application.zcore.featureCom.parseFieldData(row);
		var currentCFC=application.zcore.featureCom.getTypeCFC(row.feature_field_type_id);
		if(row.feature_field_use_original_value EQ 1){
			rs=currentCFC.onBeforeUpdate(row, typeStruct, 'newvalue', request.zos.originalFormScope, dataFields);
		}else{
			rs=currentCFC.onBeforeUpdate(row, typeStruct, 'newvalue', form, dataFields);
		}
		if(structkeyexists(rs, 'originalFile')){
			rs.value&=chr(9)&rs.originalFile;
		}
		if(qCheck.feature_schema_enable_merge_interface EQ 1 and (methodBackup EQ "addSchema" or methodBackup EQ "userAddSchema")){
			if(form.feature_data_merge_schema_id EQ ""){
				application.zcore.status.setStatus(request.zsid, "You must select a record type", form, true);
				rs.success=false;
				rs.message="You must select a record type";
			}
		}
		if(not rs.success){
			application.zcore.status.setFieldError(request.zsid, "newvalue"&row.feature_field_id, true);
			application.zcore.status.setStatus(request.zsid, rs.message, form, true);
			newAction="";
			if(methodBackup EQ "userInsertSchema"){
				newAction="userAddSchema";
			}else if(methodBackup EQ "userUpdateSchema"){
				newAction="userEditSchema";
			}else if(methodBackup EQ "insertSchema"){
				newAction="addSchema";
			}else if(methodBackup EQ "updateSchema"){
				newAction="editSchema";
			}else{
				newAction="addSchema";
			}  
			if(methodBackup EQ "publicAjaxInsertSchema" or methodBackup EQ "publicMapInsertSchema" or methodBackup EQ "internalSchemaUpdate" or methodBackup EQ "importInsertSchema"){
				return {success:false, errorMessage:"Invalid submission, please check your entries and try again.", zsid:request.zsid};
			}else{ 
				if(newAction NEQ ""){
					application.zcore.status.displayReturnJson(request.zsid);
				}else{
					application.zcore.functions.zRedirect("/z/feature/admin/features/#newAction#?feature_schema_id=#form.feature_schema_id#&feature_data_id=#form.feature_data_id#&feature_data_parent_id=#form.feature_data_parent_id#&zsid=#request.zsid#&modalpopforced=#form.modalpopforced#");
				}
			}
		}
		nv=rs.value;
		nvDate=rs.dateValue; 
		if(nvDate NEQ "" and trim(nvDate) NEQ "00:00:00" and isdate(nvDate)){
			if(timeformat(nvDate, 'h:mm tt') EQ "12:00 am"){
				newDataStruct[row.feature_field_variable_name]=dateformat(nvDate, 'm/d/yyyy');
			}else{
				newDataStruct[row.feature_field_variable_name]=dateformat(nvDate, 'm/d/yyyy')&' '&timeformat(nvDate, 'h:mm tt');
			}
		}else{
			newDataStruct[row.feature_field_variable_name]=rs.value; 
		}
		if(nv EQ "" and row.feature_data_id EQ ''){
			nv=row.feature_field_default_value;
			nvdate=nv;
		} 
		dataStruct=currentCFC.onBeforeListView(row, typeStruct, form);
		newDataMappedStruct[row.feature_field_variable_name]=currentCFC.getListValue(dataStruct, typeStruct, nv);
		if(hasSummaryField){
			if(row.feature_field_search_summary_field EQ 1){
				if(len(form.siteFieldSummary)){
					form.siteFieldSummary&=" "&newDataMappedStruct[row.feature_field_variable_name];
				}else{
					form.siteFieldSummary=newDataMappedStruct[row.feature_field_variable_name];
				}
			}
		}
		if(currentCFC.isSearchable()){
			if(hasTitleField){
				if(row.feature_field_url_title_field EQ 1){
					if(len(form.siteFieldTitle)){
						form.siteFieldTitle&=" "&newDataMappedStruct[row.feature_field_variable_name];
					}else{
						form.siteFieldTitle=newDataMappedStruct[row.feature_field_variable_name];
					}
				}
			}else{
				if(not hasPrimaryField){
					if(form.siteFieldTitle EQ ""){
						form.siteFieldTitle=newDataMappedStruct[row.feature_field_variable_name]; 
					}
				}else if(row.feature_field_primary_field EQ 1){
					if(len(form.siteFieldTitle)){
						form.siteFieldTitle&=" "&newDataMappedStruct[row.feature_field_variable_name];
					}else{
						form.siteFieldTitle=newDataMappedStruct[row.feature_field_variable_name];
					}
				}
			}
		}
		if(qCheck.feature_schema_user_id_field NEQ "" and row.feature_field_variable_name EQ qCheck.feature_schema_user_id_field){
			hasUserField=true;
			if(methodBackup EQ "userInsertSchema" or methodBackup EQ "userUpdateSchema"){
				if(not application.zcore.user.checkGroupAccess("member")){
					// force current user if not an administrative user.
					nv=request.zsession.user.id&"|"&application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
				}
			}
			userFieldValue=nv;

		}

		arrayAppend(arrFieldOrder, replace(row.feature_field_id, chr(13), "", "all"));
	
		// force original value if public user and field is not allowed to be edited by public
		if(qCheck.feature_schema_user_id_field NEQ "" and row.feature_field_variable_name EQ qCheck.feature_schema_user_id_field){
				// allow
		}else if(methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema" or methodBackup EQ "publicUpdateSchema" or methodBackup EQ "userInsertSchema" or methodBackup EQ "userUpdateSchema"){
			if(row.feature_field_allow_public EQ 0){
				// force original value
				if(structkeyexists(originalValueStruct, row.feature_field_id)){
					nv=originalValueStruct[row.feature_field_id];
				}else{
					nv="";
				}
			}
		}

		arrayAppend(arrFieldData, replace(nv, chr(13), "", "all"));
	}
	form.feature_data_approved=application.zcore.functions.zso(form, 'feature_data_approved', false, 1);
	if(methodBackup EQ "publicUpdateSchema" or methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema" or methodBackup EQ "publicMapInsertSchema" or methodBackup EQ "importInsertSchema" or methodBackup EQ "userUpdateSchema" or methodBackup EQ "userInsertSchema"){
		if((methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema" or methodBackup EQ "publicUpdateSchema") and (qCheck.recordcount EQ 0 or qCheck.feature_schema_allow_public NEQ 1)){
			hasAccess=false;
			if(qCheck.recordcount NEQ 0){
				arrUserSchema=listToArray(qCheck.feature_schema_user_group_id_list, ",");
				for(i=1;i LTE arraylen(arrUserSchema);i++){
					if(application.zcore.user.checkSchemaIdAccess(arrUserSchema[i])){
						hasAccess=true;
						break;
					}
				}
			}
			if(not hasAccess){
				application.zcore.functions.z404("feature_schema_id, #form.feature_schema_id#, doesn't allow public data entry.");
			}
		}
		if(qCheck.feature_schema_enable_approval EQ 1){
			if(methodBackup EQ "publicUpdateSchema" or methodBackup EQ "userUpdateSchema"){
				// must force approval status to stay the same on updates.
				db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# WHERE 
				site_id=#db.param(request.zos.globals.id)# and 
				feature_data_id = #db.param(form.feature_data_id)# and 
				feature_data_deleted = #db.param(0)# and
				feature_id=#db.param(form.feature_id)# ";
				qSetCheck=db.execute("qSetCheck");
				if(not application.zcore.user.checkGroupAccess("administrator") and qSetCheck.feature_data_approved EQ 2){
					form.feature_data_approved=0;
				}else{
					form.feature_data_approved=qSetCheck.feature_data_approved;
				}
			}else{
				form.feature_data_approved=0;
			}
		}
	}
	libraryId=application.zcore.functions.zso(form, 'feature_data_image_library_id');
	if(libraryId NEQ 0 and libraryId NEQ ""){
		if(form.feature_data_approved EQ 1){
			application.zcore.imageLibraryCom.approveLibraryId(libraryId);
		}else{
			application.zcore.imageLibraryCom.unapproveLibraryId(libraryId);
		}
	}
	//writedump(arrTempData);	writedump(form);abort;
 
	if(methodBackup EQ "userInsertSchema" or methodBackup EQ "insertSchema" or 
		methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema" or 
		methodBackup EQ "publicMapInsertSchema" or methodBackup EQ "importInsertSchema"){ 
		sortValue=0;
		if(qCheck.feature_schema_enable_sorting EQ 1){
			db.sql="select max(feature_data_sort) sortid 
			from #db.table("feature_data", request.zos.zcoreDatasource)# feature_data 
			WHERE feature_schema_id = #db.param(form.feature_schema_id)# and 
			feature_data_deleted = #db.param(0)# and
			feature_data.site_id=#db.param(request.zos.globals.id)# and 
			feature_id=#db.param(form.feature_id)#";
			qG2=db.execute("qG2");
			if(qG2.recordcount EQ 0 or qG2.sortid EQ ""){
				sortValue=0;
			}else{
				sortValue=qG2.sortid;
			}
			sortValue++;
		}
		form.feature_data_sort=sortValue;
		if(methodBackup EQ "importInsertSchema"){
			form.feature_data_approved=1;
		}
		db.sql="INSERT INTO #db.table("feature_data", request.zos.zcoreDatasource)#  SET 
		feature_data_sort=#db.param(form.feature_data_sort)#,
		feature_data_created_datetime=#db.param(request.zos.mysqlnow)#, ";
	}else{
		db.sql="UPDATE #db.table("feature_data", request.zos.zcoreDatasource)#  SET ";
	}
	db.sql&=" feature_id=#db.param(form.feature_id)#, 
	 site_id=#db.param(request.zos.globals.id)#, 
	 feature_data_updated_datetime=#db.param(request.zos.mysqlnow)#, 
	 feature_schema_id=#db.param(form.feature_schema_id)#,  
	 feature_data_start_date=#db.param(form.feature_data_start_date)#,
	 feature_data_end_date=#db.param(form.feature_data_end_date)#,
	 feature_data_parent_id=#db.param(form.feature_data_parent_id)#,
	feature_data_override_url=#db.param(application.zcore.functions.zso(form,'feature_data_override_url'))#,
	feature_data_approved=#db.param(form.feature_data_approved)#, 
	feature_data_image_library_id=#db.param(application.zcore.functions.zso(form, 'feature_data_image_library_id'))#, 
	feature_data_title=#db.param(form.siteFieldTitle)# , 
	feature_data_summary=#db.param(form.siteFieldSummary)#,
	feature_data_metatitle=#db.param(application.zcore.functions.zso(form, 'feature_data_metatitle'))#,
	feature_data_metakey=#db.param(application.zcore.functions.zso(form, 'feature_data_metakey'))#,
	feature_data_metadesc=#db.param(application.zcore.functions.zso(form, 'feature_data_metadesc'))#,
	feature_data_deleted=#db.param(0)#, 
	feature_data_field_order=#db.param(arrayToList(arrFieldOrder, chr(13)))#,
	feature_data_data=#db.param(arrayToList(arrFieldData, chr(13)))# "; 
	if(qCheck.feature_schema_enable_merge_interface EQ 1 and (methodBackup EQ "insertSchema" or methodBackup EQ "userInsertSchema" or methodBackup EQ "importInsertSchema")){
		db.sql&=", feature_data_merge_schema_id=#db.param(form.feature_data_merge_schema_id)# ";
	}
	if(hasUserField){
		db.sql&=", feature_data_user=#db.param(userFieldValue)# ";
	}
	if(methodBackup EQ "userInsertSchema" or methodBackup EQ "insertSchema" or 
		methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema" or 
		methodBackup EQ "publicMapInsertSchema" or methodBackup EQ "importInsertSchema"){ 
		// insert
		rs=db.insert("qInsert", request.zOS.insertIDColumnForSiteIDTable);
		if(rs.success EQ false){
			throw("Failed to insert Feature Schema set");
		}
		form.feature_data_id=rs.result;
	}else{
		//update
		db.sql&=" WHERE feature_data_id=#db.param(form.feature_data_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		feature_data_deleted=#db.param(0)#";
		if(db.execute("qUpdate") EQ false){
			throw("Failed to update Feature Schema set");
		}
	}
	structdelete(form, 'feature_data_sort'); 
	arrDataStructKeys=structkeyarray(newDataStruct);
	if(application.zcore.functions.zso(form, 'feature_data_image_library_id') NEQ ""){
        application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'feature_data_image_library_id'));
	}
	application.zcore.routing.updateFeatureSchemaSetUniqueURL(form.feature_data_id);


	featureCacheCom=createobject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	if(form.mergeRecord EQ 1 and form.feature_data_parent_id NEQ "0"){
		db.sql="update #db.table("feature_data", request.zos.zcoreDatasource)# 
		SET 
		feature_data_merge_data_id=#db.param(form.feature_data_id)#
		WHERE 
		feature_data_id=#db.param(form.feature_data_parent_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		feature_data_deleted=#db.param(0)# ";
		db.execute("qUpdate");
		featureCacheCom.updateSchemaSetIdCache(request.zos.globals.id, form.feature_data_parent_id); 
	}
	
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds3<br>'); startTime=gettickcount();
	if(request.zos.enableSiteOptionGroupCache and not structkeyexists(request.zos, 'disableSiteCacheUpdate') and qCheck.feature_schema_enable_cache EQ 1){ 
		featureCacheCom.updateSchemaSetIdCache(request.zos.globals.id, form.feature_data_id); 
	}
	if(qCheck.feature_schema_parent_field NEQ ""){
		// resort all records
		for(row in qCheck){
			mainSchemaStruct=row;
		}
		resortSetByParentField(mainSchemaStruct, form.feature_data_parent_id);
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds4<br>'); startTime=gettickcount();
	if(qCheck.feature_schema_enable_unique_url EQ 1 and qCheck.feature_schema_public_searchable EQ 1){
		if(qCheck.feature_schema_parent_id NEQ 0){
			parentStruct=application.zcore.functions.zGetSiteSchemaById(qCheck.feature_schema_parent_id);
			arrSchemaName=[];
			while(true){
				arrayAppend(arrSchemaName, parentStruct.feature_schema_variable_name);
				if(parentStruct.feature_schema_parent_id NEQ 0){
					parentStruct=application.zcore.functions.zGetSiteSchemaById(parentStruct.feature_schema_parent_id);
				}else{
					break;
				}
			}
			arrayAppend(arrSchemaName, qCheck.feature_schema_display_name);
			application.zcore.featureCom.searchReindexSet(form.feature_id, form.feature_data_id, request.zos.globals.id, arrSchemaName);
		}else{
			application.zcore.featureCom.searchReindexSet(form.feature_id, form.feature_data_id, request.zos.globals.id, [qCheck.feature_schema_display_name]);
		}
	}

	if(qCheck.feature_schema_change_cfc_path NEQ ""){ 
		path=qCheck.feature_schema_change_cfc_path;
		if(left(path, 5) EQ "root."){
			path=request.zRootCFCPath&removeChars(path, 1, 5);
		}
		if(form.feature_data_approved EQ 0){
			changeCom=application.zcore.functions.zcreateObject("component", path); 
			changeCom[qCheck.feature_schema_change_cfc_delete_method](form.feature_data_id);
		}else{
			changeCom=application.zcore.functions.zcreateObject("component", path); 
			arrSchemaName=application.zcore.featureCom.getSchemaNameArrayById(qCheck.feature_id, qCheck.feature_schema_id);
			dataStruct=application.zcore.featureCom.getSchemaSetById(application.zcore.featureCom.getFeatureNameById(qCheck.feature_id), arrSchemaName, form.feature_data_id, request.zos.globals.id, true);
			coreStruct={
				feature_data_sort:dataStruct.__sort,
				// NOT USED YET: feature_data_active:dataStruct.__active,
				feature_schema_id:dataStruct.__groupId,
				feature_data_approved:dataStruct.__approved,
				feature_data_override_url:application.zcore.functions.zso(dataStruct, '__url'),
				feature_data_parent_id:dataStruct.__parentId,
				feature_data_image_library_id:application.zcore.functions.zso(dataStruct, '__image_library_id', true),
				feature_data_id:dataStruct.__setId
			}; 
			changeCom[qCheck.feature_schema_change_cfc_update_method](dataStruct, coreStruct);
		}
	}
 
	
	mapRecord=false;
	if(not structkeyexists(form, 'disableSiteSchemaMap')){
		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo('disableSiteSchemaMap doesn''t exist (not an error) | #qCheck.feature_schema_variable_name# | qCheck.feature_schema_map_insert_type=#qCheck.feature_schema_map_insert_type# | methodBackup = #methodBackup#<br />');
		}
		form.disableSiteSchemaMap=true;
		if(qCheck.feature_schema_map_insert_type EQ 1){
			if(methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema"){
				mapRecord=true;
			}
		}else if(qCheck.feature_schema_map_insert_type EQ 2){
			if((methodBackup EQ "updateSchema" or methodBackup EQ "userUpdateSchema" or methodBackup EQ "internalSchemaUpdate") and form.feature_data_approved EQ 1){
				// only if this record was just approved
				mapRecord=true;
			}
		}
	}else{

		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo('disableSiteSchemaMap exists<br />');
		}
	}
	setIdBackup=form.feature_data_id; 
	disableSendEmail=false;
	setIdBackup2=form.feature_data_id;
	groupIdBackup2=qCheck.feature_schema_id;
	arrEmailStruct=[];
	if((methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicAjaxInsertSchema") and qCheck.feature_schema_lead_routing_enabled EQ 1 and not structkeyexists(form, 'disableSchemaEmail')){
		
		if(qCheck.feature_schema_newsletter_opt_in_form EQ 1){
			form.inquiries_email_opt_in=1;
		}
		newDataStruct.feature_data_id=setIdBackup2; 
		newDataStruct.feature_schema_id=groupIdBackup2;

		if(qCheck.feature_schema_disable_detailed_lead_email EQ 1){
			form.inquiries_disable_detailed_lead_email=1;
		}
		
		if(qCheck.feature_schema_email_cfc_path NEQ "" and qCheck.feature_schema_email_cfc_method NEQ ""){
			if(left(qCheck.feature_schema_email_cfc_path, 5) EQ "root."){
				cfcpath=replace(qCheck.feature_schema_email_cfc_path, 'root.',  request.zRootCfcPath);
			}else{
				cfcpath=qSet.feature_schema_email_cfc_path;
			}
		} 
		if(qCheck.feature_schema_map_fields_type EQ 1){
 
			if(qCheck.feature_schema_email_cfc_path NEQ "" and qCheck.feature_schema_email_cfc_method NEQ ""){ 
				tempCom=application.zcore.functions.zcreateobject("component", cfcpath); 
				emailStruct=tempCom[qCheck.feature_schema_email_cfc_method](newDataStruct, arrDataStructKeys);
				if(qCheck.feature_schema_disable_custom_routing EQ 0){
					arrayAppend(arrEmailStruct, emailStruct);
				}
				if(qCheck.feature_schema_force_send_default_email EQ 1){ 
					// ignore this branch.
				}else{
					disableSendEmail=true;
				}
				 
			}
		}else if(qCheck.feature_schema_map_fields_type EQ 0){
			if(qCheck.feature_schema_email_cfc_path NEQ "" and qCheck.feature_schema_email_cfc_method NEQ ""){
				tempCom=application.zcore.functions.zcreateobject("component", cfcpath);
				emailStruct=tempCom[qCheck.feature_schema_email_cfc_method](newDataStruct, arrDataStructKeys);
				if(qCheck.feature_schema_disable_custom_routing EQ 0){
					arrayAppend(arrEmailStruct, emailStruct);
				}
				if(qCheck.feature_schema_force_send_default_email EQ 1){
					arrayAppend(arrEmailStruct, variables.generateSchemaEmailTemplate(newDataStruct, arrDataStructKeys));
				}else{
					disableSendEmail=true;
				}
			}else{
				arrayAppend(arrEmailStruct, variables.generateSchemaEmailTemplate(newDataStruct, arrDataStructKeys));
				disableSendEmail=true;
			}
		} 
	}
	if(structkeyexists(request.zos, 'debugleadrouting')){
		echo('mapRecord:#mapRecord#<br />');
	}
	if(qCheck.feature_schema_lead_routing_enabled NEQ 1){
		disableSendEmail=true;
	}
	if(mapRecord){
		if(qCheck.feature_schema_map_fields_type EQ 1){ 
			newDataMappedStruct.feature_schema_id =form.feature_schema_id;
			form.inquiries_type_id =qCheck.inquiries_type_id;
			newDataMappedStruct.inquiries_type_id =qCheck.inquiries_type_id;
			if(structkeyexists(request.zos, 'debugleadrouting')){
				echo('mapDataToInquiries<br />');
			}
			form.inquiries_id=mapDataToInquiries(newDataMappedStruct, form, disableSendEmail); 
		}
		setIdBackup2=form.feature_data_id; 
		if(qCheck.feature_schema_delete_on_map EQ 1){
			if(structkeyexists(request.zos, 'debugleadrouting')){
				echo('autoDeleteSchema<br />');
			}
			form.feature_schema_id=qCheck.feature_schema_id;
			form.feature_data_id=setIdBackup;
			tempResult=variables.autoDeleteSchema(); 
		}
	}
	if(disableSendEmail and application.zcore.functions.zso(form, 'disableSchemaEmail', false, false) EQ false){
		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo('site-options|sendEmail<br />');
			writedump(arrEmailStruct);
		}
 
		for(i=1;i<=arraylen(arrEmailStruct);i++){
			emailStruct=arrEmailStruct[i];
			ts=StructNew();
			
			ts.to=request.officeEmail;
			ts.from=request.fromEmail;
			ts.embedImages=true;
			structappend(ts, emailStruct, true);
			if(qCheck.inquiries_type_id NEQ 0){
				leadStruct=application.zcore.functions.zGetLeadRouteForInquiriesTypeId(ts.from, qCheck.inquiries_type_id, qCheck.inquiries_type_id_siteIDType);
				//writedump(leadStruct);
				if(structkeyexists(leadStruct, 'bcc')){
					ts.bcc=leadStruct.bcc;
				}
				if(leadStruct.user_id NEQ "0"){
					ts.user_id=leadStruct.user_id;
					ts.user_id_siteIDType=leadStruct.user_id_siteIDType;
				}
				if(leadStruct.assignEmail NEQ ""){
					ts.to=leadStruct.assignEmail;
				}
			} 
			ts.site_id=request.zos.globals.id; 
			if(structkeyexists(request.zos, 'debugleadrouting')){
				ts.preview=true;
			}
			rCom=application.zcore.email.send(ts);
			if(structkeyexists(request.zos, 'debugleadrouting')){
				writedump(ts);
				writedump(rCom.getData());
			}
			if(rCom.isOK() EQ false){
				rCom.setStatusErrors(request.zsid);
				application.zcore.functions.zstatushandler(request.zsid);
				application.zcore.functions.zabort();
			}
		}
	}
	if(structkeyexists(request.zos, 'debugleadrouting')){
		echo("Aborted before returning from Feature Schema processing.");
		abort;
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds5<br>'); startTime=gettickcount();
	if(debug) application.zcore.functions.zabort();

	urlformtoken="";
	formtoken="";
	if(qCheck.feature_schema_public_thankyou_token NEQ ""){
		formtoken=setIdBackup&"-"&application.zcore.functions.zso(form, 'inquiries_id');
		request.zsession[qCheck.feature_schema_public_thankyou_token]=formtoken;
		urlformtoken="&"&qCheck.feature_schema_public_thankyou_token&"="&formtoken;
	}

	if(methodBackup EQ "userUpdateSchema" or methodBackup EQ "userInsertSchema"){
		if(qCheck.feature_schema_change_email_usergrouplist NEQ ""){
			newAction='created';
			if(methodBackup CONTAINS 'update'){
				newAction='updated';
			}else if(methodBackup CONTAINS 'import'){
				newAction='imported';
			}
			application.zcore.featureCom.sendChangeEmail(setIdBackup, newAction);
		}
	}
	request.zsession.zLastSiteXSchemaSetId=setIdBackup;
	request.zsession.zLastInquiriesID=application.zcore.functions.zso(form, 'inquiries_id');
	if(qCheck.feature_schema_enable_merge_interface EQ 1){
		if(methodBackup EQ "insertSchema" or methodBackup EQ "userInsertSchema"){
			// redirect to adding the child group
			if(methodBackup EQ "userInsertSchema"){
				newMethod="userAddSchema";
			}else{
				newMethod="addSchema";
			}
			link='/z/feature/admin/features/#newMethod#?feature_id=#form.feature_id#&feature_schema_id=#form.feature_data_merge_schema_id#&feature_data_parent_id=#setIdBackup#&mergeRecord=1&modalpopforced=1'; 
			application.zcore.functions.zReturnJson({success:true, id:setIdBackup, redirectFrame:true, redirectLink:link, newRecord:true});
		}
	}
	if(methodBackup EQ "publicMapInsertSchema" or methodBackup EQ "publicAjaxInsertSchema" or methodBackup EQ "internalSchemaUpdate" or methodBackup EQ "importInsertSchema"){
		ts={success:true, zsid:request.zsid, feature_data_id:setIdBackup, formtoken:formtoken, inquiries_id: application.zcore.functions.zso(form, 'inquiries_id')};
		return ts;
	}else if(methodBackup EQ "publicInsertSchema" or methodBackup EQ "publicUpdateSchema"){ 
		form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced');
		application.zcore.status.setStatus(request.zsid,"Saved successfully.");
		if(structkeyexists(arguments.struct, 'successURL')){
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.successURL, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#&feature_data_id=#setIdBackup#&inquiries_id=#application.zcore.functions.zso(form,'inquiries_id')#"&urlformtoken));
		}else{
			if(qCheck.feature_schema_public_thankyou_url NEQ ""){
				application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(qCheck.feature_schema_public_thankyou_url, "zsid=#request.zsid#&modalpopforced=#form.modalpopforced#&feature_data_id=#setIdBackup#&inquiries_id=#application.zcore.functions.zso(form,'inquiries_id')#"&urlformtoken));
			}else{
				application.zcore.functions.zRedirect("/z/misc/thank-you/index?modalpopforced=#form.modalpopforced#&feature_data_id=#setIdBackup#&inquiries_id=#application.zcore.functions.zso(form,'inquiries_id')#"&urlformtoken);
			}
		}
	}else if(form.modalpopforced EQ 1 and (methodBackup EQ "updateSchema" or methodBackup EQ "userUpdateSchema" or methodBackup EQ "insertSchema" or methodBackup EQ "userInsertSchema")){
		newAction="getRowHTML";
		if(methodBackup EQ "insertSchema" or methodBackup EQ "userInsertSchema"){
			newRecord=true;
		}else{
			newRecord=false;
		}
		form.feature_data_id=setIdBackup;
		if(qCheck.feature_schema_parent_field NEQ ""){
			if(methodBackup EQ "userUpdateSchema"){ 
				form.method="userGetTableHTML";
				tableHTML=userGetTableHTML();
			}else{
				form.method="getTableHTML";
				tableHTML=getTableHTML();
			}
			application.zcore.functions.zReturnJson({success:true, id:setIdBackup, tableHTML:tableHTML, newRecord:newRecord});

		}

		// need to get the schema_id from the feature_data_parent_id instead
		db.sql="select * from 
		#db.table("feature_schema", request.zos.zcoreDatasource)#, 
		#db.table("feature_data", request.zos.zcoreDatasource)# 
		WHERE 
		feature_data_id=#db.param(form.feature_data_parent_id)# and 
		feature_data.site_id=#db.param(request.zos.globals.id)# and 
		feature_data_deleted = #db.param(0)# and 
		feature_schema.feature_schema_id=feature_data.feature_schema_id and 
		feature_data.feature_data_id=#db.param(form.feature_data_parent_id)# and 
		feature_schema_deleted = #db.param(0)# and
		feature_data.feature_id=#db.param(form.feature_id)# ";
		qCheckParent=db.execute("qCheckParent", "", 10000, "query", false); 
		if(qCheckParent.feature_schema_enable_merge_interface EQ 1){
			form.feature_schema_id=qCheckParent.feature_schema_id;
			form.feature_data_id=qCheckParent.feature_data_id;
			form.feature_data_parent_id=qCheckParent.feature_data_parent_id;
			if(methodBackup EQ "userUpdateSchema" or methodBackup EQ "userInsertSchema"){ 
				form.method="userGetTableHTML";
				tableHTML=userGetTableHTML();
			}else{
				form.method="getTableHTML";
				tableHTML=getTableHTML();
			}
			application.zcore.functions.zReturnJson({success:true, id:setIdBackup, tableHTML:tableHTML, newRecord:newRecord});

		}
		if(methodBackup EQ "userUpdateSchema" or methodBackup EQ "userInsertSchema"){ 
			form.method="userGetRowHTML";
			rowHTML=userGetRowHTML();
		}else{
			form.method="getRowHTML";
			rowHTML=getRowHTML();
		}

		application.zcore.functions.zReturnJson({success:true, id:setIdBackup, rowHTML:rowHTML, newRecord:newRecord});
 
	}else{


		if(form.modalpopforced NEQ 1 and structkeyexists(request.zsession, 'siteSchemaReturnURL') and request.zsession.siteSchemaReturnURL NEQ ""){
			tempLink=request.zsession.siteSchemaReturnURL;
			structdelete(request.zsession, 'siteSchemaReturnURL');
			tempLink=replace(tempLink, "zsid=", "ztv=", "all");
			//application.zcore.functions.zRedirect(replace(tempLink, "zsid=", "ztv=", "all"));
		}else{
			application.zcore.status.setStatus(request.zsid,"Saved successfully.");
			tempLink=defaultStruct.listURL&"?zsid=#request.zsid#&feature_schema_id=#form.feature_schema_id#&feature_data_parent_id=#form.feature_data_parent_id#&modalpopforced=#form.modalpopforced#";
			//application.zcore.functions.zRedirect(defaultStruct.listURL&"?zsid=#request.zsid#&feature_schema_id=#form.feature_schema_id#&feature_data_parent_id=#form.feature_data_parent_id#&modalpopforced=#form.modalpopforced#");
		}
		application.zcore.functions.zReturnJson({success:true, redirect:1, redirectLink: tempLink});
	}
	</cfscript>
</cffunction>


<cffunction name="resortSetByParentField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="feature_data_parent_id" type="string" required="yes">
	<cfscript>
	featureCacheCom=createobject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	featureCacheCom.resortSchemaSets(request.zos.globals.id, arguments.row.feature_id, arguments.row.feature_schema_id, arguments.feature_data_parent_id);
	</cfscript>
</cffunction>
<!--- 
Define this function in another CFC to override the default email format
<cffunction name="publicEmailExample" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="arrKey" type="array" required="yes">
	<cfscript>
	var rs={
		html:"",
		text:"",
		subject:""
	};
	rs.html='#application.zcore.functions.zHTMLDoctype()#
	<head>
	<meta charset="utf-8" />
	<title>Email</title>
	</head>
	
	<body>
	<p>Testing email</p>
	<p>'&application.zcore.functions.zso(ss, 'title')&'</p>
	</body>
	</html>';
	rs.subject="Test subject";
	rs.text="Testing email";
	return rs;
	</cfscript>
</cffunction>
 --->
 
 
<!--- variables.mapDataToInquiries(form); --->
<cffunction name="mapDataToInquiries" localmode="modern" access="public">
	<cfargument name="newDataMappedStruct" type="struct" required="yes">
	<cfargument name="sourceStruct" type="struct" required="yes">
	<cfargument name="disableEmail" type="boolean" required="no" default="#false#">
	<cfscript>
	var ts=arguments.newDataMappedStruct;
	var rs=0;
	var row=0;
	var db=request.zos.queryObject; 
	form.inquiries_spam=application.zcore.functions.zso(form, 'inquiries_spam', false, 0);
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id = #db.param(ts.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# "; 
	qSchema=db.execute("qSchema"); 
	db.sql="select feature_map.*, s2.feature_field_display_name, s2.feature_field_variable_name originalFieldName from 
	#db.table("feature_map", request.zos.zcoreDatasource)# feature_map,  
	#db.table("feature_field", request.zos.zcoreDatasource)# s2
	WHERE feature_map.feature_schema_id = #db.param(ts.feature_schema_id)# and 
	feature_map_deleted = #db.param(0)# and 
	s2.feature_field_deleted = #db.param(0)# and
	feature_map.feature_id=#db.param(form.feature_id)# and  
	feature_map.feature_field_id = s2.feature_field_id and 
	feature_map.feature_schema_id =s2.feature_schema_id 
	ORDER BY s2.feature_field_sort asc";
	qMap=db.execute("qMap", "", 10000, "query", false);
	 
	if(qMap.recordcount EQ 0){
		throw('feature_schema_id, "#ts.feature_schema_id#", on site_id, "#request.zos.globals.id#" isn''t mapped 
		yet so the data can''t be stored in inquiries table or emailed. 
		The form data below must be manually forwarded to the web site owner or resubmitted.');
		return;
	} 


	form.emailLabelStruct={};
	countStruct=structnew();
	for(row in qMap){
		if(row.feature_map_fieldname NEQ ""){
			if(not structkeyexists(countStruct, row.feature_map_fieldname)){
				countStruct[row.feature_map_fieldname]=1;
			}else{
				countStruct[row.feature_map_fieldname]++;
			}
		}
	} 
	var jsonStruct={ arrCustom: [] };
	// this doesn't support all fields yet, I'd have to use getListValue on all the rows instead - or does it?
	for(row in qMap){ 
		if(row.feature_map_fieldname NEQ ""){
			if(structkeyexists(ts, row.originalFieldName)){
				if(row.feature_map_fieldname EQ "inquiries_custom_json"){
					arrayAppend(jsonStruct.arrCustom, { label: row.feature_field_display_name, value: ts[row.originalFieldName] });
				}else{
					tempString="";
					if(structkeyexists(form, row.feature_map_fieldname)){
						tempString=form[row.feature_map_fieldname];
					}
					if(countStruct[row.feature_map_fieldname] GT 1){
						//if(request.zos.isdeveloper){ writeoutput('shared:'&row.originalFieldName&'<br />'); }
						form[row.feature_map_fieldname]=tempString&row.originalFieldName&": "&ts[row.originalFieldName]&" "&chr(10); 
					}else{
						//if(request.zos.isdeveloper){ writeoutput(' not shared:'&row.originalFieldName&'<br />'); }
						form[row.feature_map_fieldname]=ts[row.originalFieldName]; 
					}
				}
			} 
		}
	} 
	if(structcount(jsonStruct)){
		form.inquiries_custom_json=serializejson(jsonStruct);
	}
	/*
	if(request.zos.isdeveloper){
		writedump(arguments.sourceStruct);
		writedump(ts);
		writedump(qMap);
		writedump(countStruct);
		writedump(form);
		abort;
	}*/
	form.inquiries_session_id=application.zcore.session.getSessionId(); 
	form.inquiries_type_id=qSchema.inquiries_type_id;
	form.inquiries_type_id_siteIDType=qSchema.inquiries_type_id_siteIDType; 

	if(application.zcore.functions.zso(form, 'zRefererURL') NEQ ""){
		if(left(form.zRefererURL, 1) EQ "/"){
			form.zRefererURL=request.zos.globals.domain&form.zRefererURL;
		}
		form.inquiries_referer=form.zRefererURL;
	}
	if(form.inquiries_type_id EQ 0 or form.inquiries_type_id EQ ""){
		form.inquiries_type_id=1;
		form.inquiries_type_id_siteIDType=4;
	}
	form.inquiries_datetime=request.zos.mysqlnow;
	form.inquiries_status_id = 1;
	form.site_id = request.zOS.globals.id; 
	if(application.zcore.functions.zso(form, 'inquiries_email') NEQ ""){ 
		application.zcore.tracking.setUserEmail(form.inquiries_email);
	}  
	form.inquiries_id=application.zcore.functions.zInsertLead();
	
	application.zcore.tracking.setConversion('inquiry',form.inquiries_id);
	tempStruct=form;
	application.zcore.functions.zUserMapFormFields(tempStruct);
	if(application.zcore.functions.zso(form, 'inquiries_email') NEQ "" and application.zcore.functions.zEmailValidate(form.inquiries_email)){
		form.contact_id=application.zcore.user.automaticAddUser(form);
	}
	// form.inquiries_spam EQ 0 and 
	 if(not arguments.disableEmail and application.zcore.functions.zso(form, 'disableSchemaEmail', false, false) EQ false){
		ts=structnew();
		ts.inquiries_id=form.inquiries_id;
		if(qSchema.feature_schema_public_form_title EQ ""){
			tempTitle="Lead capture";
		}else{
			tempTitle=qSchema.feature_schema_public_form_title;
		}
		ts.subject="#tempTitle# form submitted on #request.zos.currentHostName#";
		// send the lead

		if(structkeyexists(request.zos, 'debugleadrouting')){
			echo('zAssignAndEmailLead<br />');
		}
		ts.disableDebugAbort=true;
		ts.arrAttachments=request.zos.arrForceEmailAttachment; 
		rs=application.zcore.functions.zAssignAndEmailLead(ts);
		
		if(rs.success EQ false){
			// failed to assign/email lead
			//zdump(rs);
		}
	 }
	return form.inquiries_id;
	</cfscript>
</cffunction>

	
<cffunction name="generateSchemaEmailTemplate" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="arrKey" type="array" required="yes">
	<!--- <cfargument name="feature_schema_id" type="struct" required="yes">
	<cfargument name="subject" type="struct" required="yes"> --->
	<cfscript>
	var ts=arguments.ss;
	var i=0;
	var db=request.zos.queryObject;
	var rs={
		subject:"",
		html:"",
		text:""
	};
	arraySort(arguments.arrKey, "text", "asc");
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id = #db.param(ts.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qD=db.execute("qD");
	rs.subject='New '&qd.feature_schema_display_name&' submitted on '&request.zos.globals.shortDomain;
	editLink=request.zos.currentHostName&"/z/feature/admin/features/editSchema?feature_schema_id=#ts.feature_schema_id#&feature_data_id=#ts.feature_data_id#";
	savecontent variable="output"{
		writeoutput('New '&qd.feature_schema_display_name&' submitted'&chr(10)&chr(10));
		for(i=1;i LTE arraylen(arguments.arrKey);i++){
			if(arguments.arrKey[i] NEQ "feature_schema_id" and arguments.arrKey[i] NEQ "feature_data_id"){
				writeoutput(arguments.arrKey[i]&': '&ts[arguments.arrKey[i]]&chr(10));
			}
		}
		writeoutput(chr(10)&chr(10)&'Edit in Site Manager'&chr(10)&editLink);
	}
	rs.text=output;
	savecontent variable="output"{
		writeoutput('#application.zcore.functions.zHTMLDoctype()#
		<head>
		<meta charset="utf-8" />
		<title>'&rs.subject&'</title>
		</head>
		
		<body>
		<p>New '&htmleditformat(qd.feature_schema_display_name)&' submitted on '&request.zos.globals.shortDomain&'</p>
		<table style="border-spacing:0px;">');
		for(i=1;i LTE arraylen(arguments.arrKey);i++){
			if(arguments.arrKey[i] NEQ "feature_schema_id" and arguments.arrKey[i] NEQ "feature_data_id"){
				writeoutput('<tr><td style="padding:5px; border-bottom:1px solid ##CCC;">'&htmleditformat(arguments.arrKey[i])&':</td><td style="padding:5px; border-bottom:1px solid ##CCC;">'&htmleditformat(ts[arguments.arrKey[i]])&'</td></tr>');
			}
		}
		approved=application.zcore.functions.zso(form, 'feature_data_approved');
		if(approved EQ 0){
			echo('<tr><td style="padding:5px; border-bottom:1px solid ##CCC;">Approved?</td><td style="padding:5px; border-bottom:1px solid ##CCC;">Pending</td></tr>');
		}else if(approved EQ 2){
			echo('<tr><td style="padding:5px; border-bottom:1px solid ##CCC;">Approved?</td><td style="padding:5px; border-bottom:1px solid ##CCC;">Deactivated By User</td></tr>');
		}else if(approved EQ 4){
			echo('<tr><td style="padding:5px; border-bottom:1px solid ##CCC;">Approved?</td><td style="padding:5px; border-bottom:1px solid ##CCC;">Rejected</td></tr>');
		}else if(approved EQ 1){
			echo('<tr><td style="padding:5px; border-bottom:1px solid ##CCC;">Approved?</td><td style="padding:5px; border-bottom:1px solid ##CCC;">Approved</td></tr>');
		}
		writeoutput('</table>
		<br /><p><a href="#htmleditformat(editLink)#">Edit in Site Manager</a></p>
		</body>
		</html>');
	}
	rs.html=output;
	return rs;
	</cfscript>
</cffunction>



	 
<cffunction name="publicManageSchema" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	this.manageSchema(arguments.struct);
	</cfscript>
</cffunction>


<cffunction name="userGetRowHTML" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	validateUserSchemaAccess();
	return this.manageSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="getRowHTML" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	return this.manageSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="getTableHTMLJSON" localmode="modern" access="remote">
	<cfscript>
	form.method="getTableHTML";
	application.zcore.functions.zReturnJson({success:true, id:0, tableHTML:this.manageSchema({}), newRecord:false});
	abort;
	</cfscript>
</cffunction>

<cffunction name="userGetTableHTML" localmode="modern" access="remote">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	validateUserSchemaAccess();
	return this.manageSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="getTableHTML" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	return this.manageSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="validateUserSchemaAccess" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id');
	currentSetId=application.zcore.functions.zso(form, 'feature_data_id', true);
	currentParentId=application.zcore.functions.zso(form, 'feature_data_parent_id', true);
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# WHERE 
	feature_schema_deleted=#db.param(0)# and 
	feature_id=#db.param(form.feature_id)# and 
	feature_schema_id=#db.param(form.feature_schema_id)# ";
	qCheckSchema=db.execute("qCheckSchema");
	if(qCheckSchema.recordcount EQ 0){
		application.zcore.functions.z404("Invalid feature_schema_id");
	}
	if(not application.zcore.user.checkGroupAccess("user")){
		application.zcore.functions.z301redirect("/z/user/preference/index");
	}
	// only need to validate the topmost parent record.  the children should NOT be validated.
	// i should remove the options from groups that are not parent_id = 0 in edit group
	request.isUserPrimarySchema=true;
	if(currentParentId NEQ 0 and currentSetId EQ 0){
		request.isUserPrimarySchema=false;
		currentSetId=currentParentId;
	}
	qCheckSet={recordcount:0};
	if(currentSetId NEQ 0){ 
		first=true;
		i=0;
		while(true){
			if(not first){ 
				request.isUserPrimarySchema=false;
			} 
			first=false;
			db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# WHERE 
			site_id=#db.param(request.zos.globals.id)# and 
			feature_data_deleted=#db.param(0)# and 
			feature_id=#db.param(form.feature_id)# and 
			feature_data_id=#db.param(currentSetId)# ";
			qCheckSet=db.execute("qCheckSet");
			if(qCheckSet.recordcount EQ 0){
				application.zcore.functions.z404("Invalid record.  set id doesn't exist: #currentSetId#");
			}
			if(qCheckSet.feature_data_parent_id EQ 0){
				currentSetId=qCheckSet.feature_data_id;
				break;
			}else{
				currentSetId=qCheckSet.feature_data_parent_id;
			}
			i++;
			if(i > 255){
				throw("infinite loop");
			}
		} 
		if(currentSetId NEQ 0){
			if(qCheckSet.recordcount NEQ 0){
				db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# WHERE 
				feature_schema_deleted=#db.param(0)# and 
				feature_id=#db.param(form.feature_id)# and 
				feature_schema_id=#db.param(qCheckSet.feature_schema_id)# ";
				qCheckSchema=db.execute("qCheckSchema");
			}
			if(qCheckSchema.feature_schema_user_id_field EQ ""){
				application.zcore.functions.z404("This feature_schema requires feature_schema_user_id_field to be defined to enable user dashboard editing: #qCheckSchema.feature_schema_variable_name#");
			} 
	 
			db.sql="select * from #db.table("feature_field", request.zos.zcoreDatasource)# feature_field 
			where feature_schema_id = #db.param(qCheckSet.feature_schema_id)# and 
			feature_field_deleted = #db.param(0)# and
			feature_id =#db.param(form.feature_id)# and 
			feature_field_variable_name=#db.param(qCheckSchema.feature_schema_user_id_field)#";
			qField=db.execute("qField");
			if(qField.recordcount EQ 0){
				application.zcore.functions.z404("This feature_schema has an invalid feature_schema_user_id_field that doesn't exist: #qCheckSchema.feature_schema_user_id_field#");
			}
			db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# WHERE 
			site_id=#db.param(request.zos.globals.id)# and 
			feature_field_id=#db.param(qField.feature_field_id)# and 
			feature_data_deleted=#db.param(0)# and 
			feature_id=#db.param(form.feature_id)# and 
			feature_data_id=#db.param(currentSetId)# and 
			feature_schema_id=#db.param(qCheckSet.feature_schema_id)# ";
			qCheckValue=db.execute("qCheckValue");  
			if(qCheckValue.recordcount NEQ 0){
				siteIdType=application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id); 
				if(request.zsession.user.id&"|"&siteIdType NEQ qCheckValue.feature_data_value){
					application.zcore.functions.z404("This user doesn't have access to this set record");
				}
			}else{
				application.zcore.functions.z404("User doesn't have access to this set record");
			}
		}
	} 
	if(qCheckSchema.feature_schema_user_group_id_list EQ ""){
		application.zcore.functions.z404("This feature_schema doesn't allow user dashboard editing: #qCheckSchema.feature_schema_variable_name# (feature_schema_user_group_id_list is blank)");
	}
	arrId=listToArray(qCheckSchema.feature_schema_user_group_id_list); 
	for(i=1;i<=arraylen(arrId);i++){
		if(application.zcore.user.checkSchemaIdAccess(arrId[i])){ 
			return;
		}
	} 
	application.zcore.functions.z404("User doesn't have access to this feature_schema: #qCheckSchema.feature_schema_variable_name#");
	</cfscript>
</cffunction>


<cffunction name="userManageSchema" localmode="modern" access="remote"> 
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript> 
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	echo('<p><a href="/z/user/home/index">Back to User Dashboard</a></p>');
	validateUserSchemaAccess();
	manageSchema(arguments.struct);
	</cfscript>
</cffunction>
		

<cffunction name="manageSchema" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject;
	var queueSortStruct = StructNew(); 
	var arrLabel=arraynew(1);
	var arrVal=arraynew(1);
	var arrType=arraynew(1);
	var arrRow=arraynew(1);

	fakeRow={};
	fakePrimaryId=0;	
	fakePrimaryLabel="";	
	fakePrimaryType="";	
	var arrDisplay=[];
	var arrFieldStruct=[]; 
	var fakeRow={}; 
	methodBackup=form.method;
	if(methodBackup EQ "userManageSchema"){
		application.zcore.skin.includeCSS("/z/font-awesome/css/font-awesome.min.css");
	}
	request.isUserPrimarySchema=application.zcore.functions.zso(request, 'isUserPrimarySchema', false, false);
	savecontent variable="out"{
		defaultStruct=getDefaultStruct();
		structappend(arguments.struct, defaultStruct, false);
		if(not structkeyexists(arguments.struct, 'recurse')){
			variables.init(); 
		}
		
		
		form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
		if(not structkeyexists(request, 'manageSchemaStatusHandlerOutput')){
			application.zcore.functions.zstatusHandler(request.zsid);
			request.manageSchemaStatusHandlerOutput=true;
		}
		form.enableSorting=application.zcore.functions.zso(form, 'enableSorting', true, 0);

		if ( structKeyExists( form, 'searchOn' ) ) {
			form.enableSorting = 0;
			form.disableSorting = 1;
		}
		if(not structkeyexists(application.zcore.featureData.featureSchemaData, form.feature_id)){
			application.zcore.functions.z404("Invalid feature_id, ""#form.feature_id#""");
		}
		sog=application.zcore.featureData.featureSchemaData[form.feature_id];

		form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id',true);
		form.feature_data_parent_id=application.zcore.functions.zso(form, 'feature_data_parent_id',true);
		mainSchemaStruct=application.zcore.functions.zso(sog.featureSchemaLookup, form.feature_schema_id, false, {});
		if(structcount(mainSchemaStruct) EQ 0){
			application.zcore.functions.zredirect("/z/feature/admin/features/index");
		} 
		// db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema WHERE 
		// feature_schema_id = #db.param(form.feature_schema_id)# and 
		// feature_schema_deleted = #db.param(0)# and
		// site_id =#db.trustedsql(request.zos.globals.id)# ";
		// qSchema=db.execute("qSchema"); 
		
		// if(mainSchemaStruct.recordcount EQ 0){
		// 	application.zcore.functions.zredirect("/z/feature/admin/features/index");
		// }

		if(mainSchemaStruct.feature_schema_enable_archiving EQ 1){
			form.showArchived=application.zcore.functions.zso(form, 'showArchived');
			if(form.showArchived EQ "1"){
				request.zsession['siteSchemaShowArchived#mainSchemaStruct.feature_schema_id#']=true;
			}else if(form.showArchived EQ "0"){
				structdelete(request.zsession, 'siteSchemaShowArchived#mainSchemaStruct.feature_schema_id#');
			}
		}
		showArchived=false;
		if(structkeyexists(request.zsession, 'siteSchemaShowArchived#mainSchemaStruct.feature_schema_id#')){
			showArchived=true;
		}
		if(methodBackup EQ "userManageSchema"){ 
			arrUserSchema=listToArray(mainSchemaStruct.feature_schema_user_group_id_list, ",");
			hasAccess=false;
			for(i=1;i LTE arraylen(arrUserSchema);i++){
				if(application.zcore.user.checkSchemaIdAccess(arrUserSchema[i])){
					hasAccess=true;
					break;
				}
			}
			if(not hasAccess){
				application.zcore.functions.z404("feature_schema_id, #form.feature_schema_id#, doesn't allow public data entry.");
			} 
		}


		// these are groups that children of mainSchemaStruct
		// we also get the count of those children's set records
		arrChildSchema=[];
		for(groupId in sog.featureSchemaLookup){
			group=sog.featureSchemaLookup[groupId];
			if(group.feature_schema_parent_id EQ form.feature_schema_id){
				arrayAppend(arrChildSchema, group);
			}
		}
		// db.sql="select * 
		// from #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema  
		// where 
		// feature_schema_deleted = #db.param(0)# and
		// feature_schema.feature_schema_parent_id = #db.param(form.feature_schema_id)# and 
		// feature_schema.feature_id=#db.param(form.feature_id)# 
		// GROUP BY feature_schema.feature_schema_id
		// ORDER BY feature_schema.feature_schema_display_name";
		// q1=db.execute("q1");
		// this childCount wasn't used anymore
		// db.sql="select *, count(s3.feature_schema_id) childCount 
		// from #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
		// left join #db.table("feature_data", request.zos.zcoreDatasource)# s3 ON 
		// feature_schema.feature_schema_id = s3.feature_schema_id and 
		// s3.feature_data_master_set_id = #db.param(0)# and 
		// s3.feature_data_deleted = #db.param(0)# ";
		// if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
		// 	db.sql&=" and feature_data_id = #db.param(form.feature_data_id)# ";
		// }
		// db.sql&=" where 
		// feature_schema_deleted = #db.param(0)# and
		// feature_schema.feature_schema_parent_id = #db.param(form.feature_schema_id)# and 
		// feature_schema.feature_id=#db.param(form.feature_id)# 
		// GROUP BY feature_schema.feature_schema_id
		// ORDER BY feature_schema.feature_schema_display_name";
		// q1=db.execute("q1");


		sortEnabled=true;
		subgroupRecurseEnabled=false;
		subgroupStruct={}; 
		for(n in arrChildSchema){
			if(methodBackup EQ "userManageSchema"){ 
				arrUserSchema=listToArray(n.feature_schema_user_group_id_list, ",");
				hasAccess=false;
				for(i=1;i LTE arraylen(arrUserSchema);i++){
					if(application.zcore.user.checkSchemaIdAccess(arrUserSchema[i])){
						hasAccess=true;
						break;
					}
				}
				if(hasAccess){
					subgroupStruct[n.feature_schema_id]=true;
				}
			}else{
				subgroupStruct[n.feature_schema_id]=true;
			}
		}
		if(form.enableSorting EQ 0){
			for(n in arrChildSchema){
				if(n.feature_schema_enable_list_recurse EQ "1"){
					sortEnabled=false;
					subgroupRecurseEnabled=true;
					break;
				}
			}
		}

		tempSchemaKey="#form.feature_id#-#form.feature_schema_id#";
		if(methodBackup NEQ "getRowHTML" and methodBackup NEQ "userGetRowHTML"){
			if(structkeyexists(request.zsession, 'siteSchemaSearch') and structkeyexists(request.zsession.siteSchemaSearch, tempSchemaKey)){
				if(structkeyexists(form, 'clearSearch')){
					structdelete(request.zsession.siteSchemaSearch, tempSchemaKey);
				}else if(not structkeyexists(form, 'searchOn')){
					form.searchOn=1;
					structappend(form, request.zsession.siteSchemaSearch[tempSchemaKey], false);
				}
			}
		}
		if(application.zcore.functions.zso(form, 'disableSorting', true, 0) EQ 1){
			sortEnabled=false;
			subgroupRecurseEnabled=false;
		}
		if(structkeyexists(arguments.struct, 'recurse') or mainSchemaStruct.feature_schema_enable_sorting EQ 0){
			sortEnabled=false;
		}
		if(methodBackup EQ "userManageSchema"){
			currentUserIdValue=request.zsession.user.id&"|"&application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
		}
		if(sortEnabled){
			queueSortStruct.tableName = "feature_data";
			queueSortStruct.sortFieldName = "feature_data_sort";
			queueSortStruct.primaryKeyName = "feature_data_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			queueSortStruct.ajaxTableId='sortRowTable';
			queueSortStruct.ajaxCallback="function(){ zReloadFeatureTableHTML(); }";
			queueSortStruct.ajaxURL=application.zcore.functions.zURLAppend(arguments.struct.listURL, "feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&feature_data_parent_id=#form.feature_data_parent_id#&modalpopforced=#application.zcore.functions.zso(form, 'modalpopforced')#&enableSorting=1");
			
			queueSortStruct.where =" feature_data.feature_id = '#application.zcore.functions.zescape(form.feature_id)#' and  
			feature_schema_id = '#application.zcore.functions.zescape(form.feature_schema_id)#' and 
			feature_data_parent_id='#application.zcore.functions.zescape(form.feature_data_parent_id)#' and 
			site_id = '#request.zos.globals.id#' and 
			feature_data_master_set_id = '0' and 
			feature_data_deleted='0' ";
			if(methodBackup EQ "userManageSchema" and request.isUserPrimarySchema){
				queueSortStruct.where &=" and feature_data_user = '#application.zcore.functions.zescape(currentUserIdValue)#'";
			}
			
			queueSortStruct.disableRedirect=true;
			queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
			featureCacheCom=createobject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
			r1=queueSortCom.init(queueSortStruct);
			if(structkeyexists(form, 'zQueueSort')){
				// update cache
				if(request.zos.enableSiteOptionGroupCache and mainSchemaStruct.feature_schema_enable_cache EQ 1){
					featureCacheCom.updateSchemaSetIdCache(request.zos.globals.id, form.feature_data_id); 
				}
				// redirect with zqueuesort renamed
				application.zcore.functions.zredirect(request.cgi_script_name&"?"&replacenocase(request.zos.cgi.query_string,"zQueueSort=","ztv=","all"));
			}
			if(structkeyexists(form, 'zQueueSortAjax')){
				if(mainSchemaStruct.feature_schema_parent_field NEQ ""){
					// resort all records
					resortSetByParentField(mainSchemaStruct, form.feature_data_parent_id);
					// possibly return different json here that reloads table, and not entire page
				}else{

					// update cache 
					if(request.zos.enableSiteOptionGroupCache and mainSchemaStruct.feature_schema_enable_cache EQ 1){
						featureCacheCom.resortSchemaSets(request.zos.globals.id, form.feature_id, form.feature_schema_id, form.feature_data_parent_id); 
					}else{

						t9=application.zcore.featureData;
						var groupStruct=t9.featureSchemaLookup[form.feature_schema_id];
	 

						if(groupStruct.feature_schema_change_cfc_path NEQ ""){
							path=groupStruct.feature_schema_change_cfc_path;
							if(left(path, 5) EQ "root."){
								path=request.zRootCFCPath&removeChars(path, 1, 5);
							}
							changeCom=application.zcore.functions.zcreateObject("component", path); 
							offset=0;
							while(true){
								db.sql="select feature_data_id FROM #db.table("feature_data", request.zos.zcoreDatasource)# 
								WHERE 
								site_id=#db.param(request.zos.globals.id)# and 
								feature_data.feature_id = #db.param(form.feature_id)# and  
								feature_schema_id = #db.param(form.feature_schema_id)# and 
								feature_data_parent_id=#db.param(form.feature_data_parent_id)# and 
								feature_id=#db.param(form.feature_id)# and 
								feature_data_master_set_id = #db.param(0)# and 
								feature_data_deleted=#db.param(0)# ";
								if(methodBackup EQ "userManageSchema" and request.isUserPrimarySchema){
									db.sql&=" and feature_data_user = '#application.zcore.functions.zescape(currentUserIdValue)#'";
								}
								db.sql&=" ORDER BY feature_data_sort ASC 
								LIMIT #db.param(offset)#, #db.param(20)#";
								qSorted=db.execute("qSorted");
								if(qSorted.recordcount EQ 0){
									break;
								}
								for(row in qSorted){
									offset++;
									changeCom[groupStruct.feature_schema_change_cfc_sort_method](row.feature_data_id, offset); 
								}
							}
						}
					}
				}
				queueSortCom.returnJson();
			}
		}
		// if(form.feature_schema_id NEQ 0){
		// 	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
		// 	where feature_schema_id = #db.param(form.feature_schema_id)# and 
		// 	feature_schema_deleted = #db.param(0)# and
		// 	feature_id=#db.param(form.feature_id)# 
		// 	ORDER BY feature_schema_display_name";
		// 	q12=db.execute("q12");
		// 	if(q12.recordcount EQ 0){
		// 		application.zcore.functions.z301redirect("/z/feature/admin/features/index");	
		// 	}
		// }
		// db.sql="select * from #db.table("feature_field", request.zos.zcoreDatasource)# feature_field 
		// where feature_schema_id = #db.param(form.feature_schema_id)# and 
		// feature_field_deleted = #db.param(0)# and
		// feature_id =#db.param(form.feature_id)# 
		// ORDER BY feature_field_sort";
		// qS2=db.execute("qS2");
		arrMainField=[];
		mainFieldStruct={};
		if(not structkeyexists(sog.featureSchemaFieldLookup, form.feature_schema_id)){
			echo("This schema has no fields yet.");
			abort;
		}
		for(optionId in sog.featureSchemaFieldLookup[form.feature_schema_id]){
			mainFieldStruct[optionId]={ sort: sog.fieldLookup[optionId].feature_field_sort, row: sog.fieldLookup[optionId]};
		}
		arrKey=structsort(mainFieldStruct, "numeric", "asc", "sort");
		for(i=1;i<=arrayLen(arrKey);i++){
			arrayAppend(arrMainField, mainFieldStruct[arrKey[i]].row);
		} 
		parentIndex=0;
		arrSearchTable=[];
		arrSortSQL=[];
		for(row in arrMainField){
			if(row.feature_field_admin_searchable EQ 1){
				arrayAppend(arrSearchTable, row);
			}
			added=false;
			ts2={};
			if(mainSchemaStruct.feature_schema_parent_field NEQ "" and mainSchemaStruct.feature_schema_parent_field EQ row.feature_field_variable_name){
				added=true;
				arrayappend(arrRow, row);
				arrayappend(arrLabel, row.feature_field_display_name);
				arrayappend(arrVal, row.feature_field_id);
				arrayappend(arrType, row.feature_field_type_id);
				parentIndex=arraylen(arrVal);
				if(row.feature_field_primary_field EQ 1){
					arrayAppend(arrDisplay, 1);
				}else{
					arrayAppend(arrDisplay, 0);
				}
			}else if(row.feature_field_primary_field EQ 1){
				added=true;
				arrayAppend(arrDisplay, 1);
				arrayappend(arrRow, row);
				arrayappend(arrLabel, row.feature_field_display_name);
				arrayappend(arrVal, row.feature_field_id);
				arrayappend(arrType, row.feature_field_type_id);
			}
			if(added){
				if(row.feature_field_admin_sort_field NEQ 0){ 
					var currentCFC=application.zcore.featureCom.getTypeCFC(row.feature_field_type_id);
					var sortDirection="asc";
					if(row.feature_field_admin_sort_field EQ 2){
						sortDirection="desc";
					}
					tempSQL=currentCFC.getSortSQL(arraylen(arrVal), sortDirection);
					if(tempSQL NEQ ""){
						arrayAppend(arrSortSQL, tempSQL);
					}
				}
			}
			if(row.feature_field_type_id EQ 0){
				fakeRow=row;
				fakePrimaryId=row.feature_field_id;	
				fakePrimaryLabel=row.feature_field_display_name;	
				fakePrimaryType=row.feature_field_type_id;	
			}
		} 
		if(fakePrimaryId EQ 0 and arrayLen(arrMainField) NEQ 0){
			for(row in arrMainField){
				fakeRow=row;
				break;
			}
			fakePrimaryId=arrMainField[1].feature_field_id;
			fakePrimaryLabel=arrMainField[1].feature_field_display_name;
			fakePrimaryType=arrMainField[1].feature_field_type_id;
		}
		if(arraylen(arrVal) EQ 0){
			arrayAppend(arrDisplay, 1);
			arrayappend(arrRow, fakeRow);
			arrayappend(arrVal, fakePrimaryId);
			arrayappend(arrLabel, fakePrimaryLabel);
			arrayappend(arrType, fakePrimaryType);
		} 
		arrSearch=[];
		var dataStruct=[];
		for(i=1;i LTE arraylen(arrType);i++){
			if(not structkeyexists(arrRow[i], 'feature_field_type_json')){
				continue;
			}
			var typeStruct=deserializeJson(arrRow[i].feature_field_type_json);
			arrayAppend(arrFieldStruct, typeStruct);
			
			var currentCFC=application.zcore.featureCom.getTypeCFC(arrType[i]);
			dataStruct[i]=currentCFC.onBeforeListView(arrRow[i], typeStruct, form);
		}
		listDescription="";
		if(not structkeyexists(arguments.struct, 'recurse')){
			if(methodBackup EQ "userManageSchema"){ 
				application.zcore.template.setTag('pagenav', '<p><a href="/z/user/home/index">User Home Page</a></p>');
			}
			theTitle="#htmleditformat(mainSchemaStruct.feature_schema_display_name)#(s)";
			application.zcore.template.setTag("title",theTitle);
			if(methodBackup EQ "publicAddSchema" or methodBackup EQ "publicEditSchema"){ 
				application.zcore.template.setTag("pagetitle",theTitle);  
			} 
			curParentId=mainSchemaStruct.feature_schema_parent_id;
			curParentSetId=form.feature_data_parent_id;
			if(not structkeyexists(arguments.struct, 'hideNavigation') or not arguments.struct.hideNavigation){
				application.zcore.featureCom.getSetParentLinks(mainSchemaStruct.feature_id, mainSchemaStruct.feature_schema_id, curParentId, curParentSetId, false);
			}
			if(mainSchemaStruct.feature_schema_list_description NEQ ""){
				listDescription=mainSchemaStruct.feature_schema_list_description;
			}
		}

		arrSearchSQL=[];
		searchStruct={};
		searchFieldEnabledStruct={};
	
		if(not structkeyexists(arguments.struct, 'recurse') and form.feature_schema_id NEQ 0 and arraylen(arrSearchTable)){ 
			arrayAppend(arrSearch, '<form action="#arguments.struct.listURL#" method="get">
			<input type="hidden" name="searchOn" value="1" />
			<input type="hidden" name="feature_data_parent_id" value="#form.feature_data_parent_id#" />
			<input type="hidden" name="feature_schema_id" value="#form.feature_schema_id#" />
			<input type="hidden" name="feature_id" value="#form.feature_id#" />
			<div class="z-float " style="border-bottom:1px solid ##CCC; padding-bottom:10px;">');
			for(n=1;n LTE arraylen(arrVal);n++){
				arrSearchSQL[n]="";
			}
			for(i=1;i LTE arraylen(arrSearchTable);i++){
				row=arrSearchTable[i];
				for(n=1;n LTE arraylen(arrVal);n++){
					if(row.feature_field_id EQ arrVal[n]){
						curValIndex=n;
						break;
					}
				}
				
				form['newvalue'&row.feature_field_id]=application.zcore.functions.zso(form, 'newvalue'&row.feature_field_id);
				 
				var typeStruct=arrFieldStruct[curValIndex];
				var currentCFC=application.zcore.featureCom.getTypeCFC(row.feature_field_type_id);
				if(currentCFC.isSearchable()){
					arrayAppend(arrSearch, '<div class="z-float-left z-pr-10 z-pb-10">'&row.feature_field_display_name&'<br />');
					var tempValue=currentCFC.getSearchValue(row, typeStruct, 'newvalue', form, searchStruct);
					if(structkeyexists(form, 'searchOn')){
						arrSearchSQL[curValIndex]=currentCFC.getSearchSQL(row, typeStruct, 'newvalue', form, 's#curValIndex#.feature_data_value',  's#curValIndex#.feature_data_date_value', tempValue); 
						if(arrSearchSQL[curValIndex] NEQ ""){
							searchFieldEnabledStruct[curValIndex]=true;
						}
						arrSearchSQL[curValIndex]=replace(arrSearchSQL[curValIndex], "?", "", "all");
						searchStruct['newvalue'&row.feature_field_id]=tempValue;
					}
					arrayAppend(arrSearch, currentCFC.getSearchFormField(row, typeStruct, 'newvalue', form, tempValue, '')); 
					arrayAppend(arrSearch, '</div>');
				}
			} 
			if(methodBackup NEQ "getRowHTML" and methodBackup NEQ "userGetRowHTML"){
				if(structkeyexists(form, 'searchOn')){
					if(not structkeyexists(request.zsession, 'siteSchemaSearch')){
						request.zsession.siteSchemaSearch={};
					}
					request.zsession.siteSchemaSearch[tempSchemaKey]=searchStruct;
				}
			}
			arrNewSearchSQL=[];
			for(n=1;n LTE arraylen(arrSearchSQL);n++){
				if(arrSearchSQL[n] NEQ ""){
					arrayappend(arrNewSearchSQL, arrSearchSQL[n]);
				}
			}
			arrSearchSQL=arrNewSearchSQL; 
			
			if(mainSchemaStruct.feature_schema_enable_approval EQ 1){
				if(methodBackup NEQ "getRowHTML" and methodBackup NEQ "userGetRowHTML"){
					if(structkeyexists(form, 'searchOn')){
						searchStruct['feature_data_approved']=application.zcore.functions.zso(form,'feature_data_approved');
						if(not structkeyexists(request.zsession, 'siteSchemaSearch')){
							request.zsession.siteSchemaSearch={};
						}
						request.zsession.siteSchemaSearch[tempSchemaKey]=searchStruct;
					}
				}
				arrayAppend(arrSearch, '<div class="z-float-left z-pr-10 z-pb-10">Approval Status:<br />');
				ts = StructNew();
				ts.name = "feature_data_approved";
				ts.listLabels= "Approved|Pending|Deactivated By User|Rejected";
				ts.listValues= "1|0|2|3";
				ts.listLabelsdelimiter="|";
				ts.listValuesdelimiter="|";
				ts.output=false;
				ts.struct=form;
				arrayAppend(arrSearch, application.zcore.functions.zInputSelectBox(ts));
				arrayAppend(arrSearch, '</div>');
			}
			arrayAppend(arrSearch, '<div class="z-float-left">&nbsp;<br><input type="submit" name="searchSubmit1" value="Search" class="z-manager-search-button" /> 
				 <input type="button" onclick="window.location.href=''#application.zcore.functions.zURLAppend(arguments.struct.listURL, 'feature_schema_id=#form.feature_schema_id#&amp;feature_data_parent_id=#form.feature_data_parent_id#&amp;clearSearch=1')#''; " value="Clear Search" class="z-manager-search-button" >
			</div></div></form>');

			if ( mainSchemaStruct.feature_schema_enable_sorting EQ 1 ) {
				if ( structKeyExists( form, 'searchOn' ) and form.searchOn) {
					// echo( 'Sorting disabled when searching.' );
					arrayAppend(arrSearch, '<div style="width:100%; float:left; padding: 10px; border-bottom: 1px solid ##CCCCCC;"><strong>Sorting is disabled when searching.</strong></div>' );
				}
			}
		}
		status=application.zcore.functions.zso(searchStruct, 'feature_data_approved');


		if(mainSchemaStruct.feature_schema_limit GT 0){
			db.sql="SELECT count(feature_schema.feature_schema_id) count
			FROM (#db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema, 
			#db.table("feature_data", request.zos.zcoreDatasource)# feature_data)  "; 
			db.sql&="WHERE   
			feature_data.site_id=#db.param(request.zos.globals.id)# and 
			feature_data_deleted = #db.param(0)# and 
			feature_schema_deleted = #db.param(0)# and 
			feature_data.feature_id = #db.param(form.feature_id)# and 
			feature_data_master_set_id = #db.param(0)# and 
			feature_schema.feature_schema_id=feature_data.feature_schema_id "; 
			if(methodBackup EQ "userManageSchema" and request.isUserPrimarySchema){
				db.sql&=" and feature_data_user = #db.param(currentUserIdValue)# ";
			}
			if(form.feature_data_parent_id NEQ 0){
				db.sql&=" and feature_data.feature_data_parent_id = #db.param(form.feature_data_parent_id)#";
			} 
			if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
				db.sql&=" and feature_data.feature_data_id = #db.param(form.feature_data_id)# ";
			}
			if(mainSchemaStruct.feature_schema_enable_archiving EQ 1 and not showArchived){
				db.sql&=" and feature_data_archived =#db.param(0)# ";
			}
			db.sql&=" and feature_schema.feature_id =#db.param(form.feature_id)# and 
			feature_schema.feature_schema_id = #db.param(form.feature_schema_id)# and 
			feature_schema.feature_schema_type=#db.param('1')# ";
			qCountAllLimit=db.execute("qCountAllLimit");
		}

		if(methodBackup EQ "userManageSchema"){
			db.sql="SELECT count(feature_schema.feature_schema_id) count
			FROM (#db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema, 
			#db.table("feature_data", request.zos.zcoreDatasource)# feature_data)  ";
			// for(i=1;i LTE arraylen(arrVal);i++){
			// 	if(structkeyexists(searchFieldEnabledStruct, i)){
			// 		db.sql&="LEFT JOIN #db.table("feature_data", request.zos.zcoreDatasource)# s#i# on 
			// 		s#i#.feature_data_id = feature_data.feature_data_id and 
			// 		s#i#.feature_field_id = #db.param(arrVal[i])# and 
			// 		s#i#.feature_schema_id = feature_schema.feature_schema_id and  
			// 		s#i#.feature_id = #db.param(form.feature_id)# and 
			// 		s#i#.feature_data_deleted = #db.param(0)# ";
			// 	}
			// }
			db.sql&="WHERE  
			feature_data.site_id=#db.param(request.zos.globals.id)# and 
			feature_data_deleted = #db.param(0)# and 
			feature_schema_deleted = #db.param(0)# and 
			feature_data.feature_id = #db.param(form.feature_id)# and 
			feature_data_master_set_id = #db.param(0)# and 
			feature_schema.feature_schema_id=feature_data.feature_schema_id ";
			if(methodBackup EQ "userManageSchema" and request.isUserPrimarySchema){
				db.sql&=" and feature_data_user = #db.param(currentUserIdValue)# ";
			}
			if(form.feature_data_parent_id NEQ 0){
				db.sql&=" and feature_data.feature_data_parent_id = #db.param(form.feature_data_parent_id)#";
			}
			if(status NEQ ""){
				db.sql&=" and feature_data_approved = #db.param(status)# ";
			}
			if(arraylen(arrSearchSQL)){
				db.sql&=(" and "&arrayToList(arrSearchSQL, ' and '));
			}
			if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
				db.sql&=" and feature_data.feature_data_id = #db.param(form.feature_data_id)# ";
			}
			if(mainSchemaStruct.feature_schema_enable_archiving EQ 1 and not showArchived){
				db.sql&=" and feature_data_archived =#db.param(0)# ";
			}
			db.sql&=" and feature_schema.feature_id =#db.param(form.feature_id)# and 
			feature_schema.feature_schema_id = #db.param(form.feature_schema_id)# and 
			feature_schema.feature_schema_type=#db.param('1')# ";
			qCount=db.execute("qCount");

			if(mainSchemaStruct.feature_schema_user_child_limit NEQ 0){
				db.sql="SELECT count(feature_schema.feature_schema_id) count
				FROM (#db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema, 
				#db.table("feature_data", request.zos.zcoreDatasource)# feature_data)  ";
				// for(i=1;i LTE arraylen(arrVal);i++){
				// 	if(structkeyexists(searchFieldEnabledStruct, i)){
				// 		db.sql&="LEFT JOIN #db.table("feature_data", request.zos.zcoreDatasource)# s#i# on 
				// 		s#i#.feature_data_id = feature_data.feature_data_id and 
				// 		s#i#.feature_field_id = #db.param(arrVal[i])# and 
				// 		s#i#.feature_schema_id = feature_schema.feature_schema_id and 
				// 		s#i#.feature_id = #db.param(form.feature_id)# and 
				// 		s#i#.feature_data_deleted = #db.param(0)# ";
				// 	}
				// }
				db.sql&="WHERE  
				feature_data.site_id=#db.param(request.zos.globals.id)# and 
				feature_data_deleted = #db.param(0)# and 
				feature_schema_deleted = #db.param(0)# and 
				feature_data.feature_id = #db.param(form.feature_id)# and 
				feature_data_master_set_id = #db.param(0)# and 
				feature_schema.feature_schema_id=feature_data.feature_schema_id ";
				if(methodBackup EQ "userManageSchema" and request.isUserPrimarySchema){
					db.sql&=" and feature_data_user = #db.param(currentUserIdValue)# ";
				}
				if(form.feature_data_parent_id NEQ 0){
					db.sql&=" and feature_data.feature_data_parent_id = #db.param(form.feature_data_parent_id)#";
				} 
				if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
					db.sql&=" and feature_data.feature_data_id = #db.param(form.feature_data_id)# ";
				}
				if(mainSchemaStruct.feature_schema_enable_archiving EQ 1 and not showArchived){
					db.sql&=" and feature_data_archived =#db.param(0)# ";
				}
				db.sql&=" and feature_schema.feature_id =#db.param(form.feature_id)# and 
				feature_schema.feature_schema_id = #db.param(form.feature_schema_id)# and 
				feature_schema.feature_schema_type=#db.param('1')# ";
				qCountLimit=db.execute("qCountLimit"); 
			}
		}else{ 
			if(arraylen(arrSearchSQL) GT 0 or mainSchemaStruct.feature_schema_enable_cache EQ 0 or mainSchemaStruct.feature_schema_admin_paging_limit NEQ 0){
				db.sql="SELECT count(feature_schema.feature_schema_id) count
				FROM (#db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema, 
				#db.table("feature_data", request.zos.zcoreDatasource)# feature_data)  ";
				// for(i=1;i LTE arraylen(arrVal);i++){
				// 	if(structkeyexists(searchFieldEnabledStruct, i)){
				// 		db.sql&="LEFT JOIN #db.table("feature_data", request.zos.zcoreDatasource)# s#i# on 
				// 		s#i#.feature_data_id = feature_data.feature_data_id and 
				// 		s#i#.feature_field_id = #db.param(arrVal[i])# and 
				// 		s#i#.feature_schema_id = feature_schema.feature_schema_id and 
				// 		s#i#.site_id = feature_schema.site_id and 
				// 		s#i#.feature_id = #db.param(form.feature_id)# and 
				// 		s#i#.feature_data_deleted = #db.param(0)# ";
				// 	}
				// }
				db.sql&="WHERE  
				feature_data.site_id=#db.param(request.zos.globals.id)# and 
				feature_data_deleted = #db.param(0)# and 
				feature_schema_deleted = #db.param(0)# and 
				feature_data.feature_id = #db.param(form.feature_id)# and 
				feature_data_master_set_id = #db.param(0)# and  
				feature_schema.feature_schema_id=feature_data.feature_schema_id "; 
				if(methodBackup EQ "userManageSchema" and request.isUserPrimarySchema){
					db.sql&=" and feature_data_user = #db.param(currentUserIdValue)# ";
				}
				if(form.feature_data_parent_id NEQ 0){
					db.sql&=" and feature_data.feature_data_parent_id = #db.param(form.feature_data_parent_id)#";
				}
				if(status NEQ ""){
					db.sql&=" and feature_data_approved = #db.param(status)# ";
				}
				// if(arraylen(arrSearchSQL)){
				// 	db.sql&=(" and "&arrayToList(arrSearchSQL, ' and '));
				// }
				if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
					db.sql&=" and feature_data.feature_data_id = #db.param(form.feature_data_id)# ";
				}
				if(mainSchemaStruct.feature_schema_enable_archiving EQ 1 and not showArchived){
					db.sql&=" and feature_data_archived =#db.param(0)# ";
				}
				db.sql&=" and feature_schema.feature_id =#db.param(form.feature_id)# and 
				feature_schema.feature_schema_id = #db.param(form.feature_schema_id)# and 
				feature_schema.feature_schema_type=#db.param('1')# ";
				qCount=db.execute("qCount");  
			}else{
				// get the things
				qCount={recordcount:1, count: 0 }; 
			}
		} 


		db.sql="SELECT feature_schema.*,  feature_data.*";
		// for(i=1;i LTE arraylen(arrVal);i++){
		// 	db.sql&=" , s#i#.feature_data_value sVal#i# ";
		// }
		db.sql&=" FROM (#db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema, 
		#db.table("feature_data", request.zos.zcoreDatasource)# feature_data) ";
		// for(i=1;i LTE arraylen(arrVal);i++){
		// 	db.sql&="LEFT JOIN #db.table("feature_data", request.zos.zcoreDatasource)# s#i# on 
		// 	s#i#.feature_data_id = feature_data.feature_data_id and 
		// 	s#i#.feature_field_id = #db.param(arrVal[i])# and 
		// 	s#i#.feature_schema_id = feature_schema.feature_schema_id and  
		// 	s#i#.feature_id = #db.param(form.feature_id)# and 
		// 	s#i#.feature_data_deleted = #db.param(0)# ";
		// }
		db.sql&="
		WHERE  
		feature_data.site_id=#db.param(request.zos.globals.id)# and 
		feature_schema_deleted = #db.param(0)# and
		feature_data_master_set_id = #db.param(0)# and 
		feature_data_deleted = #db.param(0)# and 
		feature_data.feature_id = #db.param(form.feature_id)# and 
		feature_schema.feature_schema_id=feature_data.feature_schema_id ";
		// if(arraylen(arrSearchSQL)){
		// 	db.sql&=(" and "&arrayToList(arrSearchSQL, ' and '));
		// }
		if(status NEQ ""){
			db.sql&=" and feature_data_approved = #db.param(status)# ";
		}
		if(methodBackup EQ "userManageSchema" and request.isUserPrimarySchema){
			db.sql&=" and feature_data_user = #db.param(currentUserIdValue)# ";
		}
		if(form.feature_data_parent_id NEQ 0){
			db.sql&=" and feature_data.feature_data_parent_id = #db.param(form.feature_data_parent_id)#";
		}
		if(methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML"){
			db.sql&=" and feature_data.feature_data_id = #db.param(form.feature_data_id)# ";
		}
		db.sql&=" and feature_schema.feature_id =#db.param(form.feature_id)# and 
		feature_schema.feature_schema_id = #db.param(form.feature_schema_id)# and 
		feature_schema.feature_schema_type=#db.param('1')# ";

		if(mainSchemaStruct.feature_schema_enable_archiving EQ 1 and not showArchived){
			db.sql&=" and feature_data_archived =#db.param(0)# ";
		}
		//GROUP BY feature_data.feature_data_id
		// if(arraylen(arrSortSQL)){
		// 	db.sql&= "ORDER BY "&arraytolist(arrSortSQL, ", ");
		// }else{
			db.sql&=" ORDER BY feature_data_sort asc ";
		// }
		if(mainSchemaStruct.feature_schema_admin_paging_limit NEQ 0){
			db.sql&=" LIMIT #db.param((form.zIndex-1)*mainSchemaStruct.feature_schema_admin_paging_limit)#, #db.param(mainSchemaStruct.feature_schema_admin_paging_limit)# ";
		}
		qS=db.execute("qS", "", 10000, "query", false);  


		if(mainSchemaStruct.feature_schema_limit GT 0){
			db.sql="SELECT feature_schema.*,  feature_data.* 
			FROM (#db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema, 
			#db.table("feature_data", request.zos.zcoreDatasource)# feature_data) 
			WHERE  
			feature_data.site_id=#db.param(request.zos.globals.id)# and 
			feature_schema_deleted = #db.param(0)# and
			feature_data_master_set_id = #db.param(0)# and 
			feature_data_deleted = #db.param(0)# and 
			feature_data.feature_id = #db.param(form.feature_id)# and  
			feature_schema.feature_schema_id=feature_data.feature_schema_id ";
			if(arraylen(arrSearchSQL)){
				db.sql&=(" and "&arrayToList(arrSearchSQL, ' and '));
			}
			if(status NEQ ""){
				db.sql&=" and feature_data_approved = #db.param(status)# ";
			}
			if(methodBackup EQ "userManageSchema" and request.isUserPrimarySchema){
				db.sql&=" and feature_data_user = #db.param(currentUserIdValue)# ";
			}
			if(form.feature_data_parent_id NEQ 0){
				db.sql&=" and feature_data.feature_data_parent_id = #db.param(form.feature_data_parent_id)#";
			} 
			if(mainSchemaStruct.feature_schema_enable_archiving EQ 1 and not showArchived){
				db.sql&=" and feature_data_archived =#db.param(0)# ";
			}
			db.sql&=" and feature_schema.feature_id =#db.param(form.feature_id)# and 
			feature_schema.feature_schema_id = #db.param(form.feature_schema_id)# and 
			feature_schema.feature_schema_type=#db.param('1')# ";
			//GROUP BY feature_data.feature_data_id
			if(arraylen(arrSortSQL)){
				db.sql&= "ORDER BY "&arraytolist(arrSortSQL, ", ");
			}else{
				db.sql&=" ORDER BY feature_data_sort asc ";
			}
			if(mainSchemaStruct.feature_schema_admin_paging_limit NEQ 0){
				db.sql&=" LIMIT #db.param((form.zIndex-1)*mainSchemaStruct.feature_schema_admin_paging_limit)#, #db.param(mainSchemaStruct.feature_schema_admin_paging_limit)# ";
			}
			qSCount=db.execute("qSCount");
		}
		//writedump(qS);abort;
		// sort and indent 
		if(parentIndex NEQ 0){
			rs=application.zcore.featureCom.prepareRecursiveData(arrVal[parentIndex], form.feature_schema_id, arrFieldStruct[parentIndex], false);
		}
		
		rowStruct={};
		rowIndexFix=1;
		if(structkeyexists(arguments.struct, 'recurse') and qS.recordcount NEQ 0){
			echo('<h3>Sub-group: #mainSchemaStruct.feature_schema_display_name#</h3>');
		}
		addEnabled=true;
		sortLink='';
		if(not structkeyexists(arguments.struct, 'recurse')){
			if(mainSchemaStruct.feature_schema_enable_sorting EQ 1){
				if(not sortEnabled and subgroupRecurseEnabled){
					sortLink=('<a href="/z/feature/admin/features/#methodBackup#?feature_schema_id=#form.feature_schema_id#&amp;feature_data_parent_id=#form.feature_data_parent_id#&amp;enableSorting=1" class="z-manager-search-button">Enable Sorting</a>');
					
				}else if(form.enableSorting EQ 1){
					sortLink=('<a href="/z/feature/admin/features/#methodBackup#?feature_schema_id=#form.feature_schema_id#&amp;feature_data_parent_id=#form.feature_data_parent_id#" class="z-manager-search-button">Disable Sorting</a>');
				}
			}
		} 
		if(mainSchemaStruct.feature_schema_limit EQ 0 or qCountAllLimit.count LT mainSchemaStruct.feature_schema_limit){
			if(methodBackup EQ "userManageSchema"){ 
				if(mainSchemaStruct.feature_schema_user_child_limit NEQ 0 and qCountLimit.count GTE mainSchemaStruct.feature_schema_user_child_limit){
					addEnabled=false;
				}
			}
			if(structkeyexists(arguments.struct, 'recurse') EQ false){ 
				echo('<div class="z-float z-mb-10"><h2 style="display:inline-block; ">#mainSchemaStruct.feature_schema_display_name#(s)</h2> &nbsp;&nbsp; ');
				if(addEnabled){
					writeoutput('<a href="#application.zcore.functions.zURLAppend(arguments.struct.addURL, "feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&amp;feature_data_parent_id=#form.feature_data_parent_id#")#&modalpopforced=1" onclick="zTableRecordAdd(this, ''sortRowTable''); return false; " class="z-manager-quick-add-link z-manager-search-button ">Add</a>');
					if(application.zcore.functions.zso(form, 'zManagerAddOnLoad', true, 0) EQ 1){
						application.zcore.skin.addDeferredScript(' $(".z-manager-quick-add-link").trigger("click"); ');
					} 
				} 
				if(methodBackup EQ "manageSchema" and mainSchemaStruct.feature_schema_disable_export EQ 0){
					echo(' <a href="/z/feature/admin/feature-schema/export?feature_id=#mainSchemaStruct.feature_id#&feature_schema_id=#mainSchemaStruct.feature_schema_id#" class="z-button" target="_blank">Export CSV</a>');
				}

				if(mainSchemaStruct.feature_schema_enable_archiving EQ 1){
					if(showArchived){ 
						echo(' <a href="/z/feature/admin/features/#methodBackup#?feature_schema_id=#form.feature_schema_id#&feature_data_parent_id=#form.feature_data_parent_id#&showArchived=0" class="z-button">Hide Archived</a>'); 
					}else{
						echo(' <a href="/z/feature/admin/features/#methodBackup#?feature_schema_id=#form.feature_schema_id#&feature_data_parent_id=#form.feature_data_parent_id#&showArchived=1" class="z-button">Show Archived</a>');
					}
				}
				echo(' #sortLink#</div>'); 
			}
		}else{

			if(structkeyexists(arguments.struct, 'recurse') EQ false){
				echo('<div class="z-float z-mb-10"><h2 style="display:inline-block; ">#mainSchemaStruct.feature_schema_display_name#(s)</h2> &nbsp;&nbsp; #sortLink#</div>');
			}

		} 
		echo(listDescription);
		if(not structkeyexists(arguments.struct, 'recurse') and form.feature_schema_id NEQ 0 and arraylen(arrSearchTable)){ 
			if(mainSchemaStruct.feature_schema_limit EQ 0 or (qCountAllLimit.recordcount NEQ 0 and qCountAllLimit.count > 0)){
				echo(arraytolist(arrSearch, ""));
			}
		}
		if(mainSchemaStruct.feature_schema_enable_merge_interface EQ 1){
			arrId=[-1];
			loop query="#qS#"{
				arrayAppend(arrId, qS.feature_data_merge_data_id);
			}
			feature_data_id_list=arrayToList(arrId, ", ");
			db.sql="SELECT * FROM 
			#db.table("feature_data", request.zos.zcoreDatasource)# 
			WHERE  
			feature_data.site_id=#db.param(request.zos.globals.id)# and 
			feature_data_master_set_id = #db.param(0)# and 
			feature_data_deleted = #db.param(0)# and 
			feature_data.feature_id = #db.param(form.feature_id)# and 
			feature_data.feature_data_id IN (#db.trustedSQL(feature_data_id_list)#) and 
			feature_data.feature_id =#db.param(form.feature_id)# ";
			qChildData=db.execute("qChildData", "", 10000, "query", false);  

			childStruct={};
			for(row in qChildData){
				childStruct[row.feature_data_id]=row;
			}

		}
		if(sortEnabled){
			echo('<script>
			var featureReloadLink="/z/feature/admin/features/getTableHTMLJSON?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&feature_data_parent_id=#form.feature_data_parent_id#&modalpopforced=#application.zcore.functions.zso(form, 'modalpopforced')#&enableSorting=1";
			</script>');
		}
		if(qS.recordcount){
			savecontent variable="tableHTML"{
				if(mainSchemaStruct.feature_schema_enable_merge_interface EQ 1){
					if(sortEnabled){
						echo('<table id="sortRowTable" class="table-list" style="width:100%;">');
					}else{
						echo('<table id="sortRowTable" class="table-list" style="width:100%;" >');
					}
					echo('<thead>
					<tr>
						<th class="z-hide-at-767">ID</th>
						<th>Name</th>
						<th>Type</th>
						<th>Last Updated</th>
						<th>Admin</th>
					</tr>
					<tbody>');
					currentRowIndex=0;
					for(row in qS){
						currentRowIndex++;
						trHTML="";
						if(sortEnabled){
							if(row.site_id NEQ 0 or variables.allowGlobal){
								trHTML=queueSortCom.getRowHTML(row.feature_data_id);
							}
						}
						if(not structkeyexists(childStruct, row.feature_data_merge_data_id)){
							application.zcore.featureCom.deleteSchemaSetRecursively(row.feature_data_id, row.site_id, row);
							continue; // ignoring records with no proper child record.
						}
						childRow=childStruct[row.feature_data_merge_data_id];
						rsData=application.zcore.featureCom.parseFieldData(row);



						echo('<tr #trHTML# data-ztable-sort-disable-validation="1" ');// data-ztable-sort-parent-id="#childRow.feature_data_parent_id#"
						if(currentRowIndex MOD 2 EQ 0){
							echo('class="row2"');
						}else{
							echo('class="row1"');
						}
						echo('>
						<td class="z-hide-at-767">#row.feature_data_id#</td>
						<td>');
						if(row.feature_data_level GT 0){
							echo(replace(ljustify(" ", row.feature_data_level*4), " ", "&nbsp;", "all"));
						}
						echo('#rsData.name#</td>
						<td>#application.zcore.featureCom.getSchemaNameById(row.feature_id, row.feature_data_merge_schema_id)#</td>
						<td>');
						if(datediff("s", row.feature_data_updated_datetime, childRow.feature_data_updated_datetime) LT 0){
							echo(application.zcore.functions.zGetLastUpdatedDescription(row.feature_data_updated_datetime));
						}else{
							echo(application.zcore.functions.zGetLastUpdatedDescription(childRow.feature_data_updated_datetime));
						}
						echo('</td>');
						echo('<td style="white-space:nowrap;white-space: nowrap;" class="z-manager-admin">'); 
						ms={
							sortEnabled:sortEnabled,
							arrChildSchema:arrChildSchema,
							methodBackup:methodBackup,
							mainSchemaStruct:mainSchemaStruct,
							qSCount:{},
							struct:arguments.struct,
							childRow:childRow,
							subgroupStruct:subgroupStruct
						};
						if(sortEnabled){
							ms.queueSortCom=queueSortCom;
						}
						if(mainSchemaStruct.feature_schema_limit GT 0){
							ms.qSCount=qSCount;
						}
						echo(getAdminHTML(row, ms));
						echo('</td></tr>');
					}
					writeoutput('</tbody></table>');
				}else{

					columnCount=0;
					if(sortEnabled){
						echo('<table id="sortRowTable" class="table-list" style="width:100%;">');
					}else{
						echo('<table id="sortRowTable" class="table-list" style="width:100%;" >');
					}
					echo('<thead>
					<tr>');
					echo('<th class="z-hide-at-767">ID</th>');
					columnCount++;
					for(i=1;i LTE arraylen(arrVal);i++){
						if(arrDisplay[i]){
							writeoutput('<th>#arrLabel[i]#</th>');
							columnCount++;
						}
					}
					if(mainSchemaStruct.feature_schema_enable_approval EQ 1){
						echo('<th>Approval Status</th>');
						columnCount++;
					}
					writeoutput('
					<th>Last Updated</th>
					<th style="white-space:nowrap;">Admin</th>
					</tr>
					</thead><tbody>');
					columnCount+=2;
					var row=0;
					var currentRowIndex=0;
					curParentId=0;
					for(row in qS){
						currentRowIndex++;
						if(parentIndex){
							curRowIndex=0;
							curParentId=0;
							curIndent=0;
							for(n=1;n LTE arraylen(rs.arrValue);n++){
								if(row.feature_data_id EQ rs.arrValue[n]){
									curRowIndex=n;
									curParentId=rs.arrParent[n];
									curIndent=len(rs.arrLabel[n])-len(replace(rs.arrLabel[n], "_", "", "all"));
									break;
								}
							}
							if(curRowIndex EQ 0){
								curRowIndex="1000000"&rowIndexFix;
								rowIndexFix++;
							}
						}else{
							curParentId=0;
							curRowIndex=qS.currentrow;
						}
						firstDisplayed=true; 

						// need to pull data from feature_data_data
						fieldStruct={};
						if(row.feature_data_field_order NEQ ""){
							arrFieldOrder=listToArray(row.feature_data_field_order, chr(13), true);
							arrFieldData=listToArray(row.feature_data_data, chr(13), true);
							for(i=1;i<=arraylen(arrFieldOrder);i++){
								fieldStruct[arrFieldOrder[i]]=arrFieldData[i];
							}
						}

						// image is not being added to list view
						savecontent variable="rowOutput"{ 
							echo('<td class="z-hide-at-767">'&row.feature_data_id&'</td>');
							for(var i=1;i LTE arraylen(arrVal);i++){
								if(arrDisplay[i]){
									writeoutput('<td>');
									if(firstDisplayed){
										firstDisplayed=false;
										if(parentIndex NEQ 0 and curIndent){
											writeoutput(replace(ljustify(" ", curIndent*4), " ", "&nbsp;", "all"));
										}
									}
									var currentCFC=application.zcore.featureCom.getTypeCFC(arrType[i]);
									value=currentCFC.getListValue(dataStruct[i], arrFieldStruct[i], application.zcore.functions.zso(fieldStruct, arrVal[i]));
									if(arrType[i] EQ 1){
										if(value EQ ""){
											writeoutput(htmleditformat(arrRow[i].feature_field_default_value));
										}else{
											writeoutput(htmleditformat(value));
										}
									}else{
										if(value EQ ""){
											writeoutput(arrRow[i].feature_field_default_value);
										}else{
											writeoutput(value);
										}
									}
									writeoutput('</td>');
								}
							}
							if(mainSchemaStruct.feature_schema_enable_approval EQ 1){
								echo('<td>'&application.zcore.featureCom.getStatusName(row.feature_data_approved)&'</td>');
							}
							echo('<td>'&application.zcore.functions.zGetLastUpdatedDescription(row.feature_data_updated_datetime)&'</td>');
							writeoutput('<td style="white-space:nowrap;white-space: nowrap;" class="z-manager-admin">'); 
							ms={
								sortEnabled:sortEnabled,
								arrChildSchema:arrChildSchema,
								methodBackup:methodBackup,
								mainSchemaStruct:mainSchemaStruct,
								struct:arguments.struct,
								subgroupStruct:subgroupStruct
							};
							if(sortEnabled){
								ms.queueSortCom=queueSortCom;
							}
							if(mainSchemaStruct.feature_schema_limit GT 0){
								ms.qSCount=qSCount;
							}
							echo(getAdminHTML(row, ms));
							writeoutput('</td>'); 
						}

						sublistEnabled=false;
						backupSiteFieldAppId=form.feature_id;
						backupSiteSchemaId=form.feature_schema_id;
						backupSiteXSchemaSetParentId=form.feature_data_parent_id;
						savecontent variable="recurseOut"{
							if(subgroupRecurseEnabled and form.enableSorting EQ 0 and arrayLen(arrChildSchema) NEQ 0){
								for(var n in arrChildSchema){
									if(n.feature_schema_enable_list_recurse EQ "1"){
										form.feature_schema_app_id=row.feature_id;
										form.feature_data_parent_id=row.feature_data_id;
										form.feature_schema_id=n.feature_schema_id;
										if(methodBackup EQ "userManageSchema"){
											userManageSchema({recurse:true});
										}else{
											manageSchema({recurse:true});
										}
										sublistEnabled=true;
									}
								}
							}
						}
						form.feature_data_parent_id=backupSiteXSchemaSetParentId;
						form.feature_schema_id=backupSiteSchemaId;
						form.feature_id=backupSiteFieldAppId;
						if(not sublistEnabled){
							recurseOut="";
						}
						rowStruct[curRowIndex]={
							index:curRowIndex,
							parentId:curParentId,
							row:rowOutput,
							trHTML:"",
							sublist:recurseOut
						};
						lastRowStruct=rowStruct[curRowIndex];

						if(sortEnabled){
							if(row.site_id NEQ 0 or variables.allowGlobal){
								rowStruct[curRowIndex].trHTML=queueSortCom.getRowHTML(row.feature_data_id);
							}
						}
					}
					arrKey=structsort(rowStruct, "numeric", "asc", "index");
					arraysort(arrKey, "numeric", "asc");
					for(i=1;i LTE arraylen(arrKey);i++){
						writeoutput('<tr '&rowStruct[arrKey[i]].trHTML&' data-ztable-sort-disable-validation="1" ');// data-ztable-sort-parent-id="#rowStruct[arrKey[i]].parentId#"
						if(i MOD 2 EQ 0){
							writeoutput('class="row2"');
						}else{
							writeoutput('class="row1"');
						}
						writeoutput('>'&rowStruct[arrKey[i]].row&'</tr>');
						if(rowStruct[arrKey[i]].sublist NEQ ""){
							echo('<tr><td colspan="#columnCount#" style="padding:20px;">'&rowStruct[arrKey[i]].sublist&'</td></tr>');
						}
					} 
					writeoutput('</tbody></table>');
				}
			}
			if((methodBackup NEQ "getTableHTML" and methodBackup NEQ "userGetTableHTML")){ 
				echo(tableHTML);
			}
			if(form.feature_schema_id NEQ 0){
				if(mainSchemaStruct.feature_schema_admin_paging_limit NEQ 0){
					searchStruct = StructNew();
					searchStruct.count = qCount.count;
					searchStruct.index = form.zIndex;
					searchStruct.showString = "Results ";
					searchStruct.url = application.zcore.functions.zURLAppend(arguments.struct.listURL, "feature_schema_id=#form.feature_schema_id#");
					searchStruct.indexName = "zIndex";
					searchStruct.buttons = 5;
					searchStruct.perpage = mainSchemaStruct.feature_schema_admin_paging_limit;
					if(searchStruct.count GT searchStruct.perpage){
						writeoutput( '<table class="table-list" style="width:100%; border-spacing:0px;" ><tr><td style="padding:0px;">'&application.zcore.functions.zSearchResultsNav(searchStruct)&'</td></tr></table>');
					}
				} 
			}
		}

	}


	if((methodBackup EQ "getTableHTML" or methodBackup EQ "userGetTableHTML")){ 
		return tableHTML;
	}else if((methodBackup EQ "getRowHTML" or methodBackup EQ "userGetRowHTML")){ 
		if(arraylen(rowStruct)){
			return lastRowStruct.row;  
		}else{
			return '<td colspan="2">Data missing, please reload the page.</td>';
		}
		/*
		rowOut=lastRowStruct.row; 
		echo('done.<script type="text/javascript">
		window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
		window.parent.zCloseModal();
		</script>');
		abort;
		*/
	}else{
		hasListRecurseSchema=false; 
		for(var n in arrChildSchema){
			if(n.feature_schema_enable_list_recurse EQ "1"){
				hasListRecurseSchema=true;
				break;
			}
		}
		if(hasListRecurseSchema){
			echo(out);
		}else{
			echo('<div class="z-manager-list-view">'); 
			echo(out);
			echo('</div>');
		}
	}
	</cfscript> 
	<script type="text/javascript"> 
	function archiveSchemaRecord(obj){ 
		var tr, table;
		var i=0;
		linkObj=obj;
		while(true){
			i++;
			if(obj.tagName.toLowerCase() == 'tr'){
				tr=obj;
			}else if(obj.tagName.toLowerCase() == 'table'){
				table=obj;
				break;
			}
			obj=obj.parentNode;
			if(i > 50){
				alert('infinite loop. invalid table html structure');
				return false;
			}
		}
		var cellCount=zCalculateTableCells(table);

		var t={
			id:"ajaxSchemaArchive",
			method:"post",
			postObj:{},
			ignoreOldRequests:false,
			callback:function(r){
				r=JSON.parse(r);
				if(r.success){ 
					$(tr).html('<td class="zDeletedRow" colspan="'+cellCount+'">Row Archived</td>');
				}
			},
			errorCallback:function(){
				alert("Archived failed, please try again later.");
			},
			url:linkObj.href
		};  
		zAjax(t);
	}
	</script>


</cffunction>

<cffunction name="getAdminHTML" localmode="modern" access="remote"> 
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="ms" type="struct" required="yes">
	<cfscript>  
	row=arguments.row;
	ms=arguments.ms;
	savecontent variable="adminHTML"{
		if(row.site_id NEQ 0 or variables.allowGlobal){
			if(ms.sortEnabled){
				if(row.site_id NEQ 0 or variables.allowGlobal){
					echo('<div class="z-manager-button-container">');
					ms.queueSortCom.getRowStruct(row.feature_data_id);
					echo(ms.queueSortCom.getAjaxHandleButton(row.feature_data_id));
					echo('</div>');
				}
			}


			if(row.feature_schema_enable_unique_url EQ 1){
				var tempLink="";
				if(row.feature_data_override_url NEQ ""){
					tempLink=row.feature_data_override_url;
				}else{
					tempLink="/#application.zcore.functions.zURLEncode(row.feature_data_title, '-')#-50-#row.feature_data_id#.html";
				}
				if(row.feature_schema_enable_approval EQ 1){

					if(row.feature_data_approved NEQ 1){
						echo('<div class="z-manager-button-container">
							<a title="Inactive"><i class="fa fa-times-circle" aria-hidden="true" style="color:##900;"></i></a>
						</div>');
					}else{
						echo('<div class="z-manager-button-container">
							<a title="Active"><i class="fa fa-check-circle" aria-hidden="true" style="color:##090;"></i></a>
						</div>');
					}
				}

				if(row.feature_data_approved EQ 1){
					writeoutput('<div class="z-manager-button-container"><a href="'&tempLink&'" target="_blank" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a></div>');
				}else{
					writeoutput('<div class="z-manager-button-container"><a href="'&application.zcore.functions.zURLAppend(tempLink, "zpreview=1")&'" target="_blank" class="z-manager-view" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a></div>');
				}
			}
			echo('<div class="z-manager-button-container">');
			hasMultipleEditFeatures=false;
			savecontent variable="editHTML"{
				echo('
				<a href="##" class="z-manager-edit" id="z-manager-edit#row.feature_data_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a>
				<div class="z-manager-edit-menu">');

				editLink=application.zcore.functions.zURLAppend(ms.struct.editURL, "feature_id=#row.feature_id#&feature_schema_id=#row.feature_schema_id#&amp;feature_data_id=#row.feature_data_id#&amp;feature_data_parent_id=#row.feature_data_parent_id#&amp;modalpopforced=1");
				if(not ms.sortEnabled){
					editLink&="&amp;disableSorting=1";
				}
				echo('<a href="#editLink#" onclick="zTableRecordEdit(this);  return false;">Edit #row.feature_schema_display_name#</a> ');

				sog=application.zcore.featureData.featureSchemaData[form.feature_id];
				if(ms.mainSchemaStruct.feature_schema_enable_merge_interface EQ 1){
					group=sog.featureSchemaLookup[ms.childRow.feature_schema_id];
					editChildLink=application.zcore.functions.zURLAppend(ms.struct.editURL, "feature_id=#ms.childRow.feature_id#&feature_schema_id=#ms.childRow.feature_schema_id#&amp;feature_data_id=#ms.childRow.feature_data_id#&amp;feature_data_parent_id=#ms.childRow.feature_data_parent_id#&amp;modalpopforced=1");
					if(not ms.sortEnabled){
						editLink&="&amp;disableSorting=1";
					}
					echo('<a href="#editChildLink#" onclick="zTableRecordEdit(this);  return false;">Edit #group.feature_schema_display_name#</a> ');
					hasMultipleEditFeatures=true;
					// get the groups for this feature_data_merge_schema_id for each row instead
					for(groupId in sog.featureSchemaLookup){
						group=sog.featureSchemaLookup[groupId];
						if(group.feature_schema_parent_id EQ row.feature_data_merge_schema_id){
							link=application.zcore.functions.zURLAppend(ms.struct.listURL, "feature_id=#group.feature_id#&feature_schema_id=#group.feature_schema_id#&amp;feature_data_parent_id=#row.feature_data_id#");
							echo('<a href="#link#">Manage #application.zcore.functions.zFirstLetterCaps(group.feature_schema_display_name)#(s)</a>'); // n.childCount
							hasMultipleEditFeatures=true;
						}
					}
				}else{
					if(arrayLen(ms.arrChildSchema) NEQ 0){ 
						for(n in ms.arrChildSchema){
							if(structkeyexists(ms.subgroupStruct, n.feature_schema_id)){
								link=application.zcore.functions.zURLAppend(ms.struct.listURL, "feature_id=#row.feature_id#&feature_schema_id=#n.feature_schema_id#&amp;feature_data_parent_id=#row.feature_data_id#");
								echo('<a href="#link#">Manage #application.zcore.functions.zFirstLetterCaps(n.feature_schema_display_name)#(s)</a>'); // n.childCount
								hasMultipleEditFeatures=true;
							}
						} 
					} 
				}
				copyLink="";
				if(ms.methodBackup NEQ "userManageSchema" and ms.methodBackup NEQ "userGetRowHTML"){
					if(ms.mainSchemaStruct.feature_schema_limit EQ 0 or ms.qSCount.recordcount LT ms.mainSchemaStruct.feature_schema_limit){
						if(ms.mainSchemaStruct.feature_schema_enable_versioning EQ 1 and row.feature_data_parent_id EQ 0){
							copyLink=application.zcore.functions.zURLAppend(ms.struct.copyURL, "feature_id=#row.feature_id#&feature_data_id=#row.feature_data_id#"); 
							echo('<a href="#application.zcore.functions.zURLAppend(ms.struct.versionURL, "feature_data_id=#row.feature_data_id#")#">Versions</a>');
							hasMultipleEditFeatures=true;
						}else{
							copyLink=application.zcore.functions.zURLAppend(ms.struct.addURL, "feature_id=#row.feature_id#&feature_schema_id=#row.feature_schema_id#&amp;feature_data_id=#row.feature_data_id#&amp;feature_data_parent_id=#row.feature_data_parent_id#");
							
						}
					}
				}
				
				if(row.feature_schema_enable_archiving EQ 1){
					if(row.feature_data_archived EQ 1){
						echo('<a href="#application.zcore.functions.zURLAppend(ms.struct.unarchiveURL, "feature_schema_id=#row.feature_schema_id#&amp;feature_data_id=#row.feature_data_id#&amp;feature_data_parent_id=#row.feature_data_parent_id#")#">Unarchive</a> ');
					}else{
						echo('<a href="#application.zcore.functions.zURLAppend(ms.struct.archiveURL, "feature_schema_id=#row.feature_schema_id#&amp;feature_data_id=#row.feature_data_id#&amp;feature_data_parent_id=#row.feature_data_parent_id#")#" onclick="archiveSchemaRecord(this); return false;">Archive</a> ');
					}
					hasMultipleEditFeatures=true;
				}
				echo('</div>');
			}
			if(hasMultipleEditFeatures){
				echo(editHTML);
			}else{
				echo('<a href="#editLink#" onclick="zTableRecordEdit(this);  return false;" class="z-manager-edit" id="z-manager-edit#row.feature_data_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a>');
			}

			echo('</div>');

			if(copyLink NEQ ""){
				echo('<div class="z-manager-button-container"><a href="#copyLink#" class="z-manager-copy" title="Copy"><i class="fa fa-clone" aria-hidden="true"></i></a></div>');
			}
			deleteLink=application.zcore.functions.zURLAppend(ms.struct.deleteURL, "feature_id=#row.feature_id#&feature_schema_id=#row.feature_schema_id#&amp;feature_data_id=#row.feature_data_id#&amp;feature_data_parent_id=#row.feature_data_parent_id#&amp;returnJson=1&amp;confirm=1");
			//zShowModalStandard(this.href, 2000,2000, true, true);
			allowDelete=true;
			if(ms.methodBackup EQ "userManageSchema" or ms.methodBackup EQ "userGetRowHTML"){
				if(ms.mainSchemaStruct.feature_schema_allow_delete_usergrouplist NEQ ""){
					arrUserSchema=listToArray(ms.mainSchemaStruct.feature_schema_allow_delete_usergrouplist, ",");
					allowDelete=false;
					for(i=1;i LTE arraylen(arrUserSchema);i++){
						if(application.zcore.user.checkSchemaIdAccess(arrUserSchema[i])){
							allowDelete=true;
							break;
						}
					}
				}
			}
			if(allowDelete){
				if(ms.methodBackup NEQ "userManageSchema" and ms.methodBackup NEQ "userGetRowHTML" and not application.zcore.functions.zIsForceDeleteEnabled(row.feature_data_override_url) and ms.mainSchemaStruct.feature_schema_enable_locked_delete EQ 0){
					//echo('Delete disabled');
				}else{
					echo('<div class="z-manager-button-container"><a href="##"  onclick="zDeleteTableRecordRow(this, ''#deleteLink#'');  return false;" class="z-manager-delete" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></a></div>');
				}
			}
			if(row.feature_data_copy_id NEQ 0){
				echo('<div class="z-manager-button-container"><a title="This record is a copy of another record" style="padding-top:6px;display:inline-block;">Copy of ###row.feature_data_copy_id#</a></div>');
			}
		}
	}
	return adminHTML;
	</cfscript>
</cffunction>

<cffunction name="userAddSchema" localmode="modern" access="remote"> 
	<cfscript> 
	validateUserSchemaAccess();
	editSchema();
	</cfscript>
</cffunction>

<cffunction name="userEditSchema" localmode="modern" access="remote"> 
	<cfscript> 
	validateUserSchemaAccess();
	editSchema();
	</cfscript>
</cffunction>

<cffunction name="publicEditSchema" localmode="modern" access="remote" roles="public">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicEditSchema";
	this.editSchema(arguments.struct);
	</cfscript>
</cffunction>
<cffunction name="publicAddSchema" localmode="modern" access="remote" roles="public">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicAddSchema";
	this.editSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="addSchema" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.editSchema();
	</cfscript>
</cffunction>

<cffunction name="editSchema" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject; 
	defaultStruct=getDefaultStruct();
	if(not structkeyexists(arguments.struct, 'action')){
		arguments.struct.action='/z/feature/feature-display/insert';	
	}
	if(application.zcore.functions.zso(form, 'feature_schema_id') EQ ""){
		if(application.zcore.user.checkGroupAccess("member")){
			application.zcore.functions.z301redirect("/z/feature/admin/features/index");
		}else{
			application.zcore.functions.z301redirect("/");
		}
	}
	if(structkeyexists(form, 'returnURL') and form.returnURL NEQ ""){
		arguments.struct.returnURL=application.zcore.functions.zso(form, 'returnURL');
	}
	request.zsession.siteSchemaReturnURL=application.zcore.functions.zso(form, 'returnURL');
	if(not structkeyexists(arguments.struct, 'returnURL')){
		arguments.struct.returnURL='/z/feature/feature-display/add?feature_schema_id=#form.feature_schema_id#';	
	}
	variables.init();
	methodBackup=form.method;
	application.zcore.functions.zstatusHandler(request.zsid, true, false, form); 
	form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id');
	form.feature_data_parent_id=application.zcore.functions.zso(form, 'feature_data_parent_id',true);
	 
 
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	application.zcore.functions.zSetModalWindow();
	}
	form.set9=application.zcore.functions.zGetHumanFieldIndex(); 

	form.jumpto=application.zcore.functions.zso(form, 'jumpto');
	db.sql="SELECT * FROM (#db.table("feature_field", request.zos.zcoreDatasource)#, 
	#db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema) 
	WHERE 
	feature_field_deleted = #db.param(0)# and 
	feature_schema_deleted = #db.param(0)# and 
	feature_field.feature_id=#db.param(form.feature_id)# and 
	feature_schema.feature_schema_id = #db.param(form.feature_schema_id)# and 
	feature_schema.feature_schema_id = feature_field.feature_schema_id and 
	feature_schema.feature_schema_type=#db.param('1')# ";
	if(methodBackup EQ "publicAddSchema" or methodBackup EQ "publicEditSchema" or 
		methodBackup EQ "userEditSchema" or methodBackup EQ "userAddSchema"){
		db.sql&=" and feature_field_allow_public=#db.param(1)#";
	}
	db.sql&=" ORDER BY feature_field.feature_field_sort asc, feature_field.feature_field_variable_name ASC";
	qS=db.execute("qS", "", 10000, "query", false);  
	db.sql="SELECT * FROM #db.table("feature_data", request.zos.zcoreDatasource)# WHERE 
	feature_data_deleted = #db.param(0)# and
	feature_data.site_id = #db.param(request.zos.globals.id)# and 
	feature_data_id=#db.param(form.feature_data_id)# and 
	feature_schema_id=#db.param(form.feature_schema_id)# ";
	qData=db.execute("qData");
	if(methodBackup EQ "editSchema" or methodBackup EQ "userEditSchema"){
		if(qData.recordcount EQ 0){
			application.zcore.functions.z404("This Feature Schema no longer exists.");	
		}
	}
	application.zcore.functions.zQueryToStruct(qData, form, "feature_data_parent_id,feature_schema_id,feature_id");
	if(qS.recordcount EQ 0){
		application.zcore.functions.z404("No feature_fields have been set to allow public form data entry.");	
	}

	if(methodBackup EQ "userAddSchema" or methodBackup EQ "userEditSchema"){ 
		arrUserSchema=listToArray(qS.feature_schema_user_group_id_list, ",");
		hasAccess=false;
		for(i=1;i LTE arraylen(arrUserSchema);i++){
			if(application.zcore.user.checkSchemaIdAccess(arrUserSchema[i])){
				hasAccess=true;
				break;
			}
		}
		if(not hasAccess){
			application.zcore.functions.z404("feature_schema_id, #form.feature_schema_id#, doesn't allow public data entry.");
		}
	}

	curParentId=qS.feature_schema_parent_id;
	curParentSetId=form.feature_data_parent_id;  
	
	if(qS.feature_schema_limit NEQ 0){
		if(methodBackup EQ "addSchema"){ 
			db.sql="select site_id from #db.table("feature_data", request.zos.zcoreDatasource)# WHERE 
			site_id=#db.param(request.zos.globals.id)# and 
			feature_id=#db.param(form.feature_id)# and 
			feature_data_deleted=#db.param(0)# and 
			feature_data_parent_id=#db.param(form.feature_data_parent_id)# and 
			feature_schema_id=#db.param(form.feature_schema_id)# ";
			qCountCheck=db.execute("qCountCheck");
			if(qS.feature_schema_limit NEQ 0 and qCountCheck.recordcount GTE qS.feature_schema_limit){
				application.zcore.status.setStatus(request.zsid, "You can't add another record of this type because you've reached the limit.", form, true);
				application.zcore.functions.zRedirect(defaultStruct.listURL&"?zsid=#request.zsid#&feature_schema_id=#form.feature_schema_id#&feature_data_parent_id=#form.feature_data_parent_id#&modalpopforced=#application.zcore.functions.zso(form, 'modalpopforced')#");
			}
		}
	}
	if(methodBackup EQ "userAddSchema" or methodBackup EQ "userEditSchema"){
		currentUserIdValue=request.zsession.user.id&"|"&application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
	}
	// check limit for user if this
	if(qS.feature_schema_user_child_limit NEQ 0){
		if(methodBackup EQ "userAddSchema"){
			db.sql="select site_id from #db.table("feature_data", request.zos.zcoreDatasource)# WHERE 
			site_id=#db.param(request.zos.globals.id)# and 
			feature_id=#db.param(form.feature_id)# and 
			feature_data_deleted=#db.param(0)# and 
			feature_data_parent_id=#db.param(form.feature_data_parent_id)# and 
			feature_schema_id=#db.param(form.feature_schema_id)# and 
			feature_data_user = #db.param(currentUserIdValue)# ";
			qCountCheck=db.execute("qCountCheck");
			if(qS.feature_schema_user_child_limit NEQ 0 and qCountCheck.recordcount GTE qS.feature_schema_user_child_limit){
				application.zcore.status.setStatus(request.zsid, "You can't add another record of this type because you've reached the limit.", form, true);
				application.zcore.functions.zRedirect(defaultStruct.listURL&"?zsid=#request.zsid#&feature_schema_id=#form.feature_schema_id#&feature_data_parent_id=#form.feature_data_parent_id#&modalpopforced=#application.zcore.functions.zso(form, 'modalpopforced')#");
			}
		}
	}

	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id=#db.param(form.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qCheck=db.execute("qCheck");
	if(qCheck.recordcount EQ 0){
		application.zcore.functions.z404("This group doesn't allow public data entry.");	
	}
	if(qCheck.feature_schema_form_description NEQ ""){
		writeoutput(qCheck.feature_schema_form_description);
	}
	if(methodBackup EQ "publicAddSchema" or methodBackup EQ "addSchema" or methodBackup EQ "userAddSchema"){
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
	}
	if(methodBackup EQ "publicAddSchema" or methodBackup EQ "publicEditSchema"){
		// 404 if group doesn't allow public entry
		if(qCheck.feature_schema_allow_public NEQ 1){
			arrUserSchema=listToArray(qCheck.feature_schema_user_group_id_list, ",");
			hasAccess=false;
			for(i=1;i LTE arraylen(arrUserSchema);i++){
				if(application.zcore.user.checkSchemaIdAccess(arrUserSchema[i])){
					hasAccess=true;
					break;
				}
			}
			if(not hasAccess){
				application.zcore.functions.z404("feature_schema_id, #form.feature_schema_id#, doesn't allow public data entry.");
			}
		}
		
		if(qCheck.feature_schema_public_form_title NEQ ""){
			theTitle=qCheck.feature_schema_public_form_title;
		}else if(methodBackup EQ "publicEditSchema"){
			theTitle="Edit "&qCheck.feature_schema_display_name;
		}else{
			theTitle="Add "&qCheck.feature_schema_display_name;
		}
	}else if(methodBackup EQ "addSchema" or methodBackup EQ "userAddSchema"){
		theTitle="Add "&qCheck.feature_schema_display_name;
	}else{
		theTitle="Edit "&qCheck.feature_schema_display_name;
	}
	echo('<div class="z-manager-edit-head">');
		if(application.zcore.template.getTagContent("title") EQ ""){
			application.zcore.template.setTag("title",theTitle);
		}
		if(methodBackup EQ "publicAddSchema" or methodBackup EQ "publicEditSchema"){
			if(application.zcore.template.getTagContent("pagetitle") EQ ""){
				application.zcore.template.setTag("pagetitle",theTitle);
			}
		}else{
			if(application.zcore.template.getTagContent("pagetitle") EQ ""){
				echo('<h2 style="font-weight:normal; color:##369;">#theTitle#</h2>'); 
			}
		}
		arrEnd=arraynew(1);
		</cfscript>
		<script type="text/javascript">
		var zDisableBackButton=true;
		zArrDeferredFunctions.push(function(){
			zDisableBackButton=true;
		});
		</script>
		<cfif methodBackup EQ "publicEditSchema">
			<cfif qSet.feature_data_approved EQ 2>
				<p><strong>Note: Updating this record will re-submit this listing for approval.</strong></p>
			</cfif>
		</cfif>
		<p>* Denotes required field.
		<cfif methodBackup EQ "addSchema" or methodBackup EQ "editSchema">
			 | <a href="/z/feature/admin/feature-schema/help?feature_schema_id=#form.feature_schema_id#" target="_blank">View help in new window.</a>
		</cfif>
		</p>

		<cfif methodBackup EQ "editSchema"> 
			<cfscript> 
			db.sql="select * 
			from #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
			 WHERE 
			feature_schema_deleted = #db.param(0)# and
			feature_schema.feature_schema_parent_id = #db.param(form.feature_schema_id)# and 
			feature_schema.feature_id=#db.param(form.feature_id)#";
			q1=db.execute("q1", "", 10000, "query", false); 
			sortEnabled=true;
			subgroupRecurseEnabled=false;
			subgroupStruct={}; 
			for(n in q1){
				subgroupStruct[n.feature_schema_id]=n;
			}
			 

			if(q1.recordcount NEQ 0){
				echo('<h3 style="font-weight:normal; color:##369;">Edit Sub-groups</h3>');
				echo('<p>This record has additional records attached to it. Click the following link(s) to view/edit them.</p>');
				echo('<ul>');
				for(var n in q1){
					if(structkeyexists(subgroupStruct, n.feature_schema_id)){
						echo('<li><a href="#application.zcore.functions.zURLAppend(defaultStruct.listURL, "feature_schema_id=#n.feature_schema_id#&amp;feature_data_parent_id=#form.feature_data_id#")#" target="_top">#subgroupStruct[n.feature_schema_id].feature_schema_display_name#</a></li>');
					}
				}
				echo('</ul>');

				echo('<h3>or Edit Current Record Below</h3>'); 
			}
			</cfscript>
		</cfif>

	</div>


	<div class="z-manager-edit-errors z-float"></div>
	<cfscript>
	form.mergeRecord=application.zcore.functions.zso(form, "mergeRecord", true, 0);
	echo('<form class="zFormCheckDirty" id="siteSchemaForm#qCheck.feature_schema_id#" action="');
	if(methodBackup EQ "publicAddSchema" or methodBackup EQ "publicEditSchema"){
		echo(arguments.struct.action);
	}else{
		echo('/z/feature/admin/features/');
		if(methodBackup EQ "userAddSchema"){
			echo('userInsertSchema');
		}else if(methodBackup EQ "userEditSchema"){
			echo('userUpdateSchema');
		}else if(methodBackup EQ "addSchema"){
			echo('insertSchema');
		}else{
			echo('updateSchema');
		}
	} 
	echo('" method="post" enctype="multipart/form-data" ');
	if(qCheck.feature_schema_public_thankyou_url NEQ ""){
		echo(' data-thank-you-url="'&htmleditformat(qCheck.feature_schema_public_thankyou_url)&'" ');
	}
	if(methodBackup EQ "publicAddSchema" or methodBackup EQ "publicEditSchema"){
		echo('onsubmit="zSet9(''zset9_#form.set9#''); ');
		if(methodBackup EQ "publicAddSchema" and qCheck.feature_schema_ajax_enabled EQ 1){
			echo('zSiteSchemaPostForm(''siteSchemaForm#qCheck.feature_schema_id#''); return false;');
		}
		echo('"');
	}else if(methodBackup EQ "addSchema" or methodBackup EQ "userAddSchema" or methodBackup EQ "editSchema" or methodBackup EQ "userEditSchema"){
		echo(' onsubmit=" return zSubmitManagerEditForm(this);  " ');
	}
	echo('>');
	</cfscript>
		<cfif application.zcore.functions.zso(form, 'zRefererURL') NEQ "">
			<input type="hidden" name="zRefererURL" id="zRefererURL" value="#htmleditformat(form.zRefererURL)#" />
		</cfif>
		<cfif methodBackup EQ "publicAddSchema" or methodBackup EQ "publicEditSchema">
			<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
			#application.zcore.functions.zFakeFormFields()#
		</cfif>
		<input type="hidden" name="disableSorting" value="#application.zcore.functions.zso(form, 'disableSorting', true, 0)#" />
		<cfif methodBackup EQ "addSchema" or methodBackup EQ "userAddSchema">
			<input type="hidden" name="mergeRecord" value="#htmleditformat(form.mergeRecord)#" />
		</cfif>
		<input type="hidden" name="feature_id" value="#htmleditformat(form.feature_id)#" />
		<input type="hidden" name="feature_schema_id" value="#htmleditformat(form.feature_schema_id)#" />
		<input type="hidden" name="feature_data_id" value="#htmleditformat(form.feature_data_id)#" />
		<input type="hidden" name="feature_data_parent_id" value="#htmleditformat(form.feature_data_parent_id)#" />
		<table style="border-spacing:0px;" class="table-list">

			<cfscript>
			cancelLink="#defaultStruct.listURL#?feature_id=#form.feature_id#&feature_schema_id=#form.feature_schema_id#&amp;feature_data_parent_id=#form.feature_data_parent_id#";
			if(methodBackup EQ "editSchema" and form.feature_data_master_set_id NEQ 0){
				cancelLink="/z/feature/admin/feature-deep-copy/versionList?feature_id=#form.feature_id#&feature_data_id=#form.feature_data_master_set_id#";
			}
			</cfscript>
			<cfif methodBackup EQ "addSchema" or methodBackup EQ "editSchema" or 
			methodBackup EQ "userEditSchema" or methodBackup EQ "userAddSchema">
				<tr><td colspan="2">
					<div class="tabWaitButton zSiteOptionGroupWaitDiv" style="float:left; padding:5px; display:none; ">Please wait...</div>
					<button type="submit" name="submitForm" class="z-manager-search-button tabSaveButton zSiteOptionGroupSubmitButton"><cfif qCheck.feature_schema_enable_merge_interface EQ 1 and (methodBackup EQ "addSchema" or methodBackup EQ "userAddSchema")>Next<cfelse>Save</cfif></button>
						&nbsp;
						<cfif form.modalpopforced EQ 1>
							<cfif form.mergeRecord EQ 1>
								<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.location.reload();">Cancel</button>
							<cfelse>
								<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.zCloseModal();">Cancel</button>
							</cfif>
						<cfelse>
							<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href='#cancelLink#';">Cancel</button>
						</cfif>
					</td></tr>
			</cfif>
	
			<cfscript>
			var row=0;
			var currentRowIndex=0;
			var typeStruct={};
			var dataStruct={};
			var labelStruct={};
			posted=false;
			valueStruct=application.zcore.featureCom.parseFieldData(form);
			for(row in qS){
				if(form.jumpto EQ "soid_#application.zcore.functions.zurlencode(row.feature_field_variable_name,"_")#"){
					jumptoanchor="soid_#row.feature_field_id#";
				}
				if(not structkeyexists(form, "newvalue"&row.feature_field_id)){
					if(structkeyexists(form, row.feature_field_variable_name)){
						posted=true;
						form["newvalue"&row.feature_field_id]=form[row.feature_field_variable_name];
					}else{
						if(valueStruct[row.feature_field_variable_name] NEQ ""){
							form["newvalue"&row.feature_field_id]=valueStruct[row.feature_field_variable_name];
						}else{
							form["newvalue"&row.feature_field_id]=row.feature_field_default_value;
						}
					}
				}else{
					posted=true;
				}
				form[row.feature_field_variable_name]=form["newvalue"&row.feature_field_id];
				if(form.feature_data_id EQ ""){
					if(not structkeyexists(form, "newvalue"&row.feature_field_id)){
						form["newvalue"&row.feature_field_id]=row.feature_field_default_value;
					}
				}
				typeStruct[row.feature_field_id]=deserializeJson(row.feature_field_type_json);
				var currentCFC=application.zcore.featureCom.getTypeCFC(row.feature_field_type_id); 
				dataStruct=currentCFC.onBeforeListView(row, typeStruct[row.feature_field_id], form);
				if(methodBackup EQ "addSchema" and not posted and not currentCFC.isCopyable()){
					form["newvalue"&row.feature_field_id]='';
				}
				value=currentCFC.getListValue(dataStruct, typeStruct[row.feature_field_id], form["newvalue"&row.feature_field_id]);
				if(value EQ ""){
					value=row.feature_field_default_value;
				}
				labelStruct[row.feature_field_variable_name]=value;
			}
			var currentRowIndex=0;
			for(row in qS){
				currentRowIndex++;
			
				var currentCFC=application.zcore.featureCom.getTypeCFC(row.feature_field_type_id);
				var rs=currentCFC.getFormField(row, typeStruct[row.feature_field_id], 'newvalue', form);
				if(rs.hidden){
					arrayAppend(arrEnd, '<input type="hidden" name="feature_field_id" value="'&row.feature_field_id&'" />');
					arrayAppend(arrEnd, rs.value);
				}else{
					writeoutput('<tr class="siteFieldFormField#qS.feature_field_id# ');
					if(currentRowIndex MOD 2 EQ 0){
						writeoutput('row1');
					}else{
						writeoutput('row2');
					}
					writeoutput('">');
					if(rs.label and row.feature_field_hide_label EQ 0){
						if(row.feature_field_label_on_top EQ 1){
							//<th style="vertical-align:top; ">&nbsp;</th>
							echo('
							<td colspan="2">');
							echo('<div style="padding-bottom:0px;float:left; width:100%;">'&application.zcore.functions.zOutputToolTip(row.feature_field_display_name, row.feature_field_tooltip)&'<a id="soid_#row.feature_field_id#" style="display:block; float:left;"></a> ');

							if(row.feature_field_required and row.feature_field_hide_label EQ 0){
								writeoutput(' <span style="font-size:80%;">*</span> ');
							} 
							echo('</div>'); 

						}else{
							tdOutput="";
							if(row.feature_field_small_width EQ 1){
								tdOutput=' width:1%; white-space:nowrap; ';
							}
							writeoutput('<th style="vertical-align:top;#tdOutput#"><div style="padding-bottom:0px;float:left;">'&application.zcore.functions.zOutputToolTip(row.feature_field_display_name, row.feature_field_tooltip)&'<a id="soid_#row.feature_field_id#" style="display:block; float:left;"></a> ');

							if(row.feature_field_required and row.feature_field_hide_label EQ 0){
								writeoutput(' <span style="font-size:80%;">*</span> ');
							} 
							echo('</div></th>
							<td style="vertical-align:top; "><input type="hidden" name="feature_field_id" value="#htmleditformat(row.feature_field_id)#" />');
						}
					}else{
						if(row.feature_field_type_id EQ 11){
							writeoutput('<td style="vertical-align:top; padding-top:15px; padding-bottom:0px;" colspan="2">');
						}else{
							writeoutput('<td style="vertical-align:top; padding-top:5px;" colspan="2">');
						}
						if(rs.label){
							writeoutput('<input type="hidden" name="feature_field_id" value="#htmleditformat(row.feature_field_id)#" />');
						}
					}
					if(row.feature_field_readonly EQ 1 and labelStruct[row.feature_field_variable_name] NEQ ""){
						echo('<div class="zHideReadOnlyField" id="zHideReadOnlyField#currentRowIndex#">'&rs.value);
					}else{
						echo(rs.value);
					}
				} 
				requiredEnabled=true;
				if(application.zcore.functions.zso(typeStruct[row.feature_field_id], 'selectmenu_multipleselection', true, 0) EQ 1 or application.zcore.functions.zso(typeStruct[row.feature_field_id], 'checkbox_values') NEQ ""){
					requiredEnabled=false;
				} 

				if(requiredEnabled and row.feature_field_required and row.feature_field_hide_label EQ 1){
					writeoutput(' <span style="font-size:80%;">*</span> ');
				}  
				if(row.feature_field_type_id EQ 3){ 
					if(structkeyexists(valueStruct, row.feature_field_variable_name) and valueStruct[row.feature_field_variable_name] NEQ ""){
						arrValue=listToArray(valueStruct[row.feature_field_variable_name], chr(9), true);
						if(arrayLen(arrValue) EQ 2 and arrValue[2] NEQ ""){
							echo('<p><a href="/zupload/feature-options/#arrValue[2]#" target="_blank">View Original Image</a></p>');
						}
					}
				}

				if(row.feature_field_readonly EQ 1){// and labelStruct[row.feature_field_variable_name] NEQ ""){
					echo('</div>');
					echo('<div id="zReadOnlyButton#currentRowIndex#" class="zReadOnlyButton">#labelStruct[row.feature_field_variable_name]#');
					if(labelStruct[row.feature_field_variable_name] NEQ ""){
						echo('<hr />');
					}
					echo('<strong>Read only value</strong> | <a href="##" class="zEditReadOnly" data-readonlyid="zReadOnlyButton#currentRowIndex#" data-fieldid="zHideReadOnlyField#currentRowIndex#">Edit Anyway</a></div> ')
				}
				if(rs.label){
					writeoutput('</td>');	
					writeoutput('</tr>');
				}
			}

			if(methodBackup EQ 'addSchema'){ 
				if(not posted){
					form.feature_data_override_url='';
					qData={ recordcount: 0};
					form.feature_data_image_library_id='';
				}
			}
			</cfscript>
			<cfset tempIndex=qS.recordcount+1>
			<cfif methodBackup NEQ "publicAddSchema" and methodBackup NEQ "publicEditSchema" and methodBackup NEQ "userAddSchema" and methodBackup NEQ "userEditSchema">
				<cfif qCheck.feature_schema_enable_approval EQ 1>
					<cfscript>
					if(methodBackup EQ 'addSchema'){
						form.feature_data_approved=1;
					}
					</cfscript>
					<tr class="siteFieldFormField#qS.feature_field_id# <cfif tempIndex MOD 2 EQ 0>row1<cfelse>row2</cfif>">
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Approved?</div></th>
					<td style="vertical-align:top; ">
						<cfscript>
						ts = StructNew();
						ts.name = "feature_data_approved";
						ts.labelList = "Approved|Pending|Deactivated By User|Rejected";
						ts.valueList = "1|0|2|3";
						ts.delimiter="|";
						ts.output=true;
						ts.struct=form;
						writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
						</cfscript>
					</td>
					</tr>
					<cfset tempIndex++>
				</cfif>

				<cfif qS.feature_schema_enable_meta EQ "1">
		 
					<tr <cfif tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Meta Title:</div></th>
					<td style="vertical-align:top; white-space: nowrap;"><input type="text" style="width:95%;" maxlength="255" name="feature_data_metatitle" value="#htmleditformat(application.zcore.functions.zso(form, 'feature_data_metatitle'))#" /> 
					</td>
					</tr>
					<tr <cfif tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Meta Keywords:</div></th>
					<td style="vertical-align:top; white-space: nowrap;"><input type="text" style="width:95%;" maxlength="255" name="feature_data_metakey" value="#htmleditformat(application.zcore.functions.zso(form, 'feature_data_metakey'))#" /> 
					</td>
					</tr>
					<tr <cfif tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Meta Description:</div></th>
					<td style="vertical-align:top; white-space: nowrap;"><input type="text" style="width:95%;" maxlength="255" name="feature_data_metadesc" value="#htmleditformat(application.zcore.functions.zso(form, 'feature_data_metadesc'))#" /> 
					</td>
					</tr>
				</cfif>

				<cfif qS.feature_schema_is_home_page EQ 0 and qS.feature_schema_enable_unique_url EQ 1 and methodBackup NEQ "userAddSchema" and methodBackup NEQ "userEditSchema">
					<tr <cfif tempIndex MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Override URL:</div></th>
					<td style="vertical-align:top; "> 

						<cfif form.method EQ "publicAddSchema" or form.method EQ "addSchema">
							#application.zcore.functions.zInputUniqueUrl("feature_data_override_url", true)#
						<cfelse>
							#application.zcore.functions.zInputUniqueUrl("feature_data_override_url")# 
						</cfif>
					</td>
					</tr>
					<cfset tempIndex++>
				</cfif>
			</cfif>
			<cfif qS.feature_schema_enable_image_library EQ 1>
				<tr class="siteFieldFormField#qS.feature_field_id# <cfif tempIndex MOD 2 EQ 0>row1<cfelse>row2</cfif>">
				<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">Image Library:</div></th>
				<td style="vertical-align:top;">
					<cfscript>
					ts=structnew();
					ts.name="feature_data_image_library_id";
					ts.value=application.zcore.functions.zso(form, 'feature_data_image_library_id', true);
					ts.allowPublicEditing=true;
					application.zcore.imageLibraryCom.getLibraryForm(ts);
					
					</cfscript>
				</td>
				</tr>
				<cfset tempIndex++>
			</cfif> 
			<cfif qS.feature_schema_enable_public_captcha EQ 1 and (methodBackup EQ "publicAddSchema" or methodBackup EQ "publicEditSchema")>
				<tr class="siteFieldFormField#qS.feature_field_id# <cfif tempIndex MOD 2 EQ 0>row1<cfelse>row2</cfif>">
				<th style="vertical-align:top;"><div style="padding-bottom:0px;float:left;">&nbsp;</div></th>
				<td style="vertical-align:top; ">
				#application.zcore.functions.zDisplayRecaptcha()#
				</td>
				</tr>
				<cfset tempIndex++>
			</cfif>


			<cfif qCheck.feature_schema_enable_merge_interface EQ 1 and (methodBackup EQ "addSchema" or methodBackup EQ "userAddSchema")>
				</table>
				<cfscript>
				if(qCheck.feature_schema_merge_group_id NEQ "0"){
					mergeGroupId=qCheck.feature_schema_merge_group_id;
				}else{
					mergeGroupId=qCheck.feature_schema_id;
				}
				db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# 
				WHERE feature_schema_deleted=#db.param(0)# and 
				feature_schema_parent_id=#db.param(mergeGroupId)# 
				ORDER BY feature_schema_display_name ASC";
				qChildSchema=db.execute("qChildSchema", "", 10000, "query", false); 
				categoryStruct={};
				hasImagePreview=false;
				for(row in qChildSchema){
					if(row.feature_schema_preview_image NEQ ""){
						hasImagePreview=true;
					}
					if(row.feature_schema_category NEQ ""){
						categoryStruct[row.feature_schema_category]="";
					}
				}
				arrCategory=structkeyarray(categoryStruct);
				arraySort(arrCategory, "text", "asc");
				</cfscript>

				<div style="width:100%; float:left; padding-top:5px; padding-bottom:5px;">
					<div style="width:100%; padding-left:5px;" class="z-t-18">
						Select A Record Type *
					</div>
					<div style="float:left; padding:5px;">
						<strong>Search</strong> | Name: <input type="text" name="featureNameSearch" id="featureNameSearch" value="">  
						Category: 
						<select size="1" name="featureCategorySearch" id="featureCategorySearch"><option value="">-- Select --</option>
							<cfscript>
							for(categoryName in arrCategory){
								echo('<option value="#htmleditformat(categoryName)#">#categoryName#</option>');
							}
							</cfscript>
						</select>
					</div>
					<!--- <div style="float:left; padding:5px;">
						<input type="submit" name="search1" value="Search" class="z-manager-search-button">
					</div> --->
				</div>
				<input type="hidden" name="feature_data_merge_schema_id" id="feature_data_merge_schema_id" value="">
				<div id="lightboxChildContainer" style="width:100%; padding:5px; float:left;" class="z-equal-heights">
					<cfscript> 
					for(row in qChildSchema){
						echo('<div class="childSchemaBox" data-name="#htmleditformat(row.feature_schema_display_name)#" data-category="#htmleditformat(row.feature_schema_category)#">');
						if(hasImagePreview){
							echo('
							<div class="z-float z-index-2" style="padding:5px;">
								<div style="display:inline-block; float:left;" data-schema-id="#row.feature_schema_id#" class="childSchemaLink">Select</div>');
								if(row.feature_schema_preview_image NEQ ""){
									echo('<a href="/zupload/feature-options/#row.feature_schema_preview_image#" target="_blank" style="display:inline-block; float:right;" data-schema-id="#row.feature_schema_id#" class="childSchemaLink lightboxChildPreview">Preview</a>');
								}
							echo('</div>');
							echo('<div class="z-index-1"  style="margin-top:-32px; display:block; width:100%; float:left; margin-bottom:5px; height:120px; text-align:center; background-color:##000;');
							if(row.feature_schema_preview_image NEQ ""){
								echo(' background-image:url(/zupload/feature-options/#row.feature_schema_preview_image#); ');
							}
							echo(' background-size:cover;"></div>');
							echo('<div class="z-float " style="padding:5px;">#row.feature_schema_display_name#</div>');
						}else{
							echo('<div class="z-float " style="padding:5px;">#row.feature_schema_display_name#</div>
							<div class="z-float z-text-center" style="padding-bottom:5px;"><div style="display:inline-block; " data-schema-id="#row.feature_schema_id#" class="childSchemaLink">Select</div></div>');
						}
						echo('</div>');
					}
					</cfscript>
				</div>
				<cfscript>
				if(hasImagePreview){
					application.zcore.functions.zSetupLightbox("lightboxChildContainer", "lightboxChildPreview");
				}
				</cfscript>
				<style>
				.childSchemaLink, .childSchemaLink:link, .childSchemaLink:visited{ cursor:pointer; display:block; text-decoration:none; background-color:##FFF; border:1px solid ##999; color:##000 !important; border-radius:5px; padding:2px; font-weight:bold; }
				.childSchemaLink:hover{ background-color:##000; color:##FFF !important;}
				.childSchemaBox{width:200px; overflow:hidden; float:left; margin-right:10px; margin-bottom:10px; border-radius:10px; border:2px solid ##DDD; background-color:##FFF; text-align:center; color:##000;}
				.childSchemaBox:hover{
					background-color:##DFEFCF;
				}
				.childSchemaBox.selected{ background-color:##369;border:2px solid ##369;  color:##FFF;}
				</style>
				<script>
				zArrDeferredFunctions.push(function(){
					$(".childSchemaLink").on("click", function(e){
						e.preventDefault();
						$(".childSchemaBox").removeClass("selected");
						$(this).parent().parent().addClass("selected");
						$("##feature_data_merge_schema_id").val($(this).attr("data-schema-id"));
					});
					$("##featureNameSearch, ##featureCategorySearch").on("keyup paste change", function(){
						var name=$("##featureNameSearch").val();
						var category=$("##featureCategorySearch").val(); 
						$(".childSchemaBox").each(function(){
							if(name != "" && $(this).attr("data-name").indexOf(name) == -1){
								$(this).hide();
								return;
							}
							if(category != "" && $(this).attr("data-category") != category){
								$(this).hide();
								return;
							}
							$(this).show();
						});
					});
				});
				</script>
 
				<table class="table-list"> 
			</cfif>
			<tr>
				<td colspan="2">
				<cfif qS.feature_schema_is_home_page EQ 1>
					<input type="hidden" name="feature_data_override_url" value="/" />
				</cfif>
				#arraytolist(arrEnd, '')#
				<cfif qS.feature_schema_enable_unique_url EQ 1 and (methodBackup EQ "userAddSchema" or methodBackup EQ "userEditSchema")>
					<input type="hidden" name="feature_data_override_url" value="#application.zcore.functions.zso(form, 'feature_data_override_url')#" />
				</cfif>
				<cfif form.modalpopforced EQ 1>
					<input type="hidden" name="modalpopforced" value="1" />
				</cfif>
	
				<cfif methodBackup EQ "publicAddSchema" or methodBackup EQ "publicEditSchema">
					<button type="submit" name="submitForm" class="zSiteSchemaSubmitButton">Submit</button>
					<div class="zSiteSchemaWaitDiv" style="display:none; float:left; padding:5px; margin-right:5px;">Please Wait...</div>
					<cfif structkeyexists(arguments.struct, 'cancelURL')>
						<button type="button" name="cancel1" onclick="window.location.href='#htmleditformat(arguments.struct.cancelURL)#';">Cancel</button>
					</cfif>
					&nbsp;&nbsp; <a href="/z/user/privacy/index" target="_blank" class="zPrivacyPolicyLink">Privacy Policy</a>
					    <cfif form.modalpopforced EQ 1>
							<input type="hidden" name="js3811" id="js3811" value="" />
							<input type="hidden" name="js3812" id="js3812" value="#application.zcore.functions.zGetFormHashValue()#" />
					    </cfif>
				<cfelse>
					<div class="tabWaitButton zSiteOptionGroupWaitDiv" style="float:left; padding:5px; display:none; ">Please wait...</div>
					<button type="submit" name="submitForm" class="z-manager-search-button tabSaveButton zSiteOptionGroupSubmitButton"><cfif qCheck.feature_schema_enable_merge_interface EQ 1 and (methodBackup EQ "addSchema" or methodBackup EQ "userAddSchema")>Next<cfelse>Save</cfif></button>
						&nbsp;
						<cfif form.modalpopforced EQ 1>
							<cfif form.mergeRecord EQ 1>
								<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.location.reload();">Cancel</button>
							<cfelse>
								<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.zCloseModal();">Cancel</button>
							</cfif>
						<cfelse>

							<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href='#cancelLink#';">Cancel</button>
						</cfif>
				</cfif>
				</td>
			</tr>
		</table>
	</form>
	<cfscript> 
	if(qCheck.feature_schema_bottom_form_description NEQ ""){
		echo(qCheck.feature_schema_bottom_form_description);
	}
	</cfscript>
	<div style="width:100%; <cfif form.feature_schema_id EQ "">min-height:1000px; </cfif> float:left; clear:both;"></div>
	<cfif structkeyexists(form, 'jumptoanchor')>
		<script type="text/javascript">
		/* <![CDATA[ */
		var d1=document.getElementById("#form.jumptoanchor#");
		var p=zGetAbsPosition(d1);
		window.scrollTo(0, p.y);
		/* ]]> */
		</script>
	</cfif>
</cffunction>


<cffunction name="autoDeleteSchema" localmode="modern" access="public" roles="member">
	<cfscript>
	form.method="autoDeleteSchema";
	form.confirm=1;
	form.feature_id=0;
	this.deleteSchema();
	</cfscript>
</cffunction>


<cffunction name="publicDeleteSchema" localmode="modern" access="public" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	form.method="publicDeleteSchema";
	this.deleteSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="getDefaultStruct" localmode="modern" access="public">
	<cfscript>  
	if(left(form.method, 4) EQ "user"){

		defaultStruct={
			versionURL:"",///z/feature/admin/feature-deep-copy/userVersionList",
			copyURL:"",///z/feature/admin/feature-deep-copy/user",
			addURL:"/z/feature/admin/features/userAddSchema",
			editURL:"/z/feature/admin/features/userEditSchema", 
			deleteURL:"/z/feature/admin/features/userDeleteSchema",
			insertURL:"/z/feature/admin/features/userInsertSchema",
			updateURL:"/z/feature/admin/features/userUpdateSchema",
			listURL:"/z/feature/admin/features/userManageSchema",
			getRowURL:"/z/feature/admin/features/userGetRowHTML",
			archiveURL:"/z/feature/admin/features/userArchiveSchema",
			unarchiveURL:"/z/feature/admin/features/userUnarchiveSchema"
		};
	}else{
		defaultStruct={
			versionURL:"/z/feature/admin/feature-deep-copy/versionList",
			copyURL:"/z/feature/admin/feature-deep-copy/index",
			addURL:"/z/feature/admin/features/addSchema",
			editURL:"/z/feature/admin/features/editSchema",
			deleteURL:"/z/feature/admin/features/deleteSchema",
			insertURL:"/z/feature/admin/features/insertSchema",
			updateURL:"/z/feature/admin/features/updateSchema",
			listURL:"/z/feature/admin/features/manageSchema",
			errorURL:"/z/feature/admin/features/index",
			getRowURL:"/z/feature/admin/features/getRowHTML",
			archiveURL:"/z/feature/admin/features/archiveSchema",
			unarchiveURL:"/z/feature/admin/features/unarchiveSchema"
		};
	}
	return defaultStruct;
</cfscript>
</cffunction>

<cffunction name="userArchiveSchema" localmode="modern" access="remote"> 
	<cfscript>
	validateUserSchemaAccess(); 
	this.archiveSchema();
	</cfscript>
</cffunction>

<cffunction name="userUnarchiveSchema" localmode="modern" access="remote">
	<cfscript>
	validateUserSchemaAccess(); 
	this.unarchiveSchema();
	</cfscript>
</cffunction>

<cffunction name="archiveSchema" localmode="modern" access="remote"> 
	<cfscript>
	var db=request.zos.queryObject;
	init();
	form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id', true);
	form.feature_data_parent_id=application.zcore.functions.zso(form, 'feature_data_parent_id', true);
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id', true);
	db.sql="update #db.table("feature_data", request.zos.zcoreDatasource)# SET 
	feature_data_archived=#db.param(1)# 
	WHERE 
	site_id=#db.param(request.zos.globals.id)# and 
	feature_data_deleted=#db.param(0)# and 
	feature_id=#db.param(form.feature_id)# and 
	feature_data_id=#db.param(form.feature_data_id)# ";
	db.execute("qUpdate");

	application.zcore.functions.zReturnJson({success:true}); 
	</cfscript>
</cffunction>

<cffunction name="unarchiveSchema" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	init();
	form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id', true);
	form.feature_data_parent_id=application.zcore.functions.zso(form, 'feature_data_parent_id', true);
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id', true);
	db.sql="update #db.table("feature_data", request.zos.zcoreDatasource)# SET 
	feature_data_archived=#db.param(0)# 
	WHERE 
	site_id=#db.param(request.zos.globals.id)# and 
	feature_data_deleted=#db.param(0)# and 
	feature_id=#db.param(form.feature_id)# and 
	feature_data_id=#db.param(form.feature_data_id)# ";
	db.execute("qUpdate");

	application.zcore.status.setStatus(request.zsid, "Record unarchived.");
	if(form.method EQ "userUnarchiveSchema"){
		application.zcore.functions.zRedirect("/z/feature/admin/features/userManageSchema?feature_schema_id=#form.feature_schema_id#&feature_data_id=#form.feature_data_id#&feature_data_parent_id=#form.feature_data_parent_id#");
	}else{
		application.zcore.functions.zRedirect("/z/feature/admin/features/manageSchema?feature_schema_id=#form.feature_schema_id#&feature_data_id=#form.feature_data_id#&feature_data_parent_id=#form.feature_data_parent_id#");
	}
	</cfscript>
</cffunction>

<cffunction name="userDeleteSchema" localmode="modern" access="remote" roles="user">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript> 
	validateUserSchemaAccess();
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css"); 
	deleteSchema(arguments.struct);
	</cfscript>
</cffunction>

<cffunction name="deleteSchema" localmode="modern" access="remote" roles="member">
	<cfargument name="struct" type="struct" required="no" default="#{}#">
	<cfscript>
	var db=request.zos.queryObject; 
	setting requesttimeout="100000";

	defaultStruct=getDefaultStruct();
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	//if(form.method EQ "deleteSchema"){
		form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
		if(form.modalpopforced EQ 1){
			application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
			application.zcore.functions.zSetModalWindow();
		}
	//}
	structappend(arguments.struct, defaultStruct, false);
	
	variables.init();
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id');
	form.feature_data_id=application.zcore.functions.zso(form, 'feature_data_id');
	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema, 
	#db.table("feature_data", request.zos.zcoreDatasource)# feature_data WHERE
	feature_schema_deleted = #db.param(0)# and 
	feature_data_deleted = #db.param(0)# and 
	feature_schema.feature_schema_id = feature_data.feature_schema_id and 
	feature_data_id= #db.param(form.feature_data_id)# and 
	feature_schema.feature_schema_id= #db.param(form.feature_schema_id)# and 
	feature_data.site_id= #db.param(request.zos.globals.id)#";
	if(form.method EQ "userDeleteSchema" and request.isUserPrimarySchema){
		currentUserIdValue=request.zsession.user.id&"|"&application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
		db.sql&=" and feature_data_user = #db.param(currentUserIdValue)# ";
	}
	qCheck=db.execute("qCheck", "", 10000, "query", false);
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Feature Schema is missing");
		if(form.method EQ "autoDeleteSchema"){
			return false;
		}else{
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.listURL, "feature_id="&qCheck.feature_id&"&feature_schema_id="&form.feature_schema_id&"&feature_data_parent_id=#form.feature_data_parent_id#&zsid="&request.zsid));
		}
	} 

	if(form.method EQ "userDeleteSchema"){ 
		allowDelete=true;
		if(qCheck.feature_schema_allow_delete_usergrouplist NEQ ""){
			arrUserSchema=listToArray(qCheck.feature_schema_allow_delete_usergrouplist, ",");
			allowDelete=false;
			for(i=1;i LTE arraylen(arrUserSchema);i++){
				if(application.zcore.user.checkSchemaIdAccess(arrUserSchema[i])){
					allowDelete=true;
					break;
				}
			}
		} 
		if(not allowDelete){
			application.zcore.functions.z404("user delete is disabled for feature_schema_id, #form.feature_schema_id#.");
		}
		arrUserSchema=listToArray(qCheck.feature_schema_user_group_id_list, ",");
		hasAccess=false;
		for(i=1;i LTE arraylen(arrUserSchema);i++){
			if(application.zcore.user.checkSchemaIdAccess(arrUserSchema[i])){
				hasAccess=true;
				break;
			}
		}
		if(not hasAccess){
			application.zcore.functions.z404("feature_schema_id, #form.feature_schema_id#, doesn't allow public data entry.");
		}
	}

	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		if(form.method EQ "userDeleteSchema"){ 
			if(qCheck.feature_schema_change_email_usergrouplist NEQ ""){
				newAction='deleted'; 
				application.zcore.featureCom.sendChangeEmail(qCheck.feature_data_id, newAction);
			}
		}
		for(row in qCheck){
			application.zcore.featureCom.deleteSchemaSetRecursively(row.feature_data_id, row.site_id, row);
		}
 
		if(qCheck.feature_schema_enable_sorting EQ 1){
			queueSortStruct = StructNew();
			queueSortStruct.tableName = "feature_data";
			queueSortStruct.sortFieldName = "feature_data_sort";
			queueSortStruct.primaryKeyName = "feature_data_id";
			queueSortStruct.datasource=request.zos.zcoreDatasource;
			
			queueSortStruct.where =" feature_data.feature_id = '#application.zcore.functions.zescape(form.feature_id)#' and  
			feature_schema_id = '#application.zcore.functions.zescape(form.feature_schema_id)#' and 
			site_id = '#request.zos.globals.id#' and 
			feature_data_master_set_id = '0' and 
			feature_data_deleted='0' ";
			
			queueSortStruct.disableRedirect=true;
			queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
			r1=queueSortCom.init(queueSortStruct);
			queueSortCom.sortAll();
		}
		if((request.zos.enableSiteOptionGroupCache and qCheck.feature_schema_enable_cache EQ 1) or (qCheck.feature_schema_enable_versioning EQ 1 and qCheck.feature_data_master_set_id NEQ 0)){
			application.zcore.featureCom.deleteSchemaSetIdCache(qCheck.feature_id, request.zos.globals.id, form.feature_data_id);
		}
		application.zcore.status.setStatus(request.zsid, "Deleted successfully.");
		if(form.method EQ "autoDeleteSchema"){
			return true;
		}else if(form.returnJson EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else if(qcheck.feature_data_master_set_id NEQ 0){
			application.zcore.functions.zRedirect("/z/feature/admin/feature-deep-copy/versionList?feature_data_id=#qcheck.feature_data_master_set_id#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect(application.zcore.functions.zURLAppend(arguments.struct.listURL, "feature_id="&form.feature_id&"&feature_schema_id="&form.feature_schema_id&"&feature_data_parent_id=#form.feature_data_parent_id#&zsid="&request.zsid));
		}
        	</cfscript>
	<cfelse>
		<cfscript>
		theTitle="Delete Schema";
		application.zcore.template.setTag("title",theTitle);
		application.zcore.template.setTag("pagetitle",theTitle);
		</cfscript>
		<h2>
		Are you sure you want to delete this data?<br />
		<br />
		#qcheck.feature_schema_display_name# 		<br />
		ID## #form.feature_data_id# <br />
		<br />
		<cfscript>
		if(qcheck.feature_data_master_set_id NEQ 0){
			deleteLink="/z/feature/admin/feature-deep-copy/versionList?feature_data_id=#qcheck.feature_data_master_set_id#";
		}else{
			deleteLink="#application.zcore.functions.zURLAppend(arguments.struct.listURL, "feature_schema_id=#form.feature_schema_id#&amp;feature_data_parent_id=#form.feature_data_parent_id#")#";
		}
		</cfscript>
		<a href="#application.zcore.functions.zURLAppend(arguments.struct.deleteURL, "feature_id=#form.feature_id#&amp;confirm=1&amp;feature_data_id=#form.feature_data_id#&amp;feature_schema_id=#form.feature_schema_id#&amp;feature_data_parent_id=#form.feature_data_parent_id#")#">Yes</a>&nbsp;&nbsp;&nbsp;<a href="#deleteLink#">No</a>
	</cfif>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	variables.init();
	application.zcore.functions.zSetPageHelpId("2.11");
	application.zcore.functions.zStatusHandler(request.zsid); 
	form.jumpto=application.zcore.functions.zso(form, 'jumpto'); 
	theTitle="Features";
	application.zcore.template.setTag("title",theTitle);
	application.zcore.template.setTag("pagetitle",theTitle);
	db.sql="SELECT feature_schema.*, count(feature_data.feature_schema_id) childCount 
	FROM #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
	LEFT JOIN #db.table("feature_data", request.zos.zcoreDatasource)# feature_data ON 
	feature_data.site_id=#db.param(request.zos.globals.id)# and 
	feature_data_master_set_id = #db.param(0)# and 
	feature_data.feature_schema_id = feature_schema.feature_schema_id and  
	feature_data_deleted = #db.param(0)# 
	WHERE  
	feature_schema_deleted = #db.param(0)# and
	feature_schema_parent_id = #db.param('0')# and 
	feature_schema_type =#db.param('1')# and  
	feature_schema.feature_schema_disable_admin=#db.param(0)#
	GROUP BY feature_schema.feature_schema_id 
	ORDER BY feature_schema.feature_schema_display_name ASC ";
	qSchema=db.execute("qSchema");
	if(qSchema.recordcount NEQ 0){
		writeoutput('<h2>Theme Features</h2>
		<table style="border-spacing:0px;" class="table-list">
			<tr>
				<th>Feature</th>
				<th>Sub-Feature</th>
				<th>Admin</th>
			</tr>');
		var row=0;
		for(row in qSchema){
			writeoutput('<tr ');
			if(qSchema.currentRow MOD 2 EQ 0){
				writeoutput('class="row2"');
			}else{
				writeoutput('class="row1"');
			}
			writeoutput('>
				<td>#application.zcore.featureCom.getFeatureNameById(qSchema.feature_id)#</td>
				<td>#qSchema.feature_schema_display_name#</td>
				<td><a href="/z/feature/admin/features/manageSchema?feature_id=#qSchema.feature_id#&feature_schema_id=#qSchema.feature_schema_id#" class="z-manager-search-button">List/Edit</a> ');
				// TODO: need to verify if import works before enabling
					 // <a href="/z/feature/admin/features/import?feature_id=#qSchema.feature_id#&feature_schema_id=#qSchema.feature_schema_id#" class="z-manager-search-button">Import</a> ');
				
					if(qSchema.feature_schema_allow_public NEQ 0){
						writeoutput(' ');
						if(qSchema.feature_schema_public_form_url NEQ ""){
							writeoutput('<a href="#htmleditformat(qSchema.feature_schema_public_form_url)#" target="_blank" class="z-manager-search-button">Public Form</a> ');
						}else{
							writeoutput('<a href="/z/feature/feature-display/add?feature_schema_id=#qSchema.feature_schema_id#" target="_blank" class="z-manager-search-button">Public Form</a> ');
						}
					}
					if(qSchema.feature_schema_limit EQ 0 or qSchema.childCount LT qSchema.feature_schema_limit){
						writeoutput(' <a href="/z/feature/admin/features/addSchema?feature_id=#qSchema.feature_id#&feature_schema_id=#qSchema.feature_schema_id#" class="z-manager-search-button">Add</a>');
					}else{
						writeoutput(' Limit Reached');
					}
					writeoutput('</td>
			</tr>');
		}
		writeoutput('</table>
		<br />');
	} 
	</cfscript>
</cffunction>
 
</cfoutput>
</cfcomponent>
