<cfcomponent>
<cfoutput>
<!---
Client or server-side geocode caching system. 
Also provides a framework for searching a table that has the correct latitude/longitude fields.

A table needs these 4 fields to support distance search:
	latitude:"zipcode_latitude",
	longitude:"zipcode_longitude",
	// the integer fields are the latitude/longitude * 100000 rounded off allow mysql range index to speed up performance
	latitudeInteger:"zipcode_latitude_integer",
	longitudeInteger:"zipcode_longitude_integer",
and then you can query it for distance with code similar to this function: searchZipcode

run /z/misc/geocode/index to debug/test geocoding features

run this to re-execute the links that didn't work the first time:
/z/misc/geocode/rerunFinalize

TODO: make a script that auto-geocodes all the "map picker" fields that are blank if there is a valid address entered in the other address fields.
	requires caching the full address in db in the map picker value field, instead of having to re-build it - simplifies the code a lot!
	limit it to just client project at first

// how to retrieve/queue a geocode
ts={
	mode: "server", // server or client
	// id, latitude & longitude will be passed in the query string to the callbackURL when the geocode has been completed.
	callbackURL:request.zos.globals.domain&"place/updateCoordinates?id=1",

	// for multiple addresses:
	arrAddress: [], // requires geocodio api to work
	// or for single address
	address:"", // in this exact format: address, city state zip

	// or preferably separated to guarantee formatting:
	address:"",
	address2:"", // be sure to split out unit, apt # or it may result in inaccurate geocoding
	city:"",
	state:"",
	country:"",
	zip:""
};
rs=geocodeCom.getGeocode(ts);
if(rs.status EQ "error"){
	// handle error
	throw(rs.errorMessage);
}else if(rs.status EQ "queued"){
	// do nothing
}else if(rs.status EQ "complete"){
	// store the latitude/longitude
	latitude=rs.latitude;
	longitude=rs.longitude;
}
ts={
	mode: "server", // server or client
	// id, latitude & longitude will be passed in the query string to the callbackURL when the geocode has been completed.
	callbackURL:request.zos.globals.domain&"place/updateCoordinates?id=1",

	// for multiple addresses:
	arrAddress: [], // requires geocodio api to work
	// or for single address
	address:"", // in this exact format: address, city state zip

	// or preferably separated to guarantee formatting:
	address:"",
	address2:"", // be sure to split out unit, apt # or it may result in inaccurate geocoding
	city:"",
	state:"",
	country:"",
	zip:""
};
rs=geocodeCom.getGeocode(ts);
if(rs.status EQ "error"){
	// handle error
	throw(rs.errorMessage);
}else if(rs.status EQ "queued"){
	// do nothing
}else if(rs.status EQ "complete"){
	// store the latitude/longitude
	latitude=rs.latitude;
	longitude=rs.longitude;
}
 
<!--- Example of getGeocode's callbackURL function for a client site --->
<cffunction name="testUpdateCoordinates" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer or server can access this url");
	}
	siteOptionCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.site-options");

	id=application.zcore.functions.zso(form, 'id');
	form.latitude=application.zcore.functions.zso(form, 'latitude');
	form.longitude=application.zcore.functions.zso(form, 'longitude');
	if(form.latitude EQ "" or form.longitude EQ ""){
		echo('invalid request');
		abort;
	}

	placeStruct=duplicate(application.zcore.siteOptionCom.getOptionGroupSetById(["Place"],  id));
	if(structcount(placeStruct) EQ 0){
		echo('place missing');
		abort;
	}
	// ignore coordinates already set
	if(placeStruct["Map Coordinates"] NEQ ""){
		echo('Already set');
		abort;
	} 
	placeStruct["Map Coordinates"]=form.latitude&","&form.longitude;
	structclear(form);
	application.zcore.siteOptionCom.setOptionGroupImportStruct(["Place"], 0, 0, placeStruct, form);  
	form.site_x_option_group_set_id=id;
	throw("testUpdateCoordinates is ok - see form dump for map coordinates");
	rs=siteOptionCom.internalGroupUpdate(); 
	echo('Map Coordinates Set');
	abort;
	</cfscript>
</cffunction>
 --->

<cffunction name="index" localmode="modern" access="remote"> 
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer or server can access this url");
	}
	</cfscript>
	<h2>Testing Geocoding Features</h2>
	<ul>
		<li><a href="/z/misc/geocode/testServerGeocode">Test Server-side Geocode</a></li>
		<li><a href="/z/misc/geocode/testClientGeocode">Test Client-side Geocode</a></li>
		<li><a href="/z/misc/geocode/testSearchZipCode">Test Distance Search on Zipcode Table</a></li>
		<li><a href="/z/misc/geocode/testAutocomplete">Test Google Places Autocomplete API</a></li> 
		<li><a href="/z/misc/geocode/cancelUpdateMapPicker">Cancel Active Geocoding Task</a></li>  
		<li>Total Geocode Server Request Today: #application.zcore.functions.zso(application, 'zGeocodeServerCount', true, 0)#</li>
	</ul>
</cffunction>

<!--- /z/misc/geocode/testAjaxGeocode --->
<cffunction name="testAjaxGeocode" localmode="modern" access="remote" roles="serveradministrator"> 
	<cfscript>
	form.address=application.zcore.functions.zso(form, "address", false, "125 Basin Street, Suite 203, Daytona Beach, FL 32114");
	form.exact=application.zcore.functions.zso(form, "exact", true, 1);
	if(form.exact EQ 1){
		exact=true;
	}else{
		exact=false;
	}
	</cfscript>
	<h2>Ajax Geocode</h2>
	<cfif application.zcore.functions.zso(request.zos, "geocodioAPIKey") NEQ "">
		<p>Geocoding Vendor: Geocod.io</p>
	<cfelse>
		<p>Geocoding Vendor: Google Maps</p>
	</cfif>
	<form action="/z/misc/geocode/testAjaxGeocode" method="get">
		<p>Address: <input type="text" name="address" style="width:100%; max-width:100%;" value="#htmleditformat(form.address)#"></p>
		<p>Exact Location Only? #application.zcore.functions.zInput_Boolean("exact")#</p>
		<p><input type="submit" name="submit1" value="Submit"></p>
	</form>
	<h3>Response</h3>
	<p id="mapCoordinates"></p>
	<script>
	zArrDeferredFunctions.push(function(){
		var options={
			exact:#exact#,
			address:"#jsstringformat(form.address)#",
			callback:function(r){
				if(r.success){
					// do something with result
					var mapLocation=r.latitude+","+r.longitude+" exact: "+r.exact;
					$("##mapCoordinates").html(mapLocation);
				}else{
					$("##mapCoordinates").html("Unable to map location, please try a different input.");
				}
			}
		};
		zGeocodeAddress(options);
	});
	</script>

	<h2>Server-Side Geocode Response:</h2>
	<cfscript>
	rs=application.zcore.functions.zGeocode(form.address, exact);
	if(rs.success){
		mapCoordinates=rs.latitude&","&rs.longitude&" exact:"&rs.exact;
		echo(mapCoordinates);
	}else{
		// no coordinates found
	}
	</cfscript>
