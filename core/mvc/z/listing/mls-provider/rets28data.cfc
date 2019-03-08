<cfcomponent>
<cfoutput>
	<cfscript>
    variables.idxExclude=structnew();
variables.allfields=structnew();
    </cfscript>
<cffunction name="findFieldsInDatabaseNotBeingOutput" localmode="modern" output="yes" returntype="any"> 
	<cfscript>  
	application.zcore.listingCom.makeListingImportDataReady();
	idxExclude={};
	tf=application.zcore.listingStruct.mlsStruct["28"].sharedStruct.metaStruct["property"].tableFields;
	n=0;
	for(curField in tf){  
		f2=tf[curField].longname; 
		n++;
		variables.allfields[n]={field:"rets28_"&curField, label:f2};
	}
	application.zcore.listingCom=createobject("component", "zcorerootmapping.mvc.z.listing.controller.listing");
	// force allfields to not have the fields that already used
	this.getDetailCache1(structnew());
	this.getDetailCache2(structnew());
	this.getDetailCache3(structnew());


idxExclude["rets28_monthlyrent"]="Total Income";
idxExclude["rets28_totalleases"]="Total Leases";
idxExclude["rets28_roadfrontage"]="Road Frontage Depth";
idxExclude["rets28_slipamenities"]="Slip Amenities";
idxExclude["rets28_slipdraft"]="Slip Draft";
idxExclude["rets28_slipstorageyn"]="Slip Storage Y/n";
idxExclude["rets28_marinaamenities"]="Marina Amenities";
idxExclude["rets28_stories"]="Levels";
idxExclude["rets28_windowtrtmnt"]="Window Treatment";
idxExclude["rets28_city"]="Address City";
idxExclude["rets28_county"]="Address County";
idxExclude["rets28_stateorprovince"]="Address State";
idxExclude["rets28_direction"]="Address Street Direction";
idxExclude["rets28_streetname"]="Address Street Name";
idxExclude["rets28_streetnumber"]="Address Street Number";
idxExclude["rets28_postalcode"]="Address Zip Code";
idxExclude["rets28_variableratecommyn"]="Variable Rate Commission Y/n";
idxExclude["rets28_possession"]="Possession";
idxExclude["rets28_nonrepcommdesc"]="Non-representative Commission De";
idxExclude["rets28_pendingagentagentid"]="Pending Agent Id";
idxExclude["rets28_pendingofficeofficeid"]="Pending Agent Office";
idxExclude["rets28_originalsellingfirmname"]="Original Selling Firm Name";
idxExclude["rets28_originallistingfirmname"]="Original Listing Firm Name";
idxExclude["rets28_howsolddesc"]="How Sold Description";
idxExclude["rets28_buyeragentcommamount"]="Buyer Agent Commission Amount";
idxExclude["rets28_buyername"]="Buyer Name";
idxExclude["rets28_commentaryyn"]="Commentary Y/n";
idxExclude["rets28_concessionamount"]="Concession Amount";
idxExclude["rets28_colistingagentid"]="Co-list Agent Id";
idxExclude["rets28_colistingagentname"]="Co-list Agent Name";
idxExclude["rets28_colistingofficeid"]="Co-list Agent Office";
idxExclude["rets28_colistingofficename"]="Co-list Agent Office Name";
idxExclude["rets28_cosellingagentid"]="Co-sell Agent Id";
idxExclude["rets28_cosellagentname"]="Co-sell Agent Name";
idxExclude["rets28_cosellingofficeid"]="Co-sell Agent Office";
idxExclude["rets28_cosellingofficename"]="Co-sell Agent Office Name";
idxExclude["rets28_idx"]="Idx Y/n";
idxExclude["rets28_officeidx"]="Office Idx";
idxExclude["rets28_officesqft"]="Office Sqft";
idxExclude["rets28_officestatus"]="Office Status";
idxExclude["rets28_documentsanddisclosures"]="Documents And Disclosures";
idxExclude["rets28_modificationtimestamp"]="Date Recap";
idxExclude["rets28_dateownershiptransfer"]="Date Ownership Transfer";
idxExclude["rets28_datelistingconfirmed"]="Date Listing Confirmed";
idxExclude["rets28_datelistingunconfirmed"]="Date Listing Unconfirmed";
idxExclude["rets28_dateexpirationextended"]="Date Expiration Extended";
idxExclude["rets28_statuschangedate"]="Date History Status";
idxExclude["rets28_clearspan"]="Clear Span";
idxExclude["rets28_licensedrealtoryn"]="Licensed Realtor Y/n";
idxExclude["rets28_limitedserviceyn"]="Limited Service Y/n";
idxExclude["rets28_listagentkey"]="List Agent Key";
idxExclude["rets28_listingboardid"]="Listing Agent Board Id";
idxExclude["rets28_listingagentid"]="Listing Agent Id";
idxExclude["rets28_listingagentname"]="Listingagentname";
idxExclude["rets28_listingofficeid"]="Listing Agent Office Id";
idxExclude["rets28_listagentagentid"]="Listing Agent Uid";
idxExclude["rets28_listingdetail"]="Listing Detail";
idxExclude["rets28_listingfirmid"]="Listing Firm Id";
idxExclude["rets28_listofficeofficeid"]="Listing Office";
idxExclude["rets28_listofficeaffilliation"]="Listing Office Affiliation";
idxExclude["rets28_rentalcompensation"]="Rental Compensation";
idxExclude["rets28_backupoffersacceptedyn"]="Back-up Offers Accepted Y/n";
idxExclude["rets28_assessmentdesc"]="Assessment Description";
idxExclude["rets28_propertyformat"]="Property Format";
idxExclude["rets28_property_id"]="Property id";
	 
	if(structcount(variables.allfields) NEQ 0){
		//writeoutput('<h2>All Fields:</h2>');
		arrKey=structsort(variables.allfields, "text", "asc", "label");
		for(i=1;i LTE arraylen(arrKey);i++){
			if(structkeyexists(idxExclude, variables.allfields[arrKey[i]].field) EQ false){
				writeoutput('idxTemp2["'&variables.allfields[arrKey[i]].field&'"]="'&replace(application.zcore.functions.zfirstlettercaps(variables.allfields[arrKey[i]].label),"##","####")&'";<br />');
			}
		}
	}
	application.zcore.functions.zabort();
	</cfscript>
