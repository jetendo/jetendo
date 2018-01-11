<cfcomponent>
<cfoutput> 

<cffunction name="getSearchFormLink" localmode="modern" output="no" returntype="string">
	<cfscript>
	var customForm=application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_search_template',false,"");
	var customFormForced=application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_search_template_forced',true, 0);
	if(customForm NEQ "" and customFormForced EQ 1){
		return customForm;
	}else{
		return "/z/listing/search-form/index";
	}
	</cfscript>
</cffunction>

<!--- zMLSSearchOptions('variables'); --->
<cffunction name="zMLSSearchOptions" localmode="modern" returntype="any" output="true">
	<cfargument name="saved_search_id" type="string" required="yes">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="searchMLS" type="string" required="yes">
	<cfargument name="hideSearchMlS" type="boolean" required="no" default="#false#">
	<cfscript> 
	db=request.zos.queryObject; 
	if(structkeyexists(form,'action')){
        ssaction=form.action;
	}else{
		ssaction="";
	}
	if(arguments.searchMLS EQ ""){
		arguments.searchMLS=0;
	}
	form.action="form";
	request.contentEditor=true;
	</cfscript>
	<cfif arguments.searchMLS EQ 0>
    	<script type="text/javascript">
		zDisableOnGmapLoad=true;
		</script>
    </cfif> 
    <cfif arguments.hideSearchMLS EQ false>
    	Search MLS <input type="radio" name="#arguments.fieldName#" value="1" <cfif arguments.searchMLS EQ 1>checked="checked"</cfif> onclick="rssToggleMLSForm(this);" style="border:none; background:none;" /> Yes | <input type="radio" name="#arguments.fieldName#" value="0" onclick="rssToggleMLSForm(this);" <cfif arguments.searchMLS EQ 0>checked="checked"</cfif> style="border:none; background:none;" /> No 
          <script type="text/javascript">
		  /* <![CDATA[ */
		  function rssToggleMLSForm(obj){
			var cTR=document.getElementById('rssMlsSearchFormTR');
			if(obj.checked && obj.value == '1'){
				cTR.style.display="block";
				updateCountPosition(null,15);
				zDisableOnGmapLoad=false;
				if(typeof onGMAPLoad == "function"){
					onGMAPLoad(true);
				}
			}else{
				cTR.style.display="none";
			}
		  }
		  /* ]]> */
		  </script> 
        </cfif>

        <div id="rssMlsSearchFormTR" <cfif arguments.searchMLS EQ 0>style="display:none;"</cfif>>
        <cfsavecontent variable="db.sql">
			select * from #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
            where mls_saved_search_id= #db.param(arguments.saved_search_id)# and 
			site_id = #db.param(request.zos.globals.id)# and 
			mls_saved_search_deleted =#db.param(0)# 
		</cfsavecontent><cfscript>qSavedSearch=db.execute("qSavedSearch");
		application.zcore.functions.zquerytostruct(qSavedSearch, form);
		request.zos.listing.functions.zMLSSetSearchStruct(form, form);
		local.tempCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.search-form");
		local.tempCom.index();
		form.action=ssaction;
		</cfscript>
		</div>
		
	

</cffunction>


<!--- application.zcore.functions.zMLSSearchForm(); --->
<cffunction name="zMLSSearchForm" localmode="modern" returntype="any" output="true">
	<cfscript>
	var theMeta=0;
	var local=structnew();
	var ssaction=0;
	if(structkeyexists(form,'action')){
        ssaction=form.action;
	}else{
		ssaction="";
	}
	form.action="form";
	request.contentEditor=true;
	</cfscript>
	
	<div id="rssMlsSearchFormTR">
		<cfscript>request.zos.listing.functions.zMLSSetSearchStruct(form, form);

		local.tempCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.search-form");
		local.tempCom.index();
		form.action=ssaction;
		</cfscript>
	</div>
    <cfsavecontent variable="theMeta">
    <style type="text/css">
	.zSearchFormTable{float:left; width:200px;}
	</style>
    </cfsavecontent>
    <cfscript>
	application.zcore.template.appendtag("meta", theMeta);
	</cfscript>
</cffunction>



	<cffunction name="zMLSSearchOptionsUpdateEmail" localmode="modern" returntype="any" output="true">
		<cfargument name="oldemail" type="string" required="yes">
		<cfargument name="newemail" type="string" required="yes">
		<cfscript>
		var db=request.zos.queryObject;
		db.sql="UPDATE #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
		SET saved_search_email = #db.param(arguments.newemail)#,
		mls_saved_search_updated_datetime=#db.param(request.zos.mysqlnow)#  
		where saved_search_email = #db.param(arguments.oldemail)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		mls_saved_search_deleted = #db.param(0)#";
		db.execute("q"); 
		</cfscript>
	</cffunction>

<!--- zMLSSearchOptionsUpdate('variables'); --->
<cffunction name="zMLSSearchOptionsUpdate" localmode="modern" returntype="any" output="true">
	<cfargument name="MLSSavedSearchAction" type="string" required="yes">
	<cfargument name="mls_saved_search_id" type="string" required="yes">
	<cfargument name="email" type="string" required="no" default="">
	<cfargument name="searchCriteriaStruct" type="struct" required="no" default="#form#">
	<cfscript>
	var qC=structnew();
	var ts=StructNew();
	var db=request.zos.queryObject;
	var i=0;
	var nowDate=request.zos.mysqlnow;
	arguments.searchCriteriaStruct.mls_saved_search_id=arguments.mls_saved_search_id;
	ts.table="mls_saved_search";
	ts.datasource="#request.zos.zcoreDatasource#";
	ts.struct=structnew();
	if(not structkeyexists(arguments.searchCriteriaStruct, 'search_liststatus') or arguments.searchCriteriaStruct.search_liststatus EQ ""){
		arguments.searchCriteriaStruct.search_liststatus="1";
	}

	request.zos.listing.functions.zMLSSetSearchStruct(ts.struct, arguments.searchCriteriaStruct);
	ts.struct.site_id=request.zos.globals.id;
	for(i in arguments.searchCriteriaStruct){
		if(isSimpleValue(arguments.searchCriteriaStruct[i])){
			arguments.searchCriteriaStruct[i]=trim(arguments.searchCriteriaStruct[i]);	
		}
	}
	if(arguments.MLSSavedSearchAction EQ 'update'){
			//First we delete the existing record
			if(arguments.mls_saved_search_id NEQ "" and arguments.mls_saved_search_id NEQ 0){
				db.sql="select mls_saved_search_id from #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
				WHERE mls_saved_search_id = #db.param(arguments.mls_saved_search_id)#  and 
				mls_saved_search_deleted=#db.param(0)# and 
				site_id = #db.param(request.zos.globals.id)#";
				qC=db.execute("qC"); 
			}else{
				qC.recordcount=0;
			}
			ts.struct.saved_search_updated_date=nowDate;
			ts.struct.saved_search_sent_date=nowDate;
			if(arguments.email NEQ ""){
				ts.struct.saved_search_email=arguments.email;	
			}
			if(not structkeyexists(ts.struct,'saved_search_format') EQ false){
				ts.struct.saved_search_format=0;
			}
			if(not structkeyexists(ts.struct,'saved_search_frequency') EQ false){
				ts.struct.saved_search_frequency=0;	
			}
			if(qC.recordcount NEQ 0){
				ts.struct.mls_saved_search_id=arguments.mls_saved_search_id;
				structdelete(ts.struct,'saved_search_key');
				application.zcore.functions.zUpdate(ts);
				/*
				writedump(ts);
				writedump(request.zos.arrQueryLog);
				application.zcore.functions.zabort();
				*/
			}else{
				ts.struct.saved_search_key=hash(application.zcore.functions.zGenerateStrongPassword(256,256), 'sha-256');
				ts.struct.saved_search_created_date=nowDate;
				if(structkeyexists(ts.struct, 'saved_search_email')){
					request.zsession.saved_search_email=ts.struct.saved_search_email;
					request.zsession.saved_search_key=ts.struct.saved_search_key;
				}
				//Now, we insert the new data
				arguments.mls_saved_search_id = application.zcore.functions.zInsert(ts);
			}
			return arguments.mls_saved_search_id;
	}else if(arguments.MLSSavedSearchAction EQ "delete"){
		 db.sql="delete from #db.table("mls_saved_search", request.zos.zcoreDatasource)#  
		 WHERE mls_saved_search_id=#db.param(arguments.mls_saved_search_id)# and 
		site_id=#db.param(request.zos.globals.id)# and 
		mls_saved_search_deleted =#db.param(0)# ";
		db.execute("q");
	}
	</cfscript>
	
