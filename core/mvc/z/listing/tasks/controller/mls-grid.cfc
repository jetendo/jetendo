<cfcomponent>
<cfoutput>
<!--- 

// wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '29-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '29-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '29-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '29-%'; 
		
The MLS Grid uses the field MlgCanView as our deletion flag. Listings marked with MlgCanView=false are listings that no longer qualify for inclusion in the IDX feed and are marked for deletion. The participating MLS do include listings with a Closed StandardStatus. Depending on the governing rules of the MLS they may continue to include 3+ years worth of listings with a StandardStatus of Closed. Listings that are marked for deletion will carry the MlgCanView=false flag for 7 days and are then removed completely from the feed.
 
Prepping for Web API Data Import
	standardname?

	canopy specific fields are prefixed with CAR_, MFR_
b. Native MLS fields will have an MLS Local Fields prefix. (A list of MLS local fields prefix is available: docs.mlsgrid.com/#local-fields-prefix)

$top=5000
$skip=1
$count=true

StandardStatus = ?
Resource = Property, Media, Member, etc
 
	http://sa.farbeyondcode.com.local.zsite.info/z/listing/tasks/mls-grid/index
 --->
<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	variables.mls_id=29;
	// get all the active record ids from database into a lookup table so we can mark for deletion faster
	db.sql="select listing_track_id, listing_id from #db.table("listing_track", request.zos.zcoreDatasource)# 
	WHERE listing_id like #db.param('#variables.mls_id#-%')# ";
	qTrack=db.execute("qTrack");
	variables.listingLookup={};
	loop query="qTrack"{
		variables.listingLookup[qTrack.listing_id]=qTrack.listing_track_id;
	}
	variables.fieldNameLookup=getFieldNames();
	variables.arrColumn=listToArray("AboveGradeFinishedArea,AccessCode,AccessibilityFeatures,Appliances,ArchitecturalStyle,AssociationFee,AssociationFeeFrequency,AssociationName,AssociationPhone,AvailabilityDate,BathroomsFull,BathroomsHalf,BathroomsTotalInteger,BedroomsTotal,BelowGradeFinishedArea,BuilderName,BuildingAreaTotal,BuyerAgentAOR,BuyerAgentKey,BuyerAgentMlsId,BuyerOfficeKey,BuyerOfficeMlsId,CAR_BuyerAgentSaleYN,CAR_CanSubdivideYN,CAR_CCRSubjectTo,CAR_CommercialLocationDescription,CAR_ComplexName,CAR_ConstructionStatus,CAR_ConstructionType,CAR_CorrectionCount,CAR_DeedReference,CAR_Documents,CAR_DOMToClose,CAR_FloodPlain,CAR_GeocodeSource,CAR_HOASubjectTo,CAR_HOASubjectToDues,CAR_InsideCityYN,CAR_MainLevelGarageYN,CAR_OutBuildingsYN,CAR_OwnerAgentYN,CAR_PermitSyndicationYN,CAR_PlatBookSlide,CAR_PlatReferenceSectionPages,CAR_Porch,CAR_ProjectedClosingDate,CAR_PropertySubTypeSecondary,CAR_ProposedSpecialAssessmentYN,CAR_RailService,CAR_RATIO_CurrentPrice_By_Acre,CAR_RATIO_ListPrice_By_TaxAmount,CAR_Restrictions,CAR_RestrictionsDescription,CAR_room1_BathsFull,CAR_room1_BathsHalf,CAR_room1_BedsTotal,CAR_room1_RoomType,CAR_room2_BathsFull,CAR_room2_BathsHalf,CAR_room2_BedsTotal,CAR_room2_RoomType,CAR_room3_BathsFull,CAR_room3_BathsHalf,CAR_room3_BedsTotal,CAR_room3_RoomType,CAR_room4_BathsFull,CAR_room4_BathsHalf,CAR_room4_BedsTotal,CAR_room4_RoomType,CAR_SqFtAdditional,CAR_SqFtAvailableMaximum,CAR_SqFtAvailableMinimum,CAR_SqFtBuildingMinimum,CAR_SqFtGarage,CAR_SqFtLower,CAR_SqFtMain,CAR_SqFtMaximumLease,CAR_SqFtMinimumLease,CAR_SqFtThird,CAR_SqFtUnheatedBasement,CAR_SqFtUnheatedLower,CAR_SqFtUnheatedMain,CAR_SqFtUnheatedThird,CAR_SqFtUnheatedTotal,CAR_SqFtUnheatedUpper,CAR_SqFtUpper,CAR_StatusContractualSearchDate,CAR_StreetViewParam,CAR_SuitableUse,CAR_Table,CAR_TransactionType,CAR_unit1_BathsFull,CAR_unit1_BathsHalf,CAR_unit1_SqFtTotal,CAR_unit1_UnitRooms,CAR_unit2_BathsFull,CAR_unit2_BathsHalf,CAR_unit2_SqFtTotal,CAR_unit2_UnitRooms,CAR_UnitCount,CAR_WaterHeater,CAR_ZoningNCM,City,CloseDate,ClosePrice,CoListAgentAOR,CoListAgentFullName,CoListAgentKey,CoListAgentMlsId,CoListOfficeKey,CoListOfficeMlsId,CoListOfficeName,CommunityFeatures,ConstructionMaterials,Cooling,CountyOrParish,CrossStreet,CumulativeDaysOnMarket,DaysOnMarket,Directions,ElementarySchool,Elevation,EntryLevel,ExteriorFeatures,FireplaceFeatures,FireplaceYN,Flooring,FoundationDetails,Furnished,HabitableResidenceYN,Heating,HighSchool,Inclusions,InteriorFeatures,InternetAddressDisplayYN,InternetAutomatedValuationDisplayYN,InternetConsumerCommentYN,InternetEntireListingDisplayYN,Latitude,LaundryFeatures,ListAgentAOR,ListAgentDirectPhone,ListAgentFullName,ListAgentKey,ListAgentMlsId,ListingAgreement,ListingContractDate,ListingId,ListingKey,ListingTerms,ListOfficeKey,ListOfficeMlsId,ListOfficeName,ListOfficePhone,ListPrice,LivingArea,Longitude,LotFeatures,LotSizeArea,LotSizeDimensions,MiddleOrJuniorSchool,MlgCanView,Model,ModificationTimestamp,NewConstructionYN,NumberOfBuildings,NumberOfUnitsTotal,OccupantType,OriginatingSystemModificationTimestamp,OriginatingSystemName,ParcelNumber,ParkingFeatures,PendingTimestamp,PetsAllowed,PhotosChangeTimestamp,PhotosCount,PostalCode,PostalCodePlus4,PropertySubType,PropertyType,PublicRemarks,RoadResponsibility,RoadSurfaceType,Roof,RoomBathroom1Level,RoomBathroom2Level,RoomBathroom3Level,RoomBathroom4Level,RoomBathroom5Level,RoomBathroom6Level,RoomBedroom1Level,RoomBedroom2Level,RoomBedroom3Level,RoomBreakfastRoomLevel,RoomDiningRoomLevel,RoomFamilyRoomLevel,RoomKitchenLevel,RoomLaundryLevel,RoomLivingRoomLevel,RoomLoft2Level,RoomLoftLevel,RoomMasterBedroom2Level,RoomMasterBedroomLevel,RoomNoneLevel,RoomPantryLevel,RoomPlayRoomLevel,RoomType,Sewer,ShowingContactPhone,SpecialListingConditions,StandardStatus,StateOrProvince,StoriesTotal,StreetDirPrefix,StreetDirSuffix,StreetName,StreetNumber,StreetNumberNumeric,StreetSuffix,StructureType,SubdivisionName,SyndicationRemarks,TaxAnnualAmount,TenantPays,UnitNumber,UnitType1BedsTotal,UnitType2BedsTotal,Utilities,VirtualTourURLUnbranded,WaterBodyName,WaterfrontFeatures,WaterSource,YearBuilt,ZoningDescription,@odata.id", ",");


	variables.excludeStruct={
		"BuyerAgentAOR":true,
		"BuyerAgentKey":true,
		"BuyerAgentMlsId":true,
		"BuyerOfficeKey":true,
		"BuyerOfficeMlsId":true,
		"CAR_BuyerAgentSaleYN":true,
		"CAR_CCRSubjectTo":true,
		"CAR_Documents":true,
		"CAR_DOMToClose":true,
		"CAR_OwnerAgentYN":true,
		"CoListAgentAOR":true,
		"CoListAgentFullName":true,
		"CoListAgentKey":true,
		"CoListAgentMlsId":true,
		"CoListOfficeKey":true,
		"CoListOfficeMlsId":true,
		"CoListOfficeName":true,
		"Latitude":true,
		"Longitude":true,
		"InternetAddressDisplayYN":true,
		"InternetAutomatedValuationDisplayYN":true,
		"InternetConsumerCommentYN":true,
		"InternetEntireListingDisplayYN":true,
		"ListAgentAOR":true,
		"ListAgentDirectPhone":true,
		"ListAgentFullName":true,
		"ListAgentKey":true,
		"ListAgentMlsId":true,
		"ListingAgreement":true,
		"ListingContractDate":true,
		"ListingId":true,
		"ListingKey":true,
		"ListingTerms":true,
		"ListOfficeKey":true,
		"ListOfficeMlsId":true,
		"ListOfficeName":true,
		"ListOfficePhone":true,
		"MlgCanView":true,
		"ModificationTimestamp":true,
		"OriginatingSystemModificationTimestamp":true,
		"OriginatingSystemName":true,
		"PendingTimestamp":true,
		"PhotosChangeTimestamp":true,
		"ShowingContactPhone":true,
		"SyndicationRemarks":true,
	};
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote"> 
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only the developer and server can access this feature.");
	} 
	setting requesttimeout="100000"; 

 	debug=true;
 	link="";

 	// photos
 // 	if(debug){
	//  	cfhttp={status_code:200, filecontent:'{"@odata.context":"https://api.mlsgrid.com/$metadata##Media","@odata.count":71878,"value":[{"@odata.id":"https://api.mlsgrid.com/Media(''5df107c015b90f02aef77657'')","MediaKey":"5df107c015b90f02aef77657","OriginatingSystemModificationTimestamp":"2019-12-13T15:43:04.000Z","Order":0,"ImageWidth":1024,"ImageHeight":682,"ImageSizeDescription":"1024x682","MediaURL":"https://s3.amazonaws.com/mlsgrid/images/db8be70b-50de-482d-ba44-b52335550b11.jpeg","MediaModificationTimestamp":"2019-12-11T15:14:08.495Z","ModificationTimestamp":"2020-01-20T00:08:06.371Z","ResourceRecordKey":"CAR64335367","ResourceRecordID":"CAR3572577","ResourceName":"PropertyResi","OriginatingSystemName":"carolina","MlgCanView":false}],"@odata.nextLink":"https://api.mlsgrid.com/Media?$filter=ModificationTimestamp%2520gt%25202020-01-20T00%3A00%3A00.00Z&$top=1&$skip=1&$count=true"}'};
	//  }else{
	//  	top=1;
	//  	skip=0;
	//  	count=true;
	//  	lastUpdateDate=createdate(2020, 1, 20);
	//  	// photos: 
	//  	link="https://api.mlsgrid.com/Media?$filter=ModificationTimestamp%20gt%20#dateformat(lastUpdateDate, "yyyy-mm-dd")#T00:00:00.00Z&$top=#top#&$skip=#skip#&$count=#count#";
	// 	http url="#link#" timeout="10000"{
	// 		httpparam type="header" name="Authorization" value="Bearer #request.zos.mlsGridToken#";
	// 	}
	// }
	// writedump(cfhttp);
	// abort;

	// get unused fields as cfml code

	// exclude fields

	// download all data from scratch

	// download since last update minus one day to be sure timezone doesn't interfere

	// store

	arrResource=[
		"PropertyResi",
		"PropertyRlse",
		"PropertyRinc",
		"PropertyLand",
		"PropertyFarm",
		"PropertyMobi", // not used on canopyMLS
		"PropertyComs",
		"PropertyComl",
		"PropertyBuso", // not used on canopyMLS
		"Member",
		"Office",
		"Media"
	];
	resourceIndex=4; // leave as 0 when not debugging
	// property, but only residential??
	debug=false;
 	top=500; // 5000 is max records?
 	skip=0;
 	count=false; // don't need count since the next link can pull everything
 	lastUpdateDate=createdate(2020, 1, 20); // first time, pull very old data createdate(2010,1,1);
 	if(debug){
 		top=1;
 		skip=0;
 		count=true;
 		resourceIndex=1;
 	}

 	displayFields=true;
	if(displayFields){
		top=1;
		skip=0;
		count=false;
	}

	// a=downloadData("https://api.mlsgrid.com/$metadata");
	// writedump(a);
	// abort;


	insertCount=0;
	updateCount=0;
	deleteCount=0;

	init();


 	for(n=1;n<=arrayLen(arrResource);n++){
 		if(resourceIndex EQ 0){
			resource=arrResource[n];
		}else if(resourceIndex NEQ n){
			continue; // skip to the correct resourceIndex
		}else{
			resource=arrResource[resourceIndex];
		}

 		filter=urlencodedformat("ModificationTimestamp gt #dateformat(lastUpdateDate, "yyyy-mm-dd")#T00:00:00.00Z");
	 	nextLink="https://api.mlsgrid.com/#resource#?$filter=#filter#&$top=#top#&$skip=#skip#&$count=#count#";

	 	// MlgCanView 
	 	while(true){
		 	js=downloadData(nextLink);
			// writedump(resource);
			// writedump(js);
			for(i=1;i<=arraylen(js.value);i++){
				ds=js.value[i];

				if(displayFields){
					for(k in ds){
						echo('ts["#k#"]=application.zcore.functions.zso(ds, "#k#");<br>');
					}
					break;
				}

				if(resource EQ "Member"){
					processMember(ds);
				}else if(resource EQ "Office"){
					processOffice(ds);
				}else if(resource EQ "Media"){
					processMedia(ds);
				}else{
					listing_id=variables.mls_id&"-"&ds.listingId;
					if(ds["MlgCanView"] EQ "false" or ds["StandardStatus"] NEQ "active"){
						// delete this record somehow
						if(structkeyexists(variables.listingLookup, listing_id)){ 
							db2.sql="DELETE FROM #db2.table("listing", request.zos.zcoreDatasource)#  
							WHERE listing_id =#db.param(listing_id)# and listing_deleted = #db2.param(0)# ";
							db2.execute("qDelete");
							db2.sql="DELETE FROM #db2.table("listing_data", request.zos.zcoreDatasource)#  
							WHERE listing_id =#db.param(listing_id)# and listing_data_deleted = #db2.param(0)# ";
							db2.execute("qDelete");
							db2.sql="DELETE FROM #db2.table("listing_memory", request.zos.zcoreDatasource)# WHERE listing_id=#db.param(listing_id)# and listing_deleted = #db2.param(0)# ";
							db2.execute("qDelete");
							db2.sql="UPDATE #db2.table("listing_track", request.zos.zcoreDatasource)# listing_track 
							SET listing_track_hash=#db2.param('')#, 
							listing_track_inactive=#db2.param(1)#, 
							listing_track_updated_datetime=#db2.param(request.zos.mysqlnow)#  
							WHERE listing_id=#db.param(listing_id)# and 
							listing_track_deleted = #db2.param(0)#";
							db2.execute("qDelete"); 
							deleteCount++;
						}
					}else{
						excludeListingFields(ds);
						rs=processListing(ds);

						// insert to the 4 tables
						dataChanged=true;
						if(not structkeyexists(variables.listingLookup, listing_id)){ 
							// new record - might want to keep the previous values someday
							rs.listing_track_id="null";
							rs.listing_id=listing_id;
							rs.listing_track_price=ds.ListPrice;
							rs.listing_track_price_change=ds.ListPrice;
							rs.listing_track_hash="";
							rs.listing_track_deleted="0";
							rs.listing_track_inactive='0';
							rs.listing_track_datetime=request.zos.mysqlnow;
							rs.listing_track_updated_datetime=request.zos.mysqlnow;
							rs.listing_track_processed_datetime=request.zos.mysqlnow;
							insertCount++;
						}else{
							rs.listing_track_id=variables.listingLookup[listing_id];
							rs.listing_id=listing_id;
							rs.listing_track_price=ds.ListPrice;
							rs.listing_track_change_price=ds.ListPrice;
							rs.listing_track_hash="";
							rs.listing_track_deleted="0";
							rs.listing_track_inactive='0';
							rs.listing_track_datetime=request.zos.mysqlnow;
							rs.listing_track_updated_datetime=request.zos.mysqlnow;
							rs.listing_track_processed_datetime=request.zos.mysqlnow;
							updateCount++;
						} 
						ts2={
							debug:true,
							datasource:request.zos.zcoreDatasource,
							table:"listing",
							struct:rs
						};
						ts2.struct.listing_deleted='0';
						ts5={
							debug:true,
							datasource:request.zos.zcoreDatasource,
							table:"listing_memory",
							struct:rs
						};
						ts5.struct.listing_deleted='0';
						ts3={
							debug:true,
							datasource:request.zos.zcoreDatasource,
							table:"listing_data",
							struct:rs
						};
						jsData={}; 
						for(i2 in variables.arrColumn){
							jsData[i2]=rs[variables.arrColumn[i2]];
						}
						ts3.struct.listing_data_json=serializeJson(jsData);
						ts3.struct.listing_data_deleted='0';
						ts4={
							debug:true,
							datasource:request.zos.zcoreDatasource,
							table:"listing_track",
							struct:rs
						};
						ts4.struct.listing_track_deleted='0'; 

						transaction action="begin"{
							try{ 
								if(not structkeyexists(variables.listingLookup, listing_id)){ 
									application.zcore.functions.zInsert(ts4);
									application.zcore.functions.zInsert(ts5);
									application.zcore.functions.zInsert(ts2); 
									application.zcore.functions.zInsert(ts3); 
								}else{
									// listing_track
									ts4.forceWhereFields="listing_id,listing_track_deleted";
									application.zcore.functions.zUpdate(ts4);
									
									// listing_memory
									ts5.forceWhereFields="listing_id,listing_deleted";
									application.zcore.functions.zInsert(ts5); 

									// listing
									ts2.forceWhereFields="listing_id,listing_deleted";
									application.zcore.functions.zUpdate(ts2);

									// listing_data
									ts3.forceWhereFields="listing_id,listing_data_deleted";
									application.zcore.functions.zUpdate(ts3);  
								}
								transaction action="commit"; 
							}catch(Any e){
								transaction action="rollback";
								rethrow;
							}
						}
					}
				}
				break; // for debugging, only do 1
			}

			break; // for debugging, only do 1
			nextLink=application.zcore.functions.zso(js, "@odata.nextLink");
			if(nextLink EQ ""){
				break;
			}
		}
 		if(resourceIndex NEQ 0){
 			break;
 		}
 	} 
 	echo("Inserted #insertCount#, Updated #updateCount#, Deleted #deleteCount#");
	abort;
	</cfscript>
