<cfcomponent output="no">
<cfoutput>
	<cfscript>
	this.searchCriteria=structnew();
	this.searchCriteria2=structnew();
	this.searchCriteria.search_BATHROOMS_low="a";
	this.searchCriteria.search_bathrooms_high="b";
	this.searchCriteria.search_BEDROOMS_low="c";
	this.searchCriteria.search_bedrooms_high="d";
	this.searchCriteria.search_CITY_ID="e";
	this.searchCriteria.search_EXACT_MATCH="f";
	this.searchCriteria.search_MAP_COORDINATES_LIST="g";
	this.searchCriteria.search_listing_type_id="h";
	this.searchCriteria.search_listing_sub_type_id="i";
	this.searchCriteria.search_condoname="j";  
	this.searchCriteria.search_address="k";  
	this.searchCriteria.search_zip="l";  
	this.searchCriteria.search_rate_low="m";  
	this.searchCriteria.search_rate_high="n";  
	this.searchCriteria.search_SQFOOT_HIGH="o";
	this.searchCriteria.search_result_limit="p";
	this.searchCriteria.search_agent_always="q";
	this.searchCriteria.search_sort_agent_first="r";
	this.searchCriteria.search_office_always="s";
	this.searchCriteria.search_sort_office_first="t";
	this.searchCriteria.search_SQFOOT_LOW="u";
	this.searchCriteria.search_year_built_low="v";
	this.searchCriteria.search_year_built_high="w";
	this.searchCriteria.search_county="x";
	this.searchCriteria.search_frontage="y";
	this.searchCriteria.search_view="z";
	this.searchCriteria.search_remarks="aa";
	this.searchCriteria.search_style="bb";
	this.searchCriteria.search_mls_number_list="cc";
	this.searchCriteria.search_sort="dd";
	this.searchCriteria.search_listdate="ee";
    this.searchCriteria.search_near_address="ff";
	this.searchCriteria.search_near_coordinates="ff1";
	this.searchCriteria.search_near_radius="gg";
	//this.searchCriteria.search_sortppsqft="";
	//this.searchCriteria.search_new_first="";
	this.searchCriteria.search_remarks_negative="hh";
	this.searchCriteria.search_mls_number_list="ii";
	this.searchCriteria.search_acreage_low="jj";
	this.searchCriteria.search_acreage_high="kk";
	this.searchCriteria.search_status="ll";
	this.searchCriteria.search_SURROUNDING_CITIES='mm';
	this.searchCriteria.search_WITHIN_MAP="nn";
	this.searchCriteria.search_WITH_PHOTOS="oo";  
	this.searchCriteria.search_WITH_POOL="pp";   
	this.searchCriteria.search_agent_only="qq";
	this.searchCriteria.search_office_only="rr";
	this.searchCriteria.search_agent="ss";
	this.searchCriteria.search_office="tt";
	this.searchCriteria.search_subdivision="uu";
	this.searchCriteria.search_result_layout="vv";
	this.searchCriteria.search_result_limit="ww";
	this.searchCriteria.search_group_by="xx";
	this.searchCriteria.search_region="yy";
	this.searchCriteria.search_parking="zz";
	this.searchCriteria.search_condition="a1";
	this.searchCriteria.search_tenure="b1";
	this.searchCriteria.search_liststatus="c1";
	this.searchCriteria.search_lot_square_feet_low="d1";
	this.searchCriteria.search_lot_square_feet_high="e1";
	for(tempi in this.searchCriteria){
		this.searchCriteria2[this.searchCriteria[tempi]]=tempi;
	}
	
	this.rangeCriteria=structnew();
	this.rangeCriteria.search_bathrooms=true;
	this.rangeCriteria.search_bedrooms=true;
	this.rangeCriteria.search_rate=true;
	this.rangeCriteria.search_year_built=true;
	this.rangeCriteria.search_acreage=true;
	this.rangeCriteria.search_sqfoot=true;
	
	
	this.queryStringSearchToStruct(form);
	</cfscript>
    
     
	<cffunction name="getSearchCriteriaStruct" localmode="modern" access="public" returntype="struct" output="yes">

        <cfscript>
		var db=request.zos.queryObject;
		var rs=structnew();
		
		var primaryCityId=0;
		var label=0;
		var arrLabels=0;
		var arrD=0;
		var s2=0;
		var rs2=0;
		var arrLabel=0;
		var primaryCount=0;
		var tValue=0;
		var i2=0;
		var qCity=0;
		var tmp=0;
		var arrV=0;
		var cityIdList=0;
		var arrK3=0;
		var preValues=0;
		var qType=0;
		var preLabels=0;
		var qCity10=0;
		var arrK2=0;
		var nowyears=0;
		var sOut=0;
		var arrL=0;
		var cityUnq=0;
		var i=0;
		var selectedCityCount=0;
		var arrKeys=0;
		var arrValue=0;
		var s3=0;
		var g=0;
		</cfscript>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_city_id') EQ 1) and isDefined('searchFormHideCriteria.city') EQ false>
	<cfscript>
    primaryCount=1;
    primaryCityId=application.zcore.app.getAppData("listing").sharedStruct.mls_primary_city_id;
    selectedCityCount=1;
    if(application.zcore.functions.zso(form, 'search_city_id') NEQ ""){
        cityIdList="'"&replace(form.search_city_id,",","','","ALL")&"'";
        g=listgetat(form.search_city_id,1);
        selectedCityCount=listlen(form.search_city_id);
        if(isnumeric(g)){
            primaryCityId=g;	
        }
        
    }else{
        if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list NEQ ""){
            cityIdList="'"&application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list&"'";
            primaryCount=arraylen(listtoarray(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list));
        }else{
            cityIdList="'"&replace(primaryCityId,",","','","ALL")&"'";
        }
    }
    arrLabel=arraynew(1);
    arrValue=arraynew(1);
    rs2=structnew();
    rs2.labels="";
    rs2.values="";
    cityUnq=structnew();
	
    preLabels="";
    preValues="";
sOut=structnew();
    </cfscript>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_city SEPARATOR #db.trustedSQL("','")#) AS CHAR) idlist 
