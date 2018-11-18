<cfcomponent>
<!--- 


below are OLD NOTES::::
write a PHP script that loops through zcorerootpath/javascript/
minify each file and give it a version file name.
cache the version into the filename in zcorerootpath/javascriptcache/ - use the lastmodifieddate + filesize? like fileName.file_id.20121020.123901.2123123.js
update coldfusion server scope
cleanup versions that are older then 2 days periodically.
have php that checks video queue, maybe check for filesystem changes too? or just a new one.
when a file exists, php will find the new files in javascript folders and minify them.
when php is done, it will wget the coldfusion cache update to read in the new cache files via a remote cfc call with zIsServer() or zIsDeveloper().

how do i handle updating javascript/css file paths in the meta?  this could be difficult.
ALL CSS AND JAVASCRIPT used ANYWHERE on site, MUST be included on the global HEAD on home page.  for both minify, concat and caching to be efficient and easy.
	minify individual files globally
	then concat for each domain separately.
the skin package system has to have zero output for cache md5 checks to function.  This requires putting all the includeCSS and includeJS inside cfscript without output on sites that are upgraded.
Hunt down all additional javascript used and either A: don't cache those pages or B: cache them with reference to the files that are connected, so the cache can be cleared based on source code updates.
Do I really want the package files in the template? Not really
They should be a special file used by caching system.


cache these as separate files?

<cfif application.zcore.cache.isWidgetCached("myCachePackage") EQ false>
<cfsavecontent variable="theCacheData">
scripts
</cfsavecontent>
<cfscript>
// do I output ssi code here? probably and then I can save this request as static file and serve that file with X-Accel-Redirect
application.zcore.cache.registerWidget("myCachePackage", theCacheData);
</cfscript>
<cfelse>

</cfif>
stylesheets
meta



the <head> tag must be in EVERY published static file because it can change on each one.
compare md5 of current head, header, footer to existing head, header and footer.  If it doesn't exist, make a new one for the current page.

tracking abuse detection needs to be in server scope / at top of application.cfc instead of further in.  this will allow up to thousands of abusive hits per second.

2. test ssi vs no-ssi overhead
3. test cfcache performance on entire page | test ehcache?
4. write function for storing references to data records internally so that changes to that data cause the cache to be expired.
arguments: cacheRef["tableName"]["id"]="cacheExpireUrl";

make sure the storage method for cached content is abstracted into a single CFC so that I don't have to stick with disk cache - it could use memcached later.

functions:
	structnew("weak"): - garbage collects when it needs memory
	
	structnew("linked"): this creates a "linked" structure. This is good for ordered structures. When you loop through the struct, it will return the keys in the order that they were added to the structure.

// estimate 25mb for this data structure across all current sites
// structure for finding urls that must be cleared on database update or delete
ts1=structnew();
ts1[database&"~"&table&"~"&id][urlHash]=true;

// how do i know when to clear cache when ids are ADDED to a page?
firstly, this only matters for widgets like menu, slideshow and custom scripts.

site options are associated with every url sometimes.  it is inefficient to have globals associated with everything.  therefore all site options, site option groups must be SSI includes and cached as separate files IF they are within the main request file.   If they are in the head/foot of the template, I don't need to make SSI includes for them.
they must have unique names when they are cached.  These names need to be set with the registerWidget() function

when a table id is no longer associated with a page, how do I remove the extra url hashs in ts1
// store all data ids indexed by the urlHash
ts2=structnew();
ts2[urlHash][database&"~"&table&"~"&id]=true;

// on content changes to urlHash page, create a difference between current ts2 and new ts2 - remove urlHash from ts1 for the missing ids.

// handling custom data that expires periodically
// listings - all pages with dynamic mls data are stored
ts3[urlHash]=true; - daily after all active status mls data is updated
however mls listing urls don't need to be cleared until their hash changes.
// cache these in a special directory so I can rm -rf the whole structure?

hotstays hotels - monthly after the xml update is complete - it might be faster to delete the entire site's cache instead.  this ensures no permanent pages by mistake.
ts4[urlHash]=true;

manually clear all cache based on which scripts have changed.
ts5[scriptHash][urlHash]=true;

