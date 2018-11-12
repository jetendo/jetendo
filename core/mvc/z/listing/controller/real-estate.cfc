<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
	<cfscript>
	if(not application.zcore.app.siteHasApp("listing")){
		application.zcore.functions.z404("Site doesn't have listing app");
	}
request.zos.currentURLISAListingPage=true;
	var theMeta=0;
	var primaryCityId=0;
	var perpage=0;
	var returnStruct=0;
	var propertyHTML=0;
	var qC=0;
	var c=0;
	var perpageDefault=0;
	var tempPageNav=0;
	var qD=0;
	var propertyDataCom=0;
	var r1=0;
	var curUrlName=0;
	var qD3=0;
	var searchStruct=0;
	var qD4=0;
	var qD2=0;
	var ts=0;
	var inquiryTextMissing=0;
	var currentUrl=0;
	var arrUrlIdList=0;
	var zURLIdList=0;
	var distanceRadius=0;
	var propDisplayCom=0;
	var db=request.zos.queryObject;

	application.zcore.functions.zNoCache();
	
	if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1){
		application.zcore.functions.z404("Detail indexing is disabled, so this feature is intentionally set to 404.");	
	}
	// force url parameters to exist.
	form.city_id=application.zcore.functions.zso(form, 'city_id');
	if(form.city_id NEQ "" and isnumeric(form.city_id) EQ false){
		application.zcore.functions.z301redirect('/');	
	}
	form.listing_type_id=application.zcore.functions.zso(form, 'listing_type_id');
	form.listing_sub_type_id=application.zcore.functions.zso(form, 'listing_sub_type_id');
	if(structkeyexists(form, 'zIndex') and isNumeric(application.zcore.functions.zso(form, 'zIndex')) EQ false){
		application.zcore.functions.z301redirect('/');	
	}
	form.zIndex=Max(1,application.zcore.functions.zso(form, 'zIndex',false,1));
	zURLIdList=application.zcore.functions.zso(form, 'zURLIdList');
	arrUrlIdList=listtoarray(zURLIdList,"_");
	if(arraylen(arrUrlIdList) GTE 1){
		form.city_id=arrUrlIdList[1];	
	}
	if(arraylen(arrUrlIdList) GTE 2){
		form.listing_type_id=arrUrlIdList[2];	
	}
	if(arraylen(arrUrlIdList) GTE 3){
		form.listing_sub_type_id=arrUrlIdList[3];	
	}
	</cfscript>
<cfsavecontent variable="theMeta"><meta name="robots" content="noindex, follow" /></cfsavecontent>
<cfscript>
application.zcore.template.prependTag("meta", theMeta);
</cfscript>
<div style="font-size:18px; line-height:24px; font-weight:bold; text-align:center; "><a href="#request.zos.listing.functions.getSearchFormLink()#">Please click here to begin your real estate search</a><hr /><span style="font-size:13px;">The following is an index of all the listings on our site and you really should click the easier to use search link above.</span></div>

