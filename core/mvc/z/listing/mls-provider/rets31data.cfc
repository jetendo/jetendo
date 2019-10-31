<cfcomponent>
<cfoutput>
	<cfscript>
    variables.idxExclude=structnew();
	variables.allfields=structnew();
    </cfscript>
	<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" access="remote" roles="member" output="yes" returntype="any">
    	<cfscript>
	application.zcore.listingCom.makeListingImportDataReady();
	variables.idxExclude={};
	variables.idxExclude["rets31_BuyerAgentAOR"]="Buyer Agent Aor";
	variables.idxExclude["rets31_BuyerAgentDirectPhone"]="Buyer Agent Direct Phone";
	variables.idxExclude["rets31_BuyerAgentEmail"]="Buyer Agent Email";
	variables.idxExclude["rets31_BuyerAgentFullName"]="Buyer Agent Full Name";
	variables.idxExclude["rets31_BuyerAgentKeyNumeric"]="Buyer Agent Key Numeric";
	variables.idxExclude["rets31_BuyerAgentMlsId"]="Buyer Agent Mls Id";
	variables.idxExclude["rets31_BuyerOfficeKeyNumeric"]="Buyer Office Key Numeric";
	variables.idxExclude["rets31_BuyerOfficeMlsId"]="Buyer Office Mls Id";
	variables.idxExclude["rets31_BuyerOfficeName"]="Buyer Office Name";
	variables.idxExclude["rets31_BuyerOfficePhone"]="Buyer Office Phone";
	variables.idxExclude["rets31_BuyerOfficePhoneExt"]="Buyer Office Phone Ext";
	variables.idxExclude["rets31_InternetAddressDisplayYN"]="Internet Address Display Yn";
	variables.idxExclude["rets31_InternetAutomatedValuationDisplayYN"]="Internet Automated Valuation Dis";
	variables.idxExclude["rets31_InternetConsumerCommentYN"]="Internet Consumer Comment Yn";
	variables.idxExclude["rets31_InternetEntireListingDisplayYN"]="Internet Entire Listing Display ";
	variables.idxExclude["rets31_ListAgentAOR"]="List Agent Aor";
	variables.idxExclude["rets31_ListAgentDirectPhone"]="List Agent Direct Phone";
	variables.idxExclude["rets31_ListAgentEmail"]="List Agent Email";
	variables.idxExclude["rets31_ListAgentFullName"]="List Agent Full Name";
	variables.idxExclude["rets31_ListAgentKeyNumeric"]="List Agent Key Numeric";
	variables.idxExclude["rets31_ListAgentMlsId"]="List Agent Mls Id";
	variables.idxExclude["rets31_ListingAgreement"]="Listing Agreement";
	variables.idxExclude["rets31_ListingId"]="Listing Id";
	variables.idxExclude["rets31_ListingKeyNumeric"]="Listing Key Numeric";
	variables.idxExclude["rets31_ListOfficeKeyNumeric"]="List Office Key Numeric";
	variables.idxExclude["rets31_ListOfficeMlsId"]="List Office Mls Id";
	variables.idxExclude["rets31_ListOfficeName"]="List Office Name";
	variables.idxExclude["rets31_ListOfficePhone"]="List Office Phone";
	variables.idxExclude["rets31_ListOfficePhoneExt"]="List Office Phone Ext";
	variables.idxExclude["rets31_ModificationTimestamp"]="Modification Timestamp";
	variables.idxExclude["rets31_NonListedSoldYN"]="Non Listed Sold Yn";
	variables.idxExclude["rets31_OriginatingSystemKey"]="Originating System Key";
	variables.idxExclude["rets31_OriginatingSystemName"]="Originating System Name";
	variables.idxExclude["rets31_OriginatingSystemTimestamp"]="Originating System Timestamp";
	variables.idxExclude["rets31_OwnerName"]="Owner Name";
	variables.idxExclude["rets31_OwningOfficeKeyNumeric"]="Owning Office Key Numeric";
	variables.idxExclude["rets31_PhotosChangeTimestamp"]="Photos Change Timestamp";
	variables.idxExclude["rets31_PhotosCount"]="Photos Count";
	variables.idxExclude["rets31_PropertyManager"]="Property Manager";
	variables.idxExclude["rets31_PropertyManagerOnSiteYN"]="Property Manager On Site Yn";
	variables.idxExclude["rets31_PropertyManagerPhone"]="Property Manager Phone";
	variables.idxExclude["rets31_PurchaseContractDate"]="Purchase Contract Date";
	variables.idxExclude["rets31_RightofFirstRefusal"]="Rightof First Refusal";
	variables.idxExclude["rets31_SecondaryAssociationYN"]="Secondary Association Yn";
	variables.idxExclude["rets31_SpecialContingenciesApplyYN"]="Special Contingencies Apply Yn";
	variables.idxExclude["rets31_SpecialListingConditions"]="Special Listing Conditions";
	variables.idxExclude["rets31_OriginalEntryTimestamp"]="Original Entry Timestamp";
	variables.idxExclude["rets31_OriginalListPrice"]="Original List Price";
	variables.idxExclude["rets31_MajorChangeTimestamp"]="Major Change Timestamp";
	variables.idxExclude["rets31_MajorChangeType"]="Major Change Type";
	variables.idxExclude["rets31_PublicRemarks"]="Public Remarks";
	variables.idxExclude["rets31_VirtualTourURL"]="Virtual Tour Url";
	variables.idxExclude["rets31_DocumentsChangeTimestamp"]="Documents Change Timestamp";
	variables.idxExclude["rets31_DocumentsCount"]="Documents Count";
	variables.idxExclude["rets31_MlsMajorChangeType"]="Mls Major Change Type";
	variables.idxExclude["rets31_StreetDirPrefix"]="Street Dir Prefix";
	variables.idxExclude["rets31_StreetDirSuffix"]="Street Dir Suffix";
	variables.idxExclude["rets31_StreetName"]="Street Name";
	variables.idxExclude["rets31_StreetNumber"]="Street Number";
	variables.idxExclude["rets31_StreetNumberNumeric"]="Street Number Numeric";
	variables.idxExclude["rets31_StreetSuffix"]="Street Suffix";
	variables.idxExclude["rets31_City"]="City";
	variables.idxExclude["rets31_ListPrice"]="List Price";
	tf=application.zcore.listingStruct.mlsStruct["31"].sharedStruct.metaStruct["property"].tableFields;
	n=0;
	for(curField in tf){  
		f2=tf[curField].longname; 
		n++;
		variables.allfields[n]={field:"rets31_"&curField, label:f2};
	}

	application.zcore.listingCom=createobject("component", "zcorerootmapping.mvc.z.listing.controller.listing");
	// force allfields to not have the fields that already used
	this.getDetailCache1(structnew());
	this.getDetailCache2(structnew());
	this.getDetailCache3(structnew());
	
	if(structcount(variables.allfields) NEQ 0){
		writeoutput('<h2>All Fields:</h2>');
		uniqueStruct={};
		for(i in variables.allfields){
			if(structkeyexists(variables.idxExclude, variables.allfields[i].field) EQ false){
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
		
		idxTemp2["rets31_AccessAndTransportation"]="Access And Transportation";
		idxTemp2["rets31_AdditionalDepositsFees"]="Additional Deposits Fees";
		idxTemp2["rets31_AdditionalRooms"]="Additional Rooms";
		idxTemp2["rets31_AnnualRent"]="Annual Rent";
		idxTemp2["rets31_ApplicationFeeAmount"]="Application Fee Amount";
		idxTemp2["rets31_AsIsConditionYN"]="As Is Condition Yn";
		idxTemp2["rets31_AssessmentFeeAmount"]="Assessment Fee Amount";
		idxTemp2["rets31_AssociationApprovalRequiredYN"]="Association Approval Required Yn";
		idxTemp2["rets31_AssociationFee2"]="Association Fee 2";
		idxTemp2["rets31_AssociationFee2Frequemcy"]="Association Fee 2 Frequemcy";
		idxTemp2["rets31_AssociationFeeFrequency"]="Association Fee Frequency";
		idxTemp2["rets31_AssociationFeeIncludes"]="Association Fee Includes";
		idxTemp2["rets31_AssociationFeeYN"]="Association Fee Yn";
		idxTemp2["rets31_BathroomsFull"]="Bathrooms Full";
		idxTemp2["rets31_BathroomsHalf"]="Bathrooms Half";
		idxTemp2["rets31_BathroomsTotalDecimal"]="Bathrooms Total Decimal";
		idxTemp2["rets31_BathroomsTotalInteger"]="Bathrooms Total Interger";
		idxTemp2["rets31_BedroomsTotal"]="Bedrooms Total";
		idxTemp2["rets31_BuildingAreaSource"]="Building Area Source";
		idxTemp2["rets31_BuildingAreaTotal"]="Building Area Total";
		idxTemp2["rets31_BusinessAge"]="Business Age";
		idxTemp2["rets31_BusinessName"]="Business Name";
		idxTemp2["rets31_BusinessOnlyYN"]="Business Only Yn";
		idxTemp2["rets31_BusinessType"]="Business Type";
		idxTemp2["rets31_CandRYN"]="Cand Ryn";
		idxTemp2["rets31_Cleared"]="Cleared";
		idxTemp2["rets31_ClearSpan"]="Clear Span";
		idxTemp2["rets31_CommercialClass"]="Commercial Class";
		idxTemp2["rets31_Community55PlusYN"]="Community 55 Plus Yn";
		idxTemp2["rets31_ConfidentialListingYN"]="Confidential Listing Yn";
		idxTemp2["rets31_Construction"]="Construction";
		idxTemp2["rets31_Cooling"]="Cooling";
		idxTemp2["rets31_CurrentlyLeasedYN"]="Currently Leased Yn";
		idxTemp2["rets31_DateAvailable"]="Date Available";
		idxTemp2["rets31_DisasterMitigation"]="Disaster Mitigation";
		idxTemp2["rets31_DockAssociationDuesMQA"]="Dock Association Dues Mqa";
		idxTemp2["rets31_DockAssociationFee"]="Dock Association Fee";
		idxTemp2["rets31_DockAssociationYN"]="Dock Association Yn";
		idxTemp2["rets31_DockFacilityName"]="Dock Facility Name";
		idxTemp2["rets31_DockGoverningBody"]="Dock Governing Body";
		idxTemp2["rets31_DockHarbormasterYN"]="Dock Harbormaster Yn";
		idxTemp2["rets31_DockLiftCapacity"]="Dock Lift Capacity";
		idxTemp2["rets31_DockLiftYN"]="Dock Lift Yn";
		idxTemp2["rets31_DockMaintenanceExpensesPaidBy"]="Dock Maintenance Expenses Paid B";
		idxTemp2["rets31_DockMaintenanceFees"]="Dock Maintenance Fees";
		idxTemp2["rets31_DockMarinaAmenities"]="Dock Marina Amenities";
		idxTemp2["rets31_DockMonitorVHF16YN"]="Dock Monitor Vhf 16 Yn";
		idxTemp2["rets31_DockMoorage"]="Dock Moorage";
		idxTemp2["rets31_DockOvernightRestrictYN"]="Dock Overnight Restrict Yn";
		idxTemp2["rets31_DockOwnershipRequiredYN"]="Dock Ownership Required Yn";
		idxTemp2["rets31_DockParkingAvailableYN"]="Dock Parking Available Yn";
		idxTemp2["rets31_DockRestrictionsDescription"]="Dock Restrictions Description";
		idxTemp2["rets31_DockSlipAmenities"]="Dock Slip Amenities";
		idxTemp2["rets31_DockSlipSizeLength"]="Dock Slip Size Length";
		idxTemp2["rets31_DockSlipSizeWidth"]="Dock Slip Size Width";
		idxTemp2["rets31_DockSlipStorageYN"]="Dock Slip Storage Yn";
		idxTemp2["rets31_DockWastePumpYN"]="Dock Waste Pump Yn";
		idxTemp2["rets31_Electric"]="Electric";
		idxTemp2["rets31_ElectricalExpenses"]="Electrical Expenses";
		idxTemp2["rets31_EquipmentAndAppliances"]="Equipment And Appliances";
		idxTemp2["rets31_FractionalOwnershipPerc"]="Fractional Ownership Perc";
		idxTemp2["rets31_FreestandingYN"]="Freestanding Yn";
		idxTemp2["rets31_Furnished"]="Furnished";
		idxTemp2["rets31_GasAverageperMonth"]="Gas Averageper Month";
		idxTemp2["rets31_GreenCertification"]="Green Certification";
		idxTemp2["rets31_GreenEnergyFeatures"]="Green Energy Features";
		idxTemp2["rets31_GreenEnergyGeneral"]="Green Energy General";
		idxTemp2["rets31_GreenLandscaping"]="Green Landscaping";
		idxTemp2["rets31_GreenWaterFeatures"]="Green Water Features";
		idxTemp2["rets31_GrossIncome"]="Gross Income";
		idxTemp2["rets31_GroundExpenses"]="Ground Expenses";
		idxTemp2["rets31_GroundFloorBedroomYN"]="Ground Floor Bedroom Yn";
		idxTemp2["rets31_GroundFloorMasterBedroomYN"]="Ground Floor Master Bedroom Yn";
		idxTemp2["rets31_Heating"]="Heating";
		idxTemp2["rets31_HotWaterHeater"]="Hot Water Heater";
		idxTemp2["rets31_HowSold"]="How Sold";
		idxTemp2["rets31_ILSAttachedYN"]="Ils Attached Yn";
		idxTemp2["rets31_ILSBathrooms"]="Ils Bathrooms";
		idxTemp2["rets31_ILSBedrooms"]="Ils Bedrooms";
		idxTemp2["rets31_ILSKitchenYN"]="Ils Kitchen Yn";
		idxTemp2["rets31_ILSSeparateEntranceYN"]="Ils Separate Entrance Yn";
		idxTemp2["rets31_ILSTotalSQFT"]="Ils Total Sqft";
		idxTemp2["rets31_ILSUnderAirSQFT"]="Ils Under Air Sqft";
		idxTemp2["rets31_IncludedInSale"]="Included In Sale";
		idxTemp2["rets31_IncluInMonthlyLeaseAmnt"]="Inclu In Monthly Lease Amnt";
		idxTemp2["rets31_IndoorAirQuality"]="Indoor Air Quality";
		idxTemp2["rets31_InLawSuiteYN"]="In Law Suite Yn";
		idxTemp2["rets31_InsuranceExpenses"]="Insurance Expenses";
		idxTemp2["rets31_InteriorImprovements"]="Interior Improvements";
		idxTemp2["rets31_Irrigation"]="Irrigation";
		idxTemp2["rets31_LandDimensions"]="Land Dimensions";
		idxTemp2["rets31_LandStyle"]="Land Style";
		idxTemp2["rets31_LandUse"]="Land Use";
		idxTemp2["rets31_LeaseAmountFrequency"]="Lease Amount Frequency";
		idxTemp2["rets31_LeaseInfo"]="Lease Info";
		idxTemp2["rets31_LeaseProvisions"]="Lease Provisions";
		idxTemp2["rets31_LeaseTerms"]="Lease Terms";
		idxTemp2["rets31_ListAOR"]="List Aor";
		idxTemp2["rets31_ListingArea"]="Listing Area";
		idxTemp2["rets31_ListingContractDate"]="Listing Contract Date";
		idxTemp2["rets31_ListingService"]="Listing Service";
		idxTemp2["rets31_LivingArea"]="Living Area";
		idxTemp2["rets31_LivingAreaSource"]="Living Area Source";
		idxTemp2["rets31_LNDProjectPhase"]="Lnd Project Phase";
		idxTemp2["rets31_LoadingDock"]="Loading Dock";
		idxTemp2["rets31_LocationDescription"]="Location Description";
		idxTemp2["rets31_LotSizeAcres"]="Lot Size Acres";
		idxTemp2["rets31_LotSizeDimension"]="Lot Size Dimension";
		idxTemp2["rets31_MaintenanceExpenses"]="Maintenance Expenses";
		idxTemp2["rets31_ManagementExpenses"]="Management Expenses";
		idxTemp2["rets31_MasterAssociation"]="Master Association";
		idxTemp2["rets31_MasterBath"]="Master Bath";
		idxTemp2["rets31_MaxRatedOccupancy"]="Max Rated Occupancy";
		idxTemp2["rets31_MinimalRentalAllowed"]="Minimal Rental Allowed";
		idxTemp2["rets31_MinimumLease"]="Minimum Lease";
		idxTemp2["rets31_MlsStatus"]="Mls Status";
		idxTemp2["rets31_NetIncome"]="Net Income";
		idxTemp2["rets31_NoDriveBeach"]="No Drive Beach";
		idxTemp2["rets31_NumberOfUnitsInCommunity"]="Number Of Units In Community";
		idxTemp2["rets31_NumDishwashers"]="Num Dishwashers";
		idxTemp2["rets31_NumDryers"]="Num Dryers";
		idxTemp2["rets31_NumElectricMeters"]="Num Electric Meters";
		idxTemp2["rets31_NumGasMeters"]="Num Gas Meters";
		idxTemp2["rets31_NumMicrowaves"]="Num Microwaves";
		idxTemp2["rets31_NumOverheadDoors"]="Num Overhead Doors";
		idxTemp2["rets31_NumRanges"]="Num Ranges";
		idxTemp2["rets31_NumRefrigerators"]="Num Refrigerators";
		idxTemp2["rets31_NumWasherDryerHookupsOnly"]="Num Washer Dryer Hookups Only";
		idxTemp2["rets31_NumWashers"]="Num Washers";
		idxTemp2["rets31_NumWaterMeters"]="Num Water Meters";
		idxTemp2["rets31_Occupancy"]="Occupancy";
		idxTemp2["rets31_OfficeSqFt"]="Office Sq Ft";
		idxTemp2["rets31_OperatingExpenses"]="Operating Expenses";
		idxTemp2["rets31_OtherAvailbleFeatures"]="Other Availble Features";
		idxTemp2["rets31_OwnershipRequiredNotes"]="Ownership Required Notes";
		idxTemp2["rets31_ParkingFeatures"]="Parking Features";
		idxTemp2["rets31_PetComments"]="Pet Comments";
		idxTemp2["rets31_PetFeeAmount"]="Pet Fee Amount";
		idxTemp2["rets31_PetNumberAllowed"]="Pet Number Allowed";
		idxTemp2["rets31_PetRestrictionsYN"]="Pet Restrictions Yn";
		idxTemp2["rets31_PetRestrictionTypes"]="Pet Restriction Types";
		idxTemp2["rets31_PetSizeRestriction"]="Pet Size Restriction";
		idxTemp2["rets31_Pool"]="Pool";
		idxTemp2["rets31_PoolFeatures"]="Pool Features";
		idxTemp2["rets31_Possession"]="Possession";
		idxTemp2["rets31_RentalStorageUnit"]="Rental Storage Unit";
		idxTemp2["rets31_RentperMonth"]="Rentper Month";
		idxTemp2["rets31_RLSECleaningFee"]="Rlse Cleaning Fee";
		idxTemp2["rets31_RLSEFees"]="Rlse Fees";
		idxTemp2["rets31_RLSEPetDeposit"]="Rlse Pet Deposit";
		idxTemp2["rets31_RoadAccessYN"]="Road Access Yn";
		idxTemp2["rets31_RoadFrontageDepth"]="Road Frontage Depth";
		idxTemp2["rets31_Security"]="Security";
		idxTemp2["rets31_SecurityAndMisc"]="Security And Misc";
		idxTemp2["rets31_SecurityDepositAmount"]="Security Deposit Amount";
		idxTemp2["rets31_Sewer"]="Sewer";
		idxTemp2["rets31_SiteImprovements"]="Site Improvements";
		idxTemp2["rets31_SplitBRYN"]="Split Bryn";
		idxTemp2["rets31_StandardStatus"]="Standard Status";
		idxTemp2["rets31_StateOrProvince"]="State Or Province";
		idxTemp2["rets31_Stories"]="Stories";
		idxTemp2["rets31_StoriesTotal"]="Stories Total";
		idxTemp2["rets31_SubSubDivision"]="Sub Sub Division";
		idxTemp2["rets31_SyndicateTo"]="Syndicate To";
		idxTemp2["rets31_TenantExpenses"]="Tenant Expenses";
		idxTemp2["rets31_TotalIncome"]="Total Income";
		idxTemp2["rets31_TotalLeases"]="Total Leases";
		idxTemp2["rets31_TypeOfBuisness"]="Type Of Buisness";
		idxTemp2["rets31_TypeStreet"]="Type Street";
		idxTemp2["rets31_UnitFaces"]="Unit Faces";
		idxTemp2["rets31_UnitFloorNumber"]="Unit Floor Number";
		idxTemp2["rets31_UseAndPossibleUse"]="Use And Possible Use";
		idxTemp2["rets31_UtilitiesOnSite"]="Utilities On Site";
		idxTemp2["rets31_UtlitiesAndFuel"]="Utlities And Fuel";
		idxTemp2["rets31_WasherDryer"]="Washer Dryer";
		idxTemp2["rets31_Water"]="Water";
		idxTemp2["rets31_WaterAndSewer"]="Water And Sewer";
		idxTemp2["rets31_WaterExpenses"]="Water Expenses";
		idxTemp2["rets31_WaterFrontageFeet"]="Water Frontage Feet";
		idxTemp2["rets31_WaterFrontageYN"]="Water Frontage Yn";
		idxTemp2["rets31_WaterfrontFeatures"]="Waterfront Features";
		idxTemp2["rets31_WaterIinformation"]="Water Iinformation";
		idxTemp2["rets31_WaterOther"]="Water Other";
		idxTemp2["rets31_WaterViewYN"]="Water View Yn";
		idxTemp2["rets31_WindowFeatures"]="Window Features";
		idxTemp2["rets31_YearBuiltSource"]="Year Built Source";
		idxTemp2["rets31_Zoning"]="Zoning";
		idxTemp2["rets31_AssociationFee"]="Association Fee";
		idxTemp2["rets31_CeilingHeight"]="Ceiling Height";
		idxTemp2["rets31_CloseDate"]="Close Date";
		idxTemp2["rets31_ClosePrice"]="Close Price";
		idxTemp2["rets31_ComplexName"]="Complex Name";
		idxTemp2["rets31_CountyOrParish"]="County Or Parish";
		idxTemp2["rets31_Directions"]="Directions";
		idxTemp2["rets31_ExteriorFeatures"]="Exterior Features";
		idxTemp2["rets31_InteriorFeatures"]="Interior Features";
		idxTemp2["rets31_LegalDescription"]="Legal Description";
		idxTemp2["rets31_NumEmployees"]="Num Employees";
		idxTemp2["rets31_NumParkingSpaces"]="Num Parking Spaces";
		idxTemp2["rets31_OtherExpenses"]="Other Expenses";
		idxTemp2["rets31_ParcelNumber"]="Parcel Number";
		idxTemp2["rets31_PetsAllowedYN"]="Pets Allowed Yn";
		idxTemp2["rets31_PostalCode"]="Postal Code";
		idxTemp2["rets31_PropertySubType"]="Property Sub Type";
		idxTemp2["rets31_PropertyType"]="Property Type";
		idxTemp2["rets31_RentIncludes"]="Rent Includes";
		idxTemp2["rets31_Roof"]="Roof";
		idxTemp2["rets31_SubdivisionName"]="Subdivision Name";
		idxTemp2["rets31_TotalUnits"]="Total Units";
		idxTemp2["rets31_TransactionType"]="Transaction Type";
		idxTemp2["rets31_UnitNumber"]="Unit Number";
		idxTemp2["rets31_WithdrawnDate"]="Withdrawn Date";
		idxTemp2["rets31_YearBuilt"]="Year Built";
  
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Features", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
    
    
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
		// exterior features 
		//arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Exterior Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		return arraytolist(arrR,'');
		
		
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew(); 
		/*
idxTemp2["rets31_yearbuilt"]="Year Built";
if(application.zcore.functions.zso(arguments.idx, 'rets31_virtualtoururl2') NEQ ""){
	arrayAppend(arrR, '<a href="#arguments.idx.rets31_virtualtoururl2#" target="_blank">View Virtual Tour Link 2</a>');
}*/
		//arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Additional Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		

		idxTemp2=structnew(); 
		
		//arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial &amp; Legal Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		
		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
</cfoutput>
</cfcomponent>