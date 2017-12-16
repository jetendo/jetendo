<cfcomponent>
<cfoutput>
	<cfscript>
    variables.idxExclude=structnew();
	variables.allfields=structnew();
    </cfscript>
	<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" access="remote" roles="member" output="yes" returntype="any">
    	<cfscript>
	application.zcore.listingCom.makeListingImportDataReady();
	idxExclude={};
	tf=application.zcore.listingStruct.mlsStruct["30"].sharedStruct.metaStruct["property"].tableFields;
	n=0;
	for(curField in tf){  
		f2=tf[curField].longname; 
		n++;
		variables.allfields[n]={field:"rets30_"&curField, label:f2};
	}
idxExclude["rets30_AddressInternetDisplay"]="Address Internet Display";
idxExclude["rets30_AgentAlternatePhone"]="Agent Alternate Phone";
idxExclude["rets30_AgentLicenseNum"]="Agent License Num";
idxExclude["rets30_AgentsOfficeExtension"]="Agents Office Extension";
idxExclude["rets30_BonusAmount"]="Bonus Amount";
idxExclude["rets30_BonusYN"]="Bonus YN";
idxExclude["rets30_BoardIdentifier"]="Board Identifier";
idxExclude["rets30_BrokerRemarks"]="Broker Remarks";
idxExclude["rets30_CoAgentLicenseNum"]="Co Agent License Num";
idxExclude["rets30_CoListAgentDirectWorkPhone"]="Co List Agent Direct Work Phone";
idxExclude["rets30_CoListAgentEmail"]="Co List Agent Email";
idxExclude["rets30_CoListAgentFullName"]="Co List Agent Full Name";
idxExclude["rets30_CoListAgentMLSID"]="Co List Agent MLSID";
idxExclude["rets30_CoListAgent_MUI"]="Co List Agent MUI";
idxExclude["rets30_CoListOfficeMLSID"]="Co List Office MLSID";
idxExclude["rets30_CoListOffice_MUI"]="Co List Office MUI";
idxExclude["rets30_CoListOfficeName"]="Co List Office Name";
idxExclude["rets30_CoListOfficePhone"]="Co List Office Phone";
idxExclude["rets30_ComptoBuyersAgent"]="Compto Buyers Agent";
idxExclude["rets30_ComptoNonRepresentative"]="Compto Non Representative";
idxExclude["rets30_ComptoTransactionBroker"]="Compto Transaction Broker";
idxExclude["rets30_CoSellAgentLicenseNum"]="Co Sell Agent License Num";
idxExclude["rets30_CoSellingAgentDirectWorkPhone"]="Co Selling Agent Direct Work Pho";
idxExclude["rets30_CoSellingAgentEmail"]="Co Selling Agent Email";
idxExclude["rets30_CoSellingAgentFullName"]="Co Selling Agent Full Name";
idxExclude["rets30_CoSellingAgentMLSID"]="Co Selling Agent MLSID";
idxExclude["rets30_CoSellingAgent_MUI"]="Co Selling Agent MUI";
idxExclude["rets30_CoSellingOfficeMLSID"]="Co Selling Office MLSID";
idxExclude["rets30_CoSellingOffice_MUI"]="Co Selling Office MUI";
idxExclude["rets30_CoSellingOfficeName"]="Co Selling Office Name";
idxExclude["rets30_CoSellingOfficePhone"]="Co Selling Office Phone";
idxExclude["rets30_IDXOptInYN"]="IDX Opt In YN";
idxExclude["rets30_InputBrokerRemarks"]="Input Broker Remarks";
idxExclude["rets30_InternetRemarks"]="Internet Remarks";
idxExclude["rets30_InternetYN"]="Internet YN";
idxExclude["rets30_IsDeleted"]="Is Deleted";
idxExclude["rets30_ListAgentDirectWorkPhone"]="List Agent Direct Work Phone";
idxExclude["rets30_ListAgentEmail"]="List Agent Email";
idxExclude["rets30_ListAgentFullName"]="List Agent Full Name";
idxExclude["rets30_ListAgentMLSID"]="List Agent MLSID";
idxExclude["rets30_ListAgent_MUI"]="List Agent MUI";
idxExclude["rets30_ListingContractDate"]="Listing Contract Date";
idxExclude["rets30_ListingType"]="Listing Type";
idxExclude["rets30_ListOfficeMLSID"]="List Office MLSID";
idxExclude["rets30_ListOffice_MUI"]="List Office MUI";
idxExclude["rets30_ListOfficeName"]="List Office Name";
idxExclude["rets30_ListOfficePhone"]="List Office Phone";
idxExclude["rets30_ManagementCompany"]="Management Company";
idxExclude["rets30_ManagementCompanyPhone"]="Management Company Phone";
idxExclude["rets30_MatrixModifiedDT"]="Matrix Modified DT";
idxExclude["rets30_Matrix_Unique_ID"]="Matrix Unique ID";
idxExclude["rets30_RATIO_ClosePrice_By_ListPrice"]="RATIO Close Price By List Price";
idxExclude["rets30_SaleTerms"]="Sale Terms";
idxExclude["rets30_SellerContributionsAmt"]="Seller Contributions Amt";
idxExclude["rets30_SellerContributionsYN"]="Seller Contributions YN";
idxExclude["rets30_SellingAgentDirectWorkPhone"]="Selling Agent Direct Work Phone";
idxExclude["rets30_SellingAgentEmail"]="Selling Agent Email";
idxExclude["rets30_SellingAgentFullName"]="Selling Agent Full Name";
idxExclude["rets30_SellingAgentLicenseNum"]="Selling Agent License Num";
idxExclude["rets30_SellingAgentMLSID"]="Selling Agent MLSID";
idxExclude["rets30_SellingOfficeMLSID"]="Selling Office MLSID";
idxExclude["rets30_SellingOfficeName"]="Selling Office Name";
idxExclude["rets30_SellingOfficePhone"]="Selling Office Phone";
idxExclude["rets30_ShowingInstructions"]="Showing Instructions";
idxExclude["rets30_StateOrProvince"]="State Or Province";
idxExclude["rets30_Status"]="Status";
idxExclude["rets30_StreetDirPrefix"]="Street Dir Prefix";
idxExclude["rets30_StreetDirSuffix"]="Street Dir Suffix";
idxExclude["rets30_StreetName"]="Street Name";
idxExclude["rets30_StreetNumber"]="Street Number";
idxExclude["rets30_StreetNumberNumeric"]="Street Number Numeric";
idxExclude["rets30_StreetSuffix"]="Street Suffix";
idxExclude["rets30_SupplementalRemarks"]="Supplemental Remarks";
idxExclude["rets30_SupplementCount"]="Supplement Count";
idxExclude["rets30_SupplementModificationTimestamp"]="Supplement Modification Timestam";
idxExclude["rets30_SupplementRemarksYN"]="Supplement Remarks YN";
idxExclude["rets30_VarDualRateCompYN"]="Var Dual Rate Comp YN";

		application.zcore.listingCom=createobject("component", "zcorerootmapping.mvc.z.listing.controller.listing");
		// force allfields to not have the fields that already used
		this.getDetailCache1(structnew());
		this.getDetailCache2(structnew());
		this.getDetailCache3(structnew());
		
		if(structcount(variables.allfields) NEQ 0){
			writeoutput('<h2>All Fields:</h2>');
			uniqueStruct={};
			for(i in variables.allfields){
				if(structkeyexists(idxExclude, i) EQ false){
					uniqueStruct[i]={
						field:variables.allfields[i].field,
						label:replace(application.zcore.functions.zfirstlettercaps(variables.allfields[i].label),"##","####")
					}
				}
			}
			arr1=structsort(uniqueStruct, "text", "asc", "label");
			for(i=1;i LTE arraylen(arr1);i++){
				c=uniqueStruct[arr1[i]];
				writeoutput('idxTemp2["'&c.field&'"]="'&c.label&'";<br />');
			}
		}
		application.zcore.functions.zabort();</cfscript>
	</cffunction>

	<!--- <table class="ztablepropertyinfo"> --->
    <cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
      <cfargument name="idx" type="struct" required="yes">
      <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		
		
