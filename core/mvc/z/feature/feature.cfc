<cfcomponent>
<cfoutput> 
<!--- <cffunction name="onApplicationStart" localmode="modern" access="remote" roles="member">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	if(structkeyexists(arguments.sharedStruct, 'feature_id_list')){
		return; // TODO: remove this when I properly integrate this later.
	}
	// TODO: problem: the feature_id needs to be unique for all sites
	// compound key causes too much complexity, but we need to know which site is the source in order to get path info correct
		// import/backup could require setting the site_id column for each feature
	// have no trigger, force manual assignment of feature id as required field?


	// instead of site_id, i could use a domain name, like site_com, which the import/backup searches for to find the site_id
		// less likely that domain for features will ever change
		// i could store the feature
	db=request.zos.queryObject;
	db.sql="SELECT * 
	FROM #db.table("feature", request.zos.zcoreDatasource)#, 
	#db.table("site", request.zos.zcoreDatasource)#  
	WHERE
	feature.feature_deleted = #db.param(0)# and  
	feature.site_id = site.site_id and 
	site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# ";
	qFeature=db.execute("qFeature"); 
	arrId=[-1]; // force -1 to avoid having sql like "feature_id in ()" throw error
	for(row in qFeature){
		arrayAppend(arrId, row.feature_id);
	} 
	arguments.sharedStruct.feature_id_list=arrayToList(arrId, ",");
	</cfscript>
</cffunction> --->

<cffunction name="onSiteStart" localmode="modern" access="remote" roles="member">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	ss=arguments.sharedStruct;
	// if(structkeyexists(arguments.sharedStruct, 'featureStruct')){
	// 	return; // TODO: remove this when I properly integrate this later.
	// }
	db=request.zos.queryObject;
	db.sql="SELECT * 
	FROM #db.table("feature", request.zos.zcoreDatasource)#, 
	#db.table("feature_x_site", request.zos.zcoreDatasource)# 
	WHERE
	feature.feature_id = feature_x_site.feature_id and 
	feature_x_site.site_id = #db.param(ss.globals.id)# and 
	feature_x_site_active=#db.param(1)# and 
	feature_x_site_deleted=#db.param(0)# and 
	feature.feature_deleted = #db.param(0)# 
	ORDER BY feature_display_name ASC ";
	qFeature=db.execute("qFeature");  
	arrFeatureId=[-1]; // force -1 to avoid having sql like "feature_id in ()" throw error
	featureStruct={
		featureIdList:"",
		featureLookup:{}
	};
	for(row in qFeature){
		arrayAppend(arrFeatureId, row.feature_id);
		featureStruct.featureLookup[row.feature_id]=row;
	} 
	featureStruct.arrFeatureId=arrayToList(arrFeatureId, ",");
	featureStruct.featureIdList=arrayToList(arrFeatureId, ",");
	arguments.sharedStruct.featureStruct=featureStruct;
	</cfscript>
</cffunction>

<!--- application.zcore.featureCom.reloadFeatureCache() --->
<cffunction name="reloadFeatureCache" localmode="modern" access="public">
	<cfscript>
	featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
	ts=application.zcore;
	featureCacheCom.rebuildFeaturesCache(ts, false);

	onSiteStart(application.siteStruct[request.zos.globals.id]);
	</cfscript>
</cffunction>

<cffunction name="getFeatureIdList" localmode="modern" access="public">
	<cfscript>
	return application.siteStruct[request.zos.globals.id].featureStruct.featureIdList;
	</cfscript>
</cffunction>


<cffunction name="getFeatureIdForSchema" localmode="modern" access="public">
	<cfargument name="feature_schema_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select feature_id from #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE feature_schema_id =#db.param(arguments.feature_schema_id)# and 
	feature_schema_deleted=#db.param(0)# ";
	qId=db.execute("qId");
	if(qId.recordcount EQ 0){
		throw("Invalid feature_schema_id:#arguments.feature_schema_id#");
	}
	return qId.feature_id;
	</cfscript>
</cffunction>

<cffunction name="siteHasFeature" localmode="modern" access="public">
	<cfargument name="feature_id" type="string" required="yes">
	<cfscript>
	return structkeyexists(application.siteStruct[request.zos.globals.id].featureStruct.featureLookup, arguments.feature_id);
	</cfscript>
</cffunction>

<cffunction name="updateSiteDomainCache" localmode="modern" access="public">    
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfargument name="domain" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT site_domain, site_id FROM #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_deleted=#db.param(0)# and 
	site_active=#db.param(1)# and  
	site_id <> #db.param(-1)# ";
	qSite=db.execute("qSite");
	siteDomainLookup={};
	for(row in qSite){
		siteDomainLookup[row.site_domain]=row.site_id;
	}
	arguments.sharedStruct.siteDomainLookup=siteDomainLookup;
	</cfscript>
</cffunction>

<!--- application.zcore.featureCom.getFeatureSiteId(domain) --->
<cffunction name="getFeatureSiteId" localmode="modern" access="public">    
	<cfargument name="domain" type="string" required="yes">
	<cfscript>
	// TODO: need to move to onApplicationStart, and site.cfc in update/delete
	updateSiteDomainCache(application.zcore, arguments.domain);

	if(not structkeyexists(application.zcore.siteDomainLookup, arguments.domain)){
		throw("There is no active site with domain: #arguments.domain# and there is a feature that requires it.");
	}
	return application.zcore.siteDomainLookup[arguments.domain];
	</cfscript>
</cffunction>


<cffunction name="checkFeatureSecurity" localmode="modern" access="public">
	<cfargument name="feature_id" type="string" required="yes">
	<cfscript>
	return structkeyexists(application.siteStruct[request.zos.globals.id].featureStruct.featureLookup, arguments.feature_id);
	</cfscript>
</cffunction>

<!--- application.zcore.featureCom.filterSiteFeatureSQL(db, "feature") --->
<cffunction name="filterSiteFeatureSQL" localmode="modern" access="public">
	<cfargument name="db" type="component" required="yes">
	<cfargument name="tableName" type="string" required="yes">
	<cfscript>
	return " `#arguments.tableName#`.`feature_id` IN (#arguments.db.trustedSQL(application.siteStruct[request.zos.globals.id].featureStruct.featureIdList)#) ";
	</cfscript>
</cffunction>

<cffunction name="getFieldTypes" returntype="struct" localmode="modern" access="public">
	<cfscript>
	ts=getFieldTypeCFCs();
	for(i in ts){
		ts[i].init("feature", "feature");
	}
	return ts;
	</cfscript>
</cffunction>


<cffunction name="getTypeData" returntype="struct" localmode="modern" access="public">
	<cfargument name="site_id" type="string" required="yes" hint="site_id">
	<cfscript>
	return application.siteStruct[arguments.site_id].globals.featureSchemaData;
	</cfscript>
</cffunction>
 


 


<cffunction name="setFeatureMap" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ms=arguments.struct;
	db=request.zos.queryObject;
	db.sql="SELECT feature_schema.* 
	FROM #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema  
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
	db.sql="select * from 
	#db.table("feature_schema", request.zos.zcoreDatasource)#,
	#db.table("feature_x_site", request.zos.zcoreDatasource)#
	WHERE 
	feature_x_site.site_id=#db.param(request.zos.globals.id)# and 
	feature_x_site_deleted=#db.param(0)# and 
	feature_x_site.feature_id=feature_schema.feature_id and 
	feature_schema_allow_public=#db.param(1)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_schema_public_form_url<> #db.param('')# ";
	qS=db.execute("qS");
	for(row in qS){
		t9=structnew();
		t9.scriptName="/z/feature/feature-display/add";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/feature/feature-display/add";
		t9.urlStruct.feature_schema_id=row.feature_schema_id;
		ts2.uniqueURLStruct[trim(row.feature_schema_public_form_url)]=t9;
	}
	ts2.reservedAppUrlIdStruct[50]=[];
	t9=structnew();
	t9.type=1;
	t9.scriptName="/z/feature/feature-display/index";
	t9.urlStruct=structnew();
	t9.urlStruct[request.zos.urlRoutingParameter]="/z/feature/feature-display/index";
	t9.mapStruct=structnew();
	t9.mapStruct.urlTitle="zURLName";
	t9.mapStruct.dataId="feature_data_id";
	arrayappend(ts2.reservedAppUrlIdStruct[50], t9);
	db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)#, 
	#db.table("feature_schema", request.zos.zcoreDatasource)#
	WHERE 
	feature_data.site_id=#db.param(request.zos.globals.id)# and 
	feature_data.feature_id = feature_schema.feature_id and 
	feature_data.feature_schema_id = feature_schema.feature_schema_id and 
	feature_schema_enable_unique_url=#db.param(1)# and 
	feature_schema_deleted=#db.param(0)# and 
	feature_data_override_url<> #db.param('')# and 
	feature_data_master_set_id = #db.param(0)# and 
	feature_data_deleted = #db.param(0)# and
	feature_data_approved=#db.param(1)#";
	qS=db.execute("qS");
	for(row in qS){
		t9=structnew();
		t9.scriptName="/z/feature/feature-display/index";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/feature/feature-display/index";
		t9.urlStruct.feature_data_id=row.feature_data_id;
		ts2.uniqueURLStruct[trim(row.feature_data_override_url)]=t9;
	}
	</cfscript>
</cffunction>