from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_city not in #db.trustedSQL("('','0','#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#')")#
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
	<cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");</cfscript>
    <cfif qtype.idlist NEQ "">
    <cfsavecontent variable="db.sql">
    select city_x_mls.city_name label, city_x_mls.city_id value 
	from #db.table("city_x_mls", request.zos.zcoreDatasource)# city_x_mls 
	WHERE city_x_mls.city_id IN (#db.trustedSQL(qtype.idlist)#) and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))#  and 
	city_id NOT IN (#db.trustedSQL("'#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#'")#)  and 
    city_x_mls_deleted = #db.param(0)#
          
    </cfsavecontent><cfscript>qCity=db.execute("qCity");</cfscript>
    <cfloop query="qCity"><cfscript>if(structkeyexists(cityUnq,qCity.label) EQ false){cityUnq[qCity.label]=qCity.value;}</cfscript></cfloop>
    </cfif>
    <!--- put the primary cities at top and repeat further down too --->
    <cfsavecontent variable="db.sql">
    select city.city_name label, city.city_id value 
	from #db.table("city_memory", request.zos.zcoreDatasource)# city 
	WHERE city_id IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list)#'")#) 
    and city_deleted = #db.param(0)#
	ORDER BY label 
    </cfsavecontent><cfscript>qCity10=db.execute("qCity10");
	arrK2=arraynew(1);
	arrK3=arraynew(1);
	if(qCity10.recordcount NEQ 0){
		for(i=1;i LTE qCity10.recordcount;i++){
			sOut[qCity10.label[i]]=true;
			arrayappend(arrK2,qCity10.label[i]);
			arrayappend(arrK3,qCity10.value[i]);
		}
		preLabels=arraytolist(arrK2,"|")&"|"&"-----------";
		preValues=arraytolist(arrK3,"|")&"|";
	}
	structdelete(cityUnq, "");
    arrKeys=structkeyarray(cityUnq);
    arraysort(arrKeys,"text","asc");
    for(i=1;i LTE arraylen(arrKeys);i++){
        if(structkeyexists(sOut,arrKeys[i]) EQ false){
            sOut[arrKeys[i]]=true;
            arrayappend(arrLabel,arrKeys[i]);
            arrayappend(arrValue,cityUnq[arrKeys[i]]);
        }
    }
    
	if(preValues EQ ""){
		rs2.labels=trim(arraytolist(arrLabel,"|"));
		rs2.values=trim(arraytolist(arrValue,"|"));
	}else{
		rs2.labels=trim(preLabels&"|"&arraytolist(arrLabel,"|"));
		rs2.values=trim(preValues&"|"&arraytolist(arrValue,"|"));
	}
    rs.city_id.labels=rs2.labels;
    rs.city_id.values=rs2.values;
    </cfscript>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_listing_type_id') EQ 1) and isDefined('searchFormHideCriteria.listing_type_id') EQ false>
	
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_type_id SEPARATOR #db.param(',')#) AS CHAR) idlist 
from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_type_id not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
         
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("listing_type",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
    
    rs.listing_type_id=structnew();
    rs.listing_type_id.values =arraytolist(arrV,"|");
    rs.listing_type_id.labels =arraytolist(arrL,"|");
    </cfscript>
</cfif>





<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_condition') EQ 1) and isDefined('searchFormHideCriteria.listing_condition') EQ false>
	
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_condition SEPARATOR #db.param(',')#) AS CHAR) idlist 
from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_condition not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
         
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("condition",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
    
    rs.condition=structnew();
    rs.condition.values =arraytolist(arrV,"|");
    rs.condition.labels =arraytolist(arrL,"|");
    </cfscript>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_parking') EQ 1) and isDefined('searchFormHideCriteria.listing_parking') EQ false>
	
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_parking SEPARATOR #db.param(',')#) AS CHAR) idlist 
from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_parking not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
         
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("parking",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
    
    rs.parking=structnew();
    rs.parking.values =arraytolist(arrV,"|");
    rs.parking.labels =arraytolist(arrL,"|");
    </cfscript>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_tenure') EQ 1) and isDefined('searchFormHideCriteria.listing_tenure') EQ false>
	
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_tenure SEPARATOR #db.param(',')#) AS CHAR) idlist 
from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_tenure not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
         
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("tenure",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
    
    rs.tenure=structnew();
    rs.tenure.values =arraytolist(arrV,"|");
    rs.tenure.labels =arraytolist(arrL,"|");
    </cfscript>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_region') EQ 1) and isDefined('searchFormHideCriteria.listing_region') EQ false>
	
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_region SEPARATOR #db.param(',')#) AS CHAR) idlist 
from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_region not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
         
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("region",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
    
    rs.region=structnew();
    rs.region.values =arraytolist(arrV,"|");
    rs.region.labels =arraytolist(arrL,"|");
    </cfscript>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_listing_sub_type_id') EQ 1) and isDefined('searchFormHideCriteria.listing_sub_type_id') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_sub_type_id SEPARATOR #db.param(',')#) AS CHAR) idlist 
    from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
    WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_sub_type_id not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        label=application.zcore.listingCom.listingLookupValue("listing_sub_type",i);
        arrLabels=listtoarray(label,",");
        for(i2=1;i2 LTE arraylen(arrLabels);i2++){
            tValue=application.zcore.listingCom.listingLookupNewId("listing_sub_type",trim(arrLabels[i2]));
            if(tValue NEQ ""){
                if(structkeyexists(s3,arrLabels[i2]) EQ false){
                    s3[arrLabels[i2]]=i;
                }else{
                    s3[arrLabels[i2]]&=","&i;	
                }
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	rs.listing_sub_type_id.values =arraytolist(arrV,"|");
	rs.listing_sub_type_id.labels =arraytolist(arrL,"|");
	</cfscript>
</cfif>


<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only NEQ 1>
	<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_county') EQ 1) and isDefined('searchFormHideCriteria.county') EQ false>
        
        <cfsavecontent variable="db.sql">
        SELECT cast(group_concat(distinct listing_county SEPARATOR #db.param(',')#) AS CHAR) idlist 
        from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
        WHERE 
        listing_deleted = #db.param(0)# and 
        #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

        listing_county not in (#db.param('')#) 
        <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
        </cfsavecontent><cfscript>qType=db.execute("qType");
        arrD=listtoarray(qType.idlist);
        arrL=[];
        arrV=[];
        s2=structnew();
        s3=structnew();
        for(i=1;i LTE arraylen(arrD);i++){
            s2[arrD[i]]=structnew();	
        }
        for(i in s2){
            tmp=application.zcore.listingCom.listingLookupValue("county",i);
            if(tmp NEQ ""){
                if(structkeyexists(s3,tmp) EQ false){
                    s3[tmp]=i;
                }else{
                    s3[tmp]&=","&i;	
                }
            }
        }
        structdelete(s3,'');
        arrL=structkeyarray(s3);
        arraysort(arrL,"text","asc");
        for(i=1;i LTE arraylen(arrL);i++){
            arrayappend(arrV,s3[arrL[i]]);
        }	
    
        rs.county.values =arraytolist(arrV,"|");
        rs.county.labels =arraytolist(arrL,"|");
        </cfscript>
    </cfif>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_view') EQ 1) and isDefined('searchFormHideCriteria.view') EQ false>


    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_view SEPARATOR #db.param(',')#) AS CHAR) idlist 
    from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
    WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_view not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("view",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	rs.view.values =arraytolist(arrV,"|");
	rs.view.labels =arraytolist(arrL,"|");
	</cfscript>
</cfif>

<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only NEQ 1>
	<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_status') EQ 1) and isDefined('searchFormHideCriteria.status') EQ false>
    
        <cfsavecontent variable="db.sql">
        SELECT cast(group_concat(distinct listing_status SEPARATOR #db.param(',')#) AS CHAR) idlist 
        from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
        WHERE 
        listing_deleted = #db.param(0)# and 
        #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

        listing_status not in (#db.param('')#) 
        <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
            <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
        </cfsavecontent><cfscript>qType=db.execute("qType");
        arrD=listtoarray(qType.idlist);
        arrL=[];
        arrV=[];
        s2=structnew();
        s3=structnew();
        for(i=1;i LTE arraylen(arrD);i++){
            s2[arrD[i]]=structnew();	
        }
        for(i in s2){
            tmp=application.zcore.listingCom.listingLookupValue("status",i);
            if(tmp NEQ ""){
                if(structkeyexists(s3,tmp) EQ false){
                    s3[tmp]=i;
                }else{
                    s3[tmp]&=","&i;	
                }
            }
        }
        structdelete(s3,'');
        arrL=structkeyarray(s3);
        arraysort(arrL,"text","asc");
        for(i=1;i LTE arraylen(arrL);i++){
            arrayappend(arrV,s3[arrL[i]]);
        }	
        if(structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'data.search_status')){
            arrS=listtoarray(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.data.search_status);
            arrV2=arraynew(1);
            arrL2=arraynew(1);
            for(i=1;i LTE arraylen(arrV);i++){
                m=false;
                for(n=1;n LTE arraylen(arrS);n++){
                    if(arrS[n] EQ arrV[i]){
                        m=true;
                        break;
                    }
                }
                if(m EQ false){
                    arrayAppend(arrV2,arrV[i]);
                    arrayAppend(arrL2,arrL[i]);
                }
            }
            arrV=arrV2;
            arrL=arrL2;
        }
        
        rs.status.values =arraytolist(arrV,"|");
        rs.status.labels =arraytolist(arrL,"|");
        </cfscript>
    </cfif>
</cfif>




<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_liststatus') EQ 1) and isDefined('searchFormHideCriteria.liststatus') EQ false>
	<cfsavecontent variable="db.sql">
	SELECT cast(group_concat(distinct listing_liststatus SEPARATOR #db.param(',')#) AS CHAR) idlist 
    from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
    WHERE 
    listing_deleted = #db.param(0)# and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

	listing_liststatus not in (#db.param('')#) 
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
		<cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
	</cfsavecontent><cfscript>qType=db.execute("qType");
	arrD=listtoarray(qType.idlist);
	arrL=[];
	arrV=[];
	s2=structnew();
	s3=structnew();
	for(i=1;i LTE arraylen(arrD);i++){
		s2[arrD[i]]=structnew();	
	}
	for(i in s2){
		tmp=application.zcore.listingCom.listingLookupValue("liststatus",i);
		if(tmp NEQ ""){
			if(structkeyexists(s3,tmp) EQ false){
				s3[tmp]=i;
			}else{
				s3[tmp]&=","&i;	
			}
		}
	}
	structdelete(s3,'');
	arrL=structkeyarray(s3);
	arraysort(arrL,"text","asc");
	for(i=1;i LTE arraylen(arrL);i++){
		arrayappend(arrV,s3[arrL[i]]);
	}	
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'data.search_liststatus')){
		arrS=listtoarray(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.data.search_liststatus);
		arrV2=arraynew(1);
		arrL2=arraynew(1);
		for(i=1;i LTE arraylen(arrV);i++){
			m=false;
			for(n=1;n LTE arraylen(arrS);n++){
				if(arrS[n] EQ arrV[i]){
					m=true;
					break;
				}
			}
			if(m EQ false){
				arrayAppend(arrV2,arrV[i]);
				arrayAppend(arrL2,arrL[i]);
			}
		}
		arrV=arrV2;
		arrL=arrL2;
	}
	
	rs.liststatus.values =arraytolist(arrV,"|");
	rs.liststatus.labels =arraytolist(arrL,"|");
	
	</cfscript>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_style') EQ 1) and isDefined('searchFormHideCriteria.style') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_style SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_style not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("style",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	rs.style.values =arraytolist(arrV,"|");
	rs.style.labels =arraytolist(arrL,"|");
	</cfscript>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_frontage') EQ 1) and isDefined('searchFormHideCriteria.frontage') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_frontage SEPARATOR #db.param(',')#) AS CHAR) idlist 
from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_frontage not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("frontage",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	rs.frontage.values =arraytolist(arrV,"|");
	rs.frontage.labels =arraytolist(arrL,"|");
	</cfscript>
</cfif>



<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_rate') EQ 1) and isDefined('searchFormHideCriteria.price') EQ false>
	<cfscript>
	rs.rate=structnew();
    if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
        rs.rate.labels="$0|$200|$400|$600|$800|$1,000|$1,200|$1,400|$1,600|$1,800|$2,000|$2,500|$3,000|$4,000|$5,000|$6,000|$7,000|$8,000|$9,000|$10,000|$20,000|$30,000|$40,000|$50,000|$100,000|$10,000,000";
        rs.rate.values="0|200|400|600|800|1000|1200|1400|1600|1800|2000|2500|3000|4000|5000|6000|7000|8000|9000|10000|20000|30000|40000|50000|100000|10000000";
    }else{
        rs.rate.labels="$0|$25,000|$50,000|$75,000|$100,000|$125,000|$150,000|$175,000|$200,000|$225,000|$250,000|$275,000|$300,000|$325,000|$350,000|$400,000|$450,000|$500,000|$600,000|$700,000|$800,000|$900,000|$1,000,000|$1,500,000|$2,000,000|$3,000,000|$4,000,000|$5,000,000";
        rs.rate.values="0|25000|50000|75000|100000|125000|150000|175000|200000|225000|250000|275000|300000|325000|350000|400000|450000|500000|600000|700000|800000|900000|1000000|1500000|2000000|3000000|4000000|5000000";
    }
    </cfscript>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_bedrooms') EQ 1) and isDefined('searchFormHideCriteria.bedrooms') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_beds SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_beds not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    structdelete(s2,'');
    arrL=structkeyarray(s2);
    arraysort(arrL,"numeric","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,arrL[i]);
    }
	rs.bedrooms=structnew();
	rs.bedrooms.values=arraytolist(arrV,"|");
	rs.bedrooms.labels=arraytolist(arrV,"|");
	</cfscript>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_bathrooms') EQ 1) and isDefined('searchFormHideCriteria.baths') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT  cast(group_concat(distinct listing_baths SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_baths not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    structdelete(s2,'');
    arrL=structkeyarray(s2);
    arraysort(arrL,"numeric","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,arrL[i]);
    }
	rs.bathrooms=structnew();
	rs.bathrooms.values =arraytolist(arrV,"|");
	rs.bathrooms.labels =arraytolist(arrV,"|");
	</cfscript>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_lot_square_feet') EQ 1) and isDefined('searchFormHideCriteria.lot_square_feet') EQ false>
	<cfsavecontent variable="db.sql">
    SELECT listing_lot_square_feet from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_square_feet not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent>
    <cfscript>
	qType=db.execute("qType");
    </cfscript>
	<cfif qType.recordcount NEQ 0>
		<cfscript>
		rs.lot_square_feet=structnew();
        rs.lot_square_feet.labels="0|500|750|1000|1250|1500|1750|2000|2250|2500|2750|3000|3250|3500|4000|4500|5000|6000|7000|8000|9000|10000|15000|20000";
        rs.lot_square_feet.values = "0|500|750|1000|1250|1500|1750|2000|2250|2500|2750|3000|3250|3500|4000|4500|5000|6000|7000|8000|9000|10000|15000|20000";
        </cfscript>
    </cfif>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_sqfoot') EQ 1) and isDefined('searchFormHideCriteria.square_feet') EQ false>
	<cfsavecontent variable="db.sql">
    SELECT listing_square_feet from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_square_feet not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent>
    <cfscript>
	qType=db.execute("qType");
    </cfscript>
	<cfif qType.recordcount NEQ 0>
		<cfscript>
		rs.sqfoot=structnew();
        rs.sqfoot.labels="0|500|750|1000|1250|1500|1750|2000|2250|2500|2750|3000|3250|3500|4000|4500|5000|6000|7000|8000|9000|10000|15000|20000";
        rs.sqfoot.values = "0|500|750|1000|1250|1500|1750|2000|2250|2500|2750|3000|3250|3500|4000|4500|5000|6000|7000|8000|9000|10000|15000|20000";
        </cfscript>
    </cfif>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_year_built') EQ 1) and isDefined('searchFormHideCriteria.year_built') EQ false>

	<cfscript>
	nowyears="";
	for(i=2010;i LTE year(now());i++){
		nowyears&="|"&i;
	}
    rs.year_built=structnew();
    rs.year_built.labels= "<1920|1920|1930|1940|1950|1960|1970|1980|1990|1995|2000|2001|2002|2003|2004|2005|2006|2007|2008|2009#nowyears#|Future";
    rs.year_built.values = "1800|1920|1930|1940|1950|1960|1970|1980|1990|1995|2000|2001|2002|2003|2004|2005|2006|2007|2008|2009#nowyears#|#year(now())+3#";
    </cfscript>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_acreage') EQ 1) and isDefined('searchFormHideCriteria.acreage') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT listing_acreage from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_acreage not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qType=db.execute("qType");</cfscript>
    
	<cfif qType.recordcount NEQ 0>
		<cfscript>
		rs.acreage=structnew();
        rs.acreage.labels = "0+|0.25+|0.5+|0.75+|1+|2+|3+|4+|5+|10+|20+|50+|100+";
        rs.acreage.values = "0|0.25|0.5|0.75|1|2|3|4|5|10|20|50|100";
        </cfscript>
    </cfif>
</cfif>



<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_subdivision') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_subdivision') EQ 1)>
    <cfsavecontent variable="db.sql">
    SELECT  cast(group_concat(distinct listing_subdivision SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_subdivision not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=i;
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	rs.subdivision=structnew();
	rs.subdivision.values =arraytolist(arrV,"|");
	rs.subdivision.labels =arraytolist(arrV,"|");
	</cfscript>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_condoname') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_condoname') EQ 1)>
    <cfsavecontent variable="db.sql">SELECT cast(group_concat(distinct listing_condoname SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_condoname not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=i;
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	rs.condoname=structnew();
	rs.condoname.values =arraytolist(arrV,"|");
	rs.condoname.labels =arraytolist(arrV,"|");
	</cfscript>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_zip') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_zip') EQ 1)>
    <cfsavecontent variable="db.sql">SELECT cast(group_concat(distinct listing_zip SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_condoname not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=i;
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	rs.zip=structnew();
	rs.zip.values =arraytolist(arrV,"|");
	rs.zip.labels =arraytolist(arrV,"|");
    </cfscript>
</cfif>


<cfscript>
rs.listdate=structnew();
rs.listdate.values ="Show All|New|Up to 3 days old|Up to 1 week old|Up to 2 weeks old|Up to 1 month old|Up to 3 months old|Up to 6 months old|Up to 12 months old";
rs.listdate.labels ="Show All|New|Up to 3 days old|Up to 1 week old|Up to 2 weeks old|Up to 1 month old|Up to 3 months old|Up to 6 months old|Up to 12 months old";

/*
if(isDefined('search_result_limit') and isDefined('search_result_layout') and search_result_layout EQ 2){
	ts.listValues ="9|15|21|27|33|39|45|54";
}else{
	ts.listValues ="10|15|20|25|30|35|40|50";
}*/

/*
rs.group_by=structnew();
rs.group_by.values="0|1";
rs.group_by.labels="0|1";
*/

/*
rs.result_layout.values ="0|1|2";
rs.result_layout.labels ="Detail|List|Thumbnail";
*/
rs.result_limit.values ="10|15|20|25|30|35|40|50";
rs.result_limit.labels="10|15|20|25|30|35|40|50";

if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
	rs.sort.values ="priceasc|pricedesc|newfirst|nosort";
	rs.sort.labels ="Price Ascending|Price Descending|Newest Listings First|No Sorting";
}else{
	rs.sort.values ="priceasc|pricedesc|newfirst|nosort|sortppsqftasc|sortppsqftdesc";
	rs.sort.labels ="Price Ascending|Price Descending|Newest Listings First|No Sorting|Price/SQFT Ascending|Price/SQFT Descending";
}
	return rs;
</cfscript>
        
        
        
        
    </cffunction>
    
    
	<cffunction name="queryStringSearchToStruct" localmode="modern" access="public" returntype="any" output="no">
    	<cfargument name="sharedStruct" type="struct" required="yes">
    	<cfscript>
		
		
		local.i=0;
		for(local.i in form){
			if(structkeyexists(this.searchCriteria2, local.i) and isSimpleValue(form[local.i]) and form[local.i] NEQ "" and form[local.i] NEQ 0){
				arguments.sharedStruct[this.searchCriteria2[local.i]]=form[local.i];
			}
		}
		</cfscript>
    </cffunction>
	<cffunction name="formVarsToURL" localmode="modern" access="public" returntype="any" output="yes">
    	<cfargument name="sharedStruct" type="struct" required="yes">
    	<cfscript>
		
		local.i=0;
		local.arrURL=arraynew(1);
		for(local.i in arguments.sharedStruct){
			if(structkeyexists(this.searchCriteria, local.i) and isSimpleValue(arguments.sharedStruct[local.i]) and arguments.sharedStruct[local.i] NEQ "" and arguments.sharedStruct[local.i] NEQ 0){
				arrayAppend(local.arrURL, this.searchCriteria[local.i]&"="&urlencodedformat(arguments.sharedStruct[local.i]));
			}
		}
		return arraytolist(local.arrURL,"&");
		</cfscript>
    </cffunction>

	<cffunction name="g" localmode="modern" access="remote" returntype="string" output="yes"><cfscript>
		var db=request.zos.queryObject;application.zcore.tracking.backOneHit();
		var n=0;
        var perpage=0;
        var returnStruct=0;
        var arrN=0;
        var jsonText=0;
        var start=0;
        var arrN2=0;
        var propertyDataCom=0;
        var qs=0;
        var out=0;
        var ts=0;
        var aobj=0;
        var offset=0;
        var i=0;
        var theQuerySQL=0;
        var propDisplayCom=0;
            
        if(not application.zcore.app.siteHasApp("listing")){
            application.zcore.functions.z404("Listing app is not enabled on this site.");
        }
	form.debugSearchForm=application.zcore.functions.zso(form, 'debugsearchForm',false,false);
	if(structkeyexists(form,'x_ajax_id') EQ false){
		form.x_ajax_id='';
		application.zcore.functions.zabort();
	}
	request.forceHighOffset=true;
	start=gettickcount();
	for(i in form){
		form[i]=urldecode(form[i]);	
		if(left(i, 7) EQ "search_" and isSimpleValue(form[i]) and form[i] EQ 0){
			form[i]='';
		}
	} 
	offset=application.zcore.functions.zso(form, 'of',true,10);
	propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
	ts = StructNew();
	ts.offset = offset;
	ts.forceSimpleLimit=true;
	perpage=application.zcore.functions.zso(form, 'perpage',true,3);
	ts.perpage = perpage;
	ts.distance = 30; // in miles
	if(form.debugSearchForm){
		ts.debug=true;
		structappend(form,url,false);
	}
	
	
	//ts.onlyCount=true;
	if(structcount(form) EQ 0 and structkeyexists(form, 'searchId')){
		tempStruct=duplicate(application.zcore.status.getStruct(form.searchid).varStruct);
		structappend(form,tempStruct,true);
	} 
	if(structkeyexists(form, 'first') EQ false){
		ts.disableCount=true;
	}
    if(not structkeyexists(form, 'search_liststatus') or form.search_liststatus EQ ""){
        form.search_liststatus="1";
    }
	qs=formVarsToURL(form);
	/*
	for(i in form){
		qs&="&"&lcase(i)&"="&form[i];	
	}*/
	propertyDataCom.setSearchCriteria(form);
	</cfscript><cfsavecontent variable="theQuerySQL"><cfscript>
	returnStruct= propertyDataCom.getProperties(ts);</cfscript></cfsavecontent><cfscript>
	propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
	ts = StructNew();
	ts.baseCity = 'db';
	ts.datastruct = returnStruct;
	ts.searchScript=false;
	ts.compact=true;
	ts.getdetails=false;
	ts.mapFormat=true;
	propDisplayCom.init(ts);
	if(not structkeyexists(form, 'first')){
		aobj=propDisplayCom.getAjaxObject(true);
	}else{
		aobj=propDisplayCom.getAjaxObject();
	}
	arrN=arraynew(1);
	for(i in aobj.data){
		arrN2=arraynew(1);
		for(n=1;n LTE arraylen(aobj.data[i]);n++){
			if(arrayIsDefined(aobj.data[i],n)){
				arrayappend(arrN2, jsstringformat(aobj.data[i][n]));
			}else{
				arrayappend(arrN2, "");
			}
		}
		arrayappend(arrN,'"'&lcase(i)&'":["'&arraytolist(arrN2,'","')&'"]');
	}
	if(form.debugSearchForm){
		arrayappend(arrN, '"debugsql":"#replace(jsstringformat(replace(replace(replace(replace(theQuerySQL,'"',"'","all"),chr(9)," ","all"),chr(13)," ","all"),chr(10)," ","all")),"\'","'","all")#"');
	}
	//jsonText='{"loadtime":"#((gettickcount()-start)/1000)# seconds","count":#returnStruct.count#,"offset":#offset#,"success":true,"qs":"#jsstringformat(qs)#",#arraytolist(arrN,",")#,"debugsql":"#(replace(replace(rereplace(theQuerySQL,"<[^>]*>"," ","all"),chr(13)," ","all"),chr(10)," ","all"))#"}';
	
	// "query":"#jsstringformat(replace(trim(replace(theQuerySQL,'<br />',chr(10),'all')),chr(10)&chr(10), chr(10),'all'))#",
	
	jsonText='{"loadtime":"#((gettickcount()-start)/1000)# seconds","count":#returnStruct.count#,"offset":#offset#,"success":true,"qs":"#jsstringformat(qs)#",#arraytolist(arrN,",")#}';
	
	</cfscript><cfheader name="x_ajax_id" value="#form.x_ajax_id#"><cfsavecontent variable="out">#jsonText#</cfsavecontent>#out#<cfscript>application.zcore.functions.zabort();</cfscript>
	</cffunction>
    
    <cffunction name="s" localmode="modern" output="yes" access="remote" returntype="any">
    <cfscript>
		var db=request.zos.queryObject;
	application.zcore.functions.zRequireJquery();
	application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
	 
	structdelete(form,'search_result_limit');
	actionQueryString=formVarsToURL(form); 
	</cfscript> 
    <div id="debugInfo" style="position:fixed;display:none; left:10px; top:200px; width:200px; height:200px; float:left;"><textarea id="debugInfoTextArea" name="debugInfoTextArea" cols="100" rows="10"></textarea></div>
 
<div id="zScrollArea" style="overflow:hidden;  width:100%; float:left; ">
</div>
  <div id="zMapCanvas" style="width:25%; display:none; position:fixed; left:0px; top:40px; z-index:2;"><div id="zMapCanvas2" style="float:left; width:100%;"></div></div>
  <div id="zMapCanvas3" style="width:25%; display:none; position:fixed; left:0px; top:0px; z-index:2;"><div id="zMapCanvas4" style="float:left; width:100%;"></div></div>
<br />

<cfsavecontent variable="scriptHTML"> 
<script>/* <![CDATA[ */ var zlsQueryString="#jsstringformat(actionQueryString)#";/* ]]> */</script>
 
 </cfsavecontent>
 <cfscript>
 application.zcore.template.appendTag("meta",scriptHTML);
 </cfscript>
    </cffunction>
    
    <cffunction name="searchForm" localmode="modern" output="yes" returntype="any">
    	
        
        <cfscript>
		var db=request.zos.queryObject;
		
		application.zcore.functions.zDisbleEndFormCheck();
		if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
			writeoutput('.<!-- stop spamming -->');
			application.zcore.functions.zabort();
		}
		 if(request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink()){
		 application.zcore.template.settag("title","Search Results");
		 application.zcore.template.settag("pagetitle","");
		 }
		if(structkeyexists(form, 'debugSearchForm') and form.debugSearchForm){
			form.debugSearchForm=true;
		}else{
			form.debugSearchForm=false;
		}
		if(structkeyexists(form, 'debugSearchResults') and form.debugSearchResults){
			form.debugSearchResults=true;	
		}else{
			form.debugSearchResults=false;
		}
		searchFormLabelOnInput=false;
		if(isDefined('request.searchFormSelectWidth')){
			searchFormSelectWidth=request.searchFormSelectWidth;
		}else{
			searchFormSelectWidth=application.zcore.functions.zso(form, 'searchFormSelectWidth',false,'165px');
		}
		searchFormSelectWidth="100%";
		searchFormEnabledDropDownMenus=false;//application.zcore.functions.zso(form, 'searchFormEnabledDropDownMenus',false,false);
		searchDisableExpandingBox=true;//application.zcore.functions.zso(form, 'searchDisableExpandingBox',false,false);
		if(isboolean(searchFormEnabledDropDownMenus) EQ false){
			searchFormEnabledDropDownMenus=false;
		}
		form.action=application.zcore.functions.zso(form, 'action',false,'form');
		if(application.zcore.app.siteHasApp("listing") EQ false){// or (application.zcore.functions.zso(form, 'SEARCH_SORT') NEQ "" and isnumeric(application.zcore.functions.zso(form, 'SEARCH_SORT')) EQ false)){
			application.zcore.functions.z301redirect('/');
		}
		
		search_listdate=application.zcore.functions.zso(form, 'search_listdate');
		
		
		if(request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink()){
			request.zForceListingSidebar=true; 
		}
		if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_disable_search',true) EQ 1 and application.zcore.functions.zso(request,'contentEditor',false,false) EQ false){
			application.zcore.functions.z301redirect('/');	
		}
		sfSortStruct=structnew();
		sfSortStruct["startFormTag"]="";
		sfSortStruct["endFormTag"]="";
		sfSortStruct["search_sqfoot"]="";
		sfSortStruct["search_sqfoot_low"]="";
		sfSortStruct["search_sqfoot_high"]="";
		sfSortStruct["search_rate_low"]="";
		sfSortStruct["search_rate_high"]="";
		sfSortStruct["search_city_id"]="";
		sfSortStruct["search_rate"]="";
		sfSortStruct["search_listing_type_id"]="";
		sfSortStruct["search_listing_sub_type_id"]="";
		sfSortStruct["search_bedrooms"]="";
		sfSortStruct["search_bathrooms"]="";
		sfSortStruct["search_year_built"]="";
		sfSortStruct["search_acreage"]="";
		sfSortStruct["search_county"]="";
		sfSortStruct["search_view"]="";
		sfSortStruct["search_status"]="";
		sfSortStruct["search_liststatus"]="";
		sfSortStruct["search_style"]="";
		sfSortStruct["search_frontage"]="";
        sfSortStruct["search_near_address"]="";
		sfSortStruct["search_near_coordinates"]="";
		sfSortStruct["search_more_options"]="";
		sfSortStruct["search_listdate"]="";
		sfSortStruct["search_sort"]="";
		sfSortStruct["search_result_limit"]="";
		sfSortStruct["search_checkboxes"]="";
		sfSortStruct["search_mls_number_list"]="";
		sfSortStruct["search_address"]="";
		sfSortStruct["search_zip"]="";
		sfSortStruct["search_remarks_negative"]="";
		sfSortStruct["search_result_layout"]="";
		sfSortStruct["search_group_by"]="";
		sfSortStruct["search_remarks"]="";
		sfSortStruct["search_condoname"]="";
		sfSortStruct["search_subdivision"]="";
		sfSortStruct["search_region"]="";
		sfSortStruct["search_condition"]="";
		sfSortStruct["search_tenure"]="";
		sfSortStruct["search_parking"]="";
		sfSortStruct["formSubmitButton"]="";
		 
		 if(request.zos.originalURL NEQ request.zos.listing.functions.getSearchFormLink()){
			 form.zsearch_bid='';
			 form.zsearch_cid='';
			 form.searchid='';
			 structdelete(request,'zForceSearchId');
		 }
		if(application.zcore.functions.zso(form, 'zsearch_cid') NEQ ''){
			db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content, 
			#db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
			WHERE mls_saved_search.mls_saved_search_id = content.content_saved_search_id and 
            mls_saved_search_deleted = #db.param(0)# and 
			mls_saved_search.site_id = content.site_id and 
			content.site_id = #db.param(request.zos.globals.id)# and 
			content_search_mls= #db.param(1)# and 
			content.content_id = #db.param(form.zsearch_cid)#  and 
			content_deleted=#db.param('0')#";
			qc23872=db.execute("qc23872"); 
			if(qc23872.recordcount NEQ 0){
				overrideTitle=qc23872.content_name;
				temp238722=structnew();
				temp23872=structnew();
				application.zcore.functions.zQueryToStruct(qc23872,temp238722);
				request.zos.listing.functions.zMLSSetSearchStruct(temp23872,temp238722);
				form.searchId=application.zcore.status.getNewId();
				request.zsession.tempVars.zListingSearchId=form.searchId;
				application.zcore.status.setStatus(form.searchid,false,temp23872);
			}else{
				application.zcore.functions.z301redirect('/');
			}
		}
		
		if(application.zcore.functions.zso(form, 'zsearch_bid') NEQ ''){
			 db.sql="SELECT * from blog, #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
			WHERE mls_saved_search.mls_saved_search_id = blog.mls_saved_search_id and 
            mls_saved_search_deleted = #db.param(0)# and
			blog.blog_search_mls= #db.param(1)# and 
			blog.site_id = #db.param(request.zos.globals.id)# and 
			blog_id= #db.param(form.zsearch_bid)# ";
			qc23872=db.execute("qc23872");
			if(qc23872.recordcount NEQ 0){
				overrideTitle=qc23872.blog_title;
				temp238722=structnew();
				temp23872=structnew();
				application.zcore.functions.zQueryToStruct(qc23872,temp238722);
				request.zos.listing.functions.zMLSSetSearchStruct(temp23872,temp238722);
				form.searchId=application.zcore.status.getNewId();
				request.zsession.tempVars.zListingSearchId=form.searchId;
				application.zcore.status.setStatus(form.searchid,false,temp23872);
			}else{
				application.zcore.functions.z301redirect('/');
			}
		}
		
		if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
			originalRentalIdList2=application.zcore.listingCom.listingLookupIdByName("listing_type","Commercial");
			originalRentalIdList=application.zcore.listingCom.listingLookupIdByName("listing_type","Rental" );
			originalRentalIdList=replace(originalRentalIdList&","&originalRentalIdList2,",,",",","ALL");
			rentalIdList="'"&replace(originalRentalIdList,",","','","ALL")&"'";
		}
		if(isDefined('request.contentEditor')){ request.zDisableSearchFormSubmit=true; }
		if((request.zos.istestserver EQ false and application.zcore.app.getAppData("listing").sharedStruct.resetCacheTimespan) or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct, 'searchCacheTimespan') EQ false){
			if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct, 'resetCacheTimespanInProgress') EQ false){
				application.zcore.app.getAppData("listing").sharedStruct.resetCacheTimespanInProgress=true;
				application.zcore.app.getAppData("listing").sharedStruct.searchCacheTimespan=createtimespan(0,0,0,2);
			}else{
				structdelete(request.zos.listing,"resetCacheTimespanInProgress");
				application.zcore.app.getAppData("listing").sharedStruct.resetCacheTimespan=false;
				application.zcore.app.getAppData("listing").sharedStruct.searchCacheTimespan=createtimespan(0,1,0,0);
			}
		}
		
		if(isDefined('saved_search_on')){
			if(isDefined('mls_saved_search_id') and mls_saved_search_id NEQ ''){
				db.sql="SELECT mls_saved_search_id FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
				WHERE mls_saved_search_id = #db.param(mls_saved_search_id)# and 
                mls_saved_search_deleted = #db.param(0)# ";
				qId=db.execute("qId"); 
				mls_saved_search_id=qid.mls_saved_search_id;
			}else{
				mls_saved_search_id="";
			}
			if(saved_search_on EQ 1) {
				mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', mls_saved_search_id, '', form);
			} else {
				mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('delete', mls_saved_search_id);
			}
		}
		
			if (isDefined('mls_saved_search_id')) {
				q2=request.zos.listing.functions.zGetSavedSearchQuery(mls_saved_search_id);
				myOwnStruct=structnew(); 
				application.zcore.functions.zquerytostruct(q2,myOwnStruct);
			}  
		
			
		
		if(structkeyexists(form, 'searchId') EQ false or isNumeric(form.searchid) EQ false or (isDefined('request.zForceSearchId') EQ false and (request.cgi_script_name EQ "/content/index.cfm" or request.cgi_script_name EQ "/index.cfm"))){
			form.searchId=application.zcore.status.getNewId();
		}
		if(structkeyexists(form, 'zIndex')){
			application.zcore.status.setField(form.searchid,'zIndex', form.zIndex);
		}else{
			application.zcore.status.setField(form.searchid,'zIndex',0);
		}
		if(structkeyexists(form,'search_city_id') or structkeyexists(form,'search_map_coordinates_list')){
			application.zcore.status.setStatus(form.searchid,false,form);
			ts=application.zcore.status.getStruct(form.searchid);
		}else{
			ts=application.zcore.status.getStruct(form.searchid);
			if(structkeyexists(ts,'varstruct')){
				structappend(form,ts.varStruct,true);
				structappend(variables,ts.varStruct,true);
			}
		}
		if(application.zcore.functions.zso(form, 'searchaction') EQ 'search'){
			application.zcore.functions.zRedirect(request.cgi_script_name&"?searchid=#form.searchid#");
		}
		
		variables.propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
		variables.zIndex=application.zcore.functions.zso(form, 'zIndex',false,1);
		if(isNumeric(variables.zIndex) EQ false){
			application.zcore.functions.zRedirect(request.cgi_script_name&"?searchid=#form.searchid#");
		}
		variables.zIndex=max(variables.zIndex,1);
		
		if(application.zcore.functions.zso(form, 'search_sort') CONTAINS ','){
			application.zcore.functions.z301redirect('/');	
		}
		form.search_surrounding_cities=application.zcore.functions.zso(form, 'search_surrounding_cities');
		if(form.search_surrounding_cities NEQ 1 and form.search_surrounding_cities NEQ 0 and form.search_surrounding_cities NEQ ""){
			application.zcore.functions.z301Redirect('/');	
		}
		
		forceSearchFormReset=false;
		curCacheTimeSpan=application.zcore.app.getAppData("listing").sharedStruct.searchCacheTimespan;
		if(structkeyexists(application.zcore,'searchformresetdate')){
			if(structkeyexists(application.sitestruct[request.zos.globals.id],'searchformresetdate') EQ false or DateCompare(application.zcore.searchformresetdate, application.sitestruct[request.zos.globals.id].searchformresetdate) NEQ 0){
				application.sitestruct[request.zos.globals.id].searchformresetdate=application.zcore.searchformresetdate;
				forceSearchFormReset=true;
				curCacheTimeSpan=CreateTimeSpan(0, 0, 0, 0);
				
			}
		}
		
		</cfscript>

<cfif structkeyexists(request,'theSearchFormTemplate') EQ false>
<cfsavecontent variable="request.theSearchFormTemplate">

    ##startFormTag##
    <div id="zMLSSearchFormLayout0">
        <div id="zMLSSearchFormLayout2">
            <div id="zMLSSearchFormLayout1">You can select an option multiple times to have multiple entries.</div>
            <div id="zMLSSearchFormLayout3">
            ##search_city_id##
            ##search_listing_type_id##
            ##search_liststatus##
            ##search_status##
            ##search_style##
        	</div>
            <div id="zMLSSearchFormLayout9">
            ##search_frontage##
            ##search_view##
            ##search_county##
            ##search_listing_sub_type_id##
            
            
            
        	</div>
            
            
            <div id="zMLSSearchFormLayout16">You can comma separate multiple entries</div>
            <div id="zMLSSearchFormLayout15">
            ##search_subdivision##
            ##search_condoname##
            ##search_zip##
            ##search_address##
            
            </div>
            <div id="zMLSSearchFormLayout4">
            ##search_remarks##
            ##search_remarks_negative##
            ##search_mls_number_list##
            </div>
            
        </div>
        <div id="zMLSSearchFormLayout5">
            <div id="zMLSSearchFormLayout6">
            Drag the sliders or type your values
            </div>
            <div id="zMLSSearchFormLayout7">
            
                <div id="zMLSSearchFormLayout8">
                ##search_rate##
                ##search_bedrooms##
                ##search_bathrooms##
                </div>
                <div id="zMLSSearchFormLayout10">
                ##search_sqfoot##
                ##search_year_built##
                ##search_acreage##
                </div>
            </div>
            <div id="zMLSSearchFormLayout17">&nbsp;</div>
            
            <div id="zMLSSearchFormLayout12">
            
            ##search_listdate##
            ##search_sort##
            <!--- ##search_result_limit##
            ##search_result_layout##
            ##search_group_by## --->
            </div>
            <div id="zMLSSearchFormLayout13">
            
            ##search_checkboxes##
            </div>
        </div>
        
        <div id="zMLSSearchFormLayout14">
        
        </div>
    </div>
    <script>
	/* <![CDATA[ */ 
	function d492(){
		//alert(zFormData['zMLSSearchForm'].arrFields.length);
		var a=document.getElementsByTagName("script");
		for(i=0;i<a.length;i++){
			if(a[i].src == "" && a[i].text.indexOf("search_rate_low") != -1){
				//console.log(a[i].text+"\n");
			}
		}
	}
	 /* ]]> */
	</script>
    ##endFormTag##

</cfsavecontent>
</cfif>


 <cfsavecontent variable="searchFormHTML">
 
 <cfsavecontent variable="startFormTagHTML">
 <div id="searchFormTopDiv" style="float:left;  width:100%; clear:both;"></div>

<script>/* <![CDATA[ */var zDisableSearchFormSubmit=<cfif application.zcore.functions.zso(request,'zDisableSearchFormSubmit',false,false)>true<cfelse>false</cfif>;/* ]]> */</script>
<cfscript>
if(isDefined('request.contentEditor') EQ false){
	//zdump(application.zcore.status.getStruct(form.searchid));
	ts=StructNew();
	ts.name="zMLSSearchForm";
	ts.ajax=false;
	ts.debug=form.debugSearchForm;
	if(request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' and structkeyexists(form, 'mls_saved_search_id')){
		ts.action="/z/listing/property/your-saved-searches/update?mls_saved_search_id="&form.mls_saved_search_id;
	}else{
		ts.action=application.zcore.functions.zURLAppend(request.zos.listing.functions.getSearchFormLink(), "searchaction=search&searchId=#form.searchid#");
		
	}
	if(form.debugSearchForm){
		ts.action&="&zreset=app";
	}
	tempSearchFormAction=ts.action;
	ts.onLoadCallback="loadMLSResults";
	ts.method="post";
	ts.ignoreOldRequests=false;
	ts.successMessage=false;
	ts.onChangeCallback="getMLSCount2";
	application.zcore.functions.zForm(ts);
}
//propertyDataCom.disableSearchCriteria();

if(isDefined('searchFormHideCriteria') EQ false){
	searchFormHideCriteria=structnew();	
}
if(isDefined('request.searchFormHideCriteria')){
	structappend(searchFormHideCriteria,request.searchFormHideCriteria);	
}
</cfscript>

<cfif form.debugSearchForm>
<script>/* <![CDATA[ */zDebugMLSAjax=true;/* ]]> */</script>
</cfif>
<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1>
<cfscript>
ts=structnew();
search_status='7';
ts.name="search_status";
application.zcore.functions.zinput_hidden(ts);
</cfscript>
</cfif>
<cfif form.debugSearchForm>
<input type="text" name="zreset" value="site" /> (site reset)<br />
</cfif>

 
 </cfsavecontent>
 <cfscript>
sfSortStruct["startFormTag"]=startFormTagHTML;
//writeoutput(startFormTagHTML);
</cfscript>
<cfsavecontent variable="theCriteriaHTML">


<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_city_id') EQ 1) and isDefined('searchFormHideCriteria.city') EQ false>
<cfscript>
primaryCount=1;
primaryCityId=application.zcore.app.getAppData("listing").sharedStruct.mls_primary_city_id;
selectedCityCount=1;
if(application.zcore.functions.zso(form, 'search_city_id') NEQ ""){
    cityIdList="'"&replace(form.search_city_id,",","','","ALL")&"'";
	g=listgetat(form.search_city_id,1);
	selectedCityCount=listlen(form.search_city_id);
	if(isnumeric(g)){
		primaryCityId=g;	
	}
	
}else{
	if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list NEQ ""){
		cityIdList="'"&application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list&"'";
		primaryCount=arraylen(listtoarray(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list));
	}else{
    	cityIdList="'"&replace(primaryCityId,",","','","ALL")&"'";
	}
}

    arrLabel=arraynew(1);
    arrValue=arraynew(1);
    rs2=structnew();
    rs2.labels="";
    rs2.values="";
    cityUnq=structnew();
	
    preLabels="";
    preValues="";
sOut=structnew();
    </cfscript>

<!--- 
set a primary city
set a list of cities
use default primary city from #request.zos.zcoreDatasource#.mls

for drop down, sort the primary cities to top.
 --->

    
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_city SEPARATOR #db.trustedSQL("','")#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
    WHERE 
    listing_deleted = #db.param(0)# and
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_city not in #db.trustedSQL("('','0','#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#')")# 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
	<cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");</cfscript>
    <cfsavecontent variable="db.sql">
    select city_x_mls.city_name label, city_x_mls.city_id value 
	from #db.table("city_x_mls", request.zos.zcoreDatasource)# city_x_mls 
	WHERE city_x_mls.city_id IN (#db.trustedSQL(qtype.idlist)#) and 
	#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))#  and 
    city_x_mls_deleted = #db.param(0)# and
	city_id NOT IN (#db.trustedSQL("'#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#'")#)  
          
    </cfsavecontent><cfscript>qCity=db.execute("qCity");</cfscript>
    <cfloop query="qCity"><cfscript>if(structkeyexists(cityUnq,qCity.label) EQ false){cityUnq[qCity.label]=qCity.value;}</cfscript></cfloop>
    <!--- put the primary cities at top and repeat further down too --->
    <cfsavecontent variable="db.sql">
    select city.city_name label, city.city_id value 
	from #db.table("city_memory", request.zos.zcoreDatasource)# city 
	WHERE city_id IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list)#'")#) and 
    city_deleted = #db.param(0)#
	ORDER BY label 
    </cfsavecontent><cfscript>qCity10=db.execute("qCity10");
	arrK2=arraynew(1);
	arrK3=arraynew(1);
	if(qCity10.recordcount NEQ 0){
		for(i=1;i LTE qCity10.recordcount;i++){
			sOut[qCity10.label[i]]=true;
			arrayappend(arrK2,qCity10.label[i]);
			arrayappend(arrK3,qCity10.value[i]);
		}
		preLabels=arraytolist(arrK2,chr(9))&chr(9)&"-----------";
		preValues=arraytolist(arrK3,chr(9))&chr(9);
	}
	
arrKeys=structkeyarray(cityUnq);
arraysort(arrKeys,"text","asc");
//arrKeys=structsort(cityUnq,"text","asc");
for(i=1;i LTE arraylen(arrKeys);i++){
	if(structkeyexists(sOut,arrKeys[i]) EQ false){
		sOut[arrKeys[i]]=true;
		arrayappend(arrLabel,arrKeys[i]);
		arrayappend(arrValue,cityUnq[arrKeys[i]]);
	}
}

rs2.labels=trim(preLabels&chr(9)&arraytolist(arrLabel,chr(9)));
rs2.values=trim(preValues&chr(9)&arraytolist(arrValue,chr(9)));
ts.listLabels=rs2.labels;
ts.listValues =rs2.values;
</cfscript>

<cfif rs2.labels NEQ "">
<div class="zmlsformdiv">
<cfscript>

ts = StructNew();
ts.name="search_city_id";
ts.enableTyping=false;
ts.overrideOnKeyUp=false;
ts.enableClickSelect=false;
ts.selectedOnTop=false;
ts.range=false;
ts.allowAnyText=false;
ts.disableSpider=true;
ts.listLabelsDelimiter = chr(9);
ts.listValuesDelimiter = chr(9);
ts.listLabels=rs2.labels;
ts.listValues =rs2.values;
ts.output=true;
ts.selectLabel="City";
ts.inlineStyle="width:#searchFormSelectWidth#;";
application.zcore.functions.zInputLinkBox(ts);
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_city_id"]=theCriteriaHTML;
</cfscript>
<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_listing_type_id') EQ 1) and isDefined('searchFormHideCriteria.listing_type_id') EQ false>
	

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_listing_type_id') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_type_id SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_type_id not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
         
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("listing_type",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	application.zcore.searchFormCache[request.zos.globals.id].search_listing_type_id=tv299;
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_listing_type_id);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>

ts = StructNew();
ts.name="search_listing_type_id";
ts.enableTyping=false;
ts.overrideOnKeyUp=false;
ts.enableClickSelect=false;
ts.selectedOnTop=false;
ts.range=false;
ts.allowAnyText=false;
ts.disableSpider=true;
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="Property Type";
ts.inlineStyle="width:#searchFormSelectWidth#;";
application.zcore.functions.zInputLinkBox(ts);
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_listing_type_id"]=theCriteriaHTML;
</cfscript>








<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_region') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_region') EQ 1) and isDefined('searchFormHideCriteria.region') EQ false>
	

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_region') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_region SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_region not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
          
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("listing_region",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_region=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_region);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_region";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(searchFormEnabledDropDownMenus){
	ts.output=true;
	if(searchFormLabelOnInput){
		ts.selectLabel="Region";
		ts.inlineStyle="width:#searchFormSelectWidth#;";
	}else{
		ts.label="Region:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Region:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_region"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_region"]=theCriteriaHTML;
</cfscript>





<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_parking') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_parking') EQ 1) and isDefined('searchFormHideCriteria.parking') EQ false>
	

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_parking') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_parking SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_parking not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
          
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("listing_parking",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_parking=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_parking);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_parking";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(searchFormEnabledDropDownMenus){
	ts.output=true;
	if(searchFormLabelOnInput){
		ts.selectLabel="Parking";
		ts.inlineStyle="width:#searchFormSelectWidth#;";
	}else{
		ts.label="Parking:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Parking:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_parking"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_parking"]=theCriteriaHTML;
</cfscript>




<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_condition') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_condition') EQ 1) and isDefined('searchFormHideCriteria.condition') EQ false>
	

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_condition') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_condition SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_condition not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
          
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("listing_condition",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_condition=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_condition);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_condition";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(searchFormEnabledDropDownMenus){
	ts.output=true;
	if(searchFormLabelOnInput){
		ts.selectLabel="Condition";
		ts.inlineStyle="width:#searchFormSelectWidth#;";
	}else{
		ts.label="Condition:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Condition:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_condition"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_condition"]=theCriteriaHTML;
</cfscript>




<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_tenure') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_tenure') EQ 1) and isDefined('searchFormHideCriteria.tenure') EQ false>
	

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_tenure') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_tenure SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_tenure not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
          
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("listing_tenure",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false){
application.zcore.searchFormCache[request.zos.globals.id].search_tenure=tv299;
}
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_tenure);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_tenure";
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=false;
if(searchFormEnabledDropDownMenus){
	ts.output=true;
	if(searchFormLabelOnInput){
		ts.selectLabel="Tenure";
		ts.inlineStyle="width:#searchFormSelectWidth#;";
	}else{
		ts.label="Tenure:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInput_Checkbox(ts);
	
	if(searchDisableExpandingBox){
		writeoutput(rs.output);
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Tenure:";
		ts.contents=rs.output;
		ts.height=40 + (arraylen(arrV) * 18);
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_tenure"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_tenure"]=theCriteriaHTML;
</cfscript>






<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_listing_sub_type_id') EQ 1) and isDefined('searchFormHideCriteria.listing_sub_type_id') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_listing_sub_type_id') EQ false>


    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_sub_type_id SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_sub_type_id not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        label=application.zcore.listingCom.listingLookupValue("listing_sub_type",i);
        arrLabels=listtoarray(label,",");
        for(i2=1;i2 LTE arraylen(arrLabels);i2++){
            tValue=application.zcore.listingCom.listingLookupNewId("listing_sub_type",trim(arrLabels[i2]));
            if(tValue NEQ ""){
                if(structkeyexists(s3,arrLabels[i2]) EQ false){
                    s3[arrLabels[i2]]=i;
                }else{
                    s3[arrLabels[i2]]&=","&i;	
                }
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	application.zcore.searchFormCache[request.zos.globals.id].search_listing_sub_type_id=tv299;
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_listing_sub_type_id);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>


ts = StructNew();
ts.name="search_listing_sub_type_id";
ts.enableTyping=false;
ts.overrideOnKeyUp=false;
ts.enableClickSelect=false;
ts.selectedOnTop=false;
ts.range=false;
ts.allowAnyText=false;
ts.disableSpider=true;
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="Type Subcategory";
ts.inlineStyle="width:#searchFormSelectWidth#;";
application.zcore.functions.zInputLinkBox(ts);


</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_listing_sub_type_id"]=theCriteriaHTML;
</cfscript>


<cfsavecontent variable="theCriteriaHTML">

<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only NEQ 1>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_county') EQ 1) and isDefined('searchFormHideCriteria.county') EQ false>
    
<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_county') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_county SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_county not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("county",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	application.zcore.searchFormCache[request.zos.globals.id].search_county=tv299;
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_county);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<!---<cfdump var="#arrL#">--->
<cfscript>

ts = StructNew();
ts.name="search_county";
ts.enableTyping=false;
ts.overrideOnKeyUp=false;
ts.enableClickSelect=false;
ts.selectedOnTop=false;
ts.range=false;
ts.allowAnyText=false;
ts.disableSpider=true;
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="County";
ts.inlineStyle="width:#searchFormSelectWidth#;";
application.zcore.functions.zInputLinkBox(ts);

</cfscript>
</div>
</cfif>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_county"]=theCriteriaHTML;
</cfscript>


<cfsavecontent variable="theCriteriaHTML">
<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only NEQ 1>
 </cfif>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_view') EQ 1) and isDefined('searchFormHideCriteria.view') EQ false>


<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_view') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_view SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_view not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("view",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	application.zcore.searchFormCache[request.zos.globals.id].search_view=tv299;
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_view);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>

ts = StructNew();
ts.name="search_view";
ts.enableTyping=false;
ts.overrideOnKeyUp=false;
ts.enableClickSelect=false;
ts.selectedOnTop=false;
ts.range=false;
ts.allowAnyText=false;
ts.disableSpider=true;
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="View";
ts.inlineStyle="width:#searchFormSelectWidth#;";
application.zcore.functions.zInputLinkBox(ts);

</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_view"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">
<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only NEQ 1>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_status') EQ 1) and isDefined('searchFormHideCriteria.status') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_status') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_status SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_status not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("status",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'data.search_status')){
		arrS=listtoarray(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.data.search_status);
		arrV2=arraynew(1);
		arrL2=arraynew(1);
		for(i=1;i LTE arraylen(arrV);i++){
			m=false;
			for(n=1;n LTE arraylen(arrS);n++){
				if(arrS[n] EQ arrV[i]){
					m=true;
					break;
				}
			}
			if(m EQ false){
				arrayAppend(arrV2,arrV[i]);
				arrayAppend(arrL2,arrL[i]);
			}
		}
		arrV=arrV2;
		arrL=arrL2;
	}
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	application.zcore.searchFormCache[request.zos.globals.id].search_status=tv299;
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_status);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_status";
ts.enableTyping=false;
ts.overrideOnKeyUp=false;
ts.enableClickSelect=false;
ts.selectedOnTop=false;
ts.range=false;
ts.allowAnyText=false;
ts.disableSpider=true;
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="Sale Type";
ts.inlineStyle="width:#searchFormSelectWidth#;";
application.zcore.functions.zInputLinkBox(ts);
</cfscript>
</div>
</cfif>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_status"]=theCriteriaHTML;
</cfscript>



