<cfcomponent displayname="Property Display" output="no">
<cfoutput>
<cfscript>
this.isPropertyDisplayCom=true;
</cfscript>

<!--- 
ts = StructNew();
ts.property_landing_type_id = property_landing_type_id;
ts.baseCity = city_name; 
ts.query = qProperties;
ts.searchScript=false;
propertyDisplayCom.init(ts);
 --->
<cffunction name="init" localmode="modern" output="false" returntype="any">
	<cfargument name="optionStruct" type="struct" required="yes">
	<cfscript>
	this.optionStruct=StructNew();
	this.optionStruct.compact=false;
	this.optionStruct.contentDetailView=false;
	this.optionStruct.getDetails=true;
	this.optionStruct.groupBedrooms=false;
	this.optionStruct.oneLineLayout=false;
	this.optionStruct.thumbnailLayout=false;
	this.optionStruct.mapFormat=false;
	this.optionStruct.emailFormat=false;
	this.optionStruct.classifiedFlyerAds=false;
	this.optionstruct.search_result_layout=-1;
	this.optionStruct.descriptionLink=false;
	this.optionStruct.descriptionLinkRemarks=false;
	this.optionStruct.rss=false;
	this.optionStruct.output=true;
	this.optionStruct.plainText=false;
	this.optionstruct.storeCopy=false;
	this.optionStruct.featuredFormat=false;
	this.optionStruct.compactWithLinks=false;
	// cookie holds the old date - set to session
	if(isDefined('request.zsession.lastVisitDate') EQ false){
		if(isDefined('cookie.lastVisitDate') and isdate(cookie.lastVisitDate)){
			request.zsession.lastVisitDate=cookie.lastVisitDate;
		}else{
			request.zsession.lastVisitDate=request.zos.mysqlnow;
		}
		// cookie holds the current date
		cookie.lastVisitDate=DateFormat(request.zsession.lastVisitDate,'yyyy-mm-dd')&' '&TimeFormat(request.zsession.lastVisitDate,'HH:mm:ss');		
	}
	// use session old date for everything until session expires
	this.optionStruct.lastVisitDate=request.zsession.lastVisitDate;
	StructAppend(this.optionStruct, arguments.optionStruct,true);
	this.optionStruct.lastVisitDate=parsedatetime(DateFormat(this.optionStruct.lastVisitDate,'yyyy-mm-dd')&' 00:00:00');
	if(isDefined('this.optionStruct.dataStruct') EQ false){
		application.zcore.template.fail("propertyDisplay.cfc: init: optionStruct.dataStruct is required.");
	}else{
		this.dataStruct = this.optionStruct.dataStruct;
	}
	if(isDefined('arguments.optionStruct.navStruct') and isStruct(arguments.optionStruct.navStruct) EQ false){
		StructDelete(this.optionStruct, 'navStruct');
	}
	// show alternate display for search pages
	if(isDefined('this.optionStruct.searchScript') and this.optionStruct.searchScript){
		variables.searchScript=true;
	}
	</cfscript>
</cffunction>

<cffunction name="checkInit" localmode="modern" output="false" returntype="any">
	<cfscript>
		if(isDefined('this.optionStruct') EQ false){
			application.zcore.template.fail("propertyDisplay.cfc: display: you must run propertyDisplay.init() with the correct optionStruct arguments.");
		}
		</cfscript>
</cffunction>


