<cfcomponent displayname="Skinning Engine" output="no">
<cfoutput>
<cffunction name="onSiteStart" localmode="modern" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	arguments.ss.skinObj={};
	if(structkeyexists(application, 'sitestruct') and structkeyexists(application.siteStruct, arguments.ss.site_id) and  structkeyexists(application.sitestruct[arguments.ss.site_id], 'versionDate')){ 
		arguments.ss.versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
		application.sitestruct[arguments.ss.site_id].versionDate=arguments.ss.versionDate; 
		if(directoryexists(request.zos.globals.homedir&"zcompiled")){
			arguments.ss.zcompiledDeployed=true;
			application.sitestruct[arguments.ss.site_id].zcompiledDeployed=true;
		}
		arguments.ss.versionDate=application.sitestruct[arguments.ss.site_id].versionDate;
	}else{
		if(directoryexists(request.zos.globals.homedir&"zcompiled")){
			arguments.ss.zcompiledDeployed=true;
		}
		if(not structkeyexists(arguments.ss, 'versionDate') or structkeyexists(form, 'zforce')){ 
			arguments.ss.versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
		}
	}
	
	arguments.ss.skinObj.curCompiledVersionNumber=dateformat(request.zos.now,'yyyymmdd')&timeformat(request.zos.now,'HHmmss');
	/*if(request.zos.zreset NEQ "" and structkeyexists(form, 'zforce')){
		verifyCache(arguments.ss.skinObj, arguments.ss.site_id);
	}*/
	return arguments.ss;
	</cfscript>
</cffunction>

<cffunction name="addDeferredScript" localmode="modern" access="public" output="no">
	<cfargument name="script" type="string" required="yes">
	<cfscript>
	application.zcore.template.appendTag("scripts", '<script>/* <![CDATA[ */zArrDeferredFunctions.push(function(){#arguments.script# });/* ]]> */</script>');
	</cfscript>
