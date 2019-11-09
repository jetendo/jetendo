<cfcomponent>
<cfoutput>
<!--- 
This doesn't support ipv6 yet.
Google shows 16% of users are using ipv6 as of february 2017.
https://www.google.com/intl/en/ipv6/statistics.html

A study found maxmind ipv6 database to be 2-3 times less accurate
http://referaat.cs.utwente.nl/conference/24/paper/7519/comparing-the-accuracy-of-ipv4-and-ipv6-geolocation-databases.pdf

The usa owns around 36% of all ip addresses.

geoip might be useful for making users less anonymous for simple leads and abuse / spam detection.  For example, the user's network location information could be attached to leads, and logged in access logs to help us identify abuse patterns or automatically distrust certain behavior more because of what it came from.

The db also tells me if the ip is known to be anonymous proxy or satellite on some of them.  It would be interesting to determine if abuse through proxies is more common or not.  I could run a report to see the network locations of all the spam inquiries.

all inquiries 

SELECT geoip_location_city_name, COUNT(DISTINCT inquiries.inquiries_id) `count`  FROM jetendo.inquiries, jetendo.track_user, task.geoip, task.geoip_block, task.geoip_location
WHERE inquiries.inquiries_id=track_user.inquiries_id AND 
inquiries.site_id = track_user.site_id AND 
 geoip_ip_number =INET_ATON(track_user_ip) AND 
 inquiries_spam=1 AND 
 geoip.geoip_block_id=geoip_block.geoip_block_id AND 
 geoip_location.geoip_location_id = geoip_block.geoip_location_id 
GROUP BY geoip_location_city_name
  ;

  #spam by country
SELECT geoip_location_country_name, COUNT(DISTINCT inquiries.inquiries_id) `count`  FROM jetendo.inquiries, jetendo.track_user, task.geoip, task.geoip_block, task.geoip_location
WHERE inquiries.inquiries_id=track_user.inquiries_id AND 
inquiries.site_id = track_user.site_id AND 
 geoip_ip_number =INET_ATON(track_user_ip) AND 
 inquiries_spam=1 AND 
 geoip.geoip_block_id=geoip_block.geoip_block_id AND 
 geoip_location.geoip_location_id = geoip_block.geoip_location_id 
GROUP BY geoip_location_country_name
  ;


  ip count by country:

SELECT geoip_location_country_name, COUNT(geoip_block.geoip_block_id) `count`  FROM  task.geoip, task.geoip_block, task.geoip_location  
WHERE
 geoip.geoip_block_id=geoip_block.geoip_block_id AND 
 geoip_location.geoip_location_id = geoip_block.geoip_location_id 
GROUP BY geoip_location_country_name 
LIMIT 0,1000
  ;
 --->
<!--- <cffunction name="importIpStatus" localmode="modern" access="remote">
	<cfscript>
	echo('Insert Count:'&application.zcore.functions.zso(application, 'geoipInsertCount')&" | Offset:"&application.zcore.functions.zso(application, 'geoipInsertOffset'));
	</cfscript>
</cffunction>

<cffunction name="importIp" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	setting requesttimeout="100000";
	throw("this uses too much space - need to do partial import or not at all");

	application.geoipInsertOffset=10000;
	application.geoipInsertCount=0; 
	while(true){
		db.sql="SELECT  *
		FROM #db.table("geoip_block", request.zos.zcoreDatasource)#
		LIMIT #db.param(application.geoipInsertOffset)#, #db.param(10000)#";
		qIp=db.execute("qIp");
		if(qIp.recordcount EQ 0){
			break;
		}
		arrFile=[];
		for(row in qIp){
			ip=row.geoip_block_network;
			for(i=ip;i<=row.geoip_block_broadcast;i++){ 
				application.geoipInsertCount++; 
				arrayAppend(arrFile, "('#i#','#row.geoip_block_id#')"); 
				if(arrayLen(arrFile) GT 3000){
					query name="qInsert" datasource=request.zos.zcoreDatasource{
					echo("INSERT IGNORE INTO geoip (geoip_ip_number, geoip_block_id) VALUES "&arrayToList(arrFile, ", "));
					} 
					arrFile=[]; 
				}
			}
		}
		query name="qInsert" datasource=request.zos.zcoreDatasource{
		echo("INSERT IGNORE INTO geoip (geoip_ip_number, geoip_block_id) VALUES "&arrayToList(arrFile, ", "));
		} 
		application.geoipInsertOffset+=10000;
	} 
	echo('#application.geoipInsertCount# inserted | Offset: #application.geoipInsertOffset#');
	</cfscript>	
