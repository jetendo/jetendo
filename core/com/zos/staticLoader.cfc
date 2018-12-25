<cfcomponent>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.istestserver){
		application.zcore.functions.z404("This can only be run on the test server");
	}
	application.zcore.template.setPlainTemplate();
	echo('New client-side javascript dependency loader');

	/*
features:
	Determines how to load css and javascript files in order based on their predefined dependencies
		Able to load javascript files sequentially or via ajax in the correct order
	Compiles JavaScript with google closure.  
	Build process is able to incrementally build only changed JavaScript files to reduce build time.
	Detects changes to the files, and publishes a new version
	Versions are tracked via published javascript so that file names can be renamed to higher version
	Allows static resources to set their HTTP headers so they never expire.
	Allows predefining groups of modules to be published in a single file.
	Integrated with Jetendo Core/Site deploy steps
*/


/*


problem: zOS.css and other stylesheets outside javascript can't be built because the path is restricted currently.
	I should make the build copy EVERYTHING in public to public-build - exclude that from sublime, exclude public from rsync, and rsync deploy from public-build instead of public in the future
	add these afterwards to Dependencies.js
		//"\/z\/stylesheets\/zOS.css",
		//"\/z\/stylesheets\/css-framework.css",
		//"\/z\/a\/listing\/stylesheets\/global.css",
		//"\/z\/a\/listing\/stylesheets\/listing_template.css",
/z/zcache/autoload/ files need to be published to javascript-compiled2/ so that rsync works.   This is not possible currently due to lucee readonly access.  Need to translate some of this file to php or use zSecureCommand to do it.

make new every minute cronjob called build-static.php and check for changes to js/css files every few seconds.   do incremental build to reduce deploy times, and faster testing using actual version numbers/urls.

	Make deploy process able to check for jetendo/logs/build-static-error-log.txt to ensure no errors exist before allowing deployment to continue.
	
	build separate files for "site" vs "global" to eliminate needing to publish all sites separately.  ensure the "require" syntax allows site vs global too.
		need to support Dependencies.js and AutoloadGroups.js in site root of each site.  Read these onSiteStart.

	make it so that Loader and Dependencies.js can load async


	need to process css files with the spriteMap code and also so relative urls are forced to root relative.

redo how static css and js is loaded by site?
	change the js include logic from jetendo to the new code
		this allows a static build of all the files for easier packaging and deployment without having to wait for cfml to run.
		remove the inefficient "file" table and compile concepts from jetendo.  including the "skin" engine code and css spritemap code from running on production at all.
	
	
	make the javascript loader able to pick out the new version automatically from the version json
	

	the true parameter will force browser to download page again:
		window.location.reload(true);
	
	core app and site version tracked separately.   Add option on rsync deploy page for "increment version number".   This will be new field in jetendo_setup_client_version and set application.zcore.clientVersion to the same value.
		output application.zcore.clientVersion as an HTTP header name zClientVersion and as part of the hidden field json that is used to "boot" jetendo script.  
		Change all local ajax/api calls to send a zClientVersion header.   
			Server compares with client version and returns error with status code 418 if the version doesn't match.
			If the server version has changed, trigger a client side reload button to appear.   Handle this inside the zAjax() library functions, instead of in each errorCallback.
	convert all ajax requests to zReturnJSON.   Make sure to always use struct, instead of array or string.   And append version / other request info to the struct as "_system" key.   
	instead of eval(), pass all ajax responses through a zParseJson(), which uses JSON.parseJSON() and also does version checks for a "_system", key that stores system/debug info useful to developers too.


done: need to define a javascript file that shows all the scripts that were auto-loaded already.
	
	done: concatenated files need a record that stores the lastModifiedDate and all the included files - these need to be re-generated if that changes.	 
	done: publish a version json file that has matching json package names to track versions in a file that is automatically generated.  this file is excluded from open source project.
	done: build-static run twice, doesn't use cached compile json correctly now - bug fix needed.
	done: log compile errors in a json format. 
	done: i could define them all in one place 
	done: rewrite the code to lazy load file via javascript
	done: modify the jquery first js file that is included to include all other files that don't depend on jquery including the json for all package versions.
	done: put all required packages for the current page inside a hidden form field in scripts tag.   Determine load order from the version json, instead of needing to code the order all the time.
		make includeJS/includeCSS refer to the package names instead of the full file path.
	done: manually list every javascript file in one file as json.  give them unique package names and setup their dependencies?
	done: start new sub-process for each change found to minify and version it.
	done: publish to new build directory with version number in filename.
	
	*/
	//request.zos.disableOldZLoader=true;

	request.cssStruct={};
	request.javascriptStruct={};
	request.javascriptPackageStruct={};
	request.cssPackageStruct={};

	js("jquery-galleryview");
	js("jetendo-core");
	js("jquery");
	js("jquery-parallax-slider");
	js("jquery-ui");
	//css("/stylesheets/style.css");

	appVersion=1;
	compiledStruct=loadJSONVarFile(request.zos.installPath&"public/javascript-compiled2/CompiledPackages.js");
	dependStruct=loadJSONVarFile(request.zos.installPath&"public/javascript/jetendo-core/Dependencies.js");


	changesDetected=false;
	autoloadStruct=loadJSONVarFile(request.zos.installPath&"public/javascript/jetendo-core/AutoloadGroups.js");
	if(not structkeyexists(application, 'autoloadStruct')){
		application.autoloadStruct=autoloadStruct; 
	}
	a=serializeJSON(autoloadStruct);
	b=serializeJSON(application.autoloadStruct);
	if(compare(a, b) NEQ 0){
		changesDetected=true;			
	} 
	if(!fileexists(request.zos.globals.serverPrivateHomeDir&"zcache/global/autoload/build-info.js")){
		changesDetected=true;
	}  

	request.excludeLoadFileStruct={};
	testPackages=true;
	// build status detects changes by mistake sometimes still because this is not integrated with build-static yet
	if(testPackages){
		if(request.zos.isTestServer){
			statusStruct=getBuildStatus(appVersion, compiledStruct); 
			if(changesDetected or statusStruct.changesDetected){
				//writedump(changesDetected);			writedump(statusStruct.changesDetected);abort;
				generateAutoloadFiles(appVersion, autoloadStruct, statusStruct, compiledStruct, dependStruct); 
				statusStruct=getBuildStatus(appVersion, compiledStruct);
				if(statusStruct.version EQ 0){
					throw("generateAutoloadFiles failed somehow. statusStruct.version can't be 0.");
				}
			}
		} 
	}

	// You should force jsPackage to run when debugging the package behavior.
	if(testPackages or not request.zos.isTestServer){
		jsPackage("jetendo");
	}
	loadSequence(compiledStruct, dependStruct);
	outputCSSJS(compiledStruct);



	</cfscript>


