<cfcomponent extends="zcorerootmapping.functions.validation">
<cfoutput>
<cffunction name="zHTMLDoctype" localmode="modern" output="no" returntype="string">
	<cfsavecontent variable="output">	<!DOCTYPE html>
	<html lang="en-us">
	</cfsavecontent>
	<cfreturn output>
</cffunction>

<cffunction name="zEscapeURL" access="public" localmode="modern"> 
	<cfargument name="link" type="string" required="yes">
	<cfscript>
	a=listlen(arguments.link, "/");
	file=listgetat(arguments.link, a, "/");
	a2=listToArray(file, "?");
	if(arraylen(a2) GT 1){
		arrayDeleteAt(a2, 1);
		a3="?"&arrayTolist(a2, "?");
	}else{
		a3="";
	}
	path=listdeleteat(arguments.link, a, "/");
	return path&"/"&urlencodedformat(a2[1])&a3;
	</cfscript>
</cffunction>

<cffunction name="zBuildURL" access="public" localmode="modern">
	<cfargument name="link" type="string" required="yes">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	if(find("?", arguments.link) EQ 0){
		arguments.link&="?";
	}
	for(i in arguments.struct){
		arguments.link&="&"&i&'='&urlencodedformat(arguments.struct[i]);
	}
	return arguments.link;
	</cfscript>
</cffunction>


<cffunction name="zStripHTMLTags" localmode="modern" output="no" returntype="string">
	<cfargument name="string" type="string" required="yes">
	<cfscript>
	return rereplace(arguments.string,"<[^>]*>","","ALL");
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zCleanSearchText(text, false); --->
<cffunction name="zCleanSearchText" localmode="modern" output="yes" returntype="any">
	<cfargument name="text" type="string" required="yes">
	<cfargument name="nolinks" type="boolean" required="no" default="#false#">
	<cfscript>
	var links="";
	var badTagList="style|link|head|script|embed|base|input|textarea|button|object|iframe|form";
	arguments.text=lcase(arguments.text);
	// remove tags that have useless contents nested in them
	arguments.text=rereplacenocase(arguments.text,"<(#badTagList#)[^>]*?>.*?</\1>", " ", 'ALL');			
	if(arguments.nolinks EQ false){
		links=replace(arguments.text,chr(9),' ','ALL');		
		links=replace(links,chr(10),' ','ALL');		
		links=replace(links,chr(13),' ','ALL');
		
		// extract links with or without quotes
		links=rereplacenocase(links,"[^>^<]*<(area|a)\s[^>]*\s?href\s*=\s*(""|'|)([^\2^\s]*)\2\s*?[^>]*>.*?</\1>[^>^<]*",chr(9)&'\3'&chr(9),'ALL');
		
		if(find(chr(9),links) EQ 0){
			 links="";
		}
		// remove everything but the links
		links=rereplacenocase(links,"[^\t]*?\t([^\t]*)\t?[^\t]*", "\1 ", 'ALL');
		// put links at the top
		arguments.text=links&arguments.text;
	}
	// remove all html tags
	arguments.text=rereplacenocase(arguments.text,"<.*?>", " ", 'ALL');
	// remove html entities
	arguments.text=rereplacenocase(arguments.text,"&[^\s]*?;", " ", 'ALL');
	
	// innodb full text boolean mode doesn't allow @ symbol
	arguments.text=replace(arguments.text, '@', '_', 'all');

	// remove http
	arguments.text=rereplacenocase(arguments.text,"(http\:|https\:|mailto\:|www\.|\b(\S\S|\S)\b|[^a-z0-9@]|\s)", " ", 'ALL');
	arguments.text=rereplacenocase(arguments.text,"\s*(\S*)", " \1", 'ALL');
	// trim and return
	arguments.text=trim(arguments.text);
	return arguments.text;
	</cfscript>
</cffunction>


<cffunction name="zCountCFMLLinesInFile" localmode="modern" access="public" returntype="struct">
	<cfargument name="filePath" type="string" required="yes">
	<cfscript>
	var c=0;
	var lines=0;
	var arrLine=0;
	var i=0;
	var count=0;
	var c2=0;
	var c3=0;
	var arrNew=[];
	c=application.zcore.functions.zreadfile(arguments.filePath);
	c=replace(c, chr(13), "","all");
	c=replace(c, chr(9), "","all");
	c = rereplace(c, "(<!---.*?--->)","","ALL");
	arrLine=listtoarray(c, chr(10));
	count=arrayLen(arrLine);
	// ignore white space lines
	for(i=1;i LTE count;i++){
		local.t=trim(arrLine[i]);
		if(len(local.t)){
			arrayAppend(arrNew, local.t);
		}
	}
	local.totalLines=arraylen(arrNew);
	c=arrayToList(arrNew, chr(10));
	local.lineCount=arrayLen(arrNew);
	c2 = rereplace(c, "(<style.*?</style>)","","ALL");
	local.cssLineCount=local.lineCount-listLen(c2, chr(10));
	c=c2;
	local.lineCount=listLen(c, chr(10));
	c2 = rereplace(c, "(<script.*?</script>)","","ALL");
	local.jsLineCount=local.lineCount-listLen(c2, chr(10));
	c=c2;
	local.lineCount=listLen(c, chr(10));
	c2 = rereplace(c, "(<cfscript.*?</cfscript>)","","ALL");
	c2 = rereplace(c2, "(<cf.*?>)","","ALL");
	c2 = rereplace(c2, "(</cf[^>]*>)","","ALL");
	arrNew=[];
	arrLine=listtoarray(c2, chr(10));
	count=arrayLen(arrLine);
	for(i=1;i LTE count;i++){
		local.t=trim(arrLine[i]);
		if(len(local.t)){
			arrayAppend(arrNew, local.t);
		}
	}
	c2=arrayToList(arrNew, chr(10));
	local.cfmlCount=local.lineCount-listLen(c2, chr(10));
	c=c2;
	local.htmlCount=listLen(c, chr(10));
	local.rs={
		jsLines: local.jsLineCount,
		cssLines: local.cssLineCount,
		htmlLines: local.htmlCount,
		cfmlLines: local.cfmlCount,
		totalLines: local.totalLines
	};
	return local.rs;
	</cfscript>
</cffunction>

<cffunction name="zCountCFMLLinesInDirectory" localmode="modern" access="public" returntype="struct">
	<cfargument name="path" type="string" required="yes">
	<cfscript>
	var qDir=0;
	var row=0;
	var lines=0;
	var rs={
		totalLines: 0,
		jsLines:0,
		cssLines:0,
		cfcLines: 0,
		htmlLines:0, 
		cfmLines: 0,
		cfcFiles: 0,
		cfmFiles:0 
	};
	directory action="list" recurse="yes" name="qDir" directory="#arguments.path#" filter="*.cfc|*.cfm";
	for(row in qDir){
		local.rs2=application.zcore.functions.zCountCFMLLinesInFile(row.directory&"/"&row.name);
		rs.jsLines+=local.rs2.jsLines;
		rs.cssLines+=local.rs2.cssLines;
		rs.htmlLines+=local.rs2.htmlLines;
		rs.totalLines+=local.rs2.totalLines;
		if(right(row.name, 4) EQ ".cfm"){
			rs.cfmLines+=local.rs2.cfmlLines;
			rs.cfmFiles++;
		}else if(right(row.name, 4) EQ ".cfc"){
			rs.cfcLines+=local.rs2.cfmlLines;
			rs.cfcFiles++;
		}
	}
	return rs;
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zGenerateStrongPassword(minLength, maxLength [, onlyAlphanumeric] [, userFriendly]) --->
<cffunction name="zGenerateStrongPassword" localmode="modern" output="no" returnpath="string">
	<cfargument name="minLength" type="numeric" required="no" default="32">
	<cfargument name="maxLength" type="numeric" required="no" default="62">
	<cfargument name="onlyAlphanumeric" type="boolean" required="no" default="#false#">
	<cfargument name="userFriendly" type="boolean" required="no" default="#false#">
	<cfscript> 
	if(arguments.onlyAlphanumeric){
		if(arguments.userFriendly){
			d='0123456789ABCDEFGHIJKLMNPQRSTUVWXYZabcdefghjkmnopqrstuvwxyz';
		}else{
			d='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
		} 
	}else{
		if(arguments.userFriendly){
			d='123456789ABCDEFGHIJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz=!@##$%^&*()[]{}|;:,.<>?''"+';
		}else{
			d='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_=!@##$%^&*()[]{}|;:,.<>/?`~''"+-';
		}
	}
	var d1=len(d);
	var plen=max(arguments.minLength, randrange(1, arguments.maxLength-arguments.minLength, "SHA1PRNG")+arguments.minLength);
	var i=0;
	var p=""; 
	for(i=1;i LTE plen;i++){
		p&=mid(d, randrange(1,d1, "SHA1PRNG"),1);
	}
	return p;
	</cfscript>