<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from 
	(#db.table("feature_schema", request.zos.zcoreDatasource)#,
	#db.table("feature_x_site", request.zos.zcoreDatasource)#)
	WHERE 
	feature_x_site.site_id=#db.param(request.zos.globals.id)# and 
	feature_x_site.feature_id=feature_schema.feature_id and 
	feature_x_site_deleted=#db.param(0)# and 
	feature_schema_parent_id= #db.param(0)# and 
	feature_schema_deleted = #db.param(0)# and 
	feature_schema.feature_schema_disable_admin=#db.param(0)# 
	ORDER BY feature_schema_display_name ";
	qfeatureSchema=db.execute("qfeatureSchema"); 
	for(row in qFeatureSchema){
		ts=structnew();
		ts.featureName="Custom: "&row.feature_schema_display_name;
		ts.link="/z/feature/admin/features/manageSchema?feature_id=#row.feature_id#&feature_schema_id=#row.feature_schema_id#";
		ts.children=structnew();
		if(row.feature_schema_menu_name EQ ""){
			curMenu="Custom";
		}else{
			curMenu=row.feature_schema_menu_name;
		}
		
		if(structkeyexists(arguments.linkStruct, curMenu) EQ false){
			arguments.linkStruct[curMenu]={
				featureName:"Custom",
				link:"/z/feature/admin/features/index",
				children:{}
			};
		}
		plural="(s)";
		if(row.feature_schema_limit EQ 1 or right(row.feature_schema_display_name, 1) EQ "s"){
			plural="";
		}
		arguments.linkStruct[curMenu].children[row.feature_schema_display_name&plural]=ts;
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
application.zcore.featureCom.searchSchema("groupName", ts, 0, false);
 --->
<!--- <cffunction name="searchSchema" access="public" output="no" returntype="struct" localmode="modern">
	<cfargument name="featureVariableName" type="string" required="yes">
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
	feature_id=application.zcore.featureIdLookup[arguments.featureVariableName];
	fsd=application.zcore.featureData.featureSchemaData[feature_id]; 
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
	if(structkeyexists(t9, "featureSchemaIdLookup") and structkeyexists(fsd.featureSchemaIdLookup, arguments.parentSchemaId&chr(9)&arguments.groupName)){
		featureSchemaId=fsd.featureSchemaIdLookup[arguments.parentSchemaId&chr(9)&arguments.groupName];
		var schemaStruct=fsd.featureSchemaLookup[featureSchemaId];
		if(request.zos.enableSiteOptionGroupCache and schemaStruct.feature_schema_enable_cache EQ 1){
			arrSchema=getFeatureSchemaArray(arguments.featureVariableName, arguments.groupName);
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
				match=variables.processSearchArray(arguments.arrSearch, row, schemaStruct.feature_schema_id);
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

			sql=variables.processSearchArraySQL(arguments.arrSearch, fieldStruct, 1, schemaStruct.feature_schema_id);
			/*if(sql EQ ""){
				return rs;
			}*/
			//writedump(sql);abort;

			groupId=getSchemaIDWithNameArray(getFeatureIdByName(arguments.featureVariableName), [arguments.groupName]);


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
				arrayAppend(arrTable, "feature_data "&tableName);
				arrayAppend(arrWhere, "#tableName#.site_id = s1.site_id and 
				#tableName#.feature_data_id = s1.feature_data_id and 
				#tableName#.feature_field_id = '#application.zcore.functions.zescape(i)#' and 
				#tableName#.feature_schema_id = s1.feature_schema_id AND 
				#tableName#.feature_data_deleted = 0");
				fieldIndex++;
			}
			if(arguments.orderBy NEQ ""){
				// need to lookup the field feature_field_id using the feature_field_variable_name and groupId
				fieldIdLookup=t9.fieldIdLookup;
				if(structkeyexists(fieldIdLookup, groupId&chr(9)&arguments.orderBy)){
					feature_field_id=fieldIdLookup[groupId&chr(9)&arguments.orderBy];
					feature_field_type_id=t9.fieldLookup[feature_field_id].type;
					currentCFC=getTypeCFC(feature_field_type_id);

					arrayAppend(arrSelect, "s2.feature_data_value sVal2");
					arrayAppend(arrTable, "feature_data s2");
					arrayAppend(arrWhere, "s2.site_id = s1.site_id and 
					s2.feature_data_id = s1.feature_data_id and 
					s2.feature_field_id = '#application.zcore.functions.zescape(feature_field_id)#' and 
					s2.feature_schema_id = s1.feature_schema_id AND 
					s2.feature_data_deleted = 0");
					fieldIndex++;


					orderByStatement=" ORDER BY "&currentCFC.getSortSQL(2, arguments.orderByDirection);
				}else{
					throw("arguments.orderBy, ""#arguments.orderBy#"" is not a valid field in the feature_schema_id=#groupId# | ""#schemaStruct.feature_schema_variable_name#""");
				}
			}else if(structkeyexists(request.zos, 'featureFieldSearchDateRangeSortEnabled')){
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
			 #db.table("feature_data", request.zos.zcoreDatasource)# s1 
			WHERE  s1.feature_id=#db.param(form.feature_id)# and 
			s1.site_id=#db.param(request.zos.globals.id)# and 
			s1.feature_data_deleted = #db.param(0)# and    
			s1.feature_data_master_set_id = #db.param(0)# and  ";
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
</cffunction> --->
 
<!--- 
<cfscript>
ts.startDate=now();
ts.endDate=dateAdd("m", 1, now());
ts.limit=3;
ts.offset=0;
ts.orderBy="startDateASC"; // startDateASC | startDateDESC
arr1=application.zcore.featureCom.featureSchemaSetFromDatabaseBySearch(ts, request.zos.globals.id);
</cfscript>
 --->
<!--- <cffunction name="featureSchemaSetFromDatabaseBySearch" access="public" returntype="array" localmode="modern">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	ts=arguments.searchStruct;
	if(not structkeyexists(ts, 'arrSchemaName')){
		throw("arguments.searchStruct.arrSchemaName is required. It must be an array of feature_schema_variable_name values.");
	}
	fsd=application.zcore.featureData; 
	db=request.zos.queryObject;//  SEPARATOR #db.param("','")#) idlist
	 db.sql="SELECT feature_data_id FROM 
	 #db.table("feature_data", request.zos.zcoreDatasource)# s1
	WHERE 
	s1.feature_data_deleted = #db.param(0)# and 
	";
	var groupId=getSchemaIdWithNameArray(getFeatureIdByName(ts.featureVariableName), ts.arrSchemaName, arguments.site_id);
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
	schemaStruct=fsd.featureSchemaLookup[groupId];
	if(structkeyexists(ts, 'orderBy')){
		if(ts.orderBy EQ "startDateASC"){
			db.sql&="ORDER BY feature_data_start_date ASC";
		}else if(ts.orderBy EQ "startDateDESC"){
			db.sql&="ORDER BY feature_data_start_date DESC";
		}else{
			if(schemaStruct.feature_schema_enable_sorting EQ 1){
				db.sql&=" ORDER BY s1.feature_data_sort asc ";
			} 
		}
	}else{ 
		if(schemaStruct.feature_schema_enable_sorting EQ 1){
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
	 #db.table("feature_data", request.zos.zcoreDatasource)# s1, 
	 #db.table("feature_data", request.zos.zcoreDatasource)# s2
	WHERE  s1.site_id = #db.param(arguments.site_id)# and 
	s1.feature_data_deleted = #db.param(0)# and 
	s2.feature_data_deleted = #db.param(0)# and 
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
</cffunction> --->



<cffunction name="getSetParentLinks" access="public" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
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
	schemaStruct=getSchemaById(arguments.feature_id, curSchemaId); 
	if(arguments.linkCurrentPage){
		manageAction="manageSchema";
		if(form.method EQ "userManageSchema"){
			manageAction="userManageSchema";
		}
		arrayAppend(arrParent, '<a href="/z/feature/admin/features/#manageAction#?feature_schema_id=#curSchemaId#&amp;feature_data_parent_id=#curParentSetId#">Manage #schemaStruct.feature_schema_variable_name#(s)</a> / ');
	}

	// instead of getting the parent schema, get the parent data and use the schema id from that 
	if(curParentSetId NEQ 0){
		loop from="1" to="25" index="i"{
			db.sql="select s1.*, s2.feature_data_title, s2.feature_data_id d2, s2.feature_data_parent_id d3 
			from #db.table("feature_schema", request.zos.zcoreDatasource)# s1, 
			#db.table("feature_data", request.zos.zcoreDatasource)# s2
			where  
			s1.feature_schema_deleted = #db.param(0)# and 
			s2.feature_data_master_set_id = #db.param(0)# and 
			s2.feature_data_deleted = #db.param(0)# and 
			s1.feature_id=#db.param(form.feature_id)# and 
			s2.site_id=#db.param(request.zos.globals.id)# and 
			s1.feature_schema_id=s2.feature_schema_id and 
			s2.feature_data_id=#db.param(curParentSetId)# 
			LIMIT #db.param(0)#,#db.param(1)#";
			//and s1.feature_schema_id = #db.param(curParentId)# 
			q12=db.execute("q12");
			ignoreNextLink=false;
			loop query="q12"{
				manageAction="manageSchema";
				if(form.method EQ "userManageSchema"){
					manageAction="userManageSchema";
				}
				if(not arguments.linkCurrentPage and curSchemaID EQ arguments.feature_schema_id){
					out=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(q12.feature_data_title), 70)&' /';
				}else{ 
					out='<a href="/z/feature/admin/features/#manageAction#?feature_id=#q12.feature_id#&feature_schema_id=#curSchemaId#&amp;feature_data_parent_id=#q12.d2#">#application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(q12.feature_data_title), 70)#</a> /';
				}
				curSchemaId=q12.feature_schema_id;
				curParentId=q12.feature_schema_parent_id;
				curParentSetId=q12.d3;
				if(q12.feature_schema_enable_merge_interface EQ 1){ 
					ignoreNextLink=true;
				}else{
					arrayappend(arrParent, out);
				}

				// TODO: if merge interface enabled, i must ignore the immediate child record from being
				if(q12.feature_schema_parent_id EQ 0){
					out='<a href="/z/feature/admin/features/#manageAction#?feature_id=#q12.feature_id#&feature_schema_id=#q12.feature_schema_id#&amp;feature_data_parent_id=#q12.d3#">#application.zcore.functions.zFirstLetterCaps(q12.feature_schema_display_name)#</a> / ';
					arrayappend(arrParent, out);

				}
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




<cffunction name="featureSchemaSetCountFromDatabaseBySearch" access="public" returntype="numeric" localmode="modern">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	ts=arguments.searchStruct;
	if(not structkeyexists(ts, 'arrSchemaName')){
		throw("arguments.searchStruct.arrSchemaName is required. It must be an array of feature_schema_variable_name values.");
	}
	db=request.zos.queryObject;//  SEPARATOR #db.param("','")#) idlist
	 db.sql="SELECT count(feature_data_id) count FROM 
	 #db.table("feature_data", request.zos.zcoreDatasource)# s1
	WHERE s1.feature_data_deleted = #db.param(0)# and ";
	var groupId=getSchemaIdWithNameArray(getFeatureIdByName(ts.featureVariableName), ts.arrSchemaName, arguments.site_id);
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
 
<cffunction name="featureSchemaSetFromDatabaseBySetId" access="public" returntype="struct" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="groupId" type="string" required="yes">
	<cfargument name="setId" type="string" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="showUnapproved" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	fsd=application.zcore.featureData; 
	 db.sql="SELECT * FROM 
	 #db.table("feature_data", request.zos.zcoreDatasource)# s1 FORCE INDEX(`PRIMARY`)
	WHERE s1.site_id = #db.param(arguments.site_id)# and 
	s1.feature_data_deleted = #db.param(0)# and 
	s1.feature_id=#db.param(arguments.feature_id)# and 
	feature_data_master_set_id = #db.param(0)# and 
	s1.feature_schema_id=#db.param(arguments.groupId)# and ";
	if(not arguments.showUnapproved){
		db.sql&=" s1.feature_data_approved=#db.param(1)# and ";
	}
	db.sql&=" s1.feature_data_id = #db.param(arguments.setId)# 
	";
	schemaStruct=fsd.featureSchemaData[arguments.feature_id].featureSchemaLookup[arguments.groupId];
	if(schemaStruct.feature_schema_enable_sorting EQ 1){
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


<cffunction name="featureSchemaSetFromDatabaseBySortedArray" access="public" returntype="array" localmode="modern">
	<cfargument name="arrSetId" type="array" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	for(i=1;i LTE arraylen(arguments.arrSetId);i++){
		arguments.arrSetId[i]=application.zcore.functions.zescape(arguments.arrSetId[i]);
	} 
	idList="'"&arrayToList(arguments.arrSetId, "','")&"'";
	throw("this is not supported");
	 db.sql="SELECT * FROM 
	 #db.table("feature_data", request.zos.zcoreDatasource)# s1
	WHERE s1.site_id = #db.param(arguments.site_id)# and 
	s1.feature_data_deleted = #db.param(0)# and 
	feature_data_master_set_id = #db.param(0)# and 
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
			curStruct=buildSchemaSetId(row, false);
			lastSetId=row.feature_data_id;
		}
		buildSchemaSetIdField(row, curStruct);
		
	}
	arrayAppend(arrRow, curStruct);
	return arrRow;
	</cfscript>
</cffunction>

<cffunction name="featureSchemaSetFromDatabaseBySchemaId" access="public" localmode="modern">
	<cfargument name="feature_id" type="numeric" required="yes">
	<cfargument name="schemaId" type="string" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="parentStruct" type="struct" required="no" default="#{__schemaId=0,__setId=0}#">
	<cfargument name="fieldList" type="string" required="no" default="">
	<cfscript>
	db=request.zos.noVerifyQueryObject;
	defaultStruct={};
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id]; 
	schemaStruct=fsd.featureSchemaLookup[arguments.schemaId];
	 db.sql="SELECT * FROM 
	 #db.table("feature_data", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(arguments.site_id)# and 
	feature_data_deleted = #db.param(0)# and 
	feature_id = #db.param(arguments.feature_id)# and 
	feature_data_parent_id = #db.param(arguments.parentStruct.__setId)# and 
	feature_data_approved=#db.param(1)# and 
	feature_data_master_set_id = #db.param(0)# and 
	feature_schema_id = #db.param(arguments.schemaId)#";
	if(schemaStruct.feature_schema_enable_sorting EQ 1){
		db.sql&=" ORDER BY feature_data_sort asc ";
	}else{
		db.sql&=" ORDER BY feature_data_id asc ";
	}
	qS=db.execute("qS", "", 10000, "query", false); 
	arrRow=[];
	if(qS.recordcount EQ 0){
		return arrRow;
	}
	lastSetId=0;
	fieldLookup=fsd.featureSchemaFieldLookup[arguments.schemaId]; 
	for(row in qS){
		dataFields=parseFieldData(row);
		curStruct=buildSchemaSetId(row, false);
		for(field in fieldLookup){
			fieldTemp=fsd.fieldLookup[field];
			if(dataFields[fieldTemp.name] NEQ ""){
				curStruct[fieldTemp.name]=buildSchemaSetIdField(dataFields[fieldTemp.name], field, fieldTemp);
			}
		}
		arrayAppend(arrRow, curStruct);
	}
	return arrRow;
	</cfscript>
</cffunction>
	


<cffunction name="buildSchemaSetIdField" access="private" localmode="modern">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="fieldId" type="string" required="yes"> 
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfscript>
	typeId=arguments.fieldStruct.type;
	if(typeId EQ 2){
		return '<div class="zEditorHTML">'&arguments.value&'</div>';
	}else if(typeId EQ 3 or typeId EQ 9){
		if(arguments.value NEQ "" and arguments.value NEQ "0"){
			if(structkeyexists(arguments.fieldStruct.typeStruct, 'file_securepath') and arguments.fieldStruct.typeStruct['file_securepath'] EQ "Yes"){
				return "/zuploadsecure/feature-options/"&arguments.value;
			}else{
				return "/zupload/feature-options/"&arguments.value;
			}
		}
	}
	return arguments.value;
	</cfscript>
</cffunction>

<cffunction name="buildSchemaSetId" access="private" localmode="modern">
	<cfargument name="row" type="struct" required="yes"> 
	<cfargument name="disableDefaults" type="boolean" required="yes">
	<cfscript>
	row=arguments.row;  
	fsd=application.zcore.featureData.featureSchemaData[row.feature_id]; 
	ts=structnew();
	ts.__sort=row.feature_data_sort;
	ts.__setId=row.feature_data_id;
	ts.__dateModified=row.feature_data_updated_datetime;
	ts.__schemaId=row.feature_schema_id;
	ts.__level=row.feature_data_level;
	ts.__mergeSchemaId=row.feature_data_merge_schema_id;
	ts.__mergeDataId=row.feature_data_merge_data_id;
	ts.__createdDatetime=row.feature_data_created_datetime;
	ts.__approved=row.feature_data_approved;
	ts.__title=row.feature_data_title;
	ts.__parentID=row.feature_data_parent_id;
	ts.__summary=row.feature_data_summary;
	// build url
	if(row.feature_data_image_library_id NEQ 0){
		ts.__image_library_id=row.feature_data_image_library_id;
	}
	groupStruct=fsd.featureSchemaLookup[row.feature_schema_id];
	if(groupStruct.feature_schema_enable_unique_url EQ 1){
		if(row.feature_data_override_url NEQ ""){
			ts.__url=row.feature_data_override_url;
		}else{
			ts.__url="/#application.zcore.functions.zURLEncode(row.feature_data_title, '-')#-50-#row.feature_data_id#.html";
		}
	}
	if(not arguments.disableDefaults){
		structappend(ts, fsd.featureSchemaDefaults[row.feature_schema_id]);
	}
	return ts;
	</cfscript>
</cffunction>


<cffunction name="setSchemaImportStruct" access="public" localmode="modern">
	<cfargument name="feature_id" type="numeric" required="yes">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<!--- <cfargument name="feature_schema_parent_id" type="numeric" required="yes"> --->
	<cfargument name="feature_data_parent_id" type="numeric" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="importStruct" type="struct" required="yes">
	<cfscript>
	if(not structkeyexists(request.zos, 'featureSchemaImportTable')){
		request.zos["featureSchemaImportTable"]={};
	}
	var schemaId=getSchemaIdWithNameArray(arguments.feature_id, arguments.arrSchemaName, request.zos.globals.id);
	form.feature_data_id=0;
	form.feature_data_parent_id=arguments.feature_data_parent_id;
	form.feature_id=arguments.feature_id;
	form.feature_schema_id=schemaId;//featureSchemaIDByName(arguments.feature_schema_variable_name, arguments.feature_schema_parent_id);

	if(structkeyexists(request.zos["featureSchemaImportTable"], form.feature_schema_id)){
		ts=request.zos["featureSchemaImportTable"][form.feature_schema_id];
	}else{
		db=request.zos.queryObject;
		db.sql="select * from #db.table("feature_field", request.zos.zcoreDatasource)# WHERE 
		feature_schema_id = #db.param(form.feature_schema_id)# and 
		feature_field_type_id <> #db.param(11)# and 
		feature_field_deleted = #db.param(0)# and 
		feature_id=#db.param(form.feature_id)# ";
		qField=db.execute("qField");
		var ts={}; 
		var arroptionId=[];
		for(row in qField){
			arrayAppend(arroptionId, row.feature_field_id);
			ts[row.feature_field_variable_name]=row.feature_field_id;
		} 
		ts.feature_field_id=arrayToList(arroptionId, ",");
		request.zos["featureSchemaImportTable"][form.feature_schema_id]=ts;
	}
	arguments.importStruct.feature_field_id=ts.feature_field_id;
	for(i in arguments.dataStruct){
		if(structkeyexists(ts, i)){
			arguments.importStruct['newvalue'&ts[i]]=arguments.dataStruct[i];
		}
	}
	</cfscript>
</cffunction>



 
<cffunction name="getSiteMap" localmode="modern" access="public">
	<cfargument name="arrURL" type="array" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	var i=0;
	db.sql="select * from 
	(#db.table("feature", request.zos.zcoreDatasource)#, 
	#db.table("feature_x_site", request.zos.zcoreDatasource)#, 
	#db.table("feature_schema", request.zos.zcoreDatasource)#, 
	#db.table("feature_field", request.zos.zcoreDatasource)#)
	where 
	feature_x_site.site_id=#db.param(request.zos.globals.id)# and 
	feature_x_site.feature_id=feature.feature_id and 
	feature_x_site_deleted=#db.param(0)# and 
	feature.feature_id = feature_schema.feature_id and 
	feature.feature_deleted=#db.param(0)# and 
	feature_schema.feature_schema_id = feature_field.feature_schema_id and 
	feature_field_deleted=#db.param(0)# and 
	feature_schema_deleted = #db.param(0)# and 
	feature_schema_parent_id = #db.param('0')# and 
	feature_schema_disable_site_map = #db.param(0)# and 
	feature_schema.feature_schema_enable_unique_url = #db.param(1)# 
	GROUP BY feature_schema.feature_schema_id";
	qSchema=db.execute("qSchema");
	for(row in qSchema){ 
		arr1=getFeatureSchemaArray(row.feature_variable_name, row.feature_schema_variable_name, row.site_id, {__mergeSchemaId:0,__mergeDataId:0,__schemaId:0,__setId:0}, row.feature_field_variable_name);
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
	#db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema, 
	#db.table("feature_x_site", request.zos.zcoreDatasource)# WHERE 
	feature_x_site.site_id <> #db.param(-1)# and 
	feature_x_site_deleted=#db.param(0)# and 
	feature_x_site.feature_id=feature_schema.feature_id and 
	feature_schema_deleted = #db.param(0)# 
	ORDER BY feature_schema_parent_id";
	qSchema=db.execute("qSchema");
	schemaStruct={};
	for(row in qSchema){
		if(not structkeyexists(schemaStruct, row.site_id)){
			schemaStruct[row.site_id]={};
		}
		schemaStruct[row.site_id][row.feature_schema_id]={
			parentId:row.feature_schema_parent_id,
			name:row.feature_schema_variable_name
		};
	}
	while(true){
		db.sql="select feature_data.feature_id, feature_data_id, feature_schema.feature_schema_parent_id, site.site_id, feature_schema.feature_schema_variable_name FROM
		#db.table("site", request.zos.zcoreDatasource)# site, 
		#db.table("feature_data", request.zos.zcoreDatasource)# feature_data,
		#db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema
		where 
		site_deleted = #db.param(0)# and 
		feature_data_master_set_id = #db.param(0)# and 
		feature_data_deleted = #db.param(0)# and 
		feature_schema_deleted = #db.param(0)# and 
		feature_schema.feature_schema_id = feature_data.feature_schema_id and 
		feature_data.site_id = site.site_id and  
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
					tempStruct=schemaStruct[row.site_id][parentId];
					parentId=tempStruct.parentId;
					arrayAppend(arrSchema, tempStruct.name);
				}
				arrayAppend(arrSchema, row.feature_schema_variable_name);
				indexSchemaRow(row.feature_id, row.feature_data_id, row.site_id, arrSchema); 
			}
		}
	}
	db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
	site_id <> #db.param(-1)# and 
	app_id = #db.param(21)# and 
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
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id =#db.param(arguments.site_id)# and 
	app_id = #db.param(21)# and 
	search_deleted = #db.param(0)# and 
	search_table_id = #db.param(arguments.setId)# ";
	db.execute("qDelete");

	if(structkeyexists(application.siteStruct[request.zos.globals.id].globals, 'featureSchemaData') and structkeyexists(application.siteStruct[request.zos.globals.id].globals.featureSchemaData, 'featureSchemaSetQueryCache')){
		structdelete(application.siteStruct[request.zos.globals.id].globals.featureSchemaData.featureSchemaSetQueryCache, arguments.setId);
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
	db.sql="UPDATE #db.table("feature_data", request.zos.zcoreDatasource)# 
	SET 
	feature_data_approved=#db.param(approved)#,
	feature_data_updated_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE site_id =#db.param(arguments.site_id)# and 
	feature_data_deleted = #db.param(0)# and 
	feature_data_id = #db.param(arguments.setId)# ";
	db.execute("qUpdate");
	db.sql="select feature_schema_id, feature_data_image_library_id from #db.table("feature_data", request.zos.zcoreDatasource)# 
	WHERE site_id =#db.param(arguments.site_id)# and 
	feature_data_deleted = #db.param(0)# and 
	feature_data_id = #db.param(arguments.setId)# ";
	qSet=db.execute("qSet");
	if(qSet.recordcount){
		schemaId=qSet.feature_schema_id;
		if(qSet.feature_data_image_library_id NEQ 0){
			application.zcore.imageLibraryCom.unapproveLibraryId(qSet.feature_data_image_library_id);
		}
		typeStruct=getTypeData(arguments.site_id);
		t9=getSiteData(arguments.site_id);
		var schemaStruct=typeStruct.featureSchemaLookup[schemaId]; 

		deleteSchemaSetIndex(qSet.feature_data, qSet.site_id);

		if(request.zos.enableSiteOptionGroupCache and schemaStruct.feature_schema_enable_cache EQ 1 and structkeyexists(t9.featureSchemaSet, arguments.setId)){
			schemaStruct=t9.featureSchemaSet[arguments.setId];
			schemaStruct.__approved=approved;
			application.zcore.functions.zCacheJsonSiteAndUserGroup(arguments.site_id, application.zcore.siteGlobals[arguments.site_id]); 
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
	rs2={
		ts:ts,
		arrLabel:[],
		arrValue:[],
		arrParent:[]
	};
	delimiter="|";
	if(structkeyexists(ts, "selectmenu_delimiter") and ts.selectmenu_delimiter EQ "|"){
		delimiter=",";
	}
	if(structkeyexists(ts,'selectmenu_groupid') and ts.selectmenu_groupid NEQ ""){
		// get the group from memory cache
		rs=getSortedData(ts.selectmenu_groupid); 
		for(i=1;i<=arraylen(rs.arrOrder);i++){
			cs=rs.arrOrder[i];
			// get the right label / value fields
 			if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
				if(rs.arrLevel[i] > 0){
					indent=ljustify("_", rs.arrLevel[i]*4);
				}else{
					indent="";
				}
 			}else{
 				indent="";
 			}
			arrayAppend(rs2.arrLabel, indent&cs.data[ts.selectmenu_labelfield]);
			arrayAppend(rs2.arrValue, cs.row.feature_data_id); // ts.selectmenu_valuefield
			arrayAppend(rs2.arrParent, cs.row.feature_data_parent_id);
		}
		// use the level
	}
	if(structkeyexists(local, 'qTemp2')){
		rs2.qTemp2=qTemp2;
	}
	return rs2;
	</cfscript>
</cffunction>


<cffunction name="getSortedData" localmode="modern" access="public">
	<cfargument name="feature_schema_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from 
	#db.table("feature_data", request.zos.zcoreDatasource)#
	 WHERE 
	feature_data.feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	feature_data_deleted=#db.param(0)# 
	ORDER BY feature_data_sort ASC ";
	qData=db.execute("qData", "", 10000, "query", false); 
	rs={
		arrOrder:[],
		arrLevel:[]
	}; 
	if(qData.recordcount NEQ 0){
		schemaStruct=application.zcore.featureData.featureSchemaData[qData.feature_id].featureSchemaLookup[arguments.feature_schema_id];
		addChildrenToParentOrder(qData, schemaStruct.feature_schema_parent_field, rs.arrOrder, rs.arrLevel, "", 0);
	}
	return rs;
	</cfscript>
</cffunction>



<cffunction name="parseFieldData" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
 	fsd=application.zcore.featureData.featureSchemaData[row.feature_id];
	fieldLookup=fsd.featureSchemaFieldLookup[row.feature_schema_id]; 
	tempSet=duplicate(fsd.featureSchemaDefaults[row.feature_schema_id]);
	arrField=listToArray(row.feature_data_field_order, chr(13), true);
	arrData=listToArray(row.feature_data_data, chr(13), true);
	for(i=1;i<=arraylen(arrField);i++){
		fieldId=arrField[i];
		if(structkeyexists(fieldLookup, fieldId)){
			tempSet[fsd.fieldLookup[fieldId].name]=arrData[i];
		}
	}
	return tempSet;
	</cfscript>
</cffunction>

<cffunction name="addChildrenToParentOrder" localmode="modern" access="public">
	<cfargument name="optionQuery" type="query" required="yes">
	<cfargument name="parentFieldName" type="string" required="yes">
	<cfargument name="arrOrder" type="array" required="yes">
	<cfargument name="arrLevel" type="array" required="yes">
	<cfargument name="parentId" type="string" required="yes">
	<cfargument name="recursionCount" type="numeric" required="yes">
	<cfscript>
	arguments.recursionCount++;
	if(arguments.recursionCount GT 100){
		throw("Possible infinite recursion detected in parent/child relationships");
	}
	for(row in optionQuery){
		tempSet=parseFieldData(row);
		if(arguments.parentFieldName EQ ""){
			arrayAppend(arrOrder, {row:row, data:tempSet});
			arrayAppend(arrLevel, arguments.recursionCount-1);
		}else if(arguments.parentID EQ tempSet[arguments.parentFieldName]){ 
			arrayAppend(arrOrder, {row:row, data:tempSet});
			arrayAppend(arrLevel, arguments.recursionCount-1);
			addChildrenToParentOrder(optionQuery, arguments.parentFieldName, arrOrder, arrLevel, row.feature_data_id, recursionCount);
		}
	}
	</cfscript>
</cffunction>



<!--- 
// you must have a group by in your query or it may miss rows
ts=structnew();
ts.feature_id_field="rental.rental_feature_id";
ts.count = 1; // how many images to get
application.zcore.featureCom.getImageSQL(ts);
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
	rs.leftJoin="LEFT JOIN `"&request.zos.zcoreDatasource&"`.image ON "&ss.feature_id_field&" = image.feature_id and image_sort <= #db.param(ss.count)# and image.feature_id=#db.param(form.feature_id)#";
	rs.select=", cast(GROUP_CONCAT(image_id ORDER BY image_sort SEPARATOR '\t') as char) imageIdList, 
	cast(GROUP_CONCAT(image_caption ORDER BY image_sort SEPARATOR '\t') as char) imageCaptionList, 
	cast(GROUP_CONCAT(image_file ORDER BY image_sort SEPARATOR '\t') as char) imageFileList, 
	cast(GROUP_CONCAT(image_updated_datetime ORDER BY image_sort SEPARATOR '\t') as char) imageUpdatedDateList";
	return rs;
	</cfscript>
</cffunction>






<!--- 
var ts=application.zcore.functions.zGetEditableSiteSchemaSetById(schemaStruct.__schemaId, schemaStruct.__setId);
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
	var optionsCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.feature.admin.controller.features"); 
	db.sql="SELECT * FROM #db.table("feature_field", request.zos.zcoreDatasource)# feature_field,
	 #db.table("feature_schema", request.zos.zcoreDatasource)# feature_schema 
	 WHERE 
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
		// doesn't work with time/date and other multi-field Feature Field types probably...
		form['newvalue'&row.feature_field_id]=arguments.struct[row.feature_field_variable_name];
	}
	form.feature_field_id=arrayToList(arroption, ','); 
	var rs=optionsCom.internalSchemaUpdate(); 
	return rs;
	</cfscript>
</cffunction>



<cffunction name="deleteSchemaSetRecursively" localmode="modern" access="public" roles="member">
	<cfargument name="feature_data_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="rowData" type="struct" required="no" default="#{}#">
	<cfscript>
	if(arguments.feature_data_id EQ 0){
		// dangerous, this causes an infinite loop.
		throw("There is a feature_data_id that is 0 on this site.  It must be manually deleted from the database to avoid infinite loops and other serious problems.");
	}
	db=request.zos.queryObject;
	if(structcount(arguments.rowData) EQ 0){
		db.sql="SELECT * FROM #db.table("feature_data", request.zos.zcoreDatasource)# 
		WHERE  feature_data_id=#db.param(arguments.feature_data_id)# and  
		feature_data_deleted = #db.param(0)# and 
		site_id=#db.param(arguments.site_id)# and 
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
	if(row.feature_data_override_url NEQ ""){
		structdelete(application.sitestruct[request.zos.globals.id].urlRewriteStruct.uniqueURLStruct, trim(row.feature_data_override_url));
	}
	//writeLogEntry("deleteSchemaSetRecursively set id:"&arguments.feature_data_id);
	db.sql="SELECT * FROM #db.table("feature_data", request.zos.zcoreDatasource)# 
	WHERE  feature_data_parent_id=#db.param(arguments.feature_data_id)# and  
	feature_data_deleted = #db.param(0)# and
	feature_data.site_id=#db.param(arguments.site_id)#  ";
	qSets=db.execute("qSets");
	for(row2 in qSets){
		deleteSchemaSetRecursively(row2.feature_data_id, row2.site_id, {});
	}
	if(row.feature_data_image_library_id NEQ 0){
		//writeLogEntry("deleteImageLibrary id:"&row.feature_data_image_library_id);
		application.zcore.imageLibraryCom.deleteImageLibraryId(row.feature_data_image_library_id);
	}
	// delete versions
	if(row.feature_data_master_set_id EQ 0){
		db.sql="SELECT * FROM #db.table("feature_data", request.zos.zcoreDatasource)# 
		WHERE  feature_data_master_set_id=#db.param(arguments.feature_data_id)# and  
		feature_data_deleted = #db.param(0)# and
		feature_data.site_id=#db.param(arguments.site_id)#  ";
		qVersion=db.execute("qVersion");
		for(row2 in qVersion){
			//writeLogEntry("deleteSchemaSetRecursively version set id:"&row2.feature_data_id);
			deleteSchemaSetRecursively(row2.feature_data_id, row2.site_id);
		}
	}

	db.sql="SELECT * FROM #db.table("feature_field", request.zos.zcoreDatasource)# 
	WHERE  feature_field.feature_schema_id=#db.param(row.feature_schema_id)# and 
	feature_field_deleted = #db.param(0)#";
	qField=db.execute("qField");
	fieldStruct={};
	for(row in qField){
		fieldStruct[row.feature_field_id]={cfc:application.zcore.featureCom.getTypeCFC(row.feature_field_type_id), typeStruct:deserializeJson(row.feature_field_type_json), hasCustomDelete:false, data:row};
		fieldStruct[row.feature_field_id].hasCustomDelete=fieldStruct[row.feature_field_id].cfc.hasCustomDelete();
	}
	db.sql="SELECT * FROM 
	#db.table("feature_data", request.zos.zcoreDatasource)#  
	WHERE  
	feature_data_id=#db.param(arguments.feature_data_id)# and  
	feature_schema_id=#db.param(row.feature_schema_id)# and  
	site_id=#db.param(arguments.site_id)# and 
	feature_data_field_order <> #db.param('')# and 
	feature_data_deleted = #db.param(0)# ";
	qData=db.execute("qData"); 
	for(row in qData){
		arrField=listToArray(row.feature_data_field_order, chr(13), true);
		arrData=listToArray(row.feature_data_data, chr(13), true);
		for(i=1;i<=arrayLen(arrField);i++){
			if(structkeyexists(fieldStruct, arrField[i])){
				field=fieldStruct[arrField[i]];
				if(field.hasCustomDelete){
					field.cfc.onDelete(arrData[i], row.site_id, field.typeStruct);
				}
			}
		}
	}

	//writeLogEntry("deleteSchemaSetIndex version set id:"&arguments.feature_data_id);
	deleteSchemaSetIndex(arguments.feature_data_id, request.zos.globals.id);
	db.sql="DELETE FROM #db.table("feature_data", request.zos.zcoreDatasource)#  
	WHERE  feature_data_id=#db.param(arguments.feature_data_id)# and  
	feature_data_deleted = #db.param(0)# and
	site_id=#db.param(arguments.site_id)# ";
	result =db.execute("result");
	//writeLogEntry("deleted set values for set id:"&arguments.feature_data_id);
	t9=getSiteData(request.zos.globals.id);
	fsd=application.zcore.featureData.featureSchemaData[row.feature_id];
	schemaStruct=fsd.featureSchemaLookup[row.feature_schema_id]; 
	
	// TODO: remove from arrays / memory cache

	if(structkeyexists(schemaStruct, 'feature_schema_change_cfc_path') and schemaStruct.feature_schema_change_cfc_path NEQ ""){
		path=schemaStruct.feature_schema_change_cfc_path;
		if(left(path, 5) EQ "root."){
			path=request.zRootCFCPath&removeChars(path, 1, 5);
		}
		changeCom=application.zcore.functions.zcreateObject("component", path); 
		//writeLogEntry("changeCom callback for set id:"&arguments.feature_data_id);
		changeCom[schemaStruct.feature_schema_change_cfc_delete_method](arguments.feature_data_id);
	}
	</cfscript>
</cffunction>
	

<cffunction name="deleteSchemaRecursively" localmode="modern" access="public" roles="member">
	<cfargument name="feature_schema_id" type="numeric" required="yes">
	<cfargument name="rebuildSiteCache" type="boolean" required="no" default="#true#">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qCheck=db.execute("qCheck", "", 10000, "query", false);
	if(qCheck.feature_schema_preview_image NEQ ""){
		application.zcore.functions.zDeleteFile(request.zos.globals.privateHomeDir&"zupload/feature-options/"&qCheck.feature_schema_preview_image);
	}

	db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)#  
	WHERE  feature_schema_parent_id=#db.param(arguments.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	qSchemas=db.execute("qSchemas", "", 10000, "query", false); 
	for(row in qSchemas){
		deleteSchemaRecursively(row.feature_schema_id, false);	
	}
	db.sql="SELECT * FROM #db.table("feature_field", request.zos.zcoreDatasource)# 
	WHERE  feature_field.feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_field_deleted = #db.param(0)#";
	qField=db.execute("qField");
	fieldStruct={};
	for(row in qField){
		fieldStruct[row.feature_field_id]={cfc:application.zcore.featureCom.getTypeCFC(row.feature_field_type_id), typeStruct:deserializeJson(row.feature_field_type_json), hasCustomDelete:false, data:row};
		fieldStruct[row.feature_field_id].hasCustomDelete=fieldStruct[row.feature_field_id].cfc.hasCustomDelete();
	}
	db.sql="SELECT * FROM 
	#db.table("feature_data", request.zos.zcoreDatasource)#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and
	site_id<>#db.param(-1)# and 
	feature_data_data <> #db.param('')# and 
	feature_data_deleted = #db.param(0)# ";
	qData=db.execute("qData"); 
	for(row in qData){
		if(row.feature_data_image_library_id NEQ 0){
			application.zcore.imageLibraryCom.deleteImageLibraryId(row.feature_data_image_library_id, row.site_id);
		}
		arrField=listToArray(row.feature_data_field_order, chr(13), true);
		arrData=listToArray(row.feature_data_data, chr(13), true);
		for(i=1;i<=arrayLen(arrField);i++){
			if(structkeyexists(fieldStruct, arrField[i])){
				field=fieldStruct[arrField[i]];
				if(field.hasCustomDelete){
					field.cfc.onDelete(arrData[i], row.site_id, field.typeStruct);
				}
			}
		}
	} 


	db.sql="DELETE FROM #db.table("feature_data", request.zos.zcoreDatasource)#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_data_deleted = #db.param(0)# and 
	site_id<>#db.param(-1)# ";
	result =db.execute("result"); 
	db.sql="DELETE FROM #db.table("feature_map", request.zos.zcoreDatasource)#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_map_deleted = #db.param(0)#  ";
	result =db.execute("result");
	db.sql="DELETE FROM #db.table("feature_field", request.zos.zcoreDatasource)#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_field_deleted = #db.param(0)# and
	feature_id=#db.param(form.feature_id)# ";
	result =db.execute("result");
	db.sql="DELETE FROM #db.table("feature_schema", request.zos.zcoreDatasource)#  
	WHERE  feature_schema_id=#db.param(arguments.feature_schema_id)# and 
	feature_schema_deleted = #db.param(0)# and 
	feature_id=#db.param(form.feature_id)# ";
	result =db.execute("result"); 

	</cfscript>
</cffunction>
 
<cffunction name="userDashboardAdmin" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject; 
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# 
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
				db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# 
				WHERE 
				site_id=#db.param(request.zos.globals.id)# and 
				feature_id=#db.param(form.feature_id)# and 
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
	if(application.zcore.user.checkGroupAccess("member")){
		return;
	}
	currentSetId=arguments.feature_data_id;
	first=true;
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
	
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# WHERE 
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
rs=application.zcore.featureCom.deleteNotUpdatedSchemaSet(["groupName"]); 
application.zcore.status.setStatus(request.zsid, rs.deleteCount&" old records deleted");
--->
<cffunction name="deleteNotUpdatedSchemaSet" localmode="modern" access="public" returnType="struct">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfscript>
	groupId=getSchemaIdWithNameArray(arguments.feature_id, arguments.arrSchemaName, request.zos.globals.id);
	db=request.zos.queryObject;
	db.sql="SELECT * FROM 
	#db.table("feature_data", request.zos.zcoreDatasource)# WHERE 
	feature_data_deleted = #db.param(0)# and 
	feature_data_updated_datetime < #db.param(request.zos.mysqlnow)# and 
	feature_schema_id= #db.param(groupId)# and 
	site_id= #db.param(request.zos.globals.id)#";
	qSet=db.execute("qSet"); 
	rs={ success:true, deleteCount:0 };
	for(row in qSet){
		deleteSchemaSetRecursively(row.feature_data_id, row.site_id, row);
		rs.deleteCount++;
	}
	return rs;
	</cfscript>

</cffunction>




<cffunction name="getTypeCFCStruct" returntype="struct" localmode="modern" access="public">
	<cfscript>
	return application.zcore["featureData"].fieldTypeStruct;
	</cfscript>
</cffunction>
	

<cffunction name="getTypeCFC" returntype="struct" localmode="modern" access="public" output="no">
	<cfargument name="typeId" type="string" required="yes" hint="site_id">
	<cfscript>
	return application.zcore["featureData"].fieldTypeStruct[arguments.typeID];
	</cfscript>
</cffunction>

<cffunction name="getSiteData" returntype="struct" localmode="modern" access="public">
	<cfargument name="key" type="string" required="yes" hint="site_id">
	<cfscript>
	if(not structkeyexists(application.siteStruct[arguments.key].globals, "featureSchemaData")){
		featureCacheCom=createObject("component", "zcorerootmapping.mvc.z.feature.admin.controller.feature-cache");
		featureCacheCom.updateSchemaCache();
	}
	return application.siteStruct[arguments.key].globals["featureSchemaData"];
	</cfscript>
</cffunction>

<cffunction name="getTypeData" returntype="struct" localmode="modern" access="public">
	<cfargument name="key" type="string" required="yes" hint="site_id">
	<cfscript>
	//	throw("this is returning components instead of type data, why?");
	return application.zcore.featureData;//.fieldTypeStruct[arguments.key];
	</cfscript>
</cffunction>

<cffunction name="getFieldTypeCFCs" returntype="struct" localmode="modern" access="public">
	<cfscript>
	ts={
		"0": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.textFieldType"),
		"1": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.textareaFieldType"),
		"2": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.htmlEditorFieldType"),
		"3": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.imageFieldType"),
		"4": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.dateTimeFieldType"),
		"5": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.dateFieldType"),
		"6": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.timeFieldType"),
		"7": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.selectMenuFieldType"),
		"8": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.checkboxFieldType"),
		"9": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.fileFieldType"),
		"10": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.emailFieldType"),
		"11": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.htmlSeparatorFieldType"),
		"12": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.hiddenFieldType"),
		"13": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.mapPickerFieldType"),
		"14": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.radioFieldType"),
		"15": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.urlFieldType"),
		"16": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.userPickerFieldType"),
		"17": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.numberFieldType"),
		"18": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.colorFieldType"),
		"19": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.stateFieldType"),
		"20": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.countryFieldType"),
		"21": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.listingSavedSearchFieldType"),
		"22": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.sliderFieldType"),
		"23": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.imageLibraryFieldType"),
		"24": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.stylesetFieldType"),
		"25": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.productFieldType"),
		"26": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.productCategoryFieldType"),
		"27": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.officePickerFieldType"),
		"28": createobject("component", "zcorerootmapping.mvc.z.feature.field-type.fontFieldType")
	};

	return ts;
	</cfscript>
</cffunction>


<cffunction name="getTypeCustomDeleteArray" returntype="array" localmode="modern" access="public">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	ss=arguments.sharedStruct.fieldTypeStruct;
	arrCustomDelete=[];
	for(i in ss){
		if(ss[i].hasCustomDelete()){
			arrayAppend(arrCustomDelete, i);
		}
	}
	return arrCustomDelete;
	</cfscript>
</cffunction>

<cffunction name="processSearchSchemaSQL" access="private" output="no" returntype="string" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="field" type="string" required="yes">
	<cfargument name="multipleValues" type="boolean" required="yes">
	<cfargument name="delimiter" type="string" required="yes">
	<cfargument name="concatAppendPrepend" type="string" required="yes">
	<cfscript>
	arrValue=arguments.struct.arrValue;
	length=arrayLen(arrValue);
	type=arguments.struct.type;
	match=true;
	arrSQL=[];
	field=arguments.field;
	if(arguments.concatAppendPrepend NEQ ""){
		arguments.concatAppendPrepend=application.zcore.functions.zescape(arguments.concatAppendPrepend);
		field="concat('#arguments.concatAppendPrepend#', #field#, '#arguments.concatAppendPrepend#')";
	}
	multipleError="arguments.multipleValues EQ true isn't supported by processSearchSchemaSQL.  Only non-sql in-memory searches can have multiple values.";
	if(type EQ "="){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]=arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend;
					arrayAppend(arrSQL2, field&" = '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" = '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "<>"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]=arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend;
					arrayAppend(arrSQL2, field&" <> '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " and ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" <> '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "between"){
		if(arguments.multipleValues){
			throw(multipleError);
		}
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		arrayAppend(arrSQL, field&" BETWEEN '"&application.zcore.functions.zescape(arrValue[1])&"' and '"&application.zcore.functions.zescape(arrValue[2])&"' ");
	}else if(type EQ "not between"){
		if(arguments.multipleValues){
			throw(multipleError);
		}
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		arrayAppend(arrSQL, field&" NOT BETWEEN '"&application.zcore.functions.zescape(arrValue[1])&"' and '"&application.zcore.functions.zescape(arrValue[2])&"' ");
	}else if(type EQ ">"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" > '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" > '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ ">="){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" >= '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" >= '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "<"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" = '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " < "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" < '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "<="){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" <= '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" <= '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "like"){
		for(g=1;g LTE length;g++){ 
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]='%'&arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend&'%';
					arrayAppend(arrSQL2, field&" LIKE '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" LIKE '%"&application.zcore.functions.zescape(arrValue[g])&"%' ");
			}
		}
	}else if(type EQ "not like"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]='%'&arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend&'%';
					arrayAppend(arrSQL2, field&" = '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " and ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" NOT LIKE '%"&application.zcore.functions.zescape(arrValue[g])&"%' ");
			}
		}
	}else{
		throw("Invalid field type, ""#type#"".  Valid types are =, <>, <, <=, >, >=, between, not between, like, not like");
	}
	return " ( "&arrayToList(arrSQL, " or ")&" ) ";
	</cfscript>
</cffunction>


<cffunction name="processSearchSchema" access="private" output="no" returntype="boolean" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="multipleValues" type="boolean" required="yes">
	<cfargument name="delimiter" type="string" required="yes">
	<cfscript>
	arrValue=arguments.struct.arrValue;
	length=arrayLen(arrValue);
	type=arguments.struct.type;
	field=arguments.struct.field;
	if(structkeyexists(arguments.struct, 'delimiter')){
		arguments.delimiter=arguments.struct.delimiter;
	}
	row=arguments.row;
	match=true;
	
	if(arguments.multipleValues){
		arrRowValues=listToArray(row[field], arguments.delimiter);
	}else{
		arrRowValues=[row[field]];
	}
	rowLength=arrayLen(arrRowValues);
	
	if(type EQ "="){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrValue[g] EQ arrRowValues[n]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "<>"){
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrValue[g] EQ arrRowValues[n]){
					match=false;
					break;
				}
			}
		}
	}else if(type EQ "between"){
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		match=false;
		for(n=1;n LTE rowLength;n++){
			if(arrRowValues[n] GTE arrValue[1]  and arrRowValues[n] LTE arrValue[2]){
				match=true; 
				break;
			}
		}
	}else if(type EQ "not between"){
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		match=false;
		for(n=1;n LTE rowLength;n++){
			if(arrRowValues[n] LT arrValue[1] or arrRowValues[n] GT arrValue[2]){
				match=true; 
			}
		}
	}else if(type EQ ">"){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] GT arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ ">="){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] GTE arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "<"){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] LT arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "<="){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] LTE arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "like"){
		match=false;
		for(g=1;g LTE length;g++){ 
			for(n=1;n LTE rowLength;n++){
				if(refindnocase(replace('%'&application.zcore.functions.zCleanSearchText(arrValue[g])&'%', "%", ".*", "all"), arrRowValues[n]) NEQ 0){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "not like"){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(refindnocase(replace('%'&application.zcore.functions.zCleanSearchText(arrValue[g])&'%', "%", ".*", "all"), arrRowValues[n]) EQ 0){
					match=true;
					break;
				}
			}
		}
	}else{
		throw("Invalid field type, ""#type#"".  Valid types are =, <>, <, <=, >, >=, between, not between, like, not like");
	}
	return match;
	</cfscript>
</cffunction>

<!--- 
used to do search for a list of values
 --->
<cffunction name="getSearchListAsArray" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="true">
	<cfargument name="valueList" type="string" required="true">
	<cfargument name="compareOperator" type="string" required="true" hint="Valid values are BETWEEN, =, !=, <, <=, >, >=, LIKE, NOT LIKE">
	<cfargument name="groupOperator" type="string" required="true" hint="Valid values are AND or OR">
	<cfargument name="valueListDelimiter" type="string" required="no" default=",">
	<cfargument name="valueListSubDelimiter" type="string" required="no" default="">
	<cfscript>
	arrValue=listToArray(arguments.valueList, arguments.valueListDelimiter, false);
	count=arrayLen(arrValue);
	arrSearch=[];
	for(i=1;i LTE count;i++){
		t9={
			type=arguments.compareOperator,
			field: arguments.fieldName
		}
		if(arguments.valueListSubDelimiter NEQ ""){
			t9.arrValue=listToArray(arrValue[i], arguments.valueListSubDelimiter);
			if(arguments.compareOperator EQ "BETWEEN" and arrayLen(t9.arrValue) NEQ 2){
				t9.type="<>";
				t9.field=arguments.fieldName;
				t9.arrValue=["~~-1~~"];
			}
		}else{
			t9.arrValue=[arrValue[i]];
		}
		arrayAppend(arrSearch, t9);
		if(i NEQ count){
			arrayAppend(arrSearch, arguments.groupOperator);
		}
	}
	return arrSearch;
	</cfscript>
</cffunction>


<cffunction name="rebuildParentStructData" localmode="modern" access="private">
	<cfargument name="parentStruct" type="struct" required="yes">
	<cfargument name="arrLabel" type="array" required="yes">
	<cfargument name="arrValue" type="array" required="yes">
	<cfargument name="arrCurrent" type="array" required="yes">
	<cfargument name="arrParent" type="array" required="yes">
	<cfargument name="level" type="numeric" required="yes">
	<cfscript>
	if(arguments.level GT 50){ 
		throw("Possible infinite recursion.  Throwing error to prevent stackoverflow.");
	}
	for(local.f=1;local.f LTE arraylen(arguments.arrCurrent);local.f++){
		if(arguments.level NEQ 0){
			local.pad=replace(ljustify(" ", arguments.level*3), " ", "_", "ALL");
		}else{
			local.pad="";
		}
		arrayappend(arguments.arrLabel, local.pad&arguments.arrCurrent[local.f].label);
		if(structkeyexists(arguments.arrCurrent[local.f], 'idChild')){
			arrayappend(arguments.arrValue, arguments.arrCurrent[local.f].idChild);
		}else{
			arrayappend(arguments.arrValue, arguments.arrCurrent[local.f].id);
		}
		arrayAppend(arguments.arrParent, arguments.arrCurrent[local.f].parentId);
		//writeoutput( arguments.arrCurrent[local.f].id&" | "& arguments.arrCurrent[local.f].label);
		if(structkeyexists(arguments.parentStruct, arguments.arrCurrent[local.f].id) and arguments.arrCurrent[local.f].id NEQ 0){ 
			variables.rebuildParentStructData(arguments.parentStruct, arguments.arrLabel, arguments.arrValue, arguments.parentStruct[arguments.arrCurrent[local.f].id], arguments.arrParent, arguments.level+1);
		}
	}
	</cfscript>
</cffunction>


<cffunction name="processSearchArraySQL" access="private" output="no" returntype="string" localmode="modern">
	<cfargument name="arrSearch" type="array" required="yes"> 
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfargument name="tableCount" type="numeric" required="yes"> 
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript> 
	length=arraylen(arguments.arrSearch);
	lastMatch=true;
	arrSQL=[' ( '];
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id];
	t9=getSiteData(request.zos.globals.id);
	for(i=1;i LTE length;i++){
		c=arguments.arrSearch[i]; 
		if(isArray(c)){
			sql=this.processSearchArraySQL(c, arguments.fieldStruct, arguments.tableCount, arguments.option_group_id);
			arrayAppend(arrSQL, sql); 
		}else if(isStruct(c)){
			if(structkeyexists(c, 'subSchema')){
				throw("subSchema, ""#c.subSchema#"", has caching disabled. subSchema search is not supported yet when caching is disabled (i.e. option_group_enable_cache = 0).");
			}else{
				optionId=fsd.fieldIdLookup[arguments.option_group_id&chr(9)&c.field];
				if(not structkeyexists(arguments.fieldStruct, optionId)){
					arguments.fieldStruct[optionId]=arguments.tableCount;
					arguments.tableCount++;
				} 
				if(application.zcore.functions.zso(fsd.fieldLookup[optionId].typeStruct,'selectmenu_multipleselection', true, 0) EQ 1){
					multipleValues=true;
					if(fsd.fieldLookup[optionId].typeStruct.selectmenu_delimiter EQ "|"){
						delimiter=',';
					}else{
						delimiter='|';
					}
				}else{
					multipleValues=false;
					delimiter='';
				}
				if(structkeyexists(c, 'concatAppendPrepend')){
					concatAppendPrepend=c.concatAppendPrepend;
				}else{
					concatAppendPrepend='';
				}
				tableName="sSchema"&arguments.fieldStruct[optionId];
				field='sVal'&optionId;
				currentCFC=getTypeCFC(fsd.fieldLookup[optionId].type);
				fieldName=currentCFC.getSearchFieldName('s1', tableName, fsd.fieldLookup[optionId].typeStruct);
				arrayAppend(arrSQL, processSearchSchemaSQL(c, fieldName, multipleValues, delimiter, concatAppendPrepend));// "`"&tableName&"`.`"&field&"`"));
				if(i NEQ length and not isSimpleValue(arguments.arrSearch[i+1])){
					arrayAppend(arrSQL, ' and ');
				}
			}
		}else if(c EQ "OR"){
			if(i EQ 1 or i EQ length){
				throw("""OR"" must be between an array or struct, not at the beginning or end or the array.");
			}
			arrayAppend(arrSQL, 'or');
		}else if(c EQ "AND"){
			if(i EQ 1 or i EQ length){
				throw("""AND"" must be between an array or struct, not at the beginning or end or the array.");
			}
			arrayAppend(arrSQL, 'and');
		}else{
			savecontent variable="output"{
				writedump(c);
			}
			throw("Invalid data type.  Dump of object:"&c);
		}
	}
	if(arrayLen(arrSQL) EQ 1){
		arrayAppend(arrSQL, "1=1");
	}
	arrayAppend(arrSQL, ' ) ');
	return arrayToList(arrSQL, " ");
	</cfscript>
</cffunction>


<cffunction name="processSearchArray" access="private" output="yes" returntype="boolean" localmode="modern">
	<cfargument name="arrSearch" type="array" required="yes">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript>
	row=arguments.row;
	length=arraylen(arguments.arrSearch);
	lastMatch=true;
	if(length EQ 0){
		return true;
	}
	debugOn=false;
	typeStruct=getTypeData(request.zos.globals.id); 
	for(i=1;i LTE length;i++){
		c=arguments.arrSearch[i]; 
		if(debugOn){ echo('<hr>');	writedump(c);	}
		if(isArray(c)){
			if(debugOn){
				echo("before processSearchArray<br>");
			}
			lastMatch=processSearchArray(application.zcore.featureCom.getFeatureNameById(c.feature_id), c, row, arguments.option_group_id); 
			if(debugOn){
				echo("processSearchArray lastMatch:"&lastMatch&"<br>");
			}
		}else if(isStruct(c)){
			if(i NEQ 1 and not isSimpleValue(arguments.arrSearch[i])){
				if(not lastMatch){
					// the entire group must be valid or we return false.
					if(debugOn){
						echo("continue prevented struct matching from running<br>");
					}
					continue;
				}
			}
			if(structkeyexists(c, 'subSchema')){
				if(debugOn){ echo('in subgroup<br>');	}
				arrChild=getFeatureSchemaArray(application.zcore.featureCom.getFeatureNameById(c.subSchema.feature_id), c.subSchema, request.zos.globals.id, row);
				lastMatch=false;
				if(arrayLen(arrChild)){
					//writedump(arrChild); 
					optionId=typeStruct.fieldIdLookup[arrChild[1].__schemaId&chr(9)&c.field];
					if(application.zcore.functions.zso(typeStruct.fieldLookup[optionId].typeStruct,'selectmenu_multipleselection', true, 0) EQ 1){
						multipleValues=true;
						if(typeStruct.fieldLookup[optionId].typeStruct.selectmenu_delimiter EQ "|"){
							delimiter=',';
						}else{
							delimiter='|';
						}
					}else{
						multipleValues=false;
						delimiter='';
					}
					for(n=1;n LTE arrayLen(arrChild);n++){
						c2=arrChild[n]; 
						if(debugOn){ /* writedump(c); writedump(c2); */ 	}
						lastMatch=this.processSearchSchema(c, c2, multipleValues, delimiter); 
						if(lastMatch){
							// always return true if at least one child group matches. I.e. If a product has a "color" sub-group.  User searches for "red", then the product would be valid even if it has other options like "blue".
							break;
						}
					}
					/*writedump(lastMatch);					writedump(row);					writedump(childSchemaStruct);					abort;*/
				}
				if(debugOn){
					echo("child lastMatch:"&lastMatch&"<br>");
				}
			}else{ 
				optionId=typeStruct.fieldIdLookup[arguments.option_group_id&chr(9)&c.field];
				if(application.zcore.functions.zso(typeStruct.fieldLookup[optionId].typeStruct,'selectmenu_multipleselection', true, 0) EQ 1){
					multipleValues=true;
					if(typeStruct.fieldLookup[optionId].typeStruct.selectmenu_delimiter EQ "|"){
						delimiter=',';
					}else{
						delimiter='|';
					}
				}else{
					multipleValues=false;
					delimiter='';
				}
				
				if(debugOn){
					echo("before processSearchSchema:<br />");
				}
				lastMatch=this.processSearchSchema(c, row, multipleValues, delimiter); 
				if(debugOn){
					echo("processSearchSchema lastMatch:"&lastMatch&"<br>");
				}
			}
		}else if(c EQ "OR"){
			if(debugOn){
				echo("OR<br />");
			}
			if(i EQ 1 or i EQ length){
				throw("""OR"" must be between an array or struct, not at the beginning or end or the array.");
			}
			if(lastMatch){
				if(debugOn){
					echo("returning in OR<br />");
				}
				return true;
			}
			lastMatch=true;
		}else if(c EQ "AND"){
			if(debugOn){
				echo("AND<br />");
			}
			if(i EQ 1 or i EQ length){
				throw("""AND"" must be between an array or struct, not at the beginning or end or the array.");
			}
			if(not lastMatch){
				if(debugOn){
					echo("returning in AND<br />");
				}
				return false;
			}
		}else{
			savecontent variable="output"{
				writedump(c);
			}
			throw("Invalid data type.  Dump of object:"&c);
		}
	}
	if(debugOn){
		echo('final lastMatch:'&lastMatch&'<hr />');
		//abort;
	}
	return lastMatch;
	</cfscript>
</cffunction>

<cffunction name="getSchemaById" access="public" returntype="struct" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript>
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id];
	if(structkeyexists(fsd.featureSchemaLookup, arguments.option_group_id)){
		return fsd.featureSchemaLookup[arguments.option_group_id];
	}else{
		return {};
	}
	</cfscript>
</cffunction>


<cffunction name="getFeatureDomain" access="public" returntype="string" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
	<cfscript>
	if(structkeyexists(application.zcore.featureData.featureDataLookup, arguments.feature_id)){
		if(request.zos.isTestServer){
			return application.zcore.featureData.featureDataLookup[arguments.feature_id].feature_test_domain;
		}else{
			return application.zcore.featureData.featureDataLookup[arguments.feature_id].feature_live_domain;
		}
	}else{
		throw("Invalid feature_id, #arguments.feature_id#");
	}
	</cfscript>
</cffunction>

<cffunction name="getSchemaNameById" access="public" returntype="string" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript>
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id];
	if(structkeyexists(fsd.featureSchemaLookup, arguments.option_group_id)){
		return fsd.featureSchemaLookup[arguments.option_group_id]["feature_schema_variable_name"];
	}else{
		return "";
	}
	</cfscript>
