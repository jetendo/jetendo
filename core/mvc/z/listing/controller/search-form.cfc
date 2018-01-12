<!--- 

This query is twice as fast for getting the search sidebar values, but we're not using it yet because query caching is enabled:
SELECT 
CAST(GROUP_CONCAT(DISTINCT listing_type_id SEPARATOR #db.param(',')#) AS CHAR) idlistType,
CAST(GROUP_CONCAT(DISTINCT listing_sub_type_id SEPARATOR #db.param(',')#) AS CHAR) idlistSubType, 
CAST(GROUP_CONCAT(DISTINCT listing_county SEPARATOR #db.param(',')#) AS CHAR) idlistCounty, 
CAST(GROUP_CONCAT(DISTINCT listing_view SEPARATOR #db.param(',')#) AS CHAR) idlistView,
CAST(GROUP_CONCAT(DISTINCT listing_status SEPARATOR #db.param(',')#) AS CHAR) idlistStatus,
CAST(GROUP_CONCAT(DISTINCT listing_style SEPARATOR #db.param(',')#) AS CHAR) idlistStyle,
CAST(GROUP_CONCAT(DISTINCT listing_frontage SEPARATOR #db.param(',')#) AS CHAR) idlistFrontage,
MAX(listing_beds) hasBeds,
MAX(listing_baths) hasBaths, 
MAX(listing_square_feet) hasSqfeet, 
MAX(listing_acreage) hasAcreage, 
MAX(listing_condoname) hasCondos 
 FROM `listing_memory` FORCE INDEX (NewIndex2) 
WHERE 
`listing_memory`.listing_mls_id IN ('4','7','12','9','13','8') ;


DUPLICATE ADDRESSES
select cast(group_concat(listing_id SEPARATOR #db.param(',')#) as char) idlist, count(listing_id) c from listing_data 
WHERE listing_data_address <> #db.param('')# and 
listing_data_zip <> #db.param('')# group by listing_data_address, listing_data_zip having(c>=2);

Landing Pages:
Property Type
City Name
subdivision
Price
county 
year built
taxes
hoa fees 
sale type
style
financial

automating the directory system which hasn't been started.
TABLE: mls_dir
mls_dir_id=auto
mls_dir_name="City"
mls_dir_field_name="mls_city"
mls_dir_random_type="city"
mls_dir_random_title_type="city_title"
mls_dir_cache_enabled=0 (determines whether to run indexing service to eliminate full text searching and speed up application.  data gets stored in separate mls_dir_meta table
mls_dir_cache_field_name="city" (field in listing table used to store additional information)
mls_dir_cache_include=
mls_dir_fulltext_enabled=0 (determine whether to find this in listing's full text or just the exact field)
mls_dir_fulltext_match="#city#"
mls_dir_fulltext_exclude="not in #city#"

TABLE: mls_dir_meta
mls_dir_id="4"
listing_id="12313"
mls_dir_meta_name="city"
mls_dir_meta_value="Ormond Beach"

implementing seo / mls_dir directory:
map to database fields to lookup the values and check for matching listings
map to sentence type for paragraph and title to generate random text

outline how live google maps would function
maxHomesDisplayed=30;
after map is dragged, get the new coordinates and send the new and old coordinates to coldfusion via ajax.

determine which points are outside the map (& delete them)
	run 

latDistanceInMiles=100;
longDistanceInMiles=100;
latDegrees=latDistanceInMiles/69; 
longDegrees=longDistanceInMiles/69;
	
SELECT zipcode.*, 
						ROUND((ACOS((SIN(#qZip.zipcode_latitude#/57.2958) * SIN(zipcode_latitude/57.2958)) + (COS(#qZip.zipcode_latitude#/57.2958) * COS(zipcode_latitude/57.2958) * COS(zipcode_longitude/57.2958 - #qZip.zipcode_longitude#/57.2958)))) * 3963, 0) AS distance, `city_memory`.city_id 
						FROM `#request.zos.zcoreDatasource#`.zipcode, city 
						WHERE 
						`city_memory`.city_name = zipcode.city_name and 
						`city_memory`.state_abbr = zipcode.state_abbr and 
						`city_memory`.country_code = zipcode.country_code  and 
						`city_memory`.country_code = 'US' and 
						`city_memory`.city_id <> #db.param(city_parent_id)# and 
						
						(zipcode_latitude >= #qZip.zipcode_latitude - latDistance#)
						AND (zipcode_latitude <= #qZip.zipcode_latitude + latDistance#)
						AND (zipcode_longitude >= #qZip.zipcode_longitude - longDistance#)
						AND (zipcode_longitude <= #qZip.zipcode_longitude + longDistance#)
						ORDER BY zipcode.city_name, zipcode.state_abbr, zipcode_zip, distance 

 --->
 <cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	application.zcore.session.forceEnable();
	db=request.zos.queryObject; 
	var returnStruct={count:0};
	var mapQuery={}; 

	application.zcore.functions.zNoCache();

	application.zcore.functions.zDisbleEndFormCheck();
	if(structkeyexists(form,'showLastSearch') and isDefined('request.zsession.tempVars.zListingSearchId')){
		form.searchId=request.zsession.tempVars.zListingSearchId;
		form.zIndex=application.zcore.status.getField(form.searchId, "zIndex",1);
	}
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		writeoutput('.<!-- stop spamming -->');
		application.zcore.functions.zabort();
	}
	if(request.cgi_script_name EQ '/z/listing/search-form/index'){
		application.zcore.template.settag("title","Search Results");
		application.zcore.template.settag("pagetitle","Search Results");
	}
	if(structkeyexists(form, 'debugSearchForm') and form.debugSearchForm){
		form.debugSearchForm=true;	
	}else{
		form.debugSearchForm=false;
	}
	if(structkeyexists(form, 'debugSearchResults') and form.debugSearchResults){
		form.debugSearchResults=true;	
	}else{
		form.debugSearchResults=false;
	}
	form.searchFormLabelOnInput=application.zcore.functions.zso(form, 'searchFormLabelOnInput',false,false); 
	form.searchFormSelectWidth="100%";
	form.searchFormEnabledDropDownMenus=application.zcore.functions.zso(form, 'searchFormEnabledDropDownMenus',false,false);
	form.searchDisableExpandingBox=application.zcore.functions.zso(form, 'searchDisableExpandingBox',false,false);
	if(isboolean(form.searchFormEnabledDropDownMenus) EQ false){
		form.searchFormEnabledDropDownMenus=false;
	}
	form.action=application.zcore.functions.zso(form, 'action',false,'form');
	if(application.zcore.app.siteHasApp("listing") EQ false){
		application.zcore.functions.z301redirect('/');
	}

	form.search_listdate=application.zcore.functions.zso(form, 'search_listdate');
	
	</cfscript>
</cffunction>
<cffunction name="nearAddress" localmode="modern" access="remote">
	<cfscript>
	init();
	search_near_address=trim(application.zcore.functions.zso(form, 'search_near_address'));
	if(search_near_address EQ ""){
		application.zcore.functions.z404("Invalid request - search_near_address is required");
	}
	application.zcore.functions.z404("this can't depend on zGetLatLong anymore. need to make it use client side geocoding.");
	application.zcore.tracking.backOneHit();
	// /z/listing/search-form/nearAddress?search_near_address=113 Mariners Dr, Ormond Beach, FL&seach_near_radius=0.5
	lat=0;
	long=0;

	ts=structnew();
	ts.debug=false;
	ts.address=search_near_address;
	rs5=request.zos.listing.functions.zGetLatLong(ts);
	if(rs5.error){
		jsonText=('{"success":false,"errorMsg":"#rs5.errorMessage#\nAddress not found.  Please type a complete, valid address and try again."}');
	}else{
		lat=rs5.latitude;
		long=rs5.longitude;
	}
		
	// calculate radius and make lat/long box
	if(lat NEQ 0 and long NEQ 0){
		// 1 degree is 69.047 miles.
		degreeConstant=69.047;
		latRatio=search_near_radius/degreeConstant;
		longRatio=latRatio*cos(latRatio);
		minLat=lat-(latRatio/2);
		maxLat=lat+(latRatio/2);
		minLong=long-(longRatio/2);
		maxLong=long+(longRatio/2);
		arrMap2=["minLongitude","maxLongitude","minLatitude","maxLatitude"];
		form.search_map_coordinates_list="#minLong#,#maxLong#,#minLat#,#maxLat#";
		jsonText=('{"success":true,"errorMsg":"","search_map_coordinates_list":"#form.search_map_coordinates_list#"}');
	}else{
		jsonText=('{"success":false,"errorMsg":"Address not found.  Please type a complete, valid address and try again."}');	
	}
	if(structkeyexists(form, 'x_ajax_id') EQ false){
		abort;
	}
	savecontent variable="out"{
		echo(jsonText);
	}
	header name="x_ajax_id" value="#form.x_ajax_id#";
	echo(out);
	abort;
	</cfscript>
</cffunction>

<cffunction name="nearCoordinates" localmode="modern" access="remote">
	<cfscript>
	init();
	search_near_coordinates=trim(application.zcore.functions.zso(form, 'search_near_coordinates'));
	if(search_near_coordinates EQ ""){
		application.zcore.functions.z404("Invalid request - search_near_coordinates is required");
	}
	// application.zcore.functions.z404("this can't depend on zGetLatLong anymore. need to make it use client side geocoding.");
	// application.zcore.tracking.backOneHit();

	coords = listToArray( search_near_coordinates, ',' );

	lat = coords[1];
	long = coords[2];

	// calculate radius and make lat/long box
	if(lat NEQ 0 and long NEQ 0){
		// 1 degree is 69.047 miles.
		degreeConstant=69.047;
		latRatio=form.search_near_radius/degreeConstant;
		longRatio=latRatio*cos(latRatio);
		minLat=lat-(latRatio/2);
		maxLat=lat+(latRatio/2);
		minLong=long-(longRatio/2);
		maxLong=long+(longRatio/2);
		arrMap2=["minLongitude","maxLongitude","minLatitude","maxLatitude"];
		form.search_map_coordinates_list="#minLong#,#maxLong#,#minLat#,#maxLat#";
		jsonText=('{"success":true,"errorMsg":"","search_map_coordinates_list":"#form.search_map_coordinates_list#"}');
	}else{
		jsonText=('{"success":false,"errorMsg":"Address not found.  Please type a complete, valid address and try again."}');	
	}
	if(structkeyexists(form, 'x_ajax_id') EQ false){
		abort;
	}
	savecontent variable="out"{
		echo(jsonText);
	}
	header name="x_ajax_id" value="#form.x_ajax_id#";
	echo(out);
	abort;
	</cfscript>
</cffunction>

<cffunction name="ajaxMapListing" localmode="modern" access="remote">
	<cfscript>
	init();
	var propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData"); 
	var propDisplayCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
	application.zcore.tracking.backOneHit();
	if(structkeyexists(form, 'x_ajax_id') EQ false){
		abort;
	}
	start=gettickcount();
	form.zIndex=application.zcore.functions.zso(form, 'zIndex',false,1);
	form.zIndex=max(form.zIndex,1); 
	structdelete(form,'fieldnames'); 
	for(i in form){
		form[i]=urldecode(form[i]);	
	}
	ts = StructNew();
	ts.offset = form.zIndex-1;
	perpageDefault=10;
	perpage=10;
	perpage=max(1,min(perpage,100));
	ts.perpage = perpage;
	ts.distance = 30; // in miles
	ts.arrMLSPId=[form.listing_id];
	if(form.debugSearchForm){
		ts.debug=true;
	}
	propertyDataCom.setSearchCriteria(form);
	returnStruct = propertyDataCom.getProperties(ts);
	
	request.currentmappropertylink="";
	ts = StructNew();
	ts.baseCity = 'db';
	ts.datastruct = returnStruct;
	ts.searchScript=false;
	ts.compact=true;
	ts.mapFormat=true;
	propDisplayCom.init(ts);

	// inputStruct should contain all search parameters. (on daytona beach page, this would only be city_name and state_abbr)
	theHTML =propDisplayCom.displayTop();
	
	jsonText='{"loadtime":"#((gettickcount()-start)/1000)# seconds","COUNT":#returnStruct.count#,"success":true,"link":"#request.currentmappropertylink#","html":"#jsstringformat(theHTML)#"}';
	savecontent variable="out"{
		echo(jsonText);
	}
	header name="x_ajax_id" value="#form.x_ajax_id#";
	echo(out);
	abort;
	</cfscript>
</cffunction>

<cffunction name="ajaxCount" localmode="modern" access="remote">
	<cfscript>
	init();

	var propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData"); 
	var propDisplayCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
	for(i in form){
		if(left(i, 7) EQ "search_" and isSimpleValue(form[i]) and form[i] EQ 0){
			form[i]='';
		}
	}
	application.zcore.functions.zHeader("x_ajax_id", application.zcore.functions.zso(form, 'x_ajax_id'));
	application.zcore.tracking.backOneHit();
	start=gettickcount();
	form.zIndex=application.zcore.functions.zso(form, 'zIndex',false,1);
	form.zIndex=max(form.zIndex,1);
	structdelete(form,'fieldnames');
	for(i in form){
		form[i]=urldecode(form[i]);	
	}
	ts = StructNew();
	ts.offset = form.zIndex-1;
	perpageDefault=10;
	perpage=10;
	perpage=max(1,min(perpage,100));
	ts.perpage = perpage;
	ts.distance = 30; // in miles
	if(form.debugSearchForm){
		ts.debug=true;
	}
	ts.onlyCount=true;
	ts.contentTableEnabled=false;
	if(structcount(form) EQ 0 and structkeyexists(form, 'searchId')){
		tempStruct=duplicate(application.zcore.status.getStruct(form.searchid).varStruct);
		structappend(form,tempStruct,true);
	} 
	if(structkeyexists(form,'mapfullscreen')){
		ts.zselect="count(listing.listing_id), MIN(listing.listing_latitude) minLat, MAX(listing.listing_latitude) maxLat, MIN(listing.listing_longitude) minLong, MAX(listing.listing_longitude) maxLong";
		ts.zwhere="and listing_latitude<> '0' and 
		listing_longitude<>'0'";
	}
	propertyDataCom.setSearchCriteria(form);
	returnStruct2 = propertyDataCom.getProperties(ts);

	if(structkeyexists(form,'mapfullscreen')){
		structdelete(ts,'zselect');
		structdelete(ts,'zwhere');
		structdelete(ts,'contentTableEnabled');
	}
	if(structkeyexists(form,'zforcemapresults') EQ false and ((application.zcore.functions.zso(form, 'search_map_coordinates_list') EQ "" or application.zcore.functions.zso(form, 'mapNotAvailable') EQ 1) or (isDefined('request.zsession.zListingHideMap') and request.zsession.zListingHideMap EQ true))){
		fs='';
		if(returnStruct2.count EQ 0){
			fs&='"errorMessage":"#jsstringformat(returnStruct2.errorMessage)#", ';
		}
		jsonText='{#fs#"loadtime":"#((gettickcount()-start)/1000)# seconds","COUNT":#returnStruct2.count#,"success":true}';
	}else{
		ts.zReturnSimpleQuery=true;
		ts.disableCount=true;
		
		form.search_within_map=1;
		propertyDataCom.setSearchCriteria(form);
		ts.onlyCount=false;
			
			
		arrMap=listtoarray(form.search_map_coordinates_list);
		arrMap2=["minLongitude","maxLongitude","minLatitude","maxLatitude"];
		mapCoor=structnew();
		mapFail=false;
		if(arraylen(arrMap) EQ 4){
			for(i=1;i LTE arraylen(arrMap);i++){
				if(isnumeric(arrMap[i])){
					mapCoor[arrMap2[i]]=arrMap[i];
				}else{
					break;	
				}
			}
		}
		if(structcount(mapCoor) LT 4){
			jsonText='{"loadtime":"#((gettickcount()-start)/1000)# seconds","COUNT":0,"success":false,"errorMessage":"invalid request - mapping should be disabled (1): #form.search_map_coordinates_list#"}';
			echo(jsonText);
			abort;
		}
		ts.searchMapCoordinates=mapCoor;
		if(application.zcore.functions.zso(form, 'search_map_long_blocks',true) NEQ 0 and application.zcore.functions.zso(form, 'search_map_lat_blocks',true) NEQ 0){
		
			latSize=abs(mapCoor.minLatitude-mapCoor.maxLatitude)/form.search_map_lat_blocks;
			longSize=abs(mapCoor.minLongitude-mapCoor.maxLongitude)/form.search_map_long_blocks;
		}else{
			latSize=1;
			longSize=1;
		}
		arrPrice=arraynew(1);
		arrId=arraynew(1);
		arrLat=arraynew(1);
		arrLong=arraynew(1);
		arrCount=arraynew(1);
		arrAvgLat=arraynew(1);
		arrAvgLong=arraynew(1);
		arrMinLat=arraynew(1);
		arrMaxLat=arraynew(1);
		arrMinLong=arraynew(1);
		arrMaxLong=arraynew(1);
		arrColor=arraynew(1);
		arrCountAtAddress=arraynew(1);
		
		minPrice=1000000000;
		maxPrice=0;
		if(structkeyexists(form,'mapfullscreen') EQ false and returnStruct2.count LT 10){
			if(form.debugSearchForm){
				ts.debug=true;	
			}
			if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_map_state') NEQ ""){
				ts.zwhere=" and listing_state ='#application.zcore.functions.zescape(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_map_state)#' ";	
			}
			ts.zselect="CAST(GROUP_CONCAT(listing.listing_id SEPARATOR '"",""') as CHAR) listing_id, CAST(GROUP_CONCAT(listing.listing_latitude SEPARATOR ',') as CHAR) listing_latitude, CAST(GROUP_CONCAT(listing.listing_longitude SEPARATOR ',') as CHAR) listing_longitude, CAST(GROUP_CONCAT(listing.listing_price SEPARATOR ',') as CHAR) listing_price";
			returnStruct = propertyDataCom.getProperties(ts);
				// no grouping	 
			if(returnStruct.listing_id EQ ""){
				arrayAppend(arrId, "");
				arrayAppend(arrLat, "");
				arrayAppend(arrLong, "");
			}else{
				arrayappend(arrId,returnStruct.listing_id);
				arrayappend(arrLat,returnStruct.listing_latitude);
				arrayappend(arrLong,returnStruct.listing_longitude);
			}
			arrayappend(arrCount,'0');
			arrayappend(arrAvgLat,'0');
			arrayappend(arrAvgLong,'0');
			arrayappend(arrMinLat,'0');
			arrayappend(arrMaxLat,'0');
			arrayappend(arrMinLong,'0');
			arrayappend(arrMaxLong,'0');
			arrayappend(arrCountAtAddress,'0');
			arrLPrice=listtoarray(returnStruct.listing_price);
			for(i=1;i LTE arraylen(arrLPrice);i++){
				minPrice=min(arrLPrice[i],minPrice);
				maxPrice=max(arrLPrice[i],maxPrice);
			}
			for(i=1;i LTE arraylen(arrLPrice);i++){
				color=11-max(1,ceiling(((arrLPrice[i]-minPrice)/max(1,(maxPrice-minPrice)))*10));
				arrayappend(arrColor,color);
			}
		}else{
			latSign="+";
			longSign="+";
			if(mapCoor.minLatitude<0){
				latSign="-";
			}
			if(mapCoor.minLongitude<0){
				longSign="-";
			}
			if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_map_state') NEQ ""){
				ts.zwhere=" and listing_state = '#application.zcore.functions.zescape(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_map_state)#' ";	
			}
			ts.zselect=" 
			ROUND(AVG(listing_price)) avgPrice, 
			(((FLOOR(ABS(ABS(listing_latitude)-#abs(mapCoor.minLatitude)#) / #latSize#))*#latSize#)#latSign##abs(mapCoor.minLatitude)#) latGroup, 
			(((FLOOR(ABS(ABS(listing_longitude)-#abs(mapCoor.minLongitude)#) / #longSize#)+1)*#longSize#)#longSign##abs(mapCoor.minLongitude)#) longGroup, 
			if(VAR_POP(listing_longitude+listing_latitude)=0,1,0) countAtAddress, 
			COUNT(listing.listing_id) COUNT, 
			IF(COUNT(listing.listing_id) < 10, CAST(GROUP_CONCAT(listing.listing_price SEPARATOR ',') AS CHAR),'') listing_price, 
			IF(COUNT(listing.listing_id) < 10, CAST(GROUP_CONCAT(listing.listing_id SEPARATOR '"",""') AS CHAR),'') listing_id, 
			IF(COUNT(listing.listing_id) < 10, CAST(GROUP_CONCAT(listing.listing_latitude SEPARATOR ',') AS CHAR),listing_latitude) listing_latitude, 
			IF(COUNT(listing.listing_id) < 10, CAST(GROUP_CONCAT(listing.listing_longitude SEPARATOR ',') AS CHAR),listing_longitude) listing_longitude  ";
			ts.zgroupby="GROUP BY FLOOR(ABS(ABS(listing_latitude)-#abs(mapCoor.minLatitude)#) / #latSize#), FLOOR(ABS(ABS(listing_longitude)-#abs(mapCoor.minLongitude)#) / #longSize#)";//latGroup, longGroup ";//

			returnStruct = propertyDataCom.getProperties(ts);
			structdelete(variables,'ts');
			rs=structnew();
			rs.count=returnStruct2.count;
			
			loop query="returnStruct"{
				if(returnStruct.listing_id EQ ""){
					minPrice=min(returnStruct.avgprice,minPrice);
					maxPrice=max(returnStruct.avgprice,maxPrice);
				}else{
					arrPrice2=listtoarray(returnStruct.listing_price);
					for(i=1;i LTE arraylen(arrPrice2);i++){
						minPrice=min(arrPrice2[i],minPrice);
						maxPrice=max(arrPrice2[i],maxPrice);
					}
				}
			}
			loop query="returnStruct"{
				arrayappend(arrCountAtAddress,returnStruct.countAtAddress);
				if(returnStruct.listing_id EQ ""){
					arrayappend(arrId,"0");
					if(returnStruct.countAtAddress EQ 1){
						arrayappend(arrLat,returnStruct.listing_latitude);
						arrayappend(arrLong,returnStruct.listing_longitude);
					}else{
						arrayappend(arrLat,0);
						arrayappend(arrLong,0);
					}
					color=11-max(1,ceiling(((returnStruct.avgprice-minPrice)/max(1,(maxPrice-minPrice)))*10));
					arrayappend(arrColor,color);
					arrayappend(arrCount,returnStruct.count);
					arrayappend(arrPrice,"$"&numberformat(returnStruct.avgprice));
					arrayappend(arrMinLat,returnStruct.latGroup);
					arrayappend(arrMinLong,returnStruct.longGroup);
				}else{
					arrayappend(arrId,returnStruct.listing_id);
					arrayappend(arrLat,returnStruct.listing_latitude);
					arrayappend(arrLong,returnStruct.listing_longitude);
					if(returnStruct.listing_id NEQ ""){
						arrLPrice=listtoarray(returnStruct.listing_price);
						for(i=1;i LTE returnStruct.count;i++){
							arrayappend(arrPrice,'0');
							arrayappend(arrCount,'0');
							if(i GT 1){
								arrayappend(arrCountAtAddress,"0");
							}
							color=11-max(1,ceiling(((arrLPrice[i]-minPrice)/max(1,(maxPrice-minPrice)))*10));
							arrayappend(arrColor,color);
							arrayappend(arrMinLat,'0');
							arrayappend(arrMinLong,'0');
						}
					}
				}
			}
		}
		if(structkeyexists(form,'mapfullscreen')){
			fs='"allMinLat":#returnstruct2.arrData[1].minlat#,"allMaxLat":#returnstruct2.arrData[1].maxlat#,"allMinLong":#returnstruct2.arrData[1].minlong#,"allMaxLong":#returnstruct2.arrData[1].maxlong#,';
		}else{
			fs="";	
		}
		if(returnStruct2.count EQ 0){
			fs&='"errorMessage":"#jsstringformat(returnStruct2.errorMessage)#",';
		} 
		jsonText='{#fs#"loadtime":"#((gettickcount()-start)/1000)# seconds",
		"COUNT":#returnStruct2.count#,success:true,
		"avgPrice":["#arraytolist(arrPrice,'","')#"],
		"listing_id":["#arraytolist(arrId,'","')#"],
		"listing_latitude":[#arraytolist(arrLat,',')#],
		"listing_longitude":[#arraytolist(arrLong,',')#],
		"arrCount":[#arraytolist(arrCount,',')#],
		"minLat":[#arraytolist(arrMinLat,',')#],
		"minLong":[#arraytolist(arrMinLong,',')#],
		"arrCountAtAddress":[#arraytolist(arrCountAtAddress,',')#],
		"arrColor":[#arraytolist(arrColor)#]';
		
		if(structkeyexists(form,'zforcemapresults')){
			jsonText&=',"disableSetCount":true';
		}
		jsonText&="}";
	}

	writeoutput(jsonText);
	abort;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	init(); 
	request.zos.currentURLISAListingPage=true;

	var propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData"); 
	var propDisplayCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
	db=request.zos.queryObject; 
	</cfscript>
 

 
 <cfscript>
 if(request.cgi_script_name EQ "/z/listing/search-form/index"){
	request.zForceListingSidebar=true; 
 }
if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_disable_search',true) EQ 1 and application.zcore.functions.zso(request, 'contentEditor',false,false) EQ false){
	application.zcore.functions.z301redirect('/');	
}
if(application.zcore.functions.zso(request, 'contentEditor',false,false) and request.cgi_script_name NEQ "/z/listing/admin/search-filter/index"){
	form.search_liststatus='1,4,7,16';	
	variables.search_liststatus='1,4,7,16';
}
sfSortStruct=structnew();
sfSortStruct["startFormTag"]="";
sfSortStruct["endFormTag"]="";
sfSortStruct["search_sqfoot"]="";
sfSortStruct["search_sqfoot_low"]="";
sfSortStruct["search_sqfoot_high"]="";
sfSortStruct["search_lot_square_feet_low"]="";
sfSortStruct["search_lot_square_feet_high"]="";
sfSortStruct["search_rate_low"]="";
sfSortStruct["search_rate_high"]="";
sfSortStruct["search_city_id"]="";
sfSortStruct["search_rate"]="";
sfSortStruct["search_listing_type_id"]="";
sfSortStruct["search_listing_sub_type_id"]="";
sfSortStruct["search_bedrooms"]="";
sfSortStruct["search_bathrooms"]="";
sfSortStruct["search_year_built"]="";
sfSortStruct["search_acreage"]="";
sfSortStruct["search_county"]="";
sfSortStruct["search_view"]="";
sfSortStruct["search_status"]="";
sfSortStruct["search_style"]="";
sfSortStruct["search_frontage"]="";
sfSortStruct["search_region"]="";
sfSortStruct["search_condition"]="";
sfSortStruct["search_tenure"]="";
sfSortStruct["search_parking"]="";
sfSortStruct["search_near_address"]="";
sfSortStruct["search_near_coordinates"]="";
sfSortStruct["search_more_options"]="";
sfSortStruct["search_result_limit"]="";
sfSortStruct["search_sort"]="";

 if(request.cgi_script_name NEQ '/z/listing/search-form/index'){
	 form.zsearch_bid='';
	 form.zsearch_cid='';
	 form.searchid='';
	 structdelete(request,'zForceSearchId');
 }
 
 
 
 
// overrideTitle="Search Results";
if(application.zcore.functions.zso(form, 'zsearch_cid') NEQ ''){
	 db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content, 
	 #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	WHERE mls_saved_search.mls_saved_search_id = content.content_saved_search_id and 
	mls_saved_search.site_id = content.site_id and 
	content.site_id = #db.param(request.zos.globals.id)# and 
	content_search_mls= #db.param(1)# and 
	content.content_id = #db.param(form.zsearch_cid)# and 
	content_deleted=#db.param('0')# and 
	mls_saved_search_deleted = #db.param(0)#";
	qc23872=db.execute("qc23872");
	if(qc23872.recordcount NEQ 0){
		overrideTitle=qc23872.content_name;
		temp238722=structnew();
		temp23872=structnew();
		application.zcore.functions.zQueryToStruct(qc23872,temp238722);
		temp238722.search_liststatus='1,4,7,16';
		request.zos.listing.functions.zMLSSetSearchStruct(temp23872,temp238722);
		form.searchId=application.zcore.status.getNewId();
		
		request.zsession.tempVars.zListingSearchId=form.searchId;
		application.zcore.status.setStatus(form.searchId,false,temp23872);
	}else{
		application.zcore.functions.z301redirect('/');
	}
}

if(application.zcore.functions.zso(form, 'zsearch_bid') NEQ ''){
	db.sql="SELECT * from #db.table("blog", request.zos.zcoreDatasource)# blog, 
	#db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	WHERE mls_saved_search.site_id= blog.site_id and 
	mls_saved_search.mls_saved_search_id = blog.mls_saved_search_id and 
	blog.blog_search_mls= #db.param(1)# and 
	blog.site_id = #db.param(request.zos.globals.id)# and 
	blog_id= #db.param(form.zsearch_bid)# and 
	blog_deleted = #db.param(0)# and 
	mls_saved_search_deleted = #db.param(0)#";
	qc23872=db.execute("qc23872");
	if(qc23872.recordcount NEQ 0){
		overrideTitle=qc23872.blog_title;
		temp238722=structnew();
		temp23872=structnew();
		application.zcore.functions.zQueryToStruct(qc23872,temp238722);
		request.zos.listing.functions.zMLSSetSearchStruct(temp23872,temp238722);
		form.searchId=application.zcore.status.getNewId();
		request.zsession.tempVars.zListingSearchId=form.searchId;
		application.zcore.status.setStatus(form.searchId,false,temp23872);
	}else{
		application.zcore.functions.z301redirect('/');
	}
}

 
if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
	originalRentalIdList2=application.zcore.listingCom.listingLookupIdByName("listing_type","Commercial");
	originalRentalIdList=application.zcore.listingCom.listingLookupIdByName("listing_type","Rental" );
	originalRentalIdList=replace(originalRentalIdList&","&originalRentalIdList2,",,",",","ALL");
	rentalIdList="'"&replace(originalRentalIdList,",","','","ALL")&"'";
}
if(isDefined('request.contentEditor')){ request.zDisableSearchFormSubmit=true; }
if((request.zos.istestserver EQ false and application.zcore.app.getAppData("listing").sharedStruct.resetCacheTimespan) or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct, 'searchCacheTimespan') EQ false){
	if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct, 'resetCacheTimespanInProgress') EQ false){
		application.zcore.app.getAppData("listing").sharedStruct.resetCacheTimespanInProgress=true;
		application.zcore.app.getAppData("listing").sharedStruct.searchCacheTimespan=createtimespan(0,0,0,0);
	}else{
		structdelete(request.zos.listing,"resetCacheTimespanInProgress");
		application.zcore.app.getAppData("listing").sharedStruct.resetCacheTimespan=false;
		application.zcore.app.getAppData("listing").sharedStruct.searchCacheTimespan=createtimespan(0,1,0,0);
	}
}
//Request.zPageDebugDisabled=true;

if(structkeyexists(form, 'saved_search_on')){
	if(structkeyexists(form, 'mls_saved_search_id') and form.mls_saved_search_id NEQ ''){
		db.sql="SELECT mls_saved_search_id 
		FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
		WHERE mls_saved_search_id = #db.param(form.mls_saved_search_id)# and 
    	mls_saved_search_deleted = #db.param(0)#";
		qId=db.execute("qId");
		form.mls_saved_search_id=qid.mls_saved_search_id;
	}else{
		form.mls_saved_search_id="";
	}
	if(form.saved_search_on EQ 1) {
		mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', form.mls_saved_search_id, '', form);
	} else {
		mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('delete', form.mls_saved_search_id);
	}
}


	
if(structkeyexists(form, 'searchid') EQ false or isNumeric(form.searchId) EQ false or (isDefined('request.zForceSearchId') EQ false and (request.cgi_script_name EQ "/content/index.cfm" or request.cgi_script_name EQ "/index.cfm"))){
	local.newSearch=true;
	form.searchId=application.zcore.status.getNewId();
}
form.zIndex=application.zcore.functions.zso(form, 'zIndex',false,1);
if(form.zIndex EQ "" or isNumeric(form.zIndex) EQ false){
	form.zIndex=1;
}
application.zcore.status.setField(form.searchId,'zIndex',form.zIndex);
//a=application.zcore.status.getStruct(form.searchId);writedump(a);
if(structkeyexists(form,'search_city_id') or structkeyexists(form,'search_map_coordinates_list')){
	application.zcore.status.setStatus(form.searchId,false,form);
	ts=application.zcore.status.getStruct(form.searchId);
}else{
	ts=application.zcore.status.getStruct(form.searchId);
	if(not structkeyexists(ts,'varstruct')){
		ts.varstruct={};
	}
	structappend(form,ts.varStruct,false);
	structappend(variables,ts.varStruct,false);
}

if (structkeyexists(form, 'mls_saved_search_id')) {
	q2=request.zos.listing.functions.zGetSavedSearchQuery(form.mls_saved_search_id);
	application.zcore.functions.zquerytostruct(q2,ts.varstruct);
	structappend(form, ts.varstruct, true);
}  
for(i in form){
	if(left(i, 7) EQ "search_" and isSimpleValue(form[i]) and form[i] EQ 0){
		form[i]='';
	}
}
if(not structkeyexists(form, 'search_liststatus') or form.search_liststatus EQ ""){
	form.search_liststatus="1";
}
searchCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.search");
searchCom.queryStringSearchToStruct(form);


form.zIndex=max(form.zIndex,1);
if(application.zcore.functions.zso(form, 'search_sort') CONTAINS ','){
	application.zcore.functions.z301redirect('/');	
}
form.search_surrounding_cities=application.zcore.functions.zso(form, 'search_surrounding_cities');
if(form.search_surrounding_cities NEQ 1 and form.search_surrounding_cities NEQ 0 and form.search_surrounding_cities NEQ ""){
	application.zcore.functions.z301Redirect('/');	
}

forceSearchFormReset=false;
curCacheTimeSpan=application.zcore.app.getAppData("listing").sharedStruct.searchCacheTimespan;
if(structkeyexists(form, 'zdisablesearchfilter')){
	forceSearchFormReset=true;
	curCacheTimeSpan=CreateTimeSpan(0, 0, 0, 0);
}else if(structkeyexists(application.zcore,'searchformresetdate')){
	if(structkeyexists(application.sitestruct[request.zos.globals.id],'searchformresetdate') EQ false or DateCompare(application.zcore.searchformresetdate, application.sitestruct[request.zos.globals.id].searchformresetdate) NEQ 0){
		application.sitestruct[request.zos.globals.id].searchformresetdate=application.zcore.searchformresetdate;
		forceSearchFormReset=true;
		curCacheTimeSpan=CreateTimeSpan(0, 0, 0, 0);
		
	}
}
if(application.zcore.functions.zso(form, 'search_result_layout') EQ ""){
	form.search_result_layout=application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_list_layout');
}

</cfscript>
<!--- <cfthread action="run" name="zThreadListingSearchForm"> --->
 <cfsavecontent variable="searchFormHTML">
  
 <cfsavecontent variable="startFormTagHTML">

<cfif structkeyexists(request,'theSearchFormTemplate') EQ false>
 <div id="searchFormTopDiv" style="<!--- height:<cfif isDefined('request.contentEditor')>90<cfelse>130</cfif>px; --->float:left;  width:100%; clear:both;"></div><br style="clear:both;" /></cfif><cfif structkeyexists(form, 'searchId') and form.searchFormEnabledDropDownMenus EQ false><div class="zls-saveSearchFormButton"><br /><a href="##" onclick="zModalSaveSearch(#form.searchId#);return false;" class="zls-saveThisSearchLink"></a><br style="clear:both;" /></div>
 <cfif request.zos.listing.functions.hasSavedSearches()>
 	<div class="zSearchFormText"><a href="/z/listing/property/your-saved-searches" class="zls-viewSavedSearchesLink">View Saved Searches</a></div><br />
 </cfif><br />
 
 </cfif>

<script type="text/javascript">/* <![CDATA[ */var zDisableSearchFormSubmit=<cfif application.zcore.functions.zso(request,'zDisableSearchFormSubmit',false,false)>true<cfelse>false</cfif>;/* ]]> */</script>
<cfscript>
if(isDefined('request.contentEditor') EQ false){
	ts=StructNew();
	ts.name="zMLSSearchForm";
	ts.ajax=false;
	ts.debug=form.debugSearchForm;
	if(request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' and structkeyexists(form, 'mls_saved_search_id')){
		ts.action="/z/listing/property/your-saved-searches/index?action=update";
	}else{
		ts.action=application.zcore.functions.zURLAppend(request.zos.listing.functions.getSearchFormLink(), "searchaction=search&searchId=#form.searchId#");
		
	}
	if(form.debugSearchForm){
		ts.action&="&zreset=app";
	}
	tempSearchFormAction=ts.action;
	ts.onLoadCallback="loadMLSResults";
	ts.method="post";
	ts.ignoreOldRequests=true;
	ts.successMessage=false;
	ts.onChangeCallback="getMLSCount";
	application.zcore.functions.zForm(ts);
}

if(structkeyexists(form, 'searchFormHideCriteria') EQ false){
	form.searchFormHideCriteria=structnew();	
}
</cfscript>

<cfif form.debugSearchForm>
<script type="text/javascript">/* <![CDATA[ */zDebugMLSAjax=true;/* ]]> */
</script>
</cfif>
<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1>
<cfscript>
ts=structnew();
search_status='7';
ts.name="search_status";
application.zcore.functions.zinput_hidden(ts);
</cfscript>
</cfif>
<cfif form.debugSearchForm>
<input type="text" name="zreset" value="site" /> (site reset)<br />
</cfif>
<cfif structkeyexists(request,'theSearchFormTemplate') EQ false>
 <cfscript>
if(form.searchFormEnabledDropDownMenus){
	echo('<div class="zResultCountAbsolute" id="resultCountAbsolute"></div>');
}else{
	application.zcore.template.appendTag("scripts", '<div class="zResultCountAbsolute" id="resultCountAbsolute"></div>');
}
</cfscript>
 </cfif>
 
 </cfsavecontent>
 <cfscript>
sfSortStruct["startFormTag"]=startFormTagHTML;
writeoutput(startFormTagHTML);
</cfscript>
<div class="zSearchFormTable"> 
<cfscript>
//application.zcore.template.appendTag('meta',application.zcore.skin.includeJS(request.zos.listing.cityLookupFileName));
</cfscript>
<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable,'search_city_id') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'city') EQ false>
<cfscript>
primaryCount=1;
primaryCityId=application.zcore.app.getAppData("listing").sharedStruct.mls_primary_city_id;
selectedCityCount=0;
if(application.zcore.functions.zso(form, 'search_city_id') NEQ ""){
    cityIdList="'"&replace(application.zcore.functions.zescape(form.search_city_id),",","','","ALL")&"'";
	g=listgetat(form.search_city_id,1);
	selectedCityCount=listlen(form.search_city_id);
	if(isnumeric(g)){
		primaryCityId=g;	
	}
	
}else{
	if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list NEQ ""){
		cityIdList="'"&application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list&"'";
		primaryCount=arraylen(listtoarray(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list));
	}else{
    	cityIdList="'"&replace(primaryCityId,",","','","ALL")&"'";
	}
}

    arrLabel=arraynew(1);
    arrValue=arraynew(1);
    rs2=structnew();
    rs2.labels="";
    rs2.values="";
    cityUnq=structnew();
	
    preLabels="";
    preValues="";
sOut=structnew();
    </cfscript>

    
<cfif form.searchFormEnabledDropDownMenus or 1 EQ 1>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_city SEPARATOR #db.trustedSQL("','")#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_city not in #db.trustedSQL("('','0','#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#')")#
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
	<cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");</cfscript>
    <cfif qType.idlist NEQ "">
    <cfsavecontent variable="db.sql">
    select city_x_mls.city_name label, city_x_mls.city_id value 
	from #db.table("city_x_mls", request.zos.zcoreDatasource)# city_x_mls 
	WHERE city_x_mls.city_id IN (#db.trustedSQL(qtype.idlist)#)and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))#  and 
	city_id NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#)  and 
	city_x_mls_deleted = #db.param(0)#
          
    </cfsavecontent><cfscript>qCity=db.execute("qCity");</cfscript>
    <cfloop query="qCity"><cfscript>if(structkeyexists(cityUnq,qCity.label) EQ false){cityUnq[qCity.label]=qCity.value;}</cfscript></cfloop>
    </cfif>
    <!--- put the primary cities at top and repeat further down too --->
    <cfsavecontent variable="db.sql">
    select city.city_name label, city.city_id value 
	from #db.table("city_memory", request.zos.zcoreDatasource)# city 
	WHERE city_id IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list)#'")#) and 
	city_deleted=#db.param(0)# 
	ORDER BY label 
    </cfsavecontent><cfscript>qCity10=db.execute("qCity10");
	arrK2=arraynew(1);
	arrK3=arraynew(1);
	if(qCity10.recordcount NEQ 0){
		for(i=1;i LTE qCity10.recordcount;i++){
			sOut[qCity10.label[i]]=true;
			arrayappend(arrK2,qCity10.label[i]);
			arrayappend(arrK3,qCity10.value[i]);
		}
		preLabels=arraytolist(arrK2,chr(9))&chr(9)&"-----------";
		preValues=arraytolist(arrK3,chr(9))&chr(9)&"-----------";
	}
	</cfscript>
<cfelse>
    <cfsavecontent variable="db.sql">
    select city_x_mls.city_name label, city_x_mls.city_id value 
	from `city_distance_memory` city_distance,city_x_mls 
	WHERE city_x_mls.city_id = city_distance.city_id and 
	city_x_mls_deleted = #db.param(0)# and 
	city_distance_deleted = #db.param(0)# and 
	city_parent_id=#db.param(primaryCityId)# and 
	city_distance<=#db.param(30)# and 
	city_x_mls.city_id NOT IN (#db.trustedSQL("#(cityIdList)#,'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#) and 
	
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))# 
          
    <cfif primaryCount GT 1> and #db.param(1)# = #db.param(0)# </cfif>
    group by city_x_mls.city_id 
	ORDER BY city_distance asc 
	LIMIT #db.param(0)#,#db.param(10)#
    </cfsavecontent><cfscript>qCity=db.execute("qCity");</cfscript>
    <cfsavecontent variable="db.sql">
    select city.city_name label, city.city_id value 
	from #db.table("city_memory", request.zos.zcoreDatasource)# city 
	WHERE city.city_id IN (#db.trustedSQL(cityIdList)#)  and 
	city_deleted=#db.param(0)# and 
	city_id NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#)
    </cfsavecontent><cfscript>qCity2=db.execute("qCity2");</cfscript>
    <cfloop query="qCity"><cfscript>if(structkeyexists(cityUnq,label) EQ false){cityUnq[label]=value;}</cfscript></cfloop>
    <cfloop query="qCity2"><cfscript>if(structkeyexists(cityUnq,label) EQ false){cityUnq[label]=value;}</cfscript></cfloop>

</cfif>
<cfscript>
arrKeys=structkeyarray(cityUnq);
arraysort(arrKeys,"text","asc");
//arrKeys=structsort(cityUnq,"text","asc");
for(i=1;i LTE arraylen(arrKeys);i++){
	if(structkeyexists(sOut,arrKeys[i]) EQ false){
		sOut[arrKeys[i]]=true;
		arrayappend(arrLabel,arrKeys[i]);
		arrayappend(arrValue,cityUnq[arrKeys[i]]);
	}
}

rs2.labels=trim(preLabels&chr(9)&arraytolist(arrLabel,chr(9)));
rs2.values=trim(preValues&chr(9)&arraytolist(arrValue,chr(9)));
ts.listLabels=rs2.labels;
ts.listValues =rs2.values;
</cfscript>

<cfif rs2.labels NEQ "">
<div class="zmlsformdiv">
<!--- <cfscript>

ts = StructNew();
ts.name="search_city_id";
ts.enableTyping=false;
ts.overrideOnKeyUp=false;
ts.enableClickSelect=false;
ts.selectedOnTop=false;
ts.range=false;
ts.allowAnyText=false;
ts.disableSpider=true;
ts.listLabelsDelimiter = chr(9);
ts.listValuesDelimiter = chr(9);
ts.listLabels=rs2.labels;
ts.listValues =rs2.values;
ts.output=false;
ts.selectLabel="City";
ts.inlineStyle="width:#form.searchFormSelectWidth#;";
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="City";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="City:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInputLinkBox(ts);
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="City:";
		ts.contents=rs.output;
		ts.height=(selectedCityCount*18)+65 + ((listlen(rs2.labels,chr(9))-selectedCityCount) * 17);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_city_id"];
		application.zcore.functions.zExpOption(ts);

}
</cfscript> --->

<cfscript>

 
ts = StructNew();
ts.name="search_city_id";
ts.enableTyping=false;
ts.enableClickSelect=false;
//ts.overrideOnKeyUp=true;
//ts.onchange="alert('test onchange');";
//ts.onkeyup="zMlsCheckCityLookup(event, this,document.getElementById(this.id+'v'),'city_id'); zKeyboardEvent(event, this,document.getElementById(this.id+'v'));";
//ts.onEnterJS="";
//ts.onkeypress="";
//ts.onButtonClick="var e2=new Object();e2.keyCode=13;e2.which=13; zKeyboardEvent(e2, document.getElementById('#ts.name#_zmanual'),document.getElementById('#ts.name#_zmanualv'),true);";
ts.range=false;
ts.notranslate=true;
ts.allowAnyText=false;
//ts.disableSpiderAfter=3;
ts.disableSpider=true;
//ts.disableHidden=true;
ts.listLabelsDelimiter = chr(9);
ts.listValuesDelimiter = chr(9);
ts.listLabels=rs2.labels;
ts.listValues =rs2.values;
ts.inputstyle="padding:0px;font-size:10px; margin:0px;";
//ts.listURLs=rs.URLs;
//application.zcore.functions.zInputSelectBox(ts);
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="City";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="City:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
}else{
	ts.enableTyping=false;
	structdelete(ts, 'label');
	ts.overrideOnKeyUp=false;
	ts.enableClickSelect=false;
	ts.selectedOnTop=false;
	ts.range=false;
	ts.allowAnyText=false;
	ts.disableSpider=true;
	ts.selectLabel="-- Add City --";
	ts.inlineStyle="width:100%;";
	rs=application.zcore.functions.zInputLinkBox(ts);
	//rs=application.zcore.functions.zInputLinkBox(ts);
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="City:";
		ts.disableOverflow=true;
		ts.contents=rs.output;
		if(selectedCityCount NEQ 0){
			ts.height=(selectedCityCount*20)+75;
		}else{
			ts.height=70;
		}
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_city_id"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript> 
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_city_id"]=theCriteriaHTML;
</cfscript>
<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_rate') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_rate') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'price') EQ false>
<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_rate_low";
ts.name2="search_rate_high";
ts.leftLabel="$";
ts.middleLabel="$";
ts.range=true;
//ts.onchange="document.getElementById('zist').value=this.value;";
ts.fieldWidth="59";
ts.width="150";
if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
	if(form.searchFormEnabledDropDownMenus){
		ts.listLabels="$0|$200|$400|$600|$800|$1,000|$1,200|$1,400|$1,600|$1,800|$2,000|$2,500|$3,000|$4,000|$5,000|$6,000|$7,000|$8,000|$9,000|$10,000|$20,000|$30,000|$40,000|$50,000|$100,000|$10,000,000";
	}else{
		ts.listLabels="0|200|400|600|800|1,000|1,200|1,400|1,600|1,800|2,000|2,500|3,000|4,000|5,000|6,000|7,000|8,000|9,000|10,000|20,000|30,000|40,000|50,000|100,000|10,000,000";
	}
	ts.listValues="0|200|400|600|800|1000|1200|1400|1600|1800|2000|2500|3000|4000|5000|6000|7000|8000|9000|10000|20000|30000|40000|50000|100000|10000000";
}else{
	if(form.searchFormEnabledDropDownMenus){
		ts.listLabels="$0|$25,000|$50,000|$75,000|$100,000|$125,000|$150,000|$175,000|$200,000|$225,000|$250,000|$275,000|$300,000|$325,000|$350,000|$400,000|$450,000|$500,000|$600,000|$700,000|$800,000|$900,000|$1,000,000|$1,500,000|$2,000,000|$3,000,000|$4,000,000";
	}else{
		ts.listLabels="0|25,000|50,000|75,000|100,000|125,000|150,000|175,000|200,000|225,000|250,000|275,000|300,000|325,000|350,000|400,000|450,000|500,000|600,000|700,000|800,000|900,000|1,000,000|1,500,000|2,000,000|3,000,000|4,000,000";
	}
	ts.listValues="0|25000|50000|75000|100000|125000|150000|175000|200000|225000|250000|275000|300000|325000|350000|400000|450000|500000|600000|700000|800000|900000|1000000|1500000|2000000|3000000|4000000";
}
ts.listLabelsDelimiter="|";
ts.listValuesDelimiter="|";
ts.output=false;
</cfscript><cfif form.searchFormEnabledDropDownMenus>
<cfsavecontent variable="theCriteriaHTML2"><cfscript>
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Min Price";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Price&nbsp;From:&nbsp;$";
	}
	ts.labelStyle="display:block; float:left;width:75px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript></cfsavecontent><cfscript>
sfSortStruct["search_rate_low"]=theCriteriaHTML2;
</cfscript>
<cfsavecontent variable="theCriteriaHTML3"><cfscript>
	ts.name="search_rate_high";
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Max Price";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="To: $";
	} 
	if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
		 
		ts.listLabels="$0|$200|$400|$600|$800|$1,000|$1,200|$1,400|$1,600|$1,800|$2,000|$2,500|$3,000|$4,000|$5,000|$6,000|$7,000|$8,000|$9,000|$10,000|$20,000|$30,000|$40,000|$50,000|$100,000|$100,000+"; 
		ts.listValues="0|200|400|600|800|1000|1200|1400|1600|1800|2000|2500|3000|4000|5000|6000|7000|8000|9000|10000|20000|30000|40000|50000|100000|0";
	}else{		
		ts.listLabels="$0|$25,000|$50,000|$75,000|$100,000|$125,000|$150,000|$175,000|$200,000|$225,000|$250,000|$275,000|$300,000|$325,000|$350,000|$400,000|$450,000|$500,000|$600,000|$700,000|$800,000|$900,000|$1,000,000|$1,500,000|$2,000,000|$3,000,000|$4,000,000|$4,000,001+";
		ts.listValues="0|25000|50000|75000|100000|125000|150000|175000|200000|225000|250000|275000|300000|325000|350000|400000|450000|500000|600000|700000|800000|900000|1000000|1500000|2000000|3000000|4000000|0";
	}
	ts.labelStyle="display:block; float:left;width:75px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
</cfscript></cfsavecontent><cfscript>
sfSortStruct["search_rate_high"]=theCriteriaHTML3;
writeoutput(theCriteriaHTML2);
writeoutput('</div><div class="zmlsformdiv">');
writeoutput(theCriteriaHTML3);
</cfscript><cfelse><cfscript>
	rs=application.zcore.functions.zInputSlider(ts);
	
	/*ts.name="search_rate_low";
	ts.selectLabel = "Price Range";
	application.zcore.functions.zInputSelectBox(ts);
	
	ts.name="search_rate_high";
	ts.selectLabel = "to ";
	application.zcore.functions.zInputSelectBox(ts);
	*/
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
	
		ts=StructNew();
		ts.disableOverflow=true;
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Price:";
		ts.contents=rs.output;
		ts.height="65";
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_rate"];
		application.zcore.functions.zExpOption(ts);
	}
</cfscript></cfif>
</div>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_rate"]=theCriteriaHTML;
</cfscript>
<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_listing_type_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_listing_type_id') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'listing_type_id') EQ false>
	

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_listing_type_id') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_type_id SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_type_id not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
          
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("listing_type",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_listing_type_id=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_listing_type_id);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_listing_type_id";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Property Type";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Property Type:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Property Type:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 19);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_listing_type_id"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_listing_type_id"]=theCriteriaHTML;
</cfscript>














<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_region') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_region') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'region') EQ false>
	

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_region') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_region SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_region not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
          
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("region",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_region=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_region);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_region";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Region";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Region:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Region:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_region"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_region"]=theCriteriaHTML;
</cfscript>





<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_parking') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_parking') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'parking') EQ false>
	

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_parking') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_parking SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_parking not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> 	
		#db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
          
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("parking",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_parking=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_parking);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_parking";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Parking";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Parking:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Parking:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_parking"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_parking"]=theCriteriaHTML;
</cfscript>




<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_condition') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_condition') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'condition') EQ false>
	

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_condition') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_condition SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_condition not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
          
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("condition",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_condition=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_condition);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_condition";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Condition";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Condition:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Condition:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_condition"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_condition"]=theCriteriaHTML;
</cfscript>




<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_tenure') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_tenure') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'tenure') EQ false>
	

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_tenure') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_tenure SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_tenure not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
          
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("tenure",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_tenure=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_tenure);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_tenure";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Tenure";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Tenure:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Tenure:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_tenure"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_tenure"]=theCriteriaHTML;
</cfscript>


<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_listing_sub_type_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_listing_sub_type_id') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'listing_sub_type_id') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_listing_sub_type_id') EQ false>

 
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_sub_type_id SEPARATOR #db.param(',')#) AS CHAR) idlist from 
	#db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_sub_type_id not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType"); 
   // writedump(qType);    abort;
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        label=application.zcore.listingCom.listingLookupValue("listing_sub_type",i); 
	if(structkeyexists(s3, label)){
		s3[label]&=","&i;
	}else{
        	s3[label]=i;   
	}
    }
   /* writedump(s3);
 writedump(qType);
 abort;   */
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_listing_sub_type_id=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_listing_sub_type_id);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_listing_sub_type_id";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Property Sub Type";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Property Sub Type:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
	
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Property Sub Type:";
		ts.contents=rs.output;
		ts.height=28 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_listing_sub_type_id"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_listing_sub_type_id"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">

<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_bedrooms') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_bedrooms') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'bedrooms') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_bedrooms') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT listing_beds from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_beds not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qType=db.execute("qType");
	tv299=structnew();
	tv299.recordcount=qType.recordcount;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_bedrooms=tv299;
}
    </cfscript>
    
<cfelse>
	<cfscript>
	qType=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_bedrooms);
	</cfscript>
</cfif>
<cfif qType.recordcount NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_bedrooms_low";
ts.name2="search_bedrooms_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="30";
ts.width="150";
ts.listValues="1,2,3,4,5,6,7";
ts.listValuesDelimiter=",";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	ts.listLabels="1+,2+,3+,4+,5+,6+,7+";
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Beds";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Beds:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInputSlider(ts);
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Beds:";
		ts.contents=rs.output;
		ts.height="65";
		ts.width="165";
		ts.disableOverflow=true;
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_bedrooms"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_bedrooms"]=theCriteriaHTML;
</cfscript>
<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_bathrooms') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_bathrooms') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'baths') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_bathrooms') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT listing_baths from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_baths not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qType=db.execute("qType");
	tv299=structnew();
	tv299.recordcount=qType.recordcount;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_bathrooms=tv299;
}
    </cfscript>
    
