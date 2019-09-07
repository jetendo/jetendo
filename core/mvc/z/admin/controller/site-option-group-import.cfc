<cfcomponent>
<cfoutput>

<cffunction name="init" access="public" localmode="modern">
	<cfscript>
	// name lookup, to verify all types are valid;
	request.typeStruct={ 
		// group means sub-group
		"Group":{id:0},
		// field:Checkbox:checkbox_delimiter=|&checkbox_labels=Yes|No&checkbox_values=Yes|No
		"Checkbox":{id:8, checkbox_delimiter:"|", checkbox_labels:"Yes|No", checkbox_values:"Yes|No"},
		// field:Color Picker
		"Color Picker":{id:18},
		// field:Country
		"Country":{id:20},
		// field:Date
		"Date":{id:5},
		// field:Date/Time
		"Date/Time":{id:4},
		// field:Email
		"Email":{id:10},
		// field:File
		"File":{id:9},
		// field:Hidden
		"Hidden":{id:12},
		// field:Checkbox:checkbox_delimiter=|&checkbox_labels=Yes|No&checkbox_values=Yes|No
		"HTML Editor":{id:2, editorwidth:600, editorheight:300 },
		// field:HTML Separator:htmlcontent=#urlencodedformat('<h3>Heading</h3>')#
		"HTML Separator":{id:11, htmlcontent:""},
		// field:Image:imagewidth=100&imageheight=100&imagecrop=0
		"Image":{id:3, imagewidth:100, imageheight:100, imagecrop:0},
		// field:Image Library
		"Image Library":{id:23},
		// field:Map Location Picker
		"Map Location Picker":{id:13},
		// field:Number
		"Number":{id:17},
		// field:Checkbox:checkbox_delimiter=|&checkbox_labels=Yes|No&checkbox_values=Yes|No
		"Radio Group":{id:14, radio_delimiter:"|", radio_labels:"Yes|No", radio_values:"Yes|No"},
		// field:Checkbox:checkbox_delimiter=|&checkbox_labels=Yes|No&checkbox_values=Yes|No
		"Select Menu":{id:7, selectmenu_delimiter:"|", selectmenu_labels:"Label1|Label2", selectmenu_values:"Value1|Value2"},
		// field:Slider:slider_from=1&slider_to=10&slider_step=1
		"Slider":{id:22, slider_from:"1", slider_to:"10", slider_step:"1"},
		// field:State
		"State":{id:19}, 
		// field:Text
		"Text":{id:0},
		// field:Time
		"Time":{id:6},
		// field:Textarea:editorwidth2=300&editorheight2=100
		"Textarea":{id:1, editorwidth2:300, editorheight2:100 },
		// field:URL
		"URL":{id:15},
		// field:User Picker
		"User Picker":{id:16}
	};
	</cfscript>
</cffunction>

<!--- field type format:
fieldName:type:required=1&option1=value1&option2=value2
 --->