<cfscript>
db.sql="select * from #db.table("mls_option", request.zos.zcoreDatasource)# mls_option 
where site_id=#db.param(request.zos.globals.id)# and 
mls_option_deleted = #db.param(0)#";
qC=db.execute("qC"); 
if(dateformat(qc.mls_option_site_map_update_datetime,'yyyymmdd') LT dateformat(now(),'yyyymmdd')){
	// increment and update DB
	distanceRadius=min(100,max(0,qC.mls_option_site_map_radius)+qC.mls_option_site_map_growth_rate);
	nowDate=request.zos.mysqlnow;
	db.sql="update #db.table("mls_option", request.zos.zcoreDatasource)# mls_option 
	SET mls_option_site_map_radius=#db.param(distanceRadius)#, 
	mls_option_site_map_update_datetime=#db.param(nowDate)# 
	where site_id=#db.param(request.zos.globals.id)# and 
	mls_option_deleted = #db.param(0)#";
	db.execute("q"); 
}else{
	distanceRadius=max(0,qC.mls_option_site_map_radius);
}
//primaryCityId=250;
if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_primary_city NEQ 0){
	primaryCityId=application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_primary_city;
}else{
	primaryCityId=application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_primary_city_id;
}
</cfscript>
<span style="line-height:24px;">
<cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_site_map_url_id') and application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id NEQ 0>
<cfif form.listing_sub_type_id NEQ "" and form.listing_type_id NEQ "" and form.city_id NEQ "">
     <cfsavecontent variable="db.sql">
     SELECT city_name, city.city_id, COUNT(listing.listing_id) c 
	 FROM #db.table("listing_memory", request.zos.zcoreDatasource)# listing, 
	 #db.table("city_memory", request.zos.zcoreDatasource)# city  
	 WHERE  
	 listing_deleted = #db.param(0)# and 
	 city_deleted = #db.param(0)# and 
   	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))#
       and city_id NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#) 
        AND city.city_id=listing.listing_city and 
		listing.listing_liststatus=#db.param('1,4,7,16')#
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
	and city_id = #db.param(form.city_id)# 
	<cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereSQL)# </cfif>
     GROUP BY listing_city ORDER BY c DESC
     </cfsavecontent>
	<cfscript>
    qD3=db.execute("qD3");
    
	 if(qD3.recordcount EQ 0){
		 application.zcore.functions.z301redirect('/z/listing/real-estate/index');
	 }
	 </cfscript>
     <cfsavecontent variable="db.sql">
	SELECT listing_lookup_value,listing_type_id, COUNT(listing.listing_id) c 
	FROM (#db.table("listing_memory", request.zos.zcoreDatasource)# listing, 
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup , 
	#db.table("listing_track", request.zos.zcoreDatasource)# listing_track)  
	WHERE  listing_track.listing_id = listing.listing_id  and   
	listing_deleted = #db.param(0)# and 
	listing_lookup_deleted = #db.param(0)# and 
	listing_track_deleted = #db.param(0)# and 
	   listing_track.listing_track_inactive=#db.param('0')# and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))#
       and listing_city NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#) 
        and listing_lookup_type=#db.param('listing_type')# AND 
		listing_lookup_id= listing_type_id AND 
		listing_city=#db.param(form.city_id)#  and 
		listing.listing_liststatus=#db.param('1,4,7,16')#
     and listing_lookup_id = #db.param(form.listing_type_id)# 
    <cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereSQL)# </cfif>
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif> 
	GROUP BY listing_type_id ORDER BY c DESC
    </cfsavecontent>
	<cfscript>
    qD2=db.execute("qD2");
    
	 if(qD2.recordcount EQ 0){
		 application.zcore.functions.z301redirect('/z/listing/real-estate/index?city_id=#form.city_id#');
	 }
	 </cfscript>
     <cfsavecontent variable="db.sql">
	SELECT listing_lookup_value,listing_sub_type_id, COUNT(distinct listing.listing_id) c 
	FROM (#db.table("listing_memory", request.zos.zcoreDatasource)# listing,  
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup , 
	#db.table("listing_track", request.zos.zcoreDatasource)# listing_track)  
	WHERE  listing_track.listing_id = listing.listing_id  and 
	listing_deleted = #db.param(0)# and 
	listing_lookup_deleted = #db.param(0)# and 
	listing_track_deleted = #db.param(0)# and 
	   listing_track.listing_track_inactive=#db.param('0')# and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))#
	and listing_city NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#)  and 
	listing.listing_liststatus=#db.param('1,4,7,16')#
	and listing_lookup_type=#db.param('listing_sub_type')# AND 
	listing_lookup_id= listing_sub_type_id AND 
	listing_type_id=#db.param(form.listing_type_id)# and 
	listing_city=#db.param(form.city_id)# and 
	listing_lookup_id = #db.param(form.listing_sub_type_id)# 
    <cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereSQL)# </cfif>
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif> 
	GROUP BY listing_sub_type_id ORDER BY c DESC
    </cfsavecontent>
	<cfscript>
	qD4=db.execute("qD4");
	
	 if(qD4.recordcount EQ 0){
		 application.zcore.functions.z301redirect('/z/listing/real-estate/index?city_id=#form.city_id#&listing_type_id=#form.listing_type_id#');
	 }
	 </cfscript>
    <cfsavecontent variable="tempPageNav">
    <a href="/">#request.zos.globals.homelinktext#</a> / <a href="/Real-Estate-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-.html">Real Estate</a> / <a href="/#application.zcore.functions.zUrlEncode(qD3.city_name&' Real Estate','-')#-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-#form.city_id#.html">#qD3.city_name# Real Estate</a> /  <a href="/#application.zcore.functions.zUrlEncode(qD3.city_name&' '&qD2.listing_lookup_value,'-')#-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-#form.city_id#_#form.listing_type_id#.html">#qD3.city_name# #qD2.listing_lookup_value#</a> / 
    </cfsavecontent>
    <cfscript>
    application.zcore.template.setTag("title",'#qD3.city_name# #qD2.listing_lookup_value# #qD4.listing_lookup_value#');
    application.zcore.template.setTag("pagetitle",'#qD3.city_name# #qD2.listing_lookup_value# #qD4.listing_lookup_value#');
    application.zcore.template.setTag("pagenav",tempPageNav);
	
	curUrlName=application.zcore.functions.zUrlEncode(qD3.city_name&' '&qD2.listing_lookup_value&' '&qD4.listing_lookup_value,"-");
	currentUrl="/#curUrlName#-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-#form.city_id#_#form.listing_type_id#_#form.listing_sub_type_id#.html";
	if(structkeyexists(form, 'zurlname') and compare(form.zURLName, curUrlName) NEQ 0){
		application.zcore.functions.z301Redirect(currentUrl);
	}
	
    </cfscript>				
    
    