<cffunction name="getArray" localmode="modern" output="no" returntype="any">
	<cfargument name="skipLastRecord" type="boolean" default="#false#" required="no">
	<cfscript> 
	var rs=structnew(); 
	rs.count=this.datastruct.count;
	rs.arrData=[];
	ts={};
	ts.url="";
	ts.mls_id="";
	ts.listing_id="";
	ts.city="";
	ts.city_id="";
	ts.view="";
	ts.type="";
	ts.bedrooms="";
	ts.bathrooms="";
	ts.halfbaths="";
	ts.square_footage="";
	ts.pool="";
	ts.price="";
	ts.subdivision="";
	ts.photo1="";
	ts.description="";
	ts.virtual_tour="";
	ts.condoname="";
	ts.address="";
	ts.style="";
	ts.frontage="";
	ts.tenure="";
	ts.zip="";
	ts.condition="";
	ts.parking="";
	ts.region="";
	ts.status="";
	ts.yearbuilt="";
	ts.photocount="";
	ts.pool="";
	ts.listdate="";
	ts.liststatus="";
	ts.lot_square_footage="";

	ts.latitude="";
	ts.longitude="";
	ts.price="";
	if(structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct, 20)){
		ts.zoning="";
		ts.taxamount="";
		ts.listdate="";
		ts.priceoriginal="";
		ts.pricesold="";
		ts.solddate="";
		ts.daysonmarket="";
		ts.schoolelem="";
		ts.schooljunior="";
		ts.schoolhigh="";
		ts.assessamountimprove="";
		ts.assessamountland="";
		ts.assessedvalue="";
		ts.occupancy="";
		ts.remodelyear="";
		ts.taxparcelid="";
		
	}
	
	rowCount=arrayLen(this.dataStruct.arrData);
	if(arguments.skipLastRecord){
		rowCount--;
	}

	for(i=1;i LTE rowCount;i++){
		row=this.dataStruct.arrData[i];
		currentRow=i;

		idx=structnew();
		idx.arrayIndex=i;
		idx.listing_id=row.listing_id; 
		idx.mls_id=listgetat(row.listing_id,1,"-");
 
		request.lastPhotoId=row.listing_id;
		photo1="";
		if(this.optionStruct.getDetails){
			structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].getDetails(row,currentrow), true);
		}else{
			structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].baseGetDetails(row,currentrow), true);
			if(structkeyexists(request.zos.listingMlsComObjects[idx.mls_id], 'sysidfield2')){
				photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1, idx.sysidfield, idx.sysidfield2);
			}else if(structkeyexists(request.zos.listingMlsComObjects[idx.mls_id], 'sysidfield')){
				photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1, idx.sysidfield);
			}else{
				photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1);
			}
		}
		photo1Full=photo1;
		if(photo1 NEQ ""){	
			photo1=application.zcore.listingCom.getThumbnail(photo1, request.lastPhotoId, 1, form.pw, form.ph, form.pa);
		}
		titleStruct = request.zos.listing.functions.zListinggetTitle(idx);
		propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#idx.urlMlsId#-#idx.urlMLSPId#.html';
		if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
			propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
		}
		t2=duplicate(ts);
		t2.photo1Full=photo1Full;
		t2.tenure=idx.listingTenure;
		if(row.listing_square_feet neq '' and row.listing_square_feet NEQ 0){
			t2.square_footage=row.listing_square_feet;
		}else if(row.listing_lot_square_feet neq '' and row.listing_lot_square_feet NEQ 0){
			t2.square_footage=row.listing_lot_square_feet;
		}else{
			t2.square_footage="";
		}
		t2.listdate=dateformat(row.listing_track_datetime,'m/d/yyyy'); 
		t2.yearbuilt=row.listing_year_built;
		t2.zip=row.listing_zip;
		t2.condition=idx.listingCondition;
		t2.parking=idx.listingParking;
		t2.region=idx.listingRegion;
		t2.status=idx.listingstatus;
		t2.lot_square_footage=row.listing_lot_square_feet;
		
		t2.pool=row.listing_pool;
		t2.photocount=row.listing_photocount;
		t2.url=propertyLink;
		t2.mls_id=idx.mls_id;
		t2.listing_id=row.listing_id;
		t2.city_id=row.listing_city;
		t2.state=row.listing_state;
		t2.city=idx.cityName;
		t2.condoname=row.listing_condoname;
		t2.address=row.listing_address;
		
		t2.longitude=row.listing_longitude;
		t2.latitude=row.listing_latitude;
		t2.price=row.listing_price;
		
		t2.view=idx.listingView;
		t2.style=idx.listingStyle;
		t2.frontage=idx.listingFrontage;
		t2.type=idx.listingPropertyType;
		
		if(row.listing_beds neq '' and row.listing_beds NEQ 0){
			t2.bedrooms=row.listing_beds;
		}else{
			t2.bedrooms="";
		}
		if(row.listing_baths neq '' and row.listing_baths NEQ 0){
			t2.bathrooms=row.listing_baths;
		}else{
			t2.bathrooms="";
		}
		if(row.listing_halfbaths neq '' and row.listing_halfbaths NEQ 0){
			t2.halfbaths=row.listing_halfbaths;
		}else{
			t2.halfbaths="";
		}
		if(row.listing_pool EQ 1){
			t2.pool="Pool";
		}else{
			t2.pool="";
		}
		if(row.listing_price neq '' and row.listing_price neq 0){
			if(row.listing_price LT 20){
				t2.price='$#numberformat(row.listing_price)# per sqft ';
			}else{
				t2.price='$#numberformat(row.listing_price)#';
			}
		}else{
			t2.price='';
		}
		if(row.listing_subdivision neq 'Not In Subdivision' AND row.listing_subdivision neq 'Not On The List' AND row.listing_subdivision neq 'n/a' and row.listing_subdivision neq ''){
			t2.subdivision=row.listing_subdivision;
		}else{
			t2.subdivision="";	
		}
		
		t2.photo1=photo1;
		
		if(row.listing_data_remarks NEQ '' and this.optionStruct.compactWithLinks EQ false){
			tempText = rereplace(row.listing_data_remarks, "<.*?>","","ALL");
			tempText2=left(tempText, 280);
			theEnd = mid(tempText, 281, len(tempText));
			pos = find(' ', theEnd);
			if(pos NEQ 0){
				tempText2=tempText2&left(theEnd, pos);
			}
			t2.description=application.zcore.functions.zFixAbusiveCaps(tempText2);
		}else{
			t2.description="";
		}
		if(isDefined('idx.virtualtoururl') and idx.virtualtoururl neq ''){
			t2.virtual_tour=idx.virtualtoururl;
		}else{
			t2.virtual_tour="";
		}
		arrayAppend(rs.arrData, t2);
	} 
	rs.count=arrayLen(rs.arrData);
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getAjaxObject" localmode="modern" output="no" returntype="any">
	<cfargument name="skipLastRecord" type="boolean" default="#false#" required="no">
	<cfscript> 
	var rs=structnew(); 
	rs.count=this.datastruct.count;
	rs.data=structnew();
	rs.data.url=arrayNew(1);
	rs.data.mls_id=arrayNew(1);
	rs.data.listing_id=arrayNew(1);
	rs.data.city=arrayNew(1);
	rs.data.city_id=arrayNew(1);
	rs.data.view=arrayNew(1);
	rs.data.type=arrayNew(1);
	rs.data.bedrooms=arrayNew(1);
	rs.data.bathrooms=arrayNew(1);
	rs.data.halfbaths=arrayNew(1);
	rs.data.square_footage=arrayNew(1);
	rs.data.pool=arrayNew(1);
	rs.data.price=arrayNew(1);
	rs.data.subdivision=arrayNew(1);
	rs.data.photo1=arrayNew(1);
	rs.data.description=arrayNew(1);
	rs.data.virtual_tour=arrayNew(1);
	rs.data.condoname=arrayNew(1);
	rs.data.address=arrayNew(1);
	rs.data.style=arrayNew(1);
	rs.data.frontage=arrayNew(1);
	rs.data.tenure=arrayNew(1);
	rs.data.zip=arrayNew(1);
	rs.data.condition=arrayNew(1);
	rs.data.parking=arrayNew(1);
	rs.data.region=arrayNew(1);
	rs.data.status=arrayNew(1);
	rs.data.yearbuilt=arrayNew(1);
	rs.data.photocount=arrayNew(1);
	rs.data.pool=arrayNew(1);
	rs.data.listdate=arrayNew(1);
	rs.data.liststatus=arrayNew(1);
	rs.data.lot_square_footage=arrayNew(1);

	rs.data.latitude=arrayNew(1);
	rs.data.longitude=arrayNew(1);
	rs.data.price=arrayNew(1);
	
	if(arguments.skipLastRecord){
		skipIndex=rs.count;
	}else{
		skipIndex=-1;
	}

	for(i=1;i LTE arrayLen(this.dataStruct.arrData);i++){
		row=this.dataStruct.arrData[i];
		currentRow=i;
 
		idx=structnew();
		idx.arrayIndex=i;
		idx.listing_id=row.listing_id; 
		idx.mls_id=listgetat(row.listing_id,1,"-"); 
		request.lastPhotoId=row.listing_id;
		if(this.optionStruct.getDetails){
			structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].getDetails(row,currentrow), true);
		}else{
			structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].baseGetDetails(row,currentrow), true);
		}
		if(structkeyexists(request.zos.listingMlsComObjects[idx.mls_id], 'sysidfield2')){
			photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1, idx.sysidfield, idx.sysidfield2);
		}else if(structkeyexists(request.zos.listingMlsComObjects[idx.mls_id], 'sysidfield')){
			photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1, idx.sysidfield);
		}else{
			photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1);
		}
		if(photo1 NEQ ""){	
			photo1=application.zcore.listingCom.getThumbnail(photo1, request.lastPhotoId, 1, form.pw, form.ph, form.pa);
		}
		titleStruct = request.zos.listing.functions.zListinggetTitle(idx);
		propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#idx.urlMlsId#-#idx.urlMLSPId#.html';
		if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
			propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
		}
		rs.data.tenure[i]=idx.listingTenure;
		if(row.listing_square_feet neq '' and row.listing_square_feet NEQ 0){
			rs.data.square_footage[i]=row.listing_square_feet;
		}else if(row.listing_lot_square_feet neq '' and row.listing_lot_square_feet NEQ 0){
			rs.data.square_footage[i]=row.listing_lot_square_feet;
		}else{
			rs.data.square_footage[i]="";
		}
		rs.data.listdate[i]=dateformat(row.listing_track_datetime,'m/d/yyyy'); 
		rs.data.yearbuilt[i]=row.listing_year_built;
		rs.data.zip[i]=row.listing_zip;
		rs.data.condition[i]=idx.listingCondition;
		rs.data.parking[i]=idx.listingParking;
		rs.data.region[i]=idx.listingRegion;
		rs.data.status[i]=idx.listingstatus;
		rs.data.lot_square_footage[i]=row.listing_lot_square_feet;
		
		rs.data.pool[i]=row.listing_pool;
		rs.data.photocount[i]=row.listing_photocount;
		rs.data.url[i]=propertyLink;
		rs.data.mls_id[i]=idx.mls_id;
		rs.data.listing_id[i]=row.listing_id;
		rs.data.city_id[i]=row.listing_city;
		rs.data.city[i]=idx.cityName;
		rs.data.condoname[i]=row.listing_condoname;
		rs.data.address[i]=row.listing_address;
		
		rs.data.longitude[i]=row.listing_longitude;
		rs.data.latitude[i]=row.listing_latitude;
		rs.data.price[i]=row.listing_price;
		
		rs.data.view[i]=idx.listingView;
		rs.data.style[i]=idx.listingStyle;
		rs.data.frontage[i]=idx.listingFrontage;
		rs.data.type[i]=idx.listingPropertyType;
		
		if(row.listing_beds neq '' and row.listing_beds NEQ 0){
			rs.data.bedrooms[i]=row.listing_beds;
		}else{
			rs.data.bedrooms[i]="";
		}
		if(row.listing_baths neq '' and row.listing_baths NEQ 0){
			rs.data.bathrooms[i]=row.listing_baths;
		}else{
			rs.data.bathrooms[i]="";
		}
		if(row.listing_halfbaths neq '' and row.listing_halfbaths NEQ 0){
			rs.data.halfbaths[i]=row.listing_halfbaths;
		}else{
			rs.data.halfbaths[i]="";
		}
		if(row.listing_pool EQ 1){
			rs.data.pool[i]="Pool";
		}else{
			rs.data.pool[i]="";
		}
		if(row.listing_price neq '' and row.listing_price neq 0){
			if(row.listing_price LT 20){
				rs.data.price[i]='$#numberformat(row.listing_price)# per sqft ';
			}else{
				rs.data.price[i]='$#numberformat(row.listing_price)#';
			}
		}else{
			rs.data.price[i]='';
		}
		if(row.listing_subdivision neq 'Not In Subdivision' AND row.listing_subdivision neq 'Not On The List' AND row.listing_subdivision neq 'n/a' and row.listing_subdivision neq ''){
			rs.data.subdivision[i]=row.listing_subdivision;
		}else{
			rs.data.subdivision[i]="";	
		}
		
		rs.data.photo1[i]=photo1;
		
		if(row.listing_data_remarks NEQ '' and this.optionStruct.compactWithLinks EQ false){
			tempText = rereplace(row.listing_data_remarks, "<.*?>","","ALL");
			tempText2=left(tempText, 280);
			theEnd = mid(tempText, 281, len(tempText));
			pos = find(' ', theEnd);
			if(pos NEQ 0){
				tempText2=tempText2&left(theEnd, pos);
			}
			rs.data.description[i]=application.zcore.functions.zFixAbusiveCaps(tempText2);
		}else{
			rs.data.description[i]="";
		}
		if(isDefined('idx.virtualtoururl') and idx.virtualtoururl neq ''){
			rs.data.virtual_tour[i]=idx.virtualtoururl;
		}else{
			rs.data.virtual_tour[i]="";
		}
	} 
	return rs;
	</cfscript>
</cffunction>