</cffunction>

<!--- zGetSavedSearchQuery(mls_saved_search_id); --->
<cffunction name="zGetSavedSearchQuery" localmode="modern" returntype="any" output="true">
	<cfargument name="mls_saved_search_id" type="string" required="yes">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	where mls_saved_search_id= #db.param(arguments.mls_saved_search_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	mls_saved_search_deleted =#db.param(0)# ";
	qSavedSearch2=db.execute("qSavedSearch2");
	return qSavedSearch2;
	</cfscript>
</cffunction>


<!--- 
ts=structnew();
ts.debug=false;
ts.address="";
zGetLatLong(ts);
 --->
<!--- <cffunction name="zGetLatLong" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var rs=structnew();
	var ts=structnew();
	rs.latitude="0";
	rs.longitude="0";
	rs.error=false;
	rs.errorMessage="";
	ts.debug=false;
	structappend(arguments.ss,ts,false);

	if(arguments.ss.debug EQ false){
		theLink='http://maps.google.com/maps/geo?q=#urlencodedformat(arguments.ss.address)#&output=csv&oe=utf8&sensor=false&key=#request.zos.globals.googlemapsapikey#';
		r1=application.zcore.functions.zDownloadLink(theLink);
		if(r1.success){
			r2=r1.cfhttp.FileContent;
		}else{
			application.zcore.template.fail("Failed to access google geocoder API<br /><a href=""#theLink#"">#theLink#</a>");	
		}
	}else{
		r2="200,8,28.5435310,-81.3488390";
	}
	r2=trim(r2);
	rs.accuracy=-1;
	curF=false;
	arrLines=listtoarray(r2,chr(10));
	curStatus="";
	for(i=1;i LTE arraylen(arrLines);i++){
		arrF=listtoarray(arrLines[i]);
		curStatus=arrF[1];
		if(arrF[1] EQ '200'){
			if(arrF[2] GT rs.accuracy){
				rs.accuracy=arrF[2];
				rs.latitude=arrF[3];
				rs.longitude=arrF[4];
			}
		}else if(arrF[1] EQ '602'){
			// unknown address.
		}else if(arrF[1] EQ '603'){
			// unavailable address.
		}else if(arrF[1] EQ '620'){
			rs.error=true;
			rs.errorMessage="Too many queries to google geocoder from this IP. 2,500 is the limit per day.";
		}else if(arrF[1] EQ '610'){
			rs.error=true;
			rs.errorMessage="Invalid google maps key, ""#request.zos.globals.googlemapsapikey#"".";
		}else{
			// unknown error	
			rs.error=true;
			rs.errorMessage="Google maps geocoder had an unknown error: #arrLines[i]#";
		}
	}
	</cfscript><cfif rs.errorMessage NEQ ""><cfmail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" charset="utf-8" subject="zGetLatLong error">Address: #arguments.ss.address#
    URL: #theLink#
    Error Message: #rs.errorMessage#</cfmail></cfif><cfscript>
	return rs;
	</cfscript>
</cffunction>
 --->


<!--- zMLSSearchOptionsDisplay('variables'); --->
<cffunction name="zMLSSearchOptionsDisplay" localmode="modern" returntype="any" output="true">
	<cfargument name="mls_saved_search_id" type="string" required="yes">
	<cfargument name="ss" type="struct" required="no" default="#structnew()#">
	<cfscript> 
	var returnStruct={count:0}; 
	var db=request.zos.queryObject; 
	var t9=structnew();
	var t8942=structnew();
	var rs=structnew();
	t9.offset=0;
	t9.perpage=10;
	t9.returnArray=false;
	t9.disableInstantSearch=false;
	t9.forcePerPage=false;
	t9.extraSearchCriteria=structnew();
	t9.forceSimpleLimit=false;
	t9.disableCount=true;
	t9.thumbnailWidth=150;
	t9.thumbnailHeight=100;
	t9.thumbnailCrop=1;
	t9.search_with_photos=0;
	t9.distance=30;
	t9.extraCriteria=structnew();
	t9.returnQueryOnly=false;
	structappend(arguments.ss,t9,false);
	if(not structkeyexists(form, 'pw')){
		form.pw=arguments.ss.thumbnailWidth;
	}
	if(not structkeyexists(form, 'ph')){
		form.ph=arguments.ss.thumbnailHeight;
	}
	if(not structkeyexists(form, 'pa')){
		form.pa=arguments.ss.thumbnailCrop;
	}
	
	db.sql="select * from #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	where mls_saved_search_id= #db.param(arguments.mls_saved_search_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	mls_saved_search_deleted = #db.param(0)#";
	qSavedSearch3=db.execute("qSavedSearch3");
	application.zcore.functions.zquerytostruct(qSavedSearch3, t8942);
	rs.mlsSearchSearchQuery=qSavedSearch3;
	if(structkeyexists(arguments.ss,'search_sort') and arguments.ss.search_sort EQ ""){
		arguments.ss.search_sort="priceasc";	
	}
	</cfscript>
	<cfsavecontent variable="moreLink">
		<div class="zls-more-link-heading">
		<br style="clear:both;" /><a id="zbeginlistings"></a>
		<h2>#application.zcore.functions.zvarso('See more properties for sale below', request.zos.globals.id, true)#</h2><br />
		</div>
		<cfif arguments.ss.disableInstantSearch EQ false and application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_enable_instant_search EQ 1>
			<cfscript>
			local.searchCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.search");
			local.newUrl=local.searchCom.formVarsToURL(t8942);
			</cfscript>
			<input type="hidden" name="zListingSearchJsURLHidden" id="zListingSearchJsURLHidden" value="/z/listing/search-js/index?#htmleditformat(local.newUrl)#" />
			<div id="zListingInfinitePlaceHolder" style="width:100%; clear:both; float:left; min-height:250px;"></div>
		<cfelse>
			<cfscript>
			perpage=t8942.search_result_limit;
			propertyHTML="";
			propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
			ts18972 = StructNew();
			form.zindex=1;
			ts18972.offset = arguments.ss.offset;
			perpage=max(1,min(arguments.ss.perpage,100));
			ts18972.forceSimpleLimit=arguments.ss.forceSimpleLimit;
			ts18972.distance = arguments.ss.distance; // in miles
			ts18972.disableCount=arguments.ss.disableCount;
			ts18972.searchCriteria=structnew();
			request.zos.listing.functions.zMLSSetSearchStruct(ts18972.searchcriteria, t8942);
			ts18972.searchcriteria.search_with_photos=arguments.ss.search_with_photos;
			structappend(ts18972.searchCriteria, arguments.ss.extraSearchCriteria, false);
			if(arguments.ss.forcePerPage){
				ts18972.perpage =perpage;
				ts18972.searchCriteria.search_result_limit = perpage;
			}else{
				ts18972.perpage = t8942.search_result_limit;
			}
			local.searchCriteriaBackup=ts18972.searchCriteria;
			structappend(ts18972, arguments.ss.extraCriteria, false);
			searchId=application.zcore.status.getNewId();
			request.zMLSSearchOptionsDisplaySearchId=searchId;
			if(isDefined('ts18972.searchcriteria')){
				application.zcore.status.setStatus(searchId,false,ts18972.searchcriteria);
			}
			if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
				ts18972.debug=true;
			}else{
				ts18972.debug=false;
			}
			returnStruct = propertyDataCom.getProperties(ts18972);
			rs.propertyDataCom=propertyDataCom;
			if(arguments.ss.returnQueryOnly){
				return returnStruct;	
			}
			structdelete(variables,'ts');
			if(returnStruct.count or arguments.ss.returnArray){	
				propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
				
				ts18972 = StructNew();
				ts18972.dataStruct = returnStruct;
				ts18972.search_result_layout=propertyDataCom.searchCriteria.search_result_layout;
				if(propertyDataCom.searchCriteria.search_group_by EQ "1"){
					ts18972.groupBedrooms=true;
					ts18972.search_result_layout=1;
				}
				
				if(structkeyexists(ts18972,'search_result_layout') and ts18972.search_result_layout EQ 2){
					ts18972.getDetails=false;
				}
				propDisplayCom.init(ts18972);
				if(arguments.ss.returnArray){
					if(arguments.ss.forcePerPage){
						return propDisplayCom.getArray(false);
					}else{
						return propDisplayCom.getArray(true);
					}
				}else{
					echo(propDisplayCom.display());
				
				}
			}
			randcount=randrange(5,10);
			
			</cfscript> 
			<cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_search',true) EQ 0>
				<cfif isDefined('returnstruct.count') and returnstruct.count GT returnstruct.perpage>
					<table style="margin-left:auto; margin-right:auto; border-spacing:10px; width:100%;"><tr><td style="line-height:24px;font-size:18px; font-weight:bold; text-align:center;"><a href="#application.zcore.functions.zblockurl(request.zos.listing.functions.getSearchFormLink()&'?mls_saved_search_id=#arguments.mls_saved_search_id#&zIndex=2')#">Go to Next Page of Listings (Page 2)<br /><br /> or refine this search</a></td></tr></table>
				</cfif>
			</cfif>
		
		</cfif>
	</cfsavecontent>
	<cfscript>
	rs.output=moreLink;
	rs.searchCriteria=local.searchCriteriaBackup;
	rs.returnStruct=returnStruct; 
	return rs;
	</cfscript>
 </cffunction>
 
