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
	width=application.zcore.functions.zso(arguments.typeStruct.typeStruct, 'imagewidth',false,'1000');
	height=application.zcore.functions.zso(arguments.typeStruct.typeStruct, 'imageHeight',false,'1000');
	if(structkeyexists(request.zos, 'forceAbsoluteImagePlaceholderURL')){
		return request.zos.mlsImagesDomain&application.zcore.functions.zGetImagePlaceholderURL(width, height);
	}else{
		return application.zcore.functions.zGetImagePlaceholderURL(width, height);
	}
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

<cffunction name="searchFilter" localmode="modern" access="public">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldValue" type="string" required="yes"> 
	<cfargument name="searchValue" type="string" required="yes">
	<cfscript>
	if(arguments.searchValue NEQ "" and arguments.fieldValue DOES NOT CONTAIN arguments.searchValue){
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
	arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]]=""; 
	</cfscript>
</cffunction>

<cffunction name="hasCustomDelete" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
	</cfscript>
</cffunction>

<cffunction name="onDelete" localmode="modern" access="public" output="no">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfscript>
	if(arguments.value NEQ ""){
		arrValue=listToArray(arguments.value, chr(9));
		// resized image
		if(arrValue[1] NEQ "" and fileexists(application.zcore.functions.zvar('privatehomedir',arguments.site_id)&'zupload/feature-options/'&arrValue[1])){
			application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',arguments.site_id)&'zupload/feature-options/'&arrValue[1]);
		}
		// original image
		if(arrayLen(arrValue) GTE 2 and arrValue[2] NEQ "" and fileexists(application.zcore.functions.zvar('privatehomedir',arguments.site_id)&'zupload/feature-options/'&arrValue[2])){
			application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',arguments.site_id)&'zupload/feature-options/'&arrValue[2]);	
		}
	}
	</cfscript>
</cffunction>


