<cfcomponent>
<cfoutput>

<!--- 
ss.
allow search results that return a group by field with listing count instead of listings.
	with options for: 
		hide when a group is below 10 (X) results
		excluding a comma separated list
		
<cfscript>
ts=structnew();
ts.searchCriteria=structnew(); // all the search options to use in the listing query
ts.listingDatabaseFieldName=""; // listing_city, etc
ts.hideBelowCount=10; // creates a having clause on the count column
ts.excludeList="bad-data,invalid-data"; 
qResult=zMLSGroupSearch(ts);
</cfscript>
<cfloop query="qResult">

</cfloop>
 --->
<cffunction name="zMLSGroupSearch" localmode="modern" output="no" returntype="any">
    <cfargument name="ss" type="struct" required="yes">
    <cfscript>
    var c2=0;
		var db=request.zos.queryObject;
    
	var ts=0;
	var rs=0;
	var propertyDataCom=0;
	local.arrSelect=arraynew(1);
	local.arrField=arraynew(1);
	local.arrWhere=arraynew(1);
	local.arrOrder=arraynew(1);
	local.arrGroupBy=arraynew(1);
	for(local.i2=1;local.i2 LTE arraylen(arguments.ss.arrExcludeKeywords);local.i2++){
		local.arrL=listtoarray(arguments.ss.arrExcludeKeywords[local.i2], ",");
		for(local.i=1;local.i LTE arraylen(local.arrL);local.i++){
			local.arrL[local.i]="'#application.zcore.functions.zescape(local.arrL[local.i])#'";
		}
		arrayappend(local.arrL,"''");
		arrayappend(local.arrL,"'0'");
		if(arguments.ss.arrField[local.i2] EQ "listing_city"){
			arrayappend(local.arrL,"'#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#'");
		}
		arrayappend(local.arrWhere, " and listing.`"&application.zcore.functions.zescape(arguments.ss.arrField[local.i2])&"` not in ("&arraytolist(local.arrL, ",")&")");
		arrayappend(local.arrField, "listing.`"&application.zcore.functions.zescape(arguments.ss.arrField[local.i2])&"` ");
		arrayappend(local.arrOrder, "value"&local.i2);
		if(arguments.ss.arrInterval[local.i2] NEQ "" and isnumeric(arguments.ss.arrInterval[local.i2])){
			arrayappend(local.arrSelect, "round(listing.`"&application.zcore.functions.zescape(arguments.ss.arrField[local.i2])&"` / "&arguments.ss.arrInterval[local.i2]&")*"&arguments.ss.arrInterval[local.i2]&" value"&local.i2);
			arrayappend(local.arrGroupBy, 'ROUND(listing.`'&application.zcore.functions.zescape(arguments.ss.arrField[local.i2])&"` / "&arguments.ss.arrInterval[local.i2]&") ");
		}else{
			arrayappend(local.arrSelect, "listing.`"&application.zcore.functions.zescape(arguments.ss.arrField[local.i2])&"` value"&local.i2);
			arrayappend(local.arrGroupBy, "listing.`"&application.zcore.functions.zescape(arguments.ss.arrField[local.i2])&"` ");
		}
	}
	ts = StructNew();
	ts.debug=false;
	ts.name="qTest";
	ts.searchStruct=structnew();
	ts.searchStruct.searchCriteria=arguments.ss.searchCriteria;
	ts.searchStruct.contentTableEnabled=false;
	//ts.searchStruct.removeValues=search_listing_type_id;
	//ts.searchStruct.lookupName="listing_type";
	ts.searchStruct.zselect=" listing.listing_mls_id, "&arraytolist(local.arrSelect, ", ")&", COUNT(listing.listing_id) COUNT ";
	ts.searchStruct.zgroupby=" group by "&arraytolist(local.arrGroupBy, ", ")&" ";
	ts.searchStruct.zwhere=arraytolist(local.arrWhere, " ");
	
	if(structkeyexists(arguments.ss, 'hideBelowCount')){
		ts.searchStruct.zhaving=" count >= "&application.zcore.functions.zescape(arguments.ss.hideBelowCount);
	}
	ts.searchStruct.zlimit=1000;
	ts.searchStruct.zReturnLookupQuery=true;
	ts.searchStruct.zorderby=" order by "&arraytolist(local.arrOrder, ", ");
	propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	propertyDataCom.enableFiltering=true;
	propertyDataCom.enableListingTrack=false;
	rs = propertyDataCom.getSearchData(ts);
    return rs;
    </cfscript>
</cffunction>


