<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var rateCom=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Reservation Types");
	</cfscript>
	<div style="padding-bottom:10px; width:100%; float:left;"><h2 style="display:inline;">Manage Reservation Types |</h2>
	 <a href="/z/reservation/admin/reservation-type/add">Add Reservation Type</a> | View: <cfif form.method EQ "calendarView">
		Calendar | <a href="/z/reservation/admin/reservation-type/index">List</a>
	<cfelse>
		<a href="/z/reservation/admin/reservation-type/calendarView">Calendar</a> | List
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
	db=request.zos.queryObject;
	db.sql="select * from 
	#request.zos.queryObject.table("reservation_type", request.zos.zcoreDatasource)# reservation_type   
	WHERE reservation_type.site_id = #db.param(request.zOS.globals.id)# and 
	reservation_type.reservation_type_deleted = #db.param(0)# and 
	reservation_type_end_datetime >= #db.param(form.start)# and
	reservation_type_start_datetime <= #db.param(form.end)#  ";
	qCalendar=db.execute("qCalendar");
	arrJ=[];
	for(row in qCalendar){
		ts={
			title:row.reservation_type_name,
			start:dateformat(row.reservation_type_start_datetime,"yyyy-mm-dd")&"T"&timeformat(row.reservation_type_start_datetime, "HH:mm:ss"),
			link:"/z/reservation/admin/reservation-type/edit?reservation_type_id=#row.reservation_type_id#"
		}
		if(row.reservation_type_start_datetime NEQ row.reservation_type_end_datetime){
			ts.end=dateformat(row.reservation_type_end_datetime,"yyyy-mm-dd")&"T"&timeformat(row.reservation_type_end_datetime, "HH:mm:ss");
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
	<h2>Reservation Type Calendar View</h2>


	<cfscript>

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
			events: '/z/reservation/admin/reservation-type/getCalendarJsonForDateRange'
		});
		if(navigator.userAgent.indexOf("MSIE 7.0") != -1){
			$(".fc-icon-left-single-arrow").html("&lt;");
			$(".fc-icon-right-single-arrow").html("&gt;");
		}
	});
	</script> 
	<div id='calendar'></div>
