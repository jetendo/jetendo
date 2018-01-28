<cfcomponent>
<cfoutput>
<cfscript>
this.app_id=17;
</cfscript>
<!--- 
// Add a way for robots to index past events - directory for crawling 10-30 event links per page.
mystandrews is using the same event table for icalendar import.  might need to modify/upgrade their site

TODO: only change recur db when the start,end or recur or exclude days fields have changed.

Cancel an event that has reservations attached.  It should be able to cancel all the reservations in one step.


all day event is not setup to work yet...

timezone does nothing...

 ---> 

<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
</cffunction>

<cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	var qa="";
	var rs="";
	var c1="";
	var db=request.zos.queryObject;

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
	<cfargument name="arrUrl" type="array" required="yes">
	<cfscript>
	ts=application.zcore.app.getInstance(this.app_id);
	db=request.zos.queryObject;

	db.sql="SELECT * from #db.table("event_calendar", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and  
	event_calendar_deleted = #db.param(0)#
	ORDER BY event_calendar_unique_url DESC";
	qF=db.execute("qF");


	if(application.zcore.functions.zso(application.zcore.app.getAppData("event").optionStruct, 'event_config_enable_suggest_event', true) EQ 1){
		t2=StructNew();
		t2.groupName="Event Calendar";
		t2.url=request.zos.currentHostName&"/z/event/suggest-an-event/index";
		t2.title="Suggest An Event";
		arrayappend(arguments.arrUrl,t2);
	}

	publicAccess={};
	for(row in qF){
		if(row.event_calendar_user_group_idlist EQ ""){
			publicAccess[row.event_calendar_id]=true;
			t2=StructNew();
			t2.groupName="Event Calendar";
			t2.url=request.zos.currentHostName&getCalendarURL(row);
			t2.title=row.event_calendar_name;
			arrayappend(arguments.arrUrl,t2);
		}
	}
	arrCalendar=structkeyarray(publicAccess); 
	db.sql="SELECT * from #db.table("event_category", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and  
	event_category_deleted = #db.param(0)# ";
	if(arraylen(arrCalendar)){ 
		db.sql&=" and ( ";
		for(i=1;i LTE arraylen(arrCalendar);i++){
			if(i NEQ 1){
				db.sql&=" or ";
			}
			db.sql&=" CONCAT(#db.param(",")#, event_calendar_id, #db.param(",")#) LIKE #db.param("%,#arrCalendar[i]#,%")# ";
		}
		db.sql&=" ) ";
	}
	db.sql&="ORDER BY event_category_unique_url DESC";
	qF=db.execute("qF");
	for(row in qF){
		t2=StructNew();
		t2.groupName="Event Category";
		t2.url=request.zos.currentHostName&getCategoryURL(row);
		t2.title=row.event_category_name;
		arrayappend(arguments.arrUrl,t2);
	}

	db.sql="SELECT *, group_concat(event_recur_id order by event_recur_start_datetime asc SEPARATOR #db.param(',')#) recuridlist 
	from #db.table("event", request.zos.zcoreDatasource)#, 
	#db.table("event_recur", request.zos.zcoreDatasource)# 
	WHERE event.site_id=#db.param(request.zos.globals.id)# and  
	event_deleted = #db.param(0)# and 
	event_recur_deleted = #db.param(0)# and 
	event.site_id = event_recur.site_id and 
	event.event_status=#db.param(1)# and 
	event_recur.event_id = event.event_id and 
	event_recur_end_datetime>=#db.param(dateformat(now(), "yyyy-mm-dd")&" 00:00:00")#
	";
	if(arraylen(arrCalendar)){ 
		db.sql&=" and ( ";
		for(i=1;i LTE arraylen(arrCalendar);i++){
			if(i NEQ 1){
				db.sql&=" or ";
			}
			db.sql&=" CONCAT(#db.param(",")#, event_calendar_id, #db.param(",")#) LIKE #db.param("%,#arrCalendar[i]#,%")# ";
		}
		db.sql&=" ) ";
	}
	db.sql&="
	GROUP BY event.event_id 
	ORDER BY event_recur_start_datetime ASC, event_recur_end_datetime ASC";
	qF=db.execute("qF");  
	//GROUP BY event.event_id  
	uniqueEvent={};
	for(row in qF){
		if(structkeyexists(uniqueEvent, row.event_id)){
			continue;
		}
		row.event_recur_id=listGetAt(row.recuridlist, 1);
		uniqueEvent[row.event_id]=true;
		t2=StructNew();
		t2.groupName="Event";
		if(row.event_recur_ical_rules EQ ""){
			t2.url=request.zos.currentHostName&getEventURL(row);
		}else{
			t2.url=request.zos.currentHostName&getNextRecurringEventURL(row);
		}
		t2.title=row.event_name;
		arrayappend(arguments.arrUrl,t2);
	}
	return arguments.arrURL;
	</cfscript>
</cffunction>



<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
	var ts=0;
	if(structkeyexists(request.zos.userSession.groupAccess, "administrator")){
		if(structkeyexists(arguments.linkStruct,"Events") EQ false){
			ts=structnew();
			ts.featureName="Events";
			ts.link='/z/event/admin/manage-events/index';
			ts.children=structnew();
			arguments.linkStruct["Events"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["Events"].children,"Add Event") EQ false){
			ts=structnew();
			ts.featureName="Add Events";
			ts.link="/z/event/admin/manage-events/add";
			arguments.linkStruct["Events"].children["Add Event"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["Events"].children,"Add Event Category") EQ false){
			ts=structnew();
			ts.featureName="Add Event Category";
			ts.link="/z/event/admin/manage-event-category/add";
			arguments.linkStruct["Events"].children["Add Event Category"]=ts;
		}
		if(application.zcore.user.checkServerAccess()){
			if(structkeyexists(arguments.linkStruct["Events"].children,"Import iCalendar") EQ false){
				ts=structnew();
				ts.featureName="Import ICalendar";
				ts.link='/z/admin/ical-import/index';
				arguments.linkStruct["Events"].children["Import iCalendar"]=ts;
			} 
		}
		if(structkeyexists(arguments.linkStruct["Events"].children,"Add Event Calendar") EQ false){
			ts=structnew();
			ts.featureName="Add Event Calendar";
			ts.link="/z/event/admin/manage-event-calendar/add";
			arguments.linkStruct["Events"].children["Add Event Calendar"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["Events"].children,"Events") EQ false){
			ts=structnew();
			ts.featureName="Events";
			ts.link="/z/event/admin/manage-events/index";
			arguments.linkStruct["Events"].children["Events"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["Events"].children,"Event Calendars") EQ false){
			ts=structnew();
			ts.featureName="Event Calendars";
			ts.link="/z/event/admin/manage-event-calendar/index";
			arguments.linkStruct["Events"].children["Event Calendars"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["Events"].children,"Event Widgets") EQ false){
			ts=structnew();
			ts.featureName="Event Widgets";
			ts.link="/z/event/admin/manage-event-widgets/index";
			arguments.linkStruct["Events"].children["Event Widgets"]=ts;
		}
		if(structkeyexists(arguments.linkStruct["Events"].children,"Event Categories") EQ false){
			ts=structnew();
			ts.featureName="Event Categories";
			ts.link="/z/event/admin/manage-event-category/index";
			arguments.linkStruct["Events"].children["Event Categories"]=ts;
		}
		if(application.zcore.app.getAppData("event").optionStruct.event_config_enable_suggest_event EQ 1){
			if(structkeyexists(arguments.linkStruct["Events"].children,"Suggest An Event") EQ false){
				ts=structnew();
				ts.featureName="Suggest An Event";
				ts.link="/z/event/suggest-an-event/index";
				ts.target="_blank";
				arguments.linkStruct["Events"].children["Suggest An Event"]=ts;
			}
		}
	}
	return arguments.linkStruct;
	</cfscript>
</cffunction>

<cffunction name="getAdminNavMenu" localmode="modern" access="public">
	<cfscript>
	application.zcore.template.setTag("title", "Event Calendar");
	</cfscript>
	<!--- <p>Manage: 
	<a href="/z/event/admin/manage-event-calendar/index">Calendars</a> | 
	<a href="/z/event/admin/manage-event-category/index">Categories</a> | 
	<a href="/z/event/admin/manage-events/index">Events</a> 
	| Add:
	<a href="/z/event/admin/manage-event-calendar/add">Calendar</a> | 
	<a href="/z/event/admin/manage-event-category/add">Category</a> | 
	<a href="/z/event/admin/manage-events/add">Event</a>
	</p> --->
</cffunction>

<cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfscript>
	var qdata=0;
	var ts=StructNew();
	var qdata=0;
	var arrcolumns=0;
	var i=0;
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("event_config", request.zos.zcoreDatasource)# 
	where 
	site_id = #db.param(arguments.site_id)# and 
	event_config_deleted = #db.param(0)#";
	qData=db.execute("qData"); 
	for(row in qData){
		return row;
	}
	throw("event_config record is missing for site_id=#arguments.site_id#.");
	</cfscript>
</cffunction>



	
<!--- application.zcore.app.getAppCFC("event").searchReindexCategory(false, true); --->
<cffunction name="searchReindexCategory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexEverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT event_category.*, event_config_event_url_id FROM #db.table("event_category", request.zos.zcoreDatasource)#,
		#db.table("event_config", request.zos.zcoreDatasource)# 
		WHERE 
		event_config.site_id = event_category.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and event_category.site_id = #db.param(request.zos.globals.id)# ";
		}else{
			db.sql&=" and event_category.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and event_category_id = #db.param(arguments.id)# ";
		}
		db.sql&=" and event_category_deleted=#db.param(0)# and 
		event_config_deleted =#db.param(0)#	
		LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteEvent(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.event_category_name&" "&row.event_category_description;
				ds.search_title=row.event_category_name;
				//if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.event_category_description;
				//}
				ds.search_summary=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(ds.search_summary), 150);
				
				ds.search_url=getCategoryURL(row);
				ds.search_table_id="event-category-"&row.event_category_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=dateformat(row.event_category_updated_datetime, "yyyy-mm-dd")&" "&timeformat(row.event_category_updated_datetime, "HH:mm:ss");
				ds.site_id=row.site_id;
				
				searchCom.saveSearchIndex(ds); 
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and  
		search_table_id LIKE #db.param('event-category-%')# and
		search_deleted = #db.param(0)# and
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>

<cffunction name="testRule" localmode="modern" access="remote">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	struct=arguments.struct;
	projectDays=0;
	arrDate=request.ical.getRecurringDates(struct.startDate, struct.rule, struct.excludeDayList, projectDays);

	//writedump(arrDate);abort; 
	dateStruct={};
	for(i=1;i LTE arraylen(struct.arrCorrectDates);i++){
		dateStruct[dateformat(struct.arrCorrectDates[i], 'yyyy-mm-dd')]=true;
	}
	arrError=[];
	arrDate2=[];
	for(i=1;i LTE arraylen(arrDate);i++){
		d=dateformat(arrDate[i], 'yyyy-mm-dd');
		arrayAppend(arrDate2, d);
		if(not structkeyexists(dateStruct, d)){
			arrayAppend(arrError, "Extra date returned that isn't correct: "&d);
		}else{
			structdelete(dateStruct, d);
		}
	}
	arrDate3=structkeyarray(dateStruct);
	arraysort(arrDate3, "text", "asc");
	for(i=1;i LTE arraylen(arrDate3);i++){
		i2=arrDate3[i];
		arrayAppend(arrError, "Date expected but not matched: "&i2);
	} 
	if(arraylen(arrError)){
		writedump(struct);
		writedump(arrDate);
		writedump(arrError);abort;
		throw("Invalid rule: #struct.id#<br />Matched Dates: #arrayToList(arrDate2, ", ")#<br /><br />Error details:<br />"&arrayToList(arrError, "<br>"));
	}
	</cfscript>
</cffunction>


