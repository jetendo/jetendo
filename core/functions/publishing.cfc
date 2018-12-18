<cfcomponent extends="zcorerootmapping.functions.searchEngineSafeURLs">
<cfoutput>
<cffunction name="zConvertHTMLTOPDF" access="public" localmode="modern" output="no" returntype="boolean">
	<cfargument name="html" type="string" required="yes">
	<cfargument name="pdfFile" type="string" required="yes">
	<cfargument name="javascriptDelay" type="string" required="no" default="#0#" hint="Time in milliseconds">
	<cfargument name="pageWidthInches" type="numeric" required="no" default="8.5">
	<cfargument name="pageHeightInches" type="numeric" required="no" default="11">
	<cfscript>
	application.zcore.functions.zDeleteFile(arguments.pdfFile);
	arguments.javascriptDelay=application.zcore.functions.zso(arguments, 'javascriptDelay', true);
	tempFile=request.zos.globals.privatehomedir&"tempHTMLFile"&gettickcount()&".html";
	application.zcore.functions.zwritefile(tempFile, trim(arguments.html));
	secureCommand="convertHTMLTOPDF"&chr(9)&request.zos.globals.shortDomain&chr(9)&tempFile&chr(9)&arguments.pdfFile&chr(9)&arguments.javascriptDelay&chr(9)&arguments.pageWidthInches&chr(9)&arguments.pageHeightInches;
	output=application.zcore.functions.zSecureCommand(secureCommand, 15);
	application.zcore.functions.zDeleteFile(tempFile);
	returnCode=left(trim(output), 1);
	if(returnCode EQ 1 and fileexists(arguments.pdfFile)){
		return true;
	}else{
		if(output CONTAINS "|"){
			request.zos.htmlToPDFErrorMessage=listgetat(trim(output), 2, "|");
		}else{
			request.zos.htmlToPDFErrorMessage="Unknown error: #output#";
		}
		return false;
	}
	</cfscript>
</cffunction>

<!--- FUNCTION: zPublishURL(source, destinationFile, includeOnly, forceTemplate);
source can be an absolute url (including remote URLs) or a root relative coldfusion template (must use template system)
 --->
<cffunction name="zPublishURL" localmode="modern" output="false" returntype="any">
	<cfargument name="source" required="yes" type="string">
	<cfargument name="destinationFile" required="yes" type="string">
	<cfscript>
	var content = "";
	var result = "";
    var tempUnique='###getTickCount()#';
	var cfhttpresult=0;

	result=application.zcore.functions.zHTTPToFile(arguments.source, arguments.destinationFile);
	if(result EQ false){
		return "Publishing failed -> <a href=""#arguments.source#"" target=""_blank"">#arguments.source#</a>";
	}
	return true;
	</cfscript>
</cffunction>


 

<!--- 
// new function that can write binary files, checks status code correctly and always returns a boolean value for success or failure.
result=zHTTPtoFile(source, destinationFile, timeout, throwOnError, useSecureCommand);
 --->