<cffunction name="zListingDisplaySavedSearch" localmode="modern" access="public">
	<cfargument name="amls_saved_search_id" type="string" required="yes">
	<div class="zls-listingSavedSearchDiv" data-ssid="#arguments.amls_saved_search_id#"></div> 
 </cffunction>

<cffunction name="zListingDisplaySavedSearchMapSummary" localmode="modern" access="public">
	<cfargument name="amls_saved_search_id" type="string" required="yes">
	<div class="zls-listingSavedSearchMapSummaryDiv" data-ssid="#arguments.amls_saved_search_id#" style="width:100%; clear:both; float:left;">
		<div class="contentPropertySummaryDiv" style="width:#request.zos.globals.maximagewidth-400#px; float:left;">
		</div>
		
		<div class="mapContentDiv" style="width:380px; float:right; margin-left:20px; margin-bottom:20px;">  
		</div>
	</div> 
 </cffunction> 

<!--- zMLSSetSearchStruct(variables, searchStruct); --->
<cffunction name="zMLSSetSearchStruct" localmode="modern" output="no" returntype="any">
	<cfargument name="struct1" type="struct" required="yes">
	<cfargument name="searchStruct" type="any" required="yes">
	<cfscript>
	var i=0;
	var gs99t=StructNew();
	
	gs99t.search_BATHROOMS_low="";
	gs99t.search_bathrooms_high="";
	gs99t.search_BEDROOMS_low="";
	gs99t.search_bedrooms_high="";
	gs99t.search_CITY_ID="";
	gs99t.search_EXACT_MATCH="";
	gs99t.search_MAP_COORDINATES_LIST="";
	gs99t.search_listing_type_id="";
	gs99t.search_listing_sub_type_id="";
	gs99t.search_condoname="";  
	gs99t.search_address="";  
	gs99t.search_zip="";  
	gs99t.search_rate_low="";  
	gs99t.search_rate_high="";  
	gs99t.search_list_date="";  
	gs99t.search_max_list_date="";
	gs99t.search_SQFOOT_HIGH="";
	gs99t.search_lot_square_feet_low="";
	gs99t.search_lot_square_feet_high="";
	gs99t.search_result_limit="";
	gs99t.search_agent_always="";
	gs99t.search_sort_agent_first="";
	gs99t.search_office_always="";
	gs99t.search_sort_office_first="";
	gs99t.search_SQFOOT_LOW="";
	gs99t.search_year_built_low="";
	gs99t.search_result_layout="";
	gs99t.search_group_by="";
	gs99t.search_year_built_high="";
	gs99t.search_county="";
	gs99t.search_frontage="";
	gs99t.search_view="";
	gs99t.search_remarks="";
	gs99t.search_style="";
	gs99t.search_mls_number_list="";
	gs99t.search_sort="";
	gs99t.search_listdate="";
	gs99t.search_near_address="";
	gs99t.search_near_coordinates="";
	gs99t.search_near_radius="";
	gs99t.search_remarks_negative="";
	gs99t.search_mls_number_list="";
	gs99t.search_acreage_low="";
	gs99t.search_acreage_high="";
	gs99t.search_status="";
	gs99t.search_liststatus="";
	gs99t.search_SURROUNDING_CITIES='';
	gs99t.search_WITHIN_MAP="";
	gs99t.search_WITH_PHOTOS="";  
	gs99t.search_WITH_POOL="";   
	gs99t.search_agent_only=false;
	gs99t.search_office_only=false;
	gs99t.search_agent="";
	gs99t.search_office="";
	gs99t.search_subdivision="";
	gs99t.search_region="";
	gs99t.search_parking="";
	gs99t.search_condition="";
	gs99t.search_tenure="";
	// email alert variables
	gs99t.saved_search_format=0;
	gs99t.saved_search_frequency=1;
	if(isStruct(arguments.searchStruct)){
		for(i in gs99t){
			if(structkeyexists(arguments.searchStruct,i) and arguments.searchStruct[i] NEQ 0){
				arguments.struct1[i]=arguments.searchStruct[i];
			}else{
				arguments.struct1[i]="";
			}
		}
	}
    </cfscript>
</cffunction>