</cffunction>


<cffunction name="excludeListingFields" localmode="modern" access="public">
	<cfargument name="ts" type="struct" required="yes">
	<cfscript>
	ts=arguments.ts;
	for(i in variables.excludeStruct){
		structdelete(ts,i);
	}

	</cfscript>
</cffunction>


<cffunction name="downloadData" localmode="modern" access="public">
	<cfargument name="link" type="string" required="yes">
	<cfscript>
	link=arguments.link;

	debug=false;
 	if(debug){
 		cfhttp=getDebugValue();
 	}else{
		http url="#link#" timeout="10000"{
			httpparam type="header" name="Authorization" value="Bearer #request.zos.mlsGridToken#";
		}
	}
	//writedump(cfhttp);abort;
	if(cfhttp.status_code NEQ "200"){
		savecontent variable="out"{
			echo("MLSGrid download failed: #link#");
			writedump(cfhttp);
		}
		throw(out);
	}
	js=deserializeJson(cfhttp.filecontent);
	return js;
	</cfscript>
</cffunction>

<cffunction name="processMedia" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds;
	// Media
	ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
	ts["MediaKey"]=application.zcore.functions.zso(ds, "MediaKey");
	ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
	ts["Order"]=application.zcore.functions.zso(ds, "Order");
	ts["ImageWidth"]=application.zcore.functions.zso(ds, "ImageWidth");
	ts["ImageHeight"]=application.zcore.functions.zso(ds, "ImageHeight");
	ts["ImageSizeDescription"]=application.zcore.functions.zso(ds, "ImageSizeDescription");
	ts["MediaURL"]=application.zcore.functions.zso(ds, "MediaURL");
	ts["MediaModificationTimestamp"]=application.zcore.functions.zso(ds, "MediaModificationTimestamp");
	ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");
	ts["ResourceRecordKey"]=application.zcore.functions.zso(ds, "ResourceRecordKey");
	ts["ResourceRecordID"]=application.zcore.functions.zso(ds, "ResourceRecordID");
	ts["ResourceName"]=application.zcore.functions.zso(ds, "ResourceName");
	ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
	ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
	</cfscript>
</cffunction>

<cffunction name="processOffice" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds;
	// Office
	ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
	ts["OfficeBranchType"]=application.zcore.functions.zso(ds, "OfficeBranchType");
	ts["OfficeEmail"]=application.zcore.functions.zso(ds, "OfficeEmail");
	ts["OfficeFax"]=application.zcore.functions.zso(ds, "OfficeFax");
	ts["MainOfficeKeyNumeric"]=application.zcore.functions.zso(ds, "MainOfficeKeyNumeric");
	ts["MainOfficeMlsId"]=application.zcore.functions.zso(ds, "MainOfficeMlsId");
	ts["OriginatingSystemOfficeKey"]=application.zcore.functions.zso(ds, "OriginatingSystemOfficeKey");
	ts["OfficeKey"]=application.zcore.functions.zso(ds, "OfficeKey");
	ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
	ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
	ts["OfficeMlsId"]=application.zcore.functions.zso(ds, "OfficeMlsId");
	ts["OfficeBrokerKeyNumeric"]=application.zcore.functions.zso(ds, "OfficeBrokerKeyNumeric");
	ts["OfficeBrokerMlsId"]=application.zcore.functions.zso(ds, "OfficeBrokerMlsId");
	ts["CAR_OfficeLongName"]=application.zcore.functions.zso(ds, "CAR_OfficeLongName");
	ts["OfficeName"]=application.zcore.functions.zso(ds, "OfficeName");
	ts["OfficeStatus"]=application.zcore.functions.zso(ds, "OfficeStatus");
	ts["OfficePhone"]=application.zcore.functions.zso(ds, "OfficePhone");
	ts["CAR_PhotoCount"]=application.zcore.functions.zso(ds, "CAR_PhotoCount");
	ts["OfficeAOR"]=application.zcore.functions.zso(ds, "OfficeAOR");
	ts["CAR_StreetAddress"]=application.zcore.functions.zso(ds, "CAR_StreetAddress");
	ts["CAR_StreetCity"]=application.zcore.functions.zso(ds, "CAR_StreetCity");
	ts["CAR_StreetPostalCode"]=application.zcore.functions.zso(ds, "CAR_StreetPostalCode");
	ts["CAR_StreetStateOrProvince"]=application.zcore.functions.zso(ds, "CAR_StreetStateOrProvince");
	ts["CAR_WebPageAddress"]=application.zcore.functions.zso(ds, "CAR_WebPageAddress");
	ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
	ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");
	</cfscript>
</cffunction>

<cffunction name="processMember" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds;
	// Member
	ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
	ts["MemberStatus"]=application.zcore.functions.zso(ds, "MemberStatus");
	ts["MemberType"]=application.zcore.functions.zso(ds, "MemberType");
	ts["MemberAOR"]=application.zcore.functions.zso(ds, "MemberAOR");
	ts["CAR_BranchType"]=application.zcore.functions.zso(ds, "CAR_BranchType");
	ts["MemberMobilePhone"]=application.zcore.functions.zso(ds, "MemberMobilePhone");
	ts["MemberDirectPhone"]=application.zcore.functions.zso(ds, "MemberDirectPhone");
	ts["MemberPreferredPhone"]=application.zcore.functions.zso(ds, "MemberPreferredPhone");
	ts["MemberFax"]=application.zcore.functions.zso(ds, "MemberFax");
	ts["MemberFirstName"]=application.zcore.functions.zso(ds, "MemberFirstName");
	ts["MemberFullName"]=application.zcore.functions.zso(ds, "MemberFullName");
	ts["MemberLastName"]=application.zcore.functions.zso(ds, "MemberLastName");
	ts["MemberKeyNumeric"]=application.zcore.functions.zso(ds, "MemberKeyNumeric");
	ts["MemberKey"]=application.zcore.functions.zso(ds, "MemberKey");
	ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
	ts["OriginalEntryTimestamp"]=application.zcore.functions.zso(ds, "OriginalEntryTimestamp");
	ts["MemberMiddleName"]=application.zcore.functions.zso(ds, "MemberMiddleName");
	ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
	ts["MemberMlsId"]=application.zcore.functions.zso(ds, "MemberMlsId");
	ts["MemberNationalAssociationId"]=application.zcore.functions.zso(ds, "MemberNationalAssociationId");
	ts["OfficeKey"]=application.zcore.functions.zso(ds, "OfficeKey");
	ts["OfficeKeyNumeric"]=application.zcore.functions.zso(ds, "OfficeKeyNumeric");
	ts["OfficeMlsId"]=application.zcore.functions.zso(ds, "OfficeMlsId");
	ts["CAR_PhotoCount"]=application.zcore.functions.zso(ds, "CAR_PhotoCount");
	ts["MemberAddress1"]=application.zcore.functions.zso(ds, "MemberAddress1");
	ts["MemberCity"]=application.zcore.functions.zso(ds, "MemberCity");
	ts["MemberPostalCode"]=application.zcore.functions.zso(ds, "MemberPostalCode");
	ts["MemberStateOrProvince"]=application.zcore.functions.zso(ds, "MemberStateOrProvince");
	ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
	ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");
	</cfscript>
</cffunction>

