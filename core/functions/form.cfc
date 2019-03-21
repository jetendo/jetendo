<cfcomponent extends="zcorerootmapping.functions.leadRouting">
<cfoutput>
<!--- application.zcore.functions.filterCountryByStruct({"us":true}); --->
<cffunction name="filterCountryByStruct" output="no" returntype="array" localmode="modern">
	<cfargument name="countryStruct" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("country", request.zos.zcoreDatasource)# 
	ORDER BY country_name ASC";
	qCountry=db.execute("qCountry");
	arrC=[];
	for(row in qCountry){
		if(structkeyexists(arguments.countryStruct, row.country_code) or structkeyexists(arguments.countryStruct, row.country_name)){
			arrayAppend(arrC, {code:row.country_code, name: row.country_name});
		}
	}
	return arrC;
	</cfscript>
</cffunction>

<cffunction name="zInternalGetRecurseLabelValueStruct" localmode="modern" access="public">
	<cfargument name="arrData" type="array" required="yes">
	<cfargument name="parentStruct" type="struct" required="yes">
	<cfargument name="arrParentLabel" type="array" required="yes">
	<cfargument name="parentId" type="string" required="yes">
	<cfscript>
	if(not structkeyexists(arguments.parentStruct, arguments.parentId)){
		return;
	}
	a=arguments.parentStruct[arguments.parentId];
	for(i=1;i<=arraylen(a);i++){
		a[i].arrParentLabel=arguments.arrParentLabel; 
		arrayAppend(arguments.arrData, a[i]);
		if(arrayLen(arguments.arrData) GT 100){
			throw("Possible infinite loop for this data set.");
		}
		if(a[i].value NEQ 0 and structkeyexists(arguments.parentStruct, a[i].value)){
			a2=duplicate(a[i].arrParentLabel);
			arrayAppend(a2, a[i].label); 
			application.zcore.functions.zInternalGetRecurseLabelValueStruct(arguments.arrData, arguments.parentStruct, a2, a[i].value);
		}
	}
	</cfscript>
</cffunction>

<cffunction name="zGetRecursiveLabelValueStruct" localmode="modern" access="public">
	<cfargument name="arrData" type="array" required="yes">
	<cfscript>
	parentStruct={};
	for(i=1;i<=arraylen(arguments.arrData);i++){
		ds=arguments.arrData[i];
		ds.arrParentLabel=[];
		if(not structkeyexists(parentStruct, ds.parent)){
			parentStruct[ds.parent]=[];
		}
		arrayAppend(parentStruct[ds.parent], ds);
	} 
	parentId=0;
	arrOut=[];
	application.zcore.functions.zInternalGetRecurseLabelValueStruct(arrOut, parentStruct, [], parentId);
	return arrOut;
	</cfscript>
</cffunction>

<cffunction name="zGetRecursiveLabelValueForSelectBox" localmode="modern" access="public">
	<cfargument name="arrData" type="array" required="yes">
	<cfscript>
	arrOut=application.zcore.functions.zGetRecursiveLabelValueStruct(arguments.arrData);
	rs={};
	rs.arrLabel=[];
	rs.arrValue=[];
	for(i=1;i<=arraylen(arrOut);i++){
		c=arrOut[i];
		if(arraylen(c.arrParentLabel)){
			d=duplicate(c.arrParentLabel);
			arrayAppend(d, c.label);
			arrayAppend(rs.arrLabel, arrayToList(d, " -> "));
			arrayAppend(rs.arrValue, c.value);
		}else{
			arrayAppend(rs.arrLabel, c.label);
			arrayAppend(rs.arrValue, c.value);
		}
	} 
	return rs;
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zVerifyRecaptcha() --->
<cffunction name="zVerifyRecaptcha" localmode="modern" output="no" returntype="boolean">
	<cfscript>
	var cfhttp=0;
	</cfscript>
	<cfif application.zcore.functions.zso(form, 'g-recaptcha-response') EQ "">
        <cfreturn false>
    </cfif>
    <cftry>
        <cfhttp url="https://www.google.com/recaptcha/api/siteverify" method="post" timeout="10">
        <cfhttpparam type="formfield" name="secret" value="#request.zos.globals.recaptchaSecretKey#">
        <cfhttpparam type="formfield" name="remoteip" value="#request.zos.cgi.remote_addr#">
        <cfhttpparam type="formfield" name="response" value="#application.zcore.functions.zso(form, 'g-recaptcha-response')#">
        </cfhttp>
        <cfif structkeyexists(CFHTTP,'statuscode') and left(CFHTTP.statusCode,3) EQ '200' and (isBinary(cfhttp.FileContent) or trim(CFHTTP.FileContent) NEQ "CFMXConnectionFailure" and trim(CFHTTP.FileContent) NEQ "Connection Failure")>
        	<cfscript>
			a=deserializeJson(cfhttp.filecontent);
			if(a.success){
				return true;
			}else{
				return false;
			}
			</cfscript>
        </cfif>
    <cfcatch type="any"></cfcatch>
    </cftry>
    <cfreturn false>
</cffunction>

<cffunction name="zGearButton" localmode="modern" access="public">
	<cfargument name="buttonHTML" type="string" required="yes">
	<a href="##" class="zGearButton" data-button-json="#htmleditformat(arguments.buttonHTML)#"><i class="fa fa-cog"></i></a>
</cffunction>