urlHash=hash(url,'SHA');

// insert the sha hashes into a database queue
// in a separate thread, loop every 50 from the queue and delete the static files until it is complete.  the thread doesn't need to join.  this allows faster return to the page for the user.
--->

<cffunction name="init" localmode="modern" access="public" returntype="any">
	<cfscript>
    return;
	var local=structnew();
	var db=request.zos.queryObject;
	var db2=0;
	request.zos.cacheData={
		url:form[request.zos.urlRoutingParameter],
		expiration:10000000000,
		preventEnablingCache:false,
		enabled:false,
		arrTags:[],
		content=""
	}
	request.zos.cacheData.url=form[request.zos.urlRoutingParameter];
	request.zos.cacheData.urlHashValue=hash(request.zos.cacheData.url);
	</cfscript>
	<!--- <cfscript>
	var ts2=structnew();
	var ts=structnew();
	ts.expiration=10000000000;
	request.zos.cacheData=ts;
	ts2.expireTableStruct=structnew();
	db2=request.zos.noVerifyQueryObject;
	 db2.sql="SHOW TABLES LIKE 'url_expiration_%'","zcache");
	 q1=db2.execute("q1");
	</cfscript>
    <cfloop query="q1">
		<cfscript>
		c2=replace(q1["Tables_in_zcache (url_expiration_%)"][q1.currentrow],'url_expiration_','');
        ts2.expireTableStruct[c2]=true;
		ts2.tableIdStruct=structnew();
		ts2.urlStruct=structnew();
        </cfscript>
    </cfloop>
    <cfscript>
	application.zcore.cacheData=ts2;
	</cfscript> --->
</cffunction>

<!--- 

associate every database id that is output with the current url: form[request.zos.urlRoutingParameter]
in a struct:
application.zcore.urlDatabaseCache[form[request.zos.urlRoutingParameter]][database.table.id]=true;
and for the id:
application.zcore.databaseURLCache[database.table.id][form[request.zos.urlRoutingParameter]]=true;
application.zcore.urlContentCache[form[request.zos.urlRoutingParameter]]={
template:,
finalTagContent:{ title:"", meta:"", script:"", content: "" }
}
// hash() of each tag's string, stored as /zstaticcache/tags/hash.html - ssi file stored as /zstaticcache/urls/root/relative/path.html and use nginx try /zstaticcache/urls$url $url;

i should move zstaticcache to secure and route nginx like that to make dreamweaver and others cleaner.

function to clear cache:
// store each tag as a separate html file and use SSI includes to serve the file?

this allows you to delete cache on both sides. --->

<cffunction name="deleteCacheForDatabaseId" localmode="modern" output="no">
	<cfargument name="database" type="string" required="true">
	<cfargument name="table" type="string" required="true">
	<cfargument name="table_id" type="string" required="true">
    not tested<cfscript>application.zcore.functions.zabort();
	var local=structnew();
	key=arguments.database&"."&arguments.table&"."&arguments.table_id;
	// I should use named lock with key in the name here
	if(structkeyexists(application.zcore.cacheData.databaseURLCache, key)){
		for(i in application.zcore.cacheData.databaseURLCache[key]){
			url=application.zcore.cacheData.databaseURLCache[key][i];
			hashPath=getLinkCachePath(request.zos.globals.domain&url);
			application.zcore.functions.zdeletefile('/var/jetendo-server/nginx/cache/'&hashPath);
			//application.zcore.functions.zdeletefile(request.zos.globals.privatehomedir&"_cache/html/urls"&link);
			structdelete(application.zcore.cacheData.URLdatabaseCache[i], key);
		}
		structdelete(application.zcore.cacheData.databaseURLCache, key);
	}
	</cfscript>
</cffunction>

<cffunction name="enableCache" localmode="modern" output="no" access="public" returntype="any">
    <cfscript>
    return;
	if(application.zcore.user.checkGroupAccess("user") EQ false and request.zos.cacheData.preventEnablingCache EQ false){
		request.zos.cacheData.enabled=true;
	}
	</cfscript> 
</cffunction>

