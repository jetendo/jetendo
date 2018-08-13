<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
 	var db=request.zos.queryObject;
	var selectStruct=0;
	var qProperties=0;
	application.zcore.functions.zSetPageHelpId("7.3");
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Calendars");
	</cfscript>
	<h2 style="padding:5px; padding-left:0px; margin:0px;">Select a rental to edit its availability.</h2>
	<cfscript>
	db.sql="SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental WHERE 
	rental_active=#db.param(1)# and 
	rental_enable_calendar = #db.param(1)# and 
	rental_deleted = #db.param(0)# and 
	site_id = #db.param(request.zOS.globals.id)# ORDER BY rental_name ASC ";
	qProperties=db.execute("qProperties");
	</cfscript>
	<script type="text/javascript">
	/* <![CDATA[ */
	function getCalendar(val){
		if(val != ''){
			window.location.href = '/z/rental/admin/availability/select?rental_id='+val;
		}
	}
	/* ]]> */
	</script>
	<cfscript>
	selectStruct = StructNew();
	selectStruct.name = "rental_id";
	selectStruct.query = qProperties;
	selectStruct.onChange = 'getCalendar(this.value);';
	selectStruct.queryLabelField = "rental_name";
	selectStruct.queryValueField = "rental_id";
	application.zcore.functions.zInputSelectBox(selectStruct);
	application.zcore.functions.zstatushandler(request.zsid);
	</cfscript>
</cffunction>

<cffunction name="submit" localmode="modern" access="remote" roles="member">
	<cfscript>
 	var db=request.zos.queryObject;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Calendars", true);
	if(structkeyexists(form, 'start_date') EQ false){
		application.zcore.status.setStatus(request.zsid,"Please select a rental and start date to update availability.");
		application.zcore.functions.zRedirect("/z/rental/admin/availability/index?zsid=#request.zsid#");
	}
	form.start_date = DateFormat(form.start_date,'yyyy-mm-dd');
	form.end_date = DateAdd("yyyy",1,form.start_date);
	db.sql="DELETE from #request.zos.queryObject.table("availability", request.zos.zcoreDatasource)#  
	WHERE rental_id = #db.param(form.rental_id)# and 
	availability_date >= #db.param(dateformat(form.start_date, 'yyyy-mm-dd')&' 00:00:00')# and 
	availability_date < #db.param(dateformat(form.end_date, 'yyyy-mm-dd')&' 00:00:00')# and 
	inquiries_id = #db.param('0')# and 
	availability_deleted = #db.param(0)# and 
	site_id = #db.param(request.zOS.globals.id)# ";
	q=db.execute("q");
	if(structkeyexists(form, 'avail_date')){
		for(i=1;i LTE listLen(avail_date);i=i+1){
			db.sql="INSERT INTO #request.zos.queryObject.table("availability", request.zos.zcoreDatasource)#  
			SET site_id = #db.param(request.zOS.globals.id)#, 
			availability_date = #db.param(listGetAt(form.avail_date, i))#, 
			availability_updated_datetime=#db.param(request.zos.mysqlnow)#,
			rental_id = #db.param(form.rental_id)#";				
			db.execute("q");
		}
	}			
	if(structkeyexists(request.zsession, "rental_availability_return"&form.rental_id)){
		tempLink=request.zsession["rental_availability_return"&form.rental_id];
		structdelete(request.zsession,"rental_availability_return"&form.rental_id);
		application.zcore.functions.z301Redirect(tempLink);
	}else{
		application.zcore.functions.z301Redirect("/z/rental/admin/availability/select?rental_id=#form.rental_id#&start_date=#start_date#&zmessage=#URLEncodedFormat('Availability updated.')#");
	}
	</cfscript>
</cffunction>