<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">  
	<cfscript>
	var allowDelete=true;
	if(arguments.row["feature_field_required"] EQ 1){
		allowDelete=false;
	}
	arrValue=listToArray(form[arguments.prefixString&arguments.row["feature_field_id"]], chr(9), true);
	form[arguments.prefixString&arguments.row["feature_field_id"]]=arrValue[1];
	return { label: true, hidden: false, value:application.zcore.functions.zInputImage(arguments.prefixString&arguments.row["feature_field_id"], application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/feature-options/', request.zos.currentHostName&'/zupload/feature-options/',250, allowDelete)&'<br /><br />
	Note: The image will be resized to fit inside these pixel dimensions: '&
	application.zcore.functions.zso(arguments.typeStruct, 'imagewidth',false,'1000')&' x '&
	application.zcore.functions.zso(arguments.typeStruct, 'imageheight',false,'1000')&'<br />'};  
	</cfscript>
</cffunction>

<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	var allowDelete=true;
	if(arguments.row["feature_field_required"] EQ 1){
		allowDelete=false;
	}
	return '
	<cfscript>
	echo(application.zcore.functions.zInputImage("#arguments.fieldName#", left(request.zos.globals.privatehomedir, len(request.zos.globals.privatehomedir)-1)&"{uploadDisplayPath}", request.zos.currentHostName&"{uploadDisplayPath}",250, #allowDelete#));
	echo("<br /><br />Note: The image will be resized to fit inside these pixel dimensions: #application.zcore.functions.zso(arguments.typeStruct, 'imagewidth',false,'1000')# x #application.zcore.functions.zso(arguments.typeStruct, 'imageheight',false,'1000')#<br />");  
	</cfscript>
	';
	</cfscript>
</cffunction>

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	if(arguments.value NEQ "" and fileexists(request.zos.globals.privatehomedir&'zupload/feature-options/#arguments.value#')){
		return ('<a href="#request.zos.globals.domain#/zupload/feature-options/#arguments.value#" title="Click to enlarge" target="_blank"><img src="#request.zos.globals.domain#/zupload/feature-options/#arguments.value#" alt="Uploaded Image" style="width:100%; max-width:100px;" /></a>');
	}else{
		return ('N/A');
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
	var nv="";
	var nvd=0;
	var arrList=0;
	var oldnv=0;
	var photoresize=0;
	form[arguments.prefixString&arguments.row["feature_field_id"]]=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
	nv=form[arguments.prefixString&arguments.row["feature_field_id"]];
	originalFile="";
	if(nv NEQ ""){
		var tempDir=getTempDirectory();
		if((len(nv) LTE len(tempDir) or left(nv, len(tempDir)) NEQ tempDir or not fileexists(nv))){
			if((len(nv) LTE len(request.zos.installPath) or left(nv, len(request.zos.installPath)) NEQ request.zos.installPath or not fileexists(nv))){
				return { success: true, value: replace(nv, '/zupload/feature-options/', ''), dateValue: "" };
			}
		}
		photoresize=application.zcore.functions.zso(arguments.typeStruct, 'imagewidth',false,'1000')&"x"&application.zcore.functions.zso(arguments.typeStruct, 'imageHeight',false,'1000');
		nvd=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_delete');
		destination=application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/feature-options/';
		//echo(form[arguments.prefixString&arguments.row["feature_field_id"]]);	abort;
		if(application.zcore.functions.zso(arguments.typeStruct, 'imagecrop') EQ '1'){
			arrList = application.zcore.functions.zUploadResizedImagesToDb(arguments.prefixString&arguments.row["feature_field_id"], destination, photoresize,'','','',request.zos.globals.datasource,'1', request.zos.globals.id, false);
			//originalPath=form[arguments.prefixString&arguments.row["feature_field_id"]];

		}else{
			arrList = application.zcore.functions.zUploadResizedImagesToDb(arguments.prefixString&arguments.row["feature_field_id"], destination, photoresize,'','','',request.zos.globals.datasource,'', request.zos.globals.id, false);
		}
		if(isarray(arrList) EQ false){
			return {success:false, message: '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a jpeg, png or gif file.<br />'&request.zImageErrorCause };
			
			nv=oldnv;
		}else if(ArrayLen(arrList) NEQ 0){
			originalFile=request.zos.lastUploadFileName;
			if(arguments.dataFields[arguments.row.feature_field_variable_name] NEQ ""){
				arrValue=listToArray(arguments.dataFields[arguments.row.feature_field_variable_name], chr(9), true);
				application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/feature-options/'&arrValue[1]);	
				if(arrayLen(arrValue) EQ 2){
					application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/feature-options/'&arrValue[2]);	
				}
			}
			oldnv='';
			nv=arrList[1];
			tempPath9=application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/feature-options/'; 
			arguments.typeStruct.imagemaskpath=application.zcore.functions.zso(arguments.typeStruct, 'imagemaskpath');
			if(arguments.typeStruct.imagemaskpath NEQ ""){
				absImageMaskPath=request.zos.globals.homedir&removechars(arguments.typeStruct.imagemaskpath, 1, 1);
				
				var ts=structnew();
				ts.absImageMaskPath=absImageMaskPath;
				ts.absImageInputPath=tempPath9&nv;
				tempFileName=application.zcore.functions.zgetFileName(nv);
				tempIndex=1;
				while(true){
					if(not fileexists(tempPath9&tempFileName&tempIndex&".png")){
						break;
					}
					tempIndex++;
					if(tempIndex GTE 500){
						throw("Infinite loop when applying image mask", "custom");
					}
				}
				ts.absImageOutputPath=tempPath9&tempFileName&tempIndex&".png"; 
				var result=application.zcore.functions.zApplyMaskToImage(ts); 
				if(result){
					nv=tempFileName&tempIndex&".png";
				}else{
					nv=oldnv;
					application.zcore.status.setStatus(request.zsid, 'Failed to apply mask to image.  Verify mask file is valid and still exists.');	
				}
				if(ts.absImageInputPath NEQ ts.absImageOutputPath){
					application.zcore.functions.zdeleteFile(ts.absImageInputPath);	
				}
			}
			if(oldnv NEQ "" and nv NEQ oldnv){
				application.zcore.functions.zdeletefile(tempPath9&oldnv);	
			}
		}else{
			nv=oldnv;
		}
	}else{
		// retrieve from the database instead
		arrValue=listToArray(arguments.dataFields[arguments.row.feature_field_variable_name], chr(9), true);
		nv=arrValue[1];
		originalFile="";
		if(arraylen(arrValue) EQ 2){
			originalFile=arrValue[2];
		}
		nvd=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_delete');
		if(nvd EQ 1){
			structdelete(form, arguments.prefixString&arguments.row["feature_field_id"]);
			application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/feature-options/'&nv);
			application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&'zupload/feature-options/'&originalFile);
			nv='';	
			originalFile='';
		}else{
			form[arguments.prefixString&arguments.row["feature_field_id"]]=arguments.dataFields[arguments.row.feature_field_variable_name];
		}
	}
	rs={ success: true, value: nv, dateValue: "" };
	if(originalFile NEQ ""){
		rs.originalFile=originalFile;
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getFormValue" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="dataFields" type="struct" required="yes">
	<cfscript> 
	nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
	if(nv EQ ""){
		return arguments.dataFields[arguments.row.feature_field_variable_name];
	}
	return nv;
	</cfscript>
</cffunction>

<cffunction name="getTypeName" output="no" localmode="modern" access="public">
	<cfscript>
	return 'Image';
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
		imagewidth:application.zcore.functions.zso(arguments.dataStruct, 'imagewidth'),
		imageheight:application.zcore.functions.zso(arguments.dataStruct, 'imageheight'),
		imagecrop:application.zcore.functions.zso(arguments.dataStruct, 'imagecrop'),
		imagemaskpath:application.zcore.functions.zso(arguments.dataStruct, 'imagemaskpath')
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, typeStruct: ts};
	</cfscript>
</cffunction>
		
<cffunction name="getFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		imagewidth:"",
		imageheight:"",
		imagecrop:"0",
		imagemaskpath:""
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
		function validateFieldType3(postObj, arrError){ 
			var imagewidth=parseInt(postObj.imagewidth);
			var imageheight=parseInt(postObj.imageheight);
			if(isNaN(imagewidth) || imagewidth <=10){
				arrError.push('Image Max Width is required and must be greater then 10.');
			}
			if(isNaN(imageheight) || imageheight <=10){
				arrError.push('Image Max Height is required and must be greater then 10.');
			} 
		}
		</script>
		<input type="radio" name="feature_field_type_id" value="3" onClick="setType(3);" <cfif value EQ 3>checked="checked"</cfif>/>
		Image<br />
		<div id="typeFields3" style="display:none;padding-left:30px;"> 
			<p>Image Max Width:
			<input type="text" name="imagewidth" id="imagewidth" style="min-width:150px;" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'imagewidth'))#" /></p>

			<p>Image Max Height:
			<input type="text" name="imageheight" id="imageheight" style="min-width:150px;" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'imageheight'))#" /></p>
			<p>Crop:
			<input type="radio" name="imagecrop" id="imagecrop1" value="1" <cfif application.zcore.functions.zso(arguments.typeStruct, 'imagecrop') EQ 1 and application.zcore.functions.zso(arguments.typeStruct, 'imagecrop') NEQ "">checked="checked"</cfif>/>
			Yes
			<input type="radio" name="imagecrop" id="imagecrop0" value="0" <cfif application.zcore.functions.zso(arguments.typeStruct, 'imagecrop') EQ "" or application.zcore.functions.zso(arguments.typeStruct, 'imagecrop') EQ 0>checked="checked"</cfif>/>
			No</p>
			<p>Image Mask URL: 
			<input type="text" name="imagemaskpath" style="min-width:150px;" value="#htmleditformat(application.zcore.functions.zso(arguments.typeStruct, 'imagemaskpath'))#" /><br />Note: White pixels in the mask will result in the pixel having full opacity. Shades of grey are used to reduce opacity. Black will make the pixel have zero opacity.</p>
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