<cfcomponent>
<cfoutput>


<cffunction name="updateSchemaCache" access="public" localmode="modern">
	<cfscript>
	db=request.zos.queryObject; 
	db.sql="SELECT feature_x_site.site_id, feature_schema.feature_id, feature_schema.feature_schema_id 
	FROM #db.table("feature_schema", request.zos.zcoreDatasource)#
	LEFT JOIN #db.table("feature_x_site", request.zos.zcoreDatasource)# ON 
	feature_x_site.feature_id = feature_schema.feature_id and 
	feature_x_site.site_id<>#db.param(-1)# and 
	feature_x_site_deleted=#db.param(0)# 
	WHERE #application.zcore.featureCom.filterSiteFeatureSQL(db, "feature_schema")# and 
	feature_schema_deleted = #db.param(0)# 
	ORDER BY feature_schema_parent_id asc";
	qS=db.execute("qS");  
	for(row in qS){
		if(structkeyexists(application.siteStruct, row.site_id)){
			internalUpdateSchemaCacheBySchemaId(application.siteStruct[row.site_id].globals, row.feature_id, row.feature_schema_id);
		}
	} 
	</cfscript>
</cffunction>

<!--- application.zcore.featureCom.updateSchemaCacheBySchemaId(feature_id, feature_schema_id); --->
<cffunction name="updateSchemaCacheBySchemaId" access="public" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="feature_schema_id" type="string" required="yes">
	<cfscript>
	rebuildFeatureStructCache(arguments.feature_id, application.zcore);
	internalUpdateSchemaCacheBySchemaId(application.siteStruct[request.zos.globals.id].globals,  arguments.feature_id, arguments.feature_schema_id);
	application.zcore.functions.zCacheJsonSiteAndUserGroup(request.zos.globals.id, application.zcore.siteGlobals[request.zos.globals.id]);
	</cfscript>
</cffunction>

<cffunction name="rebuildFeaturesCache" localmode="modern" access="public">
	<cfargument name="cacheStruct" type="struct" required="yes">
	<cfargument name="rebuildSchemaCache" type="boolean" required="yes">
	<cfscript>	
	db=request.zos.queryObject; 
	try{
		db.sql="select * from #db.table("feature", request.zos.zcoreDatasource)# where 
		feature_deleted=#db.param(0)#";
		qFeature=db.execute("qFeature");
	}catch(Any e){
		// ignore missing feature table for first time upgrade
		return;
	}
	if(not structkeyexists(arguments.cacheStruct.featureData, "featureIdLookup")){
		arguments.cacheStruct.featureData.featureIdLookup={};
		arguments.cacheStruct.featureData.featureDataLookup={};
	}
	for(row in qFeature){
		arguments.cacheStruct.featureData.featureIdLookup[row.feature_variable_name]=row.feature_id;
		arguments.cacheStruct.featureData.featureDataLookup[row.feature_id]=row;
		if(arguments.rebuildSchemaCache){
			rebuildFeatureStructCache(row.feature_id, arguments.cacheStruct); 
		}
	}
	</cfscript>
</cffunction>

<!--- 
application.zcore.featureCom.rebuildFeatureStructCache(form.feature_id, cacheStruct);
 --->
<cffunction name="rebuildFeatureStructCache" access="public" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="cacheStruct" type="struct" required="yes">
	<cfscript> 
	db=request.zos.queryObject;
	featureData={};
	featureData.fieldLookup=structnew();
	featureData.fieldIdLookup=structnew();
	featureData.featureSchemaFieldLookup=structnew();
	featureData.featureSchemaLookup=structnew();
	featureData.featureSchemaIdLookup=structnew();
	featureData.featureSchemaDefaults=structnew();
	fs=featureData; 

	 db.sql="SELECT * FROM #db.table("feature_field", request.zos.zcoreDatasource)# 
	WHERE  
	feature_id=#db.param(arguments.feature_id)# and 
	feature_field_deleted = #db.param(0)#";
	qS=db.execute("qS");