</cffunction>

<cffunction name="getFeatureNameById" access="public" returntype="string" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
	<cfscript>
	if(structkeyexists(application.zcore.featureData.featureDataLookup, arguments.feature_id)){
		return application.zcore.featureData.featureDataLookup[arguments.feature_id].feature_variable_name;
	}else{
		throw("Invalid feature_id, #arguments.feature_id#");
	}
	</cfscript>
</cffunction>

<cffunction name="getSchemaNameArrayById" access="public" returntype="array" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript>
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id];
	arrSchemaName=[];
	i=0;
	groupID=arguments.option_group_id;
	while(true){
		i++;
		if(i GT 30){
			throw("Possible infinite loop.  Verify that feature_schema_parent_id is able to reach the root for #arguments.option_group_id#");
		}
		if(structkeyexists(fsd.featureSchemaLookup, groupID)){
			arrayPrepend(arrSchemaName, fsd.featureSchemaLookup[groupID]["feature_schema_variable_name"]);
			groupID=fsd.featureSchemaLookup[groupID]["feature_schema_parent_id"];
			if(groupID EQ 0){
				break;
			}
		}else{
			throw("groupID, ""#groupId#"", doesn't exist.  arguments.option_group_id was #arguments.option_group_id#");
		}
	}
	return arrSchemaName;
	</cfscript>
