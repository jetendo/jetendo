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
	return "28.512,-81.299178";
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
	return "";
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
	<cfargument name="optionStruct" type="struct" required="yes">
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
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes"> 
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="searchStruct" type="struct" required="yes">
	<cfscript>
	return '';
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
		type="LIKE",
		field: arguments.row["#variables.type#_option_name"],
		arrValue:[]
	};
	if(arguments.value NEQ ""){
		arrayAppend(ts.arrValue, '%'&arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]]&'%');
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
		return arguments.databaseField&' like '&db.trustedSQL("'%"&application.zcore.functions.zescape(arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]])&"%'");
	}
	return '';
	</cfscript>
</cffunction>

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">  
	<cfscript>
	ts={
		name:arguments.prefixString&arguments.row["#variables.type#_option_id"],
		value:arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]],
		fields:{
			address:"newvalue#arguments.optionStruct.addressfield#",
			city:"newvalue#arguments.optionStruct.cityfield#",
			state:"newvalue#arguments.optionStruct.statefield#",
			zip:"newvalue#arguments.optionStruct.zipfield#"
		}
	};
	if(structkeyexists(arguments.optionStruct, 'countryfield')){
		ts.fields.country="newvalue#arguments.optionStruct.countryfield#";
	}
	return { label: true, hidden: false, value: application.zcore.functions.zMapLocationPicker(ts)};  
	</cfscript>
</cffunction>

<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return '
	<cfscript>
	ts={
		name:"#arguments.fieldName#",
		fields:{
			// you must update these to be form field ids for auto-complete to work
			address:"",
			city:"",
			state:"",
			zip:"",
			country:""
		}
	};
	return { label: true, hidden: false, value: application.zcore.functions.zMapLocationPicker(ts)};  
	</cfscript> 
	';
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
	return {};
	</cfscript>
</cffunction>

<cffunction name="onBeforeUpdate" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes"> 
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript>	
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]);
	return { success: true, value: nv, dateValue: "" };
	</cfscript>
</cffunction>

<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	return application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]);
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
	<cfscript>
	return 'Map Location Picker';
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
		addressfield:application.zcore.functions.zso(arguments.dataStruct, 'addressfield'),
		cityfield:application.zcore.functions.zso(arguments.dataStruct, 'cityfield'),
		statefield:application.zcore.functions.zso(arguments.dataStruct, 'statefield'),
		zipfield:application.zcore.functions.zso(arguments.dataStruct, 'zipfield'),
		countryfield:application.zcore.functions.zso(arguments.dataStruct, 'countryfield')
	};
	arguments.dataStruct["#variables.type#_option_type_json"]=serializeJson(ts);
	return { success:true, optionStruct: ts};
	</cfscript>
</cffunction>
		

<cffunction name="getOptionFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		addressfield:"",
		cityfield:"",
		statefield:"",
		zipfield:"",
		countryfield:""
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
	db.sql="select * from #db.table("#variables.type#_option", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	#variables.type#_option_deleted = #db.param(0)# and
	#variables.type#_option_group_id = #db.param(arguments.dataStruct["#variables.type#_option_group_id"])# 	
	ORDER BY #variables.type#_option_name ASC";
	qGroup=db.execute("qGroup", "", 10000, "query", false);
	</cfscript>
	<cfsavecontent variable="output">
		<script type="text/javascript">
		function validateOptionType13(postObj, arrError){ 
			if(postObj.addressfield == '' || postObj.cityfield=='' || postObj.statefield=='' || postObj.zipfield==''){
				arrError.push('Address, City, State and Zip are required fields.');
			}
		}
		</script>
	<input type="radio" name="#variables.type#_option_type_id" value="13" onClick="setType(13);" <cfif value EQ 13>checked="checked"</cfif>/>
	#this.getTypeName()#<br />
	<div id="typeOptions13" style="display:none;padding-left:30px;"> 
		<p>Map all the fields to enable auto-populating the map address lookup field.</p>
		<table class="table-list">
		<tr><td>
		Address: </td><td>
		<cfscript>
		selectStruct = StructNew();
		selectStruct.name = "addressfield";
		selectStruct.query = qGroup;
		selectStruct.queryLabelField = "#variables.type#_option_name";
		selectStruct.queryValueField = "#variables.type#_option_id";
		selectStruct.selectedValues=application.zcore.functions.zso(arguments.optionStruct, 'addressfield');
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript> </td></tr>
		<tr><td>
		City: </td><td>
		<cfscript>
		selectStruct = StructNew();
		selectStruct.name = "cityfield";
		selectStruct.query = qGroup;
		selectStruct.queryLabelField = "#variables.type#_option_name";
		selectStruct.queryValueField = "#variables.type#_option_id";
		selectStruct.selectedValues=application.zcore.functions.zso(arguments.optionStruct, 'cityfield');
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript> </td></tr>
		<tr><td>
		State: </td><td>
		<cfscript>
		selectStruct = StructNew();
		selectStruct.name = "statefield";
		selectStruct.query = qGroup;
		selectStruct.queryLabelField = "#variables.type#_option_name";
		selectStruct.queryValueField = "#variables.type#_option_id";
		selectStruct.selectedValues=application.zcore.functions.zso(arguments.optionStruct, 'statefield');
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript> </td></tr>
		<tr><td>
		Zip: </td><td>
		<cfscript>
		selectStruct = StructNew();
		selectStruct.name = "zipfield";
		selectStruct.query = qGroup;
		selectStruct.queryLabelField = "#variables.type#_option_name";
		selectStruct.queryValueField = "#variables.type#_option_id";
		selectStruct.selectedValues=application.zcore.functions.zso(arguments.optionStruct, 'zipfield');
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript></td>
		</tr>
		<tr><td>
		Country: </td><td>
		<cfscript>
		selectStruct = StructNew();
		selectStruct.name = "countryfield";
		selectStruct.query = qGroup;
		selectStruct.queryLabelField = "#variables.type#_option_name";
		selectStruct.queryValueField = "#variables.type#_option_id";
		selectStruct.selectedValues=application.zcore.functions.zso(arguments.optionStruct, 'countryfield');
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript> </td></tr>
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