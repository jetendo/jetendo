<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>	<cfscript>
	this.retsVersion="1.7";
	 
	this.mls_id=19;
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/19/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/19/";
	}
	this.useRetsFieldName="system";
	this.arrColumns=listtoarray("1	2	10	11	17	18	19	21	22	25	26	27	28	29	30	31	39	44	45	50	53	54	56	57	59	60	61	66	67	68	69	70	71	73	76	81	87	90	91	92	93	94	96	97	98	99	100	101	102	103	106	107	108	109	110	111	113	114	115	116	126	127	129	131	134	136	137	140	141	142	143	144	145	146	147	149	150	152	157	158	160	161	162	163	165	167	177	178	179	180	181	183	189	190	191	192	193	194	209	211	213	216	219	220	225	226	227	232	234	235	238	239	241	245	246	250	251	253	254	258	260	261	263	264	266	267	273	274	275	276	277	283	285	289	290	291	294	295	296	314	315	318	319	320	321	322	324	325	326	327	328	329	331	332	333	334	335	336	337	341	342	352	353	354	355	356	360	361	362	363	364	365	366	367	368	369	370	372	373	374	375	376	384	385	387	389	390	391	392	393	394	395	396	397	398	399	400	402	403	404	407	408	409	410	412	413	414	416	417	419	420	421	422	424	425	426	427	428	429	430	431	432	433	434	435	437	438	439	440	441	442	443	444	445	446	448	449	450	455	456	460	461	462	463	465	466	467	469	470	471	472	474	475	477	478	479	481	483	484	486	487	488	489	490	491	492	493	494	495	496	498	499	500	501	502	506	507	508	509	510	511	512	514	515	516	517	518	519	520	521	522	523	524	525	526	527	528	529	530	531	532	533	536	537	538	539	540	541	542	543	544	545	546	547	548	551	552	554	555	561	562	563	564	565	567	568	569	570	572	573	575	576	577	578	579	580	581	582	583	584	585	586	587	588	589	590	591	592	593	594	595	597	598	599	600	601	602	603	604	605	606	607	608	609	610	612	613	614	615	616	617	618	619	620	621	622	623	632	634	638	641	642	643	644	645	646	647	648	649	650	651	652	653	654	655	656	657	658	659	660	661	662	663	664	665	666	671	673	674	675	677	678	681	682	683	684	685	686	687	688	689	690	691	692	693	694	695	696	697	698	699	700	701	702	703	704	705	706	707	708	709	713	714	715	716	717	718	719	720	721	722	723	724	725	726	727	728	729	730	732	733	734	735	736	737	738	739	740	741	742	743	744	745	746	747	748	749	750	756	886	891	893	894	895	896	897	898	899	900	901	902	903	904	905	906	907	908	909	910	911	912	922	924	942	944	948	950	952	954	956	958	960	962	964	966	968	970	972	974	976	978	980	982	984	986	988	990	992	994	996	998	1000	1002	1016	1018	1020	1022	1024	1026	1028	1030	1032	1034	1036	1038	1040	1042	1044	1046	1048	1050	1052	1054	1056	1058	1060	1062	1064	1066	1068	1070	1072	1074	1076	1078	1080	1082	1084	1086	1088	1223	1329	1339	1424	1426	1465	1473	1487	1488	sysid",chr(9));
	this.arrFieldLookupFields=arraynew(1);
	this.mls_provider="rets19";
	this.sysidfield="rets19_sysid";
	resourceStruct=structnew();
	resourceStruct["property"]=structnew();
	resourceStruct["property"].resource="property";
	resourceStruct["property"].id="157";
	this.emptyStruct=structnew();
	</cfscript> 
    
    <cffunction name="initImport" localmode="modern" output="no" returntype="any">
    	<cfargument name="resource" type="string" required="yes">
        <cfargument name="sharedStruct" type="struct" required="yes">
    	<cfscript>
		
		super.initImport(arguments.resource, arguments.sharedStruct);
		arguments.sharedStruct.lookupStruct.cityRenameStruct=structnew();
		</cfscript>
        
    </cffunction>
    
    <cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	<cfscript>
		var rs5=0;
		var r222=0;
		var values="";
		var newlist="";
		var i=0;
		var columnIndex=structnew();
		var cityName=0;
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
		var idx=0;
		var datacom=0;
		var values=0;
		var ts=0;
		var col=0;
		var rs=0;
		
		if(structcount(this.emptyStruct) EQ 0){
			for(i=1;i LTE arraylen(this.arrColumns);i++){
				this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
			}
		}
		ts=duplicate(this.emptyStruct);
		/*
		
		wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '11-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '11-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '11-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '11-%'; 
		*/
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
			ts["rets19_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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
		
		local.listing_subdivision="";
		if(findnocase(","&ts["Subdivision Name"]&",", ",false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") EQ 0 and ts["Subdivision Name"] NEQ ""){
			ts["Subdivision Name"]=application.zcore.functions.zFirstLetterCaps(ts["Subdivision Name"]);
			local.listing_subdivision=ts["Subdivision Name"];
		}else if(findnocase(","&ts["Complex Name"]&",", ",false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") EQ 0 and ts["Complex Name"] NEQ ""){
			ts["Complex Name"]=application.zcore.functions.zFirstLetterCaps(ts["Complex Name"]);
			local.listing_subdivision=ts["Complex Name"];
		}else if(findnocase(","&ts["Development Name"]&",", ",false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") EQ 0 and ts["Development Name"] NEQ ""){
			ts["Development Name"]=application.zcore.functions.zFirstLetterCaps(ts["Development Name"]);
			local.listing_subdivision=ts["Development Name"];
		}
		
		
		
		this.price=ts["list price"];
		local.listing_price=ts["list price"];
		cityName="";
		cid=0;
		cityStruct222=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].typeStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].fieldLookup["922"]].valueStruct;
		
		ts["city name"]=trim(ts["city name"]);
		if(structkeyexists(cityStruct222, trim(ts["city name"]))){
			cityName=trim(cityStruct222[ts["city name"]]);
		}else if(structkeyexists(cityStruct222, ts["city name"])){
			cityName=trim(cityStruct222[ts["city name"]]);
		}else{
			cityName="";
		}
		if(cityName EQ "lakeworth"){
			cityName="Lake Worth";
		}else if(cityName EQ "Port St. Lucie"){
			cityName="Port Saint Lucie";
		}else if(cityName EQ "Opa-Locka"){
			cityName="Opa Locka";
		}
		
		
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["state"])){
			cid=request.zos.listing.cityStruct[cityName&"|"&ts["state"]];
		}
		local.listing_county=this.listingLookupNewId("county",ts['county']);
		

		local.listing_sub_type_id="";
		
		local.listing_type_id=this.listingLookupNewId("listing_type",ts['property type']);

		
		if(ts["Address on Internet"] EQ "N"){
			ts["Address (Internet Display)"]="";
			ts["unit number"]="";
		}
		
		address=ts['Address (Internet Display)'];
		curLat='';
		curLong='';
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts['state'],ts['zip code'], arguments.ss.listing_id);
			curLat=rs5.latitude;
			curLong=rs5.longitude;
		}
		
		if(ts['unit number'] NEQ ''){
			address&=" Unit: "&ts["unit number"];	
		}
		
		ts2=structnew();
		ts2.field="";
		ts2.yearbuiltfield=ts['year built'];
		ts2.foreclosureField="";
		
		s=this.processRawStatus(ts2);
		
		if(ts['Short Sale'] EQ 'Y'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}
		if(ts['REO'] EQ 'Y'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}
		if(ts['Special Information'] CONTAINS 'SHORT SALE'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}
		if(ts['Special Information'] CONTAINS "FORECLOSE"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
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
		tmp=ts['style'];
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
		tmp=ts['style of property'];
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
		tmp=ts['Property Type Information'];
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
		
		tmp=ts['style of business'];
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
		
		// view & frontage
		arrT3=[];
		
		
		uns=structnew();
		tmp=ts['Waterfront Description'];
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
		
		
		arrT2=[]; 
		uns=structnew();
		tmp=ts['view'];
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
		tmp=ts['waterview description'];
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
		local.listing_view=arraytolist(arrT2);
		

		local.listing_pool=0;
		if(ts["Pool"] EQ "Y"){
			local.listing_pool=1;	
		}
		
		idx=ts;
		for(i10 in idx){ 
			value=idx[i10];
			shortColumn=replace(i10,"rets19_","");
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
		rs.listing_acreage=ts["Total Acreage"];
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
		rs.listing_lot_square_feet=ts["Property SqFt"];
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
		rs.listing_condoname="";
		rs.listing_address=trim(address);
		rs.listing_zip=ts["zip code"];
		rs.listing_condition="";
		rs.listing_parking="";
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus="1";
		rs.listing_data_remarks=ts["Internet Remarks"];
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts["zip code"]);
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
		t99=gettickcount();
		idx["features"]="";
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		t44444=0;
		request.lastPhotoId=idx.listing_id;//this.mls_id&"-"&idx.rets19_sysid;
		/*if(structkeyexists(form, 'debugPhotos')){
			echo("count:"&idx.listing_photocount&"<BR>");
		}*/
		if(idx.listing_photocount EQ 0){
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
		}else{
			i=1; 
			for(i=1;i LTE idx.listing_photocount;i++){
				local.fNameTemp1=idx.listing_id&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				idx["photo"&i]=request.zos.retsPhotoPath&'19/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
			}
		}
		idx["agentName"]=application.zcore.functions.zso(idx, "rets19_144");
		idx["agentPhone"]="";
		idx["agentEmail"]="";
		idx["officeName"]=application.zcore.functions.zso(idx, "rets19_165");
		idx["officePhone"]="";
		idx["officeCity"]="";
		idx["officeAddress"]="";
		idx["officeZip"]="";
		idx["officeState"]="";
		idx["officeEmail"]="";
			
		idx["virtualtoururl"]=application.zcore.functions.zso(idx, "rets19_1223");
		idx["zipcode"]=application.zcore.functions.zso(idx, "rets19_10");
		idx["maintfees"]="";
		if(application.zcore.functions.zso(idx, "rets19_93") NEQ ""){
			idx["maintfees"]=idx.rets19_93;
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
		
		request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
		local.fNameTemp1=this.mls_id&"-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
		local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
		local.absPath='#request.zos.sharedPath#mls-images/19/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		if(fileexists(local.absPath)){
			return request.zos.retsPhotoPath&'19/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		}else{
			request.lastPhotoId="";
			return "";
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
		var tmp=0;
		var i2=0;
		// 19=county
		fd=this.getRETSValues("property", "","61");
		for(i in fd){
				i2=i;
			arrayappend(arrSQL,"('#this.mls_provider#','county','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
			
				
		fd=this.getRETSValues("property", "","1");
		
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
				
		// property style lookups
		fd=this.getRETSValues("property", "","251");
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", "","367");
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", "","437");
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", "","438");
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", "","491");
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", "","539");
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", "","586");
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", "","662");
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", "","747");
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		
		// frontage
		fd=this.getRETSValues("property", "","296");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		// view
		fd=this.getRETSValues("property", "","285");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", "","589");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", "","502");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", "","375");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		return {arrSQL:arrSQL, cityCreated:false, arrError:arrError};
		</cfscript>
	</cffunction>
    </cfoutput>
</cfcomponent>