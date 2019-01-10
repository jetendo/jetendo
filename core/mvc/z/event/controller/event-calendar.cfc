<cfcomponent>
<cfoutput>
	
<cffunction name="viewCalendar" access="remote" localmode="modern">
    <cfscript>
	request.zos.currentURLISAnEventPage=true;
    db=request.zos.queryObject; 
	application.zcore.functions.zRequireJqueryUI();

	form.calendarids=application.zcore.functions.zso(form, 'calendarids');

	calendarIdList="";
	arrCalendar=listToArray(form.calendarids, ",");
	if(arraylen(arrCalendar)){
		arrCalendar2=[];
		for(i=1;i LTE arraylen(arrCalendar);i++){
			if(isnumeric(trim(arrCalendar[i]))){
				arrayAppend(arrCalendar2, arrCalendar[i]);
			}
		}
		calendarIdList=arrayToList(arrCalendar2, ",");
		arrCalendar=arrCalendar2;
	}
	if(calendarIdList EQ ""){
		application.zcore.functions.z404("form.calendarids is required");
	}

	db.sql="select * from #db.table("event_calendar", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	event_calendar_deleted=#db.param(0)# and 
	event_calendar_id IN (#db.trustedSQL(calendarIdList)#) ";
	qCalendar=db.execute("qCalendar", "", 10000, "query", false);
	application.zcore.functions.zQueryToStruct(qCalendar, form);
	if(qCalendar.recordcount EQ 0){
		application.zcore.functions.z404("form.calendarids doesn't exist.");
	}
	calendarStruct={};

	if(not application.zcore.app.getAppCFC("event").userHasAccessToEventCalendarID(calendarIdList)){
		application.zcore.status.setStatus(request.zsid, "You must login to view the calendar");
		application.zcore.functions.zRedirect("/z/user/preference/index?zsid=#request.zsid#&returnURL=#urlencodedformat(request.zos.originalURL)#");
	}
	if(qCalendar.recordcount GT 1){
		application.zcore.template.setTag("title", "Event Calendar");
		application.zcore.template.setTag("pagetitle", "Event Calendar");

		arraySort(arrCalendar, "numeric", "asc");
		curLink="/z/event/event-calendar/viewCalendar?calendarids=#arrayToList(arrCalendar, ",")#";
		actualLink=request.zos.originalURL&"?calendarids=#form.calendarids#";
		if(compare(curLink,actualLink) neq 0){
			application.zcore.functions.z301Redirect(curLink);
		}
	}else{
		for(row in qCalendar){
			calendarStruct=row;
		}

		if(structkeyexists(form, 'zUrlName')){
			if(calendarStruct.event_calendar_unique_url EQ ""){

				curLink=application.zcore.app.getAppCFC("event").getCalendarURL(calendarStruct); 
				urlId=application.zcore.app.getAppData("event").optionstruct.event_config_calendar_url_id;
				actualLink="/"&application.zcore.functions.zURLEncode(form.zURLName, '-')&"-"&urlId&"-"&calendarStruct.event_calendar_id&".html";

				if(compare(curLink,actualLink) neq 0){
					application.zcore.functions.z301Redirect(curLink);
				}
			}else{
				if(compare(calendarStruct.event_calendar_unique_url, request.zos.originalURL) NEQ 0){
					application.zcore.functions.z301Redirect(calendarStruct.event_calendar_unique_url);
				}
			}
		}
		application.zcore.template.setTag("meta", '<meta name="Keywords" content="#htmleditformat(qCalendar.event_calendar_metakey)#" /><meta name="Description" content="#htmleditformat(qCalendar.event_calendar_metadesc)#" />');
		if(qCalendar.event_calendar_metatitle NEQ ""){
			application.zcore.template.setTag( "title", qCalendar.event_calendar_metatitle);
		}else{
			application.zcore.template.setTag("title", qCalendar.event_calendar_name);
		}
		application.zcore.template.setTag("pagetitle", qCalendar.event_calendar_name);
		echo(qCalendar.event_calendar_description);
	}
	

	form.zview=application.zcore.functions.zso(form, 'zview');
	arrView=listToArray(qCalendar.event_calendar_list_views, ",");

	ss={};
	ss.viewStruct={};
	for(i=1;i<=arrayLen(arrView);i++){
		ss.viewStruct[arrView[i]]=true;
	}
	ss.defaultView=form.event_calendar_list_default_view;
	if(form.zview NEQ ""){
		ss.defaultView=form.zview;
	}
	ss.jsonFullLink="/z/event/event-calendar/getFullCalendarJson?calendarids=#calendarIdList#";
	ss.jsonListLink="/z/event/event-calendar/getListViewCalendarJson?calendarids=#calendarIdList#";
	if(qCalendar.event_calendar_searchable){
		ss.searchable=true;
	}
	displayCalendar(ss);
	</cfscript> 


</cffunction>

	
<cffunction name="displayCalendar" access="remote" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	viewStruct=arguments.ss.viewStruct;
	defaultView=arguments.ss.defaultView;

	count=0;
	</cfscript>
	<div id="zCalendarResultsDiv" style="width:100%;  float:left;"> 
		<cfif structkeyexists(viewStruct, 'list')>
		<div id="zCalendarHomeTabs">
			<ul>
				<cfsavecontent variable="out">
					<cfif structkeyexists(viewStruct, 'list')>
						<cfset count++>
						<li><a href="##zCalendarTab_List">List View</a></li>
					</cfif>
		
					<cfif structkeyexists(viewStruct, 'Month') or structkeyexists(viewStruct, '2 Months') or structkeyexists(viewStruct, 'Week') or structkeyexists(viewStruct, 'Day')>
						<cfset count++>
						<li><a href="##zCalendarTab_Calendar" class="zCalendarViewTab">Calendar View</a></li>
					</cfif>
					<cfif structKeyExists(ss, 'searchable') and ss.searchable>
						<cfset count++>
						<li><a href="##" onclick="window.location.href='/z/event/event-search/index?calendarids=#form.event_calendar_id#&amp;categories=#application.zcore.functions.zso(form, 'event_category_id')#'; return false;">Search Calendar</a></li>
					</cfif>
				</cfsavecontent>
				<cfscript>
				if(count GT 1){
					echo(out);
				}
				</cfscript>
			</ul>
		</cfif>
	
			<div class="zCalendarTabContainer">
				<div id="zCalendarTab_List">
					
				</div>
				<div id="zCalendarTab_Calendar" style="display:none;">
					<div id="zCalendarFullPageDiv"></div>
				</div>
			</div>
		<cfif structkeyexists(viewStruct, 'list')>
			<br style="clear:both;">
		</div>
		</cfif>
	
	</div>
	<cfscript>
	application.zcore.functions.zRequireFullCalendar();
	</cfscript>
	<cfif application.zcore.functions.zso(application.zcore.app.getAppData("event").optionstruct, 'event_config_disable_other_month_days', true, 0) EQ 1>
		<cfsavecontent variable="local.metaOutput">
		<style type="text/css">
		/* <![CDATA[ */
		.fc-other-month{visibility:hidden;}
		
		/* ]]> */
		</style>
		</cfsavecontent>
		<cfscript> 
		request.zos.template.appendTag("stylesheets", local.metaOutput); 
		</cfscript>
	</cfif>
	
	<script>
	zArrDeferredFunctions.push(function(){
		s={};
		s.defaultDate='#dateformat(now(), "yyyy-mm-dd")#';
		s.jsonFullLink="#arguments.ss.jsonFullLink#";
		s.jsonListLink="#arguments.ss.jsonListLink#";
		/*<cfif application.zcore.functions.zso(application.zcore.app.getAppData("event").optionstruct, 'event_config_disable_other_month_days', true, 0) EQ 1>*/
			s.disableOtherMonth=true;
		/*</cfif>*/
		/*<cfif structkeyexists(viewStruct, 'list')>*/
			s.hasListView=true;
		/*<cfelse>*/ 
			s.hasListView=false;
		/*</cfif>*/
		
		/*<cfif defaultView EQ "List" or (not structkeyexists(viewStruct, 'Month') and not structkeyexists(viewStruct, '2 Months') and not structkeyexists(viewStruct, 'Week') and not structkeyexists(viewStruct, 'Day'))>*/
			s.activeTab="0";
		/*<cfelse>*/
			s.activeTab="1";
		/*</cfif>*/
		zDisplayEventCalendar(s);
	});
	</script>   
</cffunction>
	

<cffunction name="returnListViewCalendarJson" access="remote" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
 	js={};
 	js.offset=ss.offset;
 	js.count=ss.count;
 	js.perpage=ss.perpage;
 	js.link=ss.link;
 	js.success=true;
 	eventCom=application.zcore.app.getAppCFC("event");
 	eventImages={};
 	dbHasPhotos=false;
 	for(i=1;i<=arrayLen(ss.arrData);i++){
 		row=ss.arrData[i];
		ts=structnew();
		ts.image_library_id=row.event_image_library_id;
		ts.output=false;
		ts.struct=row;
		ts.size="300x240";
		ts.crop=0;
		ts.count = 1; // how many images to get
		arrImage=application.zcore.imageLibraryCom.displayImageFromStruct(ts);
 		eventImages[row.event_id]=arrImage;
 		if(arrayLen(arrImage) GT 0){
 			dbHasPhotos=true;
 		}
 	}
 	</cfscript>
	<cfsavecontent variable="js.html">
		<cfloop from="1" to="#arrayLen(ss.arrData)#" index="i1">
			<cfscript>row=ss.arrData[i1];
			dateRangeStruct=eventCom.getDateRangeStruct(row);


			if(row.event_summary EQ ""){
				summary=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(row.event_description), 200);
			}else{
				summary=row.event_summary;
			}
			</cfscript>

			<div class="zEventListContainer">
				<cfif ss.hasPhotos and dbHasPhotos>
					<div class="zEventListPhoto" style="width:220px;">
						<cfif arrayLen(eventImages[row.event_id])>
							<img src="#eventImages[row.event_id][1].link#" alt="#htmleditformat(eventImages[row.event_id][1].caption)#" class="z-fluid"> 
						</cfif>
					</div>
					<div class="zEventListText" style="width:#request.zos.globals.maximagewidth-220#px;">
				<cfelse>
					<div class="zEventListText">
				</cfif>
				
						<div class="zEventListHeading"><h2><a href="#htmleditformat(row.__url)#" class="event-link">#htmleditformat(row.event_name)#</a></h2></div>
						<div class="zEventListDate">#dateRangeStruct.dateTimeRange#</div>
						<div class="zEventListSummary">
							#summary#
						</div>
						<a href="#htmleditformat(row.__url)#" class="zEventInfoButton">More Info</a>
					</div>
			</div>
			<hr /> 

		</cfloop>
		<cfif ss.offset NEQ 0 or ss.count GT ss.perpage>
			<div id="zEventListCalendarNav"></div>
		</cfif>

	</cfsavecontent>
	<cfscript>

 	if(arraylen(ss.arrData) EQ 0){
 		noEventMessage=application.zcore.functions.zso(application.zcore.app.getAppData("event").optionStruct, 'event_config_no_event_message');
 		if(noEventMessage EQ ""){
	 		js.html="<p>There are no events at this time. Please check back later.</p>";
	 	}else{
	 		js.html=noEventMessage;
	 	}
 	}
	application.zcore.functions.zReturnJson(js);
	</cfscript>