// 	if(arguments.feature_id EQ 4){
// 	writedump(QS);abort;
// }
	for(row in qS){
		fs.fieldLookup[row.feature_field_id]=row;
		structappend(fs.fieldLookup[row.feature_field_id], {
			name:row.feature_field_variable_name,
			type:row.feature_field_type_id,
			typeStruct:{}
		});
		fs.fieldLookup[row.feature_field_id].typeStruct=deserializeJson(row.feature_field_type_json);
		if(not structkeyexists(fs.featureSchemaDefaults, row.feature_schema_id)){
			fs.featureSchemaDefaults[row.feature_schema_id]={};
		}
		fs.featureSchemaDefaults[row.feature_schema_id][row.feature_field_variable_name]=row.feature_field_default_value;
		fs.fieldIdLookup[row.feature_schema_id&chr(9)&row.feature_field_variable_name]=row.feature_field_id;
		if(row.feature_schema_id NEQ 0){
			if(structkeyexists(fs.featureSchemaFieldLookup, row.feature_schema_id) EQ false){
				fs.featureSchemaFieldLookup[row.feature_schema_id]=structnew();
			}
			fs.featureSchemaFieldLookup[row.feature_schema_id][row.feature_field_id]=true;
		}
	}
	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE  
	feature_id=#db.param(arguments.feature_id)# and 
	feature_schema_deleted = #db.param(0)#";
	qSchema=db.execute("qSchema");  
	for(row in qSchema){
		row.count=0;
		fs.featureSchemaLookup[row.feature_schema_id]=row;
		fs.featureSchemaIdLookup[row.feature_schema_parent_id&chr(9)&row.feature_schema_variable_name]=row.feature_schema_id;
	}
	if(not structkeyexists(arguments.cacheStruct.featureData, "featureSchemaData")){
		arguments.cacheStruct.featureData.featureSchemaData={};
	}
	arguments.cacheStruct.featureData.featureSchemaData[arguments.feature_id]=fs;
	</cfscript>
</cffunction>

