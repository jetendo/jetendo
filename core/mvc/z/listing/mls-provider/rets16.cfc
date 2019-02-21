<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>	<cfscript>
	this.retsVersion="1.7";
	
	this.mls_id=16;
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/16/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/16/";
	}
	this.useRetsFieldName="system";
	this.arrColumns=listtoarray("1	2	10	11	14	17	18	19	21	22	25	26	27	28	29	30	31	39	44	45	47	50	53	56	57	58	59	60	61	62	66	67	68	69	70	71	73	74	76	77	81	87	90	91	92	93	94	96	97	98	99	100	101	102	103	106	107	108	109	110	111	113	114	115	116	123	124	126	127	129	130	131	134	136	137	140	141	142	143	144	145	146	147	149	150	152	157	158	160	161	162	163	164	165	167	177	178	179	180	181	183	188	189	190	191	192	193	194	195	211	213	214	216	219	220	227	232	234	235	238	239	241	246	247	248	249	250	251	254	258	260	261	263	264	266	267	273	274	275	276	277	283	285	289	290	291	294	295	296	314	315	318	319	320	321	322	325	326	327	328	329	331	332	333	334	335	336	337	338	341	342	351	352	353	354	355	356	360	361	362	364	365	366	367	368	369	370	372	373	374	375	376	384	385	387	389	390	391	392	394	395	396	397	398	399	400	402	403	404	407	408	409	410	412	413	414	416	417	419	420	421	422	424	425	426	427	428	429	430	431	432	433	434	435	437	438	439	440	441	442	443	444	445	446	448	449	450	455	456	460	461	462	463	464	465	466	467	469	470	471	472	474	475	477	478	479	481	483	484	486	487	489	491	492	493	494	495	496	497	498	499	500	501	502	506	507	508	509	510	511	512	514	515	516	517	518	519	520	521	522	523	524	525	526	527	528	529	530	531	532	533	536	537	538	539	540	541	542	543	544	545	546	547	548	551	552	554	555	561	562	563	564	565	567	568	569	570	572	573	574	575	576	577	578	579	580	581	582	583	584	585	586	587	588	589	590	591	592	593	594	595	597	598	599	600	601	602	603	604	605	606	607	608	609	610	613	615	616	617	618	620	621	622	623	632	634	638	641	642	643	644	645	646	647	648	649	650	651	652	653	654	655	656	657	658	659	660	661	662	663	664	665	671	673	674	675	677	678	681	682	683	684	685	686	687	688	689	690	691	692	693	694	695	696	697	698	699	700	701	702	703	704	705	706	707	708	709	713	716	737	738	747	881	886	891	893	894	895	896	897	898	899	900	901	902	903	904	905	906	907	908	909	910	911	912	922	924	948	950	952	954	956	958	960	962	964	966	968	970	972	974	976	978	980	982	984	986	988	990	992	994	996	998	1000	1002	1016	1018	1020	1022	1024	1026	1028	1030	1032	1034	1036	1038	1040	1042	1044	1046	1048	1050	1052	1054	1056	1058	1060	1062	1064	1066	1068	1070	1072	1074	1076	1078	1080	1082	1084	1086	1088	1223	1329	1339	1410	1424	1426	1430	1465	1473	1485	1486	1487	1488	sysid",chr(9));
	this.arrFieldLookupFields=listtoarray("54	81	82	84	85	87	95	108	114	122	124	131	146	196	211	379	383	384	389	390	391	395	398	399	400	401	402	404	405	410	423	425	428	429	431	436	438 444	478	480	481	513	514	114	146	1465	1473	1488	150	164	19	195	22	227	246	267	365	39	590	594	595	600	601	602	606	609	61	610	613	615	617	618 623	650	652	655	656	658	662	664	675	709	713	73	922	924",",");
	this.mls_provider="rets16";
	this.sysidfield="rets16_sysid";
	resourceStruct=structnew();
	resourceStruct["property"]=structnew();
	resourceStruct["property"].resource="property";
	resourceStruct["property"].id="157";
	this.emptyStruct=structnew();
	
	</cfscript> 
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var rs5=0;
		var r222=0;
		var i10=0;
		var n=0;
		var arrV=0;
		var t3=0;
		var t2=0;
		var shortColumn=0;
		var t1=0;
		var value=0;
		var arrV2=0;
		var values="";
		var newlist="";
		var i=0;
		var columnIndex=structnew();
		var address=0;
		var cid=0;
		var curLat=0;
		var curLong=0;
		var s=0;
		var cityStruct222=0;
		var arrt3=0;
		var uns=0;
		var tmp=0;
		var arrt=0;
		var arrt2=0;
		var ts2=0;
		var datacom=0;
		var values=0;
		var ts=0;
		var col=0;
		var cityName=0;
		var t9493=0;
		var idx=0;
		var rs=0;
		var ad=0;
		var arrs=0;
		var c=0;
		var rs=0;
		
		if(structcount(this.emptyStruct) EQ 0){
			for(i=1;i LTE arraylen(this.arrColumns);i++){
				if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields, this.arrColumns[i])){
					this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
				}
			}
		}
		ts=duplicate(this.emptyStruct);// this cannot be a local scope due to zo usage 
		/*
		
		wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '16-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '16-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '16-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '16-%'; 
		*/
		//application.zcore.functions.zdump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
		if(arraylen(arguments.ss.arrData) NEQ arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.functions.zdump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
			application.zcore.functions.zdump(arguments.ss.arrData);
			application.zcore.functions.zabort();
		}  
		if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
			application.zcore.template.fail("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
		}
		for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
			col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
			ts["rets16_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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
			columnIndex[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i]]=i;
		}
		ts["list price"]=replace(ts["list price"],",","","ALL");
		
		// 2983=SW Subdv Community Name
		local.listing_subdivision="";
		if(local.listing_subdivision EQ ""){
			// 2316=Subdivision Name
			if(findnocase(","&ts["Subdivision Name"]&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Subdivision Name"]="";
			}else if(ts["Subdivision Name"] NEQ ""){
				ts["Subdivision Name"]=application.zcore.functions.zFirstLetterCaps(ts["Subdivision Name"]);
			}
			local.listing_subdivision=ts["Subdivision Name"];
		}
		if(local.listing_subdivision EQ ""){
			// 2316=Complex/Community Name/NCCB
			if(findnocase(","&ts["Subdivision/Complex/Bldg."]&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
				ts["Subdivision/Complex/Bldg."]="";
			}else if(ts["Subdivision/Complex/Bldg."] NEQ ""){
				ts["Subdivision/Complex/Bldg."]=application.zcore.functions.zFirstLetterCaps(ts["Subdivision/Complex/Bldg."]);
			}
			local.listing_subdivision=ts["Subdivision/Complex/Bldg."];
		}
		
		
		this.price=ts["list price"];
		local.listing_price=ts["list price"];
		cityName="";
		cid=0; 
		
		t9493=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup[922];
		if(structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].typeStruct[t9493].valueStruct, ts["city name"])){
			cityName=replace(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].typeStruct[t9493].valueStruct[ts["city name"]],"-"," ","all");
		}
		if(cityName EQ "LakeWorth"){
			cityName="Lake Worth";
		}else if(cityName EQ "Port St. Lucie"){
			cityName="Port Saint Lucie";
		}
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|FL")){
			cid=request.zos.listing.cityStruct[cityName&"|FL"];
		}
		if(cid EQ 0){
			writeoutput(cityName&'<br />');
		}
		local.listing_county=this.listingLookupNewId("county",ts['county']);
		
		local.listing_sub_type_id="";

		local.listing_type_id=this.listingLookupNewId("listing_type",ts['property type']);

		rs=getListingTypeWithCode(ts["property type"]);
		
		if(ts["Address on Internet"] EQ "N"){
			ts["street number"]="";
			ts["street name"]="";
			ts["Unit Number"]="";
		}
		
		ts["property type"]=rs.id;
		ad=ts['street number'];
		if(ad NEQ 0){
			address="#ad# ";
		}else{
			address="";	
		}
		address&=trim(application.zcore.functions.zfirstlettercaps(ts['street name'])&" "&application.zcore.functions.zfirstlettercaps(ts['street suffix']));
		curLat='';
		curLong='';
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts['state'],ts['zip code'], arguments.ss.listing_id);
			if(rs5.success){
				curLat=rs5.latitude;
				curLong=rs5.longitude;
			}
		}
		
		if(ts['Unit Number'] NEQ ''){
			address&=" Unit: "&ts["Unit Number"];	
		}
		
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=ts['year built'];
		ts2.foreclosureField="";
		
		s=this.processRawStatus(ts2);
		if(ts['Short Sale'] EQ 'Y'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}
		arrS=listtoarray(replace(ts['Special Information'],'"','','all'),",");
		for(i=1;i LTE arraylen(arrS);i++){
			c=trim(arrS[i]);
			if(c EQ "BANKOWNED"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
				break;
			}else if(c EQ "FORECLOSE"){
				s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
				break;
			}
		}
		if(ts['Tax Information'] CONTAINS 'NEWCONST'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["new construction"]]=true;
		}
		if(ts['property type'] EQ "RNT"){
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
		}else{
			structdelete(s,request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]);
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
		}
		arrT3=[];
		local.listing_status=structkeylist(s,",");
		
		
		uns=structnew();
		arrT2=arraynew(1);
		tmp=replace(ts['Style of Property'],'"','','all');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("style",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
		local.listing_style=arraytolist(arrT2,",");
		


		
		
		// view & frontage
		arrT3=[];
		
		arrT2=arraynew(1);
		
		uns=structnew();
		tmp=replace(ts['Waterfront Description'],'"','','all');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("frontage",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
		local.listing_frontage=arraytolist(arrT2,",");
		
		uns=structnew();
		arrT2=arraynew(1);
		tmp=replace(ts['VIEW'],'"','','all');
		if(tmp NEQ ""){
		   arrT=listtoarray(tmp);
			for(i=1;i LTE arraylen(arrT);i++){
				tmp=this.listingLookupNewId("view",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
		local.listing_view=arraytolist(arrT2,",");
		

		local.listing_pool=0;
		if(ts["pool"] EQ "Y"){
			local.listing_pool=1;	
		}
		idx=ts;
		for(i10 in idx){
			value=idx[i10];
			shortColumn=replace(i10,"rets16_","");
			if(len(value) NEQ 0){
				if(left(i10,8) NEQ 'listing_' and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup, shortColumn)){
					arrV=listtoarray(trim(replace(value,'"','','all')),',',false);
					arrV2=arraynew(1);
		
					for(n=1;n LTE arraylen(arrV);n++){
						t2=replace(arrV[n]," ","","ALL");
						t3=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].typeStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup[shortColumn]].valueStruct;
						if(structkeyexists(t3, t2)){
							t1=application.zcore.functions.zfirstlettercaps(t3[t2]);
						}else{
							t1="";	
						}
						if(t1 NEQ ""){
							arrayappend(arrV2,t1);
						}
					}
					idx[i10]=arraytolist(arrV2,", ");
				}
			}
		}
		dataCom=this.getRetsDataObject();
		local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
		local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
		local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
		
		rs=structnew();
		rs.listing_id=arguments.ss.listing_id;
		rs.listing_acreage=ts["total acreage"];
		rs.listing_baths=ts["##FBaths"];
		rs.listing_halfbaths=ts["##HBaths"];
		rs.listing_beds=ts["##Beds"];
		rs.listing_city=cid;
		rs.listing_county=local.listing_county;
		rs.listing_frontage=","&local.listing_frontage&",";
		rs.listing_frontage_name="";
		rs.listing_price=ts["list price"];
		rs.listing_status=","&local.listing_status&",";
		rs.listing_state=ts["state"];
		rs.listing_type_id=local.listing_type_id;
		rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
		rs.listing_style=","&local.listing_style&",";
		rs.listing_view=","&local.listing_view&",";
		rs.listing_lot_square_feet=ts["Approximate Lot Size"];
		rs.listing_square_feet=ts["SqFt Liv Area"];
		rs.listing_subdivision=listing_subdivision;
		rs.listing_year_built=ts["year built"];
		rs.listing_office=ts["List Broker Code"];
		rs.listing_agent=ts["List Agent Public Id"];
		rs.listing_latitude=curLat;
		rs.listing_longitude=curLong;
		rs.listing_pool=local.listing_pool;
		rs.listing_photocount=ts["I##"];
		rs.listing_coded_features="";
		rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
		rs.listing_primary="0";
		rs.listing_mls_id=arguments.ss.listing_mls_id;
		rs.listing_address=trim(address);
		rs.listing_zip=ts["zip code"];
		rs.listing_condition="";
		rs.listing_parking="";
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus="1";
		rs.listing_data_remarks=ts["remarks"];
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts["zip code"]);
		rs.listing_data_detailcache1=listing_data_detailcache1;
		rs.listing_data_detailcache2=listing_data_detailcache2;
		rs.listing_data_detailcache3=listing_data_detailcache3;

		rs.listing_track_sysid=ts["rets16_sysid"];
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
		idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails);
		t99=gettickcount();
		idx["features"]="";
		a2=listtoarray(trim(lcase(arguments.ss.columnlist)),',',false);
		t44444=0;
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		request.lastPhotoId="";
		if(idx.listing_photocount EQ 0){
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
		}else{
			i=1;
			for(i=1;i LTE idx.listing_photocount;i++){
				local.fNameTemp1=arguments.ss.listing_id&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				local.absPath='#request.zos.sharedPath#mls-images/16/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				//if(fileexists(local.absPath)){
					if(i EQ 1){
						request.lastPhotoId=arguments.ss.listing_id;
					}
					idx["photo"&i]=request.zos.retsPhotoPath&'16/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				/*}else{
					if(i EQ 1){
						request.lastPhotoId="";
					}
					idx["photo"&i]='/z/a/listing/images/image-not-available.gif'; 
				}*/
			} 
		}
			idx["agentName"]=application.zcore.functions.zso(arguments.ss, "rets16_144");
			idx["agentPhone"]="";
			idx["agentEmail"]="";
			idx["officeName"]=application.zcore.functions.zso(arguments.ss, "rets16_165");
			idx["officePhone"]="";
			idx["officeCity"]="";
			idx["officeAddress"]="";
			idx["officeZip"]="";
			idx["officeState"]="";
			idx["officeEmail"]="";
			
		idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets16_1223");
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_10");
		
			idx["maintfees"]="";
		if(structkeyexists(arguments.ss, "rets#this.mls_id#_597") and arguments.ss["rets#this.mls_id#_597"] NEQ ""){
			idx["maintfees"]=arguments.ss["rets#this.mls_id#_597"];
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
        <cfargument name="sysid" type="numeric" required="no" default="0">
    	<cfscript>
		var qId=0;
		var db=request.zos.queryObject;
		
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=this.mls_id&"-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		local.absPath='#request.zos.sharedPath#mls-images/16/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		if(fileexists(local.absPath)){
			return request.zos.retsPhotoPath&'16/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		}else{
			return "";
			request.lastPhotoId="";
		} 
		</cfscript>
    </cffunction>
	
    <cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
		<cfscript>
		var i=0;
		var s=0;
		var arrSQL=[];
		var fd=0;
		var arrError=[];
		var i2=0;
		var tmp=0;

		// 19=county
		fd=this.getRETSValues("property", "","61"); 
		for(i in fd){
				i2=i;
			arrayappend(arrSQL,"('#this.mls_provider#','county','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
				
		// property style lookups
		fd=this.getRETSValues("property", "","1");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		
		
		
		// frontage
		fd=this.getRETSValues("property", "","296");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		
		
		// view
		fd=this.getRETSValues("property", "","589");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		fd=this.getRETSValues("property", "","662");
		for(i in fd){
				tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", "","491");
		for(i in fd){
				tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", "","586");
		if(isstruct(fd)){
		for(i in fd){
				tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		}else{
			arrayappend(arrError,'16 style 586 missing field');
		}
		
		fd=this.getRETSValues("property", "","662");
		for(i in fd){
				tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}

		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>