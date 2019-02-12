<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="public" output="no">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="siteType" type="string" required="yes">
	<cfscript>
	variables.type=arguments.type;
	variables.siteType=arguments.siteType;
	if(variables.type EQ "site"){
		variables.siteStorageKey="soSchemaData";
		variables.typeStorageKey="soSchemaData";
	}else if(variables.type EQ "theme"){
		variables.siteStorageKey="themeData";
		variables.typeStorageKey="themeTypeData";
	}else if(variables.type EQ "widget"){
		variables.siteStorageKey="widgetData";
		variables.typeStorageKey="widgetTypeData";
	}

	</cfscript>
</cffunction>

<cffunction name="getTypeCFCStruct" returntype="struct" localmode="modern" access="public">
	<cfscript>
	return application.zcore[variables.typeStorageKey].optionTypeStruct;
	</cfscript>
</cffunction>
	

<cffunction name="getTypeCFC" returntype="struct" localmode="modern" access="public" output="no">
	<cfargument name="typeId" type="string" required="yes" hint="site_id, theme_id or widget_id">
	<cfscript>
	return application.zcore[variables.typeStorageKey].optionTypeStruct[arguments.typeID];
	</cfscript>
</cffunction>

<cffunction name="getSiteData" returntype="struct" localmode="modern" access="public">
	<cfargument name="key" type="string" required="yes" hint="site_id, theme_id or widget_id">
	<cfscript>
	return application.siteStruct[arguments.key].globals[variables.siteStorageKey];
	</cfscript>
</cffunction>

<cffunction name="getTypeData" returntype="struct" localmode="modern" access="public">
	<cfargument name="key" type="string" required="yes" hint="site_id, theme_id or widget_id">
	<cfscript>
	return application.zcore[variables.typeStorageKey][arguments.key];
	</cfscript>
</cffunction>

<cffunction name="getFieldTypeCFCs" returntype="struct" localmode="modern" access="public">
	<cfscript>
	ts={
		"0": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.textFieldType"),
		"1": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.textareaFieldType"),
		"2": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.htmlEditorFieldType"),
		"3": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.imageFieldType"),
		"4": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.dateTimeFieldType"),
		"5": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.dateFieldType"),
		"6": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.timeFieldType"),
		"7": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.selectMenuFieldType"),
		"8": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.checkboxFieldType"),
		"9": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.fileFieldType"),
		"10": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.emailFieldType"),
		"11": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.htmlSeparatorFieldType"),
		"12": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.hiddenFieldType"),
		"13": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.mapPickerFieldType"),
		"14": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.radioFieldType"),
		"15": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.urlFieldType"),
		"16": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.userPickerFieldType"),
		"17": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.numberFieldType"),
		"18": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.colorFieldType"),
		"19": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.stateFieldType"),
		"20": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.countryFieldType"),
		"21": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.listingSavedSearchFieldType"),
		"22": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.sliderFieldType"),
		"23": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.imageLibraryFieldType"),
		"24": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.stylesetFieldType"),
		"25": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.productFieldType"),
		"26": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.productCategoryFieldType"),
		"27": createobject("component", "zcorerootmapping.mvc.z.admin.optionTypes.officePickerFieldType")
	};

	return ts;
	</cfscript>
</cffunction>


<cffunction name="getTypeCustomDeleteArray" returntype="array" localmode="modern" access="public">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	ss=arguments.sharedStruct.optionTypeStruct;
	arrCustomDelete=[];
	for(i in ss){
		if(ss[i].hasCustomDelete()){
			arrayAppend(arrCustomDelete, i);
		}
	}
	return arrCustomDelete;
	</cfscript>
</cffunction>

<cffunction name="processSearchSchemaSQL" access="private" output="no" returntype="string" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="field" type="string" required="yes">
	<cfargument name="multipleValues" type="boolean" required="yes">
	<cfargument name="delimiter" type="string" required="yes">
	<cfargument name="concatAppendPrepend" type="string" required="yes">
	<cfscript>
	arrValue=arguments.struct.arrValue;
	length=arrayLen(arrValue);
	type=arguments.struct.type;
	match=true;
	arrSQL=[];
	field=arguments.field;
	if(arguments.concatAppendPrepend NEQ ""){
		arguments.concatAppendPrepend=application.zcore.functions.zescape(arguments.concatAppendPrepend);
		field="concat('#arguments.concatAppendPrepend#', #field#, '#arguments.concatAppendPrepend#')";
	}
	multipleError="arguments.multipleValues EQ true isn't supported by processSearchSchemaSQL.  Only non-sql in-memory searches can have multiple values.";
	if(type EQ "="){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]=arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend;
					arrayAppend(arrSQL2, field&" = '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" = '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "<>"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]=arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend;
					arrayAppend(arrSQL2, field&" <> '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " and ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" <> '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "between"){
		if(arguments.multipleValues){
			throw(multipleError);
		}
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		arrayAppend(arrSQL, field&" BETWEEN '"&application.zcore.functions.zescape(arrValue[1])&"' and '"&application.zcore.functions.zescape(arrValue[2])&"' ");
	}else if(type EQ "not between"){
		if(arguments.multipleValues){
			throw(multipleError);
		}
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		arrayAppend(arrSQL, field&" NOT BETWEEN '"&application.zcore.functions.zescape(arrValue[1])&"' and '"&application.zcore.functions.zescape(arrValue[2])&"' ");
	}else if(type EQ ">"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" > '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" > '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ ">="){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" >= '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" >= '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "<"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" = '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " < "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" < '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "<="){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrayAppend(arrSQL2, field&" <= '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" <= '"&application.zcore.functions.zescape(arrValue[g])&"' ");
			}
		}
	}else if(type EQ "like"){
		for(g=1;g LTE length;g++){ 
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]='%'&arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend&'%';
					arrayAppend(arrSQL2, field&" LIKE '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " or ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" LIKE '%"&application.zcore.functions.zescape(arrValue[g])&"%' ");
			}
		}
	}else if(type EQ "not like"){
		for(g=1;g LTE length;g++){
			if(arguments.multipleValues){
				arrValue2=listToArray(arrValue[g], arguments.delimiter, false);
				arrSQL2=[];
				for(n=1;n LTE arraylen(arrValue2);n++){
					arrValue2[n]='%'&arguments.concatAppendPrepend&arrValue2[n]&arguments.concatAppendPrepend&'%';
					arrayAppend(arrSQL2, field&" = '"&application.zcore.functions.zescape(arrValue2[n])&"' ");
				}
				arrayAppend(arrSQL, " ( "&arrayToList(arrSQL2, " and ")&" ) ");
			}else{
				arrayAppend(arrSQL, field&" NOT LIKE '%"&application.zcore.functions.zescape(arrValue[g])&"%' ");
			}
		}
	}else{
		throw("Invalid field type, ""#type#"".  Valid types are =, <>, <, <=, >, >=, between, not between, like, not like");
	}
	return " ( "&arrayToList(arrSQL, " or ")&" ) ";
	</cfscript>