<cffunction name="getTests" localmode="modern" access="remote">
	<cfscript>
	arrTest=[];  
	ts={
		id:"Rule 1",
		startDate:"5/7/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=5;BYMONTHDAY=4;COUNT=0;FREQ=YEARLY;INTERVAL=1;UNTIL=20170514T040000Z",
		excludeDayList:"",
		arrCorrectDates:["2015-05-07","2015-06-04","2016-06-04"]
	}
	arrayAppend(arrTest, ts);

	ts={
		id:"Rule 2",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=MO;COUNT=0;FREQ=WEEKLY;INTERVAL=1;UNTIL=20150729T040000Z",
		excludeDayList:"10/12/2015",
		arrCorrectDates:['2015-05-08','2015-05-11','2015-05-18','2015-05-25','2015-06-01','2015-06-08','2015-06-15','2015-06-22','2015-06-29','2015-07-06','2015-07-13','2015-07-20','2015-07-27']
	}
	arrayAppend(arrTest, ts);



	ts={
		id:"Rule 3",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=SA;COUNT=5;FREQ=WEEKLY;INTERVAL=2",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2015-05-09','2015-05-23','2015-06-06','2015-06-20','2015-07-04']
		//["2015-05-08","2015-05-16","2015-05-30","2015-06-13","2015-06-27","2015-07-11"]
	}
	arrayAppend(arrTest, ts);
 
	
	ts={
		id:"Rule 4",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=FR;COUNT=0;FREQ=WEEKLY;INTERVAL=1;UNTIL=20150529T040000Z",
		excludeDayList:"",
		arrCorrectDates:["2015-05-08","2015-05-15","2015-05-22","2015-05-29"]
	}
	arrayAppend(arrTest, ts);

 	ts={
		id:"Rule 5",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=+2TU;COUNT=4;FREQ=MONTHLY;INTERVAL=1",
		excludeDayList:"",
		arrCorrectDates:["2015-05-08","2015-05-12","2015-06-09","2015-07-14","2015-08-11"]
	}
	arrayAppend(arrTest, ts);
	
	ts={
		id:"Rule 6",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTHDAY=10,18;COUNT=4;FREQ=MONTHLY;INTERVAL=1",
		excludeDayList:"",
		arrCorrectDates:["2015-05-08","2015-05-10","2015-05-18","2015-06-10","2015-06-18"]
	}
	arrayAppend(arrTest, ts);
 
	ts={
		id:"Rule 7",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=0;BYDAY=+1MO;COUNT=0;FREQ=YEARLY;INTERVAL=1;UNTIL=20170529T040000Z",
		excludeDayList:"",
		arrCorrectDates:["2015-05-08","2016-01-04","2017-01-02"]
	}
	arrayAppend(arrTest, ts);

	ts={
		id:"Rule 8",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=0;BYDAY=-1MO;COUNT=4;FREQ=YEARLY;INTERVAL=1;UNTIL=20200529T040000Z",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2016-01-25','2017-01-30','2018-01-29','2019-01-28','2020-01-27']
	}
	arrayAppend(arrTest, ts);

 
	ts={
		id:"Rule 9",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=0;BYMONTHDAY=-1;COUNT=4;FREQ=YEARLY;INTERVAL=1;UNTIL=20200529T040000Z",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2016-01-31','2017-01-31','2018-01-31','2019-01-31','2020-01-31']
	}
	arrayAppend(arrTest, ts);


	ts={
		id:"Rule 10",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=0;BYDAY=+4MO;COUNT=4;FREQ=YEARLY;INTERVAL=2;UNTIL=20210529T040000Z",
		excludeDayList:"",
		arrCorrectDates:["2015-05-08","2017-01-23","2019-01-28","2021-01-25"]
	}
	arrayAppend(arrTest, ts);


	ts={
		id:"Rule 11",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=0;BYDAY=+4MO;COUNT=6;FREQ=YEARLY;INTERVAL=1;UNTIL=20210529T040000Z",
		excludeDayList:"",
		arrCorrectDates:["2015-05-08","2016-01-25","2017-01-23","2018-01-22","2019-01-28","2020-01-27","2021-01-25"]
	}
	arrayAppend(arrTest, ts);

	ts={
		id:"Rule 12",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTHDAY=4;COUNT=4;FREQ=MONTHLY;INTERVAL=2;UNTIL=20160529T040000Z",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2015-07-04','2015-09-04','2015-11-04','2016-01-04','2016-03-04','2016-05-04']
	}
	arrayAppend(arrTest, ts); 

	ts={
		id:"Rule 13",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=0;BYMONTHDAY=1;COUNT=4;FREQ=YEARLY;INTERVAL=1;UNTIL=20200529T040000Z",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2016-01-01','2017-01-01','2018-01-01','2019-01-01','2020-01-01']
	}
	arrayAppend(arrTest, ts);

	
	ts={
		id:"Rule 14",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=11;BYMONTHDAY=2;COUNT=4;FREQ=YEARLY;INTERVAL=1;UNTIL=20190529T040000Z",
		excludeDayList:"",
		arrCorrectDates:["2015-05-08","2015-12-02","2016-12-02","2017-12-02","2018-12-02"]
	}
	arrayAppend(arrTest, ts);


	ts={
		id:"Rule 15",
		startDate:"5/7/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=5;BYMONTHDAY=4;COUNT=0;FREQ=YEARLY;INTERVAL=2;UNTIL=20200514T040000Z",
		excludeDayList:"",
		arrCorrectDates:["2015-05-07","2015-06-04","2017-06-04","2019-06-04"]
	}
	arrayAppend(arrTest, ts);

 	ts={
		id:"Rule 16",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=+2TU;COUNT=4;FREQ=MONTHLY;INTERVAL=2",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2015-05-12','2015-07-14','2015-09-08','2015-11-10']
	}
	arrayAppend(arrTest, ts); 

 	ts={
		id:"Rule 17",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=MO,TU,WE,TH,FR,SA,SU;COUNT=20;FREQ=MONTHLY;INTERVAL=1",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2015-05-09','2015-05-10','2015-05-11','2015-05-12','2015-05-13','2015-05-14','2015-05-15','2015-05-16','2015-05-17','2015-05-18','2015-05-19','2015-05-20','2015-05-21','2015-05-22','2015-05-23','2015-05-24','2015-05-25','2015-05-26','2015-05-27']
	}
	arrayAppend(arrTest, ts); 


 	ts={
		id:"Rule 18",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=TU;COUNT=4;FREQ=MONTHLY;INTERVAL=2",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2015-05-12','2015-05-19','2015-05-26','2015-07-07']
	}
	arrayAppend(arrTest, ts); 

 	ts={
		id:"Rule 19",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=1;BYDAY=+3TH;COUNT=0;FREQ=YEARLY;INTERVAL=1;UNTIL=20210413T040000Z",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2016-02-18','2017-02-16','2018-02-15','2019-02-21','2020-02-20','2021-02-18']
	}
	arrayAppend(arrTest, ts); 


 	ts={
		id:"Rule 20",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=0;BYDAY=SU;COUNT=4;FREQ=YEARLY;INTERVAL=2",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2017-01-01','2017-01-08','2017-01-15','2017-01-22']
	}
	arrayAppend(arrTest, ts); 


 	ts={
		id:"Rule 22",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=0;BYDAY=+3TH;COUNT=4;FREQ=YEARLY;INTERVAL=1",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2016-01-21','2017-01-19','2018-01-18','2019-01-17']
	}
	arrayAppend(arrTest, ts); 

	ts={
		id:"Rule 21",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=0;BYDAY=+1MO;COUNT=0;FREQ=YEARLY;INTERVAL=2;UNTIL=20190513T040000Z",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2017-01-02','2019-01-07']
	}
	arrayAppend(arrTest, ts);

	ts={
		id:"Rule 22",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=MO,WE;COUNT=4;FREQ=WEEKLY;INTERVAL=1",
		excludeDayList:"10/12/2015",
		arrCorrectDates:['2015-05-08','2015-05-11','2015-05-13','2015-05-18','2015-05-20']
	}
	arrayAppend(arrTest, ts);

	ts={
		id:"Rule 23",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=MO,TU,WE,TH,FR;COUNT=7;FREQ=DAILY;INTERVAL=1",
		excludeDayList:"10/12/2015",
		arrCorrectDates:['2015-05-08','2015-05-11','2015-05-12','2015-05-13','2015-05-14','2015-05-15','2015-05-18']
	}
	arrayAppend(arrTest, ts);
	
	ts={
		id:"Rule 24",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"COUNT=7;FREQ=DAILY;INTERVAL=2",
		excludeDayList:"10/12/2015",
		arrCorrectDates:['2015-05-08','2015-05-10','2015-05-12','2015-05-14','2015-05-16','2015-05-18','2015-05-20']
	}
	arrayAppend(arrTest, ts); 


 	ts={
		id:"Rule 25",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=MO,TU,WE,TH,FR,SA,SU;COUNT=30;FREQ=MONTHLY;INTERVAL=2",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2015-05-09','2015-05-10','2015-05-11','2015-05-12','2015-05-13','2015-05-14','2015-05-15','2015-05-16','2015-05-17','2015-05-18','2015-05-19','2015-05-20','2015-05-21','2015-05-22','2015-05-23','2015-05-24','2015-05-25','2015-05-26','2015-05-27','2015-05-28','2015-05-29','2015-05-30','2015-05-31','2015-07-01','2015-07-02','2015-07-03','2015-07-04','2015-07-05','2015-07-06']
	}
	arrayAppend(arrTest, ts);

 	ts={
		id:"Rule 26",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYMONTH=0;BYDAY=MO,TU,WE,TH,FR,SA,SU;COUNT=30;FREQ=YEARLY;INTERVAL=1",
		excludeDayList:"",
		arrCorrectDates:['2015-05-08','2016-01-01','2016-01-02','2016-01-03','2016-01-04','2016-01-05','2016-01-06','2016-01-07','2016-01-08','2016-01-09','2016-01-10','2016-01-11','2016-01-12','2016-01-13','2016-01-14','2016-01-15','2016-01-16','2016-01-17','2016-01-18','2016-01-19','2016-01-20','2016-01-21','2016-01-22','2016-01-23','2016-01-24','2016-01-25','2016-01-26','2016-01-27','2016-01-28','2016-01-29','2016-01-30']
	}
	arrayAppend(arrTest, ts);

	ts={
		id:"Rule 27",
		startDate:"5/8/2015",
		endDate:"5/8/2015",
		rule:"BYDAY=+1TH;COUNT=0;FREQ=MONTHLY;INTERVAL=1;UNTIL=20150729T040000Z",
		excludeDayList:"",
		arrCorrectDates:["2015-05-08","2015-06-04","2015-07-02"]
	}
	arrayAppend(arrTest, ts);
	return arrTest;
   
</cfscript>

</cffunction>
	

<cffunction name="getTestJson" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	arrTest=getTests();
	ts={
		success:true,
		arrTest:arrTest
	}
	application.zcore.functions.zReturnJson(ts);
	</cfscript>	
</cffunction>

<cffunction name="testPlainEnglishRules" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	setting requesttimeout="10";
	request.ical=createobject("component", "zcorerootmapping.com.ical.ical");
	request.ical.init("");

	arrTest=getTests();
	for(i=1;i LTE arraylen(arrTest);i++){
		a=request.ical.getIcalRuleAsPlainEnglish(arrTest[i].rule);
		echo(arrTest[i].rule&"<br>"&a&"<hr>");
	}
	echo('All tests done');
	abort;
	</cfscript>
</cffunction>

<cffunction name="testRules" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	setting requesttimeout="10";
	request.ical=createobject("component", "zcorerootmapping.com.ical.ical");
	request.ical.init("");

	arrTest=getTests();
	for(i=1;i LTE arraylen(arrTest);i++){
		testRule(arrTest[i]);
	}

	echo('All server-side rules passed.<br />Open browser console, and click <a href="/z/event/admin/recurring-event/index?runTests=1">run javascript tests</a> and <a href="/z/event/event/testPlainEnglishRules">run plain english tests</a>');abort;
	</cfscript>
</cffunction>
	


<cffunction name="getDateRangeString" access="public" localmode="modern">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	rs=getDateRangeStruct(arguments.row);
	return rs.dateRange;
	</cfscript>
</cffunction>

<cffunction name="getTimeRangeString" access="public" localmode="modern">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	rs=getDateRangeStruct(arguments.row);
	return rs.timeRange;
	</cfscript>
</cffunction>

<cffunction name="getDateTimeRangeString" access="public" localmode="modern">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	rs=getDateRangeStruct(arguments.row);
	return rs.dateTimeRange;
	</cfscript>
</cffunction>
	
	