<cffunction name="select" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qrental=0;
	var layout_counter=0;
	var cday=0;
	var i=0;
	var week_counter=0;
	var status=0;
	var inquiries_id=0;
	var selected=0;
	var cmonth=0;
	var current_row=0;
	var qAvailList=0;
	var availStruct=0;
	var selectStruct=0;
	var ts=0;
	var rentalFrontCom=0;
	var qProperties=0;
	var ly=0;
	var rateCom=0;
	var availability_list=0;
	var number_of_columns=0;
	var tempDate=0;
	var initDate=0;
	var qLast=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Calendars");
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "rental_availability_return"&form.rental_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	form.rental_id=application.zcore.functions.zso(form, 'rental_id',true,-1);
	db.sql="SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
	WHERE rental_id = #db.param(form.rental_id)# and 
	rental_enable_calendar = #db.param(1)# and 
	rental_deleted = #db.param(0)# and 
	site_id = #db.param(request.zOS.globals.id)#";
	qrental=db.execute("qrental");
	if(qrental.recordcount EQ 0){
		application.zcore.functions.z301Redirect('/');
	}
	</cfscript>
	<script>
	/* <![CDATA[ */
	function checkWeek(id,box){
		for(i = 1; i <= 7; i++){
			name = id + '-' + i;
			
			element = document.getElementById(name);
			
			if(element){
				if(box.checked == true){
					element.checked = true;
				} else {
					element.checked = false;
				}
			}
		}
	}
	/* ]]> */
	</script>
	<cfif structkeyexists(form,'zmessage')>
		<span style="color:##FF0000; font-weight:bold; "> #form.zmessage# </span><br />
		<br />
	</cfif>
	<h2 style="display:inline;">Availability | </h2>
	<cfscript>
	rateCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.rental.admin.controller.rates");
	rateCom.displayNavigation();
	</cfscript>
	<br />
	Please check each night that is booked and click "Update Availability" at the bottom. <br />
	<br />
	The booked dates for online reservations must be edited or cancelled by clicking on the link for the dates or editing the reservation from the reservations page.<br />
	<br />
	As a quick shortcut click on the "W" check box to check/uncheck an entire week. <br />
	<br />
	<cfscript>
	db.sql="SELECT max(availability_date) as availability_date
	FROM #request.zos.queryObject.table("availability", request.zos.zcoreDatasource)# availability 
	WHERE availability.rental_id = #db.param(form.rental_id)# and 
	availability_deleted = #db.param(0)# and 
	site_id = #db.param(request.zOS.globals.id)#";
	qLast=db.execute("qLast");
	initdate = CreateDate(year(now()),month(now()),1);
	form.first_date = CreateDate(2005,5,1);
	if(structkeyexists(form, 'first_date_year') and structkeyexists(form, 'first_date_month')){
		if(isDate(form.first_date_year&'/'&form.first_date_month&'/01') and DateCompare(form.first_date, CreateDate(form.first_date_year, form.first_date_month,1)) EQ -1){
			form.first_date = CreateDate(form.first_date_year, form.first_date_month,1);
		}
	}else if(structkeyexists(form, 'start_date')){
		form.first_date = DateFormat(form.start_date, 'yyyy-mm-dd');
	}else{
		form.first_date = initdate;
	}
	if(qLast.recordcount NEQ 0 and qLast.availability_date NEQ ''){
		tempDate = DateFormat(qLast.availability_date, 'yyyy-mm-dd');
		form.last_date = DateAdd('m',-1,DateAdd('yyyy', 1, CreateDate(year(tempDate),month(tempDate),10)));
	}else{
		form.last_date = DateAdd('m',-1,DateAdd('yyyy', 1, now()));
		form.last_date = CreateDate(year(form.last_date),month(form.last_date), daysInMOnth(form.last_date));
	}
	form.start_date = form.first_date;
	form.end_date = DateAdd('yyyy', 1, form.start_date);
	form.inc_date = form.start_date;
	cmonth = dateformat(form.end_date,"mmmm");
	cday = 'sunday';
	number_of_columns = 3;
	current_row = 1;
	availability_list = '';
	week_counter = 1;
	</cfscript>
		<form class="zFormCheckDirty" name="calSearch" id="calSearch" action="/z/rental/admin/availability/select" method="get">
	<table style="border-spacing:0px; width:100%;">
		
		<tr>
			<td><strong>Select a rental to view its availability.</strong></td>
			<td style="text-align:right;"><strong>Select a month and year to display the following 12 months</strong></td>
		</tr>
		<tr>
			<td>
				<cfscript>
				db.sql="SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental  
				WHERE rental_active = #db.param(1)# and 
				rental_enable_calendar = #db.param(1)# and 
				rental_deleted = #db.param(0)# and 
				site_id = #db.param(request.zOS.globals.id)# 
				ORDER BY rental_name ASC";
				qProperties=db.execute("qProperties");
				selectStruct = StructNew();
				selectStruct.name = "rental_id";
				selectStruct.hideSelect=true;
				selectStruct.onChange='document.calSearch.submit();';
				selectStruct.query = qProperties;
				selectStruct.queryLabelField = "##rental_id## | ##rental_name##";
				selectStruct.queryValueField = "rental_id";
				selectStruct.queryParseLabelVars=true;
				application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript></td>
			<td style="text-align:right;"><cfscript>
				ly=year(now())+2;
				</cfscript>
			#application.zcore.functions.zDateSelect("first_date", "first_date", year(initdate), ly,'document.calSearch.submit();',false,false,true)# 				</td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="2"><h2>You are editing the availability calendar for the rental below.</h2>
				<cfscript>
				ts=structnew();
				ts.rental_id_list=form.rental_id;
				rentalFrontCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.rental.controller.rental-front");
				rentalFrontCom.includeRentalById(ts);
				</cfscript></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="2" class="zrental-cal-unavailable" style="text-align:left; ">Red Dates are unavailable.<br />
				Check the boxes for reserved days. 
				Click the box in the "W" column to check or uncheck an entire week. 
				Click "Save Calendar" when you're done. </td>
		</tr>
	</table>
	</form>
	<cfscript>
	db.sql="SELECT *
	FROM #request.zos.queryObject.table("availability", request.zos.zcoreDatasource)# availability
	WHERE rental_id = #db.param(form.rental_id)# and 
	availability_date >= #db.param(dateformat(CreateDate(year(start_date), month(start_date), 1), 'yyyy-mm-dd')&' 00:00:00')# and 
	availability_deleted = #db.param(0)# and 
	site_id = #db.param(request.zOS.globals.id)# ";
	qAvailList=db.execute("qAvailList");
	availStruct = StructNew();
	loop query="qAvailList"{
		availStruct[DateFormat(qAvailList.availability_date, 'yyyy-mm-dd')] = qAvailList.inquiries_id;
	}
	</cfscript>
	<form class="zFormCheckDirty" action="/z/rental/admin/availability/submit" method="post">
		<input type="hidden" name="start_date" value="#DateFormat(form.start_date, 'yyyy-mm-dd')#" />
		<br />
		<button name="SubmitForm" type="submit" style="font-size:18px; line-height:21px; font-weight:bold; padding:10px;">Save Calendar</button>
		<br />
		<table style="border-spacing:0px;" class="cal-outer">
		<tr>
		<td style="vertical-align:top; ">
		<cfloop condition="#dateformat(form.inc_date,"yyyymm")# NEQ #dateformat(form.end_date,"yyyymm")#">
			<div class="zrental-calendardiv2">
				<table style="border-spacing:0px;" class="zrental-calendar">
					<tr>
						<td colspan="8" style="text-align:center" ><b>#dateformat(form.inc_date,"mmmm yyyy")#</b></td>
					</tr>
					<tr class="zrental-cal-days">
						<td style="text-align:center;"> Sun </td>
						<td style="text-align:center;"> Mon </td>
						<td style="text-align:center;"> Tue </td>
						<td style="text-align:center;"> Wed </td>
						<td style="text-align:center;"> Thu </td>
						<td style="text-align:center;"> Fri </td>
						<td style="text-align:center;"> Sat </td>
						<td style="text-align:center;"> W </td>
					</tr>
					<tr>
					
					<cfscript>
					current_row = current_row + 1;
					cday = 'sunday';
					layout_counter = 0;
					cmonth = dateformat(form.inc_date,"mmmm");
					while(dateformat(form.inc_date,"mmmm") EQ cmonth){
						while(dateformat(form.inc_date,"d") EQ 1){
							if(dateformat(form.inc_date,"dddd") EQ cday){
								break;
							}else{
								if(cday EQ "sunday"){
									cday="monday";
								}else if(cday EQ "monday"){
									cday="tuesday";
								}else if(cday EQ "tuesday"){
									cday="wednesday";
								}else if(cday EQ "wednesday"){
									cday="thursday";
								}else if(cday EQ "thursday"){
									cday="friday";
								}else if(cday EQ "friday"){
									cday="saturday";
								}else if(cday EQ "saturday"){
									cday="sunday";
								}
								layout_counter = layout_counter + 1;
								writeoutput('<td class="zrental-calendaremptyday">&nbsp;</td>');
							}
						}
						if(layout_counter EQ 7){
							writeoutput('</tr><tr>');
							layout_counter = 0;
						}
						layout_counter = layout_counter + 1;
						if(dateformat(form.inc_date,"dddd") EQ cday){
							try{
								status = availStruct[dateformat(form.inc_date,"yyyy-mm-dd")];
								inquiries_id = status;
								selected=true;
							}catch(Any excpt){
								status = "";
								inquiries_id="0";
								selected=false;
							}
						}
						writeoutput('<td class="');
						if(selected){
							writeoutput('zrental-cal-unavailable');
						}else{
							writeoutput('zrental-cal-available');
						}
						writeoutput('" style="text-align:center; white-space:nowrap; width:20px;">');
						if(inquiries_id NEQ '0'){
							writeoutput('<a href="/z/inquiries/admin/manage-inquiries/view?inquiries_id=#inquiries_id#" style="color:##FFFFFF;">#dateformat(form.inc_date,"d")#</a>
							<input type="hidden" name="avail_date" value="#dateformat(form.inc_date,"yyyy-mm-dd")#" />');
						}else{
							writeoutput('#dateformat(form.inc_date,"d")#<br />
							<input type="checkbox" name="avail_date" value="#dateformat(form.inc_date,"yyyy-mm-dd")#" ');
							if(selected){
								writeoutput('checked="checked"');
							}
							writeoutput(' id="#week_counter#-#layout_counter#" style="background:none; border:none;">');
						}
						writeoutput('</td>');
						if(layout_counter EQ 7){
							writeoutput('<td><input type="checkbox" onclick="checkWeek(''#week_counter#'', this)" style="background:none; border:none;"></td>');
						}
							
						if(cday EQ "sunday"){
							cday="monday";
						}else if(cday EQ "monday"){
							cday="tuesday";
						}else if(cday EQ "tuesday"){
							cday="wednesday";
						}else if(cday EQ "wednesday"){
							cday="thursday";
						}else if(cday EQ "thursday"){
							cday="friday";
						}else if(cday EQ "friday"){
							cday="saturday";
						}else if(cday EQ "saturday"){
							cday="sunday";
						}
						form.inc_date = DateAdd('d', 1, form.inc_date);
						if(layout_counter eq 7){
							week_counter = week_counter + 1;
						}
					}
					loop from="#layout_counter#" to="6" index="i"{
						writeoutput('<td class="zrental-calendaremptyday">&nbsp;</td>');
					}
					</cfscript>
					<td>&nbsp;</td>
					</tr>
					
					</table>
				</div>
		</cfloop></td>
		</tr>
		<tr>
			<td><input type="hidden" name="rental_id" value="#form.rental_id#" />
				<br />
				<br />
				<button name="SubmitForm" type="submit" style="font-size:18px; line-height:21px; font-weight:bold; padding:10px;">Save Calendar</button></td>
		</tr>
	</form>
	</table>
</cffunction>
</cfoutput>
</cfcomponent>
