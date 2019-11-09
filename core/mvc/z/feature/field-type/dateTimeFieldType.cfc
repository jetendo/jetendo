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
	return dateformat(now(), "m/d/yyyy")&" "&timeformat(now(), "h:mm tt");
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


<cffunction name="isSearchable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
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
	application.zcore.functions.zRequireJqueryUI();
	if(structkeyexists(arguments.typeStruct, 'datetime_range_search_type') and (arguments.typeStruct.datetime_range_search_type EQ 1 or arguments.typeStruct.datetime_range_search_type EQ 2)){
		savecontent variable="js"{
			echo(' $( "###arguments.prefixString&arguments.row["feature_field_id"]#" ).datepicker();');
		}
		if(structkeyexists(form, 'x_ajax_id')){
			js='<script>/* <![CDATA[ */'&js&'/* ]]> */</script>';
		}else{
			application.zcore.skin.addDeferredScript(js);
			js='';
		} 
		return '<input type="text" name="#arguments.prefixString##arguments.row["feature_field_id"]#" onchange="#arguments.onChangeJavascript#" onkeyup="#arguments.onChangeJavascript#" onpaste="#arguments.onChangeJavascript#" id="#arguments.prefixString##arguments.row["feature_field_id"]#" value="#htmleditformat(dateformat(arguments.value, 'mm/dd/yyyy'))#" style="width:60px; min-width:60px;" size="9" /> '&js;
	}else{
		savecontent variable="js"{
			echo(' $( "###arguments.prefixString&arguments.row["feature_field_id"]#" ).datepicker();');
			echo(' $( "###arguments.prefixString&arguments.row["feature_field_id"]#_2" ).datepicker();');
		}
		if(structkeyexists(form, 'x_ajax_id')){
			js='<script>/* <![CDATA[ */'&js&'/* ]]> */</script>';
		}else{
			application.zcore.skin.addDeferredScript(js);
			js='';
		}
		arrDate=listToArray(arguments.value, ",");
		if(arraylen(arrDate) EQ 2){
			value1=arrDate[1];
			value2=arrDate[2];
		}else{
			value1=arguments.value;
			value2=arguments.value;
		}
		return '<input type="text" name="#arguments.prefixString##arguments.row["feature_field_id"]#" onchange="#arguments.onChangeJavascript#" onkeyup="#arguments.onChangeJavascript#" onpaste="#arguments.onChangeJavascript#" id="#arguments.prefixString##arguments.row["feature_field_id"]#" value="#htmleditformat(dateformat(value1, 'mm/dd/yyyy'))#" size="9" style="width:60px; min-width:60px;" /> to <input type="text" name="#arguments.prefixString##arguments.row["feature_field_id"]#" onchange="#arguments.onChangeJavascript#" onkeyup="#arguments.onChangeJavascript#" onpaste="#arguments.onChangeJavascript#" id="#arguments.prefixString##arguments.row["feature_field_id"]#_2" value="#htmleditformat(dateformat(value2, 'mm/dd/yyyy'))#" size="9" style="width:60px; min-width:60px;" /> '&js; 
	}
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
			arrayAppend(ts.arrValue, dateformat(arguments.value, 'yyyy-mm-dd')&' 23:59:59');
		}
	}
	return ts;
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
		return arguments.groupTableName&".#variables.siteType#_x_option_group_date_value";
	}
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
			arrDate=listToArray(arguments.value, ",");
			if(arraylen(arrDate) EQ 2){
				return arguments.databaseDateField&' >= '&db.trustedSQL("'"&application.zcore.functions.zescape(dateformat(arrDate[1], 'yyyy-mm-dd')&' 00:00:00')&"' and "&arguments.databaseDateField&" <= '"&application.zcore.functions.zescape(dateformat(arrDate[2], 'yyyy-mm-dd')&' 23:59:59')&"'");
			}else{
				return arguments.databaseDateField&' >= '&db.trustedSQL("'"&application.zcore.functions.zescape(dateformat(arguments.value, 'yyyy-mm-dd')&' 00:00:00')&"' and "&arguments.databaseDateField&" <= '"&application.zcore.functions.zescape(dateformat(arguments.value, 'yyyy-mm-dd')&' 23:59:59')&"'");
			}
		}
	}
	return '';
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
	fieldDateTime=dateformat(arguments.fieldValue, "yyyymmdd")&timeformat(arguments.fieldValue, "HHmmss");
	searchDateTime=dateformat(arguments.searchValue, "yyyymmdd");
	if(structkeyexists(arguments.typeStruct, 'datetime_range_search_type') and arguments.typeStruct.datetime_range_search_type EQ 1){
		// start date
		if(fieldDateTime < searchDateTime&"000000"){
			return false;
		}
	}else if(structkeyexists(arguments.typeStruct, 'datetime_range_search_type') and arguments.typeStruct.datetime_range_search_type EQ 2){
		// end date
		if(fieldDateTime > searchDateTime&"235959"){
			return false;
		}
	}else{
		arrDate=listToArray(arguments.searchValue, ",");
		if(arraylen(arrDate) EQ 2){
			if(not isDate(arguments.fieldValue) or not isDate(arrDate[1]) or not isDate(arrDate[2])){
				return false;
			}
			if(fieldDateTime < arrDate[1]&"000000"){
				return false;
			}
			if(fieldDateTime > arrDate[2]&"235959"){
				return false;
			}
		}else{
			if(fieldDateTime < searchDateTime&"000000"){
				return false;
			}
			if(fieldDateTime > searchDateTime&"235959"){
				return false;
			}
		}
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="getSearchValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	local.curTime="";
	local.curDate="";
	if(structkeyexists(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_date')){
		local.tempDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_date');
		arguments.searchStruct[arguments.prefixString&arguments.row["feature_field_id"]&"_date"]=local.tempDate;
		local.tempTime=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_time'); 
		arguments.searchStruct[arguments.prefixString&arguments.row["feature_field_id"]&"_time"]=local.tempTime;
	}else{
		local.tempDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
		arguments.searchStruct[arguments.prefixString&arguments.row["feature_field_id"]]=local.tempDate;
		local.tempTime="";
	}
	arrDate=listToArray(local.tempDate);
	arrTime=listToArray(local.tempTime);
	arrFinal=[];
	for(i=1;i LTE arraylen(arrDate);i++){
		local.tempDate=arrDate[i];
		if(arraylen(arrTime) GTE i){
			local.tempTime=arrTime[i];
		}else{
			local.tempTime="";
		}
		if(local.tempDate NEQ "" and isdate(local.tempDate)){
			try{
				local.curDate=dateformat(local.tempDate, "yyyy-mm-dd");
			}catch(Any local.e){
				// ignore
			}
		}
		if(local.tempTime NEQ ""){
			try{
				local.curTime=timeformat(local.tempTime, "HH:mm:ss");
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
			if(local.curTime EQ ""){
				finalDate=parsedatetime(local.curDate&" 00:00:00");
			}else{
				finalDate=parsedatetime(local.curDate&" "&local.curTime);
			}
		}
		arrFinal[i]=finalDate;
	}
	return arrayToList(arrFinal, ",");
	</cfscript>
</cffunction>

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript>
	var excpt=0;
	var cfcatch=0;
	var curTime="";
	var curDate="";
	var disableTimeField="#variables.siteType#_x_option_group_disable_time";
	if(arguments.row["#variables.siteType#_x_option_group_id"] EQ ""){
		disableTimeField="#variables.siteType#_x_option_disable_time";
	}
	try{
		if(application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_date') NEQ ""){
			curDate=dateformat(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]&'_date'], "mm/dd/yyyy");
			if(application.zcore.functions.zso(arguments.dataStruct, 'disableTimeField', true, 0) NEQ 1){
				curTime=timeformat(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]&'_time'], "h:mm tt");
			}
		}else if(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]] NEQ ""){
			curDate=dateformat(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]], "mm/dd/yyyy");
			if(application.zcore.functions.zso(arguments.dataStruct, 'disableTimeField', true, 0) NEQ 1){
				curTime=timeformat(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]], "h:mm tt");
			}
		} 
	}catch(Any excpt){
		curDate="";
		curTime="";
	}
	if(structkeyexists(arguments.typeStruct, 'datetime_value_type')){
		if(arguments.typeStruct.datetime_value_type NEQ 0){
			return { label: true, hidden: true, value:'<input type="hidden" name="#arguments.prefixString##arguments.row["feature_field_id"]#" id="#arguments.prefixString##arguments.row["feature_field_id"]#" value="1" />'};
		}
	}
	application.zcore.functions.zRequireTimePicker();
	application.zcore.skin.addDeferredScript('
	$( "###arguments.prefixString&arguments.row["feature_field_id"]#_date" ).datepicker();
	$("###arguments.prefixString&arguments.row["feature_field_id"]#_time").timePicker({
		show24Hours: false,
		step: 15
	});
	');
	required="";
	if(arguments.row.feature_field_required EQ 1){
		required="required";
	}
	return { label: true, hidden: false, value:'<input type="text" #required# name="#arguments.prefixString&arguments.row["feature_field_id"]#_date" id="#arguments.prefixString&arguments.row["feature_field_id"]#_date" value="#curDate#" size="9" style="width:auto; min-width:auto;" size="9" />
	 Time: <input type="text" name="#arguments.prefixString&arguments.row["feature_field_id"]#_time" style="width:auto; min-width:auto;" id="#arguments.prefixString&arguments.row["feature_field_id"]#_time" value="#htmleditformat(curTime)#" size="10" /> (Time is optional)'};
	</cfscript>
</cffunction>

<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	if(structkeyexists(arguments.typeStruct, "datetime_value_type")){
		if(arguments.typeStruct.datetime_value_type NEQ 0){
			return '';
		}
	}
	return '
	<cfscript>
	var excpt=0;
	var cfcatch=0;
	var curTime="";
	var curDate="";
	try{
		if(application.zcore.functions.zso(form, "#arguments.fieldName#_date") NEQ ""){
			curDate=dateformat(form["#arguments.fieldName#_date"], "mm/dd/yyyy");
			if(application.zcore.functions.zso(form, "#arguments.fieldName#_disable_time", true, 0) NEQ 1){
				curTime=timeformat(form["#arguments.fieldName#_time"], "h:mm tt");
			}
		}else if(form["#arguments.fieldName#"] NEQ ""){
			curDate=dateformat(form["#arguments.fieldName#"], "mm/dd/yyyy");
			if(application.zcore.functions.zso(form, "#arguments.fieldName#_disable_time", true, 0) NEQ 1){
				curTime=timeformat(form["#arguments.fieldName#"], "h:mm tt");
			}
		} 
	}catch(Any excpt){
		curDate="";
		curTime="";
	} 
	application.zcore.functions.zRequireTimePicker();
	application.zcore.skin.addDeferredScript(''
	$( "#####arguments.fieldName#_date" ).datepicker();
	$("#####arguments.fieldName#_time").timePicker({
		show24Hours: false,
		step: 15
	});
	'');
	echo(''<input type="text" name="#arguments.fieldName#_date" id="#arguments.fieldName#_date" value="##curDate##" size="9" style="width:auto; min-width:auto;" size="9" />
	 Time: <input type="text" name="#arguments.fieldName#_time" style="width:auto; min-width:auto;" id="#arguments.fieldName#_time" value="##htmleditformat(curTime)##" size="10" /> (Time is optional)'');
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
	var nv=0;
	var nvdate=0;
	var excpt=0;
	var cfcatch=0;
	var curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_date');
	var curTime=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_time');
	if(structkeyexists(arguments.typeStruct, 'datetime_value_type')){
		if(structkeyexists(arguments.row, '#variables.siteType#_x_option_group_set_created_datetime')){
			if(arguments.typeStruct.datetime_value_type EQ 1){
				curDate=arguments.row["#variables.siteType#_x_option_group_set_created_datetime"];
				curTime=arguments.row["#variables.siteType#_x_option_group_set_created_datetime"];
			}else if(arguments.typeStruct.datetime_value_type EQ 2){
				curDate=arguments.row["#variables.siteType#_x_option_group_set_updated_datetime"];
				curTime=arguments.row["#variables.siteType#_x_option_group_set_updated_datetime"];
			}
		}else{
			if(arguments.typeStruct.datetime_value_type EQ 1 or arguments.typeStruct.datetime_value_type EQ 2){
				curDate=request.zos.mysqlnow;
				curTime=request.zos.mysqlnow;
			}
		}
	}
	if(curDate EQ ""){
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
		curTime=curDate;
		if(curDate EQ ""){
			return { success: true, value: "", dateValue: "" };
		}
	}

	arguments.dataStruct["#variables.siteType#_x_option_group_disable_time"]=0;
	if(curTime EQ ""){
		arguments.dataStruct["#variables.siteType#_x_option_group_disable_time"]=1;
	}
	try{
		if(arguments.dataStruct["#variables.siteType#_x_option_group_disable_time"] EQ 1){
			nvdate=dateformat(curDate, "yyyy-mm-dd")&" 00:00:00";
			nv=dateformat(curDate, "m/d/yyyy");
		}else{
			nvdate=dateformat(curDate, "yyyy-mm-dd")&" "&timeformat(curTime, "HH:mm:ss");
			nv=dateformat(curDate, "m/d/yyyy")&" "&timeformat(curTime, "h:mm tt");
		}
		if(structkeyexists(arguments.typeStruct, 'datetime_range_search_type')){
			if(arguments.typeStruct.datetime_range_search_type EQ 1){
				// start date
				arguments.dataStruct["#variables.siteType#_x_option_group_set_start_date"]=dateformat(curDate, "yyyy-mm-dd");
			}else if(arguments.typeStruct.datetime_range_search_type EQ 2){
				// end date
				arguments.dataStruct["#variables.siteType#_x_option_group_set_end_date"]=dateformat(curDate, "yyyy-mm-dd");
			}
		}
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
		curTime=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_time');
		if(isDate(curDate)){
			if(isDate(curTime)){
				curTime=dateformat(curTime, "HH:mm:ss");
				if(curTime EQ "00:00:00"){
					return dateformat(curDate, "yyyy-mm-dd");
				}else{
					return dateformat(curDate, "yyyy-mm-dd")&" "&curTime;
				}
			}else{
				return dateformat(curDate, "yyyy-mm-dd");
			}
		}else{
			return "";
		}
	}else{
		curDate=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
		if(isDate(curDate)){
			curTime=dateformat(curDate, "HH:mm:ss");
			if(curTime EQ "00:00:00"){
				return dateformat(curDate, "yyyy-mm-dd");
			}else{
				return dateformat(curDate, "yyyy-mm-dd")&" "&curTime;
			}
		}else{
			return "";
		}
	}
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
	<cfscript>
	return 'Date/Time';
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
		datetime_range_search_type:application.zcore.functions.zso(arguments.dataStruct, 'datetime_range_search_type'),
		datetime_value_type:application.zcore.functions.zso(arguments.dataStruct, 'datetime_value_type')
	}
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, typeStruct: ts};
	</cfscript>