<cffunction name="internalUpdateSchemaCacheBySchemaId" access="public" localmode="modern">
	<cfargument name="siteStruct" type="struct" required="yes">
	<cfargument name="feature_id" type="string" required="no" default="">
	<cfargument name="feature_schema_id" type="string" required="no" default="">
	<cfscript> 
	db=request.zos.queryObject;
	featureSchemaData={};
	featureSchemaData.featureSchemaSetVersion={};
	featureSchemaData.featureSchemaSetId=structnew();
	featureSchemaData.featureSchemaSet=structnew();
	featureSchemaData.featureSchemaSetArrays=structnew(); 
	featureSchemaData.featureSchemaSetQueryCache={};
	fs=featureSchemaData;
	site_id=arguments.siteStruct.id;
	feature_schema_id=arguments.feature_schema_id;
 
 	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id];
	
	fs.featureSchemaSetId[0&"_groupId"]=0;
	fs.featureSchemaSetId[0&"_parentId"]=0;
	fs.featureSchemaSetId[0&"_featureId"]=0;
	fs.featureSchemaSetId[0&"_childSchema"]=structnew();
	if(not structkeyexists(fsd.featureSchemaLookup, arguments.feature_schema_id)){
		throw("fsd.featureSchemaLookup didn't have the arguments.feature_schema_id, #arguments.feature_schema_id# - caching is incomplete.");
	}
	featureSchema=fsd.featureSchemaLookup[arguments.feature_schema_id];

	if(request.zos.enableSiteOptionGroupCache and featureSchema.feature_schema_enable_cache EQ 1){ 
		cacheEnabled=true;
	}else{
		cacheEnabled=false;
	}
	if(featureSchema.feature_schema_enable_versioning EQ 1){
		versioningEnabled=true;
	}else{
		versioningEnabled=false;
	}
	if(versioningEnabled or cacheEnabled){
		db.sql="SELECT s1.* 
		FROM #db.table("feature_data", request.zos.zcoreDatasource)# s1   
		WHERE s1.site_id = #db.param(site_id)#  and 
		s1.feature_data_deleted = #db.param(0)# and 
		feature_data_master_set_id = #db.param(0)# and ";
		if(cacheEnabled){
			db.sql&=" (s1.feature_data_master_set_id = #db.param(0)# or s1.feature_data_version_status = #db.param(1)#) and ";
		}else if(versioningEnabled){
			db.sql&=" (s1.feature_data_master_set_id <> #db.param(0)# and s1.feature_data_version_status = #db.param(1)#) and ";
		}else{
			db.sql&=" #db.param(1)# = #db.param(0)# and ";
		}
		db.sql&=" s1.feature_schema_id = #db.param(feature_schema_id)# 
		ORDER BY s1.feature_data_parent_id ASC, s1.feature_data_sort ASC "; 
		qS=db.execute("qS"); 
		tempUniqueStruct=structnew();
		

		arrVersionSetId=[];
		for(row in qS){
			id=row.feature_data_id;
			if(row.feature_data_master_set_id NEQ 0){
				arrayAppend(arrVersionSetId, id);
			}
			if(structkeyexists(fs.featureSchemaSetId, id) EQ false){
				if(structkeyexists(fs.featureSchemaSetId, id&"_appId") EQ false){
					fs.featureSchemaSetId[id&"_groupId"]=row.feature_schema_id;
					fs.featureSchemaSetId[id&"_appId"]=row.feature_id;
					fs.featureSchemaSetId[id&"_parentId"]=row.feature_data_parent_id;
					fs.featureSchemaSetId[id&"_childSchema"]=structnew();
				}
				if(structkeyexists(fs.featureSchemaSetId, row.feature_data_parent_id&"_childSchema")){
					if(structkeyexists(fs.featureSchemaSetId[row.feature_data_parent_id&"_childSchema"], row.feature_schema_id) EQ false){
						fs.featureSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id]=arraynew(1);
					}
					// used for looping all sets in the group
					if(structkeyexists(tempUniqueStruct, row.feature_data_parent_id&"_"&id) EQ false){ 
						arrayappend(fs.featureSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id], id);
						tempUniqueStruct[row.feature_data_parent_id&"_"&id]=true;
					}
				}
			} 
			if(cacheEnabled or (versioningEnabled and arraylen(arrVersionSetId))){
				arrField=listToArray(row.feature_data_field_order, chr(13), true);
				arrData=listToArray(row.feature_data_data, chr(13), true);
				for(i=1;i<=arraylen(arrField);i++){
					fieldId=arrField[i];
					value=arrData[i];
					id=row.feature_data_id;
					if(structkeyexists(fsd.fieldLookup, fieldId)){
						var typeId=fsd.fieldLookup[fieldId].type;
						if(typeId EQ 2){
							if(value EQ ""){
								tempValue="";
							}else{
								tempValue='<div class="zEditorHTML">'&value&'</div>';
							}
						}else if(typeId EQ 3){
							arrValue=listToArray(value, chr(9), true);
							if(arrValue[1] NEQ ""){
								typeStruct=fsd.fieldLookup[fieldId].typeStruct;
								if(application.zcore.functions.zso(typeStruct, 'file_securepath') EQ "Yes"){
									tempValue="/zuploadsecure/feature-options/"&arrValue[1];
								}else{
									tempValue="/zupload/feature-options/"&arrValue[1];
								}
							}else{
								tempValue="";
							}
							// original image
							if(arrayLen(arrValue) EQ 2 and arrValue[2] NEQ ""){
								fs.featureSchemaSetId["__original "&id&"_f"&fieldId]="/zupload/feature-options/"&arrValue[2];
							}else{
								fs.featureSchemaSetId["__original "&id&"_f"&fieldId]="";
							}
						}else if(typeId EQ 9){
							if(value NEQ ""){
								typeStruct=fsd.fieldLookup[fieldId].typeStruct;
								if(application.zcore.functions.zso(typeStruct, 'file_securepath') EQ "Yes"){
									tempValue="/zuploadsecure/feature-options/"&value;
								}else{
									tempValue="/zupload/feature-options/"&value;
								}
							}else{
								tempValue="";
							}
						}else{
							tempValue=value;
						}
						fs.featureSchemaSetId[id&"_f"&fieldId]=tempValue; 
					} 
				}


				// if(cacheEnabled){
				fs.featureSchemaSetQueryCache[row.feature_data_id]=row;
				// }
				if(structkeyexists(fs.featureSchemaSetArrays, row.feature_schema_id&chr(9)&row.feature_data_parent_id) EQ false){
					fs.featureSchemaSetArrays[row.feature_schema_id&chr(9)&row.feature_data_parent_id]=arraynew(1);
				}
				ts=structnew();
				ts.__sort=row.feature_data_sort;
				ts.__setId=row.feature_data_id;
				ts.__dateModified=row.feature_data_updated_datetime;
				ts.__schemaId=row.feature_schema_id;
				ts.__level=row.feature_data_level;
				ts.__mergeSchemaId=fsd.featureSchemaLookup[row.feature_schema_id].feature_schema_merge_group_id;
				ts.__approved=row.feature_data_approved;
				ts.__createdDatetime=row.feature_data_created_datetime;
				ts.__title=row.feature_data_title;
				ts.__parentID=row.feature_data_parent_id;
				ts.__summary=row.feature_data_summary;
				// build url
				if(row.feature_data_image_library_id NEQ 0){
					ts.__image_library_id=row.feature_data_image_library_id;
				}
				if(featureSchema.feature_schema_enable_unique_url EQ 1){
					if(row.feature_data_override_url NEQ ""){
						ts.__url=row.feature_data_override_url;
					}else{
						ts.__url="/#application.zcore.functions.zURLEncode(row.feature_data_title, '-')#-50-#row.feature_data_id#.html";
					}
				} 
				if(structkeyexists(fsd.featureSchemaDefaults, row.feature_schema_id)){
					defaultStruct=fsd.featureSchemaDefaults[row.feature_schema_id];
				}else{
					defaultStruct={};
				}
				if(structkeyexists(fs.featureSchemaSetId, ts.__setId&"_groupId")){
					groupId=fs.featureSchemaSetId[ts.__setId&"_groupId"];
					if(structkeyexists(fsd.featureSchemaFieldLookup, groupId)){
						fieldStruct=fsd.featureSchemaFieldLookup[groupId];
					
						for(i2 in fieldStruct){
							cf=fsd.fieldLookup[i2];
							if(structkeyexists(fs.featureSchemaSetId, "__original "&ts.__setId&"_f"&i2)){
								ts["__original "&cf.name]=fs.featureSchemaSetId["__original "&ts.__setId&"_f"&i2];
							}
							if(structkeyexists(fs.featureSchemaSetId, ts.__setId&"_f"&i2)){
								ts[cf.name]=fs.featureSchemaSetId[ts.__setId&"_f"&i2];
							}else if(structkeyexists(defaultStruct, cf.name)){
								ts[cf.name]=defaultStruct[cf.name];
							}else{
								ts[cf.name]="";
							}
						}
					}
				}
				fs.featureSchemaSet[row.feature_data_id]= ts;
				if(row.feature_data_master_set_id NEQ 0){
					if(structkeyexists(fs.featureSchemaSet, row.feature_data_master_set_id)){
						masterStruct=fs.featureSchemaSet[row.feature_data_master_set_id];
						ts.__sort=masterStruct.__sort;
						if(featureSchema.feature_schema_enable_unique_url EQ 1){
							ts.__url=masterStruct.__url;
						}
					}
					fs.featureSchemaSetVersion[row.feature_data_master_set_id]=ts.__setId;
				}else{
					arrayappend(fs.featureSchemaSetArrays[ts.__schemaId&chr(9)&row.feature_data_parent_id], ts);
				}
			}
		}
	} 



	if(not structkeyexists(arguments.siteStruct, 'featureSchemaData')){
		arguments.siteStruct.featureSchemaData={};
	} 
	for(i in fs){
		if(not structkeyexists(arguments.siteStruct.featureSchemaData, i)){
			arguments.siteStruct.featureSchemaData[i]={};
		}
		structappend(arguments.siteStruct.featureSchemaData[i], fs[i], true);
	} 
	</cfscript>