<cfelse>
	<cfscript>
	qType=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_bathrooms);
	</cfscript>
</cfif>
<cfif qType.recordcount NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_bathrooms_low";
ts.name2="search_bathrooms_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="30";
ts.width="150";
ts.listValues="1,2,3,4,5,6,7";
ts.listValuesDelimiter=",";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	ts.listLabels="1+,2+,3+,4+,5+,6+,7+";
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Baths";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Bath:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInputSlider(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Baths:";
		ts.contents=rs.output;
		ts.height="65";
		ts.width="165";
		ts.disableOverflow=true;
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_bathrooms"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>

</cfsavecontent>
<cfscript>
sfSortStruct["search_bathrooms"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_sqfoot') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_sqfoot') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'square_feet') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_sqfoot') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT listing_square_feet from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_square_feet not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent>
    <cfscript>
	qType=db.execute("qType");
	tv299=structnew();
	tv299.recordcount=qType.recordcount;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_sqfoot=tv299;
}
    </cfscript>
    
<cfelse>
	<cfscript>
	qType=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_sqfoot);
	</cfscript>
</cfif>
<cfif qType.recordcount NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_sqfoot_low";
ts.name2="search_sqfoot_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="33";
ts.width="150";
ts.listLabels="0,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000,3250,3500,4000,4500,5000,6000,7000,8000,9000,10000,15000,20000";
arrL=listtoarray(ts.listLabels,",");
for(i=1;i LTE arraylen(arrL);i++){
	//arrL[i]=arrL[i]&"sqft ("&round(arrL[i]/10.7639)&"m&##178;)";
}
ts.listLabels=arraytolist(arrL,",");
ts.listValues = "0,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000,3250,3500,4000,4500,5000,6000,7000,8000,9000,10000,15000,20000";
ts.listValuesDelimiter=",";
ts.output=false;
</cfscript><cfif form.searchFormEnabledDropDownMenus>
<cfsavecontent variable="theCriteriaHTML2"><cfscript>
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Min SQFT";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Min SQFT:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript></cfsavecontent><cfscript>
sfSortStruct["search_sqfoot_low"]=theCriteriaHTML2;
</cfscript>
<cfsavecontent variable="theCriteriaHTML3"><cfscript>
	ts2=duplicate(ts);
	ts2.name="search_sqfoot_high";
	if(form.searchFormLabelOnInput){
		ts2.selectLabel="Max SQFT";
	}else{
		ts2.label="Max SQFT:";
	}
	application.zcore.functions.zInputSelectBox(ts2);
	
	</cfscript></cfsavecontent><cfscript>