<cffunction name="processListing" localmode="modern" access="public">
	<cfargument name="ds" type="struct" required="yes">
	<cfscript>
	ds=arguments.ds; 
		startTime=gettickcount('nano');
 

		for(i in ds){
			if((right(i, 4) EQ "date" or i CONTAINS "timestamp") and isdate(ds[i])){
				d=parsedatetime(ds[i]);
				ds[i]=dateformat(d, "m/d/yyyy")&" "&timeformat(d, "h:mm tt");
			}else if(ds[i] EQ 0 or ds[i] EQ 1){

			}else if(len(ds[i]) lt 14 and isnumeric(ds[i]) and right(ds[i], 3) EQ ".00"){
				ds[i]=numberformat(ds[i]);
			}else{
				ds[i]=replace(ds[i], ",", ", ", "all");
			}
		}
		//writedump(ts); 		abort; 
		
		ts["List Price"]=replace(ts["List Price"],",","","ALL");
		
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
		if(ts["Property Type"] EQ "INC" and ts["Monthly"] NEQ "" and ts["Monthly"] NEQ "0"){
			ts["List Price"]=ts["Monthly"];
		}
		this.price=ts["List Price"];
		local.listing_price=ts["List Price"];
		cityName=this.getRetsValue("property", "", "city", ts["city"]);
		// get the actual city name: 
		cid=getNewCityId(ts["city"], cityName, ts["State Or Province"]);
		 

		arrS=listtoarray(ts['Special Listing Conditions'],","); 
		local.listing_county="";
		if(local.listing_county EQ ""){
			local.listing_county=this.listingLookupNewId("County",ts['County Or Parish']);
		}
		//writedump(listing_county); 		abort; 
		local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type", ts['Property Sub Type']);


		local.listing_type_id=this.listingLookupNewId("listing_type",ts['Property Type']);

		

		rs=getListingTypeWithCode(ts["Property Type"]);
		
		if(ts["Permit Address Internet YN"] EQ "N"){
			ts["street ##"]="";
			ts["street name"]="";
			ts["street type"]="";
			ts["Unit ##"]="";
		}
		
		ts["Property Type"]=rs.id;
		ad=ts['Street Number'];
		if(ad NEQ 0){
			address=trim(ts["Street Dir Prefix"]&" #ad# ");
		}else{
			address="";	
		}
		address&=" "&trim(ts['Street Name']&" "&ts['Street Suffix']&" "&ts["Street Dir Suffix"]);
		curLat='';
		curLong='';
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts['State Or Province'],ts['Postal Code'], arguments.ss.listing_id);
			if(rs5.success){
				curLat=rs5.latitude;
				curLong=rs5.longitude;
			}
		}
		address=application.zcore.functions.zfirstlettercaps(address);
		
		if(ts['Unit Number'] NEQ ''){
			address&=" Unit: "&ts["Unit Number"];	
		} 
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=ts['Year Built'];
		ts2.foreclosureField="";
		
		s=this.processRawStatus(ts2);
		arrS=listtoarray(ts['Special Listing Conditions'],",");
		for(i=1;i LTE arraylen(arrS);i++){
			c=trim(arrS[i]);
			if(c EQ "ShortSale"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
				break;
			} 
			if(c EQ "FCPC"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
			}
		}
		if(ts['New Construction YN'] EQ "Y"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["New Construction"]]=true;
		}
		if(ts.rets29_propertytype EQ "RNT"){
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
		//writedump(tmp);
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
		//writedump(listing_style); 	abort;


		arrT2=[]; 
		tmp=ts['Parking'];
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
		local.listing_parking=arraytolist(arrT2, ",");
		
		if(structkeyexists(ts,'Listing Contract Date')){
			arguments.ss.listing_track_datetime=dateformat(ts["Listing Contract Date"],"yyyy-mm-dd")&" "&timeformat(ts["Listing Contract Date"], "HH:mm:ss");
		}
		arguments.ss.listing_track_updated_datetime=dateformat(ts["Matrix Modified DT"],"yyyy-mm-dd")&" "&timeformat(ts["Matrix Modified DT"], "HH:mm:ss");
		//arguments.ss.listing_track_price=ts["Original List Price"];
		//if(arguments.ss.listing_track_price EQ "" or arguments.ss.listing_track_price EQ "0" or arguments.ss.listing_track_price LT 100){
			arguments.ss.listing_track_price=ts["List Price"];
		//}
		arguments.ss.listing_track_price_change=ts["List Price"];
		liststatus=ts["Status"];
		s2=structnew();
		//if(liststatus EQ "ACT"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Active"]]=true;
		//}
		/*if(liststatus EQ "AWC"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Active"]]=true;
		}
		if(liststatus EQ "WDN"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Withdrawn"]]=true;
		}
		if(liststatus EQ "TOM"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Temporarily Off Market"]]=true;
		}
		if(liststatus EQ "PNC"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Coming Soon-No Show"]]=true;
		}
		if(liststatus EQ "EXP"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Expired"]]=true;
		}
		if(liststatus EQ "SLD"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Closed"]]=true;
		}
		if(liststatus EQ "LSE"){
			s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Leased"]]=true;
		}*/

		//if(liststatus EQ "LSO"){
		//CANT FIND LEASE OPTION	s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["lease option"]]=true;
		//}
		//if(liststatus EQ "RNT"){
		//CANT FIND RENTED	s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["Leased"]]=true;
		//}
		local.listing_liststatus=structkeylist(s2,",");
		if(local.listing_liststatus EQ ""){
			local.listing_liststatus=1;
		}
		
		// view & frontage
		arrT3=[];
		
		uns=structnew();
		tmp=ts['Lot Features'];		
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
		
		local.listing_view="";
		/* 
		arrT2=[];
		uns=structnew();
  
		local.listing_view=arraytolist(arrT2);
		*/

		local.listing_pool=0; 
		extFeatures={
			"INPOOL":true,
			"AGPOOL":true
		}; 
		tmp=ts['Exterior Features']; 
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				if(structkeyexists(extFeatures, arrT[i])){
					local.listing_pool=1;	
					break;
				} 
			}
		} 
 
		tempTime=gettickcount('nano');
		application.idxImportTimerStruct.parseRow1+=(tempTime-startTime);
		startTime=tempTime; 
   		ts=this.convertRawDataToLookupValues(ts, variables.tableLookup[ts.rets29_propertytype], ts.rets29_propertytype); 
		
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		rs=structnew();
		rs.mls_id=29;
		rs.listing_id=arguments.ss.listing_id;
		// LotDimension LotSizeArea 
		rs.listing_acreage=ts["Acres Wooded"];
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
		rs.listing_lot_square_feet="";
		if(structkeyexists(ts, "Acres Wooded") and isnumeric(ts["Acres Wooded"])){
			rs.listing_lot_square_feet=round(ts["Acres Wooded"]/0.000022956841138659);
		}else if(structkeyexists(ts, "Lot Size Area In Acres") and isnumeric(ts["Lot Size Area In Acres"])){
			rs.listing_lot_square_feet=round(ts["Lot Size Area In Acres"]/0.000022956841138659);
		}
		rs.listing_square_feet=ts["Sq Ft Total"];
		rs.listing_subdivision=local.listing_subdivision;
		rs.listing_year_built=ts["year built"];
		rs.listing_office=ts["List Office MLSID"];
		rs.listing_office_name=ts["rets29_listofficename"];
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
		rs.listing_data_remarks=ts["public remarks"];
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts["Postal Code"]);
		rs.listing_data_detailcache1=listing_data_detailcache1;
		rs.listing_data_detailcache2=listing_data_detailcache2;
		rs.listing_data_detailcache3=listing_data_detailcache3; 

		rs.listing_track_sysid=ts["rets29_matrix_unique_id"];
		//writedump(rs);		writedump(ts);abort;

		tempTime=gettickcount('nano');
		application.idxImportTimerStruct.parseRow2+=(tempTime-startTime);
		startTime=tempTime;

		return {
			listingData:rs,
			columnIndex:columnIndex,
			arrData:arguments.ss.arrData
		}; 

		// PropertyResi
		ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
		ts["BathroomsFull"]=application.zcore.functions.zso(ds, "BathroomsFull");
		ts["BathroomsHalf"]=application.zcore.functions.zso(ds, "BathroomsHalf");
		ts["BathroomsTotalInteger"]=application.zcore.functions.zso(ds, "BathroomsTotalInteger");
		ts["BedroomsTotal"]=application.zcore.functions.zso(ds, "BedroomsTotal");
		ts["BuilderName"]=application.zcore.functions.zso(ds, "BuilderName");
		ts["CAR_BuyerAgentSaleYN"]=application.zcore.functions.zso(ds, "CAR_BuyerAgentSaleYN");
		ts["CumulativeDaysOnMarket"]=application.zcore.functions.zso(ds, "CumulativeDaysOnMarket");
		ts["City"]=application.zcore.functions.zso(ds, "City");
		ts["CAR_ConstructionType"]=application.zcore.functions.zso(ds, "CAR_ConstructionType");
		ts["CountyOrParish"]=application.zcore.functions.zso(ds, "CountyOrParish");
		ts["CAR_DeedReference"]=application.zcore.functions.zso(ds, "CAR_DeedReference");
		ts["DaysOnMarket"]=application.zcore.functions.zso(ds, "DaysOnMarket");
		ts["RoadSurfaceType"]=application.zcore.functions.zso(ds, "RoadSurfaceType");
		ts["ElementarySchool"]=application.zcore.functions.zso(ds, "ElementarySchool");
		ts["Appliances"]=application.zcore.functions.zso(ds, "Appliances");
		ts["ConstructionMaterials"]=application.zcore.functions.zso(ds, "ConstructionMaterials");
		ts["FireplaceFeatures"]=application.zcore.functions.zso(ds, "FireplaceFeatures");
		ts["FireplaceYN"]=application.zcore.functions.zso(ds, "FireplaceYN");
		ts["FoundationDetails"]=application.zcore.functions.zso(ds, "FoundationDetails");
		ts["CAR_GeocodeSource"]=application.zcore.functions.zso(ds, "CAR_GeocodeSource");
		ts["Heating"]=application.zcore.functions.zso(ds, "Heating");
		ts["HighSchool"]=application.zcore.functions.zso(ds, "HighSchool");
		ts["AssociationName"]=application.zcore.functions.zso(ds, "AssociationName");
		ts["AssociationPhone"]=application.zcore.functions.zso(ds, "AssociationPhone");
		ts["CAR_HOASubjectTo"]=application.zcore.functions.zso(ds, "CAR_HOASubjectTo");
		ts["CAR_HOASubjectToDues"]=application.zcore.functions.zso(ds, "CAR_HOASubjectToDues");
		ts["Latitude"]=application.zcore.functions.zso(ds, "Latitude");
		ts["LaundryFeatures"]=application.zcore.functions.zso(ds, "LaundryFeatures");
		ts["ListAgentKey"]=application.zcore.functions.zso(ds, "ListAgentKey");
		ts["ListAgentDirectPhone"]=application.zcore.functions.zso(ds, "ListAgentDirectPhone");
		ts["ListAgentFullName"]=application.zcore.functions.zso(ds, "ListAgentFullName");
		ts["ListAgentMlsId"]=application.zcore.functions.zso(ds, "ListAgentMlsId");
		ts["ListAgentAOR"]=application.zcore.functions.zso(ds, "ListAgentAOR");
		ts["ListingContractDate"]=application.zcore.functions.zso(ds, "ListingContractDate");
		ts["ListingAgreement"]=application.zcore.functions.zso(ds, "ListingAgreement");
		ts["ListOfficeKey"]=application.zcore.functions.zso(ds, "ListOfficeKey");
		ts["ListOfficeMlsId"]=application.zcore.functions.zso(ds, "ListOfficeMlsId");
		ts["ListOfficeName"]=application.zcore.functions.zso(ds, "ListOfficeName");
		ts["ListOfficePhone"]=application.zcore.functions.zso(ds, "ListOfficePhone");
		ts["ListPrice"]=application.zcore.functions.zso(ds, "ListPrice");
		ts["Longitude"]=application.zcore.functions.zso(ds, "Longitude");
		ts["LotSizeArea"]=application.zcore.functions.zso(ds, "LotSizeArea");
		ts["ListingKey"]=application.zcore.functions.zso(ds, "ListingKey");
		ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
		ts["MiddleOrJuniorSchool"]=application.zcore.functions.zso(ds, "MiddleOrJuniorSchool");
		ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
		ts["ListingId"]=application.zcore.functions.zso(ds, "ListingId");
		ts["Model"]=application.zcore.functions.zso(ds, "Model");
		ts["NewConstructionYN"]=application.zcore.functions.zso(ds, "NewConstructionYN");
		ts["CAR_OwnerAgentYN"]=application.zcore.functions.zso(ds, "CAR_OwnerAgentYN");
		ts["ParcelNumber"]=application.zcore.functions.zso(ds, "ParcelNumber");
		ts["ParkingFeatures"]=application.zcore.functions.zso(ds, "ParkingFeatures");
		ts["PendingTimestamp"]=application.zcore.functions.zso(ds, "PendingTimestamp");
		ts["InternetAddressDisplayYN"]=application.zcore.functions.zso(ds, "InternetAddressDisplayYN");
		ts["InternetEntireListingDisplayYN"]=application.zcore.functions.zso(ds, "InternetEntireListingDisplayYN");
		ts["CAR_PermitSyndicationYN"]=application.zcore.functions.zso(ds, "CAR_PermitSyndicationYN");
		ts["PhotosCount"]=application.zcore.functions.zso(ds, "PhotosCount");
		ts["PhotosChangeTimestamp"]=application.zcore.functions.zso(ds, "PhotosChangeTimestamp");
		ts["PostalCode"]=application.zcore.functions.zso(ds, "PostalCode");
		ts["PostalCodePlus4"]=application.zcore.functions.zso(ds, "PostalCodePlus4");
		ts["StructureType"]=application.zcore.functions.zso(ds, "StructureType");
		ts["PropertySubType"]=application.zcore.functions.zso(ds, "PropertySubType");
		ts["PropertyType"]=application.zcore.functions.zso(ds, "PropertyType");
		ts["CAR_ProposedSpecialAssessmentYN"]=application.zcore.functions.zso(ds, "CAR_ProposedSpecialAssessmentYN");
		ts["PublicRemarks"]=application.zcore.functions.zso(ds, "PublicRemarks");
		ts["CAR_RATIO_CurrentPrice_By_Acre"]=application.zcore.functions.zso(ds, "CAR_RATIO_CurrentPrice_By_Acre");
		ts["CAR_RATIO_ListPrice_By_TaxAmount"]=application.zcore.functions.zso(ds, "CAR_RATIO_ListPrice_By_TaxAmount");
		ts["RoadResponsibility"]=application.zcore.functions.zso(ds, "RoadResponsibility");
		ts["BuyerAgentKey"]=application.zcore.functions.zso(ds, "BuyerAgentKey");
		ts["BuyerAgentAOR"]=application.zcore.functions.zso(ds, "BuyerAgentAOR");
		ts["BuyerAgentMlsId"]=application.zcore.functions.zso(ds, "BuyerAgentMlsId");
		ts["BuyerOfficeKey"]=application.zcore.functions.zso(ds, "BuyerOfficeKey");
		ts["BuyerOfficeMlsId"]=application.zcore.functions.zso(ds, "BuyerOfficeMlsId");
		ts["Sewer"]=application.zcore.functions.zso(ds, "Sewer");
		ts["ShowingContactPhone"]=application.zcore.functions.zso(ds, "ShowingContactPhone");
		ts["SpecialListingConditions"]=application.zcore.functions.zso(ds, "SpecialListingConditions");
		ts["CAR_SqFtAdditional"]=application.zcore.functions.zso(ds, "CAR_SqFtAdditional");
		ts["BelowGradeFinishedArea"]=application.zcore.functions.zso(ds, "BelowGradeFinishedArea");
		ts["CAR_SqFtLower"]=application.zcore.functions.zso(ds, "CAR_SqFtLower");
		ts["CAR_SqFtMain"]=application.zcore.functions.zso(ds, "CAR_SqFtMain");
		ts["CAR_SqFtThird"]=application.zcore.functions.zso(ds, "CAR_SqFtThird");
		ts["LivingArea"]=application.zcore.functions.zso(ds, "LivingArea");
		ts["BuildingAreaTotal"]=application.zcore.functions.zso(ds, "BuildingAreaTotal");
		ts["CAR_SqFtUnheatedBasement"]=application.zcore.functions.zso(ds, "CAR_SqFtUnheatedBasement");
		ts["CAR_SqFtUnheatedLower"]=application.zcore.functions.zso(ds, "CAR_SqFtUnheatedLower");
		ts["CAR_SqFtUnheatedMain"]=application.zcore.functions.zso(ds, "CAR_SqFtUnheatedMain");
		ts["CAR_SqFtUnheatedThird"]=application.zcore.functions.zso(ds, "CAR_SqFtUnheatedThird");
		ts["CAR_SqFtUnheatedTotal"]=application.zcore.functions.zso(ds, "CAR_SqFtUnheatedTotal");
		ts["CAR_SqFtUnheatedUpper"]=application.zcore.functions.zso(ds, "CAR_SqFtUnheatedUpper");
		ts["CAR_SqFtUpper"]=application.zcore.functions.zso(ds, "CAR_SqFtUpper");
		ts["StateOrProvince"]=application.zcore.functions.zso(ds, "StateOrProvince");
		ts["StandardStatus"]=application.zcore.functions.zso(ds, "StandardStatus");
		ts["CAR_StatusContractualSearchDate"]=application.zcore.functions.zso(ds, "CAR_StatusContractualSearchDate");
		ts["StreetName"]=application.zcore.functions.zso(ds, "StreetName");
		ts["StreetNumber"]=application.zcore.functions.zso(ds, "StreetNumber");
		ts["StreetNumberNumeric"]=application.zcore.functions.zso(ds, "StreetNumberNumeric");
		ts["StreetSuffix"]=application.zcore.functions.zso(ds, "StreetSuffix");
		ts["CAR_StreetViewParam"]=application.zcore.functions.zso(ds, "CAR_StreetViewParam");
		ts["SubdivisionName"]=application.zcore.functions.zso(ds, "SubdivisionName");
		ts["CAR_Table"]=application.zcore.functions.zso(ds, "CAR_Table");
		ts["TaxAnnualAmount"]=application.zcore.functions.zso(ds, "TaxAnnualAmount");
		ts["CAR_UnitCount"]=application.zcore.functions.zso(ds, "CAR_UnitCount");
		ts["UnitNumber"]=application.zcore.functions.zso(ds, "UnitNumber");
		ts["InternetAutomatedValuationDisplayYN"]=application.zcore.functions.zso(ds, "InternetAutomatedValuationDisplayYN");
		ts["InternetConsumerCommentYN"]=application.zcore.functions.zso(ds, "InternetConsumerCommentYN");
		ts["WaterSource"]=application.zcore.functions.zso(ds, "WaterSource");
		ts["CAR_WaterHeater"]=application.zcore.functions.zso(ds, "CAR_WaterHeater");
		ts["YearBuilt"]=application.zcore.functions.zso(ds, "YearBuilt");
		ts["ZoningDescription"]=application.zcore.functions.zso(ds, "ZoningDescription");
		ts["CAR_MainLevelGarageYN"]=application.zcore.functions.zso(ds, "CAR_MainLevelGarageYN");
		ts["OccupantType"]=application.zcore.functions.zso(ds, "OccupantType");
		ts["CAR_ProjectedClosingDate"]=application.zcore.functions.zso(ds, "CAR_ProjectedClosingDate");
		ts["CAR_CCRSubjectTo"]=application.zcore.functions.zso(ds, "CAR_CCRSubjectTo");
		ts["RoomType"]=application.zcore.functions.zso(ds, "RoomType");
		ts["CAR_room1_BathsFull"]=application.zcore.functions.zso(ds, "CAR_room1_BathsFull");
		ts["CAR_room1_BathsHalf"]=application.zcore.functions.zso(ds, "CAR_room1_BathsHalf");
		ts["CAR_room1_BedsTotal"]=application.zcore.functions.zso(ds, "CAR_room1_BedsTotal");
		ts["RoomBathroom1Level"]=application.zcore.functions.zso(ds, "RoomBathroom1Level");
		ts["RoomBathroom2Level"]=application.zcore.functions.zso(ds, "RoomBathroom2Level");
		ts["RoomBreakfastRoomLevel"]=application.zcore.functions.zso(ds, "RoomBreakfastRoomLevel");
		ts["RoomDiningRoomLevel"]=application.zcore.functions.zso(ds, "RoomDiningRoomLevel");
		ts["RoomFamilyRoomLevel"]=application.zcore.functions.zso(ds, "RoomFamilyRoomLevel");
		ts["RoomKitchenLevel"]=application.zcore.functions.zso(ds, "RoomKitchenLevel");
		ts["RoomLivingRoomLevel"]=application.zcore.functions.zso(ds, "RoomLivingRoomLevel");
		ts["RoomMasterBedroomLevel"]=application.zcore.functions.zso(ds, "RoomMasterBedroomLevel");
		ts["CAR_room1_RoomType"]=application.zcore.functions.zso(ds, "CAR_room1_RoomType");
		ts["CAR_room2_BathsFull"]=application.zcore.functions.zso(ds, "CAR_room2_BathsFull");
		ts["CAR_room2_BathsHalf"]=application.zcore.functions.zso(ds, "CAR_room2_BathsHalf");
		ts["CAR_room2_BedsTotal"]=application.zcore.functions.zso(ds, "CAR_room2_BedsTotal");
		ts["RoomBathroom3Level"]=application.zcore.functions.zso(ds, "RoomBathroom3Level");
		ts["RoomBathroom4Level"]=application.zcore.functions.zso(ds, "RoomBathroom4Level");
		ts["RoomBathroom5Level"]=application.zcore.functions.zso(ds, "RoomBathroom5Level");
		ts["RoomLaundryLevel"]=application.zcore.functions.zso(ds, "RoomLaundryLevel");
		ts["RoomLoftLevel"]=application.zcore.functions.zso(ds, "RoomLoftLevel");
		ts["RoomMasterBedroom2Level"]=application.zcore.functions.zso(ds, "RoomMasterBedroom2Level");
		ts["RoomBedroom1Level"]=application.zcore.functions.zso(ds, "RoomBedroom1Level");
		ts["RoomBedroom2Level"]=application.zcore.functions.zso(ds, "RoomBedroom2Level");
		ts["CAR_room2_RoomType"]=application.zcore.functions.zso(ds, "CAR_room2_RoomType");
		ts["CAR_room3_BathsFull"]=application.zcore.functions.zso(ds, "CAR_room3_BathsFull");
		ts["CAR_room3_BathsHalf"]=application.zcore.functions.zso(ds, "CAR_room3_BathsHalf");
		ts["CAR_room3_BedsTotal"]=application.zcore.functions.zso(ds, "CAR_room3_BedsTotal");
		ts["RoomBathroom6Level"]=application.zcore.functions.zso(ds, "RoomBathroom6Level");
		ts["RoomLoft2Level"]=application.zcore.functions.zso(ds, "RoomLoft2Level");
		ts["RoomPlayRoomLevel"]=application.zcore.functions.zso(ds, "RoomPlayRoomLevel");
		ts["RoomBedroom3Level"]=application.zcore.functions.zso(ds, "RoomBedroom3Level");
		ts["CAR_room3_RoomType"]=application.zcore.functions.zso(ds, "CAR_room3_RoomType");
		ts["CAR_room4_BathsFull"]=application.zcore.functions.zso(ds, "CAR_room4_BathsFull");
		ts["CAR_room4_BathsHalf"]=application.zcore.functions.zso(ds, "CAR_room4_BathsHalf");
		ts["CAR_room4_BedsTotal"]=application.zcore.functions.zso(ds, "CAR_room4_BedsTotal");
		ts["RoomNoneLevel"]=application.zcore.functions.zso(ds, "RoomNoneLevel");
		ts["CAR_room4_RoomType"]=application.zcore.functions.zso(ds, "CAR_room4_RoomType");
		ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
		ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");

		// PropertyRlse
		ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
