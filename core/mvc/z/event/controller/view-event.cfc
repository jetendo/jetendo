<cfcomponent>
<cfoutput>

<cffunction name="encodeForVCalendar" localmode="modern" access="public">
	<cfargument name="s" type="string" required="yes">
	<cfscript>
	s=arguments.s;
	/*
	s=replace(s, chr(10), "\u005E\u006E", "all");
	s=replace(s, chr(13), "", "all");
	s=replace(s, "^", "\u005E\u005E", "all");
	s=replace(s, '"', "\u005E\u0027", "all");*/
	s=replace(s, chr(10), "\n", "all"); 
	s=replace(s, chr(13), "", "all"); 
	//s=wrap(s,62);
	return s;
	</cfscript>
</cffunction>	

<cffunction name="download" localmode="modern" access="remote">
	<cfscript>
	form.event_id=application.zcore.functions.zso(form, "event_id", true);
	form.event_recur_id=application.zcore.functions.zso(form, "event_recur_id", true);
	//echo(encodeForVCalendar("Test"" \\ing ^with caret and break#chr(10)#break"));abort;
	ts={};
	if(form.event_recur_id NEQ 0){
		ts.event_recur_id=form.event_recur_id;
	}
	ts.onlyFutureEvents=false;
	ts.perpage=1;
	if(application.zcore.user.checkGroupAccess("member")){
		ts.showInactive=true;
	} 
	eventCom=application.zcore.app.getAppCFC("event");
	rs=eventCom.searchEvents(ts);  
	if(rs.count NEQ 1){
		application.zcore.functions.z404("Event, #form.event_id#, is missing");
	}
	row=rs.arrData[1];
	actualLink=eventCom.getEventRecurURL(row); 
	address="";
	if(row.event_location NEQ ""){
		address&=row.event_location;
	}
	if(row.event_address NEQ ""){
		if(address NEQ ""){
			address&=", ";
		}
		address&=row.event_address;
	}
	if(row.event_city NEQ ""){
		if(address NEQ ""){
			address&=", ";
		}
		address&=row.event_city&" ";
	}
	if(row.event_state NEQ ""){
		address&=row.event_state&" ";
	}
	if(row.event_zip NEQ ""){
		address&=row.event_zip&" ";
	}
	if(row.event_country NEQ ""){
		address&=row.event_country;
	}
	
	tz=gettimezoneinfo(); 
	updatedDate=DateAdd("h", tz.utcHourOffset, row.event_updated_datetime);
	startDate=DateAdd("h", tz.utcHourOffset, row.event_recur_start_datetime);
	endDate=DateAdd("h", tz.utcHourOffset, row.event_recur_end_datetime);

	savecontent variable="out"{
		echo('BEGIN:VCALENDAR#chr(10)#');
		echo('PRODID:website');
		echo('VERSION:2.0#chr(10)#');
		echo('BEGIN:VEVENT#chr(10)#');
		echo('DTSTAMP:#dateformat(updatedDate,'yyyymmdd')&"T"&timeformat(updatedDate, "HHmmss")&"Z"##chr(10)#');
		echo('DTSTART:#dateformat(startDate,'yyyymmdd')&"T"&timeformat(startDate, "HHmmss")&"Z"##chr(10)#');
		echo('DTEND:#dateformat(endDate,'yyyymmdd')&"T"&timeformat(endDate, "HHmmss")&"Z"##chr(10)#');
		echo('LOCATION:#encodeForVCalendar(address)##chr(10)#');
		echo('DESCRIPTION:#encodeForVCalendar(application.zcore.functions.zRemoveHTMLForSearchIndexer(row.event_description))##chr(10)#');
		echo('SUMMARY:#encodeForVCalendar(row.event_name)##chr(10)#');
		echo('PRIORITY:3#chr(10)#');
		echo('UID:#application.zcore.functions.zURLEncode(request.zos.globals.domain, "-")&"-"&row.event_id&"-"&row.event_recur_id#');
		echo('END:VEVENT#chr(10)#');
		echo('END:VCALENDAR#chr(10)#');
	}

	header name="Content-Disposition"  value="attachment;filename=#Replace(replace("Event-#row.event_id#-#application.zcore.functions.zURLEncode(row.event_name, "-")#", ",", " ", "all"), " ",  "_", "all")#.ics";
	application.zcore.functions.zHeader("Content-Type", "text/calendar");
	echo(out);
	abort;
	</cfscript>