</cffunction>

<cffunction name="getFieldFieldById" access="public" returntype="struct" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="option_id" type="string" required="yes">
	<cfscript>
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id];
	if(structkeyexists(fsd.fieldLookup, arguments.option_id)){
		return fsd.fieldLookup[arguments.option_id];
	}else{
		return {};
	}
	</cfscript>
</cffunction>

<cffunction name="setIdHiddenField" access="public" returntype="any" localmode="modern">
	<cfscript>
    ts3=structnew();
    ts3.name="feature_data_id";
    application.zcore.functions.zinput_hidden(ts3);
	</cfscript>
</cffunction>
 
<cffunction name="getFieldFieldNameById" access="public" returntype="string" localmode="modern">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="option_id" type="string" required="yes">
	<cfscript>
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id];
	if(structkeyexists(fsd.fieldLookup, arguments.option_id)){
		return fsd.fieldLookup[arguments.option_id]["feature_field_variable_name"];
	}else{
		return "";
	}
	</cfscript>
</cffunction> 

<cffunction name="deleteSchemaSetIdCache" localmode="modern" access="public">
	<cfargument name="feature_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="setId" type="numeric" required="yes"> 
	<cfscript>
	deleteSchemaSetIdCacheInternal(arguments.feature_id, arguments.site_id, arguments.setId, false);
	application.zcore.functions.zCacheJsonSiteAndUserGroup(arguments.site_id, application.zcore.siteGlobals[arguments.site_id]);
	</cfscript>
