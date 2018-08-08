<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
<cfscript>
this.retsVersion="1.7";

this.mls_id=22;
if(request.zos.istestserver){
	hqPhotoPath="#request.zos.sharedPath#mls-images/22/";
}else{
	hqPhotoPath="#request.zos.sharedPath#mls-images/22/";
}
this.useRetsFieldName="system";
this.arrTypeLoop=["A","B","C","D","E"];
//this.arrTypeLoop=["CommercialProperty","IncomeProperty","Rental","ResidentialProperty","VacantLand"];
this.arrColumns=listtoarray("boardcode	colisting_member_address	colisting_member_email	feat20140414220532062889000000	colisting_member_fax	colisting_member_name	feat20140414220649171230000000	colisting_member_phone	feat20140414220523652110000000	colisting_member_shortid	colisting_member_url	coselling_member_address	coselling_member_email	coselling_member_fax	coselling_member_name	coselling_member_phone	feat20140414220532326764000000	coselling_member_shortid	coselling_member_url	feat20130303191402055377000000	feat20130303191418283689000000	feat20130303191614868962000000	feat20130303192136457093000000	feat20130303192342330382000000	gf20140414234430119311000000	feat20130303192406427253000000	feat20130303192424224044000000	feat20130303192448505389000000	list_165	feat20130303192613677192000000	feat20130303192639158718000000	feat20130303192710146451000000	feat20140429175459225119000000	feat20130303192732303667000000	feat20140429175459043783000000	feat20130303192757214251000000	feat20130303192819080310000000	feat20140224204442849373000000	feat20130303192841762175000000	feat20140414220550525724000000	feat20130303192853530677000000	feat20140414220550173767000000	feat20130311203427169504000000	feat20130311203455364360000000	gf20130226165731530666000000	feat20140414220646298510000000	list_96	feat20130311203633352493000000	feat20130311203651472732000000	feat20140414220550470909000000	gf20140414220550270729000000	feat20140414220548275310000000	feat20130311203816668450000000	feat20130311203854178425000000	feat20140429175458150316000000	feat20140224204455615695000000	feat20140414220532223015000000	feat20130311204037960304000000	gf20140415203441198230000000	feat20130311204059244934000000	feat20130311204115909928000000	feat20130311204143648880000000	feat20130311204201421075000000	feat20130311204216351611000000	feat20130311204234872729000000	feat20140415000041864890000000	coselling_office_name	feat20140414220549998579000000	colisting_office_name	feat20130312180901287538000000	feat20130312180923868874000000	feat20130312180943423178000000	feat20130312181004923671000000	feat20130312184010894153000000	feat20130312184432190678000000	gf20140414220721047738000000	feat20130312184452532398000000	feat20130312184503305368000000	feat20140414220548085828000000	feat20130312184517534659000000	feat20140311161449097690000000	gf20140414220534068563000000	feat20130312184534388987000000	feat20130312184547979158000000	feat20140701195207759080000000	feat20140414220531956466000000	feat20130312184622995608000000	feat20140701195301362786000000	feat20130312184643010360000000	feat20130312184652820129000000	feat20130312184706851966000000	feat20130312184912484980000000	feat20140414220549703716000000	feat20130313160631073350000000	feat20130313160631077279000000	colisting_office_shortid	feat20130313160631469603000000	feat20140414220548213758000000	feat20130313160631473319000000	feat20130313160631630957000000	feat20140414220549752627000000	feat20130313160631645969000000	feat20130313160631660601000000	feat20130313160631705545000000	feat20140414220523238992000000	feat20130313160631825168000000	feat20130313160631838989000000	feat20140414235940714398000000	feat20130313160631853140000000	feat20130313160701732196000000	feat20140414220548835849000000	gf20140414220712732347000000	feat20140414220548011100000000	feat20130313160701735985000000	feat20130313160701958756000000	feat20130313160701962559000000	feat20130313160702017264000000	feat20130313160702031487000000	gf20140414220717927727000000	feat20140414220706997663000000	feat20130313160702063669000000	gf20130226165731802427000000	gf20140414220528548971000000	feat20140701153345008550000000	feat20140414220549562811000000	feat20130313160702133164000000	colisting_office_fax	feat20130313161226461294000000	feat20130313161237397405000000	feat20130313161245231945000000	feat20130313190815074000000000	feat20130313190828603938000000	feat20130313190906773058000000	feat20130313191049996222000000	feat20130313191112947114000000	feat20130313191124503957000000	feat20130313191146449874000000	feat20130313191204391898000000	feat20140414220721850034000000	feat20130313192627063999000000	feat20130604141844269365000000	feat20130604141914741367000000	feat20130612161749389935000000	feat20130612161808434509000000	feat20140224170426923794000000	feat20140224170552840326000000	feat20130614160744525830000000	list_166	feat20140415000109522815000000	feat20130614161127957321000000	feat20130614161349170117000000	feat20130708162140967911000000	feat20130708162212410860000000	feat20140414220532275122000000	feat20130708162638415154000000	feat20130708162659233702000000	gf20130226165731387094000000	gf20130226165731427254000000	gf20130226165731552742000000	feat20140429175459141878000000	gf20130226165731429972000000	gf20130226165731432547000000	gf20130226165731434887000000	list_68	gf20130226165731437450000000	gf20130226165731474849000000	gf20140414220649989072000000	gf20130226165731479786000000	gf20130226165731557326000000	gf20130226165731564034000000	gf20130226165731566769000000	gf20130226165731571198000000	feat20140414220523822053000000	gf20130226165731574189000000	gf20130226165731576538000000	gf20130226165731591186000000	gf20130226165731532980000000	gf20130226165731602719000000	gf20130226180901462976000000	gf20130226181006088052000000	gf20130226181615784641000000	gf20130226183322711092000000	gf20130226183401757426000000	gf20140414220659422928000000	feat20140414220550419627000000	feat20140414220532998503000000	gf20130226183428681591000000	gf20140414220525331054000000	feat20140701195238431043000000	gf20130226183439864246000000	gf20130226183523439532000000	colisting_office_email	gf20130226183625437242000000	gf20130226183651996394000000	feat20140701195229201235000000	feat20140415000018971386000000	gf20130226183722703541000000	feat20140414220548588084000000	gf20140414220548731029000000	gf20130304162857190766000000	gf20130304162857252439000000	gf20130304162857335366000000	gf20130304162857373099000000	gf20130304162857541289000000	gf20130304162857760358000000	feat20140414220523347756000000	feat20140414220549944908000000	gf20130304162857785818000000	gf20130304162858465110000000	gf20130304162858532569000000	gf20130304162858580559000000	feat20140414220647292928000000	gf20130304162858707435000000	coselling_office_fax	colisting_office_url	gf20130304162858760252000000	list_102	gf20130304162858854843000000	gf20130304162858885380000000	feat20140414220523873950000000	gf20130304162858945692000000	gf20130304162858984183000000	gf20130226165731788115000000	feat20140414220548432612000000	gf20130304162859011223000000	gf20130304162859141784000000	feat20140414220550065351000000	feat20140414220548782268000000	gf20130226165731759363000000	feat20140414220523602018000000	feat20140414220548887580000000	gf20130306200652563727000000	gf20130306200706288865000000	feat20140414220550121506000000	gf20130306200748323850000000	gf20130306200811311544000000	feat20140701195246365688000000	gf20130306200853143209000000	gf20140414220535716227000000	gf20130307163524340443000000	gf20130313160629991243000000	gf20130313160630470904000000	gf20140414220656083086000000	gf20130313160630596209000000	gf20140414220548375954000000	gf20130313160631364646000000	gf20130313160631930033000000	lnv_mkting_remarks	gf20130313160632099768000000	gf20130313160632288140000000	gf20130313160632432737000000	gf20130313160632471914000000	feat20140224170701990558000000	gf20130313160632499631000000	gf20130313160632632644000000	list_157	gf20130313160701087172000000	gf20130313160701230816000000	gf20130313160701309776000000	gf20130313160701380862000000	gf20130313160701439929000000	gf20130313160701550178000000	gf20130313160701663397000000	gf20130313160701687658000000	gf20130313160701761964000000	gf20130313160701860449000000	gf20130313160702141121000000	gf20130313160702258186000000	gf20130313160702301802000000	gf20130313160702382495000000	feat20140414220551395942000000	gf20130313160702405956000000	gf20130313160702462897000000	gf20130313160702493319000000	feat20140415005201539058000000	feat20140414220655038187000000	gf20130313160702569820000000	gf20130313160702630730000000	gf20130313160702672864000000	gf20130313160702700206000000	feat20140414220532114092000000	gf20130313160702830745000000	gf20130313162111126800000000	gf20140414220547949278000000	feat20140701195157528815000000	gf20140414220542085309000000	gf20130313162138419721000000	gf20130313162509346678000000	gf20130313162526237784000000	gf20130313162539308166000000	gf20130313162605183406000000	feat20141222203726013616000000	feat20140224204532686584000000	gf20130313192250062794000000	gf20130313201301289976000000	gf20130313202052440770000000	gf20140414220532366276000000	gf20130313202405130588000000	gf20130313203958104166000000	feat20140224204709682181000000	list_151	gf20130604154546211961000000	gf20130604183058509522000000	gf20130604202930078590000000	list_143	gf20130604202940710553000000	feat20140414220550369130000000	gf20130604203750505027000000	gf20130606024608499268000000	gf20140414220647836418000000	feat20140414220549004483000000	gf20130611133802518156000000	gf20130612141103459183000000	gf20130612141114419516000000	list_150	list_163	feat20140414220523717587000000	gf20130614153345482319000000	gf20130618140532666471000000	gf20130702134753249824000000	list_161	feat20140701195220713160000000	gf20130702135847480250000000	feat20140416135946405380000000	gf20130702135916588997000000	gf20130702140004488300000000	list_0	list_1	list_10	list_101	list_104	feat20140414220523551316000000	list_105	list_106	list_107	list_108	list_11	list_110	feat20140224204719275631000000	list_112	list_113	gf20130226165731534992000000	colisting_office_phone	list_114	list_115	list_117	gf20130226165731771450000000	list_118	list_119	list_148	list_127	list_12	list_120	list_121	list_122	list_123	list_124	gf20130226165731807491000000	list_125	list_126	list_13	list_130	gf20140414220513458765000000	list_131	list_132	gf20130226165731505034000000	list_133	feat20140414220523500242000000	gf20140414220519013612000000	list_134	list_135	list_137	gf20140414220550629381000000	list_14	list_15	coselling_office_email	list_16	list_17	list_18	list_19	list_2	list_20	list_21	list_22	feat20140224204638572445000000	list_23	list_27	list_28	list_29	list_3	list_30	gf20140414220517659562000000	list_149	list_31	gf20130226165731766486000000	list_33	list_34	list_35	gf20140414220545550479000000	list_37	feat20140414220523768084000000	gf20140416130708540657000000	feat20140414220532006086000000	list_39	feat20140415000128045727000000	list_4	list_40	colisting_office_address	coselling_office_phone	list_41	gf20140415134650813652000000	list_43	feat20140224204427868806000000	list_46	list_47	list_48	list_49	list_5	list_51	list_52	list_53	list_54	gf20140414220656848947000000	gf20140414220509072562000000	list_56	feat20140414220648593620000000	list_57	list_58	list_59	list_6	list_60	list_61	list_62	list_63	list_65	list_66	list_67	list_69	feat20140414220548638249000000	list_7	list_71	gf20140414220549462281000000	feat20140414220523448826000000	list_72	list_73	list_74	list_75	list_76	list_77	list_78	gf20140429175458080985000000	list_79	list_8	list_80	feat20140414220549625783000000	list_81	list_82	list_83	feat20140414220535930564000000	feat20140414220532169539000000	list_84	list_85	list_86	list_162	list_87	list_88	list_9	list_90	list_91	feat20140414220548536969000000	feat20140414220523290371000000	gf20130226165731493841000000	list_92	list_93	list_95	list_97	listing_member_address	listing_member_email	listing_member_fax	listing_member_name	listing_member_phone	listing_member_shortid	listing_member_url	feat20140414220549514537000000	listing_office_address	listing_office_email	listing_office_fax	listing_office_name	listing_office_phone	listing_office_shortid	listing_office_url	room_b1_room_length	room_b1_room_width	room_ba_room_length	room_ba_room_width	room_br1_room_length	room_br1_room_width	room_br2_room_length	room_br2_room_rem	room_br2_room_width	room_br3_room_length	room_br3_room_rem	room_br3_room_width	gf20130226165731791149000000	feat20140224204615069880000000	room_br4_room_length	room_br4_room_rem	room_br4_room_width	room_dn_room_length	list_116	gf20140414220549892720000000	room_dn_room_rem	feat20140414220548484841000000	room_dn_room_width	coselling_office_address	room_fr_room_length	room_fr_room_rem	feat20140414220548939264000000	gf20140429175504549256000000	room_fr_room_width	room_ki_room_length	list_64	room_ki_room_rem	feat20140414220550319212000000	room_ki_room_width	room_lv_room_length	room_lv_room_rem	room_lv_room_width	room_mb_room_length	room_mb_room_rem	room_mb_room_width	room_or1_room_length	feat20140414220700746231000000	room_or1_room_width	feat20140414220646349622000000	room_ot1_room_length	room_ot1_room_rem	room_ot1_room_width	room_pr_room_length	room_pr_room_rem	feat20140414220548148773000000	room_pr_room_width	room_pt_room_length	room_pt_room_rem	room_pt_room_width	selling_member_address	selling_member_email	selling_member_fax	list_36	selling_member_name	selling_member_phone	coselling_office_shortid	selling_member_shortid	selling_member_url	selling_office_address	selling_office_email	selling_office_fax	coselling_office_url	selling_office_name	selling_office_phone	selling_office_shortid	selling_office_url	unbrandedidxvirtualtour	feat20140224204701214502000000	feat20141222203623758141000000	",chr(9));
this.arrFieldLookupFields=[];
this.mls_provider="rets22";
variables.resourceStruct=structnew();
variables.resourceStruct["property"]=structnew();
variables.resourceStruct["property"].resource="property";
variables.resourceStruct["property"].id="list_105";
this.emptyStruct=structnew();
variables.resourceStruct["office"]=structnew();
variables.resourceStruct["office"].resource="office";
variables.resourceStruct["office"].id="office_0";
variables.resourceStruct["agent"]=structnew();
variables.resourceStruct["agent"].resource="activeagent";
variables.resourceStruct["agent"].id="member_0";

