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
	return "You need to set this value manually";
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

<cffunction name="hasCustomDelete" localmode="modern" access="public" returntype="boolean" output="no">
	<cfscript>
	return true;
	</cfscript>
</cffunction>

<cffunction name="onDelete" localmode="modern" access="public">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfscript>
	uploadPath=getUploadPath(arguments.typeStruct); 
	if(arguments.value NEQ "" and fileexists(application.zcore.functions.zvar('privatehomedir',arguments.site_id)&uploadPath&'/feature-options/'&arguments.value)){
		application.zcore.functions.zdeletefile(application.zcore.functions.zvar('privatehomedir',arguments.site_id)&uploadPath&'/feature-options/'&arguments.value);
	}
	</cfscript>
</cffunction> 

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">  
	<cfsavecontent variable="local.output">
		<cfscript>
		var allowDelete=true;
		if(arguments.row["feature_field_required"] EQ 1){
			allowDelete=false;
		}
		var ts3=StructNew();
		ts3.name=arguments.prefixString&arguments.row["feature_field_id"];
		ts3.allowDelete=allowDelete;
		if(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]] NEQ ""){
			uploadPath=getUploadPath(arguments.typeStruct);
			if(uploadPath EQ "zuploadsecure"){
				ts3.downloadPath="/zuploadsecure/feature-options/";
				if(application.zcore.user.checkGroupAccess("administrator")){
					echo('<p><a href="#request.zos.currentHostName#/z/misc/download/index?fp='&urlencodedformat("/"&uploadPath&"/feature-options/"&arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]])&'" target="_blank">Download File</a></p>');
				}else{
					echo('<p>'&arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]]&' | You must be an administrator to download the file.</p>');
				}
			}else{
				ts3.downloadPath="/zupload/feature-options/";
				writeoutput('<p><a href="/'&uploadPath&'/feature-options/#arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]]#" 
				target="_blank" 
				title="#htmleditformat(arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]])#">Download File</a></p>');
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
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes"> 
	<cfscript>
	return ' ';
	</cfscript> 
</cffunction>

<cffunction name="getListValue" localmode="modern" access="public">
	<cfargument name="dataStruct" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	if(arguments.value NEQ ""){
		uploadPath=getUploadPath(arguments.typeStruct);
		if(uploadPath EQ "zuploadsecure"){
			return '<a href="#request.zos.globals.domain#/z/misc/download/index?fp='&urlencodedformat("/"&uploadPath&"/feature-options/"&arguments.value)&'" target="_blank">Download File</a>';
		}else{
			return '<a href="#request.zos.globals.domain#/'&uploadPath&'/feature-options/#arguments.value#" target="_blank">Download File</a>';
		}
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

<cffunction name="getUploadPath" localmode="modern" access="private">
	<cfargument name="typeStruct" type="struct" required="yes">
	<cfscript>
	uploadPath="zupload";
	if(application.zcore.functions.zso(arguments.typeStruct, 'file_securepath') EQ 'Yes'){
		uploadPath='zuploadsecure';
	}
	return uploadPath;
	</cfscript>
</cffunction>

<cffunction name="onBeforeUpdate" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="typeStruct" type="struct" required="yes"> 
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes"> 
	<cfscript>	
	var nv=0;
	uploadPath=getUploadPath(arguments.typeStruct);
	arguments.dataStruct["#variables.siteType#_x_option_group_id"]=arguments.row["#variables.siteType#_x_option_group_id"];
	nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
	var tempDir=getTempDirectory();
	filename="";
	if(structkeyexists(arguments.row, '#variables.siteType#_x_option_group_id')){
		form["#variables.siteType#_x_option_group_id"]=arguments.row["#variables.siteType#_x_option_group_id"];
		fileName=application.zcore.functions.zUploadFileToDb(arguments.prefixString&arguments.row["feature_field_id"], application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&uploadPath&'/feature-options/', '#variables.siteType#_x_option_group', '#variables.siteType#_x_option_group_id', arguments.prefixString&arguments.row["feature_field_id"]&'_delete', request.zos.zcoreDatasource, '#variables.siteType#_x_option_group_value');	
	}else{
		form["#variables.siteType#_x_option_id"]=arguments.row["#variables.siteType#_x_option_id"];
		fileName=application.zcore.functions.zUploadFileToDb(arguments.prefixString&arguments.row["feature_field_id"], application.zcore.functions.zvar('privatehomedir',request.zos.globals.id)&uploadPath&'/feature-options/', '#variables.siteType#_x_option', '#variables.siteType#_x_option_id', arguments.prefixString&arguments.row["feature_field_id"]&'_delete', request.zos.zcoreDatasource, '#variables.siteType#_x_option_value');	
	}
	if(not structkeyexists(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]&'_delete') and (isNull(fileName) or fileName EQ "")){
		if(structkeyexists(arguments.row, '#variables.siteType#_x_option_group_id')){
			arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]]=arguments.row["#variables.siteType#_x_option_group_value"];
			nv=arguments.row["#variables.siteType#_x_option_group_value"];
		}else{
			arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]]=arguments.row["#variables.siteType#_x_option_value"];
			nv=arguments.row["#variables.siteType#_x_option_value"];
		}
	}else{
		arguments.dataStruct[arguments.prefixString&arguments.row["feature_field_id"]]=fileName;
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
	var nv=application.zcore.functions.zso(arguments.dataStruct, arguments.prefixString&arguments.row["feature_field_id"]);
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
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, typeStruct: ts};
	</cfscript>
