<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var rateCom=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Reservations");
	</cfscript>
	<div style="padding-bottom:10px; width:100%; float:left;"><h2 style="display:inline;">Manage Reservations |</h2>
	 <a href="/z/reservation/admin/reservation-admin/add">Add Reservation</a> | View: <cfif form.method EQ "calendarView">
		Calendar | <a href="/z/reservation/admin/reservation-admin/index">List</a>
	<cfelse>
		<a href="/z/reservation/admin/reservation-admin/calendarView">Calendar</a> | List
	</cfif>

	 </div>
	<cfscript> 
	application.zcore.functions.zstatushandler(request.zsid);
	</cfscript>
</cffunction>

<cffunction name="getCalendarJsonForDateRange" localmode="modern" access="remote" roles="member">
	<cfscript>
	form.start=application.zcore.functions.zso(form, 'start');
	form.end=application.zcore.functions.zso(form, 'end');
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
	form.event_id=application.zcore.functions.zso(form, 'event_id');
	form.reservation_type_id=application.zcore.functions.zso(form, 'reservation_type_id');
	form.keyword=application.zcore.functions.zso(form, 'keyword');
	form.status=application.zcore.functions.zso(form, 'status');

	db=request.zos.queryObject;
	db.sql="select * from 
	#request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation   
	WHERE reservation.site_id = #db.param(request.zOS.globals.id)# and 
	reservation.reservation_deleted = #db.param(0)# and 
	reservation_end_datetime >= #db.param(form.start)# and
	reservation_start_datetime <= #db.param(form.end)#  and 
	reservation_status IN (#db.trustedSQL("'"&replace(form.status, ',', "','", "all")&"'")#)";
	if(form.keyword NEQ ""){
		db.sql&=" and reservation_search like #db.param('%#form.keyword#%')# ";
	}
	if(form.reservation_type_id NEQ ""){
		db.sql&=" and reservation.reservation_type_id = #db.param(form.reservation_type_id)# ";
	}
	if(form.site_x_option_group_set_id NEQ ""){
		db.sql&=" and reservation.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
	}
	if(form.event_id NEQ ""){
		db.sql&=" and reservation.event_id = #db.param(form.event_id)# ";
	}

	qCalendar=db.execute("qCalendar");
	arrJ=[];
	for(row in qCalendar){
		ts={
			title:row.reservation_first_name&" "&row.reservation_last_name,
			start:dateformat(row.reservation_start_datetime,"yyyy-mm-dd")&"T"&timeformat(row.reservation_start_datetime, "HH:mm:ss"),
			link:"/z/reservation/admin/reservation-admin/edit?reservation_id=#row.reservation_id#"
		}
		if(row.reservation_start_datetime NEQ row.reservation_end_datetime){
			ts.end=dateformat(row.reservation_end_datetime,"yyyy-mm-dd")&"T"&timeformat(row.reservation_end_datetime, "HH:mm:ss");
		}
		arrayAppend(arrJ, ts);
	}
	application.zcore.functions.zReturnJson(arrJ);
	</cfscript>
</cffunction>
	
<cffunction name="calendarView" localmode="modern" access="remote" roles="member">
	<cfscript>
	init();
	</cfscript>
	<h2>Reservation Calendar View</h2>


	<cfscript>
	showReservationSearchForm();

	application.zcore.functions.zRequireJqueryUI();
	application.zcore.skin.includeCSS("/fullcalendar-2.0.2/fullcalendar.css");
	savecontent variable="meta"{
		echo('<link href="/fullcalendar-2.0.2/fullcalendar.print.css" rel="stylesheet" media="print" />
		<style>
		.fc-event-inner{ cursor:pointer; }
		</style>');
	}
	application.zcore.template.appendTag("stylesheets", meta);

	application.zcore.skin.includeCSS("/fullcalendar-2.0.2/fullcalendar.print.css");
	application.zcore.skin.includeJS("/fullcalendar-2.0.2/lib/moment.min.js", "", 2);
	application.zcore.skin.includeJS("/fullcalendar-2.0.2/fullcalendar.min.js", "", 3); 
	

	eventLink="/z/reservation/admin/reservation-admin/getCalendarJsonForDateRange?ztv=1";


	eventLink&="&site_x_option_group_set_id="&form.site_x_option_group_set_id;
	eventLink&="&event_id="&application.zcore.functions.zso(form, 'event_id');
	eventLink&="&reservation_type_id="&form.reservation_type_id;
	eventLink&="&keyword="&form.keyword;
	eventLink&="&status="&form.status;
	</cfscript>

	<script>
	zArrDeferredFunctions.push(function() {
		
		$('##calendar').fullCalendar({ 
		    eventClick: function(calEvent, jsEvent, view) {
				if(typeof calEvent.link != "undefined"){
					window.location.href=calEvent.link;

				}
		    },
			header: {
				left: 'prev,next today',
				center: 'title',
				right: 'month,basicWeek,basicDay'
			},
			defaultDate: '#dateformat(now(), "yyyy-mm-dd")#',
			editable: false,
			events: '#eventLink#'
		});
		if(navigator.userAgent.indexOf("MSIE 7.0") != -1){
			$(".fc-icon-left-single-arrow").html("&lt;");
			$(".fc-icon-right-single-arrow").html("&gt;");
		}
	});
	</script> 
	<div id='calendar' style="margin-top:20px;"></div>
</cffunction>


<cffunction name="showReservationSearchForm" localmode="modern" access="public" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 

	defaultStartDate=parsedatetime(dateformat(now(), "yyyy-mm-dd"));
	defaultEndDate=dateadd("m", 1, now());

	if(structkeyexists(form, 'startDate_date')){
		form.startDate=application.zcore.functions.zGetDateTimeSelect("startDate", "yyyy-mm-dd", "HH:mm:ss");
		form.endDate=application.zcore.functions.zGetDateTimeSelect("endDate", "yyyy-mm-dd", "HH:mm:ss");
	}else{
		form.startDate=application.zcore.functions.zso(form, 'startDate', false, defaultStartDate);
		form.endDate=application.zcore.functions.zso(form, 'endDate', false, defaultEndDate);
	}
	if(not isdate(form.startDate)){
		form.startDate=defaultStartDate;
	}
	if(not isdate(form.endDate)){
		form.endDate=defaultEndDate;
	}
	form.startDate=dateformat(form.startDate, "yyyy-mm-dd")&" "&timeformat(form.startDate, "HH:mm:ss");
	form.endDate=dateformat(form.endDate, "yyyy-mm-dd")&" "&timeformat(form.endDate, "HH:mm:ss");
	if(structkeyexists(form, 'clearSearch')){
		structdelete(request.zsession, 'reservationSearchStruct');
	}
	if(structkeyexists(request.zsession, 'reservationSearchStruct') and structkeyexists(form, 'zIndex')){
		request.zsession.reservationSearchStruct.zIndex=form.zIndex;
	}
	if(structkeyexists(form, 'search1')){
		request.zsession.reservationSearchStruct={
			startDate:form.startDate,
			endDate:form.endDate,
			site_x_option_group_set_id:form.site_x_option_group_set_id,
			event_id:application.zcore.functions.zso(form, 'event_id'),
			reservation_type_id: form.reservation_type_id,
			keyword: form.keyword,
			status: form.status,
			zIndex:1
		};
	}else{
		if(structkeyexists(request.zsession, 'reservationSearchStruct')){
			structappend(form, request.zsession.reservationSearchStruct, true);
		}
		form.status=application.zcore.functions.zso(form, 'status', false, '0,1');
		form.event_id=application.zcore.functions.zso(form, 'event_id');
		form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id');
		form.reservation_type_id=application.zcore.functions.zso(form, 'reservation_type_id');
		form.keyword=application.zcore.functions.zso(form, 'keyword');
	}
	if(application.zcore.app.siteHasApp("event")){
		db.sql="select reservation.event_id, event_name from 
		(#db.table("reservation", request.zos.zcoreDatasource)# reservation, 
		#db.table("event", request.zos.zcoreDatasource)# event)
		WHERE reservation.site_id = #db.param(request.zos.globals.id)# and 
		event.site_id = reservation.site_id and 
		event.event_deleted=#db.param(0)# and 
		reservation.event_id = event.event_id and 
		reservation_deleted=#db.param(0)# ";
		if(form.reservation_type_id NEQ ""){
			db.sql&=" and reservation.reservation_type_id = #db.param(form.reservation_type_id)# ";
		}
		db.sql&=" GROUP BY reservation.event_id
		ORDER BY event_name ASC ";
		qEvent=db.execute("qEvent"); 
	}
	db.sql="select site_x_option_group_set_title, site_x_option_group_set.site_x_option_group_set_id, site_option_group_name from 
	(#db.table("reservation", request.zos.zcoreDatasource)# reservation, 
	#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set, 
	#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group)
	WHERE reservation.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group.site_id = reservation.site_id and 
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	site_option_group.site_option_group_deleted=#db.param(0)# and 
	site_option_group.site_option_group_id = site_x_option_group_set.site_option_group_id and 
	reservation_deleted=#db.param(0)# and 
	reservation.site_id = site_x_option_group_set.site_id and 
	site_x_option_group_set_deleted=#db.param(0)# and 
	reservation.site_x_option_group_set_id = site_x_option_group_set.site_x_option_group_set_id ";
	if(form.reservation_type_id NEQ ""){
		db.sql&=" and reservation.reservation_type_id = #db.param(form.reservation_type_id)# ";
	}
	db.sql&=" GROUP BY reservation.site_x_option_group_set_id
	ORDER BY site_x_option_group_set_title ASC ";
	qSet=db.execute("qSet"); 

	db.sql="select * from #db.table("reservation_type", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	reservation_type_deleted = #db.param(0)#  and 
	reservation_type_status = #db.param(1)# 
	ORDER BY reservation_type_name";
	qType=db.execute("qType");
	request.typeStruct={};
	for(row in qType){
		request.typeStruct[row.reservation_type_id]=row;
	}


	</cfscript>
	<form action="#request.zos.originalURL#" method="get">
		<table class="table-list" style="border-spacing:0px; width:100%;">
			<tr>
				<td>Search By Keyword:<br /> 
				<cfscript>
				ts = StructNew();
				ts.name = "keyword";
				ts.style="min-width:150px; width:150px;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
				<cfif request.zos.originalURL NEQ "/z/reservation/admin/reservation-admin/calendarView">
					<td>Start Date:<br />#application.zcore.functions.zDateTimeSelect("startDate", form.startDate, 15)#</td>
					<td>End Date:<br />#application.zcore.functions.zDateTimeSelect("endDate", form.endDate, 15)#</td>
				</cfif>
				<td>Status:<br /><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "status";
					selectStruct.multiple=true;
					selectStruct.size=1;
					selectStruct.listLabels="Approved,Pending Approval,Cancelled";
					selectStruct.listValues = "1,0,2";
					application.zcore.functions.zSetupMultipleSelect("status", form.status);
					application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
				<td>Type:<br /><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "reservation_type_id";
					selectStruct.size=1;
					selectStruct.query=qType;
					selectStruct.queryLabelField="reservation_type_name";
					selectStruct.queryValueField="reservation_type_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
				<td>Custom Records:<br /><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "site_x_option_group_set_id";
					selectStruct.size=1;
					selectStruct.query=qSet;
					selectStruct.queryLabelField="##site_x_option_group_set_title## (##site_option_group_name##)";
					selectStruct.queryParseLabelVars=true;
					selectStruct.queryValueField="site_x_option_group_set_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
				<cfif application.zcore.app.siteHasApp("event")>
					<td>Events:<br /><cfscript>
						selectStruct = StructNew();
						selectStruct.name = "event_id";
						selectStruct.size=1;
						selectStruct.query=qEvent;
						selectStruct.queryLabelField="event_name";
						selectStruct.queryValueField="event_id";
						application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
				</cfif>
				<td><input type="submit" name="search1" value="Search" /> 
				<input type="button" name="clearSearch" value="Clear" onclick="window.location.href='#request.zos.originalURL#?clearSearch=1';" /></td>
			</tr>
		</table>
	</form>
</cffunction>
	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	variables.init();
	form.event_id=application.zcore.functions.zso(form, 'event_id');
	//application.zcore.functions.zSetPageHelpId("7.4");   
	</cfscript> 
	
	<h2>Reservation List View</h2>
	<cfscript>	
	showReservationSearchForm();


	form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);


	db.sql=" SELECT count(reservation_id) count FROM 
	#request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation   
	WHERE reservation.site_id = #db.param(request.zOS.globals.id)# and 
	reservation.reservation_deleted = #db.param(0)# and 
	reservation_end_datetime >= #db.param(form.startDate)# and
	reservation_start_datetime <= #db.param(form.endDate)# and 
	reservation_status IN (#db.trustedSQL("'"&replace(form.status, ',', "','", "all")&"'")#)";
	if(form.keyword NEQ ""){
		db.sql&=" and reservation_search like #db.param('%#form.keyword#')# ";
	}
	if(form.reservation_type_id NEQ ""){
		db.sql&=" and reservation.reservation_type_id = #db.param(form.reservation_type_id)# ";
	}
	if(form.site_x_option_group_set_id NEQ ""){
		db.sql&=" and reservation.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
	}
	if(form.event_id NEQ ""){
		db.sql&=" and reservation.event_id = #db.param(form.event_id)# ";
	}
	qCount=db.execute("qCount");
	db.sql=" SELECT * FROM 
	#request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation   
	WHERE reservation.site_id = #db.param(request.zOS.globals.id)# and 
	reservation.reservation_deleted = #db.param(0)# and 
	reservation_end_datetime >= #db.param(form.startDate)# and
	reservation_start_datetime <= #db.param(form.endDate)# and 
	reservation_status IN (#db.trustedSQL("'"&replace(form.status, ',', "','", "all")&"'")#) ";
	if(form.keyword NEQ ""){
		db.sql&=" and reservation_search like #db.param('%#form.keyword#%')# ";
	}
	if(form.reservation_type_id NEQ ""){
		db.sql&=" and reservation.reservation_type_id = #db.param(form.reservation_type_id)# ";
	}
	if(form.site_x_option_group_set_id NEQ ""){
		db.sql&=" and reservation.site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# ";
	}
	if(form.event_id NEQ ""){
		db.sql&=" and reservation.event_id = #db.param(form.event_id)# ";
	}
	db.sql&=" order by reservation.reservation_status ASC, reservation.reservation_start_datetime ASC
	LIMIT #db.param((form.zIndex-1)*30)#, #db.param(30)#";
	qProp=db.execute("qProp");

	if(qCount.count GT 30){
		// required
		searchStruct = StructNew();
		searchStruct.count = qCount.count;
		searchStruct.index = form.zIndex;
		// optional
		searchStruct.url = "/z/reservation/admin/reservation-admin/index";
		searchStruct.buttons = 5;
		searchStruct.perpage = 30;
		searchStruct.indexName= "zIndex";
		// stylesheet overriding
		searchStruct.tableStyle = "table-list tiny";
		searchStruct.linkStyle = "tiny";
		searchStruct.textStyle = "tiny";
		searchStruct.highlightStyle = "highlight tiny";
		
		searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	}else{
		searchNav = "";
	}
	writeoutput(searchNav);


	</cfscript>
	<table class="table-list" style="border-spacing:0px; width:100%;">
		<tr>
			<th>Name</th>
			<th>Email</th>
			<th>Phone</th>
			<th>Date Received</th>
			<th>Reservation Date</th> 
			<th>Type</th>
			<th>Status</th>
			<th>Admin</th>
		</tr>
		<cfscript>
		currentRow=0;
		for(row in qProp){
			currentRow++;
			echo('<tr ');
			if(currentRow MOD 2 EQ 0){
				echo('class="row1"');
			}else{
				echo('class="row2"');
			}
			echo('>
				<td>#row.reservation_first_name# #row.reservation_last_name#</td>
				<td><a href="mailto:#row.reservation_email#">#row.reservation_email#</a></td>
				<td>#row.reservation_phone#</td>
				<td>#dateformat(row.reservation_created_datetime, "m/d/yyyy")# #timeformat(row.reservation_created_datetime, "h:mm tt")#</td>
				<td>');
					echo(application.zcore.app.getAppCFC("reservation").getReservationDateRange(row));
					echo('<td>');
					if(structkeyexists(request.typeStruct, row.reservation_type_id)){
						echo(request.typeStruct[row.reservation_type_id].reservation_type_name);
					}else{
						echo('Type missing');
					}
					echo('</td>');
			echo('</td>
				<td>'&application.zcore.app.getAppCFC("reservation").getStatusName(row.reservation_status)&'<td>
				<a href="/z/reservation/admin/reservation-admin/edit?reservation_id=#row.reservation_id#&amp;return=1">Edit</a> | 
				<a href="/z/reservation/admin/reservation-admin/delete?reservation_id=#row.reservation_id#&amp;return=1">Delete</a></td>
				</tr>');
		}
		</cfscript>
	</table> 
	<cfscript>
	
	writeoutput(searchNav);
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var tempLink=0;
	var qCheck=0;
	var result=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Reservations");
	form.reservation_id=application.zcore.functions.zso(form, 'reservation_id');
	db.sql=" SELECT * FROM #request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation 
	WHERE reservation_id = #db.param(form.reservation_id)# and 
	site_id = #db.param(request.zOS.globals.id)# ";
	qCheck=db.execute("qCheck");
    if(qCheck.recordcount EQ 0){
        application.zcore.status.setStatus(request.zsid, "Reservation is missing");
        application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/index?zsid="&request.zsid);
    }
    </cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		application.zcore.app.getAPPCFC("reservation").sendReservationEmail(form.reservation_id, 'cancelled');

        /*db.sql="DELETE FROM #request.zos.queryObject.table("reservation_availability", request.zos.zcoreDatasource)#  
		WHERE  reservation_id=#db.param(form.reservation_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		result = db.execute("result");  */
        db.sql="DELETE FROM #request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)#  
		WHERE  reservation_id=#db.param(form.reservation_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		result = db.execute("result");  
		application.zcore.status.setStatus(request.zsid, "Reservation deleted");
		application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/index?reservation_id="&form.reservation_id&"&zsid="&request.zsid); 
        </cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this Reservation?</h2>
		<p>WARNING: Delete is not the same as cancelling the reservation because the data will be permanently removed and the user will not be emailed.  If you meant to cancel the reservation, go back and edit the reservation and then change the "Status" field to "Cancelled" and save the change.<br />
			<br />
			Reservation: 
			<cfscript>
			for(row in qCheck){
				echo(application.zcore.app.getAppCFC("reservation").getReservationDateRange(row));
			}
			</cfscript> for #qcheck.reservation_first_name# #qcheck.reservation_last_name# (#qcheck.reservation_email#)</p>
			<h2>
			<a href="/z/reservation/admin/reservation-admin/delete?confirm=1&amp;reservation_id=#form.reservation_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/reservation/admin/reservation-admin/index">No</a> </h2>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	var myForm=structnew(); 
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Reservations"); 
	if(form.method EQ "update"){
		db.sql=" SELECT * FROM #request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation 
		WHERE reservation_id = #db.param(form.reservation_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Reservation is missing");
			application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/index?zsid="&request.zsid);
		}  
	}
	form.reservation_search=form.reservation_first_name&" "&form.reservation_last_name&" "&form.reservation_email&" "&form.reservation_phone&" "&form.reservation_comments;
	form.reservation_search=application.zcore.functions.zCleanSearchText(form.reservation_search, true);
	if(form.method EQ "insert"){
		form.reservation_created_datetime=request.zos.mysqlnow;
		form.reservation_key=hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256');
	}

	form.reservation_start_datetime=application.zcore.functions.zGetDateTimeSelect("reservation_start_datetime", "yyyy-mm-dd", "HH:mm:ss");
	form.reservation_end_datetime=application.zcore.functions.zGetDateTimeSelect("reservation_end_datetime", "yyyy-mm-dd", "HH:mm:ss");
	myForm.reservation_period.required=true;
	myForm.reservation_phone.required=true;
	myForm.reservation_type_id.required=true;
	myForm.reservation_email.required=true;
	myForm.reservation_email.email=true;
	myForm.reservation_last_name.required=true;
	myForm.reservation_start_datetime.required=true;
	myForm.reservation_end_datetime.required=true;
	errors=application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	 
	jsonStruct={};
	for(i=1;i LTE form.reservation_custom_count;i++){
		fieldName=application.zcore.functions.zso(form, 'reservation_custom_field'&i);
		if(fieldName NEQ ""){
			jsonStruct[fieldName]=application.zcore.functions.zso(form, 'reservation_custom_value'&i);
		}
	}
	if(form.method EQ "insert" and reservation_status EQ 2){
		application.zcore.status.setStatus(request.zsid, "You can't create a new reservation with a status of cancelled.", form, true);
		errors=true;
	}
	form.reservation_custom_json=serializeJson(jsonStruct);
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/add?zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/reservation/admin/reservation-admin/edit?reservation_id=#form.reservation_id#&zsid=#request.zsid#");
		}
	} 
	form.reservation_updated_datetime=request.zos.mysqlnow;
	form.site_id=request.zos.globals.id;
	ts=StructNew();
	ts.table="reservation";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insert"){
		form.reservation_id = application.zcore.functions.zInsert(ts);
		if(form.reservation_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Reservation couldn't be added at this time.",form,true);
			application.zcore.functions.zredirect("/z/reservation/admin/reservation-admin/add?zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Reservation added successfully.");
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Reservation failed to update.",form,true);
			application.zcore.functions.zredirect("/z/reservation/admin/reservation-admin/edit?reservation_id=#form.reservation_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Reservation updated successfully.");
		}
	}
	if(form.method EQ "insert"){
		application.zcore.app.getAPPCFC("reservation").sendReservationEmail(form.reservation_id, 'new');
	}else if(form.reservation_status EQ "2"){
		application.zcore.app.getAPPCFC("reservation").sendReservationEmail(form.reservation_id, 'cancelled');
	}else{
		application.zcore.app.getAPPCFC("reservation").sendReservationEmail(form.reservation_id, 'updated');
	}

	application.zcore.functions.zredirect("/z/reservation/admin/reservation-admin/index?zsid="&request.zsid);
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

	
<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	var currentMethod=form.method;
	variables.init();
	//application.zcore.functions.zSetPageHelpId("7.5");
	form.reservation_id=application.zcore.functions.zso(form, 'reservation_id',true);
	db.sql=" SELECT * FROM #request.zos.queryObject.table("reservation", request.zos.zcoreDatasource)# reservation 
	WHERE reservation_id = #db.param(form.reservation_id)# and 
	site_id = #db.param(request.zOS.globals.id)# and 
	reservation_deleted=#db.param(0)# ";
	qData=db.execute("qData");
	application.zcore.functions.zQueryToStruct(qData,form,'reservation_id,site_id'); 
	application.zcore.functions.zStatusHandler(request.zsid, true,true);


	db.sql=" SELECT * FROM #request.zos.queryObject.table("reservation_type", request.zos.zcoreDatasource)# reservation_type
	WHERE site_id = #db.param(request.zOS.globals.id)# and 
	reservation_type_deleted=#db.param(0)#
	ORDER BY reservation_type_name ASC ";
	qType=db.execute("qType");

	if(application.zcore.app.siteHasApp("event")){
		db.sql="select reservation.event_id, event_name from 
		(#db.table("reservation", request.zos.zcoreDatasource)# reservation, 
		#db.table("event", request.zos.zcoreDatasource)# event)
		WHERE reservation.site_id = #db.param(request.zos.globals.id)# and 
		event.site_id = reservation.site_id and 
		event.event_deleted=#db.param(0)# and 
		reservation.event_id = event.event_id and 
		reservation_deleted=#db.param(0)# ";
		if(form.reservation_type_id NEQ ""){
			db.sql&=" and reservation.reservation_type_id = #db.param(form.reservation_type_id)# ";
		}
		db.sql&=" GROUP BY reservation.event_id
		ORDER BY event_name ASC ";
		qEvent=db.execute("qEvent"); 
	}
	db.sql="select site_x_option_group_set_title, site_x_option_group_set.site_x_option_group_set_id, site_option_group_name from 
	(#db.table("reservation", request.zos.zcoreDatasource)# reservation, 
	#db.table("site_x_option_group_set", request.zos.zcoreDatasource)# site_x_option_group_set, 
	#db.table("site_option_group", request.zos.zcoreDatasource)# site_option_group)
	WHERE reservation.site_id = #db.param(request.zos.globals.id)# and 
	site_option_group.site_id = reservation.site_id and 
	site_x_option_group_set_master_set_id = #db.param(0)# and 
	site_option_group.site_option_group_deleted=#db.param(0)# and 
	site_option_group.site_option_group_id = site_x_option_group_set.site_option_group_id and 
	reservation_deleted=#db.param(0)# and 
	reservation.site_id = site_x_option_group_set.site_id and 
	site_x_option_group_set_deleted=#db.param(0)# and 
	reservation.site_x_option_group_set_id = site_x_option_group_set.site_x_option_group_set_id ";
	if(form.reservation_type_id NEQ ""){
		db.sql&=" and reservation.reservation_type_id = #db.param(form.reservation_type_id)# ";
	}
	db.sql&=" GROUP BY reservation.site_x_option_group_set_id
	ORDER BY site_x_option_group_set_title ASC ";
	qSet=db.execute("qSet"); 
	</cfscript>
	<h2>
		<cfif currentMethod EQ "edit">
			Edit
		<cfelse>
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		</cfif>
		Reservation</h2>
		<p>Email notifications are sent to
		<cfscript>
		d=application.zcore.app.getAppData("reservation");
		arr1=listToArray(d.optionstruct.reservation_config_change_email_list, ",");
		arr2=[];
		for(i=1;i LTE arraylen(arr1);i++){
			if(arr1[i] EQ "1"){
				arrayAppend(arr2, "the developer");
			}else if(arr1[i] EQ "2"){
				arrayAppend(arr2, "the administrator");
			}else if(arr1[i] EQ "3"){
				arrayAppend(arr2, "the customer");
			}
		}
		echo(arrayToList(arr2, ", "));
		</cfscript>
		 each time you update a reservation.</p>
		 <p>Note: availability is not checked when you add / update reservations.  Make sure you don't double book.</p>
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/reservation/admin/reservation-admin/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?reservation_id=#form.reservation_id#" method="post">
		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-reservation-admin-edit");
		cancelURL="/z/reservation/admin/reservation-admin/index";
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#

		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Type","member.reservation.edit reservation_type_id")#</th>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "reservation_type_id";
					selectStruct.size=1;
					selectStruct.query=qType;
					selectStruct.queryLabelField="reservation_type_name";
					selectStruct.queryValueField="reservation_type_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Status","member.reservation.edit reservation_status")#</th>
				<td><cfscript>
					
					selectStruct = StructNew();
					selectStruct.name = "reservation_status";
					selectStruct.hideSelect=true; 
					selectStruct.size=1;
					if(form.method EQ "add"){
						selectStruct.listLabels="Approved,Pending Approval";
						selectStruct.listValues = "1,0";
					}else{
						selectStruct.listLabels="Approved,Pending Approval,Cancelled";
						selectStruct.listValues = "1,0,2";
					}
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Period","member.reservation.edit reservation_period")#</th>
				<td><cfscript>
					
					selectStruct = StructNew();
					selectStruct.name = "reservation_period"; 
					selectStruct.size=1;
					selectStruct.listLabels="hourly";//"Event,Hourly,Nightly,Weekly,Monthly";
					selectStruct.listValues = "hourly";//"event,hourly,nightly,weekly,monthly";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
			</tr>


			<cfif application.zcore.app.siteHasApp("event")>
				
				<tr>
					<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Event","member.reservation.edit event_id")#</th>
					<td><cfscript>
						selectStruct = StructNew();
						selectStruct.name = "event_id";
						selectStruct.size=1;
						selectStruct.query=qEvent;
						selectStruct.queryLabelField="event_name";
						selectStruct.queryValueField="event_id";
						application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
				</tr>
			</cfif>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Custom Record","member.reservation.edit site_x_option_group_set_id")#</th>
				<td><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "site_x_option_group_set_id";
					selectStruct.size=1;
					selectStruct.query=qSet;
					selectStruct.queryLabelField="##site_x_option_group_set_title## (##site_option_group_name##)";
					selectStruct.queryParseLabelVars=true;
					selectStruct.queryValueField="site_x_option_group_set_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
			</tr>
			<tr>
				<th style="width:1%;white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Start Date","member.reservation.edit reservation_start_datetime")#</th>
				<td>#application.zcore.functions.zDateTimeSelect("reservation_start_datetime", form.reservation_start_datetime, 15)#</td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("End Date","member.reservation.edit reservation_end_datetime")#</th>
				<td>#application.zcore.functions.zDateTimeSelect("reservation_end_datetime", form.reservation_end_datetime, 15)#</td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("First Name","member.reservation.edit reservation_first_name")#</th>
				<td><input name="reservation_first_name" size="50" type="text" value="#htmleditformat(form.reservation_first_name)#" maxlength="50" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Last Name","member.reservation.edit reservation_last_name")#</th>
				<td><input name="reservation_last_name" size="50" type="text" value="#htmleditformat(form.reservation_last_name)#" maxlength="50" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Email","member.reservation.edit reservation_email")#</th>
				<td><input name="reservation_email" size="50" type="text" value="#htmleditformat(form.reservation_email)#" maxlength="100" /></td>
			</tr> 
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Phone","member.reservation.edit reservation_phone")#</th>
				<td><input name="reservation_phone" size="50" type="text" value="#htmleditformat(form.reservation_phone)#" maxlength="100" /></td>
			</tr> 
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Company","member.reservation.edit reservation_company")#</th>
				<td><input name="reservation_company" size="50" type="text" value="#htmleditformat(form.reservation_company)#" maxlength="100" /></td>
			</tr> 
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Comments","member.reservation.edit reservation_comments")#</th>
				<td><textarea name="reservation_comments" cols="100" rows="10">#htmleditformat(form.reservation_comments)#</textarea></td>
			</tr> 
			<cfscript>
			customStruct=deserializeJson(form.reservation_custom_json);
			if(not isstruct(customStruct)){
				customStruct={};
			}
			</cfscript>
			<cfif structcount(customStruct)>
				<cfscript>
				index=1;
				for(fieldName in customStruct){
					value=customStruct[fieldName];
					echo('<tr><th style="width:1%; white-space:nowrap; vertical-align:top;">'&application.zcore.functions.zFirstLetterCaps(fieldName)&'</th><td>');
					ts = StructNew();
					ts.name = "reservation_custom_value"&index;
					form["reservation_custom_value"&index]=value;
					ts.style="width:95%;";
					application.zcore.functions.zInput_Text(ts);
					ts = StructNew();
					ts.name = "reservation_custom_field"&index;
					form["reservation_custom_field"&index]=fieldName;
					application.zcore.functions.zInput_Hidden(ts);
					echo('</td></tr>');
					index++;
				}
				</cfscript>
			<cfelse>
			</cfif>
		</table>
		<input type="hidden" name="reservation_custom_count" value="#structcount(customStruct)#" />

		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Advanced")#
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Title","member.reservation.edit reservation_destination_title")#</th>
				<td><input name="reservation_destination_title" size="50" type="text" value="#htmleditformat(form.reservation_destination_title)#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination URL","member.reservation.edit reservation_destination_url")#</th>
				<td><input name="reservation_destination_url" size="50" type="text" value="#htmleditformat(form.reservation_destination_url)#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Address","member.reservation.edit reservation_destination_address")#</th>
				<td><input name="reservation_destination_address" size="50" type="text" value="#htmleditformat(form.reservation_destination_address)#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Address 2","member.reservation.edit reservation_destination_address2")#</th>
				<td><input name="reservation_destination_address2" size="50" type="text" value="#htmleditformat(form.reservation_destination_address2)#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination City","member.reservation.edit reservation_destination_city")#</th>
				<td><input name="reservation_destination_city" size="50" type="text" value="#htmleditformat(form.reservation_destination_city)#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Address","member.reservation.edit reservation_destination_state")#</th>
				<td>#application.zcore.functions.zStateSelect("reservation_destination_state", form.reservation_destination_state)#</td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Zip","member.reservation.edit reservation_destination_zip")#</th>
				<td><input name="reservation_destination_zip" size="50" type="text" value="#htmleditformat(form.reservation_destination_zip)#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Destination Country","member.reservation.edit reservation_destination_country")#</th>
				<td>#application.zcore.functions.zCountrySelect("reservation_destination_country", form.reservation_destination_country)#</td>
			</tr>
		</table>
		#tabCom.endFieldSet()#  
		#tabCom.endTabMenu()#
	</form>
</cffunction>
</cfoutput>
</cfcomponent>