<cfelseif form.listing_type_id NEQ "" and form.city_id NEQ "">
     <cfsavecontent variable="db.sql">
     SELECT city_name, city.city_id, COUNT(listing.listing_id) c 
	 FROM #db.table("listing_memory", request.zos.zcoreDatasource)# listing,
	 #db.table("city_memory", request.zos.zcoreDatasource)# city  WHERE  
	 listing_deleted = #db.param(0)# and 
	 city_deleted = #db.param(0)# and 
   #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))#
       and city_id NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#) 
        AND city.city_id=listing.listing_city  and 
		listing.listing_liststatus=#db.param('1,4,7,16')#
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
	and city_id = #db.param(form.city_id)# 
	<cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereSQL)# </cfif>
     GROUP BY listing_city ORDER BY c DESC
     </cfsavecontent>
	<cfscript>
	qD3=db.execute("qD3");
	
	 if(qD3.recordcount EQ 0){
		 application.zcore.functions.z301redirect('/z/listing/real-estate/index');
	 }
	 </cfscript>
     <cfsavecontent variable="db.sql">
	SELECT listing_lookup_value,listing_type_id, COUNT(listing.listing_id) c 
	FROM (#db.table("listing_memory", request.zos.zcoreDatasource)# listing, 
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup , 
	#db.table("listing_track", request.zos.zcoreDatasource)# listing_track)  
	WHERE  listing_track.listing_id = listing.listing_id  and   
	listing_deleted = #db.param(0)# and 
	listing_lookup_deleted = #db.param(0)# and 
	listing_track_deleted = #db.param(0)# and 
	   listing_track.listing_track_inactive=#db.param('0')# and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
	listing.listing_liststatus=#db.param('1,4,7,16')#
	and listing_city NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#) 
	and listing_lookup_type=#db.param('listing_type')# AND 
	listing_lookup_id= listing_type_id AND 
	listing_city=#db.param(form.city_id)# 
     and listing_lookup_id = #db.param(form.listing_type_id)# 
    <cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereSQL)# </cfif>
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif> 
	GROUP BY listing_type_id ORDER BY c DESC
    </cfsavecontent>
<cfscript>
qD2=db.execute("qD2");

	 if(qD2.recordcount EQ 0){
		 application.zcore.functions.z301redirect('/z/listing/real-estate/index?city_id=#form.city_id#');
	 }
	 </cfscript>
     
     <cfsavecontent variable="db.sql">
	SELECT listing_lookup_value,listing_sub_type_id, COUNT(distinct listing.listing_id) c 
	FROM #db.table("listing_memory", request.zos.zcoreDatasource)# listing,  
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup , 
	#db.table("listing_track", request.zos.zcoreDatasource)# listing_track  
	WHERE  listing_track.listing_id = listing.listing_id  and 
	listing_deleted = #db.param(0)# and 
	listing_lookup_deleted = #db.param(0)# and 
	listing_track_deleted = #db.param(0)# and 
	   listing_track.listing_track_inactive=#db.param('0')# and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
	listing.listing_liststatus=#db.param('1,4,7,16')#
	and listing_city NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#) 
	and listing_lookup_type=#db.param('listing_sub_type' )# AND 
	listing_lookup_id= listing_sub_type_id AND 
	listing_type_id=#db.param(form.listing_type_id)# and 
	listing_city=#db.param(form.city_id)#
    <cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereSQL)# </cfif>
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif> 
	GROUP BY listing_sub_type_id ORDER BY c DESC
    </cfsavecontent>
