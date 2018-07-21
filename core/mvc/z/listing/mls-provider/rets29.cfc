<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
	<cfscript>
	this.retsVersion="1.7";
	
	this.mls_id=29;
	if(request.zos.istestserver){
		hqPhotoPath="#request.zos.sharedPath#mls-images/29/";
	}else{
		hqPhotoPath="#request.zos.sharedPath#mls-images/29/";
	}
	this.useRetsFieldName="system";


	this.arrColumns=listtoarray("Access,AcresCleared,AcresWooded,AdditionalInformation,AssociationFee,AssociationFeeFrequency,AuctionBidInformation,AuctionBidType,BuyerAgentSaleYN,CanSubdivideYN,CDOM,City,CloseDate,ClosePrice,CoListAgentFullName,CoListAgentMLSBoard,CoListAgentMLSID,CoListAgent_MUI,CoListAgentPrimaryBoard,CoListOfficeMLSID,CoListOffice_MUI,CoListOfficeName,CoListTeamMLSID,CoListTeam_MUI,CoListTeamName,CoSellingAgentMLSBoard,CoSellingAgentMLSID,CoSellingAgentPrimaryBoard,CoSellingOfficeMLSID,CoSellingOffice_MUI,CommunityFeatures,ConstructionType,CorrectionCount,Country,CountyOrParish,DeedReference,Directions,DocumentManagerTotalCount,DOM,ElementarySchool,Elevation,ExteriorFeatures,FoundationDetails,GeocodeSource,GreenCertification,GreenHERSScore,HabitableResidenceYN,HighSchool,Latitude,ListAgentDirectWorkPhone,ListAgentFullName,ListAgentMLSID,ListAgent_MUI,ListOfficeMLSID,ListOffice_MUI,ListOfficeName,ListOfficePhone,ListPrice,ListTeamMLSID,ListTeam_MUI,ListTeamName,ListingAgentMLSBoard,ListingAgentPrimaryBoard,ListingContractDate,ListingServiceYN,ListingType,Longitude,LotDimension,LotFeatures,LotSizeArea,LotSizeUnits,MatrixModifiedDT,Matrix_Unique_ID,MiddleOrJuniorSchool,MLS,MLSNumber,OutBuildingsYN,OwnerAgentYN,OwnershipType,ParcelNumber,PendingDate,PermitAddressInternetYN,PermitInternetYN,PermitSyndicationYN,PhotoCount,PhotoModificationTimestamp,PlatBookSlide,PlatReferenceSectionPages,PostalCode,PostalCodePlus4,PropertySubType,PropertyType,ProposedCompletionDate,ProposedSpecialAssessmentDescription,ProposedSpecialAssessmentYN,PublicRemarks,PublicallyMaintainedRoad,Restrictions,RestrictionsDescription,Roof,SellingAgentMLSBoard,SellingAgentMLSID,SellingAgent_MUI,SellingAgentPrimaryBoard,SellingOfficeMLSID,SellingOffice_MUI,Sewer,ShowingPhoneNumber,SpecialListingConditions,SqFtBuildingMinimum,StateOrProvince,Status,StatusContractualSearchDate,Street,StreetDirPrefix,StreetDirSuffix,StreetName,StreetNumber,StreetNumberNumeric,StreetSuffix,SubdivisionName,SuitableUse,SyndicationRemarks,Table,TaxAmountNCM,UnitNumber,VirtualTourURLBranded,VirtualTourURLUnbranded,VOWConsumerCommentYN,VOWAVMYN,Water,WaterBodyName,WaterfrontFeatures,WaterfrontYN,Zoning,ZoningSpecification,ArchitecturalStyle,AuctionYN,BathsFull,BathsHalf,BathsTotal,BedsTotal,BuilderName,ComplexName,ConstructionStatus,DoorsWindows,Driveway,EntryLevel,Equipment,ExteriorConstruction,FireplaceDescription,FireplaceYN,Flooring,Heating,InteriorFeatures,LandIncludedYN,LaundryLocation,ListingFinancing,Model,NewConstructionYN,Parking,PetsAllowed,Porch,SecondLivingQuarters,SecondLivingQuartersHLA,SecondLivingQuartersSqFt,SqFtAdditional,SqFtBasement,SqFtLower,SqFtMain,SqFtThird,SqFtTotal,SqFtUnheatedBasement,SqFtUnheatedLower,SqFtUnheatedMain,SqFtUnheatedThird,SqFtUnheatedTotal,SqFtUnheatedUpper,SqFtUpper,StreetViewParam,UnitFloorLevel,WaterHeater,YearBuilt,AvailableDate,ContactName,DepositPet,Furnished,LeaseTerm,PropertySubTypeSecondary,TenantPays,CeilingHeight,CeilingHeightFT,CeilingHeightIN,CommercialCooling,CommercialHeating,CommercialLocationDescription,CrossStreet,Documents,Easement,FinancingInformation,FloodPlain,GrossOperatingIncome,GrossScheduledIncome,Inclusions,InsideCityYN,Miscellaneous,NumberOfDocksTotal,NumberOfDriveInDoorsTotal,NumberOfRentalsTotal,NumberOfUnitsBuildings,NumberOfUnitsTotal,OperatingExpense,OtherIncome,ParkingTotal,PotentialIncome,RValueCeiling,RValueFloor,RValueWall,RailService,RATIO_CurrentPrice_By_Acre,RoadFrontage,Sprinkler,SqFtAvailableMaximum,SqFtAvailableMinimum,SqFtMaximumLease,SqFtMinimumLease,StoriesTotal,TransactionType,UtilitiesCommercial,VacancyRate,WarehouseSqFt,NumberOfProjectedUnitsTotal,PropertyFeatures,RoomOther,SellerContribution", ",");
	this.arrFieldLookupFields=arraynew(1);
	this.mls_provider="rets29";
	this.sysidfield="rets29_matrix_unique_id";
	resourceStruct=structnew();
	resourceStruct["property"]=structnew();
	resourceStruct["property"].resource="property";
	resourceStruct["property"].id="mlsnumber";
	resourceStruct["office"]=structnew();
	resourceStruct["office"].resource="office";
	resourceStruct["office"].id="mlsid";
	resourceStruct["agent"]=structnew();
	resourceStruct["agent"].resource="agent";
	resourceStruct["agent"].id="mlsid";
	this.emptyStruct=structnew();
	
	
	
	variables.tableLookup=structnew();
   	variables.tableLookup["RNT"]="Rent";  
    variables.tableLookup["SFR"]="Resi";  
    variables.tableLookup["MUL"]="MF";  
    variables.tableLookup["LND"]="Land";  
    variables.tableLookup["COM"]="Comm";  
    variables.tableLookup["CND"]="Resi";  
	//variables.tableLookup["listing"]="1"; 
	variables.t5=structnew();

	this.remapFieldStruct=variables.t5;

	
	</cfscript> 
    

    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript> 
		var values="";
		var newlist=""; 
		var columnIndex=structnew(); 

		startTime=gettickcount('nano');


		if(structcount(this.emptyStruct) EQ 0){
			for(i=1;i LTE arraylen(this.arrColumns);i++){
				if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["Property"].tableFields, this.arrColumns[i])){
					this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["Property"].tableFields[this.arrColumns[i]].longname]="";
				}else{
					application.zcore.template.fail("I must update the arrColumns list");	
				}
			}
		}
		ts=duplicate(this.emptyStruct);
		/*
		
		wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '29-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '29-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '29-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '29-%'; 
		
		
		*/

		if(arraylen(arguments.ss.arrData) NEQ arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.functions.zdump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
			application.zcore.functions.zdump(arguments.ss.arrData);
			application.zcore.functions.zabort();
		}  
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.template.fail("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["Property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
			ts["rets29_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
			if(arguments.ss.arrData[i] EQ '0'){
				arguments.ss.arrData[i]="";	
			}
			if(structkeyexists(ts,col)){
				if(ts[col] NEQ ""){
					ts[col]=ts[col]&","&application.zcore.functions.zescape(arguments.ss.arrData[i]);
				}else{
					ts[col]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
				}
			}else{ 
				ts[col]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			}
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
		}

		for(i in ts){
			if((right(i, 4) EQ "date" or i CONTAINS "timestamp") and isdate(ts[i])){
				d=parsedatetime(ts[i]);
				ts[i]=dateformat(d, "m/d/yyyy")&" "&timeformat(d, "h:mm tt");
			}else if(ts[i] EQ 0 or ts[i] EQ 1){

			}else if(len(ts[i]) lt 14 and isnumeric(ts[i]) and right(ts[i], 3) EQ ".00"){
				ts[i]=numberformat(ts[i]);
			}else{
				ts[i]=replace(ts[i], ",", ", ", "all");
			}
		}
		//writedump(ts); 		abort;
		
		
		ts["List Price"]=replace(ts["List Price"],",","","ALL");
		
		local.listing_subdivision="";
		if(local.listing_subdivision EQ ""){
			if(findnocase(","&ts["Subdivision Name"]&",", ",,false,none,not on the list,not applicable,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Subdivision Name"]="";
			}else if(ts["Subdivision Name"] NEQ ""){
				ts["Subdivision Name"]=application.zcore.functions.zFirstLetterCaps(ts["Subdivision Name"]);
			}
			if(ts["Subdivision Name"] NEQ ""){
				local.listing_subdivision=ts["Subdivision Name"];
			}
		}
		if(ts["Property Type"] EQ "INC" and ts["Monthly"] NEQ "" and ts["Monthly"] NEQ "0"){
			ts["List Price"]=ts["Monthly"];
		}
		this.price=ts["List Price"];
		local.listing_price=ts["List Price"];
		cityName=this.getRetsValue("property", "", "city", ts["city"]);
		// get the actual city name: 
		cid=getNewCityId(ts["city"], cityName, ts["State Or Province"]);
		 

		arrS=listtoarray(ts['Special Listing Conditions'],","); 
		local.listing_county="";
		if(local.listing_county EQ ""){
			local.listing_county=this.listingLookupNewId("County",ts['County Or Parish']);
		}
		//writedump(listing_county); 		abort; 
		local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type", ts['Property Sub Type']);


		local.listing_type_id=this.listingLookupNewId("listing_type",ts['Property Type']);

		

		rs=getListingTypeWithCode(ts["Property Type"]);
		
		if(ts["Permit Address Internet YN"] EQ "N"){
			ts["street ##"]="";
			ts["street name"]="";
			ts["street type"]="";
			ts["Unit ##"]="";
		}
		
		ts["Property Type"]=rs.id;
		ad=ts['Street Number'];
		if(ad NEQ 0){
			address=trim(ts["Street Dir Prefix"]&" #ad# ");
		}else{
			address="";	
		}
		address&=" "&trim(ts['Street Name']&" "&ts['Street Suffix']&" "&ts["Street Dir Suffix"]);
		curLat='';
		curLong='';
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts['State Or Province'],ts['Postal Code'], arguments.ss.listing_id);
			curLat=rs5.latitude;
			curLong=rs5.longitude;
		}
		address=application.zcore.functions.zfirstlettercaps(address);
		
		if(ts['Unit Number'] NEQ ''){
			address&=" Unit: "&ts["Unit Number"];	
		} 
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=ts['Year Built'];
		ts2.foreclosureField="";
		
		s=this.processRawStatus(ts2);
		arrS=listtoarray(ts['Special Listing Conditions'],",");
		for(i=1;i LTE arraylen(arrS);i++){
			c=trim(arrS[i]);
			if(c EQ "ShortSale"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
				break;
			} 
			if(c EQ "FCPC"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
			}
		}
		if(ts['New Construction YN'] EQ "Y"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["New Construction"]]=true;
		}
		if(ts.rets29_propertytype EQ "RNT"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else{
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		arrT3=[];
		local.listing_status=structkeylist(s,",");

		uns=structnew();
		tmp=ts['Architectural Style'];
		//writedump(tmp);
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){ 
				tmp=this.listingLookupNewId("style",arrT[i]); 
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
		}
		local.listing_style=arraytolist(arrT3);
		//writedump(listing_style); 	abort;


		arrT2=[]; 
		tmp=ts['Parking'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("parking",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
		local.listing_parking=arraytolist(arrT2, ",");
		
		if(structkeyexists(ts,'Listing Contract Date')){
			arguments.ss.listing_track_datetime=dateformat(ts["Listing Contract Date"],"yyyy-mm-dd")&" "&timeformat(ts["Listing Contract Date"], "HH:mm:ss");
		}
		arguments.ss.listing_track_updated_datetime=dateformat(ts["Matrix Modified DT"],"yyyy-mm-dd")&" "&timeformat(ts["Matrix Modified DT"], "HH:mm:ss");
		//arguments.ss.listing_track_price=ts["Original List Price"];
		//if(arguments.ss.listing_track_price EQ "" or arguments.ss.listing_track_price EQ "0" or arguments.ss.listing_track_price LT 100){
			arguments.ss.listing_track_price=ts["List Price"];
		//}
		arguments.ss.listing_track_price_change=ts["List Price"];
		liststatus=ts["Status"];
		s2=structnew();
		//if(liststatus EQ "ACT"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Active"]]=true;
		//}
		/*if(liststatus EQ "AWC"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Active"]]=true;
		}
		if(liststatus EQ "WDN"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Withdrawn"]]=true;
		}
		if(liststatus EQ "TOM"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Temporarily Off Market"]]=true;
		}
		if(liststatus EQ "PNC"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Coming Soon-No Show"]]=true;
		}
		if(liststatus EQ "EXP"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Expired"]]=true;
		}
		if(liststatus EQ "SLD"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Closed"]]=true;
		}
		if(liststatus EQ "LSE"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Leased"]]=true;
		}*/

		//if(liststatus EQ "LSO"){
		//CANT FIND LEASE OPTION	s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["lease option"]]=true;
		//}
		//if(liststatus EQ "RNT"){
		//CANT FIND RENTED	s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Leased"]]=true;
		//}
		local.listing_liststatus=structkeylist(s2,",");
		if(local.listing_liststatus EQ ""){
			local.listing_liststatus=1;
		}
		
		// view & frontage
		arrT3=[];
		
		uns=structnew();
		tmp=ts['Lot Features'];		
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("frontage",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
		} 
		local.listing_frontage=arraytolist(arrT3);
		
		local.listing_view="";
		/* 
		arrT2=[];
		uns=structnew();
  
		local.listing_view=arraytolist(arrT2);
		*/

		local.listing_pool=0; 
		extFeatures={
			"INPOOL":true,
			"AGPOOL":true
		}; 
		tmp=ts['Exterior Features']; 
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				if(structkeyexists(extFeatures, arrT[i])){
					local.listing_pool=1;	
					break;
				} 
			}
		} 
 
		tempTime=gettickcount('nano');
		application.idxImportTimerStruct.parseRow1+=(tempTime-startTime);
		startTime=tempTime; 
   		ts=this.convertRawDataToLookupValues(ts, variables.tableLookup[ts.rets29_propertytype], ts.rets29_propertytype); 
		
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		// LotDimension LotSizeArea 
		rs.listing_acreage=ts["Acres Wooded"];
		rs.listing_baths=ts["Baths Full"];
		rs.listing_halfbaths=ts["Baths Half"];
		rs.listing_beds=ts["Beds Total"];
		rs.listing_city=cid;
		rs.listing_county=local.listing_county;
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=ts["list price"];
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=ts["State Or Province"];
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet="";
		if(structkeyexists(ts, "Acres Wooded") and isnumeric(ts["Acres Wooded"])){
			rs.listing_lot_square_feet=round(ts["Acres Wooded"]/0.000022956841138659);
		}else if(structkeyexists(ts, "Lot Size Area In Acres") and isnumeric(ts["Lot Size Area In Acres"])){
			rs.listing_lot_square_feet=round(ts["Lot Size Area In Acres"]/0.000022956841138659);
		}
		rs.listing_square_feet=ts["Sq Ft Total"];
		rs.listing_subdivision=local.listing_subdivision;
		rs.listing_year_built=ts["year built"];
		rs.listing_office=ts["List Office MLSID"];
		rs.listing_office_name=ts["rets29_listofficename"];
		rs.listing_agent=ts["List Agent MLSID"];
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=ts["Photo Count"];
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="0";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_address=trim(address);
		rs.listing_zip=ts["Postal Code"];
		rs.listing_condition="";
		rs.listing_parking=local.listing_parking;
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus=local.listing_liststatus;
		rs.listing_data_remarks=ts["public remarks"];
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts["Postal Code"]);
		rs.listing_data_detailcache1=listing_data_detailcache1;
		rs.listing_data_detailcache2=listing_data_detailcache2;
		rs.listing_data_detailcache3=listing_data_detailcache3; 

		rs.listing_track_sysid=ts["rets29_matrix_unique_id"];
		//writedump(rs);		writedump(ts);abort;

		tempTime=gettickcount('nano');
		application.idxImportTimerStruct.parseRow2+=(tempTime-startTime);
		startTime=tempTime;

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
		var idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails);
		t99=gettickcount();
		idx["features"]="";
		t44444=0;
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		request.lastPhotoId=""; 
		if(arguments.ss.listing_photocount EQ 0){
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
		}else{
			i=1;
			
			for(i=1;i LTE arguments.ss.listing_photocount;i++){
				
				local.fNameTemp1=idx.listing_id&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				local.absPath='#request.zos.sharedPath#mls-images/29/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				//if(fileexists(local.absPath)){
					if(i EQ 1){
						request.lastPhotoId=idx.rets29_matrix_unique_id;
					}
					idx["photo"&i]=request.zos.retsPhotoPath&'29/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				/*}else{
					idx["photo"&i]='/z/a/listing/images/image-not-available.gif';
					if(i EQ 1){
						request.lastPhotoId="";
					}
				}*/
			}
		}
		idx["agentName"]=arguments.ss["rets29_listagentfullname"];
		idx["agentPhone"]=arguments.ss["RETS29_LISTAGENTDIRECTWORKPHONE"];
		//idx["agentEmail"]=arguments.ss["rets29_listagentemail"];
		idx["officeName"]=arguments.ss["rets29_listofficename"];
		idx["officePhone"]=arguments.ss["RETS29_LISTOFFICEPHONE"];
		idx["officeCity"]="";
		idx["officeAddress"]="";
		idx["officeZip"]="";
		idx["officeState"]="";
		idx["officeEmail"]="";
			
		idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets29_virtualtoururlunbranded");
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_postalcode");
		if(application.zcore.functions.zso(arguments.ss, "rets29_associationfee") NEQ ""){
			idx["maintfees"]=arguments.ss["rets29_associationfee"]; 
			
		}else{
			idx["maintfees"]=0;
		}
		
		
		</cfscript>
        <cfsavecontent variable="details">
        <table class="ztablepropertyinfo">
        #idx.listing_data_detailcache1#
        #idx.listing_data_detailcache2#
        #idx.listing_data_detailcache3#
        </table>
        </cfsavecontent>
        <cfscript>
		idx.details=details;
		
		return idx;
		</cfscript>
    </cffunction>
    
    
    <cffunction name="getPhoto" localmode="modern" output="no" returntype="any">
    	<cfargument name="mls_pid" type="string" required="yes">
        <cfargument name="num" type="numeric" required="no" default="#1#">
        <cfargument name="sysid" type="string" required="no" default="0">
    	<cfscript>
		var qId=0;
		var db=request.zos.queryObject;
		var local=structnew();
		// rets29_matrix_unique_id  
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=this.mls_id&"-"&arguments.mls_pid&"-"&arguments.num&".jpeg"; 
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		local.absPath='#request.zos.sharedPath#mls-images/29/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		if(fileexists(local.absPath)){
			return request.zos.retsPhotoPath&'29/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		}else{
			request.lastPhotoId="";
			return "";
		}
		</cfscript>
    </cffunction>
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript> 
		var arrSQL=[]; 
		var arrError=[]; 
		// 19=county
		fd=this.getRETSValues("property", "","CountyOrParish");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','county','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		fd=this.getRETSValues("property", "","parking");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}

		// property style
		fd=this.getRETSValues("property", "","ArchitecturalStyle");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		 
		fd=this.getRETSValues("property", "","PropertySubType");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		// property style lookups
		fd=this.getRETSValues("property", "","propertytype");
		for(i in fd){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		} 
		
		
		fd=this.getRETSValues("property", "","lotfeatures");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		} 
		/*
		// view 
		
		fd=this.getRETSValues("property", "","location");
		for(i in fd){
			if(fd[i] contains 'view'){
				arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}*/  


		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>