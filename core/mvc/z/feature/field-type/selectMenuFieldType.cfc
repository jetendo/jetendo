<cfcomponent implements="zcorerootmapping.interface.fieldType">
<cfoutput>
<cffunction name="init" localmode="modern" access="public" output="no">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="siteType" type="string" required="yes">
	<cfscript>
	variables.type=arguments.type;
	variables.siteType=arguments.siteType;
	</cfscript>
</cffunction>

<cffunction name="getDebugValue" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfscript>
	if(application.zcore.functions.zso(arguments.typeStruct.typeStruct, 'selectmenu_values') NEQ ""){
		return listgetat(arguments.typeStruct.typeStruct.selectmenu_values, 1, arguments.typeStruct.typeStruct.selectmenu_delimiter);
	}else{
		return "You need to set this value manually";
	}
	</cfscript>
</cffunction>

<cffunction name="getSearchFieldName" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="setTableName" type="string" required="yes">
	<cfargument name="groupTableName" type="string" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfscript>
	return arguments.groupTableName&".#variables.siteType#_x_option_group_value";
	</cfscript>
</cffunction>
<cffunction name="onBeforeImport" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes"> 
	<cfscript>	
	return { mapData: true, struct: this.buildSelectMap(arguments.typeStruct, false) };
	</cfscript>
</cffunction>

<cffunction name="getSortSQL" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="fieldIndex" type="string" required="yes">
	<cfargument name="sortDirection" type="string" required="yes">
	<cfscript>
	return "sVal"&arguments.fieldIndex&" "&arguments.sortDirection;
	</cfscript>
</cffunction>

<cffunction name="isCopyable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
	</cfscript>
</cffunction>

<cffunction name="isSearchable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
	</cfscript>
</cffunction>

<cffunction name="getSearchFormField" localmode="modern" access="public"> 
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfargument name="value" type="string" required="yes">
	<cfargument name="onChangeJavascript" type="string" required="yes">
	<cfscript> 
	characterWidth=0;
	return variables.createSelectMenu(arguments.row["feature_field_id"], arguments.row["feature_schema_id"], arguments.typeStruct, true, arguments.onChangeJavascript, characterWidth, false);
	</cfscript>
</cffunction>


<cffunction name="getSearchValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	return arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]];
	</cfscript>
</cffunction>

<cffunction name="getSearchSQLStruct" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	ts={
		type="=",
		field: arguments.row["feature_field_variable_name"]
	};
	if(arguments.typeStruct.selectmenu_delimiter EQ "|"){
		ts.arrValue=listToArray(arguments.value, ',', true);
	}else{
		ts.arrValue=listToArray(arguments.value, '|', true);
	}
	return ts;
	</cfscript>
</cffunction>

<cffunction name="getSearchSQL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="databaseField" type="string" required="yes">
	<cfargument name="databaseDateField" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	if(arguments.value NEQ ""){
		if(arguments.value CONTAINS ","){ 
			if(arguments.typeStruct.selectmenu_delimiter EQ "|"){
				arrTemp=listToArray(arguments.value, ',', true);
			}else{
				arrTemp=listToArray(arguments.value, '|', true);
			}
			if(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_multipleselection', true, 0) EQ 1){
				for(var i=1;i LTE arrayLen(arrTemp);i++){
					arrTemp[i]=db.trustedSQL('concat(",", '&arguments.databaseField&', ",") like ')&db.trustedSQL("'%,"&application.zcore.functions.zescape(arrTemp[i])&",%'");
				} 
			}else{
				for(var i=1;i LTE arrayLen(arrTemp);i++){
					arrTemp[i]=arguments.databaseField&' = '&db.trustedSQL("'"&application.zcore.functions.zescape(arrTemp[i])&"'");
				} 
			}
			return '('&arrayToList(arrTemp, ' or ')&')';
		}else{
			if(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_multipleselection', true, 0) EQ 1){
				return db.trustedSQL('concat(",", '&arguments.databaseField&', ",") LIKE ')&db.trustedSQL("'%,"&application.zcore.functions.zescape(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]])&",%'");
			}else{
				return arguments.databaseField&' = '&db.trustedSQL("'"&application.zcore.functions.zescape(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]])&"'");
			}
		}
	}
	return '';
	</cfscript>
