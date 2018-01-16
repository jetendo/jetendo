<cfcomponent>
<cfoutput>

<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	setting requesttimeout="10000";
	// you must preregister the returnLink at the oauth2 vendor's web site.
	// that is done under Google APIs, credentials, add/edit, then change: Authorized redirect URIs
	// https://console.developers.google.com/apis/credentials

	variables.returnLink=request.zos.globals.domain&"/z/inquiries/admin/google-oauth/return"; 
	</cfscript>
</cffunction> 

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	db=request.zos.queryObject;
	init();
	application.zcore.functions.zStatusHandler(request.zsid);
	scope="https://www.googleapis.com/auth/analytics.readonly https://www.googleapis.com/auth/webmasters.readonly https://www.googleapis.com/auth/adwords";

	//link='https://accounts.google.com/o/oauth2/auth'; 
	link="https://accounts.google.com/o/oauth2/v2/auth"; 

	firstAuthLink="#link#?response_type=code&client_id=#request.zos.googleAnalyticsConfig.clientId#&redirect_uri=#urlencodedformat(variables.returnLink)#&scope=#urlencodedformat(scope)#&prompt=consent&access_type=offline";
/*
some progress on jot signing.  i can't use coldfusion, it must be php or openssl command line
	// issuer=#urlencodedformat(sc.client_email)#&signingAlgorithm=RS256&signingKey=#urlencodedformat(ss.private_key)#
	gmt=DateAdd( "s", GetTimeZoneInfo().UTCTotalOffset, now() );
	gmtOneHourFuture=dateadd("h", 1, DateAdd( "s", GetTimeZoneInfo().UTCTotalOffset, now() ));
	nowSeconds=datediff("s",  DateConvert("local2utc", createdatetime(1970, 1, 1, 0,0,0)), gmt);
	oneHourFromNowSeconds=datediff("s",  DateConvert("local2utc", createdatetime(1970, 1, 1, 0,0,0)), gmt); 
	//A JWT is composed as follows:
	header=toBase64('{"alg":"RS256","typ":"JWT"}');
	claimSet=toBase64('{
	  "iss":request.zos.googleAnalyticsConfig.clientEmail,
	  "scope":scope,
	  "aud":"https://www.googleapis.com/oauth2/v4/token",
	  "exp":oneHourFromNowSeconds, // UTF timestamp 1 hour from now
	  "iat":nowSeconds // UTC timestamp now
	}');
	signature=toBase64('');
	writedump(header);
abort;*/

/*
{Base64url encoded header}.{Base64url encoded claim set}.{Base64url encoded signature}

The base string for the signature is as follows:
{Base64url encoded header}.{Base64url encoded claim set}

php example of openssl signing
//data you want to sign
$data = 'my data';

//create new private and public key
$new_key_pair = openssl_pkey_new(array(
    "private_key_bits" => 2048,
    "private_key_type" => OPENSSL_KEYTYPE_RSA,
));
openssl_pkey_export($new_key_pair, $private_key_pem);

$details = openssl_pkey_get_details($new_key_pair);
$public_key_pem = $details['key'];

//create signature
openssl_sign($data, $signature, $private_key_pem, OPENSSL_ALGO_SHA256);
	*/

	//jwt.encode( somePayload, "RS256", "publicKey", "privateKey" );
	//jwt.decode( jwtToken, "RS256", "publicKey", "privateKey" );

	sc=request.zos.googleAnalyticsConfig.serverLogin;
	// this is for JOT later:
	//firstAuthLink="#link#?response_type=code&client_id=#sc.client_id#&redirect_uri=#urlencodedformat(variables.returnLink)#&scope=#urlencodedformat(scope)#&access_type=offline&assertion=#urlencodedformat(jsonWebToken)#";// &prompt=consent
/*
        $this->auth = new OAuth2([
            'audience' => self::TOKEN_CREDENTIAL_URI,
            'issuer' => $jsonKey['client_email'],
            'scope' => $scope,
            'signingAlgorithm' => 'RS256',
            'signingKey' => $jsonKey['private_key'],
            'sub' => $sub,
            'tokenCredentialUri' => self::TOKEN_CREDENTIAL_URI,
        ]);
	 ts.zos.googleAnalyticsConfig.serverLogin={
        "type": "service_account",
        "project_id": "",
        "private_key_id": "",
        "private_key": "",
        "client_email": "",
        "client_id": "",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://accounts.google.com/o/oauth2/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/jetendo-google-analytics%40jetendo-153519.iam.gserviceaccount.com"
    };*/

	</cfscript>
	<h2>Google API Login</h2>
	<p><a href="#firstAuthLink#">Authenticate with Google</a></p> 
	<!--- <p><a href="/z/inquiries/admin/google-oauth/passwordLogin">Login with password</a></p> --->
	<!--- 
todo: add search console api: POST https://www.googleapis.com/webmasters/v3/sites/http%3A%2F%2Fwww.boomerpower.info%2F/searchAnalytics/query?fields=rows&key=


Google Analytics:
		
	Finding data:
		Search for client 
			Search date range on reporting tab - also notice the date range compare feature on date range.
			Audience -> Overview
					This gives you total sessions, pageviews, bounce rate, time on site and more.
			Acquistion -> All Traffic -> Source/Medium
				In the middle of the page, click Keyword
					Click advanced
						Set to Exclude Keyword, change Contained to Matching RegExp
							Type in pipe delimited list of client name / company / person's name to exclude them.
								Now you have a report of the top organic search keywords.
			Conversions -> Goals -> Overview 
				You can see each lead type here.  Note, the web site database is more accurate since google analytics can be blocked.
	 --->
</cffunction>


<!--- <cffunction name="passwordLogin" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	http url="https://api.oauth2server.com/token" method="post" timeout="10"{
		httpparam type="formfield" name="grant_type" value="password";
		httpparam type="formfield" name="username" value="#request.zos.googleAnalyticsConfig.username#";
		httpparam type="formfield" name="password" value="#request.zos.googleAnalyticsConfig.password#";
		httpparam type="formfield" name="client_id" value="#request.zos.googleAnalyticsConfig.serverLogin.client_id#";
	} 

	writedump(cfhttp);

	if(not isJson(cfhttp.filecontent)){
		writedump(cfhttp.filecontent);
		return;
	}

	js=deserializeJson(cfhttp.filecontent);
	if(structkeyexists(js, 'error')){
		echo("Error:"&js.error);
		return;
	}	
	if(structkeyexists(js, 'access_token')){
		js.access_token;
		application.googleAnalyticsAccessToken=js.access_token;
		application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/reportIndex");
	}else{
		echo('Unknown response:');
		writedump(js);
		abort;
	}
	
    </cfscript>
	
</cffunction> --->

<cffunction name="return" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	form.code=application.zcore.functions.zso(form, 'code');
	//writedump(form);
	//link='https://accounts.google.com/o/oauth2/token';
	link="https://www.googleapis.com/oauth2/v4/token";
	http url="#link#" method="post" timeout="10"{
		httpparam type="formfield" name="grant_type" value="authorization_code";
		httpparam type="formfield" name="code" value="#form.code#";
		httpparam type="formfield" name="redirect_uri" value="#variables.returnLink#";
		httpparam type="formfield" name="client_id" value="#request.zos.googleAnalyticsConfig.clientId#";
		httpparam type="formfield" name="client_secret" value="#request.zos.googleAnalyticsConfig.clientSecret#"; 
	}

	//writedump(cfhttp); 
	/*
	response json is:
	{
	  "access_token": "...", 
	  "token_type": "Bearer", 
	  "expires_in": 3600, 
	  "refresh_token": "..."
	}
	*/ 

	if(not isJson(cfhttp.filecontent)){
		writedump(cfhttp.filecontent);
		return;
	}
	// 401 is expired token
	// 403 is no access to "view"

	js=deserializeJson(cfhttp.filecontent);
	if(structkeyexists(js, 'error')){
		writedump(js.error);
		return;
	}	
	if(structkeyexists(js, 'access_token')){

		application.googleAnalyticsAccessToken=js;
		application.googleAnalyticsAccessToken.loginDatetime=now();
		application.googleAnalyticsAccessToken.expiresDatetime=dateadd("s", js.expires_in, application.googleAnalyticsAccessToken.loginDatetime);
		application.zcore.functions.zWriteFile(request.zos.globals.serverPrivateHomeDir&"googleAccessToken.txt", serializeJson(application.googleAnalyticsAccessToken));
		application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/reportIndex");
	}else{
		echo('Unknown response:');
		writedump(js);
		abort;
	}
 
	</cfscript>
</cffunction>

