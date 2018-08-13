<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
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
	application.zcore.functions.zSetPageHelpId("7.8");
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Calendars");
	var initdate = CreateDate(year(now()),month(now()),1);
	application.zcore.functions.zStatusHandler(request.zsid);
	db.sql="SELECT max(availability_date) as availability_date
	FROM #request.zos.queryObject.table("availability", request.zos.zcoreDatasource)# availability 
	WHERE  site_id = #db.param(request.zOS.globals.id)# and 
	availability_deleted = #db.param(0)#";
	qLast=db.execute("qLast");
	form.search_start_date=application.zcore.functions.zso(form, 'search_start_date',false,DateAdd("d",1,now()));
	form.search_end_date = application.zcore.functions.zso(form, 'search_end_date',false,DateAdd('d', 7, form.search_start_date));	
	form.first_date = CreateDate(2005,5,1);
	if(structkeyexists(form,'first_date_year') and structkeyexists(form,'first_date_month')){
		if(isDate(form.first_date_year&'/'&form.first_date_month&'/01') and DateCompare(form.first_date, CreateDate(form.first_date_year,form.first_date_month,1)) EQ -1){
			form.first_date = CreateDate(form.first_date_year,form.first_date_month,1);
		}
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
	form.end_date = (DateAdd('m', 1, form.start_date));
	</cfscript>
	<h2 style="display:inline;">All Calendars | </h2>
	<cfscript>
	rateCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.rental.admin.controller.rates");
	rateCom.displayNavigation();
	</cfscript>
		<form name="calSearch" id="calSearch" action="/z/rental/admin/combined-availability/index" method="get">
	<table style="border-spacing:0px; width:100%;">
			<td><h2 style="display:inline;">Viewing #dateformat(search_start_date,'mmmm yyyy')#</h2></td>
			<td><input type="hidden" name="action" value="select" />
				<cfscript>
				ly=year(now())+2;
				</cfscript>
				Select Month: #application.zcore.functions.zDateSelect("first_date", "first_date", year(initdate), ly,'document.calSearch.submit();',false,false,true)# </td>
			</tr>
			
			<tr>
				<td colspan="2">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="2" class="zrental-cal-unavailable" style="text-align:left; ">The availability for each rental in the selected month is displayed below.<br />
					Red Dates are unavailable. <br />
					Dates that are underlined represent reservations.</td>
			</tr>
	</table>
		</form>
	<br />
	<cfscript>
	db.sql="SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
	WHERE rental_active = #db.param(1)# and 
	rental_enable_calendar = #db.param(1)# and 
	rental_deleted = #db.param(0)# and 
	site_id = #db.param(request.zOS.globals.id)# ORDER BY rental_name asc ";
	qrental=db.execute("qrental");
	</cfscript>
	<cfloop query="qrental">
		<cfscript>
		form.inc_date = form.start_date;
		cmonth = dateformat(form.end_date,"mmmm");
		cday = 'sunday';
		number_of_columns = 4;
		current_row = 1;
		availability_list = '';
		db.sql="SELECT availability_date, inquiries_id
		FROM #request.zos.queryObject.table("availability", request.zos.zcoreDatasource)# availability 
		WHERE availability.rental_id = #db.param(qrental.rental_id)# and 
		availability_deleted = #db.param(0)# and 
		availability_date >= #db.param(dateformat(CreateDate(year(form.start_date), month(form.start_date), 1), 'yyyy-mm-dd')&' 00:00:00')# and 
		availability_date <= #db.param(dateformat(CreateDate(year(form.end_date), month(form.end_date), 1), 'yyyy-mm-dd')&' 00:00:00')# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		qAvailList=db.execute("qAvailList");
		availStruct = StructNew();
		loop query="qAvailList"{
			availStruct[DateFormat(qAvailList.availability_date, 'yyyy-mm-dd')] = qAvailList.inquiries_id;
		}
		</cfscript>
		<table  class="cal-outer"  style="border-spacing:0px; float:left; margin-right:10px; margin-bottom:10px;">
			<tr>
				<td style="vertical-align:top; ">
				<cfloop condition="#dateformat(form.inc_date,"yyyymm")# NEQ #dateformat(form.end_date,"yyyymm")#">
					<div class="zrental-calendardiv2">
						<table style="border-spacing:0px;" class="zrental-calendar">
							<tr>
								<td colspan="7" style="text-align:center"><b>#qrental.rental_name#</b></td>
							</tr>
							<tr class="zrental-cal-days">
								<td style="text-align:center;"> Sun </td>
								<td style="text-align:center;"> Mon </td>
								<td style="text-align:center;"> Tue </td>
								<td style="text-align:center;"> Wed </td>
								<td style="text-align:center;"> Thu </td>
								<td style="text-align:center;"> Fri </td>
								<td style="text-align:center;"> Sat </td>
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
									writeoutput('<a href="/z/inquiries/admin/manage-inquiries/view?inquiries_id=#inquiries_id#" style="color:##FFFFFF;">#dateformat(form.inc_date,"d")#</a>');
								}else{
									writeoutput('#dateformat(form.inc_date,"d")#');
								}
								writeoutput('</td>');
									
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
						</tr>
						
						</table>
					</div>
				</cfloop>
			</td>
			</tr>
		</table>
	</cfloop>
	<br style="clear:both;" />
</cffunction>
</cfoutput>
</cfcomponent>