</cffunction>

<!--- /z/misc/geocode/testServerGeocode --->
<cffunction name="testServerGeocode" localmode="modern" access="remote" roles="serveradministrator"> 
	<cfscript>
	form.mode="server";
	testClientGeocode();
	</cfscript>
</cffunction>
 

<!--- /z/misc/geocode/testClientGeocode --->
<cffunction name="testClientGeocode" localmode="modern" access="remote" roles="serveradministrator"> 
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer or server can access this url");
	}
	geocodeCom=this;
	form.mode=application.zcore.functions.zso(form, 'mode', false, 'client');

	application.zcore.functions.zRequireGoogleMaps();  
	ts={
		callbackURL:request.zos.globals.domain&"/z/misc/geocode/testUpdateCoordinates",
		//address:"300 Main St, Daytona Beach, FL 32118", // in this exact format: address, city state zip

		// or preferably separated to guarantee formatting:
		address:"300 Main Street",
		address2:"", // be sure to split out unit, apt # or it may result in inaccurate geocoding
		city:"Daytona Beach",
		state:"FL",
		country:"US",
		zip:"32118",
		mode:form.mode
	};
	rs=geocodeCom.getGeocode(ts);
	writedump(rs);

	// test that multiple callbackURLs are stored in same record correctly.
	ts={
		callbackURL:request.zos.globals.domain&"/z/misc/geocode/testUpdateCoordinates2",
		//address:"300 Main St, Daytona Beach, FL 32118", // in this exact format: address, city state zip

		// or preferably separated to guarantee formatting:
		address:"300 Main Street",
		address2:"", // be sure to split out unit, apt # or it may result in inaccurate geocoding
		city:"Daytona Beach",
		state:"FL",
		country:"US",
		zip:"32118",
		mode:form.mode
	};
	rs=geocodeCom.getGeocode(ts);
	writedump(rs); 

	latitude="";
	longitude="";
	if(rs.status EQ "error"){
		// handle error
		throw(rs.errorMessage);
	}else if(rs.status EQ "queued"){
		// do nothing
	}else if(rs.status EQ "complete"){
		// store the latitude/longitude
		latitude=rs.latitude;
		longitude=rs.longitude;
	}
	echo('status:'&rs.status&"<br>");
	echo('latitude:'&latitude&"<br>");
	echo('longitude:'&longitude&"<br>");
	</cfscript>
</cffunction>
 
<!--- /z/misc/geocode/testSearchZipCode --->
<cffunction name="testSearchZipCode" localmode="modern" access="remote">
	<cfscript>
	// this is an example of how to search a table using this cfc
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer or server can access this url");
	}
	geocodeCom=this;
	ts={
		fields:{
			latitude:"zipcode_latitude",
			longitude:"zipcode_longitude",
			latitudeInteger:"zipcode_latitude_integer",
			longitudeInteger:"zipcode_longitude_integer",
			distance:"distance"
		},
		startPosition:{
			latitude:30.754348000000000000,
			longitude:-81.561603000000000000
		},
		miles:15
	}
	rs=geocodeCom.getSearchSQL(ts);

	/*
	address based distance search 
		geocode the address the user has typed (using google client geocoding api)
		distance to zip is not sufficient.  it has to be distance to the lat/long, which is a dynamic calculation using the full algorithm sin/cos, etc
	*/
	db=request.zos.queryObject;
	db.sql="select * 
	#db.trustedSQL(rs.selectSQL)#
	from #db.table("zipcode", request.zos.globals.datasource)#  
	where #db.param(1)# = #db.param(1)# 
	#db.trustedSQL(rs.whereSQL)#  
	ORDER BY `distance`";
	qDistance=db.execute("qDistance"); 
	// going to need to order by the subscription and better if that was converted to number in change.cfc.
	for(row in qDistance){
		echo('#row.zipcode_zip# | #row.distance# miles<br />');
	}
	abort;
	</cfscript>

</cffunction>
 


<!--- /z/misc/geocode/testAutocomplete --->
<cffunction name="testAutocomplete" localmode="modern" access="remote">
	<cfscript>
	// this function is an example of how to use google places autocomplete api
	if(not request.zos.isDeveloper){
		application.zcore.functions.z404("Only developers can access this");
	}
	application.zcore.functions.zRequireGoogleMaps(); 
	</cfscript>  
    <div id="locationField">
      <input id="autocomplete" placeholder="Enter your address" class="zGoogleAddressAutoComplete" type="text"
      data-address-coordinates="address_coordinates" 
      data-address-number="address_number" 
      data-address-street="address_street" 
      data-address-city="address_city" 
      data-address-state="address_state" 
      data-address-zip="address_zip" 
      data-address-country="address_country" />  
      <input type="button" name="doSearch" value="Search">
    </div>

    <table id="address">
      <tr>
        <td class="label">Coordinates</td>
        <td class="slimField"><input class="field" id="address_coordinates" name="address_coordinates" disabled="true"></input></td>
      </tr>
      <tr>
        <td class="label">Street Number</td>
        <td class="slimField"><input class="field" id="address_number" name="address_number" disabled="true"></input></td>
      </tr>
      <tr>
        <td class="label">Street Address</td>
        <td class="wideField"><input class="field" id="address_street" name="address_street" disabled="true"></input></td>
      </tr>
      <tr>
        <td class="label">City</td>
        <td class="wideField"><input class="field" id="address_city" name="address_city" disabled="true"></input></td>
      </tr>
      <tr>
        <td class="label">State</td>
        <td class="slimField"><input class="field" id="address_state" name="address_state" disabled="true"></input></td>
      </tr>
      <tr>
        <td class="label">Zip code</td>
        <td class="wideField"><input class="field" id="address_zip" name="address_zip" disabled="true"></input></td>
      </tr>
      <tr>
        <td class="label">Country</td>
        <td class="wideField"><input class="field" id="address_country" name="address_country" disabled="true"></input></td>
      </tr>
    </table>

	<script> 
	</script>