<cffunction name="getDateRangeStruct" access="public" localmode="modern">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	rs={};
	rs.startDate=dateformat(row.event_start_datetime, 'm/d/yyyy');
	rs.startTime=timeformat(row.event_start_datetime, 'h:mm tt');
	rs.endTime=timeformat(row.event_end_datetime, 'h:mm tt');
	if(row.event_allday EQ 1 or (rs.startTime EQ "12:00 AM" and rs.endTime EQ "12:00 AM")){
		rs.startTime="";
		rs.endTime="";
	}
	rs.dateRange=rs.startDate;
	rs.timeRange=rs.startTime;
	rs.endDate=dateformat(row.event_end_datetime, 'm/d/yyyy');
	if(rs.startDate != rs.endDate){
		rs.dateRange&=" to "&rs.endDate;
		if(rs.startTime NEQ ""){
			rs.timeRange&=" to "&rs.endTime;
			rs.dateTimeRange=rs.startDate&" at "&rs.startTime&" to "&rs.endDate&" at "&rs.endTime;
		}else{
			rs.dateTimeRange=rs.startDate&" to "&rs.endDate;
		}
	}else{
		if(rs.startTime NEQ ""){
			if(rs.startTime NEQ rs.endTime){
				rs.dateTimeRange=rs.startDate&" at  "&rs.startTime&" to "&rs.endTime;
			}else{
				rs.dateTimeRange=rs.startDate&" at  "&rs.startTime;
			}
		}else{
			rs.dateTimeRange=rs.startDate;
		}
	} 
	return rs;
	</cfscript>
</cffunction>

<!--- 
ts={
	searchStruct:{
		calendarids:1,
		offset:0,
		perpage:3
	},
	renderCFC: componentInstance,
	renderFunction: "displayEvent"
}
application.zcore.app.getAppCFC("event").displayUpcomingEvents(ts);
 --->
<cffunction name="displayUpcomingEvents" access="public" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	rs=searchEvents(ss.searchStruct);
	if(arraylen(rs.arrData) EQ 0){
		echo('<p>There are no upcoming events at this time.</p>');
	}
	for(i=1;i LTE arraylen(rs.arrData);i++){
		c=rs.arrData[i];
		if(structkeyexists(ss, 'renderCFC')){
			ss.renderCFC[ss.renderMethod](c);
		}else{
			echo(c.event_name&"<br />");
		}
	}
	</cfscript>

</cffunction>


<!--- 
ts={
	searchCalendars:true,
	searchCategories:true,
	searchKeyword:true
};
application.zcore.app.getAppCFC("event").displayEventSearchForm(ts);
 --->
