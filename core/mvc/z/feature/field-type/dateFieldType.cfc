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
	return dateformat(now(), "m/d/yyyy");
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
	return "s"&arguments.fieldIndex&".#variables.siteType#_x_option_group_date_value "&arguments.sortDirection;
	</cfscript>
</cffunction>

<cffunction name="getSearchFieldName" localmode="modern" access="public" returntype="string" output="no">
	<cfargument name="setTableName" type="string" required="yes">
	<cfargument name="groupTableName" type="string" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfscript>
	searchType=application.zcore.functions.zso(arguments.typeStruct, 'datetime_range_search_type', true, 0);
	if(searchType EQ 1){
		// start date
		request.zos.featureFieldSearchDateRangeSortEnabled=true;
		return arguments.setTableName&".#variables.siteType#_x_option_group_set_start_date";
	}else if(searchType EQ 2){
		// end date
		request.zos.featureFieldSearchDateRangeSortEnabled=true;
		return arguments.setTableName&".#variables.siteType#_x_option_group_set_end_date";
	}else{
		return arguments.groupTableName&".#variables.siteType#_x_option_group_value";
	}
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
	application.zcore.functions.zRequireJqueryUI();
	savecontent variable="js"{
		echo(' $( "###arguments.prefixString&arguments.row["feature_field_id"]#" ).datepicker();');
	}
	if(structkeyexists(form, 'x_ajax_id')){
		js='<script>/* <![CDATA[ */'&js&'/* ]]> */</script>';
	}else{
		application.zcore.skin.addDeferredScript(js);
		js='';
	}
	return '<input type="text" name="#arguments.prefixString##arguments.row["feature_field_id"]#" onchange="#arguments.onChangeJavascript#" onkeyup="#arguments.onChangeJavascript#" onpaste="#arguments.onChangeJavascript#" id="#arguments.prefixString##arguments.row["feature_field_id"]#" value="#htmleditformat(dateformat(arguments.value, 'mm/dd/yyyy'))#" size="9" style="width:60px; min-width:60px;" />'&js;
	</cfscript>
</cffunction>


<cffunction name="getSearchValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	local.curDate="";
	if(structkeyexists(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_date')){
		local.tempDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_date');
		arguments.searchStruct[arguments.prefixString&arguments.row["feature_field_id"]&"_date"]=local.tempDate;
	}else{
		local.tempDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
		arguments.searchStruct[arguments.prefixString&arguments.row["feature_field_id"]]=local.tempDate;
	}
	if(local.tempDate NEQ "" and isdate(local.tempDate)){
		try{
			local.curDate=dateformat(local.tempDate, "yyyy-mm-dd");
		}catch(Any local.e){
			// ignore
		}
	}
	var finalDate=0;
	if(local.curDate EQ ""){
		if(arguments.row["feature_field_admin_search_default"] NEQ "" and isnumeric(arguments.row["feature_field_admin_search_default"])){
			finalDate=dateadd("d", arguments.row["feature_field_admin_search_default"], now());
		}else{
			finalDate="";	
		}
	}else{
		finalDate=parsedatetime(local.curDate&" 00:00:00");
	}
	return finalDate;
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
		if(structkeyexists(arguments.typeStruct, 'datetime_range_search_type') and arguments.typeStruct.datetime_range_search_type EQ 1){
			// start date
			ts.type=">=";
			arrayAppend(ts.arrValue, dateformat(arguments.value, 'yyyy-mm-dd')&' 00:00:00');
		}else if(structkeyexists(arguments.typeStruct, 'datetime_range_search_type') and arguments.typeStruct.datetime_range_search_type EQ 2){
			// end date
			ts.type="<=";
			arrayAppend(ts.arrValue, dateformat(arguments.value, 'yyyy-mm-dd')&' 23:59:59');
		}else{
			arrayAppend(ts.arrValue, dateformat(arguments.value, 'yyyy-mm-dd')&' 00:00:00');
		}
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
		if(structkeyexists(arguments.typeStruct, 'datetime_range_search_type') and arguments.typeStruct.datetime_range_search_type EQ 1){
			// start date
			return arguments.databaseDateField&' >= '&db.trustedSQL("'"&application.zcore.functions.zescape(dateformat(arguments.value, 'yyyy-mm-dd')&' 00:00:00')&"'");
		}else if(structkeyexists(arguments.typeStruct, 'datetime_range_search_type') and arguments.typeStruct.datetime_range_search_type EQ 2){
			// end date
			return arguments.databaseDateField&' <= '&db.trustedSQL("'"&application.zcore.functions.zescape(dateformat(arguments.value, 'yyyy-mm-dd')&' 23:59:59')&"'");
		}else{
			return arguments.databaseDateField&' = '&db.trustedSQL("'"&application.zcore.functions.zescape(dateformat(arguments.value, 'yyyy-mm-dd')&' 00:00:00')&"'");
		}
	}
	return db.trustedSQL(' 1 = 1 ');
	</cfscript>