<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_liststatus') EQ 1) and isDefined('searchFormHideCriteria.liststatus') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_liststatus') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_liststatus SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_liststatus not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("liststatus",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	if(structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'data.search_liststatus')){
		arrS=listtoarray(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.data.search_liststatus);
		arrV2=arraynew(1);
		arrL2=arraynew(1);
		for(i=1;i LTE arraylen(arrV);i++){
			m=false;
			for(n=1;n LTE arraylen(arrS);n++){
				if(arrS[n] EQ arrV[i]){
					m=true;
					break;
				}
			}
			if(m EQ false){
				arrayAppend(arrV2,arrV[i]);
				arrayAppend(arrL2,arrL[i]);
			}
		}
		arrV=arrV2;
		arrL=arrL2;
	}
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	application.zcore.searchFormCache[request.zos.globals.id].search_liststatus=tv299;
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_liststatus);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_liststatus";
ts.enableTyping=false;
ts.overrideOnKeyUp=false;
ts.enableClickSelect=false;
ts.selectedOnTop=false;
ts.range=false;
ts.allowAnyText=false;
ts.disableSpider=true;
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=true;
ts.onchange="zInactiveCheckLoginStatus(this);";
ts.selectLabel="Listing Status";
ts.inlineStyle="width:#searchFormSelectWidth#;";
application.zcore.functions.zInputLinkBox(ts);
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_liststatus"]=theCriteriaHTML;
</cfscript>





