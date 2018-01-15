<cfcomponent output="no"><cfoutput>
<cffunction name="javascriptHeadCode" localmode="modern" returntype="string" output="no">
	<cfargument name="dynamicContent" type="string" required="yes">
	<cfscript>
	if(request.zos.originalURL EQ "/z/_com/zos/staticLoader"){
		return "";
	}
	</cfscript>
	<cfsavecontent variable="output">
	<meta name="format-detection" content="telephone=no">
	<cfif request.zos.cgi.server_port EQ "443">
		<meta name="referrer" content="origin">
	</cfif> 
	<script type="text/javascript">/* <![CDATA[ */var zSiteDomain="#request.zos.globals.domain#";/* ]]> */</script>
	<script src="#request.zos.currentHostName##application.zcore.skin.getVersionURL("/z/javascript/jetendo-init.js")#" type="text/javascript"></script>
	<script type="text/javascript">/* <![CDATA[ */
	#arguments.dynamicContent#
	/* ]]> */</script>
	</cfsavecontent>
	<cfreturn output>
</cffunction>

<cffunction name="init2" localmode="modern" output="no" returntype="any">
	<cfscript>
	var local=structnew();
	if(CGI.SERVER_PORT EQ '443'){
		local.dateDisabled=true;
	}else{
		local.dateDisabled=false;
	}
	local.kitHTML="";

	</cfscript>

	<cfif structkeyexists(request.zos,'zFontsComIncluded') EQ false>
		<cfif structkeyexists(request.zos.globals,'fontscomurl') and request.zos.globals.fontscomurl NEQ "">
			<cfset request.zos.zFontsComIncluded=true>
			<cfscript>
			local.kitURL=replace(replace(request.zos.globals.fontscomurl, "http://","//"),"https://","//");
			</cfscript>
			<cfsavecontent variable="local.kitHTML">
				<cfif right(local.kitURL, 3) EQ ".js">
					<cfif structkeyexists(request.zos,'zFontsComIncluded') EQ false>
						<script type="text/javascript">/* <![CDATA[ */ (function() {var tk = document.createElement('script');tk.src = "#jsstringformat(local.kitURL)#";tk.type = 'text/javascript';tk.async = 'true';tk.onload = tk.onreadystatechange = function() {var rs = this.readyState;if (rs && rs !== 4) return;};var s = document.getElementsByTagName('script')[0];s.parentNode.insertBefore(tk, s);})(); /* ]]> */</script>
					<cfelse>
						<script type="text/javascript" src="#local.kitURL#"></script>
					</cfif>
				<cfelse>
					<link rel="stylesheet" type="text/css" href="#local.kitURL#" />
				</cfif>
			</cfsavecontent>
			<cfscript>
			request.zos.zFontsComIncluded=true;
			</cfscript>
		</cfif>
	</cfif>

	<cfif structkeyexists(request.zos,'zTypeKitIncluded') EQ false>
		<cfif structkeyexists(request.zos.globals,'typekiturl') and request.zos.globals.typekiturl NEQ "">
			<cfscript>
			request.zos.zTypeKitIncluded=true;
			local.arrT=listtoarray(request.zos.globals.typekiturl, "/" );
			local.kitId=local.arrT[arraylen(local.arrT)];
			local.kitId=mid(local.kitId,1,len(local.kitId)-3);
			</cfscript>
			<cfsavecontent variable="local.kitHTML">
				<cfif structkeyexists(request.zos,'zTypeKitIncluded') EQ false>
					<script type="text/javascript">/* <![CDATA[ */ TypekitConfig = {kitId: '<cfscript>writeoutput(local.kitId);</cfscript>'};(function() {var tk = document.createElement('script');tk.src = '//use.typekit.com/' + TypekitConfig.kitId + '.js';tk.type = 'text/javascript';tk.async = 'true';tk.onload = tk.onreadystatechange = function() {var rs = this.readyState;if (rs && rs != 'complete' && rs != 'loaded') return;try { Typekit.load(TypekitConfig); } catch (e) {}};var s = document.getElementsByTagName('script')[0];s.parentNode.insertBefore(tk, s);})(); /* ]]> */</script>
				<cfelse>
					<script type="text/javascript" src="//use.typekit.com/<cfscript>writeoutput(local.kitId);</cfscript>.js"></script>
					<script type="text/javascript">/* <![CDATA[ */ try { Typekit.load(); } catch (e) {} /* ]]> */</script>
				</cfif>
			</cfsavecontent>
			<cfscript>
			request.zos.zTypeKitIncluded=true;
			</cfscript>
			</cfif>
		</cfif>
	<cfscript> 
	local.ts44="";
	if(application.zcore.user.checkGroupAccess("user")){
		// if site_id doesn't match, the parent or global token was used
		if(structkeyexists(cookie, 'ztoken')){
			local.ts44&="var zTokenLogin=true;"; 
		}else{
			local.ts44&="var zTokenLogin=false;";
		}
	}else{
		local.ts44&="var zTokenLogin=false;";
	}
	if(request.zos.istestserver){
		local.ts44&="var zThisIsTestServer=true;";
	}else{
		local.ts44&="var zThisIsTestServer=false;";
	}
	if(request.zos.isdeveloper){
		local.ts44&="var zThisIsDeveloper=true;";
	}else{
		local.ts44&="var zThisIsDeveloper=false;";
	}
	if(application.zcore.functions.zso(request.zos.globals, "disableUpgradeMessage", true, 0) EQ 1){
		local.ts44&="var zDisableUpgradeMessage=true;"; 
	}

	ss=application.siteStruct[request.zos.globals.id];
	iconMeta="";
	if(application.zcore.functions.zso(ss, 'iconLogoExists', false, false)){
		iconMeta=getIconMetaTags();
	}
	request.zos.templateData={
		dateDisabled:local.dateDisabled,
		notemplate:false,
		primary:true,
		uniqueTagStruct:{
			'content':true,
			'meta':true,
			'scripts':true,
			'stylesheets':true
		},
	comName : "zcorerootmapping.com.zos.template",
		template : "default.cfm",
		isFile : true,
		content : "",
		templateForced:false,
		contentStruct : StructNew(),
		tagContent : StructNew(),
		prependTagContent : { meta:{ arrContent:[variables.javascriptHeadCode(local.ts44)&local.kitHTML&iconMeta]} },
		appendTagContent : { } ,
		tagAssoc : StructNew(),
		tags : ArrayNew(1),
		requiredTags : StructNew(),
		//prependedContent : "",
		output : "",
		vars : "",
		config : StructNew(),
		building:false,
		// force content tag configuration
		tagContent:{
			content:{
				required : true,
				isFile : false,
				content : ""
			}
		},
		lastModifiedDate:false,
		dateSet:false
	};
	
	</cfscript>

</cffunction>


<cffunction name="disableShareThis" localmode="modern" output="no" returntype="any">
<cfscript>
	request.zos.templateData.disableShareThisEnabled=true;
	</cfscript>
