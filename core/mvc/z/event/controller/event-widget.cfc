<cfcomponent>
<cfoutput> 	

<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	db=request.zos.queryObject;
	request.zPageDebugDisabled=true;
	form.heading=application.zcore.functions.zso(form, "heading", false, "Upcoming Events");
	request.zos.functions.zIncludeZOSForms();
	request.zos.functions.zrequirejquery();
	echo('<div class="zEventWidget-container">
		<h2>#form.heading#</h2>');
	request.zos.template.setPlainTemplate();
	form.startdate=now();
	form.enddate=dateadd("d", 365, now()); 
	form.calendarids=request.zos.functions.zso(form, 'calendarids'); 
	form.categories=request.zos.functions.zso(form, 'categories', true, 0); 
	if(form.categories EQ 0){
		form.categories="";
	}
	form.limit=min(20,request.zos.functions.zso(form, 'limit', true, 4));
	form.target=application.zcore.functions.zso(form, 'target', false, "_blank");
	echo(variables.simpleCalendarSidebar(form));

	eventCom=application.zcore.app.getAppCFC("event");
	link="";
	if(form.categories EQ ""){
		if(form.calendarids NEQ "" and form.calendarids DOES NOT CONTAIN ","){
			db.sql="select * from #db.table("event_calendar")# WHERE 
			event_calendar_id =#db.param(form.calendarids)# and 
			event_calendar_deleted=#db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# ";
			qCalendar=db.execute("qCalendar");
			for(row in qCalendar){
				link=eventCom.getCalendarURL(row);
			}
		}else{
			db.sql="select group_concat(event_calendar_id SEPARATOR #db.param(',')#) idlist from #db.table("event_calendar")# WHERE 
			event_calendar_id =#db.param(form.calendarids)# and 
			event_calendar_deleted=#db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# ";
			qCalendar=db.execute("qCalendar");
			if(qCalendar.recordcount and qCalendar.idlist NEQ ""){
				link="/z/event/event-calendar/index?calendarids=#qCalendar.idlist#";
			}
		}
	}else{
		db.sql="select * from 
		(#db.table("event_calendar")#, 
		#db.table("event_category")#) WHERE 
		event_calendar.event_calendar_id = event_category.event_calendar_id and 
		event_category_id =#db.param(form.categories)# and 
		event_calendar_deleted=#db.param(0)# and  
		event_category_deleted=#db.param(0)# and 
		event_calendar.site_id=event_category.site_id and 
		event_category.site_id = #db.param(request.zos.globals.id)# ";
		qCategory=db.execute("qCategory");
		for(row in qCategory){
			link=eventCom.getCategoryURL(row);
		}
	}
	if(link NEQ ''){
		echo('<a href="#link#" class="zEventWidget-full-link" target="_blank">View The Full Calendar</a>');
	}
	echo('</div>');
	</cfscript>
</cffunction>



<cffunction name="simpleCalendarSidebar" access="public" localmode="modern">
	<cfargument name="struct" type="struct" required="no" default="">
	<cfscript>
	ss=arguments.struct;
	// TODO add security check for calendarids

	ts.startdate=form.startdate;
	ts.enddate=form.enddate;
	ts.calendarids=form.calendarids;
	ts.categories=form.categories;
	ts.perpage=form.limit;


	dateCSS={}; 
	dateCSS.circle="zEventWidget-circle-1";
	dateCSS.line1small="zEventWidget-circle-2";
	dateCSS.line1="zEventWidget-circle-1-4";
	dateCSS.line2small="zEventWidget-circle-2";
	dateCSS.line2="zEventWidget-circle-1-3";
	dateCSS.link="zEventWidget-circle-5";

	rs=application.zcore.app.getAppCFC("event").searchEvents(ts);  
	</cfscript>
	<cfsavecontent variable="output"> 
		<cfif rs.count EQ 0>
			<h2>No upcoming events at this time.</h2>
		</cfif>
		<cfloop from="1" to="#arraylen(rs.arrData)#" index="n">   
			<cfset row=rs.arrData[n]> 
			<a href="#htmleditformat(row.__url)#" class="zEventWidget-circle-7" <cfif ss.target NEQ "">target="#htmleditformat(ss.target)#"</cfif>> 
				<span class="#dateCSS.circle#">
					<cfif row.event_end_datetime NEQ "" and dateformat(row.event_start_datetime, "mmm") NEQ dateformat(row.event_end_datetime, "mmm")>
						<span class="#dateCSS.line1small#">#dateformat(row.event_start_datetime, "m/d")#</span><span class="#dateCSS.line2small#">to</span>
						<span class="#dateCSS.line2small#">#dateformat(row.event_end_datetime, "m/d")#</span> 
					<cfelse>
						<span class="#dateCSS.line1#">#dateformat(row.event_start_datetime, "mmm")#</span>
						<cfif row.event_end_datetime NEQ "" and dateformat(row.event_start_datetime, "d") NEQ dateformat(row.event_end_datetime, "d")>
							<span class="#dateCSS.line2small#">#dateformat(row.event_start_datetime, "d")#-#dateformat(row.event_end_datetime, "d")#</span>
						<cfelse>
							<span class="#dateCSS.line2#">#dateformat(row.event_start_datetime, "d")#</span>
						</cfif>
					</cfif>
				</span> 
				<span class="#dateCSS.link#">#htmleditformat(row.event_name)#</span>
			 </a> 
		</cfloop> 
	</cfsavecontent>
	<cfscript>
	return output;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>