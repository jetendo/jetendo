<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="private">  
	<cfscript> 
	setting requestTimeout="100000";
	variables.userAgent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36";
 
	</cfscript>
	
</cffunction>
<cffunction name="index" localmode="modern" access="remote" roles="administrator">  
	<cfscript> 
	db=request.zos.queryObject;
 
	interspireStatus=application.zcore.functions.zso(application, 'interspireImportStatus');
	if(interspireStatus EQ ""){
		interspireStatus="Inactive";
	} 
	interspireMonthStatus=application.zcore.functions.zso(application, 'interspireMonthStatus');
	if(interspireMonthStatus EQ ""){
		interspireMonthStatus="Inactive";
	} 
	</cfscript>
	<h2>Import Newsletter Stats</h2>

	<p><a href="/z/inquiries/admin/import-newsletter-stats/interspire" target="_blank">Test Interspire Import</a> (Status: #interspireStatus#)</p>
	<p><a href="/z/inquiries/admin/import-newsletter-stats/interspireMonth" target="_blank">Test Interspire Month Import</a> (Status: #interspireMonthStatus#)</p> 
	<p><a href="/z/inquiries/admin/import-newsletter-stats/checkLateNewsletters?manual=1" target="_blank">Check for late newsletters</a></p>
	<p><a href="/z/inquiries/admin/import-newsletter-stats/newsletterImportTask" target="_blank">Run All Tasks</a></p>

</cffunction> 

<cffunction name="newsletterImportTask" localmode="modern" access="remote">  
	<cfscript> 
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer or server can access this.");
	}

	interspireMonth();
	echo('<br>');
	interspire();
	echo('<br>');
	checkLateNewsletters();
	echo('<br>');

	echo('All newsletter import and alert tasks were completed');
	abort;
	</cfscript>
</cffunction>

<cffunction name="checkLateNewsletters" localmode="modern" access="remote" roles="administrator">  
	<cfscript> 
	db=request.zos.queryObject;

	form.manual=application.zcore.functions.zso(form, 'manual', true, 0);
 
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_monthly_email_campaign_count<>#db.param('0')#";
	/*
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}*/
	qSite=db.execute("qSite"); 

	form.selectedMonth=application.zcore.functions.zso(form, 'selectedMonth', false, now());
	form.selectedMonth=dateformat(form.selectedMonth, "yyyy-mm")&"-01";

	arrLog=[];
	startMonthDate=dateformat(form.selectedMonth, "yyyy-mm-")&"01";
	daysSinceFirst=dateadd("d", startMonthDate, form.selectedMonth);
	endDate=dateformat(dateadd("m", 1, startMonthDate), "yyyy-mm-dd");
	siteCountStruct={};
	for(row in qSite){
 
		db.sql="SELECT * FROM 
		#db.table("newsletter_email", request.zos.zcoreDatasource)#  
		WHERE newsletter_email_sent_datetime>=#db.param(startMonthDate&" 00:00:00")# and 
		newsletter_email_sent_datetime<#db.param(endDate&" 00:00:00")# and 
		site_id=#db.param(row.site_id)# and 
		newsletter_email_deleted=#db.param(0)# ";
		qEmail=db.execute("qEmail"); 

		siteCountStruct[row.site_id]=qEmail.recordcount; 

		if(row.site_monthly_email_campaign_alert_day_delay NEQ 0 and row.site_monthly_email_campaign_alert_day_delay GT daysSinceFirst){
			// skip this site because the alert delay hasn't been passed yet.
			continue;
		}
		if(qEmail.recordcount LT row.site_monthly_email_campaign_count){
			arrayAppend(arrLog, row.site_domain&" has only had #qEmail.recordcount# of #row.site_monthly_email_campaign_count# newsletters sent this month.");
		}
	}


	if(form.manual EQ 0){
		if(arrayLen(arrLog)){
			// send email alert  
			ts=StructNew();  
			ts.from=request.zos.developerEmailFrom;
			ts.to=request.zos.newsletterLateEmailList;
			ts.subject="Late Marketing Newsletter Alert";
			ts.html="<!DOCTYPE html><html><head><title></title><body><h2>Late Marketing Newsletter Alert</h2>
			<p>This email is only sent when the system has detected not enough newsletters have been sent according to the scheduled deliverables for a marketing client in the current month.  This alert resets automatically each month.   You should not filter or ignore this email.  This alert will be sent once per day until all late newsletters are completed.</p>
			<p>"&arrayToList(arrLog, "<br><br>")&"</p>
			<hr>
			<p>This report is not guaranteed to be accurate.  People may have sent extra newsletters or tests, which will result in accurate status.  You can view the detailed status at the link below for more information.</p>
			<h3><a href=""#request.zos.marketingPortalDomain#/z/inquiries/admin/import-newsletter-stats/checkLateNewsletters?manual=1"">View Current Newsletter Status</a></h3>
			</body></html>"; 
			rCom=application.zcore.email.send(ts); 
			if(rCom.isOK() EQ false){
				// user has opt out probably...
				if(form.debug){
					rCom.setStatusErrors(request.zsid);
					application.zcore.functions.zstatushandler(request.zsid); 
				}
			} 
		}
		return "";
	} 
	echo('<h2>Newsletter Marketing Status</h2>');
	echo('
		<form action="" method="get">
		<input type="hidden" name="manual" value="1">
		<input type="month" name="selectedMonth" value="#dateformat(form.selectedMonth, "yyyy-mm")#">
		<input type="submit" name="update" value="Update">
		</form>');

	echo('<table class="table-list">
		<tr><th>Domain</th>
		<th>Sent Newsletters</th>
		<th>Newsletters Due</th>
		<th>Status</th>
		<th>View Report</th>
		</tr>');
	for(row in qSite){ 
		echo('<tr>
			<td>#row.site_domain#</td>
			<td>#siteCountStruct[row.site_id]#</td>
			<td>#row.site_monthly_email_campaign_count#</td>
			<td>');
		if(siteCountStruct[row.site_id] LT row.site_monthly_email_campaign_count){
			echo('<span style="color:##900;">MIGHT BE LATE</span>');
		}else{
		echo('<span style="color:##090;">OK</span>');
		}
		echo('</td>
		<td><a href="#row.site_domain#/z/inquiries/admin/custom-lead-report/index?selectedMonth=#form.selectedMonth###newsletterStats" target="_blank">View Detailed Report</a></td>
		</tr>');
	}
	echo('</table>'); 
	</cfscript>
</cffunction> 


<cffunction name="interspireMonth" access="remote" localmode="modern">
	<cfscript>
	init();
	db=request.zos.queryobject;
 
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_interspire_email_owner_id_list<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	qSite=db.execute("qSite");   

	siteLookup={};
	arrOwner=[];
	for(row in qSite){
		arrTemp=listToArray(row.site_interspire_email_owner_id_list, ","); 
		for(ownerid in arrTemp){
			siteLookup[ownerid]=row.site_id;
			arrayAppend(arrOwner, ownerid);
		}
	}  
	ownerid=arrayToList(arrOwner, ","); 

	// get data for all time every time
	startDate=dateformat(request.zos.interspireStartDate, "yyyy-mm")&"-01";

	endDate=now(); 
	startDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), startDate);
	endDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), endDate);

	link="#request.zos.interspireExportLink#?totals=1&startDate=#startDateRemote#&endDate=#endDateRemote#&secret=#request.zos.interspireSecretKey#&ownerid="&urlencodedformat(ownerid); 

/*
fields returned
ownerid	month	new_subscribers	total_subscribers	bounces	unsubscribes
*/
	try{
		rs=application.zcore.functions.zDownloadLink(link, 1000, true);
	}catch(Any e){
		// try up to 10 times before throwing, due to odd connection timeout problem.
		for(i=1;i<=10;i++){
			sleep(1000);
			echo('try #link# again<br>');
			retry;
		}
		if(not rs.success){
			savecontent variable="out"{
				echo('<h2><a href="#link#" target="_blank">#link#</a> export failed.</h2>');
				writedump(rs);
			}
			throw(out);
		} 

	}
	if(trim(rs.cfhttp.filecontent) EQ ""){
		// nothing returned, ignore import
		return;
	}

	arrLine=listToArray(rs.cfhttp.filecontent, chr(10));
	arrColumn=listToArray(arrLine[1], chr(9), true);
	arrayDeleteAt(arrLine, 1);


	for(line in arrLine){
		arrRow=listToArray(line, chr(9), true);
		ts={};
		for(i=1;i<=arraylen(arrColumn);i++){
			ts[arrColumn[i]]=arrRow[i];
		} 
		if(not structkeyexists(ts, "ownerid")){
			echo("Invalid row: "&line&"<br>");
			continue;
		}

		site_id=siteLookup[ts.ownerid];
		
		application.interspireMonth="Processing "&site_id&" | "&ts.month; 

		db.sql="select * from #db.table("newsletter_month", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(site_id)# and 
		newsletter_month_deleted=#db.param(0)# and 
		newsletter_month_datetime=#db.param(ts.month&"-01")#";
		qCheck=db.execute("qCheck");

		t9={
			table:"newsletter_month",
			datasource:request.zos.zcoreDatasource,
			struct:{ 
				newsletter_month_datetime:ts.month&"-01", 
				newsletter_month_new_subscribers:ts.new_subscribers,
				newsletter_month_total_subscribers:ts.total_subscribers,
				newsletter_month_bounces:ts.bounces,
				newsletter_month_unsubscribed:ts.unsubscribes,
				site_id:site_id,
				newsletter_month_updated_datetime:request.zos.mysqlnow,
				newsletter_month_deleted:0
			}
		} 
		//writedump(t9);abort;
		if(qCheck.recordcount){
			t9.struct.newsletter_month_id=qCheck.newsletter_month_id;
			result=application.zcore.functions.zUpdate(t9);
		}else{
			newsletter_month_id=application.zcore.functions.zInsert(t9);
		} 
	}  
	echo('done'); 
	structdelete(application, 'interspireMonthImportStatus');

	</cfscript>
	
    
</cffunction>

<cffunction name="interspire" access="remote" localmode="modern">
	<cfscript>
	init();
	db=request.zos.queryobject;
 
	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# 
	WHERE site_active=#db.param(1)# and 
	site_deleted=#db.param(0)# and 
	site_id<>#db.param(-1)# and 
	site_interspire_email_owner_id_list<>#db.param('')#";
	if(application.zcore.functions.zso(form, 'sid', true) NEQ 0){
		db.sql&=" and site_id = #db.param(form.sid)# ";
	}
	qSite=db.execute("qSite");   
	for(row in qSite){

		application.interspireImportStatus="Processing "&row.site_domain; 
		if(row.site_interspire_email_last_import_datetime EQ ""){
			// download all time
			row.site_interspire_email_last_import_datetime=request.zos.interspireStartDate;
		}else{
			// download only the last 2 months
		} 

		arrTemp=listToArray(row.site_interspire_email_owner_id_list, ",");
		arrOwner=[];
		for(ownerid in arrTemp){
			arrayAppend(arrOwner, ownerid);
		}


		ownerid=arrayToList(arrOwner, ",");

		startDate=dateadd("m", -2, dateformat(row.site_interspire_email_last_import_datetime, "yyyy-mm")&"-01");
		endDate=now(); 
		startDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), startDate);
		endDateRemote=datediff("s", createDateTime(1970, 1, 1, 0, 0, 0), endDate);

		link="#request.zos.interspireExportLink#?startDate=#startDateRemote#&endDate=#endDateRemote#&secret=#request.zos.interspireSecretKey#&ownerid="&urlencodedformat(ownerid); 