</cffunction>

<cffunction name="validateFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript> 
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="onInvalidFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript> 
	</cfscript>
</cffunction>


<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">  
	<cfscript>
	characterWidth=arguments.row["feature_field_character_width"];

	if(arguments.row["feature_field_required"] EQ 1){
		required=true; 
	}else{
		required=false;
	}
	return { label: true, hidden: false, value:variables.createSelectMenu(arguments.row["feature_field_id"], arguments.row["feature_schema_id"], arguments.typeStruct, false, '', characterWidth, required)};
	</cfscript>
</cffunction>

<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	fieldName=arguments.fieldName;
	typeStruct=arguments.typeStruct;
	characterWidth=arguments.row["feature_field_character_width"];
	arrV=[];
	arrayAppend(arrV, '
		<cfscript>
			selectStruct={};
		selectStruct.name = "#fieldName#"; 
		enabled=false;
		selectStruct.size=#application.zcore.functions.zso(typeStruct, 'selectmenu_size', true, 1)#;
	');
	if(characterWidth NEQ 0){
		arrayAppend(arrV, '
		selectStruct.inlineStyle="width:#characterWidth*13#px; min-width:auto;";
		');
	}else{
		arrayAppend(arrV, '
		selectStruct.inlineStyle="width:95%; min-width:auto;";
		');
	}
	if(structkeyexists(typeStruct,'selectmenu_labels') and typeStruct.selectmenu_labels NEQ ""){
		arrayAppend(arrV, 'selectStruct.listLabelsDelimiter = "#typeStruct.selectmenu_delimiter#";
		selectStruct.listValuesDelimiter = "#typeStruct.selectmenu_delimiter#";
		selectStruct.listLabels="#replace(typeStruct.selectmenu_labels, "##", "####", "all")#";
		selectStruct.listValues="#replace(typeStruct.selectmenu_values, "##", "####", "all")#";
		enabled=true;
		');
	}
	if(structkeyexists(typeStruct, 'selectmenu_parentfield') and typeStruct.selectmenu_parentfield NEQ ""){
		arrayAppend(arrV, '
		selectStruct.listLabelsDelimiter = "#typeStruct.selectmenu_delimiter#";
		selectStruct.listValuesDelimiter = "#typeStruct.selectmenu_delimiter#";
			');
			if(structkeyexists(typeStruct,'selectmenu_labels') and typeStruct.selectmenu_labels NEQ ""){
				arrayAppend(arrV, '
		selectStruct.listLabels="#replace(selectStruct.listLabels&typeStruct.selectmenu_delimiter&arraytolist(rs.arrLabel, typeStruct.selectmenu_delimiter), "##", "####", "all")#";
		selectStruct.listValues="#replace(selectStruct.listValues&typeStruct.selectmenu_delimiter&arraytolist(rs.arrValue, typeStruct.selectmenu_delimiter), "##", "####", "all")#";
				');
			}else{
				arrayAppend(arrV, '
		selectStruct.listLabels="#replace(arraytolist(rs.arrLabel, typeStruct.selectmenu_delimiter), "##", "####", "all")#";
		selectStruct.listValues="#replace(arraytolist(rs.arrValue, typeStruct.selectmenu_delimiter), "##", "####", "all")#";
			');
		} 
		arrayAppend(arrV, '
	if(structkeyexists(form, "#fieldName#")){
		selectStruct.onchange="for(var i in this.options){ if(this.options[i].selected && this.options[i].value != '''' && this.options[i].value==''##form["#fieldName#"]##''){alert(''You can\''t select the same item you are editing.'');this.selectedIndex=0;}; } ";
	}
		');
		enabled=true;
		// must use id as the value instead of "value" because parent_id can't be a string or uniqueness would be wrong.
	}else{ 
		enabled=true;
		arrayAppend(arrV, '
		// You must implement the query and uncomment the code below for the select field to work.
		/*
		db.sql="SELECT table_label as label, table_id as id 
		FROM #db.table("table", request.zos.globals.id)# 
		ORDER BY table_id ASC ";
		qSelect=db.execute("qSelect");
		selectStruct.query = qSelect;
		selectStruct.queryLabelField = "label";
		selectStruct.queryValueField = "id";
		*/
		');
	}  
	if(enabled){

		arrayAppend(arrV, ' 

		if(arguments.row["feature_field_required"] EQ 1){
			required=true; 
		}else{
			required=false;
		}
		selectStruct.multiple=false;
		');
		if(application.zcore.functions.zso(typeStruct, 'selectmenu_multipleselection', true, 0) EQ 1){
			arrayAppend(arrV, '
		selectStruct.multiple=true;
		selectStruct.hideSelect=true;
		application.zcore.functions.zSetupMultipleSelect(selectStruct.name, application.zcore.functions.zso(form, "#fieldName#"), required);
			');
		}
		arrayAppend(arrV, '
		selectStruct.output=false;
		echo(application.zcore.functions.zInputSelectBox(selectStruct));  
		</cfscript>
		');
	}  
	return arrayToList(arrV, ' ');
	</cfscript>
</cffunction> 

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	if(arguments.value CONTAINS ","){
		var arrTemp=listToArray(arguments.value, ',', true);
		for(var i=1;i LTE arrayLen(arrTemp);i++){
			if(structkeyexists(arguments.dataStruct, arrTemp[i])){
				arrTemp[i]=arguments.dataStruct[arrTemp[i]];
			}
		}
		return arrayToList(arrTemp, ', ');
	}else{
		if(structkeyexists(arguments.dataStruct, arguments.value)){
			return arguments.dataStruct[arguments.value];
		}else{
			return arguments.value; 
		}
	}
	</cfscript>
</cffunction>

<cffunction name="onBeforeListView" localmode="modern" access="public" returntype="struct">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	return this.buildSelectMap(arguments.typeStruct, true);
	</cfscript>
</cffunction>

<cffunction name="onBeforeUpdate" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes"> 
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript>	
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
	return { success: true, value: nv, dateValue: "" }; 
	</cfscript>
</cffunction>

<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	return application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
	<cfscript>
	return 'Select Menu';
	</cfscript>
</cffunction>

<cffunction name="onUpdate" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	var error=false;
	if(len(arguments.dataStruct.selectmenu_delimiter) NEQ 1){
		application.zcore.status.setStatus(request.zsid, "Delimiter is required and must be 1 character.");
		error=true;
	}
	if(arguments.dataStruct.selectmenu_groupid NEQ ""){
		if(arguments.dataStruct.selectmenu_labelfield EQ ""){
			application.zcore.status.setStatus(request.zsid, "Label field is required when a group is selected.");
			error=true;
		}
		if(arguments.dataStruct.selectmenu_valuefield EQ ""){
			application.zcore.status.setStatus(request.zsid, "Value field is required when a group is selected.");
			error=true;
		}
	}else{
		if(arguments.dataStruct.selectmenu_labels EQ ""){
			application.zcore.status.setStatus(request.zsid, "Labels is required.");
			error=true;
		}
		
	}
	if(listlen(arguments.dataStruct.selectmenu_labels, arguments.dataStruct.selectmenu_delimiter, true) NEQ listlen(arguments.dataStruct.selectmenu_values, arguments.dataStruct.selectmenu_delimiter, true)){
		application.zcore.status.setStatus(request.zsid, "Labels and Values must have the same number of delimited values.");
		error=true;
	}
	if(error){
		application.zcore.status.setStatus(Request.zsid, false,arguments.dataStruct,true);
		return { success:false};
	}
	ts={
		selectmenu_delimiter:application.zcore.functions.zso(arguments.dataStruct, 'selectmenu_delimiter'),
		selectmenu_labels:application.zcore.functions.zso(arguments.dataStruct, 'selectmenu_labels'),
		selectmenu_values:application.zcore.functions.zso(arguments.dataStruct, 'selectmenu_values'),
		selectmenu_groupid:application.zcore.functions.zso(arguments.dataStruct, 'selectmenu_groupid'),
		selectmenu_labelfield:application.zcore.functions.zso(arguments.dataStruct, 'selectmenu_labelfield'),
		selectmenu_valuefield:application.zcore.functions.zso(arguments.dataStruct, 'selectmenu_valuefield'),
		selectmenu_parentfield:application.zcore.functions.zso(arguments.dataStruct, 'selectmenu_parentfield'),
		selectmenu_multipleselection:application.zcore.functions.zso(arguments.dataStruct, 'selectmenu_multipleselection'),
		selectmenu_size:application.zcore.functions.zso(arguments.dataStruct, 'selectmenu_size')
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, typeStruct: ts};
	</cfscript>
</cffunction>


<cffunction name="getFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		selectmenu_delimiter:"|",
		selectmenu_labels:"",
		selectmenu_values:"",
		selectmenu_groupid:"",
		selectmenu_labelfield:"",
		selectmenu_valuefield:"",
		selectmenu_parentfield:"",
		selectmenu_multipleselection:0,
		selectmenu_size:1
	};
	return ts;
	</cfscript>
</cffunction> 

<cffunction name="hasCustomDelete" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return false;
	</cfscript>
</cffunction>
		
<cffunction name="onDelete" localmode="modern" access="public">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
</cffunction>


<cffunction name="getTypeForm" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var output="";
	var value=application.zcore.functions.zso(arguments.dataStruct, arguments.fieldName);
	</cfscript>
	<cfsavecontent variable="output">
		<input type="radio" name="feature_field_type_id" value="7" onClick="setType(7);" <cfif value EQ 7>checked="checked"</cfif>/>
		Select Menu<br />
		<div id="typeFields7" style="display:none;padding-left:30px;"> 
			<p>You must set a datasource whether it is delimited Labels/Values List, or a Schema or both.</p>
			<table style="border-spacing:0px; width:100%;">
			<tr><td>Multiple Selections: </td><td>
			<cfscript>
			form.selectmenu_multipleselection=application.zcore.functions.zso(arguments.typeStruct, "selectmenu_multipleselection", true, 0);
			echo(application.zcore.functions.zInput_Boolean("selectmenu_multipleselection"));
			</cfscript></td></tr>
			<tr><td>Size: </td><td><input type="text" name="selectmenu_size" style="min-width:20px; max-width:20px;" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_size', true, 1))#" /> <br />(Makes more options visible for easier multiple selection)</td></tr>
			<tr><td colspan="2">Configure a manually entered list of values: </td></tr>
			<tr>
			<th>
			Delimiter </th><td><input type="text" name="selectmenu_delimiter" style="min-width:20px; max-width:20px;" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_delimiter', false, '|'))#" size="1" maxlength="1" /></td></tr>
			<tr><td>Labels List: </td><td><input type="text" style="min-width:150px;" name="selectmenu_labels" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_labels'))#" /></td></tr>
			<tr><td>Values List:</td><td> <input type="text" style="min-width:150px;" name="selectmenu_values" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_values'))#" /></td></tr>
			<tr><td colspan="2">Configure a group as a datasource: </td></tr>
			<tr><td>Use Schema: </td>
			<td>
			<cfscript>
			// and 	feature_schema_parent_id=#db.param(0)# 
			db.sql="SELECT * FROM #db.table("feature_schema", request.zos.zcoreDatasource)#
			WHERE feature_id=#db.param(arguments.dataStruct.feature_id)#  and 
			feature_schema_deleted = #db.param(0)# 
			ORDER BY feature_schema_display_name"; 
			var qSchema2=db.execute("qSchema2", "", 10000, "query", false);
			gs={};
			for(group in qSchema2){
				gs[group.feature_schema_id]={row:group, arrParent:[], arrParentID:[]};
			}
			for(group in qSchema2){
				currentSchema=group;
				for(i=1;i<=50;i++){
					if(currentSchema.feature_schema_parent_id NEQ 0 and structkeyexists(gs, currentSchema.feature_schema_parent_id)){
						arrayPrepend(gs[group.feature_schema_id].arrParentID, gs[currentSchema.feature_schema_parent_id].row.feature_schema_id);
						arrayPrepend(gs[group.feature_schema_id].arrParent, gs[currentSchema.feature_schema_parent_id].row.feature_schema_display_name);
						currentSchema=gs[currentSchema.feature_schema_parent_id].row;
					}else{
						break;
					}
					if(i EQ 50){
						throw("Infinite loop detected in the group heirarchy");
					}
				}
			}
			arrSchema=[];
			mainSchemaID="";
			if(structkeyexists(gs, form.feature_schema_id) and arrayLen(gs[form.feature_schema_id].arrParentID) NEQ 0){
				mainSchemaID=gs[form.feature_schema_id].arrParentID[1];
			}
			for(group in qSchema2){
				parentText="";
				if(arrayLen(gs[group.feature_schema_id].arrParent) NEQ 0){
					parentText=arrayToList(gs[group.feature_schema_id].arrParent, " -> ")&" -> ";
				}
				ts={
					label:parentText&gs[group.feature_schema_id].row.feature_schema_display_name,
					id:group.feature_schema_id
				};
				if(arrayLen(gs[group.feature_schema_id].arrParent) EQ 0){
					arrayAppend(arrSchema, ts);
				}else{
					found=false; 
					for(parentId in gs[group.feature_schema_id].arrParentID){
						if(parentId EQ mainSchemaID){
							found=true;
							break;
						}
					}
					// verify if the current group exists in the parent heirarchy before allowing it
					if(found){
						arrayAppend(arrSchema, ts);
					}
				}
			} 

			var selectStruct = StructNew();
			form.selectmenu_groupid=application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_groupid');
			selectStruct.name = "selectmenu_groupid";
			selectStruct.query = arrSchema;
			selectStruct.queryLabelField = "label";
			selectStruct.queryValueField = "id";
			application.zcore.functions.zInputSelectBox(selectStruct);
			</cfscript></td></tr>
			<tr><td>Label Field: </td>
			<td><input type="text" style="min-width:150px;" name="selectmenu_labelfield" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_labelfield'))#" /></td></tr>
			<tr><td>Value Field: </td><td><input type="text" style="min-width:150px;" name="selectmenu_valuefield" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_valuefield'))#" /></td></tr>
			<tr><td>Parent Field: </td><td>
			<input type="text" name="selectmenu_parentfield" style="min-width:150px;" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_parentfield'))#" /> (Optional, only use when this group will allow recursive heirarchy)</td></tr>
			
			
			
			<!--- 
			This has not been implemented yet.
			<tr><td colspan="2">Configure a database table as a datasource: </td></tr>
			<tr><td>Table name: </td>
			<td><input type="text" name="selectmenu_table" style="min-width:150px;" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_table'))#" /></td></tr>
			<tr><td>Label Field: </td>
			<td><input type="text" name="selectmenu_tablelabelfield" style="min-width:150px;" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_tablelabelfield'))#" /></td></tr>
			<tr><td>Value Field: </td><td><input type="text" name="selectmenu_tablevaluefield" style="min-width:150px;" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_tablevaluefield'))#" style="min-width:150px;" /></td></tr>
			<tr><td>Parent Field: </td><td>
			<input type="text" name="selectmenu_tableparentfield" style="min-width:150px;" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'selectmenu_tableparentfield'))#" /> (Optional, only use when this table has a parent_id field to allow recursive heirarchy)</td></tr>
			 --->
			
			</table>
		
		</div>
	</cfsavecontent>
	<cfreturn output>
</cffunction>

<cffunction name="buildSelectMap" localmode="modern" access="public">
	<cfargument name="typeFields" type="struct" required="yes">
	<cfargument name="indexById" type="boolean" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var ts2=arguments.typeFields;
	local.arrSelectMap=structnew();
	if(structkeyexists(ts2, 'selectmenu_labels') and ts2.selectmenu_labels NEQ ""){
		// grab the label list and group data (if using a group)
		local.arrLabelTemp=listToArray(ts2.selectmenu_labels, ts2.selectmenu_delimiter, true);
		local.arrValueTemp=listToArray(ts2.selectmenu_values, ts2.selectmenu_delimiter, true);
		// loop the label list
		for(local.f=1;local.f LTE arraylen(local.arrLabelTemp);local.f++){
			if(arguments.indexById){
				local.arrSelectMap[local.arrValueTemp[local.f]]=local.arrLabelTemp[local.f];
			}else{
				local.arrSelectMap[local.arrLabelTemp[local.f]]=local.arrValueTemp[local.f];
			}
		}
	}
	if(structkeyexists(ts2, 'selectmenu_groupid') and ts2.selectmenu_groupid NEQ ""){
		// grab all the group values and ids
		db.sql="select * from #db.table("#variables.siteType#_x_option_group", request.zos.zcoreDatasource)# s1, 
		#db.table("feature_field", request.zos.zcoreDatasource)# s2
		WHERE 
		s1.#variables.siteType#_x_option_group_deleted = #db.param(0)# and
		s2.feature_field_deleted = #db.param(0)# and
		s2.feature_field_id = s1.feature_field_id and 
		s2.feature_schema_id = s1.feature_schema_id and 
		s2.feature_id = s1.feature_id and 
		s1.feature_schema_id = #db.param(ts2.selectmenu_groupid)# and 
		s1.feature_id=#db.param(form.feature_id)# ";
		local.qSchemaData=db.execute("qSchemaData");
		// loop the group data
		local.tempSet={};
		for(local.row2 in local.qSchemaData){
			if(not structkeyexists(local.tempSet, local.row2["feature_data_id"])){
				local.tempSet[local.row2["feature_data_id"]]={};
			}
			local.tempSet[local.row2["feature_data_id"]][local.row2["feature_field_variable_name"]]=local.row2["#variables.siteType#_x_option_group_value"];
		}
		for(local.n in local.tempSet){
			if(arguments.indexById){
				local.arrSelectMap[local.n]=local.tempSet[local.n][ts2.selectmenu_labelfield];
			}else{
				local.arrSelectMap[local.tempSet[local.n][ts2.selectmenu_labelfield]]=local.n;
			}
		}
	}
	return local.arrSelectMap;
	</cfscript>
</cffunction>

<cffunction name="getSelectMenuLabel" localmode="modern" access="private">
	<cfargument name="option_id" type="string" required="yes">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfargument name="setFieldStruct" type="struct" required="yes">
	<cfscript> 
	var ts=0;
	var row=0; 
	var i=0;
	local.selectedValue="";
	if(structkeyexists(form, "newvalue"&arguments.option_id)){
		local.selectedValue=form["newvalue"&arguments.option_id];
	}
	
	local.rs=application.zcore.featureCom.prepareRecursiveData(arguments.option_id, arguments.option_group_id, arguments.setFieldStruct, false); 
	ts=local.rs.ts; 
	if(structkeyexists(ts,'selectmenu_labels') and ts.selectmenu_labels NEQ ""){ 
		local.arrTemp=listToArray(ts.selectmenu_values, ts.selectmenu_delimiter, true);
		local.arrLabelTemp=listToArray(ts.selectmenu_labels, ts.selectmenu_delimiter, true);
		for(i=1;i LTE arraylen(local.arrTemp);i++){
			if(compare(local.arrTemp[i], local.selectedValue) EQ 0){
				return local.arrLabelTemp[i];
			}
		} 
	}
	if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
		for(i=1;i LTE arraylen(local.rs.arrValue);i++){
			if(compare(local.rs.arrValue[i], local.selectedValue) EQ 0){
				return local.rs.arrLabel[i];
			}
		}  
	}else if(structkeyexists(local.rs, 'qTemp2')){
		local.enabled=true; 
		for(row in local.rs.qTemp2){
			if(compare(row.value, local.selectedValue) EQ 0){
				return row.label;
			}
		}
	}
	// return the value if label can't be found.
	return local.selectedValue;
	</cfscript>
</cffunction>

<cffunction name="createSelectMenu" localmode="modern" access="private">
	<cfargument name="option_id" type="string" required="yes">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfargument name="setFieldStruct" type="struct" required="yes">
	<cfargument name="enableSearchView" type="boolean" required="yes">
	<cfargument name="onChangeJavascript" type="string" required="yes">
	<cfargument name="characterWidth" type="string" required="yes">
	<cfargument name="required" type="boolean" required="yes">
	<cfscript>
	var selectStruct = StructNew();
	var ts=0;
	local.rs=application.zcore.featureCom.prepareRecursiveData(arguments.option_id, arguments.option_group_id, arguments.setFieldStruct, arguments.enableSearchView);
	selectStruct.name = "newvalue#arguments.option_id#";
	ts=local.rs.ts;
	local.enabled=false;
	selectStruct.size=application.zcore.functions.zso(ts, 'selectmenu_size', true, 1);
	if(arguments.enableSearchView){
		selectStruct.size=1;
	}
	if(arguments.characterWidth NEQ 0){
		selectStruct.inlineStyle="width:#arguments.characterWidth*13#px; min-width:auto;";
	}else{
		selectStruct.inlineStyle="width:95%; min-width:auto;";
	}
	
	if(structkeyexists(ts,'selectmenu_labels') and ts.selectmenu_labels NEQ ""){
		selectStruct.listLabelsDelimiter = ts.selectmenu_delimiter;
		selectStruct.listValuesDelimiter = ts.selectmenu_delimiter;
		selectStruct.listLabels=ts.selectmenu_labels;
		selectStruct.listValues=ts.selectmenu_values;
		local.enabled=true;
	}
	selectStruct.onchange="";
	if(structkeyexists(ts, 'selectmenu_parentfield') and ts.selectmenu_parentfield NEQ ""){
		selectStruct.listLabelsDelimiter = ts.selectmenu_delimiter;
		selectStruct.listValuesDelimiter = ts.selectmenu_delimiter;
		if(structkeyexists(ts,'selectmenu_labels') and ts.selectmenu_labels NEQ ""){
			selectStruct.listLabels=selectStruct.listLabels&ts.selectmenu_delimiter&arraytolist(local.rs.arrLabel, ts.selectmenu_delimiter);
			selectStruct.listValues=selectStruct.listValues&ts.selectmenu_delimiter&arraytolist(local.rs.arrValue, ts.selectmenu_delimiter);
		}else{
			selectStruct.listLabels=arraytolist(local.rs.arrLabel, ts.selectmenu_delimiter);
			selectStruct.listValues=arraytolist(local.rs.arrValue, ts.selectmenu_delimiter);
		}
		if(structkeyexists(form, 'feature_data_id')){

			selectStruct.onchange="for(var i in this.options){ if(this.options[i].selected && this.options[i].value != '' && this.options[i].value=='#form["feature_data_id"]#'){alert('You can\'t select the same item you are editing.');this.selectedIndex=0;}; } ";
		}
		local.enabled=true;
		// must use id as the value instead of "value" because parent_id can't be a string or uniqueness would be wrong.
	}else if(structkeyexists(local.rs, 'qTemp2')){
		local.enabled=true;
		selectStruct.query = local.rs.qTemp2;
		selectStruct.queryLabelField = "label";
		selectStruct.queryValueField = "id";
	} 

	selectStruct.onchange&=arguments.onChangeJavascript;
	if(arguments.required){
		selectStruct.required=true;
	}
	if(local.enabled){

		selectStruct.multiple=false;
		if(arguments.enableSearchView){
			selectStruct.multiple=false;
			selectStruct.selectedDelimiter=ts.selectmenu_delimiter;
		}else{
			if(application.zcore.functions.zso(ts, 'selectmenu_multipleselection', true, 0) EQ 1){
				selectStruct.multiple=true;
				selectStruct.required=false;
				selectStruct.hideSelect=true;
				application.zcore.functions.zSetupMultipleSelect(selectStruct.name, application.zcore.functions.zso(form, 'feature_data_id'), arguments.required);
			}
		}
		selectStruct.output=false;
		local.tempOutput=application.zcore.functions.zInputSelectBox(selectStruct);
		return replace(local.tempOutput, "_", "&nbsp;", "all");
	}else{
		return "";
	}
	</cfscript>
</cffunction>
 

<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` text NOT NULL";
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>