</cffunction>

<cffunction name="deleteSchemaSetIdCacheInternal" localmode="modern" access="private">
	<cfargument name="feature_id" type="numeric" required="yes">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="setId" type="numeric" required="yes">
	<cfargument name="disableFileUpdate" type="boolean" required="yes">
	<cfscript>
	var row=0;
	var tempValue=0; 
	t9=getSiteData(arguments.site_id);
	var db=request.zos.queryObject; 
	// remove only the keys I need to and then publish  
	if(not structkeyexists(t9.featureSchemaSetId, arguments.setId&"_groupId")){
		return;
	}
	var groupId=t9.featureSchemaSetId[arguments.setId&"_groupId"];
	var parentId=t9.featureSchemaSetId[arguments.setId&"_parentId"]; 
	deleteIndex=0;
	if(structkeyexists(t9.featureSchemaSetId[parentId&"_childSchema"], groupId)){
		var arrChild=t9.featureSchemaSetId[parentId&"_childSchema"][groupId]; 
		for(var i=1;i LTE arrayLen(arrChild);i++){
			if(arguments.setId EQ arrChild[i]){
				deleteIndex=i;
				break;
			}
		}
	}
	var arrChild2=t9.featureSchemaSetArrays[groupId&chr(9)&parentId];
	deleteIndex2=0;
	for(var i=1;i LTE arrayLen(arrChild2);i++){
		if(arguments.setId EQ arrChild2[i].__setId){
			deleteIndex2=i;
		}
	}
	// recursively delete children from shared memory cache
	var childSchema=duplicate(t9.featureSchemaSetId[arguments.setId&"_childSchema"]); 
	for(var f in childSchema){
		for(var g=1;g LTE arraylen(childSchema[f]);g++){ 
			this.deleteSchemaSetIdCacheInternal(arguments.feature_id, arguments.site_id, childSchema[f][g], true);
		}
	}
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id];
	for(var n in fsd.featureSchemaFieldLookup[groupId]){ 
		structdelete(t9.featureSchemaSetId, arguments.setId&"_f"&n);
	}
	if(deleteIndex GT 0){
		arrayDeleteAt(arrChild, deleteIndex);
	}
	if(deleteIndex2 GT 0){
		arrayDeleteAt(arrChild2, deleteIndex2);
	} 
	structdelete(t9.featureSchemaSet, arguments.setId);
	structdelete(t9.featureSchemaSetId, arguments.setId&"_groupId");
	structdelete(t9.featureSchemaSetId, arguments.setId&"_parentId");
	structdelete(t9.featureSchemaSetId, arguments.setId&"_childSchema"); 

	</cfscript>