</cffunction>

<cffunction name="disableDate" localmode="modern" output="true" returntype="any">
	<cfscript>
	request.zos.templateData.dateSet=false;
	request.zos.templateData.dateDisabled=true;
	request.zos.templateData.lastModifiedDate='';
	</cfscript>
</cffunction>



<cffunction name="setPlainTemplate" localmode="modern" output="false" returntype="any">
<cfscript>
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
	</cfscript>
</cffunction>

<cffunction name="setScriptDate" localmode="modern" output="false" returntype="any">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	return false;
	/*if(request.zos.templateData.dateDisabled) return;
	arguments.path=replaceNoCase(replaceNoCase(arguments.path,'\','/','ALL'),request.zos.globals.homedir, '/');
	request.zos.templateData.dateSet=true;
	this.setDate(request.zos.page.getFileDate(arguments.path));	
	return 	request.zos.page.getFileDate(arguments.path);
	*/
	</cfscript>
</cffunction>

<cffunction name="setDate" localmode="modern" output="false" returntype="any">
	<cfargument name="newDate" type="any" required="yes">
	<cfargument name="parse" type="boolean" required="no" default="#false#">
	<cfscript>
	return;
	/*
	if(request.zos.templateData.dateDisabled) return;
	request.zos.templateData.dateSet=true;
	if(arguments.newDate EQ false) return;
	if(arguments.parse){
		arguments.newDate=parsedatetime(DateFormat(arguments.newDate,'yyyy-mm-dd')&' '&TimeFormat(arguments.newDate,'HH:mm:ss'));
	}
	if(request.zos.templateData.lastModifiedDate EQ false){
		request.zos.templateData.lastModifiedDate = arguments.newDate;
	}else if(DateCompare(request.zos.templateData.lastModifiedDate,arguments.newDate) EQ -1){
		request.zos.templateData.lastModifiedDate = arguments.newDate;
	}
	
	this.checkIfModifiedSince();*/
	</cfscript>	
</cffunction>

<cffunction name="checkIfModifiedSince" localmode="modern" output="false" returntype="any">		
	<cfscript>
	var expireDays=14;
	var rd="";
	var tz="";
	var modified=true;
	return;
	/*
	//return;
	if(request.zos.istestserver EQ false){
	//	return;
	}
	if(request.zos.templateData.lastModifiedDate EQ false or request.zos.templateData.dateSet EQ false or request.zos.templateData.dateDisabled) return; // ignore when no date is set
	rd=gethttprequestdata();
	tz=gettimezoneinfo();
	// must parse: Sun, 06 Nov 1994 08:49:37 GMT    ; RFC 822, updated by RFC 1123

	lastMod=DateAdd("h", tz.utcHourOffset, request.zos.templateData.lastModifiedDate);
	lastModCompare=lastMod;
	expires=DateAdd("h", tz.utcHourOffset, DateAdd("h",1,request.zos.templateData.lastModifiedDate));
	lastMod=DateFormat(lastMod,'ddd, dd mmm yyyy')&' '&TimeFormat(lastMod,'HH:mm:ss')&' GMT';
	expires=DateFormat(expires,'ddd, dd mmm yyyy')&' '&TimeFormat(expires,'HH:mm:ss')&' GMT';
	expireSeconds=60*60; // expires in one hour // used to be expireDays*24*60*60
	if(structkeyexists(rd.headers,'if-modified-since')){
		ims=rd.headers['if-modified-since'];
		ims=replace(replace(replace(ims,",",""),":", " ","ALL"),"  ", " ","ALL");
	//writeoutput(ims&'|ims<br />');
		arrI=listToArray(ims,' ');
		//writedump(arrI);
		//imsOrder=arrI[1]&', '&arrI[3]&' '&arrI[2]&', '&arrI[4]&' '&arrI[5]&':'&arrI[6]&':'&arrI[7];
		try{
			imsOrder=arrI[3]&' '&arrI[2]&' '&arrI[4]&' '&arrI[5]&':'&arrI[6]&':'&arrI[7]&" "&arrI[8];
	//writeoutput(imsOrder&'|imsOrder<br />');
			imsParsed=parsedatetime(imsOrder);
			if(DateCompare(imsParsed, lastModCompare) NEQ -1){
				modified=false;
			}
		}catch(Any excpt){
		}
	}			
	//writedump(rd);
	//writeoutput("compare<br />"&imsParsed&"<br />"&lastModCompare&"<br />"&modified);
	</cfscript>
	<!--- Vary: Accept-Encoding - bug in IE 4 - 6 - fixed in IE7 ---->
<!--- 		<cfheader name="Vary" value="User Agent"> ---->
	<cfif modified> <!--- can't send mime type when its a 304 ---->
		<!--- expires really works.  without F5 or refresh - the page won't update until the expiration date! ---->
		<cfheader name="Cache-Control" value="max-age=#expireSeconds#, must-revalidate">
		<cfheader name="Expires" value="#expires#">
		<cfheader name="Last-Modified" value="#lastMod#"> 
	<cfelse>
		<cfheader statuscode="304" statustext="Not Modified">
		<!--- no output allowed when 304 is sent ---->	
		<cfscript>
		application.zcore.functions.zabort();
		</cfscript>
	</cfif>
	*/
</cfscript>
</cffunction>



<cffunction name="addPath" localmode="modern" returntype="any" output="false">
	<cfargument name="rootRelativePath" type="string" required="yes">
	<cfargument name="absPath" type="string" required="yes">
	<cfscript>
	initPaths();
	ArrayAppend(request.zos.templateData.arrRootRelativePath, arguments.rootRelativePath);
	ArrayAppend(request.zos.templateData.arrAbsPath, arguments.absPath);		
	</cfscript>
</cffunction>
<cffunction name="initPaths" localmode="modern" returntype="any" output="false">
	<cfscript>
	if(isDefined('request.zos.templateData.arrAbsPath') EQ false){
		request.zos.templateData.arrRootRelativePath=ArrayNew(1);
		request.zos.templateData.arrAbsPath=ArrayNew(1);
		// add default path at last minute
		ArrayAppend(request.zos.templateData.arrAbsPath, request.zos.globals.homedir&'templates/');
		ArrayAppend(request.zos.templateData.arrRootRelativePath, request.zos.globals.siteroot&"/templates/");
	}
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" returntype="any" output="false">
	<cfscript>
	request.zos.templateData.template = "default.cfm";
	request.zos.templateData.isFile = true;
	request.zos.templateData.uniqueTagStruct={};
	request.zos.templateData.primary = false;
	request.zos.templateData.content = "";
	request.zos.templateData.contentStruct = StructNew();
	request.zos.templateData.tagContent = StructNew();
	request.zos.templateData.tagAssoc = StructNew();
	request.zos.templateData.tags = ArrayNew(1);
	request.zos.templateData.requiredTags = StructNew();
	//request.zos.templateData.prependedContent = "";
	request.zos.templateData.output = "";
	request.zos.templateData.vars = "";
	request.zos.templateData.config = StructNew();
	// force content tag configuration
	StructInsert(request.zos.templateData.tagContent, 'content', StructNew(),true);
	request.zos.templateData.tagContent['content'].required = true;
	request.zos.templateData.tagContent['content'].isFile = false;
	request.zos.templateData.tagContent['content'].content = "";
	</cfscript>