ts["AboveGradeFinishedArea"]=application.zcore.functions.zso(ds, "AboveGradeFinishedArea");
ts["ArchitecturalStyle"]=application.zcore.functions.zso(ds, "ArchitecturalStyle");
ts["AvailabilityDate"]=application.zcore.functions.zso(ds, "AvailabilityDate");
ts["BathroomsFull"]=application.zcore.functions.zso(ds, "BathroomsFull");
ts["BathroomsHalf"]=application.zcore.functions.zso(ds, "BathroomsHalf");
ts["BathroomsTotalInteger"]=application.zcore.functions.zso(ds, "BathroomsTotalInteger");
ts["BedroomsTotal"]=application.zcore.functions.zso(ds, "BedroomsTotal");
ts["CAR_BuyerAgentSaleYN"]=application.zcore.functions.zso(ds, "CAR_BuyerAgentSaleYN");
ts["CumulativeDaysOnMarket"]=application.zcore.functions.zso(ds, "CumulativeDaysOnMarket");
ts["City"]=application.zcore.functions.zso(ds, "City");
ts["CloseDate"]=application.zcore.functions.zso(ds, "CloseDate");
ts["ClosePrice"]=application.zcore.functions.zso(ds, "ClosePrice");
ts["CountyOrParish"]=application.zcore.functions.zso(ds, "CountyOrParish");
ts["DaysOnMarket"]=application.zcore.functions.zso(ds, "DaysOnMarket");
ts["CAR_DOMToClose"]=application.zcore.functions.zso(ds, "CAR_DOMToClose");
ts["RoadSurfaceType"]=application.zcore.functions.zso(ds, "RoadSurfaceType");
ts["ElementarySchool"]=application.zcore.functions.zso(ds, "ElementarySchool");
ts["Appliances"]=application.zcore.functions.zso(ds, "Appliances");
ts["FireplaceFeatures"]=application.zcore.functions.zso(ds, "FireplaceFeatures");
ts["FireplaceYN"]=application.zcore.functions.zso(ds, "FireplaceYN");
ts["Flooring"]=application.zcore.functions.zso(ds, "Flooring");
ts["FoundationDetails"]=application.zcore.functions.zso(ds, "FoundationDetails");
ts["Furnished"]=application.zcore.functions.zso(ds, "Furnished");
ts["CAR_GeocodeSource"]=application.zcore.functions.zso(ds, "CAR_GeocodeSource");
ts["Heating"]=application.zcore.functions.zso(ds, "Heating");
ts["HighSchool"]=application.zcore.functions.zso(ds, "HighSchool");
ts["CAR_HOASubjectTo"]=application.zcore.functions.zso(ds, "CAR_HOASubjectTo");
ts["InteriorFeatures"]=application.zcore.functions.zso(ds, "InteriorFeatures");
ts["Latitude"]=application.zcore.functions.zso(ds, "Latitude");
ts["LaundryFeatures"]=application.zcore.functions.zso(ds, "LaundryFeatures");
ts["ListAgentKey"]=application.zcore.functions.zso(ds, "ListAgentKey");
ts["ListAgentDirectPhone"]=application.zcore.functions.zso(ds, "ListAgentDirectPhone");
ts["ListAgentFullName"]=application.zcore.functions.zso(ds, "ListAgentFullName");
ts["ListAgentMlsId"]=application.zcore.functions.zso(ds, "ListAgentMlsId");
ts["ListAgentAOR"]=application.zcore.functions.zso(ds, "ListAgentAOR");
ts["ListingContractDate"]=application.zcore.functions.zso(ds, "ListingContractDate");
ts["ListingAgreement"]=application.zcore.functions.zso(ds, "ListingAgreement");
ts["ListOfficeKey"]=application.zcore.functions.zso(ds, "ListOfficeKey");
ts["ListOfficeMlsId"]=application.zcore.functions.zso(ds, "ListOfficeMlsId");
ts["ListOfficeName"]=application.zcore.functions.zso(ds, "ListOfficeName");
ts["ListOfficePhone"]=application.zcore.functions.zso(ds, "ListOfficePhone");
ts["ListPrice"]=application.zcore.functions.zso(ds, "ListPrice");
ts["Longitude"]=application.zcore.functions.zso(ds, "Longitude");
ts["LotSizeArea"]=application.zcore.functions.zso(ds, "LotSizeArea");
ts["CAR_MainLevelGarageYN"]=application.zcore.functions.zso(ds, "CAR_MainLevelGarageYN");
ts["ListingKey"]=application.zcore.functions.zso(ds, "ListingKey");
ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
ts["MiddleOrJuniorSchool"]=application.zcore.functions.zso(ds, "MiddleOrJuniorSchool");
ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
ts["ListingId"]=application.zcore.functions.zso(ds, "ListingId");
ts["OccupantType"]=application.zcore.functions.zso(ds, "OccupantType");
ts["CAR_OwnerAgentYN"]=application.zcore.functions.zso(ds, "CAR_OwnerAgentYN");
ts["ParcelNumber"]=application.zcore.functions.zso(ds, "ParcelNumber");
ts["ParkingFeatures"]=application.zcore.functions.zso(ds, "ParkingFeatures");
ts["InternetAddressDisplayYN"]=application.zcore.functions.zso(ds, "InternetAddressDisplayYN");
ts["InternetEntireListingDisplayYN"]=application.zcore.functions.zso(ds, "InternetEntireListingDisplayYN");
ts["CAR_PermitSyndicationYN"]=application.zcore.functions.zso(ds, "CAR_PermitSyndicationYN");
ts["PetsAllowed"]=application.zcore.functions.zso(ds, "PetsAllowed");
ts["PhotosCount"]=application.zcore.functions.zso(ds, "PhotosCount");
ts["PhotosChangeTimestamp"]=application.zcore.functions.zso(ds, "PhotosChangeTimestamp");
ts["CAR_Porch"]=application.zcore.functions.zso(ds, "CAR_Porch");
ts["PostalCode"]=application.zcore.functions.zso(ds, "PostalCode");
ts["PostalCodePlus4"]=application.zcore.functions.zso(ds, "PostalCodePlus4");
ts["StructureType"]=application.zcore.functions.zso(ds, "StructureType");
ts["PropertySubType"]=application.zcore.functions.zso(ds, "PropertySubType");
ts["CAR_PropertySubTypeSecondary"]=application.zcore.functions.zso(ds, "CAR_PropertySubTypeSecondary");
ts["PropertyType"]=application.zcore.functions.zso(ds, "PropertyType");
ts["PublicRemarks"]=application.zcore.functions.zso(ds, "PublicRemarks");
ts["CAR_RATIO_CurrentPrice_By_Acre"]=application.zcore.functions.zso(ds, "CAR_RATIO_CurrentPrice_By_Acre");
ts["BuyerAgentKey"]=application.zcore.functions.zso(ds, "BuyerAgentKey");
ts["BuyerAgentAOR"]=application.zcore.functions.zso(ds, "BuyerAgentAOR");
ts["BuyerAgentMlsId"]=application.zcore.functions.zso(ds, "BuyerAgentMlsId");
ts["BuyerOfficeKey"]=application.zcore.functions.zso(ds, "BuyerOfficeKey");
ts["BuyerOfficeMlsId"]=application.zcore.functions.zso(ds, "BuyerOfficeMlsId");
ts["Sewer"]=application.zcore.functions.zso(ds, "Sewer");
ts["ShowingContactPhone"]=application.zcore.functions.zso(ds, "ShowingContactPhone");
ts["LivingArea"]=application.zcore.functions.zso(ds, "LivingArea");
ts["BuildingAreaTotal"]=application.zcore.functions.zso(ds, "BuildingAreaTotal");
ts["StateOrProvince"]=application.zcore.functions.zso(ds, "StateOrProvince");
ts["StandardStatus"]=application.zcore.functions.zso(ds, "StandardStatus");
ts["CAR_StatusContractualSearchDate"]=application.zcore.functions.zso(ds, "CAR_StatusContractualSearchDate");
ts["StreetName"]=application.zcore.functions.zso(ds, "StreetName");
ts["StreetNumber"]=application.zcore.functions.zso(ds, "StreetNumber");
ts["StreetNumberNumeric"]=application.zcore.functions.zso(ds, "StreetNumberNumeric");
ts["StreetSuffix"]=application.zcore.functions.zso(ds, "StreetSuffix");
ts["CAR_StreetViewParam"]=application.zcore.functions.zso(ds, "CAR_StreetViewParam");
ts["SubdivisionName"]=application.zcore.functions.zso(ds, "SubdivisionName");
ts["CAR_Table"]=application.zcore.functions.zso(ds, "CAR_Table");
ts["TenantPays"]=application.zcore.functions.zso(ds, "TenantPays");
ts["CAR_UnitCount"]=application.zcore.functions.zso(ds, "CAR_UnitCount");
ts["EntryLevel"]=application.zcore.functions.zso(ds, "EntryLevel");
ts["InternetAutomatedValuationDisplayYN"]=application.zcore.functions.zso(ds, "InternetAutomatedValuationDisplayYN");
ts["InternetConsumerCommentYN"]=application.zcore.functions.zso(ds, "InternetConsumerCommentYN");
ts["WaterSource"]=application.zcore.functions.zso(ds, "WaterSource");
ts["CAR_WaterHeater"]=application.zcore.functions.zso(ds, "CAR_WaterHeater");
ts["YearBuilt"]=application.zcore.functions.zso(ds, "YearBuilt");
ts["ZoningDescription"]=application.zcore.functions.zso(ds, "ZoningDescription");
ts["RoomType"]=application.zcore.functions.zso(ds, "RoomType");
ts["CAR_room1_BathsHalf"]=application.zcore.functions.zso(ds, "CAR_room1_BathsHalf");
ts["RoomBathroom1Level"]=application.zcore.functions.zso(ds, "RoomBathroom1Level");
ts["RoomBreakfastRoomLevel"]=application.zcore.functions.zso(ds, "RoomBreakfastRoomLevel");
ts["RoomKitchenLevel"]=application.zcore.functions.zso(ds, "RoomKitchenLevel");
ts["RoomLaundryLevel"]=application.zcore.functions.zso(ds, "RoomLaundryLevel");
ts["RoomLivingRoomLevel"]=application.zcore.functions.zso(ds, "RoomLivingRoomLevel");
ts["RoomPantryLevel"]=application.zcore.functions.zso(ds, "RoomPantryLevel");
ts["CAR_room1_RoomType"]=application.zcore.functions.zso(ds, "CAR_room1_RoomType");
ts["CAR_room2_BathsFull"]=application.zcore.functions.zso(ds, "CAR_room2_BathsFull");
ts["CAR_room2_BathsHalf"]=application.zcore.functions.zso(ds, "CAR_room2_BathsHalf");
ts["CAR_room2_BedsTotal"]=application.zcore.functions.zso(ds, "CAR_room2_BedsTotal");
ts["RoomBathroom2Level"]=application.zcore.functions.zso(ds, "RoomBathroom2Level");
ts["RoomBathroom3Level"]=application.zcore.functions.zso(ds, "RoomBathroom3Level");
ts["RoomBedroom1Level"]=application.zcore.functions.zso(ds, "RoomBedroom1Level");
ts["RoomBedroom2Level"]=application.zcore.functions.zso(ds, "RoomBedroom2Level");
ts["RoomBedroom3Level"]=application.zcore.functions.zso(ds, "RoomBedroom3Level");
ts["CAR_room2_RoomType"]=application.zcore.functions.zso(ds, "CAR_room2_RoomType");
ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");

