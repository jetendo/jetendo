<cfcomponent implements="zcorerootmapping.interface.optionType">
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
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	return "1";
	</cfscript>
</cffunction>

<cffunction name="getSearchFieldName" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="setTableName" type="string" required="yes">
	<cfargument name="groupTableName" type="string" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	return arguments.groupTableName&".#variables.siteType#_x_option_group_value";
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

<cffunction name="getSortSQL" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="fieldIndex" type="string" required="yes">
	<cfargument name="sortDirection" type="string" required="yes">
	<cfscript>
	return "sVal"&arguments.fieldIndex&" "&arguments.sortDirection;
	</cfscript>
</cffunction>

<cffunction name="getSearchFormField" localmode="modern" access="public"> 
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfargument name="value" type="string" required="yes">
	<cfargument name="onChangeJavascript" type="string" required="yes">
	<cfscript>
	var tempCheck='';

	// if list feature is used, show multiple menu instead of checkbox
	if(structkeyexists(arguments.optionStruct, 'checkbox_labels') and arguments.optionStruct.checkbox_labels NEQ "" and arguments.optionStruct.checkbox_values NEQ ""){
		// multiple select
		var ts = StructNew();
		ts.name = arguments.prefixString&arguments.row["feature_field_id"]; 
		ts.listLabelsDelimiter = arguments.optionStruct.checkbox_delimiter;
		ts.listValuesDelimiter = arguments.optionStruct.checkbox_delimiter;
		ts.listLabels=arguments.optionStruct.checkbox_labels;
		ts.listValues=arguments.optionStruct.checkbox_values;
		ts.struct=arguments.dataStruct; 
		ts.multiple=true;
		ts.hideSelect=true; 
		ts.onclick=arguments.onChangeJavascript;
		ts.output=false;
		if(arguments.row["feature_field_required"] EQ 1){
			required=true; 
		}else{
			required=false;
		}
		application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, '#variables.siteType#_x_option_group_set_id'), required);  
		tempOutput=application.zcore.functions.zInputSelectBox(ts);
		return tempOutput;
	}else{

		if(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], true, arguments.row["feature_field_default_value"]) EQ 1){
			tempCheck=' checked="checked" ';
		}
		return '<input type="checkbox" name="#arguments.prefixString##arguments.row["feature_field_id"]#" onclick="#arguments.onChangeJavascript#" id="#arguments.prefixString##arguments.row["feature_field_id"]#" value="1" #tempCheck# />';
	}
	</cfscript>
</cffunction>


<cffunction name="getSearchValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	if(structkeyexists(arguments.optionStruct, 'checkbox_labels') and arguments.optionStruct.checkbox_labels NEQ "" and arguments.optionStruct.checkbox_values NEQ ""){
		return application.zcore.functions.zso(form, arguments.prefixString&arguments.row["feature_field_id"], false, 0);
	}else{
		return application.zcore.functions.zso(form, arguments.prefixString&arguments.row["feature_field_id"], true, 0);
	}
	</cfscript>
</cffunction>

<cffunction name="getSearchSQLStruct" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	ts={
		type="=",
		field: arguments.row["feature_field_name"],
		arrValue:[]
	};
	if(structkeyexists(arguments.optionStruct, 'checkbox_labels') and arguments.optionStruct.checkbox_labels NEQ "" and arguments.optionStruct.checkbox_values NEQ ""){
		v=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], false, 0);
		arrValue=listToArray(v, ","); 
		if(v NEQ ""){
			arrSQL=[];
			for(v in arrValue){
				if(trim(v) NEQ ""){
					arrayAppend(ts.arrValue, v);
				}
			} 
		}
	}else{
		v=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], true, 0);
		if(v EQ 1){
			arrayAppend(ts.arrValue, v);
		}
	}
	return ts;
	</cfscript>
</cffunction>

<cffunction name="getSearchSQL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="databaseField" type="string" required="yes">
	<cfargument name="databaseDateField" type="string" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 


	if(structkeyexists(arguments.optionStruct, 'checkbox_labels') and arguments.optionStruct.checkbox_labels NEQ "" and arguments.optionStruct.checkbox_values NEQ ""){
		v=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], false, 0);
		arrValue=listToArray(v, ","); 
		if(v NEQ ""){
			arrSQL=[];
			for(v in arrValue){
				if(trim(v) NEQ ""){
					arrayAppend(arrSQL, db.trustedSQL("concat(',', #arguments.databaseField#, ',') like '%,"&v&",%'"));
				}
			}
			return ' ( '&arrayToList(arrSQL, ' or ')&' ) ';
		}else{
			return db.trustedSQL(' 1 = 1 ');
		}
	}else{
		v=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], true, 0);
		if(v EQ 1){
			return arguments.databaseField&' = '&db.trustedSQL("'"&v&"'");
		}else{
			return db.trustedSQL(' 1 = 1 ');
		}
	}
	</cfscript>
