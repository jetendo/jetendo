<cfcomponent>
<cfoutput>
<!---  
need to convert the z-index stuff to be elements at end of body because maimone and others have things in z-index interferring.

Future:
need light and dark theme
integrate geolocation (when https is on) 
add school search

 --->
<cffunction name="index"  localmode="modern" access="remote">

	<div class="z-float z-pt-140">

	</div>
	<div class="z-float" style="padding-top:50px; padding-bottom:50px;">
		<div class="z-container">
			<cfscript>
			ts={
				enableGeolocation:false,
				enableNeighborhoods:true,
				enableSchools:false,
				enableFeature:false
			};
			includeQuickSearch(ts);
			</cfscript>
		</div>
	</div>
</cffunction>

<!--- 
ts={
	enableGeolocation:false,
	enableCities:true,
	enableNeighborhoods:true,
	enableAddress:true,
	enableMLSNumber:true,
	enableSchools:false,
	enableZipCode:true,
	enableCounty:true,
	enableKeyword:true,
	enableFeature:true,
	jumpNegativeOffset:{
		479:-100,
		767:-100,
		992:-50,
		default:-30
	}
};
quickSearchCom=createobject("component", "zcorerootmapping.mvc.z.listing.controller.quick-search-autocomplete");
quickSearchCom.includeQuickSearch(ts);
 --->
<cffunction name="includeQuickSearch"  localmode="modern" access="public"> 
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	if(not structkeyexists(request.zos, 'quickSearchAutocompleteIncluded')){
		request.zos.quickSearchAutocompleteIncluded=true;
		application.zcore.skin.includeJS("/z/a/listing/quick-search.js");
		application.zcore.skin.includeCSS("/z/a/listing/stylesheets/quick-search.css");
	}
	ss=arguments.ss;
	ts={
		enableGeolocation:true,
		enableCities:true,
		enableNeighborhoods:true,
		enableAddress:true,
		enableMLSNumber:true,
		enableSchools:true,
		enableZipCode:true,
		enableCounty:true,
		enableKeyword:true,
		enableFeature:true,
		jumpNegativeOffset:{
			bp479:-60,
			bp767:-30,
			bp992:-30,
			bp1362:-30,
			default:-30
		}
	};
	structappend(ss, ts, false);
	structappend(ss.jumpNegativeOffset, ts.jumpNegativeOffset, false);
	arrType=[];
	if(ts.enableNeighborhoods){
		arrayAppend(arrType, "neighborhood");
	}
	if(ts.enableCities){
		arrayAppend(arrType, "city");
	}
	if(ts.enableAddress){
		arrayAppend(arrType, "address");
	}
	if(ts.enableMLSNumber){
		arrayAppend(arrType, "listing_id");
	}
	if(ts.enableSchools){
		arrayAppend(arrType, "school");
	}
	if(ts.enableCounty){
		arrayAppend(arrType, "county");
	}
	if(ts.enableZipCode){
		arrayAppend(arrType, "zip");
	}
	if(ts.enableFeature){
		arrayAppend(arrType, "feature");
	}
	if(ts.enableKeyword){
		arrayAppend(arrType, "keyword");
	}
	geolocation=false;
	</cfscript> 
	<div class="zls-quick-search-mode-container">
		<div class="zls-quick-search-mode-container2">
			<div class="z-float">
				<a class="zls-quick-search-mode-button">Search By <span class="zls-quick-search-mode-arrow-down"> </span></a>
				<form id="z-quick-search-form" action="" method="get">
				  	<input id="zls-quick-search-mode-input" data-negative-offset="#htmleditformat(serializeJson(ss.jumpNegativeOffset))#" class="zls-quick-search-mode-input" style="" type="text" name="query" id="query" placeholder="Type a City, County, MLS ##, <cfif ss.enableAddress>Address, </cfif><Cfif ss.enableZipCode>ZIP Code, </cfif><Cfif ss.enableSchools>School, </cfif>etc" autocomplete="off">
				  	<input type="button" name="quickSearchButton1" value="SEARCH" class="zls-quick-search-mode-search">
				</form>
				
			</div>
		</div> 
	</div> 
	<script id="zls-quick-search-html-pop" type="text/template">
		<div class="zls-quick-search-autocomplete-container">
		  	<div class="zls-quick-search-autocomplete"> 
		  	</div>
		</div>
		<div class="zls-quick-search-list-container">
			<div class="zls-quick-search-list"> 
				<a href="##" class="zls-quick-search-link zls-quick-search-link-selected " data-type="#arrayToList(arrType, ",")#" data-placeholder="Type a City, County, MLS ##, <cfif ss.enableAddress>Address, </cfif><Cfif ss.enableZipCode>ZIP Code, </cfif><Cfif ss.enableSchools>School, </cfif>etc">SEARCH: All</a>
				<cfif ss.enableGeolocation>
					<a href="##" class="zls-quick-search-link" data-type="nearby" data-placeholder="Grabbing your location">Nearby Me</a>
				</cfif> 
				<cfif ss.enableCities>
					<a href="##" class="zls-quick-search-link" data-type="city" data-placeholder="Type any City">Cities</a>
				</cfif>
				<cfif ss.enableNeighborhoods>
					<a href="##" class="zls-quick-search-link" data-type="neighborhood" data-placeholder="Type Any Neighborhood">Neighborhoods</a>
				</cfif>
				<cfif ss.enableSchools>
					<a href="##" class="zls-quick-search-link" data-type="school" data-placeholder="Type any School">Schools</a>
				</cfif>
				<cfif ss.enableCounty>
					<a href="##" class="zls-quick-search-link" data-type="county" data-placeholder="Type any County">County</a>
				</cfif>
				<cfif ss.enableAddress>
					<a href="##" class="zls-quick-search-link" data-type="address" data-placeholder="Type any Address">Address</a>
				</cfif>
				<cfif ss.enableMLSNumber>
					<a href="##" class="zls-quick-search-link" data-type="listing_id" data-placeholder="Type any MLS##">MLS##</a>
				</cfif>
				<cfif ss.enableZipCode>
					<a href="##" class="zls-quick-search-link" data-type="zip" data-placeholder="Type any Zip Code">Zip Code</a>
				</cfif>
				<cfif ss.enableFeature>
					<a href="##" class="zls-quick-search-link" data-type="feature" data-placeholder="Type any Feature">Feature</a> 
				</cfif>
				<cfif ss.enableKeyword>
					<a href="##" class="zls-quick-search-link" data-type="keyword" data-placeholder="Type any Keyword">Keyword</a>
				</cfif>
			</div>
		</div>
	</script>