<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_style') EQ 1) and isDefined('searchFormHideCriteria.style') EQ false>
<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_style') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_style SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_style not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("style",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }	
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	application.zcore.searchFormCache[request.zos.globals.id].search_style=tv299;
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_style);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_style";
ts.enableTyping=false;
ts.overrideOnKeyUp=false;
ts.enableClickSelect=false;
ts.selectedOnTop=false;
ts.range=false;
ts.allowAnyText=false;
ts.disableSpider=true;
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="Style";
ts.inlineStyle="width:#searchFormSelectWidth#;";
application.zcore.functions.zInputLinkBox(ts);
ts = StructNew();
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_style"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_frontage') EQ 1) and isDefined('searchFormHideCriteria.frontage') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_frontage') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT cast(group_concat(distinct listing_frontage SEPARATOR #db.param(',')#) AS CHAR) idlist 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_frontage not in (#db.param('')#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    </cfsavecontent><cfscript>qType=db.execute("qType");
    arrD=listtoarray(qType.idlist);
    arrL=[];
    arrV=[];
    s2=structnew();
    s3=structnew();
    for(i=1;i LTE arraylen(arrD);i++){
        s2[arrD[i]]=structnew();	
    }
    for(i in s2){
        tmp=application.zcore.listingCom.listingLookupValue("frontage",i);
        if(tmp NEQ ""){
            if(structkeyexists(s3,tmp) EQ false){
                s3[tmp]=i;
            }else{
                s3[tmp]&=","&i;	
            }
        }
    }
    structdelete(s3,'');
    arrL=structkeyarray(s3);
    arraysort(arrL,"text","asc");
    for(i=1;i LTE arraylen(arrL);i++){
        arrayappend(arrV,s3[arrL[i]]);
    }
	tv299=structnew();
    tv299.arrV=arrV;
    tv299.arrL=arrL;
	application.zcore.searchFormCache[request.zos.globals.id].search_frontage=tv299;
    </cfscript>

