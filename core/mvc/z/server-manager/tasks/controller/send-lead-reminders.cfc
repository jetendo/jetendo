<cfcomponent>
<cfoutput>
<!--- must call on specific site: /z/server-manager/tasks/send-lead-reminders/send --->
<cffunction name="send" localmode="modern" access="remote">
	<cfscript> 
	setting requesttimeout="10000";
	/*if(not request.zos.isTestServer){
		throw("disabled on production for now");
	}*/
	debug=false;
	if(request.zos.isTestServer){
		debug=true;
	}
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}  
	db=request.zos.queryObject;

	leadReminderStartDate=application.zcore.functions.zso(request.zos.globals, 'leadReminderStartDate');
	if(leadReminderStartDate EQ "" or leadReminderStartDate EQ "0000-00-00"){
		echo('Invalid leadReminderStartDate: #leadReminderStartDate#');
		abort;
	}
	leadReminderStartDate=dateformat(leadReminderStartDate, "yyyy-mm-dd");
	if(datecompare(now(), leadReminderStartDate) EQ -1){
		echo('leadReminderStartDate is in the future, no reminders should be sent yet.');
		abort;
	} 
	delay1=application.zcore.functions.zvar('leadReminderEmail1DelayMinutes');
	delay2=application.zcore.functions.zvar('leadReminderEmail2DelayMinutes');
	delay3=application.zcore.functions.zvar('leadReminderEmail3DelayMinutes');

	reminderLimit=0;
	if(delay1 NEQ 0){
		reminderLimit++;
	}
	if(delay2 NEQ 0){
		reminderLimit++;
	}
	if(delay3 NEQ 0){
		reminderLimit++;
	}
	if(reminderLimit EQ 0){
		echo('At least one lead reminder email delay minutes be set.  reminders disabled for this site.');
		abort;
	}

	emailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.email");
	previousDate=dateadd("d",-2,now());
	previousDateFormatted=dateformat(previousDate,'yyyy-mm-dd')&' '&timeformat(previousDate,'HH:mm:ss');
	db.sql="SELECT * 
	FROM #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# WHERE  
    inquiries_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_datetime >=#db.param(leadReminderStartDate)# and 
	inquiries_reminder_count <#db.param(reminderLimit)# and 
	inquiries_status_id IN (#db.param(1)#, #db.param(2)#) and 
	user_id <> #db.param(0)# "; 
	if(request.zos.isTestServer){
		db.sql&=" LIMIT #db.param(0)#, #db.param(1)# ";
	}
	qI=db.execute("qI");   
	if(debug){
		//writedump(qI);
	}
	if(application.zcore.functions.zvar("enableLeadUserReminder") EQ 1){
		userReminderEnabled=true;

	}else{
		userReminderEnabled=true;
	}
	if(application.zcore.functions.zvar("enableLeadAdminReminder") EQ 1){
		adminReminderEnabled=true;
	}else{
		adminReminderEnabled=true;
	}
	if(not userReminderEnabled and not adminReminderEnabled){
		return;
	}

	if(application.zcore.functions.zvar("enableLeadReminderDisableCC") EQ 1){
		disableCC=true;
	}else{
		disableCC=false;
	}
	officeCC=false;
	if(application.zcore.functions.zso(request.zos.globals, 'enableLeadReminderOfficeManagerCC', true, 0) EQ 1){
		officeCC=true;
 
		db.sql="select * from  
		#db.table("office", request.zos.zcoreDatasource)# WHERE  
		site_id = #db.param(request.zos.globals.id)# and 
		office_deleted=#db.param(0)# ";
		qOffice=db.execute("qOffice");
		officeLookup={};
		for(row in qOffice){
			officeLookup[row.office_id]=row;
		} 
	}
	if(debug){
		echo('userReminderEnabled:'&userReminderEnabled&'<br>');
		echo('adminReminderEnabled:'&adminReminderEnabled&'<br>');
		echo('disableCC:'&disableCC&'<br>');
		echo('officeCC:'&officeCC&'<br>');
	} 

	excludeParentSite=false;
	qMember=application.zcore.user.getUsersWithGroupAccess("member", excludeParentSite); 
	memberStruct={};
	for(row in qMember){
		memberStruct[row.user_id&"|"&application.zcore.functions.zGetSiteIdType(row.site_id)]=row;
	}
	qUser=application.zcore.user.getUsersWithGroupAccess("user", excludeParentSite); 
	userStruct={};
	for(row in qUser){
		userStruct[row.user_id&"|"&application.zcore.functions.zGetSiteIdType(row.site_id)]=row;
	}
	qAdminUser=application.zcore.user.getUsersWithGroupAccess("administrator", excludeParentSite);
	adminStruct={};
	for(row in qAdminUser){
		adminStruct[row.user_id&"|"&application.zcore.functions.zGetSiteIdType(row.site_id)]=row;
	}
	
	enableLeadReminderDisableCC=application.zcore.functions.zso(request.zos.globals, 'enableLeadReminderDisableCC', true, 0);
	</cfscript>
    <cfloop query="qI">
        <cfscript>		
		ts={};
		ts.to="";
		ts.from=request.fromemail;
		ts.cc="";
		uid=qI.user_id&"|"&qI.user_id_siteIdType; 

		
 
		if(structkeyexists(adminStruct, uid)){
			if(not adminReminderEnabled){
				continue;
			}
		}
		if(structkeyexists(userStruct, uid)){
			if(not userReminderEnabled){
				continue;
			}
			user=userStruct[uid];
			ts.to=user.user_email;
			if(enableLeadReminderDisableCC EQ 0 and user.user_alternate_email NEQ ""){
				ts.cc=user.user_alternate_email;
			}
		}
		if(structkeyexists(memberStruct, uid)){  
			// includes admins too
			user=userStruct[uid];
			ts.to=user.user_email;
			if(enableLeadReminderDisableCC EQ 0 and user.user_alternate_email NEQ ""){
				ts.cc=user.user_alternate_email;
			}
		} 
		if(officeCC and qI.office_id NEQ 0){  
			if(structkeyexists(officeLookup, qI.office_id)){
				office=officeLookup[qI.office_id];
				if(debug){
					echo('found office<br>');
				}
				if(office.office_manager_email_list NEQ ""){ 
					if(debug){
						echo('office has manager email list<br>');
					}
					// add to CC 
					if(ts.cc EQ ""){
						ts.cc=office.office_manager_email_list;
					}else{
						ts.cc&=","&office.office_manager_email_list;
					}
				} 
			}
		} 
		if(debug){
			echo('inquiries_id:'&qI.inquiries_id&"<br>");
		}
		if(qI.inquiries_assign_email NEQ ""){
			ts.to=qI.inquiries_assign_email;
		}
		if(ts.to EQ ""){
			ts.to=application.zcore.functions.zvarso("zofficeemail");
		}
		if(ts.to EQ ""){
			ts.to=request.zos.developerEmailTo;
		}
		if(debug or request.zos.isTestServer){
			ts.to=request.zos.developerEmailTo;
			ts.cc="";
			ts.bcc="";
		}
		sendEmail=false;
		if(qI.inquiries_reminder_sent_datetime EQ "" or qI.inquiries_reminder_sent_datetime EQ "0000-00-00"){
			sendEmail=true;
			if(debug){
				echo('blank, always send<br />');
			}
		}else{
			lastSentDateTime=parsedatetime(dateformat(qI.inquiries_reminder_sent_datetime, "yyyy-mm-dd")&" "&timeformat(qI.inquiries_reminder_sent_datetime, "HH:mm:ss"));
			minutesSinceLastReminder=datediff("n", lastSentDateTime, now());
			if(debug){
				echo('minutesSinceLastReminder:'&minutesSinceLastReminder&'<br>'); 
			}
			if(qI.inquiries_reminder_count EQ 0){
				if(reminderLimit GTE 1){
					if(minutesSinceLastReminder GTE delay1){
						sendEmail=true;
						if(debug){
							echo('delay1 reached: sending<br>');
						}
					}
				}
			}else if(qI.inquiries_reminder_count EQ 1){
				if(reminderLimit GTE 2){
					if(minutesSinceLastReminder GTE delay2){
						sendEmail=true;
						if(debug){
							echo('delay2 reached: sending<br>');
						}
					}
				}
			}else if(qI.inquiries_reminder_count EQ 2){
				if(reminderLimit GTE 3){
					if(minutesSinceLastReminder GTE delay3){
						sendEmail=true;
						if(debug){
							echo('delay3 reached: sending<br>');
						}
					}
				}
			}
		}
		if(not sendEmail){
			if(debug){
				echo("not sending<br>");
			}
			continue;
		}
		if(structkeyexists(memberStruct, uid)){ 
			leadLink=request.zos.globals.domain&"/z/inquiries/admin/feedback/view?inquiries_id="&qI.inquiries_id;
			domain=request.zos.globals.domain;
			shortDomain=replace(replace(request.zos.globals.domain, "http://", ""), "https://", "");
		}else{
			domain=request.zos.globals.domain;
			if(application.zcore.functions.zso(request.zos.globals, 'publicUserManagerDomain') NEQ ""){
				domain=request.zos.globals.publicUserManagerDomain;
			}
			shortDomain=replace(replace(domain, "http://", ""), "https://", "");
			leadLink=domain&"/z/inquiries/admin/manage-inquiries/userView?inquiries_id="&qI.inquiries_id; 
		} 
		ts.subject="Lead status not updated on #shortDomain# for inquiry ###qI.inquiries_id#";
		ts.html='<!DOCTYPE html>
		<html>
		<head><title>Alert</title></head>
		<body>
		<h3>Lead Status Not Updated for inquiry ###qI.inquiries_id#</h3>

		<p>The following lead has not had a status update since it was assigned to you.  We require you to login and update the lead status describing what action you''ve taken to contact the lead and what happened.</p>

		<h4>Lead Summary</h4>
		<p>Name: #qI.inquiries_first_name# #qI.inquiries_last_name#</p>
		<p>Email: <a href="mailto:#qI.inquiries_email#">#qI.inquiries_email#</a></p>
		<p>Phone: #qI.inquiries_phone1#</p>

		<h3><a href="#leadLink#" target="_blank">Login and View/Update Lead</a></h3> 
		<p><a href="#domain#">#domain#</a></p>
		</body></html>';
  
		
		rCom=application.zcore.email.send(ts);
		if(rCom.isOK() EQ false){
			rCom.setStatusErrors(request.zsid);
			application.zcore.functions.zstatushandler(request.zsid);
			application.zcore.functions.zabort();
		}
		if(debug){
			writedump(ts);
			echo('sent email:'&rCom.isOK()&'<br>');
		}

		db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# SET 
		inquiries_reminder_sent_datetime = #db.param(request.zos.mysqlnow)#, 
		inquiries_updated_datetime = #db.param(request.zos.mysqlnow)#, 
		inquiries_reminder_count=#db.param(qI.inquiries_reminder_count+1)# 
		WHERE inquiries_id = #db.param(qI.inquiries_id)# and 
		site_id = #db.param(qI.site_id)# and 
		inquiries_deleted=#db.param(0)# ";
		db.execute("qUpdate");

		if(debug){
			echo('aborting after first inquiry was processed.');
			abort;
		}
        </cfscript> 
    </cfloop>
    <cfscript>
	echo('done');
	abort;
	</cfscript>
</cffunction>
 

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	var db=request.zos.queryObject;
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	} 
	setting requesttimeout="10000"; 
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_id <> #db.param(-1)# and 
	site_active = #db.param(1)# and 
	site_deleted = #db.param(0)# and 
	(site_enable_lead_user_reminder=#db.param(1)# or site_enable_lead_admin_reminder=#db.param(1)#)"; 
	qSite=db.execute("qSite"); 
	for(row in qSite){
		link=row.site_domain&"/z/server-manager/tasks/send-lead-reminders/send"; 
		rs=application.zcore.functions.zdownloadlink(link, 3000, true); 
		if(not rs.success){
			savecontent variable="out"{
				echo('Failed to complete http request: #link#');
				writedump(rs);
			}
			throw(out);
		}

		if(request.zos.isTestServer){
			echo('Only one domain executed on test server for debugging purposes.<br />');
			echo(rs.cfhttp.filecontent);
			abort;
		}
	}
	</cfscript>
	done<cfabort>
</cffunction>
</cfoutput>
</cfcomponent>