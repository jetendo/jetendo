
var pixelXLongOffset=0;
var pixelYLatOffset=0;
var mapLoadFunction=function(){};
var mapObj=false;
var mapProps=new Object();
//var arrMarkers=new Array();
var streetView=false;
var mapFullscreen=false;
var zGMapAbsPos=null;
var zHideMapControl=false;
var zOneLatitude=false;
var zOneLongitude=false;
var zMapOverlayDivObj=null;
var zMapOverlayDivObjAbsPos=null;
var zMapOverlayDivObjAbsPos2=null;
var zMapIgnoreMoveEnd=false;
var zMapCurrentListingLink=null;
//var mapProps.zArrMapTotalLat=[];
//var mapProps.zArrMapTotalLong=[];
//var mapProps.zArrMapText=[];
//var mapProps.mapCount=0;
var zBingAddress="";
function createMarker(point, htmlText) {
	var marker = new GMarker(point);
	google.maps.event.addListener(marker, "click", function() {
	  marker.openInfoWindowHtml(htmlText);
	});
	//arrMarkers.push(marker);
	
	return marker;
}
function zlsOpenResultsMap(formName){
	if(typeof formName == "undefined"){
		formName="zMLSSearchForm";
	}
	var arrQ=[];
	var d3=document.getElementById("resultCountAbsolute");
	if(d3 && d3.innerHTML.substr(0,1) === 0){
		alert('There are no matching listings, please revise your search before clicking to view the map');
		return;	
	}
	var obj=zFormSubmit(formName, false, true,false, true);
	for(var i in obj){
		if(typeof zlsSearchCriteriaMap[i] !== "undefined" && obj[i] !== ""){
			arrQ.push(zlsSearchCriteriaMap[i]+"="+obj[i]);
		}
	}
	//zlsSearchCriteriaMap[i];
	var d1=arrQ.join("&");
	if(d1.length >= 1950){
		alert("You've selected too many criteria. Please reduce the number of selections for the most accurate search results.");
	}
	var newLink="/z/listing/map-fullscreen/index?"+d1.substr(0,1950);
	//console.log(newLink);
	window.open(newLink);
}
var zMapFirstZoomChange=true;
var widthPerPixel=0.000011257672119140625;
var heightPerPixel=0.000010531174841353967;
var widthPerPixel=0.000021457672119140625;
var heightPerPixel=0.000018731174841353967;
var zMapCurrentZoom=0;
var zMapTimeoutUpdate=0;

if(typeof zMapFullscreen === "undefined"){
	zMapFullscreen=false;
}
function zlsGotoMapLink(url){
	if(zMapFullscreen){
		window.open(url);
	}else{
		window.top.location.href=url;
	}
}

function onGMAPLoad(force) {
	if(typeof zDisableOnGmapLoad !== "undefined" && zDisableOnGmapLoad) return;
	if((typeof force === "undefined" || !force) && (!zFunctionLoadStarted || typeof google === "undefined" || typeof google.maps === "undefined" || typeof google.maps.LatLng === "undefined")){// || typeof zMapGaLoaded === "undefined" || !zMapGaLoaded){
		return;
	}
	var arrC=zGetElementsByClassName("zMapLoadInputVarsClass");
	if(arrC.length === 0 || typeof arrC[0].value === "undefined" || arrC[0].value ===""){
		return;
	}
	var myObj=eval('('+arrC[0].value+')');
	mapProps=myObj;
	if(typeof google.maps.OverlayView === "undefined") return;
	if(zIsTouchscreen() && window.location.href.indexOf("/listing/search-form") !== -1){
		document.getElementById('map489273').style.display='none';
		return;
	}
	zLatLngControl.prototype = new google.maps.OverlayView();
	zLatLngControl.prototype.draw = function() {};
	zLatLngControl.prototype.createHtmlNode_ = function() {
		var divNode = document.createElement('div');
		divNode.id = 'latlng-control';
		divNode.index = 100;
		return divNode;
	};
	zLatLngControl.prototype.visible_changed = function() {
		this.node_.style.display = this.get('visible') ? '' : 'none';
	};
	zLatLngControl.prototype.updatePosition = function(latLng) {
		var projection = this.getProjection();
		var point = projection.fromLatLngToContainerPixel(latLng);
		zCurMapPixelV3=point;
	};
	zWindowSize=getWindowSize();
	if(typeof mapProps.stageWidth === "string" && mapProps.stageWidth.substr(mapProps.stageWidth.length-1) === "%"){
		mapProps.curStageWidth=zWindowSize.width+zScrollbarWidth;
	}else{
		mapProps.curStageWidth=parseInt(mapProps.stageWidth);
	}
	if(typeof mapProps.stageWidth === "string" && mapProps.stageHeight.substr(mapProps.stageHeight.length-1) === "%"){
		mapProps.curStageHeight=zWindowSize.height;
	}else{
		mapProps.curStageHeight=parseInt(mapProps.stageHeight);
	}
	mapProps.longBlockWidth=84;
	mapProps.latBlockWidth=91;
	mapProps.latBlocks=Math.ceil(mapProps.curStageHeight/mapProps.longBlockWidth);
	mapProps.longBlocks=Math.ceil(mapProps.curStageWidth/mapProps.latBlockWidth);
	zMapOverlayDivObjAbsPos=zGetAbsPosition(zMapOverlayDivObj);
	//setTimeout("loadBingMap();",200);
	mapLoadFunction();
	
	if(mapProps.avgLat===0 || mapProps.avgLong===0){
		var d383=document.getElementById("zMapAllDiv");
		d383.style.display="none";
		return;
	}
	// width/height per pixel at zoom 1
	minLat=0;
	maxLat=0;
	minLong=0;
	maxLong=0;
	if(mapProps.mapCount!==0 && typeof mapProps.zArrMapTotalLat !=="undefined" && mapProps.zArrMapTotalLat.length !== 0){
		minLat=mapProps.zArrMapTotalLat[0];
		maxLat=mapProps.zArrMapTotalLat[0];
		minLong=mapProps.zArrMapTotalLong[0];
		maxLong=mapProps.zArrMapTotalLong[0];
		for(i=0;i<mapProps.mapCount;i++){
			if(mapProps.zArrMapTotalLat[i]<minLat){
				minLat=mapProps.zArrMapTotalLat[i];
			}
			if(mapProps.zArrMapTotalLat[i]>maxLat){
				maxLat=mapProps.zArrMapTotalLat[i];
			}
			if(mapProps.zArrMapTotalLong[i]<minLong){
				minLong=mapProps.zArrMapTotalLong[i];
			}
			if(mapProps.zArrMapTotalLong[i]>maxLong){
				maxLong=mapProps.zArrMapTotalLong[i];
			}
		}
		avgLat=(maxLat+minLat)/2;
		avgLong=(maxLong+minLong)/2;
	}else{
		avgLat=mapProps.avgLat;
		avgLong=mapProps.avgLong;
	}
	margin=50;
	if(minLat===0){
		minLat=avgLat;
		maxLat=avgLat;	
		minLong=avgLong;
		maxLong=avgLong;	
	}
	mapProps.minLat=minLat;
	mapProps.maxLat=maxLat;
	mapProps.minLong=minLong;
	mapProps.maxLong=maxLong;
	/*minLat=Math.max(19.66328,minLat);
	maxLat=Math.min(34.22697,maxLat);
	minLong=Math.max(-83.803711,minLong);
	maxLong=Math.min(-76.641602,maxLong);*/
	avgLat=(maxLat+minLat)/2;
	avgLong=(maxLong+minLong)/2;
	// latitude = y   longitude = x
	// get the zoom level
	propHeight=Math.max(heightPerPixel*50,Math.abs(maxLat-minLat));
	propWidth=Math.max(widthPerPixel*50,Math.abs(maxLong-minLong));
	twp=widthPerPixel;
	thp=heightPerPixel;
	for(zoom=1;zoom<=20;zoom++){
		if(zoom !== 1){
			twp*=2;
			thp*=2;
		}
		maxWidth=mapProps.curStageWidth*twp;
		maxHeight=mapProps.curStageHeight*thp;
		// all properties must fit within zoom level
		if(maxWidth>propWidth+(twp*margin) && maxHeight>propHeight+(thp*margin)){
			break;
		}
	}
	if(!document.getElementById('search_within_map_name1') || document.getElementById('search_within_map_name1').checked===false){
		zoom++;	
	}
	// set zoom and center
	mapProps.avgLong=avgLong;
	mapProps.avgLat=avgLat;
	if(mapProps.forceZoom !== 0){
		mapProps.zoom=mapProps.forceZoom;
	}else{
		if(Math.abs(maxLat-minLat)===0){
			mapProps.zoom=20-zoom;
		}else{
			mapProps.zoom=18-zoom;
		}
	}
	streetView=false;
	
	onGMAPLoadV3();
}
zArrLoadFunctions.push({functionName:onGMAPLoad});
var zAjaxNearAddressMarker=false;
var zMapMarkerIdOff=0;