</cffunction>
	 
<cffunction name="getAjaxGeocode" localmode="modern" access="remote">
	<cfscript>
	// only meant to be called via geocode.cfc's zAjax call 
	rs={};
	db=request.zos.queryObject;
	db.sql="select count(geocode_cache_id) count from #db.table("geocode_cache", request.zos.zcoreDatasource)# WHERE 
	geocode_cache_deleted=#db.param(0)# and ";
	if(not request.zos.isTestServer){
		db.sql&=" geocode_cache_client1_ip_address <> #db.param(request.zos.cgi.remote_addr)# and
		geocode_cache_client2_ip_address <> #db.param(request.zos.cgi.remote_addr)# and 
		geocode_cache_client3_ip_address <> #db.param(request.zos.cgi.remote_addr)# and  ";
	}
	db.sql&=" geocode_cache_confirm_count <> #db.param(3)# ";
	qCount=db.execute("qCount");

	if(qCount.recordcount){
		application.zGeocodeIncompleteCount=qCount.count;
	}else{
		application.zGeocodeIncompleteCount=0;
	}
	
	db.sql="select * from #db.table("geocode_cache", request.zos.zcoreDatasource)# 
	WHERE geocode_cache_deleted=#db.param(0)# and ";
	if(not request.zos.isTestServer){
		db.sql&=" geocode_cache_client1_ip_address <> #db.param(request.zos.cgi.remote_addr)# and
	geocode_cache_client2_ip_address <> #db.param(request.zos.cgi.remote_addr)# and 
	geocode_cache_client3_ip_address <> #db.param(request.zos.cgi.remote_addr)# and   ";
	}
	db.sql&=" geocode_cache_confirm_count <> #db.param(3)# 
	LIMIT ";
	if(qCount.count LT 10){
		db.sql&=db.param(0);
	}else{
		db.sql&=db.param(randrange(0,min(application.zGeocodeIncompleteCount/10,10))*10);
	}
	db.sql&=", #db.param(10)#";
	qGeocode=db.execute("qGeocode"); 
	rs.arrAddress=[];
	rs.arrKey=[];
	if(qGeocode.recordcount EQ 0){
		rs.success=false;
	}else{
		for(row in qGeocode){
			arrayAppend(rs.arrAddress, row.geocode_cache_address);
			arrayAppend(rs.arrKey, row.geocode_cache_hash);
		}
	} 
	rs.success=true;
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>


<cffunction name="processGeocodeQueue" localmode="modern" access="public"> 
	<cfscript>
	// this is meant to be a scheduled task that recurs throughout the day.

	// disabled for now: avoid hitting limits by disabling on test server
	if(request.zos.isTestServer){
		return;
	} 
	if(request.zos.isDeveloper and structkeyexists(form, 'forceGeocode')){
		application.zGeocodeIncompleteCount=1;
	}
	// avoid running this if we don't have to.
	if(structkeyexists(application, 'zGeocodeIncompleteCount') and application.zGeocodeIncompleteCount EQ 0){
		return;
	}
	if(not structkeyexists(application, 'zGeocodeCacheLimitTotal')){
		application.zGeocodeCacheLimitTotal=0;
	} 
	// limit to 1500 request per day globally unless the site has no API key
	if(request.zos.globals.googleMapsApiKey NEQ ""){
		today=dateformat(now(), 'yyyymmdd');
		if(not structkeyexists(application, 'zGeocodeCacheLimitDate')){
			application.zGeocodeCacheLimitDate=today;
		}
		if(not structkeyexists(application, 'zGeocodeCacheLimit')){
			application.zGeocodeCacheLimit=0;
		}
		if(application.zGeocodeCacheLimitDate NEQ today){
			application.zGeocodeCacheLimitDate=today;
			application.zGeocodeCacheLimit=0;
		}
		if(application.zGeocodeCacheLimit > 1500){
			// the limit is 2500 per day, but we reserve 1000 geocodes to allow real users to do geocoding themselves.
			// sites launched before summer 2016 still have free client side geocoding, which is not being counted towards the limit.
			return;
		}
	}
	</cfscript>
	<!--- <cfsavecontent variable="out"> 
		<script>
		zArrMapFunctions.push(function(){
			var ts={
				id:"zGeocodeQueue",
				method:"get",
				url:"/z/misc/geocode/getAjaxGeocode",
				callback:function(r){
					var r=JSON.parse(r);
					if(r.success){
						zGeocode.arrAddress=r.arrAddress;
						zGeocode.arrKey=r.arrKey;
						zGeocodeCacheAddress(); 
					}else{
						echo('getAjaxGeocode: fail');
					}
				},
				cache:false
			};  
			zAjax(ts);
		});
		</script>
	</cfsavecontent>
	<cfscript>
	application.zcore.template.appendTag("scripts", out);
	</cfscript> --->
</cffunction>


<!---
/z/misc/geocode/geocodeAjaxKey
 --->
<cffunction name="geocodeAjaxKey" localmode="modern" access="remote">
	<cfscript>
	application.zcore.session.forceEnable();
	form.v=application.zcore.functions.zso(form, "v");
	if(form.v EQ ""){
		application.zcore.functions.zReturnJson({success:false});
	}
	if(not structkeyexists(request.zsession, "geocodeKey"&form.v)){
		request.zsession["geocodeKey"&form.v]=hash(randRange(1, 1000000)&form.v);
	}
	application.zcore.functions.zReturnJson({success:true, value:request.zsession["geocodeKey"&form.v]});
	</cfscript>
