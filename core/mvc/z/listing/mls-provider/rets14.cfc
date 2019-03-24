<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic"><!--- roanoke is not active --->
<cfoutput>	<cfscript>
	this.mls_id=14;
	this.useRetsFieldName="long";
	this.mls_provider="rets14";
	variables.resourceStruct=structnew();
	variables.resourceStruct["property"]=structnew();
	variables.resourceStruct["property"].resource="property";
	variables.resourceStruct["property"].id="listingid";
	variables.resourceStruct["office"]=structnew();
	variables.resourceStruct["office"].resource="office";
	variables.resourceStruct["office"].id="officeid";
	variables.resourceStruct["agent"]=structnew();
	variables.resourceStruct["agent"].resource="activeagent";
	variables.resourceStruct["agent"].id="agentid";
	if(request.zos.istestserver){
		this.mlspath="#request.zos.sharedPath#mls-data/#this.mls_id#/";
	}else{
		this.mlspath="#request.zos.sharedPath#mls-data/#this.mls_id#/";
	}
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/14/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/14/";
	}
	</cfscript> 
    
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var rs5=0;
		var db=request.zos.queryObject;
		var r222=0;
		var rs=0;
		ts=structnew();
		columnIndex=structnew();
		
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.template.fail("#this.mls_provider#: This row was not long enough to contain all columns: <pre>"&arraytolist(arguments.arrRow,chr(10))&"</pre>");
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			if(arguments.ss.arrData[i] EQ '0'){
				arguments.ss.arrData[i]="";	
			}
			ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
		}
		listing_frontage="";
		listing_view="";
		listing_sub_type_id="";
		listing_acreage=application.zcore.functions.zso(ts,'rets14_TotalAcreage');
		listing_baths=application.zcore.functions.zso(ts,'rets14_TotalBths');
		listing_beds	=application.zcore.functions.zso(ts,'rets14_TotalBdrm');
		listing_city	=application.zcore.functions.zso(ts,'rets14_City');
		listing_data_zip	=application.zcore.functions.zso(ts,'rets14_ZipCode');
		listing_halfbaths	=application.zcore.functions.zso(ts,'rets14_TotalHBaths');
		listing_latitude	=application.zcore.functions.zso(ts,'rets14_GeoLat');
		listing_longitude	=application.zcore.functions.zso(ts,'rets14_GeoLon');
		listing_price	=application.zcore.functions.zso(ts,'rets14_ListPrice');
		listing_square_feet	=application.zcore.functions.zso(ts,'rets14_GrossBldgSQFT');
		if(listing_square_feet EQ ""){
			listing_square_feet	=application.zcore.functions.zso(ts,'rets14_TotalFnshdSqFt');
		}
		listing_state	=application.zcore.functions.zso(ts,'rets14_State/Province');
		listing_style	=application.zcore.functions.zso(ts,'rets14_Style');
		listing_subdivision	=application.zcore.functions.zso(ts,'rets14_Subdivision');
		listing_type_id	=application.zcore.functions.zso(ts,'rets14_ListingType');
		listing_year_built	=application.zcore.functions.zso(ts,'rets14_YearBuilt');

		listing_data_address=replace(application.zcore.functions.zso(ts,'rets14_StreetDirectionPfx')&" "&application.zcore.functions.zso(ts,'rets14_StreetDirectionSfx')&" "&application.zcore.functions.zso(ts,'rets14_StreetName')&" "&application.zcore.functions.zso(ts,'rets14_StreetNumber')&" "&application.zcore.functions.zso(ts,'rets14_StreetSuffix'),"  "," ","ALL");

		curLat='';
		curLong='';
		address=listing_data_address;
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts['rets14_stateorprovince'],ts['rets14_zip'], arguments.ss.listing_id);
			if(rs5.success){
				curLat=rs5.latitude;
				curLong=rs5.longitude;
			}
		}
		listing_data_address=address;
		listing_data_remarks=application.zcore.functions.zso(ts,'rets14_PublicRemarks');

		
		if(structkeyexists(ts, "rets14_subdivision")){
			if(findnocase(","&ts["rets14_subdivision"]&",", ",,n/a,na,") NEQ 0){
				ts["rets14_subdivision"]="";
			}else if(ts["rets14_subdivision"] NEQ ""){
				ts["rets14_subdivision"]=application.zcore.functions.zFirstLetterCaps(ts["rets14_subdivision"]);
			}
			
		}
		this.price=ts["rets14_listprice"];
		cityName="";
		cid=0;
		
		// need to clean this data - remove not in subdivision, 0 , etc.
		if(listing_city NEQ ""){
			db.sql="SELECT * FROM #db.table("city", request.zos.zcoreDatasource)# city 
			WHERE city_name = #db.param(listing_city)# and 
			state_abbr = #db.param(listing_state)# and 
			city_deleted = #db.param(0)#";
			qC=db.execute("qC"); 
			listing_city=qC.city_id;
			cid=listing_city;
			cityName=ts["rets14_city"];
		}
		listing_county=this.listingLookupNewId("county",application.zcore.functions.zso(ts,'rets14_area'));
		listing_type_id=this.listingLookupNewId("listing_type",application.zcore.functions.zso(ts,'rets14_propertytype'));
		rs=getListingTypeWithCode(ts["rets14_propertytype"]);
		//ts["rets14_propertytype"]=rs.id;
		
		ts2=structnew();
		ts2.field=application.zcore.functions.zso(ts,'rets14_publicremarks');
		ts2.yearbuiltfield=application.zcore.functions.zso(ts,'rets14_yearbuilt');
		ts2.foreclosureField="";
		s=this.processRawStatus(ts2);
		if(application.zcore.functions.zso(ts,'rets14_newconstructionyn') EQ "Y"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
		}
		if(application.zcore.functions.zso(ts,'rets14_saleorlease') EQ "Sale"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		listing_status=structkeylist(s,",");
		listing_style=this.listingLookupNewId("style",application.zcore.functions.zso(ts,'rets14_style'));
		
		
		
		dataCom=this.getRetsDataObject();
		listing_data_detailcache1=dataCom.getDetailCache1(ts);
		listing_data_detailcache2=dataCom.getDetailCache2(ts);
		listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage=listing_acreage;
		rs.listing_baths=listing_baths;
		rs.listing_halfbaths=application.zcore.functions.zso(ts,'rets14_halfbaths');
		rs.listing_beds=listing_beds;
		rs.listing_city=cid;
		rs.listing_county=listing_county;
		rs.listing_frontage=","&listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=listing_price;
		rs.listing_status=","&listing_status&",";
		rs.listing_state=listing_state;
		rs.listing_type_id=listing_type_id;
		rs.listing_sub_type_id=","&listing_sub_type_id&",";
		rs.listing_style=","&listing_style&",";
		rs.listing_view=","&listing_view&",";
		rs.listing_lot_square_feet="";
		rs.listing_square_feet=listing_square_feet;
		rs.listing_subdivision=listing_subdivision;
		rs.listing_year_built=listing_year_built;
		rs.listing_office=application.zcore.functions.zso(ts,'rets14_officeid');
		rs.listing_agent=application.zcore.functions.zso(ts,'rets14_agentid');
		rs.listing_latitude=listing_latitude;
		rs.listing_longitude=listing_longitude;
		rs.listing_pool='0';
		rs.listing_photocount="0";
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary='0';
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_address=trim(listing_data_address);
		rs.listing_zip=trim(application.zcore.functions.zso(ts,'rets14_zip'));
		rs.listing_condition="";
		rs.listing_parking="";
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus="1";
		rs.listing_data_remarks=application.zcore.functions.zso(ts,'rets14_publicremarks');
		rs.listing_data_address=trim(listing_data_address);
		rs.listing_data_zip=trim(application.zcore.functions.zso(ts,'rets14_zip'));
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
		var t2=0;
		var i10=0;
		var value=0;
		var n=0;
		var column=0;
		var arrV=0;
		var arrV2=0;
		var idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails);
		var ts=application.zcore.listingCom.parseListingId(arguments.ss.listing_id);
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		idx["features"]="";
		a2=listtoarray(trim(lcase(arguments.ss.columnlist)),',',false);
		
		for(i10=1;i10 LTE arraylen(a2);i10++){
			column=a2[i10];
			value=arguments.ss[column];
			idx[column]=value;
			if(value NEQ ""){
				fieldName=replacenocase(column,"rets14_","");
				if(left(column,8) NEQ 'listing_' and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup, fieldName)){
					arrV=listtoarray(trim(value),',',false);
					arrV2=arraynew(1);
					for(n=1;n LTE arraylen(arrV);n++){
						t2=replace(arrV[n]," ","","ALL");
						t1=this.getRETSValue("property", "",fieldName,t2);
						arrayappend(arrV2,t1);
					}
					value=arraytolist(arrV2,", ");
				}
				idx[column]=value;
			}else{
				idx[column]="";
			}
		}
		idx["photo1"]="";
		</cfscript><cfdirectory action="list" directory="#this.mlspath#images/" filter="Photo#ts.mls_pid#-*.jpeg" name="qD"><cfscript>
		idx["listing_photocount"]=qD.recordcount;
		request.lastPhotoId=listing_id;
		for(i=1;i LTE qD.recordcount;i++){
			if(fileexists("#this.mlspath#images/Photo#ts.mls_pid#-#i#.jpeg")){
				idx["photo#i#"]="/zmls/14/images/Photo#ts.mls_pid#-#i#.jpeg";
			}
		}
		idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets14_unbrandedvirtualtour");
		
		idx["virtualtoururl"]=replace(idx["virtualtoururl"],"htttp:","http:");
		if(find("http://",idx["virtualtoururl"]) EQ 0 and (find(".",idx["virtualtoururl"]) NEQ 0 and find("/",idx["virtualtoururl"]) NEQ 0)){
			idx["virtualtoururl"]&="http://"&idx["virtualtoururl"];
		}
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, "rets14_zipcode");
		idx["maintfees"]="";
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
		return "/zmls/14/images/Photo#arguments.mls_pid#-#arguments.num#.jpeg";
		</cfscript>
    </cffunction>
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var fd=0;
		var db=request.zos.queryObject;
		var arrError=[];
		var qD=0;
		var qS=0;
		var arrT=0;
		
		fd=structnew();
		fd["D"]="Farm";
		fd["C"]="Land";
		fd["B"]="Multi-Family";
		fd["A"]="Residential";
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		throw("listing table was deleted.  have to build list of counties a new way.");
		// qD was deleted
		arrD=listtoarray(qD.datalist);
		dS=structnew();
		for(i=1;i LTE arraylen(arrD);i++){
			arrT=listtoarray(arrD[i],"-");
			if(arraylen(arrT) GTE 2){
				dS[trim(arrD[i])]=trim(replacenocase(arrT[2],"county","","ALL"));
			}
		}
		for(i in dS){
			arrayappend(arrSQL,"('#this.mls_provider#','county','#dS[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>