<cffunction name="zSetupMultipleSelect" localmode="modern" output="no" returntype="string">
    <cfargument name="id" type="string" required="yes">
    <cfargument name="value" type="string" required="yes">
    <cfargument name="required" type="boolean" required="no" default="#false#">
    <cfscript>
	if(not structkeyexists(request.zos, 'zSetupMultipleSelectInit')){
		request.zos.zSetupMultipleSelectIndex=0;
		application.zcore.functions.zRequireJqueryUI();
		application.zcore.skin.includeCSS("/z/javascript/jquery/jquery-ui-multiselect-widget/jquery.multiselect.css");
		application.zcore.skin.includeCSS("/z/javascript/jquery/jquery-ui-multiselect-widget/jquery.multiselect.filter.css");
		application.zcore.skin.includeJS("/z/javascript/jquery/jquery-ui-multiselect-widget/src/jquery.multiselect.js", '', 2);
		application.zcore.skin.includeJS("/z/javascript/jquery/jquery-ui-multiselect-widget/src/jquery.multiselect.filter.js", '', 2);
	}
	request.zos.zSetupMultipleSelectIndex++;
	savecontent variable="out"{
		echo('
		$("##'&arguments.id&'").after(');
		if(arguments.required){
			echo('" * "+');
		}
		echo('"<div id=\"zSelectMultipleSelected_'&arguments.id&'\" class=\"zSelectMultipleSelected\"></div>");
		$("##'&arguments.id&'").multiselect({
			click: function(event, ui){
				if(ui.value==''''){
					return false;
				}
				if(ui.checked && ui.value == "#jsstringformat(arguments.value)#"){
					alert("You can''t select the same element you are editing.");
					$(event.currentElement).each(function(){ this.checked=false; });
					return false;
				}else{
					return true;
				}
		   }
			}).multiselectfilter();
		$("##'&arguments.id&'").bind("change", function(){
			var arrLabel=[];
			for(var i=0;i<this.options.length;i++){
				if(this.options[i].selected){
					arrLabel.push(this.options[i].text); 
				}
			}
			if(arrLabel.length){
				$("##zSelectMultipleSelected_'&arguments.id&'").html("<strong class=\"zSelectMultipleSelectedLabel\">SELECTED:</strong><br />"+arrLabel.join("<br />"));
			}else{
				$("##zSelectMultipleSelected_'&arguments.id&'").html("");
			}
		});
		$("##'&arguments.id&'").trigger("change");
		');
	}
	application.zcore.skin.addDeferredScript(out);
	</cfscript>
</cffunction>
	

<cffunction name="zCheckFormHashValue" localmode="modern" output="no" returntype="string">
    <cfargument name="hashValue" type="string" required="yes">
    <cfscript>
    if(request.zos.globals.enableDemoMode EQ 1){
    	writeoutput('<h2>Lead submission is disabled in demo mode.</h2><p>Please go back and continuing browsing the demo site.</p>');
    	application.zcore.functions.zabort();
    } 
    if(structkeyexists(request.zsession,'formHashUniqueStruct') EQ false or structkeyexists(request.zsession.formHashUniqueStruct, arguments.hashValue) EQ false){
        return false;
    }else{
        structdelete(request.zsession.formHashUniqueStruct, arguments.hashValue);
        return true;
    }
    </cfscript>
</cffunction>
<cffunction name="zGetFormHashValue" localmode="modern" output="no" returntype="string">
    <cfscript>
    var hashValue=hash(randrange(13101231,1201230120)&request.zos.mysqlnow,'sha-256');
    application.zcore.session.forceEnable();
    if(isDefined('request.zsession') EQ false or structkeyexists(request.zsession,'formHashUniqueStruct') EQ false){
        request.zsession.formHashUniqueStruct=structnew();
    } 
    request.zsession.formHashUniqueStruct[hashValue]=true;
    return hashValue;
    </cfscript>
</cffunction>

<!--- #application.zcore.functions.zDisplayRecaptcha()# --->
<cffunction name="zDisplayRecaptcha" localmode="modern" output="yes" returntype="any">
	<cfscript>
	var theC=0;
	application.zcore.skin.includeJS("https://www.google.com/recaptcha/api.js")
    </cfscript>
	<cfsavecontent variable="theC"><div class="g-recaptcha" data-sitekey="#request.zos.globals.recaptchaSiteKey#"></div></cfsavecontent>
    <cfreturn theC>
</cffunction>

<!--- application.zcore.functions.zOutputToolTip(); --->
<cffunction name="zOutputToolTip" localmode="modern" returntype="any" output="no">
	<cfargument name="label" type="string" required="yes">
	<cfargument name="helpHTML" type="string" required="yes">
	<cfscript> 
	if(structkeyexists(request.zos.tempObj,"zOutputHelpToolTipIndex") EQ false){
		request.zos.tempObj.zOutputHelpToolTipIndex=0;  
	} 
	request.zos.tempObj.zOutputHelpToolTipIndex++;
	return '<span class="zHelpToolTipContainer"><span class="zHelpToolTipLabel">'&arguments.label&'</span> <span title="'&htmleditformat(arguments.helpHTML)&'" id="zHelpToolTip'&request.zos.tempObj.zOutputHelpToolTipIndex&'" class="zHelpToolTip"></span></span>';
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zOutputHelpToolTip(helpId); --->
<cffunction name="zOutputHelpToolTip" localmode="modern" >
	<cfargument name="defaultLabel" type="string" required="yes">
	<cfargument name="helpId" type="string" required="yes">
    <cfscript>   
	if(not structkeyexists(application.zcore,'helpStruct')){
		application.zcore.helpStruct={};
	}
	if(not structkeyexists(application.zcore.helpStruct,'tooltip')){
		application.zcore.helpStruct.tooltip={};
	}
	if(structkeyexists(request.zos.tempObj,"zOutputHelpToolTipIndex") EQ false){
		request.zos.tempObj.zOutputHelpToolTipIndex=0; 
	}
	if(not structkeyexists(application.zcore.helpStruct.tooltip, arguments.helpId)){
		return arguments.defaultLabel;
	}
	request.zos.tempObj.zOutputHelpToolTipIndex++;
	if(application.zcore.helpStruct.tooltip[arguments.helpId].html EQ ""){
		return '<span class="zHelpToolTipContainer"><span class="zHelpToolTipLabel">'&application.zcore.helpStruct.tooltip[arguments.helpId].label&'</span> </span>';
	}else{
		return '<span class="zHelpToolTipContainer"><span class="zHelpToolTipLabel">'&application.zcore.helpStruct.tooltip[arguments.helpId].label&'</span> <span title="'&htmleditformat(application.zcore.helpStruct.tooltip[arguments.helpId].html)&'" id="zHelpToolTip'&request.zos.tempObj.zOutputHelpToolTipIndex&'" class="zHelpToolTip"></span></span>';
	}
	</cfscript>
</cffunction>



<!---
FUNCTION
	zInputSelectBox(ss);
DESCRIPTION
	This function generates a selectBox. 
	name and (queryLabel or listLabels) are required.
USAGE
	ts = StructNew();
	ts.name = "name";
	ts.label="Name: ";
	ts.labelStyle="";
	ts.size = 1; // more for multiple select
	ts.multiple = false; // allow multiple selections (hold CTRL)
	ts.enumerate = 1; // for editing multiple records
	ts.output = true; // set to false to save to variable
	ts.style = "normal"; // stylesheet class
	ts.inlineStyle="";
	ts.hideSelect = true; // hide first element
	ts.selectLabel = "Any"; // override default first element text
	ts.selectedValues = "value1"; // send list if there are multiple values.
	ts.selectedDelimiter = ","; // change if comma conflicts...
	ts.required=false;
	ts.friendlyName="";
	ts.onChange = "zFunction();";
	ts.defaultValue = "value1";
	ts.dollarFormatLabels = true;
	// options for query data
	ts.arrData=[]; // alias for query (can be an array of structs)
	ts.query = qQuery; // this can be an array of structs or a query
	ts.queryLabelField = "table_label";
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryValueField = "table_value";
	// options for list data
	ts.listLabels = "value1,value2,value3";
	ts.listValues = "1,2,3";
	ts.listLabelsDelimiter = ","; 
	ts.listValuesDelimiter = ",";
	
	zInputSelectBox(ts);
 --->
<cffunction name="zInputSelectBox" localmode="modern" returntype="any" output="true">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var selectedValues = "";
	var selectBox = ""; 
	var noData = true; 
	var isSelected=false; 
	var ts =StructNew();	
	var arrLabel=arraynew(1);
	var arrValue=arraynew(1); 
	// set defaults
	ts.size = 1;
	ts.label="";
	ts.friendlyName="";
	ts.onchange="";
	ts.disableAjaxFieldData=false;
	ts.multiple = false;
	ts.enumerate = "";
	ts.inlineStyle="";
	ts.labelStyle="";
	ts.output = true;
	ts.required=false;
	ts.notranslate=false;
	ts.queryParseLabelVars = false;
	ts.queryParseValueVars = false;
	ts.listLabelsDelimiter = ","; // tab delimiter
	ts.listValuesDelimiter = ",";
	ts.selectedDelimiter=",";
	ts.dollarFormatLabels = false;
	// override defaults
	ss=arguments.ss;
	StructAppend(ss, ts, false);
	if(structkeyexists(ss, 'arrData')){
		ss.query=ss.arrData;
	}
	if(not structkeyexists(ss, 'name')){
		throw("zInputSelectBox: Requires a name");
	}
	savecontent variable="selectBox"{
		if(ss.friendlyName EQ ""){
			ss.friendlyName=application.zcore.functions.zFriendlyName(ss.name);
		}
		if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ "" and ss.disableAjaxFieldData EQ false){
			ds=structNew();
			ds.required=ss.required;
			
			local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
			ss.onchange&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
			arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
			writeoutput('<script type="text/javascript">/* <![CDATA[ */');
			writeoutput('zArrDeferredFunctions.push(function(){');
			writeoutput('var ts=new Object();');
			writeoutput('ts.type="select";');
			writeoutput('ts.id="#ss.name#";');
			writeoutput('ts.required=#ss.required#;');
			writeoutput('ts.friendlyName="#jsstringformat(ss.friendlyName)#";');
			writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
			writeoutput('});');
			writeoutput('/* ]]> */</script>');
		}
		if(structkeyexists(ss,'selectedValues') and ss.selectedValues NEQ ""){
			selectedValues = ss.selectedValues;
		}else if(structkeyexists(form, ss.name)){
			selectedValues = form[ss.name];
		}else if(structkeyexists(ss,'defaultValue')){
			selectedValues = ss.defaultValue;
		}else{
			selectedValues = "";
		} 
		if(structkeyexists(ss,'listValues')){
			arrValue=listtoarray(ss.listValues,ss.listValuesDelimiter,true);
		}
		if(structkeyexists(ss,'listLabels')){
			arrLabel=listtoarray(ss.listLabels,ss.listLabelsDelimiter,true);
		}else{
			arrLabel=arrValue;	
		}
		if(ss.label NEQ ""){
			echo('<label for="#ss.name##ss.enumerate#" style="#ss.labelStyle#">#ss.label#</label> ');
		}
		echo('<select ');
		if(ss.required){
			echo(" required ");
		}
		if(ss.onChange NEQ ""){
			echo('onchange="#ss.onChange#"');
		}
		echo(' ');
		if(structkeyexists(ss,'style')){
			echo('class="#ss.style#"');
		}
		echo(' ');
		if(ss.inlineStyle NEQ ""){
			echo('style="#ss.inlineStyle#"');
		}
		echo(' name="#ss.name##ss.enumerate#" id="#ss.name##ss.enumerate#" size="#ss.size#" ');
		if(ss.multiple){
			echo('multiple="multiple"');
		}
		echo('>');
		if(application.zcore.functions.zso(ss,'hideSelect', false, false) EQ false){
			echo('<option value="">');
			if(structkeyexists(ss,'selectLabel')){
				echo(htmleditformat(ss.selectLabel));
			}else{
				echo('-- Select --');
			}
			echo('</option>');
		}
		
		if(structkeyexists(ss, 'listValues')){
			count=0;
			for(value in arrValue){
				count++;
				echo('<option value="#htmleditformat(value)#" ');
				if(ss.notranslate){
					echo('class="notranslate"');
				}
				echo(' ');
				if(selectedValues EQ value or (selectedValues NEQ "" and listFind(selectedValues, value, ss.selectedDelimiter) NEQ 0)){
					echo('selected="selected"');
				}
				echo('>');
				if(structkeyexists(ss, 'listLabels')){
					if(ss.dollarFormatLabels and isNumeric(arrLabel[count])){
						echo('$#NumberFormat(arrLabel[count])#');
					}else{
						echo('#replace(htmleditformat(arrLabel[count]),"&amp;##","&##","all")#');
					}
				}else{
					if(ss.dollarFormatLabels and isNumeric(value)){
						echo('$#NumberFormat(value)#');
					}else{
						echo(replace(htmleditformat(value),"&amp;##","&##","all"));
					}
				}
				echo('</option>');
			}
			noData = false;
		}

		if(structkeyexists(ss, 'query') and structkeyexists(ss,'queryLabelField') and structkeyexists(ss,'queryValueField')){
			for(row in ss.query){
				if(structkeyexists(ss,'queryValueField')){
					if(ss.queryParseValueVars){
						v=htmleditformat(application.zcore.functions.zParseVariables(ss.queryValueField, false, row));
					}else{
						v=htmleditformat(row[ss.queryValueField]);
					}
				}else{
					v=htmleditformat(row[ss.queryLabelField]);
				}
				if(structkeyexists(ss,'queryLabelField')){
					if(ss.dollarFormatLabels and isNumeric(row[ss.queryLabelField])){
						v2="$"&NumberFormat(row[ss.queryLabelField]);
					}else{
						if(ss.queryParseLabelVars){
							v2=htmleditformat(application.zcore.functions.zParseVariables(ss.queryLabelField, false, row));
						}else{
							v2=replace(htmleditformat(row[ss.queryLabelField]),"&amp;##","&##","all")
						}
					}
				}else{
					if(ss.dollarFormatLabels and isNumeric(row[ss.queryValueField])){
						v2="$"&NumberFormat(row[ss.queryValueField]);
					}else{
						v2=replace(htmleditformat(ss.queryValueField),"&amp;##","&##","all");
					}
				}
				isSelected=false;
				if(ss.queryParseValueVars){
					if(selectedValues NEQ "" and listFind(selectedValues, application.zcore.functions.zParseVariables(ss.queryValueField, false, row), ss.selectedDelimiter) NEQ 0){
						isSelected=true;
					}
				}else if(selectedValues NEQ "" and listFind(selectedValues, row[ss.queryValueField], ss.selectedDelimiter) NEQ 0){
					isSelected=true;
				}
	        	echo('<option value="#v#" ');
	        	if(ss.notranslate){
	        		echo('class="notranslate"');
	        	}
	        	echo(' ');
	        	if(isSelected){
	    			echo('selected="selected"');
	    		}
	    		echo('>#v2#</option>'); 
			}
			noData = false;
		}
		if(noData){
			throw("zSelectBox: ss.listLabels or (ss.query and ss.queryValueField) are required.");
		} 
		echo('</select>');
	} 
	if(ss.output){
		writeoutput(selectBox);
	}
	return selectBox;
	</cfscript>
</cffunction>


<cffunction name="zInput_SSN" localmode="modern" output="false" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="formName" type="string" required="yes">
	<cfscript>
	var output="";
	var ssn1='';
	var ssn2='';
	var ssn3=''; 
	if(structkeyexists(form, fieldName)){
		ssn1=left(form[arguments.fieldName],3);
		ssn2=mid(form[arguments.fieldName],3,2);
		ssn3=right(form[arguments.fieldName],4);
	}
	if(structkeyexists(form, arguments.fieldName&'_ssn1')){
		ssn1=form[arguments.fieldName&'_ssn1'];
	}
	if(structkeyexists(form, arguments.fieldName&'_ssn2')){
		ssn2=form[arguments.fieldName&'_ssn2'];
	}
	if(structkeyexists(form, arguments.fieldName&'_ssn3')){
		ssn3=form[arguments.fieldName&'_ssn3'];
	}
	</cfscript>
	<cfsavecontent variable="output">
	<script type="text/javascript">
	/* <![CDATA[ */
	function #fieldName#_checkSSN(fieldNum){
		if(fieldNum==1){
			if(document.#arguments.formName#.#fieldName#_ssn1.value.length==3){
				document.#arguments.formName#.#fieldName#_ssn2.focus();
			}
		}else if(fieldNum==2){
			if(document.#arguments.formName#.#fieldName#_ssn2.value.length==2){
				document.#arguments.formName#.#fieldName#_ssn3.focus();
			}
		}
	}
	/* ]]> */
	</script>
	<input type="text" name="#fieldName#_ssn1" id="#fieldName#_ssn1" value="#htmleditformat(ssn1)#" size="3" maxlength="3" onkeyup="#fieldName#_checkSSN(1);" />-<input type="text" name="#fieldName#_ssn2" id="#fieldName#_ssn2" value="#htmleditformat(ssn2)#" onkeyup="#fieldName#_checkSSN(2);" size="2" maxlength="2"/>-<input type="text" name="#fieldName#_ssn3" id="#fieldName#_ssn3" value="#htmleditformat(ssn3)#" onkeyup="#fieldName#_checkSSN(2);" size="4" maxlength="4" />
	</cfsavecontent>
	<cfreturn output>
</cffunction>

<cffunction name="zInputImage" localmode="modern" returntype="any" output="false">
	<cfargument name="field" type="string" required="yes">
	<cfargument name="abspath" type="string" required="yes">
	<cfargument name="path" type="string" required="yes">
	<cfargument name="maxwidth" type="numeric" required="no" default="#0#">
	<cfargument name="allowDelete" type="boolean" required="no" default="#true#">
	<cfscript>
	var output='';
	var currentWidth='';
	var currentHeight='';
	var tempImage="";
	var tempText=""; 
	</cfscript>
	<cfsavecontent variable="tempText">
	<cfif structkeyexists(form, arguments.field) and form[arguments.field] NEQ '' and fileexists(arguments.abspath&form[arguments.field])>
        <img src="#arguments.path##form[arguments.field]#" alt="Uploaded Image" <cfif arguments.maxwidth NEQ 0>style="max-width:#arguments.maxWidth#px;"</cfif> /><br />
		<cfif arguments.allowDelete>
			<input type="checkbox" name="#arguments.field#_delete" id="#arguments.field#_delete" value="1" style="background:none; border:none;height:15px; " /> <label for="#arguments.field#_delete">Check to delete image and then submit form.</label><br />
		</cfif>
	</cfif>	
	<input type="file" name="#arguments.field#" style="width:95%;" />	
	</cfsavecontent>
	<cfscript>
	return tempText;
	</cfscript>
</cffunction>



<!--- application.zcore.functions.zInput_Boolean(fieldName, value, emptyStringIsNo); --->
<cffunction name="zInput_Boolean" localmode="modern" returntype="any" output="false">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="value" type="string" required="no" default="">
	<cfargument name="emptyStringIsNo" type="boolean" required="no" default="#true#">
	<cfscript>
	var yes = '<input name="#arguments.fieldName#" class="zBooleanRadio" id="#arguments.fieldName#1" style="border:none; background:none;" type="radio" value="1"';
	var no = '<input name="#arguments.fieldName#" class="zBooleanRadio" id="#arguments.fieldName#0" style="border:none; background:none;" type="radio" value="0"'; 
	v="";
	if(arguments.value NEQ ""){
		v=arguments.value;
	}else if(structkeyexists(form, arguments.fieldName)){
		v=form[arguments.fieldName];
	}
	if(v EQ 1){
		yes&=' checked';
	}
	if(v EQ 0){
		no&=' checked';
	}
	if(arguments.emptyStringIsNo and v EQ ""){
		no&=' checked';
	}
	yes=yes&' /> <label for="#arguments.fieldName#1">Yes</label> ';
	no=no&' /> <label for="#arguments.fieldName#0">No</label> ';
	return yes&no;
	</cfscript>
</cffunction>



<!--- 
<cfscript>
inputStruct = StructNew();
inputStruct.name = "field_name";
inputStruct.formName = "form1";
inputStruct.style_outer_table = "table-highlight";
inputStruct.style_inner_table = "small";
inputStruct.style_input = "";
inputStruct.readOnly = false;
writeoutput(application.zcore.functions.zInput_Chmod(inputStruct));
</cfscript>
 --->
<cffunction name="zInput_Chmod" localmode="modern" returntype="any" output="false">
	<cfargument name="inputStruct" type="struct" required="yes">
	<cfscript>
	var js = "";
	var output = "";
	var ss = arguments.inputStruct;
	var tempStruct = StructNew(); 
	tempStruct.readOnly = false;
	tempStruct.style_outer_table = "table-highlight";
	tempStruct.style_inner_table = "table-highlight tiny";
	tempStruct.style_input = "";
	StructAppend(arguments.ss, tempStruct,false);
	</cfscript>
	<cfif structkeyexists(arguments.ss, 'name') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zInput_Chmod: inputStruct.name is required.">
	</cfif>
	<cfif structkeyexists(arguments.ss, 'formName') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zInput_Chmod: inputStruct.name is required.">
	</cfif>
	<cfif arguments.ss.readOnly and structkeyexists(arguments.ss, 'accessStruct') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zInput_Chmod: inputStruct.accessStruct is required when inputStruct.readOnly EQ true.">
	</cfif>
	
	<cfif arguments.ss.readOnly EQ false>
	<cfsavecontent variable="js">	
<script type="text/javascript">
/* <![CDATA[ */
function #arguments.ss.name#_updateChMod(){
	var chmod=0;
	var f = document.#arguments.ss.formName#;
	if(f.#arguments.ss.name#_owner_read.checked)chmod+=400;
	if(f.#arguments.ss.name#_owner_write.checked)chmod+=200;
	if(f.#arguments.ss.name#_owner_delete.checked)chmod+=100;
	if(f.#arguments.ss.name#_group_read.checked)chmod+=40;
	if(f.#arguments.ss.name#_group_write.checked)chmod+=20;
	if(f.#arguments.ss.name#_group_delete.checked)chmod+=10;
	if(f.#arguments.ss.name#_public_read.checked)chmod+=4;
	if(f.#arguments.ss.name#_public_write.checked)chmod+=2;
	if(f.#arguments.ss.name#_public_delete.checked)chmod+=1;
	f.#arguments.ss.name#.value = chmod;
}
function #arguments.ss.name#_updateChecks(){
	var f = document.#arguments.ss.formName#;
	var ch = f.#arguments.ss.name#.value;
	var owner = 0;
	var group = 0;
	var public = 0;
	if(ch.length == 3){
		var owner = parseInt(ch.substr(0,1));
		var group = parseInt(ch.substr(1,1));
		var public = parseInt(ch.substr(2,1));
	}
	if(ch.length == 2){
		var group = parseInt(ch.substr(0,1));
		var public = parseInt(ch.substr(1,1));	
	}
	if(ch.length == 1){
		var public = parseInt(ch.substr(0,1));	
	}
	switch(owner){
		case 1: f.#arguments.ss.name#_owner_read.checked = false;
				f.#arguments.ss.name#_owner_write.checked = false;
				f.#arguments.ss.name#_owner_delete.checked = true;
				break;
		case 2: f.#arguments.ss.name#_owner_read.checked = false;
				f.#arguments.ss.name#_owner_write.checked = true;
				f.#arguments.ss.name#_owner_delete.checked = false;
				break;
		case 3: f.#arguments.ss.name#_owner_read.checked = false;
				f.#arguments.ss.name#_owner_write.checked = true;
				f.#arguments.ss.name#_owner_delete.checked = true;
				break;
		case 4: f.#arguments.ss.name#_owner_read.checked = true;
				f.#arguments.ss.name#_owner_write.checked = false;
				f.#arguments.ss.name#_owner_delete.checked = false;
				break;
		case 5: f.#arguments.ss.name#_owner_read.checked = true;
				f.#arguments.ss.name#_owner_write.checked = false;
				f.#arguments.ss.name#_owner_delete.checked = true;
				break;
		case 6: f.#arguments.ss.name#_owner_read.checked = true;
				f.#arguments.ss.name#_owner_write.checked = true;
				f.#arguments.ss.name#_owner_delete.checked = false;
				break;
		case 7: f.#arguments.ss.name#_owner_read.checked = true;
				f.#arguments.ss.name#_owner_write.checked = true;
				f.#arguments.ss.name#_owner_delete.checked = true;
				break;
		default: f.#arguments.ss.name#_owner_read.checked = false;
				f.#arguments.ss.name#_owner_write.checked = false;
				f.#arguments.ss.name#_owner_delete.checked = false;
				break;
	}
	switch(group){
		case 1: f.#arguments.ss.name#_group_read.checked = false;
				f.#arguments.ss.name#_group_write.checked = false;
				f.#arguments.ss.name#_group_delete.checked = true;
				break;
		case 2: f.#arguments.ss.name#_group_read.checked = false;
				f.#arguments.ss.name#_group_write.checked = true;
				f.#arguments.ss.name#_group_delete.checked = false;
				break;
		case 3: f.#arguments.ss.name#_group_read.checked = false;
				f.#arguments.ss.name#_group_write.checked = true;
				f.#arguments.ss.name#_group_delete.checked = true;
				break;
		case 4: f.#arguments.ss.name#_group_read.checked = true;
				f.#arguments.ss.name#_group_write.checked = false;
				f.#arguments.ss.name#_group_delete.checked = false;
				break;
		case 5: f.#arguments.ss.name#_group_read.checked = true;
				f.#arguments.ss.name#_group_write.checked = false;
				f.#arguments.ss.name#_group_delete.checked = true;
				break;
		case 6: f.#arguments.ss.name#_group_read.checked = true;
				f.#arguments.ss.name#_group_write.checked = true;
				f.#arguments.ss.name#_group_delete.checked = false;
				break;
		case 7: f.#arguments.ss.name#_group_read.checked = true;
				f.#arguments.ss.name#_group_write.checked = true;
				f.#arguments.ss.name#_group_delete.checked = true;
				break;
		default: f.#arguments.ss.name#_group_read.checked = false;
				f.#arguments.ss.name#_group_write.checked = false;
				f.#arguments.ss.name#_group_delete.checked = false;
				break;
	}
	switch(public){
		case 1: f.#arguments.ss.name#_public_read.checked = false;
				f.#arguments.ss.name#_public_write.checked = false;
				f.#arguments.ss.name#_public_delete.checked = true;
				break;
		case 2: f.#arguments.ss.name#_public_read.checked = false;
				f.#arguments.ss.name#_public_write.checked = true;
				f.#arguments.ss.name#_public_delete.checked = false;
				break;
		case 3: f.#arguments.ss.name#_public_read.checked = false;
				f.#arguments.ss.name#_public_write.checked = true;
				f.#arguments.ss.name#_public_delete.checked = true;
				break;
		case 4: f.#arguments.ss.name#_public_read.checked = true;
				f.#arguments.ss.name#_public_write.checked = false;
				f.#arguments.ss.name#_public_delete.checked = false;
				break;
		case 5: f.#arguments.ss.name#_public_read.checked = true;
				f.#arguments.ss.name#_public_write.checked = false;
				f.#arguments.ss.name#_public_delete.checked = true;
				break;
		case 6: f.#arguments.ss.name#_public_read.checked = true;
				f.#arguments.ss.name#_public_write.checked = true;
				f.#arguments.ss.name#_public_delete.checked = false;
				break;
		case 7: f.#arguments.ss.name#_public_read.checked = true;
				f.#arguments.ss.name#_public_write.checked = true;
				f.#arguments.ss.name#_public_delete.checked = true;
				break;
		default: f.#arguments.ss.name#_public_read.checked = false;
				f.#arguments.ss.name#_public_write.checked = false;
				f.#arguments.ss.name#_public_delete.checked = false;
				break;
	}
}
/* ]]> */
</script>
	</cfsavecontent>
	</cfif>
  <cfsavecontent variable="output">
<table class="#arguments.ss.style_outer_table#">
<tr class="#arguments.ss.style_outer_table#">
<td colspan="3"><table style="border-spacing:2px;width:100%;" class="#arguments.ss.style_outer_table#">
<tr  class="#arguments.ss.style_outer_table#">
<td>Permissions: 
	<cfif arguments.ss.readOnly>
		<cfif structkeyexists(form, arguments.ss.name)>#form[arguments.ss.name]#</cfif>
	<cfelse>
		<input class="#arguments.ss.style_input#" type="text" name="#arguments.ss.name#" id="#arguments.ss.name#" value="<cfif structkeyexists(form, arguments.ss.name)>#form[arguments.ss.name]#</cfif>" onkeyup="#arguments.ss.name#_updateChecks();" size="3" maxlength="3" />
	</cfif></td>
</tr>
</table>

</td></tr>
<tr class="#arguments.ss.style_inner_table#"><td>
<table style="border-spacing:2px;" class="#arguments.ss.style_inner_table#">
<tr  class="#arguments.ss.style_inner_table#">
<td>Owner</td>
</tr>
<tr  class="#arguments.ss.style_inner_table#">
<td>
<cfif arguments.ss.readOnly>
	<cfif arguments.ss.accessStruct.access_owner_read>Read</cfif>&nbsp;
<cfelse>
<input class="#arguments.ss.style_input#" type="checkbox" name="#arguments.ss.name#_owner_read" id="#arguments.ss.name#_owner_read" value="1" onclick="#arguments.ss.name#_updateChMod();" /> Read
</cfif>
</td>
</tr>
<tr  class="#arguments.ss.style_inner_table#">
<td>
<cfif arguments.ss.readOnly>
	<cfif arguments.ss.accessStruct.access_owner_write>Write</cfif>&nbsp;
<cfelse>
<input class="#arguments.ss.style_input#" type="checkbox" name="#arguments.ss.name#_owner_write" id="#arguments.ss.name#_owner_write" value="1" onclick="#arguments.ss.name#_updateChMod();" /> Write
</cfif>
</td>
</tr>
<tr  class="#arguments.ss.style_inner_table#">
<td>
<cfif arguments.ss.readOnly>
	<cfif arguments.ss.accessStruct.access_owner_delete>Delete</cfif>&nbsp;
<cfelse>
<input class="#arguments.ss.style_input#" type="checkbox" name="#arguments.ss.name#_owner_delete" id="#arguments.ss.name#_owner_delete" value="1" onclick="#arguments.ss.name#_updateChMod();" /> Delete
</cfif>
</td>
</tr>
</table>

</td>
<td>

<table style="border-spacing:2px;" class="#arguments.ss.style_inner_table#">
<tr  class="#arguments.ss.style_inner_table#">
<td>Group</td>
</tr>
<tr  class="#arguments.ss.style_inner_table#">
<td>
<cfif arguments.ss.readOnly>
	<cfif arguments.ss.accessStruct.access_group_read>Read</cfif>&nbsp;
<cfelse>
<input class="#arguments.ss.style_input#" type="checkbox" name="#arguments.ss.name#_group_read" id="#arguments.ss.name#_group_read" value="1" onclick="#arguments.ss.name#_updateChMod();" /> Read
</cfif>
</td>
</tr>
<tr  class="#arguments.ss.style_inner_table#">
<td>
<cfif arguments.ss.readOnly>
	<cfif arguments.ss.accessStruct.access_group_write>Write</cfif>&nbsp;
<cfelse>
<input class="#arguments.ss.style_input#" type="checkbox" name="#arguments.ss.name#_group_write" id="#arguments.ss.name#_group_write" value="1" onclick="#arguments.ss.name#_updateChMod();" /> Write
</cfif>
</td>
</tr>
<tr  class="#arguments.ss.style_inner_table#">
<td>
<cfif arguments.ss.readOnly>
	<cfif arguments.ss.accessStruct.access_group_delete>Delete</cfif>&nbsp;
<cfelse>
<input class="#arguments.ss.style_input#" type="checkbox" name="#arguments.ss.name#_group_delete" id="#arguments.ss.name#_group_delete" value="1" onclick="#arguments.ss.name#_updateChMod();"> Delete
</cfif>
</td>
</tr>
</table>

</td>
<td>


<table style="border-spacing:2px;" class="#arguments.ss.style_inner_table#">
<tr  class="#arguments.ss.style_inner_table#">
<td>Public</td>
</tr>
<tr  class="#arguments.ss.style_inner_table#">
<td>
<cfif arguments.ss.readOnly>
	<cfif arguments.ss.accessStruct.access_public_read>Read</cfif>&nbsp;
<cfelse>
<input class="#arguments.ss.style_input#" type="checkbox" name="#arguments.ss.name#_public_read" id="#arguments.ss.name#_public_read" value="1" onclick="#arguments.ss.name#_updateChMod();" /> Read
</cfif>
</td>
</tr>
<tr  class="#arguments.ss.style_inner_table#">
<td>
<cfif arguments.ss.readOnly>
	<cfif arguments.ss.accessStruct.access_public_write>Write</cfif>&nbsp;
<cfelse>
<input class="#arguments.ss.style_input#" type="checkbox" name="#arguments.ss.name#_public_write" id="#arguments.ss.name#_public_write" value="1" onclick="#arguments.ss.name#_updateChMod();" /> Write
</cfif>
</td>
</tr>
<tr  class="#arguments.ss.style_inner_table#">
<td>
<cfif arguments.ss.readOnly>
	<cfif arguments.ss.accessStruct.access_public_delete>Delete</cfif>&nbsp;
<cfelse>
<input class="#arguments.ss.style_input#" type="checkbox" name="#arguments.ss.name#_public_delete" id="#arguments.ss.name#_public_delete" value="1" onclick="#arguments.ss.name#_updateChMod();" /> Delete
</cfif>
</td>
</tr>
</table>
</td>
</tr>
</table>
<cfif arguments.ss.readOnly EQ false>
<script type="text/javascript">
/* <![CDATA[ */
#arguments.ss.name#_updateChecks();
/* ]]> */
</script>
</cfif>
	</cfsavecontent>
	
	<cfscript>
	if(arguments.ss.readOnly EQ false){
		application.zcore.template.prependContent(js);
	}
	return output;
	</cfscript>
</cffunction>




<!--- 
<cfscript>
ts = StructNew();
ts.name = "field_name";
ts.friendlyName="";
ts.labelList = "Yes|No";
ts.valueList = "Yes|No";
ts.delimiter="|";
ts.defaultValue = "";
ts.style = "";
ts.className = "";
ts.required=false;
ts.statusbar = "";
ts.onclick="";
ts.output=true;
ts.struct=form;
writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
</cfscript>
 --->
<cffunction name="zInput_RadioGroup" localmode="modern" returntype="any" output="true">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var ts = StructNew();
	var label = "";
	var i = "";
	var output = '';
	var selected = ""; 
	ts.friendlyName="";
	ts.labelList = "";
	ts.style = "";
	ts.defaultValue = "";
	ts.className = "";
	ts.statusbar = "";
	ts.delimiter=",";
	ts.onclick="";
	ts.output=true;
	ts.struct=form;
	ts.required=false;
	StructAppend(arguments.ss, ts, false);
	if(not structkeyexists(arguments.ss, 'name')){
		throw("Error: FUNCTION: zInput_RadioGroup: arguments.ss.name is required.");
	}
	if(not structkeyexists(arguments.ss, 'valueList')){
		throw("Error: FUNCTION: zInput_RadioGroup: arguments.ss.valueList is required.");
	}
	if(len(arguments.ss.labelList) NEQ 0 and listLen(arguments.ss.labelList, arguments.ss.delimiter, true) NEQ listLen(arguments.ss.valueList, arguments.ss.delimiter, true)){
		throw("Error: FUNCTION: zInput_RadioGroup: arguments.ss.valueList list length is not the same as arguments.ss.labelList.");
	}
	if(len(arguments.ss.statusbar) NEQ 0 and listLen(arguments.ss.statusbar, arguments.ss.delimiter, true) NEQ listLen(arguments.ss.valueList, arguments.ss.delimiter, true)){
		throw("Error: FUNCTION: zInput_RadioGroup: arguments.ss.valueList list length is not the same as arguments.ss.statusbar.");
	}
	if(len(arguments.ss.delimiter) NEQ 1){
		throw("arguments.ss.delimiter, #arguments.ss.delimiter#, must be exactly one character");
	}
	if(structkeyexists(arguments.ss.struct, arguments.ss.name)){
		selected = arguments.ss.struct[arguments.ss.name]; 
	}else{
		selected = arguments.ss.defaultValue;
	}
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onclick&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="radio";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	label = "";
	for(i=1;i LTE listlen(arguments.ss.valueList, arguments.ss.delimiter, true);i=i+1){
		if(len(arguments.ss.labelList) NEQ 0){
			label = listGetAt(arguments.ss.labelList, i, arguments.ss.delimiter, true);			
		}
		output = output&'<span class="zRadioGroupOptionSpan"><input ';
		if(len(arguments.ss.statusbar) NEQ 0){
			output = output&'onmouseover="window.status = ''#listGetAt(arguments.ss.statusbar,i, arguments.ss.delimiter, true)#'';" onmouseout="window.status = '''';" title="#listGetAt(arguments.ss.statusbar,i, true)#" ';
		}
		output = output&' type="radio" name="#arguments.ss.name#" id="#arguments.ss.name#_#i#" value="#htmleditformat(listGetAt(arguments.ss.valueList,i, arguments.ss.delimiter, true))#"';
		if(arguments.ss.required){	
			output&=" required ";
		}
		if(arguments.ss.style NEQ ''){
			output = output&' style="#arguments.ss.style#"';
		}
		output = output&' class="zRadioButton ';
		if(arguments.ss.className NEQ ''){
			output&=arguments.ss.className;
		}
		output&='"';
		if(arguments.ss.onclick NEQ ""){
			output&=' onclick="#arguments.ss.onclick#"';
		}
		if(selected EQ listGetAt(arguments.ss.valueList,i, arguments.ss.delimiter, true)){
			output = output&' checked="checked" /> ';
		}else{
			output = output&' /> ';
		}
		output = output&'<label for="#arguments.ss.name#_#i#" style="cursor:pointer;">'&label&"</label></span> ";
	}
	if(arguments.ss.style NEQ ''){
		output = output&'</span>';
	}
	if(arguments.ss.output){
		writeoutput(output);
	}else{
		return output;
	}
	</cfscript>
	
</cffunction>


<!--- 
<cfscript>
ts = StructNew();
ts.name = "field_name";
ts.friendlyName="";
// options for query data
ts.query = qQuery;
ts.queryLabelField = "table_label";
ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
ts.queryParseStatusVars = false;
ts.queryValueField = "table_value";
// options for list data
ts.listLabels = "value1|value2|value3";
ts.listValues = "1|2|3";
ts.listLabelsDelimiter = "|"; // tab delimiter
ts.listValuesDelimiter = "|";
ts.listStatusDelimiter = "|";
ts.defaultValue = "";
ts.style = "";
ts.separate=" ";
ts.className = "";
ts.required=false;
ts.onclick="";
ts.onchange="";
writeoutput(application.zcore.functions.zInput_Checkbox(ts));
</cfscript>
 --->
<cffunction name="zInput_Checkbox" localmode="modern" returntype="any" output="true">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var arrSelected2='';
	var arrV2='';
	var curChecked='';
	var ts = StructNew();
	var rs = StructNew();
	var arrV=arraynew(1);
	var arrL=0;
	var arrS=0;
	var i = "";
	var i2=0;
	var n=0;
	var curSt=0;
	var curV=0;
	var curL=0;
	var arrLOut=arraynew(1);
	var ex="";
	var output = '';
	var arrSelected=[];
	var zExpOptionValue=0;
	var selected = "";
	local.tempRS=application.zcore.functions.zFormJSNewZValue(1);
	zExpOptionValue=local.tempRS.zValue; 
	ts.friendlyName="";
	ts.radio=false;
	ts.labelList = "";// options for query data
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryParseStatusVars = false;
	ts.listSelectedDelimiter=",";
	ts.listLabelsDelimiter = chr(9); // tab delimiter
	ts.listValuesDelimiter = chr(9);
	ts.listStatusDelimiter = chr(9);
	ts.disableExpOptionValue=false;
	ts.style = "";
	ts.separator="<br />";
	ts.defaultValue = "";
	ts.className = "";
	ts.output=true;
	ts.onchange="";
	ts.onclick="";
	ts.required=false;
	StructAppend(arguments.ss, ts, false);
	</cfscript>
	<cfif isDefined('arguments.ss.name') EQ false>
		<cfthrow type="exception" message="Error: FUNCTION: zInput_Checkbox: arguments.ss.name is required.">
	</cfif>
	<cfscript>
	if(structkeyexists(form, arguments.ss.name)){
		selected = form[arguments.ss.name];
	}else{
		selected = arguments.ss.defaultValue;
	}
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onclick&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[*/');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="text";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	if(structkeyexists(arguments.ss,'listValues')){
		arrV=listtoarray(arguments.ss.listValues, arguments.ss.listValuesDelimiter,true);
		if(structkeyexists(arguments.ss,'listLabels')){
			arrL=listtoarray(arguments.ss.listLabels, arguments.ss.listLabelsDelimiter,true);
		}else{
			arrL=arrV;
		}
		if(structkeyexists(arguments.ss,'listStatus')){
			arrS=listtoarray(arguments.ss.listStatus, arguments.ss.listStatusDelimiter,true);
		}
	}
	if(arguments.ss.disableExpOptionValue){
		ex=-1;	
	}else{
		ex=zExpOptionValue;
	}
	arrSelected2=listtoarray(selected,arguments.ss.listSelectedDelimiter,true);
	arguments.ss.onclick="zCheckboxOnChange(this,#ex#);"&arguments.ss.onclick;
	</cfscript>
    <cfsavecontent variable="output">
    #local.tempRS.output#
    <cfif structkeyexists(arguments.ss,'listValues')>
    <cfloop from="1" to="#arraylen(arrV)#" index="i">
    <cfscript>
	curL=arrL[i];
	arrV2=listtoarray(arrV[i],arguments.ss.listSelectedDelimiter,true);
	curChecked=false;
	for(i2=1;i2 LTE arraylen(arrV2);i2++){
		for(n=1;n LTE arraylen(arrSelected2);n++){
			if(compare(arrV2[i2],arrSelected2[n]) EQ 0){
				curChecked=true;
				arrayappend(arrSelected, arrSelected2[n]);
			}
		}
	}
	</cfscript>
    <input 
    type="<cfif arguments.ss.radio>radio<cfelse>checkbox</cfif>" name="#arguments.ss.name#_name" id="#arguments.ss.name#_name#i#" 
    value="#htmleditformat(arrV[i])#"  style="border:none;background:none;<cfif arguments.ss.style NEQ ''>#arguments.ss.style#</cfif> " 
    <cfif arguments.ss.className NEQ ''>class="#arguments.ss.className#"</cfif> 
    <!--- <cfif arguments.ss.onclick NEQ ""> onclick="#arguments.ss.onclick#" </cfif>  --->
    <cfif curChecked><cfset arrayappend(arrLOut, curL)>checked="checked"</cfif> /> 
    	<label style="cursor:pointer;" for="#arguments.ss.name#_name#i#" id="#arguments.ss.name#_namelabel#i#">#htmleditformat(curL)#</label>
    	#arguments.ss.separator#
    	<cfif arguments.ss.onclick NEQ "">
	    	<script type="text/javascript">
	    	zArrDeferredFunctions.push(function(){
	    		$("###arguments.ss.name#_name#i#").bind("click", function(){ 
		    		#arguments.ss.onclick#
		    		$("###arguments.ss.name#").trigger("change");
		    	});
	    	});
	    	</script>
		</cfif>
    </cfloop>
    </cfif>
    
	<!--- query data --->
	<cfif structkeyexists(arguments.ss,'query') and structkeyexists(arguments.ss,'queryLabelField')>
		<cfloop query="arguments.ss.query">
			<cfscript>
            if(structkeyexists(arguments.ss,'queryValueField')){
                if(arguments.ss.queryParseValueVars){
                    curV=application.zcore.functions.zParseVariables(arguments.ss.queryValueField, false, arguments.ss.query);
                }else{
                    curV=arguments.ss.query[arguments.ss.queryValueField];
                }
            }else{
                curV=arguments.ss.query[arguments.ss.queryLabelField];
            }
            if(arguments.ss.queryParseLabelVars){
                curL=application.zcore.functions.zParseVariables(arguments.ss.queryLabelField, false, arguments.ss.query);
            }else{
                curL=arguments.ss.query[arguments.ss.queryLabelField];
            }
			curChecked=false;
			if(find(","&curV&",",","&selected&",") NEQ 0){
				curChecked=true;
				arrayappend(arrSelected, curV);
			}
            </cfscript>
		    <input 
		    type="<cfif arguments.ss.radio>radio<cfelse>checkbox</cfif>" name="#arguments.ss.name#_name" 
		    id="#arguments.ss.name#_name#arguments.ss.query.currentrow+arrayLen(arrV)#" value="#curV#"  
		    style="border:none;background:none;height:15px;<cfif arguments.ss.style NEQ ''>#arguments.ss.style#</cfif> " 
		    <cfif arguments.ss.className NEQ ''>class="#arguments.ss.className#"</cfif> 
		    <!--- <cfif arguments.ss.onclick NEQ ""> onclick="#arguments.ss.onclick#" </cfif>  --->
		    <cfif curChecked><cfset arrayappend(arrLOut, curL)>checked="checked"</cfif> /> 
		    <label style="cursor:pointer;" for="#arguments.ss.name#_name#arguments.ss.query.currentrow+arrayLen(arrV)#" 
		    id="#arguments.ss.name#_namelabel#arguments.ss.query.currentrow+arrayLen(arrV)#">#htmleditformat(curL)#</label>
		    #arguments.ss.separator#
	    	<cfif arguments.ss.onclick NEQ "">
		    	<script type="text/javascript">
		    	zArrDeferredFunctions.push(function(){
		    		$("###arguments.ss.name#_name#arguments.ss.query.currentrow+arrayLen(arrV)#").bind("click", function(){ 
		    			#arguments.ss.onclick# });
		    	});
		    	</script>
			</cfif>
		</cfloop>
        </cfif>
    <input type="hidden" name="#arguments.ss.name#" id="#arguments.ss.name#" onchange="#arguments.ss.onchange#" value="#htmleditformat(arraytolist(arrSelected, ','))#" />
        </cfsavecontent>
    <cfscript>
	if(arguments.ss.output){
		writeoutput(output);
	}else{
		rs.output=output;
		rs.zExpOptionValue=zExpOptionValue;
		rs.value="<br />"&arraytolist(arrLOut,"<br />");
		return rs;	
	}
	</cfscript>
	
</cffunction>



<!--- 
ts=StructNew();
// required
ts.name="formSubmit";
// optional
ts.useAnchorTag=false; // set to true to use <a> instead of <input> so we can do :hover css
ts.useAnchorTagFormName=""; // required if not using zForm system and using useAnchorTag=true. Form name is needed so that the submit() function can be called onclick()
ts.friendlyName="";
ts.style="";
ts.onclick="";
ts.className="";
zInput_submit(ts);
 --->
<cffunction name="zInput_Submit" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=StructNew();
	var out='<input type="submit"'; 
	ts.name="";
	ts.imageInput=false;
	ts.imageUrl="";
	ts.value="Submit";
	ts.useAnchorTag=false;
	ts.useAnchorTagFormName="";
	ts.style="";
	ts.className="";
	ts.friendlyName="";
	ts.onclick="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.imageInput){
		out='<input type="image" src="#arguments.ss.imageUrl#"';
	}
	if(arguments.ss.useAnchorTag){
		if(application.zcore.functions.zso(request.zos, "zFormCurrentName") EQ "" and arguments.ss.useAnchorTagFormName EQ ""){
			application.zcore.template.fail("arguments.ss.useAnchorTagFormName is required if you're not using the zForm system and have set arguments.ss.useAnchorTag=true. Form name is needed so that the submit() function can be called in the onclick attribute.");	
		}
		out='<a href="##"';// #request.zos.zFormCurrentName#";
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		writeoutput('<script type="text/javascript">/* <![CDATA[ */ zArrDeferredFunctions.push(function(){zFormData["#request.zos.zFormCurrentName#"].submitContainer="#arguments.ss.name#_container";});/* ]]> */</script>');
    }
	if(arguments.ss.name EQ ""){
		application.zcore.template.fail("arguments.ss.name is required.");
	}
	out&=' name="#arguments.ss.name#" id="#arguments.ss.name#"';
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	if(arguments.ss.useAnchorTag){
		if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
			out&=' onclick="#arguments.ss.onclick#document.#request.zos.zFormCurrentName#.submit(); return false;"';
		}else{
			out&=' onclick="#arguments.ss.onclick#document.#arguments.ss.useAnchorTagFormName#.submit(); return false;"';
		}
	}else if(arguments.ss.onclick NEQ ""){
		out&=' onclick="#arguments.ss.onclick# return false;"';
	}
	if(arguments.ss.className NEQ ""){
		out&=' class="#arguments.ss.className#"';
	}
	if(arguments.ss.style NEQ ""){
		out&=' style="#arguments.ss.style#"';
	}
	if(arguments.ss.value NEQ ""){
		if(arguments.ss.useAnchorTag){
			out&='>#arguments.ss.value#</a>';
		}else if(arguments.ss.imageInput){
			out&=' />';
		}else{
			out&=' value="#htmleditformat(arguments.ss.value)#" />';
		}
	}
	writeoutput(out);
	</cfscript>
</cffunction>




<!--- 
ts=StructNew();
ts.label="";
ts.name="";
ts.style="";
ts.className="";
ts.multiline=false;
ts.size=20;
ts.maxlength=0;
ts.allowNull=false;
ts.email=false;
ts.required=false;
ts.number=false;
ts.output=true;
ts.onkeyup="";
ts.onchange="alert('neat');";
ts.defaultValue="";
zInput_Text(ts);
 --->
<cffunction name="zInput_Text" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var ts=StructNew();
	var labelStyles="";
	var out='<input type="text"'; 
	ts.label="";
	ts.name="";
	ts.friendlyName="";
	ts.style="";
	ts.labelStyle="";
	ts.labelClassName="";
	ts.size=20;
	ts.output=true;
	ts.maxlength=0;
	ts.defaultValue="";
	ts.multiline=false;
	ts.allowNull=false;
	ts.className="";
	ts.email=false;
	ts.required=false;
	ts.number=false;
	ts.onchange="";
	ts.onkeyup="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.labelClassName NEQ ""){
		labelStyles&=' class="#arguments.ss.labelClassName#"';
	}
	if(arguments.ss.labelStyle NEQ ""){
		labelStyles&=' style="#arguments.ss.labelStyle#"';
	}
	if(arguments.ss.label NEQ ""){
		out='<label for="#arguments.ss.name#" #labelStyles#>#arguments.ss.label#</label> '&out;
	}
	if(arguments.ss.multiline){
		out="<textarea";	
	}
	if(arguments.ss.name EQ ""){
		application.zcore.template.fail("arguments.ss.name is required.");
	}
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	out&=' name="#arguments.ss.name#" id="#arguments.ss.name#"';
	if(arguments.ss.size NEQ 0){
		out&=' size="#arguments.ss.size#"';
	}
	if(arguments.ss.maxlength NEQ 0){
		out&=' maxlength="#arguments.ss.maxlength#"';
	}
	if(arguments.ss.className NEQ ""){
		out&=' class="#arguments.ss.className#"';
	}
	if(arguments.ss.style NEQ ""){
		out&=' style="#arguments.ss.style#"';
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		ds.allowNull=arguments.ss.allowNull;
		ds.email=arguments.ss.email;
		ds.number=arguments.ss.number;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		local.tempJS="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arguments.ss.onkeyup&=local.tempJS;
		arguments.ss.onchange&=local.tempJS;
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[*/');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="text";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.allowNull=#arguments.ss.allowNull#;');
		writeoutput('ts.email=#arguments.ss.email#;');
		writeoutput('ts.number=#arguments.ss.number#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	if(arguments.ss.onchange NEQ ""){
		out&=' onchange="#arguments.ss.onchange#"';
	}
	if(arguments.ss.onkeyup NEQ ""){
		out&=' onkeyup="#arguments.ss.onkeyup#"';
	}
	if(arguments.ss.multiline){
		if(structkeyexists(form, arguments.ss.name)){
			out&='>#htmleditformat(form[arguments.ss.name])#</textarea';
		}else{
			out&='>#htmleditformat(arguments.ss.defaultValue)#</textarea';
		}
		out&=">";
	}else{
		if(structkeyexists(form, arguments.ss.name)){
			out&=' value="#htmleditformat(form[arguments.ss.name])#"';
		}else{
			out&=' value="#htmleditformat(arguments.ss.defaultValue)#"';
		}
		out&=" />";
	}
	if(arguments.ss.output){
		writeoutput(out);
	}else{
		return out;
	}
	</cfscript>
</cffunction>




<!--- 
ts=StructNew();
ts.name="";
ts.allowNull=false;
ts.email=false;
ts.required=false;
ts.number=false;
ts.onchange="alert('neat');";
ts.defaultValue="";
zInput_hidden(ts);
 --->
<cffunction name="zInput_hidden" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=StructNew();
	var ds=0;
	var labelStyles="";
	var out='<input type="hidden"'; 
	ts.name="";
	ts.friendlyName="";
	ts.defaultValue="";
	ts.allowNull=false;
	ts.email=false;
	ts.required=false;
	ts.number=false;
	ts.onchange="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.name EQ ""){
		application.zcore.template.fail("arguments.ss.name is required.");
	}
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	out&=' name="#arguments.ss.name#" id="#arguments.ss.name#"';
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		ds.allowNull=arguments.ss.allowNull;
		ds.email=arguments.ss.email;
		ds.number=arguments.ss.number;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onchange&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[  */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="hidden";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.allowNull=#arguments.ss.allowNull#;');
		writeoutput('ts.email=#arguments.ss.email#;');
		writeoutput('ts.number=#arguments.ss.number#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	if(arguments.ss.onchange NEQ ""){
		out&=' onchange="#arguments.ss.onchange#"';
	}
	if(structkeyexists(form, arguments.ss.name)){
		out&=' value="#htmleditformat(form[arguments.ss.name])#"';
	}else{
		out&=' value="#htmleditformat(arguments.ss.defaultValue)#"';
	}
	out&=" />";
	writeoutput(out);
	</cfscript>
</cffunction>








<!--- 
ts=StructNew();
ts.name="";
ts.style="";
ts.className="";
ts.size=20;
ts.required=false;
ts.allowDelete=true;
ts.onchange="alert('neat');";
ts.downloadPath="/zupload/event/";
zInput_file(ts); --->
<cffunction name="zInput_file" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var value=0;
	var ts=StructNew();
	var out='<input type="file"'; 
	ts.name="";
	ts.friendlyName="";
	ts.style="";
	ts.className="";
	ts.size=20;
	ts.required=false;
	ts.allowDelete=true;
	ts.number=false;
	ts.onchange="";
	ts.onkeyup="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.name EQ ""){
		application.zcore.template.fail("arguments.ss.name is required.");
	}
    if(structkeyexists(form, arguments.ss.name)){
    	value= form[arguments.ss.name];
    }else{
        value="";
    }
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	out&=' name="#arguments.ss.name#" id="#arguments.ss.name#"';
	if(arguments.ss.size NEQ 0){
		out&=' size="#arguments.ss.size#"';
	}
	if(arguments.ss.className NEQ ""){
		out&=' class="#arguments.ss.className#"';
	} 
	if(arguments.ss.required){	
		out&=" required ";
	}
	
	out&=' style=" width:95%; ';
	if(arguments.ss.style NEQ ""){
		out&=' #arguments.ss.style# ';
	}
	out&='"';
	
	if(value NEQ ""){
		if(structkeyexists(arguments.ss, 'downloadPath')){
			echo('<p><a href="/z/misc/download/index?fp=#arguments.ss.downloadPath##value#" target="_blank">Download File</a></p>');
		}
		if(arguments.ss.allowDelete){
			echo('<p><input name="#arguments.ss.name#_delete" id="#arguments.ss.name#_delete" style="border:none; background:none; height:15px;" type="checkbox" value="true"> <label for="#arguments.ss.name#_delete">Check to delete and then submit form</label></p>');
		}
	}
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		writeoutput('<script type="text/javascript">/* <![CDATA[ */
		zFormData["#request.zos.zFormCurrentName#"].contentType="multipart/form-data";zFormData["#request.zos.zFormCurrentName#"].method="post";document.#request.zos.zFormCurrentName#.enctype="multipart/form-data";document.#request.zos.zFormCurrentName#.method="post";
		/* ]]> */</script>');
    }
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		local.tempJS="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arguments.ss.onkeyup&=local.tempJS;
		arguments.ss.onchange&=local.tempJS;
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="file";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	if(arguments.ss.onchange NEQ ""){
		out&=' onchange="#arguments.ss.onchange#"';
	}
	out&=" />";
	writeoutput(out);
	</cfscript>
</cffunction>

<!---
	ts = StructNew();
	ts.groupLabel = "group name";
	ts.name = "name";
	ts.type="checkbox";
	ts.menuSize=10;
	ts.colspan=3;
	ts.enumerate = 1; // for editing multiple records
	ts.output = true; // set to false to save to variable
	ts.style = "normal"; // stylesheet class
	ts.checkedValues = "value1"; // send list if there are multiple values.
	ts.checkedDelimiter = ","; // change if comma conflicts...
	ts.onChange = "zFunction();";
	ts.defaultValue = "value1";
	ts.dollarFormatLabels = true;
	// options for query data
	ts.query = qQuery;
	ts.queryLabelField = "table_label";
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryValueField = "table_value";
	// options for list data
	ts.listLabels = "value1,value2,value3";
	ts.listValues = "1,2,3";
	ts.listLabelsDelimiter = chr(9); // tab delimiter
	ts.listValuesDelimiter = chr(9);
	
	zInputExpandingBox(ts);
 --->
<cffunction name="zInputExpandingBox" localmode="modern" returntype="any" output="true">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var tempStruct=0;
	var checkedValues = "";
	var selectBox = "";
	var noData = true;
	var i = 0;
	var leftLabel="";
	var myColumnOutput="";
	var rightLabel="";
	var arrBox=arraynew(1);
	var arrMenuBox=arraynew(1);
	var count=0;
	var currentBox=0;
	var boxCount=0;
	var template="";
	var arrChecked = 0;
	var label = 0;
	var checked = 0;
	var value = 0;
	var n = 0;
	var box = 0;
	var inputStruct = 0;
	
	// set defaults
	var tempStruct = StructNew(); 
	tempStruct.name="";
	tempStruct.friendlyName="";
	tempStruct.required=false;
	tempStruct.onchange="";
	tempStruct.enumerate = "";
	tempStruct.type="checkbox";
	tempStruct.groupLabel = "";
	tempStruct.output = true;
	tempStruct.colspan=3;
	tempStruct.className="";
	tempStruct.menuSize=0;
	tempStruct.labelSide="right";
	tempStruct.queryParseLabelVars = false;
	tempStruct.queryParseValueVars = false;
	tempStruct.listLabelsDelimiter = ","; // tab delimiter
	tempStruct.listValuesDelimiter = ",";
	tempStruct.checkedDelimiter=",";
	tempStruct.dollarFormatLabels = false;
	// override defaults
	StructAppend(arguments.ss, tempStruct, false);
	if(arguments.ss.groupLabel NEQ ""){
		arguments.ss.groupLabel&="<br />";
	}
	arguments.ss.menuSize=max(0,min(arguments.ss.menuSize,10000));
	if(arguments.ss.name EQ ''){
		application.zcore.template.fail("arguments.ss.name is required");
	}
	if(arguments.ss.friendlyName EQ ""){
		arguments.ss.friendlyName=application.zcore.functions.zFriendlyName(arguments.ss.name);
	}
	</cfscript>
	<cfsavecontent variable="selectBox">
        <cfif isDefined('request.zos.zInputExpandingBoxScript') EQ false>
            <cfset request.zos.zInputExpandingBoxScript=true>
            <cfset request.zInputExpandingBoxCount=0> 
        </cfif>
        	<script type="text/javascript">/* <![CDATA[ */
			zExpArrMenuBox.push("#arguments.ss.name#");
			/* ]]> */
			</script>
	
	<cfscript>
	if(structkeyexists(arguments.ss, 'checkedValues') and arguments.ss.checkedValues NEQ ""){
		checkedValues = arguments.ss.checkedValues;
	}else if(structkeyexists(form, arguments.ss.name)){
		checkedValues = form[arguments.ss.name];
	}else if(structkeyexists(arguments.ss, 'defaultValue')){
		checkedValues = arguments.ss.defaultValue;
	}else{
		checkedValues = "";
	}
	if(arguments.ss.type EQ "radio"){
		// force only one selected value
		if(checkedValues NEQ ""){
			checkedValues=listGetAt(checkedValues,listLen(checkedValues,arguments.ss.checkedDelimiter, true),arguments.ss.checkedDelimiter, true);
		}
	}
	
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onchange&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ 1 */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="zExpandingBox";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	arrChecked=arraynew(1);
	
	if(arguments.ss.labelSide EQ "right"){
		rightLabel=" $w";
		leftLabel="";
	}else{
		rightLabel="";
		leftLabel="$w ";
	}
	template='<a href="##" onclick="zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,$y,''#arguments.ss.type#'',0,$z); return false;" id="zExpMenuOptionLink#request.zInputExpandingBoxCount#_$y$z2" class="zExpMenuOption">#leftLabel#<input type="radio" class="zExpMenuInput" onclick="zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,$y,''#arguments.ss.type#'',1,$z);" onchange="#arguments.ss.onChange#" name="#arguments.ss.name##arguments.ss.enumerate#$z2" id="zExpMenuOption#request.zInputExpandingBoxCount#_$y$z2" value="$v" />#rightLabel#</a><br />';
	</cfscript>
	
	<!--- list data --->	
	<cfif structkeyexists(arguments.ss, 'listValues')>
    	<cfset count=listLen(arguments.ss.listValues,arguments.ss.listValuesDelimiter, true)>
		<cfloop index="i" from="1" to="#count#">
            <cfscript>
			value=listGetAt(arguments.ss.listValues, i, arguments.ss.listValuesDelimiter, true);
			if(isDefined('checkedValues') and checkedValues NEQ "" and listFind(checkedValues, value, arguments.ss.checkedDelimiter) NEQ 0){
				checked='checked="checked"';
				arrayappend(arrChecked, currentBox);
			}else{
				checked='';
			}
			if(structkeyexists(arguments.ss, 'listLabels')){
				label=listGetAt(arguments.ss.listLabels, i, arguments.ss.listLabelsDelimiter, true);
				if(arguments.ss.dollarFormatLabels and isNumeric(label)){
					label="$#NumberFormat(label)#";
				}
			}else{
				if(arguments.ss.dollarFormatLabels and isNumeric(value)){
					label="$#NumberFormat(value)#";
				}else{
					label=value;
				}
			}
			if(arguments.ss.labelSide EQ "right"){
				rightLabel=label;
				leftLabel="";
			}else{
				rightLabel="";
				leftLabel=label;
			}
			if(currentBox LT arguments.ss.menuSize){
				boxCount=2;
				if(checked NEQ ""){
					arrayappend(arrChecked, currentBox&"_2");	
				}
			}else{
				boxCount=1;
			}
			</cfscript>
            <cfloop from="1" to="#boxCount#" index="n">
            <cfsavecontent variable="box">
        	<a href="##" onclick="zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,#currentBox#,'#arguments.ss.type#',0<cfif boxCount EQ 2 and n EQ 1>,1<cfelse>,0</cfif>); return false;" id="zExpMenuOptionLink#request.zInputExpandingBoxCount#_#currentBox#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" class="zExpMenuOption<cfif checked NEQ "">Over</cfif>">#leftLabel# <input type="#arguments.ss.type#" class="zExpMenuInput" onclick="javascript:zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,#currentBox#,'#arguments.ss.type#',1<cfif boxCount EQ 2 and n EQ 1>,1<cfelse>,0</cfif>);" <cfif structkeyexists(arguments.ss, 'onChange')>onchange="#arguments.ss.onChange#"</cfif> <cfif structkeyexists(arguments.ss, 'style')>class="#arguments.ss.style#"</cfif> name="#arguments.ss.name##arguments.ss.enumerate#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" id="zExpMenuOption#request.zInputExpandingBoxCount#_#currentBox#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" value="#htmleditformat(value)#" #checked# /> #rightLabel#</a></cfsavecontent>
			<cfscript>if(boxCount EQ 2 and n EQ 1){ arrayAppend(arrMenuBox,box); }</cfscript>
            </cfloop>
            <cfscript>
			arrayAppend(arrBox, box);
			currentBox++;
			</cfscript>            
		</cfloop>		
		<cfset noData = false>
	</cfif>
	<!--- query data --->
	<cfif structkeyexists(arguments.ss, 'query') and structkeyexists(arguments.ss, 'queryLabelField') and structkeyexists(arguments.ss, 'queryValueField')>
    	<cfset count=arguments.ss.query.recordcount>
		<cfloop query="arguments.ss.query">
            <cfscript>
			if(structkeyexists(arguments.ss, 'queryValueField')){
				if(arguments.ss.queryParseValueVars){
					value=application.zcore.functions.zParseVariables(arguments.ss.queryValueField, false, arguments.ss.query);
				}else{
					value=arguments.ss.query[arguments.ss.queryValueField];
				}
			}else{
				value=arguments.ss.query[arguments.ss.queryLabelField];
			} 
			if(arguments.ss.queryParseValueVars and checkedValues NEQ "" and listFind(checkedValues, application.zcore.functions.zParseVariables(arguments.ss.queryValueField, false, arguments.ss.query), arguments.ss.checkedDelimiter) NEQ 0){
				checked='checked="checked"';
				arrayappend(arrChecked, currentBox);
			}else{
				if(checkedValues NEQ "" and listFind(checkedValues, arguments.ss.query[arguments.ss.queryValueField], arguments.ss.checkedDelimiter) NEQ 0){
					checked='checked="checked"';
					arrayappend(arrChecked, currentBox);
				}else{
					checked='';
				}
			}
			if(structkeyexists(arguments.ss, 'queryLabelField')){
			  if(arguments.ss.dollarFormatLabels and isNumeric(arguments.ss.query[arguments.ss.queryLabelField])){
				label="$"&NumberFormat(arguments.ss.query[arguments.ss.queryLabelField]);
			  }else{
					if(arguments.ss.queryParseLabelVars){
						label=application.zcore.functions.zParseVariables(arguments.ss.queryLabelField, false, arguments.ss.query);
					}else{
						label=arguments.ss.query[arguments.ss.queryLabelField];
					}
			  }
			}else{
			  if(arguments.ss.dollarFormatLabels and isNumeric(arguments.ss.query[arguments.ss.queryValueField])){
					label="$"&NumberFormat(arguments.ss.query[arguments.ss.queryValueField]);
			   }else{
					label=arguments.ss.query[arguments.ss.queryValueField];
			  }
			}
			if(arguments.ss.labelSide EQ "right"){
				rightLabel=label;
				leftLabel="";
			}else{
				rightLabel="";
				leftLabel=label;
			}
			if(currentBox LT arguments.ss.menuSize){
				boxCount=2;
				if(checked NEQ ""){
					arrayappend(arrChecked, currentBox&"_2");	
				}
			}else{
				boxCount=1;
			}
			</cfscript>
            <cfloop from="1" to="#boxCount#" index="n">
            <cfsavecontent variable="box">
        	<a href="##" onclick="zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,#currentBox#,'#arguments.ss.type#',0<cfif boxCount EQ 2 and n EQ 1>,1<cfelse>,0</cfif>); return false;" id="zExpMenuOptionLink#request.zInputExpandingBoxCount#_#currentBox#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" class="zExpMenuOption<cfif checked NEQ "">Over</cfif>">#leftLabel# <input type="#arguments.ss.type#" class="zExpMenuInput" onclick="zExpMenuToggleCheckBox(#request.zInputExpandingBoxCount#,#currentBox#,'#arguments.ss.type#',1<cfif boxCount EQ 2 and n EQ 1>,1<cfelse>,0</cfif>);" <cfif structkeyexists(arguments.ss, 'onChange')>onchange="#arguments.ss.onChange#"</cfif> name="#arguments.ss.name##arguments.ss.enumerate#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" id="zExpMenuOption#request.zInputExpandingBoxCount#_#currentBox#<cfif boxCount EQ 2 and n EQ 1>_2</cfif>" value="#htmleditformat(value)#" #checked# /> #rightLabel#</a></cfsavecontent>
			<cfscript>if(boxCount EQ 2 and n EQ 1){ arrayAppend(arrMenuBox,box); }</cfscript>
            </cfloop>
            <cfscript>
			arrayAppend(arrBox, box);
			currentBox++;
			</cfscript> 
		</cfloop>
		<cfset noData = false>
	</cfif>
    	<span class="#arguments.ss.className#">
    	<div id="#arguments.ss.name#_expmenu1" class="zExpMenuBox" onclick="zExpMenuIgnoreClick=#request.zInputExpandingBoxCount#;">
        <cfif arguments.ss.groupLabel NEQ ""><span class="zExpMenuGroupLabel">#arguments.ss.groupLabel#</span></cfif>
        <div id="#arguments.ss.name#_expmenu3" class="zExpMenuBoxOptions">
		<cfscript>
		writeoutput(arraytolist(arrMenuBox,"<br />")&'</div>');
		if(arguments.ss.menuSize LT arraylen(arrBox)){
			writeoutput('<a href="##" onclick="zExpMenuToggleMenu(''#arguments.ss.name#''); return false;" id="#arguments.ss.name#_expmenu4">More Options &gt;&gt;</a><br />');
		}
        </cfscript></div>
    
    <!--- <link href="/z/a/stylesheets/zExpandingBox.css" rel="stylesheet" type="text/css"> --->
        <div id="#arguments.ss.name#_expmenu2" class="zExpandingBox" onclick="zExpMenuIgnoreClick=#request.zInputExpandingBoxCount#;" style=" display:none;left:0px; top:0px; position:absolute;">
        <input type="hidden" name="zExpMenuBoxCount#request.zInputExpandingBoxCount#" id="zExpMenuBoxCount#request.zInputExpandingBoxCount#" onchange="#arguments.ss.onchange#" value="#arraylen(arrBox)#" />
        <table style="width:100%;"><tr><td><span class="zExpMenuGroupLabel">#arguments.ss.groupLabel#</span></td></tr><tr><td id="#arguments.ss.name#_expmenu5"><table style="width:100%;"><cfscript>	
        inputStruct = StructNew();
        inputStruct.colspan = arguments.ss.colspan;
        inputStruct.rowspan = count;
        inputStruct.vertical = true;
        myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
        myColumnOutput.init(inputStruct);
        for(i=1;i LTE arraylen(arrBox);i++){
            writeoutput(myColumnOutput.check(i)&arrBox[i]&"<br />"&myColumnOutput.ifLastRow(i));
        }
        </cfscript></table></td>
        </tr>
        <tr><td colspan="#inputStruct.colspan#" class="zExpandingBoxSubmitLinks" style="text-align:right;">
        <a href="##" onclick="zExpMenuToggleMenu('#arguments.ss.name#'); return false;">OK</a></td></tr>
        </table></div></span>
        <cfscript>
	
        echo('<script type="text/javascript">
		/* <![CDATA[ */
		zArrDeferredFunctions.push(function(){
	 	zExpMenuBoxData[#request.zInputExpandingBoxCount#]=new Object();
	 	zExpMenuBoxData[#request.zInputExpandingBoxCount#].menuSize=parseInt("#arguments.ss.menuSize#");
	 	zExpMenuBoxData[#request.zInputExpandingBoxCount#].colspan=parseInt("#arguments.ss.colspan#");
	 	zExpMenuBoxData[#request.zInputExpandingBoxCount#].type=parseInt("#arguments.ss.type#");
	 	zExpMenuBoxData[#request.zInputExpandingBoxCount#].template="#jsstringformat(template)#";
		zExpMenuBoxChecked[#request.zInputExpandingBoxCount#]=');
		if(arraylen(arrChecked) EQ 0){
			echo('new Array();');
		}else{
			echo('new Array(''#arraytolist(arrChecked,"','")#'');');
		}
		echo('});
		/* ]]> */
		</script>'); 
		</cfscript>
	<cfif noData>
		<cfthrow type="exception" message="zSelectBox: listLabels or (query and queryLabel) are required.">
	</cfif>
		
	</cfsavecontent>
			<cfscript>
            request.zInputExpandingBoxCount++;
            
	if(arguments.ss.output){
		writeoutput(selectBox);
	}
	</cfscript>
	<cfreturn selectBox>
</cffunction>



<!--- 
ts=StructNew();
ts.name="formName";
ts.action=request.cgi_script_name&"?action=submit";
ts.ajax=true;
ts.debug=false;
ts.method="get";
ts.class="zFormCheckDirty"; // use ts.class="zFormCheckDirty"; if you want to prompt user on navigation changes before losing data
ts.onLoadCallback="";
ts.onChangeCallback="";
ts.successMessage=true;
zForm(ts);
 --->
<cffunction name="zForm" localmode="modern" returntype="any" output="true">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=StructNew();	
	// set defaults
	ts.name = "formName"; // must be unique
	ts.ajax=false;
	ts.class="";
	ts.debug=false;
	ts.enctype="";
	ts.ignoreOldRequests=false;
	ts.onLoadCallback="function(){};";
	if(request.zos.istestserver){
		ts.onErrorCallback="function(r){/*alert(r);*/};";
	}else{
		ts.onErrorCallback="function(r){};";
	}
	ts.onChangeCallback="function(){};";
	ts.action=request.cgi_script_name&"?"&cgi.QUERY_STRING&"&zFormAction=submit";
	ts.successMessage=true;
	ts.method="post";
	// override defaults
	StructAppend(arguments.ss, ts, false);
	if(application.zcore.functions.zEndFormCheckEnabled() and application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		application.zcore.template.fail("You must call zEndForm() before calling zForm() again.");
	}
	request.zos.zFormCurrentName=arguments.ss.name;
	</cfscript>
    <cfif structkeyexists(request.zos,"zFormGlobalInit") EQ false>
		<cfscript>
		request.zos.zForm=structnew();
		request.zos.zForm.globalInit=true;
        request.zos.zForm.formStruct=structnew(); 
        </cfscript>
    </cfif>
    
    
    <cfif structkeyexists(request.zos.zForm.formStruct,arguments.ss.name) EQ false>
    	<cfscript>
		request.zos.zForm.formStruct[arguments.ss.name]=structnew();
		request.zos.zForm.formStruct[arguments.ss.name].arrFields=arraynew(1);
		</cfscript>
<script type="text/javascript">
/* <![CDATA[ */
zArrDeferredFunctions.push(function(){
zFormData["#arguments.ss.name#"]=new Object();
zFormData["#arguments.ss.name#"].ignoreOldRequests=#arguments.ss.ignoreOldRequests#;
zFormData["#arguments.ss.name#"].onLoadCallback=#arguments.ss.onLoadCallback#;
zFormData["#arguments.ss.name#"].onErrorCallback=#arguments.ss.onErrorCallback#;
zFormData["#arguments.ss.name#"].onChangeCallback=#arguments.ss.onChangeCallback#;
zFormData["#arguments.ss.name#"].submitId="";
zFormData["#arguments.ss.name#"].error=false;
zFormData["#arguments.ss.name#"].debug=#arguments.ss.debug#;
zFormData["#arguments.ss.name#"].action="#arguments.ss.action#";
zFormData["#arguments.ss.name#"].method="#arguments.ss.method#";
zFormData["#arguments.ss.name#"].ajaxSuccess = true;
zFormData["#arguments.ss.name#"].successMessage=#arguments.ss.successMessage#;
zFormData["#arguments.ss.name#"].arrFields = new Array();
zFormData["#arguments.ss.name#"].ajax=#arguments.ss.ajax#;
zFormData["#arguments.ss.name#"].ajaxStartCount=0;
zFormData["#arguments.ss.name#"].ajaxEndCount=0;
zFormData["#arguments.ss.name#"].contentType="application/x-www-form-urlencoded";
});
/* ]]> */
	</script>
    </cfif>
    <a id="anchor_#arguments.ss.name#"></a>
    <form name="#arguments.ss.name#" id="#arguments.ss.name#" class="#arguments.ss.class#" action="#htmleditformat(arguments.ss.action)#" method="post" onsubmit="return zFormSubmit('#arguments.ss.name#',false,false);" <cfif arguments.ss.enctype NEQ "">enctype="#arguments.ss.enctype#"</cfif>>
    <div id="zFormMessage_#arguments.ss.name#" class="zFormMessageBox"></div>
</cffunction>
<cffunction name="zEndForm" localmode="modern" returntype="any" output="true"></form><!--- <script type="text/javascript">/* <![CDATA[ */zDisableTextSelection(document.getElementById("#request.zos.zFormCurrentName#"));/* ]]> */</script> --->
	<cfscript>
	request.zos.zFormCurrentName="";
	</cfscript>
</cffunction>


<cffunction name="zDisbleEndFormCheck" localmode="modern" returntype="any" output="no">
	<cfscript>
	request.zos.zDisableEndFormCheckRule=true;
	</cfscript>
</cffunction>
<cffunction name="zEndFormCheckEnabled" localmode="modern" returntype="any" output="no">
	<cfscript>
	if(structkeyexists(request.zos,'zDisableEndFormCheckRule')){
		return false;	
	}else{
		return true;	
	}
	</cfscript>
</cffunction>










<!--- 
this is not accurate
	ts = StructNew();
	ts.groupLabel = "group name";
	ts.name = "name";
	ts.type="checkbox";
	ts.menuSize=10;
	ts.colspan=3;
	ts.enumerate = 1; // for editing multiple records
	ts.output = true; // set to false to save to variable
	ts.style = "normal"; // stylesheet class
	ts.checkedValues = "value1"; // send list if there are multiple values.
	ts.checkedDelimiter = ","; // change if comma conflicts...
	ts.onChange = "zFunction();";
	ts.defaultValue = "value1";
	ts.dollarFormatLabels = true;
	ts.onlyOneSelection=false; // set to true to limit select count to one
	// options for query data
	ts.query = qQuery;
	ts.queryLabelField = "table_label";
	ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
	ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
	ts.queryValueField = "table_value";
	// options for list data
	ts.listLabels = "value1,value2,value3";
	ts.listValues = "1,2,3";
	ts.listLabelsDelimiter = chr(9); // tab delimiter
	ts.listValuesDelimiter = chr(9);
	ts.selectedValues="";
	zInputLinkBox(ts);

 --->
<cffunction name="zInputLinkBox" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var arrURL='';
	var ds='';
	var stylesBackup='';
	var z1='';
	var nameBackup='';
	var rs=structnew();
	var out=0;
	var arrOut=arraynew(1);
	var i=0;
	var arrL=0;
	var arrV=0;
	var ts=structnew();
	var styles="";
	var inputStyles="";
	var scripts="";
	var tempValue=0;
	var selectedValue=0;
	var arrValues=0;
	var arrSelected=0;
	var arrSelectedV=0;
	var arrSelectedLink=0;
	var selectedStruct=0;
	var zOffset=0;
	var arrOut9=arraynew(1);
	var out2="";
	var ds1='<script type="text/javascript">/* <![CDATA[ */document.write("';
	var ds2=' ';
	var ds3='';
	var ds4='");/* ]]> */</script>';
	var dss1="";
	var dss2="";
	var dss3="";
	var id="";
	var dss4="";
	var escape="";
	var t9=structnew();
	var link=""; 
	ts.output=true;
	ts.listLabelsDelimiter=chr(9);
	ts.listValuesDelimiter=chr(9);
	ts.listURLsDelimiter=chr(9);
	ts.friendlyName="";
	ts.enableTyping=false;
	ts.overrideOnKeyUp=false;
	ts.disableSpiderAfter=0;
	ts.disableSpider=false;
	ts.allowAnyText=true;
	ts.onlyOneSelection=false;
	ts.notranslate=false;
	ts.listURLs="";
	ts.selectedOnTop=true;
	ts.required=false;
	ts.enableClickSelect=true;
	ts.onchange="";
	ts.onkeyup="";
	ts.onEnterJS="";
	ts.selectLabel="-- Select --";
	ts.onKeyPress="";
	ts.onbuttonclick="";
	ts.inputStyle="";
	ts.range=false;
	ts.onclick="";
	ts.style="display:block;clear:both;";
	ts.inputClass="";
	ts.class="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.listLabels EQ ""){
		arguments.ss.listLabels=arguments.ss.listValues;
	}
	if(arguments.ss.listValues EQ ""){
		//application.zcore.template.fail("arguments.ss.listValues is required and cannot be an empty string.");	
	}
    arguments.ss.listLabels=htmleditformat(arguments.ss.listLabels);
    arguments.ss.listValues=htmleditformat(arguments.ss.listValues);
    arguments.ss.listURLs=htmleditformat(arguments.ss.listURLs);
    arrL=listtoarray(arguments.ss.listLabels, arguments.ss.listLabelsDelimiter, true);
    arrV=listtoarray(arguments.ss.listValues, arguments.ss.listValuesDelimiter, true);
    arrURL=listtoarray(arguments.ss.listURLs, arguments.ss.listURLsDelimiter, true);
	if(arguments.ss.inputclass NEQ ""){
		inputstyles&=' class="#arguments.ss.inputclass#"';
	}
		styles&=' style="white-space:nowrap;#arguments.ss.style#"';
	if(arguments.ss.style NEQ ""){
	}
	if(arguments.ss.class NEQ ""){
		styles&=' class="#arguments.ss.class#"';
	}
	if(arguments.ss.onclick NEQ ""){
		scripts&=arguments.ss.onclick;
	}
	
	if(isDefined('request.zos.zFormLinkBoxCreated') EQ false){
		request.zos.zFormLinkBoxCreated=true;
		application.zcore.template.appendtag('content','<div id="zTOB" style="display:none; position:absolute; background-color:##FFFFFF; z-index:110; width:276px; height:250px; overflow:auto; float:left; border:1px solid ##CCCCCC;"></div>');
	}
	
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onchange&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="text";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	local.tempRS=application.zcore.functions.zFormJSNewZValue(8);
	zOffset=local.tempRS.zValue;
	arguments.ss.onEnterJS&="zInputSetSelectedOptions(true,#zOffset#,'#arguments.ss.name#',null,#arguments.ss.allowAnyText#);obj.value='';document.getElementById(obj.id+'v').value='';";
	if(arguments.ss.overrideOnKeyUp EQ false){
		arguments.ss.onkeyup&="document.getElementById(this.id+'v').value=this.value;";
	}
	arguments.ss.onKeyPress&="return zDisableEnter(event);";
	if(structkeyexists(arguments.ss, 'selectedValues')){
		selectedValue=arguments.ss.selectedValues;
	}else{
		if(structkeyexists(variables, arguments.ss.name)){
			selectedValue=variables[arguments.ss.name];
		}else if(structkeyexists(form, arguments.ss.name)){
			selectedValue=form[arguments.ss.name];
		}else{
			selectedValue="";
		}
	}
	if(trim(selectedValue) EQ ""){
		arrValues=arraynew(1);
	}else{
		arrValues=listtoarray(selectedValue,",", true);
	}
	selectedStruct=structnew();
	for(i=1;i LTE arraylen(arrValues);i++){
		selectedStruct[arrValues[i]]=true;
	}
	arrSelected=arraynew(1);
	arrSelectedV=arraynew(1);
	arrSelectedLink=arraynew(1);
	link="##";
	if(arguments.ss.disableSpider){
		dss1=ds1;
		dss2=ds2;
		dss3=ds3;
		dss4=ds4;
		escape="\";
	}
	arrayappend(arrOut,'<input type="hidden" name="'&arguments.ss.name&'_zlabel" id="'&arguments.ss.name&'_zlabel" value="" />');
	arrayappend(arrOut,'<input type="hidden" name="'&arguments.ss.name&'" onchange="#arguments.ss.onchange#" id="'&arguments.ss.name&'" value="#htmleditformat(selectedValue)#" />');
	
	stylesBackup=styles;
	if(arguments.ss.enableClickSelect EQ false){
		styles=replacenocase(styles,'style="','style="display:none !important;','all');
	}
	//arrayappend(arrOut, dss1);
	for(i=1;i LTE arraylen(arrL);i++){
		if(arraylen(arrV) LT i) continue;
		id="zInputLinkBox#zOffset#_link#i#";
		
		if(structkeyexists(selectedStruct, arrV[i])){
			arrayappend(arrSelected,jsstringformat(arrL[i]));	
			arrayappend(arrSelectedV,jsstringformat(arrV[i]));	
			arrayappend(arrSelectedLink,jsstringformat(id));	
			structdelete(selectedStruct,arrV[i]);
		}
		if(arraylen(arrURL) GTE i){
			link=arrURL[i];
		}
		if(arguments.ss.disableSpider EQ false and arguments.ss.disableSpiderAfter EQ i-1){
			dss1=ds1;
			dss2=ds2;
			dss3=ds3;
			dss4=ds4;
			escape="\";
		}
		arrayappend(arrOut, ('<a id="#id#" hre'&dss3&'f="'&link&'" '&dss2&' onclick="zSetInput(''#arguments.ss.name#_zmanual'', zHasInnerText() ? this.innerText : this.textContent);zSetInput(''#arguments.ss.name#_zmanualv'',''#arrV[i]#'');zInputSetSelectedOptions(true,#zOffset#,''#arguments.ss.name#'',''#id#'',#arguments.ss.allowAnyText#,#arguments.ss.onlyOneSelection#);#scripts#zCLink(this);this.style.display=''none'';'&' return false;" #styles#>'&arrL[i]&'</'&dss3&'a>'));	
		arrayappend(arrOut9,arrV[i]);
	}
	styles=stylesBackup;
	</cfscript><cfsavecontent variable="out2">
	#local.tempRS.output#
<cfif arguments.ss.selectedOnTop><div id="zInputOptionBlock#zOffset#" style="width:100%;"></div><br style="clear:both;" /></cfif>
    <input type="hidden" name="#arguments.ss.name#_zmanualv" id="#arguments.ss.name#_zmanualv" value="" />
<cfif arguments.ss.enableTyping>



 Type: <input type="text" name="#arguments.ss.name#_zmanual" id="#arguments.ss.name#_zmanual" onkeyup="#arguments.ss.onkeyup# 
	zFormOnEnter(event,this);" onkeypress="#arguments.ss.onkeypress#" value="" style="width:40%; #arguments.ss.inputstyle#" #inputstyles# />
    <script type="text/javascript">
	/* <![CDATA[ */
	document.getElementById("#arguments.ss.name#_zmanual").setAttribute("autocomplete","off");
	/* ]]> */
	</script>
 
<input type="button" name="zInputAddCat#zOffset#" onclick="<cfif arguments.ss.onButtonClick NEQ "">#arguments.ss.onButtonClick#</cfif>zInputSetSelectedOptions(true,#zOffset#,'#arguments.ss.name#',null,#arguments.ss.allowAnyText#,#arguments.ss.onlyOneSelection#);document.getElementById('#arguments.ss.name#_zmanual').value='';" value="Enter" style="#arguments.ss.inputstyle#" #inputstyles# /> 
<cfelse>
    <input type="hidden" name="#arguments.ss.name#_zmanual" id="#arguments.ss.name#_zmanual" value="" />

	<cfscript>
	t9=duplicate(arguments.ss);
	t9.selectedValues="~~noselection~~";
	t9.onchange="if(this.selectedIndex!=0){zSetInput('#arguments.ss.name#_zmanual', this.options[this.selectedIndex].text, true); zSetInput('#arguments.ss.name#_zmanualv',this.options[this.selectedIndex].value, true);this.selectedIndex=0; zInputSetSelectedOptions(true,#zOffset#,'#arguments.ss.name#','#id#',#arguments.ss.allowAnyText#,#arguments.ss.onlyOneSelection#);#scripts#zCLink(this);zSetInput('#arguments.ss.name#_zmanual','');zSetInput('#arguments.ss.name#_zmanualv','');} var z1=document.getElementById('zExpOption#zOffset+7#_contents'); if(z1){ z1.style.height='auto';  var z=zGetAbsPosition(z1);z1.style.height=z.height+'px';}";
	nameBackup=arguments.ss.name;
	t9.selectLabel=arguments.ss.selectLabel;
	t9.inlineStyle=" width:100%;";
	t9.name="zLinkBoxSelectBox"&zOffset;
	t9.disableAjaxFieldData=true;
	t9.output=true;
    application.zcore.functions.zInputSelectBox(t9);
	//arguments.ss.name=nameBackup;
    </cfscript>
</cfif>
<cfif arguments.ss.enableClickSelect>
<cfif arraylen(arrL) NEQ 0 and arguments.ss.onlyOneSelection EQ false><br />
or 
Click to select:<br style="clear:both;" /></cfif>
</cfif></cfsavecontent>
<cfscript>
arrayprepend(arrOut,out2);
</cfscript>

<cfsavecontent variable="out2">
<cfif arguments.ss.selectedOnTop EQ false><div id="zInputOptionBlock#zOffset#" style="width:100%;"></div></cfif>
<script type="text/javascript">/* <![CDATA[ */
zArrDeferredFunctions.push(function(){
<cfif arraylen(arrSelected) NEQ 0>zValues[#zOffset#]=["#arraytolist(arrSelected,'","')#"];zValues[#zOffset+1#]=["#arraytolist(arrSelectedV,'","')#"];;zValues[#zOffset+2#]=["#arraytolist(arrSelectedLink,'","')#"];</cfif>
zValues[#zOffset+3#]=new Array("#arraytolist(arrOut9,'","')#");
zValues[#zOffset+4#]="#arguments.ss.name#";
zValues[#zOffset+5#]=#zOffset+7#;
zValues[#zOffset+6#]=#arguments.ss.onlyOneSelection#;
<cfif arguments.ss.enableTyping>
zFormOnEnterAdd("#arguments.ss.name#_zmanual","#arguments.ss.onEnterJS#");
</cfif>
zInputSetSelectedOptions(false,#zOffset#);
});
/* ]]> */
</script></cfsavecontent>
     <cfscript>
	 out=arraytolist(arrOut,"")&out2;
	 if(arguments.ss.output){
	 	writeoutput(out);
	 }else{
		 rs.output=out;
		 rs.zExpOptionValue=zOffset+7;
		rs.value="<br />"&arraytolist(arrSelected,"<br />");
		return rs;
	 }
	 </cfscript>
</cffunction>





 
<cffunction name="zMotion" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var topC="";
	var arrO=0;
	var ts=StructNew();	 
	// set defaults
	// ts.labelId="";
	// ts.id = "formName";
	ts.hideOnCloseId="";
	ts.open=false;
	ts.direction="down";
	ts.rollover=false;
	ts.click=false;
	// override defaults
	StructAppend(arguments.ss, ts, false);
	
	arrO=arraynew(1);
	arrayAppend(arrO,"<script type=""text/javascript"">/* <![CDATA[ */
zArrDeferredFunctions.push(function(){");
	arrayAppend(arrO,"var zd1=document.getElementById('#arguments.ss.labelId#');var zd2=new Function('zMotiontoggleSlide(""#arguments.ss.id#"",""#arguments.ss.labelId#"",""#arguments.ss.hideOnCloseId#"");');");
	if(arguments.ss.click){
		arrayAppend(arrO,"zd1.onmousedown=new Function('zMotionOnMouseDown(""#arguments.ss.id#"");');");
		arrayAppend(arrO,"zd1.onmouseup=zd2;");
		arrayAppend(arrO,"zDisableTextSelection(zd1);");
		 
	}
	if(arguments.ss.open EQ false){
		arrayAppend(arrO,"document.getElementById('#arguments.ss.id#').style.display='none';");
	}else{
		arrayAppend(arrO,"document.getElementById('#arguments.ss.hideOnCloseId#').style.display='none';");
	}
	if(arguments.ss.rollover){
		arrayAppend(arrO,"zd1.onmouseover=zd2;zd1.onmouseout=zd2;");
	}
	writeoutput(arraytolist(arrO," ")&" });/* ]]> */</script>");
	</cfscript>    
</cffunction>

<cffunction name="zFormJSNewZValue" localmode="modern" output="yes" returntype="any">
	<cfargument name="count" type="numeric" required="yes"><cfscript>
	var i=0;
	var rs={};
	var theHTML="";
	var returnCount=0;
	if(structkeyexists(request, 'zValueOffset') EQ false){
		request.zValueOffset=-1;
	}
	rs.zValue=request.zValueOffset+1;
	savecontent variable="rs.output"{
		writeoutput('<script type="text/javascript">/* <![CDATA[ */
		zArrDeferredFunctions.push(function(){');
		for(i=1;i LTE arguments.count;i++){
			request.zValueOffset++;
			writeoutput('zValues[#request.zValueOffset#]=[];');
		}
		writeoutput('}); 
		/* ]]> */</script>');
	}
	return rs;
	</cfscript>
</cffunction>
    
    
<!--- 
ts=StructNew();
ts.label="Price:";
ts.contents="Stuff here";
ts.height="70";
ts.width="150";
ts.zMotionOpen=false;
ts.zMotionEnabled=false;
zExpOption(ts);
 --->
<cffunction name="zExpOption" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var ns=0;
	var ts=structnew(); 
	ts.zMotionEnabled=false;
	ts.zMotionOpen=false;
	ts.disableOverflow=false;
	ts.value="";
	ts.height=0;
	StructAppend(arguments.ss, ts, false);
	if(structkeyexists(arguments.ss,'zExpOptionValue') EQ false){
		local.tempRS=application.zcore.functions.zFormJSNewZValue(1);
		arguments.ss.zExpOptionValue=local.tempRS.zValue;
		writeoutput(local.tempRS.output);
	}
	</cfscript>
<div id="zExpOption#arguments.ss.zExpOptionValue#_container" style="z-index:#arguments.ss.zExpOptionValue+10#;width:#arguments.ss.width#px;" class="zExpOption_container"><div class="zExpOption_button" id="zExpOption#arguments.ss.zExpOptionValue#_button"><a  href="##" onclick="return false;" style=" width:#arguments.ss.width-12#px; "></a></div><div id="zExpOption#arguments.ss.zExpOptionValue#_contents" class="zExpOption_contents" style=" <cfif arguments.ss.height NEQ 0>height:#arguments.ss.height-22#px; </cfif> width:#arguments.ss.width-12#px; white-space:nowrap;<cfif arguments.ss.disableOverflow>overflow:visible !important;</cfif> ">#arguments.ss.contents#</div>
        <!--- <div id="zExpUpdateBar#arguments.ss.zExpOptionValue#" style=" width:#arguments.ss.width-12#px; " class="zExpOption_update">Click to Update</div> ---></div>
	
    <script type="text/javascript">/* <![CDATA[ 12 */
zArrDeferredFunctions.push(function(){
	zExpOptionLabelHTML[#arguments.ss.zExpOptionValue#]="<span class=\"zExpOption_label\">#jsstringformat(arguments.ss.label)#<\/span>";zExpOptionSetValue(#arguments.ss.zExpOptionValue#,"#jsstringformat(arguments.ss.value)#","<cfif arguments.ss.zMotionOpen>none<cfelse>inline</cfif>");
});
    /* ]]> */</script>
	<cfscript>
	if(arguments.ss.zMotionEnabled){
		ns=StructNew();
		ns.labelId="zExpOption#arguments.ss.zExpOptionValue#_button";
		ns.id="zExpOption#arguments.ss.zExpOptionValue#_contents";
		ns.hideOnCloseId="zExpOption#arguments.ss.zExpOptionValue#_value";
		ns.direction="down";
		ns.open=arguments.ss.zMotionOpen;
		ns.click=true;
		application.zcore.functions.zMotion(ns);
	}
	</cfscript>
</cffunction>









<!--- 
<cfscript>
ts=StructNew();
ts.name="price_low";
ts.name2="price_high";
ts.range=true;
ts.listLabels="";
ts.listValues="";
ts.listLabelsDelimiter = ","; // tab delimiter
ts.listValuesDelimiter = ",";
// query
ts.query=qQuery;
ts.queryParseLabelVars = false;
ts.queryParseValueVars = false;
ts.queryValueField="";
ts.queryLabelField="";

zInputSlider(ts);
</cfscript>
 --->
<cffunction name="zInputSlider" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ds=0;
	var rs=structnew();
	var arrValues=arraynew(1);
	var arrLabels=arraynew(1);
	var selectedValue1 = "";
	var selectedValue2 = "";
	var label1value="";
	var label2value="";
	var marginLeft=0;
	var marginRight=0;
	var sliderWidthSubtract=10;
	var output="";
	var percent=0;
	var zValue="";
	var pixels=0;
	var i = 0;
	var ts =StructNew();	
	// set defaults
	ts.width=150;
	ts.leftLabel="";
	ts.rightLabel="";
	ts.middleLabel="";
	ts.friendlyName="";
	ts.fieldWidth="50";
	ts.range=false;
	ts.onchange="";
	ts.multiple = false;
	ts.enumerate = "";
	ts.output = true;
	ts.required=false;
	ts.queryParseLabelVars = false;
	ts.queryParseValueVars = false;
	ts.listLabelsDelimiter = ","; // tab delimiter
	ts.listValuesDelimiter = ",";
	ts.dollarFormatLabels = false;
	// override defaults
	StructAppend(arguments.ss, ts, false);
	if(arguments.ss.range and structkeyexists(arguments.ss,"name2") EQ false){
		application.zcore.template.fail("arguments.ss.name2 is required when arguments.ss.range is true.");
	}
	
	if(structkeyexists(arguments.ss,"listValues")){
		if(structkeyexists(arguments.ss,"listLabels") EQ false){
			arguments.ss.listLabels=arguments.ss.listValues;
		}
		arrValues=listtoarray(replace(arguments.ss.listValues,chr(10)," ",'all'), arguments.ss.listValuesDelimiter,true);
		arrLabels=listtoarray(replace(arguments.ss.listLabels,chr(10)," ",'all'), arguments.ss.listLabelsDelimiter,true);
	}
	local.tempRS=application.zcore.functions.zFormJSNewZValue(8);
	zValue=local.tempRS.zValue;
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew();
		ds.required=arguments.ss.required;
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		arguments.ss.onchange&="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);";
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[ */');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="text";');
		writeoutput('ts.id="#arguments.ss.name#";');
		writeoutput('ts.required=#arguments.ss.required#;');
		writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		if(arguments.ss.range){
			local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
			arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
			writeoutput('var ts=new Object();');
			writeoutput('ts.type="text";');
			writeoutput('ts.id="#arguments.ss.name2#";');
			writeoutput('ts.required=#arguments.ss.required#;');
			writeoutput('ts.friendlyName="#jsstringformat(arguments.ss.friendlyName)#";');
			writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		}
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	</cfscript>
    <cfif structkeyexists(arguments.ss,"query")><cfloop query="arguments.ss.query"><cfscript>
		if(arguments.ss.queryParseLabelVars){
			arrayappend(arrLabels,replace(application.zcore.functions.zParseVariables(arguments.ss.queryLabelField, false, arguments.ss.query),chr(10)," ",'all'));
		}else{
			arrayappend(arrLabels,replace(arguments.ss.query[arguments.ss.queryLabelField],chr(10)," ",'all'));
		}
		if(arguments.ss.queryParseValueVars){
			arrayappend(arrValues,replace(application.zcore.functions.zParseVariables(arguments.ss.queryValueField, false, arguments.ss.query),chr(10)," ",'all'));
		}else{
			arrayappend(arrValues,replace(arguments.ss.query[arguments.ss.queryValueField],chr(10)," ",'all'));
		}
		</cfscript></cfloop></cfif>
        <cfscript>
		if(arguments.ss.range){
			sliderWidthSubtract=20;	
		}
		pixels=(arguments.ss.width-sliderWidthSubtract)/(arraylen(arrValues));
		//writeoutput("pixels:"&pixels&"| count: #arraylen(arrValues)#<br />");
		if(application.zcore.functions.zso(form, arguments.ss.name) NEQ ""){
			selectedValue1 = form[arguments.ss.name];
			label1value=selectedValue1;
			if(isNumeric(left(selectedValue1,1))){
				selectedValue1=replace(replace(selectedValue1,",","","ALL"),"$","","ALL");
			}
			for(i=1;i LTE arraylen(arrValues);i++){
				if(arrValues[i] == selectedValue1){
					label1value=arrLabels[i];
					marginLeft=round(pixels*(i-0.5));
					break;	
				}else if(arrValues[i] GT selectedValue1){
					marginLeft=round(pixels*(i-1.0));
					break;
				}
			}
		}
		if(application.zcore.functions.zso(form, arguments.ss.name2) NEQ ""){
			selectedValue2 = form[arguments.ss.name2];
			label2value=selectedValue2;
			if(isNumeric(left(selectedValue2,1))){
				selectedValue2=replace(replace(selectedValue2,",","","ALL"),"$","","ALL");
			}
			for(i=1;i LTE arraylen(arrValues);i++){
				if(arrValues[i] == selectedValue2){
					label2value=arrLabels[i];
					marginRight=round((arguments.ss.width-sliderWidthSubtract)-(pixels*(i-0.5)));
					break;	
				}else if(arrValues[i] GT selectedValue2){
					marginRight=round((arguments.ss.width-sliderWidthSubtract)-(pixels*(i-1.0)));
					break;
				}
			}
		}
		if(cgi.HTTP_USER_AGENT CONTAINS 'MSIE 6.0'){
			marginLeft/=2;
			marginRight/=2;	
		}
		//writeoutput(arraytolist(arrLabels)&"<br />");
		//writeoutput("#selectedValue1#|marginLeft: #marginLeft# of #arguments.ss.width-sliderWidthSubtract#<br />");
		//writeoutput("marginRight: #marginRight# of #arguments.ss.width-sliderWidthSubtract#<br />");
		</cfscript>
<cfsavecontent variable="output">
#local.tempRS.output#
<div style="float:left; width:100%;" class="zSliderInputDiv">
<div style="float:left; width:50%;"><input type="hidden" name="zInputHiddenValues#zValue#" id="zInputHiddenValues#zValue#" onchange="#arguments.ss.onchange#" value="" />
<cfif arguments.ss.leftLabel NEQ "">#arguments.ss.leftLabel#</cfif>
<input type="text" style="width:#arguments.ss.fieldWidth#px;" name="#arguments.ss.name#_label" id="#arguments.ss.name#_label" value="#htmleditformat(label1value)#" onkeyup="zExpShowUpdateBar(#zValue+6#, 'block');zInputSliderSetValue('#arguments.ss.name#',#zValue#,#zValue+2#,this.value,#zValue+6#, 1);" onclick="zCacheSliderValues[this.id]=this.value;this.value='';" onblur="if(this.value==''){this.value=zCacheSliderValues[this.id];} zExpShowUpdateBar(#zValue+6#, 'none');zInputSliderSetValue('#arguments.ss.name#',#zValue#,#zValue+2#,this.value,#zValue+6#, 1);" />
<input type="hidden" name="#arguments.ss.name#" id="#arguments.ss.name#" value="#htmleditformat(selectedValue1)#" /> 

</div>

<div style="float:right; text-align:right; width:50%;"><cfif arguments.ss.range><cfif arguments.ss.middleLabel NEQ "">#arguments.ss.middleLabel#</cfif>

<input type="text" onkeyup="zExpShowUpdateBar(#zValue+7#, 'block');zInputSliderSetValue('#arguments.ss.name2#',#zValue+1#,#zValue+3#,this.value,#zValue+6#, 2);" onclick="zCacheSliderValues[this.id]=this.value;this.value='';" onblur="if(this.value==''){this.value=zCacheSliderValues[this.id];} zExpShowUpdateBar(#zValue+7#, 'none');zInputSliderSetValue('#arguments.ss.name2#',#zValue+1#,#zValue+3#,this.value,#zValue+6#, 2);" style="width:#arguments.ss.fieldWidth#px;" name="#arguments.ss.name2#_label" value="#htmleditformat(label2value)#" id="#arguments.ss.name2#_label" />

<input type="hidden" name="#arguments.ss.name2#" id="#arguments.ss.name2#" value="#htmleditformat(selectedValue2)#" />

<cfif arguments.ss.rightLabel NEQ "">#arguments.ss.rightLabel#</cfif></cfif>
</div>
</div><br style="clear:both;" />
<div id="zInputSliderBox#zValue#" class="zSliderBgDiv" style="width:100%; overflow:hidden;">
<div id="zInputDragBox1_#zValue#" style="z-index:1;width:10px; height:15px; cursor:pointer; text-align:center; float:left;margin-left:#marginLeft#px; "><img src="/z/a/images/slider.jpg" alt="Click and drag this slider" width="10" height="15" style="float:left;" /></div>
<cfif arguments.ss.range>
<div id="zInputDragBox2_#zValue#" onmouseup="this.style.position='';" style="z-index:2; float:right; margin-right:#marginRight#px; width:10px; height:15px; cursor:pointer;text-align:center; "><img src="/z/a/images/slider.jpg" alt="Click and drag this slider" width="10" height="15" style="float:left;" /></div></cfif>
</div>
<div id="zInputSliderBottomBox_#zValue#" style="display:none;width:100%; float:left; clear:both;"></div>
<cfscript>
echo('<script type="text/javascript">
/* <![CDATA[ */
zArrDeferredFunctions.push(function(){
zValues[#zValue#]="#JSStringFormat(arraytolist(arrLabels,chr(10)))#".split("\n");
zValues[#zValue+1#]="#JSStringFormat(arraytolist(arrValues,chr(10)))#".split("\n");
zValues[#zValue+2#]="');
if(selectedValue1 NEQ ""){
	echo(selectedValue1);
}else{
	echo('min');
}
echo('";
zValues[#zValue+3#]="');
if(selectedValue2 NEQ ""){
	echo(selectedValue2);
}else{
	echo('max');
}
echo('";
zValues[#zValue+4#]="');
if(label1value NEQ ""){
	echo(label1value); 
}
echo('"; 
zValues[#zValue+5#]="');
if(selectedValue1 NEQ ""){
	echo(label2value); 
}
echo('";');

if(arguments.ss.range){
	echo('zSetSliderInputArray("#arguments.ss.name#_label");
zSetSliderInputArray("#arguments.ss.name2#_label");
zDrag_makeDraggable(document.getElementById("zInputDragBox1_#zValue#"),{callbackFunction:zInputSlideLimit,boxObj:"zInputSliderBox#zValue#",constrainObj:"zInputDragBox2_#zValue#",constrainLeft:false,labelId:"#arguments.ss.name#_label",valueId:"#arguments.ss.name#",zValue:#zValue#,zValueValue:#zValue+2#,zValueLabel:#zValue+4#,zExpOptionValue:#zValue+6#,range:#arguments.ss.range#});
zDrag_makeDraggable(document.getElementById("zInputDragBox2_#zValue#"),{callbackFunction:zInputSlideLimit,boxObj:"zInputSliderBox#zValue#",constrainObj:"zInputDragBox1_#zValue#",constrainLeft:true,labelId:"#arguments.ss.name2#_label",valueId:"#arguments.ss.name2#",zValue:#zValue#,zValueValue:#zValue+3#,zValueLabel:#zValue+5#,zExpOptionValue:#zValue+6#,range:#arguments.ss.range#});');
}else{
	echo('zDrag_makeDraggable(document.getElementById("zInputDragBox1_#zValue#"),{callbackFunction:zInputSlideLimit,boxObj:"zInputSliderBox#zValue#",labelId:"#arguments.ss.name#_label",valueId:"#arguments.ss.name#",zValue:#zValue#,zValueValue:#zValue+2#,zValueLabel:#zValue+4#,zExpOptionValue:#zValue+6#,range:#arguments.ss.range#});');
}
echo('
});
/* ]]> */
</script>');
</cfscript>
</cfsavecontent>
	<cfscript>
	if(arguments.ss.output){
		writeoutput(output);
	}else{
		rs=structnew();
		rs.zValue=zValue;
		rs.zExpOptionValue=zValue+6;
		rs.output=output;
		if(selectedValue1 NEQ ""){
			rs.value=selectedValue1;
		}else{
			rs.value="min";	
		}
		if(arguments.ss.range){
			if(selectedValue2 NEQ ""){
				rs.value&="-"&selectedValue2;
			}else{
				rs.value&="-max";
			}
		}
		return rs;	
	}
	</cfscript>
</cffunction>
    
    
<cffunction name="zGetCountryMap" localmode="modern" returntype="any" output="false">
	<cfscript>
	if(structkeyexists(request.zos, 'countryMap')){
		return request.zos.countryMap;
	}
	countryMap={};
	countryMap["US"]="United States";
	countryMap["RS"]="Serbia";
	countryMap["AF"]="Afghanistan";
	countryMap["AL"]="Albania";
	countryMap["DZ"]="Algeria";
	countryMap["AS"]="American Samoa";
	countryMap["AD"]="Andorra";
	countryMap["AO"]="Angola";
	countryMap["AI"]="Anguilla";
	countryMap["AQ"]="Antarctica";
	countryMap["AG"]="Antigua And Barbuda";
	countryMap["AR"]="Argentina";
	countryMap["AM"]="Armenia";
	countryMap["AW"]="Aruba";
	countryMap["AU"]="Australia";
	countryMap["AT"]="Austria";
	countryMap["AZ"]="Azerbaijan";
	countryMap["BS"]="Bahamas";
	countryMap["BH"]="Bahrain";
	countryMap["BD"]="Bangladesh";
	countryMap["BB"]="Barbados";
	countryMap["BY"]="Belarus";
	countryMap["BE"]="Belgium";
	countryMap["BZ"]="Belize";
	countryMap["BJ"]="Benin";
	countryMap["BM"]="Bermuda";
	countryMap["BT"]="Bhutan";
	countryMap["BO"]="Bolivia";
	countryMap["BC"]="Bonaire";
	countryMap["BA"]="Bosnia And Herzegovinia";
	countryMap["BW"]="Botswana";
	countryMap["BV"]="Bouvet Island";
	countryMap["BR"]="Brazil";
	countryMap["IO"]="British Indian Ocean Territory";
	countryMap["BN"]="Brunei Darussalam";
	countryMap["BG"]="Bulgaria";
	countryMap["BF"]="Burkina Faso";
	countryMap["BI"]="Burundi";
	countryMap["KH"]="Cambodia";
	countryMap["CM"]="Cameroon";
	countryMap["CA"]="Canada";
	countryMap["CS"]="Canary Islands";
	countryMap["CV"]="Cape Verde";
	countryMap["KY"]="Cayman Islands";
	countryMap["CF"]="Central African Republic";
	countryMap["TD"]="Chad";
	countryMap["CL"]="Chile";
	countryMap["CN"]="China";
	countryMap["CX"]="Christmas Island";
	countryMap["CC"]="Cocos (keeling) Islands";
	countryMap["CO"]="Colombia";
	countryMap["KM"]="Comoros";
	countryMap["CG"]="Congo";
	countryMap["CD"]="Congo, Dr Of The";
	countryMap["CK"]="Cook Islands";
	countryMap["CR"]="Costa Rica";
	countryMap["CI"]="Cote D'ivoire";
	countryMap["HR"]="Croatia";
	countryMap["CU"]="Cuba";
	countryMap["RC"]="Curacao";
	countryMap["CY"]="Cyprus";
	countryMap["CZ"]="Czech Republic";
	countryMap["DK"]="Denmark";
	countryMap["DJ"]="Djibouti";
	countryMap["DM"]="Dominica";
	countryMap["DO"]="Dominican Republic";
	countryMap["TP"]="East Timor";
	countryMap["EC"]="Ecuador";
	countryMap["EG"]="Egypt";
	countryMap["SV"]="El Salvador";
	countryMap["EN"]="England";
	countryMap["GQ"]="Equatorial Guinea";
	countryMap["ER"]="Eritrea";
	countryMap["EE"]="Estonia";
	countryMap["ET"]="Ethiopia";
	countryMap["FK"]="Falkland Islands";
	countryMap["FO"]="Faroe Islands";
	countryMap["FJ"]="Fiji";
	countryMap["FI"]="Finland";
	countryMap["FR"]="France";
	countryMap["FX"]="France, Metropolitan";
	countryMap["GF"]="French Guiana";
	countryMap["PF"]="French Polynesia";
	countryMap["TF"]="French Southern Territories";
	countryMap["GA"]="Gabon";
	countryMap["GM"]="Gambia";
	countryMap["GE"]="Georgia";
	countryMap["DE"]="Germany";
	countryMap["GH"]="Ghana";
	countryMap["GI"]="Gibraltar";
	countryMap["GR"]="Greece";
	countryMap["GK"]="Greek Islands";
	countryMap["GL"]="Greenland";
	countryMap["GD"]="Grenada";
	countryMap["GP"]="Guadeloupe";
	countryMap["GU"]="Guam";
	countryMap["GT"]="Guatemala";
	countryMap["GN"]="Guinea";
	countryMap["GW"]="Guinea-Bissau";
	countryMap["GY"]="Guyana";
	countryMap["HT"]="Haiti";
	countryMap["HM"]="Heard And Mcdonald Islands";
	countryMap["HN"]="Honduras";
	countryMap["HK"]="Hong Kong";
	countryMap["HU"]="Hungary";
	countryMap["IS"]="Iceland";
	countryMap["IN"]="India";
	countryMap["ID"]="Indonesia";
	countryMap["IR"]="Iran";
	countryMap["IQ"]="Iraq";
	countryMap["IE"]="Ireland";
	countryMap["IL"]="Israel";
	countryMap["IT"]="Italy";
	countryMap["JM"]="Jamaica";
	countryMap["JP"]="Japan";
	countryMap["JO"]="Jordan";
	countryMap["KZ"]="Kazakhstan";
	countryMap["KE"]="Kenya";
	countryMap["KI"]="Kiribati";
	countryMap["KP"]="Korea, DPR Of";
	countryMap["KR"]="Korea, Republic Of";
	countryMap["KW"]="Kuwait";
	countryMap["KG"]="Kyrgyzstan";
	countryMap["LA"]="Laos";
	countryMap["LV"]="Latvia";
	countryMap["LB"]="Lebanon";
	countryMap["LS"]="Lesotho";
	countryMap["LR"]="Liberia";
	countryMap["LY"]="Libyan Arab Jamahiriya";
	countryMap["LI"]="Liechtenstein";
	countryMap["LT"]="Lithuania";
	countryMap["LU"]="Luxembourg";
	countryMap["MO"]="Macau";
	countryMap["ME"]="Macedonia";
	countryMap["MK"]="Macedonia, FYR Of";
	countryMap["MG"]="Madagascar";
	countryMap["MW"]="Malawi";
	countryMap["MY"]="Malaysia";
	countryMap["MV"]="Maldives";
	countryMap["ML"]="Mali";
	countryMap["MT"]="Malta";
	countryMap["MH"]="Marshall Islands";
	countryMap["MQ"]="Martinique";
	countryMap["MR"]="Mauritania";
	countryMap["MU"]="Mauritius";
	countryMap["YT"]="Mayotte";
	countryMap["MX"]="Mexico";
	countryMap["FM"]="Micronesia, FS Of";
	countryMap["MD"]="Moldova, Republic Of";
	countryMap["MC"]="Monaco";
	countryMap["MN"]="Mongolia";
	countryMap["MS"]="Montserrat";
	countryMap["MA"]="Morocco";
	countryMap["MZ"]="Mozambique";
	countryMap["MM"]="Myanmar";
	countryMap["NA"]="Namibia";
	countryMap["NR"]="Nauru";
	countryMap["NP"]="Nepal";
	countryMap["NL"]="Netherlands";
	countryMap["AN"]="Netherlands Antilles";
	countryMap["NC"]="New Caledonia";
	countryMap["NZ"]="New Zealand";
	countryMap["NI"]="Nicaragua";
	countryMap["NE"]="Niger";
	countryMap["NG"]="Nigeria";
	countryMap["NU"]="Niue";
	countryMap["NF"]="Norfolk Island";
	countryMap["MP"]="Northern Mariana Islands";
	countryMap["NO"]="Norway";
	countryMap["OM"]="Oman";
	countryMap["PK"]="Pakistan";
	countryMap["PW"]="Palau";
	countryMap["PA"]="Panama";
	countryMap["PG"]="Papua New Guinea";
	countryMap["PY"]="Paraguay";
	countryMap["PE"]="Peru";
	countryMap["PH"]="Philippines";
	countryMap["PN"]="Pitcairn";
	countryMap["PL"]="Poland";
	countryMap["PT"]="Portugal";
	countryMap["PR"]="Puerto Rico";
	countryMap["QA"]="Qatar";
	countryMap["RE"]="Reunion";
	countryMap["RO"]="Romania";
	countryMap["RU"]="Russian Federation";
	countryMap["RW"]="Rwanda";
	countryMap["SU"]="Saba";
	countryMap["WS"]="Samoa";
	countryMap["SM"]="San Marino";
	countryMap["ST"]="Sao Tome And Principe";
	countryMap["SA"]="Saudi Arabia";
	countryMap["SW"]="Scotland";
	countryMap["SN"]="Senegal";
	countryMap["SC"]="Seychelles";
	countryMap["SL"]="Sierra Leone";
	countryMap["SG"]="Singapore";
	countryMap["SK"]="Slovakia (Slovak Republic)";
	countryMap["SI"]="Slovenia";
	countryMap["SB"]="Solomon Islands";
	countryMap["SO"]="Somalia";
	countryMap["ZA"]="South Africa";
	countryMap["GS"]="South Georgia";
	countryMap["ES"]="Spain";
	countryMap["LK"]="Sri Lanka";
	countryMap["SQ"]="St Barthelemy";
	countryMap["SF"]="St Eustatius";
	countryMap["KN"]="St Kitts And Nevis";
	countryMap["LC"]="St Lucia";
	countryMap["SS"]="St Martin/St Maarten";
	countryMap["VC"]="St Vincent And The Grenadines";
	countryMap["SH"]="St. Helena";
	countryMap["PM"]="St. Pierre And Miquelon";
	countryMap["SD"]="Sudan";
	countryMap["SR"]="Suriname";
	countryMap["SJ"]="Svalbard And Jan Mayen Islands";
	countryMap["SZ"]="Swaziland";
	countryMap["SE"]="Sweden";
	countryMap["CH"]="Switzerland";
	countryMap["SY"]="Syrian Arab Republic";
	countryMap["TW"]="Taiwan";
	countryMap["TJ"]="Tajikistan";
	countryMap["TZ"]="Tanzania";
	countryMap["TH"]="Thailand";
	countryMap["TG"]="Togo";
	countryMap["TK"]="Tokelau";
	countryMap["TO"]="Tonga";
	countryMap["TT"]="Trinidad And Tobago";
	countryMap["TN"]="Tunisia";
	countryMap["TR"]="Turkey";
	countryMap["TM"]="Turkmenistan";
	countryMap["TC"]="Turks And Caicos Islands";
	countryMap["TV"]="Tuvalu";
	countryMap["UG"]="Uganda";
	countryMap["UA"]="Ukraine";
	countryMap["AE"]="United Arab Emirates";
	countryMap["GB"]="United Kingdom";
	countryMap["US"]="United States";
	countryMap["UY"]="Uruguay";
	countryMap["UM"]="US Minor Outlying Islands";
	countryMap["UZ"]="Uzbekistan";
	countryMap["VU"]="Vanuatu";
	countryMap["VA"]="Vatican City State";
	countryMap["VE"]="Venezuela";
	countryMap["VN"]="Vietnam";
	countryMap["VG"]="British Virgin Islands";
	countryMap["VI"]="US Virgin Islands";
	countryMap["WA"]="Wales";
	countryMap["WF"]="Wallis And Futuna Islands";
	countryMap["EH"]="Western Sahara";
	countryMap["YE"]="Yemen";
	countryMap["YU"]="Yugoslavia";
	countryMap["ZM"]="Zambia";
	countryMap["ZW"]="Zimbabwe";
	request.zos.countryMap=countryMap;
	return countryMap;
	</cfscript>
</cffunction>

<cffunction name="zGetCountryNameMap" localmode="modern">
	<cfscript>
	if(structkeyexists(request.zos, 'countryNameMap')){
		return request.zos.countryNameMap;
	}
	countryMap=zGetCountryMap();
	countryNameMap={};
	for(abbr in countryMap){
		countryNameMap[countryMap[abbr]]=abbr;
	}
	request.zos.countryNameMap=countryNameMap;
	return countryNameMap;
	</cfscript>
</cffunction>

<cffunction name="zCountryNameToAbbr" localmode="modern" returntype="any" output="false">
	<cfargument name="country_name" type="string" required="yes">
	<cfargument name="throwIfMissing" type="boolean" required="no" default="#false#">
	<cfscript>
	countryNameMap=zGetCountryNameMap();
	if(structkeyexists(countryNameMap, arguments.country_name)){
		return countryNameMap[arguments.country_name];
	}else{
		if(arguments.throwIfMissing){
			throw("Country name is not valid: #arguments.country_name#");
		}
		return arguments.country_name;
	}
	</cfscript>
</cffunction>
    
<cffunction name="zCountryAbbrToFullName" localmode="modern" returntype="any" output="false">
	<cfargument name="country_code" type="string" required="yes">
	<cfargument name="throwIfMissing" type="boolean" required="no" default="#false#">
	<cfscript>
	countryMap=zGetCountryMap();
	if(structkeyexists(countryMap, arguments.country_code)){
		return countryMap[arguments.country_code];
	}else{
		if(arguments.throwIfMissing){
			throw("Country code is not valid: #arguments.country_code#");
		}
		return arguments.country_code;
	}
	</cfscript>
</cffunction>
     
    
<cffunction name="zCountrySelect" localmode="modern" returntype="any" output="false">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="country_code" type="string" required="no" default="">
	<cfargument name="style" type="string" required="no" default="">
	<cfargument name="onChangeJavascript" type="string" required="no" default="">
	<cfscript>
	var tempString = "";
	</cfscript>
	<cfsavecontent variable="tempString">
	
	<select name="#arguments.fieldName#" id="#arguments.fieldName#" onchange="#arguments.onChangeJavascript#" size="1" style="#arguments.style#">
		  <option <cfif arguments.country_code EQ "">selected="selected"</cfif> value="">-- Select --</option>
		  <option  value="">-- Not Listed --</option>
<option value="US" <cfif arguments.country_code EQ "US">selected="selected"</cfif>>United States</option>
<option value="AF" <cfif arguments.country_code EQ "AF">selected="selected"</cfif>>Afghanistan</option>
<option value="AL" <cfif arguments.country_code EQ "AL">selected="selected"</cfif>>Albania</option>
<option value="DZ" <cfif arguments.country_code EQ "DZ">selected="selected"</cfif>>Algeria</option>
<option value="AS" <cfif arguments.country_code EQ "AS">selected="selected"</cfif>>American Samoa</option>
<option value="AD" <cfif arguments.country_code EQ "AD">selected="selected"</cfif>>Andorra</option>
<option value="AO" <cfif arguments.country_code EQ "AO">selected="selected"</cfif>>Angola</option>
<option value="AI" <cfif arguments.country_code EQ "AI">selected="selected"</cfif>>Anguilla</option>
<option value="AQ" <cfif arguments.country_code EQ "AQ">selected="selected"</cfif>>Antarctica</option>
<option value="AG" <cfif arguments.country_code EQ "AG">selected="selected"</cfif>>Antigua And Barbuda</option>
<option value="AR" <cfif arguments.country_code EQ "AR">selected="selected"</cfif>>Argentina</option>
<option value="AM" <cfif arguments.country_code EQ "AM">selected="selected"</cfif>>Armenia</option>
<option value="AW" <cfif arguments.country_code EQ "AW">selected="selected"</cfif>>Aruba</option>
<option value="AU" <cfif arguments.country_code EQ "AU">selected="selected"</cfif>>Australia</option>
<option value="AT" <cfif arguments.country_code EQ "AT">selected="selected"</cfif>>Austria</option>
<option value="AZ" <cfif arguments.country_code EQ "AZ">selected="selected"</cfif>>Azerbaijan</option>
<option value="BS" <cfif arguments.country_code EQ "BS">selected="selected"</cfif>>Bahamas</option>
<option value="BH" <cfif arguments.country_code EQ "BH">selected="selected"</cfif>>Bahrain</option>
<option value="BD" <cfif arguments.country_code EQ "BD">selected="selected"</cfif>>Bangladesh</option>
<option value="BB" <cfif arguments.country_code EQ "BB">selected="selected"</cfif>>Barbados</option>
<option value="BY" <cfif arguments.country_code EQ "BY">selected="selected"</cfif>>Belarus</option>
<option value="BE" <cfif arguments.country_code EQ "BE">selected="selected"</cfif>>Belgium</option>
<option value="BZ" <cfif arguments.country_code EQ "BZ">selected="selected"</cfif>>Belize</option>
<option value="BJ" <cfif arguments.country_code EQ "BJ">selected="selected"</cfif>>Benin</option>
<option value="BM" <cfif arguments.country_code EQ "BM">selected="selected"</cfif>>Bermuda</option>
<option value="BT" <cfif arguments.country_code EQ "BT">selected="selected"</cfif>>Bhutan</option>
<option value="BO" <cfif arguments.country_code EQ "BO">selected="selected"</cfif>>Bolivia</option>
<option value="BC" <cfif arguments.country_code EQ "BC">selected="selected"</cfif>>Bonaire</option>
<option value="BA" <cfif arguments.country_code EQ "BA">selected="selected"</cfif>>Bosnia And Herzegovinia</option>
<option value="BW" <cfif arguments.country_code EQ "BW">selected="selected"</cfif>>Botswana</option>
<option value="BV" <cfif arguments.country_code EQ "BV">selected="selected"</cfif>>Bouvet Island</option>
<option value="BR" <cfif arguments.country_code EQ "BR">selected="selected"</cfif>>Brazil</option>
<option value="IO" <cfif arguments.country_code EQ "IO">selected="selected"</cfif>>British Indian Ocean Territory</option>
<option value="VG" <cfif arguments.country_code EQ "VG">selected="selected"</cfif>>British Virgin Islands</option>
<option value="BN" <cfif arguments.country_code EQ "BN">selected="selected"</cfif>>Brunei Darussalam</option>
<option value="BG" <cfif arguments.country_code EQ "BG">selected="selected"</cfif>>Bulgaria</option>
<option value="BF" <cfif arguments.country_code EQ "BF">selected="selected"</cfif>>Burkina Faso</option>
<option value="BI" <cfif arguments.country_code EQ "BI">selected="selected"</cfif>>Burundi</option>
<option value="KH" <cfif arguments.country_code EQ "KH">selected="selected"</cfif>>Cambodia</option>
<option value="CM" <cfif arguments.country_code EQ "CM">selected="selected"</cfif>>Cameroon</option>
<option value="CA" <cfif arguments.country_code EQ "CA">selected="selected"</cfif>>Canada</option>
<option value="CS" <cfif arguments.country_code EQ "CS">selected="selected"</cfif>>Canary Islands</option>
<option value="CV" <cfif arguments.country_code EQ "CV">selected="selected"</cfif>>Cape Verde</option>
<option value="KY" <cfif arguments.country_code EQ "KY">selected="selected"</cfif>>Cayman Islands</option>
<option value="CF" <cfif arguments.country_code EQ "CF">selected="selected"</cfif>>Central African Republic</option>
<option value="TD" <cfif arguments.country_code EQ "TD">selected="selected"</cfif>>Chad</option>
<option value="CL" <cfif arguments.country_code EQ "CL">selected="selected"</cfif>>Chile</option>
<option value="CN" <cfif arguments.country_code EQ "CN">selected="selected"</cfif>>China</option>
<option value="CX" <cfif arguments.country_code EQ "CX">selected="selected"</cfif>>Christmas Island</option>
<option value="CC" <cfif arguments.country_code EQ "CC">selected="selected"</cfif>>Cocos (keeling) Islands</option>
<option value="CO" <cfif arguments.country_code EQ "CO">selected="selected"</cfif>>Colombia</option>
<option value="KM" <cfif arguments.country_code EQ "KM">selected="selected"</cfif>>Comoros</option>
<option value="CG" <cfif arguments.country_code EQ "CG">selected="selected"</cfif>>Congo</option>
<option value="CD" <cfif arguments.country_code EQ "CD">selected="selected"</cfif>>Congo, Dr Of The</option>
<option value="CK" <cfif arguments.country_code EQ "CK">selected="selected"</cfif>>Cook Islands</option>
<option value="CR" <cfif arguments.country_code EQ "CR">selected="selected"</cfif>>Costa Rica</option>
<option value="CI" <cfif arguments.country_code EQ "CI">selected="selected"</cfif>>Cote D'ivoire</option>
<option value="HR" <cfif arguments.country_code EQ "HR">selected="selected"</cfif>>Croatia</option>
<option value="CU" <cfif arguments.country_code EQ "CU">selected="selected"</cfif>>Cuba</option>
<option value="RC" <cfif arguments.country_code EQ "RC">selected="selected"</cfif>>Curacao</option>
<option value="CY" <cfif arguments.country_code EQ "CY">selected="selected"</cfif>>Cyprus</option>
<option value="CZ" <cfif arguments.country_code EQ "CZ">selected="selected"</cfif>>Czech Republic</option>
<option value="DK" <cfif arguments.country_code EQ "DK">selected="selected"</cfif>>Denmark</option>
<option value="DJ" <cfif arguments.country_code EQ "DJ">selected="selected"</cfif>>Djibouti</option>
<option value="DM" <cfif arguments.country_code EQ "DM">selected="selected"</cfif>>Dominica</option>
<option value="DO" <cfif arguments.country_code EQ "DO">selected="selected"</cfif>>Dominican Republic</option>
<option value="TP" <cfif arguments.country_code EQ "TP">selected="selected"</cfif>>East Timor</option>
<option value="EC" <cfif arguments.country_code EQ "EC">selected="selected"</cfif>>Ecuador</option>
<option value="EG" <cfif arguments.country_code EQ "EG">selected="selected"</cfif>>Egypt</option>
<option value="SV" <cfif arguments.country_code EQ "SV">selected="selected"</cfif>>El Salvador</option>
<option value="EN" <cfif arguments.country_code EQ "EN">selected="selected"</cfif>>England</option>
<option value="GQ" <cfif arguments.country_code EQ "GQ">selected="selected"</cfif>>Equatorial Guinea</option>
<option value="ER" <cfif arguments.country_code EQ "ER">selected="selected"</cfif>>Eritrea</option>
<option value="EE" <cfif arguments.country_code EQ "EE">selected="selected"</cfif>>Estonia</option>
<option value="ET" <cfif arguments.country_code EQ "ET">selected="selected"</cfif>>Ethiopia</option>
<option value="FK" <cfif arguments.country_code EQ "FK">selected="selected"</cfif>>Falkland Islands</option>
<option value="FO" <cfif arguments.country_code EQ "FO">selected="selected"</cfif>>Faroe Islands</option>
<option value="FJ" <cfif arguments.country_code EQ "FJ">selected="selected"</cfif>>Fiji</option>
<option value="FI" <cfif arguments.country_code EQ "FI">selected="selected"</cfif>>Finland</option>
<option value="FR" <cfif arguments.country_code EQ "FR">selected="selected"</cfif>>France</option>
<option value="FX" <cfif arguments.country_code EQ "FX">selected="selected"</cfif>>France, Metropolitan</option>
<option value="GF" <cfif arguments.country_code EQ "GF">selected="selected"</cfif>>French Guiana</option>
<option value="PF" <cfif arguments.country_code EQ "PF">selected="selected"</cfif>>French Polynesia</option>
<option value="TF" <cfif arguments.country_code EQ "TF">selected="selected"</cfif>>French Southern Territories</option>
<option value="GA" <cfif arguments.country_code EQ "GA">selected="selected"</cfif>>Gabon</option>
<option value="GM" <cfif arguments.country_code EQ "GM">selected="selected"</cfif>>Gambia</option>
<option value="GE" <cfif arguments.country_code EQ "GE">selected="selected"</cfif>>Georgia</option>
<option value="DE" <cfif arguments.country_code EQ "DE">selected="selected"</cfif>>Germany</option>
<option value="GH" <cfif arguments.country_code EQ "GH">selected="selected"</cfif>>Ghana</option>
<option value="GI" <cfif arguments.country_code EQ "GI">selected="selected"</cfif>>Gibraltar</option>
<option value="GR" <cfif arguments.country_code EQ "GR">selected="selected"</cfif>>Greece</option>
<option value="GK" <cfif arguments.country_code EQ "GK">selected="selected"</cfif>>Greek Islands</option>
<option value="GL" <cfif arguments.country_code EQ "GL">selected="selected"</cfif>>Greenland</option>
<option value="GD" <cfif arguments.country_code EQ "GD">selected="selected"</cfif>>Grenada</option>
<option value="GP" <cfif arguments.country_code EQ "GP">selected="selected"</cfif>>Guadeloupe</option>
<option value="GU" <cfif arguments.country_code EQ "GU">selected="selected"</cfif>>Guam</option>
<option value="GT" <cfif arguments.country_code EQ "GT">selected="selected"</cfif>>Guatemala</option>
<option value="GN" <cfif arguments.country_code EQ "GN">selected="selected"</cfif>>Guinea</option>
<option value="GW" <cfif arguments.country_code EQ "GW">selected="selected"</cfif>>Guinea-Bissau</option>
<option value="GY" <cfif arguments.country_code EQ "GY">selected="selected"</cfif>>Guyana</option>
<option value="HT" <cfif arguments.country_code EQ "HT">selected="selected"</cfif>>Haiti</option>
<option value="HM" <cfif arguments.country_code EQ "HM">selected="selected"</cfif>>Heard And Mcdonald Islands</option>
<option value="HN" <cfif arguments.country_code EQ "HN">selected="selected"</cfif>>Honduras</option>
<option value="HK" <cfif arguments.country_code EQ "HK">selected="selected"</cfif>>Hong Kong</option>
<option value="HU" <cfif arguments.country_code EQ "HU">selected="selected"</cfif>>Hungary</option>
<option value="IS" <cfif arguments.country_code EQ "IS">selected="selected"</cfif>>Iceland</option>
<option value="IN" <cfif arguments.country_code EQ "IN">selected="selected"</cfif>>India</option>
<option value="ID" <cfif arguments.country_code EQ "ID">selected="selected"</cfif>>Indonesia</option>
<option value="IR" <cfif arguments.country_code EQ "IR">selected="selected"</cfif>>Iran</option>
<option value="IQ" <cfif arguments.country_code EQ "IQ">selected="selected"</cfif>>Iraq</option>
<option value="IE" <cfif arguments.country_code EQ "IE">selected="selected"</cfif>>Ireland</option>
<option value="IL" <cfif arguments.country_code EQ "IL">selected="selected"</cfif>>Israel</option>
<option value="IT" <cfif arguments.country_code EQ "IT">selected="selected"</cfif>>Italy</option>
<option value="JM" <cfif arguments.country_code EQ "JM">selected="selected"</cfif>>Jamaica</option>
<option value="JP" <cfif arguments.country_code EQ "JP">selected="selected"</cfif>>Japan</option>
<option value="JO" <cfif arguments.country_code EQ "JO">selected="selected"</cfif>>Jordan</option>
<option value="KZ" <cfif arguments.country_code EQ "KZ">selected="selected"</cfif>>Kazakhstan</option>
<option value="KE" <cfif arguments.country_code EQ "KE">selected="selected"</cfif>>Kenya</option>
<option value="KI" <cfif arguments.country_code EQ "KI">selected="selected"</cfif>>Kiribati</option>
<option value="KP" <cfif arguments.country_code EQ "KP">selected="selected"</cfif>>Korea, DPR Of</option>
<option value="KR" <cfif arguments.country_code EQ "KR">selected="selected"</cfif>>Korea, Republic Of</option>
<option value="KW" <cfif arguments.country_code EQ "KW">selected="selected"</cfif>>Kuwait</option>
<option value="KG" <cfif arguments.country_code EQ "KG">selected="selected"</cfif>>Kyrgyzstan</option>
<option value="LA" <cfif arguments.country_code EQ "LA">selected="selected"</cfif>>Laos</option>
<option value="LV" <cfif arguments.country_code EQ "LV">selected="selected"</cfif>>Latvia</option>
<option value="LB" <cfif arguments.country_code EQ "LB">selected="selected"</cfif>>Lebanon</option>
<option value="LS" <cfif arguments.country_code EQ "LS">selected="selected"</cfif>>Lesotho</option>
<option value="LR" <cfif arguments.country_code EQ "LR">selected="selected"</cfif>>Liberia</option>
<option value="LY" <cfif arguments.country_code EQ "LY">selected="selected"</cfif>>Libyan Arab Jamahiriya</option>
<option value="LI" <cfif arguments.country_code EQ "LI">selected="selected"</cfif>>Liechtenstein</option>
<option value="LT" <cfif arguments.country_code EQ "LT">selected="selected"</cfif>>Lithuania</option>
<option value="LU" <cfif arguments.country_code EQ "LU">selected="selected"</cfif>>Luxembourg</option>
<option value="MO" <cfif arguments.country_code EQ "MO">selected="selected"</cfif>>Macau</option>
<option value="ME" <cfif arguments.country_code EQ "ME">selected="selected"</cfif>>Macedonia</option>
<option value="MK" <cfif arguments.country_code EQ "MK">selected="selected"</cfif>>Macedonia, FYR Of</option>
<option value="MG" <cfif arguments.country_code EQ "MG">selected="selected"</cfif>>Madagascar</option>
<option value="MW" <cfif arguments.country_code EQ "MW">selected="selected"</cfif>>Malawi</option>
<option value="MY" <cfif arguments.country_code EQ "MY">selected="selected"</cfif>>Malaysia</option>
<option value="MV" <cfif arguments.country_code EQ "MV">selected="selected"</cfif>>Maldives</option>
<option value="ML" <cfif arguments.country_code EQ "ML">selected="selected"</cfif>>Mali</option>
<option value="MT" <cfif arguments.country_code EQ "MT">selected="selected"</cfif>>Malta</option>
<option value="MH" <cfif arguments.country_code EQ "MH">selected="selected"</cfif>>Marshall Islands</option>
<option value="MQ" <cfif arguments.country_code EQ "MQ">selected="selected"</cfif>>Martinique</option>
<option value="MR" <cfif arguments.country_code EQ "MR">selected="selected"</cfif>>Mauritania</option>
<option value="MU" <cfif arguments.country_code EQ "MU">selected="selected"</cfif>>Mauritius</option>
<option value="YT" <cfif arguments.country_code EQ "YT">selected="selected"</cfif>>Mayotte</option>
<option value="MX" <cfif arguments.country_code EQ "MX">selected="selected"</cfif>>Mexico</option>
<option value="FM" <cfif arguments.country_code EQ "FM">selected="selected"</cfif>>Micronesia, FS Of</option>
<option value="MD" <cfif arguments.country_code EQ "MD">selected="selected"</cfif>>Moldova, Republic Of</option>
<option value="MC" <cfif arguments.country_code EQ "MC">selected="selected"</cfif>>Monaco</option>
<option value="MN" <cfif arguments.country_code EQ "MN">selected="selected"</cfif>>Mongolia</option>
<option value="MS" <cfif arguments.country_code EQ "MS">selected="selected"</cfif>>Montserrat</option>
<option value="MA" <cfif arguments.country_code EQ "MA">selected="selected"</cfif>>Morocco</option>
<option value="MZ" <cfif arguments.country_code EQ "MZ">selected="selected"</cfif>>Mozambique</option>
<option value="MM" <cfif arguments.country_code EQ "MM">selected="selected"</cfif>>Myanmar</option>
<option value="NA" <cfif arguments.country_code EQ "NA">selected="selected"</cfif>>Namibia</option>
<option value="NR" <cfif arguments.country_code EQ "NR">selected="selected"</cfif>>Nauru</option>
<option value="NP" <cfif arguments.country_code EQ "NP">selected="selected"</cfif>>Nepal</option>
<option value="NL" <cfif arguments.country_code EQ "NL">selected="selected"</cfif>>Netherlands</option>
<option value="AN" <cfif arguments.country_code EQ "AN">selected="selected"</cfif>>Netherlands Antilles</option>
<option value="NC" <cfif arguments.country_code EQ "NC">selected="selected"</cfif>>New Caledonia</option>
<option value="NZ" <cfif arguments.country_code EQ "NZ">selected="selected"</cfif>>New Zealand</option>
<option value="NI" <cfif arguments.country_code EQ "NI">selected="selected"</cfif>>Nicaragua</option>
<option value="NE" <cfif arguments.country_code EQ "NE">selected="selected"</cfif>>Niger</option>
<option value="NG" <cfif arguments.country_code EQ "NG">selected="selected"</cfif>>Nigeria</option>
<option value="NU" <cfif arguments.country_code EQ "NU">selected="selected"</cfif>>Niue</option>
<option value="NF" <cfif arguments.country_code EQ "NF">selected="selected"</cfif>>Norfolk Island</option>
<option value="MP" <cfif arguments.country_code EQ "MP">selected="selected"</cfif>>Northern Mariana Islands</option>
<option value="NO" <cfif arguments.country_code EQ "NO">selected="selected"</cfif>>Norway</option>
<option value="OM" <cfif arguments.country_code EQ "OM">selected="selected"</cfif>>Oman</option>
<option value="PK" <cfif arguments.country_code EQ "PK">selected="selected"</cfif>>Pakistan</option>
<option value="PW" <cfif arguments.country_code EQ "PW">selected="selected"</cfif>>Palau</option>
<option value="PA" <cfif arguments.country_code EQ "PA">selected="selected"</cfif>>Panama</option>
<option value="PG" <cfif arguments.country_code EQ "PG">selected="selected"</cfif>>Papua New Guinea</option>
<option value="PY" <cfif arguments.country_code EQ "PY">selected="selected"</cfif>>Paraguay</option>
<option value="PE" <cfif arguments.country_code EQ "PE">selected="selected"</cfif>>Peru</option>
<option value="PH" <cfif arguments.country_code EQ "PH">selected="selected"</cfif>>Philippines</option>
<option value="PN" <cfif arguments.country_code EQ "PN">selected="selected"</cfif>>Pitcairn</option>
<option value="PL" <cfif arguments.country_code EQ "PL">selected="selected"</cfif>>Poland</option>
<option value="PT" <cfif arguments.country_code EQ "PT">selected="selected"</cfif>>Portugal</option>
<option value="PR" <cfif arguments.country_code EQ "PR">selected="selected"</cfif>>Puerto Rico</option>
<option value="QA" <cfif arguments.country_code EQ "QA">selected="selected"</cfif>>Qatar</option>
<option value="RE" <cfif arguments.country_code EQ "RE">selected="selected"</cfif>>Reunion</option>
<option value="RO" <cfif arguments.country_code EQ "RO">selected="selected"</cfif>>Romania</option>
<option value="RU" <cfif arguments.country_code EQ "RU">selected="selected"</cfif>>Russian Federation</option>
<option value="RW" <cfif arguments.country_code EQ "RW">selected="selected"</cfif>>Rwanda</option>
<option value="SU" <cfif arguments.country_code EQ "SU">selected="selected"</cfif>>Saba</option>
<option value="WS" <cfif arguments.country_code EQ "WS">selected="selected"</cfif>>Samoa</option>
<option value="SM" <cfif arguments.country_code EQ "SM">selected="selected"</cfif>>San Marino</option>
<option value="ST" <cfif arguments.country_code EQ "ST">selected="selected"</cfif>>Sao Tome And Principe</option>
<option value="SA" <cfif arguments.country_code EQ "SA">selected="selected"</cfif>>Saudi Arabia</option>
<option value="SW" <cfif arguments.country_code EQ "SW">selected="selected"</cfif>>Scotland</option>
<option value="SN" <cfif arguments.country_code EQ "SN">selected="selected"</cfif>>Senegal</option>
<option value="RS" <cfif arguments.country_code EQ "RS">selected="selected"</cfif>>Serbia</option>
<option value="SC" <cfif arguments.country_code EQ "SC">selected="selected"</cfif>>Seychelles</option>
<option value="SL" <cfif arguments.country_code EQ "SL">selected="selected"</cfif>>Sierra Leone</option>
<option value="SG" <cfif arguments.country_code EQ "SG">selected="selected"</cfif>>Singapore</option>
<option value="SK" <cfif arguments.country_code EQ "SK">selected="selected"</cfif>>Slovakia (Slovak Republic)</option>
<option value="SI" <cfif arguments.country_code EQ "SI">selected="selected"</cfif>>Slovenia</option>
<option value="SB" <cfif arguments.country_code EQ "SB">selected="selected"</cfif>>Solomon Islands</option>
<option value="SO" <cfif arguments.country_code EQ "SO">selected="selected"</cfif>>Somalia</option>
<option value="ZA" <cfif arguments.country_code EQ "ZA">selected="selected"</cfif>>South Africa</option>
<option value="GS" <cfif arguments.country_code EQ "GS">selected="selected"</cfif>>South Georgia</option>
<option value="ES" <cfif arguments.country_code EQ "ES">selected="selected"</cfif>>Spain</option>
<option value="LK" <cfif arguments.country_code EQ "LK">selected="selected"</cfif>>Sri Lanka</option>
<option value="SQ" <cfif arguments.country_code EQ "SQ">selected="selected"</cfif>>St Barthelemy</option>
<option value="SF" <cfif arguments.country_code EQ "SF">selected="selected"</cfif>>St Eustatius</option>
<option value="KN" <cfif arguments.country_code EQ "KN">selected="selected"</cfif>>St Kitts And Nevis</option>
<option value="LC" <cfif arguments.country_code EQ "LC">selected="selected"</cfif>>St Lucia</option>
<option value="SS" <cfif arguments.country_code EQ "SS">selected="selected"</cfif>>St Martin/St Maarten</option>
<option value="VC" <cfif arguments.country_code EQ "VC">selected="selected"</cfif>>St Vincent And The Grenadines</option>
<option value="SH" <cfif arguments.country_code EQ "SH">selected="selected"</cfif>>St. Helena</option>
<option value="PM" <cfif arguments.country_code EQ "PM">selected="selected"</cfif>>St. Pierre And Miquelon</option>
<option value="SD" <cfif arguments.country_code EQ "SD">selected="selected"</cfif>>Sudan</option>
<option value="SR" <cfif arguments.country_code EQ "SR">selected="selected"</cfif>>Suriname</option>
<option value="SJ" <cfif arguments.country_code EQ "SJ">selected="selected"</cfif>>Svalbard And Jan Mayen Islands</option>
<option value="SZ" <cfif arguments.country_code EQ "SZ">selected="selected"</cfif>>Swaziland</option>
<option value="SE" <cfif arguments.country_code EQ "SE">selected="selected"</cfif>>Sweden</option>
<option value="CH" <cfif arguments.country_code EQ "CH">selected="selected"</cfif>>Switzerland</option>
<option value="SY" <cfif arguments.country_code EQ "SY">selected="selected"</cfif>>Syrian Arab Republic</option>
<option value="TW" <cfif arguments.country_code EQ "TW">selected="selected"</cfif>>Taiwan</option>
<option value="TJ" <cfif arguments.country_code EQ "TJ">selected="selected"</cfif>>Tajikistan</option>
<option value="TZ" <cfif arguments.country_code EQ "TZ">selected="selected"</cfif>>Tanzania</option>
<option value="TH" <cfif arguments.country_code EQ "TH">selected="selected"</cfif>>Thailand</option>
<option value="TG" <cfif arguments.country_code EQ "TG">selected="selected"</cfif>>Togo</option>
<option value="TK" <cfif arguments.country_code EQ "TK">selected="selected"</cfif>>Tokelau</option>
<option value="TO" <cfif arguments.country_code EQ "TO">selected="selected"</cfif>>Tonga</option>
<option value="TT" <cfif arguments.country_code EQ "TT">selected="selected"</cfif>>Trinidad And Tobago</option>
<option value="TN" <cfif arguments.country_code EQ "TN">selected="selected"</cfif>>Tunisia</option>
<option value="TR" <cfif arguments.country_code EQ "TR">selected="selected"</cfif>>Turkey</option>
<option value="TM" <cfif arguments.country_code EQ "TM">selected="selected"</cfif>>Turkmenistan</option>
<option value="TC" <cfif arguments.country_code EQ "TC">selected="selected"</cfif>>Turks And Caicos Islands</option>
<option value="TV" <cfif arguments.country_code EQ "TV">selected="selected"</cfif>>Tuvalu</option>
<option value="UG" <cfif arguments.country_code EQ "UG">selected="selected"</cfif>>Uganda</option>
<option value="UA" <cfif arguments.country_code EQ "UA">selected="selected"</cfif>>Ukraine</option>
<option value="AE" <cfif arguments.country_code EQ "AE">selected="selected"</cfif>>United Arab Emirates</option>
<option value="GB" <cfif arguments.country_code EQ "GB">selected="selected"</cfif>>United Kingdom</option>
<option value="US" <cfif arguments.country_code EQ "US">selected="selected"</cfif>>United States</option>
<option value="UY" <cfif arguments.country_code EQ "UY">selected="selected"</cfif>>Uruguay</option>
<option value="UM" <cfif arguments.country_code EQ "UM">selected="selected"</cfif>>US Minor Outlying Islands</option>
<option value="VI" <cfif arguments.country_code EQ "VI">selected="selected"</cfif>>US Virgin Islands</option>
<option value="UZ" <cfif arguments.country_code EQ "UZ">selected="selected"</cfif>>Uzbekistan</option>
<option value="VU" <cfif arguments.country_code EQ "VU">selected="selected"</cfif>>Vanuatu</option>
<option value="VA" <cfif arguments.country_code EQ "VA">selected="selected"</cfif>>Vatican City State</option>
<option value="VE" <cfif arguments.country_code EQ "VE">selected="selected"</cfif>>Venezuela</option>
<option value="VN" <cfif arguments.country_code EQ "VN">selected="selected"</cfif>>Vietnam</option>
<option value="WA" <cfif arguments.country_code EQ "WA">selected="selected"</cfif>>Wales</option>
<option value="WF" <cfif arguments.country_code EQ "WF">selected="selected"</cfif>>Wallis And Futuna Islands</option>
<option value="EH" <cfif arguments.country_code EQ "EH">selected="selected"</cfif>>Western Sahara</option>
<option value="YE" <cfif arguments.country_code EQ "YE">selected="selected"</cfif>>Yemen</option>
<option value="YU" <cfif arguments.country_code EQ "YU">selected="selected"</cfif>>Yugoslavia</option>
<option value="ZM" <cfif arguments.country_code EQ "ZM">selected="selected"</cfif>>Zambia</option>
<option value="ZW" <cfif arguments.country_code EQ "ZW">selected="selected"</cfif>>Zimbabwe</option>
</select>
	</cfsavecontent>
	<cfreturn tempString>
</cffunction>

<cffunction name="zGetStateNameByAbbr" localmode="modern" returntype="any" output="false">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	ts={};
	ts["AL"]="Alabama";
	ts["AK"]="Alaska";
	ts["AB"]="Alberta";
	ts["AZ"]="Arizona";
	ts["AR"]="Arkansas";
	ts["BC"]="British Columbia";
	ts["CA"]="California";
	ts["CO"]="Colorado";
	ts["CT"]="Connecticut";
	ts["DE"]="Delaware";
	ts["DC"]="District of Columbia";
	ts["FL"]="Florida";
	ts["GA"]="Georgia";
	ts["HI"]="Hawaii";
	ts["ID"]="Idaho";
	ts["IL"]="Illinois";
	ts["IN"]="Indiana";
	ts["IA"]="Iowa";
	ts["KS"]="Kansas";
	ts["KY"]="Kentucky";
	ts["LA"]="Louisiana";
	ts["ME"]="Maine";
	ts["MB"]="Manitoba";
	ts["MD"]="Maryland";
	ts["MA"]="Massachusetts";
	ts["MI"]="Michigan";
	ts["MN"]="Minnesota";
	ts["MS"]="Mississippi";
	ts["MO"]="Missouri";
	ts["MT"]="Montana";
	ts["NE"]="Nebraska";
	ts["NV"]="Nevada";
	ts["NB"]="New Brunswick";
	ts["NH"]="New Hampshire";
	ts["NJ"]="New Jersey";
	ts["NM"]="New Mexico";
	ts["NY"]="New York";
	ts["NL"]="Newfoundland";
	ts["NC"]="North Carolina";
	ts["ND"]="North Dakota";
	ts["NT"]="Northwest Territories";
	ts["NS"]="Nova Scotia";
	ts["NU"]="Nunavut";
	ts["OH"]="Ohio";
	ts["OK"]="Oklahoma";
	ts["ON"]="Ontario";
	ts["OR"]="Oregon";
	ts["PA"]="Pennsylvania";
	ts["PE"]="Prince Edward Island";
	ts["QC"]="Québec";
	ts["RI"]="Rhode Island";
	ts["SK"]="Saskatchewan";
	ts["SC"]="South Carolina";
	ts["SD"]="South Dakota";
	ts["TN"]="Tennessee";
	ts["TX"]="Texas";
	ts["UT"]="Utah";
	ts["VT"]="Vermont";
	ts["VA"]="Virginia";
	ts["WA"]="Washington";
	ts["WV"]="West Virginia";
	ts["WI"]="Wisconsin";
	ts["WY"]="Wyoming";
	ts["YT"]="Yukon Territory";

	if(structkeyexists(ts, arguments.value)){
		return ts[arguments.value];
	}
	return arguments.value;
	</cfscript>
</cffunction>

<cffunction name="zStateSelect" localmode="modern" returntype="any" output="false">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="state_abbr" type="string" required="no" default="">
	<cfargument name="style" type="string" required="no" default="">
	<cfargument name="onChangeJavascript" type="string" required="no" default="">
	<cfargument name="enableCanada" type="boolean" required="no" default="#false#">
	<cfscript>
	var tempString = "";
	</cfscript>
	<cfsavecontent variable="tempString">
	
	<select size="1" name="#arguments.fieldName#" id="#arguments.fieldName#" onchange="#arguments.onChangeJavascript#" style="#arguments.style#">
		  <option <cfif arguments.state_abbr EQ "">selected="selected"</cfif> value="">-- Select --</option>
		  <option value="">-- Not Listed --</option>
		  <option value="AL" <cfif arguments.state_abbr EQ "AL">selected="selected"</cfif>>Alabama</option>
		  <option value="AK" <cfif arguments.state_abbr EQ "AK">selected="selected"</cfif>>Alaska</option>
		  <cfif arguments.enableCanada>
				<option value="AB" <cfif arguments.state_abbr EQ "AB">selected="selected"</cfif>>Alberta</option> 
			</cfif>
	
		  <option value="AZ" <cfif arguments.state_abbr EQ "AZ">selected="selected"</cfif>>Arizona</option>
		  <option value="AR" <cfif arguments.state_abbr EQ "AR">selected="selected"</cfif>>Arkansas</option>
			<cfif arguments.enableCanada>
		   <option value="BC" <cfif arguments.state_abbr EQ "BC">selected="selected"</cfif>>British Columbia</option> 
			</cfif>
		  <option value="CA" <cfif arguments.state_abbr EQ "CA">selected="selected"</cfif>>California</option>
		  <option value="CO" <cfif arguments.state_abbr EQ "CO">selected="selected"</cfif>>Colorado</option>
		  <option value="CT" <cfif arguments.state_abbr EQ "CT">selected="selected"</cfif>>Connecticut</option>
		  <option value="DE" <cfif arguments.state_abbr EQ "DE">selected="selected"</cfif>>Delaware</option>
		  <option value="DC" <cfif arguments.state_abbr EQ "DC">selected="selected"</cfif>>District of Columbia</option>
		  <option value="FL" <cfif arguments.state_abbr EQ "FL">selected="selected"</cfif>>Florida</option>
		  <option value="GA" <cfif arguments.state_abbr EQ "GA">selected="selected"</cfif>>Georgia</option>
		  <option value="HI" <cfif arguments.state_abbr EQ "HI">selected="selected"</cfif>>Hawaii</option>
		  <option value="ID" <cfif arguments.state_abbr EQ "ID">selected="selected"</cfif>>Idaho</option>
		  <option value="IL" <cfif arguments.state_abbr EQ "IL">selected="selected"</cfif>>Illinois</option>
		  <option value="IN" <cfif arguments.state_abbr EQ "IN">selected="selected"</cfif>>Indiana</option>
		  <option value="IA" <cfif arguments.state_abbr EQ "IA">selected="selected"</cfif>>Iowa</option>
		  <option value="KS" <cfif arguments.state_abbr EQ "KS">selected="selected"</cfif>>Kansas</option>
		  <option value="KY" <cfif arguments.state_abbr EQ "KY">selected="selected"</cfif>>Kentucky</option>
		  <option value="LA" <cfif arguments.state_abbr EQ "LA">selected="selected"</cfif>>Louisiana</option>
		  <option value="ME" <cfif arguments.state_abbr EQ "ME">selected="selected"</cfif>>Maine</option>
			<cfif arguments.enableCanada>
		   <option value="MB" <cfif arguments.state_abbr EQ "MB">selected="selected"</cfif>>Manitoba</option>
			</cfif>
		  <option value="MD" <cfif arguments.state_abbr EQ "MD">selected="selected"</cfif>>Maryland</option>
		  <option value="MA" <cfif arguments.state_abbr EQ "MA">selected="selected"</cfif>>Massachusetts</option>
		  <option value="MI" <cfif arguments.state_abbr EQ "MI">selected="selected"</cfif>>Michigan</option>
		  <option value="MN" <cfif arguments.state_abbr EQ "MN">selected="selected"</cfif>>Minnesota</option>
		  <option value="MS" <cfif arguments.state_abbr EQ "MS">selected="selected"</cfif>>Mississippi</option>
		  <option value="MO" <cfif arguments.state_abbr EQ "MO">selected="selected"</cfif>>Missouri</option>
		  <option value="MT" <cfif arguments.state_abbr EQ "MT">selected="selected"</cfif>>Montana</option>
		  <option value="NE" <cfif arguments.state_abbr EQ "NE">selected="selected"</cfif>>Nebraska</option>
		  <option value="NV" <cfif arguments.state_abbr EQ "NV">selected="selected"</cfif>>Nevada</option>
			<cfif arguments.enableCanada>
		   <option value="NB" <cfif arguments.state_abbr EQ "NB">selected="selected"</cfif>>New Brunswick</option>
			</cfif>
		  <option value="NH" <cfif arguments.state_abbr EQ "NH">selected="selected"</cfif>>New Hampshire</option>
		  <option value="NJ" <cfif arguments.state_abbr EQ "NJ">selected="selected"</cfif>>New Jersey</option>
		  <option value="NM" <cfif arguments.state_abbr EQ "NM">selected="selected"</cfif>>New Mexico</option>
		  <option value="NY" <cfif arguments.state_abbr EQ "NY">selected="selected"</cfif>>New York</option>
			<cfif arguments.enableCanada>
		   <option value="NL" <cfif arguments.state_abbr EQ "NL">selected="selected"</cfif>>Newfoundland</option>
			</cfif>
		  <option value="NC" <cfif arguments.state_abbr EQ "NC">selected="selected"</cfif>>North Carolina</option>
		  <option value="ND" <cfif arguments.state_abbr EQ "ND">selected="selected"</cfif>>North Dakota</option>
		<cfif arguments.enableCanada>
			   <option value="NT" <cfif arguments.state_abbr EQ "NT">selected="selected"</cfif>>Northwest Territories</option>
			  <option value="NS" <cfif arguments.state_abbr EQ "NS">selected="selected"</cfif>>Nova Scotia</option> 
			  <option value="NU" <cfif arguments.state_abbr EQ "NU">selected="selected"</cfif>>Nunavut</option>
			</cfif>
		  <option value="OH" <cfif arguments.state_abbr EQ "OH">selected="selected"</cfif>>Ohio</option>
		  <option value="OK" <cfif arguments.state_abbr EQ "OK">selected="selected"</cfif>>Oklahoma</option>
			<cfif arguments.enableCanada>
		   <option value="ON" <cfif arguments.state_abbr EQ "ON">selected="selected"</cfif>>Ontario</option>
			</cfif>
		  <option value="OR" <cfif arguments.state_abbr EQ "OR">selected="selected"</cfif>>Oregon</option>
		  <option value="PA" <cfif arguments.state_abbr EQ "PA">selected="selected"</cfif>>Pennsylvania</option>
			<cfif arguments.enableCanada>
		   <option value="PE" <cfif arguments.state_abbr EQ "PE">selected="selected"</cfif>>Prince Edward Island</option>
		  <option value="QC" <cfif arguments.state_abbr EQ "QC">selected="selected"</cfif>>Québec</option>
			</cfif>
		  <option value="RI" <cfif arguments.state_abbr EQ "RI">selected="selected"</cfif>>Rhode Island</option>
			<cfif arguments.enableCanada>
	 	  <option value="SK" <cfif arguments.state_abbr EQ "SK">selected="selected"</cfif>>Saskatchewan</option>
			</cfif>
		  <option value="SC" <cfif arguments.state_abbr EQ "SC">selected="selected"</cfif>>South Carolina</option>
		  <option value="SD" <cfif arguments.state_abbr EQ "SD">selected="selected"</cfif>>South Dakota</option>
		  <option value="TN" <cfif arguments.state_abbr EQ "TN">selected="selected"</cfif>>Tennessee</option>
		  <option value="TX" <cfif arguments.state_abbr EQ "TX">selected="selected"</cfif>>Texas</option>
		  <option value="UT" <cfif arguments.state_abbr EQ "UT">selected="selected"</cfif>>Utah</option>
		  <option value="VT" <cfif arguments.state_abbr EQ "VT">selected="selected"</cfif>>Vermont</option>
		  <option value="VA" <cfif arguments.state_abbr EQ "VA">selected="selected"</cfif>>Virginia</option>
		  <option value="WA" <cfif arguments.state_abbr EQ "WA">selected="selected"</cfif>>Washington</option>
		  <option value="WV" <cfif arguments.state_abbr EQ "WV">selected="selected"</cfif>>West Virginia</option>
		  <option value="WI" <cfif arguments.state_abbr EQ "WI">selected="selected"</cfif>>Wisconsin</option>
		  <option value="WY" <cfif arguments.state_abbr EQ "WY">selected="selected"</cfif>>Wyoming</option>
			<cfif arguments.enableCanada>
	 	  <option value="YT" <cfif arguments.state_abbr EQ "YT">selected="selected"</cfif>>Yukon Territory</option>
			</cfif>
	</select>
	
	</cfsavecontent>
	<cfreturn tempString>
</cffunction>
    
    
<cffunction name="zFakeFormFieldsNotEmpty" localmode="modern" output="yes" access="public" returntype="any">
	<cfscript>
	if(trim(application.zcore.functions.zso(form, 'form_first_name')&application.zcore.functions.zso(form, 'form_last_name')&application.zcore.functions.zso(form, 'form_comments')) NEQ ""){
		application.zcore.functions.z404("Invalid request - Robot lead submission detected");
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="zFakeFormFields" localmode="modern" output="yes" access="public" returntype="any">
	<cfset local.tick=gettickcount()>
	<table id="zInqTheFormNames#local.tick#">
        <tr>
            <td>First Name</td>
            <td><input name="form_first_name" type="text" maxlength="50" value="" /><span class="highlight"> * Required</span></td>
        </tr>
        <tr>
            <td>Last Name</td>
            <td><input name="form_last_name" type="text" maxlength="50" value="" /></td>
        </tr>
        <tr>
            <td>Comments</td>
            <td><textarea name="form_comments" cols="50" rows="5"></textarea></td>
        </tr>
    </table>
    <script type="text/javascript">
    var tFN32=document.getElementById("zInqTheF"+"ormNames#local.tick#");tFN34="ne";tFN32.style.display="no"+tFN34;
    tFN32.parentNode.removeChild(tFN32);
    </script>
    <noscript>
    	<div class="z-float" style="font-size:24px;">Warning: JavaScript is disabled on your browser.</div>
    	<div class="z-float" style="font-size:18px;">Please enable JavaScript and reload this page or call us instead.</div>
    </noscript>
</cffunction>
    
<!--- application.zcore.functions.zInputUniqueUrl("field_name"); --->
<cffunction name="zInputUniqueUrl" localmode="modern" returntype="any" output="yes">
	<cfargument name="field" type="string" required="yes">
	<cfargument name="forceEnableEditing" type="boolean" required="no" default="#false#">
	<cfscript>
	if(application.zcore.functions.zso(request.zos, "zFormCurrentName") NEQ ""){
		ds=structNew(); 
		local.fieldId=arraylen(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields);
		local.tempJS="zFormOnChange('#request.zos.zFormCurrentName#',#local.fieldId#);"; 
		arrayappend(request.zos.zForm.formStruct[request.zos.zFormCurrentName].arrFields,ds);
		writeoutput('<script type="text/javascript">/* <![CDATA[*/');
		writeoutput('zArrDeferredFunctions.push(function(){');
		writeoutput('var ts=new Object();');
		writeoutput('ts.type="text";');
		writeoutput('ts.id="#arguments.field#";');
		writeoutput('zFormData["#request.zos.zFormCurrentName#"].arrFields[#local.fieldId#]=ts;');
		writeoutput('});');
		writeoutput('/* ]]> */</script>');
	}
	value=application.zcore.functions.zso(form, arguments.field);
	if(value NEQ ""){
		if(arguments.forceEnableEditing or application.zcore.user.checkServerAccess() or application.zcore.functions.zso(request.zos.globals, "administratorEnableForceDelete", true, 0) EQ 1){
			echo('<input type="text" name="#arguments.field#" id="#arguments.field#" value="#htmleditformat(value)#" style="width:95%;" maxlength="255" /><br />
			<strong>Warning:</strong> Incorrect use of this field can cause broken links.  It is used to change the site''s internal link for this record. Internal links usually start with "/".  ');
		}else{
			echo(value&" | Locked");
			echo('<input type="hidden" name="#arguments.field#" id="#arguments.field#" value="#htmleditformat(value)#" />');
		}
	}else{
		echo('<input type="text" name="#arguments.field#" id="#arguments.field#" value="#htmleditformat(value)#" style="width:95%;" maxlength="255" /><br />
		<strong>Warning:</strong> Incorrect use of this field can cause broken links.  It is used to change the site''s internal link for this record. Internal links usually start with "/".');
		if(not application.zcore.user.checkServerAccess()){
			echo('This field will not be editable after it is set.');
		}
	} 
	</cfscript>
</cffunction>
		
<!--- 
arrField=[
	{label:"Field", value:"Value"},
];
application.zcore.functions.zLogForm(arrField);
 --->
<cffunction name="zLogForm" localmode="modern" access="public">
	<cfargument name="arrField" type="array" required="yes">
	<cfscript>
	arrField=arguments.arrField;
	if(arrayLen(arrField) GT 20){
		throw("zLogForm currently only supports 20 fields.");
	}
	ts={
		datasource:request.zos.zcoreDatasource,
		table:'form_log',
		struct:{
		  site_id:request.zos.globals.id,
		  form_log_url:request.zos.originalURL&"?"&request.zos.cgi.query_string,
		  form_log_datetime:request.zos.mysqlnow,
		  form_log_ip_address:request.zos.cgi.remote_addr,
		  form_log_user_agent:request.zos.cgi.http_user_agent,
		  form_log_updated_datetime:request.zos.mysqlnow,
		  form_log_deleted:0
		}
	};
	for(i=1;i<arrayLen(arrField);i++){
		ts.struct["form_log_field#i#_label"]=arrField[i].label;
		ts.struct["form_log_field#i#_value"]=arrField[i].value;
	}
	if(not structkeyexists(request.zsession, 'zLogFormFirstTime')){
		ts.struct.form_log_first_search=1;
		request.zsession.zLogFormFirstTime=true;
	}
	application.zcore.functions.zInsert(ts);
	</cfscript>
</cffunction>


<!--- 
ts={
	name:arguments.prefixString&arguments.row["#variables.type#_option_id"],
	value:arguments.dataStruct[arguments.prefixString&arguments.row["#variables.type#_option_id"]],
	fields:{
		address:newvalue#arguments.optionStruct.addressfield#,
		city:newvalue#arguments.optionStruct.cityfield#,
		state:newvalue#arguments.optionStruct.statefield#,
		zip:newvalue#arguments.optionStruct.zipfield#,
		country:newvalue#arguments.optionStruct.countryfield#
	}
}
ts={
	name:"map_location",
	value:form.map_location, // optional
	fields:{
		address:"",
		city:"",
		state:"",
		zip:"",
		country:"",
	}
};
echo(application.zcore.functions.zMapLocationPicker(ts));
 --->
<cffunction name="zMapLocationPicker" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	if(not structkeyexists(ss, 'value')){
		ss.value=application.zcore.functions.zso(form, ss.name);
	}
	if(not structkeyexists(ss, 'fields')){
		ss.fields={};
	}
	ts={
		address:"",
		city:"",
		state:"",
		zip:"",
		country:""
	}
	structappend(ss.fields, ts, false);
	</cfscript>
	<cfsavecontent variable="output"> 
		<!--- map picker needs to have ajax javascript in the getFormField that runs on the live data fields instead of requiring you to click on verify link. --->
		<p>Please click Verify Your Location to set the correct map marker position.  Then click the blue close button to continue editing this record.</p>
		<p><input type="text" name="#ss.name#" id="#ss.name#" style="min-width:100px; max-width:200px; width:100%;" value="#htmleditformat(ss.value)#"
		 /> <br>
		<a href="##" style="margin-top:5px;" data-map-field="#ss.name#"
			data-map-address="#ss.fields.address#" 
			data-map-city="#ss.fields.city#" 
			data-map-state="#ss.fields.state#"
			data-map-zip="#ss.fields.zip#"
			data-map-country="#ss.fields.country#" class="zMapPickerButton z-manager-search-button">Verify Your Location</a></p> 
	</cfsavecontent>
	<cfscript>
	return output;
	</cfscript>
</cffunction>


<!--- 
form.inquiries_cc=arrayToList(arrSelected, ",");
ts={
	field:"inquiries_cc",
	arrData:[{label:"Label", value:"Label`test@test.com"}]
}
application.zcore.functions.zEmailTokenAutocompleteInput(ts);
 --->
<cffunction name="zEmailTokenAutocompleteInput" localmode="modern" access="remote" roles="user">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	ss=arguments.ss;
	if(not structkeyexists(request.zos, 'emailTokenAutocompleteInputLoaded')){
		request.zos.emailTokenAutocompleteInputLoaded=true;
		application.zcore.skin.includeJS( '/z/javascript/jquery/Tokenize2/tokenize2.min.js' );
		application.zcore.skin.includeCSS( '/z/javascript/jquery/Tokenize2/tokenize2.min.css' );
		application.zcore.skin.includeCSS( '/z/javascript/jquery/Tokenize2/custom.css' );
	}
	arrSelected=listToArray(application.zcore.functions.zso(form, ss.field), ",");
	selectedStruct={};
	for(selected in arrSelected){
		selectedStruct[selected]=true;
	}
	</cfscript>
	<cfsavecontent variable="out">
		<div id="#ss.field#_container">
			<select id="#ss.field#" name="#ss.field#" multiple="multiple" style="display:none;">
				<cfscript>
				for(item in ss.arrData){
					echo('<option value="#item.value#" ');
					if(structkeyexists(selectedStruct, item.value)){
						echo('selected="selected"');
					}
					echo('>'&htmleditformat(item.label)&'</option>');
				}
				</cfscript>
			</select>
			<div id="#ss.field#_error" class="z-float" style="display:none; color:##900;"></div>
		</div>
		<script type="text/javascript">
		zArrDeferredFunctions.push( function() {
			zEmailTokenInput.setupTokenizeInput("#ss.field#");
		});
		</script>
	</cfsavecontent>
	<cfscript>
	return out;
	</cfscript> 
</cffunction>
</cfoutput>
</cfcomponent>