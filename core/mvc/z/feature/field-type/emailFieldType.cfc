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
	return "test@emailexample123.com";
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
	return { mapData: false, struct: {} };
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
	return '<input type="email" name="#arguments.prefixString##arguments.row["feature_field_id"]#" onkeyup="#arguments.onChangeJavascript#" onpaste="#arguments.onChangeJavascript#" style="width:95%; min-width:95%;" id="#arguments.prefixString##arguments.row["feature_field_id"]#" value="#htmleditformat(arguments.value)#" size="8" />';
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
		type="LIKE",
		field: arguments.row["feature_field_variable_name"],
		arrValue:[]
	};
	if(arguments.value NEQ ""){
		arrayAppend(ts.arrValue, '%'&arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]]&'%');
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
		return arguments.databaseField&' like '&db.trustedSQL("'%"&application.zcore.functions.zescape(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]])&"%'");
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
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);  
	if(nv NEQ "" and not application.zcore.functions.zEmailValidate(nv)){
		return { success:false, message: arguments.row["feature_field_display_name"]&" must be a valid email address." };
	}
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
	v='<input type="email" name="#arguments.prefixString##arguments.row["feature_field_id"]#" id="#arguments.prefixString##arguments.row["feature_field_id"]#" ';
	size=arguments.row["feature_field_character_width"];
	if(size NEQ 0){
		v&=' size="#size#" style="min-width:auto; width:auto;" ';
	}else{
		v&=' style="width:95%;" ';
	}
	v&=' value="#htmleditformat(application.zcore.functions.zso(arguments.dataStruct, '#arguments.prefixString##arguments.row["feature_field_id"]#'))#" />';
	return { label: true, hidden: false, value:v};  
	</cfscript> 
</cffunction>


<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return '
	<cfscript>
	v=''<input type="email" name="#arguments.fieldName#" id="#arguments.fieldName#" '';
	size=#arguments.row["feature_field_character_width"]#;
	if(size NEQ 0){
		v&='' size="##size##" style="min-width:auto; width:auto;" '';
	}else{
		v&='' style="width:95%;" '';
	}
	v&='' value="##htmleditformat(application.zcore.functions.zso(form, "#arguments.fieldName#"))##" />'';
	echo(v);
	</cfscript>
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
	return 'Email';
	</cfscript>
</cffunction>

<cffunction name="onUpdate" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	var error=false;
	if(false){
		application.zcore.status.setStatus(request.zsid, "Message");
		error=true;
	}
	if(error){
		application.zcore.status.setStatus(Request.zsid, false,arguments.dataStruct,true);
		return { success:false};
	}
	arguments.dataStruct["feature_field_type_json"]="{}";
	return { success:true, typeStruct: {}};
	</cfscript>
</cffunction>
		
<cffunction name="getFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
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
	<input type="radio" name="feature_field_type_id" value="10" onClick="setType(10);" <cfif value EQ "10">checked="checked"</cfif>/>
	Email<br />
	</cfsavecontent>
	<cfreturn output>
</cffunction> 

<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` varchar(100) NOT NULL";
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>