function toggleMapFullscreen(){
	var mapDiv=document.getElementById("myGoogleMap");
	var mapFloater=document.getElementById("mapFloater");
	
	if(mapFullscreen){
		mapFullscreen=false;
		mapProps.stageWidth=mapProps.curStageWidth;
		mapProps.stageHeight=mapProps.curStageHeight;
		mapDiv.style.width=mapProps.curStageWidth+'px';
		mapDiv.style.height=mapProps.curStageHeight+'px';
		mapFloater.style.marginLeft='10px'; 
		mapFloater.style.marginBottom='10px';
	}else{
		mapFullscreen=true;
		mapFloater.style.marginLeft='0px'; 
		mapFloater.style.marginBottom='10px';
		// find size of full screen and copy functionality from tiny mce or other source
		alert('not implemented');
		return;
	}
	onLoad();
}
function searchWithinMap(forceSubmit){
	var bounds =new Object();
	bounds.minY=mapObjV3.getBounds().getSouthWest().lat();
	bounds.minX=mapObjV3.getBounds().getSouthWest().lng();
	bounds.maxY=mapObjV3.getBounds().getNorthEast().lat();
	bounds.maxX=mapObjV3.getBounds().getNorthEast().lng();
	document.mapSearchForm.search_map_coordinates_list.value=bounds.minX+","+bounds.maxX+","+bounds.minY+","+bounds.maxY;
	document.mapSearchForm.submit();
}
/*
  var BingMap = null;
  var pinLocation = "";
  var bingid=null;
  var VEMap=null;
	function loadBingMap(){
	if(document.getElementById("zGStreetView")==null)return;
	var url = "http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=6.2&mkt=en-us";
	var e = document.createElement("script");
	e.src = url;
	e.type="text/javascript";
	document.getElementsByTagName("head")[0].appendChild(e);
	bingid=setInterval("GetBingMap()",1000);
	}
var zBingCheckId=null;
	
function GetBingMap() {
	return;
	if(typeof VEMap=="function" && bingid!=null){
		clearInterval(bingid);
		bingid=null;
		//setTimeout("GetBingMap()",3000);
		//return;
	} else if(bingid!=null) {
		return;
	}

	BingMap = new VEMap('myBingMap');
	BingMap.LoadMap(new VELatLong(zOneLatitude, zOneLongitude),17);
	BingMap.AddPushpin(new VELatLong(zOneLatitude, zOneLongitude));
	zBingCheckId=setTimeout("zBingHideMap();",500);
	BingMap.AttachEvent("onobliqueenter", OnObliqueEnterHandler);
	
}   
function zBingHideMap(){
	return;
	document.getElementById("myBingMapC").style.display="none";
	clearTimeout(zBingCheckId);
	zBingCheckId=null;
}

function OnObliqueEnterHandler() {
	if(BingMap.IsBirdseyeAvailable()) {
		clearTimeout(zBingCheckId);
		zBingCheckId=null;
		document.getElementById("myBingMapC").style.display="block";
		var TopOfProperty = new VELatLong(zOneLatitude, zOneLongitude); 
		BingMap.SetBirdseyeScene(TopOfProperty);
	}
}
*/

var myPano;	
if(typeof GClientGeocoder!=="undefined"){
	var geocoder = new GClientGeocoder();
}
var streetviewlatlong=0;
if(typeof GStreetviewClient!=="undefined"){
	var panoClient = new GStreetviewClient(); 
}
function gmsvShowAddress() { 
	if(document.getElementById("zGStreetView")===null)return;
	if(zOneLatitude !== ""){ 
		gmsvLoadGoogleMaps({y:zOneLatitude,x:zOneLongitude}); 
	}else if(zBingAddress !== ""){
		geocoder.getLatLng( zBingAddress   ,    function(point) {      if (!point) {    if(zOneLatitude !== ""){ gmsvLoadGoogleMaps({y:zOneLatitude,x:zOneLongitude}); }else{ handleGMSVErr(0); }    } else {  gmsvLoadGoogleMaps(point); }    }  );
	}else{ handleGMSVErr(0);}
}
var mapLoadFunction=gmsvShowAddress;
function gmsvLoadGoogleMaps(point){
	streetviewlatlong = new google.maps.LatLng(point.y,point.x);
	var panoramaOptions = { latlng:streetviewlatlong };
	myPano = new google.maps.StreetViewPanorama(document.getElementById("pano"), panoramaOptions);
      google.maps.event.addListener(myPano, "error", handleGMSVErr);
      // must be changed to: getPanoramaByLocation() instead of: panoClient.getNearestPanorama(streetviewlatlong, showPanoData);
}
function handleGMSVErr(errorCode) { //alert("errorCode:"+errorCode);
var d1=document.getElementById("zGStreetView");d1.style.display="none"; }  

function showPanoData(panoData) {
  if (panoData.code !== 200) {
   // GLog.write('showPanoData: Server rejected with code: ' + panoData.code);
   handleGMSVErr(0);
	return;
  }
  var d1=document.getElementById("zGStreetView");
  d1.style.display="block";
  var angle = computeAngle(streetviewlatlong, panoData.location.latlng);
  myPano.setLocationAndPOV(panoData.location.latlng, {yaw: angle});
}

function computeAngle(endLatLng, startLatLng) {
  var DEGREE_PER_RADIAN = 57.2957795;
  var RADIAN_PER_DEGREE = 0.017453;

  var dlat = endLatLng.lat() - startLatLng.lat();
  var dlng = endLatLng.lng() - startLatLng.lng();
  var yaw = Math.atan2(dlng * Math.cos(endLatLng.lat() * RADIAN_PER_DEGREE), dlat)
		 * DEGREE_PER_RADIAN;
  return wrapAngle(yaw);
}

function wrapAngle(angle) {
if (angle >= 360) {
  angle -= 360;
} else if (angle < 0) {
 angle += 360;
}
return angle;
}
function zSetNearAddress(v){
	if(v !== ""){
		zSetWithinMap(1);
		zSetWithinMap2(1);
	}else{
		zSetWithinMap(0);
		zSetWithinMap2(0);
	}
}

function zSetWithinMap(b){
	b=parseInt(b);
	var d1=document.getElementById("setWithinMapRadio1");
	if(d1===null) return;
	var d2=document.getElementById("setWithinMapRadio2");
	if(b===1){
		d2.checked=false;
		d1.checked=true;
	}else{	
		d2.checked=true;
		d1.checked=false;
	}
	getMLSCount('zMLSSearchForm');
}
function zSetWithinMap2(b){
	b=parseInt(b);
	var d1=document.getElementById("setWithinMapRadio1");
	var d4=document.getElementById("setWithinMapRadio2");
	if(d1===null) return;
	var d2=document.getElementById("search_within_map");
	if(b===1){
		d1.checked=true; 
		d4.checked=false;
		d2.value=1;
	}else{
		d1.checked=false;
		d4.checked=true;
		d2.value=0;
	} 
	$(d2).trigger("change");
}

