<cfcomponent extends="zcorerootmapping.functions.display">
<cfoutput><!--- zIsFutureDate(theDate); --->
<cffunction name="zIsFutureDate" localmode="modern" returntype="any" output="false">
	<cfargument name="theDate" type="string" required="yes">
	<cfscript>
	var result="";
	if(isDate(arguments.theDate)){
		arguments.theDate = parsedatetime(DateFormat(arguments.theDate,'yyyy-mm-dd'));
		result = DateCompare(now(), arguments.theDate);
		// true for today and the future
		if(result EQ -1 or result EQ 0){
			return true;
		}else{
			return false;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<cffunction name="zGetLastUpdatedDescription" localmode="modern" access="public">
	<cfargument name="date" type="string" required="yes">
	<cfscript>
	if(arguments.date NEQ "" and isDate(arguments.date)){
		seconds=datediff("s", arguments.date, now());
		if(seconds LT 5){
			if(not structkeyexists(request.zos, 'justNowDivOutput')){
				request.zos.justNowDivOutput=true;
				application.zcore.skin.addDeferredScript('zJumpToId("zJustNowDiv", -50);');
				return '<span class="lastUpdatedDescription" style="color:##900;font-weight:bold;" id="zJustNowDiv">Just now</span>';
			}else{
				return '<span class="lastUpdatedDescription" style="color:##900;">Just now</span>';
			}
		}
		if(seconds LT 60){
			return '<span class="lastUpdatedDescription" style="color:##990;">'&seconds&' seconds ago</span>';
		}else if(seconds LT 3600){
			return '<span class="lastUpdatedDescription" style="color:##090;">'&int(seconds/60)&' minutes ago</span>';
		}else if(seconds LT 86400){
			return '<span class="lastUpdatedDescription">'&int(seconds/3600)&' hours ago</span>';
		}else{
			return '<span class="lastUpdatedDescription">'&int(seconds/86400)&' days ago</span>';
		}
	}else{
		return '<span  class="lastUpdatedDescription">unknown</span>';
	}
	</cfscript>
</cffunction>

<cffunction name="zAddTimespanToDate" output="no" localmode="modern" returntype="date">
	<cfargument name="timespan" type="numeric" required="yes">
	<cfargument name="date" type="date" required="yes">
	<cfscript>
	return createOdbcDateTime(arguments.date+arguments.timespan);
	</cfscript>
</cffunction>


	
<!--- zDateTimeSelect(fieldName, selectedDate, firstYear, lastYear, onChange); --->
<cffunction name="zDateTimeSelect" localmode="modern" output="yes" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="selectedDateTime" type="string" required="no">
	<cfargument name="minutesPerOption" type="numeric" required="no" default="15">
	<cfscript>
	/*if(not structkeyexists(request.zos, 'dateTimeSelectIndex')){
		request.zos.dateTimeSelectIndex=0;
	}
	request.zos.dateTimeSelectIndex++;*/
	application.zcore.functions.zRequireTimePicker();
	application.zcore.skin.addDeferredScript('
	$( "###arguments.fieldName#_date" ).datepicker();
	$("###arguments.fieldName#_time").timePicker({
		show24Hours: false,
		step: #arguments.minutesPerOption#
	});
	');
	if(arguments.selectedDateTime NEQ "" and !isDate(arguments.selectedDateTime)){
		arguments.selectedDateTime=now();
	}
	echo('<input type="text" name="#arguments.fieldName#_date" id="#arguments.fieldName#_date" style="min-width:80px; width:80px;" value="#dateformat(arguments.selectedDateTime, 'm/d/yyyy')#" size="9" />
	 Time: <input type="text" name="#arguments.fieldName#_time" id="#arguments.fieldName#_time" style="min-width:80px; width:80px;" value="#timeformat(arguments.selectedDateTime, 'h:mm tt')#" size="10" />');
	</cfscript>
</cffunction>

<!--- zDateSelect(fieldName, selectedDate, firstYear, lastYear, onChange); --->
<cffunction name="zDateSelect" localmode="modern" output="yes" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="selectedDate" type="string" required="no">
	<cfargument name="firstYear" type="numeric" required="no" default="#year(now())-2#">
	<cfargument name="lastYear" type="numeric" required="no" default="#year(now())+2#">
	<cfargument name="onChange" type="string" required="no">
	<cfargument name="style" type="string" required="no" default="#false#">
	<cfargument name="showSelect" type="boolean" required="no" default="#false#">
	<cfargument name="noDays" type="boolean" required="no" default="#false#">
	<cfscript>
	var dateSelect = "";
	var i = 0;
	if(structkeyexists(arguments,'selectedDate') and structkeyexists(form, arguments.selectedDate)){
		arguments.selectedDate = form[arguments.selectedDate];
		if(isDate(arguments.selectedDate) EQ false){
			if(isNumericDate(arguments.selectedDate)){
				arguments.selectedDate = ParseDateTime(arguments.selectedDate);
			}else{
				StructDelete(arguments, "selectedDate", true);
			}
		}
	}else{
		arguments.selectedDate = now();
	}
	</cfscript>
	<cfif structkeyexists(arguments,'firstYear') and arguments.firstYear NEQ false and structkeyexists(arguments,'lastYear') and arguments.lastYear NEQ false>
		<cfif arguments.lastYear LT arguments.firstYear>
			<cfscript>
			application.zcore.functions.zError("ERROR: FUNCTION: zDateSelect: lastYear must be greater then or equal to firstYear", false, true);
			</cfscript>
		</cfif>
	<cfelse>
		<cfset arguments.firstYear = year(now())>
		<cfif structkeyexists(arguments,'lastYear') EQ false>
			<cfset arguments.lastYear = year(now())>
		</cfif>
	</cfif>
	<cfif structkeyexists(request,'zdateselectdaysoutput') EQ false>
		<cfset request.zdateselectdaysoutput=true>
		
		<script>
		/* <![CDATA[ */
		var zDateDaysInMonth=[];
		/* ]]> */
		<cfscript>
		for(i=1;i LTE 12;i=i+1){
			writeoutput('zDateDaysInMonth['&(i-1)&']='&daysinmonth(CreateDate(year(arguments.firstYear),i,1))&";");
		}
		</cfscript>
		function zDateSelectSetDays(field,type){
			var df=document.getElementById(field+'_day');
			var mf=document.getElementById(field+'_month');
			var yf=document.getElementById(field+'_year');
			if(type != 'day'){
				var ln=df.options.length;
				var si=df.selectedIndex;
				for(var i=0;i<ln;i++){
					df.options[0]=null;
				}
				var mon =mf.options[mf.selectedIndex].value;
				var yr=yf.options[yf.selectedIndex].value;
				if(mon==2 && yr % 4 == 0){ // leap year
					ln = 29;
				}else{
					ln = zDateDaysInMonth[mon-1];
				}
				for(var i=1;i<=ln;i++){
					df.options[i] = new Option(i,i);
				}
				if(ln>si){
					df.selectedIndex=si+1;
				}else{
					df.selectedIndex=ln-1;
				}
			}
		}
		</script>
		
	</cfif>
	<cfsavecontent variable="dateSelect">
		<select name="#arguments.fieldName#_month" id="#arguments.fieldName#_month" onChange="<cfif arguments.noDays EQ false>zDateSelectSetDays('#arguments.fieldName#','month');</cfif><cfif structkeyexists(arguments,'onChange')>#arguments.onChange#(this.selectedIndex, 'month');</cfif>" <cfif arguments.style NEQ false>class="#arguments.style#"</cfif> size="1">
			<cfif arguments.showSelect or 1 EQ 1><option value="">-- Select --</option></cfif>
			<option value="1" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 1>selected="selected"</cfif>>January</option>
			<option value="2" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 2>selected="selected"</cfif>>February</option>
			<option value="3" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 3>selected="selected"</cfif>>March</option>
			<option value="4" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 4>selected="selected"</cfif>>April</option>
			<option value="5" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 5>selected="selected"</cfif>>May</option>
			<option value="6" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 6>selected="selected"</cfif>>June</option>
			<option value="7" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 7>selected="selected"</cfif>>July</option>
			<option value="8" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 8>selected="selected"</cfif>>August</option>
			<option value="9" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 9>selected="selected"</cfif>>September</option>
			<option value="10" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 10>selected="selected"</cfif>>October</option>
			<option value="11" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 11>selected="selected"</cfif>>November</option>
			<option value="12" <cfif structkeyexists(arguments,'selectedDate') and month(arguments.selectedDate) EQ 12>selected="selected"</cfif>>December</option>
		</select>
		<cfif arguments.noDays EQ false>
		<select name="#arguments.fieldName#_day" id="#arguments.fieldName#_day" onChange="zDateSelectSetDays('#arguments.fieldName#','day');<cfif structkeyexists(arguments,'onChange')>#arguments.onChange#(this.selectedIndex, 'day');</cfif>" <cfif arguments.style NEQ false>class="#arguments.style#"</cfif> size="1">			
			<cfif arguments.showSelect><option value="">--</option></cfif>
		<cfloop from="1" to="31" step="1" index="i">
			<option <cfif structkeyexists(arguments,'selectedDate') and day(arguments.selectedDate) EQ i>selected="selected"</cfif> value="#i#">#i#</option>
		</cfloop>
		</select>
		</cfif>
		<select name="#arguments.fieldName#_year" id="#arguments.fieldName#_year" onChange="<cfif arguments.noDays EQ false>zDateSelectSetDays('#arguments.fieldName#','year');</cfif><cfif structkeyexists(arguments,'onChange')>#arguments.onChange#(this.selectedIndex, 'year');</cfif>" <cfif arguments.style NEQ false>class="#arguments.style#"</cfif> size="1">
			<cfif arguments.showSelect><option value="">----</option></cfif>
		<cfloop from="#arguments.firstYear#" to="#arguments.lastYear#" step="1" index="i">
			<option <cfif structkeyexists(arguments,'selectedDate') and year(arguments.selectedDate) EQ i>selected="selected"</cfif> value="#i#">#i#</option>
		</cfloop>
		</select>
		<cfif arguments.noDays EQ false>
			<script>/* <![CDATA[ */
			zDateSelectSetDays('#arguments.fieldName#','month');/* ]]> */
			</script>
		</cfif>
	</cfsavecontent>
	<cfreturn dateSelect>
</cffunction>



<!--- zTimeSelect(fieldName, selectedTime, hourstep, minutestep, style); --->
<cffunction name="zTimeSelect" localmode="modern" output="true" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="selectedTime" type="string" required="no">
	<cfargument name="hourstep" type="string" required="no" default="1">
	<cfargument name="minutestep" type="string" required="no" default="5">
	<cfargument name="style" type="any" required="no" default="">
	<cfscript>
	var i = 0;
	var theOutput="";
	var cur="";
	var stepminute="";
	var stephour="";
	if(structkeyexists(arguments,'selectedTime') and structkeyexists(form, arguments.selectedTime)){
		if(isdate(form[arguments.selectedTime]) EQ false){
			arguments.selectedTime = parsedatetime(dateformat(now(),'yyyy-mm-dd')&' '&timeformat(form[arguments.selectedTime],'HH:mm:ss'));
		}else{
			arguments.selectedTime = parsedatetime(dateformat(form[arguments.selectedTime],'yyyy-mm-dd')&' '&timeformat(form[arguments.selectedTime],'HH:mm:ss'));
		}
		if(isDate(arguments.selectedTime) EQ false){
			if(isNumericDate(arguments.selectedTime)){
				arguments.selectedTime = ParseDateTime(arguments.selectedTime);
			}else{
				StructDelete(arguments, "selectedTime", true);
			}
		}
	}else{
		arguments.selectedDate = now();
	}
    if(structkeyexists(arguments,'selectedTime')){
		stepminute=minute(arguments.selectedTime)-(minute(arguments.selectedTime) mod arguments.minutestep);
		stephour=(timeformat(arguments.selectedTime,'h')-(timeformat(arguments.selectedTime,'h') mod arguments.hourstep));
	}
	</cfscript><cfsavecontent variable="theOutput"><select name="#arguments.fieldName#_hour" size="1" <cfif arguments.style NEQ ''>class="#arguments.style#"</cfif>><cfloop from="1" to="12" index="i" step="#arguments.hourstep#"><option value="#i#"<cfif structkeyexists(arguments,'selectedTime') and  stephour EQ i> selected="selected"</cfif>>#i#</option></cfloop></select>:<select name="#arguments.fieldName#_minute" size="1"  <cfif arguments.style NEQ ''>class="#arguments.style#"</cfif>>
    <cfloop from="0" to="59" index="i" step="#arguments.minutestep#"><cfset cur=replace(rjustify(i,2)," ","0","ALL")><option value="#cur#"<cfif structkeyexists(arguments,'selectedTime') and  stepminute EQ i> selected="selected"</cfif>>#cur#</option></cfloop></select> <select name="#arguments.fieldName#_ampm" size="1" <cfif arguments.style NEQ ''>class="#arguments.style#"</cfif>><option value="AM" <cfif structkeyexists(arguments,'selectedTime') and hour(arguments.selectedTime) LT 12>checked="checked"</cfif>>AM</option>
	<option value="PM" <cfif structkeyexists(arguments,'selectedTime') and hour(arguments.selectedTime) GTE 12> selected="selected"</cfif>>PM</option>
</select></cfsavecontent>
	<cfscript>
    return theOutput;
    </cfscript>
</cffunction>


<cffunction name="zGetTimeSelect" localmode="modern" output="false" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="mask" type="string" required="no">
	<cfargument name="enumerate" type="numeric" required="no">
	<cfscript>
	var newDate = "";
	if(structkeyexists(arguments,'enumerate')){
		arguments.fieldName = arguments.fieldName & arguments.enumerate;
	}
	if(structkeyexists(form, arguments.fieldName&"_hour") and structkeyexists(form, arguments.fieldName&"_minute") and structkeyexists(form, arguments.fieldName&"_ampm")){
		newDate = parsedatetime("2007-01-01 "&form[arguments.fieldName&"_hour"]&":"&form[arguments.fieldName&"_minute"]&" "& form[arguments.fieldName&"_ampm"]);
		if(isDate(newDate)){
			if(structkeyexists(arguments,'mask')){
				return timeformat(newDate, arguments.mask);
			}else{
				return timeformat(newDate,"HH:mm:ss");
			}
		}else{
			return false;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="zGetDateSelect" localmode="modern" output="false" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="mask" type="string" required="no">
	<cfargument name="enumerate" type="numeric" required="no">
	<cfscript>
	var newDate = "";
	if(structkeyexists(arguments,'enumerate')){
		arguments.fieldName = arguments.fieldName & arguments.enumerate;
	}
	if(structkeyexists(form, arguments.fieldName&"_month") and structkeyexists(form, arguments.fieldName&"_day") and structkeyexists(form, arguments.fieldName&"_year")){
		newDate = form[arguments.fieldName&"_month"]&"/"&form[arguments.fieldName&"_day"]&"/"& form[arguments.fieldName&"_year"];
		if(isDate(newDate)){
			if(structkeyexists(arguments, 'mask')){
				return dateformat(createDate(form[arguments.fieldName&"_year"], form[arguments.fieldName&"_month"], form[arguments.fieldName&"_day"]), arguments.mask);
			}else{
				return createDate(form[arguments.fieldName&"_year"], form[arguments.fieldName&"_month"], form[arguments.fieldName&"_day"]);
			}
		}else{
			return false;
		}
	}else{
		return false;
	}
	</cfscript>
</cffunction>


<!--- application.zcore.functions.zGetDateTimeSelect("field_datetime", "yyyy-mm-dd", "HH:mm:ss"); --->
<cffunction name="zGetDateTimeSelect" localmode="modern" output="yes" returntype="any">
	<cfargument name="fieldName" type="string" required="yes">
	<cfargument name="dateMask" type="string" required="no">
	<cfargument name="timeMask" type="string" required="no">
	<cfargument name="enumerate" type="numeric" required="no">
	<cfscript>
	if(structkeyexists(arguments,'enumerate')){
		arguments.fieldName = arguments.fieldName & arguments.enumerate;
	}
	if(structkeyexists(form, arguments.fieldName&"_date")){
		curDate=dateformat(form[arguments.fieldName&"_date"], "yyyy-mm-dd");
	}else if(structkeyexists(form, arguments.fieldName)){
		if(arguments.dateMask EQ "" and arguments.timeMask EQ ""){
			return parsedatetime(dateformat(form[arguments.fieldName], "yyyy-mm-dd")&" "&timeformat(form[arguments.fieldName], "HH:mm:ss"));
		}else{
			if(arguments.dateMask EQ ""){
				arguments.dateMask="yyyy-mm-dd";
			}
			if(arguments.timeMask EQ ""){
				arguments.timeMask="HH:mm:ss";
			}
			curDate=dateformat(form[arguments.fieldName], arguments.dateMask)&" "&timeformat(form[arguments.fieldName], arguments.timeMask);
		}
	}else{
		return '';
	}
	if(structkeyexists(form, arguments.fieldName&"_time")){
		curDate&=" "&timeformat(form[arguments.fieldName&"_time"], "HH:mm:ss");
		if(isdate(curDate)){
			curDate=parsedatetime(curDate);
		}
	}else{
		curDate=parsedatetime(curDate);
	}
	if(arguments.dateMask EQ "" and arguments.timeMask EQ ""){
		return curDate;
	}else{
		return dateformat(curDate, arguments.dateMask)&" "&timeformat(curDate, arguments.timeMask);
	}
	</cfscript>
</cffunction>

<!--- application.zcore.functions.zTimeSinceDate( date ); --->
<cffunction name="zTimeSinceDate" localmode="modern" access="public">
	<cfargument name="date" type="string" required="yes">
	<cfargument name="onlyDates" type="boolean" required="no" default="false" hint="Whether or not only dates should be used. If set to true, will use 'Today' and 'Yesterday' instead of seconds, minutes, hours ago.">
	<cfscript>
		onlyDates = arguments.onlyDates;

		if ( arguments.date NEQ '' AND isDate( arguments.date ) ) {
			seconds = dateDiff( 's', arguments.date, now() );

			if ( onlyDates ) {
				if ( dateFormat( arguments.date, 'yyyy-mm-dd' ) EQ dateFormat( now(), 'yyyy-mm-dd' ) ) {
					return 'Today';
				} else if ( dateFormat( arguments.date, 'yyyy-mm-dd' ) EQ dateFormat( ( dateAdd( 'd', -1, now() ) ), 'yyyy-mm-dd' ) ) {
					return 'Yesterday';
				} else {
					return int( seconds / 86400 ) & ' days ago';
				}
			} else {
				if ( seconds LT 5 ) {
					return 'Just now';
				} else if ( seconds LT 60 ) {
					return seconds & ' seconds ago';
				} else if ( seconds LT 120 ) {
					return 'One minute ago';
				} else if ( seconds LT 3600 ) {
					return int( seconds / 60 ) & ' minutes ago';
				} else if ( seconds LT 7200 ) {
					return 'One hour ago';
				} else if ( seconds LT 86400 ) {
					return int( seconds / 3600 ) & ' hours ago';
				} else if ( seconds LT 172800 ) {
					return 'One day ago';
				} else {
					return int( seconds / 86400 ) & ' days ago';
				}
			}
		} else {
			return 'Unknown';
		}
</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>