<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" returntype="any">
<cfscript> 
request.zos.currentURLISAListingPage=true;
var temp=structnew();  
application.zcore.template.setTag("title","Property Detail"); 
ts=StructNew();
ts.list=''; 
if(structkeyexists(form, 'searchId') EQ false and isDefined('request.zsession.tempVars.zListingSearchId')){
	form.searchId=request.zsession.tempVars.zListingSearchId;
}

//application.zcore.template.prependTag("topcontent",'<div id="ztopofdetailpage" style="width:1px; height:1px;display:inline;"></div>');
//application.zcore.template.appendTag("content",'<script type="text/javascript">/* <![CDATA[ */ zJumpToId("ztopofdetailpage"); /* ]]> */</script>');

temp.title = "Listing";
application.zcore.template.setTag('title', temp.title);
application.zcore.template.setTag('pagetitle', temp.title);
</cfscript>
<cfsavecontent variable="temp.pageNav">
<a href="/">#request.zos.globals.homelinktext#</a> :: #temp.title#
</cfsavecontent>
<cfscript>
application.zcore.template.setTag('pagenav', temp.pageNav);
</cfscript>
<cfif structkeyexists(form, 'zprint')>
<div style="width:#request.zos.globals.maximagewidth#px; padding:10px; float:left; font-size:12px; line-height:14px; font-family:Verdana, Geneva, sans-serif;">
<div style="width:100%; float:left; padding-bottom:10px; border-bottom:1px solid ##999; margin-bottom:10px;">
<cfscript>
h=application.zcore.functions.zvarso("Global Email HTML Header", request.zos.globals.id, true);
</cfscript>
<cfif h NEQ "">
#h#
<cfelse>
<h2>#request.zos.globals.shortdomain#</h2>
<cfif request.zos.globals.emailsignature NEQ ""><p>#replace(request.zos.globals.emailsignature,chr(10),"<br />","all")#</p>
<cfelse>
<p>#application.zcore.functions.zencodeemail(request.officeEmail, true)#</p>
</cfif>
</cfif>
</div>
</cfif>
<cfscript>
if(structkeyexists(form, 'mls_pid') EQ false){
	application.zcore.functions.z301Redirect('/');
}
if(structkeyexists(form, 'mls_id') and structkeyexists(application.zcore.app.getAppData("listing").sharedStruct.urlMLSIDStruct, form.mls_id)){
	form.mls_id=application.zcore.app.getAppData("listing").sharedStruct.urlMLSIDStruct[form.mls_id];
	form.listing_id=form.mls_id&'-'&form.mls_pid;
}
if(structkeyexists(form, 'mls_id') EQ false or structkeyexists(form, 'listing_id') EQ false){
	application.zcore.functions.z301Redirect('/');
}

propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
propertyDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
ts = StructNew();

// get select properties based on mls_id and listing_id
ps=StructNew();

hideSearchBar=true;
	ts.arrMLSPid=ArrayNew(1);
	ArrayAppend(ts.arrMLSPid, form.listing_id);
	ts.showInactive=true;

ts.perpage=1;
if(structkeyexists(form, 'showInactive')){
	ts.useMLSCopy=true;
	ts.showInactive=true;
}

returnStruct = propertyDataCom.getProperties(ts);

if(arrayLen(returnStruct.arrData) EQ 0){
	if(request.zos.isDeveloper){
		writeoutput("<h1>listing record is missing. (non-developers see 404 Not Found or 301 redirect)</h1>");
		writedump(returnStruct);
		application.zcore.functions.zabort();
	}
	if(application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_missing_listing_behavior',true, 1) EQ 1){
		application.zcore.functions.z404("listing record is missing.");
	}else{
		application.zcore.functions.z301Redirect('/');
	}
}else{
	structappend(form, returnStruct.arrData[1], true);
}
isOfficeListing=false;
try{
	if(request.zos.listing.site_x_mls_office_id EQ form.listing_office){
		isOfficeListing=true;
	}
}catch(Any excpt){}
idx=request.zos.listingMlsComObjects[form.mls_id].getDetails(returnStruct.arrData[1],1,true);
idx.listing_id=form.listing_id;
structappend(form, idx,true);
 