</cffunction>
 
<cffunction name="geocodeAjax" localmode="modern" access="remote">
	<cfscript>
	form.address=application.zcore.functions.zso(form, "address");
	form.key=application.zcore.functions.zso(form, 'key');
	form.api=application.zcore.functions.zso(form, 'api', false, 0);
	form.v=application.zcore.functions.zso(form, "v");

	if(not structkeyexists(request.zsession, "geocodeKey"&form.v) or request.zsession["geocodeKey"&form.v] NEQ form.key){
		application.zcore.functions.zReturnJSON({success:false, exact:false, key:form.key, errorMessage:"Invalid key"});
	}
	ts={
		mode:"server",
		address:form.address,
		api:form.api // 0 is geocodio, 1 is google
	};
	if(not structkeyexists(request.zos, 'geocodeCom')){
		request.zos.geocodeCom=application.zcore.functions.zcreateObject("component", "zcorerootmapping.mvc.z.misc.controller.geocode");
	}
	rs=request.zos.geocodeCom.getGeocode(ts); 
	if(rs.status EQ "complete" and rs.latitude NEQ ""){
		application.zcore.functions.zReturnJson({success:true, exact:rs.exact, key:form.key, latitude:rs.latitude, longitude:rs.longitude});
	}else{
		application.zcore.functions.zReturnJson({success:false, exact:false, key:form.key, errorMessage:"Couldn't find coordinates for address"});
	}
	</cfscript>
</cffunction>

<!--- 
ts={
	mode:"server",
	address:"address",
	returnAddressComponents:true
};
geocodeCom=application.zcore.functions.zcreateObject("component", "zcorerootmapping.mvc.z.misc.controller.geocode");
rs=geocodeCom.getGeocode(ts);
if(rs.success){
	/* returns this structure
	rs.exact=true or false
	rs.latitude
	rs.longitude
	rs.addressComponents={
		number: "1109",
		predirectional: "N",
		street: "Highland",
		suffix: "St",
		formatted_street: "N Highland St",
		city: "Arlington",
		county: "Arlington County",
		state: "VA",
		zip: "22201",
		country: "US"
	}
	*/
}
 --->