// PropertyRinc
ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
ts["AccessibilityFeatures"]=application.zcore.functions.zso(ds, "AccessibilityFeatures");
ts["BathroomsFull"]=application.zcore.functions.zso(ds, "BathroomsFull");
ts["BathroomsHalf"]=application.zcore.functions.zso(ds, "BathroomsHalf");
ts["BedroomsTotal"]=application.zcore.functions.zso(ds, "BedroomsTotal");
ts["CAR_BuyerAgentSaleYN"]=application.zcore.functions.zso(ds, "CAR_BuyerAgentSaleYN");
ts["CAR_CCRSubjectTo"]=application.zcore.functions.zso(ds, "CAR_CCRSubjectTo");
ts["CumulativeDaysOnMarket"]=application.zcore.functions.zso(ds, "CumulativeDaysOnMarket");
ts["City"]=application.zcore.functions.zso(ds, "City");
ts["CommunityFeatures"]=application.zcore.functions.zso(ds, "CommunityFeatures");
ts["CAR_ConstructionStatus"]=application.zcore.functions.zso(ds, "CAR_ConstructionStatus");
ts["CAR_ConstructionType"]=application.zcore.functions.zso(ds, "CAR_ConstructionType");
ts["CountyOrParish"]=application.zcore.functions.zso(ds, "CountyOrParish");
ts["CAR_DeedReference"]=application.zcore.functions.zso(ds, "CAR_DeedReference");
ts["Directions"]=application.zcore.functions.zso(ds, "Directions");
ts["DaysOnMarket"]=application.zcore.functions.zso(ds, "DaysOnMarket");
ts["RoadSurfaceType"]=application.zcore.functions.zso(ds, "RoadSurfaceType");
ts["ElementarySchool"]=application.zcore.functions.zso(ds, "ElementarySchool");
ts["Appliances"]=application.zcore.functions.zso(ds, "Appliances");
ts["ConstructionMaterials"]=application.zcore.functions.zso(ds, "ConstructionMaterials");
ts["FireplaceFeatures"]=application.zcore.functions.zso(ds, "FireplaceFeatures");
ts["FireplaceYN"]=application.zcore.functions.zso(ds, "FireplaceYN");
ts["Flooring"]=application.zcore.functions.zso(ds, "Flooring");
ts["FoundationDetails"]=application.zcore.functions.zso(ds, "FoundationDetails");
ts["CAR_GeocodeSource"]=application.zcore.functions.zso(ds, "CAR_GeocodeSource");
ts["Heating"]=application.zcore.functions.zso(ds, "Heating");
ts["HighSchool"]=application.zcore.functions.zso(ds, "HighSchool");
ts["CAR_HOASubjectTo"]=application.zcore.functions.zso(ds, "CAR_HOASubjectTo");
ts["Latitude"]=application.zcore.functions.zso(ds, "Latitude");
ts["LaundryFeatures"]=application.zcore.functions.zso(ds, "LaundryFeatures");
ts["ListAgentKey"]=application.zcore.functions.zso(ds, "ListAgentKey");
ts["ListAgentDirectPhone"]=application.zcore.functions.zso(ds, "ListAgentDirectPhone");
ts["ListAgentFullName"]=application.zcore.functions.zso(ds, "ListAgentFullName");
ts["ListAgentMlsId"]=application.zcore.functions.zso(ds, "ListAgentMlsId");
ts["ListAgentAOR"]=application.zcore.functions.zso(ds, "ListAgentAOR");
ts["ListingContractDate"]=application.zcore.functions.zso(ds, "ListingContractDate");
ts["ListingTerms"]=application.zcore.functions.zso(ds, "ListingTerms");
ts["ListingAgreement"]=application.zcore.functions.zso(ds, "ListingAgreement");
ts["ListOfficeKey"]=application.zcore.functions.zso(ds, "ListOfficeKey");
ts["ListOfficeMlsId"]=application.zcore.functions.zso(ds, "ListOfficeMlsId");
ts["ListOfficeName"]=application.zcore.functions.zso(ds, "ListOfficeName");
ts["ListOfficePhone"]=application.zcore.functions.zso(ds, "ListOfficePhone");
ts["ListPrice"]=application.zcore.functions.zso(ds, "ListPrice");
ts["Longitude"]=application.zcore.functions.zso(ds, "Longitude");
ts["LotSizeArea"]=application.zcore.functions.zso(ds, "LotSizeArea");
ts["CAR_MainLevelGarageYN"]=application.zcore.functions.zso(ds, "CAR_MainLevelGarageYN");
ts["ListingKey"]=application.zcore.functions.zso(ds, "ListingKey");
ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
ts["MiddleOrJuniorSchool"]=application.zcore.functions.zso(ds, "MiddleOrJuniorSchool");
ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
ts["ListingId"]=application.zcore.functions.zso(ds, "ListingId");
ts["NewConstructionYN"]=application.zcore.functions.zso(ds, "NewConstructionYN");
ts["NumberOfUnitsTotal"]=application.zcore.functions.zso(ds, "NumberOfUnitsTotal");
ts["OccupantType"]=application.zcore.functions.zso(ds, "OccupantType");
ts["CAR_OwnerAgentYN"]=application.zcore.functions.zso(ds, "CAR_OwnerAgentYN");
ts["ParcelNumber"]=application.zcore.functions.zso(ds, "ParcelNumber");
ts["ParkingFeatures"]=application.zcore.functions.zso(ds, "ParkingFeatures");
ts["PendingTimestamp"]=application.zcore.functions.zso(ds, "PendingTimestamp");
ts["InternetAddressDisplayYN"]=application.zcore.functions.zso(ds, "InternetAddressDisplayYN");
ts["InternetEntireListingDisplayYN"]=application.zcore.functions.zso(ds, "InternetEntireListingDisplayYN");
ts["CAR_PermitSyndicationYN"]=application.zcore.functions.zso(ds, "CAR_PermitSyndicationYN");
ts["PetsAllowed"]=application.zcore.functions.zso(ds, "PetsAllowed");
ts["PhotosCount"]=application.zcore.functions.zso(ds, "PhotosCount");
ts["PhotosChangeTimestamp"]=application.zcore.functions.zso(ds, "PhotosChangeTimestamp");
ts["CAR_Porch"]=application.zcore.functions.zso(ds, "CAR_Porch");
ts["PostalCode"]=application.zcore.functions.zso(ds, "PostalCode");
ts["PostalCodePlus4"]=application.zcore.functions.zso(ds, "PostalCodePlus4");
ts["StructureType"]=application.zcore.functions.zso(ds, "StructureType");
ts["PropertySubType"]=application.zcore.functions.zso(ds, "PropertySubType");
ts["PropertyType"]=application.zcore.functions.zso(ds, "PropertyType");
ts["CAR_ProposedSpecialAssessmentYN"]=application.zcore.functions.zso(ds, "CAR_ProposedSpecialAssessmentYN");
ts["PublicRemarks"]=application.zcore.functions.zso(ds, "PublicRemarks");
ts["CAR_RATIO_CurrentPrice_By_Acre"]=application.zcore.functions.zso(ds, "CAR_RATIO_CurrentPrice_By_Acre");
ts["CAR_RATIO_ListPrice_By_TaxAmount"]=application.zcore.functions.zso(ds, "CAR_RATIO_ListPrice_By_TaxAmount");
ts["RoadResponsibility"]=application.zcore.functions.zso(ds, "RoadResponsibility");
ts["BuyerAgentKey"]=application.zcore.functions.zso(ds, "BuyerAgentKey");
ts["BuyerAgentAOR"]=application.zcore.functions.zso(ds, "BuyerAgentAOR");
ts["BuyerAgentMlsId"]=application.zcore.functions.zso(ds, "BuyerAgentMlsId");
ts["BuyerOfficeKey"]=application.zcore.functions.zso(ds, "BuyerOfficeKey");
ts["BuyerOfficeMlsId"]=application.zcore.functions.zso(ds, "BuyerOfficeMlsId");
ts["Sewer"]=application.zcore.functions.zso(ds, "Sewer");
ts["ShowingContactPhone"]=application.zcore.functions.zso(ds, "ShowingContactPhone");
ts["SpecialListingConditions"]=application.zcore.functions.zso(ds, "SpecialListingConditions");
ts["CAR_SqFtAdditional"]=application.zcore.functions.zso(ds, "CAR_SqFtAdditional");
ts["BelowGradeFinishedArea"]=application.zcore.functions.zso(ds, "BelowGradeFinishedArea");
ts["CAR_SqFtGarage"]=application.zcore.functions.zso(ds, "CAR_SqFtGarage");
ts["LivingArea"]=application.zcore.functions.zso(ds, "LivingArea");
ts["BuildingAreaTotal"]=application.zcore.functions.zso(ds, "BuildingAreaTotal");
ts["StateOrProvince"]=application.zcore.functions.zso(ds, "StateOrProvince");
ts["StandardStatus"]=application.zcore.functions.zso(ds, "StandardStatus");
ts["CAR_StatusContractualSearchDate"]=application.zcore.functions.zso(ds, "CAR_StatusContractualSearchDate");
ts["StreetName"]=application.zcore.functions.zso(ds, "StreetName");
ts["StreetNumber"]=application.zcore.functions.zso(ds, "StreetNumber");
ts["StreetNumberNumeric"]=application.zcore.functions.zso(ds, "StreetNumberNumeric");
ts["StreetSuffix"]=application.zcore.functions.zso(ds, "StreetSuffix");
ts["CAR_StreetViewParam"]=application.zcore.functions.zso(ds, "CAR_StreetViewParam");
ts["SyndicationRemarks"]=application.zcore.functions.zso(ds, "SyndicationRemarks");
ts["CAR_Table"]=application.zcore.functions.zso(ds, "CAR_Table");
ts["TaxAnnualAmount"]=application.zcore.functions.zso(ds, "TaxAnnualAmount");
ts["TenantPays"]=application.zcore.functions.zso(ds, "TenantPays");
ts["CAR_UnitCount"]=application.zcore.functions.zso(ds, "CAR_UnitCount");
ts["InternetAutomatedValuationDisplayYN"]=application.zcore.functions.zso(ds, "InternetAutomatedValuationDisplayYN");
ts["InternetConsumerCommentYN"]=application.zcore.functions.zso(ds, "InternetConsumerCommentYN");
ts["WaterSource"]=application.zcore.functions.zso(ds, "WaterSource");
ts["WaterfrontFeatures"]=application.zcore.functions.zso(ds, "WaterfrontFeatures");
ts["CAR_WaterHeater"]=application.zcore.functions.zso(ds, "CAR_WaterHeater");
ts["YearBuilt"]=application.zcore.functions.zso(ds, "YearBuilt");
ts["CAR_ZoningNCM"]=application.zcore.functions.zso(ds, "CAR_ZoningNCM");
ts["ZoningDescription"]=application.zcore.functions.zso(ds, "ZoningDescription");
ts["CAR_unit1_BathsFull"]=application.zcore.functions.zso(ds, "CAR_unit1_BathsFull");
ts["CAR_unit1_BathsHalf"]=application.zcore.functions.zso(ds, "CAR_unit1_BathsHalf");
ts["UnitType1BedsTotal"]=application.zcore.functions.zso(ds, "UnitType1BedsTotal");
ts["CAR_unit1_SqFtTotal"]=application.zcore.functions.zso(ds, "CAR_unit1_SqFtTotal");
ts["CAR_unit1_UnitRooms"]=application.zcore.functions.zso(ds, "CAR_unit1_UnitRooms");
ts["CAR_unit2_BathsFull"]=application.zcore.functions.zso(ds, "CAR_unit2_BathsFull");
ts["CAR_unit2_BathsHalf"]=application.zcore.functions.zso(ds, "CAR_unit2_BathsHalf");
ts["UnitType2BedsTotal"]=application.zcore.functions.zso(ds, "UnitType2BedsTotal");
ts["CAR_unit2_SqFtTotal"]=application.zcore.functions.zso(ds, "CAR_unit2_SqFtTotal");
ts["CAR_unit2_UnitRooms"]=application.zcore.functions.zso(ds, "CAR_unit2_UnitRooms");
ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");

// PropertyLand
ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
ts["AssociationFee"]=application.zcore.functions.zso(ds, "AssociationFee");
ts["AssociationFeeFrequency"]=application.zcore.functions.zso(ds, "AssociationFeeFrequency");
ts["CAR_BuyerAgentSaleYN"]=application.zcore.functions.zso(ds, "CAR_BuyerAgentSaleYN");
ts["CAR_CanSubdivideYN"]=application.zcore.functions.zso(ds, "CAR_CanSubdivideYN");
ts["CumulativeDaysOnMarket"]=application.zcore.functions.zso(ds, "CumulativeDaysOnMarket");
ts["City"]=application.zcore.functions.zso(ds, "City");
ts["CoListAgentKey"]=application.zcore.functions.zso(ds, "CoListAgentKey");
ts["CoListAgentFullName"]=application.zcore.functions.zso(ds, "CoListAgentFullName");
ts["CoListAgentAOR"]=application.zcore.functions.zso(ds, "CoListAgentAOR");
ts["CoListAgentMlsId"]=application.zcore.functions.zso(ds, "CoListAgentMlsId");
ts["CoListOfficeKey"]=application.zcore.functions.zso(ds, "CoListOfficeKey");
ts["CoListOfficeMlsId"]=application.zcore.functions.zso(ds, "CoListOfficeMlsId");
ts["CoListOfficeName"]=application.zcore.functions.zso(ds, "CoListOfficeName");
ts["CommunityFeatures"]=application.zcore.functions.zso(ds, "CommunityFeatures");
ts["CountyOrParish"]=application.zcore.functions.zso(ds, "CountyOrParish");
ts["CAR_DeedReference"]=application.zcore.functions.zso(ds, "CAR_DeedReference");
ts["Directions"]=application.zcore.functions.zso(ds, "Directions");
ts["DaysOnMarket"]=application.zcore.functions.zso(ds, "DaysOnMarket");
ts["ElementarySchool"]=application.zcore.functions.zso(ds, "ElementarySchool");
ts["FoundationDetails"]=application.zcore.functions.zso(ds, "FoundationDetails");
ts["CAR_GeocodeSource"]=application.zcore.functions.zso(ds, "CAR_GeocodeSource");
ts["HabitableResidenceYN"]=application.zcore.functions.zso(ds, "HabitableResidenceYN");
ts["HighSchool"]=application.zcore.functions.zso(ds, "HighSchool");
ts["AssociationName"]=application.zcore.functions.zso(ds, "AssociationName");
ts["AssociationPhone"]=application.zcore.functions.zso(ds, "AssociationPhone");
ts["CAR_HOASubjectTo"]=application.zcore.functions.zso(ds, "CAR_HOASubjectTo");
ts["CAR_HOASubjectToDues"]=application.zcore.functions.zso(ds, "CAR_HOASubjectToDues");
ts["Latitude"]=application.zcore.functions.zso(ds, "Latitude");
ts["ListAgentKey"]=application.zcore.functions.zso(ds, "ListAgentKey");
ts["ListAgentDirectPhone"]=application.zcore.functions.zso(ds, "ListAgentDirectPhone");
ts["ListAgentFullName"]=application.zcore.functions.zso(ds, "ListAgentFullName");
ts["ListAgentMlsId"]=application.zcore.functions.zso(ds, "ListAgentMlsId");
ts["ListAgentAOR"]=application.zcore.functions.zso(ds, "ListAgentAOR");
ts["ListingContractDate"]=application.zcore.functions.zso(ds, "ListingContractDate");
ts["ListingTerms"]=application.zcore.functions.zso(ds, "ListingTerms");
ts["ListingAgreement"]=application.zcore.functions.zso(ds, "ListingAgreement");
ts["ListOfficeKey"]=application.zcore.functions.zso(ds, "ListOfficeKey");
ts["ListOfficeMlsId"]=application.zcore.functions.zso(ds, "ListOfficeMlsId");
ts["ListOfficeName"]=application.zcore.functions.zso(ds, "ListOfficeName");
ts["ListOfficePhone"]=application.zcore.functions.zso(ds, "ListOfficePhone");
ts["ListPrice"]=application.zcore.functions.zso(ds, "ListPrice");
ts["Longitude"]=application.zcore.functions.zso(ds, "Longitude");
ts["LotSizeDimensions"]=application.zcore.functions.zso(ds, "LotSizeDimensions");
ts["LotSizeArea"]=application.zcore.functions.zso(ds, "LotSizeArea");
ts["ListingKey"]=application.zcore.functions.zso(ds, "ListingKey");
ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
ts["MiddleOrJuniorSchool"]=application.zcore.functions.zso(ds, "MiddleOrJuniorSchool");
ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
ts["ListingId"]=application.zcore.functions.zso(ds, "ListingId");
ts["CAR_OutBuildingsYN"]=application.zcore.functions.zso(ds, "CAR_OutBuildingsYN");
ts["CAR_OwnerAgentYN"]=application.zcore.functions.zso(ds, "CAR_OwnerAgentYN");
ts["ParcelNumber"]=application.zcore.functions.zso(ds, "ParcelNumber");
ts["InternetAddressDisplayYN"]=application.zcore.functions.zso(ds, "InternetAddressDisplayYN");
ts["InternetEntireListingDisplayYN"]=application.zcore.functions.zso(ds, "InternetEntireListingDisplayYN");
ts["CAR_PermitSyndicationYN"]=application.zcore.functions.zso(ds, "CAR_PermitSyndicationYN");
ts["PhotosCount"]=application.zcore.functions.zso(ds, "PhotosCount");
ts["PhotosChangeTimestamp"]=application.zcore.functions.zso(ds, "PhotosChangeTimestamp");
ts["CAR_PlatBookSlide"]=application.zcore.functions.zso(ds, "CAR_PlatBookSlide");
ts["CAR_PlatReferenceSectionPages"]=application.zcore.functions.zso(ds, "CAR_PlatReferenceSectionPages");
ts["PostalCode"]=application.zcore.functions.zso(ds, "PostalCode");
ts["StructureType"]=application.zcore.functions.zso(ds, "StructureType");
ts["PropertySubType"]=application.zcore.functions.zso(ds, "PropertySubType");
ts["PropertyType"]=application.zcore.functions.zso(ds, "PropertyType");
ts["PublicRemarks"]=application.zcore.functions.zso(ds, "PublicRemarks");
ts["CAR_RATIO_CurrentPrice_By_Acre"]=application.zcore.functions.zso(ds, "CAR_RATIO_CurrentPrice_By_Acre");
ts["CAR_RATIO_ListPrice_By_TaxAmount"]=application.zcore.functions.zso(ds, "CAR_RATIO_ListPrice_By_TaxAmount");
ts["CAR_Restrictions"]=application.zcore.functions.zso(ds, "CAR_Restrictions");
ts["RoadResponsibility"]=application.zcore.functions.zso(ds, "RoadResponsibility");
ts["Sewer"]=application.zcore.functions.zso(ds, "Sewer");
ts["ShowingContactPhone"]=application.zcore.functions.zso(ds, "ShowingContactPhone");
ts["SpecialListingConditions"]=application.zcore.functions.zso(ds, "SpecialListingConditions");
ts["CAR_SqFtBuildingMinimum"]=application.zcore.functions.zso(ds, "CAR_SqFtBuildingMinimum");
ts["StateOrProvince"]=application.zcore.functions.zso(ds, "StateOrProvince");
ts["StandardStatus"]=application.zcore.functions.zso(ds, "StandardStatus");
ts["CAR_StatusContractualSearchDate"]=application.zcore.functions.zso(ds, "CAR_StatusContractualSearchDate");
ts["StreetName"]=application.zcore.functions.zso(ds, "StreetName");
ts["StreetNumber"]=application.zcore.functions.zso(ds, "StreetNumber");
ts["StreetNumberNumeric"]=application.zcore.functions.zso(ds, "StreetNumberNumeric");
ts["StreetSuffix"]=application.zcore.functions.zso(ds, "StreetSuffix");
ts["CAR_StreetViewParam"]=application.zcore.functions.zso(ds, "CAR_StreetViewParam");
ts["SubdivisionName"]=application.zcore.functions.zso(ds, "SubdivisionName");
ts["CAR_SuitableUse"]=application.zcore.functions.zso(ds, "CAR_SuitableUse");
ts["CAR_Table"]=application.zcore.functions.zso(ds, "CAR_Table");
ts["TaxAnnualAmount"]=application.zcore.functions.zso(ds, "TaxAnnualAmount");
ts["CAR_UnitCount"]=application.zcore.functions.zso(ds, "CAR_UnitCount");
ts["InternetAutomatedValuationDisplayYN"]=application.zcore.functions.zso(ds, "InternetAutomatedValuationDisplayYN");
ts["InternetConsumerCommentYN"]=application.zcore.functions.zso(ds, "InternetConsumerCommentYN");
ts["WaterSource"]=application.zcore.functions.zso(ds, "WaterSource");
ts["CAR_ZoningNCM"]=application.zcore.functions.zso(ds, "CAR_ZoningNCM");
ts["ZoningDescription"]=application.zcore.functions.zso(ds, "ZoningDescription");
ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");

