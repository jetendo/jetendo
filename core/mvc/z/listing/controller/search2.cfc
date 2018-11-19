<!--- TODO: change all zArrDeferredFunctions in functions/form.cfc to use html data attribute eval / json instead so less javascript is output and there isn't output when output=false on functions like zInput_Text() --->
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
    
	
	<cffunction name="getCity" localmode="modern" access="public">
	
		<cfscript>
		var db=request.zos.queryObject;
		var rs=structnew();
		var cityIdList=0;
		var g=0;
		var rs2=0;
		var arrLabel=0;
		var arrValue=0;
		var qType=0;
		var i=0;
		var preLabels=0;
		var cityUnq=0;
		var arrK3=0;
		var arrKeys=0;
		var arrK2=0;
		var qCity10=0;
		var sout=0;
		var preValues=0;
		var qCity=0;
		var primaryCount=0;
		var selectedCityCount=0;
		var primaryCityId=0;
		
		primaryCount=1;
		primaryCityId=application.zcore.app.getAppData("listing").sharedStruct.mls_primary_city_id;
		selectedCityCount=1;
		if(application.zcore.functions.zso(form,'search_city_id') NEQ ""){
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
		<cfsavecontent variable="db.sql">
		select city_x_mls.city_name label, city_x_mls.city_id value 
		from #db.table("city_x_mls", request.zos.zcoreDatasource)# city_x_mls 
		WHERE 
		city_x_mls_deleted = #db.param(0)# and 
		city_x_mls.city_id IN (#db.trustedSQL(qtype.idlist)#) and 
		#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("city_x_mls"))#  and 
		city_id NOT IN (#db.trustedSQL("'#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_exclude_city_list#'")#)  
			  
		</cfsavecontent><cfscript>qCity=db.execute("qCity");</cfscript>
		<cfloop query="qCity"><cfscript>if(structkeyexists(cityUnq,qCity.label) EQ false){cityUnq[qCity.label]=qCity.value;}</cfscript></cfloop>
		<!--- put the primary cities at top and repeat further down too --->
		<cfsavecontent variable="db.sql">
		select city.city_name label, city.city_id value 
		from #db.table("city_memory", request.zos.zcoreDatasource)# city 
		WHERE city_deleted = #db.param(0)# and 
		city_id IN (#db.trustedSQL("'#(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_primary_city_list)#'")#) 
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
		return rs.city_id;
		</cfscript>
	</cffunction>
	
	
	
	<cffunction name="getData" localmode="modern" access="public">
		<cfargument name="fieldName" type="string" required="yes">
		<cfargument name="keyName" type="string" required="yes">
		<cfargument name="lookupEnabled" type="boolean" required="yes">
		<cfscript>
		var db=request.zos.queryObject;
		var sortType="numeric";
		
		db.sql="SELECT cast(group_concat(distinct #arguments.fieldName# SEPARATOR #db.param(',')#) AS CHAR) idlist 
		from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
		WHERE 
		listing_deleted = #db.param(0)# and 
		#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
		#arguments.fieldName# not in (#db.trustedSQL("'','0'")#) ";
		if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
			db.sql&=" and listing_status LIKE #db.param('%,7,%')# ";
		}
		if(structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')){
			db.sql&=" "&db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL);
		}
		local.qType=db.execute("qType");
		local.arrD=listtoarray(local.qType.idlist);
		local.arrL=[];
		local.arrV=[];
		local.s2=structnew();
		local.s3=structnew();
		for(local.i=1;local.i LTE arraylen(local.arrD);local.i++){
			local.s2[local.arrD[local.i]]=structnew();	
		}
		if(arguments.lookupEnabled){
			sortType="text";
		}
		for(local.i in local.s2){
			if(arguments.lookupEnabled){
				local.tmp=application.zcore.functions.zFirstLetterCaps(application.zcore.listingCom.listingLookupValue(arguments.keyName,local.i));
			}else{
				if(not isNumeric(local.i)){
					sortType="text";
				}
				local.tmp=local.i;
			}
			if(local.tmp NEQ ""){
				if(structkeyexists(local.s3,local.tmp) EQ false){
					local.s3[local.tmp]=local.i;
				}else{
					local.s3[local.tmp]&=","&local.i;	
				}
			}
		}
		structdelete(local.s3,'');
		local.arrL=structkeyarray(local.s3);
		arraysort(local.arrL, sortType,"asc");
		for(local.i=1;local.i LTE arraylen(local.arrL);local.i++){
			arrayappend(local.arrV,local.s3[local.arrL[local.i]]);
		}
		return {
			values:arraytolist(local.arrV,"|"),
			labels:arraytolist(local.arrL,"|")
		};
		</cfscript>
	</cffunction>
	
	<cffunction name="getCheckboxes" localmode="modern" access="private">
		<cfscript>
		var ts=0;
		savecontent variable="local.output"{
			writeoutput('<div class="searchCheckboxes">');
			if(application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false) EQ false or (isDefined('request.zForceSearchFormInclude') EQ false and request.zos.originalURL NEQ request.zos.listing.functions.getSearchFormLink() )){
				form.mapNotAvailable=1;
			}else{
				form.mapNotAvailable=0;
			}
			ts=StructNew();
			ts.name="mapNotAvailable";
			application.zcore.functions.zInput_Hidden(ts);
			
			ts = StructNew();
			ts.name="search_with_pool";
			ts.disableExpOptionValue=true;
			ts.listLabels ="Must have a pool?";
			ts.listValues ="1";
			ts.output=true;
			application.zcore.functions.zInput_Checkbox(ts);
			
			ts = StructNew();
			ts.name="search_with_photos";
			ts.disableExpOptionValue=true;
			ts.listLabels ="Must have photos?";
			ts.listValues ="1";
			ts.output=true;
			application.zcore.functions.zInput_Checkbox(ts);
			
			if(application.zcore.app.getAppData("listing").sharedStruct.agentSQL NEQ ""){
				ts = StructNew();
				ts.name="search_agent_only";
				ts.disableExpOptionValue=true;
				ts.listLabels ="Agent Listings Only?";
				ts.listValues ="1";
				ts.output=true;
				application.zcore.functions.zInput_Checkbox(ts);
			}
			if(application.zcore.app.getAppData("listing").sharedStruct.officeSQL NEQ ""){
				ts = StructNew();
				ts.name="search_office_only";
				ts.disableExpOptionValue=true;
				ts.listLabels ="Firm Listings Only?";
				ts.listValues ="1";
				ts.output=true;
				application.zcore.functions.zInput_Checkbox(ts);
			}
			ts = StructNew();
			ts.name="search_surrounding_cities";
			ts.disableExpOptionValue=true;
			ts.listLabels ="Surrounding Cities?";
			ts.listValues ="1";
			ts.output=true;
			application.zcore.functions.zInput_Checkbox(ts);
			if(application.zcore.app.getAppData("listing").sharedStruct.agentSQL NEQ ""){
				ts = StructNew();
				ts.name="search_agent_always";
				ts.disableExpOptionValue=true;
				ts.listLabels ="Similar Agent Listings?";
				ts.listValues ="1";
				ts.output=true;
				application.zcore.functions.zInput_Checkbox(ts);
			}
			if(application.zcore.app.getAppData("listing").sharedStruct.officeSQL NEQ ""){
				ts = StructNew();
				ts.name="search_office_always";
				ts.disableExpOptionValue=true;
				ts.listLabels ="Similar Firm Listings?";
				ts.listValues ="1";
				ts.output=true;
				application.zcore.functions.zInput_Checkbox(ts);
			}
			if(application.zcore.app.getAppData("listing").sharedStruct.agentSQL NEQ ""){
				if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_sort_agent_top') EQ false or application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_sort_agent_top EQ 0){
					ts = StructNew();
					ts.name="search_sort_agent_first";
					ts.disableExpOptionValue=true;
					ts.listLabels ="Sort Agent Listings First?";
					ts.listValues ="1";
					ts.output=true;
					application.zcore.functions.zInput_Checkbox(ts);
				}
			}
			if(application.zcore.app.getAppData("listing").sharedStruct.officeSQL NEQ ""){
				if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.optionStruct,'mls_option_sort_office_top') EQ false or application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_sort_office_top EQ 0){
					ts = StructNew();
					ts.name="search_sort_office_first";
					ts.disableExpOptionValue=true;
					ts.listLabels ="Sort Firm Listings First?";
					ts.listValues ="1";
					ts.output=true;
					application.zcore.functions.zInput_Checkbox(ts);
				}
			}
			
			if(application.zcore.functions.zso(application.sitestruct[request.zos.globals.id],'zListingMapCheck',false,false)){
				writeoutput('<div id="zSearchFormWithinMapDiv">');
				ts = StructNew();
				ts.name="search_within_map";
				ts.disableExpOptionValue=true;
				ts.onchange="if(typeof zSetWithinMap !='undefined'){zSetWithinMap(this.value);}";
				ts.listLabels ="Search within Map?";
				ts.listValues ="1";
				ts.output=true;
				application.zcore.functions.zInput_Checkbox(ts);
				writeoutput('</div>');
			
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
			writeoutput('</div>');
		}
		return local.output;
		</cfscript>

	</cffunction>
	
	<cffunction name="getDataFromList" localmode="modern" access="public">
		<cfargument name="fieldName" type="string" required="yes">
		<cfargument name="keyName" type="string" required="yes">
		<cfargument name="labelList" type="string" required="yes">
		<cfargument name="valueList" type="string" required="yes">
		<cfscript>
		var db=request.zos.queryObject;
		
		db.sql="SELECT #arguments.fieldName# value 
		from #db.table("listing_memory", request.zos.zcoreDatasource)# listing 
		WHERE 
		listing_deleted = #db.param(0)# and 
		#db.trustedSQL(application.zcore.listingCom.getMLSIDWhereSQL("listing"))# and 
		#arguments.fieldName# not in (#db.trustedSQL("'','0'")#) ";
		if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1){
			db.sql&=" and listing_status LIKE #db.param('%,7,%')# ";
		}
		if(structkeyexists(form, 'zdisablesearchfilter') EQ false and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.filterStruct, 'whereOptionsSQL')){
			db.sql&=" "&db.trustedSQL(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.whereOptionsSQL);
		}
		db.sql&=" LIMIT #db.param(0)#,#db.param(1)#";
		local.qType=db.execute("qType");
		if(local.qType.recordcount NEQ 0){
			return {
				success:true,
				dataStruct:{
					values:arguments.labelList,
					labels:arguments.valueList
				}
			};
		}else{
			return {
				success:false
			};
		}
		</cfscript>
	</cffunction>
	
	<!--- /newsearch.cfc?method=index --->
	<cffunction name="getSearchCriteriaStruct" localmode="modern" access="public" returntype="struct" output="yes">

        <cfscript>
		var db=request.zos.queryObject;
		var rs=structnew();
		
		var searchFormHideCriteria={};
		var nowyears="";
		var i=0;
		for(i=2011;i LTE year(now());i++){
			nowyears&="|"&i;
		}
		
		local.fieldStruct={
			"listing_city":{key:"city_id",searchField:'search_city_id',noData:false, lookup:true, formfieldType:"multiSelect", label:"City"},
			"listing_type_id":{key:"listing_type",searchField:'search_listing_type_id',noData:false, lookup:true, formfieldType:"multiSelect", label:"Property Type"},
			"listing_condition":{key:"condition",searchField:'search_condition', noData:false, lookup:true, formfieldType:"multiSelect", label:"Condition"},
			"listing_parking":{key:"parking",searchField:'search_parking', noData:false, lookup:true, formfieldType:"multiSelect", label:"Parking"},
			"listing_tenure":{key:"tenure",searchField:'search_tenure', noData:false, lookup:true, formfieldType:"multiSelect", label:"Tenure"},
			"listing_region":{key:"region",searchField:'search_region', noData:false, lookup:true, formfieldType:"multiSelect", label:"Region"},
			"listing_sub_type_id":{key:"listing_sub_type",searchField:'search_listing_sub_type_id', noData:false, lookup:true, formfieldType:"multiSelect", label:"Property Sub Type"},
			"listing_county":{key:"county",searchField:'search_county', noData:false, lookup:true, formfieldType:"multiSelect", label:"County"},
			"listing_view":{key:"view",searchField:'search_view', noData:false, lookup:true, formfieldType:"multiSelect", label:"View"},
			"listing_liststatus":{key:"liststatus",searchField:'search_liststatus', noData:false, lookup:true, formfieldType:"multiSelect", label:"List Status"},
			"listing_status":{key:"status",searchField:'search_status', noData:false, lookup:true, formfieldType:"multiSelect", label:"Sale Type"},
			"listing_style":{key:"style",searchField:'search_style', noData:false, lookup:true, formfieldType:"multiSelect", label:"Style"},
			"listing_frontage":{key:"frontage",searchField:'search_frontage', noData:false, lookup:true, formfieldType:"multiSelect", label:"Frontage"},
			"listing_lot_square_feet":{
				key:"lot_square_feet",
				searchField:'search_lot_square_feet', 
				noData:false,
				labels:"0|500|750|1000|1250|1500|1750|2000|2250|2500|2750|3000|3250|3500|4000|4500|5000|6000|7000|8000|9000|10000|15000|20000",
				values:"0|500|750|1000|1250|1500|1750|2000|2250|2500|2750|3000|3250|3500|4000|4500|5000|6000|7000|8000|9000|10000|15000|20000", 
				lookup:false, 
				formfieldType:"sliderRange", 
				label:"Lot Square Feet"
			},
			"listing_year_built":{
				key:"lot_year_built",
				searchField:'search_year_built', 
				noData:false, 
				labels:"<1920|1920|1930|1940|1950|1960|1970|1980|1990|1995|2000|2001|2002|2003|2004|2005|2010#nowyears#|Future",
				values:"1800|1920|1930|1940|1950|1960|1970|1980|1990|1995|2000|2001|2002|2003|2004|2005|2010#nowyears#|#year(now())+5#", 
				lookup:false, 
				formfieldType:"sliderRange", 
				label:"Year Built"
			},
			"listing_square_feet":{
				key:"lot_sqfoot",
				searchField:'search_sqfoot', 
				noData:false,
				labels:"0|500|750|1000|1250|1500|1750|2000|2250|2500|2750|3000|3250|3500|4000|4500|5000|6000|7000|8000|9000|10000|15000|20000",
				values:"0|500|750|1000|1250|1500|1750|2000|2250|2500|2750|3000|3250|3500|4000|4500|5000|6000|7000|8000|9000|10000|15000|20000", 
				lookup:false, 
				formfieldType:"sliderRange", 
				label:"Square Feet"
			},
			// fields with list data
			"listing_price":{
				key:"rate", 
				searchField:'search_rate', 
				noData:false, 
				rentalLabels:"$0|$200|$400|$600|$800|$1,000|$1,200|$1,400|$1,600|$1,800|$2,000|$2,500|$3,000|$4,000|$5,000|$6,000|$7,000|$8,000|$9,000|$10,000|$20,000|$30,000|$40,000|$50,000|$100,000|$10,000,000",
				rentalValues:"0|200|400|600|800|1000|1200|1400|1600|1800|2000|2500|3000|4000|5000|6000|7000|8000|9000|10000|20000|30000|40000|50000|100000|10000000",
				labels:"$0|$25,000|$50,000|$75,000|$100,000|$125,000|$150,000|$175,000|$200,000|$225,000|$250,000|$275,000|$300,000|$325,000|$350,000|$400,000|$450,000|$500,000|$600,000|$700,000|$800,000|$900,000|$1,000,000|$1,500,000|$2,000,000|$3,000,000|$4,000,000|$5,000,000",
				values:"0|25000|50000|75000|100000|125000|150000|175000|200000|225000|250000|275000|300000|325000|350000|400000|450000|500000|600000|700000|800000|900000|1000000|1500000|2000000|3000000|4000000|5000000", 
				lookup:false, 
				formfieldType:"sliderRange", 
				label:"Price"
    			},
			"listing_acreage":{
				key:"acreage",
				searchField:"search_acreage",
				noData:false,
				labels = "0+|0.25+|0.5+|0.75+|1+|2+|3+|4+|5+|10+|20+|50+|100+",
				values = "0|0.25|0.5|0.75|1|2|3|4|5|10|20|50|100", 
				lookup:false, 
				formfieldType:"sliderRange", 
				label:"Acreage"
			},
			"result_layout":{
				key:"result_layout",
				searchField:'search_result_layout',
				noData:true, 
				lookup:false,
				values:"0|1|2",
				labels:"Detail|List|Thumbnail", 
				formfieldType:"singleSelect", 
				label:"Layout"
			},
			// fields with data and no lookup
			"listing_beds":{key:"bedrooms",searchField:'search_bedrooms', noData:false, lookup:false, formfieldType:"sliderRange", label:"Bedrooms"},
			"listing_baths":{key:"bathrooms",searchField:'search_bathrooms', noData:false, lookup:false, formfieldType:"sliderRange", label:"Bathrooms"},
			"listing_subdivision":{key:"subdivision",searchField:'search_subdivision',noData:false, lookup:false, formfieldType:"text", label:"Subdivision"},
			"listing_condoname":{key:"condoname",searchField:'search_condoname', noData:false, lookup:false, formfieldType:"text", label:"Building Name"},
			"listing_zip":{key:"zip",searchField:'search_zip',noData:false, lookup:false, formfieldType:"text", label:"Zip Code"},
			// fields with no data
			"listing_remarks":{key:"remarks",searchField:'search_remarks',noData:true, lookup:false, formfieldType:"text", label:"Including These Keywords"},
			"remarks_negative":{key:"remarks_negative",searchField:'search_remarks_negative',noData:true, lookup:false, formfieldType:"text", label:"Excluding These Keywords"},
			"mls_number_list":{key:"mls_number_list",searchField:'search_mls_number_list',noData:true, lookup:false, formfieldType:"text", label:"MLS ##(s)"},
			"listing_address":{key:"address",searchField:'search_address',noData:true, lookup:false, formfieldType:"text", label:"Street Address"},
			"listdate":{
				key:"listdate",
				searchField:'search_listdate',
				noData:true, 
				lookup:false,
				values:"Show All|New|Up to 3 days old|Up to 1 week old|Up to 2 weeks old|Up to 1 month old|Up to 3 months old|Up to 6 months old|Up to 12 months old",
				labels:"Show All|New|Up to 3 days old|Up to 1 week old|Up to 2 weeks old|Up to 1 month old|Up to 3 months old|Up to 6 months old|Up to 12 months old", 
				formfieldType:"singleSelect", 
				label:"List Date"
			},
			"result_limit":{
				key:"result_limit",
				searchField:'search_result_limit',
				noData:true, 
				lookup:false,
				values ="10|15|20|25|30|35|40|50",
				labels="10|15|20|25|30|35|40|50", 
				formfieldType:"singleSelect",
				label="## of Results"
			},
			"group_by":{
				key:"group_by",
				searchField:'search_group_by',
				noData:true, 
				lookup:false,
				values ="0|1",
				labels="No Grouping|Bedrooms", 
				formfieldType:"singleSelect",
				label:"Group By"
			},
			"sort":{
				key:"sort",
				searchField:'search_sort',
				noData:true, 
				lookup:false,
				rentalValues:"priceasc|pricedesc|newfirst|nosort",
				rentalLabels:"Price Ascending|Price Descending|Newest Listings First|No Sorting",
				values:"priceasc|pricedesc|newfirst|nosort|sortppsqftasc|sortppsqftdesc",
				labels:"Price Ascending|Price Descending|Newest Listings First|No Sorting|Price/SQFT Ascending|Price/SQFT Descending", 
				formfieldType:"singleSelect",
				label:"Sort By"
			},
			"near_radius":{key:"near_radius",searchField:'search_near_radius',noData:true, lookup:false, formfieldType:"custom", label:"Near Radius"},
			"formSubmitButton":{key:"formSubmitButton",searchField:'formSubmitButton',noData:true, lookup:false, formfieldType:"custom", label=""}
			
		};
		// make the data builder have this logic for disabling formSubmitButton
		if(application.zcore.functions.zso(request, 'zDisableSearchFormSubmit',false,false) EQ false){
		}
		local.formFieldTypeStruct={};
		for(local.i in local.fieldStruct){
			local.allow=false;
			local.formFieldTypeStruct[local.i]=local.fieldStruct[local.i].formFieldType;
			if(not local.fieldStruct[local.i].noData){
				if(structkeyexists(form, 'zdisablesearchfilter')){
					local.allow=true;
				}else if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable, local.fieldStruct[local.i].searchField) EQ 1){
					if(structkeyexists(searchFormHideCriteria, local.i) EQ false){
						local.allow=true;
					}
				}
			}else{
				if(structkeyexists(local.fieldStruct[local.i], 'labels')){
					if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1 and structkeyexists(local.fieldStruct[local.i], 'rentalLabels')){
						rs[local.fieldStruct[local.i].key]={
							 labels:local.fieldStruct[local.i].rentalLabels, 
							 values:local.fieldStruct[local.i].rentalValues
						};
					}else{
						rs[local.fieldStruct[local.i].key]={
							 labels:local.fieldStruct[local.i].labels, 
							 values:local.fieldStruct[local.i].values
						};
					}
				}
			}
			if(local.allow){
				if(structkeyexists(local.fieldStruct[local.i], 'labels')){
					if(application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 1 and structkeyexists(local.fieldStruct[local.i], 'rentalLabels')){
						local.tempStruct=this.getDataFromList(local.i, local.fieldStruct[local.i].key, local.fieldStruct[local.i].rentalLabels, local.fieldStruct[local.i].rentalValues);
						if(local.tempStruct.success){
							rs[local.fieldStruct[local.i].key]=local.tempStruct.dataStruct;
						}
					}else{
						local.tempStruct=this.getDataFromList(local.i, local.fieldStruct[local.i].key, local.fieldStruct[local.i].labels, local.fieldStruct[local.i].values);
						if(local.tempStruct.success){
							rs[local.fieldStruct[local.i].key]=local.tempStruct.dataStruct;
						}
					}
				}else{
					rs[local.fieldStruct[local.i].key]=this.getData(local.i, local.fieldStruct[local.i].key, local.fieldStruct[local.i].lookup);
				}
			}
		}
		if((structkeyexists(form, 'zdisablesearchfilter') or (application.zcore.app.siteHasApp("listing") and application.zcore.app.getAppData("listing").sharedStruct.filterStruct.searchable.search_city_id EQ 1)) and structkeyexists(searchFormHideCriteria, 'city') EQ false){
			rs.city_id=this.getCity();
		}
		return {fieldStruct:local.fieldStruct, dataStruct:rs, formFieldTypeStruct:local.formFieldTypeStruct, formfieldStruct:{}};
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
		form.debugSearchForm=application.zcore.functions.zso(form,'debugsearchForm',false,false);
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
		if(isDefined('first') EQ false){
			ts.disableCount=true;
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
				arrayappend(arrN2, jsstringformat(aobj.data[i][n]));
			}
			arrayappend(arrN,'"'&lcase(i)&'":["'&arraytolist(arrN2,'","')&'"]');
		}
		if(form.debugSearchForm){
			arrayappend(arrN, '"debugsql":"#replace(jsstringformat(replace(replace(replace(replace(theQuerySQL,'"',"'","all"),chr(9)," ","all"),chr(13)," ","all"),chr(10)," ","all")),"\'","'","all")#"');
		}
		jsonText='{"loadtime":"#((gettickcount()-start)/1000)# seconds","count":#returnStruct.count#,"offset":#offset#,"success":true,"qs":"#jsstringformat(qs)#",#arraytolist(arrN,",")#}';
		
		</cfscript><cfheader name="x_ajax_id" value="#form.x_ajax_id#"><cfsavecontent variable="out">#jsonText#</cfsavecontent>#out#<cfscript>application.zcore.functions.zabort();</cfscript>
	</cffunction>
    
    <cffunction name="s" localmode="modern" output="yes" access="remote" returntype="any">
    	<cfscript>
		var db=request.zos.queryObject;
		application.zcore.functions.zRequireJquery();
		application.zcore.template.setTemplate("zcorerootmapping.templates.plain",true,true);
		
		//form.search_city_id=250;
		//form.search_rate_low=100000;
		structdelete(form,'search_result_limit');
		actionQueryString=formVarsToURL(form);
		//writeoutput('action:'&actionQueryString&'<br />');
		</cfscript>
		<div id="debugInfo" style="position:fixed;display:none; left:10px; top:200px; width:200px; height:200px; float:left;"><textarea id="debugInfoTextArea" name="debugInfoTextArea" cols="100" rows="10"></textarea></div>
		<div id="zScrollArea" style="overflow:hidden;  width:100%; float:left; ">
		</div>
		  <div id="zMapCanvas" style="width:25%; display:none; position:fixed; left:0px; top:40px; z-index:2;"><div id="zMapCanvas2" style="float:left; width:100%;"></div></div>
		  <div id="zMapCanvas3" style="width:25%; display:none; position:fixed; left:0px; top:0px; z-index:2;"><div id="zMapCanvas4" style="float:left; width:100%;"></div></div>
		<br />
		
		<cfsavecontent variable="scriptHTML">
		<script type="text/javascript">/* <![CDATA[ */ var zlsQueryString="#jsstringformat(actionQueryString)#";/* ]]> */</script>
		 </cfsavecontent>
		 <cfscript>
		 application.zcore.template.appendTag("meta",scriptHTML);
		 </cfscript>
    </cffunction>
    
    <cffunction name="initSearchForm" localmode="modern" access="private" output="yes" returntype="any">
		<cfscript>
		application.zcore.functions.zDisbleEndFormCheck();
		if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
			writeoutput('.<!-- stop spamming -->');
			application.zcore.functions.zabort();
		}
		if(request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink()){
			application.zcore.template.settag("title","Search Results");
			application.zcore.template.settag("pagetitle","");
		}
		if(request.zos.originalURL EQ request.zos.listing.functions.getSearchFormLink()){
			request.zForceListingSidebar=true; 
		}
		if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_search',true) EQ 1 and application.zcore.functions.zso(request, 'contentEditor',false,false) EQ false){
			application.zcore.functions.z301redirect('/');	
		}
		 
		</cfscript>
	</cffunction>
	
    <cffunction name="getContentSearchStruct" localmode="modern" access="private" output="yes" returntype="any">
		<cfscript>
		var db=request.zos.queryObject;
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
			mls_saved_search.site_id = content.site_id and 
			content.site_id = #db.param(request.zos.globals.id)# and 
			content_search_mls= #db.param(1)# and 
			content.content_id = #db.param(form.zsearch_cid)#  and 
			mls_saved_search_deleted = #db.param(0)# and 
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
		
		if(application.zcore.functions.zso(form,'zsearch_bid') NEQ ''){
			 db.sql="SELECT * from blog, #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
			WHERE mls_saved_search.mls_saved_search_id = blog.mls_saved_search_id and 
			blog.blog_search_mls= #db.param(1)# and 
			blog.site_id = #db.param(request.zos.globals.id)# and 
			mls_saved_search_deleted = #db.param(0)#
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
		</cfscript>
	</cffunction>
	
	<cffunction name="getDefaultSearchFormTemplate" localmode="modern" access="private" output="no">
		<cfscript>
		var output="";
		</cfscript>
		<cfsavecontent variable="output">
			##startFormTag##
			<div class="zSearchFormTable">
			<div>You can select an option multiple times to have multiple entries.</div>
			<div>
			##search_city_id##
			##search_listing_type_id##
			##search_liststatus##
			##search_status##
			##search_style##
			##search_frontage##
			##search_view##
			##search_county##
			##search_listing_sub_type_id##
			</div>
			<div>
			Drag the sliders or type your values
			</div>
			<div>
			##search_rate##
			##search_bedrooms##
			##search_bathrooms##
			##search_sqfoot##
			##search_year_built##
			##search_acreage##
			</div>
			<div>You can comma separate multiple entries</div>
			<div>
			##search_subdivision##
			##search_condoname##
			##search_zip##
			##search_address##
			##search_remarks##
			##search_remarks_negative##
			##search_mls_number_list##
			</div>
			<div>
			##search_listdate##
			##search_sort##
			 ##search_result_limit##
			##search_result_layout##
			##search_group_by##
			</div>
			<div>
			##search_checkboxes##
			</div>
			</div>
			##endFormTag##
		</cfsavecontent>
		<cfreturn output>
	</cffunction>
	
		<!--- 
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
			##endFormTag## --->
<cffunction name="getSearchFormTemplate" localmode="modern" output="yes" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;
	
	var ts=0;
	var q2=0;
	var myOwnStruct=0;
	variables.initSearchForm();
	variables.getContentSearchStruct();
	
	if(structkeyexists(request, 'contentEditor')){ request.zDisableSearchFormSubmit=true; }
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
	
	if (structkeyexists(form, 'mls_saved_search_id')) {
		q2=request.zos.listing.functions.zGetSavedSearchQuery(form.mls_saved_search_id);
		myOwnStruct=structnew(); 
		application.zcore.functions.zquerytostruct(q2,myOwnStruct);
	}  
	
		
	
	if(structkeyexists(form, 'searchId') EQ false or isNumeric(form.searchid) EQ false or (structkeyexists(request, 'zForceSearchId') EQ false and (request.cgi_script_name EQ "/content/index.cfm" or request.cgi_script_name EQ "/index.cfm"))){
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
	variables.zIndex=application.zcore.functions.zso(form,'zIndex',false,1);
	if(isNumeric(variables.zIndex) EQ false){
		application.zcore.functions.zRedirect(request.cgi_script_name&"?searchid=#form.searchid#");
	}
	variables.zIndex=max(variables.zIndex,1);
	
	if(application.zcore.functions.zso(form, 'search_sort') CONTAINS ','){
		application.zcore.functions.z301redirect('/');	
	}
	form.search_surrounding_cities=application.zcore.functions.zso(form,'search_surrounding_cities', true);
	
	if(structkeyexists(request,'theSearchFormTemplate') EQ false){
		request.theSearchFormTemplate=this.getDefaultSearchFormTemplate();
	}
	return request.theSearchFormTemplate;
	</cfscript>

</cffunction>


<cffunction name="getStartForm" localmode="modern" access="private">
	<cfscript>
	var ts=0;
	savecontent variable="local.output"{
		writeoutput('<script type="text/javascript">var zFormData=[];</script>');
		if(isDefined('request.contentEditor') EQ false){
			ts=StructNew();
			ts.name="zMLSSearchForm";
			ts.ajax=false;
			ts.action=request.zos.listing.functions.getSearchFormLink();
			ts.onLoadCallback="loadMLSResults";
			ts.method="post";
			ts.ignoreOldRequests=true;
			ts.successMessage=false;
			ts.onChangeCallback="getMLSCount";
			application.zcore.functions.zForm(ts);
		}
	}
	return local.output;
	</cfscript>
</cffunction>


<cffunction name="getEndForm" localmode="modern" access="private">
	<cfscript>
	savecontent variable="local.output"{
		application.zcore.functions.zEndForm();
	}
	return local.output;
	</cfscript>
</cffunction>

<cffunction name="renderSearchFields" localmode="modern" access="public">
	<cfargument name="searchCriteriaStruct" type="struct" required="yes">
	<cfargument name="formFieldTypeStruct" type="struct" required="yes">
	<cfscript>
	var local={};
	var rs={};
	var i=0;
	var ts=0;
	/*
	need var that groups the output into an existing key for : search_checkboxes to work
	*/
	rs.startFormTag=variables.getStartForm();
	
	for(i in arguments.searchCriteriaStruct.fieldStruct){
		local.curField=arguments.searchCriteriaStruct.fieldStruct[i];
		local.curFormFieldType=arguments.searchCriteriaStruct.formFieldTypeStruct[i];
		
		if(not structkeyexists(arguments.searchCriteriaStruct.formfieldStruct, local.curField.key)){
			arguments.searchCriteriaStruct.formfieldStruct[local.curField.key]=structnew();
		}
		local.curFormFieldStruct=arguments.searchCriteriaStruct.formfieldStruct[local.curField.key];
		if(structkeyexists(arguments.searchCriteriaStruct.dataStruct, local.curField.key)){
			local.curData=arguments.searchCriteriaStruct.dataStruct[local.curField.key];
		}else{
			local.curData={ labels:'', values:'' };	
		}
		if(not structkeyexists(local.curFormFieldStruct, local.curFormFieldType)){
			ts = StructNew();
			ts.name=local.curField.searchField;
			ts.listValues =local.curData.values;
			ts.listValuesDelimiter="|";
			ts.listLabels =local.curData.labels;
			ts.listLabelsDelimiter="|";
			ts.output=false;
			ts.label=local.curField.label;
			if(local.curFormFieldType EQ "multiSelect"){
				ts.enableTyping=false;
				structdelete(ts, 'label');
				ts.overrideOnKeyUp=false;
				ts.enableClickSelect=false;
				ts.selectedOnTop=false;
				ts.range=false;
				ts.allowAnyText=false;
				ts.disableSpider=true;
				ts.selectLabel=local.curField.label;
				ts.inlineStyle="width:100%;";
				savecontent variable="local.javascriptOutput"{
					local.tempRS=application.zcore.functions.zInputLinkBox(ts);
				}
				local.curFormFieldStruct.multiSelect=local.tempRS.output&local.javascriptOutput;
			}else if(local.curFormFieldType EQ "singleSelect"){
				ts.hideselect=true;
				ts.inlineStyle="width:100%;";
				savecontent variable="local.javascriptOutput"{
					local.tempOutput=application.zcore.functions.zInputSelectBox(ts);
				}
				local.curFormFieldStruct.singleSelect=local.tempOutput&local.javascriptOutput;
			}else if(local.curFormFieldType EQ "sliderRange"){
				ts.name2=ts.name&"_high";
				ts.name=ts.name&"_low";
				ts.range=true;
				savecontent variable="local.javascriptOutput"{
					local.tempRS=application.zcore.functions.zInputSlider(ts);
				}
				local.curFormFieldStruct.sliderRange='<label for="'&ts.name&'">'&ts.label&'</label>'&local.tempRS.output&local.javascriptOutput;
			}else if(local.curFormFieldType EQ "text"){
				ts.labelstyle="float:left;clear:both;";
				ts.style="float:left;clear:both;width:96%; padding:1%;padding-top:2px; padding-bottom:2px;";
				ts.size="20";
				savecontent variable="local.javascriptOutput"{
					local.tempOutput=application.zcore.functions.zInput_Text(ts);
				}
				local.curFormFieldStruct.text=local.tempOutput&local.javascriptOutput;
			}else if(local.curFormFieldType EQ "custom"){
				local.curFormFieldStruct.custom="";
			}
		}
		rs[local.curField.searchField]='<div style="width:100%; padding-top:7px; float:left;">'&local.curFormFieldStruct[local.curFormFieldType]&'</div>';
	}
	rs.search_checkboxes=variables.getCheckboxes();
	rs.formSubmitButton=variables.getFormSubmitButton();
	rs.searchFormSubmitURL=request.zos.listing.functions.getSearchFormLink();
	rs.searchFormAdvancedURL=request.zos.listing.functions.getSearchFormLink();
	rs.endFormTag=variables.getEndForm();
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getFormSubmitButton" localmode="modern" access="private">
	<cfscript>
	var ts=0;
	if(application.zcore.functions.zso(request,'zDisableSearchFormSubmit',false,false) EQ false){
		writeoutput('<div class="zmlsformdiv">');
		if(structkeyexists(request,'theSearchFormTemplate') EQ false){
			ts=StructNew();
			ts.name="formSubmit";
			ts.value="Search";
			ts.friendlyName="";
			if(isDefined('form.searchFormSubmitButtonClass')){
				ts.className=form.searchFormSubmitButtonClass;
				ts.imageInput=false;
				ts.useAnchorTag=true;
			}else if(isDefined('form.searchFormSubmitButtonStyle')){
				ts.style=form.searchFormSubmitButtonStyle;
				ts.imageInput=false;
				ts.useAnchorTag=true;
			}else{
				if(isDefined('form.searchFormSubmitButtonImageURL')){
					ts.imageURL=form.searchFormSubmitButtonImageURL;
				}else{
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
				writeoutput('<script type="text/javascript">/* <![CDATA[ */zDisableSearchFormSubmit=true;/* ]]> */</script>');
			}
			ts.onclick="";
			application.zcore.functions.zInput_submit(ts);
			if(request.cgi_script_name EQ '/z/listing/property/your-saved-searches/index' and isDefined('mls_saved_search_id')){
				writeoutput('<br /><input type="button" name="cancel1" value="Cancel" style="padding:5px; margin-top:5px;" onclick="window.location.href=''/z/listing/property/your-saved-searches/index'';" />');	
			}
			writeoutput('<br style="clear:both;" /><br /><span class="zSearchFormText">');
			if(form.searchFormEnabledDropDownMenus){
				writeoutput('<a href="#request.zos.listing.functions.getSearchFormLink()#" class="zNoContentTransition"><strong style="font-size:14px;">+ Show more options</strong><br />(i.e. Subdivision, zip code, <br />keyword search)</a>');
			}
			if(isDefined('request.zsession.user.id') EQ false){
				writeoutput('<br /><br /><a href="/z/user/preference/index" style="font-size:14px; font-weight:bold;">Login/Create Account</a>');
			}else{
				writeoutput('<br /><br /><span style="font-size:14px; font-weight:bold;">Logged in as #request.zsession.user.first_name#,<br />
			<a href="/?zlogout=1">LOG OUT</a></span>');
			}
			writeoutput('</span>');	
		}
		writeoutput('</div>');
	}
	</cfscript>
</cffunction>
	
<cffunction name="processSearchFormTemplate" localmode="modern" access="public">
	<cfargument name="fieldStruct" type="struct" required="yes">
	<cfargument name="template" type="string" required="yes">
	<cfscript>
	var local={};
	var sfSortStruct2={};
	for(local.i in arguments.fieldStruct){
		arguments.template=replacenocase(arguments.template,"##"&local.i&"##",arguments.fieldStruct[local.i],"ONE");
	}
	for(local.i in sfSortStruct2){
		arguments.template=replacenocase(arguments.template,"##"&local.i&"##",sfSortStruct2[local.i],"ONE");
	}
	return arguments.template;
	</cfscript>
</cffunction>
    
    </cfoutput>
</cfcomponent>