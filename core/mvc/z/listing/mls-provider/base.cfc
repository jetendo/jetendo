<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" output="no" returntype="any">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
		</cfscript>
</cffunction>

<cffunction name="checkIfLoaded" localmode="modern" output="no" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;
	if(isDefined('application.zcore.realestate') EQ false){
		application.zcore.realestate=structnew();
	}
	if(isDefined('application.zcore.realestate.search_criteria') EQ false){
		ts=structnew();
		db.sql="SELECT * FROM #db.table("search_criteria", request.zos.zcoreDatasource)#  WHERE 
		search_criteria_deleted = #db.param(0)#";
		qC=db.execute("qC"); 
		for(i=1;i LTE arraylen(qc.recordcount);i++){
			if(structkeyexists(ts,qc.mls_id[i]) EQ false){
				ts[qc.mls_id[i]]=structnew();	
			}
			if(structkeyexists(ts[qc.mls_id[i]],qc.search_criteria_type[i]) EQ false){
				ts[qc.mls_id[i]][qc.search_criteria_type[i]]=structnew();	
			}
			ts[qc.mls_id[i]][qc.search_criteria_type[i]][qc.search_criteria_value[i]]=qc.search_criteria_id[i];
		}
		application.zcore.realestate.search_criteria=ts;
	}
	</cfscript>
</cffunction>

<cffunction name="getCriteriaId" localmode="modern" output="no" returntype="any">
	<cfargument name="ts" type="struct" required="yes">
	<cfscript>
	var id=0;
	var t2=0;
	var qC=0;
	var db=request.zos.queryObject;
	checkIfLoaded();
	if(structkeyexists(application.zcore.realestate.search_criteria, ts.mls_id)){
		if(structkeyexists(application.zcore.realestate.search_criteria[ts.mls_id], ts.search_criteria_type)){	
			if(structkeyexists(application.zcore.realestate.search_criteria[ts.mls_id][ts.search_criteria_type],ts.value)){
				return application.zcore.realestate.search_criteria[ts.mls_id][ts.search_criteria_type][ts.value];
			}
		}
	}	
	db.sql="SELECT search_criteria_id FROM #db.table("search_criteria", request.zos.zcoreDatasource)# search_criteria 
	WHERE search_criteria_type=#db.param(ts.search_criteria_type)# and 
	search_criteria_value=#db.param(ts.value)# and 
	search_criteria_deleted = #db.param(0)# and
	mls_id=#db.param(ts.mls_id)#";
	qC=db.execute("qC"); 
	if(qC.recordcount EQ 0){
		t2=StructNew();
		t2.table="search_criteria";
		t2.datasource=mlsdb;
		t2.struct.search_criteria_type=ts.search_criteria_type;
		t2.struct.mls_id=ts.mls_id;
		t2.struct.search_criteria_value=ts.value;
		id=application.zcore.functions.zInsert(t2);
		if(id EQ false){
			application.zcore.template.fail("Failed to create search_criteria. SQL Failed: #request.zos.arrQueryLog[arraylen(request.zos.arrQueryLog)-1]#");
		}
	}else{
		id=qC.search_criteria_id;	
	}
	application.zcore.realestate.search_criteria[ts.mls_id][ts.search_criteria_type][ts.value]=id;
	return id;
	</cfscript>
</cffunction>


<cffunction name="setMLS" localmode="modern" output="no" returntype="any">
	<cfargument name="mls_id" type="numeric" required="yes">
	<cfscript>
	this.mls_id=arguments.mls_id;
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/#this.mls_id#/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/#this.mls_id#/";
	}
	</cfscript>
</cffunction>

<cffunction name="getListingTypeWithCode" localmode="modern" output="no" returntype="struct">
	<cfargument name="code" type="string" required="yes">
	<cfscript>
	var ts=0;
	if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.propertyTypeCode, arguments.code)){
			return request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.propertyType[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.propertyTypeCode[arguments.code]];
	}else{
		ts=structnew();
		ts.code="0";
		ts.id="0";
		ts.name="Real Estate";
		ts.seo="Real Estate";
		return ts;	
	}
	</cfscript>
