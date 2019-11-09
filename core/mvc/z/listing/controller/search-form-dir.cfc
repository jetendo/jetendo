<cfcomponent></cfcomponent><!--- <cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
 <cfscript>
		var db=request.zos.queryObject;
if(structkeyexists(request.zos.userSession.groupAccess, "member") EQ false){
	application.zcore.functions.z301redirect('/');
}
form.action=application.zcore.functions.zso(form, 'action');
start48=gettickcount();
 //request.znotemplate=1;
mls_dir_id=zso(form, 'mls_dir_id',true,0);
		//test = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.dir");
		//test.test();
		//zAbort();
redXEnabled=false;
debugSearchDir=false;//true;//zso(form, 'debugSearchDir',false,false);
form.action=application.zcore.functions.zso(form, 'action',false,'form');
propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
propertyDataCom.enableFiltering=true;
propertyDataCom.enableListingTrack=false;
propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
form.zIndex=zso(form, 'zIndex',false,1);
form.zIndex=max(form.zIndex,1);
</cfscript>
<cfif mls_dir_id NEQ 0>
	<cfscript>
	db.sql="SELECT SQL_NO_CACHE * FROM #db.table("mls_dir", request.zos.zcoreDatasource) mls_dir, 
	#db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	WHERE mls_saved_search.mls_saved_search_id = mls_dir.mls_saved_search_id AND 
	mls_dir.site_id = #db.param(request.zos.globals.id)# and 
	mls_dir.mls_dir_id = #db.param(mls_dir_id)# and 
	mls_dir_deleted = #db.param(0)# and 
	mls_saved_search_deleted = #db.param(0)#";
	qD=db.execute("qD"); 
    if(qD.recordcount EQ 0){
        z301Redirect('/Real-Estate-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_dir_url_id#-0.html');	
    }
    zquerytostruct(qd);
	if(mls_dir_full_text NEQ ""){
		writeoutput('<div style="height:120px; overflow:auto;">'&mls_dir_full_text&'</div><br style="clear:both;" /><br />');
	}
	temp238722=structnew();
	temp23872=structnew();
	application.zcore.functions.zQueryToStruct(qd,temp238722);
	request.zos.listing.functions.zMLSSetSearchStruct(temp23872,temp238722);
	//zdump(temp23872);
	propertyDataCom.setSearchCriteria(temp23872);
    </cfscript>
    <cfsavecontent variable="tempMeta">
    <meta name="keywords" content="#htmleditformat(mls_dir_metakey)#">
    <meta name="description" content="#htmleditformat(mls_dir_metadesc)#">
    </cfsavecontent>
    <cfscript>
    application.zcore.template.setTag("title",mls_dir_title);
    application.zcore.template.setTag("pagetitle",mls_dir_title);
    application.zcore.template.setTag("meta",tempMeta);
	</cfscript>
    <cfsavecontent variable="temppagenav">
    <a href="/">#application.zcore.functions.zvar('homelinktext')#</a> / <a href="/Real-Estate-#application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_dir_url_id#-0.html">Real Estate Directory</a> / 
    <cfscript>
	arrHash=arraynew(1);
	arr1=arraynew(1);
	arr2=arraynew(1);
	arr3=arraynew(1);
	for(i=1;i LTE arraylen(propertyDataCom.arrSearchFields);i++){
		label=propertyDataCom.arrShortSearchFields[i]&":";
		if(structkeyexists(propertyDataCom.ignoreFieldStruct,propertyDataCom.arrSearchFields[i]) EQ false){
			value=zso(form, propertyDataCom.arrSearchFields[i]);
			if(structkeyexists(propertyDataCom.rangeFieldStruct,propertyDataCom.arrSearchFields[i])){
				lowField=value;
				highField=zso(form, propertyDataCom.rangeFieldStruct[propertyDataCom.arrSearchFields[i]]);
				if(lowField NEQ "" and highField NEQ "" and isNumeric(lowField) and isNumeric(highField) and (propertyDataCom.defaultSearchCriteria[propertyDataCom.arrSearchFields[i]] NEQ lowField or propertyDataCom.defaultSearchCriteria[propertyDataCom.rangeFieldStruct[propertyDataCom.arrSearchFields[i]]] NEQ highField)){
					//arrayappend(arr2332,label&lowField&"-"&highvalue);
					arrayappend(arr1,lowField&"-"&highfield);
					arrayappend(arr2,label);
					arrayappend(arr3,propertyDataCom.arrSearchFields[i]);
				}
			}else if(value NEQ "" and value NEQ "0"){
				//arrayappend(arr2332,label&value);
					arrayappend(arr1,value);
					arrayappend(arr2,label);
					arrayappend(arr3,propertyDataCom.arrSearchFields[i]);
			}
		}
	}
	index=arraylen(arr1);
	hashStruct=structnew();
	index2=arraylen(arr1);
	pageNavCount=arraylen(arr1);
	//zdump(arr1);
	//zabort();
	for(n=1;n LTE pageNavCount;n++){
		arrn=arraynew(1);
		ts9=structnew();
		ts92=structnew();
		for(i=1;i LTE arraylen(arr1);i++){
			if(i NEQ index){
				arrayappend(arrn,arr2[i]&arr1[i]);
				if(right(arr3[i],4) EQ "_low"){
					ts92[arr3[i]]=listgetat(arr1[i],1,'-');
					ts92[replacenocase(arr3[i],"_low","_high")]=listgetat(arr1[i],2,'-');
				}else{
					ts92[arr3[i]]=arr1[i];
				}
			}else{
				if(right(arr3[i],4) EQ "_low"){
					ts9[arr3[i]]=listgetat(arr1[i],1,'-');
					ts9[replacenocase(arr3[i],"_low","_high")]=listgetat(arr1[i],2,'-');
				}else{
					ts9[arr3[i]]=arr1[i];
				}
				//backupValue=arr1[i];
				//backupLabel=arr2[i];	
			}
		}
		curStr=arraytolist(arrn,chr(9));
		if(curStr NEQ ""){
			curHash=hash(curStr);
			//ts9=structnew();
			//zdump(ts9);
			hashStruct[curHash]=structnew();
			hashStruct[curHash].title=arraytolist(request.zos.listing.functions.getSearchCriteriaDisplay(ts9,true,true)," | ");
			hashStruct[curHash].searchCriteria=ts92;
			hashStruct[curHash].index=index2;
			hashStruct[curHash].searchString=curStr;
			//hashStruct[curHash]=backupLabel&backupValue;
			//writeoutput('title:'&hashStruct[curHash].title&'<br />');
			arrayappend(arrHash,curHash);
			index2--;
		}
		index--;
		//writeoutput(curStr&"<br />"&curHash&"<br />");
	}
	</cfscript><cfif arraylen(arrHash) NEQ 0><cfscript>
	// get all mls_dir for the hash of current criteria
	db.sql="SELECT *, length(mls_dir_title) tlen FROM mls_dir 
	where site_id = #db.param(request.zos.globals.id)# and 
	mls_dir_hash IN (#db.trustedSQL("'#arraytolist(arrHash,"','")#'")#) and 
	mls_dir_deleted = #db.param(0)#
	ORDER BY tlen ASC";
	qD=db.execute("qD"); 
	//zdump(arrHash);
	//zdump(qD);
	linkStruct=structnew();
    </cfscript>
    <cfloop query="qD"><cfscript>
	curTitle=hashStruct[mls_dir_hash].title;//listgetat(mls_dir_title,listlen(mls_dir_title,"|"),"|");
	linkStruct[hashStruct[mls_dir_hash].index]=curTitle&' <a href="'&"/"&application.zcore.functions.zUrlEncode(mls_dir_title,"-")&"-"&application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_dir_url_id&"-"&mls_dir_id&'.html" style="vertical-align:super;">(X)</a> / ';
    </cfscript></cfloop><cfscript>
	//zdump(hashStruct);
	for(g2 in hashStruct){
		if(structkeyexists(linkStruct,hashStruct[g2].index) EQ false){
			propertyDataCom.setSearchCriteria(hashStruct[g2].searchCriteria);
			curStruct=propertyDataCom.searchCriteriaBackup;
			for(n in curStruct) {
				if(curStruct[n] EQ false) {
					curStruct[n]=0;
				} else if (curStruct[n] EQ true) {
					curStruct[n]=1;
				}
			}
			//zdump(curStruct);
			mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', "","",curStruct);
			ts5=StructNew();	
			ts5.table="mls_dir";
			ts5.datasource="#request.zos.zcoreDatasource#";
			ts5.struct=structnew();
			ts5.struct.mls_saved_search_id=mls_saved_search_id;
			ts5.struct.mls_dir_title=arraytolist(request.zos.listing.functions.getSearchCriteriaDisplay(hashStruct[g2].searchCriteria,true,true)," | ");
			ts5.struct.mls_dir_metakey="";
			ts5.struct.mls_dir_metadesc="";
			ts5.struct.mls_dir_full_text="";
			ts5.struct.mls_dir_hash=g2;
			ts5.struct.mls_dir_search_string=hashStruct[g2].searchString;
			ts5.struct.site_id=request.zos.globals.id;
			//writeoutput("creating hash:"&g2&"|"&mls_saved_search_id&"|"&hashStruct[curHash].title&"|"&ts5.struct.mls_dir_title&"<br />");
			mls_dir_id2=zInsert(ts5);
			curTitle=hashStruct[g2].title;//listgetat(mls_dir_title,listlen(mls_dir_title,"|"),"|");
			linkStruct[hashStruct[g2].index]=curTitle&' <a href="'&"/"&application.zcore.functions.zUrlEncode(ts5.struct.mls_dir_title,"-")&"-"&application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_dir_url_id&"-"&mls_dir_id2&'.html" style="vertical-align:super;">(X)</a> / ';
		}
	}
	for(i in linkstruct){
		writeoutput(linkStruct[i]);
		redXEnabled=true;
	}
	propertyDataCom.setSearchCriteria(temp23872);
	</cfscript>
    </cfif>
    </cfsavecontent> 
    <cfscript>
    application.zcore.template.setTag('pagenav',temppagenav);
    </cfscript>
<cfelse>
    <cfscript>
	db.sql="select * from #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
	where mls_saved_search_id =#db.param('-1')# and 
	mls_saved_search_deleted = #db.param(0)#";
	qd=db.execute("qd"); 
	zquerytostruct(qd);
    application.zcore.template.setTag("title","Real Estate Directory");
    application.zcore.template.setTag("pagetitle","Real Estate Directory");
    application.zcore.template.setTag('pagenav','<a href="/">#application.zcore.functions.zvar('homelinktext')#</a> /');
    </cfscript>
</cfif>


<p>Narrow the search results by selecting from the criteria below. <cfif redXEnabled><br />Click the (X) above next to criteria to remove those filtering options.</cfif></p>

<br />
<!--- <cfscript>
primaryCityId=application.zcore.app.getAppData("listing").sharedStruct.mls_primary_city_id;
selectedCityCount=1;
if(application.zcore.functions.zso(form, 'search_city_id') NEQ ""){
    cityIdList="'"&replace(search_city_id,",","','","ALL")&"'";
	g=listgetat(search_city_id,1);
	selectedCityCount=listlen(search_city_id);
	if(isnumeric(g)){
		primaryCityId=g;	
	}
	
}else{
    cityIdList="'"&replace(primaryCityId,",","','","ALL")&"'";
}
/*
ts.searchStruct.zselect=" listing_type.listing_type_name label, listing_type.listing_type_id value, count(listing_type.listing_type_id) count ";
ts.searchStruct.zleftjoin=" LEFT JOIN `#request.zos.zcoreDatasource#`.listing_type ON listing_type.listing_type_id = listing.listing_type_id";
ts.searchStruct.zgroupby=" group by listing.listing_type_id ";
ts.searchStruct.zorderby=" order by label";
*/

ts = StructNew();
//ts.debug=true;
backupSearch=propertyDataCom.searchCriteria.search_city_id;
propertyDataCom.searchCriteria.search_city_id="";
ts.name="search_city_id";
ts.searchStruct=structnew();
ts.searchStruct.zselect=" city.city_name label, city.city_id value, count(city.city_id) count ";
ts.searchStruct.zleftjoin=" LEFT JOIN `#request.zos.zcoreDatasource#`.#db.table("city_memory", request.zos.zcoreDatasource)# city ON city.city_id = listing.listing_city LEFT JOIN `#request.zos.zcoreDatasource#`.`city_distance_memory` city_distance ON city.city_id = city_distance.city_id";
ts.searchStruct.zgroupby=" group by city.city_id ";//having(count > 300) ";
ts.searchstruct.zwhere=" and city_parent_id = #db.param(primaryCityId)# and 
city_distance <='30'";
if(selectedCityCount NEQ 0){
	ts.searchstruct.zwhere&=" and city.city_id NOT IN (#cityIdList#)";
	ts.searchstruct.zunion="LIMIT 0,#max(0,max(selectedCityCount,10)-selectedCityCount)# UNION ALL SELECT c2.city_name label,c2.city_id city_id, 100000000 count FROM `city_memory` c2 WHERE c2.city_id IN (#cityIdList#)";
}else{
	ts.searchstruct.perpage=10;
}
ts.searchStruct.zorderby=" order by count desc";
rs2 = propertyDataCom.getSearchData(ts);
propertyDataCom.searchCriteria.search_city_id=backupSearch;
//writeoutput('primary city:'&primaryCityId);
//zdump(rs);
//zabort();
</cfscript>
<cfif rs2.labels NEQ "">
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts = StructNew();
ts.name="search_city_id";
ts.enableTyping=true;
ts.overrideOnKeyUp=true;
//ts.onchange="alert('test onchange');";
ts.onkeyup="zMlsCheckCityLookup(event, this,document.getElementById(this.id+'v'),'city_id'); zKeyboardEvent(event, this,document.getElementById(this.id+'v'));";
//ts.onEnterJS="";
//ts.onkeypress="";
ts.onButtonClick="var m1=document.getElementById('#ts.name#_zmanual');if(zCurrentCityLookupLabel!='' && zCurrentCityLookupLabel != m1.value && zCurrentCityLookupLabel.substr(0,m1.value.lenght) == m1.value){m1.value=zCurrentCityLookupLabel;}";
ts.range=false;
ts.allowAnyText=false;
//ts.disableSpiderAfter=3;
ts.disableSpider=true;
//ts.disableHidden=true;
ts.listLabelsDelimiter = chr(9);
ts.listValuesDelimiter = chr(9);
ts.listLabels=rs2.labels;
ts.listValues =rs2.values;
//ts.listURLs=rs.URLs;
//application.zcore.functions.zInputSelectBox(ts);
ts.output=false;
rs=application.zcore.functions.zInputLinkBox(ts);
ts=StructNew();
ts.zExpOptionValue=rs.zExpOptionValue;
ts.value=rs.value;
ts.label="City:";
ts.contents=rs.output;
ts.height=(selectedCityCount*20)+45 + ((listlen(rs2.labels,chr(9))-selectedCityCount) * 17);
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=true;
zExpOption(ts);
</cfscript>
</div>
</cfif> --->
<cfif search_city_id EQ "">
<cfscript>
ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_city_id";
ts.searchStruct=structnew();
ts.zReturnSimpleQuery=true;
ts.searchStruct.removeValues=search_city_id;
ts.searchStruct.contentTableEnabled=false;
//ts.searchStruct.lookupName="city";
ts.searchStruct.zselect=" city_name label, listing_city value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zleftjoin= dead " INNER JOIN #db.table("city_memory", request.zos.zcoreDatasource)# city ON city.city_id = listing.listing_city ";
ts.searchStruct.zgroupby=" group by listing_city ";
ts.searchStruct.zwhere=" and listing_city not in ('','0') ";
ts.searchStruct.zorderby=" order by label";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.count GTE 1>
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts.label="City:";
ts.contents=rs2.output;
ts.height=35+(rs2.count * 14);
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>
</div>
</cfif>
</cfif>
<!---<script src="#request.zos.listing.cityLookupFileName#"></script>
--->
<!---<tr><td colspan="2">
<cfscript>
ts=StructNew();
ts.name="search_rate_low";
ts.name2="search_rate_high";
ts.leftLabel="$";
ts.middleLabel=" to $";
ts.range=true;
//ts.onchange="document.getElementById('zist').value=this.value;";
ts.fieldWidth="50";
ts.width="150";
ts.listLabels="0|25,000|50,000|75,000|100,000|125,000|150,000|175,000|200,000|225,000|250,000|275,000|300,000|325,000|350,000|400,000|450,000|500,000|600,000|700,000|800,000|900,000|1,000,000|1,500,000|2,000,000|3,000,000|4,000,000|5,000,000";
ts.listValues="0|25000|50000|75000|100000|125000|150000|175000|200000|225000|250000|275000|300000|325000|350000|400000|450000|500000|600000|700000|800000|900000|1000000|1500000|2000000|3000000|4000000|5000000";
ts.listLabelsDelimiter="|";
ts.listValuesDelimiter="|";
ts.output=false;
rs=zInputSlider(ts);

ts=StructNew();
ts.zExpOptionValue=rs.zExpOptionValue;
ts.value=rs.value;
ts.label="Price:";
ts.contents=rs.output;
ts.height="65";
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=true;
zExpOption(ts);
</cfscript>
--->
<!---</div>
<cfscript>
ts = StructNew();
//ts.debug=true;
ts.name="search_beds";
ts.searchStruct=structnew();
ts.searchStruct.zselect=" listing_beds label, 0 value, 0 count ";
ts.searchstruct.zwhere=" and listing_beds not in ('','0','#zescape(search_beds)#') ";
ts.searchStruct.zorderby=" order by label asc LIMIT 0,1";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.labels NEQ "">
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts=StructNew();
ts.name="search_bedrooms_low";
ts.name2="search_bedrooms_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="22";
ts.width="150";
ts.listValues="1,2,3,4,5,6,7";
ts.listValuesDelimiter=",";
ts.output=false;
rs=zInputSlider(ts);

ts=StructNew();
ts.zExpOptionValue=rs.zExpOptionValue;
ts.value=rs.value;
ts.label="Beds:";
ts.contents=rs.output;
ts.height="60";
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>
</div>
</cfif>--->

<!---<cfscript>
ts = StructNew();
//ts.debug=true;
ts.name="search_baths";
ts.searchStruct=structnew();
ts.searchStruct.zselect=" listing_baths label, 0 value, 0 count ";
ts.searchstruct.zwhere=" and listing_baths not in ('','0','#zescape(search_baths)#') ";
ts.searchStruct.zorderby=" order by label asc LIMIT 0,1";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.labels NEQ "">
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts=StructNew();
ts.name="search_bathrooms_low";
ts.name2="search_bathrooms_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="22";
ts.width="150";
ts.listValues="1,2,3,4,5,6,7";
ts.listValuesDelimiter=",";
ts.output=false;
rs=zInputSlider(ts);

ts=StructNew();
ts.zExpOptionValue=rs.zExpOptionValue;
ts.value=rs.value;
ts.label="Baths:";
ts.contents=rs.output;
ts.height="60";
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>
</div>
</cfif>
--->
<!---<cfscript>
ts = StructNew();
//ts.debug=true;
ts.name="search_square_feet";
ts.searchStruct=structnew();
ts.searchStruct.zselect=" listing_square_feet label, 0 value, 0 count ";
ts.searchstruct.zwhere=" and listing_square_feet not in ('','0') ";
if(notdefault){
 ts.searchStruct.zwhere=" and '#zescape(search_sqfoot_low)#-#zescape(search_sqfoot_high)#') ";
}
ts.searchStruct.zorderby=" order by label asc LIMIT 0,1";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.labels NEQ "">
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts=StructNew();
ts.name="search_sqfoot_low";
ts.name2="search_sqfoot_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="33";
ts.width="150";
ts.listLabels="0,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000,3250,3500,4000,4500,5000,6000,7000,8000,9000,10000,15000,20000";
arrL=listtoarray(ts.listLabels,",");
for(i=1;i LTE arraylen(arrL);i++){
	arrL[i]=arrL[i]&"sqft ("&round(arrL[i]/10.7639)&"&##178;)";
}
ts.listLabels=arraytolist(arrL,",");
ts.listValues = "0,500,750,1000,1250,1500,1750,2000,2250,2500,2750,3000,3250,3500,4000,4500,5000,6000,7000,8000,9000,10000,15000,20000";
ts.listValuesDelimiter=",";
ts.output=false;
rs=zInputSlider(ts);

ts=StructNew();
ts.zExpOptionValue=rs.zExpOptionValue;
ts.value=rs.value;
ts.label="SQFT:";
ts.contents=rs.output;
ts.height="60";
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>

</div>
</cfif>
--->
<!---<cfscript>
ts = StructNew();
//ts.debug=true;
ts.name="search_acreage";
ts.searchStruct=structnew();
ts.searchStruct.zselect=" listing_acreage label, 0 value, 0 count ";
ts.searchstruct.zwhere=" and listing_acreage not in ('','0','#zescape(search_acreage)#') ";
ts.searchStruct.zorderby=" order by label asc LIMIT 0,1";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.labels NEQ "">
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts=StructNew();
ts.name="search_acreage_low";
ts.name2="search_acreage_high";
ts.range=true;
ts.middleLabel=" to ";
ts.fieldWidth="22";
ts.width="150";
ts.listLabels = "0|1|2|3|4|5|10|20|50|100";
ts.listValues = "0|1|2|3|4|5|10|20|50|100";
ts.listLabelsDelimiter="|";
ts.listValuesDelimiter="|";
ts.output=false;
rs=zInputSlider(ts);

ts=StructNew();
ts.zExpOptionValue=rs.zExpOptionValue;
ts.value=rs.value;
ts.label="Acreage:";
ts.contents=rs.output;
ts.height="60";
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>

</div>
</cfif>
--->

<cfif search_county EQ "">
<cfscript>
ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_county";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.removeValues=search_county;
ts.searchStruct.lookupName="county";
ts.searchStruct.zselect=" listing_county value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_county ";
ts.searchStruct.zwhere=" and listing.listing_county not in ('','0') ";
ts.searchStruct.zorderby=" order by value";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.count GTE 1>
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts.label="County:";
ts.contents=rs2.output;
ts.height=35+(rs2.count * 14);
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>
</div>
</cfif>
</cfif>

<cfif search_listing_type_id EQ "">
<cfscript>
ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_listing_type_id";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.removeValues=search_listing_type_id;
ts.searchStruct.lookupName="listing_type";
ts.searchStruct.zselect=" listing_type_id value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_type_id ";
ts.searchStruct.zwhere=" and listing.listing_type_id not in ('','0') ";
ts.searchStruct.zorderby=" order by value";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.count GTE 1>
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts.label="Property Type:";
ts.contents=rs2.output;
ts.height=35+(rs2.count * 14);
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>
</div>
</cfif>
</cfif>

<cfif search_listing_sub_type_id EQ "">
<cfscript>
ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_listing_sub_type_id";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.removeValues=search_listing_sub_type_id;
ts.searchStruct.lookupName="listing_sub_type";
ts.searchStruct.zselect=" listing_sub_type_id value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_sub_type_id ";
ts.searchStruct.zwhere=" and listing.listing_sub_type_id not in ('','0') ";
ts.searchStruct.zorderby=" order by value";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.count GTE 1>
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts.label="Property Sub Type:";
ts.contents=rs2.output;
ts.height=35+(rs2.count * 14);
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>
</div>
</cfif>
</cfif>

<cfscript>
ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_view";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.removeValues=search_view;
ts.searchStruct.lookupName="view";
ts.searchStruct.zselect=" listing_view value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_view ";
ts.searchStruct.zwhere=" and listing.listing_view not in ('','0') ";
ts.searchStruct.zorderby=" order by value";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.count GTE 1>
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts.label="View:";
ts.contents=rs2.output;
ts.height=35+(rs2.count * 14);
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>
</div>
</cfif>


<cfscript>
ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_status";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.removeValues=search_status;
ts.searchStruct.lookupName="status";
ts.searchStruct.zselect=" listing_status value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_status ";
ts.searchStruct.zwhere=" and listing.listing_status not in ('','0') ";
ts.searchStruct.zorderby=" order by value";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.count GTE 1>
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts.label="Sale Type:";
ts.contents=rs2.output;
ts.height=35+(rs2.count * 14);
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>
</div>
</cfif>

<cfscript>
ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_style";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.removeValues=search_style;
ts.searchStruct.lookupName="style";
ts.searchStruct.zselect=" listing_style value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_style ";
ts.searchStruct.zwhere=" and listing.listing_style not in ('','0') ";
ts.searchStruct.zorderby=" order by value";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.count GTE 1>
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts.label="Style:";
ts.contents=rs2.output;
ts.height=35+(rs2.count * 14);
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>
</div>
</cfif>


<cfscript>
ts = StructNew();
ts.debug=debugSearchDir;
ts.name="search_frontage";
ts.searchStruct=structnew();
ts.searchStruct.contentTableEnabled=false;
ts.searchStruct.removeValues=search_frontage;
ts.searchStruct.lookupName="frontage";
ts.searchStruct.zselect=" listing_frontage value, COUNT(listing.listing_id) COUNT ";
ts.searchStruct.zgroupby=" group by listing_frontage ";
ts.searchStruct.zwhere=" and listing.listing_frontage not in ('','0') ";
ts.searchStruct.zorderby=" order by value";
rs2 = propertyDataCom.getSearchData(ts);
</cfscript>
<cfif rs2.count GTE 1>
<div style="width:165px; float:left; white-space:nowrap; ">
<cfscript>
ts.label="Frontage:";
ts.contents=rs2.output;
ts.height=35+(rs2.count * 14);
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>
</div>
</cfif>

<!---<div style="width:165px; float:left; white-space:nowrap; ">

<cfsavecontent variable="featureHTML">
<cfscript>
ts=StructNew();
ts.label="Subdivision:";
ts.name="search_subdivision";
ts.size="10";
zInput_Text(ts);
</cfscript>
<hr />--->

<!---<cfscript>
ts=StructNew();
ts.label="Remarks:";
ts.name="search_remarks";
ts.size="10";
zInput_Text(ts);
</cfscript>
<hr />
<cfscript>
ts = StructNew();
ts.name="search_with_pool";
ts.disableExpOptionValue=true;
ts.listLabels ="Want a pool?";
ts.listValues ="1";
ts.output=true;
zInput_Checkbox(ts);
</cfscript>--->

<!---<cfscript>
ts = StructNew();
ts.name="search_with_photos";
ts.disableExpOptionValue=true;
ts.listLabels ="Must have photos?";
ts.listValues ="1";
ts.output=true;
zInput_Checkbox(ts);
</cfscript>--->

<!---<cfscript>
ts = StructNew();
ts.name="search_exact_match";
ts.disableExpOptionValue=true;
ts.listLabels ="Exact Matches Only?";
ts.listValues ="1";
ts.output=true;
zInput_Checkbox(ts);
</cfscript>--->

<!---<cfscript>
ts = StructNew();
ts.name="search_surrounding_cities";
ts.disableExpOptionValue=true;
ts.listLabels ="Surrounding Cities?";
ts.listValues ="1";
ts.output=true;
zInput_Checkbox(ts);
</cfscript>
</cfsavecontent>
<cfscript>
ts=StructNew();
//ts.zExpOptionValue=rs.zExpOptionValue;
ts.label="More Options:";
ts.contents=featureHTML;
ts.height=25 + (8 * 18);
ts.width="165";
ts.zMotionEnabled=true;
ts.zMotionOpen=false;
zExpOption(ts);
</cfscript>--->

<br style="clear:both;" /><br />
<table style="border-spacing:10px;width:700px;">
<tr>
<td id="mlsResults" style="border:1px solid ##999999;"><br />
<cfscript>
	structdelete(form,'fieldnames');
	for(i in form){
		form[i]=urldecode(form[i]);	
	}
	//zdump(form);
	
	propertyDataCom.enableListingTrack=true;
		ts = StructNew();
		ts.offset = zIndex-1;
		perpageDefault=10;
		perpage=10;//zso(form, 'perpage',true,perpagedefault);
		perpage=max(1,min(perpage,100));
		ts.perpage = perpage;
		ts.distance = 10; // in miles
		//ts.searchCriteria=structnew();
		//structappend(ts.searchCriteria,form);
		//zdump(form);
		ts.debug=debugSearchDir;
		//writeoutput('Searching<br />');
		returnStruct = propertyDataCom.getProperties(ts);
		structdelete(variables,'ts');
		//	zdump(returnstruct);
		start49=gettickcount();
		writeoutput('<script>/* <![CDATA[ */ setTimeout("setMLSCount('&returnStruct.count&');",100); /* ]]> */</script>');
		if(returnStruct.count NEQ 0){	
			/*
			*/
			//make an ajax version
			// required
			searchStruct = StructNew();
			// optional
			searchStruct.showString = "";
			// allows custom url formatting
			//searchStruct.parseURLVariables = true;
			searchStruct.indexName = 'zIndex';
			searchStruct.url = "/z/listing/search-form-dir/index";
			if(structkeyexists(form, 'searchId')){
				searchStruct.url &= "?searchId=#form.searchid#"; 
				searchStruct.index = form.zIndex;//application.zcore.status.getField(form.searchid, "zIndex",1);
			}else{
				searchStruct.index=1;
			}
			searchStruct.buttons = 5;
			searchStruct.count = returnStruct.count;
			// set from query string or default value
			searchStruct.perpage = perpageDefault;
			
			ts = StructNew();
			ts.dataStruct = returnStruct;
			ts.navStruct=searchStruct;
			propDisplayCom.init(ts);
		// REMEMBER: javascript doesn't execute when placed in innerHTML
		
		res=propDisplayCom.display();
		//writeoutput('<textarea name="sup13243" style="width:100px; height:50px;">#htmleditformat(res)#</textarea>');
		writeoutput(res);
		//zabort();
		}
		</cfscript>
</td>
</tr>
</table>
<br />
Time: #((getTickCount()-start49)/1000)&" seconds"#<br />
Time: #((getTickCount()-start48)/1000)&" seconds"#
<!--- #zdump(request.zos.arrQueryLog)# --->
</cffunction>
</cfoutput> 
</cfcomponent> --->