</cffunction>

<cffunction name="getDetailCache1" localmode="modern" output="yes" returntype="string">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var arrR=arraynew(1);
	var idxTemp2=structnew();  

//idxTemp2["rets28_list_44"]="## Parking"; 
	arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Property Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
	    idxTemp2["rets28_parkingtotal"]="## Parking Spaces";
idxTemp2["rets28_lotsizearea"]="Acres - Total";
idxTemp2["rets28_subdivision"]="Address Subdivision Name";
idxTemp2["rets28_unitnumber"]="Address Unit Number";
idxTemp2["rets28_apxbuildingsqft"]="Apx Building Sqft";
idxTemp2["rets28_slipsize"]="Apx Slip Size";
idxTemp2["rets28_listingarea"]="Area / Zone Code";
idxTemp2["rets28_commercialclass"]="Commercial Property Type";
idxTemp2["rets28_complexunits"]="Commercial Units";
idxTemp2["rets28_communityname"]="Community Name";
idxTemp2["rets28_complexname"]="Complex Name";
idxTemp2["rets28_construction"]="Construction";
idxTemp2["rets28_constructionmaterial"]="Construction Type";
idxTemp2["rets28_cooling"]="Cooling";
idxTemp2["rets28_maxratedoccupancy"]="Current Occupancy Rate";
idxTemp2["rets28_landdimensions"]="Landdimensions";
idxTemp2["rets28_landstyle"]="Land Style";
idxTemp2["rets28_landtype"]="Land Type";
idxTemp2["rets28_futurelanduse"]="Land Use";
idxTemp2["rets28_nearhighwayyn"]="Near Highway Y/n";
idxTemp2["rets28_nodrivebeachyn"]="No Drive Beach Y/n";
idxTemp2["rets28_hoayn"]="Home Owners Association Y/n";
idxTemp2["rets28_locationdescription"]="Location Description";
idxTemp2["rets28_lotsize"]="Lot Size";
idxTemp2["rets28_yearbuilt"]="Year Built";
idxTemp2["rets28_zoning"]="Zoning";
idxTemp2["rets28_utilitiesonsite"]="Utilities On Site";
idxTemp2["rets28_utlitiesandfuel"]="Utlities And Fuel";
idxTemp2["rets28_parking"]="Parking";
// idxTemp2["rets28_betweenus1andriver"]="Right Of Way Y/n";
idxTemp2["rets28_roadaccessyn"]="Road Access Y/n";
idxTemp2["rets28_elementaryschool"]="School - Elementary";
idxTemp2["rets28_highschool"]="School - High";
idxTemp2["rets28_middleschool"]="School - Middle";
idxTemp2["rets28_security"]="Security";
idxTemp2["rets28_securityandmisc"]="Security And Misc";
idxTemp2["rets28_washers"]="Washers";
idxTemp2["rets28_wastepumpyn"]="Waste Pump Y/n";
idxTemp2["rets28_water"]="Water";
idxTemp2["rets28_waterandsewer"]="Water And Sewer";
idxTemp2["rets28_waterfeatures"]="Water Features";
idxTemp2["rets28_watermainsize"]="Water Main Size";
idxTemp2["rets28_watermeters"]="Water Meters";
idxTemp2["rets28_waterother"]="Water-other";
idxTemp2["rets28_watertype"]="Water Type";
idxTemp2["rets28_windowsandwindowtrtmnt"]="Windows And Window Treatment";
idxTemp2["rets28_propertysubtype"]="Property Sub-type";
idxTemp2["rets28_propertytype"]="Property Type";
idxTemp2["rets28_projectphase"]="Project Phase";
idxTemp2["rets28_age"]="Property Age";
idxTemp2["rets28_titleinsuranceavailable"]="Property Insurance";
idxTemp2["rets28_sewer"]="Sewer";
	arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Rental Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
	   
