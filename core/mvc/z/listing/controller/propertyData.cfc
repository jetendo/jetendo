<cfcomponent displayname="propertyData.cfc">
<cfoutput>	<cfscript>
	this.disabledSearchCriteria=structnew();
	this.searchCriteria=structnew();
	this.defaultSearchCriteria=structnew(); 
    this.defaultSearchCriteria.search_bathrooms_high=20;
    this.defaultSearchCriteria.search_bathrooms_low=0;
	this.defaultSearchCriteria.search_year_built_low=0;
    this.defaultSearchCriteria.search_year_built_high=year(now())+3;
    this.defaultSearchCriteria.search_bathrooms_low=0;
    this.defaultSearchCriteria.search_bedrooms_high=20;
    this.defaultSearchCriteria.search_bedrooms_low=0;
	this.defaultSearchCriteria.search_lot_square_feet_low=0;
	this.defaultSearchCriteria.search_lot_square_feet_high=100000;
    this.defaultSearchCriteria.search_result_layout=0;
    this.defaultSearchCriteria.search_rate_low=0;  
	this.defaultSearchCriteria.search_result_limit=0;
	this.defaultSearchCriteria.search_group_by=0;
	this.defaultSearchCriteria.search_agent_always=0;
	this.defaultSearchCriteria.search_sort_agent_first=0;
	this.defaultSearchCriteria.search_office_always=0;
	this.defaultSearchCriteria.search_sort_office_first=0;
    this.defaultSearchCriteria.search_rate_high=100000000;  
    this.defaultSearchCriteria.search_sqfoot_high=65535;
    this.defaultSearchCriteria.search_sqfoot_low=0;
    this.defaultSearchCriteria.search_acreage_high=255;
    this.defaultSearchCriteria.search_acreage_low=0; 
    this.defaultSearchCriteria.search_WITHIN_MAP=0;
    this.defaultSearchCriteria.search_WITH_PHOTOS=0;  
    this.defaultSearchCriteria.search_WITH_POOL=0;   
    this.defaultSearchCriteria.search_surrounding_cities=0;
   // this.defaultSearchCriteria.search_exact_match=0;
	this.defaultSearchCriteria.search_office_only=false;
	this.defaultSearchCriteria.search_agent_only=false;
	this.defaultSearchCriteria.search_near_radius=0;
	this.searchCriteriaSet=false;
	this.enableFiltering=false;
	this.enableListingTrack=true;
	this.ignoreFieldStruct={search_sort=true,search_lot_square_feet_high=true,search_sqfoot_high=true,search_rate_high=true,search_acreage_high=true,search_bedrooms_high=true,search_bathrooms_high=true,search_year_built_high=true};
	this.rangeFieldStruct={search_sqfoot_low="search_sqfoot_high",search_lot_square_feet_low="search_lot_square_feet_high",search_rate_low="search_rate_high",search_acreage_low="search_acreage_high",search_bedrooms_low="search_bedrooms_high",search_bathrooms_low="search_bathrooms_high",search_year_built_low="search_year_built_high"};
	</cfscript>
<cffunction name="disableSearchCriteria" localmode="modern" output="no" returntype="any">
	<cfscript>
	this.disabledSearchCriteria=duplicate(this.searchCriteria);
	this.setSearchCriteria(this.defaultSearchCriteria);
	</cfscript>
</cffunction>
<cffunction name="enableSearchCriteria" localmode="modern" output="no" returntype="any">
	<cfscript>
	this.searchCriteria=duplicate(this.disabledSearchCriteria);
	this.disabledSearchCriteria=structnew();
	</cfscript>
