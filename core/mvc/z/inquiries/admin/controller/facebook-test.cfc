<cfcomponent>
<cfoutput>
<!--- 
/z/inquiries/admin/facebook-test/status
# load all pages and posts into the database:
/z/inquiries/admin/facebook-test/index
# load more stats for posts into the database:
/z/inquiries/admin/facebook-test/getPostDetails

# process the data downloaded into summaries
/z/inquiries/admin/facebook-test/calculatePageTotals

these tables are done:
	facebook_page_month
	facebook_page
	facebook_post
	facebook_month

 --->
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	form.postsEnabled=application.zcore.functions.zso(form, 'postsEnabled', true, 0);
 	form.fpid=application.zcore.functions.zso(form, 'fpid', true, 0); 

	request.facebook = application.zcore.functions.zcreateobject( 'component', 'zcorerootmapping.mvc.z.inquiries.admin.controller.facebook-api' );
	facebookConfig = request.zos.facebookConfig;
	request.facebook.init( facebookConfig );
	request.debug=false;
	if(request.debug){
		facebookDebug=createObject("component", "zcorerootmapping.facebook-debug");
		request.debugRS=facebookDebug.getDebugResponses();
	}
	</cfscript>
</cffunction>
	<!--- 
<cffunction name="status" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	echo('Status: '&application.zcore.functions.zso(application, 'facebookStatsPageStatus'));
	</cfscript>
</cffunction> --->

<cffunction name="cancelFacebookImport" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	application.cancelFacebookImport=true;
	</cfscript>
	Facebook import cancelled<cfabort>
</cffunction>


<cffunction name="installPageTab" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>

	db=request.zos.queryObject;
	setting requesttimeout="10000";
	init();   
	pageId="133352126736097"; // farbeyondcode page id - https://www.facebook.com/Far-Beyond-Code-LLC-133352126736097/
	 
	// have to get page access_token before we can do changes to the page.
	ts={
		method:'GET',
		link:'/#pageId#?fields=access_token',
		throwOnError:false
	};
	application.facebookImportStatus="Page tabs | API call #ts.link#";
	form.disableFacebookCache=true;
		echo('<p>'&ts.link&'</p>');
	if(request.debug){
		rs2={success:true};//request.debugRS.pageTabs;
	}else{ 
		rs2=request.facebook.sendRequest(ts);
	} 
	structdelete(form, 'disableFacebookCache'); 
	if(rs2.success EQ false){
		echo('<hr><h2>Download failed:'&ts.link&'</h2>');
		writedump(rs2);
		break; 
	}

	pageAccessToken=rs2.response.access_token;   
	
	/*
	// create page tab 
	ts={
		method:'POST',
		link:'/#pageId#/tabs',
		throwOnError:false,
		requestParams:{
			//tab:"app_customTab1",
			app_id:request.zos.facebookConfig.appId, // 		integer		The App ID for custom apps added tabs.
			// custom_image_url: "", // 		URL		URL for an image for this tab app
			access_token:pageAccessToken, 
			custom_name:"Jetendo Tab", // 		string		Custom name for this tab
			//is_non_connection_landing_tab:false, // 	boolean	A flag to identify whether the tab is a custom landing tab for viewers who are not already connected to this Page
			position:1, // integer 	Where this tab is located in the list of tabs
			// only specify when updating a tab
			// tab:"app_"&request.zos.facebookConfig.appId //	string	The Tab key. For default apps which appear on tabs this is a value such as timeline. For custom apps this is app_{app_id}.
		}
	};
	// "Invalid appsecret_proof provided in the API argumen
	application.facebookImportStatus="Page create tab | API call #ts.link#";
	form.disableFacebookCache=true;
		echo('<p>'&ts.link&'</p>');
	if(request.debug){
		rs2={success:true};//request.debugRS.pageTabs;
	}else{ 
		rs2=request.facebook.sendCustomTokenRequest(ts);
	} 
	//writedump(rs2);	abort;
	*/
		/* 
	response:
	{success: true}
	// errors: 
		100	Invalid parameter
		200	Permissions error
		210	User not visible
		*/
 
	// list page tabs
	ts={
		method:'GET',
		link:'/#pageId#/tabs',
		throwOnError:false
	};
	// "Invalid appsecret_proof provided in the API argumen
	application.facebookImportStatus="Page tabs | API call #ts.link#";
	form.disableFacebookCache=true;
		echo('<p>'&ts.link&'</p>');
	if(request.debug){
		rs2={success:true};//request.debugRS.pageTabs;
	}else{ 
		rs2=request.facebook.sendTokenlessRequest(ts);
	} 
	structdelete(form, 'disableFacebookCache'); 
	if(rs2.success EQ false){
		echo('<hr><h2>Download failed:'&ts.link&'</h2>');
		writedump(rs2);
		break; 
	}
	writedump(rs2);
	form.disableFacebookCache=true;
	ts={
		method:'DELETE',
		link:'/#pageId#/tabs/app_#request.zos.facebookConfig.appId#',
		requestParams:{},
		throwOnError:false
	};  
	// "Invalid appsecret_proof provided in the API argumen
	application.facebookImportStatus="Page delete tab | API call #ts.link#";
	form.disableFacebookCache=true;
		echo('<p>'&ts.link&'</p>');
		writedump(ts);
	if(request.debug){
		rs2={success:true};//request.debugRS.pageTabs;
	}else{  
		rs2=request.facebook.sendDeleteRequest(ts);
	} 
	writedump(rs2);
	abort;
	/*
	delete:
	DELETE http request
	/{page_id}/tabs
	tab // Tab key for the custom app to remove.   custom tab app syntax: app_{app_id}

	response:
	{success: true}
	// errors: 
		100	Invalid parameter
		200	Permissions error
	*/ 
	//echo(serializeJson(rs2));abort;
	//writedump(rs2);abort;
 
	abort;
	</cfscript>
</cffunction>