sfSortStruct["search_sqfoot_high"]=theCriteriaHTML3;

writeoutput(theCriteriaHTML2);
writeoutput('<br />');
writeoutput(theCriteriaHTML3);</cfscript><cfelse><cfscript>
	//ts.onchange="zConvertSliderToSquareMeters('search_sqfoot_low','search_sqfoot_high',false);";
	rs=application.zcore.functions.zInputSlider(ts);
	writeoutput('<input type="hidden" name="search_sqfoot_low_zvalue" id="search_sqfoot_low_zvalue" value="'&rs.zvalue&'" />');//<script type="text/javascript">zArrDeferredFunctions.push(function(){zConvertSliderToSquareMeters("search_sqfoot_low","search_sqfoot_high",false);});</script>');
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="SQFT:";
		ts.contents=rs.output;
		ts.height="80";
		ts.disableOverflow=true;
		ts.width="165";
		ts.zMotionEnabled=true;
		if(application.zcore.functions.zso(form, 'search_sqfoot_low', true) NEQ 0 or application.zcore.functions.zso(form, 'search_sqfoot_high', true) NEQ 0){
			ts.zMotionOpen=true;
		}else{
			application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_sqfoot"];
		}
		application.zcore.functions.zExpOption(ts);
	}
</cfscript>
</cfif>

