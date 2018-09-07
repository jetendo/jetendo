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

	// put them here
idxExclude["rets29_VirtualTourURLUnbranded"]="Virtual Tour Url Unbranded";
idxExclude["rets29_VOWAVMYN"]="Vowavmyn";
//idxExclude["rets29_ArchitecturalStyle"]="Architectural Style";
idxExclude["rets29_CloseDate"]="Close Date";
idxExclude["rets29_ClosePrice"]="Close Price";
idxExclude["rets29_CoListAgentDirectWorkPhone"]="Co List Agent Direct Work Phone";
idxExclude["rets29_CoListAgentEmail"]="Co List Agent Email";
idxExclude["rets29_CoListAgentFullName"]="Co List Agent Full Name";
idxExclude["rets29_CoListAgentMLSBoard"]="Co List Agent Mls Board";
idxExclude["rets29_CoListAgentMLSID"]="Co List Agent Mlsid";
idxExclude["rets29_CoListAgent_MUI"]="Co List Agent Mui";
idxExclude["rets29_CoListAgentPrimaryBoard"]="Co List Agent Primary Board";
idxExclude["rets29_CoListOfficeMLSID"]="Co List Office Mlsid";
idxExclude["rets29_CoListOffice_MUI"]="Co List Office Mui";
idxExclude["rets29_CoListOfficeName"]="Co List Office Name";
idxExclude["rets29_CoListOfficePhone"]="Co List Office Phone";
//idxExclude["rets29_YearBuilt"]="Year Built";
idxExclude["rets29_BuyerAgencyCompensation"]="Buyer Agency Compensation";
idxExclude["rets29_BuyerAgencyCompensationType"]="Buyer Agency Compensation Type";
idxExclude["rets29_BuyerAgentSaleYN"]="Buyer Agent Sale Yn";
idxExclude["rets29_CoSellingAgentMLSBoard"]="Co Selling Agent Mls Board";
idxExclude["rets29_CoSellingAgentMLSID"]="Co Selling Agent Mlsid";
idxExclude["rets29_CoSellingAgent_MUI"]="Co Selling Agent Mui";
idxExclude["rets29_CoSellingAgentPrimaryBoard"]="Co Selling Agent Primary Board";
idxExclude["rets29_CoSellingOfficeMLSID"]="Co Selling Office Mlsid";
idxExclude["rets29_CoSellingOffice_MUI"]="Co Selling Office Mui";
idxExclude["rets29_ConditionalDate"]="Conditional Date";
idxExclude["rets29_WarehouseSqFt"]="Warehouse Sq Ft";
idxExclude["rets29_CeilingHeight"]="Ceiling Height";
idxExclude["rets29_CommercialCooling"]="Commercial Cooling";
idxExclude["rets29_CommercialHeating"]="Commercial Heating";
idxExclude["rets29_LotSizeUnits"]="Lot Size Units";
idxExclude["rets29_NumberOfDriveInDoorsTotal"]="Number Of Drive In Doors Total";
idxExclude["rets29_NumberOfUnitsBuildings"]="Number Of Units Buildings";
idxExclude["rets29_NumberOfUnitsTotal"]="Number Of Units Total";
idxExclude["rets29_ParkingTotal"]="Parking Total";
idxExclude["rets29_DepositPet"]="Deposit Pet";
idxExclude["rets29_DepositSecurity"]="Deposit Security";
idxExclude["rets29_SmokingAllowedYN"]="Smoking Allowed Yn";
idxExclude["rets29_Latitude"]="Latitude";
idxExclude["rets29_Longitude"]="Longitude";
idxExclude["rets29_NumberOfDocksTotal"]="Number Of Docks Total";
idxExclude["rets29_ContactName"]="Contact Name";
idxExclude["rets29_ContactPhone"]="Contact Phone";
idxExclude["rets29_SellerContribution"]="Seller Contribution";
idxExclude["rets29_SellingAgentDirectWorkPhone"]="Selling Agent Direct Work Phone";
idxExclude["rets29_SellingAgentEmail"]="Selling Agent Email";
idxExclude["rets29_SellingAgentFullName"]="Selling Agent Full Name";
idxExclude["rets29_SellingAgentMLSBoard"]="Selling Agent Mls Board";
idxExclude["rets29_SellingAgentMLSID"]="Selling Agent Mlsid";
idxExclude["rets29_SellingAgent_MUI"]="Selling Agent Mui";
idxExclude["rets29_SellingAgentPrimaryBoard"]="Selling Agent Primary Board";
idxExclude["rets29_SellingOfficeMLSID"]="Selling Office Mlsid";
idxExclude["rets29_SellingOffice_MUI"]="Selling Office Mui";
idxExclude["rets29_SellingOfficeName"]="Selling Office Name";
idxExclude["rets29_SellingOfficePhone"]="Selling Office Phone";
idxExclude["rets29_ListAgentDirectWorkPhone"]="List Agent Direct Work Phone";
idxExclude["rets29_ListAgentEmail"]="List Agent Email";
idxExclude["rets29_ListAgentFullName"]="List Agent Full Name";
idxExclude["rets29_ListAgentMLSID"]="List Agent Mlsid";
idxExclude["rets29_ListAgent_MUI"]="List Agent Mui";
idxExclude["rets29_ListingAgentMLSBoard"]="Listing Agent Mls Board";
idxExclude["rets29_ListingAgentPrimaryBoard"]="Listing Agent Primary Board";
idxExclude["rets29_ListingContractDate"]="Listing Contract Date";
idxExclude["rets29_ListingServiceYN"]="Listing Service Yn";
idxExclude["rets29_ListOfficeMLSID"]="List Office Mlsid";
idxExclude["rets29_ListOffice_MUI"]="List Office Mui";
idxExclude["rets29_ListOfficeName"]="List Office Name";
idxExclude["rets29_ExpirationDate"]="Expiration Date";
idxExclude["rets29_LastChangeTimestamp"]="Last Change Timestamp";
idxExclude["rets29_LastChangeType"]="Last Change Type";
idxExclude["rets29_GeocodeSource"]="Geocode Source";
idxExclude["rets29_MatrixModifiedDT"]="Matrix Modified Dt";
idxExclude["rets29_Matrix_Unique_ID"]="Matrix Unique Id";
idxExclude["rets29_MLSNumber"]="Mls Number";
idxExclude["rets29_StatusChangeTimestamp"]="Status Change Timestamp";
idxExclude["rets29_StatusContractualSearchDate"]="Status Contractual Search Date";
idxExclude["rets29_OwnerName"]="Owner Name";
idxExclude["rets29_OffMarketDate"]="Off Market Date";
idxExclude["rets29_ListPrice"]="List Price";
idxExclude["rets29_ShowingInstructions"]="Showing Instructions";
idxExclude["rets29_ShowingPhoneNumber"]="Showing Phone Number";
idxExclude["rets29_AuctionBidInformation"]="Auction Bid Information";
idxExclude["rets29_AuctionBidType"]="Auction Bid Type";
idxExclude["rets29_SuitableUse"]="Suitable Use";
idxExclude["rets29_OriginalEntryTimestamp"]="Original Entry Timestamp";
idxExclude["rets29_PermitAddressInternetYN"]="Permit Address Internet Yn";
idxExclude["rets29_PhotoModificationTimestamp"]="Photo Modification Timestamp";
idxExclude["rets29_PlatReferenceSectionPages"]="Plat Reference Section Pages";
idxExclude["rets29_PostalCodePlus4"]="Postal Code Plus 4";
idxExclude["rets29_PriceChangeTimestamp"]="Price Change Timestamp";