</cffunction>


    
<cffunction name="zStructToCacheString" localmode="modern" access="public" output="no" returntype="string">
    <cfargument name="struct" type="struct" required="yes">
    <cfscript>
    
    local.arrKey=structkeyarray(arguments.struct);
    arraysort(local.arrKey, "text", "asc");
    local.cacheString=arraynew(1);
    for(local.i=1;local.i LTE arraylen(local.arrKey);local.i++){
        if(isArray(arguments.struct[local.arrKey[local.i]])){
            arrayAppend(local.cacheString, local.arrKey[local.i]&"="&arraytolist(arguments.struct[local.arrKey[local.i]],","));
        }else{
            arrayAppend(local.cacheString, local.arrKey[local.i]&"="&arguments.struct[local.arrKey[local.i]]);
        }
    }
    return hash(arraytolist(local.cacheString, "&"));
    </cfscript>
</cffunction>
        
<cffunction name="zHighlightHTML" localmode="modern" output="yes" returntype="any">
	<cfargument name="searchText" type="string" required="yes">
    <cfargument name="html" type="string" required="yes">
	<cfscript>
    var wordStruct=structnew();
    var i=0;
	var stringLength=0;
    var start=0;
    var arrSearchWords=0;
    var ss=0;
    var hln=0;
    var word=0;
    var phrase=0;
    var matching=true;
    var result="";
    var t99=">"&trim(arguments.html)&"<";
    arrSearchWords=listtoarray(arguments.searchtext," ");
    for(i=1;i LTE arraylen(arrSearchWords);i++){
        if(arrSearchWords[i] NEQ ""){
            wordStruct[arrSearchWords[i]]=true;
        }
    }
    arrSearchWords=structkeyarray(wordStruct);
    //writeoutput("Search Words:"&structkeylist(wordStruct)&"<hR>");
    start=1;
    while(matching){
        ss=refind(">([^<]*)<",t99, start, true);
        //zdump(ss);
        if(arraylen(ss.len) EQ 2){
            phrase=mid(t99,ss.pos[2],ss.len[2]);
            //writeoutput(htmleditformat(phrase)&"<hr size=""1"">");
            for(i=1;i LTE arraylen(arrSearchWords);i++){
                word=arrSearchWords[i];
                //stringLength=len(word);
                hln=i;
                if(i GT 9){
                    hln=i-9;
                }
                phrase=replacenocase(phrase, word,"<span id=""zsearchhighlightid#i#"" class=""zsearchhighlight#hln#"">"&word&"</span>","ALL");
            }
            //writeoutput("Fixed:"&htmleditformat(phrase)&"<hr size=""1"">");
            t99=removeChars(t99,ss.pos[2],ss.len[2]);
            t99=insert(phrase,t99,ss.pos[2]-1);
            //writeoutput(ss.pos[2]&"+"&len(phrase)&" | "&ss.len[2]&"<br />");
            start=ss.pos[2]+len(phrase)+2;
        }else{
            matching=false;	
        }
    }
    //writeoutput("DONE<hr size=""1"">"); 
    t99=mid(t99,2,len(t99)-2);
    result&='<table style="border:1px solid ##000; color:##000; background-color:##FFF; padding:10px;"><tr><td><strong>The following search terms have been highlighted</strong><br />
(Click a search term to jump to the first occurrence).<br />';
    for(i=1;i LTE arraylen(arrSearchWords);i++){
        word=arrSearchWords[i];
        //stringLength=len(word);
        hln=i;
        if(i GT 9){
            hln=i-9;
        }
        result&="<a href=""javascript:zJumpToId('zsearchhighlightid#hln#',-30);""><span class=""zsearchhighlight#hln#"">"&word&"</span></a>";
        if(arraylen(arrSearchWords) NEQ i){
            result&=', ';
        }
    }
    application.zcore.template.prependtag("meta",'<style>/* <![CDATA[ */ .zsearchhighlight1{ color:##000; background-color:##FF0; font-weight:bold;}.zsearchhighlight2{ color:##000; background-color:##fbAcAc; font-weight:bold;}.zsearchhighlight3{ color:##000; background-color:##FD3; font-weight:bold;}.zsearchhighlight4{ color:##000; background-color:##8cdff7; font-weight:bold;}.zsearchhighlight5{ color:##000; background-color:##FCA; font-weight:bold;}.zsearchhighlight6{ color:##000; background-color:##CDF; font-weight:bold;}.zsearchhighlight7{ color:##000; background-color:##EBF; font-weight:bold;}.zsearchhighlight8{ color:##000; background-color:##9F9; font-weight:bold;}.zsearchhighlight9{ color:##000; background-color:##AFD; font-weight:bold;} /* ]]> */</style>');
    return result&'</td></tr></table><br />'&t99;
    </cfscript>
</cffunction>

<cffunction name="zExtractLinksFromHTML" localmode="modern" output="no" returntype="string">
	<cfargument name="text" type="string" required="yes">
    <cfscript>
	var links=replace(arguments.text,chr(9),' ','ALL');	
	links=rereplacenocase(links,"[^>^<]*<(a|area) .*?href\s*=\s*(""|')([^""^']*)(""|')[^>]*>[^>^<]*",chr(9)&'\3'&chr(9),'ALL');
	if(find(chr(9),links) EQ 0) links="";
	links=rereplacenocase(links,"[^\t]*?\t([^\t]*)\t?[^\t]*", "\1"&chr(9), 'ALL');
	return links;
	</cfscript>
</cffunction>

<cffunction name="zExtractImagesFromHTML" localmode="modern" output="no" returntype="string">
	<cfargument name="text" type="string" required="yes">
    <cfscript>
	var links=replace(arguments.text,chr(9),' ','ALL');	
	links=rereplacenocase(links,"[^>^<]*<img .*?src\s*=\s*(""|')([^""^']*)(""|')[^>]*>[^>^<]*",chr(9)&'\2'&chr(9),'ALL');
	if(find(chr(9),links) EQ 0) links="";
	links=rereplacenocase(links,"[^\t]*?\t([^\t]*)\t?[^\t]*", "\1"&chr(9), 'ALL');
	return links;
	</cfscript>
</cffunction>


<cffunction name="zNoWhiteSpace" localmode="modern" output="false" returntype="any">
	<cfargument name="string" type="string" required="yes">
	<cfscript>
	arguments.string = rereplacenocase(arguments.string, '([\S]*)([\t\r\n\f]*)([\S]*)', '\1\3','ALL');
	arguments.string = rereplacenocase(arguments.string, '([\S]*)([^<|\s]*)([\S]*)', '\1\3','ALL');
	arguments.string = rereplacenocase(arguments.string, '>([\s]*)<', '><','ALL');
	arguments.string = replace(arguments.string, '  ', ' ','ALL');
	return arguments.string;
	</cfscript>
</cffunction>


<cffunction name="zParseQueryStringToStruct" localmode="modern" output="no" returntype="any">
	<cfargument name="queryString" type="string" required="yes">
    <cfargument name="struct" type="struct" required="no" default="#form#">
    <cfargument name="amp" type="string" required="no" default="&">
    <cfargument name="equal" type="string" required="no" default="=">
	<cfscript>
	var arrT=0;
	if(arguments.queryString EQ ""){
		return;
	}
	var arrQ=listtoarray(arguments.queryString, arguments.amp);
	var i=0;
	for(i=1;i LTE arraylen(arrQ);i++){
		arrT=listtoarray(arrQ[i],arguments.equal);
		if(arraylen(arrT) EQ 2){
			arguments.struct[arrT[1]]=urldecode(arrT[2]);
		}
	}
	</cfscript>