</cffunction> 

<cffunction name="loadJSONVarFile" localmode="modern" access="public">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	c=application.zcore.functions.zreadfile(arguments.path); 
	p=find(chr(10), c);
	c="{"&mid(c, p, len(c)-p-2)&"}";
	return deserializeJSON(c);
	</cfscript>
</cffunction>


<cffunction name="getBuildStatus" localmode="modern" access="public">
	<cfargument name="appVersion" type="string" required="yes">
	<cfargument name="compiledStruct" type="struct" required="yes">
	<cfscript> 
	rs={
		version:0,
		changesDetected:false
	};
	if(structkeyexists(application, 'buildInfoCache')){
		buildInfo=application.buildInfoCache;
	}else{
		path=request.zos.globals.serverPrivateHomeDir&"zcache/global/autoload/";
		if(fileexists(path&"build-info.js")){
			buildInfo=deserializeJSON(application.zcore.functions.zreadfile(path&"build-info.js"));
		}else{
			rs.version=0;
			rs.changesDetected=true;
			return rs;
		}
	}
	if(not isStruct(buildInfo) or not structkeyexists(buildInfo, 'appVersion') or buildInfo.appVersion NEQ arguments.appVersion){
		rs.changesDetected=true;
		rs.version=0;
	}else{
		for(file in buildInfo.arrFile){
			if(not structkeyexists(arguments.compiledStruct.arrFile, file) or arguments.compiledStruct.arrFile[file].lastModifiedDate NEQ buildInfo.arrFile[file].lastModifiedDate){ 
				writedump(file&" date doesn't match<br>");
				rs.changesDetected=true;
				break;
			}
			request.excludeLoadFileStruct[file]=true;
		}
		rs.version=buildInfo.version+1;
	}
	if(not rs.changesDetected){
		application.buildInfoCache=buildInfo;
	}
	return rs;
	</cfscript>
</cffunction>
	


