<cfcomponent>
	<cfoutput>
    <cffunction name="rateInfoTemplate" localmode="modern" access="remote" output="yes" returntype="any">
<cfscript>
var ts=0;
var temppagenav=0;
		var db=request.zos.queryObject;
application.zcore.app.getAppCFC("rental").onRentalPage();
</cfscript>
<cfsavecontent variable="temppagenav">
<a href="/">#application.zcore.functions.zvar('homelinktext')#</a> / 
<a href="#application.zcore.app.getAppCFC("rental").getRentalHomeLink()#">#application.zcore.app.getAppData("rental").optionstruct.rental_config_home_page_title#</a> / 
</cfsavecontent> 
 <!--- <cfif isDefined('hideRateInfo') EQ false and isDefined('rental_special')>
<!--- Rates are color coded so you can see what dates they fall on the calendar.<br />
<br style="clear:both;" />
<table style="border-spacing:5px; font-weight:bold; width:100%;">
<tr><td style="background-color:##FFFFFF; border:1px solid ##000000; border-right:none; text-align:center;">Standard Rate: #DollarFormat(rental_rate)# per night</td>
<td style="background-color:##CCFF99; border:1px solid ##000000; border-right:none; text-align:center;">Peak Season Rate: #DollarFormat(rental_rate_peak)# per night</td>
<td style="background-color:##FFDD99; border:1px solid ##000000; text-align:center;">Holiday Rate: #DollarFormat(rental_rate_holiday)# per night</td></tr>
</table>
<br /> --->



<cfif trim(rental_special) NEQ ''>
<span style="color:##FF0000; font-weight:bold; font-size:14px;">
<div id="premhint2" style="position:relative; left:0; visibility:'visible';text-align:left; width:400px;">#rental_special#</div></span><br /><br />
<cfif rental_special_flash EQ 1>
<script type="text/javascript">
/* <![CDATA[ */ zArrDeferredFunctions.push(function(){zBlinkId("premhint2",500);}); /* ]]> */
</script>
</cfif> 

<cfsavecontent variable="db.sql">
SELECT * FROM #db.table("rate", request.zos.zcoreDatasource)# rate 
WHERE rental_id = #db.param('0')# and rate_property NOT IN (#db.param(',#rental_id#,')#) and 
rate_deleted = #db.param(0)# and 
rate_start_date <=#db.param(DateFormat(dateadd("yyyy",1,now()),'yyyy-mm-dd'))# and 
rate_end_date >= #db.param(DateFormat(now(),'yyyy-mm-dd'))# 
ORDER BY rate_period DESC, rate_sort asc
</cfsavecontent><cfscript>qR=db.execute("qR");</cfscript>