<cffunction name="displayEventSearchForm" access="public" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ts={
		searchCalendars:true,
		searchCategories:true,
		searchKeyword:true
	};
	structappend(arguments.ss, ts, false);
	ss=arguments.ss;
	db=request.zos.queryObject;
	application.zcore.functions.zRequireJqueryUI();

	form.startdate=application.zcore.functions.zso(form, 'startdate');
	form.enddate=application.zcore.functions.zso(form, 'enddate');
	form.calendarids=application.zcore.functions.zso(form, 'calendarids');
	form.categories=application.zcore.functions.zso(form, 'categories');
	form.keyword=application.zcore.functions.zso(form, 'keyword');

	arrCalendar=listToArray(form.calendarids, ",");
	calendarSelectedStruct={};
	for(i=1;i<=arrayLen(arrCalendar);i++){
		calendarSelectedStruct[arrCalendar[i]]=true;
	}
	arrCategory=listToArray(form.categories, ",");
	categorySelectedStruct={};
	for(i=1;i<=arrayLen(arrCategory);i++){
		categorySelectedStruct[arrCategory[i]]=true;
	}

	redirectToCalendar=false;
	if(request.zos.originalURL NEQ "/z/event/event-search/index"){
		redirectToCalendar=true;
	}
	</cfscript>
	<div class="zEventSearchForm">
		<div class="zEventSearchHeading">Dates:</div>
		<div class="zEventSearchDateField">
			<div class="zEventSearchSubHeading">Start Date:</div>
			<div class="zEventSearchField">
				<input type="text" size="10" name="startdate" id="zEventSearchStartDate" value="#form.startdate#" />
			</div>
			<div class="zEventSearchSubHeading">End Date:</div>
			<div class="zEventSearchField">
				<input type="text" size="10" name="enddate" id="zEventSearchEndDate" value="#form.enddate#" />
			</div>
			<cfif ss.searchKeyword>
				<div class="zEventSearchHeading">Keyword:</div>
				<div class="zEventSearchField">
					<input type="text" size="10" name="keyword" id="zEventSearchKeyword" value="#form.keyword#" />
				</div>
			</cfif>
		</div>

		<cfscript>
		if(ss.searchCalendars){
			arrCalendar=getCalendarIdsUserHasAccessTo();
			calendarids=arrayToList(arrCalendar, ",");
			db.sql="SELECT * FROM #db.table("event_calendar", request.zos.zcoreDatasource)#  
			WHERE site_id =#db.param(request.zos.globals.id)# and 
			event_calendar_deleted = #db.param(0)# and 
			event_calendar_searchable = #db.param(1)# and 
			event_calendar_id IN (#db.trustedSQL(calendarids)#) 
			ORDER BY event_calendar_name ASC";
			qCalendar=db.execute("qCalendar");

			if(qCalendar.recordcount NEQ 0){
				echo('<div class="zEventSearchHeading">Calendar:</div>
					<div class="zEventSearchField">');
				for(row in qCalendar){
					echo('<div class="zEventSearchFieldItem">
					<div class="zEventSearchFieldItem1">
						<input type="checkbox" name="calendarids" class="zEventSearchCalendar" value="#row.event_calendar_id#" ');
					if(structkeyexists(calendarSelectedStruct, row.event_calendar_id)){
						echo('checked="checked"');
					}
					echo(' />
					</div>
					<div class="zEventSearchFieldItem2"> #htmleditformat(row.event_calendar_name)#</label></div>
					</div>');
				}
				echo('</div>');
			}
		}


		if(ss.searchCategories){
			db.sql="SELECT * FROM #db.table("event_category", request.zos.zcoreDatasource)# 
			WHERE site_id =#db.param(request.zos.globals.id)# and 
			event_category_deleted = #db.param(0)# and 
			event_category_searchable = #db.param(1)#  and 
			event_calendar_id IN (#db.trustedSQL(calendarids)#) 
			ORDER BY event_category_name ASC";
			qCategory=db.execute("qCategory");

			if(qCategory.recordcount NEQ 0){
				echo('<div class="zEventSearchHeading">Category:</div>
					<div class="zEventSearchField">');
				for(row in qCategory){
					echo('<div class="zEventSearchFieldItem">
					<div class="zEventSearchFieldItem1">
						<input type="checkbox" name="categories" class="zEventSearchCategory" value="#row.event_category_id#" ');
					if(structkeyexists(categorySelectedStruct, row.event_category_id)){
						echo('checked="checked"');
					}
					echo(' />
					</div>
					<div class="zEventSearchFieldItem2"> #htmleditformat(row.event_category_name)#</label>
					</div>
					</div>');
				}
				echo('</div>');
			}
		}
		</cfscript>

		<div class="zEventSearchField">
			<input type="button" size="10" name="zSearchEventButton" id="zSearchEventButton" value="Search Events" />
		</div>

	</div>

	<script type="text/javascript">
	/* <![CDATA[ */
	zArrDeferredFunctions.push(function(){
		zEventSearchSetupForm();
	});
	/* ]]> */
	</script>
</cffunction>


<!--- 
ts={
	// all criteria optional
	ss.event_recur_id:"",
	ss.event_id:"",
	ss.categories:"",
	ss.keyword:"",
	ss.onlyFutureEvents:"",
 	ss.startDate:"",
 	ss.endDate:"",
 	ss.calendarids:""
};
searchEvents(ts);
 --->
<cffunction name="searchEvents" access="public" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	db=request.zos.queryObject;
	ss.perpage=application.zcore.functions.zso(ss, 'perpage', true, 10);
	ss.offset=application.zcore.functions.zso(ss, 'offset', true);
	ss.event_recur_id=application.zcore.functions.zso(ss, 'event_recur_id', true);
	ss.event_id=application.zcore.functions.zso(ss, 'event_id', true);
	ss.categories=application.zcore.functions.zso(ss, 'categories');
	ss.keyword=application.zcore.functions.zso(ss, 'keyword');
	ss.onlyFutureEvents=application.zcore.functions.zso(ss, 'onlyFutureEvents', false, 1);
 	ss.startDate=application.zcore.functions.zso(ss, 'startDate');
 	ss.endDate=application.zcore.functions.zso(ss, 'endDate'); 
 	ss.calendarids=application.zcore.functions.zso(ss, 'calendarids');
 	ss.showinactive=application.zcore.functions.zso(ss, 'showinactive');
	if(not application.zcore.user.checkGroupAccess("member")){
		ss.showInactive=false;
	}

	ss.keyword=replace(replace(ss.keyword, '+', '%', 'all'), ' ', '%', 'all');

	arrCategory=listToArray(ss.categories, ',');
	if(arraylen(arrCategory)){
		arrCategory2=[];
		for(i=1;i LTE arraylen(arrCategory);i++){
			if(isnumeric(trim(arrCategory[i]))){
				arrayAppend(arrCategory2, arrCategory[i]);
			}
		}
		arrCategory=arrCategory2;
	}
	calendarIdList="";
	arrCalendar=listToArray(ss.calendarids, ",");
	if(arraylen(arrCalendar)){
		arrCalendar2=[];
		for(i=1;i LTE arraylen(arrCalendar);i++){
			if(isnumeric(trim(arrCalendar[i]))){
				arrayAppend(arrCalendar2, arrCalendar[i]);
			}
		}
		calendarIdList=arrayToList(arrCalendar2, ",");
	}
	ts=structnew();
	ts.image_library_id_field="event.event_image_library_id";
	ts.count = 1; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="select *
	#db.trustedsql(rs2.select)# from 
	(#db.table("event", request.zos.zcoreDatasource)# , 
	#db.table("event_recur", request.zos.zcoreDatasource)#) 
	#db.trustedsql(rs2.leftJoin)#
	WHERE 
	event.site_id = event_recur.site_id and 
	event.event_id = event_recur.event_id and 
	event_recur_deleted=#db.param(0)# and 
	event.site_id = #db.param(request.zos.globals.id)# and 
	event_deleted=#db.param(0)# ";
	if(ss.showInactive NEQ 1){
		db.sql&=" and event.event_status=#db.param(1)# ";
	}
	if(ss.event_id NEQ 0){
		db.sql&=" and event.event_id = #db.param(ss.event_id)# ";
	}
	if(ss.event_recur_id NEQ 0){
		db.sql&=" and event_recur_id = #db.param(ss.event_recur_id)# ";
	}
	if(ss.onlyFutureEvents){
		searchOn=true; 
		db.sql&=" and event_recur_end_datetime >= #db.param(dateformat(now(), 'yyyy-mm-dd')&' 00:00:00')# ";
	}
	if(ss.startDate NEQ "" and isdate(ss.startDate)){
		searchOn=true; 
		db.sql&=" and event_recur_end_datetime >= #db.param(dateformat(ss.startDate, 'yyyy-mm-dd')&' 00:00:00')# ";
	}
	if(ss.endDate NEQ "" and isdate(ss.endDate)){
		searchOn=true;
		db.sql&=" and event_recur_start_datetime <= #db.param(dateformat(ss.endDate, 'yyyy-mm-dd')&' 23:59:59')# ";
	}
	if(ss.keyword NEQ ""){
		searchOn=true;
		db.sql&=" and concat(event.event_id, #db.param(' ')#, event_name, #db.param(' ')#, event_description)  like #db.param('%#ss.keyword#%')# ";
	}
	if(arraylen(arrCategory)){
		db.sql&=" and ( ";
		searchOn=true;
		for(i=1;i LTE arraylen(arrCategory);i++){
			if(i NEQ 1){
				db.sql&=" or ";
			}
			db.sql&=" CONCAT(#db.param(',')#,event_category_id, #db.param(',')#) LIKE #db.param('%,'&arrCategory[i]&',%')# ";
		}
		db.sql&=" ) ";
	}
	if(arraylen(arrCalendar)){
		db.sql&=" and ( ";
		searchOn=true;
		for(i=1;i LTE arraylen(arrCalendar);i++){
			if(i NEQ 1){
				db.sql&=" or ";
			}
			db.sql&=" CONCAT(#db.param(',')#,event_calendar_id, #db.param(',')#) LIKE #db.param('%,'&arrCalendar[i]&',%')# ";
		}
		db.sql&=" ) ";
	}
	/*if(calendarIdList NEQ ""){
		searchOn=true;
		db.sql&=" and event_calendar_id IN (#db.trustedSQL(calendarIdList)#) ";
	}*/
	db.sql&=" GROUP BY event_recur.event_recur_id
	ORDER BY event_featured desc, event_recur_start_datetime ASC, event_recur_end_datetime ASC
	 LIMIT #db.param(ss.offset)#, #db.param(ss.perpage)# ";
	qList=db.execute("qList");
	if(request.zos.isdeveloper and structkeyexists(form, 'zdebug')){
		writedump(qList);
	}

	if(ss.offset EQ 0 and (qList.recordcount EQ 1 or qList.recordcount LT ss.perpage)){
		qCount={count:qList.recordcount};
	}else{

		db.sql="select count(event_recur_id) count from 
		#db.table("event", request.zos.zcoreDatasource)#, 
		#db.table("event_recur", request.zos.zcoreDatasource)# WHERE 
		event.site_id = event_recur.site_id and 
		event.event_id = event_recur.event_id and 
		event_recur_deleted=#db.param(0)# and 
		event.site_id = #db.param(request.zos.globals.id)# and 
		event_deleted=#db.param(0)# ";
		if(ss.showInactive NEQ 1){
			db.sql&=" and event.event_status=#db.param(1)# ";
		}
		if(ss.event_id NEQ 0){
			db.sql&=" and event.event_id = #db.param(ss.event_id)# ";
		}
		if(ss.event_recur_id NEQ 0){
			db.sql&=" and event_recur_id = #db.param(ss.event_recur_id)# ";
		}
		if(ss.onlyFutureEvents){
			searchOn=true; 
			db.sql&=" and event_recur_end_datetime >= #db.param(dateformat(now(), 'yyyy-mm-dd')&' 00:00:00')# ";
		}
		if(ss.startDate NEQ "" and isdate(ss.startDate)){
			searchOn=true; 
			db.sql&=" and event_recur_end_datetime >= #db.param(dateformat(ss.startDate, 'yyyy-mm-dd'))# ";
		}
		if(ss.endDate NEQ "" and isdate(ss.endDate)){
			searchOn=true;
			db.sql&=" and event_recur_start_datetime <= #db.param(dateformat(ss.endDate, 'yyyy-mm-dd'))# ";
		}
		if(ss.keyword NEQ ""){
			searchOn=true;
			db.sql&=" and concat(event.event_id, #db.param(' ')#, event_name, #db.param(' ')#, event_description)  like #db.param('%#ss.keyword#%')# ";
		}
		if(arraylen(arrCategory)){
			db.sql&=" and ( ";
			searchOn=true;
			for(i=1;i LTE arraylen(arrCategory);i++){
				if(i NEQ 1){
					db.sql&=" or ";
				}
				db.sql&=" CONCAT(#db.param(',')#,event_category_id, #db.param(',')#) LIKE #db.param('%,'&arrCategory[i]&',%')# ";
			}
			db.sql&=" ) ";
		}
		if(arraylen(arrCalendar)){
			db.sql&=" and ( ";
			searchOn=true;
			for(i=1;i LTE arraylen(arrCalendar);i++){
				if(i NEQ 1){
					db.sql&=" or ";
				}
				db.sql&=" CONCAT(#db.param(',')#,event_calendar_id, #db.param(',')#) LIKE #db.param('%,'&arrCalendar[i]&',%')# ";
			}
			db.sql&=" ) ";
		}
		/*if(calendarIdList NEQ ""){
			searchOn=true;
			db.sql&=" and event_calendar_id IN (#db.trustedSQL(calendarIdList)#) ";
		}*/
		qCount=db.execute("qCount"); 
	}
	arrData=[];
	eventCom=application.zcore.app.getAppCFC("event");
	hasPhotos=false;
	for(row in qList){
		if(row.event_recur_ical_rules NEQ ""){
			row.__url=eventCom.getEventRecurURL(row);
		}else{
			row.__url=eventCom.getEventURL(row);
		}
		row.event_start_datetime=row.event_recur_start_datetime;
		row.event_end_datetime=row.event_recur_end_datetime;
		/*
		if(timeformat(row.event_end_datetime, 'h:mm tt') EQ '12:00 am'){
			row.event_end_datetime=dateadd(row.event_end_datetime, 'yyyy-mm-dd')&' 23:59:59';
		}*/
		hasPhotos=true;
		arrayAppend(arrData, row);
	}
	return { count: qCount.count, hasPhotos:hasPhotos, arrData: arrData };
	</cfscript>
</cffunction>

	
<!--- application.zcore.app.getAppCFC("event").searchReindexCalendar(false, true); --->
<cffunction name="searchReindexCalendar" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexEverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT event_calendar.*, event_config_event_url_id FROM #db.table("event_calendar", request.zos.zcoreDatasource)#,
		#db.table("event_config", request.zos.zcoreDatasource)# 
		WHERE 
		event_config.site_id = event_calendar.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and event_calendar.site_id = #db.param(request.zos.globals.id)# ";
		}else{
			db.sql&=" and event_calendar.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and event_calendar_id = #db.param(arguments.id)# ";
		}
		db.sql&=" and 
		event_calendar_deleted=#db.param(0)# and 
		event_config_deleted =#db.param(0)#	
		LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteEvent(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.event_calendar_name&" "&row.event_calendar_description;
				ds.search_title=row.event_calendar_name;
				//if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.event_calendar_description;
				//}
				ds.search_summary=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(ds.search_summary), 150);
				
				ds.search_url=getCalendarURL(row);
				ds.search_table_id="event-calendar-"&row.event_calendar_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=dateformat(row.event_calendar_updated_datetime, "yyyy-mm-dd")&" "&timeformat(row.event_calendar_updated_datetime, "HH:mm:ss");
				ds.site_id=row.site_id;
				
				searchCom.saveSearchIndex(ds); 
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and  
		search_table_id LIKE #db.param('event-calendar-%')# and
		search_deleted = #db.param(0)# and
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>
	
<!--- application.zcore.app.getAppCFC("event").searchReindexEvent(false, true); --->
<cffunction name="searchReindexEvent" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexEverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT event.*, event_config_event_url_id FROM #db.table("event", request.zos.zcoreDatasource)#,
		#db.table("event_config", request.zos.zcoreDatasource)# 
		WHERE 
		event_config.site_id = event.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and event.site_id = #db.param(request.zos.globals.id)# ";
		}else{
			db.sql&=" and event.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and event_id = #db.param(arguments.id)# ";
		}
		db.sql&=" and event_status = #db.param(1)# and  
		event_deleted=#db.param(0)# and 
		event_config_deleted =#db.param(0)#	
		LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteEvent(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.event_name&" "&row.event_description;
				ds.search_title=row.event_name;
				//if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.event_description;
				//}
				ds.search_summary=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(ds.search_summary), 150);
				
				ds.search_url=getEventURL(row);
				ds.search_table_id="event-"&row.event_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=dateformat(row.event_updated_datetime, "yyyy-mm-dd")&" "&timeformat(row.event_updated_datetime, "HH:mm:ss");
				ds.site_id=row.site_id;
				
				searchCom.saveSearchIndex(ds); 
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and  
		search_table_id LIKE #db.param('event-%')# and
		search_deleted = #db.param(0)# and
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>
	
	
<!--- application.zcore.app.getAppCFC("event").searchIndexDeleteContent(event_id); --->
<cffunction name="searchIndexDeleteEvent" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_table_id = #db.param("event-"&arguments.id)# and 
	search_deleted = #db.param(0)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>

	
<!--- application.zcore.app.getAppCFC("event").searchIndexDeleteContent(event_category_id); --->
<cffunction name="searchIndexDeleteCategory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_table_id = #db.param("event-category-"&arguments.id)# and 
	search_deleted = #db.param(0)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>

	
<!--- application.zcore.app.getAppCFC("event").searchIndexDeleteContent(event_calendar_id); --->
<cffunction name="searchIndexDeleteCalendar" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_table_id = #db.param("event-calendar-"&arguments.id)# and 
	search_deleted = #db.param(0)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>


<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var theText="";
	var qconfig=0;
	var t9=0;
	var qcontent=0;
	var link=0;
	var t999=0;
	var pos=0;
	db.sql="SELECT * FROM #db.table("event_config", request.zos.zcoreDatasource)# event_config, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_id = app_x_site.site_id and 
	app_x_site.site_id = event_config.site_id and 
	event_config.site_id = #db.param(arguments.site_id)# and 
	event_config_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	site_deleted = #db.param(0)#";
	qConfig=db.execute("qConfig");  
	loop query="qConfig"{
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_event_url_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_category_url_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_calendar_url_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_event_recur_url_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_event_next_recur_url_id]=[];
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/event/view-event/viewRecurringEvent";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/view-event/viewRecurringEvent";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="event_recur_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_event_recur_url_id],t9); 
		t9={};
		t9.type=1;
		t9.scriptName="/z/event/view-event/viewNextRecurringEvent"; 
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/view-event/viewNextRecurringEvent";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="event_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_event_next_recur_url_id],t9); 
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/event/view-event/viewEvent";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/view-event/viewEvent";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="event_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_event_url_id],t9); 
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/event/event-category/viewCategory";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/event-category/viewCategory";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="event_category_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_category_url_id],t9); 
		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/event/event-calendar/viewCalendar";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/event-calendar/viewCalendar";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="calendarids";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.event_config_calendar_url_id],t9);  

		db.sql="SELECT * from #db.table("event", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(arguments.site_id)# and 
		event_unique_url<>#db.param('')# and 
		event_deleted = #db.param(0)#
		ORDER BY event_unique_url DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/event/view-event/viewEvent";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/view-event/viewEvent";
			t9.urlStruct.event_id=qF.event_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.event_unique_url)]=t9;
		}
		db.sql="SELECT * from #db.table("event_calendar", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(arguments.site_id)# and 
		event_calendar_unique_url<>#db.param('')# and 
		event_calendar_deleted = #db.param(0)#
		ORDER BY event_calendar_unique_url DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/event/event-calendar/viewCalendar";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/event-calendar/viewCalendar";
			t9.urlStruct.calendarids=qF.event_calendar_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.event_calendar_unique_url)]=t9;
		}
		db.sql="SELECT * from #db.table("event_category", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(arguments.site_id)# and 
		event_category_unique_url<>#db.param('')# and 
		event_category_deleted = #db.param(0)#
		ORDER BY event_category_unique_url DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/event/event-category/viewCategory";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/event-category/viewCategory";
			t9.urlStruct.event_category_id=qF.event_category_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.event_category_unique_url)]=t9;
		}
	} 
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRuleEvent" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * from #db.table("event", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	event_unique_url<>#db.param('')# and 
	event_id=#db.param(arguments.id)# and 
	event_deleted = #db.param(0)#
	ORDER BY event_unique_url DESC";
	qF=db.execute("qF");
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/event/view-event/viewEvent";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/view-event/viewEvent";
		t9.urlStruct.event_id=qF.event_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.event_unique_url)]=t9;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRuleCategory" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * from #db.table("event_category", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	event_category_unique_url<>#db.param('')# and 
	event_category_id=#db.param(arguments.id)# and 
	event_category_deleted = #db.param(0)#
	ORDER BY event_category_unique_url DESC";
	qF=db.execute("qF");
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/event/event-category/viewCategory";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/event-category/viewCategory";
		t9.urlStruct.event_category_id=qF.event_category_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.event_category_unique_url)]=t9;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRuleCalendar" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * from #db.table("event_calendar", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	event_calendar_unique_url<>#db.param('')# and 
	event_calendar_id=#db.param(arguments.id)# and 
	event_calendar_deleted = #db.param(0)#
	ORDER BY event_calendar_unique_url DESC";
	qF=db.execute("qF");
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/event/event-calendar/viewCalendar";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/event/event-calendar/viewCalendar";
		t9.urlStruct.calendarids=qF.event_calendar_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.event_calendar_unique_url)]=t9;
	}
	return true;
	</cfscript>
</cffunction> 
	
<cffunction name="updateRewriteRules" localmode="modern" output="no" access="public" returntype="boolean">
	<cfscript>
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	return true;
	</cfscript>
</cffunction>

<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from config table.">
	<!--- delete all content and content_group and images? --->
	<cfscript>
	var db=request.zos.queryObject;
	var qconfig=0;
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	db.sql="DELETE FROM #db.table("event_config", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	event_config_deleted = #db.param(0)#	";
	qConfig=db.execute("qConfig");
	return rCom;
	</cfscript>   