</cffunction>
 


<cffunction name="resortSchemaSets" localmode="modern" access="public">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="feature_id" type="numeric" required="yes">
	<cfargument name="feature_schema_id" type="numeric" required="yes">
	<cfargument name="feature_data_parent_id" type="numeric" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id]; 
	var groupStruct=fsd.featureSchemaLookup[arguments.feature_schema_id];
	rs=application.zcore.featureCom.getSortedData(arguments.feature_schema_id);
	var arrTemp=[];
	sortStruct={};
	for(i=1;i<=arraylen(rs.arrOrder);i++){
		db.sql="update #db.table("feature_data", request.zos.zcoreDatasource)#
		set 
		feature_data_sort=#db.param(i)#, 
		feature_data_level=#db.param(rs.arrLevel[i])# 
		WHERE 
		feature_data.feature_data_id=#db.param(rs.arrOrder[i].row.feature_data_id)# and 
		feature_data.site_id=#db.param(request.zos.globals.id)# and 
		feature_data.feature_data_deleted=#db.param(0)#";
		db.execute("qUpdate");
		arrayAppend(arrTemp, rs.arrOrder[i].row.feature_data_id);
		sortStruct[rs.arrOrder[i].row.feature_data_id]=i;

		if(groupStruct.feature_schema_change_cfc_path NEQ ""){
			path=groupStruct.feature_schema_change_cfc_path;
			if(left(path, 5) EQ "root."){
				path=request.zRootCFCPath&removeChars(path, 1, 5);
			}
			changeCom=application.zcore.functions.zcreateObject("component", path); 
			changeCom[groupStruct.feature_schema_change_cfc_sort_method](row.feature_data_id, i); 
		} 
	}
 

	if(groupStruct.feature_schema_enable_cache EQ "1"){
		t9=application.zcore.featureCom.getSiteData(arguments.site_id);
		t9.featureSchemaSetId[arguments.feature_data_parent_id&"_childSchema"][arguments.feature_schema_id]=arrTemp;

		arrData=t9.featureSchemaSetArrays[arguments.feature_schema_id&chr(9)&arguments.feature_data_parent_id];
		arrDataNew=[];
		for(i=1;i LTE arraylen(arrData);i++){
			sortIndex=sortStruct[arrData[i].__setId];
			arrDataNew[sortIndex]=arrData[i];
		}
		t9.featureSchemaSetArrays[arguments.feature_schema_id&chr(9)&arguments.feature_data_parent_id]=arrDataNew;	
	}
	</cfscript>