</cffunction>


<cffunction name="processSearchSchema" access="private" output="no" returntype="boolean" localmode="modern">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="multipleValues" type="boolean" required="yes">
	<cfargument name="delimiter" type="string" required="yes">
	<cfscript>
	arrValue=arguments.struct.arrValue;
	length=arrayLen(arrValue);
	type=arguments.struct.type;
	field=arguments.struct.field;
	if(structkeyexists(arguments.struct, 'delimiter')){
		arguments.delimiter=arguments.struct.delimiter;
	}
	row=arguments.row;
	match=true;
	
	if(arguments.multipleValues){
		arrRowValues=listToArray(row[field], arguments.delimiter);
	}else{
		arrRowValues=[row[field]];
	}
	rowLength=arrayLen(arrRowValues);
	
	if(type EQ "="){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrValue[g] EQ arrRowValues[n]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "<>"){
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrValue[g] EQ arrRowValues[n]){
					match=false;
					break;
				}
			}
		}
	}else if(type EQ "between"){
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		match=false;
		for(n=1;n LTE rowLength;n++){
			if(arrRowValues[n] GTE arrValue[1]  and arrRowValues[n] LTE arrValue[2]){
				match=true; 
				break;
			}
		}
	}else if(type EQ "not between"){
		if(arrayLen(arrValue) NEQ 2){
			throw("You must supply exactly 2 item array for ""arrValue"" for a ""between"" search.");
		}
		match=false;
		for(n=1;n LTE rowLength;n++){
			if(arrRowValues[n] LT arrValue[1] or arrRowValues[n] GT arrValue[2]){
				match=true; 
			}
		}
	}else if(type EQ ">"){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] GT arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ ">="){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] GTE arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "<"){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] LT arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "<="){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(arrRowValues[n] LTE arrValue[g]){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "like"){
		match=false;
		for(g=1;g LTE length;g++){ 
			for(n=1;n LTE rowLength;n++){
				if(refindnocase(replace('%'&arrValue[g]&'%', "%", ".*", "all"), arrRowValues[n]) NEQ 0){
					match=true;
					break;
				}
			}
		}
	}else if(type EQ "not like"){
		match=false;
		for(g=1;g LTE length;g++){
			for(n=1;n LTE rowLength;n++){
				if(refindnocase(replace('%'&arrValue[g]&'%', "%", ".*", "all"), arrRowValues[n]) EQ 0){
					match=true;
					break;
				}
			}
		}
	}else{
		throw("Invalid field type, ""#type#"".  Valid types are =, <>, <, <=, >, >=, between, not between, like, not like");
	}
	return match;
	</cfscript>
</cffunction>

<!--- 
used to do search for a list of values
 --->
<cffunction name="getSearchListAsArray" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="true">
	<cfargument name="valueList" type="string" required="true">
	<cfargument name="compareOperator" type="string" required="true" hint="Valid values are BETWEEN, =, !=, <, <=, >, >=, LIKE, NOT LIKE">
	<cfargument name="groupOperator" type="string" required="true" hint="Valid values are AND or OR">
	<cfargument name="valueListDelimiter" type="string" required="no" default=",">
	<cfargument name="valueListSubDelimiter" type="string" required="no" default="">
	<cfscript>
	arrValue=listToArray(arguments.valueList, arguments.valueListDelimiter, false);
	count=arrayLen(arrValue);
	arrSearch=[];
	for(i=1;i LTE count;i++){
		t9={
			type=arguments.compareOperator,
			field: arguments.fieldName
		}
		if(arguments.valueListSubDelimiter NEQ ""){
			t9.arrValue=listToArray(arrValue[i], arguments.valueListSubDelimiter);
			if(arguments.compareOperator EQ "BETWEEN" and arrayLen(t9.arrValue) NEQ 2){
				t9.type="<>";
				t9.field=arguments.fieldName;
				t9.arrValue=["~~-1~~"];
			}
		}else{
			t9.arrValue=[arrValue[i]];
		}
		arrayAppend(arrSearch, t9);
		if(i NEQ count){
			arrayAppend(arrSearch, arguments.groupOperator);
		}
	}
	return arrSearch;
	</cfscript>
</cffunction>


<cffunction name="rebuildParentStructData" localmode="modern" access="private">
	<cfargument name="parentStruct" type="struct" required="yes">
	<cfargument name="arrLabel" type="array" required="yes">
	<cfargument name="arrValue" type="array" required="yes">
	<cfargument name="arrCurrent" type="array" required="yes">
	<cfargument name="level" type="numeric" required="yes">
	<cfscript>
	if(arguments.level GT 50){ 
		throw("Possible infinite recursion.  Throwing error to prevent stackoverflow.");
	}
	for(local.f=1;local.f LTE arraylen(arguments.arrCurrent);local.f++){
		if(arguments.level NEQ 0){
			local.pad=replace(ljustify(" ", arguments.level*3), " ", "_", "ALL");
		}else{
			local.pad="";
		}
		arrayappend(arguments.arrLabel, local.pad&arguments.arrCurrent[local.f].label);
		if(structkeyexists(arguments.arrCurrent[local.f], 'idChild')){
			arrayappend(arguments.arrValue, arguments.arrCurrent[local.f].idChild);
		}else{
			arrayappend(arguments.arrValue, arguments.arrCurrent[local.f].id);
		}
		//writeoutput( arguments.arrCurrent[local.f].id&" | "& arguments.arrCurrent[local.f].label);
		if(structkeyexists(arguments.parentStruct, arguments.arrCurrent[local.f].id) and arguments.arrCurrent[local.f].id NEQ 0){ 
			variables.rebuildParentStructData(arguments.parentStruct, arguments.arrLabel, arguments.arrValue, arguments.parentStruct[arguments.arrCurrent[local.f].id], arguments.level+1);
		}
	}
	</cfscript>
</cffunction>


<cffunction name="processSearchArraySQL" access="private" output="no" returntype="string" localmode="modern">
	<cfargument name="arrSearch" type="array" required="yes"> 
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfargument name="tableCount" type="numeric" required="yes"> 
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript> 
	length=arraylen(arguments.arrSearch);
	lastMatch=true;
	arrSQL=[' ( '];
	t9=getSiteData(request.zos.globals.id);
	for(i=1;i LTE length;i++){
		c=arguments.arrSearch[i]; 
		if(isArray(c)){
			sql=this.processSearchArraySQL(c, arguments.fieldStruct, arguments.tableCount, arguments.option_group_id);
			arrayAppend(arrSQL, sql); 
		}else if(isStruct(c)){
			if(structkeyexists(c, 'subSchema')){
				throw("subSchema, ""#c.subSchema#"", has caching disabled. subSchema search is not supported yet when caching is disabled (i.e. option_group_enable_cache = 0).");
			}else{
				optionId=t9.optionIdLookup[arguments.option_group_id&chr(9)&c.field];
				if(not structkeyexists(arguments.fieldStruct, optionId)){
					arguments.fieldStruct[optionId]=arguments.tableCount;
					arguments.tableCount++;
				} 
				if(application.zcore.functions.zso(t9.optionLookup[optionId].optionStruct,'selectmenu_multipleselection', true, 0) EQ 1){
					multipleValues=true;
					if(t9.optionLookup[optionId].optionStruct.selectmenu_delimiter EQ "|"){
						delimiter=',';
					}else{
						delimiter='|';
					}
				}else{
					multipleValues=false;
					delimiter='';
				}
				if(structkeyexists(c, 'concatAppendPrepend')){
					concatAppendPrepend=c.concatAppendPrepend;
				}else{
					concatAppendPrepend='';
				}
				tableName="sSchema"&arguments.fieldStruct[optionId];
				field='sVal'&optionId;
				currentCFC=getTypeCFC(t9.optionLookup[optionId].type);
				fieldName=currentCFC.getSearchFieldName('s1', tableName, t9.optionLookup[optionId].optionStruct);
				arrayAppend(arrSQL, processSearchSchemaSQL(c, fieldName, multipleValues, delimiter, concatAppendPrepend));// "`"&tableName&"`.`"&field&"`"));
				if(i NEQ length and not isSimpleValue(arguments.arrSearch[i+1])){
					arrayAppend(arrSQL, ' and ');
				}
			}
		}else if(c EQ "OR"){
			if(i EQ 1 or i EQ length){
				throw("""OR"" must be between an array or struct, not at the beginning or end or the array.");
			}
			arrayAppend(arrSQL, 'or');
		}else if(c EQ "AND"){
			if(i EQ 1 or i EQ length){
				throw("""AND"" must be between an array or struct, not at the beginning or end or the array.");
			}
			arrayAppend(arrSQL, 'and');
		}else{
			savecontent variable="output"{
				writedump(c);
			}
			throw("Invalid data type.  Dump of object:"&c);
		}
	}
	if(arrayLen(arrSQL) EQ 1){
		arrayAppend(arrSQL, "1=1");
	}
	arrayAppend(arrSQL, ' ) ');
	return arrayToList(arrSQL, " ");
	</cfscript>
</cffunction>


<cffunction name="processSearchArray" access="private" output="yes" returntype="boolean" localmode="modern">
	<cfargument name="arrSearch" type="array" required="yes">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript>
	row=arguments.row;
	length=arraylen(arguments.arrSearch);
	lastMatch=true;
	if(length EQ 0){
		return true;
	}
	debugOn=false;
	typeStruct=getTypeData(request.zos.globals.id); 
	for(i=1;i LTE length;i++){
		c=arguments.arrSearch[i]; 
		if(debugOn){ echo('<hr>');	writedump(c);	}
		if(isArray(c)){
			if(debugOn){
				echo("before processSearchArray<br>");
			}
			lastMatch=processSearchArray(c, row, arguments.option_group_id); 
			if(debugOn){
				echo("processSearchArray lastMatch:"&lastMatch&"<br>");
			}
		}else if(isStruct(c)){
			if(i NEQ 1 and not isSimpleValue(arguments.arrSearch[i])){
				if(not lastMatch){
					// the entire group must be valid or we return false.
					if(debugOn){
						echo("continue prevented struct matching from running<br>");
					}
					continue;
				}
			}
			if(structkeyexists(c, 'subSchema')){
				if(debugOn){ echo('in subgroup<br>');	}
				arrChild=optionSchemaStruct(c.subSchema, 0, request.zos.globals.id, row);
				lastMatch=false;
				if(arrayLen(arrChild)){
					//writedump(arrChild); 
					optionId=typeStruct.optionIdLookup[arrChild[1].__groupId&chr(9)&c.field];
					if(application.zcore.functions.zso(typeStruct.optionLookup[optionId].optionStruct,'selectmenu_multipleselection', true, 0) EQ 1){
						multipleValues=true;
						if(typeStruct.optionLookup[optionId].optionStruct.selectmenu_delimiter EQ "|"){
							delimiter=',';
						}else{
							delimiter='|';
						}
					}else{
						multipleValues=false;
						delimiter='';
					}
					for(n=1;n LTE arrayLen(arrChild);n++){
						c2=arrChild[n]; 
						if(debugOn){ /* writedump(c); writedump(c2); */ 	}
						lastMatch=this.processSearchSchema(c, c2, multipleValues, delimiter); 
						if(lastMatch){
							// always return true if at least one child group matches. I.e. If a product has a "color" sub-group.  User searches for "red", then the product would be valid even if it has other options like "blue".
							break;
						}
					}
					/*writedump(lastMatch);					writedump(row);					writedump(childSchemaStruct);					abort;*/
				}
				if(debugOn){
					echo("child lastMatch:"&lastMatch&"<br>");
				}
			}else{ 
				optionId=typeStruct.optionIdLookup[arguments.option_group_id&chr(9)&c.field];
				if(application.zcore.functions.zso(typeStruct.optionLookup[optionId].optionStruct,'selectmenu_multipleselection', true, 0) EQ 1){
					multipleValues=true;
					if(typeStruct.optionLookup[optionId].optionStruct.selectmenu_delimiter EQ "|"){
						delimiter=',';
					}else{
						delimiter='|';
					}
				}else{
					multipleValues=false;
					delimiter='';
				}
				
				if(debugOn){
					echo("before processSearchSchema:<br />");
				}
				lastMatch=this.processSearchSchema(c, row, multipleValues, delimiter); 
				if(debugOn){
					echo("processSearchSchema lastMatch:"&lastMatch&"<br>");
				}
			}
		}else if(c EQ "OR"){
			if(debugOn){
				echo("OR<br />");
			}
			if(i EQ 1 or i EQ length){
				throw("""OR"" must be between an array or struct, not at the beginning or end or the array.");
			}
			if(lastMatch){
				if(debugOn){
					echo("returning in OR<br />");
				}
				return true;
			}
			lastMatch=true;
		}else if(c EQ "AND"){
			if(debugOn){
				echo("AND<br />");
			}
			if(i EQ 1 or i EQ length){
				throw("""AND"" must be between an array or struct, not at the beginning or end or the array.");
			}
			if(not lastMatch){
				if(debugOn){
					echo("returning in AND<br />");
				}
				return false;
			}
		}else{
			savecontent variable="output"{
				writedump(c);
			}
			throw("Invalid data type.  Dump of object:"&c);
		}
	}
	if(debugOn){
		echo('final lastMatch:'&lastMatch&'<hr />');
		//abort;
	}
	return lastMatch;
	</cfscript>
</cffunction>

<cffunction name="getSchemaById" access="public" returntype="struct" localmode="modern">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript>
	t9=getTypeData(request.zos.globals.id);
	if(structkeyexists(t9.optionSchemaLookup, arguments.option_group_id)){
		return t9.optionSchemaLookup[arguments.option_group_id];
	}else{
		return {};
	}
	</cfscript>
</cffunction>

<cffunction name="getSchemaNameById" access="public" returntype="string" localmode="modern">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript>
	t9=getTypeData(request.zos.globals.id);
	if(structkeyexists(t9.optionSchemaLookup, arguments.option_group_id)){
		return t9.optionSchemaLookup[arguments.option_group_id]["feature_schema_name"];
	}else{
		return "";
	}
	</cfscript>
</cffunction>

<cffunction name="getSchemaNameArrayById" access="public" returntype="array" localmode="modern">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript>
	t9=getTypeData(request.zos.globals.id);
	arrSchemaName=[];
	i=0;
	groupID=arguments.option_group_id;
	while(true){
		i++;
		if(i GT 30){
			throw("Possible infinite loop.  Verify that feature_schema_parent_id is able to reach the root for #arguments.option_group_id#");
		}
		if(structkeyexists(t9.optionSchemaLookup, groupID)){
			arrayPrepend(arrSchemaName, t9.optionSchemaLookup[groupID]["feature_schema_name"]);
			groupID=t9.optionSchemaLookup[groupID]["feature_schema_parent_id"];
			if(groupID EQ 0){
				break;
			}
		}else{
			throw("groupID, ""#groupId#"", doesn't exist.  arguments.option_group_id was #arguments.option_group_id#");
		}
	}
	return arrSchemaName;
	</cfscript>
</cffunction>

<cffunction name="getFieldFieldById" access="public" returntype="struct" localmode="modern">
	<cfargument name="option_id" type="string" required="yes">
	<cfscript>
	t9=getTypeData(request.zos.globals.id);
	if(structkeyexists(t9.optionLookup, arguments.option_id)){
		return t9.optionLookup[arguments.option_id];
	}else{
		return {};
	}
	</cfscript>
</cffunction>

<cffunction name="setIdHiddenField" access="public" returntype="any" localmode="modern">
	<cfscript>
    ts3=structnew();
    ts3.name="#variables.siteType#_x_option_group_set_id";
    application.zcore.functions.zinput_hidden(ts3);
	</cfscript>
</cffunction>

<cffunction name="requireSectionEnabledSetId" access="public" returntype="any" localmode="modern">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfscript>
	form['#variables.siteType#_x_option_group_set_id']=application.zcore.functions.zso(form, '#variables.siteType#_x_option_group_set_id', true, 0);
	if(not isSectionEnabledForSetId(arguments.arrSchemaName, form['#variables.siteType#_x_option_group_set_id'])){
		application.zcore.functions.z404("form.#variables.siteType#_x_option_group_set_id, ""#form['#variables.siteType#_x_option_group_set_id']#"", doesn't exist or doesn't has enable section set to use for the option_group.");
	}
	</cfscript>
</cffunction>

<cffunction name="isSectionEnabledForSetId" access="public" returntype="boolean" localmode="modern">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfargument name="setId" type="string" required="yes">
	<cfscript>
	if(arguments.setId EQ "" or arguments.setId EQ 0){
		return true;
	}
	struct=getSchemaSetById(arguments.arrSchemaName, arguments.setId);
	if(structcount(struct) EQ 0){
		return false;
	}else{
		groupStruct=getSchemaById(struct.__groupId);
		if(groupStruct["feature_schema_enable_section"] EQ 1){
			return true;
		}else{
			return false;
		}
	}
	</cfscript>
</cffunction>

<cffunction name="getFieldFieldNameById" access="public" returntype="string" localmode="modern">
	<cfargument name="option_id" type="string" required="yes">
	<cfscript>
	t9=getTypeData(request.zos.globals.id);
	if(structkeyexists(t9.optionLookup, arguments.option_id)){
		return t9.optionLookup[arguments.option_id]["feature_field_name"];
	}else{
		return "";
	}
	</cfscript>
</cffunction>


<cffunction name="displaySectionNav" localmode="modern" access="remote" roles="member">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfscript>
	form["#variables.siteType#_x_option_group_set_id"]=application.zcore.functions.zso(form, "#variables.siteType#_x_option_group_set_id");
	struct=getSchemaSetById(arguments.arrSchemaName, form["#variables.siteType#_x_option_group_set_id"]);
	if(structcount(struct) EQ 0){
		return;
	}else{
		groupStruct=getSchemaById(struct.__groupId);
	}
	curSchemaId=groupStruct["feature_schema_id"];
	curParentId=groupStruct["feature_schema_parent_id"];
	curParentSetId=struct.__parentId;

	getSetParentLinks(curSchemaId, curParentId, curParentSetId, true);
	echo('<h2>Manage Section: #groupStruct["feature_schema_name"]# | #struct.__title#</h2>');
	</cfscript>
	
</cffunction>


<cffunction name="deleteSchemaSetIdCache" localmode="modern" access="public">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="setId" type="numeric" required="yes"> 
	<cfscript>
	deleteSchemaSetIdCacheInternal(arguments.site_id, arguments.setId, false);
	application.zcore.functions.zCacheJsonSiteAndUserSchema(arguments.site_id, application.zcore.siteGlobals[arguments.site_id]);
	</cfscript>
</cffunction>

<cffunction name="deleteSchemaSetIdCacheInternal" localmode="modern" access="private">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfargument name="setId" type="numeric" required="yes">
	<cfargument name="disableFileUpdate" type="boolean" required="yes">
	<cfscript>
	var row=0;
	var tempValue=0; 
	t9=getSiteData(arguments.site_id);
	var db=request.zos.queryObject; 
	// remove only the keys I need to and then publish  
	if(not structkeyexists(t9.optionSchemaSetId, arguments.setId&"_groupId")){
		return;
	}
	var groupId=t9.optionSchemaSetId[arguments.setId&"_groupId"];
	var appId=t9.optionSchemaSetId[arguments.setId&"_appId"];
	var parentId=t9.optionSchemaSetId[arguments.setId&"_parentId"]; 
	deleteIndex=0;
	if(structkeyexists(t9.optionSchemaSetId[parentId&"_childSchema"], groupId)){
		var arrChild=t9.optionSchemaSetId[parentId&"_childSchema"][groupId]; 
		for(var i=1;i LTE arrayLen(arrChild);i++){
			if(arguments.setId EQ arrChild[i]){
				deleteIndex=i;
				break;
			}
		}
	}
	var arrChild2=t9.optionSchemaSetArrays[appId&chr(9)&groupId&chr(9)&parentId];
	deleteIndex2=0;
	for(var i=1;i LTE arrayLen(arrChild2);i++){
		if(arguments.setId EQ arrChild2[i].__setId){
			deleteIndex2=i;
		}
	}
	// recursively delete children from shared memory cache
	var childSchema=duplicate(t9.optionSchemaSetId[arguments.setId&"_childSchema"]); 
	for(var f in childSchema){
		for(var g=1;g LTE arraylen(childSchema[f]);g++){ 
			this.deleteSchemaSetIdCacheInternal(arguments.site_id, childSchema[f][g], true);
		}
	}
	for(var n in t9.optionSchemaFieldLookup[groupId]){ 
		structdelete(t9.optionSchemaSetId, arguments.setId&"_f"&n);
	}
	if(deleteIndex GT 0){
		arrayDeleteAt(arrChild, deleteIndex);
	}
	if(deleteIndex2 GT 0){
		arrayDeleteAt(arrChild2, deleteIndex2);
	} 
	structdelete(t9.optionSchemaSet, arguments.setId);
	structdelete(t9.optionSchemaSetId, arguments.setId&"_groupId");
	structdelete(t9.optionSchemaSetId, arguments.setId&"_appId");
	structdelete(t9.optionSchemaSetId, arguments.setId&"_parentId");
	structdelete(t9.optionSchemaSetId, arguments.setId&"_childSchema"); 

	</cfscript>
</cffunction>

<cffunction name="searchReindexSet" localmode="modern" access="public">
	<cfargument name="setId" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var row=0;
	indexSchemaRow(arguments.setId, arguments.site_id, arguments.arrSchemaName);
	</cfscript>
</cffunction>


<cffunction name="getStatusName" returntype="string" output="no" localmode="modern">
	<cfargument name="statusId" type="string" required="yes">
	<cfscript>
	if(arguments.statusId EQ 1){
		return 'Approved';
	}else if(arguments.statusId EQ 0){
		return 'Pending';
	}else if(arguments.statusId EQ 2){
		return 'Deactivated By User';
	}else if(arguments.statusId EQ 3){
		return 'Rejected';
	}else{
		throw("Invalid statusId, ""#arguments.statusId#""");
	}
	</cfscript>
</cffunction>


<cffunction name="getChildValues" localmode="modern" returntype="array" access="private">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="currentStruct" type="struct" required="yes">
	<cfargument name="arrChild" type="array" required="yes">
	<cfargument name="level" type="numeric" required="yes">
	<cfscript>
	if(arguments.level GT 25){
		savecontent variable="out"{
			writedump(arguments.arrChild);
			writedump(arguments.currentStruct);
		}
		throw("Possible infinite recursion detected in siteFieldCom.getChildValues()."&out);
	}
	arrayAppend(arguments.arrChild, arguments.currentStruct.id);
	if(structkeyexists(arguments.struct, arguments.currentStruct.id)){
		for(i in arguments.struct[arguments.currentStruct.id]){
			arguments.arrChild=this.getChildValues(arguments.struct, arguments.struct[arguments.currentStruct.id][i], arguments.arrChild, arguments.level+1);
		}
	}
	return arguments.arrChild;
	</cfscript>
</cffunction>



<cffunction name="indexSchemaRow" localmode="modern" access="public">
	<cfargument name="setId" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var i=0;
	dataStruct=getSchemaSetById(arguments.arrSchemaName, arguments.setId, arguments.site_id); 
	var t9=getTypeData(arguments.site_id);
	if(not structkeyexists(dataStruct, '__approved') or dataStruct.__approved NEQ 1){
		deleteSchemaSetIndex(arguments.setId, arguments.site_id);

		return;
	}
	groupStruct=t9.optionSchemaLookup[dataStruct.__groupId]; 
	if(groupStruct["feature_schema_search_index_cfc_path"] EQ ""){
		customSearchIndexEnabled=false;
	}else{ 
		customSearchIndexEnabled=true;
		if(left(groupStruct["feature_schema_search_index_cfc_path"], 5) EQ "root."){  
			local.cfcpath=replace(groupStruct["feature_schema_search_index_cfc_path"], 'root.',  application.zcore.functions.zGetRootCFCPath(application.zcore.functions.zvar('shortDomain', arguments.site_id)));
		}else{
			local.cfcpath=groupStruct["feature_schema_search_index_cfc_path"];
		}
	}
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	ds=searchCom.getSearchIndexStruct();
	ds.app_id=14; 
	ds.search_table_id=local.dataStruct.__setId;
	ds.site_id=arguments.site_id;
	ds.search_content_datetime=local.dataStruct.__dateModified;
	ds.search_url=dataStruct.__url;
	ds.search_title=dataStruct.__title;
	ds.search_summary=dataStruct.__summary;


	if(structkeyexists(dataStruct, '__image_library_id') and dataStruct.__image_library_id NEQ 0){
		ts={};
		ts.output=false;
		ts.size="150x120";
		ts.layoutType="";
		ts.image_library_id=dataStruct.__image_library_id;
		ts.forceSize=true;
		ts.crop=0;
		ts.offset=0;
		ts.limit=1; // zero will return all images
		var arrImage=request.zos.imageLibraryCom.displayImages(ts);
		if(arraylen(arrImage)){
			ds.search_image=arrImage[1].link;
		}
	}

	if(customSearchIndexEnabled){
		local.tempCom=application.zcore.functions.zcreateobject("component", local.cfcpath); 
		local.tempCom[groupStruct["feature_schema_search_index_cfc_method"]](dataStruct, ds);
	}else{
		arrFullText=[]; 
		if(structkeyexists(t9.optionSchemaFieldLookup, dataStruct.__groupId)){
			for(i in t9.optionSchemaFieldLookup[dataStruct.__groupId]){
				c=t9.optionLookup[i];
				if(c["feature_field_enable_search_index"] EQ 1){
					arrayAppend(arrFullText, dataStruct[c.name]);
				}
			}
		}
		ds.search_fulltext=arrayToList(arrFullText, " ");
	}
	//writedump(ds);abort;
	searchCom.saveSearchIndex(ds);
	</cfscript>
</cffunction>


<!--- application.zcore.siteFieldCom.getCurrentFieldAppId(); --->
<cffunction name="getCurrentFieldAppId" localmode="modern" output="no" returntype="any">
	<cfscript>
	if(structkeyexists(request.zos, "#variables.type#currentFieldAppId")){
		return request.zos["#variables.type#currentFieldAppId"];
	}else{
		return 0;
	}
	</cfscript>
</cffunction>

<cffunction name="setCurrentFieldAppId" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="string" required="yes">
	<cfscript>
	request.zos["#variables.type#currentFieldAppId"]=arguments.id;
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zGetSiteSchemaIdWithNameArray(["SchemaName"]); --->
<cffunction name="getSchemaIdWithNameArray" localmode="modern" output="no" returntype="numeric" hint="returns the group id for the last group in the array.">
	<cfargument name="arrSchemaName" type="array" required="no" default="An array of feature_schema_name">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	t9=getTypeData(arguments.site_id);
	count=arrayLen(arguments.arrSchemaName);
	if(count EQ 0){
		throw("You must specify one or more group names in arguments.arrSchemaName");
	}
	curSchemaId=0;
	optionSchemaId=0;
	for(i=1;i LTE count;i++){
		optionSchemaId=t9.optionSchemaIdLookup[curSchemaId&chr(9)&arguments.arrSchemaName[i]];
		curSchemaId=optionSchemaId;
	}
	return optionSchemaId;
	</cfscript>
</cffunction>

<cffunction name="optionSchemaById" localmode="modern" output="yes" returntype="struct">
	<cfargument name="option_group_id" type="string" required="no" default="">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	t9=getTypeData(arguments.site_id);
	if(structkeyexists(t9, "optionSchemaLookup") and structkeyexists(t9.optionSchemaLookup, arguments.option_group_id)){
		return t9.optionSchemaLookup[arguments.option_group_id];
	}
	return {};
	</cfscript>
</cffunction>

     
<cffunction name="getSchemaSetById" localmode="modern" output="yes" returntype="struct">
	<cfargument name="arrSchemaName" type="array" required="yes">
	<cfargument name="option_group_set_id" type="string" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfargument name="showUnapproved" type="boolean" required="no" default="#false#"> 
	<cfscript> 
	// if(structkeyexists(application.siteStruct[arguments.site_id].globals.soSchemaData.optionSchemaSet, arguments.option_group_set_id)){
	// 	groupStruct=application.siteStruct[arguments.site_id].globals.soSchemaData.optionSchemaSet[arguments.option_group_set_id];
	// }
	typeStruct=getTypeData(arguments.site_id);
	t9=getSiteData(arguments.site_id);

	if(arraylen(arguments.arrSchemaName)){
		var groupId=getSchemaIdWithNameArray(arguments.arrSchemaName, arguments.site_id);
		var groupStruct=typeStruct.optionSchemaLookup[groupId];  
		if(request.zos.enableSiteSchemaCache and not arguments.showUnapproved and groupStruct["feature_schema_enable_cache"] EQ 1 and structkeyexists(t9.optionSchemaSet, arguments.option_group_set_id)){
			groupStruct=t9.optionSchemaSet[arguments.option_group_set_id];
			if(groupStruct.__groupID NEQ groupID){
				application.zcore.functions.z404("#arrayToList(arguments.arrSchemaName, ", ")# is not the right group for feature_schema_set_id: #arguments.option_group_set_id#");
			} 
			// appendSchemaDefaults(groupStruct, groupStruct.__groupId);
			return groupStruct;
		}else{ 
			if(arguments.option_group_set_id EQ ""){
				// don't do a query when the id is missing 
				return {};
			}   
			return optionSchemaSetFromDatabaseBySetId(groupId, arguments.option_group_set_id, arguments.site_id, arguments.showUnapproved);
		}
	}else{
		if(structkeyexists(t9.optionSchemaSet, arguments.option_group_set_id)){
			return t9.optionSchemaSet[arguments.option_group_set_id];
			// appendSchemaDefaults(groupStruct, groupStruct.__groupId);
			// return groupStruct;
		}
	} 
	return {};
	</cfscript>
</cffunction>

<cffunction name="optionSchemaIdByName" localmode="modern" output="no" returntype="numeric">
	<cfargument name="groupName" type="string" required="yes">
	<cfargument name="option_group_parent_id" type="numeric" required="no" default="#0#">
	<cfargument name="site_id" type="numeric" required="no" default="#request.zos.globals.id#">
	<cfscript>
	t9=getTypeData(arguments.site_id);
	if(structkeyexists(t9, "optionSchemaIdLookup") and structkeyexists(t9.optionSchemaIdLookup, arguments.option_group_parent_id&chr(9)&arguments.groupName)){
		return t9.optionSchemaIdLookup[arguments.option_group_parent_id&chr(9)&arguments.groupName];
	}else{
		throw("arguments.groupName, ""#arguments.groupName#"", doesn't exist");
	}
	</cfscript>
</cffunction>

<cffunction name="optionSchemaStruct" localmode="modern" output="yes" returntype="array">
	<cfargument name="groupName" type="string" required="yes">
	<cfargument name="option_app_id" type="string" required="no" default="0">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfargument name="parentStruct" type="struct" required="no" default="#{__groupId=0,__setId=0}#">
	<cfargument name="fieldList" type="string" required="no" default="">
	<cfscript>  
	t9=application.siteStruct[arguments.site_id].globals[variables.siteStorageKey];
	typeStruct=t9;
	// t9=getSiteData(arguments.site_id);
	// typeStruct=getTypeData(arguments.site_id); 
	if(structkeyexists(typeStruct, 'optionSchemaIdLookup') and structkeyexists(typeStruct.optionSchemaIdLookup, arguments.parentStruct.__groupId&chr(9)&arguments.groupName)){
		optionSchemaId=typeStruct.optionSchemaIdLookup[arguments.parentStruct.__groupId&chr(9)&arguments.groupName];
		groupStruct=typeStruct.optionSchemaLookup[optionSchemaId];
		if(request.zos.enableSiteSchemaCache and groupStruct["feature_schema_enable_cache"] EQ 1){
			if(structkeyexists(t9.optionSchemaSetArrays, arguments.option_app_id&chr(9)&optionSchemaId&chr(9)&arguments.parentStruct.__setId)){
				return t9.optionSchemaSetArrays[arguments.option_app_id&chr(9)&optionSchemaId&chr(9)&arguments.parentStruct.__setId]; 
			}
		}else{
			return optionSchemaSetFromDatabaseBySchemaId(optionSchemaId, arguments.option_app_id, arguments.site_id, arguments.parentStruct, arguments.fieldList);
		}
	} 
	return arraynew(1);
	</cfscript>
</cffunction> 


<!---  appendSchemaDefaults(dataStruct, option_group_id); --->
<cffunction name="appendSchemaDefaults" localmode="modern" output="false" returntype="any">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="option_group_id" type="string" required="yes">
	<cfscript> 
	typeStruct=getTypeData(request.zos.globals.id);
	if(structkeyexists(typeStruct, 'optionSchemaDefaults') and structkeyexists(typeStruct.optionSchemaDefaults, arguments.option_group_id)){
		structappend(arguments.dataStruct, typeStruct.optionSchemaDefaults[arguments.option_group_id], false);
	}
	return arguments.dataStruct;
	</cfscript>
</cffunction>


<!--- 
ts=structnew();
ts.feature_id;
ts.output=true;
ts.query=qImages;
ts.row=currentrow;
ts.size="250x160";
ts.crop=0;
ts.count = 1; // how many images to get
application.zcore.siteFieldCom.displayImageFromSQL(ts);
 --->
<cffunction name="displayImageFromSQL" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qImages=0;
	var arrImageFile=0;
	var g2=0;
	var arrOutput=arraynew(1);
	var ts=structnew();
	var rs=structnew();
	var count=0;
	var arrId=arraynew(1);
	var arrCaption=arraynew(1);
	ts.output=true;
	ts.row=1;
	ts.crop=0;
	ts.size="#request.zos.globals.maximagewidth#x2000";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.query.imageIdList[arguments.ss.row] EQ ""){
		arguments.ss.count=0;
	}else{
		arguments.ss.count=min(arguments.ss.count,arraylen(listtoarray(arguments.ss.query.imageIdList[arguments.ss.row],chr(9),true)));
	}
	if(arguments.ss.count EQ 0){
		return arrOutput;
	}
	if(arguments.ss["#variables.siteType#_option_app_id"] EQ 0){
		if(arguments.ss.output){
			return;
		}else{
			return arrOutput;
		}
	}
	application.zcore.siteFieldCom.registerSize(arguments.ss["#variables.siteType#_option_app_id"], arguments.ss.size, arguments.ss.crop);
	</cfscript>
	<cfif arguments.ss.output>
		<cfloop query="arguments.ss.query" startrow="#arguments.ss.row#" endrow="#arguments.ss.row#">
			<cfscript>arrCaption=listtoarray(arguments.ss.query.imageCaptionList,chr(9),true);
			arrId=listtoarray(arguments.ss.query.imageIdList,chr(9),true);
			arrImageFile=listtoarray(arguments.ss.query.imageFileList,chr(9),true);
			arrImageUpdatedDate=listtoarray(arguments.ss.query.imageUpdatedDateList, chr(9), true);
			</cfscript>
			<cfloop from="1" to="#arguments.ss.count#" index="g2">
				<img src="#application.zcore.siteFieldCom.getImageLink(arguments.ss["#variables.siteType#_option_app_id"], arrId[g2], arguments.ss.size, arguments.ss.crop, true, arrCaption[g2], arrImageFile[g2], arrImageUpdatedDate[g2])#" <cfif arrCaption[g2] NEQ "">alt="#htmleditformat(arrCaption[g2])#"</cfif> style="border:none;" />
				<cfif arrCaption[g2] NEQ ""><br /><div style="padding-top:5px;">#arrCaption[g2]#</div></cfif><br /><br />
			</cfloop>
		</cfloop>
	<cfelse>
		<cfloop query="arguments.ss.query" startrow="#arguments.ss.row#" endrow="#arguments.ss.row#">
			<cfscript>
			arrCaption=listtoarray(arguments.ss.query.imageCaptionList,chr(9),true);
			arrId=listtoarray(arguments.ss.query.imageIdList,chr(9),true);
			arrImageFile=listtoarray(arguments.ss.query.imageFileList,chr(9),true);
			arrImageUpdatedDate=listtoarray(arguments.ss.query.imageUpdatedDateList, chr(9), true);
			if(arraylen(arrCaption) EQ 0){ arrayappend(arrCaption,""); }
			if(arraylen(arrId) EQ 0){ arrayappend(arrId,""); }
			if(arraylen(arrImageFile) EQ 0){ arrayappend(arrImageFile,""); }
			if(arraylen(arrImageUpdatedDate) EQ 0){ arrayappend(arrImageUpdatedDate,""); }
			</cfscript>
			<cfloop from="1" to="#arguments.ss.count#" index="g2">
				<cfscript>
				ts=structnew();
				ts.link=application.zcore.siteFieldCom.getImageLink(arguments.ss["#variables.siteType#_option_app_id"], arrId[g2], arguments.ss.size, arguments.ss.crop, true, arrCaption[g2], arrImageFile[g2], arrImageUpdatedDate[g2]);
				ts.caption=arrCaption[g2];
				ts.id=arrId[g2];
				arrayappend(arrOutput,ts);
				</cfscript>
			</cfloop>
		</cfloop>
		<cfscript>return arrOutput;</cfscript>
	</cfif>
</cffunction>

<!---  
ts=structnew();
ts.name="option_app_id";
ts.app_id=0;
ts.value=option_app_id;
application.zcore.siteFieldCom.getFieldForm(ts); --->
<cffunction name="getFieldForm" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	qLibrary=getFieldAppById(arguments.ss.value, arguments.ss.app_id);
	option_app_id=qLibrary["#variables.siteType#_option_app_id"];
	</cfscript>
<script type="text/javascript">
	/* <![CDATA[ */
	function showoptionWindow(){
		var windowSize=zGetClientWindowSize();
		var modalContent1='<iframe src="/z/admin/#variables.type#-options/index?#variables.siteType#_option_app_id=#option_app_id#&amp;ztv='+Math.random()+'"  style="margin:0px;border:none; overflow:auto;" seamless="seamless" width="100%" height="95%"><\/iframe>';		
		zShowModal(modalContent1,{'width':windowSize.width-100,'height':windowSize.height-100});
	}
	/* ]]> */
	</script>
<input type="hidden" name="#arguments.ss.name#" value="#option_app_id#" />
<h2><a href="##" onclick="showoptionWindow(); return false;">Edit Custom Fields</a></h2>

</cffunction>

<cffunction name="optionappform" localmode="modern" access="remote" roles="member" returntype="any" output="yes">
	<cfscript>
	application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);
	c=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.admin.controller.#variables.type#-options");
	c.index();
	</cfscript>
</cffunction>
  
</cfoutput>
</cfcomponent>