titleStruct = request.zos.listing.functions.zListinggetTitle(idx);

tempURL = '#request.zos.globals.siteroot#/#titleStruct.urlTitle#-#form.urlMLSId#-#form.urlMLSPId#.html';

if(structkeyexists(form, 'zurlname')){
	if(compare(form.zURLName,titleStruct.urlTitle) NEQ 0){
		if(hideSearchBar EQ false){
			if(structkeyexists(form, 'searchId')){
				tempURL = application.zcore.functions.zURLAppend(tempURL, 'searchId=#form.searchid#');
			}
			if(structkeyexists(form, 'zdIndex')){
				tempURL = application.zcore.functions.zURLAppend(tempURL, 'zdIndex=#zdIndex#');
			}
		}
 		application.zcore.functions.z301Redirect(tempURL);
	}
}else{
 	application.zcore.functions.z301Redirect(tempURL);
}
if(structkeyexists(form, 'zdIndex')){
	if(zdindex NEQ "" and isnumeric(zdindex) EQ false){
		application.zcore.functions.z301redirect('/');	
	}	
}
propertyLink = tempURL;
fullPropertyLink=application.zcore.functions.zURLAppend(propertyLink, 'searchId=#application.zcore.functions.zso(form, 'searchId')#&zdIndex=#application.zcore.functions.zso(form, 'zdIndex')#');
propertyLink=htmleditformat(propertyLink);
fullPropertyLink=htmleditformat(fullPropertyLink);
</cfscript>
<cfsavecontent variable="temp.pageNav">
	<a href="#request.zos.globals.siteroot#/">#request.zos.globals.homelinktext#</a> /
<cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_search',true) EQ 0>
<cfif hideSearchBar EQ false or structkeyexists(form, 'searchId')>
<cfelse>
	<a href="#request.zos.listing.functions.getSearchFormLink()#" class="zNoContentTransition">Property Search</a> /
	</cfif> 
</cfif>
</cfsavecontent> 
<cfscript>
	
application.zcore.template.setTag("title","#replace(titleStruct.title,'<br />','','ALL')#");
application.zcore.template.setTag("pagetitle",idx.listing_address&", "&idx.cityName&", "&idx.listing_state);
application.zcore.template.setTag("pagenav",temp.pageNav);
	
 
tempText = application.zcore.functions.zFixAbusiveCaps(form.listing_data_remarks);
tempText = rereplace(tempText, "<.*?>","","ALL");
theBegin = left(tempText, 100);
theEnd = mid(tempText, 101, len(tempText));
pos = find(' ', theEnd);
if(pos NEQ 0){
	theBegin=theBegin&left(theEnd, pos);
	theEnd=removeChars(theEnd, 1, pos);
}
</cfscript> 
<h3 class="zls-detail-random-title" style="opacity:0.7;">#titleStruct.title#</h3>
<cfif hideSearchBar EQ false>

	<cfscript>
	// required
	searchStruct = StructNew();
	// optional
	searchStruct.showString = "";
	// allows custom url formatting
	//searchStruct.parseURLVariables = true;
	searchStruct.indexName = 'zdIndex';
	searchStruct.url = application.zcore.functions.zURLAppend(propertyLink, 'searchId=#form.searchid#'); 
	searchStruct.buttons = 1;
	searchStruct.count = returnStruct.count;
	// set from query string or default value
	searchStruct.index = application.zcore.status.getField(form.searchid, "zdIndex",1);
	searchStruct.perpage = 1;
	searchStruct.returnDataOnly=true;
	navOutput=application.zcore.functions.zSearchResultsNav(searchStruct);
	</cfscript>
	<span class="search-nav">
	<div class="search-nav-l">
	<cfscript>
	for(i=1;i LTE ArrayLen(navOutput.arrData);i=i+1){
		if(navOutput.arrData[i].url EQ ''){
			writeoutput('<span class="search-nav-t">'&navOutput.textPosition&'</span>');
		}else{
			writeoutput('<a href="'&htmleditformat(navOutput.arrData[i].url)&'">'&navOutput.arrData[i].label&'</a>');
		}
	}
	</cfscript></div>
	</span>
