<cfcomponent>
<cfoutput>

<cffunction name="init" access="public" localmode="modern">
	<cfscript>
	// name lookup, to verify all types are valid;
	request.typeStruct={ 
		// group means sub-group
		"Schema":{id:0},
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
		"Radio Schema":{id:14, radio_delimiter:"|", radio_labels:"Yes|No", radio_values:"Yes|No"},
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
		arrField=listToArray(arrField[1], "&");
		for(i in arrField){
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
 
<cffunction name="importSchema" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;

	application.zcore.functions.zStatusHandler(request.zsid, true);
	 
	</cfscript>
	<h2>Import Schema</h2>
	<p>Note: The JSON format is usually generated via the widget project by merging many properly named sections into one larger structure and then pasting that here.</p>
	<form action="/z/feature/admin/feature-import/processImportSchema" method="post">
		<h3>Add to existing group:</h3>
		<p><cfscript>
		// consider having all groups with parent -> child selection 
		db.sql="select * from #db.table("feature_schema", "jetendofeature")# 
		WHERE feature_schema_deleted=#db.param(0)# and 
		feature_id=#db.param(form.feature_id)# 
		ORDER BY feature_schema_display_name";
		qSchema=db.execute("qSchema"); 
		groupStruct={};
		for(row in qSchema){
			groupStruct[row.feature_schema_id]=row;
		} 
		groupPathStruct={};
		for(groupId in groupStruct){
			row=groupStruct[groupId];
			limitCount=0;
			arrName=[];
			arrayPrepend(arrName, row.feature_schema_display_name);
			currentSchemaId=row.feature_schema_parent_id;
			while(true){
				// lookup parent groups until reaching zero
				if(currentSchemaId NEQ 0){
					tempSchema=groupStruct[row.feature_schema_parent_id]
					arrayPrepend(arrName, tempSchema.feature_schema_display_name);
					currentSchemaId=tempSchema.feature_schema_parent_id;
				}else{
					break;
				}
				limitCount++;
				if(limitCount GT 100){
					throw("Possible infinite loop detected in feature_schema_id: #row.feature_schema_id#");
				}
			}
			groupPathStruct[row.feature_schema_id]={
				id:row.feature_schema_id,
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

		db.sql="select * from #db.table("feature_schema", "jetendofeature")# 
		WHERE feature_schema_deleted=#db.param(0)# and 
		feature_schema_parent_id=#db.param(0)# and 
		feature_id=#db.param(form.feature_id)# 
		ORDER BY feature_schema_display_name";
		qSchema=db.execute("qSchema");
		ts.query = qSchema;
		ts.name="feature_schema_id";
		ts.listLabels = arrayToList(arrLabel, chr(9));
		ts.listValues = arrayToList(arrValue, chr(9));
		ts.listLabelsDelimiter = chr(9); 
		ts.listValuesDelimiter = chr(9);
		application.zcore.functions.zInputSelectBox(ts);
		</cfscript></p>
		<h3>Or type Schema Name to create a group</h3>

		<p>Schema Name: <input type="text" name="groupName" value="#application.zcore.functions.zso(form, 'groupName')#" /></p>
		<p>Public Form #application.zcore.functions.zInput_Boolean("publicForm")#</p>
		<p>Schema/Field Field JSON:<br><textarea name="fieldData" cols="100" rows="10">#application.zcore.functions.zso(form, 'fieldData')#</textarea></p> 
		<p><input type="submit" name="Submit1" value="Import Schema"> <input type="button" name="cancel1" value="Cancel" onclick="window.location.href='/z/feature/admin/feature-schema/index';"></p> 
	</form>
</cffunction>

<cffunction name="processImportSchema" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	init();
	form.publicForm=application.zcore.functions.zso(form, 'publicForm', true, 0);
	form.groupName=application.zcore.functions.zso(form, 'groupName');
	form.fieldData=application.zcore.functions.zso(form, 'fieldData');
	form.feature_schema_id=application.zcore.functions.zso(form, 'feature_schema_id', true, 0);
	if((form.feature_schema_id EQ 0 and form.groupName EQ "") or form.fieldData EQ ""){
		application.zcore.status.setStatus(request.zsid, "Schema name and JSON are required", form, true);
		application.zcore.functions.zRedirect("/z/feature/admin/feature-import/importSchema?zsid=#request.zsid#");
	}
	if(form.feature_schema_id NEQ 0){

		db.sql="SELECT * FROM #db.table("feature_schema", "jetendofeature")# 
		WHERE 
		feature_schema_deleted=#db.param(0)# and 
		feature_schema_id=#db.param(form.feature_schema_id)# and 
		feature_id=#db.param(form.feature_id)# ";
		qG=db.execute("qG");
		if(qG.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid group", form, true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-import/importSchema?zsid=#request.zsid#");
		}
		parentId=qG.feature_schema_parent_id;
		form.groupName=qG.feature_schema_display_name;
	}else{
		db.sql="SELECT * FROM #db.table("feature_schema", "jetendofeature")# 
		WHERE 
		feature_schema_parent_id=#db.param(0)# and 
		feature_schema_deleted=#db.param(0)# and 
		feature_schema_variable_name=#db.param(form.groupName)# and 
		feature_id=#db.param(form.feature_id)# ";
		qG=db.execute("qG");
		if(qG.recordcount NEQ 0){
			application.zcore.status.setStatus(request.zsid, "This group already exists", form, true);
			application.zcore.functions.zRedirect("/z/feature/admin/feature-import/importSchema?zsid=#request.zsid#");
		}
		parentId=0;
	}
	cs=deserializeJson(form.fieldData);
	csNew={};
	gs=processSchema(cs, csNew); 
	if(form.feature_schema_id NEQ 0){
		for(i=1;i<=arrayLen(gs.arrSchema);i++){
			currentSchemaName=gs.arrSchema[i].groupName; 
			db.sql="SELECT * FROM #db.table("feature_schema", "jetendofeature")# 
			WHERE 
			feature_schema_parent_id=#db.param(form.feature_schema_id)# and 
			feature_schema_deleted=#db.param(0)# and 
			feature_schema_variable_name=#db.param(currentSchemaName)# and 
			feature_id=#db.param(form.feature_id)# ";
			qCheck=db.execute("qCheck"); 
			if(qCheck.recordcount NEQ 0){
				application.zcore.status.setStatus(request.zsid, "There is already a sub-group called ""#currentSchemaName#"".  Sub-group names must be unique.", form, true);
				application.zcore.functions.zRedirect("/z/feature/admin/feature-import/importSchema?zsid=#request.zsid#");
			} 
		}
	} 
	//writedump(gs);	writedump(cs);  	abort;
	if(form.feature_schema_id NEQ 0){
		addToSchema(gs, form.feature_schema_id, parentId, form.publicForm);
	}else{
		insertSchema(gs, form.groupName, parentId, form.publicForm);
	}

	//echo('stop');	abort;
	 
	application.zcore.functions.zOS_cacheSiteAndUserSchemas(request.zos.globals.id); 

	application.zcore.status.setStatus(request.zsid, "Schema, ""#form.groupName#"", was imported successfully");
	application.zcore.functions.zRedirect("/z/feature/admin/feature-schema/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="addToSchema" access="public" localmode="modern">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="groupId" type="string" required="yes">
	<cfargument name="parentSchemaId" type="string" required="yes">
	<cfargument name="publicForm" type="string" required="yes">
	<cfscript>
	gs=arguments.groupStruct; 
	//writedump(ts);
	mainSchemaId=arguments.groupId; 
	sortIndex=1; 
	for(option in gs.arrField){
		ts={
			table:"feature_field",
			datasource:"jetendofeature",
			struct:{
				site_id:request.zos.globals.id,
				feature_schema_id:mainSchemaId,
				feature_field_type_id:option.typeId,
				feature_field_variable_name:option.fieldName,
				feature_field_default_value:option.defaultValue,
				feature_field_display_name:option.fieldName,
				feature_field_required:option.required,
				feature_field_deleted:0,
				feature_field_allow_public:arguments.publicForm,
				feature_field_updated_datetime:request.zos.mysqlnow,
				feature_field_type_json:serializeJson(option.options),
				feature_field_sort:sortIndex
			}
		}
		//writedump(ts);
		application.zcore.functions.zInsert(ts);
		sortIndex++;  
	} 
	for(group in gs.arrSchema){
		insertSchema(group.fieldStruct, group.groupName, mainSchemaId, arguments.publicForm);
	}
	</cfscript>
</cffunction>

<cffunction name="insertSchema" access="public" localmode="modern">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="groupName" type="string" required="yes">
	<cfargument name="parentSchemaId" type="string" required="yes">
	<cfargument name="publicForm" type="string" required="yes">
	<cfscript>
	gs=arguments.groupStruct;
	ts={
		table:"feature_schema",
		datasource:"jetendofeature",
		struct:{
			site_id:request.zos.globals.id,
			feature_schema_parent_id:arguments.parentSchemaId,
			feature_schema_variable_name:arguments.groupName,
			feature_schema_type:1,
			feature_schema_display_name:arguments.groupName,
			feature_schema_deleted:0, 
			feature_schema_updated_datetime:request.zos.mysqlnow,
			feature_schema_allow_public:arguments.publicForm
		}
	}
	//writedump(ts);
	mainSchemaId=application.zcore.functions.zInsert(ts);
	if(not mainSchemaId){
		throw("Schema already exists: #form.groupName#");
	}

	sortIndex=1; 
	for(option in gs.arrField){
		ts={
			table:"feature_field",
			datasource:"jetendofeature",
			struct:{
				site_id:request.zos.globals.id,
				feature_schema_id:mainSchemaId,
				feature_field_type_id:option.typeId,
				feature_field_variable_name:option.fieldName,
				feature_field_default_value:option.defaultValue,
				feature_field_display_name:option.fieldName,
				feature_field_required:option.required,
				feature_field_deleted:0,
				feature_field_allow_public:arguments.publicForm,
				feature_field_updated_datetime:request.zos.mysqlnow,
				feature_field_type_json:serializeJson(option.options),
				feature_field_sort:sortIndex
			}
		}
		//writedump(ts);
		application.zcore.functions.zInsert(ts);
		sortIndex++;  
	} 
	for(group in gs.arrSchema){
		insertSchema(group.fieldStruct, group.groupName, mainSchemaId, arguments.publicForm);
	}
	</cfscript>
</cffunction>

<cffunction name="processSchema" access="public" localmode="modern">
	<cfargument name="groupStruct" type="struct" required="yes">
	<cfargument name="csNew" type="struct" required="yes">
	<cfscript>
	csNew=arguments.csNew;
	gs=arguments.groupStruct;
	rs={ 
		arrField:[],
		arrSchema:[]
	}
	for(fieldString in gs){
		defaultValue=gs[fieldString];
		if(isArray(defaultValue)){
			fs=parseFieldType(fieldString, "");
			// add sub-group
			csNew[fs.fieldName]=[]; 
			csNew2={};
			subSchema=processSchema(defaultValue[1], csNew2); 
			arrayAppend(rs.arrSchema, {groupName: fs.fieldName, fieldStruct:subSchema}); 
			for(n=1;n<=fs.repeat;n++){
				arrayAppend(csNew[fs.fieldName], csNew2);
			} 
		}else{
			fs=parseFieldType(fieldString, defaultValue);
			// add field to current group
			csNew[fs.fieldName]=defaultValue;
			arrayAppend(rs.arrField, fs);
		}
	}
	return rs;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>