if (typeof(Number.prototype.toRad) === "undefined") {
  Number.prototype.toRad = function() {
    return this * Math.PI / 180;
  }
}
function zGetMapDistance(lat1, lon1, lat2, lon2){
	var R = 6371; // km
	var dLat = (lat2-lat1).toRad();
	var dLon = (lon2-lon1).toRad();
	var lat1 = lat1.toRad();
	var lat2 = lat2.toRad();
	
	var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
			Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2); 
	var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
	var d = R * c;	
	return d;
}
function zGeocodeAddress() {
	if(arrAddress.length <= curIndex) return;
	if(debugajaxgeocoder) f1.value+="run geocode: "+arrAddress[curIndex]+" for listing_id="+arrListingId[curIndex]+"\n";


	if(!zIsGeocoderAvailable()){
		// prevent more geocoding for this user.
		return;
	}

	geocoder.geocode( { 'address': arrAddress[curIndex]+" "+arrAddressZip[curIndex]}, function(results, status) {
		var r="";
		if (status == google.maps.GeocoderStatus.OK) {
			var a1=new Array();
			console.log(results);
			for(var i=0;i<results.length;i++){
				var a2=new Array();
				a2[0]=results[i].types.join(",");
				if(a2[0]=="street_address" || a2[0]=="premise" || a2[0]=="subpremise"){// && arrAddressZipLat[curIndex] != 0 && arrAddressZipLong[curIndex] != 0){
					a2[1]=results[i].formatted_address;
					a2[2]=results[i].geometry.location.lat()
					a2[3]=results[i].geometry.location.lng();
					a2[4]=results[i].geometry.location_type;
					var a3=a2.join("\t");
					/*var k=zGetMapDistance(arrAddressZipLat[curIndex], arrAddressZipLong[curIndex], a2[2], a2[3]);
					if(k >= 50){
						// the distance is beyond reasonable - this one is invalid
					}else{*/
						a1.push(a3);  
					//}
					break;	
				}
			}
			r=a1.join("\n");
			if(debugajaxgeocoder) f1.value+="Result:"+r+"\n";
		} else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT || status == google.maps.GeocoderStatus.REQUEST_DENIED){
			// serious error condition
			stopGeocoding=true; 
		}
		var curStatus="";
		if(status == google.maps.GeocoderStatus.OK){
			curStatus="OK";
		}else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT){
			curStatus="OVER_QUERY_LIMIT";
		}else if(status == google.maps.GeocoderStatus.REQUEST_DENIED){
			curStatus="REQUEST_DENIED";
		}else if(status == google.maps.GeocoderStatus.ZERO_RESULTS){
			curStatus="ZERO_RESULTS";
		}else if(status == google.maps.GeocoderStatus.INVALID_REQUEST){
			curStatus="INVALID_REQUEST";
		}else if(status == 'ERROR'){
			stopGeocoding=true;
			// This is an undocumented problem with google's API. We must stop geocoding and wait for a new user with a fresh copy of google's API downloaded that hopefully works.
			return;
		}else{
			curStatus=status;
		}
		if(debugajaxgeocoder) f1.value+='geocode done for listing_id='+arrListingId[curIndex]+" with status="+curStatus+"\n";
		var debugurlstring="";
		if(debugajaxgeocoder){
			debugurlstring="&debugajaxgeocoder=1";
		} 
		var tempObj={};
		tempObj.id="zMapListing";
		tempObj.method="post";
		tempObj.postObj={
			results: r, listing_id: arrListingId[curIndex], address: arrAddress[curIndex], zip: arrAddressZip[curIndex], status: curStatus
		};
		tempObj.url="/z/listing/ajax-geocoder/save?"+debugurlstring;
		tempObj.callback=function(r){
			var r=JSON.parse(r);
			if(debugajaxgeocoder) f1.value+="geocode save status="+r.success+"\n";
		};
		tempObj.errorCallback=function(){ /*ignore*/ };
		tempObj.cache=false;
		zAjax(tempObj); 
		curIndex++;
		if(curIndex<arrAddress.length && !stopGeocoding){
			setTimeout('zTimeoutGeocode();',6000);
		}
	});
}
function zTimeoutGeocode(){
	if(stopGeocoding) return;
	zGeocodeAddress();
}


var mapObjV3=false;
var zGMapAbsPosV3=0;
var arrMapMarkersV3=new Array();
var debugTextarea;
var zMapOverlaysV3=new Array();
var zMapOverlaysIdsV3=new Array();
var zArrPermanentMarkerV3=new Array();
var zHighestMapCountV3=0;
var zMarkerMapCounterV3=0;
var zMapOverlayDivObjV3=0;
var zMapOverlayDivObjAbsPosV3=0;
var zCurrentMarkerMapCounterV3=0;
var zMapCurrentListingLinkV3="";
var zMapOverlayDivObjAbsPos2V3=0;
var zCurMapPixelV3;
var zCoorUpdateIntervalIdV3;
var zMarkerMapTypeTrack=new Array();
var zLatLngControlInstance;
//zMapMarkerV3.prototype = new google.maps.OverlayView();

var zLatLngControl=function(map) {
	if(typeof google === "undefined" || typeof google.maps === "undefined" || typeof google.maps.LatLng === "undefined"){
		return;
	}
	this.ANCHOR_OFFSET_ = new google.maps.Point(8, 8);
	this.node_ = this.createHtmlNode_();
	map.controls[google.maps.ControlPosition.TOP].push(this.node_);
	this.setMap(map);
	this.set('visible', false);
};
function gmapV3ClearMarkers() {   return;
	/*if (zMapOverlaysV3) {
		for (var i in zMapOverlaysV3) {
			zMapOverlaysV3[i].setMap(null);
		}
		//zMapOverlaysV3.length = 0;
	}*/
}