<cfscript>
qD=db.execute("qD");

</cfscript>
    <cfloop query="qD">
    <a href="/#application.zcore.functions.zURLEncode(qD3.city_name&' '&qD2.listing_lookup_value&' '&qD.listing_lookup_value,'-')#-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-#form.city_id#_#form.listing_type_id#_#qD.listing_sub_type_id#.html">#qD3.city_name# #qD2.listing_lookup_value# #qD.listing_lookup_value#</a> (#qD.c#)<br />
    </cfloop>
    <cfsavecontent variable="tempPageNav">
    <a href="/">#request.zos.globals.homelinktext#</a> / <a href="/Real-Estate-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-.html">Real Estate</a> / <a href="/#application.zcore.functions.zUrlEncode(qD3.city_name&' Real Estate','-')#-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-#form.city_id#.html">#qD3.city_name# Real Estate</a> / 
    </cfsavecontent>
    <cfscript>
    application.zcore.template.setTag("title",'#qD3.city_name# #qD2.listing_lookup_value#');
    application.zcore.template.setTag("pagetitle",'#qD3.city_name# #qD2.listing_lookup_value#');
    application.zcore.template.setTag("pagenav",tempPageNav);
	
	
	curUrlName=application.zcore.functions.zUrlEncode(qD3.city_name&' '&qD2.listing_lookup_value,"-");
	currentUrl="/#curUrlName#-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-#form.city_id#_#form.listing_type_id#.html";
	if(structkeyexists(form, 'zurlname') and compare(form.zURLName, curUrlName) NEQ 0){
		application.zcore.functions.z301Redirect(currentUrl);
	}
    </cfscript>
    
<cfelseif form.city_id NEQ "">
     <cfsavecontent variable="db.sql">
	 SELECT city_name, city.city_id, COUNT(listing.listing_id) c FROM 
	 #db.table("listing_memory", request.zos.zcoreDatasource)# listing, 
	 #db.table("city_memory", request.zos.zcoreDatasource)# city  WHERE  
	 city_deleted = #db.param(0)# and 
	 listing_deleted = #db.param(0)# and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
	listing.listing_liststatus=#db.param('1,4,7,16')#
	and city_id NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#) 
	AND city.city_id=listing.listing_city 
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> 
		and listing_status LIKE #db.param('%,7,%')# 
	</cfif>
	and city_id = #db.param(form.city_id)# 
	<cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereSQL')> 
		#db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereSQL)# 
	</cfif>
     GROUP BY listing_city 
	 ORDER BY c DESC
     </cfsavecontent>
	<cfscript>
	qD3=db.execute("qD3");
	 if(qD3.recordcount EQ 0){
		 application.zcore.functions.z301redirect('/z/listing/real-estate/index');
	 }
	 </cfscript>
     <cfsavecontent variable="db.sql">
	SELECT listing_lookup_value,listing_type_id, COUNT(listing.listing_id) c 
	FROM #db.table("listing_memory", request.zos.zcoreDatasource)# listing, 
	#db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup , 
	#db.table("listing_track", request.zos.zcoreDatasource)# listing_track  
	WHERE  listing_track.listing_id = listing.listing_id  and   
	listing_deleted = #db.param(0)# and 
	listing_lookup_deleted = #db.param(0)# and 
	listing_track_deleted = #db.param(0)# and 
	   listing_track.listing_track_inactive=#db.param('0')# and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
	listing.listing_liststatus=#db.param('1,4,7,16')#
       and listing_city NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#) 
        and listing_lookup_type=#db.param('listing_type')# AND 
		listing_lookup_id= listing_type_id AND listing_city=#db.param(form.city_id)# 
    
    <cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereSQL)# </cfif>
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif> 
	GROUP BY listing_type_id ORDER BY c DESC
    </cfsavecontent>
