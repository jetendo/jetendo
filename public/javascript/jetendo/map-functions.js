
var zArrGeolocationCallback=[];
var zArrGeolocationWatchCallback=[];  

(function($, window, document, undefined){
	"use strict";

	function zCreateMap(mapDivId, optionsObj) {
		
		var mapOptions = { 
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		for(var i in optionsObj){
			mapOptions[i]=optionsObj[i];
		}
		var eventObj={};
		if(typeof mapOptions.bindEvents !== "undefined"){
			eventObj=mapOptions.bindEvents;
			delete mapOptions.bindEvents;
		}
		document.getElementById(mapDivId).style.display="block";
		var map = new google.maps.Map(document.getElementById(mapDivId), mapOptions);
		for(var i in eventObj){
			google.maps.event.addListener(map, i, eventObj[i]);
		}
		return map;
	}
	var globalInfoWindow=null;
	function zCreateMapMarker(markerObj){
		if(typeof markerObj === 'undefined'){
			markerObj={};
		}
		var eventObj={};
		var infoWindowHTML="";
		if(typeof markerObj.infoWindowHTML !== "undefined"){
			infoWindowHTML=markerObj.infoWindowHTML;
			delete markerObj.infoWindowHTML;
		}
		if(typeof markerObj.bindEvents !== "undefined"){
			eventObj=markerObj.bindEvents;
			delete markerObj.bindEvents;
		}
		var marker = new google.maps.Marker(markerObj);
		for(var i in eventObj){
			google.maps.event.addListener(marker	, i, eventObj[i]);
		} 
		if(!globalInfoWindow){
			globalInfoWindow = new google.maps.InfoWindow({
				content: ""
			});
		}
		if(infoWindowHTML !== ""){
			marker.infoWindowHTML=infoWindowHTML; 
			google.maps.event.addListener(marker	, 'click', function(){ 
				globalInfoWindow.close();
				globalInfoWindow.setPosition(marker.getPosition());
				globalInfoWindow.setContent(marker.infoWindowHTML);
				globalInfoWindow.open(marker.getMap(), marker);
			});
		}
		return marker;
	}

	function zMapFitMarkers(mapObj, arrMarker){ 
		if(arrMarker.length === 0){
			return;
		}else if(arrMarker.length === 1){
			if(arrMarker[0].getPosition().lat() !== 0){
				mapObj.setCenter(arrMarker[0].getPosition());
				// Use the zoom level from 'mapObj' if provided.
				if ( typeof( mapObj.zoom ) !== 'undefined' ) {
					mapObj.setZoom( mapObj.zoom );
				} else {
					mapObj.setZoom( 10 );
				}
			}
			return;
		}
		var bounds = new google.maps.LatLngBounds ();
		var extended=false;
		for (var i = 0, LtLgLen = arrMarker.length; i < LtLgLen; i++) {
			if(typeof arrMarker[i].getPosition() !== "undefined" && arrMarker[i].getPosition().lat() !== 0){
				bounds.extend(arrMarker[i].getPosition());
				extended=true;
			}
		} 
		if(extended){
			mapObj.fitBounds(bounds);
		} 
	} 
	function zAddMapMarkerByLatLng(mapObj, markerObj, latitude, longitude, successCallback){ 
		var marker=zCreateMapMarker(markerObj); 
		var location=new google.maps.LatLng( latitude, longitude);
		marker.setPosition(location);
		marker.setMap(mapObj);
		if(typeof successCallback !== "undefined"){
			setTimeout(function(){ successCallback(marker, location); }, 10);
		}
		return marker;
	}
	function zGetLatLongByAddress(address, successCallback, delayMilliseconds){ 
		var geocoder = new google.maps.Geocoder(); 
		if(typeof delayMilliseconds === 'undefined'){
			delayMilliseconds=0;
		}

		setTimeout(function(){
			geocoder.geocode( { 'address': address}, function(results, status) {
				if (status === google.maps.GeocoderStatus.OK) { 
					successCallback(results[0].geometry.location);
				} else {
					console.log('Geocode was not successful for address, "'+address+'", for the following reason: ' + status);
				}
			});
		}, delayMilliseconds);
	}
	function zAddMapMarkerByAddress(mapObj, markerObj, address, successCallback, delayMilliseconds){ 
		var marker=zCreateMapMarker(markerObj);
		var geocoder = new google.maps.Geocoder(); 
		if(typeof delayMilliseconds === 'undefined'){
			delayMilliseconds=0;
		}
		setTimeout(function(){
			geocoder.geocode( { 'address': address}, function(results, status) {
				if (status === google.maps.GeocoderStatus.OK) { 
					marker.setPosition(results[0].geometry.location);
					marker.setMap(mapObj);
					if(typeof successCallback !== "undefined"){
						successCallback(marker, results[0].geometry.location);
					}
				} else {
					console.log('Geocode was not successful for address, "'+address+'", for the following reason: ' + status);
				}
			});
		}, delayMilliseconds);
		return marker;
	}
	function zCreateMapWithAddress(mapDivId, address, optionsObj, successCallback, markerObj) {
		var marker=zCreateMapMarker(markerObj); 
		var geocoder = new google.maps.Geocoder(); 
		if(address.length === ""){ 
			if(typeof optionsObj.defaultAddress !== "undefined"){
				address=optionsObj.defaultAddress;
			}else{
				return;
			}
		}
		var mapOptions = {
			zoom: 8,
	   		center: new google.maps.LatLng(0, 0),
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		for(var i in optionsObj){
			mapOptions[i]=optionsObj[i];
		} 
		var map=zCreateMap(mapDivId, mapOptions); 
		geocoder.geocode( { 'address': address}, function(results, status) {
			if (status === google.maps.GeocoderStatus.OK) {
				setTimeout(function(){
					google.maps.event.trigger(map, 'resize');
					map.setCenter(results[0].geometry.location); 
				}, 1);
				marker.setPosition(results[0].geometry.location);
				marker.setMap(map);
				if(typeof mapOptions.triggerEvents !== "undefined"){
					for(var i in mapOptions.triggerEvents){
						google.maps.event.trigger(map, i);
					}
				} 
				successCallback(marker); 
			} else {
				console.log('Geocode was not successful for the following reason: ' + status);
				$("#"+mapDivId).html("The location was not able to be mapped.");
			}
		});
		return { map: map, marker: marker};
	}
	
	function zCreateMapWithLatLng(mapDivId, latitude, longitude, optionsObj, successCallback, markerObj) {  
		var mapOptions = {
			zoom: 8,
	   		center: new google.maps.LatLng(latitude, longitude),
			mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		for(var i in optionsObj){
			mapOptions[i]=optionsObj[i];
		} 
		var map=zCreateMap(mapDivId, mapOptions); 
		if(typeof markerObj === "undefined"){
			markerObj={};
		}
		markerObj.position=mapOptions.center;
		markerObj.map=map;
		var marker=zCreateMapMarker(markerObj);  
		if(typeof mapOptions.triggerEvents !== "undefined"){
			for(var i in mapOptions.triggerEvents){
				google.maps.event.trigger(map, i);
			}
		} 
		successCallback(marker); 
		return { map: map, marker: marker};
	}




	var stopCacheGeocoding=false;
	var zGeocode={
		arrAddress:[],
		arrKey:[]
	};
	var firstRun=true;
	var geocodeOffset=0;
	var geocoderAvailable=false; 
	var geocoder = false;
	function zIsGeocoderAvailable(){ 
		if(typeof google!=="undefined" && typeof google.maps!=="undefined" && typeof google.maps.Geocoder!=="undefined"){
			if(typeof geocoder == "boolean"){
				geocoder = new google.maps.Geocoder();   
			}
			geocoderAvailable=true;
		}

		if(!geocoderAvailable){
			return false;
		}
		if(firstRun){
			var active=zGetCookie("zGeocodeActive");
			if(active == "1"){
				// another browser window is already running the geocoder for this ip - lets avoid hitting limits and cancel this request.
				stopCacheGeocoding=true;
				return false;
			}
			firstRun=false;
			zSetCookie({key:"zGeocodeActive",value:"1",futureSeconds:40,enableSubdomains:false});  
		}
		var count=zGetCookie("zGeocodeCount");
		if(count==""){
			count=0;
		}else{
			count=parseInt(count);
		}
		// limit to 300 geocodes per client per day
		if(count > 300){
			return false;
		}
		count++;
		zSetCookie({key:"zGeocodeCount",value:count,futureSeconds:60 * 60 * 24,enableSubdomains:false});  
		return true;
	}
	function zGeocodeCacheAddress() {
		if(!zIsGeocoderAvailable()){
			if(zIsDeveloper()){
				console.log('Geocoder available');
			}
			return;
		} 
		if(zGeocode.arrAddress.length <= geocodeOffset){
			if(zIsDeveloper()){
				console.log('Nothing available to geocode');
			}
			return; 
		}
 
		if(zIsDeveloper()){
			console.log('geocoding address: '+zGeocode.arrAddress[geocodeOffset]);
		}
		geocoder.geocode( { 'address': zGeocode.arrAddress[geocodeOffset]}, function(results, status) {
			var r="";
			var data={
				latitude:"",
				longitude:"",
				accuracy:"",
				status:""
			};
			if(zIsDeveloper()){
				console.log(results);
			}
			var match=false;
			if (status == google.maps.GeocoderStatus.OK) {
				var a1=new Array();
				for(var i=0;i<results.length;i++){
					types=arrayToList(results[i].types, ",");
					ts.struct.geocode_cache_accuracy="";
					if(types=="street_address" || types == "premise" || types == "subpremise"){
						ts.struct.geocode_cache_accuracy="ROOFTOP";
						data.status="OK";
						data.latitude=results[i].geometry.location.lat();
						data.longitude=results[i].geometry.location.lng();
						data.accuracy=results[i].geometry.location_type; 
						match=true;
						break;	
					}else if(data.accuracy==''){

						data.status="OK";
						data.latitude="";
						data.longitude="";
						data.accuracy=results[i].geometry.location_type; 
					}
				}
				//if(debugajaxgeocoder) f1.value+="Result:"+r+"\n";
			} else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT || status == google.maps.GeocoderStatus.REQUEST_DENIED){
				// serious error condition
				stopCacheGeocoding=true; 
			}
			var curStatus="";
			if(status == google.maps.GeocoderStatus.OK){
				curStatus="OK";
			}else if(status == google.maps.GeocoderStatus.OVER_QUERY_LIMIT){
				curStatus="OVER_QUERY_LIMIT";
				stopGeocoding=true;
				return;
			}else if(status == google.maps.GeocoderStatus.REQUEST_DENIED){
				curStatus="REQUEST_DENIED";
			}else if(status == google.maps.GeocoderStatus.ZERO_RESULTS){
				curStatus="ZERO_RESULTS";
			}else if(status == google.maps.GeocoderStatus.INVALID_REQUEST){
				curStatus="INVALID_REQUEST";
			}else if(status == 'ERROR'){
				stopCacheGeocoding=true;
				// This is an undocumented problem with google's API. We must stop geocoding and wait for a new user with a fresh copy of google's API downloaded that hopefully works.
				return;
			}else{
				curStatus=status;
			}
			data.status=curStatus;
			if(zIsDeveloper()){
				console.log('before saveGeocode status: '+curStatus);
			}
			//if(debugajaxgeocoder) f1.value+='geocode done for address='+zGeocode.arrAddress[geocodeOffset]+" with status="+curStatus+"\n";
			var debugurlstring="";
			/*if(debugajaxgeocoder){
				debugurlstring="&debugajaxgeocoder=1";
			}*/
			data.address=zGeocode.arrAddress[geocodeOffset];
			data.key=zGeocode.arrKey[geocodeOffset]; 
			var ts={};
			ts.id="zSaveGeocode";
			ts.postObj=data;
			ts.cache=false;
			ts.method="post";
			ts.url="/z/misc/geocode/saveGeocode";
			ts.callback=function(r){
				var r=JSON.parse(r);
				if(r.success){
					if(zIsDeveloper()){
						console.log('saveGeocode '+geocodeOffset+' status: true');
					}
				}else{
					console.log('saveGeocode error:'+r.errorMessage);
				}
			}
			zAjax(ts);  
			geocodeOffset++;
			if(geocodeOffset<zGeocode.arrAddress.length && !stopCacheGeocoding){
				setTimeout(function(){ 
					zTimeoutGeocodeCache();
				},1500);
			}
		});
	}


	/*
	var options={
		exact:false, // true will exclude results that are ESTIMATES or the general area.
		address:"125 Basin St, Suite 203, Daytona Beach, FL 32114",
		callback:function(r){
			if(r.success){
				// do something with result
				var mapLocation=r.latitude+","+r.longitude;
				alert(mapLocation);
			}else{
				alert("Unable to map location, please try a different input.");
			}
		},
		customKeyURL:"",  // If the client is using proxy, you may need to change the urls to a different path
		customGeocodeURL:""
	};
	zGeocodeAddress(options);
	*/
	var lastGeocodeAddress="";
	var lastGeocodeResult=false;
	function zGeocodeAddress(options) {
		if(typeof options.customKeyURL == "undefined" || options.customKeyURL == ""){
			options.customKeyURL="/z/misc/geocode/geocodeAjaxKey";
		}
		if(typeof options.customGeocodeURL == "undefined" || options.customGeocodeURL == ""){
			options.customGeocodeURL="/z/misc/geocode/geocodeAjax";
		}
		if(typeof options.exact == "undefined"){
			options.exact=false;
		}
		if(options.address == lastGeocodeAddress){
			options.callback(lastGeocodeResult);
			return;
		}
		lastGeocodeAddress=options.address;
		if(options.address==""){
			console.log("Address is required.");
			return;
		}
		var v=Math.random();
		var tempObj={};
		tempObj.ignoreOldRequests=true;
		tempObj.id="zGeocodeAjaxKey";
		tempObj.url=options.customKeyURL+"?v="+v;
		tempObj.callback=function(r){
			var r=JSON.parse(r);
			if(r.success){
				var tempObj2={};
				tempObj2.ignoreOldRequests=true;
				tempObj2.id="zGeocodeAjaxKey";
				tempObj2.url=options.customGeocodeURL+"?v="+v+"&address="+escape(options.address)+"&key="+r.value;
				tempObj2.callback=function(r2){
					var r2=JSON.parse(r2);
					if(r.value==r2.key){
						lastGeocodeResult=r2;
						if(options.exact && !r2.exact){
							r2={success:false, exact:false, latitude:"", longitude:""};
						}
						options.callback(r2);
					}
				};
				tempObj2.cache=false;
				zAjax(tempObj2);
			}else{
				lastGeocodeResult=r;
				options.callback(r);
			}
		};
		tempObj.cache=false;
		zAjax(tempObj);
	}


	// zGetDirectionsDistance(sourceLat, sourceLong, destinationLat, destinationLong, directionsCallbackFunction);
	function zGetDirectionsDistanceByLatLng(sourceLat, sourceLong, destinationLat, destinationLong, directionsCallbackFunction){
		var source=new google.maps.LatLng(sourceLat, sourceLong);
		var destination=new google.maps.LatLng(destinationLat, destinationLong);
		zGetDirectionsDistanceByAddress(source, destination, directionsCallbackFunction)
	}

	// zGetDirectionsDistance(source, destination, directionsCallbackFunction);
	function zGetDirectionsDistanceByAddress(source, destination, directionsCallbackFunction){

		var directionsService = new google.maps.DirectionsService();
		var request = {
			origin:source,
			destination:destination,
			travelMode: google.maps.DirectionsTravelMode.DRIVING
		};

		directionsService.route(request, function(response, status){
			if (status == google.maps.DirectionsStatus.OK){
				if(zIsTestServer() || zIsDeveloper()) console.log(response); 
				/*
				distance = "The distance between the two points on the chosen route is: "+response.routes[0].legs[0].distance.text;
				distance += "The aproximative driving time is: "+response.routes[0].legs[0].duration.text;
				console.log(distance);
				*/  
				var rs={
					success:true,
					response:response,
					distanceInMeters: response.routes[0].legs[0].distance.value, 
					distanceInKilometers: response.routes[0].legs[0].distance.value/1000, 
					distanceInMiles: response.routes[0].legs[0].distance.value*0.000621371, // convert meters to miles
					distanceAsString: response.routes[0].legs[0].distance.text, 
					drivingTime: response.routes[0].legs[0].duration.text
				};
			}else{
				var rs={
					success:false,
					response:response,
					errorMessage:'Unable to calculate driving distance'
				};
			}
			directionsCallbackFunction(rs); 
		});
	}
	// zDisplayDirectionsDistance(googleMapObj, directionsResponse);
	function zDisplayDirectionsDistance(googleMapObj, directionsResponse){

		var directionsDisplay = new google.maps.DirectionsRenderer({
			suppressMarkers: true,
			suppressInfoWindows: true
		});
		directionsDisplay.setMap(googleMapObj);
		directionsDisplay.setDirections(directionsResponse);
	}

	var arrRegisterAutoCompleteCallback=[];
	function zGoogleAddressAutoCompleteRegisterCallback(f){
		arrRegisterAutoCompleteCallback.push(f);
	}

	zArrMapFunctions.push(function(){ 
		if($(".zGoogleAddressAutoComplete").length){

		}
	    $(".zGoogleAddressAutoComplete").each(function(){
			var placeSearch, autocomplete;

			// Bias the autocomplete object to the user's geographical location,
			// as supplied by the browser's 'navigator.geolocation' object.
			var disableGeolocate=$(this).attr("data-disable-geolocate");
			if(disableGeolocate == null || disableGeolocate == "0"){
				disableGeolocate=false;
			}else{
				disableGeolocate=true;
			}
			function geolocate() {
				// only works on https in a browser that supports geolocation
				if (window.location.href.indexOf("https:") != -1 && navigator.geolocation) {
					navigator.geolocation.getCurrentPosition(function(position) {
						var geolocation = {
							lat: position.coords.latitude,
							lng: position.coords.longitude
						};
						var circle = new google.maps.Circle({
							center: geolocation,
							radius: position.coords.accuracy
						});
						autocomplete.setBounds(circle.getBounds());
					});
				}else{
					// do nothing
				}
			}


			var componentForm = {
				coordinates: $(this).attr("data-address-coordinates"),
				street_number: $(this).attr("data-address-number"),
				route: $(this).attr("data-address-street"),
				locality: $(this).attr("data-address-city"),
				administrative_area_level_1: $(this).attr("data-address-state"),
				country: $(this).attr("data-address-country"),
				postal_code: $(this).attr("data-address-zip")
			}; 
	 		var backupAutocompleteInputValue="";
		    $(this).bind("focus", function(){
		    	backupAutocompleteInputValue=this.value;
				$(this).select();
				if(!disableGeolocate){
			    	geolocate();
			    }
		    });
			function clearAddressFields() {  
				for (var component in componentForm) {
					if (typeof componentForm[component] != "undefined") {
						document.getElementById(componentForm[component]).value = '';
						document.getElementById(componentForm[component]).disabled = false;
					}
				}
			}
			function fillInAddressFields(place, fieldName) { 
				if(typeof place.geometry == "undefined"){
					return false;
				}
				clearAddressFields();

				if (typeof componentForm["coordinates"] != "undefined"){
					document.getElementById(componentForm["coordinates"]).value=place.geometry.location.lat()+","+place.geometry.location.lng();
				}


				// Get each component of the address from the place details
				// and fill the corresponding field on the form.
				for (var i = 0; i < place.address_components.length; i++) {
					var addressType = place.address_components[i].types[0];
					if (typeof componentForm[addressType] != "undefined" && componentForm[addressType]) { 
						var val = place.address_components[i].short_name;
						document.getElementById(componentForm[addressType]).value = val;  
					}
				}
				if(zIsTestServer() || zIsDeveloper()) console.log('fillInAddressFields');
				if(zIsTestServer() || zIsDeveloper()) console.log(place);
				var a=buildAddress(place, fieldName); 
				// ensure the callback is after dom changes are done.  I think it is the place_changed event we are waiting for.
			 
				for(var i=0;i<arrRegisterAutoCompleteCallback.length;i++){
					arrRegisterAutoCompleteCallback[i](a);
				} 
				return true;
			}

			function buildAddress(place, fieldName) { 
				var a = {
					coordinates: "",
					street_number: "", 
					street: "", // route
					city: "", // locality
					state: "", // administrative_area_level_1
					country: "",
					postal_code: "",
					address:"",
					fieldName:fieldName
				};
				a.coordinates=place.geometry.location.lat()+","+place.geometry.location.lng();

				for (var i = 0; i < place.address_components.length; i++) {
					var addressType = place.address_components[i].types[0];
					var val = place.address_components[i].long_name;
					if(addressType == "street_number"){
						a.street_number=val;
					}else if(addressType == "route"){
						a.street=val;
					}else if(addressType == "locality"){
						a.city=val;
					}else if(addressType == "administrative_area_level_1"){
						a.state=val;
					}else if(addressType == "country"){
						a.country=val;
					}else if(addressType == "postal_code"){
						a.postal_code=val; 
					}
					// administrative_area_level_2 is county
				}
				var arrAddress=[];
				a.address=place.formatted_address;
				/*
				if(a.street_number != ""){
					arrAddress.push(a.street_number+" ");
				}
				if(a.street != ""){
					arrAddress.push(a.street+", ");
				}
				if(a.city != ""){
					arrAddress.push(a.city+", ");
				}
				if(a.state != ""){
					arrAddress.push(a.state+" ");
				}
				if(a.postal_code != ""){
					arrAddress.push(a.postal_code+" ");
				}
				if(a.country != ""){
					arrAddress.push(a.country);
				}
				console.log(arrAddress);
				//a.address=arrAddress.join("");
				*/
				return a;
			}

			

 
 			var userSelectedGooglePlace=false;
			function fillInAddress() { 
				// Get the place details from the autocomplete object.
				if(zIsTestServer() || zIsDeveloper()) console.log('fillInAddress called: place_changed event');
				userSelectedGooglePlace=true;
				setTimeout(function(){
					userSelectedGooglePlace=false;
				}, 2000);
				var place = autocomplete.getPlace(); 
				fillInAddressFields(place, this.__fieldElement.name);
			}
			// Create the autocomplete object, restricting the search to geographical
			// location types.

			var options={
				types: ['geocode'] // geocode, (regions) or (cities)
			}; 

			var restrict=false;
			var ts={};
			/*
			// restrictions don't work with type=geocode, only larger areas.  Restriction may still be useful someday if we need use to type only city/zip/state instead.  i.e. (regions) or (cities)
			// up to 5 countries
			*/
			// data-autocomplete-type="(cities)" data-country-limit="us,mx" data-state-limit="fl,ga" data-city-limit="Ormond Beach,Daytona Beach" data-zip-limit="32174,32176,32114"
			
			var type=$(this).attr("data-autocomplete-type");
			if(type != null && type !=""){
				if(type == 'regions'){
					type='(regions)';
				}
				if(type == 'cities'){
					type='(cities)';
				}
				if(type == 'postal_code'){
					type='(postal_code)';
				}
				if(type != '(cities)' && type != '(postal_code)' && type != '(regions)' && type != 'geocode'){
					throw("Invalid autocomplete type.  Please specify geocode, (cities), (regions) in data-autocomplete-type"); 
				}
				options.types=[type];
				if(type == "(regions)" || type == "(cities)"){
					var countryLimit=$(this).attr("data-country-limit");
					var stateLimit=$(this).attr("data-state-limit");
					var cityLimit=$(this).attr("data-city-limit");
					var postalCodeLimit=$(this).attr("data-zip-limit");
					if(countryLimit != null && countryLimit != ""){
						restrict=true;
						ts.country=countryLimit.toLowerCase().split(",");
					}
					if(stateLimit != null && stateLimit != ""){
						restrict=true;
		    			ts.administrativeArea=stateLimit.toLowerCase().split(",");
					}
					if(cityLimit != null && cityLimit != ""){
						restrict=true;
		    			ts.locality=cityLimit.toLowerCase().split(","); 
					}
					if(postalCodeLimit != null && postalCodeLimit != ""){
						restrict=true;	
		    			ts.postalCode=postalCodeLimit.toLowerCase().split(","); 
					}
					if(restrict){
						options.componentRestrictions=ts;
					}
				}
			}

			autocomplete = new google.maps.places.Autocomplete(this, options); 
			autocomplete.__fieldElement=this;  
 
			$(this).bind("blur", function(){ 
				var currentValue=$.trim(this.value);
				var self2=this;
				// must wait to verify if user selected a google autocomplete place
				setTimeout(function(){
					// need to be able to register to autocomplete callback functions.
					if(userSelectedGooglePlace){
						if(zIsTestServer() || zIsDeveloper()) console.log('blur autocomplete geocode: google place picked');
						userSelectedGooglePlace=false;
					}else{
						if(zIsTestServer() || zIsDeveloper()) console.log('blur autocomplete geocode: geocode will execute');
						// if the value changed, clear the address fields until callback completes
						if(backupAutocompleteInputValue != currentValue){
							clearAddressFields();
						} 
						// only run geocode if user didn't select a google address
						var v=document.getElementById(componentForm["coordinates"]).value;  
						if(v=='' && currentValue!=""){
 
							// geocode and set form
							var geocoder = new google.maps.Geocoder();  
							geocoder.geocode( {  
								'address': currentValue
							}, function(results, status) {
								if (status === google.maps.GeocoderStatus.OK) { 
									var place=results[0]; 
									clearAddressFields();  
									if(zIsTestServer() || zIsDeveloper()) console.log('Geocoded address:'+currentValue); 
									if(type != '(postal_code)'){
										self2.value=place.formatted_address;
									}

									fillInAddressFields(place, autocomplete.__fieldElement.name); 
								} else {
									alert("Google can't map this address, please correct or remove the address and try again. (Status: "+status+")");
								}
							});   
						}
					}
				}, 500);
			});
			// When the user selects an address from the dropdown, populate the address
			// fields in the form.
			autocomplete.addListener('place_changed', fillInAddress);

		});
	});

	function zTimeoutGeocodeCache(){
		if(stopCacheGeocoding) return;
		zGeocodeCacheAddress();
	}



	// lat/long distance functions 
	function zGetDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) {
		var R = 6371; // Radius of the earth in km
		var dLat = zDeg2Rad(lat2-lat1);  // deg2rad below
		var dLon = zDeg2Rad(lon2-lon1); 
		var a = 
		Math.sin(dLat/2) * Math.sin(dLat/2) +
		Math.cos(zDeg2Rad(lat1)) * Math.cos(zDeg2Rad(lat2)) * 
		Math.sin(dLon/2) * Math.sin(dLon/2)
		; 
		var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
		var d = R * c; // Distance in km
		return d;
	}
	function zGetDistanceFromLatLonInMiles(lat1,lon1,lat2,lon2) {
		var km=zGetDistanceFromLatLonInKm(lat1,lon1,lat2,lon2);
		return zKmToMiles(km);
	}
	function zKmToMiles(km){
		return km*1.609;
	}
	function zMilesToKm(miles){
		return miles*0.621;
	} 
	function zDeg2Rad(deg) {
		return deg * (Math.PI/180);
	}
	function zSortLocationsByDistance(latitude, longitude, arrLocation){ 
		var arrDistance=[];
		if(arrLocation.length==0){
			return [];
		}
		for(var i=0;i<arrLocation.length;i++){
			var latitude2=parseFloat(arrLocation[i].latitude);
			var longitude2=parseFloat(arrLocation[i].longitude); 
			var distanceInMiles=zGetDistanceFromLatLonInMiles(latitude,longitude,latitude2,longitude2); 
			arrDistance.push({distanceInMiles: distanceInMiles, location:arrLocation[i] });
		}
		arrDistance.sort(function(a, b){
		    if(a.distanceInMiles < b.distanceInMiles) return -1;
		    if(a.distanceInMiles > b.distanceInMiles) return 1;
		    return 0;
		});
		return arrDistance;
	}

	// geolocation functions
	zArrDeferredFunctions.push(function (){
		var userLocation=zGetCookie("ZSTOREDUSERLOCATION");
		if(userLocation!=""){
			var arrLocation=userLocation.split(",");
			if(arrLocation.length==3){
				zSetCurrentUserLocation(arrLocation[0], arrLocation[1], arrLocation[2]);
			}else if(arrLocation.length==2){
				zSetCurrentUserLocation(arrLocation[0], arrLocation[1]);
			}
		}
		setTimeout(function(){
			if(zArrGeolocationCallback.length || zArrGeolocationWatchCallback.length){
				zExecuteGeoLocationLookup();
			}
		}, 10);
	});
	function zGetGeoLocationWithCallback(callback, errorCallback){
		if(typeof navigator.geolocation=="undefined"){
			if(typeof errorCallback != "undefined"){
				errorCallback();
			}
		}
		navigator.geolocation.getCurrentPosition(function(location) {  
			zSetCurrentUserLocation(location.coords.latitude, location.coords.longitude, 'device'); 
	 		callback();
		},
		function (error) {  
			if(typeof errorCallback != "undefined"){
				errorCallback({success:false, error:error});
			}
		}, { enableHighAccuracy :true}); 
	}  

	function zSetCurrentUserLocation(latitude, longitude, type){
		window.zStoredUserLocation={
			latitude:latitude,
			longitude:longitude,
			type:type
		};
		var location=latitude+","+longitude+","+type;
		zSetCookie({key:"ZSTOREDUSERLOCATION", value:location, futureSeconds:60*60*24*365,enableSubdomains:false});  
	}
	function zGetCurrentUserLocation(){
		if(typeof window.zStoredUserLocation == "undefined"){
			return {success:false};
		}else{ 
			return {success:true, latitude:window.zStoredUserLocation.latitude, longitude:window.zStoredUserLocation.longitude, type:window.zStoredUserLocation.type};
		}
	}

	function zExecuteGeoLocationLookup(){
		if(typeof navigator.geolocation=="undefined"){
			return;
		}
		var userLocation=zGetCurrentUserLocation();
		if(userLocation.success && userLocation.type == 'device'){
	 		for(var i=0;i<zArrGeolocationWatchCallback.length;i++){
	 			zArrGeolocationWatchCallback[i]();
	 		}
	 		for(var i=0;i<zArrGeolocationCallback.length;i++){
	 			zArrGeolocationCallback[i]();
	 		} 
	 		return;

		}else{
			if(zArrGeolocationWatchCallback.length){
				navigator.geolocation.watchPosition(function(location) {
					// this allows realtime position information to come back to the site.  

					zSetCurrentUserLocation(location.coords.latitude, location.coords.longitude, 'device');  
			 		for(var i=0;i<zArrGeolocationWatchCallback.length;i++){
			 			zArrGeolocationWatchCallback[i]();
			 		}
				}, function(error){
					console.log('navigator.geolocation.watchPosition failed');
					console.log(error);

				}, { enableHighAccuracy :true}); 
			}
			if(zArrGeolocationCallback.length){
				navigator.geolocation.getCurrentPosition(function(location) { 
					console.log('navigator.geolocation.getCurrentPosition success'); 
					console.log(location);

					zSetCurrentUserLocation(location.coords.latitude, location.coords.longitude, 'device'); 
			 		for(var i=0;i<zArrGeolocationCallback.length;i++){
			 			zArrGeolocationCallback[i]();
			 		}
				}, function(error){
					console.log('navigator.geolocation.getCurrentPosition failed');
					console.log(error);

				}, { enableHighAccuracy :true}); 
			}
		}
	}


	window.zSetCurrentUserLocation=zSetCurrentUserLocation;
	window.zGetCurrentUserLocation=zGetCurrentUserLocation;
	window.zGetGeoLocationWithCallback=zGetGeoLocationWithCallback; 
	window.zSortLocationsByDistance=zSortLocationsByDistance;

	window.zGoogleAddressAutoCompleteRegisterCallback=zGoogleAddressAutoCompleteRegisterCallback;
	window.zGeocode=zGeocode;
	window.zIsGeocoderAvailable=zIsGeocoderAvailable;
	window.zGeocodeCacheAddress=zGeocodeCacheAddress;
	window.zCreateMap=zCreateMap;
	window.zCreateMapMarker=zCreateMapMarker;
	window.zMapFitMarkers=zMapFitMarkers;
	window.zAddMapMarkerByLatLng=zAddMapMarkerByLatLng;
	window.zGetLatLongByAddress=zGetLatLongByAddress;
	window.zAddMapMarkerByAddress=zAddMapMarkerByAddress;
	window.zCreateMapWithAddress=zCreateMapWithAddress;
	window.zCreateMapWithLatLng=zCreateMapWithLatLng;
	window.zDisplayDirectionsDistance=zDisplayDirectionsDistance;
	window.zGetDirectionsDistanceByLatLng=zGetDirectionsDistanceByLatLng;
	window.zGetDirectionsDistanceByAddress=zGetDirectionsDistanceByAddress;
	window.zGeocodeAddress=zGeocodeAddress;
})(jQuery, window, document, "undefined"); 