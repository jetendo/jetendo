<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>	<cfscript>
	this.retsVersion="1.7";
	
	this.mls_id=21;
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/21/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/21/";
	}
	this.arrTypeLoop=listtoarray("listing_mrmls_resi,listing_mrmls_rinc,listing_mrmls_rlse,listing_mrmls_land,listing_mrmls_mobhomes");
	this.useRetsFieldName="system";
	this.arrColumns=listtoarray("Acres	ActualRentTotal	AdditionalDimensions	AdNumber	AgentRemarks	APN	Appliances	Area	Assessments	Association	AssociationDues1	AssociationDues1Frequency	AssociationDues2	AssociationDues2Frequency	AssociationName1	AssociationName2	AssociationPhone1	AssociationPhone1Ext	AssociationPhone2	AssociationPhone2Ext	AssociationYN	AttachedStructure	BasementSqft	Bath2	BathsFull	BathsHalf	BathsOqtr	BathsTotal	BathsTqtr	Bedrooms	BlockNumber	BuildersTractCode	BuildersTractName	CableTVExpense	CapRate	CashiersCheck	CDOM	CDOMResetYN	City	Cleared	CoLA_Board	CoLA_CarPhone	CoLA_CellPhone	CoLA_DirectPhone	CoLA_DirectPhoneExt	CoLA_DreLicenseNumber	CoLA_Fax	CoLA_FirstName	CoLA_HomePhone	CoLA_HomePhoneExt	CoLA_Languages	CoLA_LastName	CoLA_MUI	CoLA_Pager	CoLA_PublicID	CoLA_TollFreePhone	CoLA_TollFreePhoneExt	CoLA_Voicemail	CoLA_VoicemailExt	CoLo_Board	CoLo_Code	CoLO_DreLicenseNumber	CoLo_Fax	CoLo_Mui	CoLo_Name	CoLo_Phone	CoLo_PhoneExt	ConcessionsAmount	ConcessionsComments	ConstructionMaterials	ContactOrder1	ContactOrder2	ContactOrder3	ContactOrder4	ContactOrder5	ContactOrder6	Cooling	CoSA_Board	CoSA_DreLicenseNumber	CoSA_FirstName	CoSA_LastName	CoSA_MUI	CoSA_PublicID	CoSO_Board	CoSO_Code	CoSO_DreLicenseNumber	CoSO_MUI	CoSO_Name	Country	County	CreditAmount	CreditCheckPaidBy	CreditCheckYN	CrossStreets	CurrentGeologicalYN	DateCanceled	DateClosedSale	DateEnding	DateHoldActivation	DateLandLeaseExp	DateLandLeaseRenew	DateLeaseBegins	DateLeased	DateListingContract	DatePurchaseContract	DateStatusChange	DeletedYN	DepositKey	DepositOther	DepositPets	DepositSecurity	Disclosures	DistanceToBus	DistanceToChurches	DistanceToElectric	DistanceToFreeway	DistanceToGas	DistanceToPhoneService	DistanceToSchools	DistanceToSewer	DistanceToStores	DistanceToStreet	DistanceToWater	DocumentNumber	DOH1	DOH2	DOH3	DOM	DrivingDirections	DualVariableCompensation	EatingArea	ElectricExpense	Elevation	EntryLocation	Fencing	FinancialInfoAsOf	FinancialRemarks	Financing	Fireplace	FirstRepairs	Floor	Foundation	Furnished	FurnitureExpense	GarageAttached	GarageIncome	GarageRentalRate	GarageSpaces	GardenerExpense	GasExpense	GreenBuildingCertification	GreenCertificationRating	GreenCertifyingBody	GreenEnergyEfficient	GreenEnergyGeneration	GreenHTAindex	GreenIndoorAirQuality	GreenLocation	GreenSustainability	GreenWalkScore	GreenWaterConservation	GreenYearCertified	GrossEquity	GrossMultiplier	GrossOperatingIncome	GrossScheduledIncome	GrossSpendableIncome	Have	Heating	Improvements	ImprovementsAmount	ImprovementsPercent	IncomeOtherDesc	IngressEgress	InsuranceExpense	InsuranceWaterFurnitureYN	InteriorFeatures	InternetSendAddressYN	InternetSendListingYN	KeySafeDescription	KeySafeLocation	LA_Board	LA_CarPhone	LA_CellPhone	LA_DirectPhone	LA_DirectPhoneExt	LA_DreLicenseNumber	LA_Fax	LA_FirstName	LA_HomePhone	LA_HomePhoneExt	LA_Languages	LA_LastName	LA_MUI	LA_Pager	LA_PublicID	LA_TollFreePhone	LA_TollFreePhoneExt	LA_Voicemail	LA_VoicemailExt	LandFeeLease	LandLeaseAmount	LandLeasePurchaseYN	LandLeaseTransferFee	LandValue	LandValuePercent	Latitude	Laundry	LaundryEquipment	LaundryIncome	LeaseConsideredYN	LeasePerMonthYear	Length	License1	License2	License3	LicensesExpense	Listing_Board	ListingChangeType	ListingPaidYN	ListingTerms	ListingType	ListPrice	ListPriceExcludes	ListPriceIncludes	ListPriceLow	ListPriceOriginal	LO_Board	LO_Code	LO_DreLicenseNumber	LO_Fax	LO_MUI	LO_Name	LO_Phone	LO_PhoneExt	LoanPayment	Longitude	LotDimensions	LotNumber	LotSquareFootage	MaintenanceExpense	MaintenancePercent	Make	ManagementCo	ManagementCoPhone	ManagementCoPhoneExt	ManagementExpense	ManagerApprovalYN	ManagerName	ManagersFax	ManagersPhone	ManagersPhoneExt	Matrix_Unique_ID	MLnumber	MLS_ID	MobileToRemain	Model	ModelCode	ModelName	MonthlyGrossIncome	NetOperatingIncome	NewTaxesExpense	NotIncluded	NumberCarpet	NumberCarportSpaces	NumberDishwasher	NumberDisposal	NumberDrapes	NumberElectricMeters	NumberGarageSpaces	NumberGasMeters	NumberLeased	NumberOfBuildings	NumberParkingSpaces	NumberPatio	NumberRange	NumberRefrigerator	NumberRemotes	NumberRentedGarages	NumberSheds	NumberSpaces	NumberUnits	NumberWallAC	NumberWaterMeters	OccupantType	OperatingExpense	OperatingExpensePercent	OtherExpense	OtherExpenseDescription	OtherIncome1	OtherIncome2	OtherPhoneDescription	OtherPhoneExt	OtherPhoneNumber	OwnersName	ParcelMapNumber	ParcelNumber	Parking	ParkingSpacesTotal	ParkName	ParkType	Patio	PersonalPropertyAmount	PersonalPropertyPercent	PestExpense	PetsAllowed	PhotoNotes	PicCount	Points	Pool	PoolExpense	PoolYN	Possession	PossibleNewZone	PostalCode	PostalCodePlus4	PotentialUsage	PresentLoans	PresentUse	PricePerSqft	PricePerUnit	ProfessionalManagement	ProFormaRentTotal	PropertyDescription	PropertySubType	RenewalPurchaseComp	RentControlYN	RentIncludes	Roofing	Rooms	RVAccessDimensions	RVParkingFee	SA_Board	SA_DreLicenseNumber	SA_FirstName	SA_LastName	SA_MUI	SA_PublicID	SaleType	SaleYN	SchoolDistrict	SchoolElementary	SchoolHigh	SchoolJuniorHigh	SecurityExpense	SellingOfficeCompensation	SellingOfficeCompensationRemarks	SellingPrice	SeniorYN	SerialU	SerialX	SerialXX	ServiceType	Show	ShowingContactName	ShowingContactPhone	ShowingContactPhoneExt	ShowingContactType	SignOnPropertyYN	Skirt	SO_Board	SO_Code	SO_DreLicenseNumber	SO_MUI	SO_Name	SOCompPer	SOCompType	SoilType	SoldCapRate	SoldTerms	Spa	SpaceNumber	SpecialAssessments	SqFtSourceLot	SqFtSourceStructure	SquareFootage1Bedroom	SquareFootage2Bedroom	SquareFootage3Bedroom	SquareFootageBuilding	SquareFootageStructure	SquareFootageStudio	State	Status	Stories	StreetDirection	StreetDirectionSuffix	StreetName	StreetNumber	StreetNumberModifier	StreetSuffix	StreetSuffixModifier	Style	SupplementCount	SuppliesExpense	Survey	TaxArea	TaxesPercent	TaxesTotal	TaxRate	TaxRateTotal	TaxRateYear	TaxTotal	TenantPays	Terms	ThomasGuide	TimestampModified	TimestampOffMarket	TimestampOriginalEntry	TimestampPhotoModified	TimestampStatusChange	Topography	TotalExpenses	TotalMoveInCosts	TractMap	TractName	TractNumber	TractSubAreaCode	TransferFee	TransferFeePaidBy	TrashExpense	Trees	Type10ActualRent	Type10Baths	Type10Bedrooms	Type10Furnished	Type10GarageAttached	Type10GarageSpaces	Type10ProFormaRent	Type10TotalRent	Type10Units	Type11ActualRent	Type11Baths	Type11Bedrooms	Type11Furnished	Type11GarageAttached	Type11GarageSpaces	Type11ProFormaRent	Type11TotalRent	Type11Units	Type12ActualRent	Type12Baths	Type12Bedrooms	Type12Furnished	Type12GarageAttached	Type12GarageSpaces	Type12ProFormaRent	Type12TotalRent	Type12Units	Type13ActualRent	Type13Baths	Type13Bedrooms	Type13Furnished	Type13GarageAttached	Type13GarageSpaces	Type13ProFormaRent	Type13TotalRent	Type13Units	Type1ActualRent	Type1Baths	Type1Bedrooms	Type1Furnished	Type1GarageAttached	Type1GarageSpaces	Type1ProFormaRent	Type1TotalRent	Type1Units	Type2ActualRent	Type2Baths	Type2Bedrooms	Type2Furnished	Type2GarageAttached	Type2GarageSpaces	Type2ProFormaRent	Type2TotalRent	Type2Units	Type3ActualRent	Type3Baths	Type3Bedrooms	Type3Furnished	Type3GarageAttached	Type3GarageSpaces	Type3ProFormaRent	Type3TotalRent	Type3Units	Type4ActualRent	Type4Baths	Type4Bedrooms	Type4Furnished	Type4GarageAttached	Type4GarageSpaces	Type4ProFormaRent	Type4TotalRent	Type4Units	Type5ActualRent	Type5Baths	Type5Bedrooms	Type5Furnished	Type5GarageAttached	Type5GarageSpaces	Type5ProFormaRent	Type5TotalRent	Type5Units	Type6ActualRent	Type6Baths	Type6Bedrooms	Type6Furnished	Type6GarageAttached	Type6GarageSpaces	Type6ProFormaRent	Type6TotalRent	Type6Units	Type7ActualRent	Type7Baths	Type7Bedrooms	Type7Furnished	Type7GarageAttached	Type7GarageSpaces	Type7ProFormaRent	Type7TotalRent	Type7Units	Type8ActualRent	Type8Baths	Type8Bedrooms	Type8Furnished	Type8GarageAttached	Type8GarageSpaces	Type8ProFormaRent	Type8TotalRent	Type8Units	Type9ActualRent	Type9Baths	Type9Bedrooms	Type9Furnished	Type9GarageAttached	Type9GarageSpaces	Type9ProFormaRent	Type9TotalRent	Type9Units	TypeOfMobileHome	UnitNumber	UsableLandPercent	Utilities	VacancyAllowDollar	VacancyAllowPercent	View	VirtualTour	VOWAutomatedValuationDisplay	VOWConsumerComment	WaterDistrictName	WaterSewerExpense	WaterTableDepth	WaterWellYN	WellDepth	WellGallonsPerMinute	WellHoleSize	WellPumpHorsepower	WellReportYN	Width	WorkersCompensation	YearBuilt	YearBuiltSource	ZipCode	ZipCodePlus4	Zone",chr(9));
	this.arrFieldLookupFields=arraynew(1);
	this.mls_provider="rets21";
	//this.sysidfield="";
	resourceStruct=structnew();
	resourceStruct["property"]=structnew();
	resourceStruct["property"].resource="property";
	resourceStruct["property"].id="MLnumber";
	this.emptyStruct=structnew();
	</cfscript> 
    
    <cffunction name="initImport" localmode="modern" output="no" returntype="any">
    	<cfargument name="resource" type="string" required="yes">
        <cfargument name="sharedStruct" type="struct" required="yes">
    	<cfscript>
		
		super.initImport(arguments.resource, arguments.sharedStruct);
		arguments.sharedStruct.lookupStruct.cityRenameStruct=structnew();
		</cfscript>
        
    </cffunction>
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
        <cfargument name="optionStruct" type="struct" required="yes">
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
		var idx=0;
		var datacom=0;
		var values=0;
		var ts=0;
		var col=0;
		var rs=0;
		var i10=0;
		var s2=0;
		var liststatus=0;
		var shortColumn=0;
		var value=0;
		if(structcount(this.emptyStruct) EQ 0){
			for(i=1;i LTE arraylen(this.arrColumns);i++){
				this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
			}
		}
		ts=duplicate(this.emptyStruct);
		/*
		
		wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '11-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '11-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '11-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '11-%'; 
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
			ts["rets21_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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
		ts["rets21_listprice"]=replace(ts["rets21_listprice"],",","","ALL");
		
		
		local.listing_subdivision=application.zcore.functions.zFirstLetterCaps(application.zcore.functions.zso(ts, "rets21_BuildersTractName"));
		if(findnocase(","&local.listing_subdivision&",", ",false,none,not on the list,not in a development,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") EQ 0 and local.listing_subdivision NEQ ""){
			local.listing_subdivision=application.zcore.functions.zFirstLetterCaps(local.listing_subdivision);
			local.listing_subdivision=local.listing_subdivision;
		// may be other fields to display
		}
		local.listing_region=application.zcore.functions.zFirstLetterCaps(this.listingLookupNewId("listing_region",ts['area']));
		
		local.curClass="";
		if(arguments.optionstruct.filepath CONTAINS "listings-income"){
			local.curClass="listing_mrmls_rinc";
			local.listing_type_id=this.listingLookupNewId("listing_type","income");
			local.totalBaths=0;
			local.totalBeds=0;
			for(i=1;i LTE 13;i++){
				if(structkeyexists(ts, 'rets21_Type'&i&'Baths') and isnumeric(ts['rets21_Type'&i&'Baths'])){
					local.totalBaths+=ts['rets21_Type'&i&'Baths'];
				}
				if(structkeyexists(ts, 'rets21_Type'&i&'Beds') and isnumeric(ts['rets21_Type'&i&'Beds'])){
					local.totalBeds+=ts['rets21_Type'&i&'Beds'];
				}
			}
			ts["rets21_bathshalf"]=0;
			ts["rets21_bathsfull"]=local.totalBaths;
			ts["rets21_bedrooms"]=local.totalBeds;
		}else if(arguments.optionstruct.filepath CONTAINS "listings-residential"){
			local.curClass="listing_mrmls_resi";
			local.listing_type_id=this.listingLookupNewId("listing_type","residential");
			ts["rets21_squarefootagebuilding"]=application.zcore.functions.zso(ts,"rets21_squarefootagestructure");
		}else if(arguments.optionstruct.filepath CONTAINS "listings-land"){
			local.curClass="listing_mrmls_land";
			local.listing_type_id=this.listingLookupNewId("listing_type","land");
			ts["rets21_bathshalf"]=0;
			ts["rets21_bathsfull"]=0;
			ts["rets21_bedrooms"]=0;
			ts["rets21_squarefootagebuilding"]="";
		}else if(arguments.optionstruct.filepath CONTAINS "listings-lease"){
			local.curClass="listing_mrmls_rlse";
			local.propertyType="lease";
			local.listing_type_id=this.listingLookupNewId("listing_type","lease");
			ts["rets21_squarefootagebuilding"]=application.zcore.functions.zso(ts,"rets21_squarefootagestructure");
			ts["rets21_bathshalf"]=application.zcore.functions.zso(ts,"rets21_bathshalf",false,0);
			ts["rets21_bathsfull"]=application.zcore.functions.zso(ts,"rets21_bathsfull",false,0);
			ts["rets21_bedrooms"]=application.zcore.functions.zso(ts,"rets21_bedrooms",false,0);
		}else if(arguments.optionstruct.filepath CONTAINS "listings-mobile"){
			local.curClass="listing_mrmls_mobhomes";
			local.listing_type_id=this.listingLookupNewId("listing_type","mobile");	
			ts["rets21_squarefootagebuilding"]=application.zcore.functions.zso(ts,"rets21_squarefootagestructure");
		}else{
			application.zcore.template.fail("Invalid file name.  Must be a matching property type.");
		}
		
		this.price=ts["rets21_listprice"];
		local.listing_price=ts["rets21_listprice"]; 
		cid=0;
		cityName=this.getRetsValue("property", local.curClass, "city", ts["city"]);
		
		// state might need to be converted from id lookup value
		if(ts['rets21_state'] EQ 'OS'){
			ts["rets21_state"]='CA';
		}
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["rets21_state"])){
			cid=request.zos.listing.cityStruct[cityName&"|"&ts["rets21_state"]];
		}
		local.listing_county=this.listingLookupNewId("county",ts['county']);
		 /*
		if( ts["city"] NEQ 'OS' and (cid EQ 0 or local.listing_county EQ "")){
			writedump(ts["city"]&" | "&ts['county']&" | "&ts["rets21_state"]);
			abort;	
		}*/
		local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type",application.zcore.functions.zso(ts,'rets21_propertysubtype'));
		
		liststatus=ts.rets21_status;
		s2=structnew();
		if(liststatus EQ "a"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
		}
		if(liststatus EQ "w"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["withdrawn"]]=true;
		}
		if(liststatus EQ "c"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active continue to show"]]=true;
		}
		if(liststatus EQ "p"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["pending"]]=true;
		}
		if(liststatus EQ "x"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["expired"]]=true;
		}
		if(liststatus EQ "s"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["sold"]]=true;
		}
		/*
		not implemented:
		<MetadataEntryID>2</MetadataEntryID><LongValue>Backup Offer</LongValue><ShortValue>B</ShortValue><Value>B</Value></LookupType>
		<LookupType>
		<MetadataEntryID>4</MetadataEntryID><LongValue>First Right Of Refusal</LongValue><ShortValue>F</ShortValue><Value>F</Value></LookupType>
		<LookupType>
		<MetadataEntryID>5</MetadataEntryID><LongValue>Hold Do Not Show</LongValue><ShortValue>H</ShortValue><Value>H</Value></LookupType>
		<LookupType>
		<MetadataEntryID>6</MetadataEntryID><LongValue>Canceled</LongValue><ShortValue>K</ShortValue><Value>K</Value></LookupType>
		<LookupType>
		<MetadataEntryID>7</MetadataEntryID><LongValue>Leased</LongValue><ShortValue>L</ShortValue><Value>L</Value></LookupType>
		<LookupType>>*/
		
		local.listing_liststatus=structkeylist(s2,",");
		
		local.propertyType="";

		
		if((structkeyexists(ts, "Send Address to the Internet") and ts["Send Address to the Internet"] EQ "N") or (structkeyexists(ts, "Send Address to Internet") and ts["Send Address to Internet"] EQ "N")){
			ts["street number"]="";
			ts["street name"]="";
			ts["street direction"]="";
			ts["street suffix"]="";
			ts["rets21_unitnumber"]="";
		}
		
		address=application.zcore.functions.zFirstLetterCaps(application.zcore.functions.zso(ts,"street number")&" "&application.zcore.functions.zso(ts,"street name")&" "&application.zcore.functions.zso(ts,"street direction")&" "&application.zcore.functions.zso(ts,"street suffix"));
		curLat='';
		curLong='';
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts['rets21_state'],ts['rets21_zipcode'], arguments.ss.listing_id);
			if(rs5.success){
				curLat=rs5.latitude;
				curLong=rs5.longitude;
			}
		}
		
		if(structkeyexists(ts, 'rets21_unitnumber') and ts['rets21_unitnumber'] NEQ ''){
			address&=" Unit: "&ts["rets21_unitnumber"];	
		}
		
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=application.zcore.functions.zso(ts,'rets21_yearbuilt');
		ts2.foreclosureField="";
		
		s=this.processRawStatus(ts2);
		
		if(ts['rets21_SaleType'] EQ 'SPAY'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}
		if(ts['rets21_SaleType'] EQ 'REO'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}
		if(ts['rets21_SaleType'] EQ 'FOR'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
		if(ts['rets21_SaleType'] EQ 'ATN'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["auction"]]=true;
		}
		
		if(local.propertyType EQ "lease"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else{
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		local.listing_status=structkeylist(s,",");
		
		arrT3=[];
		if(structkeyexists(ts, 'rets21_style')){
			uns=structnew();
			tmp=ts['rets21_style'];
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
		}
		local.listing_style=arraytolist(arrT3);
		
		
		
		if(structkeyexists(ts,'rets21_landfeelease')){
			local.tenure=this.listingLookupNewId("tenure",ts.rets21_landfeelease);
		}else{
			local.tenure="";
		}
		
		// view & frontage
		arrT3=[];
		
		arrT2=[]; 
		if(structkeyexists(ts, 'rets21_parking')){
			uns=structnew();
			tmp=ts['rets21_parking'];
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
		}
		local.parking=arraytolist(arrT2);
		
		/*
		uns=structnew();
		tmp=ts['Waterfront Description'];
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
		*/
		local.listing_frontage="";
		
		arrT2=[]; 
		if(structkeyexists(ts, 'rets21_view')){
			uns=structnew();
			tmp=ts['rets21_view'];
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
		}
		local.listing_view=arraytolist(arrT2);
		

		local.listing_pool=0;
		if((structkeyexists(ts, 'rets21_poolyn') and ts["rets21_PoolYN"] EQ "Y") or (structkeyexists(ts, 'rets21_pool') and ","&ts.rets21_pool&"," DOES NOT CONTAIN ",no,")){
			local.listing_pool=1;	
		}
		
		if(ts["rets21_state"] EQ ""){
			local.state="CA";
		}else{
			local.state=ucase(ts["rets21_state"]);
		}
		idx=ts;
		for(i10 in idx){
			if(isdefined('idx.#i10#') EQ false){
				idx[i10]="";	
			}
			value=idx[i10];
			shortColumn=replace(i10,"rets21_","");
			if(len(value) NEQ 0){
				if(left(i10,8) NEQ 'listing_' and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup, shortColumn)){
					arrV=listtoarray(trim(replace(value,'"','','all')),',',false);
					arrV2=arraynew(1);
					for(n=1;n LTE arraylen(arrV);n++){
						t2=replace(arrV[n]," ","","ALL");
						t3=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].typeStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup[shortColumn]].valueStruct;
						if(structkeyexists(t3, t2)){
							t1=application.zcore.functions.zfirstlettercaps(t3[t2]);
						}else{
							t1="";	
						}
						if(t1 NEQ ""){
							arrayappend(arrV2,t1);
						}
					}
					idx[i10]=arraytolist(arrV2,", ");
				}
			}
		}
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage=ts["rets21_acres"];
		rs.listing_baths=ts["rets21_bathsfull"];
		rs.listing_halfbaths=ts["rets21_bathshalf"];
		rs.listing_beds=ts["rets21_bedrooms"];
		rs.listing_city=cid;
		rs.listing_county=local.listing_county;
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=ts["rets21_listprice"];
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=local.state;
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet=ts["rets21_lotsquarefootage"];
		rs.listing_square_feet=ts["rets21_squarefootagebuilding"];
		rs.listing_subdivision=local.listing_subdivision;
		rs.listing_year_built=application.zcore.functions.zso(ts,"rets21_yearbuilt");
		rs.listing_office=ts["rets21_lo_code"];
		rs.listing_agent=ts["rets21_la_publicid"];
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=ts["rets21_piccount"];
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="0";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_condoname="";
		rs.listing_address=trim(address);
		rs.listing_zip=ts["rets21_zipcode"];
		rs.listing_condition="";
		rs.listing_parking=local.parking;
		rs.listing_region=local.listing_region;
		rs.listing_tenure=local.tenure;
		rs.listing_liststatus=local.listing_liststatus;
		rs.listing_data_remarks=ts["rets21_propertydescription"];
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts["zip code"]);
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
		var q1=0;
		var t1=0;
		var t3=0;
		var t2=0;
		var i=0;
		var t99=0;
		var t44444=0;
		var details=0;
		var i10=0;
		var value=0;
		var n=0;
		var column=0;
		var arrV=0;
		var arrV2=0;
		var idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails);
		t99=gettickcount();
		idx["features"]="";
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		t44444=0;
		request.lastPhotoId=idx.listing_id;//this.mls_id&"-"&idx.rets21_sysid;
		if(idx.listing_photocount EQ 0){
			// check for permanent images or show not available image.
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
		}else{
			i=1;
			for(i=1;i LTE idx.listing_photocount;i++){
				local.fNameTemp1=removechars(idx.listing_id,1,3)&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				if(i EQ 1){
					idx["photo"&i]="http://mlsimage.fnisrediv.com/ListingImages/camrmls/images/"&removechars(idx.listing_id,1,3)&".jpg";
				}else{
					idx["photo"&i]="http://mlsimage.fnisrediv.com/ListingImages/camrmls/addl_picts/"&removechars(idx.listing_id,1,3)&"-"&(i-1)&".jpg";
				}
			}
		}
		idx["agentName"]=application.zcore.functions.zso(idx, "rets21_la_firstname")&" "&application.zcore.functions.zso(idx, "rets21_la_lastname");
		idx["agentPhone"]="";
		idx["agentEmail"]="";
		idx["officeName"]=application.zcore.functions.zso(idx, "rets21_lo_name");
		idx["officePhone"]="";
		idx["officeCity"]="";
		idx["officeAddress"]="";
		idx["officeZip"]="";
		idx["officeState"]="";
		idx["officeEmail"]="";
			
		idx["virtualtoururl"]=application.zcore.functions.zso(idx, "rets21_virtualtour");
		idx["zipcode"]=application.zcore.functions.zso(idx, "rets21_zipcode");
		idx["maintfees"]="";
		if(application.zcore.functions.zso(idx, "rets21_maintenanceexpense") NEQ ""){
			idx["maintfees"]=application.zcore.functions.zso(idx, "rets21_maintenanceexpense");
		}
		
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
        <!--- <cfargument name="sysid" type="numeric" required="no" default="0"> --->
    	<cfscript>
		var qId=0;
		
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		if(arguments.num EQ 1){
			return "http://mlsimage.fnisrediv.com/ListingImages/camrmls/images/"&arguments.mls_pid&".jpg";
		}else{
			return "http://mlsimage.fnisrediv.com/ListingImages/camrmls/addl_picts/"&arguments.mls_pid&"-"&(arguments.num-1)&".jpg";
		}
		//return request.zos.retsPhotoPath&'21/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		</cfscript>
    </cffunction>
	
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript> 
		var arrSQL=[];
		var db=request.zos.queryObject; 
		var arrError=[]; 
		var failStr="";
		var cityCreated=false; 
		fd=structnew();
		fd["income"]="Income";
		fd["residential"]="Residential";
		fd["land"]="Land";
		fd["lease"]="Lease";
		fd["mobile"]="Mobile";
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
			}
		}
		for(g=1;g LTE arraylen(this.arrTypeLoop);g++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"view");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','view','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"type");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"STYLE");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','style','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"landfeelease");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','tenure','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"county");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','county','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"area");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','region','#application.zcore.functions.zescape(trim(fd[i]))#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"PARKING");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','parking','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			 
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"city");
			//application.zcore.functions.zdump(fd);
			//writeoutput(structcount(fd)&'<br />');
			//arrC=arraynew(1);
			failStr="";
			for(i in fd){
				tempState="CA";
				if(fd[i] EQ "Las Vegas"){
					tempState="NV";
				}
				 db.sql="select * from #db.table("city_rename", request.zos.zcoreDatasource)# city_rename 
				WHERE city_name =#db.param(fd[i])# and 
				state_abbr=#db.param(tempState)# and 
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
						city_longitude=#db.param(qZ.zipcode_longitude)#, 
						city_latitude=#db.param(qZ.zipcode_latitude)#,
					 	city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
						rs=db.insert("q", request.zOS.insertIDColumnForSiteIDTable); 
						 db.sql="INSERT INTO #db.table("city_memory", request.zos.zcoreDatasource)#  
						 SET city_id=#db.param(rs.result)#, 
						 city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
						 state_abbr=#db.param(tempState)#,
						 country_code=#db.param('US')#, 
						 city_mls_id=#db.param(i)#, 
					 city_deleted=#db.param(0)#,
						 city_longitude=#db.param(qZ.zipcode_longitude)#, 
						 city_latitude=#db.param(qZ.zipcode_latitude)#,
					 	city_updated_datetime=#db.param(request.zos.mysqlnow)#  ";
						db.insert("q", request.zOS.insertIDColumnForSiteIDTable); 
						//writeoutput("created #i#: "&city_id&"<br>");
						cityCreated=true; // need to run zipcode calculations
					}else{
						db.sql="INSERT INTO #db.table("city", request.zos.zcoreDatasource)#  
						SET city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
						state_abbr=#db.param(tempState)#,
						country_code=#db.param('US')#, 
						city_mls_id=#db.param(i)#,
					 city_deleted=#db.param(0)#,
						 city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
						city_id=db.insert("q", request.zOS.insertIDColumnForSiteIDTable); 
						//writeoutput('Missing: #fd[i]#, california<br />');
						//arrayAppend(arrError, "<a href=""http://maps.google.com/maps?q=#urlencodedformat(fd[i]&', california')#"" rel=""external"" onclick=""window.open(this.href); return false;"">#fd[i]#, california</a> is missing in `#request.zos.zcoreDatasource#`.zipcode.<br />");
					}
				}
				arrayClear(request.zos.arrQueryLog);
			} 
		}
		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>