<cfscript>
qD=db.execute("qD");
</cfscript>
    <cfloop query="qD">
    <a href="/#application.zcore.functions.zURLEncode(qD3.city_name&' '&qD.listing_lookup_value,'-')#-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-#form.city_id#_#qD.listing_type_id#.html">#qD3.city_name# #qD.listing_lookup_value#</a> (#qD.c#)<br />
    </cfloop>
    <cfsavecontent variable="tempPageNav">
    <a href="/">#request.zos.globals.homelinktext#</a> / <a href="/Real-Estate-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-.html">Real Estate</a> /
    </cfsavecontent>
    <cfscript>
    application.zcore.template.setTag("title",'#qD3.city_name# Real Estate');
    application.zcore.template.setTag("pagetitle",'#qD3.city_name# Real Estate');
    application.zcore.template.setTag("pagenav",tempPageNav);
	
	curUrlName=application.zcore.functions.zUrlEncode(qD3.city_name&' Real Estate',"-");
	currentUrl="/#curUrlName#-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-#form.city_id#.html";
	if(structkeyexists(form, 'zurlname') and compare(form.zURLName, curUrlName) NEQ 0){
		application.zcore.functions.z301Redirect(currentUrl);
	}
    </cfscript>
    
<cfelse> 
    <cfsavecontent variable="tempPageNav">
    <a href="/">#request.zos.globals.homelinktext#</a> / 
    </cfsavecontent>
    <cfscript>
    application.zcore.template.setTag("title",'Real Estate Listings');
    application.zcore.template.setTag("pagetitle",'Real Estate Listings');
    application.zcore.template.setTag("pagenav",tempPageNav);
	currentUrl="/Real-Estate-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-.html";
	
    inquiryTextMissing=false;
    ts=structnew();
    ts.content_unique_name='/z/listing/real-estate/index';
    r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
    if(r1 EQ false){
        inquiryTextMissing=true;
		if(structkeyexists(form, 'zurlname') and compare('Real-Estate',form.zUrlName) NEQ 0){
			application.zcore.functions.z301Redirect(currentUrl);
		}
    }
    </cfscript>
    
	<!--- Root Page