</cffunction>
<cffunction name="setSearchCriteria" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var matchstring=0;
	var booleanmode=0;
	var remarksMatchList="";
	var sc3=structnew();
	var sc2=structnew();
	var sc4=structnew();
	var sc5=structnew();
	var sc6=structnew();
	var sc8=structnew();
	var sc7=structnew();
	var sc9=structnew();
	var arrd=0;
	var a2=[];
	var mAIstruct=0;
	var i2=0;
	var arrS=0;
	var arrI=0;
	var arrP=0;
	var i=0;
	var combineSQL="or";
	if(this.enableFiltering){
		combineSQL="and";	
	}
	if (IsDefined("request.zos.listing.arrSearchFields") EQ False){
		request.zos.listing.arrSearchFields = StructNew();
	}
	this.arrSearchFields=request.zos.listing.arrSearchFields;
	this.arrShortSearchFields=request.zos.listing.arrShortSearchFields;
	this.searchCriteriaSet=true;
    sc3.search_city_id="";
    sc3.search_listing_type_id="";
	sc3.search_zip="";
	sc3.search_county="";
	sc3.search_region="";
	sc3.search_parking="";
	sc3.search_condition="";
	sc3.search_liststatus="";
	sc3.search_tenure="";
	//sc6.search_agent="";
    //sc6.search_office="";
	sc6.search_listdate="";
	sc6.search_list_date="";
	sc6.search_max_list_date="";
	sc6.search_style="";
	sc6.search_listing_sub_type_id="";
	sc6.search_view="";
	sc6.search_frontage="";
	sc6.search_condoname="";
	//sc6.search_zip="";
	sc6.search_address="";
	sc6.search_zip="";
	sc6.search_mls_number_list="";
	sc6.search_status="";
	sc9.search_agent="listing_agent";
	sc9.search_office="listing_office";
	sc6.search_remarks="";
	sc6.search_remarks_negative="";
    sc6.search_subdivision="";
	
	sc5.search_condoname="listing_condoname"; 
	sc5.search_address="REPLACE(REPLACE(REPLACE(listing_address,'    ','   '),'   ','  '),'  ',' ')"; 
	sc4.search_style="listing_style";
	sc4.search_view="listing_view";
	sc4.search_frontage="listing_frontage";
	sc4.search_status="listing_status";
    	sc4.search_listing_sub_type_id="listing_sub_type_id";
    sc5.search_subdivision="listing_subdivision";
	sc7.search_remarks_negative="listing_data_remarks";
	sc8.search_remarks="listing_data_remarks";
	
	sc2.search_sort="priceasc"; 
	sc2.search_near_address="";
	sc2.search_near_coordinates="";
	sc2.search_near_radius="";
	sc2.search_new_first=false;
	sc2.search_list_date="";
	sc2.search_max_list_date="";
	sc2.search_office_only=false;
	sc2.search_agent_only=false;
    sc2.search_MAP_COORDINATES_LIST="";
	
	this.searchCriteria=duplicate(arguments.ss);//,true);
	structappend(this.searchCriteria,this.defaultSearchCriteria,false);
	for(i in this.defaultSearchCriteria){
		if(isNumeric(this.searchCriteria[i]) EQ false){
			this.searchCriteria[i]=this.defaultSearchCriteria[i];	
		}
	}
	for(i in sc2){
		sc2[i]=application.zcore.functions.zescape(sc2[i]);	
	}
	for(i in sc6){
		sc6[i]=application.zcore.functions.zescape(sc6[i]);	
	}
	structappend(this.searchCriteria,sc2,false);
	structappend(this.searchCriteria,sc3,false);
	structappend(this.searchCriteria,sc6,false);
	if(request.zos.zListingShowSoldData EQ false){
		this.searchCriteria.search_liststatus='1,4,7,16';	
	}
	if(this.searchCriteria.search_listdate NEQ ""){
		this.searchCriteria.search_listdate=urldecode(this.searchCriteria.search_listdate);
	}
	this.searchCriteriaBackup=duplicate(this.searchCriteria);
	this.searchContentCriteria=duplicate(this.searchCriteria);
	for(i in sc4){
		if(this.searchCriteria[i] NEQ ""){
			a2=listtoarray(replace(replace(this.searchCriteria[i],"\","\\","ALL"),"'",'"',"ALL"),',',false);
			this.searchCriteria[i]="#sc4[i]# like '%,"&arraytolist(a2,",%' #combineSQL# #sc4[i]# like '%,")&",%'";
		}
	}
	for(i in sc5){
		if(this.searchCriteria[i] NEQ ""){
			a2=listtoarray(replace(replace(replace(this.searchCriteria[i],"\","\\","ALL"),"'","\'","ALL"),'"',' ',"ALL"),',',false);
			this.searchCriteria[i]="#sc5[i]# like '%"&arraytolist(a2,"%' #combineSQL# #sc5[i]# like '%")&"%'";
		}
	}
	for(i in sc9){
		// doesn't need to be in content criteria
		if(structkeyexists(this.searchCriteria,i) and this.searchCriteria[i] NEQ ""){
			mAIstruct=structnew();
			arrP=listtoarray(replace(mid(this.searchCriteria[i],2,len(this.searchCriteria[i])-2),"'","","ALL"),',');
			arrS=arraynew(1);
			for(i2=1;i2 LTE arraylen(arrP);i2++){
				arrI=listtoarray(arrP[i2],'-');
				if(arraylen(arrI) EQ 2){
					arrayappend(arrS,"( listing_mls_id='"&application.zcore.functions.zescape(arrI[1])&"' and `#sc9[i]#` = '"&application.zcore.functions.zescape(arrI[2])&"')");
				}
			}
			this.searchCriteria[i]=arraytolist(arrS,' #combineSQL# ');
		}
	}
	if(application.zcore.functions.zso(form, 'search_surrounding_cities') EQ 1){
		this.searchCriteria.search_surrounding_cities=1;
	}
	matchString="";
	booleanMode="";
	
	// always search active if not selected
	if(this.searchCriteria.search_liststatus EQ ""){
		this.searchCriteria.search_liststatus="1";
	} 
	for(i in sc3){
		if(this.searchCriteria[i] NEQ ""){
			this.searchCriteria[i]="'"&replace(application.zcore.functions.zescape(this.searchCriteria[i]), ",","','","ALL")&"'";
			this.searchContentCriteria[i]=this.searchCriteria[i];
		}
	}
	if(this.searchCriteria.search_result_limit LTE 8){
		this.searchCriteria.search_result_limit=10;
	}

	search_result_layout=application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_list_layout;
	if(search_result_layout EQ 2 and application.zcore.functions.zso(this.searchCriteria, "search_result_limit", true, 10) EQ 10){
		this.searchCriteria.search_result_limit=9;  
	}
	</cfscript>
</cffunction>
<cffunction name="getProperties" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
    var start48=gettickcount(); 
	var nowDate=request.zos.mysqlnow; 
    var ts=StructNew();
	var rs=structnew();
	var parentCity="";
	var listingDataTable=false; 
	var db=request.zos.queryObject; 
	var listingTrackTable=false;
	var db2=request.zos.noVerifyQueryObject;


	listingSharedData=application.zcore.app.getAppData("listing");

	if(not structkeyexists(request.zos, 'arrListingsDisplayed')){
		request.zos.arrListingsDisplayed=[];
	}
   	errorMessage="";
	application.zcore.functions.zNoCache();

	ts.requireValidCoordinates=false;
	ts.removeValues="";
	ts.zReturnLookupQuery=false;
	ts.lookupName="";
	ts.returnWhereSQLOnly=false;
	ts.contentTableEnabled=true;
	ts.forceSimpleLimit=false;	
	ts.enableThreading=false;
	ts.searchCriteria=structnew();
    ts.noCityTable=true;
	ts.useMlsCopy=false;
	ts.tempWhere="";
    ts.debug=false;
    ts.offset = 0;
	ts.onlyCount=false;
	ts.zReturnSimpleQuery=false;
	ts.disableCount=false;
    ts.perpage = 10;
	ts.arrExcludeContentId=arraynew(1);
    ts.distance = 30;
	ts.zhaving="";
	ts.zselect="";
    ts.zwhere="";
    ts.zgroupby="";
    ts.zorderby="";
	ts.zlimit="";
	ts.zunion="";
	ts.zleftjoin="";
	ts.searchMapCoordinates=structnew();
	ts.checkSearchCountCache=false;
    StructAppend(arguments.ss, ts, false);
	if(arguments.ss.contentTableEnabled and request.cgi_script_name EQ '/z/listing/property/detail/index'){
		arguments.ss.contentTableEnabled=false;	
	}
	if(structcount(arguments.ss.searchCriteria) NEQ 0){
		this.setSearchCriteria(arguments.ss.searchCriteria);	
	}else if(this.searchCriteriaSet EQ false){
		this.setSearchCriteria(structnew());	
	}
	if(this.searchCriteria.search_city_id NEQ ""){
		parentCity=listgetat(this.searchCriteria.search_city_id,1,",");
		parentCity=mid(parentCity,2,len(parentCity)-2);
        arguments.ss.noCityTable=false;
	}
    if(arguments.ss.offset EQ ''){
        arguments.ss.offset=0;
    }
	if(arguments.ss.offset GT 100 and structkeyexists(request,'forceHighOffset') EQ false){
		application.zcore.functions.z404('Property search greater then 100 offset is not allowed unless request.forceHighOffset=true.');
	}
    if(arguments.ss.perpage EQ ''){
        arguments.ss.perpage=0;
    } 
    zo=application.zcore.functions.zo; 
if(this.searchCriteria.search_list_date NEQ "" or this.searchCriteria.search_max_list_date NEQ ""){
	listingTrackTable=true;
}
if(this.searchCriteria.search_listdate NEQ "" and this.searchCriteria.search_listdate NEQ "Show All" and this.searchCriteria.search_list_date EQ ""){
	listingTrackTable=true;
	if(this.searchCriteria.search_listdate EQ "New"){
		oldDate=dateadd("d",-3,now());
		this.searchCriteria.search_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
		this.searchCriteria.search_max_list_date=dateformat(now(),"yyyy-mm-dd 23:59:59");
	}else if(this.searchCriteria.search_listdate EQ "Up to 3 days old"){
		oldDate=dateadd("d",-7,now());
		this.searchCriteria.search_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
		oldDate=dateadd("d",-3,now());
		this.searchCriteria.search_max_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
	}else if(this.searchCriteria.search_listdate EQ "Up to 1 week old"){
		oldDate=dateadd("d",-14,now());
		this.searchCriteria.search_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
		oldDate=dateadd("d",-7,now());
		this.searchCriteria.search_max_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
	}else if(this.searchCriteria.search_listdate EQ "Up to 2 weeks old"){
		oldDate=dateadd("m",-1,now());
		this.searchCriteria.search_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
		oldDate=dateadd("d",-14,now());
		this.searchCriteria.search_max_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
	}else if(this.searchCriteria.search_listdate EQ "Up to 1 month old"){
		oldDate=dateadd("m",-3,now());
		this.searchCriteria.search_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
		oldDate=dateadd("m",-1,now());
		this.searchCriteria.search_max_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
	}else if(this.searchCriteria.search_listdate EQ "Up to 3 months old"){
		oldDate=dateadd("m",-6,now());
		this.searchCriteria.search_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
		oldDate=dateadd("m",-3,now());
		this.searchCriteria.search_max_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
	}else if(this.searchCriteria.search_listdate EQ "Up to 6 months old"){
		oldDate=dateadd("m",-12,now());
		this.searchCriteria.search_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
		oldDate=dateadd("m",-6,now());
		this.searchCriteria.search_max_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
	}else if(this.searchCriteria.search_listdate EQ "Up to 12 months old"){
		oldDate=dateadd("m",-100,now());
		this.searchCriteria.search_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
		oldDate=dateadd("m",-12,now());
		this.searchCriteria.search_max_list_date=dateformat(oldDate,"yyyy-mm-dd ")&timeformat(oldDate,"HH:mm:ss");
	}else{
		// ignore
	}
}


	if(isnumeric(this.searchCriteria.search_result_limit) EQ false){
		writeoutput('Invalid Request');application.zcore.functions.zabort();	
	}
    </cfscript>
    
    
    
    <cfif arguments.ss.noCityTable EQ false>
        <cfif this.searchCriteria.search_city_id NEQ "" and this.searchCriteria.search_surrounding_cities EQ 1>
        	<cfscript>
			c=listgetat(this.searchCriteria.search_city_id,1);
			c=mid(c,2,len(c)-2);
			</cfscript>
            <cfsavecontent variable="db.sql">
            select #db.trustedSQL("cast(concat(""'"",group_concat(city_id SEPARATOR ""','""),""'"") AS CHAR) idlist ")#
			FROM  #db.table("city_distance_memory", request.zos.zcoreDatasource)# city_distance 
			WHERE city_parent_id = #db.param(c)# and 
			city_distance < #db.param(arguments.ss.distance)# and 
			city_distance_deleted = #db.param(0)# and 
			city_id NOT IN (#db.trustedSQL("'#listingSharedData.sharedStruct.optionStruct.mls_option_exclude_city_list#'")#) 
            
           </cfsavecontent><cfscript>qC=db.execute("qC");
		   if(qC.recordcount NEQ 0 and qC.idlist NEQ ""){
		   		this.searchCriteria["search_city_id"]=qC.idlist;
		   } 
		   </cfscript>
       </cfif>
    </cfif>
        
    <cfsavecontent variable="whereSQL">
        
    WHERE 
 	
<cfif this.searchCriteria.search_agent_always EQ 1 or this.searchCriteria.search_office_always EQ 1>
(
</cfif>
(
    
    <cfif structkeyexists(arguments.ss,'listingOfficeSearch') and ss.listingOfficeSearch NEQ ""> 
    listing.listing_office IN ('#replace(arguments.ss.listingOfficeSearch,",","','","ALL")#') and
	</cfif>
      
    <cfif listingSharedData.sharedStruct.optionStruct.mls_option_exclude_city_list NEQ ""> listing_city NOT IN ('#listingSharedData.sharedStruct.optionStruct.mls_option_exclude_city_list#') AND </cfif>
    
    <cfscript>
	
	if(this.searchCriteria.search_mls_number_list NEQ ""){
		arrId=listtoarray(this.searchCriteria.search_mls_number_list, ",", false);
		arguments.ss.arrMLSPID=arraynew(1);
		for(i=1;i LTE arraylen(arrId);i++){
			for(i654 in listingSharedData.sharedStruct.mlsStruct){
				arrayappend(arguments.ss.arrMLSPID, i654&"-"&trim(arrId[i]));
			}
			
			for(i654 in listingSharedData.sharedStruct.mlsStruct){
				arrId[i]=rereplace(arrId[i],"[a-zA-Z]*","","all");
				arrayappend(arguments.ss.arrMLSPID, i654&"-"&trim(arrId[i]));
			}
		}
	}
	</cfscript>
    <cfif structkeyexists(arguments.ss,'arrExcludeMLSPID')>
        <cfif ArrayLen(arguments.ss.arrExcludeMLSPID) NEQ 0>
            <cfscript>
            for(n=1;n LTE ArrayLen(arguments.ss.arrExcludeMLSPID);n=n+1){
				arguments.ss.arrExcludeMLSPID[n]=application.zcore.functions.zescape(trim(arguments.ss.arrExcludeMLSPID[n]));
            }
            writeoutput(" listing.listing_id NOT IN ('#arraytolist(arguments.ss.arrExcludeMLSPID,"','")#')");
            </cfscript>
             and
        <cfelse>
             1 = 0  and
        </cfif>
    </cfif>
    
    <cfif structkeyexists(arguments.ss,'arrMLSPID')>
        <cfif ArrayLen(arguments.ss.arrMLSPID) NEQ 0>
            <cfscript>

            hideStruct={}
            if(structkeyexists(request.zos, 'arrListingsDisplayed')){
            	for(n=1;n<=arraylen(request.zos.arrListingsDisplayed);n++){
            		hideStruct[request.zos.arrListingsDisplayed[n]]=true;
            	}
            }
            for(n=1;n LTE ArrayLen(arguments.ss.arrMLSPID);n=n+1){
				arguments.ss.arrMLSPID[n]=application.zcore.functions.zescape(trim(arguments.ss.arrMLSPID[n]));
				
				structdelete(hideStruct, arguments.ss.arrMLSPID[n]);
            }
            request.zos.arrListingsDisplayed=structkeyarray(hideStruct);
            writeoutput(" listing.listing_id IN ('#arraytolist(arguments.ss.arrMLSPID,"','")#')");
            </cfscript>
             and
        <cfelse>
             1 = 0  and
        </cfif>
    </cfif>
    <cfif arguments.ss.noCityTable EQ false>
        <cfif this.searchCriteria.search_city_id EQ "" or structkeyexists(arguments.ss,'arrMLSPID')>
        <cfelse> 
        listing.listing_city IN (#this.searchCriteria.search_city_id#) and  
        </cfif>
    </cfif> 
        #application.zcore.listingCom.getMLSIDWhereSQL("listing")#
    
        <cfif this.searchCriteria.search_rate_low NEQ this.defaultSearchCriteria.search_rate_low or this.searchCriteria.search_rate_high NEQ this.defaultSearchCriteria.search_rate_high>
        and (listing_price BETWEEN #application.zcore.functions.zescape(this.searchCriteria.search_rate_low)# AND #application.zcore.functions.zescape(this.searchCriteria.search_rate_high)#)
        </cfif>
        <cfif this.searchCriteria.search_sqfoot_low NEQ this.defaultSearchCriteria.search_sqfoot_low or this.searchCriteria.search_sqfoot_high NEQ this.defaultSearchCriteria.search_sqfoot_high>
        and listing_square_feet BETWEEN #application.zcore.functions.zescape(this.searchCriteria.search_sqfoot_low)# AND #application.zcore.functions.zescape(this.searchCriteria.search_sqfoot_high)#
        </cfif>
        <cfif this.searchCriteria.search_lot_square_feet_low NEQ this.defaultSearchCriteria.search_lot_square_feet_low or this.searchCriteria.search_lot_square_feet_high NEQ this.defaultSearchCriteria.search_lot_square_feet_high>
        and listing_square_feet BETWEEN #application.zcore.functions.zescape(this.searchCriteria.search_lot_square_feet_low)# AND #application.zcore.functions.zescape(this.searchCriteria.search_lot_square_feet_high)#
        </cfif>
        
        <cfif this.searchCriteria.search_acreage_low NEQ this.defaultSearchCriteria.search_acreage_low or this.searchCriteria.search_acreage_high NEQ this.defaultSearchCriteria.search_acreage_high>
        and listing_acreage BETWEEN #application.zcore.functions.zescape(this.searchCriteria.search_acreage_low)# AND #application.zcore.functions.zescape(this.searchCriteria.search_acreage_high)#
        </cfif>
        <cfif this.searchCriteria.search_year_built_low NEQ this.defaultSearchCriteria.search_year_built_low or this.searchCriteria.search_year_built_high NEQ this.defaultSearchCriteria.search_year_built_high>
        and listing_year_built BETWEEN #application.zcore.functions.zescape(this.searchCriteria.search_year_built_low)# AND #application.zcore.functions.zescape(this.searchCriteria.search_year_built_high)#
        </cfif>
        <cfif this.searchCriteria.search_bedrooms_low NEQ this.defaultSearchCriteria.search_bedrooms_low or this.searchCriteria.search_bedrooms_high NEQ this.defaultSearchCriteria.search_bedrooms_high>
        and listing_beds BETWEEN #application.zcore.functions.zescape(this.searchCriteria.search_bedrooms_low)# and #application.zcore.functions.zescape(this.searchCriteria.search_bedrooms_high)#
        </cfif>
        <cfif this.searchCriteria.search_bathrooms_low NEQ this.defaultSearchCriteria.search_bathrooms_low or this.searchCriteria.search_bathrooms_high NEQ this.defaultSearchCriteria.search_bathrooms_high>
        and listing_baths BETWEEN #application.zcore.functions.zescape(this.searchCriteria.search_bathrooms_low)# and #application.zcore.functions.zescape(this.searchCriteria.search_bathrooms_high)#
        </cfif>
        
        <cfif arraylen(request.zos.arrListingsDisplayed)>
			and listing.listing_id NOT IN ('#arraytoList(request.zos.arrListingsDisplayed, "','")#')  
		</cfif>
        
        <cfif this.searchCriteria.search_county NEQ "">
            and listing_county IN (#this.searchCriteria.search_county#)
        </cfif>
        <cfif this.searchCriteria.search_frontage NEQ "">
            and (#this.searchCriteria.search_frontage#)
        </cfif>
        <cfif this.searchCriteria.search_status NEQ "">
            and (#this.searchCriteria.search_status#)
        </cfif>
        <cfif this.searchCriteria.search_liststatus NEQ "">
            and listing_liststatus IN (#this.searchCriteria.search_liststatus#)
        </cfif>
        <cfif this.searchCriteria.search_style NEQ "">
            and (#this.searchCriteria.search_style#)
        </cfif>
        <cfif this.searchCriteria.search_view NEQ "">
            and (#this.searchCriteria.search_view#)
        </cfif>
        <cfif this.searchCriteria.search_listing_sub_type_id NEQ "">
        	and (#this.searchCriteria.search_listing_sub_type_id#)
        </cfif>
		<cfif structkeyexists(this.searchCriteria,'search_agent') and this.searchCriteria.search_agent NEQ "">
            and (#this.searchCriteria.search_agent#)
        </cfif>
        <cfif structkeyexists(this.searchCriteria,'search_office') and this.searchCriteria.search_office NEQ "">
           and (#this.searchCriteria.search_office#)
        </cfif> 
        
        <cfif this.searchCriteria.search_listing_type_id NEQ "">
        and listing.listing_type_id IN (#this.searchCriteria.search_listing_type_id#)
        </cfif>
        <cfif this.searchCriteria.search_region NEQ "">
        and listing.listing_region IN (#this.searchCriteria.search_region#)
        </cfif>
        <cfif this.searchCriteria.search_parking NEQ "">
        and listing.listing_parking IN (#this.searchCriteria.search_parking#)
        </cfif>
        <cfif this.searchCriteria.search_condition NEQ "">
        and listing.listing_condition IN (#this.searchCriteria.search_condition#)
        </cfif>
        <cfif this.searchCriteria.search_tenure NEQ "">
        and listing.listing_tenure IN (#this.searchCriteria.search_tenure#)
        </cfif>
        
        
        <cfif structkeyexists(this.searchCriteria,'search_harborOnly')>
        and (listing_subdivision like '%harbour%')
        </cfif>
        <cfif this.searchCriteria.search_subdivision NEQ "">
        and (#this.searchCriteria.search_subdivision#)
        </cfif>
        <cfif this.searchCriteria.search_with_pool EQ 1>
        and listing_pool = '1' 
        </cfif>
        <cfif this.searchCriteria.search_office_only>
        <cfif listingSharedData.sharedStruct.officeSQL NEQ ""> and (#listingSharedData.sharedStruct.officeSQL#)<cfelse> and 1 = 0 </cfif>
        <cfelseif this.searchCriteria.search_agent_only>
        <cfif listingSharedData.sharedStruct.agentSQL NEQ ""> and (#listingSharedData.sharedStruct.agentSQL#)<cfelse> and 1 = 0 </cfif>
        </cfif>
        
        <cfif this.searchCriteria.search_within_map EQ 1>
            <cfscript>
			local.inclusiveLatLongBox=' and listing_latitude BETWEEN '&listingSharedData.sharedStruct.minLat&' and '&listingSharedData.sharedStruct.maxLat&' and listing_longitude BETWEEN '&listingSharedData.sharedStruct.minLong&' and '&listingSharedData.sharedStruct.maxLong;
			if(structcount(arguments.ss.searchMapCoordinates) EQ 4){
				writeoutput(' and listing_latitude BETWEEN '&application.zcore.functions.zescape(arguments.ss.searchMapCoordinates.minLatitude)&' AND '&application.zcore.functions.zescape(arguments.ss.searchMapCoordinates.maxLatitude)&' AND listing_longitude BETWEEN '&application.zcore.functions.zescape(arguments.ss.searchMapCoordinates.minLongitude)&' AND '&application.zcore.functions.zescape(arguments.ss.searchMapCoordinates.maxLongitude)&' '); 
				
			}else{
				arrMap=listtoarray(this.searchCriteria.search_map_coordinates_list);
				if(arraylen(arrMap) NEQ 4){
					writeoutput(' and 1=0 ');
				}else{
					arrMap2=["minLongitude","maxLongitude","minLatitude","maxLatitude"];
					mapCoor=structnew();
					mapFail=false;
					for(i=1;i LTE arraylen(arrMap);i++){
						if(isnumeric(arrMap[i])){
							mapCoor[arrMap2[i]]=arrMap[i];
						}else{
							break;	
						}
					}
					if(structcount(mapCoor) LT 4){
						writeoutput(' and 1=0 ');
					}else if(mapCoor.minLatitude EQ mapCoor.maxLatitude and mapCoor.minLongitude EQ mapCoor.maxLongitude){
						writeoutput(" and (listing_longitude = '"&application.zcore.functions.zescape(mapCoor.minLongitude)&"' AND listing_latitude='"&application.zcore.functions.zescape(mapCoor.minLatitude)&"')");
					}else{
						writeoutput(' and listing_latitude BETWEEN '&application.zcore.functions.zescape(mapCoor.minLatitude)&' and '&application.zcore.functions.zescape(mapCoor.maxLatitude)&' and listing_longitude BETWEEN '&application.zcore.functions.zescape(mapCoor.minLongitude)&' and  '&application.zcore.functions.zescape(mapCoor.maxLongitude)&' ');
					}
				}
			}
			writeoutput(local.inclusiveLatLongBox);
            </cfscript>
        </cfif>
        
         
	    <cfif arraylen(arguments.ss.arrExcludeContentId) NEQ 0>
	        <cfsavecontent variable="db.sql">
	        SELECT cast(group_concat(content_mls_number SEPARATOR #db.param("','")#) as char) as idlist 
			FROM #db2.table("content", request.zos.zcoreDatasource)# content 
			WHERE content_mls_number <> #db.param('')# AND 
			content_mls_override=#db.param('1')# and 
			content_for_sale <> #db.param('2')# and 
			content_deleted=#db.param('0')# and 
			content.site_id = #db.param(request.zos.globals.id)# and 
			content.content_id IN (#db.trustedSQL("'#arraytolist(arguments.ss.arrExcludeContentId,"','")#'")#) 
	        </cfsavecontent><cfscript>qC2732=db.execute("qC2732");
	        if(qC2732.recordcount and qC2732.idlist NEQ ""){
	        	echo(" and listing.listing_id NOT IN ('#qC2732.idlist#')  ");
	        }
	    	</cfscript>
	    </cfif> 
        
        <cfif arguments.ss.requireValidCoordinates>
			and listing_latitude<>'' and listing_longitude<>'' and listing_latitude BETWEEN -180 AND 180 and listing_longitude BETWEEN -180 AND 180 and listing_latitude<>'0' and listing_longitude<>'0'
        </cfif>
        
        <cfif this.searchCriteria.search_with_photos EQ 1>
        and listing_photocount <> '0' 
        </cfif>
        <cfif structkeyexists(this.searchCriteria,'search_forcehotel') and this.searchCriteria.search_forceHotel NEQ "">
        and (listing_remarks like '%motel%' or listing_remarks like '%hotel%') and listing_type_id = 'C'
        </cfif>
        <cfif structkeyexists(this.searchCriteria,'search_forceRentalForSale') and this.searchCriteria.search_forceRentalForSale NEQ "">
        and (listing_remarks like '%vacation home%' or listing_remarks like '%vacation rental%')
        </cfif>
        <cfif structkeyexists(this.searchCriteria,'search_alsoCondotel') and this.searchCriteria.search_alsoCondotel NEQ "">
        and ((listing_remarks like '%condotel%' and listing_price>='209000') or 
         (listing.listing_type_id = '#application.zcore.functions.zEscape(this.searchCriteria.search_listing_type_id)#'
         and listing_price>='499000')
         )
        </cfif>
        
        <cfif structkeyexists(this.searchCriteria,'search_condoname') and this.searchCriteria.search_condoname NEQ "">
        and (#this.searchCriteria.search_condoname#)
        </cfif>
        <cfif structkeyexists(this.searchCriteria,'search_zip') and this.searchCriteria.search_zip NEQ "">
        <cfset listingDataTable=true>
        and (listing_zip IN (#this.searchCriteria.search_zip#))
        </cfif>
        <cfif structkeyexists(this.searchCriteria,'search_address') and this.searchCriteria.search_address NEQ ""> 
        and (#this.searchCriteria.search_address#) 
        </cfif>

		<cfscript>
		if((structkeyexists(this.searchCriteria,'search_remarks') and this.searchCriteria.search_remarks NEQ "") or (structkeyexists(this.searchCriteria,'search_remarks_negative') and this.searchCriteria.search_remarks_negative NEQ "")){
			arrRemark=[];
			if(structkeyexists(this.searchCriteria,'search_remarks')){
				arrR=listToArray(this.searchCriteria["search_remarks"], ",");
				for(i=1;i LTE arraylen(arrR);i++){
					a=arrR[i];
					a=trim(application.zcore.functions.zurlencode(a, " "));
					if(a NEQ ""){ 
						arrayAppend(arrRemark, a);
					}
				}
			}
			arrRemarkNegative=[];
			if(structkeyexists(this.searchCriteria,'search_remarks_negative')){
				arrR=listToArray(this.searchCriteria["search_remarks_negative"], ",");
				for(i=1;i LTE arraylen(arrR);i++){
					a=arrR[i];
					a=trim(application.zcore.functions.zurlencode(a, " "));
					if(a NEQ ""){
						arrayAppend(arrRemarkNegative, a);
					}
				}
			}
			arrRemarkFinal=[]; 
				if(arraylen(arrRemark)){
					positiveList=" and (listing_data.listing_data_remarks LIKE '%"&arrayToList(arrRemark, "%' or listing_data.listing_data_remarks LIKE '%")&"%')";
					arrayAppend(arrRemarkFinal, positiveList);
				}
				if(arraylen(arrRemarkNegative)){
					negativeList=" and (listing_data.listing_data_remarks NOT LIKE '%"&arrayToList(arrRemarkNegative, "%' and listing_data.listing_data_remarks NOT LIKE '%")&"%')";
					arrayAppend(arrRemarkFinal, negativeList);
				} 
			if(arrayLen(arrRemarkFinal)){
				listingDataTable=true;
				echo(arrayToList(arrRemarkFinal, " "));
			}
		}
		</cfscript> 
         
        
        
        <cfif structkeyexists(this.searchCriteria,'search_residential') and this.searchCriteria.search_residential NEQ "">
            and listing.listing_type_id <> 'V'
            and listing.listing_type_id <> 'C'
            and listing.listing_type_id <> 'R'
        </cfif>  
        
        <cfif this.searchCriteria.search_list_date NEQ "">
        and listing_track_datetime > '#application.zcore.functions.zEscape(this.searchCriteria.search_list_date)#'
        </cfif>
        <cfif this.searchCriteria.search_max_list_date NEQ "">
        and listing_track_datetime <= '#application.zcore.functions.zEscape(this.searchCriteria.search_max_list_date)#'
        </cfif>

)        
<cfif this.searchCriteria.search_agent_always EQ 1>
    <cfif listingSharedData.sharedStruct.agentSQL NEQ ""> or (
        1=1 
    <cfif arguments.ss.noCityTable EQ false>
        <cfif this.searchCriteria.search_city_id EQ "" or structkeyexists(arguments.ss,'arrMLSPID')>
        <cfelse>  
        and listing.listing_city IN (#this.searchCriteria.search_city_id#)   
        </cfif>
    </cfif>
    <cfif this.searchCriteria.search_county NEQ "">
        and listing_county IN (#this.searchCriteria.search_county#)
    </cfif>
    <cfif this.searchCriteria.search_frontage NEQ "">
        and (#this.searchCriteria.search_frontage#)
    </cfif>
    <cfif this.searchCriteria.search_status NEQ "">
        and (#this.searchCriteria.search_status#)
    </cfif>
    <cfif this.searchCriteria.search_liststatus NEQ "">
        and listing_liststatus IN (#this.searchCriteria.search_liststatus#)
    </cfif>
    <cfif this.searchCriteria.search_style NEQ "">
        and (#this.searchCriteria.search_style#)
    </cfif>
    <cfif this.searchCriteria.search_view NEQ "">
        and (#this.searchCriteria.search_view#)
    </cfif>
    <cfif this.searchCriteria.search_listing_type_id NEQ "">
    and listing.listing_type_id IN (#this.searchCriteria.search_listing_type_id#)
    </cfif>
    <cfif structkeyexists(this.searchCriteria,'search_harborOnly')>
    and (listing_subdivision like '%harbour%')
    </cfif>
    <cfif this.searchCriteria.search_subdivision NEQ "">
    and (#this.searchCriteria.search_subdivision#)
    </cfif>
    <cfif this.searchCriteria.search_with_pool EQ 1>
    and listing_pool = '1' 
    </cfif> and 
    #listingSharedData.sharedStruct.agentSQL#) 
	</cfif>
</cfif>
<cfif this.searchCriteria.search_office_always EQ 1>
        <cfif listingSharedData.sharedStruct.officeSQL NEQ ""> or (
        1=1 
    <cfif arguments.ss.noCityTable EQ false>
        <cfif this.searchCriteria.search_city_id EQ "" or structkeyexists(arguments.ss,'arrMLSPID')>
        <cfelse> 
        and listing.listing_city IN (#this.searchCriteria.search_city_id#)  
        </cfif>
    </cfif>
        <cfif this.searchCriteria.search_county NEQ "">
            and listing_county IN (#this.searchCriteria.search_county#)
        </cfif>
        <cfif this.searchCriteria.search_frontage NEQ "">
            and (#this.searchCriteria.search_frontage#)
        </cfif>
        <cfif this.searchCriteria.search_status NEQ "">
            and (#this.searchCriteria.search_status#)
        </cfif>
        <cfif this.searchCriteria.search_liststatus NEQ "">
            and listing_liststatus IN (#this.searchCriteria.search_liststatus#)
        </cfif>
        <cfif this.searchCriteria.search_style NEQ "">
            and (#this.searchCriteria.search_style#)
        </cfif>
        <cfif this.searchCriteria.search_view NEQ "">
            and (#this.searchCriteria.search_view#)
        </cfif>
        <cfif this.searchCriteria.search_listing_type_id NEQ "">
        and listing.listing_type_id IN (#this.searchCriteria.search_listing_type_id#)
        </cfif>
        <cfif structkeyexists(this.searchCriteria,'search_harborOnly')>
        and (listing_subdivision like '%harbour%')
        </cfif>
        <cfif this.searchCriteria.search_subdivision NEQ "">
        and (#this.searchCriteria.search_subdivision#)
        </cfif>
        <cfif this.searchCriteria.search_with_pool EQ 1>
        and listing_pool = '1' 
        </cfif> and 
        #listingSharedData.sharedStruct.officeSQL#) </cfif>
</cfif>

<cfif structkeyexists(listingSharedData.sharedStruct, 'latLongBoundaries')>
	#listingSharedData.sharedStruct.latLongBoundaries# 
</cfif>

<cfif this.searchCriteria.search_agent_always EQ 1 or this.searchCriteria.search_office_always EQ 1>
    )
    </cfif>
        <cfif listingDataTable>
    and listing_data.listing_id = listing.listing_id and 
    listing_data_deleted = '0'
    </cfif>
    <!---  --->
        
        
       <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(listingSharedData.sharedStruct.filterStruct, 'whereSQL')> #listingSharedData.sharedStruct.filterStruct.whereSQL#
       <cfif listingSharedData.sharedStruct.filterStruct.listingDataTable>
       	<cfset listingDataTable=true>
       </cfif>
        </cfif>
	<cfif listingSharedData.sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE '%,7,%' </cfif>
        
        <cfif arguments.ss.tempWhere NEQ ''>
            #(arguments.ss.tempWhere)#
        </cfif>
    </cfsavecontent>
    <cfscript>
	whereSQL=replace(replace(whereSQL,"'% %'","'~~~~~&*^(%)^~~~~~'","ALL"),"'%, ,%'","'~~~~~&*^(%)^~~~~~'","ALL");
	
	if(arguments.ss.returnWhereSQLOnly){
		return whereSQL;	
	}
	searchFormURL=request.zos.listing.functions.getSearchFormLink();
	</cfscript>
    
    <cfsavecontent variable="countSQL">
    
    SELECT <cfif request.zos.originalURL EQ searchFormURL> SQL_NO_CACHE  </cfif> count(listing.listing_id) as count 
    FROM ( 
   <cfif listingDataTable> #db2.table("listing_data", request.zos.zcoreDatasource)# listing_data ,</cfif>  
    <cfif 1 EQ 0 and arguments.ss.useMLSCopy>
    #db2.table("listing_saved", request.zos.zcoreDatasource)# listing_saved 
    <cfelse> 
    #db2.table("listing_memory", request.zos.zcoreDatasource)# listing
	</cfif>
             <cfif this.searchCriteria.search_list_date NEQ "" or this.searchCriteria.search_max_list_date NEQ "">
    <cfif listingTrackTable or (arguments.ss.onlyCount EQ false and this.enableListingTrack)> , #db2.table("listing_track", request.zos.zcoreDatasource)# listing_track </cfif>
    </cfif>
    )
    
    #whereSQL#
             <cfif this.searchCriteria.search_list_date NEQ "" or this.searchCriteria.search_max_list_date NEQ "">
   		<cfif listingTrackTable or (arguments.ss.onlyCount EQ false and this.enableListingTrack)> and listing.listing_id = listing_track.listing_id and 
   		listing_track_deleted = 0 and 
	   listing_track.listing_track_inactive=0  </cfif>
        </cfif>
    <cfif arguments.ss.perpage EQ 0> and 1=0 </cfif>
    </cfsavecontent>
    
    <cfif arguments.ss.onlyCount EQ false>
<cfsavecontent variable="propSQL">
    
    SELECT <cfif request.zos.originalURL EQ searchFormURL> SQL_NO_CACHE  </cfif> listing.listing_id 
        <cfif left(this.searchCriteria.search_sort,10) EQ "sortppsqft">
        , if(listing_price>999,if(listing_square_feet>0,listing_price/listing_square_feet,10000000),10000000) pricepersqft 
        </cfif>
    
    
    FROM 
    ( 
	
    <cfif listingDataTable> #db2.table("listing_data", request.zos.zcoreDatasource)# listing_data ,</cfif> 
    <cfif 1 EQ 0 and structkeyexists(arguments.ss,'useMLScopy') and arguments.ss.useMLSCopy EQ true>
    #db2.table("listing_saved", request.zos.zcoreDatasource)# listing_saved
    <cfelse>
    #db2.table("listing_memory", request.zos.zcoreDatasource)# listing 
    </cfif>
             <cfif this.searchCriteria.search_list_date NEQ "" or this.searchCriteria.search_max_list_date NEQ "">
   	<cfif listingTrackTable or (arguments.ss.onlyCount EQ false and this.enableListingTrack)> , #db2.table("listing_track", request.zos.zcoreDatasource)# listing_track </cfif> 
    </cfif>
    )
    
    #whereSQL# 
             <cfif this.searchCriteria.search_list_date NEQ "" or this.searchCriteria.search_max_list_date NEQ "">
   		<cfif listingTrackTable or (arguments.ss.onlyCount EQ false and this.enableListingTrack)> and listing.listing_id = listing_track.listing_id and 
   		listing_track_deleted = 0 and 
	   listing_track.listing_track_inactive=0 </cfif> 
        </cfif>
    
    <cfif isDefined('arguments.ss.noSorting') EQ false>
     
        <cfset outputorderbycomma="ORDER BY ">
        
        
        
        <cfset arrTopSort=arraynew(1)>
<cfif this.searchCriteria.search_sort_agent_first EQ 1>
	<cfif listingSharedData.sharedStruct.agentSQL NEQ "">
		<cfscript>
        arrayappend(arrTopSort,"if("&listingSharedData.sharedStruct.agentSQL&",1,0) desc,");
        </cfscript>
    </cfif>
</cfif>
<cfif this.searchCriteria.search_sort_office_first EQ 1>
	<cfif listingSharedData.sharedStruct.officeSQL NEQ "">
		<cfscript>
        arrayappend(arrTopSort,"if("&listingSharedData.sharedStruct.officeSQL&",1,0) desc,");
        </cfscript>
    </cfif>
</cfif>
        <cfset outputorderbycomma="ORDER BY "&arraytolist(arrTopSort,"")>
    <cfif arguments.ss.noCityTable EQ false>
        <cfif this.searchCriteria.search_city_id NEQ '' and this.searchCriteria.search_surrounding_cities EQ 1>
        #outputorderbycomma# FIND_IN_SET(listing_city, #replace(this.searchCriteria.search_city_id,"','",",","ALL")#) 
        <cfset outputorderbycomma=",">
	</cfif>
    </cfif>
    
        <cfif this.searchCriteria.search_sort NEQ "nosort">
        <cfif 1 EQ 1 or outputorderbycomma EQ ",">
		<cfif this.searchCriteria.search_sort EQ "priceasc" or this.searchCriteria.search_sort EQ "">
		#outputorderbycomma# listing_price ASC
		<cfelseif this.searchCriteria.search_sort EQ "newfirst">
		#outputorderbycomma# listing_updated_datetime DESC
		<cfelseif this.searchCriteria.search_sort EQ "sortppsqftasc">
		#outputorderbycomma# IF(listing_price>999,IF(listing_square_feet>0,listing_price/listing_square_feet,10000000),10000000)
		<cfelseif this.searchCriteria.search_sort EQ "pricedesc">
		#outputorderbycomma# listing_price DESC
		<cfelseif this.searchCriteria.search_sort EQ "sortppsqftdesc">
		#outputorderbycomma# IF(listing_price>999,IF(listing_square_feet>0,listing_price/listing_square_feet,10000000),10000000) DESC
		<cfelse> 
             #outputorderbycomma# #this.searchCriteria.search_sort# 
             listing_priceBAD_SEARCH_SORT ASC
             <cfscript>
		writeoutput('Invalid Request');application.zcore.functions.zabort();	
		</cfscript>
             </cfif>
         </cfif> 
         </cfif>
		 
		 
    </cfif>
    
    LIMIT 
    <cfscript>
    if(arguments.ss.forceSimpleLimit){
		echo(arguments.ss.offset&", "&arguments.ss.perpage);
	}else{
		echo((arguments.ss.perpage*arguments.ss.offset)&", ");
		if(arguments.ss.disableCount){
			if(this.searchCriteria.search_result_limit NEQ 0){
				echo(this.searchCriteria.search_result_limit+1);
			}else{
				echo(arguments.ss.perpage+1);
			}
		}else{
			if(this.searchCriteria.search_result_limit NEQ 0){
				echo(this.searchCriteria.search_result_limit);
			}else{
				echo(arguments.ss.perpage);
			}
		}
	}
    </cfscript>
    </cfsavecontent> 
    </cfif>
    <cfif arguments.ss.zselect NEQ "">
    <cfif arguments.ss.contentTableEnabled>
		<cfscript>
        // you must have a group by in your query or it may miss rows
        ts=structnew();
        ts.image_library_id_field="content.content_image_library_id";
        ts.count =  1; // how many images to get
        rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
        </cfscript>
    </cfif>
<cfsavecontent variable="zselectsql">
    
    SELECT <cfif request.zos.originalURL EQ searchFormURL> SQL_NO_CACHE  </cfif> #arguments.ss.zselect# 
    <cfif arguments.ss.zReturnSimpleQuery EQ false>
	<cfif arguments.ss.contentTableEnabled>
    #(rs2.select)#
    </cfif>
    </cfif>
    FROM 
    ( 
    <cfif listingDataTable> #db2.table("listing_data", request.zos.zcoreDatasource)# listing_data ,</cfif>
    <cfif 1 EQ 0 and arguments.ss.useMLSCopy EQ true>
    #db2.table("listing_saved", request.zos.zcoreDatasource)# listing_saved
    <cfelse>
    #db2.table("listing_memory", request.zos.zcoreDatasource)# listing
    </cfif>
    
             <cfif this.searchCriteria.search_list_date NEQ "" or this.searchCriteria.search_max_list_date NEQ "">
    <cfif listingTrackTable or (arguments.ss.onlyCount EQ false and this.enableListingTrack)>
    , #db2.table("listing_track", request.zos.zcoreDatasource)# listing_track 
    </cfif>
    </cfif>
    <cfif arguments.ss.zReturnSimpleQuery EQ false>
    </cfif>
    )

    <cfif arguments.ss.zReturnSimpleQuery EQ false>
	<cfif arguments.ss.contentTableEnabled>
     LEFT JOIN #db2.table("content", request.zos.zcoreDatasource)# content ON content.content_mls_number = listing.listing_id and content_mls_override='1' and content_for_sale <> '2' and content_deleted='0' and content.site_id = '#request.zos.globals.id#' 
       #(rs2.leftJoin)#
       </cfif>
       
       </cfif>
       
    #arguments.ss.zleftjoin#
    
    #whereSQL# 
        <cfif this.searchCriteria.search_list_date NEQ "" or this.searchCriteria.search_max_list_date NEQ "">
   		<cfif listingTrackTable or (arguments.ss.onlyCount EQ false and this.enableListingTrack)> and listing.listing_id = listing_track.listing_id and 
   		listing_track_deleted = 0 and 
	   listing_track.listing_track_inactive=0 </cfif> 
        </cfif>
    
    #arguments.ss.zwhere#
    
    #arguments.ss.zgroupby# 
    #arguments.ss.zunion#
    
    
    <cfif arguments.ss.zhaving NEQ "">
    	HAVING (#arguments.ss.zhaving#)
    </cfif>
    
    #arguments.ss.zorderby#
    
    <cfif arguments.ss.zlimit NEQ "" and isnumeric(arguments.ss.zlimit)>
    LIMIT 0, #arguments.ss.zlimit#
    </cfif>
    </cfsavecontent>
        <cfsavecontent variable="db2.sql">
        #(zselectsql)#
        </cfsavecontent>
        <cfscript>
        qZselect=db2.execute("qZselect");
    	</cfscript>
		<cfif arguments.ss.debug>
        <span style="border:1px solid ##999999; padding:5px;font-size:10px; line-height:11px; display:block; "><strong>;qZSelect;</strong><br />
            #zselectsql#<br />;Time: #((getTickCount()-start48)/1000)&" seconds"#<br /><br /></span>
        </cfif> 

		<cfscript>
		if(arguments.ss.zReturnSimpleQuery){
			request.tempZselectsql=zselectsql;
			return qZSelect;	
		} 
		</cfscript>
        <cfif arguments.ss.checkSearchCountCache>
		<cfset start48=gettickcount()> 
			
		<cfscript>

		mls_dir_title = "title";
		mls_dir_metakey = "";
		mls_dir_metadesc = "";
		mls_dir_full_text = "";
		
		</cfscript>
						 
        <cfif arguments.ss.lookupName NEQ "">
            <cfscript>
			cs=structnew();
			</cfscript>
            <cfloop query="qzselect"><cfscript>if(qzselect.value CONTAINS ","){arr1=listtoarray(mid(qzselect.value,2,len(qzselect.value)-2),",",false);}else{arr1=listtoarray(qzselect.value,",");}
			for(i=1;i LTE arraylen(arr1);i++){
				if(structkeyexists(cs,arr1[i]) EQ false){
					cs[arr1[i]]=structnew();
					cs[arr1[i]].count=0;
					cs[arr1[i]].label=application.zcore.listingCom.listingLookupValue(arguments.ss.lookupName,arr1[i]);
				}
				cs[arr1[i]].count+=qzselect.count;
			}
			</cfscript></cfloop><cfscript>
			qzselect=querynew("label,value,count","varchar,varchar,integer");
			arrSort=structsort(cs,"numeric","asc","count");
			row=0;
			for(i=1;i LTE arraylen(arrSort);i++){
				if(findnocase(","&arrSort[i]&",",","&arguments.ss.removeValues&",") EQ 0){
					row++;
					queryaddrow(qzselect,1);
					QuerySetCell(qzselect, "value", arrSort[i], row);
					QuerySetCell(qzselect, "label", cs[arrSort[i]].label, row);
					QuerySetCell(qzselect, "count", cs[arrSort[i]].count, row); 
				} 
			}
			</cfscript>
        </cfif>
					
		<cfscript>
		if(arguments.ss.zReturnLookupQuery){
			return qzselect;	
		} 
		arrsql=arraynew(1);
		arrSavedSearchDirIds=arraynew(1);
		arrayappend(arrsql,'INSERT INTO mls_dir (');
		arrF=arraynew(1);

		arrayAppend(arrF,'mls_saved_search_id');
		arrayAppend(arrF,'mls_dir_title');
		arrayAppend(arrF,'mls_dir_metakey');
		arrayAppend(arrF,'mls_dir_metadesc');
		arrayAppend(arrF,'mls_dir_full_text');
		arrayAppend(arrF,'site_id');
		arrayAppend(arrF,'mls_dir_hash');
		arrayAppend(arrF,'mls_dir_search_string');
		arrayAppend(arrF,'mls_dir_updated_datetime');
				
		arrayappend(arrsql,arraytolist(arrF)&") VALUES "); 
		arrRow=arraynew(1);
		arrSavedRow=arraynew(1);
		arrDirIds=arraynew(1);
		hashStruct=structnew();
		hashReturnStruct=structnew();
		valueReturnStruct=structnew();
		arrDirHash=arraynew(1);
		ts5=StructNew();
		curFieldIndex=0;
		a444=duplicate(this.searchCriteriaBackup);
		for(i in a444) {
			if(a444[i] EQ false) {
				a444[i]=0;
			} else if (a444[i] EQ true) {
				a444[i]=1;
			}
		}
		fs=structnew();
		arr2332=arraynew(1);
		nowDate=request.zos.mysqlnow;
		arrSavedValues=arraynew(1);
		for(i=1;i LTE arraylen(this.arrSearchFields);i++){
			label=this.arrShortSearchFields[i]&":";
			if(structkeyexists(this.ignoreFieldStruct,this.arrSearchFields[i]) EQ false){
				if(this.arrSearchFields[i] EQ arguments.ss.searchcountname) {
					curFieldIndex=arraylen(arr2332)+1;
					curOriginalFieldIndex=i;
					if(this.searchCriteriaBackup[this.arrSearchFields[i]] NEQ ""){
						value="~$$$~,"&this.searchCriteriaBackup[this.arrSearchFields[i]];
					}else{
						value="~$$$~";	
					}
				}else{
					value=this.searchCriteriaBackup[this.arrSearchFields[i]];
				}
				if(structkeyexists(this.rangeFieldStruct,this.arrSearchFields[i])){
					lowField=value;
					highField=this.searchCriteriaBackup[this.rangeFieldStruct[this.arrSearchFields[i]]];
					if(lowField NEQ "" and highField NEQ "" and isNumeric(lowField) and isNumeric(highField) and (this.defaultSearchCriteria[this.arrSearchFields[i]] NEQ lowField or this.defaultSearchCriteria[this.rangeFieldStruct[this.arrSearchFields[i]]] NEQ highField)){
						arrayappend(arr2332,label&lowField&"-"&highfield);
					}
				}else if(value NEQ "" and value NEQ "0"){
					arrayappend(arr2332,label&value);
				}
			}
			arrayappend(arrSavedValues,application.zcore.functions.zescape(a444[this.arrSearchFields[i]]));
		}
		arrayappend(arrSavedValues,nowDate);
		arrayappend(arrSavedValues,nowDate);
		//structAppend(variables,a444, true);
		</cfscript><cfloop query="qzselect"><cfscript>
		//for(n=1;n LTE qzselect.recordcount;n++) {
			backupStr=arr2332[curFieldIndex];
			arr2332[curFieldIndex]=replace(arr2332[curFieldIndex],"~$$$~", qzselect.value);
			//writeoutput(arraytolist(arr2332,"|")&"<br /><br />");
			t95=structnew();
			t95.mls_dir_search_string=arraytolist(arr2332,chr(9)); 
			arr2332[curFieldIndex]=backupStr;
			//t95.mls_dir_hash=;
			t95.zI=qzselect.currentrow;
			t95.label=qzselect.label;
			t95.value=qzselect.value;
			t95.count=qzselect.count;
			hashStruct[hash(t95.mls_dir_search_string)]=t95;
		//}
		</cfscript></cfloop><cfscript>
		//application.zcore.functions.zdump(hashStruct);
		chs=structnew();
		// get all mls_dir
		db.sql="SELECT SQL_NO_CACHE * FROM #db.table("mls_dir", request.zos.zcoreDatasource)# mls_dir 
		where mls_dir_hash IN (#db.trustedSQL("'#arraytolist(structkeyarray(hashStruct),"','")#'")#) and 
		site_id=#db.param(request.zos.globals.id)# and 
		mls_dir_deleted = #db.param(0)# ";
		qdir=db.execute("qdir");
		//application.zcore.functions.zdump(qdir);
		perfect=false;
		//writeoutput('qdir:'&qdir.recordcount&' NEQ qzselect:'&qzselect.recordcount&'<br />');
		</cfscript><cfif qdir.recordcount NEQ qzselect.recordcount><cfloop query="qdir"><cfscript>
        chs[mls_dir_hash]=structnew();
        chs[mls_dir_hash].mls_dir_id=qdir.mls_dir_id;
		chs[mls_dir_hash].mls_saved_search_id=qdir.mls_saved_search_id;
		chs[mls_dir_hash].mls_dir_title=qdir.mls_dir_title;
		curLabel=hashStruct[mls_dir_hash].label & " (" & hashStruct[mls_dir_hash].count & ")";
		tempLink="/"&application.zcore.functions.zUrlEncode(mls_dir_title,"-")&"-"&listingSharedData.sharedStruct.optionStruct.mls_option_dir_url_id&"-"&mls_dir_id&".html";
		//arrayappend(arrL,'<a href="#arrdirid222[currentrow]#">#arrLabels[currentrow]#</a>');
		fs[curLabel&"_"&hashStruct[mls_dir_hash].value]='<a href="'&tempLink&'">'&curLabel&'</a>';
		structdelete(hashStruct,mls_dir_hash);
        </cfscript></cfloop><cfelse><cfloop query="qdir"><cfscript>
        // all downloaded!
		perfect=true;
		curLabel=hashStruct[mls_dir_hash].label & " (" & hashStruct[mls_dir_hash].count & ")";
		tempLink="/"&application.zcore.functions.zUrlEncode(mls_dir_title,"-")&"-"&listingSharedData.sharedStruct.optionStruct.mls_option_dir_url_id&"-"&mls_dir_id&".html";
		//arrayappend(arrL,'<a href="#arrdirid222[currentrow]#">#arrLabels[currentrow]#</a>');
		fs[curLabel&"_"&hashStruct[mls_dir_hash].value]='<a href="'&tempLink&'">'&curLabel&'</a>';
        </cfscript></cfloop></cfif><cfscript>
		// create the missing ones
		if(perfect EQ false){
			arrHash=structkeyarray(hashStruct);
			for(i=1;i LTE arraylen(arrHash);i++){
				zI=hashStruct[arrHash[i]].zI;
				// create all #db2.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search sql
				if(this.searchCriteriaBackup[arguments.ss.searchcountname] NEQ ""){
					//variables[arguments.ss.searchcountname] = qZselect.value[n]&","&this.searchCriteriaBackup[arguments.ss.searchcountname];
					arrSavedValues[curOriginalFieldIndex] = qZselect.value[zI]&","&this.searchCriteriaBackup[arguments.ss.searchcountname];
				}else{
					//variables[arguments.ss.searchcountname] = qZselect.value[n];
					arrSavedValues[curOriginalFieldIndex] = qZselect.value[zI];
				}
				hashStruct[arrHash[i]].newValue=arrSavedValues[curOriginalFieldIndex];
				arrayappend(arrSavedRow,"'"&arraytolist(arrSavedValues,"','")&"', '#request.zos.mysqlnow#'"); 
			}
			savedSQL="INSERT INTO #db2.table("mls_saved_search", request.zos.zcoreDatasource)#  (`"&arraytolist(this.arrSearchFields,"`,`")&"`,saved_search_created_date,saved_search_updated_date, mls_saved_search_updated_datetime) VALUES("&arraytolist(arrSavedRow,"),(")&")";
			//writeoutput(savedSQL);
			//application.zcore.functions.zabort();
			newId=0;
			db2.sql=savedSQL;
			local.rs=db2.execute("q");
			if(local.rs.success){
				newId=local.rs.result;
			}else{
				throw("mls_saved_search insert failed.");
			}
			if(newId NEQ 0){
				for(i=1;i LTE arraylen(arrHash);i++){
					a444[arguments.ss.searchcountname]=hashStruct[arrHash[i]].newValue;
					hashStruct[arrHash[i]].mls_dir_title=arraytolist(request.zos.listing.functions.getSearchCriteriaDisplay(a444,true)," | ");
					hashStruct[arrHash[i]].mls_saved_search_id=newId+(i-1);
					mls_dir_metakey="";
					mls_dir_metadesc="";
					mls_dir_full_text="";
					arrF=arraynew(1);
					arrayAppend(arrF,application.zcore.functions.zescape(hashStruct[arrHash[i]].mls_saved_search_id));
					arrayAppend(arrF,application.zcore.functions.zescape(hashStruct[arrHash[i]].mls_dir_title));
					arrayAppend(arrF,application.zcore.functions.zescape(mls_dir_metakey));
					arrayAppend(arrF,application.zcore.functions.zescape(mls_dir_metadesc));
					arrayAppend(arrF,application.zcore.functions.zescape(mls_dir_full_text));
					arrayAppend(arrF,application.zcore.functions.zescape(request.zos.globals.id));
					arrayAppend(arrF,application.zcore.functions.zescape(arrHash[i]));
					arrayAppend(arrF,application.zcore.functions.zescape(hashStruct[arrHash[i]].mls_dir_search_string));
					arrayappend(arrF,request.zos.mysqlnow);
					arrayappend(arrRow,"'"&arraytolist(arrF,"','")&"'"); 
				}
				arrayappend(arrsql,"("&arraytolist(arrRow,"),(")&")");
				dirSQL=arraytolist(arrsql,"");
				newId=0;
				db2.sql=dirSQL;
				local.rs=db2.insert("q");
				if(local.rs.success){
					newId=local.rs.result;
				}else{
					throw("mls_saved_search insert failed.");
				}
				if(newId NEQ 0){
					for(i=1;i LTE arraylen(arrHash);i++){
						hashStruct[arrHash[i]].mls_dir_id=newId+(i-1);
						curLabel=hashStruct[arrHash[i]].label & " (" & hashStruct[arrHash[i]].count & ")";
						tempLink="/"&application.zcore.functions.zUrlEncode(hashStruct[arrHash[i]].mls_dir_title,"-")&"-"&listingSharedData.sharedStruct.optionStruct.mls_option_dir_url_id&"-"&hashStruct[arrHash[i]].mls_dir_id&".html";
						fs[curLabel&"_"&hashStruct[arrHash[i]].value]='<a href="'&tempLink&'">'&curLabel&'</a>';
					}
				}
			}
		}
				 
		arrKey=structkeyarray(fs);
		arraysort(arrKey,"text","asc");
		ArrL=arraynew(1);
		for(i=1;i LTE arraylen(arrKey);i++){
			ArrL[i]=fs[arrKey[i]];	
		}
		rs.count=arraylen(arrKey);
		request.globaldircount+=rs.count;
		rs.output=arraytolist(ArrL,"<br />"); 
	    </cfscript>
			  
         <cfscript>
		 if(arguments.ss.debug){
			writeoutput(((gettickcount()-start48)/1000)&' seconds for post-processing.<br /><br />');
		 }
        return rs;
        </cfscript>
    </cfif>
<cfelse>
    <cfscript>
    cancelNextSearch=false;
	request.zos.requestLogEntry('propertyData.cfc before qPropertyCount');
	if(arguments.ss.disableCount EQ false){
	    try{
	    	if(arguments.ss.enableThreading){
		        db2.sql=countSQL;
			    qPropertyCount=db2.execute("qPropertyCount", request.zos.zcoreDatasource, 5);
	        }else{
		        db2.sql=countSQL;
		        qPropertyCount=db2.execute("qPropertyCount", request.zos.zcoreDatasource, 5);
	        }
		}catch(Any e){

			if(e.type EQ "database" and e.detail CONTAINS "Statement cancelled"){
				savecontent variable="out"{
					echo('Listing search is not available right now. Running queries:');
					arrS=application.zcore.functions.zGetRunningQueries();
					writedump(arrS);
				}
				ts={
					type:"Custom",
					errorHTML:out,
					scriptName:'/zcorerootmapping.mvc.z.listing.controller.propertyData.cfc',
					url:request.zos.originalURL,
					exceptionMessage:'Listing search count is not available right now due to other system activity.',
					// optional
					lineNumber:''
				}
				application.zcore.functions.zLogError(ts);
				qPropertyCount={recordcount:0, count:0};
				qProperty={recordcount:0};
				cancelNextSearch=true;
				errorMessage='Listing search count is not available right now due to other system activity.';
			}
		}
    }
	request.zos.requestLogEntry('propertyData.cfc after qPropertyCount');
    if(arguments.ss.debug){
    	echo('<span style="border:1px solid ##999999; padding:5px;font-size:10px; line-height:11px; display:block; ">');
    }
    if(arguments.ss.onlyCount EQ false){
    	db2.sql=propSQL;
    	qProperty={recordcount:0};
    	if(not cancelNextSearch){
		    try{
	    		qProperty=db2.execute("qProperty", request.zos.zcoreDatasource, 5);
			}catch(Any e){

				if(e.type EQ "database" and e.detail CONTAINS "Statement cancelled"){
					savecontent variable="out"{
						echo('Listing search is not available right now. Running queries:');
						arrS=application.zcore.functions.zGetRunningQueries();
						writedump(arrS);
						rs=application.zcore.functions.zDownloadLink(request.zos.globals.serverDomain&"/z/listing/tasks/importMLS/checkImportTimer", 5);
						if(rs.success){
							echo(rs.cfhttp.filecontent);
						}
					}
					ts={
						type:"Custom",
						errorHTML:out,
						scriptName:'/zcorerootmapping.mvc.z.listing.controller.propertyData.cfc',
						url:request.zos.originalURL,
						exceptionMessage:'Listing search detail is not available right now due to other system activity.',
						// optional
						lineNumber:''
					}
					application.zcore.functions.zLogError(ts);
					qPropertyCount={recordcount:0, count:0};
					qProperty={recordcount:0};
					errorMessage='Listing search detail is not available right now due to other system activity.';
				}
			}
		}
        if(structkeyexists(qProperty, 'recordcount') and qProperty.recordcount NEQ 0){
			mlsStruct=structnew();
			arrQuery=arraynew(1);
			orderStruct=structnew();
			n22=1;
			for(row in qProperty){
				if(row.listing_id CONTAINS "-"){
					mls_id=listgetat(row.listing_id,1,"-");
				}else{
					mls_id=0;
				}
				if(structkeyexists(mlsStruct,mls_id) EQ false){
					mlsStruct[mls_id]=arraynew(1);	
				}
				orderStruct[row.listing_id]=n22;
				n22++;
				arrayappend(request.zos.arrListingsDisplayed, row.listing_id);
				arrayappend(mlsStruct[mls_id], row.listing_id);
			}
			// you must have a group by in your query or it may miss rows
			ts=structnew();
			ts.image_library_id_field="content.content_image_library_id";
			ts.count =  1; // how many images to get
			rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
			local.queryColumnStruct=structnew();
			for(i654 in mlsStruct){
				if(i654 EQ 0){
					if(not structkeyexists(request.zos.listingMlsComObjects, i654)){
						continue;
					}
					ts=structnew();
					ts.image_library_id_field="manual_listing.manual_listing_image_library_id";
					ts.count =  1; // how many images to get
					local.rs3=application.zcore.imageLibraryCom.getImageSQL(ts);
				}else{
					local.rs3={select:"", leftJoin:""};
				}
				idlist22=arraytolist(mlsstruct[i654],"','");
				tsql232="select * #db.trustedSQL(rs2.select)# #db.trustedSQL(rs3.select)# from (
				#db.table("listing", request.zos.zcoreDatasource)# listing, 
				#db.table("listing_data", request.zos.zcoreDatasource)# listing_data) 		
				#db.trustedSQL(local.rs3.leftJoin)#
				LEFT JOIN #db.table("listing_track", request.zos.zcoreDatasource)# listing_track ON 
				listing.listing_id = listing_track.listing_id and 
				listing_track_deleted = #db.param(0)# and 
	   			listing_track.listing_track_inactive=#db.param('0')#
				LEFT JOIN #db.table("content", request.zos.zcoreDatasource)# content ON 
				content.content_mls_number = listing.listing_id and 
				content_mls_override=#db.param('1')# and 
				content_for_sale <> #db.param('2')# and 
				content_deleted=#db.param('0')# and 
				content.site_id = #db.param(request.zos.globals.id)# 
				#db.trustedSQL(rs2.leftJoin)#
				WHERE listing.listing_id IN (#db.trustedSQL("'#idlist22#'")#) and 
				listing_deleted = #db.param(0)# and 
				listing_data_deleted = #db.param(0)# and 
				listing.listing_id = listing_data.listing_id 
				GROUP BY listing.listing_id "; 
			    if(arguments.ss.debug){
					echo('mls '&i654&';'&tsql232&';<hr />');
				}
				db.sql=tsql232;
				r1=db.execute("r1");
				local.a1=listtoarray(r1.columnlist, ",");
				arrayappend(arrQuery,r1);
			}
		}
	}
	request.zos.requestLogEntry('propertyData.cfc after getProperties');
	</cfscript>
	   
    <cfif arguments.ss.disableCount EQ false>
    	<cfif arguments.ss.enableThreading>
        <!--- <cfthread action="join" name="zThread#variables.tempThreadHash#" /> --->
        </cfif>
    </cfif>
    <cfif arguments.ss.debug>
	    <cfif arguments.ss.disableCount EQ false>
	    	<strong>;qPropertyCountSQL;</strong>
            <cfscript>
			c=countSQL;
			c=rereplace(c,"\n\s*(\S)",chr(10)&"\1","ALL");
			writeoutput(application.zcore.functions.zparagraphformat(trim(replace(c, ':ztablesql:', "", 'all'))));
			</cfscript><hr />
        </cfif>
		<cfif arguments.ss.onlyCount EQ false>
            <strong>;qPropertySQL;</strong>
            <cfscript>
			c=propSQL;
			c=rereplace(c,"\n\s*(\S)",chr(10)&"\1","ALL");
			writeoutput(application.zcore.functions.zparagraphformat(trim(replace(c, ':ztablesql:', "", 'all'))));
			</cfscript>
        </cfif><br />;Time: #((getTickCount()-start48)/1000)&" seconds"#
        </span>
        <cfif structkeyexists(form, 'abortOnSearchResults')>
        	<cfscript>
        	abort;
        	</cfscript>
        </cfif>
    </cfif>

    </cfif>
    <cfscript>
    ts=StructNew();
	if(this.searchCriteria.search_result_limit NEQ 0){
		ts.perpage=this.searchCriteria.search_result_limit;
	}else{
		ts.perpage=arguments.ss.perpage;
	}
	ts.inputArguments=arguments;
	//ts.queryColumnStruct=local.queryColumnStruct;
	ts.arrData=arraynew(1);   
	ts.errorMessage=errorMessage;
	ts.count=0;
	if(arguments.ss.zselect NEQ ""){
    	for(row in qzselect){
    		arrayAppend(ts.arrData, row);
    	}
        ts.count=qzselect.recordcount;
    }else{
		if(arguments.ss.onlyCount EQ false){
        	// ts.query=qProperty;   don't need this anymore.
			ts.arrData=[];
			if(qProperty.recordcount NEQ 0){

				ps={};
				// store lookup table of qproperty
        		for(row in qProperty){
        			ps[row.listing_id]=row;
        		}
				tempCount=0;
				// sort the array to match original qProperty sort order 
				for(g=1;g LTE arraylen(arrQuery);g++){
					curQuery=arrQuery[g];
					for(row in curQuery){
						tempCount++;

						newRow=ps[row.listing_id];
						newRow.columnlist=curQuery.columnlist;
						structappend(newRow, row, true);
						if(len(row.listing_data_json) GT 0){
							structappend(newRow, deserializeJson(row.listing_data_json));
						}
						ts.arrData[orderStruct[curQuery.listing_id]]=newRow;
					}
				}
				if(tempCount NEQ qProperty.recordcount){
					// rebuild to eliminate gaps in array
					arrNew=[];
					for(row in ts.arrData){
						arrayAppend(arrNew, row);
					}
					ts.arrData=arrNew;
				} 
			}
		}
		if(arguments.ss.disableCount){
			ts.count=qProperty.recordcount;
		}else{
        	ts.count=qPropertyCount.count;
		}
    }
    return ts;
    </cfscript> 
</cffunction>





<cffunction name="getSearchData" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var ts=structnew();
	var t2=structnew();
	var r1=0;
	var qC=0;
	var searchCountSQL=0;
	var i=0;
	var qCresult=0;
    var arrLabels=arraynew(1);
    var arrValues=arraynew(1);
	var rs=structnew();
	var rs2=structnew();
	//var sqlHash=hash(arguments.ss.sql);
	var arrCount=arraynew(1);
	var nowDate=request.zos.mysqlnow;
	t2.debug=false;
	structappend(arguments.ss,t2,false);
	ts.debug=arguments.ss.debug;
	structappend(ts,arguments.ss.searchStruct,true);
	ts.checkSearchCountCache=true;
	ts.searchCountName=arguments.ss.name;
	rs2 = this.getProperties(ts);
	return rs2;
	</cfscript>
</cffunction>
 

<cffunction name="getComparisonSQL" localmode="modern" returntype="any" output="no">
    <cfargument name="type" type="numeric" required="yes">
    <cfscript>
    var ss10=structnew();
    ss10.likeSQL=" LIKE ";
    ss10.betweenSQL=" BETWEEN ";
    ss10.equateSQL=" = ";
	ss10.listSQL=" IN ";
    ss10.combineSQL=" OR ";
    ss10.matchSQL=" MATCH ";
    if(arguments.type GTE 2){
   		ss10.matchSQL=" NOT MATCH ";
        ss10.likeSQL=" NOT LIKE ";
    	ss10.betweenSQL=" NOT BETWEEN ";
		ss10.listSQL=" NOT IN ";
        ss10.equateSQL=" <> ";
        ss10.combineSQL=" AND ";
    }
    return ss10;
    </cfscript>
</cffunction>

<cffunction name="setFilterCriteria" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
    <cfscript>
	var i=0;
	var remarksMatchList="";
	var sc3=structnew();
	var sc2=structnew();
	var sc4=structnew();
	var sc5=structnew();
	var sc6=structnew();
	var sc8=structnew();
	var sc7=structnew();
	var sc9=structnew();
	var a2=[];
	var ss10=0;
	var db2=request.zos.noVerifyQueryObject;
	this.searchFilterSet=true;
    sc3.search_city_id="";
    sc3.search_listing_type_id="";
	sc3.search_zip="";
	sc3.search_liststatus="";
	sc3.search_county="";
	sc3.search_region="";
	sc3.search_tenure="";
	sc3.search_parking="";
	sc3.search_condition="";
	sc6.search_agent="";
    sc6.search_office="";
    sc6.search_listing_sub_type_id="";
	sc6.search_style="";
	sc6.search_view="";
	sc6.search_frontage="";
	sc6.search_condoname="";
	sc6.search_zip="";
	sc6.search_address="";
	sc6.search_status="";
	sc9.search_agent="listing_agent";
	sc9.search_office="listing_office";
	sc6.search_remarks="";
	sc6.search_remarks_negative="";
    sc6.search_subdivision="";
	
	sc5.search_condoname="listing_condoname";
	sc5.search_address="listing_address";
	sc4.search_style="listing_style";
	sc4.search_view="listing_view";
    sc4.search_listing_sub_type_id="listing_sub_type_id";
	sc4.search_frontage="listing_frontage";
	sc4.search_status="listing_status";
    sc5.search_subdivision="listing_subdivision";
	sc7.search_remarks_negative="listing_remarks";
	sc8.search_remarks="listing_remarks";
	
	sc2.search_sort="priceasc";
	sc2.search_near_address="";
	sc2.search_near_coordinates="";
	sc2.search_near_radius="";
	sc2.search_new_first=false;
	sc2.search_list_date="";
	sc2.search_max_list_date="";
	//sc2.search_sortppsqft=false;
	sc2.search_office_only=false;
	sc2.search_agent_only=false;
    sc2.search_MAP_COORDINATES_LIST="";
	
	this.filterCriteria=duplicate(arguments.ss.data);//,true);
	structappend(this.filterCriteria,this.defaultSearchCriteria,false);
	for(i in this.defaultSearchCriteria){
		if(isNumeric(this.filterCriteria[i]) EQ false){
			this.filterCriteria[i]=this.defaultSearchCriteria[i];	
		}
	}
	
	structappend(this.filterCriteria,sc2,false);
	structappend(this.filterCriteria,sc3,false);
	structappend(this.filterCriteria,sc6,false);
	this.filterContentCriteria=duplicate(this.filterCriteria);
	for(i in sc4){
		request.i222=i;
		if(isSimpleValue(this.filterCriteria[i]) and this.filterCriteria[i] NEQ ""){
			ss10=getComparisonSQL(arguments.ss.type[i]);
			// ss10.likeSQL | ss10.equateSQL | ss10.combineSQL 
			if(ss10.likeSQL EQ " LIKE "){
				//ss10.likeSQL=" NOT LIKE ";	
				//ss10.combineSQL=" AND ";	
			}else{
				//ss10.likeSQL=" LIKE ";	
				//ss10.combineSQL=" OR ";	
			}
			a2=listtoarray(replace(this.filterCriteria[i],"'",'"',"ALL"),',',false);
			this.filterCriteria[i]="#sc4[i]# #ss10.likeSQL# '%,"&arraytolist(a2,",%' #ss10.combineSQL# #sc4[i]# #ss10.likeSQL# '%,")&",%'";
			this.filterContentCriteria[i]="#db2.table("mls_saved_search", request.zos.zcoreDatasource)# .#i# #ss10.likeSQL# '%,"&arraytolist(a2,",%' #ss10.combineSQL# #db2.table("mls_saved_search", request.zos.zcoreDatasource)# .#i# #ss10.likeSQL# '%,")&",%'";
		}
	}
	for(i in sc5){
		if(isSimpleValue(this.filterCriteria[i]) and this.filterCriteria[i] NEQ ""){
			ss10=getComparisonSQL(arguments.ss.type[i]);
			a2=listtoarray(replace(replace(this.filterCriteria[i],"'",' ',"ALL"),'"',' ',"ALL"),',',false);
			this.filterCriteria[i]="#sc5[i]# #ss10.likeSQL# '%"&arraytolist(a2,"%' #ss10.combineSQL# #sc5[i]# #ss10.likeSQL# '%")&"%'";
			this.filterContentCriteria[i]="#db2.table("mls_saved_search", request.zos.zcoreDatasource)# .#i# #ss10.likeSQL# '%,"&arraytolist(a2,",%' #ss10.combineSQL# #db2.table("mls_saved_search", request.zos.zcoreDatasource)# .#i# #ss10.likeSQL# '%,")&",%'";
		}
	} 
	for(i in sc3){
		if(isSimpleValue(this.filterCriteria[i]) and this.filterCriteria[i] NEQ ""){
			this.filterCriteria[i]="'"&replace(replace(this.filterCriteria[i],"'",'"',"ALL"), ",","','","ALL")&"'";
			this.filterContentCriteria[i]=this.filterCriteria[i];
		}
	}
	request.filterCriteria=this.filterCriteria;
	request.filterContentCriteria=this.filterContentCriteria;
	</cfscript>
</cffunction>


<cffunction name="getSearchFilter" localmode="modern" output="yes" returntype="any">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	
	var flen=0;
	var db=request.zos.queryObject;
	var arrcurrentsort=0;
	var whereSQL="";
	var qList=0;
	var qList2=0;
	var rs=structnew();
	var whereOptionsSQL=0;
	
	var parentCity="";
	var mapCoor=0;
	var i=0;
	var ss10=0;
	var arrMap=0;
	var arrMap2=0;
	var noCityTable=true;
	var arrCur=0;
	var key=0;
	var field=0;
	var arrC=arraynew(1);
	var defaultOpened=structnew();
	var nodragstruct=0;
	var uniquesortstruct=structnew();
	var arrDefaultSort=listtoarray("filter_city_id,filter_rate,filter_listing_type_id,filter_listing_sub_type_id,filter_bedrooms,filter_bathrooms,filter_sqfoot,filter_lot_square_feet,filter_year_built,filter_acreage,filter_county,filter_view,filter_status,filter_style,filter_frontage,filter_region,filter_tenure,filter_parking,filter_condition,filter_near_address,filter_near_coordinates,filter_more_options,filter_condoname,filter_subdivision,filter_remarks,filter_remarks_negative,filter_zip,filter_address,filter_within_map");
	var db2=request.zos.noVerifyQueryObject;
	db.sql="select * from #db.table("mls_filter", request.zos.zcoreDatasource)# mls_filter 
	where mls_filter.site_id = #db.param(request.zos.globals.id)# and 
	mls_filter_deleted = #db.param(0)#";
	qMLSFilter=db.execute("qMLSFilter");
	rs.whereSQL="";
	rs.whereOptionsSQL="";
	rs.citySQL="";
	rs.searchable=structnew();
	rs.opened=structnew();
	rs.type=structnew();
	rs.data=structnew();
	rs.appendRemarksMatchString="";
	rs.listingDataTable=false; // set to true when fields are using it
	defaultOpened["filter_more_options"]=true;
	defaultOpened["filter_city_id"]=true;
	defaultOpened["filter_rate"]=true;
	defaultOpened["filter_bedrooms"]=true;
	defaultOpened["filter_bathrooms"]=true;
	defaultOpened["filter_listing_type_id"]=true;
	nodragstruct=structnew();
	nodragstruct["filter_remarks"]=true;
	nodragstruct["filter_remarks_negative"]=true;
	nodragstruct["filter_subdivision"]=true;
	nodragstruct["filter_within_map"]=true;
	nodragstruct["filter_condoname"]=true;
	nodragstruct["filter_zip"]=true;
	nodragstruct["filter_address"]=true;
	
	arrC=listtoarray(qMLSFilter.columnlist); 
	local.maxSort=0;
	
	if(qMLSFilter.recordcount NEQ 0){
		for(i=1;i LTE arraylen(arrC);i++){
			local.c=listlen(qMLSFilter[arrC[i]], ",");
			if(local.c EQ 4){
				local.c2=listgetat(qMLSFilter[arrC[i]], 3,",");
				if(local.c2 NEQ 99){
					local.maxSort=max(local.maxSort, local.c2);
				}
			}
		}
	}
	if(qMLSFilter.recordcount NEQ 0){
		local.arrC2=arraynew(1);
		for(i=1;i LTE arraylen(arrC);i++){
			if(local.qMLSFilter[arrC[i]] EQ ""){
				local.maxSort++;
				arrayappend(local.arrC2, lcase(arrC[i])&"='1,0,"&local.maxSort&",0'");
			}
		}
		if(arraylen(local.arrC2) NEQ 0){
			db.sql="update #db.table("mls_filter", request.zos.zcoreDatasource)#  
			set "&db.trustedSQL(arraytolist(local.arrC2, ", "))&" ,
			mls_filter_updated_datetime=#db.param(request.zos.mysqlnow)# 
			where site_id = #db.param(request.zos.globals.id)# and 
			mls_filter_deleted = #db.param(0)#";
			db.execute("q");
		}
	}
	flen=len("filter_");
	arrCurrentSort=arraynew(1);
	if(qMLSFilter.recordcount EQ 0){
		for(i=1;i LTE arraylen(arrDefaultSort);i++){
			key="search_"&removeChars(arrDefaultSort[i],1,flen);
			if(structkeyexists(nodragstruct,arrDefaultSort[i]) EQ false){
				rs.sort[i]=key;
			}
		}
	}
	for(i=1;i LTE arraylen(arrC);i++){
		field=arrC[i];
		if(left(field,flen) EQ "filter_"){
			key="search_"&removeChars(arrC[i],1,flen);
			//rs.sort[i]=key;
			rs.searchable[key]=1;
			if(structkeyexists(defaultOpened,arrC[i])){
				rs.opened[key]=true;
			}else{
				rs.opened[key]=false;	
			}
		}
	}
	if(qMLSFilter.recordcount EQ 0){
		return rs;
	}
	db.sql="select * FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	where mls_saved_search_id=#db.param(qMLSFilter.mls_saved_search_id)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	mls_saved_search_deleted =#db.param(0)# " ;
	qMLSFilter2=db.execute("qMLSFilter2");
	if(qMLSFilter2.recordcount EQ 0){
		return rs;
	}
	for(i=1;i LTE arraylen(arrC);i++){
		field=arrC[i];
		if(left(field,flen) EQ "filter_"){
			arrCur=listtoarray(qMLSFilter[field][1]);
			key="search_"&removeChars(arrC[i],1,flen);
			rs.hideListings[key]=false;	
			if(arraylen(arrCur) GTE 4){
				if(arrCur[3] NEQ 99){
					rs.sort[arrCur[3]]=key;
				}
				rs.searchable[key]=arrCur[1];
				if(arrCur[2] EQ 1){
					rs.opened[key]=true;
				}else{
					rs.opened[key]=false;	
				}
				rs.type[key]=arrCur[4];
			}else{
				rs.sort[i]=key;
				rs.searchable[key]=1;
				rs.opened[key]=false;
				rs.type[key]=0;
			}
			if(rs.type[key] EQ 1 OR rs.type[key] EQ 3){
				rs.hideListings[key]=true;	
			}
		}
	}
	arrC=listtoarray(qMLSFilter2.columnlist);
	for(i=1;i LTE arraylen(arrC);i++){
		rs.data[arrC[i]]=qMLSFilter2[arrC[i]][1];
	}
	for(i in rs.data){
		if(isNumeric(rs.data[i]) and rs.data[i] EQ 0){
			rs.data[i]="";	
		}
	}
		this.setFilterCriteria(rs);
	</cfscript>
    <!--- 
	listingDataTable must be enforced globally when application scope has set it to true.
	
	
	filter_listing_sub_type_id 
	0  Non-Matching Options 
	1 Non-Matching Options + Listings
	2 Matching Options 
	3 Matching Options + Listings
	 --->
     
    <cfsavecontent variable="whereSQL"> 
        <cfif rs.hideListings["search_city_id"] and this.filterCriteria.search_city_id NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_city_id"]);
			</cfscript>
        and  listing.listing_city #ss10.listSQL# (#this.filterCriteria.search_city_id#) 
        <cfscript>
		rs.citySQL=" and listing.listing_city #ss10.listSQL# (#this.filterCriteria.search_city_id#) ";
		</cfscript>
    </cfif>
        <cfif rs.hideListings["search_rate"] and (this.filterCriteria.search_rate_low NEQ this.defaultSearchCriteria.search_rate_low or this.filterCriteria.search_rate_high NEQ this.defaultSearchCriteria.search_rate_high)>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_rate"]);
			</cfscript>
        and (listing_price #ss10.BETWEENSQL# #this.filterCriteria.search_rate_low# AND #this.filterCriteria.search_rate_high#)
        </cfif>
        
        <cfif rs.hideListings["search_lot_square_feet"] and (this.filterCriteria.search_lot_square_feet_low NEQ this.defaultSearchCriteria.search_lot_square_feet_low or this.filterCriteria.search_lot_square_feet_high NEQ this.defaultSearchCriteria.search_lot_square_feet_high)>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_lot_square_feet"]);
			</cfscript>
        and listing_lot_square_feet  #ss10.BETWEENSQL# #this.filterCriteria.search_lot_square_feet_low# AND #this.filterCriteria.search_lot_square_feet_high#
        </cfif>
        <cfif rs.hideListings["search_sqfoot"] and (this.filterCriteria.search_sqfoot_low NEQ this.defaultSearchCriteria.search_sqfoot_low or this.filterCriteria.search_sqfoot_high NEQ this.defaultSearchCriteria.search_sqfoot_high)>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_sqfoot"]);
			</cfscript>
        and listing_square_feet  #ss10.BETWEENSQL# #this.filterCriteria.search_sqfoot_low# AND #this.filterCriteria.search_sqfoot_high#
        </cfif>
        <cfif rs.hideListings["search_acreage"] and (this.filterCriteria.search_acreage_low NEQ this.defaultSearchCriteria.search_acreage_low or this.filterCriteria.search_acreage_high NEQ this.defaultSearchCriteria.search_acreage_high)>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_acreage"]);
			</cfscript>
        and listing_acreage  #ss10.BETWEENSQL# #this.filterCriteria.search_acreage_low# AND #this.filterCriteria.search_acreage_high#
        </cfif>
        <cfif rs.hideListings["search_year_built"] and (this.filterCriteria.search_year_built_low NEQ this.defaultSearchCriteria.search_year_built_low or this.filterCriteria.search_year_built_high NEQ this.defaultSearchCriteria.search_year_built_high)>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_year_built"]);
			</cfscript>
        and listing_year_built  #ss10.BETWEENSQL# #this.filterCriteria.search_year_built_low# AND #this.filterCriteria.search_year_built_high#
        </cfif> 

        <cfif rs.hideListings["search_bedrooms"] and (this.filterCriteria.search_bedrooms_low NEQ this.defaultSearchCriteria.search_bedrooms_low or this.filterCriteria.search_bedrooms_high NEQ this.defaultSearchCriteria.search_bedrooms_high)>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_bedrooms"]);
			</cfscript>
        and listing_beds  #ss10.BETWEENSQL# #this.filterCriteria.search_bedrooms_low# and #this.filterCriteria.search_bedrooms_high#
        </cfif>
        <cfif rs.hideListings["search_bathrooms"] and (this.filterCriteria.search_bathrooms_low NEQ this.defaultSearchCriteria.search_bathrooms_low or this.filterCriteria.search_bathrooms_high NEQ this.defaultSearchCriteria.search_bathrooms_high)>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_bathrooms"]);
			</cfscript>
        and listing_baths  #ss10.BETWEENSQL# #this.filterCriteria.search_bathrooms_low# and #this.filterCriteria.search_bathrooms_high#
        </cfif>
        <cfif rs.hideListings["search_county"] and (this.filterCriteria.search_county NEQ "")>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_county"]);
			</cfscript>
            and listing_county #ss10.listSQL# (#this.filterCriteria.search_county#)
        </cfif>
        <cfif rs.hideListings["search_frontage"] and this.filterCriteria.search_frontage NEQ "">
            and (#this.filterCriteria.search_frontage#)
        </cfif>
        <cfif rs.hideListings["search_status"] and this.filterCriteria.search_status NEQ "">
            and (#this.filterCriteria.search_status#)
        </cfif>
        <cfif rs.hideListings["search_liststatus"] and this.filterCriteria.search_liststatus NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_liststatus"]);
			</cfscript>
            and listing_liststatus #ss10.listSQL# (#this.filterCriteria.search_liststatus#)
        </cfif>
        <cfif this.filterCriteria.search_tenure NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_tenure"]);
			</cfscript>
            and listing_tenure #ss10.listSQL# (#this.filterCriteria.search_tenure#)
        </cfif>
        <cfif this.filterCriteria.search_parking NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_parking"]);
			</cfscript>
            and listing_parking #ss10.listSQL# (#this.filterCriteria.search_parking#)
        </cfif>
        <cfif this.filterCriteria.search_condition NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_condition"]);
			</cfscript>
            and listing_condition #ss10.listSQL# (#this.filterCriteria.search_condition#)
        </cfif>
        <cfif rs.hideListings["search_style"] and this.filterCriteria.search_style NEQ "">
            and (#this.filterCriteria.search_style#)
        </cfif>
        <cfif rs.hideListings["search_view"] and this.filterCriteria.search_view NEQ "">
            and (#this.filterCriteria.search_view#)
        </cfif>
        <cfif this.filterCriteria.search_region NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_region"]);
			</cfscript>
        and listing_region #ss10.listSQL# (#this.filterCriteria.search_region#)
        </cfif>
        <cfif rs.hideListings["search_listing_type_id"] and this.filterCriteria.search_listing_type_id NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_listing_type_id"]);
			</cfscript>
        and listing.listing_type_id #ss10.listSQL# (#this.filterCriteria.search_listing_type_id#)
        </cfif>
        <cfif structkeyexists(rs.hideListings,"search_zip") and rs.hideListings["search_zip"] and this.filterCriteria.search_zip NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_zip"]);
			</cfscript>
        and listing.listing_zip #ss10.listSQL# (#this.filterCriteria.search_zip#)
        </cfif>
        <cfif structkeyexists(rs.hideListings,"search_subdivision") and rs.hideListings["search_subdivision"] and this.filterCriteria.search_subdivision NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_subdivision"]);
			</cfscript>
        and listing.listing_subdivision #ss10.listSQL# (#this.filterCriteria.search_subdivision#)
        </cfif> 
        <cfif rs.hideListings["search_listing_sub_type_id"] and this.filterCriteria.search_listing_sub_type_id NEQ "">
            and (#this.filterCriteria.search_listing_sub_type_id#)
        </cfif> 
         
    </cfsavecontent>
    
    <cfsavecontent variable="whereOptionsSQL">
        <cfif this.filterCriteria.search_city_id NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_city_id"]);
			</cfscript>
        and  listing.listing_city #ss10.listSQL# (#this.filterCriteria.search_city_id#) 
        <cfscript>
		rs.citySQL=" and listing.listing_city #ss10.listSQL# (#this.filterCriteria.search_city_id#) ";
		</cfscript>
    </cfif>
        <cfif this.filterCriteria.search_rate_low NEQ this.defaultSearchCriteria.search_rate_low or this.filterCriteria.search_rate_high NEQ this.defaultSearchCriteria.search_rate_high>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_rate"]);
			</cfscript>
        and (listing_price #ss10.BETWEENSQL# #this.filterCriteria.search_rate_low# AND #this.filterCriteria.search_rate_high#)
        </cfif>
        <cfif this.filterCriteria.search_sqfoot_low NEQ this.defaultSearchCriteria.search_sqfoot_low or this.filterCriteria.search_sqfoot_high NEQ this.defaultSearchCriteria.search_sqfoot_high>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_sqfoot"]);
			</cfscript>
        and listing_square_feet  #ss10.BETWEENSQL# #this.filterCriteria.search_sqfoot_low# AND #this.filterCriteria.search_sqfoot_high#
        </cfif>
        
        <cfif rs.hideListings["search_lot_square_feet"] and (this.filterCriteria.search_lot_square_feet_low NEQ this.defaultSearchCriteria.search_lot_square_feet_low or this.filterCriteria.search_lot_square_feet_high NEQ this.defaultSearchCriteria.search_lot_square_feet_high)>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_lot_square_feet"]);
			</cfscript>
        and listing_lot_square_feet  #ss10.BETWEENSQL# #this.filterCriteria.search_lot_square_feet_low# AND #this.filterCriteria.search_lot_square_feet_high#
        </cfif>
        
        <cfif this.filterCriteria.search_acreage_low NEQ this.defaultSearchCriteria.search_acreage_low or this.filterCriteria.search_acreage_high NEQ this.defaultSearchCriteria.search_acreage_high>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_acreage"]);
			</cfscript>
        and listing_acreage  #ss10.BETWEENSQL# #this.filterCriteria.search_acreage_low# AND #this.filterCriteria.search_acreage_high#
        </cfif>
        <cfif this.filterCriteria.search_year_built_low NEQ this.defaultSearchCriteria.search_year_built_low or this.filterCriteria.search_year_built_high NEQ this.defaultSearchCriteria.search_year_built_high>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_year_built"]);
			</cfscript>
        and listing_year_built  #ss10.BETWEENSQL# #this.filterCriteria.search_year_built_low# AND #this.filterCriteria.search_year_built_high#
        </cfif> 

        <cfif this.filterCriteria.search_bedrooms_low NEQ this.defaultSearchCriteria.search_bedrooms_low or this.filterCriteria.search_bedrooms_high NEQ this.defaultSearchCriteria.search_bedrooms_high>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_bedrooms"]);
			</cfscript>
        and listing_beds  #ss10.BETWEENSQL# #this.filterCriteria.search_bedrooms_low# and #this.filterCriteria.search_bedrooms_high#
        </cfif>
        <cfif this.filterCriteria.search_bathrooms_low NEQ this.defaultSearchCriteria.search_bathrooms_low or this.filterCriteria.search_bathrooms_high NEQ this.defaultSearchCriteria.search_bathrooms_high>
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_bathrooms"]);
			</cfscript>
        and listing_baths  #ss10.BETWEENSQL# #this.filterCriteria.search_bathrooms_low# and #this.filterCriteria.search_bathrooms_high#
        </cfif>
        <cfif this.filterCriteria.search_county NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_county"]);
			</cfscript>
            and listing_county #ss10.listSQL# (#this.filterCriteria.search_county#)
        </cfif>
        <cfif this.filterCriteria.search_frontage NEQ "">
            and (#this.filterCriteria.search_frontage#)
        </cfif>
        <cfif this.filterCriteria.search_status NEQ "">
            and (#this.filterCriteria.search_status#)
        </cfif>
        <cfif this.filterCriteria.search_liststatus NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_liststatus"]);
			</cfscript>
            and listing_liststatus #ss10.listSQL# (#this.filterCriteria.search_liststatus#)
        </cfif>
        
        <cfif this.filterCriteria.search_tenure NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_tenure"]);
			</cfscript>
            and listing_tenure #ss10.listSQL# (#this.filterCriteria.search_tenure#)
        </cfif>
        <cfif this.filterCriteria.search_parking NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_parking"]);
			</cfscript>
            and listing_parking #ss10.listSQL# (#this.filterCriteria.search_parking#)
        </cfif>
        <cfif this.filterCriteria.search_condition NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_condition"]);
			</cfscript>
            and listing_condition #ss10.listSQL# (#this.filterCriteria.search_condition#)
        </cfif>
        <cfif this.filterCriteria.search_style NEQ "">
            and (#this.filterCriteria.search_style#)
        </cfif>
        <cfif this.filterCriteria.search_view NEQ "">
            and (#this.filterCriteria.search_view#)
        </cfif>
        
        <cfif this.filterCriteria.search_region NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_region"]);
			</cfscript>
        and listing_region #ss10.listSQL# (#this.filterCriteria.search_region#)
        </cfif>
        <cfif this.filterCriteria.search_zip NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_zip"]);
			</cfscript>
        and listing.listing_zip #ss10.listSQL# (#this.filterCriteria.search_zip#)
        </cfif>
        <cfif this.filterCriteria.search_subdivision NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_subdivision"]);
			</cfscript>
        and listing.listing_subdivision #ss10.listSQL# (#this.filterCriteria.search_subdivision#)
        </cfif>
        <cfif this.filterCriteria.search_listing_type_id NEQ "">
	        <cfscript>
			ss10=getComparisonSQL(rs.type["search_listing_type_id"]);
			</cfscript>
        and listing.listing_type_id #ss10.listSQL# (#this.filterCriteria.search_listing_type_id#)
        </cfif>
        <cfif this.filterCriteria.search_listing_sub_type_id NEQ "">
            and (#this.filterCriteria.search_listing_sub_type_id#)
        </cfif> 
    </cfsavecontent>
  <cfif trim(whereSQL) NEQ "">
    	<cfsavecontent variable="whereSQL">
    and ((1=1 #whereSQL#) 
        <cfif arguments.sharedStruct.officeSQL NEQ ""> or (#arguments.sharedStruct.officeSQL#) </cfif>
        <cfif arguments.sharedStruct.agentSQL NEQ ""> or (#arguments.sharedStruct.agentSQL#) </cfif> )
        </cfsavecontent>
    </cfif>
    <cfif trim(whereOptionsSQL) NEQ "">
    	<cfsavecontent variable="whereOptionsSQL">
    and ((1=1 #whereOptionsSQL#) 
        <cfif arguments.sharedStruct.officeSQL NEQ ""> or (#arguments.sharedStruct.officeSQL#) </cfif>
        <cfif arguments.sharedStruct.agentSQL NEQ ""> or (#arguments.sharedStruct.agentSQL#) </cfif> )
        </cfsavecontent>
    </cfif>  
    
    <cfscript> 
	rs.whereOptionsSQL=replace(replace(whereOptionsSQL,"'% %'","'~~~~~&*^(%)^~~~~~'","ALL"),"'%, ,%'","'~~~~~&*^(%)^~~~~~'","ALL");
	rs.whereSQL=replace(replace(whereSQL,"'% %'","'~~~~~&*^(%)^~~~~~'","ALL"),"'%, ,%'","'~~~~~&*^(%)^~~~~~'","ALL"); 
	arguments.sharedStruct.filterStruct=rs;
	//application.zcore.functions.zdump(rs);
	//application.zcore.functions.zabort();
	</cfscript>
    <cfreturn rs>
</cffunction>
</cfoutput>
</cfcomponent>