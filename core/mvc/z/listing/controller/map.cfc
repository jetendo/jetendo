<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="public" returntype="any">
	<cfargument name="mapStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var mapCoor=0;
	var arrMap=0;
	var arrMap2=0;
	var mapFail=0;
	var theMapProp=0;
	var returnStruct3=0;
	var noCoordinates=0;
	var centerCoorAlreadySet=0; 
	var theMapText=0; 
	var rts=0;
	var backupCoordinatesList=0;
	var primaryCityId=0;
	var zBingAddress=0;
	var arrNew=0;
	var tempMetaBing=0;
	var i=0;
	var mapStageStruct=application.zcore.functions.zso(arguments.mapStruct, 'mapStageStruct', false, structnew());
	var local=structnew();
	structappend(local, arguments.mapStruct, true); 
	if(structkeyexists(mapStageStruct, 'height') EQ false){
		if(request.cgi_script_name NEQ '/z/listing/property/detail/index' and request.cgi_script_name NEQ '/z/listing/property/detail-new/index'){
			mapStageStruct=StructNew();
			mapStageStruct.width=request.zos.globals.maximagewidth;
			mapStageStruct.height=350;
			mapStageStruct.fullscreen.width=498;
			mapStageStruct.fullscreen.height=302;
		}
	}
	noCoordinates=true;
	
	rts=structnew();
	rts.minLat=0;
	rts.maxLat=0;
	rts.minLong=0;
	rts.maxLong=0;

	optionStruct=application.zcore.app.getAppData("listing").sharedStruct.optionStruct;
	backupSearchWithinMap=application.zcore.functions.zso(form, 'search_within_map',true);
	if(application.zcore.functions.zso(form, 'search_within_map') NEQ 1 and request.cgi_script_name NEQ "/z/listing/property/detail/index" and request.cgi_script_name NEQ '/z/listing/property/detail-new/index'){

/*

// this wasn't working yet.
		// get coordinates for primary city
		maxDistance=application.zcore.functions.zso(optionStruct, 'mls_option_max_map_distance_from_primary', true, 0);
		primaryCityId=optionStruct.mls_option_site_map_primary_city;
		db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# 
		WHERE city_id = #db.param(primaryCityId)# and 
		city_deleted=#db.param(0)# ";
		qCity=db.execute("qCity");
		backupCoordinatesList=application.zcore.functions.zso(form, 'search_map_coordinates_list'); 
		if(qCity.recordcount and (backupCoordinatesList EQ "" or backupCoordinatesList EQ 0)){
			latitudeMin= (maxDistance / 69)-qCity.city_latitude;
			latitudeMax= (maxDistance / 69)+qCity.city_latitude;
			longitudeMin= (maxDistance / 60)-qCity.city_longitude;
			longitudeMax= (maxDistance / 60)+qCity.city_longitude; 

			form.search_map_coordinates_list="#longitudeMin#,#longitudeMax#,#latitudeMin#,#latitudeMax#";
			backupCoordinatesList=form.search_map_coordinates_list;
			//echo('maxDistance:'&maxDistance&'<br>');
			//writedump(rts);
			//writedump(mapstageStruct);		
			rts.minLat=latitudeMin;
			rts.maxLat=latitudeMax;
			rts.minLong=longitudeMin;
			rts.maxLong=longitudeMax;
			noCoordinates=false;
			mapStageStruct.avgLat=(rts.minLat+rts.maxLat)/2;
			mapStageStruct.avgLong=(rts.minLong+rts.maxLong)/2;
			writedump(rts);
		} */
		 
		//echo("|"&backupCoordinatesList&"|<br>|"&form.search_map_coordinates_list);
		ts = StructNew();
		ts.offset =0;
		ts.perpage = 1;
		ts.distance = 30; // in miles
		ts.zReturnSimpleQuery=true;
		ts.requireValidCoordinates=true;
		structdelete(form,"search_within_map");
		structdelete(form,"search_map_coordinates_list");
		propertyDataCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
		propertyDataCom.setSearchCriteria(form);
		ts.onlyCount=true;
		//ts.debug=true;
		if(application.zcore.functions.zso(optionStruct, 'mls_option_map_state') NEQ ""){
			ts.zwhere=" and listing_state = '"&optionStruct.mls_option_map_state&"' ";	
		}
		ts.zselect=" min(listing_latitude) minLat, max(listing_latitude) maxLat, min(listing_longitude) minLong, max(listing_longitude) maxLong";
		returnStruct3 = propertyDataCom.getProperties(ts);
		form.search_map_coordinates_list=backupCoordinatesList;
		if(returnStruct3.recordcount NEQ 0 and returnStruct3.minLat NEQ ""){			
			rts.minLat=returnStruct3.minLat;
			rts.maxLat=returnStruct3.maxLat;
			rts.minLong=returnStruct3.minLong;
			rts.maxLong=returnStruct3.maxLong;
			noCoordinates=false;
			mapStageStruct.avgLat=(rts.minLat+rts.maxLat)/2;
			mapStageStruct.avgLong=(rts.minLong+rts.maxLong)/2;
		}  
	}else if(application.zcore.functions.zso(form,'search_map_coordinates_list') NEQ ""){
		arrMap=listtoarray(form.search_map_coordinates_list);
		arrMap2=["minLongitude","maxLongitude","minLatitude","maxLatitude"];
		mapCoor=structnew();
		mapFail=false;
		for(i=1;i LTE arraylen(arrMap);i++){
			if(isnumeric(arrMap[i])){
				mapCoor[arrMap2[i]]=arrMap[i];
			}else{
				break;	
			}
		}
		if(structcount(mapCoor) EQ 4){
			rts.minLat=mapCoor.minLatitude;
			rts.maxLat=mapCoor.maxLatitude;
			rts.minLong=mapCoor.minLongitude;
			rts.maxLong=mapCoor.maxLongitude;
			noCoordinates=false;
			mapstageStruct.avgLat=(mapCoor.minLatitude+mapCoor.maxLatitude)/2;
			mapstageStruct.avgLong=(mapCoor.minLongitude+mapCoor.maxLongitude)/2;
		}
	}
	if(noCoordinates){
		if(application.zcore.functions.zso(form, 'primaryCityId',true) EQ 0){
			primaryCityId=application.zcore.app.getAppData("listing").sharedStruct.mls_primary_city_id;
		}
		mapstageStruct.forceZoom=9;
		mapstageStruct.avgLat=application.zcore.app.getAppData("listing").sharedStruct.avgLat;
		mapstageStruct.avgLong=application.zcore.app.getAppData("listing").sharedStruct.avgLong;
	}
 
	application.zcore.template.appendTag('scripts', '<div id="zMapOverlayDivV3" style="position:absolute; left:0px; top:0px; display:none; z-index:1000;"></div>');
	disableGoogleMaps=false;
	</cfscript> 
	<cfsavecontent variable="theMapText">
		<div id="zMapAllDiv" style="float:left;width:100%">
		<cfif structkeyexists(request.zos, 'zForceEnableMap') or application.zcore.app.getAppCFC("content").isContentPage() or request.cgi_script_name EQ '/z/listing/map-fullscreen/index' or request.cgi_script_name EQ '/z/listing/map-embedded/index' or request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' or request.cgi_script_name EQ '/z/listing/property/saved-search/index' or request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink() or isDefined('request.zForceSearchFormInclude') or request.zos.inmemberarea>
			<cfif application.zcore.app.getAppCFC("content").isContentPage() EQ false and request.cgi_script_name NEQ '/z/listing/map-embedded/index'>
				<div id="zlsHideListingMapDiv" style="font-weight:bold; padding-bottom:5px; ">Hide listings outside the map view? <input type="radio" name="setWithinMapRadio" id="setWithinMapRadio1" value="1" style="border:none; background:none;" onclick="zSetWithinMap2(1);" <cfif backupSearchWithinMap EQ 1>checked="checked"</cfif> /> Yes <input type="radio" name="setWithinMapRadio" id="setWithinMapRadio2" style="border:none; background:none;" onclick="zSetWithinMap2(0);" value="0" <cfif backupSearchWithinMap EQ 0>checked="checked"</cfif> /> No</div>
			</cfif>
			<div id="myGoogleMapV3" style="width: 100%; max-width:100%; height: #mapStageStruct.height#<cfif right(mapStageStruct.height,1) NEQ "%">px</cfif>; margin-bottom:5px;"></div>
			<div id="zlsMapLegendDiv" style="width:100%; float:left;">
			<table style="border-spacing:5px; width:100%;">
			<tr><td style="vertical-align:top; width:32px; ">
			<img src="/z/a/listing/images/icon-multi.jpg" width="32" height="25" alt="Image" /></td><td style="vertical-align:top; width:100px; " > LISTING GROUP</td>
			<td style="width:21px; vertical-align:top;"><img src="/z/a/listing/images/icon-home.jpg" alt="Image" width="21" height="17" /></td><td style="width:50px; vertical-align:top;padding-left:0px;">LISTING</td>
			<cfif application.zcore.app.getAppCFC("content").isContentPage() and request.cgi_script_name NEQ '/z/listing/map-embedded/index'></tr><tr><td colspan="4"><cfelse><td></cfif><div class="zls2-colorlegend" style="float:right;"></div></td></tr>
			</table>
			</div>
		<cfelseif request.cgi_script_name EQ '/z/listing/property/detail/index' or request.cgi_script_name EQ '/z/listing/property/detail-new/index'>

			<cfif listing_latitude NEQ "" and listing_longitude NEQ "">
				<cfscript>
				disableGoogleMaps=true;
				ts={
				    marginRadiusInMiles:3, // can be decimal
				    // note this doesn't support multiple markers or custom marker html when clicked yet
				    markers:[{
				        latitude:#listing_latitude#,
				        longitude:#listing_longitude#
				    }],
				    width:"100%",
				    height:mapStageStruct.height,
				    displayMapLink:false
				};
				application.zcore.functions.zDisplayMapWithMarker(ts);
				</cfscript>
			</cfif>
		
			<!--- <cfsavecontent variable="tempMetaBing">
			<script type="text/javascript">
			/* <![CDATA[ */ zOneLatitude=#listing_latitude#;
			zOneLongitude=#listing_longitude#;
			<cfset zBingAddress=listing_data_address&", "&cityName&", FL "&listing_data_zip>
			zBingAddress="#zBingAddress#"; /* ]]> */
			</script>
			</cfsavecontent>
			
			<cfscript>
				application.zcore.template.appendTag("scripts",tempMetaBing);
			</cfscript>
			<div id="myGoogleMapV3" style="width:100%;max-width:100%;  height: #mapStageStruct.height#px; "></div>
			<form name="mapSearchForm" id="mapSearchForm" method="post" action="#htmleditformat(application.zcore.functions.zURLAppend(request.zos.listing.functions.getSearchFormLink(),'searchId='))#" style="margin:0px; padding:0px; ">
			<input type="hidden" name="search_map_coordinates_list" value="#application.zcore.functions.zso(form, 'search_map_coordinates_list')#" />
			<input type="hidden" name="search_within_map" value="1" />
			</form>
			
			<cfif application.zcore.functions.zso(optionStruct,'mls_option_disable_search',true) EQ 0>
			<div id="zmlssearchwithindiv"><h3><a href="##" onclick="searchWithinMap(true);return false;">Search for nearby listings</a></h3></div>
			</cfif>
			<div id="zGStreetView" style="display:none;">
			<h3>360&deg; Street View</h3>
			Note: Drag your mouse to view 360&deg;.  The default view may not be facing the property.<br />
			<div id="pano" style="width:480px; height: 270px; "></div>
			</div> --->
		
		</cfif>
		</div>
	</cfsavecontent>
	<cfif isDefined('hideSavedSearchSubmit')>
	<div style="float:left; width:780px; "></div>
	</cfif>
	<div id="map489273" style="float:left; width:100%; clear:both;">#theMapText#</div>
	<cfif structkeyexists(request,'zOverrideMapDivId') EQ false><cfset request.zOverrideMapDivId="map489273"></cfif>

		
		<cfsavecontent variable="theMapProp">{
			"forceZoom":<cfif isDefined('mapstageStruct.forceZoom')>#mapstageStruct.forceZoom#<cfelse>0</cfif>,
			"stageWidth":"#mapStageStruct.width#",
			"stageHeight":"#mapStageStruct.height#",
			"avgLat":<cfif isDefined('mapstageStruct.avgLat') EQ false or isnumeric(mapstageStruct.avgLat) EQ false>0<cfelse>#mapstageStruct.avgLat#</cfif>,
			"avgLong":<cfif isDefined('mapstageStruct.avgLong') EQ false or isnumeric(mapstageStruct.avgLong) EQ false>0<cfelse>#mapStageStruct.avgLong#</cfif>,
			<cfif isDefined('hideMapControls')>"zHideMapControl":true,</cfif>
		<cfif structkeyexists(mapStageStruct, 'arrMapTotalLat')>
        		<cfscript>
			arrNew=arraynew(1);
			for(i=1;i LTE arraylen(mapStageStruct.arrMapText);i++){
				arrayappend(arrNew, jsstringformat(mapStageStruct.arrMapText[i]));
			}
			</cfscript>
		    "mapCount":#arrayLen(mapStageStruct.arrMapTotalLat)#,
		    <cfif arrayLen(mapStageStruct.arrMapTotalLat) EQ 1 >"forceZoom":14,</cfif>
		    "zArrMapTotalLat":[#arraytolist(mapStageStruct.arrMapTotalLat,", ")#],
		    "zArrMapTotalLong":[#arraytolist(mapStageStruct.arrMapTotalLong, ", ")#],
		    "zArrMapText":["#arraytolist(arrNew, '","')#"]
        <cfelse>
		<cfif rts.minLat NEQ 0>
			<cfset centerCoorAlreadySet=false>
			<cfif structkeyexists(form, 'searchid') EQ false>
				<cfset tempSQL=application.zcore.listingCom.getMLSIDWhereSQL('listing')>
				<cfsavecontent variable="db.sql">
				SELECT (listing_latitude) `lat`, (listing_longitude) `long` 
				from #db.table("listing", request.zos.zcoreDatasource)# 
				where listing_latitude<>#db.param('')# and 
				listing_deleted = #db.param(0)# and 
				listing_city = #db.param(optionStruct.mls_option_site_map_primary_city)# and 
				#db.trustedSQL(tempSQL)#  
				LIMIT #db.param(0)#,#db.param(1)#
				</cfsavecontent>
				<cfscript>
				qOneCoor=db.execute("qOneCoor");
				</cfscript>
				<cfif qOneCoor.recordcount NEQ 0>
					<cfset centerCoorAlreadySet=true>
					"mapCount":1,
					"forceZoom":14,
					"zArrMapTotalLat":[#qOneCoor.lat#],
					"zArrMapTotalLong":[#qOneCoor.long#],
					"zArrMapText":[false]
				</cfif>
			</cfif>
			<cfif centerCoorAlreadySet EQ false>
				"mapCount":2,
				"zArrMapTotalLat":[#rts.minLat#, #rts.maxLat#],
				"zArrMapTotalLong":[#rts.minLong#, #rts.maxLong#],
				"zArrMapText":[false,false]
			</cfif>
			</cfif>
		</cfif>
	}</cfsavecontent>
	<input type="hidden" name="zMapLoadInputVars1" class="zMapLoadInputVarsClass" value="#htmleditformat(theMapProp)#" />
	
	<cfscript>
	if(not disableGoogleMaps){
		application.zcore.functions.zRequireGoogleMaps();
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>