<cfelse>
	<cfscript>
	tv299=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_frontage);
	arrV=tv299.arrV;
	arrL=tv299.arrL;
	</cfscript>
</cfif>
	
	
<cfif arraylen(arrL) NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts = StructNew();
ts.name="search_frontage";
ts.enableTyping=false;
ts.overrideOnKeyUp=false;
ts.enableClickSelect=false;
ts.selectedOnTop=false;
ts.range=false;
ts.allowAnyText=false;
ts.disableSpider=true;
ts.listValues =arraytolist(arrV,"|");
ts.listValuesDelimiter="|";
ts.listLabels =arraytolist(arrL,"|");
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="Frontage";
ts.inlineStyle="width:#searchFormSelectWidth#;";
application.zcore.functions.zInputLinkBox(ts);
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_frontage"]=theCriteriaHTML;
</cfscript>




<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_rate') EQ 1) and isDefined('searchFormHideCriteria.price') EQ false>
<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_rate_low";
ts.name2="search_rate_high";
ts.leftLabel="$";
ts.middleLabel="$";
ts.range=true;
//ts.onchange="document.getElementById('zist').value=this.value;";
ts.fieldWidth="59";
ts.width="150";
if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
	if(searchFormEnabledDropDownMenus){
		ts.listLabels="$0|$200|$400|$600|$800|$1,000|$1,200|$1,400|$1,600|$1,800|$2,000|$2,500|$3,000|$4,000|$5,000|$6,000|$7,000|$8,000|$9,000|$10,000|$20,000|$30,000|$40,000|$50,000|$100,000|$10,000,000";
	}else{
		ts.listLabels="0|200|400|600|800|1,000|1,200|1,400|1,600|1,800|2,000|2,500|3,000|4,000|5,000|6,000|7,000|8,000|9,000|10,000|20,000|30,000|40,000|50,000|100,000|10,000,000";
	}
	ts.listValues="0|200|400|600|800|1000|1200|1400|1600|1800|2000|2500|3000|4000|5000|6000|7000|8000|9000|10000|20000|30000|40000|50000|100000|10000000";
}else{
	if(searchFormEnabledDropDownMenus){
		ts.listLabels="$0|$25,000|$50,000|$75,000|$100,000|$125,000|$150,000|$175,000|$200,000|$225,000|$250,000|$275,000|$300,000|$325,000|$350,000|$400,000|$450,000|$500,000|$600,000|$700,000|$800,000|$900,000|$1,000,000|$1,500,000|$2,000,000|$3,000,000|$4,000,000|$5,000,000";
	}else{
		ts.listLabels="0|25,000|50,000|75,000|100,000|125,000|150,000|175,000|200,000|225,000|250,000|275,000|300,000|325,000|350,000|400,000|450,000|500,000|600,000|700,000|800,000|900,000|1,000,000|1,500,000|2,000,000|3,000,000|4,000,000|5,000,000";
	}
	ts.listValues="0|25000|50000|75000|100000|125000|150000|175000|200000|225000|250000|275000|300000|325000|350000|400000|450000|500000|600000|700000|800000|900000|1000000|1500000|2000000|3000000|4000000|5000000";
}
ts.listLabelsDelimiter="|";
ts.listValuesDelimiter="|";
ts.output=false;

	rs=application.zcore.functions.zInputSlider(ts);
	
	if(searchDisableExpandingBox){
		writeoutput('<div class="zmlsformlabel">Price Range</div><div class="zmlsformfield">'&rs.output&'</div>');
	}else{
	
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Price:";
		ts.contents=rs.output;
		ts.height="65";
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_rate"];
		application.zcore.functions.zExpOption(ts);
	}
