<cfcomponent>
<cfoutput><!--- zXMLtoStruct(xmlStruct, struct); --->
<cffunction name="zXMLtoStruct" localmode="modern" output="false" returntype="any">
	<cfargument name="xmlStruct" required="yes" type="any">
	<cfargument name="struct" required="yes" type="struct">
	<cfscript>
	for(i in arguments.xmlStruct){
		StructInsert(struct, i, arguments.xmlStruct[i].xmlText,true);
	}
	</cfscript>
</cffunction>

<cffunction name="zXMLEscape" localmode="modern" returntype="any" output="false">
	<cfargument name="value" type="string" required="yes">
	<cfscript>
	return Replace(Replace(replace(replace(StripCR(application.zcore.functions.zParagraphFormat(arguments.value)),"<br />",chr(10),"ALL"),"&","&amp;","ALL"), "<","&lt;","ALL"),">","&gt;","ALL");
	</cfscript>
</cffunction>




<!--- 
ts=StructNew();
ts.zip="32114";
ts.forecastLink=true;
ts.currentOnly=false;
ts.overrideStyles=false;
ts.timeout=3;
weatherHTML=zGetWeather(ts);
 --->
<cffunction name="zGetWeather" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=StructNew();
	var r={success:false};
	var arrWC=structnew();
	var d="";
	var image="";
	var weatherHTML="";
	/*if(not request.zos.istestserver){
		request.zLastWeatherLookup={temperature:0};
		return "";
	}*/
	ts.timeout=3;
	ts.forecastLink=true;
	ts.currentOnly=false;
	ts.overrideStyles=false;
	structappend(arguments.ss,ts,false);
	if(structkeyexists(arguments.ss,"zip") EQ false){
		application.zcore.template.fail("arguments.ss.zip is required.");
	}
	ctemp="";
	
	if(arguments.ss.currentOnly){
		ctemp="current-";
	}
	structdelete(request, 'zLastWeatherLookup');
	request.zLastWeatherLookup={};
	request.zLastWeatherLookup.temperature=0;
	ss2=application.sitestruct[request.zos.globals.id];
	download=false;
	if(not structkeyexists(ss2, 'weatherset'&arguments.ss.zip&ctemp&'v2')){
		download=true;
	}else if(datecompare(ss2["weatherset"&arguments.ss.zip&ctemp&'v2'], dateadd("n",-30,now())) EQ -1){
		download=true;
	}else if(not structkeyexists(ss2, "weatherset"&arguments.ss.zip&ctemp&'cache-v2')){
		if(not fileexists(request.zos.globals.serverprivatehomedir&"_cache/html/weather/#arguments.ss.zip#-#ctemp#v2.html")){
			download=true;
		}else{
			request.zLastWeatherLookup=deserializeJson(application.zcore.functions.zreadfile(request.zos.globals.serverprivatehomedir&"_cache/html/weather/#arguments.ss.zip#-#ctemp#v2.html"));
			if(not isstruct(request.zLastWeatherLookup)){
				structdelete(request, 'zLastWeatherLookup');
				request.zLastWeatherLookup={};
			}
		}
	}else{
		request.zLastWeatherLookup=ss2["weatherset"&arguments.ss.zip&ctemp&'cache-v2'];
		request.zLastWeatherLookup.temperature=application.zcore.functions.zso(request.zLastWeatherLookup, 'temperature');
		return request.zLastWeatherLookup.weatherHTML;
	}
	
	if(download){	
		// consider using weather.com instead: http://wxdata.weather.com/weather/local/32114 | ?cc= at end gives more info | has no image support rain / cloudy, etc
		ss2["weatherset"&arguments.ss.zip&ctemp&'v2']=now();
		try{
			r=application.zcore.functions.zdownloadlink("https://wxdata.weather.com/weather/local/#arguments.ss.zip#?cc=&unit=F", arguments.ss.timeout);
		}catch(Any e){ 
			e='Failed to download weather after 3 seconds: https://wxdata.weather.com/weather/local/#arguments.ss.zip#?cc=&unit=F';
			ts={
				type:"Custom",
				errorHTML:e,
				scriptName:request.zos.originalURL,
				url:request.zos.originalURL,
				exceptionMessage:e,
				// optional
				lineNumber:'93'
			}
			application.zcore.functions.zLogError(ts);
			r={success:false};
		}
		//r=application.zcore.functions.zdownloadlink("http://xml.weather.yahoo.com/forecastrss?p=#arguments.ss.zip#", 3);
	} 
	if(r.success){ 
		try{
			d=xmlparse(r.cfhttp.FileContent);
			if(not isdefined('d.weather.cc.t.xmltext')){
				return "";
			}
		}catch(Any excpt){
			return "";
		}
		/*
		arrWC=structnew();
		arrWC["0"]="tornado";
		arrWC["1"]="tropical storm";
		arrWC["2"]="hurricane";
		arrWC["3"]="severe thunderstorms";
		arrWC["4"]="thunderstorms";
		arrWC["5"]="mixed rain and snow";
		arrWC["6"]="mixed rain and sleet";
		arrWC["7"]="mixed snow and sleet";
		arrWC["8"]="freezing drizzle";
		arrWC["9"]="drizzle";
		arrWC["10"]="freezing rain";
		arrWC["11"]="showers";
		arrWC["12"]="showers";
		arrWC["13"]="snow flurries";
		arrWC["14"]="light snow showers ";
		arrWC["15"]="blowing snow";
		arrWC["16"]="snow";
		arrWC["17"]="hail";
		arrWC["18"]="sleet";
		arrWC["19"]="dust";
		arrWC["20"]="foggy";
		arrWC["21"]="haze";
		arrWC["22"]="smoky";
		arrWC["23"]="blustery";
		arrWC["24"]="windy";
		arrWC["25"]="cold";
		arrWC["26"]="cloudy";
		arrWC["27"]="mostly cloudy (night)";
		arrWC["28"]="mostly cloudy (day)";
		arrWC["29"]="partly cloudy (night)";
		arrWC["30"]="partly cloudy (day)";
		arrWC["31"]="clear (night)";
		arrWC["32"]="sunny";
		arrWC["33"]="fair (night)";
		arrWC["34"]="fair (day)";
		arrWC["35"]="mixed rain and hail";
		arrWC["36"]="hot";
		arrWC["37"]="isolated thunderstorms";
		arrWC["38"]="scattered thunderstorms";
		arrWC["39"]="scattered thunderstorms";
		arrWC["40"]="scattered showers";
		arrWC["41"]="heavy snow";
		arrWC["42"]="scattered snow showers ";
		arrWC["43"]="heavy snow";
		arrWC["44"]="partly cloudy";
		arrWC["45"]="thundershowers";
		arrWC["46"]="snow showers";
		arrWC["47"]="isolated thundershowers";
		arrWC["3200"]="not available";   
		if(not structkeyexists(d.rss.channel.item, "yweather:condition")){ 
			return "";
		}
		if(structkeyexists(arrWC,d.rss.channel.item["yweather:condition"].xmlattributes.code)){
			image1="http://us.i1.yimg.com/us.yimg.com/i/us/we/52/#d.rss.channel.item["yweather:condition"].xmlattributes.code#.gif";
		}else{
			image1=false;
		}
		*/
		image1=false;
		request.zLastWeatherLookup=structnew();
		request.zLastWeatherLookup.temperature=d.weather.cc.tmp.xmltext;//rss.channel.item["yweather:condition"].xmlattributes.temp;
		//request.zLastWeatherLookup.temperature=d.rss.channel.item["yweather:condition"].xmlattributes.temp;
		if(image1 NEQ false){
			request.zLastWeatherLookup.image=image1;
		}
		if(arguments.ss.currentOnly){
			request.zLastWeatherLookup.weatherHTML="#d.weather.cc.t.xmltext#, #d.weather.cc.tmp.xmltext# F";
			//request.zLastWeatherLookup.weatherHTML='#d.rss.channel.item["yweather:condition"].xmlattributes.text#, #d.rss.channel.item["yweather:condition"].xmlattributes.temp# F';
			application.zcore.functions.zwritefile(request.zos.globals.serverprivatehomedir&"_cache/html/weather/#arguments.ss.zip#-#ctemp#v2.html",trim(serializeJson(request.zLastWeatherLookup)));
			ss["weatherset"&arguments.ss.zip&ctemp&'cache-v2']=request.zLastWeatherLookup;
			return request.zLastWeatherLookup.weatherHTML;
		}
		savecontent variable="weatherHTML"{
			if(image1 NEQ false){
				echo('<img src="#image#" class="zweather-image">');
			}
			/*echo('<div class="zweather-current">Current Conditions:<br />
			#d.rss.channel.item["yweather:condition"].xmlattributes.text#, #d.rss.channel.item["yweather:condition"].xmlattributes.temp# F</div><br style="clear:both;" />
			<div class="zweather-divider"></div><br />
			Forecast:<br />
			#d.rss.channel.item["yweather:forecast"][1].xmlattributes.day# - #d.rss.channel.item["yweather:forecast"][1].xmlattributes.text#. <br />
			High: #d.rss.channel.item["yweather:forecast"][1].xmlattributes.high# Low: #d.rss.channel.item["yweather:forecast"][1].xmlattributes.low#
			<div class="zweather-divider2"></div><br />
			
			#d.rss.channel.item["yweather:forecast"][2].xmlattributes.day# - #d.rss.channel.item["yweather:forecast"][2].xmlattributes.text#. <br />
			High: #d.rss.channel.item["yweather:forecast"][2].xmlattributes.high# Low: #d.rss.channel.item["yweather:forecast"][2].xmlattributes.low#<br />
			<div class="zweather-yahoo">View Full Forecast at Yahoo! Weather</div>');*/
		}
		request.zLastWeatherLookup.weatherHTML=weatherHTML;
		ss2["weatherset"&arguments.ss.zip&'cache-v2']=request.zLastWeatherLookup;
		application.zcore.functions.zwritefile(request.zos.globals.serverprivatehomedir&"_cache/html/weather/#arguments.ss.zip#-#ctemp#v2.html",trim(serializeJson(request.zLastWeatherLookup)));

		return weatherHTML;
	}else{
		if(not structkeyexists(request, 'zLastWeatherLookup')){
			request.zLastWeatherLookup=deserializeJson(application.zcore.functions.zreadfile(request.zos.globals.serverprivatehomedir&"_cache/html/weather/#arguments.ss.zip#-#ctemp#v2.html"));
		}
		if(not isstruct(request.zLastWeatherLookup) or not structkeyexists(request.zLastWeatherLookup, 'weatherHTML')){
			request.zLastWeatherLookup={};
			request.zLastWeatherLookup.temperature=application.zcore.functions.zso(request.zLastWeatherLookup, 'temperature');
			return "";
		}else{
			request.zLastWeatherLookup.temperature=application.zcore.functions.zso(request.zLastWeatherLookup, 'temperature');
			return request.zLastWeatherLookup.weatherHTML;	
		}
	}
	</cfscript> 
	<!--- <cfsavecontent variable="weatherHTML"><cfif arguments.ss.overrideStyles EQ false><style type="text/css">