<cffunction name="zHTTPtoFile" localmode="modern" output="yes" returntype="boolean">
	<cfargument name="source" required="yes" type="string">
	<cfargument name="destinationFile" required="yes" type="string">
	<cfargument name="timeout" type="string" required="no" default="#30#">
	<cfargument name="throwOnError" type="boolean" required="no" default="#false#">
	<cfargument name="useSecureCommand" type="boolean" required="no" default="#false#">
	<cfscript>
	var content = "";
    var tempUnique='###getTickCount()#';
	var cfhttpresult=0;

	path=getDirectoryFromPath(arguments.destinationFile);
	tempName=getFileFromPath(arguments.destinationFile);
	tempFilePath=path&tempName&tempUnique;
	if(not directoryexists(path)){
		throw("Directory, ""#path#"", doesn't exist.");
	}
	if(fileexists(tempFilePath)){
		application.zcore.functions.zdeletefile(tempFilePath);
	}
	find2 = findNoCase("https://", arguments.source);
	if(find2 NEQ 0){
		// cfml doesn't support SNI for SSL connections, so we force PHP Curl download on all SSL connections to avoid in case the domain uses SNI.
		arguments.useSecureCommand=true;
	}

		if(arguments.useSecureCommand){
			result=application.zcore.functions.zSecureCommand("httpDownloadToFile"&chr(9)&arguments.source&chr(9)&(arguments.timeout-2)&chr(9)&tempFilePath, arguments.timeout);
			if(result EQ 0){
				if(fileexists(tempFilePath)){
					application.zcore.functions.zdeletefile(tempFilePath);
				}
				return false;
			}else{
				if(fileexists(arguments.destinationFile)){
					application.zcore.functions.zdeletefile(arguments.destinationFile);
				}
				file action="rename" nameconflict="overwrite" source="#tempFilePath#" destination="#arguments.destinationFile#";
				return true;
			}
		}
	try{
		HTTP METHOD="GET" URL="#arguments.source#" path="#path#" file="#tempName&tempUnique#" result="cfhttpresult" redirect="yes" timeout="#arguments.timeout#" resolveurl="no" charset="utf-8" useragent="Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3 GoogleToolbarFF 3.1.20080730 Jetendo CMS" getasbinary="auto" throwonerror="yes"{
			httpparam type="Header" name="Accept-Encoding" value="#request.httpCompressionType#";
			httpparam type="Header" name="TE" value="#request.httpCompressionType#";
		}
		if(structkeyexists(cfhttpresult,'statuscode') and left(cfhttpresult.statusCode,3) EQ '200'){
			if(fileexists(arguments.destinationFile)){
				application.zcore.functions.zdeletefile(arguments.destinationFile);
			}
			file action="rename" nameconflict="overwrite" source="#tempFilePath#" destination="#arguments.destinationFile#";
			return true;
		}
	}catch(Any e){
		// ignore exception
		if(arguments.throwOnError){
			if(fileexists(tempFilePath)){
				application.zcore.functions.zdeletefile(tempFilePath);
			}
			rethrow;
		}
	}
	if(fileexists(tempFilePath)){
		application.zcore.functions.zdeletefile(tempFilePath);
	}
	return false;
	</cfscript>
</cffunction>
	
<cffunction name="zPublishQuery" localmode="modern" output="true" returntype="any">
	<cfargument name="publishStruct" type="struct" required="yes">
	<cfscript>
	
	var g=0;
	var ps = arguments.publishStruct;
	var tempStruct = StructNew();
	var currentURL = "";
	var currentFilePath = "";
	var n = 0;
	var tempVarList = "";
	var qPublish = "";
	var result = "";
	var db=request.zos.queryObject;
	
	// set defaults
	tempStruct.schedule = false;
	tempStruct.offset = 0;
	tempStruct.limit = 0;
	tempStruct.escapeWith = "-";
	tempStruct.escapeURL = true;
	tempStruct.datasource = request.zos.globals.datasource;
	tempStruct.template = false;
	// override defaults
	StructAppend(ps, tempStruct, false);
	</cfscript>
	<cfif isDefined('ps.url') EQ false and isDefined('ps.template') EQ false>
		<cfthrow type="exception" message="zPublishQuery: 'publishStruct.url' required">
	</cfif>
	<cfif isDefined('ps.fileNameFormat') EQ false>
		<cfthrow type="exception" message="zPublishQuery: 'publishStruct.fileNameFormat' required">
	</cfif>
	<cfif isDefined('ps.dirNameFormat') EQ false>
		<cfthrow type="exception" message="zPublishQuery: 'publishStruct.dirNameFormat' required">
	</cfif>
	
	<cfsavecontent variable="local.theSQL">
	#db.trustedSQL(ps.sql)# 
	<cfif ps.limit NEQ 0>
	LIMIT #db.param(ps.offset)#, #db.param(ps.limit)#
	</cfif>
	</cfsavecontent><cfscript>qPublish=db.execute("qPublish");</cfscript>
	
	<cfloop query="qPublish">
		<cfscript>
		// parse filename
		tempStruct.filename = application.zcore.functions.zParseVariables(ps.fileNameFormat,"-", qPublish);
		// parse dir
		tempStruct.dirname = application.zcore.functions.zParseVariables(ps.dirNameFormat,"-", qPublish);
		
		if(right(tempStruct.dirname,1) NEQ "/"){
			tempStruct.dirname = tempStruct.dirname&"/";
		}
		</cfscript>
		<cfif directoryexists(tempStruct.dirname) EQ false>
			<cfthrow type="exception" message="ZFUNCTION: zPublishQuery: directory doesn't exist, dirname = '#tempStruct.dirname#'">		
		</cfif>
		<cfscript>
			if(ps.escapeURL){
				result = application.zcore.functions.zPublishURL(application.zcore.functions.zParseVariables(ps.url,"_", qpublish), tempStruct.dirname&tempStruct.filename);
			}else{
				result = application.zcore.functions.zPublishURL(application.zcore.functions.zParseVariables(ps.url,false, qpublish), tempStruct.dirname&tempStruct.filename);
			}
		</cfscript>
	</cfloop>
