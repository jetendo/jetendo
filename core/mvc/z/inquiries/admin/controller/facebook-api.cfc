<cfcomponent>
<cfoutput>
<!--- 
Add ?debug=1 to url to force development environment

consider integrating the "Rate limiting header" feature to dynamically adjust to api limits

api call is each id in a single http request.   batch doesn't bypass api limits
 --->

<cffunction name="init" localmode="modern" access="public">
	<cfargument name="facebookConfig" type="struct" required="yes">
	<cfscript>
	facebookConfig = arguments.facebookConfig;

	variables.apiEndpoint   = 'https://graph.facebook.com/v2.8';
	variables.environment   = determineEnvironment();
	variables.batchRequests = [];
	variables.appId         = facebookConfig.appId;
	variables.appSecret     = facebookConfig.appSecret;

	setAccessToken( facebookConfig.accessToken );
	</cfscript>
</cffunction>

<cffunction name="setAccessToken" localmode="modern" access="public">
	<cfargument name="accessToken" type="string" required="yes">
	<cfscript>
	variables.accessToken = arguments.accessToken;
	</cfscript>
</cffunction>

<cffunction name="getAccessToken" localmode="modern" access="public">
	<cfscript>
	return variables.accessToken;
	</cfscript>
</cffunction>

 

<!--- 
<cffunction name="getPageLikes" localmode="modern" access="public">
	<cfargument name="pageId" type="string" required="yes">
	<cfargument name="pageLikes" type="struct" required="no" default="#{}#">
	<cfscript>
	pageId    = arguments.pageId;
	pageLikes = arguments.pageLikes;

	pageLikes.access_token = getAccessToken();

	ts={
		requestURL:'/' & pageId & '/insights/page_fans',
		params:pageLikes,
		method:"GET",
		timeout:30,
		throwOnError:true,  
	}
	return internalSendRequest(ts);   
	</cfscript>
</cffunction>

<cffunction name="getPageEngagements" localmode="modern" access="public">
	<cfargument name="pageId" type="string" required="yes">
	<cfargument name="pageEngagements" type="struct" required="no" default="#{}#">
	<cfscript>
	pageId          = arguments.pageId;
	pageEngagements = arguments.pageEngagements; 
	ts={
		requestURL:'/' & pageId & '/insights/page_engaged_users',
		params:pageEngagements,
		method:"GET",
		timeout:30,
		throwOnError:true,  
	}
	return internalSendRequest(ts);  
	</cfscript>
</cffunction>
<cffunction name="getPageReach" localmode="modern" access="public">
	<cfargument name="pageId" type="string" required="yes">
	<cfargument name="pageReach" type="struct" required="no" default="#{}#">
	<cfscript>
	pageId    = arguments.pageId;
	pageReach = arguments.pageReach;

	pageReach.access_token = getAccessToken();

	ts={
		requestURL:'/' & pageId & '/insights/page_impressions',
		params:pageReach,
		method:"GET",
		timeout:30,
		throwOnError:true,  
	}
	return internalSendRequest(ts);  
	</cfscript>
</cffunction>

<cffunction name="getFeedByPageId" localmode="modern" access="public">
	<cfargument name="pageId" type="string" required="yes">
	<cfscript>
	pageId    = arguments.pageId;
	ps = {
		'access_token': getAccessToken()
	};

	ts={
		requestURL:'/' & pageId & '/feed',
		params:ps,
		method:"GET",
		timeout:30,
		throwOnError:true,  
	}
	return internalSendRequest(ts);  
	</cfscript>
</cffunction>

<cffunction name="getAllPostsByPageId" localmode="modern" access="public">
	<cfargument name="pageId" type="string" required="yes">
	<cfscript>
	pageId    = arguments.pageId;
	ps = {
		'access_token': getAccessToken()
	};

	ts={
		requestURL:'/' & pageId & '/posts',
		params:ps,
		method:"GET",
		timeout:30,
		throwOnError:true,  
	}
	return internalSendRequest(ts); 
	</cfscript>
</cffunction>

