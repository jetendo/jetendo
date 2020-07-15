<cfcomponent>
<!--- 
this script was never upgraded to new system.


<!--- helps you search all rentals and you click on make a reservation to see the actual booking form. --->
<cfscript>
application.zcore.app.getAppCFC("rental").onRentalPage();

</cfscript>
<!--- Disabled.<cfscript>application.zcore.functions.zabort();</cfscript> --->
<cfscript>
var db=request.zos.queryObject;
//startDateFieldName="search_start_date";
//endDateFieldName="search_end_date";
startDateFieldName="#form.search_start_date#";
endDateFieldName="#form.search_end_date#";
</cfscript>

<cfoutput>
<cfsavecontent variable="zoverridemetakey">
<meta name="Keywords" content="rental availability search results" />
</cfsavecontent>
<cfsavecontent variable="zoverridemetadesc">
<meta name="Description" content="Rental availability search results." />
</cfsavecontent>
<cfscript>
zoverridetitle = "Availability Search Results";
zpagetitle = "Availability Search Results";

// if lake house - add before and after
tsd=search_start_date;
ted=search_end_date;
oldDate=parsedatetime(dateformat(dateadd("d",2,now()),"yyyy-mm-dd")&" 00:00:00");
newDate=parsedatetime(dateformat(search_start_date,"yyyy-mm-dd")&" 00:00:01");
oldDate=dateadd("d",2,now());
newDate=search_start_date;
newDate=parsedatetime(dateformat(search_start_date,"yyyy-mm-dd")&" 16:00:00");
if(datecompare(newDate,oldDate) LTE 0){
	writeoutput("<h2>Online reservations must be placed 48 hours in advance.</h2> Please call our office at 1-888-452-9567 to check availability and place your reservation.");
	//reserveDisabled=1;
}
/*
if(rental_id EQ 18 or rental_id EQ 42){
	tsd=dateadd("d",-1,search_start_date);
	ted=dateadd("d",1,search_end_date);
	writeoutput('<strong>Please note this rental must be available one day before and after your stay in order for it to be reserved.</strong><br /><br /><br />');
}
if(rental_id EQ 36 and zso(form, 'inquiries_adults',true) + zso(form, 'inquiries_children',true) GT 6){
	ted=dateadd("d",1,search_end_date);
	//writeoutput('Please note this rental must be available one day after your stay in order for it to be reserved.<br /><br /><br />');
}
*/
</cfscript>
<cfsavecontent variable="zpagenav">

<a href="#request.zos.currentHostName#/">Home</a> / <a href="#request.zos.currentHostName#/cabin_rentals/index.html">Cabin Rentals</a> /
</cfsavecontent>
<cfparam name="security_deposit" type="any" default="">
<cfif application.zcore.functions.zso(form, 'action') EQ "search">
  <!--- <cfsavecontent variable="db.sql">
SELECT rental_id, count(availability_date) count FROM rental 
LEFT JOIN availability ON 
(availability_date >= #db.param(DateFormat(now(), "yyyy-mm-dd"))#  and 
availability.rental_id = rental.rental_id) 
WHERE rental.rental_active=#db.param(1)# and 
rental_deleted = #db.param(0)#
</cfsavecontent><cfscript>qSort=db.execute("qSort");</cfscript> --->
  <cfsavecontent variable="db.sql">
    SELECT *, count(a2.rental_id) unavailableCount FROM rental 
    LEFT JOIN availability a1 ON 
	(a1.availability_date BETWEEN #db.param(DateFormat(tsd, "yyyy-mm-dd"))# and 
	#db.param(DateFormat(ted, "yyyy-mm-dd"))# and 
	a1.rental_id = rental.rental_id)  and rental.site_id=a1.site_id and
  a1.availability_deleted = #db.param(0)#
    LEFT JOIN availability a2 ON 
	(a2.availability_date >= #db.param(DateFormat(now(), "yyyy-mm-dd"))#  and 
	a2.rental_id = rental.rental_id) and 
	rental.site_id=a2.site_id and 
  a2.availability_deleted = #db.param(0)#
    WHERE a1.rental_id IS NULL and 
    rental_deleted = #db.param(0)# and 
	rental.rental_active=#db.param(1)# and 