<cffunction name="getGeocode" localmode="modern" access="remote">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	// this function may be called directly or internally 
	ts={
		name:"geocoding",
		type:"ip",
		api:0,
		limits:{
			minute:30,
			hour:300,
			day:1000
		}
	};
	if(application.zcore.tracking.isAPIUsageThrottled(ts)){
		// this request was blocked due to high usage
		rs={};
		rs.status="complete"; 
		rs.latitude="";
		rs.longitude="";
		rs.addressComponents={};
		rs.exact=false;
		rs.errorNumber=1;
		return rs;
	}

	ts={
		returnAddressComponents:false,
		callbackURL:"",
		arrAddress:[],
		api:0,
		address:"",
		address2:"", // be sure to split out unit, apt # or it may result in inaccurate geocoding
		city:"",
		state:"",
		country:"",
		zip:"",
		mode:'client' // client or server | server mode will only use server method on first call.  If the geocode is queued, it will fall back to client.
	};
	ss=arguments.ss;
	structappend(ss, ts, false);
	for(i in ss){
		if(i EQ "arrAddress"){
			continue;
		}
		ss[i]=trim(ss[i]);
	} 
	if(ss.address EQ ""){
		throw("arguments.ss.address is required");
	}
	if(ss.mode EQ "client"){
		if(ss.callbackURL EQ ""){
			throw("arguments.ss.callbackURL is required");
		}
	}
	arrAddress=[ss.address];
	if(ss.city NEQ ""){
		arrayAppend(arrAddress, ", "&ss.city);
	}
	if(ss.state NEQ ""){
		arrayAppend(arrAddress, ", "&ss.state);
	}
	if(ss.zip NEQ ""){
		arrayAppend(arrAddress, " "&ss.zip);
	}
	if(ss.country NEQ "" and ss.country NEQ "US" and ss.country NEQ "USA" and ss.country NEQ "United States"){
		arrayAppend(arrAddress, " "&ss.country);
	}


	ts={
		table:"geocode_cache",
		datasource:request.zos.zcoreDatasource,
		struct:{
			geocode_cache_callback_url:ss.callbackURL,
			geocode_cache_hash:hash(application.zcore.functions.zGenerateStrongPassword(80,200), 'sha-256'),
			geocode_cache_address:replace(replace(arrayToList(arrAddress, ""), "  ", " ", "all"), "  ", " ", "all"),
			geocode_cache_created_datetime:request.zos.mysqlnow,
			geocode_cache_updated_datetime:request.zos.mysqlnow,
			geocode_deleted:0
		}
	}
	db=request.zos.queryObject; 
	db.sql="select * from #db.table("geocode_cache", request.zos.zcoreDatasource)# 
	WHERE geocode_cache_deleted=#db.param(0)# and 
	geocode_cache_address = #db.param(ts.struct.geocode_cache_address)#";
	qGeocode=db.execute("qGeocode");

	if(qGeocode.recordcount NEQ 0 and qGeocode.geocode_cache_confirm_count EQ 3){
		// already geocoded
		rs={};
		rs.status="complete";
		rs.addressComponents={};
		rs.errorNumber=0;
		// fix the double casting
		if(qGeocode.geocode_cache_latitude EQ "0E-7" or qGeocode.geocode_cache_latitude EQ "0"){
			rs.latitude="";
			rs.longitude="";
			rs.errorNumber=2;
		}else{
			rs.latitude=qGeocode.geocode_cache_latitude;
			rs.longitude=qGeocode.geocode_cache_longitude;
		}
		if(qGeocode.geocode_cache_accuracy EQ "ROOFTOP"){
			rs.exact=true;
		}else{
			rs.exact=false;
		}
		if(qGeocode.geocode_cache_address_json NEQ ""){
			rs.addressComponents=deserializeJson(qGeocode.geocode_cache_address_json);
		}
		if(ss.returnAddressComponents and rs.latitude NEQ "" and qGeocode.geocode_cache_address_json EQ ""){
			// don't return because we require address components
		}else{
			return rs;  
		}
	}

	useGeocodio=false;

	if(ss.mode EQ "server"){ 
		if(not structkeyexists(application, 'zGeocodeServerCount') or application.zGeocodeServerDate NEQ dateformat(now(), 'yyyymmdd')){
			application.zGeocodeServerCount=0;
			application.zGeocodeServerDate=dateformat(now(), 'yyyymmdd');
		} 		 
		// application.zGeocodeServerCount++;
		// if(application.zGeocodeServerCount GT 1500){
		// 	rs={success:false};
		// }else{
		if(arrayLen(ss.arrAddress) EQ 1){
			ss.address=ss.arrAddress[1];
			ss.arrAddress=[];
		}
		if(arrayLen(ss.arrAddress) GT 1){
			throw("Bulk geocoding is not implemented yet. The request is done, but not the response processing.");
			if(ss.api EQ 0 and application.zcore.functions.zso(request.zos, "geocodioAPIKey") NEQ ""){
				http url="https://api.geocod.io/v1.3/geocode?api_key=#request.zos.geocodioAPIKey#" timeout="1000" method="post"{
					header name="Content-Type" value="application/json";
					header name="body" value="#serializeJSON(ss.arrAddress)#"; 
				}
				useGeocodio=true;
			}else{
				//throw("Geocodio API Key is not defined and it required to be able to geocode multiple addresses at once.");
				throw("Multiple address geocoding with ss.exact=false is not supported.");
			}
		}else{
			if(ss.api EQ 0 and application.zcore.functions.zso(request.zos, "geocodioAPIKey") NEQ ""){
				http url="https://api.geocod.io/v1.3/geocode?q=#urlencodedformat(ts.struct.geocode_cache_address)#&api_key=#request.zos.geocodioAPIKey#" timeout="1000" method="get"{}
				useGeocodio=true; 
			}else{
				link="https://maps.google.com/maps/api/geocode/json?key=#application.zcore.functions.zso(request.zos, 'googleMapsApiServerKey')#&address="&urlencodedformat(ts.struct.geocode_cache_address)&"&sensor=false";
				http url="#link#" timeout="10" method="get"{}
			}
		} 
		// }

		if(cfhttp.status_code EQ 200){
			location=deserializeJson(cfhttp.filecontent);
			if(structkeyexists(form, 'debugGeocode')){
				writedump(location);
				abort;
			}
			if(useGeocodio){
				if(structkeyexists(location, "results") and arraylen(location.results) GT 0){
					result=location.results[1];

					t9={
						"number": "",
						"predirectional": "",
						"street": "",
						"suffix": "",
						"formatted_street": "",
						"city": "",
						"county": "",
						"state": "",
						"zip": "",
						"country": ""
					};
					// force existence of all keys
					structappend(result.address_components, t9, false);
					if(result.accuracy_type EQ "rooftop" or result.accuracy_type EQ "point"){
						rs={};
						rs.errorNumber=0;
						rs.latitude=result.location.lat;
						rs.longitude=result.location.lng;
						rs.addressComponents=result.address_components;
						rs.status="complete";
						ts.struct.geocode_cache_accuracy="ROOFTOP";
						ts.struct.geocode_cache_latitude=rs.latitude;
						ts.struct.geocode_cache_longitude=rs.longitude;
						ts.struct.geocode_cache_status="OK";
						ts.struct.geocode_cache_confirm_count=3;
						ts.struct.geocode_cache_callback_url="";
						ts.struct.geocode_cache_address_json=serializeJson(result.address_components);
						if(qGeocode.recordcount NEQ 0){
							ts.struct.geocode_cache_id=qGeocode.geocode_cache_id;
							application.zcore.functions.zUpdate(ts); 
						}else{
							application.zcore.functions.zInsert(ts); 
						}
					}else{ 
						rs={};
						rs.errorNumber=0;
						rs.status="complete"; 
						rs.latitude=result.location.lat;
						rs.longitude=result.location.lng;
						rs.addressComponents=result.address_components;
						ts.struct.geocode_cache_accuracy="ESTIMATE";
						ts.struct.geocode_cache_status="OK";
						ts.struct.geocode_cache_confirm_count=3;
						ts.struct.geocode_cache_callback_url="";
						ts.struct.geocode_cache_latitude=rs.latitude;
						ts.struct.geocode_cache_longitude=rs.longitude;
						ts.struct.geocode_cache_address_json=serializeJson(result.address_components);
						if(qGeocode.recordcount NEQ 0){
							ts.struct.geocode_cache_id=qGeocode.geocode_cache_id;
							application.zcore.functions.zUpdate(ts); 
						}else{
							application.zcore.functions.zInsert(ts);
						}
					} 
				}else{
					ts.struct.geocode_cache_accuracy="FAILED";
					ts.struct.geocode_cache_status="OK";
					ts.struct.geocode_cache_confirm_count=3;
					ts.struct.geocode_cache_callback_url="";
					application.zcore.functions.zInsert(ts);
					rs={};
					rs.status="complete"; 
					rs.latitude="";
					rs.longitude="";
					rs.errorNumber=3;
					rs.addressComponents={};
				}
			}else{ 
				if(isArray(location.results) and arraylen(location.results) GT 0 and location['status'] NEQ "ZERO_RESULTS"){ 
					locationGeometry=location['results'][1]['geometry']['location'];
					types=arrayToList(location['results'][1].types, ",");
					rs={};
					rs.latitude=locationGeometry.lat;
					rs.longitude=locationGeometry.lng;
					rs.status="complete";
					ts.struct.geocode_cache_accuracy="";
					if(types=="street_address" || types == "premise" || types == "subpremise"){
						ts.struct.geocode_cache_accuracy="ROOFTOP";
					}else{
						ts.struct.geocode_cache_accuracy="ESTIMATE";
					}
					ts.struct.geocode_cache_latitude=rs.latitude;
					ts.struct.geocode_cache_longitude=rs.longitude;
					ts.struct.geocode_cache_status="OK";
					ts.struct.geocode_cache_confirm_count=3;
					ts.struct.geocode_cache_callback_url="";
					application.zcore.functions.zInsert(ts); 
				}else{
					// store it as no coordinates
					ts.struct.geocode_cache_accuracy="FAILED";
					ts.struct.geocode_cache_status="OK";
					ts.struct.geocode_cache_confirm_count=3;
					ts.struct.geocode_cache_callback_url="";
					application.zcore.functions.zInsert(ts);
					rs={};
					rs.status="complete"; 
					rs.latitude="";
					rs.longitude="";
				}
			}
			if(ts.struct.geocode_cache_accuracy EQ "ROOFTOP"){
				rs.exact=true;
			}else{
				rs.exact=false;
			}
		}else{
			if(useGeocodio and cfhttp.status_code EQ "422"){
				rs={};
				rs.status="complete"; 
				rs.latitude="";
				rs.longitude="";
				rs.errorNumber=4;
				rs.exact=false;
				ts.struct.geocode_cache_accuracy="FAILED";
				ts.struct.geocode_cache_status="OK";
				ts.struct.geocode_cache_confirm_count=3;
				ts.struct.geocode_cache_callback_url="";
				application.zcore.functions.zInsert(ts);

			}else{

				rs={
					exact:false
				};
				// queue it | hit limit or temporary api failure
				rs.status="queued";
				application.zcore.functions.zInsert(ts);
				if(not structkeyexists(application, 'zGeocodeIncompleteCount')){
					application.zGeocodeIncompleteCount=0;
				}
				application.zGeocodeIncompleteCount++;
				savecontent variable="out"{
					writedump(form);
					writedump(cfhttp);
				}
				ts={
					type:"Custom",
					errorHTML:"Geocode was queued. Vendor might not be available. Queue is currently not enabled for processing, must review this manually.<br><br>"&out,
					scriptName:'',
					url:request.zos.originalURL,
					exceptionMessage:"Geocode was queued.  Vendor might not be available. Queue is currently not enabled for processing, must review this manually.",
					// optional
					lineNumber:'710'
				}
				application.zcore.functions.zLogError(ts);
			}
		} 
		return rs;
	}else if(ss.mode EQ "client"){ 
		throw("Client mode is disabled to avoid hitting limits, which no longer are measured by ip.");

		// rs={};
		// if(qGeocode.recordcount EQ 0){
		// 	geocode_cache_id=application.zcore.functions.zInsert(ts);
		// 	if(not structkeyexists(application, 'zGeocodeIncompleteCount')){
		// 		application.zGeocodeIncompleteCount=0;
		// 	}
		// 	application.zGeocodeIncompleteCount++;
		// 	if(geocode_cache_id){
		// 		rs.status="queued";
		// 		return rs;
		// 	}else{
		// 		rs.status="error";
		// 		rs.errorMessage="Failed to queue geocode";
		// 		return rs;
		// 	}
		// }else{
		// 	if(qGeocode.geocode_cache_confirm_count < 3){
		// 		arrURL=listToArray(qGeocode.geocode_cache_callback_url, chr(10))
		// 		for(link in arrURL){
		// 			if(link EQ ss.callbackURL){
		// 				// already queued
		// 				rs.status="queued";
		// 				return rs;
		// 			}
		// 		} 
		// 		arrayAppend(arrURL, ss.callbackURL);
		// 		ts.struct.geocode_cache_callback_url=arrayToList(arrURL, chr(10));
		// 		ts.struct.geocode_cache_id=qGeocode.geocode_cache_id;
		// 		ts.struct.geocode_cache_hash=qGeocode.geocode_cache_hash;
		// 		result=application.zcore.functions.zUpdate(ts);
		// 		if(result){
		// 			rs.status="queued";
		// 			return rs;
		// 		}else{
		// 			rs.status="error";
		// 			rs.errorMessage="Failed to queue geocode";
		// 			return rs; 
		// 		} 
		// 	}
		// } 
	}
	</cfscript> 
