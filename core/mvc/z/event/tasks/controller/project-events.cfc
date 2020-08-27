<cfcomponent>
<cfoutput>
<!--- 
one site
/z/event/tasks/project-events/index?sid=#request.zos.globals.id#&forceAll=1
or
all sites
/z/event/tasks/project-events/index?forceAll=1
 --->
<cffunction name="index" access="remote" localmode="modern">
	<cfscript>
	db=request.zos.queryObject;
	
	application.zcore.functions.checkIfCronJobAllowed();
	request.ignoreSlowScript=true;
	setting requesttimeout="5000";

	request.ical=createobject("component", "zcorerootmapping.com.ical.ical");
	request.ical.init("");

	form.forceAll=application.zcore.functions.zso(form, 'forceAll', true, 0);
	form.sid=application.zcore.functions.zso(form, 'sid', true, 0);

	offset=0;
	while(true){
		db.sql="select * from #db.table("event", request.zos.zcoreDatasource)#, 
		#db.table("event_config", request.zos.zcoredatasource)#
		WHERE 
		event.site_id = event_config.site_id and 
		event_config_deleted=#db.param(0)# and 
		event.site_id <> #db.param(-1)# and ";
		if(form.sid NEQ 0){
			db.sql&=" event.site_id = #db.param(form.sid)# and ";
		}
		if(form.forceAll EQ 0){
			if(structkeyexists(form, 'processNonRecurring')){
				db.sql&=" event_recur_ical_rules=#db.param('')# and ";
			}else{
				db.sql&=" event_recur_ical_rules<> #db.param('')# and 
				(event_recur_count = #db.param(0)# or 
				event_recur_until_datetime >=#db.param(dateformat(now(), "yyyy-mm-dd")&" 00:00:00")#) and ";
			}
		}
		// db.sql&=" event.event_id=#db.param(26)# and ";
		db.sql&="  
		event_deleted=#db.param(0)# 
		LIMIT #db.param(offset)#, #db.param(30)#";
		qEvent=db.execute("qEvent");
		if(qEvent.recordcount EQ 0){
			break;
		}

		for(row in qEvent){
			projectDays=row.event_config_project_recurrence_days;
			if(not isnumeric(projectDays)){
				projectDays=0;
			}


			db.sql="select * from #db.table("event_recur", request.zos.zcoreDatasource)#
			WHERE 
			site_id = #db.param(row.site_id)# and 
			event_recur_deleted=#db.param(0)# and 
			event_id=#db.param(row.event_id)#";
			qEventRecur=db.execute("qEventRecur");
			recurStruct={};
			for(row2 in qEventRecur){
				recurStruct[dateformat(row2.event_recur_start_datetime, "yyyy-mm-dd")&" "&timeformat(row2.event_recur_start_datetime, "HH:mm:ss")&" to "&dateformat(row2.event_recur_end_datetime, "yyyy-mm-dd")&" "&timeformat(row2.event_recur_end_datetime, "HH:mm:ss")]=row2.event_recur_id;
			}

			if(row.event_recur_ical_rules EQ ""){

				mysqlStartDate=dateformat(row.event_start_datetime, "yyyy-mm-dd")&" "&timeformat(row.event_start_datetime, "HH:mm:ss")&" to "&dateformat(row.event_end_datetime, "yyyy-mm-dd")&" "&timeformat(row.event_end_datetime, "HH:mm:ss");

				if(form.forceAll EQ 1 or not structkeyexists(recurStruct, mysqlStartDate)){
					startDate=dateformat(row.event_start_datetime, "yyyy-mm-dd")&" "&timeformat(row.event_start_datetime, "HH:mm:ss");
					ts={
						table:"event_recur",
						datasource:request.zos.zcoreDatasource,
						struct:{
							event_id:row.event_id,
							site_id:row.site_id,
							event_recur_datetime:startDate,
							event_recur_start_datetime:startDate,
							event_recur_end_datetime:dateformat(row.event_end_datetime, "yyyy-mm-dd")&" "&timeformat(row.event_end_datetime, "HH:mm:ss"),
							event_recur_updated_datetime:dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'),
							event_recur_deleted:0
						}
					};
					form.event_recur_id=application.zcore.functions.zInsert(ts);
					db.sql="delete from #db.table("event_recur", request.zos.zcoreDatasource)# WHERE 
					event_recur_deleted=#db.param(0)# and 
					site_id=#db.param(row.site_id)# and 
					event_id=#db.param(row.event_id)# and 
					event_recur_id <> #db.param(form.event_recur_id)# ";
					qDelete=db.execute("qDelete");
				}else{
					form.event_recur_id=recurStruct[mysqlStartDate];
					db.sql="delete from #db.table("event_recur", request.zos.zcoreDatasource)# WHERE 
					event_recur_deleted=#db.param(0)# and 
					site_id=#db.param(row.site_id)# and 
					event_id=#db.param(row.event_id)# and 
					event_recur_id <> #db.param(form.event_recur_id)# ";
					qDelete=db.execute("qDelete");
				}
			}else{
				daysAfterStartDate=datediff("d", row.event_start_datetime, now());
				tempProjectDays=projectDays;
				if(daysAfterStartDate GT 0){
					tempProjectDays+=daysAfterStartDate;
				}

				arrDate=request.ical.getRecurringDates(row.event_start_datetime, row.event_recur_ical_rules, row.event_excluded_date_list, tempProjectDays); 
				//echo('supposed to be :<br>8/9<br>8/23<br>9/6<br>9/20');
				//writedump(arrDate);abort;
				minutes=datediff("n", row.event_start_datetime, row.event_end_datetime); 
				for(i=1;i LTE arraylen(arrDate);i++){
					startDate=arrDate[i];
					endDate=dateadd("n", minutes, startDate);
					mysqlStartDate=dateformat(startDate, "yyyy-mm-dd")&" "&timeformat(startDate, "HH:mm:ss")&" to "&dateformat(endDate, "yyyy-mm-dd")&" "&timeformat(endDate, "HH:mm:ss");

					if(form.forceAll EQ 0 and structkeyexists(recurStruct, mysqlStartDate)){
						structdelete(recurStruct, mysqlStartDate);
						// echo('skip '&mysqlStartDate&'<br>');
					}else{
						startDate=dateformat(startDate, "yyyy-mm-dd")&" "&timeformat(startDate, "HH:mm:ss");
						ts={
							table:"event_recur",
							datasource:request.zos.zcoreDatasource,
							struct:{
								event_id:row.event_id,
								site_id:row.site_id,
								event_recur_datetime:startDate,
								event_recur_start_datetime:startDate,
								event_recur_end_datetime:dateformat(endDate, "yyyy-mm-dd")&" "&timeformat(endDate, "HH:mm:ss"),
								event_recur_updated_datetime:dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'),
								event_recur_deleted:0
							}
						}
						application.zcore.functions.zInsert(ts);
					}
				}
				arrDelete=[];
				for(i in recurStruct){
					arrayAppend(arrDelete, recurStruct[i]);
				}
				if(arraylen(arrDelete)){
					db.sql="delete from #db.table("event_recur", request.zos.zcoreDatasource)# WHERE 
					event_recur_deleted=#db.param(0)# and 
					site_id=#db.param(row.site_id)# and 
					event_id=#db.param(row.event_id)# and 
					event_recur_id IN (#db.trustedSQL(arrayToList(arrDelete,  ", "))#) ";
					qDelete=db.execute("qDelete");
				}
			}
		}
		offset+=30;
	} 
	if(form.forceAll EQ 1){
		echo('<h2>All event projections were forcefully recalculated.</h2>');
	}else{
		echo('<h2>All event projections updated.</h2>');
	}
	echo('  <a href="/z/event/tasks/project-events/index?forceAll=1">Force all events to be recalculated.</a><br />Need to process non-recurring events after an import? <a href="/z/event/tasks/project-events/index?processNonRecurring=1">click here</a>');
	abort;
	</cfscript>
</cffunction>	
</cfoutput>
</cfcomponent>