</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_sqfoot"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">

<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_year_built') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_year_built') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'year_built') EQ false>

<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_year_built_low";
ts.name2="search_year_built_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="42";
ts.width="150";
nowyears="";
for(i=2010;i LTE year(now());i++){
	nowyears&=","&i;
}
ts.listLabels = "<1920,1920,1930,1940,1950,1960,1970,1980,1990,1995,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009#nowyears#,Future";
ts.listValues = "1800,1920,1930,1940,1950,1960,1970,1980,1990,1995,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009#nowyears#,#year(now())+3#";
ts.listLabelsDelimiter=",";
ts.listValuesDelimiter=",";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.listLabels = "<1920,1920+,1930+,1940+,1950+,1960+,1970+,1980+,1990+,1995+,2000+,2001+,2002+,2003+,2004+,2005+,2006+,2007+,2008+,2009+#nowyears#,Future";
		ts.selectLabel="Year Built";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Year Built:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInputSlider(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Year Built:";
		ts.contents=rs.output;
		ts.height="65";
		ts.disableOverflow=true;
		ts.width="165";
		ts.zMotionEnabled=true;
		if(application.zcore.functions.zso(form, 'search_year_built_low', true) NEQ 0 or application.zcore.functions.zso(form, 'search_year_built_high', true) NEQ 0){
			ts.zMotionOpen=true;
		}else{
			ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_year_built"];
		}
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>

</div>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_year_built"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">

<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_acreage') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_acreage') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'acreage') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_acreage') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT listing_acreage from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_acreage not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qType=db.execute("qType");
	tv299=structnew();
	tv299.recordcount=qType.recordcount;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_acreage=tv299;
}
    </cfscript>
    
