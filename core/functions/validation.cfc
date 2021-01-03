<cfcomponent extends="zcorerootmapping.functions.xml">
<cfoutput>

<!--- 
myform = StructNew();
myform.fieldname.required = true;
myform.fieldname.checkbox = true;
myform.fieldname.createdate = true;
myform.fieldname.createtime = true;
myform.fieldname.createdatetime = true;
myform.fieldname.createESTDate = true;
myform.fieldname.createESTDate = true;
myform.fieldname.createESTTime = true;
myform.fieldname.createESTDateTime = true;
myform.fieldname.date = true;
myform.fieldname.time = true;
myform.fieldname.allowNull = false;
myform.fieldname.html = false;
myform.fieldname.number = true;
myform.fieldname.length = "1-100"; // also "10" for non-range length
myform.fieldname.numberrange = "2-20"; // also "20" for non-range length
myform.fieldname.upperCase = true;
myform.fieldname.lowerCase = true;
myform.fieldname.firstCaps = true;
myform.fieldname.email = true;
myform.fieldname.charLimit = "a-z"; // uses simple regular expression to match chars
// DISABLED: file or resized image uploads!
myform.fieldname.uploadAbsPath = request.zos.globals.homedir;
myform.fieldname.uploadPath = "images/uploads/";
myform.fieldname.databaseAndTable = "database.table";
myform.fieldname.primaryKeyId = "field_name";
myform.fieldname.fieldList = "image_one,image_two"; // fields used to store the image names
myform.fieldname.resizeList = "400x300,90x50"; // creates multiple sizes from one upload file