<cffunction name="listFacebookAccounts" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	setting requesttimeout="10000";
	init(); 
	arrAccount=[];
	ts={
		method:'GET',
		link:'/me/accounts',
		throwOnError:true
	} 
	form.disableFacebookCache=true;
	echo('<p>'&ts.link&'</p>');
	if(request.debug){
		rs=request.debugRS.accounts;
	}else{
		rs=request.facebook.sendRequest(ts);
	}
	structdelete(form, 'disableFacebookCache'); 

	for(n2=1;n2<=arraylen(rs.response.data);n2++){
		arrayAppend(arrAccount, rs.response.data[n2]);
	}

	maxRequests=50; // 1250 account limit
	requestCount=1;
	while(true){
		if(structkeyexists(rs.response.paging, 'next')){
			ts.link=rs.response.paging.next;
			form.disableFacebookCache=true;
			echo('<p>'&ts.link&'</p>');
			if(request.debug){
				rs=request.debugRS.accounts;
			}else{
				rs=request.facebook.sendRequest(ts);
			}
			requestCount++;
			structdelete(form, 'disableFacebookCache');
			for(n2=1;n2<=arraylen(rs.response.data);n2++){
				arrayAppend(arrAccount, rs.response.data[n2]);
			}
			if(requestCount EQ maxRequests){
				throw("Hit facebook account limit: 1250");
			}
		}else{
			break;
		}
	}
	echo("<h2>Page Id and Page Name for all accounts</h2>");
	for(page in arrAccount){
		echo('<p>'&page.id&" | "&page.name&"</p>");
	}
	abort;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	setting requesttimeout="10000";
	init();
 	pullEverything=false;
 	if(application.zcore.functions.zso(form, 'pullEverything', true, 0) EQ 1){
 		pullEverything=true;
 	}

	/*
	don't need these anymore i think.
	// PAGE
	pageId = request.zos.facebookConfig.debugPageId;
	videoId = request.zos.facebookConfig.debugVideoId; // has views, reactions, shares
	photoId = request.zos.facebookConfig.debugPhotoId; // has comments & likes
	linkId  = request.zos.facebookConfig.debugLinkId; // has like
	postId  = request.zos.facebookConfig.debugPostId; // has likes
	*/
	//startDate="2016-12-01"; 
	//endDate="2017-01-01"; 
	nowDate=dateformat(now(), "yyyy-mm-dd");


	db.sql="select *, replace(replace(site_short_domain, #db.param("."&request.zos.testDomain)#, #db.param('')#), #db.param('www.')#, #db.param('')#) shortDomain from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_facebook_page_id_list<>#db.param('')# 
	ORDER BY shortDomain ASC"; 
	qSite=db.execute("qSite"); 
	pageStructLookup={};
	for(row in qSite){
		if(row.site_facebook_page_id_list EQ ""){
			continue;
		}
		arrList=listToArray(row.site_facebook_page_id_list, ",");
		for(id in arrList){
			ts={
				startDate:dateformat(row.site_facebook_insights_start_date, "yyyy-mm-01")
			};
			if(ts.startDate EQ ""){
				ts.startDate=dateadd("m", 3, now());
			}
			if(row.site_facebook_last_import_datetime NEQ ""){
				ts.lastImportDate=dateformat(row.site_facebook_last_import_datetime, "yyyy-mm-01");
			}else{
				ts.lastImportDate=ts.startDate;
			}
			pageStructLookup[id]=ts;
		}
	} 
	// each page has its own start date, not each site.  I'd have to figure this out from the site, by pulling all site/pages, or make it possible to attach the data to the page id instead.

	/*
	addBatchRequest // adds to queue
	sendBatchRequests // executes api calls and returns array of response object
	sendRequest // does 1 api call and returns response object
	getAllPages
	getAllPostsByPageId
	getFeedByPageId

	// not needed
	getResponse // just does deserialize on filecontent
	getPageLikes // not needed
	getPageEngagements// not needed
	getPageReach // not needed 
	getPageImpressions // not needed
	*/ 

	stats={
		postInsert:0,
		postUpdate:0,
		pageInsert:0,
		pageUpdate:0,
		pageMonthInsert:0,
		pageMonthUpdate:0
	};
	arrAccount=[];
	// get list of all accounts
	application.facebookImportStatus="API Call: /me/accounts";
	ts={
		method:'GET',
		link:'/me/accounts',
		throwOnError:true
	}
	if(structkeyexists(application, 'cancelFacebookImport')){
		structdelete(application, 'cancelFacebookImport');
		echo('Cancelled');
		abort;
	}
	form.disableFacebookCache=true;
	echo('<p>'&ts.link&'</p>');
	if(request.debug){
		rs=request.debugRS.accounts;
	}else{
		rs=request.facebook.sendRequest(ts);
	}
	for(n2=1;n2<=arraylen(rs.response.data);n2++){
		arrayAppend(arrAccount, rs.response.data[n2]);
	}

	maxRequests=50; // 1250 account limit
	requestCount=1;
	while(true){
		if(structkeyexists(rs.response.paging, 'next')){
			ts.link=rs.response.paging.next;
			form.disableFacebookCache=true;
			echo('<p>'&ts.link&'</p>');
			if(request.debug){
				rs=request.debugRS.accounts;
			}else{
				rs=request.facebook.sendRequest(ts);
			}
			requestCount++;
			structdelete(form, 'disableFacebookCache');
			for(n2=1;n2<=arraylen(rs.response.data);n2++){
				arrayAppend(arrAccount, rs.response.data[n2]);
			}
			if(requestCount EQ maxRequests){
				throw("Hit facebook account limit: 1250");
			}
		}else{
			break;
		}
	}
	structdelete(form, 'disableFacebookCache');
	//echo(serializeJson(rs)); abort;
 
	ageLookup={
		"F.13-17":"Female 13-17",
		"F.18-24":"Female 18-24",
		"F.25-34":"Female 25-34",
		"F.35-44":"Female 35-44",
		"F.45-54":"Female 45-54",
		"F.55-64":"Female 55-64",
		"F.65+":"Female 65+",
		"M.13-17":"Male 13-17",
		"M.18-24":"Male 18-24",
		"M.25-34":"Male 25-34",
		"M.35-44":"Male 35-44",
		"M.45-54":"Male 45-54",
		"M.55-64":"Male 55-64",
		"M.65+":"Male 65+",
		"U.13-17":"Unspecified 13-17",
		"U.18-24":"Unspecified 18-24",
		"U.25-34":"Unspecified 25-34",
		"U.35-44":"Unspecified 35-44",
		"U.45-54":"Unspecified 45-54",
		"U.55-64":"Unspecified 55-64",
		"U.65+":"Unspecified 65+"
	};
 	arrPage=[];
 	postStruct2={};
	dupeFound=0;

	db.sql="select * from #db.table("facebook_page", request.zos.zcoreDatasource)# WHERE ";
	if(form.fpid NEQ "0"){
		db.sql&=" facebook_page_id=#db.param(form.fpid)# and ";
	}
	db.sql&=" 
	facebook_page_deleted=#db.param(0)#";
	qPage=db.execute("qPage");
	pageStruct={};
	for(ps2 in qPage){
		pageStruct[ps2.facebook_page_external_id]=ps2;
	}

	db.sql="select * from #db.table("facebook_post", request.zos.zcoreDatasource)# WHERE ";
	if(form.fpid NEQ "0"){
		db.sql&=" facebook_page_id=#db.param(form.fpid)# and ";
	}
	db.sql&=" facebook_post_deleted=#db.param(0)#";
	qPagePosts=db.execute("qPagePosts");
	postStruct={};
	for(post in qPagePosts){
		postStruct[post.facebook_post_external_id]={facebook_post_id:post.facebook_post_id};
	} 
	for(n2=1;n2<=arraylen(arrAccount);n2++){
		page=arrAccount[n2];
		if(form.fpid NEQ "0"){
			if(structkeyexists(pageStruct, page.id)){ 
				if(pageStruct[page.id].facebook_page_external_id NEQ page.id){
					continue;
				}
			}else{
				continue;
			}
		}  
		ps={
			page:page,
			arrPost:[]
		};
		limitCount=300;
		pageOffset=0;
		echo('<h2>Import Page: #page.name#</h2>');

		if(structkeyexists(pageStructLookup, page.id)){ 
			firstStartDate=pageStructLookup[page.id].startDate;
			startDate=dateformat(dateadd("m", -3, pageStructLookup[page.id].lastImportDate), "yyyy-mm-dd"); 
			if(pullEverything EQ false and datecompare(pageStructLookup[page.id].startDate, startDate) EQ 1){
				startDate=pageStructLookup[page.id].startDate;
			}else{
				startDate=firstStartDate;
			}
			endDate=dateformat(dateadd("d", -1, dateadd("m", 1, startDate)), "yyyy-mm-dd");
		}else{
			// only grab the most recent 3 months
			startDate=dateformat(dateadd("m", -3, now()), "yyyy-mm-")&"01";
			firstStartDate=startDate&" 00:00:00";
			endDate=dateformat(dateadd("d", -1, dateadd("m", 1, startDate)), "yyyy-mm-dd");
		} 
		monthCount=0;
	 	while(true){ 
	 		startDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), startDate);
			endDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), endDate); 
			//application.facebookStatsPageStatus="Processing insights for page: #page.name# (id: #page.id#) at #startDate# to #endDate#";

			// grab page fans and age groups separately on the last day of the month only
			ts={
				method:'GET',
				link:'/#page.id#/insights?metric=page_fans,page_fans_gender_age,page_views_total&period=lifetime&since=' & endDateRemote & '&until=' & endDateRemote,
				throwOnError:false
			};
			application.facebookImportStatus="Page: #page.name# | API call #ts.link# at #startDate# to #endDate#";
				echo('<p>'&ts.link&'</p>');
			if(request.debug){
				rs2=request.debugRS.pageInsights;
			}else{ 
				rs2=request.facebook.sendRequest(ts);
			} 
			if(rs2.success EQ false){
				echo('<hr><h2>Download failed:'&ts.link&'</h2>');
				writedump(rs2);
				break; 
			}
			//writedump(rs2);
 
			//echo(serializeJson(rs2));abort;
			//writedump(rs2);abort;

			pageInfo={
				"pageViewsTotal":0,
				"pageTotalFans":0,
				"pageFanAgeStruct":{},
				"newPagePaidFans":0,
				"newPageUnpaidFans":0,
				"newPageRemoveFanTotal":0,
				"pageViews":0,
				"pageReach":0,
				"pageImpressions":0
			};
			for(i in ageLookup){
				pageInfo.pageFanAgeStruct[ageLookup[i]]=0;
			}
			for(i=1;i<=arraylen(rs2.response.data);i++){
				ds=rs2.response.data[i];
				if(ds.name EQ "page_fans_gender_age"){
					ag=application.zcore.functions.zso(ds.values[arraylen(ds.values)], 'value');
					if(isarray(ag)){
						for(n in ag){
							if(structkeyexists(ageLookup, n)){
								pageInfo.pageFanAgeStruct[ageLookup[n]]=ag[n];
							}else{
								throw("Invalid facebook age group: #n#");
							}
						}
					}
				}else if(ds.name EQ "page_fans"){ 
					pageInfo.pageTotalFans=application.zcore.functions.zso(ds.values[arraylen(ds.values)], 'value', true, 0);
				}else if(ds.name EQ "page_views_total"){
					pageInfo.pageViewsTotal=application.zcore.functions.zso(ds.values[arraylen(ds.values)], 'value', true, 0);
				} 
			}
			//echo(serializeJson(rs2));abort;
			//writedump(rs2);abort;
			//writedump(pageInfo);abort;
			application.facebookImportStatus="Page: #page.name# | API call #ts.link#";
			ts={
				method:'GET',
				link:'/#page.id#/insights?metric=page_fan_adds_by_paid_non_paid_unique,page_fan_removes,page_impressions_unique,page_impressions,page_views_total&period=day&since=' & startDateRemote & '&until=' & endDateRemote,
				throwOnError:false
			};
				echo('<p>'&ts.link&'</p>');
			if(request.debug){
				rs2=request.debugRS.pageInsightsDaily;
			}else{ 
				rs2=request.facebook.sendRequest(ts);
			}  
			if(rs2.success EQ false){
				echo('<hr><h2>Download failed:'&ts.link&'</h2>');
				writedump(rs2);
				break; 
			}
			if(structkeyexists(application, 'cancelFacebookImport')){
				structdelete(application, 'cancelFacebookImport');
				echo('Cancelled');
				abort;
			}
			//writedump(rs2);
			for(i=1;i<=arraylen(rs2.response.data);i++){
				ds=rs2.response.data[i];
				// loop the days
				for(n=1;n<=arraylen(ds.values);n++){
					vs=ds.values[n];
					if(ds.name EQ "page_fan_adds_by_paid_non_paid_unique"){
						if(structkeyexists(vs, 'value')){
							if(structkeyexists(vs.value, 'paid')){
								pageInfo.newPagePaidFans+=vs.value.paid;
							}
							if(structkeyexists(vs.value, 'unpaid')){
								pageInfo.newPageUnpaidFans+=vs.value.unpaid;
							}
						}
					}else if(ds.name EQ "page_fan_removes"){
						pageInfo.newPageRemoveFanTotal+=application.zcore.functions.zso(vs, 'value', true, 0);
					}else if(ds.name EQ "page_views_total"){ 
						pageInfo.pageViews+=application.zcore.functions.zso(vs, 'value', true, 0);
					}else if(ds.name EQ "page_impressions"){
						pageInfo.pageImpressions+=application.zcore.functions.zso(vs, 'value', true, 0);
					}else if(ds.name EQ "page_impressions_unique"){
						pageInfo.pageReach+=application.zcore.functions.zso(vs, 'value', true, 0);
					}
				}
			}
			//writedump(pageStruct);
			//writedump(pageInfo); abort;

			if(not structkeyexists(pageStruct, page.id)){
				ts={
					table:"facebook_page",
					datasource:request.zos.zcoreDatasource,
					struct:{
						facebook_page_external_id:page.id,
						facebook_page_name:page.name,
						facebook_page_created_datetime:firstStartDate, 
						facebook_page_age_json:serializeJSON(pageInfo.pageFanAgeStruct),
						facebook_page_views:pageInfo.pageViewsTotal,
						facebook_page_fans:pageInfo.pageTotalFans, 
						facebook_page_updated_datetime:request.zos.mysqlnow,
						facebook_page_deleted:0
					}
				};
				facebook_page_id=application.zcore.functions.zInsert(ts);
				ts.struct.facebook_page_id=facebook_page_id;
				pageStruct[ts.struct.facebook_page_external_id]=ts.struct;
				stats.pageInsert++; 
				echo('<p>Page inserted: #page.name#</p>');
			}else{
				facebook_page_id=pageStruct[page.id].facebook_page_id; 
				if(datecompare(startDate, nowDate) EQ 0){ // only update on the last loop
					ts={
						table:"facebook_page",
						datasource:request.zos.zcoreDatasource,
						struct:{
							facebook_page_id:facebook_page_id, 
							facebook_page_name:page.name,
							facebook_page_external_id:page.id, 
							facebook_page_age_json:serializeJSON(pageInfo.pageFanAgeStruct),
							facebook_page_views:pageInfo.pageViewsTotal,
							facebook_page_fans:pageInfo.pageTotalFans, 
							facebook_page_updated_datetime:request.zos.mysqlnow,
							facebook_page_deleted:0
						}
					}; 
					r=application.zcore.functions.zUpdate(ts); 
					structappend(pageStruct[ts.struct.facebook_page_external_id], ts.struct, true); 
					echo('<p>Page updated: #page.name#</p>');
					stats.pageUpdate++;
				}
			}  

			db.sql="select * from #db.table("facebook_page_month", request.zos.zcoreDatasource)# WHERE 
			facebook_page_external_id=#db.param(page.id)# and 
			facebook_page_month_datetime=#db.param(dateformat(startDate, "yyyy-mm-dd")&" 00:00:00")# and 
			facebook_page_month_deleted=#db.param(0)#";
			qPageMonth=db.execute("qPageMonth");
			ts={
				table:"facebook_page_month",
				datasource:request.zos.zcoreDatasource,
				struct:{
					facebook_page_external_id:page.id,
					facebook_page_id:facebook_page_id,
					facebook_page_month_datetime:dateformat(startDate, "yyyy-mm-dd")&" 00:00:00", 
					facebook_page_month_paid_likes:pageInfo.newPagePaidFans,
					facebook_page_month_organic_likes:pageInfo.newPageUnpaidFans,
					facebook_page_month_unlikes:pageInfo.newPageRemoveFanTotal,
					facebook_page_month_reach:pageInfo.pageReach,
					facebook_page_month_impressions:pageInfo.pageImpressions,
					facebook_page_month_views:pageInfo.pageViews,
					facebook_page_month_fans:pageInfo.pageTotalFans, 
					facebook_page_month_updated_datetime:request.zos.mysqlnow,
					facebook_page_month_deleted:0
				}
			}; 
			if(qPageMonth.recordcount EQ 0){
				echo('<p>Page month inserted: #page.name# | #startDate#</p>');
				facebook_page_month_id=application.zcore.functions.zInsert(ts);
				stats.pageMonthInsert++;
			}else{ 
				echo('<p>Page month updated: #page.name# | #startDate#</p>');
				ts.struct.facebook_page_month_id=qPageMonth.facebook_page_month_id; 
				application.zcore.functions.zUpdate(ts); 
				stats.pageMonthUpdate++;
			}
 			

			if(form.postsEnabled and monthCount EQ 0){
				// everything but reactions is possible:
				ts={
					method:'GET',
					link:'/#page.id#/posts?fields='&urlencodedformat("id,type,object_id,created_time,updated_time,permalink_url,message,comments.limit(0).summary(total_count),shares"),
					throwOnError:true
				};
				application.facebookImportStatus="Page: #page.name# | #gettickcount()# | API call #ts.link#";
				//application.facebookStatsPageStatus="Processing insights for page posts: #page.name# (id: #page.id#)";
				pageOffset=0;
				while(true){ 
					if(structkeyexists(application, 'cancelFacebookImport')){
						structdelete(application, 'cancelFacebookImport');
						echo('Cancelled');
						abort;
					}
					echo('<p>'&ts.link&'</p>');

					if(request.debug){
						rs2=request.debugRS.pagePosts;
					}else{
						rs2=request.facebook.sendRequest(ts);
					}
					/*
					if(pageOffset NEQ 0){
						writedump(rs2);
						abort;
					}*/
					//echo(serializeJson(rs2));abort;
					//writedump(rs2);abort;
					if(rs2.success){
						//writedump(rs2);
						count=arraylen(rs2.response.data); 
						for(n=1;n<=count;n++){
							post=rs2.response.data[n]; 
							created_time=replace(post.created_time, "T", " "); 
							updated_time=replace(post.updated_time, "T", " "); 
		 					
							ts2={
								table:"facebook_post",
								datasource:request.zos.zcoreDatasource,
								struct:{
									facebook_post_external_id:post.id,
									facebook_post_created_datetime:dateformat(created_time, "yyyy-mm-dd")&" "&timeformat(created_time, "HH:mm:ss"), 
									facebook_post_updated_datetime:request.zos.mysqlnow,
									facebook_post_deleted:0,
									facebook_post_text:application.zcore.functions.zso(post, 'message'),
									facebook_page_id:facebook_page_id,
									facebook_post_type:post.type,
									facebook_post_permalink:post.permalink_url, 
									facebook_post_changed_datetime:dateformat(updated_time, "yyyy-mm-dd")&" "&timeformat(updated_time, "HH:mm:ss"), 
									facebook_post_comments:post.comments.summary.total_count, 
									facebook_post_updated_datetime:request.zos.mysqlnow,
									facebook_post_deleted:0,
									facebook_post_object_id:application.zcore.functions.zso(post, 'object_id'), 
									//facebook_post_shares:0,
									facebook_page_id:facebook_page_id
								}
							}; 
							if(structkeyexists(postStruct2, ts2.struct.facebook_post_external_id)){
								// facebook pagination returns the same posts more then once, seemingly randomly. 
								continue;
								/*echo('Post already processed this request: #ts2.struct.facebook_post_external_id# | #pageOffset#'); 
								dupeFound++;
								if(dupeFound GT 5){
								writedump(form.lastSuccessfulRequestHTTP);
								writedump(rs2);
								abort;
								}*/
							}
							postStruct2[ts2.struct.facebook_post_external_id]=true;
							if(structkeyexists(post, 'shares')){
								ts2.struct.facebook_post_shares=post.shares.count;
							}  
							if(structkeyexists(postStruct, post.id)){
								// update if we get full data?
								ts2.struct.facebook_post_id=postStruct[post.id].facebook_post_id; 
								application.zcore.functions.zUpdate(ts2);
								stats.postUpdate++;
							}else{
								facebook_post_id=application.zcore.functions.zInsert(ts2);
								postStruct[ts2.struct.facebook_post_external_id]={facebook_post_id:facebook_post_id};
								stats.postInsert++;
							}

							arrayAppend(ps.arrPost, ts2);
						} 
						if(count NEQ 0){
							// most efficient way to page through all data according to: https://developers.request.facebook.com/docs/graph-api/using-graph-api/#paging 
							try{
								if(structkeyexists(rs2.response.paging, 'next')){
									//writedump(rs2);
									ts.link=urldecode(rs2.response.paging.next); 
								}else{
									echo('Reached the end at pageOffset: #pageOffset# for page id: #page.id#<br>');
									break;
								} 
							}catch(Any e){
								writedump(e);
								writedump(ts);
								writedump(rs2);
								abort;
							}
						}else{
							break;
						}
					}else{
						break;
					}
					pageOffset++;
					if(request.zos.isTestServer){
						if(pageOffset > 2){
							echo('stopped for fast debug<br>');
							break;
						}
					}

					// TODO: disabled to save time
					//echo('Break on first loop to save time testing.<br>');
					//break;
				}
			}
			arrayAppend(arrPage, ps);
			//writedump(arrPage);	abort;

			if(request.zos.isTestServer and monthCount>3){
				// only download first 3 months on test server
				break;
			}
			monthCount++;

			startDate=dateFormat(dateadd("m", 1, startDate), "yyyy-mm-dd");
			endDate=dateformat(dateadd("m", 1, endDate), "yyyy-mm-dd");
			echo('startDate:'&startDate&'<br>');
			if(datecompare(startDate, nowDate) EQ 1){ 
				break;
			} 
		}
		if(request.zos.isTestServer){
			// only download first account on test server
			echo('Only download first account on test server<br>');
			break;
		}
	}
 	
	writedump(stats);


	calculatePageTotals();
 	/*
 	nothing below
 	writedump(arrPage);
	abort;  
*/ 