<cfelse>
	<cfscript>
	qType=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_acreage);
	</cfscript>
</cfif>
<cfif qType.recordcount NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_acreage_low";
ts.name2="search_acreage_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="30";
ts.width="150";
ts.listLabels = "0+|0.25+|0.5+|0.75+|1+|2+|3+|4+|5+|10+|20+|50+|100+";
ts.listValues = "0|0.25|0.5|0.75|1|2|3|4|5|10|20|50|100";
ts.listLabelsDelimiter="|";
ts.listValuesDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Acreage";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Acreage:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInputSlider(ts);
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
	
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Acreage:";
		ts.disableOverflow=true;
		ts.contents=rs.output;
		ts.height="65";
		ts.width="165";
		ts.zMotionEnabled=true;
		if(application.zcore.functions.zso(form, 'search_acreage_low', true) NEQ 0 or application.zcore.functions.zso(form, 'search_acreage_high', true) NEQ 0){
			ts.zMotionOpen=true;
		}else{
			ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_acreage"];
		}
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>

</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_acreage"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">

<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only NEQ 1>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_county') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_county') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'county') EQ false>
    
<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_county') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_county SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_county not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("county",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_county=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_county);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<!---<cfdump var="#arrL#">--->
<cfscript>
ts = StructNew();
ts.name="search_county";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="County";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="County:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="County:";
		ts.contents=rs.output;
		ts.height=28 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_county"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_county"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">
<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only NEQ 1>
 </cfif>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_view') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_view') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'view') EQ false>


<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_view') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_view SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_view not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("view",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_view=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_view);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_view";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Water/View";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Water/View:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="View:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_view"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_view"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">

<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only NEQ 1>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_status') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_status') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'status') EQ false>


<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_status') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_status SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_status not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist,",",false);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("status",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    //structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
	
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'data.search_status')){
		
		arrS=listtoarray(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.data.search_status);
		
		arrV2=arraynew(1);
		arrL2=arraynew(1);
		for(i=1;i LTE arraylen(arrV);i++){
			m=false;
			for(n=1;n LTE arraylen(arrS);n++){
				if(arrS[n] EQ arrV[i]){
					m=true;
					break;
				}
			}
			if(arraylen(arrS) NEQ 0 and (application.zcore.app.getAppData("listing").sharedStruct.filterStruct.type.search_status EQ 1 or application.zcore.app.getAppData("listing").sharedStruct.filterStruct.type.search_status EQ 0)){
				if(m){
					arrayAppend(arrV2,arrV[i]);
					arrayAppend(arrL2,arrL[i]);
				}
			}else{
				if(m EQ false){
					arrayAppend(arrV2,arrV[i]);
					arrayAppend(arrL2,arrL[i]);
				}
				
			}
		}
		arrV=arrV2;
		arrL=arrL2;
	}
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_status=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_status);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_status";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Sale Type";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Sale Type:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Sale Type:";
		ts.contents=rs.output;
		ts.height=28 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_status"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_status"]=theCriteriaHTML;
</cfscript>



<cfsavecontent variable="theCriteriaHTML">
<cfif application.zcore.functions.zso(request,'contentEditor',false,false) and request.cgi_script_name NEQ "/z/listing/admin/search-filter/index">
<cfscript>
ts=structnew();
form.search_liststatus='1,4,7,16';
ts.name="search_liststatus";
application.zcore.functions.zinput_hidden(ts);
</cfscript>
</cfif>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_liststatus') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_liststatus') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'liststatus') EQ false and (application.zcore.functions.zso(request,'contentEditor',false,false) EQ false or request.cgi_script_name EQ "/z/listing/admin/search-filter/index")>


<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_liststatus') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_liststatus SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_liststatus not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist,",",false);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("liststatus",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    //structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
	
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'data.search_liststatus')){
		
		arrS=listtoarray(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.data.search_liststatus);
		
		arrV2=arraynew(1);
		arrL2=arraynew(1);
		for(i=1;i LTE arraylen(arrV);i++){
			m=false;
			for(n=1;n LTE arraylen(arrS);n++){
				if(arrS[n] EQ arrV[i]){
					m=true;
					break;
				}
			}
			if(arraylen(arrS) NEQ 0 and (application.zcore.app.getAppData("listing").sharedStruct.filterStruct.type.search_liststatus EQ 1 or application.zcore.app.getAppData("listing").sharedStruct.filterStruct.type.search_liststatus EQ 0)){
				if(m){
					arrayAppend(arrV2,arrV[i]);
					arrayAppend(arrL2,arrL[i]);
				}
			}else{
				if(m EQ false){
					arrayAppend(arrV2,arrV[i]);
					arrayAppend(arrL2,arrL[i]);
				}
				
			}
		}
		arrV=arrV2;
		arrL=arrL2;
	}
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_liststatus=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_liststatus);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_liststatus";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.onchange="zInactiveCheckLoginStatus(this);";
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Listing Status";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Listing Status:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	ts.onclick="zInactiveCheckLoginStatus(this);";
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Listing Status:";
		ts.contents=rs.output;
		ts.height=28 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_liststatus"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_liststatus"]=theCriteriaHTML;
</cfscript>




<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_style') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_style') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'style') EQ false>
<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_style') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_style SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing  
WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_style not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("style",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_style=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_style);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_style";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Style";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Style:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);

	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Style:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_style"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_style"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_frontage') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_frontage') EQ 1) and structkeyexists(form.searchFormHideCriteria, 'frontage') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_frontage') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_frontage SEPARATOR #db.param(',')#) AS CHAR) idlist from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_frontage not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType"); 
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("frontage",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_frontage=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_frontage);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
	
	
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
	ts = StructNew();
	ts.name="search_frontage";
	ts.listValues =arraytolist(arrV,"|");
	ts.listValuesDelimiter="|";
	ts.listLabels =arraytolist(arrL,"|");
	ts.listLabelsDelimiter="|";
	ts.output=false;
