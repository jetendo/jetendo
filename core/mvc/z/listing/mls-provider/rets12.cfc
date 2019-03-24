<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>	<cfscript>
	this.retsVersion="1.7";
	
	this.mls_id=12;
	if(request.zos.istestserver){
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/12/";
	}else{
		variables.hqPhotoPath="#request.zos.sharedPath#mls-images/12/";
	}
	this.useRetsFieldName="system";
	this.arrColumns=listtoarray("1	2	10	11	17	18	19	21	22	25	28	29	30	31	34	44	45	46	50	53	54	56	57	59	60	61	62	63	66	67	68	69	70	71	73	75	76	78	80	81	87	90	92	93	94	96	97	98	99	100	102	103	106	107	108	109	110	111	113	114	115	116	126	127	129	131	134	136	137	140	141	143	144	145	146	147	149	150	152	157	158	160	161	162	163	164	165	167	177	178	179	180	181	189	190	191	192	193	194	195	206	214	216	219	220	223	225	226	227	229	230	231	232	234	235	239	241	242	246	247	248	249	250	253	254	258	260	261	263	266	267	268	274	275	276	285	289	290	291	294	295	296	314	315	317	318	319	322	326	329	330	331	332	333	334	335	336	337	338	341	347	348	352	353	355	356	360	362	363	365	366	367	368	370	371	372	373	374	375	376	386	388	390	391	392	393	396	397	398	399	400	401	404	406	411	415	416	417	418	419	420	421	422	424	429	430	431	432	433	435	436	437	440	441	442	446	449	450	455	462	466	469	472	477	479	483	484	486	487	489	491	492	494	495	498	500	501	502	506	510	511	512	514	517	518	519	520	521	522	523	524	527	534	536	538	539	540	542	544	547	548	552	563	565	568	569	573	574	575	576	578	579	580	581	582	584	585	586	587	588	594	598	600	601	603	604	605	606	608	609	610	613	619	621	622	623	632	634	638	641	642	643	644	645	646	647	648	650	651	652	653	654	655	656	658	659	661	662	664	665	671	675	676	677	678	679	680	681	682	683	684	685	686	687	688	689	690	691	692	693	694	695	696	697	698	699	700	701	702	703	704	705	706	709	713	716	720	721	722	723	727	728	733	734	737	738	742	743	746	747	748	881	883	886	891	892	893	894	895	896	897	898	899	900	901	902	903	904	905	906	907	908	909	922	924	948	950	952	954	956	958	960	962	964	966	968	970	972	974	976	978	980	982	984	986	988	990	992	994	996	998	1000	1002	1016	1018	1020	1022	1024	1026	1028	1030	1032	1034	1036	1038	1040	1042	1044	1046	1048	1050	1052	1054	1056	1058	1060	1062	1064	1066	1068	1070	1072	1074	1076	1078	1080	1082	1084	1086	1088	1218	1223	1328	1329	1340	1424	1426	1428	1430	1465	1473	sysid",chr(9));
	this.arrFieldLookupFields=arraynew(1);
	this.mls_provider="rets12";
	this.sysidfield="rets12_sysid";
	variables.resourceStruct=structnew();
	variables.resourceStruct["property"]=structnew();
	variables.resourceStruct["property"].resource="property";
	variables.resourceStruct["property"].id="157";
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
		var cityname=0;
		var cid=0;
		var ts=0;
		var col=0;
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
		var datacom=0;
		var idx=0;
		var values=0;
		var rs=0;
		if(structcount(this.emptyStruct) EQ 0){
			for(i=1;i LTE arraylen(this.arrColumns);i++){
				this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
			}
		}
		ts=duplicate(this.emptyStruct);
		/*
		
		wipe out the listings to reimport them again...
DELETE FROM `#request.zos.zcoreDatasource#`.listing_track WHERE listing_id LIKE '12-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing WHERE listing_id LIKE '12-%';
DELETE FROM `#request.zos.zcoreDatasource#`.listing_data WHERE listing_id LIKE '12-%';
DELETE FROM `#request.zos.zcoreDatasource#`.`listing_memory` WHERE listing_id LIKE '12-%'; 
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
			ts["rets12_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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

		
		address=ts['Address'];
		curLat='';
		curLong='';
		if(trim(address) NEQ ""){
			rs5=this.baseGetLatLong(address,ts['state'],ts['zip code'], arguments.ss.listing_id);
			if(rs5.success){
				curLat=rs5.latitude;
				curLong=rs5.longitude;
			}
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
			shortColumn=replace(i10,"rets12_","");
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
		rs.local.listing_county=local.listing_county;
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
		
		rs.listing_address=trim(address)
		rs.listing_zip=ts["zip code"];
		rs.listing_condition="";
		rs.listing_parking="";
		rs.listing_region="";
		rs.listing_tenure="";
		rs.listing_liststatus="1";
		rs.listing_data_remarks=ts["Internet Remarks"];
		rs.listing_data_address=trim(address);
		rs.listing_data_zip=trim(ts["zip code"]);
		rs.listing_data_detailcache1=local.listing_data_detailcache1;
		rs.listing_data_detailcache2=local.listing_data_detailcache2;
		rs.listing_data_detailcache3=local.listing_data_detailcache3;

		rs.listing_track_sysid=ts["rets12_sysid"];
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
		var t3=0;
		var t2=0;
		var i10=0;
		var value=0;
		var n=0;
		var column=0;
		var arrV=0;
		var arrV2=0;
		var idx=this.baseGetDetails(arguments.ss, arguments.row, arguments.fulldetails);
		
		t99=gettickcount();
		idx["features"]="";
		idx.listingSource=request.zos.listing.mlsStruct[listgetat(idx.listing_id,1,'-')].mls_disclaimer_name;
		
		
		t44444=0;
		request.lastPhotoId="";
		if(arguments.ss.listing_photocount EQ 0){
			idx["photo1"]='/z/a/listing/images/image-not-available.gif';
		}else{
			i=1;
			for(i=1;i LTE idx.listing_photocount;i++){
				local.fNameTemp1=arguments.ss.listing_id&"-"&i&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				local.absPath='#request.zos.sharedPath#mls-images/12/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				//if(fileexists(local.absPath)){
					if(i EQ 1){
						request.lastPhotoId=arguments.ss.listing_id;
					}
					idx["photo"&i]=request.zos.retsPhotoPath&'12/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
				/*}else{
					idx["photo"&i]='/z/a/listing/images/image-not-available.gif';
					if(i EQ 1){
						request.lastPhotoId="";
					}
				}*/
			}
		}
			idx["agentName"]=application.zcore.functions.zso(arguments.ss, "rets12_144");
			idx["agentPhone"]="";
			idx["agentEmail"]="";
			idx["officeName"]=application.zcore.functions.zso(arguments.ss, "rets12_165");
			idx["officePhone"]="";
			idx["officeCity"]="";
			idx["officeAddress"]="";
			idx["officeZip"]="";
			idx["officeState"]="";
			idx["officeEmail"]="";
			
		idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets12_1223");
		idx["zipcode"]=application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_10");
		idx["maintfees"]="";
		if(application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_93") NEQ ""){
			idx["maintfees"]=application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_93");
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
		local.absPath='#request.zos.sharedPath#mls-images/12/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		if(fileexists(local.absPath)){
			return request.zos.retsPhotoPath&'12/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		}else{
			return "";
			request.lastPhotoId="";
		}
		/*
		}else{
			if(arguments.sysid EQ 0){
				db.sql="select SQL_NO_CACHE rets12_sysid 
				from #db.table("rets12_property", request.zos.zcoreDatasource)# rets12_property 
				where rets12_157=#db.param('12-#arguments.mls_pid#')#";
				qId=db.execute("qId"); 
				if(qId.recordcount NEQ 0){
					arguments.sysid=qId.rets12_sysid;
				}
			}
			request.lastPhotoId="";
			if(arguments.sysid NEQ 0){
				request.lastPhotoId=this.mls_id&"-"&arguments.sysid;
				local.fNameTemp1=arguments.sysid&"-"&arguments.num&".jpeg";
				local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
				return request.zos.retsPhotoPath&'12/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
			}else{
				return "";
			}
		}*/
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
		fd=this.getRETSValues("property", "", "61");
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
		fd=this.getRETSValues("property", "","367");
		if(isstruct(fd)){
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		}else{
			arrayappend(arrError,"12 style 367 missing field");
		}
		fd=this.getRETSValues("property", "","437");
		if(isstruct(fd)){
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		}else{
			arrayappend(arrError,"12 style 437 missing field");
		}
		fd=this.getRETSValues("property", "","491");
		if(isstruct(fd)){
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		}else{
			arrayappend(arrError,"12 style 491 missing field");
		}
		
		fd=this.getRETSValues("property", "","586");
		if(isstruct(fd)){
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		}else{
			arrayappend(arrError,"12 style 586 missing field");
		}
		fd=this.getRETSValues("property", "","662");
		if(isstruct(fd)){
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		}
		fd=this.getRETSValues("property", "","747");
		if(isstruct(fd)){
		for(i in fd){
			if(i NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		}else{
			arrayappend(arrError,"12 style 747 missing field");
		}
		
		// frontage
		fd=this.getRETSValues("property", "","296");
		if(isstruct(fd)){
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		}else{
			arrayappend(arrError,"12 style 296 missing field");
		}
			
		
		// view
		fd=this.getRETSValues("property", "","285");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", "", "502");
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