rental.rental_id <> #db.param('7')#  and 
rental.site_id=#db.param(request.zos.globals.id)#
    GROUP BY rental.rental_id
    ORDER BY unavailableCount ASC
    </cfsavecontent><cfscript>qAvail=db.execute("qAvail");</cfscript>
  <cfif isDefined('reserveDisabled')>
    <cfelseif qAvail.recordcount EQ 0>
    <h2>Sorry, but none of our Cabin Rentals are available from #DateFormat(search_start_date, 'm/d/yyyy')# to #DateFormat(search_end_date,'m/d/yyyy')#</h2>
    Please search again using different dates or call us at 1-888-452-9567 to check for last minute cancellations!
    <cfelse>
    <cfscript>
avail=false;
for(i=1;i LTE qAvail.recordcount;i=i+1){
	if(structkeyexists(form, 'rental_id') and form.rental_id EQ qavail.rental_id[i]){
		avail=true;
		application.zcore.functions.zQueryToStruct(qAvail,form,'',i);
	}
}
nights=datediff("d",search_start_date,search_end_date);
</cfscript>
    <cfset required3Night=false>
    <cfset required4Night=false>
    <cfset required7Night=false>
    <cfsavecontent variable="db.sql">
    SELECT * FROM #db.table("rental", request.zos.zcoreDatasource)# rental 
	WHERE rental_id=#db.param(application.zcore.functions.zso(form, 'rental_id'))# and 
	rental_active=#db.param('1')# and 
  rental_deleted = #db.param(0)#
    </cfsavecontent><cfscript>qPPPP=db.execute("qPPPP");</cfscript>
    <!---  <cfif qPPPP.recordcount NEQ 0 and qPPPP.rental_7nightmin EQ 1 and nights lt 7>
        <cfsavecontent variable="db.sql">
        SELECT count(availability_date) count 
        FROM availability 
        WHERE availability.rental_id = #db.param('43')# and 
        availability_deleted = #db.param(0)# and 
		availability_date >= #db.param(DateFormat(search_start_date, 'yyyy-mm-dd')&' 00:00:00')# and 
		availability_date <= #db.param(DateFormat(search_end_date, 'yyyy-mm-dd')&' 00:00:00')#
        </cfsavecontent><cfscript>q7Night=db.execute("q7Night");</cfscript>
        <cfif q7Night.count NEQ 0>
          <cfset hideOtheravail=false>
          <cfset required7Night=true>
        </cfif>
      </cfif>
      <cfset required4Night=false>
      <cfif nights lt 4>
        <cfsavecontent variable="db.sql">
        SELECT count(availability_date) count 
        FROM availability 
        WHERE availability.rental_id = #db.param('35')# and 
        availability_deleted = #db.param(0)# and 
		availability_date >= #db.param(DateFormat(search_start_date, 'yyyy-mm-dd')&' 00:00:00')# and 
		availability_date <= #db.param(DateFormat(search_end_date, 'yyyy-mm-dd')&' 00:00:00')#
        </cfsavecontent><cfscript>q4Night=db.execute("q4Night");</cfscript>
        <cfif q4Night.count NEQ 0>
          <cfset hideOtheravail=false>
          <cfset required4Night=true>
        </cfif>
      </cfif>
      <cfif required4night EQ false and nights lt 3>
        <cfsavecontent variable="db.sql">
        SELECT count(availability_date) count 
        FROM availability 
        WHERE availability.rental_id = #db.param('34')# and 
        availability_deleted = #db.param(0)# and
		availability_date >= #db.param(DateFormat(search_start_date, 'yyyy-mm-dd')&' 00:00:00')# and 
