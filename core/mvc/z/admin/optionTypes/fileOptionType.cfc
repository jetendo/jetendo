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
	return "/stylesheets/style.css";
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

<cffunction name="isCopyable" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return false;
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

<cffunction name="validateFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	/*
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]);
	if(nv NEQ "" and doValidation...){
		return { success:false, message: arguments.row["#variables.type#_option_display_name"]&" must ..." };
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
	arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]]=""; 
	</cfscript>
</cffunction>

<cffunction name="hasCustomDelete" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
	</cfscript>
</cffunction>

<cffunction name="onDelete" localmode="modern" access="public" output="no">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	uploadPath=getUploadPath(arguments.optionStruct);
	if(structkeyexists(arguments.row, '#variables.siteType#_x_option_group_value')){
		if(fileexists(application.zcore.functions.zvar('privatehomedir',arguments.row.site_id)&uploadPath&'/site-options/'&arguments.row["#variables.siteType#_x_option_group_value"])){
			application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',arguments.row.site_id)&uploadPath&'/site-options/'&arguments.row["#variables.siteType#_x_option_group_value"]);
		}
	}else{
		if(fileexists(application.zcore.functions.zvar('privatehomedir',arguments.row.site_id)&uploadPath&'/site-options/'&arguments.row["#variables.siteType#_x_option_value"])){
			application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',arguments.row.site_id)&uploadPath&'/site-options/'&arguments.row["#variables.siteType#_x_option_value"]);
		}
	}
	</cfscript>
</cffunction> 

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">  
	<cfsavecontent variable="local.output">
		<cfscript>
		var allowDelete=true;
		if(arguments.row["#variables.type#_option_required"] EQ 1){
			allowDelete=false;
		}
		var ts3=StructNew();
		ts3.name=arguments.prefixString&arguments.row["#variables.type#_option_id"];
		ts3.allowDelete=allowDelete;
		if(arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]] NEQ ""){
			uploadPath=getUploadPath(arguments.optionStruct);
			if(uploadPath EQ "zuploadsecure"){
				ts3.downloadPath="/zuploadsecure/site-options/";
				/*if(application.zcore.user.checkGroupAccess("administrator")){
					echo('<p><a href="#request.zos.currentHostName#/z/misc/download/index?fp='&urlencodedformat("/"&uploadPath&"/site-options/"&arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]])&'" target="_blank">Download File</a></p>');
				}else{ 
					echo('<p>'&arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]]&' | You must be an administrator to download the file.</p>');
				}*/
			}else{
				ts3.downloadPath="/zupload/site-options/";
				/*writeoutput('<p><a href="/'&uploadPath&'/site-options/#arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]]#" 
				target="_blank" 
				title="#htmleditformat(arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]])#">Download File</a></p>');*/
			}
		}else{
			if(arguments.row.site_option_required EQ 1){	
				ts3.required=true;
			}
		}
		application.zcore.functions.zInput_file(ts3);
		</cfscript>
	</cfsavecontent>
	<cfscript>
	return { label: true, hidden: false, value:local.output};  
	</cfscript> 
</cffunction>