</cffunction>

<cffunction name="searchFilter" localmode="modern" access="public">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldValue" type="string" required="yes"> 
	<cfargument name="searchValue" type="string" required="yes">
	<cfscript>
	if(arguments.searchValue EQ ""){
		return true;
	}
	if(not isDate(arguments.fieldValue) or not isDate(arguments.searchValue)){
		return false;
	}
	fieldDateTime=dateformat(arguments.fieldValue, "yyyymmdd");
	searchDateTime=dateformat(arguments.searchValue, "yyyymmdd");
	if(structkeyexists(arguments.typeStruct, 'datetime_range_search_type') and arguments.typeStruct.datetime_range_search_type EQ 1){
		// start date
		if(fieldDateTime < searchDateTime){
			return false;
		}
	}else if(structkeyexists(arguments.typeStruct, 'datetime_range_search_type') and arguments.typeStruct.datetime_range_search_type EQ 2){
		// end date
		if(fieldDateTime > searchDateTime){
			return false;
		}
	}else if(fieldDateTime NEQ searchDateTime){
		return false;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript>
	var cfcatch=0;
	var excpt=0;
	var curDate="";
	try{
		if(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_date') NEQ ""){
			curDate=dateformat(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]&'_date'], "mm/dd/yyyy");
		}else if(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]) NEQ ""){
			curDate=dateformat(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]], "mm/dd/yyyy");
		} 
	}catch(Any excpt){
		curDate="";
	}
	application.zcore.functions.zRequireJqueryUI();
	/*
	arguments.typeStruct=duplicate(arguments.typeStruct);
	arguments.typeStruct.datetime_min_offset=0;
	arguments.typeStruct.datetime_max_offset=7;
	*/
	initValues="{";
	if(structkeyexists(arguments.typeStruct, 'datetime_max_offset') and arguments.typeStruct.datetime_max_offset NEQ ""){
		arrMaxDate=listToArray(dateformat(dateadd("d", arguments.typeStruct.datetime_max_offset, now()), 'yyyy,m,d'));
		maxDate=arrMaxDate[1]&","&(arrMaxDate[2]-1)&","&arrMaxDate[3];
		initValues&="maxDate:new Date(#maxDate#)";
	}
	if(structkeyexists(arguments.typeStruct, 'datetime_min_offset') and arguments.typeStruct.datetime_min_offset NEQ ""){
		arrMinDate=listToArray(dateformat(dateadd("d", arguments.typeStruct.datetime_min_offset, now()), 'yyyy,m,d'));
		minDate=arrMinDate[1]&","&(arrMinDate[2]-1)&","&arrMinDate[3];
		if(right(initValues, 1) NEQ "{"){
			initValues&=", ";
		}
		initValues&=" minDate:new Date(#minDate#) ";
	}
	initValues&="}";
	application.zcore.skin.addDeferredScript('$( "###arguments.prefixString##arguments.row["feature_field_id"]#_date" ).datepicker(#initValues#);');
	required="";
	if(arguments.row.feature_field_required EQ 1){
		required="required";
	}
	return { label: true, hidden: false, value:'<input #required# type="text" name="#arguments.prefixString&arguments.row["feature_field_id"]#_date" id="#arguments.prefixString&arguments.row["feature_field_id"]#_date" style="width:auto; min-width:auto;" value="#curDate#" size="9" />'};
	</cfscript>