if(form.searchFormEnabledDropDownMenus){
	ts.output=true;
	if(form.searchFormLabelOnInput){
		ts.selectLabel="Water/Frontage";
		ts.inlineStyle="width:#form.searchFormSelectWidth#;";
	}else{
		ts.label="Water/Frontage:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{

	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(form.searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Water/Frontage:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_frontage"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_frontage"]=theCriteriaHTML;
</cfscript>



<cfif request.zos.isTestServer>

<!--- START TEST SERVER ONLY --->



<cfsavecontent variable="theCriteriaHTML">
<!---<cfif structkeyexists(form.searchFormHideCriteria, 'more_options') EQ false and application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false)>--->
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_near_coordinates') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable,'search_near_coordinates') EQ 1)>

<div class="zmlsformdiv">
<cfsavecontent variable="featureHTML2"> 
Type street address<br />
including city &amp; state:<br />

<cfscript>
ts=StructNew();
//ts.label="Location:";
ts.name="search_near_coordinates";

if ( structKeyExists( form, 'search_near_coordinates' ) ) {
	ts.value = form.search_near_coordinates;
}

rs=application.zcore.functions.zInput_Hidden(ts);

application.zcore.functions.zRequireGoogleMaps();

</cfscript>


<input data-address-coordinates="search_near_coordinates" type="text" name="searchNearLocation" id="searchNearLocation" size="15" value="<cfif application.zcore.functions.zso(form, 'searchNearLocation') NEQ "">#searchNearLocation#<cfelse>#application.zcore.functions.zso(form, 'search_near_location')#</cfif>" class="zGoogleAddressAutoComplete" data-disable-geolocate="1" />
<div class="zsearchformhr"></div>
<br style="clear:both;" />
Set Radius Distance: <br style="clear:both;" />

<cfscript>
ts = StructNew();
ts.name="search_near_radius";
ts.hideselect=true;
ts.listValuesDelimiter="|";
ts.listValues ="5|10|25|50|75|100";
ts.listLabels ="5|10|25|50|75|100";
ts.listLabelsDelimiter="|";
ts.onchange="zAjaxMapCoordinatesRadiusChange();";
ts.output=true;
ts.selectLabel="Radius";
//ts.inlineStyle="width:#replace(form.searchFormSelectWidth,"px","")-20#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript> (In Miles)<br style="clear:both;" />
<div id="zNearCoordinatesDiv" style="display:none;">
<div class="zsearchformhr"></div><br style="clear:both;" />
Click &quot;Set&quot; to recenter<br />
 the map or &quot;Cancel&quot;.<br />

<input type="button" name="setNearCoordinates" onclick="zAjaxSetNearCoordinates();" value="Set" /> <input type="button" name="cancelNearAddress" onclick="zAjaxCancelNearCoordinates();" value="Cancel" />
</div>
</cfsavecontent>
<cfscript>
if(form.searchFormEnabledDropDownMenus){
	//writeoutput(featureHTML2);	
}else{
	if(form.searchDisableExpandingBox){
		writeoutput(featureHTML2);
	}else{
		ts=StructNew();
		//ts.zExpOptionValue=rs.zExpOptionValue;
		ts.label="Near Location:";
		ts.contents=featureHTML2;
			ts.height=28 + 145;
		ts.width="165";
		ts.zMotionEnabled=true;
		if(application.zcore.functions.zso(form, 'search_near_coordinates') NEQ ""){
			ts.zMotionOpen=true;
		}else{
			ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_near_coordinates"];
		}
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript></div>
<!--- <div class="zmlsformdiv">
<cfsavecontent variable="featureHTML2"> 
Type street address<br />
including city &amp; state:<br />

<cfscript>
ts=StructNew();
//ts.label="Location:";
ts.name="search_near_address";
rs=application.zcore.functions.zInput_Hidden(ts);
</cfscript>
<input type="text" name="searchNearAddress" id="searchNearAddress" size="15" onkeyup="zNearAddressChange(this);" value="<cfif application.zcore.functions.zso(form, 'searchNearAddress') NEQ "">#searchNearAddress#<cfelse>#application.zcore.functions.zso(form, 'search_near_address')#</cfif>" />
<div class="zsearchformhr"></div>
<br style="clear:both;" />
Set Radius Distance: <br style="clear:both;" />

<cfscript>
ts = StructNew();
ts.name="search_near_radius";
ts.hideselect=true;
ts.listValuesDelimiter="|";
ts.listValues ="0.1|0.25|0.50|0.75|1|1.25|1.5|2|3|4|5|10|15|20|25|30|40|50";
ts.listLabels ="0.1|0.25|0.50|0.75|1|1.25|1.5|2|3|4|5|10|15|20|25|30|40|50";
ts.listLabelsDelimiter="|";
ts.onchange="zAjaxMapRadiusChange();";
ts.output=true;
ts.selectLabel="Radius";
//ts.inlineStyle="width:#replace(form.searchFormSelectWidth,"px","")-20#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript> (In Miles)<br style="clear:both;" />
<div id="zNearAddressDiv" style="display:none;">
<div class="zsearchformhr"></div><br style="clear:both;" />
Click &quot;Set&quot; to recenter<br />
 the map or &quot;Cancel&quot;.<br />

<input type="button" name="setNearAddress" onclick="zAjaxSetNearAddress();" value="Set" /> <input type="button" name="cancelNearAddress" onclick="zAjaxCancelNearAddress();" value="Cancel" />
</div>
</cfsavecontent>
<cfscript>
if(form.searchFormEnabledDropDownMenus){
	//writeoutput(featureHTML2);	
}else{
	if(form.searchDisableExpandingBox){
		writeoutput(featureHTML2);
	}else{
		ts=StructNew();
		//ts.zExpOptionValue=rs.zExpOptionValue;
		ts.label="Near Location:";
		ts.contents=featureHTML2;
			ts.height=28 + 145;
		ts.width="165";
		ts.zMotionEnabled=true;
		if(application.zcore.functions.zso(form, 'search_near_address') NEQ ""){
			ts.zMotionOpen=true;
		}else{
			ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_near_address"];
		}
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript></div> --->
<!---</cfif>--->
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_near_coordinates"]=theCriteriaHTML;
</cfscript>


<!--- END TEST SERVER ONLY --->

</cfif>






<cfsavecontent variable="theCriteriaHTML">
<cfif request.cgi_script_name NEQ "/z/listing/admin/search-filter/index">
<cfif structkeyexists(form.searchFormHideCriteria, 'more_options') EQ false>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_more_options') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_more_options') EQ 1)>
<cfset addHeight=0>
<div class="zmlsformdiv">
<cfsavecontent variable="featureHTML"> 
Use a comma to separate<br />
multiple words/phrases<br />
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_subdivision') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_subdivision') EQ 1)>
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Type Subdivisions:";
ts.name="search_subdivision";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript><br style="clear:both;" />
<div class="zsearchformhr"></div>
</cfif>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_condoname') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT <!--- cast(group_concat(distinct listing_frontage SEPARATOR #db.param(',')#) AS CHAR) idlist ---> count(listing_id) count from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
    listing_deleted = #db.param(0)# and 
    listing_condoname not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qCname=db.execute("qCname");
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_condoname=qCName;
}
    </cfscript>

<cfelse>
	<cfscript>
	qCname=application.zcore.searchFormCache[request.zos.globals.id].search_condoname;
	</cfscript>
</cfif>
<cfif qCname.count NEQ 0>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_condoname') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_condoname') EQ 1)>
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Type Building Name:";
ts.name="search_condoname";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript><br style="clear:both;" />
<div class="zsearchformhr"></div>
</cfif>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_remarks') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_remarks') EQ 1)>
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Type Keywords:";
ts.name="search_remarks";
//ts.onchange="zToggleSortFormBox();";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript><br style="clear:both;" />
<div class="zsearchformhr"></div>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_remarks_negative') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_remarks_negative') EQ 1)>
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Excluding These Keywords:";
ts.name="search_remarks_negative";
//ts.onchange="zToggleSortFormBox();";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript><br style="clear:both;" />
<div class="zsearchformhr"></div>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_zip') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_zip') EQ 1)>
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Zip Code:";
ts.name="search_zip";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript><br style="clear:both;" />
<div class="zsearchformhr"></div>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_address') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_address') EQ 1)>
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Street Address:";
ts.name="search_address";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript><br style="clear:both;" />
<div class="zsearchformhr"></div> 

</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_mls_number_list') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_mls_number_list') EQ 1)>
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="MLS ##(s):";
ts.name="search_mls_number_list";
//ts.onchange="zToggleSortFormBox();";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript><br style="clear:both;" />
<div class="zsearchformhr"></div>
</cfif>

<div style="clear:both;width:100%; ">
<cfscript>
if(application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false) EQ false or (isDefined('request.zForceSearchFormInclude') EQ false and request.cgi_script_name NEQ '/z/listing/search-form/index' )){
	form.mapNotAvailable=1;
}else{
	form.mapNotAvailable=0;
}
	ts=StructNew();
	ts.name="mapNotAvailable";
	application.zcore.functions.zInput_Hidden(ts);

addHeight+=19;
ts = StructNew();
ts.name="search_with_pool";
ts.disableExpOptionValue=true;
ts.listLabels ="Must have a pool?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);

addHeight+=19;
ts = StructNew();
ts.name="search_with_photos";
ts.disableExpOptionValue=true;
ts.listLabels ="Must have photos?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>

<cfif application.zcore.app.getAppData("listing").sharedStruct.agentSQL NEQ "">
<cfscript>
addHeight+=19;
ts = StructNew();
ts.name="search_agent_only";
ts.disableExpOptionValue=true;
ts.listLabels ="Agent Listings Only?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
</cfif>

<cfif application.zcore.app.getAppData("listing").sharedStruct.officeSQL NEQ "">

<cfscript>
addHeight+=19;
ts = StructNew();
ts.name="search_office_only";
ts.disableExpOptionValue=true;
ts.listLabels ="Firm Listings Only?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>

</cfif>

<cfscript>
addHeight+=19;
ts = StructNew();
ts.name="search_surrounding_cities";
ts.disableExpOptionValue=true;
ts.listLabels ="Surrounding Cities?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
<!--- <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only NEQ 1>
<cfscript>
ts = StructNew();
ts.name="search_sortppsqft";
ts.disableExpOptionValue=true;
ts.listLabels ="Sort by Price/SQFT?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
</cfif> --->
<cfif application.zcore.app.getAppData("listing").sharedStruct.agentSQL NEQ "">
<cfscript>
addHeight+=19;
ts = StructNew();
ts.name="search_agent_always";
ts.disableExpOptionValue=true;
ts.listLabels ="Similar Agent Listings?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
</cfif>

<cfif application.zcore.app.getAppData("listing").sharedStruct.officeSQL NEQ "">
<cfscript>
addHeight+=19;
ts = StructNew();
ts.name="search_office_always";
ts.disableExpOptionValue=true;
ts.listLabels ="Similar Firm Listings?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
</cfif>
<cfif application.zcore.app.getAppData("listing").sharedStruct.agentSQL NEQ "">
<cfscript>
if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_sort_agent_top') EQ false or application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_sort_agent_top EQ 0){
	addHeight+=19;
	ts = StructNew();
	ts.name="search_sort_agent_first";
	ts.disableExpOptionValue=true;
	ts.listLabels ="Sort Agent Listings First?";
	ts.listValues ="1";
	ts.output=true;
	application.zcore.functions.zInput_Checkbox(ts);
}
</cfscript>
</cfif>
<cfif application.zcore.app.getAppData("listing").sharedStruct.officeSQL NEQ "">
<cfscript>
if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_sort_office_top') EQ false or application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_sort_office_top EQ 0){
	addHeight+=19;
	ts = StructNew();
	ts.name="search_sort_office_first";
	ts.disableExpOptionValue=true;
	ts.listLabels ="Sort Firm Listings First?";
	ts.listValues ="1";
	ts.output=true;
	application.zcore.functions.zInput_Checkbox(ts);
}
</cfscript>
</cfif>

<!--- <cfif isDefined('request.contentEditor') EQ false> --->
<div id="zSearchFormWithinMapDiv">
<cfscript>
addHeight+=19;
backupSearchWithinMap=application.zcore.functions.zso(form, 'search_within_map',true);
ts = StructNew();
ts.name="search_within_map";
ts.disableExpOptionValue=true;
ts.onchange="if(typeof zSetWithinMap !='undefined'){zSetWithinMap(this.value);}";
ts.listLabels ="Search within Map?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
</div>
<!--- </cfif> --->

<cfscript>
/*
ts = StructNew();
ts.name="search_map_coordinates_list2";
ts.output=true;
application.zcore.functions.zInput_Hidden(ts);
*/
if(application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false)){
	ts = StructNew();
	ts.name="search_map_coordinates_list";
	ts.output=true;
	application.zcore.functions.zInput_Hidden(ts);
	ts = StructNew();
	ts.name="search_map_long_blocks";
	ts.output=true;
	application.zcore.functions.zInput_Hidden(ts);
	ts = StructNew();
	ts.name="search_map_lat_blocks";
	ts.output=true;
	application.zcore.functions.zInput_Hidden(ts);
}
</cfscript>
</div>
<!--- <div id="zSortFormBox2" style="display:none;">
<span style="font-size:12px;font-weight:bold;">Sort By: Relevance</span><br />
Required when keyword<br />search is used.
</div>
<div id="zSortFormBox"> --->
<!--- <br style="clear:both;" /></div><br style="clear:both;" /> --->

<div style="padding-bottom:5px;padding-top:5px;clear:both;width:100%; ">

<cfif structkeyexists(form, 'search_list_date') and structkeyexists(form, 'search_max_list_date') and form.search_list_date NEQ "" and form.search_max_list_date NEQ "">