</cfif>

<cfscript>
firstImageToShow=1;
</cfscript>

 
<cfscript> 
tempText = rereplace(form.listing_data_remarks, "<.*?>","","ALL");
fullTextBackup=tempText;
tempText = left(tempText, 240);
theEnd = mid(form.listing_data_remarks, 241, len(form.listing_data_remarks));
pos = find(' ', theEnd);
if(pos NEQ 0){
    tempText=tempText&left(theEnd, pos);
}
if(len(tempText) LT len(form.listing_data_remarks)){
	tempText&="...";	
}
tempText=application.zcore.functions.zFixAbusiveCaps(replace(tempText,",",", ","all"));
</cfscript>
<cfset priceChange=0>
<cfif form.listing_track_datetime NEQ "">
	<cfset priceChange=application.zcore.functions.zso(form, 'listing_track_price',true)-application.zcore.functions.zso(form, 'listing_track_price_change',true)>
</cfif>

 
 <cfscript>
 topRightColSize=max(275,request.zos.globals.maximagewidth-506);
 topLeftColSize=request.zos.globals.maximagewidth-topRightColSize;
 
 newTopHeight=round((342/506)*topLeftColSize);
 </cfscript>
 
 <div class="zls-detail-box">
     <div class="zls-detail-leftbox">
 
    <cfsavecontent variable="theJS">
{
pause_on_hover: true,
transition_speed: 1000,<!---  		//INT - duration of panel/frame transition (in milliseconds) --->
transition_interval: 3000,<!---  		//INT - delay between panel/frame transitions (in milliseconds) --->
easing: 'swing',<!---  				//STRING - easing method to use for animations (jQuery provides 'swing' or 'linear', more available with jQuery UI or Easing plugin) --->
panel_width: 800,
panel_height: 600,
<!--- show_panel_nav: false, --->
panel_animation: <cfif structkeyexists(form, 'zprint')>'none'<cfelse>'crossfade'</cfif>,<!---  		//STRING - animation method for panel transitions (crossfade,fade,slide,none) --->
panel_scale: 'fit',<!---  			//STRING - cropping option for panel images (crop = scale image and fit to aspect ratio determined by panel_width and panel_height, fit = scale image and preserve original aspect ratio) --->
overlay_position: 'bottom',<!---  	//STRING - position of panel overlay (bottom, top) --->
pan_images: true,<!--- 				//BOOLEAN - flag to allow user to grab/drag oversized images within gallery --->
pan_style: 'track',<!--- 				//STRING - panning method (drag = user clicks and drags image to pan, track = image automatically pans based on mouse position --->
pan_smoothness: 15,<!--- 				//INT - determines smoothness of tracking pan animation (higher number = smoother) --->
start_frame: 1,<!---  				//INT - index of panel/frame to show first when gallery loads --->
show_filmstrip: true,<!---  			//BOOLEAN - flag to show or hide filmstrip portion of gallery --->
show_filmstrip_nav: true,<!---  		//BOOLEAN - flag indicating whether to display navigation buttons --->
enable_slideshow: <cfif structkeyexists(form, 'zprint')>false<cfelse>true</cfif>,<!--- 			//BOOLEAN - flag indicating whether to display slideshow play/pause button --->
autoplay: <cfif structkeyexists(form, 'zprint')>false<cfelse>true</cfif>,<!--- 				//BOOLEAN - flag to start slideshow on gallery load --->
show_captions: false,<!---  			//BOOLEAN - flag to show or hide frame captions	 --->
filmstrip_size: 3,<!---  				//INT - number of frames to show in filmstrip-only gallery --->
filmstrip_style: 'scroll',<!---  		//STRING - type of filmstrip to use (scroll = display one line of frames, scroll filmstrip if necessary, showall = display multiple rows of frames if necessary) --->
filmstrip_position: 'bottom',<!---  	//STRING - position of filmstrip within gallery (bottom, top, left, right) --->
frame_width: 80,<!---  				//INT - width of filmstrip frames (in pixels) --->
frame_height: 50,<!---  				//INT - width of filmstrip frames (in pixels)isDefined('') --->
frame_opacity: 0.5,<!---  			//FLOAT - transparency of non-active frames (1.0 = opaque, 0.0 = transparent) --->
frame_scale: 'crop',<!---  			//STRING - cropping option for filmstrip images (same as above) --->
frame_gap: 5,<!---  					//INT - spacing between frames within filmstrip (in pixels) --->
show_infobar: false,<!--- 				//BOOLEAN - flag to show or hide infobar --->
infobar_opacity: 1<!--- 				//FLOAT - transparency for info bar --->
}
    </cfsavecontent>
    <input type="hidden" name="zGalleryViewSlideshow1_data" id="zGalleryViewSlideshow1_data" value="#htmleditformat(theJS)#" /> 
	<div class="zGalleryViewSlideshowContainer">
		<ul id="zGalleryViewSlideshow1" class="zGalleryViewSlideshow">
		<cfset hasPhotos=false>
		<cfloop from="1" to="#form.listing_photocount#" index="i">
			<cfif structkeyexists(idx,'photo'&i)>
				<cfset hasPhotos=true>
				<cfset curPhoto=application.zcore.listingCom.getThumbnail(idx['photo'&i], request.lastPhotoId, i, 10000, 10000, 0)> 
				<li><img id="zmlslistingphoto#i#" data-frame="#curPhoto#" src="#curPhoto#" alt="<cfif structkeyexists(idx, 'photo_description'&i)>
					#htmleditformat(idx['photo_description'&i])#<cfelse>Listing Photo #i#</cfif>" />
				</li>
			</cfif>
		</cfloop>
		</ul>
	</div>
	<div class="zls-view-larger-div">
		<cfloop from="1" to="#form.listing_photocount#" index="i">
			<cfif structkeyexists(idx,'photo'&i)>
				<a href="#idx["photo"&i]#"  data-ajax="false" title="" rel="placeImageColorbox" class="zNoContentTransition placeImageColorbox">View larger images</a><br />
			</cfif>
		</cfloop>
	</div>