<cffunction name="parseFieldType" access="public" localmode="modern">
	<cfargument name="field" type="string" required="yes">
	<cfargument name="defaultValue" type="string" required="yes">
	<cfscript>
	arrField=listToArray(arguments.field, ":");
	fieldName=arrField[1];
	arraydeleteat(arrField, 1);
	rs={
		fieldName:fieldName,
		type:"text",
		repeat:1,
		required:0,
		defaultValue:arguments.defaultValue,
		options:{}
	};
	if(arrayLen(arrField) EQ 0){
		// do nothing
	}else if(arrayLen(arrField) EQ 1){
		rs.type=arrField[1];
	}else if(arrayLen(arrField) EQ 2){
		rs.type=arrField[1];
		arraydeleteat(arrField, 1);
		arrOption=listToArray(arrField[1], "&");
		for(i in arrOption){
			arrNV=listToArray(i, "=");
			if(arrNV[1] EQ "repeat"){
				rs.repeat=arrNV[2];
			}else if(arrNV[1] EQ "required"){
				rs.required=1;
			}else{
				rs.options[trim(arrNV[1])]=trim(urldecode(arrNV[2]));
			}
		} 
	}
	if(not structkeyexists(request.typeStruct, rs.type)){
		throw("Invalid type for field: #arguments.field#");
	}else{
		rs.typeId=request.typeStruct[rs.type].id;
	}
	if(rs.type EQ "image" or rs.type EQ "file" or rs.type EQ "User Picker" or rs.type EQ "map location picker"){
		// we don't want image/file defaults
		rs.defaultValue="";
	}
	for(i in rs.options){
		if(i EQ "id"){
			throw("id is an invalid type option for field: #arguments.field#");
		}
		if(not structkeyexists(request.typeStruct[rs.type], i)){
			throw("Invalid type option: #i# for field: #arguments.field#");
		}
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="processSectionData" access="public" localmode="modern">
	<cfargument name="sectionStruct" type="struct" required="yes">
	<cfscript>
	init();
	cs=arguments.sectionStruct; 
	csNew={};
	//echo(serializeJson(cs));
	gs=processGroup(cs, csNew);
	/*writedump(csNew);
	writedump(gs);
	echo(serializeJson(gs));
	abort;*/
	return csNew;
	</cfscript>
</cffunction>


	
<cffunction name="importGroup" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;

	application.zcore.functions.zStatusHandler(request.zsid, true);
	 
	</cfscript>
	<h2>Import Group</h2>
	<p>Note: The JSON format is usually generated via the widget project by merging many properly named sections into one larger structure and then pasting that here.</p>
	<form action="/z/admin/site-option-group-import/processImportGroup" method="post">
		<h3>Add to existing group:</h3>
		<p><cfscript>
		// consider having all groups with parent -> child selection 
		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
		WHERE site_option_group_deleted=#db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# 
		ORDER BY site_option_group_display_name";
		qGroup=db.execute("qGroup"); 
		groupStruct={};
		for(row in qGroup){
			groupStruct[row.site_option_group_id]=row;
		} 
		groupPathStruct={};
		for(groupId in groupStruct){
			row=groupStruct[groupId];
			limitCount=0;
			arrName=[];
			arrayPrepend(arrName, row.site_option_group_display_name);
			currentGroupId=row.site_option_group_parent_id;
			while(true){
				// lookup parent groups until reaching zero
				if(currentGroupId NEQ 0){
					tempGroup=groupStruct[row.site_option_group_parent_id]
					arrayPrepend(arrName, tempGroup.site_option_group_display_name);
					currentGroupId=tempGroup.site_option_group_parent_id;
				}else{
					break;
				}
				limitCount++;
				if(limitCount GT 100){
					throw("Possible infinite loop detected in site_option_group_id: #row.site_option_group_id#");
				}
			}
			groupPathStruct[row.site_option_group_id]={
				id:row.site_option_group_id,
				name:arrayToList(arrName, " -> ")
			};
		}
		arrKey=structsort(groupPathStruct, "text", "asc", "name");
		arrLabel=[];
		arrValue=[];
		for(key in arrKey){
			arrayAppend(arrLabel, groupPathStruct[key].name);
			arrayAppend(arrValue, groupPathStruct[key].id);
		}

		db.sql="select * from #db.table("site_option_group", request.zos.zcoreDatasource)# 
		WHERE site_option_group_deleted=#db.param(0)# and 
		site_option_group_parent_id=#db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# 
		ORDER BY site_option_group_display_name";
		qGroup=db.execute("qGroup");
		ts.query = qGroup;
		ts.name="site_option_group_id";
		ts.listLabels = arrayToList(arrLabel, chr(9));
		ts.listValues = arrayToList(arrValue, chr(9));
		ts.listLabelsDelimiter = chr(9); 
		ts.listValuesDelimiter = chr(9);
		application.zcore.functions.zInputSelectBox(ts);
		</cfscript></p>
		<h3>Or type Group Name to create a group</h3>

		<p>Group Name: <input type="text" name="groupName" value="#application.zcore.functions.zso(form, 'groupName')#" /></p>
		<p>Public Form #application.zcore.functions.zInput_Boolean("publicForm")#</p>
		<p>Group/Option Field JSON:<br><textarea name="fieldData" cols="100" rows="10">#application.zcore.functions.zso(form, 'fieldData')#</textarea></p> 
		<p><input type="submit" name="Submit1" value="Import Group" class="z-manager-search-button"> <input type="button" name="cancel1" value="Cancel" onclick="window.location.href='/z/admin/site-option-group/index';" class="z-manager-search-button"></p> 
	</form>
</cffunction>

<cffunction name="processImportGroup" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	init();
	form.publicForm=application.zcore.functions.zso(form, 'publicForm', true, 0);
	form.groupName=application.zcore.functions.zso(form, 'groupName');
	form.fieldData=application.zcore.functions.zso(form, 'fieldData');
	form.site_option_group_id=application.zcore.functions.zso(form, 'site_option_group_id', true, 0);
	if((form.site_option_group_id EQ 0 and form.groupName EQ "") or form.fieldData EQ ""){
		application.zcore.status.setStatus(request.zsid, "Group name and JSON are required", form, true);
		application.zcore.functions.zRedirect("/z/admin/site-option-group-import/importGroup?zsid=#request.zsid#");
	}
	if(form.site_option_group_id NEQ 0){

		db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
		WHERE 
		site_option_group_deleted=#db.param(0)# and 
		site_option_group_id=#db.param(form.site_option_group_id)# and 
		site_id=#db.param(request.zos.globals.id)# ";
		qG=db.execute("qG");
		if(qG.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid group", form, true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group-import/importGroup?zsid=#request.zsid#");
		}
		parentId=qG.site_option_group_parent_id;
		form.groupName=qG.site_option_group_display_name;
	}else{
		db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
		WHERE 
		site_option_group_parent_id=#db.param(0)# and 
		site_option_group_deleted=#db.param(0)# and 
		site_option_group_name=#db.param(form.groupName)# and 
		site_id=#db.param(request.zos.globals.id)# ";
		qG=db.execute("qG");
		if(qG.recordcount NEQ 0){
			application.zcore.status.setStatus(request.zsid, "This group already exists", form, true);
			application.zcore.functions.zRedirect("/z/admin/site-option-group-import/importGroup?zsid=#request.zsid#");
		}
		parentId=0;
	}
	cs=deserializeJson(form.fieldData);
	csNew={};
	gs=processGroup(cs, csNew); 
	if(form.site_option_group_id NEQ 0){
		for(i=1;i<=arrayLen(gs.arrGroup);i++){
			currentGroupName=gs.arrGroup[i].groupName; 
			db.sql="SELECT * FROM #db.table("site_option_group", request.zos.zcoreDatasource)# 
			WHERE 
			site_option_group_parent_id=#db.param(form.site_option_group_id)# and 
			site_option_group_deleted=#db.param(0)# and 
			site_option_group_name=#db.param(currentGroupName)# and 
			site_id=#db.param(request.zos.globals.id)# ";
			qCheck=db.execute("qCheck"); 
			if(qCheck.recordcount NEQ 0){
				application.zcore.status.setStatus(request.zsid, "There is already a sub-group called ""#currentGroupName#"".  Sub-group names must be unique.", form, true);
				application.zcore.functions.zRedirect("/z/admin/site-option-group-import/importGroup?zsid=#request.zsid#");
			} 
		}
	} 
	//writedump(gs);	writedump(cs);  	abort;
	if(form.site_option_group_id NEQ 0){
		addToGroup(gs, form.site_option_group_id, parentId, form.publicForm);
	}else{
		insertGroup(gs, form.groupName, parentId, form.publicForm);
	}

	//echo('stop');	abort;
	 
	application.zcore.functions.zOS_cacheSiteAndUserGroups(request.zos.globals.id); 

	application.zcore.status.setStatus(request.zsid, "Group, ""#form.groupName#"", was imported successfully");
	application.zcore.functions.zRedirect("/z/admin/site-option-group/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="addToGroup" access="public" localmode="modern">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="groupId" type="string" required="yes">
	<cfargument name="parentGroupId" type="string" required="yes">
	<cfargument name="publicForm" type="string" required="yes">
	<cfscript>
	gs=arguments.groupStruct; 
	//writedump(ts);
	mainGroupId=arguments.groupId; 
	sortIndex=1; 
	for(option in gs.arrOption){
		ts={
			table:"site_option",
			datasource:request.zos.zcoreDatasource,
			struct:{
				site_id:request.zos.globals.id,
				site_option_group_id:mainGroupId,
				site_option_type_id:option.typeId,
				site_option_name:option.fieldName,
				site_option_default_value:option.defaultValue,
				site_option_display_name:option.fieldName,
				site_option_required:option.required,
				site_option_deleted:0,
				site_option_allow_public:arguments.publicForm,
				site_option_updated_datetime:request.zos.mysqlnow,
				site_option_type_json:serializeJson(option.options),
				site_option_sort:sortIndex
			}
		}
		//writedump(ts);
		application.zcore.functions.zInsert(ts);
		sortIndex++;  
	} 
	for(group in gs.arrGroup){
		insertGroup(group.fieldStruct, group.groupName, mainGroupId, arguments.publicForm);
	}
	</cfscript>
</cffunction>

<cffunction name="insertGroup" access="public" localmode="modern">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="groupName" type="string" required="yes">
	<cfargument name="parentGroupId" type="string" required="yes">
	<cfargument name="publicForm" type="string" required="yes">
	<cfscript>
	gs=arguments.groupStruct;
	ts={
		table:"site_option_group",
		datasource:request.zos.zcoreDatasource,
		struct:{
			site_id:request.zos.globals.id,
			site_option_group_parent_id:arguments.parentGroupId,
			site_option_group_name:arguments.groupName,
			site_option_group_type:1,
			site_option_group_display_name:arguments.groupName,
			site_option_group_deleted:0,
			site_option_group_appidlist:",,",
			site_option_group_updated_datetime:request.zos.mysqlnow,
			site_option_group_allow_public:arguments.publicForm
		}
	}
	//writedump(ts);
	mainGroupId=application.zcore.functions.zInsert(ts);
	if(not mainGroupId){
		throw("Group already exists: #form.groupName#");
	}

	sortIndex=1; 
	for(option in gs.arrOption){
		ts={
			table:"site_option",
			datasource:request.zos.zcoreDatasource,
			struct:{
				site_id:request.zos.globals.id,
				site_option_group_id:mainGroupId,
				site_option_type_id:option.typeId,
				site_option_name:option.fieldName,
				site_option_default_value:option.defaultValue,
				site_option_display_name:option.fieldName,
				site_option_required:option.required,
				site_option_deleted:0,
				site_option_allow_public:arguments.publicForm,
				site_option_updated_datetime:request.zos.mysqlnow,
				site_option_type_json:serializeJson(option.options),
				site_option_sort:sortIndex
			}
		}
		//writedump(ts);
		application.zcore.functions.zInsert(ts);
		sortIndex++;  
	} 
	for(group in gs.arrGroup){
		insertGroup(group.fieldStruct, group.groupName, mainGroupId, arguments.publicForm);
	}
	</cfscript>
</cffunction>

<cffunction name="processGroup" access="public" localmode="modern">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="csNew" type="struct" required="yes">
	<cfscript>
	csNew=arguments.csNew;
	gs=arguments.groupStruct;
	rs={ 
		arrOption:[],
		arrGroup:[]
	}
	for(fieldString in gs){
		defaultValue=gs[fieldString];
		if(isArray(defaultValue)){
			fs=parseFieldType(fieldString, "");
			// add sub-group
			csNew[fs.fieldName]=[]; 
			csNew2={};
			subGroup=processGroup(defaultValue[1], csNew2); 
			arrayAppend(rs.arrGroup, {groupName: fs.fieldName, fieldStruct:subGroup}); 
			for(n=1;n<=fs.repeat;n++){
				arrayAppend(csNew[fs.fieldName], csNew2);
			} 
		}else{
			fs=parseFieldType(fieldString, defaultValue);
			// add field to current group
			csNew[fs.fieldName]=defaultValue;
			arrayAppend(rs.arrOption, fs);
		}
	}
	return rs;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>