<cffunction name="generateAutoloadFiles" localmode="modern" access="public">
	<cfargument name="appVersion" type="string" required="yes">
	<cfargument name="autoloadStruct" type="struct" required="yes">
	<cfargument name="statusStruct" type="struct" required="yes">
	<cfargument name="compiledStruct" type="struct" required="yes">
	<cfargument name="dependStruct" type="struct" required="yes">
	<cfscript>
	path=request.zos.globals.serverPrivateHomeDir&"zcache/global/autoload/"; 
	application.zcore.functions.zCreateDirectory(path);
 
	buildInfo={
		arrFile:{},
		arrGroup:{},
		appVersion:arguments.appVersion,
		version:arguments.statusStruct.version
	};
	for(group in arguments.autoloadStruct){
		packages=arguments.autoloadStruct[group];

		loadEverything=false;
		for(i=1;i<=arraylen(packages);i++){
			if(packages[i] EQ "*"){
				loadEverything=true;
				break;
			}
		}
		if(loadEverything){
			packages=[];
			for(i in arguments.dependStruct.arrFile){
				arrayAppend(packages, i);
			}
		}
		sequenceStruct=buildSequentialArray(arguments.compiledStruct, arguments.dependStruct, packages);

		arrOut=[];
		for(i=1;i<=arraylen(sequenceStruct.arrCSS);i++){
			file=sequenceStruct.arrCompiledCSS[i];
			if(left(file, 3) EQ "/z/"){
				filePath=request.zos.installPath&"public/"&removeChars(file,1,3);
				filePath2=request.zos.installPath&"public/"&removeChars(sequenceStruct.arrCSS[i],1,3);
			}else{
				filePath=request.zos.globals.homedir&removechars(file, 1,1);
				filePath2=request.zos.globals.homedir&removeChars(sequenceStruct.arrCSS[i],1,1);
			}
			arrayAppend(arrOut, application.zcore.functions.zReadFile(filePath));
			arrayAppend(arrOut, 'Jetendo.loadedFiles["'&jsstringformat(sequenceStruct.arrCSS[i])&'"]=true;');
			fileInfo=getfileinfo(filePath2);
			buildInfo.arrFile[sequenceStruct.arrCSS[i]]={
				"lastModifiedDate":dateformat(fileInfo.lastModified, "yyyymmdd")&timeformat(fileInfo.lastModified, "HHmmss")
			};
		}
		application.zcore.functions.zwritefile(path&group&"."&arguments.appVersion&"."&buildInfo.version&".css", arrayToList(arrOut, chr(10)), "660", true);
 
		arrOut=[];
		for(i=1;i<=arraylen(sequenceStruct.arrJS);i++){
			file=sequenceStruct.arrCompiledJS[i];
			if(left(file, 3) EQ "/z/"){
				filePath=request.zos.installPath&"public/"&removeChars(file,1,3);
				filePath2=request.zos.installPath&"public/"&removeChars(sequenceStruct.arrJS[i],1,3);
			}else{
				filePath=request.zos.globals.homedir&removechars(file, 1,1);
				filePath2=request.zos.globals.homedir&removeChars(sequenceStruct.arrJS[i],1,1);
			}
			arrayAppend(arrOut, application.zcore.functions.zReadFile(filePath));
			arrayAppend(arrOut, 'Jetendo.loadedFiles["'&jsstringformat(sequenceStruct.arrJS[i])&'"]=true;');
			fileInfo=getfileinfo(filePath2);

			buildInfo.arrFile[sequenceStruct.arrJS[i]]={
				"lastModifiedDate":dateformat(fileInfo.lastModified, "yyyymmdd")&timeformat(fileInfo.lastModified, "HHmmss")
			};
		}

		application.zcore.functions.zwritefile(path&group&"."&arguments.appVersion&"."&buildInfo.version&".js", arrayToList(arrOut, chr(10)), "660", true);

		buildInfo.arrGroup[group]={
			jsUrlPath:"/z/zcache/autoload/"&group&"."&arguments.appVersion&"."&buildInfo.version&".js",
			cssUrlPath:"/z/zcache/autoload/"&group&"."&arguments.appVersion&"."&buildInfo.version&".css",
		}

	}
	application.buildInfoCache=buildInfo;
	application.zcore.functions.zwritefile(path&"build-info.js", serializeJSON(buildInfo), "660", true);
	</cfscript>
	