</cffunction>

<cffunction name="saveGeocode" localmode="modern" access="remote"> 
	<cfscript> 
	db=request.zos.queryObject; 
	if(not structkeyexists(application, 'zGeocodeCacheLimitTotal')){
		application.zGeocodeCacheLimitTotal=0;
	}
	application.zGeocodeCacheLimitTotal++;
	if(request.zos.globals.googleMapsApiKey NEQ ""){
		if(not structkeyexists(application, 'zGeocodeCacheLimit')){
			application.zGeocodeCacheLimit=0;
		}
		application.zGeocodeCacheLimit++;
	}
	form.address=application.zcore.functions.zso(form, 'address');
	form.latitude=application.zcore.functions.zso(form, 'latitude');
	form.longitude=application.zcore.functions.zso(form, 'longitude');
	form.accuracy=application.zcore.functions.zso(form, 'accuracy');
	form.status=application.zcore.functions.zso(form, 'status');
	form.key=application.zcore.functions.zso(form, 'key');
	if(form.address EQ ""){ 
		application.zcore.functions.zReturnJson({success:false, errorMessage:"Invalid request"});
	}
	db.sql="select sql_no_cache * from #db.table("geocode_cache", request.zos.zcoreDatasource)# 
	WHERE geocode_cache_deleted=#db.param(0)# and 
	geocode_cache_address = #db.param(form.address)# and 
	geocode_cache_hash=#db.param(form.key)#";
	qGeocode=db.execute("qGeocode");
	if(qGeocode.recordcount EQ 0){
		application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-existent address or invalid key"});
	}
	if(qGeocode.geocode_cache_confirm_count EQ 3){
		application.zcore.functions.zReturnJson({success:false, errorMessage:"Already completed"});
	} 
	for(row in qGeocode){
		whichClient=1;
		//echo(row.geocode_cache_confirm_count&":"&whichClient&"<br>");
		if(row.geocode_cache_confirm_count EQ 0){
			row.geocode_cache_confirm_count=1;
			row.geocode_cache_client1_ip_address=request.zos.cgi.remote_addr;
			whichClient=1;
		}else if(row.geocode_cache_confirm_count EQ 1){
			if(not request.zos.isTestServer and row.geocode_cache_client1_ip_address EQ request.zos.cgi.remote_addr){
				application.zcore.functions.zReturnJson({success:false, errorMessage:"Not a unique IP Address"});
			}
			row.geocode_cache_confirm_count=2;
			row.geocode_cache_client2_ip_address=request.zos.cgi.remote_addr;
			whichClient=2;
		}else if(row.geocode_cache_confirm_count EQ 2){
			if(not request.zos.isTestServer and row.geocode_cache_client1_ip_address EQ request.zos.cgi.remote_addr){
				application.zcore.functions.zReturnJson({success:false, errorMessage:"Not a unique IP Address"});
			}
			if(not request.zos.isTestServer and row.geocode_cache_client2_ip_address EQ request.zos.cgi.remote_addr){
				application.zcore.functions.zReturnJson({success:false, errorMessage:"Not a unique IP Address"});
			}
			row.geocode_cache_confirm_count=3;
			row.geocode_cache_client3_ip_address=request.zos.cgi.remote_addr;
			whichClient=3;
		}
		row["geocode_cache_client#whichClient#_latitude"]=numberformat(form.latitude, '_._______');
		row["geocode_cache_client#whichClient#_longitude"]=numberformat(form.longitude, '_._______');
		row["geocode_cache_client#whichClient#_accuracy"]=form.accuracy;
		row["geocode_cache_client#whichClient#_status"]=form.status;
		//echo(row.geocode_cache_confirm_count&":"&whichClient);abort;
		// find if the current whichClient is the non-matching one 
		finalize=false;
		if(request.zos.isTestServer){
			finalize=true;
			row.geocode_cache_confirm_count=3;
		}else{
			if(row.geocode_cache_confirm_count EQ 3){ 
				if(compare(numberformat(row.geocode_cache_client1_latitude, '_._______'), numberformat(row.geocode_cache_client2_latitude, '_._______')) EQ 0 and compare(row.geocode_cache_client1_longitude, row.geocode_cache_client2_longitude) EQ 0){
					if(compare(numberformat(row.geocode_cache_client2_latitude, '_._______'), numberformat(row.geocode_cache_client3_latitude, '_._______')) EQ 0 and compare(numberformat(row.geocode_cache_client2_longitude, '_._______'), numberformat(row.geocode_cache_client3_longitude, '_._______')) EQ 0){
						// all 3 match
						finalize=true;
					}else{
						// only first 2 match, invalid 3rd record - need to redo it
						if(whichClient EQ 3){
							db.sql="update #db.table("geocode_cache", request.zos.zcoreDatasource)# SET 
							geocode_cache_confirm_count=#db.param(0)#, 
							geocode_cache_updated_datetime=#db.param(request.zos.mysqlnow)# WHERE 
							geocode_cache_id=#db.param(row.geocode_cache_id)# and 
							geocode_cache_deleted=#db.param(0)#";
							db.execute("qUpdate");
							// return and ignore this save request
							application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-matching third geocode #row.geocode_cache_client2_latitude# EQ #row.geocode_cache_client3_latitude# and #row.geocode_cache_client2_longitude# EQ #row.geocode_cache_client3_longitude#"});
						}
					}
				}else{
					if(compare(numberformat(row.geocode_cache_client2_latitude, '_._______'), numberformat(row.geocode_cache_client3_latitude, '_._______')) EQ 0 and compare(numberformat(row.geocode_cache_client2_longitude, '_._______'), numberformat(row.geocode_cache_client3_longitude, '_._______')) EQ 0){
						// last 2 match
						if(whichClient EQ 1){
							db.sql="update #db.table("geocode_cache", request.zos.zcoreDatasource)# SET 
							geocode_cache_confirm_count=#db.param(0)#, 
							geocode_cache_updated_datetime=#db.param(request.zos.mysqlnow)# WHERE 
							geocode_cache_id=#db.param(row.geocode_cache_id)# and 
							geocode_cache_deleted=#db.param(0)#";
							db.execute("qUpdate");
							// return and ignore this save request
							application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-matching first geocode: #row.geocode_cache_client2_latitude# EQ #row.geocode_cache_client3_latitude# and #row.geocode_cache_client2_longitude# EQ #row.geocode_cache_client3_longitude#"});
						}
					}else{
						if(compare(numberformat(row.geocode_cache_client1_latitude, '_._______'), numberformat(row.geocode_cache_client3_latitude, '_._______')) EQ 0 and compare(numberformat(row.geocode_cache_client1_longitude, '_._______'), numberformat(row.geocode_cache_client3_longitude, '_._______')) EQ 0){
							// first and last match 
							if(whichClient EQ 2){
								db.sql="update #db.table("geocode_cache", request.zos.zcoreDatasource)# SET 
								geocode_cache_confirm_count=#db.param(0)#, 
								geocode_cache_updated_datetime=#db.param(request.zos.mysqlnow)# WHERE 
								geocode_cache_id=#db.param(row.geocode_cache_id)# and 
								geocode_cache_deleted=#db.param(0)#";
								db.execute("qUpdate");
								// return and ignore this save request
								application.zcore.functions.zReturnJson({success:false, errorMessage:"Non-matching second geocode: #row.geocode_cache_client1_latitude# EQ #row.geocode_cache_client3_latitude# and #row.geocode_cache_client1_longitude# EQ #row.geocode_cache_client3_longitude#"});
							}
						}else{
							// none match - strange - lets throw developer error to see why
							structappend(form, row, true);
							throw("None of the geocode results match");
							// application.zcore.functions.zReturnJson({success:false, errorMessage:"None of the geocode results match"});
						}
					}
				}
			}
		}
		if(finalize){
			if(row.geocode_cache_client1_accuracy EQ "ROOFTOP"){
				row.geocode_cache_latitude=row["geocode_cache_client1_latitude"];
				row.geocode_cache_longitude=row["geocode_cache_client1_longitude"];
			}else{
				row.geocode_cache_latitude="";
				row.geocode_cache_longitude="";
			}
			row.geocode_cache_accuracy=row["geocode_cache_client1_accuracy"];
			row.geocode_cache_status=row["geocode_cache_client1_status"];
			if(row.geocode_cache_latitude EQ 0){
				row.geocode_cache_callback_url="";
			}
		}
		row.geocode_cache_updated_datetime=request.zos.mysqlnow;
		row.geocode_cache_deleted=0;
		ts={
			table:"geocode_cache",
			datasource:request.zos.zcoreDatasource,
			struct:row
		} 
		result=application.zcore.functions.zUpdate(ts);  
		if(not result){
			application.zcore.functions.zReturnJson({success:false, errorMessage:'Failed to update record'});
		}
		if(finalize){
			if(row.geocode_cache_accuracy EQ "ROOFTOP"){
				arrNewLink=[];
				arrLink=listToArray(row.geocode_cache_callback_url, chr(10));
				for(link in arrLink){
					rs2=application.zcore.functions.zDownloadLink(application.zcore.functions.zURLAppend(link, 'latitude='&row.geocode_cache_latitude&'&longitude='&row.geocode_cache_longitude), 10);
					if(not rs2.success){
						arrayAppend(arrNewLink, link);
					}
				}
				db.sql="UPDATE #db.table("geocode_cache", request.zos.zcoreDatasource)# SET 
				geocode_cache_callback_url=#db.param(arrayToList(arrNewLink, chr(10)))#,
				geocode_cache_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))#
				WHERE
				geocode_cache_id =#db.param(row.geocode_cache_id)# AND
				geocode_cache_deleted=#db.param(0)#";
				db.execute("qGeocode"); 
			}
		}
	}
	application.zcore.functions.zReturnJson({success:true});
	</cfscript>

