<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
	<cfscript>
	this.retsVersion="1.7";
	
	this.mls_id=31;
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/31/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/31/";
	}
	this.useRetsFieldName="system";


	this.arrColumns=listtoarray("AccessAndTransportation,AdditionalDepositsFees,AdditionalRooms,AnnualRent,ApplicationFeeAmount,AsIsConditionYN,AssessmentFeeAmount,AssociationApprovalRequiredYN,AssociationFee,AssociationFee2,AssociationFee2Frequemcy,AssociationFeeFrequency,AssociationFeeIncludes,AssociationFeeYN,BathroomsFull,BathroomsHalf,BathroomsTotalDecimal,BathroomsTotalInteger,BedroomsTotal,BuildingAreaSource,BuildingAreaTotal,BusinessAge,BusinessName,BusinessOnlyYN,BusinessType,BuyerAgentAOR,BuyerAgentDirectPhone,BuyerAgentEmail,BuyerAgentFullName,BuyerAgentKeyNumeric,BuyerAgentMlsId,BuyerOfficeKeyNumeric,BuyerOfficeMlsId,BuyerOfficeName,BuyerOfficePhone,BuyerOfficePhoneExt,CandRYN,CeilingHeight,City,ClearSpan,Cleared,CloseDate,ClosePrice,CommercialClass,Community55PlusYN,ComplexName,ConfidentialListingYN,Construction,Cooling,CountyOrParish,CurrentlyLeasedYN,DateAvailable,Directions,DisasterMitigation,DockAssociationDuesMQA,DockAssociationFee,DockAssociationYN,DockFacilityName,DockGoverningBody,DockHarbormasterYN,DockLiftCapacity,DockLiftYN,DockMaintenanceExpensesPaidBy,DockMaintenanceFees,DockMarinaAmenities,DockMonitorVHF16YN,DockMoorage,DockOvernightRestrictYN,DockOwnershipRequiredYN,DockParkingAvailableYN,DockRestrictionsDescription,DockSlipAmenities,DockSlipSizeLength,DockSlipSizeWidth,DockSlipStorageYN,DockWastePumpYN,DocumentsChangeTimestamp,DocumentsCount,Electric,ElectricalExpenses,EquipmentAndAppliances,ExteriorFeatures,FractionalOwnershipPerc,FreestandingYN,Furnished,GasAverageperMonth,GreenCertification,GreenEnergyFeatures,GreenEnergyGeneral,GreenLandscaping,GreenWaterFeatures,GrossIncome,GroundExpenses,GroundFloorBedroomYN,GroundFloorMasterBedroomYN,Heating,HotWaterHeater,HowSold,ILSAttachedYN,ILSBathrooms,ILSBedrooms,ILSKitchenYN,ILSSeparateEntranceYN,ILSTotalSQFT,ILSUnderAirSQFT,InLawSuiteYN,IncluInMonthlyLeaseAmnt,IncludedInSale,IndoorAirQuality,InsuranceExpenses,InteriorFeatures,InteriorImprovements,InternetAddressDisplayYN,InternetAutomatedValuationDisplayYN,InternetConsumerCommentYN,InternetEntireListingDisplayYN,Irrigation,LandDimensions,LandStyle,LandUse,LeaseAmountFrequency,LeaseInfo,LeaseProvisions,LeaseTerms,LegalDescription,ListAgentAOR,ListAgentDirectPhone,ListAgentEmail,ListAgentFullName,ListAgentKeyNumeric,ListAgentMlsId,ListAOR,ListOfficeKeyNumeric,ListOfficeMlsId,ListOfficeName,ListOfficePhone,ListOfficePhoneExt,ListPrice,ListingAgreement,ListingArea,ListingContractDate,ListingId,ListingKeyNumeric,ListingService,LivingArea,LivingAreaSource,LNDProjectPhase,LoadingDock,LocationDescription,LotSizeAcres,LotSizeDimension,MaintenanceExpenses,MajorChangeTimestamp,MajorChangeType,ManagementExpenses,MasterAssociation,MasterBath,MaxRatedOccupancy,MinimalRentalAllowed,MinimumLease,MlsMajorChangeType,MlsStatus,ModificationTimestamp,NetIncome,NoDriveBeach,NonListedSoldYN,NumDishwashers,NumDryers,NumElectricMeters,NumEmployees,NumGasMeters,NumMicrowaves,NumOverheadDoors,NumParkingSpaces,NumRanges,NumRefrigerators,NumWasherDryerHookupsOnly,NumWashers,NumWaterMeters,NumberOfUnitsInCommunity,Occupancy,OfficeSqFt,OperatingExpenses,OriginalEntryTimestamp,OriginalListPrice,OriginatingSystemKey,OriginatingSystemName,OriginatingSystemTimestamp,OtherAvailbleFeatures,OtherExpenses,OwnerName,OwnershipRequiredNotes,OwningOfficeKeyNumeric,ParcelNumber,ParkingFeatures,PetComments,PetFeeAmount,PetNumberAllowed,PetRestrictionTypes,PetRestrictionsYN,PetSizeRestriction,PetsAllowedYN,PhotosChangeTimestamp,PhotosCount,Pool,PoolFeatures,Possession,PostalCode,PropertyManager,PropertyManagerOnSiteYN,PropertyManagerPhone,PropertySubType,PropertyType,PublicRemarks,PurchaseContractDate,RentIncludes,RentalStorageUnit,RentperMonth,RightofFirstRefusal,RLSECleaningFee,RLSEFees,RLSEPetDeposit,RoadAccessYN,RoadFrontageDepth,Roof,SecondaryAssociationYN,Security,SecurityAndMisc,SecurityDepositAmount,Sewer,SiteImprovements,SpecialContingenciesApplyYN,SpecialListingConditions,SplitBRYN,StandardStatus,StateOrProvince,Stories,StoriesTotal,StreetDirPrefix,StreetDirSuffix,StreetName,StreetNumber,StreetNumberNumeric,StreetSuffix,SubSubDivision,SubdivisionName,SyndicateTo,TenantExpenses,TotalIncome,TotalLeases,TotalUnits,TransactionType,TypeOfBuisness,TypeStreet,UnitFaces,UnitFloorNumber,UnitNumber,UseAndPossibleUse,UtilitiesOnSite,UtlitiesAndFuel,VirtualTourURL,WasherDryer,Water,WaterAndSewer,WaterExpenses,WaterFrontageFeet,WaterFrontageYN,WaterIinformation,WaterOther,WaterViewYN,WaterfrontFeatures,WindowFeatures,WithdrawnDate,YearBuilt,YearBuiltSource,Zoning", ",");
	this.arrFieldLookupFields=arraynew(1);
	this.mls_provider="rets31";
	this.sysidfield="rets31_ListingKeyNumeric";
	variables.resourceStruct=structnew();
	variables.resourceStruct["property"]=structnew();
	variables.resourceStruct["property"].resource="property";
	variables.resourceStruct["property"].id="ListingId";
	variables.resourceStruct["office"]=structnew();
	variables.resourceStruct["office"].resource="office";
	variables.resourceStruct["office"].id="OfficeKeyNumeric";
	variables.resourceStruct["agent"]=structnew();
	variables.resourceStruct["agent"].resource="agent";
	variables.resourceStruct["agent"].id="MemberKeyNumeric";
	this.emptyStruct=structnew();
	
	
	
	variables.tableLookup=structnew();

	variables.tableLookup["listing"]="1"; 
	variables.t5=structnew();

	this.remapFieldStruct=variables.t5;

	
	</cfscript> 

