<cfcomponent extends="zcorerootmapping.mvc.z.listing.mls-provider.rets-generic">
<cfoutput>
<cfscript>
this.retsVersion="1.7";

this.mls_id=27;
if(request.zos.istestserver){
	variables.hqPhotoPath="#request.zos.sharedPath#mls-images/27/";
}else{
	variables.hqPhotoPath="#request.zos.sharedPath#mls-images/27/";
}
this.useRetsFieldName="system";
this.arrTypeLoop=["A","B","C","D", "F", "G"];
this.arrColumns=listtoarray("colisting_member_address,colisting_member_email,colisting_member_fax,colisting_member_name,colisting_member_phone,colisting_member_shortid,colisting_member_url,FEAT20030311183918049959000000,FEAT20030311183938639447000000,FEAT20030311183954886938000000,FEAT20030311184006675967000000,FEAT20030311184018811717000000,FEAT20030311214906751681000000,FEAT20030311214917291819000000,FEAT20030312193006671084000000,FEAT20030312193124023452000000,FEAT20030312200358826124000000,FEAT20030312200441631565000000,FEAT20030312200550377591000000,FEAT20030312200558799849000000,FEAT20030312200614690909000000,FEAT20030312200628307043000000,FEAT20030312201649031864000000,FEAT20030312201657219733000000,FEAT20030312201712145040000000,FEAT20030312201738658624000000,FEAT20030312201834743858000000,FEAT20030312202026016257000000,FEAT20030312202055571400000000,FEAT20030312202118680004000000,FEAT20030312202140993560000000,FEAT20030312202523524674000000,FEAT20030312202607862725000000,FEAT20030312202634323923000000,FEAT20030312202648270263000000,FEAT20030312202716646333000000,FEAT20030312202732279886000000,FEAT20030312211859681589000000,FEAT20030312211944772919000000,FEAT20030313213554236983000000,FEAT20030313213620522102000000,FEAT20030313213633468914000000,FEAT20030313222251583825000000,FEAT20030313222251823358000000,FEAT20030313222252152083000000,FEAT20030313222252247417000000,FEAT20030313222252312703000000,FEAT20030313222252372272000000,FEAT20030313222252432596000000,FEAT20030313222252492555000000,FEAT20030313222252724757000000,FEAT20030313222252784148000000,FEAT20030313222252952159000000,FEAT20030313222253184234000000,FEAT20030313222253245186000000,FEAT20030313222253311068000000,FEAT20030313222253370367000000,FEAT20030313222253441134000000,FEAT20030313222253502158000000,FEAT20030313222253562057000000,FEAT20030313222253621456000000,FEAT20030313222253680201000000,FEAT20030313222253740756000000,FEAT20030313222253800640000000,FEAT20030313222254027013000000,FEAT20030313222254194310000000,FEAT20030313222254254366000000,FEAT20030313222254324998000000,FEAT20030313222254385530000000,FEAT20030313222254445677000000,FEAT20030313222254505668000000,FEAT20030313222254565053000000,FEAT20030316035509991397000000,FEAT20030316035535336079000000,FEAT20030316035550159196000000,FEAT20030316035616108941000000,FEAT20030316040809875502000000,FEAT20030316040822910764000000,FEAT20030316040841767020000000,FEAT20030316040859630317000000,FEAT20030316040917696804000000,FEAT20030316040949457403000000,FEAT20030316041021079768000000,FEAT20030316041036971013000000,FEAT20030316041053260342000000,FEAT20030316041111184239000000,FEAT20030326032241373388000000,FEAT20030326032539535161000000,FEAT20030327193642354064000000,FEAT20030327193652399182000000,FEAT20030327193711481483000000,FEAT20030327193734767598000000,FEAT20030327193759660647000000,FEAT20030327193809269757000000,FEAT20030327193823311391000000,FEAT20030327193833590599000000,FEAT20030327193847488723000000,FEAT20030327193900055053000000,FEAT20030327193913850802000000,FEAT20030327193926601699000000,FEAT20030327193939552049000000,FEAT20030327193956750928000000,FEAT20030327194011913616000000,FEAT20030327194218488157000000,FEAT20030612162644522581000000,FEAT20030612205004438535000000,FEAT20030923163353316224000000,FEAT20030923163620661182000000,FEAT20030923164024392443000000,FEAT20030923164054326497000000,FEAT20030923165602659574000000,FEAT20030923170351573533000000,FEAT20040305180455673825000000,FEAT20040628173716309885000000,FEAT20040628173739939686000000,FEAT20130325204907598472000000,GF20020923141755529165000000,GF20030226223922292850000000,GF20030226223924178856000000,GF20030226223924548899000000,GF20030226223924961175000000,GF20030226223925313972000000,GF20030226223925644818000000,GF20030226223925901561000000,GF20030226223926983029000000,GF20030226223927789385000000,GF20030226223929026171000000,GF20030226223929852543000000,GF20030226223930163349000000,GF20030226223930354490000000,GF20030226223930665208000000,GF20030226223931411163000000,GF20030226223932164213000000,GF20030226223932480526000000,GF20030226223933328883000000,GF20030226223934316859000000,GF20030226223934789160000000,GF20030226223936396599000000,GF20030226223936808977000000,GF20030226223938465518000000,GF20030226223940461070000000,GF20030226223941039602000000,GF20030226223942637168000000,GF20030227010650718647000000,GF20030228184016963251000000,GF20030305180243592752000000,GF20030305220206873663000000,GF20030305220239790821000000,GF20030305220303003689000000,GF20030305220326457642000000,GF20030306165225382102000000,GF20030307143703901758000000,GF20030307143845665006000000,GF20030307143900748488000000,GF20030307144055011296000000,GF20030307144213806624000000,GF20030307144239272145000000,GF20030307144326808985000000,GF20030307144357108172000000,GF20030307144450198773000000,GF20030307144645419813000000,GF20030307144712288667000000,GF20030307144736877502000000,GF20030307144831825664000000,GF20030307144901128621000000,GF20030307144948629808000000,GF20030307145118656426000000,GF20030307145224721798000000,GF20030307145242383366000000,GF20030307145254565296000000,GF20030307145316049007000000,GF20030307145346802276000000,GF20030307145415507812000000,GF20030307145448883655000000,GF20030307150656844370000000,GF20030307150701370384000000,GF20030307150701777202000000,GF20030307150705788119000000,GF20030307150709625693000000,GF20030307150710451244000000,GF20030307150712003071000000,GF20030307150712912350000000,GF20030307150715226180000000,GF20030307150716953983000000,GF20030307150717372548000000,GF20030307150722391366000000,GF20030310024242393113000000,GF20030310024250779761000000,GF20030310024252785856000000,GF20030310024256478930000000,GF20030310024302234720000000,GF20030310024302951804000000,GF20030310024303532029000000,GF20030310024305485861000000,GF20030310024306596098000000,GF20030310024307813311000000,GF20030310024308154024000000,GF20030310024311905702000000,GF20030310024312807492000000,GF20030310033432917694000000,GF20030310144059848163000000,GF20030310144134960319000000,GF20030310144150927573000000,GF20030311034120796072000000,GF20030311034128619452000000,GF20030311034129706355000000,GF20030311034131503120000000,GF20030311034133522227000000,GF20030311034134339042000000,GF20030311034137194777000000,GF20030311034140872534000000,GF20030311034143059853000000,GF20030311034144369061000000,GF20030311034146270735000000,GF20030311034147368896000000,GF20030311034148077490000000,GF20030311034148598338000000,GF20030311034148939888000000,GF20030311034149716396000000,GF20030311034152144091000000,GF20030311034153580698000000,GF20030311035306372544000000,GF20030311035335652346000000,GF20030311035356533095000000,GF20030311035426957247000000,GF20030311035450976505000000,GF20030311035513141301000000,GF20030311035530287975000000,GF20030311035547206098000000,GF20030311035609939812000000,GF20030311035625646992000000,GF20030311035639909284000000,GF20030313222237701613000000,GF20030313222239599297000000,GF20030313222240257693000000,GF20030313222240551378000000,GF20030313222240949110000000,GF20030313222241349280000000,GF20030313222242431569000000,GF20030313222244230998000000,GF20030313222245288182000000,GF20030313222246117493000000,GF20030313222248009621000000,GF20030313222248944660000000,GF20030313222251003477000000,GF20030313222251522164000000,GF20030313222254975326000000,GF20030313222255450365000000,GF20030313222255976656000000,GF20030313222256256820000000,GF20030313222257959998000000,GF20030313222258970489000000,GF20030313222300692756000000,GF20030313222302185406000000,GF20030313222302764561000000,GF20030313222303104013000000,GF20030313222303929560000000,GF20030313222305334750000000,GF20030313222305801878000000,GF20030313222308425763000000,GF20030316041756525995000000,GF20030316042253536015000000,GF20030326015005739753000000,GF20030326015006456699000000,GF20030326015008369333000000,GF20030326015008757524000000,GF20030326015010776935000000,GF20030326015011172738000000,GF20030326015013958574000000,GF20030326015014974182000000,GF20030326015016683918000000,GF20030326015017699570000000,GF20030326015018607749000000,GF20030326015019402171000000,GF20030326015020879240000000,GF20030326015021734674000000,GF20030326015022117815000000,GF20030326015023964780000000,GF20030326015024306988000000,GF20030326015026045421000000,GF20030326015027166546000000,GF20030326015028403983000000,GF20030326015030748067000000,GF20030326015032477026000000,GF20030326015032985047000000,GF20030326015033300521000000,GF20030326015034024077000000,GF20030326015035381127000000,GF20030326015036881057000000,GF20030326015037824669000000,GF20030326015038738344000000,GF20030327174035917305000000,GF20030327214422174377000000,GF20030327214438932183000000,GF20030327215807013860000000,GF20030327215829684088000000,GF20030327215849382204000000,GF20030327215915636756000000,GF20030607043107874564000000,GF20030609154828999409000000,GF20030613192716477740000000,GF20040625154623314091000000,GF20051214195610733711000000,GF20061101132330909919000000,GF20061101134252098174000000,GF20061101150711013638000000,GF20061101161314831018000000,GF20061101163056436736000000,GF20070119152500075247000000,GF20070119152616771672000000,GF20070122133416855055000000,GF20070122133953065412000000,GF20070122134348485246000000,GF20070122141336266664000000,GF20091007174340223056000000,GF20091007175249510919000000,GF20091007175326003449000000,GF20091007175439371259000000,GF20120424173840764151000000,GF20120605151337566802000000,HiRes location,LIST_0,LIST_1,LIST_101,LIST_105,LIST_106,LIST_107,LIST_108,LIST_109,LIST_113,LIST_115,LIST_117,LIST_118,LIST_119,LIST_133,LIST_134,LIST_137,LIST_15,LIST_16,LIST_19,LIST_22,LIST_24,LIST_25,LIST_26,LIST_27,LIST_28,LIST_29,LIST_3,LIST_31,LIST_32,LIST_33,LIST_34,LIST_35,LIST_36,LIST_37,LIST_38,LIST_39,LIST_40,LIST_41,LIST_42,LIST_43,LIST_44,LIST_46,LIST_47,LIST_48,LIST_49,LIST_5,LIST_50,LIST_51,LIST_52,LIST_53,LIST_54,LIST_55,LIST_56,LIST_57,LIST_6,LIST_65,LIST_66,LIST_67,LIST_68,LIST_69,LIST_70,LIST_73,LIST_74,LIST_77,LIST_78,LIST_8,LIST_80,LIST_81,LIST_82,LIST_83,LIST_84,LIST_86,LIST_87,LIST_88,LIST_89,LIST_9,LIST_90,LIST_91,LIST_93,LIST_94,LIST_95,LIST_96,LIST_97,listing_member_address,listing_member_email,listing_member_fax,listing_member_name,listing_member_phone,listing_member_shortid,listing_member_url,listing_office_address,listing_office_email,listing_office_fax,listing_office_name,listing_office_phone,listing_office_shortid,listing_office_url,ROOM_BD1_room_area,ROOM_BD1_room_length,ROOM_BD1_room_level,ROOM_BD1_room_nbr,ROOM_BD1_room_rem,ROOM_BD1_room_width,ROOM_BD2_room_area,ROOM_BD2_room_length,ROOM_BD2_room_level,ROOM_BD2_room_nbr,ROOM_BD2_room_rem,ROOM_BD2_room_width,ROOM_BD3_room_area,ROOM_BD3_room_length,ROOM_BD3_room_level,ROOM_BD3_room_nbr,ROOM_BD3_room_rem,ROOM_BD3_room_width,ROOM_BD4_room_area,ROOM_BD4_room_length,ROOM_BD4_room_level,ROOM_BD4_room_nbr,ROOM_BD4_room_rem,ROOM_BD4_room_width,ROOM_BD5_room_area,ROOM_BD5_room_length,ROOM_BD5_room_level,ROOM_BD5_room_nbr,ROOM_BD5_room_rem,ROOM_BD5_room_width,ROOM_BD6_room_area,ROOM_BD6_room_length,ROOM_BD6_room_level,ROOM_BD6_room_nbr,ROOM_BD6_room_rem,ROOM_BD6_room_width,ROOM_blank_room_area,ROOM_blank_room_length,ROOM_blank_room_level,ROOM_blank_room_nbr,ROOM_blank_room_rem,ROOM_blank_room_width,ROOM_BON_room_area,ROOM_BON_room_length,ROOM_BON_room_level,ROOM_BON_room_nbr,ROOM_BON_room_rem,ROOM_BON_room_width,ROOM_BRK_room_area,ROOM_BRK_room_length,ROOM_BRK_room_level,ROOM_BRK_room_nbr,ROOM_BRK_room_rem,ROOM_BRK_room_width,ROOM_DIN_room_area,ROOM_DIN_room_length,ROOM_DIN_room_level,ROOM_DIN_room_nbr,ROOM_DIN_room_rem,ROOM_DIN_room_width,ROOM_FAM_room_area,ROOM_FAM_room_length,ROOM_FAM_room_level,ROOM_FAM_room_nbr,ROOM_FAM_room_rem,ROOM_FAM_room_width,ROOM_GRT_room_area,ROOM_GRT_room_length,ROOM_GRT_room_level,ROOM_GRT_room_nbr,ROOM_GRT_room_rem,ROOM_GRT_room_width,ROOM_KIT_room_area,ROOM_KIT_room_length,ROOM_KIT_room_level,ROOM_KIT_room_nbr,ROOM_KIT_room_rem,ROOM_KIT_room_width,ROOM_LIV_room_area,ROOM_LIV_room_length,ROOM_LIV_room_level,ROOM_LIV_room_nbr,ROOM_LIV_room_rem,ROOM_LIV_room_width,ROOM_OTH_room_area,ROOM_OTH_room_length,ROOM_OTH_room_level,ROOM_OTH_room_nbr,ROOM_OTH_room_rem,ROOM_OTH_room_width,UNBRANDEDIDXVIRTUALTOUR,VOWAddr,VOWAVM,VOWComm,VOWList",",");
this.arrFieldLookupFields=[];
this.mls_provider="rets27";
variables.resourceStruct=structnew();
variables.resourceStruct["property"]=structnew();
variables.resourceStruct["property"].resource="property";
variables.resourceStruct["property"].id="list_105";
// list_1 is the sysid
this.emptyStruct=structnew(); 
variables.tableLookup=structnew();
variables.tableLookup["A"]="A"; // residential
variables.tableLookup["B"]="B"; // condo
variables.tableLookup["C"]="C"; // lots and land
variables.tableLookup["D"]="D"; // rentals
variables.tableLookup["E"]="E";	// investment/multifamily
variables.tableLookup["F"]="F"; // Commercial for Sale
variables.tableLookup["G"]="G"; // Commercial For Lease

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
	for(i=1;i LTE arraylen(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns);i++){
		if(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i] EQ "rets27_hireslocation"){
			ts["HiRes location"]=arguments.ss.arrData[i]; 
			columnIndex["HiRes location"]=i;
			continue;
		}
		col=(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.metaStruct["property"].tableFields[removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)].longname);
		ts["rets27_"&removechars(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.arrColumns[i],1,7)]=arguments.ss.arrData[i];
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
	ts["rets27_list_22"]=replace(ts["rets27_list_22"],",","","ALL");
	// need to clean this data - remove not in subdivision, 0 , etc.
	subdivision="";
	listing_subdivision="";
	if(application.zcore.functions.zso(ts, "Legal Name of Subdiv") NEQ ""){
		subdivision=ts["Legal Name of Subdiv"]; 
		listing_subdivision=this.getRetsValue("property", ts["rets27_list_8"], "LIST_83", subdivision);
	}else if(application.zcore.functions.zso(ts, "Common Name of Sub") NEQ ""){
		subdivision=ts["Common Name of Sub"];  
		listing_subdivision=this.getRetsValue("property", ts["rets27_list_8"], "LIST_77", subdivision);
	}
	
	if(listing_subdivision NEQ ""){
		if(findnocase(","&listing_subdivision&",", ",,false,none,not on the list,not in subdivision,n/a,other,zzz,na,0,.,N,0000,00,/,") NEQ 0){
			listing_subdivision="";
		}else{
			listing_subdivision=application.zcore.functions.zFirstLetterCaps(listing_subdivision);
		}
	}  
	
	this.price=ts["rets27_list_22"];
	listing_price=ts["rets27_list_22"];
	cityName="";
	cid=0;
	ts['city']=this.getRetsValue("property", ts["rets27_list_8"], "LIST_39", ts['city']);
	ts['state/Province']=this.getRetsValue("property", ts["rets27_list_8"], "LIST_40",ts['state/Province']);
	if(ts['state/Province'] EQ "Florida"){
		ts["state/Province"]="FL";
	}else if(ts['state/Province'] EQ "Georgia"){
		ts["state/Province"]="GA";
	}
	if(structkeyexists(request.zos.listing.cityStruct, ts["city"]&"|"&ts["State/Province"])){
		cid=request.zos.listing.cityStruct[ts["city"]&"|"&ts["State/Province"]];
	}
	if(cid EQ 0 and structkeyexists(request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct, ts['postal code'])){
		cityName=request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.cityRenameStruct[ts['postal code']];
		ts["city"]=listgetat(cityName,1,"|");
		if(structkeyexists(request.zos.listing.cityStruct, cityName&"|"&ts["State/Province"])){
			cid=request.zos.listing.cityStruct[cityName&"|"&ts["State/Province"]];
		}
	} 
	listing_county=this.listingLookupNewId("county",ts['county']);
	
	listing_parking=this.listingLookupNewId("parking",ts['Parking Facilities']);
 
	if(application.zcore.functions.zso(ts, "rets27_GF20030609154828999409000000") NEQ ""){
		arrT=listtoarray(ts["rets27_GF20030609154828999409000000"]);
	}else if(application.zcore.functions.zso(ts, "rets27_GF20030607043107874564000000") NEQ ""){
		arrT=listtoarray(ts["rets27_GF20030607043107874564000000"]);
	}else if(application.zcore.functions.zso(ts, "rets27_GF20030326015036881057000000") NEQ ""){
		arrT=listtoarray(ts["rets27_GF20030326015036881057000000"]);
	}else if(application.zcore.functions.zso(ts, "rets27_GF20030319224856584184000000") NEQ ""){
		arrT=listtoarray(ts["rets27_GF20030319224856584184000000"]);
	}else if(application.zcore.functions.zso(ts, "rets27_GF20030226223922292850000000") NEQ ""){
		arrT=listtoarray(ts["rets27_GF20030226223922292850000000"]);
	}else if(application.zcore.functions.zso(ts, "rets27_LIST_97") NEQ ""){
		arrT=listtoarray(ts["rets27_LIST_97"]);
	}else if(application.zcore.functions.zso(ts, "rets27_GF20030307143703901758000000") NEQ ""){
		arrT=listtoarray(ts["rets27_GF20030307143703901758000000"]);
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
	
	listing_type_id=this.listingLookupNewId("listing_type",ts['rets27_list_8']);

	ad=ts['street number'];
	if(ad NEQ 0){
		address="#ad# ";
	}else{
		address="";	
	}
	ts['street sfx']=this.getRetsValue("property", ts["rets27_list_8"], "LIST_37",ts['street sfx']);
	if(structkeyexists(ts, 'street direction sfx')){
		ts['street dir']=this.getRetsValue("property", ts["rets27_list_8"], "LIST_36",ts['street direction sfx']);
		address&=application.zcore.functions.zfirstlettercaps(ts['street name']&ts['street dir']&" "&" "&ts['street sfx']);
	}else{
		ts['street dir']=this.getRetsValue("property", ts["rets27_list_8"], "LIST_33",ts['street direction pfx']);
		address&=application.zcore.functions.zfirstlettercaps(ts['street dir']&" "&ts['street name']&" "&ts['street sfx']);
	}
	curLat=ts["rets27_list_46"];
	curLong=ts["rets27_list_47"];
	if(curLat EQ "" and trim(address) NEQ ""){
		rs5=this.baseGetLatLong(address,ts['State/Province'],ts['postal code'], arguments.ss.listing_id);
		curLat=rs5.latitude;
		curLong=rs5.longitude;
	}
	
	if(ts['Unit ##'] NEQ ''){
		address&=" Unit: "&ts["Unit ##"];
	}  
	listing_liststatus="1"; 
	
	arrT3=[];
	uns=structnew();
	tmp=ts['style'];
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
	listing_style=arraytolist(arrT3);
	
	tmp=ts["Lot Description/View"];
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("view",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	listing_view=arraytolist(arrT3);

	tmp=ts["Waterfront Descript"];
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
	 

	tmp=application.zcore.functions.zso(ts, "pool");
	if(tmp EQ ""){
		tmp=ts["Pool/Hot Tub"];
	}
	if(tmp NEQ ""){
	   arrT=listtoarray(tmp);
		for(i=1;i LTE arraylen(arrT);i++){
			tmp=this.listingLookupNewId("pool",arrT[i]);
			if(tmp NEQ "" and structkeyexists(uns,tmp) EQ false){
				uns[tmp]=true;
				arrayappend(arrT3,tmp);
			}
		}
	}
	listing_pool=arraytolist(arrT3);
	if(listing_pool CONTAINS "no pool"){
		listing_pool="";
	}
  
 
	ts=this.convertRawDataToLookupValues(ts, ts["rets27_list_8"], ts["rets27_list_8"]);
	ts2=structnew();
	ts2.field="";
	ts2.yearbuiltfield=ts['year built'];
	ts2.foreclosureField="";
	
	s=this.processRawStatus(ts2);
	
	if(ts["rets27_list_8"] EQ "D" or ts["rets27_list_8"] EQ "G"){
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for rent"]]=true; 
	}else{
		s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["for sale"]]=true;
	} 

	if(structkeyexists(ts, 'OwnerApprPublicMktg')){  
		arrT=listToArray(ts["OwnerApprPublicMktg"]);
		currentField="";
		if(application.zcore.functions.zso(ts, "rets27_GF20091007175439371259000000") NEQ ""){
			currentField="GF20091007175439371259000000";
		}else if(application.zcore.functions.zso(ts, "rets27_GF20091007175403725545000000") NEQ ""){
			currentField="GF20091007175403725545000000";
		}else if(application.zcore.functions.zso(ts, "rets27_GF20091007175439371259000000") NEQ ""){
			currentField="GF20091007175326003449000000";
		}else if(application.zcore.functions.zso(ts, "rets27_GF20091007175249510919000000") NEQ ""){
			currentField="GF20091007175249510919000000";
		}else if(application.zcore.functions.zso(ts, "rets27_GF20091007174340223056000000") NEQ ""){
			currentField="GF20091007174340223056000000";
		}
		arrT2=[];
		for(i=1;i<=arraylen(arrT);i++){
			t=this.getRetsValue("property", ts["rets27_list_8"], currentField, arrT[i]);
			if(t NEQ ""){
				arrayAppend(arrT2, t);
			}
		}
		saleType=arrayToList(arrT2, ",");
		if(saleType CONTAINS "Pre-Foreclosure"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["foreclosure"]]=true;
		}
		if(saleType CONTAINS "Foreclosed"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["bank owned"]]=true;
		}
		if(saleType CONTAINS "short sale"){
			s[request.zos.listing.mlsStruct[this.mls_id].sharedStruct.lookupStruct.statusStr["short sale"]]=true;
		}    
	}
	listing_status=structkeylist(s,",");
	 
	dataCom=this.getRetsDataObject();
	listing_data_detailcache1=dataCom.getDetailCache1(ts);
	listing_data_detailcache2=dataCom.getDetailCache2(ts);
	listing_data_detailcache3=dataCom.getDetailCache3(ts);

	rs=structnew();
	rs.listing_acreage="";
	if(application.zcore.functions.zso(ts, 'rets27_list_57') NEQ ""){
		rs.listing_acreage=ts["rets27_list_57"]; 
	}
	rs.listing_id=arguments.ss.listing_id;
	if(structkeyexists(ts, 'Full Baths')){
		rs.listing_baths=ts["Full Baths"];
	}else{
		rs.listing_baths='';
	}
	rs.listing_halfbaths=application.zcore.functions.zso(ts, "Half Baths");
	if(structkeyexists(ts, "Total Bedrooms")){
		rs.listing_beds=ts["Total Bedrooms"];
	}else if(structkeyexists(ts, "Bedrooms")){
		rs.listing_beds=ts["Bedrooms"];
	}else{
		rs.listing_beds=0;
	}
	rs.listing_condoname="";
	rs.listing_city=cid;
	rs.listing_county=listing_county;
	rs.listing_frontage=","&listing_frontage&",";
	rs.listing_frontage_name="";
	rs.listing_price=ts["rets27_list_22"];
	rs.listing_status=","&listing_status&",";
	rs.listing_state=ts["State/Province"];
	rs.listing_type_id=listing_type_id;
	rs.listing_sub_type_id=","&listing_sub_type_id&",";
	rs.listing_style=","&listing_style&",";
	rs.listing_view=","&listing_view&",";
	rs.listing_lot_square_feet="";

	rs.listing_square_feet=application.zcore.functions.zso(ts, "rets27_list_48");

	if(ts["rets27_list_8"] EQ "E"){
		rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets27_list_49");
	}else if(ts["rets27_list_8"] EQ "F" or ts["rets27_list_8"] EQ "G"){
		rs.listing_lot_square_feet=application.zcore.functions.zso(ts, "rets27_list_52");
	}
	rs.listing_subdivision=listing_subdivision;
	rs.listing_year_built=ts["year built"];
	rs.listing_office=ts["Office ID"];
	rs.listing_agent=ts["Agent ID"]; 
	rs.listing_office_name=ts["ListingOfficeName"];
	rs.listing_latitude=curLat;
	rs.listing_longitude=curLong;
	rs.listing_pool=listing_pool;
	rs.listing_photocount=ts["Picture Count"];
	rs.listing_coded_features="";
	rs.listing_updated_datetime=arguments.ss.listing_track_updated_datetime;
	rs.listing_primary="0";
	rs.listing_mls_id=arguments.ss.listing_mls_id;
	rs.listing_address=trim(address);
	rs.listing_zip=ts["postal code"];
	rs.listing_condition="";
	rs.listing_parking=listing_parking;
	rs.listing_region="";
	rs.listing_tenure="";
	rs.listing_liststatus=listing_liststatus;
	rs.listing_data_remarks=ts["Public Remarks"];
	rs.listing_data_address=trim(address);
	rs.listing_data_zip=trim(ts["postal code"]);
	rs.listing_data_detailcache1=listing_data_detailcache1;
	rs.listing_data_detailcache2=listing_data_detailcache2;
	rs.listing_data_detailcache3=listing_data_detailcache3; 
	rs["HiRes location"]=ts["HiRes location"]; 

	rs.listing_track_sysid="";
	rs2={
		listingData:rs,
		columnIndex:columnIndex,
		arrData:arguments.ss.arrData
	}; 
	return rs2;
	</cfscript>
