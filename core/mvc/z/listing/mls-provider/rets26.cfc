<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
<cfscript>
this.retsVersion="1.7";

this.mls_id=26;
if(request.zos.istestserver){
	variables.hqPhotoPath="#request.zos.sharedPath#mls-images/26/";
}else{
	variables.hqPhotoPath="#request.zos.sharedPath#mls-images/26/";
}
this.useRetsFieldName="system";
this.arrTypeLoop=["A","B","C","D", "F", "G"];
this.arrColumns=listtoarray("BOARDCODE,colisting_member_address,colisting_member_email,colisting_member_fax,colisting_member_name,colisting_member_phone,colisting_member_shortid,colisting_member_url,colisting_office_address,colisting_office_email,colisting_office_fax,colisting_office_name,colisting_office_phone,colisting_office_shortid,colisting_office_url,coselling_member_address,coselling_member_email,coselling_member_fax,coselling_member_name,coselling_member_phone,coselling_member_shortid,coselling_member_url,coselling_office_address,coselling_office_email,coselling_office_fax,coselling_office_name,coselling_office_phone,coselling_office_shortid,coselling_office_url,FEAT20141229145118055494000000,FEAT20141229145138164152000000,FEAT20141229145153687439000000,FEAT20141229145427455062000000,FEAT20141229145440616012000000,FEAT20141229145502644200000000,FEAT20141229145547454159000000,FEAT20141229145606182757000000,FEAT20141229150212708273000000,FEAT20141229150230241806000000,FEAT20141229150326562731000000,FEAT20141229150352900748000000,FEAT20141229150421297114000000,FEAT20141229150431193331000000,FEAT20141229150451463764000000,FEAT20141229150515105932000000,FEAT20141229150534994153000000,FEAT20141229150558923570000000,FEAT20141229150619157422000000,FEAT20141229150638493647000000,FEAT20141229150702524631000000,FEAT20141229150817086141000000,FEAT20141229150844131789000000,FEAT20141229150900997734000000,FEAT20141229150911265922000000,FEAT20141229150931601578000000,FEAT20150108165630073273000000,FEAT20150108165650554083000000,FEAT20150108165710733602000000,FEAT20150108165737145587000000,FEAT20150108165754408943000000,FEAT20150108170645439801000000,FEAT20150108170714327492000000,FEAT20150108170743177653000000,FEAT20150217140738268585000000,FEAT20150217140820531605000000,FEAT20150217140916630551000000,FEAT20150217140933740240000000,FEAT20150217140957054142000000,FEAT20150217141012916898000000,FEAT20150217141032420230000000,FEAT20150217141050083464000000,FEAT20150217141106131358000000,FEAT20150217141135359138000000,FEAT20150217141147340887000000,FEAT20150217141201409162000000,FEAT20150217141222499515000000,FEAT20150217142108716323000000,FEAT20150217142127345119000000,FEAT20150217142144057732000000,FEAT20150217142201131993000000,FEAT20150217142212556354000000,FEAT20150217142225502383000000,FEAT20150217142239583032000000,FEAT20150217142312067832000000,FEAT20150217142337197693000000,FEAT20150217142411557889000000,FEAT20150217142431106706000000,FEAT20150217145137635735000000,FEAT20150217145626241677000000,FEAT20150217145852154211000000,FEAT20150217145927809817000000,GF20141226230259827496000000,GF20141226230311380539000000,GF20141226230324959029000000,GF20141226230335404830000000,GF20141226230405195560000000,GF20141226230416743766000000,GF20141226230426862688000000,GF20141226230444683855000000,GF20141226230458968493000000,GF20141226230513688158000000,GF20141226230530523380000000,GF20141227001224390986000000,GF20141227001311156424000000,GF20141227001326295145000000,GF20141227001344053028000000,GF20141227001528056321000000,GF20141227001543899079000000,GF20141227001555393624000000,GF20141227001731140343000000,GF20141227001748539984000000,GF20141227001804189977000000,GF20141227001822456749000000,GF20141227001833876907000000,GF20141227001849499306000000,GF20141227001902268272000000,GF20141227001925179813000000,GF20141227001940123830000000,GF20141227002720558708000000,GF20141227192834057254000000,GF20141227192834317267000000,GF20141227192834666082000000,GF20141227192835088770000000,GF20141227192835969249000000,GF20141227192836583087000000,GF20141227192837165022000000,GF20141227192837801758000000,GF20141227192838320884000000,GF20141227192838985297000000,GF20141227192839454070000000,GF20141227192839779357000000,GF20141227192840262031000000,GF20141227192840945324000000,GF20141227192841845016000000,GF20141227192842483375000000,GF20141227192843436684000000,GF20141227192844323514000000,GF20141227192844574139000000,GF20141227192845246339000000,GF20141227192846024680000000,GF20141227192846650034000000,GF20141227192847200678000000,GF20141227192847415428000000,GF20141227192847903634000000,GF20141227192848538703000000,GF20141227192849327292000000,GF20141227192849848869000000,GF20141227193410300025000000,GF20141227193410727401000000,GF20141227193412356482000000,GF20141227193413674607000000,GF20141227193415617007000000,GF20141227193416451569000000,GF20141227193417138040000000,GF20141227193418087637000000,GF20141227193420780210000000,GF20141227193421492461000000,GF20141227193422151879000000,GF20141227193423364613000000,GF20141227193423763336000000,GF20141227193424267068000000,GF20141227193424857651000000,GF20141227193425333350000000,GF20141227193546701063000000,GF20141227193548494838000000,GF20141227193549092607000000,GF20141227193549712759000000,GF20141227193551462863000000,GF20141227193552219738000000,GF20141227193556888800000000,GF20141227193558750386000000,GF20141227193559134378000000,GF20141227194557132723000000,GF20141227194620250823000000,GF20141227194656448898000000,GF20141227194819652551000000,GF20141227194850136354000000,GF20141227194901735001000000,GF20141227194925318751000000,GF20141227195028677239000000,GF20141227195128500758000000,GF20141227195245871670000000,GF20141227195308633273000000,GF20141227195320847948000000,GF20150107140547074282000000,GF20150107140549889252000000,GF20150107140555547865000000,GF20150107140556308462000000,GF20150107140556859169000000,GF20150107140558302722000000,GF20150107201859464523000000,GF20150107201916072541000000,GF20150107201927432439000000,GF20150107201947930749000000,GF20150113144548552928000000,GF20150113144559808305000000,GF20150113144629066331000000,GF20150113144638235722000000,GF20150113144647743453000000,GF20150113203800450795000000,GF20150113203813169264000000,GF20150113203825119434000000,GF20150113203837017118000000,GF20150113203850400754000000,GF20150217135449359725000000,GF20150217135649410135000000,LIST_0,LIST_1,LIST_10,LIST_104,LIST_105,LIST_106,LIST_107,LIST_108,LIST_109,LIST_11,LIST_110,LIST_111,LIST_112,LIST_113,LIST_114,LIST_117,LIST_118,LIST_119,LIST_12,LIST_120,LIST_121,LIST_122,LIST_123,LIST_124,LIST_125,LIST_126,LIST_127,LIST_13,LIST_130,LIST_131,LIST_132,LIST_133,LIST_134,LIST_135,LIST_137,LIST_14,LIST_140,LIST_141,LIST_142,LIST_143,LIST_144,LIST_145,LIST_146,LIST_147,LIST_148,LIST_149,LIST_15,LIST_150,LIST_151,LIST_152,LIST_153,LIST_154,LIST_155,LIST_156,LIST_157,LIST_158,LIST_159,LIST_16,LIST_161,LIST_162,LIST_163,LIST_165,LIST_166,LIST_167,LIST_168,LIST_17,LIST_177,LIST_18,LIST_19,LIST_2,LIST_21,LIST_22,LIST_23,LIST_28,LIST_29,LIST_3,LIST_31,LIST_33,LIST_34,LIST_35,LIST_36,LIST_37,LIST_39,LIST_4,LIST_40,LIST_41,LIST_43,LIST_44,LIST_45,LIST_46,LIST_47,LIST_48,LIST_49,LIST_5,LIST_52,LIST_53,LIST_56,LIST_57,LIST_58,LIST_59,LIST_6,LIST_60,LIST_61,LIST_62,LIST_63,LIST_65,LIST_66,LIST_67,LIST_69,LIST_7,LIST_73,LIST_74,LIST_75,LIST_76,LIST_77,LIST_78,LIST_8,LIST_80,LIST_81,LIST_82,LIST_86,LIST_87,LIST_88,LIST_89,LIST_9,LIST_90,LIST_91,LIST_92,LIST_93,LIST_94,LIST_95,LIST_96,LIST_97,listing_member_address,listing_member_email,listing_member_fax,listing_member_name,listing_member_phone,listing_member_shortid,listing_member_url,listing_office_address,listing_office_email,listing_office_fax,listing_office_name,listing_office_phone,listing_office_shortid,listing_office_url,ROOM_BR1_room_length,ROOM_BR1_room_level,ROOM_BR2_room_length,ROOM_BR2_room_level,ROOM_BR3_room_length,ROOM_BR3_room_level,ROOM_BR4_room_length,ROOM_BR4_room_level,ROOM_DO_room_length,ROOM_DO_room_level,ROOM_DR_room_length,ROOM_DR_room_level,ROOM_FL_room_length,ROOM_FL_room_level,ROOM_FR_room_length,ROOM_FR_room_level,ROOM_KT_room_length,ROOM_KT_room_level,ROOM_LR_room_length,ROOM_LR_room_level,ROOM_MR_room_length,ROOM_MR_room_level,ROOM_PB_room_length,ROOM_PB_room_level,ROOM_PD_room_length,ROOM_PD_room_level,ROOM_UR_room_length,ROOM_UR_room_level,selling_member_address,selling_member_email,selling_member_fax,selling_member_name,selling_member_phone,selling_member_shortid,selling_member_url,selling_office_address,selling_office_email,selling_office_fax,selling_office_name,selling_office_phone,selling_office_shortid,selling_office_url,SYND_LIST_REF_URL,UNBRANDEDIDXVIRTUALTOUR,feat20200615231851990402000000",",");
this.arrFieldLookupFields=[];
this.mls_provider="rets26";
variables.resourceStruct=structnew();
variables.resourceStruct["property"]=structnew();
variables.resourceStruct["property"].resource="property";
variables.resourceStruct["property"].id="list_105";
// list_1 is the sysid
this.emptyStruct=structnew();
variables.resourceStruct["office"]=structnew();
variables.resourceStruct["office"].resource="office";
variables.resourceStruct["office"].id="office_0";
variables.resourceStruct["agent"]=structnew();
variables.resourceStruct["agent"].resource="activeagent";
variables.resourceStruct["agent"].id="member_0";