result = zValidateStruct(form, myForm, statusId, replaceVars, enumerate, suppressErrors);
if(result){
	// success
}else{
	// errors
}
--->
<cffunction name="zValidateStruct" localmode="modern" output="true" returntype="any">
	<cfargument name="targetStruct" type="struct" required="yes">
	<cfargument name="validationStruct" type="struct" required="yes">
	<cfargument name="statusId" type="any" required="no">
    <cfargument name="replaceVars" type="boolean" required="no" default="#false#">
	<cfargument name="enumerate" type="any" required="no" default="">
	<cfargument name="suppressErrors" type="boolean" required="no" default="#false#">
	<!--- 
	<cfargument name="enumerate" type="any" required="no" default="">
	<cfargument name="suppressErrors" type="boolean" required="no" default="#false#"> --->
	<cfscript>
	var friendlyName='';
	var tempFieldList='';
	var n='';
	var errorCount = 0;
	var value = "";
	var curStructStr=0;
	var curStruct=0;
	var fieldValue = "";
	var tempFieldValue = "";
	var tempDeleteField = "";
	var tempImageList = "";
	var tempStruct = StructNew();
	var tempErrorStruct = StructNew();
	var resultStruct = StructNew();
	var destinationPath = "";
	var error = "";
	var current = "";
	var i = 0;
	var allowNull = false;
	if(arguments.enumerate EQ false){
		arguments.enumerate = "";
	}
	for(i in arguments.validationStruct){
		current =arguments.validationStruct[i];
		if(structkeyexists(current,'friendlyName')){
			friendlyName = current.friendlyName;
		}else{
			friendlyName = application.zcore.functions.zFriendlyName(i);
		}
		i = i&arguments.enumerate;
		if(structkeyexists(current, 'required')){			
			value = current["required"];
			if(value and structkeyexists(arguments.targetStruct, i) EQ false){
				error = friendlyName & " required";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				continue;
			}
		}
		if(structkeyexists(arguments.targetStruct,i)){
			fieldValue = arguments.targetStruct[i];
		}else{
			if(structkeyexists(current, 'checkBox')){
				value = current["checkBox"];
				if(value){
					StructInsert(tempStruct, i, 0, true);
				}
			}
			if(structkeyexists(current, 'createDate')){			
				value = current["createDate"];
				if(value){
					StructInsert(tempStruct, i, DateFormat(now(), "yyyy-mm-dd"), true);
				}
			}
			if(structkeyexists(current, 'createTime')){			
				value = current["createTime"];
				if(value){
					StructInsert(tempStruct, i, TimeFormat(now(), "HH:mm:ss"), true);
				}
			}
			if(structkeyexists(current, 'createDateTime')){			
				value = current["createDateTime"];
				if(value){
					StructInsert(tempStruct, i, request.zos.mysqlnow, true);
				}
			}
			if(structkeyexists(current, 'createESTDate')){			
				value = current["createESTDate"];
				if(value){
					StructInsert(tempStruct, i, DateFormat(application.zcore.functions.zESTDateTime(), "yyyy-mm-dd"), true);
				}
			}
			if(structkeyexists(current, 'createESTTime')){			
				value = current["createESTTime"];
				if(value){
					StructInsert(tempStruct, i, TimeFormat(application.zcore.functions.zESTDateTime(), "HH:mm:ss"), true);
				}
			}
			if(structkeyexists(current, 'createESTDateTime')){			
				value = current["createESTDateTime"];
				if(value){
					StructInsert(tempStruct, i, DateFormat(application.zcore.functions.zESTDateTime(), "yyyy-mm-dd")&" "&TimeFormat(application.zcore.functions.zESTDateTime(), "HH:mm:ss"), true);
				}
			}
			if(structkeyexists(current, 'date')){			
				if(structkeyexists(current, 'dateDropDown')){
					if(structkeyexists(arguments.targetStruct, i&'_year') and structkeyexists(arguments.targetStruct, i&'_month') and structkeyexists(arguments.targetStruct, i&'_day')){
						fieldvalue = arguments.targetStruct[i&'_year']&"/"&arguments.targetStruct[i&'_month']&"/"&arguments.targetStruct[i&'_day'];
						if(value and isDate(fieldvalue) NEQ false){
							StructInsert(tempStruct, i, DateFormat(arguments.targetStruct[i], "yyyy-mm-dd"), true);
						}else{
							error = friendlyName & " must be a well formatted date, (ex. 12/2/1981)";
							errorCount = errorCount + 1;
							StructInsert(tempErrorStruct, i, error, true);
							StructInsert(tempStruct, i, fieldValue, true);
						}
					}
				}
			}
			if(structkeyexists(current, 'datetime')){			
				value = current["datetime"];
				if(value and structkeyexists(arguments.targetStruct, i&'_date') and structkeyexists(arguments.targetStruct, i&'_time') and isDate(arguments.targetStruct[i&'_date']) NEQ false and isDate(arguments.targetStruct[i&'_time']) NEQ false){
					StructInsert(tempStruct, i, DateFormat(arguments.targetStruct[i&'_date'], "yyyy-mm-dd")&" "&TimeFormat(arguments.targetStruct[i&'_time'], "HH:mm:ss"), true);
				}else{
					error = friendlyName & " must be a well formatted date/time, (ex. 12/2/1981 3:30 pm)";
					errorCount = errorCount + 1;
					StructInsert(tempErrorStruct, i, error, true);
					StructInsert(tempStruct, i, fieldValue, true);
				}
			}
			continue;
		}
		if(structkeyexists(current, 'allowNull')){
			value = current["allowNull"];
			if(fieldValue EQ ""){
				if(value){
					continue;
				}else{
					error = friendlyName & " required";
					errorCount = errorCount + 1;
					StructInsert(tempErrorStruct, i, error, true);
					continue;
				}
			}
		}else{
			if(isSimpleValue(fieldValue) and fieldValue EQ ""){
				error = friendlyName & " required";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				continue;
			}
		}
		if(structkeyexists(current, 'html')){			
			value = current["html"];
			if(value){
				StructInsert(tempStruct, i, fieldValue, true);
			}else{
				fieldValue = HTMLEditFormat(fieldValue);
				StructInsert(tempStruct, i, fieldValue , true);
			}
		}

		if(structkeyexists(current, 'length')){
			value = current["length"];
			if(listLen(value, "-") EQ 2){
				if(len(fieldValue) LT listGetAt(value, 1, "-") or len(fieldValue) GT listGetAt(value, 2, "-")){
					error = friendlyName & " must be a length of "&value&" characters.";
					errorCount = errorCount + 1;
					StructInsert(tempErrorStruct, i, error, true);
					StructInsert(tempStruct, i, fieldValue, true);
					continue;
				}
			}else{
				if(len(fieldValue) GT value){
					error = friendlyName & " must be a length of "&value&" characters.";
					errorCount = errorCount + 1;
					StructInsert(tempErrorStruct, i, error, true);
					StructInsert(tempStruct, i, fieldValue, true);
					continue;
				}
			
			}
		}
		if(structkeyexists(current, 'number')){	
			value = current["number"];
			if(value and isNumeric(fieldValue) EQ false){
				error = friendlyName & " must be a number";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				StructInsert(tempStruct, i, fieldValue, true);
				continue;
			}
		}
		if(structkeyexists(current, 'numberRange')){
			value = current["numberRange"];
			if(listLen(value, "-") EQ 2){
				if(fieldValue LT listGetAt(value, 1, "-") or fieldValue GT listGetAt(value, 2, "-")){
					error = friendlyName & " must be between "&value&".";
					errorCount = errorCount + 1;
					StructInsert(tempErrorStruct, i, error, true);
					StructInsert(tempStruct, i, fieldValue, true);
					continue;
				}
			}else{
				application.zcore.template.fail("Error: FUNCTION: zValidateForm: numberRange must be formatted like 0-100");
			}
		}
		if(structkeyexists(current, 'upperCase')){			
			value = current["upperCase"];
			if(value){
				StructInsert(tempStruct, i, uCase(fieldValue), true);
			}
		}
		if(structkeyexists(current, 'lowerCase')){			
			value = current["lowerCase"];
			if(value){
				StructInsert(tempStruct, i, lCase(fieldValue), true);
			}
		}
		if(structkeyexists(current, 'firstCaps')){			
			value = current["firstCaps"];
			if(value){
				StructInsert(tempStruct, i, application.zcore.functions.zFirstLetterCaps(fieldValue), true);
			}
		}
		if(structkeyexists(current, 'email')){	
			value = current["email"];
			tempFieldValue = application.zcore.functions.zEmailValidate(fieldValue);
			if(value and tempFieldValue NEQ false){
				//StructInsert(tempStruct, i, tempFieldValue, true);
				StructInsert(tempStruct, i, fieldValue, true);
			}else{
				error = friendlyName & " must be a well formatted email address, (ex. johndoe@domain.com)";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				StructInsert(tempStruct, i, fieldValue, true);
				continue;
			}
		}
		if(structkeyexists(current, 'date')){			
			value = current["date"];
			if(value and isNumericDate(fieldValue) NEQ false){
				StructInsert(tempStruct, i, DateFormat(fieldValue, "yyyy-mm-dd"), true);
			}else{
				error = friendlyName & " must be a well formatted date, (ex. 12/2/1981)";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				StructInsert(tempStruct, i, fieldValue, true);
				continue;
			}
		}
		if(structkeyexists(current, 'time')){			
			value = current["time"];
			if(value and isNumericDate(fieldValue) NEQ false){
				StructInsert(tempStruct, i, TimeFormat(fieldValue, "HH:mm:ss"), true);
			}else{
				error = friendlyName & " must be a well formatted time, (ex. 1:30 pm)";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				StructInsert(tempStruct, i, fieldValue, true);
				continue;
			}
		}
		if(structkeyexists(current, 'charLimit')){			
			value = current["charLimit"];
			value = replacelist(value, '\,+,*,?,.,[,^,$,(,),{,|', '\\,\+,\*,\?,\.,\[,\^,\$,\(,\),\{,\|');
			if(REFind("[^"&value&"\s]+", fieldValue) NEQ 0){
				error = friendlyName & " must be well formatted. You may use the only following characters, "&value;
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				StructInsert(tempStruct, i, fieldValue, true);
				continue;
			}
		}
	}
	
	
	
	
	// store processed variables.
	application.zcore.status.setStatus(arguments.statusId, false, tempStruct);
	// append error fields to the error field struct
	application.zcore.status.setErrorStruct(arguments.statusId, tempErrorStruct);
	if(arguments.suppressErrors EQ false){
		application.zcore.status.setErrorStruct(arguments.statusId, tempErrorStruct);
	}
	if(arguments.replaceVars EQ true){
		StructAppend(variables, tempStruct, true);
		StructAppend(form, tempStruct, true);
	}
	if(errorCount GT 0){
		return true;		
	}else{
		return false;
	}
	</cfscript>