<cffunction name="setTemplateContent" localmode="modern" output="no" access="public" returntype="any">
	<cfargument name="content" type="string" required="yes">
    <cfscript>
    return;
	if(request.zos.cacheData.enabled EQ false){
		if(request.zos.cacheData.preventEnablingCache EQ false){
			this.disableCache();
		}
		return;
	}
	// disable ssi includes in the request content to prevent insecure access to other system files when people manually add html in the CMS.
	//request.zos.cacheData.content=replace(arguments.content, '<!--##', '<disabled --##', 'all');
	request.zos.cacheData.content=arguments.content;
	</cfscript>        
</cffunction>

<cffunction name="setTag" localmode="modern" access="public" output="no" returntype="any">
	<cfargument name="name" type="string" required="yes">
	<cfargument name="templateToken" type="string" required="yes">
    <cfargument name="content" type="string" required="yes">
    <cfscript>
    return;
	var local=structnew();
	var hashValue="";
	var arrEcho=[];
	if(request.zos.cacheData.enabled EQ false) return;
	if(len(arguments.content) EQ 0){
		request.zos.cacheData.content=replace(request.zos.cacheData.content, arguments.templateToken, '');
	/*}else if(arguments.name EQ "content"){
		hashValue=request.zos.cacheData.urlHashValue&'-content';
		if(structkeyexists(application.zcore.cacheData.tagHashCache, hashValue) EQ false){
			application.zcore.functions.zwritefile("/var/jetendo-server/nginx/ztemplatecache/"&hashValue&".html", arguments.content);
			application.zcore.cacheData.tagHashCache[hashValue]=true;
		}
		arrayappend(request.zos.cacheData.arrTags, '<!--## include virtual="/ztemplatecache/'&hashValue&'.html" set="'&arguments.name&'" -->');
		request.zos.cacheData.content=replacenocase(request.zos.cacheData.content, arguments.templateToken, '<!--## echo var="'&arguments.name&'" encoding="none" default="" -->');*/
		
	}else{
		//hashValue=hash(arguments.content);
		arguments.content=replace(replace(replace(replace(arguments.content, '\','\\','all'), '$','\$','all'), '"','\"','all'), chr(13),'','all');
		//replace(replace(arguments.content, '\','\\','all'), '$','\$','all')
		//arguments.content='test\\\" a \$ value \with % bad stuff. ya? / !@##\$%^&*()_+-=[]{} ; \" '' ''.,<test>?|~`';
		
		/*varCount=ceiling(len(arguments.content)/250);
		for(i=1;i LTE varCount;i++){
			curContent=mid(arguments.content, ((i-1)*250)+1, min(len(arguments.content),varCount*250));
			arrayappend(request.zos.cacheData.arrTags, '<!--## set var="'&arguments.name&"section"&i&'" value="'&curContent&'" -->');
			arrayappend(arrEcho, '<!--## echo var="'&arguments.name&'" encoding="none" default="" -->');
		}
		request.zos.cacheData.content=replacenocase(request.zos.cacheData.content, arguments.templateToken, arraytolist(arrEcho,""));
		*/
		arrayappend(request.zos.cacheData.arrTags, '<!--## set var="'&arguments.name&'" value="'&arguments.content&'" -->');//&arguments.name&'|'&arguments.content&chr(10)&chr(10));
		request.zos.cacheData.content=replacenocase(request.zos.cacheData.content, arguments.templateToken, '<!--## echo var="'&arguments.name&'" encoding="none" default="" -->');
		/*if(structkeyexists(application.zcore.cacheData.tagHashCache, hashValue) EQ false){
			//application.zcore.functions.zwritefile(request.zos.globals.serverprivatehomedir&"_cache/html/tagcache/"&hashValue&".html", arguments.content);
			application.zcore.functions.zwritefile("/var/jetendo-server/nginx/tagcache/"&hashValue&".html", arguments.content);
			request.zos.cacheData.content=replace(request.zos.cacheData.content, arguments.templateToken, '<!--## include file="/ztagcache/'&hashValue&'.html" -->');
		}else{
			request.zos.cacheData.content=replace(request.zos.cacheData.content, arguments.templateToken, '<!--## include file="/ztagcache/'&hashValue&'.html" -->');
		}*/
		application.zcore.cacheData.tagHashCache[hashValue]=true;
	}
	</cfscript> 
</cffunction>

<cffunction name="disableCache" localmode="modern" output="no" access="public" returntype="any">
    <cfscript>
    return;
	//application.zcore.functions.zcookie({name:'znocache',value:'1',expires='now'});
	//this was live previously: application.zcore.functions.zheader("zdisableproxycache","1");
	request.zos.cacheData.preventEnablingCache=true;
	request.zos.cacheData.enabled=false;
	</cfscript> 
</cffunction>

<!--- <cffunction name="setCurrentURL" localmode="modern" access="public" returntype="any">
	<cfargument name="url" type="string" required="yes">
    <cfscript>
	request.zos.cacheData.url=arguments.url;
	request.zos.cacheData.urlHashValue=hash(arguments.url);
	</cfscript> 
</cffunction> --->

<cffunction name="setDatabaseID" localmode="modern" output="no" access="public" returntype="any">
	<cfargument name="database" type="string" required="true">
	<cfargument name="table" type="string" required="true">
	<cfargument name="table_id" type="string" required="true">
    <cfscript>
    return;
	var key=arguments.database&"."&arguments.table&"."&arguments.table_id;
	if(request.zos.cacheData.enabled EQ false) return;
	application.zcore.cacheData.databaseURLCache[key][request.zos.cacheData.url]=true;
	application.zcore.cacheData.urlDatabaseCache[request.zos.cacheData.url][key]=true;
    </cfscript>
</cffunction>

<cffunction name="setExpiration" localmode="modern" output="no" access="public" returntype="any">
	<cfargument name="seconds" type="numeric" required="yes" hint="Number of seconds until cache expires.">
    <cfscript>
    return;
	request.zos.cacheData.expiration=min(request.zos.cacheData.expiration, arguments.seconds);
	</cfscript>
	<!--- // number of second until cache expires.  Used for http max-age header.  If not used, browser will use if-modified-since to determine if cache is valid.
	// calling this many times in the same request will result in only the shortest value being used.  i.e. mls updates daily, but weather updates hourly, therefore the page will expire hourly.
	 --->
</cffunction>

<cffunction name="storeJsonCache" localmode="modern" output="yes" access="public" returntype="any">
	<cfscript>
    return;
	var hashValue=0;
	if(request.zos.cacheData.enabled EQ false){
		return;
	}else{
		hashValue=request.zos.cacheData.urlHashValue&"-json";
		if(structkeyexists(application.zcore.cacheData.tagHashCache, hashValue) EQ false){
			application.zcore.functions.zwritefile('/var/jetendo-server/nginx/ztemplatecache/'&hashValue&".html", request.zos.cacheData.content);
			application.zcore.cacheData.tagHashCache[hashValue]=true;
		}
		application.zcore.functions.zHeader("Cache-Control",	"max-age="&request.zos.cacheData.expiration);
		application.zcore.functions.zHeader("Pragma",	"public");
		application.zcore.functions.zHeader("Cache-Control",	"public");
		application.zcore.functions.zHeader("Expires",GetHTTPTimeString( dateadd("s", request.zos.cacheData.expiration, request.zos.now)));

		writeoutput(request.zos.cacheData.content);
		application.zcore.functions.zabort();
	}
	// write file to disk - but lets just dump it for now.
	//application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&"_cache/html/urls/"&hash(request.zos.cacheData.url)&".html", request.zos.cacheData.content);
	
	
	</cfscript>
</cffunction>

<cffunction name="storeCache" localmode="modern" output="yes" access="public" returntype="any">
	<cfscript>
    return;
	if(structkeyexists(request.zos, 'cacheData') EQ false or request.zos.cacheData.enabled EQ false){
		return;
	}else{
		request.zos.cacheData.templateHashValue=hash(request.zos.cacheData.content);
		if(structkeyexists(application.zcore.cacheData.tagHashCache, request.zos.cacheData.templateHashValue) EQ false){
			application.zcore.functions.zwritefile('/var/jetendo-server/nginx/ztemplatecache/'&request.zos.cacheData.templateHashValue&".html", request.zos.cacheData.content);
			application.zcore.cacheData.tagHashCache[request.zos.cacheData.templateHashValue]=true;
		}
		application.zcore.functions.zHeader("Cache-Control",	"max-age="&request.zos.cacheData.expiration);
		application.zcore.functions.zHeader("Pragma",	"public");
		application.zcore.functions.zHeader("Cache-Control",	"public");
		application.zcore.functions.zHeader("Expires",GetHTTPTimeString( dateadd("s", request.zos.cacheData.expiration, request.zos.now)));

		writeoutput(arraytolist(request.zos.cacheData.arrTags,chr(10))&chr(10)&'<!--## include virtual="/ztemplatecache/'&request.zos.cacheData.templateHashValue&'.html" wait="yes" -->');
		application.zcore.functions.zabort();
	}
	// write file to disk - but lets just dump it for now.
	//application.zcore.functions.zwritefile(request.zos.globals.privatehomedir&"_cache/html/urls/"&hash(request.zos.cacheData.url)&".html", request.zos.cacheData.content);
	
	
	</cfscript>
</cffunction>



<cffunction name="getLinkCachePath" localmode="modern" access="public">
	<cfargument name="link" type="string" required="yes">
	<cfscript>
    return;
	hashValue=hash(arguments.link);
	hashPath=lcase(right(hashValue, 1)&"/"&mid(hashValue, len(hashValue)-2,2)&"/"&hashValue);
	return hashPath;
	</cfscript>
</cffunction>
<!--- 
set which tables should have "cache tracking" enabled.
site_option tables
image
content
blog tables
rental
slideshow
?

what if i add behavior to db.execute so that all queries are looped for the primary key ids to call application.zcore.cache.setDatabaseID() automatically everywhere.  This would make it easier to determine what data has been output to screen.


Z_USER_ID=1;
proxy_cache_bypass $cookie_Z_USER_ID $cookie_z_user_id $arg_znocache $http_authorization $cookie_znocache $http_zdisableproxycache; # used to force refresh cache with same url.

proxy_cache_path  /var/jetendo-server/nginx/cache levels=1:2 keys_zone=nginxproxycache:1000m;
proxy_cache_valid 200 302 12h;
proxy_cache_valid 404 1m;
proxy_cache_key "$scheme$zfulldomain$request_uri";

# this works, but I disabled until I complete the application changes!
#proxy_cache nginxproxycache;
	
proxy_set_header HTTP_HOST $host;
proxy_set_header REMOTE_ADDR $remote_addr;

#test performance with this:
#proxy_set_header  Accept-Encoding  "";

every record that is output can't have the database ids, unless the cached data also caches the ids along with the html or objects.
on listing sites, the listing results can't be cached more then 1 day anyway. 

http://wiki.nginx.org/HttpSsiModule
http://wiki.nginx.org/HttpProxyModule
Without proxy_cache_valid nginx will only cache responses which
explicitly indicate they may be cached (either with Expires header
in future or with Cache-Control: max-age=).

the proxy cache can manage expiration automatically for me.

proxy_cache_path  /data/nginx/cache/one    levels=1      keys_zone=one:10m;
proxy_cache_path  /data/nginx/cache/two    levels=2:2    keys_zone=two:100m;
proxy_cache_path  /data/nginx/cache/three  levels=1:1:2  keys_zone=three:1000m;

proxy_cache_valid  200 302  10m;
proxy_cache_valid  404      1m;
 --->

	
<!--- <cffunction name="registerWidget" localmode="modern" access="public" returntype="any">
	<cfargument name="widgetInstanceName" type="string" required="yes" hint="unique name across entire domain">
	<cfargument name="widgetData" type="string" required="yes" hint="html or other data to be cached">
    <cfscript>
	// only cache if output outside the request script - like the template or in other components like listing.onRequestStart()
	// need data structure for saving html widget data
    </cfscript>
    
</cffunction>
    
<cffunction name="registerTemplateSection" localmode="modern" access="public" returntype="any">
	<cfargument name="sectionName" type="string" required="yes" hint="header,footer,etc - must be unique across all template and the site">
	<cfargument name="sectionData" type="string" required="yes" hint="html or other data to be cached">
    <cfscript>
	// need data structure for saving html template section
    </cfscript>
    
</cffunction>
    
<cffunction name="storeCache" localmode="modern" access="public" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;
	var local=structnew();
	curExpiration=max(60, request.zos.cacheData.expiration);
	// places all the SSI includes and published a static file.
	</cfscript>
    
    
    <cfif curExpiration NEQ 10000000000>
        <cfscript>
        // store the expiration data if it was set
		cdate=dateformat(now(),'yyyymmdd');
		</cfscript>
        <cfif structkeyexists(application.zcore.cacheData.expireTableStruct, cdate) EQ false>
        	<cfscript> db.sql="CREATE TABLE `zcache`.`url_expiration_#cdate#`( `url_expiration_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT, `url_expiration_hash` VARCHAR(40) NOT NULL, `url_expiration_datetime` DATETIME NOT NULL, `url_expiration_deleted` CHAR(1) NOT NULL DEFAULT '0', PRIMARY KEY (`url_expiration_id`), INDEX `NewIndex1` (`url_expiration_datetime`, `url_expiration_deleted`) )";
			db.execute("q");
			application.zcore.cacheData.expireTableStruct[cdate]=true;
			</cfscript>
        </cfif>
        <cfscript>
        // use server scope to determine if url_expiration_yyyymmdd for the expiration's date exists
        //    if not, create new table and set server scope
        // insert data
		</cfscript>
    </cfif>
</cffunction>


<cffunction name="purgeExpiredCache" localmode="modern" access="public" returntype="any">
	<cfscript>
	var local=structnew();
	todayDate=dateformat(now(),'yyyymmdd');
	nowDate=dateformat(now(),'yyyy-mm-dd')&' '&timeformat(now(),'HH:mm:ss')
	</cfscript>
<!--- 
	// manage deletion of expired cache for data that should automatically refresh.
	// store a presorted data structure with urls that expire in the order that they expire:
	// must store expiration data in the database
	// loop all tables - any that are before today and have been fully processed must be dropped.
	SHOW TABLES LIKE 'url_expiration_%'
	url_expiration_yyyymmdd
		url_expiration_id int 11
		url_expiration_hash varchar 40
		url_expiration_datetime datetime
		url_expiration_deleted char 1
		index on url_expiration_datetime + url_expiration_deleted --->
    <cfscript>
	arrKey=structkeyarray(application.zcore.cacheData.expireTableStruct);
	</cfscript>
    <cfloop from="1" to="#arraylen(arrKey)#" index="i">
        <cfquery name="qs" datasource="zcache">
        select * from url_expiration_#preserveSingleQuotes(arrKey[i])# 
WHERE url_expiration_datetime <= #db.param(nowDate)# LIMIT #db.param(0)#, #db.param(50)#
        </cfquery>
        <cfscript>
		arrId=arraynew(1);
		</cfscript>
        <cfloop query="qs">
            <cfscript>
            // remove from cache
			
            for(i in application.zcore.cacheData.urlStruct[url_expiration_hash]){
                if(structkeyexists(application.zcore.cacheData.tableIdStruct, application.zcore.cacheData.urlStruct[url_expiration_hash][i])){
                    structdelete(application.zcore.cacheData.tableIdStruct[application.zcore.cacheData.urlStruct[url_expiration_hash][i]], url_expiration_hash);
                }
            }
			arrayappend(arrId, url_expiration_id);
            // application.zcore.functions.zdeletefile(the sha1 hash file path);
            </cfscript>
        </cfloop>
        <cfif arrKey[i] LT todayDate and qs.recordcount LT 50>
        	<cfquery name="qd" datasource="zcache">
            DROP TABLE url_expiration_#preserveSingleQuotes(arrKey[i])#
            </cfquery>
        <cfelse>
        	<cfquery name="qu" datasource="zcache">
            update url_expiration_#preserveSingleQuotes(arrKey[i])# SET url_expiration_deleted=#db.param(1)# 
WHERE url_expiration_id IN ('#arraytolist(arrId, "','")#') 
            </cfquery>
        </cfif>
    </cfloop>
</cffunction> --->

</cfcomponent>