</cfscript>
</div>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_rate"]=theCriteriaHTML;
</cfscript>
<cfsavecontent variable="theCriteriaHTML">

<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_bedrooms') EQ 1) and isDefined('searchFormHideCriteria.bedrooms') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_bedrooms') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT listing_beds from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_beds not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qType=db.execute("qType");
	tv299=structnew();
	tv299.recordcount=qType.recordcount;
	application.zcore.searchFormCache[request.zos.globals.id].search_bedrooms=tv299;
    </cfscript>
    
<cfelse>
	<cfscript>
	qType=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_bedrooms);
	</cfscript>
</cfif>
<cfif qType.recordcount NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_bedrooms_low";
ts.name2="search_bedrooms_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="33";
ts.width="150";
ts.listValues="1,2,3,4,5,6,7";
ts.listValuesDelimiter=",";
ts.output=false;
if(searchFormEnabledDropDownMenus){
	ts.output=true;
	ts.listLabels="1+,2+,3+,4+,5+,6+,7+";
	if(searchFormLabelOnInput){
		ts.selectLabel="Beds";
		ts.inlineStyle="width:#searchFormSelectWidth#;";
	}else{
		ts.label="Beds:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInputSlider(ts);
	if(searchDisableExpandingBox){
		writeoutput('<div class="zmlsformlabel">Bedrooms</div><div class="zmlsformfield">'&rs.output&'</div>');
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Beds:";
		ts.contents=rs.output;
		ts.height="65";
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_bedrooms"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_bedrooms"]=theCriteriaHTML;
</cfscript>
<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_bathrooms') EQ 1) and isDefined('searchFormHideCriteria.baths') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_bathrooms') EQ false>

    <cfsavecontent variable="db.sql">
    SELECT listing_baths 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_baths not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qType=db.execute("qType");
	tv299=structnew();
	tv299.recordcount=qType.recordcount;
	application.zcore.searchFormCache[request.zos.globals.id].search_bathrooms=tv299;
    </cfscript>
    
<cfelse>
	<cfscript>
	qType=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_bathrooms);
	</cfscript>
</cfif>
<cfif qType.recordcount NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_bathrooms_low";
ts.name2="search_bathrooms_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="33";
ts.width="150";
ts.listValues="1,2,3,4,5,6,7";
ts.listValuesDelimiter=",";
ts.output=false;
if(searchFormEnabledDropDownMenus){
	ts.output=true;
	ts.listLabels="1+,2+,3+,4+,5+,6+,7+";
	if(searchFormLabelOnInput){
		ts.selectLabel="Baths";
		ts.inlineStyle="width:#searchFormSelectWidth#;";
	}else{
		ts.label="Bath:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInputSlider(ts);
	
	if(searchDisableExpandingBox){
		writeoutput('<div class="zmlsformlabel">Bathrooms</div><div class="zmlsformfield">'&rs.output&'</div>');
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Baths:";
		ts.contents=rs.output;
		ts.height="65";
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_bathrooms"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>
</div>
</cfif>
</cfif>

</cfsavecontent>
<cfscript>
sfSortStruct["search_bathrooms"]=theCriteriaHTML;
</cfscript>


<cfsavecontent variable="theCriteriaHTML">
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_sqfoot') EQ 1) and isDefined('searchFormHideCriteria.square_feet') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_sqfoot') EQ false>
<cfsavecontent variable="db.sql">
    SELECT listing_square_feet 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_square_feet not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent>
    <cfscript>
	qType=db.execute("qType");
	tv299=structnew();
	tv299.recordcount=qType.recordcount;
	application.zcore.searchFormCache[request.zos.globals.id].search_sqfoot=tv299;
    </cfscript>
    
<cfelse>
	<cfscript>
	qType=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_sqfoot);
	</cfscript>
</cfif>
<cfif qType.recordcount NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_sqfoot_low";
ts.name2="search_sqfoot_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="33";
ts.width="150";
ts.listLabels="0,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000,3250,3500,4000,4500,5000,6000,7000,8000,9000,10000,15000,20000";
arrL=listtoarray(ts.listLabels,",");
for(i=1;i LTE arraylen(arrL);i++){
	arrL[i]=arrL[i]&"sqft ("&round(arrL[i]/10.7639)&"m&##178;)";
}
ts.listLabels=arraytolist(arrL,",");
ts.listValues = "0,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000,3250,3500,4000,4500,5000,6000,7000,8000,9000,10000,15000,20000";
ts.listValuesDelimiter=",";
ts.output=false;
</cfscript><cfif searchFormEnabledDropDownMenus>
<cfsavecontent variable="theCriteriaHTML2"><cfscript>
	ts.output=true;
	if(searchFormLabelOnInput){
		ts.selectLabel="Min SQFT";
		ts.inlineStyle="width:#searchFormSelectWidth#;";
	}else{
		ts.label="Min SQFT:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	</cfscript></cfsavecontent><cfscript>
sfSortStruct["search_sqfoot_low"]=theCriteriaHTML2;
</cfscript>
<cfsavecontent variable="theCriteriaHTML3"><cfscript>
	ts2=duplicate(ts);
	ts2.name="search_sqfoot_high";
	if(searchFormLabelOnInput){
		ts2.selectLabel="Max SQFT";
	}else{
		ts2.label="Max SQFT:";
	}
	application.zcore.functions.zInputSelectBox(ts2);
	
	</cfscript></cfsavecontent><cfscript>
sfSortStruct["search_sqfoot_high"]=theCriteriaHTML3;

writeoutput(theCriteriaHTML2);
writeoutput('<br />');
writeoutput(theCriteriaHTML3);</cfscript><cfelse><cfscript>
	ts.onchange="zConvertSliderToSquareMeters('search_sqfoot_low','search_sqfoot_high',false);";
	rs=application.zcore.functions.zInputSlider(ts);
	writeoutput('<input type="hidden" name="search_sqfoot_low_zvalue" id="search_sqfoot_low_zvalue" value="'&rs.zvalue&'" />');
	
	if(searchDisableExpandingBox){
		writeoutput('<div class="zmlsformlabel">Square Feet</div><div class="zmlsformfield">'&rs.output&'</div>');
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="SQFT:";
		ts.contents=rs.output;
		ts.height="65";
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_sqfoot"];
		application.zcore.functions.zExpOption(ts);
	}
</cfscript>
</cfif>

</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_sqfoot"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">

<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_year_built') EQ 1) and isDefined('searchFormHideCriteria.year_built') EQ false>

<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_year_built_low";
ts.name2="search_year_built_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="33";
ts.width="150";
nowyears="";
for(i=2010;i LTE year(now());i++){
	nowyears&=","&i;
}
ts.listLabels = "<1920,1920,1930,1940,1950,1960,1970,1980,1990,1995,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009#nowyears#,Future";
ts.listValues = "1800,1920,1930,1940,1950,1960,1970,1980,1990,1995,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009#nowyears#,#year(now())+3#";
ts.listLabelsDelimiter=",";
ts.listValuesDelimiter=",";
ts.output=false;
if(searchFormEnabledDropDownMenus){
	ts.output=true;
	if(searchFormLabelOnInput){
		ts.listLabels = "<1920,1920+,1930+,1940+,1950+,1960+,1970+,1980+,1990+,1995+,2000+,2001+,2002+,2003+,2004+,2005+,2006+,2007+,2008+,2009+#nowyears#,Future";
		ts.selectLabel="Year Built";
		ts.inlineStyle="width:#searchFormSelectWidth#;";
	}else{
		ts.label="Year Built:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInputSlider(ts);
	
	if(searchDisableExpandingBox){
		writeoutput('<div class="zmlsformlabel">Year Built</div><div class="zmlsformfield">'&rs.output&'</div>');
	}else{
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Year Built:";
		ts.contents=rs.output;
		ts.height="65";
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_year_built"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>

</div>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_year_built"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">

<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_acreage') EQ 1) and isDefined('searchFormHideCriteria.acreage') EQ false>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_acreage') EQ false>
    <cfsavecontent variable="db.sql">
    SELECT listing_acreage from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
WHERE 
    listing_deleted = #db.param(0)# and
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 

    listing_acreage not in (#db.trustedSQL("'','0'")#) 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    
        <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> #db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# </cfif>
    LIMIT #db.param(0)#,#db.param(1)#
    </cfsavecontent><cfscript>qType=db.execute("qType");
	tv299=structnew();
	tv299.recordcount=qType.recordcount;
	application.zcore.searchFormCache[request.zos.globals.id].search_acreage=tv299;
    </cfscript>
    
<cfelse>
	<cfscript>
	qType=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_acreage);
	</cfscript>
</cfif>
<cfif qType.recordcount NEQ 0>
<div class="zmlsformdiv">
<cfscript>
ts=StructNew();
ts.name="search_acreage_low";
ts.name2="search_acreage_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="33";
ts.width="150";
ts.listLabels = "0+|0.25+|0.5+|0.75+|1+|2+|3+|4+|5+|10+|20+|50+|100+";
ts.listValues = "0|0.25|0.5|0.75|1|2|3|4|5|10|20|50|100";
ts.listLabelsDelimiter="|";
ts.listValuesDelimiter="|";
ts.output=false;
if(searchFormEnabledDropDownMenus){
	ts.output=true;
	if(searchFormLabelOnInput){
		ts.selectLabel="Acreage";
		ts.inlineStyle="width:#searchFormSelectWidth#;";
	}else{
		ts.label="Acreage:";
	}
	ts.labelStyle="display:block; float:left;width:80px; padding-right:5px; text-align:right;";
	application.zcore.functions.zInputSelectBox(ts);
	
}else{
	rs=application.zcore.functions.zInputSlider(ts);
	if(searchDisableExpandingBox){
		writeoutput('<div class="zmlsformlabel">Acreage</div><div class="zmlsformfield">'&rs.output&'</div>');
	}else{
	
		ts=StructNew();
		ts.zExpOptionValue=rs.zExpOptionValue;
		ts.value=rs.value;
		ts.label="Acreage:";
		ts.contents=rs.output;
		ts.height="65";
		ts.width="165";
		ts.zMotionEnabled=true;
		ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_acreage"];
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript>

</div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_acreage"]=theCriteriaHTML;
</cfscript>



<cfsavecontent variable="theCriteriaHTML">
<!--- <cfif isDefined('searchFormHideCriteria.more_options') EQ false and application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false)>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_near_address') EQ 1)>
<div class="zmlsformdiv">
<cfsavecontent variable="featureHTML2"> 
Type street address<br />
including city &amp; state:<br />

<cfscript>
ts=StructNew();
//ts.label="Location:";
ts.name="search_near_address";
rs=application.zcore.functions.zInput_Hidden(ts);
</cfscript>
<input type="text" name="searchNearAddress" id="searchNearAddress" size="15" onkeyup="zNearAddressChange(this);" value="<cfif application.zcore.functions.zso(form, 'searchNearAddress') NEQ "">#form.searchNearAddress#<cfelse>#application.zcore.functions.zso(form, 'search_near_address')#</cfif>" />
<div class="zsearchformhr"></div>
<br style="clear:both;" />
Set Radius Distance: <br style="clear:both;" />

<cfscript>
ts = StructNew();
ts.name="search_near_radius";
ts.hideselect=true;
ts.listValuesDelimiter="|";
ts.listValues ="0.1|0.25|0.50|0.75|1|1.25|1.5|2|3|4|5|10|15|20|25|30|40|50";
ts.listLabels ="0.1|0.25|0.50|0.75|1|1.25|1.5|2|3|4|5|10|15|20|25|30|40|50";
ts.listLabelsDelimiter="|";
ts.onchange="zAjaxMapRadiusChange();";
ts.output=true;
ts.selectLabel="Radius";
//ts.inlineStyle="width:#replace(searchFormSelectWidth,"px","")-20#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript> (In Miles)<br style="clear:both;" />
<div id="zNearAddressDiv" style="display:none;">
<div class="zsearchformhr"></div><br style="clear:both;" />
Click &quot;Set&quot; to recenter<br />
 the map or &quot;Cancel&quot;.<br />

<input type="button" name="setNearAddress" onclick="zAjaxSetNearAddress();" value="Set" /> <input type="button" name="cancelNearAddress" onclick="zAjaxCancelNearAddress();" value="Cancel" />
</div>
</cfsavecontent>
<cfscript>
if(searchFormEnabledDropDownMenus){
	//writeoutput(featureHTML2);	
}else{
	if(searchDisableExpandingBox){
		writeoutput('<div class="zmlsformlabel">Near Location</div><br />'&featureHTML2);
	}else{
		ts=StructNew();
		//ts.zExpOptionValue=rs.zExpOptionValue;
		ts.label="Near Location:";
		ts.contents=featureHTML2;
			ts.height=28 + 145;
		ts.width="165";
		ts.zMotionEnabled=true;
		if(application.zcore.functions.zso(form, 'search_near_address') NEQ ""){
			ts.zMotionOpen=true;
		}else{
			ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_near_address"];
		}
		application.zcore.functions.zExpOption(ts);
	}
}
</cfscript></div>
</cfif>
</cfif> --->
</cfsavecontent>
<cfscript>
sfSortStruct["search_near_address"]=theCriteriaHTML;
</cfscript>

<cfsavecontent variable="theCriteriaHTML">
<cfif isDefined('searchFormHideCriteria.more_options') EQ false and application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false)>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_city_id') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_near_coordinates') EQ 1)>
<div class="zmlsformdiv">
<cfsavecontent variable="featureHTML2"> 
Type street address<br />
including city &amp; state:<br />

<cfscript>
ts=StructNew();
//ts.label="Location:";
ts.name="search_near_coordinates";
rs=application.zcore.functions.zInput_Hidden(ts);
</cfscript>
<input type="text" name="searchNearCoordinates" id="searchNearCoordinates" size="15" onkeyup="zNearCoordinatesChange(this);" value="<cfif application.zcore.functions.zso(form, 'searchNearCoordinates') NEQ "">#form.searchNearCoordinates#<cfelse>#application.zcore.functions.zso(form, 'search_near_coordinates')#</cfif>" />
<div class="zsearchformhr"></div>
<br style="clear:both;" />
Set Radius Distance: <br style="clear:both;" />

<cfscript>
ts = StructNew();
ts.name="search_near_radius";
ts.hideselect=true;
ts.listValuesDelimiter="|";
ts.listValues ="0.1|0.25|0.50|0.75|1|1.25|1.5|2|3|4|5|10|15|20|25|30|40|50";
ts.listLabels ="0.1|0.25|0.50|0.75|1|1.25|1.5|2|3|4|5|10|15|20|25|30|40|50";
ts.listLabelsDelimiter="|";
ts.onchange="zAjaxMapCoordinatesRadiusChange();";
ts.output=true;
ts.selectLabel="Radius";
//ts.inlineStyle="width:#replace(searchFormSelectWidth,"px","")-20#px;";
    application.zcore.functions.zInputSelectBox(ts);
</cfscript> (In Miles)<br style="clear:both;" />
<div id="zNearCoordinatesDiv" style="display:none;">
<div class="zsearchformhr"></div><br style="clear:both;" />
Click &quot;Set&quot; to recenter<br />
 the map or &quot;Cancel&quot;.<br />

<input type="button" name="setNearCoordinates" onclick="zAjaxSetNearCoordinates();" value="Set" /> <input type="button" name="cancelNearCoordinates" onclick="zAjaxCancelNearCoordinates();" value="Cancel" />
</div>
</cfsavecontent>
<cfscript>
if(searchFormEnabledDropDownMenus){
    //writeoutput(featureHTML2);    
}else{
    if(searchDisableExpandingBox){
        writeoutput('<div class="zmlsformlabel">Near Location</div><br />'&featureHTML2);
    }else{
        ts=StructNew();
        //ts.zExpOptionValue=rs.zExpOptionValue;
        ts.label="Near Location:";
        ts.contents=featureHTML2;
            ts.height=28 + 145;
        ts.width="165";
        ts.zMotionEnabled=true;
        if(application.zcore.functions.zso(form, 'search_near_coordinates') NEQ ""){
            ts.zMotionOpen=true;
        }else{
            ts.zMotionOpen=application.zcore.app.getAppData("listing").sharedStruct.filterStruct.opened["search_near_coordinates"];
        }
        application.zcore.functions.zExpOption(ts);
    }
}
</cfscript></div>
</cfif>
</cfif>
</cfsavecontent>
<cfscript>
sfSortStruct["search_near_coordinates"]=theCriteriaHTML;
</cfscript>

<!--- <cfsavecontent variable="theCriteriaHTML">
<cfif isDefined('searchFormHideCriteria.more_options') EQ false> --->
<cfset addHeight=0>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_subdivision') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_subdivision') EQ 1)>
    <cfsavecontent variable="theCriteriaHTML"> 
    <div class="zmlsformdiv">
    <cfscript>
    addHeight+=45;
    ts=StructNew();
    ts.label="Subdivision:";
    ts.name="search_subdivision";
    ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;width:95%;";
    ts.size="20";
    application.zcore.functions.zInput_Text(ts);
    </cfscript>
    </div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_subdivision"]=theCriteriaHTML;
    </cfscript>