</cffunction>

<cffunction name="setTemplate" localmode="modern" returntype="boolean" output="false">
	<cfargument name="template" required="yes" type="string">
	<cfargument name="isFile" required="no" type="boolean" default="#true#">
	<cfargument name="force" required="no" type="boolean" default="#false#">
	<cfscript>
	if(request.zos.templateData.templateForced EQ false or arguments.force){
		request.zos.templateData.isFile = arguments.isFile;
		request.zos.templateData.template = arguments.template;
	}
	if(arguments.force){
		request.zos.templateData.templateForced = true;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="addEndBodyHTML" localmode="modern" access="public">
	<cfargument name="finalString" type="string" required="yes">
	<cfargument name="html" type="string" required="yes">
	<cfscript>
	pos=find("##zDebugBar##", arguments.finalString);
	if(pos NEQ 0){
		arguments.finalString=replace(arguments.finalString, '##zDebugBar##',  arguments.html, 'one');
	}else{
		arguments.finalString=replacenocase(arguments.finalString,"</body>", arguments.html&"</body>","one");
	}
	return arguments.finalString;
	</cfscript>
</cffunction>
<!--- 
<cffunction name="getEndBodyHTML" localmode="modern" access="public">
	<cfscript>
	return '<div id="zOverEditDivTag" style="z-index:20001;  position:absolute; background-color:##FFFFFF; display:none; cursor:pointer; left:0px; top:0px; width:50px; height:27px; text-align:center; font-weight:bold; line-height:18px; "><a id="zOverEditATag" href="##" class="zNoContentTransition" target="_top" title="Click EDIT to edit this content">EDIT</a></div>'; 
	</cfscript>
</cffunction> --->

<cffunction name="abort" localmode="modern" output="true" returntype="any"><cfargument name="overrideContent" type="string" required="yes"><cfscript>
	var i=0;
	var finalOut=0;
	if(structkeyexists(request,'znotemplate') and request.znotemplate){
		writeoutput(trim(arguments.overrideContent));
	}else{
		this.setTag("content", trim(arguments.overrideContent), true,false);
		for(i in request.zos.templateData.tagContent){
			request.zos.templateData.tagContent[i].required = false;
		}
		finalString=this.build();
		endBodyHTML="";//this.getEndBodyHTML();
		echo(this.addEndBodyHTML(finalString, endBodyHTML));
		
	}
	if(isDefined('request.zos.tracking')){
		application.zcore.tracking.backOneHit();
	}
	if(isDefined('application.zcore.functions.zabort')){
		application.zcore.functions.zabort();
	}else{
		abort;
	}
	</cfscript>
</cffunction>

<cffunction name="getTags" localmode="modern" output="no" returntype="any">
	<cfargument name="start" type="numeric" required="no" default="#1#">
	<cfscript>
	var matching = true;
	var arrMatches = ArrayNew(1);
	var result = StructNew();
	var index = 1;
	var tempStruct = StructNew();
	var tempTag = "";
	var arrTagAttr="";
	var matchess=1;
	var i=1;
	var resultLen=0;
	var resultPos=0;
	var pos2=0;
	var pos=0;
	/*if(findnocase("<z_content>", request.zos.templateData.content) EQ 0){
		request.zos.templateData.content=replacenocase(request.zos.templateData.content, "</body>", "<z_content></body>");
	}*/
	while(matching){
		// ignore attrib="val""ue"
		i=0;
		matching = false;
		pos= findnocase('<z_', request.zos.templateData.content, index);
		if(pos NEQ 0){
			pos2= findnocase('>', request.zos.templateData.content, pos);
			if(pos2 NEQ 0){
				resultPos=pos;
				resultLen=(pos2-pos)+1;
				i=1;
				matching=true;
			}
		}
		if(i NEQ 0){
			if(resultPos NEQ 0){
				tempStruct = StructNew();
				tempStruct.content = "";
				tempStruct.isFile = false;
				tempStruct.string = mid(request.zos.templateData.content, index, resultPos-index);

				tempTag = mid(request.zos.templateData.content, resultPos+3, resultLen-4);
				tempStruct.tag = listgetat(tempTag,1," ");
				if(structkeyexists(request.zos.templateData.tagContent, tempStruct.tag) EQ false){
					StructInsert(request.zos.templateData.tagContent, tempStruct.tag,StructNew(),false);
					request.zos.templateData.tagContent[tempStruct.tag].isFile = false;
					request.zos.templateData.tagContent[tempStruct.tag].required = false;
				}
				if(structkeyexists(request.zos.templateData.tagAssoc, tempStruct.tag) EQ false){
					request.zos.templateData.tagAssoc[tempStruct.tag] = ArrayNew(1);
				}
				ArrayAppend(arrMatches, tempStruct);
				ArrayAppend(request.zos.templateData.tagAssoc[tempStruct.tag],ArrayLen(arrMatches));
				index = resultPos+resultLen;
			}else{
				matching = false;
			}
		}
	}
	tempStruct = StructNew();
	tempStruct.content = "";
	tempStruct.isFile = false;
	tempStruct.string = mid(request.zos.templateData.content, index, (len(request.zos.templateData.content)-index)+1);
	tempStruct.tag = '';
	ArrayAppend(arrMatches, tempStruct);
	request.zos.templateData.tags = arrMatches;
	</cfscript>
</cffunction>

<cffunction name="compileTemplateCFC" localmode="modern" returntype="string" output="yes"><cfargument name="returnString" type="boolean" required="no" default="#false#"><cfscript>
	var i=1;
	var finalString = "";
	var arrFinal=ArrayNew(1);
	var currentTag = "";
	var tempIO = "";
	var cfcName="";
	var cfcCreatePath="";
	var arrT=0;
	var arrT2=0;
	var result=0;
	var sp=0;
	var r=0;
	var contentTagIndex=0;
	var cfcPath=0;
	
	request.zos.templateData.building=true;
	request.zos.templateData.content = application.zcore.functions.zreadfile(request.zos.templateData.templatePath);
	// convert to new variables
	if(request.zos.templateData.content EQ false){
		// no template exists in any of the paths
		application.zcore.template.fail("#request.zos.templateData.comName#: build: `#request.zos.templateData.template#`, is not a valid template name. Path: #request.zos.templateData.templatePath#",true);
	}
	
	request.zos.templateData.content='<cfoutput>'&replacenocase(replacenocase(request.zos.templateData.content,'<cfoutput>','','ALL'),'</cfoutput>','','ALL')&'</cfoutput>';
	// fix legacy code to reference the new paths
	request.zos.templateData.content=replacenocase(request.zos.templateData.content,"/zsa2/","/zcorerootmapping/","all"); 
	request.zos.templateData.content=replacenocase(replacenocase(replacenocase(request.zos.templateData.content,'<cfinclude template="/','<cfinclude template="#request.zrootpath#','all'),'<cfinclude template="#request.zrootpath#zsa2/','<cfinclude template="/zcorerootmapping/','ALL'),'<cfinclude template="#request.zrootpath#zcorerootmapping/','<cfinclude template="/zcorerootmapping/','ALL');
	
	
	this.getTags();
	arrT=arraynew(1);
	arrT2=arraynew(1);
	contentTagIndex=0;
	arrayAppend(arrT, '
	if(request.zos.whiteSpaceEnabled EQ false){
		_zcoretemplatelocalvars.result=rereplace(_zcoretemplatelocalvars.result, "\n(\s+)",chr(10),"all");
	}
	application.zcore.cache.setTemplateContent(_zcoretemplatelocalvars.result);');
			
	for(i=1;i LTE arraylen(request.zos.templateData.tags);i++){
		if(request.zos.templateData.tags[i].tag NEQ ""){
			if(request.zos.templateData.tags[i].tag EQ "content"){
				contentTagIndex=i;
			}
			arrayAppend(arrT, '
			_zcoretemplatelocalvars.finalTagContent=application.zcore.template.getFinalTagContent("'&request.zos.templateData.tags[i].tag&'");
			application.zcore.cache.setTag("'&request.zos.templateData.tags[i].tag&'", "####_zcoretemplatelocalvars.ts.section'&i&'####", _zcoretemplatelocalvars.finalTagContent);
			_zcoretemplatelocalvars.result=replace(_zcoretemplatelocalvars.result,"####_zcoretemplatelocalvars.ts.section'&i&'####", _zcoretemplatelocalvars.finalTagContent);');
			arrayAppend(arrT2, request.zos.templateData.tags[i].string&'####_zcoretemplatelocalvars.ts.section'&i&'####');
		}else{
			arrayAppend(arrT2, request.zos.templateData.tags[i].string);
		}
	}
	/*if(#contentTagIndex# NEQ 0 and findnocase("####_zcoretemplatelocalvars.ts.section#contentTagIndex#####",_zcoretemplatelocalvars.result) EQ 0){
		_zcoretemplatelocalvars.result=replacenocase(_zcoretemplatelocalvars.result, "</body>", "####_zcoretemplatelocalvars.ts.section#contentTagIndex#####</body>");	
	}*/
	
	result='<cfcomponent output="yes"><cffunction name="runTemplate" localmode="modern" output="yes" returntype="string"><cfscript>
	var _zcoretemplatelocalvars=structnew();
	_zcoretemplatelocalvars.ts=structnew();
	</cfscript><cfsavecontent variable="_zcoretemplatelocalvars.result">'&arraytolist(arrT2,'')&'</cfsavecontent><cfscript>
	application.zcore.functions.zExecuteCSSJSIncludes();
	'&arraytolist(arrT,'')&'
	return _zcoretemplatelocalvars.result;
	</cfscript></cffunction></cfcomponent>';
	if(left(request.zos.templateData.templatePath, len(request.zos.globals.serverprivatehomedir&"_cache/")) EQ request.zos.globals.serverprivatehomedir&"_cache/"){
		sp=request.zos.globals.serverprivateHomeDir&"_cache/scripts/templates";
		cfcName=replace(replace(request.zos.templateData.templatePath,".","$","all"),"/","$","all")&".cfc";
		cfcPath=sp&'/'&cfcName;
		r=application.zcore.functions.zwritefile(cfcPath,result);
		
	}else{
		sp=request.zos.globals.privateHomeDir&"_cache/scripts/templates";
		if(directoryexists(sp) EQ false){
			application.zcore.functions.zcreatedirectory(sp);
		}
		cfcName=replace(replace(replace(request.zos.templateData.templatePath, request.zos.globals.homedir, "", "one"),".","$","all"),"/","$","all")&".cfc";
		cfcPath=sp&'/'&cfcName;
		r=application.zcore.functions.zwritefile(cfcPath,result);
	}
	
	application.zcore.functions.zClearCFMLTemplateCache();
</cfscript>
</cffunction>

<cffunction name="deleteAllTemplates" localmode="modern" returntype="any" output="no">
<cfscript>
var local=structnew();
var db=request.zos.queryObject;
db.sql="select * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
where site_active = #db.param('1')# and 
site_deleted = #db.param(0)#";
local.qSite=db.execute("qSite");
for(local.row in local.qSite){
	local.sphd=application.zcore.functions.zGetDomainWritableInstallPath(local.row.site_short_domain);
	local.qDir=directoryList("#local.sphd#_cache/scripts/templates/", false, 'query');
	for(local.row2 in local.qDir){
		if(local.row2.name NEQ "." and local.row2.name NEQ ".." and local.row2.type EQ "file" and right(local.row2.name, 4) EQ ".cfc"){
			filedelete("#local.sphd#_cache/scripts/templates/#local.row2.name#");
		}
	}
}
</cfscript>
</cffunction>


<cffunction name="createTemplateObject" localmode="modern" output="no" returntype="any">
    <cfargument name="c" type="string" required="yes">
    <cfargument name="cpath" type="string" required="yes">
    <cfargument name="forceNew" type="boolean" required="no" default="#false#">
    <cfscript>
    var c=0;
	var i=0;
	var t9=0;
	var t7=0;
	var e=0;
	var e2=0;
    if(structkeyexists(application.zcore,'templateCFCCache') EQ false){
        application.zcore.templateCFCCache=structnew();
    }
    if(structkeyexists(application.zcore.templateCFCCache, request.zos.globals.id) EQ false){
        application.zcore.templateCFCCache[request.zos.globals.id]=structnew();
    }
	t7=application.zcore.templateCFCCache;
    if(structkeyexists(t7,arguments.cpath) EQ false or arguments.forceNew){
		try{
			t9=createobject("component",arguments.cpath);
		}catch(Any e){
			savecontent variable="local.e2"{
				if(application.zcore.functions.zso(e, 'message') CONTAINS '-railo-dump' or application.zcore.functions.zso(e, 'message') CONTAINS '-lucee-dump'){
					echo(e.message);
				}
				writedump(e);	
			}
			if(not fileexists(expandpath(replace(arguments.cpath, ".","/","all")&".cfc"))){
				application.zcore.functions.z404("createTemplateObject() c:"&arguments.c&"<br />cpath:"&arguments.cpath&"<br />forceNew:"&arguments.forceNew&"<br />request.zos.cgi.SCRIPT_NAME:"&request.zos.cgi.SCRIPT_NAME&"<br />catch error:"&local.e2);
			}else{
				rethrow;
			}
		}
        application.zcore.templateCFCCache[request.zos.globals.id][arguments.cpath]=t9;
    }
	t7=application.zcore.templateCFCCache[request.zos.globals.id][arguments.cpath];
    c=duplicate(t7);
    for(i in c){
        if(isstruct(c[i])){
            c[i]=structnew();
            structappend(c[i],duplicate(t7[i]),true);
        }
    }
    return c;
    </cfscript>
</cffunction>

<cffunction name="build" localmode="modern" returntype="string" output="no"><cfscript>
	var i=1;
	var local=structnew();
	var finalString = "";
	var arrFinal=ArrayNew(1);
	var currentTag = "";
	var tempIO = "";
	var runTemplate=true;
	var runCFCTemplate=false;
	var cfcName="";
	var cfcCreatePath="";
	var sp=request.zos.globals.privateHomeDir&"_cache/scripts/templates"; 
	application.zcore.functions.zIncludeZOSFORMS();
	application.zcore.functions.zRequireCSSFramework();

	appendTag("stylesheets", "<!-- This is a copyrighted work. The owner of this web site reserves all rights to the content of this web site. #chr(10)#"&
	"Review the legal notices at the following url for more information: #request.zos.globals.domain#/z/misc/system/legal  -->");
	request.zos.templateData.building=true;
	if(not structkeyexists(application.zcore, 'templateCFCCache')){
		application.zcore.templateCFCCache={};
	}
	if(not structkeyexists(application.zcore.templateCFCCache, request.zos.globals.id)){
		application.zcore.templateCFCCache[request.zos.globals.id]={};
	}
	if(request.zos.templateData.isFile){
		request.zos.templateData.templatePath=false; 
		if(right(request.zos.templateData.template, 4) NEQ ".cfm"){
			runCFCTemplate=true;
			runTemplate=false;
			// modern cfc templates - all new code should use this more efficient templating.
			//zcorerootmapping.templates.administrator
			//zcorerootmapping.mvc.z.server-manager.templates.administrator
			// root.templates.default
			var cfcCreatePath=request.zos.templateData.template;
			if(left(request.zos.templateData.template, 5) EQ "root."){
				cfcCreatePath=request.zrootcfcpath&removechars(request.zos.templateData.template, 1, 5);
			}
			if(request.zos.zreset EQ "template"){
				structclear(application.zcore.templateCFCCache[request.zos.globals.id]);
				tempIO=createTemplateObject("component", cfcCreatePath, true);
			}else{
				tempIO=createTemplateObject("component", cfcCreatePath);
			}
		}else{ 
			// legacy cfm templates
			if(left(request.zos.templateData.template,19) EQ "/zcorecachemapping/"){
				sp=request.zos.globals.serverprivateHomeDir&"_cache/scripts/templates";
				request.zos.templateData.templatePath=request.zos.globals.serverprivatehomedir&"_cache/"&removechars(request.zos.templateData.template,1,19);
				cfcName=replace(replace(replace(request.zos.templateData.templatePath, request.zos.globals.homedir, "", "one"),".","$","all"),"/","$","all");
				cfcCreatePath='zcorecachemapping.scripts.templates.'&cfcName;
			}else{
				request.zos.templateData.templatePath=request.zos.globals.homedir&"templates/"&request.zos.templateData.template;
				cfcName=replace(replace(replace(request.zos.templateData.templatePath, request.zos.globals.homedir, "", "one"),".","$","all"),"/","$","all");
				cfcCreatePath=request.zRootSecureCFCPath&'_cache.scripts.templates.'&cfcName;
			}
			if(not structkeyexists(application.zcore, 'compiledSiteTemplatePathCache')){
				application.zcore.compiledSiteTemplatePathCache={};
			}
			if(not structkeyexists(application.zcore.compiledSiteTemplatePathCache, request.zos.globals.id)){
				application.zcore.compiledSiteTemplatePathCache[request.zos.globals.id]={};
			}
			if(structkeyexists(application.zcore.compiledTemplatePathCache, sp&'/'&cfcName&".cfc")){
				application.zcore.compiledTemplatePathCache[sp&'/'&cfcName&".cfc"]=true;
			}  
			if(not request.zos.enableSiteTemplateCache){ 
				this.compileTemplateCFC(); 
				tempIO=createTemplateObject("component",cfcCreatePath,true);
				application.zcore.compiledSiteTemplatePathCache[request.zos.globals.id][sp&'/'&cfcName&".cfc"]=true;
			}else if(request.zos.zreset EQ "template" or not structkeyexists(application.zcore.compiledSiteTemplatePathCache[request.zos.globals.id], sp&'/'&cfcName&".cfc")){   
				structclear(application.zcore.templateCFCCache[request.zos.globals.id]);
				if(fileexists(request.zos.templateData.templatePath)){
					this.compileTemplateCFC(); 
					tempIO=createTemplateObject("component",cfcCreatePath,true);
					application.zcore.compiledSiteTemplatePathCache[request.zos.globals.id][sp&'/'&cfcName&".cfc"]=true;
				}else{
					runTemplate=false;
				}
			}else if(structkeyexists(application.zcore.compiledTemplatePathCache, sp&'/'&cfcName&".cfc")){
				tempIO=createTemplateObject("component",cfcCreatePath);
			}else{
				
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, request.zos.templateData.templatePath) EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[request.zos.templateData.templatePath]=fileexists(request.zos.templateData.templatePath);
				}
				if(application.sitestruct[request.zos.globals.id].fileExistsCache[request.zos.templateData.templatePath]){
					if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, sp&'/'&cfcName&".cfc") EQ false){
						application.sitestruct[request.zos.globals.id].fileExistsCache[sp&'/'&cfcName&".cfc"]=fileexists(sp&'/'&cfcName&".cfc");
					}
					if(application.sitestruct[request.zos.globals.id].fileExistsCache[sp&'/'&cfcName&".cfc"] EQ false){
						this.compileTemplateCFC();
						application.sitestruct[request.zos.globals.id].fileExistsCache[sp&'/'&cfcName&".cfc"]=true;
					}
					tempIO=createTemplateObject("component",cfcCreatePath);
					application.zcore.compiledTemplatePathCache[sp&'/'&cfcName&".cfc"]=true;
				}else{
					runTemplate=false;
				}
			} 
		}
	}else{
		// don't compile this the same?  or just put the entire template as the struct key maybe.
		request.zos.templateData.content = request.zos.templateData.template;
	}
	if(structkeyexists(request, 'zValueOffset') and request.zValueOffset NEQ 0){
		application.zcore.template.appendTag('meta','<script type="text/javascript">/* <![CDATA[ */zArrDeferredFunctions.push(function(){zInitZValues(#request.zValueOffset#);});/* ]]> */</script>');
	} 
	if(not structkeyexists(form, 'zab')){
		if(Request.zOS.isdeveloper){
			if(request.zos.istestserver or application.zcore.user.checkAllCompanyAccess()){
				application.zcore.debugger.init();
			}
		} 
	}
	local.retrytemplatecompile=false;
	if(runCFCTemplate){
		if(structkeyexists(tempIO, 'init')){
			tempIO.init();
		}
		finalString=tempIO.render(this.getFinalTagStruct());
	}else if(runTemplate){
		finalString=tempIO.runTemplate();
	}else{
		finalString=this.getTagContent("content");	
	} 
	if(structkeyexists(form,'zViewSource')){
		finalString = HTMLCodeFormat(finalString);
	}

	if(not structkeyexists(request, 'disableGlobalHTMLHeadCode') and structkeyexists(request.zos,'inMemberArea') and request.zos.inMemberArea EQ false){
		finalString=replace(finalString, '</head>',application.sitestruct[request.zos.globals.id].globalHTMLHeadSource&'</head>');
	}
	request.zos.endtime=gettickcount('nano');
	if(request.zos.templateData.primary and (Request.zOS.isDeveloper or request.zos.istestserver)){
		if(structkeyexists(Request,'zPageDebugDisabled') EQ false and (application.zcore.user.checkAllCompanyAccess() or request.zos.istestserver) and structkeyexists(form, 'zab') EQ false){
			request.zos.debuggerFinalString=finalString;
			request.zos.debugbarStruct=application.zcore.debugger.getForm();
			request.zos.debugbaroutput=application.zcore.debugger.getOutput();
		}
		if(structkeyexists(form,'zOS_viewAsXML') and findNoCase('firefox', request.zos.cgi.HTTP_USER_AGENT) NEQ 0){
			finalString = replace(finalString, ' xmlns="http://www.w3.org/1999/xhtml"','');			
		}
	}
	
	request.zos.templateData.output = finalString;
	return finalString;
	</cfscript></cffunction>