<cffunction name="zListinggetCache" localmode="modern" output="no" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
    <cfargument name="value" type="string" required="yes">
    <cfargument name="defaultValue" type="string" required="no" default="">
    <cfscript>
	if(structkeyexists(request.zos.listing.cacheStruct,arguments.fieldName) and structkeyexists(request.zos.listing.cacheStruct[arguments.fieldName], arguments.value)){
		return request.zos.listing.cacheStruct[arguments.fieldName][arguments.value];
	}else{
		return arguments.defaultValue;
	}
	</cfscript>
</cffunction>


<cffunction name="zListinggetTitle" localmode="modern" output="no" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	var qLXS='';
	var d2='';
	var titleStruct=structnew();
	var ts=0;
	var appendStruct=0;
	var seocommercial=0;
	var seolistingbathrooms=0;
	var avs=0;
	var c=0;
	var lbackup23=0;
	var i=0;
	var arrK=0;
	var arrDescription=arraynew(1);
	var arrTitle=arraynew(1);
	var arrURL=arraynew(1);
	var urlLength=0;
	var titleLength=0;
	var descriptionLength=0;
	var remainingDescriptionLength=150;
	var remainingtitleLength=66;
	var remainingurlLength=66;
	var remarkIndex=0;
	var ct=0;
	var p=0;
	if(left(arguments.idx.listing_id, 2) EQ "0-"){
		titleStruct.listing_x_site_title=arguments.idx.manual_listing_title;
		titleStruct.listing_x_site_url=application.zcore.functions.zURLEncode(arguments.idx.manual_listing_title,"-");
		titleStruct.listing_x_site_description=rereplace(arguments.idx.manual_listing_metadesc, "<[^>]*>","","all");
		titleStruct.flashTitle=titleStruct.listing_x_site_title;
		titleStruct.title=titleStruct.listing_x_site_title;
		titleStruct.mapTitle=titleStruct.listing_x_site_title;
		titleStruct.urlTitle=titleStruct.listing_x_site_url;
		titleStruct.propertyType=arguments.idx.listingPropertyType;
		return titleStruct;	
	} 
	// set the above struct if the value exists.
	appendStruct=structnew();
	appendStruct.listingBedrooms=["beds"];
	seolistingBathrooms=["baths"];
	seocommercial=["Commercial Real Estate"];
	
	// flag the available fields
	avs={
		city:"",
		remarks:"",
		address:"",
		subdivision:"",
		bedrooms:"",
		bathrooms:"",
		type:"",
		subtype:"",
		style:"",
		view:"",
		frontage:"",
		pool:"",
		condo:""
	};
	d2="";
	d2="Real Estate";
	if(arguments.idx.listingPropertyType neq ''){
		avs.type=arguments.idx.listingPropertyType;
		if(avs.type EQ "Single Family"){
			avs.type="Home";
		}else if(avs.type EQ "Residential"){
			avs.type="Home";
		}else if(avs.type CONTAINS "commercial"){
			avs.type=seocommercial[1];
		}
		d2=avs.type;
		if((avs.type EQ "land" or avs.type EQ "vacant land") and arguments.idx.listing_acreage NEQ ""){
			avs.type=arguments.idx.listing_acreage&" acres of "&avs.type;
		}
		if(avs.type DOES NOT CONTAIN "commercial"){
			if(arguments.idx.listing_price GT 500000){
				avs.type="Luxury "&avs.type;
			}else if(arguments.idx.listing_price GT 1000000){
				avs.type="Million Dollar "&avs.type;
			}else if(arguments.idx.listing_price GT 2000000){
				avs.type="Multi-Million Dollar "&avs.type;
			}
		}
		if(avs.type EQ "rental"){
			avs.type&=" For Rent";
		}else{
			avs.type&=" "&application.zcore.functions.zfirstlettercaps(arguments.idx.listingstatus);
		}
	}else{
		avs.type="Real Estate "&application.zcore.functions.zfirstlettercaps(arguments.idx.listingstatus);
	} 
	if(arguments.idx.listing_condoname NEQ "" and arguments.idx.listing_condoname NEQ "Other"){
		avs.condo=arguments.idx.listing_condoname&" Condominium";
	}
	if(arguments.idx.listingView neq ''){ 
		c=listlen(arguments.idx.listingView,",");
		avs.view=trim(listgetat(arguments.idx.listingView, 1,","));
	}
	if(arguments.idx.listingFrontage neq ''){ 
		c=listlen(arguments.idx.listingFrontage,",");
		avs.frontage=trim(listgetat(arguments.idx.listingFrontage, 1,","));
	}
	if(arguments.idx.listing_pool EQ 1){
		avs.pool="Pool";
	}
	if(arguments.idx.listingStyle neq ''){
		avs.style=arguments.idx.listingStyle;
	}
	if(arguments.idx.listing_beds neq '' and arguments.idx.listing_beds NEQ 0){
		avs.bedrooms=arguments.idx.listing_beds;
	}
	if(arguments.idx.listing_baths neq '' and arguments.idx.listing_baths NEQ 0){
		avs.bathrooms=arguments.idx.listing_baths;
		if(arguments.idx.listing_halfbaths neq '' and arguments.idx.listing_halfbaths neq '0'){
			if(arguments.idx.listing_halfbaths EQ 1){
				avs.bathrooms&=".5 "&seolistingBathrooms[1];
			}else{
				avs.bathrooms=avs.bathrooms&" bath "&arguments.idx.listing_halfbaths&" half baths";
			}
		}else{
			avs.bathrooms&=" "&seolistingBathrooms[1];
		}
	}
	if(arguments.idx.cityName neq ''){
		avs.city=arguments.idx.cityName;
	}
	if(arguments.idx.listing_subdivision neq 'Not In Subdivision' AND arguments.idx.listing_subdivision neq 'Not On The List' AND arguments.idx.listing_subdivision neq 'n/a' and arguments.idx.listing_subdivision neq ''){
		avs.subdivision=arguments.idx.listing_subdivision;
	}
	if(arguments.idx.listing_data_remarks NEQ ""){
		avs.remarks=trim(lcase(rereplace(arguments.idx.listing_data_remarks,"\*\**"," ","ALL")));
	}
	if(trim(arguments.idx.listing_address) NEQ ""){
		avs.address=application.zcore.functions.zFirstLetterCaps(arguments.idx.listing_address);
	}
	arrT=[];
	if(structkeyexists(avs, 'address') and avs.address NEQ ""){
		arrayAppend(arrT, avs.address);
	}
	if(structkeyexists(avs, 'city') and avs.city NEQ ""){
		arrayAppend(arrT, avs.city);
	}
	if(structkeyexists(avs, 'frontage') and avs.frontage NEQ ""){
		arrayAppend(arrT, avs.frontage);
	}
	if(structkeyexists(avs, 'type') and avs.type NEQ ""){
		arrayAppend(arrT, avs.type);
	}
	// remove false values
	lbackup23="";
	if(structkeyexists(avs, 'address') and avs.address NEQ ""){
		lbackup23=avs.address;
	}
	if(trim(lbackup23) EQ ""){
		if(avs.subdivision NEQ ""){
			lbackup23=avs.subdivision;
			structdelete(avs,'subdivision');	
		}else if(avs.city NEQ ""){
			lbackup23=avs.city;
			structdelete(avs,'city');	
		}
	}
	structdelete(avs,"address");

	for(i in avs){
		if(avs[i] EQ ""){
			structdelete(avs,i);
			continue;
		}
		if(structkeyexists(appendStruct, i)){
			avs[i]&=" "&appendStruct[i][1];	
		}
	} 
	arrK=structkeyarray(avs);
	if(trim(lbackup23) NEQ ""){
		arrayprepend(arrK,"address");
		avs.address=lbackup23;
	} 
	arrK2=listToArray(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_listing_title_format, ",");
	
	// build description
	for(n=1;n LTE arraylen(arrK2);n++){
		i=arrK2[n];
		if(not structkeyexists(avs, i)){
			continue;
		}
		if(i EQ "remarks"){
			remarkIndex=n;
			if(descriptionLength LT 200){
				ct=lcase(left(avs[i],max(25,min(remainingDescriptionLength,170))));
				if(avs[i] NEQ ""){
					if(len(avs[i]) GT max(25,min(remainingDescriptionLength,170))){
						ct=reverse(ct);
						p=find(" ",ct);
						if(p NEQ 0){
							ct=reverse(removeChars(ct,1,p));
						}
					}
					ct=ucase(left(ct,1))&removeChars(ct,1,1);
					if(len(avs[i]) GT max(25,min(remainingDescriptionLength,170))){
						ct&="...";	
					}
				}
				arrayappend(arrDescription, ct);	
			}
			if(titleLength LT 66){		
				ct=lcase(left(avs[i],max(25,min(remainingTitleLength,66))));
				if(avs[i] NEQ ""){
					if(len(avs[i]) GT max(25,min(remainingTitleLength,66))){
						ct=reverse(ct);
						p=find(" ",ct);
						if(p NEQ 0){
							ct=reverse(removeChars(ct,1,p));
						}
					}
					ct=ucase(left(ct,1))&removeChars(ct,1,1);
					if(len(avs[i]) GT max(25,min(remainingTitleLength,66))){
						ct&="...";	
					}
				}
				arrayappend(arrTitle, ct);
			}
		}else{
			if(descriptionLength LT 150){		
				arrayappend(arrDescription, avs[i]);
			}
			if(titleLength LT 66){		
				arrayappend(arrTitle, avs[i]);
			}
			if(urlLength LT 66){	
				arrayappend(arrURL, avs[i]);	
			}
		}
		if(descriptionLength GTE 150){
			break;
		}
		descriptionLength+=len(arrDescription[arraylen(arrDescription)]);
		titleLength+=len(arrTitle[arraylen(arrTitle)]);
		if(arraylen(arrURL) NEQ 0){
			urlLength+=len(arrURL[arraylen(arrURL)]);
		}
		remainingDescriptionLength=max(0,150-descriptionLength);
		remainingtitleLength=max(0,66-titleLength);
		remainingurlLength=max(0,66-urlLength);
	}
	if(remarkIndex NEQ 0){
		// always put description at the end of the array
		if(arraylen(arrDescription) GTE remarkIndex and arraylen(arrDescription) NEQ remarkIndex){
			arrayappend(arrDescription, arrDescription[remarkIndex]);
			arraydeleteat(arrDescription, remarkIndex);
		}
		if(arraylen(arrTitle) GTE remarkIndex and arraylen(arrTitle) NEQ remarkIndex){
			arrayappend(arrTitle, arrTitle[remarkIndex]);
			arraydeleteat(arrTitle, remarkIndex);
		}
		if(arraylen(arrURL) GTE remarkIndex and arraylen(arrURL) NEQ remarkIndex){
			arrayappend(arrURL, arrURL[remarkIndex]);
			arraydeleteat(arrURL, remarkIndex);
		}
	}
	titleStruct.listing_x_site_description=arraytolist(arrDescription,", ");
	if(structkeyexists(arguments.idx, 'listing_x_site_url') and arguments.idx.listing_x_site_url NEQ ""){
		titleStruct.listing_x_site_url=arguments.idx.listing_x_site_url;
	}else{
		titleStruct.listing_x_site_url=rereplace(application.zcore.functions.zurlencode(arraytolist(arrURL," "),"-"),"-(-*)","-","ALL");
	}
	titleStruct.listing_x_site_title=arraytolist(arrT, ", ");//arraytolist(arrTitle,", ");
	titleStruct.flashTitle=titleStruct.listing_x_site_title;
	titleStruct.title=titleStruct.listing_x_site_title;
	titleStruct.mapTitle=titleStruct.listing_x_site_title;
	titleStruct.urlTitle=titleStruct.listing_x_site_url; 
	titleStruct.propertyType=d2;
	return titleStruct;
	</cfscript>
