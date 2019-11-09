<cfcomponent><!--- <cfoutput>
<cfscript>
		var db=request.zos.queryObject;
	  if(structkeyexists(form, 'ifmdisable')){
		application.zcore.template.setTemplate("zcorerootmapping.templates.blank",true,true);  
		if(isDefined('ifmshowCalendar') EQ false){
			request.hideCalendar=true;
		}
		calendarInclude=true;
	  }    

	application.zcore.functions.zRequireJquery();
	application.zcore.functions.zRequireJqueryUI();
</cfscript>
<script language="javascript"> 
zArrDeferredFunctions.push(function(){
	$( ".datepicker" ).datepicker();
});
</script>

<cfif application.zcore.functions.zso(form, 'rental_id') NEQ "">
<cfsavecontent variable="db.sql">
SELECT * FROM rental 
WHERE rental_id = #db.param(application.zcore.functions.zso(form, 'rental_id'))# and 
rental_active=#db.param(1)# and 
rental_deleted = #db.param(0)#
</cfsavecontent><cfscript>qrental=db.execute("qrental");
calendarInclude=true;
if(qrental.recordcount EQ 0){
	z301Redirect('/');
}
if(isDefined('calendarInclude') EQ false){
if(isDefined('zRequestURL') EQ false or Compare(zRequestURL, getCalendarLink(qrental)) NEQ 0){
	z301Redirect(getCalendarLink(qrental));
}
}
request.rental_id = rental_id;
application.zcore.functions.zQueryToStruct(qrental);
</cfscript>
<cfelse>
<cfset calendarInclude=true>
<cfset ifmdisable=true>
</cfif>
<cfsavecontent variable="db.sql">
SELECT * FROM rental WHERE rental_active=#db.param(1)# and 
rental_id <> #db.param('7')# and 
rental_deleted = #db.param(0)#
ORDER BY rental_name ASC
</cfsavecontent><cfscript>qProperties=db.execute("qProperties");</cfscript>
<!--- <cfif request.cgi_SCRIPT_NAME EQ '/z/_a/rental/check-availability' and structkeyexists(form, 'ifmdisable') EQ false> --->
<!--- <cfsavecontent variable="zoverridemetakey">
<meta name="keywords" content="availability, cabin, rentals, vacation, North Georgia, romantic, getaway, honeymoon, log, homes, romance, honeymoons, weddings, toccoa, river, ocoee, Blue Ridge, Fannin County, Georgia, North Georgia, lake, lakes, creeks, creek, river, Toccoa, mountain, view, Rich Mountain, rental, cabin rental, log cabin rental, mountain view cabin rentals, romantic getaways, romantic honeymoons, mountain weddings, Toccoa River">
</cfsavecontent>
<cfsavecontent variable="zoverridemetadesc">
<meta name="description" content="Luxury Hot Tub Cabin Rentals in the North Georgia Mountains. Information on Blue Ridge Georgia and the Toccoa River area.">
</cfsavecontent> --->
<cfscript>
			application.zcore.template.setTag("title",qrental.rental_name&" Cabin Rental Availability Calendar");
			application.zcore.template.setTag("pagetitle",qrental.rental_name&" Cabin Rental Availability Calendar");
</cfscript>
<cfsavecontent variable="zpagenav">
<a href="/">Home</a> / <a href="/cabin_rentals/index.html">Cabin Rentals</a> / <a href="#qrental.rental_url#">#qrental.rental_name# Cabin Rental</a> / 
</cfsavecontent>
<cfscript>
			application.zcore.template.setTag("pagenav",zpagenav);
</cfscript>
<!--- </cfif> --->
		<cfscript>
		application.zcore.functions.zStatusHandler(request.zsid);
		</cfscript>