<cffunction name="reportIndex" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	if(structkeyexists(form, 'googleSearchConsoleCancel')){
		application.googleSearchConsoleCancel=1; 
	}
	if(structkeyexists(form, 'googleAnalyticsOverviewCancel')){
		application.googleAnalyticsOverviewCancel=1; 
	}
	if(structkeyexists(form, 'googleAnalyticsOrganicCancel')){
		application.googleAnalyticsOrganicCancel=1; 
	}
	if(structkeyexists(form, 'googleAnalyticsKeywordCancel')){
		application.googleAnalyticsKeywordCancel=1; 
	}
	if(not structkeyexists(application, 'googleAnalyticsAccessToken')){
		application.zcore.status.setStatus(request.zsid, "Invalid access token", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/index?zsid=#request.zsid#");
	}
	echo("Access Token:<br>");
	writedump(application.googleAnalyticsAccessToken);

	scheduledLink="/z/inquiries/admin/google-oauth/scheduledTask";
	overviewLink="/z/inquiries/admin/google-oauth/overview";
	organicLink="/z/inquiries/admin/google-oauth/organic";
	keywordLink="/z/inquiries/admin/google-oauth/keyword";
	goalLink="/z/inquiries/admin/google-oauth/goal";
	refreshLink="/z/inquiries/admin/google-oauth/refreshToken";
	searchConsoleLink="/z/inquiries/admin/google-oauth/searchConsole";
	</cfscript>
	<p>You can add sid=SITEID&amp;reimport=1 to pull the data again for a specific site.</p>

	<p><a href="/z/inquiries/admin/custom-lead-report/index" target="_blank">View Report</a></p>
	<p><a href="/z/inquiries/admin/google-oauth/revokeToken">Revoke Auth Token</a></p>
	<p><a href="#scheduledLink#" target="_blank">Scheduled Task (Adwords) - Don't run this</a> 

	<h2>Never run more then one of these at a time because Google will start failing and it will be pointless.  They will each take several minutes to finish.</h2>
	<p><a href="#overviewLink#" target="_blank">Google Analytics Main Overview</a> 
		<cfscript>
		s=application.zcore.functions.zso(application, 'googleAnalyticsOverviewStatus');
		</cfscript>
		<cfif s NEQ "">
			(Status: #s# | <a href="/z/inquiries/admin/google-oauth/reportIndex?googleAnalyticsOverviewStatus=1">Cancel</a>)
		</cfif></p>
	<p><a href="#organicLink#" target="_blank">Google Analytics Organic Search</a> 
		<cfscript>
		s=application.zcore.functions.zso(application, 'googleAnalyticsOrganicStatus');
		</cfscript>
		<cfif s NEQ "">
			(Status: #s# | <a href="/z/inquiries/admin/google-oauth/reportIndex?googleAnalyticsOrganicCancel=1">Cancel</a>)
		</cfif></p>
	<p><a href="#keywordLink#" target="_blank">Google Analytics Keywords</a> 
		<cfscript>
		s=application.zcore.functions.zso(application, 'googleAnalyticsKeywordStatus');
		</cfscript>
		<cfif s NEQ "">
			(Status: #s# | <a href="/z/inquiries/admin/google-oauth/reportIndex?googleAnalyticsKeywordCancel=1">Cancel</a>)
		</cfif></p>
	<p><a href="#searchConsoleLink#" target="_blank">Google Webmaster Search Console Keywords</a> 
		<cfscript>
		s=application.zcore.functions.zso(application, 'googleSearchConsoleStatus');
		</cfscript>
		<cfif s NEQ "">
			(Status: #s# | <a href="/z/inquiries/admin/google-oauth/reportIndex?googleSearchConsoleCancel=1">Cancel</a>)
		</cfif> </p> 
	<!--- <p><a href="#goalLink#" target="_blank">Google Analytics Goals</a></p>  --->
	<p><a href="#refreshLink#">Refresh Token (#dateformat(application.googleAnalyticsAccessToken.expiresDatetime, "m/d/yyyy")&" "&timeformat(application.googleAnalyticsAccessToken.expiresDatetime, "h:mm tt")#)</a></p>
	<p><a href="/z/inquiries/admin/google-oauth/index">Authenticate Again</a></p>
</cffunction>

<cffunction name="revokeToken" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	//https://accounts.google.com/o/oauth2/revoke?token=
	http url="https://accounts.google.com/o/oauth2/revoke?token=#application.googleAnalyticsAccessToken.access_token#" method="get" timeout="10"{ 
	}

	//writedump(cfhttp);

	application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/index");
	abort;
	</cfscript>
</cffunction>

<cffunction name="scheduledTask" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isdeveloper and not request.zos.istestserver and not request.zos.isserver){
		application.zcore.functions.z404("Only for servers / developers to run");
	}
	result=checkAccessToken();
	writedump(result);
	if(not result){
		link="#request.zos.globals.serverDomain#/z/inquiries/admin/google-oauth/index";
		throw('Google Access Token has expired.  Please manually authenticate again here: <a href="#link#">#link#</a>');
	}
	// getCampaignReport works for reports
	rs=getCampaignReport();
	// getCampaigns is set to pause campaign - not working yet?
	//rs=getCampaigns();
	if(not rs.success){
		echo(rs.errorMessage);
		abort;
	}
	writedump(rs);
	abort;

	writedump(application.zcore.functions.zso(application, 'googleAnalyticsAccessToken'));
	abort;
	</cfscript>
</cffunction>

<cffunction name="getCampaignReport" localmode="modern" access="public">
	<cfscript>
	campaignId="920259499"; // test campaign
	// Label (field) documentation: https://developers.google.com/adwords/api/docs/appendix/reports/campaign-performance-report

	// more documentation here: https://developers.google.com/adwords/api/docs/guides/reporting

	// working example of all campaign report:
	// response is: "Custom Campaign Performance Report (Aug 1, 2017-Sep 2, 2017)" Campaign ID,Campaign,Campaign state,Impressions,Clicks,Cost,Conversions,Budget 920259499,Search Campaign,enabled,0,0,0,0.00,5000000 Total, --, --,0,0,0,0.00,5000000
	xmlText='<?xml version="1.0" encoding="UTF-8"?>
	<reportDefinition xmlns="https://adwords.google.com/api/adwords/cm/v201708">
  <selector>
<fields>CampaignId</fields>
<fields>CampaignName</fields>
<fields>CampaignStatus</fields>
<fields>Impressions</fields>
<fields>Clicks</fields>
<fields>Cost</fields>
<fields>Conversions</fields> 
<fields>Amount</fields> 
<fields>Date</fields> 
<dateRange>
  <min>20170801</min>
  <max>20170902</max>
</dateRange>
  </selector>
  <reportName>Custom Campaign Performance Report</reportName>
  <reportType>CAMPAIGN_PERFORMANCE_REPORT</reportType>
  <dateRangeType>CUSTOM_DATE</dateRangeType>
  <downloadFormat>CSV</downloadFormat>
</reportDefinition>';

/*
// working example of ad group report
xmlText='<?xml version="1.0" encoding="UTF-8"?>
<reportDefinition xmlns="https://adwords.google.com/api/adwords/cm/v201708">
  <selector>
    <fields>CampaignId</fields>
    <fields>AdGroupId</fields>
    <fields>Impressions</fields>
    <fields>Clicks</fields>
    <fields>Cost</fields>
    <predicates>
      <field>AdGroupStatus</field>
      <operator>IN</operator>
      <values>ENABLED</values>
      <values>PAUSED</values>
    </predicates>
  </selector>
  <reportName>Custom Adgroup Performance Report</reportName>
  <reportType>ADGROUP_PERFORMANCE_REPORT</reportType>
  <dateRangeType>LAST_7_DAYS</dateRangeType>
  <downloadFormat>CSV</downloadFormat>
</reportDefinition>';
*/
/*
this can go in selector to filter the returned data
<predicates>
  <field>AdGroupStatus</field>
  <operator>IN</operator>
  <values>ENABLED</values>
  <values>PAUSED</values>
</predicates>
*/
	debug=false;
	if(debug){
		cfhttp={statuscode:'200 OK', filecontent:'"Custom Campaign Performance Report (Aug 1, 2017-Sep 2, 2017)" Campaign ID,Campaign,Campaign state,Impressions,Clicks,Cost,Conversions,Budget,Day 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-02 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-03 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-05 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-07 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-13 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-17 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-21 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-27 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-09-01 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-09 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-11 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-12 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-16 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-22 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-23 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-24 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-25 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-10 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-14 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-26 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-28 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-30 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-09-02 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-01 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-04 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-06 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-08 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-15 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-18 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-19 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-20 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-29 920259499,Search Campaign,enabled,0,0,0,0.00,5000000,2017-08-31 Total, --, --,0,0,0,0.00,5000000, --'};
	}else{

		apiLink="https://adwords.google.com/api/adwords/reportdownload/v201708";
		http url="#apiLink#" method="post" charset="utf-8" timeout="1000" throwonerror="no"{ 
			httpparam type="Header" name="Authorization" value="Bearer #application.googleAnalyticsAccessToken.access_token#";
			httpparam type="Header" name="developerToken" value="#request.zos.googleAnalyticsConfig.adwordsDeveloperToken#";
			httpparam type="Header" name="clientCustomerId" value="#request.zos.googleAnalyticsConfig.adwordsTestAccount#";
			//httpparam type="Header" name="useRawEnumValues" value="true";
			httpparam type="Header" name="includeZeroImpressions" value="true";
			//httpparam type="Header" name="clientCustomerId" value="#request.zos.googleAnalyticsConfig.adwordsLiveAccount#";
			httpparam type="formfield" name="__rdxml" value="#xmlText#";
			// &__fmt=CSV
		}
	}
	echo('<pre>'&cfhttp.filecontent&'</pre>');
	writedump(cfhttp);
	abort;
	rs={success:true}; 
	if(cfhttp.statuscode CONTAINS "200"){
		r=cfhttp.FileContent; 
		rs.data=xmlparse(r);
		rs.requestXML=arguments.xml;
		rs.responseXML=cfhttp.FileContent;
	}else{
		rs.success=false;
		savecontent variable="out"{
			writedump(arguments.xml);
			writedump(cfhttp);
		}
		rs.errorMessage="HTTP request failed: #arguments.apiLink#"&out;
	} 
	return rs;
	</cfscript>
</cffunction>
	

<cffunction name="getCampaigns" localmode="modern" access="public">
	<cfscript> 
	campaignId="920259499"; // test campaign

	// campaign status can be PAUSED or ENABLED or REMOVED
	// we should not try to change the status for a campaign that is already "REMOVED"
	xmlText='<?xml version="1.0"?>
	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	  <soapenv:Header>
	    <ns1:RequestHeader xmlns:ns1="https://adwords.google.com/api/adwords/cm/v201708" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">
	      #getAdwordsAuthXML()#
	    </ns1:RequestHeader>
	  </soapenv:Header>
	  <soapenv:Body>
	    <mutate xmlns="https://adwords.google.com/api/adwords/cm/v201708">
	      <operations>
	        <operator>SET</operator>
	        <operand>
         		<id>#campaignId#</id> 
	        	<status>ENABLED</status> 
	        </operand>
	      </operations>
	    </mutate> 
	  </soapenv:Body>
	</soapenv:Envelope>';
	//xmlText='<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Header><RequestHeader xmlns="https://adwords.google.com/api/adwords/cm/v201708"><clientCustomerId>#request.zos.googleAnalyticsConfig.adwordsTestAccount#</clientCustomerId><developerToken>#request.zos.googleAnalyticsConfig.adwordsDeveloperToken#</developerToken></RequestHeader></soap:Header><soap:Body><get xmlns="https://adwords.google.com/api/adwords/cm/v201708"><selector><ids>#campaignId#</ids></selector></get></soap:Body></soap:Envelope>';//<authToken>********</authToken>

	/*
LAST_7_DAYS
<dateRange>
  <min>20150201</min>
  <max>20150301</max>
</dateRange>

	  <reportDefinition xmlns="https://adwords.google.com/api/adwords/cm/v201708">
  <selector> 
<dateRange>
  <min>20170901</min>
  <max>20170902</max>
</dateRange>
  </selector>
  <dateRangeType>CUSTOM_DATE</dateRangeType>
</reportDefinition>
	 	<get xmlns="https://adwords.google.com/api/adwords/cm/v201708"><selector><ids>#campaignId#</ids></selector></get>

	    <mutate xmlns="https://adwords.google.com/api/adwords/cm/v201708">
	      <operations>
	        <operator>ADD</operator>
	        <operand>
	          <name>Hello World</name>
	          <status>PAUSED</status>
	          <budget>
	            <budgetId>YOUR_BUDGET_ID</budgetId>
	          </budget>
	          <settings xmlns:ns2="https://adwords.google.com/api/adwords/cm/v201708" xsi:type="ns2:GeoTargetTypeSetting">
	            <positiveGeoTargetType>DONT_CARE</positiveGeoTargetType>
	          </settings>
	          <advertisingChannelType>SEARCH</advertisingChannelType>
	          <networkSetting>
	            <targetGoogleSearch>true</targetGoogleSearch>
	            <targetSearchNetwork>true</targetSearchNetwork>
	            <targetContentNetwork>false</targetContentNetwork>
	          </networkSetting>
	          <biddingStrategyConfiguration>
	            <biddingScheme xmlns:ns4="https://adwords.google.com/api/adwords/cm/v201708" xsi:type="ns4:ManualCpcBiddingScheme">
	              <enhancedCpcEnabled>false</enhancedCpcEnabled>
	            </biddingScheme>
	          </biddingStrategyConfiguration>
	        </operand>
	      </operations>
	    </mutate>



	xmlText='<?xml version="1.0" encoding="utf-8"?><soap:Envelope
xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:xsd="http://www.w3.org/2001/
XMLSchema"><soap:Header><RequestHeader xmlns="https://
adwords.google.com/api/adwords/cm/v201708"><authToken>********</
authToken><clientCustomerId>some number</
clientCustomerId><developerToken>some number</developerToken></
RequestHeader></soap:Header><soap:Body><get xmlns="https://
adwords.google.com/api/adwords/cm/v201708"><selector><ids>9382159670</
ids></selector></get></soap:Body></soap:Envelope>'; */

// Google\AdsApi\AdWords\v201708\cm\CampaignStatus
/*

possibly needed:
$url = "https://www.google.com/accounts/ClientLogin"; 
$params = array( 
   "accountType" => "GOOGLE", 
   "Email" => $username, 
   "Passwd" => $password, 
   "service" => "adwords", 
   "source" => "test" 
); 

define("ADWORDS_API_TOKEN", "YOUR_DEV_TOKEN"); 
$username = "YOUR_USERNAME";
$password = "YOUR_PASSWORD";
$customerId = "123-456-7890";
 
$headers = array( 
   "developerToken" => ADWORDS_API_TOKEN, 
   "userAgent" => "testing", 
   "clientCustomerId" => $customerId,
   "authToken" => $auth 
); 
*/

	rs=doSOAPAPICall('https://adwords.google.com/api/adwords/cm/v201708/CampaignService', xmlText);
	return rs;
	</cfscript>
</cffunction>


<cffunction name="getAndProcessKeywordStats" localmode="modern" access="public">
	<cfargument name="arrKeyword" type="array" required="yes">
	<cfscript>
	arrKeyword=duplicate(arguments.arrKeyword);
	// batch 500 keywords at a time 
	js={
		success:true,
		results:[]
	};
	perpage=700; // google has limit of 800 results from this service
	// google can return up to 700 keyword stats at once, we do 500 here to stay under the limit
	echo(arrayTOList(arrKeyword, "<br>"));
	echo("<br>====GOOGLE RESPONSE BELOW:<br>");
	runCount=ceiling(arrayLen(arrKeyword)/perpage);
	echo('runCount:'&runCount&'<br>');
	for(i2=1;i2<=runCount;i2++){
		application.googleAdwordsAPIStatus="API Call ###i2# request processing: getAndProcessKeywordStats";
		arrNew=[];
		count=arrayLen(arrKeyword);
		for(n=1;n<=min(perpage, count);n++){
			arrayAppend(arrNew, arrKeyword[1]);
			arrayDeleteAt(arrKeyword, 1);
		}
		if(i2 NEQ 1){
			sleep(75000); 
		}
		hasMore=true;
		offset=0;
		while(hasMore){
			try{  
				rs=getKeywordStats(offset, arrNew);
				if(not rs.success){
					js.success=false;
					js.errorResponse=rs;
					return js;
					//return rs;
				}
				application.googleAdwordsAPIStatus="API Call ###i2# response processing with offset: #offset#: getAndProcessKeywordStats";
				//writedump(rs);abort;
				total=rs.data["soap:Envelope"]["soap:Body"].getResponse.rval.totalNumEntries.xmltext;
				if(total EQ 0){
					//echo('total was 0<br>');
					break;
				}
				entries=rs.data["soap:Envelope"]["soap:Body"].getResponse.rval.entries; 
				for(i=1;i<=arraylen(entries);i++){
					t=entries[i].data;  
					t1={}; 

					if(t[1].key.XMLText EQ "KEYWORD_TEXT"){
						t1.keyword=t[1].value.value.xmlText;
					}
					if(t[2].key.XMLText EQ "SEARCH_VOLUME"){
						t1.searchVolume=t[2].value.value.xmlText;
					}  
					echo(t1.keyword&":"&t1.searchVolume&"<br>");
					arrayAppend(js.results, t1);
				}
				offset+=500; 
				if(total < offset){
					hasMore=false;
					break;
				}else{
					sleep(75000); 
				}
			}catch(Any e){
				savecontent variable="out"{
					echo('<h2>Google Adwords API Error Occurred</h2>');
					if(not structkeyexists(local, 'rs')){
						writedump(e);
					}else{
						writedump(rs);
						writedump(e);
					}
				}
				if(request.zos.isDeveloper){
					echo(out);
					abort;
				}else{
					throw(out);
				}
			}
		}
	}
	//echo('stopped');	abort;
	structdelete(application, 'googleAdwordsAPIStatus');
	return js;
	</cfscript>
</cffunction>

<!---  
/z/inquiries/admin/google-oauth/index
/z/inquiries/admin/google-oauth/displayKeywordIdeas
/z/inquiries/admin/google-oauth/displayKeywordStats
 --->
<cffunction name="getAndProcessKeywordIdeas" localmode="modern" access="public">
	<cfargument name="arrKeyword" type="array" required="yes">
	<cfscript>
	arrKeyword=arguments.arrKeyword;
	js={
		success:true,
		results:[]
	};
	perpage=500; // google has limit of 800 results from this service
	// google has limit of 200 seed keywords per ideas request
	runCount=ceiling(arrayLen(arrKeyword)/100); 
	for(i2=1;i2<=runCount;i2++){
		application.googleAdwordsAPIStatus="API Call ###i2# request processing: getAndProcessKeywordIdeas";
		arrNew=[];
		count=arrayLen(arrKeyword);
		for(n=1;n<=min(100, count);n++){
			arrayAppend(arrNew, arrKeyword[1]);
			arrayDeleteAt(arrKeyword, 1);
		}
		if(i2 NEQ 1){
			sleep(3000);
		}
		hasMore=true;
		offset=0;
		while(hasMore){
			try{
				rs=getKeywordIdeas(offset, arrNew); 
				if(not rs.success){
					return rs; 
				} 
				application.googleAdwordsAPIStatus="API Call ###i2# response processing with offset: #offset#: getAndProcessKeywordIdeas";
				total=rs.data["soap:Envelope"]["soap:Body"].getResponse.rval.totalNumEntries.xmltext;
				if(total EQ 0){
					break;
				}
				entries=rs.data["soap:Envelope"]["soap:Body"].getResponse.rval.entries;  
				for(i=1;i<=arraylen(entries);i++){
					t=entries[i].data;  
					t1={}; 
					t1.keyword=t[1].value.value.xmlText;
					t1.keyword=listdeleteat(t1.keyword, listlen(t1.keyword, " "), " ");
					t1.searchVolume=t[2].value.value.xmlText;
					arrayAppend(js.results, t1);
				}
				offset+=500;
				if(total < offset){
					hasMore=false;
					break;
				}else{
					sleep(3000);
				}
			}catch(Any e){
				savecontent variable="out"{
					echo('<h2>Google Adwords API Error Occurred</h2>');
					writedump(rs);
					writedump(e);
				}
				if(request.zos.isDeveloper){
					echo(out);
					abort;
				}else{
					throw(out);
				}
			}
		}
	}
	structdelete(application, 'googleAdwordsAPIStatus');
	return js;
	</cfscript>
</cffunction>


<cffunction name="displayKeywordStats" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	rs=getKeywordStats(0, ["Flights from London to New York", "London Flights"]);
	//rs={success:true, data:xmlparse('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Header><ResponseHeader xmlns:ns2="https://adwords.google.com/api/adwords/cm/v201710" xmlns="https://adwords.google.com/api/adwords/o/v201710"><ns2:requestId>0005619168f967e80ac14c051300f74e</ns2:requestId><ns2:serviceName>TargetingIdeaService</ns2:serviceName><ns2:methodName>get</ns2:methodName><ns2:operations>1</ns2:operations><ns2:responseTime>197</ns2:responseTime></ResponseHeader></soap:Header><soap:Body><getResponse xmlns:ns2="https://adwords.google.com/api/adwords/cm/v201710" xmlns="https://adwords.google.com/api/adwords/o/v201710"><rval><totalNumEntries>2</totalNumEntries><entries><data><key>KEYWORD_TEXT</key><value xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="StringAttribute"><Attribute.Type>StringAttribute</Attribute.Type><value>london flights</value></value></data><data><key>SEARCH_VOLUME</key><value xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="LongAttribute"><Attribute.Type>LongAttribute</Attribute.Type><value>4248747</value></value></data></entries><entries><data><key>KEYWORD_TEXT</key><value xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="StringAttribute"><Attribute.Type>StringAttribute</Attribute.Type><value>flights from london to new york</value></value></data><data><key>SEARCH_VOLUME</key><value xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="LongAttribute"><Attribute.Type>LongAttribute</Attribute.Type><value>3934797</value></value></data></entries></rval></getResponse></soap:Body></soap:Envelope>')};
	if(not rs.success){ 
		echo(rs.errorMessage);		abort;
	}
	//writedump(rs);abort;
	entries=rs.data["soap:Envelope"]["soap:Body"].getResponse.rval.entries;
	//writedump(entries);
	js={
		success:true,
		results:[]
	};
	for(i=1;i<=arraylen(entries);i++){
		t=entries[i].data;  
		t1={}; 

		if(t[1].key.XMLText EQ "KEYWORD_TEXT"){
			t1.keyword=t[1].value.value.xmlText;
		}
		if(t[2].key.XMLText EQ "SEARCH_VOLUME"){
			t1.searchVolume=t[2].value.value.xmlText;
		}  
		arrayAppend(js.results, t1);
	}
	writedump(js);abort;
	</cfscript>
</cffunction>

<!---  
/z/inquiries/admin/google-oauth/index
/z/inquiries/admin/google-oauth/displayKeywordIdeas
/z/inquiries/admin/google-oauth/displayKeywordStats
 --->
<cffunction name="displayKeywordIdeas" localmode="modern" access="remote" roles="administrator"> 
	<cfscript> 

	rs=getKeywordIdeas(0, ["Flights"]);
	// ideas response with searchVolume
	//rs={success:true, data:xmlparse(application.zcore.functions.zreadfile(request.zos.globals.privatehomedir&"googleAdwordsKeywordIdeasResponse.txt")) }; 
	if(not rs.success){ 
		echo(rs.errorMessage);	abort;
	}
	//writedump(rs);abort;
	entries=rs.data["soap:Envelope"]["soap:Body"].getResponse.rval.entries; 
	
	js={
		success:true,
		results:[]
	};
	for(i=1;i<=arraylen(entries);i++){
		t=entries[i].data;  
		t1={}; 
		t1.keyword=t[1].value.value.xmlText;
		t1.keyword=listdeleteat(t1.keyword, listlen(t1.keyword, " "), " ");
		t1.searchVolume=t[2].value.value.xmlText;
		arrayAppend(js.results, t1);
	}
	writedump(js);	abort;
	</cfscript>
</cffunction>

<cffunction name="displayKeywordStatsMonthly" localmode="modern" access="remote" roles="administrator"> 
	<cfscript> 
	//rs=getKeywordStatsMonthly(0, ["Flights from London to New York", "London Flights"]);
	//writedump(rs);abort; 
	// this was a stats response with monthly searches
	rs={success:true, data:xmlparse('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Header><ResponseHeader xmlns:ns2="https://adwords.google.com/api/adwords/cm/v201710" xmlns="https://adwords.google.com/api/adwords/o/v201710"><ns2:requestId>000561906c0814580aec568c680d512d</ns2:requestId><ns2:serviceName>TargetingIdeaService</ns2:serviceName><ns2:methodName>get</ns2:methodName><ns2:operations>1</ns2:operations><ns2:responseTime>226</ns2:responseTime></ResponseHeader></soap:Header><soap:Body><getResponse xmlns:ns2="https://adwords.google.com/api/adwords/cm/v201710" xmlns="https://adwords.google.com/api/adwords/o/v201710"><rval><totalNumEntries>2</totalNumEntries><entries><data><key>KEYWORD_TEXT</key><value xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="StringAttribute"><Attribute.Type>StringAttribute</Attribute.Type><value>london flights</value></value></data><data><key>TARGETED_MONTHLY_SEARCHES</key><value xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="MonthlySearchVolumeAttribute"><Attribute.Type>MonthlySearchVolumeAttribute</Attribute.Type><value><year>2017</year><month>11</month><count>4417788</count></value><value><year>2017</year><month>10</month><count>9836306</count></value><value><year>2017</year><month>9</month><count>8496396</count></value><value><year>2017</year><month>8</month><count>1212821</count></value><value><year>2017</year><month>7</month><count>2911047</count></value><value><year>2017</year><month>6</month><count>5121332</count></value><value><year>2017</year><month>5</month><count>48068</count></value><value><year>2017</year><month>4</month><count>5889451</count></value><value><year>2017</year><month>3</month><count>105440</count></value><value><year>2017</year><month>2</month><count>3994551</count></value><value><year>2017</year><month>1</month><count>8163845</count></value><value><year>2016</year><month>12</month><count>787929</count></value></value></data></entries><entries><data><key>KEYWORD_TEXT</key><value xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="StringAttribute"><Attribute.Type>StringAttribute</Attribute.Type><value>flights from london to new york</value></value></data><data><key>TARGETED_MONTHLY_SEARCHES</key><value xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="MonthlySearchVolumeAttribute"><Attribute.Type>MonthlySearchVolumeAttribute</Attribute.Type><value><year>2017</year><month>11</month><count>8284056</count></value><value><year>2017</year><month>10</month><count>3396650</count></value><value><year>2017</year><month>9</month><count>1813169</count></value><value><year>2017</year><month>8</month><count>7316914</count></value><value><year>2017</year><month>7</month><count>4127112</count></value><value><year>2017</year><month>6</month><count>1422728</count></value><value><year>2017</year><month>5</month><count>6340440</count></value><value><year>2017</year><month>4</month><count>2140069</count></value><value><year>2017</year><month>3</month><count>1430838</count></value><value><year>2017</year><month>2</month><count>7911019</count></value><value><year>2017</year><month>1</month><count>2077186</count></value><value><year>2016</year><month>12</month><count>957383</count></value></value></data></entries></rval></getResponse></soap:Body></soap:Envelope>') };
	// search_volume didn't return anything, so we have to calculate the average ourselves for each term
	if(not rs.success){
		echo(rs.errorMessage);
		abort;
	}
	//writedump(rs);abort;
	//writedump(rs);
	entries=rs.data["soap:Envelope"]["soap:Body"].getResponse.rval.entries;
	//writedump(entries);
	
	js={
		success:true,
		results:[]
	};
	for(i=1;i<=arraylen(entries);i++){
		t=entries[i].data;  
		t1={}; 
		if(entries[i].data[1].key.XMLText EQ "KEYWORD_TEXT"){
			t1.keyword=entries[i].data[1].value.value.xmlText;
			totalVolume=0;
			totalMonths=arraylen(t.value.value);
			for(i3=1;i3<=arraylen(t.value.value);i3++){
				totalVolume+=t.value.value.count.xmlText;
			}
			avgVolume=0;
			if(totalMonths NEQ 0){
				avgVolume=round(totalVolume/totalMonths);
			}
			t1.totalVolume=totalVolume;
			t1.searchVolume=avgVolume;
		}  
		arrayAppend(js.results, t1);
	}
	writedump(js);	abort;
	</cfscript>
</cffunction>


<!--- 
adwordsLiveManagerAccount
 --->
<cffunction name="getAdwordsAuthXML" localmode="modern" access="public">
	<cfscript>
	live=true;
	form.debug=application.zcore.functions.zso(form, 'debug', true, 0);
	if(form.debug){
		live=false;
	}
	</cfscript>
	<cfsavecontent variable="out">
	<cfif live>
		<ns1:clientCustomerId>#request.zos.googleAnalyticsConfig.adwordsLiveAccount#</ns1:clientCustomerId>
		<ns1:developerToken>#request.zos.googleAnalyticsConfig.adwordsDeveloperToken#</ns1:developerToken>
	<cfelse>
		<ns1:clientCustomerId>#request.zos.googleAnalyticsConfig.adwordsTestAccount#</ns1:clientCustomerId>
		<ns1:developerToken>#request.zos.googleAnalyticsConfig.adwordsDeveloperToken#</ns1:developerToken>
	</cfif>
		<ns1:userAgent>Jetendo</ns1:userAgent>
		<ns1:validateOnly>false</ns1:validateOnly>
		<ns1:partialFailure>false</ns1:partialFailure>
	</cfsavecontent>
	<cfscript>
	return out;
	</cfscript>
</cffunction>

<cffunction name="getKeywordIdeas" localmode="modern" access="public">
	<cfargument name="startIndex" type="numeric" required="yes">
	<cfargument name="arrKeyword" type="array" required="yes">
	<cfscript>  
	arrKeyword=arguments.arrKeyword;

	// the ids for language and location come from data posted here: 
	// https://developers.google.com/adwords/api/docs/appendix/codes-formats
	// 1000 is english

	// https://developers.google.com/adwords/api/docs/appendix/geotargeting
	// 2840 is united states

	// limits documented here: https://developers.google.com/adwords/api/docs/appendix/limits

	// campaign status can be PAUSED or ENABLED or REMOVED
	// we should not try to change the status for a campaign that is already "REMOVED"
	xmlText='<?xml version="1.0"?>
	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<soapenv:Header>
		<ns1:RequestHeader xmlns:ns1="https://adwords.google.com/api/adwords/o/v201710" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">
			#getAdwordsAuthXML()#
		</ns1:RequestHeader>
	</soapenv:Header>
	<soapenv:Body>
	      <get xmlns="https://adwords.google.com/api/adwords/o/v201710">
	         <selector>
	            <searchParameters xsi:type="RelatedToQuerySearchParameter">';
	            for(keyword in arrKeyword){
	            	xmlText&='<queries>'&keyword&'</queries>';
	            } 
	            xmlText&='
	            </searchParameters>
	            <searchParameters xsi:type="LanguageSearchParameter">
	               <languages>
	                  <id xmlns="https://adwords.google.com/api/adwords/cm/v201710">1000</id>
	               </languages>
	            </searchParameters>
	           
	            <ideaType>KEYWORD</ideaType>
	            <requestType>IDEAS</requestType>
	            <requestedAttributeTypes>KEYWORD_TEXT</requestedAttributeTypes>
	            <requestedAttributeTypes>KEYWORD_TEXT</requestedAttributeTypes>
	            <requestedAttributeTypes>SEARCH_VOLUME</requestedAttributeTypes>
	            
	            
	            <paging>
	               <startIndex xmlns="https://adwords.google.com/api/adwords/cm/v201710">#arguments.startIndex#</startIndex>
	               <numberResults xmlns="https://adwords.google.com/api/adwords/cm/v201710">500</numberResults>
	            </paging>
	         </selector>
	      </get>
	  </soapenv:Body>
	</soapenv:Envelope>'; 
	/*
	 <searchParameters xsi:type="LocationSearchParameter">
	               <locations>
	                  <id xmlns="https://adwords.google.com/api/adwords/cm/v201710">2840</id>
	               </locations>
	            </searchParameters> 
	            */
	            //<requestType>STATS</requestType>
	//<requestedAttributeTypes>TARGETED_MONTHLY_SEARCHES</requestedAttributeTypes>

	// https://adwords.google.com/api/adwords/o/v201710/TargetingIdeaService?wsdl
	rs=doSOAPAPICall('https://adwords.google.com/api/adwords/o/v201710/TargetingIdeaService', xmlText); 
	return rs;
	</cfscript>
</cffunction>


<cffunction name="getKeywordStats" localmode="modern" access="public">
	<cfargument name="startIndex" type="numeric" required="yes">
	<cfargument name="arrKeyword" type="array" required="yes">
	<cfscript>  
	arrKeyword=arguments.arrKeyword;

	// the ids for language and location come from data posted here: 
	// https://developers.google.com/adwords/api/docs/appendix/codes-formats
	// 1000 is english

	// https://developers.google.com/adwords/api/docs/appendix/geotargeting
	// 2840 is united states

	// limits documented here: https://developers.google.com/adwords/api/docs/appendix/limits

	// campaign status can be PAUSED or ENABLED or REMOVED
	// we should not try to change the status for a campaign that is already "REMOVED"
	arrXML=[];
	arrayAppend(arrXML, '<?xml version="1.0"?>
	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<soapenv:Header>
		<ns1:RequestHeader xmlns:ns1="https://adwords.google.com/api/adwords/o/v201710" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">
			#getAdwordsAuthXML()#
		</ns1:RequestHeader>
	</soapenv:Header>
	<soapenv:Body>
	      <get xmlns="https://adwords.google.com/api/adwords/o/v201710">
	         <selector>
	            <searchParameters xsi:type="RelatedToQuerySearchParameter">');
	            for(keyword in arrKeyword){
	            	arrayAppend(arrXML, '<queries>'&keyword&'</queries>');
	            }
	            arrayAppend(arrXML, '</searchParameters>
	            <searchParameters xsi:type="LanguageSearchParameter">
	               <languages>
	                  <id xmlns="https://adwords.google.com/api/adwords/cm/v201710">1000</id>
	               </languages>
	            </searchParameters>
	            <ideaType>KEYWORD</ideaType>
	            <requestType>STATS</requestType>
	            <requestedAttributeTypes>KEYWORD_TEXT</requestedAttributeTypes>
	            <requestedAttributeTypes>SEARCH_VOLUME</requestedAttributeTypes> 
	            
	            <paging>
	               <startIndex xmlns="https://adwords.google.com/api/adwords/cm/v201710">#arguments.startIndex#</startIndex>
	               <numberResults xmlns="https://adwords.google.com/api/adwords/cm/v201710">500</numberResults>
	            </paging>
	         </selector>
	      </get>
	  </soapenv:Body>
	</soapenv:Envelope>');  

/*

	            <searchParameters xsi:type="LocationSearchParameter">
	               <locations>
	                  <id xmlns="https://adwords.google.com/api/adwords/cm/v201710">2840</id>
	               </locations>
	            </searchParameters>
	            */
	// https://adwords.google.com/api/adwords/o/v201710/TargetingIdeaService?wsdl
	xmlText=arrayToList(arrXML, '');
	rs=doSOAPAPICall('https://adwords.google.com/api/adwords/o/v201710/TargetingIdeaService', xmlText);  
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getKeywordStatsMonthly" localmode="modern" access="public">
	<cfargument name="startIndex" type="numeric" required="yes">
	<cfargument name="arrKeyword" type="array" required="yes">
	<cfscript>  
	arrKeyword=arguments.arrKeyword;

	// the ids for language and location come from data posted here: 
	// https://developers.google.com/adwords/api/docs/appendix/codes-formats
	// 1000 is english

	// https://developers.google.com/adwords/api/docs/appendix/geotargeting
	// 2840 is united states

	// limits documented here: https://developers.google.com/adwords/api/docs/appendix/limits

	// campaign status can be PAUSED or ENABLED or REMOVED
	// we should not try to change the status for a campaign that is already "REMOVED"
	xmlText='<?xml version="1.0"?>
	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<soapenv:Header>
		<ns1:RequestHeader xmlns:ns1="https://adwords.google.com/api/adwords/o/v201710" soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0">
			#getAdwordsAuthXML()#
		</ns1:RequestHeader>
	</soapenv:Header>
	<soapenv:Body>
	      <get xmlns="https://adwords.google.com/api/adwords/o/v201710">
	         <selector>
	            <searchParameters xsi:type="RelatedToQuerySearchParameter">';
	            for(keyword in arrKeyword){
	            	xmlText&='<queries>'&keyword&'</queries>';
	            }
	            xmlText&='
	            </searchParameters>
	            <searchParameters xsi:type="LanguageSearchParameter">
	               <languages>
	                  <id xmlns="https://adwords.google.com/api/adwords/cm/v201710">1000</id>
	               </languages>
	            </searchParameters>
	            <searchParameters xsi:type="LocationSearchParameter">
	               <locations>
	                  <id xmlns="https://adwords.google.com/api/adwords/cm/v201710">2840</id>
	               </locations>
	            </searchParameters>
	            <ideaType>KEYWORD</ideaType>
	            <requestType>STATS</requestType>
	            <requestedAttributeTypes>KEYWORD_TEXT</requestedAttributeTypes>
	            <requestedAttributeTypes>TARGETED_MONTHLY_SEARCHES</requestedAttributeTypes> 
	            
	            <paging>
	               <startIndex xmlns="https://adwords.google.com/api/adwords/cm/v201710">#arguments.startIndex#</startIndex>
	               <numberResults xmlns="https://adwords.google.com/api/adwords/cm/v201710">500</numberResults>
	            </paging>
	         </selector>
	      </get>
	  </soapenv:Body>
	</soapenv:Envelope>'; 
	            //<requestType>STATS</requestType>
	//<requestedAttributeTypes>TARGETED_MONTHLY_SEARCHES</requestedAttributeTypes>

	// https://adwords.google.com/api/adwords/o/v201710/TargetingIdeaService?wsdl
	rs=doSOAPAPICall('https://adwords.google.com/api/adwords/o/v201710/TargetingIdeaService', xmlText); 
	return rs;
	</cfscript>
</cffunction>

<cffunction name="doSOAPAPICall" localmode="modern" access="public">
	<cfargument name="apiLink" type="string" required="yes">
	<cfargument name="xml" type="string" required="yes">
	<cfscript> 
	//basic key: execute up to 10,000 operations and 1,000 report downloads per day
	// standard key: more

	// get counts as 1 operation for one set of data
	// mutate counts as 1 operation per record changed

	// report api doesn't have an operation limit per day, but there is a limit of 1000 reports per day.
	http url="#arguments.apiLink#" method="post" charset="utf-8" timeout="1000" throwonerror="no"{
		httpparam type="Header" name="Content-Type" value="application/soap+xml";
		httpparam type="Header" name="Authorization" value="Bearer #application.googleAnalyticsAccessToken.access_token#";
		httpparam type="xml" value="#arguments.xml#";
	}
	rs={success:true}; 
	if(cfhttp.statuscode CONTAINS "200"){
		r=cfhttp.FileContent; 
		rs.data=xmlparse(r);
		rs.requestXML=arguments.xml;
		rs.responseXML=cfhttp.FileContent;
	}else{
		rs.success=false;
		savecontent variable="out"{
			writedump(arguments.xml);
			writedump(cfhttp);
		}
		rs.errorMessage="HTTP request failed: #arguments.apiLink#"&out;
	} 
	return rs;
	</cfscript>
</cffunction>
	
<!--- /z/inquiries/admin/google-oauth/checkAccessToken --->
<cffunction name="checkAccessToken" localmode="modern" access="public">
	<cfscript>
	if(not structkeyexists(application, 'googleAnalyticsAccessToken')){
		tokenContents=application.zcore.functions.zReadFile(request.zos.globals.serverPrivateHomeDir&"googleAccessToken.txt");
		if(tokenContents NEQ false){
			application.googleAnalyticsAccessToken=deserializeJson(tokenContents);
		}
	}

	if(structkeyexists(application, 'googleAnalyticsAccessToken')){
		d=parsedatetime(dateformat(application.googleAnalyticsAccessToken.expiresDatetime, "yyyy-mm-dd")&" "&timeformat(application.googleAnalyticsAccessToken.expiresDatetime, "HH:mm:ss"));
		secondsRemaining=datediff("s", d, now()); 
		if(secondsRemaining >=-30){
			// execute token refresh 
			http url="https://www.googleapis.com/oauth2/v4/token" method="post" timeout="10"{
				httpparam type="formfield" name="grant_type" value="refresh_token";
				httpparam type="formfield" name="refresh_token" value="#application.googleAnalyticsAccessToken.refresh_token#"; 
				httpparam type="formfield" name="client_id" value="#request.zos.googleAnalyticsConfig.clientId#";
				httpparam type="formfield" name="client_secret" value="#request.zos.googleAnalyticsConfig.clientSecret#"; 
			}
			if(not isJson(cfhttp.filecontent)){
				return false;
			}
			// 401 is expired token
			// 403 is no access to "view"

			js=deserializeJson(cfhttp.filecontent); 
			if(structkeyexists(js, 'error')){
				return false;
			}	
			if(structkeyexists(js, 'access_token')){ 
				application.googleAnalyticsAccessToken.access_token=js.access_token;
				application.googleAnalyticsAccessToken.loginDatetime=now();
				application.googleAnalyticsAccessToken.expiresDatetime=dateadd("s", js.expires_in, application.googleAnalyticsAccessToken.loginDatetime);
				application.zcore.functions.zWriteFile(request.zos.globals.serverPrivateHomeDir&"googleAccessToken.txt", serializeJson(application.googleAnalyticsAccessToken));
				return true;
			}else{
				return false;
			}
		}else{
			return true;
		}
	}
	return false;
	</cfscript>
</cffunction>


<cffunction name="refreshToken" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	form.code=application.zcore.functions.zso(form, 'code');
	if(not structkeyexists(application, 'googleAnalyticsAccessToken')){
		application.zcore.status.setStatus(request.zsid, "You must authenticate with google first.", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/index?zsid=#request.zsid#");
	}
	http url="https://www.googleapis.com/oauth2/v4/token" method="post" timeout="10"{
		httpparam type="formfield" name="grant_type" value="refresh_token";
		httpparam type="formfield" name="refresh_token" value="#application.googleAnalyticsAccessToken.refresh_token#"; 
		httpparam type="formfield" name="client_id" value="#request.zos.googleAnalyticsConfig.clientId#";
		httpparam type="formfield" name="client_secret" value="#request.zos.googleAnalyticsConfig.clientSecret#"; 
	}

	writedump(cfhttp); 
	/*
	response json is:
	{
	  "access_token": "***", 
	  "token_type": "***", 
	  "expires_in": 0
	}
	*/ 

	if(not isJson(cfhttp.filecontent)){
		writedump(cfhttp.filecontent);
		return;
	}
	// 401 is expired token
	// 403 is no access to "view"

	js=deserializeJson(cfhttp.filecontent);
	if(structkeyexists(js, 'error')){
		writedump(js.error);
		return;
	}	
	if(structkeyexists(js, 'access_token')){ 
		application.googleAnalyticsAccessToken.loginDatetime=now();
		application.googleAnalyticsAccessToken.expiresDatetime=dateadd("s", js.expires_in, application.googleAnalyticsAccessToken.loginDatetime);

		// TODO: don't need to redirect when this is done
		application.zcore.functions.zRedirect("/z/inquiries/admin/google-oauth/reportIndex");
	}else{
		echo('Unknown response:');
		writedump(js);
		abort;
	}
	</cfscript>
</cffunction>
 

<cffunction name="doAPICall" localmode="modern" access="public">
	<cfargument name="jsonStruct" type="struct" required="yes">
	<cfscript> 
	/*
	limits for read-only:
	10 queries per second per user - can send userIp, if multiple users
	50,000 requests per day.
	*/

 	link='https://analyticsreporting.googleapis.com/v4/reports:batchGet?access_token=#application.googleAnalyticsAccessToken.access_token#&alt=json';
 	//echo(link);
 	jsonString=serializeJson(arguments.jsonStruct); 
	jsonString=application.zcore.functions.zHttpJsonPost(link, jsonString, 20);
	
	if(jsonString EQ false or not isJson(jsonString)){
		throw(jsonString);
	}
	js=deserializeJson(jsonString); 
	if(structkeyexists(js, 'error')){
		savecontent variable="out"{
			echo('API Call Failure.  Input:');
			writedump(jsonStruct);
			echo('Response:');
			writedump(js.error);
		}
		throw(out);
	}
	return js;
	</cfscript>
</cffunction>

<cffunction name="searchConsole" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	init();
	db=request.zos.queryObject;
	/*
	Limits: 5 queries per second  200 queries per minute 
	documentation: https://developers.google.com/webmaster-tools/v3/searchanalytics/query#dimensionFilterGroups.filters.dimension
	*/

	// force ricerose for now: 
	if(request.zos.isTestServer){
		form.sid=298;
	}else{
		//form.sid=422;
	} 

	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_google_search_console_domain<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	qSite=db.execute("qSite");     

 	for(row in qSite){
		startMonthDate=dateformat(dateadd("d", -90, now()), "yyyy-mm-")&"01";
		endDate=dateformat(dateadd("d", -1, dateadd("m", 1, startMonthDate)), "yyyy-mm-dd");

		for(n2=1;n2<=3;n2++){  
			if(structkeyexists(application, 'googleSearchConsoleCancel')){
				application.googleSearchConsoleStatus="";
				structdelete(application, 'googleSearchConsoleCancel');
				echo('Cancelled');
				abort;
			}
			application.googleSearchConsoleStatus="Processing #row.site_short_domain# at #startMonthDate# to #endDate#";
			link="https://www.googleapis.com/webmasters/v3/sites/#urlencodedformat(row.site_google_search_console_domain)#/searchAnalytics/query?access_token=#application.googleAnalyticsAccessToken.access_token#&alt=json&fields=rows";
			jsonStruct={
				"startDate": startMonthDate,
				"endDate": endDate,
				"dimensions": [
					"query"
				]
			};
		 	jsonString=serializeJson(jsonStruct); 
			jsonString=application.zcore.functions.zHttpJsonPost(link, jsonString, 20);
			
			if(jsonString EQ false or not isJson(jsonString)){
				throw(jsonString);
			}
			js=deserializeJson(jsonString); 
			if(structkeyexists(js, 'error')){
				savecontent variable="out"{
					echo('API Call Failure.  Input:');
					writedump(jsonStruct);
					echo('Response:');
					writedump(js.error);
				}
				throw(out);
			} 
			// writedump(js);abort;

			//abort;
			/*
			json response is:
			{
			 "rows": [
			  {
			   "keys": [
			    "baby boomer gifts"
			   ],
			   "clicks": 0,
			   "impressions": 6,
			   "ctr": 0,
			   "position": 33.166666666666664
			  },
			  {
			   "keys": [
			    "young martin o malley"
			   ],
			   "clicks": 0,
			   "impressions": 2,
			   "ctr": 0,
			   "position": 1
			  }
			 ]
			}
			*/
			arrData=[]; 
			if(not structkeyexists(js, 'rows')){
				echo('Search console returned no data for #row.site_short_domain# | #startMonthDate# to #endDate#<br>'); 
				startMonthDate=dateFormat(dateadd("m", 1, startMonthDate), "yyyy-mm-dd");
				endDate=dateformat(dateadd("m", 1, endDate), "yyyy-mm-dd");
				continue;
			}
			for(n=1;n<=arraylen(js.rows);n++){
				ds=js.rows[n]; 
				ts={};
				ts.ga_month_keyword_keyword=ds.keys[1];
				ts.ga_month_keyword_type=2; // 1 is google analytics, 2 is webmaster tool search analytics
				ts.ga_month_keyword_visits=ds.clicks;
				ts.ga_month_keyword_impressions=ds.impressions;
				ts.ga_month_keyword_ctr=ds.ctr;
				ts.ga_month_keyword_position=ds.position;
				ts.ga_month_keyword_date=startMonthDate;
				ts.ga_month_keyword_updated_datetime=request.zos.mysqlnow;
				ts.ga_month_keyword_deleted=0;
				ts.site_id=row.site_id;
		 
				// TODO: consider optimizing this to track the last import date somewhere, so we only need to compare the new data to reduce the amount of queries that run.
				db.sql="select * from #db.table("ga_month_keyword", request.zos.zcoreDatasource)# 
				WHERE site_id = #db.param(ts.site_id)# and 
				ga_month_keyword_deleted=#db.param(0)# and 
				ga_month_keyword_date=#db.param(dateformat(startMonthDate, "yyyy-mm-dd"))# and 
				ga_month_keyword_keyword=#db.param(ts.ga_month_keyword_keyword)# and
				ga_month_keyword_type=#db.param(ts.ga_month_keyword_type)#";
				qRank=db.execute("qRank"); 
				/*writedump(qRank);
				writedump(ts);
				abort;*/
				// only import new records
				ts2={
					table:"ga_month_keyword",
					datasource:request.zos.zcoreDatasource,
					struct:ts 
				}; 
				if(qRank.recordcount EQ 0){
					ga_month_keyword_id=application.zcore.functions.zInsert(ts2); 
				}else{
					ts2.struct.ga_month_keyword_id=qRank.ga_month_keyword_id;
					application.zcore.functions.zUpdate(ts2);
				}   
			} 
			echo('Processed search console for #row.site_short_domain# | #startMonthDate# to #endDate#<br>'); 
			startMonthDate=dateFormat(dateadd("m", 1, startMonthDate), "yyyy-mm-dd");
			endDate=dateformat(dateadd("m", 1, endDate), "yyyy-mm-dd");
			sleep(1000); // sleep to avoid hitting google's api limit
		}
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_google_search_console_last_import_datetime=#db.param(request.zos.mysqlnow)#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate");
	}

	application.googleSearchConsoleStatus="";
	echo('done'); 
	</cfscript>
</cffunction>

<cffunction name="processGASummary" localmode="modern" access="public">
	<cfargument name="ds2" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	ds2=arguments.ds2;  
	js=doAPICall(ds2.js);  
	arrLabel=[
		"Users",
		"Sessions",
		"Visitors", 
		"Visits",
		"Bounces",
		"Pageviews",
		"Visit Bounce Rate",
		"Time On Site",
		"Average Time On Site"
	]; 
	if(not structkeyexists(js, 'reports')){
		echo('missing reports<br>');
		return false;
	}
	for(i=1;i<=arraylen(js.reports);i++){
		rs=js.reports[i];
		if(not structkeyexists(rs.data, 'rows')){
			echo('missing rows<br>');
			return false;
		}
		for(n=1;n<=arraylen(rs.data.rows);n++){
			ds=rs.data.rows[n]; 
			values=ds.metrics[1].values;
			ss={};
			if(arrayLen(ds.dimensions) EQ 2){
				tempMonth=ds.dimensions[2];
			}else{
				tempMonth=ds.dimensions[1];
			}
			ss.month=ds2.startDate;//dateformat(dateadd("m", tempMonth, ds2.startDate), "yyyy-mm-dd");
			for(g=1;g<=arraylen(values);g++){
				ss[arrLabel[g]]=values[g];
			} 
			ts={};
			ts.site_id=ds2.site_id;
			ts.ga_month_date=ss.month;
			ts.ga_month_type=ds2.ga_month_type; // 1 is google everything (overview), 2 is google organic traffic only
			ts.ga_month_users=ss.users;
			ts.ga_month_sessions=ss.sessions;
			ts.ga_month_visitors=ss.visitors;
			ts.ga_month_visits=ss.visits;
			ts.ga_month_bounces=ss.bounces;
			ts.ga_month_pageviews=ss.pageviews;
			ts.ga_month_visit_bounce_rate=ss["Visit Bounce Rate"];
			ts.ga_month_time_on_site=ss["Time On Site"];
			ts.ga_month_average_time_on_site=ss["Average Time On Site"];
			ts.ga_month_updated_datetime=0;
			ts.ga_month_deleted=0; 
	 		//writedump(ts);abort;
			// TODO: consider optimizing this to track the last import date somewhere, so we only need to compare the new data to reduce the amount of queries that run.
			db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
			WHERE site_id = #db.param(ts.site_id)# and 
			ga_month_deleted=#db.param(0)# and 
			ga_month_date=#db.param(dateformat(ts.ga_month_date, "yyyy-mm-dd"))# and  
			ga_month_type=#db.param(ts.ga_month_type)#";
			qRank=db.execute("qRank"); 
			/*writedump(qRank);
			writedump(ts);
			abort;*/
			// only import new records
			ts2={
				table:"ga_month",
				datasource:request.zos.zcoreDatasource,
				struct:ts 
			};  
			/*writedump(qrank);
			writedump(ts);
			abort;*/
			if(qRank.recordcount EQ 0){
				ga_month_id=application.zcore.functions.zInsert(ts2); 
			}else{
				ts2.struct.ga_month_id=qRank.ga_month_id; 
				result=application.zcore.functions.zUpdate(ts2); 
			}    
		}
	} 
	return true;
	</cfscript>
</cffunction>
 
<cffunction name="overview" localmode="modern" access="remote" roles="administrator">
	<cfscript>  
	init();
	db=request.zos.queryObject;
	/*
	documented here: https://developers.google.com/analytics/devguides/reporting/core/v3/common-queries

	dimensions=ga:source,ga:medium
	metrics=ga:sessions,ga:pageviews,ga:sessionDuration,ga:exits
	sort=-ga:sessions

	or

	paid search:
	dimensions=ga:source
	metrics=ga:pageviews,ga:sessionDuration,ga:exits
	filters=ga:medium==cpa,ga:medium==cpc,ga:medium==cpm,ga:medium==cpp,ga:medium==cpv,ga:medium==ppc
	sort=-ga:pageviews
	*/
	if(request.zos.isTestServer){
		form.sid=298;
	}else{
		//form.sid=422;
	} 


	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_google_analytics_view_id<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	qSite=db.execute("qSite"); 

	count=0;
	yearLimit=30; // to avoid infinite loop
	startDate=dateformat(dateadd("yyyy", -1, dateformat(now(), "yyyy-mm")&"-01"), "yyyy-mm-dd"); 
	endDate=dateformat(now(), "yyyy-mm-dd"); 
 	for(row in qSite){
		tempStartDate=startDate;
		tempEndDate=endDate; 

 		tempYearLimit=yearLimit; 
 		// uncomment to force import of all time again
 		//row.site_google_analytics_overview_last_import_datetime="";
 		if(row.site_google_analytics_overview_last_import_datetime NEQ ""){
 			tempYearLimit=1; // only pull current year if we already pulled the past.
 		} 
 		for(g=1;g<=tempYearLimit;g++){
			if(structkeyexists(application, 'googleAnalyticsOverviewCancel')){
				application.googleAnalyticsOverviewStatus="";
				structdelete(application, 'googleAnalyticsOverviewCancel');
				echo('Cancelled');
				abort;
			} 
			application.googleAnalyticsOverviewStatus="Processing #row.site_short_domain# at #tempStartDate# to #tempEndDate#"; 
	 		count++;
			js={
			  "reportRequests":
			  [
			    {
					"viewId": row.site_google_analytics_view_id,
					"dateRanges": [{"startDate": dateFormat(tempStartDate, "yyyy-mm-dd"), "endDate": dateFormat(tempEndDate, "yyyy-mm-dd")}],
			      	"dimensions": [{"name": "ga:nthMonth"}],
		      		"metrics": [ 
		      			// only 10 metrics are allowed in single call 
			      		{"expression": "ga:users"},
		      			{"expression": "ga:sessions"},
						{"expression": "ga:visitors"},
						//{"expression": "ga:newVisits"},
						//{"expression": "ga:percentNewVisits"},
						{"expression": "ga:visits"},
						{"expression": "ga:bounces"},
						{"expression": "ga:pageviews"},
						{"expression": "ga:visitBounceRate"},
						{"expression": "ga:sessionDuration"},
						{"expression": "ga:avgSessionDuration"}
					],
					"orderBys":[
					{
						"fieldName":"ga:nthMonth",
						"orderType":"VALUE",
						"sortOrder":"ASCENDING"
					}],
					"pageToken": "0",
					"pageSize": "10000"
			    }
			  ]
			}; 
			ds={};
			ds.js=js;
			ds.site_short_domain=row.site_short_domain;
			ds.site_id=row.site_id;
			ds.startDate=tempStartDate;
			ds.ga_month_type=1; 
			result=processGASummary(ds);
			if(result EQ false){
				echo('stopped google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
				break;
			}
			echo('processed google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
			tempStartDate=dateformat(dateadd("yyyy", -1, tempStartDate), "yyyy-mm-dd"); 
			tempEndDate=dateformat(dateadd("yyyy", -1, tempEndDate), "yyyy-mm-dd"); 
			sleep(1000); // sleep to avoid hitting google's api limit
			if(dateformat(tempStartDate, "yyyymmdd") < 20050101){
				echo('stopped google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
				break;
			} 
		}
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_google_analytics_overview_last_import_datetime=#db.param(request.zos.mysqlnow)#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate"); 
	}

	application.googleAnalyticsOverviewStatus="";
	echo('done: #count#');
	abort;
	</cfscript> 
</cffunction>


<cffunction name="channelGoalReport" localmode="modern" access="remote" roles="administrator">
	<cfscript>  
	init();
	db=request.zos.queryObject;
	/*
	documented here: https://developers.google.com/analytics/devguides/reporting/core/v3/common-queries

	dimensions=ga:source,ga:medium
	metrics=ga:sessions,ga:pageviews,ga:sessionDuration,ga:exits
	sort=-ga:sessions

	or

	paid search:
	dimensions=ga:source
	metrics=ga:pageviews,ga:sessionDuration,ga:exits
	filters=ga:medium==cpa,ga:medium==cpc,ga:medium==cpm,ga:medium==cpp,ga:medium==cpv,ga:medium==ppc
	sort=-ga:pageviews
	*/
	if(request.zos.isTestServer){
		form.sid=298;
	}else{
		//form.sid=422;
	} 


	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_google_analytics_goal_count <> #db.param(0)# and
	site_google_analytics_view_id<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	qSite=db.execute("qSite"); 

	count=0;
	yearLimit=30; // to avoid infinite loop
	startDate=dateformat(dateadd("yyyy", -1, dateformat(now(), "yyyy-mm")&"-01"), "yyyy-mm-dd"); 
	endDate=dateformat(now(), "yyyy-mm-dd"); 
 	for(row in qSite){
 		/*if(count EQ 5){
 			break;
 		}*/
		
		tempStartDate=startDate;
		tempEndDate=endDate; 

	
		/*if(request.zos.isTestServer){
			tempStartDate="2017-09-01";
			tempEndDate="2017-09-30"; 
		}*/
 		count++;
 		tempYearLimit=yearLimit; 
 		// uncomment to force import of all time again
 		//row.site_google_analytics_overview_last_import_datetime="";
 		if(row.site_google_analytics_overview_last_import_datetime NEQ ""){
 			tempYearLimit=1; // only pull current year if we already pulled the past.
 		} 
		var goalMax = row.site_google_analytics_goal_count + (row.site_google_analytics_goal_count mod 4)
 		for(g=1;g<=tempYearLimit;g++){
 			for(h=1; h <= goalMax; h+=4){
				if(structkeyexists(application, 'googleAnalyticsOverviewCancel')){
					application.googleAnalyticsOverviewStatus="";
					structdelete(application, 'googleAnalyticsOverviewCancel');
					echo('Cancelled');
					abort;
				} 
				application.googleAnalyticsOverviewStatus="Processing #row.site_short_domain# at #tempStartDate# to #tempEndDate#"; 
				js={
				  "reportRequests":
				  [
				    {
						"viewId": row.site_google_analytics_view_id,
						"dateRanges": [
							{"startDate": dateFormat(tempStartDate, "yyyy-mm-dd"), 
							"endDate": dateFormat(tempEndDate, "yyyy-mm-dd")
							}
						],
				      	"dimensions": [
				      		{"name": "ga:nthMonth"},
				      		//{"name": "ga:goalCompletionLocation"}
				      		{"name": "ga:source"},
				      		{"name": "ga:channelGrouping"},
				      		//{"name": "ga:acquisitionTrafficChannel"}
				      	],
			      		"metrics": [ 
			      			// only 10 metrics are allowed in single call 
			      			{"expression": "ga:sessions"},
							{"expression": "ga:visits"},
							{"expression": "ga:goal#h#ConversionRate"},	
							{"expression": "ga:goal#h#Completions"},
							{"expression": "ga:goal#h+1#ConversionRate"},	
							{"expression": "ga:goal#h+1#Completions"},
							{"expression": "ga:goal#h+2#ConversionRate"},	
							{"expression": "ga:goal#h+2#Completions"},
							{"expression": "ga:goal#h+3#ConversionRate"},	
							{"expression": "ga:goal#h+3#Completions"}
						],
						//"samplingLevel" : "2",
						"orderBys":[
						{
							"fieldName":"ga:nthMonth",
							"orderType":"VALUE",
							"sortOrder":"ASCENDING"
						}],
						"pageToken": "0",
						"pageSize": "10000"
				    }
				  ]
				}; 
				ds={};
				ds.js=js;
				ds.site_short_domain=row.site_short_domain;
				ds.site_id=row.site_id;
				ds.startDate=tempStartDate;
				ds.ga_month_type=1; 

				result=processChannelGoalReport(ds, row.site_google_analytics_goal_count);
				echo('processed google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate# for goal(s) #h# - #h+3#<br>');
				if(result NEQ true){
					if(result EQ false){
						echo('stopped google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
					}
					break;
				}
				sleep(1000); // sleep to avoid hitting google's api limit
			}
			tempStartDate=dateformat(dateadd("yyyy", -1, tempStartDate), "yyyy-mm-dd"); 
			tempEndDate=dateformat(dateadd("yyyy", -1, tempEndDate), "yyyy-mm-dd"); 
			sleep(1000); // sleep to avoid hitting google's api limit
			if(dateformat(tempStartDate, "yyyymmdd") < 20050101){
				echo('stopped google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
				break;
			} 
		}
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_google_analytics_channel_goal_last_import_datetime=#db.param(request.zos.mysqlnow)#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate"); 
	}

	application.googleAnalyticsOverviewStatus="";
	//echo('done: #count#');
	//abort;
	</cfscript> 
</cffunction>


<cffunction name="processChannelGoalReport" localmode="modern" access="public">
	<cfargument name="ds2" type="struct" required="yes">
	<cfargument name="maxGoals" type="number" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	ds2=arguments.ds2;  
	js=doAPICall(ds2.js);  
	//writedump(js);
	//return;

	if(not structkeyexists(js, 'reports')){
		echo('missing reports<br>');
		return false;
	}
	for(i=1;i<=arraylen(js.reports);i++){
		rs=js.reports[i];
		if(not structkeyexists(rs.data, 'rows')){
			echo('missing rows<br>');
			return false;
		}
		for(n=1;n<=arraylen(rs.data.rows);n++){
			ds=rs.data.rows[n]; 
			values=ds.metrics[1].values;
			ss={};
			tempMonth=ds.dimensions[1];
			ss.site_id=ds2.site_id;
			ss.ga_month_channel_source_goal_date 			= dateformat(dateadd("m", tempMonth, ds2.startDate), "yyyy-mm-dd");
			ss.ga_month_channel_source_goal_source 			= ds.dimensions[2];
			ss.ga_month_channel_source_goal_channel 		= ds.dimensions[3];
			ss.ga_month_channel_source_goal_sessions 		= values[1];
			ss.ga_month_channel_source_goal_visits			= values[2];
			for(g=3; g<=10;g+=2){
				var tmp = rs.columnHeader.metricHeader.metricHeaderEntries[g].name;
				tmp = replaceNoCase(tmp, "ga:goal", "");
				tmp = replaceNoCase(tmp, "ConversionRate", "");
				if(!isNumeric(tmp)){
					echo("ERROR CLEANING " & tmp & " CHECK that token is in the form of ga:goal##ConversionRate <br />");
					return false;
				}
				ss.ga_month_channel_source_goal_name 			= tmp;
				ss.ga_month_channel_source_goal_conversion_rate = values[g];
				ss.ga_month_channel_source_goal_conversions 	= values[g+1];
				db.sql="select * from #db.table("ga_month_channel_source_goal", request.zos.zcoreDatasource)# 
				WHERE site_id = #db.param(ss.site_id)# and 
				ga_month_channel_source_goal_source = #db.param(ds.dimensions[2])# and
				ga_month_channel_source_goal_channel = #db.param(ds.dimensions[3])# and
				ga_month_channel_source_goal_name = #db.param(tmp)# and
				ga_month_channel_source_goal_deleted=#db.param(0)# and 
				ga_month_channel_source_goal_date=#db.param(dateformat(ss.ga_month_channel_source_goal_date, "yyyy-mm-dd"))#";
				qRank=db.execute("qRank");
				//writedump(ss);
				var tsGoal={
					table:"ga_month_channel_source_goal",
					datasource:request.zos.zcoreDatasource,
					struct:ss 
				};  			
				if(qRank.recordcount EQ 0){
					//echo("Zeeeeeeeeeeeeeero <br />");
					ga_month_channel_source_goal_id = application.zcore.functions.zInsert(tsGoal); 
				}else{
					ss.ga_month_channel_source_goal_id = qRank.ga_month_channel_source_goal_id; 
					//echo("Updated <br />");
					application.zcore.functions.zUpdate(tsGoal); 
				}
				var testTmp = LSParseNumber(tmp);
				if(testTmp GT arguments.maxGoals){
					//echo("Processed up to " & testTmp & " <br />"); 
					return 100;
				}
			}
		}
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="organic" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	init();
	db=request.zos.queryObject;
	/* 
	organic search:
	dimensions=ga:source
	metrics=ga:pageviews,ga:sessionDuration,ga:exits
	filters=ga:medium==organic
	sort=-ga:pageviews
	*/ 
	if(request.zos.isTestServer){
		form.sid=298;
	}else{
		//form.sid=422;
	} 

	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_google_analytics_view_id<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	} 
	qSite=db.execute("qSite");  
	startDate=dateformat(dateadd("m", -1, dateformat(now(), "yyyy-mm")&"-01"), "yyyy-mm-dd"); 
	endDate=dateformat(dateadd("d", -1, dateformat(now(), "yyyy-mm")&"-01"), "yyyy-mm-dd");
 
 	count=0;
 	monthSinceGALaunch=datediff("m", "2005-01-01", now());  
 
 	for(row in qSite){
		tempStartDate=startDate;
		tempEndDate=endDate;   
 		// uncomment to force import of all time again
 		//row.site_google_analytics_organic_last_import_datetime="";
		if(row.site_google_analytics_organic_last_import_datetime NEQ "" and not structkeyexists(form, 'reimport')){
			monthSinceGALaunch=2; // only download last 2 months of data
		} 
 		// one month at a time in reverse until nothing is returned?
 		for(g=1;g<=monthSinceGALaunch;g++){   
			if(structkeyexists(application, 'googleAnalyticsOrganicCancel')){
				application.googleAnalyticsOrganicStatus="";
				structdelete(application, 'googleAnalyticsOrganicCancel');
				echo('Cancelled');
				abort;
			} 
			application.googleAnalyticsOrganicStatus="Processing #row.site_short_domain# at #tempStartDate# to #tempEndDate#"; 
 
 			//tempStartDate='2017-01-01';
 			//tempEndDate='2017-01-31';
 			//echo('start:'&tempStartDate&' to '&tempEndDate&'<br>');
 			count++; 
			js={
			  "reportRequests":
			  [
			    {
					"viewId": row.site_google_analytics_view_id,
					"dateRanges": [{"startDate": dateFormat(tempStartDate, "yyyy-mm-dd"), "endDate": dateFormat(tempEndDate, "yyyy-mm-dd")}],
			      	"dimensions": [
			      		{"name": "ga:medium"},
			      		//{"name": "ga:nthMonth"}
			      	],
		      		"metrics": [ 
		      			// only 10 metrics are allowed in single call 
			      		{"expression": "ga:users"},
		      			{"expression": "ga:sessions"},
						{"expression": "ga:visitors"},
						//{"expression": "ga:newVisits"},
						//{"expression": "ga:percentNewVisits"},
						{"expression": "ga:visits"},
						{"expression": "ga:bounces"},
						{"expression": "ga:pageviews"},
						{"expression": "ga:visitBounceRate"},
						{"expression": "ga:sessionDuration"},
						{"expression": "ga:avgSessionDuration"}
					],
					"dimensionFilterClauses": [
			        {
					  //"operator": "AND", // need this, because default with multiple filters is "OR"
			          "filters": [
						{
							"dimensionName":"ga:medium",
							"operator":"EXACT",
							"expressions":["organic"]
						}
						/*,
						{
							"dimensionName":"ga:source",
							"operator":"EXACT",
							"expressions":["google"]
						}*/
						]
					}
					],
					/*"orderBys":[
					{
						"fieldName":"ga:nthMonth",
						"orderType":"VALUE",
						"sortOrder":"ASCENDING"
					}],*/
					//"pageToken": "0",
					//"pageSize": 10000
			    }
			  ]
			};  
			ds={};
			ds.js=js;
			ds.startDate=tempStartDate;
			ds.ga_month_type=2;
			ds.site_id=row.site_id;
			ds.site_short_domain=row.site_short_domain;   
			result=processGASummary(ds);  

			if(result EQ false){
				echo('stopped google analytics organic for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
				break;
			}
			echo('processed google analytics organic for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>'); 
			tempStartDate=dateformat(dateadd("m", -1, tempStartDate), "yyyy-mm-dd"); 
			tempEndDate=dateformat(dateadd("d", -1, dateadd("m", 1, tempStartDate) ), "yyyy-mm-dd");
			if(dateformat(tempStartDate, "yyyymmdd") < 20050101){
				echo('stopped google analytics overview for #row.site_short_domain# at #tempStartDate# to #tempEndDate#<br>');
				break;
			} 
			sleep(1000); // sleep to avoid hitting google's api limit
		} 
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_google_analytics_organic_last_import_datetime=#db.param(request.zos.mysqlnow)#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate"); 
	} 
	application.googleAnalyticsOrganicStatus=""; 
	echo('done');
	abort;
	</cfscript> 
</cffunction>


<cffunction name="keyword" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	init();
	db=request.zos.queryObject;
	// TODO: need unique manually created exclude list for each client to filter out their own brand 
	/*
	dimensions=ga:source,ga:medium
	metrics=ga:sessions,ga:pageviews,ga:sessionDuration,ga:exits
	sort=-ga:sessions
	*/    
	/*
	Limits: 5 queries per second  200 queries per minute 
	documentation: https://developers.google.com/webmaster-tools/v3/searchanalytics/query#dimensionFilterGroups.filters.dimension
	*/

	// force ricerose for now: 
	if(request.zos.isTestServer){
		form.sid=298;
	}else{
		//form.sid=422;
	} 

	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_google_analytics_view_id<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	qSite=db.execute("qSite");    
	// site_google_search_console_last_import_datetime
	startDate=dateformat(now(), "yyyy-mm-")&"01"; 
	endDate=dateformat(dateadd("d", -1, dateadd("m", 1, startDate) ), "yyyy-mm-dd");
 	count=0;
 	monthSinceGALaunch=datediff("m", "2005-01-01", now());
 	for(row in qSite){
		tempStartDate=startDate;
		tempEndDate=endDate; 
		// uncomment to force downloading everything again
		// row.site_google_analytics_keyword_last_import_datetime="";
		if(row.site_google_analytics_keyword_last_import_datetime NEQ "" and not structkeyexists(form, 'reimport')){
			monthSinceGALaunch=2; // only download last 2 months of data
		}
 		// one month at a time in reverse until nothing is returned?
 		for(g=1;g<=monthSinceGALaunch;g++){  
			if(structkeyexists(application, 'googleAnalyticsKeywordCancel')){
				application.googleAnalyticsKeywordStatus="";
				structdelete(application, 'googleAnalyticsKeywordCancel');
				echo('Cancelled');
				abort;
			}
			application.googleAnalyticsKeywordStatus="Processing #row.site_short_domain# at #tempStartDate# to #tempEndDate#"; 
			js={
			  "reportRequests":
			  [
			    {
			      "viewId": row.site_google_analytics_view_id,
			      "dateRanges": [{"startDate": tempStartDate, "endDate": tempEndDate}],
			      "dimensions": [{"name": "ga:keyword"}],
			      "metrics": [
			      	// limited to 10 metrics
			      	{"expression": "ga:users"}, // unique user
		  			{"expression": "ga:sessions"},
					{"expression": "ga:visitors"}, 
					{"expression": "ga:visits"},
					{"expression": "ga:bounces"},
					{"expression": "ga:pageviews"},
					{"expression": "ga:visitBounceRate"},
					{"expression": "ga:sessionDuration"},
					{"expression": "ga:avgSessionDuration"}]
			    }
			  ]
			};   

			js=doAPICall(js); 

			nextSite=false;
			if(not structkeyexists(js, 'reports')){
				echo('Stopped google analytics organic keywords for #row.site_short_domain# at #tempStartDate# to #tempEndDate#..<br>');
				break;
			}
			for(i=1;i<=arraylen(js.reports);i++){
				rs=js.reports[i];
				if(not structkeyexists(rs.data, 'rows')){
					echo('Stopped google analytics organic keywords for #row.site_short_domain# at #tempStartDate# to #tempEndDate#.<br>');
					nextSite=true;
					break;
				}
				for(n=1;n<=arraylen(rs.data.rows);n++){
					ds=rs.data.rows[n];
					vs=ds.metrics[1].values; 
					ts={};
					ts.ga_month_keyword_keyword=ds.dimensions[1];
					ts.ga_month_keyword_type=1; // 1 is google analytics, 2 is webmaster tool search analytics
					ts.ga_month_keyword_visits=vs[4];
					ts.ga_month_keyword_impressions=0;
					ts.ga_month_keyword_ctr=0;
					ts.ga_month_keyword_position=0;
					ts.ga_month_keyword_bounces=vs[5]     
					ts.ga_month_keyword_pageviews=vs[6];
					ts.ga_month_keyword_visit_bounce_rate=vs[7];
					ts.ga_month_keyword_time_on_site=vs[8];
					ts.ga_month_keyword_average_time_on_site=vs[9];
					ts.ga_month_keyword_date=tempStartDate;
					ts.ga_month_keyword_updated_datetime=request.zos.mysqlnow;
					ts.ga_month_keyword_deleted=0;
					ts.site_id=row.site_id;
 
			 
					// TODO: consider optimizing this to track the last import date somewhere, so we only need to compare the new data to reduce the amount of queries that run.
					db.sql="select * from #db.table("ga_month_keyword", request.zos.zcoreDatasource)# 
					WHERE site_id = #db.param(ts.site_id)# and 
					ga_month_keyword_deleted=#db.param(0)# and 
					ga_month_keyword_date=#db.param(dateformat(tempStartDate, "yyyy-mm-dd"))# and 
					ga_month_keyword_keyword=#db.param(ts.ga_month_keyword_keyword)# and
					ga_month_keyword_type=#db.param(ts.ga_month_keyword_type)#";
					qRank=db.execute("qRank"); 
					/*writedump(qRank);
					writedump(ts);
					abort;*/
					// only import new records
					ts2={
						table:"ga_month_keyword",
						datasource:request.zos.zcoreDatasource,
						struct:ts 
					}; 
					if(qRank.recordcount EQ 0){
						ga_month_keyword_id=application.zcore.functions.zInsert(ts2); 
					}else{
						ts2.struct.ga_month_keyword_id=qRank.ga_month_keyword_id;
						application.zcore.functions.zUpdate(ts2);
					}   
				}
			}
			if(nextSite){
				break;
			} 
			sleep(1000); // sleep to avoid hitting google's api limit
			echo('Processed google analytics organic keywords for #row.site_short_domain# | #tempStartDate# to #tempEndDate#<br>'); 
			tempStartDate=dateformat(dateadd("m", -1, tempStartDate), "yyyy-mm-dd"); 
			tempEndDate=dateformat(dateadd("d", -1, dateadd("m", 1, tempStartDate) ), "yyyy-mm-dd");
		} 
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_google_analytics_keyword_last_import_datetime=#db.param(request.zos.mysqlnow)#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate");
	}

	application.googleAnalyticsKeywordStatus="";
	echo('done'); 
	abort;
	</cfscript>
</cffunction>

<cffunction name="goal" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	init();
	throw("not implemented - the api call works, but i don't think we need this one");
	/*
dimensions=ga:source,ga:medium
metrics=ga:sessions,ga:goal1Starts,ga:goal1Completions,ga:goal1Value,ga:goalStartsAll,ga:goalCompletionsAll,ga:goalValueAll
sort=-ga:goalCompletionsAll
	*/
	startDate="2014-11-01";
	endDate="2014-11-30";
	js={
	  "reportRequests":
	  [
	    {
	      "viewId": request.zos.googleAnalyticsConfig.debugViewId,
	      "dateRanges": [{"startDate": startDate, "endDate": endDate}],
	      "dimensions": [
	      	{"name": "ga:source"},
	      	{"name": "ga:medium"}
	      ],
	      "metrics": [
	      	// limited to 10 metrics 
  			{"expression": "ga:sessions"},
			{"expression": "ga:goal1Completions"}, 
			{"expression": "ga:goal1Value"},
			{"expression": "ga:goalStartsAll"},
			{"expression": "ga:goalCompletionsAll"},
			{"expression": "ga:goalValueAll"}
		  ],
		"pageToken": "0",
		"pageSize": "10000"
	    }
	  ]
	}; 
	js=doAPICall(js);  
	for(i=1;i<=arraylen(js.reports);i++){
		rs=js.reports[i];
		for(n=1;n<=arraylen(rs.data.rows);n++){
			ds=rs.data.rows[n]; 
		}
	} 
	</cfscript>
</cffunction>


<!--- 

	public function getVisitsByDate($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:date',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getAudienceStatistics($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visitors,ga:newVisits,ga:percentNewVisits,ga:visits,ga:bounces,ga:pageviews,ga:visitBounceRate,ga:sessionDuration,ga:avgSessionDuration',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsByCountries($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:country',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsByCities($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:city',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsByLanguages($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:language',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsBySystemBrowsers($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:browser',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsBySystemOs($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:operatingSystem',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);


	}

	public function getVisitsBySystemResolutions($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:screenResolution',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsByMobileOs($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:operatingSystem',
			'sort' => '-ga:visits',
			'segment' => 'gaid::-11',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getVisitsByMobileResolutions($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:screenResolution',
			'sort' => '-ga:visits',
			'segment' => 'gaid::-11',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	/*
	 * CONTENT
	 *
	 */

	public function getPageviewsByDate($params=array()) {

		$defaults = array(
			'metrics' => 'ga:pageviews',
			'dimensions' => 'ga:date',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getContentStatistics($params=array()) {

		$defaults = array(
			'metrics' => 'ga:pageviews,ga:uniquePageviews',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getContentTopPages($params=array()) {

		$defaults = array(
			'metrics' => 'ga:pageviews',
			'dimensions' => 'ga:pagePath',
			'sort' => '-ga:pageviews',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	/*
	 * TRAFFIC SOURCES
	 *
	 */

	public function getTrafficSources($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:medium',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getKeywords($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:keyword',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}

	public function getReferralTraffic($params=array()) {

		$defaults = array(
			'metrics' => 'ga:visits',
			'dimensions' => 'ga:source',
			'sort' => '-ga:visits',
		);
		$_params = array_merge($defaults, $params);
		return $this->_query($_params);

	}
 --->
</cfoutput>
</cfcomponent>
