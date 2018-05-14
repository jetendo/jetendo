<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
	<cfscript>
	this.retsVersion="1.7";
	
	this.mls_id=25;
	if(request.zos.istestserver){
		hqPhotoPath="#request.zos.sharedPath#mls-images/25/";
	}else{
		hqPhotoPath="#request.zos.sharedPath#mls-images/25/";
	}
	this.useRetsFieldName="system";


	this.arrColumns=listtoarray("AccessibilityFeatures,AdditionalApplicantFee,AdditionalLeaseRestrictions,AdditionalMembershipAvailableYN,AdditionalParcelsDescription,AdditionalParcelsYN,AdditionalPetFees,AdditionalRooms,AdditionalWaterInformation,AdjoiningProperty,AlternateKeyFolioNum,AmenitiesAdditionalFees,AnnualExpenses,AnnualIncomeType,AnnualNetIncome,AnnualRent,Appliances,ApplicationFee,ApprovalProcess,ArchitecturalStyle,AssociationAmenities,AssociationApplicationFee,AssociationApprovalFee,AssociationApprovalRequiredYN,AssociationFee,AssociationFeeFrequency,AssociationFeeIncludes,AssociationFeeRequirement,AttachedGarageYN,AuctionFirmURL,AuctionPropAccessYN,AuctionType,AvailabilityDate,AvailableForLeaseYN,BathroomsFull,BathroomsHalf,BathroomsTotalInteger,BedroomsTotal,BodyType,BuilderModel,BuilderName,BuildingAreaSource,BuildingAreaTotal,BuildingElevatorYN,BuildingNameNumber,BusinessType,BuyerAgencyCompensation,BuyerAgentAOR,BuyerAgentFullName,BuyerAgentMlsId,BuyerOfficeMlsId,BuyerOfficeName,BuyersPremium,CarportSpaces,CarportYN,CDDYN,CeilingHeight,CeilingType,City,ClassofSpace,CloseDate,ClosePrice,CoBuyerAgentFullName,CoBuyerAgentMlsId,CoBuyerOfficeMlsId,CoBuyerOfficeName,CoListAgentDirectPhone,CoListAgentFullName,CoListAgentMlsId,CoListOfficeMlsId,CoListOfficeName,ComTransactionTerms,ComTransactionType,CommunityFeatures,ComplexCommunityNameNCCB,ComplexDevelopmentName,ConditionExpDate,CondoEnvironmentYN,CondoFees,CondoFeesTerm,CondoLandIncludedYN,ConstructionMaterials,ContractStatus,ConvertedResidenceYN,Cooling,Country,CountyLandUseCode,CountyOrParish,CountyPropertyUseCode,CumulativeDaysOnMarket,CurrencyMonthlyRentAmt,CurrentAdjacentUse,CurrentPrice,CurrentUse,DaysNoticeToTenantIfNotRenew,DaysOnMarket,DaysToClosed,DirectionFaces,Directions,DisasterMitigation,Disclosures,DoorHeight,DoorWidth,DPRURL,DPRURL2,DPRYN,Easements,Electric,ElementarySchool,EndDateofLease,EstAnnualMarketIncome,ExistLseTenantYN,ExpectedClosingDate,ExteriorFeatures,FannieMaeDTC,Fencing,FinancialDataSource,FinancingTerms,FireplaceFeatures,FireplaceYN,FlexSpaceSqFt,FloodZoneCode,FloodZoneDate,FloodZonePanel,FloorNumber,Flooring,ForLeaseYN,FoundationDetails,FreezerSpaceYN,FrontFootage,Furnished,FutureLandUse,GarageDimensions,GarageDoorHeight,GarageSpaces,GarageYN,GreenBuildingVerificationType,GreenEnergyEfficient,GreenEnergyGeneration,GreenIndoorAirQuality,GreenLandscaping,GreenWaterConservation,GrossIncome,GrossScheduledIncome,Heating,HERSIndex,HighSchool,HomesteadYN,InteriorFeatures,InternetAddressDisplayYN,InternetConsumerCommentYN,InternetEntireListingDisplayYN,LandLeaseAmount,LastDateAvailable,LastMonthsRent,Latitude,LaundryFeatures,LeasableArea,LeaseAmountFrequency,LeaseFee,LeasePrice,LeasePricePerAcre,LeaseTerm,Levels,ListAgentAOR,ListAgentDirectPhone,ListAgentEmail,ListAgentFax,ListAgentFullName,ListAgentKeyNumeric,ListAgentMlsId,ListAgentOfficePhoneExt,ListAgentPager,ListAgentURL,ListAOR,ListOfficeFax,ListOfficeHeadOfficeKeyNumeric,ListOfficeKeyNumeric,ListOfficeMlsId,ListOfficeName,ListOfficePhone,ListOfficeURL,ListPrice,ListTeamName,ListingAgreement,ListingContractDate,ListingId,ListingKeyNumeric,ListingTerms,LivingArea,LongTermYN,Longitude,LotFeatures,LotSizeAcres,LotSizeDimensions,LotSizeSquareFeet,Management,MasterBedSize,MaxPetWeight,MiddleOrJuniorSchool,MillageRate,MinimumLease,Miscellaneous,Miscellaneous2,MLSAreaMajor,MlsStatus,Model,ModificationTimestamp,MonthToMonthOrWeeklyYN,MonthlyCondoFeeAmount,MonthlyHOAAmount,MonthsAvailable,MontlyMaintAmtAdditionToHOA,NetOperatingIncome,NewConstructionYN,NonRepCompensation,NumOfOwnYearsPriorToLse,NumTimesperYear,NumberOfLots,NumberOfPets,NumberOfUnitsTotal,NumofBays,NumofBaysDockHigh,NumofBaysGradeLevel,NumofConferenceMeetingRooms,NumofHotelMotelRms,NumofOffices,NumofRestrooms,OffMarketDate,OffSeasonRent,OfficeRetailSpaceSqFt,OriginalEntryTimestamp,OriginalListPrice,OriginatingSystemTimestamp,OtherEquipment,OtherExemptionsYN,OtherFeesAmount,OtherFeesDescription,OtherFeesTerm,OtherStructures,OwnerPays,ParcelNumber,ParkingFeatures,PatioAndPorchFeatures,PetDepositFee,PetFeeNonRefundable,PetRestrictions,PetSize,PetsAllowed,PhotosChangeTimestamp,PhotosCount,PlannedUnitDevelopmentYN,PoolFeatures,PoolPrivateYN,PostalCode,PostalCodePlus4,PriceChangeTimestamp,PricePerAcre,PrivateRemarks,ProjectedCompletionDate,PropertyCondition,PropertyDescription,PropertySubType,PropertyType,PublicRemarks,PublicSurveyRange,PublicSurveySection,RealtorInfo,RentConcession,RoadFrontageFt,RoadFrontageType,Roof,RoomCount,SeasonalRent,SecurityDeposit,SecurityFeatures,SeniorCommunityYN,Sewer,ShowingRequirements,SoldRemarks,SpaFeatures,SpaYN,SpaceType,SpecialListingConditions,StateLandUseCode,StateOrProvince,StatePropertyUseCode,StatusChangeTimestamp,StoriesTotal,StreetDirPrefix,StreetDirSuffix,StreetName,StreetNumber,StreetSuffix,SubdivisionName,SubdivisionNum,SubdivisionSectionNumber,SWSubdivCommunityName,SWSubdivCondoNum,TaxAnnualAmount,TaxBlock,TaxBookNumber,TaxLegalDescription,TaxLot,TaxOtherAnnualAssessmentAmount,TaxYear,TempOffMarketDate,TenantPays,TotalAcreage,TotalActualRent,TotalMonthlyExpenses,TotalNumBuildings,Township,TransactionBrokerCompensation,TransportationAccess,UnitCount,UnitNumber,UnparsedAddress,UseCode,Utilities,Vegetation,View,VirtualTourURLBranded,VirtualTourURLBranded2,VirtualTourURLUnbranded,VirtualTourURLUnbranded2,WarehouseSpaceHeated,WarehouseSpaceTotal,WaterAccess,WaterAccessYN,WaterBodyName,WaterExtras,WaterExtrasYN,WaterFrontageFeetBayHarbor,WaterFrontageFeetBayou,WaterFrontageFeetBeachPrvt,WaterFrontageFeetBeachPub,WaterFrontageFeetBrackishWater,WaterFrontageFeetCanalBrackish,WaterFrontageFeetCanalFresh,WaterFrontageFeetCanalSalt,WaterFrontageFeetCreek,WaterFrontageFeetFCWLSC,WaterFrontageFeetGulfOcean,WaterFrontageFeetICW,WaterFrontageFeetLagoon,WaterFrontageFeetLake,WaterFrontageFeetLakeChain,WaterFrontageFeetMarina,WaterFrontageFeetOcean2Bay,WaterFrontageFeetPond,WaterFrontageFeetRiver,WaterSource,WaterView,WaterViewYN,WaterfrontFeatures,WaterfrontFeetTotal,WaterfrontYN,WeeklyRent,WeeksAvailable,WindowFeatures,YearBuilt,YrsOfOwnerPriorToLeasingReqYN,Zoning,ZoningCompatibleYN", ",");
	this.arrFieldLookupFields=arraynew(1);
	this.mls_provider="rets25";
	this.sysidfield="rets25_listingkeynumeric";
	resourceStruct=structnew();
	resourceStruct["property"]=structnew();
	resourceStruct["property"].resource="property";
	resourceStruct["property"].id="listingid";
	resourceStruct["office"]=structnew();
	resourceStruct["office"].resource="office";
	resourceStruct["office"].id="OfficeMlsId";
	resourceStruct["agent"]=structnew();
	resourceStruct["agent"].resource="member";
	resourceStruct["agent"].id="membermlsid";
	this.emptyStruct=structnew();
	
	
	
	variables.tableLookup=structnew();

	variables.tableLookup["listing"]="1";
	/*
	variables.tableLookup["RES"]="1";
	variables.tableLookup["INC"]="1";
	variables.tableLookup["COM"]="1";
	variables.tableLookup["REN"]="1";
	variables.tableLookup["VAC"]="1";
	*/
	variables.t5=structnew();

	this.remapFieldStruct=variables.t5;

	
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
		var ts=0;
		var col=0;
		var rs=0;
		var s2=0;
		var sub=0;
		var arrS=0; 
		var c=0;
		var liststatus=0;
		var ad=0;

		startTime=gettickcount('nano');


		if(structcount(this.emptyStruct) EQ 0){
			for(i=1;i LTE arraylen(this.arrColumns);i++){
				if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields, this.arrColumns[i])){
					this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
				}else{
					application.zcore.template.fail("I must update the arrColumns list");	
				}
			}
		}
		ts=duplicate(this.emptyStruct);
		/*
		
		wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '25-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '25-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '25-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '25-%'; 
		
		
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
			col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
			ts["rets25_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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

			}else if(isnumeric(ts[i]) and right(ts[i], 3) EQ ".00"){
				ts[i]=numberformat(ts[i]);
			}else{
				ts[i]=replace(ts[i], ",", ", ", "all");
			}
		}
		
		
		ts["list price"]=replace(ts["list price"],",","","ALL");
		if(ts["list price"] EQ "" or ts["list price"] EQ "0"){
			ts["list price"]=replace(ts["current price"],",","","ALL");
		}
		
		local.listing_subdivision="";
		if(local.listing_subdivision EQ ""){
			if(findnocase(","&ts["SW Subdiv Community Name"]&",", ",,false,none,not on the list,not applicable,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["SW Subdiv Community Name"]="";
			}else if(ts["SW Subdiv Community Name"] NEQ ""){
				ts["SW Subdiv Community Name"]=application.zcore.functions.zFirstLetterCaps(ts["SW Subdiv Community Name"]);
			}
			if(ts["SW Subdiv Community Name"] NEQ ""){
				local.listing_subdivision=ts["SW Subdiv Community Name"];
			}
		}
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
		if(local.listing_subdivision EQ ""){
			if(findnocase(","&ts["Complex Community Name NCCB"]&",", ",,false,none,not on the list,not applicable,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Complex Community Name NCCB"]="";
			}else if(ts["Complex Community Name NCCB"] NEQ ""){
				ts["Complex Community Name NCCB"]=application.zcore.functions.zFirstLetterCaps(ts["Complex Community Name NCCB"]);
			}
			if(ts["Complex Community Name NCCB"] NEQ ""){
				local.listing_subdivision=ts["Complex Community Name NCCB"];
			}
		}
 

		/*if(ts["Property Type"] EQ "RINC" and ts["Total Monthly Rent"] NEQ "" and ts["Total Monthly Rent"] NEQ "0"){
			ts["list price"]=ts["Total Monthly Rent"];
		}*/
		
		this.price=ts["list price"];
		local.listing_price=ts["list price"];
		cityName="";
		cid=0;
		if(structkeyexists(request.zos.listing.cityStruct, ts["city"]&"|"&ts["State Or Province"])){
			cid=request.zos.listing.cityStruct[ts["city"]&"|"&ts["State Or Province"]];
		}
		local.listing_county="";
		if(local.listing_county EQ ""){
			local.listing_county=this.listingLookupNewId("county",ts['County Or Parish']);
		}
		
	
		local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type",ts['Current Use']);
		moreTypes=this.listingLookupNewId("listing_sub_type",ts['Property Sub Type']);
		if(local.listing_sub_type_id NEQ "" and moreTypes NEQ ""){
			local.listing_sub_type_id&=","&moreTypes;
		}else{
			local.listing_sub_type_id=moreTypes;
		}  
		local.listing_type_id=this.listingLookupNewId("listing_type",ts['property type']);
		

		rs=getListingTypeWithCode(ts["property type"]);
		
		if(ts["Internet Address Display YN"] EQ "N" or ts["Internet Address Display YN"] EQ "0"){
			ts["street ##"]="";
			ts["street name"]="";
			ts["street type"]="";
			ts["Unit ##"]="";
		}
		
		ts["property type"]=rs.id;
		ad=ts['street number'];
		if(ad NEQ 0){
			address=trim(ts["Street Dir Prefix"]&" #ad# ");
		}else{
			address="";	
		}
		address&=" "&trim(ts['street name']&" "&ts['street suffix']&" "&ts["street dir suffix"]);
		curLat='';
		curLong='';
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts['State Or Province'],ts['postal code'], arguments.ss.listing_id);
			curLat=rs5.latitude;
			curLong=rs5.longitude;
		}
		address=application.zcore.functions.zfirstlettercaps(address);
		
		if(ts['Unit Number'] NEQ ''){
			address&=" Unit: "&ts["Unit Number"];	
		}
		
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=ts['year built'];
		ts2.foreclosureField="";
		
		s=this.processRawStatus(ts2);
		arrS=listtoarray(ts['Special Listing Conditions'],",");
		for(i=1;i LTE arraylen(arrS);i++){
			c=trim(arrS[i]);
			if(c EQ "SHORT"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
				break;
			}
			// Special Sale Provision
			if(c EQ "REAL"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
				break;
			}
		}
		if(ts['Realtor Info'] CONTAINS "FORECL"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		} 
		if(ts['New Construction YN'] EQ "Y" or ts['New Construction YN'] EQ "1"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
		}
		if(ts.rets25_propertytype EQ "RLSE"){
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
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				if(arrT[i] EQ "Traditional"){
					tmp=233;
				}else if(arrT[i] EQ "Spanish"){
					tmp=231;
				}else if(arrT[i] EQ "Colonial"){
					tmp=212;
				}else if(arrT[i] EQ "Contemporary"){
					tmp=213;
				}else if(arrT[i] EQ "Ranch"){
					tmp=229;
				}else{
					tmp=this.listingLookupNewId("style",arrT[i]);
				}
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
		}
		local.listing_style=arraytolist(arrT3);
		


		arrT2=[]; 
		tmp=ts['parking features'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("parkingfeatures",arrT[i]);
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
		arguments.ss.listing_track_updated_datetime=dateformat(ts["Modification Timestamp"],"yyyy-mm-dd")&" "&timeformat(ts["Modification Timestamp"], "HH:mm:ss");
		arguments.ss.listing_track_price=ts["Original List Price"];
		if(arguments.ss.listing_track_price EQ "" or arguments.ss.listing_track_price EQ "0" or arguments.ss.listing_track_price LT 100){
			arguments.ss.listing_track_price=ts["List Price"];
		}
		arguments.ss.listing_track_price_change=ts["List Price"];
		liststatus=ts["Mls Status"];
		
		s2=structnew();
		if(liststatus EQ "ACT"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
		}
		/*if(liststatus EQ "AWC"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active continue to show"]]=true;
		}*/
		if(liststatus EQ "WTH"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["withdrawn"]]=true;
		}
		if(liststatus EQ "TOM"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["temporarily withdrawn"]]=true;
		}
		if(liststatus EQ "PND"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["pending"]]=true;
		}
		if(liststatus EQ "EXP"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["expired"]]=true;
		}
		if(liststatus EQ "SLD"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["sold"]]=true;
		}
		if(liststatus EQ "LSE"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["leased"]]=true;
		}
		/*
		if(liststatus EQ "LSO"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["lease option"]]=true;
		}*/
		/*
		if(liststatus EQ "RNT"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["rented"]]=true;
		}*/
		local.listing_liststatus=structkeylist(s2,",");
		if(local.listing_liststatus EQ ""){
			local.listing_liststatus=1;
		}
		
		// view & frontage
		arrT3=[];
		
		uns=structnew(); 
		tmp=ts['Waterfront Features'];
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
		if(ts["lot features"] CONTAINS "OnGolfCourse"){
			tmp=this.listingLookupNewId("frontage", "OnGolfCourse");
			arrayappend(arrT3, tmp);
		}
		local.listing_frontage=arraytolist(arrT3);
		
		
		arrT2=[];
		uns=structnew();
		tmp=ts['view'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("view",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
		tmp=ts['water view'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("view",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
		if(ts["Water View YN"] EQ "Y" or ts["Water View YN"] EQ "1"){
			arrayappend(arrT2,243);
		} 
		local.listing_view=arraytolist(arrT2);
		

		local.listing_pool=0;
		if(ts["Pool Private YN"] EQ "Y" or ts["Pool Private YN"] EQ "1"){
			local.listing_pool=1;	
		}


		tempTime=gettickcount('nano');
		application.idxImportTimerStruct.parseRow1+=(tempTime-startTime);
		startTime=tempTime;

		ts=this.convertRawDataToLookupValues(ts, 'property', ts.rets25_propertytype);
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage=ts["Lot Size Acres"];
		rs.listing_baths=ts["Bathrooms Full"];
		rs.listing_halfbaths=ts["Bathrooms Half"];
		rs.listing_beds=ts["Bedrooms Total"];
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
		rs.listing_lot_square_feet=trim(replace(ts["Lot Size Square Feet"], ",", "", "all"));
		rs.listing_square_feet=trim(replace(ts["Building Area Total"], ",", "", "all"));
		rs.listing_subdivision=local.listing_subdivision;
		rs.listing_year_built=ts["year built"];
		rs.listing_office=ts["List Office MLS ID"]; 
		rs.listing_agent=ts["List Agent MLS ID"];
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=ts["Photos Count"];
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
		//writedump(rs);		writedump(ts);abort;

		rs.listing_track_sysid=ts["rets25_listingkeynumeric"];

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
				
				local.fNameTemp1=arguments.ss.listing_id&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				local.absPath='#request.zos.sharedPath#mls-images/25/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				//if(fileexists(local.absPath)){
					if(i EQ 1){
						request.lastPhotoId=arguments.ss.listing_id;
					}
					idx["photo"&i]=request.zos.retsPhotoPath&'25/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				/*}else{
					idx["photo"&i]='/z/a/listing/images/image-not-available.gif';
					if(i EQ 1){
						request.lastPhotoId="";
					}
				}*/
			}
		}
			idx["agentName"]=arguments.ss["rets25_listagentfullname"];
			idx["agentPhone"]=arguments.ss["rets25_ListAgentDirectPhone"];
			idx["agentEmail"]=arguments.ss["rets25_listagentemail"];
			idx["officeName"]=arguments.ss["rets25_listofficename"];
			idx["officePhone"]=arguments.ss["RETS25_LISTOFFICEPHONE"];
			idx["officeCity"]="";
			idx["officeAddress"]="";
			idx["officeZip"]="";
			idx["officeState"]="";
			idx["officeEmail"]="";
			
		idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets25_virtualtoururlunbranded");
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_postalcode");
		if(application.zcore.functions.zso(arguments.ss, "rets25_totalmonthlyexpenses") NEQ ""){
			idx["maintfees"]=arguments.ss["rets25_totalmonthlyexpenses"];
		}else if(application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_MonthlyHOAAmount") NEQ ""){
			idx["maintfees"]=arguments.ss["rets#this.mls_id#_MonthlyHOAAmount"];
		}else if(application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_CondoFees") NEQ ""){
			idx["maintfees"]=arguments.ss["rets#this.mls_id#_CondoFees"];
			
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
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=this.mls_id&"-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		local.absPath='#request.zos.sharedPath#mls-images/25/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		if(fileexists(local.absPath)){
			return request.zos.retsPhotoPath&'25/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		}else{
			request.lastPhotoId="";
			return "";
		}
		</cfscript>
    </cffunction>
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var fd=0;
		var arrError=[];
		var i2=0;
		var tmp=0;

		// 19=county
		fd=this.getRETSValues("property", "","countyorparish");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','county','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		fd=this.getRETSValues("property", "","parkingfeatures");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}

		// Current Use
		fd=this.getRETSValues("property", "","propertysubtype");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", "","currentuse");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}  
		
		// 86=property use
		fd=this.getRETSValues("property", "","currentuse");
		for(i in fd){
			if(i EQ "MULTIFAMILY"){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		// 1=property type
		fd=this.getRETSValues("property", "","propertytype");
		//fd["M"]="Multi-Family";
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		fd=this.getRETSValues("property", "","waterfrontfeatures");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		} 
		fd=this.getRETSValues("property", "","lotfeatures");
		for(i in fd){
			if(fd[i] EQ "OnGolfCourse"){
				arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		arrayappend(arrSQL,"('#this.mls_provider#','frontage','Waterfront','266','#request.zos.mysqlnow#','266','#request.zos.mysqlnow#', '0')");
		
		
		// view
		fd=this.getRETSValues("property", "","waterview");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		fd=this.getRETSValues("property", "","view");
		for(i in fd){ 
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		}
		// Water View Y/N
		arrayappend(arrSQL,"('#this.mls_provider#','view','Waterview','243','#request.zos.mysqlnow#','243','#request.zos.mysqlnow#', '0')");
		
		
		fd=this.getRETSValues("property", "","architecturalstyle");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		

		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>