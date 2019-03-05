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
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	if(arguments.optionStruct.optionStruct.radio_values NEQ ""){
		return listgetat(arguments.optionStruct.optionStruct.radio_values, 1, arguments.optionStruct.optionStruct.radio_delimiter);
	}else{
		return "You need to set this value manually";
	}
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

<cffunction name="isCopyable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
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
	var ts = StructNew();
	ts.name = arguments.prefixString&arguments.row["feature_field_id"];
	ts.labelList = arguments.optionStruct.radio_labels;
	ts.valueList = arguments.optionStruct.radio_values;
	ts.delimiter = arguments.optionStruct.radio_delimiter;
	ts.struct=arguments.dataStruct; 
	ts.onclick=arguments.onChangeJavascript;
	ts.output=false;
	return application.zcore.functions.zInput_RadioGroup(ts);    
	</cfscript>
</cffunction>


<cffunction name="getSearchValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	return application.zcore.functions.zso(form, arguments.prefixString&arguments.row["feature_field_id"], false, "");
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
		field: arguments.row["feature_field_variable_name"],
		arrValue:[]
	};
	if(arguments.value NEQ ""){
		arrayAppend(ts.arrValue, arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]]);
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
	if(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], false, '') NEQ ''){
		return arguments.databaseField&' = '&db.trustedSQL("'"&application.zcore.functions.zescape(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]])&"'");
	}else{
		return db.trustedSQL(' 1 = 1 ');
	}
	</cfscript>
</cffunction>

<cffunction name="onBeforeImport" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	return { mapData: false, struct: variables.buildSelectMap(arguments.optionStruct, false)};
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
	var ts = StructNew();
	ts.name = arguments.prefixString&arguments.row["feature_field_id"];
	ts.labelList = arguments.optionStruct.radio_labels;
	ts.valueList = arguments.optionStruct.radio_values;
	ts.delimiter = arguments.optionStruct.radio_delimiter;
	ts.struct=arguments.dataStruct; 
	ts.output=false;
	return { label: true, hidden: false, value: application.zcore.functions.zInput_RadioGroup(ts)};   
	</cfscript>
</cffunction>


<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript> 
	return '
	<cfscript>
	var ts = StructNew();
	ts.name = "#arguments.fieldName#";
	ts.labelList = "#replace(replace(arguments.optionStruct.radio_labels, '"' , '""', "all"), "####", "########", "all")#";
	ts.valueList = "#replace(replace(arguments.optionStruct.radio_values, '"' , '""', "all"), "####", "########", "all")#";
	ts.delimiter = "#arguments.optionStruct.radio_delimiter#";
	ts.struct=form; 
	ts.output=true;
	application.zcore.functions.zInput_RadioGroup(ts);   
	</cfscript>
	';
	</cfscript>
</cffunction>

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	if(structkeyexists(arguments.dataStruct, arguments.value)){
		return arguments.dataStruct[arguments.value];
	}else{
		return arguments.value; 
	}
	</cfscript>
</cffunction>

<cffunction name="onBeforeListView" localmode="modern" access="public" returntype="struct">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	return variables.buildSelectMap(arguments.optionStruct, true);
	</cfscript>
</cffunction>


<cffunction name="buildSelectMap" localmode="modern" access="private">
	<cfargument name="typeFields" type="struct" required="yes">
	<cfargument name="indexById" type="boolean" required="yes">
	<cfscript>
	var ts2=arguments.typeFields;
	var arrSelectMap=structnew();
	if(structkeyexists(ts2, 'radio_labels') and ts2.radio_labels NEQ ""){
		// grab the label list and group data (if using a group)
		var arrLabelTemp=listToArray(ts2.radio_labels, ts2.radio_delimiter, true);
		var arrValueTemp=listToArray(ts2.radio_values, ts2.radio_delimiter, true);
		// loop the label list
		for(var f=1;f LTE arraylen(arrLabelTemp);f++){
			if(arguments.indexById){
				arrSelectMap[arrValueTemp[f]]=arrLabelTemp[f];
			}else{
				arrSelectMap[arrLabelTemp[f]]=arrValueTemp[f];
			}
		}
	}
	return arrSelectMap;
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
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], false, "");
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
	return 'Radio Schema';
	</cfscript>
</cffunction>

<cffunction name="onUpdate" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	var error=false;
	if(len(arguments.dataStruct.radio_delimiter) NEQ 1){
		application.zcore.status.setStatus(request.zsid, "Delimiter is required and must be 1 character.");
		error=true;
	} 
	if(arguments.dataStruct.radio_labels EQ ""){
		application.zcore.status.setStatus(request.zsid, "Label field is required.");
		error=true;
	}
	if(arguments.dataStruct.radio_values EQ ""){
		application.zcore.status.setStatus(request.zsid, "Value field is required.");
		error=true;
	} 
	if(listlen(arguments.dataStruct.radio_labels, arguments.dataStruct.radio_delimiter, true) NEQ listlen(arguments.dataStruct.radio_values, arguments.dataStruct.radio_delimiter, true)){
		application.zcore.status.setStatus(request.zsid, "Labels and Values must have the same number of delimited values.");
		error=true;
	}
	if(error){
		application.zcore.status.setStatus(Request.zsid, false,arguments.dataStruct,true);
		return { success:false};
	}
	ts={
		radio_delimiter:application.zcore.functions.zso(arguments.dataStruct, 'radio_delimiter'),
		radio_labels:application.zcore.functions.zso(arguments.dataStruct, 'radio_labels'),
		radio_values:application.zcore.functions.zso(arguments.dataStruct, 'radio_values')
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, optionStruct: ts};
	</cfscript>
</cffunction> 
		
<cffunction name="getFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		radio_delimiter:"|",
		radio_labels:"",
		radio_values:""
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
		<script type="text/javascript">
		function validateFieldType1(postObj, arrError){  
			if(postObj.radio_delimiter == ''){
				arrError.push('Delimiter is required');
			}
			if(postObj.radio_labels == ''){
				arrError.push('Labels List is required');
			} 
			if(postObj.radio_values == ''){
				arrError.push('Values List is required');
			}
		}
		</script>
		<input type="radio" name="feature_field_type_id" value="14" onClick="setType(14);" <cfif value EQ 14>checked="checked"</cfif>/>
		Radio Schema<br />
		<div id="typeFields14" style="display:none;padding-left:30px;"> 
			<table style="border-spacing:0px;">
			<tr>
			<th>
			Delimiter </th><td><input type="text" name="radio_delimiter"  value="<cfif structkeyexists(form, 'radio_delimiter')>#htmleditformat(form.radio_delimiter)#<cfelse>#htmleditformat(application.zcore.functions.zso(arguments.optionStruct, 'radio_delimiter', false, '|'))#</cfif>" size="1" maxlength="1" /></td></tr>
			<tr><td>Labels List: </td><td><input type="text" name="radio_labels"  value="<cfif structkeyexists(form, 'radio_labels')>#htmleditformat(form.radio_labels)#<cfelse>#htmleditformat(application.zcore.functions.zso(arguments.optionStruct, 'radio_labels'))#</cfif>" /></td></tr>
			<tr><td>Values List:</td><td> <input type="text" name="radio_values" value="<cfif structkeyexists(form, 'radio_values')>#htmleditformat(form.radio_values)#<cfelse>#htmleditformat(application.zcore.functions.zso(arguments.optionStruct, 'radio_values'))#</cfif>" /></td></tr>
			</table>
		</div>
	</cfsavecontent>
	<cfreturn output>
</cffunction> 


<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` varchar(255) NOT NULL";
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>