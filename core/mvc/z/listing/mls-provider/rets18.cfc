<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic"><!--- ntreis is not active --->
<cfoutput>	<cfscript>
	this.retsVersion="1.7";
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/18/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/18/";
	}
	
	this.mls_id=18;
	this.useRetsFieldName="system";
	this.arrColumns=listtoarray("ACRES	ACRESBOTTOMLAND	ACRESCULTIVATED	ACRESIRRIGATED	ACRESPASTURE	ACRESPRICE	AGENTLIST	AGENTLIST_FULLNAME	AGENTSELL_FULLNAME	AGEXEMPTION	APPLIANCESYN	APPLICATIONFEE	APPRAISERNAME	APPROVALNUM	AREA	ASSOCFEE	ASSOCFEEINCLUDES	ASSOCFEEPAID	BARN1LENGTH	BARN1WIDTH	BARN2LENGTH	BARN2WIDTH	BARN3LENGTH	BARN3WIDTH	BARNDESC	BATHSFULL	BATHSFULLBASEMENT	BATHSFULLLEVEL1	BATHSFULLLEVEL2	BATHSFULLLEVEL3	BATHSHALF	BATHSHALFBASEMENT	BATHSHALFLEVEL1	BATHSHALFLEVEL2	BATHSHALFLEVEL3	BATHSTOTAL	BEDS	BLOCK	BUILDING	BUILDINGNUM	BUILDINGUSE	BUS1	BUS2	BUS3	BUS4	BUSINESSNAME	CAPRATE	CARPORTCAP	CEILINGHEIGHT	CITY	COMMONFEATURES	COMPD	COMPLEXNAME	CONSTRUCTION	COUNTY	COVEREDSPACESTOTAL	CROPPROGRAM	CROPS	DATEAVAIL	DEPOSITAMOUNT	DEPOSITPET	DEVELOPMENT	DIRECTIONS	DOCUMENTS	DOORSFREIGHT	EASEMENTS	ENERGY	EQUIPMENT	EXPENSEGROSS	EXPENSEINSURANCE	EXPENSETENANT	EXPENSETOTALINCLUDES	EXPIREDATELEASE	EXPPPVTDISPLAY	EXTERIOR	FEATURES	FENCE	FENCEDYARD	FILLACRES	FILLAREA	FILLBLOCK	FILLCITY	FILLCOUNTY	FILLLEGAL	FILLLOTDEPTH	FILLLOTFRONTAGE	FILLLOTNUM	FILLLOTSQFT	FILLMAP	FILLMAPBOOK	FILLMAPCOORD	FILLMAPPAGE	FILLSCHOOLDISTRICT	FILLSQFTTOTAL	FILLSTREETNUMDISPLAY	FILLSUBAREA	FILLSUBDIVISION	FILLTAXID	FILLTAXUNEXEMPT	FILLUNITNUM	FILLYEARBUILT	FILLZIPCODE	FINANCEPROPOSED	FIREPLACEDESC	FIREPLACES	FLOORS	FORLEASE	FORSALE	FOUNDATION	FRONTAGEFEET	FURNISHED	GARAGECAP	GARAGEDESC	GREENCERTIFICATION	GREENFEATURES	HANDICAP	HANDICAPYN	HEATSYSTEM	HOA	HOUSINGTYPE	INCEXPSOURCE	INCLUSIONS	INCOMEGROSS	INCOMEGROSSMULTIPLY	INCOMENETOPERATING	INTERIOR	INTERNETADDRYN	INTERNETDISPLAYYN	INTERNETLIST_ALL	LAKENAME	LANDLEASE	LEASELENGTH	LEASEMONTH	LEASERATEMAX	LEASERATEMIN	LEASEREQUIRED	LEASETERMS	LEASETYPE	LEGAL	LESSEEPAYS	LISTPRICE	LISTPRICELOW	LISTPRICEORIG	LISTPRICERANGE	LISTSTATUS	LISTSTATUSFLAG	LOTDESC	LOTDIM	LOTNUM	LOTSIZE	LOTSSOLDPKG	LOTSSOLDSEP	MAPBOOK	MAPCOORD	MAPPAGE	MISCELLANEOUS	MLSNUM	MODIFIED	MONEYREQUIRED	MUDDISTRICT	NONREFUNDPETFEE	NUMBARN1STALLS	NUMBARN2STALLS	NUMBARN3STALLS	NUMBARNS	NUMBUILDING	NUMCARS	NUMDAYS	NUMDININGAREAS	NUMLAKES	NUMLEASESPACES	NUMLIVINGAREAS	NUMLOTS	NUMPARKING	NUMPETS	NUMPONDS	NUMRESIDENCE	NUMSPACESLEASED	NUMSTOCKTANKS	NUMUNITS	NUMWATERMETERS	NUMWELLS	OCCUPANCYRATE	OFFICELIST	OFFICELIST_OFFICENAM1	OFFICESELL_OFFICENAM2	OPENHOUSEDATE	OPENHOUSETIME	OWNERPAYS	PARCELSMULTIPLE	PETFEE	PETS	PHOTOAERIALAVAIL	PHOTOCOUNT	PHOTODATE	PLANNEDDEVELOPMENT	POOLDESC	POOLYN	POSSESSION	PRESENTUSE	PROPERTYASSOCIATION	PROPOSEDUSE	PROPSUBTYPE	PROPSUBTYPEDISPLAY	PROPTYPE	RANCHNAME	RANCHTYPE	REMARKS	RESTRICTIONS	ROADASSESS	ROADFRONTAGE	ROADFRONTAGEDESC	ROOF	ROOMBED2LENGTH	ROOMBED2LEVEL	ROOMBED2WIDTH	ROOMBED3LENGTH	ROOMBED3LEVEL	ROOMBED3WIDTH	ROOMBED4LENGTH	ROOMBED4LEVEL	ROOMBED4WIDTH	ROOMBED5LENGTH	ROOMBED5LEVEL	ROOMBED5WIDTH	ROOMBEDBATHDESC	ROOMBREAKFASTLENGTH	ROOMBREAKFASTLEVEL	ROOMBREAKFASTWIDTH	ROOMDININGLENGTH	ROOMDININGLEVEL	ROOMDININGWIDTH	ROOMGARAGELENGTH	ROOMGARAGEWIDTH	ROOMKITCHENDESC	ROOMKITCHENLENGTH	ROOMKITCHENLEVEL	ROOMKITCHENWIDTH	ROOMLIVING1LENGTH	ROOMLIVING1LEVEL	ROOMLIVING1WIDTH	ROOMLIVING2LENGTH	ROOMLIVING2LEVEL	ROOMLIVING2WIDTH	ROOMLIVING3LENGTH	ROOMLIVING3LEVEL	ROOMLIVING3WIDTH	ROOMMASTERBEDLENGTH	ROOMMASTERBEDLEVEL	ROOMMASTERBEDWIDTH	ROOMOTHER	ROOMOTHER1LENGTH	ROOMOTHER1LEVEL	ROOMOTHER1WIDTH	ROOMOTHER2LENGTH	ROOMOTHER2LEVEL	ROOMOTHER2WIDTH	ROOMSTUDYLENGTH	ROOMSTUDYLEVEL	ROOMSTUDYWIDTH	ROOMUTILDESC	ROOMUTILITYLENGTH	ROOMUTILITYLEVEL	ROOMUTILITYWIDTH	SCHOOLDISTRICT	SCHOOLNAME1	SCHOOLNAME2	SCHOOLNAME3	SCHOOLNAME4	SCHOOLTYPE1	SCHOOLTYPE2	SCHOOLTYPE3	SCHOOLTYPE4	SECURITY	SECURITYDESC	SHOWING	SOILTYPE	SPECIALNOTES	SQFTBUILDING	SQFTGROSS	SQFTGRPRICE	SQFTLAND	SQFTLEASABLE	SQFTLOT	SQFTLOTPRICE	SQFTPRICE	SQFTSOURCE	SQFTSOURCELAND	SQFTTOTAL	STATE	STORIES	STORIESBLDG	STREETDIR	STREETDIRSUFFIX	STREETNAME	STREETNUM	STREETNUMDISPLAY	STREETTYPE	STYLE	SUBAREA	SUBDIVIDE	SUBDIVIDED	SUBDIVISION	SURFACERIGHTS	TAXID	TAXUNEXEMPT	TENANCY	TOPOGRAPHY	UID	UIDPRP	UNIT1BATHSFULL	UNIT1BATHSHALF	UNIT1BEDS	UNIT1DININGAREALENGTH	UNIT1DININGAREAWIDTH	UNIT1KITCHENLENGTH	UNIT1KITCHENWIDTH	UNIT1LEASE	UNIT1LIVINGAREALENGTH	UNIT1LIVINGAREAWIDTH	UNIT1MASTERBEDLENGTH	UNIT1MASTERBEDWIDTH	UNIT1SQFT	UNIT1UNITS	UNIT2BATHSFULL	UNIT2BATHSHALF	UNIT2BEDS	UNIT2DININGAREALENGTH	UNIT2DININGAREAWIDTH	UNIT2KITCHENLENGTH	UNIT2KITCHENWIDTH	UNIT2LEASE	UNIT2LIVINGAREALENGTH	UNIT2LIVINGAREAWIDTH	UNIT2MASTERBEDLENGTH	UNIT2MASTERBEDWIDTH	UNIT2SQFT	UNIT2UNITS	UNIT3BATHSFULL	UNIT3BATHSHALF	UNIT3BEDS	UNIT3DININGAREALENGTH	UNIT3DININGAREAWIDTH	UNIT3KITCHENLENGTH	UNIT3KITCHENWIDTH	UNIT3LEASE	UNIT3LIVINGAREALENGTH	UNIT3LIVINGAREAWIDTH	UNIT3MASTERBEDLENGTH	UNIT3MASTERBEDWIDTH	UNIT3SQFT	UNIT3UNITS	UNIT4BATHSFULL	UNIT4BATHSHALF	UNIT4BEDS	UNIT4DININGAREALENGTH	UNIT4DININGAREAWIDTH	UNIT4KITCHENLENGTH	UNIT4KITCHENWIDTH	UNIT4LEASE	UNIT4LIVINGAREALENGTH	UNIT4LIVINGAREAWIDTH	UNIT4MASTERBEDLENGTH	UNIT4MASTERBEDWIDTH	UNIT4SQFT	UNIT4UNITS	UNITFLOORNUM	UNITNUM	UTILITIES	UTILITIESOTHER	VOWAVMYN	VOWCOMMYN	WALLS	YEARBUILT	YEARBUILTDESC	ZIPCODE	ZONING	ZONINGINFO	ZONINGMULTI",chr(9));
	this.mls_provider="rets18";
	resourceStruct=structnew();
	resourceStruct["property"]=structnew();
	resourceStruct["property"].resource="property";
	resourceStruct["property"].id="mlsnum";
	resourceStruct["office"]=structnew();
	resourceStruct["office"].resource="office";
	resourceStruct["office"].id="uid";
	resourceStruct["agent"]=structnew();
	resourceStruct["agent"].resource="agent";
	resourceStruct["agent"].id="uid";
	resourceStruct["media"]=structnew();
	resourceStruct["media"].id="tableuid";
	resourceStruct["media"].resource="media";
	</cfscript> 
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var db=request.zos.queryObject;
		var columnIndex=structnew(); 
		var ts=structnew(); 
		/*
		
		wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '18-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '18-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '18-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '18-%'; 
		
		*/
		
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.template.fail("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			if(arguments.ss.arrData[i] EQ '0'){
				arguments.ss.arrData[i]="";	
			}
			ts[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=application.zcore.functions.zescape(arguments.ss.arrData[i]);
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
		}
		if(structkeyexists(ts, "rets18_subdivision")){
			if(findnocase(","&ts["rets18_subdivision"]&",", ",,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["rets18_subdivision"]="";
			}else if(ts["rets18_subdivision"] NEQ ""){
				ts["rets18_subdivision"]=application.zcore.functions.zFirstLetterCaps(ts["rets18_subdivision"]);
			}
			if(ts["rets18_subdivision"] NEQ ""){
				sub=this.getRETSValue("property", "","subdivision",ts["rets18_subdivision"]);//," ","","ALL"));
				if(sub NEQ ""){
					ts["rets18_subdivision"]=sub;
				}
			}
		}
		this.price=ts["rets18_listprice"];
		cityName="";
		cid=0;
		if(structkeyexists(request.zos.listing.cityStruct, ts["rets18_city"]&"|TX")){
			cid=request.zos.listing.cityStruct[ts["rets18_city"]&"|TX"];
		}
		local.listing_county=this.listingLookupNewId("county",application.zcore.functions.zso(ts, 'rets18_county'));
		
		local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type",application.zcore.functions.zso(ts, 'rets18_propsubtype'));
		local.listing_type_id=this.listingLookupNewId("listing_type",application.zcore.functions.zso(ts, 'rets18_proptype'));
		rs=getListingTypeWithCode(ts["rets18_proptype"]);
		//ts["rets18_proptype"]=rs.id;
		ad=application.zcore.functions.zso(ts, 'rets18_street_num');
		if(ad NEQ 0){
			address="#ad# ";
		}else{
			address="";	
		}
		address&=application.zcore.functions.zfirstlettercaps(application.zcore.functions.zso(ts, 'rets18_street_name'));
		curLat='';
		curLong='';
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,application.zcore.functions.zso(ts, 'rets18_state'),application.zcore.functions.zso(ts, 'rets18_zipcode'), arguments.ss.listing_id);
			if(rs5.success){
				curLat=rs5.latitude;
				curLong=rs5.longitude;
			}
		}
		if(application.zcore.functions.zso(ts, 'rets18_unit_num') NEQ ''){
			address&=" Unit: "&ts["rets18_unit_num"];	
		}
		
		
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=application.zcore.functions.zso(ts, 'rets18_yearbuilt');
		ts2.foreclosureField="";
		
		s=this.processRawStatus(ts2);
		arrT3=[];
		local.listing_status=structkeylist(s,",");
		tmp=application.zcore.functions.zso(ts, 'rets18_style');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("style",arrT[i]);
				if(tmp NEQ ""){
					arrayappend(arrT3,tmp);
				}
			}
		}
		local.listing_view='';
		local.listing_style=arraytolist(arrT3);
		
		// view & frontage
		arrT2=[];
		arrT3=[];
		
		tmp=application.zcore.functions.zso(ts, 'rets18_lotdesc');
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
		

		local.listing_pool=0;
		if(application.zcore.functions.zso(ts, 'rets18_POOLYN') EQ "Y"){
			local.listing_pool=1;	
		}
		
		idx=ts;
		for(i10 in idx){
			column=i10;
			value=idx[i10];
			if(value NEQ ""){
				fieldName=replacenocase(column,"rets18_","");
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
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage=application.zcore.functions.zso(ts, 'rets18_acres');
		rs.listing_baths=application.zcore.functions.zso(ts, 'rets18_bathsfull');
		rs.listing_halfbaths=application.zcore.functions.zso(ts, 'rets18_bathshalf');
		rs.listing_beds=application.zcore.functions.zso(ts, 'rets18_beds');
		rs.listing_city=cid;
		rs.listing_county=local.listing_county;
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=application.zcore.functions.zso(ts, 'rets18_listprice');
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=application.zcore.functions.zso(ts, 'rets18_state');
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet=application.zcore.functions.zso(ts, 'rets18_sqftland');
		rs.listing_square_feet=application.zcore.functions.zso(ts, 'rets18_sqfttotal');
		rs.listing_subdivision=application.zcore.functions.zso(ts, 'rets18_subdivision');
		rs.listing_year_built=application.zcore.functions.zso(ts, 'rets18_yearbuilt');
		rs.listing_office=application.zcore.functions.zso(ts, 'rets18_officelist');

		throw("need to find which field is office");
		rs.listing_office_name="";
		rs.listing_agent=application.zcore.functions.zso(ts, 'rets18_agentlist');
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=application.zcore.functions.zso(ts, 'rets18_photocount');
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="0";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_condoname="";
		rs.listing_address=trim(address);
		rs.listing_zip=trim(application.zcore.functions.zso(ts, 'rets18_zipcode'));
		rs.listing_condition="";
		rs.listing_parking="";
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus="1";
		rs.listing_data_remarks=application.zcore.functions.zso(ts, 'rets18_remarks');
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(application.zcore.functions.zso(ts, 'rets18_zipcode'));
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
		var idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails);
		idx["features"]="";
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		request.lastPhotoId=listing_id;
		if(idx.listing_photocount EQ 0){
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
		}else{
			i=1;
			firstpic=1;
			db.sql="SELECT rets18_mediasource FROM #db.table("rets18_media", request.zos.zcoreDatasource)# rets18_media 
			where rets18_mediatype=#db.param('pic')# and 
			rets18_tableuid=#db.param(idx["rets18_uid"])# ";
			qPic=db.execute("qPic"); 
			if(qPic.recordcount NEQ 0){
				firstpic=replacenocase(replacenocase(listgetat(qpic.rets18_mediasource,2,"-"),".jpg",""),".jpeg","");
			}
			for(i=1;i LTE idx.listing_photocount;i++){
				idx["photo"&i]='http://ntreispictures.marketlinx.com/MediaDisplay/'&right(idx["rets18_uid"],2)&"/HR"&idx["rets18_uid"]&"-"&firstpic+(i-1)&".jpg";
				firstpic++;
				if(firstpic GT idx.listing_photocount){
					break;	
				}
			}
		}
		oid1="0";
		idx["agentName"]="";
		idx["agentPhone"]="";
		idx["agentEmail"]="";
		idx["officeName"]=idx.listing_office_name;
		idx["officePhone"]="";
		idx["officeCity"]="";
		idx["officeAddress"]="";
		idx["officeZip"]="";
		idx["officeState"]="";
		idx["officeEmail"]=""; 
		// virtual tour is in media table.
		db.sql="SELECT * FROM #db.table("rets18_media", request.zos.zcoreDatasource)# rets18_media 
		where rets18_mediatype=#db.param('vt')# and 
		rets18_tableuid=#db.param(idx["rets18_uid"])# ";
		qVT=db.execute("qVT"); 
		if(qVT.recordcount NEQ 0 and qVT.rets18_mediasource NEQ ""){
			idx["virtualtoururl"]="http://"&qVT.rets18_mediasource;
		}else{
			idx["virtualtoururl"]="";
		}
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, "rets18_zipcode");
		idx["maintfees"]=application.zcore.functions.zso(arguments.ss, "rets18_assocfee");
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
        <cfargument name="sysid" type="numeric" required="no" default="0">
    	<cfscript>
		var qId=0;
		var photo="";
		var qpic=0;
		var newnum=0;
		var db=request.zos.queryObject;
		application.zcore.template.fail("ntreis getphoto queries not optimized like the other rets servers");
		if(arguments.sysid EQ 0){
			db.sql="select rets18_media.rets18_mediasource, listing_track_sysid
			from #db.table("listing_track", request.zos.zcoreDatasource)#, 
			#db.table("rets18_media", request.zos.zcoreDatasource)# rets18_media 
			WHERE rets18_mediatype=#db.param('pic')# and 
			rets18_media.rets18_tableuid = listing_track_sysid and 
			listing_id=#db.param('18-#arguments.mls_pid#')# 
			limit #db.param(0)#,#db.param(1)#";
			qId=db.execute("qId"); 
			if(qId.recordcount NEQ 0){
				arguments.sysid=qId.rets18_uid;
				newnum=replacenocase(replacenocase(listgetat(qId.rets18_mediasource,2,"-"),".jpg",""),".jpeg","");
				if(arguments.num LT newnum){
					arguments.num=newnum;
				}
			}
		}
		request.lastPhotoId="";
		if(arguments.sysid NEQ 0){
			request.lastPhotoId=this.mls_id&"-"&arguments.sysid;
			photo='http://ntreispictures.marketlinx.com/MediaDisplay/'&right(arguments.sysid,2)&"/HR"&arguments.sysid&"-"&arguments.num&".jpg";
		}
		return photo;
		</cfscript>
    </cffunction>
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var db=request.zos.queryObject;
		var fd=0;
		var arrError=[];
		application.zcore.functions.zError("rets18 not tested");
		fd=this.getRETSValues("property", "","proptype_res");
		
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		fd=this.getRETSValues("property", "","propsubtype");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		throw("have to build list of counties a new way, qD was deleted");
		arrD=listtoarray(qD.datalist);
		dS=structnew();
		for(i=1;i LTE arraylen(arrD);i++){
			pos=find(" ",trim(arrD[i]));
			if(pos NEQ 0){
				countyName=left(trim(arrD[i]), pos-1);	
			}else{
				countyName="";
			}
			dS[trim(arrD[i])]=application.zcore.functions.zfirstlettercaps(countyName);
		}
		for(i in dS){
			arrayappend(arrSQL,"('#this.mls_provider#','county','#dS[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		fd=this.getRETSValues("property", "","lotdesc");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		fd=this.getRETSValues("property", "","style");
		for(i in fd){
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		throw("have to build list of cities a new way, qD was deleted");
		arrD=listtoarray(qD.datalist);
		tcs=structnew();
		for(i=1;i LTE arraylen(arrd);i++){
			tcs[application.zcore.functions.zfirstlettercaps(trim(arrd[i]))]=true;	
		}
		arrd=structkeyarray(tcs);
		failStr="";
		
		for(i=1;i LTE arraylen(arrd);i++){
			tempState="TX";
			cur=arrd[i];
			 db.sql="select * from #db.table("city_rename", request.zos.zcoreDatasource)# city_rename 
			WHERE city_name =#db.param(cur)# and 
			state_abbr=#db.param(tempState)# and 
			city_rename_deleted = #db.param(0)#";
			qD2=db.execute("qD2");
			if(qD2.recordcount NEQ 0){
				cur=qD2.city_renamed;
			}
			//arrayappend(arrC,application.zcore.functions.zescape(application.zcore.functions.zFirstLetterCaps(cur)));
			 db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# city 
			WHERE city_name =#db.param(cur)# and 
			state_abbr=#db.param(tempState)# and 
			city_deleted = #db.param(0)#";
			qD=db.execute("qD");
			if(qD.recordcount EQ 0){
				//writeoutput(cur&" missing<br />");
				 db.sql="select	* from #db.table("zipcode", request.zos.zcoreDatasource)# zipcode 
				WHERE city_name =#db.param(cur)# and 
				state_abbr=#db.param(tempState)# and 
				zipcode_deleted = #db.param(0)#";
				qZ=db.execute("qZ");
				if(qZ.recordcount NEQ 0){
					db.sql="INSERT INTO #db.table("city", request.zos.zcoreDatasource)#  
					SET city_name=#db.param(application.zcore.functions.zfirstlettercaps(cur))#, state_abbr=#db.param(tempState)#,
					country_code=#db.param('US')#, 
					city_mls_id=#db.param('0')#,
					 city_deleted=#db.param(0)#,
					 city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
					city_id=db.insert("q", request.zOS.insertIDColumnForSiteIDTable); 
					 db.sql="INSERT INTO #db.table("city_memory", request.zos.zcoreDatasource)#  
					 SET city_id=#db.param(city_id)#, 
					 city_name=#db.param(application.zcore.functions.zfirstlettercaps(cur))#, 
					 state_abbr=#db.param(tempState)#,
					 country_code=#db.param('US')#, 
					 city_mls_id=#db.param('0')#,
					 city_deleted=#db.param(0)#,
					 city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
					 db.execute("q");
					//writeoutput(city_id);
					cityCreated=true; // need to run zipcode calculations
				}else{
					failStr&=("<a href=""http://maps.google.com/maps?q=#urlencodedformat(cur&', texas')#"" rel=""external"" onclick=""window.open(this.href); return false;"">#cur#, texas</a> is missing in `#request.zos.zcoreDatasource#`.zipcode.<br />");
				}
			}
			arrayClear(request.zos.arrQueryLog);
		}
		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript> 
	</cffunction>
    </cfoutput>
</cfcomponent>