LIST DATE RANGE:<br />
	<cfscript>
    addHeight+=45;
    
    ts = StructNew();
    ts.name="search_list_date";
    application.zcore.functions.zInput_hidden(ts);
    ts = StructNew();
    ts.name="search_max_list_date";
    application.zcore.functions.zInput_hidden(ts);
    </cfscript>
    #dateformat(form.search_list_date, "m/d/yy")&" "&timeformat(form.search_list_date, "h:mmtt")# to<br />
    #dateformat(form.search_max_list_date,"m/d/yy")&" "&timeformat(form.search_max_list_date, "h:mmtt")#<br />
    <a href="##" onclick="document.getElementById('search_list_date').value='';document.getElementById('search_max_list_date').value=''; document.getElementById('zMLSSearchForm').submit();">Remove Date Range Filter</a>
<cfelse>
LIST DATE:<br />
	<cfscript>
    addHeight+=55;
    ts = StructNew();
    ts.name="search_listdate";
    ts.hideselect=true;
    ts.listValuesDelimiter="|";
    ts.listValues ="Show All|New|Up to 3 days old|Up to 1 week old|Up to 2 weeks old|Up to 1 month old|Up to 3 months old|Up to 6 months old|Up to 12 months old";
    ts.listLabels ="Show All|New|Up to 3 days old|Up to 1 week old|Up to 2 weeks old|Up to 1 month old|Up to 3 months old|Up to 6 months old|Up to 12 months old";
    ts.listLabelsDelimiter="|";
    ts.output=true;
    ts.selectLabel="List Date";
    //ts.inlineStyle="width:#replace(form.searchFormSelectWidth,"px","")-20#px;";
        application.zcore.functions.zInputSelectBox(ts);
    </cfscript>

</cfif>
</div>

<div style="padding-bottom:5px;padding-top:5px;clear:both;width:100%; ">
## of Results:<br />

	<cfsavecontent variable="theCriteriaHTML4">
	<cfscript>
	addHeight+=55;
	ts = StructNew();
	ts.name="search_result_limit";
	ts.hideselect=true;
	ts.listValuesDelimiter="|";
	if(structkeyexists(form, 'search_result_layout') and form.search_result_layout EQ 2){
		ts.listValues ="9|15|21|27|33|39|45|54";
	}else{
		ts.listValues ="10|15|20|25|30|35|40|50";
	}
	ts.listLabels =ts.listValues;
	ts.listLabelsDelimiter="|";
	ts.output=true;
	ts.selectLabel="List Date";
	//ts.inlineStyle="width:#replace(form.searchFormSelectWidth,"px","")-20#px;";
		application.zcore.functions.zInputSelectBox(ts);
	</cfscript>
	</cfsavecontent>
	<cfscript>
	sfSortStruct["search_result_limit"]=theCriteriaHTML4;
	</cfscript>
	#theCriteriaHTML4#
</div>
<!--- <br style="clear:both;" /><div style="height:10px; width:100%; "></div><br style="clear:both;" /> --->
<div style="padding-bottom:5px;clear:both;width:100%; ">

GROUP BY:<br />
<cfscript>
addHeight+=55;
ts = StructNew();
ts.name="search_group_by";
ts.hideselect=true;
ts.listValuesDelimiter="|";
ts.listValues ="0|1";
ts.listLabels ="No Grouping|Bedrooms";
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="Layout";
ts.inlineStyle="width:100%;";//#min(140,replace(form.searchFormSelectWidth,"px","")-20)#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript>
</div>
<div style="padding-bottom:5px;clear:both;width:100%; ">
LAYOUT:<br />
<cfscript>
addHeight+=55;
ts = StructNew();
ts.name="search_result_layout";
ts.hideselect=true;
ts.listValuesDelimiter="|";
ts.listValues ="0|1|2";
ts.listLabels ="Detail|List|Grid";
ts.listLabelsDelimiter="|";
ts.onchange="zMLSUpdateResultLimit(this.options[this.selectedIndex].value);";
ts.output=true;
ts.selectLabel="Layout";
ts.inlineStyle="width:100%;";//#min(140,replace(form.searchFormSelectWidth,"px","")-20)#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript>
</div>
<div style="padding-bottom:5px;clear:both;width:100%; ">
SORT BY:<br />
	<cfsavecontent variable="theCriteriaHTML4">
<cfscript>
addHeight+=55;
ts = StructNew();
ts.name="search_sort";
ts.hideselect=true;
ts.listValuesDelimiter="|";
if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
	ts.listValues ="priceasc|pricedesc|newfirst|nosort";
	ts.listLabels ="Price Ascending|Price Descending|Newest Listings First|No Sorting";
}else{
	ts.listValues ="priceasc|pricedesc|newfirst|nosort|sortppsqftasc|sortppsqftdesc";
	ts.listLabels ="Price Ascending|Price Descending|Newest Listings First|No Sorting|Price/SQFT Ascending|Price/SQFT Descending";
}
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="Sort";
ts.inlineStyle="width:100%;";//#min(140,replace(form.searchFormSelectWidth,"px","")-20)#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript>
	</cfsavecontent>
	<cfscript>
	sfSortStruct["search_sort"]=theCriteriaHTML4;
	</cfscript>
	#theCriteriaHTML4#
</div>



<!--- </div>
<script type="text/javascript">zToggleSortFormBox();</script> --->
<!---  ---><!--- 
<cfsavecontent variable="theSearchWithinText">
<input type="checkbox" name="search_within_map" class="input-plain" value="1" <cfif application.zcore.functions.zso(form, 'within_map') EQ 1>checked="checked"</cfif>> <label for="search_within_map">Search within map?</label> <br />
</cfsavecontent>
<script type="text/javascript">
if(GMap){
    document.write('#JSStringFormat(theSearchWithinText)#');
}
</script> --->

<!--- <cfscript>
ts = StructNew();
ts.name="search_new_first";
ts.disableExpOptionValue=true;
ts.listLabels ="Newest Listings First?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript> --->
</cfsavecontent>
<cfscript>
if(form.searchFormEnabledDropDownMenus){
	//writeoutput(featureHTML);	
}else{
	if(form.searchDisableExpandingBox){
		writeoutput(featureHTML);
	}else{
		ts=StructNew();
		//ts.zExpOptionValue=rs.zExpOptionValue;
		ts.label="More Options:";
		ts.disableOverflow=true;
		ts.contents=featureHTML;
		ts.height=45 + addHeight;
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_more_options"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
<input type="hidden" name="searchgotolistings" id="searchgotolistings" value="0" />
<cfif request.cgi_script_name EQ '/z/listing/search-form/index' and application.zcore.functions.zso(form, 'searchgotolistings') NEQ 1>
<script type="text/javascript">
/* <![CDATA[ */
//setTimeout("jumpToSearchForm();",100);
/* ]]> */
</script>
</cfif>
</div>
</cfif>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_more_options"]=theCriteriaHTML;



</cfscript> 
<cfscript>
if(structkeyexists(request,'theSearchFormTemplate') EQ false){ 
	if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'sort')){
		arrKey=structkeyarray(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.sort);
		arraysort(arrKey,"numeric","asc");
		for(i=1;i LTE arraylen(arrKey);i++){
			if(structkeyexists(sfSortStruct,application.zcore.app.getAppData("listing").sharedStruct.filterStruct.sort[arrKey[i]])){
				writeoutput(sfSortStruct[application.zcore.app.getAppData("listing").sharedStruct.filterStruct.sort[arrKey[i]]]);
			}
		}
	}else{
		for(i in sfSortStruct){
			writeoutput(sfSortStruct[i]);
		}
	}
}


</cfscript>

<cfif request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' and isDefined('mls_saved_search_id')>
	  <cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	WHERE mls_saved_search_id = #db.param(mls_saved_search_id)# and 
	site_id = #db.param(request.zos.globals.id)#
	</cfsavecontent><cfscript>qSaved=db.execute("qSaved");</cfscript>
<div class="zmlsformdiv">
<cfsavecontent variable="theHTML">
	<input type="hidden" name="mls_saved_search_id" value="#mls_saved_search_id#" />
	Format:<br />
<input type="radio" name="saved_search_format" value="1" style="background:none; border:0px; " <cfif qsaved.saved_search_format EQ '1'>checked="checked"</cfif> /> Text w/Photos 
	<input type="radio" name="saved_search_format" value="0" <cfif qsaved.saved_search_format EQ '0'>checked="checked"</cfif> style="background:none; border:0px; " /> Text<br />

	Frequency:<br />
<input type="radio" name="saved_search_frequency" value="0" style="background:none; border:0px; " <cfif qsaved.saved_search_frequency EQ 0>checked="checked"</cfif> /> Every Day 
	<input type="radio" name="saved_search_frequency" value="1" <cfif qsaved.saved_search_frequency EQ '1'>checked="checked"</cfif> style="background:none; border:0px; " /> Fridays<br />
	</cfsavecontent>
<cfscript>
	ts=StructNew();
	//ts.zExpOptionValue=rs.zExpOptionValue;
	ts.label="Email Alert Options:";
	ts.contents=theHTML;
	ts.height=90;
	ts.width="165";
	ts.zMotionEnabled=true;
	ts.zMotionOpen=true;
	application.zcore.functions.zExpOption(ts);
</cfscript>
</div>
</cfif>
<cfif application.zcore.functions.zso(request,'zDisableSearchFormSubmit',false,false) EQ false>
<div class="zmlsformdiv">

<cfscript>
if(structkeyexists(request,'theSearchFormTemplate') EQ false){
	ts=StructNew();
	// required
	ts.name="formSubmit";
	ts.value="Show Results";
	// optional
	ts.friendlyName="";
	if(isDefined('searchFormSubmitButtonClass')){
		ts.className=searchFormSubmitButtonClass;
		ts.imageInput=false;
		ts.useAnchorTag=true;
	}else if(isDefined('searchFormSubmitButtonStyle')){
		ts.style=searchFormSubmitButtonStyle;
		ts.imageInput=false;
		ts.useAnchorTag=true;
	}else{
		ts.className="zSearchFormButton";
		/*
		//
		if(isDefined('imageUrl')){
			ts.imageUrl=imageUrl;
		}
		else{
			ts.imageUrl="/z/a/listing/images/search-mls-button.gif";
		}
		ts.imageInput=true;
		*/
		//ts.style="border:1px solid ##FFF !important; background-color:##000 !important; color:##FFF !important; font-size:130% !important; line-height:130% !important; padding:5px !important; cursor:pointer !important;";
		//	ts.style="font-size:18px; width:165px; padding:5px; background-color:##BBBBBB; color:##000000; border:1px solid ##000000; text-decoration:underline; cursor:pointer;";
	}
	if(request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' and isDefined('mls_saved_search_id')){
		ts.value="UPDATE SAVED SEARCH";
		ts.useAnchorTag=false;
		ts.imageInput=false;
		ts.style="padding:5px;";
		writeoutput('<script type="text/javascript">/* <![CDATA[ */zDisableSearchFormSubmit=true;/* ]]> */</script>');
		//searchFormSubmitButtonClass="zSavedSearchButton";
		//writeoutput("<style type=""text/css"">.zSavedSearchButton {font-size:13px; font-weight:bold; line-height:21px; border:1px solid ##000; background-color:##FFF; padding:5px; margin-top:10px;) .zSavedSearchButton a:link, .zSavedSearchButton a:visited{ color:##369; } .zSavedSearchButton a:hover{ color:##0F0; }</style>");
	}
	ts.onclick="";
	application.zcore.functions.zInput_submit(ts);
	if(request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' and isDefined('mls_saved_search_id')){
		writeoutput('<br /><input type="button" name="cancel1" value="Cancel" style="padding:5px; margin-top:5px;" onclick="window.location.href=''/z/listing/property/your-saved-searches/index'';" />');	
	}
	writeoutput('<br style="clear:both;" /><br /><span class="zSearchFormText">');
	if(form.searchFormEnabledDropDownMenus){
		writeoutput('<a href="#request.zos.listing.functions.getSearchFormLink()#" class="zNoContentTransition"><strong style="font-size:14px;">+ Show more options</strong><br />(i.e. Subdivision, zip code, <br />keyword search)</a>');
	}
	/*if(isDefined('request.zsession.user.id') EQ false){
		writeoutput('<br /><br /><a href="/z/user/preference/index" style="font-size:14px; font-weight:bold;">Login/Create Account</a>');
	}else{
		writeoutput('<br /><br /><span style="font-size:14px; font-weight:bold;">Logged in as #request.zsession.user.first_name#,<br />
	<a href="/?zlogout=1">LOG OUT</a></span>');
	}*/
    writeoutput('</span>');	
}
</cfscript>
</div>
</cfif>
<!--- </table> --->
</div>
<cfsavecontent variable="endFormTagHTML">
<cfscript>
if(request.cgi_script_name EQ "/z/listing/search-form/index" OR isDefined('request.contentEditor')){
	if(structkeyexists(request.zos.tempObj,'getMLSCountOutput') EQ false){
		request.zos.tempObj.getMLSCountOutput=true;
		writeoutput('<script type="text/javascript">/* <![CDATA[ */zArrDeferredFunctions.push(function(){getMLSCount(''zMLSSearchForm'');});/* ]]> */</script>');
	}
}
if(isDefined('request.contentEditor') EQ false){
	application.zcore.functions.zEndForm();
}
</cfscript>
 </cfsavecontent>
 <cfscript>
sfSortStruct["endFormTag"]=endFormTagHTML;
writeoutput(endFormTagHTML);