</div>

     <div class="zls-detail-rightbox">
<cfif form.listing_price NEQ "" and form.listing_price NEQ "0"><div class="zdetail-price">$#numberformat(form.listing_price)#</div> <cfif form.listing_price LT 20> per sqft</cfif></cfif><cfif idx.pricepersqft NEQ "" and idx.pricepersqft NEQ 0><br /><div class="zdetail-pricesqft">($#numberformat(idx.pricepersqft)#/sqft)</div></cfif>
<br /><div class="zdetail-liststatus">List Status: #form.listingListStatus#</div>

<div class="zls-detail-address">
#form.listing_data_address#<br />
#form.cityName#, #form.listing_state# #form.listing_data_zip#</div><br /><br />
<div class="zls-detail-toplist">
<cfif form.listingstatus EQ "for rent">For Rent/Lease<cfelseif idx.listingPropertyType NEQ 'rental'>#idx.listingPropertyType# For Sale<cfelse>Rental</cfif><br />
<cfif form.listing_beds NEQ 0>#form.listing_beds# beds<br /></cfif>
<cfif form.listing_baths NEQ 0>#form.listing_baths# baths<br /></cfif><cfif form.listing_halfbaths NEQ 0>#application.zcore.functions.zso(form,'listing_halfbaths',true)# half baths<br /></cfif><cfif form.listing_square_feet neq '0' and form.listing_square_feet neq ''>#form.listing_square_feet# living sqft<br /></cfif>
</div>

<div class="zls-detail-askquestion"><a href="##" onclick="zShowModalStandard('/z/listing/inquiry/index?action=form&amp;modalpopforced=1&amp;listing_id=#form.listing_id#', 540, 630);return false;" rel="nofollow">Ask A Question</a></div>
 
