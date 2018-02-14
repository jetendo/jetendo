<cfcomponent>
<cfoutput>
<!--- 
need option for "Delete missing fields?"

Maybe a better export format uses groupNameList for all the site_option_group_id and groupNameList+site_option_name for all the site_option_id
This allows avoiding remaps more easily.  Less code when importing.
 --->

<cffunction name="getNextOptionId" localmode="modern" returntype="numeric">
	<cfargument name="groupNameList" type="string" required="yes">
	<cfargument name="site_option_name" type="string" required="yes">
	<cfscript>
	if(not structkeyexists(request.nextOptionStruct, arguments.groupNameList)){
		request.nextOptionStruct[arguments.groupNameList]={};
	}
	if(structkeyexists(request.nextOptionStruct[arguments.groupNameList], arguments.site_option_name)){
		request.nextOptionStruct[arguments.groupNameList][arguments.site_option_name];
	}
	request.nextOptionId++;
	request.nextOptionStruct[arguments.groupNameList][arguments.site_option_name]=request.nextOptionId;
	return request.nextOptionId;
	</cfscript>
</cffunction>

<cffunction name="getNextOptionGroupId" localmode="modern" returntype="numeric">
	<cfargument name="groupNameList" type="string" required="yes">
	<cfscript>
	if(structkeyexists(request.nextOptionGroupStruct, arguments.groupNameList)){
		return request.nextOptionGroupStruct[arguments.groupNameList];
	}
	request.nextOptionGroupId++;
	request.nextOptionGroupStruct[arguments.groupNameList]=request.nextOptionGroupId;
	return request.nextOptionGroupId;
	</cfscript>
</cffunction>

<cffunction name="getOptionGroupByName" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="groupNameList" type="string" required="yes">
	<cfargument name="createIfMissing" type="boolean" required="no" default="#false#">
	<cfscript>
	arrGroup=listToArray(arguments.groupNameList, chr(9));
	if(arraylen(arrGroup) EQ 0){
		return {success:false};
	}
	site_option_group_name=arrGroup[arrayLen(arrGroup)];
	if(arraylen(arrGroup) LTE 1 or arguments.groupNameList EQ 0){
		parentId=0;
	}else{
		arrayDeleteAt(arrGroup, arraylen(arrGroup));
		parentStruct=getOptionGroupByName(arguments.struct, arrayToList(arrGroup, chr(9)), arguments.createIfMissing);
		parentId=parentStruct.struct.site_option_group_id;
	}
	if(structkeyexists(arguments.struct.optionGroupNameStruct, arguments.groupNameList)){
		groupStruct=arguments.struct.optionGroupStruct[arguments.struct.optionGroupNameStruct[arguments.groupNameList]];
		return { success:true, struct:groupStruct };
	}else if(arguments.createIfMissing){
		groupStruct={
			new:true,
			site_option_group_name:site_option_group_name,
			site_option_group_id:getNextOptionGroupId(arguments.groupNameList),
			site_option_group_parent_id:parentId,
			site_id:request.zos.globals.id
		};
		return { success:true, struct:groupStruct };
	}else{
		return {success:false};
	}
	</cfscript>
</cffunction>

<cffunction name="getOptionGroupById" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="site_option_group_id" type="string" required="yes">
	<cfscript>
	if(structkeyexists(arguments.struct.optionGroupStruct, arguments.site_option_group_id)){
		groupStruct=arguments.struct.optionGroupStruct[arguments.site_option_group_id];
		return { success:true, struct:groupStruct };
	}else{
		return {success:false};
	}
	</cfscript>
</cffunction>

<cffunction name="getOptionById" localmode="modern" returntype="struct">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="site_option_id" type="string" required="yes">
	<cfscript>
	if(structkeyexists(arguments.struct.optionStruct, arguments.site_option_id)){
		optionStruct=arguments.struct.optionStruct[arguments.site_option_id];
		return { success:true, struct:optionStruct };
	}else{
		return {success:false};
	}
	</cfscript>
</cffunction>

<cffunction name="getOptionByName" localmode="modern" returntype="struct">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="groupNameList" type="string" required="yes">
	<cfargument name="site_option_name" type="string" required="yes">
	<cfargument name="createIfMissing" type="boolean" required="no" default="#false#">
	<cfscript>
	groupStruct=getOptionGroupByName(arguments.struct, arguments.groupNameList, arguments.createIfMissing);
	if(not groupStruct.success){
		return {success:false, errorMessage:"couldn't find group: "&arguments.groupNameList&"<br>"};
	}
	if(structkeyexists(arguments.struct.optionNameStruct, arguments.groupNameList) and structkeyexists(arguments.struct.optionNameStruct[arguments.groupNameList], arguments.site_option_name)){
		optionStruct=arguments.struct.optionStruct[arguments.struct.optionNameStruct[arguments.groupNameList][arguments.site_option_name]];
		return { success:true, struct:optionStruct };
	}else if(arguments.createIfMissing){
		optionStruct={
			new:true,
			site_option_group_id:groupStruct.struct.site_option_group_id,
			site_option_id:getNextOptionId(arguments.groupNameList, arguments.site_option_name),
			site_id:request.zos.globals.id
		};
		return { success:true, struct:optionStruct };
	}else{
		return {success:false, errorMessage:"site_option_name, ""#arguments.site_option_name#"", doesn't exist in group."};
	}
	</cfscript>