</cffunction>

<cffunction name="searchReindexSet" localmode="modern" access="public">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="setId" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	indexSchemaRow(arguments.feature_id, arguments.setId, arguments.site_id, arguments.arrSchemaName);
	</cfscript>
</cffunction>


<cffunction name="getStatusName" returntype="string" output="no" localmode="modern">
	<cfargument name="statusId" type="string" required="yes">
	<cfscript>
	if(arguments.statusId EQ 1){
		return 'Approved';
	}else if(arguments.statusId EQ 0){
		return 'Pending';
	}else if(arguments.statusId EQ 2){
		return 'Deactivated By User';
	}else if(arguments.statusId EQ 3){
		return 'Rejected';
	}else{
		throw("Invalid statusId, ""#arguments.statusId#""");
	}
	</cfscript>
</cffunction>


<cffunction name="getChildValues" localmode="modern" returntype="array" access="private">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="currentStruct" type="struct" required="yes">
	<cfargument name="arrChild" type="array" required="yes">
	<cfargument name="level" type="numeric" required="yes">
	<cfscript>
	if(arguments.level GT 25){
		savecontent variable="out"{
			writedump(arguments.arrChild);
			writedump(arguments.currentStruct);
		}
		throw("Possible infinite recursion detected in siteFieldCom.getChildValues()."&out);
	}
	arrayAppend(arguments.arrChild, arguments.currentStruct.id);
	if(structkeyexists(arguments.struct, arguments.currentStruct.id)){
		for(i in arguments.struct[arguments.currentStruct.id]){
			arguments.arrChild=this.getChildValues(arguments.struct, arguments.struct[arguments.currentStruct.id][i], arguments.arrChild, arguments.level+1);
		}
	}
	return arguments.arrChild;
	</cfscript>