availability_date <= #db.param(DateFormat(search_end_date, 'yyyy-mm-dd')&' 00:00:00')#
        </cfsavecontent><cfscript>q3Night=db.execute("q3Night");</cfscript>
        <cfif q3Night.count NEQ 0>
          <cfset hideOtheravail=false>
          <cfset required3Night=true>
        </cfif>
      </cfif>
      <cfif required7night>
        <h2>There is a 7 night minimum stay required to make a reservation for #qpppp.rental_name#.<br />
          <br />
          Please select at least 7 nights below and click &quot;Search Availability&quot;</h2>
        <cfelseif required4night>
        <h2>Due to the holiday, there is a 4 night minimum stay required to make a reservation.<br />
          <br />
          Please select at least 4 nights below and click &quot;Search Availability&quot;</h2>
        <cfelseif required3night>
        <h2>Due to the holiday, there is a 3 night minimum stay required to make a reservation.<br />
          <br />
          Please select at least 3 nights below and click &quot;Search Availability&quot;</h2>
        <cfelse> --->
    <cfif structkeyexists(form, 'rental_id') and form.rental_id NEQ ''>
      <!---  <cfif rental_id EQ '42'>
       <cfsavecontent variable="db.sql">
                SELECT * FROM #db.param("availability", request.zos.zcoreDatasource)# availability 
				WHERE availability_date BETWEEN #db.param(DateFormat(dateadd("d",-1,tsd), "yyyy-mm-dd"))# and 
        availability_deleted = #db.param(0)# and 
				#db.param(DateFormat(DateAdd("d",1,ted), "yyyy-mm-dd"))# and 
				availability.rental_id = #db.param(rental_id)# 
                </cfsavecontent><cfscript>qAvail222=db.execute("qAvail222");</cfscript>
        <cfif qAvail222.recordcount NEQ 0>
          <h2>The cabin rental, &quot;Blue Ridge Mansion&quot; requires 1 available day before and after your stay.  Please adjust your stay dates and check availability again or try a different cabin.</h2>
          <cfset avail=false>
        </cfif> --->
        <!--- </cfif> --->
       <!---  <cfif rental_id EQ '38' and datecompare(search_start_date, createdate(2008,3,1)) EQ -1>
          <h2>Cherokee Ridge Cabin Rentals is not available for rent until March 1st, 2008.</h2>
          <cfset avail=false>
          <cfelseif avail>
          <table style="width:100%; border-spacing:10px; border:1px solid ##990000; background-color:##FFFFFF;">
          <cfif structkeyexists(form, 'zsid')>
            <tr>
              <td><h2>At least 1 adult is required to make a reservation.</h2></td>
            </tr>
          </cfif> --->
          <tr>
          <td>
          <h2>#rental_name# Cabin Rental is available from #DateFormat(search_start_date, 'm/d/yyyy')# to #DateFormat(search_end_date,'m/d/yyyy')#!</h2>
          <hr />
          <table style="border-spacing:5px; width:100%;">
            <tr>
              <td colspan="2"><strong>Please note only the 
                <!---  <cfif rental_id EQ 18 or rental_id EQ 42>
                    initial
                    <cfelse>
                    $250
                  </cfif> ---> initial
                down payment will be required to reserve the cabin.<br />
                The total booking amount is due at check-in. <br />
                Refer to our <a href="#request.zos.currentHostName#/reservation-information-policies.html" target="_blank">cabin rental policies</a> for more information.</strong></td>
            </tr>
          </table>
          <table style="border-spacing:5px; width:100%;">
            <tr>
              <td>Start Date:</td>
              <td>#DateFormat(search_start_date,'mmmm d, yyyy')#</td>
            </tr>
            <tr>
              <td>End Date:</td>
              <td>#DateFormat(search_end_date,'mmmm d, yyyy')#</td>
            </tr>
            <cfscript>
	nights=DateDiff("d",search_start_date,search_end_date);
	
	</cfscript>
            <tr>
              <td>## of Nights:</td>
              <td>#nights#</td>
            </tr>
            <tr>
              <td>&nbsp;</td>
            </tr>
            <table style="border-spacing:5px;">
              <form class="zFormCheckDirty" id="myCalc" action="#request.zos.globals.securedomain#/z/_a/rental/reserve?rental_id=#rental_id#&amp;reserve=1&amp;secure=1&amp;inquiries_start_date=#urlencodedformat(search_start_date)#&amp;inquiries_end_date=#urlencodedformat(search_end_date)#" method="post" enctype="multipart/form-data" >
                <tr>
                  <td colspan = "2"><h2>Please select ## of adults and children and click &quot;Book Now&quot;</h2></td>
                </tr>
                <tr>
                  <td>Adults:</td>
                  <td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_adults";
			selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript></td>
                </tr>
                <tr>
                  <td>Children<br />
                    (age 3 and up):</td>
                  <td ><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_children";
			selectStruct.listValues = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript></td>
                </tr>
                <tr>
                  <td style="vertical-align:top; ">Children<br />
                    (under age 3):</td>
                  <td style="vertical-align:top;"><cfscript> 