<!--- propertyDisplayCom.display(); --->
<cffunction name="display" localmode="modern" output="true" returntype="any">
	<cfscript> 
	var db=request.zos.queryObject; 
	var arrOutput=[]; 
	curTemplate="";
	curTemplateOutput=false;
	if(structkeyexists(request, 'arrEmailPhoto') EQ false){
		request.arrEmailPhoto=[];
	}
	ArrayAppend(arrOutput,this.checkNav()); 
	t493={};
	application.zcore.app.getAppCFC("content").setContentIncludeConfig(t493); 
	if(this.optionstruct.search_result_layout EQ 0){
		// default detail layout
	}else if(this.optionstruct.search_result_layout EQ 1){
		this.optionStruct.oneLineLayout=true;
		variables.trackBedroomStruct=structnew();
	}else if(this.optionstruct.search_result_layout EQ 2){
		this.optionStruct.thumbnailLayout=true;
	} 
	limit=10;
	if(isdefined('this.optionstruct.dataStruct.inputArguments.ss.searchCriteria.search_result_limit') and this.optionstruct.dataStruct.inputArguments.ss.searchCriteria.search_result_limit NEQ ""){
		limit=this.optionstruct.dataStruct.inputArguments.ss.searchCriteria.search_result_limit;
	}else if(application.zcore.functions.zso(form, "search_result_limit", true, 0) NEQ 0){
		limit=form.search_result_limit;
	}
	request.zos.requestLogEntry('propertyDisplay.cfc before display() loop');

	if ( application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_search_header_cfc_path') NEQ '' ) {
		if ( application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_search_header_cfc_method') NEQ '' ) {
			tempHeaderComPath = replace( application.zcore.app.getAppData("listing").sharedStruct.optionStruct['mls_option_search_header_cfc_path'], 'root.', request.zRootCFCPath );
			tempHeaderCom = createobject( 'component', tempHeaderComPath );
			savecontent variable="out"{
				tempHeaderCom[ application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_search_header_cfc_method') ]();
			}
			arrayAppend( arrOutput, '<div class="z-float">'&out&'</div>' );
		}
	}

	var useCustomListingLayout = false;

	if ( application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_listing_result_cfc_path') NEQ '' ) {
		if ( application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_listing_result_cfc_method') NEQ '' ) {
			useCustomListingLayout = true;
			tempListingComPath = replace( application.zcore.app.getAppData("listing").sharedStruct.optionStruct['mls_option_listing_result_cfc_path'], 'root.', request.zRootCFCPath );
			tempListingCom = createobject( 'component', tempListingComPath );
		}
	}

	for(i=1;i LTE min(limit, arrayLen(this.dataStruct.arrData));i++){
		if(not arrayisdefined(this.dataStruct.arrData, i)){
			continue;
		}
		row=this.dataStruct.arrData[i];
		currentRow=i;

		idx=structnew();
		idx.arrayIndex=i;
		idx.listing_id=row.listing_id; 
		idx.mls_id=listgetat(row.listing_id,1,"-");
		if(this.optionStruct.getDetails or true){
			structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].getDetails(row, currentrow), true);
			request.zos.requestLogEntry('propertyDisplay.cfc after getDetails() for listing_id = #row.listing_id#');
		}else{
			structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].basegetDetails(row, currentrow), true);
			request.zos.requestLogEntry('propertyDisplay.cfc after baseGetDetails() for listing_id = #row.listing_id#');
		}

		request.lastphotoid=idx.listing_id;
		if(structkeyexists(idx, 'sysidfield2')){
			idx.photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1, idx.sysidfield, idx.sysidfield2);
		}else if(structkeyexists(idx, 'sysidfield')){
			idx.photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1, idx.sysidfield);
		}else{
			idx.photo1=application.zcore.listingCom.getPhoto(idx.listing_id,1);
		}  
 
		savecontent variable="tempText"{
			if(useCustomListingLayout){ 
				tempListingCom[ application.zcore.app.getAppData("listing").sharedStruct.optionStruct['mls_option_listing_result_cfc_method'] ]( idx ); 
			}else if(this.optionStruct.storeCopy){
				throw("storeCopy listing_saved is disabled");
			}else if(this.optionStruct.oneLineLayout){
				if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
					curTemplate="template: one-line<br />";
				}
				this.oneLineTemplate(idx); 
			}else if( this.optionStruct.thumbnailLayout){
				if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
					curTemplate="template: thumbnail<br />";
				}

				this.thumbnailTemplate(idx);
			}else if( this.optionStruct.descriptionLink){
				if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
					curTemplate="template: description-link<br />";
				}
				this.descriptionLinkTemplate(idx);
			}else if( this.optionStruct.classifiedflyerads){
				if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
					curTemplate="template: classifiedflyerads<br />";
				}
				this.classifiedFlyerAdsTemplate(idx);
				/*
			    // TODO this is probably wrong or not in use.
			}else if( this.optionStruct.rss){
				if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
					curTemplate="template: rss<br />";
				}
				this.rssTemplate(idx);
			    ts=StructNew();
			    ts.name='listing'&(StructCount(Request.rssListingStruct)+1);
			    ts.date=DateFormat(far_vrdb_list_date,'yyyymmdd')&'000001';
			    ts.text=tempText;
			    request.rssListingStruct[ts.name]=ts;
			    */
			}else if( this.optionStruct.emailFormat){
				if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
					curTemplate="template: email<br />";
				}
				this.emailTemplate(idx);
			}else if( this.optionStruct.plainText){
				if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
					curTemplate="template: emailPlain<br />";
				}
				this.emailPlainTemplate(idx);
			}else if( isdefined('this.optionStruct.listNew') and this.optionStruct.listNew){
				if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
					curTemplate="template: list (new)<br />";
				}
				this.listTemplate(idx);
			}else{
				if(structkeyexists(form, 'debugsearchresults') and form.debugsearchresults){
					curTemplate="template: list<br />";
				}
				this.listTemplate(idx);
			}
			if(len(curTemplate) and curTemplateOutput EQ false){
				curTemplateOutput=true;
				echo(curTemplate);
			}
		} 
		if(this.optionStruct.output){
		    arrayAppend(arrOutput,tempText);// tempText2&
		}else{
			if(structkeyexists(request,'cOutStruct')){
				// add content
				request.contentCount++;
				ts=StructNew();
				ts.output=tempText;
				if(idx.listing_price EQ 0){
					ts.price=1000000000;
				}else{
					ts.price=idx.listing_price;
				}
				ts.id=listgetat(idx.listing_id,2,"-");
				ts.sort=idx.listing_id;
				request.cOutStruct[request.contentCount]=ts;
			}
		}
		request.zos.requestLogEntry('propertyDisplay.cfc end of display loop for listing_id = #row.listing_id#');
	}  

	request.zos.requestLogEntry('propertyDisplay.cfc after display() loop');
	if(this.optionStruct.thumbnailLayout){
		arrayprepend(arrOutput,'<div style="width:100%; float:left;"><div id="zmls-thumbnailboxid">');
		arrayappend(arrOutput,'</div></div>');
	}else if(this.optionStruct.oneLineLayout){
		var arrNew=arraynew(1); 
		var startTable='
		        <table style="border-spacing:0px; width:100%; padding:5px;">
		<tr class="zls-onelinerow">
		<td style="vertical-align:top;">Unit##</td>
		<td style="vertical-align:top;">Address/Price</td>
		<td style="vertical-align:top;"><a style="text-decoration:none;" title="Bedrooms, Bathrooms and Half Bathrooms">BR/BA/HBA</a><br />List Status</td>
		<td style="vertical-align:top;">Living Area<br />(SQFT)</td>
		<td style="vertical-align:top;">Price Change</td>
		<td style="vertical-align:top;">Date<br />Listed</td>
		<td style="vertical-align:top;">&nbsp;</td>
		</tr>';
		var endTable='</table>';
		if(this.optionStruct.groupBedrooms){
			arrK=structkeyarray(variables.trackBedroomStruct);
			arraysort(arrK,"numeric","asc");
			
			for(i=1;i LTE arraylen(arrK);i++){
				arrayappend(arrNew, '<h2>#i# Bedroom</h2>'); 
				arrayappend(arrNew, startTable);
				curRow=0;
				for(i2=1;i2 LTE arraylen(variables.trackBedroomStruct[arrK[i]]);i2++){
					curRow++;
					if(curRow MOD 2 EQ 1){
						arrayappend(arrNew, '<tr class="zls-onelinerowodd">');	
					}else{
						arrayappend(arrNew, '<tr class="zls-onelineroweven">');
					}
					arrayappend(arrNew, arrOutput[variables.trackBedroomStruct[arrK[i]][i2]]);
					arrayappend(arrNew,'</tr>');
				}
				arrayappend(arrNew, endTable&'<br />');
			}
			arrOutput=arrNew;
		}else{
			for(i2=1;i2 LTE arraylen(arrOutput);i2++){
				if(isDefined('arrOutput[#i2#]')){
					if(i2 MOD 2 EQ 1){
						arrOutput[i2]='<tr class="zls-onelinerowodd">'&arrOutput[i2]&'</tr>';
					}else{
						arrOutput[i2]='<tr class="zls-onelineroweven">'&arrOutput[i2]&'</tr>';
					}
				}
			}
			ArrayPrepend(arrOutput,startTable);
			ArrayAppend(arrOutput,endTable);
		}
	}
	ArrayAppend(arrOutput,this.checkNav(true));

	if ( application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_search_footer_cfc_path') NEQ '' ) {
		if ( application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_search_footer_cfc_method') NEQ '' ) {
			tempFooterComPath = replace( application.zcore.app.getAppData("listing").sharedStruct.optionStruct['mls_option_search_footer_cfc_path'], 'root.', request.zRootCFCPath );
			tempFooterCom = createobject( 'component', tempFooterComPath );

			savecontent variable="out"{
				tempFooterCom[ application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_search_footer_cfc_method') ]();
			}
			arrayAppend( arrOutput, '<div class="z-float">'&out&'</div>');
		}
	}
	if(this.optionStruct.plainText EQ false and this.optionStruct.classifiedFlyerAds EQ false and this.optionStruct.rss EQ false){
		ArrayAppend(arrOutput,'<br style="clear:both;" />');
	}
	
	output=arraytolist(arrOutput,'');
	if(structkeyexists(this.optionStruct, 'permanentImages') and this.optionStruct.permanentImages){
		output=replace(output, '/images/','/images_permanent/','ALL');
	} 
	return output;
	</cfscript>
</cffunction>

<!--- propertyDisplayCom.displayTop(); --->
<cffunction name="displayTop" localmode="modern" output="yes" returntype="any">
	<cfscript>
	var arrOrder=arraynew(1); 
	for(i=1;i LTE arrayLen(this.dataStruct.arrData);i++){
		row=this.dataStruct.arrData[i];
		currentRow=i;

		idx=structnew();
		idx.arrayIndex=i;
		idx.listing_id=row.listing_id; 
		idx.mls_id=listgetat(row.listing_id,1,"-");
		savecontent variable="outNow"{
			if(this.optionStruct.getDetails){
				structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].getDetails(row, currentrow), true);
			}else{
				structappend(idx, request.zos.listingMlsComObjects[idx.mls_id].basegetDetails(row, currentrow), true);
			}
			if(this.optionStruct.mapFormat){
				this.mapTemplate(idx, i);
			}else if(this.optionStruct.emailFormat){
				this.emailTemplate(idx, i);
			}else{
				this.savedTemplate(idx, i);
			}
		}
		arrayAppend(arrOrder, outNow);
		//writeoutput(row.listing_id);
	}
	return this.checkNav()&arraytolist(arrOrder,"")&this.checkNav(true);
	</cfscript>