idxTemp2["rets30_AccountingandLegalExpens"]="Accounting and Legal Expens";
idxTemp2["rets30_ACPercentage"]="AC Percentage";
idxTemp2["rets30_AcreageDescription"]="Acreage Description";
idxTemp2["rets30_ActiveOpenHouseCount"]="Active Open House Count";
idxTemp2["rets30_ADACompliant"]="ADA Compliant";
idxTemp2["rets30_AdditionalBusinessNames"]="Additional Business Names";
idxTemp2["rets30_AdditionalFurnishedInfo"]="Additional Furnished Info";
idxTemp2["rets30_AddlMoveInCostYN"]="Addl Move In Cost YN";
idxTemp2["rets30_AddressonInternet"]="Addresson Internet";
idxTemp2["rets30_AdjustedAreaSF"]="Adjusted Area SF";
idxTemp2["rets30_AdvertisingExpenses"]="Advertising Expenses";
idxTemp2["rets30_Amenities"]="Amenities";
idxTemp2["rets30_AnnualBaseRate"]="Annual Base Rate";
idxTemp2["rets30_ApplicationFee"]="Application Fee";
idxTemp2["rets30_ApprovalInformation"]="Approval Information";
idxTemp2["rets30_ApproximateLotSize"]="Approximate Lot Size";
idxTemp2["rets30_ApproxSqftTotalArea"]="Approx Sqft Total Area";
idxTemp2["rets30_Area"]="Area";
idxTemp2["rets30_AssocFeePaidPer"]="Assoc Fee Paid Per";
idxTemp2["rets30_AssociationFee"]="Association Fee";
idxTemp2["rets30_AssumableChattelBalance"]="Assumable Chattel Balance";
idxTemp2["rets30_AssumableYN"]="Assumable YN";
idxTemp2["rets30_AuctionType"]="Auction Type";
idxTemp2["rets30_AuctionYN"]="Auction YN";
idxTemp2["rets30_AvailableDate"]="Available Date";
idxTemp2["rets30_AvailableDocuments"]="Available Documents";
idxTemp2["rets30_AVM"]="Avm";
idxTemp2["rets30_BalconyPorchandorPatioYN"]="Balcony Porchandor Patio YN";
idxTemp2["rets30_BathsFull"]="Baths Full";
idxTemp2["rets30_BathsHalf"]="Baths Half";
idxTemp2["rets30_BathsTotal"]="Baths Total";
idxTemp2["rets30_BedroomDescription"]="Bedroom Description";
idxTemp2["rets30_BedsTotal"]="Beds Total";
idxTemp2["rets30_Blogging"]="Blogging";
idxTemp2["rets30_BoatDockAccommodates"]="Boat Dock Accommodates";
idxTemp2["rets30_BoatServices"]="Boat Services";
idxTemp2["rets30_BrandName"]="Brand Name";
idxTemp2["rets30_BuildingAreaAlternative"]="Building Area Alternative";
idxTemp2["rets30_BuildingAreaAltSource"]="Building Area Alt Source";
idxTemp2["rets30_BuildingIncludes"]="Building Includes";
idxTemp2["rets30_BuildingNameNumber"]="Building Name Number";
idxTemp2["rets30_BuildingNumber"]="Building Number";
idxTemp2["rets30_BuildingSqFt"]="Building Sq Ft";
idxTemp2["rets30_CableAvailableYN"]="Cable Available YN";
idxTemp2["rets30_CancelledDate"]="Cancelled Date";
idxTemp2["rets30_CarportDescription"]="Carport Description";
idxTemp2["rets30_CeilingDescription"]="Ceiling Description";
idxTemp2["rets30_CeilingHeight"]="Ceiling Height";
idxTemp2["rets30_City"]="City";
idxTemp2["rets30_CloseDate"]="Close Date";
idxTemp2["rets30_ClosePrice"]="Close Price";
idxTemp2["rets30_ColumnDescription"]="Column Description";
idxTemp2["rets30_CommonAreaMaintAmount"]="Common Area Maint Amount";
idxTemp2["rets30_CommonAreaMaintIncludes"]="Common Area Maint Includes";
idxTemp2["rets30_ComplexName"]="Complex Name";
idxTemp2["rets30_ComprehensivePlanUse"]="Comprehensive Plan Use";
idxTemp2["rets30_ConditionalDate"]="Conditional Date";
idxTemp2["rets30_ConstructionType"]="Construction Type";
idxTemp2["rets30_ConvertibleBedroomYN"]="Convertible Bedroom YN";
idxTemp2["rets30_CoolingDescription"]="Cooling Description";
idxTemp2["rets30_CostofSales"]="Costof Sales";
idxTemp2["rets30_CountyLandCode"]="County Land Code";
idxTemp2["rets30_CountyOrParish"]="County Or Parish";
idxTemp2["rets30_CurrentPrice"]="Current Price";
idxTemp2["rets30_DadeAssessedAmtSOHValue"]="Dade Assessed Amt SOH Value";
idxTemp2["rets30_DadeMarketAmtAssessedAmt"]="Dade Market Amt Assessed Amt";
idxTemp2["rets30_DaysOpen"]="Days Open";
idxTemp2["rets30_DecalNumber"]="Decal Number";
idxTemp2["rets30_DeedRestrictions"]="Deed Restrictions";
idxTemp2["rets30_DenDimensions"]="Den Dimensions";
idxTemp2["rets30_DepositInformation"]="Deposit Information";
idxTemp2["rets30_Design"]="Design";
idxTemp2["rets30_DesignDescription"]="Design Description";
idxTemp2["rets30_Development"]="Development";
idxTemp2["rets30_DevelopmentName"]="Development Name";
idxTemp2["rets30_DiningAreaDimensions"]="Dining Area Dimensions";
idxTemp2["rets30_DiningDescription"]="Dining Description";
idxTemp2["rets30_DiningRoomDimensions"]="Dining Room Dimensions";
idxTemp2["rets30_Directions"]="Directions";
idxTemp2["rets30_DockHeight"]="Dock Height";
idxTemp2["rets30_DockInformation"]="Dock Information";
idxTemp2["rets30_DockNumber"]="Dock Number";
idxTemp2["rets30_DOM"]="Dom";
idxTemp2["rets30_DoorHeight"]="Door Height";
idxTemp2["rets30_EaveHeight"]="Eave Height";
idxTemp2["rets30_EfficiencyYN"]="Efficiency YN";
idxTemp2["rets30_ElectricService"]="Electric Service";
idxTemp2["rets30_ElementarySchool"]="Elementary School";
idxTemp2["rets30_ElevationAboveSeaLevel"]="Elevation Above Sea Level";
idxTemp2["rets30_EnvironmentalAudit"]="Environmental Audit";
idxTemp2["rets30_EquestrianFeatures"]="Equestrian Features";
idxTemp2["rets30_EquipmentAppliances"]="Equipment Appliances";
idxTemp2["rets30_ExcludeFromInventoryStats"]="Exclude From Inventory Stats";
idxTemp2["rets30_ExpenseAmount"]="Expense Amount";
idxTemp2["rets30_ExpensesIncluded"]="Expenses Included";
idxTemp2["rets30_ExpInclAcctgLegalYN"]="Exp Incl Acctg Legal YN";
idxTemp2["rets30_ExpInclAdvLicPermitYN"]="Exp Incl Adv Lic Permit YN";
idxTemp2["rets30_ExpInclElectricYN"]="Exp Incl Electric YN";
idxTemp2["rets30_ExpInclExterminationYN"]="Exp Incl Extermination YN";
idxTemp2["rets30_ExpInclGasOilYN"]="Exp Incl Gas Oil YN";
idxTemp2["rets30_ExpInclInsuranceYN"]="Exp Incl Insurance YN";
idxTemp2["rets30_ExpInclJanitorYN"]="Exp Incl Janitor YN";
idxTemp2["rets30_ExpInclLawnMaintenanceYN"]="Exp Incl Lawn Maintenance YN";
idxTemp2["rets30_ExpInclMaintandRepairYN"]="Exp Incl Maintand Repair YN";
idxTemp2["rets30_ExpInclManagementYN"]="Exp Incl Management YN";
idxTemp2["rets30_ExpInclMiscellaneousYN"]="Exp Incl Miscellaneous YN";
idxTemp2["rets30_ExpInclPoolServiceYN"]="Exp Incl Pool Service YN";
idxTemp2["rets30_ExpInclPropertyTaxYN"]="Exp Incl Property Tax YN";
idxTemp2["rets30_ExpInclReplaceReserveYN"]="Exp Incl Replace Reserve YN";
idxTemp2["rets30_ExpInclRetaxYN"]="Exp Incl Retax YN";
idxTemp2["rets30_ExpInclSuppliesYN"]="Exp Incl Supplies YN";
idxTemp2["rets30_ExpInclTrashYN"]="Exp Incl Trash YN";
idxTemp2["rets30_ExpInclWaterSewerYN"]="Exp Incl Water Sewer YN";
idxTemp2["rets30_ExpirationDate"]="Expiration Date";
idxTemp2["rets30_ExteriorFeatures"]="Exterior Features";
idxTemp2["rets30_FeeDescription"]="Fee Description";
idxTemp2["rets30_FillDescription"]="Fill Description";
idxTemp2["rets30_FillFromRecord_MUI"]="Fill From Record MUI";
idxTemp2["rets30_FillFromRecord_TableID"]="Fill From Record Table ID";
idxTemp2["rets30_FireProtection"]="Fire Protection";
idxTemp2["rets30_FixtureValue"]="Fixture Value";
idxTemp2["rets30_FloodZone"]="Flood Zone";
idxTemp2["rets30_FloorDescription"]="Floor Description";
idxTemp2["rets30_FolioNum2ndParcel"]="Folio Num 2 Nd Parcel";
idxTemp2["rets30_ForLeaseMLSNumber"]="For Lease MLS Number";
idxTemp2["rets30_ForLeaseYN"]="For Lease YN";
idxTemp2["rets30_ForSaleMLSNumber"]="For Sale MLS Number";
idxTemp2["rets30_ForSaleYN"]="For Sale YN";
idxTemp2["rets30_FrontExposure"]="Front Exposure";
idxTemp2["rets30_FurnAnnualRent"]="Furn Annual Rent";
idxTemp2["rets30_FurnishedInfoList"]="Furnished Info List";
idxTemp2["rets30_FurnishedInfoSold"]="Furnished Info Sold";
idxTemp2["rets30_FurnOffSeasonRent"]="Furn Off Season Rent";
idxTemp2["rets30_FurnSeasonalRent"]="Furn Seasonal Rent";
idxTemp2["rets30_GarageDescription"]="Garage Description";
idxTemp2["rets30_GasDescription"]="Gas Description";
idxTemp2["rets30_GeographicArea"]="Geographic Area";
idxTemp2["rets30_GreenEnergyEfficient"]="Green Energy Efficient";
idxTemp2["rets30_GrossOperatingIncome"]="Gross Operating Income";
idxTemp2["rets30_GrossRent"]="Gross Rent";
idxTemp2["rets30_GrossRentIncome"]="Gross Rent Income";
idxTemp2["rets30_GrossSales"]="Gross Sales";
idxTemp2["rets30_GrossScheduledIncome"]="Gross Scheduled Income";
idxTemp2["rets30_GroundCover"]="Ground Cover";
idxTemp2["rets30_GroundCoverDescription"]="Ground Cover Description";
idxTemp2["rets30_GuestHouseDescription"]="Guest House Description";
idxTemp2["rets30_HardshipPackage"]="Hardship Package";
idxTemp2["rets30_HeatingDescription"]="Heating Description";
idxTemp2["rets30_HousingOlderPersonsAct"]="Housing Older Persons Act";
idxTemp2["rets30_ImprovementHeightBUS"]="Improvement Height BUS";
idxTemp2["rets30_ImprovementHeightCOM"]="Improvement Height COM";
idxTemp2["rets30_IncExpStatementPeriod"]="Inc Exp Statement Period";
idxTemp2["rets30_InformationAvailable"]="Information Available";
idxTemp2["rets30_InsuranceExpense"]="Insurance Expense";
idxTemp2["rets30_IntendedUse"]="Intended Use";
idxTemp2["rets30_InteriorCeilingHeight"]="Interior Ceiling Height";
idxTemp2["rets30_InteriorFeatures"]="Interior Features";
idxTemp2["rets30_InventoryValue"]="Inventory Value";
idxTemp2["rets30_Jurisdiction"]="Jurisdiction";
idxTemp2["rets30_LandImprovements"]="Land Improvements";
idxTemp2["rets30_LandLeaseAmount"]="Land Lease Amount";
idxTemp2["rets30_LandLeaseFeePaidPer"]="Land Lease Fee Paid Per";
idxTemp2["rets30_LastChangeTimestamp"]="Last Change Timestamp";
idxTemp2["rets30_LastChangeType"]="Last Change Type";
idxTemp2["rets30_LastStatus"]="Last Status";
idxTemp2["rets30_LeasePrice"]="Lease Price";
idxTemp2["rets30_LeaseTermInfo"]="Lease Term Info";
idxTemp2["rets30_LeaseTermRemaining"]="Lease Term Remaining";
idxTemp2["rets30_LegalDescription"]="Legal Description";
idxTemp2["rets30_LenderApproval"]="Lender Approval";
idxTemp2["rets30_Licenses"]="Licenses";
idxTemp2["rets30_ListPrice"]="List Price";
idxTemp2["rets30_Location"]="Location";
idxTemp2["rets30_LocationofProperty"]="Location of Property";
idxTemp2["rets30_LotDepth"]="Lot Depth";
idxTemp2["rets30_LotDescription"]="Lot Description";
idxTemp2["rets30_LotFrontage"]="Lot Frontage";
idxTemp2["rets30_LotorTrackNum"]="Lotor Track Num";
idxTemp2["rets30_LotSqFootage"]="Lot Sq Footage";
idxTemp2["rets30_LPAmtSqFt"]="LP Amt Sq Ft";
idxTemp2["rets30_MainLivingArea"]="Main Living Area";
idxTemp2["rets30_MaintandRepairsExpense"]="Maintand Repairs Expense";
idxTemp2["rets30_MaintenanceChargeMonth"]="Maintenance Charge Month";
idxTemp2["rets30_MaintenanceFeeIncludes"]="Maintenance Fee Includes";
idxTemp2["rets30_MaintenanceIncludes"]="Maintenance Includes";
idxTemp2["rets30_MaintFeePaidPer"]="Maint Fee Paid Per";
idxTemp2["rets30_ManagementExpense"]="Management Expense";
idxTemp2["rets30_ManufacturedHomeMiscell"]="Manufactured Home Miscell";
idxTemp2["rets30_ManufacturedHomeSize"]="Manufactured Home Size";
idxTemp2["rets30_MasterBathroomDescription"]="Master Bathroom Description";
idxTemp2["rets30_MaximumCeilingHeight"]="Maximum Ceiling Height";
idxTemp2["rets30_MaximumLeasableSqft"]="Maximum Leasable Sqft";
idxTemp2["rets30_MemberFeePaidPer"]="Member Fee Paid Per";
idxTemp2["rets30_MembershipPurchaseFee"]="Membership Purchase Fee";
idxTemp2["rets30_MembershipPurchRqdYN"]="Membership Purch Rqd YN";
idxTemp2["rets30_MiddleSchool"]="Middle School";
idxTemp2["rets30_MilestoBeach"]="Milesto Beach";
idxTemp2["rets30_MilestoExpressway"]="Miles to Expressway";
idxTemp2["rets30_MinimumLeasePeriod"]="Minimum Lease Period";
idxTemp2["rets30_MinimumNumofDaysforLease"]="Minimum Num of Days for Lease";
idxTemp2["rets30_MinSFLivingAreaReqmt"]="Min SF Living Area Reqmt";
idxTemp2["rets30_Miscellaneous"]="Miscellaneous";
idxTemp2["rets30_MiscellaneousExpense"]="Miscellaneous Expense";
idxTemp2["rets30_MiscellaneousImprovements"]="Miscellaneous Improvements";
idxTemp2["rets30_MiscellaneousInformation"]="Miscellaneous Information";
idxTemp2["rets30_MLSNumber"]="MLS Number";
idxTemp2["rets30_ModelName"]="Model Name";
idxTemp2["rets30_MoveInDollars"]="Move In Dollars";
idxTemp2["rets30_MultipleOffersAcceptedYN"]="Multiple Offers Accepted YN";
idxTemp2["rets30_MunicipalCode"]="Municipal Code";
idxTemp2["rets30_Neighborhoods"]="Neighborhoods";
idxTemp2["rets30_NetOperatingIncome"]="Net Operating Income";
idxTemp2["rets30_NumBays"]="Num Bays";
idxTemp2["rets30_NumBuildings"]="Num Buildings";
idxTemp2["rets30_NumCarportSpaces"]="Num Carport Spaces";
idxTemp2["rets30_NumCeilingFans"]="Num Ceiling Fans";
idxTemp2["rets30_NumEmployees"]="Num Employees";
idxTemp2["rets30_NumFloors"]="Num Floors";
idxTemp2["rets30_NumGarageSpaces"]="Num Garage Spaces";
idxTemp2["rets30_NumInteriorLevels"]="Num Interior Levels";
idxTemp2["rets30_NumLeasesYear"]="Num Leases Year";
idxTemp2["rets30_NumLoadingDoors"]="Num Loading Doors";
idxTemp2["rets30_NumMeters"]="Num Meters";
idxTemp2["rets30_NumOffices"]="Num Offices";
idxTemp2["rets30_NumParcels"]="Num Parcels";
idxTemp2["rets30_NumParkingSpaces"]="Num Parking Spaces";
idxTemp2["rets30_NumSeats"]="Num Seats";
idxTemp2["rets30_NumStories"]="Num Stories";
idxTemp2["rets30_NumTenants"]="Num Tenants";
idxTemp2["rets30_NumTimesLeasedYear"]="Num Times Leased Year";
idxTemp2["rets30_NumToilets"]="Num Toilets";
idxTemp2["rets30_NumUnits"]="Num Units";
idxTemp2["rets30_OccupancyInformation"]="Occupancy Information";
idxTemp2["rets30_OccupancyPercentage"]="Occupancy Percentage";
idxTemp2["rets30_OfficeFaxNumber"]="Office Fax Number";
idxTemp2["rets30_OffMarketDate"]="Off Market Date";
idxTemp2["rets30_OnSiteUtilities"]="On Site Utilities";
idxTemp2["rets30_OriginalEntryTimestamp"]="Original Entry Timestamp";
idxTemp2["rets30_OriginalListPrice"]="Original List Price";
idxTemp2["rets30_OtherExpenses"]="Other Expenses";
idxTemp2["rets30_OtherIncomeExpense"]="Other Income Expense";
idxTemp2["rets30_OwnerAgentYN"]="Owner Agent YN";
idxTemp2["rets30_Ownership"]="Ownership";
idxTemp2["rets30_PACEYN"]="Paceyn";
idxTemp2["rets30_ParcelNumber"]="Parcel Number";
idxTemp2["rets30_ParcelNumberMLX"]="Parcel Number MLX";
idxTemp2["rets30_ParkingDescription"]="Parking Description";
idxTemp2["rets30_ParkingRestrictions"]="Parking Restrictions";
idxTemp2["rets30_ParkingSpaceNumber"]="Parking Space Number";
idxTemp2["rets30_PatioBalconyDimensions"]="Patio Balcony Dimensions";
idxTemp2["rets30_PendingDate"]="Pending Date";
idxTemp2["rets30_PetRestrictions"]="Pet Restrictions";
idxTemp2["rets30_PetsAllowedYN"]="Pets Allowed YN";
idxTemp2["rets30_PhotoCount"]="Photo Count";
idxTemp2["rets30_PhotoModificationTimestamp"]="Photo Modification Timestamp";
idxTemp2["rets30_PoolDescription"]="Pool Description";
idxTemp2["rets30_PoolDimensions"]="Pool Dimensions";
idxTemp2["rets30_PoolYN"]="Pool YN";
idxTemp2["rets30_PossessionInformation"]="Possession Information";
idxTemp2["rets30_PostalCode"]="Postal Code";
idxTemp2["rets30_PostalCodePlus4"]="Postal Code Plus 4";
idxTemp2["rets30_PreviousStatus"]="Previous Status";
idxTemp2["rets30_PriceAcre"]="Price Acre";
idxTemp2["rets30_PriceChangeTimestamp"]="Price Change Timestamp";
idxTemp2["rets30_PropertyDescription"]="Property Description";
idxTemp2["rets30_PropertyDetachedYN"]="Property Detached YN";
idxTemp2["rets30_PropertySqFt"]="Property Sq Ft";
idxTemp2["rets30_PropertySubType"]="Property Sub Type";
idxTemp2["rets30_PropertyType"]="Property Type";
idxTemp2["rets30_PropertyTypeInformation"]="Property Type Information";
idxTemp2["rets30_PropTypeTypeofBuilding"]="Prop Type Type of Building";
idxTemp2["rets30_ProviderKey"]="Provider Key";
idxTemp2["rets30_RailDescription"]="Rail Description";
idxTemp2["rets30_RealEstateTaxes"]="Real Estate Taxes";
idxTemp2["rets30_RecLeaseMoFeePaidPer"]="Rec Lease Mo Fee Paid Per";
idxTemp2["rets30_RecLeaseMonth"]="Rec Lease Month";
idxTemp2["rets30_ReimbursableSqFt"]="Reimbursable Sq Ft";
idxTemp2["rets30_Remarks"]="Remarks";
idxTemp2["rets30_RentalDepositIncludes"]="Rental Deposit Includes";
idxTemp2["rets30_RentalPaymentIncludes"]="Rental Payment Includes";
idxTemp2["rets30_RentIncludes"]="Rent Includes";
idxTemp2["rets30_RentPeriod"]="Rent Period";
idxTemp2["rets30_RentStatusApril"]="Rent Status April";
idxTemp2["rets30_RentStatusAugust"]="Rent Status August";
idxTemp2["rets30_RentStatusDecember"]="Rent Status December";
idxTemp2["rets30_RentStatusFebruary"]="Rent Status February";
idxTemp2["rets30_RentStatusJanuary"]="Rent Status January";
idxTemp2["rets30_RentStatusJuly"]="Rent Status July";
idxTemp2["rets30_RentStatusJune"]="Rent Status June";
idxTemp2["rets30_RentStatusMarch"]="Rent Status March";
idxTemp2["rets30_RentStatusMay"]="Rent Status May";
idxTemp2["rets30_RentStatusNovember"]="Rent Status November";
idxTemp2["rets30_RentStatusOctober"]="Rent Status October";
idxTemp2["rets30_RentStatusSeptember"]="Rent Status September";
idxTemp2["rets30_REOYN"]="Reoyn";
idxTemp2["rets30_Restrictions"]="Restrictions";
idxTemp2["rets30_RoadDescription"]="Road Description";
idxTemp2["rets30_RoadFrntgDescription"]="Road Frntg Description";
idxTemp2["rets30_RoadFrontage"]="Road Frontage";
idxTemp2["rets30_RoadTypeDescription"]="Road Type Description";
idxTemp2["rets30_Roof"]="Roof";
idxTemp2["rets30_RoofDescription"]="Roof Description";
idxTemp2["rets30_RoomCount"]="Room Count";
idxTemp2["rets30_RoomsDescription"]="Rooms Description";
idxTemp2["rets30_SaleIncludes"]="Sale Includes";
idxTemp2["rets30_SaleIncludesINCL"]="Sale Includes INCL";
idxTemp2["rets30_SaleIncludesSALE"]="Sale Includes SALE";
idxTemp2["rets30_Section"]="Section";
idxTemp2["rets30_SecurityInformation"]="Security Information";
idxTemp2["rets30_SeniorHighSchool"]="Senior High School";
idxTemp2["rets30_SeparateMeterYN"]="Separate Meter YN";
idxTemp2["rets30_SerialNumber"]="Serial Number";
idxTemp2["rets30_ServiceExpense"]="Service Expense";
idxTemp2["rets30_SewerDescription"]="Sewer Description";
idxTemp2["rets30_ShortSaleAddendumYN"]="Short Sale Addendum YN";
idxTemp2["rets30_ShortSaleYN"]="Short Sale YN";
idxTemp2["rets30_ShowingSuiteEmailInfoYN"]="Showing Suite Email Info YN";
idxTemp2["rets30_ShowingSuiteSettingYN"]="Showing Suite Setting YN";
idxTemp2["rets30_ShowingTimeFlag"]="Showing Time Flag";
idxTemp2["rets30_SoldPriceperSF"]="Sold Price per SF";
idxTemp2["rets30_SourceofExpenses"]="Source of Expenses";
idxTemp2["rets30_SpaYN"]="Spa YN";
idxTemp2["rets30_SpecialAssessmentYN"]="Special Assessment YN";
idxTemp2["rets30_SpecialInformation"]="Special Information";
idxTemp2["rets30_SprinklerDescription"]="Sprinkler Description";
idxTemp2["rets30_SqFtLAofGuestHouse"]="Sq Ft L Aof Guest House";
idxTemp2["rets30_SqFtLivArea"]="Sq Ft Liv Area";
idxTemp2["rets30_SqFtOccupied"]="Sq Ft Occupied";
idxTemp2["rets30_SqFtTotal"]="Sq Ft Total";
idxTemp2["rets30_StatusChangeTimestamp"]="Status Change Timestamp";
idxTemp2["rets30_StatusContractualSearchDate"]="Status Contractual Search Date";
idxTemp2["rets30_StormProtection"]="Storm Protection";
idxTemp2["rets30_StreetViewParam"]="Street View Param";
idxTemp2["rets30_Style"]="Style";
idxTemp2["rets30_StyleofBusiness"]="Style of Business";
idxTemp2["rets30_StyleofProperty"]="Style of Property";
idxTemp2["rets30_StyleTran"]="Style Tran";
idxTemp2["rets30_SubBoardID"]="Sub Board ID";
idxTemp2["rets30_SubdivisionComplexBldg"]="Subdivision Complex Bldg";
idxTemp2["rets30_SubdivisionInformation"]="Subdivision Information";
idxTemp2["rets30_SubdivisionName"]="Subdivision Name";
idxTemp2["rets30_SubdivisionNumber"]="Subdivision Number";
idxTemp2["rets30_SupplyExpense"]="Supply Expense";
idxTemp2["rets30_SurfaceDescription"]="Surface Description";
idxTemp2["rets30_TaxAmount"]="Tax Amount";
idxTemp2["rets30_TaxInformation"]="Tax Information";
idxTemp2["rets30_TaxYear"]="Tax Year";
idxTemp2["rets30_TempOffMarketDate"]="Temp Off Market Date";
idxTemp2["rets30_TenantPays"]="Tenant Pays";
idxTemp2["rets30_TermsAvailable"]="Terms Available";
idxTemp2["rets30_TermsConsidered"]="Terms Considered";
idxTemp2["rets30_TotalAcreage"]="Total Acreage";
idxTemp2["rets30_TotalAssumableLoans"]="Total Assumable Loans";
idxTemp2["rets30_TotalExpenses"]="Total Expenses";
idxTemp2["rets30_TotalFloorsInBuilding"]="Total Floors In Building";
idxTemp2["rets30_TotalMortgage"]="Total Mortgage";
idxTemp2["rets30_TotalMoveInDollars"]="Total Move In Dollars";
idxTemp2["rets30_TotalNumofUnitsInBuildin"]="Total Num of Units In Buildin";
idxTemp2["rets30_TotalNumofUnitsInComplex"]="Total Num of Units In Complex";
idxTemp2["rets30_TotalUnits"]="Total Units";
idxTemp2["rets30_TownshipRange"]="Township Range";
idxTemp2["rets30_TrainingAvailableYN"]="Training Available YN";
idxTemp2["rets30_TransactionType"]="Transaction Type";
idxTemp2["rets30_TrashExpense"]="Trash Expense";
idxTemp2["rets30_TypeofAssociation"]="Type of Association";
idxTemp2["rets30_TypeofBuilding"]="Type of Building";
idxTemp2["rets30_TypeofBusiness"]="Type of Business";
idxTemp2["rets30_TypeofContingencies"]="Type of Contingencies";
idxTemp2["rets30_TypeofGoverningBodies"]="Type of Governing Bodies";
idxTemp2["rets30_TypeofOwnership"]="Type of Ownership";
idxTemp2["rets30_TypeofProperty"]="Type of Property";
idxTemp2["rets30_TypeofSoil"]="Type of Soil";
idxTemp2["rets30_TypeofTrees"]="Type of Trees";
idxTemp2["rets30_UnfurnAnnualRent"]="Unfurn Annual Rent";
idxTemp2["rets30_UnfurnOffSeasonRent"]="Unfurn Off Season Rent";
idxTemp2["rets30_UnfurnSeasonalRent"]="Unfurn Seasonal Rent";
idxTemp2["rets30_UnitCount"]="Unit Count";
idxTemp2["rets30_UnitDesign"]="Unit Design";
idxTemp2["rets30_UnitFloorLocation"]="Unit Floor Location";
idxTemp2["rets30_UnitNumber"]="Unit Number";
idxTemp2["rets30_UnitView"]="Unit View";
idxTemp2["rets30_Usage"]="Usage";
idxTemp2["rets30_UsageDescription"]="Usage Description";
idxTemp2["rets30_UtilitiesAvailable"]="Utilities Available";
idxTemp2["rets30_UtilityExpense"]="Utility Expense";
idxTemp2["rets30_UtilityRoomDimension"]="Utility Room Dimension";
idxTemp2["rets30_VacancyRate"]="Vacancy Rate";
idxTemp2["rets30_View"]="View";
idxTemp2["rets30_VirtualTour"]="Virtual Tour";
idxTemp2["rets30_WaterAccess"]="Water Access";
idxTemp2["rets30_WaterDescription"]="Water Description";
idxTemp2["rets30_WaterfrontDescription"]="Waterfront Description";
idxTemp2["rets30_WaterfrontFrontage"]="Waterfront Frontage";
idxTemp2["rets30_WaterfrontPropertyYN"]="Waterfront Property YN";
idxTemp2["rets30_WaterView"]="Water View";
idxTemp2["rets30_WaterviewDescription"]="Waterview Description";
idxTemp2["rets30_WebAddress"]="Web Address";
idxTemp2["rets30_WindowsTreatment"]="Windows Treatment";
idxTemp2["rets30_WithdrawnDate"]="Withdrawn Date";
idxTemp2["rets30_YearBuilt"]="Year Built";
idxTemp2["rets30_YearBuiltDescription"]="Year Built Description";
idxTemp2["rets30_YearEstablished"]="Year Established";
idxTemp2["rets30_YearofAddition"]="Yearof Addition";
idxTemp2["rets30_ZoningInformation"]="Zoning Information";

  
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Interior Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
    
    
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		// exterior features 
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Exterior Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew(); 
		/*
idxTemp2["rets30_yearbuilt"]="Year Built";
if(application.zcore.functions.zso(arguments.idx, 'rets30_virtualtoururl2') NEQ ""){
	arrayAppend(arrR, '<a href="#arguments.idx.rets30_virtualtoururl2#" target="_blank">View Virtual Tour Link 2</a>');
}*/
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Additional Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		

		idxTemp2=structnew(); 
		
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial &amp; Legal Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
</cfoutput>
</cfcomponent>