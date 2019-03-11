<cfcomponent>
<cfoutput>
<!--- 
need option for "Delete missing fields?"

Maybe a better export format uses groupNameList for all the feature_schema_id and groupNameList+feature_field_variable_name for all the feature_field_id
This allows avoiding remaps more easily.  Less code when importing.
 --->

<cffunction name="getNextFieldId" localmode="modern" returntype="numeric">
	<cfargument name="groupNameList" type="string" required="yes">
	<cfargument name="feature_field_variable_name" type="string" required="yes">
	<cfscript>
	if(not structkeyexists(request.nextFieldStruct, arguments.groupNameList)){
		request.nextFieldStruct[arguments.groupNameList]={};
	}
	if(structkeyexists(request.nextFieldStruct[arguments.groupNameList], arguments.feature_field_variable_name)){
		request.nextFieldStruct[arguments.groupNameList][arguments.feature_field_variable_name];
	}
	request.nextFieldId++;
	request.nextFieldStruct[arguments.groupNameList][arguments.feature_field_variable_name]=request.nextFieldId;
	return request.nextFieldId;
	</cfscript>
</cffunction>

<cffunction name="getNextSchemaId" localmode="modern" returntype="numeric">
	<cfargument name="groupNameList" type="string" required="yes">
	<cfscript>
	if(structkeyexists(request.nextSchemaStruct, arguments.groupNameList)){
		return request.nextSchemaStruct[arguments.groupNameList];
	}
	request.nextSchemaId++;
	request.nextSchemaStruct[arguments.groupNameList]=request.nextSchemaId;
	return request.nextSchemaId;
	</cfscript>
</cffunction>

<cffunction name="getSchemaByName" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="groupNameList" type="string" required="yes">
	<cfargument name="createIfMissing" type="boolean" required="no" default="#false#">
	<cfscript>
	arrSchema=listToArray(arguments.groupNameList, chr(9));
	if(arraylen(arrSchema) EQ 0){
		return {success:false};
	}
	feature_schema_variable_name=arrSchema[arrayLen(arrSchema)];
	if(arraylen(arrSchema) LTE 1 or arguments.groupNameList EQ 0){
		parentId=0;
	}else{
		arrayDeleteAt(arrSchema, arraylen(arrSchema));
		parentStruct=getSchemaByName(arguments.struct, arrayToList(arrSchema, chr(9)), arguments.createIfMissing);
		parentId=parentStruct.struct.feature_schema_id;
	}
	if(structkeyexists(arguments.struct.featureSchemaNameStruct, arguments.groupNameList)){
		groupStruct=arguments.struct.featureSchemaStruct[arguments.struct.featureSchemaNameStruct[arguments.groupNameList]];
		return { success:true, struct:groupStruct };
	}else if(arguments.createIfMissing){
		groupStruct={
			new:true,
			feature_schema_variable_name:feature_schema_variable_name,
			feature_schema_id:getNextSchemaId(arguments.groupNameList),
			feature_schema_parent_id:parentId,
			feature_id:request.zos.globals.id
		};
		return { success:true, struct:groupStruct };
	}else{
		return {success:false};
	}
	</cfscript>
</cffunction>

<cffunction name="getSchemaById" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="feature_schema_id" type="string" required="yes">
	<cfscript>
	if(structkeyexists(arguments.struct.featureSchemaStruct, arguments.feature_schema_id)){
		groupStruct=arguments.struct.featureSchemaStruct[arguments.feature_schema_id];
		return { success:true, struct:groupStruct };
	}else{
		return {success:false};
	}
	</cfscript>
</cffunction>

<cffunction name="getFieldById" localmode="modern" returntype="struct">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="feature_field_id" type="string" required="yes">
	<cfscript>
	if(structkeyexists(arguments.struct.typeStruct, arguments.feature_field_id)){
		typeStruct=arguments.struct.typeStruct[arguments.feature_field_id];
		return { success:true, struct:typeStruct };
	}else{
		return {success:false};
	}
	</cfscript>
</cffunction>

<cffunction name="getFieldByName" localmode="modern" returntype="struct">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="groupNameList" type="string" required="yes">
	<cfargument name="feature_field_variable_name" type="string" required="yes">
	<cfargument name="createIfMissing" type="boolean" required="no" default="#false#">
	<cfscript>
	groupStruct=getSchemaByName(arguments.struct, arguments.groupNameList, arguments.createIfMissing);
	if(not groupStruct.success){
		return {success:false, errorMessage:"couldn't find group: "&arguments.groupNameList&"<br>"};
	}
	if(structkeyexists(arguments.struct.optionNameStruct, arguments.groupNameList) and structkeyexists(arguments.struct.optionNameStruct[arguments.groupNameList], arguments.feature_field_variable_name)){
		typeStruct=arguments.struct.typeStruct[arguments.struct.optionNameStruct[arguments.groupNameList][arguments.feature_field_variable_name]];
		return { success:true, struct:typeStruct };
	}else if(arguments.createIfMissing){
		typeStruct={
			new:true,
			feature_schema_id:groupStruct.struct.feature_schema_id,
			feature_field_id:getNextFieldId(arguments.groupNameList, arguments.feature_field_variable_name),
			feature_id:request.zos.globals.id
		};
		return { success:true, struct:typeStruct };
	}else{
		return {success:false, errorMessage:"feature_field_variable_name, ""#arguments.feature_field_variable_name#"", doesn't exist in group."};
	}
	</cfscript>
</cffunction>