variables.tableLookup=structnew();
variables.tableLookup["A"]="A";
variables.tableLookup["B"]="B";
variables.tableLookup["C"]="C";
variables.tableLookup["D"]="D";  
variables.tableLookup["F"]="F";
variables.tableLookup["G"]="G"; 

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
	var rs5=0;
	var r222=0;
	var values="";
	var newlist="";
	var i=0;
	var columnIndex=structnew();
	var cityname=0;
	var cid=0;
	var a9=arraynew(1);
	var ts=0;
	var col=0;
	var tmp=0;
	var uns=0;
	var arrt3=0;
	var address=0;
	var arrt2=0;
	var datacom=0;
	var ad=0;
	var liststatus=0;
	var s2=0;
	var curlat=0;
	var curlong=0;
	var ts2=0;
	var s=0;
	var arrT=0;
	var rs=0;
	
	var db=request.zos.queryObject;
	if(structcount(this.emptyStruct) EQ 0){
		for(i=1;i LTE arraylen(this.arrColumns);i++){
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
	for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
		col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
		ts["rets26_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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
	if(not structkeyexists(ts, "list price")){
		ts["list price"]=replace(ts["original list price"],",","","ALL");
	}else{
		ts["list price"]=replace(ts["list price"],",","","ALL");
	}
	// need to clean this data - remove not in subdivision, 0 , etc.
	subdivision="";
	if(application.zcore.functions.zso(ts, "Subdivision/Condo Name") NEQ ""){
		subdivision=ts["Subdivision/Condo Name"];
	}else if(application.zcore.functions.zso(ts, "Subdivision") NEQ ""){
		subdivision=ts["Subdivision"]; 
	}
	
	local.listing_subdivision=this.getRetsValue("property", ts["rets26_list_8"], "LIST_77", subdivision);
	if(local.listing_subdivision NEQ ""){
		if(findnocase(","&local.listing_subdivision&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			local.listing_subdivision="";
		}else{
			local.listing_subdivision=application.zcore.functions.zFirstLetterCaps(local.listing_subdivision);
		}
	} 
	ts['zip code']=this.getRetsValue("property", ts["rets26_list_8"], "LIST_43",ts['zip code']); 
	
	this.price=ts["list price"];
	local.listing_price=ts["list price"];
	cityName="";
	cid=0;
	ts['city']=this.getRetsValue("property", ts["rets26_list_8"], "LIST_39", ts['city']);
	ts['state/Province']=this.getRetsValue("property", ts["rets26_list_8"], "LIST_40",ts['state/Province']);
	if(structkeyexists(request.zos.listing.cityStruct, ts["city"]&"|"&ts["State/Province"])){
		cid=request.zos.listing.cityStruct[ts["city"]&"|"&ts["State/Province"]];
	}
	if(cid EQ 0 and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct, ts['zip code'])){
		cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct[ts['zip code']];
		ts["city"]=listgetat(cityName,1,"|");
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["State/Province"])){
			cid=request.zos.listing.cityStruct[cityName&"|"&ts["State/Province"]];
		}
	}
	local.listing_county=this.listingLookupNewId("county",ts['county']);
	
	local.listing_parking=this.listingLookupNewId("parking",ts['Parking']);


	if(application.zcore.functions.zso(ts, "rets26_GF20150107140549889252000000") NEQ ""){
		arrT=listtoarray(ts["rets26_GF20150107140549889252000000"]);
	}else if(application.zcore.functions.zso(ts, "rets26_GF20150107201859464523000000") NEQ ""){
		arrT=listtoarray(ts["rets26_GF20150107201859464523000000"]);
	}else if(application.zcore.functions.zso(ts, "rets26_GF20141227193418087637000000") NEQ ""){
		arrT=listtoarray(ts["rets26_GF20141227193418087637000000"]);
	// }else if(application.zcore.functions.zso(ts, "rets26_list_101") NEQ ""){
	// 	arrT=listtoarray(ts["rets26_list_101"]);
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
	local.listing_sub_type_id=arraytolist(arrT3);  
	
	local.listing_type_id=this.listingLookupNewId("listing_type",ts['rets26_list_8']);

	ad=ts['street ##']; 
	if(ad NEQ 0){
		address="#ad# ";
	}else{
		address="";	
	}
	ts['street suffix']=this.getRetsValue("property", ts["rets26_list_8"], "LIST_37",ts['street suffix']);
	ts['street dir suffix']="";
	if(structkeyexists(ts, 'rets26_list_36')){
		ts['street dir suffix']=this.getRetsValue("property", ts["rets26_list_8"], "LIST_33",ts['rets26_list_36']);
	}
	ts['street dir']="";
	if(structkeyexists(ts, 'rets26_list_33')){
		ts['street dir']=this.getRetsValue("property", ts["rets26_list_8"], "LIST_33",ts['rets26_list_33']);
	}
	address&=application.zcore.functions.zfirstlettercaps(ts['street dir']&" "&ts['street name']&" "&ts['street dir suffix']&" "&ts['street suffix']);
	curLat=ts["rets26_list_46"];
	curLong=ts["rets26_list_47"];
	if(curLat EQ "" and trim(address) NEQ ""){
		rs5=this.baseGetLatLong(address,ts['State/Province'],ts['zip code'], arguments.ss.listing_id);
		if(rs5.success){
			curLat=rs5.latitude;
			curLong=rs5.longitude;
		}
	}
	
	if(ts['Unit ##'] NEQ ''){
		address&=" Unit: "&ts["Unit ##"];
	} 
	
	s2=structnew();
	liststatus=this.getRetsValue("property", ts["rets26_list_8"], 'list_15', ts["status"]);
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
	local.listing_liststatus=structkeylist(s2,",");
	
	arrT3=[];
	uns=structnew();
	tmp=ts['rets26_list_9'];
	// style and pool don't work.
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
	
// Waterfront
/*
GF20141226230324959029000000
GF20141227192849848869000000
GF20141227193425333350000000
GF20150107140558302722000000
*/
	pt={
		// GFLU20141226230324959029000000
		"A":{
			key:"rets26_GF20141226230324959029000000", // correct
			view:{
				"183HXGQA1QFW":true,
				"183HXGONWJF3":true
			},
			frontage:{
				"183HXGN6D62A":true,
				"183HXGO6UWGG":true,
				"183HXGOYQ32F":true,
				"183HXGPW2MI3":true,
				"183HXGQKO1P3":true,
				"183HXGRXSZBI":true,
				"183HXGWE5KIR":true,
				"183HXGWS46MC":true,
				"183HXGX51WDB":true,
				"183HXGY252X5":true,
				"183HXGYAAN31":true,
				"183HXGYK5FU8":true,
				"183HXGYUZ0UT":true,
				"1AN2TT88XDQ1":true

			} 
		}, 
		// GFLU20141227192849848869000000
		"B":{
            key:"rets26_GF20141227192849848869000000", // correct
            view:{
                  "183I9PW45521":true,  
                  "183I9PW48ZV0":true,  
            },
            frontage:{
				"183I9PW42ICW":true,
				"183I9PW4416A":true,
				"183I9PW46M2S":true,
				"183I9PW47W09":true,
				"183I9PW4A4V4":true,
				"183I9PW4BJCO":true,
				"183I9PW4CXZE":true,
				"183I9PW4EBV0":true,
				"183I9PW4FNQH":true,
				"183I9PW4GRUH":true,
				"183I9PW4HUZF":true,
				"183I9PW4IZAZ":true,
				"183I9PW4KCK6":true,
				"1AN2TTB91PSR":true
            }
        },
        // GFLU20141227193425333350000000
        "C":{
        	key:"rets26_GF20141227193425333350000000", // correct
            view:{
				"183I9Q5MYY7N":true,
				"183I9Q5N0D7U":true
            },
            frontage:{
				"183I9Q5MRF2Z":true,
				"183I9Q5MSIAC":true,
				"183I9Q5MUN9P":true,
				"183I9Q5MVP4I":true,
				"183I9Q5MWS2I":true,
				"183I9Q5MXUOX":true,
				"183I9Q5N1IOP":true,
				"183I9Q5N2NXI":true,
				"183I9Q5N4S1Q":true,
			}
        },
        // GFLU20150107140558302722000000
        // GF20150107140558302722000000
        "F":{
        	key:"rets26_GF20150107140558302722000000", // correct
            view:{
                  "1AIXY5JWI0SA":true,  
                  "1AIXY5JWNTVB":true,   
            },
            frontage:{
				"1AIXY5JW8S1B":true,
				"1AIXY5JWADBL":true,
				"1AIXY5JWGNNS":true,
				"1AIXY5JWJISR":true,
				"1AIXY5JWMIXY":true,
				"1AIXY5JWQRPV":true,
				"1AIXY5JWSNFI":true,
				"1DBDJQWRNPFH":true,
				"1DBDJQZ2G936":true
			}
        }
	};  
	// view & frontage
	arrT3=[];
	arrT2=[]; 
	uns=structnew();
	uns2=structnew();
	
	if(structkeyexists(pt, ts["rets26_list_8"])){
		tmp=application.zcore.functions.zso(ts, pt[ts["rets26_list_8"]].key);
		arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			if(structkeyexists(pt[ts["rets26_list_8"]], 'frontage') and structkeyexists(pt[ts["rets26_list_8"]].frontage, arrT[i])){
				tmp=this.listingLookupNewId("frontage",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
					uns[tmp]=true;
					arrayappend(arrT3,tmp);
				}
			}
			if(structkeyexists(pt[ts["rets26_list_8"]], 'view') and structkeyexists(pt[ts["rets26_list_8"]].view, arrT[i])){
				tmp=this.listingLookupNewId("view",arrT[i]);
				if(tmp NEQ "" and structkeyexists(uns2,tmp) EQ false){
					uns2[tmp]=true;
					arrayappend(arrT2,tmp);
				}
			}
		}
	}
 
	local.listing_frontage=arraytolist(arrT3);  
	local.listing_view=arraytolist(arrT2);
	

	pt={
		"A":{
			key:"rets26_GF20141226230335404830000000",
			data:{
				"183HXH06C27H":true,  
				"183HXH1M3CTI":true,  
			} 
		}, 
		"B":{
            key:"rets26_GF20141227192846024680000000",
            data:{
                  "183I9PW1SSI7":true,  
                  "183I9PW1VMXX":true,  
            } 
        },
        "D":{
        	key:"rets26_GF20141227193422151879000000",
        	data:{
        		"183I9Q5KT5HP":true, 
				"183I9Q5KVISG":true
        	} 
        }
	};
	local.listing_pool=0;
	for(i in pt){
		if(i EQ ts.rets26_list_8){
			if(structkeyexists(ts, pt[i].key)){
				arrPool=listtoarray(ts[pt[i].key], ",");
				for(n=1;n LTE arraylen(arrPool);n++){
					if(structkeyexists(pt[i].data, arrPool[n])){
						local.listing_pool=1;
						break;
					}
				}
			}
		}
	}
 
	ts=this.convertRawDataToLookupValues(ts, ts["rets26_list_8"], ts["rets26_list_8"]);
	ts2=structnew();
	ts2.field="";
	ts2.yearbuiltfield=ts['year built'];
	ts2.foreclosureField="";
	
	s=this.processRawStatus(ts2);
	
	if(ts["rets26_list_8"] EQ "B"){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
	}else if(ts["rets26_list_8"] EQ "D" and ts["rets26_list_9"] EQ "183IMU3I4W6F"){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true;
	}else{
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
	} 

	if(structkeyexists(ts, 'Special Conditions')){ 
		if(ts['Special Conditions'] CONTAINS '1AIXY5JV4D0R' or ts['Special Conditions'] CONTAINS '183I9Q7UF3EF' or ts['Special Conditions'] CONTAINS '183I9Q5LTN5H' or ts['Special Conditions'] CONTAINS '183I9PW30363' or ts['Special Conditions'] CONTAINS '183I7G4DC6ZK'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
		if(ts['Special Conditions'] CONTAINS '183I7G3YQXGQ' or ts['Special Conditions'] CONTAINS '183I9PW2YO4R' or ts['Special Conditions'] CONTAINS '183I9Q5LSJVZ' or ts['Special Conditions'] CONTAINS '183I9Q7UDZQN' or ts['Special Conditions'] CONTAINS '1AIXY5JV387E'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}
		if(ts['Special Conditions'] CONTAINS '183I7G5SBAEJ' or ts['Special Conditions'] CONTAINS '183I9PW32YKE' or ts['Special Conditions'] CONTAINS '183I9Q5LW36P' or ts['Special Conditions'] CONTAINS '183I9Q7UH8OO' or ts['Special Conditions'] CONTAINS '1AIXY5JV6LL6'){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}   
	}
	local.listing_status=structkeylist(s,",");
	 
	dataCom=this.getRetsDataObject();
	local.listing_data_detailcache1=dataCom.getDetailCache1(ts);
	local.listing_data_detailcache2=dataCom.getDetailCache2(ts);
	local.listing_data_detailcache3=dataCom.getDetailCache3(ts);

	rs=structnew();
	rs.listing_acreage="";
	if(application.zcore.functions.zso(ts, 'rets26_list_57') NEQ ""){
		rs.listing_acreage=ts["rets26_list_57"];
	}else if(application.zcore.functions.zso(ts, 'rets26_GF20141227192834317267000000') NEQ ""){
		rs.listing_acreage=ts["rets26_GF20141227192834317267000000"];
	}else if(application.zcore.functions.zso(ts, 'rets26_GF20141226230259827496000000') NEQ ""){
		rs.listing_acreage=ts["rets26_GF20141226230259827496000000"];
	}
	rs.listing_id=arguments.ss.listing_id;
	if(structkeyexists(ts, "Baths")){
		rs.listing_baths=ts["Baths"];
	}else if(structkeyexists(ts, "Baths - Total")){
		rs.listing_baths=ts["Baths - Total"];
	}else if(structkeyexists(ts, 'Full Baths')){
		rs.listing_baths=ts["Full Baths"];
	}else{
		rs.listing_baths='';
	}
	rs.listing_halfbaths=ts["Baths - Half"];
	if(structkeyexists(ts, "Total Bedrooms")){
		rs.listing_beds=ts["Total Bedrooms"];
	}else if(structkeyexists(ts, "Bedrooms")){
		rs.listing_beds=ts["Bedrooms"];
	}else{
		rs.listing_beds=0;
	}
	rs.listing_condoname=application.zcore.functions.zso(ts,"rets26_list_130");
	rs.listing_city=cid;
	rs.listing_county=local.listing_county;
	rs.listing_frontage=","&local.listing_frontage&",";
	rs.listing_frontage_name="";
	rs.listing_price=ts["list price"];
	rs.listing_status=","&local.listing_status&",";
	rs.listing_state=ts["State/Province"];
	rs.listing_type_id=local.listing_type_id;
	rs.listing_sub_type_id=","&local.listing_sub_type_id&",";
	rs.listing_style=","&local.listing_style&",";
	rs.listing_view=","&local.listing_view&",";

	// if residential, don't use this field 
	rs.listing_lot_square_feet=0;
	if(ts["rets26_list_8"] EQ "A"){
		rs.listing_square_feet=application.zcore.functions.zso(ts, "rets26_list_48");
		//rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets26_list_49");
	}else if(ts["rets26_list_8"] EQ "B"){
		rs.listing_square_feet=application.zcore.functions.zso(ts, "rets26_list_48");
		//rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets26_list_49");
	}else if(ts["rets26_list_8"] EQ "C"){
		rs.listing_square_feet=application.zcore.functions.zso(ts, "rets26_list_48");
		//rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets26_list_49");
 
	}else if(ts["rets26_list_8"] EQ "D"){
		rs.listing_square_feet=application.zcore.functions.zso(ts, "rets26_list_48");
		//rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets26_list_49");
	}else if(ts["rets26_list_8"] EQ "F"){
		rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets26_list_52");
		rs.listing_square_feet=0;
	}else{
		rs.listing_square_feet=0;
		rs.listing_lot_square_feet=0;
	}
	rs.listing_subdivision=local.listing_subdivision;
	rs.listing_year_built=ts["year built"];
	rs.listing_office=ts["Office ID"];
	rs.listing_agent=ts["Agent ID"];
	rs.listing_office_name=ts["rets26_listing_office_name"];
	rs.listing_latitude=curLat;
	rs.listing_longitude=curLong;
	rs.listing_pool=local.listing_pool;
	rs.listing_photocount=ts["Picture Count"];
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
	rs.listing_data_remarks=ts["Remarks"];
	rs.listing_data_address=trim(address);
	rs.listing_data_zip=trim(ts["zip code"]);
	rs.listing_data_detailcache1=local.listing_data_detailcache1;
	rs.listing_data_detailcache2=local.listing_data_detailcache2;
	rs.listing_data_detailcache3=local.listing_data_detailcache3; 

	rs.listing_track_external_timestamp=ts["rets26_list_87"]; 
	rs.listing_track_sysid="";
	rs2={
		listingData:rs,
		columnIndex:columnIndex,
		arrData:arguments.ss.arrData
	};
	//writedump(rs2);abort;
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
			local.fNameTemp1="26-"&idx.urlMlsPid&"-"&i&".jpeg";
			local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
			idx["photo"&i]=request.zos.retsPhotoPath&'26/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
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
		
	idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets26_unbrandedidxvirtualtour");
	idx["zipcode"]=arguments.ss["listing_zip"];
	idx["maintfees"]="";
	if(isnumeric(application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_LIST_117"))){
		idx["maintfees"]=arguments.ss["rets#this.mls_id#_LIST_117"]; 
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
	local.fNameTemp1="26-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
	local.fNameTempMd51=lcase(hash(local.fNameTemp1, 'MD5'));
	return request.zos.retsPhotoPath&'26/'&left(local.fNameTempMd51,2)&"/"&mid(local.fNameTempMd51,3,1)&"/"&local.fNameTemp1;
	
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
	fd["B"]="Residential Lease";
	fd["C"]="Multi-Family";
	fd["D"]="Commercial";
	fd["F"]="Vacant Land";
	fd["G"]="Boat Docks"; 
	for(i in fd){
		i2=i;
		if(i2 NEQ ""){
			arrayappend(arrSQL,"('#this.mls_provider#','listing_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		}
	}


	for(g=1;g LTE arraylen(this.arrTypeLoop);g++){
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"list_41");
		for(i in fd){
			i2=i;
			arrayappend(arrSQL,"('#this.mls_provider#','county','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		} 

		// sub_type
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20150107140549889252000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		// sub_type
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20141227193418087637000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		// sub_type
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20150107201859464523000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		// sub_type
		// fd=this.getRETSValues("property", this.arrTypeLoop[g],"LIST_101");
		// for(i in fd){
		// 	i2=i;
		// 	if(i2 NEQ ""){
		// 		arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		// 	}
		// } 


		arrFrontage=["GF20141226230324959029000000","GF20141227192849848869000000","GF20141227193425333350000000","GF20150107140558302722000000"];
		// frontage
		for(i2=1;i2 LTE arraylen(arrFrontage);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrFrontage[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','frontage','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
				arrayappend(arrSQL,"('#this.mls_provider#','view','#fd[i]#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			} 
		} 
		
		// style
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"LIST_9");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','style','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}

		// parking
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20141226230426862688000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20141227192845246339000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20141227193421492461000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
		}
		fd=this.getRETSValues("property", this.arrTypeLoop[g],"GF20141227193556888800000000");
		for(i in fd){
			i2=i;
			if(i2 NEQ ""){
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#fd[i]#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
			}
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
					 local.result=db.insert("q"); 
					 db.sql="INSERT INTO #db.table("city_memory", request.zos.zcoreDatasource)#  
					 SET city_id=#db.param(local.result.result)#, 
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
	}
	return {arrSQL:arrSQL, cityCreated:cityCreated, arrError:arrError};
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>