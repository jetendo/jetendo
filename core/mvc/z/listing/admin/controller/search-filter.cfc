<cfcomponent>
<cfoutput>
<cffunction name="update" localmode="modern" access="remote" roles="member">

	<cfscript>
	var ts=0;
	var qId=0;
	var qM=0;
	var i=0;
	var arrFields=0;
	var field=0;
	var db=request.zos.queryObject;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Listing Search Filter");
	if(not structkeyexists(form, 'filterFields')){
		echo('Invalid request.');
		abort;
	}
	
	arrFields=listtoarray(form.filterFields);
	for(i=1;i LTE arraylen(arrFields);i++){
		form[arrFields[i]&"_sort"]=99;
	}
	arrFields=listtoarray(form.sortFields);
	for(i=1;i LTE arraylen(arrFields);i++){
		form[arrFields[i]&"_sort"]=i;
	}
	arrFields=listtoarray(form.filterFields);
	for(i=1;i LTE arraylen(arrFields);i++){
		field=arrFields[i];
		// searchable|opened|sorting|filtertype
		form[field]=application.zcore.functions.zso(form, '#field#_searchable')&","&application.zcore.functions.zso(form, '#field#_opened')&","&application.zcore.functions.zso(form, '#field#_sort')&","&application.zcore.functions.zso(form, '#field#_filtertype');	
	}
	// clear old fields no longer used...
	db.sql="SHOW FIELDS FROM "&request.zos.queryObject.table("mls_saved_search", request.zos.zcoreDatasource);
	qM=db.execute("qM"); 
	for(i=1;i LTE qM.recordcount;i++){
		if(structkeyexists(form, qM.field[i]) EQ false and left(qM.field[i],len("search_")) EQ "search_"){
			form[qM.field[i]]="";
		}
	}
	db.sql="SELECT mls_saved_search_id, mls_filter_id 
	FROM #request.zos.queryObject.table("mls_filter", request.zos.zcoreDatasource)# mls_filter 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	mls_filter_deleted = #db.param(0)#";
	qId=db.execute("qId"); 
	if(qId.recordcount NEQ 0 and qId.mls_saved_search_id NEQ 0){
		form.mls_saved_search_id=qid.mls_saved_search_id;
		form.mls_filter_id=qId.mls_filter_id;
	}else{
		form.mls_saved_search_id="";
	}
	form.site_id = request.zos.globals.id;
	form.mls_saved_search_id=request.zos.listing.functions.zMLSSearchOptionsUpdate('update', form.mls_saved_search_id, '', form);
	ts=structnew();
	ts.datasource="#request.zos.zcoreDatasource#";
	ts.table="mls_filter";
	ts.struct=form;
	if(qId.recordcount EQ 0){
		application.zcore.functions.zInsert(ts);
	}else{
		application.zcore.functions.zUpdate(ts);
	}
	application.zcore.listingCom.updateSearchFilter();
	application.sitestruct[request.zos.globals.id].searchformresetdate=now();
	
	application.zcore.status.setStatus(request.zsid,"Saved successfully.");
	application.zcore.functions.zRedirect("/z/listing/admin/search-filter/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var f21=0;
	var arrCur=0;
	var g=0;
	var field=0;
	var returnStruct=0;
	var arrDefaultSort=0;
	var returnStruct2=0;
	var nodragstruct=0;
	var tempTableRow=0;
	var ts99=0;
	var q2=0;
	var propertyDataCom=0;
	var arrCurrentSort=0;
	var arrNoSort=0;
	var defaultOpened=0;
	var rowStruct=0;
	var ts=0;
	var arrSorted=0;
	var newAction=0;
	var qM=0;
	var qM2=0;
	var arrField22=0;
	var i=0;
	var cts=0;
	var arrKeys=0;
	application.zcore.functions.zSetPageHelpId("6.4");
    application.zcore.adminSecurityFilter.requireFeatureAccess("Listing Search Filter");
	var db=request.zos.queryObject;
    if(application.zcore.app.siteHasApp("listing") EQ false){
        application.zcore.status.setStatus(request.zsid,"Access denied");
        application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
    }
    form.content_parent_id=application.zcore.functions.zso(form, 'content_parent_id',true);
    request.zMLSHideCount=true;

	db.sql="select * from #request.zos.queryObject.table("mls_filter", request.zos.zcoreDatasource)# mls_filter 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	mls_filter_deleted = #db.param(0)#";
	qM2=db.execute("qM2"); 
	application.zcore.functions.zQueryToStruct(qM2, form);
	
	q2=request.zos.listing.functions.zGetSavedSearchQuery(form.mls_saved_search_id);
	application.zcore.functions.zquerytostruct(q2,form);
	</cfscript>
        
    <h1>Filter MLS</h1>
<script>
zDisableSearchFilter=1;
</script>
<cfscript>
//application.zcore.functions.zdump(application.zcore.status.getStruct(form.searchid));
ts=StructNew();
ts.name="zMLSSearchForm";
ts.ajax=false;
newAction="update";
ts.class="zFormCheckDirty";
ts.enctype="multipart/form-data";
ts.action="/z/listing/admin/search-filter/update?zdisablesearchfilter=1";
ts.method="post";
//ts.onLoadCallback="loadMLSResults";
ts.onChangeCallback="getMLSCount";
ts.successMessage=false;
application.zcore.functions.zForm(ts);
</cfscript>
		<button type="submit" name="submitPage1" value="submitPage1" class="z-button">Update Search Filter</button><br />
<br />
        <h2>Specify criteria and choose to include or exclude listings that match.</h2>

<cfscript>
form.zdisablesearchfilter=1;
</cfscript>
<!--- <cfscript>
propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
ts = StructNew();
ts.offset = 0;
ts.perpage = 1;
ts.distance = 30; // in miles
ts.onlyCount=true;
//ts.debug=true;
ts.searchCriteria=duplicate(form);
for(i in ts.searchCriteria){
	if(ts.searchCriteria[i] EQ 0 or ts.searchCriteria[i] EQ ""){	
		structdelete(ts.searchCriteria, i);
	}
}
returnStruct = propertyDataCom.getProperties(ts);
propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
form.zdisablesearchfilter=1;
structdelete(ts, 'searchCriteria');
//ts.debug=true;
returnStruct2 = propertyDataCom.getProperties(ts);
</cfscript>

<h2>There are currently #numberformat(returnStruct2.count-returnStruct.count)# of #numberformat(returnStruct2.count)# listings that are being filtered with the settings below.</h2> --->

	<cfset form.action="form">
	<cfset request.contentEditor=true>
	<cfscript>request.zos.listing.functions.zMLSSetSearchStruct(form, form);
	local.tempCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.search-form");
	local.tempCom.index();
	</cfscript>
        <br />
        Zip Codes: <input type="text" name="search_zip" size="70" value="#htmleditformat(form.search_zip)#" /> (Comma separated list)
        <br />
        <br />
       Subdivision: <input type="text" name="search_subdivision" size="70" value="#htmleditformat(form.search_subdivision)#" /> (Comma separated list)
        <br />
        <br />

        <h2>Search Filter Options</h2>   
        <p>You can select whether to filter the search form or to remove the listings from the entire web site.  If you remove them from the web site, search engines and users won't be able to search or find those listings anymore.  You can also drag the rows up and down to reorder the search criteria on the forms throughout the web site.  Example: Selecting a price range of $100,000 to $200,000 and clicking "Hide Non-Matching Options + Listings" would prevent users from finding any homes on the entire web site not within that price range.</p>
        <cfscript>
		
		db.sql="SHOW FIELDS FROM "&request.zos.queryObject.table("mls_filter", request.zos.zcoreDatasource);
		qM=db.execute("qM"); 
		arrDefaultSort=listtoarray("filter_city_id,filter_rate,filter_listing_type_id,filter_listing_sub_type_id,filter_bedrooms,filter_bathrooms,filter_sqfoot,filter_year_built,filter_acreage,filter_county,filter_view,filter_status,filter_liststatus,filter_style,filter_frontage,filter_region,filter_tenure,filter_parking,filter_condition,filter_near_address,filter_near_coordinates,filter_more_options,filter_condoname,filter_subdivision,filter_remarks,filter_remarks_negative,filter_zip,filter_address,filter_within_map");
		arrCurrentSort=arraynew(1);
		/*if(filter_city_id NEQ ""){
			for(i=1;i LTE arraylen(arrDefaultSort);i++){
				
			}
		}*/
		defaultOpened=structnew();
		defaultOpened["filter_more_options"]=true;
		defaultOpened["filter_city_id"]=true;
		defaultOpened["filter_rate"]=true;
		defaultOpened["filter_bedrooms"]=true;
		defaultOpened["filter_bathrooms"]=true;
		defaultOpened["filter_listing_type_id"]=true;
		nodragstruct=structnew();
		nodragstruct["filter_remarks"]=true;
		nodragstruct["filter_remarks_negative"]=true;
		nodragstruct["filter_subdivision"]=true;
		nodragstruct["filter_within_map"]=true;
		nodragstruct["filter_condoname"]=true;
		nodragstruct["filter_zip"]=true;
		nodragstruct["filter_address"]=true;
		
		//currentSortOrder&=",filter_remarks,filter_remarks_negative,filter_subdivision,filter_within_map,filter_condoname,filter_zip,filter_address";
		arrField22=arraynew(1);
		cts=structnew();
		cts["rate"]="price range";
		cts["city id"]="city";
		cts["listing type id"]="property type";
		cts["listing sub type id"]="property sub type";
		cts["near address"]="near location";
		cts["near coordinates"]="near coordinates";
		cts["status"]="sale type";
		cts["liststatus"]="listing status";
		arrNoSort=arraynew(1);
		rowStruct=structnew();
		</cfscript>
        <script src="/z/javascript/zTableDragAndDrop.js"></script>
        <style>
		##zDragTable1 td{ border-bottom:1px solid ##999; padding-right:0px;}
		</style>
        <table id="zDragTable1" class="table-list" style="border-spacing:0px; width:100%;">
        <tr noDrop="true" noDrag="true"><th colspan="2" style="width:135px;">Criteria</th><th>Searchable</th><th>Opened</th><th style="width:178px;">Hide Non-Matching</th><th style="width:300px;">or Hide Matching</tr>
        <cfloop from="1" to="#arraylen(arrDefaultSort)#" index="g">
			<cfscript>
            field=arrDefaultSort[g];
			arrCur=listtoarray(application.zcore.functions.zso(form, ''&field));	
			ts99=structnew();
			if(arraylen(arrCur) GTE 3){
				ts99.sort=arrCur[3];
			}else{
				ts99.sort=g;	
			}
			if(arraylen(arrCur) GTE 1){
				ts99.searchable=arrCur[1];
			}else{

				ts99.searchable=1;	
			}
			if(arraylen(arrCur) GTE 2){
				ts99.opened=arrCur[2];
			}else if(structkeyexists(defaultOpened,field)){
				ts99.opened=1;	
			}else{
				ts99.opened=0;	
			}
			if(structkeyexists(nodragstruct,field)){
				ts99.draggable=0;	
				ts99.opened=99;
				ts99.sort=99;
			}else{
				ts99.draggable=1;
			}
			if(arraylen(arrCur) GTE 4){
				ts99.filtertype=arrCur[4];
			}else{
				ts99.filtertype=0;
			}
			</cfscript>
            <cfsavecontent variable="tempTableRow">
            <cfscript>
		f21=replace(replace(field,"filter_",""),"_"," ","ALL");
		if(structkeyexists(cts,f21)){
			f21=cts[f21];	
		}
		</cfscript>
		<tr <cfif structkeyexists(nodragstruct, field)> noDrop="true" noDrag="true"</cfif>><td style="width:15px;"><cfif structkeyexists(nodragstruct, field) EQ false><img src="/z/a/images/dragicon.jpg"><cfelse>&nbsp;</cfif></td><td style="white-space:nowrap; width:120px;">
          #f21#
		</td><td style="font-size:10px;">
        <cfscript>
		form[field&"_searchable"]=ts99.searchable;
		ts = StructNew();
		ts.name = "#field#_searchable";
		ts.style="border:none;background:none;";
		ts.labelList = "Yes,No";
		ts.valueList = "1,0";
		ts.hideSelect=true;
		writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
		</cfscript></td><td style="font-size:10px;">
        <cfscript>
		if(ts99.opened EQ 99){
			writeoutput('<input type="hidden" name="#field#_opened" value="0">');	
		}else{
			form[field&"_opened"]=ts99.opened;
			ts = StructNew();
			ts.name = "#field#_opened";
			ts.style="border:none;background:none;";
			ts.labelList = "Yes,No";
			ts.valueList = "1,0";
			ts.hideSelect=true;
			writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
		}
		</cfscript></td><td style="font-size:10px;" colspan="2">
        <cfscript>
		if((field EQ "filter_more_options" or ts99.sort EQ 99) and field NEQ "filter_zip" and field NEQ "filter_subdivision"){
			writeoutput('<input type="hidden" name="#field#_filtertype" value="0">');	
		}else{
		form[field&"_filtertype"]=ts99.filtertype;
		ts = StructNew();
		ts.name = "#field#_filtertype";
		ts.style="border:none;background:none;";
		ts.labelList = "Options,Options + Listings,Options,Options + Listings";
		ts.valueList = "0,1,2,3";
		ts.hideSelect=true;
		writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
		}
		</cfscript> </td></tr>
            </cfsavecontent>
            <cfscript>
			if(ts99.draggable EQ 0){
				arrayappend(arrNoSort,tempTableRow);	
			}else{
				arrayappend(arrField22,field);
				ts99.field=field;
				ts99.tableRow=tempTableRow;
				rowStruct["row"&g]=ts99;
			}
			</cfscript>
        </cfloop>
        
        <cfscript>
		arrKeys=structsort(rowStruct,"numeric","asc","sort");
		arrSorted=arraynew(1);
		for(i=1;i LTE arraylen(arrKeys);i++){
			arrayAppend(arrSorted, rowStruct[arrKeys[i]].field);
			writeoutput(rowStruct[arrKeys[i]].tableRow);
		}
		writeoutput(' <tr noDrop="true" noDrag="true"><th colspan="6">The following options can not be sorted or filtered</th></tr>'&arraytolist(arrNoSort,""));
		</cfscript>
</table>
<input type="hidden" name="sortfields" id="sortfields" value="#arraytolist(arrSorted)#">
<input type="hidden" name="filterFields" value="#arraytolist(arrDefaultSort)#">
<script>
var table = document.getElementById('zDragTable1');
var tableDnD = new TableDnD();
function zDropFilterTable(table, row, startIndex, endIndex){
	var d1=document.getElementById("sortfields");
	var arrSearchFilterFields=d1.value.split(",");
	var backup=arrSearchFilterFields[startIndex-1];
	arrSearchFilterFields.splice(startIndex-1,1);
	arrSearchFilterFields.splice(endIndex-1,0,backup);
	d1.value=arrSearchFilterFields.join(",");
}
tableDnD.init(table,zDropFilterTable);
</script>
    <br />


	<button type="submit" name="submitPage" value="submitPage" class="z-button">Update Search Filter</button>
    #application.zcore.functions.zEndForm()# 

</cffunction>
</cfoutput>
</cfcomponent>