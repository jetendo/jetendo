<cfcomponent extends="zcorerootmapping.com.app.option-base">
<cfoutput> 
<cffunction name="getOptionTypes" returntype="struct" localmode="modern" access="public">
	<cfscript>
	ts=getOptionTypeCFCs();
	for(i in ts){
		ts[i].init("site", "site");
	}
	return ts;
	</cfscript>
</cffunction>


<cffunction name="getTypeData" returntype="struct" localmode="modern" access="public">
	<cfargument name="site_id" type="string" required="yes" hint="site_id">
	<cfscript>
	return application.siteStruct[arguments.site_id].globals.soGroupData;
	</cfscript>
</cffunction>
 


 

<cffunction name="updateOptionGroupCache" access="public" localmode="modern">
	<cfargument name="siteStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject; 
	db.sql="SELECT site_option_group_id FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_id =#db.param(arguments.siteStruct.id)# and 
	site_option_group_deleted = #db.param(0)# 
	ORDER BY site_option_group_parent_id asc";
	qS=db.execute("qS"); 
	for(row in qS){
		internalUpdateOptionGroupCacheByGroupId(arguments.siteStruct, row.site_option_group_id);
	} 
	</cfscript>
</cffunction>




<!--- application.zcore.siteOptionCom.updateAllSitesOptionCache(); --->
<cffunction name="updateAllSitesOptionCache" access="public" localmode="modern">  
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT site_id FROM #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_id <>#db.param(-1)# and 
	site_active=#db.param(1)# and 
	site_deleted = #db.param(0)#";
	qS=db.execute("qS"); 
	for(row in qS){
		updateOptionCache(row.site_id);
	} 
	</cfscript>
</cffunction>
<!--- application.zcore.siteOptionCom.updateOptionCache(); --->
<cffunction name="updateOptionCache" access="public" localmode="modern"> 
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	siteStruct=application.zcore.functions.zGetSiteGlobals(arguments.site_id); 
	internalUpdateOptionOptionCache(siteStruct);

	application.zcore.functions.zCacheJsonSiteAndUserGroup(arguments.site_id, siteStruct);
	</cfscript>
</cffunction>

<!--- application.zcore.siteOptionCom.updateOptionGroupCacheByGroupId(optionGroupId); --->
<cffunction name="updateOptionGroupCacheByGroupId" access="public" localmode="modern">
	<cfargument name="optionGroupId" type="string" required="yes">
	<cfscript>
	siteStruct=application.zcore.functions.zGetSiteGlobals(request.zos.globals.id);
	internalUpdateOptionGroupCacheByGroupId(siteStruct, arguments.optionGroupId);
	application.zcore.functions.zCacheJsonSiteAndUserGroup(request.zos.globals.id, siteStruct);
	</cfscript>
</cffunction>