idxExclude["rets29_ZoningSpecification"]="Zoning Specification";
idxExclude["rets29_AssociationFee"]="Association Fee";
idxExclude["rets29_AssociationFeeFrequency"]="Association Fee Frequency";
idxExclude["rets29_AuctionYN"]="Auction Yn";
idxExclude["rets29_SyndicationRemarks"]="Syndication Remarks";
idxExclude["rets29_TaxAmountNCM"]="Tax Amount Ncm";
idxExclude["rets29_SoldTerms"]="Sold Terms"; 
idxExclude["rets29_WebURL"]="Web Url";
idxExclude["rets29_WithdrawnDate"]="Withdrawn Date";
idxExclude["rets29_BuilderName"]="Builder Name";
idxExclude["rets29_CompanyRemarks"]="Company Remarks";
idxExclude["rets29_ConstructionType"]="Construction Type";
idxExclude["rets29_CCRSubjectToYN"]="Ccr Subject To Yn";
idxExclude["rets29_CompleName"]="Complex Name";
idxExclude["rets29_Country"]="Country";
idxExclude["rets29_Directions"]="Directions";
idxExclude["rets29_Elevation"]="Elevation";
idxExclude["rets29_LaundryLocation"]="Laundry Location";
idxExclude["rets29_LeaseTerm"]="Lease Term";
idxExclude["rets29_LeaseYN"]="Lease Yn";
idxExclude["rets29_ListingType"]="Listing Type";
idxExclude["rets29_LotDimension"]="Lot Dimension";
idxExclude["rets29_OwnershipType"]="Ownership Type";
idxExclude["rets29_PetsAllowed"]="Pets Allowed";
idxExclude["rets29_Restrictions"]="Restrictions";
idxExclude["rets29_Street"]="Address";
idxExclude["rets29_StreetDirPrefix"]="Street Dir Prefix";
idxExclude["rets29_StreetDirSuffix"]="Street Dir Suffix";
idxExclude["rets29_StreetName"]="Street Name";
idxExclude["rets29_StreetNumberNumeric"]="Street Number Numeric";
idxExclude["rets29_StreetSuffix"]="Street Suffix";
idxExclude["rets29_CDOM"]="Cdom";
idxExclude["rets29_CorrectionCount"]="Correction Count";
idxExclude["rets29_DOM"]="Dom";
idxExclude["rets29_FoundationDetails"]="Foundation Details";
idxExclude["rets29_GreenBuildingFeatures"]="Green Building Features";
idxExclude["rets29_GreenCertification"]="Green Certification";
idxExclude["rets29_GreenHERSScore"]="Green Hers Score";
idxExclude["rets29_Improvements"]="Improvements";
idxExclude["rets29_Miscellaneous"]="Miscellaneous";
idxExclude["rets29_NewConstructionYN"]="New Construction Yn";
idxExclude["rets29_OpenHouseCount"]="Open House Count";
idxExclude["rets29_OpenHouseUpcoming"]="Open House Upcoming";
idxExclude["rets29_OriginalListPrice"]="Original List Price";
idxExclude["rets29_PhotoCount"]="Photo Count";
idxExclude["rets29_ProposedCompletionDate"]="Proposed Completion Date";
idxExclude["rets29_PublicallyMaintainedRoad"]="Publically Maintained Road";
idxExclude["rets29_Sewer"]="Sewer";
idxExclude["rets29_Status"]="Status";
idxExclude["rets29_Porch"]="Porch";