</cffunction>
	
	
<cffunction name="checkCompiledJS" output="no" returntype="any" localmode="modern">
	<cfscript>
	if(not request.zos.isTestServer or structkeyexists(request, 'forceNewJS')){
		if(application.zcore.app.siteHasApp("listing")){
			application.zcore.skin.includeJS("/z/javascript-compiled/jetendo.js");
		}else{
			application.zcore.skin.includeJS("/z/javascript-compiled/jetendo-no-listing.js");
		}
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>
	
<cffunction name="onApplicationStart" localmode="modern" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript> 
	if(structkeyexists(application, 'zcore') and structkeyexists(application.zcore, 'versionDate')){
		arguments.ss.versionDate=application.zcore.versionDate;
	}else if(not structkeyexists(arguments.ss, 'versionDate')){
		arguments.ss.versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
	} 
	/*if(request.zos.zreset NEQ "" and structkeyexists(form, 'zforce')){
		verifyServerCache(arguments.ss.skinObj);
	} */
	return arguments.ss;
	</cfscript>
</cffunction>
   
<cffunction name="onCodeDeploy" localmode="modern" access="public" returntype="any" output="no">
	<!--- <cfargument name="ss" type="struct" required="yes"> --->
	<cfscript> 
	if(structkeyexists(application, 'sitestruct') and structkeyexists(application.siteStruct, request.zos.globals.id)){
		if(directoryexists(request.zos.globals.homedir&"zcompiled")){
			application.sitestruct[request.zos.globals.id].zcompiledDeployed=true;
		}
		if(not structkeyexists(application.sitestruct[request.zos.globals.id], 'versionDate')){
			application.sitestruct[request.zos.globals.id].versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
		} 
	}
	</cfscript>
</cffunction>
   <!--- 
<cffunction name="verifyCache" localmode="modern" access="public" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="site_id" type="string" required="no" default="#request.zos.globals.id#">
	<cfscript>
	// TODO: compiling is disabled until we finish deploy version of this
	return arguments.ss;
	var db=application.zcore.db.newQuery();
	if(request.zos.isTestServer){
		return arguments.ss;
	}
	tempHomeDirPath=application.zcore.functions.zGetDomainInstallPath(application.zcore.functions.zvar("shortDomain", arguments.site_id));
	directory name="qDir" directory="#tempHomeDirPath#" action="list" recurse="yes" type="file" filter="*js|*css";
	errorSent=false;
	
	for(ds in qDir){ 
		if(right(ds.name, 3) EQ "css" and right(ds.name, 4) NEQ ".css"){
			continue;
		}else if(right(ds.name, 2) EQ "js" and right(ds.name, 3) NEQ ".js"){
			continue;
		}
		if(ds.directory DOES NOT CONTAIN "/wp-admin" and ds.directory DOES NOT CONTAIN "/wp-includes" and ds.directory DOES NOT CONTAIN "/wp-content" and 
			ds.directory DOES NOT CONTAIN "/published_files" and ds.directory DOES NOT CONTAIN "/tiny_mce"){
			rootRelativePath=replace(replace(ds.directory&"/"&ds.name,"\","/","ALL"), tempHomeDirPath,"/");
			ts={};
			ts.struct=structnew();
			ts.struct.file_type=fileext;
			ts.struct.file_path=rootRelativePath;
			ts.struct.file_absolute_path=application.zcore.functions.zGetDomainInstallPath(application.zcore.functions.zvar("shortDomain", arguments.site_id))&removechars(ts.struct.file_path,1,3);
			rs=compile(ts.struct, arguments.site_id);
		}
	}
	return arguments.ss;
	</cfscript>
</cffunction>
    
	
<cffunction name="verifyServerCache" localmode="modern" access="private" returntype="any" output="no">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	// TODO: compiling is disabled until we finish deploy version of this
	return arguments.ss;
	var db=application.zcore.db.newQuery(); 
	if(request.zos.isTestServer){
		return arguments.ss;
	}
	directory name="qDir" directory="#request.zos.installPath#public/" action="list" recurse="yes" type="file" filter="*js|*css";
	writedump(QDir);abort;
	for(ds in qDir){

		if(right(ds.name, 3) EQ "css" and right(ds.name, 4) NEQ ".css"){
			continue;
		}else if(right(ds.name, 2) EQ "js" and right(ds.name, 3) NEQ ".js"){
			continue;
		}
		if(ds.directory DOES NOT CONTAIN "/tiny_mce"){
			if(structkeyexists(arguments.ss,'newestServerDateLastModified') EQ false or datecompare(ds.dateLastModified, arguments.ss.newestServerDateLastModified) EQ 1){
				arguments.ss.newestServerDateLastModified=ds.dateLastModified;
			}
			rootRelativePath="/z"&replace(replace(ds.directory&"/"&ds.name,"\","/","ALL"),"#request.zos.installPath#public/","/");
			
			ts={};
			ts.struct=structnew();
			ts.struct.file_type=fileext;
			ts.struct.file_path=rootRelativePath;
			ts.struct.file_absolute_path=request.zos.installPath&"public/"&removechars(ts.struct.file_path,1,1);
			rs=compile(ts.struct, request.zos.globals.serverid);
			
			
		}
	} 
	return arguments.ss;
	</cfscript>
</cffunction> --->
	
<cffunction name="compile" localmode="modern" access="private" output="no" returntype="struct">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	 
	var rs={
		success:true,
		arrErrors:[],
		tempFilePath:""
	};
	if(request.zos.isTestServer){
		return rs;
	} 
	if(arguments.ss.file_type EQ "js" or arguments.ss.file_type EQ "css"){ 
		if(fileexists(curTempPath)){ 
			out=application.zcore.functions.zreadfile(curTempPath); 
			if(left(arguments.ss.file_path,3) EQ "/z/"){
				ss=application.zcore;
				if(not structkeyexists(ss, 'versionDate')){
					ss.versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
				}
			}else{
				ss=application.siteStruct[request.zos.globals.id];
				if(not structkeyexists(ss, 'versionDate')){
					ss.versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
				}
			}
			out=rereplace(out, '/zv[0-9]*/', '/zv#ss.versionDate#/', 'all'); 
			application.zcore.functions.zwritefile(curTempPath, out);  
			//application.zcore.functions.zwritefile(rs.tempFilePath, out);  
		}else{ 
			arrayappend(rs.arrErrors,"Failed to run yuicompressor because file is missing: #arguments.ss.file_path#<br /><br />#curTempPath#");
			rs.success=false;
			return rs;
		}
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="disableGlobalHTMLHeadCode" localmode="modern" access="public">
	<cfscript>
	request.disableGlobalHTMLHeadCode=true;
	</cfscript>
</cffunction>
    
<cffunction name="checkGlobalHeadCodeForUpdate" localmode="modern" access="public">
	<cfscript>
	
	d=application.zcore.functions.zvarso("Global HTML Head Source Code");
	newHash=hash(d);
	if(not structkeyexists(application.sitestruct[request.zos.globals.id],'globalHTMLHeadSourceArrCSS') or application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceMD5 NEQ newHash){
		tempArrCSS=arraynew(1);
		tempArrJS=arraynew(1);
		if(d NEQ ""){
			v2=rematchnocase('<script [^>]*src="[^"]*"[^>]*>[^>]*</script>', d);
			for(i=1;i LTE arraylen(v2);i++){
				v22=refindnocase('src="([^"]*)"', v2[i], 1, true);
				n=mid(v2[i], v22.pos[2], v22.len[2]);
				if(left(n, 7) EQ "http://"){
					n=replace(n,"http://","//");
				}else if(left(n, 7) EQ "https://"){
					n=replace(n,"https://","//");
				} 
				arrayappend(temparrJS, n);
			}
			d=rereplacenocase(d,'<script [^>]*src="[^"]*"[^>]*>[^>]*</script>', '', 'all');
			v3=rematchnocase('<link [^>]*href="[^"]*"[^>]*/>',d);
			arrNonStylesheet=[];
			for(i=1;i LTE arraylen(v3);i++){
				if(find('rel="stylesheet"', v3[i]) EQ 0 and find("rel='stylesheet'", v3[i]) EQ 0 and find('rel=stylesheet', v3[i]) EQ 0){
					arrayAppend(arrNonStylesheet, v3[i]);
					continue;
				}
				v22=refindnocase('href="([^"]*)"', v3[i], 1, true);
				n=mid(v3[i], v22.pos[2], v22.len[2]);
				if(left(n, 7) EQ "http://"){
					n=replace(n,"http://","//");
				}else if(left(n, 7) EQ "https://"){
					n=replace(n,"https://","//");
				} 
				arrayappend(temparrCSS, n);
			}
			d=trim(rereplacenocase(d,'<link [^>]*href="[^"]*"[^>]*/>', '', 'all'))&arrayToList(arrNonStylesheet, chr(10));
		}
		application.sitestruct[request.zos.globals.id].globalHTMLHeadSource=d;
		application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceMD5=newHash;
		application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrCSS=tempArrCSS;
		application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrJS=tempArrJS;
	}

	</cfscript>
</cffunction>

<cffunction name="compilePackage" localmode="modern" access="public" output="yes" returntype="any">
	<cfscript>
	
	var newHash=0;
	var start3=gettickcount();
	debug=false;
	if((request.zos.isDeveloper or request.zos.isTestServer) and structkeyexists(form, 'debugSkinCompile')){
		debug=true;
	}
		
	if(debug){
		writeoutput("request.zos.globals.enableMinCat:"&request.zos.globals.enableMinCat&"<br />");
	}
	if(request.zos.globals.enableMinCat EQ 0){
		return;
	}
	tempPath=request.zos.globals.privatehomedir&"zcache/_z.system.mincat.js";
	if(not structkeyexists(application.sitestruct[request.zos.globals.id].fileExistsCache, tempPath)){
		application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath]=fileexists(tempPath);
	}
	if(application.sitestruct[request.zos.globals.id].fileExistsCache[tempPath]){
		fileObj=application.zcore.functions.zGetFileAttrib(request.zos.globals.privatehomedir&"zcache/_z.system.mincat.js");
	}else{
		fileObj=structnew();	
		fileObj.size=0;
		fileObj.dateLastModified=now();
	}
		
	if(debug){
		writeoutput(((gettickcount()-start3)/1000)&' seconds1<br />');
		start3=gettickcount();
	} 
	ts=structnew();
	ts.js=arraynew(1);
	ts.css=arraynew(1);
	cssOut="";
	jsOut="";
	
	application.zcore.app.getCSSJSIncludes(ts);
	
	if(debug){
		writeoutput(((gettickcount()-start3)/1000)&' seconds2 - after getCSSJSIncludes<br />');
		start3=gettickcount();
	}
	if(not structkeyexists(request, 'disableGlobalHTMLHeadCode')){
		for(i=1;i LTE arraylen(application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrCSS);i++){
			arrayappend(ts.css, application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrCSS[i]);
		}
		for(i=1;i LTE arraylen(application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrJS);i++){
			arrayappend(ts.js, application.sitestruct[request.zos.globals.id].globalHTMLHeadSourceArrJS[i]);
		}
	}
	if(debug){
		writedump(ts);
	}
	for(i=1;i LTE arraylen(ts.css);i++){
		c=ts.css[i];
		if(left(c,3) EQ "/z/"){
			filePath=request.zos.installPath&"public/"&removechars(c,1,3);
		}else if(left(c,8) EQ "/zthemes/"){
			filePath=request.zos.installPath&"themes/"&removechars(c,1,8);
		}else{
			filePath=request.zos.globals.homedir&removechars(c,1,1);
		}
		fileContents=application.zcore.functions.zreadfile(filePath);
		cssOut&="@@z@@"&filePath&"~"&c&"@"&chr(10)&fileContents&chr(10);
	} 
	if(debug){
		writeoutput(((gettickcount()-start3)/1000)&' seconds3 after read &amp; concat css<br />');
		start3=gettickcount();
	}
	for(i=1;i LTE arraylen(ts.js);i++){
		c=ts.js[i];
		if(left(c,3) EQ "/z/"){
			checkPath=c;  
			d2=application.zcore.functions.zreadfile(request.zos.installPath&"public/"&removechars(checkPath,1,3));
			if(debug) writeoutput("js direct:"&request.zos.installPath&"public/"&removechars(checkPath,1,3)&'<br />');
			if(d2 EQ false){
				if(debug) writeoutput('fail<br /><br />');
			}
			jsOut&=d2; 
		}else{
			checkPath=c; 
			d2=application.zcore.functions.zreadfile(request.zos.globals.homedir&removechars(checkPath,1,1));
			if(debug) writeoutput("js direct:"&request.zos.globals.homedir&removechars(checkPath,1,1)&'<br />');
			if(d2 EQ false){
				if(debug) writeoutput('fail<br /><br />');
			}
			jsOut&=d2; 
		}
	}
	
	if(debug){
		writeoutput(((gettickcount()-start3)/1000)&' seconds4 after read &amp; concat js<br />');
		start3=gettickcount();
	}
	dt=dateformat(now(),'yyyymmdd')&'.'&timeformat(now(),'HHmmss');
	if(debug){
		startTime=gettickcount();
	}
	cssSpriteMap=application.zcore.functions.zcreateobject("component", "cssSpriteMap");
	cssSpriteMap.init({
		charset:"utf-8", // the charset used to read and write CSS files
		spritePad:1, // the number of pixels between each image in the sprite image. At least 1 pixel is recommended for best browser rendering compatibility.
		disableMinify: false, // Set disableMinify to true to output CSS with perfect indenting and line breaks
		aliasStruct:{
			"/":request.zos.globals.homedir,
			// if you normal server files from a web server alias directory like this in nginx:
			// location /cssSpriteMapAlias { alias /path/to/cssSpriteMap-dot-cfc/example/alias; }
			// cssSpriteMap-dot-cfc can process the alias folder if you specify any additional folders to use when evaluating the absolute path of a file.
			// This even works when the web server alias doesn't exist, so we have a fake alias setup in the example by default
			"/zupload/":request.zos.globals.privatehomedir&"zupload/",
			"/z/":request.zos.installPath&"public/"
		},
		jpegFilePath:request.zos.globals.privatehomedir&"zcache/zspritemap.jpg", // the absolute path to the JPEG sprite image that will be output
		pngFilePath:request.zos.globals.privatehomedir&"zcache/zspritemap.png", // the absolute path to the PNG sprite image that will be output. i.e. /absolute/path/to/cssSpriteMap.jpg
		jpegRootRelativePath:"/zcache/zv#randrange(199999,999999)#/zspritemap.jpg", // the root relative path to the JPEG sprite image that will be output. i.e. /path/to/cssSpriteMap.jpg
		pngRootRelativePath:"/zcache/zv#randrange(199999,999999)#/zspritemap.png", // the root relative path to the PNG sprite image that will be output. i.e. /path/to/cssSpriteMap.jpg
		disableSpriteMap:false, // disable the sprite map feature and only concatenate and minify the CSS
		root:request.zos.globals.homedir // specify the root directory for the current web server virtual host
	
	});
	
	destinationFile=request.zos.globals.privatehomedir&"zcache/_z.system.mincat.css";
	cssSpriteMap.setCSSRoot(request.zos.globals.homedir, "/");
	rs=cssSpriteMap.convertAndReturnCSS(cssOut);
	cssSpriteMap.saveCSS(destinationFile, rs.css);
	
	if(debug){
		writeoutput(((gettickcount()-startTime)/1000)&' seconds<br>');
		cssSpriteMap.displayCSS(rs.arrCSS, rs.cssStruct);
	}
	if(debug){
		writeoutput(((gettickcount()-start3)/1000)&' seconds5 after spritemapper<br />');
		start3=gettickcount();
	}
	cd=application.zcore.functions.zGetFileAttrib(destinationFile).dateLastModified;
	
	if(debug){
		writeoutput(((gettickcount()-start3)/1000)&' seconds6 after final write<br />');
		start3=gettickcount();
	}
	application.sitestruct[request.zos.globals.id].skinObj.curCompiledVersionNumber=dateformat(cd,'yyyymmdd')&timeformat(cd,'HHmmss');
	if(debug){
		application.zcore.functions.zabort();
	} 
	</cfscript>
</cffunction>



<cffunction name="includeCSSPackage" localmode="modern" access="public" output="no" returntype="any">
<cfargument name="file_path" type="string" required="yes">
	<cfargument name="forcePosition" required="no" type="string" default="" hint="This can be set to first or last.">
	<cfargument name="package" type="string" required="no" default="" hint="Allow minification and concatenation of multiple stylesheet files">
	<cfscript>
	var ts=structnew();
	if(left(arguments.file_path,2) EQ "//" or left(arguments.file_path,1) NEQ "/"){
		application.zcore.functions.zError("skin.cfc includeCSSPackage() - file_path must be a root relative url, such as /stylesheets/style.css");
	}
	ts.type="";
	ts.url=arguments.file_path;
	ts.forcePosition=arguments.forcePosition;
	ts.package=arguments.package;
	arrayappend(request.zos.arrCSSIncludes, ts);
	</cfscript>
</cffunction> 

<cffunction name="includeJSPackage" localmode="modern" access="public" output="no" returntype="any">
<cfargument name="file_path" type="string" required="yes">
	<cfargument name="forcePosition" required="no" type="string" default="" hint="This can be set to first or last.">
	<cfargument name="package" type="string" required="no" default="" hint="Allow minification and concatenation of multiple stylesheet files">
	<cfscript>
	var ts=structnew();
	if(left(arguments.file_path,2) EQ "//" or left(arguments.file_path,1) NEQ "/"){
		application.zcore.functions.zError("skin.cfc includeJSPackage() - file_path must be a root relative url, such as /scripts/cc.js");
	}
	ts.type="";
	ts.url=arguments.file_path;
	ts.forcePosition=arguments.forcePosition;
	ts.package=arguments.package;
	arrayappend(request.zos.arrJSIncludes, ts);
	</cfscript>

</cffunction>

<cffunction name="disableMinCat" localmode="modern" access="public" output="no" returntype="any">
	<cfscript>
	request.zos.tempObj.disableMinCat=true;
	</cfscript>
</cffunction>

<!--- application.zcore.skin.includeCSS("/skins/css/style.css"); --->
<cffunction name="includeCSS" localmode="modern" access="public" output="no" returntype="any">
	<cfargument name="file_path" type="string" required="yes">
	<cfargument name="forcePosition" required="no" type="string" default="" hint="This can be set to first or last or empty string.">
	<cfscript>
	var checkPath=arguments.file_path;
	if(structkeyexists(request.zos.cssIncludeUniqueStruct, checkPath)){
		return;
	}
	var forceFirst=false;
	var templateTagName="stylesheets";
	var templateTagFunction="prependTag";
	if(left(checkPath,1) EQ "/" and left(checkPath,3) NEQ "/zv"){
		checkPath=getVersionURL(checkPath);
	} 
	request.zos.cssIncludeUniqueStruct[checkPath]=true;
	if(arguments.forcePosition EQ "first"){
		forceFirst=true;
	}else if(arguments.forcePosition EQ "last"){
		templateTagFunction="prependTag";
		templateTagName="meta";
	}  
	// if(left(checkPath, 1) EQ '/' and left(checkPath, 2) NEQ "//"){
	// 	s='<link rel="stylesheet" type="text/css"  media="none" onload="if(media!==''all'')media=''all''" href="#request.zos.currentHostName##checkPath#" />'; 
	// }else{
	// 	s='<link rel="stylesheet" type="text/css"  media="none" onload="if(media!==''all'')media=''all''" href="#checkPath#" />'; 
	// }
	if(left(checkPath, 1) EQ '/' and left(checkPath, 2) NEQ "//"){
		s='<link rel="stylesheet" type="text/css" href="#request.zos.currentHostName##checkPath#" />'; 
	}else{
		s='<link rel="stylesheet" type="text/css" href="#checkPath#" />'; 
	}
	application.zcore.template[templateTagFunction](templateTagName, s&chr(10), forceFirst); 
	return "";
</cfscript>
</cffunction>

<!--- application.zcore.skin.getVersionURL("/images/header.jpg") --->
<cffunction name="getVersionURL" localmode="modern" access="public" output="no">
	<cfargument name="link" type="string" required="yes">
	<cfscript>
	link=arguments.link;
	if(left(link, 2) EQ "//"){
		return link;
	}
	if(left(link, 1) NEQ "/"){
		throw("arguments.link, ""#arguments.link#"", must start with a slash for versioning to work.");
	}
	if(left(link, 4) EQ "/zv."){
		throw("arguments.link, ""#arguments.link#"", is already versioned.");
	}
	if(left(link, 3) EQ "/z/"){
		ss=application.zcore;
		if(not structkeyexists(ss, 'versionDate')){
			ss.versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
		}
	}else{
		ss=application.siteStruct[request.zos.globals.id];
		if(not structkeyexists(ss, 'versionDate')){
			ss.versionDate=dateformat(now(),"yyyymmdd")&timeformat(now(),"HHmmss");
		}
	}
	return "/zv"&ss.versionDate&link;
	</cfscript>
</cffunction>

<!--- application.zcore.skin.includeJS("/skins/js/script.js", "", ""); --->
<cffunction name="includeJS" localmode="modern" access="public" output="no" returntype="any">
	<cfargument name="file_path" type="string" required="yes">
	<cfargument name="forcePosition" required="no" type="string" default="" hint="This can be set to first or last or empty string.">
	<cfargument name="loadLevel" type="string" required="no" default="1">
	<cfscript>
	var checkPath=arguments.file_path;
	if(structkeyexists(request.zos.jsIncludeUniqueStruct, checkPath)){
		return;
	}
	if(left(checkPath,1) EQ "/" and left(checkPath,3) NEQ "/zv"){
		checkPath=getVersionURL(checkPath);
	} 
	request.zos.jsIncludeUniqueStruct[checkPath]=true;
	arrayappend(request.zos.arrScriptIncludeLevel, arguments.loadLevel);
	arrayappend(request.zos.arrScriptInclude, checkPath);
	return "";
	</cfscript>
</cffunction>

<cffunction name="loadJS" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	writeoutput('{arrJS:[{file:"/z/skin/view/js/blog/article.js",renderObj:"blog-article", callbackFunction: function(){ /* code here */ return "ajax loaded cb func called"; }},{file:"/z/skin/view/js/blog/comments.js", renderObj:"blog-comments", callbackFunction: function(){ return "ajax cb comments called"; }}] }');
	header name="x_ajax_id" value="#x_ajax_id#";
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="getSkinData" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	writeoutput('{"cacheIndex":"#jsstringformat(application.zcore.functions.zso(form, 'cacheIndex'))#", "query1":[["rtitle","rdate","ruser","remail"],["rtitle2","rdate2","ruser2","remail2"]],  "query2":[["rsometitle2"]]');
	for(i in form){
		writeoutput(',"#i#": "#jsstringformat(form[i])#"');
	}
	writeoutput(' }');
	header name="x_ajax_id" value="#form.x_ajax_id#";
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<!--- daily scheduled task 
/z/_com/display/skin?method=deleteOldCache --->
<cffunction name="deleteOldCache" localmode="modern" access="remote" output="yes" returntype="any">
	<cfscript>
	
	var i=0;
	var db=request.zos.queryObject;
	var fs={}
	var q=0;
	var ts=0;
	var ts1=0;
	application.zcore.functions.checkIfCronJobAllowed();
	if(request.zos.isDeveloper and not application.zcore.user.checkAllCompanyAccess()){
		application.zcore.status.setStatus(request.zsid, "Access denied.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	// this is disabled since we're going to stop caching to db
	return;
	/*
	permanentStruct={
		"zsystem.css":true,
		"listing-search-form.js":true,
		"sitemap.xml.gz":true,
		"robots.txt":true,
		"_z.system.mincat.css":true,
		"_z.system.mincat.js":true,
		"zspritemap.jpg":true,
		"zspritemap.png":true
	}
	var validStruct=duplicate(permanentStruct);
	setting requesttimeout="5000";
	// build list of valid file names from the struct in memory
	for(i in application.zcore.skinObj.fileStruct){
		ts=application.zcore.skinObj.fileStruct[i];
		validStruct["#application.zcore.functions.zGetFileName(ts.file_name)#.#ts.file_id#.#ts.file_version_number#.#ts.file_type#"]=true;
	}
	arrPath=[];
	tempPath=request.zos.globals.serverprivatehomedir&"zcache/";
	directory action="list" directory="#tempPath#" name="qDir" sort="name desc";
	for(ts in qDir){
		if(not structkeyexists(validStruct, ts.name) and left(ts.name, 2) NEQ "_z"){
			//writeoutput("delete: "&tempPath&ts.name&"<br>");
			application.zcore.functions.zdeletefile(tempPath&ts.name);
		}
	}
	db.sql="select site_id from #db.table("site", request.zos.zcoreDatasource)# 
	where site_active=#db.param(1)# and 
	site_id <> #db.param(1)# and 
	site_deleted = #db.param(0)#";
	q=db.execute("q");
	for(ts1 in q){
		writeoutput("site_id:"&ts1.site_id&"<br>");
		validStruct=duplicate(permanentStruct);
		if(not structkeyexists(application.siteStruct, ts1.site_id) or not structkeyexists(application.siteStruct[ts1.site_id], 'skinObj')) continue;
		for(i in application.siteStruct[ts1.site_id].skinObj.fileStruct){
			ts=application.siteStruct[ts1.site_id].skinObj.fileStruct[i];
			validStruct["#application.zcore.functions.zGetFileName(ts.file_name)#.#ts.file_id#.#ts.file_version_number#.#ts.file_type#"]=true;
		}
		tempPath=application.zcore.functions.zvar('privatehomedir', ts1.site_id)&"zcache/";
		directory action="list" directory="#tempPath#" name="qDir" sort="name desc";
		for(ts in qDir){
			if(not structkeyexists(validStruct, ts.name) and left(ts.name, 2) NEQ "_z"){
				//writeoutput("delete: "&tempPath&ts.name&"<br>");
				application.zcore.functions.zdeletefile(tempPath&ts.name);
			}
		}
	}
	echo('Done.');
	abort;*/
	</cfscript>
</cffunction>

<!--- application.zcore.skin.includeSkin("/skins/template/default.html"); --->
<cffunction name="includeSkin" localmode="modern" access="public" output="no" returntype="any">
	<cfargument name="file_path" type="string" required="yes">
	<cfargument name="viewdata" type="struct" required="no" default="#structnew()#">
	<cfargument name="rerun" type="boolean" required="no" default="#false#">
	<cfscript>
	var zSkinHTMLContents99="";
	var sa=false;
	var e=0;
	var cfcatch=0;
	throw("includeSkin is disabled. this code may be removed at a later date.");
	/*
	if(left(arguments.file_path,3) EQ "/z/"){
		sa=true;
	}
	if(arguments.rerun){
		if(sa){
			variables.verifyServerCache(application.zcore.skinObj);	
		}else{
			this.verifyCache(application.sitestruct[request.zos.globals.id].skinObj);
		}
	}
	request.zos.tempObj.viewData=arguments.viewdata;
	if(sa and structkeyexists(application.zcore.skinObj.fileStruct,arguments.file_path)){
		try{
			savecontent variable="zSkinHTMLContents99"{
				writeoutput(application.zcore.skinObj.fileStruct[arguments.file_path].skinCom.render(arguments.viewdata));
			}
		}catch(Any e){
			application.zcore.functions.zErrorMetaData("application.zcore.skin.includeSkin("""&arguments.file_path&"""); generated this error.<br /><br />#e.Message#<br /><br />It is easy to get confused about which file to work on since the skin system compiles your skin to a different file name.<br /><br />Make sure you fix the error in this file: "&arguments.file_path);
			rethrow;
		}
		return zSkinHTMLContents99;
	}else if(structkeyexists(application.sitestruct[request.zos.globals.id].skinObj.fileStruct,arguments.file_path)){
		try{
			savecontent variable="zSkinHTMLContents99"{
				writeoutput(application.sitestruct[request.zos.globals.id].skinObj.fileStruct[arguments.file_path].skinCom.render());
			}
		}catch(Any e){
			application.zcore.functions.zErrorMetaData("application.zcore.skin.includeSkin("""&arguments.file_path&"""); generated this error.<br /><br />#e.Message#<br /><br />It is easy to get confused about which file to work on since the skin system compiles your skin to a different file name.<br /><br />Make sure you fix the error in this file: "&arguments.file_path);
			rethrow;
		}
		return zSkinHTMLContents99;
	}else{
		if(arguments.rerun){
			application.zcore.functions.zError("application.zcore.skin.includeSkin() Failed: file_path, ""#arguments.file_path#"" doesn't exist.  Check your spelling or append ?zreset=application to the current url to rebuild the skin cache and try again.");
		}else{
			this.includeSkin(arguments.file_path, arguments.viewdata, true);	
		}
	}*/
	</cfscript>
</cffunction> 
</cfoutput>
</cfcomponent>