</cfif>

<cfif forceSearchFormReset or structkeyexists(application.zcore.searchFormCache[request.zos.globals.id],'search_condoname') EQ false>

    <cfsavecontent variable="db.sql">SELECT count(listing_id) count 
	from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
	WHERE 
    listing_deleted = #db.param(0)# and 
    #db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
    listing_condoname <>#db.param('')# 
    <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1> and listing_status LIKE #db.param('%,7,%')# </cfif>
    <cfif structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')> 
		#db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL)# 
	</cfif>
    </cfsavecontent><cfscript>qCname=db.execute("qCname");
	application.zcore.searchFormCache[request.zos.globals.id].search_condoname=qCName;
    </cfscript>

<cfelse>
	<cfscript>
	qCname=duplicate(application.zcore.searchFormCache[request.zos.globals.id].search_condoname);
	</cfscript>
</cfif>
<cfif qCname.count NEQ 0>
<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_condoname') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_condoname') EQ 1)>
<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Building Name:";
ts.name="search_condoname";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;width:95%;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript>
    </div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_condoname"]=theCriteriaHTML;
    </cfscript>
</cfif>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_remarks') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_remarks') EQ 1)>
<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Keywords:";
ts.name="search_remarks";
//ts.onchange="zToggleSortFormBox();";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;width:95%;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript>
    </div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_remarks"]=theCriteriaHTML;
    </cfscript>
</cfif>

<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_remarks_negative') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_remarks_negative') EQ 1)>
<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Exclude Keywords:";
ts.name="search_remarks_negative";
//ts.onchange="zToggleSortFormBox();";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;width:95%;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript>
    </div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_remarks_negative"]=theCriteriaHTML;
    </cfscript>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_zip') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_zip') EQ 1)>
<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Zip Code:";
ts.name="search_zip";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;width:95%;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript>
    </div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_zip"]=theCriteriaHTML;
    </cfscript>
</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_address') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_address') EQ 1)>
<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="Street Address:";
ts.name="search_address";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;width:95%;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript> 
    </div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_address"]=theCriteriaHTML;
    </cfscript>

</cfif>


<cfif (structkeyexists(form, 'zdisablesearchfilter') or structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'searchable.search_mls_number_list') EQ false or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, 'search_mls_number_list') EQ 1)>
<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">
<cfscript>
addHeight+=45;
ts=StructNew();
ts.label="MLS ##(s):";
ts.name="search_mls_number_list";
//ts.onchange="zToggleSortFormBox();";
ts.labelstyle="float:left;clear:both;";
ts.style="float:left;clear:both;width:95%;";
ts.size="20";
application.zcore.functions.zInput_Text(ts);
</cfscript>
    </div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_mls_number_list"]=theCriteriaHTML;
    </cfscript>
</cfif>

<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">
    <label>Other Options</label><br />
<cfscript>
if(application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false) EQ false or (isDefined('request.zForceSearchFormInclude') EQ false and request.zos.originalURL NEQ request.zos.listing.functions.getSearchFormLink())){
	form.mapNotAvailable=1;
}else{
	form.mapNotAvailable=0;
}
	ts=StructNew();
	ts.name="mapNotAvailable";
	application.zcore.functions.zInput_Hidden(ts);

addHeight+=19;
ts = StructNew();
ts.name="search_with_pool";
ts.disableExpOptionValue=true;
ts.listLabels ="Must have a pool?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);

addHeight+=19;
ts = StructNew();
ts.name="search_with_photos";
ts.disableExpOptionValue=true;
ts.listLabels ="Must have photos?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>

<cfif application.zcore.app.getAppData("listing").sharedStruct.agentSQL NEQ "">
<cfscript>
addHeight+=19;
ts = StructNew();
ts.name="search_agent_only";
ts.disableExpOptionValue=true;
ts.listLabels ="Agent Listings Only?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
</cfif>

<cfif application.zcore.app.getAppData("listing").sharedStruct.officeSQL NEQ "">

<cfscript>
addHeight+=19;
ts = StructNew();
ts.name="search_office_only";
ts.disableExpOptionValue=true;
ts.listLabels ="Firm Listings Only?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>

</cfif>

<cfscript>
addHeight+=19;
ts = StructNew();
ts.name="search_surrounding_cities";
ts.disableExpOptionValue=true;
ts.listLabels ="Surrounding Cities?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
<!--- <cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only NEQ 1>
<cfscript>
ts = StructNew();
ts.name="search_sortppsqft";
ts.disableExpOptionValue=true;
ts.listLabels ="Sort by Price/SQFT?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
</cfif> --->

<cfif application.zcore.app.getAppData("listing").sharedStruct.agentSQL NEQ "">
<cfscript>
addHeight+=19;
ts = StructNew();
ts.name="search_agent_always";
ts.disableExpOptionValue=true;
ts.listLabels ="Similar Agent Listings?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
</cfif>

<cfif application.zcore.app.getAppData("listing").sharedStruct.officeSQL NEQ "">
<cfscript>
addHeight+=19;
ts = StructNew();
ts.name="search_office_always";
ts.disableExpOptionValue=true;
ts.listLabels ="Similar Firm Listings?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
</cfif>
<cfif application.zcore.app.getAppData("listing").sharedStruct.agentSQL NEQ "">
<cfscript>
if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_sort_agent_top') EQ false or application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_sort_agent_top EQ 0){
	addHeight+=19;
	ts = StructNew();
	ts.name="search_sort_agent_first";
	ts.disableExpOptionValue=true;
	ts.listLabels ="Sort Agent Listings First?";
	ts.listValues ="1";
	ts.output=true;
	application.zcore.functions.zInput_Checkbox(ts);
}
</cfscript>
</cfif>
<cfif application.zcore.app.getAppData("listing").sharedStruct.officeSQL NEQ "">
<cfscript>
if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_sort_office_top') EQ false or application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_sort_office_top EQ 0){
	addHeight+=19;
	ts = StructNew();
	ts.name="search_sort_office_first";
	ts.disableExpOptionValue=true;
	ts.listLabels ="Sort Firm Listings First?";
	ts.listValues ="1";
	ts.output=true;
	application.zcore.functions.zInput_Checkbox(ts);
}
</cfscript>
</cfif>