<cffunction name="getShareButton" localmode="modern" output="no" returntype="string">
<cfargument name="style" type="string" required="no" default="font-size:13px; font-weight:bold;clear:both; width:300px; margin-left:5px; padding-bottom:5px;">
<cfargument name="nohr" type="boolean" required="no" default="#false#">
<cfargument name="addthisType" type="string" required="no" default="addthis_default_style">
<cfscript>
	var s1="";
	if(isDefined('request.zos.sharebuttonindex') EQ false){
		request.zos.sharebuttonindex=0;
	}
	request.zos.sharebuttonindex++;
		if(1 EQ 0 and request.zos.istestserver){
			return '';
		}else{ 
			if(request.zos.sharebuttonindex == 1){
				if(request.zos.cgi.SERVER_PORT EQ "443"){
					s1="s";
				}
			}
			return '<div id="zaddthisbox#request.zos.sharebuttonindex#" class="addthis_toolbox #arguments.addthisType# "></div>';
		}
	</cfscript>
</cffunction>

 
<cffunction name="requireTag" localmode="modern" returntype="boolean" output="false">
	<cfargument name="name" required="yes" type="string">
	<cfscript>
	if(isDefined('request.zos.templateData.tagContent.#arguments.name#') EQ false){
		StructInsert(request.zos.templateData.tagContent, arguments.name, StructNew(),true);
	}
	request.zos.templateData.tagContent[arguments.name].required = true;
	return true;
	</cfscript>