// PropertyFarm
ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
ts["CAR_BuyerAgentSaleYN"]=application.zcore.functions.zso(ds, "CAR_BuyerAgentSaleYN");
ts["CumulativeDaysOnMarket"]=application.zcore.functions.zso(ds, "CumulativeDaysOnMarket");
ts["City"]=application.zcore.functions.zso(ds, "City");
ts["CAR_ConstructionType"]=application.zcore.functions.zso(ds, "CAR_ConstructionType");
ts["CAR_CorrectionCount"]=application.zcore.functions.zso(ds, "CAR_CorrectionCount");
ts["CountyOrParish"]=application.zcore.functions.zso(ds, "CountyOrParish");
ts["CAR_DeedReference"]=application.zcore.functions.zso(ds, "CAR_DeedReference");
ts["Directions"]=application.zcore.functions.zso(ds, "Directions");
ts["DaysOnMarket"]=application.zcore.functions.zso(ds, "DaysOnMarket");
ts["ElementarySchool"]=application.zcore.functions.zso(ds, "ElementarySchool");
ts["ExteriorFeatures"]=application.zcore.functions.zso(ds, "ExteriorFeatures");
ts["FoundationDetails"]=application.zcore.functions.zso(ds, "FoundationDetails");
ts["CAR_GeocodeSource"]=application.zcore.functions.zso(ds, "CAR_GeocodeSource");
ts["HabitableResidenceYN"]=application.zcore.functions.zso(ds, "HabitableResidenceYN");
ts["HighSchool"]=application.zcore.functions.zso(ds, "HighSchool");
ts["CAR_HOASubjectTo"]=application.zcore.functions.zso(ds, "CAR_HOASubjectTo");
ts["Latitude"]=application.zcore.functions.zso(ds, "Latitude");
ts["ListAgentKey"]=application.zcore.functions.zso(ds, "ListAgentKey");
ts["ListAgentDirectPhone"]=application.zcore.functions.zso(ds, "ListAgentDirectPhone");
ts["ListAgentFullName"]=application.zcore.functions.zso(ds, "ListAgentFullName");
ts["ListAgentMlsId"]=application.zcore.functions.zso(ds, "ListAgentMlsId");
ts["ListAgentAOR"]=application.zcore.functions.zso(ds, "ListAgentAOR");
ts["ListingContractDate"]=application.zcore.functions.zso(ds, "ListingContractDate");
ts["ListingTerms"]=application.zcore.functions.zso(ds, "ListingTerms");
ts["ListingAgreement"]=application.zcore.functions.zso(ds, "ListingAgreement");
ts["ListOfficeKey"]=application.zcore.functions.zso(ds, "ListOfficeKey");
ts["ListOfficeMlsId"]=application.zcore.functions.zso(ds, "ListOfficeMlsId");
ts["ListOfficeName"]=application.zcore.functions.zso(ds, "ListOfficeName");
ts["ListOfficePhone"]=application.zcore.functions.zso(ds, "ListOfficePhone");
ts["ListPrice"]=application.zcore.functions.zso(ds, "ListPrice");
ts["Longitude"]=application.zcore.functions.zso(ds, "Longitude");
ts["LotFeatures"]=application.zcore.functions.zso(ds, "LotFeatures");
ts["LotSizeArea"]=application.zcore.functions.zso(ds, "LotSizeArea");
ts["ListingKey"]=application.zcore.functions.zso(ds, "ListingKey");
ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
ts["MiddleOrJuniorSchool"]=application.zcore.functions.zso(ds, "MiddleOrJuniorSchool");
ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
ts["ListingId"]=application.zcore.functions.zso(ds, "ListingId");
ts["CAR_OutBuildingsYN"]=application.zcore.functions.zso(ds, "CAR_OutBuildingsYN");
ts["CAR_OwnerAgentYN"]=application.zcore.functions.zso(ds, "CAR_OwnerAgentYN");
ts["ParcelNumber"]=application.zcore.functions.zso(ds, "ParcelNumber");
ts["InternetAddressDisplayYN"]=application.zcore.functions.zso(ds, "InternetAddressDisplayYN");
ts["InternetEntireListingDisplayYN"]=application.zcore.functions.zso(ds, "InternetEntireListingDisplayYN");
ts["CAR_PermitSyndicationYN"]=application.zcore.functions.zso(ds, "CAR_PermitSyndicationYN");
ts["PhotosCount"]=application.zcore.functions.zso(ds, "PhotosCount");
ts["PhotosChangeTimestamp"]=application.zcore.functions.zso(ds, "PhotosChangeTimestamp");
ts["PostalCode"]=application.zcore.functions.zso(ds, "PostalCode");
ts["PostalCodePlus4"]=application.zcore.functions.zso(ds, "PostalCodePlus4");
ts["StructureType"]=application.zcore.functions.zso(ds, "StructureType");
ts["PropertySubType"]=application.zcore.functions.zso(ds, "PropertySubType");
ts["PropertyType"]=application.zcore.functions.zso(ds, "PropertyType");
ts["PublicRemarks"]=application.zcore.functions.zso(ds, "PublicRemarks");
ts["CAR_RATIO_CurrentPrice_By_Acre"]=application.zcore.functions.zso(ds, "CAR_RATIO_CurrentPrice_By_Acre");
ts["CAR_Restrictions"]=application.zcore.functions.zso(ds, "CAR_Restrictions");
ts["RoadResponsibility"]=application.zcore.functions.zso(ds, "RoadResponsibility");
ts["Sewer"]=application.zcore.functions.zso(ds, "Sewer");
ts["ShowingContactPhone"]=application.zcore.functions.zso(ds, "ShowingContactPhone");
ts["SpecialListingConditions"]=application.zcore.functions.zso(ds, "SpecialListingConditions");
ts["CAR_SqFtBuildingMinimum"]=application.zcore.functions.zso(ds, "CAR_SqFtBuildingMinimum");
ts["StateOrProvince"]=application.zcore.functions.zso(ds, "StateOrProvince");
ts["StandardStatus"]=application.zcore.functions.zso(ds, "StandardStatus");
ts["CAR_StatusContractualSearchDate"]=application.zcore.functions.zso(ds, "CAR_StatusContractualSearchDate");
ts["StreetDirSuffix"]=application.zcore.functions.zso(ds, "StreetDirSuffix");
ts["StreetName"]=application.zcore.functions.zso(ds, "StreetName");
ts["StreetNumber"]=application.zcore.functions.zso(ds, "StreetNumber");
ts["StreetNumberNumeric"]=application.zcore.functions.zso(ds, "StreetNumberNumeric");
ts["StreetSuffix"]=application.zcore.functions.zso(ds, "StreetSuffix");
ts["SubdivisionName"]=application.zcore.functions.zso(ds, "SubdivisionName");
ts["SyndicationRemarks"]=application.zcore.functions.zso(ds, "SyndicationRemarks");
ts["CAR_Table"]=application.zcore.functions.zso(ds, "CAR_Table");
ts["TaxAnnualAmount"]=application.zcore.functions.zso(ds, "TaxAnnualAmount");
ts["CAR_UnitCount"]=application.zcore.functions.zso(ds, "CAR_UnitCount");
ts["VirtualTourURLUnbranded"]=application.zcore.functions.zso(ds, "VirtualTourURLUnbranded");
ts["InternetAutomatedValuationDisplayYN"]=application.zcore.functions.zso(ds, "InternetAutomatedValuationDisplayYN");
ts["InternetConsumerCommentYN"]=application.zcore.functions.zso(ds, "InternetConsumerCommentYN");
ts["WaterSource"]=application.zcore.functions.zso(ds, "WaterSource");
ts["ZoningDescription"]=application.zcore.functions.zso(ds, "ZoningDescription");
ts["CAR_RATIO_ListPrice_By_TaxAmount"]=application.zcore.functions.zso(ds, "CAR_RATIO_ListPrice_By_TaxAmount");
ts["CAR_SuitableUse"]=application.zcore.functions.zso(ds, "CAR_SuitableUse");
ts["WaterBodyName"]=application.zcore.functions.zso(ds, "WaterBodyName");
ts["Elevation"]=application.zcore.functions.zso(ds, "Elevation");
ts["WaterfrontFeatures"]=application.zcore.functions.zso(ds, "WaterfrontFeatures");
ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");

// PropertyComs
ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
ts["BathroomsTotalInteger"]=application.zcore.functions.zso(ds, "BathroomsTotalInteger");
ts["CAR_BuyerAgentSaleYN"]=application.zcore.functions.zso(ds, "CAR_BuyerAgentSaleYN");
ts["CumulativeDaysOnMarket"]=application.zcore.functions.zso(ds, "CumulativeDaysOnMarket");
ts["City"]=application.zcore.functions.zso(ds, "City");
ts["Cooling"]=application.zcore.functions.zso(ds, "Cooling");
ts["Heating"]=application.zcore.functions.zso(ds, "Heating");
ts["CAR_ConstructionType"]=application.zcore.functions.zso(ds, "CAR_ConstructionType");
ts["CountyOrParish"]=application.zcore.functions.zso(ds, "CountyOrParish");
ts["CAR_DeedReference"]=application.zcore.functions.zso(ds, "CAR_DeedReference");
ts["DaysOnMarket"]=application.zcore.functions.zso(ds, "DaysOnMarket");
ts["Flooring"]=application.zcore.functions.zso(ds, "Flooring");
ts["FoundationDetails"]=application.zcore.functions.zso(ds, "FoundationDetails");
ts["CAR_GeocodeSource"]=application.zcore.functions.zso(ds, "CAR_GeocodeSource");
ts["CAR_HOASubjectTo"]=application.zcore.functions.zso(ds, "CAR_HOASubjectTo");
ts["Inclusions"]=application.zcore.functions.zso(ds, "Inclusions");
ts["CAR_InsideCityYN"]=application.zcore.functions.zso(ds, "CAR_InsideCityYN");
ts["Latitude"]=application.zcore.functions.zso(ds, "Latitude");
ts["ListAgentKey"]=application.zcore.functions.zso(ds, "ListAgentKey");
ts["ListAgentDirectPhone"]=application.zcore.functions.zso(ds, "ListAgentDirectPhone");
ts["ListAgentFullName"]=application.zcore.functions.zso(ds, "ListAgentFullName");
ts["ListAgentMlsId"]=application.zcore.functions.zso(ds, "ListAgentMlsId");
ts["ListAgentAOR"]=application.zcore.functions.zso(ds, "ListAgentAOR");
ts["ListingContractDate"]=application.zcore.functions.zso(ds, "ListingContractDate");
ts["ListingTerms"]=application.zcore.functions.zso(ds, "ListingTerms");
ts["ListingAgreement"]=application.zcore.functions.zso(ds, "ListingAgreement");
ts["ListOfficeKey"]=application.zcore.functions.zso(ds, "ListOfficeKey");
ts["ListOfficeMlsId"]=application.zcore.functions.zso(ds, "ListOfficeMlsId");
ts["ListOfficeName"]=application.zcore.functions.zso(ds, "ListOfficeName");
ts["ListOfficePhone"]=application.zcore.functions.zso(ds, "ListOfficePhone");
ts["ListPrice"]=application.zcore.functions.zso(ds, "ListPrice");
ts["Longitude"]=application.zcore.functions.zso(ds, "Longitude");
ts["LotSizeArea"]=application.zcore.functions.zso(ds, "LotSizeArea");
ts["ListingKey"]=application.zcore.functions.zso(ds, "ListingKey");
ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
ts["ListingId"]=application.zcore.functions.zso(ds, "ListingId");
ts["NewConstructionYN"]=application.zcore.functions.zso(ds, "NewConstructionYN");
ts["NumberOfBuildings"]=application.zcore.functions.zso(ds, "NumberOfBuildings");
ts["CAR_OwnerAgentYN"]=application.zcore.functions.zso(ds, "CAR_OwnerAgentYN");
ts["ParcelNumber"]=application.zcore.functions.zso(ds, "ParcelNumber");
ts["InternetAddressDisplayYN"]=application.zcore.functions.zso(ds, "InternetAddressDisplayYN");
ts["InternetEntireListingDisplayYN"]=application.zcore.functions.zso(ds, "InternetEntireListingDisplayYN");
ts["CAR_PermitSyndicationYN"]=application.zcore.functions.zso(ds, "CAR_PermitSyndicationYN");
ts["PhotosCount"]=application.zcore.functions.zso(ds, "PhotosCount");
ts["PhotosChangeTimestamp"]=application.zcore.functions.zso(ds, "PhotosChangeTimestamp");
ts["CAR_PlatReferenceSectionPages"]=application.zcore.functions.zso(ds, "CAR_PlatReferenceSectionPages");
ts["PostalCode"]=application.zcore.functions.zso(ds, "PostalCode");
ts["PostalCodePlus4"]=application.zcore.functions.zso(ds, "PostalCodePlus4");
ts["StructureType"]=application.zcore.functions.zso(ds, "StructureType");
ts["PropertySubType"]=application.zcore.functions.zso(ds, "PropertySubType");
ts["CAR_PropertySubTypeSecondary"]=application.zcore.functions.zso(ds, "CAR_PropertySubTypeSecondary");
ts["PropertyType"]=application.zcore.functions.zso(ds, "PropertyType");
ts["PublicRemarks"]=application.zcore.functions.zso(ds, "PublicRemarks");
ts["CAR_RATIO_CurrentPrice_By_Acre"]=application.zcore.functions.zso(ds, "CAR_RATIO_CurrentPrice_By_Acre");
ts["CAR_RATIO_ListPrice_By_TaxAmount"]=application.zcore.functions.zso(ds, "CAR_RATIO_ListPrice_By_TaxAmount");
ts["CAR_Restrictions"]=application.zcore.functions.zso(ds, "CAR_Restrictions");
ts["CAR_RestrictionsDescription"]=application.zcore.functions.zso(ds, "CAR_RestrictionsDescription");
ts["RoadResponsibility"]=application.zcore.functions.zso(ds, "RoadResponsibility");
ts["BuyerAgentAOR"]=application.zcore.functions.zso(ds, "BuyerAgentAOR");
ts["ShowingContactPhone"]=application.zcore.functions.zso(ds, "ShowingContactPhone");
ts["SpecialListingConditions"]=application.zcore.functions.zso(ds, "SpecialListingConditions");
ts["CAR_SqFtAvailableMaximum"]=application.zcore.functions.zso(ds, "CAR_SqFtAvailableMaximum");
ts["CAR_SqFtAvailableMinimum"]=application.zcore.functions.zso(ds, "CAR_SqFtAvailableMinimum");
ts["CAR_SqFtMaximumLease"]=application.zcore.functions.zso(ds, "CAR_SqFtMaximumLease");
ts["CAR_SqFtMinimumLease"]=application.zcore.functions.zso(ds, "CAR_SqFtMinimumLease");
ts["LivingArea"]=application.zcore.functions.zso(ds, "LivingArea");
ts["BuildingAreaTotal"]=application.zcore.functions.zso(ds, "BuildingAreaTotal");
ts["StateOrProvince"]=application.zcore.functions.zso(ds, "StateOrProvince");
ts["StandardStatus"]=application.zcore.functions.zso(ds, "StandardStatus");
ts["CAR_StatusContractualSearchDate"]=application.zcore.functions.zso(ds, "CAR_StatusContractualSearchDate");
ts["StoriesTotal"]=application.zcore.functions.zso(ds, "StoriesTotal");
ts["StreetName"]=application.zcore.functions.zso(ds, "StreetName");
ts["StreetNumber"]=application.zcore.functions.zso(ds, "StreetNumber");
ts["StreetNumberNumeric"]=application.zcore.functions.zso(ds, "StreetNumberNumeric");
ts["StreetSuffix"]=application.zcore.functions.zso(ds, "StreetSuffix");
ts["CAR_StreetViewParam"]=application.zcore.functions.zso(ds, "CAR_StreetViewParam");
ts["CAR_SuitableUse"]=application.zcore.functions.zso(ds, "CAR_SuitableUse");
ts["CAR_Table"]=application.zcore.functions.zso(ds, "CAR_Table");
ts["TaxAnnualAmount"]=application.zcore.functions.zso(ds, "TaxAnnualAmount");
ts["CAR_TransactionType"]=application.zcore.functions.zso(ds, "CAR_TransactionType");
ts["CAR_UnitCount"]=application.zcore.functions.zso(ds, "CAR_UnitCount");
ts["InternetAutomatedValuationDisplayYN"]=application.zcore.functions.zso(ds, "InternetAutomatedValuationDisplayYN");
ts["InternetConsumerCommentYN"]=application.zcore.functions.zso(ds, "InternetConsumerCommentYN");
ts["YearBuilt"]=application.zcore.functions.zso(ds, "YearBuilt");
ts["ZoningDescription"]=application.zcore.functions.zso(ds, "ZoningDescription");
ts["CAR_CCRSubjectTo"]=application.zcore.functions.zso(ds, "CAR_CCRSubjectTo");
ts["OccupantType"]=application.zcore.functions.zso(ds, "OccupantType");
ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");