/* 
	ts={
		method:'GET',
		link:'/me/accounts'
	}
	request.facebook.addBatchRequest(ts);
	request.facebook.addBatchRequest( 'GET', '/' & pageId & '/insights?metric=page_fans,page_fan_adds_by_paid_non_paid_unique,page_fan_removes,page_views_total&period=day&since=' & startDateRemote & '&until=' & endDateRemote );


	request.facebook.addBatchRequest( 'GET', '/' & pageId & '/posts&since=' & startDateRemote & '&until=' & endDateRemote );
	// /{page-id}/posts
	// /{page-id}/feed

	// POST
	// Get a single post (<page id>_<post id>)

	request.facebook.addBatchRequest( 'GET', '/' & videoId & '?fields=id,type,created_time,updated_time,permalink_url,message,comments.limit(0).summary(total_count),shares,
		reactions.type(LIKE).summary(total_count).limit(0).as(like),
		reactions.type(LOVE).summary(total_count).limit(0).as(love),
		reactions.type(WOW).summary(total_count).limit(0).as(wow),
		reactions.type(HAHA).summary(total_count).limit(0).as(haha),
		reactions.type(SAD).summary(total_count).limit(0).as(sad),
		reactions.type(ANGRY).summary(total_count).limit(0).as(angry)'
	);
	request.facebook.addBatchRequest( 'GET', '/' & videoId & '/insights?metric=post_video_views,post_impressions,post_engaged_users,post_fan_reach' );
	// Each request counts as 1 api call, even when batched
	ts={
		throwOnError:false
	};
	rs = request.facebook.sendBatchRequests(ts); 
*/
	//writedump(structkeyarray(postStruct2));
	//writedump(structkeyarray(postStruct));
	</cfscript>