</cffunction>

<cffunction name="displayEvent" localmode="modern" access="private">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	request.zos.currentURLISAnEventPage=true;
	if(application.zcore.functions.zso(form, 'nextOccurrence', true) NEQ 0){
		structdelete(form, 'nextOccurrence');
		//writedump('test');abort;
		viewNextRecurringEvent();
		return;
	}
	if(application.zcore.functions.zso(form, 'recurId', true) NEQ 0){ 
		form.event_recur_id=form.recurId;
		structdelete(form, 'recurId');
		viewRecurringEvent();
		return;
	}
	db=request.zos.queryObject;
	struct=arguments.struct;

	if(struct.event_status EQ 0){
		application.zcore.template.prependTag("content", '<div class="zEventView-preview-message">This event is not active. The public can''t view it until it is made active.</div>');
	}
	eventCom=application.zcore.app.getAppCFC("event");
	//writedump(struct);
 	eventCalendarId=listGetAt(struct.event_calendar_id, 1);
	db.sql="SELECT * FROM #db.table("event_calendar", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	event_calendar_deleted=#db.param(0)# and 
	event_calendar_id = #db.param(eventCalendarId)# ";
	qCalendar=db.execute("qCalendar");

	calendarLink="##";
	for(row in qCalendar){
		calendarLink=eventCom.getCalendarURL(row);
	}


	writeoutput('<div style="display:block; float:left; width:100%;"  id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit zEditorHTML" data-editurl="/z/event/admin/manage-events/edit?event_id=#struct.event_id#&amp;returnURL=#request.zos.originalURL#">'); 
	application.zcore.template.prependTag('pagetitle','<span style="display:inline;" id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit" data-editurl="/z/event/admin/manage-events/edit?event_id=#struct.event_id#&amp;returnURL=#request.zos.originalURL#">');
	application.zcore.template.appendTag('pagetitle','</span>');  

	</cfscript>  


	
	<cfif structkeyexists(form, 'print')>
		<cfsavecontent variable="local.metaOutput">
		<style>
		/* <![CDATA[ */
		.zEventView-share{display:none;}
		.zEventView-buttons{display:none;}
		.zEventView1-3{float:none;}
		.zEventView1-container{float:none;}
		
		/* ]]> */
		</style>
		</cfsavecontent>
		<cfscript>
		application.zcore.template.setPlainTemplate();
		request.zos.template.appendTag("stylesheets", local.metaOutput);
		if(struct.event_address EQ ""){
			application.zcore.skin.addDeferredScript("window.print(); ");
		}
		</cfscript>
	</cfif>  
	<cfsavecontent variable="scriptOutput">
		<cfscript>
		application.zcore.functions.zRequireGoogleMaps();
		</cfscript> 
		<script>
		/* <![CDATA[ */
		var printNow=false;
		<cfif structkeyexists(form, 'print')>
			printNow=true;
		</cfif>
		function zEventMapSuccessCallback(){
			$("##zEventViewMapContainer").show();

			if(printNow){
				setTimeout(function(){
					window.print();
				}, 2000);
			}
		}
		zArrMapFunctions.push(function(){
			//$("##zEventSlideshowDiv").cycle({timeout:3000, speed:1200});
			//$( "##startdate" ).datepicker();
			//$( "##enddate" ).datepicker();
			<cfif struct.event_address NEQ "">
				var optionsObj={ zoom: 13 };
				var markerObj={
					infoWindowHTML:'<a href="https://maps.google.com/maps?q=#urlencodedformat(struct.event_address&", "&struct.event_city&", "&struct.event_state&" "&struct.event_zip&" "&struct.event_country)#" target="_blank">Get Directions on Google Maps</a>'
				};
				<cfif struct.event_map_coordinates NEQ "">
					arrLatLng=[#struct.event_map_coordinates#]; 
					zCreateMapWithLatLng("zEventMapDivId", arrLatLng[0], arrLatLng[1], optionsObj, zEventMapSuccessCallback, markerObj);  
				<cfelse>
					zCreateMapWithAddress("zEventMapDivId", "#jsstringformat(struct.event_address&', '&struct.event_city&", "&struct.event_state&" "&struct.event_zip&" "&application.zcore.functions.zCountryAbbrToFullName(struct.event_country))#", optionsObj, zEventMapSuccessCallback); 
				</cfif>
			</cfif> 
		});
		/* ]]> */
		</script> 
	</cfsavecontent>
	<cfscript>
	request.zos.template.appendTag("meta", scriptOutput); 

	application.zcore.template.setTag("meta", '<meta name="Keywords" content="#htmleditformat(struct.event_metakey)#" /><meta name="Description" content="#htmleditformat(struct.event_metadesc)#" />');
	if(struct.event_metatitle NEQ ""){
		application.zcore.template.setTag( "title", struct.event_metatitle);
	}else{
		request.zos.template.setTag("title", struct.event_name);
	}
	request.zos.template.setTag("pagetitle", struct.event_name);

	countryName=application.zcore.functions.zCountryAbbrToFullName(struct.event_country);

	</cfscript>
	<!--- <cfsavecontent variable="request.eventsSidebarHTML">#local.eventsCom.calendarSidebar()#</cfsavecontent>  --->
	

	<div class="zEventView1-4">
		<div class="zEventView1-1">Date:</div>
		<div class="zEventView1-2">
		#eventCom.getDateTimeRangeString(struct)# 
		</div>
	</div>

	<cfscript>

	savecontent variable="slideShowOut"{
		echo('<div class="zEventView1-3">');
		ts=structnew();
		ts.output=true;
		ts.size=request.zos.globals.maximagewidth&"x"&(request.zos.globals.maximagewidth*.6);
		ts.image_library_id=struct.event_image_library_id;
		ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(struct.event_image_library_layout);
		ts.forceSize=true; 
		ts.crop=0;
		ts.offset=0;
		ts.limit=0;  
		if(application.zcore.imageLibraryCom.isBottomLayoutType(struct.event_image_library_layout)){
			ts.top=false;
		}else{
			ts.top=true;
		}
		arrImage=request.zos.imageLibraryCom.displayImages(ts);  
		ts.layoutType="";
		ts.output=false;
		ts.size="1900x1080";
		arrImage2=request.zos.imageLibraryCom.displayImages(ts); 
		echo('<div id="zEventViewLightGallery" class="zEventView1-larger">  ');
		for(i=1;i LTE arraylen(arrImage2);i++){
			echo('<a href="#arrImage2[i].link#" title="Image #i#" onclick="return false;" ');
			if(i NEQ 1){
				echo('style="display:none;"');
			}
			echo('>View larger images</a>');
		}
		echo('</div>');
		application.zcore.functions.zSetupLightbox("zEventViewLightGallery"); 
		echo('</div>');
	}
	if(application.zcore.imageLibraryCom.isBottomLayoutType(struct.event_image_library_layout)){
		slideshowOutBottom=slideshowOut;
		slideshowOutTop="";
	}else{
		slideshowOutTop=slideshowOut;
		slideshowOutBottom="";
	}
	</cfscript>
	 
	#slideshowOutTop# 
	<div class="zEventView1-container">
		<cfif struct.event_description NEQ "">
	
			<div class="zEventView1-3">
				<h2>Event Description</h2>
				#struct.event_description#
			</div>
		</cfif>
		<div class="zEventView1-3">
			<cfif struct.event_address NEQ "">
				<div class="zEventView1-0">
					<div class="zEventView1-1">Location:</div>
					<div class="zEventView1-2">
						<cfif struct.event_location NEQ "">
							#struct.event_location#<br />
						</cfif>
						#htmleditformat(struct.event_address)#<br />
						#struct.event_city#

						#htmleditformat(struct.event_state&" "&struct.event_zip)# 
						<cfif struct.event_country NEQ "US">
							#countryName#
						</cfif>
					</div>
				</div>
			</cfif> 
			<cfif struct.event_phone NEQ "">
				<div class="zEventView1-0">
					<div class="zEventView1-1">Phone:</div>
					<div class="zEventView1-2"><a class="zPhoneLink">#htmleditformat(struct.event_phone)#</a></div>
				</div>
			</cfif>
			<cfif left(struct.event_website, 7) EQ "http://" or left(struct.event_website, 8) EQ "https://">
				<div class="zEventView1-0">
					<div class="zEventView1-1">Website:</div>
					<div class="zEventView1-2"><a href="#htmleditformat(struct.event_website)#" target="_blank">#htmleditformat(struct.event_website)#</a></div>
				</div>
			</cfif>
			<cfif struct.event_file1 NEQ "" or struct.event_file2 NEQ "">
				<div class="zEventView1-0">
					<div class="zEventView1-1">Download Files:</div>
					<div class="zEventView1-2">
						<cfif struct.event_file1 NEQ "">
							<a href="#htmleditformat("/zupload/event/"&struct.event_file1)#" target="_blank">
								<cfif struct.event_file1label NEQ "">
									#struct.event_file1label#
								<cfelse>
									File 1
								</cfif>
							</a>
						</cfif>
						<cfif struct.event_file2 NEQ "">
							<br /><a href="#htmleditformat("/zupload/event/"&struct.event_file2)#" target="_blank">
								<cfif struct.event_file2label NEQ "">
									#struct.event_file2label#
								<cfelse>
									File 2
								</cfif>
							</a>
						</cfif>
					</div>
				</div>
			</cfif> 
			<div class="zEventView1-0 zEventView-share">
				<div class="zEventView1-1">Share:</div>
				<div class="zEventView1-2"> 
					<div class="z-float">
						<cfif request.zos.globals.enableSendTOFriend>
							<a href="##"  data-ajax="false" onclick="zShowModalStandard('/z/misc/share-with-friend/index?title=#urlencodedformat(struct.event_name)#&amp;link=#urlencodedformat(request.zos.currentHostName&struct.__url)#', 540, 630);return false;" rel="nofollow" style="display:block; float:left; margin-right:10px;"><img src="/z/images/event/share_03.jpg" alt="Share by email" width="30" height="30" /></a>
						</cfif>
						<a href="https://www.facebook.com/sharer/sharer.php?u=#urlencodedformat(request.zos.currentHostName&struct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/event/share_05.jpg" alt="Share on facebook" width="30" height="30" /></a>
						<a href="https://twitter.com/share?url=#urlencodedformat(request.zos.currentHostName&struct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/event/share_07.jpg" alt="Share on twitter" width="30" height="30" /></a>
						<a href="http://www.linkedin.com/shareArticle?mini=true&amp;url=#urlencodedformat(request.zos.currentHostName&struct.__url)#&amp;title=#urlencodedformat(struct.event_name)#&amp;summary=&amp;source=#urlencodedformat(request.zos.globals.shortDomain)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/event/share_09.jpg" alt="Share on linkedin" width="30" height="30" /></a> 
						<a href="#request.zos.originalURL#?print=1" target="_blank" class="zEventView1-print" rel="nofollow">Print</a>
					</div>
					<div class="z-float">
						<a href="/z/event/view-event/download?event_id=#struct.event_id#&event_recur_id=#struct.event_recur_id#" target="_blank"  title="Open the download file to add this event to your email software's calendar" class="zEventView1-print" style="margin-right:5px; margin-bottom:5px;">Add To My Calendar</a>

						<cfscript>
						
						tz=gettimezoneinfo(); 
						updatedDate=DateAdd("h", tz.utcHourOffset, struct.event_updated_datetime);
						startDate=DateAdd("h", tz.utcHourOffset, struct.event_recur_start_datetime);
						endDate=DateAdd("h", tz.utcHourOffset, struct.event_recur_end_datetime);
 
						startDateConverted=dateformat(startDate,'yyyymmdd')&"T"&timeformat(startDate, "HHmmss")&"Z";
						endDateConverted=dateformat(endDate,'yyyymmdd')&"T"&timeformat(endDate, "HHmmss")&"Z";
						</cfscript>
						<a href="https://www.google.com/calendar/render?action=TEMPLATE&text=#urlencodedformat(struct.event_name)#&dates=#startDateConverted#/#endDateConverted#&details=For+details,+click+here:+#request.zos.globals.domain##request.zos.originalURL#&sf=true&output=xml" target="_blank"  title="Open the download file to add this event to your email software's calendar" class="zEventView1-print">Add To Google Calendar</a>



					</div>
				</div>
			</div>

			<!--- <cfif application.zcore.functions.zso(application.zcore.app.getAppData("event").optionStruct, 'event_config_add_to_calendar_enabled') EQ "1">
				<cfscript>
				application.zcore.skin.includeJS("//addthisevent.com/libs/1.6.0/ate.min.js");
				arrLocation=[];
				if(struct.event_location NEQ ""){
					arrayAppend(arrLocation, struct.event_location);
				}
				if(struct.event_address NEQ ""){
					arrayAppend(arrLocation, struct.event_address&", ");
				}
				if(struct.event_city NEQ ""){
					arrayAppend(arrLocation, struct.event_city&", ");
				}
				if(struct.event_state NEQ ""){
					arrayAppend(arrLocation, struct.event_state);
				}
				if(struct.event_zip NEQ ""){
					arrayAppend(arrLocation, struct.event_zip);
				}
				if(struct.event_country NEQ "" and struct.event_country NEQ "US"){
					arrayAppend(arrLocation, countryName);
				}
				locationText=arrayToList(arrLocation, " ");
				</cfscript>
				<div class="zEventView1-0">
					<div class="zEventView1-1">&nbsp;</div>
					<div class="zEventView1-2"> 

						<div title="Add to Calendar" class="addthisevent">
							Add to Your Calendar
							<span class="start">#dateformat(struct.event_start_datetime, "mm/dd/yyyy")# #timeformat(struct.event_start_datetime, "HH:mm tt")#</span>
							<span class="end">#dateformat(struct.event_end_datetime, "mm/dd/yyyy")# #timeformat(struct.event_end_datetime, "HH:mm tt")#</span>
							<span class="timezone">America/New_York</span>
							<span class="title">#struct.event_name#</span>
							<span class="description">#application.zcore.functions.zRemoveHTMLForSearchIndexer(struct.event_description)#</span>
							<cfif locationText NEQ "">
								<span class="location">#locationText#</span>
							</cfif>
							<span class="all_day_event"><cfif struct.event_allday EQ 1>true<cfelse>false</cfif></span>
							<span class="date_format">MM/DD/YYYY</span>
						</div>
				
					</div>
				</div>
			</cfif>
 --->
		</div>
	</div>
	<cfscript>
	echo('</div>');
	</cfscript>
	
	<div class="zEventView1-container">
		<cfif struct.event_address NEQ "">
			<div id="zEventViewMapContainer" style="page-break-before: always;">
				<div class="zEventView1-Map"  id="zEventMapDivId"></div>
				<div style="width:100%; float:left;padding-top:10px; padding-bottom:10px;"> <a href="https://maps.google.com/maps?q=#urlencodedformat(struct.event_address&", "&struct.event_city&", "&struct.event_state&" "&struct.event_zip&" "&struct.event_country)#" target="_blank">Launch In Google Maps</a></div>
			</div>
		</cfif>
	</div>   
	#slideshowOutBottom# 
	<div class="zEventView-buttons z-float">
		<a href="#calendarLink#" class="zEventView1-backToCalendar">Back To Calendar</a>
		<cfif application.zcore.user.checkGroupAccess("member") and application.zcore.adminSecurityFilter.checkFeatureAccess("Events", true)>
			<a href="/z/event/admin/manage-events/edit?event_id=#struct.event_id#&amp;returnURL=#request.zos.originalURL#" class="zNoContentTransition zEventView1-backToCalendar" style="margin-left:10px;">Edit</a>
		</cfif>
	</div>
	
 	
</cffunction>
</cfoutput>

<cffunction name="viewNextRecurringEvent" localmode="modern" access="remote">
	<cfscript>
	
	db=request.zos.queryObject; 
	form.event_id=application.zcore.functions.zso(form, 'event_id', true);
	ts.event_id=form.event_id;
	ts.onlyFutureEvents=true;
	ts.perpage=1; 
	if(application.zcore.user.checkGroupAccess("member")){
		ts.showInactive=true;
	}
	eventCom=application.zcore.app.getAppCFC("event");
	rs=eventCom.searchEvents(ts);
	if(rs.count NEQ 1){
		application.zcore.functions.z404("Event id, #form.event_id#, is missing or doesn't have a future recurring date.");
	}
	row=rs.arrData[1];
	urlId=application.zcore.app.getAppData("event").optionstruct.event_config_event_next_recur_url_id;
	actualLink=eventCom.getEventRecurURL(row);
	curLink=request.zos.originalURL; 
	if(compare(curLink, actualLink) NEQ 0){ 
		application.zcore.functions.z301redirect(actualLink);
	}
	row.event_start_datetime=row.event_recur_start_datetime;
	row.event_end_datetime=row.event_recur_end_datetime;
	displayEvent(row); 
	</cfscript>
</cffunction>

<cffunction name="viewRecurringEvent" localmode="modern" access="remote">
	<cfscript>
	application.zcore.template.prependTag('meta','<meta name="robots" content="noindex,follow" />'); 
	db=request.zos.queryObject; 
	form.event_recur_id=application.zcore.functions.zso(form, 'event_recur_id', true);
	ts={};
	ts.event_recur_id=form.event_recur_id;
	ts.onlyFutureEvents=false;
	ts.perpage=1;
	if(application.zcore.user.checkGroupAccess("member")){
		ts.showInactive=true;
	} 
	eventCom=application.zcore.app.getAppCFC("event");
	rs=eventCom.searchEvents(ts);  
	if(rs.count NEQ 1){
		application.zcore.functions.z404("Recurring event, #form.event_recur_id#, is missing");
	}
	row=rs.arrData[1];
	actualLink=eventCom.getEventRecurURL(row); 
	if(row.event_unique_url NEQ ""){
		curLink=request.zos.originalURL&"?recurId="&form.event_recur_id;
	}else{
		curLink=request.zos.originalURL;
	}
	if(compare(curLink, actualLink) NEQ 0){
		application.zcore.functions.z301redirect(actualLink);
	}
	row.event_start_datetime=row.event_recur_start_datetime;
	row.event_end_datetime=row.event_recur_end_datetime;
	displayEvent(row); 
	</cfscript>
</cffunction>



<cffunction name="viewEvent" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject; 
	form.event_id=application.zcore.functions.zso(form, 'event_id', true);
	ts.event_id=form.event_id;
	ts.perpage=1;
	ts.onlyFutureEvents=true;
	if(application.zcore.user.checkGroupAccess("member")){
		ts.showInactive=true;
	}
	eventCom=application.zcore.app.getAppCFC("event");
	rs=eventCom.searchEvents(ts);
	if(rs.count EQ 0){
		ts.onlyFutureEvents=false;
		eventCom=application.zcore.app.getAppCFC("event");
		rs=eventCom.searchEvents(ts);
	} 
	if(rs.count NEQ 1){
		application.zcore.functions.z404("Event, #form.event_id#, is missing");
	}
	row=rs.arrData[1];
	if(not eventCom.userHasAccessToEventCalendarID(row.event_calendar_id)){
		application.zcore.status.setStatus(request.zsid, "You must login to view the calendar");
		application.zcore.functions.zRedirect("/z/user/preference/index?zsid=#request.zsid#&returnURL=#urlencodedformat(request.zos.originalURL)#");
	}
	row.event_start_datetime=row.event_recur_start_datetime;
	row.event_end_datetime=row.event_recur_end_datetime; 


	if(structkeyexists(form, 'zUrlName')){
		if(row.event_unique_url EQ ""){

			curLink=row.__url; 
			urlId=application.zcore.app.getAppData("event").optionstruct.event_config_event_url_id;
			actualLink="/"&application.zcore.functions.zURLEncode(form.zURLName, '-')&"-"&urlId&"-"&row.event_id&".html";

			if(compare(curLink,actualLink) neq 0){
				application.zcore.functions.z301Redirect(curLink);
			}
		}else{
			if(compare(row.event_unique_url, request.zos.originalURL) NEQ 0){
				application.zcore.functions.z301Redirect(row.event_unique_url);
			}
		}
	}
	displayEvent(row);
	</cfscript>
</cffunction>
</cfcomponent>