<cffunction name="getFieldDataFromDatabase" access="public" localmode="modern" returntype="struct">
	<cfscript>
	db=request.zos.queryObject;
	ts={
		arrField:[],
		arrSchema:[],
	//	arrSchemaMap:[],
	};
	// setup destination data
	db.sql="select * from #db.table("feature_field", request.zos.zcoreDatasource)# 
	WHERE feature_id = #db.param(form.feature_id)# and 
	feature_field_deleted = #db.param(0)# ";
	qField=db.execute("qField");
	for(row in qField){
		arrayAppend(ts.arrField, row);
	}
	
	db.sql="select * from #db.table("feature_schema", request.zos.zcoreDatasource)# 
	WHERE feature_id = #db.param(form.feature_id)# and
	feature_schema_deleted = #db.param(0)# 
	ORDER BY feature_schema_parent_id ASC ";
	qSchema=db.execute("qSchema");
	for(row in qSchema){
		if(row.feature_schema_user_group_id_list NEQ ""){
			arrSchema=listToArray(row.feature_schema_user_group_id_list, ",");
			groupNameStruct={};
			for(n=1;n LTE arraylen(arrSchema);n++){
				arrayAppend(groupNameStruct, variables.userSchemaCom.getSchemaName(arrSchema[n], request.zos.globals.id)); 
			}
			row.userSchemaNameJSON=serializeJson(groupNameStruct);
		}
		if(row.inquiries_type_id NEQ 0){
			tempSiteId=application.zcore.functions.zGetSiteIdFromSiteIDType(row.inquiries_type_id_siteIDType);
			db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
			WHERE feature_id = #db.param(tempSiteId)# and 
			inquiries_type_deleted = #db.param(0)# and 
			inquiries_type_id = #db.param(row.inquiries_type_id)#";
			qType=db.execute("qType");
			if(qType.recordcount EQ 0){
				throw("inquiries_type_id, ""#row.inquiries_type_id#"", doesn't exist, and it is required for this group to work:  Parent ID: #row.feature_schema_parent_id# Name: #row.feature_schema_variable_name#.");
			}
			row.inquiriesTypeName = qType.inquiries_type_name;
		}
		arrayAppend(ts.arrSchema, row);
	}
	/*
	db.sql="select * from #db.table("feature_map", request.zos.zcoreDatasource)# 
	WHERE feature_id = #db.param(form.feature_id)# and 
	feature_map_deleted = #db.param(0)# ";
	qMap=db.execute("qMap");
	for(row in qMap){
		arrayAppend(ts.arrSchemaMap, row);
	}*/
	return ts;
	</cfscript>
</cffunction>


<cffunction name="getFieldMappedData" access="public" localmode="modern" returntype="struct">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	ts=arguments.dataStruct;
	struct={
		typeStruct:{},
		featureSchemaStruct:{},
		//featureSchemaMapStruct:{},
		optionNameStruct:{},
		featureSchemaNameStruct:{},
		featureSchemaNameLookupById:{}
	};
	for(i=1;i LTE arraylen(ts.arrSchema);i++){
		ts.arrSchema[i].feature_id=request.zos.globals.id;
		struct.featureSchemaStruct[ts.arrSchema[i].feature_schema_id]=ts.arrSchema[i];
	}
	//writedump(struct.featureSchemaStruct);
	// force these to exist for options outside of a group to be synced.
	struct.featureSchemaStruct["0"]={};
	struct.optionNameStruct["0"]={};
	for(i=1;i LTE arraylen(ts.arrSchema);i++){
		groupNameList=arrayToList(getFullSchemaPath(struct, ts.arrSchema[i].feature_schema_parent_id, ts.arrSchema[i].feature_schema_variable_name), chr(9));
		struct.featureSchemaNameStruct[groupNameList]=ts.arrSchema[i].feature_schema_id;
		struct.optionNameStruct[groupNameList]={};
		struct.featureSchemaNameLookupById[ts.arrSchema[i].feature_schema_id]=groupNameList;
	}
	for(i=1;i LTE arraylen(ts.arrField);i++){
		ts.arrField[i].feature_id=request.zos.globals.id;
		struct.typeStruct[ts.arrField[i].feature_field_id]=ts.arrField[i];
		if(ts.arrField[i].feature_schema_id NEQ 0 and structkeyexists(struct.featureSchemaStruct, ts.arrField[i].feature_schema_id)){ 
			groupStruct=struct.featureSchemaStruct[ts.arrField[i].feature_schema_id];
			groupNameList=getFullSchemaPath(struct, groupStruct.feature_schema_parent_id, groupStruct.feature_schema_variable_name);
			struct.optionNameStruct[arrayToList(groupNameList, chr(9))][ts.arrField[i].feature_field_variable_name]=ts.arrField[i].feature_field_id;
		}else{
			struct.optionNameStruct["0"][ts.arrField[i].feature_field_variable_name]=ts.arrField[i].feature_field_id;
		}
	}
	/*
	for(i=1;i LTE arraylen(ts.arrSchemaMap);i++){
		ts.arrSchemaMap[i].feature_id=request.zos.globals.id;
		struct.featureSchemaMapStruct[ts.arrSchemaMap[i].feature_map_id]=ts.arrSchemaMap[i];
	}*/
	return struct;
	</cfscript>
</cffunction>


<cffunction name="remapField" localmode="modern" returntype="struct">
	<cfargument name="source" type="struct" required="yes">
	<cfargument name="destination" type="struct" required="yes">
	<cfargument name="sourceFieldId" type="numeric" required="yes">
	<cfargument name="skipIdRemap" type="boolean" required="no" default="#false#">
	<cfscript>
	sourceStruct=arguments.source;
	destinationStruct=arguments.destination;
	
	row=duplicate(sourceStruct.typeStruct[arguments.sourceFieldId]);
	// loop source feature_field and check for select_menu group_id usage and any other fields that allow groupID
	if(row.feature_field_type_id EQ 7){
		typeStruct=deserializeJson(row.feature_field_type_json);
		if(structkeyexists(typeStruct, 'selectmenu_groupid') and typeStruct.selectmenu_groupid NEQ ""){
			rs=getSchemaById(sourceStruct, typeStruct.selectmenu_groupid);
			
			if(rs.success){
				groupNameList=arrayToList(getFullSchemaPath(sourceStruct, rs.struct.feature_schema_parent_id, rs.struct.feature_schema_variable_name), chr(9));
				
				selectSchemaStruct=getSchemaByName(destinationStruct, groupNameList, true);
				typeStruct.selectmenu_groupid=toString(selectSchemaStruct.struct.feature_schema_id);
			}else{
				echo("Warning: selectmenu_groupid, ""#typeStruct.selectmenu_groupid#"", doesn't exist in source. The Feature Field, #row.feature_field_variable_name# will be imported, but it must be manually corrected.");
				typeStruct.selectmenu_groupid='';
			}
		}
		row.feature_field_type_json=serializeJson(typeStruct);
		//row.zfeature_field_type_json=row.feature_field_type_json;
	}
	
	if(not arguments.skipIdRemap){
		groupNameList="0";
		if(row.feature_schema_id NEQ 0){
			groupNameList=sourceStruct.featureSchemaNameLookupById[row.feature_schema_id];
			rs=getSchemaByName(destinationStruct, groupNameList, true);
			row.feature_schema_id=rs.struct.feature_schema_id;
		}
		
		// this should work with feature_schema_id 0 as well.
		typeStruct=getFieldByName(destinationStruct, groupNameList, row.feature_field_variable_name, true);
		row.feature_field_id=typeStruct.struct.feature_field_id;
	}
	row.feature_id = request.zos.globals.id;
	return row;
	</cfscript>