</cffunction>

<cffunction name="getListViewCalendarJson" access="remote" localmode="modern">
	<cfscript>
	ss={}; 
	if(structkeyexists(form, 'categories') and form.categories NEQ ""){
		ss.categories=application.zcore.functions.zso(form, 'categories');
	}else{
		ss.calendarids=application.zcore.functions.zso(form, 'calendarids');
	}
 	ss.startDate=application.zcore.functions.zso(form, 'start', false, request.zos.mysqlnow);
 	ss.endDate=application.zcore.functions.zso(form, 'end', false, dateadd("d", application.zcore.app.getAppData("event").optionstruct.event_config_project_recurrence_days, request.zos.mysqlnow)); 
 	ss.offset=min(application.zcore.functions.zso(form, 'offset', true, 0), 1000);
 	ss.perpage=min(application.zcore.functions.zso(form, 'perpage', true, 15),50);

 	eventCom=application.zcore.app.getAppCFC("event");
 	rs=eventCom.searchEvents(ss); 
 	rs.offset=ss.offset;
 	rs.perpage=ss.perpage; 
 	if(structkeyexists(form, 'categories') and form.categories NEQ ""){
	 	rs.link="/z/event/event-calendar/getListViewCalendarJson?categories=#ss.categories#";
 	}else{
	 	rs.link="/z/event/event-calendar/getListViewCalendarJson?calendarids=#ss.calendarids#";
	 }
 	returnListViewCalendarJson(rs);
 	</cfscript>