</cffunction>

<!--- FUNCTION: getTagContent(name); --->
<cffunction name="getTagContent" localmode="modern" returntype="any" output="false">
	<cfargument name="name" required="yes" type="string">
	<cfscript>
	if(structkeyexists(request.zos.templateData.tagContent, arguments.name) and structkeyexists(request.zos.templateData.tagContent[arguments.name],'content')){
		return request.zos.templateData.tagContent[arguments.name].content;
	}else{
		return "";
	}
	</cfscript>
</cffunction>

<cffunction name="getFinalTagStruct" localmode="modern" returntype="struct" output="no">
	<cfscript>
	var tagStruct={}; 
	// you can't enable new meta tags because it breaks old templates and sites that load jquery plugins the old way
	//application.zcore.functions.zEnableNewMetaTags(); 
	application.zcore.functions.zExecuteCSSJSIncludes(); 
	for(var i in request.zos.templateData.uniqueTagStruct){
		tagStruct[i]=this.getFinalTagContent(i);
	}  
	return tagStruct;
	</cfscript>
</cffunction>

<cffunction name="getFinalTagContent" localmode="modern" returntype="any" output="false">
	<cfargument name="name" required="yes" type="string">
	<cfscript>
	var local=structnew();
	var prepend="";
	var append="";
	var append2="";
	if(structkeyexists(request.zos.templateData.prependTagContent, arguments.name)){
		prepend=arraytolist(request.zos.templateData.prependTagContent[arguments.name].arrContent,"");
	}
	if(structkeyexists(request.zos.templateData.appendTagContent, arguments.name)){
		append=arraytolist(request.zos.templateData.appendTagContent[arguments.name].arrContent,"");
	}
	if(arguments.name EQ "scripts" and not structkeyexists(request.zos, 'disableOldZLoader')){
		if(arraylen(request.zos.arrScriptInclude) neq 0){
			local.lastScript=request.zos.arrScriptInclude[arraylen(request.zos.arrScriptInclude)];
			local.jqueryIncludeLength=len("/z/javascript/jquery/jquery-1.10.2.min.js");
			local.scriptIncludeStruct={"1":{},"2":{},"3":{},"4":{},"5":{},"6":{},"7":{},"8":{}, "9":{}, "10":{}, "11":{}, "12":{}, "13":{}, "14":{}, "15":{}, "16":{}, "17":{}, "18":{}, "19":{}, "20":{} };
			for(local.i=1;local.i LTE arraylen(request.zos.arrScriptInclude);local.i++){
				if(left(request.zos.arrScriptInclude[local.i], local.jqueryIncludeLength) NEQ "/z/javascript/jquery/jquery-1.10.2.min.js"){
					if(left(request.zos.arrScriptInclude[local.i], 1) EQ '/' and left(request.zos.arrScriptInclude[local.i], 2) NEQ "//"){
						// required for domains that use http proxy connection
						local.scriptIncludeStruct[request.zos.arrScriptIncludeLevel[local.i]][request.zos.currentHostName&request.zos.arrScriptInclude[local.i]]=true;
					}else{
						local.scriptIncludeStruct[request.zos.arrScriptIncludeLevel[local.i]][request.zos.arrScriptInclude[local.i]]=true;
					}
				}
			}
			local.scriptCount=structcount(local.scriptIncludeStruct); 
			local.arrBeginFunction=[];
			local.arrEndFunction=[];
			for(local.i=1;local.i LTE 20;local.i++){
				if(structcount(local.scriptIncludeStruct[local.i])){
					arrayappend(local.arrBeginFunction, ', function(a){ var t=new zLoader();t.loadScripts(["'&structkeylist(local.scriptIncludeStruct[local.i],'", "')&'"]');
					arrayappend(local.arrEndFunction, ");}");
				}
			}
			local.scriptOutput=arraytolist(local.arrBeginFunction, "")&arrayToList(local.arrEndFunction,"");

			append2='<script type="text/javascript">/* <![CDATA[ */  
				setTimeout(function(){
					var tempM=new zLoader();tempM.loadScripts(["#request.zos.currentHostName##application.zcore.skin.getVersionURL("/z/javascript/jquery/jquery-1.10.2.min.js")#"]
					'&local.scriptOutput&'
					);
				},0); /* ]]> */</script>'; 
		}
	}
	
	if(structkeyexists(request.zos.templateData.tagContent, arguments.name) and structkeyexists(request.zos.templateData.tagContent[arguments.name],'content')){
		if(arguments.name EQ "title" or arguments.name EQ "pagetitle"){
			local.finalContent=prepend&replacenocase(htmleditformat(request.zos.templateData.tagContent[arguments.name].content),"&amp;amp;","&amp;","ALL")&append&append2;
		}else{
			local.finalContent=prepend&request.zos.templateData.tagContent[arguments.name].content&append&append2;
		}
	}else{
		local.finalContent=prepend&append&append2;
	}
	return trim(local.finalContent);
	/*if(request.zos.whiteSpaceEnabled){
		return trim(local.finalContent);
	}else{
		return trim(rereplace(local.finalContent, "\n(\s+)",chr(10),"all"));
	}*/
	</cfscript>
