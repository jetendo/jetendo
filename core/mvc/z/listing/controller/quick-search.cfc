<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfscript>
var theFinalHTML=0;
var ts=0;
application.zcore.functions.zHeader("Content-type", "text/javascript");
application.zcore.tracking.backOneHit();</cfscript>
<cfsavecontent variable="request.theSearchFormTemplate">
<style>
.quicksearchtable{font-family:Verdana, Geneva, sans-serif; font-size:14px;}
.quicksearchtable select{ margin:0px; font-size:13px; line-height:14px;}
.quicksearchtable > td{ padding:3px;}
.quicksearchrow1 table{padding:0px; margin:0px; border-spacing:0px;}
.quicksearchrow1 table td{padding:0px;  } 
.quicksearchrow1 td{padding:3px; vertical-align:top;}
.quicksearchrow2 td{padding:3px; vertical-align:top;}
</style>
<form name="quickSearchForm" id="quickSearchForm" action="#request.zos.currentHostName###searchFormSubmitURL##" target="_blank" method="post">
<script>/* <![CDATA[ */ zArrDeferredFunctions.push(function(){zFormData["zMLSSearchForm"]=new Object(); zFormData["zMLSSearchForm"].arrFields=[]; });/* ]]> */</script>
<table class="quicksearchtable">
<tr>
<td style="font-size:18px; font-weight:bold; line-height:24px; padding-bottom:10px;" colspan="2">Real Estate Search</td>
</tr>
<tr class="quicksearchrow1">
<!--- <td>City:</td> --->
<td>##search_city_id##</td>
<!--- <td>Beds:</td> --->
<td>##search_bedrooms##</td>
<!--- <td rowspan="4" style="vertical-align:middle; width:180px; text-align:center;">
<input type="image" src="/images/shell5/search_03.jpg" width="124" height="40" /><br /><br />
	<a href="##searchFormAdvancedURL##">Advanced Search</a>
</td> --->
</tr>
<tr class="quicksearchrow1">
<!--- <td>Type:</td> --->
<td>##search_listing_type_id##</td>
<!--- <td>Baths:</td> --->
<td>##search_bathrooms##</td>
</tr>
<tr class="quicksearchrow2">
<!--- <td rowspan="2">Price:</td> --->
<td>##search_rate_low##</td>
<!--- <td rowspan="2">SQFT:</td> --->
<td>##search_rate_high##</td>
</tr>
<tr><td colspan="2" style="padding-top:10px;"><input type="submit" name="searchSubmit" value="Search Listings" style="font-size:16px; font-weight:bold; padding:5px;" /> </td></tr>
</table>
</form>
<!--- search_bathrooms,search_year_built,search_sqfoot,search_city_id,search_status,search_near_address,search_listing_type_id,search_listing_sub_type_id,search_view,search_bedrooms,search_county,search_more_options,search_rate,search_style,search_frontage,search_acreage,search_rate_low,search_rate_high

---> 
</cfsavecontent>
<cfsavecontent variable="theFinalHTML">
<cfscript>
ts=structnew();
ts.output=true;
ts.javascript=true;
ts.searchFormLabelOnInput=true;
ts.searchFormEnabledDropDownMenus=true;
ts.searchFormHideCriteria=structnew();
ts.searchFormHideCriteria["more_options"]=true;
application.zcore.listingCom.includeSearchForm(ts);
</cfscript>
</cfsavecontent>
<cfscript>
request.znotemplate=true;
writeoutput('document.write("'&jsstringformat(theFinalHTML)&'");');
</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>