</cffunction>

<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return '
	<cfscript>
	var cfcatch=0;
	var excpt=0;
	var curDate="";
	try{
		if(application.zcore.functions.zso(form, "#arguments.fieldName#") NEQ ""){
			curDate=dateformat(form["#arguments.fieldName#"], "mm/dd/yyyy");
		} 
	}catch(Any excpt){
		curDate="";
	}
	application.zcore.functions.zRequireJqueryUI();
	application.zcore.skin.addDeferredScript(''$( "#####arguments.fieldName#" ).datepicker();'');
	echo(''<input type="text" name="#arguments.fieldName#" id="#arguments.fieldName#" style="width:auto; min-width:auto;" value="##curDate##" size="9" />'');
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
	<cfargument name="dataFields" type="struct" required="yes">
	<cfscript>	
	var cfcatch=0;
	var excpt=0; 
	var curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_date');
	if(curDate EQ ""){
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
		if(curDate EQ ""){
			return { success: true, value: "", dateValue: "" };
		}
	}
	try{
		var nvdate=dateformat(curDate, "yyyy-mm-dd")&" 00:00:00";
		var nv=dateformat(curDate, "m/d/yyyy");
	}catch(Any excpt){
		application.zcore.status.setStatus(request.zsid, arguments.row["feature_field_variable_name"]&" must be a valid date.", form, true);
		return { success: false, message: arguments.row["feature_field_variable_name"]&" must be a valid date.", value: "", dateValue: "" };
	}
	return { success: true, value: nv, dateValue: nvdate };
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


<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="dataFields" type="struct" required="yes">
	<cfscript>
	if(structkeyexists(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_date')){
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_date');
		if(isDate(curDate)){
			return dateformat(curDate, "yyyy-mm-dd");
		}else{
			return "";
		}
	}else{
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
		if(isDate(curDate)){
			return dateformat(curDate, "yyyy-mm-dd");
		}else{
			return "";
		}
	}
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
	<cfscript>
	return 'Date';
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
		datetime_range_search_type:application.zcore.functions.zso(arguments.dataStruct, 'datetime_range_search_type'),
		datetime_min_offset:application.zcore.functions.zso(arguments.dataStruct, 'datetime_min_offset'),
		datetime_max_offset:application.zcore.functions.zso(arguments.dataStruct, 'datetime_max_offset')
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, typeStruct: ts};
	</cfscript>
</cffunction>
		
<cffunction name="getFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		datetime_range_search_type:"0",
		datetime_min_offset:"",
		datetime_max_offset:""
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
	<input type="radio" name="feature_field_type_id" value="5" onClick="setType(5);" <cfif value EQ 5>checked="checked"</cfif>/>
	Date<br />
	<div id="typeFields5" style="display:none;padding-left:30px;"> 
		<p>Leave these values empty to disable date range restriction on the datepicker.<p>
		<p>Min Date Offset in Days: <input type="text" name="datetime_min_offset" id="datetime_min_offset" value="#application.zcore.functions.zso(arguments.typeStruct, 'datetime_min_offset')#" style="width:100px; min-width:auto;"></p>
		<p>Max Date Offset in Days: 
		<input type="text" name="datetime_max_offset" id="datetime_max_offset" value="#application.zcore.functions.zso(arguments.typeStruct, 'datetime_max_offset')#" style="width:100px; min-width:auto;"></p>
	</div>	
	</cfsavecontent>
	<cfreturn output>
</cffunction>

<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` date NOT NULL DEFAULT '0000-00-00'";
	</cfscript>
</cffunction> 
</cfoutput>
</cfcomponent>