</cffunction>
		
<cffunction name="getFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={ 
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
	<input type="radio" name="feature_field_type_id" value="9" onClick="setType(9);" <cfif value EQ 9>checked="checked"</cfif>/>
	File<br />
	<div id="typeFields9" style="display:none;padding-left:30px;">

		<table style="border-spacing:0px;">
		<tr><td>Secure Path: </td><td>
		<cfscript>
		arguments.typeStruct.file_securepath=application.zcore.functions.zso(arguments.typeStruct, 'file_securepath', false, "No");
		if(arguments.typeStruct.file_securepath EQ ""){
			arguments.typeStruct.file_securepath="No";
		}
		var ts = StructNew();
		ts.name = "file_securepath";
		ts.style="border:none;background:none;";
		ts.labelList = "Yes,No";
		ts.valueList = "Yes,No";
		ts.hideSelect=true;
		ts.struct=arguments.typeStruct;
		writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
		</cfscript>
		</td></tr>
		</table>

	<!--- 


which fields must be done by client?
	amount
	subscription / purchase
ts={
	arrAmount:[
		// one time payment example
		{
			amount:2,
			label: "One Time Payment"
		},
		// subscription payment example
		{
			amount:2,
			label="Subscription Payment",
			frequency: 1, // ommitting this field or setting it to 0 disables the subscription feature for this payment option, 1 will collect a payment each subscriptionPeriod, 2+ will skip subscriptionPeriods (i.e. 2 is bimonthly, 3 is trimonthly etc)
			period: 'M', // M = month | Y = year | D = day,
		},
		// product purchase example
		{
			amount:30,
			label: "Product Purchase", 
			taxRate:6,
			shipping:10
		}
	],
	arrItem:[
		{
			name:'Product/Service',
			amount:2
		}
	],
	selectMessage: "Select Payment Field and Click Buy Now",
	buttonImage: "Buy now", // Must be "Buy now", "Checkout", "Donate" or "Custom"
	// buttonImageURL: "", // only used when buttonImage is "Custom"
	subscriptionPaymentLimit: 0, // 0 is unlimited, Otherwise you can set this between 2 and 52
	subscriptionRetry: true, // true will retry 2 times before cancelling subscription.
	subscriptionModifyEnabled: false, // true will allow the customer to change subscription - not recommended in most cases
	subscriptionTrialEnabled: false, // true will allow a different price or $0 price at the beginning of the subscription
	// subscriptionTrialPeriod: 'M', // M = month | Y = year | D = day | When subscriptionTrialEnabled is true, this value determine the length of the trial.
	// subscriptionTrialAmount: 0, // When subscriptionTrialEnabled is true, this value determine the price of the trial.  The price can be 0 or more.
	sandbox:false, // requires paypal developer sandbox account for "business" field if set to true
	business: "", // paypal merchant id (recommended) or paypal email address
	// invoice: 1, // must be unique on each transaction or don't specify one
	hideLabel: false,
	ipnURL: request.zos.currentHostName&"/z/misc/paypal/ipn", // It is better if this URL uses SSL
	returnURL: request.zos.currentHostName&"/z/misc/paypal/thank-you", // Note: The user is not sent to this URL automatically. They have to click a button after paying.
	returnLabel: "Continue shopping", // after payment, there is a button that will go to the return URL, this field changes the text on that button
	disableNote: true, // Set to false to allow the customer to enter notes in a comments field that is sent along with their payment.
	disableShipping: true, // Set to false to enable paypal's shipping features
	bottomMessage: "No PayPal account is required"
};
	 --->
	</div> 

	</cfsavecontent>
	<cfreturn output>
</cffunction> 


<cffunction name="getCreateTableColumnSQL" localmode="modern" access="public">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return "`#arguments.fieldName#` text NOT NULL";
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>