<div class="zls-detail-toplinks">
<cfif form.virtualtoururl neq '' and (findnocase("https://", form.virtualtoururl) NEQ 0 or findnocase("http://", form.virtualtoururl) NEQ 0)> 
	<a href="#application.zcore.functions.zBlockURL(form.virtualtoururl)#" rel="nofollow" target="_blank">Virtual Tour</a></cfif>
<a href="##" class="zls-saveListingButton" data-listing-id="#form.listing_id#" rel="nofollow" class="zNoContentTransition">Save Listing</a>

<cfif application.zcore.functions.zvar('enableSendToFriend', request.zos.globals.id) EQ 1>
	
	<a href="##" onclick="zShowModalStandard('/z/misc/share-with-friend/index?title=#htmleditformat(urlencodedformat(application.zcore.template.getTagContent('pagetitle')))#&amp;link=#htmleditformat(urlencodedformat(request.zos.currenthostname&propertyLink))#', 540, 630);return false;" rel="nofollow">Share With Friend</a>
</cfif>

<a href="/z/misc/mortgage-calculator/index<cfif form.listing_price NEQ 0>?mloan=#form.listing_price#</cfif>">Mortgage Calculator</a>
<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 0 and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_enable_mortgage_quote',true,1) EQ 1>
<a href="##" onclick="zShowModalStandard('/z/misc/mortgage-quote/index?modalpopforced=1', 540, 630);return false;" rel="nofollow">Get Pre-Qualified</a>
</cfif>
<a href="#application.zcore.functions.zBlockURL(application.zcore.functions.zURLAppend(propertyLink,"zprint=1"))#" rel="nofollow" onclick="window.open(this.href); return false;">Print Listing</a>
</div>
     </div>
 </div>
 
 <div class="zls-detail-box">
 
 <cfscript>
 rightColSize=max(274,request.zos.globals.maximagewidth-446);
 leftColSize=request.zos.globals.maximagewidth-rightColSize-6;
 </cfscript>
 
     <div class="zls-detail-leftbox">
         <div class="zls-detail-box">
<div class="zls-detail-subheading">Top Features</div>
         <div class="zls-detail-box">

<ul><cfscript>
   /* if(priceChange GT 0){
        writeoutput('<li class="zPriceChangeMessage">Price reduced $#numberformat(pricechange)# since #dateformat(form.listing_track_datetime,'m/d/yy')#, NOW $#numberformat(form.listing_price)#</li>'); 	
    }else if(priceChange LT 0){
        writeoutput('<li class="zPriceChangeMessage">Price increased $#numberformat(abs(pricechange))# since #dateformat(form.listing_track_datetime,'m/d/yy')#, NOW #numberformat(form.listing_price)#</li>');
    }*/
    </cfscript>
<cfif form.listingFrontage NEQ ""><li class="zls-top-feature-frontage">Frontage: #form.listingFrontage#</li></cfif>
<cfif form.listingView NEQ ""><li>View: #form.listingView#</li></cfif>
<cfif form.listing_pool EQ 1><li>Has a pool</li></cfif>
<cfif form.listing_subdivision neq ''><li>Subdivision:&nbsp;#htmleditformat(form.listing_subdivision)#</li></cfif>
<cfif form.listing_lot_square_feet neq '0' and form.listing_lot_square_feet neq ''><li>Lot SQFT: #form.listing_lot_square_feet# sqft (#htmleditformat(round(form.listing_lot_square_feet/10.7639))#m&##178;)</li></cfif>
<cfif form.listing_year_built NEQ ""><li>Built in &nbsp;#form.listing_year_built#</li></cfif>
<cfif form.listingStyle NEQ ""><li>Style: #form.listingStyle#</li></cfif>
<cfif form.maintfees NEQ "" and form.maintfees NEQ 0><li>Maint Fees: $#numberformat(form.maintfees)#</li></cfif>
<cfscript>
if(form.listing_sub_type_id NEQ "" and form.listing_sub_type_id NEQ 0){
	var  arrD=listtoarray(form.listing_sub_type_id); 
	var arrD2=[];
	for(i=1;i LTE arraylen(arrD);i++){
		local.label=application.zcore.listingCom.listingLookupValue("listing_sub_type",arrD[i]);
		if(local.label NEQ ""){
			arrayappend(arrD2, local.label);
		}
	}
	if(arrayToList(arrD2, ", ") NEQ ""){
		writeoutput('<li>'&arrayToList(arrD2, ", ")&'</li>');
	}
}
</cfscript>
</ul>
</div>
</div>
         <div class="zls-detail-box">
         <div class="zls-detail-subheading">Description</div>
         MLS ###listgetat(form.listing_id,2,'-')# Source: #idx.listingSource#<br />
         <cfscript>
                writeoutput(htmleditformat(fullTextBackup));
            </cfscript>
         </div>
         
         <div class="zls-detail-box">
         <div class="zls-detail-subheading">Property Details</div>
