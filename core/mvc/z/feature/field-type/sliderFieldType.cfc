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
	return arguments.typeStruct.typeStruct.slider_from;
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
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfargument name="value" type="string" required="yes">
	<cfargument name="onChangeJavascript" type="string" required="yes">
	<cfscript>
	return '<input type="number" name="#arguments.prefixString##arguments.row["feature_field_id"]#" onkeyup="#arguments.onChangeJavascript#" onpaste="#arguments.onChangeJavascript#" min="#arguments.typeStruct.slider_from#" max="#arguments.typeStruct.slider_to#" step="#arguments.typeStruct.slider_step#" id="#arguments.prefixString##arguments.row["feature_field_id"]#" style="width:95%; min-width:95%;" value="#htmleditformat(arguments.value)#" size="8" />';
	</cfscript>
</cffunction>


<cffunction name="getSearchValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	return application.zcore.functions.zso(form, arguments.prefixString&arguments.row["feature_field_id"], false, "");
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
	<cfargument name="typeStruct" type="struct" required="yes">
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

<cffunction name="searchFilter" localmode="modern" access="public">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldValue" type="string" required="yes"> 
	<cfargument name="searchValue" type="string" required="yes">
	<cfscript>
	if(arguments.searchValue NEQ "" and arguments.fieldValue EQ arguments.searchValue){
		return false;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="onBeforeImport" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfscript>
	return { mapData: false, struct: {}};
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


<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">  
	<cfscript> 
	required="";
	if(arguments.row.feature_field_required EQ 1){
		required="required";
	}
  	return { label: true, hidden: false, value: '<input type="range" #required# name="#arguments.prefixString&arguments.row["feature_field_id"]#" min="#arguments.typeStruct.slider_from#" max="#arguments.typeStruct.slider_to#" onchange="document.getElementById(''#arguments.prefixString&arguments.row["feature_field_id"]#_valueInput'').innerHTML=this.value; " step="#arguments.typeStruct.slider_step#" value="#htmleditformat(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]))#"><br />
  		Selected Value: <span id="#arguments.prefixString&arguments.row["feature_field_id"]#_valueInput">#htmleditformat(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]))#</span>' };
	</cfscript>
</cffunction>


<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript> 
  	return '
  	<input type="range" name="#arguments.fieldName#" min="#arguments.typeStruct.slider_from#" max="#arguments.typeStruct.slider_to#" onchange="document.getElementById(''#arguments.fieldName#_valueInput'').innerHTML=this.value; " step="#arguments.typeStruct.slider_step#" value="##htmleditformat(application.zcore.functions.zso(form, "#arguments.fieldName#"))##"><br />
  	Selected Value: <span id="#arguments.fieldName#_valueInput">##htmleditformat(application.zcore.functions.zso(form, "#arguments.fieldName#"))##</span>
  		';
	</cfscript>
</cffunction>

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
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
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	return {};
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


<cffunction name="onBeforeUpdate" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes"> 
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfargument name="dataFields" type="struct" required="yes">
	<cfscript>
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], false, "");
	return { success: true, value: nv, dateValue: "" };
	</cfscript>
</cffunction>

<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="dataFields" type="struct" required="yes">
	<cfscript>
	return application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"], false, arguments.row["feature_field_default_value"]);
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
	<cfscript>
	return 'Slider';
	</cfscript>
</cffunction>

<cffunction name="onUpdate" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	var error=false;
	if(len(arguments.dataStruct.slider_from) EQ ""){
		application.zcore.status.setStatus(request.zsid, "From is required.");
		error=true;
	} 
	if(arguments.dataStruct.slider_to EQ ""){
		application.zcore.status.setStatus(request.zsid, "To is required.");
		error=true;
	}
	if(arguments.dataStruct.slider_step EQ ""){
		application.zcore.status.setStatus(request.zsid, "Step is required.");
		error=true;
	}  
	if(error){
		application.zcore.status.setStatus(Request.zsid, false,arguments.dataStruct,true);
		return { success:false};
	}
	ts={
		slider_from:application.zcore.functions.zso(arguments.dataStruct, 'slider_from'),
		slider_to:application.zcore.functions.zso(arguments.dataStruct, 'slider_to'),
		slider_step:application.zcore.functions.zso(arguments.dataStruct, 'slider_step')
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, typeStruct: ts};
	</cfscript>
</cffunction> 
		
<cffunction name="getFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		slider_from:"",
		slider_to:"",
		slider_step:""
	};
	return ts;
	</cfscript>
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
		<script type="text/javascript">
		function validateFieldType22(postObj, arrError){   
			if(postObj.slider_from == ''){
				arrError.push('Slider From is required.');
			}
			if(postObj.slider_to == ''){
				arrError.push('Slider To is required.');
			}
			if(postObj.slider_step == ''){
				arrError.push('Slider Step is required.');
			}
		}
		</script>
		<input type="radio" name="feature_field_type_id" value="22" onClick="setType(22);" <cfif value EQ 22>checked="checked"</cfif>/>
		Slider<br />
		<div id="typeFields22" style="display:none;padding-left:30px;"> 
			<table style="border-spacing:0px;">
			<tr>
			<th>From:</th>
			<td><input type="number" name="slider_from" value="<cfif structkeyexists(form, 'slider_from')>#htmleditformat(form.slider_from)#<cfelse>#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'slider_from', false, '|'))#</cfif>"></td>
			</tr>
			<tr>
			<th>To:</th>
			<td><input type="number" name="slider_to" value="<cfif structkeyexists(form, 'slider_to')>#htmleditformat(form.slider_to)#<cfelse>#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'slider_to', false, '|'))#</cfif>"></td>
			</tr>
			<tr>
			<th>Step:</th>
			<td><input type="number" name="slider_step" value="<cfif structkeyexists(form, 'slider_step')>#htmleditformat(form.slider_step)#<cfelse>#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'slider_step', false, '|'))#</cfif>"></td>
			</tr> 
			</table>
		</div>
	</cfsavecontent>
	<cfreturn output>
</cffunction> 


<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` decimal(10,2) NOT NULL";
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>