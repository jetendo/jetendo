<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfscript> 
db=request.zos.queryObject;
Request.zPageDebugDisabled=true;
application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
form.ssid=application.zcore.functions.zso(form, 'ssid',true);
db.sql="select * from  
#request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
where
saved_search_email=#db.param('')# and 
user_id=#db.param(0)# and 
contact_id=#db.param(0)# and 
mls_saved_search_deleted = #db.param(0)# and 
mls_saved_search_id = #db.param(form.ssid)# and 
mls_saved_search.site_id=#db.param(request.zos.globals.id)#";
qC=db.execute("qC");
 
if(qC.recordcount EQ 0){
	abort;
}
application.zcore.functions.zquerytostruct(qc, form);

propertyHTML="";
propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
ts = StructNew();
form.zindex=1;
ts.offset = 0;
perpageDefault=10;
perpage=form.search_result_limit;
perpage=max(1,min(perpage,100));
ts.perpage = perpage;
ts.distance = 30; // in miles
ts.disableCount=true;
ts.searchCriteria=structnew();
request.zos.listing.functions.zMLSSetSearchStruct(ts.searchcriteria, form);

form.searchId=application.zcore.status.getNewId();
application.zcore.status.setStatus(form.searchid,false,ts.searchcriteria); 
writeoutput('<script>/* <![CDATA[ */ zMLSSearchFormName="contentSearchHiddenForm"; /* ]]> */</script>');
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
ts3.name="search_map_long_blocks";
application.zcore.functions.zinput_hidden(ts3);
ts3=structnew();
ts3.name="search_map_lat_blocks";
application.zcore.functions.zinput_hidden(ts3);
ts3=structnew();
ts3.name="zforcemapresults";
application.zcore.functions.zinput_hidden(ts3);

for(i in ts.searchCriteria){
	ts3=structnew();
	ts3.name=lcase(i);
	form[i]=ts.searchCriteria[i];
	application.zcore.functions.zinput_hidden(ts3);
}
application.zcore.functions.zEndForm(); 
if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
ts.debug=true;
}
propertyHTML="";
if(isDefined('request.zForceHideContentProperties') EQ false){ 
	returnStruct = propertyDataCom.getProperties(ts);
	structdelete(variables,'ts'); 
	if(returnStruct.count NEQ 0){	
		propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
		
	}
}
randcount=randrange(5,10);
</cfscript>
	<div id="mapContentDivId" style="width:100%; float:left;"></div>
	<cfscript>
	mapStageStruct=StructNew();
	mapStageStruct.width=380;
	mapStageStruct.height=300;
	mapStageStruct.fullscreen.width=380;
	mapStageStruct.fullscreen.height=300;
	mapQuery=returnStruct;
	//hideMapControls=true;
	request.zOverrideMapDivId="mapContentDivId"
	
		ms={
			mapQuery=mapQuery,
			propertyDataCom=propertyDataCom,
			mapStageStruct=mapStageStruct
		}
		mapCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.map");
		mapCom.index(ms);
		</cfscript><br /><strong><a href="##" onclick="zlsOpenResultsMap('contentSearchHiddenForm'); return false;">View Fullscreen Map</a></strong>
<cfsavecontent variable="theScript">
<style>
body{ overflow:hidden; background:none !important; background-color:transparent !important;}
##zlsMapLegendDiv{display:none;}
</style>
<script>
/* <![CDATA[ */ 
zArrDeferredFunctions.push(function(){ 
	zMapArrLoadFunctions.push(function(){
		zMapCoorUpdateV3(true, "contentSearchHiddenForm");
	}); 
	document.body.onmouseover=function(){
		var myOptions = {
			draggable: false,
			scrollwheel:false
		}
		mapObjV3.setOptions(myOptions);
	} 
}); 
/* ]]> */
</script></cfsavecontent>
<cfscript>
application.zcore.template.appendTag("scripts",theScript);
</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>