</cffunction>


<!--- finish converting to do one record at a time, then feed it the args --->
<cffunction name="zListingverifyImage" localmode="modern" output="true" returntype="any">
	<cfargument name="listing_id" type="string" required="yes">
	<cfargument name="listing_photocount" type="string" required="yes">	
	<cfargument name="ignoreExisting" type="boolean" required="no" default="#false#">	
	<cfscript>
	var d='';
	var	imageExt = '.jpg';
	var imagePath='';
	var uploadPath='';
	var uploadThumbPath='';
	for(d=0;d LT arguments.listing_photocount;d=d+1){
		if(d eq 0){
			tick = 'a';
		}else if(d eq 1){
			tick = 'b';
		}else if(d eq 2){
			tick = 'c';
		}else if(d eq 3){
			tick = 'd';
		}else if(d eq 4){
			tick = 'e';
		}else if(d eq 5){
			tick = 'f';
		}else if(d eq 6){
			tick = 'g';
		}else if(d eq 7){
			tick = 'h';
		}else if(d eq 8){
			tick = 'i';
		}else if(d eq 9){
			tick = 'j';
		}else if(d eq 10){
			tick = 'k';
		}else if(d eq 11){
			tick = 'l';
		}else if(d eq 12){
			tick = 'm';
		}else if(d eq 13){
			tick = 'n';
		}else if(d eq 14){
			tick = 'o';
		}else if(d eq 15){
			tick = 'p';
		}else if(d eq 16){
			tick = 'q';
		}else if(d eq 17){
			tick = 'r';
		}else if(d eq 18){
			tick = 's';
		}else if(d eq 19){
			tick = 't';
		}else if(d eq 20){
			tick = 'u';
		}else if(d eq 21){
			tick = 'v';
		}else if(d eq 22){
			tick = 'w';
		}else if(d eq 23){
			tick = 'x';
		}else if(d eq 24){
			tick = 'y';
		}else if(d eq 25){
			tick = 'z';
		}
		imagePath = 'http://photos.neg.ctimls.com/neg/photos/large/#left(right(arguments.listing_id,2),1)#/#right(arguments.listing_id,1)#/#arguments.listing_id##tick#.jpg';
		uploadPath = '#request.zos.globals.homedir#mls/3/images/#arguments.listing_id##tick##imageExt#';
		uploadThumbPath = '#request.zos.globals.homedir#mls/3/images/thumbnails/';
		if(arguments.ignoreExisting EQ false or fileexists(uploadPath) EQ false){
			application.sitestruct[request.zos.globals.id].zrealestate.mls[3].functions.cacheImage(imagePath, uploadPath, uploadThumbPath);
			//writeoutput('download from: #imagePath#<br />');
			//writeoutput('upload to: #uploadPath#<br />');
		}
	}
	</cfscript>
</cffunction>