<!--- <cfif isDefined('request.contentEditor') EQ false> --->
<cfscript>
addHeight+=19;
backupSearchWithinMap=application.zcore.functions.zso(form,'search_within_map',true);
ts = StructNew();
ts.name="search_within_map";
ts.disableExpOptionValue=true;
ts.onchange="if(typeof zSetWithinMap !='undefined'){zSetWithinMap(this.value);}";
ts.listLabels ="Search within Map?";
ts.listValues ="1";
ts.output=true;
application.zcore.functions.zInput_Checkbox(ts);
</cfscript>
<!--- </cfif> --->

<cfscript>
/*
ts = StructNew();
ts.name="search_map_coordinates_list2";
ts.output=true;
application.zcore.functions.zInput_Hidden(ts);
*/
if(application.zcore.functions.zso(application.sitestruct[request.zos.globals.id], 'zListingMapCheck',false,false)){
	ts = StructNew();
	ts.name="search_map_coordinates_list";
	ts.output=true;
	application.zcore.functions.zInput_Hidden(ts);
	ts = StructNew();
	ts.name="search_map_long_blocks";
	ts.output=true;
	application.zcore.functions.zInput_Hidden(ts);
	ts = StructNew();
	ts.name="search_map_lat_blocks";
	ts.output=true;
	application.zcore.functions.zInput_Hidden(ts);
}
</cfscript>
    </div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_checkboxes"]=theCriteriaHTML;
    </cfscript>
<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">

<label for="search_listdate">List Date:</label><br />


<cfscript>
addHeight+=55;
ts = StructNew();
ts.name="search_listdate";
ts.hideselect=true;
ts.listValuesDelimiter="|";
ts.listValues ="Show All|New|Up to 3 days old|Up to 1 week old|Up to 2 weeks old|Up to 1 month old|Up to 3 months old|Up to 6 months old|Up to 12 months old";
ts.listLabels ="Show All|New|Up to 3 days old|Up to 1 week old|Up to 2 weeks old|Up to 1 month old|Up to 3 months old|Up to 6 months old|Up to 12 months old";
ts.listLabelsDelimiter="|";
ts.output=true;
ts.inlineStyle="width:95%;";
//ts.selectLabel="List Date";
//ts.inlineStyle="width:#replace(searchFormSelectWidth,"px","")-20#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript>
    </div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_listdate"]=theCriteriaHTML;
    </cfscript>
    <!--- 
<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">
<cfscript>
addHeight+=55;
ts = StructNew();
ts.name="search_result_limit";
ts.hideselect=true;
ts.listValuesDelimiter="|";
if(isDefined('search_result_limit') and isDefined('search_result_layout') and search_result_layout EQ 2){
	ts.listValues ="9|15|21|27|33|39|45|54";
}else{
	ts.listValues ="10|15|20|25|30|35|40|50";
}
ts.listLabels =ts.listValues;
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="Limit";
//ts.inlineStyle="width:#replace(searchFormSelectWidth,"px","")-20#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript>
</div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_result_limit"]=theCriteriaHTML;
    </cfscript>
    
<cfsavecontent variable="theCriteriaHTML"> 
<div class="zmlsformdiv">

GROUP BY:<br />
<cfscript>
addHeight+=55;
ts = StructNew();
ts.name="search_group_by";
ts.hideselect=true;
ts.listValuesDelimiter="|";
ts.listValues ="0|1";
ts.listLabels ="No Grouping|Bedrooms";
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="Layout";
ts.inlineStyle="width:100%;";//#min(140,replace(searchFormSelectWidth,"px","")-20)#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript>
</div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_group_by"]=theCriteriaHTML;
    </cfscript>
    
<cfsavecontent variable="theCriteriaHTML"> 
<div class="zmlsformdiv">
LAYOUT:<br />
<cfscript>
addHeight+=55;
ts = StructNew();
ts.name="search_result_layout";
ts.hideselect=true;
ts.listValuesDelimiter="|";
ts.listValues ="0|1|2";
ts.listLabels ="Detail|List|Thumbnail";
ts.listLabelsDelimiter="|";
ts.onchange="zMLSUpdateResultLimit(this.options[this.selectedIndex].value);";
ts.output=true;
ts.selectLabel="Layout";
ts.inlineStyle="width:100%;";//#min(140,replace(searchFormSelectWidth,"px","")-20)#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript>
</div>
    
</cfsavecontent>
<cfscript>
sfSortStruct["search_result_layout"]=theCriteriaHTML;
</cfscript> --->
    
    
    
    
<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">

<label for="search_result_limit">## of Results:</label><br />


<cfscript>
addHeight+=55;
ts = StructNew();
ts.name="search_result_limit";
ts.hideselect=true;
ts.listValuesDelimiter="|";
ts.listValues ="10|15|20|25|30|35|40|50";
ts.listLabels =ts.listValues;
ts.listLabelsDelimiter="|";
ts.output=true;
ts.inlineStyle="width:95%;";
//ts.selectLabel="List Date";
//ts.inlineStyle="width:#replace(searchFormSelectWidth,"px","")-20#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript>
</div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_result_limit"]=theCriteriaHTML;
    </cfscript>
<cfsavecontent variable="theCriteriaHTML"> 
	<div class="zmlsformdiv">


<label for="search_sort">Sort By:</label><br />
<cfscript>
addHeight+=45;
ts = StructNew();
ts.name="search_sort";
ts.hideselect=true;
ts.listValuesDelimiter="|";
if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
	ts.listValues ="priceasc|pricedesc|newfirst|nosort";
	ts.listLabels ="Price Ascending|Price Descending|Newest Listings First|No Sorting";
}else{
	ts.listValues ="priceasc|pricedesc|newfirst|nosort|sortppsqftasc|sortppsqftdesc";
	ts.listLabels ="Price Ascending|Price Descending|Newest Listings First|No Sorting|Price/SQFT Ascending|Price/SQFT Descending";
}
ts.listLabelsDelimiter="|";
ts.output=true;
ts.selectLabel="Sort";
ts.inlineStyle="width:95%;";//#min(140,replace(searchFormSelectWidth,"px","")-20)#px;";
	application.zcore.functions.zInputSelectBox(ts);
</cfscript>
</div>
    </cfsavecontent>
    <cfscript>
    sfSortStruct["search_sort"]=theCriteriaHTML;
    </cfscript>

<!--- 
<cfscript>
if(structkeyexists(request,'theSearchFormTemplate') EQ false){
	//writeoutput('keylist:'&structkeylist(sfSortStruct)&'<br />');
	
	if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'sort')){
		arrKey=structkeyarray(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.sort);
		arraysort(arrKey,"numeric","asc");
		for(i=1;i LTE arraylen(arrKey);i++){
			writeoutput(sfSortStruct[application.zcore.app.getAppData("listing").sharedStruct.filterStruct.sort[arrKey[i]]]);
		}
	}else{
		for(i in sfSortStruct){
			writeoutput(sfSortStruct[i]);
		}
	}
}


</cfscript> --->
<!--- 
<cfif request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' and isDefined('mls_saved_search_id')>
	  <cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
WHERE mls_saved_search_id = #db.param(form.mls_saved_search_id)# and site_id = #db.param(request.zos.globals.id)# and 
mls_saved_search_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qSaved=db.execute("qSaved");</cfscript>
<div class="zmlsformdiv">
<cfsavecontent variable="theHTML">
	<input type="hidden" name="mls_saved_search_id" value="#mls_saved_search_id#" />
	Format:<br />
<input type="radio" name="saved_search_format" value="1" style="background:none; border:0px; " <cfif qsaved.saved_search_format EQ '1'>checked="checked"</cfif> /> Text w/Photos 
	<input type="radio" name="saved_search_format" value="0" <cfif qsaved.saved_search_format EQ '0'>checked="checked"</cfif> style="background:none; border:0px; " /> Text<br />

	Frequency:<br />
<input type="radio" name="saved_search_frequency" value="0" style="background:none; border:0px; " <cfif qsaved.saved_search_frequency EQ 0>checked="checked"</cfif> /> Every Day 
	<input type="radio" name="saved_search_frequency" value="1" <cfif qsaved.saved_search_frequency EQ '1'>checked="checked"</cfif> style="background:none; border:0px; " /> Fridays<br />
	</cfsavecontent>
<cfscript>
	ts=StructNew();
	//ts.zExpOptionValue=rs.zExpOptionValue;
	ts.label="Email Alert Options:";
	ts.contents=theHTML;
	ts.height=90;
	ts.width="165";
	ts.zMotionEnabled=true;
	ts.zMotionOpen=true;
	application.zcore.functions.zExpOption(ts);
</cfscript>
</div>
</cfif> --->
<cfsavecontent variable="endFormTagHTML">
<cfif application.zcore.functions.zso(request, 'zDisableSearchFormSubmit',false,false) EQ false>
<div class="zmlsformdiv">

<cfscript>
//if(structkeyexists(request,'theSearchFormTemplate') EQ false){
	ts=StructNew();
	// required
	ts.name="formSubmit";
	ts.value="Search";
	// optional
	ts.friendlyName="";
	if(isDefined('searchFormSubmitButtonClass')){
		ts.className=searchFormSubmitButtonClass;
		ts.imageInput=false;
		ts.useAnchorTag=true;
	}else if(isDefined('searchFormSubmitButtonStyle')){
		ts.style=searchFormSubmitButtonStyle;
		ts.imageInput=false;
		ts.useAnchorTag=true;
	}else{
		if(isDefined('imageUrl')){
			ts.imageUrl=imageUrl;
		}
		else{
			ts.imageUrl="/z/a/listing/images/search-mls-button.gif";
		}
		ts.imageInput=true;
		ts.style="border:none;";
	}
	if(request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' and isDefined('mls_saved_search_id')){
		ts.value="UPDATE SAVED SEARCH";
		ts.useAnchorTag=false;
		ts.imageInput=false;
		ts.style="padding:5px;";
		writeoutput('<script>/* <![CDATA[ */zDisableSearchFormSubmit=true;/* ]]> */</script>');
	}
	ts.onclick="";
	application.zcore.functions.zInput_submit(ts);
	if(request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' and isDefined('mls_saved_search_id')){
		writeoutput('<br /><input type="button" name="cancel1" value="Cancel" style="padding:5px; margin-top:5px;" onclick="window.location.href=''/z/listing/property/your-saved-searches/index'';" />');	
	}
</cfscript>
</div>
</cfif>
</cfsavecontent>
<!--- </table> --->
<cfscript>

sfSortStruct["formSubmitButton"]=endFormTagHTML;</cfscript>
<!--- </div> --->
<cfsavecontent variable="endFormTagHTML">
<cfif request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' and isDefined('mls_saved_search_id')>
<input type="submit" name="buttonShowListing" value="Update Saved Search" /> <input type="button" name="cbuttonShowListing" value="Cancel" onclick="window.location.href='/z/listing/inquiry/index';" /> 
<cfelse>
<input type="button" name="buttonShowListing" value="Show Listings" onclick="zlsHoverBoxNew.showListings();" id="zls-hover-box-show-listing-button" />
</cfif>
<cfscript>
if(isDefined('request.contentEditor') EQ false){
	application.zcore.functions.zEndForm();
}
</cfscript>
 </cfsavecontent>
 
 <cfscript>
sfSortStruct["endFormTag"]=endFormTagHTML;
//writeoutput(endFormTagHTML);
//application.zcore.functions.zdump(sfSortStruct);
if(structkeyexists(request,'theSearchFormTemplate')){
	//request.zMLSHideCount=true;
	for(i in sfSortStruct){
		/*if(left(trim(sfSortStruct[i]),'4') EQ '<tr>'){
			request.theSearchFormTemplate=replace(request.theSearchFormTemplate,"##"&i&"##","<table class=""zquicksearchpaddingfix"" style=""width:100%;"">"&sfSortStruct[i]&"</table>","ALL");
		}else{*/
			request.theSearchFormTemplate=replacenocase(request.theSearchFormTemplate,"##"&i&"##",sfSortStruct[i],"ONE");
		//}
	}
	sfSortStruct2=structnew();
	sfSortStruct2["searchFormSubmitURL"]=htmleditformat(tempSearchFormAction);
	sfSortStruct2["searchFormAdvancedURL"]=request.zos.listing.functions.getSearchFormLink();
	for(i in sfSortStruct2){
		request.theSearchFormTemplate=replacenocase(request.theSearchFormTemplate,"##"&i&"##",sfSortStruct2[i],"ONE");
	}
	request.theSearchFormTemplate=request.theSearchFormTemplate;
}
</cfscript>#request.theSearchFormTemplate#
</cfsavecontent>
<cfscript>
sidebarOutput=false;
	writeoutput(searchFormHTML);
</cfscript>
        
        
        
        
    </cffunction>
    
    
    </cfoutput>
</cfcomponent>