</cffunction>
	

<cffunction name="getFullCalendarJson" access="remote" localmode="modern">
	<cfscript>
	ss={};
	if(structkeyexists(form, 'categories')){
		ss.categories=application.zcore.functions.zso(form, 'categories');
	}else{
		ss.calendarids=application.zcore.functions.zso(form, 'calendarids');
	}
	ss.onlyFutureEvents=false;
 	ss.startDate=application.zcore.functions.zso(form, 'start', false, request.zos.mysqlnow);
 	ss.endDate=application.zcore.functions.zso(form, 'end', false, dateadd("d", application.zcore.app.getAppData("event").optionstruct.event_config_project_recurrence_days, request.zos.mysqlnow)); 
 	ss.perpage=1000;
 	rs=application.zcore.app.getAppCFC("event").searchEvents(ss); 
 	arrData=[]; 

 	tz=GetTimeZoneInfo();
 	//writedump(tz);

 	for(i=1;i LTE arraylen(rs.arrData);i++){
 		row=rs.arrData[i]; 
		ts={
			id:row.event_recur_id,
			title:row.event_name,
			start:dateformat(row.event_recur_start_datetime,"yyyy-mm-dd")&" "&timeformat(row.event_recur_start_datetime, "HH:mm"),
			link:row.__url
		}

		if(row.event_allday EQ 1){
			ts.allDay=true;
		}else{
			ts.allDay=false;
			ts.title=timeformat(row.event_recur_start_datetime, "h:mm tt - ")&ts.title;
		}

		if(row.event_recur_start_datetime NEQ row.event_recur_end_datetime){
			endTime=timeformat(row.event_recur_end_datetime, "HH:mm:ss");
			/*if(endTime EQ "00:00:00"){
				endTime="13:00:00";
			}*/

			// this forces event to appear on the end date on the calendar, the time has to be most of the day to make it visible.
			endTime="00:00";//"23:59:59";
			ts.end=dateformat(dateadd("d", 1, row.event_recur_end_datetime),"yyyy-mm-dd")&" "&endTime;
		}
		arrayAppend(arrData, ts);
	}
 	application.zcore.functions.zReturnJson(arrData);

	</cfscript>