</cffunction>

<cffunction name="onBeforeImport" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	return { mapData: false, struct: {} };
	</cfscript>
</cffunction>

<cffunction name="hasCustomDelete" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return false;
	</cfscript>
</cffunction>

<cffunction name="onDelete" localmode="modern" access="public" output="no">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	</cfscript>
</cffunction>


<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">  
	<cfscript>
	var tempCheck='';
	// if list feature is used, show multiple menu instead of checkbox
	if(application.zcore.functions.zso(arguments.optionStruct, 'checkbox_labels') NEQ "" and application.zcore.functions.zso(arguments.optionStruct, 'checkbox_values') NEQ ""){
		// multiple select
		var ts = StructNew();
		ts.name = arguments.prefixString&arguments.row["feature_field_id"]; 
		ts.listLabels = arguments.optionStruct.checkbox_labels;
		ts.listValues = arguments.optionStruct.checkbox_values;
		ts.listLabelsDelimiter = application.zcore.functions.zso(arguments.optionStruct, 'checkbox_delimiter'); // tab delimiter
		ts.listValuesDelimiter = application.zcore.functions.zso(arguments.optionStruct, 'checkbox_delimiter');
		ts.struct=arguments.dataStruct;  
		ts.output=false; 
		rs=application.zcore.functions.zInput_Checkbox(ts); 
		return { label: true, hidden: false, value:rs.output};
	}else{
		if(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], true, arguments.row["feature_field_default_value"]) EQ 1){
			tempCheck=' checked="checked" ';
		}
		return { label: true, hidden: false, value:'<input type="checkbox" name="#arguments.prefixString&arguments.row["feature_field_id"]#" id="#arguments.prefixString&arguments.row["feature_field_id"]#" value="1" #tempCheck# />'};  
	}
	</cfscript>
</cffunction>


<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	// if list feature is used, show multiple menu instead of checkbox
	if(application.zcore.functions.zso(arguments.optionStruct, 'checkbox_labels') NEQ "" and application.zcore.functions.zso(arguments.optionStruct, 'checkbox_values') NEQ ""){
		// multiple select
		return ('
		<cfscript>
		var ts = StructNew();
		ts.name = "#arguments.fieldName#"; 
		ts.listLabels = "#replace(replace(arguments.optionStruct.checkbox_labels, '"' , '""', "all"), "####", "########", "all")#";
		ts.listValues = "#replace(replace(arguments.optionStruct.checkbox_values, '"' , '""', "all"), "####", "########", "all")#";
		ts.listLabelsDelimiter = "#application.zcore.functions.zso(arguments.optionStruct, 'checkbox_delimiter')#"; // tab delimiter
		ts.listValuesDelimiter = "#application.zcore.functions.zso(arguments.optionStruct, 'checkbox_delimiter')#";
		ts.struct=form;  
		ts.output=true; 
		application.zcore.functions.zInput_Checkbox(ts); 
		</cfscript>
		');
	}else{
		return ('
		<cfscript>
		var tempCheck="";
		if(application.zcore.functions.zso(form, "#arguments.fieldName#", true, "#arguments.row["feature_field_default_value"]#") EQ 1){
			tempCheck=" checked=""checked"" ";
		}
		echo(''<input type="checkbox" name="#arguments.fieldName#" id="#arguments.fieldName#" value="1" #tempCheck# />'');
		</cfscript>
		');  
	}
	</cfscript>
</cffunction>

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	if(application.zcore.functions.zso(arguments.optionStruct, 'checkbox_labels') NEQ "" and application.zcore.functions.zso(arguments.optionStruct, 'checkbox_values') NEQ ""){
		return arguments.value;
	}else{ 
		if(arguments.value EQ 1){
			return 'Yes';
		}else{
			return 'No';
		} 
	}
	</cfscript>
</cffunction>

<cffunction name="onBeforeListView" localmode="modern" access="public" returntype="struct">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	return {};
	</cfscript>
</cffunction>

<cffunction name="validateFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript> 
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="onInvalidFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>  
	</cfscript>
</cffunction>


<cffunction name="onBeforeUpdate" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes"> 
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript>
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], false, 0);
	return { success: true, value: nv, dateValue: "" };
	</cfscript>
</cffunction>

<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	return application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], false, arguments.row["feature_field_default_value"]);
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
	<cfscript>
	return 'Checkbox';
	</cfscript>