idxTemp2["rets28_accessandtransportation"]="Access And Transportation";
idxTemp2["rets28_appliances"]="Appliances";
idxTemp2["rets28_asisconditionyn"]="As Is Condition Y/n";
idxTemp2["rets28_assessment"]="Assessment";
idxTemp2["rets28_attachmentyn"]="Attachment Y/n";
idxTemp2["rets28_availablewithlease"]="Available With Lease";
idxTemp2["rets28_gasexpense"]="Gas Average Per Month";
idxTemp2["rets28_gasmeters"]="Gas Meters";
idxTemp2["rets28_rentalpropertytype"]="Rental Property Type";
idxTemp2["rets28_rentalyn"]="Rental Y/n";
idxTemp2["rets28_rentincludes"]="Rentincludes";
idxTemp2["rets28_rentalrestrictions"]="Restrictions Description";
idxTemp2["rets28_unit1monthlyrent"]="Unit 1 Monthly Rent";
idxTemp2["rets28_unit2monthlyrent"]="Unit 2 Monthly Rent";
idxTemp2["rets28_unit3monthlyrent"]="Unit 3 Monthly Rent";
idxTemp2["rets28_unit4monthlyrent"]="Unit 4 Monthly Rent";
idxTemp2["rets28_annualrent"]="Annual Rent";
idxTemp2["rets28_rentlow"]="Rent - Low";
idxTemp2["rets28_rentalamount"]="Rent Per Month";
idxTemp2["rets28_dateleased"]="Date Leased";
idxTemp2["rets28_incluinmonthlyleaseamnt"]="Include In Monthly Lease Amount";
idxTemp2["rets28_leaseinfo"]="Lease Info";
idxTemp2["rets28_leaseoption"]="Lease Option Y/n/u";
idxTemp2["rets28_leaseprovisions"]="Lease Provisions";
idxTemp2["rets28_leaseterms"]="Lease Terms";
idxTemp2["rets28_currentlyleasedyn"]="Lease Y/n";
	return arraytolist(arrR,'');
	
	</cfscript>
</cffunction>

<cffunction name="getDetailCache2" localmode="modern" output="yes" returntype="string">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var arrR=arraynew(1);
	var idxTemp2=structnew();  
	arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Room Information", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));
