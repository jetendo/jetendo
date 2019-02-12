<cfcomponent extends="zcorerootmapping.com.app.option-base">
<cfoutput> 
<cffunction name="getFieldTypes" returntype="struct" localmode="modern" access="public">
	<cfscript>
	ts=getFieldTypeCFCs();
	for(i in ts){
		ts[i].init("site", "site");
	}
	return ts;
	</cfscript>
</cffunction>


<cffunction name="getTypeData" returntype="struct" localmode="modern" access="public">
	<cfargument name="site_id" type="string" required="yes" hint="site_id">
	<cfscript>
	return application.siteStruct[arguments.site_id].globals.soSchemaData;
	</cfscript>
</cffunction>
 


 

<cffunction name="updateSchemaCache" access="public" localmode="modern">
	<cfargument name="siteStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject; 
	db.sql="SELECT feature_schema_id FROM #db.table("feature_schema", "jetendofeature")# 
	WHERE site_id =#db.param(arguments.siteStruct.id)# and 
	feature_schema_deleted = #db.param(0)# 
	ORDER BY feature_schema_parent_id asc";
	qS=db.execute("qS"); 
	for(row in qS){
		internalUpdateSchemaCacheBySchemaId(arguments.siteStruct, row.feature_schema_id);
	} 
	</cfscript>
</cffunction>

<!--- application.zcore.siteFieldCom.updateFieldCache(); --->
<cffunction name="updateFieldCache" access="public" localmode="modern"> 
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	siteStruct=application.zcore.functions.zGetSiteGlobals(arguments.site_id); 
	internalUpdateFieldFieldCache(siteStruct);

	application.zcore.functions.zCacheJsonSiteAndUserSchema(arguments.site_id, siteStruct);
	</cfscript>
</cffunction>

<!--- application.zcore.siteFieldCom.updateSchemaCacheBySchemaId(optionSchemaId); --->
<cffunction name="updateSchemaCacheBySchemaId" access="public" localmode="modern">
	<cfargument name="optionSchemaId" type="string" required="yes">
	<cfscript>
	siteStruct=application.zcore.functions.zGetSiteGlobals(request.zos.globals.id);
	internalUpdateSchemaCacheBySchemaId(siteStruct, arguments.optionSchemaId);
	application.zcore.functions.zCacheJsonSiteAndUserSchema(request.zos.globals.id, siteStruct);
	</cfscript>
</cffunction>


<cffunction name="internalUpdateSchemaCacheBySchemaId" access="public" localmode="modern">
	<cfargument name="siteStruct" type="struct" required="yes">
	<cfargument name="groupId" type="string" required="no" default="">
	<cfscript>
	db=request.zos.queryObject;
	tempStruct={};
	tempStruct.soSchemaData={};
	tempStruct.soSchemaData.optionSchemaSetVersion={};
	tempStruct.soSchemaData.optionSchemaFieldLookup=structnew();
	tempStruct.soSchemaData.optionSchemaLookup=structnew();
	tempStruct.soSchemaData.optionSchemaIdLookup=structnew();
	tempStruct.soSchemaData.optionSchemaSetId=structnew();
	tempStruct.soSchemaData.optionSchemaSet=structnew();
	tempStruct.soSchemaData.optionSchemaSetArrays=structnew(); 
	tempStruct.soSchemaData.optionSchemaSetQueryCache={};
	tempStruct.soSchemaData.optionSchemaDefaults=structnew();
	sog=tempStruct.soSchemaData;
	site_id=arguments.siteStruct.id;
	groupId=arguments.groupId;


	 db.sql="SELECT * FROM #db.table("feature_field", "jetendofeature")# feature_field 
	WHERE feature_schema_id=#db.param(groupId)# and  
	feature_field_deleted = #db.param(0)# and 
	site_id = #db.param(site_id)#";
	qS=db.execute("qS");
	for(row in qS){
		sog.optionLookup[row.feature_field_id]=row;
		structappend(sog.optionLookup[row.feature_field_id], {
			edit:row.feature_field_edit_enabled,
			name:row.feature_field_name,
			type:row.feature_field_type_id,
			optionStruct:{}
		});
		sog.optionLookup[row.feature_field_id].optionStruct=deserializeJson(row.feature_field_type_json);
		if(not structkeyexists(sog.optionSchemaDefaults, row.feature_schema_id)){
			sog.optionSchemaDefaults[row.feature_schema_id]={};
		}
		sog.optionSchemaDefaults[row.feature_schema_id][row.feature_field_name]=row.feature_field_default_value;
		sog.optionIdLookup[row.feature_schema_id&chr(9)&row.feature_field_name]=row.feature_field_id;
		if(row.feature_schema_id NEQ 0){
			if(structkeyexists(sog.optionSchemaFieldLookup, row.feature_schema_id) EQ false){
				sog.optionSchemaFieldLookup[row.feature_schema_id]=structnew();
			}
			sog.optionSchemaFieldLookup[row.feature_schema_id][row.feature_field_id]=true;
		}
	}
	db.sql="SELECT * FROM #db.table("feature_schema", "jetendofeature")# feature_schema 
	WHERE site_id =#db.param(site_id)# and 
	feature_schema_id = #db.param(groupId)# and 
	feature_schema_deleted = #db.param(0)#";
	qSchema=db.execute("qSchema"); 
	 
	cacheEnabled=false;
	versioningEnabled=false;
	for(row in qSchema){
		row.count=0;
		sog.optionSchemaLookup[row.feature_schema_id]=row;
		if(request.zos.enableSiteSchemaCache and row.feature_schema_enable_cache EQ 1){ 
			cacheEnabled=true;
		}
		if(row.feature_schema_enable_versioning EQ 1){
			versioningEnabled=true;
		}
		sog.optionSchemaIdLookup[row.feature_schema_parent_id&chr(9)&row.feature_schema_variable_name]=row.feature_schema_id;
	}
	
	sog.optionSchemaSetId[0&"_groupId"]=0;
	sog.optionSchemaSetId[0&"_parentId"]=0;
	sog.optionSchemaSetId[0&"_appId"]=0;
	sog.optionSchemaSetId[0&"_childSchema"]=structnew();

	if(versioningEnabled or cacheEnabled){
		db.sql="SELECT s1.* 
		FROM #db.table("feature_data", "jetendofeature")# s1   
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
		db.sql&=" s1.feature_schema_id = #db.param(groupId)# 
		ORDER BY s1.feature_data_parent_id ASC, s1.feature_data_sort ASC "; 
		qS=db.execute("qS"); 
		tempUniqueStruct=structnew();
		

		arrVersionSetId=[];
		for(row in qS){
			id=row.feature_data_id;
			if(row.feature_data_master_set_id NEQ 0){
				arrayAppend(arrVersionSetId, id);
			}
			if(structkeyexists(sog.optionSchemaSetId, id) EQ false){
				if(structkeyexists(sog.optionSchemaSetId, id&"_appId") EQ false){
					sog.optionSchemaLookup[row.feature_schema_id].count++;
					sog.optionSchemaSetId[id&"_groupId"]=row.feature_schema_id;
					sog.optionSchemaSetId[id&"_appId"]=row.feature_id;
					sog.optionSchemaSetId[id&"_parentId"]=row.feature_data_parent_id;
					sog.optionSchemaSetId[id&"_childSchema"]=structnew();
				}
				if(structkeyexists(sog.optionSchemaSetId, row.feature_data_parent_id&"_childSchema")){
					if(structkeyexists(sog.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"], row.feature_schema_id) EQ false){
						sog.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id]=arraynew(1);
					}
					// used for looping all sets in the group
					if(structkeyexists(tempUniqueStruct, row.feature_data_parent_id&"_"&id) EQ false){ 
						arrayappend(sog.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id], id);
						tempUniqueStruct[row.feature_data_parent_id&"_"&id]=true;
					}
				}
			}
		}
		if(cacheEnabled or (versioningEnabled and arraylen(arrVersionSetId))){
			db.sql="SELECT s3.feature_data_id, s3.feature_field_id groupSetFieldId, 
			s3.site_x_option_group_value groupSetValue , 
			s3.site_x_option_group_original groupSetOriginal 
			FROM #db.table("site_x_option_group", "jetendofeature")# s3 
			WHERE s3.site_id = #db.param(site_id)#  and 
			s3.feature_schema_id = #db.param(groupId)# and 
			s3.site_x_option_group_deleted = #db.param(0)# "; 
			if(not cacheEnabled){
				db.sql&=" and s3.feature_data_id IN (#db.trustedSQL(arrayToList(arrVersionSetId, ', '))#) ";
			}
			qS=db.execute("qS");  
			
			for(row in qS){
				id=row.feature_data_id;
				if(structkeyexists(sog.optionLookup, row.groupSetFieldId)){
					var typeId=sog.optionLookup[row.groupSetFieldId].type;
					if(typeId EQ 2){
						if(row.groupSetValue EQ ""){
							tempValue="";
						}else{
							tempValue='<div class="zEditorHTML">'&row.groupSetValue&'</div>';
						}
					}else if(typeId EQ 3 or typeId EQ 9){
						if(row.groupSetValue NEQ "" and row.groupSetValue NEQ "0"){
							optionStruct=sog.optionLookup[row.groupSetFieldId].optionStruct;
							if(application.zcore.functions.zso(optionStruct, 'file_securepath') EQ "Yes"){
								tempValue="/zuploadsecure/site-options/"&row.groupSetValue;
							}else{
								tempValue="/zupload/site-options/"&row.groupSetValue;
							}
						}else{
							tempValue="";
						}
					}else{
						tempValue=row.groupSetValue;
					}
					sog.optionSchemaSetId[id&"_f"&row.groupSetFieldId]=tempValue; 
					if(typeId EQ 2){
						sog.optionSchemaSetId[id&"_f"&row.groupSetFieldId]=tempValue;
					}else if(typeId EQ 3){
						if(row.groupSetOriginal NEQ ""){
							sog.optionSchemaSetId["__original "&id&"_f"&row.groupSetFieldId]="/zupload/site-options/"&row.groupSetOriginal;
						}else{
							sog.optionSchemaSetId["__original "&id&"_f"&row.groupSetFieldId]=tempValue;
						}
					}
				}
			}
		}


		 db.sql="SELECT * FROM 
		 #db.table("feature_data", "jetendofeature")# s1, 
		 #db.table("feature_schema", "jetendofeature")# s2
		WHERE s1.site_id = #db.param(site_id)# and 
		s1.site_id = s2.site_id and 
		s1.feature_data_deleted = #db.param(0)# and 
		s2.feature_schema_deleted = #db.param(0)# and 
		s2.feature_schema_id = #db.param(groupId)# and ";
		if(cacheEnabled){
			db.sql&=" (s1.feature_data_master_set_id = #db.param(0)# or s1.feature_data_version_status = #db.param(1)#) and ";
		}else{
			db.sql&=" (s1.feature_data_master_set_id <> #db.param(0)# and s1.feature_data_version_status = #db.param(1)#) and ";

		}
		db.sql&=" s1.feature_schema_id = s2.feature_schema_id 
		ORDER BY s1.feature_data_master_set_id asc, s1.feature_data_sort asc";
		qS=db.execute("qS"); 
		for(row in qS){
			if(cacheEnabled){
				sog.optionSchemaSetQueryCache[row.feature_data_id]=row;
			}
			if(structkeyexists(sog.optionSchemaSetArrays, row.feature_id&chr(9)&row.feature_schema_id&chr(9)&row.feature_data_parent_id) EQ false){
				sog.optionSchemaSetArrays[row.feature_id&chr(9)&row.feature_schema_id&chr(9)&row.feature_data_parent_id]=arraynew(1);
			}
			ts=structnew();
			ts.__sort=row.feature_data_sort;
			ts.__setId=row.feature_data_id;
			ts.__dateModified=row.feature_data_updated_datetime;
			ts.__groupId=row.feature_schema_id;
			ts.__approved=row.feature_data_approved;
			ts.__createdDatetime=row.feature_data_created_datetime;
			ts.__title=row.feature_data_title;
			ts.__parentID=row.feature_data_parent_id;
			ts.__summary=row.feature_data_summary;
			// build url
			if(row.feature_data_image_library_id NEQ 0){
				ts.__image_library_id=row.feature_data_image_library_id;
			}
			if(row.feature_schema_enable_unique_url EQ 1){
				if(row.feature_data_override_url NEQ ""){
					ts.__url=row.feature_data_override_url;
				}else{
					ts.__url="/#application.zcore.functions.zURLEncode(row.feature_data_title, '-')#-50-#row.feature_data_id#.html";
				}
			}
			t9=sog;
			if(structkeyexists(t9.optionSchemaDefaults, row.feature_schema_id)){
				defaultStruct=t9.optionSchemaDefaults[row.feature_schema_id];
			}else{
				defaultStruct={};
			}
			if(structkeyexists(t9.optionSchemaSetId, ts.__setId&"_groupId")){
				groupId=t9.optionSchemaSetId[ts.__setId&"_groupId"];
				if(structkeyexists(t9.optionSchemaFieldLookup, groupId)){
					fieldStruct=t9.optionSchemaFieldLookup[groupId];
				
					for(i2 in fieldStruct){
						cf=t9.optionLookup[i2];
						if(structkeyexists(t9.optionSchemaSetId, "__original "&ts.__setId&"_f"&i2)){
							ts["__original "&cf.name]=t9.optionSchemaSetId["__original "&ts.__setId&"_f"&i2];
						}
						if(structkeyexists(t9.optionSchemaSetId, ts.__setId&"_f"&i2)){
							ts[cf.name]=t9.optionSchemaSetId[ts.__setId&"_f"&i2];
						}else if(structkeyexists(defaultStruct, cf.name)){
							ts[cf.name]=defaultStruct[cf.name];
						}else{
							ts[cf.name]="";
						}
					}
				}
			}
			sog.optionSchemaSet[row.feature_data_id]= ts;


			if(row.feature_data_master_set_id NEQ 0){
				if(structkeyexists(sog.optionSchemaSet, row.feature_data_master_set_id)){
					masterStruct=sog.optionSchemaSet[row.feature_data_master_set_id];
					ts.__sort=masterStruct.__sort;
					if(row.feature_schema_enable_unique_url EQ 1){
						ts.__url=masterStruct.__url;
					}
				}
				sog.optionSchemaSetVersion[row.feature_data_master_set_id]=ts.__setId;
			}else{
				arrayappend(sog.optionSchemaSetArrays[row.feature_id&chr(9)&ts.__groupId&chr(9)&row.feature_data_parent_id], ts);
			}
		} 
	}

	if(not structkeyexists(arguments.siteStruct, 'soSchemaData')){
		arguments.siteStruct.soSchemaData={};
	}
	//sog.optionSchemaSetQueryCache={};
	for(i in sog){
		if(not structkeyexists(arguments.siteStruct.soSchemaData, i)){
			arguments.siteStruct.soSchemaData[i]={};
		}
		structappend(arguments.siteStruct.soSchemaData[i], sog[i], true);
	} 
	//arguments.siteStruct.soSchemaData[i].optionSchemaSetQueryCache={};
	</cfscript>