<cffunction name="zListingcacheImage" localmode="modern" output="true" returntype="any">
	<cfargument name="imagePath"  type="string" required="yes">
	<cfargument name="uploadPath" type="string" required="yes">
	<cfargument name="uploadThumbPath" type="string" required="yes">
    <cfscript>
	var arrFiles=0;
	var cfhttpresult=0;
	</cfscript>
	<cfhttp url="#arguments.imagePath#" result="cfhttpresult" charset="utf-8"></cfhttp>
	<cfif isDefined('cfhttpresult.responseheader.status_code') EQ false or cfhttpresult.responseheader.status_code NEQ '200'>
		<cfscript>
		// do nothing application.zcore.template.fail("CFHTTP request failed: #arguments.imagePath#");
		</cfscript>
	<cfelse>
		<cffile nameconflict="overwrite" action="write" file="#arguments.uploadPath#" output="#cfhttpresult.FileContent#" charset="utf-8">
		<cftry>
		<cfscript>
		// autocrop the thumbnail
		arrFiles = application.zcore.functions.zResizeImage(arguments.uploadPath,arguments.uploadThumbPath,'228x143',true,true);
		return true;
		</cfscript>
		<cfcatch type="any">
		<cfreturn true>
		</cfcatch>
		</cftry>
	</cfif>