</cffunction>

<cffunction name="clearPrependAppendTagData" localmode="modern" returntype="void" output="false">
	<cfargument name="name" required="yes" type="string">
<cfscript>
	if(structkeyexists(request.zos.templateData.prependTagContent, arguments.name)){
		request.zos.templateData.prependTagContent[arguments.name].arrContent=arraynew(1);
		request.zos.templateData.prependTagContent[arguments.name].arrFirst=arraynew(1);
	}
	if(structkeyexists(request.zos.templateData.appendTagContent, arguments.name)){
		request.zos.templateData.appendTagContent[arguments.name].arrContent=arraynew(1);
		request.zos.templateData.appendTagContent[arguments.name].arrFirst=arraynew(1);
	}
	</cfscript>


</cffunction>


<!--- application.zcore.template.findAndReplacePrependTag(name,searchstr, newstr); --->
<cffunction name="findAndReplacePrependTag" localmode="modern" returntype="void" output="false">
	<cfargument name="name" required="yes" type="string">
	<cfargument name="searchstr" required="yes" type="string">
	<cfargument name="newstr" required="yes" type="string">
<cfscript>
	var i=0;
	if(structkeyexists(request.zos.templateData.prependTagContent, arguments.name)){
		for(i=1;i LTE arraylen(request.zos.templateData.prependTagContent[arguments.name].arrContent);i++){
			request.zos.templateData.prependTagContent[arguments.name].arrContent[i]=replace(request.zos.templateData.prependTagContent[arguments.name].arrContent[i], arguments.searchstr, arguments.newstr, 'all');
		}
	}
	</cfscript>
