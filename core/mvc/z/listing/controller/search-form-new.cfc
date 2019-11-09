<cfcomponent>
<!--- testing is done here: http://www.carlosring.com.192.168.56.104.xip.io/newsearch.cfc?method=index --->
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	variables.propertyDataCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	variables.propertyDisplayCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
	application.zcore.functions.zDisbleEndFormCheck();
	if(structkeyexists(form,'showLastSearch') and isDefined('request.zsession.tempVars.zListingSearchId')){
		form.searchId=request.zsession.tempVars.zListingSearchId;
		form.zIndex=application.zcore.status.getField(form.searchId, "zIndex",1);
	}
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		writeoutput('.<!-- stop spamming -->');
		application.zcore.functions.zabort();
	}
	 if(request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink()){
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
	application.zcore.tracking.backOneHit();

	application.zcore.functions.z404("not able to be used");
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
		application.zcore.functions.zAbort();	
	}
	header name="x_ajax_id" value="#form.x_ajax_id#";
	writeoutput(jsonText);
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="ajaxMapListing" localmode="modern" access="remote">
	<cfscript>
	var i=0;
	var start=0;
	var ts=0;
	var theHTML=0;
	
	application.zcore.tracking.backOneHit();
	if(structkeyexists(form, 'x_ajax_id') EQ false){
		application.zcore.functions.zAbort();	
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
	variables.propertyDataCom.setSearchCriteria(form);
	returnStruct = variables.propertyDataCom.getProperties(ts);
	
	request.currentmappropertylink="";
	ts = StructNew();
	ts.baseCity = 'db';
	ts.datastruct = returnStruct;
	ts.searchScript=false;
	ts.compact=true;
	ts.mapFormat=true;
	variables.propertyDisplayCom.init(ts);
	theHTML =variables.propertyDisplayCom.displayTop();
	
	header name="x_ajax_id" value="#form.x_ajax_id#";
	writeoutput('{"loadtime":"#((gettickcount()-start)/1000)# seconds","COUNT":#returnStruct.count#,"success":true,"link":"#request.currentmappropertylink#","html":"#jsstringformat(theHTML)#"}');
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="ajaxCount" localmode="modern" access="remote">
	<cfscript>
	var start=0;
	var i=0;
	var returnStruct2=0;
	var out=0;
	var maxPrice=0;
	var longSign=0;
	var mapFail=0;
	var arrLong=0;
	var arrMinLong=0;
	var arrMinLat=0;
	var arrColor=0;
	var latSign=0;
	var minPrice=0;
	var arrPrice2=0;
	var fs=0;
	var arrMaxLat=0;
	var arrPrice=0;
	var mapCoor=0;
	var arrLPrice=0;
	var arrMap2=0;
	var arrAvgLat=0;
	var arrLat=0;
	var arrCount=0;
	var color=0;
	var arrMap=0;
	var longSize=0;
	var arrId=0;
	var arrMaxLong=0;
	var latSize=0;
	var arrAvgLong=0;
	var arrCountAtAddress=0;
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
	ts.perpage = 10;
	ts.distance = 30; 
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
	variables.propertyDataCom.setSearchCriteria(form);
	returnStruct2 = variables.propertyDataCom.getProperties(ts);

	if(structkeyexists(form,'mapfullscreen')){
		structdelete(ts,'zselect');
		structdelete(ts,'zwhere');
		structdelete(ts,'contentTableEnabled');
	}
	if(structkeyexists(form,'zforcemapresults') EQ false and ((application.zcore.functions.zso(form, 'search_map_coordinates_list') EQ "" or application.zcore.functions.zso(form, 'mapNotAvailable') EQ 1) or (isDefined('request.zsession.zListingHideMap') and request.zsession.zListingHideMap EQ true))){
		jsonText='{"loadtime":"#((gettickcount()-start)/1000)# seconds","COUNT":#returnStruct2.count#,"success":true}';
	}else{
		ts.zReturnSimpleQuery=true;
		ts.disableCount=true;
		
		form.search_within_map=1;
		variables.propertyDataCom.setSearchCriteria(form);
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
			writeoutput('{"loadtime":"#((gettickcount()-start)/1000)# seconds","COUNT":0,"success":false,"errorMessage":"invalid request - mapping should be disabled (1): #form.search_map_coordinates_list#"}');
			application.zcore.functions.zabort();
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
			returnStruct = variables.propertyDataCom.getProperties(ts);
				// no grouping	
			arrayappend(arrPrice,'0');
			arrayappend(arrId,returnStruct.listing_id);
			arrayappend(arrLat,returnStruct.listing_latitude);
			arrayappend(arrLong,returnStruct.listing_longitude);
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
			ts.zgroupby="GROUP BY FLOOR(ABS(ABS(listing_latitude)-#abs(mapCoor.minLatitude)#) / #latSize#), 
			FLOOR(ABS(ABS(listing_longitude)-#abs(mapCoor.minLongitude)#) / #longSize#)";
		
			returnStruct = variables.propertyDataCom.getProperties(ts);
			structdelete(variables,'ts');
			rs=structnew();
			rs.count=returnStruct2.count;
			for(local.row in returnStruct){
				if(local.row.listing_id EQ ""){
					minPrice=min(local.row.avgprice,minPrice);
					maxPrice=max(local.row.avgprice,maxPrice);
				}else{
					arrPrice2=listtoarray(local.row.listing_price);
					for(i=1;i LTE arraylen(arrPrice2);i++){
						minPrice=min(arrPrice2[i],minPrice);
						maxPrice=max(arrPrice2[i],maxPrice);
					}
				}
			}
			for(local.row in returnStruct){
				arrayappend(arrCountAtAddress,local.row.countAtAddress);
				if(local.row.listing_id EQ ""){
					arrayappend(arrId,"0");
					if(local.row.countAtAddress EQ 1){
						arrayappend(arrLat,local.row.listing_latitude);
						arrayappend(arrLong,local.row.listing_longitude);
					}else{
						arrayappend(arrLat,0);
						arrayappend(arrLong,0);
					}
					color=11-max(1,ceiling(((local.row.avgprice-minPrice)/max(1,(maxPrice-minPrice)))*10));
					arrayappend(arrColor,color);
					arrayappend(arrCount,local.row.count);
					arrayappend(arrPrice,"$"&numberformat(local.row.avgprice));
					arrayappend(arrMinLat,local.row.latGroup);
					arrayappend(arrMinLong,local.row.longGroup);
				}else{
					arrayappend(arrId,local.row.listing_id);
					arrayappend(arrLat,local.row.listing_latitude);
					arrayappend(arrLong,local.row.listing_longitude);
					if(local.row.listing_id NEQ ""){
						arrLPrice=listtoarray(local.row.listing_price);
						for(i=1;i LTE local.row.count;i++){
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
			fs='"allMinLat":#returnstruct2.query.minlat#,"allMaxLat":#returnstruct2.query.maxlat#,"allMinLong":#returnstruct2.query.minlong#,"allMaxLong":#returnstruct2.query.maxlong#,';
		}else{
			fs="";	
		}
		jsonText='{#fs#
		"loadtime":"#((gettickcount()-start)/1000)# seconds",
		"COUNT":#returnStruct2.count#,
		success:true,
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
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="getSearchHelpBar" localmode="modern" access="private">
	<cfscript>
	var searchStruct=0;
	var res=0;
	var perpage=0;
	var returnStruct=0;
	var mapQuery=0;
	var perpageDefault=0;
	var ts=0;
	var ms=0;
	var mapCom=0;
	var tempHideMap=0;
			writeoutput('<h2 id="zls-searchformusemessage">Use the form on the sidebar to search.</h2>');
	writeoutput('<div id="mlsResults">
		<div style="width:50%; float:left;">
			<div id="zls-searchformhelpdiv"> <a href="##" onclick="zToggleDisplay(''zListingHelpDiv'');return false;">Need help using search?</a><br />
							<div id="zListingHelpDiv" style="display:none; border:1px solid ##990000; padding:10px; padding-top:0px;">
								<p style="font-size:14px; font-weight:bold;">Search Directions:</p>
								<p>Click on one of the search options on the sidebar and use the text fields, 
								sliders and check boxes to enter your search data.  
								After you are done, click "Show Results" and the results will load on the right. </p>
								<p><strong>City Search:</strong> Start typing a city into the box and our system will automatically show you a list of matching cities.  Select each city you wish to include in the search by using the arrow keys up and down.  Please the enter key or left click with your mouse to confirm the selection.  To remove a city, click the "X" button to the left of the city name. Only cities matching the ones in our system may be selected.</p>
								<p>After typing an entry, click "Update Results" to update your search. </p>
								<p>You can select or type as many options as you want.</p>
								<p>Your search will automatically show the ## of matching listings as you update each search field.</p>
								<p>After searching, only the available options will appear.  To reveal more options again, try unselecting or extending the range for your next search.</p>
							</div>
						</div>');
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
						writeoutput('</div>
					<div style="width:50%; float:left; text-align:right; font-size:14px; font-weight:bold;">&nbsp;');
						if(application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false) and tempHideMap EQ false){
							if((isDefined('request.zsession.zListingHideMap') EQ false or request.zsession.zListingHideMap EQ false) and tempHideMap EQ false){
								writeoutput('
									<a href="##" onclick="zlsOpenResultsMap(); return false;">Fullscreen Map</a> | 
									<a id="zHideMapSearchButton" href="#request.zos.listing.functions.getSearchFormLink()#?searchId=#form.searchId#&amp;zIndex=#form.zIndex#&amp;zListingHideMap=1">Hide Map Search</a>'); //class="zNoContentTransition" 
							}else{
								writeoutput('<a id="zHideMapSearchButton" href="#request.zos.listing.functions.getSearchFormLink()#?searchId=#form.searchId#&amp;zIndex=#form.zIndex#&amp;zListingHideMap=0">Show Map</a>');// class="zNoContentTransition"
							}
						}
						writeoutput('</div>');
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
			ts.distance = 30; 
			if(form.debugSearchForm or form.debugSearchResults){
				ts.debug=true;
			} 
			ts.enableThreading=false;
			returnStruct = variables.propertyDataCom.getProperties(ts);
			structdelete(variables,'ts');
			mapQuery = returnStruct; 
			if(returnStruct.count NEQ 0){
				searchStruct = StructNew();
				searchStruct.showString = "";
				searchStruct.indexName = 'zIndex';
				searchStruct.url = request.zos.listing.functions.getSearchFormLink();
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
				if(isDefined('variables.propertyDataCom.searchCriteria.search_result_layout')){
					ts.search_result_layout=variables.propertyDataCom.searchCriteria.search_result_layout;
					if(ts.search_result_layout EQ 2){
						ts.datastruct.perpage=int(ts.datastruct.perpage/3)*3;
					}
				}
				if(isDefined('variables.propertyDataCom.searchCriteria.search_group_by') and variables.propertyDataCom.searchCriteria.search_group_by EQ "1"){
					ts.groupBedrooms=true;
					ts.search_result_layout=1;
				}
				if(structkeyexists(ts,'search_result_layout') and ts.search_result_layout EQ 2){
					ts.getDetails=false;
				}
				ts.searchId=form.searchId;
				request.zsession.tempVars.zListingSearchId=form.searchId;
				variables.propertyDisplayCom.init(ts);
				if(returnStruct.count NEQ 0 and (isnumeric(application.zcore.functions.zso(form, 'searchId')) or structkeyexists(form,'searchaction'))){
					res=variables.propertyDisplayCom.display();
				}
			}
			if(structkeyexists(application.sitestruct[request.zos.globals.id], 'zListingMapCheck') and isDefined('request.zsession.zListingHideMap') and request.zsession.zListingHideMap EQ false and tempHideMap EQ false){
				ms={
					mapQuery=mapQuery,
					propertyDataCom=variables.propertyDataCom
				}
				mapCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.map");
				mapCom.index(ms);
				writeoutput('<br />');
			}
			if(returnStruct.count NEQ 0){
				if(application.zcore.functions.zso(form, 'search_result_layout') NEQ ""){
					if(form.search_result_layout EQ 0){
						local.displayType="detail";
					}else if(form.search_result_layout EQ 1){
						local.displayType="list";
					}else if(form.search_result_layout EQ 2){
						local.displayType="grid";
					}else{
						local.displayType="detail";
					}
				}else{
					local.displayType="detail";
				}
				if(isnumeric(application.zcore.functions.zso(form, 'searchId')) or structkeyexists(form,'searchaction')){
					writeoutput('<input type="hidden" name="zlsHoverBoxDisplayType" id="zlsHoverBoxDisplayType" value="#local.displayType#" />
					<div id="zls-matchinglistingsdiv" style="width:100%;">
						<div class="zls-hover-box1"> <a href="##" id="zls-hover-box-map-button" style="float:right; display:none;">MAP</a> <a href="##" id="zls-hover-box-detail-button" style="float:right;">DETAIL</a> <a href="##" id="zls-hover-box-list-button" style="float:right;">LIST</a> <a href="##" id="zls-hover-box-grid-button" style="float:right;">GRID</a></div>
						<h2>Matching Listings</h2>
					</div>');
					writeoutput(res);
				}
			}
			if(structkeyexists(form, 'searchId') EQ false){
				writeoutput('<div style="width:100%; height:500px;">&nbsp;</div>');
			}
			writeoutput('</div>');
	</cfscript>
</cffunction>

<cffunction name="displayResults" localmode="modern" access="public">
	<cfscript>
	var i=0;
	structdelete(variables,'request.zos.listing');
	structdelete(form,'fieldnames');
	for(i in form){
		if(structkeyexists(form,i) EQ false){
			//structdelete(form, i);
		}else if(isSimpleValue(form[i])){
			form[i]=urldecode(form[i]);
		}
	} 
	variables.propertyDataCom.setSearchCriteria(form);
	variables.getSearchHelpBar();
	if(isDefined('request.contentEditor')){
		writeoutput('<div id="mlsResults" style="padding-left:10px;vertical-align:top;">');
	}
	if(application.zcore.functions.zso(form, 'outputSearchForm',false,false) EQ false){
		if(isDefined('request.contentEditor') EQ false and isDefined('request.hideMLSResults') EQ false){
			if(request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink() OR isDefined('request.contentEditor')){
				if(isDefined('request.zMLSHideCount') EQ false){
					if(variables.sidebarOutput){
						if(structkeyexists(request.zos.tempObj,'getMLSCountOutput') EQ false){
							request.zos.tempObj.getMLSCountOutput=true;
							application.zcore.template.appendTag("sidebar",'<script>/* <![CDATA[ */    
							zArrDeferredFunctions.push(function(){getMLSCount(''zMLSSearchForm'')});  /* ]]> */</script>');	
						}
					}else{
						if(structkeyexists(request.zos.tempObj,'getMLSCountOutput') EQ false){
							request.zos.tempObj.getMLSCountOutput=true;
							writeoutput('<script>/* <![CDATA[ */
							zArrDeferredFunctions.push(function(){getMLSCount(''zMLSSearchForm'')});   /* ]]> */</script>');
						}
					}
				}
			}
		}else{
			if(isDefined('request.contentEditor') EQ false){
				ts=structnew();
				ts.content_unique_name='/z/listing/search-form/index';
				ts.disableContentMeta=false;
				ts.disableLinks=true;
				r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
				if(r1 EQ false){
					inquiryTextMissing=true;
				}
				writeoutput('<p style="font-size:18px;">Please submit your search using the <strong>search form on the sidebar</strong>.</p>
				<p>Expand each section by clicking on the title. i.e. &quot;Sale Type&quot; or &quot;Frontage&quot; and select as many options as you like.</p>
				<p>Under price and some of the other options are 2 slider boxes. Click and drag these boxes left and right in order to quickly adjust the selection.</p>');
				if(isDefined('request.zUsingRightSidebar')){
					writeoutput('<p><img src="/z/a/images/redarrowright.jpg" /></p>');
				}else{
					writeoutput('<p><img src="/z/a/images/redarrow.jpg" /></p>');
				}
				writeoutput('<script>/* <![CDATA[ */zListingDisplayHelpBox();/* ]]> */</script>
				<div style="width:100%; height:500px;float:left; clear:both;"></div>');
			}
			if(isDefined('request.contentEditor')){
				if(application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false)){
					ms={
						propertyDataCom=variables.propertyDataCom
					}
					mapCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.map");
					mapCom.index(ms);
					writeoutput('<br />');
				}
				writeoutput('</div>');
				if(request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink() OR isDefined('request.contentEditor')){
					if(isDefined('request.zMLSHideCount') EQ false and isDefined('request.contentEditor')){
						if(structkeyexists(request.zos.tempObj,'getMLSCountOutput') EQ false){
							request.zos.tempObj.getMLSCountOutput=true;
							writeoutput('<script>/* <![CDATA[ */
								zArrDeferredFunctions.push(function(){getMLSCount(''MLSSearchForm'');  });
							/* ]]> */</script>');
						}
					}
				}
			}
		}
	}
	</cfscript>
</cffunction>

<cffunction name="getSearchIdFromUrl" localmode="modern" access="private">
	<cfscript>
	var qc23872=0;
	var temp238722=0;
	var temp23872=0;
	var db=request.zos.queryObject;
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
		mls_saved_search_deleted = #db.param(0)# ";
		qc23872=db.execute("qc23872");
		if(qc23872.recordcount NEQ 0){
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
	
	 if(request.zos.originalURL NEQ request.zos.listing.functions.getSearchFormLink()){
		 form.zsearch_bid='';
		 form.zsearch_cid='';
		 form.searchid='';
		 structdelete(request,'zForceSearchId');
	 }
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;
	var startFormTagHTML=0;
	var searchFormHTML=0;
	var arrKey=0;
	var sfSortStruct2=0;
	var forceSearchFormReset=0;
	var curCacheTimeSpan=0;
	var sfSortStruct=0;
	var searchCom=0;
	var ts=0;
	var endFormTagHTML=0;
	var i=0;
	var tempSearchFormAction=0;
	variables.init();
	
	variables.getSearchIdFromUrl();
	 if(request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink()){
		request.zForceListingSidebar=true; 
	 }
	if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_disable_search',true) EQ 1 and application.zcore.functions.zso(request, 'contentEditor',false,false) EQ false){
		application.zcore.functions.z301redirect('/');	
	}
	if(application.zcore.functions.zso(request, 'contentEditor',false,false) and request.cgi_script_name NEQ "/z/listing/admin/search-filter/index"){
		form.search_liststatus='1,4,7,16';	
		variables.search_liststatus='1,4,7,16';
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
	
	if (structkeyexists(form, 'mls_saved_search_id')) {
		q2=request.zos.listing.functions.zGetSavedSearchQuery(form.mls_saved_search_id);
		myOwnStruct=structnew(); 
		application.zcore.functions.zquerytostruct(q2,myOwnStruct);
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
	if(structkeyexists(form,'search_city_id') or structkeyexists(form,'search_map_coordinates_list')){
		application.zcore.status.setStatus(form.searchId,false,form);
		ts=application.zcore.status.getStruct(form.searchId);
	}else{
		ts=application.zcore.status.getStruct(form.searchId);
		if(structkeyexists(ts,'varstruct')){
			structappend(form,ts.varStruct,false);
			structappend(variables,ts.varStruct,false);
		}
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
	savecontent variable="searchFormHTML"{
		
		local.searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.search2");
		local.rs=local.searchCom.getSearchCriteriaStruct();
		local.formFieldStruct=local.searchCom.renderSearchFields(local.rs, local.rs.formFieldTypeStruct);
		sfSortStruct=local.formFieldStruct;
		//local.template=local.searchCom.getSearchFormTemplate();
		
		//local.output=local.searchCom.processSearchFormTemplate(local.formFieldStruct, local.template);
		//writeoutput(local.output);
		
		savecontent variable="startFormTagHTML"{
			if(isDefined('request.contentEditor') EQ false){
				writeoutput(local.formFieldStruct.startFormTag);
			}
			if(structkeyexists(request,'theSearchFormTemplate') EQ false){
				writeoutput('<div id="searchFormTopDiv" style="float:left;  width:100%; clear:both;"></div><br style="clear:both;" />');
			}
			if(structkeyexists(form, 'searchId') and form.searchFormEnabledDropDownMenus EQ false){
				writeoutput('<div class="zls-saveSearchFormButton"><br />
				<a href="##" onclick="zModalSaveSearch(#form.searchId#);return false;"><img src="/z/a/listing/images/save-this-search.jpg" alt="Save This Search" /></a><br />
				<br /></div>');
			}
			if(application.zcore.functions.zso(request,'zDisableSearchFormSubmit',false,false)){
				local.disableTemp=true;
			}else{
				local.disableTemp=false;
			}
			writeoutput('<script>/* <![CDATA[ */var zDisableSearchFormSubmit=#local.disableTemp#;/* ]]> */</script>');
			
			if(structkeyexists(form, 'searchFormHideCriteria') EQ false){
				form.searchFormHideCriteria=structnew();	
			}
			if(form.debugSearchForm){
				writeoutput('<script>/* <![CDATA[ */zDebugMLSAjax=true;/* ]]> */</script>');
			}
			if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
				ts=structnew();
				search_status='7';
				ts.name="search_status";
				application.zcore.functions.zinput_hidden(ts);
			}
			if(form.debugSearchForm){
				writeoutput('<input type="text" name="zreset" value="site" /> (site reset)<br />');
			}
			if(structkeyexists(request,'theSearchFormTemplate') EQ false){
				application.zcore.template.appendTag("scripts", '<div class="zResultCountAbsolute" id="resultCountAbsolute"></div>');
			}
		}
		sfSortStruct["startFormTag"]=startFormTagHTML;
		writeoutput(startFormTagHTML);
		
		
		
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
		
		
		writeoutput('</div>');
		savecontent variable="endFormTagHTML"{
			if(request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink() OR isDefined('request.contentEditor')){
				if(structkeyexists(request.zos.tempObj,'getMLSCountOutput') EQ false){
					request.zos.tempObj.getMLSCountOutput=true;
					writeoutput('<script>/* <![CDATA[ */zArrDeferredFunctions.push(function(){getMLSCount(''zMLSSearchForm'');});/* ]]> */</script>');
				}
			}
			if(isDefined('request.contentEditor') EQ false){
				writeoutput(local.formFieldStruct.endFormTag);
			}
		}
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
	}
	variables.sidebarOutput=false;
	if(structkeyexists(request,'theSearchFormTemplate')){
		writeoutput(request.theSearchFormTemplate);	
	}else if(isDefined('request.contentEditor')){
		writeoutput(searchFormHTML);	
	}else if(structkeyexists(form, 'outputSearchForm') and form.outputSearchForm){
		writeoutput(searchFormHTML);
	}else{
		variables.sidebarOutput=true;
		application.zcore.template.setTag("sidebar",searchFormHTML);
	}
	
	
	variables.displayResults();
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