</cffunction>

<cffunction name="getOptionDataFromDatabase" access="public" localmode="modern" returntype="struct">
	<cfscript>
	db=request.zos.queryObject;
	ts={
		arrOption:[],
		arrOptionGroup:[],
	//	arrOptionGroupMap:[],
	};
	// setup destination data
	db.sql="select * from #db.table("site_option", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_option_deleted = #db.param(0)# ";
	qOption=db.execute("qOption");
	for(row in qOption){
		arrayAppend(ts.arrOption, row);
	}
	
	db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and
	site_option_group_deleted = #db.param(0)# 
	ORDER BY site_option_group_parent_id ASC ";
	qGroup=db.execute("qGroup");
	for(row in qGroup){
		if(row.site_option_group_user_group_id_list NEQ ""){
			arrGroup=listToArray(row.site_option_group_user_group_id_list, ",");
			groupNameStruct={};
			for(n=1;n LTE arraylen(arrGroup);n++){
				arrayAppend(groupNameStruct, variables.userGroupCom.getGroupName(arrGroup[n], request.zos.globals.id)); 
			}
			row.userGroupNameJSON=serializeJson(groupNameStruct);
		}
		if(row.inquiries_type_id NEQ 0){
			tempSiteId=application.zcore.functions.zGetSiteIdFromSiteIDType(row.inquiries_type_id_siteIDType);
			db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
			WHERE site_id = #db.param(tempSiteId)# and 
			inquiries_type_deleted = #db.param(0)# and 
			inquiries_type_id = #db.param(row.inquiries_type_id)#";
			qType=db.execute("qType");
			if(qType.recordcount EQ 0){
				throw("inquiries_type_id, ""#row.inquiries_type_id#"", doesn't exist, and it is required.");
			}
			row.inquiriesTypeName = qType.inquiries_type_name;
		}
		arrayAppend(ts.arrOptionGroup, row);
	}
	/*
	db.sql="select * from #db.table("site_option_group_map", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_option_group_map_deleted = #db.param(0)# ";
	qMap=db.execute("qMap");
	for(row in qMap){
		arrayAppend(ts.arrOptionGroupMap, row);
	}*/
	return ts;
	</cfscript>
</cffunction>


<cffunction name="getOptionMappedData" access="public" localmode="modern" returntype="struct">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	ts=arguments.dataStruct;
	struct={
		optionStruct:{},
		optionGroupStruct:{},
		//optionGroupMapStruct:{},
		optionNameStruct:{},
		optionGroupNameStruct:{},
		optionGroupNameLookupById:{}
	};
	for(i=1;i LTE arraylen(ts.arrOptionGroup);i++){
		ts.arrOptionGroup[i].site_id=request.zos.globals.id;
		struct.optionGroupStruct[ts.arrOptionGroup[i].site_option_group_id]=ts.arrOptionGroup[i];
	}
	//writedump(struct.optionGroupStruct);
	// force these to exist for options outside of a group to be synced.
	struct.optionGroupStruct["0"]={};
	struct.optionNameStruct["0"]={};
	for(i=1;i LTE arraylen(ts.arrOptionGroup);i++){
		groupNameList=arrayToList(getFullGroupPath(struct, ts.arrOptionGroup[i].site_option_group_parent_id, ts.arrOptionGroup[i].site_option_group_name), chr(9));
		struct.optionGroupNameStruct[groupNameList]=ts.arrOptionGroup[i].site_option_group_id;
		struct.optionNameStruct[groupNameList]={};
		struct.optionGroupNameLookupById[ts.arrOptionGroup[i].site_option_group_id]=groupNameList;
	}
	for(i=1;i LTE arraylen(ts.arrOption);i++){
		ts.arrOption[i].site_id=request.zos.globals.id;
		struct.optionStruct[ts.arrOption[i].site_option_id]=ts.arrOption[i];
		if(ts.arrOption[i].site_option_group_id NEQ 0 and structkeyexists(struct.optionGroupStruct, ts.arrOption[i].site_option_group_id)){ 
			groupStruct=struct.optionGroupStruct[ts.arrOption[i].site_option_group_id];
			groupNameList=getFullGroupPath(struct, groupStruct.site_option_group_parent_id, groupStruct.site_option_group_name);
			struct.optionNameStruct[arrayToList(groupNameList, chr(9))][ts.arrOption[i].site_option_name]=ts.arrOption[i].site_option_id;
		}else{
			struct.optionNameStruct["0"][ts.arrOption[i].site_option_name]=ts.arrOption[i].site_option_id;
		}
	}
	/*
	for(i=1;i LTE arraylen(ts.arrOptionGroupMap);i++){
		ts.arrOptionGroupMap[i].site_id=request.zos.globals.id;
		struct.optionGroupMapStruct[ts.arrOptionGroupMap[i].site_option_group_map_id]=ts.arrOptionGroupMap[i];
	}*/
	return struct;
	</cfscript>
