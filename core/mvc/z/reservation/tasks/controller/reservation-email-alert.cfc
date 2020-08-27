<cfcomponent>
<cfoutput>

<cffunction name="index" localmode="modern" access="remote">
	<!--- reservation_config_id
	reservation_config_confirmation_email_list
	reservation_config_change_email_list
	reservation_config_payment_failure_email_list
	reservation_config_destination_on_email
 --->

</cffunction>



<cffunction name="sendReminderEmail" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.functions.checkIfCronJobAllowed();
	application.zcore.functions.zNoCache();
	form.reservation_id=application.zcore.functions.zso(form, 'reservation_id');
	db.sql="select * from #db.table("reservation", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	reservation_id = #db.param(form.reservation_id)# and 
	reservation_status = #db.param(1)# and 
	reservation_deleted=#db.param(0)#	";
	qReservation=db.execute("qReservation");
	if(qReservation.recordcount EQ 0){
		application.zcore.functions.z404("Invalid reservation");
	}
	application.zcore.app.getAppCFC("reservation").sendReservationEmail(form.reservation_id, 'reminder');
	echo("Reminder sent");
	abort;
	</cfscript>
</cffunction>
	

<cffunction name="findReservationNeedingReminder" localmode="modern" access="remote">
	<cfscript>
	setting requesttimeout="3000";
	db=request.zos.queryObject;
	application.zcore.functions.zNoCache();
	db.sql="select * from #db.table("reservation_config", request.zos.zcoreDatasource)# WHERE 
	site_id <> #db.param(-1)# and 
	reservation_config_deleted=#db.param(0)#
	";
	qConfig=db.execute("qConfig");
	for(row in qConfig){
		arrReminder=listToArray(row.reservation_config_reminder_days_list, ",");
		arraySort(arrReminder, "numeric", "asc");
		for(i=1;i LTE arraylen(arrReminder);i++){
			xDays=arrReminder[i];
			futureDate=dateadd("d", xDays, now());
			db.sql="select reservation_id, site_id from #db.table("reservation", request.zos.zcoreDatasource)# 
			WHERE 
			reservation.site_id = #db.param(row.site_id)# and 
			reservation.reservation_status = #db.param(1)# and 
			reservation.reservation_deleted=#db.param(0)# and 
			(reservation_reminder_email_sent_x_days=#db.param(0)# or 
			reservation_reminder_email_sent_x_days > #db.param(xDays)#) and 
			reservation_start_datetime < #db.param(dateformat(futureDate, "yyyy-mm-dd")&" "&timeformat(futureDate, "HH:mm:ss"))# ";
			qReservation=db.execute("qReservation");
			if(qReservation.recordcount){
				writedump(qReservation); 
			}
			for(reserve in qReservation){
				link=application.zcore.functions.zvar('domain', reserve.site_id)&"/z/reservation/tasks/reservation-email-alert/sendReminderEmail?reservation_id=#reserve.reservation_id#";
				if(structkeyexists(form, 'forceDebug')){
					link&="&forceDebug=1";
				}
				if(structkeyexists(form, 'forceEmail')){
					link&="&forceEmail=1";
				}
				r1=application.zcore.functions.zDownloadLink(link);
				if(r1.success){

					db.sql="update #db.table("reservation", request.zos.zcoreDatasource)# set 
					reservation_reminder_email_sent_x_days =#db.param(xDays)#, 
					reservation_updated_datetime=#db.param(request.zos.mysqlnow)#
					WHERE 
					reservation.site_id = #db.param(reserve.site_id)# and 
					reservation.reservation_id = #db.param(reserve.reservation_id)# and 
					reservation.reservation_deleted=#db.param(0)#";
					db.execute("qUpdate");
				}
				if(request.zos.isTestServer){
					echo("Downloaded: "&link&"<br />");
					if(r1.success EQ false){
						writedump(r1);
						application.zcore.functions.zabort();
					}else{
						writeoutput(r1.cfhttp.FileContent&'<br /><br />');
						application.zcore.functions.zabort();
					}
				}
			}
		}
	}
	echo("Done");
	</cfscript>
</cffunction>
	

</cfoutput>
</cfcomponent>