// PropertyComl
ts["@odata.id"]=application.zcore.functions.zso(ds, "@odata.id");
ts["AccessCode"]=application.zcore.functions.zso(ds, "AccessCode");
ts["BathroomsTotalInteger"]=application.zcore.functions.zso(ds, "BathroomsTotalInteger");
ts["CAR_BuyerAgentSaleYN"]=application.zcore.functions.zso(ds, "CAR_BuyerAgentSaleYN");
ts["CAR_CCRSubjectTo"]=application.zcore.functions.zso(ds, "CAR_CCRSubjectTo");
ts["CumulativeDaysOnMarket"]=application.zcore.functions.zso(ds, "CumulativeDaysOnMarket");
ts["City"]=application.zcore.functions.zso(ds, "City");
ts["Cooling"]=application.zcore.functions.zso(ds, "Cooling");
ts["Heating"]=application.zcore.functions.zso(ds, "Heating");
ts["CAR_CommercialLocationDescription"]=application.zcore.functions.zso(ds, "CAR_CommercialLocationDescription");
ts["CAR_ComplexName"]=application.zcore.functions.zso(ds, "CAR_ComplexName");
ts["CAR_ConstructionStatus"]=application.zcore.functions.zso(ds, "CAR_ConstructionStatus");
ts["CAR_ConstructionType"]=application.zcore.functions.zso(ds, "CAR_ConstructionType");
ts["CountyOrParish"]=application.zcore.functions.zso(ds, "CountyOrParish");
ts["CrossStreet"]=application.zcore.functions.zso(ds, "CrossStreet");
ts["CAR_DeedReference"]=application.zcore.functions.zso(ds, "CAR_DeedReference");
ts["Directions"]=application.zcore.functions.zso(ds, "Directions");
ts["CAR_Documents"]=application.zcore.functions.zso(ds, "CAR_Documents");
ts["DaysOnMarket"]=application.zcore.functions.zso(ds, "DaysOnMarket");
ts["Elevation"]=application.zcore.functions.zso(ds, "Elevation");
ts["CAR_FloodPlain"]=application.zcore.functions.zso(ds, "CAR_FloodPlain");
ts["Flooring"]=application.zcore.functions.zso(ds, "Flooring");
ts["FoundationDetails"]=application.zcore.functions.zso(ds, "FoundationDetails");
ts["CAR_GeocodeSource"]=application.zcore.functions.zso(ds, "CAR_GeocodeSource");
ts["CAR_HOASubjectTo"]=application.zcore.functions.zso(ds, "CAR_HOASubjectTo");
ts["Inclusions"]=application.zcore.functions.zso(ds, "Inclusions");
ts["CAR_InsideCityYN"]=application.zcore.functions.zso(ds, "CAR_InsideCityYN");
ts["Latitude"]=application.zcore.functions.zso(ds, "Latitude");
ts["ListAgentKey"]=application.zcore.functions.zso(ds, "ListAgentKey");
ts["ListAgentDirectPhone"]=application.zcore.functions.zso(ds, "ListAgentDirectPhone");
ts["ListAgentFullName"]=application.zcore.functions.zso(ds, "ListAgentFullName");
ts["ListAgentMlsId"]=application.zcore.functions.zso(ds, "ListAgentMlsId");
ts["ListAgentAOR"]=application.zcore.functions.zso(ds, "ListAgentAOR");
ts["ListingContractDate"]=application.zcore.functions.zso(ds, "ListingContractDate");
ts["ListingAgreement"]=application.zcore.functions.zso(ds, "ListingAgreement");
ts["ListOfficeKey"]=application.zcore.functions.zso(ds, "ListOfficeKey");
ts["ListOfficeMlsId"]=application.zcore.functions.zso(ds, "ListOfficeMlsId");
ts["ListOfficeName"]=application.zcore.functions.zso(ds, "ListOfficeName");
ts["ListOfficePhone"]=application.zcore.functions.zso(ds, "ListOfficePhone");
ts["ListPrice"]=application.zcore.functions.zso(ds, "ListPrice");
ts["Longitude"]=application.zcore.functions.zso(ds, "Longitude");
ts["LotSizeArea"]=application.zcore.functions.zso(ds, "LotSizeArea");
ts["ListingKey"]=application.zcore.functions.zso(ds, "ListingKey");
ts["OriginatingSystemModificationTimestamp"]=application.zcore.functions.zso(ds, "OriginatingSystemModificationTimestamp");
ts["OriginatingSystemName"]=application.zcore.functions.zso(ds, "OriginatingSystemName");
ts["ListingId"]=application.zcore.functions.zso(ds, "ListingId");
ts["NewConstructionYN"]=application.zcore.functions.zso(ds, "NewConstructionYN");
ts["NumberOfBuildings"]=application.zcore.functions.zso(ds, "NumberOfBuildings");
ts["OccupantType"]=application.zcore.functions.zso(ds, "OccupantType");
ts["CAR_OwnerAgentYN"]=application.zcore.functions.zso(ds, "CAR_OwnerAgentYN");
ts["ParcelNumber"]=application.zcore.functions.zso(ds, "ParcelNumber");
ts["InternetAddressDisplayYN"]=application.zcore.functions.zso(ds, "InternetAddressDisplayYN");
ts["InternetEntireListingDisplayYN"]=application.zcore.functions.zso(ds, "InternetEntireListingDisplayYN");
ts["CAR_PermitSyndicationYN"]=application.zcore.functions.zso(ds, "CAR_PermitSyndicationYN");
ts["PhotosCount"]=application.zcore.functions.zso(ds, "PhotosCount");
ts["PhotosChangeTimestamp"]=application.zcore.functions.zso(ds, "PhotosChangeTimestamp");
ts["PostalCode"]=application.zcore.functions.zso(ds, "PostalCode");
ts["StructureType"]=application.zcore.functions.zso(ds, "StructureType");
ts["PropertySubType"]=application.zcore.functions.zso(ds, "PropertySubType");
ts["CAR_PropertySubTypeSecondary"]=application.zcore.functions.zso(ds, "CAR_PropertySubTypeSecondary");
ts["PropertyType"]=application.zcore.functions.zso(ds, "PropertyType");
ts["PublicRemarks"]=application.zcore.functions.zso(ds, "PublicRemarks");
ts["CAR_RailService"]=application.zcore.functions.zso(ds, "CAR_RailService");
ts["CAR_RATIO_CurrentPrice_By_Acre"]=application.zcore.functions.zso(ds, "CAR_RATIO_CurrentPrice_By_Acre");
ts["CAR_RATIO_ListPrice_By_TaxAmount"]=application.zcore.functions.zso(ds, "CAR_RATIO_ListPrice_By_TaxAmount");
ts["CAR_Restrictions"]=application.zcore.functions.zso(ds, "CAR_Restrictions");
ts["CAR_RestrictionsDescription"]=application.zcore.functions.zso(ds, "CAR_RestrictionsDescription");
ts["RoadResponsibility"]=application.zcore.functions.zso(ds, "RoadResponsibility");
ts["Roof"]=application.zcore.functions.zso(ds, "Roof");
ts["ShowingContactPhone"]=application.zcore.functions.zso(ds, "ShowingContactPhone");
ts["SpecialListingConditions"]=application.zcore.functions.zso(ds, "SpecialListingConditions");
ts["CAR_SqFtAvailableMaximum"]=application.zcore.functions.zso(ds, "CAR_SqFtAvailableMaximum");
ts["CAR_SqFtAvailableMinimum"]=application.zcore.functions.zso(ds, "CAR_SqFtAvailableMinimum");
ts["CAR_SqFtMaximumLease"]=application.zcore.functions.zso(ds, "CAR_SqFtMaximumLease");
ts["CAR_SqFtMinimumLease"]=application.zcore.functions.zso(ds, "CAR_SqFtMinimumLease");
ts["LivingArea"]=application.zcore.functions.zso(ds, "LivingArea");
ts["BuildingAreaTotal"]=application.zcore.functions.zso(ds, "BuildingAreaTotal");
ts["StateOrProvince"]=application.zcore.functions.zso(ds, "StateOrProvince");
ts["StandardStatus"]=application.zcore.functions.zso(ds, "StandardStatus");
ts["CAR_StatusContractualSearchDate"]=application.zcore.functions.zso(ds, "CAR_StatusContractualSearchDate");
ts["StoriesTotal"]=application.zcore.functions.zso(ds, "StoriesTotal");
ts["StreetDirPrefix"]=application.zcore.functions.zso(ds, "StreetDirPrefix");
ts["StreetName"]=application.zcore.functions.zso(ds, "StreetName");
ts["StreetNumber"]=application.zcore.functions.zso(ds, "StreetNumber");
ts["StreetNumberNumeric"]=application.zcore.functions.zso(ds, "StreetNumberNumeric");
ts["StreetSuffix"]=application.zcore.functions.zso(ds, "StreetSuffix");
ts["CAR_StreetViewParam"]=application.zcore.functions.zso(ds, "CAR_StreetViewParam");
ts["CAR_SuitableUse"]=application.zcore.functions.zso(ds, "CAR_SuitableUse");
ts["CAR_Table"]=application.zcore.functions.zso(ds, "CAR_Table");
ts["TaxAnnualAmount"]=application.zcore.functions.zso(ds, "TaxAnnualAmount");
ts["CAR_TransactionType"]=application.zcore.functions.zso(ds, "CAR_TransactionType");
ts["CAR_UnitCount"]=application.zcore.functions.zso(ds, "CAR_UnitCount");
ts["UnitNumber"]=application.zcore.functions.zso(ds, "UnitNumber");
ts["Utilities"]=application.zcore.functions.zso(ds, "Utilities");
ts["InternetAutomatedValuationDisplayYN"]=application.zcore.functions.zso(ds, "InternetAutomatedValuationDisplayYN");
ts["InternetConsumerCommentYN"]=application.zcore.functions.zso(ds, "InternetConsumerCommentYN");
ts["YearBuilt"]=application.zcore.functions.zso(ds, "YearBuilt");
ts["CAR_ZoningNCM"]=application.zcore.functions.zso(ds, "CAR_ZoningNCM");
ts["ZoningDescription"]=application.zcore.functions.zso(ds, "ZoningDescription");
ts["MlgCanView"]=application.zcore.functions.zso(ds, "MlgCanView");
ts["ModificationTimestamp"]=application.zcore.functions.zso(ds, "ModificationTimestamp");

return ts;
	</cfscript>
</cffunction>