</cffunction>

<!--- FUNCTIONS BELOW ARE FOR INTERNAL USE ONLY --->

<cffunction name="checkNav" localmode="modern" output="false" returntype="any">
	<cfargument name="bottom" type="boolean" required="no" default="#false#">
	<cfscript>
	var searchNav="";
	var tempOutput="";
	var i=0; 
	</cfscript>
	<cfif this.optionStruct.rss EQ false>
		<cfscript>
		if(structkeyexists(this.optionStruct,'navStruct')){
			if(structkeyexists(request.zos, 'propertyDisplayNavProcessed') EQ false){
				this.optionStruct.navStruct.returnDataOnly=true;
				request.zos.propertyDisplayNavProcessed=true;
				this.navOutput=application.zcore.functions.zSearchResultsNav(this.optionStruct.navStruct);
			}
		}else{
			return '';
		}
		if(this.optionStruct.plainText){
			if(arguments.bottom EQ false or ArrayLen(this.navOutput.arrData) LTE 1){
				return '';
			}else if(isDefined('this.optionStruct.saved_search_email') and isDefined('this.optionStruct.saved_search_id') and isDefined('this.optionStruct.saved_search_key')){
				return '---------------------------------------------------------'&chr(10)&'View More Results: #request.zos.currentHostName#/property/your-saved-searches.cfm?action=viewsearch&saved_search_email=#this.optionStruct.saved_search_email#&saved_search_key=#this.optionStruct.saved_search_key#&saved_search_id=#this.optionStruct.saved_search_id#&zindex=2'&chr(10);
			}else{
				return '';
			}
		}
		</cfscript>
		<cfsavecontent variable="tempOutput">
		<cfif this.optionStruct.navStruct.count GT this.optionStruct.navStruct.perPage>
			<cfif this.optionStruct.emailFormat>
				<span style="display:block; font-weight:bold; padding-bottom:5px;">
			<cfelse>
				<cfif arguments.bottom EQ false>
					<span style="font-weight:bold; padding-bottom:5px; display:block; ">Showing #this.navOutput.textPosition# listings that matched your search criteria.</span>
				</cfif>
				<cfif arguments.bottom>
					<span class="search-nav-bottom">
				<cfelse>
					<span class="search-nav">
				</cfif>
			</cfif>
			<cfscript>
			if(this.optionStruct.emailFormat){
				if(arguments.bottom){
					writeoutput('<a href="'&htmleditformat(request.zos.currentHostName&'/property/your-saved-searches.cfm?action=viewsearch&saved_search_email=#this.optionStruct.saved_search_email#&saved_search_key=#this.optionStruct.saved_search_key#&saved_search_id=#this.optionStruct.saved_search_id#&zindex=2')&'" rel="nofollow">See More Results</a>');
				}
			}else{
				for(i=1;i LTE ArrayLen(this.navOutput.arrData);i=i+1){
					if(this.navOutput.arrData[i].url EQ ''){
						writeoutput('<span class="search-nav-t">Page '&this.navOutput.arrData[i].label&'</span>');
					}else{
						writeoutput('<a rel="nofollow" href="'&htmleditformat(this.navOutput.arrData[i].url)&'">'&this.navOutput.arrData[i].label&'</a>');
					}
				}
			}
			</cfscript>
			</span>
		</cfif>
		</cfsavecontent>
	</cfif> 
	<cfreturn tempOutput>
</cffunction>

<cffunction name="thumbnailTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var showbr=0;
	var p=0;
	var thePaths=0;
	var i=0;
	var priceChange=0;
	var iheight=0;
	var titleStruct=0;
	var propertyLink=0;
	var iwidth=0;
		
	//writedump(arguments.idx.photo1&":"&arguments.idx.listing_id&":"&arguments.idx.sysidfield);
	var iwidth=int(request.zos.globals.maximagewidth/3)-30;
	var iheight=int(iwidth*0.68);
	titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	propertyLink = '/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
	if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
		propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
	}
	propertyLink=htmleditformat(propertyLink);
	priceChange=0; 
	savecontent variable="thePaths"{
		loop from="1" to="#arguments.idx.listing_photocount#" index="i"{
			if(structkeyexists(arguments.idx, 'photo'&i)){
				if(i NEQ 1){
					echo('@');
				}
				if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0) EQ 2){
					echo(application.zcore.listingCom.getThumbnail(arguments.idx['photo'&i], request.lastPhotoId, i, iwidth, iheight, 0));
				}else{
					echo(application.zcore.listingCom.getThumbnail(arguments.idx['photo'&i], request.lastPhotoId, i, 10000,10000, 0));
				}
			}
		}
	} 
	</cfscript>
	<div class="zls-list-grid-listingdiv" style="width:33%; box-sizing:border-box; ">
		<input type="hidden" name="m#arguments.idx.listing_id#_mlstempimagepaths" id="m#arguments.idx.listing_id#_mlstempimagepaths" value="#htmleditformat(replace(thePaths,'&amp;','&','all'))#" />
		<cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0) EQ 0>
			<div id="m#arguments.idx.listing_id#" class="zls-list-grid-imagediv z-preserve-ratio" data-ratio="4:3" style="overflow:hidden; height:#iheight#px; float:left; width:100%;" onmousemove="zImageMouseMove('m#arguments.idx.listing_id#',event);" onmouseout="setTimeout('zImageMouseReset(\'m#arguments.idx.listing_id#\')',100);"><a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>
			<img src="#arguments.idx.photo1#" alt="" class="z-fluid"><!--- #application.zcore.functions.zLoadAndCropImage({id:"m#arguments.idx.listing_id#_img",width:400,height:300, url:arguments.idx.photo1, style:"", canvasStyle:"", crop:true})# 		 --->		</a></div>
			<cfelse>
			<div id="m#arguments.idx.listing_id#" class="zls-list-grid-imagediv z-preserve-ratio" data-ratio="4:3"><a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>><img src="#arguments.idx.photo1#" alt="" class="z-fluid"> <!--- #application.zcore.functions.zLoadAndCropImage({id:"m#arguments.idx.listing_id#_img",width:400,height:300, url:arguments.idx.photo1, style:"", canvasStyle:"", crop:true})#  --->
				</a></div>
		</cfif>
		<div class="zls-grid-summary-text">
		<div class="zls-buttonlink" style="float:right; position:relative; margin-top:-33px;"> <a href="#request.zos.currentHostName##propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>View</a> </div>
		<cfif arguments.idx.listing_price NEQ "" and arguments.idx.listing_price NEQ "0">
			<div class="zls-grid-price">
			$#numberformat(arguments.idx.listing_price)#
			<cfif arguments.idx.listing_price LT 20>
				per sqft
			</cfif>
		</cfif>
		<cfif arguments.idx.listing_price NEQ "" and arguments.idx.listing_price NEQ "0">
			</div>
		</cfif>
		<cfif arguments.idx.listing_data_address NEQ "">
			#arguments.idx.listing_data_address#<br />
		</cfif>
		#arguments.idx.cityName# 		<br />
		<cfif arguments.idx.listing_condoname NEQ "">
			#arguments.idx.listing_condoname#<br />
		</cfif>
		<cfset showbr=false>
		<cfif arguments.idx.listing_beds NEQ 0>
			<cfset showbr=true>
			#arguments.idx.listing_beds#BR/#arguments.idx.listing_baths#BA<cfif arguments.idx.listing_halfbaths NEQ "" and arguments.idx.listing_halfbaths NEQ 0>/#arguments.idx.listing_halfbaths#HBA</cfif>
			<cfelseif arguments.idx.listing_square_feet neq '0' and arguments.idx.listing_square_feet neq ''>
			<cfset showbr=true>
			#arguments.idx.listing_square_feet# sqft
		</cfif>
		<!--- <cfif arguments.idx.listing_address CONTAINS "unit:">
			<cfscript>
			p=findnocase("unit:",arguments.idx.listing_address);
			writeoutput("unit: "&trim(removechars(arguments.idx.listing_address,1, p+5)));
			</cfscript>
		</cfif> --->
		<cfif showbr>
			<br />
		</cfif>
		<cfif arguments.idx.listingstatus EQ "for rent">
			For Rent/Lease
		<cfelseif titleStruct.propertyType NEQ 'rental'>
			For Sale
		<cfelse>
			Rental
		</cfif>
		| #arguments.idx.listingListStatus# </div>
	</div>
</cffunction>

<cffunction name="oneLineTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var titleStruct=0;
	var propertyLink=0;
	var priceChange=0;
	var p=0;
	if(structkeyexists(variables.trackBedroomStruct, arguments.idx.listing_beds) EQ false){
		variables.trackBedroomStruct[arguments.idx.listing_beds]=arraynew(1);
	}
	arrayappend(variables.trackBedroomStruct[arguments.idx.listing_beds], arguments.idx.arrayindex);
	
	titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	propertyLink = '/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
	if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
		propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
	}
	propertyLink=htmleditformat(propertyLink);
	priceChange=0;
	if(arguments.idx.listing_track_datetime NEQ ""){
		priceChange=application.zcore.functions.zso(arguments.idx, 'listing_track_price',true)-application.zcore.functions.zso(arguments.idx, 'listing_track_price_change',true);
	}
	</cfscript>
	<td style="vertical-align:top;"><cfif arguments.idx.listing_address CONTAINS "unit:">
			<cfscript>
			p=findnocase("unit:" ,arguments.idx.listing_address);
			writeoutput(trim(removechars(arguments.idx.listing_address,1, p+5)));
			</cfscript>
		</cfif></td>
	<td style="vertical-align:top;">#arguments.idx.listing_address#<br />
		<cfif arguments.idx.listing_price NEQ "" and arguments.idx.listing_price NEQ "0">
			$#numberformat(arguments.idx.listing_price)#
			<cfif arguments.idx.listing_price LT 20>
				per sqft
			</cfif>
		</cfif></td>
	<td style="vertical-align:top;">#arguments.idx.listing_beds#/#arguments.idx.listing_baths#/#arguments.idx.listing_halfbaths#<br />
