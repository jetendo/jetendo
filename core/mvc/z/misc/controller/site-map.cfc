<cfcomponent>
<cfoutput> 
<cffunction name="getLinks" localmode="modern" access="public" returntype="array">
	<cfscript>
	var arrURL=arraynew(1);
	var arrURL2=arraynew(1);
	var uniqueStruct=structnew();
	var i=0;
	if(fileexists(request.zos.globals.privatehomedir&"_cache/scripts/hardcoded-urls.json")){
		arrURL=deserializeJson(application.zcore.functions.zReadFile(request.zos.globals.privatehomedir&"_cache/scripts/hardcoded-urls.json"));
	}
	arrURL=application.zcore.app.getSiteMap(arrUrl);
	for(i=1;i LTE arraylen(arrURL);i++){
		if(structkeyexists(uniqueStruct, arrURL[i].url) EQ false){
			arrayAppend(arrURL2, arrURL[i]);
			uniqueStruct[arrURL[i].url]=true;
		}
	}

	arrayAppend(arrURL2, { groupName: 'Miscellaneous', title:'Privacy Policy & Cookies', url:request.zos.currentHostName&'/z/user/privacy/index'});
	arrayAppend(arrURL2, { groupName: 'Miscellaneous', title:'Terms of Use', url:request.zos.currentHostName&'/z/user/terms-of-use/index'});
	arrayAppend(arrURL2, { groupName: 'Miscellaneous', title:'Legal Notices', url:request.zos.currentHostName&'/z/misc/system/legal'});
	arrayAppend(arrURL2, { groupName: 'Miscellaneous', title:'Accessibility Statement', url:request.zos.currentHostName&'/z/user/accessibility/index'});
	if(form.method EQ "index"){
		arrayAppend(arrURL2, { groupName: 'Miscellaneous', title:'XML Site Map', url:request.zos.currentHostName&'/sitemap.xml.gz'});
	}

	return arrURL2;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var i=0;
	var g=0;
	var firstEmptyGroup=0;
	var arrUrl=this.getLinks();
	application.zcore.template.setTag("title","Site Map");
	application.zcore.template.setTag("pagetitle","Site Map");
	application.zcore.template.setTag("pagenav", '<a href="/">Home</a> /');
	firstEmptyGroup=true;

	groupOutput={};
	for(i=1;i LTE arraylen(arrUrl);i++){
		if(not structkeyexists(arrUrl[i],'groupName')){
			savecontent variable="out"{
				writedump(arrURL[i]);
			}
			throw("groupName was missing in site map link: #arrURL[i]#");
		}
		if(not structkeyexists(groupOutput, arrUrl[i].groupName)){
			groupOutput[arrUrl[i].groupName]={ groupName: arrUrl[i].groupName, arrLinks:[] };
		}
		arrayAppend(groupOutput[arrUrl[i].groupName].arrLinks, arrURL[i]);
	}
	arrGroup=structsort(groupOutput, "text", "asc", "groupName");
	for(i=1;i LTE arraylen(arrGroup);i++){
		group=arrGroup[i];
		g=groupOutput[arrGroup[i]].arrLinks;
		if(arraylen(g)){
			echo('<h2>'&group&'</h2>
				<ul>');
			for(n=1;n LTE arraylen(g);n++){
				if(structkeyexists(g[n],"indent")){
					echo('<li style="margin-left:'&(len(g[n].indent)*8)&'px;">');
				}else{
					echo('<li>');
				}
				echo('<a href="'&replace(g[n].url,request.zos.globals.domain&"/", request.zos.currentHostName&"/")&'">'&g[n].title&'</a></li>');
			}
			echo('</ul>');
		}
	}
	</cfscript>
</cffunction>

        
<cffunction name="xmloutput" localmode="modern" access="remote">
        <cfscript>
	var arrXML=arraynew(1);
        var g="";
	var arrURL=this.getLinks();
	
	arrayappend(arrXML,'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');
	for(i=1;i LTE arraylen(arrUrl);i++){
		if(arrUrl[i].url CONTAINS "/z/misc/thank-you/index"){
			continue;
		}
		arrayappend(arrXML,'<url><loc>'&xmlformat(arrUrl[i].url)&'</loc>');
		if(structkeyexists(arrUrl[i],'lastmod')){
			arrayappend(arrXML,'<lastmod>'&xmlformat(arrURl[i].lastmod)&'</lastmod>');
		}
		arrayappend(arrXML,'</url>');
	}
	arrayappend(arrXML,'</urlset>');
	xDoc=arraytolist(arrXML,'');
	filePath=request.zos.globals.privatehomedir&'zcache/sitemap.xml';
	domainPath=request.zos.globals.domain&'/sitemap.xml.gz';
	if(not fileexists(filePath) or hash(xDoc) NEQ hash(application.zcore.functions.zreadfile(filePath)) or structkeyexists(form, 'force')){
		application.zcore.functions.zwritefile(filePath, xDoc);
		application.zcore.functions.zGzipFilePath(filePath, 10);
		if(fileexists(filePath)){
			application.zcore.functions.zdeletefile(filePath);
		}
		if(request.zos.istestserver EQ false and (structkeyexists(application.sitestruct[request.zos.globals.id],'lastSiteMapPing') EQ false or datecompare(dateadd("n",-30,now()),application.sitestruct[request.zos.globals.id].lastSiteMapPing) EQ 1)){
			application.sitestruct[request.zos.globals.id].lastSiteMapPing=now();
			pingURL="https://www.google.com/webmasters/tools/ping?sitemap="&URLEncodedFormat(domainPath);
			r1=application.zcore.functions.zdownloadlink(pingURL);
			if(r1.success EQ false){
				savecontent variable="output"{
					writedump(r1);
				}
				throw("Failed to ping google with pingURL = #pingURL#. "&output);
			}
		}
	}
	writeoutput('Done');
	application.zcore.functions.zabort();
        </cfscript>
</cffunction>
</cfoutput>
</cfcomponent>