<cffunction name="initImport" localmode="modern" output="no" returntype="any">
	<cfargument name="resource" type="string" required="yes">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	
	var qZ=0;
	super.initImport(arguments.resource, arguments.sharedStruct);
	
	arguments.sharedStruct.lookupStruct.cityRenameStruct=structnew();
	</cfscript>
</cffunction>
    
<cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript> 
	var columnIndex=structnew(); 
	var a9=arraynew(1); 
	
	var db=request.zos.queryObject;
	if(structcount(this.emptyStruct) EQ 0){
		for(i=1;i LTE arraylen(this.arrColumns);i++){
			if(this.arrColumns[i] EQ "HiRes location"){
				continue;
			}
			this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
		}
	}
	
	for(i=1;i LTE arraylen(arguments.ss.arrData);i++){
		if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.idxSkipDataIndexStruct, i) EQ false){
			arrayappend(a9, arguments.ss.arrData[i]);	
		}
	}
	arguments.ss.arrData=a9;

	ts=duplicate(this.emptyStruct);
	if(arraylen(arguments.ss.arrData) NEQ arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
		application.zcore.functions.zdump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
		application.zcore.functions.zdump(arguments.ss.arrData);
		application.zcore.functions.zabort();
	}  
	if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
		application.zcore.template.fail("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
	}
	// photoLocation="";
	for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
		// if(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i] EQ "rets31_hireslocation"){
		// 	photoLocation=arguments.ss.arrData[i];
		// 	continue;
		// }
		if(!structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields, removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7))){
			continue;
		}
		col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
		ts["rets31_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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
		//ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=ts[col];
		columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
	} 
	ts["rets31_listprice"]=replace(ts["rets31_listprice"],",","","ALL");
	// need to clean this data - remove not in subdivision, 0 , etc.
	subdivision="";
	listing_subdivision="";
	if(application.zcore.functions.zso(ts, "rets31_SubdivisionName") NEQ ""){
		subdivision=ts["rets31_SubdivisionName"]; 
		listing_subdivision=this.getRetsValue("property", "property", "SubdivisionName", subdivision);
	}

	
	if(listing_subdivision NEQ ""){
		if(findnocase(","&listing_subdivision&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			listing_subdivision="";
		}else{
			listing_subdivision=application.zcore.functions.zFirstLetterCaps(listing_subdivision);
		}
	}  
	
	// if(ts['rets31_propertytype'] EQ 2){
	// 	ts['rets31_propertysubtype']='V';
	// }

	this.price=ts["rets31_listprice"];
	listing_price=ts["rets31_listprice"];
	cityName="";
	cid=0;
	ts['city']=this.getRetsValue("property", "", "city", ts['rets31_city']);
	ts['StateOrProvince']=this.getRetsValue("property", "", "StateOrProvince",ts['rets31_StateOrProvince']); 
	if(structkeyexists(request.zos.listing.cityStruct, ts["city"]&"|"&ts["rets31_StateOrProvince"])){
		cid=request.zos.listing.cityStruct[ts["city"]&"|"&ts["rets31_StateOrProvince"]];
	} 
	if(cid EQ 0 and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct, ts['rets31_postalcode'])){
		cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct[ts['rets31_postalcode']];
		ts["city"]=listgetat(cityName,1,"|");
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["rets31_StateOrProvince"])){
			cid=request.zos.listing.cityStruct[cityName&"|"&ts["rets31_StateOrProvince"]];
		}
	} 
 
	listing_county=this.listingLookupNewId("county",ts['rets31_CountyOrParish']);
	listing_parking="";//this.listingLookupNewId("listing_parking",ts['rets31_Parking']);
 
	// sub type:
	// PropertySubType 
	/* lookups for sub type:

	LookupMulti5A
	LookupMulti2P
	LookupMulti1G
	Lookup70
	Lookup67
	
	field names
	UseAndPossibleUse
	LandStyle
	LandType
	RentalPropertyType
	CommercialClass
	*/
	if(application.zcore.functions.zso(ts, "rets31_UseAndPossibleUse") NEQ ""){
		arrT=listtoarray(ts["rets31_UseAndPossibleUse"]);
	}else if(application.zcore.functions.zso(ts, "rets31_LandStyle") NEQ ""){
		arrT=listtoarray(ts["rets31_LandStyle"]);
	}else if(application.zcore.functions.zso(ts, "rets31_CommercialClass") NEQ ""){
		arrT=listtoarray(ts["rets31_CommercialClass"]); 
	}else{
		arrT=[];
	} 
	arrT3=[];
	for(i=1;i LTE arraylen(arrT);i++){
		tmp=this.listingLookupNewId("listing_sub_type",arrT[i]);
		if(tmp NEQ ""){
			arrayappend(arrT3,tmp);
		}
	}
	listing_sub_type_id=arraytolist(arrT3);  
	
	listing_type_id=this.listingLookupNewId("listing_type",ts['rets31_propertytype']);

	ad=ts['rets31_streetnumber'];
	if(ad NEQ 0){
		address="#ad# ";
	}else{
		address="";	
	} 
	// if(structkeyexists(ts, 'direction')){
	// 	direction=this.getRetsValue("property", "", "direction",ts['rets31_direction']);
	// 	address&=application.zcore.functions.zfirstlettercaps(direction&" "&ts['rets31_streetname']);
	// }else{
		address&=application.zcore.functions.zfirstlettercaps(ts['rets31_streetname']);
	// }
	curLat="";
	curLong="";
	/*
	if(curLat EQ "" and trim(address) NEQ ""){
		rs5=this.baseGetLatLong(address,ts['StateOrProvince'],ts['postalcode'], arguments.ss.listing_id);
		if(rs5.success){
			curLat=rs5.latitude;
			curLong=rs5.longitude;
		}
	}*/
	
	if(ts['rets31_UnitNumber'] NEQ ''){
		address&=" Unit: "&ts["rets31_UnitNumber"];
	} 
	
	/*s2=structnew();
	liststatus=this.getRetsValue("property", "", 'ListingStatus', ts["rets31_ListingStatus"]);
	if(liststatus EQ "Active"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
	}else if(liststatus EQ "Canceled"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Cancelled"]]=true;
	}else if(liststatus EQ "Pending"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["pending"]]=true;
	}else if(liststatus EQ "Expired"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["expired"]]=true;
	}else if(liststatus EQ "Closed"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["sold"]]=true; 
	}else if(liststatus EQ "Contingent"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["contingent"]]=true;
	}else if(liststatus EQ "Deleted"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["deleted"]]=true;
	}else if(liststatus EQ "Temp Off Market"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["temporarily withdrawn"]]=true;
	}
	listing_liststatus=structkeylist(s2,",");*/

		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
	listing_liststatus=structkeylist(s2,",");
	
	/*arrT3=[];
	uns=structnew();
	tmp=ts['style'];
	// style and pool don't work.
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("listing_style",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	listing_style=arraytolist(arrT3);*/

