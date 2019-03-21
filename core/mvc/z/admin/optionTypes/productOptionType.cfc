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
	var sValue = application.zcore.functions.zso(arguments.dataStruct, '#arguments.prefixString##arguments.row["#variables.type#_option_id"]#');
	//application.zcore.functions.zso(form, '#variables.siteType#_x_option_group_set_id')
	var db=request.zos.queryObject;
	db.sql="select * from #db.table("product", request.zos.globals.datasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	product_deleted = #db.param(0)# and
	product_active = #db.param(1)# 	
	ORDER BY product_name ASC";
	qProd = db.execute("qProd");
	productName="";
	required="";
	if(arguments.row.site_option_required EQ 1){
		required="required";
	}
	</cfscript>
	<cfsavecontent variable="output">
	<script>
		var arrProdInSpecial	= [];
		zArrDeferredFunctions.push(function(){
			<cfloop query="qProd">
				arrProdInSpecial.push({id:"#qProd.product_id#", name: "#qProd.product_name#", category:"#qProd.product_category_id#"});
				<cfif Trim(sValue) EQ qProd.product_id>
					<cfscript>
					productName=qProd.product_name;
					</cfscript>
					$("###arguments.prefixString##arguments.row["#variables.type#_option_id"]#").append("<option selected data-category=\"#qProd.product_category_id#\" value=\"#qProd.product_id#\">#qProd.product_name#</option>");
				</cfif>
			</cfloop>
		});
		function pspMgrProdChanged_#arguments.row["#variables.type#_option_id"]#(ctrl){
			var $lstCtrl = $("##lstProductName");
			$("##product_name_#arguments.row["#variables.type#_option_id"]#").val($("###arguments.prefixString##arguments.row["#variables.type#_option_id"]# option:selected").text());
			var sCategory = $("###arguments.prefixString##arguments.row["#variables.type#_option_id"]# option:selected").attr("data-category");
			if(sCategory != "" && sCategory !== undefined){
				if($(".zProductCategoryIdClass")[0])
					$(".zProductCategoryIdClass").val(sCategory);
			}
			if($lstCtrl.css('display') == 'block'){
				$lstCtrl.css('display', 'none');
				$("##ddBtnProductName")[0].textContent = "▼";
			}
		}
		function pspMgrHideList_#arguments.row["#variables.type#_option_id"]#(ctrl, lstCtrl) {
			var $theCtrl = $("##" + lstCtrl);
			if($theCtrl.css('display') == 'none'){
				$theCtrl.css('display', 'block');
				ctrl.textContent = "▲";
			} else {
				$theCtrl.css('display', 'none');
				ctrl.textContent = "▼";
			}
		}
		function pspMgrSearchProduct_#arguments.row["#variables.type#_option_id"]#(e, ctrl) {
			if(e.keyCode == 27)
				return false;
			$("###arguments.prefixString##arguments.row["#variables.type#_option_id"]#").empty();
			$("###arguments.prefixString##arguments.row["#variables.type#_option_id"]#").append("<option value=\"\"></option>");
			var searchText = $(ctrl).val().toLowerCase();
			for(var idx in arrProdInSpecial){
				var prod = arrProdInSpecial[idx];
				if(searchText == "" || prod.id.indexOf(searchText) != -1 || prod.name.toLowerCase().indexOf(searchText) != -1){
					$("###arguments.prefixString##arguments.row["#variables.type#_option_id"]#").append("<option data-category=\"" + prod.category + "\" value=\""+ prod.id + "\">" + prod.name + "</option>");
				}
			}
			var $lstCtrl = $("##lstProductName");
			if($lstCtrl.css('display') == 'none'){
				$lstCtrl.css('display', 'block');
				$("##ddBtnProductName")[0].textContent = "▲";
			}
		}
	</script>	
	<input #required# style="width:200px; height:25px;" type="text" id="product_name_#arguments.row["#variables.type#_option_id"]#" value="#productName#"
		name="product_name_#arguments.row["#variables.type#_option_id"]#" list="productList" onkeyup="pspMgrSearchProduct_#arguments.row["#variables.type#_option_id"]#(event, this);" />
	<button type="button" id="ddBtnProductName" onclick="pspMgrHideList_#arguments.row["#variables.type#_option_id"]#(this,'lstProductName');" style="padding:0px; width:22px; height:24px; top:1px; position:relative; left:-3px; cursor:pointer;">▼</button>
	<datalist id="lstProductName" style="display:none; height:300px; width:250px; padding-left:0px;">
		<select class="zProductIdClass" name="#arguments.prefixString##arguments.row["#variables.type#_option_id"]#" id="#arguments.prefixString##arguments.row["#variables.type#_option_id"]#" size="8" style="width:350px;" onchange="pspMgrProdChanged_#arguments.row["#variables.type#_option_id"]#(this);">
			<option value="">No Product</option>
		</select>
	</datalist>
	</cfsavecontent>
	<cfscript>
		<!---
		var db=request.zos.queryObject;
		db.sql="select * from #db.table("product", request.zos.globals.datasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		product_deleted = #db.param(0)# and
		product_active = #db.param(1)# 	
		ORDER BY product_name ASC";
		qGroup=db.execute("qGroup");
		savecontent variable="output"{
			selectStruct = StructNew();
			selectStruct.name = "#arguments.prefixString##arguments.row["#variables.type#_option_id"]#";
			selectStruct.query = qGroup;
			selectStruct.queryLabelField = "product_name";
			selectStruct.queryValueField = "product_id";
			selectStruct.multiple=true;
			selectStruct.hideSelect=true;
			application.zcore.functions.zInputSelectBox(selectStruct);
			application.zcore.functions.zSetupMultipleSelect(selectStruct.name, application.zcore.functions.zso(form, '#variables.siteType#_x_option_group_set_id'), true);
		}
		--->
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
	return 'Product Picker';
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
	arguments.dataStruct["#variables.type#_option_type_json"]=serializeJson(ts);
	return { success:true, optionStruct: ts};
	</cfscript>
</cffunction>
		

<cffunction name="getOptionFieldStruct" output="no" localmode="modern" access="public"> 
	<cfscript>
	ts={
		product_id:""
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
		var output	= "#this.getTypeName()#";
		var value=application.zcore.functions.zso(arguments.dataStruct, arguments.fieldName);
	</cfscript>
	<cfsavecontent variable="output">
		<input type="radio" name="#variables.type#_option_type_id" value="25" onClick="setType(25);" <cfif value EQ 25>checked="checked"</cfif>/>
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