selectStruct = StructNew(); selectStruct.name = "inquiries_children_age"; selectStruct.listValues = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20"; application.zcore.functions.zInputSelectBox(selectStruct); 
</cfscript>
                    <strong>Note: </strong>Children under age 3 are free.</td>
                </tr>
                <!---  <cfif rental_id EQ 47 or rental_id EQ 49 or rental_id EQ 52>
                    <tr>
                      <td>Pets:</td>
                      <td ><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_pets";
			selectStruct.listValues = "0,1,2";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript>
          <cfif rental_id EQ 52>
          There will be a $10 rental fee per pet and $25 additional cleaning fee added to your stay if you intend to bring a pet. (2 pet limit)
          <cfelseif rental_id EQ 49>
          There will be a $20 rental fee per pet and $20 additional cleaning fee added to your stay if you intend to bring a pet. (2 pet limit)
          <cfelse>
                        <strong>Pet Fees: </strong>One payment of $75 will be charged if you bring a pet. (2 pet limit)
                        </cfif></td>
                    </tr>
                  </cfif> ---> 
                <!--- <cfif rental_id EQ 26>
                    <tr>
                      <td style="white-space:nowrap;">Pets:</td>
                      <td ><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_pets";
			selectStruct.listValues = "0,1,2";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript>
                        <strong>Pet Fees: </strong>$15 per night per pet and $20 additional cleaning fee per pet. (2 pet limit)</td>
                    </tr>
                  </cfif> ---> 
                <!---  <tr><td>Coupon code:</td><td><input name="inquiries_coupon_code" type="text" size="5" MAXLENGTH="5" > (optional)</td>
        </tr>	 --->
                <tr>
                  <td colspan="2"><br />
                    <button type="submit" name="submit">Book Now</button></td>
                </tr>
              </form>
            </table>
            <!---<cfif inquiries_adults neq "" and inquiries_children neq "" and inquiries_children_age neq "">
<tr><td style="text-align:center;">
<span style="font-size:18px;"><a href="#request.zos.globals.securedomain#/inquiry.cfm?rental_id=#rental_id#&reserve=1&secure=1&search_start_date_month=#search_start_date_month#&search_start_date_day=#search_start_date_day#&search_start_date_year=#search_start_date_year#&inquiries_end_date_month=#search_end_date_month#&inquiries_end_date_day=#search_end_date_day#&inquiries_end_date_year=#search_end_date_year#">Book Now</a></span>--->
            <tr>
              <td></td>
              </td>
            
              </tr>
            
            <tr>
              <td>
            </tr>
              </td>
            
              </tr>
            
          </table>
          <br />
          <br />
          <hr />
          <cfelse>
          <cfsavecontent variable="db.sql">
          SELECT * FROM rental 
		  WHERE rental_id = #db.param(form.rental_id)# and 
			rental_active=#db.param(1)#
          </cfsavecontent><cfscript>qProp=db.execute("qProp");
if(qprop.recordcount EQ 0){
	application.zcore.status.setStatus(request.zsid, 'This rental is no longer available.');
	application.zcore.functions.zRedirect('/inquiry.cfm?zsid=#request.zsid#');
}
zQueryToStruct(qprop);
</cfscript>
          <h2>Sorry, but #rental_name# Cabin Rental was not available from #DateFormat(search_start_date, 'm/d/yyyy')# to #DateFormat(search_end_date,'m/d/yyyy')#</h2>
          Please review the calendar for this rental and select new dates
          <cfif qavail.recordcount NEQ 0>
            or select a different cabin that is available from the results below
          </cfif>
          <br />
          <br />
          <table style="border-spacing:8px;border:1px solid ##990000; background-color:##FFFFFF; width:100%;">
            <tr>
              <td><h2 style="padding:0px; display:inline;">#rental_name# Cabin Rental Availability Calendar</h2></td>
            </tr>
          </table>
          <cfset calendarInclude=true>
	  include calendar
          <hr />
        </cfif>
      </cfif>
    </cfif>
    <cfif isDefined('hideOtheravail') EQ false>
      <table class="zrental-tbspace" style="border-spacing:3px;border:1px solid ##990000; background-color:##FFFFFF; width:100%;">
        <tr>
          <td colspan="5"><h2>The following cabins
              <cfif avail>
                also
              </cfif>
              have availability from #DateFormat(search_start_date, 'm/d/yyyy')# to #DateFormat(search_end_date,'m/d/yyyy')#</h2></td>
        </tr>
        <tr>
          <th colspan="2">Cabin Rental</th>
          <th>BR/BA/Sleeps</th>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <cfscript>