</cffunction>

<cffunction name="getListingTypeWithId" localmode="modern" output="no" returntype="struct">
	<cfargument name="listing_type_id" type="string" required="yes">
	<cfscript>
	var ts=0;
	if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.propertyType, arguments.listing_type_id)){
			return request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.propertyType[arguments.listing_type_id];
	}else{
		ts=structnew();
		ts.code="0";
		ts.id="0";
		ts.name="Real Estate";
		ts.seo="Real Estate";
		return ts;	
	}
	</cfscript>
</cffunction>

<cffunction name="baseGetDetails" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="row" type="numeric" required="no" default="#1#">
	<cfargument name="fulldetails" type="boolean" required="no" default="#false#">
	<cfscript>
	idx=arguments.ss;
	idx["listingHasMap"]=0;
	if(isnumeric(idx.listing_latitude) and isnumeric(idx.listing_longitude) and idx.listing_latitude NEQ '0' and idx.listing_longitude NEQ '0' and abs(idx.listing_latitude) LTE 180 and abs(idx.listing_longitude) LTE 180){
		idx["listingHasMap"]=1;
	}
	if(structkeyexists(request.zos.listing.cityNameStruct,idx.listing_city)){
		idx["cityName"]=request.zos.listing.cityNameStruct[idx.listing_city];
	}else{
		idx["cityName"]="";
	}
	if(idx.listing_square_feet NEQ 0 and idx.listing_price GTE 999){
		idx["pricepersqft"]=round(idx.listing_price/idx.listing_square_feet);
	}else if(idx.listing_lot_square_feet NEQ 0 and idx.listing_price GTE 999){
		idx["pricepersqft"]=round(idx.listing_price/idx.listing_lot_square_feet);
	}else{
		idx["pricepersqft"]="";	
	}
	if(structkeyexists(this,'sysidfield') and structkeyexists(idx, this.sysidfield)){
		idx["sysidfield"]=idx[this.sysidfield];
	}else{
		idx["sysidfield"]="";
	}
	if(structkeyexists(this,'sysidfield2') and structkeyexists(idx, this.sysidfield2)){
		idx["sysidfield2"]=idx[this.sysidfield2];
	}else{
		idx["sysidfield2"]="";
	}
	
	arrNewList=["liststatus","status","style","view","frontage","tenure","parking","region","condition"];
	for(i4=1;i4 LTE arraylen(arrNewList);i4++){
		argtype=arrNewList[i4];
		if(argtype EQ "status"){
			arglist=idx["listing_status"];
		}else{
			arglist=idx["listing_"&argtype];
		}
		argdelimiter=",";
		arrA=listtoarray(arglist, argdelimiter);
		arrB=[];
		tmp="";
		i=0;
		for(i=1;i LTE arraylen(arrA);i++){
			if(structkeyexists(request.zos.listing.listingLookupStruct, argtype) and structkeyexists(request.zos.listing.listingLookupStruct[argtype].value, arrA[i])){
				tmp=request.zos.listing.listingLookupStruct[argtype].value[arrA[i]];
				if(tmp NEQ ""){
					arrayappend(arrB, tmp);	
				}
			}
		}
		idx["listing"&arrNewList[i4]]=arraytolist(arrB,", ");
	}
	
	
	idx["listingPropertyType"]="Real Estate";
	if(idx.listing_type_id NEQ 0){
		idx["listingPropertyType"]=application.zcore.functions.zFirstLetterCaps(application.zcore.listingCom.listingLookupValue("listing_type",idx.listing_type_id));
	} 
	arrI=listtoarray(idx.listing_id,"-");
	idx.urlMlsId=application.zcore.listingCom.getURLIdForMLS(arrI[1]);
	if(arraylen(arrI) EQ 2){
		idx.urlMLSPId=arrI[2];
	}else{
		idx.urlMLSPId="";
	}
	return idx;
	</cfscript>
</cffunction>