</cffunction>
 
<cffunction name="internalUpdateFieldAndSchemaCache" access="public" localmode="modern">
	<cfargument name="siteStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	tempStruct=arguments.siteStruct;
	site_id=tempStruct.id;
	
	if(not structkeyexists(tempStruct, 'soSchemaData')){
		tempStruct.soSchemaData={};
	} 
	updateSchemaCache(tempStruct);
	</cfscript>
	
</cffunction>


<cffunction name="setFeatureMap" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ms=arguments.struct;
	db=request.zos.queryObject;
	db.sql="SELECT feature_schema.* 
	FROM #db.table("feature_schema", "jetendofeature")# feature_schema  
	WHERE feature_schema.feature_id=#db.param(form.feature_id)# and 
	feature_schema_parent_id = #db.param('0')# and 
	feature_schema_deleted = #db.param(0)# and 
	feature_schema_type =#db.param('1')# and 
	feature_schema.feature_schema_disable_admin=#db.param(0)# 
	ORDER BY feature_schema.feature_schema_display_name ASC ";
	qSchema=db.execute("qSchema"); 
	if(qSchema.recordcount NEQ 0){
		ms["Custom"]={ parent:'', value:'Custom', label: "Custom"};
		// loop the groups
		// get the code from manageoptions"
		// feature_schema_disable_admin=0
		for(row in qSchema){
			ms["Custom: "&row.feature_schema_display_name]={ parent:'Custom', value:"Custom: "&row.feature_schema_display_name, label:chr(9)&row.feature_schema_display_name&chr(10)};
		}
	}
	</cfscript>
</cffunction>



<cffunction name="setURLRewriteStruct" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	ts2=arguments.struct;
	db.sql="select * from #db.table("feature_schema", "jetendofeature")# feature_schema
	WHERE feature_id=#db.param(form.feature_id)# and 
	feature_schema_allow_public=#db.param(1)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_schema_public_form_url<> #db.param('')# ";
	qS=db.execute("qS");
	for(row in qS){
		t9=structnew();
		t9.scriptName="/z/misc/display-site-option-group/add";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/add";
		t9.urlStruct.feature_schema_id=row.feature_schema_id;
		ts2.uniqueURLStruct[trim(row.feature_schema_public_form_url)]=t9;
	}
	ts2.reservedAppUrlIdStruct[50]=[];
	t9=structnew();
	t9.type=1;
	t9.scriptName="/z/misc/display-site-option-group/index";
	t9.urlStruct=structnew();
	t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/index";
	t9.mapStruct=structnew();
	t9.mapStruct.urlTitle="zURLName";
	t9.mapStruct.dataId="feature_data_id";
	arrayappend(ts2.reservedAppUrlIdStruct[50], t9);
	db.sql="select * from #db.table("feature_data", "jetendofeature")# feature_data
	WHERE feature_id=#db.param(form.feature_id)# and 
	feature_data_override_url<> #db.param('')# and 
	feature_data_master_set_id = #db.param(0)# and 
	feature_data_deleted = #db.param(0)# and
	feature_data_approved=#db.param(1)#";
	qS=db.execute("qS");
	for(row in qS){
		t9=structnew();
		t9.scriptName="/z/misc/display-site-option-group/index";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/index";
		t9.urlStruct.feature_data_id=row.feature_data_id;
		ts2.uniqueURLStruct[trim(row.feature_data_override_url)]=t9;
	}
	</cfscript>
</cffunction>

<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("feature_schema", "jetendofeature")# feature_schema 
	WHERE feature_schema_parent_id= #db.param(0)# and 
	feature_id=#db.param(form.feature_id)# and 
	feature_schema_deleted = #db.param(0)# and 
	feature_schema.feature_schema_disable_admin=#db.param(0)# and 
	feature_schema_admin_app_only= #db.param(0)#
	ORDER BY feature_schema_display_name ";
	qoptionSchema=db.execute("qoptionSchema"); 
	for(i=1;i LTE qoptionSchema.recordcount;i++){
		ts=structnew();
		ts.featureName="Custom: "&qoptionSchema.feature_schema_display_name[i];
		ts.link="/z/feature/admin/features/manageSchema?feature_schema_id="&qoptionSchema.feature_schema_id[i];
		ts.children=structnew();
		if(qoptionSchema.feature_schema_menu_name[i] EQ ""){
			curMenu="Custom";
		}else{
			curMenu=qoptionSchema.feature_schema_menu_name[i];
		}
		
		if(structkeyexists(arguments.linkStruct, curMenu) EQ false){
			arguments.linkStruct[curMenu]={
				featureName:"Custom",
				link:"/z/feature/admin/features/index",
				children:{}
			};
		}
		plural="(s)";
		if(qSchema.feature_schema_limit[i] EQ 1 or right(qSchema.feature_schema_display_name[i], 1) EQ "s"){
			plural="";
		}
		arguments.linkStruct[curMenu].children[qoptionSchema.feature_schema_display_name[i]&plural]=ts;
	}
	return arguments.linkStruct;
	</cfscript>
</cffunction>


 
<!--- 
// nested in-memory search is WORKING for all types.
ts=[
	{
		type="=",
		field: "User Id",
		arrValue:[request.zsession.user.id]	
	},
	'OR',
	[
		{
			type="not like",
			field: "title",
			arrValue:["pizza"]
		},
		'AND',
		{
			type="like",
			field: "title",
			arrValue:["3 Wishes%"]
		},
		'AND',
		{
			type="not between",
			field: "city",
			arrValue:[8, 9]
		}
			
	]
];
// Valid types are =, <>, <, <=, >, >=, between, not between, like, not like
application.zcore.siteFieldCom.searchSchema("groupName", ts, 0, false);
 --->