</cffunction>   --->

<cffunction name="zGetFastIpLocation" localmode="modern" access="remote">
	<cfargument name="ip" type="string" required="yes">
	<cfargument name="columnList" type="string" required="no" default="" hint="* is a valid value if you want everything">
	<cfscript>
	if(arguments.columnList EQ ""){
		arguments.columnList="geoip_location.geoip_location_country_name,
		geoip_location.geoip_location_country_iso_code,
		geoip_location.geoip_location_city_name,
		geoip_block.geoip_block_latitude,
		geoip_block.geoip_block_longitude  ";
	} 
	db=request.zos.queryObject;
	db.sql="SELECT   SQL_NO_CACHE
	#arguments.columnList# 
	FROM #db.table("geoip_block", request.zos.zcoreDatasource)# FORCE INDEX(newindex2), 
	#db.table("geoip_location", request.zos.zcoreDatasource)#  
	where geoip_block.geoip_location_id = geoip_location.geoip_location_id and 
	geoip_block_prefix=(substring_index(substring_index(#db.param(arguments.ip)#, #db.param('.')#, #db.param(1)#), #db.param('.')#, #db.param(-1)#)*#db.param(256)#)+substring_index(substring_index(#db.param(arguments.ip)#, #db.param('.')#, #db.param(2)#), #db.param('.')#, #db.param(-1)#) 
	AND inet_aton(#db.param(arguments.ip)#) >= geoip_block_network
	AND inet_aton(#db.param(arguments.ip)#) <= geoip_block_broadcast 
	LIMIT #db.param(0)#, #db.param(1)#";
	qIp=db.execute("qIp");
	ts={};
	if(qIp.recordcount EQ 0){
		ts.success=false; 
	}else{
		ts.success=true;
		ts.type="ip";
		for(row in qIp){
			ts.countryCode=application.zcore.functions.zso(row, 'geoip_location_country_iso_code');
			ts.cityName=application.zcore.functions.zso(row, 'geoip_location_city_name');
			ts.countryName=application.zcore.functions.zso(row, 'geoip_location_country_name');
			ts.locale=application.zcore.functions.zso(row, 'geoip_location_locale_code');
			ts.continentCode=application.zcore.functions.zso(row, 'geoip_location_continent_code');
			ts.continentName=application.zcore.functions.zso(row, 'geoip_location_continent_name');
			ts.subdivision1Code=application.zcore.functions.zso(row, 'geoip_location_subdivision_1_iso_code'); // I.e. state/province
			ts.subdivision1Name=application.zcore.functions.zso(row, 'geoip_location_subdivision_1_name');
			ts.subdivision2Code=application.zcore.functions.zso(row, 'geoip_location_subdivision_2_iso_code');
			ts.subdivision2Name=application.zcore.functions.zso(row, 'geoip_location_subdivision_2_name');
			ts.metroCode=application.zcore.functions.zso(row, 'geoip_location_metro_code');
			ts.postalCode=application.zcore.functions.zso(row, 'geoip_location_postalCode');
			if(ts.postalCode EQ ""){
				ts.postalCode=application.zcore.functions.zso(row, 'geoip_block_postal_code');
			}
			ts.latitude=application.zcore.functions.zso(row, 'geoip_block_latitude');
			ts.longitude=application.zcore.functions.zso(row, 'geoip_block_longitude');
		}
	}
	return ts;
	</cfscript>
</cffunction>

<cffunction name="zGetIpLocation" localmode="modern" access="remote">
	<cfargument name="ip" type="string" required="yes">
	<cfargument name="columnList" type="string" required="no" default="" hint="* is a valid value if you want everything">
	<cfscript>
	if(arguments.columnList EQ ""){
		arguments.columnList="geoip_location.geoip_location_country_name,
		geoip_location.geoip_location_country_iso_code,
		geoip_location.geoip_location_city_name,
		geoip_block.geoip_block_latitude,
		geoip_block.geoip_block_longitude  ";
	}
	db=request.zos.queryObject; 

	db.sql="SELECT   SQL_NO_CACHE
	#arguments.columnList# 
	FROM #db.table("geoip_block", request.zos.zcoreDatasource)# FORCE INDEX(newindex1), 
	#db.table("geoip_location", request.zos.zcoreDatasource)#  
	where geoip_block.geoip_location_id = geoip_location.geoip_location_id 
	AND inet_aton(#db.param(arguments.ip)#) >= geoip_block_network
	AND inet_aton(#db.param(arguments.ip)#) <= geoip_block_broadcast 
	LIMIT #db.param(0)#, #db.param(1)#";
	qIp=db.execute("qIp");
	ts={};
	if(qIp.recordcount EQ 0){
		ts.success=false; 
	}else{
		ts.success=true;
		ts.type="ip";
		for(row in qIp){
			ts.countryCode=application.zcore.functions.zso(row, 'geoip_location_country_iso_code');
			ts.cityName=application.zcore.functions.zso(row, 'geoip_location_city_name');
			ts.countryName=application.zcore.functions.zso(row, 'geoip_location_country_name');
			ts.locale=application.zcore.functions.zso(row, 'geoip_location_locale_code');
			ts.continentCode=application.zcore.functions.zso(row, 'geoip_location_continent_code');
			ts.continentName=application.zcore.functions.zso(row, 'geoip_location_continent_name');
			ts.subdivision1Code=application.zcore.functions.zso(row, 'geoip_location_subdivision_1_iso_code'); // I.e. state/province
			ts.subdivision1Name=application.zcore.functions.zso(row, 'geoip_location_subdivision_1_name');
			ts.subdivision2Code=application.zcore.functions.zso(row, 'geoip_location_subdivision_2_iso_code');
			ts.subdivision2Name=application.zcore.functions.zso(row, 'geoip_location_subdivision_2_name');
			ts.metroCode=application.zcore.functions.zso(row, 'geoip_location_metro_code');
			ts.postalCode=application.zcore.functions.zso(row, 'geoip_location_postalCode');
			if(ts.postalCode EQ ""){
				ts.postalCode=application.zcore.functions.zso(row, 'geoip_block_postal_code');
			}
			ts.latitude=application.zcore.functions.zso(row, 'geoip_block_latitude');
			ts.longitude=application.zcore.functions.zso(row, 'geoip_block_longitude');
		}
	}
	return ts;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	starttime=gettickcount();
	form.ip=application.zcore.functions.zso(form, 'ip', false, request.zos.cgi.remote_addr);
	ts2=zGetIpLocation(form.ip, "");
	slowTime=(gettickcount()-starttime);
	starttime=gettickcount();
	ts=zGetFastIpLocation(form.ip, "");
	fastTime=(gettickcount()-starttime);

	echo('<h2>GeoIP Live Demo</h2>');
	echo('<div class="z-1of2">
	<form action="" method="get"><p>IP Address <input type="text" name="ip" value="#htmleditformat(form.ip)#"> <input type="submit" name="submit1" value="Submit"></p></form>');
	echo('<p>Lookup Time: #slowTime#ms (slow method) | #fastTime#ms (fast method)</p>');
	if(ts.success){
		arrK=structkeyarray(ts);
		arraySort(arrK, "text", "asc");
		for(i in arrK){
			if(i EQ "success"){
				continue;
			}
			if(ts[i] NEQ 0 and ts[i] NEQ ""){
				echo('<p>#i#:'&ts[i]&'</p>');
			}
		}
	}else{
		echo('Unable to find location for ip: #form.ip#');
	}
	</cfscript> 
	</div>
	<div class="z-1of2">
	<cfif ts.success and ts.latitude NEQ "0" and ts.latitude NEQ "">

		<cfsavecontent variable="scriptOutput">
			<cfscript>
			application.zcore.functions.zRequireGoogleMaps();
			</cfscript> 
			<script>
			/* <![CDATA[ */
			var curMap=false;
			var arrAdditionalLocationLatLng=[];
			<cfscript> 
			arrLocation=[];
			ts={
				coordinates:ts.latitude&","&ts.longitude,
				info:"IP Location: #jsstringformat(form.ip)#"
			};
			arrayAppend(arrLocation, ts);   
			echo('arrAdditionalLocationLatLng=#serializeJson(arrLocation)#');
			</cfscript>  
			var markerCompleteCount=0;
			var arrMarker=[];
			function markerCallback(markerObj, location){  
				markerCompleteCount++;
				if(markerCompleteCount ==arrAdditionalLocationLatLng.length){
					zMapFitMarkers(curMap, arrMarker);
				}
			} 
			zArrMapFunctions.push(function(){ 
				if(arrAdditionalLocationLatLng.length){
					var optionsObj={ 
						zoom: 13 
					};
					var mapOptions = {
						zoom: 13,
						mapTypeId: google.maps.MapTypeId.ROADMAP
					}
					for(var i in optionsObj){
						mapOptions[i]=optionsObj[i];
					} 
					$("##mapContainerDiv").show();
					curMap=zCreateMap("mapDivId", mapOptions);  
					for(var i=0;i<arrAdditionalLocationLatLng.length;i++){ 
						var c=arrAdditionalLocationLatLng[i];
						var markerObj={};
						markerObj.infoWindowHTML=c.info;
						var arrLatLng=arrAdditionalLocationLatLng[i].coordinates.split(","); 
						var marker=zAddMapMarkerByLatLng(curMap, markerObj, arrLatLng[0], arrLatLng[1], markerCallback);  
						arrMarker.push(marker);
					}  
				}
			});
			/* ]]> */
			</script> 
		</cfsavecontent>
		<cfscript>
		request.zos.template.appendTag("scripts", scriptOutput);
		</cfscript>
		<div id="mapContainerDiv" style="width:100%; display:none; margin-bottom:20px; float:left;">
			<div style="width:100%; float:left; height:420px;" id="mapDivId"></div> 
		</div> 
	</cfif> 
	</div>
</cffunction>


<cffunction name="setLocationByIp" localmode="modern" access="public">
	<cfargument name="ip" type="string" required="yes">
	<cfscript>
	columnList="";
	if(structkeyexists(cookie, 'zStoredUserLocation') and listLen(cookie.zStoredUserLocation, ",") EQ 3){
		arrLocation=listToArray(cookie.zStoredUserLocation, ",");
		cs={
			success:true,
			latitude:arrLocation[1],
			longitude:arrLocation[2],
			type:arrLocation[3]
		};
	}else{
		cs=zGetFastIpLocation(arguments.ip, columnList); 
	}
	</cfscript> 
	<cfif cs.success>
		<cfsavecontent variable="out">
			<script>
			zArrDeferredFunctions.push(function(){
				zSetCurrentUserLocation(#cs.latitude#, #cs.longitude#, "#cs.type#");
			});
			</script>
		</cfsavecontent>
		<cfscript>
		application.zcore.template.appendTag("scripts", out);
		ts=structnew();
		ts.name="ZSTOREDUSERLOCATION";
		ts.value=cs.latitude&","&cs.longitude&","&cs.type;
		ts.expires="never";
		application.zcore.functions.zCookie(ts); 
		</cfscript>
	</cfif>
	<cfscript>
	return cs;
	</cfscript>
</cffunction>


<cffunction name="getDistanceFromLatLonInMiles" localmode="modern" access="public">
	<cfargument name="lat1" type="string" required="yes">
	<cfargument name="lon1" type="string" required="yes">
	<cfargument name="lat2" type="string" required="yes">
	<cfargument name="lon2" type="string" required="yes">
	<cfscript>
	lat1=arguments.lat1;
	lat2=arguments.lat2;
	lon1=arguments.lon1;
	lon2=arguments.lon2; 

	MilesPerLatitude = 69.09;
 
    DegreeDistance = rad2Deg(
        ACos(
			(
				Sin( deg2rad( lat1 ) ) *
				Sin( deg2rad( lat2 ) )
			)
			+
			(
				Cos( deg2rad( lat1 ) ) *
				Cos( deg2rad( lat2 ) ) *
				Cos( deg2rad( lon1 - lon2 ) )
			)
		)
    );
 
    return DegreeDistance * MilesPerLatitude; 
	</cfscript>
</cffunction>

<cffunction name="getDistanceFromLatLonInKm" localmode="modern" access="public">
	<cfargument name="lat1" type="string" required="yes">
	<cfargument name="lon1" type="string" required="yes">
	<cfargument name="lat2" type="string" required="yes">
	<cfargument name="lon2" type="string" required="yes">
	<cfscript>
	lat1=arguments.lat1;
	lat2=arguments.lat2;
	lon1=arguments.lon1;
	lon2=arguments.lon2;  
	miles=getDistanceFromLatLonInMiles(lat1,lon1,lat2,lon2);
	return milesToKm(miles); 
	</cfscript>
</cffunction>

<cffunction name="kmToMiles" localmode="modern" access="public">
	<cfargument name="km" type="string" required="yes">
	<cfscript>
	return arguments.km*1.609;
	</cfscript>
</cffunction>

<cffunction name="milesToKm" localmode="modern" access="public">
	<cfargument name="miles" type="string" required="yes">
	<cfscript> 
	return arguments.miles*0.621;
	</cfscript>
</cffunction>

<cffunction name="rad2Deg" localmode="modern" access="public">
	<cfargument name="radians" type="string" required="yes">
	<cfscript>  
    return (ARGUMENTS.Radians * 180) / Pi();
	</cfscript>
</cffunction>

<cffunction name="deg2Rad" localmode="modern" access="public">
	<cfargument name="deg" type="string" required="yes">
	<cfscript>  
	return arguments.deg * (PI()/180);
	</cfscript>
</cffunction>

<cffunction name="sortLocationsByDistance" localmode="modern" access="public">
	<cfargument name="latitude" type="string" required="yes">
	<cfargument name="longitude" type="string" required="yes">
	<cfargument name="arrLocation" type="array" required="yes">
	<cfscript>   
	arrLocation=arguments.arrLocation;
	arrDistance2=[];
	if(arrayLen(arrLocation)==0){
		return [];
	}
	if(not isnumeric(arguments.latitude) or not isnumeric(arguments.longitude)){
		for(i=1;i<=arraylen(arrLocation);i++){
			arrayAppend(arrDistance2, {distanceInMiles: 0, location:arrLocation[i] });
		}
		return arrDistance2;
	}
	ds={};
	for(i=1;i<=arraylen(arrLocation);i++){
		var latitude2=arrLocation[i].latitude;
		var longitude2=arrLocation[i].longitude; 
		var distanceInMiles=getDistanceFromLatLonInMiles(arguments.latitude, arguments.longitude, latitude2, longitude2); 
		ds[i]={distanceInMiles: distanceInMiles, location:arrLocation[i] };
	}
	arrDistance=structsort(ds, "numeric", "asc", "distanceInMiles");

	for(i=1;i<=arraylen(arrDistance);i++){
		arrayAppend(arrDistance2, ds[arrDistance[i]]);
	}
	return arrDistance2;
	</cfscript>
</cffunction> 

<cffunction name="initSelectedLocation" localmode="modern" access="public">
	<cfargument name="arrLocation" type="array" required="yes">
	<cfargument name="idField" type="string" required="yes">
	<cfargument name="defaultField" type="string" required="yes">
	<cfargument name="mapCoordinatesField" type="string" required="yes">
	<cfscript>
	arrLocation=arguments.arrLocation; 
	if(request.zos.istestserver){
		request.currentIP="67.78.165.194";
	}else{
		request.currentIP=request.zos.cgi.remote_addr;
	}
	// this location will be geoip, geolocation or manual user location
	cs=setLocationByIp(request.currentIP);
 	
 	if(arrayLen(arrLocation) EQ 0){
 		application.zcore.functions.z404("There must be at least one location added before you can view the front of the web site.");
 	}  
 
	request.zStoredBusinessLocationId = ''; 
	if(structkeyexists(form, 'zStoredBusinessLocationId')){
		request.zStoredBusinessLocationId=form.zStoredBusinessLocationId;
	}else if(structkeyexists(cookie, 'zStoredBusinessLocationId')){ 
		form.zStoredBusinessLocationId=cookie.zStoredBusinessLocationId;
		request.zStoredBusinessLocationId=form.zStoredBusinessLocationId;
	}
	if(request.zStoredBusinessLocationId EQ "" || request.zStoredBusinessLocationId EQ "0"){
		if(cs.success){ 
			arrLocationNew=[];
			for ( location in arrLocation ) {
				arrMap=listToArray(location[arguments.mapCoordinatesField], ",");
				if(arrayLen(arrMap) EQ 2){
					arrayAppend(arrLocationNew, {latitude:arrMap[1], longitude:arrMap[2], location:location});
				}
			}

			arrLocationDistance=sortLocationsByDistance(cs.latitude, cs.longitude, arrLocationNew);  
			if(arrayLen(arrLocationDistance) NEQ 0){
				form.zStoredBusinessLocationId=arrLocationDistance[1].location.location[arguments.idField];
				request.zStoredBusinessLocationId=form.zStoredBusinessLocationId;
			}
		}
	}
	request.zStoredBusinessLocationData={};
	for ( location in arrLocation ) {
		if(location[arguments.idField] EQ request.zStoredBusinessLocationId){
			request.zStoredBusinessLocationData=location;
		}
	}
	// force default location if all location lookups fail
	if(structcount(request.zStoredBusinessLocationData) EQ 0){
		for ( location in arrLocation ) { 
			if(location[arguments.defaultField] EQ "Yes"){ 
				request.zStoredBusinessLocationData=location;
				form.zStoredBusinessLocationId=request.zStoredBusinessLocationData[arguments.idField];
				request.zStoredBusinessLocationId=form.zStoredBusinessLocationId;
			}
		}
	}
	// force first location if all location lookups fail
	if(structcount(request.zStoredBusinessLocationData) EQ 0){
		request.zStoredBusinessLocationData=arrLocation[1];
		form.zStoredBusinessLocationId=request.zStoredBusinessLocationData[arguments.idField];
		request.zStoredBusinessLocationId=form.zStoredBusinessLocationId;
	}  
	ts=structnew();
	ts.name="ZSTOREDBUSINESSLOCATIONID";
	ts.value=request.zStoredBusinessLocationId;
	ts.expires="never";
	application.zcore.functions.zCookie(ts);    

	return request.zStoredBusinessLocationData;
	</cfscript>
</cffunction>


<!--- 
arrNearbyLocation=getLocationsNearUser(100, arrLocation, "Map Location");
for(i=1;i<=arraylen(arrNearbyLocation);i++){
	c=arrNearbyLocation[i];
	echo(c.location.title&" - "&c.distanceInMiles&" miles<br>");
}
 --->
<cffunction name="getLocationsNearUser" localmode="modern" access="public">
	<cfargument name="maxDistance" type="numeric" required="yes">
	<cfargument name="arrLocation" type="array" required="yes"> 
	<cfargument name="mapCoordinatesField" type="string" required="yes">
	<cfscript>
	arrLocation=arguments.arrLocation;
	if(not structkeyexists(cookie, 'zStoredUserLocation')){
		arrFinal=[];
		for(location in arrLocation){ 
			arrayAppend(arrFinal, {distanceInMiles: 0, location:location});
		}
		return arrFinal;
	}
	arrUserLocation=listToArray(cookie.zStoredUserLocation, ",");

	arrLocationNew=[];
	for ( location in arrLocation ) {
		arrMap=listToArray(location[arguments.mapCoordinatesField], ",");
		if(arrayLen(arrMap) EQ 2){
			arrayAppend(arrLocationNew, {latitude:arrMap[1], longitude:arrMap[2], location:location});
		}
	}

	arrLocationDistance=sortLocationsByDistance(arrUserLocation[1], arrUserLocation[2], arrLocationNew);   
	arrFinal=[];
	for(location in arrLocationDistance){
		if(location.distanceInMiles LTE arguments.maxDistance){
			arrayAppend(arrFinal, {distanceInMiles: location.distanceInMiles, location:location.location.location});
		}
	}
	return arrFinal;
	</cfscript>
</cffunction>
 
<cffunction name="getSelectedLocationData" localmode="modern" access="public">
	<cfscript>
	if(not structkeyexists(request, 'zStoredBusinessLocationData')){
		throw("geoip.initSelectedLocation() must be run before running getSelectedLocationData");
	}
	return request.zStoredBusinessLocationData;
	</cfscript>
</cffunction>
	
</cfoutput>
</cfcomponent>