<cfsavecontent variable="db.sql">
SELECT * FROM #db.table("rate", request.zos.zcoreDatasource)# rate 
WHERE  rental_id = #db.param(rental_id)# and 
rate_deleted = #db.param(0)# and 
rate_start_date <=#db.param(DateFormat(dateadd("yyyy",1,now()),'yyyy-mm-dd'))# and 
rate_end_date >= #db.param(DateFormat(now(),'yyyy-mm-dd'))# 
ORDER BY rate_period DESC, rate_sort asc
</cfsavecontent><cfscript>qR2=db.execute("qR2");</cfscript>
<h2>Current specials for this rental | Limit of 1 special per reservation.</h2>
<p>Specials are automatically calculated during your online reservation.  </p>
<style type="text/css">
.tbb2 td{ border-bottom:1px solid ##999999; padding:10px; }
.table-list th{ border-bottom:1px solid ##999999; background-color:##990000; color:##FFFFFF; padding:10px; }
</style>
<table  style="border-spacing:10px;" class="table-list tbb2">
<tr>
<!--- <th style="width:15px;">##</th> --->
<th style="width:300px;">Promotion</th>
<th>Minimum Stay</th>
<th>Valid Date Range</th>
<th>Limited to:</th>
</tr>
<cfset n2=0>
<cfloop query="qR2">
<cfset n2++>
<tr>
<!--- <td style="width:15px; <cfif n2 MOD 2 EQ 0>background-color:##F3F3F3;</cfif>">#n2#</td> --->
<td style="width:300px;<cfif n2 MOD 2 EQ 0>background-color:##F3F3F3;</cfif>"><cfif rate_event_summary NEQ ''>#rate_event_summary#<br /></cfif>
<cfscript>
if(rate_coupon_type EQ 1){
	// day off
	if(rate_coupon EQ 1){
		writeoutput(round(rate_coupon)&' free night');
	}else{
		writeoutput(round(rate_coupon)&' free nights');
	}
}else if(rate_coupon_type EQ 2){
	writeoutput(rate_coupon&'% off the nightly rate.');
}else if(rate_coupon_type EQ 0){
	writeoutput("Discounted to "&dollarformat(rate_rate)&'/night.');
}
</cfscript>
</td>
<td style="<cfif n2 MOD 2 EQ 0>background-color:##F3F3F3;</cfif>">#rate_period# night<cfif rate_period NEQ 1>s</cfif></td>
<td style="<cfif n2 MOD 2 EQ 0>background-color:##F3F3F3;</cfif>">#dateformat(rate_start_date,'m/dd/yy')# to #dateformat(rate_end_date,'m/dd/yy')#</td>
<td style="<cfif n2 MOD 2 EQ 0>background-color:##F3F3F3;</cfif>">#mid(rate_day,2,len(rate_day)-2)#&nbsp;</td>
</tr>
</cfloop>
<cfloop query="qR">
<cfset n2++>
<tr>
<!--- <td style="width:15px;<cfif n2 MOD 2 EQ 0>background-color:##F3F3F3;</cfif>">#n2#</td> --->
<td style="width:300px; <cfif n2 MOD 2 EQ 0>background-color:##F3F3F3;</cfif>"><cfif rate_event_summary NEQ ''>#rate_event_summary#<br /></cfif>
<cfscript>
if(rate_coupon_type EQ 1){
	// day off
	if(rate_coupon EQ 1){
		writeoutput(round(rate_coupon)&' free night');
	}else{
		writeoutput(round(rate_coupon)&' free nights');
	}
}else if(rate_coupon_type EQ 2){
	writeoutput(rate_coupon&'% off the nightly rate.');
}else if(rate_coupon_type EQ 0){
	writeoutput("Discounted to "&dollarformat(rate_rate)&'/night.');
}
</cfscript>
</td>
<td style="<cfif n2 MOD 2 EQ 0>background-color:##F3F3F3;</cfif>">#rate_period# night<cfif rate_period NEQ 1>s</cfif></td>
<td style="<cfif n2 MOD 2 EQ 0>background-color:##F3F3F3;</cfif>">#dateformat(rate_start_date,'m/dd/yy')# to #dateformat(rate_end_date,'m/dd/yy')#</td>
<td style="<cfif n2 MOD 2 EQ 0>background-color:##F3F3F3;</cfif>">#mid(rate_day,2,len(rate_day)-2)#&nbsp;</td>
</tr>
</cfloop>
</table><br />



<p><strong>Please note for all specials:</strong> You can't combine our specials or other discounts together. Existing reservations do not apply.  If the special is no longer advertised here, it may have expired and is no longer valid. When a free night promotion is offered, the cheapest night of your stay is the free one.</p>
<!--- ignore holiday checks. --->
<!--- 
<strong>Stay for 5 consecutive nights and get the 6th night free! </strong><br />The free night will be the value of lowest nightly rate that is during the stay dates.<br /><br /> --->
<hr />
<cfset tempLink="">
<h2>Reserve #rental_name# Right Now | <a href="#tempLink#">View Full Calendar</a></h2>

Please select the start and end date of your stay and click "Search Availability"<br />
<br />

<!--- <h2>Search Availability</h2> --->
<!--- <cfset calendarInclude=true>
include rental availability calendar --->
<iframe src="/z/rental/rental-front/checkAvailabilityTemplate?ifmdisable=1&ifmshowCalendar=1&rental_id=#application.zcore.functions.zso(form, 'rental_id')#" height="630" width="100%"  style="border:none; overflow:auto;" seamless="seamless"></iframe>

<br />


</cfif>
<!--- 
rental_max_guest
rental_rate_cleaning --->
</cfif>
<!--- ---> --->
<cfscript>
ts=structnew();
ts.content_unique_name='/Rental-Reservation-Policies-#application.zcore.app.getAppData("rental").optionstruct.rental_config_misc_url_id#-1.html';
</cfscript>
<cfif form.method NEQ "rateInfoTemplate">
	<hr />
<cfscript>

	ts.disableContentMeta=false;
	ts.disableLinks=true;
	var r1=application.zcore.app.getAppCFC("content").includeContentByName(ts);
	writeoutput('<span style="font-size:14px; "><a href="/Rental-Reservation-Policies-#application.zcore.app.getAppData("rental").optionStruct.rental_config_misc_url_id#-1.html">Please review our rental reservation policies</a></span>');
</cfscript>
<cfelse>
	<cfsavecontent variable="temppagenav">
	<a href="/">#application.zcore.functions.zvar('homelinktext')#</a> / 
    <a href="#application.zcore.app.getAppCFC("rental").getRentalHomeLink()#">#application.zcore.app.getAppData("rental").optionstruct.rental_config_home_page_title#</a> / 
	</cfsavecontent> 
	<cfscript>
	application.zcore.template.setTag('title',"Rental Rate Information");
	application.zcore.template.setTag('pagetitle',"Rental Rate Information"); 
	r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts); 
	application.zcore.template.setTag('pagenav',temppagenav);
</cfscript> 
</cfif>
    </cffunction>
    
	<cffunction name="rentalTemplate" localmode="modern" access="remote" returntype="any">
    	<cfscript>
	var arrCatId=0;
var temppagenav=0;
var photoWidth=0;
var calendarLink=0;
var arrImages=0;
var qXAmenity=0;
var qCat=0;
var property_id=0;
var qRental=0;
var i=0;
var arrAmen=0;
var photoHeight=0;
var link=0;
var r1=0;
var tempMeta=0;
var arrThumbSize=0;
var ts=0;
		var db=request.zos.queryObject;
		application.zcore.app.getAppCFC("rental").onRentalPage();
		form.rental_id=application.zcore.functions.zso(form, 'rental_id',true);
		</cfscript>
 
<cfsavecontent variable="db.sql">
SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
WHERE rental_id = #db.param(form.rental_id)# and 
site_id = #db.param(request.zos.globals.id)# and 
rental_deleted=#db.param(0)# 
GROUP BY rental.rental_id 
</cfsavecontent><cfscript>qRental=db.execute("qRental");
if(qRental.recordcount EQ 0 or (qRental.rental_active EQ 0)){
	application.zcore.functions.z404("rental record is missing in rentalTemplate.");
}
application.zcore.functions.zQueryToStruct(qRental, local);
request.zos.tempObj.currentRentalQuery=qRental;
application.zcore.functions.zStatusHandler(request.zsid, true);
calendarLink =application.zcore.app.getAppCFC("rental").getCalendarLink(rental_id, rental_name, rental_url);
</cfscript>

<cfsavecontent variable="tempMeta">
<meta name="Keywords" content="#htmleditformat(rental_metakey)#" />
<meta name="Description" content="#htmleditformat(rental_metadesc)#" />
</cfsavecontent>
<cfsavecontent variable="temppagenav">
<a href="/">#htmleditformat(application.zcore.functions.zvar('homelinktext'))#</a> / 
<a href="#application.zcore.app.getAppCFC("rental").getRentalHomeLink()#">#htmleditformat(application.zcore.app.getAppData("rental").optionstruct.rental_config_home_page_title)#</a> / 

<cfscript>
arrCatId=listtoarray(rental_category_id_list,",",true);
if(arraylen(arrCatId) GTE 2){
	 db.sql="SELECT * FROM #db.table("rental_category", request.zos.zcoreDatasource)# rental_category 
	WHERE rental_category_id=#db.param(arrCatId[2])# and 
	rental_category_deleted=#db.param(0)#  and 
	site_id = #db.param(request.zos.globals.id)# ";
	qCat=db.execute("qCat");
	if(qCat.recordcount NEQ 0){
		writeoutput('<a href="#application.zcore.app.getAppCFC("rental").getCategoryLink(qcat.rental_category_id,qcat.rental_category_name,qcat.rental_category_url)#">#htmleditformat(qcat.rental_category_name)#</a> /');
	}
}
</cfscript>

</cfsavecontent> 
<cfscript>
application.zcore.template.setTag('title',rental_name);
application.zcore.template.setTag('meta',tempMeta);
application.zcore.template.setTag('pagetitle',rental_name);
application.zcore.template.setTag('pagenav',temppagenav);


	//if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){ 
		writeoutput('<div style="display:inline;"  id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit zEditorHTML" data-editurl="/z/rental/admin/rates/editRental?rental_id=#rental_id#&amp;return=1">');
		application.zcore.template.prependTag('pagetitle','<span style="display:inline;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/rental/admin/rates/editRental?rental_id=#rental_id#&amp;return=1">');
		application.zcore.template.appendTag('pagetitle','</span>');
	//}   
</cfscript> 
<div class="zrental-header">Rental Property</div>
<div class="zrental-menu"><a href="##zrental-amenities">Amenities</a> <cfif rental_text NEQ ""><a href="##zrental-description">Description</a></cfif> <a href="##zrental-rates">Rates</a> <a href="##zrental-photos">Photos</a> 

    <cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_availability_calendar EQ 1 and rental_enable_calendar EQ '1'>
<a href="#application.zcore.app.getAppCFC("rental").getCalendarLink(rental_id,rental_name,rental_url)#">Calendar</a>  
</cfif>
    <cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_reserve_online EQ 1>
<a href="##zrental-calendar"><strong>Reserve Now</strong></a>
<cfelse>
<a href="#application.zcore.app.getAppCFC("rental").getRentalInquiryLink()#?rental_id=#rental_id#">Inquire Now</a>
  </cfif>
<br style="clear:both;" /></div><br style="clear:both;" />

<div class="zrental-main">
<cfscript>
photoWidth=round(request.zos.globals.maximagewidth-232);
photoHeight=round((photoWidth/450)*299);

</cfscript>
<div class="zrental-main-photo" style="width:#photoWidth#px; height:#photoHeight#px;"><cfscript>

ts=structnew(); 
ts.output=false;
ts.image_library_id=rental_image_library_id;
ts.size=application.zcore.app.getAppCFC("rental").getImageSize("rental-page-thumbnail");
arrThumbSize=listtoarray(ts.size,"x");
ts.crop=1;
arrImages=application.zcore.imageLibraryCom.displayImages(ts);
if(arraylen(arrImages) NEQ 0){
	application.zcore.imageLibraryCom.registerSize(rental_image_library_id, application.zcore.app.getAppCFC("rental").getImageSize("rental-page-main"), 0);
	link=application.zcore.imageLibraryCom.getImageLink(rental_image_library_id, arrImages[1].id, application.zcore.app.getAppCFC("rental").getImageSize("rental-page-main"), 0, true, arrImages[1].caption, arrImages[1].file, arrImages[1].updatedDatetime);
	// temporarily disabled the popup images.
	writeoutput('<img src="#link#" alt="#htmleditformat(arrImages[1].caption)#" style="border:none; text-align:middle; " />');
}

</cfscript></div>

<div class="zrental-main-header" style="width:#request.zos.globals.maximagewidth-photoWidth-42#px; height:#photoHeight-22#px">
Rental Summary<br />
<h2><cfif application.zcore.functions.zso(form, 'rental_beds',true) NEQ 0>#rental_beds# Bedroom<cfif rental_beds GT 1>s</cfif></cfif><cfif application.zcore.functions.zso(form, 'rental_beds',true) NEQ 0 or application.zcore.functions.zso(form, 'rental_bath',true) NEQ 0><br /> </cfif>
<cfif application.zcore.functions.zso(form, 'rental_bath',true) NEQ 0>#rental_bath# Bath<cfif rental_bath GT 1>s</cfif></cfif><cfif rental_beds NEQ 0 or rental_bath NEQ 0><br /></cfif>
<cfif application.zcore.functions.zso(form, 'rental_max_guest',true) NEQ 0>Sleeps 1 to #rental_max_guest#</cfif>
</h2>

#rental_description#
</div></div><br style="clear:both;" />
<br style="clear:both;" /> 
<cfset property_id = 20>
<cfscript>
arrAmen=arraynew(1);
if(rental_pool EQ 1){
	arrayappend(arrAmen,'&middot; Pool');	
}
if(rental_mountainview EQ 1){
	arrayappend(arrAmen,'&middot; Mountain View');	
}
if(rental_waterview EQ 1){
	arrayappend(arrAmen,'&middot; Water View');	
}
if(rental_gameroom EQ 1){
	arrayappend(arrAmen,'&middot; Game Room');	
}
if(rental_cabletv EQ 1){
	arrayappend(arrAmen,'&middot; Satellite/Cable TV');	
}
if(rental_highspeedinternet EQ 1){
	arrayappend(arrAmen,'&middot; High Speed Internet');	
}
if(rental_fireplace EQ 1){
	arrayappend(arrAmen,'&middot; Fireplace');	
}
if(rental_petfriendly EQ 1){
	arrayappend(arrAmen,'&middot; Pet Friendly');	
}
if(rental_oceanview EQ 1){
	arrayappend(arrAmen,'&middot; Ocean View');	
}
if(rental_riverview EQ 1){
	arrayappend(arrAmen,'&middot; River View');	
}
 db.sql="select * from #db.table("rental_x_amenity", request.zos.zcoreDatasource)# rental_x_amenity, 
 #db.table("rental_amenity", request.zos.zcoreDatasource)# rental_amenity 
WHERE rental_x_amenity.site_id = rental_amenity.site_id and 
rental_amenity_deleted = #db.param(0)# and 
rental_x_amenity_deleted = #db.param(0)# and 
rental_amenity.rental_amenity_id = rental_x_amenity.rental_amenity_id and 
rental_x_amenity.site_id = #db.param(request.zos.globals.id)# and 
rental_id = #db.param(rental_id)#";
qXAmenity=db.execute("qXAmenity");
</cfscript>
<cfloop query="qXAmenity"><cfscript>
	arrayappend(arrAmen,'&middot; '&qXAmenity.rental_amenity_name);	</cfscript></cfloop>
    <cfscript>
	arraysort(arrAmen, "text","asc");
	</cfscript>
<cfif rental_amenities_text NEQ "" or arraylen(arrAmen) NEQ 0>
<a id="zrental-amenities"></a>
<div class="zrental-box zrental-amenities-box">
<div class="zrental-subtitle"><div style="width:300px; text-align:right; float:right;"><a href="/Compare-Rental-Amenities-#application.zcore.app.getAppData("rental").optionstruct.rental_config_misc_url_id#-2.html" style="font-size:14px; font-weight:bold;">Click here to compare all rentals</a></div><h2 style="margin:0px; padding:0px;">Featured Amenities</h2></div>
<div class="zrental-box-inner">
<cfif rental_amenities_text NEQ "">#rental_amenities_text#</cfif>
<table style="width:100%; border-spacing:5px;">
	<cfscript>	
	inputStruct = StructNew();
	inputStruct.colspan = 3;
	inputStruct.rowspan = arraylen(arramen);
	inputStruct.vertical = true;
	myColumnOutput = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.loopOutput");
	myColumnOutput.init(inputStruct);
	
for(i=1;i LTE arraylen(ArrAmen);i++){
	writeoutput(myColumnOutput.check(i));
	writeoutput(arrAmen[i]&'<br />');
	writeoutput(myColumnOutput.ifLastRow(i));
}
</cfscript>
</table><br />
</div>
</div><br style="clear:both;" />
</cfif>
<cfif rental_text NEQ "">
<a id="zrental-description"></a>
<div class="zrental-box">
<h2 class="zrental-subtitle">Rental Description</h2>
<div class="zrental-box-inner">
#rental_text#
</div>
</div>
</cfif>

<br style="clear:both;" /> 

<a id="zrental-rates"></a>
<div class="zrental-box">
<h2 class="zrental-subtitle">Rates &amp; Rental Policy</h2>
<div class="zrental-box-inner">
<cfif trim(rental_special) NEQ ''>
<span style="color:##FF0000; font-weight:bold; font-size:14px;">
<div id="zratepremhint2" style="position:relative; left:0; top:0; visibility:'visible';text-align:left; width:100%;">#rental_special#</div></span><br />
<cfif rental_special_flash EQ 1>
<script type="text/javascript">
/* <![CDATA[ */ zArrDeferredFunctions.push(function(){zBlinkId("zratepremhint2",500);}); /* ]]> */
</script>
</cfif> 
</cfif>
#rental_rate_text#

<cfscript>
this.rateInfoTemplate();
</cfscript>

</div>
</div>
<br style="clear:both;" /> 

<a id="zrental-photos"></a>
<div class="zrental-box">
<h2 class="zrental-subtitle">Photos</h2>
<div id="zRentalThumbnailLightGallery" class="zrental-box-inner">

<cfscript>

	/*
arrPhoto=application.zcore.app.getAppCFC("rental").getPhotoArray(qRental,"small",1);

for(i=1;i LTE arraylen(arrPhoto);i=i+1){
	link=application.zcore.app.getAppCFC("rental").getPhotoLink(rental_id, rental_name, rental_url, i);
	writeoutput('<img src="/images/rental/#arrPhoto[i].name#" width="200" style="float:left; padding:10px; padding-left:0px; padding-bottom:0px; cursor:pointer" onclick="var winId=window.open(''#link#'',''null'',''height=360,width=475,status=yes,toolbar=no,menubar=no,location=no'');if (window.focus) {winId.focus()}">');
}
*/
ts=structnew(); 
ts.output=false;
ts.image_library_id=rental_image_library_id;
ts.size="960x960";
ts.crop=0;
ts.offset=0;
arrImages2=application.zcore.imageLibraryCom.displayImages(ts);

//application.zcore.skin.includeJS("/z/javascript/jquery/lightbox/jquery.lightbox-0.5.min.js");
//application.zcore.skin.includeCSS("/z/javascript/jquery/lightbox/css/jquery.lightbox-0.5.css");

for(i=1;i LTE arraylen(arrImages);i=i+1){
	// temporarily disabled the popup images.
	link=application.zcore.app.getAppCFC("rental").getPhotoLink(rental_id, arrImages[i].caption&" | "&rental_name, rental_url, arrImages[i].id);
	writeoutput('<a href="#arrImages2[i].link#" class="zNoContentTransition"><img src="#arrImages[i].link#" alt="#htmleditformat(arrImages[i].caption)#" width="#arrThumbSize[1]#" height="#arrThumbSize[2]#" style="float:left; padding:10px; padding-left:0px; padding-bottom:0px; ');
	if((i) MOD 3 EQ 0){
		writeoutput(' padding-right:0px;');	
	}
	echo('" /></a>');
	//writeoutput(' cursor:pointer" onclick="var winId=window.open(''#link#'',''null'',''height=360,width=475,status=yes,toolbar=no,menubar=no,location=no'');if (window.focus) {winId.focus()}" />');
}

application.zcore.functions.zSetupLightbox("zRentalThumbnailLightGallery");
</cfscript>
<!--- <script type="text/javascript">
/* <![CDATA[ */ zArrDeferredFunctions.push(function(){
$('##zRentalThumbnailLightGallery a').lightBox();
}); /* ]]> */
</script>--->
<br style="clear:both;" />
</div>
</div>  
   <cfscript>
	//if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){ 
		writeoutput('</div>');
	//}
	</cfscript>
	</cffunction>
    
    
    <cffunction name="rentalEmailIncludeTemplate" localmode="modern" access="remote" returntype="any"> 
    	<cfargument name="ss" type="struct" required="yes">
<cfscript>
ss=arguments.ss;
application.zcore.app.getAppCFC("rental").onRentalPage(); 
</cfscript>
        <table style="width:100%; border-spacing:10px;"> <tr>
              <td rowspan="2" style="vertical-align:top; text-align:center;font-size:12px;font-weight:bold;border-bottom:2px solid ##999999;"><a href="#request.zos.currentHostName##application.zcore.app.getAppCFC("rental").getRentalLink(ss.rental_id, ss.rental_name, ss.rental_url)#">
			  <cfscript>
			var ts=structnew();
			ts.image_library_id=ss.rental_image_library_id;
			ts.output=false;
			ts.struct=ss; 
			ts.size="150x100";
			ts.crop=1;
			ts.count = 2; // how many images to get
			//zdump(ts);
			var arrImages=application.zcore.imageLibraryCom.displayImageFromStruct(ts); 
			for(var i=1;i LTE arraylen(arrImages);i++){
				writeoutput('<img src="#request.zos.currentHostName#'&arrImages[i].link&'" width="150" height="100" alt="#htmleditformat(arrImages[i].caption)#" style="border:none;" />');
			} 
			</cfscript>
<span style="padding-bottom:10px;display:block;">#ss.rental_name#</span></a></td>
                <td>
<cfif ss.rental_beds NEQ "">#ss.rental_beds# Bedrooms<cfif ss.rental_beds GT 1>s</cfif><br /></cfif>
<cfif ss.rental_bath NEQ "">#ss.rental_bath# Bathroom<cfif ss.rental_bath GT 1>s</cfif><br />
</cfif>
<cfif ss.rental_max_guest NEQ 0>Sleeps 1 to #ss.rental_max_guest#</cfif>
</td>
                <td>
                
<cfscript>
var ts=StructNew();
ts.rental_id=ss.rental_id;
ts.startDate=form.startDate;
ts.endDate=form.endDate;
ts.adults=form.inquiries_adults;
ts.children=form.inquiries_children;
ts.couponCode=form.inquiries_coupon;
var rs=application.zcore.app.getAppCFC("rental").rateCalc(ts);
//zdump(rs);
//zabort();
var mrate=0;
if(arraylen(rs.arrNights)){
	mrate=rs.arrNights[1].rate;
}
for(var i=2;i LTE arraylen(rs.arrNights);i++){
	mrate=min(mrate,rs.arrNights[i].rate);
}
var preg=ss.rental_display_regular;
if(ss.rental_display_regular EQ 0){
	preg=ss.rental_rate;
}
</cfscript>
<span style="line-height:18px;"><cfif preg-mrate GT 0><span style="text-decoration:line-through; color:##CCCCCC; font-size:12px;">From #dollarformat(preg)#/night</span><br /></cfif>
<cfif mrate NEQ 0>From #dollarformat(mrate)#/night<br /></cfif>
<cfif preg-mrate GT 0><strong style="color:##FF0000; font-size:12px;">Save up to $#(preg-mrate)#/night</strong></cfif></span></td>
                <td style="text-align:right;">
                <a href="#request.zos.currentHostName##application.zcore.app.getAppCFC("rental").getRentalLink(ss.rental_id, ss.rental_name, ss.rental_url)#">View Rental</a><br />
                
    <cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_availability_calendar EQ 1 and ss.rental_enable_calendar EQ '1' and structkeyexists(form,'method') and form.method NEQ "calendarTemplate">
<a href="#request.zos.currentHostName##application.zcore.app.getAppCFC("rental").getCalendarLink(ss.rental_id, ss.rental_name, ss.rental_url)#">Availability Calendar</a><br />
    </cfif>
    <cfif structkeyexists(form, 'method') EQ false or form.method NEQ "inquiryTemplate">
    <cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_reserve_online EQ 1>
<a href="#request.zos.currentHostName##application.zcore.app.getAppCFC("rental").getRentalLink(ss.rental_id, ss.rental_name, ss.rental_url)###zrental-calendar"><strong>Reserve Now</strong></a>
<cfelse>
<a href="#request.zos.currentHostName##application.zcore.app.getAppCFC("rental").getRentalInquiryLink()#?rental_id=#ss.rental_id#" rel="nofollow">Inquire Now</a>
    </cfif>
</cfif>
           </td>
              </tr>
              
              
<cfscript>
var arrAmen=arraynew(1);
if(ss.rental_pool EQ 1){
	arrayappend(arrAmen,'Pool');	
}
if(ss.rental_mountainview EQ 1){
	arrayappend(arrAmen,'Mountain View');	
}
if(ss.rental_waterview EQ 1){
	arrayappend(arrAmen,'Water View');	
}
if(ss.rental_gameroom EQ 1){
	arrayappend(arrAmen,'Game Room');	
}
if(ss.rental_cabletv EQ 1){
	arrayappend(arrAmen,'Satellite/Cable TV');	
}
if(ss.rental_highspeedinternet EQ 1){
	arrayappend(arrAmen,'High Speed Internet');	
}
if(ss.rental_fireplace EQ 1){
	arrayappend(arrAmen,'Fireplace');	
}
if(ss.rental_hottub EQ 1){
	arrayappend(arrAmen,'Hot Tub');	
}
if(ss.rental_petfriendly EQ 1){
	arrayappend(arrAmen,'Pet Friendly');	
}
if(ss.rental_oceanview EQ 1){
	arrayappend(arrAmen,'Ocean View');	
}
if(ss.rental_riverview EQ 1){
	arrayappend(arrAmen,'River View');	
}
</cfscript>
<tr><td colspan="3"  style="vertical-align:top;border-bottom:2px solid ##999999; padding-top:0px;"><cfif arraylen(arrAmen) NEQ 0>
<strong>Features:</strong><br />
#arraytolist(arrAmen,", ")#</cfif></td></tr></table> 
    </cffunction>
    
    
    <cffunction name="calendarTemplate" localmode="modern" access="remote" returntype="any">
    	
<cfscript>var inquiryTextMissing=0;
var selectStruct=0;
var qInquiries=0;
var r1=0;
var tempMeta=0;
var ts=0;
		var db=request.zos.queryObject;
application.zcore.app.getAppCFC("rental").onRentalPage(); 
	  if(structkeyexists(form, 'ifmdisable')){
		application.zcore.template.setPlainTemplate();
		if(isDefined('ifmshowCalendar') EQ false){
			request.hideCalendar=true;
		}
		calendarInclude=true;
	  }
	  tempMeta="";
	  form.rental_id=application.zcore.functions.zso(form, 'rental_id');
	  qRental={recordcount:0};
	</cfscript>
	<cfif application.zcore.functions.zso(form, 'rental_id') NEQ "">
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
		WHERE rental_id = #db.param(application.zcore.functions.zso(form, 'rental_id'))# and 
		rental_active = #db.param(1)# and 
		rental_deleted = #db.param(0)# and 
		rental_enable_calendar = #db.param('1')# and 
		rental.site_id = #db.param(request.zos.globals.id)#
		</cfsavecontent><cfscript>
		qRental=db.execute("qRental");
		calendarInclude=true;
		if(qRental.recordcount EQ 0){
			application.zcore.functions.z301Redirect('/');
		}
		application.zcore.functions.zQueryToStruct(qRental);
		calendarLink=application.zcore.app.getAppCFC("rental").getCalendarLink(rental_id,rental_name,rental_url); 
		if(structkeyexists(form, 'zurlname') EQ false or Compare(zURLName, application.zcore.functions.zURLEncode(rental_name&"-Availability-Calendar","-")) NEQ 0){
			application.zcore.functions.z301Redirect(calendarLink);
		}
		request.rental_id = rental_id;
		</cfscript> 
		<cfsavecontent variable="tempMeta">
	    <meta name="Keywords" content="#application.zcore.functions.zurlencode(qRental.rental_name," ")# Availability Calendar" /> 
	    <meta name="Description" content="#rental_name# Availability Calendar" />
	    </cfsavecontent>
	<cfelse>
		<cfset calendarInclude=true>
		<cfset ifmdisable=true>
	</cfif>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
	WHERE rental_active = #db.param(1)# and 
	rental_enable_calendar = #db.param('1')#  and 
	rental_deleted = #db.param(0)# and
	rental.site_id = #db.param(request.zos.globals.id)#
	ORDER BY rental_name ASC
	</cfsavecontent><cfscript>qProperties=db.execute("qProperties");</cfscript>
<cfif form.method EQ "calendarTemplate" and structkeyexists(form, 'ifmdisable') EQ false>
    <cfsavecontent variable="zpagenav">
    <a href="/">#application.zcore.functions.zvar('homelinktext')#</a> / 
    <a href="#application.zcore.app.getAppCFC("rental").getRentalHomeLink()#">#application.zcore.app.getAppData("rental").optionstruct.rental_config_home_page_title#</a> / 
<cfscript>
if(qRental.recordcount){
	arrCatId=listtoarray(rental_category_id_list,",",true);
	if(arraylen(arrCatId) GTE 2){
		 db.sql="SELECT * FROM #db.table("rental_category", request.zos.zcoreDatasource)# rental_category 
		WHERE rental_category_id=#db.param(arrCatId[2])# and 
		rental_category_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)# ";
		qCat=db.execute("qCat");
		if(qCat.recordcount NEQ 0){
			writeoutput('<a href="#application.zcore.app.getAppCFC("rental").getCategoryLink(qcat.rental_category_id,qcat.rental_category_name,qcat.rental_category_url)#">#qcat.rental_category_name#</a> /');
		}
	}
	echo('<a href="#application.zcore.app.getAppCFC("rental").getRentalLink(rental_id,rental_name,rental_url)#">#rental_name# Rental</a> / ');
    application.zcore.template.setTag("title",rental_name&" Availability Calendar");
    application.zcore.template.setTag("pagetitle",rental_name&" Availability Calendar");
}
</cfscript>
    
    </cfsavecontent> 
    <cfscript>
    application.zcore.template.setTag("meta",tempMeta);
    application.zcore.template.setTag("pagenav",zpagenav);
    </cfscript>