</cffunction>


<cffunction name="onUpdate" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	var error=false;
	if(len(arguments.dataStruct.checkbox_delimiter) NEQ 1){
		application.zcore.status.setStatus(request.zsid, "Delimiter is required and must be 1 character.");
		error=true;
	} 
	if(structkeyexists(arguments.dataStruct, 'checkbox_labels') and arguments.dataStruct.checkbox_labels EQ "" and arguments.dataStruct.checkbox_values EQ ""){
		// do nothing
	}else if(listlen(arguments.dataStruct.checkbox_labels, arguments.dataStruct.checkbox_delimiter, true) NEQ listlen(arguments.dataStruct.checkbox_values, arguments.dataStruct.checkbox_delimiter, true)){
		application.zcore.status.setStatus(request.zsid, "Labels and Values must have the same number of delimited values.");
		error=true;
	}
	if(error){
		application.zcore.status.setStatus(Request.zsid, false,arguments.dataStruct,true);
		return { success:false};
	}
	ts={
		checkbox_delimiter:application.zcore.functions.zso(arguments.dataStruct, 'checkbox_delimiter'),
		checkbox_labels:application.zcore.functions.zso(arguments.dataStruct, 'checkbox_labels'),
		checkbox_values:application.zcore.functions.zso(arguments.dataStruct, 'checkbox_values')
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, optionStruct: ts};
	</cfscript>
</cffunction> 
		
<cffunction name="getFieldFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
	};
	return ts;
	</cfscript>
</cffunction> 

<cffunction name="getTypeForm" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var output="";
	var value=application.zcore.functions.zso(arguments.dataStruct, arguments.fieldName);
	</cfscript>
	<cfsavecontent variable="output">
	<input type="radio" name="feature_field_type_id" value="8" onClick="setType(8);" <cfif value EQ 8>checked="checked"</cfif>/>
	Checkbox<br />
	<div id="typeFields8" style="display:none;padding-left:30px;">  
		<script type="text/javascript">
		function validateFieldType1(postObj, arrError){  
			if(postObj.checkbox_delimiter == ''){
				arrError.push('Delimiter is required');
			}
			if(postObj.checkbox_labels == ''){
				arrError.push('Labels List is required');
			} 
			if(postObj.checkbox_values == ''){
				arrError.push('Values List is required');
			}
		}
		</script>  
		<p>Leave these options empty for checkbox to default to a value of 1 when checked and 0 when not checked.</p>
		<table style="border-spacing:0px;">
		<tr>
		<th>
		Delimiter </th><td><input type="text" name="checkbox_delimiter"  value="<cfif structkeyexists(form, 'checkbox_delimiter')>#htmleditformat(form.checkbox_delimiter)#<cfelse>#htmleditformat(application.zcore.functions.zso(arguments.optionStruct, 'checkbox_delimiter', false, '|'))#</cfif>" size="1" maxlength="1" /></td></tr>
		<tr><td>Labels List: </td><td><input type="text" name="checkbox_labels"  value="<cfif structkeyexists(form, 'checkbox_labels')>#htmleditformat(form.checkbox_labels)#<cfelse>#htmleditformat(application.zcore.functions.zso(arguments.optionStruct, 'checkbox_labels'))#</cfif>" /></td></tr>
		<tr><td>Values List:</td><td> <input type="text" name="checkbox_values" value="<cfif structkeyexists(form, 'checkbox_values')>#htmleditformat(form.checkbox_values)#<cfelse>#htmleditformat(application.zcore.functions.zso(arguments.optionStruct, 'checkbox_values'))#</cfif>" /></td></tr>
		</table>
	</div>
	</cfsavecontent>
	<cfreturn output>
</cffunction> 


<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	if(structkeyexists(request, 'forceTextCheckbox')){
		return "`#arguments.fieldName#` TEXT NOT NULL ";
	}else{
		return "`#arguments.fieldName#` char(1) NOT NULL DEFAULT '0'";
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>