function zAddPermanentMarkerV3(pm){
	for(var i=0;i<zArrPermanentMarkerV3.length;i++){
		if(zArrPermanentMarkerV3[i].title === pm.title){
			zArrPermanentMarkerV3[i].point=pm.point;
			zArrPermanentMarkerV3[i].title=pm.title;
			zArrPermanentMarkerV3[i].htmlText=pm.htmlText;
			zArrPermanentMarkerV3[i].marker=zCreatePermanentMarkerV3(zArrPermanentMarkerV3[i]);
			return zArrPermanentMarkerV3[i].marker;
		}
	}
	
	zArrPermanentMarkerV3.push(pm);
	zArrPermanentMarkerV3[zArrPermanentMarkerV3.length-1].marker=zCreatePermanentMarkerV3(zArrPermanentMarkerV3[zArrPermanentMarkerV3.length-1]);
	return zArrPermanentMarkerV3[zArrPermanentMarkerV3.length-1].marker;
}
function zRemovePermanentMarkers(){
	for(var i=0;i<zArrPermanentMarkerV3.length;i++){
		zArrPermanentMarkerV3[i].marker.setMap(null);
	}
	zArrPermanentMarkerV3=[];
}
function zCreatePermanentMarkersV3(offset){
	for(var i=0;i<zArrPermanentMarkerV3.length;i++){
		zArrPermanentMarkerV3[i].marker=zCreatePermanentMarkerV3(zArrPermanentMarkerV3[i]);
	}
}
function zCreatePermanentMarkerV3(pm){
	var title="";
	if(pm.marker){
		pm.marker.setMap(null);
		pm.marker=false;
	}
	
	var infowindow = new google.maps.InfoWindow({
		content: pm.htmlText
	});
	var marker = new google.maps.Marker({
		position: pm.point,
		map: mapObjV3,
		title: pm.title
	});
	google.maps.event.addListener(marker, 'click', function() {
	  infowindow.open(mapObjV3,marker);
	});
	return marker;
}
zMapArrLoadFunctions=[];
function zlsUpdateMapSize(){
	var mid3=document.getElementById("myGoogleMapV3");
	mapProps.curStageWidth=zWindowSize.width+zScrollbarWidth;
	mapProps.curStageHeight=zWindowSize.height;
	mapProps.latBlocks=Math.ceil(mapProps.curStageHeight/mapProps.longBlockWidth);
	mapProps.longBlocks=Math.ceil(mapProps.curStageWidth/mapProps.latBlockWidth);
	//myGoogleMapV3.style.width=mapProps.curStageWidth+"px";
	myGoogleMapV3.style.height=mapProps.curStageHeight+"px";
}
function onGMAPLoadV3(){
	zMapOverlayDivObjV3=document.getElementById("zMapOverlayDivV3");
	zMapOverlayDivObjAbsPosV3=zGetAbsPosition(zMapOverlayDivObjV3);
	var mid3=document.getElementById("myGoogleMapV3");
	if(mid3===null){
		return;
	}
	//myGoogleMapV3.style.width=mapProps.curStageWidth+"px";
	myGoogleMapV3.style.height=mapProps.curStageHeight+"px";
	var myLatlng = new google.maps.LatLng(mapProps.avgLat,mapProps.avgLong);
	var myOptions = {
		streetViewControl: false,
		panControl:true, 
	  zoom: mapProps.zoom,
	  center: myLatlng,
	  mapTypeId: google.maps.MapTypeId.HYBRID
	};
	mapObjV3 = new google.maps.Map(mid3, myOptions);
	google.maps.event.addListener(mapObjV3, "click", function(){zMapMarkerRollOutV3(true); }); 
	
	
	
	zLatLngControlInstance = new zLatLngControl(mapObjV3);
 	zGMapAbsPosV3=zGetAbsPosition(mid3);
	//debugTextArea=document.getElementById('cojunasd83');
	
	 //debugTextArea.value="";
	 
	for(var n=0;n<zMapOverlaysIdsV3.length;n++){
		zMapOverlaysV3[n].setMap(null);
	}
	zMapOverlaysIdsGroupV3=[];
	zMapOverlaysIdsV3=[];
	zMapOverlaysV3=[];
	zRemovePermanentMarkers();
	 
	google.maps.event.addListener(mapObjV3, 'mouseover', function(mEvent) {
	  zLatLngControlInstance.set('visible', true);
	});
	google.maps.event.addListener(mapObjV3, 'mouseout', function(mEvent) {
	  zLatLngControlInstance.set('visible', false);
	});
	google.maps.event.addListener(mapObjV3, 'mousemove', function(mEvent) {
	  zLatLngControlInstance.updatePosition(mEvent.latLng); zMapMarkerMouseMoveV3(mEvent,this);
	});
	
	 
	 
		
	google.maps.event.addListener(mapObjV3, 'zoom_changed', function(){var oldZoom=-99;var newZoom = mapObjV3.getZoom();
	//debugTextArea.value+="zoom:"+newZoom+"\n";
	
	zMapOverlayDivObjV3.style.display="none"; zMapCurrentZoom=newZoom; if(oldZoom !== newZoom && !zMapFirstZoomChange){ gmapV3ClearMarkers();zCreatePermanentMarkersV3(); } zMapOverlaysIds=[];zMapOverlays=[]; zMapFirstZoomChange=false; clearTimeout(zMapTimeoutUpdate); /*zMapTimeoutUpdate=setTimeout('zMapCoorUpdateV3(true,zMLSSearchFormName);',10); */ if(newZoom>oldZoom){ streetView=false;}  });
	
	google.maps.event.addListener(mapObjV3, "bounds_changed", zMapBoundsChange);
	//google.maps.event.addListener(mapObjV3, "dragend", function(){/*debugTextArea.value+="dragend\n";*/zMapOverlayDivObjV3.style.display="none";if(!zMapIgnoreMoveEnd){ clearInterval(zMapTimeoutUpdate); zMapTimeoutUpdate=setTimeout('zMapCoorUpdateV3(true,zMLSSearchFormName);',10);} zMapIgnoreMoveEnd=false; });
	google.maps.event.addListener(mapObjV3,  "dragstart", function(){/*debugTextArea.value+="dragstart\n";*/zMapOverlayDivObjV3.style.display="none"; });
	
	google.maps.event.addListener(mapObjV3, "drag", function(){/*debugTextArea.value+="dragging\n";*/zMapOverlayDivObjV3.style.display="none";  });
	 
	google.maps.event.addListener(mapObjV3, "dragend", function(){ });
	for(var i=0;i<mapProps.mapCount;i++){
		if(mapProps.zArrMapText[i] !== false){
			var pm=new Object();
			pm.point=new google.maps.LatLng(mapProps.zArrMapTotalLat[i],mapProps.zArrMapTotalLong[i]);
			pm.title="zNearAddressMarker";
			pm.htmlText='<table width="150"><tr><td>'+mapProps.zArrMapText[i]+'</td></tr></table>';
			var marker=zAddPermanentMarkerV3(pm);
			zMapOverlaysV3.push(marker);
		}
	}
	if(zAjaxNearAddressMarker){
		var d2=document.getElementById("search_near_address");
		arrAd=d2.value.split(",");
		var ad1=arrAd.shift()+"<br>"+arrAd.join(",");
		//debugTextArea.value+="ad1:"+ad1+"\n";
		
		var pm=new Object();
		pm.point=new google.maps.LatLng(zAjaxNearAddressMarker[0], zAjaxNearAddressMarker[1]);
		pm.title="zNearAddressMarker";
		pm.htmlText='<table width="150"><tr><td>Location:<br>'+ad1+'</td></tr></table>';
		var marker=zAddPermanentMarkerV3(pm);
		google.maps.event.trigger(marker,'click');
		zMapOverlaysV3.push(marker);
	}
	setTimeout("zMapTryUpdateV3();",1000);
	//zCoorUpdateIntervalIdV3=setInterval('zMapCoorUpdateV3(true,zMLSSearchFormName)',50);
	
}
function zMapBoundsChange(){/*debugTextArea.value+="dragend\n";*/if(typeof zMapOverlayDivObjV3.style !== "undefined") {zMapOverlayDivObjV3.style.display="none";}if(!zMapIgnoreMoveEnd){ clearInterval(zMapTimeoutUpdate); zMapTimeoutUpdate=setTimeout(zMapMapTimeoutUpdate,100);} zMapIgnoreMoveEnd=false; 
}
function zMapMapTimeoutUpdate(){
	zMapCoorUpdateV3(true,zMLSSearchFormName);
}
function zMapTryUpdateV3(){
	if(zMarkerMapTypeTrack.length===0){
		google.maps.event.trigger(mapObjV3,'zoom_changed');
	}
	for(var i=0;i<zMapArrLoadFunctions.length;i++){
		zMapArrLoadFunctions[i]();	
	}
}
			