</cfif> 
		<cfscript>
		application.zcore.functions.zStatusHandler(request.zsid);
		</cfscript>

<script type="text/javascript">
/* <![CDATA[ */ 
arrProp = new Array();
<cfloop query="qProperties">
	<cfscript>
	link=application.zcore.app.getAppCFC("rental").getCalendarLink(qProperties.rental_id, qProperties.rental_name, qProperties.rental_url);
	</cfscript>
	arrProp[#qProperties.rental_id#] = '#link#';
</cfloop>
function getCalendar(val){
	var tempURL = arrProp[val];
	tempURL += '?first_date_year='+document.calSearch.first_date_year.options[document.calSearch.first_date_year.selectedIndex].text+'&first_date_month='+document.calSearch.first_date_month.options[document.calSearch.first_date_month.selectedIndex].value;
	window.location.href = tempURL;
} /* ]]> */
</script>

<cfif form.rental_id NEQ "">
		<cfsavecontent variable="db.sql">
			SELECT max(availability_date) as availability_date
			FROM #db.table("availability", request.zos.zcoreDatasource)# availability 
			WHERE availability.rental_id = #db.param(form.rental_id)#  and 
			availability_deleted = #db.param(0)# and
			site_id = #db.param(request.zos.globals.id)#
		</cfsavecontent><cfscript>qLast=db.execute("qLast");</cfscript>
		</cfif>
		<cfscript>
		initdate = CreateDate(year(now()),month(now()),1);
		form.search_start_date=application.zcore.functions.zso(form, 'search_start_date',false,DateAdd("d",2,now()));
		form.search_end_date = application.zcore.functions.zso(form, 'search_end_date',false,DateAdd('d', 7, form.search_start_date));	
		form.first_date = CreateDate(2005,5,1);
		if(structkeyexists(form, 'first_date_year') and structkeyexists(form, 'first_date_month')){
			if(isDate(form.first_date_year&'/'&form.first_date_month&'/01') and DateCompare(form.first_date, CreateDate(form.first_date_year, form.first_date_month,1)) EQ -1){
				form.first_date = CreateDate(form.first_date_year, form.first_date_month,1);
			}
		}else{
			form.first_date = initdate;
		}
		if(isDefined('qlast') and qLast.recordcount NEQ 0 and qLast.availability_date NEQ ''){
			tempDate = DateFormat(qLast.availability_date, 'yyyy-mm-dd');
			form.last_date = DateAdd('m',-1,DateAdd('yyyy', 1, CreateDate(year(tempDate),month(tempDate),10)));
		}else{
			form.last_date = DateAdd('m',-1,DateAdd('yyyy', 1, now()));
			form.last_date = CreateDate(year(form.last_date),month(form.last_date), daysInMOnth(form.last_date));
		}
		</cfscript>
		
		<cfset form.start_date = form.first_date>
<cfif isDefined('calendarInclude') EQ false>
		<cfset form.end_date = (DateAdd('yyyy', 1, form.start_date))>
		<cfelse>
		<cfset form.end_date = (DateAdd('m', 4, form.start_date))>		
		</cfif>
		<cfset form.end_date = (DateAdd('yyyy', 1, form.start_date))>
		
		<cfset form.inc_date = form.start_date>
		<cfset cmonth = dateformat(form.end_date,"mmmm")>
		<cfset cday = 'sunday'>
        <cfif isDefined('calendarcolumns')>
        	<cfset number_of_columns=calendarcolumns>
        <cfelse>
			<cfset number_of_columns = 4>
        </cfif>
		<cfset current_row = 1>
		<cfset availability_list = ''>
		<!--- set peak & holidays --->
		<!--- <cfsavecontent variable="db.sql">
			SELECT availability_date
			FROM #db.table("availability", request.zos.zcoreDatasource)# availability 
			WHERE availability.rental_id = #db.param('31')# and 
			availability_deleted = #db.param(0)# and 
			availability_date >= #db.param(DateFormat(CreateDate(year(start_date), month(start_date), 1), 'yyyy-mm-dd')&' 00:00:00')# and 
			availability_date <= #db.param(DateFormat(CreateDate(year(end_date), month(end_date), 1), 'yyyy-mm-dd')&' 00:00:00')#  and 
			site_id = #db.param(request.zos.globals.id)#
		</cfsavecontent><cfscript>qpeak=db.execute("qpeak");</cfscript>
		<cfset peakStruct = StructNew()>
		<cfloop query="qpeak">
			<cfscript>
			peakStruct[DateFormat(qpeak.availability_date, 'yyyy-mm-dd')] = true;
			</cfscript>
		</cfloop> --->
         
            <cfsavecontent variable="db.sql">
                SELECT cast(GROUP_CONCAT(availability_type_calendar_date ORDER BY availability_type_sort SEPARATOR #db.param(",")#) as char) cdate, 
				cast(GROUP_CONCAT(availability_type_color ORDER BY availability_type_sort SEPARATOR #db.param(",")#) as char) ccolor
                FROM #db.table("availability_type_calendar", request.zos.zcoreDatasource)# availability_type_calendar , 
				#db.table("availability_type", request.zos.zcoreDatasource)# availability_type
                WHERE 
                availability_type_deleted = #db.param(0)# and 
                availability_type_calendar_deleted = #db.param(0)# and
                availability_type_calendar.site_id = availability_type.site_id and 
                availability_type_calendar.availability_type_id = availability_type.availability_type_id and 
				availability_type_calendar_date >= #db.param(DateFormat(CreateDate(year(start_date), month(start_date), 1), 'yyyy-mm-dd')&' 00:00:00')# and 
				availability_type_calendar_date <= #db.param(DateFormat(CreateDate(year(end_date), month(end_date), 1), 'yyyy-mm-dd')&' 00:00:00')#  and 
				availability_type_calendar.site_id = #db.param(request.zos.globals.id)# 
                GROUP BY availability_type_calendar_date 
                ORDER BY availability_type_sort ASC
            </cfsavecontent><cfscript>qtypecalendar=db.execute("qtypecalendar");
            availabilityTypeStruct=structnew();
            </cfscript>
            <cfloop query="qtypecalendar">
                <cfscript>
				curDate=DateFormat(listgetat(qtypecalendar.cdate,1,","), 'yyyy-mm-dd');
				curColor=listgetat(qtypecalendar.ccolor,1,",");
				if(structkeyexists(availabilityTypeStruct, curDate) EQ false){
                	availabilityTypeStruct[curDate] = curColor;
				}
                </cfscript>
            </cfloop>
		<!--- get only current month and future dates --->
		<cfsavecontent variable="db.sql">
		SELECT availability_date
		FROM #db.table("availability", request.zos.zcoreDatasource)# availability 
		WHERE availability.rental_id = #db.param(application.zcore.functions.zso(form, 'rental_id'))# and 
		availability_deleted = #db.param(0)# and
		availability_date >= #db.param(DateFormat(CreateDate(year(start_date), month(start_date), 1), 'yyyy-mm-dd')&' 00:00:00')#  and 
		availability_date <= #db.param(DateFormat(CreateDate(year(end_date), month(end_date), 1), 'yyyy-mm-dd')&' 00:00:00')#  and 
		site_id = #db.param(request.zos.globals.id)#
		</cfsavecontent><cfscript>qAvailList=db.execute("qAvailList");</cfscript> 
		<cfset availStruct = StructNew()>
		<cfloop query="qAvailList">
			<cfscript>
			availStruct[DateFormat(qAvailList.availability_date, 'yyyy-mm-dd')] = "990000";
			</cfscript>
		</cfloop>
		

<script type="text/javascript">
/* <![CDATA[ */ function updateOffset22(val,type){
	setDateOffset2("calSearch","search_start_date","search_end_date", "day",2);
} /* ]]> */
</script>

<cfif form.rental_id NEQ "">
<cfscript>
ts=structnew();
ts.rental_id_list=form.rental_id;
this.includeRentalById(ts);
</cfscript>
</cfif>
<cfscript>

	//if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){ 
		writeoutput('<div style="display:inline;"  id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit zEditorHTML" data-editurl="/z/rental/admin/availability/select?rental_id=#form.rental_id#&amp;return=1">');
		application.zcore.template.prependTag('pagetitle','<span style="display:inline;"  id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/rental/admin/availability/select?rental_id=#form.rental_id#&amp;return=1">');
		application.zcore.template.appendTag('pagetitle','</span>');
	//}   
</cfscript>

<!--- <cfif isDefined('calendarcolumns') EQ false>
<form name="calSearch" id="calSearch" target="_top" action="<cfif isDefined('calendarInclude')>/calendar-results.cfm?action=search<cfelse>#getCalendarLink(qRental)#</cfif>" method="get" style="margin:0px; padding:0px;">
<table style="width:100%; border-spacing:<cfif isDefined('rental_id')>8<cfelse>0</cfif>px;" class="zrental-availabilitysearch">
<tr>
<cfif isDefined('calendarInclude') EQ false>
<td><strong>Select a rental to view its availability.</strong></td>
<td style="text-align:right;"><strong>Search Dates</strong></td>
</tr>
<tr  ><td>
 
<cfscript>
selectStruct = StructNew();
selectStruct.name = "rental_id";
selectStruct.hideSelect=true;
selectStruct.query = qProperties;
selectStruct.onChange = 'getCalendar(this.value);';
selectStruct.queryLabelField = "rental_name";
selectStruct.queryValueField = "rental_id";
application.zcore.functions.zInputSelectBox(selectStruct);
</cfscript>

</td>
</cfif>
<td <!--- style="border:1px solid ##000000; background-color:##FFFFFF; " --->>
<cfscript>
ly=max(year(initdate),year(last_date))+1;
</cfscript>
<cfif isDefined('calendarInclude') EQ false>
#application.zcore.functions.zDateSelect("first_date", "first_date", year(initdate), ly,'document.calSearch.submit();',false,false,true)#
<cfelse>
<cfif isDefined('rental_id') and rental_id NEQ ''>
<input type="hidden" name="rental_id" value="#rental_id#" />
<strong>Check-in: #application.zcore.functions.zDateSelect("search_start_date", "search_start_date", year(initdate), ly,"updateOffset22")# 
Check-out: #application.zcore.functions.zDateSelect("search_end_date", "search_end_date", year(initdate), ly)#</strong>
<input type="submit" name="searchButton" value="Search Availability" style="text-align:center;" />
</td></tr>
<cfelse>
<table style="border-spacing:5px;">
<tr><td><strong>Select Rental:</strong></td>
<td><cfscript>
if(isDefined('request.forcerental_id')){
	rental_id=request.forcerental_id;
}
selectStruct = StructNew();
selectStruct.name = "rental_id";
selectStruct.query = qProperties;
selectStruct.queryLabelField = "rental_name";
selectStruct.queryValueField = "rental_id";
application.zcore.functions.zInputSelectBox(selectStruct);
</cfscript> (optional)</td>
</tr>
<tr><td><strong>Start Date:</strong></td>
<td>#application.zcore.functions.zDateSelect("search_start_date", "search_start_date", year(initdate), ly,"updateOffset22")#</td>
</tr>
<tr><td><strong>End Date:</strong></td>
<td>#application.zcore.functions.zDateSelect("search_end_date", "search_end_date", year(initdate), ly)#</td>
</tr>
<tr><td>&nbsp;</td>
<td><input type="submit" name="searchButton" value="Availability Search" style="text-align:center;" /></td>
</tr>
</table>
</cfif>
</cfif>
</form>

</cfif>  --->

<table style="width:100%; border-spacing:<cfif isDefined('rental_id')>8<cfelse>0</cfif>px;" class="zrental-availabilitysearch">
<cfif isDefined('request.hideCalendar') EQ false>
<tr>
<td colspan="2" class="zrental-cal-unavailable" style="text-align:left; ">Red Dates are unavailable.  <!--- <cfif qRental.recordcount>All rates are for first #rental_addl_guest_count# guests.</cfif> ---><br />
Rates are color coded so you can see what dates they fall on the calendar.<!--- <cfif rental_discount EQ 1><br />

<img src="/images/10-percent-off.gif" style="padding-top:5px;" /></cfif> ---></td>
</tr>
<tr><td colspan="2" style="padding:0px;">
<cfif qRental.recordcount>
<cfif rental_rate NEQ 0><div class="zrental-ratetypediv"><div class="zrental-ratetypecolordiv" style="background-color:##FFFFFF;"></div> Standard Rate: #DollarFormat(rental_rate)# per night</div></cfif>
<!--- 
<cfsavecontent variable="db.sql">
SELECT * FROM #db.table("availability_type", request.zos.zcoreDatasource)# availability_type 
WHERE site_id = #db.param(request.zos.globals.id)# and 
availability_type_deleted = #db.param(0)# 
ORDER BY availability_type_name ASC
</cfsavecontent><cfscript>qtype=db.execute("qtype");</cfscript>
<cfloop query="qtype">
<div class="zrental-ratetypediv"><div class="zrental-ratetypecolordiv" style="background-color:###qtype.availability_type_color#;"></div> #qtype.availability_type_name# Rate: #DollarFormat(qtype.rental_rate_holiday)# per night</div>
</cfloop> --->
</cfif></td></tr>
</table>
	<!--- LOOPING THROUGH THE MONTHS; TERMINATES WHEN END OF CALENDAR DATE IS REACHED --->
	<table style="margin-left:auto; margin-right:auto; border-spacing:5px;" class="zrental-cal-outer">
	<tr>
	<td style="vertical-align:top; ">
	<cfloop condition="#dateformat(form.inc_date,"yyyymm")# NEQ #dateformat(form.end_date,"yyyymm")#">
	<cfset current_row = current_row + 1>
    <div class="zrental-calendardiv">
	<table class="zrental-calendar">			
			<tr>
			<td colspan="7" style="text-align:center">
			<b>#dateformat(inc_date,"mmmm yyyy")#</b>
			</td>
			</tr>
			<tr class="zrental-cal-days">
			<td style="text-align:center;">
			Sun
			</td>
			<td style="text-align:center;">
			Mon
			</td>
			<td style="text-align:center;">
			Tue
			</td>
			<td style="text-align:center;">
			Wed
			</td>
			<td style="text-align:center;">
			Thu
			</td>
			<td style="text-align:center;">
			Fri
			</td>
			<td style="text-align:center;">
			Sat
			</td>
			</tr>	
			<tr>
<cfset cday = 'sunday'>
			<cfset layout_counter = 0>
			<cfset cmonth = dateformat(form.inc_date,"mmmm")>
			
	<!--- LOOPING THROUGH DATES --->
	
			<cfloop condition="#dateformat(form.inc_Date,"mmmm")# EQ cmonth">			
				<cfloop condition="#dateformat(form.inc_Date,"d")# EQ 1">					
					<cfif dateformat(form.inc_Date,"dddd") EQ cday>					
						<cfbreak>					
					<cfelse>		
						<cfif cday EQ 'sunday'>
							<cfset cday = 'monday'>
						<cfelseif cday EQ 'monday'>
							<cfset cday = 'tuesday'>
						<cfelseif cday EQ 'tuesday'>
							<cfset cday = 'wednesday'>
						<cfelseif cday EQ 'wednesday'>
							<cfset cday = 'thursday'>
						<cfelseif cday EQ 'thursday'>
							<cfset cday = 'friday'>
						<cfelseif cday EQ 'friday'>
							<cfset cday = 'saturday'>
						<cfelseif cday EQ 'saturday'>		
							<cfset cday = 'sunday'>
						</cfif>						
						<td class="zrental-calendaremptyday">&nbsp;</td>
						<cfset layout_counter = layout_counter + 1>
					
					</cfif>
				</cfloop>
			
	
				<cfif layout_counter EQ 7>
				#'</tr>
                <tr>'#
		       
					<cfset layout_counter = 0>
				</cfif>
				
				<cfset layout_counter = layout_counter + 1>
	
				<cfif dateformat(form.inc_Date,"dddd") EQ cday>		
					<cfscript>
					tempIncDate=dateformat(form.inc_Date,"yyyy-mm-dd");
					if(structkeyexists(availStruct, tempIncDate)){
						tempcolor = availStruct[tempIncDate];
						selected=true;
					}else{
						status = true;
						selected=false;
					}
					m=month(form.inc_Date);
					if(structkeyexists(availabilityTypeStruct, tempIncDate)){
						tempcolor  = availabilityTypeStruct[tempIncDate];
						specialTypeRate=true;
					}else{
						specialTypeRate=false;
					}
					if(selected){
						style='class="zrental-cal-unavailable" style="';
					}else if(specialTypeRate){
						style='class="zrental-cal-available" style="background-color:###tempcolor# !important;';
					}else{
						style='class="zrental-cal-available" style="';
					}
					writeoutput('<td  #style# width:20px; vertical-align:top; text-align:center;" >#dateformat(form.inc_Date,"d")#</td>');
					</cfscript> 
				</cfif>
	
				<cfif cday EQ 'sunday'>
					<cfset cday = 'monday'>
				<cfelseif cday EQ 'monday'>
					<cfset cday = 'tuesday'>
				<cfelseif cday EQ 'tuesday'>
					<cfset cday = 'wednesday'>
				<cfelseif cday EQ 'wednesday'>
					<cfset cday = 'thursday'>
				<cfelseif cday EQ 'thursday'>
					<cfset cday = 'friday'>
				<cfelseif cday EQ 'friday'>
					<cfset cday = 'saturday'>
				<cfelseif cday EQ 'saturday'>		
					<cfset cday = 'sunday'>
				</cfif>
	
				<cfset form.inc_Date = DateAdd('d', 1, form.inc_Date)>
	
			</cfloop>
			<cfloop from="#layout_counter#" to="6" index="i">
				<td class="zrental-calendaremptyday">&nbsp;</td>
</tr></cfloop>
		 
			</table>
            </div>
	</cfloop>
	</cfif>
    </td>
    </tr>
	</table> 
   <cfscript>
	//if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){ 
		writeoutput('</div>');
	//}
	</cfscript>
    </cffunction>
        
    <cffunction name="inquiryTemplate" localmode="modern" access="remote" returntype="any">
    	
<cfscript>var inquiryTextMissing=0;
var selectStruct=0;
var qInquiries=0;
var r1=0;
var tempMeta=0;
var ts=0;
var myForm={};
var inputStruct=0;
var propertyHTML="";
var qrental=0;
		var db=request.zos.queryObject;
application.zcore.app.getAppCFC("rental").onRentalPage();
</cfscript>
<cfif isDefined('request.zHideInquiryForm') EQ false>
<cfscript> 

application.zcore.functions.zRequireJquery();
application.zcore.functions.zRequireJqueryUI();
request.zHideInquiryForm=true;
form.action=application.zcore.functions.zso(form, 'action',false,'form'); 
if(application.zcore.functions.zso(form, 'rental_id',true) NEQ 0){
	 db.sql="SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)#  
	WHERE rental_id=#db.param(form.rental_id)# and 
	rental_deleted=#db.param(0)#  and 
	site_id = #db.param(request.zos.globals.id)# and 
	rental_active=#db.param('1')#";
	qrental=db.execute("qrental");
	if(qrental.recordcount EQ 0){
		application.zcore.functions.z301redirect('/');	
	}
/*}else{
	application.zcore.functions.z301redirect('/');*/
}
	
	propertyHTML="";
	application.zcore.functions.zStatusHandler(request.zsid,true,true);
	</cfscript> 
	<cfif form.action EQ "send"> 
	<cfscript>
	var rs=0;
	var qinquiry=0;
	var arrAmen=0;
	var qD=0;
	var result=0;
	form.inquiries_spam=0;
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		form.inquiries_spam=1;
		form.inquiries_spam_description="Fake form fields not empty"; 
		//application.zcore.functions.zRedirect("/z/misc/thank-you/index");
	}
	/*if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
		form.inquiries_spam=1; 
		form.inquiries_spam_description="zset9 was wrong";
		//application.zcore.functions.zredirect('/');
	}*/
	// form validation struct
	if(structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1){
		myForm.inquiries_email.required = true;
		myForm.inquiries_email.friendlyName = "Email Address";
		myForm.inquiries_email.email = true;
	}
	myForm.inquiries_first_name.required = true;
	myForm.inquiries_first_name.friendlyName = "First Name";
	if(application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1){
		myForm.inquiries_phone1.required = true;
		myForm.inquiries_phone1.friendlyName = "Phone";
	}
	
	myForm.inquiries_datetime.createDateTime = true;
	form.inquiries_type_id = 11; // rentals
	form.inquiries_type_id_siteIdType=4;
	form.inquiries_status_id = 1;
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result eq true){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		application.zcore.functions.zRedirect("#application.zcore.app.getAppCFC("rental").getRentalInquiryLink()#?zsid=#Request.zsid#&action=form&rental_id=#application.zcore.functions.zso(form, 'rental_id')#");
	}
	if(Find("@", form.inquiries_first_name) NEQ 0){
		application.zcore.status.setStatus(Request.zsid, "Invalid Request",form,true);
		application.zcore.functions.zRedirect("#application.zcore.app.getAppCFC("rental").getRentalInquiryLink()#?zsid=#Request.zsid#&action=form&rental_id=#application.zcore.functions.zso(form, 'rental_id')#");
	}
	
	if(application.zcore.functions.zso(form, 'inquiries_start_date') NEQ "" and isdate(form.inquiries_start_date)){
		form.inquiries_start_date=dateformat(form.inquiries_start_date,"yyyy-mm-dd");
	}
	if(application.zcore.functions.zso(form, 'inquiries_end_date') NEQ "" and isdate(form.inquiries_end_date)){
		form.inquiries_end_date=dateformat(form.inquiries_end_date,"yyyy-mm-dd");
	}
	form.inquiries_referer2=request.zos.cgi.http_referer;
	form.user_id=0;
	//	Insert Into Inquiry Database
	form.site_id = request.zOS.globals.id;
	form.property_id="";
	form.content_id="";
	form.inquiries_datetime = dateformat(now(), 'yyyy-mm-dd') &" "&timeformat(now(), 'HH:mm:ss'); 
	form.inquiries_session_id=application.zcore.session.getSessionId(); 
	form.inquiries_id=application.zcore.functions.zInsertLead();
	if(form.inquiries_id EQ false){
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Your inquiry has not been sent due to an error.", false,true);
		application.zcore.functions.zRedirect("#application.zcore.app.getAppCFC("rental").getRentalInquiryLink()#?rental_id=#form.rental_id#&zsid="&request.zsid);
	}else{
		//request.zsid = application.zcore.status.setStatus(Request.zsid, "Your inquiry has been sent.");
		// success
	}
	db.sql="SELECT * FROM (#db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
	#db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status) 
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
	inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	inquiries_type.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#) and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	inquiries_type_deleted = #db.param(0)#
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries.user_id  and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	user_deleted = #db.param(0)#
	WHERE inquiries.site_id = #db.param(request.zos.globals.id)#  and 	
	inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
	inquiries_deleted = #db.param(0)# and 
	inquiries_status_deleted=#db.param(0)# and 
	inquiries_id = #db.param(form.inquiries_id)# ";
	qinquiry=db.execute("qinquiry");
	application.zcore.functions.zQueryToStruct(qinquiry);

	application.zcore.tracking.setUserEmail(form.inquiries_email);
	application.zcore.tracking.setConversion('property inquiry', form.inquiries_id);
	
	
	if(application.zcore.functions.zso(form, 'inquiries_email') EQ "" or application.zcore.functions.zEmailValidate(form.inquiries_email) EQ false){
		form.inquiries_email=request.fromemail;
	}
	form.contact_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew()));
	//if(form.inquiries_spam EQ 0){
		ts=structnew();
		if(isQuery(qrental) and qrental.rental_category_id_list NEQ "" and qrental.rental_category_id_list NEQ ",,"){
			 db.sql="select rental_category_email 
			 from #db.table("rental_category", request.zos.zcoreDatasource)# rental_category 
			WHERE rental_category_id IN (#db.trustedSQL("'#arraytolist(listtoarray(qrental.rental_category_id_list,",",false),"','")#'")#) and 
			rental_category_email <> #db.param('')# and 
			rental_category_deleted = #db.param(0)# and
			site_id = #db.param(request.zos.globals.id)#";
			qD=db.execute("qD");
			if(qD.recordcount NEQ 0){
				ts.forceAssign=true;
				ts.assignEmail=qD.rental_category_email;
				ts.leadEmail=form.inquiries_email;
			}
		}
		ts.inquiries_id=form.inquiries_id;
		ts.subject="New Rental Inquiry on #request.zos.globals.shortdomain#";
		// send the lead
		rs=application.zcore.functions.zAssignAndEmailLead(ts);
		if(rs.success EQ false){
			// failed to assign/email lead
			//zdump(rs);
		}
	//}
	
	//if(form.inquiries_spam EQ 0){
		if(application.zcore.functions.zso(application.zcore.app.getAppData("rental").optionstruct, 'rental_config_lodgix_email_to') NEQ ""){
			this.lodgixInquiryTemplate();
		}
	//}
	
	application.zcore.functions.zRedirect("/z/misc/thank-you/index?zsid="&request.zsid);
	</cfscript>
		
</cfif>
		
		
		
<cfif form.action EQ "form" or form.method NEQ "inquiryTemplate">
<cfscript>
if(form.method EQ "inquiryTemplate"){
	application.zcore.template.prependTag('meta','<meta name="robots" content="noindex,follow" />');
}
</cfscript>
<a id="cjumpform"></a>
<cfif application.zcore.app.siteHasApp("content")>
    	<cfscript>
		inquiryTextMissing=false;
		ts=structnew();
		ts.content_unique_name=application.zcore.app.getAppCFC("rental").getRentalInquiryLink();
		ts.disableContentMeta=false;
		ts.disableLinks=true;
		if(form.method EQ "inquiryTemplate"){
			r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		}else{
			r1=application.zcore.app.getAppCFC("content").includeContentByName(ts);
		}
		if(r1 EQ false){
			inquiryTextMissing=true;
		}
		</cfscript>
<cfelse><cfset inquiryTextMissing=true>
</cfif>
<cfif inquiryTextMissing>

		<cfscript>
		if(form.method EQ "inquiryTemplate"){
			application.zcore.template.setTag("title","Rental Inquiry");
			application.zcore.template.setTag("pagetitle","Rental Inquiry");
		}else{
			writeoutput('<h2>Rental Inquiry</h2>');
		}
        </cfscript>
     <cfif form.method EQ "rentalTemplate">
     <p>Submit the form below to inquire about the above rental property.</p>
     <cfelse>
<p>
You are inquiring about <Cfif structkeyexists(form, 'rental_id')> rental ###form.rental_id#<cfelse>rentals</Cfif>.  To send a general inquiry instead, <a href="/z/misc/inquiry/index">click here</a></p>
</cfif>

</cfif> 
<Cfif application.zcore.functions.zso(form, 'rental_id',true) NEQ 0>
<cfscript>
ts=structnew();
ts.rental_id_list=form.rental_id;
this.includeRentalById(ts);
</cfscript>
</Cfif>
            
<br style="clear:both;" />
<table style="border-spacing:0px;" class="zinquiry-form-table">
<tr><td style="vertical-align:top; ">
	<cfsavecontent variable="db.sql">
		SELECT *
		from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
		WHERE inquiries_id = #db.param(-1)# and 
		inquiries_deleted=#db.param(0)# and
		site_id = #db.param(request.zos.globals.id)#
	</cfsavecontent><cfscript>qInquiries=db.execute("qInquiries");</cfscript>

	<cfif isdefined('error_message') EQ false>
		<cfscript>
		application.zcore.functions.zQueryToStruct(qInquiries,form,'rental_id');
		application.zcore.functions.zStatusHandler(request.zsid, true);
		</cfscript>
	</cfif>
    <cfscript>
	form.set9=application.zcore.functions.zGetHumanFieldIndex();
	</cfscript>
	<form class="zFormCheckDirty" id="myForm" action="#application.zcore.app.getAppCFC("rental").getRentalInquiryLink()#?action=send" onsubmit="zSet9('zset9_#form.set9#');" method="post">
    <input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
       #application.zcore.functions.zFakeFormFields()#
<cfsavecontent variable="tempMeta">
<script type="text/javascript">
/* <![CDATA[ */ 	zArrDeferredFunctions.push(function(){
		var dates = $( "##inquiries_start_date, ##inquiries_end_date" ).datepicker({
			minDate: 0, 
			maxDate: "+2Y",
			changeMonth: true,
			changeYear: true,
			onSelect: function( selectedDate ) {
				var option = this.id == "inquiries_start_date" ? "minDate" : "maxDate",
					instance = $( this ).data( "datepicker" );
					date = $.datepicker.parseDate(
						instance.settings.dateFormat ||
						$.datepicker._defaults.dateFormat,
						selectedDate, instance.settings );
				dates.not( this ).datepicker( "option", option, date );
			}
		});
	}); /* ]]> */
	</script>  

</cfsavecontent>
<cfscript>
application.zcore.template.appendTag("meta",tempMeta);
</cfscript>
	<input type="hidden" name="inquiries_referer" value="#HTMLEditFormat(request.zos.cgi.http_referer)#" />

	<table style="border-spacing:5px; width:100%;">
	<tr>
		<td>First Name:</td>
		<td><input name="inquiries_first_name" type="text" size="30" maxlength="50" value="<cfif form.inquiries_first_name EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_first_name')#<cfelse>#form.inquiries_first_name#</cfif>" /><span class="highlight"> * Required</span></td>
	</tr>
	<tr>
		<td>Last Name:</td>
		<td><input name="inquiries_last_name" type="text" size="30" maxlength="50" value="<cfif form.inquiries_last_name EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_last_name')#<cfelse>#form.inquiries_last_name#</cfif>" /><span class="highlight"> * Required</span></td>
	</tr>
	<tr>
		<td>Email:</td>
		<td><input name="inquiries_email" type="text" size="30" maxlength="50" value="<cfif form.inquiries_email EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_email')#<cfelse>#form.inquiries_email#</cfif>" /> <cfif structkeyexists(application.zcore.app.getAppData("content").optionStruct,'content_config_email_required') EQ false or application.zcore.app.getAppData("content").optionStruct.content_config_email_required EQ 1><span class="highlight"> * Required</span> </cfif></td>
	</tr>
	<tr>
		<td>Phone:</td>
		<td><input name="inquiries_phone1" type="text" size="30" maxlength="50" value="<cfif form.inquiries_phone1 EQ '' and not application.zcore.user.checkGroupAccess("administrator")>#application.zcore.functions.zso(request.zsession, 'inquiries_phone1')#<cfelse>#form.inquiries_phone1#</cfif>" /><cfif application.zcore.app.getAppData("content").optionStruct.content_config_phone_required EQ 1><span class="highlight"> * Required</span></cfif></td>
	</tr>
	<tr>
		<td>Check-In Date:</td>
		<td><input name="inquiries_start_date" id="inquiries_start_date" type="text" size="30" maxlength="50" value="#form.inquiries_start_date#" /></td>
	</tr>
	<tr>
		<td>Check-Out Date:</td>
		<td><input name="inquiries_end_date" id="inquiries_end_date" type="text" size="30" maxlength="50" value="#form.inquiries_end_date #" /></td>
	</tr>
      <tr>
        <td>Adults:</td>
        <td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_adults";
		selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript></td>
      </tr>
      <tr>
        <td>Children<br />(3 to 15):</td>
        <td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_children";
			selectStruct.listValues = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript></td>
      </tr>
      <tr id="zrentalformchildrenunderthree">
        <td>Children<br />(under age 3):</td>
        <td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_children_age";
			selectStruct.listValues = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript> (There is no charge for children under age 3)</td>
      </tr>
	<tr>
		<td style="vertical-align:top; ">Comments:</td>
		<td><textarea name="inquiries_comments" cols="50" rows="5"><cfif structkeyexists(form, 'inquiries_comments')>#form.inquiries_comments#<cfelse>#inquiries_comments#</cfif></textarea></td>
	</tr>	  
	<tr>
	  <td>&nbsp;</td>
		<td><button type="submit" name="submit">Send Inquiry</button>&nbsp;&nbsp;<a href="#request.zos.currentHostName#/z/user/privacy/index" target="_blank" class="zPrivacyPolicyLink">Privacy Policy</a>
		<input type="hidden" name="rental_id" value="#application.zcore.functions.zso(form, 'rental_id')#" /></td>
	</tr>
	<tr><td colspan="2">By submitting this form, you agree to receive future mailings from us.</td></tr>
	
	</table>
	</form>
</td>
</tr>
</table>
	
</cfif>
</cfif>
    </cffunction>
    
    
<cffunction name="photoTemplate" localmode="modern" access="remote" returntype="any">
	<cfscript>
	var db=request.zos.queryObject;
	application.zcore.app.getAppCFC("rental").onRentalPage();
	if(structkeyexists(form, 'rental_id') EQ false){
		application.zcore.functions.z404("form.rental_id was undefined");	
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
	WHERE rental_id = #db.param(form.rental_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	rental_deleted=#db.param(0)# 
	</cfsavecontent><cfscript>qRental=db.execute("qrental");
	application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);
	if(qRental.recordcount EQ 0 or (qRental.rental_active EQ 0)){
		application.zcore.functions.zRedirect(application.zcore.app.getAppCFC("rental").getRentalHomeLink());
	}


	ts=structnew();
	ts.output=false;
	ts.image_library_id=qRental.rental_image_library_id;
	ts.image_id=form.image_id;
	ts.size=application.zcore.app.getAppCFC("rental").getImageSize("rental-page-main");
	ts.crop=0;
	arrImages=application.zcore.imageLibraryCom.displayImages(ts);
	if(arraylen(arrImages) NEQ 0){
		title=arrImages[1].caption&" | "&qRental.rental_name&" Photo "&arrImages[1].id;
		if(compare(zURLName, application.zcore.functions.zURLEncode(title,"-")) NEQ 0){
			link=application.zcore.app.getAppCFC("rental").getPhotoLink(qRental.rental_id, title, qRental.rental_url, arrImages[1].id);
			application.zcore.functions.z301Redirect(link);
		}
		
		tempMeta='
		<meta name="keywords" content="#htmleditformat(application.zcore.functions.zurlencode(title," "))#" />
		<meta name="description" content="#htmleditformat(title)#" />
		';
		application.zcore.template.setTag('meta',tempMeta);
		application.zcore.template.setTag("title","Photo ##"&form.image_id&" for "&title);
		application.zcore.imageLibraryCom.registerSize(qRental.rental_image_library_id, application.zcore.app.getAppCFC("rental").getImageSize("rental-page-main"), 0);
		link=application.zcore.imageLibraryCom.getImageLink(qRental.rental_image_library_id, arrImages[1].id, application.zcore.app.getAppCFC("rental").getImageSize("rental-page-main"), 0, true, arrImages[1].caption, arrImages[1].file, arrImages[1].updatedDatetime);
		// temporarily disabled the popup images.
		writeoutput('<div style="padding:5px; height:299px; text-align:center; width:#application.zcore.app.getAppCFC("rental").getImageSize("rental-page-main")#px;"><img src="#link#" alt="#htmleditformat(arrImages[1].caption)#" style="border:none; text-align:center; " /></div>
		<div style="padding:5px; text-align:center;">#arrImages[1].caption#</div>');
	}
		
	</cfscript>
</cffunction>
    
    <cffunction name="compareRentalAmenitiesTemplate" localmode="modern" access="remote" returntype="any">
    	
<cfscript>
		var db=request.zos.queryObject;
application.zcore.app.getAppCFC("rental").onRentalPage(); 

// you must have a group by in your query or it may miss rows
ts=structnew();
ts.image_library_id_field="rental.rental_image_library_id";
ts.count =  2; // how many images to get
rs=application.zcore.imageLibraryCom.getImageSQL(ts);
</cfscript>
<cfsavecontent variable="db.sql">
SELECT * #db.trustedSQL(rs.select)# 
FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
#db.trustedSQL(rs.leftJoin)# 
WHERE rental_active = #db.param(1)# and 
rental_deleted = #db.param(0)# and 
rental.site_id = #db.param(request.zos.globals.id)# 
<cfif form.method EQ "categoryListTemplate"> and rental_home_featured=#db.param('1')# </cfif>   
GROUP BY rental.rental_id 
ORDER BY <cfif form.method EQ "categoryListTemplate">rental_sort ASC, </cfif> rental_beds ASC, rental_bath ASC, rental_rate ASC
</cfsavecontent><cfscript>qProp=db.execute("qProp");</cfscript>

<cfsavecontent variable="temppagenav">
<a href="/">#application.zcore.functions.zvar('homelinktext')#</a> / 
<a href="#application.zcore.app.getAppCFC("rental").getRentalHomeLink()#">#application.zcore.app.getAppData("rental").optionstruct.rental_config_home_page_title#</a> / 
</cfsavecontent> 
<cfscript>
ts=structnew();
ts.content_unique_name="/Compare-Rental-Amenities-#application.zcore.app.getAppData("rental").optionstruct.rental_config_misc_url_id#-2.html";
application.zcore.template.setTag('title',"Rental Rate Information");
application.zcore.template.setTag('pagetitle',"Rental Rate Information"); 
r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts); 
application.zcore.template.setTag('pagenav',temppagenav);  
</cfscript> 
<cfif isDefined('compact')>
     <!---      <!--- <a href="/Compare-Rental-Amenities-#application.zcore.app.getAppData("rental").optionstruct.rental_config_misc_url_id#-2.html">Back to full view</a><br /><br /> --->
        <table class="zrental-tbspace2" style="width:100%;">
          <tr>
            <th style="width:30%;">Rental</th>
            <th>
Sleeps</th>
            <th>Starting<br />
Rate</th>
            <th>Mountain View</th>
            <th>Water View</th>
            <th>Game Room</th>
            <th  style="white-space:nowrap;">Satellite<br />
/Cable TV</th>
            <th>Fast Internet</th>
            <th>Fireplace</th>
            <th>Hot Tub</th>
            <th>&nbsp;</th>
          </tr>
          
<cfscript>
form.startDate=dateadd("d",3,now());
form.endDate=dateadd("d",3,form.startDate);
form.inquiries_adults=2;
form.inquiries_children=0;
form.inquiries_coupon="";
</cfscript>
          <cfloop query="qProp">
              <tr <cfif currentrow MOD 2 EQ 0>class="zrental-alternaterowcolor"<cfelse>class="zrental-rowcolor"</cfif>>
                <td><a href="#rental_url#">#qProp.rental_name#</a></td>
                <td><cfif rental_max_guest NEQ 0>2-#qProp.rental_max_guest#<cfelse>&nbsp;</cfif></td>
                <td>
                
<cfscript>
ts=StructNew();
ts.rental_id=rental_id;
ts.startDate=form.startDate;
ts.endDate=form.endDate;
ts.adults=inquiries_adults;
ts.children=inquiries_children;
ts.couponCode=inquiries_coupon;
rs=application.zcore.app.getAppCFC("rental").rateCalc(ts);
//zdump(rs);
//zabort();
mrate=rs.arrNights[1].rate;
for(i=2;i LTE arraylen(rs.arrNights);i++){
	mrate=min(mrate,rs.arrNights[i].rate);
}
preg=rental_display_regular;
if(rental_display_regular EQ 0){
	preg=rental_rate;
}
</cfscript>#dollarformat(mrate)#</td>
              
            <td><cfif rental_mountainview EQ 1>Yes<cfelse>&nbsp;</cfif></td>
            <td><cfif rental_waterview EQ 1>Yes<cfelse>&nbsp;</cfif></td>
            <td><cfif rental_gameroom EQ 1>Yes<cfelse>&nbsp;</cfif></td>
            <td><cfif rental_cabletv EQ 1>Yes<cfelse>&nbsp;</cfif></td>
            <td><cfif rental_highspeedinternet EQ 1>Yes<cfelse>&nbsp;</cfif></td>
            <td><cfif rental_fireplace EQ 1>Yes<cfelse>&nbsp;</cfif></td>
            <td><cfif rental_hottub EQ 1>Yes<cfelse>&nbsp;</cfif></td>
                <td style="white-space:nowrap;"><a href="#rental_url#">View</a> | <a href="javascript:reserve(#rental_id#);">Reserve</a><!--- <br />
<a href="/#application.zcore.functions.zURLEncode(rental_name,'-')#-Availability-Calendar-1-#rental_id#.html">Availability Calendar</a><br /> ---></td>
            </tr>
          </cfloop>
        </table> --->
	<cfelse>
	<!--- <cfif request.cgi_script_name NEQ '/index.cfm'>
	<a href="/Compare-Rental-Amenities-#application.zcore.app.getAppData("rental").optionstruct.rental_config_misc_url_id#-3.html">Switch to compact view</a> <br /><br />
	</cfif> 
	 --->


    
          
		<cfscript>
		this.includeRentalListHeader();
		form.startDate=dateadd("d",3,now());
		form.endDate=dateadd("d",3,form.startDate);
		inquiries_adults=2;
		inquiries_children=0;
		inquiries_coupon="";
		for(row in qProp){
			rentalIncludeTemplate(row);
		}
		</cfscript> 
    </cfif>    
    </cffunction>
    
    <cffunction name="includeRentalSearchForm" localmode="modern" output="yes" returntype="any">
        <cfscript>
		this.searchTemplate();
		</cfscript>
    </cffunction>
    
    <!--- 
	ts=structnew();
	ts.rental_id_list="";
	configCom.includeRentalById(ts);
	 --->
    <cffunction name="includeRentalById" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
        <cfscript>
		var qProp=0;
		var db=request.zos.queryObject;
		var ts=structnew();
		
		var rs=0;
		ts.email=false;
		structappend(arguments.ss,ts,false);
		if(arguments.ss.email EQ false){
			this.includeRentalListHeader();
		}
		form.site_id=request.zos.globals.id;
		ts=structnew();
		ts.image_library_id_field="rental.rental_image_library_id";
		ts.count =  2; // how many images to get
		rs=application.zcore.imageLibraryCom.getImageSQL(ts);
		arguments.ss.rental_id_list="'"&replace(replace(arguments.ss.rental_id_list,"'","","ALL"),",","','","ALL")&"'";
		form.startDate=dateadd("d",3,now());
		form.endDate=dateadd("d",3,form.startDate);
		form.inquiries_adults=2;
		form.inquiries_children=0;
		form.inquiries_coupon="";
		</cfscript>
        <cfsavecontent variable="db.sql">
		SELECT * #db.trustedSQL(rs.select)# 
		FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
		#db.trustedSQL(rs.leftJoin)# 
		WHERE rental_active = #db.param(1)# and 
		rental_deleted = #db.param(0)# and 
		rental.site_id = #db.param(form.site_id)# and 
		rental_id IN (#db.trustedSQL(arguments.ss.rental_id_list)#)  
		GROUP BY rental.rental_id 
		ORDER BY <cfif request.cgi_script_name EQ '/index.cfm'>rental_sort ASC, </cfif> rental_beds ASC, rental_bath ASC, rental_rate ASC
		</cfsavecontent><cfscript>qProp=db.execute("qProp"); 
        request.zos.tempObj.currentRentalQuery=qProp;
        for(row in qProp){
        	if(arguments.ss.email){
        		rentalEmailIncludeTemplate(row);
        	}else{
        		rentalIncludeTemplate(row);
        	}
        }
        </cfscript> 
    </cffunction>
        
    <!--- 
	ts=structnew();
	ts.rental_category_id="";
	configCom.includeRentalByCategoryId(ts);
	 --->
    <cffunction name="includeRentalByCategoryId" localmode="modern" output="yes" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
        <cfscript>
		var qProp=0;
		var db=request.zos.queryObject;
		var ts=0;
		
		var rs=0;
		var rentalFrontCom=0;
		this.includeRentalListHeader();
		form.site_id=request.zos.globals.id;
		ts=structnew();
		ts.image_library_id_field="rental.rental_image_library_id";
		ts.count =  2; // how many images to get
		rs=application.zcore.imageLibraryCom.getImageSQL(ts);
		form.startDate=dateadd("d",3,now());
		form.endDate=dateadd("d",3,form.startDate);
		form.inquiries_adults=2;
		form.inquiries_children=0;
		form.inquiries_coupon="";
		</cfscript>
        <cfsavecontent variable="db.sql">
        SELECT * #db.trustedSQL(rs.select)# 
		FROM (#db.table("rental", request.zos.zcoreDatasource)# rental, 
		#db.table("rental_x_category", request.zos.zcoreDatasource)# rental_x_category) 
		#db.trustedSQL(rs.leftJoin)# 
		WHERE rental.site_id = rental_x_category.site_id and 
		rental_deleted = #db.param(0)# and 
		rental_x_category_deleted = #db.param(0)# and 
		rental.rental_id = rental_x_category.rental_id and 
		rental_x_category.rental_category_id = #db.param(arguments.ss.rental_category_id)# and 
		rental_active = #db.param(1)# and 
		rental.site_id = #db.param(form.site_id)# 
		<!--- and rental_category_id_list like #db.param('%,#arguments.ss.rental_category_id#,%')# --->  
		GROUP BY rental.rental_id 
		ORDER BY rental_x_category_sort asc, rental_beds ASC, rental_bath ASC, rental_rate ASC
        </cfsavecontent><cfscript>qProp=db.execute("qProp");
        for(row in qProp){
        	rentalIncludeTemplate(row);
        }
    	</cfscript>
    </cffunction>
    
    
    <cffunction name="rentalIncludeTemplate" localmode="modern" access="remote" returntype="any">
    	<cfargument name="ss" type="struct" required="yes">
    	
<cfscript>
ss=arguments.ss;
		var db=request.zos.queryObject;
application.zcore.app.getAppCFC("rental").onRentalPage();
if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){ 
	writeoutput('<div style="display:inline;"  id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit zEditorHTML" data-editurl="/z/rental/admin/rates/editRental?rental_id=#ss.rental_id#&amp;return=1">');
}   
if(not structkeyexists(request.zos, 'rentalIncludeOutputIndex')){
	request.zos.rentalIncludeOutputIndex=1;
}else{
	request.zos.rentalIncludeOutputIndex++;
}
</cfscript>
        <table class="zrental-tbspace" style="width:100%;">  <tr <cfif request.zos.rentalIncludeOutputIndex MOD 2 EQ 0>class="zrental-alternaterowcolor"<cfelse>class="zrental-rowcolor"</cfif>>
              <td style="vertical-align:top;" rowspan="2" class="zrental-includerentalname"><a href="#application.zcore.app.getAppCFC("rental").getRentalLink(ss.rental_id, ss.rental_name, ss.rental_url)#">
			  <cfscript>
			ts=structnew();
			ts.image_library_id=ss.rental_image_library_id;
			ts.output=false;
			ts.struct=ss;
			ts.size="150x100";
			ts.crop=1;
			ts.count = 2; // how many images to get
			//zdump(ts);
			arrImages=application.zcore.imageLibraryCom.displayImageFromStruct(ts); 
			for(i=1;i LTE arraylen(arrImages);i++){
				writeoutput('<img src="'&arrImages[i].link&'" width="150" height="100" alt="#htmleditformat(arrImages[i].caption)#" style="border:none;" />');
			}
			</cfscript>
<span style="padding-bottom:10px;display:block;">#ss.rental_name#</span></a></td>
                <td>
<cfif ss.rental_beds NEQ "">#ss.rental_beds# Bedroom<cfif ss.rental_beds GT 1>s</cfif><br /></cfif>
<cfif ss.rental_bath NEQ "">#ss.rental_bath# Bathroom<cfif ss.rental_bath GT 1>s</cfif><br />
</cfif>
<cfif ss.rental_max_guest NEQ 0>Sleeps 1 to #ss.rental_max_guest#</cfif>
</td>
                <td>
               
<cfscript>
ts=StructNew();
ts.rental_id=ss.rental_id;
ts.startDate=form.startDate;
ts.endDate=form.endDate;
ts.adults=application.zcore.functions.zso(form, 'inquiries_adults');
ts.children=application.zcore.functions.zso(form, 'inquiries_children');
ts.couponCode=application.zcore.functions.zso(form, 'inquiries_coupon');
rs=application.zcore.app.getAppCFC("rental").rateCalc(ts); 
mrate=0;
if(arraylen(rs.arrNights)){	
	mrate=rs.arrNights[1].rate;
}
for(i=2;i LTE arraylen(rs.arrNights);i++){
	mrate=min(mrate,rs.arrNights[i].rate);
}
preg=ss.rental_display_regular;
if(ss.rental_display_regular EQ 0){
	preg=ss.rental_rate;
}
</cfscript>
<span style="line-height:18px;"><cfif preg-mrate GT 0><span style="text-decoration:line-through; color:##CCCCCC; font-size:12px;">From #dollarformat(preg)#/night</span><br /></cfif>
<cfif mrate NEQ 0>From #dollarformat(mrate)#/night<br /></cfif>
<cfif preg-mrate GT 0><strong style="color:##FF0000; font-size:12px;">Save up to $#(preg-mrate)#/night</strong></cfif></span></td>
                <td style="text-align:right;">
                <a href="#application.zcore.app.getAppCFC("rental").getRentalLink(ss.rental_id,ss.rental_name,ss.rental_url)#">View Rental</a><br />
                
    <cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_availability_calendar EQ 1 and ss.rental_enable_calendar EQ '1' and (structkeyexists(form,'method') eq false or form.method NEQ "calendarTemplate")>
<a href="#application.zcore.app.getAppCFC("rental").getCalendarLink(ss.rental_id,ss.rental_name,ss.rental_url)#">Availability Calendar</a><br />
    </cfif>
    <cfif (structkeyexists(form,'method') eq false or form.method NEQ "inquiryTemplate")>
    <cfif application.zcore.app.getAppData("rental").optionstruct.rental_config_reserve_online EQ 1>
<a href="##zrental-calendar"><strong>Reserve Now</strong></a>
<cfelse>
<a href="#application.zcore.app.getAppCFC("rental").getRentalInquiryLink()#?rental_id=#ss.rental_id#" rel="nofollow">Inquire Now</a>
    </cfif>
</cfif>
           </td>
              </tr>
              
              
<cfscript>
arrAmen=arraynew(1);
if(ss.rental_pool EQ 1){
	arrayappend(arrAmen,'Pool');	
}
if(ss.rental_mountainview EQ 1){
	arrayappend(arrAmen,'Mountain View');	
}
if(ss.rental_waterview EQ 1){
	arrayappend(arrAmen,'Water View');	
}
if(ss.rental_gameroom EQ 1){
	arrayappend(arrAmen,'Game Room');	
}
if(ss.rental_cabletv EQ 1){
	arrayappend(arrAmen,'Satellite/Cable TV');	
}
if(ss.rental_highspeedinternet EQ 1){
	arrayappend(arrAmen,'High Speed Internet');	
}
if(ss.rental_fireplace EQ 1){
	arrayappend(arrAmen,'Fireplace');	
}
if(ss.rental_hottub EQ 1){
	arrayappend(arrAmen,'Hot Tub');	
}
if(ss.rental_petfriendly EQ 1){
	arrayappend(arrAmen,'Pet Friendly');	
}
if(ss.rental_oceanview EQ 1){
	arrayappend(arrAmen,'Ocean View');	
}
if(ss.rental_riverview EQ 1){
	arrayappend(arrAmen,'River View');	
}
 db.sql="select * from #db.table("rental_x_amenity", request.zos.zcoreDatasource)# rental_x_amenity, 
 #db.table("rental_amenity", request.zos.zcoreDatasource)# rental_amenity 
WHERE rental_x_amenity.site_id = rental_amenity.site_id and 
rental_amenity.rental_amenity_id = rental_x_amenity.rental_amenity_id and 
rental_x_amenity.site_id = #db.param(request.zos.globals.id)# and 
rental_id = #db.param(ss.rental_id)# and 
rental_x_amenity_deleted = #db.param(0)# and 
rental_amenity_deleted = #db.param(0)#";
qXAmenity=db.execute("qXAmenity");
</cfscript>
<cfloop query="qXAmenity"><cfscript>
	arrayappend(arrAmen,qXAmenity.rental_amenity_name);	</cfscript></cfloop>
    <cfscript>
	arraysort(arrAmen, "text","asc");
	</cfscript>
<tr <cfif request.zos.rentalIncludeOutputIndex MOD 2 EQ 0>class="zrental-alternaterowcolor"<cfelse>class="zrental-rowcolor"</cfif>><td colspan="3" style="height:45px;vertical-align:top;border-bottom:2px solid ##999999; padding-top:0px;">
 <cfif trim(ss.rental_special) NEQ ''>
<span style="color:##FF0000; font-weight:bold; font-size:14px;">
<span id="zratepremhintrental_#ss.rental_id#" style="position:relative; left:0; top:0; visibility:'visible';text-align:left; width:100%; display:block;">#ss.rental_special#</span></span>
<cfif ss.rental_special_flash EQ 1>
<script type="text/javascript">
/* <![CDATA[ */ zArrDeferredFunctions.push(function(){zBlinkId("zratepremhintrental_#ss.rental_id#",500);}); /* ]]> */
</script>
</cfif> 
</cfif>
<cfif arraylen(arrAmen) NEQ 0>
<strong>Features:</strong><br />
#arraytolist(arrAmen,", ")#</cfif></td></tr></table>
   <cfscript>
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){ 
		writeoutput('</div>');
	}
	</cfscript>
    </cffunction>
    
    
    <cffunction name="categoryTemplate" localmode="modern" access="remote" returntype="any">
    	
<cfscript>
var ct1948=0;
var search_rate_high=0;
var categoryUnique=0;
var searchaction=0;
var i=0;
var qC2=0;
var search_bathrooms=0;
var qC=0;
var arrNav=0;
var hasInquiryLink=0;
var qpar=0;
var selectStruct=0;
var search_rate_low=0;
var search_bedrooms=0;
var search_rental_sort=0;
var tempRentalHTML=0;
var parentChildGroupId=0;
var inquiries_children=0;
var arrName=0;
var search_city=0;
var arrImages=0;
var temppagenav=0;
var rs=0;
var search_max_guest=0;
var inquiries_adults=0;
var qrental=0;
var qchild=0;
var g=0;
var site_id=0;
var parentparentid=0;
var cpi=0;
var inquiries_coupon=0;
var therentalHTMLSection=0;
var t99=0;
var search_rental_category_id=0;
var tempMeta=0;
var ts=0;
		var db=request.zos.queryObject;
application.zcore.app.getAppCFC("rental").onRentalPage();
//request.zos.page.setActions(structnew());
  
	if(structkeyexists(form, 'rental_category_id') EQ false){
		application.zcore.functions.z301Redirect('/');
	} 
	</cfscript>
        
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("rental_category", request.zos.zcoreDatasource)# rental_category 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	rental_category_id=#db.param(form.rental_category_id)# and 
	rental_category_deleted = #db.param(0)#
	</cfsavecontent><cfscript>qrental=db.execute("qrental");
	if(qrental.recordcount EQ 0 and application.zcore.functions.zso(form, 'zIgnoreMissingrental',false,false) EQ false){
		application.zcore.functions.z301Redirect('/');
	}
	application.zcore.functions.zQueryToStruct(qrental, local); 
	if(structkeyexists(form, 'zurlname') and application.zcore.functions.zURLEncode(rental_category_name,'-') NEQ form.zURLName and rental_category_url EQ ''){
		application.zcore.functions.z301Redirect(application.zcore.app.getAppCFC("rental").getCategoryLink(rental_category_id,rental_category_name,rental_category_url));
	}else if(structkeyexists(form, 'zurlname') and rental_category_url NEQ ''){
		application.zcore.functions.z301Redirect(application.zcore.app.getAppCFC("rental").getCategoryLink(rental_category_id,rental_category_name,rental_category_url));
	}
	
    </cfscript>
  <cfif rental_category_slideshow_id NEQ 0>
    	<cfscript>application.zcore.functions.zEmbedSlideShow(rental_category_slideshow_id);</cfscript>
    </cfif>
    <cfscript>
	request.rentalCount=0;
	request.cOutStruct=structnew();	 
	
    arrNav=ArrayNew(1);
    cpi=rental_category_parent_id;
    arrName=ArrayNew(1);
    parentparentid='0';
	categoryUnique=structnew();
	categoryUnique[rental_category_id]=true;
	categoryUnique[cpi]=true;
    parentChildGroupId=0; // general rental_category
    </cfscript>
    <cfloop from="1" to="255" index="g">
        <cfsavecontent variable="db.sql">
        SELECT * FROM #db.table("rental_category", request.zos.zcoreDatasource)# rental_category 
		WHERE rental_category_id = #db.param(cpi)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		rental_category_deleted=#db.param(0)# 
        </cfsavecontent><cfscript>qpar=db.execute("qpar");</cfscript>
        <cfif qpar.recordcount EQ 0>
        	<cfbreak>
        </cfif>
        <cfif g EQ 1>
        	<cfset parentParentId=qpar.rental_category_parent_id>
        </cfif>
        <cfscript>
        ArrayAppend(arrName, qpar.rental_category_name);
        arrayappend(arrNav, '<a href="#request.zos.currentHostName##application.zcore.app.getAppCFC("rental").getCategoryLink(qpar.rental_category_id,qpar.rental_category_name,qpar.rental_category_url)#">#qPar.rental_category_name#</a> / ');
        cpi=qpar.rental_category_parent_id;
		categoryUnique[cpi]=true;
        </cfscript>
        <cfif cpi EQ 0>
        	<cfbreak>
        </cfif>
    </cfloop> 
    <cfscript>
	request.zos.tempObj.currentRentalCategoryIdStruct=categoryUnique;
	</cfscript>
	<cfsavecontent variable="tempMeta">
	<meta name="Keywords" content="#htmleditformat(rental_category_metakey)#" />
	<meta name="Description" content="#htmleditformat(rental_category_metadesc)#" />
	</cfsavecontent>
	<cfsavecontent variable="temppagenav">
    <a href="/">#application.zcore.functions.zvar('homelinktext')#</a> / 
    <a href="#application.zcore.app.getAppCFC("rental").getRentalHomeLink()#">#application.zcore.app.getAppData("rental").optionstruct.rental_config_home_page_title#</a> / 
	<cfscript>
	for(i=arraylen(arrNav);i GTE 1;i=i-1){
		writeoutput(arrNav[i]);
	}
	</cfscript>
	</cfsavecontent>  
	<cfscript>
		application.zcore.template.setTag('title',rental_category_name);
		application.zcore.template.setTag('meta',tempMeta);
		application.zcore.template.setTag('pagetitle',rental_category_name);
		application.zcore.template.setTag('pagenav',temppagenav);
	</cfscript> 
	<cfif application.zcore.functions.zso(application.zcore.app.getAppData("rental").optionstruct, 'rental_config_disable_child_category_links', false, 0) EQ 0>
		<cfsavecontent variable="db.sql">
		SELECT *  FROM #db.table("rental_category", request.zos.zcoreDatasource)# rental_category  
		WHERE rental_category_parent_id = #db.param(rental_category_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		rental_category_deleted = #db.param(0)#
		ORDER BY rental_category_sort ASC, rental_category_name ASC
		</cfsavecontent><cfscript>qchild=db.execute("qchild");</cfscript>	
	<cfelse>
		<cfscript>
		qchild={recordcount:0};
		</cfscript>
	</cfif>   
    <cfsavecontent variable="therentalHTMLSection">
	<cfscript>
	//if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){ 
		writeoutput('<div style="display:inline;"  id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit zEditorHTML" data-editurl="/z/rental/admin/rental-category/edit?rental_category_id=#rental_category_id#&amp;return=1">');
		application.zcore.template.prependTag('pagetitle','<span style="display:inline;"  id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/rental/admin/rental-category/edit?rental_category_id=#rental_category_id#&amp;return=1">');
		application.zcore.template.appendTag('pagetitle','</span>');
	//}   
</cfscript>
<cfsavecontent variable="tempRentalHTML">
            <cfscript>
			
	ts=structnew();
	ts.rental_category_id=rental_category_id;
	this.includeRentalByCategoryId(ts);
	</cfscript>
    </cfsavecontent>
    <cfscript>
	if(tempRentalHTML CONTAINS application.zcore.app.getAppCFC("rental").getRentalInquiryLink()){
		hasInquiryLink=true;
	}else{
		hasInquiryLink=false;
	}
	</cfscript>
    <cfif qchild.recordcount NEQ 0 or hasInquiryLink>
	<div class="zrental-jumpbox">
		<cfif qchild.recordcount NEQ 0>
			Jump To Rental Category: 
			<select name="jumpToCategory" onchange="var link=this.options[this.selectedIndex].value; if(link != ''){window.location.href = link;}" size="1">
			<option value="">-- Select --</option>
			<cfloop query="qchild">
				<option value="#request.zos.currentHostName##application.zcore.app.getAppCFC("rental").getCategoryLink(qchild.rental_category_id, qchild.rental_category_name, qchild.rental_category_url)#">#qchild.rental_category_name#</option>
			</cfloop></select> 
		 </cfif> 
		 <cfif qchild.recordcount NEQ 0 and hasInquiryLink>
			<br /> or 
		</cfif>
		<cfif hasInquiryLink> <a href="##rental-list">Browse The Rentals In This Category </cfif></a>
		</div>
	</cfif>

	<cfscript>
	ts=structnew();
	ts.output=false;
	ts.image_library_id=rental_category_image_library_id;
	ts.size="#request.zos.globals.maximagewidth#x2000";
	ts.crop=1;
	arrImages=application.zcore.imageLibraryCom.displayImages(ts);
	if(arraylen(arrImages) NEQ 0){
		application.zcore.imageLibraryCom.registerSize(rental_category_image_library_id, "350x232", 0);
		link=application.zcore.imageLibraryCom.getImageLink(rental_category_image_library_id, arrImages[1].id, "350x232", 0, true, arrImages[1].caption, arrImages[1].file, arrImages[1].updatedDatetime);
		// temporarily disabled the popup images.
		writeoutput('<img src="#link#" alt="#htmleditformat(arrImages[1].caption)#" style="padding-right:10px; padding-bottom:10px; border:none; text-align:left; " />');
	}
	
	ct1948=rental_category_text;
</cfscript>


#ct1948#<br style="clear:both;" />
   <cfscript>
   
	for(i=2;i LTE arraylen(arrImages);i=i+1){
		writeoutput('<img src="#arrImages[i].link#" alt="#htmleditformat(arrImages[i].caption)#" /><br /><br />');
	}
   
	//if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){ 
		writeoutput('</div>');
	//}
	</cfscript>
   </cfsavecontent>
    <cfscript>
	if(structkeyexists(form, 'zsearchtexthighlight') AND contentConfig.searchincludebars EQ false and form[request.zos.urlRoutingParameter] NEQ "/z/misc/search-site/results"){
		t99=application.zcore.functions.zHighlightHTML(form.zsearchtexthighlight,therentalHTMLSection);
	}else{
		t99=therentalHTMLSection;
	}
	writeoutput(t99);
	</cfscript>
    <hr />
    
    <h2>Rental Search</h2>
    <cfset form.search_rental_category_id=rental_category_id>
    #this.includeRentalSearchForm()#
    <hr />
    <cfif qchild.recordcount NEQ 0>
   	  <h2>Further narrow your rental search or scroll down to view the rentals in this category.</h2>
        <ul>
    <cfloop query="qchild">
    <li><a href="#request.zos.currentHostName##application.zcore.app.getAppCFC("rental").getCategoryLink(qchild.rental_category_id, qchild.rental_category_name, qchild.rental_category_url)#">#qchild.rental_category_name#</a></li>
    </cfloop>
    </ul>
    <hr />
    </cfif>
    
    
    <cfif hasInquiryLink>
    <a id="rental-list"></a>
        <h2>Browse Our Rentals In This Category</h2><br />
        #tempRentalHTML#
    </cfif>

        
<!---     
<cfset pcount=0>
     
<cfif pcount NEQ 0>
<hr>
<a id="zbeginlistings"></a>
<h2>See more properties for sale below</h2><br /> 
    <cfscript>
    if(parentChildSorting EQ 1){
		arrOrder=structsort(request.cOutStruct,"numeric","desc","price");
	}else if(parentChildSorting EQ 2){
		arrOrder=structsort(request.cOutStruct,"numeric","asc","price");
	}else if(parentChildSorting EQ 0){
		arrOrder=structsort(request.cOutStruct,"numeric","asc","sort");
	}
	//application.zcore.functions.zdump(request.cOutStruct);
	
	for(i=1;i LTE arraylen(arrOrder);i++){
		//if(i NEQ 1){ writeoutput('<hr />'); }
		//application.zcore.functions.zdump(request.cOutStruct);
		//application.zcore.functions.zdump(arrOrder);
		writeoutput(request.cOutStruct[arrOrder[i]].output); 
	}
	</cfscript>
</cfif> --->
  
	<cfscript>
		application.zcore.template.setTag('title',rental_category_name);
		application.zcore.template.setTag('meta',tempMeta);
		application.zcore.template.setTag('pagetitle',rental_category_name);
		application.zcore.template.setTag('pagenav',temppagenav);
	</cfscript> 
        
    </cffunction>
    
    
    
    <cffunction name="includeRentalListHeader" localmode="modern" output="yes" returntype="any">
    	<cfif isDefined('request.rentalListHeaderDisplayed') EQ false>
        	<cfset request.rentalListHeaderDisplayed=true>
        <table class="zrental-tbspace" style="width:100%;">
          <tr>
            <th style="width:302px;">Rental</th>
            <th>BR/BA/Sleeps</th>
            <th>&nbsp;</th>
            <th>&nbsp;</th>
          </tr>
        </table>
        </cfif>
    </cffunction>
    
    <cffunction name="categoryListTemplate" localmode="modern" access="remote" returntype="any">
		<cfscript>
		var db=request.zos.queryObject;
		</cfscript>

    <cfsavecontent variable="tempRentalHomeFeaturedHTML">
	<cfscript>this.compareRentalAmenitiesTemplate();</cfscript>
    </cfsavecontent>
    	<cfscript>
		
		ts=structnew();
		ts.content_unique_name=application.zcore.app.getAppCFC("rental").getRentalHomeLink();
		
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		if(r1 EQ false){
			application.zcore.template.setTag("title",application.zcore.app.getAppData("rental").optionStruct.rental_config_home_page_title);
			application.zcore.template.setTag("pagetitle",application.zcore.app.getAppData("rental").optionStruct.rental_config_home_page_title);
		}
		</cfscript>
  <!---   <h2>Search Our Rentals</h2>
    
    Beds: 
    Baths:
    Sleeps: 
    Price Range: 
	RADIO Annual Leases or RADIO Short Term Rental
    Period: Weekly | Nightly | Monthly
    Features: 
Gameroom:  Yes  No  
Mountain View:  Yes  No  
Water View:  Yes  No  
Hot Tub:  Yes  No  
Fireplace:  Yes  No  
High Speed Internet:  Yes  No  
Cable TV:  Yes  No  
Ocean View:  Yes  No  
River View:  Yes  No  
Pet Friendly:  Yes  No  

	
     --->
    
	<cfscript>
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="rental_category_image_library_id";
	ts.count = 1; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * #db.trustedSQL(rs.select)# 
	FROM #db.table("rental_category", request.zos.zcoreDatasource)# rental_category 
	#db.trustedSQL(rs.leftJoin)# 
	WHERE rental_category.site_id = #db.param(request.zos.globals.id)# and 
	rental_category_parent_id = #db.param('0')# and 
	rental_category_deleted = #db.param(0)#
	GROUP BY rental_category.rental_category_id  
	ORDER BY rental_category_sort ASC, rental_category_name ASC
	</cfsavecontent><cfscript>qpar=db.execute("qpar");</cfscript>	 
    <h2>Browse Our Rental Categories</h2>
    <ul>
	<cfloop query="qpar">
        <li><h3><a href="#request.zos.currentHostName##application.zcore.app.getAppCFC("rental").getCategoryLink(qpar.rental_category_id, qpar.rental_category_name, qpar.rental_category_url)#"> 
			#qpar.rental_category_name#</a></h3></li>  
    </cfloop>
    </ul>
    <h2>Rental Search</h2>
    #this.includeRentalSearchForm()#
    <hr />
    <!--- featured rentals go here... --->
    <cfif tempRentalHomeFeaturedHTML CONTAINS application.zcore.app.getAppCFC("rental").getRentalInquiryLink()>
    <h2>Featured Rentals</h2><br /><br />

    #tempRentalHomeFeaturedHTML#
  </cfif>
    </cffunction>
    
    <cffunction name="searchTemplate" localmode="modern" access="remote" returntype="any">
    <cfscript>
		var db=request.zos.queryObject;
form.search_city=application.zcore.functions.zso(form, 'search_city');
form.search_max_guest=application.zcore.functions.zso(form, 'search_max_guest');
form.search_rate_low=application.zcore.functions.zso(form, 'search_rate_low');
form.search_bedrooms=application.zcore.functions.zso(form, 'search_bedrooms');
form.search_bathrooms=application.zcore.functions.zso(form, 'search_bathrooms');
form.search_rate_high=application.zcore.functions.zso(form, 'search_rate_high');
form.search_rental_category_id=application.zcore.functions.zso(form, 'search_rental_category_id');
form.search_rental_sort=application.zcore.functions.zso(form, 'search_rental_sort');
form.searchaction=application.zcore.functions.zso(form, 'searchaction',false,'form');
if(structkeyexists(form,'method') EQ false or form.method NEQ "searchTemplate"){
	form.searchaction="";
}

form.site_id=request.zos.globals.id;
var ts=structnew();
ts.image_library_id_field="rental.rental_image_library_id";
ts.count =  2; // how many images to get
var rs=application.zcore.imageLibraryCom.getImageSQL(ts);
form.startDate=dateadd("d",3,now());
form.endDate=dateadd("d",3,form.startDate);
form.inquiries_adults=2;
form.inquiries_children=0;
form.inquiries_coupon="";

</cfscript>

<form action="/z/rental/rental-front/searchTemplate" method="get">
<input type="hidden" name="searchaction" value="search" class="z-manager-search-button" />
<!--- <style type="text/css">
/* <![CDATA[ */ 
.zrental-searchtable div{  padding-bottom:7px; width:33%; float:left; }
 /* ]]> */
 </style> --->
<table style="border-spacing:0px; padding:5px;" class="zrental-searchtable">
<tr><td>
<cfsavecontent variable="db.sql">
SELECT rental_category.rental_category_name, rental_category.rental_category_id 
FROM (#db.table("rental", request.zos.zcoreDatasource)# rental, 
#db.table("rental_x_category", request.zos.zcoreDatasource)# rental_x_category, 
#db.table("rental_category", request.zos.zcoreDatasource)# rental_category) 
WHERE 
rental_deleted = #db.param(0)# and 
rental_x_category_deleted = #db.param(0)# and 
rental_category_deleted = #db.param(0)# and
rental.site_id = rental_x_category.site_id and 
rental_x_category.site_id = rental_category.site_id and 
rental.rental_id = rental_x_category.rental_id and 
rental_x_category.rental_category_id = rental_category.rental_category_id and 
rental_active = #db.param(1)# and 
rental.site_id = #db.param(form.site_id)# and 
rental_available_start_date <=#db.param(dateformat(now(), 'yyyy-mm-dd'))# and 
(rental_category.rental_category_id = #db.param(form.search_rental_category_id)# or 
rental_category_searchable=#db.param('1')#) 
GROUP BY rental_category.rental_category_id  
ORDER BY rental_category.rental_category_name 
</cfsavecontent><cfscript>var qC2=db.execute("qC2");</cfscript>
<cfif qC2.recordcount NEQ 0>
<div style="width:100%;padding-bottom:7px;  float:left;">
 Category: 
<cfscript>
	var selectStruct = StructNew();
	selectStruct.name = "search_rental_category_id";
	selectStruct.query=qc2;
	selectStruct.styleInline="width:30px;";
	//selectStruct.selectLabel="Category";
	selectStruct.queryLabelField="rental_category_name";
	selectStruct.queryValueField="rental_category_id";
	application.zcore.functions.zInputSelectBox(selectStruct);
  </cfscript>
  </div>
  </cfif>
<cfsavecontent variable="db.sql">
SELECT rental_city FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
WHERE rental_active = #db.param(1)# and 
rental.site_id = #db.param(form.site_id)# and 
rental_available_start_date <=#db.param(dateformat(now(), 'yyyy-mm-dd'))#
 and rental_city <> #db.param('')# and 
 rental_deleted = #db.param(0)#
 GROUP BY rental.rental_city 
 ORDER BY rental.rental_city 
</cfsavecontent><cfscript>var qC=db.execute("qC");</cfscript>
<cfif qC.recordcount NEQ 0>
<div style="padding-bottom:7px; padding-right:15px; float:left;">
City: 
<cfscript>
	selectStruct = StructNew();
	selectStruct.name = "search_city";
	selectStruct.query=qc;
	//selectStruct.selectLabel="City";
	selectStruct.queryValueField="rental_city";
	selectStruct.queryLabelField="rental_city";
	application.zcore.functions.zInputSelectBox(selectStruct);
  </cfscript>
  </div>
  </cfif>

<cfsavecontent variable="db.sql">
SELECT rental_beds FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
WHERE rental_active = #db.param(1)# and 
rental.site_id = #db.param(form.site_id)# and 
rental_available_start_date <=#db.param(dateformat(now(), 'yyyy-mm-dd'))#
 and rental_beds <> #db.param('')# 
  and rental_beds <> #db.param(0)# and 
  rental_deleted = #db.param(0)#
 GROUP BY rental.rental_beds 
 ORDER BY rental.rental_beds 
</cfsavecontent>
<cfscript>var qC=db.execute("qC");</cfscript>
<cfif qC.recordcount NEQ 0>
	<div style="padding-bottom:7px; padding-right:15px; float:left;">Bedrooms: 
	<cfscript>
	var selectStruct = StructNew();
	selectStruct.name = "search_bedrooms";
	selectStruct.query=qc;
	selectStruct.queryValueField="rental_beds";
	selectStruct.queryLabelField="rental_beds";
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript>
	</div>
</cfif>
<cfsavecontent variable="db.sql">
SELECT rental_bath FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
WHERE rental_active = #db.param(1)# and 
rental.site_id = #db.param(form.site_id)# and 
rental_available_start_date <=#db.param(dateformat(now(), 'yyyy-mm-dd'))#
 and rental_bath <> #db.param('')# 
  and rental_bath <> #db.param(0)# and 
  rental_deleted = #db.param(0)#
 GROUP BY rental.rental_bath
 ORDER BY rental.rental_bath
</cfsavecontent>
<cfscript>var qC=db.execute("qC");</cfscript>
<cfif qC.recordcount NEQ 0>
	<div style="padding-bottom:7px; padding-right:15px; float:left;">Bathrooms: 
	<cfscript>
	var selectStruct = StructNew();
	selectStruct.name = "search_bathrooms";
	selectStruct.query=qc;
	selectStruct.queryValueField="rental_bath";
	selectStruct.queryLabelField="rental_bath";
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript>
	</div>
</cfif>
<cfsavecontent variable="db.sql">
SELECT rental_max_guest  FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
WHERE rental_active = #db.param(1)# and 
rental.site_id = #db.param(form.site_id)# and 
rental_available_start_date <=#db.param(dateformat(now(), 'yyyy-mm-dd'))#
 and rental_max_guest  <> #db.param('')# 
  and rental_max_guest  <> #db.param(0)# and 
  rental_deleted = #db.param(0)#
 GROUP BY rental.rental_max_guest 
 ORDER BY rental.rental_max_guest 
</cfsavecontent>
<cfscript>var qC=db.execute("qC");</cfscript>
<cfif qC.recordcount NEQ 0>
	<div style="padding-bottom:7px; padding-right:15px; float:left;">## of Guests: 
	<cfscript>
	var selectStruct = StructNew();
	selectStruct.name = "search_max_guest";
	selectStruct.query=qc;
	selectStruct.queryValueField="rental_max_guest";
	selectStruct.queryLabelField="rental_max_guest";
	application.zcore.functions.zInputSelectBox(selectStruct);
	</cfscript>
	</div>
</cfif>
<!--- <div style="padding-bottom:7px; padding-right:15px; float:left;">
Sort: 
<cfscript>
selectStruct = StructNew();
selectStruct.name = "search_rental_sort";
selectStruct.listLabels = "Price Asc|Price Desc|Max Guests";
selectStruct.listValues = "priceasc|pricedesc|maxguest";
selectStruct.listLabelsDelimiter="|";
selectStruct.listValuesDelimiter="|";
application.zcore.functions.zInputSelectBox(selectStruct);
</cfscript>
</div> --->
<!--- 
<div style="padding-bottom:7px; padding-right:15px; float:left;">
Nightly Rate:
<cfscript>
selectStruct = StructNew();
selectStruct.name = "search_rate_low";
selectStruct.selectLabel="Min Price";
selectStruct.listLabels="Any|$50|$100|$150|$200|$300|$400|$600|$800|$1,000|$1,200|$1,400|$1,600|$1,800|$2,000|$2,500|$3,000|$4,000|$5,000|$6,000|$7,000|$8,000|$9,000|$10,000|$20,000|$30,000|$40,000|$50,000|$100,000|Any";

selectStruct.listValues="0|50|100|150|200|300|400|600|800|1000|1200|1400|1600|1800|2000|2500|3000|4000|5000|6000|7000|8000|9000|10000|20000|30000|40000|50000|100000|0";
selectStruct.listLabelsDelimiter="|";
selectStruct.listValuesDelimiter="|";
application.zcore.functions.zInputSelectBox(selectStruct);
</cfscript>
		To: 
<cfscript>
selectStruct = StructNew();
selectStruct.name = "search_rate_high";
selectStruct.selectLabel="Max Price";
selectStruct.listLabels="Any|$50|$100|$150|$200|$300|$400|$600|$800|$1,000|$1,200|$1,400|$1,600|$1,800|$2,000|$2,500|$3,000|$4,000|$5,000|$6,000|$7,000|$8,000|$9,000|$10,000|$20,000|$30,000|$40,000|$50,000|$100,000|Any";

selectStruct.listValues="10000000|50|100|150|200|300|400|600|800|1000|1200|1400|1600|1800|2000|2500|3000|4000|5000|6000|7000|8000|9000|10000|20000|30000|40000|50000|100000|10000000";

selectStruct.listLabelsDelimiter="|";
selectStruct.listValuesDelimiter="|";
application.zcore.functions.zInputSelectBox(selectStruct);
</cfscript>
</div> --->

<div style="padding-bottom:7px; padding-right:15px; float:left;">
<button type="submit" name="submit8324549n" value="SEARCH">Search Rentals</button>
                  </div>
</td>
</tr>
</table>

</form>

<cfif form.searchaction EQ "form">
<cfscript>
application.zcore.template.setTag("title","Rental Search");
application.zcore.template.setTag("pagetitle","Rental Search");
</cfscript>
<cfelseif form.searchaction EQ "search">
<hr />
<cfscript>

application.zcore.template.setTag("title","Rental Search Results");
application.zcore.template.setTag("pagetitle","Rental Search Results");
</cfscript>

<cfsavecontent variable="db.sql">
SELECT * #db.trustedSQL(rs.select)# 
FROM (#db.table("rental", request.zos.zcoreDatasource)# rental, 
#db.table("rental_x_category", request.zos.zcoreDatasource)# rental_x_category) 
#db.trustedSQL(rs.leftJoin)# 
WHERE rental.rental_id = rental_x_category.rental_id and 
rental.site_id = rental_x_category.site_id and 
rental_deleted = #db.param(0)# and 
rental_x_category_deleted = #db.param(0)# 

<cfif form.search_rental_category_id NEQ "">
and rental_x_category.rental_category_id = #db.param(form.search_rental_category_id)# 
</cfif>
<cfif form.search_city NEQ "">
and rental_city=#db.param(form.search_city)#
</cfif>
<cfif form.search_bedrooms NEQ "">
and rental_beds>=#db.param(form.search_bedrooms)#
</cfif>
<cfif form.search_bathrooms NEQ "">
and rental_bath>=#db.param(form.search_bathrooms)#
</cfif>
<cfif form.search_max_guest NEQ "">
and rental_max_guest>=#db.param(form.search_max_guest)#
</cfif>
<!--- <cfif form.search_rate_low NEQ "">
and (rental_rate <> '0' and rental_rate>=#db.param(form.search_rate_low)#)
</cfif>
<cfif form.search_rate_high NEQ "">
and (rental_rate <> '0' and rental_rate<=#db.param(form.search_rate_high)#)
</cfif>
 --->
	 and rental_active = #db.param(1)# and rental.site_id = #db.param(form.site_id)# and rental_available_start_date <=#db.param(dateformat(now(), 'yyyy-mm-dd'))#  
	  GROUP BY rental.rental_id ORDER BY 
	<cfif form.search_rental_sort EQ "pricedesc">rental_rate desc
	<cfelseif form.search_rental_sort EQ "pricedesc">rental_rate asc
	<cfelseif form.search_rental_sort EQ "maxguest">rental_max_guest desc
	<cfelse>rental_x_category_sort asc, rental_beds ASC, rental_bath ASC, rental_rate ASC
	</cfif>
	</cfsavecontent><cfscript>var qProp=db.execute("qProp");</cfscript>  
		<cfif qProp.recordcount EQ 0>
			<p>Your search didn't match our rental listings. Please try again with different criteria.</p>
		<cfelse>
			<h3>#qprop.recordcount# matching listings found</h3>
			<cfscript>
			this.includeRentalListHeader();
			</cfscript>
		</cfif>
		<cfscript>
		for(row in qProp){
			rentalIncludeTemplate(row);
		}
		</cfscript>
	</cfif>
	</cffunction>
    
    
    <cffunction name="lodgixInquiryTemplate" localmode="modern" access="public" returntype="any">
    	<cfscript>
    	db=request.zos.queryObject;
		lodgix_property_id="";
		if(application.zcore.functions.zso(form, 'rental_id',true) NEQ 0){
			 db.sql="SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)#  
			WHERE rental_id=#db.param(form.rental_id)# and 
			rental_deleted=#db.param(0)#  and 
			site_id = #db.param(request.zos.globals.id)# and 
			rental_active=#db.param('1')#";
			qrental=db.execute("qrental");
			if(qrental.recordcount EQ 0){
				application.zcore.functions.z301redirect('/');	
			} 
			lodgix_property_id=qrental.rental_lodgix_property_id; 
		/*}else{
			application.zcore.functions.z301redirect('/');*/
		}
		</cfscript>
<!--- 
working example from gravity forms
<cfmail from="#request.zos.developerEmailTo#" to="inquiry-1@lodgix.com" type="html" charset="utf-8" subject="Inquiry" >Property ID: 1
Name: Test Name
Email: developer@your-company.com
Phone: (123)123-1234

Date Format: mm/dd/yyyy
Start Date: 08/08/2012
End Date: 08/08/2012
Number of Adults: 1
Number of Children: 0

Address1: 123 Test Dr
Address2: 
City: City
State: State
Zip: 32176
Country: United States

Comments: Testing inquiry - please ignore.
</cfmail> --->
<cfset defaultLodgixUsed=false>
<cfscript>
</cfscript>
<cfmail to="#application.zcore.app.getAppData("rental").optionstruct.rental_config_lodgix_email_to#" from="#form.inquiries_email#" charset="utf-8" subject="#application.zcore.app.getAppData("rental").optionstruct.rental_config_lodgix_email_subject#">Property ID: <cfif application.zcore.functions.zso(form, 'lodgix_property_id') EQ "">#application.zcore.app.getAppData("rental").optionstruct.rental_config_lodgix_property_id#<cfset defaultLodgixUsed=true><cfelse>#form.lodgix_property_id#</cfif><!--- {Property ID:21:value} --->
Name: #form.inquiries_first_name# #form.inquiries_last_name#
Email: <cfif structkeyexists(form, 'inquiries_email')>#form.inquiries_email#</cfif>
Phone: <cfif structkeyexists(form, 'inquiries_phone1')>#form.inquiries_phone1#</cfif>

Date Format: mm/dd/yyyy
Start Date: <cfif structkeyexists(form, 'inquiries_start_date')>#dateformat(form.inquiries_start_date,'mm/dd/yyyy')#</cfif>
End Date: <cfif structkeyexists(form, 'inquiries_end_date')>#dateformat(form.inquiries_end_date,'mm/dd/yyyy')#</cfif>
Number of Adults: <cfif structkeyexists(form, 'inquiries_adults')>#form.inquiries_adults#</cfif>
Number of Children: <cfif structkeyexists(form, 'inquiries_children')>#form.inquiries_children#</cfif>

Address1: <cfif structkeyexists(form, 'inquiries_address')>#form.inquiries_address#</cfif>
Address2: 
City: <cfif structkeyexists(form, 'inquiries_city')>#form.inquiries_city#</cfif>
State: <cfif structkeyexists(form, 'inquiries_state')>#form.inquiries_state#</cfif>
Zip: <cfif structkeyexists(form, 'inquiries_zip')>#form.inquiries_zip#</cfif>
Country: <cfif structkeyexists(form, 'inquiries_country')>#form.inquiries_country#</cfif>

Comments: <cfif defaultLodgixUsed>No rental was selected. A default property ID was set in order to integrate with Lodgix.com inquiry system. | </cfif><cfif structkeyexists(form, 'inquiries_comments')>#replace(replace(form.inquiries_comments,chr(10), " ","all"),chr(13)," ","all")# <cfif structkeyexists(form, 'inquiries_company')>#form.inquiries_company#</cfif></cfif>
</cfmail>
    </cffunction>
    
    </cfoutput>
</cfcomponent>