</cffunction>

<!--- application.zcore.template.findAndReplaceAppendTag(searchstr, newstr); --->
<cffunction name="findAndReplaceAppendTag" localmode="modern" returntype="void" output="false">
	<cfargument name="name" required="yes" type="string">
	<cfargument name="searchstr" required="yes" type="string">
	<cfargument name="newstr" required="yes" type="string">
<cfscript>
	var i=0;
	if(structkeyexists(request.zos.templateData.appendTagContent, arguments.name)){
		for(i=1;i LTE arraylen(request.zos.templateData.appendTagContent[arguments.name].arrContent);i++){
			request.zos.templateData.appendTagContent[arguments.name].arrContent[i]=replace(request.zos.templateData.appendTagContent[arguments.name].arrContent[i], searchstr, newstr, 'all');
		}
	}
	</cfscript>
</cffunction>

<!--- FUNCTION: prependTag(name, content, forceFirst); --->
<cffunction name="prependTag" localmode="modern" returntype="void" output="false">
	<cfargument name="name" required="yes" type="string">
	<cfargument name="content" required="yes" type="string">
	<cfargument name="forceFirst" required="no" type="boolean" default="#false#">
<cfscript>
	if(len(arguments.content) EQ 0) return;
	if(len(arguments.name) EQ 0){
		this.fail("Error: COMPONENT: zcorerootmapping.com.zos.template.cfc: prependTag ARGUMENT `name` cannot be an empty string",true);
	}else{
		request.zos.templateData.uniqueTagStruct[arguments.name]=true;
		if(structkeyexists(request.zos.templateData.prependTagContent, arguments.name) EQ false){
			request.zos.templateData.prependTagContent[arguments.name]={ arrContent=[arguments.content] };
		}else{
			if(arguments.forceFirst){
				arrayprepend(request.zos.templateData.prependTagContent[arguments.name].arrContent,arguments.content);
			}else{
				arrayappend(request.zos.templateData.prependTagContent[arguments.name].arrContent,arguments.content);
			}
		}
	}
	</cfscript>
</cffunction>

<cffunction name="prependContent" localmode="modern" returntype="any" output="false">
	<cfargument name="content" type="string" required="yes">
	<cfscript>
	if(len(arguments.content) EQ 0) return;
	request.zos.templateData.uniqueTagStruct["content"]=true;
	if(structkeyexists(request.zos.templateData.prependTagContent, "content") EQ false){
		request.zos.templateData.prependTagContent["content"]={ arrContent=[arguments.content] };
	}else{
		arrayappend(request.zos.templateData.prependTagContent["content"].arrContent,arguments.content);
	}
	</cfscript>
</cffunction>

<!--- FUNCTION: appendTag(name, content, forceFirst); --->
<cffunction name="appendTag" localmode="modern" returntype="void" output="false">
	<cfargument name="name" required="yes" type="string">
	<cfargument name="content" required="yes" type="string">
	<cfargument name="forceFirst" required="no" type="boolean" default="#false#">
<cfscript>
	var i=1;
	var matched=false;
	if(len(arguments.content) EQ 0) return;
	if(len(trim(arguments.name)) EQ 0){
		request.zos.templateData.fail("Error: COMPONENT: zcorerootmapping.com.zos.template.cfc: appendTag ARGUMENT `name` cannot be an empty string",true);
	}else{
		request.zos.templateData.uniqueTagStruct[arguments.name]=true;
		if(structkeyexists(request.zos.templateData.appendTagContent, arguments.name) EQ false){
			request.zos.templateData.appendTagContent[arguments.name]={ arrContent=[arguments.content], arrFirst=[arguments.forceFirst] };
		}else{
			if(arguments.forceFirst){
				for(i=1;i LTE arraylen(request.zos.templateData.appendTagContent[arguments.name].arrFirst);i++){
					if(request.zos.templateData.appendTagContent[arguments.name].arrFirst[i] EQ false){
						arrayinsertat(request.zos.templateData.appendTagContent[arguments.name].arrContent,i, arguments.content);
						arrayinsertat(request.zos.templateData.appendTagContent[arguments.name].arrFirst,i,true);
						matched=true;
						break;
					}
				}
				if(matched EQ false){
					arrayprepend(request.zos.templateData.appendTagContent[arguments.name].arrContent, arguments.content);
					arrayprepend(request.zos.templateData.appendTagContent[arguments.name].arrFirst,true);
				}
			}else{
				arrayappend(request.zos.templateData.appendTagContent[arguments.name].arrContent,arguments.content);
				arrayappend(request.zos.templateData.appendTagContent[arguments.name].arrFirst,false);
			}
		}
	}
	</cfscript>