</cffunction>

<cffunction name="autocompleteSearch" localmode="modern" access="remote" returntype="string">
	<cfscript>
	form.keyword=application.zcore.functions.zso(form, 'keyword'); 
	rs={
		success:true,
		arrOrder:["neighborhood", "city", "county", "address", "zip", "school", "feature", "listing_id", "keyword"],
		arrLabel:["Neighborhood", "Cities", "County", "Address", "ZIP Code", "Schools", "Feature", "MLS ##", "Keyword"],
		neighborhood:[],
		city:[],
		county:[],
		address:[],
		zip:[],
		school:[],
		listing_id:[],
		feature:[],
		keyword:[{label:form.keyword, value:form.keyword, field:"search_remarks"}]
	};
	arrSearchType=listToArray(form.searchType, ",");
	searchTypeStruct={};
	for(i in arrSearchType){
		searchTypeStruct[i]=true;
	} 
	if(structkeyexists(searchTypeStruct, 'city')){
		getCityData(form.keyword, rs); 
	}
	if(structkeyexists(searchTypeStruct, "county")){
		getCountyData(form.keyword, rs); 
	}
	if(structkeyexists(searchTypeStruct, "neighborhood")){
		getNeighborhoodData(form.keyword, rs); 
	}
	if(structkeyexists(searchTypeStruct, "school")){
		getSchoolData(form.keyword, rs); 
	}	
	if(structkeyexists(searchTypeStruct, "address")){
		getAddressKeyword(form.keyword, rs); 
	}
	if(structkeyexists(searchTypeStruct, "zip")){
		getZipData(form.keyword, rs); 
	}
	if(structkeyexists(searchTypeStruct, "feature")){
		getFeature(form.keyword, rs); 
	}
	if(structkeyexists(searchTypeStruct, "listing_id")){
		getMLSData(form.keyword, rs); 
	}		
 
	application.zcore.functions.zReturnJson(rs); 
	</cfscript>
</cffunction>	

<cffunction name="listingSQLFilter" localmode="modern" access="public" returntype="string">
	<cfargument name="db" type="component" required="yes" />
	<cfscript>
	db=arguments.db;
	</cfscript>
	<cfsavecontent variable="filter">
		and listing_deleted = #db.param(0)# and 
	    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
    	listing_city not in #db.trustedSQL("('','0','#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#')")#
    	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> 
    		and listing_status LIKE #db.param('%,7,%')# 
    	</cfif>
    	<cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> 
    		#db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# 
    	</cfif>
    </cfsavecontent>
    <cfreturn filter>
</cffunction>