idxExclude["rets29_PropertySubType"]="Property Sub Type";
idxExclude["rets29_PropertySubTypeSecondary"]="Property Sub Type Secondary";
idxExclude["rets29_PropertyType"]="Property Type";
idxExclude["rets29_Roof"]="Roof";
idxExclude["rets29_ParcelNumber"]="Parcel Number";

idxExclude["rets29_Access"]="Access";
idxExclude["rets29_AcresCleared"]="Acres Cleared";
idxExclude["rets29_UnitCount"]="Unit Count";
idxExclude["rets29_UnitFloorLevel"]="Unit Floor Level";
idxExclude["rets29_UnitNumber"]="Unit Number";
idxExclude["rets29_CommunityFeatures"]="Community Features";

idxExclude["rets29_Driveway"]="Driveway";
idxExclude["rets29_SqFtAdditional"]="Sq Ft Additional";
idxExclude["rets29_SqFtBasement"]="Sq Ft Basement";
idxExclude["rets29_SqFtLower"]="Sq Ft Lower";
idxExclude["rets29_SqFtMain"]="Sq Ft Main";
idxExclude["rets29_SqFtThird"]="Sq Ft Third";
idxExclude["rets29_SqFtUnheatedBasement"]="Sq Ft Unheated Basement";
idxExclude["rets29_SqFtUpper"]="Sq Ft Upper";
idxExclude["rets29_Water"]="Water";
idxExclude["rets29_FireplaceDescription"]="Fireplace Description";
idxExclude["rets29_Flooring"]="Flooring";
idxExclude["rets29_RoomCount"]="Room Count";
idxExclude["rets29_SecondLivingQuarters"]="Second Living Quarters";

