<cfcomponent extends="base">
	<cfoutput>
	<cfscript>
	this.mls_provider="far";
	</cfscript> 
    <cffunction name="init" localmode="modern" output="no" returntype="any">
    	<cfargument name="sharedStruct" type="struct" required="yes">
        <cfscript>
		
		var qfeatures=0;
		var ts=0; 
		db=request.zos.queryObject;

		arguments.sharedStruct.featureCodeStruct=structnew();
		arguments.sharedStruct.arrFeatureCodes=arraynew(1);
		if(request.zos.istestserver){
			variables.hqPhotoPath="#request.zos.sharedPath#mls-images/#this.mls_id#/";
		}else{
			variables.hqPhotoPath="#request.zos.sharedPath#mls-images/#this.mls_id#/";
		}
		this.getDataObject(); 

		</cfscript>
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("far_feature", request.zos.zcoreDatasource)# far_feature 
		WHERE far_feature_deleted = #db.param(0)#
		ORDER BY `far_feature`.far_feature_type ASC, `far_feature`.far_feature_description ASC
		</cfsavecontent><cfscript>qFeatures=db.execute("qFeatures");</cfscript>
        <cfloop query="qFeatures"><cfscript>
		if(structkeyexists(arguments.sharedStruct.featureCodeStruct, qFeatures.far_feature_code) EQ false){
			arrayappend(arguments.sharedStruct.arrFeatureCodes, qFeatures.far_feature_code);
			ts=structnew();
			ts.type=qFeatures.far_feature_type;
			ts.label=qFeatures.far_feature_description;
			ts.index=arraylen(arguments.sharedStruct.arrFeatureCodes);
			arguments.sharedStruct.featureCodeStruct[qFeatures.far_feature_code]=ts;
		}
		</cfscript></cfloop>
    </cffunction> 

    <cffunction name="initImport" localmode="modern" output="no" returntype="any">
    	<cfargument name="resource" type="string" required="yes">
        <cfargument name="sharedStruct" type="struct" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var i=0;
		db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# city 
		WHERE state_abbr = #db.param('FL')# and 
		city_deleted = #db.param(0)#";
		var qC=db.execute("qC"); 
		if(request.zos.istestserver){
			variables.hqPhotoPath="#request.zos.sharedPath#mls-images/#this.mls_id#/";
		}else{
			variables.hqPhotoPath="#request.zos.sharedPath#mls-images/#this.mls_id#/";
		}
		arguments.sharedStruct.lookupStruct.idxcolumns="far_mls_id,far_mls_state_id,far_mls_listing_id,far_tln_firm_id,far_mls_office_name,far_mls_office_phone,far_tln_realtor_id,far_mls_agent_name,far_mls_agent_phone,far_listing_date,far_listing_exp_date,far_sold_date,far_available_date,far_property_type_code,far_property_type_description,far_remarks,far_status_code,far_sale_price,far_sold_price,far_property_state_id,far_street_number,far_street_name,far_street_type,far_street_direction,far_unit_number,far_longitude,far_latitude,far_city,far_city_id,far_zip_code,far_zip_plus4,far_mls_area,far_county,far_fips_county_code,far_subdivision,far_community_name,far_year_built,far_acres,far_lot_dimensions,far_lot_square_footage,far_lot_square_footage_land,far_building_square_footage,far_bedrooms,far_baths_total,far_baths_full,far_baths_half,far_baths_three_quarter,far_fireplace_number,far_total_rooms,far_school_district,far_school_elementary,far_school_middle,far_school_junior_high,far_school_high,far_total_units,far_total_buildings,far_total_lots,far_hoa_fees,far_owners_name,far_legal,far_apn,far_taxes,far_tax_year,far_section,far_range,far_township,far_rent_on_season,far_rent_off_season,far_photo_ind,far_last_mls_update_date,far_master_bed,far_bed2,far_bed3,far_bed4,far_bed5,far_kitchen,far_breakfast,far_laundry,far_den,far_dining,far_family,far_living,far_great,far_extra,far_feature_codes,far_mls_office_id,far_mls_agent_id,far_virtual_tour_url,far_photo_quantity,far_photo_url,far_photo_most_recent_date";
		arguments.sharedStruct.lookupStruct.propertyType=structnew();
		arguments.sharedStruct.lookupStruct.propertyType["S"]="Single Family Home";
		arguments.sharedStruct.lookupStruct.propertyType["M"]="Condo/Town Home";
		arguments.sharedStruct.lookupStruct.propertyType["B"]="Mobile Home";
		arguments.sharedStruct.lookupStruct.propertyType["V"]="Vacant Land";
		arguments.sharedStruct.lookupStruct.propertyType["C"]="Commercial Property";
		arguments.sharedStruct.lookupStruct.propertyType["D"]="Multi-Family";
		arguments.sharedStruct.lookupStruct.propertyType["R"]="Rentals";
		if(arguments.resource NEQ "property"){
			application.zcore.template.fail("Invalid resource, ""#arguments.resource#"".");
		}
		arguments.sharedStruct.lookupStruct.table="far";
		arguments.sharedStruct.lookupStruct.primaryKey="far_mls_listing_id";
		arguments.sharedStruct.lookupStruct.arrColumns=listtoarray(arguments.sharedStruct.lookupStruct.idxcolumns);
		arguments.sharedStruct.lookupStruct.idColumnOffset=0;
		for(i=1;i LTE arraylen(arguments.sharedStruct.lookupStruct.arrColumns);i++){
			if(arguments.sharedStruct.lookupStruct.arrColumns[i] EQ 'far_mls_listing_id'){
				arguments.sharedStruct.lookupStruct.idColumnOffset=i;
			}
		}
		</cfscript>
        <cfloop query="qC"><cfscript>
        arguments.sharedStruct.lookupStruct.cityIDXStruct[qC.city_mls_id]=qC.city_name&"|"&qC.state_abbr;
        </cfscript></cfloop>
    </cffunction> 
    
    
    <cffunction name="getDataObject" localmode="modern" output="no">
    	<cfscript>
		if(structkeyexists(variables, 'mlsDataCom') EQ false){
			variables.mlsDataCom=createobject("component", "zcorerootmapping.mvc.z.listing.mls-provider.florida-idxdata");
		}
		return variables.mlsDataCom;
		</cfscript>
    </cffunction>
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		
		var ts=structnew();
		var columnIndex=structnew();
		 var i=0;
		 var cityName=0;
		 var cid=0;
		 var arrF=0;
		 var arrS=0;
		 var let=0;
		 var tmp=0;
		 var arrS2=0;
		 var arrS3=0;
		 var ts2=0;
		 var curLat=0;
		 var curLong=0;
		 var address=0;
		 var rc=0;
		 var rc1=0;
		 var pos=0;
		 var ar23=0;
		 var newList=0;
		 var values=0;
		 var rs5=0;
		 var dataCom=0;
		 var s=0;
		var rs=0;
		 
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
		  if( i NEQ 91){
			if(arguments.ss.arrData[i] EQ '0'){
				arguments.ss.arrData[i]="";	
			}
			ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
		  }
		  else{
		  	ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[91]]="";
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[91]]=91;
		  }
		}
		
		if(findnocase(","&ts.far_subdivision&",", ",,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			ts.far_subdivision="";
		}else if(ts.far_subdivision NEQ ""){
			ts.far_subdivision=application.zcore.functions.zFirstLetterCaps(ts.far_subdivision);
		}
		this.price=ts.far_sale_price;
		cityName="";
		cid=0;
		if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityIDXStruct, ts.far_city_id)){
			cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityIDXStruct[ts.far_city_id];
			if(structkeyexists(request.zos.listing.cityStruct, cityName)){
				cid=request.zos.listing.cityStruct[cityName];
			}
		}
		
		arguments.ss.arrData[columnIndex["far_subdivision"]]=ts.far_subdivision;
		arguments.ss.arrData[columnIndex["far_city_id"]]=""&cid;
		
		arrF=listtoarray(ts.far_feature_codes);
		arrS=[];
		arrS2=[];
		arrS3=[];
		for(i=1;i LTE arraylen(arrF);i++){
			let=left(arrF[i],1);
			if(let EQ 'X'){
				tmp=this.listingLookupNewId("view",trim(arrF[i]));
				if(tmp NEQ ""){
					arrayappend(arrS,tmp);
				}
				tmp=this.listingLookupNewId("frontage",trim(arrF[i]));
				if(tmp NEQ ""){
					arrayappend(arrS2,tmp);
				}
			}else if(let EQ 'Y'){
				tmp=this.listingLookupNewId("style",trim(arrF[i]));
				if(tmp NEQ ""){
					arrayappend(arrS3,tmp);
				}
			}
		}
		local.listing_view=arraytolist(arrS);
		local.listing_frontage=arraytolist(arrS2);
		local.listing_style=arraytolist(arrS3);
		
		local.listing_type_id=this.listingLookupNewId("listing_type",ts.far_property_type_code);
		local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type",ts.far_property_type_description);
		local.listing_county=this.listingLookupNewId("county",ts.far_county);
		ts2=structnew();
		ts2.field=ts.far_remarks;
		ts2.yearbuiltfield=ts.far_year_built;
		if(ts.far_feature_codes CONTAINS 'H20'){
			ts2.foreclosureField=1;
		}else{
			ts2.foreclosureField=0;
		}
		s=this.processRawStatus(ts2);
		if(ts.far_property_type_code EQ 'R'){
            s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
            StructDelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
		}
		if(arguments.ss.listing_id EQ "8-590488"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]);
		}else if(ts.far_feature_codes CONTAINS 'H21'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}else{
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]);
		}
		if(ts.far_feature_codes CONTAINS 'H08'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}
		if(ts.far_feature_codes CONTAINS 'H06'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}		
		if(ts.far_feature_codes CONTAINS 'B04' or ts.far_feature_codes CONTAINS 'B05'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
		}
		if(ts.far_feature_codes CONTAINS 'B13'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["pre construction"]]=true;
		}
		if(ts.far_feature_codes CONTAINS 'B06'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["remodeled"]]=true;
		}
		if(ts.far_feature_codes CONTAINS 'B11'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["model home"]]=true;
		}
		
		local.listing_status=structkeylist(s,",");
		
		local.listing_pool=0;
		pos=refindnocase("(U01|U02|U03|U04|U05|U06|U07|U08|U09)",ts.far_feature_codes);//C11|C15|
		if(pos NEQ 0){
			local.listing_pool=1;	
		}else if(len(rereplacenocase(ts.far_remarks,"(room for .*pool)","","ALL")) EQ len(ts.far_remarks) and ts.far_remarks CONTAINS 'pool' and ts.far_remarks does not contain 'whirlpool' and ts.far_remarks does not contain 'no pool'){
			local.listing_pool=1;
		}
		
		curLat="";
		curLong="";
		address=application.zcore.functions.zFirstLetterCaps("#ts.far_street_number# #ts.far_street_direction# #ts.far_street_name# #ts.far_street_type#");
		if(ts.far_latitude NEQ ""){
			curLat=ts.far_latitude;
			curLong=ts.far_longitude;
		}else{
			if(trim(address) NEQ ""){
				rs5=this.baseGetLatLong(address, ts.far_mls_state_id, ts.far_zip_code, arguments.ss.listing_id);
				if(rs5.success){
					curLat=rs5.latitude;
					curLong=rs5.longitude;
				}
			}
		}
		if(ts.far_unit_number NEQ ''){
			address&=" Unit: #ts.far_unit_number#";	
		}
		rc=arraylen(arguments.ss.arrData);
		rc1=arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
		if(rc GT rc1){
			ar23=arraynew(1);
			for(i=1;i LTE rc1;i++){
				arrayappend(ar23, arguments.ss.arrData[i]);
			}
		}else{
			ar23=arguments.ss.arrData;
		}
		
		dataCom=this.getDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage=ts.far_acres;
		rs.listing_baths=ts.far_baths_total;
		rs.listing_halfbaths=ts.far_baths_half;
		rs.listing_beds=ts.far_bedrooms;
		rs.listing_city=cid;
		rs.listing_county=local.listing_county;
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=ts.far_sale_price;
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=ts.far_mls_state_id;
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet=ts.far_lot_square_footage;
		rs.listing_square_feet=ts.far_building_square_footage;
		rs.listing_subdivision=ts.far_subdivision;
		rs.listing_year_built=ts.far_year_built;
		rs.listing_office=ts.far_tln_firm_id;
		rs.listing_agent=ts.far_tln_realtor_id;
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=ts.far_photo_quantity;
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_address=trim(address);
		rs.listing_zip=ts.far_zip_code;
		rs.listing_condition="";
		rs.listing_parking="";
		rs.listing_region="";
		rs.listing_tenure=""; 
		if(ts.far_status_code EQ "P"){
			rs.listing_liststatus="7";
		}else{
			rs.listing_liststatus="1";
		}
		rs.listing_data_remarks=ts.far_remarks;
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=ts.far_zip_code;
		rs.listing_data_detailcache1=listing_data_detailcache1;
		rs.listing_data_detailcache2=listing_data_detailcache2;
		rs.listing_data_detailcache3=listing_data_detailcache3;

		rs.listing_track_sysid="";
		return {
			listingData:rs,
			columnIndex:columnIndex,
			arrData:arguments.ss.arrData
		};
		</cfscript>
    </cffunction> 
    
    
    <cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
    	<cfargument name="mls_pid" type="string" required="yes">
        <cfargument name="num" type="numeric" required="no" default="#1#">
    	<cfscript>
		var qP=0;
		var photo=0;
		var db=request.zos.queryObject;
		 db.sql="SELECT listing_data_json FROM #db.table("listing_data", request.zos.zcoreDatasource)#
		 WHERE listing_id = #db.param(this.mls_id&"-"&arguments.mls_pid)#";
		 qP=db.execute("qP");
		if(qP.recordcount EQ 0){
			return "";
		}
		js=deserializeJson(qP.listing_data_json);
		if(application.zcore.functions.zso(js, 'far_photo_url') EQ ""){
			return "";
		}
		if(arguments.num EQ 1){
			photo=js.far_photo_url;
		}else{
			photo=replace(js.far_photo_url,'.jpg','_'&arguments.num&'.jpg');
		}
		return photo;
		</cfscript>
    </cffunction>
    
    <cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
        <cfargument name="row" type="numeric" required="no" default="#1#">
        <cfargument name="fulldetails" type="boolean" required="no" default="#false#">
    	<cfscript>
		
		var i=0;
		var column=0;
		var features=0; 
		var arrF=0;
		var details=0;
		var value=0;
		var cs8328=0;
		var cs383=0;
		var curType=0;
		var curStruct=0;
		var curStruct383=0;
		var arrV=0;
		var idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails);
		var a2=listtoarray(lcase(arguments.ss.columnlist));
		for(i=1;i LTE arraylen(a2);i++){
			column=a2[i];
			value=arguments.ss[column];
			if(value NEQ ""){
				idx[column]=value;
			}else{
				idx[column]="";
			}
		}
		features="";
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		

		arrF=listtoarray(application.zcore.functions.zso(arguments.ss, 'far_feature_codes'),",",false);
		curType="";
		curStruct=request.zos.listing.mlsStruct[this.mls_id].sharedStruct;
		curStruct383=structnew();
		arrV=arraynew(1);
		if(isDefined('curStruct.featureCodeStruct.X12.index')){
			for(i=1;i LTE arraylen(arrF);i++){
				if(structkeyexists(curStruct.featureCodeStruct, arrF[i])){
					curStruct383[curStruct.featureCodeStruct[arrF[i]].index]=curStruct.featureCodeStruct[arrF[i]];
				}
			}
			arrV=structkeyarray(curStruct383);
			arraysort(arrV,"numeric","asc");
			for(i=1;i LTE arraylen(arrV);i++){
				cs8328=curStruct383[arrV[i]];
				cs383="";
				if(curType NEQ cs8328.type){
					curType=cs8328.type;
					cs383='<tr><td colspan="2"><h3>#cs8328.type#</h3></td></tr>';
				}
				cs383&='<tr><td colspan="2">#cs8328.label#</td></tr>';
				arrV[i]=cs383;
			}
		}
		features=arraytolist(arrV,"");
		
		idx["features"]=features;
		
		request.lastPhotoId=arguments.ss.listing_id;
		if(application.zcore.functions.zso(arguments.ss, 'far_photo_quantity') EQ 0){
			// check for permanent images or show not available image.
			if(arguments.ss.far_photo_ind eq 'x' and fileexists(request.zos.globals.serverhomedir&"a/listings/images/images_permanent/#arguments.ss.listing_id#.jpg")){
				idx["photo1"]='/z/a/listing/images/images_permanent/#arguments.ss.listing_id#.jpg';
			}else{
				idx["photo1"]='/z/a/listing/images/image-not-available.gif';
			}
		}else{
			idx["photo1"]=application.zcore.functions.zso(arguments.ss, 'far_photo_url');
			for(i=2;i LTE application.zcore.functions.zso(arguments.ss, 'far_photo_quantity');i++){
				idx["photo"&i]=replace(application.zcore.functions.zso(arguments.ss, 'far_photo_url'),'.jpg','_'&i&'.jpg');
			}
		}
		idx["officeName"]=application.zcore.functions.zso(arguments.ss, 'far_mls_office_name');
		idx["agentName"]=application.zcore.functions.zso(arguments.ss, 'far_mls_agent_name');
		idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, 'far_virtual_tour_url');
		
		idx["virtualtoururl"]=replace(application.zcore.functions.zso(idx, "virtualtoururl"),"htttp:","http:");
		if(idx["virtualtoururl"] NEQ "" and find("http://",idx["virtualtoururl"]) EQ 0 and (find(".",idx["virtualtoururl"]) NEQ 0 and find("/",idx["virtualtoururl"]) NEQ 0)){
			idx["virtualtoururl"]&="http://"&idx["virtualtoururl"];
		}
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, 'far_zip_code');
		idx["maintfees"]=application.zcore.functions.zso(arguments.ss, 'far_hoa_fees');
		details="";
		</cfscript>
        <cfif arguments.fulldetails>
        <cfsavecontent variable="details"><table class="ztablepropertyinfo">
        #idx.listing_data_detailcache1#
        #idx.listing_data_detailcache2#
        #idx.listing_data_detailcache3#
		</table></cfsavecontent>
        </cfif>
        <cfscript>
		idx.details=details;
		return idx;
		</cfscript>
    </cffunction>
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var fd=0;
		var arrError=[];
		var ts=0;
		var arrSubType=0;
		var arrCounty=0;
		// mls_id 9
		
		ts=structnew();
		ts["S"]="Single Family";
		ts["M"]="Condo\Town Home";
		ts["B"]="Mobile Home";
		ts["V"]="Vacant Land";
		ts["C"]="Commercial";
		ts["D"]="Multi-Family";
		ts["R"]="Rental";        
		
		for(i in ts){
			arrayappend(arrSQL,"('9','listing_type','#ts[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		ts=structnew();
		ts["Y11"]="A-frame";
		ts["Y12"]="Cabin";
		ts["Y13"]="Cape Cod";
		ts["Y14"]="Chalet style";
		ts["Y15"]="Colonial";
		ts["Y16"]="Contemporary";
		ts["Y17"]="Cottage/bungalow style";
		ts["Y18"]="Country style";
		ts["Y19"]="Denver Square style";
		ts["Y20"]="Duplex";
		ts["Y21"]="Earth berm";
		ts["Y22"]="Farm house style";
		ts["Y23"]="Highrise";
		ts["Y24"]="Penthouse";
		ts["Y25"]="Ranch";
		ts["Y26"]="Raised ranch style";
		ts["Y27"]="Spanish";
		ts["Y28"]="Studio/efficiency";
		ts["Y29"]="Traditional";
		ts["Y30"]="Tudor";
		ts["Y31"]="Victorian";
		ts["Y32"]="Townhouse style";
		ts["Y33"]="Cluster style";
		ts["Y34"]="Dutch colonial style";
		ts["Y35"]="Split foyer style";
		ts["Y36"]="Georgian style";
		ts["Y37"]="Williamsburg style";
		ts["Y38"]="Split-level";
		ts["Y39"]="Bungalow style";
		ts["Y40"]="Santa Fe style";
		ts["Y41"]="Condo";
		ts["Y42"]="C+C601oop condominium";
		ts["Y43"]="English style";
		ts["Y44"]="Mediterranean style";
		ts["Y45"]="Oriental style";
		ts["Y46"]="Western style";
		ts["Y48"]="Time share";
		ts["Y61"]="Four-plex";
		ts["Y62"]="French provincial";
		ts["Y63"]="Historic";
		ts["Y67"]="Multiunit";
		ts["Y71"]="Triplex";
		ts["Y73"]="Two family";
		ts["Y74"]="Three family";
		ts["Y75"]="Four family";
		ts["Y76"]="Five or more family";
		ts["Y77"]="Residential";
		ts["Y78"]="Commercial";
		ts["Y79"]="Agricultural";
		ts["Y80"]="Industrial";
		ts["Y81"]="Short term rental";
		
		for(i in ts){
			arrayappend(arrSQL,"('9','style','#ts[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		ts=structnew();
		ts["X02"]="Lake view";
		ts["X04"]="Lake or river view";
		ts["X06"]="River view";
		ts["X07"]="Ocean view";
		ts["X08"]="Ocean access";
		ts["X11"]="Bay view";
		ts["X13"]="Canal view";
		ts["X15"]="Lagoon view";
		ts["X17"]="Valley/canyon view";
		ts["X18"]="Swimming pool view";
		ts["X19"]="Clubhouse view";
		ts["X20"]="Tennis Court view";
		ts["X22"]="Golf course view";
		ts["X23"]="Garden view";
		ts["X24"]="Greenbelt view";
		ts["X26"]="Hill/mountain view";
		ts["X27"]="Back range view";
		ts["X28"]="Foothills view";
		ts["X29"]="Panoramic Views";
		ts["X30"]="Park-like views";
		ts["X31"]="View of the plains";
		ts["X32"]="Adjacent to park";
		ts["X33"]="City lights view";
		ts["X34"]="Scenic view";
		ts["X35"]="Waterview";
		ts["X37F"]="Gulf view";
		
		ts["X01"]="Lake access";
		ts["X05"]="River frontage/Access";
		ts["X38F"]="Gulf access";
		
		for(i in ts){
			arrayappend(arrSQL,"('9','view','#ts[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		ts=structnew();
		ts["X03"]="Lakefront";
		ts["X09"]="Oceanfront";
		ts["X10"]="Bay or ocean frontage";
		ts["X12"]="Waterfront";
		ts["X14"]="Canalfront";
		ts["X16"]="Intracoastal";
		ts["X21"]="Golf course";
		ts["X25"]="Hill country";
		ts["X36F"]="Gulf frontage";
		for(i in ts){
			arrayappend(arrSQL,"('9','frontage','#ts[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		arrSubType=listtoarray("Single Family Home|Free Standing|Single Family Use|Single Family|Condo|Townhouse|Duplex|One Story|Office/Warehouse|Commercial|Villa|Mixed Use|1/2 Duplex|Residential Development|General Commercial|Retail|Manufactured|Farmland|Office|Timberland|Warehouse-storage|Five or More|Four Units|Mobile Home Use|PUD|Industrial|Ranchland|Crop Producing Farm|Car Wash|Apartment|Co-op|Manufactured/Mobile out of Park|Home with Rental Unit|High-rise|Business Opportunity|Two Story|One Story,Manufactured|Manufactured/Mobile in Park|Other|Plant Nursery|Triplex|Strip Center|Multi-Family|One Story,Single Family Home|Single Family Home,One Story|Three Story,Villa|Heavy Weight Sales Serv|Two Story,Condo|Acreage/Ranch/Grove|Two Story,Townhouse|Three Story|Manufacturing|Restaurants/Bars|Medical Offices|Group Housing/ACLF|Distribution|1/2 Duplex,Villa|Warehouse|Garage Apt|Business|Business Opp. w/RE||One Story,Villa|One Story,Villa,Single Family Home|Condo,Townhouse|Villa,One Story|Split Level,One Story|Efficiency,Garage Apt|Condo,Three Story|Showroom/Office|Condo,High-rise|One Story,Two Story|Vehicle Related|Automotive|One Story,Single Family Home,Villa|Condo,Two Story|Condo,One Story|Groves|Two Story,Single Family Home|Single Family Home,Villa|Split Level|Apartments|High-rise,Condo|One Story,Townhouse,Condo|One Story,Condo|Vehicle Repair|Subdivided Vacant Land|Motel/Hotel|Service/Fueling Station|Flex Space|Day Care|Personal Services|Villa,1/2 Duplex|Three Story,Apartment|Triplex Use|Duplex Use|Three Story,Townhouse|Planned Unit Development|Executive Suites|Neighborhood Center|Three Story,Condo,Mid-rise|Condo,Mid-rise|Mobile Home/RV Park|Business Opp. No/RE|Community Shopping Cntr|Modular|Condo,High-rise,Garage Apt,Mid-rise|Townhouse,Condo,Two Story|Single Family Home,One Story,Garage Apt|Mid-rise,Condo|Four Units Use|One Story,Apartment|Townhouse,One Story|One Story,Villa,1/2 Duplex|Special Purpose|Townhouse,Two Story|Condo,Townhouse,Two Story|Single Family Home,Two Story|Townhouse,Condo|Grocery|Working Ranch|Ranch|Food/Drink Sell/Service|Dude Ranch|Mobile|Home & Income Housing|Churches|Mini-warehouse|Manufactured,Mobile w/Land Double Out of Park|Vehicle sales|Mobile w/Land Double in ParkD|One Story,Townhouse|Tree Farm|Marine|Apartment,Efficiency|One Story,1/2 Duplex|Fish Farm|Self-storage|Bar/Club|Townhouse,Three Story|Mid-rise|Sod Farm|Net Leased|Mobile w/Land Single Out of Park|Efficiency|Recreation|Billboard Site|Restaurants/BarsA09Ret|Two Story,Townhouse,Condo|Apartment,Two Story|Villa,Three Story|Mobile w/Land Single in Park|Tri-Level|One Story,Two Story,Single Family Home|1/2 Duplex,Townhouse,Condo,Apartment|Two Story,1/2 Duplex|Single Family Home,Mobile w/Land Double Out of Par|One Story,Split Level|Outside Storage only|Two Story,Efficiency,Garage Apt|Villa,Condo,One Story|Two Story,1/2 Duplex,Condo|Mobile w/Land Double in|One Story,Condo,Mid-rise|Condo,Two Story,Single Family Home|Split Level,Single Family Home|One Story,Condo,Single Family Home|Two Story,Condo,Townhouse|Two Story,Apartment|Tri-Level,Single Family Home|Villa,One Story,1/2 Duplex|Two Story,Single Family Home,Apartment|Condo,Townhouse,One Story|Three Story,Condo|Mobile w/Land Single Ou|Mobile w/Land Double Out of Park|Two Story,Garage Apt,Single Family Home|Fashion / Specialty|Mobile w/Land Double in Park|Apartment,One Story,Single Family Home|Two Story,Villa,Condo|Theatre|One Story,1/2 Duplex,Villa|1/2 Duplex,Condo|Condo,Townhouse,Villa|Split Level,Three Story|Condo  Town Home|Vacant Land|Rental","|");
		for(i=1;i LTE arraylen(arrSubType);i++){
			arrayappend(arrSQL,"('9','listing_sub_type','#arrSubType[i]#','#arrSubType[i]#','#request.zos.mysqlnow#','#arrSubType[i]#','#request.zos.mysqlnow#', '0')");
		}
		
		arrCounty=listtoarray("Alachua,Baker,Bay,Bradford,Brevard,Broward,Calhoun,Charlotte,Citrus,Clay,Collier,Columbia,De Soto,Dixie,Duval,Escambia,Flagler,Franklin,Gadsden,Gilchrist,Glades,Gulf,Hamilton,Hardee,Hendry,Hernando,Highlands,Hillsborough,Holmes,Indian River,Jackson,Jefferson,Lafayette,Lake,Lee,Leon,Levy,Liberty,Madison,Manatee,Marion,Martin,Miami-Dade,Monroe,Nassau,Okaloosa,Okeechobee,Orange,Osceola,Palm Beach,Pasco,Pinellas,Polk,Putnam,Saint Johns,Saint Lucie,Santa Rosa,Sarasota,Seminole,Sumter,Suwannee,Taylor,Union,Volusia,Wakulla,Walton,Washington");
		for(i=1;i LTE arraylen(arrCounty);i++){
			arrayappend(arrSQL,"('9','county','#arrCounty[i]#','#arrCounty[i]#','#request.zos.mysqlnow#','#arrCounty[i]#','#request.zos.mysqlnow#', '0')");
		}
				
		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>