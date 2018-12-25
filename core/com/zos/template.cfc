<cfcomponent output="no"><cfoutput>
<cffunction name="javascriptHeadCode" localmode="modern">
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

<cffunction name="init2" localmode="modern">
	<cfscript> 
	if(CGI.SERVER_PORT EQ '443'){
		dateDisabled=true;
	}else{
		dateDisabled=false;
	}
	kitHTML="";

	</cfscript>

	<cfif structkeyexists(request.zos,'zFontsComIncluded') EQ false>
		<cfif structkeyexists(request.zos.globals,'fontscomurl') and request.zos.globals.fontscomurl NEQ "">
			<cfset request.zos.zFontsComIncluded=true>
			<cfscript>
			kitURL=replace(replace(request.zos.globals.fontscomurl, "http://","//"),"https://","//");
			</cfscript>
			<cfsavecontent variable="kitHTML">
				<cfif right(kitURL, 3) EQ ".js">
					<cfif structkeyexists(request.zos,'zFontsComIncluded') EQ false>
						<script type="text/javascript">/* <![CDATA[ */ (function() {var tk = document.createElement('script');tk.src = "#jsstringformat(kitURL)#";tk.type = 'text/javascript';tk.async = 'true';tk.onload = tk.onreadystatechange = function() {var rs = this.readyState;if (rs && rs !== 4) return;};var s = document.getElementsByTagName('script')[0];s.parentNode.insertBefore(tk, s);})(); /* ]]> */</script>
					<cfelse>
						<script type="text/javascript" src="#kitURL#"></script>
					</cfif>
				<cfelse>
					<link rel="stylesheet" type="text/css" href="#kitURL#" />
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
			arrT=listtoarray(request.zos.globals.typekiturl, "/" );
			kitId=arrT[arraylen(arrT)];
			kitId=mid(kitId,1,len(kitId)-3);
			</cfscript>
			<cfsavecontent variable="kitHTML">
				<cfif structkeyexists(request.zos,'zTypeKitIncluded') EQ false>
					<script type="text/javascript">/* <![CDATA[ */ TypekitConfig = {kitId: '<cfscript>writeoutput(kitId);</cfscript>'};(function() {var tk = document.createElement('script');tk.src = '//use.typekit.com/' + TypekitConfig.kitId + '.js';tk.type = 'text/javascript';tk.async = 'true';tk.onload = tk.onreadystatechange = function() {var rs = this.readyState;if (rs && rs != 'complete' && rs != 'loaded') return;try { Typekit.load(TypekitConfig); } catch (e) {}};var s = document.getElementsByTagName('script')[0];s.parentNode.insertBefore(tk, s);})(); /* ]]> */</script>
				<cfelse>
					<script type="text/javascript" src="//use.typekit.com/<cfscript>writeoutput(kitId);</cfscript>.js"></script>
					<script type="text/javascript">/* <![CDATA[ */ try { Typekit.load(); } catch (e) {} /* ]]> */</script>
				</cfif>
			</cfsavecontent>
			<cfscript>
			request.zos.zTypeKitIncluded=true;
			</cfscript>
			</cfif>
		</cfif>
	<cfscript> 
	savecontent variable="ts44"{
		if(application.zcore.user.checkGroupAccess("user")){
			// if site_id doesn't match, the parent or global token was used
			if(structkeyexists(cookie, 'ztoken')){
				echo("var zTokenLogin=true;"); 
			}else{
				echo("var zTokenLogin=false;");
			}
		}else{
			echo("var zTokenLogin=false;");
		}
		if(request.zos.istestserver){
			echo("var zThisIsTestServer=true;");
		}else{
			echo("var zThisIsTestServer=false;");
		}
		if(request.zos.isdeveloper){
			echo("var zThisIsDeveloper=true;");
		}else{
			echo("var zThisIsDeveloper=false;");
		}
		if(application.zcore.functions.zso(request.zos.globals, "disableUpgradeMessage", true, 0) EQ 1){
			echo("var zDisableUpgradeMessage=true;"); 
		}
	}
	ss=application.siteStruct[request.zos.globals.id];
	iconMeta="";
	if(application.zcore.functions.zso(ss, 'iconLogoExists', false, false)){
		iconMeta=getIconMetaTags();
	}
	request.zosTemplatePrependTagContent={ meta:{ arrContent:[javascriptHeadCode(ts44)&kitHTML&iconMeta]} };
	request.zosTemplateAppendTagContent=structnew("sync");
	request.zosTemplateTagContent=structnew("sync");
	

	request.zosTemplateData={
		dateDisabled:dateDisabled,
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
		contentStruct : structnew("sync"),
		// tagContent : structnew("sync"),
		// prependTagContent : { meta:{ arrContent:[javascriptHeadCode(ts44)&kitHTML&iconMeta]} },
		// appendTagContent : { } ,
		tagAssoc : structnew("sync"),
		tags : ArrayNew(1),
		requiredTags : structnew("sync"),
		//prependedContent : "",
		output : "",
		vars : "",
		config : structnew("sync"),
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


<cffunction name="disableShareThis" localmode="modern">
<cfscript>
	request.zosTemplateData.disableShareThisEnabled=true;
	</cfscript>
</cffunction>

<cffunction name="disableDate" localmode="modern">
	<cfscript>
	request.zosTemplateData.dateSet=false;
	request.zosTemplateData.dateDisabled=true;
	request.zosTemplateData.lastModifiedDate='';
	</cfscript>
</cffunction>



<cffunction name="setPlainTemplate" localmode="modern">
<cfscript>
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
	</cfscript>
</cffunction>

<cffunction name="setScriptDate" localmode="modern">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	return false; 
	</cfscript>
</cffunction>

<cffunction name="setDate" localmode="modern">
	<cfargument name="newDate" type="any" required="yes">
	<cfargument name="parse" type="boolean" required="no" default="#false#">
	<cfscript>
	return;
	/*
	if(request.zosTemplateData.dateDisabled) return;
	request.zosTemplateData.dateSet=true;
	if(arguments.newDate EQ false) return;
	if(arguments.parse){
		arguments.newDate=parsedatetime(DateFormat(arguments.newDate,'yyyy-mm-dd')&' '&TimeFormat(arguments.newDate,'HH:mm:ss'));
	}
	if(request.zosTemplateData.lastModifiedDate EQ false){
		request.zosTemplateData.lastModifiedDate = arguments.newDate;
	}else if(DateCompare(request.zosTemplateData.lastModifiedDate,arguments.newDate) EQ -1){
		request.zosTemplateData.lastModifiedDate = arguments.newDate;
	}
	
	this.checkIfModifiedSince();*/
	</cfscript>	
</cffunction>

<cffunction name="checkIfModifiedSince" localmode="modern">		
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
	if(request.zosTemplateData.lastModifiedDate EQ false or request.zosTemplateData.dateSet EQ false or request.zosTemplateData.dateDisabled) return; // ignore when no date is set
	rd=gethttprequestdata();
	tz=gettimezoneinfo();
	// must parse: Sun, 06 Nov 1994 08:49:37 GMT    ; RFC 822, updated by RFC 1123

	lastMod=DateAdd("h", tz.utcHourOffset, request.zosTemplateData.lastModifiedDate);
	lastModCompare=lastMod;
	expires=DateAdd("h", tz.utcHourOffset, DateAdd("h",1,request.zosTemplateData.lastModifiedDate));
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



<cffunction name="addPath" localmode="modern">
	<cfargument name="rootRelativePath" type="string" required="yes">
	<cfargument name="absPath" type="string" required="yes">
	<cfscript>
	initPaths();
	ArrayAppend(request.zosTemplateData.arrRootRelativePath, arguments.rootRelativePath);
	ArrayAppend(request.zosTemplateData.arrAbsPath, arguments.absPath);		
	</cfscript>
</cffunction>
<cffunction name="initPaths" localmode="modern">
	<cfscript>
	if(isDefined('request.zosTemplateData.arrAbsPath') EQ false){
		request.zosTemplateData.arrRootRelativePath=ArrayNew(1);
		request.zosTemplateData.arrAbsPath=ArrayNew(1);
		// add default path at last minute
		ArrayAppend(request.zosTemplateData.arrAbsPath, request.zos.globals.homedir&'templates/');
		ArrayAppend(request.zosTemplateData.arrRootRelativePath, request.zos.globals.siteroot&"/templates/");
	}
	</cfscript>
</cffunction>
 
<cffunction name="setTemplate" localmode="modern">
	<cfargument name="template" required="yes" type="string">
	<cfargument name="isFile" required="no" type="boolean" default="#true#">
	<cfargument name="force" required="no" type="boolean" default="#false#">
	<cfscript>
	if(request.zosTemplateData.templateForced EQ false or arguments.force){
		request.zosTemplateData.isFile = arguments.isFile;
		request.zosTemplateData.template = arguments.template;
	}
	if(arguments.force){
		request.zosTemplateData.templateForced = true;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="getTemplate" localmode="modern">
	<cfscript>
	return request.zosTemplateData.template;
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

<cffunction name="abort" localmode="modern"><cfargument name="overrideContent" type="string" required="yes"><cfscript>
	var i=0;
	var finalOut=0;
	if(structkeyexists(request,'znotemplate') and request.znotemplate){
		writeoutput(trim(arguments.overrideContent));
	}else{
		this.setTag("content", trim(arguments.overrideContent), true,false);
		for(i in request.zosTemplateTagContent){
			request.zosTemplateTagContent[i].required = false;
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

<cffunction name="getTags" localmode="modern">
	<cfargument name="start" type="numeric" required="no" default="#1#">
	<cfscript>
	var matching = true;
	var arrMatches = ArrayNew(1);
	var result = structnew("sync");
	var index = 1;
	var tempStruct = structnew("sync");
	var tempTag = "";
	var arrTagAttr="";
	var matchess=1;
	var i=1;
	var resultLen=0;
	var resultPos=0;
	var pos2=0;
	var pos=0;
	/*if(findnocase("<z_content>", request.zosTemplateData.content) EQ 0){
		request.zosTemplateData.content=replacenocase(request.zosTemplateData.content, "</body>", "<z_content></body>");
	}*/
	while(matching){
		// ignore attrib="val""ue"
		i=0;
		matching = false;
		pos= findnocase('<z_', request.zosTemplateData.content, index);
		if(pos NEQ 0){
			pos2= findnocase('>', request.zosTemplateData.content, pos);
			if(pos2 NEQ 0){
				resultPos=pos;
				resultLen=(pos2-pos)+1;
				i=1;
				matching=true;
			}
		}
		if(i NEQ 0){
			if(resultPos NEQ 0){
				tempStruct = structnew("sync");
				tempStruct.content = "";
				tempStruct.isFile = false;
				tempStruct.string = mid(request.zosTemplateData.content, index, resultPos-index);

				tempTag = mid(request.zosTemplateData.content, resultPos+3, resultLen-4);
				tempStruct.tag = listgetat(tempTag,1," ");
				if(structkeyexists(request.zosTemplateTagContent, tempStruct.tag) EQ false){
					StructInsert(request.zosTemplateTagContent, tempStruct.tag,structnew("sync"),false);
					request.zosTemplateTagContent[tempStruct.tag].isFile = false;
					request.zosTemplateTagContent[tempStruct.tag].required = false;
				}
				if(structkeyexists(request.zosTemplateData.tagAssoc, tempStruct.tag) EQ false){
					request.zosTemplateData.tagAssoc[tempStruct.tag] = ArrayNew(1);
				}
				ArrayAppend(arrMatches, tempStruct);
				ArrayAppend(request.zosTemplateData.tagAssoc[tempStruct.tag],ArrayLen(arrMatches));
				index = resultPos+resultLen;
			}else{
				matching = false;
			}
		}
	}
	tempStruct = structnew("sync");
	tempStruct.content = "";
	tempStruct.isFile = false;
	tempStruct.string = mid(request.zosTemplateData.content, index, (len(request.zosTemplateData.content)-index)+1);
	tempStruct.tag = '';
	ArrayAppend(arrMatches, tempStruct);
	request.zosTemplateData.tags = arrMatches;
	</cfscript>
</cffunction>

<cffunction name="compileTemplateCFC" localmode="modern"><cfargument name="returnString" type="boolean" required="no" default="#false#"><cfscript>
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
	
	request.zosTemplateData.building=true;
	request.zosTemplateData.content = application.zcore.functions.zreadfile(request.zosTemplateData.templatePath);
	// convert to new variables
	if(request.zosTemplateData.content EQ false){
		// no template exists in any of the paths
		application.zcore.template.fail("#request.zosTemplateData.comName#: build: `#request.zosTemplateData.template#`, is not a valid template name. Path: #request.zosTemplateData.templatePath#",true);
	}
	
	request.zosTemplateData.content='
	<cfscript>
	if(request.zos.zReset EQ "template" or request.zos.zReset EQ "site"){
		_zForceReloadTemplate=true;
	}else{
		_zForceReloadTemplate=false;
	}
	</cfscript>
	<cfoutput>'&replacenocase(replacenocase(request.zosTemplateData.content,'<cfoutput>','','ALL'),'</cfoutput>','','ALL')&'</cfoutput>';
	// fix legacy code to reference the new paths
	request.zosTemplateData.content=replacenocase(request.zosTemplateData.content,"/zsa2/","/zcorerootmapping/","all"); 
	request.zosTemplateData.content=replacenocase(replacenocase(replacenocase(request.zosTemplateData.content,'<cfinclude template="/','<cfinclude template="#request.zrootpath#','all'),'<cfinclude template="#request.zrootpath#zsa2/','<cfinclude template="/zcorerootmapping/','ALL'),'<cfinclude template="#request.zrootpath#zcorerootmapping/','<cfinclude template="/zcorerootmapping/','ALL');
	request.zosTemplateData.content=replacenocase(request.zosTemplateData.content, '<cfinclude ', '<cfinclude forceReload="##_zForceReloadTemplate##" ', "all"); 
 
	
	
	this.getTags();
	arrT=arraynew(1);
	arrT2=arraynew(1);
	contentTagIndex=0;
	arrayAppend(arrT, '
	if(request.zos.whiteSpaceEnabled EQ false){
		_zcoretemplatelocalvars.result=rereplace(_zcoretemplatelocalvars.result, "\n(\s+)",chr(10),"all");
	}
	/*application.zcore.cache.setTemplateContent(_zcoretemplatelocalvars.result);*/');
			
	for(i=1;i LTE arraylen(request.zosTemplateData.tags);i++){
		if(request.zosTemplateData.tags[i].tag NEQ ""){
			if(request.zosTemplateData.tags[i].tag EQ "content"){
				contentTagIndex=i;
			}
			arrayAppend(arrT, '
			_zcoretemplatelocalvars.finalTagContent=application.zcore.template.getFinalTagContent("'&request.zosTemplateData.tags[i].tag&'");
			/*application.zcore.cache.setTag("'&request.zosTemplateData.tags[i].tag&'", "####_zcoretemplatelocalvars.ts.section'&i&'####", _zcoretemplatelocalvars.finalTagContent);*/
			_zcoretemplatelocalvars.result=replace(_zcoretemplatelocalvars.result,"####_zcoretemplatelocalvars.ts.section'&i&'####", _zcoretemplatelocalvars.finalTagContent);');
			arrayAppend(arrT2, request.zosTemplateData.tags[i].string&'####_zcoretemplatelocalvars.ts.section'&i&'####');
		}else{
			arrayAppend(arrT2, request.zosTemplateData.tags[i].string);
		}
	}
	/*if(#contentTagIndex# NEQ 0 and findnocase("####_zcoretemplatelocalvars.ts.section#contentTagIndex#####",_zcoretemplatelocalvars.result) EQ 0){
		_zcoretemplatelocalvars.result=replacenocase(_zcoretemplatelocalvars.result, "</body>", "####_zcoretemplatelocalvars.ts.section#contentTagIndex#####</body>");	
	}*/
	
	result='<cfcomponent output="yes"><cffunction name="runTemplate" localmode="modern"><cfscript>
	var _zcoretemplatelocalvars=structnew("sync");
	_zcoretemplatelocalvars.ts=structnew("sync");
	</cfscript><cfsavecontent variable="_zcoretemplatelocalvars.result">'&arraytolist(arrT2,'')&'</cfsavecontent><cfscript>
	application.zcore.functions.zExecuteCSSJSIncludes();
	'&arraytolist(arrT,'')&'
	return _zcoretemplatelocalvars.result;
	</cfscript></cffunction></cfcomponent>';
	if(left(request.zosTemplateData.templatePath, len(request.zos.globals.serverprivatehomedir&"_cache/")) EQ request.zos.globals.serverprivatehomedir&"_cache/"){
		sp=request.zos.globals.serverprivateHomeDir&"_cache/scripts/templates";
		cfcName=replace(replace(request.zosTemplateData.templatePath,".","$","all"),"/","$","all")&".cfc";
		cfcPath=sp&'/'&cfcName;
		r=application.zcore.functions.zwritefile(cfcPath,result);
		
	}else{
		sp=request.zos.globals.privateHomeDir&"_cache/scripts/templates";
		if(directoryexists(sp) EQ false){
			application.zcore.functions.zcreatedirectory(sp);
		}
		cfcName=replace(replace(replace(request.zosTemplateData.templatePath, request.zos.globals.homedir, "", "one"),".","$","all"),"/","$","all")&".cfc";
		cfcPath=sp&'/'&cfcName;
		r=application.zcore.functions.zwritefile(cfcPath,result);
	}
	
	if(request.zos.zReset EQ ""){
		request.zos.zReset="template";
	} 
	//application.zcore.functions.zClearCFMLTemplateCache();
</cfscript>
</cffunction>

<cffunction name="deleteAllTemplates" localmode="modern">
<cfscript> 
var db=request.zos.queryObject;
db.sql="select * FROM #request.zos.queryObject.table("site", request.zos.zcoreDatasource)# site 
where site_active = #db.param('1')# and 
site_deleted = #db.param(0)#";
qSite=db.execute("qSite");
for(row in qSite){
	sphd=application.zcore.functions.zGetDomainWritableInstallPath(row.site_short_domain);
	qDir=directoryList("#sphd#_cache/scripts/templates/", false, 'query');
	for(row2 in qDir){
		if(row2.name NEQ "." and row2.name NEQ ".." and row2.type EQ "file" and right(row2.name, 4) EQ ".cfc"){
			filedelete("#sphd#_cache/scripts/templates/#row2.name#");
		}
	}
}
</cfscript>
</cffunction> 

<cffunction name="getString" localmode="modern">
	<cfscript>
	return "1";
	</cfscript>
</cffunction>
<cffunction name="createTemplateObject" localmode="modern">
    <cfargument name="c" type="string" required="yes">
    <cfargument name="cpath" type="string" required="yes">
    <cfargument name="forceNew" type="boolean" required="no" default="#false#">
    <cfscript> 
    if(not structkeyexists(application.zcore,'templateCFCCache')){
        application.zcore.templateCFCCache={};
    }
    t7=application.zcore.templateCFCCache;
    if(not structkeyexists(t7, request.zos.globals.id)){
        t7[request.zos.globals.id]={};
    } 
    t9=t7[request.zos.globals.id]; 
    if(not structkeyexists(t9,arguments.cpath) or arguments.forceNew){
		try{
			if(structkeyexists(t9,arguments.cpath)){
				com=ReloadComponent(t9[arguments.cpath], true); 
			}else{
				com=createobject("component",arguments.cpath);
			}
		}catch(Any e){
			savecontent variable="e2"{
				if(application.zcore.functions.zso(e, 'message') CONTAINS '-railo-dump' or application.zcore.functions.zso(e, 'message') CONTAINS '-lucee-dump'){
					echo(e.message);
				}
				writedump(e);	
			}
			if(not fileexists(expandpath(replace(arguments.cpath, ".","/","all")&".cfc"))){
				application.zcore.functions.z404("createTemplateObject() c:"&arguments.c&"<br />cpath:"&arguments.cpath&"<br />forceNew:"&arguments.forceNew&"<br />request.zos.cgi.SCRIPT_NAME:"&request.zos.cgi.SCRIPT_NAME&"<br />catch error:"&e2);
			}else{
				rethrow;
			}
		}
        t9[arguments.cpath]=com;
    }else{
		com=t9[arguments.cpath];
	}
    return duplicate(com, true); 
    </cfscript>
</cffunction>

<cffunction name="build" localmode="modern"><cfscript> 
	var arrFinal=ArrayNew(1); 
	var runTemplate=true;
	var runCFCTemplate=false; 
	var sp=request.zos.globals.privateHomeDir&"_cache/scripts/templates"; 
	application.zcore.functions.zIncludeZOSFORMS();
	application.zcore.functions.zRequireCSSFramework(); 
	request.zosTemplateData.building=true;
	if(not structkeyexists(application.zcore, 'templateCFCCache')){
		application.zcore.templateCFCCache={};
	}
	if(not structkeyexists(application.zcore.templateCFCCache, request.zos.globals.id)){
		application.zcore.templateCFCCache[request.zos.globals.id]={};
	}
	if(request.zosTemplateData.isFile){
		request.zosTemplateData.templatePath=false; 
		if(right(request.zosTemplateData.template, 4) NEQ ".cfm"){
			runCFCTemplate=true;
			runTemplate=false;
			// modern cfc templates - all new code should use this more efficient templating.
			//zcorerootmapping.templates.administrator
			//zcorerootmapping.mvc.z.server-manager.templates.administrator
			// root.templates.default
			var cfcCreatePath=request.zosTemplateData.template;
			if(left(request.zosTemplateData.template, 5) EQ "root."){
				cfcCreatePath=request.zrootcfcpath&removechars(request.zosTemplateData.template, 1, 5);
			}
			if(request.zos.zreset EQ "template"){
				//structclear(application.zcore.templateCFCCache[request.zos.globals.id]);
				tempIO=createTemplateObject("component", cfcCreatePath, true);
			}else{
				tempIO=createTemplateObject("component", cfcCreatePath);
			}
		}else{ 
			// legacy cfm templates
			if(left(request.zosTemplateData.template,19) EQ "/zcorecachemapping/"){
				sp=request.zos.globals.serverprivateHomeDir&"_cache/scripts/templates";
				request.zosTemplateData.templatePath=request.zos.globals.serverprivatehomedir&"_cache/"&removechars(request.zosTemplateData.template,1,19);
				cfcName=replace(replace(replace(request.zosTemplateData.templatePath, request.zos.globals.homedir, "", "one"),".","$","all"),"/","$","all");
				cfcCreatePath='zcorecachemapping.scripts.templates.'&cfcName;
			}else{
				request.zosTemplateData.templatePath=request.zos.globals.homedir&"templates/"&request.zosTemplateData.template;
				cfcName=replace(replace(replace(request.zosTemplateData.templatePath, request.zos.globals.homedir, "", "one"),".","$","all"),"/","$","all");
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
				if(fileexists(request.zosTemplateData.templatePath)){
					this.compileTemplateCFC(); 
					tempIO=createTemplateObject("component",cfcCreatePath,true); 
					application.zcore.compiledSiteTemplatePathCache[request.zos.globals.id][sp&'/'&cfcName&".cfc"]=true;
				}else{
					runTemplate=false;
				}
			}else if(structkeyexists(application.zcore.compiledTemplatePathCache, sp&'/'&cfcName&".cfc")){ 
				tempIO=createTemplateObject("component",cfcCreatePath); 
			}else{ 
				if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, request.zosTemplateData.templatePath) EQ false){
					application.sitestruct[request.zos.globals.id].fileExistsCache[request.zosTemplateData.templatePath]=fileexists(request.zosTemplateData.templatePath);
				}
				if(application.sitestruct[request.zos.globals.id].fileExistsCache[request.zosTemplateData.templatePath]){
					if(structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, sp&'/'&cfcName&".cfc") EQ false){
						application.sitestruct[request.zos.globals.id].fileExistsCache[sp&'/'&cfcName&".cfc"]=fileexists(sp&'/'&cfcName&".cfc");
					}
					forceReload=false;
					if(application.sitestruct[request.zos.globals.id].fileExistsCache[sp&'/'&cfcName&".cfc"] EQ false){
						this.compileTemplateCFC(); 
						forceReload=true;
						application.sitestruct[request.zos.globals.id].fileExistsCache[sp&'/'&cfcName&".cfc"]=true;
					}
					tempIO=createTemplateObject("component",cfcCreatePath, forceReload); 
					application.zcore.compiledTemplatePathCache[sp&'/'&cfcName&".cfc"]=true;
				}else{
					runTemplate=false;
				}
			}  
		}
	}else{
		// don't compile this the same?  or just put the entire template as the struct key maybe.
		request.zosTemplateData.content = request.zosTemplateData.template; 
	}  
	if(structkeyexists(request, 'zValueOffset') and request.zValueOffset NEQ 0){
		application.zcore.template.appendTag('meta','<script type="text/javascript">/* <![CDATA[ */zArrDeferredFunctions.push(function(){zInitZValues(#request.zValueOffset#);});/* ]]> */</script>');
	} 
	if(not structkeyexists(form, 'zab')){
		if(Request.zOS.isdeveloper or request.zos.istestserver or application.zcore.user.checkAllCompanyAccess()){ 
			application.zcore.debugger.init();
		} 
	}
	retrytemplatecompile=false;
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

	if(not structkeyexists(request, 'disableGlobalHTMLHeadCode') and structkeyexists(request.zos,'inMemberArea') and request.zos.inMemberArea EQ false and structkeyexists(application.sitestruct[request.zos.globals.id], 'globalHTMLHeadSource')){
		finalString=replace(finalString, '</head>',application.sitestruct[request.zos.globals.id].globalHTMLHeadSource&'</head>');
	}
	request.zos.endtime=gettickcount('nano');
	if(request.zosTemplateData.primary and (Request.zOS.isDeveloper or request.zos.istestserver)){
		if(structkeyexists(Request,'zPageDebugDisabled') EQ false and (application.zcore.user.checkAllCompanyAccess() or request.zos.istestserver) and structkeyexists(form, 'zab') EQ false){
			request.zos.debuggerFinalString=finalString; 
			request.zos.debugbarStruct=application.zcore.debugger.getForm();
			request.zos.debugbaroutput=application.zcore.debugger.getOutput();
		}
		if(structkeyexists(form,'zOS_viewAsXML') and findNoCase('firefox', request.zos.cgi.HTTP_USER_AGENT) NEQ 0){
			finalString = replace(finalString, ' xmlns="http://www.w3.org/1999/xhtml"','');			
		}
	}
	
	request.zosTemplateData.output = finalString;
	return finalString;
	</cfscript></cffunction>

<cffunction name="getShareButton" localmode="modern">
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

 
<cffunction name="requireTag" localmode="modern">
	<cfargument name="name" required="yes" type="string">
	<cfscript>
	if(isDefined('request.zosTemplateTagContent.#arguments.name#') EQ false){
		StructInsert(request.zosTemplateTagContent, arguments.name, structnew("sync"),true);
	}
	request.zosTemplateTagContent[arguments.name].required = true;
	return true;
	</cfscript>
</cffunction>

<!--- FUNCTION: getTagContent(name); --->
<cffunction name="getTagContent" localmode="modern">
	<cfargument name="name" required="yes" type="string">
	<cfscript>
	if(structkeyexists(request.zosTemplateTagContent, arguments.name) and structkeyexists(request.zosTemplateTagContent[arguments.name],'content')){
		return request.zosTemplateTagContent[arguments.name].content;
	}else{
		return "";
	}
	</cfscript>
</cffunction>

<cffunction name="getFinalTagStruct" localmode="modern">
	<cfscript>
	var tagStruct=structnew("sync"); 
	// you can't enable new meta tags because it breaks old templates and sites that load jquery plugins the old way
	//application.zcore.functions.zEnableNewMetaTags(); 
	application.zcore.functions.zExecuteCSSJSIncludes(); 
	for(var i in request.zosTemplateData.uniqueTagStruct){
		tagStruct[i]=this.getFinalTagContent(i);
	}  
	return tagStruct;
	</cfscript>
</cffunction>

<cffunction name="getFinalTagContent" localmode="modern">
	<cfargument name="name" required="yes" type="string">
	<cfscript> 
	var prepend="";
	var append="";
	var append2="";
	zos=request.zos; 
	name=arguments.name;
	savecontent variable="out"{
		if(structkeyexists(request.zosTemplatePrependTagContent, name)){
			echo(arraytolist(request.zosTemplatePrependTagContent[name].arrContent,""));
		}
		if(structkeyexists(request.zosTemplateTagContent, name)){
			if(structkeyexists(request.zosTemplateTagContent[name], "content")){
				if(name EQ "title" or name EQ "pagetitle"){
					echo(htmleditformat(request.zosTemplateTagContent[name].content));
				}else{
					echo(request.zosTemplateTagContent[name].content);
				}
			}
		}
		if(structkeyexists(request.zosTemplateAppendTagContent, name)){
			echo(arraytolist(request.zosTemplateAppendTagContent[name].arrContent,""));
		}
		if(name EQ "scripts"){// and not structkeyexists(zos, 'disableOldZLoader')){
			if(arraylen(zos.arrScriptInclude)){
				lastScript=zos.arrScriptInclude[arraylen(zos.arrScriptInclude)]; 
				scriptIncludeStruct={"1":{},"2":{},"3":{},"4":{},"5":{}};
				for(i=1;i LTE arraylen(zos.arrScriptInclude);i++){
					script=zos.arrScriptInclude[i]; 
					if(left(script, 1) EQ '/' and left(script, 2) NEQ "//"){
						// required for domains that use http proxy connection
						scriptIncludeStruct[zos.arrScriptIncludeLevel[i]][zos.currentHostName&script]=true;
					}else{
						scriptIncludeStruct[zos.arrScriptIncludeLevel[i]][script]=true;
					} 
				}
				scriptCount=structcount(scriptIncludeStruct); 
				arrBeginFunction=[];
				arrEndFunction=[];
				for(i=1;i LTE 5;i++){
					if(structcount(scriptIncludeStruct[i])){
						arrayappend(arrBeginFunction, ', function(a){ var t=new zLoader();t.loadScripts(["'&structkeylist(scriptIncludeStruct[i],'", "')&'"]');
						arrayappend(arrEndFunction, ");}");
					}
				} 
				echo('<script type="text/javascript">/* <![CDATA[ */  
					setTimeout(function(){
						var tempM=new zLoader();tempM.loadScripts(["#zos.currentHostName##application.zcore.skin.getVersionURL("/z/javascript/jquery/jquery-1.10.2.min.js")#"]
						'&arraytolist(arrBeginFunction, "")&arrayToList(arrEndFunction,"")&'
						);
					},0); /* ]]> */</script>'); 
			}
		} 
	}
	return out;
	</cfscript>
</cffunction>
 
<!--- FUNCTION: prependTag(name, content, forceFirst); --->
<cffunction name="prependTag" localmode="modern">
	<cfargument name="name" required="yes" type="string">
	<cfargument name="content" required="yes" type="string">
	<cfargument name="forceFirst" required="no" type="boolean" default="#false#">
<cfscript>
	if(len(arguments.content) EQ 0) return;
	request.zosTemplateData.uniqueTagStruct[arguments.name]=true;
	if(structkeyexists(request.zosTemplatePrependTagContent, arguments.name) EQ false){
		request.zosTemplatePrependTagContent[arguments.name]={ arrContent=[arguments.content] };
	}else{
		if(arguments.forceFirst){
			arrayprepend(request.zosTemplatePrependTagContent[arguments.name].arrContent,arguments.content);
		}else{
			arrayappend(request.zosTemplatePrependTagContent[arguments.name].arrContent,arguments.content);
		}
	}
	</cfscript>
</cffunction>

<cffunction name="prependContent" localmode="modern">
	<cfargument name="content" type="string" required="yes">
	<cfscript>
	if(len(arguments.content) EQ 0) return;
	request.zosTemplateData.uniqueTagStruct["content"]=true;
	if(structkeyexists(request.zosTemplatePrependTagContent, "content") EQ false){
		request.zosTemplatePrependTagContent["content"]={ arrContent=[arguments.content] };
	}else{
		arrayappend(request.zosTemplatePrependTagContent["content"].arrContent,arguments.content);
	}
	</cfscript>
</cffunction>

<!--- FUNCTION: appendTag(name, content, forceFirst); --->
<cffunction name="appendTag" localmode="modern">
	<cfargument name="name" required="yes" type="string">
	<cfargument name="content" required="yes" type="string">
	<cfargument name="forceFirst" required="no" type="boolean" default="#false#">
	<cfscript>
	if(len(arguments.content) EQ 0) return;
	request.zosTemplateData.uniqueTagStruct[arguments.name]=true;
	if(structkeyexists(request.zosTemplateAppendTagContent, arguments.name) EQ false){
		request.zosTemplateAppendTagContent[arguments.name]={ arrContent=[arguments.content], arrFirst=[arguments.forceFirst] };
	}else{
		if(arguments.forceFirst){
			matched=false;
			for(i=1;i LTE arraylen(request.zosTemplateAppendTagContent[arguments.name].arrFirst);i++){
				if(request.zosTemplateAppendTagContent[arguments.name].arrFirst[i] EQ false){
					arrayinsertat(request.zosTemplateAppendTagContent[arguments.name].arrContent,i, arguments.content);
					arrayinsertat(request.zosTemplateAppendTagContent[arguments.name].arrFirst,i,true);
					matched=true;
					break;
				}
			}
			if(matched EQ false){
				arrayprepend(request.zosTemplateAppendTagContent[arguments.name].arrContent, arguments.content);
				arrayprepend(request.zosTemplateAppendTagContent[arguments.name].arrFirst,true);
			}
		}else{
			arrayappend(request.zosTemplateAppendTagContent[arguments.name].arrContent,arguments.content);
			arrayappend(request.zosTemplateAppendTagContent[arguments.name].arrFirst,false);
		}
	}
	</cfscript>
</cffunction>

<!--- FUNCTION: setTag(name, content, required, isFile); --->
<cffunction name="setTag" localmode="modern">
	<cfargument name="name" required="yes" type="string">
	<cfargument name="content" required="yes" type="string">
	<cfargument name="required" required="no" type="boolean" default="#false#">
	<cfargument name="isFile" required="no" type="boolean" default="#false#">
	<cfargument name="append" required="no" type="boolean" default="#false#">
	<cfscript>
	request.zosTemplateData.uniqueTagStruct[arguments.name]=true;
	if(arguments.append){
		if(structkeyexists(request.zosTemplateTagContent, arguments.name)){
			arguments.content = request.zosTemplateTagContent[arguments.name].content&arguments.content;
		}
	}
	request.zosTemplateTagContent[arguments.name]={
		required:arguments.required,
		isFile:arguments.isFile,
		content:arguments.content
	};
	</cfscript>
</cffunction> 

<cffunction name="getOutput" localmode="modern">
	<cfscript> 
	return request.zosTemplateData.output;
	</cfscript>
</cffunction>

<cffunction name="fail" localmode="modern" hint="Used when a critical template error occurs and result is aborted with a custom error message.">
	<cfargument name="message" type="string" required="no" default="">
	<cfargument name="throwError" type="boolean" required="no" default="#true#">
	<cfargument name="pageOutput" type="boolean" required="no" default="#false#">
	<cfargument name="templateOutput" type="boolean" required="no" default="#false#"> 
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
			writeoutput("<br /><br />Partial page output below<br /><textarea style=""width:100%;height:250;"">#HTMLEditFormat(request.zosTemplateData.output)#</textarea>");
		}
		if(arguments.templateOutput){
			writeoutput("<br /><br />Template code below<br /><textarea style=""width:100%;height:250;"">#HTMLEditFormat(request.zosTemplateData.content)#</textarea>");
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
	<cfabort>
</cffunction>

<cffunction name="replaceErrorContent" localmode="modern">
	<cfargument name="content" type="string" required="yes">
	<cfscript>
	request.zos.prependedErrorContent = arguments.content;
	</cfscript>
</cffunction>

<cffunction name="prependErrorContent" localmode="modern">
	<cfargument name="content" type="string" required="yes">
	<cfscript>
	if(structkeyexists(request.zos,'prependedErrorContent') eq false){
		request.zos.prependedErrorContent=arguments.content&'<br /><br />';
	}else{
		request.zos.prependedErrorContent&=arguments.content&'<br /><br />';
	}
	</cfscript>
</cffunction>






<cffunction name="makeTag" localmode="modern">
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