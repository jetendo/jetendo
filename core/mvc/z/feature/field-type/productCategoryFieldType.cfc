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
	return "";
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
		field: arguments.row["feature_field_name"],
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
	<cfargument name="optionStruct" type="struct" required="yes">
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

<cffunction name="getFormField" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="prefixString" type="string" required="yes">
	<cfargument name="dataStruct" type="struct" required="yes">  
	<cfscript>
		var sValue = application.zcore.functions.zso(arguments.dataStruct, '#arguments.prefixString##arguments.row["feature_field_id"]#');
		var db=request.zos.queryObject;
		db.sql="select p.product_category_id AS ProdId,p.product_category_name AS ProdName, child.product_category_id, child.product_category_name
		 FROM #db.table("product_category", request.zos.globals.datasource)# p
         LEFT JOIN #db.table("product_category", request.zos.globals.datasource)# AS child 
         ON child.product_category_parent_id = p.product_category_id
	   	WHERE p.product_category_parent_id = #db.param(0)#
		AND p.feature_id=#db.param(form.feature_id)#
			AND	p.product_category_deleted = #db.param(0)#
			AND p.product_category_active = #db.param(1)# 		   
		ORDER BY p.product_category_name, child.product_category_name";
		try{
			qProd = db.execute("qProd");
		}
		catch(Any e){qProd = QueryNew("product_category_id, product_category_name");}
	</cfscript>
	<cfsavecontent variable="output">
	<script>
		function pspMgrProdCategoryChanged_#arguments.row["feature_field_id"]#(ctrl){
			var iProduct = parseInt($("###arguments.prefixString##arguments.row["feature_field_id"]#").val());
			if(iProduct){
				if($(".zProductIdClass")[0]){
					var $prod = $(".zProductIdClass");
					if(arrProdInSpecial){
						$prod.find('option').not(':selected').remove();
						for(var idx in arrProdInSpecial){
							var prod = arrProdInSpecial[idx];
							if(prod.category == iProduct && prod.id != $prod.val()){
								$prod.append("<option data-category=\"" + prod.category + "\" value=\""+ prod.id + "\">" + prod.name + "</option>");
							}
						}
					}
				}
			}
		}
	</script>	
	<select class="zProductCategoryIdClass" name="#arguments.prefixString##arguments.row["feature_field_id"]#" id="#arguments.prefixString##arguments.row["feature_field_id"]#" size="8" style="width:350px;" onchange="pspMgrProdCategoryChanged_#arguments.row["feature_field_id"]#(this);">
		<option value="">No Product Category</option>
		<cfset prodName = "">
		<cfloop query="qProd">
			<cfif prodName NEQ qProd.prodName AND qProd.product_category_id GT 0>
				<cfset prodName = qProd.prodName>
				<optgroup label="#prodName#">
			<cfelseif prodName NEQ qProd.prodName AND qProd.product_category_id LTE 0>
				<cfset prodName = qProd.prodName>
				<optgroup label="#prodName#">
				<cfif Trim(sValue) EQ qProd.prodId>
					<option selected value="#qProd.prodId#">#qProd.prodName#</option>
				<cfelse>
					<option value="#qProd.prodId#">#qProd.prodName#</option>
				</cfif>
				<cfcontinue>
			</cfif>
			<cfif Trim(sValue) EQ qProd.product_category_id>
				<option selected value="#qProd.product_category_id#">#qProd.product_category_name#</option>
			<cfelse>
				<option value="#qProd.product_category_id#">#qProd.product_category_name#</option>
			</cfif>
		</cfloop>
	</select>
	</cfsavecontent>
	<cfscript>
		return { label: true, hidden: false, value: output};  
	</cfscript>
</cffunction>

<cffunction name="getFormFieldCode" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfscript>
	return '';
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
	return 'Product Category Picker';
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
		product_id:application.zcore.functions.zso(arguments.dataStruct, 'product_id'),
		product_name:application.zcore.functions.zso(arguments.dataStruct, 'product_name'),
		product_category_id:application.zcore.functions.zso(arguments.dataStruct, 'product_category_id'),
		product_image_library_id:application.zcore.functions.zso(arguments.dataStruct, 'product_image_library_id')
	};
	arguments.dataStruct["feature_field_type_json"]=serializeJson(ts);
	return { success:true, optionStruct: ts};
	</cfscript>
</cffunction>
		

<cffunction name="getFieldFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		product_category_id:""
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
		<input type="radio" name="feature_field_type_id" value="26" onClick="setType(26);" <cfif value EQ 26>checked="checked"</cfif>/>
		#this.getTypeName()#<br />
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