</cffunction>



<cffunction name="indexSchemaRow" localmode="modern" access="public">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="setId" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var i=0;
	dataStruct=getSchemaSetById(application.zcore.featureCom.getFeatureNameById(arguments.feature_id), arguments.arrSchemaName, arguments.setId, arguments.site_id); 
	fsd=application.zcore.featureData.featureSchemaData[arguments.feature_id]; 
	if(not structkeyexists(dataStruct, '__approved') or dataStruct.__approved NEQ 1){
		deleteSchemaSetIndex(arguments.setId, arguments.site_id);

		return;
	}
	schemaStruct=fsd.featureSchemaLookup[dataStruct.__schemaId]; 
	if(schemaStruct["feature_schema_search_index_cfc_path"] EQ ""){
		customSearchIndexEnabled=false;
	}else{ 
		customSearchIndexEnabled=true;
		if(left(schemaStruct["feature_schema_search_index_cfc_path"], 5) EQ "root."){  
			local.cfcpath=replace(schemaStruct["feature_schema_search_index_cfc_path"], 'root.',  application.zcore.functions.zGetRootCFCPath(application.zcore.functions.zvar('shortDomain', arguments.site_id)));
		}else{
			local.cfcpath=schemaStruct["feature_schema_search_index_cfc_path"];
		}
	}
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	ds=searchCom.getSearchIndexStruct();
	ds.app_id=21; 
	ds.search_table_id=local.dataStruct.__setId;
	ds.site_id=arguments.site_id;
	ds.search_content_datetime=local.dataStruct.__dateModified;
	ds.search_url=dataStruct.__url;
	ds.search_title=dataStruct.__title;
	ds.search_summary=dataStruct.__summary;


	if(structkeyexists(dataStruct, '__image_library_id') and dataStruct.__image_library_id NEQ 0){
		ts={};
		ts.output=false;
		ts.size="150x120";
		ts.layoutType="";
		ts.image_library_id=dataStruct.__image_library_id;
		ts.forceSize=true;
		ts.crop=0;
		ts.offset=0;
		ts.limit=1; // zero will return all images
		var arrImage=request.zos.imageLibraryCom.displayImages(ts);
		if(arraylen(arrImage)){
			ds.search_image=arrImage[1].link;
		}
	}

	if(customSearchIndexEnabled){
		local.tempCom=application.zcore.functions.zcreateobject("component", local.cfcpath); 
		local.tempCom[schemaStruct["feature_schema_search_index_cfc_method"]](dataStruct, ds);
	}else{
		arrFullText=[dataStruct.__title]; 
		if(structkeyexists(fsd.featureSchemaFieldLookup, dataStruct.__schemaId)){
			for(i in fsd.featureSchemaFieldLookup[dataStruct.__schemaId]){
				c=fsd.fieldLookup[i];
				if(c["feature_field_enable_search_index"] EQ 1){
					arrayAppend(arrFullText, dataStruct[c.name]);
				}
			}
		}
		ds.search_fulltext=arrayToList(arrFullText, " ");
	}
	//writedump(ds);abort;
	searchCom.saveSearchIndex(ds);
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zGetSiteSchemaIdWithNameArray(["SchemaName"]); --->
<cffunction name="getSchemaIdWithNameArray" localmode="modern" output="no" returntype="numeric" hint="returns the group id for the last group in the array.">
	<cfargument name="feature_id" type="string" required="yes">
	<cfargument name="arrSchemaName" type="array" required="yes" hint="An array of feature_schema_variable_name">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	fsd=application.zcore.featureData;
	count=arrayLen(arguments.arrSchemaName);
	if(count EQ 0){
		throw("You must specify one or more group names in arguments.arrSchemaName");
	}
	curSchemaId=0;
	featureSchemaId=0;
	for(i=1;i LTE count;i++){
		featureSchemaId=fsd.featureSchemaData[arguments.feature_id].featureSchemaIdLookup[curSchemaId&chr(9)&arguments.arrSchemaName[i]];
		curSchemaId=featureSchemaId;
	}
	return featureSchemaId;
	</cfscript>
</cffunction>

<cffunction name="featureSchemaById" localmode="modern" output="yes" returntype="struct">
	<cfargument name="option_group_id" type="string" required="no" default="">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	fsd=application.zcore.featureData;
	if(structkeyexists(t9, "featureSchemaLookup") and structkeyexists(fsd.featureSchemaLookup, arguments.option_group_id)){
		return fsd.featureSchemaLookup[arguments.option_group_id];
	}
	return {};
	</cfscript>