<cffunction name="getAllPages" localmode="modern" access="public">
	<cfscript>
	allPages = {
		'access_token': getAccessToken()
	};

	ts={
		requestURL:'/me/accounts',
		params:allPages,
		method:"GET",
		timeout:30,
		throwOnError:true,  
	}
	return internalSendRequest(ts); 
	</cfscript>
</cffunction> 

<!--- INSIGHTS --->
<!--- https://developers.facebook.com/docs/graph-api/reference/v2.8/insights --->

<cffunction name="getPageImpressions" localmode="modern" access="public">
	<cfargument name="pageId" type="string" required="yes">
	<cfargument name="pageImpressions" type="struct" required="no" default="#{}#">
	<cfscript>
	pageId          = arguments.pageId;
	pageImpressions = arguments.pageImpressions;

	pageImpressions.access_token = getAccessToken();

	ts={
		requestURL:'/' & pageId & '/insights',
		params:pageImpressions,
		method:"GET",
		timeout:30,
		throwOnError:true,  
	}
	return internalSendRequest(ts); 
	</cfscript>
</cffunction>
--->
<!--- 
ts={
	method:"GET",
	link:"" 
}
rs=facebookCom.addBatchRequest(ts);
if(rs.success){
	// rs.response is the json response as native object.
}
 --->
<cffunction name="addBatchRequest" localmode="modern" access="public" hint="Each request counts as 1 api call, even when batched">
	<cfargument name="ss" type="struct" required="yes">  
	<cfscript>
	ss=arguments.ss;
	batchRequest = {
		'method':       ss.method,
		'relative_url': ss.link
	};

	arrayAppend( variables.batchRequests, batchRequest );
	</cfscript>
</cffunction>

<!--- 
ts={ 
	throwOnError:true
}
rs=facebookCom.sendBatchRequests(ts);
if(rs.success){
	// rs.response is the json response as native object.
}
 --->
<cffunction name="sendBatchRequests" localmode="modern" access="public" hint="Each request counts as 1 api call, even when batched">
	<cfargument name="ss" type="struct" required="yes">  
	<cfscript>
	ss=arguments.ss;
	if ( arrayLen( variables.batchRequests ) GT 0 ) {
		if ( arrayLen( variables.batchRequests ) GT 50 ) {
			throw( 'Too many batch requests at once. Maximum of 50 per API call (found ' & arrayLen( variables.batchRequests ) & ').' );
		} 
		requestParams = {
			'access_token':    getAccessToken(),
			'batch':           serializeJson(variables.batchRequests),
			'include_headers': false
		};
		ts={
			requestURL:"/",
			params:requestParams,
			method:"POST",
			timeout:200,
			throwOnError:application.zcore.functions.zso(ss, 'throwOnError', false, true),  
		};
		rs=internalSendRequest(ts);
		variables.batchRequests = [];
		return rs;
	} else {
		throw( 'No batch requests found to send.' );
	}
	</cfscript>
</cffunction>

<!--- 
ts={
	method:"GET",
	link:"",
	throwOnError:false
}
rs=facebookCom.sendRequest(ts);
if(rs.success){
	// rs.response is the json response as native object.
}
 --->
<cffunction name="sendRequest" localmode="modern" access="public" hint="Each request counts as 1 api call, even when batched">
	<cfargument name="ss" type="struct" required="yes"> 
	<cfscript> 
	ss=arguments.ss;
	requestParams = {
		'access_token':    getAccessToken(), 
		'include_headers': false
	};
	if(structkeyexists(ss, 'requestParams')){
		structappend(requestParams, ss.requestParams);
	}
	ts={
		requestURL:ss.link,
		params:requestParams,
		method:ss.method,
		timeout:200,
		throwOnError: application.zcore.functions.zso(ss, 'throwOnError', false, true)  
	}
	return internalSendRequest(ts);

	</cfscript>
</cffunction>