<cffunction name="getCityName" localmode="modern" output="no" returntype="string">
	<cfargument name="listing_city_id" type="string" required="yes">
	<cfscript>    
	if(structkeyexists(request.zos.listing.cityNameStruct,arguments.listing_city_id)){
		return request.zos.listing.cityNameStruct[arguments.listing_city_id];
	}else{
		return "";	
	}
	</cfscript>
</cffunction>


<cffunction name="initImport" localmode="modern" output="no" returntype="any">
	<cfargument name="resource" type="string" required="yes">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	</cfscript>
</cffunction> 

<cffunction name="getImportFilePath" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var path=request.zos.sharedPath&"mls-data/"&arguments.ss.row.mls_id&"/"&arguments.ss.row.mls_file;
	if(fileexists(path)){
		return replace(path, request.zos.sharedPath, "");
	}else{
		return false;	
	}
	</cfscript>
</cffunction>

<cffunction name="baseGetLatLong" localmode="modern" output="no" returntype="any">
	<cfargument name="address" type="string" required="yes">
	<cfargument name="state" type="string" required="yes">
	<cfargument name="zip" type="string" required="yes">
	<cfargument name="listing_id" type="string" required="yes">
	<cfscript>
	// var db=request.zos.queryObject;
	// var rs=structnew();
	// rs.latitude="";
	// rs.longitude="";
	// rs.accuracy="";
	// Note: this table stores city name in listing_coordinates_address, but the feeds don't pass it into this function.
	// db.sql="SELECT * FROM #db.table("listing_coordinates", request.zos.zcoreDatasource)# listing_coordinates 
	// WHERE listing_id = #db.param(arguments.listing_id)# and 
	// listing_coordinates_zip = #db.param(arguments.zip)# and 
	// listing_coordinates_latitude<>#db.param('')# and 
	// listing_coordinates_status=#db.param('OK')# and 
	// listing_coordinates_accuracy=#db.param('ROOFTOP')# and 
	// listing_coordinates_deleted = #db.param(0)#";
	// //listing_coordinates_address = #db.param(arguments.address)# and 
	// qD=db.execute("qD");
	// if(qD.recordcount NEQ 0){
	// 	rs.latitude=qD.listing_coordinates_latitude;
	// 	rs.longitude=qD.listing_coordinates_longitude;
	// 	rs.accuracy=qD.listing_coordinates_accuracy;
	// }
	rs=application.zcore.functions.zGeocode(arguments.address&", "&arguments.state&" "&arguments.zip, true);
	if(rs.success){
		rs.accuracy="ROOFTOP"; // for legacy compatibility
	}else{
		// no coordinates found
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="baseInitImport" localmode="modern" output="no" returntype="any">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var i=0;
	var qP=0;
	var db=application.zcore.db.newQuery();
	var db2=request.zos.noVerifyQueryObject;
	var ts=structnew();
	var ts2=0;
	var orsql=0;
	var qlookup=0;
	ts.lookupStruct=StructNew();

	ts.lookupStruct.statusStr=structnew();    
	ts.lookupStruct.statusStr["for sale"]=1;
	ts.lookupStruct.statusStr["foreclosure"]=2;
	ts.lookupStruct.statusStr["short sale"]=3;
	ts.lookupStruct.statusStr["bank owned"]=4;
	ts.lookupStruct.statusStr["new construction"]=5;
	//ts.lookupStruct.statusStr["for lease"]=6;
	ts.lookupStruct.statusStr["for rent"]=7;
	ts.lookupStruct.statusStr["pre construction"]=8;
	ts.lookupStruct.statusStr["model home"]=9;
	ts.lookupStruct.statusStr["pre-foreclosure"]=10;
	ts.lookupStruct.statusStr["auction"]=11;
	ts.lookupStruct.statusStr["remodeled"]=12;
	ts.lookupStruct.statusStr["hud"]=13;
	ts.lookupStruct.statusStr["relo company"]=14;
	ts.lookupStruct.liststatusStr=structnew();    
	ts.lookupStruct.liststatusStr["active"]=1;
	ts.lookupStruct.liststatusStr["incomplete"]=2;
	ts.lookupStruct.liststatusStr["withdrawn"]=3;
	ts.lookupStruct.liststatusStr["active continue to show"]=4;
	ts.lookupStruct.liststatusStr["temporarily withdrawn"]=5;
	ts.lookupStruct.liststatusStr["incomplete"]=6;
	ts.lookupStruct.liststatusStr["pending"]=7;
	ts.lookupStruct.liststatusStr["expired"]=8;
	ts.lookupStruct.liststatusStr["sold"]=9;
	ts.lookupStruct.liststatusStr["expired continue to show"]=10;
	ts.lookupStruct.liststatusStr["expired pending"]=11;
	ts.lookupStruct.liststatusStr["leased"]=12;
	ts.lookupStruct.liststatusStr["lease option"]=13;
	ts.lookupStruct.liststatusStr["rented"]=14;
	ts.lookupStruct.liststatusStr["incoming"]=15;
	ts.lookupStruct.liststatusStr["contingent"]=16;
	ts.lookupStruct.liststatusStr["deleted"]=17;
	ts.lookupStruct.liststatusStr["cancelled"]=18;
	
	ts.lookupStruct.propertyTypeCode=structnew();
	ts.lookupStruct.propertyType=structnew();
	db.sql="SELECT * FROM #db.table("listing_type", request.zos.zcoreDatasource)# listing_type 
	WHERE mls_id_list LIKE #db.trustedSQL("'%,#this.mls_id#,%'")# and 
	listing_type_deleted = #db.param(0)#";
	qP=db.execute("qP"); 
	loop query="qP"{
		ts2=structnew();
		ts2.id=qP.listing_type_id;
		ts2.code=qP.listing_type_code;
		ts2.name=qP.listing_type_name;
		ts2.seo=qP.listing_type_seo;
		ts.lookupStruct.propertyType[qP.listing_type_id]=ts;
		ts.lookupStruct.propertyTypeCode[qP.listing_type_code]=qP.listing_type_id;
	}
	ts.listingLookupStruct=structnew();
	orsql=""; 
	db.sql="SELECT listing_lookup_value,listing_lookup_id,listing_lookup_type,listing_lookup_oldid  
	FROM #db.table("listing_lookup", request.zos.zcoreDatasource)# listing_lookup 
	WHERE (listing_lookup_mls_provider = #db.param(this.mls_provider)# and 
	listing_lookup_deleted = #db.param(0)#
	#db.trustedSQL(orsql)#) 
	ORDER BY listing_lookup_type";
	qLookup=db.execute("qLookup");
	ts.listingLookupStruct["status"]=structnew();
	ts.listingLookupStruct["status"].value=structnew();
	ts.listingLookupStruct["status"].id=structnew();
	for(i in ts.lookupStruct.statusStr){
		ts.listingLookupStruct["status"].value[ts.lookupStruct.statusStr[i]]=i;
		ts.listingLookupStruct["status"].id[i]=ts.lookupStruct.statusStr[i];
	}
	ts.listingLookupStruct["liststatus"]=structnew();
	ts.listingLookupStruct["liststatus"].value=structnew();
	ts.listingLookupStruct["liststatus"].id=structnew();
	for(i in ts.lookupStruct.liststatusStr){
		ts.listingLookupStruct["liststatus"].value[ts.lookupStruct.liststatusStr[i]]=i;
		ts.listingLookupStruct["liststatus"].id[i]=ts.lookupStruct.liststatusStr[i];
	}
	loop query="qLookup"{
		if(structkeyexists(ts.listingLookupStruct,qLookup.listing_lookup_type) EQ false){
			ts.listingLookupStruct[qLookup.listing_lookup_type]=structnew();
			ts.listingLookupStruct[qLookup.listing_lookup_type].value=structnew();
			ts.listingLookupStruct[qLookup.listing_lookup_type].id=structnew();
		}
		ts.listingLookupStruct[qLookup.listing_lookup_type].value[qLookup.listing_lookup_id]=qLookup.listing_lookup_value;
		ts.listingLookupStruct[qLookup.listing_lookup_type].id[qLookup.listing_lookup_oldid]=qLookup.listing_lookup_id;
	}
	structappend(arguments.sharedStruct, ts, true);
	</cfscript>
</cffunction>

<cffunction name="listingLookupNewId" localmode="modern" output="no" returntype="any">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="oldid" type="string" required="yes">
	<cfargument name="defaultValue" type="string" required="no" default="">
	<cfscript>
	arguments.oldid=replace(arguments.oldid,'"','','all');
	if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.listingLookupStruct,arguments.type) and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.listingLookupStruct[arguments.type].id,arguments.oldid)){
		return request.zos.listing.mlsStruct[this.mls_id].sharedStruct.listingLookupStruct[arguments.type].id[arguments.oldid];
	}else{
		return arguments.defaultValue;
	}
	</cfscript>