</cffunction> 

<cffunction name="getCachedRequestListingImageUrls" localmode="modern" access="public">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	if(not structkeyexists(request.zos, 'listingImageURLCache')){
		request.zos.listingImageURLCache={};
	}
	if(structkeyexists(request.zos.listingImageURLCache, arguments.idx.listing_id)){
		return request.zos.listingImageURLCache[arguments.idx.listing_id];
	}
	arrPhoto=listToArray(application.zcore.functions.zso(arguments.idx, "HiRes location"), ",");
	ts={};
	for(i=1;i<=arraylen(arrPhoto);i++){
		ts["photo"&i]=application.zcore.listingCom.getThumbnail(arrPhoto[i], arguments.idx.listing_id, i, 10000, 10000, 0); 
	}
	request.zos.listingImageURLCache[arguments.idx.listing_id]=ts;
	return ts;
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
		ts=getCachedRequestListingImageUrls(idx); 
		structappend(idx, ts, true); 
		/*
		i=1;
		for(i=1;i LTE idx.listing_photocount;i++){
			fNameTemp1="27-"&idx.urlMlsPid&"-"&i&".jpeg";
			fNameTempMd51=lcase(hash(fNameTemp1, 'MD5'));
			idx["photo"&i]=request.zos.retsPhotoPath&'27/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/"&fNameTemp1;
		}
		*/
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
		
	idx["virtualtoururl"]=application.zcore.functions.zso(arguments.ss, "rets27_unbrandedidxvirtualtour");
	idx["zipcode"]=arguments.ss["listing_zip"];
	idx["maintfees"]="";
	if(isnumeric(application.zcore.functions.zso(arguments.ss, "rets#this.mls_id#_LIST_26"))){
		idx["maintfees"]=arguments.ss["rets#this.mls_id#_LIST_26"]; 
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
	if(structkeyexists(request.zos, 'listingImageURLCache')){
		if(structkeyexists(request.zos.listingImageURLCache, this.mls_id&"-"&arguments.mls_pid)){
			if(structkeyexists(request.zos.listingImageURLCache[this.mls_id&"-"&arguments.mls_pid], "photo"&arguments.num)){
				return request.zos.listingImageURLCache[this.mls_id&"-"&arguments.mls_pid]["photo"&arguments.num];
			}
		}
	}
	request.lastPhotoId="";
	/*
	request.lastPhotoId=this.mls_id&"-"&arguments.mls_pid;
	fNameTemp1="27-"&arguments.mls_pid&"-"&arguments.num&".jpeg";
	fNameTempMd51=lcase(hash(fNameTemp1, 'MD5'));
	return request.zos.retsPhotoPath&'27/'&left(fNameTempMd51,2)&"/"&mid(fNameTempMd51,3,1)&"/"&fNameTemp1;
	*/
	
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
	fd["B"]="Condominimums";
	fd["C"]="Vacant Land";
	fd["D"]="Rentals";
	fd["E"]="Multi-family";
	fd["F"]="Commercial For Sale";
	fd["G"]="Commercial For Lease";
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
			arrayappend(arrSQL,"('#this.mls_provider#','county','#application.zcore.functions.zescape(fd[i])#','#i2#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')");
		} 

		 
		// sub_type
		arrSubType=["GF20030609154828999409000000","GF20030607043107874564000000","GF20030326015036881057000000","GF20030319224856584184000000","GF20030226223922292850000000","LIST_97","GF20030307143703901758000000"];
		for(i2=1;i2 LTE arraylen(arrSubType);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrSubType[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','listing_sub_type','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
			} 
		} 
 
		arrFrontage=["GF20020923141755529165000000","GF20030307150709625693000000","GF20030310024252785856000000","GF20030326015018607749000000"];
		// frontage
		for(i2=1;i2 LTE arraylen(arrFrontage);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrFrontage[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','frontage','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
			} 
		} 
		arrView=["GF20030319224838160515000000","GF20030313222248944660000000","GF20030311034137194777000000"];
		// view
		for(i2=1;i2 LTE arraylen(arrView);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrView[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','view','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
			} 
		} 
		 
		arrStyle=["GF20030226223932480526000000","GF20030326015035381127000000"];
		// style 
		for(i2=1;i2 LTE arraylen(arrStyle);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrStyle[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','style','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
			}  
		}

		arrParking=["GF20030226223936808977000000","GF20030307150710451244000000", "GF20030326015019402171000000", "GF20030319224835368134000000", "GF20030313222246117493000000", "GF20030311034134339042000000"];
		// parking 
		for(i2=1;i2 LTE arraylen(arrParking);i2++){
			fd=this.getRETSValues("property", this.arrTypeLoop[g],arrParking[i2]);
			for(i in fd){
				tmp=i;
				arrayappend(arrSQL,"('#this.mls_provider#','parking','#application.zcore.functions.zescape(fd[i])#','#tmp#','#request.zos.mysqlnow#','#i#','#request.zos.mysqlnow#', '0')"); 
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
	}
	return {arrSQL:arrSQL, cityCreated:cityCreated, arrError:arrError};
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>