function zMapCoorUpdateV3(fireAjax, formName) {
	var bounds =new Object(); 
	if(!mapObjV3.getBounds || typeof mapObjV3.getBounds() !== "object"){
		return; 
	}
	bounds.minY=mapObjV3.getBounds().getSouthWest().lat();
	bounds.minX=mapObjV3.getBounds().getSouthWest().lng();
	bounds.maxY=mapObjV3.getBounds().getNorthEast().lat();
	bounds.maxX=mapObjV3.getBounds().getNorthEast().lng();
	var fd=document.getElementById(formName);
	
	if(fd !==null && $("#search_map_coordinates_list").length) {
		$("#search_map_coordinates_list").val(bounds.minX+","+bounds.maxX+","+bounds.minY+","+bounds.maxY);
		//alert(fd.search_map_coordinates_list.value);
		//debugTextArea.value+="coor:"+fd.search_map_coordinates_list.value+"\n";
		$("#search_map_long_blocks").val(mapProps.longBlocks);
		$("#search_map_lat_blocks").val(mapProps.latBlocks);
		if(fireAjax) {
			if(typeof zFormData === "undefined" || typeof zFormData[formName] === "undefined"){
				zArrDeferredFunctions.push(function(){zFormData[formName].onChangeCallback(formName);});
			}else{
				zFormData[formName].onChangeCallback(formName);
			}
		}
	}
}
var zMapOverlaysIdsGroupV3=[];	
zUpdateMapMarkersV3First=true;	
function zUpdateMapMarkersV3(obj){
	if(typeof google === "undefined" || typeof google.maps === "undefined" || typeof google.maps.LatLng === "undefined"){
		return;
	}
	if(zArrPermanentMarker.length !== 0 || zArrPermanentMarkerV3.length !== 0) return;
	var arrOverlays=new Array();
	var arrOverlaysTemp=new Array();
	var arrOverlaysGroupTemp=new Array();
	var arrSkip=new Array();
	var found=false; 
	if(typeof obj.listing_id !== "undefined" && obj.listing_latitude !== ""){
		for(var n=0;n<zMapOverlaysIdsGroupV3.length;n++){
			if(zMapOverlaysIdsGroupV3[n] === true){
				//	console.log("group clear n2:"+n);
				zMapOverlaysV3[n].setMap(null);
			}
		}
		zHighestMapCountV3=0;
		if(zUpdateMapMarkersV3First && typeof obj.allMinLat !== "undefined" && window.location.href.indexOf("map-fullscreen") !== -1){
			var markerBounds = new google.maps.LatLngBounds(); 
			markerBounds.extend(new google.maps.LatLng(obj.allMinLat,obj.allMinLong)); 
			markerBounds.extend(new google.maps.LatLng(obj.allMinLat,obj.allMaxLong)); 
			markerBounds.extend(new google.maps.LatLng(obj.allMaxLat,obj.allMaxLong)); 
			markerBounds.extend(new google.maps.LatLng(obj.allMaxLat,obj.allMinLong)); 
			mapObjV3.fitBounds(markerBounds);
			zUpdateMapMarkersV3First=false;
		}
		for(var i2=0;i2<obj.listing_id.length;i2++){
			if(obj.listing_id[i2] === "0"){
				zHighestMapCountV3=Math.max(zHighestMapCountV3,obj.arrCount[i2]);
			}
		}
		
		for(var i2=0;i2<obj.arrColor.length;i2++){
			found=-1;
			if(obj.listing_id[i2] !== "0" && obj.listing_id[i2] !== ""){
				for(var n=0;n < zMapOverlaysIdsV3.length;n++){
					if(zMapOverlaysIdsV3[n]===obj.listing_id[i2]){
						found=zMapOverlaysIdsV3[n];	
						marker=zMapOverlaysV3[n];
						marker.setIcon("/z/a/listing/images/icon-home"+obj.arrColor[i2]+".jpg");
						if(typeof mapObjV3 === "object" && mapObjV3 !== null){
							marker.setMap(mapObjV3);
						}
						marker.myForceEasyClick=true;
						arrSkip.push(found);
						break;
					}
				}
				if(found===-1){
					var myLatlng = new google.maps.LatLng(obj.listing_latitude[i2],obj.listing_longitude[i2]);
					var marker=createMarkerListingAjaxV3(myLatlng, obj.listing_id[i2], obj.arrColor[i2]); 
					marker.listing_id = obj.listing_id[i2];
				}
				arrOverlaysGroupTemp.push(false);
			}else{
				//console.log("group"+(arrOverlaysTemp.length)+":"+obj.minLat[i2]+":"+obj.minLong[i2]);
				var myLatlng = new google.maps.LatLng(obj.minLat[i2],obj.minLong[i2]);
				var marker=createMarkerGroupBgAjaxV3(myLatlng, obj, i2, obj.arrColor[i2]); 
				//var marker=createMarkerGroupBgAjaxV3(myLatlng, obj, i2, obj.arrColor[i2]); 
				marker.listing_id = "0"+obj.minLat[i2]+":"+obj.minLong[i2];
				//console.log("marker"+obj.minLat[i2]+":"+obj.minLong[i2]+":"+obj.arrCount[i2]+":"+obj.avgPrice[i2]);
				arrOverlaysGroupTemp.push(true);
			}
			arrOverlaysTemp.push(obj.listing_id[i2]+":"+obj.minLat[i2]+":"+obj.minLong[i2]);
			arrOverlays.push(marker);
		}
	}
	var arrDelete=new Array();
	for(var n=0;n<zMapOverlaysIdsV3.length;n++){
		found=false;
		if(zMapOverlaysIdsGroupV3[n] === false){
			for(var i=0;i<arrSkip.length;i++){
				if(arrSkip[i]===zMapOverlaysIdsV3[n]){
					found=true;
					break;
				}
			}
			if(found===false){
				//	console.log("group clear n:"+n);
				zMapOverlaysV3[n].setMap(null);
			}
		}
	}
	zMapOverlaysIdsGroupV3=arrOverlaysGroupTemp;
	zMapOverlaysIdsV3=arrOverlaysTemp;
	zMapOverlaysV3=arrOverlays;
}
function zSetupCustomMarkerV3(marker){
	marker.zMarkerMapCounterV3=zMarkerMapCounterV3;
	marker.myRolloverCallbackObj=new Object();
	marker.myRolloverCallback=false;
	marker.myRolloverHTML=""; 
	if(typeof google === "undefined"){
		return;
	}
	google.maps.event.addListener(marker, "mouseover", function(o){zMapMarkerMouseOverV3(o,this); }); 
	google.maps.event.addListener(marker, "click", function(o){zMapMarkerMouseOverV3(o,this); }); 
	google.maps.event.addListener(marker, "mouseout", function(o){zMapMarkerRollOutV3Delay(); }); 
	
}
var zMapMarkerRollOutV3TimeoutId=0;
function zMapMarkerRollOutV3Delay(){
	clearTimeout(zMapMarkerRollOutV3TimeoutId);
	zMapMarkerRollOutV3TimeoutId=setTimeout(function(){zMapMarkerRollOutV3();}, 100);

}

function zMapLoadListingV3(obj){
	 zMapOverlayDivObjV3.style.width="300px";
	zMapOverlayDivObjV3.style.height="120px";
	//	document.getElementById("testdebug").value+="set to 100 height\n";
	 
//	 zMapOverlayDivObj.style.height="110px";
	var tempObj={};
	tempObj.id="zMapListing";
	tempObj.url="/z/listing/search-form/ajaxMapListing?listing_id="+obj.id;
	if(zDebugMLSAjax){
		tempObj.debug=true;
	}
	tempObj.cache=true;
	tempObj.callback=zMapShowListingV3;
	tempObj.ignoreOldRequests=true;
	zAjax(tempObj);	
}
function zMapShowListingV3(r){
	var myObj=eval('('+r+')');
	zMapCurrentListingLinkV3=myObj.link;
	zMapOverlayDivObjV3.innerHTML=myObj.html;
}
function createMarkerListingAjaxV3(point, id, iconcolor) {
	zMarkerMapCounterV3++;
	var marker = new google.maps.Marker({
		position: point,
		icon:"/z/a/listing/images/icon-home"+iconcolor+".jpg",
		map: mapObjV3,
		title: "zMapMarkerImage"+zMarkerMapCounterV3
	});
	marker.myForceEasyClick=true;
	zMarkerMapTypeTrack[zMarkerMapCounterV3]="marker";
	zSetupCustomMarkerV3(marker);
	var obj=new Object();
	obj.id=id;
	marker.myRolloverCallback=zMapLoadListingV3;
	marker.myRolloverCallbackObj=obj;
	// only for the home icon...
	google.maps.event.addListener(marker, "dblclick", function(o){
	  if(zMapCurrentListingLinkV3 !== null && zMapCurrentListingLinkV3 !== ""){
		 mapObjV3=null;
		window.top.location.href=zMapCurrentListingLinkV3;  
	  }
  });
	return marker; 
} 
function createMarkerGroupBgAjaxV3(point, obj, index, iconcolor) {
	if(obj.arrCountAtAddress[index]===1){
		point = new google.maps.LatLng(obj.listing_latitude[index],obj.listing_longitude[index]);
		
		zMarkerMapCounterV3++;
		var marker = new google.maps.Marker({
			position: point,
			icon:"/z/a/listing/images/icon-home"+iconcolor+".jpg",
			map: mapObjV3,
			title: "zSeeThroughMarkerId"+zMarkerMapCounterV3
		});
		zMarkerMapTypeTrack[zMarkerMapCounterV3]="seeThrough";
		marker.zMarkerMapCounterV3=zMarkerMapCounterV3;
		zSetupCustomMarkerV3(marker);
		
		marker.myForceEasyClick=true;
		marker.myRolloverHTML='<strong>'+obj.arrCount[index]+' listings at this address</strong><br />Average list price: '+obj.avgPrice[index]+'</span><br /><a href="##" onclick="zlsGotoMultiunitResults(\''+obj.listing_longitude[index]+","+obj.listing_longitude[index]+","+obj.listing_latitude[index]+","+obj.listing_latitude[index]+'\'); return false;">Click here to view all listings</a>';
		
		return marker;
	}else{
		var scale=obj.arrCount[index]/zHighestMapCountV3;
		var width= (32*scale)+24;
		var height= (25*scale)+20;
		//debugTextArea.value+="id:"+(index+1)+" | scale:"+scale+" | width:"+width+" | height:"+height+" | high:"+zHighestMapCountV3+"| count:"+obj.arrCount[index]+"\n";
		//width=42.40620155038759;
		//height=34.37984496124031;
		//var newAnchor=new google.maps.Point(Math.round(100-(58-(width/2))),Math.round(90-(45-(height/2))));//59, 62);
		var newAnchor=new google.maps.Point(Math.round(90-(58-(width/2))),Math.round(80-(45-(height/2))));//59, 62);
		var image2=new google.maps.MarkerImage('/z/a/listing/images/icon-multi'+iconcolor+'.png', new google.maps.Size(Math.round(width),Math.round(height)),new google.maps.Point(0, 0), newAnchor, new google.maps.Size(Math.round(width),Math.round(height)));
		/*if(index==2 || index === 1){
		//	console.log("index:"+index+" width:"+width+" height:"+height+" newAnchor:"+newAnchor+" point:"+point+" zMarkerMapCounterV3:"+zMarkerMapCounterV3);	
		//	console.log(image2);
		}*/
		zMarkerMapCounterV3++;
		//console.log(point);
		var marker = new google.maps.Marker({
			position: point,
			map: mapObjV3,
			icon: image2,
			title: "zSeeThroughMarkerId"+zMarkerMapCounterV3
		});
		//console.log(image2);
		zMarkerMapTypeTrack[zMarkerMapCounterV3]="seeThrough";
		zSetupCustomMarkerV3(marker);
		marker.myRolloverHTML='<strong>'+obj.arrCount[index]+' matching listings here</strong><br />Average list price: '+obj.avgPrice[index]+'</span><br />Double click to zoom in.';
		return marker;
		//alert(zHighestMapCountV3);
		/*
		var marker = new zMapMarkerV3(point,{"width":mapProps.longBlockWidth,"height":mapProps.latBlockWidth,"scale":scale,"iconcolor":iconcolor});
		marker.mySetRolloverHTML('<strong>'+obj.arrCount[index]+' matching listings here</strong><br />Average list price: '+obj.avgPrice[index]+'</span><br />Double click the red icon to zoom in.');
		*/
	}
	//arrMarkers.push(marker);
	//return marker;
}