<cffunction name="index" localmode="modern" access="remote" roles="member">

	<cfscript>
	var arrTSVRow=0;
	var arrRow=0;
	var qResult=0;
	var arrTSV=0;
	var lookupStruct=0;
	var skiprow=0;
	var i=0;
	var c=0;
	var c3=0;
	var ts=0;
	var c2=0;
	application.zcore.functions.zSetPageHelpId("6.3");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Listing Research Tool");
	form.action=application.zcore.functions.zso(form, 'action', false,'list');
	</cfscript>
<cfif form.action EQ "download">
	
</cfif>
<cfscript>
ts=structnew();
ts.searchCriteria=form;
ts.arrExcludeKeywords=arraynew(1);
ts.arrField=arraynew(1);
ts.arrInterval=arraynew(1);
for(i=1;i LTE 5;i++){
	c=application.zcore.functions.zso(form, 'excludekeywords'&i);
	c2=application.zcore.functions.zso(form, 'groupfield'&i);
	c3=application.zcore.functions.zso(form, 'groupinterval'&i);
	if(isnumeric(c3) EQ false){
		form["groupinterval"&i]="";
	}
	if(c2 NEQ ""){
		arrayappend(ts.arrExcludeKeywords, c);
		arrayappend(ts.arrField, c2);
		arrayappend(ts.arrInterval, c3);
	}
}
if(arraylen(ts.arrField) EQ 0){
	form.action="list";
}else{
	//ts.listingDatabaseFieldName="listing_subdivision"; // listing_city, etc
	ts.hideBelowCount=application.zcore.functions.zso(form, 'hideBelowCount',false,3); // creates a having clause on the count column
	ts.excludeList="bad-data,invalid-data"; 
	qResult=this.zMLSGroupSearch(ts);
}
//writedump(qResult);
</cfscript>

<h2>Real Estate Research Tool</h2>
<p>The complex grouping made possible with this tool helps you build real estate lists faster.  This tool can accelerate finding subjects for making new landing pages and navigation for the web site.  <!--- This tool will be integrated with the content management system more in the future to simplify creation of navigation links. ---></p>

<cfscript>
//zdump(application.zcore.status.getStruct(form.searchid));
ts=StructNew();
ts.name="zMLSSearchForm";
ts.ajax=false;
ts.action="#request.cgi_script_name#?method=index&action=search";
ts.method="post";
ts.class="zFormCheckDirty";
ts.successMessage=false;
ts.onLoadCallback="loadMLSResults";
ts.onChangeCallback="getMLSCount";
application.zcore.functions.zForm(ts);
</cfscript>
<script type="text/javascript">
function setInt22(n2, n){
	var d1=document.getElementById(n2);
	if(n == "listing_price"){
		d1.value="100000";
	}else if(n == "listing_acreage"){
		d1.value="1";
	}else if(n == "listing_square_feet"){
		d1.value="500";
	}else if(n == "listing_year_built"){
		d1.value="1";
	}
}
</script>
	<p>Select one or more fields to group by.  The order you select the groups changes the results of the report.</p>
    <p>Multiple exclusion keywords must be separated by a comma.</p>
    <p>Group Interval sets the range for price, square feet, acreage and year built groups. It has no effect on non-numeric fields.</p>
    <div style="width:100%; float:left; padding-bottom:10px;">
    Hide results with fewer then ##<input type="text" name="hidebelowcount" size="3" style="padding:2px; margin:0px;" value="#application.zcore.functions.zso(form, 'hidebelowcount',true,3)#" /> listings.
    
    
    </div>
	<div style="width:100%; float:left; padding-bottom:10px;">
    <cfloop from="1" to="5" index="i">
        <div style="width:150px; padding-right:10px; float:left;">
        <cfscript>
        ts=StructNew();
        ts.name="groupfield"&i;
        ts.listLabels ="Acreage,Bathrooms,Bedrooms,City,Condition,Condo/Building Name,Frontage,Listing Status,Parking,Property Type,Property Sub Type,Price,Region,Sq Foot,Status,Style,Subdivision,Tenure,View,Year Built,Zip";//,List Date
        ts.listValues = "listing_acreage,listing_baths,listing_beds,listing_city,listing_condition,listing_condoname,listing_frontage,listing_liststatus,listing_parking,listing_type_id,listing_sub_type_id,listing_price,listing_region,listing_square_feet,listing_status,listing_style,listing_subdivision,listing_tenure,listing_view,listing_year_built,listing_zip";//,listing_listdate
		ts.onchange="setInt22('groupinterval#i#',this.options[this.selectedIndex].value);";
        ts.listLabelsDelimiter=",";
        ts.listValuesDelimiter=",";
        ts.output=false;
        writeoutput(application.zcore.functions.zInputSelectBox(ts));
        </cfscript>
        <br />
        Excluding Keywords:<br />
        <input type="text" name="excludekeywords#i#" value="#htmleditformat(application.zcore.functions.zso(form, 'excludekeywords'&i))#" />
        <br /><br />
        Group Interval:<br />
        <input type="text" name="groupinterval#i#" id="groupinterval#i#" value="#application.zcore.functions.zso(form, 'groupinterval'&i)#" /> 
        </div>
	</cfloop>
    </div>
    <br style="clear:both;" />
    <hr />
    <cfscript>
    request.zos.listing.functions.zMLSSearchForm();
    </cfscript>
    <input type="hidden" name="searchId" value="#form.searchid#" />
    
    <br style="clear:both;" />
    <input type="submit" name="submit32423" value="Run Report" style="font-size:18px; line-height:21px; padding:10px;" />