Example of getting cities with listings within 10 mile radius
	 --->
     <cfif distanceRadius LT 100>
     <cfsavecontent variable="db.sql">
	SELECT CAST(GROUP_CONCAT(city.city_id SEPARATOR #db.param(',')#) AS CHAR) idlist 
	FROM #db.table("city_distance_memory", request.zos.zcoreDatasource)# city_distance, 
	#db.table("city_memory", request.zos.zcoreDatasource)# city  
	WHERE city_parent_id=#db.param(primaryCityId)# and 
	city_distance <=#db.param(distanceRadius)# and 
	city.city_id = city_distance.city_id  and 
	city_deleted = #db.param(0)# and 
	city_distance_deleted = #db.param(0)#
	ORDER BY city_distance ASC
      </cfsavecontent>
<cfscript>
qCity2=db.execute("qCity2");
</cfscript>
           <cfsavecontent variable="db.sql">
     SELECT city_name, city.city_id, COUNT(listing.listing_id) c FROM (
	 #db.table("listing_memory", request.zos.zcoreDatasource)# listing, 
	 #db.table("city_memory", request.zos.zcoreDatasource)# city, 
	 #db.table("listing_track", request.zos.zcoreDatasource)# listing_track)  
	 WHERE  
	 listing_deleted = #db.param(0)# and 
	 city_deleted = #db.param(0)# and 
       #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
listing.listing_liststatus=#db.param('1,4,7,16')#
       <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list NEQ ""> 
	   		and city_id NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#) 
	   </cfif>
        and listing.listing_id = listing_track.listing_id and 
		listing_track.listing_track_deleted=#db.param('0')# and 
	   listing_track.listing_track_inactive=#db.param('0')# AND 
		city.city_id=listing.listing_city AND 
		listing_city IN (<cfif qCity2.idlist NEQ "">#db.trustedSQL(qCity2.idlist)#<cfelse>#db.param(primaryCityId)#</cfif>)
		<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>

    	<cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereSQL)# </cfif>
           
         GROUP BY listing_city 
		 ORDER BY c DESC
         </cfsavecontent>
		<cfscript>
		qD=db.execute("qD");
		</cfscript>
     <cfelse>
         <cfsavecontent variable="db.sql">
         SELECT city_name, city.city_id, COUNT(listing.listing_id) c 
		 FROM (#db.table("listing_memory", request.zos.zcoreDatasource)# listing, 
		 #db.table("city_memory", request.zos.zcoreDatasource)# city, 
		 #db.table("listing_track", request.zos.zcoreDatasource)# listing_track)  WHERE  
		 listing_deleted = #db.param(0)# and 
		 city_deleted = #db.param(0)# and 
       #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))#  and 
	   listing.listing_liststatus=#db.param('1,4,7,16')#
       and city_id NOT IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list)#'")#) 
       AND city.city_id=listing.listing_city and 
	   listing.listing_id = listing_track.listing_id and 
	   listing_track.listing_track_deleted=#db.param('0')# and 
	   listing_track.listing_track_inactive=#db.param('0')#
<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>

    <cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereSQL)# </cfif>
           
         GROUP BY listing_city ORDER BY c DESC
         </cfsavecontent>
		<cfscript>
        qD=db.execute("qD");
        </cfscript>
     </cfif>
    <cfloop query="qD">
    <a href="/#application.zcore.functions.zURLEncode(qD.city_name,'-')#-Real-Estate-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_site_map_url_id#-#qD.city_id#.html">#qD.city_name# Real Estate</a> (#qD.c#)<br />
    </cfloop>
</cfif>
</cfif>
<hr />
<h2>Related Real Estate Listings</h2>
	<cfscript>
	propertyHTML="";
	propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	ts = StructNew();
	if(form.listing_sub_type_id EQ ""){
		perpageDefault=10;
		form.zIndex=1;
		ts.offset=0;	
		ts.disableCount=true;
	}else{
		perpageDefault=50;
		ts.offset = form.zIndex-1;
	}
	//ts.debug=true;
	perpage=perpageDefault;
	ts.perpage = perpage;
	ts.distance = 0;//distanceRadius; // in miles
	//ts.disableCount=true;
	ts.searchCriteria=structnew();
	request.zos.listing.functions.zMLSSetSearchStruct(ts.searchcriteria, form);
	ts.searchCriteria.search_new_first=1;
	if(form.city_id NEQ ""){
		ts.searchCriteria.search_city_id=form.city_id;
	}else if(distanceRadius LT 100){
		ts.searchCriteria.search_city_id=qCity2.idlist;
	}
	if(form.listing_type_id NEQ ""){
		ts.searchCriteria.search_listing_type_id=form.listing_type_id;
	}
	if(form.listing_sub_type_id NEQ ""){
		ts.searchCriteria.search_listing_sub_type_id=form.listing_sub_type_id;
	}
	ts.searchCriteria.search_liststatus='1,4,7,16';
	if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
		ts.searchCriteria.search_status='7';
    } 
	ts.searchCriteria.search_result_limit=perpageDefault;
		
	returnStruct = propertyDataCom.getProperties(ts);
	structdelete(variables,'ts');
	
	if((form.listing_sub_type_id EQ "" and arrayLen(returnStruct.arrData) NEQ 0) or (returnStruct.count -(perpageDefault*(form.zIndex-1)) GT 0)){	
		propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
		
		ts = StructNew();
		ts.descriptionLink=true;
		ts.descriptionLinkRemarks=true;
		ts.getDetails=false;
		ts.dataStruct = returnStruct;
		
		
			
		if(form.listing_sub_type_id NEQ ""){
			// required
			searchStruct = StructNew();
			// optional
			searchStruct.showString = "";
			searchStruct.indexName = 'zIndex';
			searchStruct.url = currentUrl; 
			searchStruct.buttons = 5;
			searchStruct.count = returnStruct.count;
			searchStruct.index = form.zIndex;
			searchStruct.perpage = perpageDefault;
			ts.navStruct=searchStruct;
		}
		ts.search_result_limit=returnStruct.count;
		propDisplayCom.init(ts);
	
		propertyHTML=propDisplayCom.display();
		writeoutput(propertyHTML);
	}else{
		// invalid zIndex has caused 0 results, redirect to the first page... (this url will change later)
		
		//writeoutput('redirect to1: '&currentUrl);
	//	application.zcore.functions.zabort();
		application.zcore.functions.z301Redirect('/');
	}
	</cfscript></span> 
    </cffunction>
</cfoutput>
</cfcomponent>