#arguments.idx.listingListStatus# 		</td>
	<td style="vertical-align:top;"><cfif arguments.idx.listing_square_feet neq '0' and arguments.idx.listing_square_feet neq ''>
			#arguments.idx.listing_square_feet#<br />
		</cfif>
		<cfif arguments.idx.pricepersqft NEQ "" and arguments.idx.pricepersqft NEQ 0>
			($#numberformat(arguments.idx.pricepersqft)#/sqft)
		</cfif></td>
	<td style="vertical-align:top;"><cfscript>
    /*if(priceChange GT 0){
        writeoutput('-$#numberformat(pricechange)#'); 	
    }else if(priceChange LT 0){
        writeoutput('+$#numberformat(abs(pricechange))#');
    }else{
		writeoutput('&nbsp;');	
	}*/
		writeoutput('&nbsp;');	
    </cfscript></td>
	<td style="vertical-align:top; white-space:nowrap;">#dateformat(arguments.idx.listing_track_datetime,'m/d/yy')#<br />
		<cfif arguments.idx.listingstatus EQ "for rent">
			For Rent/Lease
		<cfelseif titleStruct.propertyType NEQ 'rental'>
			For Sale
		<cfelse>
			Rental
		</cfif></td>
	<td style="vertical-align:top;"><a target="_parent" href="#request.zos.currentHostName##propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>View</a></td>
</cffunction>

<cffunction name="listTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript> 
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx); 
	</cfscript>
	<cfif structkeyexists(arguments.idx, 'arrayindex') and arguments.idx.arrayindex MOD 2 EQ 0>
		<cfset bgClass="listing-l-box1">
		<cfelse>
		<cfset bgClass="listing-l-box2">
	</cfif>
	<cfset propertyLink = '/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html'>
	<cfif isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive>
		<cfset propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1")>
	</cfif>
	<cfscript>
	   propertyLink=htmleditformat(propertyLink);

	savecontent variable="thePaths"{
		loop from="1" to="#arguments.idx.listing_photocount#" index="i"{
			if(structkeyexists(arguments.idx, 'photo'&i)){
				if(i NEQ 1){
					echo('@');
				}
				if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0) EQ 2){
					echo(application.zcore.listingCom.getThumbnail(arguments.idx['photo'&i], request.lastPhotoId, i, 221, 165, 0));
				}else{
					echo(application.zcore.listingCom.getThumbnail(arguments.idx['photo'&i], request.lastPhotoId, i, 10000,10000, 0));
				}
			}
		}
	}
	</cfscript> 
	<input type="hidden" name="m#arguments.idx.listing_id#_mlstempimagepaths" id="m#arguments.idx.listing_id#_mlstempimagepaths" value="#htmleditformat(replace(thePaths,'&amp;','&','all'))#" />
	<cfscript> 
	tempText = rereplace(arguments.idx.listing_data_remarks, "<.*?>","","ALL");
	fullTextBackup=tempText;
	tempText = left(tempText, 240);
	theEnd = mid(arguments.idx.listing_data_remarks, 241, len(arguments.idx.listing_data_remarks));
	pos = find(' ', theEnd);
	if(pos NEQ 0){
	    tempText=tempText&left(theEnd, pos);
	}
	if(len(tempText) LT len(arguments.idx.listing_data_remarks)){
		tempText&="...";	
	}
	tempText=application.zcore.functions.zFixAbusiveCaps(replace(tempText,",",", ","all"));
	rowSpan1=6;
	if(arguments.idx.listing_beds eq '' or arguments.idx.listing_beds EQ 0){
		rowSpan1--;
	}
	priceChange=0;
	if(arguments.idx.listing_track_datetime NEQ ""){
		//priceChange=application.zcore.functions.zso(arguments.idx, 'listing_track_price',true)-application.zcore.functions.zso(arguments.idx, 'listing_track_price_change',true);
	}
	if(arguments.idx.listing_pool NEQ 1 and arguments.idx.listingFrontage EQ "" and arguments.idx.listing_subdivision EQ ""){
		rowSpan1--;
	}
	if((arguments.idx.listing_lot_square_feet neq '0' and arguments.idx.listing_lot_square_feet neq '') or (arguments.idx.listing_square_feet neq '0' and arguments.idx.listing_square_feet neq '') or arguments.idx.maintfees NEQ "0"){
	}else{
		rowSpan1--;
	}
	if(arguments.idx.listingview NEQ "" or arguments.idx.listing_year_built NEQ "" or arguments.idx.listingStyle NEQ ""){
	}else{
		rowSpan1--;
	}
	if(isDefined('this.isPropertyDisplayCom') EQ false or this.optionStruct.compact EQ false or this.optionStruct.compactWithLinks){
	}else{
		rowSpan1--;
	} 
	</cfscript>
	<table class="zls2-1">
		<tr>
			<td class="zls2-15" colspan="3" style="padding-right:0px;"><table class="zls2-8" style="border-spacing:0px;">
				<tr>
					<td class="zls2-9"><span class="zls2-10">
						<cfif arguments.idx.listing_price NEQ "" and arguments.idx.listing_price NEQ "0">
							$#numberformat(arguments.idx.listing_price)#
							<cfif arguments.idx.listing_price LT 20>
								per sqft
							</cfif>
						</cfif>
						<br />
						#arguments.idx.listingListStatus#</span><br />
						<cfif arguments.idx.pricepersqft NEQ "" and arguments.idx.pricepersqft NEQ 0>
							($#numberformat(arguments.idx.pricepersqft)#/sqft)
						</cfif></td>
					<cfif arguments.idx.listing_address CONTAINS "unit:">
						<td class="zls2-9-3">UNIT ##
							<cfscript>
							p=findnocase("unit:", arguments.idx.listing_address);
							writeoutput(trim(removechars(arguments.idx.listing_address,1, p+5)));
							</cfscript></td>
					</cfif>
					<td class="zls2-9-2"><strong>#arguments.idx.cityName#
						<cfif arguments.idx.listingstatus EQ "for rent">
							For Rent/Lease
						<cfelseif titleStruct.propertyType NEQ 'rental'>
							#titleStruct.propertyType# For Sale
						<cfelse>
							Rental
						</cfif>
						</strong><br />
						<cfif arguments.idx.listing_beds NEQ 0>
							#arguments.idx.listing_beds# beds,
						</cfif>
						<cfif arguments.idx.listing_baths NEQ 0>
							#arguments.idx.listing_baths# baths,
						</cfif>
						<cfif arguments.idx.listing_halfbaths NEQ 0>
							#application.zcore.functions.zso(arguments.idx, 'listing_halfbaths',true)# half baths,
						</cfif>
						<cfif arguments.idx.listing_square_feet neq '0' and arguments.idx.listing_square_feet neq ''>
							#arguments.idx.listing_square_feet# living sqft
						</cfif></td>
					</tr>
				</table>
				<br style="clear:both;" />
				<div class="zls-buttonlink">
					<cfif request.cgi_script_name NEQ '/z/listing/property/detail/index'>
						<a href="#request.zos.currentHostName##propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>View Full Details</a>
					</cfif>
					<cfif request.cgi_script_name NEQ '/z/listing/inquiry/index'>
						<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 0>
							<cfelse>
							<a href="##" onclick="zShowModalStandard('/z/listing/inquiry/index?action=form&amp;modalpopforced=1&amp;listing_id=#arguments.idx.listing_id#&amp;inquiries_comments=#urlencodedformat('I''d like to apply to rent this property')#', 540, 630);return false;" rel="nofollow">Apply Now</a>
						</cfif>
					</cfif> 
					<cfif request.cgi_script_name NEQ '/z/listing/inquiry/index'>
						<a href="##" class="zls-saveListingButton" data-listing-id="#arguments.idx.listing_id#" rel="nofollow" class="zNoContentTransition">Save Listing</a>
					</cfif>
					<cfif arguments.idx.virtualtoururl neq '' and (findnocase("https://", arguments.idx.virtualtoururl) NEQ 0 or findnocase("http://",arguments.idx.virtualtoururl) NEQ 0)>
						<a href="#application.zcore.functions.zBlockURL(arguments.idx.virtualtoururl)#" rel="nofollow" onclick="window.open(this.href); return false;">Virtual Tour</a>
					</cfif>
					<cfif arguments.idx.listingHasMap>
						<a href="#request.zos.currentHostName##propertyLink###googlemap" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>Map</a>
					</cfif>
					<cfif request.cgi_script_name NEQ '/z/listing/inquiry/index'>
						<a href="##" onclick="zShowModalStandard('/z/listing/inquiry/index?action=form&amp;modalpopforced=1&amp;listing_id=#arguments.idx.listing_id#', 540, 630);return false;" rel="nofollow">Ask Question</a>
					</cfif>
				</div></td>
		</tr>
		<tr>
			<td class="zls2-3" colspan="2"><table class="zls2-16">
				<tr>
					<td class="zls2-4" rowspan="3"><cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0)  EQ 0>
							<div id="m#arguments.idx.listing_id#" class="zls2-5" onmousemove="zImageMouseMove('m#arguments.idx.listing_id#',event);" onmouseout="setTimeout('zImageMouseReset(\'m#arguments.idx.listing_id#\')',100);"><a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>> 
								
								
								<img id="m#arguments.idx.listing_id#_img" src="#application.zcore.listingCom.getThumbnail(arguments.idx.photo1, request.lastPhotoId, 1, 221, 165, 1)#"  class="zlsListingImage"  alt="Listing Image" width="221" />
								</a></div>
							<cfif arguments.idx.listing_photocount LTE 1 or application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_image_enlarge',false,0) EQ 2>
								<div class="zls2-6"></div>
								<cfelse>
								<div class="zls2-7">
									<cfif arguments.idx.listing_photocount NEQ 0>
										ROLLOVER TO VIEW #arguments.idx.listing_photocount# PHOTO<cfif arguments.idx.listing_photocount GT 1>S</cfif>
									</cfif>
								</div>
							</cfif>
							<cfelse>
							<div id="m#arguments.idx.listing_id#" class="zls2-5"><a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>> #application.zcore.functions.zLoadAndCropImage({id:"m#arguments.idx.listing_id#_img",width:221,height:165, url:arguments.idx.photo1, style:"", canvasStyle:"", crop:true})# 
								</a></div>
						</cfif></td>
					<td class="zls2-17" style="vertical-align:top;padding:0px;"><table style="width:100%;">
							<tr>
								<td class="zls2-2"> MLS ###listgetat(arguments.idx.listing_id,2,'-')# Source: #arguments.idx.listingSource# | <a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>#htmleditformat(titleStruct.title)#</a><br />
									#arguments.idx.listing_data_address#, #arguments.idx.cityName#, #arguments.idx.listing_state# #arguments.idx.listing_data_zip#</td>
							</tr>
							<tr>
								<td colspan="2"><div class="zls2-11">
										<cfscript>
									    /*if(priceChange GT 0){
										writeoutput('<span class="zls2-12 zPriceChangeMessage">Price reduced $#numberformat(pricechange)# since #dateformat(arguments.idx.listing_track_datetime,'m/d/yy')#, NOW $#numberformat(arguments.idx.listing_price)#</span> | '); 	
									    }else if(priceChange LT 0){
										writeoutput('<span class="zls2-12 zPriceChangeMessage">Price increased $#numberformat(abs(pricechange))# since #dateformat(arguments.idx.listing_track_datetime,'m/d/yy')#, NOW $#numberformat(arguments.idx.listing_price)#</span> | ');
									    }*/
										if(request.cgi_script_name EQ "/z/listing/property/detail/index"){
											writeoutput(htmleditformat(fullTextBackup));
										}else{
											writeoutput(htmleditformat(tempText));
										}
									    </cfscript>
									</div>
									<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 0 and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_enable_mortgage_quote',true,1) EQ 1>
										<table class="zls2-13">
											<tr>
												<td>Low interest financing available. <a href="##" onclick="zShowModalStandard('/z/misc/mortgage-quote/index?modalpopforced=1', 540, 630);return false;" rel="nofollow"><strong>Get Pre-Qualified</strong></a></td>
											</tr>
										</table>
									</cfif>
									<table class="zls2-14">
										<tr>
											<td> Top Features:
												<cfif titleStruct.propertyType EQ "rental">
													For Rent
												<cfelse>
													#arguments.idx.listingstatus#
												</cfif>
												<cfif arguments.idx.listingFrontage NEQ "">
													, Frontage: #arguments.idx.listingFrontage#
												</cfif>
												<cfif arguments.idx.listingView NEQ "">
													, View: #arguments.idx.listingView#
												</cfif>
												<cfif arguments.idx.listing_pool EQ 1>
													Has a pool
												</cfif>
												<cfif arguments.idx.listing_subdivision neq ''>
													, Subdivision:&nbsp;#htmleditformat(arguments.idx.listing_subdivision)#
												</cfif>
												<cfif arguments.idx.listing_lot_square_feet neq '0' and arguments.idx.listing_lot_square_feet neq ''>
													, Lot SQFT: #arguments.idx.listing_lot_square_feet#sqft
												</cfif>
												<cfif arguments.idx.listing_year_built NEQ "">
													, Built in &nbsp;#arguments.idx.listing_year_built#
												</cfif>
												<cfif arguments.idx.listingStyle NEQ "">
													, Style: #arguments.idx.listingStyle#
												</cfif>
												<cfif arguments.idx.maintfees NEQ "" and arguments.idx.maintfees NEQ 0>
													, Maint Fees: $#numberformat(arguments.idx.maintfees)#
												</cfif></td>
										</tr>
									</table></td>
							</tr>
						</table></td>
					<cfscript>
					tempAgent=arguments.idx.listing_agent;
					</cfscript>
					<cfif structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[arguments.idx.mls_id], "agentIdStruct") and 
structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[arguments.idx.mls_id].agentIdStruct, tempAgent)>
						<cfscript>
						agentStruct=application.zcore.app.getAppData("listing").sharedStruct.mlsStruct[arguments.idx.mls_id].agentIdStruct[tempAgent];
						userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
						userusergroupid = userGroupCom.getGroupId('user',request.zos.globals.id);
						</cfscript>
						<td class="zls2-agentPanel"> LISTING AGENT<br />
							<cfif fileexists(application.zcore.functions.zVar('privatehomedir',agentStruct.userSiteId)&removechars(request.zos.memberImagePath,1,1)&agentStruct.member_photo)>
								<img src="#application.zcore.functions.zvar('domain',agentStruct.userSiteId)##request.zos.memberImagePath##agentStruct.member_photo#" alt="Listing Agent" width="90"/><br />
							</cfif>
							<cfif agentStruct.member_first_name NEQ ''>
								#agentStruct.member_first_name#
							</cfif>
							<cfif agentStruct.member_last_name NEQ ''>
								#agentStruct.member_last_name#<br />
							</cfif>
							<cfif agentStruct.member_phone NEQ ''>
								<strong>#agentStruct.member_phone#</strong><br />
							</cfif>
							<cfif application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id NEQ "0" and agentStruct.member_public_profile EQ 1>
								<cfscript>
tempName=application.zcore.functions.zurlencode(lcase("#agentStruct.member_first_name# #agentStruct.member_last_name# "),'-');
</cfscript>
								<a href="/#tempName#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_listing_user_id#-#agentStruct.user_id#.html">Bio &amp; Listings</a>
							</cfif>
						</td>
					</cfif>
				</tr>
			</table></td>
		</tr>
	</table>
	<div class="zls2-divider"></div>
</cffunction>

<cffunction name="ajaxTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	var propertyLink=0;
	var tempText=0;
	var tempText2=0;
	var theEnd=0;
	var pos=0;
	var rs={data:{}}; 
	i=arguments.idx.arrayindex;
	propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
	if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
		propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
	}
	rs.data.url[i]=propertyLink;
	rs.data.mls_id[i]=arguments.idx.mls_id;
	rs.data.listing_id[i]=arguments.idx.listing_id;
	rs.data.city_id[i]=arguments.idx.listing_city;
	rs.data.city[i]=arguments.idx.cityName;
	rs.data.condoname[i]=arguments.idx.listing_condoname;
	rs.data.address[i]=arguments.idx.listing_address;
	
	rs.data.longitude[i]=arguments.idx.listing_longitude;
	rs.data.latitude[i]=arguments.idx.listing_latitude;
	rs.data.price[i]=arguments.idx.listing_price;
	
	rs.data.view[i]=arguments.idx.listingView;
	rs.data.style[i]=arguments.idx.listingStyle;
	rs.data.frontage[i]=arguments.idx.listingFrontage;
	rs.data.type[i]=arguments.idx.listingPropertyType;
	if(arguments.idx.listing_beds neq '' and arguments.idx.listing_beds NEQ 0){
		rs.data.bedrooms[i]=arguments.idx.listing_beds;
	}else{
		rs.data.bedrooms[i]="";
	}
	if(arguments.idx.listing_baths neq '' and arguments.idx.listing_baths NEQ 0){
		rs.data.bathrooms[i]=arguments.idx.listing_baths;
	}else{
		rs.data.bathrooms[i]="";
	}
	if(arguments.idx.listing_halfbaths neq '' and arguments.idx.listing_halfbaths NEQ 0){
		rs.data.halfbaths[i]=arguments.idx.listing_halfbaths;
	}else{
		rs.data.halfbaths[i]="";
	}
	if(arguments.idx.listing_square_feet neq '' and arguments.idx.listing_square_feet NEQ 0){
		rs.data.square_footage[i]=arguments.idx.listing_square_feet;
	}else if(arguments.idx.listing_lot_square_feet NEQ '' and arguments.idx.listing_lot_square_feet NEQ '0'){
		rs.data.square_footage[i]=arguments.idx.listing_lot_square_feet;
	}else{
		rs.data.square_footage[i]="";
	}
	if(arguments.idx.listing_pool EQ 1){
		rs.data.pool[i]="Pool";
	}else{
		rs.data.pool[i]="";
	}
	if(isDefined('arguments.idx.listing_price') and arguments.idx.listing_price neq '' and arguments.idx.listing_price neq 0){
		if(arguments.idx.listing_price LT 20){
			rs.data.price[i]='$#numberformat(arguments.idx.listing_price)# per sqft ';
		}else{
			rs.data.price[i]='$#numberformat(arguments.idx.listing_price)#';
		}
	}else{
		rs.data.price[i]='';
	}
	if(arguments.idx.listing_subdivision neq 'Not In Subdivision' AND arguments.idx.listing_subdivision neq 'Not On The List' AND arguments.idx.listing_subdivision neq 'n/a' and isDefined('arguments.idx.listing_subdivision') and arguments.idx.listing_subdivision neq ''){
		rs.data.subdivision[i]=arguments.idx.listing_subdivision;
	}else{
		rs.data.subdivision[i]="";	
	}
	
	rs.data.photo1[i]=arguments.idx.photo1;
	if(isDefined('arguments.idx.listing_data_remarks') and arguments.idx.listing_data_remarks NEQ '' and this.optionStruct.compactWithLinks EQ false){
		tempText = rereplace(arguments.idx.listing_data_remarks, "<.*?>","","ALL");
		tempText2=left(tempText, 280);
		theEnd = mid(tempText, 281, len(tempText));
		pos = find(' ', theEnd);
		if(pos NEQ 0){
			tempText2=tempText2&left(theEnd, pos);
		}
		rs.data.description[i]=application.zcore.functions.zFixAbusiveCaps(tempText2);
	}else{
		rs.data.description[i]="";
	}
	if(isDefined('arguments.idx.listing_virtual_tour_url') and arguments.idx.listing_virtual_tour_url neq ''){
		rs.data.virtual_tour[i]=arguments.idx.listing_virtual_tour_url;
	}else{
		rs.data.virtual_tour[i]="";
	}
	return rs;
	</cfscript>