</cffunction>




<!--- FUNCTION: zPublishFile(sourceUrl, destinationFile) --->
<cffunction name="zPublishFile" localmode="modern" output="false" returntype="any">
	<cfargument name="sourceUrl" required="true" type="string">
	<cfargument name="destinationFile" required="true" type="string">
	<cfscript>
	result=application.zcore.functions.zHTTPToFile(arguments.sourceURL, arguments.destinationFile);
	if(result EQ false){
		return "Publishing failed -> <a href=""#arguments.sourceUrl#"" target=""_blank"">#arguments.sourceUrl#</a>";
	}
	return true;
	</cfscript>
</cffunction>



<cffunction name="zGetResponseCookies" access="public" localmode="modern" returntype="struct" output="false" hint="This parses the response of a CFHttp call and puts the cookies into a struct."> 
	<cfargument name="Response" type="struct" required="true" hint="The response of a CFHttp call." />
	<cfscript>
	rs = StructNew(); 
	if(NOT StructKeyExists(ARGUMENTS.Response.ResponseHeader,"Set-Cookie")){
		return rs;
	}
	arrCookie = ARGUMENTS.Response.ResponseHeader[ "Set-Cookie" ];
	for(string in arrCookie){ 
		arrList=listToArray(string, ";");
		first=true;
		for(pair in arrList){
			name=listFirst(pair, "=");
			if(ListLen( Pair, "=" ) GT 1){
				value = ListRest( Pair, "=" );
			}else{
				value = "";
			} 
			if(first){
				first=false;
				rs[ Name ] = StructNew();
				cookieStruct = rs[ Name ];
				cookieStruct.Value = Value;
				cookieStruct.Attributes = StructNew();
			}else{
				cookieStruct.Attributes[ Name ] = Value;
			}
		}
	}
	return rs;
	</cfscript>
</cffunction>


<!--- 

jsonString=application.zcore.functions.zHttpJsonPost("link", serializeJson(js), 20);
if(jsonString EQ false or not isJson(jsonString)){
	throw(jsonString);
}
js=deserializeJson(jsonString);
writedump(js);
abort;
 --->
<cffunction name="zHttpJsonPost" access="public" localmode="modern"> 
	<cfargument name="link" type="string" required="true" />
	<cfargument name="jsonString" type="string" required="true" />
	<cfargument name="timeout" type="numeric" required="true" />
	<cfscript> 
	rs = StructNew(); 

	result=application.zcore.functions.zSecureCommand("httpJsonPost"&chr(9)&arguments.link&chr(9)&arguments.jsonString&chr(9)&(arguments.timeout-2), arguments.timeout);
	if(result EQ 0){
		return false;
	}else{
		return result;
	}
	</cfscript>
</cffunction>


<!--- 
ts={
	link:"",
	headers:{
		"soapAction":"something"
	},
	requestXML:'xmlAsString',
	timeout:20 // please set to at least 10 or more seconds
};
rs=application.zcore.functions.zHttpXMLPost(ts);
if(not rs.success){
	throw(rs.errorMessage);
	abort;
} 
writedump(rs);
abort;
 --->
<cffunction name="zHttpXMLPost" access="public" localmode="modern"> 
	<cfargument name="ss" type="struct" required="true" />
	<cfscript> 
	rs = StructNew(); 
	result=application.zcore.functions.zSecureCommand("httpXMLPost"&chr(9)&serializeJson(arguments.ss), arguments.ss.timeout+2);
	if(result NEQ "" and isJson(result)){
		return deserializeJson(result);
	}else{
		return {success:false, "zSecureCommand -> httpXMLPost failed"};
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>