function zMapMarkerMouseMoveV3(o){
	if(zCurrentMarkerMapCounterV3!==0 && typeof zMarkerMapTypeTrack[zCurrentMarkerMapCounterV3] !== "undefined"){
		if(zMarkerMapTypeTrack[zCurrentMarkerMapCounterV3]==="seeThrough"){
			var backupDiv=zMapOverlayDivObjV3;
			var tempPos={x:0,y:0};
			var tmpObj=false;
			if(window.parent !== null && window.parent.document.getElementById('zMapOverlayDivV3') !== null){
				zMapOverlayDivObjV3=window.parent.document.getElementById('zMapOverlayDivV3');
				tmpObj=zMapOverlayDivObjV3;
				tempPos=zGetAbsPosition(window.parent.document.getElementById('embeddedmapiframe'));
			}
			zMapOverlayDivObjV3.style.width="215px";
			zMapOverlayDivObjV3.style.height="65px";
	
			//alert(zGMapAbsPosV3.width+":"+px+":"+py+":"+zGMapAbsPosV3.x+"+"+tempPos.x+":"+zPositionObjSubtractPos[0]);
			//var projection=mapObjV3.getProjection();
			var pos=zCurMapPixelV3;//projection.fromLatLngToContainerPixel(obj.getPosition());
			if(tmpObj!== false){
				var pos={x:zMousePosition.x,y:zMousePosition.y};
				pos.x+=	tempPos.x;
				pos.y+=tempPos.y;
				zMapOverlayDivObjV3.style.top=(((zMousePosition.y+tempPos.y)-zPositionObjSubtractPos[1])+20)+"px";
				zMapOverlayDivObjV3.style.left=(((zMousePosition.x+tempPos.x)-zPositionObjSubtractPos[0])+20)+"px";
			}else{
				//debugTextArea.value='mousemove:'+zMousePosition.x+":"+zMousePosition.y+"\n";
				zMapOverlayDivObjV3.style.top=((zMousePosition.y-zPositionObjSubtractPos[1])+20)+"px";
				zMapOverlayDivObjV3.style.left=((zMousePosition.x-zPositionObjSubtractPos[0])+20)+"px";
			}
		
		}
	}
}


function goToStreetV3(lat,long2){
	streetView=true;
	zMapIgnoreMoveEnd=true;
	//mapObjV3.setZoom(mapProps.zoom);
	mapObjV3.setCenter(new google.maps.LatLng(lat, long2));
	zMapOverlayDivObjV3.style.left=(zGMapAbsPosV3.x+(zGMapAbsPosV3.width/2)+9)+"px";
	zMapOverlayDivObjV3.style.top=(zGMapAbsPosV3.y+(zGMapAbsPosV3.height/2)-9)+"px";
	//if(mapObj.getCurrentMapType() !== G_MAP_TYPE){
	if(mapObjV3.getMapTypeId() !== google.maps.MapTypeId.ROADMAP){
		mapObjV3.setZoom(21);
	}else{
		mapObjV3.setZoom(19);
	}
}