#idx.details#

         </div>
         
<cfif trim(idx.features) NEQ "">
         <div class="zls-detail-box"><table class="ztablepropertyinfo">#idx.features#</table>
         </div>
     </cfif>
     
     
     </div>
     <div class="zls-detail-rightbox"> 
     <cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_email_listing_agent_only', true, 0) EQ 1>
		<h2>Contact Listing Agent</h2>
		<p>Please mention mls ###listGetAt(form.listing_id, 2, "-")#
		<h3>#form.agentName#</h3>

		<cfif application.zcore.functions.zso(form, 'agentPhoto') NEQ "">
			<p><img src="#form.agentPhoto#" alt=""></p>
		</cfif>

		<cfif form.officeName NEQ "">
			<p>#form.officeName#</p>
		</cfif>
		<cfif form.agentPhone NEQ "">
			<p>Agent Phone: #form.agentPhone#</p>
		</cfif>
		<cfif form.officePhone NEQ "">
			<p>Office Phone: #form.officePhone#</p>
		</cfif>
		<cfif form.agentEmail NEQ "">
			<p>Email: #application.zcore.functions.zEncodeEmail(form.agentEmail, true, form.agentEmail)#</p>
		</cfif>
	</cfif>

<cfscript>
tempAgent=form.listing_agent;
agentStruct=application.zcore.app.getAppCFC("listing").getAgentDataByAgentId(form.mls_id, form.listing_agent);
</cfscript>
<cfif agentStruct.success> 
    <div class="zls-detail-box"> 
		<div class="zls-detail-subheading">LISTING AGENT</div><br />
		<cfif agentStruct.tempData.photo NEQ "">
		<div style="width:105px; float:left;">
		<img src="#agentStruct.tempData.photo#" alt="Listing Agent" width="90"/><br />
		</div>
		</cfif>
		<cfif agentStruct.data.member_first_name NEQ ''>#agentStruct.data.member_first_name#</cfif> <cfif agentStruct.data.member_last_name NEQ ''>#agentStruct.data.member_last_name#<br /></cfif>
		<cfif agentStruct.data.member_phone NEQ ''><strong>#agentStruct.data.member_phone#</strong><br /></cfif>
		<cfif agentStruct.tempData.profileURL NEQ "">
			<a href="#agentStruct.tempData.profileURL#" target="_blank">Bio &amp; Listings</a>
		</cfif>
	</div>
</cfif> 
         <div class="zls-makeOfferBox zls-detail-box">
<div class="" style="border:1px solid ##666; float:left; padding:3.2%; width:93%;">
<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_rentals_only EQ 0>

<cfscript>
message1=application.zcore.functions.zVarSO("Listing: Sales Message 1");
message2=application.zcore.functions.zVarSO("Listing: Sales Message 2");
message3=application.zcore.functions.zVarSO("Listing: Sales Message 3");
message4=application.zcore.functions.zVarSO("Listing: Email Text",request.zos.globals.id,true);
</cfscript>
<span style="font-size:14px; font-weight:bold; line-height:18px;"><cfif message1 NEQ "">#message1#<cfelse>We are experts at price negotiation:</cfif><br />
<a href="##" onclick="zShowModalStandard('/z/listing/inquiry/index?action=form&amp;modalpopforced=1&amp;listing_id=#form.listing_id#&amp;inquiries_comments=<cfif message4 NEQ "">#URLEncodedformat(message4)#<cfelse>I%27d%20like%20to%20make%20an%20offer%20of%20%24</cfif>', 540, 630);return false;" rel="nofollow"><cfif message2 NEQ "">#message2#<cfelse>MAKE AN OFFER and we'll help you save thousands</cfif></a></span><br />