</cffunction>

<cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="validate" required="no" type="boolean" default="#false#">
	<cfscript>
	var field="";
	var i=0;
	var error=false;
	var df=structnew();

	df.event_config_project_recurrence_days=365;
	for(i in df){	
		if(arguments.validate){
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
				error=true;
				field=trim(lcase(replacenocase(replacenocase(i,"event_config_",""),"_"," ","ALL")));
				application.zcore.status.setStatus(request.zsid,"#field# is required.",form);
			}
		}else{
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){			
				form[i]=df[i];
			}
		}
	}
	if(error){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="configSave" localmode="modern" output="no" access="remote" returntype="any" hint="saves the application data submitted by the change() form.">
	<cfscript>
	var ts=StructNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var result='';

	if(this.loadDefaultConfig(true) EQ false){
		rCom.setError("Please correct the above validation errors and submit again.",1);
		return rCom;
	}	
	form.site_id=form.sid; 
	ts=StructNew();
	ts.arrId=arrayNew(1);
	arrayappend(ts.arrId,trim(form.event_config_category_url_id));
	arrayappend(ts.arrId,trim(form.event_config_calendar_url_id));
	arrayappend(ts.arrId,trim(form.event_config_event_url_id));
	arrayappend(ts.arrId,trim(form.event_config_event_recur_url_id));
	arrayappend(ts.arrId,trim(form.event_config_event_next_recur_url_id));
	ts.site_id=form.site_id;
	ts.app_id=this.app_id;
	rCom=application.zcore.app.reserveAppUrlId(ts);
	if(rCom.isOK() EQ false){
		return rCom;
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=configForm&app_x_site_id=#this.app_x_site_id#&zsid=#request.zsid#");
		application.zcore.functions.zabort();
	} 
	form.event_config_project_recurrence_days=application.zcore.functions.zso(form, 'event_config_project_recurrence_days', true);
	form.event_config_deleted=0;
	form.event_config_updated_datetime=request.zos.mysqlnow;
	ts.table="event_config";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zso(form, 'event_config_id',true) EQ 0){ // insert
		result=application.zcore.functions.zInsert(ts);  
		if(result EQ false){
			rCom.setError("Failed to save configuration.",2);
			return rCom;
		}
	}else{ // update
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			rCom.setError("Failed to save configuration.",3);
			return rCom;
		}
	}
	application.zcore.status.setStatus(request.zsid,"Configuration saved.");
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
   	<cfscript>
	var db=request.zos.queryObject;
	var ts='';
	var selectStruct='';
	var rs=structnew();
	var qConfig='';
	var theText='';
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	savecontent variable="theText"{
		db.sql="SELECT * FROM #db.table("event_config", request.zos.zcoreDatasource)# event_config 
		WHERE site_id = #db.param(form.sid)# and 
		event_config_deleted = #db.param(0)#";
		qConfig=db.execute("qConfig");
		application.zcore.functions.zQueryToStruct(qConfig);//, "configStruct");
		if(qConfig.recordcount EQ 0){
			this.loadDefaultConfig();
		} 
		application.zcore.functions.zStatusHandler(request.zsid,true);
		echo('<input type="hidden" name="event_config_id" value="#form.event_config_id#" />
		<table style="border-spacing:0px;" class="table-list">');
		echo('
		<tr>
		<th>ICal URL List:</th>
		<td>');
		ts = StructNew();
		ts.name = "event_config_ical_url_list";
		application.zcore.functions.zInput_Text(ts);
		echo('<br />(A comma separated list of urls to import on a daily basis.)</td>
		</tr>
		<tr>
		<th>Project Recurrence ## of Days:</th>
		<td>');
		ts = StructNew();
		ts.name = "event_config_project_recurrence_days";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Event URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("event_config_event_url_id", form.event_config_event_url_id, this.app_id));
		echo('</td>
		</tr>
		<tr>
		<th>Event Recur URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("event_config_event_recur_url_id", form.event_config_event_recur_url_id, this.app_id));
		echo('</td>
		</tr>
		<tr>
		<th>Event Next Recur URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("event_config_event_next_recur_url_id", form.event_config_event_next_recur_url_id, this.app_id));
		echo('</td>
		</tr>
		<tr>
		<th>Calendar URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("event_config_calendar_url_id", form.event_config_calendar_url_id, this.app_id));
		echo('</td>
		</tr>
		<tr>
		<th>Category URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("event_config_category_url_id", form.event_config_category_url_id, this.app_id));
		echo('</td>
		</tr> 

		<tr>
		<th>Disable Other Month Days:</th>
		<td>');

		if(form.event_config_disable_other_month_days EQ ""){
			form.event_config_disable_other_month_days=0;
		}
		echo(application.zcore.functions.zInput_Boolean("event_config_disable_other_month_days"));
		echo(' (This disables events from other months appearring at beginning and end of 30 day calendar.)</td>
		</tr>
		<tr>
		<th>Enable Suggest Event:</th>
		<td>');

		if(form.event_config_enable_suggest_event EQ ""){
			form.event_config_enable_suggest_event=0;
		}
		echo(application.zcore.functions.zInput_Boolean("event_config_enable_suggest_event"));
		echo('</td>
		</tr>
		<tr>
		<th>Enable Add To Calendar:</th>
		<td>');
		echo(application.zcore.functions.zInput_Boolean("event_config_add_to_calendar_enabled"));
		echo('<br>Don''t enable this on any commercial web site.  It is only free for personal/non-profit use.</td>
		</tr>
		<tr>
		<th>Disable Robot Recurring<br />Event Indexing:</th>
		<td>');

		if(form.event_config_disable_recur_indexing EQ ""){
			form.event_config_disable_recur_indexing=1;
		}
		echo(application.zcore.functions.zInput_Boolean("event_config_disable_recur_indexing"));
		echo('</td>
		</tr>

		
		</table>');
	}
	rs.output=theText;
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
	<cfscript>

	application.zcore.skin.includeJS("/z/javascript/jetendo-event/calendar.js");
	</cfscript>
</cffunction>

<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
	<cfscript>
	
	</cfscript>
</cffunction>


<cffunction name="getEventRecurURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.event_unique_url NEQ ""){
		return row.event_unique_url&"?recurId="&row.event_recur_id;
	}else{
		urlId=application.zcore.app.getAppData("event").optionstruct.event_config_event_recur_url_id;
		return "/"&application.zcore.functions.zURLEncode(row.event_name, '-')&"-"&urlId&"-"&row.event_recur_id&".html";
	}
	</cfscript>
</cffunction>

<cffunction name="getEventURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.event_unique_url NEQ ""){
		return row.event_unique_url;
	}else{
		urlId=application.zcore.app.getAppData("event").optionstruct.event_config_event_url_id;
		return "/"&application.zcore.functions.zURLEncode(row.event_name, '-')&"-"&urlId&"-"&row.event_id&".html";
	}
	</cfscript>
</cffunction>

<cffunction name="getNextRecurringEventURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	urlId=application.zcore.app.getAppData("event").optionstruct.event_config_event_next_recur_url_id;
	if(row.event_unique_url NEQ ""){
		return row.event_unique_url&"?nextOccurrence=1";
	}else{
		return "/"&application.zcore.functions.zURLEncode(row.event_name, '-')&"-"&urlId&"-"&row.event_id&".html";
	}
	</cfscript>
</cffunction>


<cffunction name="getCategoryURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.event_category_unique_url NEQ ""){
		return row.event_category_unique_url;
	}else{
		urlId=application.zcore.app.getAppData("event").optionstruct.event_config_category_url_id;
		return "/"&application.zcore.functions.zURLEncode(row.event_category_name, '-')&"-"&urlId&"-"&row.event_category_id&".html";
	}
	</cfscript>
</cffunction>

<cffunction name="getCalendarURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.event_calendar_unique_url NEQ ""){
		return row.event_calendar_unique_url;
	}else{
		urlId=application.zcore.app.getAppData("event").optionstruct.event_config_calendar_url_id;
		return "/"&application.zcore.functions.zURLEncode(row.event_calendar_name, '-')&"-"&urlId&"-"&row.event_calendar_id&".html";
	}
	</cfscript>
</cffunction>

<cffunction name="getCalendarListURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.event_calendar_unique_url NEQ ""){
		return row.event_calendar_unique_url&"?zview=list";
	}else{
		urlId=application.zcore.app.getAppData("event").optionstruct.event_config_calendar_url_id;
		return "/"&application.zcore.functions.zURLEncode(row.event_calendar_name, '-')&"-"&urlId&"-"&row.event_calendar_id&".html?zview=list";
	}
	</cfscript>
</cffunction>


<!--- application.zcore.app.getAppCFC("event").getCalendarIdsUserHasAccessTo(); --->
<cffunction name="getCalendarIdsUserHasAccessTo" access="public" returntype="array" localmode="modern">
	<cfscript>
	ss=application.zcore.app.getAppData("event").sharedStruct;
	
	arrCalendar=[-1];
	for(id in ss.calendarCacheStruct){ 
		row=ss.calendarCacheStruct[id];
		if(row.event_calendar_user_group_idlist EQ ""){
			arrayAppend(arrCalendar, row.event_calendar_id);
		}else{
			c=listToArray(row.event_calendar_user_group_idlist, ",");
			for(n=1;n LTE arraylen(c);n++){
				if(application.zcore.user.checkGroupIdAccess(c[n])){
					arrayAppend(arrCalendar, row.event_calendar_id);
					break;
				}
			}
		}
	}
	return arrCalendar;
	</cfscript>
	
</cffunction>

<!--- application.zcore.app.getAppCFC("event").userHasAccessToEventCalendarID(event_calendar_id); --->
<cffunction name="userHasAccessToEventCalendarID" access="public" localmode="modern">
	<cfargument name="event_calendar_id" type="string" required="yes">
	<cfscript>
	arrCalendar=listToarray(arguments.event_calendar_id, ",");
	ss=application.zcore.app.getAppData("event").sharedStruct;
	hasAccess=false;
	for(i=1;i LTE arraylen(arrCalendar);i++){
		if(structkeyexists(ss.calendarAccessCacheStruct, arrCalendar[i])){
			c=ss.calendarAccessCacheStruct[arrCalendar[i]];
			if(arraylen(c) EQ 0){
				hasAccess=true;
			}else{
				for(n=1;n LTE arraylen(c);n++){
					if(c[n] NEQ "" and application.zcore.user.checkGroupIdAccess(c[n])){
						hasAccess=true;
						break;
					}
				}
			}
		}else{
			hasAccess=true;
		}
	}
	return hasAccess;
	</cfscript>
	
</cffunction>


<cffunction name="updateEventCalendarCache" access="public" localmode="modern">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	ts=arguments.sharedStruct;
	
	db=request.zos.queryObject;
	db.sql="select * from #db.table("event_calendar", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	event_calendar_deleted=#db.param(0)# ";
	qCalendar=db.execute("qCalendar");
	ts.calendarCacheStruct={};
	ts.calendarAccessCacheStruct={};
	for(row in qCalendar){
		ts.calendarCacheStruct[row.event_calendar_id]=row;
		ts.calendarAccessCacheStruct[row.event_calendar_id]=listToArray(row.event_calendar_user_group_idlist, ",");
	}
	</cfscript>
</cffunction>

<cffunction name="updateEventCategoryCache" access="public" localmode="modern">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	ts=arguments.sharedStruct;
	
	db=request.zos.queryObject;
	db.sql="select * from #db.table("event_category", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	event_category_deleted=#db.param(0)# ";
	qcategory=db.execute("qcategory");
	ts.categoryCacheStruct={};
	ts.categoryAccessCacheStruct={};
	for(row in qcategory){
		ts.categoryCacheStruct[row.event_category_id]=row;
	}
	</cfscript>
</cffunction>



<cffunction name="onSiteStart" access="public" localmode="modern">
	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
	<cfscript>
	ts={}; 
	updateEventCalendarCache(ts);
	updateEventCategoryCache(ts);
	

	ts.icalCom=createobject("component", "zcorerootmapping.com.ical.ical");
	ts.icalCom.init(""); 
	ts.timeZoneStruct={
"Africa/Abidjan":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Accra":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Addis_Ababa":{ offset: "+03:00", dstOffset: "+03:00"},
"Africa/Algiers":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Asmara":{ offset: "+03:00", dstOffset: "+03:00"},
"Africa/Asmera":{ offset: "+03:00", dstOffset: "+03:00"},
"Africa/Bamako":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Bangui":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Banjul":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Bissau":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Blantyre":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Brazzaville":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Bujumbura":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Cairo":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Casablanca":{ offset: "+00:00", dstOffset: "+01:00"},
"Africa/Ceuta":{ offset: "+01:00", dstOffset: "+02:00"},
"Africa/Conakry":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Dakar":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Dar_es_Salaam":{ offset: "+03:00", dstOffset: "+03:00"},
"Africa/Djibouti":{ offset: "+03:00", dstOffset: "+03:00"},
"Africa/Douala":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/El_Aaiun":{ offset: "+00:00", dstOffset: "+01:00"},
"Africa/Freetown":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Gaborone":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Harare":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Johannesburg":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Juba":{ offset: "+03:00", dstOffset: "+03:00"},
"Africa/Kampala":{ offset: "+03:00", dstOffset: "+03:00"},
"Africa/Khartoum":{ offset: "+03:00", dstOffset: "+03:00"},
"Africa/Kigali":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Kinshasa":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Lagos":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Libreville":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Lome":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Luanda":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Lubumbashi":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Lusaka":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Malabo":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Maputo":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Maseru":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Mbabane":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Mogadishu":{ offset: "+03:00", dstOffset: "+03:00"},
"Africa/Monrovia":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Nairobi":{ offset: "+03:00", dstOffset: "+03:00"},
"Africa/Ndjamena":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Niamey":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Nouakchott":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Ouagadougou":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Porto-Novo":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Sao_Tome":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Timbuktu":{ offset: "+00:00", dstOffset: "+00:00"},
"Africa/Tripoli":{ offset: "+02:00", dstOffset: "+02:00"},
"Africa/Tunis":{ offset: "+01:00", dstOffset: "+01:00"},
"Africa/Windhoek":{ offset: "+01:00", dstOffset: "+02:00"},
"America/Adak":{ offset: "−10:00", dstOffset: "−09:00"},
"America/Anchorage":{ offset: "−09:00", dstOffset: "−08:00"},
"America/Anguilla":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Antigua":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Araguaina":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/Buenos_Aires":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/Catamarca":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/ComodRivadavia":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/Cordoba":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/Jujuy":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/La_Rioja":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/Mendoza":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/Rio_Gallegos":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/Salta":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/San_Juan":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/San_Luis":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/Tucuman":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Argentina/Ushuaia":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Aruba":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Asuncion":{ offset: "−04:00", dstOffset: "−03:00"},
"America/Atikokan":{ offset: "−05:00", dstOffset: "−05:00"},
"America/Atka":{ offset: "−10:00", dstOffset: "−09:00"},
"America/Bahia":{ offset: "−03:00", dstOffset: "−02:00"},
"America/Bahia_Banderas":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Barbados":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Belem":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Belize":{ offset: "−06:00", dstOffset: "−06:00"},
"America/Blanc-Sablon":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Boa_Vista":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Bogota":{ offset: "−05:00", dstOffset: "−05:00"},
"America/Boise":{ offset: "−07:00", dstOffset: "−06:00"},
"America/Buenos_Aires":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Cambridge_Bay":{ offset: "−07:00", dstOffset: "−06:00"},
"America/Campo_Grande":{ offset: "−04:00", dstOffset: "−03:00"},
"America/Cancun":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Caracas":{ offset: "−04:30", dstOffset: "−04:30"},
"America/Catamarca":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Cayenne":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Cayman":{ offset: "−05:00", dstOffset: "−05:00"},
"America/Chicago":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Chihuahua":{ offset: "−07:00", dstOffset: "−06:00"},
"America/Coral_Harbour":{ offset: "−05:00", dstOffset: "−05:00"},
"America/Cordoba":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Costa_Rica":{ offset: "−06:00", dstOffset: "−06:00"},
"America/Creston":{ offset: "−07:00", dstOffset: "−07:00"},
"America/Cuiaba":{ offset: "−04:00", dstOffset: "−03:00"},
"America/Curacao":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Danmarkshavn":{ offset: "+00:00", dstOffset: "+00:00"},
"America/Dawson":{ offset: "−08:00", dstOffset: "−07:00"},
"America/Dawson_Creek":{ offset: "−07:00", dstOffset: "−07:00"},
"America/Denver":{ offset: "−07:00", dstOffset: "−06:00"},
"America/Detroit":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Dominica":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Edmonton":{ offset: "−07:00", dstOffset: "−06:00"},
"America/Eirunepe":{ offset: "−05:00", dstOffset: "−05:00"},
"America/El_Salvador":{ offset: "−06:00", dstOffset: "−06:00"},
"America/Ensenada":{ offset: "−08:00", dstOffset: "−07:00"},
"America/Fort_Wayne":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Fortaleza":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Glace_Bay":{ offset: "−04:00", dstOffset: "−03:00"},
"America/Godthab":{ offset: "−03:00", dstOffset: "−02:00"},
"America/Goose_Bay":{ offset: "−04:00", dstOffset: "−03:00"},
"America/Grand_Turk":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Grenada":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Guadeloupe":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Guatemala":{ offset: "−06:00", dstOffset: "−06:00"},
"America/Guayaquil":{ offset: "−05:00", dstOffset: "−05:00"},
"America/Guyana":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Halifax":{ offset: "−04:00", dstOffset: "−03:00"},
"America/Havana":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Hermosillo":{ offset: "−07:00", dstOffset: "−07:00"},
"America/Indiana/Indianapolis":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Indiana/Knox":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Indiana/Marengo":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Indiana/Petersburg":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Indiana/Tell_City":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Indiana/Valparaiso":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Indiana/Vevay":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Indiana/Vincennes":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Indiana/Winamac":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Indianapolis":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Inuvik":{ offset: "−07:00", dstOffset: "−06:00"},
"America/Iqaluit":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Jamaica":{ offset: "−05:00", dstOffset: "−05:00"},
"America/Jujuy":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Juneau":{ offset: "−09:00", dstOffset: "−08:00"},
"America/Kentucky/Louisville":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Kentucky/Monticello":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Knox_IN":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Kralendijk":{ offset: "−04:00", dstOffset: "−04:00"},
"America/La_Paz":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Lima":{ offset: "−05:00", dstOffset: "−05:00"},
"America/Los_Angeles":{ offset: "−08:00", dstOffset: "−07:00"},
"America/Louisville":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Lower_Princes":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Maceio":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Managua":{ offset: "−06:00", dstOffset: "−06:00"},
"America/Manaus":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Marigot":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Martinique":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Matamoros":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Mazatlan":{ offset: "−07:00", dstOffset: "−06:00"},
"America/Mendoza":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Menominee":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Merida":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Metlakatla":{ offset: "−08:00", dstOffset: "−08:00"},
"America/Mexico_City":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Miquelon":{ offset: "−03:00", dstOffset: "−02:00"},
"America/Moncton":{ offset: "−04:00", dstOffset: "−03:00"},
"America/Monterrey":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Montevideo":{ offset: "−03:00", dstOffset: "−02:00"},
"America/Montreal":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Montserrat":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Nassau":{ offset: "−05:00", dstOffset: "−04:00"},
"America/New_York":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Nipigon":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Nome":{ offset: "−09:00", dstOffset: "−08:00"},
"America/Noronha":{ offset: "−02:00", dstOffset: "−02:00"},
"America/North_Dakota/Beulah":{ offset: "−06:00", dstOffset: "−05:00"},
"America/North_Dakota/Center":{ offset: "−06:00", dstOffset: "−05:00"},
"America/North_Dakota/New_Salem":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Ojinaga":{ offset: "−07:00", dstOffset: "−06:00"},
"America/Panama":{ offset: "−05:00", dstOffset: "−05:00"},
"America/Pangnirtung":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Paramaribo":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Phoenix":{ offset: "−07:00", dstOffset: "−07:00"},
"America/Port_of_Spain":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Port-au-Prince":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Porto_Acre":{ offset: "−05:00", dstOffset: "−05:00"},
"America/Porto_Velho":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Puerto_Rico":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Rainy_River":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Rankin_Inlet":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Recife":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Regina":{ offset: "−06:00", dstOffset: "−06:00"},
"America/Resolute":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Rio_Branco":{ offset: "−05:00", dstOffset: ""},
"America/Rosario":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Santa_Isabel":{ offset: "−08:00", dstOffset: "−07:00"},
"America/Santarem":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Santiago":{ offset: "−03:00", dstOffset: "−03:00"},
"America/Santo_Domingo":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Sao_Paulo":{ offset: "−03:00", dstOffset: "−02:00"},
"America/Scoresbysund":{ offset: "−01:00", dstOffset: "+00:00"},
"America/Shiprock":{ offset: "−07:00", dstOffset: "−06:00"},
"America/Sitka":{ offset: "−09:00", dstOffset: "−08:00"},
"America/St_Barthelemy":{ offset: "−04:00", dstOffset: "−04:00"},
"America/St_Johns":{ offset: "−03:30", dstOffset: "−02:30"},
"America/St_Kitts":{ offset: "−04:00", dstOffset: "−04:00"},
"America/St_Lucia":{ offset: "−04:00", dstOffset: "−04:00"},
"America/St_Thomas":{ offset: "−04:00", dstOffset: "−04:00"},
"America/St_Vincent":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Swift_Current":{ offset: "−06:00", dstOffset: "−06:00"},
"America/Tegucigalpa":{ offset: "−06:00", dstOffset: "−06:00"},
"America/Thule":{ offset: "−04:00", dstOffset: "−03:00"},
"America/Thunder_Bay":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Tijuana":{ offset: "−08:00", dstOffset: "−07:00"},
"America/Toronto":{ offset: "−05:00", dstOffset: "−04:00"},
"America/Tortola":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Vancouver":{ offset: "−08:00", dstOffset: "−07:00"},
"America/Virgin":{ offset: "−04:00", dstOffset: "−04:00"},
"America/Whitehorse":{ offset: "−08:00", dstOffset: "−07:00"},
"America/Winnipeg":{ offset: "−06:00", dstOffset: "−05:00"},
"America/Yakutat":{ offset: "−09:00", dstOffset: "−08:00"},
"America/Yellowknife":{ offset: "−07:00", dstOffset: "−06:00"},
"Antarctica/Casey":{ offset: "+11:00", dstOffset: "+08:00"},
"Antarctica/Davis":{ offset: "+05:00", dstOffset: "+07:00"},
"Antarctica/DumontDUrville":{ offset: "+10:00", dstOffset: "+10:00"},
"Antarctica/Macquarie":{ offset: "+11:00", dstOffset: "+11:00"},
"Antarctica/Mawson":{ offset: "+05:00", dstOffset: "+05:00"},
"Antarctica/McMurdo":{ offset: "+12:00", dstOffset: "+13:00"},
"Antarctica/Palmer":{ offset: "−04:00", dstOffset: "−03:00"},
"Antarctica/Rothera":{ offset: "−03:00", dstOffset: "−03:00"},
"Antarctica/South_Pole":{ offset: "+12:00", dstOffset: "+13:00"},
"Antarctica/Syowa":{ offset: "+03:00", dstOffset: "+03:00"},
"Antarctica/Troll":{ offset: "+00:00", dstOffset: "+02:00"},
"Antarctica/Vostok":{ offset: "+06:00", dstOffset: "+06:00"},
"Arctic/Longyearbyen":{ offset: "+01:00", dstOffset: "+02:00"},
"Asia/Aden":{ offset: "+03:00", dstOffset: "+03:00"},
"Asia/Almaty":{ offset: "+06:00", dstOffset: "+06:00"},
"Asia/Amman":{ offset: "+02:00", dstOffset: "+03:00"},
"Asia/Anadyr":{ offset: "+12:00", dstOffset: "+12:00"},
"Asia/Aqtau":{ offset: "+05:00", dstOffset: "+05:00"},
"Asia/Aqtobe":{ offset: "+05:00", dstOffset: "+05:00"},
"Asia/Ashgabat":{ offset: "+05:00", dstOffset: "+05:00"},
"Asia/Ashkhabad":{ offset: "+05:00", dstOffset: "+05:00"},
"Asia/Baghdad":{ offset: "+03:00", dstOffset: "+03:00"},
"Asia/Bahrain":{ offset: "+03:00", dstOffset: "+03:00"},
"Asia/Baku":{ offset: "+04:00", dstOffset: "+05:00"},
"Asia/Bangkok":{ offset: "+07:00", dstOffset: "+07:00"},
"Asia/Beirut":{ offset: "+02:00", dstOffset: "+03:00"},
"Asia/Bishkek":{ offset: "+06:00", dstOffset: "+06:00"},
"Asia/Brunei":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Calcutta":{ offset: "+05:30", dstOffset: "+05:30"},
"Asia/Choibalsan":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Chongqing":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Chungking":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Colombo":{ offset: "+05:30", dstOffset: "+05:30"},
"Asia/Dacca":{ offset: "+06:00", dstOffset: "+06:00"},
"Asia/Damascus":{ offset: "+02:00", dstOffset: "+03:00"},
"Asia/Dhaka":{ offset: "+06:00", dstOffset: "+06:00"},
"Asia/Dili":{ offset: "+09:00", dstOffset: "+09:00"},
"Asia/Dubai":{ offset: "+04:00", dstOffset: "+04:00"},
"Asia/Dushanbe":{ offset: "+05:00", dstOffset: "+05:00"},
"Asia/Gaza":{ offset: "+02:00", dstOffset: "+03:00"},
"Asia/Harbin":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Hebron":{ offset: "+02:00", dstOffset: "+03:00"},
"Asia/Ho_Chi_Minh":{ offset: "+07:00", dstOffset: "+07:00"},
"Asia/Hong_Kong":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Hovd":{ offset: "+07:00", dstOffset: "+08:00"},
"Asia/Irkutsk":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Istanbul":{ offset: "+02:00", dstOffset: "+03:00"},
"Asia/Jakarta":{ offset: "+07:00", dstOffset: "+07:00"},
"Asia/Jayapura":{ offset: "+09:00", dstOffset: "+09:00"},
"Asia/Jerusalem":{ offset: "+02:00", dstOffset: "+03:00"},
"Asia/Kabul":{ offset: "+04:30", dstOffset: "+04:30"},
"Asia/Kamchatka":{ offset: "+12:00", dstOffset: "+12:00"},
"Asia/Karachi":{ offset: "+05:00", dstOffset: "+05:00"},
"Asia/Kashgar":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Kathmandu":{ offset: "+05:45", offset: "+05:45"},
"Asia/Katmandu":{ offset: "+05:45", offset: "+05:45"},
"Asia/Khandyga":{ offset: "+09:00", dstOffset: "+09:00"},
"Asia/Kolkata":{ offset: "+05:30", dstOffset: "+05:30"},
"Asia/Krasnoyarsk":{ offset: "+07:00", dstOffset: "+07:00"},
"Asia/Kuala_Lumpur":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Kuching":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Kuwait":{ offset: "+03:00", dstOffset: "+03:00"},
"Asia/Macao":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Macau":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Magadan":{ offset: "+10:00", dstOffset: "+10:00"},
"Asia/Makassar":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Manila":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Muscat":{ offset: "+04:00", dstOffset: "+04:00"},
"Asia/Nicosia":{ offset: "+02:00", dstOffset: "+03:00"},
"Asia/Novokuznetsk":{ offset: "+07:00", dstOffset: "+07:00"},
"Asia/Novosibirsk":{ offset: "+06:00", dstOffset: "+06:00"},
"Asia/Omsk":{ offset: "+06:00", dstOffset: "+06:00"},
"Asia/Oral":{ offset: "+05:00", dstOffset: "+05:00"},
"Asia/Phnom_Penh":{ offset: "+07:00", dstOffset: "+07:00"},
"Asia/Pontianak":{ offset: "+07:00", dstOffset: "+07:00"},
"Asia/Pyongyang":{ offset: "+09:00", dstOffset: "+09:00"},
"Asia/Qatar":{ offset: "+03:00", dstOffset: "+03:00"},
"Asia/Qyzylorda":{ offset: "+06:00", dstOffset: "+06:00"},
"Asia/Rangoon":{ offset: "+06:30", dstOffset: "+06:30"},
"Asia/Riyadh":{ offset: "+03:00", dstOffset: "+03:00"},
"Asia/Saigon":{ offset: "+07:00", dstOffset: "+07:00"},
"Asia/Sakhalin":{ offset: "+11:00", dstOffset: "+11:00"},
"Asia/Samarkand":{ offset: "+05:00", dstOffset: "+05:00"},
"Asia/Seoul":{ offset: "+09:00", dstOffset: "+09:00"},
"Asia/Shanghai":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Singapore":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Taipei":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Tashkent":{ offset: "+05:00", dstOffset: "+05:00"},
"Asia/Tbilisi":{ offset: "+04:00", dstOffset: "+04:00"},
"Asia/Tehran":{ offset: "+03:30", dstOffset: "+04:30"},
"Asia/Tel_Aviv":{ offset: "+02:00", dstOffset: "+03:00"},
"Asia/Thimbu":{ offset: "+06:00", dstOffset: "+06:00"},
"Asia/Thimphu":{ offset: "+06:00", dstOffset: "+06:00"},
"Asia/Tokyo":{ offset: "+09:00", dstOffset: "+09:00"},
"Asia/Ujung_Pandang":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Ulaanbaatar":{ offset: "+08:00", dstOffset: "+09:00"},
"Asia/Ulan_Bator":{ offset: "+08:00", dstOffset: "+09:00"},
"Asia/Urumqi":{ offset: "+08:00", dstOffset: "+08:00"},
"Asia/Ust-Nera":{ offset: "+10:00", dstOffset: "+10:00"},
"Asia/Vientiane":{ offset: "+07:00", dstOffset: "+07:00"},
"Asia/Vladivostok":{ offset: "+10:00", dstOffset: "+10:00"},
"Asia/Yakutsk":{ offset: "+09:00", dstOffset: "+09:00"},
"Asia/Yekaterinburg":{ offset: "+05:00", dstOffset: "+05:00"},
"Asia/Yerevan":{ offset: "+04:00", dstOffset: "+04:00"},
"Atlantic/Azores":{ offset: "−01:00", dstOffset: "+00:00"},
"Atlantic/Bermuda":{ offset: "−04:00", dstOffset: "−03:00"},
"Atlantic/Canary":{ offset: "+00:00", dstOffset: "+01:00"},
"Atlantic/Cape_Verde":{ offset: "−01:00", dstOffset: "−01:00"},
"Atlantic/Faeroe":{ offset: "+00:00", dstOffset: "+01:00"},
"Atlantic/Faroe":{ offset: "+00:00", dstOffset: "+01:00"},
"Atlantic/Jan_Mayen":{ offset: "+01:00", dstOffset: "+02:00"},
"Atlantic/Madeira":{ offset: "+00:00", dstOffset: "+01:00"},
"Atlantic/Reykjavik":{ offset: "+00:00", dstOffset: "+00:00"},
"Atlantic/South_Georgia":{ offset: "−02:00", dstOffset: "−02:00"},
"Atlantic/St_Helena":{ offset: "+00:00", dstOffset: "+00:00"},
"Atlantic/Stanley":{ offset: "−03:00", dstOffset: "−03:00"},
"Australia/ACT":{ offset: "+10:00", dstOffset: "+11:00"},
"Australia/Adelaide":{ offset: "+09:30", dstOffset: "+10:30"},
"Australia/Brisbane":{ offset: "+10:00", dstOffset: "+10:00"},
"Australia/Broken_Hill":{ offset: "+09:30", dstOffset: "+10:30"},
"Australia/Canberra":{ offset: "+10:00", dstOffset: "+11:00"},
"Australia/Currie":{ offset: "+10:00", dstOffset: "+11:00"},
"Australia/Darwin":{ offset: "+09:30", dstOffset: "+09:30"},
"Australia/Eucla":{ offset: "+08:45", offset: "+08:45"},
"Australia/Hobart":{ offset: "+10:00", dstOffset: "+11:00"},
"Australia/LHI":{ offset: "+10:30", dstOffset: "+11:00"},
"Australia/Lindeman":{ offset: "+10:00", dstOffset: "+10:00"},
"Australia/Lord_Howe":{ offset: "+10:30", dstOffset: "+11:00"},
"Australia/Melbourne":{ offset: "+10:00", dstOffset: "+11:00"},
"Australia/North":{ offset: "+09:30", dstOffset: "+09:30"},
"Australia/NSW":{ offset: "+10:00", dstOffset: "+11:00"},
"Australia/Perth":{ offset: "+08:00", dstOffset: "+08:00"},
"Australia/Queensland":{ offset: "+10:00", dstOffset: "+10:00"},
"Australia/South":{ offset: "+09:30", dstOffset: "+10:30"},
"Australia/Sydney":{ offset: "+10:00", dstOffset: "+11:00"},
"Australia/Tasmania":{ offset: "+10:00", dstOffset: "+11:00"},
"Australia/Victoria":{ offset: "+10:00", dstOffset: "+11:00"},
"Australia/West":{ offset: "+08:00", dstOffset: "+08:00"},
"Australia/Yancowinna":{ offset: "+09:30", dstOffset: "+10:30"},
"Brazil/Acre":{ offset: "−05:00", dstOffset: ""},
"Brazil/DeNoronha":{ offset: "−02:00", dstOffset: "−02:00"},
"Brazil/East":{ offset: "−03:00", dstOffset: "−02:00"},
"Brazil/West":{ offset: "−04:00", dstOffset: "−04:00"},
"Canada/Atlantic":{ offset: "−04:00", dstOffset: "−03:00"},
"Canada/Central":{ offset: "−06:00", dstOffset: "−05:00"},
"Canada/Eastern":{ offset: "−05:00", dstOffset: "−04:00"},
"Canada/East-Saskatchewan":{ offset: "−06:00", dstOffset: "−06:00"},
"Canada/Mountain":{ offset: "−07:00", dstOffset: "−06:00"},
"Canada/Newfoundland":{ offset: "−03:30", dstOffset: "−02:30"},
"Canada/Pacific":{ offset: "−08:00", dstOffset: "−07:00"},
"Canada/Saskatchewan":{ offset: "−06:00", dstOffset: "−06:00"},
"Canada/Yukon":{ offset: "−08:00", dstOffset: "−07:00"},
"Chile/Continental":{ offset: "−03:00", dstOffset: "−03:00"},
"Chile/EasterIsland":{ offset: "−05:00", dstOffset: "−05:00"},
"Cuba":{ offset: "−05:00", dstOffset: "−04:00"},
"Egypt":{ offset: "+02:00", dstOffset: "+03:00"},
"Eire":{ offset: "+00:00", dstOffset: "+01:00"},
"Etc/GMT":{ offset: "+00:00", dstOffset: "+00:00"},
"Etc/GMT+0":{ offset: "+00:00", dstOffset: "+00:00"},
"Etc/UCT":{ offset: "+00:00", dstOffset: "+00:00"},
"Etc/Universal":{ offset: "+00:00", dstOffset: "+00:00"},
"Etc/UTC":{ offset: "+00:00", dstOffset: "+00:00"},
"Etc/Zulu":{ offset: "+00:00", dstOffset: "+00:00"},
"Europe/Amsterdam":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Andorra":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Athens":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Belfast":{ offset: "+00:00", dstOffset: "+01:00"},
"Europe/Belgrade":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Berlin":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Bratislava":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Brussels":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Bucharest":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Budapest":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Busingen":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Chisinau":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Copenhagen":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Dublin":{ offset: "+00:00", dstOffset: "+01:00"},
"Europe/Gibraltar":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Guernsey":{ offset: "+00:00", dstOffset: "+01:00"},
"Europe/Helsinki":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Isle_of_Man":{ offset: "+00:00", dstOffset: "+01:00"},
"Europe/Istanbul":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Jersey":{ offset: "+00:00", dstOffset: "+01:00"},
"Europe/Kaliningrad":{ offset: "+02:00", dstOffset: "+02:00"},
"Europe/Kiev":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Lisbon":{ offset: "+00:00", dstOffset: "+01:00"},
"Europe/Ljubljana":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/London":{ offset: "+00:00", dstOffset: "+01:00"},
"Europe/Luxembourg":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Madrid":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Malta":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Mariehamn":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Minsk":{ offset: "+03:00", dstOffset: "+03:00"},
"Europe/Monaco":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Moscow":{ offset: "+03:00", dstOffset: "+03:00"},
"Europe/Nicosia":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Oslo":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Paris":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Podgorica":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Prague":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Riga":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Rome":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Samara":{ offset: "+04:00", dstOffset: "+04:00"},
"Europe/San_Marino":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Sarajevo":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Simferopol":{ offset: "+03:00", dstOffset: "+03:00"},
"Europe/Skopje":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Sofia":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Stockholm":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Tallinn":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Tirane":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Tiraspol":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Uzhgorod":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Vaduz":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Vatican":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Vienna":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Vilnius":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Volgograd":{ offset: "+03:00", dstOffset: "+03:00"},
"Europe/Warsaw":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Zagreb":{ offset: "+01:00", dstOffset: "+02:00"},
"Europe/Zaporozhye":{ offset: "+02:00", dstOffset: "+03:00"},
"Europe/Zurich":{ offset: "+01:00", dstOffset: "+02:00"},
"GB":{ offset: "+00:00", dstOffset: "+01:00"},
"GB-Eire":{ offset: "+00:00", dstOffset: "+01:00"},
"GMT":{ offset: "+00:00", dstOffset: "+00:00"},
"GMT+0":{ offset: "+00:00", dstOffset: "+00:00"},
"GMT0":{offset: "+00:00", dstOffset: "+00:00"},
"GMT-0":{offset: "+00:00", dstOffset: "+00:00"},
"Greenwich":{ offset: "+00:00", dstOffset: "+00:00"},
"Hongkong":{ offset: "+08:00", dstOffset: "+08:00"},
"Iceland":{ offset: "+00:00", dstOffset: "+00:00"},
"Indian/Antananarivo":{ offset: "+03:00", dstOffset: "+03:00"},
"Indian/Chagos":{ offset: "+06:00", dstOffset: "+06:00"},
"Indian/Christmas":{ offset: "+07:00", dstOffset: "+07:00"},
"Indian/Cocos":{ offset: "+06:30", dstOffset: "+06:30"},
"Indian/Comoro":{ offset: "+03:00", dstOffset: "+03:00"},
"Indian/Kerguelen":{ offset: "+05:00", dstOffset: "+05:00"},
"Indian/Mahe":{ offset: "+04:00", dstOffset: "+04:00"},
"Indian/Maldives":{ offset: "+05:00", dstOffset: "+05:00"},
"Indian/Mauritius":{ offset: "+04:00", dstOffset: "+04:00"},
"Indian/Mayotte":{ offset: "+03:00", dstOffset: "+03:00"},
"Indian/Reunion":{ offset: "+04:00", dstOffset: "+04:00"},
"Iran":{ offset: "+03:30", dstOffset: "+04:30"},
"Israel":{ offset: "+02:00", dstOffset: "+03:00"},
"Jamaica":{ offset: "−05:00", dstOffset: "−05:00"},
"Japan":{ offset: "+09:00", dstOffset: "+09:00"},
"Kwajalein":{ offset: "+12:00", dstOffset: "+12:00"},
"Libya":{ offset: "+02:00", dstOffset: "+01:00"},
"Mexico/BajaNorte":{ offset: "−08:00", dstOffset: "−07:00"},
"Mexico/BajaSur":{ offset: "−07:00", dstOffset: "−06:00"},
"Mexico/General":{ offset: "−06:00", dstOffset: "−05:00"},
"Navajo":{ offset: "−07:00", dstOffset: "−06:00"},
"NZ":{ offset: "+12:00", dstOffset: "+13:00"},
"NZ-CHAT":{ offset: "+12:45", dstOffset: "+13:45"},
"Pacific/Apia":{ offset: "+13:00", dstOffset: "+14:00"},
"Pacific/Auckland":{ offset: "+12:00", dstOffset: "+13:00"},
"Pacific/Chatham":{ offset: "+12:45", dstOffset: "+13:45"},
"Pacific/Chuuk":{ offset: "+10:00", dstOffset: "+10:00"},
"Pacific/Easter":{ offset: "−06:00", dstOffset: "−05:00"},
"Pacific/Efate":{ offset: "+11:00", dstOffset: "+11:00"},
"Pacific/Enderbury":{ offset: "+13:00", dstOffset: "+13:00"},
"Pacific/Fakaofo":{ offset: "+13:00", dstOffset: "+13:00"},
"Pacific/Fiji":{ offset: "+12:00", dstOffset: "+13:00"},
"Pacific/Funafuti":{ offset: "+12:00", dstOffset: "+12:00"},
"Pacific/Galapagos":{ offset: "−06:00", dstOffset: "−06:00"},
"Pacific/Gambier":{ offset: "−09:00", dstOffset: "−09:00"},
"Pacific/Guadalcanal":{ offset: "+11:00", dstOffset: "+11:00"},
"Pacific/Guam":{ offset: "+10:00", dstOffset: "+10:00"},
"Pacific/Honolulu":{ offset: "−10:00", dstOffset: "−10:00"},
"Pacific/Johnston":{ offset: "−10:00", dstOffset: "−10:00"},
"Pacific/Kiritimati":{ offset: "+14:00", dstOffset: "+14:00"},
"Pacific/Kosrae":{ offset: "+11:00", dstOffset: "+11:00"},
"Pacific/Kwajalein":{ offset: "+12:00", dstOffset: "+12:00"},
"Pacific/Majuro":{ offset: "+12:00", dstOffset: "+12:00"},
"Pacific/Marquesas":{ offset: "−09:30", dstOffset: "−09:30"},
"Pacific/Midway":{ offset: "−11:00", dstOffset: "−11:00"},
"Pacific/Nauru":{ offset: "+12:00", dstOffset: "+12:00"},
"Pacific/Niue":{ offset: "−11:00", dstOffset: "−11:00"},
"Pacific/Norfolk":{ offset: "+11:30", dstOffset: "+11:30"},
"Pacific/Noumea":{ offset: "+11:00", dstOffset: "+11:00"},
"Pacific/Pago_Pago":{ offset: "−11:00", dstOffset: "−11:00"},
"Pacific/Palau":{ offset: "+09:00", dstOffset: "+09:00"},
"Pacific/Pitcairn":{ offset: "−08:00", dstOffset: "−08:00"},
"Pacific/Pohnpei":{ offset: "+11:00", dstOffset: "+11:00"},
"Pacific/Ponape":{ offset: "+11:00", dstOffset: "+11:00"},
"Pacific/Port_Moresby":{ offset: "+10:00", dstOffset: "+10:00"},
"Pacific/Rarotonga":{ offset: "−10:00", dstOffset: "−10:00"},
"Pacific/Saipan":{ offset: "+10:00", dstOffset: "+10:00"},
"Pacific/Samoa":{ offset: "−11:00", dstOffset: "−11:00"},
"Pacific/Tahiti":{ offset: "−10:00", dstOffset: "−10:00"},
"Pacific/Tarawa":{ offset: "+12:00", dstOffset: "+12:00"},
"Pacific/Tongatapu":{ offset: "+13:00", dstOffset: "+13:00"},
"Pacific/Truk":{ offset: "+10:00", dstOffset: "+10:00"},
"Pacific/Wake":{ offset: "+12:00", dstOffset: "+12:00"},
"Pacific/Wallis":{ offset: "+12:00", dstOffset: "+12:00"},
"Pacific/Yap":{ offset: "+10:00", dstOffset: "+10:00"},
"Poland":{ offset: "+01:00", dstOffset: "+02:00"},
"Portugal":{ offset: "+00:00", dstOffset: "+01:00"},
"PRC":{ offset: "+08:00", dstOffset: "+08:00"},
"ROC":{ offset: "+08:00", dstOffset: "+08:00"},
"ROK":{ offset: "+09:00", dstOffset: "+09:00"},
"Singapore":{ offset: "+08:00", dstOffset: "+08:00"},
"Turkey":{ offset: "+02:00", dstOffset: "+03:00"},
"UCT":{ offset: "+00:00", dstOffset: "+00:00"},
"Universal":{ offset: "+00:00", dstOffset: "+00:00"},
"US/Alaska":{ offset: "−09:00", dstOffset: "−08:00"},
"US/Aleutian":{ offset: "−10:00", dstOffset: "−09:00"},
"US/Arizona":{ offset: "−07:00", dstOffset: "−07:00"},
"US/Central":{ offset: "−06:00", dstOffset: "−05:00"},
"US/Eastern":{ offset: "−05:00", dstOffset: "−04:00"},
"US/East-Indiana":{ offset: "−05:00", dstOffset: "−04:00"},
"US/Hawaii":{ offset: "−10:00", dstOffset: "−10:00"},
"US/Indiana-Starke":{ offset: "−06:00", dstOffset: "−05:00"},
"US/Michigan":{ offset: "−05:00", dstOffset: "−04:00"},
"US/Mountain":{ offset: "−07:00", dstOffset: "−06:00"},
"US/Pacific":{ offset: "−08:00", dstOffset: "−07:00"},
"US/Samoa":{ offset: "−11:00", dstOffset: "−11:00"},
"UTC":{ offset: "+00:00", dstOffset: "+00:00"},
"W-SU":{ offset: "+03:00", dstOffset: "+03:00"},
"Zulu":{ offset: "+00:00", dstOffset: "+00:00"}
}
arguments.sharedStruct=ts;
return arguments.sharedStruct;
</cfscript>

</cffunction>


<!--- application.zcore.app.getAppCFC("event").getIcalCFC(); --->
<cffunction name="getIcalCFC" localmode="modern">
	<cfscript>
	return duplicate(application.zcore.app.getAppData("event").sharedStruct.icalCom);
	</cfscript>
</cffunction>
	

<cffunction name="isCurrentPageInEvent" localmode="modern" returntype="boolean" access="remote">
	<cfscript>
	if(structkeyexists(request.zos, 'currentURLISAnEventPage')){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<cffunction name="getEventCategories" localmode="modern" access="public">
	<cfargument name="categoryIdList" type="string" required="no" default="0">
	<cfscript>
		categoryIdList = arguments.categoryIdList;

		ts = application.zcore.app.getInstance( this.app_id );

		db = request.zos.queryObject;

		// TODO - Category sorting - currently sorting by name, needs to sort by event_category_sort when implemented.
		if ( categoryIdList EQ 0 ) {
			db.sql = "SELECT *
				FROM #db.table( 'event_category', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND event_category_deleted = #db.param( 0 )#
				ORDER BY event_category_name ASC ";
		} else {
			categoryIdArray = listToArray( categoryIdList, ',' );
			for(i=1;i<=arrayLen(categoryIdArray);i++){
				categoryIdArray[i]="'"&application.zcore.functions.zEscape(categoryIdArray[i])&"'";
			}

			db.sql = "SELECT *
				FROM #db.table( 'event_category', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND event_category_id IN ( #db.trustedSQL( arrayToList( categoryIdArray, ',' ) )# )
					AND event_category_deleted = #db.param( 0 )#
				ORDER BY event_category_name ASC ";
		}

		qCategories = db.execute( 'qCategories' );

		categories = [];

		for ( category in qCategories ) {
			category.__url=getCategoryURL(category);
			arrayAppend( categories, category );
		}

		return categories;
	</cfscript>
</cffunction>



<cffunction name="getEventCalendars" localmode="modern" access="public">
	<cfargument name="calendarIdList" type="string" required="no" default="0">
	<cfscript>
		calendarIdList = arguments.calendarIdList;

		ts = application.zcore.app.getInstance( this.app_id );

		db = request.zos.queryObject;

		// TODO - calendar sorting - currently sorting by name, needs to sort by event_calendar_sort when implemented.
		if ( calendarIdList EQ 0 ) {
			db.sql = "SELECT *
				FROM #db.table( 'event_calendar', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND event_calendar_deleted = #db.param( 0 )#
				ORDER BY event_calendar_name ASC ";
		} else {
			calendarIdArray = listToArray( calendarIdList, ',' );
			for(i=1;i<=arrayLen(categoryIdArray);i++){
				calendarIdArray[i]="'"&application.zcore.functions.zEscape(calendarIdArray[i])&"'";
			}

			db.sql = "SELECT *
				FROM #db.table( 'event_calendar', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zos.globals.id )#
					AND event_calendar_id IN ( #db.trustedSQL( arrayToList( calendarIdArray, ',' ) )# )
					AND event_calendar_deleted = #db.param( 0 )#
				ORDER BY event_calendar_name ASC ";
		}

		qCalendars = db.execute( 'qCalendars' );

		calendars = [];

		for ( calendar in qCalendars ) {
			calendar.__url=getcalendarURL(calendar);
			arrayAppend( calendars, calendar );
		}

		return calendars;
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>