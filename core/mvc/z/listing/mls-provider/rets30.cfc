<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
	<cfscript>
	this.retsVersion="1.7";
	
	this.mls_id=30;
	if(request.zos.istestserver){
		hqPhotoPath="#request.zos.sharedPath#mls-images/30/";
	}else{
		hqPhotoPath="#request.zos.sharedPath#mls-images/30/";
	}
	this.useRetsFieldName="system";


	this.arrColumns=listtoarray("ACPercentage,AccountingandLegalExpens,AcreageDescription,ActiveOpenHouseCount,ADACompliant,AdditionalBusinessNames,AdditionalFurnishedInfo,AddlMoveInCostYN,AddressInternetDisplay,AddressonInternet,AdjustedAreaSF,AdvertisingExpenses,AgentAlternatePhone,AgentLicenseNum,AgentsOfficeExtension,Amenities,AnnualBaseRate,ApplicationFee,ApprovalInformation,ApproxSqftTotalArea,ApproximateLotSize,Area,AssocFeePaidPer,AssociationFee,AssumableChattelBalance,AssumableYN,AuctionType,AuctionYN,AvailableDate,AvailableDocuments,AVM,BalconyPorchandorPatioYN,BathsFull,BathsHalf,BathsTotal,BedroomDescription,BedsTotal,Blogging,BoardIdentifier,BoatDockAccommodates,BoatServices,BonusAmount,BonusYN,BrandName,BrokerRemarks,BuildingAreaAltSource,BuildingAreaAlternative,BuildingIncludes,BuildingNameNumber,BuildingNumber,BuildingSqFt,CableAvailableYN,CancelledDate,CarportDescription,CeilingDescription,CeilingHeight,City,CloseDate,ClosePrice,CoAgentLicenseNum,CoListAgentDirectWorkPhone,CoListAgentEmail,CoListAgentFullName,CoListAgentMLSID,CoListAgent_MUI,CoListOfficeMLSID,CoListOffice_MUI,CoListOfficeName,CoListOfficePhone,CoSellAgentLicenseNum,CoSellingAgentDirectWorkPhone,CoSellingAgentEmail,CoSellingAgentFullName,CoSellingAgentMLSID,CoSellingAgent_MUI,CoSellingOfficeMLSID,CoSellingOffice_MUI,CoSellingOfficeName,CoSellingOfficePhone,ColumnDescription,CommonAreaMaintAmount,CommonAreaMaintIncludes,ComplexName,ComprehensivePlanUse,ComptoBuyersAgent,ComptoNonRepresentative,ComptoTransactionBroker,ConditionalDate,ConstructionType,ConvertibleBedroomYN,CoolingDescription,CostofSales,CountyLandCode,CountyOrParish,CurrentPrice,DadeAssessedAmtSOHValue,DadeMarketAmtAssessedAmt,DaysOpen,DecalNumber,DeedRestrictions,DenDimensions,DepositInformation,Design,DesignDescription,Development,DevelopmentName,DiningAreaDimensions,DiningDescription,DiningRoomDimensions,Directions,DockHeight,DockInformation,DockNumber,DOM,DoorHeight,EaveHeight,EfficiencyYN,ElectricService,ElementarySchool,ElevationAboveSeaLevel,EnvironmentalAudit,EquestrianFeatures,EquipmentAppliances,ExcludeFromInventoryStats,ExpInclAcctgLegalYN,ExpInclAdvLicPermitYN,ExpInclElectricYN,ExpInclExterminationYN,ExpInclGasOilYN,ExpInclInsuranceYN,ExpInclJanitorYN,ExpInclLawnMaintenanceYN,ExpInclMaintandRepairYN,ExpInclManagementYN,ExpInclMiscellaneousYN,ExpInclPoolServiceYN,ExpInclPropertyTaxYN,ExpInclReplaceReserveYN,ExpInclRetaxYN,ExpInclSuppliesYN,ExpInclTrashYN,ExpInclWaterSewerYN,ExpenseAmount,ExpensesIncluded,ExpirationDate,ExteriorFeatures,FeeDescription,FillDescription,FillFromRecord_MUI,FillFromRecord_TableID,FireProtection,FixtureValue,FloodZone,FloorDescription,FolioNum2ndParcel,ForLeaseMLSNumber,ForLeaseYN,ForSaleMLSNumber,ForSaleYN,FrontExposure,FurnAnnualRent,FurnOffSeasonRent,FurnSeasonalRent,FurnishedInfoList,FurnishedInfoSold,GarageDescription,GasDescription,GeographicArea,GreenEnergyEfficient,GrossOperatingIncome,GrossRent,GrossRentIncome,GrossSales,GrossScheduledIncome,GroundCover,GroundCoverDescription,GuestHouseDescription,HardshipPackage,HeatingDescription,HousingOlderPersonsAct,IDXOptInYN,ImprovementHeightBUS,ImprovementHeightCOM,IncExpStatementPeriod,InformationAvailable,InputBrokerRemarks,InsuranceExpense,IntendedUse,InteriorCeilingHeight,InteriorFeatures,InternetRemarks,InternetYN,InventoryValue,IsDeleted,Jurisdiction,LandImprovements,LandLeaseAmount,LandLeaseFeePaidPer,LastChangeTimestamp,LastChangeType,LastStatus,LeasePrice,LeaseTermInfo,LeaseTermRemaining,LegalDescription,LenderApproval,Licenses,ListAgentDirectWorkPhone,ListAgentEmail,ListAgentFullName,ListAgentMLSID,ListAgent_MUI,ListOfficeMLSID,ListOffice_MUI,ListOfficeName,ListOfficePhone,ListPrice,ListingContractDate,ListingType,Location,LocationofProperty,LotDepth,LotDescription,LotFrontage,LotSqFootage,LotorTrackNum,LPAmtSqFt,MainLivingArea,MaintFeePaidPer,MaintandRepairsExpense,MaintenanceChargeMonth,MaintenanceFeeIncludes,MaintenanceIncludes,ManagementCompany,ManagementCompanyPhone,ManagementExpense,ManufacturedHomeMiscell,ManufacturedHomeSize,MasterBathroomDescription,MatrixModifiedDT,Matrix_Unique_ID,MaximumCeilingHeight,MaximumLeasableSqft,MemberFeePaidPer,MembershipPurchRqdYN,MembershipPurchaseFee,MiddleSchool,MilestoBeach,MilestoExpressway,MinSFLivingAreaReqmt,MinimumLeasePeriod,MinimumNumofDaysforLease,Miscellaneous,MiscellaneousExpense,MiscellaneousImprovements,MiscellaneousInformation,MLSNumber,ModelName,MoveInDollars,MultipleOffersAcceptedYN,MunicipalCode,Neighborhoods,NetOperatingIncome,NumBays,NumBuildings,NumCarportSpaces,NumCeilingFans,NumEmployees,NumFloors,NumGarageSpaces,NumInteriorLevels,NumLeasesYear,NumLoadingDoors,NumMeters,NumOffices,NumParcels,NumParkingSpaces,NumSeats,NumStories,NumTenants,NumTimesLeasedYear,NumToilets,NumUnits,OccupancyInformation,OccupancyPercentage,OffMarketDate,OfficeFaxNumber,OnSiteUtilities,OriginalEntryTimestamp,OriginalListPrice,OtherExpenses,OtherIncomeExpense,OwnerAgentYN,Ownership,PACEYN,ParcelNumber,ParcelNumberMLX,ParkingDescription,ParkingRestrictions,ParkingSpaceNumber,PatioBalconyDimensions,PendingDate,PetRestrictions,PetsAllowedYN,PhotoCount,PhotoModificationTimestamp,PoolDescription,PoolDimensions,PoolYN,PossessionInformation,PostalCode,PostalCodePlus4,PreviousStatus,PriceAcre,PriceChangeTimestamp,PropTypeTypeofBuilding,PropertyDescription,PropertyDetachedYN,PropertySqFt,PropertySubType,PropertyType,PropertyTypeInformation,ProviderKey,RailDescription,RATIO_ClosePrice_By_ListPrice,RealEstateTaxes,RecLeaseMoFeePaidPer,RecLeaseMonth,ReimbursableSqFt,Remarks,RentIncludes,RentPeriod,RentStatusApril,RentStatusAugust,RentStatusDecember,RentStatusFebruary,RentStatusJanuary,RentStatusJuly,RentStatusJune,RentStatusMarch,RentStatusMay,RentStatusNovember,RentStatusOctober,RentStatusSeptember,RentalDepositIncludes,RentalPaymentIncludes,REOYN,Restrictions,RoadDescription,RoadFrntgDescription,RoadFrontage,RoadTypeDescription,Roof,RoofDescription,RoomCount,RoomsDescription,SaleIncludes,SaleIncludesINCL,SaleIncludesSALE,SaleTerms,Section,SecurityInformation,SellerContributionsAmt,SellerContributionsYN,SellingAgentDirectWorkPhone,SellingAgentEmail,SellingAgentFullName,SellingAgentLicenseNum,SellingAgentMLSID,SellingOfficeMLSID,SellingOfficeName,SellingOfficePhone,SeniorHighSchool,SeparateMeterYN,SerialNumber,ServiceExpense,SewerDescription,ShortSaleAddendumYN,ShortSaleYN,ShowingInstructions,ShowingSuiteEmailInfoYN,ShowingSuiteSettingYN,ShowingTimeFlag,SoldPriceperSF,SourceofExpenses,SpaYN,SpecialAssessmentYN,SpecialInformation,SprinklerDescription,SqFtLAofGuestHouse,SqFtLivArea,SqFtOccupied,SqFtTotal,StateOrProvince,Status,StatusChangeTimestamp,StatusContractualSearchDate,StormProtection,StreetDirPrefix,StreetDirSuffix,StreetName,StreetNumber,StreetNumberNumeric,StreetSuffix,StreetViewParam,Style,StyleTran,StyleofBusiness,StyleofProperty,SubBoardID,SubdivisionComplexBldg,SubdivisionInformation,SubdivisionName,SubdivisionNumber,SupplementCount,SupplementModificationTimestamp,SupplementRemarksYN,SupplementalRemarks,SupplyExpense,SurfaceDescription,TaxAmount,TaxInformation,TaxYear,TempOffMarketDate,TenantPays,TermsAvailable,TermsConsidered,TotalAcreage,TotalAssumableLoans,TotalExpenses,TotalFloorsInBuilding,TotalMortgage,TotalMoveInDollars,TotalNumofUnitsInBuildin,TotalNumofUnitsInComplex,TotalUnits,TownshipRange,TrainingAvailableYN,TransactionType,TrashExpense,TypeofAssociation,TypeofBuilding,TypeofBusiness,TypeofContingencies,TypeofGoverningBodies,TypeofOwnership,TypeofProperty,TypeofSoil,TypeofTrees,UnfurnAnnualRent,UnfurnOffSeasonRent,UnfurnSeasonalRent,UnitCount,UnitDesign,UnitFloorLocation,UnitNumber,UnitView,Usage,UsageDescription,UtilitiesAvailable,UtilityExpense,UtilityRoomDimension,VacancyRate,VarDualRateCompYN,View,VirtualTour,WaterAccess,WaterDescription,WaterView,WaterfrontDescription,WaterfrontFrontage,WaterfrontPropertyYN,WaterviewDescription,WebAddress,WindowsTreatment,WithdrawnDate,YearBuilt,YearBuiltDescription,YearEstablished,YearofAddition,ZoningInformation", ",");
	this.arrFieldLookupFields=arraynew(1);
	this.mls_provider="rets30";
	this.sysidfield="rets30_matrix_unique_id";
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

	variables.tableLookup["listing"]="1"; 
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

		//writedump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields);abort;
		if(structcount(this.emptyStruct) EQ 0){
			for(i=1;i LTE arraylen(this.arrColumns);i++){
				if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields, this.arrColumns[i])){
					this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
				}else{
					throw("I must update the arrColumns list - missing: "&this.arrColumns[i]);	
				}
			}
		}
		ts=duplicate(this.emptyStruct);
		/*
		
		wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '30-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '30-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '30-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '30-%'; 
		
		
		*/
		if(arraylen(arguments.ss.arrData) NEQ arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.functions.zdump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
			application.zcore.functions.zdump(arguments.ss.arrData);
			application.zcore.functions.zabort();
		}  
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			throw("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
			ts["rets30_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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
		if(local.listing_subdivision EQ ""){
			if(findnocase(","&ts["Development Name"]&",", ",,false,none,not on the list,not applicable,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Development Name"]="";
			}else if(ts["Development Name"] NEQ ""){
				ts["Development Name"]=application.zcore.functions.zFirstLetterCaps(ts["Development Name"]);
			}
			if(ts["Development Name"] NEQ ""){
				local.listing_subdivision=ts["Development Name"];
			}
		} 
		if(local.listing_subdivision EQ ""){
			if(findnocase(","&ts["Complex Name"]&",", ",,false,none,not on the list,not applicable,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Complex Name"]="";
			}else if(ts["Complex Name"] NEQ ""){
				ts["Complex Name"]=application.zcore.functions.zFirstLetterCaps(ts["Complex Name"]);
			}
			if(ts["Complex Name"] NEQ ""){
				local.listing_subdivision=ts["Complex Name"];
			}
		}

		if(local.listing_subdivision EQ ""){
			if(findnocase(","&ts["Subdivision Complex Bldg"]&",", ",,false,none,not on the list,not applicable,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Subdivision Complex Bldg"]="";
			}else if(ts["Subdivision Complex Bldg"] NEQ ""){
				ts["Subdivision Complex Bldg"]=application.zcore.functions.zFirstLetterCaps(ts["Subdivision Complex Bldg"]);
			}
			if(ts["Subdivision Complex Bldg"] NEQ ""){
				local.listing_subdivision=ts["Subdivision Complex Bldg"];
			}
		}
		if(local.listing_subdivision EQ ""){
			if(findnocase(","&ts["Subdivision Information"]&",", ",,false,none,not on the list,not applicable,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Subdivision Information"]="";
			}else if(ts["Subdivision Information"] NEQ ""){
				ts["Subdivision Information"]=application.zcore.functions.zFirstLetterCaps(ts["Subdivision Information"]);
			}
			if(ts["Subdivision Information"] NEQ ""){
				local.listing_subdivision=ts["Subdivision Information"];
			}
		}
 

		if(ts["Property Type"] EQ "RIN" and ts["Gross Rent"] NEQ "" and ts["Gross Rent"] NEQ "0"){
			ts["list price"]=ts["Gross Rent"];
		}
		
		this.price=ts["list price"];
		local.listing_price=ts["list price"];
		cityName="";
		cid=0;
		if(structkeyexists(request.zos.listing.cityStruct, ts["City"]&"|"&ts["State Or Province"])){
			cid=request.zos.listing.cityStruct[ts["City"]&"|"&ts["State Or Province"]];
		}
		local.listing_county="";
		if(local.listing_county EQ ""){
			local.listing_county=this.listingLookupNewId("county",ts['County Or Parish']);
		}
		
	
		local.listing_sub_type_id="";//this.listingLookupNewId("listing_sub_type",ts['style']);


		local.listing_type_id=this.listingLookupNewId("listing_type",ts['property type']);

		

		rs=getListingTypeWithCode(ts["property type"]);
		
		if(ts["Address Internet Display"] EQ "N"){
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
		arrS=listtoarray(ts['Special Information'],",");
		if(ts["Short Sale Addendum YN"] EQ "Y"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
			break;
		}
		for(i=1;i LTE arraylen(arrS);i++){
			c=trim(arrS[i]);
			// Special Information
			if(c EQ "BANKOWNED"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
				break;
			}
			if(c CONTAINS "FORECLOSE"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
				break;
			} 
		}
		if(ts['Construction Type'] CONTAINS "NEW"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
		}
		if(ts['Property Type'] CONTAINS "REN"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else{
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		arrT3=[];
		local.listing_status=structkeylist(s,",");
		
		uns=structnew(); 
		tmp=ts['Style'];
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
		tmp=ts['Styleof Business'];
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
		tmp=ts['Styleof Property'];
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
		tmp=ts['Style Tran'];
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
		


		arrT2=[]; 
		tmp=ts['parking description'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("parkingdescription",arrT[i]);
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
		arguments.ss.listing_track_price=ts["Original List Price"];
		if(arguments.ss.listing_track_price EQ "" or arguments.ss.listing_track_price EQ "0" or arguments.ss.listing_track_price LT 100){
			arguments.ss.listing_track_price=ts["List Price"];
		}
		arguments.ss.listing_track_price_change=ts["List Price"];
		liststatus=ts["Status"];
		
		s2=structnew();
		if(liststatus EQ "A"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
		} 
		if(liststatus EQ "W"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["withdrawn"]]=true;
		}
		if(liststatus EQ "T"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["temporarily withdrawn"]]=true;
		}
		if(liststatus EQ "PS"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["pending"]]=true;
		}
		if(liststatus EQ "X"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["expired"]]=true;
		}
		if(liststatus EQ "CS"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["sold"]]=true;
		} 
		if(liststatus EQ "R"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["rented"]]=true;
		}
		local.listing_liststatus=structkeylist(s2,",");
		if(local.listing_liststatus EQ ""){
			local.listing_liststatus=1;
		}
		
		// view & frontage
		arrT3=[];
		
		uns=structnew();
		tmp=ts['waterfront description'];
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
		if(ts["unit design"] CONTAINS "ONGOLFCS"){
			tmp=this.listingLookupNewId("frontage", "ONGOLFCS");
			arrayappend(arrT3, tmp);
		}
		local.listing_frontage=arraytolist(arrT3);
		
		
		arrT2=[];
		uns=structnew();
		tmp=ts['water view'];
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("view",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
		} 
		  
		local.listing_view=arraytolist(arrT2);
		

		local.listing_pool=0;
		if(ts["pool yn"] EQ "Y"){
			local.listing_pool=1;	
		}


		tempTime=gettickcount('nano');
		application.idxImportTimerStruct.parseRow1+=(tempTime-startTime);
		startTime=tempTime;

		ts=this.convertRawDataToLookupValues(ts, 'listing', ts.rets30_propertytype);
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage=ts["Total Acreage"];
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
		rs.listing_lot_square_feet=ts["Lot Sq Footage"];
		rs.listing_square_feet=ts["Building Sq Ft"];
		if(rs.listing_square_feet EQ ""){
			rs.listing_square_feet=ts["Property Sq Ft"];
		}
		rs.listing_subdivision=local.listing_subdivision;
		rs.listing_year_built=ts["year built"];
		rs.listing_office=ts["List Office MLSID"];
		rs.listing_office_name=ts["List Office Name"];
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
		rs.listing_data_remarks=ts["Internet Remarks"];
		if(rs.listing_data_remarks EQ ""){
			rs.listing_data_remarks=ts["Remarks"];
		}
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts["Postal Code"]);
		rs.listing_data_detailcache1=listing_data_detailcache1;
		rs.listing_data_detailcache2=listing_data_detailcache2;
		rs.listing_data_detailcache3=listing_data_detailcache3;
		//writedump(rs);		writedump(ts);abort;

		rs.listing_track_sysid=ts["rets30_matrix_unique_id"];

		tempTime=gettickcount('nano');
		application.idxImportTimerStruct.parseRow2+=(tempTime-startTime);
		startTime=tempTime;

		//writedump(rs);abort;

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
				local.absPath='#request.zos.sharedPath#mls-images/30/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				//if(fileexists(local.absPath)){
					if(i EQ 1){
						request.lastPhotoId=arguments.ss.listing_id;
					}
					idx["photo"&i]=request.zos.retsPhotoPath&'30/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				/*}else{
					idx["photo"&i]='/z/a/listing/images/image-not-available.gif';
					if(i EQ 1){
						request.lastPhotoId="";
					}
				}*/
			}
		}
		idx["agentName"]=arguments.ss["rets30_listagentfullname"];
		idx["agentPhone"]=arguments.ss["RETS30_LISTAGENTDIRECTWORKPHONE"];
		idx["agentEmail"]=arguments.ss["rets30_listagentemail"];
		idx["officeName"]=arguments.ss["rets30_listofficename"];
		idx["officePhone"]=arguments.ss["RETS30_LISTOFFICEPHONE"];
		idx["officeCity"]="";
		idx["officeAddress"]="";
		idx["officeZip"]="";
		idx["officeState"]="";
		idx["officeEmail"]="";
		
		idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets30_virtualtour");
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_postalcode");
		idx["maintfees"]=0;
		
		
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
		local.absPath='#request.zos.sharedPath#mls-images/30/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		if(fileexists(local.absPath)){
			return request.zos.retsPhotoPath&'30/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
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
		/*
		fd=this.getRETSValues("property", "","parkingdescription"); 
		writedump(fd);
		writedump(structkeyarray(application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup));
		abort;
		*/
		fd=this.getRETSValues("property", "","parkingdescription"); 
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}  
		 
		// 1=property type
		fd=this.getRETSValues("property", "","propertytype");
		//fd["M"]="Multi-Family";
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		 
		fd=this.getRETSValues("property", "","unitdesign");
		for(i in fd){
			if(i EQ "ONGOLFCS"){
				arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", "","waterfrontdescription");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		} 
		
		// view
		fd=this.getRETSValues("property", "","waterview");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		} 
		
		fd=this.getRETSValues("property", "","style");
		for(i in fd){  
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		}
		
		fd=this.getRETSValues("property", "","styleofproperty");
		for(i in fd){  
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		}
		
		fd=this.getRETSValues("property", "","styleofbusiness");
		for(i in fd){  
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		}
		
		fd=this.getRETSValues("property", "","styletran");
		for(i in fd){  
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		}
		

		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>