/*
fields returned
statid,queueid,starttime,finishtime,htmlrecipients,textrecipients,multipartrecipients,trackopens,tracklinks,bouncecount_soft,bouncecount_hard,bouncecount_unknown,unsubscribecount,newsletterid,sendfromname,sendfromemail,bounceemail,replytoemail,charset,sendinformation,sendsize,sentby,notifyowner,linkclicks,emailopens,emailforwards,emailopens_unique,hiddenby,textopens,textopens_unique,htmlopens,htmlopens_unique,jobid,sendtestmode,sendtype,newslettername,newslettersubject,username,fullname,emailaddress
*/
		try{
			rs=application.zcore.functions.zDownloadLink(link, 1000, true); 
		}catch(Any e){
			// try up to 10 times before throwing, due to odd connection timeout problem.
			for(i=1;i<=10;i++){
				sleep(1000);
				echo('try #link# again<br>');
				retry;
			}
			if(not rs.success){
				savecontent variable="out"{
					echo('<h2><a href="#link#" target="_blank">#link#</a> export failed.</h2>');
					writedump(rs);
					writedump(e);
				}
				throw(out);
			} 

		}  
		if(trim(rs.cfhttp.filecontent) EQ ""){
			// nothing returned
			continue;
		} 
 
		arrLine=listToArray(rs.cfhttp.filecontent, chr(10));
		arrColumn=listToArray(arrLine[1], chr(9), true);
		arrayDeleteAt(arrLine, 1);

		for(line in arrLine){
			arrRow=listToArray(line, chr(9), true);
			ts={};
			for(i=1;i<=arraylen(arrColumn);i++){
				ts[arrColumn[i]]=arrRow[i];
			}
			//writedump(ts); 

			db.sql="select * from #db.table("newsletter_email", request.zos.zcoreDatasource)# 
			WHERE site_id = #db.param(row.site_id)# and 
			newsletter_email_deleted=#db.param(0)# and 
			newsletter_email_external_id=#db.param(ts.statid)#";
			qCheck=db.execute("qCheck");

			t9={
				table:"newsletter_email",
				datasource:request.zos.zcoreDatasource,
				struct:{
					newsletter_email_name:ts.newslettername,
					newsletter_email_external_id:ts.statid,
					newsletter_email_external_newsletter_id:ts.newsletterid,
					newsletter_email_sent_datetime:dateadd("s", ts.starttime, createDateTime(1970, 1, 1, 0, 0, 0)),
					newsletter_email_sent_count:ts.htmlrecipients+ts.textrecipients+ts.multipartrecipients,
					newsletter_email_opens:ts.emailopens_unique,
					newsletter_email_clicks:ts.linkclicks,
					newsletter_email_bounces:ts.bouncecount_soft+ts.bouncecount_hard,
					newsletter_email_unsubscribes:ts.unsubscribecount,
					site_id:row.site_id,
					newsletter_email_updated_datetime:request.zos.mysqlnow,
					newsletter_email_deleted:0
				}
			}
			t9.struct.newsletter_email_sent_datetime=dateformat(t9.struct.newsletter_email_sent_datetime, "yyyy-mm-dd")&" "&timeformat(t9.struct.newsletter_email_sent_datetime, "HH:mm:ss"); 
			if(qCheck.recordcount){
				t9.struct.newsletter_email_id=qCheck.newsletter_email_id;
				result=application.zcore.functions.zUpdate(t9);
			}else{
				newsletter_email_id=application.zcore.functions.zInsert(t9);
			}

			/* 
			echo('<p>#numberformat(row.newsletter_month_total_subscribers, "_")# Total Subscribers</p>');
			echo('<p>#numberformat(row.newsletter_month_new_subscribers, "_")# New Subscribers</p>');
			echo('<p>#numberformat(row.newsletter_month_unsubscribed, "_")# Unsubscribed</p>');
			echo('<hr>');
			*/ 
		}
		db.sql="update #db.table("site", request.zos.zcoreDatasource)# SET 
		site_interspire_email_last_import_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))#,
		site_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE site_id = #db.param(row.site_id)# and 
		site_deleted=#db.param(0)#";
		qUpdate=db.execute("qUpdate");

	}  
	echo('done'); 
	structdelete(application, 'interspireImportStatus'); 
	</cfscript>
	
    
</cffunction>
 
	 
</cfoutput>
</cfcomponent>