</cffunction>

<cffunction name="rerunFinalize" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	setting requesttimeout="10000";

	db.sql="SELECT * FROM #db.table("geocode_cache", request.zos.zcoreDatasource)# WHERE 
	geocode_cache_confirm_count =#db.param(3)# AND 
	geocode_cache_accuracy=#db.param('ROOFTOP')# AND 
	geocode_cache_callback_url <>#db.param('')# AND
	geocode_cache_deleted=#db.param(0)#";
	qGeocode=db.execute("qGeocode");
	for(row in qGeocode){
		if(row.geocode_cache_accuracy EQ "ROOFTOP"){
			arrLink=listToArray(row.geocode_cache_callback_url, chr(10));
			arrNewLink=[];
			for(link in arrLink){
				rs2=application.zcore.functions.zDownloadLink(application.zcore.functions.zURLAppend(link, 'latitude='&row.geocode_cache_latitude&'&longitude='&row.geocode_cache_longitude), 10);
				if(not rs2.success){
					arrayAppend(arrNewLink, link);
					echo("Failed:"&link&"<br>");
				}
			}
			db.sql="UPDATE #db.table("geocode_cache", request.zos.zcoreDatasource)# SET 
			geocode_cache_callback_url=#db.param(arrayToList(arrNewLink, chr(10)))#,
			geocode_cache_updated_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))#
			WHERE
			geocode_cache_id =#db.param(row.geocode_cache_id)# AND
			geocode_cache_deleted=#db.param(0)#";
			db.execute("qGeocode"); 
		}
	}
	</cfscript>