<cffunction name="getCountyData" localmode="modern" access="public" returntype="string">
	<cfargument name="keyword" type="string" required="true" >
	<cfargument name="rs" type="struct" required="true" >
    <cfscript>
    rs=arguments.rs;
	db 		= request.zos.queryObject;
	</cfscript>	
    <cfsavecontent variable="db.sql">
	    SELECT distinct listing_county
		from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
		WHERE  #db.param(1)# = #db.param(1)# 
    	#listingSQLFilter(db)#
	LIMIT #db.param(0)#, #db.param(10)#
    </cfsavecontent>
	<cfscript>
	qType 	= db.execute("qType"); 
	ts 	= {}; 
	for(row in qType){
		var sCounty = application.zcore.listingCom.listingLookupValue("county", row.listing_county);

		if(sCounty CONTAINS arguments.keyword){ 
			ts[row.listing_county]={value:row.listing_county, label:sCounty, field:"search_county"};
		}
	}	 
	arrKey=structSort(ts, "text", "asc", "label");
	for(key in arrKey){
		arrayAppend(rs.county, ts[key]);
	}
	</cfscript>
</cffunction>	

<cffunction name="getCityData" localmode="modern" access="public" returntype="string">
	<cfargument name="keyword" type="string" required="true" />
	<cfargument name="rs" type="struct" required="true" >
    <cfscript>
    rs=arguments.rs;
		db 		= request.zos.queryObject;
	</cfscript>
	<cfsavecontent variable="db.sql">
	    SELECT cast(group_concat(distinct listing_city SEPARATOR #db.trustedSQL("','")#) AS CHAR) idlist 
		from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
		WHERE #db.param(1)# = #db.param(1)# 
    	#listingSQLFilter(db)#
	LIMIT #db.param(0)#, #db.param(10)#
    </cfsavecontent>
    <cfscript>
	qType=db.execute("qType");
	if(qType.idlist NEQ ""){
		db.sql="select city_x_mls.city_name label, city_x_mls.city_id value 
		from #db.table("city_x_mls", request.zos.zcoreDatasource)# city_x_mls 
		WHERE city_x_mls.city_id IN (#db.trustedSQL(qtype.idlist)#)and 
		#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))#  and 
		city_id NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#)  and 
		city_x_mls_deleted = #db.param(0)# and 
		city_x_mls.city_name LIKE #db.param('%#arguments.keyword#%')# 
		ORDER BY label ASC ";
		qCity=db.execute("qCity");
		for(row in qCity){
			arrRec 	= [];
			cityUnq	= {};
    		if(structkeyexists(cityUnq,row.label) EQ false){
    			cityUnq[qCity.label] =true;
				arrayAppend(rs.city, {label:row.label, value: row.value, field:"search_city_id"}); 
    		}
		}
	}
	</cfscript> 
</cffunction>	

<cffunction name="getAddressKeyword" localmode="modern" access="public" returntype="string">
	<cfargument name="keyword" type="string" required="true" />
	<cfargument name="rs" type="struct" required="true" />
    <cfscript>
    rs=arguments.rs;
	db 		= request.zos.queryObject;
	db.sql="SELECT DISTINCT listing_address 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE  
	listing_address like #db.param('%#arguments.keyword#%')#
	#listingSQLFilter(db)#
	LIMIT #db.param(0)#, #db.param(10)#";
	qType=db.execute("qType");
	arrData=[];
	for(row in qType){
		if(row.listing_address NEQ ""){
			arrayAppend(arrData, row.listing_address);
		}
	}
	arraySort(arrData, "text", "asc");
	for(address in arrData){
		arrayAppend(rs.address, {label:address, value: address, field:"search_address"});
	}
	</cfscript>
</cffunction>	

<cffunction name="getZipData" localmode="modern" access="public" returntype="string">
	<cfargument name="keyword" type="string" required="true" />
	<cfargument name="rs" type="struct" required="true" />
    <cfscript>
    rs=arguments.rs;
	db 		= request.zos.queryObject;
	db.sql="SELECT DISTINCT listing_zip 
		from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
		WHERE listing_zip LIKE #db.param('%#arguments.keyword#%')# 
    	#listingSQLFilter(db)#
	LIMIT #db.param(0)#, #db.param(5)#";
	qType=db.execute("qType");
	for(row in qType){
		if(row.listing_zip NEQ ""){
			arrayAppend(rs.zip, {label:row.listing_zip, value: row.listing_zip, field:"search_zip"});
		}
	}
	</cfscript> 
</cffunction>	

<cffunction name="getMLSData" localmode="modern" access="public" returntype="string">
	<cfargument name="keyword" type="string" required="true" />
	<cfargument name="rs" type="struct" required="true" />
    <cfscript>
    rs=arguments.rs;
		db 		= request.zos.queryObject;
	db.sql="SELECT DISTINCT listing_id
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
	listing_id like #db.param('%-'&arguments.keyword)# 
	#listingSQLFilter(db)#
	LIMIT #db.param(0)#, #db.param(3)#
	"; 
	qType=db.execute("qType");
	for(row in qType){ 
		id=listGetAt(row.listing_id, 2, '-');
		arrayAppend(rs.listing_id, {label:id, value: id, field:"search_mls_number_list"}); 
	}
	</cfscript>  
</cffunction>	

<cffunction name="getFeature" localmode="modern" access="public" returntype="string">
	<cfargument name="keyword" type="string" required="true" />
	<cfargument name="rs" type="struct" required="true" />
    <cfscript>
    rs=arguments.rs;
	db 		= request.zos.queryObject;
	db.sql="SELECT DISTINCT listing_frontage 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE  #db.param(1)# = #db.param(1)#
	#listingSQLFilter(db)#  
	LIMIT #db.param(0)#, #db.param(10)# "; 
	qType 	= db.execute("qType");  
	for(row in qType){
		arrFeature=listToArray(row.listing_frontage, ",");
		for(featureId in arrFeature){
			if(featureId NEQ ""){
				feature = application.zcore.listingCom.listingLookupValue("frontage", featureId);
				if(feature CONTAINS arguments.keyword){
					arrayAppend(rs.feature, {label:feature, value: featureId, field:"search_frontage"}); 
				}
			}
		}
	}
	db.sql="SELECT DISTINCT listing_view 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing  
	WHERE  #db.param(1)# = #db.param(1)#
	#listingSQLFilter(db)#  
	LIMIT #db.param(0)#, #db.param(10)# ";
	qType 	= db.execute("qType"); 
	for(row in qType){
		arrFeature=listToArray(row.listing_view, ",");
		for(featureId in arrFeature){
			if(featureId NEQ ""){
				feature = application.zcore.listingCom.listingLookupValue("view", featureId);
				if(feature CONTAINS arguments.keyword){
					arrayAppend(rs.feature, {label:feature, value: featureId, field:"search_view"}); 
				}
			}
		}
	}
	db.sql="SELECT DISTINCT listing_style 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing  
	WHERE  #db.param(1)# = #db.param(1)#
	#listingSQLFilter(db)#  
	LIMIT #db.param(0)#, #db.param(10)# ";
	qType 	= db.execute("qType"); 
	for(row in qType){
		arrFeature=listToArray(row.listing_style, ",");
		for(featureId in arrFeature){
			if(featureId NEQ ""){
				feature = application.zcore.listingCom.listingLookupValue("style", featureId);
				if(feature CONTAINS arguments.keyword){
					arrayAppend(rs.feature, {label:feature, value: featureId, field:"search_style"}); 
				}
			}
		}
	}
	</cfscript>
</cffunction>	

<cffunction name="getNeighborhoodData" localmode="modern" access="public" returntype="string">
	<cfargument name="keyword" type="string" required="true" />
	<cfargument name="rs" type="struct" required="true" />
    <cfscript>
    rs=arguments.rs;
	db 		= request.zos.queryObject;
	db.sql="SELECT DISTINCT listing_subdivision 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
	listing_subdivision LIKE #db.param('%#arguments.keyword#%')# 
	#listingSQLFilter(db)# 
	ORDER BY listing_subdivision ASC 
	LIMIT #db.param(0)#, #db.param(10)# ";
	qType 	= db.execute("qType"); 
	for(row in qType){
		arrayAppend(rs.neighborhood, {label:row.listing_subdivision, value: row.listing_subdivision, field:"search_subdivision"}); 
	}
	</cfscript>
</cffunction>	

<cffunction name="getSchoolData" localmode="modern" access="public" returntype="string">
	<cfargument name="keyword" type="string" required="true" />
	<cfargument name="rs" type="struct" required="true" />
    <cfscript>
    rs=arguments.rs;
	db 		= request.zos.queryObject;
	db.sql="SELECT DISTINCT listing_subdivision 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE  
	listing_subdivision LIKE #db.param('%#arguments.keyword#%')#

	#listingSQLFilter(db)# 
	ORDER BY listing_subdivision ASC 
	LIMIT #db.param(0)#, #db.param(10)# ";
	qType 	= db.execute("qType"); 
	for(row in qType){
		arrayAppend(rs.neighborhood, {label:row.listing_subdivision, value: row.listing_subdivision, field:"search_subdivision"}); 
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