this.arrTypeLoop=listtoarray("A,B,C,D,F,G");//E,
variables.tableLookup=structnew();
variables.tableLookup["A"]="A";
variables.tableLookup["B"]="B";
variables.tableLookup["C"]="C";
variables.tableLookup["D"]="D"; // this one was actually blank
//variables.tableLookup["E"]="E";  // missing
variables.tableLookup["F"]="F";
variables.tableLookup["G"]="G";


/*
t5=structnew();

t5["county"]=structnew();

t5["countyreverse"]=structnew();
for(n in t5["county"]){
t5["countyreverse"][t5["county"][n]]=n;
}



t5["style"]=structnew();


t5["frontage"]=structnew();



t5["subtypeid"]=structnew();


t5["typeid"]=structnew();

t5["view"]=structnew();


t5["county"].lookupfield="county";
t5["frontage"].lookupfield="frontage";
t5["subtypeid"].lookupfield="sub_type_id";
t5["typeid"].lookupfield="type_id";
t5["style"].lookupfield="style";
t5["view"].lookupfield="view";
this.remapFieldStruct=t5;
*/
</cfscript> 

<cffunction name="initImport" localmode="modern" output="no" returntype="any">
	<cfargument name="resource" type="string" required="yes">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var local=structnew();
	var qZ=0;
	super.initImport(arguments.resource, arguments.sharedStruct);
	
	arguments.sharedStruct.lookupStruct.cityRenameStruct=structnew();
	</cfscript>
