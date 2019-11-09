<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfscript>
Request.zPageDebugDisabled=true;
application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
application.zcore.template.setTag("title","Listing Map Search");
application.zcore.functions.zFullScreenMobileApp();
/*

*/
if(not application.zcore.app.siteHasApp("listing")){
	application.zcore.functions.z404("Listing application is not enabled for this site.");
}
propertyHTML="";
propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
ts = StructNew();
form.zindex=1;
ts.offset = 0;
perpageDefault=10;
perpage=10;
perpage=max(1,min(perpage,100));
ts.perpage = perpage;
ts.distance = 30; // in miles
ts.disableCount=true;

if(structkeyexists(form, 'searchId') EQ false){
	form.searchId=application.zcore.status.getNewId();
}
ts.searchcriteria={
	search_map_coordinates_list="",
	search_map_long_blocks="",
	search_map_lat_blocks="",
	zforcemapresults=""
}
structappend(ts.searchcriteria, application.zcore.status.getStruct(form.searchid).varStruct,true);
searchCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.search");
searchCom.queryStringSearchToStruct(ts.searchcriteria);

request.zos.listing.functions.zMLSSetSearchStruct(ts.searchcriteria, ts.searchcriteria);
structappend(form, ts.searchcriteria, true);

structdelete(ts.searchcriteria, "fieldnames");
   writeoutput('<script>/* <![CDATA[ */ zMapFullscreen=true;zMLSSearchFormName="contentSearchHiddenForm"; /* ]]> */</script>');
   /*
	*/ 
	ts2=StructNew();
    ts2.name="contentSearchHiddenForm";
    ts2.ajax=false;
    ts2.debug=false;
    ts2.action=application.zcore.functions.zURLAppend(request.zos.listing.functions.getSearchFormLink(), "searchaction=search&searchId=#form.searchid#");
    tempSearchFormAction=ts2.action;
    ts2.onLoadCallback="loadMLSResults";
    ts2.method="post";
    ts2.ignoreOldRequests=true;
    ts2.successMessage=false;
    ts2.onChangeCallback="getMLSCount";
    application.zcore.functions.zForm(ts2);
	
	ts3=structnew();
	ts3.name="mapfullscreen";
	form.mapfullscreen="1";
	application.zcore.functions.zinput_hidden(ts3);
    for(i in ts.searchCriteria){
        ts3=structnew();
        ts3.name=lcase(i);
        form[i]=ts.searchCriteria[i];
        application.zcore.functions.zinput_hidden(ts3);
    }
    application.zcore.functions.zEndForm();

randcount=randrange(5,10);

</cfscript>
    <div id="mapContentDivId" style="width:100%; float:left;"></div>
	<cfscript>
	mapStageStruct=StructNew();
	mapStageStruct.width="100%";
	mapStageStruct.height="100%";
	mapStageStruct.fullscreen.width=600;
	mapStageStruct.fullscreen.height=600;
	request.zOverrideMapDivId="mapContentDivId"
	
		ms={
			propertyDataCom=propertyDataCom,
			mapStageStruct=mapStageStruct
		}
		mapCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.map");
		mapCom.index(ms);
		</cfscript>
<cfsavecontent variable="theScript">
<style>body{ background:none !important; overflow:hidden; background-color:transparent !important;}
##zlsHideListingMapDiv{display:none;}
##myGoogleMapV3{ z-index:21;}
##zlsMapLegendDiv{margin-top:-63px; width:530px !important; position:relative; background-color:##FFF; opacity:0.8; float:right !important; z-index:22;}
.zls2-colorlegend{ display:block !important;}
##zlsInstantPlaceholder{display:none !important;}
##zSearchJsToolNewDiv{display:none !important;}
</style>
<script>
/* <![CDATA[ */  
zArrDeferredFunctions.push(function(){ 
zArrResizeFunctions.push({functionName: zlsUpdateMapSize});
zMapArrLoadFunctions.push(function(){ zMapCoorUpdateV3(true, "contentSearchHiddenForm");}); }); 
/* ]]> */
</script></cfsavecontent>
<cfscript>
application.zcore.template.appendTag("scripts",theScript);
</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>