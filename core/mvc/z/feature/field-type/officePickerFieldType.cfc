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
	return "1";
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
	db=request.zos.queryObject;
	db.sql="SELECT * 
	FROM #db.table("office", request.zos.zcoreDatasource)# 
	WHERE feature_id=#db.param(form.feature_id)# and 
	office_deleted = #db.param(0)#
	ORDER BY office_name";
	qOffice=db.execute("qOffice");

	savecontent variable="out"{
		selectStruct = StructNew();
		selectStruct.name = arguments.prefixString&arguments.row["feature_field_id"];
		selectStruct.query = qOffice;
		selectStruct.selectedValues=application.zcore.functions.zso(arguments.dataStruct, '#arguments.prefixString##arguments.row["feature_field_id"]#');
		selectStruct.queryParseLabelVars=true;
		selectStruct.queryParseValueVars=true; 
		selectStruct.queryLabelField = "##office_name##"; 
		selectStruct.inlineStyle="width:200px; max-width:100%;";
		selectStruct.queryValueField = "##office_id##";
		selectStruct.output=true; 
		selectStruct.size=3;
		application.zcore.skin.addDeferredScript("  $('###selectStruct.name#').filterByText($('###selectStruct.name#_InputField'), true); "); 

		echo('Search: <input type="text" name="#selectStruct.name#_InputField" id="#selectStruct.name#_InputField" value="" style="min-width:auto;width:200px; max-width:100%; margin-bottom:5px;"><br />Select:<br />');
		value=application.zcore.functions.zInputSelectBox(selectStruct); 
	}
	return out; 
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
	if(arguments.value NEQ ""){
		return db.trustedSQL("concat(',', "&arguments.databaseField&", ',') like '%,"&application.zcore.functions.zescape(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]])&",%'");
	}
	return '';
	</cfscript>
</cffunction>