idxTemp2["rets28_additionalrooms"]="Additionalrooms";
idxTemp2["rets28_bathstotal"]="Baths";
idxTemp2["rets28_bedroom1length"]="Bedroom 1 Length";
idxTemp2["rets28_bedroom1width"]="Bedroom 1 Width";
idxTemp2["rets28_bedroom2length"]="Bedroom 2 Length";
idxTemp2["rets28_bedroom2width"]="Bedroom 2 Width";
idxTemp2["rets28_bedroom3length"]="Bedroom 3 Length";
idxTemp2["rets28_bedroom3width"]="Bedroom 3 Width";
idxTemp2["rets28_bedroom4length"]="Bedroom 4 Length";
idxTemp2["rets28_bedroom4width"]="Bedroom 4 Width";
idxTemp2["rets28_bedrooms"]="Bedrooms";
idxTemp2["rets28_ceilingheight"]="Ceiling Height";
idxTemp2["rets28_clearedynp"]="Cleared Y/n";
idxTemp2["rets28_dateavailable"]="Date Available";
idxTemp2["rets28_datebackonmarket"]="Date Back On Market";
idxTemp2["rets28_datechange"]="Date Change";
idxTemp2["rets28_closedate"]="Date Closed / Sold";
idxTemp2["rets28_datecontingency"]="Date Contingency";
idxTemp2["rets28_datedeleted"]="Date Deleted";
idxTemp2["rets28_expirationdate"]="Date Expiration";
idxTemp2["rets28_listdate"]="Date Listed";
idxTemp2["rets28_datenewlisting"]="Date New Listing";
//idxTemp2["rets28_contractdate"]="Date Pending";
idxTemp2["rets28_photomodificationtimestamp"]="Date Photo";
//idxTemp2["rets28_datepricechange"]="Date Price Change";
idxTemp2["rets28_datewithdrawn"]="Date Withdrawn";
idxTemp2["rets28_daysonmarket"]="Days On Market";
idxTemp2["rets28_daysonmarketcontinuous"]="Days On Market Continuous";
idxTemp2["rets28_diningroomlength"]="Dining Room Length";
idxTemp2["rets28_diningroomwidth"]="Dining Room Width";
idxTemp2["rets28_directions"]="Directions";
idxTemp2["rets28_dishwashers"]="Dishwashers";
idxTemp2["rets28_doorfaces"]="Door Faces";
idxTemp2["rets28_dryers"]="Dryers";
idxTemp2["rets28_electric"]="Electric";
idxTemp2["rets28_electricalexpense"]="Electrical Expenses";
idxTemp2["rets28_electricitymeters"]="Electricity Meters";
idxTemp2["rets28_employees"]="Employees";
idxTemp2["rets28_equipmentandappliances"]="Equipment And Appliances";
idxTemp2["rets28_estimatevalueyn"]="Estimate Of Value Y/n";
idxTemp2["rets28_exclusiveagency"]="Exclusive Agency";
idxTemp2["rets28_exteriorfeatures"]="Exterior Features";
idxTemp2["rets28_exteriorfinish"]="Exterior Finish";
idxTemp2["rets28_familyroomlength"]="Family Room Length";
idxTemp2["rets28_familyroomwidth"]="Family Room Width";
idxTemp2["rets28_floor"]="Floor";
//idxTemp2["rets28_floorlocation"]="Floor Location";
idxTemp2["rets28_floornumber"]="Floor Number";
idxTemp2["rets28_floors"]="Floors";
idxTemp2["rets28_floorsperunit"]="Floors Per Unit";
idxTemp2["rets28_floridaroomlength"]="Florida Room Length";
idxTemp2["rets28_floridaroomwidth"]="Florida Room Width";
idxTemp2["rets28_foreignselleryn"]="Foreign Seller Y/n";
idxTemp2["rets28_freestandingyn"]="Freestanding Y/n";
idxTemp2["rets28_furnishedyn"]="Furnished Y/n";
idxTemp2["rets28_garage"]="Garage";
idxTemp2["rets28_garagecarportspaces"]="Garage / Carport Spaces";
idxTemp2["rets28_garageandcarstorage"]="Garage And Car Storage";
idxTemp2["rets28_bathspartial"]="Half-baths";
//idxTemp2["rets28_harbormasteryn"]="Harbor Master Y/n";
idxTemp2["rets28_heating"]="Heating";
idxTemp2["rets28_heatingandac"]="Heatingandac";
idxTemp2["rets28_inlawsuite"]="In Law Suite";
idxTemp2["rets28_insidefeatures"]="Insidefeatures";
idxTemp2["rets28_interiorfeatures"]="Interiorfeatures";
idxTemp2["rets28_interiorimprovements"]="Interior Improvements";
idxTemp2["rets28_irrigation"]="Irrigation";
idxTemp2["rets28_kickout"]="Kickout";
idxTemp2["rets28_kitchenlength"]="Kitchen Length";
idxTemp2["rets28_kitchenwidth"]="Kitchen Width";
idxTemp2["rets28_laundrylength"]="Laundry Room Length";
idxTemp2["rets28_laundrywidth"]="Laundry Room Width";
idxTemp2["rets28_livingroomlength"]="Living Room Length";
idxTemp2["rets28_livingroomwidth"]="Living Room Width";
idxTemp2["rets28_loadingdocks"]="Loading Dock";
idxTemp2["rets28_masterbath"]="Master Bath";
idxTemp2["rets28_groundfloorbedroomyn"]="Master Bedroom Downstairs Y/n";
idxTemp2["rets28_microwaves"]="Microwaves";
idxTemp2["rets28_applicationfeeamount"]="Application Fee Amount";
//idxTemp2["rets28_assessmentfeeamount"]="Assessment Fee Amount";
//idxTemp2["rets28_assessmentfeeperiod"]="Assessmentfeeperiod";
idxTemp2["rets28_otherroom1length"]="Other Room 1 Length";
idxTemp2["rets28_otherroom1name"]="Other Room 1 Type";
idxTemp2["rets28_otherroom1width"]="Other Room 1 Width";
idxTemp2["rets28_otherroom2length"]="Other Room 2 Length";
idxTemp2["rets28_otherroom2name"]="Other Room 2 Type";
idxTemp2["rets28_otherroom2width"]="Other Room 2 Width";
idxTemp2["rets28_overheaddoornumber"]="Overhead Door Number";
idxTemp2["rets28_pooldescription"]="Pool Description";
idxTemp2["rets28_pool"]="Pool Description";
idxTemp2["rets28_poolfeatures"]="Pool Features";
idxTemp2["rets28_poolpresent"]="Pool Y/n";
idxTemp2["rets28_porchlength"]="Porch Length";
idxTemp2["rets28_porchwidth"]="Porch Width";
idxTemp2["rets28_unit1baths"]="Unit 1 Baths";
idxTemp2["rets28_electricmeters"]="Unit 1 Electric Meter";
idxTemp2["rets28_unit1halfbaths"]="Unit 1 Half Baths";
idxTemp2["rets28_unit1rooms"]="Unit 1 Rooms";
idxTemp2["rets28_unit1sqft"]="Unit 1 Sqft";
idxTemp2["rets28_unit2baths"]="Unit 2 Baths";
idxTemp2["rets28_unit2halfbaths"]="Unit 2 Half Baths";
idxTemp2["rets28_unit2rooms"]="Unit 2 Rooms";
idxTemp2["rets28_unit2sqft"]="Unit 2 Sqft";
idxTemp2["rets28_unit3baths"]="Unit 3 Baths";
idxTemp2["rets28_unit3halfbaths"]="Unit 3 Half Baths";
idxTemp2["rets28_unit3rooms"]="Unit 3 Rooms";
idxTemp2["rets28_unit3sqft"]="Unit 3 Sqft";
idxTemp2["rets28_unit4baths"]="Unit 4 Baths";
idxTemp2["rets28_unit4halfbaths"]="Unit 4 Half Baths";
idxTemp2["rets28_unit4rooms"]="Unit 4 Rooms";
idxTemp2["rets28_unit4sqft"]="Unit 4 Sqft";
idxTemp2["rets28_totalunits"]="Units";
idxTemp2["rets28_refrigerators"]="Refrigerators";
idxTemp2["rets28_windows"]="Windows";
idxTemp2["rets28_roof"]="Roof";
idxTemp2["rets28_totalrooms"]="Rooms";
idxTemp2["rets28_siteimprovements"]="Site Improvements";
idxTemp2["rets28_specialcontingenciesapplyyn"]="Special Contingencies Apply Y/n";
idxTemp2["rets28_splityn"]="Split Y/n";
idxTemp2["rets28_livingarea"]="Sqft Heated";
idxTemp2["rets28_sqftlivingarea"]="Sqft Living Area";
idxTemp2["rets28_sqfttotal"]="Sqft Total";
idxTemp2["rets28_parkingspaceyn"]="Parking Space Y/n";
idxTemp2["rets28_parkingavailable"]="Parking Description";
idxTemp2["rets28_occupancy"]="Occupancy";
idxTemp2["rets28_stylefeatures"]="Style";
idxTemp2["rets28_style"]="Style Of Home";
idxTemp2["rets28_type"]="Type";
idxTemp2["rets28_typestreet"]="Typestreet";
idxTemp2["rets28_petsynr"]="Pets Y/n";
	return arraytolist(arrR,'');
	
	
	
	</cfscript>