if(structkeyexists(request,'theSearchFormTemplate')){
	request.zMLSHideCount=true;
	
	for(i in sfSortStruct){
		if(left(trim(sfSortStruct[i]),'4') EQ '<tr>'){
			request.theSearchFormTemplate=replace(request.theSearchFormTemplate,"##"&i&"##","<table class=""zquicksearchpaddingfix"" style=""width:100%;"">"&sfSortStruct[i]&"</table>","ALL");
		}else{
			request.theSearchFormTemplate=replace(request.theSearchFormTemplate,"##"&i&"##",sfSortStruct[i],"ALL");
		}
	}
	sfSortStruct2=structnew();
	sfSortStruct2["searchFormSubmitURL"]=htmleditformat(tempSearchFormAction);
	sfSortStruct2["searchFormAdvancedURL"]=request.zos.listing.functions.getSearchFormLink();
	for(i in sfSortStruct2){
		request.theSearchFormTemplate=replace(request.theSearchFormTemplate,"##"&i&"##",sfSortStruct2[i],"ALL");
	}
	request.theSearchFormTemplate=request.theSearchFormTemplate;
}
</cfscript>
</cfsavecontent>
<cfscript>
sidebarOutput=false;
if(request.zos.originalURL EQ "/z/listing/search-form/index"){
	form.outputSearchForm=false;
}
if(structkeyexists(request,'theSearchFormTemplate')){
	writeoutput(request.theSearchFormTemplate);	
}else if(isDefined('request.contentEditor')){
	writeoutput(searchFormHTML);	
}else if(structkeyexists(form, 'outputSearchForm') and form.outputSearchForm){
	writeoutput(searchFormHTML);
}else{
	sidebarOutput=true;
	application.zcore.template.setTag("sidebar",searchFormHTML);
}
</cfscript>
<!--- </cfthread>
<cfthread action="run" name="zThreadListingSearchFormListings"> --->

<cfscript>

	structdelete(variables,'request.zos.listing');
	structdelete(form,'fieldnames');
	for(i in url){
		if(isSimpleValue(url[i])){
			form[i]=url[i];
		}
	} 
	for(i in form){
		if(structkeyexists(form,i) EQ false){ 
		}else if(isSimpleValue(form[i])){
			form[i]=urldecode(form[i]);
		}
	} 
propertyDataCom.setSearchCriteria(form);
</cfscript>
<cfif isDefined('request.contentEditor')> <div id="mlsResults" style="padding-left:10px;vertical-align:top;"></cfif>
<cfif application.zcore.functions.zso(form, 'outputSearchForm',false,false) EQ false>
<cfif isDefined('request.contentEditor') EQ false and isDefined('request.hideMLSResults') EQ false> 
    <div style="font-size:130%; width:100%; float:left;" id="zls-searchformusemessage">Use the form on the sidebar to search.</div>
<div id="mlsResults" style="width:100%; float:left; margin-bottom:20px;">

	<div id="zls-search-form-top-map-text">
		<div style="width:50%; margin-bottom:20px; float:left;">
			<div id="zls-searchformhelpdiv">
				<a href="##" onclick="zToggleDisplay('zListingHelpDiv');return false;">Need help using search?</a>
				</div> 
				<cfscript>
				if(isDefined('request.zsession.zListingHideMap') EQ false){
					request.zsession.zListingHideMap=false;
				}
				if(structkeyexists(form, 'zListingHideMap')){
					if(form.zListingHideMap EQ 1){
						request.zsession.zListingHideMap=true;	
					}else{
						request.zsession.zListingHideMap=false;
					}
				}
				if(structkeyexists(form, 'searchId') EQ false and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_hide_map_until_search') EQ 1){
					tempHideMap=true;	
				}else{
					tempHideMap=false;
				}

				</cfscript>

			</div>
			<div style="width:50%; margin-bottom:20px; float:left;  text-align:right; font-size:110%; font-weight:bold;">&nbsp;
				<cfif application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false) and tempHideMap EQ false>
					<cfif (isDefined('request.zsession.zListingHideMap') EQ false or request.zsession.zListingHideMap EQ false) and tempHideMap EQ false>
						<a href="##" onclick="zlsOpenResultsMap(); return false;">Fullscreen Map</a> | 
						<a id="zHideMapSearchButton" href="/z/listing/search-form/index?searchId=#form.searchId#&amp;zIndex=#form.zIndex#&amp;zListingHideMap=1">Hide Map Search</a>
					<cfelse>
						<a id="zHideMapSearchButton" href="/z/listing/search-form/index?searchId=#form.searchId#&amp;zIndex=#form.zIndex#&amp;zListingHideMap=0">Show Map</a>
					</cfif>
				</cfif>
			</div> 
		</div>
	</div> 
	<div id="zListingHelpDiv" style="display:none; margin-bottom:10px;border:1px solid ##990000; padding:10px; padding-top:10px;">
		<p style="font-size:14px; font-weight:bold;">Search Directions:</p>
		<p>Click on one of the search options on the sidebar and use the text fields, sliders and check boxes to enter your search data.  After you are done, click "Show Results" and the results will load on the right. </p>
		<p><strong>City Search:</strong> Start typing a city into the box and our system will automatically show you a list of matching cities.  Select each city you wish to include in the search by using the arrow keys up and down.  Please the enter key or left click with your mouse to confirm the selection.  To remove a city, click the "X" button to the left of the city name. Only cities matching the ones in our system may be selected.</p>
		<p>After typing an entry, click "Update Results" to update your search. </p>
		<p>You can select or type as many options as you want.</p>
		<p>Your search will automatically show the ## of matching listings as you update each search field.</p>
		<p>After searching, only the available options will appear.  To reveal more options again, try unselecting or extending the range for your next search.</p>
	</div>
	<cfscript> 
		ts = StructNew();
		ts.offset = form.zIndex-1;
		perpageDefault=10;
		if(structkeyexists(form, 'searchId')){
			form.search_result_limit=application.zcore.status.getField(form.searchId, "search_result_limit");
		}
		if(structkeyexists(form, 'search_result_limit') and isnumeric(form.search_result_limit) and form.search_result_limit GTE 9){
			perpage=form.search_result_limit;
		}else{
			perpage=10;
		}
		perpage=max(1,min(perpage,100));
		ts.perpage = perpage;
		ts.distance = 30; // in miles
		//ts.searchCriteria=structnew();
		//structappend(ts.searchCriteria,form);
		//zdump(form);
		//	ts.debug=true;
		if(form.debugSearchForm or form.debugSearchResults){
			ts.debug=true;
		} 
		ts.enableThreading=false;
		returnStruct = propertyDataCom.getProperties(ts);
 
		structdelete(variables,'ts'); 
		mapQuery = returnStruct; 
		if(returnStruct.count NEQ 0){
			searchStruct = StructNew();
			searchStruct.showString = "";
			searchStruct.indexName = 'zIndex';
			searchStruct.url = "/z/listing/search-form/index";
			if(structkeyexists(form, 'searchId')){
				searchStruct.url &= "?searchId=#form.searchId#"; 
				searchStruct.index = form.zIndex;
			}else{
				searchStruct.index=1;
			}
			searchStruct.buttons = 5;
			searchStruct.count = returnStruct.count;
			searchStruct.perpage = perpage;
			
			ts = StructNew();
			ts.dataStruct = returnStruct;
			ts.navStruct=searchStruct;
			if(isDefined('propertyDataCom.searchCriteria.search_result_layout')){
				ts.search_result_layout=propertyDataCom.searchCriteria.search_result_layout;
				if(ts.search_result_layout EQ 2){
					ts.datastruct.perpage=int(ts.datastruct.perpage/3)*3;
				}
			}
			if(isDefined('propertyDataCom.searchCriteria.search_group_by') and propertyDataCom.searchCriteria.search_group_by EQ "1"){
				ts.groupBedrooms=true;
				ts.search_result_layout=1;
			}
			if(structkeyexists(ts,'search_result_layout') and ts.search_result_layout EQ 2){
				ts.getDetails=false;
			}
			ts.searchId=form.searchId;
			request.zsession.tempVars.zListingSearchId=form.searchId;
			propDisplayCom.init(ts);
			if(returnStruct.count NEQ 0 and (isnumeric(application.zcore.functions.zso(form, 'searchId')) or structkeyexists(form,'searchaction'))){
				res=propDisplayCom.display();
			}
		}
		</cfscript>	

        <cfif structkeyexists(application.sitestruct[request.zos.globals.id], 'zListingMapCheck') and isDefined('request.zsession.zListingHideMap') and request.zsession.zListingHideMap EQ false and tempHideMap EQ false>
        <cfscript>
		ms={
			mapQuery=mapQuery,
			propertyDataCom=propertyDataCom 
		}
		mapCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.map");
		mapCom.index(ms);
		</cfscript><br />
            </cfif>
		<cfif returnStruct.count NEQ 0>
            <cfif isnumeric(application.zcore.functions.zso(form, 'searchId')) or structkeyexists(form,'searchaction')>

 		<input type="hidden" name="zlsHoverBoxDisplayType" id="zlsHoverBoxDisplayType" value="<cfif application.zcore.functions.zso(form, 'search_result_layout') NEQ ""><cfif form.search_result_layout EQ 0>detail<cfelseif form.search_result_layout EQ 1>list<cfelseif form.search_result_layout EQ 2>grid<cfelse>detail</cfif><cfelse>detail</cfif>" />
        <div id="zls-matchinglistingsdiv" style="width:100%;">
            <div class="zls-hover-box1">
	            <a href="##" id="zls-hover-box-map-button" style="float:right; display:none;">MAP</a>
	            <a href="##" id="zls-hover-box-detail-button" style="float:right;">DETAIL</a>
	            <a href="##" id="zls-hover-box-list-button" style="float:right;">LIST</a>
	            <a href="##" id="zls-hover-box-grid-button" style="float:right;">GRID</a>
	        </div>
            <h2>Matching Listings</h2>
    	</div>
		<cfscript>
			writeoutput(res);
		</cfscript>
        </cfif>
		<h2><a href="##searchFormTopDiv">Revise Search</a></h2>
	</cfif>
    
    <cfif structkeyexists(form, 'searchId') EQ false>
    <div style="width:100%; height:500px;">&nbsp;</div>
    </cfif> 

	<cfscript>
	if(request.cgi_script_name EQ "/z/listing/search-form/index" OR isDefined('request.contentEditor')){
		if(isDefined('request.zMLSHideCount') EQ false){
			if(sidebarOutput){
				if(structkeyexists(request.zos.tempObj,'getMLSCountOutput') EQ false){
					request.zos.tempObj.getMLSCountOutput=true;
						application.zcore.template.appendTag("sidebar",'<script type="text/javascript">/* <![CDATA[ */    zArrDeferredFunctions.push(function(){getMLSCount(''zMLSSearchForm'')});  /* ]]> */</script>');	
				}
			}else{
				if(structkeyexists(request.zos.tempObj,'getMLSCountOutput') EQ false){
					request.zos.tempObj.getMLSCountOutput=true;
					writeoutput('<script type="text/javascript">/* <![CDATA[ */zArrDeferredFunctions.push(function(){getMLSCount(''zMLSSearchForm'')});   /* ]]> */</script>');
				}
			}
		}
	} 
	</cfscript>
<cfelse>
        
<cfif isDefined('request.contentEditor') EQ false>
    	<cfscript>
		ts=structnew();
		ts.content_unique_name='/z/listing/search-form/index';
		ts.disableContentMeta=false;
		ts.disableLinks=true;
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		if(r1 EQ false){
			inquiryTextMissing=true;
		}
		</cfscript>
        <p style="font-size:18px;">Please submit your search using the <strong>search form on the sidebar</strong>.</p>
        <p>Expand each section by clicking on the title. i.e. &quot;Sale Type&quot; or &quot;Frontage&quot; and select as many options as you like.</p>
        <p>Under price and some of the other options are 2 slider boxes. Click and drag these boxes left and right in order to quickly adjust the selection.</p>
        <cfif isDefined('request.zUsingRightSidebar')>
        <p><img src="/z/a/images/redarrowright.jpg" /></p>
        <cfelse>
        <p><img src="/z/a/images/redarrow.jpg" /></p>
        </cfif>
<script type="text/javascript">/* <![CDATA[ */zListingDisplayHelpBox();/* ]]> */</script>
        <div style="width:100%; height:500px;float:left; clear:both;"></div>
     </cfif>
     
<cfif isDefined('request.contentEditor')>
        <cfif application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false)>
        <cfscript>
		ms={
			propertyDataCom=propertyDataCom
		}
		mapCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.map");
		mapCom.index(ms);
		</cfscript><br />
            </cfif>
            </div>
            <cfif request.cgi_script_name EQ "/z/listing/search-form/index" OR isDefined('request.contentEditor')>
<cfif isDefined('request.zMLSHideCount') EQ false and isDefined('request.contentEditor')>
	<cfif structkeyexists(request.zos.tempObj,'getMLSCountOutput') EQ false>
		<cfset request.zos.tempObj.getMLSCountOutput=true><script type="text/javascript">/* <![CDATA[ */
		zArrDeferredFunctions.push(function(){getMLSCount('zMLSSearchForm');  });
	/* ]]> */</script></cfif></cfif></cfif>
</cfif>
</cfif> 
<!--- </cfthread>

<cfthread action="join" name="zThreadListingSearchForm" />

<cfthread action="join" name="zThreadListingSearchFormListings" />

#zThreadListingSearchForm.output#
#zThreadListingSearchFormListings.output#   --->

</cfif>
</cffunction>
</cfoutput> 
</cfcomponent>