<cffunction name="internalUpdateOptionGroupCacheByGroupId" access="public" localmode="modern">
	<cfargument name="siteStruct" type="struct" required="yes">
	<cfargument name="groupId" type="string" required="no" default="">
	<cfscript>
	db=request.zos.queryObject;
	tempStruct={};
	tempStruct.soGroupData={};
	tempStruct.soGroupData.optionGroupSetVersion={};
	tempStruct.soGroupData.optionGroupFieldLookup=structnew();
	tempStruct.soGroupData.optionGroupLookup=structnew();
	tempStruct.soGroupData.optionGroupIdLookup=structnew();
	tempStruct.soGroupData.optionGroupSetId=structnew();
	tempStruct.soGroupData.optionGroupSet=structnew();
	tempStruct.soGroupData.optionGroupSetArrays=structnew(); 
	tempStruct.soGroupData.optionGroupSetQueryCache={};
	tempStruct.soGroupData.optionGroupDefaults=structnew();
	sog=tempStruct.soGroupData;
	site_id=arguments.siteStruct.id;
	groupId=arguments.groupId;


	 db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	WHERE site_option_group_id=#db.param(groupId)# and  
	site_option_deleted = #db.param(0)# and 
	site_id = #db.param(site_id)#";
	qS=db.execute("qS");
	for(row in qS){
		sog.optionLookup[row.site_option_id]=row;
		structappend(sog.optionLookup[row.site_option_id], {
			edit:row.site_option_edit_enabled,
			name:row.site_option_name,
			type:row.site_option_type_id,
			optionStruct:{}
		});
		sog.optionLookup[row.site_option_id].optionStruct=deserializeJson(row.site_option_type_json);
		if(not structkeyexists(sog.optionGroupDefaults, row.site_option_group_id)){
			sog.optionGroupDefaults[row.site_option_group_id]={};
		}
		sog.optionGroupDefaults[row.site_option_group_id][row.site_option_name]=row.site_option_default_value;
		sog.optionIdLookup[row.site_option_group_id&chr(9)&row.site_option_name]=row.site_option_id;
		if(row.site_option_group_id NEQ 0){
			if(structkeyexists(sog.optionGroupFieldLookup, row.site_option_group_id) EQ false){
				sog.optionGroupFieldLookup[row.site_option_group_id]=structnew();
			}
			sog.optionGroupFieldLookup[row.site_option_group_id][row.site_option_id]=true;
		}
	}
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
	WHERE site_id =#db.param(site_id)# and 
	site_option_group_id = #db.param(groupId)# and 
	site_option_group_deleted = #db.param(0)#";
	qGroup=db.execute("qGroup"); 
	 
	cacheEnabled=false;
	versioningEnabled=false;
	for(row in qGroup){
		row.count=0;
		sog.optionGroupLookup[row.site_option_group_id]=row;
		if(request.zos.enableSiteOptionGroupCache and row.site_option_group_enable_cache EQ 1){ 
			cacheEnabled=true;
		}
		if(row.site_option_group_enable_versioning EQ 1){
			versioningEnabled=true;
		}
		sog.optionGroupIdLookup[row.site_option_group_parent_id&chr(9)&row.site_option_group_name]=row.site_option_group_id;
	}
	
	sog.optionGroupSetId[0&"_groupId"]=0;
	sog.optionGroupSetId[0&"_parentId"]=0;
	sog.optionGroupSetId[0&"_appId"]=0;
	sog.optionGroupSetId[0&"_childGroup"]=structnew();

	if(versioningEnabled or cacheEnabled){
		db.sql="SELECT s1.* 
		FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1   
		WHERE s1.site_id = #db.param(site_id)#  and 
		s1.site_x_option_group_set_deleted = #db.param(0)# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and ";
		if(cacheEnabled){
			db.sql&=" (s1.site_x_option_group_set_master_set_id = #db.param(0)# or s1.site_x_option_group_set_version_status = #db.param(1)#) and ";
		}else if(versioningEnabled){
			db.sql&=" (s1.site_x_option_group_set_master_set_id <> #db.param(0)# and s1.site_x_option_group_set_version_status = #db.param(1)#) and ";
		}else{
			db.sql&=" #db.param(1)# = #db.param(0)# and ";
		}
		db.sql&=" s1.site_option_group_id = #db.param(groupId)# 
		ORDER BY s1.site_x_option_group_set_parent_id ASC, s1.site_x_option_group_set_sort ASC "; 
		qS=db.execute("qS"); 
		tempUniqueStruct=structnew();
		

		arrVersionSetId=[];
		for(row in qS){
			id=row.site_x_option_group_set_id;
			if(row.site_x_option_group_set_master_set_id NEQ 0){
				arrayAppend(arrVersionSetId, id);
			}
			if(structkeyexists(sog.optionGroupSetId, id) EQ false){
				if(structkeyexists(sog.optionGroupSetId, id&"_appId") EQ false){
					sog.optionGroupLookup[row.site_option_group_id].count++;
					sog.optionGroupSetId[id&"_groupId"]=row.site_option_group_id;
					sog.optionGroupSetId[id&"_appId"]=row.site_option_app_id;
					sog.optionGroupSetId[id&"_parentId"]=row.site_x_option_group_set_parent_id;
					sog.optionGroupSetId[id&"_childGroup"]=structnew();
				}
				if(structkeyexists(sog.optionGroupSetId, row.site_x_option_group_set_parent_id&"_childGroup")){
					if(structkeyexists(sog.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"], row.site_option_group_id) EQ false){
						sog.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"][row.site_option_group_id]=arraynew(1);
					}
					// used for looping all sets in the group
					if(structkeyexists(tempUniqueStruct, row.site_x_option_group_set_parent_id&"_"&id) EQ false){ 
						arrayappend(sog.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"][row.site_option_group_id], id);
						tempUniqueStruct[row.site_x_option_group_set_parent_id&"_"&id]=true;
					}
				}
			}
		}
		if(cacheEnabled or (versioningEnabled and arraylen(arrVersionSetId))){
			db.sql="SELECT s3.site_x_option_group_set_id, s3.site_option_id groupSetOptionId, 
			s3.site_x_option_group_value groupSetValue , 
			s3.site_x_option_group_original groupSetOriginal 
			FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)# s3 
			WHERE s3.site_id = #db.param(site_id)#  and 
			s3.site_option_group_id = #db.param(groupId)# and 
			s3.site_x_option_group_deleted = #db.param(0)# "; 
			if(not cacheEnabled){
				db.sql&=" and s3.site_x_option_group_set_id IN (#db.trustedSQL(arrayToList(arrVersionSetId, ', '))#) ";
			}
			qS=db.execute("qS");  
			
			for(row in qS){
				id=row.site_x_option_group_set_id;
				if(structkeyexists(sog.optionLookup, row.groupSetOptionId)){
					var typeId=sog.optionLookup[row.groupSetOptionId].type;
					if(typeId EQ 2){
						if(row.groupSetValue EQ ""){
							tempValue="";
						}else{
							tempValue='<div class="zEditorHTML">'&row.groupSetValue&'</div>';
						}
					}else if(typeId EQ 3 or typeId EQ 9){
						if(row.groupSetValue NEQ "" and row.groupSetValue NEQ "0"){
							optionStruct=sog.optionLookup[row.groupSetOptionId].optionStruct;
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
					sog.optionGroupSetId[id&"_f"&row.groupSetOptionId]=tempValue; 
					if(typeId EQ 2){
						sog.optionGroupSetId[id&"_f"&row.groupSetOptionId]=tempValue;
					}else if(typeId EQ 3){
						if(row.groupSetOriginal NEQ ""){
							sog.optionGroupSetId["__original "&id&"_f"&row.groupSetOptionId]="/zupload/site-options/"&row.groupSetOriginal;
						}else{
							sog.optionGroupSetId["__original "&id&"_f"&row.groupSetOptionId]=tempValue;
						}
					}
				}
			}
		}


		 db.sql="SELECT * FROM 
		 #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1, 
		 #db.table("site_option_group", request.zos.zcoreDatasource)# s2
		WHERE s1.site_id = #db.param(site_id)# and 
		s1.site_id = s2.site_id and 
		s1.site_x_option_group_set_deleted = #db.param(0)# and 
		s2.site_option_group_deleted = #db.param(0)# and 
		s2.site_option_group_id = #db.param(groupId)# and ";
		if(cacheEnabled){
			db.sql&=" (s1.site_x_option_group_set_master_set_id = #db.param(0)# or s1.site_x_option_group_set_version_status = #db.param(1)#) and ";
		}else{
			db.sql&=" (s1.site_x_option_group_set_master_set_id <> #db.param(0)# and s1.site_x_option_group_set_version_status = #db.param(1)#) and ";

		}
		db.sql&=" s1.site_option_group_id = s2.site_option_group_id 
		ORDER BY s1.site_x_option_group_set_master_set_id asc, s1.site_x_option_group_set_sort asc";
		qS=db.execute("qS"); 
		for(row in qS){
			if(cacheEnabled){
				sog.optionGroupSetQueryCache[row.site_x_option_group_set_id]=row;
			}
			if(structkeyexists(sog.optionGroupSetArrays, row.site_option_app_id&chr(9)&row.site_option_group_id&chr(9)&row.site_x_option_group_set_parent_id) EQ false){
				sog.optionGroupSetArrays[row.site_option_app_id&chr(9)&row.site_option_group_id&chr(9)&row.site_x_option_group_set_parent_id]=arraynew(1);
			}
			ts=structnew();
			ts.__sort=row.site_x_option_group_set_sort;
			ts.__setId=row.site_x_option_group_set_id;
			ts.__dateModified=row.site_x_option_group_set_updated_datetime;
			ts.__groupId=row.site_option_group_id;
			ts.__approved=row.site_x_option_group_set_approved;
			ts.__createdDatetime=row.site_x_option_group_set_created_datetime;
			ts.__title=row.site_x_option_group_set_title;
			ts.__parentID=row.site_x_option_group_set_parent_id;
			ts.__summary=row.site_x_option_group_set_summary;
			// build url
			if(row.site_x_option_group_set_image_library_id NEQ 0){
				ts.__image_library_id=row.site_x_option_group_set_image_library_id;
			}
			if(row.site_option_group_enable_unique_url EQ 1){
				if(row.site_x_option_group_set_override_url NEQ ""){
					ts.__url=row.site_x_option_group_set_override_url;
				}else{
					var urlId=arguments.siteStruct.optionGroupUrlId;
					if(urlId EQ "" or urlId EQ 0){
						throw("site_option_group_url_id is not set for site_id, #site_id#.");
					}
					ts.__url="/#application.zcore.functions.zURLEncode(row.site_x_option_group_set_title, '-')#-#urlId#-#row.site_x_option_group_set_id#.html";
				}
			}
			t9=sog;
			if(structkeyexists(t9.optionGroupDefaults, row.site_option_group_id)){
				defaultStruct=t9.optionGroupDefaults[row.site_option_group_id];
			}else{
				defaultStruct={};
			}
			if(structkeyexists(t9.optionGroupSetId, ts.__setId&"_groupId")){
				groupId=t9.optionGroupSetId[ts.__setId&"_groupId"];
				if(structkeyexists(t9.optionGroupFieldLookup, groupId)){
					fieldStruct=t9.optionGroupFieldLookup[groupId];
				
					for(i2 in fieldStruct){
						cf=t9.optionLookup[i2];
						if(structkeyexists(t9.optionGroupSetId, "__original "&ts.__setId&"_f"&i2)){
							ts["__original "&cf.name]=t9.optionGroupSetId["__original "&ts.__setId&"_f"&i2];
						}
						if(structkeyexists(t9.optionGroupSetId, ts.__setId&"_f"&i2)){
							ts[cf.name]=t9.optionGroupSetId[ts.__setId&"_f"&i2];
						}else if(structkeyexists(defaultStruct, cf.name)){
							ts[cf.name]=defaultStruct[cf.name];
						}else{
							ts[cf.name]="";
						}
					}
				}
			}
			sog.optionGroupSet[row.site_x_option_group_set_id]= ts;


			if(row.site_x_option_group_set_master_set_id NEQ 0){
				if(structkeyexists(sog.optionGroupSet, row.site_x_option_group_set_master_set_id)){
					masterStruct=sog.optionGroupSet[row.site_x_option_group_set_master_set_id];
					ts.__sort=masterStruct.__sort;
					if(row.site_option_group_enable_unique_url EQ 1){
						ts.__url=masterStruct.__url;
					}
				}
				sog.optionGroupSetVersion[row.site_x_option_group_set_master_set_id]=ts.__setId;
			}else{
				arrayappend(sog.optionGroupSetArrays[row.site_option_app_id&chr(9)&ts.__groupId&chr(9)&row.site_x_option_group_set_parent_id], ts);
			}
		} 
	}

	if(not structkeyexists(arguments.siteStruct, 'soGroupData')){
		arguments.siteStruct.soGroupData={};
	}
	//sog.optionGroupSetQueryCache={};
	for(i in sog){
		if(not structkeyexists(arguments.siteStruct.soGroupData, i)){
			arguments.siteStruct.soGroupData[i]={};
		}
		structappend(arguments.siteStruct.soGroupData[i], sog[i], true);
	} 
	//arguments.siteStruct.soGroupData[i].optionGroupSetQueryCache={};
	</cfscript>
</cffunction>
 
	
<cffunction name="internalUpdateOptionOptionCache" access="public" localmode="modern">
	<cfargument name="siteStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	site_id=arguments.siteStruct.id;
	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option 
	LEFT JOIN #db.table("site_x_option", request.zos.zcoreDatasource)# site_x_option ON 
	site_x_option.site_id =#db.param(site_id)# and 
	site_x_option.site_option_id = site_option.site_option_id and 
	site_option.site_id = if(site_x_option.site_option_id_siteIDType = #db.param(1)#, #db.param(site_id)#, 
		if(site_x_option.site_option_id_siteIDType = #db.param(4)#, #db.param(0)#, #db.param(site_id)#)) and 
	site_x_option_deleted = #db.param(0)#
	WHERE site_option.site_id IN (#db.param('0')#,#db.param(site_id)#) and 
	site_option_deleted = #db.param(0)# and 
	site_option_group_id = #db.param(0)#"; 
	qS=db.execute("qS"); 
	tempStruct={}; 
	tempStruct.site_options=structnew();
	tempStruct.site_option_edit_enabled=structnew();
	tempStruct.site_option_app=structnew();
	for(row in qS){
		tempStruct.site_option_edit_enabled[row.site_option_name]=row.site_option_edit_enabled;
		if(row.site_option_type_id EQ 1 and row.site_option_line_breaks EQ 1){
			if(row.site_x_option_id EQ ""){
				c1=application.zcore.functions.zparagraphformat(row.site_option_default_value);
			}else{
				c1=application.zcore.functions.zparagraphformat(row.site_x_option_value);
			}
		}else{
			if(row.site_x_option_id EQ ""){
				c1=row.site_option_default_value;
			}else{
				c1=row.site_x_option_value;
			}
			if(c1 NEQ "" and c1 NEQ "0" and (row.site_option_type_id EQ 3 or row.site_option_type_id EQ 9)){
				c1="/zupload/site-options/"&c1;
			}
		}
		if(row.site_option_app_id NEQ 0){
			if(structkeyexists(tempStruct.site_option_app, row.site_option_app_id) EQ false){
				tempStruct.site_option_app[row.site_option_app_id]=structnew();
			}
			tempStruct.site_option_app[row.site_option_app_id][row.site_option_name]=c1;
			if(row.site_x_option_original NEQ ""){
				tempStruct.site_option_app[row.site_option_app_id]["__original "&row.site_option_name]="/zupload/site-options/"&row.site_x_option_original;
			}else{
				tempStruct.site_option_app[row.site_option_app_id]["__original "&row.site_option_name]=c1;
			}
		}else{
			tempStruct.site_options[row.site_option_name]=c1;
			if(row.site_option_type_id EQ 3){
				if(row.site_x_option_original NEQ ""){
					tempStruct.site_options["__original "&row.site_option_name]="/zupload/site-options/"&row.site_x_option_original;
				}else{
					tempStruct.site_options["__original "&row.site_option_name]=c1;
				}
			}
		}
	}
	structappend(arguments.siteStruct, tempStruct, true);
	</cfscript>
</cffunction>
	

<cffunction name="internalUpdateOptionAndGroupCache" access="public" localmode="modern">
	<cfargument name="siteStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	tempStruct=arguments.siteStruct;
	site_id=tempStruct.id;
	
	if(not structkeyexists(tempStruct, 'soGroupData')){
		tempStruct.soGroupData={};
	} 
	//tempStruct.soGroupData.optionLookup={};
	//tempStruct.soGroupData.optionIdLookup={};
	//sog=tempStruct.soGroupData;
	
	updateOptionGroupCache(tempStruct);
	internalUpdateOptionOptionCache(tempStruct);
	
	</cfscript>
	
</cffunction>


<cffunction name="setFeatureMap" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ms=arguments.struct;
	db=request.zos.queryObject;
	db.sql="SELECT site_option_group.* 
	FROM #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group  
	WHERE site_option_group.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_parent_id = #db.param('0')# and 
	site_option_group_deleted = #db.param(0)# and 
	site_option_group_type =#db.param('1')# and 
	site_option_group.site_option_group_disable_admin=#db.param(0)# 
	ORDER BY site_option_group.site_option_group_display_name ASC ";
	qGroup=db.execute("qGroup"); 
	if(qGroup.recordcount NEQ 0){
		ms["Custom"]={ parent:'', value:'Custom', label: "Custom"};
		// loop the groups
		// get the code from manageoptions"
		// site_option_group_disable_admin=0
		for(row in qGroup){
			ms["Custom: "&row.site_option_group_display_name]={ parent:'Custom', value:"Custom: "&row.site_option_group_display_name, label:chr(9)&row.site_option_group_display_name&chr(10)};
		}
	}
	</cfscript>
</cffunction>



<cffunction name="setURLRewriteStruct" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	ts2=arguments.struct;
	db.sql="select * from #db.table("site_option_group", request.zos.zcoredatasource)# site_option_group
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_allow_public=#db.param(1)# and 
	site_option_group_deleted = #db.param(0)# and
	site_option_group_public_form_url<> #db.param('')# ";
	qS=db.execute("qS");
	for(row in qS){
		t9=structnew();
		t9.scriptName="/z/misc/display-site-option-group/add";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/add";
		t9.urlStruct.site_option_group_id=row.site_option_group_id;
		ts2.uniqueURLStruct[trim(row.site_option_group_public_form_url)]=t9;
	}
	// setup built in routing
	if(structkeyexists(request.zos.globals,'optionGroupURLID') and request.zos.globals.optionGroupURLID NEQ 0){
		ts2.reservedAppUrlIdStruct[request.zos.globals.optionGroupURLid]=[];
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/misc/display-site-option-group/index";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/index";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="site_x_option_group_set_id";
		arrayappend(ts2.reservedAppUrlIdStruct[request.zos.globals.optionGroupURLid], t9);
		db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoredatasource)#, 
		#db.table("site_option_group", request.zos.zcoreDatasource)# 
		WHERE site_x_option_group_set.site_id = #db.param(request.zos.globals.id)# and 
		site_option_group_enable_unique_url=#db.param(1)# and 
		site_x_option_group_set.site_id = site_option_group.site_id and 
		site_option_group_deleted=#db.param(0)# and 
		site_x_option_group_set.site_option_group_id=site_option_group.site_option_group_id and 
		site_x_option_group_set_override_url<> #db.param('')# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		site_x_option_group_set_deleted = #db.param(0)# and
		site_x_option_group_set_approved=#db.param(1)#";
		qS=db.execute("qS");
		for(row in qS){
			t9=structnew();
			t9.scriptName="/z/misc/display-site-option-group/index";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/misc/display-site-option-group/index";
			t9.urlStruct.site_x_option_group_set_id=row.site_x_option_group_set_id;
			ts2.uniqueURLStruct[trim(row.site_x_option_group_set_override_url)]=t9;
		}
	}
	</cfscript>
</cffunction>

<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
	WHERE site_option_group_parent_id= #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_option_group.site_option_group_disable_admin=#db.param(0)# and 
	site_option_group_admin_app_only= #db.param(0)#
	ORDER BY site_option_group_display_name ";
	qoptionGroup=db.execute("qoptionGroup"); 
	for(i=1;i LTE qoptionGroup.recordcount;i++){
		ts=structnew();
		ts.featureName="Custom: "&qoptionGroup.site_option_group_display_name[i];
		ts.link="/z/admin/site-options/manageGroup?site_option_group_id="&qoptionGroup.site_option_group_id[i];
		ts.children=structnew();
		if(qoptionGroup.site_option_group_menu_name[i] EQ ""){
			curMenu="Custom";
		}else{
			curMenu=qoptionGroup.site_option_group_menu_name[i];
		}
		
		if(structkeyexists(arguments.linkStruct, curMenu) EQ false){
			arguments.linkStruct[curMenu]={
				featureName:"Custom",
				link:"/z/admin/site-options/index",
				children:{}
			};
		}
		plural="(s)";
		if(qOptionGroup.site_option_group_limit[i] EQ 1 or right(qOptionGroup.site_option_group_display_name[i], 1) EQ "s"){
			plural="";
		}
		arguments.linkStruct[curMenu].children[qoptionGroup.site_option_group_display_name[i]&plural]=ts;
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
application.zcore.siteOptionCom.searchOptionGroup("groupName", ts, 0, false);
 --->
<cffunction name="searchOptionGroup" access="public" output="no" returntype="struct" localmode="modern">
	<cfargument name="groupName" type="string" required="yes">
	<cfargument name="arrSearch" type="array" required="yes">
	<cfargument name="parentGroupId" type="string" required="yes">
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
	if(structkeyexists(t9, "optionGroupIdLookup") and structkeyexists(t9.optionGroupIdLookup, arguments.parentGroupId&chr(9)&arguments.groupName)){
		optionGroupId=t9.optionGroupIdLookup[arguments.parentGroupId&chr(9)&arguments.groupName];
		var groupStruct=t9.optionGroupLookup[optionGroupId];
		if(request.zos.enableSiteOptionGroupCache and groupStruct.site_option_group_enable_cache EQ 1){
			arrGroup=optionGroupStruct(arguments.groupName);
			if(arguments.orderBy NEQ ""){
				tempStruct={};
				for(i=1;i LTE arrayLen(arrGroup);i++){
					if(arguments.orderByDataType EQ "numeric" and not isnumeric(arrGroup[i][arguments.orderBy])){
						continue;
					} 
					if(arguments.orderByDataType EQ "date"){
						if(not isdate(arrGroup[i][arguments.orderBy])){
							continue;
						}
						value=dateformat(arrGroup[i][arguments.orderBy], "yyyymmdd")&timeformat(arrGroup[i][arguments.orderBy], "HHmmss");
					}else{
						value=arrGroup[i][arguments.orderBy];
					} 
					tempStruct[i]={
						sortKey: value,
						data:arrGroup[i]
					};
				}
				if(arguments.orderByDataType EQ "date"){
					arrTempKey=structsort(tempStruct, "numeric", arguments.orderByDirection, "sortKey");
				}else{
					arrTempKey=structsort(tempStruct, arguments.orderByDataType, arguments.orderByDirection, "sortKey");
				}  
				arrGroup2=[];
				for(i=1;i LTE arrayLen(arrTempKey);i++){
					arrayAppend(arrGroup2, tempStruct[arrTempKey[i]].data);
				}
				arrGroup=arrGroup2;
			}
			//writedump(arraylen(arrGroup));
			// return rows in an array.
			//writedump(arguments.arrSearch);
			stopStoring=false;
			rs.count=0;
			for(i=1;i LTE arrayLen(arrGroup);i++){
				row=arrGroup[i];
				if(structkeyexists(row, '__approved') and row.__approved NEQ 1){
					continue;
				}
				match=variables.processSearchArray(arguments.arrSearch, row, groupStruct.site_option_group_id);
				if(match){
					rs.count++;
					if(not stopStoring){
						if(currentOffset LT arguments.offset){
							//echo('skip<br>');
							currentOffset++;
							continue;
						}else{
							//echo('match and store: #arrGroup[i].title#<br />');
							// to avoid having to generate a total count, we just see if there is 1 more matching record.
							if(arguments.getCount){
								arrayAppend(rs.arrResult, arrGroup[i]);
								if(arguments.limit EQ arrayLen(rs.arrResult)){
									stopStoring=true;
								}
							}else{
								if(arguments.limit+1 EQ arrayLen(rs.arrResult)){
									rs.hasMoreRecords=true;
									break;
								}
								arrayAppend(rs.arrResult, arrGroup[i]);
							}
						}
					}
				//}else{
				//	echo('not match: #arrGroup[i].title#<br />');
				}
			}
			//abort;
		}else{
			fieldStruct={};

			sql=variables.processSearchArraySQL(arguments.arrSearch, fieldStruct, 1, groupStruct.site_option_group_id);
			/*if(sql EQ ""){
				return rs;
			}*/
			//writedump(sql);abort;

			groupId=getOptionGroupIDWithNameArray([arguments.groupName]);


			arrTable=["site_x_option_group_set s1"];
			arrWhere=["s1.site_id = '#request.zos.globals.id#' and 
			s1.site_x_option_group_set_deleted = 0  and 
			s1.site_option_group_id = '#groupId#' and "&sql];
			arrSelect=[];

			orderTableLookup={};
			fieldIndex=1;
			for(i in fieldStruct){
				tableName="sGroup"&fieldStruct[i];
				orderTableLookup[i]=fieldIndex;
				//arrayAppend(arrSelect, "sVal"&i);
				arrayAppend(arrTable, "site_x_option_group "&tableName);
				arrayAppend(arrWhere, "#tableName#.site_id = s1.site_id and 
				#tableName#.site_x_option_group_set_id = s1.site_x_option_group_set_id and 
				#tableName#.site_option_id = '#application.zcore.functions.zescape(i)#' and 
				#tableName#.site_option_group_id = s1.site_option_group_id AND 
				#tableName#.site_x_option_group_deleted = 0");
				fieldIndex++;
			}
			if(arguments.orderBy NEQ ""){
				// need to lookup the field site_option_id using the site_option_name and groupId
				optionIdLookup=t9.optionIdLookup;
				if(structkeyexists(optionIdLookup, groupId&chr(9)&arguments.orderBy)){
					site_option_id=optionIdLookup[groupId&chr(9)&arguments.orderBy];
					site_option_type_id=t9.optionLookup[site_option_id].type;
					currentCFC=getTypeCFC(site_option_type_id);

					arrayAppend(arrSelect, "s2.site_x_option_group_value sVal2");
					arrayAppend(arrTable, "site_x_option_group s2");
					arrayAppend(arrWhere, "s2.site_id = s1.site_id and 
					s2.site_x_option_group_set_id = s1.site_x_option_group_set_id and 
					s2.site_option_id = '#application.zcore.functions.zescape(site_option_id)#' and 
					s2.site_option_group_id = s1.site_option_group_id AND 
					s2.site_x_option_group_deleted = 0");
					fieldIndex++;


					orderByStatement=" ORDER BY "&currentCFC.getSortSQL(2, arguments.orderByDirection);
				}else{
					throw("arguments.orderBy, ""#arguments.orderBy#"" is not a valid field in the site_option_group_id=#groupId# | ""#groupStruct.site_option_group_name#""");
				}
			}else if(structkeyexists(request.zos, '#variables.type#OptionSearchDateRangeSortEnabled')){
				orderByStatement=" ORDER BY s1.site_x_option_group_set_start_date ASC ";
			}else{
				orderByStatement=" ORDER BY s1.site_x_option_group_set_id ASC ";
			}
			db=request.zos.noVerifyQueryObject;
			if(arguments.getCount){
				db.sql="select count(distinct s1.site_x_option_group_set_id) count
				from #arrayToList(arrTable, ", ")# 
				WHERE #arrayToList(arrWhere, " and ")# ";
				if(not arguments.showUnapproved){
					db.sql&=" and site_x_option_group_set_approved=#db.param('1')# ";
				}
				qCount=db.execute("qSelect");  
				rs.count=qCount.count;
				//writedump(qCount);abort;
				if(qCount.recordcount EQ 0 or qCount.count EQ 0){
					return rs;
				} 
			}
			db.sql="select s1.site_x_option_group_set_id ";
			if(arraylen(arrSelect)){
				db.sql&=", "&arrayToList(arrSelect, ", ");
			}
			db.sql&="
			from #arrayToList(arrTable, ", ")# 
			WHERE #arrayToList(arrWhere, " and ")# ";
			if(not arguments.showUnapproved){
				db.sql&=" and site_x_option_group_set_approved=#db.param('1')# ";
			}
			db.sql&=" GROUP BY s1.site_x_option_group_set_id 
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
				arrayAppend(arrId, row.site_x_option_group_set_id);
				currentRow++;
			}
			idlist="'"&arraytolist(arrId, "','")&"'";
			
			 db.sql="SELECT *  FROM 
			 #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1, 
			 #db.table("site_x_option_group", request.zos.zcoreDatasource)# s2
			WHERE  s1.site_id = #db.param(request.zos.globals.id)# and 
			s1.site_x_option_group_set_deleted = #db.param(0)# and 
			s2.site_x_option_group_deleted = #db.param(0)# and 
			s1.site_id = s2.site_id and 
			s1.site_option_group_id = s2.site_option_group_id and 
			s1.site_x_option_group_set_master_set_id = #db.param(0)# and 
			s1.site_x_option_group_set_id = s2.site_x_option_group_set_id and ";
			if(not arguments.showUnapproved){
				db.sql&=" s1.site_x_option_group_set_approved=#db.param(1)# and ";
			}
			db.sql&=" s1.site_x_option_group_set_id IN (#db.trustedSQL(idlist)#) ";
			if(qIdList.recordcount GT 1){
				db.sql&="ORDER BY field(s1.site_x_option_group_set_id, #db.trustedSQL(idlist)#)  asc"; 
			}
			qS=db.execute("qS"); 
			//writedump(qS);abort;
			if(qS.recordcount EQ 0){
				return rs;
			}
			lastSetId=0;
			for(row in qS){
				if(lastSetId NEQ row.site_x_option_group_set_id){
					if(lastSetId NEQ 0){
						arrayAppend(rs.arrResult, curStruct);
					}
					curStruct=variables.buildOptionGroupSetId(row, false);
					lastSetId=row.site_x_option_group_set_id;
				}
				variables.buildOptionGroupSetIdField(row, curStruct);
				
			}
			arrayAppend(rs.arrResult, curStruct);
			return rs;
		}
	}else{
		throw("groupName, ""#arguments.groupName#"" doesn't exist with parentGroupId, ""#arguments.parentGroupId#"".");
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
arr1=application.zcore.siteOptionCom.optionGroupSetFromDatabaseBySearch(ts, request.zos.globals.id);
</cfscript>
 --->
<cffunction name="optionGroupSetFromDatabaseBySearch" access="public" returntype="array" localmode="modern">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	ts=arguments.searchStruct;
	if(not structkeyexists(ts, 'arrGroupName')){
		throw("arguments.searchStruct.arrGroupName is required. It must be an array of site_option_group_name values.");
	}
	db=request.zos.queryObject;//  SEPARATOR #db.param("','")#) idlist
	 db.sql="SELECT site_x_option_group_set_id FROM 
	 #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1
	WHERE 
	s1.site_x_option_group_set_deleted = #db.param(0)# and 
	";
	var groupId=getOptionGroupIdWithNameArray(ts.arrGroupName, arguments.site_id);
	db.sql&="s1.site_option_group_id = #db.param(groupId)# and ";
	if(structkeyexists(ts, 'endDate')){
		if(structkeyexists(ts, 'startDate')){
			db.sql&=" s1.site_x_option_group_set_start_date <= #db.param(dateformat(ts.endDate, 'yyyy-mm-dd'))# and 
			s1.site_x_option_group_set_end_date >= #db.param(dateformat(ts.startDate, 'yyyy-mm-dd'))#  and ";
		}else{
			db.sql&=" s1.site_x_option_group_set_end_date <= #db.param(dateformat(ts.endDate, 'yyyy-mm-dd'))# and ";
		}
	}else if(structkeyexists(ts, 'startDate')){
		db.sql&=" s1.site_x_option_group_set_start_date >= #db.param(dateformat(ts.startDate, 'yyyy-mm-dd'))# and ";
	}
	if(structkeyexists(ts, 'excludeBeforeStartDate')){
		db.sql&=" s1.site_x_option_group_set_end_date >= #db.param(dateformat(ts.excludeBeforeStartDate, "yyyy-mm-dd")&" 00:00:00")# and ";
	}
	db.sql&="  s1.site_id = #db.param(arguments.site_id)# and  
	s1.site_x_option_group_set_master_set_id = #db.param(0)# and 
	s1.site_x_option_group_set_approved=#db.param(1)# ";
	var t9=getTypeData(arguments.site_id);
	groupStruct=t9.optionGroupLookup[groupId];
	if(structkeyexists(ts, 'orderBy')){
		if(ts.orderBy EQ "startDateASC"){
			db.sql&="ORDER BY site_x_option_group_set_start_date ASC";
		}else if(ts.orderBy EQ "startDateDESC"){
			db.sql&="ORDER BY site_x_option_group_set_start_date DESC";
		}else{
			if(groupStruct.site_option_group_enable_sorting EQ 1){
				db.sql&=" ORDER BY s1.site_x_option_group_set_sort asc ";
			} 
		}
	}else{ 
		if(groupStruct.site_option_group_enable_sorting EQ 1){
			db.sql&=" ORDER BY s1.site_x_option_group_set_sort asc ";
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
		arrayAppend(arrId, row.site_x_option_group_set_id);
	}
	idlist="'"&arraytolist(arrId, "','")&"'";
	
	 db.sql="SELECT * FROM 
	 #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1, 
	 #db.table("site_x_option_group", request.zos.zcoreDatasource)# s2
	WHERE  s1.site_id = #db.param(arguments.site_id)# and 
	s1.site_x_option_group_set_deleted = #db.param(0)# and 
	s2.site_x_option_group_deleted = #db.param(0)# and 
	s1.site_x_option_group_set_master_set_id = #db.param(0)# and 
	s1.site_id = s2.site_id and 
	s1.site_option_group_id = s2.site_option_group_id and 
	s1.site_x_option_group_set_id = s2.site_x_option_group_set_id and 
	s1.site_x_option_group_set_approved=#db.param(1)# and 
	s1.site_x_option_group_set_id IN (#db.trustedSQL(idlist)#) ";
	if(qIdList.recordcount GT 1){
		db.sql&="ORDER BY field(s1.site_x_option_group_set_id, #db.trustedSQL(idlist)#)  asc"; 
	}
	qS=db.execute("qS"); 
	if(qS.recordcount EQ 0){
		return arrRow;
	}
	lastSetId=0;
	for(row in qS){
		if(lastSetId NEQ row.site_x_option_group_set_id){
			if(lastSetId NEQ 0){
				arrayAppend(arrRow, curStruct);
			}
			curStruct=variables.buildOptionGroupSetId(row, false);
			lastSetId=row.site_x_option_group_set_id;
		}
		variables.buildOptionGroupSetIdField(row, curStruct);
		
	}
	arrayAppend(arrRow, curStruct);
	return arrRow;
	</cfscript>
</cffunction>



<cffunction name="getSetParentLinks" access="public" localmode="modern">
	<cfargument name="site_option_group_id" type="string" required="yes">
	<cfargument name="site_option_group_parent_id" type="string" required="yes">
	<cfargument name="site_x_option_group_set_parent_id" type="string" required="yes">
	<cfargument name="linkCurrentPage" type="boolean" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	arrParent=arraynew(1);
	curGroupId=arguments.site_option_group_id;
	curParentId=arguments.site_option_group_parent_id;
	curParentSetId=arguments.site_x_option_group_set_parent_id;
	groupStruct=getOptionGroupById(curGroupId); 
	if(arguments.linkCurrentPage){
		if(form.method NEQ "sectionGroup"){
			arrayAppend(arrParent, '<a href="/z/admin/site-options/sectionGroup?site_x_option_group_set_id=#form.site_x_option_group_set_id#">Manage Section</a> /');
		}
		manageAction="manageGroup";
		if(form.method EQ "userManageGroup"){
			manageAction="userManageGroup";
		}
		arrayAppend(arrParent, '<a href="/z/admin/site-options/#manageAction#?site_option_group_id=#curGroupId#&amp;site_x_option_group_set_parent_id=#curParentSetId#">Manage #groupStruct.site_option_group_name#(s)</a> / ');
	}
	if(curParentSetId NEQ 0){
		loop from="1" to="25" index="i"{
			db.sql="select s1.*, s2.site_x_option_group_set_title, s2.site_x_option_group_set_id d2, s2.site_x_option_group_set_parent_id d3 
			from #db.table("site_option_group", request.zos.zcoreDatasource)# s1, 
			#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s2
			where s1.site_id = s2.site_id and 
			s1.site_option_group_deleted = #db.param(0)# and 
			s2.site_x_option_group_set_master_set_id = #db.param(0)# and 
			s2.site_x_option_group_set_deleted = #db.param(0)# and 
			s1.site_id = #db.param(request.zos.globals.id)# and 
			s1.site_option_group_id=s2.site_option_group_id and 
			s2.site_x_option_group_set_id=#db.param(curParentSetId)# and 
			s1.site_option_group_id = #db.param(curParentId)# 
			LIMIT #db.param(0)#,#db.param(1)#";
			q12=db.execute("q12");
			loop query="q12"{
				manageAction="manageGroup";
				if(form.method EQ "userManageGroup"){
					manageAction="userManageGroup";
				}
				out='<a href="#application.zcore.functions.zURLAppend("/z/admin/site-options/#manageAction#", "site_option_group_id=#q12.site_option_group_id#&amp;site_x_option_group_set_parent_id=#q12.d3#")#">#application.zcore.functions.zFirstLetterCaps(q12.site_option_group_display_name)#</a> / ';
				if(not arguments.linkCurrentPage and curGroupID EQ arguments.site_option_group_id){
					out&=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(q12.site_x_option_group_set_title), 70)&' /';
				}else{ 
					out&='<a href="/z/admin/site-options/#manageAction#?site_option_group_id=#curGroupId#&amp;site_x_option_group_set_parent_id=#q12.d2#">#application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(q12.site_x_option_group_set_title), 70)#</a> /';
				}
				arrayappend(arrParent, out);
				curGroupId=q12.site_option_group_id;
				curParentId=q12.site_option_group_parent_id;
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




<cffunction name="optionGroupSetCountFromDatabaseBySearch" access="public" returntype="numeric" localmode="modern">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	ts=arguments.searchStruct;
	if(not structkeyexists(ts, 'arrGroupName')){
		throw("arguments.searchStruct.arrGroupName is required. It must be an array of site_option_group_name values.");
	}
	db=request.zos.queryObject;//  SEPARATOR #db.param("','")#) idlist
	 db.sql="SELECT count(site_x_option_group_set_id) count FROM 
	 #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1
	WHERE s1.site_x_option_group_set_deleted = #db.param(0)# and ";
	var groupId=getOptionGroupIdWithNameArray(ts.arrGroupName, arguments.site_id);
	db.sql&="s1.site_option_group_id = #db.param(groupId)# and ";
	if(structkeyexists(ts, 'endDate')){
		if(structkeyexists(ts, 'startDate')){
			db.sql&=" s1.site_x_option_group_set_start_date <= #db.param(dateformat(ts.endDate, 'yyyy-mm-dd'))# and 
			s1.site_x_option_group_set_end_date >= #db.param(dateformat(ts.startDate, 'yyyy-mm-dd'))#  and ";
		}else{
			db.sql&=" s1.site_x_option_group_set_end_date <= #db.param(dateformat(ts.endDate, 'yyyy-mm-dd'))# and ";
		}
	}else if(structkeyexists(ts, 'startDate')){
		db.sql&=" s1.site_x_option_group_set_start_date >= #db.param(dateformat(ts.startDate, 'yyyy-mm-dd'))# and ";
	}
	db.sql&="  s1.site_id = #db.param(arguments.site_id)# and  
	s1.site_x_option_group_set_master_set_id = #db.param(0)# and 
	s1.site_x_option_group_set_approved=#db.param(1)# ";
	qIdList=db.execute("qIdList");  
	if(qIdList.recordcount EQ 0){
		return 0;
	}else{
		return qIdList.count;
	}
	</cfscript>
</cffunction>
 
<cffunction name="optionGroupSetFromDatabaseBySetId" access="public" returntype="struct" localmode="modern">
	<cfargument name="groupId" type="string" required="yes">
	<cfargument name="setId" type="string" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="showUnapproved" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	 db.sql="SELECT * FROM 
	 #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1 FORCE INDEX(`PRIMARY`), 
	 #db.table("site_x_option_group", request.zos.zcoreDatasource)# s2 FORCE INDEX(`PRIMARY`)
	WHERE s1.site_id = #db.param(arguments.site_id)# and 
	s1.site_x_option_group_set_deleted = #db.param(0)# and 
	s2.site_x_option_group_deleted = #db.param(0)# and 
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	site_x_option_group_value <> #db.param('')# and 
	s1.site_id = s2.site_id and 
	s1.site_option_group_id = s2.site_option_group_id and 
	s1.site_x_option_group_set_id = s2.site_x_option_group_set_id and 
	s1.site_option_group_id=#db.param(arguments.groupId)# and ";
	if(not arguments.showUnapproved){
		db.sql&=" s1.site_x_option_group_set_approved=#db.param(1)# and ";
	}
	db.sql&=" s1.site_x_option_group_set_id = #db.param(arguments.setId)# 
	";
	var t9=getTypeData(arguments.site_id);
	groupStruct=t9.optionGroupLookup[arguments.groupId];
	if(groupStruct.site_option_group_enable_sorting EQ 1){
		db.sql&=" ORDER BY s1.site_x_option_group_set_sort asc ";
	}
	qSet=db.execute("qSet"); 
	resultStruct={};
	lastSetId=0; 
	for(row in qSet){
		if(lastSetId NEQ row.site_x_option_group_set_id){
			resultStruct=variables.buildOptionGroupSetId(row, false);
			lastSetId=row.site_x_option_group_set_id;
		}
		variables.buildOptionGroupSetIdField(row, resultStruct);
		
	}
	return resultStruct;
	</cfscript>
</cffunction>


<cffunction name="optionGroupSetFromDatabaseBySortedArray" access="public" returntype="array" localmode="modern">
	<cfargument name="arrSetId" type="array" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	for(i=1;i LTE arraylen(arguments.arrSetId);i++){
		arguments.arrSetId[i]=application.zcore.functions.zescape(arguments.arrSetId[i]);
	} 
	idList="'"&arrayToList(arguments.arrSetId, "','")&"'";
	 db.sql="SELECT * FROM 
	 #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1, 
	 #db.table("site_x_option_group", request.zos.zcoreDatasource)# s2
	WHERE s1.site_id = #db.param(arguments.site_id)# and 
	s1.site_x_option_group_set_deleted = #db.param(0)# and 
	s2.site_x_option_group_deleted = #db.param(0)# and 
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	s1.site_id = s2.site_id and 
	s1.site_option_group_id = s2.site_option_group_id and 
	s1.site_x_option_group_set_id = s2.site_x_option_group_set_id and 
	s1.site_x_option_group_set_approved=#db.param(1)# and 
	s1.site_x_option_group_set_id IN (#db.trustedSQL(idList)#) 
	ORDER BY field(s1.site_x_option_group_set_id, #db.trustedSQL(idList)#) ASC";
	qS=db.execute("qS"); 
	arrRow=[];
	if(qS.recordcount EQ 0){
		return arrRow;
	}
	lastSetId=0;
	for(row in qS){
		if(lastSetId NEQ row.site_x_option_group_set_id){
			if(lastSetId NEQ 0){
				arrayAppend(arrRow, curStruct);
			}
			curStruct=variables.buildOptionGroupSetId(row, false);
			lastSetId=row.site_x_option_group_set_id;
		}
		variables.buildOptionGroupSetIdField(row, curStruct);
		
	}
	arrayAppend(arrRow, curStruct);
	return arrRow;
	</cfscript>
</cffunction>

<cffunction name="optionGroupSetFromDatabaseByGroupId" access="public" localmode="modern">
	<cfargument name="groupId" type="string" required="yes">
	<cfargument name="site_option_app_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="parentStruct" type="struct" required="no" default="#{__groupId=0,__setId=0}#">
	<cfargument name="fieldList" type="string" required="no" default="">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	 db.sql="SELECT * FROM 
	 #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1 FORCE INDEX(`PRIMARY`), 
	 #db.table("site_x_option_group", request.zos.zcoreDatasource)# s2 FORCE INDEX(`PRIMARY`)
	WHERE s1.site_id = #db.param(arguments.site_id)# and 
	s1.site_x_option_group_set_deleted = #db.param(0)# and 
	s2.site_x_option_group_deleted = #db.param(0)# and 
	s1.site_id = s2.site_id and 
	s1.site_option_group_id = s2.site_option_group_id and 
	s1.site_option_app_id = #db.param(arguments.site_option_app_id)# and 
	s1.site_x_option_group_set_id = s2.site_x_option_group_set_id and 
	s1.site_x_option_group_set_parent_id = #db.param(arguments.parentStruct.__setId)# and 
	s1.site_x_option_group_set_approved=#db.param(1)# and 
	s2.site_x_option_group_value <> #db.param('')# and 
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	s1.site_option_group_id = #db.param(arguments.groupId)# ";

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
			db.sql&=" and s2.site_option_id IN (#db.trustedSQL("'"&arrayToList(arrId, "','")&"'")#) ";
			disableDefaults=true;
		} 
	} 
	groupStruct=t9.optionGroupLookup[arguments.groupId];
	if(groupStruct.site_option_group_enable_sorting EQ 1){
		db.sql&=" ORDER BY s1.site_x_option_group_set_sort asc ";
	}else{
		db.sql&=" ORDER BY s1.site_x_option_group_set_id asc ";
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
		if(not structkeyexists(rowStruct, row.site_x_option_group_set_id)){
			curStruct=variables.buildOptionGroupSetId(row, disableDefaults);
			if(disableDefaults){
				structappend(curStruct, defaultStruct);
			}
			rowStruct[row.site_x_option_group_set_id]=curStruct;
			arrayAppend(arrSort, row.site_x_option_group_set_id);
		} 
		variables.buildOptionGroupSetIdField(row, rowStruct[row.site_x_option_group_set_id]);
		
	}
	for(i in arrSort){
		row=rowStruct[i];
		arrayAppend(arrRow, row);
	}
	return arrRow;
	</cfscript>
</cffunction>
	
<cffunction name="buildOptionGroupSetIdField" access="private" localmode="modern">
	<cfargument name="row" type="struct" required="yes"> 
	<cfargument name="curStruct" type="struct" required="yes"> 
	<cfscript>
	var t9=getTypeData(arguments.row.site_id);
	if(arguments.row.site_option_id NEQ ""){
		typeId=t9.optionLookup[arguments.row.site_option_id].type;
		if(typeId EQ 2){
			if(arguments.row.site_x_option_group_value EQ ""){
				tempValue="";
			}else{
				tempValue='<div class="zEditorHTML">'&arguments.row.site_x_option_group_value&'</div>';;
			}
		}else if(typeId EQ 3 or typeId EQ 9){
			if(arguments.row.site_x_option_group_value NEQ "" and arguments.row.site_x_option_group_value NEQ "0"){
				if(application.zcore.functions.zso(t9.optionLookup[arguments.row.site_option_id].optionStruct, 'file_securepath') EQ "Yes"){
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
		arguments.curStruct[t9.optionLookup[arguments.row.site_option_id].name]=tempValue;
	}
	</cfscript>
</cffunction>

<cffunction name="buildOptionGroupSetId" access="private" localmode="modern">
	<cfargument name="row" type="struct" required="yes"> 
	<cfargument name="disableDefaults" type="boolean" required="yes">
	<cfscript>
	row=arguments.row;  
	var t9=getTypeData(row.site_id);
	ts=structnew();
	ts.__sort=row.site_x_option_group_set_sort;
	ts.__setId=row.site_x_option_group_set_id;
	ts.__dateModified=row.site_x_option_group_set_updated_datetime;
	ts.__groupId=row.site_option_group_id;
	ts.__createdDatetime=row.site_x_option_group_set_created_datetime;
	ts.__approved=row.site_x_option_group_set_approved;
	ts.__title=row.site_x_option_group_set_title;
	ts.__parentID=row.site_x_option_group_set_parent_id;
	ts.__summary=row.site_x_option_group_set_summary;
	// build url
	if(row.site_x_option_group_set_image_library_id NEQ 0){
		ts.__image_library_id=row.site_x_option_group_set_image_library_id;
	}
	groupStruct=t9.optionGroupLookup[row.site_option_group_id];
	if(groupStruct.site_option_group_enable_unique_url EQ 1){
		if(row.site_x_option_group_set_override_url NEQ ""){
			ts.__url=row.site_x_option_group_set_override_url;
		}else{
			var urlId=application.zcore.functions.zvar('optionGroupURLID', row.site_id);
			if(urlId EQ "" or urlId EQ 0){
				throw("site_option_group_url_id is not set for site_id, #arguments.site_id#.");
			}
			ts.__url="/#application.zcore.functions.zURLEncode(row.site_x_option_group_set_title, '-')#-#urlId#-#row.site_x_option_group_set_id#.html";
		}
	}
	if(not arguments.disableDefaults){
		structappend(ts, t9.optionGroupDefaults[row.site_option_group_id]);
	}
	return ts;
	</cfscript>
</cffunction>


<cffunction name="setOptionGroupImportStruct" access="public" localmode="modern">
	<cfargument name="arrGroupName" type="array" required="yes">
	<cfargument name="site_option_app_id" type="numeric" required="yes">
	<!--- <cfargument name="site_option_group_parent_id" type="numeric" required="yes"> --->
	<cfargument name="site_x_option_group_set_parent_id" type="numeric" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="importStruct" type="struct" required="yes">
	<cfscript>
	if(not structkeyexists(request.zos, '#variables.type#OptionGroupImportTable')){
		request.zos["#variables.type#OptionGroupImportTable"]={};
	}
	var groupId=getOptionGroupIdWithNameArray(arguments.arrGroupName, request.zos.globals.id);
	//var groupStruct=typeStruct.optionGroupLookup[groupId]; 
	form.site_x_option_group_set_id=0;
	form.site_x_option_group_set_parent_id=arguments.site_x_option_group_set_parent_id;
	form.site_option_app_id=arguments.site_option_app_id;
	form.site_option_group_id=groupId;//optionGroupIDByName(arguments.site_option_group_name, arguments.site_option_group_parent_id);

	if(structkeyexists(request.zos["#variables.type#OptionGroupImportTable"], form.site_option_group_id)){
		ts=request.zos["#variables.type#OptionGroupImportTable"][form.site_option_group_id];
	}else{
		db=request.zos.queryObject;
		db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# WHERE 
		site_option_group_id = #db.param(form.site_option_group_id)# and 
		site_option_type_id <> #db.param(11)# and 
		site_option_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		qOption=db.execute("qOption");
		var ts={}; 
		var arroptionId=[];
		for(row in qOption){
			arrayAppend(arroptionId, row.site_option_id);
			ts[row.site_option_name]=row.site_option_id;
		} 
		ts.site_option_id=arrayToList(arroptionId, ",");
		request.zos["#variables.type#OptionGroupImportTable"][form.site_option_group_id]=ts;
	}
	arguments.importStruct.site_option_id=ts.site_option_id;
	for(i in arguments.dataStruct){
		if(structkeyexists(ts, i)){
			arguments.importStruct['newvalue'&ts[i]]=arguments.dataStruct[i];
		}
	}
	</cfscript>
</cffunction>



<cffunction name="resortOptionGroupSets" localmode="modern" access="public">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="site_option_app_id" type="numeric" required="yes">
	<cfargument name="site_option_group_id" type="numeric" required="yes">
	<cfargument name="site_x_option_group_set_parent_id" type="numeric" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	db.sql="select site_x_option_group_set_id from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)#
	WHERE 
	site_x_option_group_set_deleted = #db.param(0)# and 
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	site_x_option_group_set_parent_id= #db.param(arguments.site_x_option_group_set_parent_id)# and 
	site_option_group_id = #db.param(arguments.site_option_group_id)# and 
	site_option_app_id = #db.param(arguments.site_option_app_id)# and 
	site_id = #db.param(arguments.site_id)# 
	ORDER BY site_x_option_group_set_sort";
	var qSort=db.execute("qSort");
	var arrTemp=[];
	sortStruct={};
	i=1;

	t9=getTypeData(arguments.site_id);
	var groupStruct=t9.optionGroupLookup[arguments.site_option_group_id];

	for(var row2 in qSort){
		arrayAppend(arrTemp, row2.site_x_option_group_set_id);
		sortStruct[row2.site_x_option_group_set_id]=i;


		if(structkeyexists(groupStruct, 'site_option_group_change_cfc_path') and groupStruct.site_option_group_change_cfc_path NEQ ""){
			path=groupStruct.site_option_group_change_cfc_path;
			if(left(path, 5) EQ "root."){
				path=request.zRootCFCPath&removeChars(path, 1, 5);
			}
			changeCom=application.zcore.functions.zcreateObject("component", path);
			changeCom[groupStruct.site_option_group_change_cfc_sort_method](row2.site_x_option_group_set_id, i);
		}
		i++;
	}
	t9=getSiteData(arguments.site_id);
	t9.optionGroupSetId[arguments.site_x_option_group_set_parent_id&"_childGroup"][arguments.site_option_group_id]=arrTemp;

	arrData=t9.optionGroupSetArrays[arguments.site_option_app_id&chr(9)&arguments.site_option_group_id&chr(9)&arguments.site_x_option_group_set_parent_id];
	arrDataNew=[];
	for(i=1;i LTE arraylen(arrData);i++){
		sortIndex=sortStruct[arrData[i].__setId];
		arrDataNew[sortIndex]=arrData[i];
	}
	t9.optionGroupSetArrays[arguments.site_option_app_id&chr(9)&arguments.site_option_group_id&chr(9)&arguments.site_x_option_group_set_parent_id]=arrDataNew;
	</cfscript>
</cffunction>
	
<cffunction name="updateOptionGroupSetIdCache" localmode="modern" access="public">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="site_x_option_group_set_id" type="numeric" required="yes">
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
	db.sql="SELECT s1.*, s3.site_option_id groupSetOptionId, s4.site_option_type_id typeId, s3.site_x_option_group_value groupSetValue, s3.site_x_option_group_original groupSetOriginal  
	FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1  
	LEFT JOIN #db.table("site_x_option_group", request.zos.zcoreDatasource)# s3  ON 
	s1.site_option_group_id = s3.site_option_group_id AND 
	s1.site_x_option_group_set_id = s3.site_x_option_group_set_id and 
	s1.site_id = s3.site_id
	LEFT JOIN #db.table("site_option", request.zos.zcoreDatasource)# s4 ON 
	s4.site_option_group_id = s3.site_option_group_id and 
	s4.site_option_id = s3.site_option_id and 
	s4.site_id = s3.site_id 
	WHERE s1.site_id = #db.param(arguments.site_id)#  and 
	s1.site_x_option_group_set_deleted = #db.param(0)# and 
	s3.site_x_option_group_deleted = #db.param(0)# and 
	s4.site_option_deleted = #db.param(0)# and 
	s1.site_x_option_group_set_approved=#db.param(1)# and 
	s1.site_x_option_group_set_id=#db.param(arguments.site_x_option_group_set_id)#
	ORDER BY s1.site_x_option_group_set_parent_id ASC, s1.site_x_option_group_set_sort ASC ";
	//s1.site_x_option_group_set_master_set_id = #db.param(0)# and 
	//if(debug) writedump(db.sql);
	var qS=db.execute("qS"); 
	if(debug) writedump(qS);
	var tempUniqueStruct=structnew();
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-1<br>'); startTime=gettickcount();
	var newRecord=false;
	for(row in qS){
		var id=row.site_x_option_group_set_id;
		if(structkeyexists(t9.optionGroupSetId, id&"_appId") EQ false){
			newRecord=true;
			typeStruct.optionGroupLookup[row.site_option_group_id].count++;
			t9.optionGroupSetId[id&"_groupId"]=row.site_option_group_id;
			t9.optionGroupSetId[id&"_appId"]=row.site_option_app_id;
			t9.optionGroupSetId[id&"_parentId"]=row.site_x_option_group_set_parent_id;
			t9.optionGroupSetId[id&"_childGroup"]=structnew();
		}
		if(row.site_x_option_group_set_master_set_id EQ 0 and structkeyexists(t9.optionGroupSetId, row.site_x_option_group_set_parent_id&"_childGroup")){
			if(structkeyexists(t9.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"], row.site_option_group_id) EQ false){
				t9.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"][row.site_option_group_id]=arraynew(1);
			}
			if(typeStruct.optionGroupLookup[row.site_option_group_id].site_option_group_enable_sorting EQ 1){
				if(structkeyexists(tempUniqueStruct, row.site_x_option_group_set_parent_id&"_"&id) EQ false){
					var arrChild=t9.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"][row.site_option_group_id];
					var resort=false;
					if(arrayLen(arrChild) LT row.site_x_option_group_set_sort){
						resort=true;
					}else if(arrayLen(arrChild) GTE row.site_x_option_group_set_sort){
						if(arrChild[row.site_x_option_group_set_sort] NEQ id){
							resort=true;
						}
					/*}else if(arrayLen(arrChild)+1 EQ row.site_x_option_group_set_sort){
						arrayAppend(arrChild, id);*/
					}else{
						resort=true;
					} 
			//writedump(resort);
					if(resort){
						db.sql="select site_x_option_group_set_id from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)#
						WHERE 
						site_x_option_group_set_deleted = #db.param(0)# and 
						site_x_option_group_set_master_set_id = #db.param(0)# and 
						site_x_option_group_set_parent_id= #db.param(row.site_x_option_group_set_parent_id)# and 
						site_option_group_id = #db.param(row.site_option_group_id)# and 
						site_option_app_id = #db.param(row.site_option_app_id)# and 
						site_id = #db.param(arguments.site_id)# 
						ORDER BY site_x_option_group_set_sort";
						var qSort=db.execute("qSort");
						var arrTemp=[];
						for(var row2 in qSort){
							arrayAppend(arrTemp, row2.site_x_option_group_set_id);
						}
						t9.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"][row.site_option_group_id]=arrTemp;
					}
					//writedump(t9.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"][row.site_option_group_id]);
					tempUniqueStruct[row.site_x_option_group_set_parent_id&"_"&id]=true;
				}
			}else if(newRecord){
				// if i get an undefined error here, it is probably because memory caching is disable on the parent site_option_group_id
				var arrChild=t9.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"][row.site_option_group_id];
				var found=false;
				for(var i=1;i LTE arrayLen(arrChild);i++){
					if(row.site_x_option_group_set_id EQ arrChild[i]){
						found=true;
						break;
					}
				}
				if(not found){
					arrayAppend(arrChild, row.site_x_option_group_set_id);
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
				optionStruct=typeStruct.optionLookup[row.groupSetOptionId].optionStruct;
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
		t9.optionGroupSetId[id&"_f"&row.groupSetOptionId]=tempValue;
		if(row.typeId EQ 3){
			if(row.groupSetOriginal NEQ ""){
				t9.optionGroupSetId["__original "&id&"_f"&row.groupSetOptionId]="/zupload/site-options/"&row.groupSetOriginal;
			}else{
				t9.optionGroupSetId["__original "&id&"_f"&row.groupSetOptionId]=tempValue;
			}
		} 
	}
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-2<br>'); startTime=gettickcount();
	 db.sql="SELECT * FROM 
	 #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# s1, 
	 #db.table("site_option_group", request.zos.zcoreDatasource)# s2
	WHERE s1.site_id = #db.param(arguments.site_id)# and 
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	s1.site_x_option_group_set_deleted = #db.param(0)# and 
	s2.site_option_group_deleted = #db.param(0)# and 
	s1.site_id = s2.site_id and 
	s1.site_option_group_id = s2.site_option_group_id and 
	s1.site_x_option_group_set_id = #db.param(arguments.site_x_option_group_set_id)# ";
	var qS=db.execute("qS"); 
	if(debug) writeoutput(((gettickcount()-startTime)/1000)& 'seconds1-3<br>'); startTime=gettickcount();
	if(debug) writedump(qS);
	for(row in qS){
		if(not structkeyexists(t9, 'optionGroupSetQueryCache')){
			t9.optionGroupSetQueryCache={};
		}
		if(request.zos.enableSiteOptionGroupCache and row.site_option_group_enable_cache EQ 1){
			t9.optionGroupSetQueryCache[row.site_x_option_group_set_id]=row;
		}
		if(structkeyexists(t9.optionGroupSetArrays, row.site_option_app_id&chr(9)&row.site_option_group_id&chr(9)&row.site_x_option_group_set_parent_id) EQ false){
			t9.optionGroupSetArrays[row.site_option_app_id&chr(9)&row.site_option_group_id&chr(9)&row.site_x_option_group_set_parent_id]=arraynew(1);
		}
		var ts=structnew();
		ts.__sort=row.site_x_option_group_set_sort;
		ts.__setId=row.site_x_option_group_set_id;
		ts.__dateModified=row.site_x_option_group_set_updated_datetime;
		ts.__groupId=row.site_option_group_id;
		ts.__createdDatetime=row.site_x_option_group_set_created_datetime;
		ts.__approved=row.site_x_option_group_set_approved;
		ts.__title=row.site_x_option_group_set_title;
		ts.__parentID=row.site_x_option_group_set_parent_id;
		ts.__summary=row.site_x_option_group_set_summary;
		// build url
		if(row.site_x_option_group_set_image_library_id NEQ 0){
			ts.__image_library_id=row.site_x_option_group_set_image_library_id;
		}
		if(row.site_option_group_enable_unique_url EQ 1){
			if(row.site_x_option_group_set_override_url NEQ ""){
				ts.__url=row.site_x_option_group_set_override_url;
			}else{
				var urlId=application.zcore.functions.zvar('optionGroupUrlID', arguments.site_id);
				if(urlId EQ "" or urlId EQ 0){
					throw("site_option_group_url_id is not set for site_id, #arguments.site_id#.");
				}
				ts.__url="/#application.zcore.functions.zURLEncode(row.site_x_option_group_set_title, '-')#-#urlId#-#row.site_x_option_group_set_id#.html";
			}
		} 
		var fieldStruct=t9.optionGroupFieldLookup[ts.__groupId];
		
		var defaultStruct=t9.optionGroupDefaults[row.site_option_group_id];
		for(var i2 in fieldStruct){
			var cf=t9.optionLookup[i2];
			if(structkeyexists(t9.optionGroupSetId, "__original "&ts.__setId&"_f"&i2)){
				ts["__original "&cf.name]=t9.optionGroupSetId["__original "&ts.__setId&"_f"&i2];
			}
			if(structkeyexists(t9.optionGroupSetId, ts.__setId&"_f"&i2)){
				ts[cf.name]=t9.optionGroupSetId[ts.__setId&"_f"&i2];
			}else if(structkeyexists(defaultStruct, cf.name)){
				ts[cf.name]=defaultStruct[cf.name];
			}else{
				ts[cf.name]="";
			}
		}
		if(debug) writedump(ts);
		
		t9.optionGroupSet[row.site_x_option_group_set_id]= ts;
		arrChild=[];

		// don't sort versions
		if(row.site_x_option_group_set_master_set_id EQ 0){
			if(typeStruct.optionGroupLookup[row.site_option_group_id].site_option_group_enable_sorting EQ 1){
				var arrChild=t9.optionGroupSetArrays[row.site_option_app_id&chr(9)&ts.__groupId&chr(9)&row.site_x_option_group_set_parent_id];
				var resort=false;
				if(arrayLen(arrChild) GTE row.site_x_option_group_set_sort){
					if(arrayLen(arrChild) LT row.site_x_option_group_set_sort){
						resort=true;
					}else if(arrChild[row.site_x_option_group_set_sort].__setId NEQ row.site_x_option_group_set_id){
						resort=true;
					}else{ 
						arrChild[row.site_x_option_group_set_sort]=ts;
					} 
				}else{
					resort=true;
				} 
				if(resort){  

					if(not structkeyexists(t9.optionGroupSetId, row.site_x_option_group_set_parent_id&"_childGroup")){
						t9.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"]={};
					}
					if(not structkeyexists(t9.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"], row.site_option_group_id)){
						t9.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"][row.site_option_group_id]=[];
					}
					try{
						var arrChild2=t9.optionGroupSetId[row.site_x_option_group_set_parent_id&"_childGroup"][row.site_option_group_id];
						var arrTemp=[]; 
						for(var i=1;i LTE arraylen(arrChild2);i++){
							arrayAppend(arrTemp, t9.optionGroupSet[arrChild2[i]]);
						}
						t9.optionGroupSetArrays[row.site_option_app_id&chr(9)&ts.__groupId&chr(9)&row.site_x_option_group_set_parent_id]=arrTemp;
					}catch(Any e){
						application.zcore.siteOptionCom.updateOptionGroupCacheByGroupId(row.site_option_group_id);
						//application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
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
				var arrChild=t9.optionGroupSetArrays[row.site_option_app_id&chr(9)&ts.__groupId&chr(9)&row.site_x_option_group_set_parent_id];
				var found=false;
				for(var i=1;i LTE arrayLen(arrChild);i++){
					if(row.site_x_option_group_set_id EQ arrChild[i].__setID){
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
 
 
<cffunction name="getSiteMap" localmode="modern" access="public">
	<cfargument name="arrURL" type="array" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var i=0;
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)#, 
	#db.table("site_option", request.zos.zcoreDatasource)#
	where 
	site_option_group.site_id = site_option.site_id and 
	site_option_group.site_option_group_id = site_option.site_option_group_id and 
	site_option_deleted=#db.param(0)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_option_group_parent_id = #db.param('0')# and 
	site_option_group.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_disable_site_map = #db.param(0)# and 
	site_option_group.site_option_group_enable_unique_url = #db.param(1)# 
	GROUP BY site_option_group.site_option_group_id";
	qGroup=db.execute("qGroup");
	for(row in qGroup){ 
		arr1=optionGroupStruct(row.site_option_group_name, 0, row.site_id, {__groupId=0,__setId=0}, row.site_option_name);
		for(i=1;i LTE arraylen(arr1);i++){
			if(arr1[i].__approved EQ 1){
				t2=StructNew();
				t2.groupName=row.site_option_group_display_name;
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
	db.sql="select site_option_group_id, site_option_group_parent_id, site_option_group_name, site_id FROM
	#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group WHERE 
	site_id <> #db.param(-1)# and 
	site_option_group_deleted = #db.param(0)# 
	ORDER BY site_option_group_parent_id";
	qGroup=db.execute("qGroup");
	groupStruct={};
	for(row in qGroup){
		if(not structkeyexists(groupStruct, row.site_id)){
			groupStruct[row.site_id]={};
		}
		groupStruct[row.site_id][row.site_option_group_id]={
			parentId:row.site_option_group_parent_id,
			name:row.site_option_group_name
		};
	}
	while(true){
		db.sql="select site_x_option_group_set_id, site_option_group.site_option_group_parent_id, site.site_id, site_option_group.site_option_group_name FROM
		#db.table("site", request.zos.zcoreDatasource)# site, 
		#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set,
		#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group
		where 
		site_deleted = #db.param(0)# and 
		site_x_option_group_set_master_set_id = #db.param(0)# and 
		site_x_option_group_set_deleted = #db.param(0)# and 
		site_option_group_deleted = #db.param(0)# and 
		site_option_group.site_option_group_id = site_x_option_group_set.site_option_group_id and 
		site_x_option_group_set.site_id = site.site_id and 
		site_option_group.site_id = site.site_id and 
		site_option_group.site_id = site_x_option_group_set.site_id and 
		site_option_group_enable_unique_url = #db.param(1)# and 
		site_x_option_group_set.site_x_option_group_set_active = #db.param(1)# and 
		site_x_option_group_set.site_x_option_group_set_approved = #db.param(1)# and 
		site_option_group_public_searchable = #db.param(1)# and 
		site.site_active=#db.param(1)# and 
		site.site_id <> #db.param(-1)# "; 
		if(structkeyexists(form, 'sid') and form.sid NEQ ""){
			db.sql&=" and site.site_id = #db.param(form.sid)# ";
		}
		db.sql&=" LIMIT #db.param(offset)#, #db.param(limit)#"; 
		qGroup=db.execute("qGroup"); 
		offset+=limit;
		if(qGroup.recordcount EQ 0){
			break;
		}else{
			for(row in qGroup){
				arrGroup=[];
				parentId=row.site_option_group_parent_id;
				while(true){
					if(parentId EQ 0){
						break;
					}
					tempStruct=groupStruct[row.site_id][parentId];
					parentId=tempStruct.parentId;
					arrayAppend(arrGroup, tempStruct.name);
				}
				arrayAppend(arrGroup, row.site_option_group_name);
				indexOptionGroupRow(row.site_x_option_group_set_id, row.site_id, arrGroup); 
			}
		}
	}
	db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
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


<cffunction name="deleteOptionGroupSetIndex" localmode="modern" access="public">
	<cfargument name="setId" type="string" required="no" default="">
	<cfargument name="site_id" type="string" required="no" default="">
	<cfscript>
	// note: deactivateOptionGroupSet also calls this function
	var db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoredatasource)# 
	WHERE site_id =#db.param(arguments.site_id)# and 
	app_id = #db.param(14)# and 
	search_deleted = #db.param(0)# and 
	search_table_id = #db.param(arguments.setId)# ";
	db.execute("qDelete");

	if(structkeyexists(application.siteStruct[request.zos.globals.id].globals.soGroupData, 'optionGroupSetQueryCache')){
		structdelete(application.siteStruct[request.zos.globals.id].globals.soGroupData.optionGroupSetQueryCache, arguments.setId);
	}
	</cfscript>
</cffunction>

<cffunction name="deactivateOptionGroupSet" localmode="modern" access="public">
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
	db.sql="UPDATE #db.table("site_x_option_group_set", request.zos.zcoredatasource)# 
	SET 
	site_x_option_group_set_approved=#db.param(approved)#,
	site_x_option_group_set_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE site_id =#db.param(arguments.site_id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and 
	site_x_option_group_set_id = #db.param(arguments.setId)# ";
	db.execute("qUpdate");
	db.sql="select site_option_group_id, site_x_option_group_set_image_library_id from #db.table("site_x_option_group_set", request.zos.zcoredatasource)# 
	WHERE site_id =#db.param(arguments.site_id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and 
	site_x_option_group_set_id = #db.param(arguments.setId)# ";
	qSet=db.execute("qSet");
	if(qSet.recordcount){
		groupId=qSet.site_option_group_id;
		if(qSet.site_x_option_group_set_image_library_id NEQ 0){
			application.zcore.imageLibraryCom.unapproveLibraryId(qSet.site_x_option_group_set_image_library_id);
		}
		typeStruct=getTypeData(arguments.site_id);
		t9=getSiteData(arguments.site_id);
		var groupStruct=typeStruct.optionGroupLookup[groupId]; 

		deleteOptionGroupSetIndex(qSet.site_x_option_group_set, qSet.site_id);

		if(request.zos.enableSiteOptionGroupCache and groupStruct.site_option_group_enable_cache EQ 1 and structkeyexists(t9.optionGroupSet, arguments.setId)){
			groupStruct=t9.optionGroupSet[arguments.setId];
			groupStruct.__approved=approved;
			application.zcore.functions.zCacheJsonSiteAndUserGroup(arguments.site_id, application.zcore.siteGlobals[arguments.site_id]); 
		}
	}
	
	</cfscript>
</cffunction>




<cffunction name="prepareRecursiveData" localmode="modern" access="public">
	<cfargument name="site_option_id" type="string" required="yes">
	<cfargument name="site_option_group_id" type="string" required="yes">
	<cfargument name="setOptionStruct" type="struct" required="yes">
	<cfargument name="enableSearchView" type="boolean" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=arguments.setOptionStruct;
	arrLabel=[];
	arrValue=[];
	arrParent=[];
	delimiter="|";
	if(arguments.setOptionStruct.selectmenu_delimiter EQ "|"){
		delimiter=",";
	}
	if(structkeyexists(ts,'selectmenu_groupid') and ts.selectmenu_groupid NEQ ""){
		parentId=application.zcore.functions.zso(form, 'site_x_option_group_set_parent_id', true);
		// need parent group of ts.selectmenu_groupid
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
		WHERE site_option_group_id=#db.param(ts.selectmenu_groupid)# and 
		site_option_group_deleted=#db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		qParentGroup=db.execute("qParentGroup", "", 10000, "query", false); 
		found=false; 
		if(qParentGroup.recordcount NEQ 0 and qParentGroup.site_option_group_parent_id NEQ 0 and form.site_x_option_group_set_parent_id NEQ 0){ 
			for(i=1;i<=50;i++){
				db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
				 site_x_option_group_set_deleted=#db.param(0)# and 
				 site_x_option_group_set_id=#db.param(parentId)# and 
				 site_id = #db.param(request.zos.globals.id)#";
				qParentSet=db.execute("qParentSet"); 
				if(qParentSet.site_option_group_id EQ qParentGroup.site_option_group_parent_id){
					parentId=qParentSet.site_x_option_group_set_id;
					found=true;
					break;
				}
				if(qParentSet.site_x_option_group_set_parent_id EQ 0){
					break;
				}else{
					parentId=qParentSet.site_x_option_group_set_parent_id;
				}
				if(i EQ 50){
					throw("Infinite loop detected in group heirarchy");
				}
			}
		}
		if(not found){
			parentId=0;
		} 
		db.sql="select s1.site_option_id labelFieldId, s2.site_option_id valueFieldId ";
		 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
			db.sql&=",  s3.site_option_id parentFieldID ";
		 }
		 db.sql&="
		from 
		 #db.table("site_option", request.zos.zcoredatasource)# s1 , 
		 #db.table("site_option", request.zos.zcoredatasource)# s2";
		 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
			db.sql&=",  #db.table("site_option", request.zos.zcoredatasource)# s3 ";
		 }
		 db.sql&=" WHERE 
		 s1.site_option_deleted = #db.param(0)# and 
		 s2.site_option_deleted = #db.param(0)# and
		s1.site_option_group_id = #db.param(ts.selectmenu_groupid)# and 
		s1.site_option_name = #db.param(ts.selectmenu_labelfield)# and 
		
		s2.site_id = s1.site_id and 
		s2.site_option_group_id = #db.param(ts.selectmenu_groupid)# and 
		s2.site_option_name = #db.param(ts.selectmenu_valuefield)# and 
		";
		 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
			db.sql&=" s3.site_id = s1.site_id and 
			s3.site_option_group_id = #db.param(ts.selectmenu_groupid)# and 
			s3.site_option_name = #db.param(ts.selectmenu_parentfield)# and 
			s3.site_option_deleted = #db.param(0)# and ";
		 }
		 db.sql&="
		s2.site_id = #db.param(request.zos.globals.id)#
		GROUP BY s2.site_id";
		qTemp=db.execute("qTemp", "", 10000, "query", false);  

		if(qTemp.recordcount NEQ 0){
			db.sql="select 
			s1.site_x_option_group_set_id id, 
			s1.site_x_option_group_value label,
			set1.site_x_option_group_set_sort sort,
			 s2.site_x_option_group_value value";
			 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
				db.sql&=", s3.site_x_option_group_value parentId ";
			//	db.sql&=", s3.site_x_option_group_value parentId ";
			 }
			 db.sql&=" from (
			 #db.table("site_x_option_group_set", request.zos.zcoredatasource)# set1,
			 #db.table("site_x_option_group", request.zos.zcoredatasource)# s1 , 
			 #db.table("site_x_option_group", request.zos.zcoredatasource)# s2 ";
			 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
				db.sql&=" ,#db.table("site_x_option_group", request.zos.zcoredatasource)# s3";
			 }
			db.sql&=") WHERE ";
			if(parentID NEQ 0){
				db.sql&=" set1.site_x_option_group_set_parent_id=#db.param(parentId)# and ";
			}
			db.sql&=" set1.site_x_option_group_set_deleted=#db.param(0)# and 
			set1.site_x_option_group_set_id=s1.site_x_option_group_set_id and
			set1.site_id = s1.site_id and 
			s1.site_x_option_group_deleted = #db.param(0)# and 
			s2.site_x_option_group_deleted = #db.param(0)# and 
			s1.site_option_id = #db.param(qTemp.labelFieldId)# and 
			s1.site_option_group_id = #db.param(ts.selectmenu_groupid)# and 
			s1.site_x_option_group_set_id = s2.site_x_option_group_set_id AND 
			s2.site_id = s1.site_id and 
			s2.site_option_id = #db.param(qTemp.valueFieldId)# and 
			s2.site_option_group_id = #db.param(ts.selectmenu_groupid)# and ";
			 if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
				db.sql&=" s3.site_id = s1.site_id and 
				s3.site_option_id = #db.param(qTemp.parentFieldID)# and 
				s3.site_option_group_id = #db.param(ts.selectmenu_groupid)# and 
				s1.site_x_option_group_set_id = s3.site_x_option_group_set_id and 
				s3.site_x_option_group_deleted = #db.param(0)# and ";
			 }
			if(not structkeyexists(ts, 'selectmenu_parentfield') or ts.selectmenu_parentfield EQ ""){
				if(arguments.site_option_group_id EQ ts.selectmenu_groupid){
					// exclude current site_x_option_group_set_id from query
					db.sql&="  s1.site_x_option_group_set_id <> #db.param(form.site_x_option_group_set_id)# and ";
				}
			}
			db.sql&=" s2.site_id = #db.param(request.zos.globals.id)#
			GROUP BY s1.site_x_option_group_set_id, s2.site_x_option_group_set_id ";

			if(not structkeyexists(ts, 'selectmenu_parentfield') or ts.selectmenu_parentfield EQ ""){
				db.sql&=" ORDER BY label ASC ";
			}else{
				db.sql&=" ORDER BY set1.site_x_option_group_set_sort ASC  ";
			}
			qTemp2=db.execute("qTemp2", "", 10000, "query", false); 
			//writedump(qtemp2);abort;
		}

		// ts.selectmenu_groupid
		// site_option_group_id=9
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
					ds[row2.parentId][row2.id]={ value: row2.value, sort:row2.sort, label:row2.label, id:row2.id, parentId:row2.parentId };
				}
			}
			for(n in ds){
				arrKey=structsort(ds[n], "text", "asc", "sort");
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
				variables.rebuildParentStructData(ds2, arrLabel, arrValue, arrCurrent, arrParent, 0);
			}
		}
	}
	rs= { 
		ts: ts, 
		arrLabel: arrLabel, 
		arrValue: arrValue,
		arrParent: arrParent
	};
	if(structkeyexists(local, 'qTemp2')){
		rs.qTemp2=qTemp2;
	}
	return rs;
	</cfscript>
</cffunction>


 
<!--- application.zcore.siteOptionCom.activateOptionAppId(site_option_app_id); --->
<cffunction name="activateOptionAppId" localmode="modern" returntype="any" output="no">
	<cfargument name="site_option_app_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	 db.sql="UPDATE #db.table("site_option_app", request.zos.zcoreDatasource)# site_option_app 
	 SET site_option_app_active = #db.param('1')#, 
	 site_option_app_updated_datetime=#db.param(request.zos.mysqlnow)# 
	 WHERE site_option_app_id=#db.param(arguments.site_option_app_id)# and 
	 site_option_app_deleted = #db.param(0)# and 
	 site_id = #db.param(request.zos.globals.id)#";
	 db.execute("q");
	</cfscript>
</cffunction>


<!--- /z/_com/app/site-option?method=getNewOptionAppId --->
<cffunction name="getNewOptionAppId" localmode="modern" access="remote" roles="member" returntype="any" output="no">
	<cfargument name="app_id" type="string" required="yes">
	<cfscript>
	ts.datasource=request.zos.zcoreDatasource;
	ts.table="site_option_app";
	ts.struct=structnew();
	ts.struct.site_id=request.zos.globals.id;
	ts.struct.app_id=arguments.app_id;
	ts.struct.site_option_app_active=0;
	//ts.debug=true;
	//ts.struct.site_option_app_datetime=request.zos.mysqlnow;
	site_option_app_id=application.zcore.functions.zInsert(ts);
	if(site_option_app_id EQ false){
		application.zcore.template.fail("Error: zcorerootmapping.com.app.site-option.cfc - getNewOptionAppId() failed to insert into site_option_app.");
	}
	if(application.zcore.functions.zso(form, 'method') EQ 'getNewOptionAppId'){
		writeoutput('new id:'&site_option_app_id);
		application.zcore.functions.zabort();
	}else{
		return site_option_app_id;
	}
	</cfscript>
</cffunction>

<!--- this.getOptionAppById(site_option_app_id, app_id, newOnMissing); --->
<cffunction name="getOptionAppById" localmode="modern" returntype="any" output="yes">
	<cfargument name="site_option_app_id" type="string" required="yes">
	<cfargument name="app_id" type="string" required="yes">
	<cfargument name="newOnMissing" type="boolean" required="no" default="#true#">
	<cfscript>
	var qG=0;
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #request.zos.queryObject.table("site_option_app", request.zos.zcoreDatasource)# site_option_app 
	WHERE site_option_app_id = #db.param(arguments.site_option_app_id)# and 
	site_option_app_deleted = #db.param(0)# and 
	site_id =#db.param(request.zos.globals.id)#";
	qG=db.execute("qG");
	if(qG.recordcount EQ 0){
		if(arguments.newOnMissing){
			arguments.site_option_app_id=this.getNewOptionAppId(arguments.app_id);
			db.sql="SELECT * FROM #request.zos.queryObject.table("site_option_app", request.zos.zcoreDatasource)# site_option_app 
			WHERE site_option_app_id = #db.param(arguments.site_option_app_id)# and 
			site_option_app_deleted = #db.param(0)# and
			site_id =#db.param(request.zos.globals.id)#";
			qG=db.execute("qG");
		}else{
			return false;
		}
	}
	return qG;
	</cfscript>
</cffunction> 

<!--- application.zcore.siteOptionCom.deleteOptionAppId(site_option_app_id); --->
<cffunction name="deleteOptionAppId" localmode="modern" returntype="any" output="no">
	<cfargument name="site_option_app_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	var q=0;
	var db=request.zos.queryObject;
	typeStruct=getTypeData(arguments.site_id);
	if(arguments.site_option_app_id NEQ 0 and arguments.site_option_app_id NEQ ""){
		db.sql="SELECT * FROM #request.zos.queryObject.table("site_x_option", request.zos.zcoreDatasource)# site_x_option, 
		#request.zos.queryObject.table("site_option", request.zos.zcoreDatasource)# site_option 
		WHERE site_x_option.site_id = #db.param(request.zos.globals.id)# and 
		site_x_option_deleted = #db.param(0)# and 
		site_option_deleted = #db.param(0)# and 
		site_option.site_id=#db.param(arguments.site_id)# and  
		site_x_option.site_option_id = site_option.site_option_id and 
		site_x_option.site_option_app_id=#db.param(arguments.site_option_app_id)# and 
		site_option_type_id IN (#db.param(3)#, #db.param(9)#) and 
		site_x_option_value <> #db.param('')# and 
		site_option_type_id=#db.param('3')#";
		path=application.zcore.functions.zvar('privatehomedir',arguments.site_id)&'zupload/site-options/';
		securepath=application.zcore.functions.zvar('privatehomedir',arguments.site_id)&'zuploadsecure/site-options/';
		qS=db.execute("qS");
		for(i=1;i LTE qS.recordcount;i++){
			optionStruct=typeStruct.optionLookup[row.site_option_id].optionStruct;
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
		db.sql="SELECT * FROM #request.zos.queryObject.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group, 
		#request.zos.queryObject.table("site_option", request.zos.zcoreDatasource)# site_option 
		WHERE site_x_option_group.site_id = #db.param(request.zos.globals.id)# and 
		site_option.site_id=#db.param(arguments.site_id)# and  
		site_x_option_group.site_option_id = site_option.site_option_id and 
		site_x_option_group.site_option_app_id=#db.param(arguments.site_option_app_id)# and 
		site_option_type_id IN (#db.param(3)#, #db.param(9)#) and 
		site_x_option_group_value <> #db.param('')# and 
		site_option_deleted = #db.param(0)# and 
		site_x_option_group_deleted = #db.param(0)# and 
		site_option_type_id=#db.param('3')#";
		qS=db.execute("qS");
		for(i=1;i LTE qS.recordcount;i++){
			optionStruct=typeStruct.optionLookup[row.site_option_id].optionStruct;
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
		
		db.sql="DELETE FROM #request.zos.queryObject.table("site_x_option", request.zos.zcoreDatasource)#  
		WHERE site_option_app_id = #db.param(arguments.site_option_app_id)# and 
		site_x_option_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		q=db.execute("q");
		db.sql="DELETE FROM #request.zos.queryObject.table("site_x_option_group", request.zos.zcoreDatasource)#  
		WHERE site_option_app_id = #db.param(arguments.site_option_app_id)# and 
		site_x_option_group_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		q=db.execute("q");
		db.sql="DELETE FROM #request.zos.queryObject.table("site_x_option_group_set", request.zos.zcoreDatasource)#  
		WHERE site_option_app_id = #db.param(arguments.site_option_app_id)# and 
		site_x_option_group_set_deleted = #db.param(0)# and 
		site_id = #db.param(arguments.site_id)#";
		q=db.execute("q");
		db.sql="DELETE FROM #request.zos.queryObject.table("site_option_app", request.zos.zcoreDatasource)#  
		WHERE site_option_app_id = #db.param(arguments.site_option_app_id)# and 
		site_option_app_deleted = #db.param(0)# and 
		 site_id = #db.param(arguments.site_id)#";
		q=db.execute("q");

		// Need more efficient way to rebuild after site_option_app_id delete - or remove this feature perhaps
		application.zcore.functions.zOS_cacheSiteAndUserGroups(arguments.site_id);
	}
	</cfscript>
</cffunction>





<!--- 
// you must have a group by in your query or it may miss rows
ts=structnew();
ts.site_option_app_id_field="rental.rental_site_option_app_id";
ts.count = 1; // how many images to get
application.zcore.siteOptionCom.getImageSQL(ts);
 --->
<cffunction name="getImageSQL" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qImages=0;
	var arrOutput=arraynew(1);
	var ts=structnew();
	var rs=structnew();
	ts.site_option_app_id_field="";
	ts.count=1;
	ss=arguments.ss;
	structappend(ss,ts,false);
	if(structkeyexists(ss, 'db')){
		db=ss.db;
	}else{
		db=request.zos.queryObject;
	}
	if(ss.site_option_app_id_field EQ ""){
		application.zcore.template.fail("Error: zcorerootmapping.com.app.site-option.cfc - displayImages() failed because ss.site_option_app_id_field is required.");	
	}
	rs.leftJoin="LEFT JOIN `"&request.zos.zcoreDatasource&"`.image ON "&ss.site_option_app_id_field&" = image.site_option_app_id and image_sort <= #db.param(ss.count)# and image.site_id = #db.param(request.zos.globals.id)#";
	rs.select=", cast(GROUP_CONCAT(image_id ORDER BY image_sort SEPARATOR '\t') as char) imageIdList, 
	cast(GROUP_CONCAT(image_caption ORDER BY image_sort SEPARATOR '\t') as char) imageCaptionList, 
	cast(GROUP_CONCAT(image_file ORDER BY image_sort SEPARATOR '\t') as char) imageFileList, 
	cast(GROUP_CONCAT(image_updated_datetime ORDER BY image_sort SEPARATOR '\t') as char) imageUpdatedDateList";
	return rs;
	</cfscript>
</cffunction>






<!--- 
var ts=application.zcore.functions.zGetEditableSiteOptionGroupSetById(groupStruct.__groupId, groupStruct.__setId);
ts.name="New name";
var rs=application.zcore.functions.zUpdateSiteOptionGroupSet(ts);
if(not rs.success){
	application.zcore.status.setStatus(rs.zsid, false, form, true);
	application.zcore.functions.zRedirect("/?zsid=#rs.zsid#");
}else{
	writeoutput('Success !');
}
 --->
<cffunction name="updateOptionGroupSet" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var optionsCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options"); 
	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)# site_option,
	 #db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group 
	 WHERE 
	 site_option.site_id = site_option_group.site_id and 
	 site_option.site_option_group_id = site_option_group.site_option_group_id and 
	site_option_group.site_option_group_id = #db.param(arguments.struct.site_option_group_id)# and 
	site_option_deleted = #db.param(0)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_option_group.site_id = #db.param(arguments.struct.site_id)#  ";
	var qD=db.execute("qD");
	structappend(form, arguments.struct, true);
	var arroption=[];
	for(var row in qD){
		arrayAppend(arroption, row.site_option_id);
		// doesn't work with time/date and other multi-field site option types probably...
		form['newvalue'&row.site_option_id]=arguments.struct[row.site_option_name];
	}
	form.site_option_id=arrayToList(arroption, ','); 
	var rs=optionsCom.internalGroupUpdate(); 
	return rs;
	</cfscript>
</cffunction>


<cffunction name="getEditableOptionGroupSetById" localmode="modern" access="public">
	<cfargument name="arrGroupName" type="array" required="yes">
	<cfargument name="site_x_option_group_set_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="no" default="#request.zos.globals.id#">  
	<cfscript>
	var s=getOptionGroupSetById(arguments.arrGroupName, arguments.site_x_option_group_set_id);
	var db=request.zos.queryObject;
	if(arguments.site_id NEQ request.zos.globals.id){
		throw("zGetEditableOptionGroupSetById() doesn't support other site ids yet.");
	}
	if(structcount(s) EQ 0){
		throw("site_x_option_group_set_id, #arguments.site_x_option_group_set_id#, doesn't exist, so it can't be edited.");
	}
	db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
	site_x_option_group_set_id= #db.param(arguments.site_x_option_group_set_id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and 
	site_id = #db.param(arguments.site_id)# ";
	var qS=db.execute("qS");
	if(qS.recordcount EQ 0){
		throw("site_x_option_group_set_id, #arguments.site_x_option_group_set_id#, doesn't exist, so it can't be edited.");
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
	<cfargument name="site_option_app_id" type="string" required="no" default="0">
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
			return '<script>var zVisitorTrackingDisabled=true; </script>';
		}
	 } 
	if(arguments.disableEditing EQ false and contentConfig.contentEmailFormat EQ false){
		// and structkeyexists(application.zcore,'user') and structkeyexists(request.zos.userSession, 'groupAccess') and (structkeyexists(request.zos.userSession.groupAccess, "administrator")) 
		start='<div style="display:inline;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/admin/site-options/index?returnURL=#urlencodedformat(request.zos.originalURL)#&amp;jumpto=soid_#application.zcore.functions.zURLEncode(arguments.name,"_")#">';
		end='</div>';
	}
	if(arguments.site_option_app_id EQ 0){
		if(structkeyexists(Request.zOS.globals,"site_options") and structkeyexists(Request.zOS.globals.site_options,arguments.name)){
			if(Request.zOS.globals.site_option_edit_enabled[arguments.name] EQ 0){
				start="";
				end="";
			}
			if(arguments.site_id EQ request.zos.globals.id){
				return start&Request.zOS.globals.site_options[arguments.name]&end;
			}else{
				return start&application.siteStruct[arguments.site_id].globals.site_options[arguments.name]&end;
			}
		}else{
			//application.zcore.template.fail("zVarSO: `#arguments.name#`, is not a site option.");
			return "";//Site Option Missing: #arguments.name#";		
		}
	}else{
		if(structkeyexists(Request.zOS.globals,"site_option_app") and structkeyexists(Request.zOS.globals.site_option_app, arguments.site_option_app_id) and structkeyexists(Request.zOS.globals.site_option_app[arguments.site_option_app_id],arguments.name)){
			if(Request.zOS.globals.site_option_edit_enabled[arguments.name] EQ 0){
				start="";
				end="";
			}
			if(arguments.site_id EQ request.zos.globals.id){
				return start&Request.zOS.globals.site_option_app[arguments.site_option_app_id][arguments.name]&end;
			}else{
				return start&application.siteStruct[arguments.site_id].globals.site_option_app[arguments.site_option_app_id][arguments.name]&end;
			}
		}else{
			//application.zcore.template.fail("zVarSO: `#arguments.name#`, is not a site option.");
			return "";//Site Option Missing: #arguments.name#";		
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

<cffunction name="deleteGroupSetRecursively" localmode="modern" access="public" roles="member">
	<cfargument name="site_x_option_group_set_id" type="numeric" required="yes">
	<cfargument name="rowData" type="struct" required="no" default="#{}#">
	<cfscript>
	if(arguments.site_x_option_group_set_id EQ 0){
		// dangerous, this causes an infinite loop.
		throw("There is a site_x_option_group_set_id that is 0 on this site.  It must be manually deleted from the database to avoid infinite loops and other serious problems.");
	}
	db=request.zos.queryObject;
	if(structcount(arguments.rowData) EQ 0){
		db.sql="SELECT * FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
		WHERE  site_x_option_group_set_id=#db.param(arguments.site_x_option_group_set_id)# and  
		site_x_option_group_set_deleted = #db.param(0)# and 
		site_x_option_group_set.site_id = #db.param(request.zos.globals.id)#  ";
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
	if(row.site_x_option_group_set_override_url NEQ ""){
		structdelete(application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct, trim(row.site_x_option_group_set_override_url));
	}
	//writeLogEntry("deleteGroupSetRecursively set id:"&arguments.site_x_option_group_set_id);
	db.sql="SELECT * FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
	WHERE  site_x_option_group_set_parent_id=#db.param(arguments.site_x_option_group_set_id)# and  
	site_x_option_group_set_deleted = #db.param(0)# and
	site_x_option_group_set.site_id = #db.param(request.zos.globals.id)#  ";
	qSets=db.execute("qSets");
	for(row2 in qSets){
		deleteGroupSetRecursively(row2.site_x_option_group_set_id, {});
	}
	if(row.site_x_option_group_set_image_library_id NEQ 0){
		//writeLogEntry("deleteImageLibrary id:"&row.site_x_option_group_set_image_library_id);
		application.zcore.imageLibraryCom.deleteImageLibraryId(row.site_x_option_group_set_image_library_id);
	}
	// delete versions
	if(row.site_x_option_group_set_master_set_id EQ 0){
		db.sql="SELECT * FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
		WHERE  site_x_option_group_set_master_set_id=#db.param(arguments.site_x_option_group_set_id)# and  
		site_x_option_group_set_deleted = #db.param(0)# and
		site_x_option_group_set.site_id = #db.param(request.zos.globals.id)#  ";
		qVersion=db.execute("qVersion");
		for(row2 in qVersion){
			//writeLogEntry("deleteGroupSetRecursively version set id:"&row2.site_x_option_group_set_id);
			deleteGroupSetRecursively(row2.site_x_option_group_set_id);
		}
	}

	if(arraylen(application.zcore.soGroupData.arrCustomDelete)){
		typeIdList=arrayToList(application.zcore.soGroupData.arrCustomDelete, ",");

		db.sql="SELECT * FROM 
		#db.table("site_x_option_group", request.zos.zcoreDatasource)#,
		#db.table("site_option", request.zos.zcoreDatasource)#  
		WHERE site_x_option_group_set_id=#db.param(arguments.site_x_option_group_set_id)# and 
		site_option_type_id in (#db.trustedSQL(typeIdList)#) and 
		site_x_option_group.site_id = #db.param(request.zos.globals.id)# and 
		site_option.site_id = site_x_option_group.site_id and 
		site_x_option_group_value <> #db.param('')# and 
		site_option_deleted = #db.param(0)# and 
		site_x_option_group_deleted = #db.param(0)# and
		site_option.site_option_id = site_x_option_group.site_option_id ";
		qOptions=db.execute("qOptions");
		//writeLogEntry("#qOptions.recordcount# qOptions records that need onDelete");
		path=application.zcore.functions.zvar('privatehomedir', request.zos.globals.id)&'zupload/site-options/';
		securepath=application.zcore.functions.zvar('privatehomedir', request.zos.globals.id)&'zuploadsecure/site-options/';
		siteStruct=application.zcore.functions.zGetSiteGlobals(request.zos.globals.id);
		sog=siteStruct.soGroupData;
		for(row2 in qOptions){
			if(structkeyexists(sog.optionLookup, row2.site_option_id)){
				var currentCFC=application.zcore.siteOptionCom.getTypeCFC(sog.optionLookup[row2.site_option_id].type); 
				if(currentCFC.hasCustomDelete()){
					optionStruct=sog.optionLookup[row2.site_option_id].optionStruct;
					//writeLogEntry("delete for site_option_id:"&row2.site_option_id&" type:"&sog.optionLookup[row2.site_option_id].type);
					currentCFC.onDelete(row2, optionStruct); 
				}
			}
		}
	}   

	//writeLogEntry("deleteOptionGroupSetIndex version set id:"&arguments.site_x_option_group_set_id);
	deleteOptionGroupSetIndex(arguments.site_x_option_group_set_id, request.zos.globals.id);
	db.sql="DELETE FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)#  
	WHERE  site_x_option_group_set_id=#db.param(arguments.site_x_option_group_set_id)# and  
	site_x_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	result =db.execute("result");
	//writeLogEntry("deleted set values for set id:"&arguments.site_x_option_group_set_id);
	
	db.sql="DELETE FROM #request.zos.queryObject.table("site_x_option_group_set", request.zos.zcoreDatasource)#  
	WHERE  site_x_option_group_set_id=#db.param(arguments.site_x_option_group_set_id)# and  
	site_x_option_group_set_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	result =db.execute("result");
	//writeLogEntry("deleted set for set id:"&arguments.site_x_option_group_set_id);

	
	t9=application.zcore.siteGlobals[request.zos.globals.id].soGroupData;
	groupStruct=t9.optionGroupLookup[row.site_option_group_id]; 


	// If one of the parent groups has a change cfc defined, we need to execute the update function on that cfc here
	parentId=groupStruct.site_option_group_parent_id; 
	loopCount=0;
	while(true){
		if(parentId EQ 0){
			break;
		}
		loopCount++;
		if(loopCount GT 50){
			throw("Possible infinite loop detected for site_option_group_id: #parentId# - must change the site_option_group_parent_id value manually.");
		}
		groupStruct=application.zcore.functions.zGetSiteOptionGroupById(parentId);
		if(groupStruct.site_option_group_change_cfc_path NEQ "" and groupStruct.site_option_group_change_cfc_children EQ 1){
			// execute the change cfc path with the parent data, not current record.

			// get the data for the right site_x_option_group_set_id based on loop of site_x_option_group_set_parent_id?
			setParentId=form.site_x_option_group_set_parent_id;
			loopCount2=0;
			while(true){
				if(setParentId EQ 0){
					break;
				} 
				loopCount2++;
				if(loopCount GT 50){
					throw("Possible infinite loop detected for site_x_option_group_set_id: #setParentId# - must change the site_x_option_group_parent_id value manually.");
				}
				db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
				site_x_option_group_set_deleted=#db.param(0)# and 
				site_id = #db.param(request.zos.globals.id)# and 
				site_x_option_group_set_id=#db.param(setParentId)#";
				qSet=db.execute("qSet");
				if(qSet.recordcount EQ 0){
					break;
				}
				for(row in qSet){
					if(groupStruct.site_option_group_id EQ row.site_option_group_id){
						// this is the right record, execute here
						path=groupStruct.site_option_group_change_cfc_path;
						if(left(path, 5) EQ "root."){
							path=request.zRootCFCPath&removeChars(path, 1, 5);
						}
						changeCom=application.zcore.functions.zcreateObject("component", path); 
						arrGroupName=application.zcore.siteOptionCom.getOptionGroupNameArrayById(groupStruct.site_option_group_id);
						dataStruct=application.zcore.siteOptionCom.getOptionGroupSetById(arrGroupName, row.site_x_option_group_set_id, request.zos.globals.id, true);
						coreStruct={
							site_x_option_group_set_sort:dataStruct.__sort,
							// NOT USED YET: site_x_option_group_set_active:dataStruct.__active,
							site_option_group_id:dataStruct.__groupId,
							site_x_option_group_set_approved:dataStruct.__approved,
							site_x_option_group_set_override_url:application.zcore.functions.zso(dataStruct, '__url'),
							site_x_option_group_set_parent_id:dataStruct.__parentId,
							site_x_option_group_set_image_library_id:application.zcore.functions.zso(dataStruct, '__image_library_id', true),
							site_x_option_group_set_id:dataStruct.__setId
						};  
						changeCom[groupStruct.site_option_group_change_cfc_update_method](dataStruct, coreStruct);
					}
					setParentId=row.site_x_option_group_set_parent_id;
				}
			}
		}
		parentId=groupStruct.site_option_group_parent_id; 
	} 
	
	if(structkeyexists(groupStruct, 'site_option_group_change_cfc_path') and groupStruct.site_option_group_change_cfc_path NEQ ""){
		path=groupStruct.site_option_group_change_cfc_path;
		if(left(path, 5) EQ "root."){
			path=request.zRootCFCPath&removeChars(path, 1, 5);
		}
		changeCom=application.zcore.functions.zcreateObject("component", path); 
		//writeLogEntry("changeCom callback for set id:"&arguments.site_x_option_group_set_id);
		changeCom[groupStruct.site_option_group_change_cfc_delete_method](arguments.site_x_option_group_set_id);
	}
	</cfscript>
</cffunction>
	

<cffunction name="deleteGroupRecursively" localmode="modern" access="public" roles="member">
	<cfargument name="site_option_group_id" type="numeric" required="yes">
	<cfargument name="rebuildSiteCache" type="boolean" required="no" default="#true#">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var result=0;
	siteStruct=application.zcore.functions.zGetSiteGlobals(request.zos.globals.id);
	sog=siteStruct.soGroupData;
	db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)#  
	WHERE  site_option_group_parent_id=#db.param(arguments.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	qGroups=db.execute("qGroups");
	for(row in qGroups){
		deleteGroupRecursively(row.site_option_group_id, false);	
	}
	 
	db.sql="SELECT * FROM #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
	WHERE  site_x_option_group_set.site_option_group_id=#db.param(arguments.site_option_group_id)# and  
	site_x_option_group_set_deleted = #db.param(0)# and
	site_x_option_group_set.site_id = #db.param(request.zos.globals.id)#  ";
	qSets=db.execute("qSets");
	for(row in qSets){
		if(row.site_x_option_group_set_image_library_id NEQ 0){
			application.zcore.imageLibraryCom.deleteImageLibraryId(row.site_x_option_group_set_image_library_id);
		}
	}

	db.sql="SELECT * FROM #db.table("site_option", request.zos.zcoreDatasource)#, 
	#db.table("site_x_option_group", request.zos.zcoreDatasource)#  
	WHERE  site_x_option_group.site_option_group_id=#db.param(arguments.site_option_group_id)# and 
	site_option_type_id in (#db.param(3)#, #db.param(9)#) and 
	site_x_option_group.site_id = #db.param(request.zos.globals.id)# and 
	site_option.site_id = site_x_option_group.site_id and 
	site_x_option_group_value <> #db.param('')# and 
	site_option_deleted = #db.param(0)# and 
	site_x_option_group_deleted = #db.param(0)# and
	site_option.site_option_id = site_x_option_group.site_option_id ";
	qOptions=db.execute("qOptions");
	path=application.zcore.functions.zvar('privatehomedir', request.zos.globals.id)&'zupload/site-options/';
	securepath=application.zcore.functions.zvar('privatehomedir', request.zos.globals.id)&'zuploadsecure/site-options/';
	for(row in qOptions){
		if(structkeyexists(sog.optionLookup, row.site_option_id)){
			var currentCFC=application.zcore.siteOptionCom.getTypeCFC(sog.optionLookup[row.site_option_id].type); 
			if(currentCFC.hasCustomDelete()){
				optionStruct=sog.optionLookup[row.site_option_id].optionStruct;
				currentCFC.onDelete(row, optionStruct); 
			}
		}
	}
	db.sql="DELETE FROM #db.table("site_x_option_group", request.zos.zcoreDatasource)#  
	WHERE  site_option_group_id=#db.param(arguments.site_option_group_id)# and 
	site_x_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	result =db.execute("result");
	db.sql="DELETE FROM #request.zos.queryObject.table("site_x_option_group_set", request.zos.zcoreDatasource)#  
	WHERE  site_option_group_id=#db.param(arguments.site_option_group_id)# and 
	site_x_option_group_set_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	result =db.execute("result");
	
	db.sql="DELETE FROM #db.table("site_option_group_map", request.zos.zcoreDatasource)#  
	WHERE  site_option_group_id=#db.param(arguments.site_option_group_id)# and 
	site_option_group_map_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	result =db.execute("result");
	db.sql="DELETE FROM #db.table("site_option", request.zos.zcoreDatasource)#  
	WHERE  site_option_group_id=#db.param(arguments.site_option_group_id)# and 
	site_option_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)# ";
	result =db.execute("result");
	db.sql="DELETE FROM #db.table("site_option_group", request.zos.zcoreDatasource)#  
	WHERE  site_option_group_id=#db.param(arguments.site_option_group_id)# and 
	site_option_group_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	result =db.execute("result"); 

	if(arguments.rebuildSiteCache){
		application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
	}

	</cfscript>
</cffunction>
 
<cffunction name="userDashboardAdmin" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject; 
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_enable_user_dashboard_admin=#db.param(1)# and 
	site_option_group_deleted=#db.param(0)# 
	ORDER BY site_option_group_parent_id ASC, site_option_group_display_name ASC";
	qGroup=db.execute("qGroup");
	for(row in qGroup){ 
		if(row.site_option_group_parent_id NEQ 0){
			continue;
		}
		if(row.site_option_group_user_group_id_list EQ ""){
			continue;
		}
		arrGroup=listToArray(row.site_option_group_user_group_id_list, ",");
		hasAccess=false;
		for(groupId in arrGroup){
			if(application.zcore.user.checkGroupIdAccess(groupId)){
				hasAccess=true;
				break;
			}
		}
		if(not hasAccess){
			continue;
		}
		if(row.site_option_group_subgroup_alternate_admin EQ 1){
			if(row.site_option_group_user_child_limit EQ 1){
				currentUserIdValue=request.zsession.user.id&"|"&application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id);
				db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				site_option_group_id=#db.param(row.site_option_group_id)# and  
				site_x_option_group_set_deleted=#db.param(0)# and 
				site_x_option_group_set_user = #db.param(currentUserIdValue)# 
				ORDER BY site_x_option_group_set_sort ASC";
				qSet=db.execute("qSet"); 
				if(qSet.recordcount EQ 0){
					echo('<h2><a href="/z/admin/site-options/userAddGroup?site_option_app_id=0&site_x_option_group_set_id=&site_option_group_id=#row.site_option_group_id#&site_x_option_group_set_parent_id=0">Add #row.site_option_group_display_name#</a></h2>');
				}else{
					echo('<h2><a href="/z/admin/site-options/userEditGroup?site_option_app_id=0&site_x_option_group_set_id=#qSet.site_x_option_group_set_id#&site_option_group_id=#row.site_option_group_id#&site_x_option_group_set_parent_id=0">Edit #row.site_option_group_display_name#</a></h2>');
					echo('<ul>');
					for(row2 in qGroup){
						if(row2.site_option_group_parent_id EQ row.site_option_group_id){
							echo('<li><a href="/z/admin/site-options/userManageGroup?site_option_app_id=0&site_option_group_id=#row2.site_option_group_id#&site_x_option_group_set_parent_id=#qSet.site_x_option_group_set_id#">Manage #row.site_option_group_display_name#(s)</a></li>');
						}
					}
					echo('</ul>');
				}
			}else{
				echo('<h2><a href="/z/admin/site-options/userManageGroup?site_option_app_id=0&site_option_group_id=#row.site_option_group_id#&site_x_option_group_set_parent_id=0">Manage #row.site_option_group_display_name#(s)</a> | 
					<a href="/z/admin/site-options/userAddGroup?site_option_app_id=0&site_option_group_id=#row.site_option_group_id#&site_x_option_group_set_parent_id=0">Add #row.site_option_group_display_name#</a></h2>');
			//	echo('<li><a href="/z/admin/site-options/userAddGroup?site_option_app_id=0&site_option_group_id=#row.site_option_group_id#&site_x_option_group_set_parent_id=0">Add #row.site_option_group_display_name#(s)</a></li>');
			}
		}else{
			echo('<h2><a href="/z/admin/site-options/userManageGroup?site_option_app_id=0&site_option_group_id=#row.site_option_group_id#&site_x_option_group_set_parent_id=0">Manage #row.site_option_group_display_name#(s)</a> | 
			<a href="/z/admin/site-options/userAddGroup?site_option_app_id=0&site_option_group_id=#row.site_option_group_id#&site_x_option_group_set_parent_id=0">Add #row.site_option_group_display_name#</a></h2>');
		}
	} 
	</cfscript>
</cffunction> 

<cffunction name="sendChangeEmail" localmode="modern" access="public">
	<cfargument name="site_x_option_group_set_id" type="string" required="yes">
	<cfargument name="action" type="string" required="yes" hint="values are created|updated|deleted ">
	<cfscript>
	if(application.zcore.functions.zso(form, 'method') CONTAINS "import" or request.zos.originalURL CONTAINS "import" or structkeyexists(request.zos, 'sendChangeEmailSiteOptionGroupExecuted')){
		return;
	}
	request.zos.sendChangeEmailSiteOptionGroupExecuted=true;
	db=request.zos.queryObject; 
	if(application.zcore.user.checkGroupAccess("member")){
		return;
	}
	currentSetId=arguments.site_x_option_group_set_id;
	first=true;
	while(true){
		if(not first){ 
			request.isUserPrimaryGroup=false;
		} 
		first=false;
		db.sql="select * from #db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
		site_x_option_group_set_deleted=#db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		site_x_option_group_set_id=#db.param(currentSetId)# ";
		qCheckSet=db.execute("qCheckSet");
		if(qCheckSet.recordcount EQ 0){
			application.zcore.functions.z404("Invalid record.  set id doesn't exist: #currentSetId#");
		}
		if(qCheckSet.site_x_option_group_set_parent_id EQ 0){
			currentSetId=qCheckSet.site_x_option_group_set_id;
			break;
		}else{
			currentSetId=qCheckSet.site_x_option_group_set_parent_id;
		}
		i++;
		if(i > 255){
			throw("infinite loop");
		}
	}  
	if(qCheckSet.site_x_option_group_set_user NEQ ""){
		arrUser=listToArray(qCheckSet.site_x_option_group_set_user, "|");
		site_id=application.zcore.functions.zGetSiteIdFromSiteIdType(arrUser[2]);
	}
	user_id=qCheckSet.site_x_option_group_set_user
	db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# WHERE 
	user_deleted=#db.param(0)# and 
	site_id = #db.param(site_id)# and 
	user_id=#db.param(arrUser[1])# ";
	qUser=db.execute("qUser");
	
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# WHERE 
	site_option_group_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_id=#db.param(qCheckSet.site_option_group_id)# ";
	qGroup=db.execute("qGroup");
	groupName=qGroup.site_option_group_display_name;
	
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
	ts.html&='<p>#qCheckSet.site_x_option_group_set_title#</p> 
	<p>'; 
	if(arguments.action NEQ "deleted"){
		if(qGroup.site_option_group_enable_unique_url EQ 1){
			if(qCheckSet.site_x_option_group_set_override_url NEQ ""){
				link=qCheckSet.site_x_option_group_set_override_url;
			}else{
				var urlId=request.zos.globals.optionGroupUrlId;
				if(urlId EQ "" or urlId EQ 0){
					throw("site_option_group_url_id is not set for site_id, #site_id#.");
				}
				link="/#application.zcore.functions.zURLEncode(qCheckSet.site_x_option_group_set_title, '-')#-#urlId#-#qCheckSet.site_x_option_group_set_id#.html";
			}
			ts.html&='<a href="#request.zos.globals.domain##link#" target="_blank">View</a> | ';
		}
		ts.html&='<a href="#request.zos.globals.domain#/z/admin/site-options/editGroup?site_option_app_id=0&amp;site_option_group_id=#qCheckSet.site_option_group_id#&amp;site_x_option_group_set_id=#qCheckSet.site_x_option_group_set_id#&amp;site_x_option_group_set_parent_id=0" target="_blank">Edit</a>';
	}
	ts.html&=' | <a href="#request.zos.globals.domain#/z/admin/site-options/manageGroup?site_option_app_id=0&site_option_group_id=#qCheckSet.site_option_group_id#" target="_blank">Manage #groupName#(s)</a></p>
	
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
rs=application.zcore.siteOptionCom.deleteNotUpdatedOptionGroupSet(["groupName"]); 
application.zcore.status.setStatus(request.zsid, rs.deleteCount&" old records deleted");
--->
<cffunction name="deleteNotUpdatedOptionGroupSet" localmode="modern" access="public" returnType="struct">
	<cfargument name="arrGroupName" type="array" required="yes">
	<cfscript>
	groupId=getOptionGroupIdWithNameArray(arguments.arrGroupName, request.zos.globals.id);
	db=request.zos.queryObject;
	db.sql="SELECT * FROM 
	#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# WHERE 
	site_x_option_group_set_deleted = #db.param(0)# and 
	site_x_option_group_set_updated_datetime < #db.param(request.zos.mysqlnow)# and 
	site_option_group_id= #db.param(groupId)# and 
	site_id= #db.param(request.zos.globals.id)#";
	qSet=db.execute("qSet"); 
	rs={ success:true, deleteCount:0 };
	for(row in qSet){
		deleteGroupSetRecursively(row.site_x_option_group_set_id, row);
		rs.deleteCount++;
	}
	return rs;
	</cfscript>

</cffunction>

</cfoutput>
</cfcomponent>