</cffunction>











<!--- 
myform = StructNew();
myform.fieldname.required = true;
myform.fieldname.checkbox = true;
myform.fieldname.createdate = true;
myform.fieldname.createtime = true;
myform.fieldname.createdatetime = true;
myform.fieldname.createESTDate = true;
myform.fieldname.createESTDate = true;
myform.fieldname.createESTTime = true;
myform.fieldname.createESTDateTime = true;
myform.fieldname.date = true;
myform.fieldname.time = true;
myform.fieldname.allowNull = false;
myform.fieldname.html = false;
myform.fieldname.number = true;
myform.fieldname.length = "1-100"; // also "10" for non-range length
myform.fieldname.numberrange = "2-20"; // also "20" for non-range length
myform.fieldname.upperCase = true;
myform.fieldname.lowerCase = true;
myform.fieldname.firstCaps = true;
myform.fieldname.email = true;
myform.fieldname.charLimit = "a-z"; // uses simple regular expression to match chars
// file or resized image uploads!
myform.fieldname.uploadAbsPath = request.zos.globals.homedir;
myform.fieldname.uploadPath = "images/uploads/";
myform.fieldname.databaseAndTable = "database.table";
myform.fieldname.primaryKeyId = "field_name";
myform.fieldname.fieldList = "image_one,image_two"; // fields used to store the image names
myform.fieldname.resizeList = "400x300,90x50"; // creates multiple sizes from one upload file