</cffunction>

<cffunction name="parseRawData" localmode="modern" output="yes" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	
	var db=request.zos.queryObject;
	var columnIndex=structnew();
	var a9=arraynew(1); 
	if(structcount(this.emptyStruct) EQ 0){
		for(i=1;i LTE arraylen(this.arrColumns);i++){
			this.emptyStruct[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[this.arrColumns[i]].longname]="";
		}
	} 
	ts=duplicate(this.emptyStruct);
	if(arraylen(arguments.ss.arrData) NEQ arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
		echo('Column count doesn''t match data.');
		application.zcore.functions.zdump(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);
		application.zcore.functions.zdump(arguments.ss.arrData);
		application.zcore.functions.zabort();
	}  
	if(arraylen(arguments.ss.arrData) LT arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns)){
		application.zcore.template.fail("RETS#this.mls_id#: This row was not long enough to contain all columns: "&application.zcore.functions.zparagraphformat(arraytolist(arguments.ss.arrData,chr(10)))&""); 
	}
	// this is the first column
	a=application.zcore.listingStruct.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns;
	b=arguments.ss.arrData;
	for(i=1;i LTE arraylen(arguments.ss.arrData);i++){
		ts[a[i]]=b[i];
		columnIndex[a[i]]=i;
	}
	local.listing_parking="";
	tempStyle="";
	tempStyle2="";
	tempStyle3="";
	for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
		column=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i];
		shortColumn=removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7);
		fieldName=this.getRETSFieldName("property", ts["rets22_list_8"], shortColumn); 
		if(fieldName EQ "Parking"){
			local.listing_parking=this.listingLookupNewId("parking",ts[column]);
		}else if(fieldName EQ "Style"){
			tempStyle=ts[column];
		}else if(fieldName EQ "Waterfront Type"){
			tempStyle2=ts[column];
		}else if(fieldName EQ "Waterfront Type"){
			tempStyle2=ts[column];
		}else if(fieldName EQ "Dwelling View'"){
			tempStyle3=ts[column]; 
		}
		ts[fieldName]=this.getRetsValue("property", ts["rets22_list_8"], shortColumn, ts[column]);
	} 


	if(not structkeyexists(ts, "rets22_list_22") or ts["rets22_list_22"] EQ ""){
		ts["rets22_list_22"]=replace(ts["original list price"],",","","ALL");
	}else{
		ts["rets22_list_22"]=replace(ts["rets22_list_22"],",","","ALL");
	} 
	// need to clean this data - remove not in subdivision, 0 , etc.
	
	local.listing_subdivision=ts['Subdivision/Condo Name'];
	if(local.listing_subdivision NEQ ""){
		if(findnocase(","&local.listing_subdivision&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			local.listing_subdivision="";
		}else{
			local.listing_subdivision=application.zcore.functions.zFirstLetterCaps(local.listing_subdivision);
		}
	}  
	
	this.price=ts["rets22_list_22"];
	local.listing_price=ts["rets22_list_22"];
	cityName="";
	cid=0;
	ts["rets22_list_40"]="FL"; 
	if(structkeyexists(request.zos.listing.cityStruct, ts["city"]&"|"&ts["rets22_list_40"])){
		cid=request.zos.listing.cityStruct[ts["city"]&"|"&ts["rets22_list_40"]];
	}
	//writeoutput(cid&"|"&ts["city"]&"|"&ts["rets22_list_40"]); 
	if(cid EQ 0 and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct, ts['zip code'])){
		cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct[ts['zip code']];
		ts["city"]=listgetat(cityName,1,"|");
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["rets22_list_40"])){
			cid=request.zos.listing.cityStruct[cityName&"|"&ts["rets22_list_40"]];
		}
	}
	local.listing_county=this.listingLookupNewId("county",ts['rets22_list_43']);
	

	local.listing_sub_type_id=this.listingLookupNewId("listing_sub_type",ts['rets22_list_9']);
	
	local.listing_type_id=this.listingLookupNewId("listing_type",ts['rets22_list_8']);

	ad=ts['street ##'];
	if(ad NEQ 0){
		address="#ad# ";
	}else{
		address="";	
	} 
	address&=application.zcore.functions.zfirstlettercaps(ts['Street Dir']&" "&ts['street name']&" "&ts['street suffix']);
	curLat=ts["rets22_list_46"];
	curLong=ts["rets22_list_47"];
	if(curLat EQ "" and trim(address) NEQ ""){
		rs5=this.baseGetLatLong(address,ts['rets22_list_40'],ts['zip code'], arguments.ss.listing_id);
		curLat=rs5.latitude;
		curLong=rs5.longitude;
	}
	
	if(ts['Unit ##'] NEQ ''){
		address&=" Unit: "&ts["Unit ##"];	
	}else if(ts['Condo Unit ##'] NEQ ''){
		address&=" Unit: "&ts["Condo Unit ##"];
	}
	
	 
	
	s2=structnew();
	liststatus=ts["status"];
	if(liststatus EQ "Active"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["active"]]=true;
	}else if(liststatus EQ "Withdrawn"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["withdrawn"]]=true;
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
	}else if(liststatus EQ "Cancelled"){
		s2[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.liststatusStr["cancelled"]]=true;
	}
	local.listing_liststatus=structkeylist(s2,",");
	
	arrT3=[];
	uns=structnew();
	tmp=tempStyle;
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
	tmp=tempStyle2;
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
	tmp=tempStyle3;
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
	pt={
		"A":{
			key:"rets22_GF20130226165731566769000000",
			data:{
				"15373EEHYRPV":true, 
				"1536QBSXEUN4":true, 
				"1536QBSWLBCA":true
			}
		},
		"B":{
			key:"rets22_GF20130304162858707435000000",
			data:{
				"156ZJMT9EDPD":true,
				"156ZJMTK17WU":true,
				"156ZJMTUERQ3":true
			}
		},
		"D":{
			key:"rets22_GF20130313160702258186000000",
			data:{
				"1541KGQNC9FJ":true,
				"1541KGQNBTVG":true,
				"1541KGQNC05P":true,
				"1541KGQNC6C2":true
			}
		}
	};
	local.listing_pool=0;
	for(i in pt){
		if(i EQ ts.rets22_list_8){
			arrPool=listtoarray(ts[pt[i].key], ",");
			for(n=1;n LTE arraylen(arrPool);n++){
				if(structkeyexists(pt[i].data, arrPool[n])){
					local.listing_pool=1;
					break;
				}
			}
		}
	}
			
	//if(structkeyexists(variables.tableLookup,ts.rets22_list_8)){
		//  ts["rets22_list_8"]
		ts=this.convertRawDataToLookupValues(ts, ts["rets22_list_8"], ts["rets22_list_8"]);//variables.tableLookup[ts.rets22_list_8]);
	//}
	
	ts2=structnew();
	ts2.field="";
	ts2.yearbuiltfield=ts['year built'];
	ts2.foreclosureField="";
	
	s=this.processRawStatus(ts2);
	
	if(ts["rets22_list_8"] EQ "D"){//structkeyexists(ts, 'Rental Price') and ts['Rental Price'] NEQ ""){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
	}else{
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
	} 
	if(structkeyexists(ts, 'rets22_list_71')){
		if(ts['rets22_list_71'] CONTAINS 'hud'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["hud"]]=true;
		}
		if(ts['rets22_list_71'] CONTAINS 'relo company'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["relo company"]]=true;
		}
		if(ts['rets22_list_71'] CONTAINS 'auction'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["auction"]]=true;
		}
		if(ts['rets22_list_71'] CONTAINS 'bank owned'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}
		if(ts['rets22_list_71'] CONTAINS 'short sale'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}   
	}
	local.listing_status=structkeylist(s,",");
	
	local.arrRoom=listToArray('room_br2_room,room_br3_room,room_br4_room,room_dn_room,room_fr_room,room_ki_room,room_lv_room,room_mb_room,room_ot1_room,room_pr_room,room_pt_room,room_b1_room,room_ba_room,room_br1_room,room_br2_room,room_br3_room,room_br4_room,room_dn_room,room_fr_room,room_ki_room,room_lv_room,room_or1_room', ',');
	for(i=1;i LTE arraylen(local.arrRoom);i++){
		if(structkeyexists(ts, "rets22_"&local.arrRoom[i]&"_length") and ts["rets22_"&local.arrRoom[i]&"_length"] NEQ ""){
			ts["rets22_"&local.arrRoom[i]&"_length"]=ts["rets22_"&local.arrRoom[i]&"_width"]&"x"&ts["rets22_"&local.arrRoom[i]&"_length"];
		}
	}
	dataCom=this.getRetsDataObject();
	local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
	local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
	local.listing_data_detailcache3=dataCom.getDetailCache3(ts);
	
	rs=structnew();
	rs.listing_id=arguments.ss.listing_id;
	if(structkeyexists(ts, "acreage")){
		rs.listing_acreage=ts["Acreage"];
	}else if(structkeyexists(ts, 'acres')){
		rs.listing_acreage=ts["Acres"];
	}
	if(structkeyexists(ts, "Baths")){
		rs.listing_baths=ts["Baths"];
	}else if(structkeyexists(ts, 'Baths - Total')){
		rs.listing_baths=ts["Baths - Total"];
	}else{
		rs.listing_baths='';
	}
	rs.listing_halfbaths=ts["Baths - Half"];
	rs.listing_beds=ts["Bedrooms"];
	rs.listing_city=cid;
	rs.listing_county=local.listing_county;
	rs.listing_frontage=","&local.listing_frontage&",";
	rs.listing_frontage_name="";
	rs.listing_price=ts["rets22_list_22"];
	rs.listing_status=","&local.listing_status&",";
	rs.listing_state=ts["rets22_list_40"];
	rs.listing_type_id=local.listing_type_id;
	rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
	rs.listing_style=","&local.listing_style&",";
	rs.listing_view=","&local.listing_view&",";

	// list_48 is living for A yes
	// list_49 is total for a
	// income B is list_48 total
	// not needed unless 48/49 is empty: list_52 for D ,C, B and A is lot sqft
	// list_49 is living for B income
	// D list_48 - living
	// D list_49 = total

	// F list_48 - total

	// G list_48 lease area (living)

	// list_52 is total for A
	if(ts.rets22_list_8 EQ "A" or ts.rets22_list_8 EQ "D" or ts.rets22_list_8 EQ "G" or ts.rets22_list_8 EQ "C"){
		rs.listing_lot_square_feet="";
		if(structkeyexists(ts, "rets22_list_48")){
			rs.listing_square_feet=ts["rets22_list_48"];
		}
		rs.listing_lot_square_feet="";
		if(structkeyexists(ts, "rets22_list_49")){
			rs.listing_lot_square_feet=ts["rets22_list_49"]; 
		}
		if(rs.listing_lot_square_feet EQ "" and structkeyexists(ts, "rets22_list_52")){ 
			rs.listing_lot_square_feet=ts["rets22_list_52"];
		}
	}else{
		rs.listing_lot_square_feet="";
		if(structkeyexists(ts, "rets22_list_49")){
			rs.listing_square_feet=ts["rets22_list_49"];
		}
		rs.listing_lot_square_feet="";
		if(structkeyexists(ts, "rets22_list_48")){
			rs.listing_lot_square_feet=ts["rets22_list_48"]; 
		}
		if(rs.listing_lot_square_feet EQ "" and structkeyexists(ts, "rets22_list_52")){ 
			rs.listing_lot_square_feet=ts["rets22_list_52"];
		}
	} 
	rs.listing_subdivision=local.listing_subdivision;
	rs.listing_year_built=application.zcore.functions.zso(ts, "rets22_list_53");
	rs.listing_office=ts["rets22_list_106"];
	rs.listing_office_name=ts["rets22_listing_office_name"];
	rs.listing_agent=ts["rets22_list_5"];
	rs.listing_latitude=curLat;
	rs.listing_longitude=curLong;
	rs.listing_pool=local.listing_pool;
	rs.listing_photocount=ts["rets22_list_133"];
	rs.listing_coded_features="";
	rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
	rs.listing_primary="0";
	rs.listing_mls_id=arguments.ss.listing_mls_id;
	rs.listing_address=trim(address);
	rs.listing_zip=ts["zip code"];
	rs.listing_condition="";
	rs.listing_parking=local.listing_parking;
	rs.listing_region="";
	rs.listing_tenure="";
	rs.listing_liststatus=local.listing_liststatus;
	rs.listing_data_remarks=ts["Narrative"];
	rs.listing_data_address=trim(address);
	rs.listing_data_zip=trim(ts["zip code"]);
	rs.listing_data_detailcache1=local.listing_data_detailcache1;
	rs.listing_data_detailcache2=local.listing_data_detailcache2;
	rs.listing_data_detailcache3=local.listing_data_detailcache3; 


	rs.listing_track_sysid=ts["rets22_list_1"];
	//writedump(rs);abort;
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
	request.lastPhotoId=idx.listing_id;
	if(idx.listing_photocount EQ 0){
		idx["photo1"]='/z/a/listing/images/image-not-available.gif';
	}else{
		i=1;
		for(i=1;i LTE idx.listing_photocount;i++){
			local.fNameTemp1="22-"&idx.urlMlsPid&"-"&i&".jpeg";
			local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
			idx["photo"&i]=request.zos.retsPhotoPath&'22/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
		}
	} 
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
		
	idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets22_unbrandedidxvirtualtour");
	idx["zipcode"]=arguments.ss["listing_zip"];
	idx["maintfees"]="";
	/*if(arguments.ss["rets#this.mls_id#_FEAT20130612195730582842000000"] NEQ ""){
		idx["maintfees"]=arguments.ss["rets#this.mls_id#_FEAT20130612195730582842000000"];
	}*/
	
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
	local.fNameTemp1="22-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
	local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
	return request.zos.retsPhotoPath&'22/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
	
	</cfscript>