<cffunction name="searchSchema" access="public" output="no" returntype="struct" localmode="modern">
	<cfargument name="groupName" type="string" required="yes">
	<cfargument name="arrSearch" type="array" required="yes">
	<cfargument name="parentSchemaId" type="string" required="yes">
	<cfargument name="showUnapproved" type="boolean" required="no" default="#false#">
	<cfargument name="offset" type="string" required="no" default="0">
	<cfargument name="limit" type="string" required="no" default="10">
	<cfargument name="orderBy" type="string" required="no" default="">
	<cfargument name="orderByDataType" type="string" required="no" default="">
	<cfargument name="orderByDirection" type="string" required="no" default="">
	<cfargument name="getCount" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	rs={count:0, arrResult:[], hasMoreRecords:false};
	arguments.offset=application.zcore.functions.zso(arguments, 'offset', true, 0);
	arguments.limit=application.zcore.functions.zso(arguments, 'limit', true, 10); 
	t9=getTypeData(request.zos.globals.id);
	currentOffset=0;
	if(arguments.orderBy NEQ ""){
		if(arguments.orderByDataType EQ ""){
			arguments.orderByDataType="text";
		}
		if(arguments.orderByDataType NEQ "date" and arguments.orderByDataType NEQ "text" and arguments.orderByDataType NEQ "numeric"){
			throw("Invalid value for arguments.orderByDataType, ""#arguments.orderByDataType#"".");
		}
		if(arguments.orderByDirection EQ ""){
			arguments.orderByDirection="asc";
		}
		if(arguments.orderByDirection NEQ "asc" and arguments.orderByDirection NEQ "desc"){
			throw("Invalid value for arguments.orderByDirection, ""#arguments.orderByDirection#"".");
		}
	} 
	if(structkeyexists(t9, "optionSchemaIdLookup") and structkeyexists(t9.optionSchemaIdLookup, arguments.parentSchemaId&chr(9)&arguments.groupName)){
		optionSchemaId=t9.optionSchemaIdLookup[arguments.parentSchemaId&chr(9)&arguments.groupName];
		var groupStruct=t9.optionSchemaLookup[optionSchemaId];
		if(request.zos.enableSiteSchemaCache and groupStruct.feature_schema_enable_cache EQ 1){
			arrSchema=optionSchemaStruct(arguments.groupName);
			if(arguments.orderBy NEQ ""){
				tempStruct={};
				for(i=1;i LTE arrayLen(arrSchema);i++){
					if(arguments.orderByDataType EQ "numeric" and not isnumeric(arrSchema[i][arguments.orderBy])){
						continue;
					} 
					if(arguments.orderByDataType EQ "date"){
						if(not isdate(arrSchema[i][arguments.orderBy])){
							continue;
						}
						value=dateformat(arrSchema[i][arguments.orderBy], "yyyymmdd")&timeformat(arrSchema[i][arguments.orderBy], "HHmmss");
					}else{
						value=arrSchema[i][arguments.orderBy];
					} 
					tempStruct[i]={
						sortKey: value,
						data:arrSchema[i]
					};
				}
				if(arguments.orderByDataType EQ "date"){
					arrTempKey=structsort(tempStruct, "numeric", arguments.orderByDirection, "sortKey");
				}else{
					arrTempKey=structsort(tempStruct, arguments.orderByDataType, arguments.orderByDirection, "sortKey");
				}  
				arrSchema2=[];
				for(i=1;i LTE arrayLen(arrTempKey);i++){
					arrayAppend(arrSchema2, tempStruct[arrTempKey[i]].data);
				}
				arrSchema=arrSchema2;
			}
			//writedump(arraylen(arrSchema));
			// return rows in an array.
			//writedump(arguments.arrSearch);
			stopStoring=false;
			rs.count=0;
			for(i=1;i LTE arrayLen(arrSchema);i++){
				row=arrSchema[i];
				if(structkeyexists(row, '__approved') and row.__approved NEQ 1){
					continue;
				}
				match=variables.processSearchArray(arguments.arrSearch, row, groupStruct.feature_schema_id);
				if(match){
					rs.count++;
					if(not stopStoring){
						if(currentOffset LT arguments.offset){
							//echo('skip<br>');
							currentOffset++;
							continue;
						}else{
							//echo('match and store: #arrSchema[i].title#<br />');
							// to avoid having to generate a total count, we just see if there is 1 more matching record.
							if(arguments.getCount){
								arrayAppend(rs.arrResult, arrSchema[i]);
								if(arguments.limit EQ arrayLen(rs.arrResult)){
									stopStoring=true;
								}
							}else{
								if(arguments.limit+1 EQ arrayLen(rs.arrResult)){
									rs.hasMoreRecords=true;
									break;
								}
								arrayAppend(rs.arrResult, arrSchema[i]);
							}
						}
					}
				//}else{
				//	echo('not match: #arrSchema[i].title#<br />');
				}
			}
			//abort;
		}else{
			fieldStruct={};

			sql=variables.processSearchArraySQL(arguments.arrSearch, fieldStruct, 1, groupStruct.feature_schema_id);
			/*if(sql EQ ""){
				return rs;
			}*/
			//writedump(sql);abort;

			groupId=getSchemaIDWithNameArray([arguments.groupName]);


			arrTable=["feature_data s1"];
			arrWhere=["s1.site_id = '#request.zos.globals.id#' and 
			s1.feature_data_deleted = 0  and 
			s1.feature_schema_id = '#groupId#' and "&sql];
			arrSelect=[];

			orderTableLookup={};
			fieldIndex=1;
			for(i in fieldStruct){
				tableName="sSchema"&fieldStruct[i];
				orderTableLookup[i]=fieldIndex;
				//arrayAppend(arrSelect, "sVal"&i);
				arrayAppend(arrTable, "site_x_option_group "&tableName);
				arrayAppend(arrWhere, "#tableName#.site_id = s1.site_id and 
				#tableName#.feature_data_id = s1.feature_data_id and 
				#tableName#.feature_field_id = '#application.zcore.functions.zescape(i)#' and 
				#tableName#.feature_schema_id = s1.feature_schema_id AND 
				#tableName#.site_x_option_group_deleted = 0");
				fieldIndex++;
			}
			if(arguments.orderBy NEQ ""){
				// need to lookup the field feature_field_id using the feature_field_name and groupId
				optionIdLookup=t9.optionIdLookup;
				if(structkeyexists(optionIdLookup, groupId&chr(9)&arguments.orderBy)){
					feature_field_id=optionIdLookup[groupId&chr(9)&arguments.orderBy];
					feature_field_type_id=t9.optionLookup[feature_field_id].type;
					currentCFC=getTypeCFC(feature_field_type_id);

					arrayAppend(arrSelect, "s2.site_x_option_group_value sVal2");
					arrayAppend(arrTable, "site_x_option_group s2");
					arrayAppend(arrWhere, "s2.site_id = s1.site_id and 
					s2.feature_data_id = s1.feature_data_id and 
					s2.feature_field_id = '#application.zcore.functions.zescape(feature_field_id)#' and 
					s2.feature_schema_id = s1.feature_schema_id AND 
					s2.site_x_option_group_deleted = 0");
					fieldIndex++;


					orderByStatement=" ORDER BY "&currentCFC.getSortSQL(2, arguments.orderByDirection);
				}else{
					throw("arguments.orderBy, ""#arguments.orderBy#"" is not a valid field in the feature_schema_id=#groupId# | ""#groupStruct.feature_schema_variable_name#""");
				}
			}else if(structkeyexists(request.zos, '#variables.type#FieldSearchDateRangeSortEnabled')){
				orderByStatement=" ORDER BY s1.feature_data_start_date ASC ";
			}else{
				orderByStatement=" ORDER BY s1.feature_data_id ASC ";
			}
			db=request.zos.noVerifyQueryObject;
			if(arguments.getCount){
				db.sql="select count(distinct s1.feature_data_id) count
				from #arrayToList(arrTable, ", ")# 
				WHERE #arrayToList(arrWhere, " and ")# ";
				if(not arguments.showUnapproved){
					db.sql&=" and feature_data_approved=#db.param('1')# ";
				}
				qCount=db.execute("qSelect");  
				rs.count=qCount.count;
				//writedump(qCount);abort;
				if(qCount.recordcount EQ 0 or qCount.count EQ 0){
					return rs;
				} 
			}
			db.sql="select s1.feature_data_id ";
			if(arraylen(arrSelect)){
				db.sql&=", "&arrayToList(arrSelect, ", ");
			}
			db.sql&="
			from #arrayToList(arrTable, ", ")# 
			WHERE #arrayToList(arrWhere, " and ")# ";
			if(not arguments.showUnapproved){
				db.sql&=" and feature_data_approved=#db.param('1')# ";
			}
			db.sql&=" GROUP BY s1.feature_data_id 
			#orderByStatement#
			LIMIT #db.param(arguments.offset)#, #db.param(arguments.limit+1)#";
			qIdList=db.execute("qSelect"); 
			//writedump(qIdList);abort;

			if(qIdList.recordcount EQ 0){
				return rs;
			} 
			arrId=[];
			currentRow=1;
			for(row in qIdList){
				// to avoid having to generate a total count, we just see if there is 1 more matching record.
				if(arguments.limit+1 EQ currentRow){
					rs.hasMoreRecords=true;
					break;
				}
				arrayAppend(arrId, row.feature_data_id);
				currentRow++;
			}
			idlist="'"&arraytolist(arrId, "','")&"'";
			
			 db.sql="SELECT *  FROM 
			 #db.table("feature_data", "jetendofeature")# s1, 
			 #db.table("site_x_option_group", "jetendofeature")# s2
			WHERE  s1.feature_id=#db.param(form.feature_id)# and 
			s1.feature_data_deleted = #db.param(0)# and 
			s2.site_x_option_group_deleted = #db.param(0)# and 
			s1.site_id = s2.site_id and 
			s1.feature_schema_id = s2.feature_schema_id and 
			s1.feature_data_master_set_id = #db.param(0)# and 
			s1.feature_data_id = s2.feature_data_id and ";
			if(not arguments.showUnapproved){
				db.sql&=" s1.feature_data_approved=#db.param(1)# and ";
			}
			db.sql&=" s1.feature_data_id IN (#db.trustedSQL(idlist)#) ";
			if(qIdList.recordcount GT 1){
				db.sql&="ORDER BY field(s1.feature_data_id, #db.trustedSQL(idlist)#)  asc"; 
			}
			qS=db.execute("qS"); 
			//writedump(qS);abort;
			if(qS.recordcount EQ 0){
				return rs;
			}
			lastSetId=0;
			for(row in qS){
				if(lastSetId NEQ row.feature_data_id){
					if(lastSetId NEQ 0){
						arrayAppend(rs.arrResult, curStruct);
					}
					curStruct=variables.buildSchemaSetId(row, false);
					lastSetId=row.feature_data_id;
				}
				variables.buildSchemaSetIdField(row, curStruct);
				
			}
			arrayAppend(rs.arrResult, curStruct);
			return rs;
		}
	}else{
		throw("groupName, ""#arguments.groupName#"" doesn't exist with parentSchemaId, ""#arguments.parentSchemaId#"".");
	}
	return rs;
	</cfscript>
</cffunction>
 
<!--- 
<cfscript>
ts.startDate=now();
ts.endDate=dateAdd("m", 1, now());
ts.limit=3;
ts.offset=0;
ts.orderBy="startDateASC"; // startDateASC | startDateDESC
arr1=application.zcore.siteFieldCom.optionSchemaSetFromDatabaseBySearch(ts, request.zos.globals.id);
</cfscript>
 --->
<cffunction name="optionSchemaSetFromDatabaseBySearch" access="public" returntype="array" localmode="modern">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	ts=arguments.searchStruct;
	if(not structkeyexists(ts, 'arrSchemaName')){
		throw("arguments.searchStruct.arrSchemaName is required. It must be an array of feature_schema_variable_name values.");
	}
	db=request.zos.queryObject;//  SEPARATOR #db.param("','")#) idlist
	 db.sql="SELECT feature_data_id FROM 
	 #db.table("feature_data", "jetendofeature")# s1
	WHERE 
	s1.feature_data_deleted = #db.param(0)# and 
	";
	var groupId=getSchemaIdWithNameArray(ts.arrSchemaName, arguments.site_id);
	db.sql&="s1.feature_schema_id = #db.param(groupId)# and ";
	if(structkeyexists(ts, 'endDate')){
		if(structkeyexists(ts, 'startDate')){
			db.sql&=" s1.feature_data_start_date <= #db.param(dateformat(ts.endDate, 'yyyy-mm-dd'))# and 
			s1.feature_data_end_date >= #db.param(dateformat(ts.startDate, 'yyyy-mm-dd'))#  and ";
		}else{
			db.sql&=" s1.feature_data_end_date <= #db.param(dateformat(ts.endDate, 'yyyy-mm-dd'))# and ";
		}
	}else if(structkeyexists(ts, 'startDate')){
		db.sql&=" s1.feature_data_start_date >= #db.param(dateformat(ts.startDate, 'yyyy-mm-dd'))# and ";
	}
	if(structkeyexists(ts, 'excludeBeforeStartDate')){
		db.sql&=" s1.feature_data_end_date >= #db.param(dateformat(ts.excludeBeforeStartDate, "yyyy-mm-dd")&" 00:00:00")# and ";
	}
	db.sql&="  s1.site_id = #db.param(arguments.site_id)# and  
	s1.feature_data_master_set_id = #db.param(0)# and 
	s1.feature_data_approved=#db.param(1)# ";
	var t9=getTypeData(arguments.site_id);
	groupStruct=t9.optionSchemaLookup[groupId];
	if(structkeyexists(ts, 'orderBy')){
		if(ts.orderBy EQ "startDateASC"){
			db.sql&="ORDER BY feature_data_start_date ASC";
		}else if(ts.orderBy EQ "startDateDESC"){
			db.sql&="ORDER BY feature_data_start_date DESC";
		}else{
			if(groupStruct.feature_schema_enable_sorting EQ 1){
				db.sql&=" ORDER BY s1.feature_data_sort asc ";
			} 
		}
	}else{ 
		if(groupStruct.feature_schema_enable_sorting EQ 1){
			db.sql&=" ORDER BY s1.feature_data_sort asc ";
		}
	}
	if(structkeyexists(ts, 'limit')){
		if(ts.limit LT 1){
			application.zcore.functions.z404("Limit can't be less then one.");
		}
		if(structkeyexists(ts, 'offset')){
			if(ts.offset LT 0){
				application.zcore.functions.z404("Offset can't be less then zero.");
			}
			db.sql&=" LIMIT #db.param(ts.offset)#, #db.param(ts.limit)#";
		}else{
			db.sql&=" LIMIT 0, #db.param(ts.limit)#";
		}
	}
	qIdList=db.execute("qIdList");  
	//writedump(qidlist);abort;
	arrRow=[];
	if(qIdList.recordcount EQ 0){
		return arrRow;
	}
	arrId=[];
	for(row in qIdList){
		arrayAppend(arrId, row.feature_data_id);
	}
	idlist="'"&arraytolist(arrId, "','")&"'";
	
	 db.sql="SELECT * FROM 
	 #db.table("feature_data", "jetendofeature")# s1, 
	 #db.table("site_x_option_group", "jetendofeature")# s2
	WHERE  s1.site_id = #db.param(arguments.site_id)# and 
	s1.feature_data_deleted = #db.param(0)# and 
	s2.site_x_option_group_deleted = #db.param(0)# and 
	s1.feature_data_master_set_id = #db.param(0)# and 
	s1.site_id = s2.site_id and 
	s1.feature_schema_id = s2.feature_schema_id and 
	s1.feature_data_id = s2.feature_data_id and 
	s1.feature_data_approved=#db.param(1)# and 
	s1.feature_data_id IN (#db.trustedSQL(idlist)#) ";
	if(qIdList.recordcount GT 1){
		db.sql&="ORDER BY field(s1.feature_data_id, #db.trustedSQL(idlist)#)  asc"; 
	}
	qS=db.execute("qS"); 
	if(qS.recordcount EQ 0){
		return arrRow;
	}
	lastSetId=0;
	for(row in qS){
		if(lastSetId NEQ row.feature_data_id){
			if(lastSetId NEQ 0){
				arrayAppend(arrRow, curStruct);
			}
			curStruct=variables.buildSchemaSetId(row, false);
			lastSetId=row.feature_data_id;
		}
		variables.buildSchemaSetIdField(row, curStruct);
		
	}
	arrayAppend(arrRow, curStruct);
	return arrRow;
	</cfscript>
</cffunction>



<cffunction name="getSetParentLinks" access="public" localmode="modern">
	<cfargument name="feature_schema_id" type="string" required="yes">
	<cfargument name="feature_schema_parent_id" type="string" required="yes">
	<cfargument name="feature_data_parent_id" type="string" required="yes">
	<cfargument name="linkCurrentPage" type="boolean" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	arrParent=arraynew(1);
	curSchemaId=arguments.feature_schema_id;
	curParentId=arguments.feature_schema_parent_id;
	curParentSetId=arguments.feature_data_parent_id;
	groupStruct=getSchemaById(curSchemaId); 
	if(arguments.linkCurrentPage){
		if(form.method NEQ "sectionSchema"){
			arrayAppend(arrParent, '<a href="/z/feature/admin/features/sectionSchema?feature_data_id=#form.feature_data_id#">Manage Section</a> /');
		}
		manageAction="manageSchema";
		if(form.method EQ "userManageSchema"){
			manageAction="userManageSchema";
		}
		arrayAppend(arrParent, '<a href="/z/feature/admin/features/#manageAction#?feature_schema_id=#curSchemaId#&amp;feature_data_parent_id=#curParentSetId#">Manage #groupStruct.feature_schema_variable_name#(s)</a> / ');
	}
	if(curParentSetId NEQ 0){
		loop from="1" to="25" index="i"{
			db.sql="select s1.*, s2.feature_data_title, s2.feature_data_id d2, s2.feature_data_parent_id d3 
			from #db.table("feature_schema", "jetendofeature")# s1, 
			#db.table("feature_data", "jetendofeature")# s2
			where s1.site_id = s2.site_id and 
			s1.feature_schema_deleted = #db.param(0)# and 
			s2.feature_data_master_set_id = #db.param(0)# and 
			s2.feature_data_deleted = #db.param(0)# and 
			s1.feature_id=#db.param(form.feature_id)# and 
			s1.feature_schema_id=s2.feature_schema_id and 
			s2.feature_data_id=#db.param(curParentSetId)# and 
			s1.feature_schema_id = #db.param(curParentId)# 
			LIMIT #db.param(0)#,#db.param(1)#";
			q12=db.execute("q12");
			loop query="q12"{
				manageAction="manageSchema";
				if(form.method EQ "userManageSchema"){
					manageAction="userManageSchema";
				}
				out='<a href="#application.zcore.functions.zURLAppend("/z/feature/admin/features/#manageAction#", "feature_schema_id=#q12.feature_schema_id#&amp;feature_data_parent_id=#q12.d3#")#">#application.zcore.functions.zFirstLetterCaps(q12.feature_schema_display_name)#</a> / ';
				if(not arguments.linkCurrentPage and curSchemaID EQ arguments.feature_schema_id){
					out&=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(q12.feature_data_title), 70)&' /';
				}else{ 
					out&='<a href="/z/feature/admin/features/#manageAction#?feature_schema_id=#curSchemaId#&amp;feature_data_parent_id=#q12.d2#">#application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(q12.feature_data_title), 70)#</a> /';
				}
				arrayappend(arrParent, out);
				curSchemaId=q12.feature_schema_id;
				curParentId=q12.feature_schema_parent_id;
				curParentSetId=q12.d3;
			}
			if(q12.recordcount EQ 0 or curParentSetId EQ 0){
				break;
			}
		}
	}
	if(arraylen(arrParent)){
		writeoutput('<p>');
		for(i = arrayLen(arrParent);i GTE 1;i--){
			writeOutput(arrParent[i]&' ');
		}
		writeoutput(" </p>");
	}
	</cfscript>
</cffunction>




<cffunction name="optionSchemaSetCountFromDatabaseBySearch" access="public" returntype="numeric" localmode="modern">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	ts=arguments.searchStruct;
	if(not structkeyexists(ts, 'arrSchemaName')){
		throw("arguments.searchStruct.arrSchemaName is required. It must be an array of feature_schema_variable_name values.");
	}
	db=request.zos.queryObject;//  SEPARATOR #db.param("','")#) idlist
	 db.sql="SELECT count(feature_data_id) count FROM 
	 #db.table("feature_data", "jetendofeature")# s1
	WHERE s1.feature_data_deleted = #db.param(0)# and ";
	var groupId=getSchemaIdWithNameArray(ts.arrSchemaName, arguments.site_id);
	db.sql&="s1.feature_schema_id = #db.param(groupId)# and ";
	if(structkeyexists(ts, 'endDate')){
		if(structkeyexists(ts, 'startDate')){
			db.sql&=" s1.feature_data_start_date <= #db.param(dateformat(ts.endDate, 'yyyy-mm-dd'))# and 
			s1.feature_data_end_date >= #db.param(dateformat(ts.startDate, 'yyyy-mm-dd'))#  and ";
		}else{
			db.sql&=" s1.feature_data_end_date <= #db.param(dateformat(ts.endDate, 'yyyy-mm-dd'))# and ";
		}
	}else if(structkeyexists(ts, 'startDate')){
		db.sql&=" s1.feature_data_start_date >= #db.param(dateformat(ts.startDate, 'yyyy-mm-dd'))# and ";
	}
	db.sql&="  s1.site_id = #db.param(arguments.site_id)# and  
	s1.feature_data_master_set_id = #db.param(0)# and 
	s1.feature_data_approved=#db.param(1)# ";
	qIdList=db.execute("qIdList");  
	if(qIdList.recordcount EQ 0){
		return 0;
	}else{
		return qIdList.count;
	}
	</cfscript>
</cffunction>
 
<cffunction name="optionSchemaSetFromDatabaseBySetId" access="public" returntype="struct" localmode="modern">
	<cfargument name="groupId" type="string" required="yes">
	<cfargument name="setId" type="string" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="showUnapproved" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	 db.sql="SELECT * FROM 
	 #db.table("feature_data", "jetendofeature")# s1 FORCE INDEX(`PRIMARY`), 
	 #db.table("site_x_option_group", "jetendofeature")# s2 FORCE INDEX(`PRIMARY`)
	WHERE s1.site_id = #db.param(arguments.site_id)# and 
	s1.feature_data_deleted = #db.param(0)# and 
	s2.site_x_option_group_deleted = #db.param(0)# and 
	feature_data_master_set_id = #db.param(0)# and 
	site_x_option_group_value <> #db.param('')# and 
	s1.site_id = s2.site_id and 
	s1.feature_schema_id = s2.feature_schema_id and 
	s1.feature_data_id = s2.feature_data_id and 
	s1.feature_schema_id=#db.param(arguments.groupId)# and ";
	if(not arguments.showUnapproved){
		db.sql&=" s1.feature_data_approved=#db.param(1)# and ";
	}
	db.sql&=" s1.feature_data_id = #db.param(arguments.setId)# 
	";
	var t9=getTypeData(arguments.site_id);
	groupStruct=t9.optionSchemaLookup[arguments.groupId];
	if(groupStruct.feature_schema_enable_sorting EQ 1){
		db.sql&=" ORDER BY s1.feature_data_sort asc ";
	}
	qSet=db.execute("qSet"); 
	resultStruct={};
	lastSetId=0; 
	for(row in qSet){
		if(lastSetId NEQ row.feature_data_id){
			resultStruct=variables.buildSchemaSetId(row, false);
			lastSetId=row.feature_data_id;
		}
		variables.buildSchemaSetIdField(row, resultStruct);
		
	}
	return resultStruct;
	</cfscript>
</cffunction>


<cffunction name="optionSchemaSetFromDatabaseBySortedArray" access="public" returntype="array" localmode="modern">
	<cfargument name="arrSetId" type="array" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	for(i=1;i LTE arraylen(arguments.arrSetId);i++){
		arguments.arrSetId[i]=application.zcore.functions.zescape(arguments.arrSetId[i]);
	} 
	idList="'"&arrayToList(arguments.arrSetId, "','")&"'";
	 db.sql="SELECT * FROM 
	 #db.table("feature_data", "jetendofeature")# s1, 
	 #db.table("site_x_option_group", "jetendofeature")# s2
	WHERE s1.site_id = #db.param(arguments.site_id)# and 
	s1.feature_data_deleted = #db.param(0)# and 
	s2.site_x_option_group_deleted = #db.param(0)# and 
	feature_data_master_set_id = #db.param(0)# and 
	s1.site_id = s2.site_id and 
	s1.feature_schema_id = s2.feature_schema_id and 
	s1.feature_data_id = s2.feature_data_id and 
	s1.feature_data_approved=#db.param(1)# and 
	s1.feature_data_id IN (#db.trustedSQL(idList)#) 
	ORDER BY field(s1.feature_data_id, #db.trustedSQL(idList)#) ASC";
	qS=db.execute("qS"); 
	arrRow=[];
	if(qS.recordcount EQ 0){
		return arrRow;
	}
	lastSetId=0;
	for(row in qS){
		if(lastSetId NEQ row.feature_data_id){
			if(lastSetId NEQ 0){
				arrayAppend(arrRow, curStruct);
			}
			curStruct=variables.buildSchemaSetId(row, false);
			lastSetId=row.feature_data_id;
		}
		variables.buildSchemaSetIdField(row, curStruct);
		
	}
	arrayAppend(arrRow, curStruct);
	return arrRow;
	</cfscript>
</cffunction>

<cffunction name="optionSchemaSetFromDatabaseBySchemaId" access="public" localmode="modern">
	<cfargument name="groupId" type="string" required="yes">
	<cfargument name="feature_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="parentStruct" type="struct" required="no" default="#{__groupId=0,__setId=0}#">
	<cfargument name="fieldList" type="string" required="no" default="">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	 db.sql="SELECT * FROM 
	 #db.table("feature_data", "jetendofeature")# s1 FORCE INDEX(`PRIMARY`), 
	 #db.table("site_x_option_group", "jetendofeature")# s2 FORCE INDEX(`PRIMARY`)
	WHERE s1.site_id = #db.param(arguments.site_id)# and 
	s1.feature_data_deleted = #db.param(0)# and 
	s2.site_x_option_group_deleted = #db.param(0)# and 
	s1.site_id = s2.site_id and 
	s1.feature_schema_id = s2.feature_schema_id and 
	s1.feature_id = #db.param(arguments.feature_id)# and 
	s1.feature_data_id = s2.feature_data_id and 
	s1.feature_data_parent_id = #db.param(arguments.parentStruct.__setId)# and 
	s1.feature_data_approved=#db.param(1)# and 
	s2.site_x_option_group_value <> #db.param('')# and 
	feature_data_master_set_id = #db.param(0)# and 
	s1.feature_schema_id = #db.param(arguments.groupId)# ";

	var t9=getTypeData(arguments.site_id); 
	disableDefaults=false;
	defaultStruct={};
	if(arguments.fieldList NEQ ""){
		arrField=listToArray(arguments.fieldList);
		arrId=[];
		for(field in arrField){
			defaultStruct[trim(field)]="";
			arrayAppend(arrId, t9.optionIdLookup[arguments.groupId&chr(9)&trim(field)]);
		}
		if(arraylen(arrId) NEQ 0){
			db.sql&=" and s2.feature_field_id IN (#db.trustedSQL("'"&arrayToList(arrId, "','")&"'")#) ";
			disableDefaults=true;
		} 
	} 
	groupStruct=t9.optionSchemaLookup[arguments.groupId];
	if(groupStruct.feature_schema_enable_sorting EQ 1){
		db.sql&=" ORDER BY s1.feature_data_sort asc ";
	}else{
		db.sql&=" ORDER BY s1.feature_data_id asc ";
	}
	qS=db.execute("qS");  
	arrRow=[];
	if(qS.recordcount EQ 0){
		return arrRow;
	}
	lastSetId=0;
	rowStruct={}; 
	arrSort=[];
	for(row in qS){
		if(not structkeyexists(rowStruct, row.feature_data_id)){
			curStruct=variables.buildSchemaSetId(row, disableDefaults);
			if(disableDefaults){
				structappend(curStruct, defaultStruct);
			}
			rowStruct[row.feature_data_id]=curStruct;
			arrayAppend(arrSort, row.feature_data_id);
		} 
		variables.buildSchemaSetIdField(row, rowStruct[row.feature_data_id]);
		
	}
	for(i in arrSort){
		row=rowStruct[i];
		arrayAppend(arrRow, row);
	}
	return arrRow;
	</cfscript>
</cffunction>
	
<cffunction name="buildSchemaSetIdField" access="private" localmode="modern">
	<cfargument name="row" type="struct" required="yes"> 
	<cfargument name="curStruct" type="struct" required="yes"> 
	<cfscript>
	var t9=getTypeData(arguments.row.site_id);
	if(arguments.row.feature_field_id NEQ ""){
		typeId=t9.optionLookup[arguments.row.feature_field_id].type;
		if(typeId EQ 2){
			if(arguments.row.site_x_option_group_value EQ ""){
				tempValue="";
			}else{
				tempValue='<div class="zEditorHTML">'&arguments.row.site_x_option_group_value&'</div>';;
			}
		}else if(typeId EQ 3 or typeId EQ 9){
			if(arguments.row.site_x_option_group_value NEQ "" and arguments.row.site_x_option_group_value NEQ "0"){
				if(application.zcore.functions.zso(t9.optionLookup[arguments.row.feature_field_id].optionStruct, 'file_securepath') EQ "Yes"){
					tempValue="/zuploadsecure/site-options/"&arguments.row.site_x_option_group_value;
				}else{
					tempValue="/zupload/site-options/"&arguments.row.site_x_option_group_value;
				}
			}else{
				tempValue="";
			}
		}else{
			tempValue=arguments.row.site_x_option_group_value;
		}
		arguments.curStruct[t9.optionLookup[arguments.row.feature_field_id].name]=tempValue;
	}
	</cfscript>
</cffunction>

<cffunction name="buildSchemaSetId" access="private" localmode="modern">
	<cfargument name="row" type="struct" required="yes"> 
	<cfargument name="disableDefaults" type="boolean" required="yes">
	<cfscript>
	row=arguments.row;  
	var t9=getTypeData(row.site_id);
	ts=structnew();
	ts.__sort=row.feature_data_sort;
	ts.__setId=row.feature_data_id;
	ts.__dateModified=row.feature_data_updated_datetime;
	ts.__groupId=row.feature_schema_id;
	ts.__createdDatetime=row.feature_data_created_datetime;
	ts.__approved=row.feature_data_approved;
	ts.__title=row.feature_data_title;
	ts.__parentID=row.feature_data_parent_id;
	ts.__summary=row.feature_data_summary;
	// build url
	if(row.feature_data_image_library_id NEQ 0){
		ts.__image_library_id=row.feature_data_image_library_id;
	}
	groupStruct=t9.optionSchemaLookup[row.feature_schema_id];
	if(groupStruct.feature_schema_enable_unique_url EQ 1){
		if(row.feature_data_override_url NEQ ""){
			ts.__url=row.feature_data_override_url;
		}else{ 
			ts.__url="/#application.zcore.functions.zURLEncode(row.feature_data_title, '-')#-50-#row.feature_data_id#.html";
		}
	}
	if(not arguments.disableDefaults){
		structappend(ts, t9.optionSchemaDefaults[row.feature_schema_id]);
	}
	return ts;
	</cfscript>
</cffunction>


<cffunction name="setSchemaImportStruct" access="public" localmode="modern">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfargument name="feature_id" type="numeric" required="yes">
	<!--- <cfargument name="feature_schema_parent_id" type="numeric" required="yes"> --->
	<cfargument name="feature_data_parent_id" type="numeric" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="importStruct" type="struct" required="yes">
	<cfscript>
	if(not structkeyexists(request.zos, '#variables.type#SchemaImportTable')){
		request.zos["#variables.type#SchemaImportTable"]={};
	}
	var groupId=getSchemaIdWithNameArray(arguments.arrSchemaName, request.zos.globals.id);
	//var groupStruct=typeStruct.optionSchemaLookup[groupId]; 
	form.feature_data_id=0;
	form.feature_data_parent_id=arguments.feature_data_parent_id;
	form.feature_id=arguments.feature_id;
	form.feature_schema_id=groupId;//optionSchemaIDByName(arguments.feature_schema_variable_name, arguments.feature_schema_parent_id);

	if(structkeyexists(request.zos["#variables.type#SchemaImportTable"], form.feature_schema_id)){
		ts=request.zos["#variables.type#SchemaImportTable"][form.feature_schema_id];
	}else{
		db=request.zos.queryObject;
		db.sql="select * from #db.table("feature_field", "jetendofeature")# WHERE 
		feature_schema_id = #db.param(form.feature_schema_id)# and 
		feature_field_type_id <> #db.param(11)# and 
		feature_field_deleted = #db.param(0)# and 
		feature_id=#db.param(form.feature_id)# ";
		qField=db.execute("qField");
		var ts={}; 
		var arroptionId=[];
		for(row in qField){
			arrayAppend(arroptionId, row.feature_field_id);
			ts[row.feature_field_name]=row.feature_field_id;
		} 
		ts.feature_field_id=arrayToList(arroptionId, ",");
		request.zos["#variables.type#SchemaImportTable"][form.feature_schema_id]=ts;
	}
	arguments.importStruct.feature_field_id=ts.feature_field_id;
	for(i in arguments.dataStruct){
		if(structkeyexists(ts, i)){
			arguments.importStruct['newvalue'&ts[i]]=arguments.dataStruct[i];
		}
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
	db.sql="select feature_data_id from #db.table("feature_data", "jetendofeature")#
	WHERE 
	feature_data_deleted = #db.param(0)# and 
	feature_data_master_set_id = #db.param(0)# and 
	feature_data_parent_id= #db.param(arguments.feature_data_parent_id)# and 
	feature_schema_id = #db.param(arguments.feature_schema_id)# and 
	feature_id = #db.param(arguments.feature_id)# and 
	site_id = #db.param(arguments.site_id)# 
	ORDER BY feature_data_sort";
	var qSort=db.execute("qSort");
	var arrTemp=[];
	sortStruct={};
	i=1;

	t9=getTypeData(arguments.site_id);
	var groupStruct=t9.optionSchemaLookup[arguments.feature_schema_id];

	for(var row2 in qSort){
		arrayAppend(arrTemp, row2.feature_data_id);
		sortStruct[row2.feature_data_id]=i;


		if(structkeyexists(groupStruct, 'feature_schema_change_cfc_path') and groupStruct.feature_schema_change_cfc_path NEQ ""){
			path=groupStruct.feature_schema_change_cfc_path;
			if(left(path, 5) EQ "root."){
				path=request.zRootCFCPath&removeChars(path, 1, 5);
			}
			changeCom=application.zcore.functions.zcreateObject("component", path);
			changeCom[groupStruct.feature_schema_change_cfc_sort_method](row2.feature_data_id, i);
		}
		i++;
	}
	t9=getSiteData(arguments.site_id);
	t9.optionSchemaSetId[arguments.feature_data_parent_id&"_childSchema"][arguments.feature_schema_id]=arrTemp;

	arrData=t9.optionSchemaSetArrays[arguments.feature_id&chr(9)&arguments.feature_schema_id&chr(9)&arguments.feature_data_parent_id];
	arrDataNew=[];
	for(i=1;i LTE arraylen(arrData);i++){
		sortIndex=sortStruct[arrData[i].__setId];
		arrDataNew[sortIndex]=arrData[i];
	}
	t9.optionSchemaSetArrays[arguments.feature_id&chr(9)&arguments.feature_schema_id&chr(9)&arguments.feature_data_parent_id]=arrDataNew;
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
	/* if(request.zos.isdeveloper){
		 debug=true;
	 }*/

	t9=getSiteData(arguments.site_id);
	typeStruct=getTypeData(arguments.site_id);
	db.sql="SELECT s1.*, s3.feature_field_id groupSetFieldId, s4.feature_field_type_id typeId, s3.site_x_option_group_value groupSetValue, s3.site_x_option_group_original groupSetOriginal  
	FROM #db.table("feature_data", "jetendofeature")# s1  
	LEFT JOIN #db.table("site_x_option_group", "jetendofeature")# s3  ON 
	s1.feature_schema_id = s3.feature_schema_id AND 
	s1.feature_data_id = s3.feature_data_id and 
	s1.site_id = s3.site_id
	LEFT JOIN #db.table("feature_field", "jetendofeature")# s4 ON 
	s4.feature_schema_id = s3.feature_schema_id and 
	s4.feature_field_id = s3.feature_field_id and 
	s4.site_id = s3.site_id 
	WHERE s1.site_id = #db.param(arguments.site_id)#  and 
	s1.feature_data_deleted = #db.param(0)# and 
	s3.site_x_option_group_deleted = #db.param(0)# and 
	s4.feature_field_deleted = #db.param(0)# and 
	s1.feature_data_approved=#db.param(1)# and 
	s1.feature_data_id=#db.param(arguments.feature_data_id)#
	ORDER BY s1.feature_data_parent_id ASC, s1.feature_data_sort ASC ";
	//s1.feature_data_master_set_id = #db.param(0)# and 
	//if(debug) writedump(db.sql);
	var qS=db.execute("qS"); 
	if(debug) writedump(qS);
	var tempUniqueStruct=structnew();
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-1<br>'); startTime=gettickcount();
	var newRecord=false;
	for(row in qS){
		var id=row.feature_data_id;
		if(structkeyexists(t9.optionSchemaSetId, id&"_appId") EQ false){
			newRecord=true;
			typeStruct.optionSchemaLookup[row.feature_schema_id].count++;
			t9.optionSchemaSetId[id&"_groupId"]=row.feature_schema_id;
			t9.optionSchemaSetId[id&"_appId"]=row.feature_id;
			t9.optionSchemaSetId[id&"_parentId"]=row.feature_data_parent_id;
			t9.optionSchemaSetId[id&"_childSchema"]=structnew();
		}
		if(row.feature_data_master_set_id EQ 0 and structkeyexists(t9.optionSchemaSetId, row.feature_data_parent_id&"_childSchema")){
			if(structkeyexists(t9.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"], row.feature_schema_id) EQ false){
				t9.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id]=arraynew(1);
			}
			if(typeStruct.optionSchemaLookup[row.feature_schema_id].feature_schema_enable_sorting EQ 1){
				if(structkeyexists(tempUniqueStruct, row.feature_data_parent_id&"_"&id) EQ false){
					var arrChild=t9.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id];
					var resort=false;
					if(arrayLen(arrChild) LT row.feature_data_sort){
						resort=true;
					}else if(arrayLen(arrChild) GTE row.feature_data_sort){
						if(arrChild[row.feature_data_sort] NEQ id){
							resort=true;
						}
					/*}else if(arrayLen(arrChild)+1 EQ row.feature_data_sort){
						arrayAppend(arrChild, id);*/
					}else{
						resort=true;
					} 
			//writedump(resort);
					if(resort){
						db.sql="select feature_data_id from #db.table("feature_data", "jetendofeature")#
						WHERE 
						feature_data_deleted = #db.param(0)# and 
						feature_data_master_set_id = #db.param(0)# and 
						feature_data_parent_id= #db.param(row.feature_data_parent_id)# and 
						feature_schema_id = #db.param(row.feature_schema_id)# and 
						feature_id = #db.param(row.feature_id)# and 
						site_id = #db.param(arguments.site_id)# 
						ORDER BY feature_data_sort";
						var qSort=db.execute("qSort");
						var arrTemp=[];
						for(var row2 in qSort){
							arrayAppend(arrTemp, row2.feature_data_id);
						}
						t9.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id]=arrTemp;
					}
					//writedump(t9.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id]);
					tempUniqueStruct[row.feature_data_parent_id&"_"&id]=true;
				}
			}else if(newRecord){
				// if i get an undefined error here, it is probably because memory caching is disable on the parent feature_schema_id
				var arrChild=t9.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id];
				var found=false;
				for(var i=1;i LTE arrayLen(arrChild);i++){
					if(row.feature_data_id EQ arrChild[i]){
						found=true;
						break;
					}
				}
				if(not found){
					arrayAppend(arrChild, row.feature_data_id);
				}
			}
		}
		if(row.typeId EQ 2){
			if(row.groupSetValue EQ ""){
				tempValue="";
			}else{
				tempValue='<div class="zEditorHTML">'&row.groupSetValue&'</div>';
			}
		}else if(row.typeId EQ 3 or row.typeId EQ 9){
			if(row.groupSetValue NEQ "" and row.groupSetValue NEQ "0"){
				optionStruct=typeStruct.optionLookup[row.groupSetFieldId].optionStruct;
				if(application.zcore.functions.zso(optionStruct, 'file_securepath') EQ "Yes"){
					tempValue="/zuploadsecure/site-options/"&row.groupSetValue;
				}else{
					tempValue="/zupload/site-options/"&row.groupSetValue;
				}
			}else{
				tempValue="";
			}
		}else{
			tempValue=row.groupSetValue;
		}
		t9.optionSchemaSetId[id&"_f"&row.groupSetFieldId]=tempValue;
		if(row.typeId EQ 3){
			if(row.groupSetOriginal NEQ ""){
				t9.optionSchemaSetId["__original "&id&"_f"&row.groupSetFieldId]="/zupload/site-options/"&row.groupSetOriginal;
			}else{
				t9.optionSchemaSetId["__original "&id&"_f"&row.groupSetFieldId]=tempValue;
			}
		} 
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-2<br>'); startTime=gettickcount();
	 db.sql="SELECT * FROM 
	 #db.table("feature_data", "jetendofeature")# s1, 
	 #db.table("feature_schema", "jetendofeature")# s2
	WHERE s1.site_id = #db.param(arguments.site_id)# and 
	feature_data_master_set_id = #db.param(0)# and 
	s1.feature_data_deleted = #db.param(0)# and 
	s2.feature_schema_deleted = #db.param(0)# and 
	s1.site_id = s2.site_id and 
	s1.feature_schema_id = s2.feature_schema_id and 
	s1.feature_data_id = #db.param(arguments.feature_data_id)# ";
	var qS=db.execute("qS"); 
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-3<br>'); startTime=gettickcount();
	if(debug) writedump(qS);
	for(row in qS){
		if(not structkeyexists(t9, 'optionSchemaSetQueryCache')){
			t9.optionSchemaSetQueryCache={};
		}
		if(request.zos.enableSiteSchemaCache and row.feature_schema_enable_cache EQ 1){
			t9.optionSchemaSetQueryCache[row.feature_data_id]=row;
		}
		if(structkeyexists(t9.optionSchemaSetArrays, row.feature_id&chr(9)&row.feature_schema_id&chr(9)&row.feature_data_parent_id) EQ false){
			t9.optionSchemaSetArrays[row.feature_id&chr(9)&row.feature_schema_id&chr(9)&row.feature_data_parent_id]=arraynew(1);
		}
		var ts=structnew();
		ts.__sort=row.feature_data_sort;
		ts.__setId=row.feature_data_id;
		ts.__dateModified=row.feature_data_updated_datetime;
		ts.__groupId=row.feature_schema_id;
		ts.__createdDatetime=row.feature_data_created_datetime;
		ts.__approved=row.feature_data_approved;
		ts.__title=row.feature_data_title;
		ts.__parentID=row.feature_data_parent_id;
		ts.__summary=row.feature_data_summary;
		// build url
		if(row.feature_data_image_library_id NEQ 0){
			ts.__image_library_id=row.feature_data_image_library_id;
		}
		if(row.feature_schema_enable_unique_url EQ 1){
			if(row.feature_data_override_url NEQ ""){
				ts.__url=row.feature_data_override_url;
			}else{
				ts.__url="/#application.zcore.functions.zURLEncode(row.feature_data_title, '-')#-50-#row.feature_data_id#.html";
			}
		} 
		var fieldStruct=t9.optionSchemaFieldLookup[ts.__groupId];
		
		var defaultStruct=t9.optionSchemaDefaults[row.feature_schema_id];
		for(var i2 in fieldStruct){
			var cf=t9.optionLookup[i2];
			if(structkeyexists(t9.optionSchemaSetId, "__original "&ts.__setId&"_f"&i2)){
				ts["__original "&cf.name]=t9.optionSchemaSetId["__original "&ts.__setId&"_f"&i2];
			}
			if(structkeyexists(t9.optionSchemaSetId, ts.__setId&"_f"&i2)){
				ts[cf.name]=t9.optionSchemaSetId[ts.__setId&"_f"&i2];
			}else if(structkeyexists(defaultStruct, cf.name)){
				ts[cf.name]=defaultStruct[cf.name];
			}else{
				ts[cf.name]="";
			}
		}
		if(debug) writedump(ts);
		
		t9.optionSchemaSet[row.feature_data_id]= ts;
		arrChild=[];

		// don't sort versions
		if(row.feature_data_master_set_id EQ 0){
			if(typeStruct.optionSchemaLookup[row.feature_schema_id].feature_schema_enable_sorting EQ 1){
				var arrChild=t9.optionSchemaSetArrays[row.feature_id&chr(9)&ts.__groupId&chr(9)&row.feature_data_parent_id];
				var resort=false;
				if(arrayLen(arrChild) GTE row.feature_data_sort){
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

					if(not structkeyexists(t9.optionSchemaSetId, row.feature_data_parent_id&"_childSchema")){
						t9.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"]={};
					}
					if(not structkeyexists(t9.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"], row.feature_schema_id)){
						t9.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id]=[];
					}
					try{
						var arrChild2=t9.optionSchemaSetId[row.feature_data_parent_id&"_childSchema"][row.feature_schema_id];
						var arrTemp=[]; 
						for(var i=1;i LTE arraylen(arrChild2);i++){
							arrayAppend(arrTemp, t9.optionSchemaSet[arrChild2[i]]);
						}
						t9.optionSchemaSetArrays[row.feature_id&chr(9)&ts.__groupId&chr(9)&row.feature_data_parent_id]=arrTemp;
					}catch(Any e){
						application.zcore.siteFieldCom.updateSchemaCacheBySchemaId(row.feature_schema_id);
						//application.zcore.functions.zOS_cacheSiteAndUserSchemas(request.zos.globals.id);
						ts={};
						ts.subject="Site option group update resort failed";
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
				var arrChild=t9.optionSchemaSetArrays[row.feature_id&chr(9)&ts.__groupId&chr(9)&row.feature_data_parent_id];
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
	application.zcore.functions.zCacheJsonSiteAndUserSchema(arguments.site_id, application.zcore.siteGlobals[arguments.site_id]); 
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-5<br>'); startTime=gettickcount();
	if(debug) application.zcore.functions.zabort();
	</cfscript>
</cffunction>
 
 
<cffunction name="getSiteMap" localmode="modern" access="public">
	<cfargument name="arrURL" type="array" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var i=0;
	db.sql="select * from #db.table("feature_schema", "jetendofeature")#, 
	#db.table("feature_field", "jetendofeature")#
	where 
	feature_schema.site_id = feature_field.site_id and 
	feature_schema.feature_schema_id = feature_field.feature_schema_id and 
	feature_field_deleted=#db.param(0)# and 
	feature_schema_deleted = #db.param(0)# and 
	feature_schema_parent_id = #db.param('0')# and 
	feature_schema.feature_id=#db.param(form.feature_id)# and 
	feature_schema_disable_site_map = #db.param(0)# and 
	feature_schema.feature_schema_enable_unique_url = #db.param(1)# 
	GROUP BY feature_schema.feature_schema_id";
	qSchema=db.execute("qSchema");
	for(row in qSchema){ 
		arr1=optionSchemaStruct(row.feature_schema_variable_name, 0, row.site_id, {__groupId=0,__setId=0}, row.feature_field_name);
		for(i=1;i LTE arraylen(arr1);i++){
			if(arr1[i].__approved EQ 1){
				t2=StructNew();
				t2.groupName=row.feature_schema_display_name;
				t2.url=request.zos.currentHostName&arr1[i].__url;
				t2.title=arr1[i].__title;
				arrayappend(arguments.arrUrl,t2);
			}
		}
	}
	return arguments.arrURL;
	</cfscript>
</cffunction>

<cffunction name="searchReindex" localmode="modern" access="public" hint="Reindex ALL site-option records in the entire app.">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var offset=0;
	var limit=30;
	setting requesttimeout="5000";
	startDatetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	db.sql="select feature_schema_id, feature_schema_parent_id, feature_schema_variable_name, site_id FROM
	#db.table("feature_schema", "jetendofeature")# feature_schema WHERE 
	site_id <> #db.param(-1)# and 
	feature_schema_deleted = #db.param(0)# 
	ORDER BY feature_schema_parent_id";
	qSchema=db.execute("qSchema");
	groupStruct={};
	for(row in qSchema){
		if(not structkeyexists(groupStruct, row.site_id)){
			groupStruct[row.site_id]={};
		}
		groupStruct[row.site_id][row.feature_schema_id]={
			parentId:row.feature_schema_parent_id,
			name:row.feature_schema_variable_name
		};
	}
	while(true){
		db.sql="select feature_data_id, feature_schema.feature_schema_parent_id, site.site_id, feature_schema.feature_schema_variable_name FROM
		#db.table("site", "jetendofeature")# site, 
		#db.table("feature_data", "jetendofeature")# feature_data,
		#db.table("feature_schema", "jetendofeature")# feature_schema
		where 
		site_deleted = #db.param(0)# and 
		feature_data_master_set_id = #db.param(0)# and 
		feature_data_deleted = #db.param(0)# and 
		feature_schema_deleted = #db.param(0)# and 
		feature_schema.feature_schema_id = feature_data.feature_schema_id and 
		feature_data.site_id = site.site_id and 
		feature_schema.site_id = site.site_id and 
		feature_schema.site_id = feature_data.site_id and 
		feature_schema_enable_unique_url = #db.param(1)# and 
		feature_data.feature_data_active = #db.param(1)# and 
		feature_data.feature_data_approved = #db.param(1)# and 
		feature_schema_public_searchable = #db.param(1)# and 
		site.site_active=#db.param(1)# and 
		site.site_id <> #db.param(-1)# "; 
		if(structkeyexists(form, 'sid') and form.sid NEQ ""){
			db.sql&=" and site.site_id = #db.param(form.sid)# ";
		}
		db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)#"; 
		qSchema=db.execute("qSchema"); 
		offset+=limit;
		if(qSchema.recordcount EQ 0){
			break;
		}else{
			for(row in qSchema){
				arrSchema=[];
				parentId=row.feature_schema_parent_id;
				while(true){
					if(parentId EQ 0){
						break;
					}
					tempStruct=groupStruct[row.site_id][parentId];
					parentId=tempStruct.parentId;
					arrayAppend(arrSchema, tempStruct.name);
				}
				arrayAppend(arrSchema, row.feature_schema_variable_name);
				indexSchemaRow(row.feature_data_id, row.site_id, arrSchema); 
			}
		}
	}
	db.sql="delete from #db.table("search", "jetendofeature")# WHERE 
	site_id <> #db.param(-1)# and 
	app_id = #db.param(14)# and 
	search_deleted = #db.param(0)#";
	if(structkeyexists(form, 'sid') and form.sid NEQ ""){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	db.sql&="  and 
	search_updated_datetime < #db.param(startDatetime)# ";
	db.execute("qDelete");
	</cfscript>
</cffunction>


<cffunction name="deleteSchemaSetIndex" localmode="modern" access="public">
	<cfargument name="setId" type="string" required="no" default="">
	<cfargument name="site_id" type="string" required="no" default="">
	<cfscript>
	// note: deactivateSchemaSet also calls this function
	var db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", "jetendofeature")# 
	WHERE site_id =#db.param(arguments.site_id)# and 
	app_id = #db.param(14)# and 
	search_deleted = #db.param(0)# and 
	search_table_id = #db.param(arguments.setId)# ";
	db.execute("qDelete");

	if(structkeyexists(application.siteStruct[request.zos.globals.id].globals.soSchemaData, 'optionSchemaSetQueryCache')){
		structdelete(application.siteStruct[request.zos.globals.id].globals.soSchemaData.optionSchemaSetQueryCache, arguments.setId);
	}
	</cfscript>
</cffunction>

<cffunction name="deactivateSchemaSet" localmode="modern" access="public">
	<cfargument name="setId" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="isDisabledByUser" type="boolean" required="yes">
	<cfscript>
	// nothing calls this function?
	var db=request.zos.queryObject;
	if(arguments.isDisabledByUser){
		approved=2;
	}else{
		approved=0;
	}
	db.sql="UPDATE #db.table("feature_data", "jetendofeature")# 
	SET 
	feature_data_approved=#db.param(approved)#,
	feature_data_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE site_id =#db.param(arguments.site_id)# and 
	feature_data_deleted = #db.param(0)# and 
	feature_data_id = #db.param(arguments.setId)# ";
	db.execute("qUpdate");
	db.sql="select feature_schema_id, feature_data_image_library_id from #db.table("feature_data", "jetendofeature")# 
	WHERE site_id =#db.param(arguments.site_id)# and 
	feature_data_deleted = #db.param(0)# and 
	feature_data_id = #db.param(arguments.setId)# ";
	qSet=db.execute("qSet");
	if(qSet.recordcount){
		groupId=qSet.feature_schema_id;
		if(qSet.feature_data_image_library_id NEQ 0){
			application.zcore.imageLibraryCom.unapproveLibraryId(qSet.feature_data_image_library_id);
		}
		typeStruct=getTypeData(arguments.site_id);
		t9=getSiteData(arguments.site_id);
		var groupStruct=typeStruct.optionSchemaLookup[groupId]; 

		deleteSchemaSetIndex(qSet.feature_data, qSet.site_id);

		if(request.zos.enableSiteSchemaCache and groupStruct.feature_schema_enable_cache EQ 1 and structkeyexists(t9.optionSchemaSet, arguments.setId)){
			groupStruct=t9.optionSchemaSet[arguments.setId];
			groupStruct.__approved=approved;
			application.zcore.functions.zCacheJsonSiteAndUserSchema(arguments.site_id, application.zcore.siteGlobals[arguments.site_id]); 
		}
	}
	
	</cfscript>
</cffunction>




<cffunction name="prepareRecursiveData" localmode="modern" access="public">
	<cfargument name="feature_field_id" type="string" required="yes">
	<cfargument name="feature_schema_id" type="string" required="yes">
	<cfargument name="setFieldStruct" type="struct" required="yes">
	<cfargument name="enableSearchView" type="boolean" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=arguments.setFieldStruct;
	arrLabel=[];
	arrValue=[];
	delimiter="|";
	if(arguments.setFieldStruct.selectmenu_delimiter EQ "|"){
		delimiter=",";
	}
	if(structkeyexists(ts,'selectmenu_groupid') and ts.selectmenu_groupid NEQ ""){
		parentId=application.zcore.functions.zso(form, 'feature_data_parent_id', true);
		// need parent group of ts.selectmenu_groupid
		db.sql="select * from #db.table("feature_schema", "jetendofeature")# 
		WHERE feature_schema_id=#db.param(ts.selectmenu_groupid)# and 
		feature_schema_deleted=#db.param(0)# and 
		feature_id=#db.param(form.feature_id)# ";
		qParentSchema=db.execute("qParentSchema", "", 10000, "query", false); 
		found=false; 
		if(qParentSchema.recordcount NEQ 0 and qParentSchema.feature_schema_parent_id NEQ 0 and form.feature_data_parent_id NEQ 0){ 
			for(i=1;i<=50;i++){
				db.sql="select * from #db.table("feature_data", "jetendofeature")# WHERE 
				 feature_data_deleted=#db.param(0)# and 
				 feature_data_id=#db.param(parentId)# and 
				 feature_id=#db.param(form.feature_id)#";
				qParentSet=db.execute("qParentSet"); 
				if(qParentSet.feature_schema_id EQ qParentSchema.feature_schema_parent_id){
					parentId=qParentSet.feature_data_id;
					found=true;
					break;
				}
				if(qParentSet.feature_data_parent_id EQ 0){
					break;
				}else{
					parentId=qParentSet.feature_data_parent_id;
				}
				if(i EQ 50){
					throw("Infinite loop detected in group heirarchy");
				}
			}
		}
		if(not found){
			parentId=0;
		} 
		db.sql="select s1.feature_field_id labelFieldId, s2.feature_field_id valueFieldId ";
		 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
			db.sql&=",  s3.feature_field_id parentFieldID ";
		 }
		 db.sql&="
		from 
		 #db.table("feature_field", "jetendofeature")# s1 , 
		 #db.table("feature_field", "jetendofeature")# s2";
		 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
			db.sql&=",  #db.table("feature_field", "jetendofeature")# s3 ";
		 }
		 db.sql&=" WHERE 
		 s1.feature_field_deleted = #db.param(0)# and 
		 s2.feature_field_deleted = #db.param(0)# and
		s1.feature_schema_id = #db.param(ts.selectmenu_groupid)# and 
		s1.feature_field_name = #db.param(ts.selectmenu_labelfield)# and 
		
		s2.site_id = s1.site_id and 
		s2.feature_schema_id = #db.param(ts.selectmenu_groupid)# and 
		s2.feature_field_name = #db.param(ts.selectmenu_valuefield)# and 
		";
		 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
			db.sql&=" s3.site_id = s1.site_id and 
			s3.feature_schema_id = #db.param(ts.selectmenu_groupid)# and 
			s3.feature_field_name = #db.param(ts.selectmenu_parentfield)# and 
			s3.feature_field_deleted = #db.param(0)# and ";
		 }
		 db.sql&="
		s2.feature_id=#db.param(form.feature_id)#
		GROUP BY s2.site_id ";
		qTemp=db.execute("qTemp", "", 10000, "query", false);  

		if(qTemp.recordcount NEQ 0){
			db.sql="select 
			s1.feature_data_id id, 
			s1.site_x_option_group_value label,
			 s2.site_x_option_group_value value";
			 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
				db.sql&=", s3.site_x_option_group_value parentId ";
			//	db.sql&=", s3.site_x_option_group_value parentId ";
			 }
			 db.sql&=" from (
			 #db.table("feature_data", "jetendofeature")# set1,
			 #db.table("site_x_option_group", "jetendofeature")# s1 , 
			 #db.table("site_x_option_group", "jetendofeature")# s2 ";
			 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
				db.sql&=" ,#db.table("site_x_option_group", "jetendofeature")# s3";
			 }
			db.sql&=") WHERE ";
			if(parentID NEQ 0){
				db.sql&=" set1.feature_data_parent_id=#db.param(parentId)# and ";
			}
			db.sql&=" set1.feature_data_deleted=#db.param(0)# and 
			set1.feature_data_id=s1.feature_data_id and
			set1.site_id = s1.site_id and 
			s1.site_x_option_group_deleted = #db.param(0)# and 
			s2.site_x_option_group_deleted = #db.param(0)# and 
			s1.feature_field_id = #db.param(qTemp.labelFieldId)# and 
			s1.feature_schema_id = #db.param(ts.selectmenu_groupid)# and 
			s1.feature_data_id = s2.feature_data_id AND 
			s2.site_id = s1.site_id and 
			s2.feature_field_id = #db.param(qTemp.valueFieldId)# and 
			s2.feature_schema_id = #db.param(ts.selectmenu_groupid)# and ";
			 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
				db.sql&=" s3.site_id = s1.site_id and 
				s3.feature_field_id = #db.param(qTemp.parentFieldID)# and 
				s3.feature_schema_id = #db.param(ts.selectmenu_groupid)# and 
				s1.feature_data_id = s3.feature_data_id and 
				s3.site_x_option_group_deleted = #db.param(0)# and ";
			 }
			if(not structkeyexists(ts, 'selectmenu_parentfield') or ts.selectmenu_parentfield EQ ""){
				if(arguments.feature_schema_id EQ ts.selectmenu_groupid){
					// exclude current feature_data_id from query
					db.sql&="  s1.feature_data_id <> #db.param(form.feature_data_id)# and ";
				}
			}
			db.sql&=" s2.feature_id=#db.param(form.feature_id)#
			GROUP BY s1.feature_data_id, s2.feature_data_id
			ORDER BY label asc ";
			qTemp2=db.execute("qTemp2", "", 10000, "query", false); 
			//writedump(qtemp2);abort;
		}

		// ts.selectmenu_groupid
		// feature_schema_id=9
		if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
			ds=structnew();
			ds2=structnew();
			if(qTemp.recordcount NEQ 0){
				for(row2 in qTemp2){
					if(row2.parentId EQ ""){
						row2.parentId=0;
					}
					if(not structkeyexists(ds, row2.parentId)){
						ds[row2.parentId]={};
						ds2[row2.parentId]=[];
					}
					ds[row2.parentId][row2.id]={ value: row2.value, label:row2.label, id:row2.id, parentId:row2.parentId };
				}
			}
			for(n in ds){
				arrKey=structsort(ds[n], "text", "asc", "label");
				for(f=1;f LTE arraylen(arrKey);f++){
					arrayAppend(ds2[n], ds[n][arrKey[f]]);
				}
			}
			// all subcategories sorted, now do the combine + indent
			if(structkeyexists(ds2, "0")){
				arrCurrent=ds2["0"];
			}
			if(arguments.enableSearchView){
				for(n in ds){
					for(g in ds[n]){
						arrChildValues=[];
						arrChildValues=variables.getChildValues(ds, ds[n][g], arrChildValues, 1);
						arraySort(arrChildValues, "text");
						//ds[n][g].value=arrayToList(arrChildValues, delimiter);
						ds[n][g].idChild=arrayToList(arrChildValues, delimiter);
					}
				}
			}
			if(structkeyexists(ds2, "0")){
//				writedump(arguments.setoptionstruct);				writedump(ds2);				writedump(ds);				writedump(arrValue);				abort;/**/
				variables.rebuildParentStructData(ds2, arrLabel, arrValue, arrCurrent, 0);
			}
		}
	}
	rs= { 
		ts: ts, 
		arrLabel: arrLabel, 
		arrValue: arrValue
	};
	if(structkeyexists(local, 'qTemp2')){
		rs.qTemp2=qTemp2;
	}
	return rs;
	</cfscript>
</cffunction>


 
<!--- application.zcore.siteFieldCom.activateFieldAppId(feature_id); --->
<cffunction name="activateFieldAppId" localmode="modern" returntype="any" output="no">
	<cfargument name="feature_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	 db.sql="UPDATE #db.table("feature", "jetendofeature")# feature 
	 SET feature_active = #db.param('1')#, 
	 feature_updated_datetime=#db.param(request.zos.mysqlnow)# 
	 WHERE feature_id=#db.param(arguments.feature_id)# and 
	 feature_deleted = #db.param(0)# and 
	 feature_id=#db.param(form.feature_id)#";
	 db.execute("q");
	</cfscript>
</cffunction>


<!--- /z/_com/app/site-option?method=getNewFieldAppId --->
<cffunction name="getNewFieldAppId" localmode="modern" access="remote" roles="member" returntype="any" output="no">
	<cfargument name="app_id" type="string" required="yes">
	<cfscript>
	ts.datasource="jetendofeature";
	ts.table="feature";
	ts.struct=structnew();
	ts.struct.site_id=request.zos.globals.id;
	ts.struct.app_id=arguments.app_id;
	ts.struct.feature_active=0;
	//ts.debug=true;
	//ts.struct.feature_datetime=request.zos.mysqlnow;
	feature_id=application.zcore.functions.zInsert(ts);
	if(feature_id EQ false){
		application.zcore.template.fail("Error: zcorerootmapping.com.app.site-option.cfc - getNewFieldAppId() failed to insert into feature.");
	}
	if(application.zcore.functions.zso(form, 'method') EQ 'getNewFieldAppId'){
		writeoutput('new id:'&feature_id);
		application.zcore.functions.zabort();
	}else{
		return feature_id;
	}
	</cfscript>
</cffunction>

<!--- this.getFieldAppById(feature_id, app_id, newOnMissing); --->
<!--- <cffunction name="getFieldAppById" localmode="modern" returntype="any" output="yes">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="app_id" type="string" required="yes">
	<cfargument name="newOnMissing" type="boolean" required="no" default="#true#">
	<cfscript>
	var qG=0;
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #request.zos.queryObject.table("feature", "jetendofeature")# feature 
	WHERE feature_id = #db.param(arguments.feature_id)# and 
	feature_deleted = #db.param(0)# and 
	feature_id =#db.param(form.feature_id)#";
	qG=db.execute("qG");
	if(qG.recordcount EQ 0){
		if(arguments.newOnMissing){
			arguments.feature_id=this.getNewFieldAppId(arguments.app_id);
			db.sql="SELECT * FROM #request.zos.queryObject.table("feature", "jetendofeature")# feature 
			WHERE feature_id = #db.param(arguments.feature_id)# and 
			feature_deleted = #db.param(0)# and
			feature_id =#db.param(form.feature_id)#";
			qG=db.execute("qG");
		}else{
			return false;
		}
	}
	return qG;
	</cfscript>
</cffunction> 
 --->
<!--- application.zcore.siteFieldCom.deleteFieldAppId(feature_id); --->
<cffunction name="deleteFieldAppId" localmode="modern" returntype="any" output="no">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var q=0;
	var db=request.zos.queryObject;
	typeStruct=getTypeData(arguments.site_id);
	if(arguments.feature_id NEQ 0 and arguments.feature_id NEQ ""){
		db.sql="SELECT * FROM #request.zos.queryObject.table("site_x_option", "jetendofeature")# site_x_option, 
		#request.zos.queryObject.table("feature_field", "jetendofeature")# feature_field 
		WHERE site_x_option.feature_id=#db.param(form.feature_id)# and 
		site_x_option_deleted = #db.param(0)# and 
		feature_field_deleted = #db.param(0)# and 
		feature_field.site_id=#db.param(arguments.site_id)# and  
		site_x_option.feature_field_id = feature_field.feature_field_id and 
		site_x_option.feature_id=#db.param(arguments.feature_id)# and 
		feature_field_type_id IN (#db.param(3)#, #db.param(9)#) and 
		site_x_option_value <> #db.param('')# and 
		feature_field_type_id=#db.param('3')#";
		path=application.zcore.functions.zvar('privatehomedir',arguments.site_id)&'zupload/site-options/';
		securepath=application.zcore.functions.zvar('privatehomedir',arguments.site_id)&'zuploadsecure/site-options/';
		qS=db.execute("qS");
		for(i=1;i LTE qS.recordcount;i++){
			optionStruct=typeStruct.optionLookup[row.feature_field_id].optionStruct;
			if(application.zcore.functions.zso(optionStruct, 'file_securepath') EQ 'Yes'){
				if(fileexists(securepath&qS.site_x_option_value[i])){
					application.zcore.functions.zdeletefile(securepath&qS.site_x_option_value[i]);
				}
			}else{
				if(fileexists(path&qS.site_x_option_value[i])){
					application.zcore.functions.zdeletefile(path&qS.site_x_option_value[i]);
				}
				if(qS.site_x_option_original[i] NEQ "" and fileexists(path&qS.site_x_option_value[i])){
					application.zcore.functions.zdeletefile(path&qS.site_x_option_original[i]);
				}
			}
		}
		db.sql="SELECT * FROM #request.zos.queryObject.table("site_x_option_group", "jetendofeature")# site_x_option_group, 
		#request.zos.queryObject.table("feature_field", "jetendofeature")# feature_field 
		WHERE site_x_option_group.feature_id=#db.param(form.feature_id)# and 
		feature_field.site_id=#db.param(arguments.site_id)# and  
		site_x_option_group.feature_field_id = feature_field.feature_field_id and 
		site_x_option_group.feature_id=#db.param(arguments.feature_id)# and 
		feature_field_type_id IN (#db.param(3)#, #db.param(9)#) and 
		site_x_option_group_value <> #db.param('')# and 
		feature_field_deleted = #db.param(0)# and 
		site_x_option_group_deleted = #db.param(0)# and 
		feature_field_type_id=#db.param('3')#";
		qS=db.execute("qS");
		for(i=1;i LTE qS.recordcount;i++){
			optionStruct=typeStruct.optionLookup[row.feature_field_id].optionStruct;
			if(application.zcore.functions.zso(optionStruct, 'file_securepath') EQ 'Yes'){
				if(fileexists(securepath&qS.site_x_option_group_value[i])){
					application.zcore.functions.zdeletefile(securepath&qS.site_x_option_group_value[i]);
				}
			}else{
				if(fileexists(path&qS.site_x_option_group_value[i])){
					application.zcore.functions.zdeletefile(path&qS.site_x_option_group_value[i]);
				}
				if(qS.site_x_option_group_original[i] NEQ "" and fileexists(path&qS.site_x_option_group_original[i])){
					application.zcore.functions.zdeletefile(path&qS.site_x_option_group_original[i]);
				}
			}
		}
		
		db.sql="DELETE FROM #request.zos.queryObject.table("site_x_option", "jetendofeature")#  
		WHERE feature_id = #db.param(arguments.feature_id)# and 
		site_x_option_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		q=db.execute("q");
		db.sql="DELETE FROM #request.zos.queryObject.table("site_x_option_group", "jetendofeature")#  
		WHERE feature_id = #db.param(arguments.feature_id)# and 
		site_x_option_group_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		q=db.execute("q");
		db.sql="DELETE FROM #request.zos.queryObject.table("feature_data", "jetendofeature")#  
		WHERE feature_id = #db.param(arguments.feature_id)# and 
		feature_data_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		q=db.execute("q");
		db.sql="DELETE FROM #request.zos.queryObject.table("feature", "jetendofeature")#  
		WHERE feature_id = #db.param(arguments.feature_id)# and 
		feature_deleted = #db.param(0)# and 
		 site_id = #db.param(arguments.site_id)#";
		q=db.execute("q");

		// Need more efficient way to rebuild after feature_id delete - or remove this feature perhaps
		application.zcore.functions.zOS_cacheSiteAndUserSchemas(arguments.site_id);
	}
	</cfscript>
</cffunction>





<!--- 
// you must have a group by in your query or it may miss rows
ts=structnew();
ts.feature_id_field="rental.rental_feature_id";
ts.count = 1; // how many images to get
application.zcore.siteFieldCom.getImageSQL(ts);
 --->
<cffunction name="getImageSQL" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qImages=0;
	var arrOutput=arraynew(1);
	var ts=structnew();
	var rs=structnew();
	ts.feature_id_field="";
	ts.count=1;
	ss=arguments.ss;
	structappend(ss,ts,false);
	if(structkeyexists(ss, 'db')){
		db=ss.db;
	}else{
		db=request.zos.queryObject;
	}
	if(ss.feature_id_field EQ ""){
		application.zcore.template.fail("Error: zcorerootmapping.com.app.site-option.cfc - displayImages() failed because ss.feature_id_field is required.");	
	}
	rs.leftJoin="LEFT JOIN `"&"jetendofeature"&"`.image ON "&ss.feature_id_field&" = image.feature_id and image_sort <= #db.param(ss.count)# and image.feature_id=#db.param(form.feature_id)#";
	rs.select=", cast(GROUP_CONCAT(image_id ORDER BY image_sort SEPARATOR '\t') as char) imageIdList, 
	cast(GROUP_CONCAT(image_caption ORDER BY image_sort SEPARATOR '\t') as char) imageCaptionList, 
	cast(GROUP_CONCAT(image_file ORDER BY image_sort SEPARATOR '\t') as char) imageFileList, 
	cast(GROUP_CONCAT(image_updated_datetime ORDER BY image_sort SEPARATOR '\t') as char) imageUpdatedDateList";
	return rs;
	</cfscript>
</cffunction>






<!--- 
var ts=application.zcore.functions.zGetEditableSiteSchemaSetById(groupStruct.__groupId, groupStruct.__setId);
ts.name="New name";
var rs=application.zcore.functions.zUpdateSiteSchemaSet(ts);
if(not rs.success){
	application.zcore.status.setStatus(rs.zsid, false, form, true);
	application.zcore.functions.zRedirect("/?zsid=#rs.zsid#");
}else{
	writeoutput('Success !');
}
 --->
<cffunction name="updateSchemaSet" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var optionsCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.features"); 
	db.sql="SELECT * FROM #db.table("feature_field", "jetendofeature")# feature_field,
	 #db.table("feature_schema", "jetendofeature")# feature_schema 
	 WHERE 
	 feature_field.site_id = feature_schema.site_id and 
	 feature_field.feature_schema_id = feature_schema.feature_schema_id and 
	feature_schema.feature_schema_id = #db.param(arguments.struct.feature_schema_id)# and 
	feature_field_deleted = #db.param(0)# and 
	feature_schema_deleted = #db.param(0)# and 
	feature_schema.site_id = #db.param(arguments.struct.site_id)#  ";
	var qD=db.execute("qD");
	structappend(form, arguments.struct, true);
	var arroption=[];
	for(var row in qD){
		arrayAppend(arroption, row.feature_field_id);
		// doesn't work with time/date and other multi-field site option types probably...
		form['newvalue'&row.feature_field_id]=arguments.struct[row.feature_field_name];
	}
	form.feature_field_id=arrayToList(arroption, ','); 
	var rs=optionsCom.internalSchemaUpdate(); 
	return rs;
	</cfscript>
</cffunction>


<cffunction name="getEditableSchemaSetById" localmode="modern" access="public">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfargument name="feature_data_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="no" default="#request.zos.globals.id#">  
	<cfscript>
	var s=getSchemaSetById(arguments.arrSchemaName, arguments.feature_data_id);
	var db=request.zos.queryObject;
	if(arguments.site_id NEQ request.zos.globals.id){
		throw("zGetEditableSchemaSetById() doesn't support other site ids yet.");
	}
	if(structcount(s) EQ 0){
		throw("feature_data_id, #arguments.feature_data_id#, doesn't exist, so it can't be edited.");
	}
	db.sql="select * from #db.table("feature_data", "jetendofeature")# WHERE 
	feature_data_id= #db.param(arguments.feature_data_id)# and 
	feature_data_deleted = #db.param(0)# and 
	site_id = #db.param(arguments.site_id)# ";
	var qS=db.execute("qS");
	if(qS.recordcount EQ 0){
		throw("feature_data_id, #arguments.feature_data_id#, doesn't exist, so it can't be edited.");
	}
	var n={};
	for(var i in s){
		if(s[i] EQ "/zupload/site-option/0"){
			n[i]="";
		}else if(left(i, 2) NEQ "__"){
			n[i]=s[i];
		}
	} 
	structappend(n, qS, false);
	return n;
	</cfscript>
</cffunction>





<cffunction name="var" localmode="modern" output="false" returntype="string">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="">
	<cfargument name="disableEditing" type="boolean" required="no" default="#false#">
	<cfargument name="feature_id" type="string" required="no" default="0">
     <cfscript>
	 var start="";
	 var end="";
	 if(arguments.site_id EQ "" and structkeyexists(request.zos, 'globals') and structkeyexists(request.zos.globals, 'id')){
	 	arguments.site_id=request.zos.globals.id;
	 }
	 var contentConfig=structnew();
	 if(application.zcore.app.siteHasApp("content")){
		 contentConfig=application.zcore.app.getAppCFC("content").getContentIncludeConfig();
	 }else{
		 contentConfig.contentEmailFormat=false;
	 }
	 if(arguments.name EQ 'Visitor Tracking Code'){
	 	disabled=false;
	 	if(structkeyexists(request.zos.userSession.groupAccess, "member") or request.zos.istestserver){
			disabled=true;
		}else if(structkeyexists(request.zos, 'trackingDisabled') and request.zos.trackingDisabled){
			disabled=true;
		}
		if(disabled){
			return '<script type="text/javascript">var zVisitorTrackingDisabled=true; </script>';
		}
	 } 
	if(arguments.disableEditing EQ false and contentConfig.contentEmailFormat EQ false){
		// and structkeyexists(application.zcore,'user') and structkeyexists(request.zos.userSession, 'groupAccess') and (structkeyexists(request.zos.userSession.groupAccess, "administrator")) 
		start='<div style="display:inline;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/feature/admin/features/index?returnURL=#urlencodedformat(request.zos.originalURL)#&amp;jumpto=soid_#application.zcore.functions.zURLEncode(arguments.name,"_")#">';
		end='</div>';
	}
	if(arguments.feature_id EQ 0){
		if(structkeyexists(Request.zOS.globals,"feature_fields") and structkeyexists(Request.zOS.globals.feature_fields,arguments.name)){
			if(Request.zOS.globals.feature_field_edit_enabled[arguments.name] EQ 0){
				start="";
				end="";
			}
			if(arguments.site_id EQ request.zos.globals.id){
				return start&Request.zOS.globals.feature_fields[arguments.name]&end;
			}else{
				return start&application.siteStruct[arguments.site_id].globals.feature_fields[arguments.name]&end;
			}
		}else{
			//application.zcore.template.fail("zVarSO: `#arguments.name#`, is not a site option.");
			return "";//Field Missing: #arguments.name#";		
		}
	}else{
		if(structkeyexists(Request.zOS.globals,"feature") and structkeyexists(Request.zOS.globals.feature, arguments.feature_id) and structkeyexists(Request.zOS.globals.feature[arguments.feature_id],arguments.name)){
			if(Request.zOS.globals.feature_field_edit_enabled[arguments.name] EQ 0){
				start="";
				end="";
			}
			if(arguments.site_id EQ request.zos.globals.id){
				return start&Request.zOS.globals.feature[arguments.feature_id][arguments.name]&end;
			}else{
				return start&application.siteStruct[arguments.site_id].globals.feature[arguments.feature_id][arguments.name]&end;
			}
		}else{
			//application.zcore.template.fail("zVarSO: `#arguments.name#`, is not a site option.");
			return "";//Field Missing: #arguments.name#";		
		}
	}
	</cfscript>
</cffunction>

<!--- <cffunction name="writeLogEntry" localmode="modern" access="private">
	<cfargument name="message" type="string" required="yes">
	<cfscript>
	if(request.zos.isdeveloper){
		p=request.zos.globals.privateHomeDir&"import-ralsc.txt"; 
		f=fileopen(p, "append", "utf-8");
		filewriteline(f, dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss")&": "&arguments.message);
		fileclose(f);
	}
	</cfscript>
</cffunction> --->

<cffunction name="deleteSchemaSetRecursively" localmode="modern" access="public" roles="member">
	<cfargument name="feature_data_id" type="numeric" required="yes">
	<cfargument name="rowData" type="struct" required="no" default="#{}#">
	<cfscript>
	if(arguments.feature_data_id EQ 0){
		// dangerous, this causes an infinite loop.
		throw("There is a feature_data_id that is 0 on this site.  It must be manually deleted from the database to avoid infinite loops and other serious problems.");
	}
	db=request.zos.queryObject;
	if(structcount(arguments.rowData) EQ 0){
		db.sql="SELECT * FROM #db.table("feature_data", "jetendofeature")# 
		WHERE  feature_data_id=#db.param(arguments.feature_data_id)# and  
		feature_data_deleted = #db.param(0)# and 
		feature_data.feature_id=#db.param(form.feature_id)#  ";
		qSet=db.execute("qSet");
		if(qSet.recordcount EQ 0){
			return;
		}
		for(i in qSet){
			row=i;
		}
	}else{
		row=arguments.rowData;
	}
	//writeLogEntry("deleteSchemaSetRecursively set id:"&arguments.feature_data_id);
	db.sql="SELECT * FROM #db.table("feature_data", "jetendofeature")# 
	WHERE  feature_data_parent_id=#db.param(arguments.feature_data_id)# and  
	feature_data_deleted = #db.param(0)# and
	feature_data.feature_id=#db.param(form.feature_id)#  ";
	qSets=db.execute("qSets");
	for(row2 in qSets){
		deleteSchemaSetRecursively(row2.feature_data_id, {});
	}
	if(row.feature_data_image_library_id NEQ 0){
		//writeLogEntry("deleteImageLibrary id:"&row.feature_data_image_library_id);
		application.zcore.imageLibraryCom.deleteImageLibraryId(row.feature_data_image_library_id);
	}
	// delete versions
	if(row.feature_data_master_set_id EQ 0){
		db.sql="SELECT * FROM #db.table("feature_data", "jetendofeature")# 
		WHERE  feature_data_master_set_id=#db.param(arguments.feature_data_id)# and  
		feature_data_deleted = #db.param(0)# and
		feature_data.feature_id=#db.param(form.feature_id)#  ";
		qVersion=db.execute("qVersion");
		for(row2 in qVersion){
			//writeLogEntry("deleteSchemaSetRecursively version set id:"&row2.feature_data_id);
			deleteSchemaSetRecursively(row2.feature_data_id);
		}
	}

	if(arraylen(application.zcore.soSchemaData.arrCustomDelete)){
		typeIdList=arrayToList(application.zcore.soSchemaData.arrCustomDelete, ",");

		db.sql="SELECT * FROM 
		#db.table("site_x_option_group", "jetendofeature")#,
		#db.table("feature_field", "jetendofeature")#  
		WHERE feature_data_id=#db.param(arguments.feature_data_id)# and 
		feature_field_type_id in (#db.trustedSQL(typeIdList)#) and 
		site_x_option_group.feature_id=#db.param(form.feature_id)# and 
		feature_field.site_id = site_x_option_group.site_id and 
		site_x_option_group_value <> #db.param('')# and 
		feature_field_deleted = #db.param(0)# and 
		site_x_option_group_deleted = #db.param(0)# and
		feature_field.feature_field_id = site_x_option_group.feature_field_id ";
		qFields=db.execute("qFields");
		//writeLogEntry("#qFields.recordcount# qFields records that need onDelete");
		path=application.zcore.functions.zvar('privatehomedir', request.zos.globals.id)&'zupload/site-options/';
		securepath=application.zcore.functions.zvar('privatehomedir', request.zos.globals.id)&'zuploadsecure/site-options/';
		siteStruct=application.zcore.functions.zGetSiteGlobals(request.zos.globals.id);
		sog=siteStruct.soSchemaData;
		for(row2 in qFields){
			if(structkeyexists(sog.optionLookup, row2.feature_field_id)){
				var currentCFC=application.zcore.siteFieldCom.getTypeCFC(sog.optionLookup[row2.feature_field_id].type); 
				if(currentCFC.hasCustomDelete()){
					optionStruct=sog.optionLookup[row2.feature_field_id].optionStruct;
					//writeLogEntry("delete for feature_field_id:"&row2.feature_field_id&" type:"&sog.optionLookup[row2.feature_field_id].type);
					currentCFC.onDelete(row2, optionStruct); 
				}
			}
		}
	}   

	//writeLogEntry("deleteSchemaSetIndex version set id:"&arguments.feature_data_id);
	deleteSchemaSetIndex(arguments.feature_data_id, request.zos.globals.id);
	db.sql="DELETE FROM #db.table("site_x_option_group", "jetendofeature")#  
	WHERE  feature_data_id=#db.param(arguments.feature_data_id)# and  
	site_x_option_group_deleted = #db.param(0)# and 
	feature_id=#db.param(form.feature_id)# ";
	result =db.execute("result");
	//writeLogEntry("deleted set values for set id:"&arguments.feature_data_id);
	
	db.sql="DELETE FROM #request.zos.queryObject.table("feature_data", "jetendofeature")#  
	WHERE  feature_data_id=#db.param(arguments.feature_data_id)# and  
	feature_data_deleted = #db.param(0)# and 
	feature_id=#db.param(form.feature_id)# ";
	result =db.execute("result");
	//writeLogEntry("deleted set for set id:"&arguments.feature_data_id);

	
	t9=application.zcore.siteGlobals[request.zos.globals.id].soSchemaData;
	groupStruct=t9.optionSchemaLookup[row.feature_schema_id]; 
	
	if(structkeyexists(groupStruct, 'feature_schema_change_cfc_path') and groupStruct.feature_schema_change_cfc_path NEQ ""){
		path=groupStruct.feature_schema_change_cfc_path;
		if(left(path, 5) EQ "root."){
			path=request.zRootCFCPath&removeChars(path, 1, 5);
		}
		changeCom=application.zcore.functions.zcreateObject("component", path); 
		//writeLogEntry("changeCom callback for set id:"&arguments.feature_data_id);
		changeCom[groupStruct.feature_schema_change_cfc_delete_method](arguments.feature_data_id);
	}
	</cfscript>
</cffunction>
	

<cffunction name="deleteSchemaRecursively" localmode="modern" access="public" roles="member">
	<cfargument name="feature_schema_id" type="numeric" required="yes">
	<cfargument name="rebuildSiteCache" type="boolean" required="no" default="#true#">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var result=0;
	siteStruct=application.zcore.functions.zGetSiteGlobals(request.zos.globals.id);
	sog=siteStruct.soSchemaData;
	db.sql="SELECT * FROM #db.table("feature_schema", "jetendofeature")#  
	WHERE  feature_schema_parent_id=#db.param(arguments.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qSchemas=db.execute("qSchemas");
	for(row in qSchemas){
		deleteSchemaRecursively(row.feature_schema_id, false);	
	}
	 
	db.sql="SELECT * FROM #db.table("feature_data", "jetendofeature")# 
	WHERE  feature_data.feature_schema_id=#db.param(arguments.feature_schema_id)# and  
	feature_data_deleted = #db.param(0)# and
	feature_data.feature_id=#db.param(form.feature_id)#  ";
	qSets=db.execute("qSets");
	for(row in qSets){
		if(row.feature_data_image_library_id NEQ 0){
			application.zcore.imageLibraryCom.deleteImageLibraryId(row.feature_data_image_library_id);
		}
	}

	db.sql="SELECT * FROM #db.table("feature_field", "jetendofeature")#, 
	#db.table("site_x_option_group", "jetendofeature")#  
	WHERE  site_x_option_group.feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_field_type_id in (#db.param(3)#, #db.param(9)#) and 
	site_x_option_group.feature_id=#db.param(form.feature_id)# and 
	feature_field.site_id = site_x_option_group.site_id and 
	site_x_option_group_value <> #db.param('')# and 
	feature_field_deleted = #db.param(0)# and 
	site_x_option_group_deleted = #db.param(0)# and
	feature_field.feature_field_id = site_x_option_group.feature_field_id ";
	qFields=db.execute("qFields");
	path=application.zcore.functions.zvar('privatehomedir', request.zos.globals.id)&'zupload/site-options/';
	securepath=application.zcore.functions.zvar('privatehomedir', request.zos.globals.id)&'zuploadsecure/site-options/';
	for(row in qFields){
		if(structkeyexists(sog.optionLookup, row.feature_field_id)){
			var currentCFC=application.zcore.siteFieldCom.getTypeCFC(sog.optionLookup[row.feature_field_id].type); 
			if(currentCFC.hasCustomDelete()){
				optionStruct=sog.optionLookup[row.feature_field_id].optionStruct;
				currentCFC.onDelete(row, optionStruct); 
			}
		}
	}
	db.sql="DELETE FROM #db.table("site_x_option_group", "jetendofeature")#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	site_x_option_group_deleted = #db.param(0)# and 
	feature_id=#db.param(form.feature_id)# ";
	result =db.execute("result");
	db.sql="DELETE FROM #request.zos.queryObject.table("feature_data", "jetendofeature")#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_data_deleted = #db.param(0)# and 
	feature_id=#db.param(form.feature_id)# ";
	result =db.execute("result");
	
	db.sql="DELETE FROM #db.table("feature_schema_map", "jetendofeature")#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_schema_map_deleted = #db.param(0)# and 
	feature_id=#db.param(form.feature_id)# ";
	result =db.execute("result");
	db.sql="DELETE FROM #db.table("feature_field", "jetendofeature")#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_field_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	result =db.execute("result");
	db.sql="DELETE FROM #db.table("feature_schema", "jetendofeature")#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and 
	feature_id=#db.param(form.feature_id)# ";
	result =db.execute("result"); 

	if(arguments.rebuildSiteCache){
		application.zcore.functions.zOS_cacheSiteAndUserSchemas(request.zos.globals.id);
	}

	</cfscript>
</cffunction>
 
<cffunction name="userDashboardAdmin" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject; 
	db.sql="select * from #db.table("feature_schema", "jetendofeature")# 
	WHERE feature_id=#db.param(form.feature_id)# and 
	feature_schema_enable_user_dashboard_admin=#db.param(1)# and 
	feature_schema_deleted=#db.param(0)# 
	ORDER BY feature_schema_parent_id ASC, feature_schema_display_name ASC";
	qSchema=db.execute("qSchema");
	for(row in qSchema){ 
		if(row.feature_schema_parent_id NEQ 0){
			continue;
		}
		if(row.feature_schema_user_group_id_list EQ ""){
			continue;
		}
		arrSchema=listToArray(row.feature_schema_user_group_id_list, ",");
		hasAccess=false;
		for(groupId in arrSchema){
			if(application.zcore.user.checkSchemaIdAccess(groupId)){
				hasAccess=true;
				break;
			}
		}
		if(not hasAccess){
			continue;
		}
		if(row.feature_schema_subgroup_alternate_admin EQ 1){
			if(row.feature_schema_user_child_limit EQ 1){
				currentUserIdValue=request.zsession.user.id&"|"&application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
				db.sql="select * from #db.table("feature_data", "jetendofeature")# 
				WHERE feature_id=#db.param(form.feature_id)# and 
				feature_schema_id=#db.param(row.feature_schema_id)# and  
				feature_data_deleted=#db.param(0)# and 
				feature_data_user = #db.param(currentUserIdValue)# 
				ORDER BY feature_data_sort ASC";
				qSet=db.execute("qSet"); 
				if(qSet.recordcount EQ 0){
					echo('<h2><a href="/z/feature/admin/features/userAddSchema?feature_id=0&feature_data_id=&feature_schema_id=#row.feature_schema_id#&feature_data_parent_id=0">Add #row.feature_schema_display_name#</a></h2>');
				}else{
					echo('<h2><a href="/z/feature/admin/features/userEditSchema?feature_id=0&feature_data_id=#qSet.feature_data_id#&feature_schema_id=#row.feature_schema_id#&feature_data_parent_id=0">Edit #row.feature_schema_display_name#</a></h2>');
					echo('<ul>');
					for(row2 in qSchema){
						if(row2.feature_schema_parent_id EQ row.feature_schema_id){
							echo('<li><a href="/z/feature/admin/features/userManageSchema?feature_id=0&feature_schema_id=#row2.feature_schema_id#&feature_data_parent_id=#qSet.feature_data_id#">Manage #row.feature_schema_display_name#(s)</a></li>');
						}
					}
					echo('</ul>');
				}
			}else{
				echo('<h2><a href="/z/feature/admin/features/userManageSchema?feature_id=0&feature_schema_id=#row.feature_schema_id#&feature_data_parent_id=0">Manage #row.feature_schema_display_name#(s)</a> | 
					<a href="/z/feature/admin/features/userAddSchema?feature_id=0&feature_schema_id=#row.feature_schema_id#&feature_data_parent_id=0">Add #row.feature_schema_display_name#</a></h2>');
			//	echo('<li><a href="/z/feature/admin/features/userAddSchema?feature_id=0&feature_schema_id=#row.feature_schema_id#&feature_data_parent_id=0">Add #row.feature_schema_display_name#(s)</a></li>');
			}
		}else{
			echo('<h2><a href="/z/feature/admin/features/userManageSchema?feature_id=0&feature_schema_id=#row.feature_schema_id#&feature_data_parent_id=0">Manage #row.feature_schema_display_name#(s)</a> | 
			<a href="/z/feature/admin/features/userAddSchema?feature_id=0&feature_schema_id=#row.feature_schema_id#&feature_data_parent_id=0">Add #row.feature_schema_display_name#</a></h2>');
		}
	} 
	</cfscript>
</cffunction> 

<cffunction name="sendChangeEmail" localmode="modern" access="public">
	<cfargument name="feature_data_id" type="string" required="yes">
	<cfargument name="action" type="string" required="yes" hint="values are created|updated|deleted ">
	<cfscript>
	if(application.zcore.functions.zso(form, 'method') CONTAINS "import" or request.zos.originalURL CONTAINS "import" or structkeyexists(request.zos, 'sendChangeEmailSiteSchemaExecuted')){
		return;
	}
	request.zos.sendChangeEmailSiteSchemaExecuted=true;
	db=request.zos.queryObject; 
	if(application.zcore.user.checkSchemaAccess("member")){
		return;
	}
	currentSetId=arguments.feature_data_id;
	first=true;
	while(true){
		if(not first){ 
			request.isUserPrimarySchema=false;
		} 
		first=false;
		db.sql="select * from #db.table("feature_data", "jetendofeature")# WHERE 
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
	if(qCheckSet.feature_data_user NEQ ""){
		arrUser=listToArray(qCheckSet.feature_data_user, "|");
		site_id=application.zcore.functions.zGetSiteIdFromSiteIdType(arrUser[2]);
	}
	user_id=qCheckSet.feature_data_user
	db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# WHERE 
	user_deleted=#db.param(0)# and 
	site_id = #db.param(site_id)# and 
	user_id=#db.param(arrUser[1])# ";
	qUser=db.execute("qUser");
	
	db.sql="select * from #db.table("feature_schema", "jetendofeature")# WHERE 
	feature_schema_deleted=#db.param(0)# and 
	feature_id=#db.param(form.feature_id)# and 
	feature_schema_id=#db.param(qCheckSet.feature_schema_id)# ";
	qSchema=db.execute("qSchema");
	groupName=qSchema.feature_schema_display_name;
	
	ts={};
	ts.from=request.fromemail;
	ts.to=application.zcore.functions.zvarso("zofficeemail");
	if(ts.to EQ ""){
		ts.to=request.zos.developerEmailTo;
	}
	if(request.zos.isTestServer){
		ts.to=request.zos.developerEmailTo;
	}
	ts.subject="#groupName# has been #arguments.action# on #request.zos.cgi.http_host#";
	ts.html='<!DOCTYPE html>
	<html>
	<head><title>Alert</title></head>
	<body>
	<h3>The following #groupName# has been #arguments.action# on <a href="#request.zos.globals.domain#" target="_blank">#request.zos.globals.shortDomain#</a>.</h3>';
	
	if(qUser.recordcount){
		ts.html&='<p>User: #qUser.user_first_name# #qUser.user_last_name# (#qUser.user_email#)</p>';
	} 
	ts.html&='<p>#qCheckSet.feature_data_title#</p> 
	<p>'; 
	if(arguments.action NEQ "deleted"){
		if(qSchema.feature_schema_enable_unique_url EQ 1){
			if(qCheckSet.feature_data_override_url NEQ ""){
				link=qCheckSet.feature_data_override_url;
			}else{
				var urlId=50;
				if(urlId EQ "" or urlId EQ 0){
					throw("feature_schema_url_id is not set for site_id, #site_id#.");
				}
				link="/#application.zcore.functions.zURLEncode(qCheckSet.feature_data_title, '-')#-#urlId#-#qCheckSet.feature_data_id#.html";
			}
			ts.html&='<a href="#request.zos.globals.domain##link#" target="_blank">View</a> | ';
		}
		ts.html&='<a href="#request.zos.globals.domain#/z/feature/admin/features/editSchema?feature_id=0&amp;feature_schema_id=#qCheckSet.feature_schema_id#&amp;feature_data_id=#qCheckSet.feature_data_id#&amp;feature_data_parent_id=0" target="_blank">Edit</a>';
	}
	ts.html&=' | <a href="#request.zos.globals.domain#/z/feature/admin/features/manageSchema?feature_id=0&feature_schema_id=#qCheckSet.feature_schema_id#" target="_blank">Manage #groupName#(s)</a></p>
	
	<p>If you want to stop receiving these messages, please contact the web developer.</p>
	</body></html>';
	
	rCom=application.zcore.email.send(ts);
	if(rCom.isOK() EQ false){
		rCom.setStatusErrors(request.zsid);
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zabort();
	}
	</cfscript>
</cffunction>

<!--- 
rs=application.zcore.siteFieldCom.deleteNotUpdatedSchemaSet(["groupName"]); 
application.zcore.status.setStatus(request.zsid, rs.deleteCount&" old records deleted");
--->
<cffunction name="deleteNotUpdatedSchemaSet" localmode="modern" access="public" returnType="struct">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfscript>
	groupId=getSchemaIdWithNameArray(arguments.arrSchemaName, request.zos.globals.id);
	db=request.zos.queryObject;
	db.sql="SELECT * FROM 
	#db.table("feature_data", "jetendofeature")# WHERE 
	feature_data_deleted = #db.param(0)# and 
	feature_data_updated_datetime < #db.param(request.zos.mysqlnow)# and 
	feature_schema_id= #db.param(groupId)# and 
	site_id= #db.param(request.zos.globals.id)#";
	qSet=db.execute("qSet"); 
	rs={ success:true, deleteCount:0 };
	for(row in qSet){
		deleteSchemaSetRecursively(row.feature_data_id, row);
		rs.deleteCount++;
	}
	return rs;
	</cfscript>

</cffunction>

</cfoutput>
</cfcomponent>