</cffunction>

 

<cffunction name="remapSchema" localmode="modern" returntype="struct">
	<cfargument name="source" type="struct" required="yes">
	<cfargument name="destination" type="struct" required="yes">
	<cfargument name="sourceSchemaId" type="numeric" required="yes">
	<cfargument name="skipSchemaIdRemap" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	sourceStruct=arguments.source;
	destinationStruct=arguments.destination;
	row=sourceStruct.featureSchemaStruct[arguments.sourceSchemaId];
	
	// find the user_group_id in destination site
	if(row.feature_schema_user_group_id_list NEQ ""){
		userSchemaStruct=deserializeJson(row.userSchemaNameJSON);
		arrId=[];
		arrMissingId=[];
		for(n in userSchemaStruct){
			try{
				arrayAppend(arrId, variables.userSchemaCom.getSchemaId(n, request.zos.globals.id)); 
			}catch(Any excpt){
				arrayAppend(arrMissingId, n);
			}
		}
		if(arrayLen(arrMissingId)){
			throw("One of more user groups were missing and are required before sync can be completed: "&arrayToList(arrMissingId, ", "));
		}
		row.feature_schema_user_group_id_list=arrayToList(arrId,",");
		//row.zfeature_schema_user_group_id_list=arrayToList(arrId,",");
	}
	if(row.inquiries_type_id NEQ 0){
		tempSiteId=application.zcore.functions.zGetSiteIdFromSiteIDType(row.inquiries_type_id_siteIDType);
		db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE feature_id = #db.param(tempSiteId)# and 
		inquiries_type_deleted = #db.param(0)# and 
		inquiries_type_name = #db.param(row.inquiriesTypeName)#";
		qType=db.execute("qType");
		if(qType.recordcount EQ 0){
			throw("inquiries_type_id with name, ""#row.inquiriesTypeName#"", doesn't exist, and it is required.");
		}
		row.inquiries_type_id = qType.inquiries_type_id;
		//row.zinquiries_type_id = qType.inquiries_type_id;
	}
	if(not arguments.skipSchemaIdRemap){
		groupStruct=getSchemaById(sourceStruct, row.feature_schema_id);
		if(groupStruct.success){
			groupNameList=arrayToList(getFullSchemaPath(sourceStruct, groupStruct.struct.feature_schema_parent_id, row.feature_schema_variable_name), chr(9));
		}else{
			groupNameList=row.feature_schema_variable_name;
		}
		if(row.feature_schema_parent_id NEQ 0){
			parentSchemaStruct=getSchemaById(sourceStruct, row.feature_schema_parent_id);
			if(parentSchemaStruct.success){
				
				parentSchemaNameList=arrayToList(getFullSchemaPath(sourceStruct, parentSchemaStruct.struct.feature_schema_parent_id, parentSchemaStruct.struct.feature_schema_variable_name), chr(9));
			}else{
				parentSchemaNameList="";
			}
			rs=getSchemaByName(destinationStruct, parentSchemaNameList, true);
			if(rs.success){
				row.feature_schema_parent_id=rs.struct.feature_schema_id;
			}else{
				row.feature_schema_parent_id=0;
			}
		}
		rs=getSchemaByName(destinationStruct, groupNameList, true);
		row.feature_schema_id=rs.struct.feature_schema_id;
	}
	row.feature_id = request.zos.globals.id;
	return row;
	</cfscript>
</cffunction>



<cffunction name="compareRecords" localmode="modern">
	<cfargument name="source" type="struct" required="yes">
	<cfargument name="destination" type="struct" required="yes">
	<cfscript>
	sourceStruct=arguments.source;
	destinationStruct=arguments.destination;
	destinationStructClone=duplicate(arguments.destination);
	changed=false;
	changeStruct={};
	
	for(i in sourceStruct){
		if(not structkeyexists(destinationStruct, i)){
			changed=true;
			changeStruct[i]=sourceStruct[i];
		}else{
			structdelete(destinationStructClone, i);
		}
	}
	</cfscript>
</cffunction>


<cffunction name="getFullSchemaPath" localmode="modern" returntype="array">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="parentId" type="numeric" required="yes">
	<cfargument name="name" type="string" required="yes">
	<cfscript>
	arrParent=[];
	currentParentId=arguments.parentId;
	currentName=arguments.name; 
	i=0;
	while(true){
		arrayPrepend(arrParent, currentName); 
		if(currentParentId EQ 0 or not structkeyexists(arguments.struct.featureSchemaStruct, currentParentId)){
			break;
		}else{ 
			currentName=arguments.struct.featureSchemaStruct[currentParentId].feature_schema_variable_name;
			currentParentId=arguments.struct.featureSchemaStruct[currentParentId].feature_schema_parent_id; 
		}
		i++;
		if( i GT 100){
			throw("infinite loop detected with arguments.parentId=""#arguments.parentId#"" and arguments.name=""#arguments.name#"".");
		}
	}
	return arrParent;
	</cfscript>
</cffunction>