/*startDate=dateadd("d",3,now());
endDate=dateadd("d",3,startDate);
startDate_month=month(startdate);
startDate_year=year(startdate);
startDate_day=day(startdate);
endDate_month=month(enddate);
endDate_year=year(enddate);
endDate_day=day(enddate);
startDate="startDate";
endDate="endDate";*/
inquiries_adults=2;
inquiries_children=0;
inquiries_coupon="";
</cfscript>
        <cfloop query="qAvail">
        <tr>
          <td rowspan="2"  style="vertical-align:top;border-bottom:1px solid ##999999;<cfif qAvail.currentrow MOD 2 EQ 0>background-color:##F3F3F3;</cfif>"><!--- <a href="#rental_url#"><img src="#rental_photo#" width="90" alt="Exterior view of our #rental_name# cabin rental." /><img src="#replacenocase(rental_photo,".jpg","-view.jpg")#" width="90" alt="The view from our #rental_name# cabin rental." /></a> ---></td>
          <td style="<cfif currentrow MOD 2 EQ 0>background-color:##F3F3F3;</cfif>"><a href="#rental_url#">#rental_name#</a></td>
          <td style="<cfif currentrow MOD 2 EQ 0>background-color:##F3F3F3;</cfif>">#rental_beds# Bedroom<cfif rental_beds GT 1>s</cfif><br />
            #rental_bath# Bathroom<cfif rental_bath GT 1>s</cfif><br />
            Sleeps 1 to #rental_max_guest#</td>
          <td style="<cfif currentrow MOD 2 EQ 0>background-color:##F3F3F3;</cfif>"><cfscript>
ts=StructNew();
ts.rental_id=rental_id;
ts.startDate=search_start_date;
ts.endDate=search_end_date;
ts.adults=inquiries_adults;
ts.pets=zso(form, 'inquiries_pets',true);
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
</cfscript>
            <span style="line-height:18px;">
            <cfif preg-mrate NEQ 0>
              <span style="text-decoration:line-through; color:##CCCCCC; font-size:12px;">From #dollarformat(preg)#/night</span><br />
            </cfif>
            From #dollarformat(mrate)#/night<br />
            <cfif preg-mrate NEQ 0>
              <strong style="color:##FF0000; font-size:12px;">Save up to $#(preg-mrate)#/night</strong>
            </cfif>
            </span></td>
          <td style="<cfif currentrow MOD 2 EQ 0>background-color:##F3F3F3;</cfif>"><a href="#rental_url#">View rental</a><br />
            <a href="#request.zos.globals.securedomain#/z/_a/rental/calendar-results?rental_id=#rental_id#&amp;reserve=1&amp;secure=1&amp;&amp;search_start_date=#urlencodedformat(search_start_date)#&amp;search_end_date=#urlencodedformat(search_end_date)#">Make a Reservation</a><br />
            <a href="/#zURLEncode(rental_name,'-')#-Cabin-Rental-Availability-Calendar-1-#rental_id#.html">Availability Calendar</a><br /></td>
        </tr>
        <cfscript>
arrAmen=arraynew(1);

if(rental_pool EQ 1){
	arrayappend(arrAmen,'Pool');	
}
if(rental_mountainview EQ 1){
	arrayappend(arrAmen,'Mountain View');	
}
if(rental_waterview EQ 1){
	arrayappend(arrAmen,'Water View');	
}
if(rental_gameroom EQ 1){
	arrayappend(arrAmen,'Game Room');	
}
if(rental_cabletv EQ 1){
	arrayappend(arrAmen,'Satellite/Cable TV');	
}
if(rental_highspeedinternet EQ 1){
	arrayappend(arrAmen,'High Speed Internet');	
}
if(rental_fireplace EQ 1){
	arrayappend(arrAmen,'Fireplace');	
}
if(rental_hottub EQ 1){
	arrayappend(arrAmen,'Hot Tub');	
}
</cfscript>
        <tr>
          <td colspan="4" style="height:45px;vertical-align:top;border-bottom:1px solid ##999999;<cfif currentrow MOD 2 EQ 0>background-color:##F3F3F3;</cfif>"><strong>Features:</strong> #arraytolist(arrAmen,", ")#</td>
        </tr>
        </cfloop>
      </table>
<!---     </cfif> --->
  <!--- </cfif> --->
  <hr />
  <h2>Search Availability Again</h2>
  <cfset calendarInclude=true>
  <cfset request.hideCalendar=true>
  include availability calendar
</cfif>
</cfoutput>
 --->
 </cfcomponent>