/*
	openhouse=application.zcore.functions.zso(ts,"rets31_openhouseyn", false, "n");
	if(openhouse EQ ""){
		openhouse="n";
	}
	if(openhouse EQ "y"){
		//openhouseaid,openhousedt,openhouserem,openhousetm,openhouseyn
	}
*/

	listing_style="";
	// uns={};
	// tmp=application.zcore.functions.zso(ts,"rets31_WaterfrontFeatures");
	// if(tmp NEQ ""){
	//    arrT=listtoarray(tmp);
	// 	for(i=1;i LTE arraylen(arrT);i++){
	// 		tmp=this.listingLookupNewId("view",arrT[i]);
	// 		//LookupMulti1B 

	// 		//LookupMulti4B

	// 		if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
	// 			uns[tmp]=true;
	// 			arrayappend(arrT3,tmp);
	// 		}
	// 	}
	// }
	listing_view="";//arraytolist(arrT3);

	tmp=application.zcore.functions.zso(ts, "rets31_WaterfrontFeatures");
	/*
LookupMulti7C
LookupMulti4C
LookupMulti2C
LookupMulti1C
	*/
	uns={};
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
	listing_frontage=arraytolist(arrT3);
	 

	tmp=application.zcore.functions.zso(ts, "rets31_Pool");
	listing_pool="0";
	if(tmp EQ "PRIVT"){ 
		listing_pool="1";
	} 
	// tempTableLookup={};
	// tempTableLookup["BDOCK"]="BoatDock"; // Boat Dock
	// tempTableLookup["COMLS"]="CommercialRental"; // For Rent-Commercial
	// tempTableLookup["F"]="ResidentialProperty"; //  Residential Factory Built
	// tempTableLookup["C"]="CommercialProperty"; //  Commercial Sale
	// tempTableLookup["L"]="ResidentialProperty"; //  Condotels
	// tempTableLookup["N"]="ResidentialRental"; //  For Rent-Residential-Resort
	// tempTableLookup["O"]="ResidentialProperty"; //  Condo
	// tempTableLookup["I"]="ResidentialIncomeProperty"; //  Residential Income
	// tempTableLookup["U"]="ResidentialProperty"; //  Single Unit of 2, 3, 4 plex
	// tempTableLookup["T"]="ResidentialProperty"; //  Townhomes
	// tempTableLookup["V"]="VacantLand"; //  Vacant Land
	// tempTableLookup["P"]="ResidentialProperty"; //  Co-Op
	// tempTableLookup["R"]="ResidentialProperty"; //  Single Family Site Built

	// propertyTable=tempTableLookup[ts['rets31_propertysubtype']];
  
	ts=this.convertRawDataToLookupValues(ts, "property", '');
	//writedump(propertyTable);
	//writedump(ts);abort;
	//writedump(propertysubtype);abort;
  
 
	/*
	ts2=structnew();
	ts2.field="";
	ts2.yearbuiltfield=ts['year built'];
	ts2.foreclosureField="";
	
	s=this.processRawStatus(ts2);
	*/
	s={};
	if(application.zcore.functions.zso(ts, 'rets31_yearbuilt') EQ year(now())){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
	} 

	//if(ts["rets31_propertysubtype"] EQ "E" or ts["rets31_propertysubtype"] EQ "N"){
	if(ts["rets31_transactiontype"] EQ "For Lease" or ts["rets31_propertytype"] EQ "Residential Lease"){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true; 
	}else{
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
	} 

	arrListType=listToArray(application.zcore.functions.zso(ts, 'rets31_SpecialListingConditions'), ',');
	for(i in arrListType){
		if(i EQ "Real Estate Owned"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}else if(i EQ "Under Construction"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["pre construction"]]=true;
		}else if(i EQ "Short Sale"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}else if(i EQ "Auction"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["auction"]]=true;
		}else if(i EQ "Lease Option"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else if(i EQ "In Foreclosure"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
	} 
	listing_status=structkeylist(s,",");
	 
	dataCom=this.getRetsDataObject();
	listing_data_detailcache1=dataCom.getDetailCache1(ts);
	listing_data_detailcache2=dataCom.getDetailCache2(ts);
	listing_data_detailcache3=dataCom.getDetailCache3(ts); 
	rs=structnew();
	rs.listing_acreage="";
	if(application.zcore.functions.zso(ts, 'rets31_LotSizeAcres') NEQ ""){
		rs.listing_acreage=ts["rets31_LotSizeAcres"]; 
	}
	rs.listing_id=arguments.ss.listing_id;
	if(structkeyexists(ts, 'rets31_BathroomsFull')){
		rs.listing_baths=ts["rets31_BathroomsFull"];
	}else{
		rs.listing_baths='';
	}
	rs.listing_halfbaths=application.zcore.functions.zso(ts, "rets31_BathroomsHalf");
	if(structkeyexists(ts, "rets31_BedroomsTotal")){
		rs.listing_beds=ts["rets31_BedroomsTotal"];
	}else{
		rs.listing_beds=0;
	}
	rs.listing_condoname="";
	rs.listing_city=cid;
	rs.listing_county=listing_county;
	rs.listing_frontage=","&listing_frontage&",";
	rs.listing_frontage_name="";
	rs.listing_price=ts["rets31_listprice"];
	rs.listing_status=","&listing_status&",";
	rs.listing_state=ts["rets31_StateOrProvince"];
	rs.listing_type_id=listing_type_id;
	rs.listing_sub_type_id=","&listing_sub_type_id&",";
	rs.listing_style=","&listing_style&",";
	rs.listing_view=","&listing_view&",";
	rs.listing_lot_square_feet="";

	rs.listing_square_feet=application.zcore.functions.zso(ts, "rets31_LivingArea");
 
	rs.listing_lot_square_feet="";//application.zcore.functions.zso(ts, "rets31_LotSizeArea"); 


	rs.listing_subdivision=listing_subdivision;
	rs.listing_year_built=application.zcore.functions.zso(ts, "rets31_yearbuilt");
	if(rs.listing_year_built EQ ""){
		rs.listing_year_built=application.zcore.functions.zso(ts, "Year Built");
	}
	rs.listing_office=ts["rets31_ListOfficeKeyNumeric"];
	rs.listing_agent=ts["rets31_ListAgentKeyNumeric"]; 

	if(not structkeyexists(request, 'rets31officeLookup')){
		t2={};
		path="#request.zos.sharedPath#mls-data/"&this.mls_id&"/office.txt";
		f=application.zcore.functions.zReadFile(path);
		if(f EQ false){
			throw("Office file is missing for rets31");
		}
		arrLine=listToArray(f, chr(10));
		first=true;
		for(line in arrLine){
			arrRow=listToArray(line, chr(9), true);
			if(first){
				arrColumn=arrRow;
				first=false;
			}else{
				t3={};
				for(g=1;g LTE arraylen(arrRow);g++){
					t3[trim(arrColumn[g])]=trim(arrRow[g]);
				}  
				t2[t3[variables.resourceStruct["office"].id]]=t3;
			}
		} 
		request.rets31officeLookup=t2;
	}
	if(structkeyexists(request.rets31officeLookup, rs.listing_office)){
		rs.listing_office_name=request.rets31officeLookup[rs.listing_office].officename;
	}else{
		rs.listing_office_name='';
	}  
	rs.listing_latitude=curLat;
	rs.listing_longitude=curLong;
	rs.listing_pool=listing_pool;
	rs.listing_photocount=ts["rets31_PhotosCount"];
	rs.listing_coded_features="";
	rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
	rs.listing_primary="0";
	rs.listing_mls_id=arguments.ss.listing_mls_id;
	rs.listing_address=trim(address);
	rs.listing_zip=ts["rets31_postalcode"];
	rs.listing_condition="";
	rs.listing_parking=listing_parking;
	rs.listing_region="";
	rs.listing_tenure="";
	rs.listing_liststatus=listing_liststatus;
	rs.listing_data_remarks=ts["rets31_publicremarks"];
	rs.listing_data_address=trim(address);
	rs.listing_data_zip=trim(ts["rets31_postalcode"]);
	rs.listing_data_detailcache1=listing_data_detailcache1;
	rs.listing_data_detailcache2=listing_data_detailcache2;
	rs.listing_data_detailcache3=listing_data_detailcache3; 
	//if(ts["WATERTYPE"] NEQ ""){ 	writedump(rs);abort;	}

	rs.listing_track_external_timestamp=ts["rets31_modificationtimestamp"]; 
	rs.listing_track_sysid=ts["rets31_ListingKeyNumeric"];
	rs2={
		listingData:rs,
		columnIndex:columnIndex,
		arrData:arguments.ss.arrData
	};
	//writedump(photoLocation);	writedump(rs2);abort;
	return rs2;
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
			request.lastPhotoId=idx.listing_id;
			// ts=getCachedRequestListingImageUrls(idx); 
			// structappend(idx, ts, true); 
			
			i=1; 
			
			for(i=1;i LTE arguments.ss.listing_photocount;i++){
				
				local.fNameTemp1=arguments.ss.listing_id&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				local.absPath='#request.zos.sharedPath#mls-images/31/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				if(i EQ 1){
					request.lastPhotoId=arguments.ss.listing_id;
				}
				idx["photo"&i]=request.zos.retsPhotoPath&'31/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
			}
			// LargePhoto location
			// https://rets.sef.mlsmatrix.com/Rets/GetRetsMedia.ashx?Key=26938795&TableID=9&Type=1&Number=0&Size=3&usd=-1&ust=PaYDAM9gPz8vk(Bl55dX8lj79FJXpyFvCk(7TxlttNjqixNJMUUHGw))
			/**/
		}
		idx["agentName"]=arguments.ss["rets31_listagentfullname"];
		idx["agentPhone"]=arguments.ss["rets31_ListAgentDirectPhone"];
		idx["agentEmail"]=arguments.ss["rets31_listagentemail"];
		idx["officeName"]=arguments.ss["rets31_listofficename"];
		idx["officePhone"]=arguments.ss["rets31_LISTOFFICEPHONE"];
		idx["officeCity"]="";
		idx["officeAddress"]="";
		idx["officeZip"]="";
		idx["officeState"]="";
		idx["officeEmail"]="";
		
		idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets31_virtualtour");
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
		
		//request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		// local.fNameTemp1=this.mls_id&"-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTemp1="31-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		local.absPath='#request.zos.sharedPath#mls-images/31/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		if(fileexists(local.absPath)){
			return request.zos.retsPhotoPath&'31/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		}else{
			return "";
			request.lastPhotoId="";
		}
		</cfscript>
    </cffunction>
	
<cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
	<cfscript> 
	var arrSQL=[]; 
	var arrError=[]; 
	var db=request.zos.queryObject; 
	var cityCreated=false; 

	// fd={};
	// fd["D"]="Boat Dock"; // Boat Dock
	// fd["E"]="Commercial Rental"; // For Rent-Commercial
	// fd["F"]="Residential Property"; //  Residential Factory Built
	// fd["C"]="Commercial Property"; //  Commercial Sale
	// fd["L"]="Residential Property"; //  Condotels
	// fd["N"]="Residential Rental"; //  For Rent-Residential-Resort
	// fd["O"]="Residential Property"; //  Condo
	// fd["I"]="Residential Income Property"; //  Residential Income
	// fd["U"]="Residential Property"; //  Single Unit of 2, 3, 4 plex
	// fd["T"]="Residential Property"; //  Townhomes
	// fd["V"]="Vacant Land"; //  Vacant Land
	// fd["P"]="Residential Property"; //  Co-Op
	// fd["R"]="Residential Property"; //  Single Family Site Built 
	// typeStruct=fd;
 
	fd=this.getRETSValues("property", "","PropertyType");
	for(i in fd){
		i2=i;
		if(i2 NEQ ""){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
	}

	// // county
	fd=this.getRETSValues("property", "","CountyOrParish");

	for(i in fd){
		i2=i;
		arrayappend(arrSQL,"('#this.mls_provider#','county','#application.zcore.functions.zescape(fd[i])#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
	}

	arrSubType=["UseAndPossibleUse","LandStyle","CommercialClass"];
	for(i2=1;i2 LTE arraylen(arrSubType);i2++){
		fd=this.getRETSValues("property", "", arrSubType[i2]);
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		} 
	} 
 
	// arrSubType=["WaterFeatures"];
	// for(i2=1;i2 LTE arraylen(arrSubType);i2++){
	// 	fd=this.getRETSValues("property", "", arrSubType[i2]); 
	// 	for(i in fd){
	// 		tmp=i;
	// 		arrayappend(arrSQL,"('#this.mls_provider#','view','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
	// 	} 
	// }  

	arrSubType=["WaterfrontFeatures"];
	for(i2=1;i2 LTE arraylen(arrSubType);i2++){
		fd=this.getRETSValues("property", "", arrSubType[i2]);
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		} 
	}  
 

	fd=this.getRETSValues("property", "","city"); 
	arrC=arraynew(1);
	failStr="";
	for(i in fd){
		tempState="FL"; 
		if(fd[i] NEQ "SEE REMARKS" and fd[i] NEQ "NOT AVAILABLE" and fd[i] NEQ "NONE"){
			 db.sql="select * from #db.table("city_rename", request.zos.zcoreDatasource)# city_rename 
			WHERE city_name =#db.param(fd[i])# and 
			state_abbr=#db.param(tempState)# and 
			city_rename_deleted = #db.param(0)#";
			qD2=db.execute("qD2");
			if(qD2.recordcount NEQ 0){
				fd[i]=qD2.city_renamed;
			}
			 db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# city 
			WHERE city_name =#db.param(fd[i])# and 
			state_abbr=#db.param(tempState)# and 
			city_deleted = #db.param(0)#";
			qD=db.execute("qD");
			if(qD.recordcount EQ 0){
				 db.sql="INSERT INTO #db.table("city", request.zos.zcoreDatasource)#  
				 SET city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
				 state_abbr=#db.param(tempState)#,
				 country_code=#db.param('US')#, 
				 city_mls_id=#db.param(i)#,
				 city_deleted=#db.param(0)#,
				 city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
				 result=db.insert("q"); 
				 db.sql="INSERT INTO #db.table("city_memory", request.zos.zcoreDatasource)#  
				 SET city_id=#db.param(result.result)#, 
				 city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
				 state_abbr=#db.param(tempState)#,
				 country_code=#db.param('US')#, 
				 city_mls_id=#db.param(i)# ,
				 city_deleted=#db.param(0)#,
				 city_updated_datetime=#db.param(request.zos.mysqlnow)#";
				 db.execute("q");
				cityCreated=true; // need to run zipcode calculations
			}
		}
		
		arrayClear(request.zos.arrQueryLog);
	} 
	return {arrSQL:arrSQL, cityCreated:cityCreated, arrError:arrError};
	</cfscript>
</cffunction>
    </cfoutput>
</cfcomponent>