</cffunction>

<cffunction name="contentEmailTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="query" type="any" required="yes">
	<cfscript>
	var tempMLSId=0;
	var tempMLSPID=0;
	var tempMLSStruct=0;
	var contentConfig=application.zcore.app.getAppCFC("content").getContentIncludeConfig();
	if(contentConfig.showmlsnumber and application.zcore.app.siteHasApp("listing")){
		tempMlsId=arguments.query.content_mls_provider;
		tempMlsPId=arguments.query.content_mls_number;
		if(tempMLSId NEQ "" and tempMlsPId NEQ ""){
		    tempMLSStruct=application.zcore.listingCom.getMLSStruct(tempMLSId);
		    if(isStruct(tempMLSStruct)){
			if(tempMLSStruct.mls_login_url NEQ ''){
			    writeoutput('MLS ###tempMLSPid# found in #tempMLSStruct.mls_name# MLS, <a href="#tempMLSStruct.mls_login_url#" target="_blank">click here to login to MLS</a><br />');
			}else{
			    writeoutput('MLS ###tempMLSPid# found in #tempMLSStruct.mls_name# MLS<br />');
			}
		    }
		}
	}
	</cfscript>
	<table style="width:100%; border-spacing:0px; margin-bottom:10px;">
		<tr>
			<td style="vertical-align:top;padding:5px;width:100px;border-bottom:none;"><a target="_parent" href="<cfif arguments.query.content_url_only NEQ ''>#application.zcore.functions.zForceAbsoluteUrl(request.zos.currentHostName,arguments.query.content_url_only)#<cfelse>#request.zos.currentHostName#<cfif arguments.query.content_unique_name NEQ ''>#arguments.query.content_unique_name#<cfelse>/#application.zcore.functions.zURLEncode(arguments.query.content_name,'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_article_id#-#arguments.query.content_id#.html</cfif></cfif>" style="   font-weight:normal;  ">
				<cfif fileexists(request.zos.globals.homedir&'images/content/'&arguments.query.content_thumbnail)>
					<img src="#request.zos.currentHostName&'/images/content/'##arguments.query.content_thumbnail#" class="listing-d-img" id="zclistingdimg#arguments.query.content_id#" width="100" height="78">
				<cfelse>
					Image N/A
				</cfif>
				</a><br />
				<cfif contentConfig.showmlsnumber EQ false and arguments.query.content_mls_number NEQ "">
					ID ###listgetat(arguments.query.content_mls_number,2,'-')#
				</cfif></td>
			<td style="vertical-align:top;padding:5px;text-align:left;border-bottom:none;"><h3><a target="_parent" href="<cfif arguments.query.content_url_only NEQ ''>#application.zcore.functions.zForceAbsoluteUrl(request.zos.currentHostName,arguments.query.content_url_only)#<cfelse>#request.zos.currentHostName#<cfif arguments.query.content_unique_name NEQ ''>#arguments.query.content_unique_name#<cfelse>/#application.zcore.functions.zURLEncode(arguments.query.content_name,'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_article_id#-#arguments.query.content_id#.html</cfif></cfif>" style="text-decoration:none;">#arguments.query.content_name#</a>
					<cfif arguments.query.content_price NEQ 0>
						<br />
						$#numberformat(arguments.query.content_price)#
					</cfif>
				</h3>
				<a target="_parent" href="<cfif arguments.query.content_url_only NEQ ''>#application.zcore.functions.zForceAbsoluteUrl(request.zos.currentHostName,arguments.query.content_url_only)#<cfelse>#request.zos.currentHostName#<cfif arguments.query.content_unique_name NEQ ''>#arguments.query.content_unique_name#<cfelse>/#application.zcore.functions.zURLEncode(arguments.query.content_name,'-')#-#application.zcore.app.getAppData("content").optionstruct.content_config_url_article_id#-#arguments.query.content_id#.html</cfif></cfif>" style="margin-right:3px; display:block;  font-weight:bold; float:left; padding:4px; line-height:20px; text-decoration:none;  " class="z-manager-search-button zcontent-readmore-link ">Read More</a></td>
		</tr>
	</table> 
</cffunction>

<cffunction name="descriptionLinkTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	var str1=0;
	var pos=0;
	var pos2=0;
	var rr=0;
	var sr=0;
	var mr=arguments.idx.listing_data_remarks;
	mr=rereplacenocase(mr,"[^A-Za-z0-9]+"," ","ALL");
	mr=replacenocase(mr,"  "," ","ALL");
	mr=replacenocase(mr,"must see property","","ALL");
	mr=replacenocase(mr,"is sold in as is condition","","ALL");
	mr=replacenocase(mr,"AS-IS SALE","","ALL");
	mr=replacenocase(mr,"AS IS SALE","","ALL");
	mr=replacenocase(mr,"All offers are subject to third party approval","","ALL");
	mr=replacenocase(mr,"all offers are subject to 3rd party approval","","ALL");
	mr=replacenocase(mr,"Contracts are subject to third party approval","","ALL");
	mr=replacenocase(mr,"bring offers","","ALL");
	pos=findnocase("foreclosure",mr);
	str1=randrange(20,50);
	if(pos EQ 0){
		pos=max(1,randrange(1,len(mr)-str1));
	}
	pos2=find(" ", mr, pos+str1);
	rr=randrange(10,30);
	if(pos2 EQ 0){
		sr=mid(mr,max(pos-rr,1), (len(mr)-pos)+rr);
	}else{
		sr=mid(mr,max(pos-rr,1), (pos2-pos)+rr);
	}
	pos2=find(" ", sr);
	if(pos2 NEQ 0){
		sr=removechars(sr,1,pos2);
	}
	</cfscript>
	<a href="#request.zos.currentHostName#/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html" target="_parent" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>>
	<cfif sr EQ "">
		#htmleditformat(titleStruct.title)#
	<cfelse>
		#htmleditformat(trim(lcase(sr&' '&arguments.idx.cityName&' '&titleStruct.propertyType)))#
		<cfif arguments.idx.listing_subdivision NEQ "">
			in #htmleditformat(arguments.idx.listing_subdivision)#
		</cfif>
	</cfif>
	</a><br />
</cffunction>

<cffunction name="emailTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	var tempTitle = titleStruct.title;
	var urlTempTitle = titleStruct.urlTitle;
	var bgstyle=0;
	var propertyLink=0;
	if(arguments.idx.arrayindex MOD 2 EQ 0){
		bgstyle=" padding-bottom:5px; margin-bottom:15px; float:left; border-bottom:0px solid ##CCCCCC; background-image:url(#request.zos.currentHostName#/images/property-gradient.jpg); background-repeat:repeat-x; width:99%;";
	}else{
		bgstyle=" padding-bottom:5px; margin-bottom:15px; float:left; border-bottom:0px solid ##CCCCCC; background-image:url(#request.zos.currentHostName#/images/property-gradient.jpg); background-repeat:repeat-x; width:99%;";
	}
	propertyLink = request.zos.currentHostName&'/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
	if(isDefined('request.temp_saved_search_id')){
		propertyLink&='?saved_search_id=#request.temp_saved_search_id#&saved_search_email=#request.temp_saved_search_email#';
	}
	if(isDefined('this.optionStruct.showInactive') and this.optionStruct.showInactive){
		propertyLink=application.zcore.functions.zURLAppend(propertyLink,"showInactive=1");
	}
	</cfscript>
	<table style="border-spacing:0px;">
		<tr>
			<td style="vertical-align:top;padding:5px;"><a href="#propertyLink#" target="_parent" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif>> #application.zcore.functions.zLoadAndCropImage({id:"m#arguments.idx.listing_id#_img",width:100,height:70, url:arguments.idx.photo1, style:"", canvasStyle:"", crop:true})# 
				<!--- <img id="m#arguments.idx.listing_id#_img" src="#application.zcore.listingCom.getThumbnail(arguments.idx.photo1, request.lastPhotoId, 1, 100, 70, 1)#" alt="Listing Photo" width="100" /> ---></a><br />
				<cfif isDefined('this.optionStruct.hideMLSNumber') EQ false or this.optionStruct.hideMLSNumber EQ false>
					ID###listgetat(arguments.idx.listing_id,2,'-')#
				</cfif>
				<cfif isDefined('request.temp_saved_search_id') and arguments.idx.listing_track_datetime NEQ "" and DateCompare(arguments.idx.listing_track_datetime,this.optionStruct.lastVisitDate) LTE 0>
					<br />
					<span style="color:##FF0000; font-weight:bold; ">New Listing!</span>
				</cfif></td>
			<td style="vertical-align:top;padding:5px;"><h2 style="font-size:14px; font-style:normal; line-height:normal; margin:0px; padding:0px; padding-bottom:5px; "><a href="#propertyLink#" target="_parent" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> style="text-decoration:none; ">#tempTitle#</a>
					<cfif isDefined('arguments.idx.content_mls_price') and arguments.idx.content_mls_price EQ 0 and arguments.idx.content_price NEQ "0">
						<br />
						$#numberformat(arguments.idx.content_price)#
					<cfelse>
						<cfif arguments.idx.listing_price NEQ "0">
							<br />
							$#numberformat(arguments.idx.listing_price)# <br />
							#arguments.idx.listingListStatus#
						</cfif>
					</cfif>
				</h2>
				<a href="#propertyLink#" target="_parent" style="margin-right:3px; display:block; font-weight:bold; float:left; padding:4px; line-height:20px; text-decoration:none; 	border-bottom:1px solid ##CCCCCC; " <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> class="zcontent-readmore-link">Read More</a></td>
		</tr>
	</table>
	<hr />