</cffunction>



<cffunction name="zConvertToAscii" localmode="modern" output="no" returntype="string">
	<cfargument name="text" type="string" required="yes">
	<cfscript>
	var i = 0;

    // map incompatible non-ISO characters into plausible 
	// substitutes
	arguments.text = Replace(arguments.text, Chr(128), "&euro;", "All");

	arguments.text = Replace(arguments.text, Chr(130), ",", "All");
	arguments.text = Replace(arguments.text, Chr(131), "<em>f</em>", "All");
	arguments.text = Replace(arguments.text, Chr(132), ",,", "All");
	arguments.text = Replace(arguments.text, Chr(133), "...", "All");
		
	arguments.text = Replace(arguments.text, Chr(136), "^", "All");

	arguments.text = Replace(arguments.text, Chr(139), ")", "All");
	arguments.text = Replace(arguments.text, Chr(140), "Oe", "All");

	arguments.text = Replace(arguments.text, Chr(145), "'", "All");
	arguments.text = Replace(arguments.text, Chr(146), "'", "All");
	arguments.text = Replace(arguments.text, Chr(147), """", "All");
	arguments.text = Replace(arguments.text, Chr(148), """", "All");
	arguments.text = Replace(arguments.text, Chr(149), "*", "All");
	arguments.text = Replace(arguments.text, Chr(150), "-", "All");
	arguments.text = Replace(arguments.text, Chr(151), "--", "All");
	arguments.text = Replace(arguments.text, Chr(152), "~", "All");
	arguments.text = Replace(arguments.text, Chr(153), "&trade;", "All");

	arguments.text = Replace(arguments.text, Chr(155), ")", "All");
	arguments.text = Replace(arguments.text, Chr(156), "oe", "All");

	// remove any remaining ASCII 128-159 characters
	for (i = 128; i LTE 159; i = i + 1)
		arguments.text = Replace(arguments.text, Chr(i), "", "All");

	// map Latin-1 supplemental characters into
	// their &name; encoded substitutes
	arguments.text = Replace(arguments.text, Chr(160), " ", "All");

	arguments.text = Replace(arguments.text, Chr(163), "##", "All");

	arguments.text = Replace(arguments.text, Chr(169), "&copy;", "All");

	arguments.text = Replace(arguments.text, Chr(176), "&deg;", "All");

	// encode ASCII 160-255 using &#999; format
	for (i = 160; i LTE 255; i = i + 1)		arguments.text = REReplace(arguments.text, "(#Chr(i)#)", "&###i#;", "All");
	
    // supply missing semicolon at end of numeric entities
	arguments.text = ReReplace(arguments.text, "&##([0-2][[:digit:]]{2})([^;])", "&##\1;\2", "All");
	
    // fix obscure numeric rendering of &lt; &gt; &amp;
	//arguments.text = ReReplace(arguments.text, "&##038;", "&amp;", "All");
	arguments.text = ReReplace(arguments.text, "&##060;", "&lt;", "All");
	arguments.text = ReReplace(arguments.text, "&##062;", "&gt;", "All");

	// supply missing semicolon at the end of &amp; &quot;
	//arguments.text = ReReplace(arguments.text, "&amp(^;)", "&amp;\1", "All");
	//arguments.text = ReReplace(arguments.text, "&quot(^;)", "&quot;\1", "All");
	
	//arguments.text=replace(arguments.text,chr(38), "&amp;", "all"); 
	//arguments.text=replace(arguments.text,chr(133), "&##133;", "all"); 
	//arguments.text=replace(arguments.text,chr(145), "&##039;", "all"); 
	//arguments.text=replace(arguments.text,chr(146), "&##039;", "all");
	//arguments.text=replace(arguments.text,chr(147), "&##034;", "all"); 
	//arguments.text=replace(arguments.text,chr(148), "&##034;", "all"); 
	//arguments.text=replace(arguments.text,chr(149), "&##149;", "all");  
	//arguments.text=replace(arguments.text,chr(150), "&##150;", "all"); 
	//arguments.text=replace(arguments.text,chr(151), "&##151;", "all"); 
	//arguments.text=replace(arguments.text,chr(153), "&##153;", "all"); // trademark
	//arguments.text=replace(arguments.text,chr(169), "&copy;", "all"); // copyright mark
	//arguments.text=replace(arguments.text,chr(174), "&reg;", "all"); // registration mark
	arguments.text=replace(arguments.text,chr(8226), "&##8243;", "all"); 
	arguments.text=replace(arguments.text,chr(8216), "&##039;", "all"); 
	arguments.text=replace(arguments.text,chr(8217), "&##039;", "all");  
	arguments.text=replace(arguments.text,chr(8220), "&##034;", "all"); 
	arguments.text=replace(arguments.text,chr(8221), "&##034;", "all"); 
	arguments.text=replace(arguments.text,chr(8226), "&##149;", "all"); 
	arguments.text=replace(arguments.text,chr(8211), "&##150;", "all");
	arguments.text=replace(arguments.text,chr(8212), "&##151;", "all"); 
	arguments.text=replace(arguments.text,chr(8482), "&##153;", "all"); // trademark
	return arguments.text;
	</cfscript>
</cffunction>

<cffunction name="zStringDistance" localmode="modern" output="no" returntype="numeric">
   <cfargument name="string1" type="string" required="yes">
   <cfargument name="string2" type="string" required="yes">
   <cfscript>
   var str1len='';
	var str2len='';
	var m='';
	var a='';
	var i='';
	var j='';
	var temp='';
	</cfscript>
   <!--- 
   based on this javascript function:
   function levenshtein( str1, str2 ) {
    // http://kevin.vanzonneveld.net
    // +   original by: Carlos R. L. Rodrigues
    // *     example 1: levenshtein('Kevin van Zonneveld', 'Kevin van Sommeveld');
    // *     returns 1: 3
 
    var s, l = (s = str1.split("")).length, t = (str2 = str2.split("")).length, i, j, m, n;
    if(!(l || t)) return Math.max(l, t);
    for(var a = [], i = l + 1; i; a[--i] = [i]);
    for(i = t + 1; a[0][--i] = i;);
    for(i = -1, m = s.length; ++i < m;){
        for(j = -1, n = str2.length; ++j < n;){
            a[(i *= 1) + 1][(j *= 1) + 1] = Math.min(a[i][j + 1] + 1, a[i + 1][j] + 1, a[i][j] + (s[i] != str2[j]));
        }
    }
    return a[l][t];
}
    --->
   <cfscript>
   str1len = len(string1);
   str2len = len(string2);
   m=0;
   if(str1len eq 0 or str2len eq 0) return max(str1len, str2len);
   a = arraynew(1);
   i = str1len;
	while(i gte 1){
		a[i]=[i];
		i--;
	}
	i=str2len;
	while(i gte 1){
		a[1][i]=i;
		i--;
	}
	for(i = 1; i lt str1len;i++){
        for(j = 1; j lt str2len;j++){
			temp = min(a[i][j+1] + 1, a[i+1][j] + 1);
            a[i+1][j+1] = min(temp, a[i][j] + (mid(string1,i,1) neq  mid(string2,j,1)));
        }
    }
    return a[str1len][str2len]-1;   
   </cfscript>
</cffunction>

<cffunction name="zXMLFormat" localmode="modern">
	<cfargument name="s" type="any" required="yes">
	<cfscript>
	return rereplace(arguments.s, "[^\w\ \.@/-]","", "ALL");
	</cfscript>
</cffunction>


<cffunction name="zProcessAndStoreLinksInHTML" localmode="modern" returntype="string">
	<cfargument name="directoryName" type="string" required="yes">
	<cfargument name="t" type="string" required="yes">
	<cfscript>
	setting requesttimeout="3000";
	t=arguments.t;
	fileTypes={
		"pdf":true,
		"doc":true,
		"docx":true,
		"xlsx":true,
		"xls":true,
		"jpg":true,
		"jpeg":true,
		"gif":true,
		"png":true,
		"bmp":true,
		"tiff":true,
		"zip":true,
		"rtf":true,
		"csv":true
	};
	linkStruct={};
	a=listToArray(application.zcore.functions.zExtractLinksFromHTML(t), chr(9));
	for(i=1;i LTE arraylen(a);i++){
		ext=application.zcore.functions.zGetFileExt(a[i]);
		if(structkeyexists(fileTypes, ext)){
			linkStruct[a[i]]=true;
		}
	}
	a=listToArray(application.zcore.functions.zExtractImagesFromHTML(t), chr(9));
	for(i=1;i LTE arraylen(a);i++){
		ext=application.zcore.functions.zGetFileExt(a[i]);
		if(structkeyexists(fileTypes, ext)){
			linkStruct[a[i]]=true;
		}
	}
	a=structkeyarray(linkStruct);
	arraysort(a, "text", "desc"); // sort descending ensures similar urls are kept separate.
	arrFinal=[];

	dirName=lcase(application.zcore.functions.zURLEncode(application.zcore.functions.zLimitStringLength(arguments.directoryName, 30, false), "-"));
	if(arraylen(a)){

		fileCom=createobject("component", "zcorerootmapping.mvc.z.admin.controller.files");
		virtualFileCom=fileCom.getVirtualFileCom(); 
		if(not virtualFileCom.folderExistsByPath("auto-cached")){
			ts={
				data:{
					virtual_folder_name:"auto-cached",
					virtual_folder_path:"auto-cached"
				}
			};
			rs=virtualFileCom.createFolder(ts);
			if(not rs.success){ 
				// failed to create auto-cached folder  
				return t;
			}
		}
		dirPath="#request.zos.globals.privatehomedir#zupload/user/auto-cached/#dirName#/";
		rs=virtualFileCom.getFolderByPath("auto-cached/#dirName#");
 
		if(not rs.success){
			ts={
				data:{
					virtual_folder_name:dirName,
					virtual_folder_path:"auto-cached/"&dirName
				}
			}
			rs=virtualFileCom.createFolder(ts);
			if(not rs.success){ 
				// failed to create folder 
				return t;
			}
		} 
		for(i=1;i LTE arraylen(a);i++){ 
			fileName=getfilefrompath(a[i]);
			absoluteLink=application.zcore.functions.zForceAbsoluteURL(request.zos.currentHostName&"/", a[i]);
			if(left(absoluteLink, len(request.zos.currentHostName&"/")) EQ request.zos.currentHostName&"/"){
				continue;
			}
			count=0;
			ext=application.zcore.functions.zGetFileExt(fileName);
			theName=application.zcore.functions.zURLEncode(application.zcore.functions.zGetFileName(fileName), '-');
			newFileName=theName&"."&ext; 
			tempPath="auto-cached/"&dirName&"/"&newFileName;
			dirPath=request.zos.globals.privateHomeDir&"zupload/user/auto-cached/"&dirName&"/";
			if(virtualFileCom.fileExistsByPath(tempPath)){
				while(true){
					count++;
					if(count EQ 100){
						throw("Detected infinite loop");
					}
					newFileName=theName&count&"."&ext;
					tempPath="auto-cached/"&dirName&"/"&newFileName;
					if(not virtualFileCom.fileExistsByPath(tempPath)){
						break;
					}
				}
			}
			success=true; 
			try{
				http url="#a[i]#" timeout="30" path="#dirPath#" file="#newFileName#"{

				};
			}catch(Any e){   
				success=false;
			}
			if(success){
				ts={
					data:{
						virtual_file_name:newFileName,
						virtual_file_path:tempPath,
						virtual_file_secure:0,
						virtual_file_user_group_list:""
					}
				};
				rs=virtualFileCom.createFile(ts); 
				if(rs.success EQ false){
					// Failed to create file
					continue;
				} 

				viewLink=virtualFileCom.getViewLink(rs.data);
				arrayAppend(arrFinal, {originalURL: a[i], newURL: viewLink });
			}
		}

		for(i=1;i LTE arraylen(arrFinal);i++){
			t=replace(t, arrFinal[i].originalURL, arrFinal[i].newURL, 'all'); 
		}
	} 
	return t;
	</cfscript>
</cffunction>

<!--- 

application.zcore.functions.zLimitStringLength("long text", 5);
 --->
<cffunction name="zLimitStringLength" localmode="modern">
	<cfargument name="text" type="string" required="yes">
	<cfargument name="length" type="numeric" required="yes">
	<cfargument name="enableEllipsis" type="boolean" required="no" default="#true#">
	<cfscript>
 	textLength=len(arguments.text);   
	if(arguments.length GT textLength){
		return arguments.text;
	}
	newText=left(arguments.text, arguments.length);
	spacePosition=find(" ", reverse(newText));
	affix="...";
	if(not arguments.enableEllipsis){
		affix="";
	}
	if(arguments.length-spacePosition LTE 0){
		return newText&affix;
	}
	return left(newText, arguments.length-spacePosition)&affix;
	</cfscript>
</cffunction>

<cffunction name="zPluralize" localmode="modern">
	<cfargument name="quantity" type="any" required="yes">
	<cfargument name="singular" type="any" required="yes">
	<cfargument name="plural" type="any" required="yes">
    <cfscript>
	if(quantity EQ 1){
		return singular;
	}else{
		return plural;
	}
	</cfscript>
</cffunction>

<cffunction name="zGetStringDistance" localmode="modern">
	<cfargument name="s" type="any" required="yes">
    <cfargument name="t" type="any" required="yes">
    <cfscript>
	var d = ArrayNew(1);
	var n=0; // length of s
	var m=0; // length of t
	var i=0; // iterates through s
	var j=0; // iterates through t
	var s_i=0; // ith character of s
	var t_j=0; // jth character of t
	var cost=0; // cost


	// Step 1
	n = len(s);
	m = len(t);
	if (n EQ 0) {
		return m;
	}

	if (m EQ 0) {
		return n;
	}
	
	for(i=1; i LTE n; i=i+1)
		d[i] = ArrayNew(1);


	// Step 2
	for (i = 1; i LTE n; i=i+1) {
		d[i][1] = i;
	}

	for (j = 1; j LTE m; j=j+1) {
		d[1][j] = j;
	}

	// Step 3
	for (i = 2; i LTE n; i=i+1) {

		s_i = mid(s, i - 1,1);
		
		// Step 4
		for (j = 2; j LTE m; j=j+1) {

			t_j = mid(t,j - 1,1);

			// Step 5
			if (s_i EQ t_j) {
				cost = 0;
			}
			else {
				cost = 1;
			}
			
			a = d[i-1][j]+1;
			b = d[i][j-1]+1;
			c = d[i-1][j-1] + cost;
			
			mi = a;
			if (b LT mi) mi = b;
			if (c LT mi) mi = c;
			d[i][j] = mi;
		}

	}
	for(i=2; i LTE n; i=i+1) {
		dG[i] = ArrayNew(1);
		for(j=2; j LTE m; j=j+1){
			dG[i][j] = d[i][j];
		}
	}

	// Step 7
	return d[n][m]-1;
	</cfscript>
</cffunction>

<cffunction name="zForceAbsoluteURL" localmode="modern" output="no" returntype="string">
	<cfargument name="pageURL" type="string" required="yes">
    <cfargument name="linkURL" type="string" required="yes">
   	<cfscript>
	var start=0;
	var end=0;
	var domain=0;
	if(find(":",arguments.linkURL) NEQ 0){
		return arguments.linkURL;
	}
	if(left(arguments.linkURL,2) EQ '//'){
		if(request.zos.cgi.server_port EQ "443"){
			arguments.linkURL="https:"&arguments.linkURL;	
		}else{
			arguments.linkURL="http:"&arguments.linkURL;	
		}
	}
	if(right(arguments.pageURL,1) EQ '/' and left(arguments.linkURL,1) EQ '/'){
		arguments.pageURL=left(arguments.pageURL,len(arguments.pageURL)-1);
	}
	if(left(arguments.linkURL,4) NEQ 'http'){			
		if(left(arguments.linkURL,1) EQ '/'){
			start=find("/",arguments.pageURL)+2;
			end=0;
			if(start NEQ 0){
				end=find("/",arguments.pageURL,start);
			}
			if(end EQ 0){
				domain= arguments.pageURL;
			}else{
				domain= mid(arguments.pageURL, 1, end);
			}
			return domain&arguments.linkURL;
		}else{
			start=find("/",arguments.pageURL)+2;
			end=0;
			if(start NEQ 0){
				end=find("/",arguments.pageURL,start);
			}
			if(end EQ 0){
				return arguments.pageURL&'/'&arguments.linkURL;
			}else if(getdirectoryfrompath(arguments.pageURL) EQ 'http:'){
				return arguments.pageURL&arguments.linkURL;
			}else{
				return getdirectoryfrompath(arguments.pageURL)&arguments.linkURL;
			}
		}
	}else{
		return arguments.linkURL;
	}
	</cfscript>
</cffunction>


<!--- FUNCTION: zListToArray(list, delimiter); --->
<cffunction name="zListToArray" localmode="modern" output="false" returntype="any">
	<cfargument name="list" type="string" required="yes">
	<cfargument name="delimiter" type="string" required="no" default=",">
	<cfscript>
	var matching = true;
	var arrMatches = ArrayNew(1);
	var result = StructNew();
	var index = 1;
	var i=1;
	while(matching){
		result = findnocase(arguments.delimiter, arguments.list, index);
		if(result EQ 0){
			matching = false;
		}
		if(result NEQ 0){
			ArrayAppend(arrMatches, mid(arguments.list, index, result-index));
			index = result+len(arguments.delimiter);
		}else{
			matching = false;
		}
	}
	ArrayAppend(arrMatches, mid(arguments.list, index, (len(arguments.list)-index)+1));
	return arrMatches;
	</cfscript>	
</cffunction>

<!--- zFixAbusiveCaps(string); --->
<cffunction name="zFixAbusiveCaps" localmode="modern" returntype="any">
	<cfargument name="string" type="string" required="yes">
	<cfscript>
	var i=1;
	var capCount=0;
	if(len(arguments.string) GT 0){
		for(i=1;i LTE 10;i=i+1){
			if(Compare(ucase(mid(arguments.string,i,1)), mid(arguments.string,i,1)) EQ 0){
				capCount=capCount+1;
			}
		}
		if(capCount GTE 5){
			return ucase(mid(arguments.string,1,1))&lcase(mid(arguments.string,2,len(arguments.string)-1));
		}
	}
	return arguments.string;
	</cfscript>
</cffunction>


<!--- zNumberToLetter(number); --->
<cffunction name="zNumberToLetter" localmode="modern" returntype="any" output="false">
	<cfargument name="number" required="yes" type="any">
	<cfreturn listGetAt("a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z", arguments.number)>
</cffunction>

<cffunction name="zCFFormat" localmode="modern" output="no" returntype="string">
	<cfargument name="text" type="string" required="yes">
    <cfscript>
	return "'"&replace(arguments.text,"'","''","ALL")&"'";
	</cfscript>
</cffunction>

<cffunction name="zCFFormatNoVars" localmode="modern" output="no" returntype="string">
	<cfargument name="text" type="string" required="yes">
    <cfscript>
	return "'"&replace(replace(arguments.text,"##","####","ALL"),"'","''","ALL")&"'";
	</cfscript>
</cffunction>

<cffunction name="zParseVariables" localmode="modern" returntype="any" output="no">
 	<cfargument name="str" type="string" required="yes">
	<cfargument name="escapeWith" type="string" required="yes">
	<cfargument name="varStruct" type="any" required="yes">
	<cfargument name="allowLiteralPound" type="boolean" required="no" default="#false#">
	<cfscript>
	var i=0;
	var p=0;
	var result="";
	var arrD=0;
	var e=0;
	var v=0;
	if(arguments.escapeWith EQ false){
		arguments.escapeWith="";
	}
	e=len(arguments.escapeWith);
	if(arguments.allowLiteralPound){
		arrD=listtoarray(replace(replace(arguments.str, chr(13),"","all"), "####",chr(13), "all"), "##", true);
	}else{
		arrD=listtoarray(arguments.str, "##", true);
	}
	v=arraylen(arrD);
	</cfscript><cfsavecontent variable="result"><cfscript>
	if(v MOD 2 EQ 0){
		application.zcore.template.fail("zParseVariables: The input string is missing a ## symbol. input string = '#arguments.str#'");	
	}
	for(i=1;i LTE v;i++){
		if(len(arrD[i])){
			if(i MOD 2 EQ 0){
				if(e){
					writeoutput(application.zcore.functions.zURLEncode(arguments.varStruct[arrD[i]], arguments.escapeWith));		
				}else{
					writeoutput(arguments.varStruct[arrD[i]]);
				}
			}else{
				writeoutput(arrD[i]);
			}
		}
	}
	</cfscript></cfsavecontent><cfscript>
	if(arguments.allowLiteralPound){
		return replace(result, chr(13), "##", "all");
	}else{
		return result;
	}
	</cfscript> 
 </cffunction>




<!--- 
DESCRIPTION
	better version of the similiar paragraphFormat();
USUAGE
	zParagraphFormat(value); 
	--->
<cffunction name="zParagraphFormat" localmode="modern" returntype="any" output="false">
	<cfargument name="value" type="any" required="yes">
	<cfscript>
	if(arguments.value EQ ""){
		return "";
	}else{
		v=replace(replace(arguments.value, chr(13), "", "all"), chr(10), "<br>", "ALL");
		return '<p>'&replacenocase(v, '<br><br>', '</p><p>', "all")&'</p>';
	}
	</cfscript>
</cffunction>





<cffunction name="zURLAppend" localmode="modern" returntype="any" output="false">
	<cfargument name="aURL" type="string" required="no" default="">
	<cfargument name="queryString" type="string" required="no" default="">
	<cfscript>	
	var poundPosition=find("##", arguments.aURL);
	if(arguments.aURL EQ false){
		arguments.aURL = "";
	}
	if(arguments.aURL EQ ""){
		arguments.aURL = request.cgi_script_name;
		if(CGI.QUERY_STRING NEQ ""){
			arguments.aURL = arguments.aURL &"?"&CGI.QUERY_STRING;
		}
	}
	if(poundPosition EQ 0){
		if(find("?", arguments.aURL) EQ 0){
			return arguments.aURL&"?"&arguments.queryString;
		}else{
			return arguments.aURL&"&"&arguments.queryString;	
		}
	}else{
		if(find("?", arguments.aURL) EQ 0){
			return insert("?"&arguments.queryString, arguments.aURL, poundPosition-1);
		}else{
			return insert("&"&arguments.queryString, arguments.aURL, poundPosition-1);
		}
	}
	</cfscript>
</cffunction>

<cffunction name="zFriendlyName" localmode="modern" returntype="any" output="false">
	<cfargument name="name" type="string" required="yes">
	<cfset arguments.name = replacelist(arguments.name, "1,2,3,4,5,6,7,8,9,0,_", " 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, ")>
	<cfset arguments.name = application.zcore.functions.zFirstLetterCaps(arguments.name)>
	<cfif arguments.name EQ ""><cfthrow detail="zFirstLetterCaps: Empty strings are not allowed, please contact webmaster"></cfif>
	<cfreturn arguments.name>
</cffunction>


<!--- application.zcore.functions.zDownloadLink(link, timeout); --->
<cffunction name="zDownloadLink" localmode="modern" returntype="any" output="false">
	<cfargument name="link" type="string" required="yes">
	<cfargument name="timeout" type="string" required="no" default="#30#">
	<cfargument name="useSecureCommand" type="boolean" required="no" default="#false#">
	<cfscript>
	var find1 = "";
	var find2 = "";
	var method="GET";
	var cfhttp=0;
	var rs={success:false};
	find1 = findNoCase("http://", arguments.link);
	find2 = findNoCase("https://", arguments.link);
	if(find2 NEQ 0){
		// cfml doesn't support SNI for SSL connections, so we force PHP Curl download on all SSL connections to avoid in case the domain uses SNI.
		arguments.useSecureCommand=true;
	}
	if(find1 EQ 0 and find2 EQ 0){
		arguments.link = "http://"&arguments.link;
	}
	if(arguments.useSecureCommand){
		result=application.zcore.functions.zSecureCommand("httpDownload"&chr(9)&arguments.link&chr(9)&arguments.timeout-2, arguments.timeout);
		if(result EQ 0){
			return rs;
		}else{
			rs={
				success:true,
				cfhttp:{
					filecontent:result,
					statusCode:"200 OK"
				}
			}
			return rs;
		}
	}
	</cfscript>
    <cftry>
		<cfhttp url="#arguments.link#" method="#method#" timeout="#arguments.timeout#" redirect="yes" charset="utf-8" useragent="Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36 Jetendo CMS">
		<!--- Jetendo CMS and Feedburner are added to user agent to allow web server to bypass security / ssl checks --->
		<cfhttpparam type="Header" name="Accept-Encoding" value="#request.httpCompressionType#">
		<cfhttpparam type="Header" name="TE" value="#request.httpCompressionType#"></cfhttp>
		<cfcatch type="any">
			<!--- try again without https to bypass SNI SSL support problem. --->
			<cfif left(arguments.link, 5) EQ "https">
    				<cftry>
					<cfhttp url="#replace(arguments.link, 'https', 'http')#" method="#method#" timeout="#arguments.timeout#" redirect="yes" charset="utf-8" useragent="Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36 Jetendo CMS ">
					<!--- Jetendo CMS and Feedburner are added to user agent to allow web server to bypass security / ssl checks --->
					<cfhttpparam type="Header" name="Accept-Encoding" value="#request.httpCompressionType#">
					<cfhttpparam type="Header" name="TE" value="#request.httpCompressionType#"></cfhttp>
					<cfcatch type="any">
					</cfcatch>
				</cftry>
			</cfif>
			<cfreturn rs>
		</cfcatch>
	</cftry>
	<cfset rs.cfhttp=cfhttp>
	<cfif structkeyexists(CFHTTP,'FileContent') AND (isbinary(CFHTTP.FileContent) or CFHTTP.FileContent NEQ "Connection Failure") and isDefined('cfhttp.responseheader.status_code') and cfhttp.responseheader.status_code EQ 200>
		<cfset rs.success=true>
		<cfreturn rs>
	<cfelse>
		<cfreturn rs>
	</cfif>
</cffunction>

<cffunction name="zVerifyLink" localmode="modern" returntype="any" output="no">
	<cfargument name="link" type="string" required="yes">
	<cfargument name="findlink" type="string" required="no" default="">
	<cfargument name="timeout" type="numeric" required="no" default="#20#">
	<cfscript>
	var find1 = "";
	var find2 = "";
	var method="GET";
	var cfhttp=0;
	var ext=application.zcore.functions.zgetfileext(arguments.link);
	find1 = findNoCase("http://", arguments.link);
	find2 = findNoCase("https://", arguments.link);
	if(find1 EQ 0 and find2 EQ 0){
		arguments.link = "http://"&arguments.link;
	}
	if(arguments.findlink EQ ''){
		method='HEAD';
	}
	if(replacelist(ext, "jpg,gif,png,js,css,doc,pdf",",,,,,,") NEQ ext){
		method="GET";
	}
	</cfscript>
	<cfhttp url="#arguments.link#" method="#method#" redirect="yes" timeout="#arguments.timeout#" charset="utf-8" useragent="Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3 GoogleToolbarFF 3.1.20080730 Jetendo CMS">
		<cfhttpparam type="Header" name="Accept-Encoding" value="#request.httpCompressionType#">
		<cfhttpparam type="Header" name="TE" value="#request.httpCompressionType#"></cfhttp>
	<cfif (structkeyexists(cfhttp,'filecontent') EQ false or isbinary(CFHTTP.FileContent) or CFHTTP.FileContent NEQ "Connection Failure") and isDefined('cfhttp.responseheader.status_code') and cfhttp.responseheader.status_code EQ 200>
		<cfif arguments.findlink EQ '' or findnocase(arguments.findlink, CFHTTP.FileContent) NEQ 0>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<cffunction name="zFirstLetterCaps" localmode="modern" returntype="any" output="false">
	<cfargument name="string" type="string" required="yes">
	<cfscript>
	var i=0;
	return ucFirst(lcase(arguments.string), true, true);
	/*
	var firstLetter = "";
	var arrString = ListToArray(lcase(arguments.string), " ");
	for(i=1;i LTE ArrayLen(arrString);i=i+1){
		firstLetter = ucase(left(arrString[i], 1));
		arrString[i] = firstLetter & removeChars(arrString[i], 1, 1);
	}
	return ArrayToList(arrString, " ");
	*/
	</cfscript>
</cffunction>


<cffunction name="zEmailValidate" localmode="modern" returntype="boolean" output="yes">
    <cfargument name="email" type="string" required="yes">
    <cfscript>
    var tmpE="";
    var arrM=0;
    var n=0;
    //var class="\!\##\$\%&'\*\-\?\^_`\.\{\|\}~";
    //var reg = "^[a-zA-Z0-9#class#][#class#\+/=\w\.-]*[#class#a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$";
    reg="^[a-zA-Z0-9.!##$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$";
    var ipCheck="";
    arguments.email=trim(arguments.email);
    if(len(arguments.email) EQ 0){
        return false;
    }
    tmpE=replace(arguments.email,'\"','','ALL');
    tmpE=rereplace(tmpE,'".*?"','test','ALL');
    if(find('"',tmpE) NEQ 0){
        // unequal number of quotes
        return false;
    }else if(find('..',tmpE) NEQ 0){
        // can't have 2 consequtive dots
        return false;
    }else if(right(tmpE,1) EQ '.' or find(".@",tmpE) NEQ 0){
        // can't have a period next to the @ or at the end.
        return false;
    }
    atPosition=find("@",tmpE);
    if(atPosition NEQ 0 and len(tmpE)-atPosition GT 0 and mid(tmpE, atPosition, len(tmpE)-atPosition) DOES NOT CONTAIN "."){
    	return false;
    }
    ipCheck=right(arguments.email,max(find("@",reverse(arguments.email))-1,1));
    if(left(ipCheck,1) EQ '[' and right(ipCheck,1) EQ ']'){
        return true;
    }else if(REFind(reg, tmpE) EQ 1){
        return true;
    }else{
        return false;
    }
    
    </cfscript>
</cffunction> 


<!--- 
formating rules explained here: http://mailformat.dan.info/headers/from.html
addressList must be comma separated with "Name" <email> format
displayFormat makes an additional user friendly copy of the text
zEmailValidateList(addressList, displayFormat);
 --->
<cffunction name="zEmailValidateList" localmode="modern" output="yes" returntype="any">
    <cfargument name="addressList" type="string" required="yes">
    <cfargument name="displayFormat" type="boolean" required="no" default="#false#">
    <cfscript>
    var rs=StructNew();
    var count=listlen(arguments.addressList);
    var arrC2=listtoarray(arguments.addressList,'',true);
    var asi=0;
    var inEmail=false;
    var inString=false;
    var inParen=false;
    var inBegin=true;
    var curType="string";
    var str="";
    var i=0;
    var n=0;
    var letter="";
    var nextLetter="";
    rs.success=true;
    rs.string=arraynew(1);
    rs.email=arraynew(1);
    rs.valid=arraynew(1);
    rs.invalid=arraynew(1);
    rs.processed=arraynew(1);
	if(arguments.displayFormat){
    	rs.displayProcessed=arraynew(1);
	}
	if(count EQ 0){
		rs.success=false;
		arrayappend(rs.invalid, 'A valid email address is required.');
		return rs;
	}
    arrayset(rs.string,1,count,'');
    arrayset(rs.email,1,count,'');
    // test against these patterns:
    //arguments.field='"John Q. Smith" <jqsmith@example.net>,"domain.com{}<>?/.,;'':\"\\|\)\(_+*&=^%$##@!\"test" <anything@site.com>,jqsmith@example.net (John Q. Smith),jqsmith@example.net,jqsmith@[127.0.0.1],"System Administrator",=?windows-1251?B?wPDn4Ozg8fbl4g==?= <teewang@phayze.com>,"Guy Macon" <guymacon+" http://www.guymacon.com/ "00@spamcop.net>,Abc@example.com,Abc.123@example.com,user+mailbox/department=shipping@example.com,!##$%&''*+-/=?^_`.{|}~@example.com,"Abc@def"@example.com,"Fred Bloggs"@example.com,"Joe.\\Blow"@example.com,Abc.example.com,Abc.@example.com,Abc..123@example.com,"test"+mean+"test2"@bruce.com,!##$%&''*+-/=?^_`.{|}@example.com,test@tete.com';
    
    for(i=1;i LTE arraylen(arrC2);i++){
        letter=arrC2[i];
        nextLetter="";
        if(arraylen(arrC2) NEQ i+1){
            nextLetter=arrC2[i];
        }
        if(letter EQ '@'){
            if(inBegin){
                curType='email';
            }
        }else if(letter EQ ';' or letter EQ ','){
            if(inBegin){
                asi++;
                rs[curType][asi]=str;
                str="";
            }
            inBegin=false;
            if(inString){
                // this is a literal
            }else{
                if(trim(str) NEQ ''){
                    if(left(str,1) EQ '@'){
                        rs.email[asi]=rs.string[asi]&str;
                        rs.string[asi]="";
                    }else if(inEmail){
                        rs.email[asi]&=str;
                        str="";
                    }else if(inString){
                        rs.string[asi]&=str;
                        str="";
                    }else if(find("@", str) NEQ 0){
                        rs.email[asi]&=str;
                        str="";
                    }else{
                        rs.string[asi]&=str;
                        str="";
                    }
                }
                letter="";
                inEmail=false;
                inString=false;
                inParen=false;
                inBegin=true;
                curType="string";
                str="";
            }
        }else if(letter EQ '"'){
            if(inBegin){
                asi++;
                rs[curType][asi]=str;
                str="";
            }
            inBegin=false;
            if(inEmail){
                // this is a literal
            }else if(inString){
                rs.string[asi]&=str&'"';
                str="";
                inString=false;
                letter="";
            }else{
                inString=true;
                //letter="";
                inBegin=false;
            }
        }else if(letter EQ '\'){
            if(nextLetter EQ '"' or nextLetter EQ "(" or nextLetter EQ ")" or nextLetter EQ "\"){
                // this is an escaped character
                letter=letter&nextLetter;
                i++;
            }
            // store next letter and removeChars
        }else if(letter EQ '('){
            if(inBegin){
                asi++;
                rs[curType][asi]=str;
                str="";
                inBegin=false;
            }
            if(inString){
                // this is a literal
            }else{
                inParen=true;
                letter="";
            }
        }else if(letter EQ ')'){
            if(inString){
                // this is a literal
            }else{
                rs.string[asi]&=str;
                str="";
                letter="";
                inParen=false;
            }
        }else if(letter EQ '<'){
            if(inBegin){
                asi++;
                rs[curType][asi]=str;
                str="";
            }
            inBegin=false;
            if(inString){
                // this is a literal
            }else{
                // end the previous string and start an email address
                inEmail=true;
                letter="";
            }					
        }else if(letter EQ '>'){
            if(inString){
                // this is a literal
            }else if(inEmail){
                // end of email address - store in variable
                rs.email[asi]&=str;
                str="";
                inEmail=false;
                letter="";
            }
        }
        str=str&letter;
    }
    if(arraylen(rs[curType]) EQ 0 and inBegin){
        asi++;
        rs[curType][asi]=str;
    }else if(trim(str) NEQ ''){
        if(left(str,1) EQ '@'){
            rs.email[asi]=rs.string[asi]&str;
            rs.string[asi]="";
        }else if(inEmail){
            rs.email[asi]&=str;
                asi++;
            str="";
        }else if(inString){
            rs.string[asi]&=str;
                asi++;
            str="";
        }else if(find("@", str) NEQ 0){
                asi++;
            rs.email[asi]&=str;
            str="";
        }else{
                asi++;
            rs.string[asi]&=str;
            str="";
        }
    }
    for(i=1;i LTE count;i++){
        if(i GT asi){
            arraydeleteat(rs.string,i);
            arraydeleteat(rs.email,i);
            
        }else{
            rs.string[i]=trim(rs.string[i]);
            rs.email[i]=trim(rs.email[i]);
            if(left(rs.string[i],1) EQ '"' and right(rs.string[i],1) EQ '"'){
                rs.string[i]=mid(rs.string[i],2,len(rs.string[i])-2);
            }
            if(rs.string[i] EQ 'System Administrator' and rs.email[i] EQ ''){
                // ignore
                rs.processed[i]='';
                continue;
            }
            if(rs.string[i] NEQ ''){
                if(rs.email[i] NEQ ''){
                    rs.processed[i]='"'&replace(replace(rs.string[i],'\','\\',"ALL"),'"','\"',"ALL")&'" <'&rs.email[i]&'>';
                }else{
                    rs.processed[i]=rs.string[i];
                }
            }else{
                rs.processed[i]=rs.email[i];
            }
			if(arguments.displayFormat){
				str=rs.processed[i];
				str=replace(str,'\"','"','ALL');
				str=replace(str,'\(','(','ALL');
				str=replace(str,'\)',')','ALL');
				str=replace(str,'\\','\','ALL');
				rs.displayProcessed[i]=str;
			}
            if((rs.email[i] EQ '' and rs.string[i] NEQ '') or application.zcore.functions.zEmailValidate(rs.email[i]) EQ false){
                // invalid
                rs.success=false;
                arrayappend(rs.invalid,i);
            }else{
                arrayappend(rs.valid,i);
            }
        }
    }
    return rs;
    </cfscript>
</cffunction>

<!--- application.zcore.functions.zValidateURL(link, true, false); --->
<cffunction name="zValidateURL" access="public" localmode="modern"> 
	<cfargument name="link" type="string" required="yes">
	<cfargument name="disableSpecialCharacters" type="boolean" required="yes">
	<cfargument name="disableExternal" type="boolean" required="yes">
	<cfscript>
	link=arguments.link;
	if(left(link, 4) EQ 'tel:' or left(link, 7) EQ 'mailto:'){
		return true;
	}

	if(arguments.disableSpecialCharacters){
		link2=link;
		if(left(link2, 7) EQ 'http://'){
			link2=removeChars(link2, 1, 7);
		}else if(left(link, 8) EQ 'https://'){
			link2=removeChars(link2, 1, 8);
		} 
		if(link2 CONTAINS "/./"){
			return false;
		}else if(link2 CONTAINS "/../"){
			return false;
		}else if(find(" ", link2) NEQ 0 or find(chr(9), link2) NEQ 0){
			return false;
		}else if(rereplacenocase(link2, '[a-z0-9\._\-\/##]*', '', 'all') NEQ ""){
			return false;
		}
	}

	if(link NEQ ""){
		if(left(link, 1) EQ "/" or left(link, 1) EQ "##"){
			return true;
		}else if(left(link, '7') EQ 'http://' or left(link, '8') EQ 'https://'){
			if(arguments.disableExternal){
				return false;
			}
			return true;
		}else{
			return false;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zFormatPhoneNumber( phoneNumber ); --->
<cffunction name="zFormatPhoneNumber" output="no" returntype="any" localmode="modern">
	<cfargument name="phoneNumber" type="string" required="yes">
	<cfscript>
		var phoneNumber = arguments.phoneNumber;

		// Return immediately if phone number was empty.
		if ( phoneNumber EQ '' ) {
			return phoneNumber;
		}

		// Remove all non-numeric characters. This will remove any existing
		// formatting from the string.
		var formattedPhoneNumber = reReplace( phoneNumber, '([^0-9]*)', '', 'ALL' );

		// Return after removing non-numeric characters if string is empty.
		if ( formattedPhoneNumber EQ '' ) {
			return phoneNumber;
		}

		// Determine how to handle the phone number.
		if ( len( formattedPhoneNumber ) EQ 7 ) {
			// Phone number is in XXX-XXXX format (without area code).
			formattedPhoneNumber = left( formattedPhoneNumber, 3 ) & '-' & right( formattedPhoneNumber, 4 );
		} else if ( len( formattedPhoneNumber ) EQ 10 ) {
			// Phone number is in XXX-XXX-XXXX format (includes area code).
			formattedPhoneNumber = '(' & left( formattedPhoneNumber, 3 ) & ') ' & mid( formattedPhoneNumber, 4, 3 ) & '-' & right( formattedPhoneNumber, 4 );
		} else {
			// The phone number is either improperly formatted, an international
			// number or contained characters that evaluated to an improper
			// expected phone number length. At this point we will just return
			// what was provided.
			return phoneNumber;
		}

		return formattedPhoneNumber;
	</cfscript>
</cffunction>

<!---
Returns a Google Maps URL formatted like the following:

	https://www.google.com/maps/place/1234+Street,+Suite+567,+Orlando,+FL+12345/

Example address struct:

	address = {
		'Name': 'Company Name',
		'Address': '1234 Street',
		'Address 2': 'Suite 567',
		'City': 'Orlando',
		'State': 'FL',
		'Zip': '12345',
		'Country': 'United States'
	};

Example usage:

	#application.zcore.functions.zGoogleMapsURLFromAddress( address )#

--->
<cffunction name="zGoogleMapsURLFromAddress" output="no" returntype="any" localmode="modern">
	<cfargument name="address" type="struct" required="yes">
	<cfscript>
		var address = arguments.address;

		// Allow for other field variations ('Street Address', 'Zip Code').
		if ( structKeyExists( address, 'Street Address' ) ) address['Address'] = address['Street Address'];
		if ( structKeyExists( address, 'Zip Code' ) )       address['Zip']     = address['Zip Code'];

		// Make sure that we have a properly formatted struct that includes at
		// least the Address, City, and State keys.
		if ( ! structKeyExists( address, 'Address' ) ) return;
		if ( ! structKeyExists( address, 'City' ) )    return;
		if ( ! structKeyExists( address, 'State' ) )   return;

		// Add in empty values for optional keys.
		if ( ! structKeyExists( address, 'Name' ) )      address['Name']      = '';
		if ( ! structKeyExists( address, 'Address 2' ) ) address['Address 2'] = '';
		if ( ! structKeyExists( address, 'Zip' ) )       address['Zip']       = '';
		if ( ! structKeyExists( address, 'Country' ) )   address['Country']   = '';

		// Build the address string.
		var addressString = '';

		// Name is optional.
		if ( address['Name'] NEQ '' ) addressString = address['Name'] & ', ';

		addressString &= address['Address'];

		// Address 2 is optional.
		if ( address['Address 2'] NEQ '' ) addressString &= ', ' & address['Address 2'];

		addressString &= ', ' & address['City'];
		addressString &= ', ' & address['State'];

		// Country is optional.
		if ( address['Country'] NEQ '' ) addressString &= ', ' & address['Country'];

		// Zip is optional.
		if ( address['Zip'] NEQ '' ) addressString &= ' ' & address['Zip'];

		// Encode the address string to be used in the URL.
		addressString = urlencodedformat( addressString );

		// Build the Google Maps URL.
		var googleMapsURL = 'https://www.google.com/maps/place/';

		// Append the address string to the URL;
		googleMapsURL &= addressString & '/';

		return googleMapsURL;
	</cfscript>
</cffunction>



<cffunction name="zFormatInquiryPhone" localmode="modern" access="public">
	<cfargument name="phone" type="string" required="yes">
	<cfscript>
	phone=arguments.phone;
	if(phone EQ ""){
		return "";
	}
	// remove county prefix for ctm data
	phone=reReplace(phone, '\+1(.*)', '\1', 'ALL' );
	// try to remove ext
	phone=reReplaceNocase(phone, 'ext.*', '', 'ALL' );
	// remove all non-numeric
	phone=reReplace(phone, '[^0-9]*', '', 'ALL' );
	if(len(phone) LT 7){
		phone=""; // probably an invalid phone number
	}
	return trim(phone);
	</cfscript>
</cffunction>

<!--- 

<cfsavecontent variable="out">
## Vehicles
$ Discount
$/sqft
% Apartments
12 Text
About Button Text
Are you willing to work overtime?
Column 5 Width %
!@(*^^(@)$
</cfsavecontent>
<cfscript>
arr=listToArray(trim(out), chr(10));
for(s in arr){
	echo(application.zcore.functions.zStringToVariableName(s)&"<br>");
} 
abort;
</cfscript>
  --->
<cffunction name="zStringToVariableName" localmode="modern" access="public">
	<cfargument name="stringName" type="string" required="yes">
	<cfscript>
	s=left(arguments.stringName, 100)
	.replace("##", "Number ", "all")
	.replace("$", "Price ", "all")
	.replace("%", "Percent ", "all")
	.rereplace("[^a-zA-Z0-9 ]*", "", "all")
	.trim()
	.replace("  ", " ", "all")
	.ucFirst(true, true)
	.replace(" ", "", "all");
	if(isNumeric(left(s, 2))){
		s="_"&s;
	}else if(isNumeric(left(s, 1))){
		s=replacelist(left(s, 1), "1,2,3,4,5,6,7,8,9,0", "one,two,three,four,five,six,seven,eight,nine,zero")&" "&removeChars(s, 1, 1);
	}
	if(len(s) EQ 0){
		throw(""""&arguments.stringName&""" can't be converted to a valid variable name");
	}
	s=lcase(left(s, 1))&removeChars(s, 1, 1);
	return s;
	</cfscript>
</cffunction>

<cffunction name="zDisplayCookieNotice" localmode="modern" access="public">
	<cfif not structkeyexists(cookie, "ZHIDECOOKIENOTICE")>
		<div class="z-float zCookieNoticeDiv">
			<div class="z-container">
				Our website uses cookies to ensure a great experience. We also use third party cookies.  To find out more about the cookies on our web site, please read our <a href="/z/user/privacy/index">privacy policy</a>.  By continuing to use our website, you agree to the use of cookies. <a href="##" class="zStopCookieNotice">Continue</a>
			</div>
		</div>
		<script>
		zArrDeferredFunctions.push(function(){
			$(".zStopCookieNotice").on("click", function(e){
				e.preventDefault();
				zSetCookie({key:"ZHIDECOOKIENOTICE",value:"1",futureSeconds:365*60 * 60 * 24 * 7,enableSubdomains:false});
				$(".zCookieNoticeDiv").hide();
			});
		});
		</script>
	</cfif>
</cffunction>


<!--- 
jwtResult=application.zcore.functions.zJWTEncode(serializeJson({ test:true}), "secret", "HS256");
if(not jwtResult.success){
	throw("Problem encoding jwt:"&jwt);
} --->
<cffunction name="zJWTEncode" localmode="modern" access="public" returntype="boolean">
	<cfargument name="jsonString" type="string" required="yes">
	<cfargument name="key" type="string" required="yes">
	<cfargument name="algorithm" type="string" required="yes">
	<cfscript>
	result=application.zcore.functions.zSecureCommand("jwtEncode"&chr(9)&arguments.jsonString&chr(9)&arguments.key&chr(9)&arguments.algorithm, 20);
	if(result EQ "0"){
		return {success:false};
	}else{
		return {success:true, jwt:result};
	}
	</cfscript>
</cffunction>

<!--- 
jwtResult=application.zcore.functions.zJWTEncode(serializeJson({ test:true}), "secret", "HS256");
decodedResult=application.zcore.functions.zJWTDecode(jwtResult.jwt, "secret", "HS256");
if(not decodedResult.success){
	throw("Problem decoding jwt:"&jwt);
}
writedump(decodedResult.json);
 --->
<cffunction name="zJWTDecode" localmode="modern" access="public" returntype="boolean">
	<cfargument name="jwtString" type="string" required="yes">
	<cfargument name="key" type="string" required="yes">
	<cfargument name="algorithm" type="string" required="yes">
	<cfscript>
	result=application.zcore.functions.zSecureCommand("jwtDecode"&chr(9)&arguments.jwtString&chr(9)&arguments.key&chr(9)&arguments.algorithm, 20);
	if(result EQ "0"){
		return {success:false};
	}else{
		return {success:true, json:deserializeJson(result)};
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