</cffunction>
	
<cffunction name="loadSequence" localmode="modern" access="public">
	<cfargument name="compiledStruct" type="struct" required="yes">
	<cfargument name="dependStruct" type="struct" required="yes">
	<cfscript>
	dependStruct=arguments.dependStruct;
	//writedump(dependStruct);
	cssStruct={};
	for(i in dependStruct.arrFile){
		c=dependStruct.arrFile[i];
		
		arrCSS=[];
		for(n2=1;n2 LTE arraylen(c);n2++){
			c2=c[n2];
			for(n=1;n LTE arraylen(c2);n++){
				if(right(c2[n], 4) EQ ".css"){
					arrayAppend(arrCSS, c2[n]);
				}
			}
		}
		if(arraylen(arrCSS)){
			cssStruct[i]=arrCSS;
		}
	}
	//writedump(cssStruct);  
	sequenceStruct=buildSequentialArray(arguments.compiledStruct, dependStruct, structkeyarray(request.javascriptStruct));

	//writedump(sequenceStruct);

	request.arrJS=[];
	for(i=1;i<=arraylen(sequenceStruct.arrJS);i++){
		/*arrayAppend(request.arrJS, '<script type="text/javascript">var a=document.createElement("script");
		a.async=true;
		a.src="#sequenceStruct.arrJS[i]#";
		document.getElementsByTagName("head")[0].appendChild(a);</script>');*/
		if(not structkeyexists(request.excludeLoadFileStruct, sequenceStruct.arrJS[i])){
			arrayAppend(request.arrJS, '<script type="text/javascript" defer="defer" src="#sequenceStruct.arrJS[i]#"></script>');
		}
	}
	for(i=1;i<=arraylen(sequenceStruct.arrCSS);i++){
		css(sequenceStruct.arrCSS[i]);
	}
	</cfscript>
	
</cffunction>

<cffunction name="getCompiledFile" localmode="modern" access="private">
	<cfargument name="compiledStruct" type="struct" required="yes">
	<cfargument name="filePath" type="string" required="yes">
	<cfscript>
	if(structkeyexists(arguments.compiledStruct.arrFile, arguments.filePath)){
		compileInfo=arguments.compiledStruct.arrFile[arguments.filePath];
		return compileInfo.urlPath;
	}else{
		return arguments.filePath;
	}
	</cfscript>
</cffunction>

<cffunction name="buildSequentialArray" localmode="modern" access="private">
	<cfargument name="compiledStruct" type="struct" required="yes">
	<cfargument name="dependStruct" type="struct" required="yes">
	<cfargument name="files" type="array" required="yes">
	<cfscript> 
	// this is for single js file output 
	sequenceStruct={
		arrCompiledJS:[],
		arrCompiledCSS:[],
		arrJS:[],
		arrCSS:[],
		uniqueObj:{}
	};

	for(i=1;i<=arraylen(arguments.files);i++){
		name=arguments.files[i];
		if(not structkeyexists(arguments.dependStruct.arrFile, name)){
			throw("Invalid js package name:"&name);
		} 
		loadSynchronousPackage(arguments.compiledStruct, arguments.dependStruct, name, sequenceStruct); 
	}
	structdelete(sequenceStruct, 'uniqueObj');
	return sequenceStruct; 
	</cfscript>
</cffunction>

<cffunction name="loadSynchronousPackage" localmode="modern" access="private">
	<cfargument name="compiledStruct" type="struct" required="yes">
	<cfargument name="dependStruct" type="struct" required="yes">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="sequenceStruct" type="struct" required="yes">
	<cfscript> 
	if(structkeyexists(arguments.sequenceStruct.uniqueObj, arguments.name)){ 
		return;
	} 
	var loadFiles=arguments.dependStruct.arrFile[arguments.name];
	for(n=1;n<=arraylen(loadFiles);n++){ 
		var n2=loadFiles[n]; 
		for(var n3=1;n3<=arraylen(n2);n3++){
			var jsFile=n2[n3];
			if(structkeyexists(arguments.sequenceStruct.uniqueObj, jsFile)){ 
				continue;
			} 
			if(right(jsFile, 4) == ".css"){ 
				//throw("Loading css this way is not implemented.");
				arrayAppend(arguments.sequenceStruct.arrCSS, jsFile); 
				arrayAppend(arguments.sequenceStruct.arrCompiledCSS, getCompiledFile(arguments.compiledStruct, jsFile)); 
			}else if(right(jsFile, 3) == ".js"){
				// load js file
				arrayAppend(arguments.sequenceStruct.arrJS, jsFile); 
				arrayAppend(arguments.sequenceStruct.arrCompiledJS, getCompiledFile(arguments.compiledStruct, jsFile));  
			}else{ 
				loadSynchronousPackage(arguments.compiledStruct, arguments.dependStruct, jsFile, arguments.sequenceStruct);  
			}
			arguments.sequenceStruct.uniqueObj[jsFile]=true;
		}
	}
	</cfscript>