</cffunction>
<!--- 
make it possible to run data pull for individual clients from interface
getPostDetails

 --->

<cffunction name="getPostDetails" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	init();
	setting requesttimeout="10000";

	offset=0;
	perpage=10;


	stats={
		postUpdate:0,
		postInsert:0, 
		postDelete:0
	};
	echo('<h2>This data is not used for current reporting.</h2>');
	while(true){
		// pull posts from database, and get detailed post info
		db.sql="select * from #db.table("facebook_post", request.zos.zcoreDatasource)# WHERE  ";
		if(form.fpid NEQ "0"){
			db.sql&=" facebook_page_id=#db.param(form.fpid)# and ";
		}
		db.sql&="
		facebook_post_deleted=#db.param(0)# ";

		// testing specific photo post for now: There's a new, delicious, limited time edition to our dessert lineup! Don't miss our new Salted Caramel & Toffee Ice Cream Sandwich. It tastes just as good as it looks, so try one this weekend at your local Stonewood: 
		//db.sql&=" and facebook_post_external_id=#db.param("372283602835584_1513251182072148")# ";

		db.sql&=" LIMIT #db.param(offset)#, #db.param(perpage)#";
		qPost=db.execute("qPost");
		//writedump(qpost);
		offset+=perpage;
		if(qPost.recordcount EQ 0){
			break;
		}

		for(row in qPost){ 
			if(true or row.facebook_post_reactions EQ 0){
				ts={
					method:"GET",
					link:'/' & row.facebook_post_external_id & '?fields='&urlencodedformat("id,updated_time,comments.limit(0).summary(total_count),shares,"& 
					"reactions.type(LIKE).summary(total_count).limit(0).as(like),"&
					"reactions.type(LOVE).summary(total_count).limit(0).as(love),"&
					"reactions.type(WOW).summary(total_count).limit(0).as(wow),"&
					"reactions.type(HAHA).summary(total_count).limit(0).as(haha),"&
					"reactions.type(SAD).summary(total_count).limit(0).as(sad),"&
					"reactions.type(ANGRY).summary(total_count).limit(0).as(angry)")
				};
				application.facebookImportStatus="Post API call #ts.link#";
				if(structkeyexists(application, 'cancelFacebookImport')){
					structdelete(application, 'cancelFacebookImport');
					echo('Cancelled');
					abort;
				}
				echo('<p>'&ts.link&'</p>');
				if(request.debug){
					rs2=request.debugRS.postDetails;
				}else{ 
					rs2=request.facebook.sendRequest(ts);
				} 
				ds=rs2.response;
				//echo(serializeJson(rs2));abort;
				//writedump(rs2);abort;

				// if post didn't exist, delete from facebook_post - i.e. someone deleted it from facebook permanently.
				 
				if(not structkeyexists(ds, 'like')){
					db.sql="delete from #db.table("facebook_post", request.zos.zcoreDatasource)# WHERE 
					facebook_post_id =#db.param(row.facebook_post_id)# and 
					facebook_post_deleted=#db.param(0)#";
					db.execute("qDelete"); 
					stats.postDelete++;
					continue;
				}

				updated_time=replace(ds.updated_time, "T", " "); 

				reactions=0;
				reactions+=ds.like.summary.total_count;
				reactions+=ds.love.summary.total_count;
				reactions+=ds.wow.summary.total_count;
				reactions+=ds.haha.summary.total_count;
				reactions+=ds.sad.summary.total_count;
				reactions+=ds.angry.summary.total_count; 

				ts={
					table:"facebook_post",
					datasource:request.zos.zcoreDatasource,
					struct:{
						facebook_post_id:row.facebook_post_id, 
						facebook_post_changed_datetime:dateformat(updated_time, "yyyy-mm-dd")&" "&timeformat(updated_time, "HH:mm:ss"),
						facebook_post_reactions:reactions,
						facebook_post_comments:ds.comments.summary.total_count, 
						facebook_post_updated_datetime:request.zos.mysqlnow,
						facebook_post_deleted:0
					}
				};
				if(structkeyexists(ds, 'shares')){
					ts.struct.facebook_post_shares=ds.shares.count;
				}
			}else{
				ts={
					table:"facebook_post",
					datasource:request.zos.zcoreDatasource,
					struct:{
						facebook_post_id:row.facebook_post_id,
						facebook_post_external_id:row.facebook_post_external_id,
						facebook_post_updated_datetime:request.zos.mysqlnow,
						facebook_post_deleted:0,
					}
				};  
			}  
			/*
			post_fan_reach // how many fans saw the post
			post_engaged_fan // this is fan creating story
			post_engaged_users // this is clicks that create story
			post_consumptions // this is clicks
			post_impressions // impressions
			post_impressions_unique // reach
			post_stories // total of write operations related to a post that users did
				checkin				Page checkins
				coupon				offer claims
				event				RSVPing to event
				fan				Page likes
				mention				Page mentions
				page post				posts by a Page
				question				question answers
				user post				posts by people on a Page
				other				other
			post_consumptions_by_type // only way to get link clicks and video plays
	            "video play": 2305,
	            "other clicks": 4774,
	            "photo view": 58,
	            "link clicks": 232
			*/
			// post clicks and others come from insight api instead - consumption was measured on page, is it measured on post too?
			ts2={
				method:"GET",
				link:'/' & row.facebook_post_external_id & '/insights?metric='&urlencodedformat("post_stories,post_video_views,post_negative_feedback,post_consumptions,post_consumptions_by_type,post_impressions,post_impressions_unique,post_engaged_users,post_engaged_fan,post_fan_reach")&'&period=lifetime'
			}; 
			application.facebookImportStatus="Post API call #ts2.link#";

			if(structkeyexists(application, 'cancelFacebookImport')){
				structdelete(application, 'cancelFacebookImport');
				echo('Cancelled');
				abort;
			}
			//echo('<p>'&ts2.link&'</p>');
			//writedump(rs2); 
			// post_engaged_users-post_engaged_fan reveals how many non-fans engaged
			if(request.debug){
				rs2=request.debugRS.postInsights;
			}else{ 
				rs2=request.facebook.sendRequest(ts2); 
			}
			//echo(serializeJson(rs2));abort;
			//echo('second request:');
			ds=rs2.response.data;
			ts2={};

			for(n=1;n<=arraylen(ds);n++){
				vs=ds[n];
				if(vs.name EQ "post_consumptions_by_type"){
			        ts.struct.facebook_post_video_play=application.zcore.functions.zso(vs.values[1].value, "video play", true, 0);
			        ts.struct.facebook_post_photo_view=application.zcore.functions.zso(vs.values[1].value, "photo view", true, 0);
			        ts.struct.facebook_post_link_click=application.zcore.functions.zso(vs.values[1].value, "link clicks", true, 0);
			        ts.struct.facebook_post_other_click=application.zcore.functions.zso(vs.values[1].value, "other click", true, 0); 
				}else if(vs.name EQ "post_consumptions"){
					ts.struct.facebook_post_consumptions=application.zcore.functions.zso(vs.values[1], 'value', true, 0); 
				}else if(vs.name EQ "post_engaged_fan"){
					ts.struct.facebook_post_engaged_fan=application.zcore.functions.zso(vs.values[1], 'value', true, 0);
				}else if(vs.name EQ "post_engaged_users"){
					ts.struct.facebook_post_engaged_users=application.zcore.functions.zso(vs.values[1], 'value', true, 0);
				}else if(vs.name EQ "page_negative_feedback"){
					ts.struct.facebook_post_negative_feedback=application.zcore.functions.zso(vs.values[1], 'value', true, 0);
				}else if(vs.name EQ "post_stories"){
					ts.struct.facebook_post_stories=application.zcore.functions.zso(vs.values[1], 'value', true, 0);
				}else if(vs.name EQ "post_video_views"){
					ts.struct.facebook_post_video_views=application.zcore.functions.zso(vs.values[1], 'value', true, 0);
				}else if(vs.name EQ "post_impressions_unique"){
					ts.struct.facebook_post_reach=application.zcore.functions.zso(vs.values[1], 'value', true, 0); 
				}else if(vs.name EQ "post_fan_reach"){
					ts.struct.facebook_post_fan_reach=application.zcore.functions.zso(vs.values[1], 'value', true, 0);
				}else if(vs.name EQ "post_impressions"){
					ts.struct.facebook_post_impressions=application.zcore.functions.zso(vs.values[1], 'value', true, 0);
				}
			}  
			//writedump(rs2);
			//writedump(ts);//abort;
			//abort; 
			stats.postUpdate++;
			application.zcore.functions.zUpdate(ts);
			/*
			db.sql="select * from #db.table("facebook_page", request.zos.zcoreDatasource)# WHERE 
			facebook_page_external_id=#db.param(page.id)# and 
			facebook_page_deleted=#db.param(0)#";
			qPage=db.execute("qPage");
			if(qPage.recordcount EQ 0){

			}*/
			if(request.zos.isTestServer){
				break;
			}
		}
	}
	echo('done');
	writedump(stats);
	abort;
	</cfscript>