<cffunction name="searchFilter" localmode="modern" access="public">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldValue" type="string" required="yes"> 
	<cfargument name="searchValue" type="string" required="yes">
	<cfscript>
	if(arguments.searchValue NEQ "" and ","&arguments.fieldValue&"," DOES NOT CONTAIN ","&arguments.searchValue&","){
		return false;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="validateFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	/*
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
	if(nv NEQ "" and doValidation...){
		return { success:false, message: arguments.row["feature_field_display_name"]&" must ..." };
	}
	*/
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
	db=request.zos.queryObject;
	db.sql="SELECT * 
	FROM #db.table("office", request.zos.zcoreDatasource)# 
	WHERE feature_id=#db.param(form.feature_id)# and 
	office_deleted = #db.param(0)# 
	ORDER BY office_name";
	qOffice=db.execute("qOffice");
	selectStruct = StructNew();
	selectStruct.name = arguments.prefixString&arguments.row["feature_field_id"];
	selectStruct.query = qOffice;
	selectStruct.selectedValues=application.zcore.functions.zso(arguments.dataStruct, '#arguments.prefixString##arguments.row["feature_field_id"]#');
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryParseValueVars=true;
	selectStruct.queryLabelField = "##office_name##";
	selectStruct.queryValueField = "##office_id##";
	selectStruct.output=false; 
	if(application.zcore.functions.zso(arguments.typeStruct, "office_multipleselection") EQ "Yes"){ 
		selectStruct.multiple=true;
		selectStruct.size=5;
		selectStruct.hideSelect=true;
		application.zcore.functions.zSetupMultipleSelect(selectStruct.name, selectStruct.selectedValues); 
	}else{ 
		selectStruct.size=5;
		application.zcore.skin.addDeferredScript('  $("###selectStruct.name#").filterByText($("###selectStruct.name#_InputField"), true); '); 
	} 
	if(arguments.row.feature_field_required EQ 1){
		selectStruct.required=true;
	}
	value=application.zcore.functions.zInputSelectBox(selectStruct);
	if(not selectStruct.multiple){
 
		value='Search: <input type="text" name="#selectStruct.name#_InputField" id="#selectStruct.name#_InputField" value="" style="width:200px; min-width:auto; margin-bottom:5px;"><br />Select:<br />'&value; 
	} 
	return { label: true, hidden: false, value:value};  
	</cfscript>
</cffunction>

<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	arrV=[]; 
	arrayAppend(arrV, '
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT * 
	FROM ##db.table("office", request.zos.zcoreDatasource)## 
	WHERE site_id = ##db.param(request.zos.globals.id)## and 
	office_deleted = ##db.param(0)## 
	ORDER BY office_name";
	qOffice=db.execute("qOffice");
	selectStruct = StructNew();
	selectStruct.name = "#arguments.fieldName#";
	selectStruct.query = qOffice;
	selectStruct.selectedValues=application.zcore.functions.zso(form, "#arguments.fieldName#");
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryParseValueVars=true;
	selectStruct.queryLabelField = "####office_name####";
	selectStruct.queryValueField = "####office_id####";
	selectStruct.output=false;
	');
	if(application.zcore.functions.zso(arguments.typeStruct, "office_multipleselection") EQ "Yes"){
		arrayAppend(arrV, ' 
		selectStruct.multiple=true;
		selectStruct.size=5;
		selectStruct.hideSelect=true;
		application.zcore.functions.zSetupMultipleSelect(selectStruct.name, selectStruct.selectedValues);
		');
	}else{
		arrayAppend(arrV, ' 
		selectStruct.size=5;
		application.zcore.skin.addDeferredScript(''  $("######selectStruct.name##").filterByText($("######selectStruct.name##_InputField"), true); '');
		');
	}

	arrayAppend(arrV, ' 
	value=application.zcore.functions.zInputSelectBox(selectStruct);
	if(not selectStruct.multiple){
 
		value=''Search: <input type="text" name="##selectStruct.name##_InputField" id="##selectStruct.name##_InputField" value="" style="width:200px; min-width:auto; margin-bottom:5px;"><br />Select:<br />''&value; 
	}
 
	echo(value);
	</cfscript>
	');
	return arrayToList(arrV, " ");
	</cfscript>
</cffunction>

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	returnValue="";
	arrOffice=listToArray(arguments.value, ","); 
	if(arguments.value NEQ ""){
		db.sql="select group_concat(office_name separator #db.param(", ")#) officeName from #db.table("office", request.zos.zcoreDatasource)# 
		where feature_id=#db.param(form.feature_id)# and 
		office_id IN (";
		for(i=1;i<=arraylen(arrOffice);i++){
			if(i NEQ 1){
				db.sql&=", ";
			}
			db.sql&=" #db.param(arrOffice[i])# ";
		}
		db.sql&=") and office_deleted = #db.param(0)#  ";
		qOffice=db.execute("qOffice");
		if(qOffice.recordcount NEQ 0){ 
			returnValue=qOffice.officeName; 
		}
	}
	return returnValue; 
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
	<cfargument name="dataFields" type="struct" required="yes">
	<cfscript>	
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
	return { success: true, value: nv, dateValue: "" };
	</cfscript>
</cffunction>

<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="dataFields" type="struct" required="yes">
	<cfscript>
	return application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
	<cfscript>
	return 'Office Picker';
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
		office_multipleselection:application.zcore.functions.zso(form, 'office_multipleselection')
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, typeStruct: ts};
	</cfscript>
</cffunction>
		

<cffunction name="getFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={ 
		office_multipleselection:"No"
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
		<script>
		function validateFieldType27(postObj, arrError){    
		}
		</script>
	<input type="radio" name="feature_field_type_id" value="27" onClick="setType(27);" <cfif value EQ "27">checked="checked"</cfif>/>
	Office Picker<br />
		<div id="typeFields27" style="display:none;padding-left:30px;"> 
			<table style="border-spacing:0px;"> 
			<tr><td>Multiple Selections: </td><td>
			<cfscript>
			arguments.typeStruct.office_multipleselection=application.zcore.functions.zso(arguments.typeStruct, 'office_multipleselection', false, "No");
			if(arguments.typeStruct.office_multipleselection EQ ""){
				arguments.typeStruct.office_multipleselection="No";
			}
			var ts = StructNew();
			ts.name = "office_multipleselection";
			ts.style="border:none;background:none;";
			ts.labelList = "Yes,No";
			ts.valueList = "Yes,No";
			ts.hideSelect=true;
			ts.struct=arguments.typeStruct;
			writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
			</cfscript>
			</td></tr>
			</table>
		</div>
	</cfsavecontent>
	<cfreturn output>
</cffunction> 

<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` varchar(255) NOT NULL DEFAULT ''";
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>