</cffunction>

<cffunction name="getFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		datetime_range_search_type:"0",
		datetime_value_type:"0"
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
	<input type="radio" name="feature_field_type_id" value="4" onClick="setType(4);" <cfif value EQ 4>checked="checked"</cfif>/>
	Date/Time<br />
	<div id="typeFields4" style="display:none;padding-left:30px;">
		Enable Date Range Search:  
		<cfscript> 
		arguments.typeStruct.datetime_range_search_type=application.zcore.functions.zso(arguments.typeStruct, 'datetime_range_search_type', true, 0);
		var ts = StructNew();
		ts.name = "datetime_range_search_type";
		ts.style="border:none;background:none;";
		ts.labelList = "Start Date,End Date,Disabled";
		ts.valueList = "1,2,0";
		ts.hideSelect=true;
		ts.struct=arguments.typeStruct;
		writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
		</cfscript>
		<br />
		Force Value: 
		<cfscript> 
		arguments.typeStruct.datetime_value_type=application.zcore.functions.zso(arguments.typeStruct, 'datetime_value_type', true, 0);
		var ts = StructNew();
		ts.name = "datetime_value_type";
		ts.style="border:none;background:none;";
		ts.labelList = "Created Date,Updated Date,Editable";
		ts.valueList = "1,2,0";
		ts.hideSelect=true;
		ts.struct=arguments.typeStruct;
		writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
		</cfscript>
	</div>	
	</cfsavecontent>
	<cfreturn output>
</cffunction> 

<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` datetime NOT NULL DEFAULT '0000-00-00 00:00:00'";
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>