</cffunction>
	
<!--- 
ts={
	fields:{
		latitude:"place_latitude",
		longitude:"place_longitude",
		latitudeInteger:"place_latitude_integer",
		longitudeInteger:"place_longitude_integer",
		distance:"distance"
	},
	startPosition:{
		latitude:28.6660872,
		longitude:-82.6016039
	},
	miles:15
}
rs=geocodeCom.getSearchSQL(ts);
 --->
<cffunction name="getSearchSQL" localmode="modern" access="remote">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	// build a box to limit how many records are searched
	latDistanceInMiles=abs(ss.miles);
	longDistanceInMiles=abs(ss.miles);
	latDegrees=latDistanceInMiles/68; 
	longDegrees=longDistanceInMiles/68; 
  
	if(ss.startPosition.latitude > 90 or ss.startPosition.latitude < -90){
		return { success:false};
	}
	latitudeField="`#application.zcore.functions.zEscape(ss.fields.latitude)#`";
	longitudeField="`#application.zcore.functions.zEscape(ss.fields.longitude)#`";
	latitudeIntegerField="`#application.zcore.functions.zEscape(ss.fields.latitudeInteger)#`";
	longitudeIntegerField="`#application.zcore.functions.zEscape(ss.fields.longitudeInteger)#`";
	distanceField="`#application.zcore.functions.zEscape(ss.fields.distance)#`";
	startLatitude=application.zcore.functions.zEscape(ss.startPosition.latitude);
	startLongitude=application.zcore.functions.zEscape(ss.startPosition.longitude);
   	rs={};
   	rs.success=true;
   	rs.selectSQL=", ( 3959 * acos( cos( radians('#startLatitude#') )
      * cos( radians( #latitudeField# ) ) 
      * cos( radians( #longitudeField# ) - radians('#startLongitude#') ) 
      + sin( radians('#startLatitude#') ) 
      * sin( radians( #latitudeField# ) ) ) ) AS `#application.zcore.functions.zEscape(ss.fields.distance)#` ";
    rs.whereSQL=" and 
    ( 3959 * acos( cos( radians('#startLatitude#') )
      * cos( radians( #latitudeField# ) ) 
      * cos( radians( #longitudeField# ) - radians('#startLongitude#') ) 
      + sin( radians('#startLatitude#') ) 
      * sin( radians( #latitudeField# ) ) ) ) <= #application.zcore.functions.zEscape(ss.miles)# and 
	#latitudeIntegerField# between #application.zcore.functions.zEscape(int((ss.startPosition.latitude-latDegrees)*100000))# and #application.zcore.functions.zEscape(ceiling((ss.startPosition.latitude+latDegrees)*100000))# and 
	#longitudeIntegerField# between #application.zcore.functions.zEscape(int((ss.startPosition.longitude-longDegrees)*100000))# and #application.zcore.functions.zEscape(ceiling((ss.startPosition.longitude+longDegrees)*100000))# "; 
	return rs;
	</cfscript>
</cffunction>

<!--- /z/misc/geocode/cancelUpdateMapPicker --->
<cffunction name="cancelUpdateMapPicker" localmode="modern" access="remote">
	<cfscript>
	application.cancelGeocodeTask=true;
	</cfscript>
	Geocoding task will cancel shortly.
</cffunction>

</cfoutput>
</cfcomponent>