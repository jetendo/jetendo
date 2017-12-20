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
idxExclude["rets29_ArchitecturalStyle"]="Architectural Style";
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
idxExclude["rets29_YearBuilt"]="Year Built";
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
		application.zcore.functions.zabort();</cfscript>
	</cffunction>

	<!--- <table class="ztablepropertyinfo"> --->
    <cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
      <cfargument name="idx" type="struct" required="yes">
      <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();
 
		idxTemp2["rets29_SqFtAdditional"]="Sq Ft Additional";
		idxTemp2["rets29_SqFtBasement"]="Sq Ft Basement";
		idxTemp2["rets29_SqFtLower"]="Sq Ft Lower";
		idxTemp2["rets29_SqFtMain"]="Sq Ft Main";
		idxTemp2["rets29_SqFtThird"]="Sq Ft Third";
		idxTemp2["rets29_SqFtTotal"]="Sq Ft Total";
		idxTemp2["rets29_SqFtUnheatedBasement"]="Sq Ft Unheated Basement";
		idxTemp2["rets29_SqFtUpper"]="Sq Ft Upper";
		idxTemp2["rets29_Water"]="Water";
		idxTemp2["rets29_FireplaceDescription"]="Fireplace Description";
		idxTemp2["rets29_FireplaceYN"]="Fireplace Yn";
		idxTemp2["rets29_Flooring"]="Flooring";
		idxTemp2["rets29_Heating"]="Heating";
		idxTemp2["rets29_RoomCount"]="Room Count";
		idxTemp2["rets29_SecondLivingQuarters"]="Second Living Quarters";
		idxTemp2["rets29_InteriorFeatures"]="Interior Features"; 
		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Interior Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		    
		return arraytolist(arrR,'');
		
		</cfscript>
	</cffunction>
    
    
	<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew(); 

 
		idxTemp2["rets29_Access"]="Access";
		idxTemp2["rets29_AcresCleared"]="Acres Cleared";
		idxTemp2["rets29_UnitCount"]="Unit Count";
		idxTemp2["rets29_UnitFloorLevel"]="Unit Floor Level";
		idxTemp2["rets29_UnitNumber"]="Unit Number";
		idxTemp2["rets29_CommunityFeatures"]="Community Features";

		idxTemp2["rets29_Driveway"]="Driveway";

		idxTemp2["rets29_ExteriorConstruction"]="Exterior Construction";
		idxTemp2["rets29_ExteriorFeatures"]="Exterior Features";
		idxTemp2["rets29_LotFeatures"]="Lot Features";
		idxTemp2["rets29_LotSizeArea"]="Lot Size Area In Acres";
		idxTemp2["rets29_ParcelNumber"]="Parcel Number";
		idxTemp2["rets29_Parking"]="Parking";
		idxTemp2["rets29_Porch"]="Porch";

		idxTemp2["rets29_PropertySubType"]="Property Sub Type";
		idxTemp2["rets29_PropertySubTypeSecondary"]="Property Sub Type Secondary";
		idxTemp2["rets29_PropertyType"]="Property Type";
		idxTemp2["rets29_Roof"]="Roof";

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Exterior Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		    
		return arraytolist(arrR,'');
		
		</cfscript>
    </cffunction>
    <cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
        <cfargument name="idx" type="struct" required="yes">
        <cfscript>
		var arrR=arraynew(1);
		var idxTemp2=structnew();  

 

		idxTemp2["rets29_WebURL"]="Web Url";
		idxTemp2["rets29_WithdrawnDate"]="Withdrawn Date";
		idxTemp2["rets29_BuilderName"]="Builder Name";
		idxTemp2["rets29_CompanyRemarks"]="Company Remarks";
		idxTemp2["rets29_Construction"]="Construction";
		idxTemp2["rets29_ConstructionType"]="Construction Type";
		idxTemp2["rets29_VirtualTourURLUnbranded"]="Virtual Tour Url Unbranded";
		idxTemp2["rets29_VOWAVMYN"]="Vowavmyn";
		idxTemp2["rets29_CCRSubjectToYN"]="Ccr Subject To Yn";
		idxTemp2["rets29_City"]="City";
		idxTemp2["rets29_CompleName"]="Complex Name";
		idxTemp2["rets29_Country"]="Country";
		idxTemp2["rets29_CountyOrParish"]="County Or Parish";
		idxTemp2["rets29_Directions"]="Directions";
		idxTemp2["rets29_ElementarySchool"]="Elementary School";
		idxTemp2["rets29_Elevation"]="Elevation";
		idxTemp2["rets29_Equipment"]="Equipment";
		idxTemp2["rets29_LaundryLocation"]="Laundry Location";
		idxTemp2["rets29_LeaseTerm"]="Lease Term";
		idxTemp2["rets29_LeaseYN"]="Lease Yn";
		idxTemp2["rets29_ListingType"]="Listing Type";
		idxTemp2["rets29_LotDimension"]="Lot Dimension";
		idxTemp2["rets29_OwnershipType"]="Ownership Type";
		idxTemp2["rets29_PetsAllowed"]="Pets Allowed";
		idxTemp2["rets29_Restrictions"]="Restrictions";
		idxTemp2["rets29_StateOrProvince"]="State Or Province";
		idxTemp2["rets29_Street"]="Street";
		idxTemp2["rets29_StreetDirPrefix"]="Street Dir Prefix";
		idxTemp2["rets29_StreetDirSuffix"]="Street Dir Suffix";
		idxTemp2["rets29_StreetName"]="Street Name";
		idxTemp2["rets29_StreetNumberNumeric"]="Street Number Numeric";
		idxTemp2["rets29_StreetSuffix"]="Street Suffix";
		idxTemp2["rets29_SubdivisionName"]="Subdivision Name";
		idxTemp2["rets29_CDOM"]="Cdom";
		idxTemp2["rets29_CorrectionCount"]="Correction Count";
		idxTemp2["rets29_DOM"]="Dom";
		idxTemp2["rets29_FoundationDetails"]="Foundation Details";
		idxTemp2["rets29_GreenBuildingFeatures"]="Green Building Features";
		idxTemp2["rets29_GreenCertification"]="Green Certification";
		idxTemp2["rets29_GreenHERSScore"]="Green Hers Score";
		idxTemp2["rets29_HighSchool"]="High School";
		idxTemp2["rets29_Improvements"]="Improvements";
		idxTemp2["rets29_LastStatus"]="Last Status";
		idxTemp2["rets29_MiddleOrJuniorSchool"]="Middle Or Junior School";
		idxTemp2["rets29_Miscellaneous"]="Miscellaneous";
		idxTemp2["rets29_NewConstructionYN"]="New Construction Yn";
		idxTemp2["rets29_OpenHouseCount"]="Open House Count";
		idxTemp2["rets29_OpenHouseUpcoming"]="Open House Upcoming";
		idxTemp2["rets29_OriginalListPrice"]="Original List Price";
		idxTemp2["rets29_PhotoCount"]="Photo Count";
		idxTemp2["rets29_ProposedCompletionDate"]="Proposed Completion Date";
		idxTemp2["rets29_PublicallyMaintainedRoad"]="Publically Maintained Road";
		idxTemp2["rets29_Sewer"]="Sewer";
		idxTemp2["rets29_Status"]="Status";
		idxTemp2["rets29_CurrentPrice"]="Current Price";

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Additional Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
		     
		idxTemp2=structnew(); 
		
		
		idxTemp2["rets29_Zoning"]="Zoning";
		idxTemp2["rets29_ZoningSpecification"]="Zoning Specification";
		idxTemp2["rets29_AssociationFee"]="Association Fee";
		idxTemp2["rets29_AssociationFeeFrequency"]="Association Fee Frequency";
		idxTemp2["rets29_AuctionYN"]="Auction Yn";
		idxTemp2["rets29_SyndicationRemarks"]="Syndication Remarks";
		idxTemp2["rets29_TaxAmountNCM"]="Tax Amount Ncm";
		idxTemp2["rets29_SoldTerms"]="Sold Terms";

		arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial &amp; Legal Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));

		return arraytolist(arrR,'');
		</cfscript>
	</cffunction>
</cfoutput>
</cfcomponent>