<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfsavecontent variable="out">
		<cfscript> 
		if(arguments.row["#variables.type#_option_required"] EQ 1){
			allowDelete=false;
		}else{
			allowDelete=true;
		}
		echo('
		<cfscript>
		var ts3={};
		ts3.name="#arguments.fieldName#";
		ts3.allowDelete=#allowDelete#;
		ts3.downloadPath="{uploadDisplayPath}"; 
		application.zcore.functions.zInput_file(ts3);
		</cfscript>
		');
		</cfscript>
	</cfsavecontent>
	<cfscript>
	return out;
	</cfscript> 
</cffunction>

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	if(arguments.value NEQ ""){
		uploadPath=getUploadPath(arguments.optionStruct);
		appendValue="";
		if(application.zcore.functions.zso(arguments.optionStruct, 'file_attachtoemail', true, 0) EQ 1 and structkeyexists(request.zos, 'arrForceEmailAttachment')){
			arrayAppend(request.zos.arrForceEmailAttachment, request.zos.globals.privateHomeDir&uploadPath&"/site-options/"&arguments.value); 
			appendValue=" | Also attached to lead email"; 
		} 

		if(uploadPath EQ "zuploadsecure"){
			return '<a href="#request.zos.globals.domain#/z/misc/download/index?fp='&urlencodedformat("/"&uploadPath&"/site-options/"&arguments.value)&'" target="_blank">Download File</a>'&appendValue;
		}else{
			return '<a href="#request.zos.globals.domain#/'&uploadPath&'/site-options/#arguments.value#" target="_blank">Download File</a>'&appendValue;
		}
	}else{
		return ('N/A');
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

<cffunction name="getUploadPath" localmode="modern" access="private">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	uploadPath="zupload";
	if(application.zcore.functions.zso(arguments.optionStruct, 'file_securepath') EQ 'Yes'){
		uploadPath='zuploadsecure';
	}
	return uploadPath;
	</cfscript>
</cffunction>

<cffunction name="onBeforeUpdate" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes"> 
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript>	
	var nv=0;
	uploadPath=getUploadPath(arguments.optionStruct);
	arguments.dataStruct["#variables.siteType#_x_option_group_id"]=arguments.row["#variables.siteType#_x_option_group_id"];
	nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]);
	filename="";
	if(structkeyexists(arguments.row, '#variables.siteType#_x_option_group_id')){
		form["#variables.siteType#_x_option_group_id"]=arguments.row["#variables.siteType#_x_option_group_id"];
		fileName=application.zcore.functions.zUploadFileToDb(arguments.prefixString&arguments.row["#variables.type#_option_id"], application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&uploadPath&'/site-options/', '#variables.siteType#_x_option_group', '#variables.siteType#_x_option_group_id', arguments.prefixString&arguments.row["#variables.type#_option_id"]&'_delete', request.zos.zcoredatasource, '#variables.siteType#_x_option_group_value');	
	}else{
		form["#variables.siteType#_x_option_id"]=arguments.row["#variables.siteType#_x_option_id"];
		fileName=application.zcore.functions.zUploadFileToDb(arguments.prefixString&arguments.row["#variables.type#_option_id"], application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&uploadPath&'/site-options/', '#variables.siteType#_x_option', '#variables.siteType#_x_option_id', arguments.prefixString&arguments.row["#variables.type#_option_id"]&'_delete', request.zos.zcoredatasource, '#variables.siteType#_x_option_value');	
	}
	if(not structkeyexists(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]&'_delete') and (isNull(fileName) or fileName EQ "")){
		if(structkeyexists(arguments.row, '#variables.siteType#_x_option_group_id')){
			arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]]=arguments.row["#variables.siteType#_x_option_group_value"];
			nv=arguments.row["#variables.siteType#_x_option_group_value"];
		}else{
			arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]]=arguments.row["#variables.siteType#_x_option_value"];
			nv=arguments.row["#variables.siteType#_x_option_value"];
		}
	}else{
		arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]]=fileName;
		nv=fileName;
	}
	return { success: true, value: nv, dateValue: "" };
	</cfscript>
</cffunction>

<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfscript>
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["#variables.type#_option_id"]);
	if(nv EQ ""){
		if(structkeyexists(arguments.row,'#variables.siteType#_x_option_group_value')){
			return arguments.row["#variables.siteType#_x_option_group_value"];
		}else{
			return arguments.row["#variables.siteType#_x_option_value"];
		}
	}
	return nv;
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
	<cfscript>
	return 'File';
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
		file_securepath:form.file_securepath,
		file_attachtoemail:form.file_attachtoemail
	};
	arguments.dataStruct["#variables.type#_option_type_json"]=serializeJson(ts);
	return { success:true, optionStruct: ts};
	</cfscript>
</cffunction>
		
<cffunction name="getOptionFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		file_securepath:"No",
		file_attachtoemail:"0"
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
	<input type="radio" name="#variables.type#_option_type_id" value="9" onClick="setType(9);" <cfif value EQ 9>checked="checked"</cfif>/>
	File<br />
	<div id="typeOptions9" style="display:none;padding-left:30px;">
		<table style="border-spacing:0px;">
		<tr><td>Secure Path: </td><td>
		<cfscript>
		arguments.optionStruct.file_securepath=application.zcore.functions.zso(arguments.optionStruct, 'file_securepath', false, "No");
		arguments.optionStruct.file_attachtoemail=application.zcore.functions.zso(arguments.optionStruct, 'file_attachtoemail', false, "0");
		form.file_attachtoemail=arguments.optionStruct.file_attachtoemail;
		if(arguments.optionStruct.file_securepath EQ ""){
			arguments.optionStruct.file_securepath="No";
		}
		var ts = StructNew();
		ts.name = "file_securepath";
		ts.style="border:none;background:none;";
		ts.labelList = "Yes,No";
		ts.valueList = "Yes,No";
		ts.hideSelect=true;
		ts.struct=arguments.optionStruct;
		writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
		</cfscript>
		</td></tr>
		<tr><td>Attach To Lead Email: </td><td>
			#application.zcore.functions.zInput_Boolean("file_attachtoemail", form.file_attachtoemail)#
		</td></tr>
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