idxExclude["rets29_Access"]="Access";
idxExclude["rets29_AcresCleared"]="Acres Cleared";
idxExclude["rets29_AcresWooded"]="Acres Wooded";
idxExclude["rets29_AdditionalInformation"]="Additional Information";
idxExclude["rets29_AssociationFee2"]="Association Fee 2";
idxExclude["rets29_AssociationFee2Frequency"]="Association Fee 2 Frequency";
idxExclude["rets29_AuctionBidInformation"]="Auction Bid Information";
idxExclude["rets29_AuctionBidType"]="Auction Bid Type";
idxExclude["rets29_AvailableDate"]="Available Date";
idxExclude["rets29_BuilderName"]="Builder Name";
idxExclude["rets29_BuyerAgentSaleYN"]="Buyer Agent Sale YN";
idxExclude["rets29_CanSubdivideYN"]="Can Subdivide YN";
idxExclude["rets29_CDOM"]="Cdom";
idxExclude["rets29_CeilingHeight"]="Ceiling Height";
idxExclude["rets29_CeilingHeightFT"]="Ceiling Height FT";
idxExclude["rets29_CeilingHeightIN"]="Ceiling Height IN";
idxExclude["rets29_CloseDate"]="Close Date";
idxExclude["rets29_ClosePrice"]="Close Price";
idxExclude["rets29_CoListAgentFullName"]="Co List Agent Full Name";
idxExclude["rets29_CoListAgentMLSBoard"]="Co List Agent MLS Board";
idxExclude["rets29_CoListAgentMLSID"]="Co List Agent MLSID";
idxExclude["rets29_CoListAgent_MUI"]="Co List Agent MUI";
idxExclude["rets29_CoListAgentPrimaryBoard"]="Co List Agent Primary Board";
idxExclude["rets29_CoListOfficeMLSID"]="Co List Office MLSID";
idxExclude["rets29_CoListOffice_MUI"]="Co List Office MUI";
idxExclude["rets29_CoListOfficeName"]="Co List Office Name";
idxExclude["rets29_CoListTeamMLSID"]="Co List Team MLSID";
idxExclude["rets29_CoListTeam_MUI"]="Co List Team MUI";
idxExclude["rets29_CoListTeamName"]="Co List Team Name";
idxExclude["rets29_CommercialCooling"]="Commercial Cooling";
idxExclude["rets29_CommercialHeating"]="Commercial Heating";
idxExclude["rets29_CommercialLocationDescription"]="Commercial Location Description";
idxExclude["rets29_ComplexName"]="Complex Name";
idxExclude["rets29_ConstructionStatus"]="Construction Status";
idxExclude["rets29_ConstructionType"]="Construction Type";
idxExclude["rets29_ContactName"]="Contact Name";
idxExclude["rets29_CorrectionCount"]="Correction Count";
idxExclude["rets29_CoSellingAgentMLSBoard"]="Co Selling Agent MLS Board";
idxExclude["rets29_CoSellingAgentMLSID"]="Co Selling Agent MLSID";
idxExclude["rets29_CoSellingAgentPrimaryBoard"]="Co Selling Agent Primary Board";
idxExclude["rets29_CoSellingOfficeMLSID"]="Co Selling Office MLSID";
idxExclude["rets29_CoSellingOffice_MUI"]="Co Selling Office MUI";
idxExclude["rets29_Country"]="Country";
idxExclude["rets29_CrossStreet"]="Cross Street";
idxExclude["rets29_DeedReference"]="Deed Reference";
idxExclude["rets29_DepositPet"]="Deposit Pet";
idxExclude["rets29_Directions"]="Directions";
idxExclude["rets29_DocumentManagerTotalCount"]="Document Manager Total Count";
idxExclude["rets29_Documents"]="Documents";
idxExclude["rets29_DOM"]="Dom";
idxExclude["rets29_DoorsWindows"]="Doors Windows";
idxExclude["rets29_Driveway"]="Driveway";
idxExclude["rets29_Easement"]="Easement";
idxExclude["rets29_Elevation"]="Elevation";
idxExclude["rets29_EntryLevel"]="Entry Level";
idxExclude["rets29_FinancingInformation"]="Financing Information";
idxExclude["rets29_FireplaceDescription"]="Fireplace Description";
idxExclude["rets29_FloodPlain"]="Flood Plain";
idxExclude["rets29_Flooring"]="Flooring";
idxExclude["rets29_FoundationDetails"]="Foundation Details";
idxExclude["rets29_Furnished"]="Furnished";
idxExclude["rets29_GeocodeSource"]="Geocode Source";
idxExclude["rets29_GreenCertification"]="Green Certification";
idxExclude["rets29_GreenHERSScore"]="Green HERS Score";
idxExclude["rets29_GrossOperatingIncome"]="Gross Operating Income";
idxExclude["rets29_GrossScheduledIncome"]="Gross Scheduled Income";
idxExclude["rets29_HabitableResidenceYN"]="Habitable Residence YN";
idxExclude["rets29_HOAEmail"]="HOA Email";
idxExclude["rets29_HOAEmail2"]="HOA Email 2";
idxExclude["rets29_HOAManagementName"]="HOA Management Name";
idxExclude["rets29_HOAManagementName2"]="HOA Management Name 2";
idxExclude["rets29_HOAManagementPhone"]="HOA Management Phone";
idxExclude["rets29_HOAManagementPhone2"]="HOA Management Phone 2";
idxExclude["rets29_HOASubjectTo"]="HOA Subject To";
idxExclude["rets29_HOASubjectToDues"]="HOA Subject To Dues";
idxExclude["rets29_Inclusions"]="Inclusions";
idxExclude["rets29_InsideCityYN"]="Inside City YN";
idxExclude["rets29_LandIncludedYN"]="Land Included YN";
idxExclude["rets29_Latitude"]="Latitude";
idxExclude["rets29_LaundryLocation"]="Laundry Location";
idxExclude["rets29_LeaseTerm"]="Lease Term";
idxExclude["rets29_ListAgentDirectWorkPhone"]="List Agent Direct Work Phone";
idxExclude["rets29_ListAgentFullName"]="List Agent Full Name";
idxExclude["rets29_ListAgentMLSID"]="List Agent MLSID";
idxExclude["rets29_ListAgent_MUI"]="List Agent MUI";
idxExclude["rets29_ListingAgentMLSBoard"]="Listing Agent MLS Board";
idxExclude["rets29_ListingAgentPrimaryBoard"]="Listing Agent Primary Board";
idxExclude["rets29_ListingContractDate"]="Listing Contract Date";
idxExclude["rets29_ListingFinancing"]="Listing Financing";
idxExclude["rets29_ListingServiceYN"]="Listing Service YN";
idxExclude["rets29_ListingType"]="Listing Type";
idxExclude["rets29_ListOfficeMLSID"]="List Office MLSID";
idxExclude["rets29_ListOffice_MUI"]="List Office MUI";
idxExclude["rets29_ListOfficeName"]="List Office Name";
idxExclude["rets29_ListOfficePhone"]="List Office Phone";
idxExclude["rets29_ListPrice"]="List Price";
idxExclude["rets29_ListTeamMLSID"]="List Team MLSID";
idxExclude["rets29_ListTeam_MUI"]="List Team MUI";
idxExclude["rets29_ListTeamName"]="List Team Name";
idxExclude["rets29_Longitude"]="Longitude";
idxExclude["rets29_LotDimension"]="Lot Dimension";
idxExclude["rets29_LotSizeUnits"]="Lot Size Units";
idxExclude["rets29_MatrixModifiedDT"]="Matrix Modified DT";
idxExclude["rets29_Matrix_Unique_ID"]="Matrix Unique ID";
idxExclude["rets29_Miscellaneous"]="Miscellaneous";
idxExclude["rets29_MLS"]="Mls";
idxExclude["rets29_MLSNumber"]="MLS Number";
idxExclude["rets29_Model"]="Model";
idxExclude["rets29_NewConstructionYN"]="New Construction YN";
idxExclude["rets29_NumberOfDocksTotal"]="Number Of Docks Total";
idxExclude["rets29_NumberOfDriveInDoorsTotal"]="Number Of Drive In Doors Total";
idxExclude["rets29_NumberOfProjectedUnitsTotal"]="Number Of Projected Units Total";
idxExclude["rets29_NumberOfRentalsTotal"]="Number Of Rentals Total";
idxExclude["rets29_NumberOfUnitsBuildings"]="Number Of Units Buildings";
idxExclude["rets29_NumberOfUnitsTotal"]="Number Of Units Total";
idxExclude["rets29_OperatingExpense"]="Operating Expense";
idxExclude["rets29_OtherIncome"]="Other Income";
idxExclude["rets29_OutBuildingsYN"]="Out Buildings YN";
idxExclude["rets29_OwnerAgentYN"]="Owner Agent YN";
idxExclude["rets29_OwnershipType"]="Ownership Type";
idxExclude["rets29_ParcelNumber"]="Parcel Number";
idxExclude["rets29_ParkingTotal"]="Parking Total";
idxExclude["rets29_PendingDate"]="Pending Date";
idxExclude["rets29_PermitAddressInternetYN"]="Permit Address Internet YN";
idxExclude["rets29_PermitInternetYN"]="Permit Internet YN";
idxExclude["rets29_PermitSyndicationYN"]="Permit Syndication YN";
idxExclude["rets29_PetsAllowed"]="Pets Allowed";
idxExclude["rets29_PhotoCount"]="Photo Count";
idxExclude["rets29_PhotoModificationTimestamp"]="Photo Modification Timestamp";
idxExclude["rets29_PlatBookSlide"]="Plat Book Slide";
idxExclude["rets29_PlatReferenceSectionPages"]="Plat Reference Section Pages";
idxExclude["rets29_Porch"]="Porch";
idxExclude["rets29_PostalCodePlus4"]="Postal Code Plus 4";
idxExclude["rets29_PotentialIncome"]="Potential Income";
idxExclude["rets29_PropertyFeatures"]="Property Features";
idxExclude["rets29_PropertySubType"]="Property Sub Type";
idxExclude["rets29_PropertySubTypeSecondary"]="Property Sub Type Secondary";
idxExclude["rets29_PropertyType"]="Property Type";
idxExclude["rets29_ProposedCompletionDate"]="Proposed Completion Date";
idxExclude["rets29_ProposedSpecialAssessmentDescription"]="Proposed Special Assessment Desc";
idxExclude["rets29_ProposedSpecialAssessmentYN"]="Proposed Special Assessment YN";
idxExclude["rets29_PublicallyMaintainedRoad"]="Publically Maintained Road";
idxExclude["rets29_PublicRemarks"]="Public Remarks";
idxExclude["rets29_RailService"]="Rail Service";
idxExclude["rets29_RATIO_CurrentPrice_By_Acre"]="RATIO Current Price By Acre";
idxExclude["rets29_Restrictions"]="Restrictions";
idxExclude["rets29_RestrictionsDescription"]="Restrictions Description";
idxExclude["rets29_RoadFrontage"]="Road Frontage";
idxExclude["rets29_RoadResponsibility"]="Road Responsibility";
idxExclude["rets29_Roof"]="Roof";
idxExclude["rets29_RoomOther"]="Room Other";
idxExclude["rets29_RValueCeiling"]="R Value Ceiling";
idxExclude["rets29_RValueFloor"]="R Value Floor";
idxExclude["rets29_RValueWall"]="R Value Wall";
idxExclude["rets29_SecondLivingQuarters"]="Second Living Quarters";
idxExclude["rets29_SecondLivingQuartersHLA"]="Second Living Quarters HLA";
idxExclude["rets29_SecondLivingQuartersSqFt"]="Second Living Quarters Sq Ft";
idxExclude["rets29_SellerContribution"]="Seller Contribution";
idxExclude["rets29_SellingAgentMLSBoard"]="Selling Agent MLS Board";
idxExclude["rets29_SellingAgentMLSID"]="Selling Agent MLSID";
idxExclude["rets29_SellingAgent_MUI"]="Selling Agent MUI";
idxExclude["rets29_SellingAgentPrimaryBoard"]="Selling Agent Primary Board";
idxExclude["rets29_SellingOfficeMLSID"]="Selling Office MLSID";
idxExclude["rets29_SellingOffice_MUI"]="Selling Office MUI";
idxExclude["rets29_Sewer"]="Sewer";
idxExclude["rets29_ShowingPhoneNumber"]="Showing Phone Number";
idxExclude["rets29_SpecialListingConditions"]="Special Listing Conditions";
idxExclude["rets29_Sprinkler"]="Sprinkler";
idxExclude["rets29_SqFtAdditional"]="Sq Ft Additional";
idxExclude["rets29_SqFtAvailableMaximum"]="Sq Ft Available Maximum";
idxExclude["rets29_SqFtAvailableMinimum"]="Sq Ft Available Minimum";
idxExclude["rets29_SqFtBasement"]="Sq Ft Basement";
idxExclude["rets29_SqFtBuildingMinimum"]="Sq Ft Building Minimum";
idxExclude["rets29_SqFtLower"]="Sq Ft Lower";
idxExclude["rets29_SqFtMain"]="Sq Ft Main";
idxExclude["rets29_SqFtMaximumLease"]="Sq Ft Maximum Lease";
idxExclude["rets29_SqFtMinimumLease"]="Sq Ft Minimum Lease";
idxExclude["rets29_SqFtThird"]="Sq Ft Third";
idxExclude["rets29_SqFtUnheatedBasement"]="Sq Ft Unheated Basement";
idxExclude["rets29_SqFtUnheatedLower"]="Sq Ft Unheated Lower";
idxExclude["rets29_SqFtUnheatedMain"]="Sq Ft Unheated Main";
idxExclude["rets29_SqFtUnheatedThird"]="Sq Ft Unheated Third";
idxExclude["rets29_SqFtUnheatedTotal"]="Sq Ft Unheated Total";
idxExclude["rets29_SqFtUnheatedUpper"]="Sq Ft Unheated Upper";
idxExclude["rets29_SqFtUpper"]="Sq Ft Upper";
idxExclude["rets29_Status"]="Status";
idxExclude["rets29_StatusContractualSearchDate"]="Status Contractual Search Date";
idxExclude["rets29_Street"]="Street";
idxExclude["rets29_StreetDirPrefix"]="Street Dir Prefix";
idxExclude["rets29_StreetDirSuffix"]="Street Dir Suffix";
idxExclude["rets29_StreetName"]="Street Name";
idxExclude["rets29_StreetNumber"]="Street Number";
idxExclude["rets29_StreetNumberNumeric"]="Street Number Numeric";
idxExclude["rets29_StreetSuffix"]="Street Suffix";
idxExclude["rets29_StreetViewParam"]="Street View Param";
idxExclude["rets29_SuitableUse"]="Suitable Use";
idxExclude["rets29_Table"]="Table";
idxExclude["rets29_TenantPays"]="Tenant Pays";
idxExclude["rets29_TransactionType"]="Transaction Type";
idxExclude["rets29_UnitFloorLevel"]="Unit Floor Level";
idxExclude["rets29_UnitNumber"]="Unit Number";
idxExclude["rets29_VacancyRate"]="Vacancy Rate";
idxExclude["rets29_VirtualTourURLBranded"]="Virtual Tour URL Branded";
idxExclude["rets29_VirtualTourURLUnbranded"]="Virtual Tour URL Unbranded";
idxExclude["rets29_VOWAVMYN"]="Vowavmyn";
idxExclude["rets29_VOWConsumerCommentYN"]="VOW Consumer Comment YN";
idxExclude["rets29_WarehouseSqFt"]="Warehouse Sq Ft";
idxExclude["rets29_Water"]="Water";
idxExclude["rets29_WaterBodyName"]="Water Body Name";
idxExclude["rets29_WaterfrontFeatures"]="Waterfront Features";
idxExclude["rets29_WaterfrontYN"]="Waterfront YN";
idxExclude["rets29_WaterHeater"]="Water Heater";




