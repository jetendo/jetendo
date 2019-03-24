<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>	<cfscript>
	this.retsVersion="1.7";
	
	this.mls_id=17;
	this.useRetsFieldName="system";
	this.arrColumns=listtoarray("BEDROOMS	ACREAGE	AD_DETAILS	AD_YN	AGENT_OTHER_CONTACT_DESC	AGENT_OTHER_CONTACT_PHONE	AREA	ASSESSMENT_YN	AVAILABLE_DATE	BATHS	BATHS_FULL	BATHS_HALF	BOM_DATE	BROKERAGE_INTEREST	BUILDING_SQFT	CAM	CAM_PER	CATEGORY	CITY	CITY_CODE	CO_LA_CODE	CO_LO_CODE	CONSTRC_STATUS	CONTACTS	COUNTY	CURRENT_PRICE	DATE_CREATED	DATE_MODIFIED	DESCRIPTION	DESIGN	DIRECTIONS	ELEM_SCHOOL	FILE_NUMBER	FTR_APPLIANCE	FTR_ASSMORTGAGETYPE	FTR_CONSTRC	FTR_CONSTRC_STATUS	FTR_ENERGY	FTR_EXTERIOR	FTR_HOAINCL	FTR_INTERIOR	FTR_INTERNET	FTR_LEASES	FTR_LISTING_CLASS	FTR_LOTACCESS	FTR_LOTDESC	FTR_PARKING	FTR_PROJFACILITIES	FTR_ROOMDESC	FTR_SALE_TYPE	FTR_STYLE	FTR_TOSHOW	FTR_UTILITIES	FTR_WATERFRONT	FTR_WATERVIEW	FTR_ZONING	GEO_PRECISION	GEORESULT	HIGH_SCHOOL	HVAC_WHSE_SQFT	INCLUDE_ADDRESS_YN	LA_CODE	LAND_LEASE_AMOUNT	LATITUDE	LEASE_EXPIRE_DATE	LEASE_SQFT_YEAR	LEGALS	LIST_PRICE	LISTING_CLASS	LO_CODE	LONGITUDE	LOOPNET_1	LOOPNET_2	LOOPNET_3	LOOPNET_4	LOOPNET_5	LOOPNET_6	LOT_DEPTH	LOT_DIMENSIONS	LOT_FRONTAGE	MAINT_FEE	MAINT_TERM	MASTER_DEVELOPMENT	MEDIA_FLAG	MIDDLE_SCHOOL	MLS_ACCT	MLS_ID	NO_ASSIGNED_SPACES	NO_CARPORT_SPACES	NO_COVERED_SPACES	NO_DRIVEWAY_SPACES	NO_GARAGE_SPACES	NO_STREET_SPACES	NO_TOTAL_PARKING_SPACES	NUM_DOCK_HIGH_DOORS	NUM_FLOORS	NUM_GROUND_LEVEL_DOORS	NUM_ROOMS	NUM_STORIES_ABV_GRND	NUM_STORIES_BLDG	NUM_UNITS	OCCUPANCY_YN	OFFICE_CLASS	OFFICE_SQFT	PARCEL_ID	PHOTO_COUNT	PHOTO_DATE_MODIFIED	PRE_CON_YN	PRICE_ACRE	PRICE_CHANGE_DATE	PRICE_SQFT	PRICE_UNIT	PROJ_CLOSE_DATE	PROJ_NAME	PROPERTY_NAME	PROPTYPE_COM_IND	PROPTYPE_COM_LAND	PROPTYPE_COM_NLI	PROPTYPE_COM_OFFICE	PROPTYPE_COM_RETAIL	RAIL_YN	REMARKS	RES_HOA_FEE	RES_HOA_TERM	RETAIL_SQFT	SITE_INFORMATION	SPRINKLERS_YN	SQFT_BALCONY	STATE	STATUS	STATUS_DATE	STATUS_FLAG	STORIES	STREET_NAME	STREET_NUM	SUB_AREA	SUBDIVISION	SUBJ_TO_LEASE_YN	TERM	TOT_BLDG_SQFT	TOT_HEAT_SQFT	TOT_WHSE_SQFT	UNIT_NUM	VACANCY_RATE	VACANT_YN	VT_YN	WF_DESCRIPTION	WF_FEET	YEAR_BUILT	ZIP	ZONING",chr(9));
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/17/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/17/";
	}
	this.mls_provider="rets17";
	variables.resourceStruct=structnew();
	variables.resourceStruct["property"]=structnew();
	variables.resourceStruct["property"].resource="property";
	variables.resourceStruct["property"].id="mls_acct";
	variables.resourceStruct["office"]=structnew();
	variables.resourceStruct["office"].resource="office";
	variables.resourceStruct["office"].id="lo_lo_code";
	variables.resourceStruct["agent"]=structnew();
	variables.resourceStruct["agent"].resource="agent";
	variables.resourceStruct["agent"].id="la_la_code";
	</cfscript> 
    
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var rs5=0;
		var r222=0;
		var values="";
		var newlist="";
		var i=0;
		var columnIndex=structnew();
		var cityname=0;
		var cid=0;
		var ts=0;
		var cityName=0;
		var address=0;
		var cid=0;
		var curLat=0;
		var curLong=0;
		var s=0;
		var cityStruct222=0;
		var arrt3=0;
		var uns=0;
		var tmp=0;
		var arrt=0;
		var arrt2=0;
		var ts2=0;
		var datacom=0;
		var values=0;
		var sub=0;
		var rs=0;
		var ad=0;
		var arrs=0;
		var arrFTR_PROJFACILITIES=0;
		var ARRFTR_EXTERIOR=0;
		var p1=0;
		var idx=0;
		var rs=0;
		ts=structnew();
		/*
		
		wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '17-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '17-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '17-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '17-%'; 
		
		*/
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.template.fail("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			if(arguments.ss.arrData[i] EQ '0'){
				arguments.ss.arrData[i]="";	
			}
			ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
		}
		// need to clean this data - remove not in subdivision, 0 , etc.
		if(structkeyexists(ts, "rets17_subdivision")){
			if(findnocase(","&ts["rets17_subdivision"]&",", ",,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["rets17_subdivision"]="";
			}else if(ts["rets17_subdivision"] NEQ ""){
				ts["rets17_subdivision"]=application.zcore.functions.zFirstLetterCaps(ts["rets17_subdivision"]);
			}
			if(ts["rets17_subdivision"] NEQ ""){
				sub=this.getRETSValue("property", "","subdivision",ts["rets17_subdivision"]);//," ","","ALL"));
				if(sub NEQ ""){
					ts["rets17_subdivision"]=sub;
				}
			}
		}
		this.price=ts["rets17_list_price"];
		cityName="";
		cid=0;
		if(ts["rets17_city"] NEQ ""){
			ts["rets17_city"]=this.getRETSValue("property", "","city",ts["rets17_city"]);
			cityName=ts["rets17_city"]&"|"&ts["rets17_state"];
			if(structkeyexists(request.zos.listing.cityStruct, cityName)){
				cid=request.zos.listing.cityStruct[cityName];
			}
			cityName=ts["rets17_city"];
		}
		local.listing_county=this.listingLookupNewId("county",application.zcore.functions.zso(ts, 'rets17_county'));
		if(ts["rets17_county"] NEQ ""){
			ts["rets17_county"]=this.getRETSValue("property", "","county",ts["rets17_county"]);
		}
		//writeoutput(application.zcore.functions.zso(ts, 'rets17_category')&'<br />');
		local.listing_type_id=this.listingLookupNewId("listing_type",application.zcore.functions.zso(ts, 'rets17_category'));
		rs=getListingTypeWithCode(ts["rets17_category"]);
		//ts["rets17_category"]=rs.id;
		ad=application.zcore.functions.zso(ts, 'rets17_street_num');
		if(ad NEQ 0){
			address="#ad# ";
		}else{
			address="";	
		}
		address&=application.zcore.functions.zfirstlettercaps(application.zcore.functions.zso(ts, 'rets17_street_name'));
		/*mapAddress="";
		if(trim(address) NEQ "" and cityName NEQ ""){
			mapAddress=lcase(trim(address)&", "&cityName&", "&application.zcore.functions.zso(ts, 'rets17_state')&" "&application.zcore.functions.zso(ts, 'rets17_zip'));
		}*/
		curLat="";
		curLong="";
		if(application.zcore.functions.zso(ts, 'rets17_latitude',true) NEQ ''){
			curLat=application.zcore.functions.zso(ts, 'rets17_latitude');
			curLong=application.zcore.functions.zso(ts, 'rets17_longitude');
		}else{
			if(trim(address) NEQ ""){// and cityName NEQ ""){
				rs5=this.baseGetLatLong(address,application.zcore.functions.zso(ts, 'rets17_state'),application.zcore.functions.zso(ts, 'rets17_zip'), arguments.ss.listing_id);
				if(rs5.success){
					curLat=rs5.latitude;
					curLong=rs5.longitude;
				}
			}
		}
		if(application.zcore.functions.zso(ts, 'rets17_unit_num') NEQ ''){
			address&=" Unit: "&ts["rets17_unit_num"];	
		}
		
		
		ts2=structnew();
		ts2.field="";//application.zcore.functions.zso(ts, 'rets17_remarks');
		ts2.yearbuiltfield=application.zcore.functions.zso(ts, 'rets17_year_built');
		ts2.foreclosureField="";
		
		s=this.processRawStatus(ts2);
		/* FTR_SALE_TYPE */
		
		arrS=listtoarray(application.zcore.functions.zso(ts, 'rets17_FTR_SALE_TYPE'),",");
		for(i=1;i LTE arraylen(arrS);i++){
			c=trim(arrS[i]);
			if(find(","&c&",",",1.10,2.12,14.10,12.10,11.12,11.10,5.12,5.10,4.12,4.10,3.12,3.10,2.10,") NEQ 0){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
				break;
			}
			if(find(","&c&",",",1.9,2.9,3.9,4.9,5.9,11.9,12.9,14.9,") NEQ 0){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
				break;
			}
			if(find(","&c&",",",1.3,2.3,3.3,4.3,5.3,11.3,12.3,14.3,") NEQ 0){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["auction"]]=true;
				break;
			}
			if(find(","&c&",",",1.8,2.8,3.8,4.8,5.8,11.8,12.8,14.8,") NEQ 0){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["pre-foreclosure"]]=true;
				break;
			}
			if(find(","&c&",",",1.7,2.7,3.7,4.7,5.7,11.7,12.7,14.7,") NEQ 0){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
				break;
			}
			
		}
		
		arrS=listtoarray(application.zcore.functions.zso(ts, 'rets17_ftr_constrc_status'),",");
		for(i=1;i LTE arraylen(arrS);i++){
			c=trim(arrS[i]);
			if(find(","&c&",",",1.3,1.4,2.3,2.4,3.3,3.4,4.3,4.4,12.2,12.3,13.2,13.3,14.3,14.4,") NEQ 0){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
				break;
			}
		}
		// change to check comma separated values...
		if(application.zcore.functions.zso(ts, 'rets17_ftr_sale_type') EQ 9){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else{
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		local.listing_status=structkeylist(s,",");
		local.listing_style=this.listingLookupNewId("style",application.zcore.functions.zso(ts, 'rets17_ftr_style'));
		
		// view & frontage
		arrT2=[];
		arrT3=[];
		
		tmp=application.zcore.functions.zso(ts, 'rets17_ftr_waterfront');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("frontage",arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT3,tmp);
				}
			}
		}
		tmp=application.zcore.functions.zso(ts, 'rets17_ftr_waterview');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("view",arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT2,tmp);
				}
			}
		}
		local.listing_frontage=arraytolist(arrT3);
		local.listing_view=arraytolist(arrT2);
		

		local.listing_pool=0;
		arrFTR_PROJFACILITIES = listtoarray('1.27,2.27,9.27,14.6');
		arrFTR_EXTERIOR = listtoarray('1.29,1.30,1.31,1.32,1.33,2.29,2.30,2.31,2.32,9.29,9.30,9.31,9.32,9.33');
		p1=","&application.zcore.functions.zso(ts, 'rets17_ftr_exterior')&",";
		for(i=1;i LTE arraylen(arrFTR_EXTERIOR);i++){
			if(find(arrFTR_EXTERIOR[i], p1) NEQ 0){
				local.listing_pool=1;
				break;
			}
		}
		p1=","&application.zcore.functions.zso(ts, 'rets17_ftr_projfacilities')&",";
		for(i=1;i LTE arraylen(arrftr_projfacilities);i++){
			if(find(arrftr_projfacilities[i], p1) NEQ 0){
				local.listing_pool=1;
				break;
			}
		}
		idx=ts;
		for(i10 in idx){
			column=i10;
			value=idx[column];
			if(value NEQ ""){
				fieldName=replacenocase(column,"rets17_","");
				if(left(column,8) NEQ 'listing_' and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup, fieldName)){
					arrV=listtoarray(trim(value),',',false);
					arrV2=arraynew(1);
					for(n=1;n LTE arraylen(arrV);n++){
						t2=replace(arrV[n]," ","","ALL");
						t3=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].typeStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup[fieldName]].valueStruct;
						if(structkeyexists(t3, t2)){
							t1=application.zcore.functions.zfirstlettercaps(t3[t2]);
						}else{
							t1="";	
						}
						if(t1 NEQ ""){
							arrayappend(arrV2,t1);
						}
					}
					value=arraytolist(arrV2,", ");
				}
				idx[column]=value;
			}else{
				idx[column]="";
			}
		}
		
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		if(isDefined('idx.rets17_price_change_date') and isdate(idx["rets17_price_change_date"])){
			idx["rets17_price_change_date"]=dateformat(idx["rets17_price_change_date"],"m/d/yyyy");
		}
		if(isDefined('idx.rets17_status_date') and isdate(idx["rets17_status_date"])){
			idx["rets17_status_date"]=dateformat(idx["rets17_status_date"],"m/d/yyyy");
		}
		if(isDefined('idx.rets17_date_created') and isdate(idx["rets17_date_created"])){
			idx["rets17_date_reated"]=dateformat(idx["rets17_date_created"],"m/d/yyyy");
		}
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage=application.zcore.functions.zso(ts, 'rets17_acreage');
		rs.listing_baths=application.zcore.functions.zso(ts, 'rets17_baths_full');
		rs.listing_halfbaths=application.zcore.functions.zso(ts, 'rets17_baths_half');
		rs.listing_beds=application.zcore.functions.zso(ts, 'rets17_bedrooms');
		rs.listing_city=cid;
		rs.listing_county=local.listing_county;
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=application.zcore.functions.zso(ts, 'rets17_list_price');
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=application.zcore.functions.zso(ts, 'rets17_state');
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=",,";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet=application.zcore.functions.zso(ts, 'rets17_sqfttotal');
		rs.listing_square_feet=application.zcore.functions.zso(ts, 'rets17_tot_heat_sqft');
		rs.listing_subdivision=application.zcore.functions.zso(ts, 'rets17_subdivision');
		rs.listing_year_built=application.zcore.functions.zso(ts, 'rets17_year_built');
		rs.listing_office=application.zcore.functions.zso(ts, 'rets17_lo_code');
		rs.listing_agent=application.zcore.functions.zso(ts, 'rets17_la_code');
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=application.zcore.functions.zso(ts, 'rets17_photo_count');
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_condoname=application.zcore.functions.zso(ts, 'rets17_property_name');
		rs.listing_address=trim(address);
		rs.listing_zip=trim(application.zcore.functions.zso(ts, 'rets17_zip'));
		rs.listing_condition="";
		rs.listing_parking="";
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus="1";
		rs.listing_data_remarks=application.zcore.functions.zso(ts, 'rets17_remarks');
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(application.zcore.functions.zso(ts, 'rets17_zip'));
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

    <cffunction name="getDetails" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
        <cfargument name="row" type="numeric" required="no" default="#1#">
        <cfargument name="fulldetails" type="boolean" required="no" default="#false#">
    	<cfscript> 
		var db=request.zos.queryObject; 
		var idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails);
		idx["features"]="";
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		request.lastPhotoId=idx.listing_id;
		if(idx.listing_photocount EQ 0){
			// check for permanent images or show not available image.
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
		}else{
			i=1;
			for(i=1;i LTE idx.listing_photocount;i++){
				local.fNameTemp1=idx.urlMlsPid&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				idx["photo"&i]=request.zos.retsPhotoPath&'17/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
			}
		}
		oid1="0";
		
		d44=dateformat(now(),"yyyymmdd");
		if(structkeyexists(application.zcore,'rets17officelookup') EQ false or application.zcore.rets17officelookupdate NEQ d44){
			t9=structnew();
			throw("deleted office table. need new way to get this info");
			for(i10=1;i10 LTE q1.recordcount;i10++){
				t9[q1.rets17_lo_lo_code[i10]]=q1.rets17_lo_name[i10];
			}
			application.zcore.rets17officelookupdate=d44;
			application.zcore.rets17officelookup=t9;
		}
		
		if(structkeyexists(application.zcore.rets17officelookup, application.zcore.functions.zso(arguments.ss, "rets17_lo_code"))){
			idx.officeName=application.zcore.rets17officelookup[arguments.ss.rets17_lo_code];	
		}else{
			idx.officeName="Firm Name Not Available";
		}
		idx["virtualtoururl"]="";
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, "rets17_zip");
		idx["maintfees"]=application.zcore.functions.zso(arguments.ss, "rets17_maint_fee");
		
		
		</cfscript>
        <cfsavecontent variable="details"><table class="ztablepropertyinfo">
        #idx.listing_data_detailcache1#
        #idx.listing_data_detailcache2#
        #idx.listing_data_detailcache3#
		</table></cfsavecontent>
        <cfscript>
		idx.details=details;
		return idx;
		</cfscript>
    </cffunction>
    
    <cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
    	<cfargument name="mls_pid" type="string" required="yes">
        <cfargument name="num" type="numeric" required="no" default="#1#">
    	<cfscript>
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		return request.zos.retsPhotoPath&'17/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		</cfscript>
    </cffunction>
    </cfoutput>
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var fd=0;
		var arrError=[];
		var db=request.zos.queryObject;
		var arrC=0;
		var qD2=0;
		var qD=0;
		var qId=0;
		var qZ=0;
		var cityCreated=false;
		var failStr="";
		var tempState=0;
		fd=this.getRETSValues("property", "","category");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		fd=this.getRETSValues("property", "","county");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','county','#application.zcore.functions.zfirstlettercaps(fd[i])#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		fd=this.getRETSValues("property", "","ftr_waterfront");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", "","ftr_waterview");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		fd=this.getRETSValues("property", "","ftr_style");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		fd=this.getRETSValues("property", "","city_code");
		//application.zcore.functions.zdump(fd);
		//writeoutput(structcount(fd)&'<br />');
		arrC=arraynew(1);
		failStr="";
		for(i in fd){
			tempState="FL";
			if(fd[i] EQ "Florala"){
				tempState="AL";
			}
			if(fd[i] NEQ "SEE REMARKS" and fd[i] NEQ "NOT AVAILABLE" and fd[i] NEQ "NONE"){
				 db.sql="select * from #db.table("city_rename", request.zos.zcoreDatasource)# city_rename 
				WHERE city_name =#db.param(fd[i])# and state_abbr=#db.param(tempState)# and 
				city_rename_deleted = #db.param(0)#";
				qD2=db.execute("qD2");
				if(qD2.recordcount NEQ 0){
					fd[i]=qD2.city_renamed;
				}
				//arrayappend(arrC,application.zcore.functions.zescape(application.zcore.functions.zFirstLetterCaps(fd[i])));
				 db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# city 
				WHERE city_name =#db.param(fd[i])# and 
				state_abbr=#db.param(tempState)# and 
				city_deleted = #db.param(0)#";
				qD=db.execute("qD");
				if(qD.recordcount EQ 0){
					//writeoutput(fd[i]&" missing<br />");
					 db.sql="select	* from #db.table("zipcode", request.zos.zcoreDatasource)# zipcode 
					WHERE city_name =#db.param(fd[i])# and 
					state_abbr=#db.param(tempState)# and 
					zipcode_deleted = #db.param(0)#";
					qZ=db.execute("qZ");
					if(qZ.recordcount NEQ 0){
						 db.sql="INSERT INTO #db.table("city", request.zos.zcoreDatasource)#  
						 SET city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
						 state_abbr=#db.param(tempState)#,
						 country_code=#db.param('US')#, 
						 city_mls_id=#db.param(i)#,
					 city_deleted=#db.param(0)#,
					 city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
						 city_id=db.insert("q", request.zOS.insertIDColumnForSiteIDTable);
						 db.sql="INSERT INTO #db.table("city_memory", request.zos.zcoreDatasource)#  
						 SET city_id=#db.param(city_id)#, 
						 city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
						 state_abbr=#db.param(tempState)#,
						 country_code=#db.param('US')#, 
						 city_mls_id=#db.param(i)#,
					 city_deleted=#db.param(0)#,
					 city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
						 db.execute("q");
						//writeoutput(city_id);
						cityCreated=true; // need to run zipcode calculations
					}else{
						failStr&=("<a href=""http://maps.google.com/maps?q=#urlencodedformat(fd[i]&', florida')#"" rel=""external"" onclick=""window.open(this.href); return false;"">#fd[i]#, florida</a> is missing in `#request.zos.zcoreDatasource#`.zipcode.<br />");
					}
				}
			}
			
			arrayClear(request.zos.arrQueryLog);
		}
		</cfscript>
		<cfif failStr NEQ "">
			<cfmail to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="Emerald Coast Missing Cities" type="html">
			#application.zcore.functions.zHTMLDoctype()#
			<head>
			<meta charset="utf-8" />
			<title>Missing</title>
			</head>
			
			<body>
			#failStr#
			<br />I need to manually create them.<br /><br />Sample Insert Query:<br />
			INSERT INTO `#request.zos.zcoreDatasource#`.zipcode SET city_type='A', city_name = 'city', state_abbr='FL',country_code='US',zipcode_type='P',zipcode_zip='',zipcode_latitude='',zipcode_longitude='';<br /><br />Use google maps to find the zipcode and lat/long.  Try to zoom in to find closest lat/long.
			</body>
			</html>
			</cfmail>
		</cfif>
		<cfscript>
		return {arrSQL:arrSQL, cityCreated:cityCreated, arrError:arrError};
		</cfscript>
	</cffunction>
</cfcomponent>