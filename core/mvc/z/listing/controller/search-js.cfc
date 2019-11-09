<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfscript>
application.zcore.functions.zRequireJquery();
application.zcore.functions.zRequireJqueryUI();
//application.zcore.functions.zFullScreenMobileApp();
application.zcore.template.setTag("title","New MLS Search Interface");
//application.zcore.template.setTag("pagetitle","New MLS Search Interface");

application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);

propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
ts=structnew();
ts.onlyCount=true;
ts.offset = 0;
ts.distance = 30; 
returnStruct= propertyDataCom.getProperties(ts);
</cfscript>

<cfsavecontent variable="theMeta">
<script>
zArrDeferredFunctions.push(function(){
	var u=window.location.href;
	var p=u.indexOf("##");
	if(p != -1){
		u=u.substr(p);
	}
	if(u.indexOf("forceForm=") != -1){
		zScrollApp.disableFirstAjaxLoad=true;
	}
	zScrollApp.listingSearchLoad(); 
	zlsHoverBoxNew.load();
	
	if(zScrollApp.disableFirstAjaxLoad){
		zlsHoverBoxNew.togglePanel();
	}
	zArrResizeFunctions.push({functionName:zlsHoverBoxNew.resizePanel});
	zlsHoverBoxNew.resizePanel();
	if(!zScrollApp.disableFirstAjaxLoad){
		setTimeout(zlsHoverBoxNew.showListings, 100);
	}else{
		setMLSCount2(#returnStruct.count#);
	}
	zArrScrollFunctions.push({functionName:zForceSearchJsScrollTop});
	zScrollApp.disableFirstAjaxLoad=false;
});
</script>
<style>
/* <![CDATA[ */
body{ padding-top:60px; background:none !important; background-color:transparent !important;}
/* ]]> */
</style>
</cfsavecontent>
<cfscript>
application.zcore.template.appendTag("meta",theMETA);
</cfscript>
<!--- <div class="z-fixed-position z-fixed-n">
North
</div>
<div class="z-fixed-position z-fixed-n-e">
North East
</div>
<div class="z-fixed-position z-fixed-e">
East
</div>
<div class="z-fixed-position z-fixed-s-e">
South East
</div>
<div class="z-fixed-position z-fixed-s">
South
</div>
<div class="z-fixed-position z-fixed-s-w">
South West
</div>
<div class="z-fixed-position z-fixed-w">
West
</div>
<div class="z-fixed-position z-fixed-n-w">
North West
</div> --->
<div id="debugDiv" style="display:none;position:absolute; left:300px; top:300px; opacity:0.6; z-index:10000; width:300px;">
  <textarea id="dt21" name="dt21" cols="10" style="width:90%" rows="10"></textarea>
  <div id="debugDivDiv" style="width:100%; float:left; clear:both; height:200px; overflow:auto;">
  </div>
  <br style="clear:both;" />
</div>
<div id="zls-hover-box" class="z-fixed-n">
  <cfscript>
	application.zcore.template.appendTag("scripts", '<div id="resultCountAbsolute" style="display:none;float:left; font-weight:700; padding:10px;">0 Listings</div>');
</cfscript>
  <a href="##" id="zls-hover-box-refine-button">Refine Search</a>
  <!--- <a href="#" id="zls-hover-box-show-button" class="zls-hover-box-show-button-selected">Show Listings</a> --->
  <div style="padding:10px; float:left;"></div>
  <div style="padding:10px; float:right; padding:5px;"><a href="##" id="zls-hover-box-grid-button">GRID</a><a href="##" id="zls-hover-box-list-button" style="display:none;">LIST</a><a href="##" id="zls-hover-box-map-button" style="display:none;">MAP</a></div>
</div>
<cfsavecontent variable="searchPanelHTML">
        <cfscript>
		tempCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.search");
		tempCom.searchForm();
		</cfscript>
</cfsavecontent>

<div id="zls-hover-box-panel" class="z-fixed-n"  style=" background-color:##FFF;border:1px solid ##999; border-right:none;border-left:none;">
<div id="zls-hover-box-panel-inner" style="width:92%; padding:20px; padding-right:0px;">
<!--- Large search form goes here. --->
<cfoutput>
#searchPanelHTML#
</cfoutput>
</div>
</div>

<cfscript>
searchCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.search");
searchCom.s();
</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>