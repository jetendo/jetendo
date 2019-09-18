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
	return "";
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
	return "";
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

<cffunction name="isCopyable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
	</cfscript>
</cffunction>

<cffunction name="isSearchable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return false;
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
	return '';
	</cfscript>
</cffunction>


<cffunction name="getSearchValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	return '';
	</cfscript>
</cffunction>

<cffunction name="getSearchSQLStruct" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript> 
	ts={};
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
	return '';
	</cfscript>
</cffunction>

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">  
	<cfscript>
	ts={
		name:arguments.prefixString&arguments.row["feature_field_id"],
		selector:arguments.typeStruct.styleset_selector,
		editFonts:arguments.typeStruct.styleset_fonts,
		editSizes:arguments.typeStruct.styleset_sizes,
		editSpaces:arguments.typeStruct.styleset_spaces,
		editColors:arguments.typeStruct.styleset_colors,
		editBreakpoints:arguments.typeStruct.styleset_breakpoints,
		externalStylesheet:arguments.typeStruct.styleset_external_stylesheet
	};
	styleEditorCom=createObject("component", "zcorerootmapping.mvc.z.misc.controller.styleEditor");
	return { label: true, hidden: false, value: styleEditorCom.zStylesetEditor(ts)};  
	</cfscript>
</cffunction>

<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return ' 
	styleset not implemented for generator yet
	';
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
	return 'Style Editor';
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
	ts={
		styleset_selector:application.zcore.functions.zso(arguments.dataStruct, 'styleset_selector'),
		styleset_fonts:application.zcore.functions.zso(arguments.dataStruct, 'styleset_fonts'),
		styleset_sizes:application.zcore.functions.zso(arguments.dataStruct, 'styleset_sizes'),
		styleset_spaces:application.zcore.functions.zso(arguments.dataStruct, 'styleset_spaces'),
		styleset_colors:application.zcore.functions.zso(arguments.dataStruct, 'styleset_colors'),
		styleset_breakpoints:application.zcore.functions.zso(arguments.dataStruct, 'styleset_breakpoints'),
		styleset_external_stylesheet:application.zcore.functions.zso(arguments.dataStruct, 'styleset_external_stylesheet')
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, typeStruct: ts};
	</cfscript>
</cffunction>
		

<cffunction name="getFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		styleset_selector:"",
		styleset_fonts:"",
		styleset_sizes:"",
		styleset_spaces:"",
		styleset_colors:"",
		styleset_breakpoints:"",
		styleset_external_stylesheet:""
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
	db.sql="select * from #db.table("feature_field", request.zos.zcoreDatasource)# WHERE 
	feature_id=#db.param(form.feature_id)# and 
	feature_field_deleted = #db.param(0)# and
	feature_schema_id = #db.param(arguments.dataStruct["feature_schema_id"])# 	
	ORDER BY feature_field_variable_name ASC";
	qSchema=db.execute("qSchema");
	</cfscript>
	<cfsavecontent variable="output">
		<script type="text/javascript">
		function validateFieldType24(postObj, arrError){  
		}
		</script>
	<input type="radio" name="feature_field_type_id" value="24" onClick="setType(24);" <cfif value EQ 24>checked="checked"</cfif>/>
	#this.getTypeName()#<br />
	<div id="typeFields24" style="display:none;padding-left:30px;">  
		<table class="table-list">
		<tr>
			<td>
		CSS Selector Prefix: </td><td>
			<input type="text" name="styleset_selector" value="#htmleditformat(application.zcore.functions.zso(form, "styleset_selector"))#"><br><br>
			The selector must be a valid CSS selector which be prefixed to all the styles generated.
		</td></tr> 
		<tr><td>
		Fonts: </td><td>
			#application.zcore.functions.zInput_Boolean("styleset_fonts")#
		</td></tr>
		<tr>
			<td>
		Sizes: </td><td>
			#application.zcore.functions.zInput_Boolean("styleset_sizes")#
		</td></tr>
		<tr>
			<td>
		Spaces: </td><td>
			#application.zcore.functions.zInput_Boolean("styleset_spaces")#
		</td></tr>
		<tr>
			<td>
		Colors: </td><td>
			#application.zcore.functions.zInput_Boolean("styleset_colors")#
		</td></tr>
		<tr>
			<td>
		Breakpoints: </td><td>
			#application.zcore.functions.zInput_Boolean("styleset_breakpoints")#
		</td></tr> 
		<tr>
			<td>
		External Stylesheet: </td><td>
			#application.zcore.functions.zInput_Boolean("styleset_external_stylesheet")#
		</td></tr> 
		</table>
	</div>
	</cfsavecontent>
	<cfreturn output>
</cffunction> 

<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` varchar(80) NOT NULL";
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>