</cffunction>

<cffunction name="getDetailCache3" localmode="modern" output="yes" returntype="string">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var arrR=arraynew(1);
	var idxTemp2=structnew();  
	arrayappend(arrR, application.zcore.listingCom.getListingDetailRowOutput("Financial / Legal Info", arguments.idx, variables.idxExclude, idxTemp2, variables.allFields));

idxTemp2["rets28_businessname"]="Business Name";
//idxTemp2["rets28_businessonlyyn"]="Business Only Y/n";
idxTemp2["rets28_financialpackageyn"]="Financial Package Y/n";
idxTemp2["rets28_grossincome"]="Gross Income";
idxTemp2["rets28_associationfee"]="Hoa Dues";
idxTemp2["rets28_associationfeeperiod"]="Hoa Dues Paid M/q/a";
//idxTemp2["rets28_hoamaintfees"]="Hoa Maintenance Fees";
idxTemp2["rets28_insuranceexpense"]="Insurance Expenses";
idxTemp2["rets28_legaldescription"]="Legal Description";
idxTemp2["rets28_maintenanceexpense"]="Maintenance Expenses";
idxTemp2["rets28_maintexpensespaidby"]="Maintenance Expenses Paid By";
idxTemp2["rets28_maintfeecovers"]="Maint Fee Covers";
idxTemp2["rets28_dateestimatedcompletion"]="Date Estimated Completion";
idxTemp2["rets28_managementexpense"]="Management Expenses";
idxTemp2["rets28_netincome"]="Net Income";
idxTemp2["rets28_petfeeamount"]="Pet Fee Amount";
idxTemp2["rets28_pricesqft"]="Price / Sqft";
idxTemp2["rets28_pricechangeyn"]="Price Change Y/n";
idxTemp2["rets28_taxamount"]="Tax Amount";
idxTemp2["rets28_titleinsuranceavailableyn"]="Title Insurance Available Y/n";
idxTemp2["rets28_originallistprice"]="Original Price";
idxTemp2["rets28_otheravailblefeatures"]="Otheravailblefeatures";
idxTemp2["rets28_otherexpense"]="Other Expenses";
idxTemp2["rets28_watersewerexpense"]="Water Expenses";
idxTemp2["rets28_ownername"]="Owner Name";
idxTemp2["rets28_ownershiprequiredyn"]="Ownership";
idxTemp2["rets28_parcelnumber"]="Parcel Number / Id";

idxTemp2["rets28_prospectsexcludedyn"]="Name Prospect Y/n";
idxTemp2["rets28_previouslistprice"]="Previous List Price";
idxTemp2["rets28_taxid"]="Tax Id";
idxTemp2["rets28_alternatekey"]="Tax Id 1";
idxTemp2["rets28_tangibletaxes"]="Tax Total";
idxTemp2["rets28_assessedvaluation"]="Tax Value Assessed";
idxTemp2["rets28_taxyear"]="Tax Year";
idxTemp2["rets28_tenantexpenses"]="Tenant Expenses";
idxTemp2["rets28_operatingexpense"]="Operating Expenses";
idxTemp2["rets28_maintefeecovers"]="Mainte Fee Covers";
idxTemp2["rets28_groundsexpense"]="Ground Expenses";
idxTemp2["rets28_governingbody"]="Governing Body";
//idxTemp2["rets28_assocapprovalrequiredyn"]="Association Approval Required Y/N";
idxTemp2["rets28_associationfeecovers"]="Association Fee Covers";
idxTemp2["rets28_attachmentcount"]="Attachment Count";

idxTemp2["rets28_securitydepositamount"]="Security Deposit Amount";
	return arraytolist(arrR,'');
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>