#application.zcore.functions.zEndForm()#

<cfif form.action EQ "search">
	<cfscript>
	lookupStruct=structnew();
	lookupStruct["listing_county"]="county";
	lookupStruct["listing_type_id"]="listing_type";
	lookupStruct["listing_sub_type_id"]="listing_sub_type";
	lookupStruct["listing_view"]="view";
	lookupStruct["listing_status"]="salestype";
	lookupStruct["listing_style"]="style";
	lookupStruct["listing_frontage"]="frontage";
	</cfscript>
	<hr />
	<h2>Search Results</h2>
	<table style="cellspacing:0px; " class="table-list">
    <cfscript>
	
	arrTSV=arraynew(1);
	writeoutput('<tr>');
	for(i=1;i LTE 5;i++){
		c2=application.zcore.functions.zso(form, 'groupfield'&i);
		if(c2 NEQ ""){
			c3=application.zcore.functions.zfirstlettercaps(replace(replace(replace(c2,"_id",""), "listing_","","all"),"_"," ","all"));
			writeoutput('<th>'&c3&'</th>');
			arrayappend(arrTSV, c3&chr(9));
		}
	}
	arrayappend(arrTSV, "Listing Count"&chr(10));
	writeoutput('<th>Listing Count</th>');
	writeoutput('<tr>');
	</cfscript>
        
	<cfloop query="qResult">
    <cfscript>
	arrRow=arraynew(1);
	arrTSVRow=arraynew(1);
	arrayappend(arrRow,'<tr>');
	skiprow=false;
	for(i=1;i LTE 5;i++){
		c2=application.zcore.functions.zso(form, 'groupfield'&i);
		if(c2 NEQ ""){
			// have to convert the value based on c2 field name.
			if(structkeyexists(lookupStruct, c2)){
				c3=application.zcore.listingCom.listingLookupValue(lookupStruct[c2],qResult["value"&i]);	
				// exclude again here because it was translated
				c4=application.zcore.functions.zso(form, 'excludekeywords'&i);
				if(c4 NEQ ""){
					a4=listtoarray(c4,",");
					match=false;
					for(i2=1;i2 LTE arraylen(a4);i2++){
						if(c3 CONTAINS a4[i2]){
							match=true;
							break;
						}
					}
					if(match){
						skiprow=true;
						break;
					}
				}
			}else{
				c3=qResult["value"&i];
			}
			if(c2 EQ "listing_city"){
				if(structkeyexists(request.zos.listing.cityNameStruct, c3)){
					c3=request.zos.listing.cityNameStruct[c3];
					c4=application.zcore.functions.zso(form, 'excludekeywords'&i);
					if(c4 NEQ ""){
						a4=listtoarray(c4,",");
						match=false;
						for(i2=1;i2 LTE arraylen(a4);i2++){
							if(c3 CONTAINS a4[i2]){
								match=true;
								break;
							}
						}
						if(match){
							skiprow=true;
							break;
						}
					}
				}
			}
			arrayappend(arrTSVRow, c3&chr(9));
			arrayappend(arrRow,'<td>'&c3&'</td>');
		}
	}
	if(skiprow EQ false){
		writeoutput(arraytolist(arrRow,"")&'<td>#qResult.count#</td></tr>');
		arrayappend(arrTSV, arraytolist(arrTSVRow, "")&qResult.count&chr(10));
	}else{
		//writeoutput('<tr><td>skip</td>	</tr>');
	}
	</cfscript></cfloop>
    </table>
    <hr />
    <h2>Spreadsheet Format (Copy and paste the text below into a spreadsheet editor.)</h2>
    <textarea name="excelformat" cols="100" rows="10"><cfscript>
	writeoutput(arraytolist(arrTSV,""));
    </cfscript></textarea>
</cfif>
</cffunction>
</cfoutput>
</cfcomponent>