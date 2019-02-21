<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
<cfscript>
this.retsVersion="1.7";

this.mls_id=28;
if(request.zos.istestserver){
	variables.hqPhotoPath="#request.zos.sharedPath#mls-images/28/";
}else{
	variables.hqPhotoPath="#request.zos.sharedPath#mls-images/28/";
} 
this.caseSensitiveLookup=true;
this.useRetsFieldName="system";
this.arrTypeLoop=[];//["A","B","C","D", "F", "G"];
this.arrColumns=listtoarray("additionalrooms,age,agedescription,agentstatus,annualrent,appliances,applicationfeeamount,apxbuildingsqft,asisconditionyn,assessedvaluation,assessmentdesc,associationfee,associationfeecovers,associationfeeperiod,avmyn,bathspartial,bathstotal,bedroom1length,bedroom1width,bedroom2length,bedroom2width,bedroom3length,bedroom3width,bedroom4length,bedroom4width,bedrooms,betweenus1andriver,blogyn,businessname,ceilingheight,city,clearedynp,closedate,closeprice,colistingagentid,colistingagentname,colistingofficeid,colistingofficename,commentaryyn,commercialclass,communityover55yn,complexname,complexunits,confidentiallistingyn,construction,constructionmaterial,cooling,county,currentlyleasedyn,dateavailable,datechange,datecontingency,dateestimatedcompletion,datenewlisting,datewithdrawn,daysonmarket,diningroomlength,diningroomwidth,direction,directions,dishwashers,displayflagaddress,displayflaglisting,documentsanddisclosures,doorfaces,dryers,electric,electricalexpense,electricitymeters,electricmeters,employees,equipmentandappliances,estimatevalueyn,exteriorfeatures,exteriorfinish,familyroomlength,familyroomwidth,floor,floornumber,floors,floorsperunit,floridaroomlength,floridaroomwidth,freestandingyn,furnishedyn,futurelanduse,garage,garageandcarstorage,garagecarportspaces,gasexpense,gasmeters,generictextfield1,generictextfield2,grossincome,groundfloorbedroomyn,groundsexpense,heating,heatingandac,hoayn,idx,insidefeatures,insuranceexpense,interiorfeatures,kitchenlength,kitchenwidth,landstyle,landtype,latitude,laundrylength,laundrywidth,leaseagent,leaseboard,leasefirm,leaseoffice,leaseoption,leaseterms,legaldescription,listagentagentid,listdate,listingagentid,listingagentname,listingarea,listingboardid,listingdetail,listingfirmid,listingid,listingofficeid,listingstatus,listingtype,listofficeaffilliation,listofficeofficeid,listprice,livingarea,livingroomlength,livingroomwidth,loadingdocks,locationdescription,longitude,lotsize,lotsizearea,maintenanceexpense,maintfeecovers,managementexpense,masterbath,maxratedoccupancy,microwaves,middleschool,miscellaneous,miscellaneousn,modificationtimestamp,monthlyrent,nearhighwayyn,netincome,nodrivebeachyn,officeidx,officephone,officesqft,officestatus,openhouseaid,openhousedt,openhouserem,openhousetm,openhouseyn,operatingexpense,originallistingfirmname,otheravailblefeatures,otherexpense,otherroom1length,otherroom1name,otherroom1width,otherroom2length,otherroom2name,otherroom2width,overheaddoornumber,ownername,parcelnumber,parkingtotal,petfeeamount,petsynr,photocode,photocount,photoframenumber,photomodificationtimestamp,photorollnumber,pool,pooldescription,poolfeatures,poolpresent,porchlength,porchwidth,possession,postalcode,previouslistprice,pricesqft,propertysubtype,propertytype,publicremarks,ranges,refrigerators,rentalamount,rentalpropertytype,rentalyn,rentincludes,rentlow,roadfrontage,roof,saleagentagentid,saleagentname,saleofficename,saleofficeofficeid,securityandmisc,securitydepositamount,sewer,specialcontingenciesapplyyn,splityn,sqftlivingarea,sqfttotal,stateorprovince,statuschangedate,stories,streetname,streetnameidx,streetnoidx,streetnumber,style,stylefeatures,subdivision,surveyyn,tangibletaxes,taxamount,taxyear,totalrooms,totalunits,totsqftarea,type,typestreet,unit1baths,unit1halfbaths,unit1monthlyrent,unit1rooms,unit1sqft,unit2baths,unit2halfbaths,unit2monthlyrent,unit2rooms,unit2sqft,unit3baths,unit3halfbaths,unit3monthlyrent,unit3rooms,unit3sqft,unit4baths,unit4halfbaths,unit4monthlyrent,unit4rooms,unit4sqft,unitnumber,utlitiesandfuel,virtualtoururl,virtualtouryn,washerdryerhookupsonly,washers,water,waterandsewer,waterfeatures,watermainsize,watermeters,waterother,watersewerexpense,watertype,windows,windowsandwindowtrtmnt,windowtrtmnt,yearbuilt,zoning",",");
this.arrFieldLookupFields=[];
this.mls_provider="rets28";
variables.resourceStruct=structnew();
variables.resourceStruct["property"]=structnew();
variables.resourceStruct["property"].resource="property";
variables.resourceStruct["property"].id="ListingId";

