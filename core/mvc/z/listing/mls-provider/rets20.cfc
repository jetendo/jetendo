<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<!--- 
download is throttled to 5000 records during the day
unlimited between 7pm and 5am hawaii time
1am to 11am eastern time
 --->
<cfoutput>	<cfscript>
	this.retsVersion="1.7";
	
	this.mls_id=20;
	this.useRetsFieldName="system";
	this.arrColumns=listtoarray("ActiveContinueToShowDate	ActiveOpenHouseCount	AdditionalParcelsYN	AdvertiseDate	Amenities	ArchitecturalStyle	AssociationCommunityName	AssociationFee	AssociationFee2	AssociationFee2Includes	AssociationFeeIncludes	AssociationFeeTotal	AssociationPhone	AuctionDate	BackOnMarketDate	BathsFull	BathsHalf	BathsTotal	BedsTotal	BuilderName	BuildingName	BuildingType	BusinessName	BusinessType	BusinessTypeDescription	BuyerFinancing	City	CloseDate	ClosePrice	CoListAgent_MUI	CoListAgentDirectWorkPhone	CoListAgentEmail	CoListAgentFullName	CoListAgentMLSID	CoListOffice_MUI	CoListOfficeMLSID	CoListOfficeName	CoListOfficePhone	CommercialSpacesNumberOf	CommercialSpaceYN	CompensationMethod	CompensationSubjectTo	Concessions	ConditionalDate	CondoParkingUnit	CondoPropertyRegimeYN	ConstructionMaterials	ConversionYear	Cooling	CoSellingAgent_MUI	CoSellingAgentDirectWorkPhone	CoSellingAgentEmail	CoSellingAgentFullName	CoSellingAgentMLSID	CoSellingOffice_MUI	CoSellingOfficeMLSID	CoSellingOfficeName	CoSellingOfficePhone	CountyOrParish	CropsIncludedYN	CurrentPrice	DaysOpenNumberOf	DepositAmount	Disclosures	DivisionName	Documents	DOM	DownPaymentResourceYN	DualVariableCompensationYN	Easements	ElementarySchool	ElevatorsFreightNumberOf	ElevatorsNumberOf	Employees	Exclusions	ExpensesInclude	ExpensesInformationSource	FeeOptions	FeePurchase	FloodZone	Flooring	FloorNumber	ForecloseureCivilCaseNumber	ForeclosureYN	ForeignCountryOrState	FractionalOwnershipYN	FranchiseFee	Furnished	GrossIncome	HighSchool	HoursOpen	Improvements	Inclusions	IncomeInformationSource	IsDeleted	LandlordName	LandlordPhone	LandRecorded	LandTenure	LandUse	LastChangeTimestamp	LaundryFacilities	LeaseExpirationDate	LeaseExpirationYear	LeaseFeeMonth	LeasePrice	LeaseRenegotiationDate	LeaseType	LessorName	LessorName2	ListAgent_MUI	ListAgentDirectWorkPhone	ListAgentEmail	ListAgentFullName	ListAgentMLSID	ListingAgreement	ListingContractDate	ListingFinancing	ListingService	ListOffice_MUI	ListOfficeMLSID	ListOfficeName	ListOfficePhone	ListPrice	Loading	Location	LockBoxYN	LotFeatures	LotSizeArea	LotSizeDimensions	MaintenanceExpense	ManagementCompanyName	ManagementCompanyPhone	Matrix_Unique_ID	MatrixModifiedDT	MiddleOrJuniorSchool	MLS	MLSAreaMajor	MLSNumber	Model	ModelSiteContactName	ModelSiteContactPhone	ModelSiteOpenHours	Neighbourhood	NetOperatingIncome	NewDevelopmentConstructionYN	NumberOfUnitsTotal	OccupantType	OffMarketDate	OpenHouseCount	OpenHouseUpcoming	OriginalEntryTimestamp	OriginalListPrice	OtherIncome	OtherParkingFeatures	OwnerOccupancyPercentage	OwnershipType	ParcelNumber	ParkingAdditional	ParkingFeatures	ParkingTotal	PendingDate	PermitAddressInternetYN	PermitInternetYN	PetsAllowed	PetsAllowedYN	PhotoCount	PhotoModificationTimestamp	PoolFeatures	Possession	PossibleUse	PostalCode	PostalCodePlus4	PriceChangeTimestamp	PrivateRemarks	ProjectPublicReportNumber	PropertyCondition	PropertyFrontage	PropertySubType	PropertyType	ProviderModificationTimestamp	PublicRemarks	PublicReportNumber	RecreationFacilities	Remodelled	RentalType	RentalUnitAvailableDate	RentStepUpMonthFirst	RentStepUpMonthSecond	RentYearFirst	RentYearSecond	ResidentManagerYN	Restrictions	RoadFrontage	Roof	RoomCount	Section8YN	SecurityFeatures	SellingAgent_MUI	SellingAgentDirectWorkPhone	SellingAgentEmail	SellingAgentFullName	SellingAgentMLSID	SellingAgentRemarks	SellingOffice_MUI	SellingOfficeMLSID	SellingOfficeName	SellingOfficePhone	SetBacks	Sewer	ShowingInstructions	SpecialListingConditions	SQFTBuilding	SQFTGarageCarport	SQFTInterior	SQFTLanaiCovered	SQFTLanaiOpen	SQFTOther	SQFTRoofedLiving	SQFTRoofedOther	SqftTotal	StandardIndustrialClassification	StateOrProvince	Status	StatusChangeTimestamp	StatusContractualSearchDate	Stories	StoriesType	StreetDirPrefix	StreetDirSuffix	StreetName	StreetNumber	StreetSuffix	StreetViewParam	StructuresPresentYN	StudioUnitsNumberOf	SubAgencyCompensation	SupplementCount	SupplementModificationTimestamp	Table	TaxAmount	TaxAssessedValue	TaxAssessedValueImprovements	TaxAssessedValueLand	TaxExcemptionOwnerOccupancy	TaxLot	TaxPaidBySellerYN	TaxYear	TempOffMarketDate	TemporarilyWithdrawnDate	TenantsResponsibilitiesIncludes	TMKArea	TMKCondoPropertyRegimeNumber	TMKDivision	TMKParcel	TMKPLAT	TMKSection	TMKZone	Topography	TotalActualRent	TotalAnnualOperatingExpenses	TotalIncome	UnitCount	UnitFeatures	UnitNumber	UnitOneBedNumberOf	UnitThreeBedNumberOf	UnitTwoBedNumberOf	Utilities	UtilitiesMeters	View	VirtualTourURLUnbranded	WithdrawnDate	YearBuilt	YearEstablished	YearRemodeled	Zoning",chr(9));
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/20/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/20/";
	}
	this.arrTypeLoop=listtoarray("COMM,MULT,LAND,RESI");
	this.mls_provider="rets20";
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
	/*resourceStruct["media"]=structnew();
	resourceStruct["media"].id="matrix_unique_id";
	resourceStruct["media"].resource="media";
	resourceStruct["media"].extraPrimaryKey="KEY `ExtraIndex1` (`rets20_table_id`,`rets20_table_mui`)";*/
	/*resourceStruct["openhouse"]=structnew();
	resourceStruct["openhouse"].id="matrix_unique_id";
	resourceStruct["openhouse"].resource="openhouse";*/
	/*
	ListAgentMLSID - foreign key to agent
	ListOfficeMLSID "" office
	rets20_listingmui 	mlsnumber
	*/
	this.sysidfield="rets20_matrix_unique_id";
	this.sysidfield2="rets20_propertytype";
	variables.cityRename=structnew();
	variables.cityRename["Captain"]="Captain Cook";
	variables.cityRename["Ewa"]="Ewa Beach";
	variables.cityRename["Kailu-kona"]="Kailua Kona";
	variables.cityRename["Kailua-kona"]="Kailua Kona";
	variables.cityRename["Kialua-kona"]="Kailua Kona";
	variables.cityRename["Mililani Town"]="Mililani";
	</cfscript> 
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript> 
		var columnIndex=structnew(); 
		var ts=structnew(); 
		
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.template.fail("rets20: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			if(arguments.ss.arrData[i] EQ '0'){
				arguments.ss.arrData[i]="";	
			}
			ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
		}
		if(structkeyexists(ts, "rets20_neighbourhood")){
			if(findnocase(","&ts["rets20_neighbourhood"]&",", ",,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["rets20_neighbourhood"]="";
			}else if(ts["rets20_neighbourhood"] NEQ ""){
				ts["rets20_neighbourhood"]=application.zcore.functions.zFirstLetterCaps(ts["rets20_neighbourhood"]);
			}
		}
		if(structkeyexists(ts,'rets20_originalentrytimestamp')){
			arguments.ss.listing_track_datetime=dateformat(ts.rets20_originalentrytimestamp,"yyyy-mm-dd")&" "&timeformat(ts.rets20_originalentrytimestamp, "HH:mm:ss");
		}
		arguments.ss.listing_track_updated_datetime=dateformat(ts.rets20_matrixmodifieddt,"yyyy-mm-dd")&" "&timeformat(ts.rets20_matrixmodifieddt, "HH:mm:ss");
		arguments.ss.listing_track_price=ts["rets20_OriginalListPrice"];
		if(arguments.ss.listing_track_price EQ "0"){
			arguments.ss.listing_track_price=ts.rets20_LISTPRICE;
		}
		arguments.ss.listing_track_price_change=ts.rets20_LISTPRICE;
		
		this.price=ts["rets20_LISTPRICE"];
		cityName="";
		cid=0;
		if(ts["rets20_city"] NEQ ""){
			if(structkeyexists(variables.cityRename, ts["rets20_city"])){
				ts["rets20_city"]=variables.cityRename[ts["rets20_city"]];
			}
			cityName=ts["rets20_city"]&"|"&ts["rets20_StateOrProvince"];
			if(structkeyexists(request.zos.listing.cityStruct, cityName)){
				cid=request.zos.listing.cityStruct[cityName];
			}
			cityName=ts["rets20_city"];
		}
		
		if(structkeyexists(ts,'rets20_PROPERTYCONDITION')){
			condition=this.listingLookupNewId("condition",ts.rets20_PROPERTYCONDITION);
		}else{
			condition="";
		}
		if(structkeyexists(ts,'rets20_ParkingFeatures')){
			parking=this.listingLookupNewId("parking",ts.rets20_ParkingFeatures);
		}else{
			parking="";
		}
		region=this.listingLookupNewId("region",ts.rets20_MLSAreaMajor);
		if(structkeyexists(ts,'rets20_landtenure')){
			tenure=this.listingLookupNewId("tenure",ts.rets20_landtenure);
		}else{
			tenure="";
		}
		
		local.listing_type_id=this.listingLookupNewId("listing_type",ts.rets20_PROPERTYTYPE);
		local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type",application.zcore.functions.zso(ts, 'rets20_PROPERTYSUBTYPE'));
		if(application.zcore.functions.zso(ts, 'rets20_permitaddressinternetyn') EQ "1"){
			ad=application.zcore.functions.zso(ts, 'rets20_streetnumber');
			if(ad NEQ 0){
				address="#ad# ";
			}else{
				address="";	
			}	
			
			address&=application.zcore.functions.zfirstlettercaps(trim(replace(ts.rets20_StreetDirPrefix&" "&ts.rets20_StreetName&" "&ts.rets20_StreetDirSuffix&" "&ts.rets20_StreetSuffix,"  "," ","all")));
			
			curLat="";
			curLong="";
				if(trim(address) NEQ ""){// and cityName NEQ ""){
					rs5=this.baseGetLatLong(address,ts.rets20_stateorprovince,ts.rets20_postalcode, arguments.ss.listing_id);
					if(rs5.success){
						curLat=rs5.latitude;
						curLong=rs5.longitude;
					}
				}
			if(application.zcore.functions.zso(ts, 'rets20_unitnumber') NEQ ''){
				address&=" Unit: "&ts["rets20_unitnumber"];	
			}
		}else{
			address="";
		}
		arrS=listtoarray(application.zcore.functions.zso(ts, 'rets20_SpecialListingConditions'),",");
		s=structnew();
		for(i=1;i LTE arraylen(arrS);i++){
			c=trim(arrS[i]);
			if(find(","&c&",",",SHOSAL,") NEQ 0){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
				break;
			}
			if(find(","&c&",",",FORECL,") NEQ 0){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
				break;
			}
			
		}
		
		arrS=listtoarray(application.zcore.functions.zso(ts, 'rets20_STATUS'),",");
		
		
		liststatus=ts.rets20_STATUS;
		s2=structnew();
		if(liststatus EQ "a"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
		}
		if(liststatus EQ "w"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["withdrawn"]]=true;
		}
		if(liststatus EQ "C"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active continue to show"]]=true;
		}
		if(liststatus EQ "t"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["temporarily withdrawn"]]=true;
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
		if(liststatus EQ "r"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["leased"]]=true;
		}
		if(liststatus EQ "i"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["incoming"]]=true;
		}
		
		if(application.zcore.functions.zso(ts, 'rets20_NewDevelopmentConstructionYN') EQ "1"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
		}
		if(application.zcore.functions.zso(ts, 'rets20_proptype') EQ "rnt"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else{
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		local.listing_status=structkeylist(s,",");
		local.listing_liststatus=structkeylist(s2,",");
		local.listing_style=this.listingLookupNewId("style",application.zcore.functions.zso(ts, 'rets20_ArchitecturalStyle'));
		
		// view & frontage
		arrT2=[];
		arrT3=[];
		
		tmp=application.zcore.functions.zso(ts, 'rets20_PROPERTYFRONTAGE');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("frontage",arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT3,tmp);
				}
			}
		}
		local.listing_frontage=arraytolist(arrT3);
		tmp=application.zcore.functions.zso(ts, 'rets20_VIEW');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("view",arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT2,tmp);
				}
			}
		}
		local.listing_view=arraytolist(arrT2);
		

		local.listing_pool=0;
		if(application.zcore.functions.zso(ts, 'rets20_POOLFeatures') NEQ "" or application.zcore.functions.zso(ts, 'rets20_Amenities') CONTAINS "HEAPOO" or application.zcore.functions.zso(ts, 'rets20_amenities') CONTAINS "POOL"){
			local.listing_pool=1;
		}
		
		
		livingsqfoot=application.zcore.functions.zso(ts, 'rets20_SQFTRoofedLiving');
		if(livingsqfoot EQ "" or livingsqfoot EQ "0"){
			livingsqfoot=application.zcore.functions.zso(ts, 'rets20_sqfttotal');
		}

		idx=ts;
		for(i10 in idx){
			column=i10;
			value=idx[column];
			if(value NEQ ""){
				fieldName=replacenocase(column,"rets20_","");
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
		local.arrDate=["originalentrytimestamp","matrixmodifieddt","ActiveContinueToShowDate","AdvertiseDate","AuctionDate","BackOnMarketDate","CloseDate","ConditionalDate","LeaseExpirationDate","LeaseRenegotiationDate","ListingContractDate","OffMarketDate","PendingDate","RentalUnitAvailableDate","StatusContractualSearchDate","TempOffMarketDate","TemporarilyWithdrawnDate","WithdrawnDate","OriginalEntryTimestamp","PhotoModificationTimestamp","PriceChangeTimestamp","StatusChangeTimestamp","SupplementModificationTimestamp"];
		for(local.i=1;local.i LTE arraylen(local.arrDate);local.i++){
			if(isDefined('idx.rets20_'&local.arrDate[local.i]) and isdate(idx["rets20_"&local.arrDate[local.i]])){ idx["rets20_"&local.arrDate[local.i]]=dateformat(idx["rets20_"&local.arrDate[local.i]],"m/d/yyyy");}
		}
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage="";
		rs.listing_baths=application.zcore.functions.zso(ts, 'rets20_bathsfull');
		rs.listing_halfbaths=application.zcore.functions.zso(ts, 'rets20_bathshalf');
		rs.listing_beds=application.zcore.functions.zso(ts, 'rets20_bedstotal');
		rs.listing_city=cid;
		rs.listing_county=application.zcore.functions.zso(ts, 'rets20_CountyOrParish');
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=ts.rets20_LISTPRICE;
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=ts.rets20_stateorprovince;
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet=application.zcore.functions.zso(ts, 'rets20_lotsizearea');
		rs.listing_square_feet=livingsqfoot;
		rs.listing_subdivision=application.zcore.functions.zso(ts, 'rets20_neighbourhood');
		rs.listing_year_built=application.zcore.functions.zso(ts, 'rets20_yearbuilt');
		rs.listing_office=ts.rets20_ListOfficeMLSID;
		rs.listing_agent=application.zcore.functions.zso(ts, 'rets20_ListAgentMLSID');
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=ts.rets20_photocount;
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="0";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_condoname=application.zcore.functions.zFirstLetterCaps(application.zcore.functions.zso(ts, 'rets20_BUILDINGNAME'));
		rs.listing_address=trim(address);
		rs.listing_zip=trim(ts.rets20_postalcode);
		rs.listing_condition=trim(condition);
		rs.listing_parking=trim(parking);
		rs.listing_region=trim(region);
		rs.listing_tenure=trim(tenure);
		rs.listing_liststatus=trim(local.listing_liststatus);
		rs.listing_data_remarks=ts.rets20_publicremarks;
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts.rets20_postalcode);
		rs.listing_data_detailcache1=listing_data_detailcache1;
		rs.listing_data_detailcache2=listing_data_detailcache2;
		rs.listing_data_detailcache3=listing_data_detailcache3;


		rs.listing_track_sysid=ts["rets20_matrix_unique_id"];
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
		request.lastPhotoId=idx.listing_id;
		idx.virtualtoururl="";
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		
		if(arguments.ss.listing_photocount EQ 0){
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
			
		}else{
			i=1;
			if(application.zcore.functions.zso(idx, "rets20_status") NEQ "A"){
				local.tempCount=1;
			}else{
				local.tempCount=arguments.ss.listing_photocount;
			}
			for(i=1;i LTE local.tempCount;i++){
				local.fNameTemp1=idx.listing_id&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				idx["photo"&i]=request.zos.retsPhotoPath&'20/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
			}
		}
		
		oid1="0";
		
		request.zos.tempObj.currentListingIdx=idx;
		
		idx.photowidth=460;
		idx.photoheight=304;
		
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, "rets20_postalcode");
		idx["maintfees"]=application.zcore.functions.zso(arguments.ss, "rets20_MaintenanceExpense");
		</cfscript>
        <cfsavecontent variable="details">     
		<table class="ztablepropertyinfo">   
        <!--- 
        <cfif structkeyexists(idx,'pdf1')>
            <tr><td colspan="2"><h3>PDFs Available For Download</h3></td></tr>
            <cfloop from="1" to="25" index="local.i">
                <cfif structkeyexists(idx, "pdf"&i)>
                <tr><th>PDF ###local.i#</th><th><a href="#idx["pdf"&i]#" target="_blank">#htmleditformat(idx["pdf_description"&i])#</a></th></tr>
                <cfelse>
                    <cfbreak>
                </cfif>
            </cfloop>
        </cfif> --->
        #idx.listing_data_detailcache1#
        #idx.listing_data_detailcache2#
        #idx.listing_data_detailcache3#