</cffunction>

<cffunction name="listingLookupValue" localmode="modern" output="no" returntype="any">
	<cfargument name="type" type="string" required="yes">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="defaultValue" type="string" required="no" default="">
	<cfscript>
        if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.listingLookupStruct,arguments.type) and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.listingLookupStruct[arguments.type].value,arguments.id)){
            return request.zos.listing.mlsStruct[this.mls_id].sharedStruct.listingLookupStruct[arguments.type].value[arguments.id];
        }else{
            return arguments.defaultValue;
        }
        </cfscript>
</cffunction>

<!--- 
	ts=structnew();
	ts.field=remarks;
	ts.yearbuiltfield=yearbuilt;
	ts.foreclosureField=foreclosure;
	mlsProviderCom.processRawStatus(ts);
	 --->
<cffunction name="processRawStatus" localmode="modern" output="no" returntype="struct">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var statusStruct=structnew();
	var ts=structnew();
	ts.field="";
	ts.yearbuiltfield="";
	ts.foreclosureField="";
	structappend(arguments.ss,ts,false);
	if(arguments.ss.foreclosureField NEQ ""){
		if(arguments.ss.foreclosureField EQ 1){
			statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
	}
	if(arguments.ss.field CONTAINS "remodeled"){
		statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["remodeled"]]=true;
	}
	if(arguments.ss.field CONTAINS "model home"){
		statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["model home"]]=true;
	}
	if(refindnocase("not ^.* bank owned", arguments.ss.field) EQ 0 and arguments.ss.field CONTAINS "bank owned"){
		statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
	}
	if(arguments.ss.field CONTAINS "new construction"){
		statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
	}
	if(arguments.ss.field CONTAINS "pre construction"){
		statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["pre construction"]]=true;
	}
	if(arguments.ss.field CONTAINS "auction" and arguments.ss.field DOES NOT CONTAIN "auction house"){
		statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["auction"]]=true;
	}
	if(arguments.ss.field CONTAINS " lease" or (arguments.ss.field CONTAINS "lease " and arguments.ss.field DOES NOT CONTAIN "elease" and arguments.ss.field DOES NOT CONTAIN "please")){
		statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
	}else if(arguments.ss.field DOES NOT CONTAIN "not for rent" and arguments.ss.field CONTAINS "for rent"){
		statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
	}else{
		statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
	}
	if(arguments.ss.yearbuiltfield GTE year(dateadd("m",-6,now())) and arguments.ss.yearbuiltfield LTE year(dateadd("m",6,now()))){
		statusStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
	}
	return statusStruct;
        </cfscript>