</cffunction>


<cffunction name="remapOption" localmode="modern" returntype="struct">
	<cfargument name="source" type="struct" required="yes">
	<cfargument name="destination" type="struct" required="yes">
	<cfargument name="sourceOptionId" type="numeric" required="yes">
	<cfargument name="skipIdRemap" type="boolean" required="no" default="#false#">
	<cfscript>
	sourceStruct=arguments.source;
	destinationStruct=arguments.destination;
	
	row=duplicate(sourceStruct.optionStruct[arguments.sourceOptionId]);
	// loop source site_option and check for select_menu group_id usage and any other fields that allow groupID
	if(row.site_option_type_id EQ 7){
		optionStruct=deserializeJson(row.site_option_type_json);
		if(structkeyexists(optionStruct, 'selectmenu_groupid') and optionStruct.selectmenu_groupid NEQ ""){
			rs=getOptionGroupById(sourceStruct, optionStruct.selectmenu_groupid);
			
			if(rs.success){
				groupNameList=arrayToList(getFullGroupPath(sourceStruct, rs.struct.site_option_group_parent_id, rs.struct.site_option_group_name), chr(9));
				
				selectGroupStruct=getOptionGroupByName(destinationStruct, groupNameList, true);
				optionStruct.selectmenu_groupid=toString(selectGroupStruct.struct.site_option_group_id);
			}else{
				echo("Warning: selectmenu_groupid, ""#optionStruct.selectmenu_groupid#"", doesn't exist in source. The site option, #row.site_option_name# will be imported, but it must be manually corrected.");
				optionStruct.selectmenu_groupid='';
			}
		}
		row.site_option_type_json=serializeJson(optionStruct);
		//row.zsite_option_type_json=row.site_option_type_json;
	}
	
	if(not arguments.skipIdRemap){
		groupNameList="0";
		if(row.site_option_group_id NEQ 0){
			groupNameList=sourceStruct.optionGroupNameLookupById[row.site_option_group_id];
			rs=getOptionGroupByName(destinationStruct, groupNameList, true);
			row.site_option_group_id=rs.struct.site_option_group_id;
		}
		
		// this should work with site_option_group_id 0 as well.
		optionStruct=getOptionByName(destinationStruct, groupNameList, row.site_option_name, true);
		row.site_option_id=optionStruct.struct.site_option_id;
	}
	row.site_id = request.zos.globals.id;
	return row;
	</cfscript>
</cffunction>

 

<cffunction name="remapOptionGroup" localmode="modern" returntype="struct">
	<cfargument name="source" type="struct" required="yes">
	<cfargument name="destination" type="struct" required="yes">
	<cfargument name="sourceOptionGroupId" type="numeric" required="yes">
	<cfargument name="skipGroupIdRemap" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	sourceStruct=arguments.source;
	destinationStruct=arguments.destination;
	row=sourceStruct.optionGroupStruct[arguments.sourceOptionGroupId];
	
	// find the user_group_id in destination site
	if(row.site_option_group_user_group_id_list NEQ ""){
		userGroupStruct=deserializeJson(row.userGroupNameJSON);
		arrId=[];
		arrMissingId=[];
		for(n in userGroupStruct){
			try{
				arrayAppend(arrId, variables.userGroupCom.getGroupId(n, request.zos.globals.id)); 
			}catch(Any excpt){
				arrayAppend(arrMissingId, n);
			}
		}
		if(arrayLen(arrMissingId)){
			throw("One of more user groups were missing and are required before sync can be completed: "&arrayToList(arrMissingId, ", "));
		}
		row.site_option_group_user_group_id_list=arrayToList(arrId,",");
		//row.zsite_option_group_user_group_id_list=arrayToList(arrId,",");
	}
	if(row.inquiries_type_id NEQ 0){
		tempSiteId=application.zcore.functions.zGetSiteIdFromSiteIDType(row.inquiries_type_id_siteIDType);
		db.sql="select * from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(tempSiteId)# and 
		inquiries_type_deleted = #db.param(0)# and 
		inquiries_type_name = #db.param(row.inquiriesTypeName)#";
		qType=db.execute("qType");
		if(qType.recordcount EQ 0){
			throw("inquiries_type_id with name, ""#row.inquiriesTypeName#"", doesn't exist, and it is required.");
		}
		row.inquiries_type_id = qType.inquiries_type_id;
		//row.zinquiries_type_id = qType.inquiries_type_id;
	}
	if(not arguments.skipGroupIdRemap){
		groupStruct=getOptionGroupById(sourceStruct, row.site_option_group_id);
		if(groupStruct.success){
			groupNameList=arrayToList(getFullGroupPath(sourceStruct, groupStruct.struct.site_option_group_parent_id, row.site_option_group_name), chr(9));
		}else{
			groupNameList=row.site_option_group_name;
		}
		if(row.site_option_group_parent_id NEQ 0){
			parentGroupStruct=getOptionGroupById(sourceStruct, row.site_option_group_parent_id);
			if(parentGroupStruct.success){
				
				parentGroupNameList=arrayToList(getFullGroupPath(sourceStruct, parentGroupStruct.struct.site_option_group_parent_id, parentGroupStruct.struct.site_option_group_name), chr(9));
			}else{
				parentGroupNameList="";
			}
			rs=getOptionGroupByName(destinationStruct, parentGroupNameList, true);
			if(rs.success){
				row.site_option_group_parent_id=rs.struct.site_option_group_id;
			}else{
				row.site_option_group_parent_id=0;
			}
		}
		rs=getOptionGroupByName(destinationStruct, groupNameList, true);
		row.site_option_group_id=rs.struct.site_option_group_id;
	}
	row.site_id = request.zos.globals.id;
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