<cffunction name="sendTokenlessRequest" localmode="modern" access="public" hint="Each request counts as 1 api call, even when batched">
	<cfargument name="ss" type="struct" required="yes">  
	<cfscript> 
	ss=arguments.ss;
	requestParams = {
		'access_token':    request.zos.facebookConfig.appId&"|"&request.zos.facebookConfig.appSecret, 
		'include_headers': false
	};
	if(structkeyexists(ss, 'requestParams')){
		structappend(requestParams, ss.requestParams);
	}
	ts={
		requestURL:ss.link,
		params:requestParams,
		method:ss.method,
		timeout:200,
		throwOnError: application.zcore.functions.zso(ss, 'throwOnError', false, true)  
	}
	return internalSendRequest(ts);

	</cfscript>
</cffunction>

<cffunction name="sendCustomTokenRequest" localmode="modern" access="public" hint="Each request counts as 1 api call, even when batched">
	<cfargument name="ss" type="struct" required="yes">   
	<cfscript> 
	ss=arguments.ss; 
 	appsecret_proof=lcase(HMAC( ss.requestParams.access_token, request.zos.facebookConfig.appSecret, "HmacSHA256"));
	requestParams = { 
		'include_headers': false,
		appsecret_proof:appsecret_proof
	};
	if(structkeyexists(ss, 'requestParams')){
		structappend(requestParams, ss.requestParams);
	}
	ts={
		requestURL:ss.link,
		params:requestParams,
		method:ss.method,
		timeout:200,
		throwOnError: application.zcore.functions.zso(ss, 'throwOnError', false, true)  
	}
	return internalSendRequest(ts);

	</cfscript>
</cffunction> 

<cffunction name="sendDeleteRequest" localmode="modern" access="public" hint="Each request counts as 1 api call, even when batched">
	<cfargument name="ss" type="struct" required="yes">    
	<cfscript> 
	ss=arguments.ss;  
	requestParams={};
	if(structkeyexists(ss, 'requestParams')){
		structappend(requestParams, ss.requestParams);
	}
	ts={
		requestURL:application.zcore.functions.zURLAppend(ss.link, "access_token=#request.zos.facebookConfig.appId&"|"&request.zos.facebookConfig.appSecret#"),
		params:requestParams,
		method:ss.method,
		timeout:200,
		throwOnError: application.zcore.functions.zso(ss, 'throwOnError', false, true)  
	} 
	return internalSendRequest(ts);

	</cfscript>
</cffunction> 

<!--- API REQUEST & HELPERS ---> 
<!--- 
ts={
	requestURL:"",
	params:{},
	method:"POST",
	timeout:30,
	throwOnError:true,  
}
rs=internalSendRequest(ts);
if(rs.success){

}else{
	echo(rs.errorMessage);
}
 --->