.zweather-body{ float:left; width:280px; line-height:13px; font-size:11px; font-weight:bold; }
.zweather-current{ float:left; font-size:14px; line-height:18px; margin-top:5px; margin-left:10px; font-weight:bold; }
.zweather-yahoo{ font-size:10px; font-weight:normal; text-decoration:underline; }
.zweather-divider, .zweather-divider2{ width:100%; height:1px; border-bottom:1px solid ##666666; float:left; margin-top:5px; margin-bottom:5px; }
.zweather-image{ float:left; }
</style></cfif><div class="zweather-body" style="<cfif arguments.ss.forecastLink>cursor:pointer;</cfif>" <cfif arguments.ss.forecastLink>onClick="var newWindow = window.open('http://weather.yahoo.com/forecast/#arguments.ss.zip#_f.html', '_blank');newWindow.focus(); "</cfif>>#request.zLastWeatherLookup.weatherHTML#</div></cfsavecontent>
	<cfscript>
	return weatherHTML;
	</cfscript> --->
</cffunction>




<cffunction name="zGetUPSRates" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var arrError=0;
	var ts=StructNew();
	var rs=structnew();
	var ts2=structnew();
	var i=0;
	var r=0;
	var r2=0;
	var g=0;
	var txml="";
	var theXML="";
	var error="";
	var arrService=0;
	var total="";
	var code="";
	var cfhttp=0;
	
	rs.error="";
	rs.success=true;
	ts.debug=false;
	ts.arrPackage=arraynew(1);
	structappend(arguments.ss,ts,false);
	if(arguments.ss.debug){
		// georgia sales tax test
		arguments.ss.accessLicenseNumber="";
		arguments.ss.userId="";
		arguments.ss.password="";
		arguments.ss.shipper.name="Test Customer";
		arguments.ss.shipper.phone="123-123-1234";
		arguments.ss.shipper.shippernumber="7y615x";
		arguments.ss.shipper.addressline1="1 Main St";
		arguments.ss.shipper.addressline2="";
		arguments.ss.shipper.city="Daytona Beach";
		arguments.ss.shipper.state="FL";
		arguments.ss.shipper.postalcode="32174";
		arguments.ss.shipper.countrycode="US";
		arguments.ss.from.companyname="Test Customer";
		arguments.ss.from.phone="1 Main St";
		arguments.ss.from.addressline1="Daytona Beach";
		arguments.ss.from.addressline2="";
		arguments.ss.from.city="Ormond Beach";
		arguments.ss.from.state="FL";
		arguments.ss.from.postalcode="32174";
		arguments.ss.from.countrycode="US";
		arguments.ss.to.companyname="Test Customer2";
		arguments.ss.to.addressline1="181 Tammen Drive";
		arguments.ss.to.addressline2="";
		arguments.ss.to.city="Blue Ridge";
		arguments.ss.to.state="GA";
		arguments.ss.to.postalcode="30513";
		arguments.ss.to.countrycode="US";
	}
	ts2.accessLicenseNumber=false;
	ts2.userId=false;
	ts2.password=false;
	ts2.shipper.name=false;
	ts2.shipper.phone=false;
	ts2.shipper.shippernumber=false;
	ts2.shipper.addressline1=false;
	ts2.shipper.addressline2=false;
	ts2.shipper.city=false;
	ts2.shipper.state=false;
	ts2.shipper.postalcode=false;
	ts2.shipper.countrycode=false;
	ts2.from.companyname=false;
	ts2.from.phone=false;
	ts2.from.addressline1=false;
	ts2.from.addressline2=false;
	ts2.from.city=false;
	ts2.from.state=false;
	ts2.from.postalcode=false;
	ts2.from.countrycode=false;
	ts2.to.companyname="Shipping Name/Company";
	ts2.to.addressline1="Shipping Address Line 1";
	ts2.to.addressline2="Shipping Address Line 2";
	ts2.to.city="Shipping City";
	ts2.to.state="Shipping State";
	ts2.to.postalcode="Shipping Zip";
	ts2.to.countrycode="Shipping Country";
	arrError=arraynew(1);
	for(i in ts2){
		if(isstruct(ts2[i])){
			for(g in ts2[i]){
				if(isDefined('arguments.ss.#i#.#g#') EQ false){
					if(ts2[i][g] EQ false){
						application.zcore.template.fail("Error: zGetUPSRates(): arguments.ss.#i#.#g# is required.");
					}else{
						arrayappend(arrError,ts2[i][g]&" is required");
					}
				}
			}
		}else{
			if(isDefined('arguments.ss.#i#') EQ false){
				if(ts2[i] EQ false){
					application.zcore.template.fail("Error: zGetUPSRates(): arguments.ss.#i# is required.");
				}else{
					arrayappend(arrError,ts2[i]&" is required");
				}
			}
		}
	}
	if(arraylen(arguments.ss.arrPackage) EQ 0){
		application.zcore.template.fail("There must be at least one package in the array, arguments.ss.arrPackage");
	}
	if(arraylen(arrError) NEQ 0){ 
		rs.error=arraytolist(arrError,"<br />");
		rs.success=false;
		return rs;
	}
	</cfscript>


<cfsavecontent variable="theXML"><?xml version="1.0"?>
<AccessRequest xml:lang="en-US">
	<AccessLicenseNumber>#arguments.ss.accessLicenseNumber#</AccessLicenseNumber>
	<UserId>#arguments.ss.userId#</UserId>
	<Password>#arguments.ss.password#</Password>
</AccessRequest>
<?xml version="1.0"?>
<RatingServiceSelectionRequest xml:lang="en-US">
  <Request>
	<TransactionReference>
	  <CustomerContext>Rating and Service</CustomerContext>
	  <XpciVersion>1.0</XpciVersion>
	</TransactionReference>
	<RequestAction>Rate</RequestAction>
	<RequestOption>Shop</RequestOption>
  </Request>
	<PickupType>
	<Code>07</Code>
	<Description>Rate</Description>
	</PickupType>
  <Shipment>
	<Description>Rate Description</Description>
	<Shipper>
	  <Name>#arguments.ss.shipper.name#</Name>
	  <PhoneNumber>#arguments.ss.shipper.phone#</PhoneNumber>
	  <ShipperNumber>#arguments.ss.shipper.shippernumber#</ShipperNumber>
	  <Address>
		<AddressLine1>#arguments.ss.shipper.addressline1#</AddressLine1>
		<AddressLine2>#arguments.ss.shipper.addressline2#</AddressLine2>
		<City>#arguments.ss.shipper.city#</City>
		<StateProvinceCode>#arguments.ss.shipper.state#</StateProvinceCode>
		<PostalCode>#arguments.ss.shipper.postalcode#</PostalCode> 
		<CountryCode>#arguments.ss.shipper.countrycode#</CountryCode>
	  </Address>
	</Shipper>
	<ShipTo>
	  <CompanyName>#arguments.ss.to.companyname#</CompanyName>
	  <PhoneNumber />
	  <Address>
		<AddressLine1>#arguments.ss.to.addressline1#</AddressLine1>
		<AddressLine2>#arguments.ss.to.addressline2#</AddressLine2>
		<City>#arguments.ss.to.city#</City>
		<StateProvinceCode>#arguments.ss.to.state#</StateProvinceCode>
		<PostalCode>#arguments.ss.to.postalcode#</PostalCode> 
		<CountryCode>#arguments.ss.to.countrycode#</CountryCode>
	  </Address>
	</ShipTo>
	<ShipFrom>
	  <CompanyName>#arguments.ss.from.companyname#</CompanyName>
	  <AttentionName />
	  <PhoneNumber>#arguments.ss.from.phone#</PhoneNumber>
	  <FaxNumber />
	  <Address>
		<AddressLine1>#arguments.ss.from.addressline1#</AddressLine1>
		<AddressLine2>#arguments.ss.from.addressline2#</AddressLine2>
		<City>#arguments.ss.from.city#</City>
		<StateProvinceCode>#arguments.ss.from.state#</StateProvinceCode>
		<PostalCode>#arguments.ss.from.postalcode#</PostalCode> 
		<CountryCode>#arguments.ss.from.countrycode#</CountryCode>
	  </Address>
	</ShipFrom>
	<Service>
			<Code>03</Code>
	</Service>
	<PaymentInformation>
			<Prepaid>
				<BillShipper>
					<AccountNumber>Ship Number</AccountNumber>
				</BillShipper>
			</Prepaid>
	</PaymentInformation>
	<cfloop from="1" to="#arraylen(arguments.ss.arrPackage)#" index="i">
		<cftry>
		<Package>
			<PackagingType>
				<Code>00</Code>
			</PackagingType>
			<Dimensions>
				<Width>#arguments.ss.arrPackage[i].width#</Width>
				<Height>#arguments.ss.arrPackage[i].height#</Height>
				<Length>#arguments.ss.arrPackage[i].length#</Length>
				<UnitOfMeasurement>
				  <Code>IN</Code>
				</UnitOfMeasurement>
			</Dimensions>
			<Description>Rate</Description>
			<PackageWeight>
				<UnitOfMeasurement>
				  <Code>LBS</Code>
				</UnitOfMeasurement>
				<Weight>#arguments.ss.arrPackage[i].weight#</Weight>
			</PackageWeight>   
		</Package>
		<cfcatch type="any"><cfscript>
		application.zcore.template.fail('zGetUpsRats(): Invalid package format.  Each package must have width, height, length and weight like this:<br />ts.arrPackage=arraynew(1);<br />t2=structnew();<br />t2.width="10";<br />t2.height="15";<br />t2.length="10";<br />t2.weight="5";<br />arrayappend(ts.arrPackage,t2); ');
		</cfscript></cfcatch></cftry>
	</cfloop>
	<ShipmentServiceOptions>
	  <OnCallAir>
		<Schedule> 
			<PickupDay>02</PickupDay>
			<Method>02</Method>
		</Schedule>
	  </OnCallAir>
	</ShipmentServiceOptions>
  </Shipment>
</RatingServiceSelectionRequest></cfsavecontent>
	<cfhttp url="https://wwwcie.ups.com/ups.app/xml/Rate" method="post" charset="utf-8" timeout="10" throwonerror="no">
		<cfhttpparam type="Header" name="Accept-Encoding" value="#request.httpCompressionType#">
		<cfhttpparam type="Header" name="TE" value="#request.httpCompressionType#">
		<cfhttpparam type="xml" value="#theXML#"></cfhttp>
	<cfscript>
	if(cfhttp.statuscode CONTAINS "200"){
		r=cfhttp.FileContent;
		r=xmlparse(r);
		if(arguments.ss.debug){
			rs.requestXML=thexml;
			rs.responseXML=cfhttp.FileContent;
		}
	}
	</cfscript>
	<cfif isDefined('r.RatingServiceSelectionResponse.Response.ResponseStatusCode.XMLText') EQ false or r.RatingServiceSelectionResponse.Response.ResponseStatusCode.XMLText NEQ 1>
		<cfscript>
		error="";
		if(isDefined('r.RatingServiceSelectionResponse.Response.error.errordescription.xmltext')){
			error=r.RatingServiceSelectionResponse.Response.error.errordescription.xmltext;
		}
		if(error EQ ''){
			error="Unknown Error Occurred, Please verify your information and try again later.";
		}
		</cfscript>
		<cfmail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" charset="utf-8" subject="UPS Rate Check Error" type="html">
		#application.zcore.functions.zHTMLDoctype()#
	<head><title>UPS Error</title></head><body>
		<span style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px; line-height:18px;">
		UPS Rate Check Error:<br /><br />
		XML Request:<br />
		#htmlcodeformat(theXML)#
		<br /><br />
		XML Response:<br />
		#htmlcodeformat(r)#
		</span></body></html>
		</cfmail>
		<cfscript>
		rs.error=error;
		rs.success=false;
		return rs;
		</cfscript>
	</cfif>
	   <!---  #zdump(r)# --->
	<cfscript>
	arrService=structnew();
	arrService[""]="UPS Shipping";
	arrService["01"]="UPS Next Day Air&reg;";
	arrService["02"]="UPS Second Day Air&reg;";
	arrService["03"]="UPS Ground";
	arrService["12"]="UPS Three-Day Select&reg;";
	arrService["13"]="UPS Next Day Air Saver&reg;";
	arrService["14"]="UPS Next Day Air&reg; Early A.M. SM";
	arrService["59"]="UPS Second Day Air A.M.&reg;";
	arrService["65"]="UPS Saver";
	arrService["01"]="UPS Next Day Air&reg;";
	arrService["02"]="UPS Second Day Air&reg;";
	arrService["03"]="UPS Ground";
	arrService["07"]="UPS Worldwide ExpressSM";
	arrService["08"]="UPS Worldwide ExpeditedSM";
	arrService["11"]="UPS Standard";
	arrService["12"]="UPS Three-Day Select&reg;";
	arrService["14"]="UPS Next Day Air&reg; Early A.M. SM";
	arrService["54"]="UPS Worldwide Express PlusSM";
	arrService["59"]="UPS Second Day Air A.M.&reg;";
	arrService["65"]="UPS Saver";
	arrService["01"]="UPS Next Day Air&reg;";
	arrService["02"]="UPS Second Day Air&reg;";
	arrService["03"]="UPS Ground";
	arrService["07"]="UPS Worldwide ExpressSM";
	arrService["08"]="UPS Worldwide ExpeditedSM";
	arrService["14"]="UPS Next Day Air&reg; Early A.M. SM";
	arrService["54"]="UPS Worldwide Express PlusSM";
	arrService["65"]="UPS Saver";
	arrService["01"]="UPS Express";
	arrService["02"]="UPS ExpeditedSM";
	arrService["07"]="UPS Worldwide ExpressSM";
	arrService["08"]="UPS Worldwide ExpeditedSM";
	arrService["11"]="UPS Standard";
	arrService["12"]="UPS Three-Day Select&reg;";
	arrService["13"]="UPS Saver";
	arrService["14"]="UPS Express Early A.M. SM";
	arrService["54"]="UPS Worldwide Express PlusSM";
	arrService["65"]="UPS Saver";
	arrService["07"]="UPS Express";
	arrService["08"]="UPS ExpeditedSM";
	arrService["54"]="UPS Express Plus";
	arrService["65"]="UPS Saver";
	arrService["07"]="UPS Express";
	arrService["08"]="UPS ExpeditedSM";
	arrService["11"]="UPS Standard";
	arrService["54"]="UPS Worldwide Express PlusSM";
	arrService["65"]="UPS Saver";
	arrService["82"]="UPS Today StandardSM";
	arrService["83"]="UPS Today Dedicated CourrierSM";
	arrService["84"]="UPS Today Intercity";
	arrService["85"]="UPS Today Express";
	arrService["86"]="UPS Today Express Saver";
	arrService["07"]="UPS Express";
	arrService["08"]="UPS ExpeditedSM";
	arrService["11"]="UPS Standard";
	arrService["54"]="UPS Worldwide Express PlusSM";
	arrService["65"]="UPS Saver";
	arrService["07"]="UPS Express";
	arrService["08"]="UPS Worldwide ExpeditedSM";
	arrService["11"]="UPS Standard";
	arrService["54"]="UPS Worldwide Express PlusSM";
	arrService["65"]="UPS Saver";
	arrService["TDCB"]="Trade Direct Cross Border";
	arrService["TDA"]="Trade Direct Air";
	arrService["TDO"]="Trade Direct Ocean";
	arrService["308"]="UPS Freight LTL";
	arrService["309"]="UPS Freight LTL Guaranteed";
	arrService["310"]="UPS Freight LTL Urgent";
	
	r2=r.RatingServiceSelectionResponse.RatedShipment;
	rs.arrServiceLabel=arraynew(1);
	rs.arrServiceValue=arraynew(1);
	for(i=1;i LTE arraylen(r2);i++){
		total=r2[i].totalcharges.monetaryvalue.xmltext;
		code=trim(r2[i].service.code.xmltext);
		if(structkeyexists(arrService,code)){
			arrayappend(rs.arrServiceLabel,arrService[code]&" ("&dollarformat(total)&")");
			arrayappend(rs.arrServiceValue,total);
		}
	}
	return rs;
	</cfscript>
</cffunction>


<cffunction name="zDisplayRSSFeed" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	if(not ss.success){
		echo('News feed temporarily unavailable.  ');
		if(request.zos.isTestServer or request.zos.isDeveloper){
			echo(" | Error message:"&ss.errorMessage);
		}
		return;
	} 
	</cfscript> 
	<cfloop index="x" from="1" to="#ArrayLen(ss.arrData)#">
		<cfscript>
		c=ss.arrData[x];

		noHTML=application.zcore.functions.zStripHTMLTags(c.description);
		summary=application.zcore.functions.zLimitStringLength(noHTML, 250); 
		</cfscript>
		<div class="zRssFeedItem"> 
			<div style="width:100%; float:left;">
				<h2 class="zRssHeading"><a href="#c.link#" target="_blank">#c.title#</a></h2>
			</div>
			<div id="zRssSummary#x#" class="zRssSummary" style="  width:100%; float:left;">
			<p>#summary#</p> 
			</div>
			<!---
			<div id="zRssDescription#x#" style="display:none; width:100%; float:left;">
				#c.description#
			</div> --->
			<p><a href="#c.link#" target="_blank" class="zRssReadMore" data-id="#x#">Read More</a></p>

		</div>		
	
	</cfloop> 
			<!---
	<script type="text/javascript">
	zArrDeferredFunctions.push(function(){
		$(".zRssReadMore").bind("click", function(){
			var id=$(this).attr("data-id");
			$("##zRssSummary"+id).hide();
			$("##zRssDescription"+id).show();
			return false;
		});

	});
	</script>--->
</cffunction>


<!--- 
ts={};
ts.name="blog";
ts.url="http://www.blog.com/link.xml";
ts.cacheSeconds=3600;
// optional
ts.limit=0;
ts.filterCFC=request.zRootCFCPath&"mvc.controller.blog";
ts.filterMethod="rssFilter";
rs=application.zcore.functions.zGetRSSFeed(ts);
if(rs.success){
	for(x=1;x LTE arraylen(rs.arrData);x++){
		c=arrData[x];
		echo('<a href="#c.link#" target="_blank">'&echo(c.title)&'</a>');
		echo(c.description);
	}
}
 --->
<cffunction name="zGetRSSFeed" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes"> 
	<cfscript>
	ss=arguments.ss;
	rs={success:true};
	found=false; 
	limit=application.zcore.functions.zso(ss, 'limit', true, 0);
	feedFileName=application.zcore.functions.zURLEncode(ss.name, '-');
	if(fileexists(request.zos.globals.privatehomedir&feedFileName&".xml") and structkeyexists(form, 'zForceRSSDownload') EQ false){
		directory action="list" directory="#request.zos.globals.privatehomedir#" filter="#feedFileName#.xml" name="fileInfo";
		fileDate = parseDateTime(fileInfo.dateLastModified);
		if(dateDiff("s", fileDate, now()) GT ss.cacheSeconds){
			found=false;
		}else{
			found=true;
			x=application.zcore.functions.zreadfile(request.zos.globals.privatehomedir&feedFileName&".xml");
		}

	}
	if(found EQ false){
		try{
			http url="#ss.url#" method="GET" timeout="5" throwonerror="yes" resolveurl="yes"{ }; 
		}catch(Any e){ 
			rs.success=false;
			rs.errorMessage="Failed to download feed";
			return rs;
				
		}
		if(cfhttp.FileContent NEQ "Connection Timeout"){
		    application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&feedFileName&".xml", cfhttp.FileContent);
		}else{
			rs.success=false;
			rs.errorMessage="Connection timeout for #ss.url#";
			return rs;
		}
		x=cfhttp.filecontent;
	}
	x=rereplace(x, "<!-- .*? --->", "", "all");
	try{
		blogs_xml=XMLParse(x); 
	}catch(Any e){
		rs.success=false;
		rs.errorMessage="Failed to parse xml";
		return rs;
	}
	//rs.xmlStruct=blogs_xml;

	if(structkeyexists(blogs_xml, 'rss') and structkeyexists(blogs_xml.rss, 'xmlattributes') and structkeyexists(blogs_xml.rss.xmlattributes, 'version') and blogs_xml.rss.xmlattributes.version EQ "2.0"){
		arrItems=blogs_xml.rss.channel.item;
		arrData=[];
		for(x=1;x LTE arraylen(arrItems);x++){
			if(limit NEQ 0 and x>limit){
				break;
			}
			c=arrItems[x];
			try{
				ts={
					title:c.title.xmltext,
					link:c.link.xmltext,
					description:""
				}
				if(structkeyexists(c, "description")){
					ts.description=c.description.xmltext;
				}
			}catch(Any e){
				savecontent variable="out"{
					echo("<h2>RSS feed has invalid structure: "&ss.url&"</h2>");
					writedump(c);
					writedump(e);
				}
				throw(out);
			}

			if(structkeyexists(ss, 'filterCFC') and structkeyexists(ss, 'filterMethod')){
				ts=ss.filterCFC[ss.filterMethod](ts);
			}
			arrayAppend(arrData, ts);
		}
		rs.arrData=arrData;
	}else{
		savecontent variable="out"{
			writedump(arguments);
			writedump(blogs_xml);
		}
		throw("RSS Version not implemented: "&out);
	}
	return rs;
	</cfscript>
	
</cffunction>
</cfoutput>
</cfcomponent>