</table>
<cfif application.zcore.functions.zso(idx, "rets20_parcelnumber") NEQ "">
<h3><a href="http://www.honolulupropertytax.com/Forms/PrintDatalet.aspx?jur=000&amp;State=1&amp;item=1&amp;ranks=Datalet&amp;ownseq=1&amp;card=1&amp;pin=#htmleditformat(removechars(replace(idx.rets20_parcelnumber,"-","","all"),1,1))#&amp;gsp=PROFILEALL&amp;items=-1&amp;all=all" target="_blank" rel="nofollow">View Property Tax Records</a><h3>
</cfif>
        </cfsavecontent>
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
		local.fNameTemp1=this.mls_id&"-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		local.absPath='#request.zos.sharedPath#mls-images/20/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		if(fileexists(local.absPath)){
			return request.zos.retsPhotoPath&'20/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
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
		var g=0;
		fd=structnew();
		fd["BUS"]="Business";
		fd["com"]="Commercial/Industry";
		fd["PUD"]="Condo (PUD)";
		fd["CND"]="Condo";
		fd["FOR"]="Foreclosure";
		fd["lnd"]="Land";
		fd["RNT"]="Rental";
		fd["RES"]="Single Family";
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
			}
		}
		
		for(g=1;g LTE arraylen(this.arrTypeLoop);g++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"PROPERTYFRONTAGE");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','frontage','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"VIEW");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','view','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"PROPERTYSUBTYPE");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"ArchitecturalStyle");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','style','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"LANDTENURE");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','tenure','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"PROPERTYCONDITION");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','condition','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"MLSAreaMajor");
			s=structnew();
			s["DiamondHd"]="Diamond Head";
			s["ewaplain"]="Ewa Plain";
			s["Metro"]="Metro Oahu";
			s["PearlCity"]="Pearl City";
			s["Central"]="Central Oahu";
			s["leeward"]="Leeward Coast";
			for(i in fd){
				if(i NEQ ""){
					if(structkeyexists(s, fd[i])){
						fd[i]=s[fd[i]];
					}
					arrayappend(arrSQL,"('#this.mls_provider#','region','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
			/* i shouldn't have used this here...
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"LISTSTATUS");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','liststatus','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}*/
			fd=this.getRETSValues("property", this.arrTypeLoop[g],"PARKINGFEATURES");
			for(i in fd){
				if(i NEQ ""){
					arrayappend(arrSQL,"('#this.mls_provider#','parking','#trim(fd[i])#','#trim(i)#','#request.zos.mysqlnow#','#trim(i)#','#request.zos.mysqlnow#', '0')");
				}
			}
		}
		return {arrSQL:arrSQL, cityCreated:false, failStr:"", arrError:arrError};
		</cfscript>
	</cffunction>
    
    </cfoutput>
</cfcomponent>