this.emptyStruct=structnew();
variables.resourceStruct["office"]=structnew();
variables.resourceStruct["office"].resource="office";
variables.resourceStruct["office"].id="OfficeUID";
variables.resourceStruct["agent"]=structnew();
variables.resourceStruct["agent"].resource="agent";
variables.resourceStruct["agent"].id="AgentUID";
 
variables.tableLookup=structnew(); 
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
	photoLocation="";
	for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
		if(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i] EQ "rets28_hireslocation"){
			photoLocation=arguments.ss.arrData[i];
			continue;
		}
		col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
		ts["rets28_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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
	ts["rets28_listprice"]=replace(ts["rets28_listprice"],",","","ALL");
	// need to clean this data - remove not in subdivision, 0 , etc.
	subdivision="";
	listing_subdivision="";
	if(application.zcore.functions.zso(ts, "rets28_subdivision") NEQ ""){
		subdivision=ts["rets28_subdivision"]; 
		listing_subdivision=this.getRetsValue("property", ts["rets28_subdivision"], "subdivision", subdivision);
	}else if(application.zcore.functions.zso(ts, "rets28_communityname") NEQ ""){
		subdivision=ts["rets28_communityname"];  
		listing_subdivision=this.getRetsValue("property", ts["rets28_communityname"], "communityname", subdivision);
	}
	
	if(listing_subdivision NEQ ""){
		if(findnocase(","&listing_subdivision&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			listing_subdivision="";
		}else{
			listing_subdivision=application.zcore.functions.zFirstLetterCaps(listing_subdivision);
		}
	}  
	
	if(ts['rets28_propertytype'] EQ 2){
		ts['rets28_propertysubtype']='V';
	}

	this.price=ts["rets28_listprice"];
	listing_price=ts["rets28_listprice"];
	cityName="";
	cid=0;
	ts['city']=this.getRetsValue("property", ts["rets28_propertysubtype"], "city", ts['rets28_city']);
	ts['StateOrProvince']=this.getRetsValue("property", ts["rets28_propertysubtype"], "StateOrProvince",ts['rets28_StateOrProvince']); 
	if(structkeyexists(request.zos.listing.cityStruct, ts["city"]&"|"&ts["StateOrProvince"])){
		cid=request.zos.listing.cityStruct[ts["city"]&"|"&ts["StateOrProvince"]];
	}
	if(cid EQ 0 and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct, ts['rets28_postalcode'])){
		cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct[ts['rets28_postalcode']];
		ts["city"]=listgetat(cityName,1,"|");
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["StateOrProvince"])){
			cid=request.zos.listing.cityStruct[cityName&"|"&ts["StateOrProvince"]];
		}
	} 
	listing_county=this.listingLookupNewId("county",ts['rets28_county']);
	
	listing_parking="";//this.listingLookupNewId("listing_parking",ts['rets28_Parking']);
 
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
	if(application.zcore.functions.zso(ts, "rets28_UseAndPossibleUse") NEQ ""){
		arrT=listtoarray(ts["rets28_UseAndPossibleUse"]);
	}else if(application.zcore.functions.zso(ts, "rets28_LandStyle") NEQ ""){
		arrT=listtoarray(ts["rets28_LandType"]);
	}else if(application.zcore.functions.zso(ts, "rets28_RentalPropertyType") NEQ ""){
		arrT=listtoarray(ts["rets28_RentalPropertyType"]);
	}else if(application.zcore.functions.zso(ts, "rets28_CommercialClass") NEQ ""){
		arrT=listtoarray(ts["rets28_CommercialClass"]); 
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
	
	listing_type_id=this.listingLookupNewId("listing_type",ts['rets28_propertysubtype']);

	ad=ts['rets28_streetnumber'];
	if(ad NEQ 0){
		address="#ad# ";
	}else{
		address="";	
	} 
	if(structkeyexists(ts, 'direction')){
		direction=this.getRetsValue("property", ts["rets28_propertysubtype"], "direction",ts['rets28_direction']);
		address&=application.zcore.functions.zfirstlettercaps(direction&" "&ts['rets28_streetname']);
	}else{
		address&=application.zcore.functions.zfirstlettercaps(ts['rets28_streetname']);
	}
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
	
	if(ts['Address Unit Number'] NEQ ''){
		address&=" Unit: "&ts["Address Unit Number"];
	} 
	
	/*s2=structnew();
	liststatus=this.getRetsValue("property", ts["rets28_propertysubtype"], 'ListingStatus', ts["rets28_ListingStatus"]);
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
	openhouse=application.zcore.functions.zso(ts,"rets28_openhouseyn", false, "n");
	if(openhouse EQ ""){
		openhouse="n";
	}
	if(openhouse EQ "y"){
		//openhouseaid,openhousedt,openhouserem,openhousetm,openhouseyn
	}
*/

	listing_style="";
	uns={};
	tmp=application.zcore.functions.zso(ts,"rets28_WaterFeatures");
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("view",arrT[i]);
			//LookupMulti1B 

			//LookupMulti4B

			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	listing_view=arraytolist(arrT3);

	tmp=application.zcore.functions.zso(ts, "rets28_WATERTYPE");
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
	 

	tmp=application.zcore.functions.zso(ts, "rets28_PoolPresent");
	listing_pool="0";
	if(tmp EQ "Y"){ 
		listing_pool="1";
	} 
	tempTableLookup={};
	tempTableLookup["D"]="BoatDock"; // Boat Dock
	tempTableLookup["E"]="CommercialRental"; // For Rent-Commercial
	tempTableLookup["F"]="ResidentialProperty"; //  Residential Factory Built
	tempTableLookup["C"]="CommercialProperty"; //  Commercial Sale
	tempTableLookup["L"]="ResidentialProperty"; //  Condotels
	tempTableLookup["N"]="ResidentialRental"; //  For Rent-Residential-Resort
	tempTableLookup["O"]="ResidentialProperty"; //  Condo
	tempTableLookup["I"]="ResidentialIncomeProperty"; //  Residential Income
	tempTableLookup["U"]="ResidentialProperty"; //  Single Unit of 2, 3, 4 plex
	tempTableLookup["T"]="ResidentialProperty"; //  Townhomes
	tempTableLookup["V"]="VacantLand"; //  Vacant Land
	tempTableLookup["P"]="ResidentialProperty"; //  Co-Op
	tempTableLookup["R"]="ResidentialProperty"; //  Single Family Site Built

	propertyTable=tempTableLookup[ts['rets28_propertysubtype']];
  
	ts=this.convertRawDataToLookupValues(ts, propertyTable, '');
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
	if(application.zcore.functions.zso(ts, 'rets28_yearbuilt') EQ year(now())){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
	} 

	//if(ts["rets28_propertysubtype"] EQ "E" or ts["rets28_propertysubtype"] EQ "N"){
	if(ts["rets28_propertytype"] EQ "For Rent-Commercial" or ts["rets28_propertytype"] EQ "For Rent-Residential"){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true; 
	}else{
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
	} 

	arrListType=listToArray(application.zcore.functions.zso(ts, 'rets28_ListingDetail'), ',');
	for(i in arrListType){
		if(i EQ "REO or Bank Owned"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}else if(i EQ "Under Construction"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["pre construction"]]=true;
		}else if(i EQ "Preforeclosure/Short Sale"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}else if(i EQ "Auction"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["auction"]]=true;
		}else if(i EQ "Lease Option"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else if(i EQ ""){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}else if(i EQ ""){
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
	if(application.zcore.functions.zso(ts, 'rets28_LotSizeArea') NEQ ""){
		rs.listing_acreage=ts["rets28_LotSizeArea"]; 
	}
	rs.listing_id=arguments.ss.listing_id;
	if(structkeyexists(ts, 'rets28_BathsTotal')){
		rs.listing_baths=ts["rets28_BathsTotal"];
	}else{
		rs.listing_baths='';
	}
	rs.listing_halfbaths=application.zcore.functions.zso(ts, "rets28_BathsPartial");
	if(structkeyexists(ts, "rets28_bedrooms")){
		rs.listing_beds=ts["rets28_bedrooms"];
	}else{
		rs.listing_beds=0;
	}
	rs.listing_condoname="";
	rs.listing_city=cid;
	rs.listing_county=listing_county;
	rs.listing_frontage=","&listing_frontage&",";
	rs.listing_frontage_name="";
	rs.listing_price=ts["rets28_listprice"];
	rs.listing_status=","&listing_status&",";
	rs.listing_state=ts["rets28_StateOrProvince"];
	rs.listing_type_id=listing_type_id;
	rs.listing_sub_type_id=","&listing_sub_type_id&",";
	rs.listing_style=","&listing_style&",";
	rs.listing_view=","&listing_view&",";
	rs.listing_lot_square_feet="";

	rs.listing_square_feet=application.zcore.functions.zso(ts, "rets28_SqFtTotal");
 
	rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets28_LotSizeArea"); 


	rs.listing_subdivision=listing_subdivision;
	rs.listing_year_built=application.zcore.functions.zso(ts, "rets28_yearbuilt");
	if(rs.listing_year_built EQ ""){
		rs.listing_year_built=application.zcore.functions.zso(ts, "Year Built");
	}
	rs.listing_office=ts["rets28_ListOfficeOfficeID"];//OfficeUID"];
	rs.listing_agent=ts["rets28_ListAgentAgentID"];//AgentUID"]; 

	if(not structkeyexists(request, 'rets28officeLookup')){
		t2={};
		path="#request.zos.sharedPath#mls-data/"&this.mls_id&"/office.txt";
		f=application.zcore.functions.zReadFile(path);
		if(f EQ false){
			throw("Office file is missing for rets28");
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
		request.rets28officeLookup=t2;
	}
	if(structkeyexists(request.rets28officeLookup, rs.listing_office)){
		rs.listing_office_name=request.rets28officeLookup[rs.listing_office].name;
	}else{
		rs.listing_office_name='';
	}  
	rs.listing_latitude=curLat;
	rs.listing_longitude=curLong;
	rs.listing_pool=listing_pool;
	rs.listing_photocount=ts["rets28_PhotoCount"];
	rs.listing_coded_features="";
	rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
	rs.listing_primary="0";
	rs.listing_mls_id=arguments.ss.listing_mls_id;
	rs.listing_address=trim(address);
	rs.listing_zip=ts["rets28_postalcode"];
	rs.listing_condition="";
	rs.listing_parking=listing_parking;
	rs.listing_region="";
	rs.listing_tenure="";
	rs.listing_liststatus=listing_liststatus;
	rs.listing_data_remarks=ts["rets28_publicremarks"];
	rs.listing_data_address=trim(address);
	rs.listing_data_zip=trim(ts["rets28_postalcode"]);
	rs.listing_data_detailcache1=listing_data_detailcache1;
	rs.listing_data_detailcache2=listing_data_detailcache2;
	rs.listing_data_detailcache3=listing_data_detailcache3; 
	//if(ts["WATERTYPE"] NEQ ""){ 	writedump(rs);abort;	}

	rs.listing_track_sysid="";
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
	idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
	
	t44444=0;
	request.lastPhotoId=idx.listing_id;
	if(idx.listing_photocount EQ 0){
		idx["photo1"]='/z/a/listing/images/image-not-available.gif';
	}else{
		i=1;
		for(i=1;i LTE idx.listing_photocount;i++){
			fNameTemp1="28-"&idx.urlMlsPid&"-"&i&".jpeg";
			fNameTempMd51=lcase(hash(fNameTemp1, 'MD5'));
			idx["photo"&i]=request.zos.retsPhotoPath&'28/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/"&fNameTemp1;
		}
	}  
	agentStruct={};
	officeStruct={};
	if(not structkeyexists(application.zcore, 'rets28AgentStruct')){
		contents=application.zcore.functions.zReadFile(request.zos.sharedPath&"mls-data/28/agent.txt");
		if(contents NEQ false){
			contents=replace(contents, chr(13), "", "all");
			arrLine=listToArray(contents, chr(10));
			first=true;
			for(line in arrLine){
				if(first){
					arrColumn=listToArray(line, chr(9));
					first=false;
				}else{
					arrRow=listToArray(line, chr(9), true);
					ts={};
					for(i=1;i<=arraylen(arrRow);i++){
						ts["rets28_"&arrColumn[i]]=trim(arrRow[i]);
					}
					agentStruct[ts["rets28_AgentUID"]]=ts;
				}
			}
			application.zcore.rets28AgentStruct=agentStruct;
		}
	}else{
		agentStruct=application.zcore.rets28AgentStruct;
	}
	if(not structkeyexists(application.zcore, 'rets28OfficeStruct')){
		contents=application.zcore.functions.zReadFile(request.zos.sharedPath&"mls-data/28/office.txt");
		if(contents NEQ false){
			contents=replace(contents, chr(13), "", "all");
			arrLine=listToArray(contents, chr(10));
			first=true;
			for(line in arrLine){
				if(first){
					arrColumn=listToArray(line, chr(9));
					first=false;
				}else{
					arrRow=listToArray(line, chr(9), true);
					ts={};
					for(i=1;i<=arraylen(arrRow);i++){
						ts["rets28_"&arrColumn[i]]=trim(arrRow[i]);
					} 
					officeStruct[ts["rets28_OfficeUID"]]=ts; 
				}
			}
			application.zcore.rets28OfficeStruct=officeStruct;
		}
	}else{
		officeStruct=application.zcore.rets28OfficeStruct;
	}

	currentAgent={};
	if(structkeyexists(agentStruct, idx.rets28_listagentagentid)){
		currentAgent=agentStruct[idx.rets28_listagentagentid];
	}
	currentOffice={};
	if(structkeyexists(officeStruct, idx.rets28_listofficeofficeid)){
		currentOffice=officeStruct[idx.rets28_listofficeofficeid];
	} 
	idx["agentName"]="";
	idx["agentPhone"]="";
	idx["agentEmail"]=""; 
	// need the hashed version.

	agentFileName="#idx.rets28_listagentagentid#-1.jpeg";
	agentFileNameHash=lcase(hash(agentFileName, 'MD5'));
	filePath=request.zos.sharedPath&"mls-images/nsb-agent/"&left(agentFileNameHash,2)&"/"&mid(agentFileNameHash,3,1)&"/"&agentFileName;
	//filePath=request.zos.sharedPath&"mls-images/nsb-agent/#idx.rets28_listagentagentid#-1.jpeg";
	displayPath="/zretsphotos/nsb-agent/"&left(agentFileNameHash,2)&"/"&mid(agentFileNameHash,3,1)&"/"&agentFileName;;
	
	if(fileexists(filePath)){
		idx["agentPhoto"]=displayPath;
	}
	/*
	filePath=request.zos.sharedPath&"mls-images/temp/nsb-agent/nsb-office/#idx.rets28_listofficeofficeid#-1.jpeg";
	displayPath="/zretsphotos/temp/nsb-agent/nsb-office/#idx.rets28_listofficeofficeid#-1.jpeg";
	
	if(fileexists(filePath)){
		idx["officePhoto"]=displayPath;
	}*/
	if(structcount(currentAgent) NEQ 0){
		idx["agentName"]=currentAgent.rets28_firstname&" "&currentAgent.rets28_lastname;
		idx["agentPhone"]=currentAgent.rets28_cellphone;
		idx["agentEmail"]=currentAgent.rets28_email; 
	}
	idx["officeName"]=idx.listing_office_name;
	idx["officePhone"]="";
	idx["officeCity"]="";
	idx["officeAddress"]="";
	idx["officeZip"]="";
	idx["officeState"]="";
	idx["officeEmail"]="";
	if(structcount(currentOffice) NEQ 0){
		idx["officePhone"]=currentOffice.rets28_officephone;
		//idx["officeCity"]=currentOffice.rets28_city;
		//idx["officeAddress"]=currentOffice.rets28_streetaddress;
		//idx["officeZip"]=currentOffice.rets28_postalcode;
		//idx["officeState"]=currentOffice.rets28_stateorprovince;
		idx["officeEmail"]=currentOffice.rets28_email;
	} 
		
	idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets28_virtualtoururl");
	idx["zipcode"]=arguments.ss["listing_zip"];
	idx["maintfees"]=""; 
	if(isnumeric(application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_HOAMaintFees"))){
		idx["maintfees"]=application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_HOAMaintFees"); 
	}else if(isnumeric(application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_MaintenanceExpense"))){
		idx["maintfees"]=application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_MaintenanceExpense"); 
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
	<cfscript>
	request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
	fNameTemp1="28-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
	fNameTempMd51=lcase(hash(fNameTemp1, 'MD5'));
	return request.zos.retsPhotoPath&'28/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/"&fNameTemp1;
	
	</cfscript>
</cffunction>
	
<cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
	<cfscript> 
	var arrSQL=[]; 
	var arrError=[]; 
	var db=request.zos.queryObject; 
	var cityCreated=false; 

	fd={};
	fd["D"]="Boat Dock"; // Boat Dock
	fd["E"]="Commercial Rental"; // For Rent-Commercial
	fd["F"]="Residential Property"; //  Residential Factory Built
	fd["C"]="Commercial Property"; //  Commercial Sale
	fd["L"]="Residential Property"; //  Condotels
	fd["N"]="Residential Rental"; //  For Rent-Residential-Resort
	fd["O"]="Residential Property"; //  Condo
	fd["I"]="Residential Income Property"; //  Residential Income
	fd["U"]="Residential Property"; //  Single Unit of 2, 3, 4 plex
	fd["T"]="Residential Property"; //  Townhomes
	fd["V"]="Vacant Land"; //  Vacant Land
	fd["P"]="Residential Property"; //  Co-Op
	fd["R"]="Residential Property"; //  Single Family Site Built 
	typeStruct=fd;
 
	for(i in fd){
		i2=i;
		if(i2 NEQ ""){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
	}

	// county
	fd=this.getRETSValues("property", "","county");

	for(i in fd){
		i2=i;
		arrayappend(arrSQL,"('#this.mls_provider#','county','#application.zcore.functions.zescape(fd[i])#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
	}

	arrSubType=["UseAndPossibleUse","LandStyle","RentalPropertyType","CommercialClass"];
	for(i2=1;i2 LTE arraylen(arrSubType);i2++){
		fd=this.getRETSValues("property", "", arrSubType[i2]);
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		} 
	} 
 
	arrSubType=["WaterFeatures"];
	for(i2=1;i2 LTE arraylen(arrSubType);i2++){
		fd=this.getRETSValues("property", "", arrSubType[i2]); 
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
		} 
	}  

	arrSubType=["watertype"];
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