</cffunction>



<cffunction name="displayCalendarResults" access="private" localmode="modern">
	<cfscript>
	request.zos.currentURLISAnEventPage=true;
	var ts=0;
	</cfscript> 
	<cfsavecontent variable="output">
		<cfscript>
		ts={};
		form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
		if(form.zIndex LTE 0){
			application.zcore.functions.z301redirect("/events/index");
		}

		if(structkeyexists(form, 'startDate')){
			if(structkeyexists(form, 'startDate') and isdate(form.startDate)){
				ts.startDate=form.startDate;
			}else{
				ts.startDate=now();
			}
			if(structkeyexists(form, 'endDate') and isdate(form.endDate)){
				ts.endDate=form.endDate;
			}else{
				ts.endDate=dateAdd("m", 3, now());
			}
			ts.arrGroupName=["event"];
			ts.limit=15;
			ts.offset=(form.zIndex-1)*ts.limit;
			ts.orderBy="startDateASC"; // startDateASC | startDateDESC
			arr1=application.zcore.siteOptionCom.optionGroupSetFromDatabaseBySearch(ts, request.zos.globals.id);  
			countTotal=application.zcore.siteOptionCom.optionGroupSetCountFromDatabaseBySearch(ts, request.zos.globals.id);
		}else{

			ts=[];
			arrayAppend(ts, {
				type:">=",
				field: "Start Date",
				arrValue:[request.zos.mysqlnow]	
			});
			arrayAppend(ts, {
				type:">",
				field: "End Date",
				arrValue:[request.zos.mysqlnow]	
			});
			
			form.limit=15;
			form.offset=(form.zIndex-1)*form.limit;
			rs2=application.zcore.siteOptionCom.searchOptionGroup("Event", ts, 0, false, form.offset, form.limit, "Start Date", "text", "asc", true);
			arr1=rs2.arrResult;
			countTotal=rs2.count;
		}
		ts=[];
		arrayAppend(ts, {
			type:"<",
			field: "Start Date",
			arrValue:[request.zos.mysqlnow]	
		});
		arrayAppend(ts, {
			type:">",
			field: "End Date",
			arrValue:[request.zos.mysqlnow]	
		});
		
		form.limit=25;
		form.offset=0;
		rs=application.zcore.siteOptionCom.searchOptionGroup("Event", ts, 0, false, form.offset, form.limit, "Start Date", "text", "asc", true);

		ongoing={};
		for(i=1;i LTE arraylen(rs.arrResult);i++){
			eventStruct=rs.arrResult[i];
			savecontent variable="event"{
				echo('	<div class="sn-36">
							<div class="sn-37">
								<div class="sn-38"><a href="#htmleditformat(eventStruct.__url)#" class="event-link">#htmleditformat(eventStruct.title)#</a></div>
								<div class="sn-39">#request.zos.functions.zParagraphFormat(htmleditformat(eventStruct.summary))#</div>
							</div>
							<a href="#htmleditformat(eventStruct.__url)#" class="event-button">View Details</a>
						</div>
						<hr />');
			}
			ongoing[eventStruct.__setId]={
				html:event,
				date:eventStruct["start date"],
				dateAsNumber:dateformat(eventStruct["start date"], "yyyymdd")&timeformat(eventStruct["start date"],"HHmmss")
			};
		} 
		//arr1=request.zos.functions.zSiteOptionGroupStruct("Event");
		dateStruct={};
		signatureDisplayed=false;   

		</cfscript>
		<cfloop from="1" to="#arraylen(arr1)#" index="i">
			<cfscript>
			eventStruct=arr1[i]; 
			</cfscript>
			<cfif arr1[i]["Signature Event"] EQ "1">
			<!--- <cfif (variables.isDateWithinRange(eventStruct["start date"], form.startdate, form.enddate) or variables.isDateWithinRange(dateformat(eventStruct["end date"], 'yyyy-mm-dd'), form.startdate, form.enddate)) and (form.rootCategoryList EQ "" or variables.isInSearchCategory(arr1[i]["category"], form.rootCategoryList))  and eventStruct["Signature Event"] EQ "1">  --->
				<cfscript>
				signatureDisplayed=true; 
				eventStruct=arr1[i];
				curDate=dateformat(arr1[i]["start date"], "yyyymmdd");
				if(not structkeyexists(dateStruct, curDate)){
					dateStruct[curDate]={};
				}
				</cfscript>  
				<div style="width:618px; padding:25px; float:left;  background-color:##e5fde5; border:1px solid ##769373; margin-bottom:20px;">
					<div class="sn-32">
						<div class="sn-33">#dateformat(arr1[i]["start date"], 'mmm')#</div>
						<div class="sn-34">#dateformat(arr1[i]["start date"], 'd')#</div>
					</div>
					<div class="sn-35">
						<div class="sn-36">
							<div class="sn-37">
								<div class="sn-38"><a href="#htmleditformat(eventStruct.__url)#" class="event-link">#htmleditformat(eventStruct.title)#</a></div>
								<div class="sn-39">#request.zos.functions.zParagraphFormat(htmleditformat(eventStruct.summary))#</div>
							</div>
							<a href="#htmleditformat(eventStruct.__url)#" class="event-button">View Details</a>
						</div> 
					</div> 
				</div> 
			</cfif>
		</cfloop> 
	<!--- Disabled<cfabort> --->
		<cfscript>
		//arr1=request.zos.functions.zSiteOptionGroupStruct("Event");
		dateStruct={};
		if(form.method EQ "viewAll"){
			countLimit=0; // show everything, but the date range must always be no more then 30 days.
		}else{
			countLimit=15;
		}
		count=0;
		resultsLimited=false;  
		</cfscript>
		<cfloop from="1" to="#arraylen(arr1)#" index="i"> 
			<!--- <cfif (variables.isDateWithinRange(arr1[i]["start date"], form.startdate, form.enddate) or variables.isDateWithinRange(dateformat(arr1[i]["end date"], 'yyyy-mm-dd'), form.startdate, form.enddate)) and (form.rootCategoryList EQ "" or variables.isInSearchCategory(arr1[i]["category"], form.rootCategoryList)) and arr1[i]["Signature Event"] NEQ "1"> --->
			<cfif arr1[i]["Signature Event"] NEQ "1">
				<cfscript>
				/*if(countLimit NEQ 0 and count GTE countLimit){
					resultsLimited=true;
					break;
				}*/
				count++;
				eventStruct=arr1[i];
				curDate=dateformat(arr1[i]["start date"], "yyyymmdd");
				if(not structkeyexists(dateStruct, curDate)){
					dateStruct[curDate]={};
				}
				</cfscript>
				<cfsavecontent variable="event">
					<div class="sn-36">
						<div class="sn-37">
							<div class="sn-38"><a href="#htmleditformat(eventStruct.__url)#" class="event-link">#htmleditformat(eventStruct.title)#</a></div>
							<div class="sn-39">#request.zos.functions.zParagraphFormat(htmleditformat(eventStruct.summary))#</div>
						</div>
						<a href="#htmleditformat(eventStruct.__url)#" class="event-button">View Details</a>
					</div>
					<hr />
				</cfsavecontent>
				<cfscript> 
				dateStruct[curDate][eventStruct.__setId]={
					html:event,
					date:eventStruct["start date"],
					dateAsNumber:dateformat(eventStruct["start date"], "yyyymdd")&timeformat(eventStruct["start date"],"HHmmss")
				}; 
				</cfscript>
			</cfif>
		</cfloop> 
		<cfscript>
		arrKey2=structsort(ongoing, "numeric", "asc", "dateAsNumber");
		savecontent variable="sidebarContent"{
			if(arraylen(arrKey2)){
				echo('<div style="width:100%;clear:both; float:left;font-size:18px;  font-weight:bold; line-height:24px; padding-bottom:10px; padding-top:20px;">Ongoing Events</div>');
				for(i=1;i LTE arraylen(arrKey2);i++){
					echo(ongoing[arrKey2[i]].html);
				}
			}
		}
		if(not structkeyexists(request, 'eventsSidebarHTML')){
			request.eventsSidebarHTML="";
		}
		request.eventsSidebarHTML&=sidebarContent;
		arrKey=structkeyarray(dateStruct);
		arraysort(arrKey, "numeric", "asc");
		var totalOutput=0;
		var totalOffset=0;
		var curOffset=(form.zIndex-1)*countLimit;
		for(i=1;i LTE arraylen(arrKey);i++){
			arrCurrent=[];
			arrKey2=structsort(dateStruct[arrKey[i]], "numeric", "asc", "dateAsNumber");
			//writeoutput('<br /><br >'&arrKey[i]&' | '&dateformat(arrKey[i], 'm/d/yy')&'<br />');
			var outputThisDate=false;
			for(n=1;n LTE arraylen(arrKey2);n++){
				//writeoutput(dateStruct[arrKey[i]][arrKey2[n]].date);
				curDate=dateStruct[arrKey[i]][arrKey2[n]].date;
				curHTML=dateStruct[arrKey[i]][arrKey2[n]].html;
				if(n EQ arraylen(arrKey2)){
					curHTML=replace(curHTML, ' class="sn-36"', ' class="sn-36" style="border-bottom:none;"');
				}
				//if(totalOffset GTE curOffset and totalOffset LT curOffset+countLimit){
					totalOutput++;
					outputThisDate=true;
					arrayAppend(arrCurrent, curHTML);
				//}
				/*totalOffset++;
				if(totalOutput EQ countLimit){
					break;
				}*/
			}
			if(outputThisDate){
				writeoutput('
				<div class="sn-31">
					<div class="sn-32">
						<div class="sn-33">#dateformat(curDate, 'mmm')#</div>
						<div class="sn-34">#dateformat(curDate, 'd')#</div>
					</div>
					<div class="sn-35">'&arrayToList(arrCurrent, " ")&'
					</div>
				</div>');
			}
			if(totalOutput EQ countLimit){ 
				resultsLimited=true;
				break;
			}
		} 
		//writeoutput(countTotal&" | "&((form.zIndex-1)*15)+countLimit);
		if(form.zIndex NEQ 1 or countTotal GTE ((form.zIndex-1)*15)+countLimit){
			// required
			searchStruct = StructNew();
			searchStruct.count = countTotal;
			searchStruct.index = form.zIndex;
			searchStruct.url = "/events/index?startDate=#urlencodedformat(dateformat(form.startDate, "m/d/yyyy"))#&endDate=#urlencodedformat(dateformat(form.endDate, "m/d/yyyy"))#";
			searchStruct.indexName = "zIndex";
			searchStruct.buttons = 5;
			searchStruct.perpage = countLimit;
			var searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
			writeoutput(searchNav);
		}
		//writeoutput(totalOutput &":"&countLimit&":"&count);
		</cfscript>
		<!--- <cfif resultsLimited and form.method NEQ "viewAll" and count NEQ 0>
			<div class="sn-41"> <a href="/events/viewAll" class="big-button">VIEW ALL</a></div>
		</cfif> --->
		<cfif not signatureDisplayed and count EQ 0>
			<div style="padding:40px;">
			<h2>Please adjust your search</h2>
			<p>No events match your search.</p></div>
			<cfelse> 
		</cfif>
	</cfsavecontent>
	<cfscript>
	return output;
	</cfscript>
</cffunction>


<cffunction name="view" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;

	writedump(form);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>