</cffunction> 


<cffunction name="makeListingImportDataReady" localmode="modern" access="remote">
	<cfscript> 
	</cfscript>
</cffunction>


<cffunction name="getNewCityId" localmode="modern" access="public">
	<cfargument name="cityMlsId" type="string" required="yes">
	<cfargument name="cityName" type="string" required="yes">
	<cfargument name="stateCode" type="string" required="yes">
	<cfscript>
	cityMlsId=arguments.cityMlsId;
	cityName=arguments.cityName;
	stateCode=arguments.stateCode;
	cid=0;
	if(cityName EQ "" or stateCode EQ ""){
		// can't create blank cities
		return cid;
	}
	db=request.zos.queryObject;
	if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&stateCode)){
		return request.zos.listing.cityStruct[cityName&"|"&stateCode];
	}else{  
		db.sql="select * from #db.table("city_rename", request.zos.zcoreDatasource)# city_rename 
		WHERE city_name =#db.param(cityName)# and 
		state_abbr=#db.param(stateCode)# and 
		city_rename_deleted = #db.param(0)#";
		qD2=db.execute("qD2");
		if(qD2.recordcount NEQ 0){
			cityName=qD2.city_renamed;
		}
		//arrayappend(arrC,application.zcore.functions.zescape(application.zcore.functions.zFirstLetterCaps(cityName)));
		 db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# city 
		WHERE city_name =#db.param(cityName)# and 
		state_abbr=#db.param(stateCode)# and 
		city_deleted = #db.param(0)#";
		qD=db.execute("qD"); 
		if(qD.recordcount EQ 0){ 
			db.sql="select	* from #db.table("zipcode", request.zos.zcoreDatasource)# zipcode 
			WHERE city_name =#db.param(cityName)# and 
			state_abbr=#db.param(stateCode)# and 
			zipcode_deleted = #db.param(0)#";
			qZ=db.execute("qZ");
			if(qZ.recordcount NEQ 0){
				db.sql="INSERT INTO #db.table("city", request.zos.zcoreDatasource)#  
				SET city_name=#db.param(application.zcore.functions.zfirstlettercaps(cityName))#, 
				state_abbr=#db.param(stateCode)#,
				country_code=#db.param('US')#, 
				city_mls_id=#db.param(cityMlsId)#, 
			 	city_deleted=#db.param(0)#,
				city_longitude=#db.param(qZ.zipcode_longitude)#, 
				city_latitude=#db.param(qZ.zipcode_latitude)#,
			 	city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
				rs=db.insert("q", "id"); 
				cid=rs.result; 
				request.zos.listing.cityStruct[cityName&"|"&stateCode]=cid;
				 db.sql="INSERT INTO #db.table("city_memory", request.zos.zcoreDatasource)#  
				 SET city_id=#db.param(rs.result)#, 
				 city_name=#db.param(application.zcore.functions.zfirstlettercaps(cityName))#, 
				 state_abbr=#db.param(stateCode)#,
				 country_code=#db.param('US')#, 
				 city_mls_id=#db.param(cityMlsId)#, 
			 	city_deleted=#db.param(0)#,
				 city_longitude=#db.param(qZ.zipcode_longitude)#, 
				 city_latitude=#db.param(qZ.zipcode_latitude)#,
			 	city_updated_datetime=#db.param(request.zos.mysqlnow)#  ";
				db.insert("q", "id");  
				request.newListingCitiesCreated=true; // need to run zipcode calculations
			}else{
				db.sql="INSERT INTO #db.table("city", request.zos.zcoreDatasource)#  
				SET city_name=#db.param(application.zcore.functions.zfirstlettercaps(cityName))#, 
				state_abbr=#db.param(stateCode)#,
				country_code=#db.param('US')#, 
				city_mls_id=#db.param(cityMlsId)#,
				 city_deleted=#db.param(0)#,
				 city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
				rs=db.insert("q", "id"); 
				cid=rs.result; 
				 db.sql="INSERT INTO #db.table("city_memory", request.zos.zcoreDatasource)#  
				 SET city_id=#db.param(rs.result)#, 
				 city_name=#db.param(application.zcore.functions.zfirstlettercaps(cityName))#, 
				 state_abbr=#db.param(stateCode)#,
				 country_code=#db.param('US')#, 
				 city_mls_id=#db.param(cityMlsId)#, 
			 	city_deleted=#db.param(0)#,
			 	city_updated_datetime=#db.param(request.zos.mysqlnow)#  ";
				rs=db.insert("q", "id"); 
				request.zos.listing.cityStruct[cityName&"|"&stateCode]=cid;
				request.newListingCitiesCreated=true; // need to run zipcode calculations
			}
		}else{
			cid=qD.city_id;
		}
		arrayClear(request.zos.arrQueryLog); 
	}
	return cid;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