<cffunction name="getFullGroupPath" localmode="modern" returntype="array">
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
		if(currentParentId EQ 0 or not structkeyexists(arguments.struct.optionGroupStruct, currentParentId)){
			break;
		}else{ 
			currentName=arguments.struct.optionGroupStruct[currentParentId].site_option_group_name;
			currentParentId=arguments.struct.optionGroupStruct[currentParentId].site_option_group_parent_id; 
		}
		i++;
		if( i GT 100){
			throw("infinite loop detected with arguments.parentId=""#arguments.parentId#"" and arguments.name=""#arguments.name#"".");
		}
	}
	return arrParent;
	</cfscript>
</cffunction>

<cffunction name="getOptionFieldChanges" localmode="modern">
	<cfargument name="source" type="struct" required="yes">
	<cfargument name="destination" type="struct" required="yes">
	<cfscript>
	sourceStruct=arguments.source;
	destinationStruct=arguments.destination;
	changedFields={};    
	changedGroups={};
	newGroups={};
	extraGroups={};
	newFields={};
	extraFields={};
	
	for(i in sourceStruct.optionGroupNameStruct){
		groupId=sourceStruct.optionGroupNameStruct[i];
		
		groupChanged=false; 
		if(structkeyexists(destinationStruct.optionGroupNameStruct, i)){
			newGroupStruct=remapOptionGroup(sourceStruct, destinationStruct, groupId);
			currentDestinationStruct=destinationStruct.optionGroupStruct[destinationStruct.optionGroupNameStruct[i]];
			structdelete(newGroupStruct, 'site_option_group_updated_datetime');
			structdelete(currentDestinationStruct, 'site_option_group_updated_datetime');
			if(not objectequals(newGroupStruct, currentDestinationStruct)){
				if(form.debugEnabled){
					echo("changed group: "&i&"<br>");	
					echo('<div style="width:500px;float:left;">');
					writedump(newGroupStruct);
					echo('</div><div style="width:500px;float:left;">');
					writedump(currentDestinationStruct);
					echo('</div>
					<hr style="clear:both;"/>');
				}
				changedGroups[i]=newGroupStruct;
			}
		}else{
			// new group - need to translate to the destination ids...
			newGroups[i]=remapOptionGroup(sourceStruct, destinationStruct, groupId);
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
					sourceFieldStruct=remapOption(sourceStruct, destinationStruct, optionId);
					destinationFieldStruct=destinationStruct.optionStruct[destinationStruct.optionNameStruct[i][n]];
					structdelete(sourceFieldStruct, 'site_option_updated_datetime');
					structdelete(destinationFieldStruct, 'site_option_updated_datetime');
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
				newFields[i][n]=remapOption(sourceStruct, destinationStruct, optionId);
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
						extraFields[i][n]=destinationStruct.optionStruct[optionId];
					}
				}
			}
		}
	}
	
	if(form.deleteEnabled EQ 1){
		for(i in destinationStruct.optionGroupNameStruct){
			groupId=destinationStruct.optionGroupNameStruct[i];
			if(structkeyexists(sourceStruct.optionGroupNameStruct, i)){
				continue; // skip, already checked above.
			}else{
				// extra group
				extraGroups[i]=destinationStruct.optionGroupStruct[groupId];
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
		changedGroups: changedGroups,
		extraGroups: extraGroups,
		newGroups: newGroups,
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

<cffunction name="updateOption" localmode="modern">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="new" type="boolean" required="yes">
	<cfscript>
	throw("updateOption not implemented.");
	abort;
	db=request.zos.queryObject;
	arguments.row.site_option_updated_datetime = request.zos.mysqlnow;
	if(arguments.new){
		arrSQL=["INSERT INTO #db.table("site_option", request.zos.zcoreDatasource)# SET "];
		for(i in arguments.row){
			if(i NEQ "site_option_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE site_id = #db.param(arguments.row.site_id)# and 
		site_option_deleted = #db.param(0)# and
		site_option_id = #db.param(arguments.row.site_option_id)# ";
		result=db.insert("qOptionInsert", request.zos.insertIDColumnForSiteIDTable);
		if(rs.success){
			return rs.result;
		}else{
			throw("Failed to create site_option");	
		}
	}else{
		arrSQL=["UPDATE #db.table("site_option", request.zos.zcoreDatasource)# SET"];
		for(i in arguments.row){
			if(i NEQ "site_id" or i NEQ "site_option_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE site_id = #db.param(arguments.row.site_id)# and 
		site_option_deleted = #db.param(0)# and
		site_option_id = #db.param(arguments.row.site_option_id)# ";
		return db.execute("qOptionUpdate");
	}
	</cfscript>
</cffunction>


<cffunction name="updateOptionGroup" localmode="modern">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="new" type="boolean" required="yes">
	<cfscript>
	throw("updateOptionGroup not implemented.");
	abort;
	db=request.zos.queryObject;
	arguments.row.site_option_group_updated_datetime = request.zos.mysqlnow;
	if(arguments.new){
		arrSQL=["INSERT INTO #db.table("site_option_group", request.zos.zcoreDatasource)# SET "];
		for(i in arguments.row){
			if(i NEQ "site_option_group_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE site_id = #db.param(arguments.row.site_id)# and 
		site_option_group_deleted = #db.param(0)# and
		site_option_group_id = #db.param(arguments.row.site_option_group_id)# ";
		result=db.insert("qOptionGroupInsert", request.zos.insertIDColumnForSiteIDTable);
		if(rs.success){
			return rs.result;
		}else{
			throw("Failed to create site_option_group");	
		}
	}else{
		arrSQL=["UPDATE #db.table("site_option_group", request.zos.zcoreDatasource)# SET"];
		for(i in arguments.row){
			if(i NEQ "site_id" or i NEQ "site_option_group_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE site_id = #db.param(arguments.row.site_id)# and 
		site_option_group_deleted = #db.param(0)# and
		site_option_group_id = #db.param(arguments.row.site_option_group_id)# ";
		return db.execute("qOptionGroupUpdate");
	}
	</cfscript>
</cffunction>
<!--- 
<cffunction name="updateOptionGroupMap" localmode="modern">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="new" type="boolean" required="yes">
	<cfscript>
	throw("updateOptionGroupMap not implemented.");
	abort;
	db=request.zos.queryObject;
	arguments.row.site_option_group_map_updated_datetime = request.zos.mysqlnow;
	if(arguments.new){
		arrSQL=["INSERT INTO #db.table("site_option_group_map", request.zos.zcoreDatasource)# SET "];
		for(i in arguments.row){
			if(i NEQ "site_option_group_map_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE site_id = #db.param(arguments.row.site_id)# and 
		site_option_group_map_deleted = #db.param(0)# and
		site_option_group_map_id = #db.param(arguments.row.site_option_group_map_id)# ";
		result=db.insert("qOptionGroupMapInsert", request.zos.insertIDColumnForSiteIDTable);
		if(rs.success){
			return rs.result;
		}else{
			throw("Failed to create site_option_group_map");	
		}
	}else{
		arrSQL=["UPDATE #db.table("site_option_group_map", request.zos.zcoreDatasource)# SET"];
		for(i in arguments.row){
			if(i NEQ "site_id" or i NEQ "site_option_group_map_id"){
				arrayPrepend(arrSQL, "`"&i&"` = "&db.param(arguments.row[i]));
			}
		}
		db.sql=arrayToList(arrSQL, " ")&" 
		WHERE site_id = #db.param(arguments.row.site_id)# and 
		site_option_group_map_deleted = #db.param(0)# and 
		site_option_group_map_id = #db.param(arguments.row.site_option_group_map_id)# ";
		return db.execute("qOptionGroupMapUpdate");
	}
	</cfscript>
</cffunction> --->

<!--- 
<cffunction name="remapOptionGroupMap" localmode="modern" returntype="struct">
	<cfargument name="source" type="struct" required="yes">
	<cfargument name="destination" type="struct" required="yes">
	<cfargument name="sourceOptionGroupMapId" type="numeric" required="yes">
	<cfscript>
	sourceStruct=arguments.source;
	destinationStruct=arguments.destination; 
	
	row=sourceStruct.optionGroupMapStruct[arguments.sourceOptionGroupMapId];
	
	
	groupNameList=sourceStruct.optionGroupNameLookupById[row.site_option_group_id];
		
	sourceGroupStruct=getOptionGroupByName(sourceStruct, groupNameList, true);
	
	destinationGroupStruct=getOptionGroupByName(destinationStruct, groupNameList, true);
	
	row.site_option_group_id=destinationGroupStruct.struct.site_option_group_id;
	
	// remap site_option_id
	sourceOption=getOptionById(sourceStruct, row.site_option_id);
	if(not sourceOption.success){
		return {success:false, errorMessage:"skipping source where row.site_option_id = ""#row.site_option_id#""<br />" };
	}
	destinationOptionStruct=getOptionByName(destinationStruct, groupNameList, sourceOption.struct.site_option_name, true);
	row.site_option_id=destinationOptionStruct.struct.site_option_id;
	
	// remap site_option_group_map_fieldname if this site_option_id is mapped to a site_option_group_id
	if(sourceGroupStruct.struct.site_option_group_map_group_id NEQ 0){
		if(structkeyexists(sourceStruct.optionGroupNameLookupById, sourceGroupStruct.struct.site_option_group_map_group_id)){
			return {success:false, errorMessage:"can't map due to missing site_option_group_map_group_id, #sourceGroupStruct.struct.site_option_group_map_group_id#, in source<br />" };
		}
		groupNameList2=sourceStruct.optionGroupNameLookupById[sourceGroupStruct.struct.site_option_group_map_group_id];
		// remap site_option_id
		sourceOption2=getOptionById(sourceStruct, row.site_option_group_map_fieldname);
		if(not sourceOption2.success){
			return {success:false, errorMessage:"can't map due to missing site_option_id, #row.site_option_group_map_fieldname#, in source<br />" };
		}else{
			destinationOptionStruct2=getOptionByName(destinationStruct, groupNameList2, sourceOption2.struct.site_option_name, true);
			// site_option_group_map_fieldname is a field in the site_option_group_map_group_id field of the current site_option_group_id
			row.site_option_group_map_fieldname=destinationOptionStruct2.struct.site_option_id;
		}
	}
	row.site_option_group_map_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
	row.site_id=request.zos.globals.id;
	return {success:true, struct:row };
	</cfscript>
</cffunction> --->


<cffunction name="exportData" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Server Manager");
	variables.userGroupCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.user_group_admin");
	header name="Content-Type" value="text/plain" charset="utf-8";
	if(request.zos.isTestServer){
		fileName="test-";
	}else{
		fileName="live-";
	}
	fileName&="sync-json-";
	fileName&=application.zcore.functions.zUrlEncode(request.zos.globals.shortDomain)&".txt";

	if(structkeyexists(form, 'download')){
		header name="Content-Disposition" value="attachment; filename=#fileName#" charset="utf-8";
	}
	
	
	// later I would load sourceDataStruct from external json.js file instead of database when comparing and importing structure changes.
	sourceDataStruct=getOptionDataFromDatabase();
	
	/*
	don't use menu, slideshow or other features yet in theme - too complex.
		make them with site_option_group instead.
	
	menuDataStruct=getMenuDataFromDatabase();
	
	slideshowDataStruct=getSlideshowDataFromDatabase();
	
	slideshowDataStruct=getSlideshowDataFromDatabase();
	
	*/
	
	
	sourceJsonString=serializeJSON(sourceDataStruct);
	echo(sourceJsonString);
	application.zcore.functions.zabort();
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
	if(structcount(fieldChangeStruct.newGroups)){
		echo('<h2>Site Option Groups that will be added</h2>
		<table class="table-list">
		');
		hasChanges=true; 
		arrKey=structkeyarray(fieldChangeStruct.newGroups);
		arraySort(arrKey, "text", "asc"); 
		for(g=1;g LTE arrayLen(arrKey);g++){
			i=arrKey[g];
			echo('<tr><td>'&replace(i, chr(9), " &rarr; ", "all")&"</td></tr>");
		}
		echo('</table><br />');
	}
	if(structcount(fieldChangeStruct.changedGroups)){
		echo('<h2>Site Option Groups that will be updated</h2>
		<table class="table-list">');
		hasChanges=true;
		arrKey=structkeyarray(fieldChangeStruct.changedGroups);
		arraySort(arrKey, "text", "asc");
		for(g=1;g LTE arrayLen(arrKey);g++){
			i=arrKey[g];
			echo('<tr><td>'&replace(i, chr(9), " &rarr; ", "all")&"</td></tr>");
		}
		echo('</table><br />');
	}
	if(structcount(fieldChangeStruct.extraGroups)){
		echo('<h2>Site Option Groups that will be deleted.</h2>
		<table class="table-list">');
		hasChanges=true;
		arrKey=structkeyarray(fieldChangeStruct.extraGroups);
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
		echo('<h2>Site Options that will be added</h2>
		<table class="table-list">');
		hasChanges=true;
		echo(arrayToList(arrF, " "));
		echo('</table><br />');
	}
	arrF=[];
	arrKey=structkeyarray(fieldChangeStruct.changedGroups);
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
		echo('<h2>Site Options that will be updated</h2>
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
		echo('<h2>Site Options that will be deleted</h2>
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
	
	
	arrKey=structkeyarray(fieldChangeStruct.extraGroups);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		groupId=destinationStruct.optionGroupNameStruct[i];
		if(form.debugEnabled){
			echo("delete site_option_group where site_option_group_id=#groupId#<br>");
		}else{
			application.zcore.siteOptionCom.deleteGroupRecursively(groupId, false);
		}
	}
	arrKey=structkeyarray(fieldChangeStruct.extraFields);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		for(n in fieldChangeStruct.extraFields[i]){
			optionId=destinationStruct.optionNameStruct[i][n];
			if(form.debugEnabled){
				echo("delete site_option_group where site_option_id=#optionId#<br>");
			}else{
				if(i EQ 0){
					db.sql="select * from #db.table("site_x_option", request.zos.zcoreDatasource)# s1,
					#db.table("site_option", request.zos.zcoreDatasource)# s2
					where s1.site_option_id = #db.param(optionId)# and 
					s1.site_id = #db.param(request.zos.globals.id)# and 
					s1.site_x_option_deleted = #db.param(0)# and 
					s2.site_option_deleted = #db.param(0)# and
					s1.site_id = s2.site_id and 
					s1.site_option_id = s2.site_option_id ";
					qSiteXOption=db.execute("qSiteXOption");
					for(row in qSiteXOption){
						optionStruct=deserializeJson(row.site_option_type_json); 
						currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id);
						if(currentCFC.hasCustomDelete()){
							// call delete on optionType
							currentCFC.onDelete(row, optionStruct);
						}
					}
					db.sql="delete from #db.param("site_x_option", request.zos.zcoreDatasource)# 
					where site_option_id = #db.param(optionId)# and 
					site_x_option_deleted = #db.param(0)# and
					site_id = #db.param(request.zos.globals.id)#";
					db.execute("qDelete");
				}else{
					db.sql="select * from #db.table("site_x_option_group", request.zos.zcoreDatasource)# site_x_option_group, 
					#db.table("site_option", request.zos.zcoreDatasource)# site_option 
					where site_x_option_group.site_option_id = #db.param(optionId)# and 
					site_x_option_group.site_id = #db.param(request.zos.globals.id)# and 
					site_x_option_group_deleted = #db.param(0)# and 
					site_option_deleted = #db.param(0)# and
					site_x_option_group.site_option_id = site_option.site_option_id and 
					site_x_option_group.site_id = site_option.site_id ";
					qSiteXOptionGroup=db.execute("qSiteXOptionGroup");
					for(row in qSiteXOptionGroup){
						optionStruct=deserializeJson(row.site_option_type_json); 
						currentCFC=application.zcore.siteOptionCom.getTypeCFC(row.site_option_type_id);
						if(currentCFC.hasCustomDelete()){
							// call delete on optionType
							currentCFC.onDelete(row, optionStruct);
						}
					}
					db.sql="delete from #db.table("site_x_option_group", request.zos.zcoreDatasource)# 
					where site_option_id = #db.param(optionId)# and 
					site_x_option_group_deleted = #db.param(0)# and
					site_id = #db.param(request.zos.globals.id)#";
					db.execute("qDelete");
				} 
				
				/*db.sql="delete from #db.table("site_option_group_map", request.zos.zcoreDatasource)# 
				where site_option_id = #db.param(optionId)# and 
				site_id = #db.param(request.zos.globals.id)#";
				db.execute("qDelete");*/
				
				db.sql="delete from #db.table("site_option", request.zos.zcoreDatasource)# 
				WHERE site_option_id=#db.param(optionId)# and 
				site_option_deleted = #db.param(0)# and
				site_id = #db.param(request.zos.globals.id)# ";
				db.execute("qDeleteOption");
			}
		}
	}
	
	arrKey=structkeyarray(fieldChangeStruct.newGroups);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		ts={};
		ts.table="site_option_group";
		ts.enableReplace=true;
		ts.struct=fieldChangeStruct.newGroups[i];
		ts.struct.site_option_group_updated_datetime=request.zos.mysqlnow;
		ts.datasource=request.zos.zcoreDatasource;
		ts.forcePrimaryInsert={
			"site_option_group_id":true,
			"site_id":true
		};
		if(form.debugEnabled){
			echo("insert site_option_group<br />");
			writedump(ts);
		}else{
			application.zcore.functions.zInsert(ts);
		}
	}
	arrKey=structkeyarray(fieldChangeStruct.changedGroups);
	arraySort(arrKey, "text", "asc");
	for(g=1;g LTE arrayLen(arrKey);g++){
		i=arrKey[g];
		ts={};
		ts.table="site_option_group";
		ts.struct=fieldChangeStruct.changedGroups[i];
		ts.struct.site_option_group_updated_datetime=request.zos.mysqlnow;
		ts.datasource=request.zos.zcoreDatasource;
		if(form.debugEnabled){
			echo("update site_option_group<br>");
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
			ts.table="site_option";
			ts.enableReplace=true;
			ts.struct=fieldChangeStruct.newFields[i][n];
			ts.struct.site_option_updated_datetime=request.zos.mysqlnow;
			ts.datasource=request.zos.zcoreDatasource;
			ts.forcePrimaryInsert={
				"site_option_id":true,
				"site_id":true
			};
			if(form.debugEnabled){
				echo("insert site_option<br>");
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
			ts.table="site_option";
			ts.struct=fieldChangeStruct.changedFields[i][n];
			ts.struct.site_option_updated_datetime=request.zos.mysqlnow;
			ts.datasource=request.zos.zcoreDatasource;
			if(form.debugEnabled){
				echo("update site_option<br>");
				writedump(ts);
			}else{
				application.zcore.functions.zUpdate(ts);
			}
		}
	}
	/*
	if(structcount(sourceStruct.optionGroupMapStruct)){
		groupIdStruct={};
		for(i in sourceStruct.optionGroupMapStruct){
			mapStruct=remapOptionGroupMap(sourceStruct, destinationStruct, i);
			if(mapStruct.success){
				groupIdStruct[mapStruct.struct.site_option_group_id]=true;
				ts={};
				ts.table="site_option_group_map";
				ts.struct=mapStruct.struct;
				ts.struct.site_option_group_map_updated_datetime=request.zos.mysqlnow;
				ts.datasource=request.zos.zcoreDatasource;
				if(form.debugEnabled){
					echo("insert site_option_group_map<br>");
					writedump(ts);
				}else{
					application.zcore.functions.zInsert(ts);
				}
			}
		}
		arrGroup=structkeyarray(groupIdStruct);
		idlist="'"&arrayToList(arrGroup, "','")&"'";
		if(arrayLen(arrGroup)){
			if(form.debugEnabled){
				echo("remove site_option_group_map records that weren't updated where site_option_group_id in (#idlist#)<br>");
			}else{
				db.sql="delete from #db.table("site_option_group_map", request.zos.zcoreDatasource)# 
				where site_option_group_map_updated_datetime < #db.param(request.zos.mysqlnow)# and 
				site_option_group_map_deleted = #db.param(0)# and
				site_id=#db.param(request.zos.globals.id)# and 
				site_option_group_id IN (#db.trustedSQL(idlist)#)";
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
		
		application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id);
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
	
	request.nextOptionStruct={};
	request.nextOptionGroupStruct={};

	db.sql="select IF(ISNULL(MAX(site_option_id)), #db.param(0)#, MAX(site_option_id)) id from 
	#db.table("site_option", request.zos.zcoredatasource)# 
	where site_id = #db.param(request.zos.globals.id)# and 
	site_option_deleted = #db.param(0)#";
	qOptionId=db.execute("qOptionId");
	request.nextOptionId=qOptionId.id+1;
	
	db.sql="select IF(ISNULL(MAX(site_option_group_id)), #db.param(0)#, MAX(site_option_group_id)) id from 
	#db.table("site_option", request.zos.zcoredatasource)# 
	where site_id = #db.param(request.zos.globals.id)# and 
	site_option_deleted = #db.param(0)# ";
	qOptionGroupId=db.execute("qOptionGroupId");
	request.nextOptionGroupId=qOptionGroupId.id+1;
	
	
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
	variables.userGroupCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.user.user_group_admin");
	sourceDataStruct=deserializeJSON(sourceJsonString);
	sourceStruct=getOptionMappedData(sourceDataStruct);
	
	destinationDataStruct=getOptionDataFromDatabase();
	destinationStruct=getOptionMappedData(destinationDataStruct);
	
	fieldChangeStruct=getOptionFieldChanges(sourceStruct, destinationStruct);
	
	if(form.finalize EQ 0){
		preview(fieldChangeStruct, sourceStruct, destinationStruct);
	}else{
		import(fieldChangeStruct, sourceStruct, destinationStruct);
	}
	/*if(form.debugEnabled){ 
		writedump("The following new ids were created and their data was not fully mapped to them yet.");
		writedump(request.nextOptionStruct);
		writedump(request.nextOptionGroupStruct);
	}*/
	// site_option_app is missing from this code - so any customizations for blog & content records would be lost in a theme export/import.
	
	</cfscript>
</cffunction>

<cffunction name="init" access="private" localmode="modern">
	<cfscript>
	optionGroupCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.admin.controller.site-option-group");
	optionGroupCom.displayoptionAdminNav();
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
	<p>Allows import/export of configuration data for site options system.   <!--- Coming soon: sync for menus, slideshows, site globals, app configuration, and more. ---></p>
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