idxExclude["rets29_TempOffMarketDate"]="Temp Off Market Date";


	tf=application.zcore.listingStruct.mlsStruct["29"].sharedStruct.metaStruct["property"].tableFields;
	n=0;
	for(curField in tf){  
		f2=tf[curField].longname; 
		n++;
		variables.allfields[n]={field:"rets29_"&curField, label:f2};
	}
		//idxExclude["rets29_virtualtoururl2"]="Virtual Tour Url 2"; 
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
		abort;
		</cfscript>
	</cffunction>

	<!--- <table class="ztablepropertyinfo"> --->
    <cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
      <cfargument name="idx" type="struct" required="yes">
      <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
 
		idxTemp2["rets29_equipment"]="Appliances";
		idxTemp2["rets29_SqFtTotal"]="Sq. Feet";
		idxTemp2["rets29_bathstotal"]="Total Baths";
		idxTemp2["rets29_bathsfull"]="Full Baths";
		idxTemp2["rets29_bathshalf"]="Half Baths";
		idxTemp2["rets29_bedstotal"]="Bedrooms";
		idxTemp2["rets29_FireplaceYN"]="Fireplace Yn";
		idxTemp2["rets29_Heating"]="Heating";
		idxTemp2["rets29_InteriorFeatures"]="Interior"; 
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Interior Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		    
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
    
    
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew(); 

		idxTemp2["rets29_yearbuilt"]="Year Built";
		idxTemp2["rets29_architecturalStyle"]="Style";
		idxTemp2["rets29_StoriesTotal"]="Stories";
		idxTemp2["rets29_communityfeatures"]="Community Features";
		idxTemp2["rets29_ExteriorConstruction"]="Construction";
		idxTemp2["rets29_ExteriorFeatures"]="Exterior";
		idxTemp2["rets29_LotFeatures"]="Lot Description";
		idxTemp2["rets29_LotSizeArea"]="Lot Size In Acres";
		idxTemp2["rets29_Parking"]="Garage Size/Parking";
		idxTemp2["rets29_utilitiescommercial"]="Utilities";
		idxTemp2["rets29_Zoning"]="Zoning";
		idxTemp2["rets29_CurrentPrice"]="Current Price";

		if(structkeyexists(arguments.idx, "rets29_ParcelNumber")){
			arguments.idx["rets29_ParcelNumber"]=replace(arguments.idx["rets29_ParcelNumber"], "Â", "-", "all");
		}

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Exterior Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		    
		return arraytolist(arrR,'');
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();  

 

		idxTemp2["rets29_City"]="City";
		idxTemp2["rets29_StateOrProvince"]="State";
		idxTemp2["rets29_postalcode"]="Zip";
		idxTemp2["rets29_CountyOrParish"]="County";
		idxTemp2["rets29_ElementarySchool"]="Elementary School";
		idxTemp2["rets29_SubdivisionName"]="Subdivision";
		idxTemp2["rets29_HighSchool"]="High School";
		idxTemp2["rets29_LastStatus"]="Last Status";
		idxTemp2["rets29_MiddleOrJuniorSchool"]="Middle/Junior School";

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Additional Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		     

		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
</cfoutput>
</cfcomponent>