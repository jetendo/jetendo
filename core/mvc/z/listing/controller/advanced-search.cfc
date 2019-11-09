<cfcomponent>
<cfoutput>
<cffunction name="modalSaveSearch" localmode="modern" access="remote" roles="member">
	<cfscript>
	form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', 0, '', form); 
	application.zcore.functions.zReturnJSON({
		success:true, 
		mls_saved_search_id: form.mls_saved_search_id, 
		searchAsString: arrayToList(request.zos.listing.functions.getSearchCriteriaDisplay(form), ", ")
	});
	</cfscript>
</cffunction>

<cffunction name="modalEditSearchForm" localmode="modern" access="remote" roles="member">
	<cfscript>
	form.mls_saved_search_id=application.zcore.functions.zso(form, 'mls_saved_search_id');
	request.zForceSearchFormInclude=true;
	application.zcore.functions.zSetModalWindow();
	ts=StructNew();
	ts.name="zMLSSearchForm";
	ts.ajax=false;
	ts.enctype="multipart/form-data";
	ts.action="/z/listing/advanced-search/modalSaveSearch";
	ts.method="post";
	ts.successMessage=false;
	//ts.onLoadCallback="loadMLSResults";
	ts.onChangeCallback="doChangeCallback";
	application.zcore.functions.zForm(ts);
	
	ts={
		name:"mls_saved_search_id"
	};
	application.zcore.functions.zInput_Hidden(ts);
	
	request.zos.listing.functions.zMLSSearchOptions(form.mls_saved_search_id, "mls_saved_search_id", 1, false);
        application.zcore.functions.zEndForm();
	</cfscript>
	<script>
	/* <![CDATA[ */
	 var parentWindowCallback="#jsstringformat(application.zcore.functions.zso(form,'callback'))#";
	 function executeParentCallback(data){
		if(typeof window.parent[parentWindowCallback] != "undefined"){
			window.parent[parentWindowCallback](data);
		}
	 }
	 function saveCallback(responseText){
		var obj=eval('(' + responseText + ')');
		var field=document.getElementById("mls_saved_search_id");
		field.value=obj.mls_saved_search_id;
		executeParentCallback(obj);
	 }
	 function errorCallback(d){
		alert("Failed to save search, please try again later."); 
		throw("modalSaveSearch ajax call failed.");
	 }
	 function doChangeCallback(formName, newForm){
		var tempObj={};
		tempObj.id="zSaveSearch";
		tempObj.url="/z/listing/advanced-search/modalSaveSearch";
		tempObj.callback=saveCallback;
		tempObj.errorCallback=errorCallback;
		postObj=zGetFormDataByFormId(formName); 
		tempObj.postObj=postObj;
		tempObj.method="post";
		tempObj.cache=false;
		tempObj.ignoreOldRequests=true;
		zAjax(tempObj);
		 getMLSCount(formName, newForm);
		 
	 }
	/* ]]> */
	</script>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" returntype="any">
<!--- 
include quick search, then modify it to have everything in rows and columns
then make it work with edit saved search
 --->
<cfscript>
 application.zcore.template.settag("title","Listing Search");
 application.zcore.template.settag("pagetitle","Listing Search");

</cfscript>
<!--- <cfsavecontent variable="request.theSearchFormTemplate">
##startFormTag##
<!--- <form name="quickSearchForm" id="quickSearchForm" action="##searchFormSubmitURL##" method="post"> --->
<!--- <script>zFormData["zMLSSearchForm"]=new Object(); zFormData["zMLSSearchForm"].arrFields=[];</script> --->

<div style="float:left; width:30%; padding-right:3%;">
<h3>CITY:</h3>
##search_city_id##

</div>
<div style="float:left; width:30%; padding-right:3%;">
<h3>PROPERTY TYPE:</h3>
##search_listing_type_id##<br /> 

<h3>BEDS:</h3>
##search_bedrooms##<br /> 

<h3>BATHS:</h3>
##search_bathrooms##<br /> 

</div>
<div style="float:left; width:30%; padding-right:3%;">
<h3>PRICE RANGE:</h3>
##search_rate##<br /> 

<h3>SQUARE FOOTAGE:</h3><br />
##search_sqfoot##<br />
<h3>YEAR BUILT:</h3>
##search_year_built##<br />
<h3>ACREAGE:</h3>
##search_acreage##<br />

</div>
<br style="clear:both;" />
<hr />
<br style="clear:both;" />
<div style="float:left; width:30%; padding-right:3%;">
<h3>PROPERTY SUB TYPE:</h3>
##search_listing_sub_type_id##<br />

</div>
<div style="float:left; width:30%; padding-right:3%;">
<h3>SALE TYPE:</h3>
##search_status##<br />


<h3>LISTING STATUS:</h3>
##search_liststatus##<br />

<h3>NEAR ADDRESS:</h3>
##search_near_address##<br />
</div>

<div style="float:left; width:30%; padding-right:3%;">
<h3>COUNTY:</h3>
##search_county##<br />

<h3>VIEW:</h3>
##search_view##<br />
</div>
<br style="clear:both;" />
<hr />
<br style="clear:both;" />

<div style="float:left; width:30%; padding-right:3%;">
<h3>MORE OPTIONS:</h3>
##search_more_options##<br />
</div>

<div style="float:left; width:30%; padding-right:3%;">
<h3>STYLE:</h3>
##search_style##<br />
</div>
<div style="float:left; width:30%; padding-right:3%;">
<h3>FRONTAGE:</h3>
##search_frontage##<br />
</div> 

<div style="float:left; clear:both; width:100%;">
<input type="submit" name="submitQuick1" value="Search MLS" style="font-size:18px; line-height:24px;" />
    </div>
    <br style="clear:both;">

##endFormTag## 
</cfsavecontent> --->
<cfsavecontent variable="theFinalHTML">
<cfscript>
ts=structnew();
ts.output=true;
ts.advancedSearch=true;
ts.disablejavascript=true;
ts.searchFormLabelOnInput=true;
ts.searchDisableExpandingBox=true;
ts.searchFormEnabledDropDownMenus=false;
ts.searchReturnVariableStruct=true;
/*ts.searchFormHideCriteria=structnew();
ts.searchFormHideCriteria["more_options"]=true;*/
application.zcore.listingCom.includeSearchForm(ts);
</cfscript>
</cfsavecontent>
<cfscript>
writeoutput(theFinalHTML);
request.zHideInquiryForm=true;
</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>  