<cffunction name="getFieldFieldChanges" localmode="modern">
	<cfargument name="source" type="struct" required="yes">
	<cfargument name="destination" type="struct" required="yes">
	<cfscript>
	sourceStruct=arguments.source;
	destinationStruct=arguments.destination;
	changedFields={};    
	changedSchemas={};
	newSchemas={};
	extraSchemas={};
	newFields={};
	extraFields={};
	
	for(i in sourceStruct.featureSchemaNameStruct){
		groupId=sourceStruct.featureSchemaNameStruct[i];
		
		groupChanged=false; 
		if(structkeyexists(destinationStruct.featureSchemaNameStruct, i)){
			newSchemaStruct=remapSchema(sourceStruct, destinationStruct, groupId);
			currentDestinationStruct=destinationStruct.featureSchemaStruct[destinationStruct.featureSchemaNameStruct[i]];
			structdelete(newSchemaStruct, 'feature_schema_updated_datetime');
			structdelete(currentDestinationStruct, 'feature_schema_updated_datetime');
			if(not objectequals(newSchemaStruct, currentDestinationStruct)){
				if(form.debugEnabled){
					echo("changed group: "&i&"<br>");	
					echo('<div style="width:500px;float:left;">');
					writedump(newSchemaStruct);
					echo('</div><div style="width:500px;float:left;">');
					writedump(currentDestinationStruct);
					echo('</div>
					<hr style="clear:both;"/>');
				}
				changedSchemas[i]=newSchemaStruct;
			}
		}else{
			// new group - need to translate to the destination ids...
			newSchemas[i]=remapSchema(sourceStruct, destinationStruct, groupId);
		}
		extraFields[i]={};
		newFields[i]={};
		// check for field changes
		for(n in sourceStruct.optionNameStruct[i]){
			optionId=sourceStruct.optionNameStruct[i][n];
			
			newField=false;
			if(structkeyexists(destinationStruct.optionNameStruct, i)){
				if(structkeyexists(destinationStruct.optionNameStruct[i], n)){
					// check for field option changes
					sourceFieldStruct=remapField(sourceStruct, destinationStruct, optionId);
					destinationFieldStruct=destinationStruct.typeStruct[destinationStruct.optionNameStruct[i][n]];
					structdelete(sourceFieldStruct, 'feature_field_updated_datetime');
					structdelete(destinationFieldStruct, 'feature_field_updated_datetime');
					if(not objectequals(sourceFieldStruct, destinationFieldStruct)){
						if(form.debugEnabled){
							echo("changed field: "&i&" | "&n&"<br>");	
							echo('<div style="width:500px;float:left;">');
							writedump(sourceFieldStruct);
							echo('</div><div style="width:500px;float:left;">');
							writedump(destinationFieldStruct);
							echo('</div>
							<hr style="clear:both;"/>');
						}
						changedFields[i][n]=sourceFieldStruct;
					}
				}else{
					newField=true;
				}
			}else{
				newField=true;
			}
			if(newField){
				// new field
				if(form.debugEnabled){
					echo("new field: "&i&" | "&n&"<br>");
				}
				newFields[i][n]=remapField(sourceStruct, destinationStruct, optionId);
			}
		}
		if(form.deleteEnabled EQ 1){ 
			if(structkeyexists(destinationStruct.optionNameStruct, i)){
				for(n in destinationStruct.optionNameStruct[i]){
					optionId=destinationStruct.optionNameStruct[i][n];
					if(structkeyexists(sourceStruct.optionNameStruct[i], n)){
						continue; // already checked
					}else{
						// extra field
						if(form.debugEnabled){
							echo("extra field: "&i&" | "&n&"<br>");
						}
						extraFields[i][n]=destinationStruct.typeStruct[optionId];
					}
				}
			}
		}
	}
	
	if(form.deleteEnabled EQ 1){
		for(i in destinationStruct.featureSchemaNameStruct){
			groupId=destinationStruct.featureSchemaNameStruct[i];
			if(structkeyexists(sourceStruct.featureSchemaNameStruct, i)){
				continue; // skip, already checked above.
			}else{
				// extra group
				extraSchemas[i]=destinationStruct.featureSchemaStruct[groupId];
			}
		}
	}
	for(i in newFields){
		if(structcount(newFields[i]) EQ 0){
			structdelete(newFields, i);
		}
	}
	for(i in extraFields){
		if(structcount(extraFields[i]) EQ 0){
			structdelete(extraFields, i);
		}
	}
	fieldChangesStruct={
		changedSchemas: changedSchemas,
		extraSchemas: extraSchemas,
		newSchemas: newSchemas,
		extraFields:extraFields, // extra fields in destination - that could be renamed or deleted
		newFields:newFields, // new fields in source that could be added to destination, if they are not mapped to an existing fields manually.
		changedFields: changedFields // fields with changed metadata
	};
	if(form.debugEnabled){
		writedump(fieldChangesStruct);
	}
	return fieldChangesStruct;
	</cfscript>
</cffunction>

<cffunction name="updateField" localmode="modern">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="new" type="boolean" required="yes">
	<cfscript>
	throw("updateField not implemented.");
	abort;
	db=request.zos.queryObject;
	arguments.row.feature_field_updated_datetime = request.zos.mysqlnow;
	if(arguments.new){
		arrSQL=["INSERT INTO #db.table("feature_field", request.zos.zcoreDatasource)# SET "];
		for(i in arguments.row){
			if(i NEQ "feature_field_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE feature_id = #db.param(arguments.row.feature_id)# and 
		feature_field_deleted = #db.param(0)# and
		feature_field_id = #db.param(arguments.row.feature_field_id)# ";
		result=db.insert("qFieldInsert", request.zos.insertIDColumnForSiteIDTable);
		if(rs.success){
			return rs.result;
		}else{
			throw("Failed to create feature_field");	
		}
	}else{
		arrSQL=["UPDATE #db.table("feature_field", request.zos.zcoreDatasource)# SET"];
		for(i in arguments.row){
			if(i NEQ "feature_id" or i NEQ "feature_field_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE feature_id = #db.param(arguments.row.feature_id)# and 
		feature_field_deleted = #db.param(0)# and
		feature_field_id = #db.param(arguments.row.feature_field_id)# ";
		return db.execute("qFieldUpdate");
	}
	</cfscript>
</cffunction>


<cffunction name="updateSchema" localmode="modern">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="new" type="boolean" required="yes">
	<cfscript>
	throw("updateSchema not implemented.");
	abort;
	db=request.zos.queryObject;
	arguments.row.feature_schema_updated_datetime = request.zos.mysqlnow;
	if(arguments.new){
		arrSQL=["INSERT INTO #db.table("feature_schema", request.zos.zcoreDatasource)# SET "];
		for(i in arguments.row){
			if(i NEQ "feature_schema_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE feature_id = #db.param(arguments.row.feature_id)# and 
		feature_schema_deleted = #db.param(0)# and
		feature_schema_id = #db.param(arguments.row.feature_schema_id)# ";
		result=db.insert("qSchemaInsert", request.zos.insertIDColumnForSiteIDTable);
		if(rs.success){
			return rs.result;
		}else{
			throw("Failed to create feature_schema");	
		}
	}else{
		arrSQL=["UPDATE #db.table("feature_schema", request.zos.zcoreDatasource)# SET"];
		for(i in arguments.row){
			if(i NEQ "feature_id" or i NEQ "feature_schema_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE feature_id = #db.param(arguments.row.feature_id)# and 
		feature_schema_deleted = #db.param(0)# and
		feature_schema_id = #db.param(arguments.row.feature_schema_id)# ";
		return db.execute("qSchemaUpdate");
	}
	</cfscript>
</cffunction>
<!--- 
<cffunction name="updateSchemaMap" localmode="modern">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="new" type="boolean" required="yes">
	<cfscript>
	throw("updateSchemaMap not implemented.");
	abort;
	db=request.zos.queryObject;
	arguments.row.feature_map_updated_datetime = request.zos.mysqlnow;
	if(arguments.new){
		arrSQL=["INSERT INTO #db.table("feature_map", request.zos.zcoreDatasource)# SET "];
		for(i in arguments.row){
			if(i NEQ "feature_map_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE feature_id = #db.param(arguments.row.feature_id)# and 
		feature_map_deleted = #db.param(0)# and
		feature_map_id = #db.param(arguments.row.feature_map_id)# ";
		result=db.insert("qSchemaMapInsert", request.zos.insertIDColumnForSiteIDTable);
		if(rs.success){
			return rs.result;
		}else{
			throw("Failed to create feature_map");	
		}
	}else{
		arrSQL=["UPDATE #db.table("feature_map", request.zos.zcoreDatasource)# SET"];
		for(i in arguments.row){
			if(i NEQ "feature_id" or i NEQ "feature_map_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE feature_id = #db.param(arguments.row.feature_id)# and 
		feature_map_deleted = #db.param(0)# and 
		feature_map_id = #db.param(arguments.row.feature_map_id)# ";
		return db.execute("qSchemaMapUpdate");
	}
	</cfscript>
</cffunction> --->

<!--- 
<cffunction name="remapSchemaMap" localmode="modern" returntype="struct">
	<cfargument name="source" type="struct" required="yes">
	<cfargument name="destination" type="struct" required="yes">
	<cfargument name="sourceSchemaMapId" type="numeric" required="yes">
	<cfscript>
	sourceStruct=arguments.source;
	destinationStruct=arguments.destination; 
	
	row=sourceStruct.featureSchemaMapStruct[arguments.sourceSchemaMapId];
	
	
	groupNameList=sourceStruct.featureSchemaNameLookupById[row.feature_schema_id];
		
	sourceSchemaStruct=getSchemaByName(sourceStruct, groupNameList, true);
	
	destinationSchemaStruct=getSchemaByName(destinationStruct, groupNameList, true);
	
	row.feature_schema_id=destinationSchemaStruct.struct.feature_schema_id;
	
	// remap feature_field_id
	sourceField=getFieldById(sourceStruct, row.feature_field_id);
	if(not sourceField.success){
		return {success:false, errorMessage:"skipping source where row.feature_field_id = ""#row.feature_field_id#""<br />" };
	}
	destinationFieldStruct=getFieldByName(destinationStruct, groupNameList, sourceField.struct.feature_field_variable_name, true);
	row.feature_field_id=destinationFieldStruct.struct.feature_field_id;
	
	// remap feature_map_fieldname if this feature_field_id is mapped to a feature_schema_id
	if(sourceSchemaStruct.struct.feature_map_group_id NEQ 0){
		if(structkeyexists(sourceStruct.featureSchemaNameLookupById, sourceSchemaStruct.struct.feature_map_group_id)){
			return {success:false, errorMessage:"can't map due to missing feature_map_group_id, #sourceSchemaStruct.struct.feature_map_group_id#, in source<br />" };
		}
		groupNameList2=sourceStruct.featureSchemaNameLookupById[sourceSchemaStruct.struct.feature_map_group_id];
		// remap feature_field_id
		sourceField2=getFieldById(sourceStruct, row.feature_map_fieldname);
		if(not sourceField2.success){
			return {success:false, errorMessage:"can't map due to missing feature_field_id, #row.feature_map_fieldname#, in source<br />" };
		}else{
			destinationFieldStruct2=getFieldByName(destinationStruct, groupNameList2, sourceField2.struct.feature_field_variable_name, true);
			// feature_map_fieldname is a field in the feature_map_group_id field of the current feature_schema_id
			row.feature_map_fieldname=destinationFieldStruct2.struct.feature_field_id;
		}
	}
	row.feature_map_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	row.feature_id=request.zos.globals.id;
	return {success:true, struct:row };
	</cfscript>
</cffunction> --->


<cffunction name="exportData" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.userSchemaCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.user_group_admin");
	if(request.zos.isTestServer){
		fileName="test-";
	}else{
		fileName="live-";
	}
	fileName&="sync-json-";
	fileName&=application.zcore.functions.zUrlEncode(request.zos.globals.shortDomain)&".txt";

	
	
	// later I would load sourceDataStruct from external json.js file instead of database when comparing and importing structure changes.
	sourceDataStruct=getFieldDataFromDatabase();
	
	/*
	don't use menu, slideshow or other features yet in theme - too complex.
		make them with feature_schema instead.
	
	menuDataStruct=getMenuDataFromDatabase();
	
	slideshowDataStruct=getSlideshowDataFromDatabase();
	
	slideshowDataStruct=getSlideshowDataFromDatabase();
	
	*/
	
	
	sourceJsonString=serializeJSON(sourceDataStruct);

	if(structkeyexists(form, 'download')){
		header name="Content-Type" value="text/plain" charset="utf-8";
		header name="Content-Disposition" value="attachment; filename=#fileName#" charset="utf-8";
	}
	echo(sourceJsonString);
	abort;
	</cfscript>
</cffunction>

<cffunction name="preview" access="public" localmode="modern" roles="serveradministrator">
	<cfargument name="fieldChangeStruct" type="struct" required="yes">
	<cfargument name="sourceStruct" type="struct" required="yes">
	<cfargument name="destinationStruct" type="struct" required="yes">
	<cfscript>
	fieldChangeStruct=arguments.fieldChangeStruct;
	sourceStruct=arguments.sourceStruct;
	destinationStruct=arguments.destinationStruct;
	
	hasChanges=false;
	
	echo('<h2>Import Preview</h2>'); 
	echo('<form class="zFormCheckDirty" action="/z/admin/sync/importData?importId=#form.importId#&deleteEnabled=#form.deleteEnabled#&debugEnabled=#form.debugEnabled#" method="post">'); 
	if(structcount(fieldChangeStruct.newSchemas)){
		echo('<h2>Feature Schemas that will be added</h2>
		<table class="table-list">
		');
		hasChanges=true; 
		arrKey=structkeyarray(fieldChangeStruct.newSchemas);
		arraySort(arrKey, "text", "asc"); 
		for(g=1;g LTE arrayLen(arrKey);g++){
			i=arrKey[g];
			echo('<tr><td>'&replace(i, chr(9), " &rarr; ", "all")&"</td></tr>");
		}
		echo('</table><br />');
	}
	if(structcount(fieldChangeStruct.changedSchemas)){
		echo('<h2>Feature Schemas that will be updated</h2>
		<table class="table-list">');
		hasChanges=true;
		arrKey=structkeyarray(fieldChangeStruct.changedSchemas);
		arraySort(arrKey, "text", "asc");
		for(g=1;g LTE arrayLen(arrKey);g++){
			i=arrKey[g];
			echo('<tr><td>'&replace(i, chr(9), " &rarr; ", "all")&"</td></tr>");
		}
		echo('</table><br />');
	}
	if(structcount(fieldChangeStruct.extraSchemas)){
		echo('<h2>Feature Schemas that will be deleted.</h2>
		<table class="table-list">');
		hasChanges=true;
		arrKey=structkeyarray(fieldChangeStruct.extraSchemas);
		arraySort(arrKey, "text", "asc");
		for(g=1;g LTE arrayLen(arrKey);g++){
			i=arrKey[g];
			echo('<tr><td>'&replace(i, chr(9), " &rarr; ", "all")&"</td></tr>");
		}
		echo('</table><br />');
	}
		
		
	arrF=[];
	arrKey=structkeyarray(fieldChangeStruct.newFields);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		c=fieldChangeStruct.newFields[i];
		for(n in c){
			hasChanges=true;
			arrayAppend(arrF, '<tr><td>'&replace(i, chr(9), " &rarr; ", "all")&" &rarr; "&n&"</td></tr>");
		}
	}
	if(arrayLen(arrF)){
		echo('<h2>Fields that will be added</h2>
		<table class="table-list">');
		hasChanges=true;
		echo(arrayToList(arrF, " "));
		echo('</table><br />');
	}
	arrF=[];
	arrKey=structkeyarray(fieldChangeStruct.changedSchemas);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		if(structkeyexists(fieldChangeStruct.changedFields, i)){
			c=fieldChangeStruct.changedFields[i];
			for(n in c){
				arrayAppend(arrF, '<tr><td>'&replace(i, chr(9), " &rarr; ", "all")&" &rarr; "&n&"</td></tr>");
			}
		}
	}
	if(arrayLen(arrF)){
		echo('<h2>Fields that will be updated</h2>
		<table class="table-list">');
		hasChanges=true;
		echo(arrayToList(arrF, " "));
		echo('</table><br />');
	}
	arrF=[];
	arrKey=structkeyarray(fieldChangeStruct.extraFields);
	arraySort(arrKey,  "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		c=fieldChangeStruct.extraFields[i];
		for(n in c){
			arrayAppend(arrF, '<tr><td>'&replace(i, chr(9), " &rarr; ", "all")&" &rarr; "&n&"</td></tr>");
		}
	}
	if(arrayLen(arrF)){
		hasChanges=true;
		echo('<h2>Fields that will be deleted</h2>
		<table class="table-list">');
		echo(arrayToList(arrF, " "));
		echo('</table><br />');
	}
	if(not hasChanges){
		application.zcore.status.setStatus(request.zsid, "No changes were detected, import cancelled.");
		application.zcore.functions.zRedirect("/z/admin/sync/index?zsid=#request.zsid#");
	}
	echo('<input type="hidden" name="finalize" value="1" />
	<button type="submit" name="submit1" value="">Finalize Import</button> 
	<button type="button" name="button1" value="" onclick="window.location.href=''/z/admin/sync/index'';" >Cancel</button>');
	echo('</form>');
	</cfscript>
</cffunction>

<cffunction name="import" access="public" localmode="modern" roles="serveradministrator">
	<cfargument name="fieldChangeStruct" type="struct" required="yes">
	<cfargument name="sourceStruct" type="struct" required="yes">
	<cfargument name="destinationStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	fieldChangeStruct=arguments.fieldChangeStruct;
	sourceStruct=arguments.sourceStruct;
	destinationStruct=arguments.destinationStruct;
	
	
	arrKey=structkeyarray(fieldChangeStruct.extraSchemas);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		groupId=destinationStruct.featureSchemaNameStruct[i];
		if(form.debugEnabled){
			echo("delete feature_schema where feature_schema_id=#groupId#<br>");
		}else{
			application.zcore.featureCom.deleteSchemaRecursively(groupId, false);
		}
	}
	arrKey=structkeyarray(fieldChangeStruct.extraFields);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		for(n in fieldChangeStruct.extraFields[i]){
			optionId=destinationStruct.optionNameStruct[i][n];
			if(form.debugEnabled){
				echo("delete feature_schema where feature_field_id=#optionId#<br>");
			}else{
				db.sql="select * from #db.table("feature_data", request.zos.zcoreDatasource)# feature_data, 
				#db.table("feature_field", request.zos.zcoreDatasource)# feature_field 
				where feature_data.feature_field_id = #db.param(optionId)# and 
				feature_data.feature_id = #db.param(form.feature_id)# and 
				feature_data_deleted = #db.param(0)# and 
				feature_field_deleted = #db.param(0)# and
				feature_data.feature_field_id = feature_field.feature_field_id and 
				feature_data.feature_id = feature_field.feature_id ";
				qSiteXSchema=db.execute("qSiteXSchema");
				for(row in qSiteXSchema){
					typeStruct=deserializeJson(row.feature_field_type_json); 
					currentCFC=application.zcore.featureCom.getTypeCFC(row.feature_field_type_id);
					if(currentCFC.hasCustomDelete()){
						// call delete on optionType
						currentCFC.onDelete(row, typeStruct);
					}
				}
				db.sql="delete from #db.table("feature_data", request.zos.zcoreDatasource)# 
				where feature_field_id = #db.param(optionId)# and 
				feature_data_deleted = #db.param(0)# and
				feature_id = #db.param(form.feature_id)#";
				db.execute("qDelete");
				
				/*db.sql="delete from #db.table("feature_map", request.zos.zcoreDatasource)# 
				where feature_field_id = #db.param(optionId)# and 
				feature_id = #db.param(form.feature_id)#";
				db.execute("qDelete");*/
				
				db.sql="delete from #db.table("feature_field", request.zos.zcoreDatasource)# 
				WHERE feature_field_id=#db.param(optionId)# and 
				feature_field_deleted = #db.param(0)# and
				feature_id = #db.param(form.feature_id)# ";
				db.execute("qDeleteField");
			}
		}
	}
	
	arrKey=structkeyarray(fieldChangeStruct.newSchemas);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		ts={};
		ts.table="feature_schema";
		ts.enableReplace=true;
		ts.struct=fieldChangeStruct.newSchemas[i];
		ts.struct.feature_schema_updated_datetime=request.zos.mysqlnow;
		ts.datasource=request.zos.zcoreDatasource;
		ts.forcePrimaryInsert={
			"feature_schema_id":true,
			"feature_id":true
		};
		if(form.debugEnabled){
			echo("insert feature_schema<br />");
			writedump(ts);
		}else{
			application.zcore.functions.zInsert(ts);
		}
	}
	arrKey=structkeyarray(fieldChangeStruct.changedSchemas);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		ts={};
		ts.table="feature_schema";
		ts.struct=fieldChangeStruct.changedSchemas[i];
		ts.struct.feature_schema_updated_datetime=request.zos.mysqlnow;
		ts.datasource=request.zos.zcoreDatasource;
		if(form.debugEnabled){
			echo("update feature_schema<br>");
			writedump(ts);
		}else{
			application.zcore.functions.zUpdate(ts);
		}
	}
	arrKey=structkeyarray(fieldChangeStruct.newFields);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		for(n in fieldChangeStruct.newFields[i]){
			ts={};
			ts.table="feature_field";
			ts.enableReplace=true;
			ts.struct=fieldChangeStruct.newFields[i][n];
			ts.struct.feature_field_updated_datetime=request.zos.mysqlnow;
			ts.datasource=request.zos.zcoreDatasource;
			ts.forcePrimaryInsert={
				"feature_field_id":true,
				"feature_id":true
			};
			if(form.debugEnabled){
				echo("insert feature_field<br>");
				writedump(ts);
			}else{
				application.zcore.functions.zInsert(ts);
			}
		}
	}
	arrKey=structkeyarray(fieldChangeStruct.changedFields);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		for(n in fieldChangeStruct.changedFields[i]){
			ts={};
			ts.table="feature_field";
			ts.struct=fieldChangeStruct.changedFields[i][n];
			ts.struct.feature_field_updated_datetime=request.zos.mysqlnow;
			ts.datasource=request.zos.zcoreDatasource;
			if(form.debugEnabled){
				echo("update feature_field<br>");
				writedump(ts);
			}else{
				application.zcore.functions.zUpdate(ts);
			}
		}
	}
	/*
	if(structcount(sourceStruct.featureSchemaMapStruct)){
		groupIdStruct={};
		for(i in sourceStruct.featureSchemaMapStruct){
			mapStruct=remapSchemaMap(sourceStruct, destinationStruct, i);
			if(mapStruct.success){
				groupIdStruct[mapStruct.struct.feature_schema_id]=true;
				ts={};
				ts.table="feature_map";
				ts.struct=mapStruct.struct;
				ts.struct.feature_map_updated_datetime=request.zos.mysqlnow;
				ts.datasource=request.zos.zcoreDatasource;
				if(form.debugEnabled){
					echo("insert feature_map<br>");
					writedump(ts);
				}else{
					application.zcore.functions.zInsert(ts);
				}
			}
		}
		arrSchema=structkeyarray(groupIdStruct);
		idlist="'"&arrayToList(arrSchema, "','")&"'";
		if(arrayLen(arrSchema)){
			if(form.debugEnabled){
				echo("remove feature_map records that weren't updated where feature_schema_id in (#idlist#)<br>");
			}else{
				db.sql="delete from #db.table("feature_map", request.zos.zcoreDatasource)# 
				where feature_map_updated_datetime < #db.param(request.zos.mysqlnow)# and 
				feature_map_deleted = #db.param(0)# and
				feature_id=#db.param(form.feature_id)# and 
				feature_schema_id IN (#db.trustedSQL(idlist)#)";
				db.execute("qDelete");
			}
		}
	}*/
	
	if(form.debugEnabled){
		echo("Import cancelled because debugging is enabled.");
		application.zcore.functions.zabort();
	}else{
		// remove the json file from shared memory
		statusStruct=application.zcore.status.getStruct(form.importId);
		structclear(statusStruct.varStruct);
		
		application.zcore.functions.zOS_cacheSiteAndUserSchemas(request.zos.globals.id);
		application.zcore.status.setStatus(request.zsid, "Import completed successfully.");
		application.zcore.functions.zRedirect("/z/admin/sync/index?zsid=#request.zsid#");
	}
	
	</cfscript>
</cffunction>

<cffunction name="importData" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager", true);
	init();
	db=request.zos.queryObject;
	
	form.finalize=application.zcore.functions.zso(form, 'finalize', true, 0);
	form.deleteEnabled=application.zcore.functions.zso(form, 'deleteEnabled', true, 0);
	form.debugEnabled=application.zcore.functions.zso(form, 'debugEnabled', true, 0);
	
	request.nextFieldStruct={};
	request.nextSchemaStruct={};

	db.sql="select IF(ISNULL(MAX(feature_field_id)), #db.param(0)#, MAX(feature_field_id)) id from 
	#db.table("feature_field", request.zos.zcoredatasource)# 
	where feature_id = #db.param(form.feature_id)# and 
	feature_field_deleted = #db.param(0)#";
	qFieldId=db.execute("qFieldId");
	request.nextFieldId=qFieldId.id+1;
	
	db.sql="select IF(ISNULL(MAX(feature_schema_id)), #db.param(0)#, MAX(feature_schema_id)) id from 
	#db.table("feature_field", request.zos.zcoredatasource)# 
	where feature_id = #db.param(form.feature_id)# and 
	feature_field_deleted = #db.param(0)# ";
	qSchemaId=db.execute("qSchemaId");
	request.nextSchemaId=qSchemaId.id+1;
	
	
	form.importId=application.zcore.functions.zso(form, 'importId', true, 0);
	 if(form.importId EQ 0){
		path=request.zos.globals.privatehomedir&"zupload/user/";
		filePath=application.zcore.functions.zuploadfile("import_file", path);
		if(isBoolean(filePath) and not filePath){
			application.zcore.status.setStatus(request.zsid, "A valid file must be uploaded.", form, true);
			application.zcore.functions.zRedirect("/z/admin/sync/index?zsid=#request.zsid#");
		}
		sourceJsonString=application.zcore.functions.zreadfile(path&filePath);
		application.zcore.functions.zdeletefile(path&filePath);
		tempStruct={
			sourceJsonString: sourceJsonString
		};
		form.importId=application.zcore.status.getNewId();
		application.zcore.status.setStatus(form.importId, false, tempStruct);
		application.zcore.functions.zRedirect("/z/admin/sync/importData?importId=#form.importId#&debugEnabled=#form.debugEnabled#&deleteEnabled=#form.deleteEnabled#");
	 }else{
		statusStruct=application.zcore.status.getStruct(form.importId);
		if(not structkeyexists(statusStruct.varStruct, 'sourceJsonString')){
			application.zcore.status.setStatus(request.zsid, "Import session expired.  Please try again.", form, true);
			application.zcore.functions.zRedirect("/z/admin/sync/index?zsid=#request.zsid#");
		}
		sourceJsonString=statusStruct.varStruct.sourceJsonString;
	}
	variables.userSchemaCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.user_group_admin");
	sourceDataStruct=deserializeJSON(sourceJsonString);
	sourceStruct=getFieldMappedData(sourceDataStruct);
	
	destinationDataStruct=getFieldDataFromDatabase();
	destinationStruct=getFieldMappedData(destinationDataStruct);
	
	fieldChangeStruct=getFieldFieldChanges(sourceStruct, destinationStruct);
	
	if(form.finalize EQ 0){
		preview(fieldChangeStruct, sourceStruct, destinationStruct);
	}else{
		import(fieldChangeStruct, sourceStruct, destinationStruct);
	}
	/*if(form.debugEnabled){ 
		writedump("The following new ids were created and their data was not fully mapped to them yet.");
		writedump(request.nextFieldStruct);
		writedump(request.nextSchemaStruct);
	}*/
	// feature_field_app is missing from this code - so any customizations for blog & content records would be lost in a theme export/import.
	
	</cfscript>
</cffunction>

<cffunction name="init" access="private" localmode="modern">
	<cfscript>
	featureSchemaCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.admin.controller.feature-schema");
	featureSchemaCom.displayFeatureAdminNav();
	</cfscript>
</cffunction>

<cffunction name="index" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript> 
	db=request.zos.queryObject; 

	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	init();
	application.zcore.functions.zSetPageHelpId("2.7.5");
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2>Sync Tool</h2>
	<p>Allows import/export of configuration data for Feature Fields system.   <!--- Coming soon: sync for menus, slideshows, site globals, app configuration, and more. ---></p>
	<p><strong>WARNING: Sync only works if the Code Name matches on both servers.  If you have edited the code name manually, you must edit the remote server manually too, or you may cause data loss.</strong></p>
	<p>If you are unsure about the safety of using this feature, you should probably download a copy of the newest version of the project instead of using this tool.</p>
	<h3><a href="/z/admin/sync/exportData?download=1" class="z-manager-search-button">Export</a> </h3>
	<hr />
	<h2>Import</h2>
	<p>The json file must be valid or it may cause data loss or errors.  Make sure that you are running the same version of Jetendo on both the source and destination for best compatibility.</p>
	<form class="zFormCheckDirty" action="/z/admin/sync/importData" method="post" enctype="multipart/form-data">
		<p><label for="import_file">File:</label>
		<cfscript>
		ts={
			name:"import_file"
		};
		application.zcore.functions.zInput_File(ts);
		</cfscript>
		</p>
		<p><input type="checkbox" name="deleteEnabled" id="deleteEnabled" value="1" /> <label for="deleteEnabled">Delete extra options and groups? Warning: affected user data will be permanently deleted.</label> 
		</p>
		<p><input type="checkbox" name="debugEnabled" id="debugEnabled" value="1" /> <label for="debugEnabled">Enable debug mode?  Note: no permanent changes are made in debug mode and large objects will be dumped to screen to help with debugging.</label> 
		</p>
		<p><input type="submit" name="submit1" value="Preview Import" class="z-manager-search-button z-t-18" /></p>
	</form>
	
</cffunction>
</cfoutput>
</cfcomponent>