</cffunction>

	
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	variables.init();
	//application.zcore.functions.zSetPageHelpId("7.4");   
	</cfscript> 
	
	<h2>Reservation Type List View</h2>
	<cfscript>	
	defaultStartDate=parsedatetime(dateformat(now(), "yyyy-mm-dd"));
	defaultEndDate=dateadd("m", 1, now());
	form.clearSearch=application.zcore.functions.zso(form, 'clearSearch', false, 0);
	if(form.clearSearch EQ 1){
		defaultStartDate="";
		defaultEndDate="";
		form.startDate="";
		form.endDate="";
		form.keyword="";
	}
	form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
	form.startDate=application.zcore.functions.zso(form, 'startDate', false, defaultStartDate);
	form.endDate=application.zcore.functions.zso(form, 'endDate', false, defaultEndDate);
	if(not isdate(form.startDate)){
		form.startDate=defaultStartDate;
	}
	if(not isdate(form.endDate)){
		form.endDate=defaultEndDate;
	}
	if(form.startDate NEQ ""){
		form.startDate=application.zcore.functions.zGetDateTimeSelect("startDate", "yyyy-mm-dd", "HH:mm:ss");
	}
	if(form.endDate NEQ ""){
		form.endDate=application.zcore.functions.zGetDateTimeSelect("endDate", "yyyy-mm-dd", "HH:mm:ss");
	}
	form.keyword=application.zcore.functions.zso(form, 'keyword');
	db.sql=" SELECT count(reservation_type_id) count FROM 
	#request.zos.queryObject.table("reservation_type", request.zos.zcoreDatasource)# reservation_type   
	WHERE reservation_type.site_id = #db.param(request.zOS.globals.id)# and 
	reservation_type.reservation_type_deleted = #db.param(0)#  ";
	qCountAll=db.execute("qCountAll");
	db.sql=" SELECT count(reservation_type_id) count FROM 
	#request.zos.queryObject.table("reservation_type", request.zos.zcoreDatasource)# reservation_type   
	WHERE reservation_type.site_id = #db.param(request.zOS.globals.id)# and 
	reservation_type.reservation_type_deleted = #db.param(0)#  ";
	if(form.clearSearch EQ 0){
		db.sql&=" and reservation_type_end_datetime >= #db.param(form.startDate)# and
		reservation_type_start_datetime <= #db.param(form.endDate)# ";
	}
	if(form.keyword NEQ ""){
		db.sql&=" and reservation_type_name like #db.param('%#form.keyword#')# ";
	}
	qCount=db.execute("qCount");
	db.sql=" SELECT * FROM 
	#request.zos.queryObject.table("reservation_type", request.zos.zcoreDatasource)# reservation_type   
	WHERE reservation_type.site_id = #db.param(request.zOS.globals.id)# and 
	reservation_type.reservation_type_deleted = #db.param(0)# ";

	if(form.clearSearch EQ 0){
		db.sql&=" and reservation_type_end_datetime >= #db.param(form.startDate)# and
		reservation_type_start_datetime <= #db.param(form.endDate)# ";
	}
	if(form.keyword NEQ ""){
		db.sql&=" and reservation_type_name like #db.param('%#form.keyword#%')# ";
	}
	db.sql&=" order by reservation_type.reservation_type_start_datetime ASC
	LIMIT #db.param((form.zIndex-1)*30)#, #db.param(30)#";
	qProp=db.execute("qProp");
	echo('<p>Showing #qCount.count# of #qCountAll.count# reservation types. To show all records, click <a href="/z/reservation/admin/reservation-type/index?clearSearch=1">Show All</a></p>');
	</cfscript>
	<form action="/z/reservation/admin/reservation-type/index" method="get">
		<table class="table-list" style="border-spacing:0px; width:100%;">
			<tr>
				<td>Name: 
				<cfscript>
				ts = StructNew();
				ts.name = "keyword";
				ts.style="width:150px;";
				application.zcore.functions.zInput_Text(ts);
				</cfscript></td>
				<td>Start Date: #application.zcore.functions.zDateTimeSelect("startDate", form.startDate, 15)#</td>
				<td>End Date: #application.zcore.functions.zDateTimeSelect("endDate", form.endDate, 15)#</td>
				<td><input type="submit" name="search1" value="Search" /> 
				<input type="button" name="clearSearch" value="Clear" onclick="window.location.href='/z/reservation/admin/reservation-type/index?clearSearch=1';" /></td></td>
			</tr>
		</table>
	</form>
	<cfscript>
	
	if(qCount.count GT 30){
		// required
		searchStruct = StructNew();
		searchStruct.count = qCount.count;
		searchStruct.index = form.zIndex;
		// optional
		searchStruct.url = "/z/reservation/admin/reservation-type/index";
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
			<th>Period</th> 
			<th>Date Range</th> 
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
				<td>#row.reservation_type_name#</td>
				<td>#row.reservation_type_period#</td>
				<td>');
					echo(application.zcore.app.getAppCFC("reservation").getReservationTypeDateRange(row));
					
			echo('</td>
				<td>'&application.zcore.app.getAppCFC("reservation").getTypeStatusName(row.reservation_type_status)&'</td>
				<td>
				<a href="/z/reservation/admin/reservation-type/edit?reservation_type_id=#row.reservation_type_id#&amp;return=1">Edit</a> | 
				<a href="/z/reservation/admin/reservation-type/delete?reservation_type_id=#row.reservation_type_id#&amp;return=1">Delete</a></td>
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
    application.zcore.adminSecurityFilter.requireFeatureAccess("Reservation Types");
	form.reservation_type_id=application.zcore.functions.zso(form, 'reservation_type_id');
	db.sql=" SELECT * FROM #request.zos.queryObject.table("reservation_type", request.zos.zcoreDatasource)# reservation_type 
	WHERE reservation_type_id = #db.param(form.reservation_type_id)# and 
	site_id = #db.param(request.zOS.globals.id)# ";
	qCheck=db.execute("qCheck");
    if(qCheck.recordcount EQ 0){
        application.zcore.status.setStatus(request.zsid, "reservation_type is missing");
        application.zcore.functions.zRedirect("/z/reservation/admin/reservation-type/index?zsid="&request.zsid);
    }
    </cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
        /*db.sql="DELETE FROM #request.zos.queryObject.table("reservation_type_availability", request.zos.zcoreDatasource)#  
		WHERE  reservation_type_id=#db.param(form.reservation_type_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		result = db.execute("result");  */
        db.sql="DELETE FROM #request.zos.queryObject.table("reservation_type", request.zos.zcoreDatasource)#  
		WHERE  reservation_type_id=#db.param(form.reservation_type_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		result = db.execute("result");  
		application.zcore.status.setStatus(request.zsid, "reservation_type deleted");
		application.zcore.functions.zRedirect("/z/reservation/admin/reservation-type/index?reservation_type_id="&form.reservation_type_id&"&zsid="&request.zsid); 
        </cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this Reservation Type?<br />
			<br />
			<cfscript>
			for(row in qCheck){
				echo('Name: #row.reservation_type_name#<br />
				Period: #row.reservation_type_period#<br />
				Date Range: '&application.zcore.app.getAppCFC("reservation").getReservationTypeDateRange(row));
			}
			</cfscript><br />
			<br />
			<a href="/z/reservation/admin/reservation-type/delete?confirm=1&amp;reservation_type_id=#form.reservation_type_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/reservation/admin/reservation-type/index">No</a> </h2>
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
    application.zcore.adminSecurityFilter.requireFeatureAccess("Reservation Types"); 
	if(form.method EQ "update"){
		db.sql=" SELECT * FROM #request.zos.queryObject.table("reservation_type", request.zos.zcoreDatasource)# reservation_type 
		WHERE reservation_type_id = #db.param(form.reservation_type_id)# and 
		site_id = #db.param(request.zOS.globals.id)#  and 
		reservation_type_deleted = #db.param(0)# ";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Reservation Type is missing");
			application.zcore.functions.zRedirect("/z/reservation/admin/reservation-type/index?zsid="&request.zsid);
		}  
	}
	form.reservation_type_start_datetime=application.zcore.functions.zGetDateTimeSelect("reservation_type_start_datetime", "yyyy-mm-dd", "HH:mm:ss");
	form.reservation_type_end_datetime=application.zcore.functions.zGetDateTimeSelect("reservation_type_end_datetime", "yyyy-mm-dd", "HH:mm:ss");
	if(trim(form.reservation_type_end_datetime) EQ ""){
		form.reservation_type_end_datetime=form.reservation_type_start_datetime;
	}
	myForm.reservation_type_period.required=true;
	myForm.reservation_type_name.required=true;
	myForm.reservation_type_start_datetime.required=true;
	myForm.reservation_type_end_datetime.required=true;
	errors=application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	 
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/reservation/admin/reservation-type/add?zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/reservation/admin/reservation-type/edit?reservation_type_id=#form.reservation_type_id#&zsid=#request.zsid#");
		}
	} 
	form.reservation_type_updated_datetime=request.zos.mysqlnow;
	form.site_id=request.zos.globals.id;
	ts=StructNew();
	ts.table="reservation_type";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insert"){
		form.reservation_type_id = application.zcore.functions.zInsert(ts);
		if(form.reservation_type_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Reservation Type couldn't be added at this time.",form,true);
			application.zcore.functions.zredirect("/z/reservation/admin/reservation-type/add?zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Reservation Type added successfully.");
			application.zcore.functions.zredirect("/z/reservation/admin/reservation-type/index?zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Reservation Type failed to update.",form,true);
			application.zcore.functions.zredirect("/z/reservation/admin/reservation-type/edit?reservation_type_id=#form.reservation_type_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Reservation Type updated successfully.");
			application.zcore.functions.zredirect("/z/reservation/admin/reservation-type/index?zsid="&request.zsid);
		}
	}
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
	form.reservation_type_id=application.zcore.functions.zso(form, 'reservation_type_id',true);
	db.sql=" SELECT * FROM #request.zos.queryObject.table("reservation_type", request.zos.zcoreDatasource)# reservation_type 
	WHERE reservation_type_id = #db.param(form.reservation_type_id)# and 
	site_id = #db.param(request.zOS.globals.id)# and 
	reservation_type_deleted = #db.param(0)# ";
	qData=db.execute("qData");
	application.zcore.functions.zQueryToStruct(qData,form,'reservation_type_id,site_id'); 
	application.zcore.functions.zStatusHandler(request.zsid, true,true);


	form.reservation_type_max_reservations=application.zcore.functions.zso(form, 'reservation_type_max_reservations', true, 1);
	form.reservation_type_max_guests=application.zcore.functions.zso(form, 'reservation_type_max_guests', true, 0);
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
		Reservation Type</h2> 
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/reservation/admin/reservation-type/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?reservation_type_id=#form.reservation_type_id#" method="post">
		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-reservation_type-admin-edit");
		cancelURL="/z/reservation/admin/reservation-type/index";
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#

		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Name","member.reservation_type.edit reservation_type_name")#</th>
				<td><input name="reservation_type_name" size="50" type="text" value="#htmleditformat(form.reservation_type_name)#" maxlength="50" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Status","member.reservation_type.edit reservation_type_status")#</th>
				<td><cfscript>
					
					selectStruct = StructNew();
					selectStruct.name = "reservation_type_status";
					selectStruct.hideSelect=true; 
					selectStruct.size=1;
					selectStruct.listLabels="Active,Inactive";
					selectStruct.listValues = "1,0";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Period","member.reservation_type.edit reservation_type_period")#</th>
				<td><cfscript>
					
					selectStruct = StructNew();
					selectStruct.name = "reservation_type_period"; 
					selectStruct.size=1;
					selectStruct.listLabels="hourly";//"Event,Hourly,Nightly,Weekly,Monthly";
					selectStruct.listValues = "hourly";//"event,hourly,nightly,weekly,monthly";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
			</tr>
			<tr>
				<th style="width:1%;white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Start Date","member.reservation_type.edit reservation_type_start_datetime")#</th>
				<td>#application.zcore.functions.zDateTimeSelect("reservation_type_start_datetime", form.reservation_type_start_datetime, 15)#</td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("End Date","member.reservation_type.edit reservation_type_end_datetime")#</th>
				<td>
					<p>Forever: <cfscript>
					form.reservation_type_forever=application.zcore.functions.zso(form, 'reservation_type_forever', true, 1);
					var ts = StructNew();
					ts.name = "reservation_type_forever";
					ts.style="border:none;background:none;";
					ts.labelList = "Yes,No";
					ts.valueList = "1,0";
					ts.hideSelect=true;
					writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
					
					</cfscript></p>
					<p>If not forever, then select an end date:<br />
					#application.zcore.functions.zDateTimeSelect("reservation_type_end_datetime", form.reservation_type_end_datetime, 15)#</p></td>
			</tr>
			<tr>
				<th style="width:1%;white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Max Reservations","member.reservation_type.edit reservation_type_max_reservations")#</th>
				<td><input name="reservation_type_max_reservations" size="10" type="text" value="#htmleditformat(form.reservation_type_max_reservations)#" maxlength="10" /> (To allow more then 1 reservation at the same time, set to this 2 or more.  To allow unlimited reservations at the same time, set to 0)</td>
			</tr>
			<tr>
				<th style="width:1%;white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Max Guests","member.reservation_type.edit reservation_type_max_guests")#</th>
				<td><input name="reservation_type_max_guests" size="10" type="text" value="#htmleditformat(form.reservation_type_max_guests)#" maxlength="10" /> (To allow more then 1 guest per reservation, set to this 2 or more.  To allow unlimited guests, set to 0)</td>
			</tr>

			<cfif application.zcore.user.checkServerAccess()>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Payment Type","member.reservation_type.edit reservation_type_new_reservation_status")#</th>
				<td>Feature not implemented yet<input name="reservation_type_payment_type_list" size="50" type="hidden" value="#htmleditformat(form.reservation_type_payment_type_list)#" maxlength="50" />

					<!--- <cfscript>
					// select * from reservation_payment_type

					form.reservation_type_new_reservation_status=application.zcore.functions.zso(form, 'reservation_type_new_reservation_status', false, application.zcore.app.getAppData("reservation").optionStruct.reservation_config_new_reservation_status);
					selectStruct = StructNew();
					selectStruct.name = "reservation_type_payment_type_list";
					
					selectStruct.multiple=true;
					selectStruct.size=1;
					selectStruct.listLabels="Not Available";
					selectStruct.listValues = "0";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript> ---></td>
			</tr>
			</cfif>
	
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("New Reservation Status","member.reservation_type.edit reservation_type_new_reservation_status")#</th>
				<td><cfscript>
					form.reservation_type_new_reservation_status=application.zcore.functions.zso(form, 'reservation_type_new_reservation_status', false, application.zcore.app.getAppData("reservation").optionStruct.reservation_config_new_reservation_status);
					selectStruct = StructNew();
					selectStruct.name = "reservation_type_new_reservation_status";
					selectStruct.hideSelect=true; 
					selectStruct.size=1;
					selectStruct.listLabels="Approved,Pending Approval";
					selectStruct.listValues = "1,0";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Minimum Notice","member.reservation_type.edit reservation_type_minimum_hours_before_reservation")#</th>
				<td><input name="reservation_type_minimum_hours_before_reservation" size="10" type="text" value="#htmleditformat(form.reservation_type_minimum_hours_before_reservation)#" maxlength="50" /> (## of hours required before accepting a new reservation)</td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Minimum Length","member.reservation_type.edit reservation_type_minimum_length")#</th>
				<td><input name="reservation_type_minimum_length" size="10" type="text" value="#htmleditformat(form.reservation_type_minimum_length)#" maxlength="50" /> (## of units where unit is the period selected)</td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Maximum Length","member.reservation_type.edit reservation_type_maximum_length")#</th>
				<td><input name="reservation_type_maximum_length" size="10" type="text" value="#htmleditformat(form.reservation_type_maximum_length)#" maxlength="50" /> (## of units where unit is the period selected)</td>
			</tr> 
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Contract Enabled","member.reservation_type.edit reservation_type_contract_enabled")#</th>
				<td>
					<cfscript>
					form.reservation_type_contract_enabled=application.zcore.functions.zso(form, 'reservation_type_contract_enabled', true, 0);
					var ts = StructNew();
					ts.name = "reservation_type_contract_enabled";
					ts.style="border:none;background:none;";
					ts.labelList = "Yes,No";
					ts.valueList = "1,0";
					ts.hideSelect=true;
					writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
					
					</cfscript></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Payment Enabled","member.reservation_type.edit reservation_type_payment_enabled")#</th>
				<td>
					<cfscript>
					form.reservation_type_payment_enabled=application.zcore.functions.zso(form, 'reservation_type_payment_enabled', true, 0);
					var ts = StructNew();
					ts.name = "reservation_type_payment_enabled";
					ts.style="border:none;background:none;";
					ts.labelList = "Yes,No";
					ts.valueList = "1,0";
					ts.hideSelect=true;
					writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
					
					</cfscript></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Payment Required","member.reservation_type.edit reservation_type_payment_required")#</th>
				<td>
					<cfscript>
					form.reservation_type_payment_required=application.zcore.functions.zso(form, 'reservation_type_payment_required', true, 0);
					var ts = StructNew();
					ts.name = "reservation_type_payment_required";
					ts.style="border:none;background:none;";
					ts.labelList = "Yes,No";
					ts.valueList = "1,0";
					ts.hideSelect=true;
					writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
					
					</cfscript></td>
			</tr>
			<cfif application.zcore.user.checkServerAccess()>
		
				<tr>
					<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Validator CFC Path","member.reservation_type.edit reservation_type_validator_cfc_path")#</th>
					<td><input name="reservation_type_validator_cfc_path" size="50" type="text" value="#htmleditformat(form.reservation_type_validator_cfc_path)#" maxlength="50" /></td>
				</tr>
				<tr>
					<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Validator CFC Method","member.reservation_type.edit reservation_type_validator_cfc_method")#</th>
					<td><input name="reservation_type_validator_cfc_method" size="50" type="text" value="#htmleditformat(form.reservation_type_validator_cfc_method)#" maxlength="50" /></td>
				</tr>
				<tr>
					<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("View CFC Path","member.reservation_type.edit reservation_type_validator_cfc_path")#</th>
					<td><input name="reservation_type_validator_cfc_path" size="50" type="text" value="#htmleditformat(form.reservation_type_validator_cfc_path)#" maxlength="50" /></td>
				</tr>
				<tr>
					<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("View CFC Method","member.reservation_type.edit reservation_type_view_cfc_method")#</th>
					<td><input name="reservation_type_view_cfc_method" size="50" type="text" value="#htmleditformat(form.reservation_type_view_cfc_method)#" maxlength="50" /></td>
				</tr>
				<tr>
					<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("List CFC Path","member.reservation_type.edit reservation_type_list_cfc_path")#</th>
					<td><input name="reservation_type_list_cfc_path" size="50" type="text" value="#htmleditformat(form.reservation_type_list_cfc_path)#" maxlength="50" /></td>
				</tr>
				<tr>
					<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("List CFC Method","member.reservation_type.edit reservation_type_list_cfc_method")#</th>
					<td><input name="reservation_type_list_cfc_method" size="50" type="text" value="#htmleditformat(form.reservation_type_list_cfc_method)#" maxlength="50" /></td>
				</tr>
			</cfif>

		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Advanced")#
		<table style="width:100%; border-spacing:0px;" class="table-list">
		</table>
		#tabCom.endFieldSet()#  
		#tabCom.endTabMenu()#
	</form>
</cffunction>
</cfoutput>
</cfcomponent>
