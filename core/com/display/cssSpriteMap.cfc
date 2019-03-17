<!--- 
cssSpriteMap.cfc
Version: 0.1.000

Project Home Page: https://www.jetendo.com/manual/view/current/2.1/db-dot-cfc.html
Github Home Page: https://github.com/jetendo/db-dot-cfc

Licensed under the MIT license
http://www.opensource.org/licenses/mit-license.php
Copyright (c) 2013 Far Beyond Code LLC.
--->
<cfcomponent>
<cfoutput> 
<cffunction name="init" access="public" output="no" localmode="modern">
<cfargument name="config" type="struct" required="yes">
<cfscript>
	var root=expandPath("/");
	this.config={
		charset:"utf-8",
		spritePad:1,
		disableMinify:false,
		jpegFilePath:root&"/cssSpriteMap.jpg",
		pngFilePath:root&"/cssSpriteMap.png",
		jpegRootRelativePath:"/cssSpriteMap.jpg",
		pngRootRelativePath:"/cssSpriteMap.png",
		disableSpriteMap:false,
		root:root,
	};
	structappend(this, this.config, true);
	aliasStruct={"/":root};
	structappend(this, arguments.config, true);
	variables.initRun=true;
</cfscript>
</cffunction>


<cffunction name="saveCSS" returntype="boolean" access="public" output="false" localmode="modern">
<cfargument name="filePath" required="yes" type="string">
<cfargument name="srcString" required="yes" type="string">
<cfscript>
var tempUnique='###getTickCount()#';
</cfscript>
<cfif arguments.filePath NEQ "">
    <cftry>
	<cffile addnewline="no" action="write" nameconflict="overwrite" charset="utf-8" file="#arguments.filePath##tempUnique#" output="#arguments.srcString#">
	<cfif compare(arguments.filePath&tempUnique , arguments.filePath) NEQ 0>
	    <cflock name="cssSpriteMap|#arguments.filePath#" timeout="60" type="exclusive">
		<cffile action="rename" nameconflict="overwrite" source="#arguments.filePath##tempUnique#" destination="#arguments.filePath#">
	    </cflock>
	</cfif>
	<cfcatch type="any">
				<cfscript>
	    throw('Failed to save css. arguments.filePath=#arguments.path#',true);
	    </cfscript>
	</cfcatch>
    </cftry>
<cfelse>
    <cfscript>
    throw('Failed to save css. arguments.filePath=#arguments.path#',true);
    </cfscript>
</cfif>
<cfreturn true>
</cffunction>

<cffunction name="setCSSRoot" access="public" output="no" localmode="modern">
	<cfargument name="rootPath" type="string" required="yes">
	<cfargument name="rootRelativePath" type="string" required="yes">
	<cfscript>
	variables.cssRootPath=arguments.rootPath;
	variables.cssRootRelativePath=arguments.rootRelativePath;
	</cfscript>
</cffunction>

<cffunction name="loadCSSFile" access="public" output="no" localmode="modern">
	<cfargument name="cssFilePath" type="string" required="yes">
	<cfscript>
	var css=0;
	variables.cssRootPath=getdirectoryfrompath(arguments.cssFilePath);
	if(arguments.cssFilePath  EQ  ""  OR  replace(arguments.cssFilePath, "./", "", "all") NEQ arguments.cssFilePath  OR  mid(arguments.cssFilePath, len(arguments.cssFilePath)-3,4) NEQ ".css" or not fileexists(arguments.cssFilePath)){
		throw("All CSS file in the array must end with .css and be an absolute path.","all");
	}
	fileHandle=fileopen(arguments.cssFilePath, "read", "utf-8");
	css=replace(replace(fileread(fileHandle), chr(10), " ", "all"), chr(13),"", "all");
	fileclose(fileHandle);
	return css;
	</cfscript>
</cffunction>