</cffunction>

<!--- application.zcore.template.getAllPreAndPostData(); --->
<cffunction name="getAllPreAndPostData" localmode="modern" returntype="string" output="yes">
<cfscript>
	var arrOut=arraynew(1);
	var n=1;
	var c=0;
	for(n in request.zos.templateData.prependTagContent){
		c=arraytolist(request.zos.templateData.prependTagContent[n].arrContent,"");
		if(c DOES NOT CONTAIN '/z/javascript/zForm.js'){
			arrayappend(arrOut,c);
		}
	}
	for(n in request.zos.templateData.appendTagContent){
		c=arraytolist(request.zos.templateData.appendTagContent[n].arrContent,"");
		if(c DOES NOT CONTAIN '/z/javascript/zForm.js'){
			arrayappend(arrOut,c);
		}
	}
	return arraytolist(arrOut,"");
	</cfscript>
</cffunction>

<!--- FUNCTION: setTag(name, content, required, isFile); --->
<cffunction name="setTag" localmode="modern" returntype="boolean" output="no">
	<cfargument name="name" required="yes" type="string">
	<cfargument name="content" required="yes" type="string">
	<cfargument name="required" required="no" type="boolean" default="#false#">
	<cfargument name="isFile" required="no" type="boolean" default="#false#">
	<cfargument name="append" required="no" type="boolean" default="#false#">
	<cfscript>
	if(trim(arguments.name) EQ ''){
		this.fail("Error: COMPONENT: zcorerootmapping.com.zos.template.cfc: setTag ARGUMENT `name` cannot be an empty string",true);
	}else{
		request.zos.templateData.uniqueTagStruct[arguments.name]=true;
		if(arguments.append){
			if(structkeyexists(request.zos.templateData.tagContent,arguments.name)){
				request.zos.templateData.tagContent[arguments.name].content = request.zos.templateData.tagContent[arguments.name].content&arguments.content;
				return true;
			}
		}
		StructInsert(request.zos.templateData.tagContent, arguments.name, StructNew(),true);
		request.zos.templateData.tagContent[arguments.name].required = arguments.required;
		request.zos.templateData.tagContent[arguments.name].isFile = arguments.isFile;
		request.zos.templateData.tagContent[arguments.name].content = arguments.content;
	}
	return true;
	</cfscript>
</cffunction>




<cffunction name="getOutput" localmode="modern" output="false" returntype="string">
	<cfscript>
	return request.zos.templateData.output;
	</cfscript>
</cffunction>






<cffunction name="fail" localmode="modern" hint="Used when a critical template error occurs and result is aborted with a custom error message." output="true" returntype="any">
	<cfargument name="message" type="string" required="no" default="">
	<cfargument name="throwError" type="boolean" required="no" default="#true#">
	<cfargument name="pageOutput" type="boolean" required="no" default="#false#">
	<cfargument name="templateOutput" type="boolean" required="no" default="#false#">
	<cfscript>
	var theError = "";
	</cfscript>
	<cfsavecontent variable="theError">
	<cfscript>
	writeoutput('<!-- JetendoCustomError --><h2>Jetendo CMS Custom Error</h2>');
	writeoutput('<table style=" border-spacing:0px; width:100%;" class="table-list"><tr><td>');
	if(arguments.message NEQ ''){
		writeoutput('Reason: '&arguments.message);
	}else{
		writeoutput('No reason was given.');
	}
	writeoutput('</td></tr></table><table style=" border-spacing:0px; width:100%;" class="table-list"><tr><td>');
	if(arguments.pageOutput){
		writeoutput("<br /><br />Partial page output below<br /><textarea style=""width:100%;height:250;"">#HTMLEditFormat(request.zos.templateData.output)#</textarea>");
	}
	if(arguments.templateOutput){
		writeoutput("<br /><br />Template code below<br /><textarea style=""width:100%;height:250;"">#HTMLEditFormat(request.zos.templateData.content)#</textarea>");
	}
	writeoutput('</td></tr></table><!-- JetendoCustomErrorEnd -->');
	if(isDefined('application.zcore.functions.zEndOfRunningScript')){
		application.zcore.functions.zEndOfRunningScript();
	}
	</cfscript>
	</cfsavecontent>		
	<cfif arguments.throwError>
		<cfset Request.zOS.customError=true>
		<cfthrow message="#theError#" type="exception">
	<cfelse>
		#theError#
	</cfif>
	<cfscript>
	if(isDefined('application.zcore.functions.zabort')){
		application.zcore.functions.zabort();
	}
	</cfscript><cfabort>
</cffunction>

<cffunction name="replaceErrorContent" localmode="modern" returntype="any" output="false">
	<cfargument name="content" type="string" required="yes">
	<cfscript>
	request.zos.prependedErrorContent = arguments.content;
	</cfscript>
</cffunction>

<cffunction name="prependErrorContent" localmode="modern" returntype="any" output="false">
	<cfargument name="content" type="string" required="yes">
	<cfscript>
	if(structkeyexists(request.zos,'prependedErrorContent') eq false){
		request.zos.prependedErrorContent="";
	}
	request.zos.prependedErrorContent = request.zos.prependedErrorContent&arguments.content&'<br /><br />';
	</cfscript>
</cffunction>






<cffunction name="makeTag" localmode="modern" returntype="string" output="false">
	<cfargument name="name" type="string" required="yes">
	<cfscript>
	return HTMLEditFormat("<z_"&arguments.name&">");
	</cfscript>
</cffunction>


<cffunction name="getIconMetaTags" access="private" localmode="modern">
	<cfsavecontent variable="out">
	<link rel="shortcut icon" href="#request.zos.globals.domain#/favicon.ico">
	<link rel="apple-touch-icon" href="#request.zos.globals.domain#/zupload/settings/apple-touch-icon.png">
	<link rel="apple-touch-icon" sizes="57x57" href="#request.zos.globals.domain#/zupload/settings/apple-touch-icon-57x57-precomposed.png" />
	<link rel="apple-touch-icon" sizes="72x72" href="#request.zos.globals.domain#/zupload/settings/apple-touch-icon-72x72-precomposed.png" />
	<link rel="apple-touch-icon" sizes="114x114" href="#request.zos.globals.domain#/zupload/settings/apple-touch-icon-114x114-precomposed.png" />
	<link rel="apple-touch-icon" sizes="144x144" href="#request.zos.globals.domain#/zupload/settings/apple-touch-icon-144x144-precomposed.png" /> 
	</cfsavecontent>
	<cfscript>
	return out;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>