</cffunction>


<!--- 
problem: only current month is inserting to page_month and month tables 

seems like i should make facebook_page_month update separate from import to make it easier to debug

 --->

<cffunction name="calculatePageTotals" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	init();
	setting requesttimeout="10000";
	db.sql="select * from #db.table("facebook_page", request.zos.zcoreDatasource)# WHERE  
	facebook_page_deleted=#db.param(0)#";
	qPage=db.execute("qPage");

	stats={
		monthUpdate:0,
		monthInsert:0,
		pageMonthUpdate:0,

	}

	//application.zcore.functions.z404("this is not fully implemented yet - there are wrong data structures, but correct data.  trying to find more efficient loop");
	pageIdLookup={};
	pageMonthStruct={};
	monthPageStruct={};
	for(page in qPage){
		pageIdLookup[page.facebook_page_external_id]=page.facebook_page_id;
		// get all the posts for this page
		/*
		db.sql="select * from #db.table("facebook_post", request.zos.zcoreDatasource)# WHERE  
		facebook_page_id=#db.param(page.facebook_page_id)# and 
		facebook_post_deleted=#db.param(0)#";
		qPost=db.execute("qPost");
		*/
		postStruct={};
		//monthStruct={};

		// get all the months for this page
		db.sql="select * from #db.table("facebook_page_month", request.zos.zcoreDatasource)# WHERE 
		facebook_page_id=#db.param(page.facebook_page_id)# and 
		facebook_page_month_deleted=#db.param(0)#";
		qPageMonth=db.execute("qPageMonth");  
		if(qPageMonth.recordcount EQ 0){
			continue;
		}

		// cache all of the records by month in a struct
		for(pageMonth in qPageMonth){
			firstDayOfMonth=dateformat(pageMonth.facebook_page_month_datetime, "yyyy-mm-01");
			if(not structkeyexists(monthPageStruct, firstDayOfMonth)){
				//monthStruct[firstDayOfMonth]={};
				monthPageStruct[firstDayOfMonth]={};
			}
			monthPageStruct[firstDayOfMonth][page.facebook_page_id]=pageMonth;
		}

		/*
		// cache all of the posts into the month struct
		for(post in qPost){
			firstDayOfMonth=dateformat(post.facebook_post_created_datetime, "yyyy-mm-01");
			if(not structkeyexists(monthPageStruct, firstDayOfMonth) or not structkeyexists(monthPageStruct[firstDayOfMonth], post.facebook_page_id)){
				continue;
			}
			if(not structkeyexists(monthStruct, firstDayOfMonth)){
				monthStruct[firstDayOfMonth]={}; 
			}
			monthStruct[firstDayOfMonth][post.facebook_post_external_id]=post;
		}*/
		//writedump(structkeyarray(monthPageStruct));
		//writedump(structkeyarray(monthStruct));

		/*
  
		// reach is added to the month the post was created in. if a post has impressions after the end of the month, those will count on the current month only.
		for(m in monthPageStruct){
			application.facebookImportStatus="Update page: #page.facebook_page_name# for month: #m#";
			monthReach=0; 
			if(not structkeyexists(monthStruct, m)){ 
				continue; // no posts this month, skip it
			}
			for(postId in monthStruct[m]){
				post=monthStruct[m][postId]; 
				monthReach+=post.facebook_post_reach; 
			}
			db.sql="update #db.table("facebook_page_month", request.zos.zcoreDatasource)# 
			SET 
			facebook_page_month_reach=#db.param(monthReach)#,
			facebook_page_month_updated_datetime=#db.param(request.zos.mysqlnow)# 
			WHERE 
			facebook_page_month_id=#db.param(monthPageStruct[m][post.facebook_page_id].facebook_page_month_id)# and 
			facebook_page_month_deleted=#db.param(0)#";
			db.execute("qUpdateMonth"); 
			monthPageStruct[m][post.facebook_page_id].facebook_page_month_reach=monthReach;
			stats.pageMonthUpdate++;
		}  */
	}



	db.sql="select *, replace(replace(site_short_domain, #db.param("."&request.zos.testDomain)#, #db.param('')#), #db.param('www.')#, #db.param('')#) shortDomain from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_facebook_page_id_list<>#db.param('')# 
	ORDER BY shortDomain ASC"; 
	qSite=db.execute("qSite"); 
	for(ss in qSite){
		//echo(ss.site_domain&"<br>");
		arrList=listToArray(ss.site_facebook_page_id_list, ",");

		// get all of the existing months for this site
		db.sql="SELECT facebook_month_id, facebook_month_datetime FROM #db.table("facebook_month", request.zos.zcoreDatasource)# WHERE 
		site_id=#db.param(ss.site_id)# and 
		facebook_month_deleted=#db.param(0)#";
		qMonth=db.execute("qMonth");
		monthLookup={};
		for(ms in qMonth){
			monthLookup[dateformat(ms.facebook_month_datetime, "yyyy-mm-dd")]=ms.facebook_month_id;
		}

		// loop each month 
		for(m in monthPageStruct){
			ts={
				table:"facebook_month",
				datasource:request.zos.zcoreDatasource,
				struct:{
					site_id:ss.site_id,
					facebook_month_datetime:m,
					facebook_month_paid_likes:0,
					facebook_month_organic_likes:0,
					facebook_month_unlikes:0,
					facebook_month_reach:0,
					facebook_month_views:0,
					facebook_month_fans:0, 
					facebook_month_updated_datetime:request.zos.mysqlnow,
					facebook_month_deleted:0
				}
			};

			// this is to allow totalling multiple facebook pages per site
			// loop each page id
			for(i=1;i<=arraylen(arrList);i++){
				facebook_page_external_id=arrList[i];
				if(structkeyexists(pageIdLookup, facebook_page_external_id)){
					pageId=pageIdLookup[facebook_page_external_id];
					//echo('trying to find page:'&pageId&' | #m#<br>');
					if(structkeyexists(monthPageStruct[m], pageId)){
						//echo('Found page: #facebook_page_external_id# | #m#<br>');
						ms=monthPageStruct[m][pageId];
						// add the page month data to the site month fields
						ts.struct.facebook_month_paid_likes+=ms.facebook_page_month_paid_likes;
						ts.struct.facebook_month_organic_likes+=ms.facebook_page_month_organic_likes;
						ts.struct.facebook_month_unlikes+=ms.facebook_page_month_unlikes;
						ts.struct.facebook_month_reach+=ms.facebook_page_month_reach; 
						ts.struct.facebook_month_views+=ms.facebook_page_month_views; 
						ts.struct.facebook_month_fans+=ms.facebook_page_month_fans; 
					}
				} 
				if(structkeyexists(monthLookup, m)){
					ts.struct.facebook_month_id=monthLookup[m];
					stats.monthUpdate++;
					application.zcore.functions.zUpdate(ts);
				}else{
					application.zcore.functions.zInsert(ts);
					stats.monthInsert++;
				}
			}
		}


		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET
		site_facebook_last_import_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id=#db.param(ss.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate"); 
	}
	//		writedump(monthPageStruct);

	echo('<h2>Facebook calculations completed</h2>');
	writedump(stats);
	</cfscript>

</cffunction>

</cfoutput>
</cfcomponent>