function zMapMarkerMouseOverV3(o,obj){
	//debugTextArea.value+='mouseover:'+obj.getTitle()+"\n";
	//return;
	var backupDiv=zMapOverlayDivObjV3;
	var tempPos={x:0,y:0};
	var tmpObj=false;
	if(window.parent !== null && window.parent.document.getElementById('zMapOverlayDivV3') !== null){
		zMapOverlayDivObjV3=window.parent.document.getElementById('zMapOverlayDivV3');
		tmpObj=zMapOverlayDivObjV3;
		tempPos=zGetAbsPosition(window.parent.document.getElementById('embeddedmapiframe'));
	}
	zMapOverlayDivObjV3.style.width="215px";
	zMapOverlayDivObjV3.style.height="65px";
	
	
	var p=30;
	/*if(zCurrentMarkerMapCounterV3!=0 && zCurrentMarkerMapCounterV3 !== obj.zMarkerMapCounterV3){
		//zMapMarkerRollOutV3(true);
	}*/
	
	var px=(zMousePosition.x-zGMapAbsPosV3.x);
	var py=zMousePosition.y-zGMapAbsPosV3.y;
	//alert(zGMapAbsPosV3.width+":"+px+":"+py+":"+zGMapAbsPosV3.x+"+"+tempPos.x+":"+zPositionObjSubtractPos[0]);
	//var projection=mapObjV3.getProjection();
	var pos=zCurMapPixelV3;//projection.fromLatLngToContainerPixel(obj.getPosition());
	if(tmpObj!== false){
		var pos={x:zMousePosition.x,y:zMousePosition.y};
		pos.x+=	tempPos.x;
		pos.y+=tempPos.y;
	}else{
		pos.x+=zGMapAbsPosV3.x;
		pos.y+=zGMapAbsPosV3.y;
	}
	
	pos.width=20;
	pos.height=17;
	//debugTextArea.value="divpoint:"+pos.x+":"+pos.y+" | subtractpos:"+zPositionObjSubtractPos[0]+":"+zPositionObjSubtractPos[1]+"\n";
	zMapOverlayDivObjAbsPos2V3=pos;
	zCurrentMarkerMapCounterV3=obj.zMarkerMapCounterV3;
	zMapOverlayDivObjV3.innerHTML=obj.myRolloverHTML;
	if(obj.myRolloverCallback!==false){
		obj.myRolloverCallback(obj.myRolloverCallbackObj);
	}
	
	if(zIsTouchscreen() && zTouchPosition.count){
		px=zTouchPosition.x[0];//-zGMapAbsPosV3.x;
		py=zTouchPosition.y[0];//-zGMapAbsPosV3.y;
		pos.x=zTouchPosition.x[0];
		pos.y=zTouchPosition.y[0];
		if(tmpObj!== false){
			pos.x+=tempPos.x;
			pos.y+=tempPos.y;
		}else{
			pos.x+=zGMapAbsPosV3.x;
			pos.y+=zGMapAbsPosV3.y;
		}
	}
	if(1===0){//obj.image_ === false){
		//alert('try fixmapmarkerdiv');
		return;
		//setTimeout("zFixMapMarkerDiv();",10);
		
	}else{
		
		//debugTextArea.value+="mappos:"+(zGMapAbsPosV3.width+":"+zGMapAbsPosV3.height+" | objpos:"+pos.x+":"+pos.y+"\n");
		if(px>zGMapAbsPosV3.width/2){
			if(typeof obj.myForceEasyClick !== "undefined"){
				zMapOverlayDivObjV3.style.left=(pos.x-zPositionObjSubtractPos[0])+"px";
			}else{
				zMapOverlayDivObjV3.style.left=((pos.x-zPositionObjSubtractPos[0])-(parseInt(zMapOverlayDivObjV3.style.width))+(10))+"px";//
			}
			//debugTextArea.value+="left1:"+((pos.x-zPositionObjSubtractPos[0])-(parseInt(zMapOverlayDivObjV3.style.width)+(9)))+":"+pos.x+":"+zPositionObjSubtractPos[0]+":"+parseInt(zMapOverlayDivObjV3.style.width)+"\n";
			if(py<zGMapAbsPosV3.height/2){ 
				zMapOverlayDivObjV3.style.top=((pos.y-zPositionObjSubtractPos[1])-25)+"px";
				//debugTextArea.value+="top1:"+(pos.y-zPositionObjSubtractPos[1])+":"+pos.y+":"+zPositionObjSubtractPos[1]+"\n";
			}else{
				//alert('t2');
				zMapOverlayDivObjV3.style.top=((pos.y+pos.height-zPositionObjSubtractPos[1])-(parseInt(zMapOverlayDivObjV3.style.height)+15))+"px";
				//debugTextArea.value+="top2:"+((pos.y+pos.height-zPositionObjSubtractPos[1])-(parseInt(zMapOverlayDivObjV3.style.height)+9))+":"+pos.y+":"+zMapOverlayDivObjV3.style.height+":"+parseInt(zMapOverlayDivObjV3.style.height)+"\n";
			}
		}else{
			//alert(pos.x+":"+(pos.x+pos.width));
			if(typeof obj.myForceEasyClick !== "undefined"){
				zMapOverlayDivObjV3.style.left=(pos.x-zPositionObjSubtractPos[0])+"px";
			}else{
				zMapOverlayDivObjV3.style.left=((pos.x+pos.width)-zPositionObjSubtractPos[0])+"px";//
			}
			//debugTextArea.value+="left2:"+(pos.x+pos.width-zPositionObjSubtractPos[0])+":"+pos.x+":"+pos.width+":"+zPositionObjSubtractPos[0]+"\n";
			if(py<zGMapAbsPosV3.height/2){
				zMapOverlayDivObjV3.style.top=((pos.y-zPositionObjSubtractPos[1])-25)+"px";
				//debugTextArea.value+="top3:"+(pos.y-zPositionObjSubtractPos[1])+":"+pos.y+":"+zPositionObjSubtractPos[1]+"\n";
			}else{
				zMapOverlayDivObjV3.style.top=((pos.y+pos.height-zPositionObjSubtractPos[1])-(parseInt(zMapOverlayDivObjV3.style.height)+15))+"px";
				//debugTextArea.value+="top4:"+((pos.y+pos.height-zPositionObjSubtractPos[1])-(parseInt(zMapOverlayDivObjV3.style.height)+9))+":"+pos.y+":"+zMapOverlayDivObjV3.style.height+":"+parseInt(zMapOverlayDivObjV3.style.height)+"\n";
			}
		} 
		zMapOverlayDivObjAbsPosV3={"x":parseInt(zMapOverlayDivObjV3.style.left)-tempPos.x,"y":parseInt(zMapOverlayDivObjV3.style.top)-tempPos.y,"width":parseInt(zMapOverlayDivObjV3.style.width),"height":parseInt(zMapOverlayDivObjV3.style.height)}; 
	}
			//alert(zMapOverlayDivObjV3.style.left+":"+zMapOverlayDivObjV3.style.top);
	
	/*
	var d2=document.getElementById("zSeeThroughMarkerId"+obj.zMarkerMapCounterV3);
	if(d2!=null){
		d2.style.opacity=0.5; d2.style.filter='alpha(opacity=50)';
	}*/
	
	zMapOverlayDivObjV3.style.display="block";
	/*if(tmpObj!== false){
		//tmpObj=zMapOverlayDivObjV3;	
	}*/
}
  
function zMapMarkerRollOutV3(force){
	//return;
	//alert('out'); 
	//debugTextArea.value="curMarker:"+zMousePosition.x+":"+zMousePosition.y+" | "+zMapOverlayDivObjAbsPosV3.x+":"+zMapOverlayDivObjAbsPosV3.y+":"+zMapOverlayDivObjAbsPosV3.width+":"+zMapOverlayDivObjAbsPosV3.height+"\n";
	var p=30; 
	if(zMapOverlayDivObjV3!==null && zCurrentMarkerMapCounterV3!==0){
		var image=false;
		if(typeof zMarkerMapTypeTrack[zCurrentMarkerMapCounterV3] !== "undefined"){
			if(zMarkerMapTypeTrack[zCurrentMarkerMapCounterV3]==="marker"){
				image=true;
			}
	  		if(!force && (zMousePosition.x-zPositionObjSubtractPos[0]>=zMapOverlayDivObjAbsPosV3.x-p && zMousePosition.x-zPositionObjSubtractPos[0]<=zMapOverlayDivObjAbsPosV3.x+zMapOverlayDivObjAbsPosV3.width+p && zMousePosition.y-zPositionObjSubtractPos[1]>=zMapOverlayDivObjAbsPosV3.y-p && zMousePosition.y-zPositionObjSubtractPos[1]<=zMapOverlayDivObjAbsPosV3.y+zMapOverlayDivObjAbsPosV3.height+p)){
				// in overlay tooltip
			}else if(!force && zMousePosition.x>=zMapOverlayDivObjAbsPos2V3.x-p && zMousePosition.x<=zMapOverlayDivObjAbsPos2V3.x+zMapOverlayDivObjAbsPos2V3.width+p && zMousePosition.y>=zMapOverlayDivObjAbsPos2V3.y-p && zMousePosition.y<=zMapOverlayDivObjAbsPos2V3.y+zMapOverlayDivObjAbsPos2V3.height+p){
				// in overlay
				//debugTextArea.value+="in overlay";
			}else if(!image){
				//debugTextArea.value+="out";
				//d2.style.opacity=0; d2.style.filter='alpha(opacity=0)';
				zCurrentMarkerMapCounterV3=0;
				zMapOverlayDivObjV3.innerHTML="";
				zMapOverlayDivObjV3.style.display="none"; 
			}else{
				zCurrentMarkerMapCounterV3=0;
				zMapOverlayDivObjV3.innerHTML="";
				zMapOverlayDivObjV3.style.display="none"; 
			}
		}
	}
}

function zAjaxMapRadiusChange(){
	var d3=document.getElementById("search_near_radius");
	if(d3.value !== ""){
		zAjaxSetNearAddress();
	}
}
	function zAjaxMapCoordinatesRadiusChange(){
		var d3=document.getElementById("search_near_radius");
		if(d3.value !== ""){
			zAjaxSetNearCoordinates();
		}
	}
function zAjaxFailNearAddress(){
	alert('There was a problem setting the address. Try again');
}
	function zAjaxFailNearCoordinates(){
		alert('There was a problem setting the coordinates. Try again');
	}
