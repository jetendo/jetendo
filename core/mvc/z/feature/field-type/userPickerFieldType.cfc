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
	return "1|1";
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
<cffunction name="onBeforeImport" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
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
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfargument name="value" type="string" required="yes">
	<cfargument name="onChangeJavascript" type="string" required="yes">
	<cfscript>
	arrSchema=listToArray(application.zcore.functions.zso(arguments.optionStruct, 'user_group_id_list'), ',');
	for(i=1;i LTE arraylen(arrSchema);i++){
		arrSchema[i]=application.zcore.functions.zescape(arrSchema[i]);
	}
	userSchemaIdSQL="'"&arrayToList(arrSchema, "','")&"'";
	db=request.zos.queryObject;
	db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("user.site_id"))# as siteIDType
	FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE feature_id=#db.param(form.feature_id)# and 
	user_deleted = #db.param(0)# ";
	if(arrayLen(arrSchema)){
		db.sql&=" and user_group_id in ("&db.trustedSQL(userSchemaIdSQL)&")";
	}
	db.sql&=" ORDER BY user_first_name, user_last_name, user_username";
	qUser=db.execute("qUser");

	savecontent variable="out"{
		selectStruct = StructNew();
		selectStruct.name = arguments.prefixString&arguments.row["feature_field_id"];
		selectStruct.query = qUser;
		selectStruct.selectedValues=application.zcore.functions.zso(arguments.dataStruct, '#arguments.prefixString##arguments.row["feature_field_id"]#');
		selectStruct.queryParseLabelVars=true;
		selectStruct.queryParseValueVars=true;
		if(arguments.optionStruct.user_displaytype EQ 0){
			selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##)";
		}else if(arguments.optionStruct.user_displaytype EQ 1){
			selectStruct.queryLabelField = "##member_company## (##user_username##)";
		}else if(arguments.optionStruct.user_displaytype EQ 2){
			selectStruct.queryLabelField = "##user_username##";
		}
		selectStruct.inlineStyle="width:200px; max-width:100%;";
		selectStruct.queryValueField = "##user_id##|##siteIdType##";
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
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	return arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]];
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
	if(arguments.value NEQ ""){
		return db.trustedSQL("concat(',', "&arguments.databaseField&", ',') like '%,"&application.zcore.functions.zescape(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]])&",%'");
		//return arguments.databaseField&' like '&db.trustedSQL("'%"&application.zcore.functions.zescape(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]])&"%'");
	}
	return '';
	</cfscript>
</cffunction>