</cffunction>
	
<cffunction name="updateSchemaSetIdCache" localmode="modern" access="public">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="feature_data_id" type="numeric" required="yes">
	<cfscript>
	var row=0;
	var tempValue=0;
	var db=request.zos.queryObject;
	var debug=false;
	var startTime=gettickcount(); 

	t9=application.zcore.featureCom.getSiteData(arguments.site_id);

	db.sql="SELECT * FROM 
	#db.table("feature_data", request.zos.zcoreDatasource)# s1 WHERE 
	s1.site_id = #db.param(arguments.site_id)# and 
	feature_data_master_set_id = #db.param(0)# and 
	s1.feature_data_deleted = #db.param(0)# and 
	s1.feature_data_id = #db.param(arguments.feature_data_id)#";
	var qS=db.execute("qS", "", 10000, "query", false);  
	if(qS.recordcount EQ 0){
		throw("feature_data_id, #arguments.feature_data_id#, doesn't exist.");
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-3<br>'); startTime=gettickcount();
	if(debug) writedump(qS);

	fsd=application.zcore.featureData.featureSchemaData[qS.feature_id];

	fieldStruct={};
	if(qS.feature_data_field_order NEQ ""){
		arrFieldOrder=listToArray(qS.feature_data_field_order, chr(13), true);
		arrFieldData=listToArray(qS.feature_data_data, chr(13), true);
		for(i=1;i<=arraylen(arrFieldOrder);i++){
			fieldStruct[arrFieldOrder[i]]=arrFieldData[i];
		}
	}

	db.sql="SELECT *
	FROM #db.table("feature_field", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id=#db.param(qS.feature_schema_id)# and 
	feature_field_deleted = #db.param(0)# 
	ORDER BY feature_field_sort ASC ";
	var qField=db.execute("qField", "", 10000, "query", false);

	if(debug) writedump(qField);
	var tempUniqueStruct=structnew();
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-1<br>'); startTime=gettickcount();
	var newRecord=false;
	fsd=application.zcore.featureData.featureSchemaData[qS.feature_id]; 
	for(row in qField){
		var id=qS.feature_data_id;
		if(structkeyexists(t9.featureSchemaSetId, id&"_appId") EQ false){
			newRecord=true;
			t9.featureSchemaSetId[id&"_groupId"]=row.feature_schema_id;
			t9.featureSchemaSetId[id&"_appId"]=row.feature_id;
			t9.featureSchemaSetId[id&"_parentId"]=qS.feature_data_parent_id;
			t9.featureSchemaSetId[id&"_childSchema"]=structnew();
		}
		schemaStruct=fsd.featureSchemaLookup[row.feature_schema_id];
		if(qS.feature_data_master_set_id EQ 0 and structkeyexists(t9.featureSchemaSetId, qS.feature_data_parent_id&"_childSchema")){
			if(structkeyexists(t9.featureSchemaSetId[qS.feature_data_parent_id&"_childSchema"], row.feature_schema_id) EQ false){
				t9.featureSchemaSetId[qS.feature_data_parent_id&"_childSchema"][row.feature_schema_id]=arraynew(1);
			}
			if(schemaStruct.feature_schema_enable_sorting EQ 1){
				if(structkeyexists(tempUniqueStruct, qS.feature_data_parent_id&"_"&id) EQ false){
					var arrChild=t9.featureSchemaSetId[qS.feature_data_parent_id&"_childSchema"][row.feature_schema_id];
					var resort=false;
					if(qS.feature_data_sort EQ 0){
						resort=true;
					}else if(arrayLen(arrChild) LT qS.feature_data_sort){
						resort=true;
					}else if(arrayLen(arrChild) GTE qS.feature_data_sort){
						if(arrChild[qS.feature_data_sort] NEQ id){
							resort=true;
						}
					}else{
						resort=true;
					} 
					//writedump(resort);
					if(resort){
						db.sql="select feature_data_id from #db.table("feature_data", request.zos.zcoreDatasource)#
						WHERE 
						feature_data_deleted = #db.param(0)# and 
						feature_data_master_set_id = #db.param(0)# and 
						feature_data_parent_id= #db.param(qS.feature_data_parent_id)# and 
						feature_schema_id = #db.param(row.feature_schema_id)# and 
						feature_id = #db.param(row.feature_id)# and 
						site_id = #db.param(arguments.site_id)# 
						ORDER BY feature_data_sort";
						var qSort=db.execute("qSort");
						var arrTemp=[];
						for(var row2 in qSort){
							arrayAppend(arrTemp, row2.feature_data_id);
						}
						t9.featureSchemaSetId[qS.feature_data_parent_id&"_childSchema"][row.feature_schema_id]=arrTemp;
					}
					//writedump(t9.featureSchemaSetId[qS.feature_data_parent_id&"_childSchema"][row.feature_schema_id]);
					tempUniqueStruct[qS.feature_data_parent_id&"_"&id]=true;
				}
			}else if(newRecord){
				// if i get an undefined error here, it is probably because memory caching is disable on the parent feature_schema_id
				var arrChild=t9.featureSchemaSetId[qS.feature_data_parent_id&"_childSchema"][row.feature_schema_id];
				var found=false;
				for(var i=1;i LTE arrayLen(arrChild);i++){
					if(qS.feature_data_id EQ arrChild[i]){
						found=true;
						break;
					}
				}
				if(not found){
					arrayAppend(arrChild, qS.feature_data_id);
				}
			}
		}
		fieldValue="";
		if(structkeyexists(fieldStruct, row.feature_field_id)){
			fieldValue=fieldStruct[row.feature_field_id];
		}
		if(row.feature_field_type_id EQ 2){
			if(fieldValue EQ ""){
				tempValue="";
			}else{
				tempValue='<div class="zEditorHTML">'&fieldValue&'</div>';
			}
		}else if(row.feature_field_type_id EQ 3){
			arrValue=listToArray(fieldValue, chr(9), true); 
			if(arrValue[1] NEQ ""){
				typeStruct=fsd.fieldLookup[row.feature_field_id].typeStruct;
				if(application.zcore.functions.zso(typeStruct, 'file_securepath') EQ "Yes"){
					tempValue="/zuploadsecure/feature-options/"&arrValue[1];
				}else{
					tempValue="/zupload/feature-options/"&arrValue[1];
				}
			}else{
				tempValue="";
			}
			if(arrayLen(arrValue) EQ 2 and arrValue[2] NEQ ""){
				t9.featureSchemaSetId["__original "&id&"_f"&row.feature_field_id]="/zupload/feature-options/"&arrValue[2];
			}else{
				t9.featureSchemaSetId["__original "&id&"_f"&row.feature_field_id]="";
			}
		}else if(row.feature_field_type_id EQ 9){
			if(fieldValue NEQ "" and fieldValue NEQ "0"){
				typeStruct=fsd.fieldLookup[row.feature_field_id].typeStruct;
				if(application.zcore.functions.zso(typeStruct, 'file_securepath') EQ "Yes"){
					tempValue="/zuploadsecure/feature-options/"&fieldValue;
				}else{
					tempValue="/zupload/feature-options/"&fieldValue;
				}
			}else{
				tempValue="";
			}
		}else{
			tempValue=fieldValue;
		}
		t9.featureSchemaSetId[id&"_f"&row.feature_field_id]=tempValue;
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-2<br>'); startTime=gettickcount();
	for(row in qS){
		if(not structkeyexists(t9, 'featureSchemaSetQueryCache')){
			t9.featureSchemaSetQueryCache={};
		}
		if(request.zos.enableSiteOptionGroupCache and schemaStruct.feature_schema_enable_cache EQ 1){
			t9.featureSchemaSetQueryCache[row.feature_data_id]=row;
		}
		if(structkeyexists(t9.featureSchemaSetArrays, row.feature_schema_id&chr(9)&row.feature_data_parent_id) EQ false){
			t9.featureSchemaSetArrays[row.feature_schema_id&chr(9)&row.feature_data_parent_id]=arraynew(1);
		}
		var ts=structnew();
		ts.__sort=row.feature_data_sort;
		ts.__setId=row.feature_data_id;
		ts.__dateModified=row.feature_data_updated_datetime;
		ts.__schemaId=row.feature_schema_id;
		ts.__level=row.feature_data_level;
		ts.__mergeSchemaId=schemaStruct.feature_schema_merge_group_id;
		ts.__createdDatetime=row.feature_data_created_datetime;
		ts.__approved=row.feature_data_approved;
		ts.__title=row.feature_data_title;
		ts.__parentID=row.feature_data_parent_id;
		ts.__summary=row.feature_data_summary;
		// build url
		if(row.feature_data_image_library_id NEQ 0){
			ts.__image_library_id=row.feature_data_image_library_id;
		}
		if(schemaStruct.feature_schema_enable_unique_url EQ 1){
			if(row.feature_data_override_url NEQ ""){
				ts.__url=row.feature_data_override_url;
			}else{
				ts.__url="/#application.zcore.functions.zURLEncode(row.feature_data_title, '-')#-50-#row.feature_data_id#.html";
			}
		} 
		var fieldStruct=fsd.featureSchemaFieldLookup[ts.__schemaId];
		
		var defaultStruct=fsd.featureSchemaDefaults[row.feature_schema_id];
		for(var i2 in fieldStruct){
			var cf=fsd.fieldLookup[i2];
			if(structkeyexists(t9.featureSchemaSetId, "__original "&ts.__setId&"_f"&i2)){
				ts["__original "&cf.name]=t9.featureSchemaSetId["__original "&ts.__setId&"_f"&i2];
			}
			if(structkeyexists(t9.featureSchemaSetId, ts.__setId&"_f"&i2)){
				ts[cf.name]=t9.featureSchemaSetId[ts.__setId&"_f"&i2];
			}else if(structkeyexists(defaultStruct, cf.name)){
				ts[cf.name]=defaultStruct[cf.name];
			}else{
				ts[cf.name]="";
			}
		}
		if(debug) writedump(ts);
		
		t9.featureSchemaSet[row.feature_data_id]= ts;
		arrChild=[];

		// don't sort versions
		if(row.feature_data_master_set_id EQ 0){
			if(schemaStruct.feature_schema_enable_sorting EQ 1){
				var arrChild=t9.featureSchemaSetArrays[ts.__schemaId&chr(9)&row.feature_data_parent_id];
				var resort=false;
				if(row.feature_data_sort EQ 0){
						resort=true;
				}else if(arrayLen(arrChild) GTE row.feature_data_sort){
					if(arrayLen(arrChild) LT row.feature_data_sort){
						resort=true;
					}else if(arrChild[row.feature_data_sort].__setId NEQ row.feature_data_id){
						resort=true;
					}else{ 
						arrChild[row.feature_data_sort]=ts;
					} 
				}else{
					resort=true;
				} 
				if(resort){  

					if(not structkeyexists(t9.featureSchemaSetId, row.feature_data_parent_id&"_childSchema")){
						t9.featureSchemaSetId[row.feature_data_parent_id&"_childSchema"]={};
					}
					if(not structkeyexists(t9.featureSchemaSetId[row.feature_data_parent_id&"_childSchema"], row.feature_schema_id)){
						t9.featureSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id]=[];
					}
					try{
						var arrChild2=t9.featureSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id];
						var arrTemp=[]; 
						for(var i=1;i LTE arraylen(arrChild2);i++){
							arrayAppend(arrTemp, t9.featureSchemaSet[arrChild2[i]]);
						}
						t9.featureSchemaSetArrays[ts.__schemaId&chr(9)&row.feature_data_parent_id]=arrTemp;
					}catch(Any e){
						updateSchemaCacheBySchemaId(row.feature_id, row.feature_schema_id);
						ts={};
						ts.subject="Feature Schema update resort failed";
						savecontent variable="output"{
							echo('#application.zcore.functions.zHTMLDoctype()#
							<head>
							<meta charset="utf-8" />
							<title>Error</title>
							</head>
							
							<body>');

							writedump(form);
							writedump(e);
							echo('</body>
							</html>');
						}
						ts.html=output;
						ts.to=request.zos.developerEmailTo;
						ts.from=request.zos.developerEmailFrom;
						rCom=application.zcore.email.send(ts);
						if(rCom.isOK() EQ false){
							rCom.setStatusErrors(request.zsid);
							application.zcore.functions.zstatushandler(request.zsid);
							application.zcore.functions.zabort();
						}
					}
				}
			}else{
				var arrChild=t9.featureSchemaSetArrays[ts.__schemaId&chr(9)&row.feature_data_parent_id];
				var found=false;
				for(var i=1;i LTE arrayLen(arrChild);i++){
					if(row.feature_data_id EQ arrChild[i].__setID){
						found=true;
						arrChild[i]=ts;
						break;
					}
				}
				if(not found){
					arrayAppend(arrChild, ts);
				}
			}
		}
	}  
	if(debug and structkeyexists(local, 'arrChild')) writedump(arrChild);
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-4<br>'); startTime=gettickcount();
	application.zcore.functions.zCacheJsonSiteAndUserGroup(arguments.site_id, application.zcore.siteGlobals[arguments.site_id]); 
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-5<br>'); startTime=gettickcount();
	if(debug) application.zcore.functions.zabort();
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>