function zAjaxSetNearAddress(){
	var d1=document.getElementById("searchNearAddress");
	var d2=document.getElementById("search_near_radius");
	var d3="/z/listing/search-form/nearAddress?search_near_address="+escape(d1.value)+"&search_near_radius="+escape(d2.value);
	
	var tempObj={};
	tempObj.id="zMapNearAddress";
	tempObj.url=d3;
	tempObj.callback=zAjaxReturnNearAddress;
	tempObj.errorCallback=zAjaxFailNearAddress;
	tempObj.cache=false;
	tempObj.ignoreOldRequests=true;
	zAjax(tempObj);
}
	function zAjaxSetNearCoordinates(){
		var d1=document.getElementById("search_near_coordinates");
		var d2=document.getElementById("search_near_radius");
		var d3="/z/listing/search-form/nearCoordinates?search_near_coordinates="+escape(d1.value)+"&search_near_radius="+escape(d2.value);
		
		var tempObj={};
		tempObj.id="zMapNearCoordinates";
		tempObj.url=d3;
		tempObj.callback=zAjaxReturnNearCoordinates;
		tempObj.errorCallback=zAjaxFailNearCoordinates;
		tempObj.cache=false;
		tempObj.ignoreOldRequests=true;
		zAjax(tempObj);
	}
function zAjaxCancelNearAddress(){
	var d1=document.getElementById("searchNearAddress");
	var d2=document.getElementById("search_near_radius");
	var d3=document.getElementById("zNearAddressDiv");
	d3.style.display="none";
	d1.value='';
	d2.value='0.1';
}
	function zAjaxCancelNearCoordinates(){
		var d1=document.getElementById("search_near_coordinates");
		var d2=document.getElementById("search_near_radius");
		var d3=document.getElementById("zNearCoordinatesDiv");
		d3.style.display="none";
		d1.value='';
		d2.value='0.1';
	}
function zNearAddressChange(o){
	var d1=document.getElementById("zNearAddressDiv");
	var d3=document.getElementById("search_near_address");
	if(o.value === ""){
		d1.style.display="none";
		d3.value="";
	}else{
		d1.style.display="block";
	}
}
	function zNearCoordinatesChange(o){
		var d1=document.getElementById("zNearCoordinatesDiv");
		var d3=document.getElementById("search_near_coordinates");
		if(o.value === ""){
			d1.style.display="none";
			d3.value="";
		}else{
			d1.style.display="block";
		}
	}

var zArrPermanentMarker=new Array();
function zAjaxReturnNearAddress(r,skipParse){
	// throws an error when debugging is enabled.
	//r='{"success":true,"errorMsg":"","search_map_coordinates_list":"-81.1391101437,-81.1376618563,29.2753658556,29.2768141444"}';
	if(zDebugMLSAjax){
		document.write(r);	
		return;
	}
	var myObj=eval('('+r+')');
	if(!myObj.success){
		alert(myObj.errorMessage);
		return;
	}
	//alert("set:"+myObj.success);
	// set map coordinates
	var arrLatLong=myObj.search_map_coordinates_list.split(",");
	var minLat=parseFloat(arrLatLong[2]);
	var maxLat=parseFloat(arrLatLong[3]);
	var minLong=parseFloat(arrLatLong[0]);
	var maxLong=parseFloat(arrLatLong[1]);
	var avgLat=(minLat+maxLat)/2;
	var avgLong=(minLong+maxLong)/2;
	var zoom=0;
	var propHeight=Math.max(heightPerPixel*50,Math.abs(maxLat-minLat));
	var propWidth=Math.max(widthPerPixel*50,Math.abs(maxLong-minLong));
	var twp=widthPerPixel;
	var thp=heightPerPixel;
	margin=50;
	for(zoom=1;zoom<=20;zoom++){
		if(zoom !== 1){
			twp*=2;
			thp*=2;
		}
		maxWidth=mapProps.curStageWidth*twp;
		maxHeight=mapProps.curStageHeight*thp;
		// all properties must fit within zoom level
		if(maxWidth>propWidth+(twp*margin) && maxHeight>propHeight+(thp*margin)){
			break;
		}
	}
	// set zoom and center
	mapProps.avgLong=avgLong;
	mapProps.avgLat=avgLat;
	if(Math.abs(maxLat-minLat)===0){
		mapProps.zoom=20-zoom;
	}else{
		mapProps.zoom=18-zoom;
	}
	streetView=false;
	var d1=document.getElementById("searchNearAddress");
	var d2=document.getElementById("search_near_address");
	d2.value=d1.value;
	var d3=document.getElementById("zNearAddressDiv");
	d3.style.display="none";

	if(typeof mapObj === "undefined"){
		return;
	}
	// mapObjV3.closeInfoWindow();
	mapObjV3.setCenter(new google.maps.LatLng(mapProps.avgLat, mapProps.avgLong), mapProps.zoom);
	
	zSetNearAddress(1);
	var pm=new Object();
	pm.point=new google.maps.LatLng(mapProps.avgLat, mapProps.avgLong);
	pm.title="zNearAddressMarker";
	arrAd=d2.value.split(",");
	var ad1=arrAd.shift()+"<br>"+arrAd.join(",");
	pm.htmlText='<table width="150"><tr><td>Location:<br>'+ad1+'</td></tr></table>';
	var marker=zAddPermanentMarkerV3(pm);
	google.maps.event.trigger(marker,"click");
}
	function zAjaxReturnNearCoordinates(r,skipParse){
		// throws an error when debugging is enabled.
		//r='{"success":true,"errorMsg":"","search_map_coordinates_list":"-81.1391101437,-81.1376618563,29.2753658556,29.2768141444"}';
		if(zDebugMLSAjax){
			document.write(r);	
			return;
		}
		var myObj=eval('('+r+')');
		if(!myObj.success){
			alert(myObj.errorMessage);
			return;
		}
		//alert("set:"+myObj.success);
		// set map coordinates
		var arrLatLong=myObj.search_map_coordinates_list.split(",");
		var minLat=parseFloat(arrLatLong[2]);
		var maxLat=parseFloat(arrLatLong[3]);
		var minLong=parseFloat(arrLatLong[0]);
		var maxLong=parseFloat(arrLatLong[1]);
		var avgLat=(minLat+maxLat)/2;
		var avgLong=(minLong+maxLong)/2;
		var zoom=0;
		var propHeight=Math.max(heightPerPixel*50,Math.abs(maxLat-minLat));
		var propWidth=Math.max(widthPerPixel*50,Math.abs(maxLong-minLong));
		var twp=widthPerPixel;
		var thp=heightPerPixel;
		margin=50;
		for(zoom=1;zoom<=20;zoom++){
			if(zoom !== 1){
				twp*=2;
				thp*=2;
			}
			maxWidth=mapProps.curStageWidth*twp;
			maxHeight=mapProps.curStageHeight*thp;
			// all properties must fit within zoom level
			if(maxWidth>propWidth+(twp*margin) && maxHeight>propHeight+(thp*margin)){
				break;
			}
		}
		// set zoom and center
		mapProps.avgLong=avgLong;
		mapProps.avgLat=avgLat;
		if(Math.abs(maxLat-minLat)===0){
			mapProps.zoom=20-zoom;
		}else{
			mapProps.zoom=18-zoom;
		}
		streetView=false;
		var d1=document.getElementById("searchNearLocation");
		var d2=document.getElementById("search_near_coordinates");
		// d2.value=d1.value;
		var d3=document.getElementById("zNearCoordinatesDiv");
		d3.style.display="none";

		if(typeof mapObj === "undefined"){
			return;
		}
		// mapObjV3.closeInfoWindow();
		mapObjV3.setCenter(new google.maps.LatLng(mapProps.avgLat, mapProps.avgLong), mapProps.zoom);
		
		zSetNearAddress(1);
		var pm=new Object();
		pm.point=new google.maps.LatLng(mapProps.avgLat, mapProps.avgLong);
		pm.title="zNearCoordinatesMarker";
		arrAd=d1.value.split(",");
		var ad1=arrAd.shift()+"<br>"+arrAd.join(",");
		pm.htmlText='<table width="150"><tr><td>Location:<br>'+ad1+'</td></tr></table>';
		var marker=zAddPermanentMarkerV3(pm);
		google.maps.event.trigger(marker,"click");
	}