</cffunction>
	
<cffunction name="getLookupTables" localmode="modern" access="public" output="no" returntype="struct">
	<cfscript> 
	var arrSQL=[]; 
	var arrError=[]; 
	var db=request.zos.queryObject; 
	var cityCreated=false; 
	fd=structnew();
	fd["A"]="Residential";
	fd["B"]="Multi-Family";
	fd["C"]="Vacant Land";
	fd["D"]="Rental"; // this one was actually blank
	//fd["E"]="Common Interest";
	fd["F"]="Commercial For Sale";
	fd["G"]="Commercial For Lease";
	// need to index type, county, style, view, parking, frontage for F and G still.
	for(i in fd){
		i2=i;
		if(i2 NEQ ""){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
	}
	for(g=1;g LTE arraylen(this.arrTypeLoop);g++){
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"list_41");
		for(i in fd){
			i2=i;
			arrayappend(arrSQL,"('#this.mls_provider#','county','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		} 
	
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"LIST_9"); 
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		
		// style
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130226165731387094000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130306200748323850000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313160701380862000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130325004325380721000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313160719015644000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		/*
		// subdivision
		fd=this.getRETSValues("property","LIST_77");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','subdivision','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		*/
		// parking
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130226165731576538000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313160719925404000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313160702301802000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130304162858580559000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(i2)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		} 
		
		
		
		
		
		

		
		
		// frontage
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313162509346678000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(tmp)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130702134753249824000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(tmp)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130702135847480250000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(tmp)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130702135916588997000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(tmp)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130702140004488300000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(tmp)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130226165731552742000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','frontage','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(tmp)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		
		
		// view
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130313160701309776000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(tmp)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20130226165731564034000000");
		for(i in fd){
			tmp=i;
			arrayappend(arrSQL,"('#this.mls_provider#','view','#application.zcore.functions.zescape(fd[i])#','#application.zcore.functions.zescape(tmp)#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		} 

		
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"list_39"); 
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
				//arrayappend(arrC,application.zcore.functions.zescape(application.zcore.functions.zFirstLetterCaps(fd[i])));
				 db.sql="select * from #db.table("city", request.zos.zcoreDatasource)# city 
				WHERE city_name =#db.param(fd[i])# and 
				state_abbr=#db.param(tempState)# and 
				city_deleted = #db.param(0)# ";
				qD=db.execute("qD");
				if(qD.recordcount EQ 0){
					/*
					//writeoutput(fd[i]&" missing<br />");
					 db.sql="select	* from #db.table("zipcode", request.zos.zcoreDatasource)# zipcode 
					WHERE city_name =#db.param(fd[i])# and 
					state_abbr=#db.param(tempState)# and 
					zipcode_deleted = #db.param(0)#";
					qZ=db.execute("qZ");
					if(qZ.recordcount NEQ 0){*/
						 db.sql="INSERT INTO #db.table("city", request.zos.zcoreDatasource)#  
						 SET city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
						 state_abbr=#db.param(tempState)#,
						 country_code=#db.param('US')#, 
						 city_mls_id=#db.param(i)#,
						 city_deleted=#db.param(0)#,
					 	city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
						 local.result=db.insert("q"); 
						 db.sql="INSERT INTO #db.table("city_memory", request.zos.zcoreDatasource)#  
						 SET city_id=#db.param(local.result.result)#, 
						 city_name=#db.param(application.zcore.functions.zfirstlettercaps(fd[i]))#, 
						 state_abbr=#db.param(tempState)#,
						 country_code=#db.param('US')#, 
						 city_mls_id=#db.param(i)#,
						 city_deleted=#db.param(0)#,
						 city_updated_datetime=#db.param(request.zos.mysqlnow)# ";
						 db.execute("q");
						//writeoutput(qId.city_id);
						cityCreated=true; // need to run zipcode calculations
						/*
					}else{
						failStr&=("<a href=""http://maps.google.com/maps?q=#urlencodedformat(fd[i]&', florida')#"" rel=""external"" onclick=""window.open(this.href); return false;"">#fd[i]#, florida</a> is missing in `#request.zos.zcoreDatasource#`.zipcode.<br />");
					}*/
				}
			}
			
			arrayClear(request.zos.arrQueryLog);
		}
	}
	return {arrSQL:arrSQL, cityCreated:cityCreated, arrError:arrError};
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>