<script>
<!--
arrProp = new Array();
<cfloop query="qProperties">arrProp[#rental_id#] = '/#application.zcore.functions.zURLEncode(rental_name,'-')#-Cabin-Rental-Availability-Calendar-1-#rental_id#.html';</cfloop>
function getCalendar(val){
	var tempURL = arrProp[val];
	tempURL += '?first_date_year='+document.calSearch.first_date_year.options[document.calSearch.first_date_year.selectedIndex].text+'&first_date_month='+document.calSearch.first_date_month.options[document.calSearch.first_date_month.selectedIndex].value;
	window.location.href = tempURL;
}
//-->
</script>

<cfif isDefined('rental_id')>
		<cfsavecontent variable="db.sql">
			SELECT max(availability_date) as availability_date
			FROM availability 
			WHERE availability.rental_id = #db.param(rental_id)# and 
			availability_deleted = #db.param(0)#
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
			first_date = initdate;
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
		<cfset form.end_date = (DateAdd('m', 3, form.start_date))>		
		</cfif>
		<!--- <cfset form.end_date = (DateAdd('yyyy', 1, form.start_date))> --->
		
		<cfset form.inc_Date = form.start_date>
		<cfset cmonth = '#dateformat(form.end_date,"mmmm")#'>
		<cfset cday = 'sunday'>
        <cfif isDefined('calendarcolumns')>
        	<cfset number_of_columns=calendarcolumns>
        <cfelse>
			<cfset number_of_columns = 4>
        </cfif>
		<cfset current_row = 1>
		<cfset availability_list = ''>
		<!--- set peak & holidays --->
		<cfsavecontent variable="db.sql">
			SELECT left(availability_date,#db.param(10)#) as availability_date
			FROM availability 
			WHERE availability.rental_id = #db.param('31')# and 
			availability_deleted = #db.param(0)# and 
			availability_date >= #db.param(DateFormat(CreateDate(year(start_date), month(start_date), 1), 'yyyy-mm-dd')&' 00:00:00')# and 
			availability_date <= #db.param(DateFormat(CreateDate(year(end_date), month(end_date), 1), 'yyyy-mm-dd')&' 00:00:00')# 
		</cfsavecontent><cfscript>qpeak=db.execute("qpeak");</cfscript>
		<cfset peakStruct = StructNew()>
		<cfloop query="qpeak">
			<cfscript>
			peakStruct[DateFormat(availability_date, 'yyyy-mm-dd')] = true;
			</cfscript>
		</cfloop>
		<cfsavecontent variable="db.sql">
			SELECT left(availability_date,#db.param(10)#) as availability_date
			FROM availability 
			WHERE availability.rental_id = #db.param('29')# and 
			availability_deleted = #db.param(0)# and 
			availability_date >= #db.param(DateFormat(CreateDate(year(start_date), month(start_date), 1), 'yyyy-mm-dd')&' 00:00:00')# and 
			availability_date <= #db.param(DateFormat(CreateDate(year(end_date), month(end_date), 1), 'yyyy-mm-dd')&' 00:00:00')# 
		</cfsavecontent><cfscript>qholiday=db.execute("qholiday");</cfscript>
		<cfset holidayStruct = StructNew()>
		<cfloop query="qholiday">
			<cfscript>
			holidayStruct[DateFormat(availability_date, 'yyyy-mm-dd')] = true;
			</cfscript>
		</cfloop>
		<!--- get only current month and future dates --->
		<cfsavecontent variable="db.sql">
			SELECT left(availability_date,#db.param(10)#) as availability_date
			FROM availability 
			WHERE availability.rental_id = #db.param(application.zcore.functions.zso(form, 'rental_id'))# and 
			availability_deleted = #db.param(0)# and 
			availability_date >= #db.param(DateFormat(CreateDate(year(start_date), month(start_date), 1), 'yyyy-mm-dd')&' 00:00:00')#  and 
			availability_date <= #db.param(DateFormat(CreateDate(year(end_date), month(end_date), 1), 'yyyy-mm-dd')&' 00:00:00')# 
		</cfsavecontent><cfscript>qAvailList=db.execute("qAvailList");</cfscript>
		<cfset availStruct = StructNew()>
		<cfloop query="qAvailList">
			<cfscript>
			availStruct[DateFormat(availability_date, 'yyyy-mm-dd')] = true;
			</cfscript>
		</cfloop>
		

<script language="javascript">
function updateOffset22(val,type){
	setDateOffset2("calSearch","search_start_date","search_end_date", "day",2);
}
</script>
<cfif isDefined('calendarcolumns') EQ false>
<form name="calSearch" id="calSearch" target="_top" action="<cfif isDefined('calendarInclude')>/z/_a/rental/calendar-results<cfelse>#getCalendarLink(qrental)#</cfif>" method="get" style="margin:0px; padding:0px;">
<!---  ---><input type="hidden" name="action" value="search" />
<table style="width:100%; border-spacing:<cfif isDefined('rental_id')>8<cfelse>0</cfif>px;" <cfif isDefined('rental_id')>style="background-color:##FFFFFF; border:1px solid ##990000;"</cfif>>
<tr>
<cfif isDefined('calendarInclude') EQ false>
<td><strong>Select a rental to view its availability.</strong></td>
<td style="text-align:right;"><strong>Search Dates</strong></td>
</tr><tr>
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
zInputSelectBox(selectStruct);
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
<!--<strong>
 TODO: change to JQUery 
Check-in: #application.zcore.functions.zDateSelect("search_start_date", "search_start_date", year(initdate), ly,"updateOffset22")# 
Check-out: #application.zcore.functions.zDateSelect("search_end_date", "search_end_date", year(initdate), ly)#
</strong>-->

<strong>Check-In:</strong><input type="text" name="search_start_date" class="datepicker" />
<strong>Check-Out:</strong><input type="text" name="search_end_date" class="datepicker" />

<input type="submit" name="searchButton" value="Search Availability" style="text-align:center;" />

<cfelse>
<table style="border-spacing:5px;">
<tr><td><strong>Select Cabin:</strong></td>
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

</cfif>
</form>
</td>
</tr><!---  ---><!--- 
<tr><td colspan="2">&nbsp;</td></tr> --->
<cfif isDefined('request.hideCalendar') EQ false>
<tr>
<td colspan="2" class="cal-unavailable" style="text-align:left; ">Red Dates are unavailable.  <cfif isDefined('qrental')>All rates are for first #qrental.rental_addl_guest_count# guests.</cfif><br />
Rates are color coded so you can see what dates they fall on the calendar.<!--- <cfif rental_discount EQ 1><br />

<img src="/images/10-percent-off.gif" style="padding-top:5px;" /></cfif> ---></td>
</tr>
<tr><td colspan="2" style="padding:0px;">
<cfif isDefined('qrental')>
<table style="border-spacing:5px; font-weight:bold; width:100%;">
<tr><td style="background-color:##FFFFFF; border:1px solid ##000000; border-right:none; text-align:center;">Standard Rate: #DollarFormat(rental_rate)# per night</td>
<!--- <td style="background-color:##CCFF99; border:1px solid ##000000; border-right:none; text-align:center;">Peak Season Rate: #DollarFormat(rental_rate_peak)# per night</td> --->
<td style="background-color:##FFDD99; border:1px solid ##000000; text-align:center;">Holiday Rate: #DollarFormat(rental_rate_holiday)# per night</td></tr>
</table></cfif></td></tr>
</table>
	<!--- LOOPING THROUGH THE MONTHS; TERMINATES WHEN END OF CALENDAR DATE IS REACHED --->
	<table  style="margin-left:auto; margin-right:auto; border-spacing:5px;" class="cal-outer">
	<tr>
	<cfloop condition="#dateformat(form.inc_Date,"yyyymm")# NEQ #dateformat(end_date,"yyyymm")#">
	<cfset current_row = current_row + 1>
	<td style="vertical-align:top; ">
	<table style=" border-spacing:2px;" class="calendar">			
			<tr>
			<td colspan="7" style="text-align:center">
			<b>#dateformat(form.inc_Date,"mmmm yyyy")#</b>
			</td>
			</tr>
			<tr class="cal-days">
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
			<cfset cmonth = dateformat(form.inc_Date,"mmmm")>
			
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
						<td class="table-white"></td>
						<cfset layout_counter = layout_counter + 1>
					
					</cfif>
				</cfloop>
			
	
				<cfif layout_counter EQ 7>
					</tr><tr>
					<cfset layout_counter = 0>
				</cfif>
				
				<cfset layout_counter = layout_counter + 1>
	
				<cfif dateformat(form.inc_Date,"dddd") EQ cday>		
					<cfscript>
					try{
						status = availStruct[dateformat(form.inc_Date,"yyyy-mm-dd")];
						selected=true;
					}catch(Any excpt){
						status = true;
						selected=false;
					}
					
					m=month(form.inc_Date);
					/*peakRate=false;
					if(m EQ 6 or m EQ 7 or m EQ 10){
						peakRate=true;
					}*/
					try{
						status3 = holidayStruct[dateformat(form.inc_Date,"yyyy-mm-dd")];
						holidayRate=true;
					}catch(Any excpt){
						holidayRate=false;
					}
					/*
					try{
						status3 = peakStruct[dateformat(form.inc_Date,"yyyy-mm-dd")];
						peakRate=true;
					}catch(Any excpt){
						peakRate=false;
					}*/
					peakRate=false;
					if(selected){
						style='class="cal-unavailable" style="';
					}else if(holidayRate){
						style='class="cal-available" style="background-color:##FFDD99;';
					}else if(peakRate){
						style='class="cal-available" style="background-color:##CCFF99;';
					}else{
						style='class="cal-available" style="';
					}
					writeoutput('<td #style# width:20px; vertical-align:top; text-align:center;" >#dateformat(form.inc_Date,"d")#</td>');
					</cfscript>
					
				<cfelse>
					
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
			
			</tr>
			</table>
			</td>			
			<cfif current_row MOD number_of_columns EQ 1>
				</tr></cfif>			
	</cfloop>
	</cfif>
	</table>
<!--- </cfif> --->
</cfoutput>
 --->
 </cfcomponent>