<!--- cssSpriteMap.loadCSSFileArray([{absolutePath:"",relativePath:""}]; --->
<cffunction name="loadCSSFileArray" output="no" access="public" localmode="modern">
	<cfargument name="arrCSSFile" type="array" required="yes">
	<cfscript>
	
	var e=0;
	var a=0;
	arrCSS=[];
	for(i=1;i LTE arraylen(arguments.arrCSSFile);i++){
		a=arguments.arrCSSFile[i].absolutePath;
		if(a  EQ  ""  OR  replace(a, "./", "", "all") NEQ a  OR  mid(a, len(a)-3,4) NEQ ".css" or not fileexists(a)){
			throw("All CSS file in the array must end with .css and be an absolute path.","all");
		}
		try{
			arrayappend(arrCSS, '@@z@@'&a&'~'&arguments.arrCSSFile[i].relativePath&'@'&fileread(a, this.charset));
		}catch(Any e){
			throw("CSS File doesn't exist: "&a, "custom");
		}
	}
	return arraytolist(arrCSS, chr(10));
	</cfscript>
</cffunction>

<cffunction name="convertAndReturnCSS" access="public" returntype="struct" output="no" localmode="modern">
<cfargument name="css" type="string" required="yes">
<cfscript>
	
	if(not structkeyexists(variables,'initRun')){
		this.init();
	}
	if(not structkeyexists(variables,'cssRootPath') or variables.cssRootPath EQ ""){
		throw("cssSpriteMap.setCSSRoot() must be called before cssSpriteMap.convertAndReturnCSS()", "custom");
	}
	if(trim(arguments.css) EQ ""){
		throw("this.css must be set before calling convert.", "custom");
	}
	variables.arrAlias=structkeyarray(this.aliasStruct);
	arraysort(variables.arrAlias, "text", "desc");
	arrCSS=variables.parseCSSString(arguments.css);
	rs=variables.getImagesFromParsedCSS(arrCSS);
	rs=variables.generateSpriteMaps(rs);
	s=variables.rebuildCSS(arrCSS, rs);
	return { arrCSS:arrCSS, cssStruct:rs, css:s};
	</cfscript>
</cffunction>



<cffunction name="displayCSS" access="public" output="yes" localmode="modern">
<cfargument name="arrCSS" type="array" required="yes">
<cfargument name="imageStruct" type="struct" required="yes">
<cfscript>
	html="<h2>Use the CSS class names below in your code</h2>";
	css="";
	css2="";
	cssPrefix="sn-";
	count=0;
	for(key=1;key LTE arraylen(arguments.arrCSS);key++){
		curValue=arguments.arrCSS[key];
		if(curValue.type  EQ  "rules"){
			for(i=1;i LTE arraylen(curValue.arrProperty);i++){
				c=curValue.arrProperty[i];
				if(c.name  EQ  "background-image"){
					if(this.disableSpritemap EQ 0){
						match=false;
						if(structkeyexists(c, 'imageIndex') and c.imageIndex GT 0){
							match=true;
							curSpriteFile=this.jpegRootRelativePath;
							ts=arguments.imageStruct.imageStruct[arguments.imageStruct.arrLookupImage[c.imageIndex]];
						}else if(structkeyexists(c, 'transparentIndex') and c.transparentIndex GT 0){
							match=true;
							curSpriteFile=this.pngRootRelativePath;
							ts=arguments.imageStruct.imageTransparentStruct[arguments.imageStruct.arrLookupTransparent[c.transparentIndex]];
						}
						if(match){
							if(ts.selector NEQ ""){
								t9=listtoarray(ts.selector, "{");
								className=t9[1];
							}else{
								className=cssPrefix&count;//"";
							}
							count++;
							tempClass="."&cssPrefix&count;
							c444=' class="'&cssPrefix&count&'"';
							html&='<h2>'&className&'</h2> <div style="width:'&ts.width&'px; height:'&ts.height&'px;  margin-bottom:10px; clear:both;" '&c444&'></div><hr />';
							css&=""&className&"{width:"&ts.width&"px; height:"&ts.height&"px; background-image:url("&curSpriteFile&"); background-position:"&(ts.left-this.spritePad)&"px "&(ts.top-this.spritePad)&"px; background-repeat:no-repeat; } "&chr(10);
							css2&=""&tempClass&"{width:"&ts.width&"px; height:"&ts.height&"px; background-image:url("&curSpriteFile&"); background-position:"&(ts.left-this.spritePad)&"px "&(ts.top-this.spritePad)&"px; background-repeat:no-repeat; } "&chr(10);
						}
						
					}
				}
			}
		}
	}
	writeoutput('<html><head><title>CSS Sprite Map Generator</title><style type="text/css">'&css2&'</style></head><body style="margin:10px;"><h1>CSS Sprite Map Generator</h1>');
	if(count){
		writeoutput('<p>Sprite map image(s) were created from all images with "background-repeat:no-repeat" or "background:##FFF url(image.jpg) no-repeat" shorthand in the CSS. To prevent an image from being in the sprite map, use "background-repeat:no-repeat !important;".</p>');
		writeoutput('<div style="width:100%; "><h2>JPEG Sprite Map</h2><img src="'&this.jpegRootRelativePath&'" style="border:2px solid ##999;" alt="JPEG Sprite Map" /></div>');
		writeoutput('<div style="width:100%; "><h2>PNG Sprite Map (Preserves Alpha Channel Transparency)</h2><img src="'&this.pngRootRelativePath&'" style="border:2px solid ##999;" alt="PNG Sprite Map" /></div>');
		writeoutput('<h2>CSS Styles Generated</h2> <div style="width:100%; "><textarea name="d11" id="d11" cols="90" rows="10">'&css&'</textarea><br />'&html&'</div>');
	}else{
		writeoutput('<p>No images could be converted into a css sprite map.</p>');	
	}
	writeoutput('</body></html>');
	</cfscript>
</cffunction>

<!--- private methods below --->

<cffunction name="forceAbsoluteDir" access="private" output="no" returntype="string" localmode="modern">
<cfargument name="path" type="string" required="yes">
<cfargument name="filePath" type="string" required="yes">
<cfargument name="rootPath" type="string" required="yes">
<cfscript>
	
	var arrN=[];
	if(mid(arguments.path,1,1) EQ "/"){
		arguments.path=arguments.rootPath&removechars(arguments.path,1,1);
	}else{
		arguments.path=arguments.filePath&arguments.path;
	}
	arr3=listtoarray(arguments.rootPath, "/");
	arrN2=[];
	count3=arraylen(arr3)
	for(i2=1;i2 LTE count3;i2++){
		if(arr3[i2] NEQ ""){
			arrayappend(arrN2, arr3[i2]);	
		}
	}
	arr2=listtoarray(arguments.path, "/");
	count=arraylen(arr2);
	for(i2=1;i2 LTE count;i2++){
		c2=arr2[i2];	
		if(c2 EQ ""){
			continue;	
		}else if(c2 EQ "."){
			continue;
		}else if(c2 EQ ".."){
			if(arraylen(arrN) GT arraylen(arrN2)-1){
				arraydeleteat(arrN, arraylen(arrN));
			}
		}else{
			arrayappend(arrN, c2);	
		}
	}
	return "/"&arraytolist(arrN, "/");
	</cfscript>
</cffunction>

<cffunction name="indexAscending" access="private" output="no" localmode="modern">
<cfargument name="a" type="any" required="yes">
<cfargument name="b" type="any" required="yes">
<cfscript>
if(arguments.a.curIndex EQ  arguments.b.curIndex){
    return 0 ; 
}
if(arguments.a.curIndex LT arguments.b.curIndex){
    return -1;
}else{
    return 1;
}
</cfscript>
</cffunction>
<cffunction name="widthDescending" access="private" output="no" localmode="modern">
<cfargument name="a" type="any" required="yes">
<cfargument name="b" type="any" required="yes">
<cfscript>
if(arguments.a.width EQ  arguments.b.width){
    return 0 ; 
}
if(arguments.a.width GT arguments.b.width){
    return -1;
}else{
    return 1;
}
</cfscript>
</cffunction>
<cffunction name="widthDescending" access="private" output="no" localmode="modern">
<cfargument name="a" type="any" required="yes">
<cfargument name="b" type="any" required="yes">
<cfscript>
if(arguments.a.height EQ  arguments.b.height){
    return 0 ; 
}
if(arguments.a.height GT arguments.b.height){
    return -1;
}else{
    return 1;
}
</cfscript>
</cffunction>

<cffunction name="generateSpriteMap" access="private" output="no" localmode="modern">
	<cfargument name="arrImage2" type="array" required="yes">
	<cfargument name="spriteMapFile" type="string" required="yes">
	<cfscript>
		application.zcore.functions.z404("feature disabled");
		
		var imageCount=arraylen(arguments.arrImage2);
		var transparent=false;
		var uniqueStruct={};
		if(not imageCount) return arguments.arrImage2;
		imageStruct={};
		for(i=1;i LTE imageCount;i++){
			arrTemp=listtoarray(arguments.arrImage2[i], "?");
			curPath9=arrTemp[1];
			if(structkeyexists(uniqueStruct, curPath9)){
				ts={};
				ts.selector="";
				ts.top=0;
				ts.left=0;
				ts.curIndex=i;
				ts.referenceIndex=uniqueStruct[curPath9];
				ts.width=0;
				ts.height=0;
			ts.image=arrTemp[1];
			imageStruct[i]=ts;
				continue;
			}
			r=imageread(curPath9);
			if(isStruct(r)){
			ts={};
			ts.source=r;
			ts.curIndex=i;
			ts.selector="";
			ts.left=0;
			ts.top=0;
			ts.width=r.width+(this.spritePad*2);
			ts.height=r.height+(this.spritePad*2);
			ts.image=arrTemp[1];
		
			ext=mid(arrTemp[1], len(arrTemp[1])-3,4);
			if(ext EQ ".png" or ext EQ ".gif"){
				transparent=true;
			}
			ts.ext=ext;
			imageStruct[i]=ts;
		}else{
			ts={};
			ts.width=0;
			ts.height=0;
			ts.left=0;
			ts.top=0;
			ts.curIndex=i;
			imageStruct[i]=ts;
		}
		uniqueStruct[curPath9]=i;
	}
		
	arrKey=structsort(imageStruct, "numeric", "desc", "width");
	maxImageWidth=imageStruct[arrKey[1]].width;
	
	arrKey=structsort(imageStruct, "numeric", "desc", "height");
	maxWidth=maxImageWidth;
	curX=0;
	curY=0;
	nextY=0;
	arrGrid=[];
	imagePad=1;
	
	maxWidthDivided=ceiling(maxWidth/imagePad);
	maxHeightDivided=ceiling(10000/imagePad);
	
	maxHeight=0;
	maxWidth=0;
	for(g=1;g LTE imageCount;g++){
	    ts=imageStruct[arrKey[g]];
	    if(ts.width  EQ  0){continue; }
	    searching=true;
	    curX=0;
	    curY=0;
	    tsWidthDivided=ceiling(ts.width/imagePad);
	    tsHeightDivided=ceiling(ts.height/imagePad);
	    arrRowHeights=[];
	    for(n=0;n LT maxHeightDivided;n++){
		for(i=0;i LTE maxWidthDivided-tsWidthDivided;i++){
		    // do hit detection on all the previous sprites
		    hit=false;
					for(f=1;f LTE arraylen(arrKey);f++){
						curObj=imageStruct[arrKey[f]];
			curObj=imageStruct[f];
			if(structkeyexists(curObj, 'leftDivided') and i+tsWidthDivided gt curObj.leftDivided and i lt curObj.rightDivided and n+tsHeightDivided gt curObj.topDivided and n lt curObj.bottomDivided){
			    hit=true;
			    i=curObj.rightDivided-1;
			    break;
			}
		    }
		    if(hit){
			continue;
		    }else{
			curX=i;
			curY=n;
			searching=false;	
			break;
		    }
		}
		if(searching EQ false){
		    break;
		}
	    }
	    ts.left=curX*imagePad;
	    ts.top=curY*imagePad;
	    ts.right=ts.left+ts.width;
	    ts.bottom=ts.top+ts.height;
	    maxHeight=max(ts.bottom, maxHeight);
	    maxWidth=max(ts.right, maxWidth);
	    ts.leftDivided=ceiling(ts.left/imagePad);
	    ts.topDivided=ceiling(ts.top/imagePad);
	    ts.rightDivided=ceiling(ts.right/imagePad);
	    ts.bottomDivided=ceiling(ts.bottom/imagePad);
	}
	// if(transparent){
	// 	finalImage = imagenew("", maxWidth, maxHeight, "argb");
	// }else{
	// 	finalImage = imagenew("", maxWidth, maxHeight, "rgb", "##FFFFFF");
	// }
	// 	ImageSetAntialiasing(finalImage,"on");
	// for(i in imageStruct){
	//     if(imageStruct[i].width  EQ  0) continue;
	//     ts=imageStruct[i];
	//     ts.width-=(this.spritePad*2);
	//     ts.height-=(this.spritePad*2);
	// 		ImagePaste(finalImage, ts.source, ts.left+this.spritePad, ts.top+this.spritePad);
	// 		structdelete(ts, 'source');
	// }
	// if(ext EQ ".png"){
	// 		imagewrite(finalImage, arguments.spriteMapFile, true, 5);
	// }else{  
	// 		imagewrite(finalImage, arguments.spriteMapFile, true, 90);
	// }        
	return imageStruct;
	</cfscript>
</cffunction>



<cffunction name="parseCSSString" access="private" output="no" localmode="modern">
	<cfargument name="css" type="string" required="yes">
	<cfscript>
	
	arguments.css=replace(arguments.css, chr(13), "","all");
	length=len(arguments.css);
	inComment=false;
	inRule=false;
	inAtKeyword=false;
	inSelector=false;
	inProperty=false;
	inValue=false;
	curStr="";
	arrC=[];
	for(i=1;i LTE length;i++){
	    curChar=mid(arguments.css,i,1);
	    lastChar="";
	    if(i NEQ 1){
		lastChar=mid(arguments.css,i,1);	
	    }
	    nextChar="";
	    if(i NEQ length){
		nextChar=mid(arguments.css,i+1,1);	
	    }
	    if(curChar  EQ  '/' and nextChar  EQ  "*"){
		// comment
		for(i2=i+2;i2 LTE length;i2++){
		    curChar2=mid(arguments.css,i2,1);
		    nextChar2="";
		    if(i2 LTE length){
			nextChar2=mid(arguments.css,i2+1,1);
		    }
		    if(curChar2  EQ  '*' and nextChar2  EQ  "/"){
			endPos=i2+1;
			break;
		    }
		}
				if(endPos-i LT 1){
					endPos=length;
				}
		curStr=mid(arguments.css, i, (endPos-i)+1);
		t={};
		t.type="comment";
		t.value=trim(curStr);
		arrayappend(arrC, t);
		i=endPos;
		curStr="";
		
	    }else if(not inRule){
		if(curChar  EQ  "}"){
		    if(inAtKeyword){
			t={};
			t.type="endatkeyword";
			t.value="}";
			curStr="";
			arrayappend(arrC, t);
		    }
		}else if(curChar  EQ  '@'){
		    // only support import and media
		    if(mid(arguments.css,i+1,5)  EQ  "media"){
			// find { and save it all as media query
			for(i2=i+1;i2 LTE length;i2++){
			    curChar2=mid(arguments.css,i2,1);
			    if(curChar2  EQ  '{'){
				endPos=i2;
				break;
			    }
			}
			curStr=mid(arguments.css,i,endPos-i);
			inAtKeyword=true;
			t={};
			t.type="atkeyword";
			t.value=trim(curStr)&"{";
			arrayappend(arrC, t);
			i=endPos;
			curStr="";
		    }else if(mid(arguments.css,i+1,6)  EQ  "import"){
			// find ; or end of line and save it
			for(i2=i+1;i2 LTE length;i2++){
			    curChar2=mid(arguments.css,i2,1);
			    if(curChar2  EQ  ';'){
				endPos=i2;
				break;
			    }
			}
			curStr=mid(arguments.css,i,endPos-i);
			t={};
			t.type="atkeyword";
			t.value=trim(curStr)&";";
			arrayappend(arrC, t);
			t={};
			t.type="endatkeyword";
			t.value="";
			arrayappend(arrC, t);
			i=endPos;
			curStr="";
		    }else if(mid(arguments.css,i+1,4)  EQ  "@z@@"){
			np44=find("@", arguments.css, i+5);
			if(np44){
			    curStr=mid(arguments.css, i+5, np44-(i+5));
			    t={};
			    t.type="fileseparator";
			    t.value=trim(curStr);
			    arrayappend(arrC, t);
			    curStr="";
			    i=(np44);
			    continue;
			}
		    }else{
			curStr&=curChar;
		    }
		}else if(curChar  EQ  '{'){
		    t={};
		    t.type="startselector";
		    t.value=trim(replace(curStr,chr(10)," ","all"))&"{";
		    arrayappend(arrC, t);
		    inRule=true;
		    curStr="";
		}else{
		    curStr&=curChar;
		}
	    }else{
		if(curChar  EQ  '}'){
		    arrP=listtoarray(curStr, ";");
		    arrR=[];
		    for(i2=1;i2 LTE arraylen(arrP);i2++){
			if(trim(arrP[i2]) NEQ ""){
			    c=listtoarray(arrP[i2],":");
			    
			    if(arraylen(c)  GT  3){
				    key=c[i2];
				arrTemp=ArrayNew(1);
				    arrayDeleteAt(c, 1);
				arrayAppend(arrTemp, $key);
				arrTemp(arrTemp, arrayToList(c, ":"));
				    if(arrTemp[2] CONTAINS "data:image/"){
					if(arrayLen(arrP) GTE i2+1 and left(c[i2+1], 7) EQ "base64,"){
						arrTemp[2]&=";"&c[i2+1];
						i2++;
					}
				    }
				c=[c[1], trim(c[1]).trim(c[2])];
			    }
			    if(arraylen(c)  EQ  2){
				t={};
				t.type="property";
				t.name=trim(c[1]);
				t.value=trim(c[2]);
				arrayappend(arrR, t);
			    }
			}
		    }
		    t={};
		    t.type="rules";
		    t.arrProperty=arrR;
		    t.value=trim(curStr);
		    arrayappend(arrC, t);
		    inRule=false;
		    t={};
		    t.type="endselector";
		    t.value="}";
		    arrayappend(arrC, t);
		    curStr="";
		}else{
		    curStr&=curChar;
		}
	    }
	}
	return arrC;
	</cfscript>
</cffunction>

<cffunction name="getImagesFromParsedCSS" access="private" output="no" localmode="modern">
	<cfargument name="arrCSS" type="array" required="yes">
	<cfscript>
	
	var arrImageTransparent=[];
	var arrImage=[];
	index=0;
	arrImageNewStylesheet=[];
	arrImageTransparentNewStylesheet=[];
	curLength=arraylen(arguments.arrCSS);
	//writeoutput('rel:'&variables.cssRootPath&'<br>');
	aliasCount=arraylen(variables.arrAlias);
	for(key=1;key LTE curLength;key++){
		currentCSSRootPath=variables.cssRootPath;
		currentCSSRootRelativePath=variables.cssRootRelativePath;
		curValue=arguments.arrCSS[key];
		if(curValue.type  EQ  "fileseparator"){
			arrTemp=listtoarray(curValue.value,"~");
			if(arraylen(arrTemp) NEQ 2){
				throw("Invalid file separator format. Must be absolutePath~relativePath","custom");
			}
			currentCSSRootPath=getdirectoryfrompath(arrTemp[1]);
			currentCSSRootRelativePath=getdirectoryfrompath(arrTemp[2]);
		}else if(curValue.type  EQ  "rules"){
			curBackgroundImage="";
			this.arr3=[];
			enableBackgroundSprite=false;
			for(i=1;i LTE arraylen(curValue.arrProperty);i++){
				c=curValue.arrProperty[i];
				if(c.name EQ "background-repeat" and c.value  EQ  "no-repeat"){ 
					enableBackgroundSprite=true;
				}
			}
			for(i=1;i LTE arraylen(curValue.arrProperty);i++){
				c=curValue.arrProperty[i];
				if(c.name EQ "background"){
					// parse it	into the separate values
					hasNoRepeat=findnocase(" no-repeat ", curValue.value);
					if(hasNoRepeat){
						arr2=listtoarray(curValue.value, " ", false);
						if(arraylen(arr2) EQ 5){
							color=arr2[1];
							url=arr2[2];
							enableBackgroundSprite=true;
			t={};
			t.type="property";
			t.name="background-repeat";
			t.value="no-repeat";
			arrayinsertat(curValue.arrProperty, i+1, t);
			t={};
			t.type="property";
			t.name="background-image";
			t.value=url;
			arrayinsertat(curValue.arrProperty, i+2, t);
							arraydeleteat(arr2, 1);
							arraydeleteat(arr2, 1);
							curValue.value=arr2[1]&" none "&arraytolist(arr2, " ");

						}
					}
				}else if(enableBackgroundSprite and c.name EQ "background-image"){
					curBackgroundImage=trim(replace(replace(replace(replace(c.value, "'", "", "all"), '"', '', "all"), 'url(','', "all"), ')','', "all"));
				}else{
					arrayappend(this.arr3, c);
				}
			}
			if(curBackgroundImage NEQ ""){
				curBackgroundImage=this.forceAbsoluteDir(curBackgroundImage, currentCSSRootPath, this.root);
				if(mid(curBackgroundImage, 1, len(this.root)) NEQ this.root){
					curBackgroundImage="";	
				}else{
					curBackgroundImage=removechars(curBackgroundImage, 1, len(this.root)-1);
					for(n=1;n LTE aliasCount;n++){
						currentCSSRootRelativePath=variables.arrAlias[n];
						currentCSSRootPath=this.aliasStruct[variables.arrAlias[n]];
						if(mid(curBackgroundImage, 1,len(currentCSSRootRelativePath)) EQ currentCSSRootRelativePath){
							break;
						}
					}
					curBackgroundImage=this.forceAbsoluteDir(mid(curBackgroundImage, len(currentCSSRootRelativePath), len(curBackgroundImage)-(len(currentCSSRootRelativePath)-1)) , currentCSSRootPath, currentCSSRootPath);
					if(mid(curBackgroundImage, 1, len(currentCSSRootPath)) NEQ currentCSSRootPath){
						curBackgroundImage="";	
					}
				}
				if(curBackgroundImage NEQ ""){
					c={};
					c.type="property";
					c.name="background-image";
					arrTemp=listtoarray(curBackgroundImage, "?");
					curBackgroundImage=arrTemp[1];
					ext=mid(curBackgroundImage, len(curBackgroundImage)-3,4);
					if(arraylen(arrTemp) GTE 2){
						curBackgroundImage&="?"&arrTemp[2];
					}
					if(ext  EQ  ".jpg"){
						c.imageIndex=arraylen(arrImage)+1;
						c.transparentIndex=-1;
						arrayappend(arrImage, curBackgroundImage);
					}else if(ext  EQ  ".png"  OR  ext  EQ  ".gif"){
						c.imageIndex=-1;
						c.transparentIndex=arraylen(arrImageTransparent)+1;
						arrayappend(arrImageTransparent, curBackgroundImage);
					}
					c.value="url("&curBackgroundImage&")";
					arrayappend(this.arr3, c);
				}
			}
			curValue.arrProperty=this.arr3;
		}
	}
	return {arrImage:arrImage, arrImageTransparent: arrImageTransparent};
	</cfscript>
</cffunction>


<cffunction name="generateSpriteMaps" access="private" output="no" localmode="modern">
	<cfargument name="imageStruct" type="struct" required="yes">
	<cfscript>
	
	var arrImage=arguments.imageStruct.arrImage;
	var arrImageTransparent=arguments.imageStruct.arrImageTransparent;
	imageStructNew=[];
	imageTransparentStructNew=[];
	arrLookupImage=[];
	arrLookupTransparent=[];
	if(this.disableSpritemap EQ 0){
		if(arraylen(arrImage) NEQ 0){
			imageStructNew=this.generateSpriteMap(arrImage, this.jpegFilePath);
			
			for(i in imageStructNew){
				arrLookupImage[imageStructNew[i].curIndex]=i;
			}
		}
		if(arraylen(arrImageTransparent) NEQ 0){
			imageTransparentStructNew=this.generateSpriteMap(arrImageTransparent, this.pngFilePath);
			for(i in imageTransparentStructNew){
				arrLookupTransparent[imageTransparentStructNew[i].curIndex]=i;
			}
		}
	}
	return { imageStruct:imageStructNew, imageTransparentStruct:imageTransparentStructNew, arrLookupImage:arrLookupImage, arrLookupTransparent:arrLookupTransparent};
	</cfscript>
</cffunction>

<cffunction name="rebuildCSS" access="private" output="no" localmode="modern">
<cfargument name="arrCSS" type="array" required="yes">
<cfargument name="imageStruct" type="struct" required="yes">
<cfscript>
	
	a=[];
	lastVal="";
	originalStruct=duplicate(arguments.imageStruct);
	for(key=1;key LTE arraylen(arguments.arrCSS);key++){
		curValue=arguments.arrCSS[key];
		if(curValue.type  EQ  "fileseparator"){
			continue;
		}else if(curValue.type  EQ  "rules"){
			for(i=1;i LTE arraylen(curValue.arrProperty);i++){
				c=curValue.arrProperty[i];
				if(c.name  EQ  "background-image"){
					match=false;
					if(this.disableSpritemap EQ 0){
						if(structkeyexists(c, 'imageIndex') and c.imageIndex GT 0){
							match=true;
							f=arguments.imageStruct.imageStruct[arguments.imageStruct.arrLookupImage[c.imageIndex]];
							f.selector=lastVal;
							if(structkeyexists(f, 'referenceIndex')){
								t=originalStruct.imageStruct[f.referenceIndex];
								f.left=t.left;
								f.top=t.top;
								f.width=t.width;
								f.height=t.height;
								
							}
							if(f.width  EQ  0) continue;
							curValue.arrProperty[i].value="url("&this.jpegRootRelativePath&")";
							if(f.left NEQ 0){
								f.left*=-1;
							}
							if(f.top NEQ 0){
								f.top*=-1;
							}
							if(this.disableMinify){
								arrayappend(a, chr(9));
							}
							arrayappend(a, "background-position:"&(f.left-this.spritePad)&"px "&(f.top-this.spritePad)&"px;");
							if(this.disableMinify){
								arrayappend(a, chr(10));
							}
						}
						if(structkeyexists(c, 'transparentIndex') and c.transparentIndex GT 0){
							match=true;
							f=arguments.imageStruct.imageTransparentStruct[arguments.imageStruct.arrLookupTransparent[c.transparentIndex]];
							f.selector=lastVal;
							if(structkeyexists(f, 'referenceIndex')){
								t=originalStruct.imageTransparentStruct[f.referenceIndex];
								f.left=t.left;
								f.top=t.top;
								f.width=t.width;
								f.height=t.height;
								
							}
							if(f.width  EQ  0) continue;
							curValue.arrProperty[i].value="url("&this.pngRootRelativePath&")";
							if(f.left NEQ 0){
								f.left*=-1;
							}
							if(f.top NEQ 0){
								f.top*=-1;
							}
							if(this.disableMinify){
								arrayappend(a, chr(9));
							}
							arrayappend(a, "background-position:"&(f.left-this.spritePad)&"px "&(f.top-this.spritePad)&"px;");
							if(this.disableMinify){
								arrayappend(a, chr(10));
							}
						}
						if(not match){
							curValue.arrProperty[i].value=replace(replace(curValue.arrProperty[i].value, '"', '', "all"), ")","?zv="&randrange(1034212,92301493)&")", "all");
						}
					}
				}
				if(this.disableMinify){
					arrayappend(a, chr(9));
				}
				arrayappend(a, curValue.arrProperty[i].name&":"&curValue.arrProperty[i].value&";");	
				if(this.disableMinify){
					arrayappend(a, chr(10));
				}
			}
		}else{
			lastVal=curValue.value;
			if(this.disableMinify){
				if(not find(","&curValue.type&",", ",endatkeyword,atkeyword,endselector,startselector,comment,")){
					arrayappend(a, chr(9));
				}
			}else{
				if(curValue.type EQ "startselector"){
					arrayappend(a, replace(curValue.value, chr(10)," ","all"));
				}else if(curValue.type NEQ "comment"){
					arrayappend(a, curValue.value);
				}
			}
			if(this.disableMinify){
				arrayappend(a, chr(10));
			}
		}
	}
	// fix @font-face
	s=replace(replace(replace(arraytolist(a,""), "font-face", "@font-face", "all"), "@@font-face","@font-face", "all"), this.root, "/", "all");
	return s;
	</cfscript>
</cffunction>





</cfoutput>
</cfcomponent>