</cffunction>

     
     
     

	<cffunction name="getSearchCriteriaDisplay" localmode="modern" output="true" returntype="array">
		<cfargument name="searchStr" type="struct" required="yes">
        <cfargument name="disableLabels" type="boolean" required="no" default="#false#">
       <!---  <cfargument name="useOnlyStruct" type="boolean" required="no" default="#false#"> --->
	<cfscript>
		var db=request.zos.queryObject;
	var local=structnew();
	var	SearchCri=ArrayNew(1);
	var qtab=0;
	var qCity=0;
	var qType=0;
	var arrL=0;
	var s9=structnew();
	var g=0;
	var arrList2=['search_city_id','search_listing_type_id','search_acreage_low','search_acreage_high','search_bedrooms_low','search_bedrooms_high','search_bathrooms_low','search_bathrooms_high','search_sqfoot_low','search_sqfoot_high','search_rate_low','search_zip','search_address','search_rate_high','search_with_photos','search_subdivision','search_frontage','search_view','search_county','search_status','search_style','search_condoname','search_with_pool','search_sort','search_near_address','search_near_coordinates','search_near_radius','search_within_map','search_agent_only','search_office_only','search_subdivision','search_surrounding_cities','search_remarksmatch','search_remarks_negative','search_remarks','search_year_built_low','search_year_built_high','search_listing_sub_type_id','search_result_limit','search_agent_always','search_office_always','search_sort_agent_first','search_sort_office_first','search_result_layout','search_group_by','search_region','search_condition','search_parking','search_tenure','search_liststatus','search_lot_square_feet_low','search_lot_square_feet_high','search_mls_number_list'];
	s9.city="City: ";
	s9.yearBuilt="Year Built: ";
	s9.priceRange="Price Range: ";
	s9.propertyType="Property Type: ";
	s9.county="County: ";
	s9.style="Style: ";
	s9.status="Sale Type: ";
	s9.view="View: ";
	s9.frontage="Frontage: ";
	s9.condoname="Condo name: ";
	s9.streetaddress="Street Address: ";
	s9.zipcode="Zip Code: ";
	s9.remarks="Remarks: ";
	s9.subdivision="Subdivision: ";
	s9.tenure="Land Tenure: ";
	s9.liststatus="List Status: ";
	s9.region="Region: ";
	s9.condition="Condition: ";
	s9.parking="Parking: ";
	
	
	if(arguments.disableLabels){
		for(g in s9){
			s9[g]="";	
		}
	}
	for(g=1;g LTE arraylen(arrList2);g++){
		if(structkeyexists(arguments.searchStr, arrList2[g]) EQ false){
			arguments.searchStr[arrList2[g]]="";
		}
	}
	</cfscript>
	<cfif arguments.searchStr.search_city_id NEQ ''>
		<cfsavecontent variable="db.sql">
		SELECT cast(group_concat(city_name SEPARATOR #db.param(", ")#) AS CHAR) idlist 
		FROM #db.table("city_memory", request.zos.zcoreDatasource)# city 
		WHERE city_id IN (#db.trustedSQL(arguments.searchStr.search_city_id)#) and 
		city_deleted = #db.param(0)#
		</cfsavecontent><cfscript>qCity=db.execute("qCity");
		if(qCity.recordcount NEQ 0){
			ArrayAppend(searchCri,s9.city&qCity.idlist);
		}
		</cfscript>
	</cfif>
	<cfscript>
	if(arguments.searchStr.search_mls_number_list NEQ ""){
		ArrayAppend(searchCri, "MLS ##(s): #arguments.searchStr.search_mls_number_list#");
	}
	if(arguments.searchStr.search_bedrooms_low NEQ '' and arguments.searchStr.search_bedrooms_low NEQ '0'){
		ArrayAppend(SearchCri,arguments.searchStr.search_bedrooms_low&' bed');
	}
	if(arguments.searchStr.search_bathrooms_low NEQ '' and arguments.searchStr.search_bathrooms_low NEQ '0'){
		ArrayAppend(SearchCri,arguments.searchStr.search_bathrooms_low&' bath');
	}
	if(arguments.searchStr.search_sqfoot_low NEQ '' and arguments.searchStr.search_sqfoot_high NEQ '' and arguments.searchStr.search_sqfoot_low NEQ '0' and arguments.searchStr.search_sqfoot_high NEQ '0'){
		ArrayAppend(SearchCri,NumberFormat(arguments.searchStr.search_sqfoot_low)&'-'&NumberFormat(arguments.searchStr.search_sqfoot_high)&' sqft');
	}		
	if(arguments.searchStr.search_lot_square_feet_low NEQ '' and arguments.searchStr.search_lot_square_feet_high NEQ '' and arguments.searchStr.search_lot_square_feet_low NEQ '0' and arguments.searchStr.search_lot_square_feet_high NEQ '0'){
		ArrayAppend(SearchCri,NumberFormat(arguments.searchStr.search_lot_square_feet_low)&'-'&NumberFormat(arguments.searchStr.search_lot_square_feet_high)&' lot sqft');
	}		
	if(arguments.searchStr.search_year_built_low EQ '' or arguments.searchStr.search_year_built_low EQ '0'){
		if(arguments.searchStr.search_year_built_high NEQ '' and arguments.searchStr.search_year_built_high EQ '0'){
			ArrayAppend(SearchCri,s9.yearBuilt&(arguments.searchStr.search_year_built_high)&' or older');
		}
	}else{
		if(arguments.searchStr.search_year_built_high NEQ '' and arguments.searchStr.search_year_built_high NEQ '0'){
			ArrayAppend(SearchCri,s9.yearBuilt&(arguments.searchStr.search_year_built_low)&' to '&(arguments.searchStr.search_year_built_high));
		}else{
			ArrayAppend(SearchCri,s9.yearBuilt&(arguments.searchStr.search_year_built_low)&' or newer');
		}
	}
	// don't search price if default
	if(arguments.searchStr.search_rate_low EQ '' or arguments.searchStr.search_rate_low EQ '0'){
		if(arguments.searchStr.search_rate_high NEQ '' and arguments.searchStr.search_rate_high NEQ '0'){
			ArrayAppend(SearchCri,s9.priceRange&'$'&NumberFormat(arguments.searchStr.search_rate_high)&' or less');
		}
	}else{
		if(arguments.searchStr.search_rate_high NEQ '' and arguments.searchStr.search_rate_high NEQ '0'){
			ArrayAppend(SearchCri,s9.priceRange&'$'&NumberFormat(arguments.searchStr.search_rate_low)&'-$'&NumberFormat(arguments.searchStr.search_rate_high));
			//ArrayAppend(SearchCri,s9.priceRange&'$'&NumberFormat(arguments.searchStr.search_rate_low)&'-$'&NumberFormat(arguments.searchStr.search_rate_high));
		}else{
			ArrayAppend(SearchCri,s9.priceRange&'$'&NumberFormat(arguments.searchStr.search_rate_low)&' or more');
		}
	}
	if(arguments.searchStr.search_listing_type_id NEQ '' and arguments.searchStr.search_listing_type_id NEQ 0){
		arrL=application.zcore.listingCom.listingLookupValueArray("listing_type", arguments.searchStr.search_listing_type_id);
		ArrayAppend(SearchCri,s9.propertyType&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_listing_sub_type_id NEQ '' and arguments.searchStr.search_listing_sub_type_id NEQ 0){
		arrL=application.zcore.listingCom.listingLookupValueArray("listing_sub_type", arguments.searchStr.search_listing_sub_type_id);
		ArrayAppend(SearchCri,s9.propertyType&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_county NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("county", arguments.searchStr.search_county);
		ArrayAppend(SearchCri,s9.county&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_style NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("style", arguments.searchStr.search_style);
		ArrayAppend(SearchCri,s9.style&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_status NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("status", arguments.searchStr.search_status);
		ArrayAppend(SearchCri,s9.status&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_liststatus NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("liststatus", arguments.searchStr.search_liststatus);
		ArrayAppend(SearchCri,s9.liststatus&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_view NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("view", arguments.searchStr.search_view);
		ArrayAppend(SearchCri,s9.view&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_frontage NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("frontage", arguments.searchStr.search_frontage);
		ArrayAppend(SearchCri,s9.frontage&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_region NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("region", arguments.searchStr.search_region);
		ArrayAppend(SearchCri,s9.region&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_condition NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("condition", arguments.searchStr.search_condition);
		ArrayAppend(SearchCri,s9.condition&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_parking NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("parking", arguments.searchStr.search_parking);
		ArrayAppend(SearchCri,s9.parking&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_tenure NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("tenure", arguments.searchStr.search_tenure);
		ArrayAppend(SearchCri,s9.tenure&arraytolist(arrL,", "));
	}
	if(arguments.searchStr.search_liststatus NEQ ''){
		arrL=application.zcore.listingCom.listingLookupValueArray("liststatus", arguments.searchStr.search_liststatus);
		ArrayAppend(SearchCri,s9.liststatus&arraytolist(arrL,", "));
	}
	
	if(arguments.searchStr.search_condoname NEQ ''){
		ArrayAppend(SearchCri,s9.condoname&'"'&arguments.searchStr.search_condoname&'"');
	}
	if(arguments.searchStr.search_address NEQ ''){
		ArrayAppend(SearchCri,s9.streetaddress&'"'&arguments.searchStr.search_address&'"');
	}
	if(arguments.searchStr.search_zip NEQ ''){
		ArrayAppend(SearchCri,s9.zipcode&'"'&arguments.searchStr.search_zip&'"');
	}
	if(arguments.searchStr.search_remarks NEQ ''){
		ArrayAppend(SearchCri,s9.remarks&arguments.searchStr.search_remarks&'');
	}
	if(arguments.searchStr.search_near_address NEQ ''){
		ArrayAppend(SearchCri,'Within #arguments.searchStr.search_near_radius# miles of #arguments.searchStr.search_near_address#');
	}
	if(arguments.searchStr.search_near_coordinates NEQ ''){
		ArrayAppend(SearchCri,'Within #arguments.searchStr.search_near_radius# miles of #arguments.searchStr.search_near_coordinates#');
	}
	if(arguments.searchStr.search_remarks_negative NEQ ''){
		ArrayAppend(SearchCri,'Excluding These Remarks: '&arguments.searchStr.search_remarks_negative);
	}
	if(arguments.searchStr.search_remarksmatch NEQ ''){
		ArrayAppend(SearchCri,s9.remarks&arguments.searchStr.search_remarksmatch);
	}
	if(arguments.searchStr.search_result_limit NEQ 0 and arguments.searchStr.search_result_limit NEQ ''){
		ArrayAppend(SearchCri,arguments.searchStr.search_result_limit&" results per page");
	}
	if(arguments.searchStr.search_agent_always EQ '1'){
		ArrayAppend(SearchCri,"Always show agent listings");
	}
	if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_sort_agent_top NEQ 1){
		if(arguments.searchStr.search_sort_agent_first EQ '1'){
			ArrayAppend(SearchCri,"agent listings sorted to top");
		}
	}
	if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_sort_office_top NEQ 1){
		if(arguments.searchStr.search_sort_office_first EQ '1'){
			ArrayAppend(SearchCri,"Office listings sorted to top");
		}
	}
	if(arguments.searchStr.search_office_always EQ '1'){
		ArrayAppend(SearchCri,"Always show office listings");
	}



	/*if(arguments.searchStr.search_new_first EQ '1'){
		ArrayAppend(SearchCri,'new listings first');
	}*/
	if(arguments.searchStr.search_surrounding_cities EQ '1'){
		ArrayAppend(SearchCri,'Including surrounding cities ');
	}
	if(arguments.searchStr.search_subdivision NEQ ''){
		ArrayAppend(SearchCri,s9.subdivision&arguments.searchStr.search_subdivision);
	}
	if(arguments.searchStr.search_sort EQ "newfirst"){
		ArrayAppend(SearchCri,"Sorted By: Newest listings first");
	}else if(arguments.searchStr.search_sort EQ "pricedesc"){
		ArrayAppend(SearchCri,"Sorted By: Price descending");
	}else if(arguments.searchStr.search_sort EQ "sortppsqftasc"){
	 	ArrayAppend(SearchCri,"Sorted By: Price/SQFT ascending");
	}else if(arguments.searchStr.search_sort EQ "sortppsqftdesc"){
	 	ArrayAppend(SearchCri,"Sorted By: Price/SQFT descending");
	}else{
		ArrayAppend(SearchCri,"Sorted By: Price ascending");
	}
	if(arguments.searchStr.search_result_layout EQ "0"){
		ArrayAppend(SearchCri,"Detail layout");
	}else if(arguments.searchStr.search_result_layout EQ "1"){
		ArrayAppend(SearchCri,"One Line layout");
	}else if(arguments.searchStr.search_result_layout EQ "2"){
	 	ArrayAppend(SearchCri,"Thumbnail layout");
	}
	if(arguments.searchStr.search_group_by EQ "1"){
		ArrayAppend(SearchCri,"Group by bedrooms");
	}
	if(arguments.searchStr.search_agent_only EQ 1){
		ArrayAppend(SearchCri,' Only this agent''s listings');
	}
	if(arguments.searchStr.search_office_only EQ 1){
		ArrayAppend(SearchCri,' Only this office''s listings');
	}
	
	if(arguments.searchStr.search_with_photos EQ 1){
		ArrayAppend(SearchCri,' Must have a photo');
	}
	if(arguments.searchStr.search_with_pool EQ 1){
		ArrayAppend(SearchCri,' Must have a pool');
	}
	if(arguments.searchStr.search_within_map EQ 1){
		ArrayAppend(SearchCri,' Search within map area only');
	}
	return searchcri;
	</cfscript>
	</cffunction>
	
	
<cffunction name="savedSearchQueryToStruct" localmode="modern" output="true" returntype="struct">
	<cfargument name="qSearch" type="query" required="yes">
	<cfargument name="currentrow" type="numeric" required="yes"> 
	<cfscript>
	var db=request.zos.queryObject;
	var local=structnew();
	var i="";
	var searchStr=StructNew(); 
        application.zcore.functions.zQueryToStruct(arguments.qSearch, searchStr, "", arguments.currentrow);
        for(i in searchStr){
            if(searchStr[i] EQ '0'){
                searchStr[i]='';
            }
        }
        if(searchStr.search_rate_low NEQ "" or searchStr.search_rate_high NEQ ""){
            searchStr.search_rate_low=application.zcore.functions.zso(searchStr, 'search_rate_low',true);
            searchStr.search_rate_high=application.zcore.functions.zso(searchStr, 'search_rate_high',true);	
	    if(searchStr.search_rate_high LT searchStr.search_rate_low){
		    structdelete(searchStr, 'search_rate_high');
	    }
        }
        if(searchStr.search_acreage_low NEQ "" or searchStr.search_acreage_high NEQ ""){
            searchStr.search_acreage_low=application.zcore.functions.zso(searchStr, 'search_acreage_low',true);
            searchStr.search_acreage_high=application.zcore.functions.zso(searchStr, 'search_acreage_high',true);
	    if(searchStr.search_acreage_high LT searchStr.search_acreage_low){
		    structdelete(searchStr, 'search_acreage_high');
	    }
        }
        if(searchStr.search_sqfoot_low NEQ "" or searchStr.search_sqfoot_high NEQ ""){
            searchStr.search_sqfoot_low=application.zcore.functions.zso(searchStr, 'search_sqfoot_low',true);
            searchStr.search_sqfoot_high=application.zcore.functions.zso(searchStr, 'search_sqfoot_high',true);
	    if(searchStr.search_sqfoot_high LT searchStr.search_sqfoot_low){
		    structdelete(searchStr, 'search_sqfoot_high');
	    }
        }
        if(searchStr.search_lot_square_feet_low NEQ "" or searchStr.search_lot_square_feet_high NEQ ""){
            searchStr.search_lot_square_feet_low=application.zcore.functions.zso(searchStr, 'search_lot_square_feet_low',true);
            searchStr.search_lot_square_feet_high=application.zcore.functions.zso(searchStr, 'search_lot_square_feet_high',true);
	    if(searchStr.search_lot_square_feet_high LT searchStr.search_lot_square_feet_low){
		    structdelete(searchStr, 'search_lot_square_feet_high');
	    }
        }
        if(searchStr.search_within_map NEQ '1'){
            searchStr.search_within_map=0;
        }
        if(searchStr.search_with_pool NEQ '1'){
            searchStr.search_with_pool=0;
        }
        if(searchStr.search_with_photos NEQ '1'){
            searchStr.search_with_photos=0;
        }
        if(searchStr.search_agent_only NEQ '1'){
            searchStr.search_agent_only=0;
        }
        if(searchStr.search_office_only NEQ '1'){
            searchStr.search_office_only=0;
        }
        if(structkeyexists(searchStr, 'search_new_first') and searchStr.search_new_first NEQ '1'){
            searchStr.search_new_first=0;
        }
        if(structkeyexists(searchStr, 'search_surrounding_cities') and searchStr.search_surrounding_cities NEQ '1'){
            searchStr.search_surrounding_cities=0;
        }
        if(searchStr.saved_search_format NEQ '1'){
            searchStr.saved_search_format=0;
        }
        if(searchStr.saved_search_frequency NEQ '1'){
            searchStr.saved_search_frequency=0;
        }
        if(searchStr.search_map_coordinates_list EQ ''){
            searchStr.search_within_map=0;
        } 
        return searchStr;	
        </cfscript> 
</cffunction>

<cffunction name="getSimilarListings" localmode="modern" access="public">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var  propertyHTML="";
	var  searchId=application.zcore.status.getNewId();
	var propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	var ts18972 = StructNew();
	form.zindex=1;
	ts18972.offset = 0;
	ts18972.forceSimpleLimit=true;
	ts18972.distance = 10; // in miles
	ts18972.disableCount=true;
	ts18972.searchCriteria=structnew();
	
	local.criteria=structnew();
	if(arguments.idx.listing_price GT 100){
		local.criteria.search_rate_low=round(arguments.idx.listing_price*.90);
		local.criteria.search_rate_high=round(arguments.idx.listing_price*1.10);
	}
	local.criteria.search_subdivision=application.zcore.functions.zso(arguments.idx, 'search_subdivision');
	local.criteria.search_bedrooms_low=arguments.idx.listing_beds;
	local.criteria.search_bedrooms_high=arguments.idx.listing_beds;
	local.criteria.search_bathrooms_low=arguments.idx.listing_baths;
	local.criteria.search_bathrooms_high=arguments.idx.listing_baths;
	local.criteria.search_city_id=arguments.idx.listing_city;
	local.criteria.search_listing_type_id=arguments.idx.listing_type_id;
	//local.criteria.search_listing_sub_type_id=arguments.idx.listing_sub_type_id; 
	local.criteria.search_result_layout=2;
	
	request.zos.listing.functions.zMLSSetSearchStruct(ts18972.searchcriteria, local.criteria);  
	ts18972.perpage =4;
	ts18972.searchCriteria.search_result_limit = 4; 
	request.zMLSSearchOptionsDisplaySearchId=searchId;
	application.zcore.status.setStatus(searchId,false,ts18972.searchcriteria);
	if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
		ts18972.debug=true; 
	}else{
		ts18972.debug=false;
	}
	ts18972.arrExcludeMLSPID=[arguments.idx.listing_id]; 
	var returnStruct = propertyDataCom.getProperties(ts18972); 
	if(returnStruct.count NEQ 0){	
		var propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
		
		ts18972 = StructNew();
		returnStruct.perpage=3;
		ts18972.dataStruct = returnStruct;
		ts18972.search_result_layout=2; 
		
		if(structkeyexists(ts18972,'search_result_layout') and ts18972.search_result_layout EQ 2){
			ts18972.getDetails=false;
		}
		propDisplayCom.init(ts18972);
		propertyHTML=propDisplayCom.display();
	} 
	local.moreLink="";
	if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_search',true) EQ 0){
		if(returnstruct.count GT returnstruct.perpage){
			local.moreLink=application.zcore.functions.zblockurl(request.zos.listing.functions.getSearchFormLink()&'?searchId=#searchId#&amp;zIndex=1');
		}
	}
	return {
		output:propertyHTML, 
		count=returnstruct.count,
		moreLink:local.moreLink
	};
	</cfscript>
</cffunction>

<cffunction name="hasSavedSearches" localmode="modern" returntype="boolean" access="public">
	<cfscript>
	var db=request.zos.queryObject;
	local.email="";
	if(structkeyexists(request.zsession,'inquiries_email')){
		local.email=request.zsession.inquiries_email;
	}else if(application.zcore.user.checkGroupAccess("user")){
		local.email=request.zsession.user.email;
	}
	if(local.email EQ ""){
		return false;
	}else{
		db.sql="select count(mls_saved_search_id) count from #db.table("mls_saved_search", request.zos.zcoreDatasource)# 
		WHERE saved_search_email = #db.param(local.email)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		mls_saved_search_deleted = #db.param(0)#";
		local.qSaved=db.execute("qSaved");
		if(local.qSaved.count){
			return true;
		}else{
			return false;
		}
	}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>