</cffunction>

<cffunction name="outputCSSJS" localmode="modern" access="public">
	<cfargument name="compiledStruct" type="struct" required="yes">
	<cfscript>
	arrCSS=[];
	arrCSSLoaded=[];

	/*sequenceStruct=buildSequentialArray(compiledStruct);
	for(i=1;i<=arraylen(sequenceStruct.arrCSS);i++){
		request.cssStruct[sequenceStruct.arrCSS[i]]=true;
	}*/ 

	for(i in request.cssStruct){
		if(not structkeyexists(request.excludeLoadFileStruct, i)){
			arrayAppend(arrCSS, '<link rel="stylesheet" type="text/css" href="#i#" />');
		}
		arrayAppend(arrCSSLoaded, i);//'Jetendo.loadedFiles["'&jsStringFormat(i)&'"]=true;');
	}
	//writedump(request.javascriptStruct);
	application.zcore.template.prependTag('scripts', '<script type="text/javascript">var Jetendo={loadCount:0,loadedFiles:{}};</script>');
	jsCount=10+structcount(request.javascriptPackageStruct);
	for(i in request.javascriptPackageStruct){
		application.zcore.template.appendTag('scripts', '<script type="text/javascript"  src="'&i&'"></script>');
	}
	for(i in request.javascriptPackageStruct){
		arrayAppend(arrCSS, '<link rel="stylesheet" type="text/css" href="#i#" />');
	}
	application.zcore.template.prependTag('stylesheets', arrayToList(arrCSS, chr(10)));
	// <input type="hidden" name="JetendoDependJS" id="JetendoDependJS" data-count="#jsCount#" data-loaded="#htmleditformat(arrayToList(arrCSSLoaded,","))#" value="#structkeylist(request.javascriptStruct)#" />
	application.zcore.template.appendTag('scripts', '<script type="text/javascript" defer="defer" src="/z/javascript/jetendo-core/Dependencies.js"></script>
		<script type="text/javascript" defer="defer" src="/z/javascript/jetendo-core/Loader.js"></script>
		#arrayToList(request.arrJS, chr(10))#
		<script type="text/javascript" defer="defer" src="/z/javascript/jetendo-core/custom.js"></script>');
	// 
		//#arrayToList(arrCSSLoaded, chr(10))#
	</cfscript>
</cffunction>

<cffunction name="css" localmode="modern" access="public">
	<cfargument name="urlPath" type="string" required="yes">
	<cfscript>
	request.cssStruct[arguments.urlPath]=true;
	</cfscript>
</cffunction>
	
<cffunction name="js" localmode="modern" access="public">
	<cfargument name="urlPath" type="string" required="yes">
	<cfscript>
	request.javascriptStruct[arguments.urlPath]=true;   
	</cfscript>
</cffunction>
<cffunction name="jsPackage" localmode="modern" access="public">
	<cfargument name="packageName" type="string" required="yes">
	<cfscript>
	if(not structkeyexists(application, 'buildInfoCache')){
		path=request.zos.globals.serverPrivateHomeDir&"zcache/global/autoload/"; 
		application.buildInfoCache=deserializeJSON(application.zcore.functions.zreadfile(path&"build-info.js"));
	}
	if(not structkeyexists(application.buildInfoCache.arrGroup, arguments.packageName)){
		throw("Invalid package name: "&packageName&" | Must be an AutoloadGroup.");
	}
	buildInfo=application.buildInfoCache.arrGroup[arguments.packageName];
	request.javascriptPackageStruct[buildInfo.jsUrlPath]=true;   
	request.cssPackageStruct[buildInfo.cssUrlPath]=true;   
	//request.javascriptStruct[buildInfo.urlPath]=true;   
	</cfscript>
</cffunction>
</cfcomponent>