</cffunction>

<cffunction name="emailPlainTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	var tempTitle = titleStruct.title;
	var urlTempTitle = titleStruct.urlTitle;
	var propertyLink = '#request.zos.currentHostName#/#urlTempTitle#-#arguments.idx.listing_id#.html';
	if(isDefined('request.temp_saved_search_id')){
		propertyLink=propertyLink&'?saved_search_id=#request.temp_saved_search_id#&saved_search_email=#request.temp_saved_search_email#';
	}
	writeoutput('---------------------------------#chr(10)# MLS ###arguments.idx.listing_id##chr(10)# #replace(tempTitle,'<br />',chr(10),'ALL')##chr(10)# #propertyLink##chr(10)#');
	return;
	</cfscript>
</cffunction>

<cffunction name="mapTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var zdindex=0;
	var propertyLink=0;
	var image=0;
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	
	if(structkeyexists(request.zos, 'customListingMapLinkJSTemplate')){
		propertyLink=replacenocase(request.zos.customListingMapLinkJSTemplate, "##listing_id##", arguments.idx.listing_id, "one");
	}else{
		var propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
		if(isDefined('this.optionStruct.searchID')){
			zdIndex = ((application.zcore.status.getField(this.optionStruct.searchId, "zIndex",0)-1)*application.zcore.status.getField(this.optionStruct.searchId, "perpage",0))+i;
			propertyLink=application.zcore.functions.zURLAppend(propertyLink,"searchID=#this.optionStruct.searchID#&zdIndex=#zdIndex#");
		}
		propertyLink=htmleditformat("zlsGotoMapLink('#propertyLink#'); return false;");
	}
	request.currentmappropertylink=propertyLink;
	if(structkeyexists(arguments.idx, 'sysidfield2')){
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1, arguments.idx.sysidfield, arguments.idx.sysidfield2);
	}else if(structkeyexists(arguments.idx, 'sysidfield')){
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1, arguments.idx.sysidfield);
	}else{
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1);
	}
	</cfscript>
	<table style="width:100%; border-spacing:0px;">
		<tr>
			<td style="width:100px;padding:5px; vertical-align:top; padding-right:10px;border-right:1px solid ##999;"><cfif image neq false>
					<a href="##" onclick="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> target="_top"><img src="#application.zcore.listingCom.getThumbnail(image, request.lastPhotoId, 1, 100, 78, 1)#" width="100" height="78" onerror="this.style.display='none';document.getElementById('zmaptemplateimagena').style.display='block';" /></a>
					<cfelse>
					Image N/A
				</cfif>
				<div id="zmaptemplateimagena" style="display:none;">Image N/A</div></td>
			<td style="vertical-align:top; padding:5px; font-weight:normal;  "><a href="##" onclick="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> target="_top">
				<cfscript>
				if(arguments.idx.listing_beds neq '' and arguments.idx.listing_beds NEQ 0){
					writeoutput('#arguments.idx.listing_beds#bd, ');
				}
				if(arguments.idx.listing_halfbaths neq '' and arguments.idx.listing_halfbaths neq '0' and arguments.idx.listing_baths neq ''and arguments.idx.listing_baths neq '0'){
					writeoutput('#(arguments.idx.listing_halfbaths / 2) + arguments.idx.listing_baths#ba, ');
				}
				writeoutput('#arguments.idx.listingPropertyType#<br />');
				writeoutput('#arguments.idx.cityName#');
				
				if(arguments.idx.listing_price NEQ '0') {
					writeoutput('<br /><strong style="font-size:14px; line-height:18px;">$#numberformat(arguments.idx.listing_price)#</strong>');
				}
				writeoutput('<br /><strong style="font-size:13px; line-height:18px;">'&arguments.idx.listingListStatus&'</strong>');
				</cfscript>
				</a>
				<hr />
				<a href="##" onclick="goToStreetV3(#arguments.idx.listing_latitude#,#arguments.idx.listing_longitude#); return false;" rel="nofollow">Zoom to Street Level</a><br />
				<a href="##" onclick="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> target="_top"><strong>Click here for details</strong></a></td>
		</tr>
	</table>
</cffunction>

<cffunction name="rssTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var tempText=0;
	var theEnd=0;
	var pos=0;
	var date=0;
	var time=0;
	var imageLink=0;
	var propertyLink=0;
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	var tempTitle = titleStruct.title;
	var urlTempTitle = titleStruct.urlTitle;
	var commentlink="#request.zos.currentHostName##request.cgi_script_name#?action=form&mls_id=#arguments.idx.mls_id#&listing_id=#arguments.idx.listing_id#";
	
	imagelink=request.zos.currentHostName&application.zcore.listingCom.getThumbnail(arguments.idx.photo1, request.lastPhotoId, 1, 221, 165, 1);
	propertyLink = '#request.zos.currentHostName#/#urlTempTitle#-#arguments.idx.listing_id#.html';
	date = dateformat(arguments.idx.listing_track_updated_datetime, "ddd, dd mmm yyyy");
	time = timeformat(arguments.idx.listing_track_updated_datetime, "HH:mm:ss") & " EST";
	</cfscript>
	<item>
	<title>#xmlFormat(replace(tempTitle,'<br />',chr(10),'ALL'))#</title>
	<link>
	#xmlFormat(propertyLink)#
	</link>
	<cfscript> 
	tempText = rereplace(arguments.idx.listing_data_remarks, "<.*?>","","ALL");
	tempText = left(tempText, 280);
	theEnd = mid(arguments.idx.listing_data_remarks, 281, len(arguments.idx.listing_data_remarks));
	pos = find(' ', theEnd);
	if(pos NEQ 0){
		tempText=tempText&left(theEnd, pos);
	}
	tempText=application.zcore.functions.zFixAbusiveCaps(tempText);
	</cfscript>
	<description>
		<![CDATA[<p><cfif imagelink neq false><img src="#xmlFormat(imagelink)#" style="float:left; padding-right:10px; padding-bottom:10px;"/></cfif>#xmlFormat(tempText)#</p>]]>
	</description>
	<pubDate>#date# #time#</pubDate>
	<comments>#xmlformat(commentlink)#</comments>
	</item>
</cffunction>

<cffunction name="savedTemplate" localmode="modern" output="yes" returntype="any">
	<cfargument name="idx" type="struct" required="yes">
	<cfscript>
	var propertyLink=0;
	var image=0;
	var titleStruct = request.zos.listing.functions.zListinggetTitle(arguments.idx);
	propertyLink = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#arguments.idx.urlMlsId#-#arguments.idx.urlMLSPId#.html';
	propertyLink=htmleditformat(propertyLink);
   
	if(structkeyexists(arguments.idx, 'sysidfield2')){
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1, arguments.idx.sysidfield, arguments.idx.sysidfield2);
	}else if(structkeyexists(arguments.idx, 'sysidfield')){
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1, arguments.idx.sysidfield);
	}else{
		image=application.zcore.listingCom.getPhoto(arguments.idx.listing_id,1);
	}
	</cfscript>
	<td style="text-align:center; border-right:1px solid ##999;">
	<cfif image neq false>
		<a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> target="_top" title="#htmleditformat(left(arguments.idx.listing_data_remarks,100))#"><img src="#application.zcore.listingCom.getThumbnail(image, request.lastPhotoId, 1, 100, 78, 1)#" style="max-width:100%;" class="listing-d-img" id="zlistingdimg#arguments.idx.listing_id#" alt="Listing Photo" /></a>
	<cfelse>
		Image N/A
	</cfif>
	<br />
	<a href="#propertyLink#" <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1>rel="nofollow"</cfif> target="_top" style="  font-weight:normal;  ">
	<cfscript>
	if(isDefined('arguments.idx.listing_beds') and arguments.idx.listing_beds neq '' and arguments.idx.listing_beds NEQ 0){
		writeoutput('#arguments.idx.listing_beds#bd, ');
	}
	
	writeoutput('#titleStruct.propertyType#, ');
	
	if(isDefined('arguments.idx.listing_halfbaths') and arguments.idx.listing_halfbaths neq '' and arguments.idx.listing_halfbaths neq '0' and isDefined('arguments.idx.listing_baths') and arguments.idx.listing_baths neq ''and arguments.idx.listing_baths neq '0'){
		writeoutput('#(arguments.idx.listing_halfbaths / 2) + arguments.idx.listing_baths#ba, ');
	}
	if(isDefined('arguments.idx.content_mls_price') and arguments.idx.content_mls_price EQ 0 and arguments.idx.content_price NEQ "0"){
		writeoutput("$"&numberformat(arguments.idx.content_price));
	}else{
		if(arguments.idx.listing_price NEQ '0') {
			writeoutput('$#numberformat(arguments.idx.listing_price)#');
		}
	}
	writeoutput(", "&arguments.idx.listingListStatus);
	</cfscript>
	</a><br />
	<a href="##" class="zls-removeListingButton" data-listing-id="#arguments.idx.listing_id#" style=" font-weight:bold;  " title="Delete This Property From Your List" rel="nofollow" target="_top">Remove</a></td>
</cffunction>
 
</cfoutput>
</cfcomponent>