result = zValidateForm(statusId, myform, replaceVars, enumerate, suppressErrors);
if(result){
	// success
}else{
	// errors
}
--->
<cffunction name="zValidateForm" localmode="modern" output="true" returntype="any" hint="Deprecated: Please use zValidateStruct instead. Not compatible with localmode=modern">
	<cfargument name="statusId" type="any" required="no">
	<cfargument name="formName" type="any" required="yes">
	<cfargument name="replaceVars" type="any" required="no" default="#false#">
	<cfargument name="enumerate" type="any" required="no" default="">
	<cfargument name="suppressErrors" type="boolean" required="no" default="#false#">
	<cfscript>
	var friendlyName='';
	var tempFieldList='';
	var n='';
	var formStruct = "";
	var errorCount = 0;
	var value = "";
	var curStructStr=0;
	var curStruct=0;
	var fieldValue = "";
	var tempFieldValue = "";
	var tempDeleteField = "";
	var tempImageList = "";
	var tempStruct = StructNew();
	var tempErrorStruct = StructNew();
	var resultStruct = StructNew();
	var destinationPath = "";
	var error = "";
	var current = "";
	var i = 0;
	var allowNull = false;
	if(request.zos.isDeveloper){
		application.zcore.functions.zError("zValidateForm is deprecated: Please use zValidateStruct instead.");
	}
	if(arguments.enumerate EQ false){
		arguments.enumerate = "";
	}
	if(isstruct(arguments.formName)){
		formStruct=arguments.formName;
	}else if(isDefined(arguments.formName)){
		formStruct = evaluate(arguments.formName);
	}else{
		application.zcore.template.fail("Error: zValidateForm: Missing form validation struct",true);
	}	
	for(i in formStruct){
		current =formStruct[i];
		if(structkeyexists(current,'friendlyName')){
			friendlyName = current.friendlyName;
		}else{
			friendlyName = application.zcore.functions.zFriendlyName(i);
		}
		i = i&arguments.enumerate;
		if(structkeyexists(current, 'required')){			
			value = current["required"];
			if(structkeyexists(variables, i)){
				curStructStr="variables";
			}else{
				curStructStr="form";
			}
			if(value and isDefined(curStructStr&"."&i) EQ false){
				error = friendlyName & " required";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				continue;
			}
		}
		
		if(structkeyexists(variables,i)){
			fieldValue = variables[i];
		}else if(structkeyexists(form,i)){
			fieldValue = form[i];
		}else{
			if(structkeyexists(current, 'checkBox')){
				value = current["checkBox"];
				if(value){
					StructInsert(tempStruct, i, 0, true);
				}
			}
			if(structkeyexists(current, 'createDate')){			
				value = current["createDate"];
				if(value){
					StructInsert(tempStruct, i, DateFormat(now(), "yyyy-mm-dd"), true);
				}
			}
			if(structkeyexists(current, 'createTime')){			
				value = current["createTime"];
				if(value){
					StructInsert(tempStruct, i, TimeFormat(now(), "HH:mm:ss"), true);
				}
			}
			if(structkeyexists(current, 'createDateTime')){			
				value = current["createDateTime"];
				if(value){
					StructInsert(tempStruct, i, request.zos.mysqlnow, true);
				}
			}
			if(structkeyexists(current, 'createESTDate')){			
				value = current["createESTDate"];
				if(value){
					StructInsert(tempStruct, i, DateFormat(application.zcore.functions.zESTDateTime(), "yyyy-mm-dd"), true);
				}
			}
			if(structkeyexists(current, 'createESTTime')){			
				value = current["createESTTime"];
				if(value){
					StructInsert(tempStruct, i, TimeFormat(application.zcore.functions.zESTDateTime(), "HH:mm:ss"), true);
				}
			}
			if(structkeyexists(current, 'createESTDateTime')){			
				value = current["createESTDateTime"];
				if(value){
					StructInsert(tempStruct, i, DateFormat(application.zcore.functions.zESTDateTime(), "yyyy-mm-dd")&" "&TimeFormat(application.zcore.functions.zESTDateTime(), "HH:mm:ss"), true);
				}
			}
			if(structkeyexists(current, 'date')){			
				if(structkeyexists(current, 'dateDropDown')){
					if(structkeyexists(variables, i&'_year')){
						curStruct=variables;
					}else{
						curStruct=form;
					}
					if(structkeyexists(curStruct, i&'_year') and structkeyexists(curStruct, i&'_month') and structkeyexists(curStruct, i&'_day')){
						fieldvalue = curStruct[i&'_year']&"/"&curStruct[i&'_month']&"/"&curStruct[i&'_day'];
						if(value and isDate(fieldvalue) NEQ false){
							StructInsert(tempStruct, i, DateFormat(curStruct[i], "yyyy-mm-dd"), true);
						}else{
							error = friendlyName & " must be a well formatted date, (ex. 12/2/1981)";
							errorCount = errorCount + 1;
							StructInsert(tempErrorStruct, i, error, true);
							StructInsert(tempStruct, i, fieldValue, true);
						}
					}
				}
			}
			if(structkeyexists(current, 'datetime')){			
				value = current["datetime"];
				if(structkeyexists(variables, i&'_date')){
					curStruct=variables;
				}else{
					curStruct=form;
				}
				if(value and structkeyexists(curStruct, i&'_date') and structkeyexists(curStruct, i&'_time') and isDate(curStruct[i&'_date']) NEQ false and isDate(curStruct[i&'_time']) NEQ false){
					StructInsert(tempStruct, i, DateFormat(curStruct[i&'_date'], "yyyy-mm-dd")&" "&TimeFormat(curStruct[i&'_time'], "HH:mm:ss"), true);
				}else{
					error = friendlyName & " must be a well formatted date/time, (ex. 12/2/1981 3:30 pm)";
					errorCount = errorCount + 1;
					StructInsert(tempErrorStruct, i, error, true);
					StructInsert(tempStruct, i, fieldValue, true);
				}
			}
			continue;
		}
		if(structkeyexists(current, 'allowNull')){
			value = current["allowNull"];
			if(fieldValue EQ ""){
				if(value){
					continue;
				}else{
					error = friendlyName & " required";
					errorCount = errorCount + 1;
					StructInsert(tempErrorStruct, i, error, true);
					continue;
				}
			}
		}else{
			if(fieldValue EQ ""){
				error = friendlyName & " required";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				continue;
			}
		}
		if(structkeyexists(current, 'html')){			
			value = current["html"];
			if(value){
				StructInsert(tempStruct, i, fieldValue, true);
			}else{
				fieldValue = HTMLEditFormat(fieldValue);
				StructInsert(tempStruct, i, fieldValue , true);
			}
		}

		if(structkeyexists(current, 'length')){
			value = current["length"];
			if(listLen(value, "-") EQ 2){
				if(len(fieldValue) LT listGetAt(value, 1, "-") or len(fieldValue) GT listGetAt(value, 2, "-")){
					error = friendlyName & " must be a length of "&value&" characters.";
					errorCount = errorCount + 1;
					StructInsert(tempErrorStruct, i, error, true);
					StructInsert(tempStruct, i, fieldValue, true);
					continue;
				}
			}else{
				if(len(fieldValue) GT value){
					error = friendlyName & " must be a length of "&value&" characters.";
					errorCount = errorCount + 1;
					StructInsert(tempErrorStruct, i, error, true);
					StructInsert(tempStruct, i, fieldValue, true);
					continue;
				}
			
			}
		}
		if(structkeyexists(current, 'number')){	
			value = current["number"];
			if(value and isNumeric(fieldValue) EQ false){
				error = friendlyName & " must be a number";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				StructInsert(tempStruct, i, fieldValue, true);
				continue;
			}
		}
		if(structkeyexists(current, 'numberRange')){
			value = current["numberRange"];
			if(listLen(value, "-") EQ 2){
				if(fieldValue LT listGetAt(value, 1, "-") or fieldValue GT listGetAt(value, 2, "-")){
					error = friendlyName & " must be between "&value&".";
					errorCount = errorCount + 1;
					StructInsert(tempErrorStruct, i, error, true);
					StructInsert(tempStruct, i, fieldValue, true);
					continue;
				}
			}else{
				application.zcore.template.fail("Error: FUNCTION: zValidateForm: numberRange must be formatted like 0-100");
			}
		}
		if(structkeyexists(current, 'upperCase')){			
			value = current["upperCase"];
			if(value){
				StructInsert(tempStruct, i, uCase(fieldValue), true);
			}
		}
		if(structkeyexists(current, 'lowerCase')){			
			value = current["lowerCase"];
			if(value){
				StructInsert(tempStruct, i, lCase(fieldValue), true);
			}
		}
		if(structkeyexists(current, 'firstCaps')){			
			value = current["firstCaps"];
			if(value){
				StructInsert(tempStruct, i, application.zcore.functions.zFirstLetterCaps(fieldValue), true);
			}
		}
		if(structkeyexists(current, 'email')){	
			value = current["email"];
			tempFieldValue = application.zcore.functions.zEmailValidate(fieldValue);
			if(value and tempFieldValue NEQ false){
				//StructInsert(tempStruct, i, tempFieldValue, true);
				StructInsert(tempStruct, i, fieldValue, true);
			}else{
				error = friendlyName & " must be a well formatted email address, (ex. johndoe@domain.com)";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				StructInsert(tempStruct, i, fieldValue, true);
				continue;
			}
		}
		if(structkeyexists(current, 'date')){			
			value = current["date"];
			if(value and isNumericDate(fieldValue) NEQ false){
				StructInsert(tempStruct, i, DateFormat(fieldValue, "yyyy-mm-dd"), true);
			}else{
				error = friendlyName & " must be a well formatted date, (ex. 12/2/1981)";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				StructInsert(tempStruct, i, fieldValue, true);
				continue;
			}
		}
		if(structkeyexists(current, 'time')){			
			value = current["time"];
			if(value and isNumericDate(fieldValue) NEQ false){
				StructInsert(tempStruct, i, TimeFormat(fieldValue, "HH:mm:ss"), true);
			}else{
				error = friendlyName & " must be a well formatted time, (ex. 1:30 pm)";
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				StructInsert(tempStruct, i, fieldValue, true);
				continue;
			}
		}
		if(structkeyexists(current, 'charLimit')){			
			value = current["charLimit"];
			value = replacelist(value, '\,+,*,?,.,[,^,$,(,),{,|', '\\,\+,\*,\?,\.,\[,\^,\$,\(,\),\{,\|');
			if(REFind("[^"&value&"\s]+", fieldValue) NEQ 0){
				error = friendlyName & " must be well formatted. You may use the only following characters, "&value;
				errorCount = errorCount + 1;
				StructInsert(tempErrorStruct, i, error, true);
				StructInsert(tempStruct, i, fieldValue, true);
				continue;
			}
		}
	}
	
	
	
	// store processed variables.
	application.zcore.status.setStatus(arguments.statusId, false, tempStruct);
	// append error fields to the error field struct
	application.zcore.status.setErrorStruct(arguments.statusId, tempErrorStruct);
	if(arguments.suppressErrors EQ false){
		application.zcore.status.setErrorStruct(arguments.statusId, tempErrorStruct);
	}
	if(arguments.replaceVars EQ true){
		StructAppend(variables, tempStruct, true);
		StructAppend(form, tempStruct, true);
	}
	if(errorCount GT 0){
		return true;		
	}else{
		return false;
	}
	</cfscript>
</cffunction>



</cfoutput>
</cfcomponent>