<cfif message3 NEQ "">#message3#<cfelse>We work hard to quickly narrow the thousands of properties down to just a select few that meet your family's needs.  Our services are paid for by the seller.  We represent your best interests on every transaction to make sure home is safe, more financially sound and in the right neighborhood for your lifestyle. <strong><a href="/z/misc/inquiry/index">Contact Us</a></strong> to learn how we can work for you.<br /></cfif>

</cfif>

<cfif form.listing_track_datetime NEQ "">
<div id="zls-list-date-detail">
This listing was first listed on this web site on #dateformat(form.listing_track_datetime,'mmmm d, yyyy')# and it was last updated on #dateformat(form.listing_track_updated_datetime,'mmmm d, yyyy')#<br />
</div>
</cfif>

	<cfif form.listingHasMap and application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_enable_walkscore',true,1) EQ 1>
<div style="width:100%; font-size:18px; margin-bottom:10px; margin-top:10px;" id="walkscore-div"><a href="##" onclick="zAjaxWalkscore({'latitude':'#form.listing_latitude#','longitude':'#form.listing_longitude#'}); return false;" title="Walk Score measures how walkable an address is based on the distance to nearby amenities. A score of 100 represents the most walkable area compared to other areas.">View Walkscore</a></div>
</cfif>
<span style="font-size:80%;">Source: #request.zos.globals.shortdomain#</span>
</div>
</div>

	<cfif form.listingHasMap>
        <div class="zls-detail-box">
        
			<a id="googlemap"></a>
			<div class="zls-detail-subheading">Neighborhood Map</div>
				<cfscript>
				mapStageStruct=StructNew();
				mapStageStruct.width=rightColSize-20;
				mapStageStruct.height=300;
				mapStageStruct.fullscreen.width=770;
				mapStageStruct.fullscreen.height=300;
				mapQuery=returnStruct;
				hideMapControls=true;
				</cfscript>
			    <cfsavecontent variable="mapHTML"><table style="width:280px;"><tr><td><cfscript>propertyDisplayCom.mapTemplate(idx, 1);</cfscript></td></tr></table></cfsavecontent>
			    
			    <cfscript>
				mapStageStruct.arrMapTotalLat=listtoarray(form.listing_latitude);
				mapStageStruct.arrMapTotalLong=listtoarray(form.listing_longitude);
				mapStageStruct.arrMapText=arraynew(1);
				arrayappend(mapStageStruct.arrMapText, "#(mapHTML)#");
				</cfscript>
				<!---  <script type="text/javascript">
				/* <![CDATA[ */
				zArrDeferredFunctions.push(function(){
				 zMapCount++;
				zArrMapTotalLat.push(#form.listing_latitude#);
				zArrMapTotalLong.push(#form.listing_longitude#);
				zArrMapText.push("#jsstringformat(mapHTML)#");
				});
				/* ]]> */
				</script> --->
			        <cfscript>
					ms={
						mapQuery=mapQuery,
						mapStageStruct=mapStageStruct,
						listing_latitude=form.listing_latitude,
						listing_longitude=form.listing_longitude,
						listing_data_address=form.listing_data_address,
						listing_data_zip=form.listing_data_zip,
						cityName=form.cityName,
						hideMapControls=hideMapControls	
					}
					tempCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.listing.controller.map");
					tempCom.index(ms);
					</cfscript><br style="clear:both;" />

		        </div>
			</cfif>
		</div>
     </div>
 
     <div class="zls-detail-box">
         <div class="zls-detail-subheading">Property Photos</div>
         <cfscript>
		 if(structkeyexists(idx,'photowidth')){
			 nw=idx.photowidth;
			 nh=idx.photoheight;
		 }else{
			 nw=round((1200-65)/3);
			 nh=round(nw*0.68);
		 }
		 </cfscript>
		 <div class="z-float z-equal-heights" data-column-count="3">
			<cfloop from="1" to="#form.listing_photocount#" index="i">
			<cfif structkeyexists(idx,'photo'&i)>
			<div class="z-preserve-ratio" data-ratio="4:3" style="width:32%; min-width:150px; float:left; overflow:hidden; margin-right:1%; margin-bottom:2%;">
			#application.zcore.functions.zLoadAndCropImage({id:"zmlslistingphoto2_#i#",width:nw,height:nh, url:idx['photo'&i], style:"margin-bottom:5px; clear:both; width:100%; max-width:#request.zos.globals.maximagewidth#px;", canvasStyle:"", crop:false})#
			</div>
			</cfif>
			</cfloop>
		</div>
     </div>
 
 

<cfsavecontent variable="metacontent">
<cfscript>
metaKey=rereplacenocase(titleStruct.title&" "&idx.features,"<.*?>"," ","ALL");
</cfscript>
<link rel="canonical" href="#request.zos.currentHostName##propertyLink#" />
<cfif application.zcore.functions.zso(application.zcore.app.getAppData("listing").sharedStruct.optionStruct, 'mls_option_disable_detail_indexing',true,0) EQ 1 or structkeyexists(form, 'zprint')>
<meta name="robots" content="noindex,nofollow,noarchive" />
</cfif>
<meta name="keywords" content="#htmleditformat(metaKey)#" />
<meta name="description" content="#htmleditformat(titleStruct.listing_x_site_description)#" />
<cfif structkeyexists(form, 'zprint')>
<style type="text/css">
body{background:none !important;}
body, table{ background-color:##FFF !important; color:##000;}
a:link, a:visited{ color:##369; }
.zls-detail-box, h1,h2,h3, a:link, a:visited{color:##000 !important;}
.zls-detail-askquestion a:link, .zls-detail-askquestion a:visited, .zls-detail-toplinks a:link, .zls-detail-toplinks a:visited{ background-color:##FFF !important;}
.table-list th, .table-list-header, th{ background-color:##FFF !important; color:##000 !important;}
</style>
</cfif>
</cfsavecontent>
<cfscript>
application.zcore.template.setTag("meta",metacontent);
if(structkeyexists(form, 'zprint')){
	application.zcore.template.setTemplate("zcorerootmapping.templates.simple",true,true);	
}
</cfscript>
	
    
<cfif structkeyexists(idx, 'officeName')>
	<cfif application.zcore.app.getAppData("listing").sharedStruct.optionStruct.mls_option_compliantIDX EQ 1>
        <div class="zls-detail-box">Listing courtesy of #idx.officeName#</div> <br />
    <cfelse>
		<cfscript>
        application.zcore.template.setTag('listoffice','listing courtesy of #idx.officeName#');
        </cfscript>
    </cfif>
</cfif>


<cfscript>
local.rs=request.zos.listing.functions.getSimilarListings(idx);
 
if(local.rs.count){
	writeoutput('<div style="border-top:1px solid ##666; padding-top:20px; float:left; width:100%;">
	<h2>Similar Listings</h2>
	#local.rs.output#');
	if(local.rs.moreLink NEQ ""){
		writeoutput('<div style="width:100%; float:left; font-size:130%; clear:both; padding-bottom:10px; font-weight:bold;"><a href="#htmleditformat(local.rs.moreLink)#">View More Similar Listings &gt;</a></div>');
	}
	writeoutput('</div>');
}
</cfscript>
<cfif structkeyexists(form, 'zprint')>
</div>
<script type="text/javascript">
zArrDeferredFunctions.push(function(){ zListingSearchJsToolHide(); setTimeout(function(){window.print(); },1000); });
</script>
</cfif>
</cffunction>
</cfoutput>
</cfcomponent>