<cffunction name="getDebugValue" localmode="modern" access="public">
	<cfscript>
	js={
			filecontent:'{"@odata.context":"https://api.mlsgrid.com/$metadata##PropertyResi","@odata.count":6744,"value":[{"@odata.id":"https://api.mlsgrid.com/PropertyResi(''CAR3554719'')","BathroomsFull":5,"BathroomsHalf":1,"BathroomsTotalInteger":6,"BedroomsTotal":5,"BuilderName":"Lennar","CAR_BuyerAgentSaleYN":"0","CumulativeDaysOnMarket":107,"City":"Charlotte","CAR_ConstructionType":"Site Built","CountyOrParish":"Mecklenburg","CAR_DeedReference":"15822-440","DaysOnMarket":107,"RoadSurfaceType":"Concrete","ElementarySchool":"Palisades Park","Appliances":"Gas Cooktop,Dishwasher,Double Oven,Dryer,Microwave,Washer","ConstructionMaterials":"Brick Partial,Fiber Cement","FireplaceFeatures":"Family Room","FireplaceYN":false,"FoundationDetails":"Basement","CAR_GeocodeSource":"Manual","Heating":"Heat Pump,Heat Pump","HighSchool":"Olympic","AssociationName":"Braesal Management","AssociationPhone":"704-847-3507","CAR_HOASubjectTo":"Required","CAR_HOASubjectToDues":"Mandatory","Latitude":35.070471,"LaundryFeatures":"Upper Level","ListAgentKey":"CAR59636720","ListAgentDirectPhone":"980-298-0767","ListAgentFullName":"Ehren Hutchings","ListAgentMlsId":"CAR69988","ListAgentAOR":"Charlotte Regional Realtor Association","ListingContractDate":"2019-10-04","ListingAgreement":"Exclusive Right To Sell","ListOfficeKey":"CAR46002214","ListOfficeMlsId":"CAR10141","ListOfficeName":"OfferPad Brokerage LLC","ListOfficePhone":"480-636-9175","ListPrice":459900,"Longitude":-81.017402,"LotSizeArea":0.45,"ListingKey":"CAR63599851","OriginatingSystemModificationTimestamp":"2020-01-20T00:10:36.000Z","MiddleOrJuniorSchool":"Southwest","OriginatingSystemName":"carolina","ListingId":"CAR3554719","Model":"Westley F","NewConstructionYN":false,"CAR_OwnerAgentYN":"0","ParcelNumber":"21726160","ParkingFeatures":"Garage - 3 Car","PendingTimestamp":"2020-01-19T05:00:00.000Z","InternetAddressDisplayYN":true,"InternetEntireListingDisplayYN":true,"CAR_PermitSyndicationYN":"1","PhotosCount":37,"PhotosChangeTimestamp":"2019-11-21T15:09:06.559Z","PostalCode":"28278","PostalCodePlus4":"8884","StructureType":"3 Story/Basement","PropertySubType":"Single Family Residence","PropertyType":"Residential","CAR_ProposedSpecialAssessmentYN":"0","PublicRemarks":"Welcome home to this brick stunner! This open floor plan makes entertaining easy. The chef of the home will appreciate the large center island, double ovens, gas cook top and miles of gorgeous granite. Each room offers gorgeous views of your tree lined yard, expansive deck and custom fire pit. Did I mention the large additional master on the first floor? The second story offers a large bonus room, additional spacious bedrooms and baths plus another master bedroom with a spa like en suite. The third floor offers a guest suite with its own private bathroom too. Let''s not forget the unfinished basement that can be customized to your needs. The possibilities are endless! Come check out this beauty.","CAR_RATIO_CurrentPrice_By_Acre":"1022000.00","CAR_RATIO_ListPrice_By_TaxAmount":"1.20078","RoadResponsibility":"Public Maintained Road","BuyerAgentKey":"CAR43201026","BuyerAgentAOR":"Charlotte Regional Realtor Association","BuyerAgentMlsId":"CAR54158","BuyerOfficeKey":"CAR1005675","BuyerOfficeMlsId":"CAR9147","Sewer":"Public Sewer","ShowingContactPhone":"800-746-9464","SpecialListingConditions":"None","CAR_SqFtAdditional":"0","BelowGradeFinishedArea":0,"CAR_SqFtLower":"0","CAR_SqFtMain":"1685","CAR_SqFtThird":"617","LivingArea":3904,"BuildingAreaTotal":3904,"CAR_SqFtUnheatedBasement":"1646","CAR_SqFtUnheatedLower":"0","CAR_SqFtUnheatedMain":"617","CAR_SqFtUnheatedThird":"0","CAR_SqFtUnheatedTotal":"2263","CAR_SqFtUnheatedUpper":"0","CAR_SqFtUpper":"1602","StateOrProvince":"NC","StandardStatus":"Pending","CAR_StatusContractualSearchDate":"2020-01-19","StreetName":"Alydar Commons","StreetNumber":"16822","StreetNumberNumeric":16822,"StreetSuffix":"Lane","CAR_StreetViewParam":"1$35.070471$-81.017402$274.74$13.33$1.00$2Xyslcujvmd-C_rQTCnEVA","SubdivisionName":"Southern Trace","CAR_Table":"Listing - Residential","TaxAnnualAmount":383000,"CAR_UnitCount":"0","UnitNumber":"67","InternetAutomatedValuationDisplayYN":true,"InternetConsumerCommentYN":true,"WaterSource":"Public","CAR_WaterHeater":"Gas","YearBuilt":2016,"ZoningDescription":"R3","CAR_MainLevelGarageYN":"1","OccupantType":"Owner","CAR_ProjectedClosingDate":"2020-02-11","CAR_CCRSubjectTo":"Undiscovered","RoomType":"Bathroom 1,Bathroom 2,Breakfast Room,Dining Room,Family Room,Kitchen,Living Room,Master Bedroom,Bathroom 3,Bathroom 4,Bathroom 5,Laundry,Loft,Master Bedroom 2,Bedroom 1,Bedroom 2,Play Room,Bedroom 3,None","CAR_room1_BathsFull":"1","CAR_room1_BathsHalf":"1","CAR_room1_BedsTotal":"1","RoomBathroom1Level":"Main","RoomBathroom2Level":"Main","RoomBreakfastRoomLevel":"Main","RoomDiningRoomLevel":"Main","RoomFamilyRoomLevel":"Main","RoomKitchenLevel":"Main","RoomLivingRoomLevel":"Main","RoomMasterBedroomLevel":"Main","CAR_room1_RoomType":"Bathroom(s),Breakfast,Dining Room,Family Room,Kitchen,Living Room,2nd Master","CAR_room2_BathsFull":"3","CAR_room2_BathsHalf":"0","CAR_room2_BedsTotal":"3","RoomBathroom3Level":"Upper","RoomBathroom4Level":"Upper","RoomBathroom5Level":"Upper","RoomLaundryLevel":"Upper","RoomLoftLevel":"Upper","RoomMasterBedroom2Level":"Upper","RoomBedroom1Level":"Upper","RoomBedroom2Level":"Upper","CAR_room2_RoomType":"Bathroom(s),Bedroom(s),Laundry,Loft,Master Bedroom","CAR_room3_BathsFull":"1","CAR_room3_BathsHalf":"0","CAR_room3_BedsTotal":"1","RoomBathroom6Level":"Third","RoomLoft2Level":"Third","RoomPlayRoomLevel":"Third","RoomBedroom3Level":"Third","CAR_room3_RoomType":"Bathroom(s),Bedroom(s),Loft,Play Room","CAR_room4_BathsFull":"0","CAR_room4_BathsHalf":"0","CAR_room4_BedsTotal":"0","RoomNoneLevel":"Basement","CAR_room4_RoomType":"None","MlgCanView":true,"ModificationTimestamp":"2020-01-20T00:11:06.405Z","CloseDate":null,"ExpirationDate":null,"OffMarketDate":null,"PurchaseContractDate":null}],"@odata.nextLink":"https://api.mlsgrid.com/PropertyResi?$filter=ModificationTimestamp%2520gt%25202020-01-20T00%3A00%3A00.00Z&$top=1&$skip=1&$count=true"}',
 		
 		status_code:200
 	};
 	return js;
	</cfscript>
</cffunction>

<cffunction name="getFieldNames" localmode="modern" access="public">
	<cfscript>
		ts={};
		ts["AboveGradeFinishedArea"]="Above Grade Finished Area";
ts["AccessCode"]="Access Code";
ts["AccessibilityFeatures"]="Accessibility Features";
ts["Appliances"]="Appliances";
ts["ArchitecturalStyle"]="Architectural Style";
ts["AssociationFee"]="Association Fee";
ts["AssociationFeeFrequency"]="Association Fee Frequency";
ts["AssociationName"]="Association Name";
ts["AssociationPhone"]="Association Phone";
ts["AvailabilityDate"]="Availability Date";
ts["BathroomsFull"]="Bathrooms Full";
ts["BathroomsHalf"]="Bathrooms Half";
ts["BathroomsTotalInteger"]="Bathrooms Total Integer";
ts["BedroomsTotal"]="Bedrooms Total";
ts["BelowGradeFinishedArea"]="Below Grade Finished Area";
ts["BuilderName"]="Builder Name";
ts["BuildingAreaTotal"]="Building Area Total";
ts["CAR_CanSubdivideYN"]="Can Subdivide YN";
ts["CAR_CommercialLocationDescription"]="Commercial Location Description";
ts["CAR_ComplexName"]="Complex Name";
ts["CAR_ConstructionStatus"]="Construction Status";
ts["CAR_ConstructionType"]="Construction Type";
ts["CAR_CorrectionCount"]="Correction Count";
ts["CAR_DeedReference"]="Deed Reference";
ts["CAR_FloodPlain"]="Flood Plain";
ts["CAR_GeocodeSource"]="Geocode Source";
ts["CAR_HOASubjectTo"]="HOA Subject To";
ts["CAR_HOASubjectToDues"]="HOA Subject To Dues";
ts["CAR_InsideCityYN"]="Inside City YN";
ts["CAR_MainLevelGarageYN"]="Main Level Garage YN";
ts["CAR_OutBuildingsYN"]="Out Buildings YN";
ts["CAR_PermitSyndicationYN"]="Permit Syndication YN";
ts["CAR_PlatBookSlide"]="Plat Book Slide";
ts["CAR_PlatReferenceSectionPages"]="Plat Reference Section Pages";
ts["CAR_Porch"]="Porch";
ts["CAR_ProjectedClosingDate"]="Projected Closing Date";
ts["CAR_PropertySubTypeSecondary"]="Property Sub Type Secondary";
ts["CAR_ProposedSpecialAssessmentYN"]="Proposed Special Assessment YN";
ts["CAR_RailService"]="Rail Service";
ts["CAR_RATIO_CurrentPrice_By_Acre"]="RATIO Current Price By Acre";
ts["CAR_RATIO_ListPrice_By_TaxAmount"]="RATIO ListPrice By TaxAmount";
ts["CAR_Restrictions"]="Restrictions";
ts["CAR_RestrictionsDescription"]="Restrictions Description";
ts["CAR_room1_BathsFull"]="Room 1 Baths Full";
ts["CAR_room1_BathsHalf"]="Room 1 Baths Half";
ts["CAR_room1_BedsTotal"]="Room 1 Beds Total";
ts["CAR_room1_RoomType"]="Room 1 Room Type";
ts["CAR_room2_BathsFull"]="Room 2 Baths Full";
ts["CAR_room2_BathsHalf"]="Room 2 Baths Half";
ts["CAR_room2_BedsTotal"]="Room 2 Beds Total";
ts["CAR_room2_RoomType"]="Room 2 Room Type";
ts["CAR_room3_BathsFull"]="Room 3 Baths Full";
ts["CAR_room3_BathsHalf"]="Room 3 Baths Half";
ts["CAR_room3_BedsTotal"]="Room 3 Beds Total";
ts["CAR_room3_RoomType"]="Room 3 Room Type";
ts["CAR_room4_BathsFull"]="Room 4 Baths Full";
ts["CAR_room4_BathsHalf"]="Room 4 Baths Half";
ts["CAR_room4_BedsTotal"]="Room 4 Beds Total";
ts["CAR_room4_RoomType"]="Room 4 Room Type";
ts["CAR_SqFtAdditional"]="SqFt Additional";
ts["CAR_SqFtAvailableMaximum"]="SqFt Available Maximum";
ts["CAR_SqFtAvailableMinimum"]="SqFt Available Minimum";
ts["CAR_SqFtBuildingMinimum"]="SqFt Building Minimum";
ts["CAR_SqFtGarage"]="SqFt Garage";
ts["CAR_SqFtLower"]="SqFt Lower";
ts["CAR_SqFtMain"]="SqFt Main";
ts["CAR_SqFtMaximumLease"]="SqFt Maximum Lease";
ts["CAR_SqFtMinimumLease"]="SqFt Minimum Lease";
ts["CAR_SqFtThird"]="SqFt Third";
ts["CAR_SqFtUnheatedBasement"]="SqFt Unheated Basement";
ts["CAR_SqFtUnheatedLower"]="SqFt Unheated Lower";
ts["CAR_SqFtUnheatedMain"]="SqFt Unheated Main";
ts["CAR_SqFtUnheatedThird"]="SqFt Unheated Third";
ts["CAR_SqFtUnheatedTotal"]="SqFt Unheated Total";
ts["CAR_SqFtUnheatedUpper"]="SqFt Unheated Upper";
ts["CAR_SqFtUpper"]="SqFt Upper";
ts["CAR_StatusContractualSearchDate"]="Status Contractual Search Date";
ts["CAR_StreetViewParam"]="Street View Param";
ts["CAR_SuitableUse"]="Suitable Use";
ts["CAR_Table"]="Table";
ts["CAR_TransactionType"]="Transaction Type";
ts["CAR_unit1_BathsFull"]="Unit 1 Baths Full";
ts["CAR_unit1_BathsHalf"]="Unit 1 Baths Half";
ts["CAR_unit1_SqFtTotal"]="Unit 1 SqFt Total";
ts["CAR_unit1_UnitRooms"]="Unit 1 Unit Rooms";
ts["CAR_unit2_BathsFull"]="Unit 2 Baths Full";
ts["CAR_unit2_BathsHalf"]="Unit 2 Baths Half";
ts["CAR_unit2_SqFtTotal"]="Unit 2 SqFt Total";
ts["CAR_unit2_UnitRooms"]="Unit 2 Unit Rooms";
ts["CAR_UnitCount"]="Unit Count";
ts["CAR_WaterHeater"]="Water Heater";
ts["CAR_ZoningNCM"]="Zoning NCM";
ts["City"]="City";
ts["CloseDate"]="Close Date";
ts["ClosePrice"]="Close Price";
ts["CommunityFeatures"]="Community Features";
ts["ConstructionMaterials"]="Construction Materials";
ts["Cooling"]="Cooling";
ts["CountyOrParish"]="County Or Parish";
ts["CrossStreet"]="Cross Street";
ts["CumulativeDaysOnMarket"]="Cumulative Days On Market";
ts["DaysOnMarket"]="Days On Market";
ts["Directions"]="Directions";
ts["ElementarySchool"]="Elementary School";
ts["Elevation"]="Elevation";
ts["EntryLevel"]="EntryLevel";
ts["ExteriorFeatures"]="ExteriorFeatures";
ts["FireplaceFeatures"]="FireplaceFeatures";
ts["FireplaceYN"]="Fireplace YN";
ts["Flooring"]="Flooring";
ts["FoundationDetails"]="Foundation Details";
ts["Furnished"]="Furnished";
ts["HabitableResidenceYN"]="Habitable Residence YN";
ts["Heating"]="Heating";
ts["HighSchool"]="High School";
ts["Inclusions"]="Inclusions";
ts["InteriorFeatures"]="Interior Features";
ts["LaundryFeatures"]="Laundry Features";
ts["ListPrice"]="List Price";
ts["LivingArea"]="Living Area";
ts["LotFeatures"]="Lot Features";
ts["LotSizeArea"]="Lot Size Area";
ts["LotSizeDimensions"]="Lot Size Dimensions";
ts["MiddleOrJuniorSchool"]="Middle Or Junior School";
ts["Model"]="Model";
ts["NewConstructionYN"]="New Construction YN";
ts["NumberOfBuildings"]="Number Of Buildings";
ts["NumberOfUnitsTotal"]="Number Of Units Total";
ts["OccupantType"]="Occupant Type";
ts["ParcelNumber"]="Parcel Number";
ts["ParkingFeatures"]="Parking Features";
ts["PetsAllowed"]="Pets Allowed";
ts["PhotosCount"]="Photos Count";
ts["PostalCode"]="Postal Code";
ts["PostalCodePlus4"]="Postal Code Plus 4";
ts["PropertySubType"]="Property Sub Type";
ts["PropertyType"]="Property Type";
ts["PublicRemarks"]="Public Remarks";
ts["RoadResponsibility"]="Road Responsibility";
ts["RoadSurfaceType"]="Road SurfaceType";
ts["Roof"]="Roof";
ts["RoomBathroom1Level"]="Room Bathroom 1 Level";
ts["RoomBathroom2Level"]="Room Bathroom 2 Level";
ts["RoomBathroom3Level"]="Room Bathroom 3 Level";
ts["RoomBathroom4Level"]="Room Bathroom 4 Level";
ts["RoomBathroom5Level"]="Room Bathroom 5 Level";
ts["RoomBathroom6Level"]="Room Bathroom 6 Level";
ts["RoomBedroom1Level"]="Room Bedroom 1 Level";
ts["RoomBedroom2Level"]="Room Bedroom 2 Level";
ts["RoomBedroom3Level"]="Room Bedroom 3 Level";
ts["RoomBreakfastRoomLevel"]="Room Breakfast Room Level";
ts["RoomDiningRoomLevel"]="Room Dining Room Level";
ts["RoomFamilyRoomLevel"]="Room Family Room Level";
ts["RoomKitchenLevel"]="Room Kitchen Level";
ts["RoomLaundryLevel"]="Room Laundry Level";
ts["RoomLivingRoomLevel"]="Room Living Room Level";
ts["RoomLoft2Level"]="Room Loft 2 Level";
ts["RoomLoftLevel"]="Room Loft Level";
ts["RoomMasterBedroom2Level"]="Room Master Bedroom 2 Level";
ts["RoomMasterBedroomLevel"]="Room Master Bedroom Level";
ts["RoomNoneLevel"]="Room None Level";
ts["RoomPantryLevel"]="Room Pantry Level";
ts["RoomPlayRoomLevel"]="Room Play Room Level";
ts["RoomType"]="Room Type";
ts["Sewer"]="Sewer";
ts["SpecialListingConditions"]="Special Listing Conditions";
ts["StandardStatus"]="Standard Status";
ts["StateOrProvince"]="State Or Province";
ts["StoriesTotal"]="Stories Total";
ts["StreetDirPrefix"]="Street Dir Prefix";
ts["StreetDirSuffix"]="Street Dir Suffix";
ts["StreetName"]="Street Name";
ts["StreetNumber"]="Street Number";
ts["StreetNumberNumeric"]="Street Number Numeric";
ts["StreetSuffix"]="Street Suffix";
ts["StructureType"]="Structure Type";
ts["SubdivisionName"]="Subdivision Name";
ts["TaxAnnualAmount"]="TaxAnnual Amount";
ts["TenantPays"]="Tenant Pays";
ts["UnitNumber"]="Unit Number";
ts["UnitType1BedsTotal"]="Unit Type 1 Beds Total";
ts["UnitType2BedsTotal"]="Unit Type 2 Beds Total";
ts["Utilities"]="Utilities";
ts["VirtualTourURLUnbranded"]="Virtual Tour URL Unbranded";
ts["WaterBodyName"]="Water Body Name";
ts["WaterfrontFeatures"]="Waterfront Features";
ts["WaterSource"]="Water Source";
ts["YearBuilt"]="Year Built";
ts["ZoningDescription"]="Zoning Description";


return ts;
</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>