<cffunction name="validateFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
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
	<cfargument name="optionStruct" type="struct" required="yes">
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
	arrSchema=listToArray(application.zcore.functions.zso(arguments.optionStruct, 'user_group_id_list'), ',');
	for(i=1;i LTE arraylen(arrSchema);i++){
		arrSchema[i]=application.zcore.functions.zescape(arrSchema[i]);
	}
	userSchemaIdSQL="'"&arrayToList(arrSchema, "','")&"'";
	db=request.zos.queryObject;
	db.sql="SELECT *, #db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("user.site_id"))# as siteIDType
	FROM #db.table("user", request.zos.zcoreDatasource)# user 
	WHERE feature_id=#db.param(form.feature_id)# and 
	user_deleted = #db.param(0)# ";
	if(arrayLen(arrSchema)){
		db.sql&=" and user_group_id in ("&db.trustedSQL(userSchemaIdSQL)&")";
	}
	db.sql&=" ORDER BY user_first_name, user_last_name, user_username";
	qUser=db.execute("qUser");
	selectStruct = StructNew();
	selectStruct.name = arguments.prefixString&arguments.row["feature_field_id"];
	selectStruct.query = qUser;
	selectStruct.selectedValues=application.zcore.functions.zso(arguments.dataStruct, '#arguments.prefixString##arguments.row["feature_field_id"]#');
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryParseValueVars=true;
	if(arguments.optionStruct.user_displaytype EQ 0){
		selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##)";
	}else if(arguments.optionStruct.user_displaytype EQ 1){
		selectStruct.queryLabelField = "##member_company## (##user_username##)";
	}else if(arguments.optionStruct.user_displaytype EQ 2){
		selectStruct.queryLabelField = "##user_username##";
	}
	selectStruct.queryValueField = "##user_id##|##siteIdType##";
	selectStruct.output=false;
	if(application.zcore.functions.zso(arguments.optionStruct, 'user_multipleselection') EQ 'Yes'){
		selectStruct.multiple=true;
		selectStruct.size=5;
		selectStruct.hideSelect=true;
		application.zcore.functions.zSetupMultipleSelect(selectStruct.name, selectStruct.selectedValues);
	}else{
		selectStruct.size=5;
		application.zcore.skin.addDeferredScript("  $('###selectStruct.name#').filterByText($('###selectStruct.name#_InputField'), true); ");
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
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	arrV=[];
	arrSchema=listToArray(application.zcore.functions.zso(arguments.optionStruct, 'user_group_id_list'), ',');
	for(i=1;i LTE arraylen(arrSchema);i++){
		arrSchema[i]=application.zcore.functions.zescape(arrSchema[i]);
	}
	userSchemaIdSQL="'"&arrayToList(arrSchema, "','")&"'";
	arrayAppend(arrV, '
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT *, ##db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("user.site_id"))## as siteIDType
	FROM ##db.table("user", request.zos.zcoreDatasource)## user 
	WHERE site_id = ##db.param(request.zos.globals.id)## and 
	user_deleted = ##db.param(0)## ";
	');
	if(arrayLen(arrSchema)){
		arrayAppend(arrV, ' 
		db.sql&=" and user_group_id in ("&db.trustedSQL(#userSchemaIdSQL#)&")";
		');
	}
	arrayAppend(arrV, ' 
	db.sql&=" ORDER BY user_first_name, user_last_name, user_username";
	qUser=db.execute("qUser");
	selectStruct = StructNew();
	selectStruct.name = "#arguments.fieldName#";
	selectStruct.query = qUser;
	selectStruct.selectedValues=application.zcore.functions.zso(form, "#arguments.fieldName#");
	selectStruct.queryParseLabelVars=true;
	selectStruct.queryParseValueVars=true;
	');
	if(arguments.optionStruct.user_displaytype EQ 0){
		arrayAppend(arrV, ' 
		selectStruct.queryLabelField = "####user_first_name#### ####user_last_name#### (####user_username####)";
		');
	}else if(arguments.optionStruct.user_displaytype EQ 1){
		arrayAppend(arrV, ' 
		selectStruct.queryLabelField = "####member_company#### (####user_username####)";
		');
	}else if(arguments.optionStruct.user_displaytype EQ 2){
		arrayAppend(arrV, ' 
		selectStruct.queryLabelField = "####user_username####";
		');
	}
	arrayAppend(arrV, ' 
	selectStruct.queryValueField = "####user_id####|####siteIdType####";
	selectStruct.output=false;
	');
	if(application.zcore.functions.zso(arguments.optionStruct, "user_multipleselection") EQ "Yes"){
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
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	returnValue="";
	arrUser=listToArray(arguments.value, "|");
	if(arraylen(arrUser) EQ 2){
		db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user 
		where site_id = #db.param(application.zcore.functions.zGetSiteIdFromSiteIdType(arrUser[2]))# and 
		user_deleted = #db.param(0)# and
		user_id = #db.param(arrUser[1])# ";
		qUser=db.execute("qUser");
		if(qUser.recordcount NEQ 0){
			if(arguments.optionStruct.user_displaytype EQ 0){
				returnValue=qUser.user_first_name&" "&qUser.user_last_name&" ("&qUser.user_username&")";
			}else if(arguments.optionStruct.user_displaytype EQ 1){
				returnValue= qUser.member_company&" ("&qUser.user_username&")";
			}else if(arguments.optionStruct.user_displaytype EQ 2){
				returnValue=qUser.user_username;
			}
		}
	}
	return returnValue; 
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

<cffunction name="onBeforeUpdate" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes"> 
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
	return 'User Picker';
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
		user_group_id_list:application.zcore.functions.zso(arguments.dataStruct, 'user_group_id_list'),
		user_displaytype:application.zcore.functions.zso(form, 'user_displaytype'),
		user_multipleselection:application.zcore.functions.zso(form, 'user_multipleselection')
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, optionStruct: ts};
	</cfscript>
</cffunction>
		

<cffunction name="getFieldFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		user_group_id_list:"0",
		user_displaytype:"",
		user_multipleselection:"No"
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
		function validateFieldType16(postObj, arrError){   
			if(postObj.user_group_id_list == ''){
				arrError.push('You must select at least one user group in the Limit User Schemas field.');
			}
		}
		</script>
	<input type="radio" name="feature_field_type_id" value="16" onClick="setType(16);" <cfif value EQ "16">checked="checked"</cfif>/>
	User Picker<br />
		<div id="typeFields16" style="display:none;padding-left:30px;"> 
			<table style="border-spacing:0px;">
			<tr><td>Display Type: </td><td>
			<cfscript>
			arguments.optionStruct.user_displaytype=application.zcore.functions.zso(arguments.optionStruct, 'user_displaytype', true, 0);
			var ts = StructNew();
			ts.name = "user_displaytype";
			ts.style="border:none;background:none;";
			ts.labelList = "First/Last Name/Email,Company/Email,Email";
			ts.valueList = "0,1,2";
			ts.hideSelect=true;
			ts.struct=arguments.optionStruct;
			writeoutput(application.zcore.functions.zInput_RadioSchema(ts));
			</cfscript>
			</td></tr>
			<tr><td style="vertical-align:top;">Limit User Schemas: </td>
			<td>
			<cfscript>
			form.user_group_id_list=application.zcore.functions.zso(arguments.optionStruct, 'user_group_id_list');
			db.sql="SELECT *FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
			WHERE feature_id=#db.param(form.feature_id)#  and 
			user_group_deleted = #db.param(0)#
			ORDER BY user_group_name asc"; 
			var qSchema2=db.execute("qSchema2"); 
			ts = StructNew();
			ts.name = "user_group_id_list";
			ts.friendlyName="";
			// options for query data
			ts.query = qSchema2;
			ts.queryLabelField = "user_group_friendly_name";
			ts.queryValueField = "user_group_id";
			writeoutput(application.zcore.functions.zInput_Checkbox(ts));
			</cfscript></td></tr>
			<tr><td>Multiple Selections: </td><td>
			<cfscript>
			arguments.optionStruct.user_multipleselection=application.zcore.functions.zso(arguments.optionStruct, 'user_multipleselection', false, "No");
			if(arguments.optionStruct.user_multipleselection EQ ""){
				arguments.optionStruct.user_multipleselection="No";
			}
			var ts = StructNew();
			ts.name = "user_multipleselection";
			ts.style="border:none;background:none;";
			ts.labelList = "Yes,No";
			ts.valueList = "Yes,No";
			ts.hideSelect=true;
			ts.struct=arguments.optionStruct;
			writeoutput(application.zcore.functions.zInput_RadioSchema(ts));
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