<cffunction name="internalSendRequest" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes"> 
	<cfscript> 
	ss=arguments.ss; 
	result={};

	if(left(ss.requestURL, 4) EQ 'http'){
		tempLink = ss.requestURL;
	}else{
		tempLink = variables.apiEndpoint & ss.requestURL;
	}
	path=request.zos.globals.privateHomeDir&"facebook-api-cache/";
	application.zcore.functions.zcreatedirectory(path);
	// the hash has to be computed on all the params (excluding the access_token)
	hashString="";
	for(param in ss.params){
		if(param NEQ "access_token"){
			hashString&=param&"="&ss.params[param];
		}
	} 
	filePath=path&hash(tempLink&"?"&hashString, "sha-256")&"-"&dateformat(now(), "yyyy-mm-dd")&".json";

	if(fileExists(filePath) and not structkeyexists(form, 'disableFacebookCache')){
		if(request.zos.isDeveloper){
			echo('Cached download:'&tempLink&"<br>");
		}
		r=application.zcore.functions.zReadFile(filePath);
		result=deserializeJson(r);
	}else{
		if(request.zos.isDeveloper){
			echo('Fresh download:'&tempLink&"<br>");
		}

		try{
			http method=ss.method, charset="utf-8", timeout=ss.timeout, url=tempLink, result="result" {
				httpparam name="appsecret_proof", type="url", value=getAppSecretProof();

				if ( isStruct( ss.params ) AND NOT structIsEmpty( ss.params ) ) {
					for ( param in ss.params ) {
						if ( ss.method EQ 'GET' ) {
							httpparam name=param, type="url", value=ss.params[ param ] ;
						} else {
							httpparam name=param, type="formfield", value=ss.params[ param ] ;
						}
					}
				}
			}
			form.lastSuccessfulRequestHTTP=result;
			// lets never cache anything for now:
			//application.zcore.functions.zwritefile(filepath, serializeJson(result));
			sleep(400); // avoid api limits

		}catch(Any e){
			if(ss.throwOnError){
				savecontent variable="out"{
					echo('<h2>Facebook api http call failed</h2>');
					writedump(e);
					echo('<h2>Requests</h2>'); 

					if(structkeyexists(ss.params, 'batch')){
						writedump(variables.batchRequests); 
					}else{
						writedump(tempLink); 
					}
					echo('<h2>Responses</h2>');
					writedump(result);
				}
				throw(out );
			}else{
				return { success: false, errorMessage:'Facebook api http error', e:e };
			}
		}
	}
	if (not structkeyexists(result, 'status_code') or result.status_code NEQ 200 ) {
		if(ss.throwOnError){
			savecontent variable="out"{
				echo('<h2>Facebook api response error</h2>
				<h2>Requests</h2>'); 
				if(structkeyexists(ss.params, 'batch')){
					writedump(variables.batchRequests); 
				}else{
					writedump(tempLink); 
				}
				echo('<h2>Responses</h2>');
				writedump(result);
			}
			throw(out);
		}else{
			return { success: false, errorMessage:'Facebook api response error', result:result };
		}
	}

	arrReturn=[];
	if(structkeyexists(ss.params, 'batch')){
		arrResponse=deserializeJson(result.filecontent);
		rs={success:true, arrResponse:[] };
		for(i=1;i<=arraylen(arrResponse);i++){
			r=arrResponse[i];
			if(r.code NEQ "200"){
				if(ss.throwOnError){
					savecontent variable="out"{
						echo('<h2>Facebook api response error</h2> 
						<h2>Requests</h2>'); 
						writedump(variables.batchRequests); 
						echo('<h2>Responses</h2>');
						writedump(arrResponse);
					}
					throw(out);
				}else{
					rs.success=false;
					rs.errorMessage="One or more facebook api responses failed";
				}
			} 
			ts={
				request:variables.batchRequests[i],
				response:deserializeJSON(r.body),
				code:r.code
			};
			arrayAppend(rs.arrResponse, ts);
		}

		return rs;
	}else{
		ts={
			success:true,
			request:ss.requestURL,
			response:deserializeJson(result.filecontent),
			code: result.status_code
		}
		return ts;

	}
	</cfscript>
</cffunction>

<cffunction name="getResponse" localmode="modern" access="private">
	<cfargument name="result" type="struct" required="yes">
	<cfscript>
		return deserializeJSON( arguments.result.filecontent );
	</cfscript>
</cffunction>

<cffunction name="determineEnvironment" localmode="modern" access="private">
	<cfscript>
	var environment = 'development';

	if ( request.zos.isTestServer ) {
		environment = 'development';
	} else {
		environment = 'production';
	}

	if ( structKeyExists( form, 'debug' ) ) {
		environment = 'development';
	}

	return environment;
	</cfscript>
</cffunction>

<cffunction name="inDevelopment" localmode="modern" access="public">
	<cfscript>
	if ( variables.environment EQ 'development' ) {
		return true;
	}

	return false;
	</cfscript>
</cffunction>

<cffunction name="inProduction" localmode="modern" access="public">
	<cfscript>
	if ( variables.environment EQ 'production' ) {
		return true;
	}

	return false;
	</cfscript>
</cffunction>

<cffunction name="getAppSecretProof" localmode="modern" access="private">
	<cfscript>
	return lCase( hmac( variables.accessToken, variables.appSecret, 'HMACSHA256' ) );
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>