</cffunction>

<cffunction name="getFeatureIDByName" localmode="modern" output="yes">
	<cfargument name="featureVariableName" type="string" required="yes">
	<cfscript>
	if(structkeyexists(application.zcore.featureData.featureIdLookup, arguments.featureVariableName)){
		return application.zcore.featureData.featureIdLookup[arguments.featureVariableName];
	}else{
		throw("Feature, ""#arguments.featureVariableName#"", doesn't exist. Remember to use the variable name and not the display name.");
	}
	</cfscript>
</cffunction>
     
<cffunction name="getSchemaSetById" localmode="modern" output="yes" returntype="struct">
	<cfargument name="featureVariableName" type="string" required="yes">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfargument name="feature_data_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfargument name="showUnapproved" type="boolean" required="no" default="#false#"> 
	<cfscript> 
	feature_id=getFeatureIDByName(arguments.featureVariableName);

	typeStruct=application.zcore.featureData;
	t9=getSiteData(arguments.site_id);

	if(arraylen(arguments.arrSchemaName)){
		var groupId=getSchemaIdWithNameArray(feature_id, arguments.arrSchemaName, arguments.site_id);
		var schemaStruct=typeStruct.featureSchemaData[feature_id].featureSchemaLookup[groupId];  
		if(request.zos.enableSiteOptionGroupCache and not arguments.showUnapproved and schemaStruct.feature_schema_enable_cache EQ 1 and structkeyexists(t9.featureSchemaSet, arguments.feature_data_id)){
			schemaStruct=t9.featureSchemaSet[arguments.feature_data_id];
			if(schemaStruct.__schemaId NEQ groupID){
				application.zcore.functions.z404("#arrayToList(arguments.arrSchemaName, ", ")# is not the right group for feature_schema_set_id: #arguments.feature_data_id#");
			} 
			return schemaStruct;
		}else{ 
			if(arguments.feature_data_id EQ ""){
				// don't do a query when the id is missing 
				return {};
			}   
			return featureSchemaSetFromDatabaseBySetId(feature_id, groupId, arguments.feature_data_id, arguments.site_id, arguments.showUnapproved);
		}
	}else{
		if(structkeyexists(t9.featureSchemaSet, arguments.feature_data_id)){
			return t9.featureSchemaSet[arguments.feature_data_id];
		}
	} 
	return {};
	</cfscript>
</cffunction>

<!--- 
// when using the merge interface, we can get the child data directly without having to query all of the child groups for existence using this function
rs=application.zcore.featureCom.getMergeFeatureData("feature", row);
if(rs.success){
	writedump(rs.schema.feature_schema_variable_name);
	writedump(rs.data);
}else{
	throw("Merged data is missing for row ###row.__setId#");
}

 --->
<cffunction name="getMergeFeatureData" localmode="modern" output="yes" returntype="struct">
	<cfargument name="featureVariableName" type="string" required="yes">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfargument name="showUnapproved" type="boolean" required="no" default="#false#"> 
	<cfscript> 
	feature_id=getFeatureIDByName(arguments.featureVariableName);

	typeStruct=application.zcore.featureData;
	t9=getSiteData(arguments.site_id);

	var schemaStruct=typeStruct.featureSchemaData[feature_id].featureSchemaLookup[arguments.struct.__mergeSchemaId];  
	if(request.zos.enableSiteOptionGroupCache and not arguments.showUnapproved and schemaStruct.feature_schema_enable_cache EQ 1 and structkeyexists(t9.featureSchemaSet, arguments.struct.__mergeDataId)){
		schemaSet=t9.featureSchemaSet[arguments.struct.__mergeDataId];
		if(schemaSet.__schemaId NEQ arguments.struct.__mergeSchemaId){
			application.zcore.functions.z404("#arrayToList(arguments.arrSchemaName, ", ")# is not the right group for feature_schema_set_id: #arguments.struct.__mergeDataId#");
		} 
		return {success:true, schema: schemaStruct, data: schemaSet};
	}else{ 
		if(arguments.struct.__mergeDataId EQ "" or arguments.struct.__mergeDataId EQ "0"){
			// don't do a query when the id is missing 
			return {success:false};
		}   
		return {success:true, schema: schemaStruct, data: featureSchemaSetFromDatabaseBySetId(feature_id, arguments.struct.__mergeSchemaId, arguments.struct.__mergeDataId, arguments.site_id, arguments.showUnapproved)};
	}
	return {success:false };
	</cfscript>
</cffunction>

<cffunction name="featureSchemaIdByName" localmode="modern" output="no" returntype="numeric">
	<cfargument name="groupName" type="string" required="yes">
	<cfargument name="feature_schema_parent_id" type="numeric" required="no" default="#0#">
	<cfargument name="site_id" type="numeric" required="no" default="#request.zos.globals.id#">
	<cfscript>
	fsd=application.zcore.featureData;
	if(structkeyexists(fsd, "featureSchemaIdLookup") and structkeyexists(fsd.featureSchemaIdLookup, arguments.feature_schema_parent_id&chr(9)&arguments.groupName)){
		return fsd.featureSchemaIdLookup[arguments.feature_schema_parent_id&chr(9)&arguments.groupName];
	}else{
		throw("arguments.groupName, ""#arguments.groupName#"", doesn't exist");
	}
	</cfscript>
</cffunction>

<cffunction name="getFeatureSchemaArray" localmode="modern" output="yes" returntype="array">
	<cfargument name="featureVariableName" type="string" required="yes">
	<cfargument name="groupName" type="string" required="yes"> 
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfargument name="parentStruct" type="struct" required="no" default="#{__schemaId:0,__setId:0,__mergeSchemaId:0,__mergeDataId:0}#">
	<cfargument name="fieldList" type="string" required="no" default="">
	<cfscript>  
	feature_id=getFeatureIDByName(arguments.featureVariableName);
	fsd=application.zcore.featureData.featureSchemaData[feature_id];
	if(structkeyexists(fsd, 'featureSchemaIdLookup')){
		t9=getSiteData(arguments.site_id);
		// this code didn't help, must be stored correctly and not needing it
		/*if(arguments.parentStruct.__mergeSchemaId NEQ 0){
			if(structkeyexists(fsd.featureSchemaIdLookup, arguments.parentStruct.__mergeSchemaId&chr(9)&arguments.groupName)){
				featureSchemaId=fsd.featureSchemaIdLookup[arguments.parentStruct.__mergeSchemaId&chr(9)&arguments.groupName];
				schemaStruct=fsd.featureSchemaLookup[featureSchemaId];
				if(request.zos.enableSiteOptionGroupCache and schemaStruct["feature_schema_enable_cache"] EQ 1){
					if(structkeyexists(t9.featureSchemaSetArrays, featureSchemaId&chr(9)&arguments.parentStruct.__setId)){
						return t9.featureSchemaSetArrays[featureSchemaId&chr(9)&arguments.parentStruct.__setId]; 
					}
				}else{
					return featureSchemaSetFromDatabaseBySchemaId(feature_id, featureSchemaId, arguments.site_id, arguments.parentStruct, arguments.fieldList);
				}	
			}
		}else*/
		if(structkeyexists(fsd.featureSchemaIdLookup, arguments.parentStruct.__schemaId&chr(9)&arguments.groupName)){
			featureSchemaId=fsd.featureSchemaIdLookup[arguments.parentStruct.__schemaId&chr(9)&arguments.groupName];
			schemaStruct=fsd.featureSchemaLookup[featureSchemaId];
			if(request.zos.enableSiteOptionGroupCache and schemaStruct["feature_schema_enable_cache"] EQ 1){ 
				if(structkeyexists(t9.featureSchemaSetArrays, featureSchemaId&chr(9)&arguments.parentStruct.__setId)){
					return t9.featureSchemaSetArrays[featureSchemaId&chr(9)&arguments.parentStruct.__setId]; 
				}
			}else{
				return featureSchemaSetFromDatabaseBySchemaId(feature_id, featureSchemaId, arguments.site_id, arguments.parentStruct, arguments.fieldList);
			}	
		}
	} 
	return arraynew(1);
	</cfscript>
</cffunction> 


<!---  appendSchemaDefaults(dataStruct, option_group_id); --->
<cffunction name="appendSchemaDefaults" localmode="modern" output="false" returntype="any">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript> 
	fsd=application.zcore.featureData; 
	if(structkeyexists(fsd, 'featureSchemaDefaults') and structkeyexists(fsd.featureSchemaDefaults, arguments.option_group_id)){
		structappend(arguments.dataStruct, fsd.featureSchemaDefaults[arguments.option_group_id], false);
	}
	return arguments.dataStruct;
	</cfscript>
</cffunction>


<!--- 
ts=structnew();
ts.feature_id;
ts.output=true;
ts.query=qImages;
ts.row=currentrow;
ts.size="250x160";
ts.crop=0;
ts.count = 1; // how many images to get
application.zcore.featureCom.displayImageFromSQL(ts);
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
	if(arguments.ss["feature_id"] EQ 0){
		if(arguments.ss.output){
			return;
		}else{
			return arrOutput;
		}
	}
	application.zcore.featureCom.registerSize(arguments.ss["feature_id"], arguments.ss.size, arguments.ss.crop);
	</cfscript>
	<cfif arguments.ss.output>
		<cfloop query="arguments.ss.query" startrow="#arguments.ss.row#" endrow="#arguments.ss.row#">
			<cfscript>arrCaption=listtoarray(arguments.ss.query.imageCaptionList,chr(9),true);
			arrId=listtoarray(arguments.ss.query.imageIdList,chr(9),true);
			arrImageFile=listtoarray(arguments.ss.query.imageFileList,chr(9),true);
			arrImageUpdatedDate=listtoarray(arguments.ss.query.imageUpdatedDateList, chr(9), true);
			</cfscript>
			<cfloop from="1" to="#arguments.ss.count#" index="g2">
				<img src="#application.zcore.featureCom.getImageLink(arguments.ss["feature_id"], arrId[g2], arguments.ss.size, arguments.ss.crop, true, arrCaption[g2], arrImageFile[g2], arrImageUpdatedDate[g2])#" <cfif arrCaption[g2] NEQ "">alt="#htmleditformat(arrCaption[g2])#"</cfif> style="border:none;" />
				<cfif arrCaption[g2] NEQ ""><br /><div style="padding-top:5px;">#arrCaption[g2]#</div></cfif><br /><br />
			</cfloop>
		</cfloop>
	<cfelse>
		<cfloop query="arguments.ss.query" startrow="#arguments.ss.row#" endrow="#arguments.ss.row#">
			<cfscript>
			arrCaption=listtoarray(arguments.ss.query.imageCaptionList,chr(9),true);
			arrId=listtoarray(arguments.ss.query.imageIdList,chr(9),true);
			arrImageFile=listtoarray(arguments.ss.query.imageFileList,chr(9),true);
			arrImageUpdatedDate=listtoarray(arguments.ss.query.imageUpdatedDateList, chr(9), true);
			if(arraylen(arrCaption) EQ 0){ arrayappend(arrCaption,""); }
			if(arraylen(arrId) EQ 0){ arrayappend(arrId,""); }
			if(arraylen(arrImageFile) EQ 0){ arrayappend(arrImageFile,""); }
			if(arraylen(arrImageUpdatedDate) EQ 0){ arrayappend(arrImageUpdatedDate,""); }
			</cfscript>
			<cfloop from="1" to="#arguments.ss.count#" index="g2">
				<cfscript>
				ts=structnew();
				ts.link=application.zcore.featureCom.getImageLink(arguments.ss["feature_id"], arrId[g2], arguments.ss.size, arguments.ss.crop, true, arrCaption[g2], arrImageFile[g2], arrImageUpdatedDate[g2]);
				ts.caption=arrCaption[g2];
				ts.id=arrId[g2];
				arrayappend(arrOutput,ts);
				</cfscript>
			</cfloop>
		</cfloop>
		<cfscript>return arrOutput;</cfscript>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>