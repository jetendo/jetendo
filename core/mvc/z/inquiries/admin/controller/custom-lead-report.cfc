<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private"> 
	<cfscript>
	if(form.method NEQ "index"){
		if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
			application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
		}
	}
	</cfscript>
</cffunction>

<!--- 
/z/inquiries/admin/custom-lead-report/sendAllReportEmails
/z/inquiries/admin/custom-lead-report/sendReportEmail
 --->
<cffunction name="sendAllReportEmails" localmode="modern" access="remote"> 
	<cfscript>
	db=request.zos.queryObject;
	init();

	//echo('disabled until approved');	abort;
	// loop all sites (like marketing reports script);
	// call each domain directly
	db.sql="select *, replace(replace(site_short_domain, #db.param("."&request.zos.testDomain)#, #db.param('')#), #db.param('www.')#, #db.param('')#) shortDomain
	 from #db.table("site", request.zos.zcoreDatasource)#, 
	 #db.table("company", request.zos.zcoreDatasource)# 
	WHERE 
	site.company_id = company.company_id and 
	company_deleted=#db.param(0)# and 
	(site_google_analytics_view_id<>#db.param(0)# or site_seomoz_id_list<> #db.param('')#  or site_semrush_id_list<> #db.param('')# or site_calltrackingmetrics_account_id<> #db.param('')# or site_facebook_page_id_list<>#db.param('')# )
	and 
	site.site_id<>#db.param(-1)# and 
	site_active=#db.param(1)# and 
	site_report_auto_send_enable=#db.param(1)# and 
	site_deleted=#db.param(0)# 
	ORDER BY shortDomain ASC";
	qSite=db.execute("qSite");

	selectedMonth=dateformat(dateadd("m", -1, now()), "yyyy-mm");
	sent=0;
	for(row in qSite){
		if(row.site_report_sent_datetime NEQ "" and dateformat(row.site_report_sent_datetime, "yyyy-mm") GTE selectedMonth){
			// not ready to send data this month
			continue;
		}
		link=row.site_domain&"/z/inquiries/admin/custom-lead-report/sendReportEmail?selectedMonth=#selectedMonth#"; 
		r1=application.zcore.functions.zdownloadlink(link);
		if(r1.success){
			writeoutput(r1.cfhttp.FileContent);
			sent++;
		}else{
			savecontent variable="out"{
				writeoutput('<h2>Failed to send marketing report</h2>');
				echo('<p>'&link&'</p');
				writedump(r1.cfhttp);
			}
			throw(out);
		}

		// TODO: remove when this is ready to go live.
		break;
	}
	echo("#sent# of #qSite.recordcount# reports sent");
	abort;
	</cfscript>
</cffunction>

<cffunction name="sendReportEmail" localmode="modern" access="remote">  
	<cfscript>
	db=request.zos.queryObject;
	init();
	form.selectedMonth=application.zcore.functions.zso(form, 'selectedMonth'); 
	if(form.selectedMonth NEQ "" and isdate(form.selectedMonth)){ 
		form.selectedMonth=dateformat(form.selectedMonth, "yyyy-mm");  
	}else{
		form.selectedMonth=dateformat(dateadd("m", -1, now()), "yyyy-mm");
	}
	selectedMonth=form.selectedMonth;
	db.sql="select *, replace(replace(site_short_domain, #db.param("."&request.zos.testDomain)#, #db.param('')#), #db.param('www.')#, #db.param('')#) shortDomain
	 from #db.table("site", request.zos.zcoreDatasource)#, 
	 #db.table("company", request.zos.zcoreDatasource)# 
	WHERE 
	site.company_id = company.company_id and 
	company_deleted=#db.param(0)# and  
	site.site_id=#db.param(request.zos.globals.id)# and 
	site_active=#db.param(1)# and   
	site_report_auto_send_enable=#db.param(1)# and 
	site_deleted=#db.param(0)#";
	qSite=db.execute("qSite");
	if(qSite.recordcount EQ 0){
		throw("Site must be active, associated to a company and have Report Auto Send enabled.");
	}
	reportCompanyName=application.zcore.functions.zso(request.zos.globals, "reportCompanyName");
	if(reportCompanyName EQ ""){
		reportCompanyName=request.zos.globals.siteName;
	}

	fromEmail=request.zos.developerEmailFrom;
	if(qSite.company_report_from_email NEQ ""){
		fromEmail=qSite.company_report_from_email;
	}
	toEmail=qSite.site_report_auto_send_email_list;
	if(toEmail EQ ""){
		toEmail=qSite.company_report_email_list;
	}else{
		toEmail&=","&qSite.company_report_email_list;
	}
	ts={
		to:toEmail,
		from:fromEmail,
		subject:"#dateformat(form.selectedMonth, "mmmm yyyy")# Marketing Report for #reportCompanyName#",
		html:'<!DOCTYPE html><html><head><title></title></head><body>
		<h2>#dateformat(form.selectedMonth, "mmmm yyyy")# Marketing Report for #reportCompanyName#</h2>
		<p>Please review the attached PDF.</p>
		<p>Generated #dateformat(now(), "m/d/yyyy")&" at "&timeformat(now(), "h:mm tt")#</body></html>'
	};
	if(request.zos.isTestServer){
		ts.to=request.zos.developerEmailTo;
		ts.from=request.zos.developerEmailFrom;
	}
	form.returnJSON=1;
	form.print=1;
	form.yearToDateLeadLog=0;
	form.disableSection="";
	form.addPageCount=0;
	rs=index();
	if(not rs.success){
		throw("Failed to generate report");
	} 
	if(rs.filePath NEQ "" and fileexists(rs.filePath)){
		ts.attachments=[rs.filePath]; // absolute path to temporary file
	}
	mail  TO = "#ts.to#" FROM="#ts.from#"  SUBJECT= "#ts.subject#" type="html" mailerid="Web Mailer" charset="utf-8"{
 		mailpart  charset="utf-8" type="text/html"{
 			echo(ts.html);
 		}
		mailparam file="#rs.filePath#" disposition="attachment";
	}
	
	application.zcore.email.send(ts);
	// cfmail and postfix must have the file on disk to avoid "lost connection after DATA (0 bytes)" postix error in syslog.  We can't delete this pdf until the next month
	previousMonth=dateformat(dateAdd("m", -1, selectedMonth), "yyyy-mm"); 
	oldFilePath=replace(rs.filePath, selectedMonth, previousMonth);
	if(fileexists(oldFilePath)){
		application.zcore.functions.zDeleteFile(oldFilePath);
	}

	db.sql="UPDATE #db.table("site", request.zos.zcoreDatasource)# 
	SET 
	site_report_sent_datetime=#db.param(request.zos.mysqlnow)#, 
	site_updated_datetime=#db.param(request.zos.mysqlnow)#
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	site_deleted=#db.param(0)# ";

	echo('<h2>Report sent</h2>
	<p>subject: #ts.subject#</p>
	<p>from: #ts.from#</p>
	<p>to: #ts.to#</p>
	<p>html:</p>
	#ts.html#');
	abort;
	</cfscript>
</cffunction>

<cffunction name="showDate" localmode="modern" access="public">
	<cfargument name="d" type="string" required="yes">
	<cfscript>
	d=arguments.d;
	if(d EQ "" or not isdate(d)){
		echo('Never Imported');
	}else{
		echo(dateformat(d, "m/d/yyyy")&" "&timeformat(d, "h:mmtt"));
	}
	</cfscript>
</cffunction>

<cffunction name="isValidMonth" localmode="modern" access="public">
	<cfargument name="month" type="string" required="yes">
	<cfscript>
	reportStartDate=application.zcore.functions.zso(request.zos.globals, 'reportStartDate'); 
	if(reportStartDate NEQ ""){

		arguments.month=dateformat(arguments.month, "yyyy-mm-dd"); 
		if(datecompare(arguments.month, reportStartDate) GTE 0){
			return true;
		}else{
			return false;
		}
	}else{
		return true;
	}
	</cfscript>
</cffunction>


<cffunction name="isValidKeywordMonth" localmode="modern" access="public">
	<cfargument name="month" type="string" required="yes">
	<cfscript>
	keywordRankingStartDate=application.zcore.functions.zso(request.zos.globals, 'keywordRankingStartDate'); 
	if(keywordRankingStartDate NEQ ""){

		arguments.month=dateformat(arguments.month, "yyyy-mm-dd"); 
		if(datecompare(arguments.month, keywordRankingStartDate) GTE 0){
			return true;
		}else{
			return false;
		}
	}else{
		return true;
	}
	</cfscript>
</cffunction>

	
<cffunction name="filterInquiryTableSQL" localmode="modern" access="public">
	<cfargument name="db" type="component" required="yes">
	<cfscript>
	db=arguments.db;
	arrExcludeLeadTypeList=listToArray(application.zcore.functions.zso(request.zos.globals, 'excludeLeadTypeList'), ",");
	db.sql&=" and inquiries_spam <> #db.param(1)# "
	if(arrayLen(arrExcludeLeadTypeList)){
		db.sql&=" and ( ";
		for(i=1;i<=arraylen(arrExcludeLeadTypeList);i++){
			if(i NEQ 1){
				db.sql&=" and ";
			}
			db.sql&=" concat(inquiries_type_id, #db.param('|')#, inquiries_type_id_siteIDType) <> #db.param(arrExcludeLeadTypeList[i])# ";
		}
		db.sql&=" ) ";
	}
	reportStartDate=application.zcore.functions.zso(request.zos.globals, 'reportStartDate');
	if(reportStartDate NEQ ""){
		db.sql&=" and inquiries_datetime>=#db.param(dateformat(reportStartDate, "yyyy-mm-dd")&" 00:00:00")# ";
	}
	</cfscript>
</cffunction>
	
<cffunction name="filterOtherTableSQL" localmode="modern" access="public">
	<cfargument name="db" type="component" required="yes">
	<cfargument name="dateField" type="string" required="yes">
	<cfscript>
	db=arguments.db; 
	reportStartDate=application.zcore.functions.zso(request.zos.globals, 'reportStartDate');
	if(reportStartDate NEQ ""){
		db.sql&=" and `#arguments.dateField#`>=#db.param(dateformat(reportStartDate, "yyyy-mm-dd")&" 00:00:00")# ";
	}
	</cfscript>
</cffunction>

<cffunction name="generateReport" localmode="modern" access="remote">  
	<cfscript>  
	if(not request.zos.isServer and not request.zos.isDeveloper){
		application.zcore.functions.z404("Only server or developer can visit this page.");
	}
	index();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">  
	<cfscript>  
	setting requesttimeout="200";
	init();
	form.returnJSON=application.zcore.functions.zso(form, "returnJSON", true, 0);
	form.facebookQuarters=application.zcore.functions.zso(form, 'facebookQuarters', true, 1);
	savecontent variable="htmlOut"{
		initReportData();
		reportHeader();
		tableOfContents();
		websiteLeads();
		leadComparison();
		request.leadData.keywordData={};
		getKeywordData(); 

		// if client only has moz, then it can't show report.
		// how to fix?

		labelLookup={};
		arrId=listToArray(application.zcore.functions.zso(request.zos.globals, 'semrushIdList'), ",");
		arrLabel=listToArray(application.zcore.functions.zso(request.zos.globals, 'semrushLabelList'), ","); 

		for(i=arrayLen(arrLabel)+1;i LTE arrayLen(arrId);i++){
			arrayAppend(arrLabel, "Google Rankings");
		} 
		if(arrayLen(arrId) EQ 0){
			arrayAppend(arrId, "Google Rankings");
			arrayAppend(arrLabel, "Google Rankings");
		}
		labelLookup={};
		uniqueSource={}; 
		for(i=1;i LTE arraylen(arrId);i++){ 
			labelLookup[arrId[i]]=arrLabel[i];
			sourceId=arrId[i];
			if(structkeyexists(request.leadData.keywordData, sourceId)){
				kd=request.leadData.keywordData[sourceId];
				if(structkeyexists(labelLookup, sourceId)){
					kd.sourceLabel=labelLookup[sourceId];
				}else{
					kd.sourceLabel="Google Rankings";
				}
				if(structkeyexists(uniqueSource, kd.sourceLabel)){
					continue;
				}
				uniqueSource[kd.sourceLabel]=true;
				TopVerifiedRankings(kd);
				verifiedRankings(kd);
			}else{
				//throw("Invalid Source Label: #arrLabel[i]#");
			}
		} 
		incomingOrganic();
		newsletterStats();
		blogLog();
		facebookLog();
		leadSummaryByTypeData();
		//to do 
		if(structkeyexists(form, 'enableSourceChart')){
			websiteLeadsBarChart();
		}
		phoneLogOut=phoneCallLog();
		webFormOut=webformLog();
		leadSummaryOut=leadSummaryByType();

		echo(leadSummaryOut);
		echo(phoneLogOut);
		echo(webFormOut);

		for(i=1;i LTE form.addPageCount;i++){
			showFooter();
		}
		reportFooter();
	}
	if(form.returnJSON EQ 1){
		rs=processAndDisplayReport(htmlOut);
		return rs;
	}else{
		processAndDisplayReport(htmlOut);
	}
	</cfscript>

			
</cffunction>

<cffunction name="initReportData" localmode="modern" access="public">
	<cfscript>
	form.AddPageCount=application.zcore.functions.zso(form, 'AddPageCount', true, 0);
	form.yearToDateLeadLog=application.zcore.functions.zso(form, 'yearToDateLeadLog', true, 0);
	request.leadData={};

	request.leadData.pageCount=0;
	if(form.yearToDateLeadLog EQ 1 or form.yearToDateLeadLog EQ 2){
		request.leadData.rowLimit=36;
	}else{
		request.leadData.rowLimit=31;
	}
	request.leadData.contentSection={
		Summary:0,
		LeadComparison:0,
		TopVerifiedRankings:0,
		facebookReach:0,
		VerifiedRankings:0,
		OrganicSearch:0,
		PhoneLog:0,
		WebLeadLog:0,
		leadTypeSummary:0,
		blogLog:0,
		newsletterLog:0,
		facebookLog:0
	};
	request.leadData.disableContentSection={
		Summary:false,
		LeadComparison:false,
		facebookReach:false,
		TopVerifiedRankings:false,
		VerifiedRankings:false,
		OrganicSearch:false,
		PhoneLog:false,
		WebLeadLog:false,
		leadTypeSummary:false,
		blogLog:false,
		newsletterLog:false,
		facebookLog:false
	}; 
	form.disableSection=application.zcore.functions.zso(form, 'disableSection');
	arrSection=listToArray(form.disableSection, ",");
	for(section in arrSection){
		if(structkeyexists(request.leadData.disableContentSection, section)){
			request.leadData.disableContentSection[section]=true;
		}
	}
	db=request.zos.queryObject;
	request.leadData.typeLookup={};
	typeIdLookup={};
	//application.zcore.template.setPlainTemplate();

	if(form.yearToDateLeadLog EQ 2){ 
		// this code can disable the long winded sections, but they didn't want that.
		//form.disableSection&=",blogLog,PhoneLog,WebLeadLog";

		firstOfMonth=form.selectedMonth&"-01";
		request.leadData.startDate=form.selectedMonth&"-01"&" 00:00:00";
		request.leadData.startMonthDate=request.leadData.startDate;
		request.leadData.endDate=dateformat(dateadd("yyyy", 1, form.selectedMonth), "yyyy-mm")&"-01"&" 00:00:00";
		request.leadData.selectedMonth=form.selectedMonth;

		//request.leadData.endDate=dateformat(dateadd("m", 1, form.selectedMonth), "yyyy-mm-dd")&" 00:00:00";

		request.leadData.previousStartDate=dateformat(dateadd("yyyy", -1, request.leadData.startDate), "yyyy-mm-dd");
		request.leadData.previousStartMonthDate=dateformat(dateadd("yyyy", -1, request.leadData.startMonthDate), "yyyy-mm-dd");
		request.leadData.previousEndDate=dateformat(request.leadData.startDate, "yyyy-mm-dd");  
	}else{

		if(not structkeyexists(form, 'selectedMonth')){
			firstOfMonth=createdate(year(now()), month(now()), 1);
			form.selectedMonth=dateformat(dateadd("d", -1, firstOfMonth), "yyyy-mm");
		}
		request.leadData.selectedMonth=form.selectedMonth;

		//request.leadData.startDate=form.selectedMonth&"-01 00:00:00";

		firstOfYear=year(request.leadData.selectedMonth)&"-01-01";
		if(form.yearToDateLeadLog EQ 1){
			//throw("not implemented");
			request.leadData.startDate=firstOfYear;
			request.leadData.startMonthDate=firstOfYear;
			request.leadData.endDate=dateformat(dateadd("m", 1, form.selectedMonth), "yyyy-mm-dd")&" 00:00:00";
		}else if(form.yearToDateLeadLog EQ 0){
			request.leadData.startDate=dateformat(dateadd("m", -2, form.selectedMonth&"-01"), "yyyy-mm-dd");
			request.leadData.startMonthDate=form.selectedMonth&"-01";
			request.leadData.endDate=dateformat(dateadd("m", 1, form.selectedMonth), "yyyy-mm-dd")&" 00:00:00";
		}
		request.leadData.previousStartDate=dateformat(dateadd("yyyy", -1, request.leadData.startDate), "yyyy-mm-dd");
		request.leadData.previousStartMonthDate=dateformat(dateadd("yyyy", -1, request.leadData.startMonthDate), "yyyy-mm-dd");
		request.leadData.previousEndDate=dateformat(dateadd("yyyy", -1, request.leadData.endDate), "yyyy-mm-dd");
 	}

	db.sql="SELECT * FROM #db.table("inquiries_type", request.zos.zcoreDatasource)#
	WHERE  
	inquiries_type_deleted=#db.param(0)# and   
	site_id = #db.param(0)#";
	qType=db.execute("qType");
	for(row in qType){
		request.leadData.typeLookup[application.zcore.functions.zGetSiteIdType(row.site_id)&"-"&row.inquiries_type_id]=row.inquiries_type_name;
		typeIdLookup[row.inquiries_type_name]=row;
	} 

	db.sql="SELECT * FROM #db.table("inquiries_type", request.zos.zcoreDatasource)#
	WHERE  
	inquiries_type_deleted=#db.param(0)# and   
	site_id = #db.param(request.zos.globals.id)#";
	qType=db.execute("qType");
 
	for(row in qType){
		request.leadData.typeLookup[application.zcore.functions.zGetSiteIdType(row.site_id)&"-"&row.inquiries_type_id]=row.inquiries_type_name;
		typeIdLookup[row.inquiries_type_name]=row;
	}


	request.leadData.phoneMonthStruct=typeIdLookup["Phone Call"];
	// get previous period

	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_final_inquiries_id=#db.param(0)# and 
	inquiries_datetime>=#db.param(request.leadData.previousStartDate)# and 
	inquiries_datetime<#db.param(request.leadData.previousEndDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&=" GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date ";
	qPreviousMonthTotal=db.execute("qPreviousMonthTotal"); 

	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_final_inquiries_id=#db.param(0)# and 
	inquiries_datetime>=#db.param(request.leadData.previousStartDate)# and 
	inquiries_datetime<#db.param(request.leadData.previousEndDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries_type_id=#db.param(request.leadData.phoneMonthStruct.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(request.leadData.phoneMonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#"; 
	filterInquiryTableSQL(db);
	db.sql&="
	GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date ";
	qPreviousMonthPhone=db.execute("qPreviousMonthPhone"); 


	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_final_inquiries_id=#db.param(0)# and ";
	if(form.yearToDateLeadLog EQ 2){
		db.sql&=" inquiries_datetime>=#db.param(request.leadData.previousStartMonthDate&" 00:00:00")# and ";
	}else{
		db.sql&=" inquiries_datetime>=#db.param(year(request.leadData.previousStartMonthDate)&"-01-01 00:00:00")# and ";
	}
	db.sql&=" inquiries_datetime<#db.param(request.leadData.previousEndDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&="
	ORDER BY date ";
	qPreviousYTDTotal=db.execute("qPreviousYTDTotal");  

	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_final_inquiries_id=#db.param(0)# and ";
	if(form.yearToDateLeadLog EQ 2){
		db.sql&=" inquiries_datetime>=#db.param(request.leadData.previousStartMonthDate&" 00:00:00")# and ";
	}else{
		db.sql&=" inquiries_datetime>=#db.param(year(request.leadData.previousStartMonthDate)&"-01-01 00:00:00")# and ";
	}
	db.sql&="
	inquiries_datetime<#db.param(request.leadData.previousEndDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries_type_id=#db.param(request.leadData.phoneMonthStruct.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(request.leadData.phoneMonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&="
	ORDER BY date ";
	qPreviousYTDPhone=db.execute("qPreviousYTDPhone");



	// get current period
	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_final_inquiries_id=#db.param(0)# and 
	inquiries_datetime>=#db.param(request.leadData.startDate)# and 
	inquiries_datetime<#db.param(request.leadData.endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries.site_id = #db.param(request.zos.globals.id)#"; 
	filterInquiryTableSQL(db);
	db.sql&="
	GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date ";
	qMonthTotal=db.execute("qMonthTotal");  

	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_final_inquiries_id=#db.param(0)# and 
	inquiries_datetime>=#db.param(request.leadData.startDate)# and 
	inquiries_datetime<#db.param(request.leadData.endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries_type_id=#db.param(request.leadData.phoneMonthStruct.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(request.leadData.phoneMonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#"; 
	filterInquiryTableSQL(db);
	db.sql&="
	GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date ";
	qMonthPhone=db.execute("qMonthPhone"); 


	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_final_inquiries_id=#db.param(0)# and ";
	if(form.yearToDateLeadLog EQ 2){
		db.sql&=" inquiries_datetime>=#db.param(request.leadData.startDate&" 00:00:00")# and ";
	}else{
		db.sql&=" inquiries_datetime>=#db.param(year(request.leadData.startMonthDate)&"-01-01 00:00:00")# and ";
	}
	db.sql&="
	inquiries_datetime<#db.param(request.leadData.endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&="
	ORDER BY date ";
	qYTDTotal=db.execute("qYTDTotal");

	db.sql="SELECT 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_final_inquiries_id=#db.param(0)# and ";
	if(form.yearToDateLeadLog EQ 2){
		db.sql&=" inquiries_datetime>=#db.param(request.leadData.startMonthDate&" 00:00:00")# and ";
	}else{
		db.sql&=" inquiries_datetime>=#db.param(year(request.leadData.startMonthDate)&"-01-01 00:00:00")# and ";
	}
	db.sql&="
	inquiries_datetime<#db.param(request.leadData.endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries_type_id=#db.param(request.leadData.phoneMonthStruct.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(request.leadData.phoneMonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&="
	ORDER BY date ";
	qYTDPhone=db.execute("qYTDPhone"); 


	db.sql="SELECT  inquiries.inquiries_type_id, DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE   
	inquiries_final_inquiries_id=#db.param(0)# and 
	inquiries_deleted=#db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# "; 
	filterInquiryTableSQL(db);
	db.sql&="
	GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date";
	qMonth=db.execute("qMonth");
	
 
	request.leadData.monthStruct2={};
	request.leadData.monthStruct={};
	request.leadData.ytdStruct={
		total:0,
		phone:0
	};
	request.leadData.previousYtdStruct={
		total:0,
		phone:0
	};
	for(row in qMonthTotal){
		if(not structkeyexists(request.leadData.monthStruct, row.date)){
			request.leadData.monthStruct[row.date]={
				total:0,
				phone:0
			};
		} 
		request.leadData.monthStruct[row.date].total=row.count;
	}
	for(row in qMonthPhone){
		if(not structkeyexists(request.leadData.monthStruct, row.date)){
			request.leadData.monthStruct[row.date]={
				total:0,
				phone:0
			};
		} 
		request.leadData.monthStruct[row.date].phone=row.count;
		if(request.leadData.monthStruct[row.date].total EQ 0){
			request.leadData.monthStruct[row.date].total=request.leadData.monthStruct[row.date].phone;
		}
	}  
	for(row in qYTDTotal){ 
		request.leadData.ytdStruct.total=row.count;
	}
	for(row in qYTDPhone){
		request.leadData.ytdStruct.phone=row.count;
		if(request.leadData.ytdStruct.total EQ 0){
			request.leadData.ytdStruct.total=request.leadData.ytdStruct.phone;
		}
	}  

	if(form.yearToDateLeadLog EQ 0){
		for(row in qPreviousMonthTotal){
			if(not structkeyexists(request.leadData.monthStruct, row.date)){
				request.leadData.monthStruct[row.date]={
					total:0,
					phone:0
				};
			} 
			request.leadData.monthStruct[row.date].total=row.count;
		}
		for(row in qPreviousMonthPhone){
			if(not structkeyexists(request.leadData.monthStruct, row.date)){
				request.leadData.monthStruct[row.date]={
					total:0,
					phone:0
				};
			} 
			request.leadData.monthStruct[row.date].phone=row.count;
			if(request.leadData.monthStruct[row.date].total EQ 0){
				request.leadData.monthStruct[row.date].total=request.leadData.monthStruct[row.date].phone;
			}
		}  
	}
	for(row in qPreviousYTDTotal){ 
		request.leadData.previousYtdStruct.total=row.count;
	}
	for(row in qPreviousYTDPhone){
		request.leadData.previousYtdStruct.phone=row.count;
		if(request.leadData.previousYtdStruct.total EQ 0){
			request.leadData.previousYtdStruct.total=request.leadData.previousYtdStruct.phone;
		}
	}  

	request.leadData.arrStat=[];
	for(row in qMonthTotal){
		tempPreviousDate=dateformat(dateadd("yyyy", -1, row.date), "yyyy-mm");
		//if(dateformat(row.date, "mmmm") EQ dateformat(request.leadData.startMonthDate, "mmmm")){
			if(structkeyexists(request.leadData.monthStruct, tempPreviousDate)){
				ps=request.leadData.monthStruct[tempPreviousDate];
				cs=request.leadData.monthStruct[row.date]; 
				previousWebLeads=ps.total-ps.phone;
				webLeads=cs.total-cs.phone;
				if(ps.total NEQ 0 and ps.total<cs.total){
					percentIncrease=round(((cs.total-ps.total)/ps.total)*100);
					arrayAppend(request.leadData.arrStat, "There was a "&percentIncrease&"% increase in total leads in #dateformat(row.date, "mmmm")# compared to last year");
				}else if(ps.phone NEQ 0 and ps.phone<cs.phone){
					percentIncrease=round(((cs.phone-ps.phone)/ps.phone)*100);
					arrayAppend(request.leadData.arrStat, "There was a "&percentIncrease&"% increase in phone call leads in #dateformat(row.date, "mmmm")# compared to last year");
				}else if(previousWebLeads NEQ 0 and previousWebLeads<webLeads){
					percentIncrease=round(((webLeads-previousWebLeads)/previousWebLeads)*100);
					arrayAppend(request.leadData.arrStat, "There was a "&percentIncrease&"% increase in web form leads in #dateformat(row.date, "mmmm")# compared to last year");
				}
			}
			// calc year on year MONTHLY comparison percentages.

			// calc year on year YTD comparison percentages.
		//}
	} 
	previousYTDWebLeads=request.leadData.previousYtdStruct.total-request.leadData.previousYtdStruct.phone;
	yTDWebLeads=request.leadData.ytdStruct.total-request.leadData.ytdStruct.phone;
	if(request.leadData.previousYtdStruct.total NEQ 0 and request.leadData.previousYtdStruct.total<request.leadData.ytdStruct.total){
		percentIncrease=round(((request.leadData.ytdStruct.total-request.leadData.previousYtdStruct.total)/request.leadData.previousYtdStruct.total)*100);
		arrayAppend(request.leadData.arrStat, "There was a "&percentIncrease&"% increase in total leads year on year");
	}else if(request.leadData.previousYtdStruct.phone NEQ 0 and request.leadData.previousYtdStruct.phone<request.leadData.ytdStruct.phone){
		percentIncrease=round(((request.leadData.ytdStruct.phone-request.leadData.previousYtdStruct.phone)/request.leadData.previousYtdStruct.phone)*100);
		arrayAppend(request.leadData.arrStat, "There was a "&percentIncrease&"% increase in phone call leads year on year");
	}else if(previousYTDWebLeads NEQ 0 and previousYTDWebLeads<YTDwebLeads){
		percentIncrease=round(((YTDwebLeads-previousYTDWebLeads)/previousYTDWebLeads)*100);
		arrayAppend(request.leadData.arrStat, "There was a "&percentIncrease&"% increase in web form leads year on year");
	} 




	db.sql="select * from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_id = #db.param(request.zos.globals.id)# and 
	site_deleted=#db.param(0)# ";
	request.leadData.qSite=db.execute("qSite");

	request.leadData.footerDomain=request.leadData.qSite.site_short_domain;
	if(request.leadData.qSite.site_semrush_domain NEQ ""){
		request.leadData.footerDomain=request.leadData.qSite.site_semrush_domain;
	}
	if(request.leadData.qSite.site_report_company_name NEQ ""){
		request.leadData.footerDomain=request.leadData.qSite.site_report_company_name;
	} 


	request.leadData.arrDisable=[];
	for(i in request.leadData.disableContentSection){
		if(request.leadData.disableContentSection[i]){
			arrayAppend(request.leadData.arrDisable, i);
		}
	}
	</cfscript>
</cffunction>


<cffunction name="showFooter" localmode="modern" access="public">
	<cfargument name="last" type="boolean" required="no" default="#false#">
	<cfscript>
	request.leadData.pageCount++; if(request.zos.isdeveloper and structkeyexists(form, 'debugpage')){ echo('page: #request.leadData.pageCount#<br>'); }
	</cfscript>
	
	</div>
	<cfif structkeyexists(form, 'print')>
		<div class="print-footer"> 
			<div style="width:70%; float:left; text-align:left;">
				<cfif form.yearToDateLeadLog EQ 2>
					<p class="leadHeading">#dateformat(request.leadData.startDate, "mmm yyyy")# to #dateformat(request.leadData.endDate, "mmm yyyy")# - #request.leadData.footerDomain#</p>
				<cfelseif form.yearToDateLeadLog EQ 1>
					<p class="leadHeading">Jan to #dateformat(request.leadData.selectedMonth, "mmm yyyy")# - #request.leadData.footerDomain#</p>
				<cfelse>
					<p class="leadHeading">#dateformat(request.leadData.selectedMonth, "mmmm yyyy")# - #request.leadData.footerDomain#</p>
				</cfif>  
			</div>
			<div style="width:30%; float:left;">
				Page #request.leadData.pageCount# of {pagecount}
			</div>
		</div>
	</cfif> <!--- 
	<cfif structkeyexists(form, 'print')>
		<div class="page-break"></div>
	</cfif> --->
	
	<cfif arguments.last EQ false>
		<div class="main-header">
	</cfif>
</cffunction>


<cffunction name="reportHeader" localmode="modern" access="public">
	
<html>
	<head>
		<title>Report</title>
	    <meta charset="utf-8" /> 
	    <script src="https://code.jquery.com/jquery-1.12.4.min.js" type="text/javascript"></script>
	    <script src="#request.zos.globals.domain#/z/javascript/d3/d3.js" type="text/javascript"></script>

		<script> 
		function loadLineCharts(){
			$("svg").each(function(){
				//if($(this).attr("data-attr") != "ignore"){
					var svg = d3.select(this),
					    margin = {top: 20, right: 20, bottom: 30, left: 50},
					    width = +svg.attr("width") - margin.left - margin.right,
					    height = +svg.attr("height") - margin.top - margin.bottom,
					    g = svg.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");

					var parseTime = d3.timeParse("%m/%d/%Y");

					var x = d3.scaleTime()
					    .rangeRound([0, width]);

					var y = d3.scaleLinear()
					    .rangeRound([height, 0]);

					var area = d3.area()
					    .x(function(d) { return x(d.date); })
					    .y1(function(d) { return y(d.close); });

					var verticalLabel=$(this).attr("data-json-vertical-label");
					var areaColor=$(this).attr("data-chart-area-color");
					var data=JSON.parse($(this).attr("data-jsondata"));
					var minValue=100000000;
					for(var i=0;i<data.length;i++){
						data[i].date=parseTime(data[i].date);
						if(data[i].close < minValue){
							minValue=data[i].close;
						}
					}  
					x.domain(d3.extent(data, function(d) {  return d.date; }));
					y.domain([minValue, d3.max(data, function(d) { return d.close; })]);
					area.y0(y(minValue));

					g.append("path")
					      .datum(data)
					      .attr("fill", "##"+areaColor) //"rgba(0,68,175,1)")
					      .attr("d", area);

					g.append("g")
					      .attr("transform", "translate(0," + height + ")")
					      .call(d3.axisBottom(x)); 

					g.append("g")
					      .call(d3.axisLeft(y))
					    .append("text")
					      .attr("fill", "##000")
					      .attr("transform", "rotate(-90)")
					      .attr("y", 6)
					      .attr("dy", "0.71em")
					      .attr("text-anchor", "end")
					      .text(verticalLabel);
					      g;   
				//}
			});
		}
		$(document).ready(function(){
			loadLineCharts();
		});
		//});
		</script>
	    <link href="#request.zos.globals.domain#/z/fonts/stylesheet.css" type="text/css" rel="stylesheet" />
	<style type="text/css">
		body{font-family:'Open Sans', serif; line-height:1.3; font-size:13px; margin:0px;}
	h1,h2,h3,h4,h5, p, ul, ol{margin:0px; padding:0px; padding-bottom:20px;}
	h1{ font-size:30px;}
	h2{ margin-top:50px; font-size:24px;}
	h3{font-size:18px;}
	table{font-family:'Open Sans', serif; font-weight:normal;}

	.leadHeading{padding-top:20px;}
	.leadTable1{border-spacing:0px;
	width:100%;
	margin-bottom:20px;
		border-right:1px solid ##999;
		border-bottom:1px solid ##999;}
	.leadTable1 th{ text-align:left;}
	.leadTable1 th, .leadTable1 td{
		padding:3px;
		font-size:10px;
		line-height:1.3; 
		border:1px solid ##999;
		border-right:none;
		border-bottom:none;

	} 
	<cfif form.yearToDateLeadLog EQ 1 or form.yearToDateLeadLog EQ 2>
		.leadTable1 th, .leadTable1 td{
		font-size:9px;
		}
	</cfif>
	*{-webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing:border-box;}
	.topFiveColor{background-color:##e9ea96;}
	.topTenColor{background-color:##96dcf8;}
	.topTwentyColor{background-color:##bacde4;}
	.topFiftyColor{background-color:##fbd57f;}
	.wrapper{  padding:20px; } 
	.print-footer {
	    text-align:right;
	    width: 100%;
	    float:left;
	    position: relative;
	    margin-top:-95px;
	    z-index:2;
	    margin-left:23px;
	    padding:45px;
	    padding-top:20px; 
	    padding-bottom:0px;
	    width:755px;
	} 
	.organicTrafficChart td{  font-size:13px; padding:5px;}
	.leadSummaryTable td{padding-right:50px; white-space:nowrap; }
	.tableOfContentsTable td{padding-right:50px; white-space:nowrap; }
	.main-header{
	margin-top:30px;
	position:relative;z-index:1; 
	width:100%; float:left;}
	<cfif structkeyexists(form, 'print')>
		.wrapper{padding:0px;max-width:8.5in;}
		.main-header{ margin-top:23px;margin:23px;  float:left; width:755px; border:1px solid ##000; padding:45px; padding-top:165px; height:985px; clear:both;  page-break-after: always; }
		<cfif not request.zos.istestserver and request.zos.marketingBgImageURL NEQ "">
			.main-header{background-image:url(#request.zos.marketingBgImageURL#); background-repeat:no-repeat; background-size:100% auto;}
		</cfif>
		.leadHeading{padding-top:0px;}
		.hide-on-print{display:none;}  
	<cfelse>
		##print-footer { display:none; }
		@media only print {
			.hide-on-print{display:none;}
			.page-break	{ display: block; page-break-before: always; }
		}
	</cfif>
	</style>
</head>
<body>

<div class="wrapper">
	<div class="hide-on-print">
		<div>
			<div style="width:50%; float:left;">
				<a href="##generatedInfo">Learn How This Report Was Generated</a> 
			</div>
			<div style="width:50%; float:left;">
				<form action="/z/inquiries/admin/custom-lead-report/index" method="get">
				<p style="text-align:right;">Select Month: 
				<input type="month" name="selectedMonth" value="#dateformat(form.selectedMonth, "yyyy-mm")#"> 
				<input type="submit" name="select1" value="Select"> | 
				<a href="#request.zos.originalURL#?selectedMonth=#form.selectedMonth#&amp;print=1&amp;yearToDateLeadLog=#form.yearToDateLeadLog#&amp;disableSection=#urlencodedformat(arrayToList(request.leadData.arrDisable, ","))#&addPageCount=#form.addPageCount#" target="_blank">View {totalPageCount} Page PDF</a></p>
				</form>

			</div>
		</div>
		<div class="uptodateDiv"><p style="font-size:18px; font-weight:bold; color:##FF0000;">This report has data sources that are not up to date for the selected month<br>
			See data integration status at the bottom of report for more information</p></div>
		<cfscript> 
		if(form.yearToDateLeadLog NEQ 2){
			if(not isValidMonth(request.leadData.selectedMonth)){
				echo('<div><p style="font-size:18px; font-weight:bold; color:##FF0000;">There is no data available for this month.</p></div>');
			}
		}
		</cfscript>
	</div>
	<div class="main-header">
		<p style="font-size:36px; color:##999; padding-bottom:0px;  margin-top:0px;">#replace(request.leadData.footerDomain, "."&request.zos.testDomain, "")#</p>
		<cfif form.yearToDateLeadLog EQ 2>
					<p class="leadHeading">#dateformat(request.leadData.startDate, "mmmm yyyy")# to #dateformat(dateadd("m", -1, request.leadData.endDate), "mmmm yyyy")# Digital Marketing Report</p>
		<cfelseif form.yearToDateLeadLog EQ 1>
			<p style="font-size:24px; font-weight:bold; padding-top:0px;">January to #dateformat(request.leadData.selectedMonth, "mmmm yyyy")#<br>
			Digital Marketing Report</p> 
		<cfelse>
			<p style="font-size:24px; font-weight:bold; padding-top:0px;">#dateformat(form.selectedMonth, "mmmm yyyy")# Digital Marketing Report</p> 
		</cfif>


</cffunction>
	
<cffunction name="tableOfContents" localmode="modern" access="public">
	
	<h2 style="font-weight:normal;">Table Of Contents</h2>
	<p class="hide-on-print">Checking boxes and clicking update will exclude the section</p>
	<form action="#request.zos.originalURL#" method="get">
	<table class="tableOfContentsTable">
		<tr style="{SummaryStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="Summary" <cfif request.leadData.disableContentSection.Summary>checked="checked"</cfif>></td> 
			<td>Website Leads</td><td>{SummaryPageNumber}</td>
		<tr style="{LeadComparisonStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="LeadComparison" <cfif request.leadData.disableContentSection.LeadComparison>checked="checked"</cfif>></td>
			<td>Lead Comparison</td><td>{LeadComparisonPageNumber}</td></tr>
		<tr style="{TopVerifiedRankingsStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="TopVerifiedRankings" <cfif request.leadData.disableContentSection.TopVerifiedRankings>checked="checked"</cfif>></td>
			<td>Top Verified Keyword Rankings</td><td>{TopVerifiedRankingsPageNumber}</td></tr>
		<tr style="{VerifiedRankingsStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="VerifiedRankings" <cfif request.leadData.disableContentSection.VerifiedRankings>checked="checked"</cfif>></td>
			<td>Verified Keyword Ranking Results</td><td>{VerifiedRankingsPageNumber}</td></tr>
		<tr style="{OrganicSearchStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="OrganicSearch" <cfif request.leadData.disableContentSection.OrganicSearch>checked="checked"</cfif>></td>
			<td>Incoming Organic Search Traffic</td><td>{OrganicSearchPageNumber}</td></tr>
		<tr style="{newsletterLogStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="newsletterLog" <cfif request.leadData.disableContentSection.newsletterLog>checked="checked"</cfif>></td>
			<td>Email Marketing</td><td>{newsletterLogPageNumber}</td></tr> 
		<tr style="{blogLogStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="blogLog" <cfif request.leadData.disableContentSection.blogLog>checked="checked"</cfif>></td>
			<td>Blog Articles</td><td>{blogLogPageNumber}</td></tr> 
		<tr style="{facebookLogStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="facebookLog" <cfif request.leadData.disableContentSection.facebookLog>checked="checked"</cfif>></td>
			<td>Facebook Marketing</td><td>{facebookLogPageNumber}</td></tr>  
		<cfif not structkeyexists(form, 'print')>
			<tr style="{facebookReachStyle}">
				<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="facebookReach" <cfif request.leadData.disableContentSection.facebookReach>checked="checked"</cfif>></td>
				<td>Facebook Reach</td><td>{facebookReachPageNumber}</td></tr>  
		</cfif>
		<tr style="{leadTypeSummaryStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="leadTypeSummary" <cfif request.leadData.disableContentSection.leadTypeSummary>checked="checked"</cfif>></td>
			<td>Lead Summary By Type</td><td>{leadTypeSummaryPageNumber}</td></tr>
		<tr style="{PhoneLogStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="PhoneLog" <cfif request.leadData.disableContentSection.PhoneLog>checked="checked"</cfif>></td>
			<td>Phone Call Lead Log</td><td>{PhoneLogPageNumber}</td></tr>
		<tr style="{WebLeadLogStyle}">
			<td class="hide-on-print" style="width:1%; padding-right:0px;"><input type="checkbox" name="disableSection" value="WebLeadLog" <cfif request.leadData.disableContentSection.webLeadLog>checked="checked"</cfif>></td>
			<td>Web Form Lead Log</td><td>{WebLeadLogPageNumber}</td></tr> 
	</table> 
	<div class="hide-on-print" style="padding-top:20px;">
		<input type="hidden" name="selectedMonth" value="#htmleditformat(form.selectedMonth)#">
		<p>Add Pages At Bottom: <input type="text" style="width:50px;" name="AddPageCount" value="#form.addPageCount#"></p>
		<p>Date Range: 
		<input type="radio" name="yearToDateLeadLog" value="1" <cfif form.yearToDateLeadLog EQ 1>checked="checked"</cfif>> 
		January 1st to End of Selected Month | 
		<input type="radio" name="yearToDateLeadLog" value="0" <cfif form.yearToDateLeadLog EQ 0>checked="checked"</cfif>> 
		Selected Month | 
		<input type="radio" name="yearToDateLeadLog" value="2" <cfif form.yearToDateLeadLog EQ 2>checked="checked"</cfif>> 
		12 Months Starting with Selected Month</p>
		<p>Facebook Month Table: 
		<input type="radio" name="facebookQuarters" value="1" <cfif form.facebookQuarters EQ 1>checked="checked"</cfif>> 
		4 Quarters
		<input type="radio" name="facebookQuarters" value="0" <cfif form.facebookQuarters EQ 0>checked="checked"</cfif>> 
		Last Year and Last 2 Months (Required if less then 1 year of data)</p>
		<p><input type="submit" name="submit1" value="Update Report">
		<input type="button" name="submit2" value="Reset" onclick="window.location.href='#request.zos.originalURL#';"></p>
	</div>
	<cfscript>
	for(i in request.leadData.disableContentSection){
		if(request.leadData.disableContentSection[i]){
			echo('<input type="hidden" name="disableSection" value="#i#">');
		}
	}
	</cfscript>
	</form>
</cffunction>
<cffunction name="websiteLeadsBarChart" localmode="modern" access="public">
	<h2 style="margin-top:0px;">Lead Comparison Chart</h2>
	<div class="z-float" id="divChannels"></div>
	<div style="height:350px; padding-left:10px; float:left;">
		<cfscript>
			//application.zcore.skin.includeJS("#request.zos.globals.domain#/z/javascript/d3/d3.js");
			//initReportData();
			//request.leadData.contentSection.Summary=request.leadData.pageCount; 
			//writeDUmp(request.leadData.monthStruct);abort;
			var barData 	= [];
			for(var key in request.leadData.monthStruct){
				arrayAppend(barData,{"month": "#key#", "Phone Leads" : request.leadData.monthStruct[key].phone, "Web Leads": (request.leadData.monthStruct[key].total - request.leadData.monthStruct[key].phone)});
			}
			//writeDump(barData);abort;
			#makeStackGraph(serializeJSON(barData),"pcStack")#;	
		</cfscript>
	</div>
</cffunction>
<cffunction name="makeStackGraph" localmode="modern" access="remote">
	<cfargument name="chartData" type="string" required="yes">
	<cfargument name="chartName" type="string" required="yes">
	<div style="float:left;padding-left:150px;">
		<svg data-attr="ignore" id="#arguments.chartName#" width="500" height="325">
		</svg>
	</div>
	<script>
		function #arguments.chartName#loadStackCharts(){
			var color = d3.scaleOrdinal().range(["##319177",
												 "##867200", 
												 "##93DFB8",
												 "##FF7A00",
												 "##AD4379",
												 "##652DC1", 
												 "##C5E17A", 
												 "##0A6B0D", 
												 "##87FF2A", 
												 "##FFC800", 
												 "##F653A6", 
												 "##6456B7", 
												 "##FDFF00", 
												 "##708EB3",
												 "##000000",
												 "##A6A6A6",
												 "##9E5E6F",
												 "##DA2C43",
												 "##778BA5",
												 "##5FA778",
												 "##5F8A8B",
												 "##914E75"
												 ]);

			var data	 	= #arguments.chartData#;
			//alert(JSON.stringify(data));
			var keys		= ["Web Leads", "Phone Leads"];
			var series = d3.stack()
			    .keys(keys)
			    .offset(d3.stackOffsetDiverging)
			    (data);
			var svg = d3.select("svg"),
			    margin = {top: 20, right: 30, bottom: 30, left: 290},
			    width = +svg.attr("width"),
			    height = +svg.attr("height");

			var x = d3.scaleBand()
			    .domain(data.map(function(d) { return d.month; }))
			    .rangeRound([margin.left, width - margin.right])
			    .padding(0.1);

			var y = d3.scaleLinear()
			    .domain([d3.min(series, stackMin), d3.max(series, stackMax)])
			    .rangeRound([height - margin.bottom, margin.top]);

			var z = d3.scaleOrdinal(d3.schemeCategory10);

			svg.append("g")
			  .selectAll("g")
			  .data(series)
			  .enter().append("g")
			    //.attr("fill", function(d) { alert(z(d.key));return z(d.key); })
				.style("fill", function(d,i) { return color(i);})
			  .selectAll("rect")
			  .data(function(d) { return d; })
			  .enter().append("rect")
			    .attr("width", x.bandwidth)
			    .attr("x", function(d) { return x(d.data.month); })
			    .attr("y", function(d) { /*if(isNaN(y(d[1]))) return 1; else*/ return y(d[1]); })
			    .attr("height", function(d) { if(isNaN(y(d[1]))) return 1; else return y(d[0]) - y(d[1]); })

			svg.append("g")
			    .attr("transform", "translate(0," + y(0) + ")")
			    .call(d3.axisBottom(x));

			svg.append("g")
			    .attr("transform", "translate(" + margin.left + ",0)")
			    .call(d3.axisLeft(y));

			var legend = svg.append("g")
		  		.attr("class", "legend")
				.attr("height", 100)
		  		.attr("width", 100)
	    		.attr('transform', 'translate(-20,50)');
	   
		    legend.selectAll('rect')
		      .data(keys)
		      .enter()
		      .append("rect")
			  .attr("x", 5)
		      .attr("y", function(d, i){ return (i *  30);})
			  .attr("width", 45)
			  .attr("height", 25)
			  .style("fill", function(d,i) { 
		        var color_hash = color(i);
		        return color_hash;
		    });
	      
		    legend.selectAll('text')
		      .data(keys)
		      .enter()
		      .append("text")
			  .attr("x", 55)
		      .attr("y", function(d, i){ return ((i *  30)+17);})
			  .text(function(d,i) {
		        var text = keys[i];
		        return text;
			});

		}
		function stackMin(serie) {
		  return d3.min(serie, function(d) { return d[0]; });
		}

		function stackMax(serie) {
		  return d3.max(serie, function(d) { return d[1]; });
		}		
		#arguments.chartName#loadStackCharts();
	</script>
</cffunction>

<cffunction name="websiteLeads" localmode="modern" access="public">

	<cfscript>
	if(request.leadData.disableContentSection["Summary"]){
		return;
	}
	</cfscript>
	#showFooter()#
	<cfscript>
	request.leadData.contentSection.Summary=request.leadData.pageCount; 
	</cfscript>

	<h2 style="margin-top:0px;">Website Leads</h2>
	<p>We are tracking conversions from your website through phone calls and contact form leads. 
	Below are the conversions from the month of #dateformat(form.selectedMonth, "mmmm")#:</p>
	<table class="leadSummaryTable ">
		<cfif form.yearToDateLeadLog EQ 1 or form.yearToDateLeadLog EQ 2>
			<cfscript>
			totalCalls=0;
			totalForms=0;
			totalLeads=0;
			for(i in request.leadData.monthStruct){
				v=request.leadData.monthStruct[i];
				totalCalls+=v.phone;
				totalForms+=v.total-v.phone;
				totalLeads+=v.total;
			}
			</cfscript>
				<tr>
					<td style="width:1%; white-space:nowrap;">Phone Calls:</td>
					<td>#numberformat(totalCalls)#</td>
				</tr>
				<tr>
					<td style="width:1%; white-space:nowrap;">Contact Form Leads:</td>
					<td>#numberformat(totalForms)#</td>
				</tr>
				<tr>
					<td style="width:1%; white-space:nowrap;">Total Leads:</td>
					<td>#numberformat(totalLeads)#</td>
				</tr>
		<cfelse>
			<cfif structkeyexists(request.leadData.monthStruct, dateformat(request.leadData.startMonthDate, "yyyy-mm"))>
				
				<tr>
					<td style="width:1%; white-space:nowrap;">Phone Calls:</td>
					<td>#numberformat(request.leadData.monthStruct[dateformat(request.leadData.startMonthDate, "yyyy-mm")].phone)#</td>
				</tr>
				<tr>
					<td style="width:1%; white-space:nowrap;">Contact Form Leads:</td>
					<td>#numberformat(request.leadData.monthStruct[dateformat(request.leadData.startMonthDate, "yyyy-mm")].total-request.leadData.monthStruct[dateformat(request.leadData.startMonthDate, "yyyy-mm")].phone)#</td>
				</tr>
				<tr>
					<td style="width:1%; white-space:nowrap;">Total Leads:</td>
					<td>#numberformat(request.leadData.monthStruct[dateformat(request.leadData.startMonthDate, "yyyy-mm")].total)#</td>
				</tr>
			<cfelse>
				<tr>
					<td style="width:1%; white-space:nowrap;">Phone Calls:</td>
					<td>0</td>
				</tr>
				<tr>
					<td style="width:1%; white-space:nowrap;">Contact Form Leads:</td>
					<td>0</td>
				</tr>
				<tr>
					<td style="width:1%; white-space:nowrap;">Total Leads:</td>
					<td>0</td>
				</tr>
			</cfif> 
			<tr>
				<td style="width:1%; white-space:nowrap;">Total Leads Year to Date:</td>
				<td>#numberformat(request.leadData.ytdStruct.total)#</td>
			</tr>
		</cfif>
	</table>

	<!--- 
leadchart
	db.sql="select * from #db.table("facebook_month", request.zos.zcoreDatasource)# WHERE ";  
	db.sql&=" facebook_month_datetime>=#db.param(dateformat(dateadd("yyyy", -1, request.leadData.endDate), "yyyy-mm-dd"))# and 
		facebook_month_datetime<#db.param(dateformat(dateadd("d", -1, dateadd("m", 1, request.leadData.endDate)), "yyyy-mm-dd"))# and "; 
	db.sql&=" site_id =#db.param(request.zos.globals.id)# and 
	facebook_month_deleted=#db.param(0)#  
	ORDER BY facebook_month_datetime ASC  ";
	qMonthChart=db.execute("qMonthChart");  

	
	// build json for the javascript line chart
	js=[];
	for(row in qMonthChart){
		ts={
			date:dateformat(row.facebook_month_datetime, "mm/dd/yyyy"),
			close: row.facebook_month_fans
		};
		arrayAppend(js, ts); 
	}
	
	
	
	<cfif arrayLen(js) NEQ 0> 
		<h2>Facebook Fans</h2>  
		<div style="float:left; width:100%;">
		<svg data-json-vertical-label="Facebook Fans" data-jsondata="#htmleditformat(serializeJson(js))#" width="680" height="230"></svg> 
		</div>
	</cfif>
	 --->

	<cfscript>
	if(form.yearToDateLeadLog EQ 0){
		if(arrayLen(request.leadData.arrStat)){
			echo('<h2>Lead Highlights</h2>');
			for(stat in request.leadData.arrStat){
				echo('<h4>#stat#</h4>');
			}
		}
	}
	</cfscript>  
</cffunction>
<cffunction name="leadComparison" localmode="modern" access="public">
	<cfscript>
	if(request.leadData.disableContentSection["LeadComparison"]){
		return;
	}
	</cfscript> 
	<cfscript>
	showFooter();  
	request.leadData.contentSection.LeadComparison=request.leadData.pageCount;
	</cfscript>
	<h2 style="margin-top:0px;">Lead Comparison Report</h2>
	<cfif form.yearToDateLeadLog EQ 2>
		<h3>#dateformat(request.leadData.startDate, "mmmm yyyy")# to #dateFormat(dateadd("m", -1, request.leadData.endDate), "mmmm yyyy")# Leads</h3>
	<cfelseif form.yearToDateLeadLog EQ 1>
		<h3>January to #dateFormat(dateadd("m", -1, request.leadData.endDate), "mmmm")# Leads</h3>
	<cfelse>
		<h3>#dateformat(request.leadData.startDate, "mmmm")# through #dateformat(request.leadData.startMonthDate, "mmmm")# Monthly Leads</h3>
	</cfif>
	<table style="border-spacing:0px;" class="leadTable1">
		<tr> 
			<th style="width:1%; white-space:nowrap;">&nbsp;</th>
			<cfscript> 
			arrMonth=structkeyarray(request.leadData.monthStruct);
			arraySort(arrMonth, "text", "asc");
			for(month in arrMonth){
				echo('<th>#dateformat(month, "mmm yyyy")#</th>');
			}
			</cfscript> 
		</tr> 
		<cfscript>
		echo('<tr>');
		echo('<td style="width:1%; white-space:nowrap;">Web Leads</td>');
		for(month in arrMonth){ 
			echo('<td>#numberformat(request.leadData.monthStruct[month].total-request.leadData.monthStruct[month].phone)#</td>');
		}
		echo('</tr><tr>');
		echo('<td style="width:1%; white-space:nowrap;">Phone Leads</td>');
		for(month in arrMonth){ 
			echo('<td>#numberformat(request.leadData.monthStruct[month].phone)#</td>');
		}
		echo('</tr><tr>');
		echo('<td style="width:1%; white-space:nowrap;">Total Leads</td>');
		for(month in arrMonth){ 
			echo('<td>#numberformat(request.leadData.monthStruct[month].total)#</td>');
		}
		echo('</tr>');
		</cfscript>  
	</table>  

	<h3>Year To Date Total Leads</h3>
	<table style="border-spacing:0px;" class="leadTable1">
		<tr> 
			<th style="width:1%; white-space:nowrap;">&nbsp;</th>
			<cfif isValidMonth(request.leadData.previousStartMonthDate)> 
				<th>#year(request.leadData.previousStartMonthDate)#</th>
			</cfif>
			<th>#year(request.leadData.startMonthDate)#</th>
		</tr> 
		<cfscript>
		echo('<tr>');
		echo('<td style="width:1%; white-space:nowrap;">Web Leads</td>');
		if(isValidMonth(request.leadData.previousStartMonthDate)){
			echo('<td>#numberformat(request.leadData.previousYtdStruct.total-request.leadData.previousYtdStruct.phone)#</td>');
		}
		echo('<td>#numberformat(request.leadData.ytdStruct.total-request.leadData.ytdStruct.phone)#</td>');
		echo('</tr><tr>');
		echo('<td style="width:1%; white-space:nowrap;">Phone Leads</td>');
		if(isValidMonth(request.leadData.previousStartMonthDate)){
			echo('<td>#numberformat(request.leadData.previousYtdStruct.phone)#</td>');
		}
		echo('<td>#numberformat(request.leadData.ytdStruct.phone)#</td>');
		echo('</tr><tr>');
		echo('<td style="width:1%; white-space:nowrap;">Total Leads</td>');
		if(isValidMonth(request.leadData.previousStartMonthDate)){
			echo('<td>#numberformat(request.leadData.previousYtdStruct.total)#</td>');
		}
		echo('<td>#numberformat(request.leadData.ytdStruct.total)#</td>');
		echo('</tr>');
 
		</cfscript>  
	</table>    
</cffunction>

<!--- need to modify to have secondary boolean, which changes which data is excluded

 --->
<cffunction name="getLabelKeywordData" localmode="modern" access="public">
	<cfargument name="sourceLabel" type="string" required="yes">
	<cfscript>
	</cfscript>
</cffunction>
	
<cffunction name="getKeywordData" localmode="modern" access="public"> 
	<cfscript>
	db=request.zos.queryObject;

	reportStartDate="";
	if(application.zcore.functions.zso(request.zos.globals, "reportStartDate") NEQ ""){
		reportStartDate=dateformat(request.zos.globals.reportStartDate, "yyyy-mm-dd");
	}
	keywordStartDate=reportStartDate;
	if(application.zcore.functions.zso(request.zos.globals, 'keywordRankingStartDate') NEQ ""){
		keywordStartDate=dateformat(request.zos.globals.keywordRankingStartDate, "yyyy-mm-dd");
	}
	// TODO: consider implementing a label lookup instead of basing everything on strings
	db.sql="select distinct keyword_ranking_source_id, keyword_ranking_secondary 
	from #db.table("keyword_ranking", request.zos.zcoreDatasource)# 
	WHERE
	site_id = #db.param(request.zos.globals.id)# and 
	keyword_ranking_deleted=#db.param(0)# ";
	qLabel=db.execute("qLabel"); 

	// create lookup struct for labels
	// site_semrush_label_list
	// site_seomoz_id_list
	db.sql="select distinct keyword_ranking_source_id, keyword_ranking_secondary 
	from #db.table("keyword_ranking", request.zos.zcoreDatasource)# 
	WHERE
	site_id = #db.param(request.zos.globals.id)# and 
	keyword_ranking_deleted=#db.param(0)# ";
	qLabel=db.execute("qLabel"); 
	arrLabelTemp=[];
	arrayAppend(arrLabelTemp, {keyword_ranking_source_id:"", keyword_ranking_secondary:"0"});
	for(labelRow in qLabel){
		if(labelRow.keyword_ranking_source_id NEQ ""){
  			arrayAppend(arrLabelTemp, labelRow);
  		}
  	}
	request.leadData.labelData={};
	for(labelRow in arrLabelTemp){
		sourceID=labelRow.keyword_ranking_source_id;
		if(sourceID EQ ""){
			sourceID="Google Rankings";
		}
		if(labelRow.keyword_ranking_secondary EQ 1){
			isSecondary=true;
		}else{
			isSecondary=false;
		}
		vs={};
		ks={}; 
		// build keyword report with separation on source label
		// exclude moz / search console with keyword_ranking_secondary=#db.param(1)#

		request.leadData.keywordData[sourceID]={};

		db.sql="select keyword_ranking_keyword  
		from #db.table("keyword_ranking", request.zos.zcoreDatasource)# WHERE  ";
		if(isSecondary){
			db.sql&=" keyword_ranking_source_id=#db.param(labelRow.keyword_ranking_source_id)# and ";
		}else{
			db.sql&=" keyword_ranking_secondary=#db.param(0)# and ";
		}
		db.sql&=" site_id = #db.param(request.zos.globals.id)# and 
		keyword_ranking_deleted=#db.param(0)# 
		GROUP BY keyword_ranking_keyword";
		qKeywordList=db.execute("qKeywordList");   

		db.sql="select *,
		DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#) date, 
		MIN(IF(keyword_ranking_position = #db.param(0)#, #db.param(1000)#, keyword_ranking_position)) topPosition, 
		max(keyword_ranking_search_volume) highestSearchVolume
		from #db.table("keyword_ranking", request.zos.zcoreDatasource)# WHERE ";
		if(isSecondary){
			db.sql&=" keyword_ranking_source_id=#db.param(labelRow.keyword_ranking_source_id)# and ";
		}else{
			db.sql&=" keyword_ranking_secondary=#db.param(0)# and ";
		}
		db.sql&="  
		keyword_ranking_run_datetime>=#db.param(request.leadData.startDate)# and 
		keyword_ranking_run_datetime<#db.param(request.leadData.endDate)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		keyword_ranking_deleted=#db.param(0)# ";
		filterOtherTableSQL(db, "keyword_ranking_run_datetime");
		//keyword_ranking_position<>#db.param(0)# and 
		db.sql&="
		GROUP BY DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#), keyword_ranking_keyword";
		request.leadData.keywordData[sourceID].qKeyword=db.execute("qKeyword"); 
 
		// TODO also need the previous search too request.leadData.keywordData[sourceID].qPreviousKeyword, etc
		db.sql="select *,
		DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#) date, 
		MIN(IF(keyword_ranking_position = #db.param(0)#, #db.param(1000)#, keyword_ranking_position)) topPosition, 
		max(keyword_ranking_search_volume) highestSearchVolume 
		from #db.table("keyword_ranking", request.zos.zcoreDatasource)# WHERE ";
		if(isSecondary){
			db.sql&=" keyword_ranking_source_id=#db.param(labelRow.keyword_ranking_source_id)# and ";
		}else{
			db.sql&=" keyword_ranking_secondary=#db.param(0)# and ";
		}
		db.sql&="  
		keyword_ranking_run_datetime>=#db.param(request.leadData.previousStartDate)# and 
		keyword_ranking_run_datetime<#db.param(request.leadData.previousEndDate)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		keyword_ranking_deleted=#db.param(0)# ";
		filterOtherTableSQL(db, "keyword_ranking_run_datetime"); 
		db.sql&="
		GROUP BY DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#), keyword_ranking_keyword";
		// keyword_ranking_position<>#db.param(0)# and 
		request.leadData.keywordData[sourceID].qPreviousKeyword=db.execute("qPreviousKeyword");


		db.sql="select 
		DATE_FORMAT(min(keyword_ranking_run_datetime), #db.param('%Y-%m')#) date 
		from #db.table("keyword_ranking", request.zos.zcoreDatasource)# WHERE   ";
		if(isSecondary){
			db.sql&=" keyword_ranking_source_id=#db.param(labelRow.keyword_ranking_source_id)# and ";
		}else{
			db.sql&=" keyword_ranking_secondary=#db.param(0)# and ";
		}
		db.sql&="  
		site_id = #db.param(request.zos.globals.id)# and 
		keyword_ranking_run_datetime >=#db.param('2000-01-01 00:00:00')# and
		";
		if(keywordStartDate NEQ ""){
			db.sql&=" keyword_ranking_run_datetime >=#db.param(keywordStartDate)# and ";
		}
		db.sql&="keyword_ranking_deleted=#db.param(0)# ";
		filterOtherTableSQL(db, "keyword_ranking_run_datetime");  
		qFirstKeyword=db.execute("qFirstKeyword"); 
	 
		keywordVolumeSortStruct={};
		uniqueKeyword={};
		count=0;
		for(row in request.leadData.keywordData[sourceID].qKeyword){
			if(not structkeyexists(ks, row.date)){
				ks[row.date]={};
				for(row2 in qKeywordList){
					ks[row.date][row2.keyword_ranking_keyword]=0;
				}
			}
			if(row.topPosition NEQ 0 and row.topPosition NEQ 1000){
				ks[row.date][row.keyword_ranking_keyword]=row.topPosition;
			} 
			if(not structkeyexists(vs, row.keyword_ranking_keyword)){
				vs[row.keyword_ranking_keyword]=0;
			}
			if(row.highestSearchVolume > vs[row.keyword_ranking_keyword]){
				vs[row.keyword_ranking_keyword]=row.highestSearchVolume;
			}
			if(not structkeyexists(uniqueKeyword, row.keyword_ranking_keyword)){
				uniqueKeyword[row.keyword_ranking_keyword]=true;
				keywordVolumeSortStruct[count]={
					keyword:row.keyword_ranking_keyword,
					volume:vs[row.keyword_ranking_keyword]
				}
			}
			count++;
		}  
		count=0;

		if(qFirstKeyword.recordcount){
			db.sql="select *,
			DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#) date, 
			MIN(IF(keyword_ranking_position = #db.param(0)#, #db.param(1000)#, keyword_ranking_position)) topPosition, 
			max(keyword_ranking_search_volume) highestSearchVolume
			from #db.table("keyword_ranking", request.zos.zcoreDatasource)# WHERE ";
			if(isSecondary){
				db.sql&=" keyword_ranking_source_id=#db.param(labelRow.keyword_ranking_source_id)# and ";
			}else{
				db.sql&=" keyword_ranking_secondary=#db.param(0)# and ";
			}
			db.sql&="  
			keyword_ranking_run_datetime>=#db.param(qFirstKeyword.date&"-01 00:00:00")# and 
			keyword_ranking_run_datetime<#db.param(dateformat(dateadd("m", 1, qFirstKeyword.date&"-01"), "yyyy-mm-dd")&" 00:00:00")# and 
			site_id = #db.param(request.zos.globals.id)# and 
			keyword_ranking_deleted=#db.param(0)# ";
			filterOtherTableSQL(db, "keyword_ranking_run_datetime"); 
			db.sql&="
			GROUP BY DATE_FORMAT(keyword_ranking_run_datetime, #db.param('%Y-%m')#), keyword_ranking_keyword";
			qFirstRankKeyword=db.execute("qFirstRankKeyword");
			//keyword_ranking_position<>#db.param(0)# and 
			request.leadData.keywordData[sourceID].qFirstRankKeyword=qFirstRankKeyword;

//writedump(qKeywordList);writedump(qFirstRankKeyword);
			for(row in qFirstRankKeyword){
				if(not structkeyexists(ks, row.date)){
					ks[row.date]={};
					for(row2 in qKeywordList){
						ks[row.date][row2.keyword_ranking_keyword]=0;
					}
				}
				if(row.topPosition NEQ 0 and row.topPosition NEQ 1000){
					ks[row.date][row.keyword_ranking_keyword]=row.topPosition;
				} 
				if(not structkeyexists(vs, row.keyword_ranking_keyword)){
					vs[row.keyword_ranking_keyword]=0;
				}
				if(row.highestSearchVolume > vs[row.keyword_ranking_keyword]){
					vs[row.keyword_ranking_keyword]=row.highestSearchVolume;
				}
				if(not structkeyexists(uniqueKeyword, row.keyword_ranking_keyword)){
					uniqueKeyword[row.keyword_ranking_keyword]=true;
					keywordVolumeSortStruct[count]={
						keyword:row.keyword_ranking_keyword,
						volume:vs[row.keyword_ranking_keyword]
					}
				}
				count++;
			} 
		}

		for(row in request.leadData.keywordData[sourceID].qPreviousKeyword){
			if(form.yearToDateLeadLog EQ 0){
				if(not structkeyexists(ks, row.date)){
					ks[row.date]={};
					for(row2 in qKeywordList){
						ks[row.date][row2.keyword_ranking_keyword]=0;
					}
				}
				if(row.topPosition NEQ 0 and row.topPosition NEQ 1000){
					ks[row.date][row.keyword_ranking_keyword]=row.topPosition;
				}
				if(not structkeyexists(vs, row.keyword_ranking_keyword)){
					vs[row.keyword_ranking_keyword]=0;
				}
				if(row.highestSearchVolume > vs[row.keyword_ranking_keyword]){
					vs[row.keyword_ranking_keyword]=row.highestSearchVolume;
				}
			}
			if(not structkeyexists(uniqueKeyword, row.keyword_ranking_keyword)){
				uniqueKeyword[row.keyword_ranking_keyword]=true;
				keywordVolumeSortStruct[count]={
					keyword:row.keyword_ranking_keyword,
					volume:vs[row.keyword_ranking_keyword]
				};
			}
			count++;
		} 
		request.leadData.keywordData[sourceID].arrVolumeSort=structsort(keywordVolumeSortStruct, "numeric", "desc", "volume"); 
		for(date in ks){
			cs=ks[date];
			for(keyword in cs){
				kw[keyword]=true;
			}
		}
		request.leadData.keywordData[sourceID].arrKeyword=[];
		request.leadData.keywordData[sourceID].arrKeywordDate=structkeyarray(ks); 
		if(request.leadData.keywordData[sourceID].qFirstRankKeyword.recordcount NEQ 0 or request.leadData.keywordData[sourceID].qKeyword.recordcount NEQ 0 or request.leadData.keywordData[sourceID].qPreviousKeyword.recordcount NEQ 0){
			arraySort(request.leadData.keywordData[sourceID].arrKeywordDate, "text", "asc");
			keywordSortStruct={};
			ts=ks[request.leadData.keywordData[sourceID].arrKeywordDate[arraylen(request.leadData.keywordData[sourceID].arrKeywordDate)]];
			count=0;
			for(keyword in ts){
				keywordSortStruct[count]={keyword:keyword, position:ts[keyword]};
				if(keywordSortStruct[count].position EQ 0){
					keywordSortStruct[count].position=1000;
				}
				count++; 
			}
			arrKey=structsort(keywordSortStruct, "numeric", "asc", "position");
			for(i in arrKey){
				arrayAppend(request.leadData.keywordData[sourceID].arrKeyword, keywordSortStruct[i].keyword);
			}
		}  
		request.leadData.keywordData[sourceID].keywordDataStruct={ 
			ks:ks,
			vs:vs,
			keywordVolumeSortStruct:keywordVolumeSortStruct 
		}; 
	} 
	</cfscript>

</cffunction>

 
<cffunction name="topVerifiedRankings" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	if(request.leadData.disableContentSection["TopVerifiedRankings"]){
		return;
	}
	ss=arguments.ss;
	ks=arguments.ss.keywordDataStruct.ks;
	</cfscript>  
	<cfif ss.qKeyword.recordcount NEQ 0 or ss.qPreviousKeyword.recordcount NEQ 0>
	
		<cfscript>
		showFooter();  
		request.leadData.contentSection.TopVerifiedRankings=request.leadData.pageCount; 
		</cfscript>
		<cfsavecontent variable="tableHead">  
			<h2 style="margin-top:0px;">Top Verified #arguments.ss.sourceLabel#</h2>
			<table class="keywordTable1 leadTable1">
				<tr>
					<th style="width:1%; white-space:nowrap;">Keyword</th>
					<cfscript>
					for(date in ss.arrKeywordDate){ 
						if(isValidMonth(date) and isValidKeywordMonth(date)){
							echo('<th>#dateformat(date, "mmm yyyy")#</th>'); 
						}
					}
					</cfscript>
					<!--- <th>Search Volume</th> --->
				</tr>
		</cfsavecontent>
			<cfscript> 
			echo(tableHead);
			count=0;
			// need to implement page breaks here..
			for(i=1;i LTE arrayLen(ss.arrKeyword);i++){
				keyword=ss.arrKeyword[i];
				if(count > request.leadData.rowLimit){
					if(structkeyexists(form, 'print')){
						echo('</table>');
						showFooter();
						echo(tableHead);
					}else{
						request.leadData.pageCount++; if(request.zos.isdeveloper and structkeyexists(form, 'debugpage')){ echo('page: #request.leadData.pageCount#<br>'); }
					}
					count=0;
				}
				topKeyword=false;
				savecontent variable="keyOut"{
					echo('<tr>');
					echo('<th style="width:1%; white-space:nowrap;" data-id="##">#keyword#</th>');
					for(n=1;n<=arrayLen(ss.arrKeywordDate);n++){
						date=ss.arrKeywordDate[n];
						if(not isValidMonth(date) or not isValidKeywordMonth(date)){
							continue;
						}
						if(structkeyexists(ks, date) and structkeyexists(ks[date], keyword)){
							position=ks[date][keyword];
							if(position EQ 0){
								position=1000;
							}
							if(arrayLen(ss.arrKeywordDate) EQ n){
								if(position<51){
									topKeyword=true;
								}
								if(position < 6){
									className="topFiveColor";
								}else if(position < 11){
								 	className="topTenColor";
								}else if(position < 21){
									className="topTwentyColor";
								}else if(position <51){
									className="topFiftyColor";
								}else{
									echo('<td>&nbsp;</td>');// style="background-color:##CCC;"
									continue;
								}
							}else{ 
								className="";
							}
							if(position EQ 1000 or position EQ 0){ 
								echo('<td>&nbsp;</td>');// style="background-color:##CCC;"
							}else{
								echo('<td class="#className#">#numberformat(position)#</td>');
							}
						}else{
							echo('<td>&nbsp;</td>');// style="background-color:##CCC;"
						}
					}
					// need to get this from manual data entry
					//echo('<td>#vs[keyword]#</td>');
					echo('</tr>');
				}
				if(topKeyword){
					echo(keyOut);
					count++;
				}
			}
			</cfscript>
		</table> 
		<cfscript>
		if(count>request.leadData.rowLimit-7){ 
			showFooter(); 
			echo('<h2 style="margin-top:0px;">Top Verified Keyword Google Rankings</h2>');
			count=0;
		}
		</cfscript>
		<div style="width:100%; float:left;">
			<div style="padding:10px; margin-right:20px; border:1px solid ##000; float:left; white-space:nowrap; margin-bottom:20px;" class="topFiveColor">Top Five (1st Page)</div> 
			<div style="padding:10px; margin-right:20px; border:1px solid ##000; float:left; white-space:nowrap; margin-bottom:20px;" class="topTenColor">Top Ten (1st Page)</div>  
			<div style="padding:10px; margin-right:20px; border:1px solid ##000; float:left; white-space:nowrap; margin-bottom:20px;" class="topTwentyColor">Top Twenty (2nd Page)</div> 
			<div style="padding:10px; margin-right:20px; border:1px solid ##000; float:left; white-space:nowrap; margin-bottom:20px;" class="topFiftyColor">Top 50</div>  
		</div>
		<p>This is your current ranking position for your targeted keywords on Google Search. Page rankings 1 through 10 appear on the first results page, 11 through 20 on the second, etc. Our goal is first page placement for all of your targeted keywords.  Search volume varies over time.</p> 

	</cfif>
</cffunction>
<cffunction name="verifiedRankings" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	if(request.leadData.disableContentSection["VerifiedRankings"] and arrayLen(ss.arrVolumeSort)){
		return;
	}
	ss=arguments.ss;
	ks=arguments.ss.keywordDataStruct.ks;
	vs=arguments.ss.keywordDataStruct.vs;
	keywordVolumeSortStruct=arguments.ss.keywordDataStruct.keywordVolumeSortStruct;
	</cfscript> 
	<cfsavecontent variable="tableHead">  
		<h2 style="margin-top:0px;">Verified <!--- Google Keyword Ranking Results --->#arguments.ss.sourceLabel#</h2>
		<table class="keywordTable1 leadTable1">
			<tr>
				<th style="width:1%; white-space:nowrap;">Keyword</th>
				<cfscript>
				for(date in ss.arrKeywordDate){
					if(isValidMonth(date) and isValidKeywordMonth(date)){
						echo('<th>#dateformat(date, "mmm yyyy")#</th>');
					}
				}
				</cfscript>
				<th>Search Volume</th>
			</tr>
	</cfsavecontent>
	<cfscript> 
	showFooter();  
	echo(tableHead);
	request.leadData.contentSection.VerifiedRankings=request.leadData.pageCount;  
	count=0;
	// need to implement page breaks here..
	for(i=1;i LTE arrayLen(ss.arrVolumeSort);i++){
		keyword=keywordVolumeSortStruct[ss.arrVolumeSort[i]].keyword;
		if(count > request.leadData.rowLimit){
			if(structkeyexists(form, 'print')){
				echo('</table>');
				showFooter();
				echo(tableHead);
			}else{
				request.leadData.pageCount++; if(request.zos.isdeveloper and structkeyexists(form, 'debugpage')){ echo('page: #request.leadData.pageCount#<br>'); }
			}
			count=0;
		}
		echo('<tr>');
		echo('<th style="width:1%; white-space:nowrap;">#keyword#</th>');
		for(n=1;n<=arrayLen(ss.arrKeywordDate);n++){
			date=ss.arrKeywordDate[n];
			if(not isValidMonth(date) or not isValidKeywordMonth(date)){	
				continue;
			}
			if(structkeyexists(ks, date) and structkeyexists(ks[date], keyword)){
				position=ks[date][keyword];
				if(position EQ 0){
					position=1000;
				} 
				if(position EQ 1000 or position EQ 0){ 
					echo('<td >&nbsp;</td>');//style="background-color:##CCC;"
				}else{
					echo('<td>#numberformat(position)#</td>');
				}
			}else{
				echo('<td>&nbsp;</td>'); //  style="background-color:##CCC;"
			}
		}
		// need to get this from manual data entry
		echo('<td>#numberformat(keywordVolumeSortStruct[ss.arrVolumeSort[i]].volume)#</td>');
		echo('</tr>');
		count++;
	}
	</cfscript>
	</table>   
</cffunction>
<cffunction name="incomingOrganic" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	if(request.leadData.disableContentSection["OrganicSearch"]){
		return;
	}
	</cfscript>
	<cfscript> 

	db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	ga_month_type=#db.param(2)# and 
	ga_month_deleted=#db.param(0)# and ";
	if(form.yearToDateLeadLog EQ 1 or form.yearToDateLeadLog EQ 2){
		db.sql&=" ga_month_date>=#db.param(dateformat(dateadd("yyyy", -1, request.leadData.endDate), "yyyy-mm-dd"))# and ";
	}else{
		db.sql&=" ga_month_date>=#db.param(dateformat(dateadd("m", -1, request.leadData.endDate), "yyyy-mm-dd"))# and ";
	}
	db.sql&=" ga_month_date<#db.param(request.leadData.endDate)# ";
	filterOtherTableSQL(db, "ga_month_date"); 
	qOrganicTraffic=db.execute("qOrganicTraffic");  
 
	db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	ga_month_type=#db.param(2)# and 
	ga_month_deleted=#db.param(0)# and ";
	if(form.yearToDateLeadLog EQ 1 or form.yearToDateLeadLog EQ 2){
		db.sql&=" ga_month_date>=#db.param(dateformat(dateadd("yyyy", -2, request.leadData.endDate), "yyyy-mm-dd"))# and
		ga_month_date<#db.param(dateformat(dateadd("yyyy", -1, request.leadData.endDate), "yyyy-mm-dd"))#  ";
	}else{
		db.sql&=" ga_month_date>=#db.param(dateformat(dateadd("yyyy", -1, dateadd("m", -1, request.leadData.endDate)), "yyyy-mm-dd"))# and  
		ga_month_date<#db.param(dateformat(dateadd("yyyy", -1, request.leadData.endDate), "yyyy-mm-dd"))#";
	}  
	qPreviousOrganicTraffic=db.execute("qPreviousOrganicTraffic");  

	db.sql="select * from #db.table("ga_month_keyword", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	ga_month_keyword_deleted=#db.param(0)# and ";
	if(form.yearToDateLeadLog EQ 1 or form.yearToDateLeadLog EQ 2){
		db.sql&=" ga_month_keyword_date>=#db.param(dateformat(dateadd("yyyy", -1, request.leadData.endDate), "yyyy-mm-dd"))# and ";
	}else{
		db.sql&=" ga_month_keyword_date>=#db.param(dateformat(dateadd("m", -1, request.leadData.endDate), "yyyy-mm-dd"))# and ";
	}
	db.sql&="
	ga_month_keyword_date<#db.param(request.leadData.endDate)# ";
	filterOtherTableSQL(db, "ga_month_keyword_date");
	request.leadData.qKeyword=db.execute("qKeyword"); 

	db.sql="select * from #db.table("ga_month_keyword", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	ga_month_keyword_deleted=#db.param(0)# and ";
	if(form.yearToDateLeadLog EQ 1 or form.yearToDateLeadLog EQ 2){
		db.sql&=" ga_month_keyword_date>=#db.param(dateformat(dateadd("yyyy", -2, request.leadData.endDate), "yyyy-mm-dd"))# and ";
	}else{
		db.sql&=" ga_month_keyword_date>=#db.param(dateformat(dateadd("yyyy", -1, dateadd("m", -1, request.leadData.endDate)), "yyyy-mm-dd"))# and  ";
	}
	db.sql&="
	ga_month_keyword_date<#db.param(dateformat(dateadd("yyyy", -1, request.leadData.endDate), "yyyy-mm-dd"))# ";  
	filterOtherTableSQL(db, "ga_month_keyword_date");
	request.leadData.qPreviousKeyword=db.execute("qPreviousKeyword"); 
	ks={};
	ksp={};
	count=0; 
	arrExcludeList=listToArray(request.leadData.qSite.site_google_analytics_exclude_keyword_list, ",");
	arrayAppend(arrExcludeList, '(not provided)');
	arrayAppend(arrExcludeList, '(not set)');
	arrayAppend(arrExcludeList, 'sharebutton');
	for(row in request.leadData.qKeyword){
		count++;
		skip=false;
		for(phrase in arrExcludeList){
			if(row.ga_month_keyword_keyword CONTAINS phrase){
				skip=true;
				break;
			}
		}
		if(skip){
			continue;
		}
		ts={
			visits:row.ga_month_keyword_visits, 
			keyword:row.ga_month_keyword_keyword 
		}; 
		ks[count]=ts;
	} 
	count=0;
	for(row in request.leadData.qPreviousKeyword){
		count++;
		skip=false;
		for(phrase in arrExcludeList){
			if(row.ga_month_keyword_keyword CONTAINS phrase){
				skip=true;
				break;
			}
		}
		if(skip){
			continue;
		}
		ts={
			visits:row.ga_month_keyword_visits, 
			keyword:row.ga_month_keyword_keyword 
		}; 
		ksp[count]=ts;
	}  
	request.leadData.arrKeywordSort=structsort(ks, "numeric", "desc", "visits");  
	arrPreviousKeywordSort=structsort(ksp, "numeric", "desc", "visits");  
	</cfscript> 
	<cfif request.leadData.qKeyword.recordcount or request.leadData.qPreviousKeyword.recordcount> 
		<cfscript>
		showFooter(); 
		request.leadData.contentSection.OrganicSearch=request.leadData.pageCount; 
		</cfscript>

		<h2 style="margin-top:0px;">Incoming Organic Search Traffic</h2>
		<cfscript> 

		/*db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		ga_month_type=#db.param(2)# and 
		ga_month_deleted=#db.param(0)# and 
		ga_month_date>=#db.param(dateformat(dateadd("m", -2, request.leadData.endDate), "yyyy-mm-dd"))# and 
		ga_month_date<#db.param(dateformat(dateadd("m", -1, request.leadData.endDate), "yyyy-mm-dd"))# ";  
		qPreviousMonthOrganicTraffic=db.execute("qPreviousMonthOrganicTraffic");  */ 
		db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		ga_month_type=#db.param(2)# and 
		ga_month_deleted=#db.param(0)# and 
		ga_month_date>=#db.param(dateformat(dateadd("yyyy", -1, request.leadData.endDate), "yyyy-mm-dd"))# and 
		ga_month_date<#db.param(request.leadData.endDate)# ";
		filterOtherTableSQL(db, "ga_month_date");
		db.sql&=" 
		ORDER BY ga_month_date ASC";  
		qOrganicTrafficAnnual=db.execute("qOrganicTrafficAnnual");   
		echo('<p>This data includes traffic from Google, Bing, Yahoo and other search engines.</p>');
		echo('<h3>Visits by Month This Year</h3>');
		echo('<table class="leadTable1 organicTrafficChart">');
		echo('<tr>');
		for(row in qOrganicTrafficAnnual){
			if(isValidMonth(row.ga_month_date)){	
			echo('<td>#dateformat(row.ga_month_date, "mmm yy")#</td>');
			}

		}
		echo('</tr>');
		echo('<tr>');
		for(row in qOrganicTrafficAnnual){
			if(isValidMonth(row.ga_month_date)){	
				echo('<td>#numberformat(row.ga_month_visits)#</td>');
			}

		}
		echo('</tr>');
		echo('</table>');


		db.sql="select * from #db.table("ga_month", request.zos.zcoreDatasource)# 
		WHERE site_id = #db.param(request.zos.globals.id)# and 
		ga_month_type=#db.param(2)# and 
		ga_month_deleted=#db.param(0)# and 
		ga_month_date>=#db.param(dateformat(dateadd("yyyy", -2, request.leadData.endDate), "yyyy-mm-dd"))# and 
		ga_month_date<#db.param(dateformat(dateadd("yyyy", -1, request.leadData.endDate), "yyyy-mm-dd"))#  ";
		filterOtherTableSQL(db, "ga_month_date");
		db.sql&=" 
		ORDER BY ga_month_date ASC";  
		qOrganicTrafficAnnual2=db.execute("qOrganicTrafficAnnual");  

		echo('<h3>Visits by Month Last Year</h3>');
		echo('<table class="leadTable1 organicTrafficChart">');
		echo('<tr>');
		for(row in qOrganicTrafficAnnual2){
			if(isValidMonth(row.ga_month_date)){	
				echo('<td>#dateformat(row.ga_month_date, "mmm yy")#</td>');
			}

		}
		echo('</tr>');
		echo('<tr>');
		for(row in qOrganicTrafficAnnual2){
			if(isValidMonth(row.ga_month_date)){	
				echo('<td>#numberformat(row.ga_month_visits)#</td>');
			}

		}
		echo('</tr>');
		echo('</table>');
		</cfscript>
		<div style=" ">
			<div style="width:50%; padding-right:5%; float:left;">
				<h3>
					<cfif form.yearToDateLeadLog EQ 2>
						#dateformat(request.leadData.startDate, "mmmm yyyy")# to #dateformat(dateadd("m", -1, request.leadData.endDate), "mmmm yyyy")#
					<cfelseif form.yearToDateLeadLog EQ 1>
						Jan to #dateformat(dateadd("m", -1, request.leadData.previousEndDate), "mmm yyyy")# -
					<cfelse>
						#dateformat(request.leadData.previousStartMonthDate, "mmmm yyyy")# - 
					</cfif>

				<cfif qPreviousOrganicTraffic.recordcount>
					<cfscript>
					visits=0;
					for(row in qPreviousOrganicTraffic){
						visits+=qPreviousOrganicTraffic.ga_month_visits;
					}
					</cfscript>
					#numberformat(visits)#
				<cfelse>
					0
				</cfif> Visits</h3>
			</div>
			<div style="width:50%;padding-right:5%; float:left;">
				<h3>
					
					<cfif form.yearToDateLeadLog EQ 2>
						#dateformat(request.leadData.startDate, "mmmm yyyy")# to #dateformat(dateadd("m", -1, request.leadData.endDate), "mmmm yyyy")#
					<cfelseif form.yearToDateLeadLog EQ 1>
						Jan to #dateformat(dateadd("m", -1, request.leadData.endDate), "mmm yyyy")# -
					<cfelse>
						#dateformat(request.leadData.startMonthDate, "mmmm yyyy")# - 
					</cfif>
				<cfif qOrganicTraffic.recordcount>
					<cfscript>
					visits=0;
					for(row in qOrganicTraffic){
						visits+=qOrganicTraffic.ga_month_visits;
					}
					</cfscript>
					#numberformat(visits)# 
				<cfelse>
					0
				</cfif> Visits</h3>
			</div>
		</div>

<!--- 
		<h3>Top 10 Google Keywords Generating Website Traffic</h3>
		<div style=" ">
			<div style="width:50%; padding-right:5%; float:left;">
				<table class="keywordTable1 leadTable1">
					<tr>
						<th style="width:1%; white-space:nowrap;">&nbsp;</th> 
						<th >Google Keyword Phrase</th>   
					</tr>
					<cfscript>
					for(i=1;i<=min(10, arraylen(arrPreviousKeywordSort));i++){
						ts=ksp[arrPreviousKeywordSort[i]];
						echo('<tr><td>#i#</td><td>#application.zcore.functions.zLimitStringLength(ts.keyword, 50)#</td></tr>');
					}
					</cfscript>
				</table>
			</div>
			<div style="width:50%;padding-right:5%; float:left;">
				<table class="keywordTable1 leadTable1">
					<tr>
						<th style="width:1%; white-space:nowrap;">&nbsp;</th> 
						<th >Google Keyword Phrase</th>   
					</tr>
					<cfscript>
					for(i=1;i<=min(10, arraylen(request.leadData.arrKeywordSort));i++){
						ts=ks[request.leadData.arrKeywordSort[i]];
						echo('<tr><td>#i#</td><td>#application.zcore.functions.zLimitStringLength(ts.keyword, 50)#</td></tr>');
					}
					</cfscript>
				</table>
			</div>
		</div>   --->
		<!--- <p>These are the top keyword searches on Google that led visitors to your website in the month of #dateformat(form.selectedMonth, "mmmm yyyy")# not including your name or company name.</p> --->

		<cfscript>
		if(qPreviousOrganicTraffic.recordcount and qOrganicTraffic.recordcount){
			if(isValidMonth(qPreviousOrganicTraffic.ga_month_date)){	
				v=round(((qOrganicTraffic.ga_month_visits-qPreviousOrganicTraffic.ga_month_visits)/qPreviousOrganicTraffic.ga_month_visits)*100);
				if(v>0){
					echo('<p style="font-weight:bold;">'&v&'% increase in organic traffic year over year</p>'); 
				}
			}
		}
		/*if(qPreviousMonthOrganicTraffic.recordcount and qPreviousMonthOrganicTraffic.recordcount){
			v=round(((qOrganicTrafficAnnual.ga_month_visits[qOrganicTrafficAnnual.recordcount]-qPreviousMonthOrganicTraffic.ga_month_visits)/qPreviousMonthOrganicTraffic.ga_month_visits)*100);
			if(v>0){
				echo('<p style="font-weight:bold;">'&v&'% increase in organic traffic this month</p>'); 
			}
		}*/
		</cfscript>
	</cfif>
</cffunction>
<cffunction name="leadSummaryByTypeData" localmode="modern" access="public">

	<cfscript>
	db=request.zos.queryObject;
	webFormOut="";
	phoneLogOut=""; 
	db.sql="SELECT 
	*
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE 
	inquiries_final_inquiries_id=#db.param(0)# and 
	inquiries_datetime>=#db.param(request.leadData.startMonthDate)# and 
	inquiries_datetime<#db.param(request.leadData.endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	inquiries_type_id=#db.param(request.leadData.phoneMonthStruct.inquiries_type_id)# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(request.leadData.phoneMonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#"; 
	filterInquiryTableSQL(db);
	db.sql&="
	ORDER BY inquiries_datetime ASC ";
	request.leadData.qPhone=db.execute("qPhone");

  
	db.sql="SELECT 
	*, track_user_referer, track_user_source, track_user_first_page
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	LEFT JOIN #db.table("track_user", request.zos.zcoreDatasource)# ON 
	track_user.site_id = inquiries.site_id and 
	track_user.inquiries_id = inquiries.inquiries_id and 
	track_user_deleted=#db.param(0)# 
	WHERE 
	inquiries_final_inquiries_id=#db.param(0)# and 
	inquiries_datetime>=#db.param(request.leadData.startMonthDate)# and 
	inquiries_datetime<#db.param(request.leadData.endDate)# and 
	inquiries_deleted=#db.param(0)# and  
	concat(inquiries_type_id, #db.param('-')#, inquiries_type_id_siteIDType) <> 
	#db.param(request.leadData.phoneMonthStruct.inquiries_type_id&'-'&application.zcore.functions.zGetSiteIdType(request.leadData.phoneMonthStruct.site_id))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#"; 
	filterInquiryTableSQL(db);
	db.sql&="
	ORDER BY inquiries_datetime ASC ";
	request.leadData.qWebLead=db.execute("qWebLead");
	request.leadData.phoneGroup={};
	request.leadData.phoneGroupOffset={};
	request.leadData.webFormGroup={};
	request.leadData.webFormGroupOffset={};
	count=0;
	hasData=false;
	for(row in request.leadData.qPhone){
		js=deserializeJson(row.inquiries_custom_json);
		fs={
			"name":"",
			"Phone 1":"",
			"source":"",
			"city":"",
			"tracking_label":"",
			"called_at":""
		};
		for(field in js.arrCustom){
			fs[field.label]=field.value;
		}
		label=application.zcore.functions.zLimitStringLength(fs.tracking_label, 60);
		source=application.zcore.functions.zLimitStringLength(fs.source, 60);
		if(label EQ ""){
			label=source;
		}
		if(not structkeyexists(request.leadData.phoneGroupOffset, label)){
			request.leadData.phoneGroupOffset[label]=count;
			request.leadData.phoneGroup[count]={
				label:label, 
				count:0
			};
		}
		request.leadData.phoneGroup[request.leadData.phoneGroupOffset[label]].count++;
		count++;
		hasData=true;
	}

	count=0;
	for(row in request.leadData.qWebLead){
		v=row.inquiries_type_id_siteIDType&"-"&row.inquiries_type_id;
		if(structkeyexists(request.leadData.typeLookup, v)){
			inquiries_type_name=request.leadData.typeLookup[v];
		
			if(not structkeyexists(request.leadData.webFormGroupOffset, inquiries_type_name)){
				request.leadData.webFormGroupOffset[inquiries_type_name]=count;
				request.leadData.webFormGroup[count]={
					label:inquiries_type_name,
					count:0
				};
			}
			request.leadData.webFormGroup[request.leadData.webFormGroupOffset[inquiries_type_name]].count++;
		}else{
			if(not structkeyexists(request.leadData.webFormGroupOffset, "(No Label)")){
				request.leadData.webFormGroupOffset["(No Label)"]=count;
				request.leadData.webFormGroup[count]={
					label:"(No Label)",
					count:0
				}
			}
			request.leadData.webFormGroup[request.leadData.webFormGroupOffset["(No Label)"]].count++;
		}
		count++;
		hasData=true;
	}
	request.leadData.footerSummaryOut="";
	if(hasData){
		if(not request.leadData.disableContentSection["leadTypeSummary"]){
			//request.leadData.pageCount++; if(request.zos.isdeveloper and structkeyexists(form, 'debugpage')){ echo('page: #request.leadData.pageCount#<br>'); }
			savecontent variable="request.leadData.footerSummaryOut"{
				showFooter();
				request.leadData.contentSection.leadTypeSummary=request.leadData.pageCount; 
			}
		}
	}
	</cfscript>
</cffunction>
<cffunction name="phoneCallLog" localmode="modern" access="public">
	
	<cfscript>
	db=request.zos.queryObject;
	if(request.leadData.disableContentSection["PhoneLog"]){
		return "";
	}
	</cfscript>

	<cfsavecontent variable="phoneLogOut">
		<cfif request.leadData.qPhone.recordcount>  
			
			<cfsavecontent variable="tableHead">
				<cfif form.yearToDateLeadLog EQ 2> 
					<h2 style="margin-top:0px;">#dateformat(request.leadData.startMonthDate, "mmmm yyyy")# to #dateformat(dateadd("m", -1, request.leadData.endDate), "mmmm yyyy")# Phone Call Log</h2>
				<cfelseif form.yearToDateLeadLog EQ 1>
					<h2 style="margin-top:0px;">#dateformat(request.leadData.startMonthDate, "mmmm")# to #dateformat(dateadd("m", -1, request.leadData.endDate), "mmmm yyyy")# Phone Call Log</h2>
				<cfelse>  
					<h2 style="margin-top:0px;">#dateformat(request.leadData.startMonthDate, "mmmm yyyy")# Phone Call Log</h2>
				</cfif>
				<table class="leadTable1">
					<tr>
						<th style="width:1%; white-space:nowrap;">Caller ID</th>
						<th>Customer ##</th>
						<th>City</th>
						<th>Date</th>
						<th>Label / Referrer</th>
						<!--- <th>Source</th> --->
					</tr>
			</cfsavecontent>
			<cfscript>
			showFooter(); 
			request.leadData.contentSection.PhoneLog=request.leadData.pageCount;  
			rowCount=0;
			echo(tableHead);
			for(row in request.leadData.qPhone){
				if(rowCount > request.leadData.rowLimit){
					if(structkeyexists(form, 'print')){
						echo('</table>');

						showFooter();
						echo(tableHead);
					}else{
						request.leadData.pageCount++; if(request.zos.isdeveloper and structkeyexists(form, 'debugpage')){ echo('page: #request.leadData.pageCount#<br>'); }
					}
					rowCount=0;
				}
				js=deserializeJson(row.inquiries_custom_json);
				referrer="";
				fs={
					"name":"",
					"Phone 1":"",
					"source":"",
					"city":"",
					"tracking_label":"",
					"called_at":"",
					"referrer":""
				};
				for(field in js.arrCustom){
					fs[field.label]=field.value;
				}
				if(fs.referrer NEQ ""){
					referrer=application.zcore.functions.zLimitStringLength(fs.referrer, 30);
				}
				//echo('</table>');
				if(fs["Phone 1"] EQ ""){
					fs["Phone 1"]=row.inquiries_phone1;
				}
				label=application.zcore.functions.zLimitStringLength(fs.tracking_label&" / "&referrer, 60); 
				/*writedump(row);
				writedump(js);
				break;*/
				// Phone 1
				echo('<tr>
					<td style="width:1%; white-space:nowrap;">#fs.Name#</td>
					<td>#fs["Phone 1"]#</td>
					<td>#fs.city#</td>
					<td>#dateformat(row.inquiries_datetime, "m/d/yyyy")#</td>
					<td>#label#</td>
					
				</tr>'); 

				rowCount++;
			}
			</cfscript>
			</table> 
		</cfif> 
	</cfsavecontent> 
	<cfscript>
	return phoneLogOut;
	</cfscript>

</cffunction>

<cffunction name="webformLog" localmode="modern" access="public">
	
	<cfscript>
	db=request.zos.queryObject;
	if(request.leadData.disableContentSection["WebLeadLog"]){
		return "";
	}
	</cfscript>
	<cfsavecontent variable="webFormOut">
	
		<cfif request.leadData.qWebLead.recordcount> 
			<cfsavecontent variable="tableHead">  
				<cfif form.yearToDateLeadLog EQ 2> 
					<h2 style="margin-top:0px;">#dateformat(request.leadData.startMonthDate, "mmmm yyyy")# to #dateformat(dateadd("m", -1, request.leadData.endDate), "mmmm yyyy")# Web Form Log</h2>
				<cfelseif form.yearToDateLeadLog EQ 1>
					<h2 style="margin-top:0px;">#dateformat(request.leadData.startMonthDate, "mmmm")# to #dateformat(dateadd("m", -1, request.leadData.endDate), "mmmm yyyy")# Web Form Log</h2>
				<cfelse>  
					<h2 style="margin-top:0px;">#dateformat(request.leadData.startMonthDate, "mmmm yyyy")# Web Form Log</h2>
				</cfif>

				<table class="leadTable1">
					<tr>
						<th style="width:1%; white-space:nowrap;">Name</th>
						<th>Phone</th>
						<th>Email</th>
						<th>Date</th>
						<th>Type</th>
						<th>Source</th>
					</tr>
			</cfsavecontent>
			<cfscript>
			showFooter();  
			request.leadData.contentSection.WebLeadLog=request.leadData.pageCount; 
			rowCount=0;
			echo(tableHead);
			for(row in request.leadData.qWebLead){
				if(rowCount > request.leadData.rowLimit){
					if(structkeyexists(form, 'print')){
						echo('</table>');

						showFooter();
						echo(tableHead);
					}else{
						request.leadData.pageCount++; if(request.zos.isdeveloper and structkeyexists(form, 'debugpage')){ echo('page: #request.leadData.pageCount#<br>'); }
					}
					rowCount=0;
				} 
				fs["Phone 1"]=""; 
				if(row.inquiries_custom_json NEQ ""){
					js=deserializeJson(row.inquiries_custom_json);
					
					fs={
						"name":"",
						"Phone 1":"",
						"source":"",
						"city":"",
						"tracking_label":"",
						"called_at":""
					};
					for(field in js.arrCustom){
						fs[field.label]=field.value;
					}  
					//echo('</table>');
					if(fs["Phone 1"] EQ ""){
						fs["Phone 1"]=row.inquiries_phone1;
					} 
				}
				v=row.inquiries_type_id_siteIDType&"-"&row.inquiries_type_id;
				if(structkeyexists(request.leadData.typeLookup, v)){
					inquiries_type_name=request.leadData.typeLookup[v];
				}else{
					inquiries_type_name="";
				}
			 
				/*writedump(row);
				writedump(js);
				break;*/
				// Phone 1

				/*
output source:
track_user_source
track_user_first_page

			track_user_referer NOT LIKE #db.param('%doubleclick%')# AND 
			track_user_referer NOT LIKE #db.param('%/aclk%')# AND 
			(track_user_referer LIKE #db.param('%search.%')# OR 
			track_user_referer LIKE #db.param('%google%')# OR 
			track_user_referer LIKE #db.param('%bing%')# OR 
			track_user_referer LIKE #db.param('%android%')# )";
				*/
				source=row.track_user_source;
				if(source EQ ""){
					source="N/A";
				}
				echo('<tr>
					<td style="width:1%; white-space:nowrap;">#row.inquiries_first_name# #row.inquiries_last_name#</td>
					<td>#row.inquiries_phone1#</td>
					<td>#row.inquiries_email#</td>
					<td>#dateformat(row.inquiries_datetime, "m/d/yyyy")#</td>
					<td>#inquiries_type_name#</td>
					<td>#source#</td>
				</tr>');
				rowCount++;
			}
			</cfscript>
			</table>
		</cfif> 
	</cfsavecontent> 
	<cfscript>
	return webFormOut;
	</cfscript>
</cffunction>

<cffunction name="leadSummaryByType" localmode="modern" access="public">
	
	<cfscript>
	db=request.zos.queryObject;
	if(request.leadData.disableContentSection["leadTypeSummary"]){
		return "";
	}
	</cfscript>	
 	<cfsavecontent variable="leadSummaryOut">
 		<cfscript>
		rowCount=0;
		</cfscript> 
		#request.leadData.footerSummaryOut#
		<cfif request.leadData.qPhone.recordcount or request.leadData.qWebLead.recordcount> 
			<h2 style="margin-top:0px;">Lead Summary By Type</h2>
			<cfif request.leadData.qPhone.recordcount>  
				<h3>Phone Calls by <cfif request.leadData.qSite.site_phone_tracking_label_text EQ "">Tracking Label<cfelse>#request.leadData.qSite.site_phone_tracking_label_text#</cfif></h3>
				<cfscript> 
				echo('<table style="font-size:12px;">'); 
				arrGroupSort=structsort(request.leadData.phoneGroup, "numeric", "desc", "count");
				for(i=1;i<=arraylen(arrGroupSort);i++){
					c=request.leadData.phoneGroup[arrGroupSort[i]];
					if(rowCount > 30){
						if(structkeyexists(form, 'print')){
							echo('</table>');

							showFooter();
							echo('<h3>Phone Calls by Tracking Label</h3><table style="font-size:12px;">'); 
						}else{
							request.leadData.pageCount++; if(request.zos.isdeveloper and structkeyexists(form, 'debugpage')){ echo('page: #request.leadData.pageCount#<br>'); }
						}
						rowCount=0;
					}
					echo('<tr><td style="width:1%; white-space:nowrap;">');
					echo(numberformat(c.count));
					echo(' calls</td>');

					if(c.label EQ ""){ 
						echo('<td style=" padding-left:10px;">(No Label)</td>');
					}else{
						echo('<td style=" padding-left:10px;">#c.label#</td>');
					}
					echo('</tr>');
					rowCount++;
				}
				echo('</table>');
				</cfscript>
			</cfif> 
			<cfscript>
			db.sql="SELECT track_user_source, COUNT(track_user_id) `count` 
			FROM #db.table("track_user", request.zos.zcoreDatasource)# 
			WHERE track_user_source<>#db.param('')# AND 
			site_id = #db.param(request.zos.globals.id)#
			AND  
			track_user_deleted=#db.param(0)# and 
			(DATE_FORMAT(track_user_recent_datetime,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(request.leadData.startMonthDate, "yyyy-mm-dd"))# AND 
			DATE_FORMAT(track_user_datetime,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(request.leadData.endDate, "yyyy-mm-dd"))#) 
			GROUP BY track_user_source 
			ORDER BY track_user_source ASC ";
			 qTrack=db.execute("qTrack"); 

			db.sql="SELECT COUNT(track_user_id) `count` 
			FROM #db.table("track_user", request.zos.zcoreDatasource)# 
			WHERE  
			site_id = #db.param(request.zos.globals.id)# 
			AND  
			(DATE_FORMAT(track_user_recent_datetime,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(request.leadData.startMonthDate, "yyyy-mm-dd"))# AND 
			DATE_FORMAT(track_user_datetime,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(request.leadData.endDate, "yyyy-mm-dd"))#)  AND 
			track_user_deleted=#db.param(0)# and 
			track_user_referer NOT LIKE #db.param('%doubleclick%')# AND 
			track_user_referer NOT LIKE #db.param('%/aclk%')# AND 
			(track_user_referer LIKE #db.param('%search.%')# OR 
			track_user_referer LIKE #db.param('%google%')# OR 
			track_user_referer LIKE #db.param('%bing%')# OR 
			track_user_referer LIKE #db.param('%android%')# )";
			 qTrack2=db.execute("qTrack2"); 

			if(qTrack.recordcount NEQ 0){
				echo('
					<br>
				<h3>Web Form Leads By Tracking Label</h3>
				<table style="font-size:12px;">
					<tr>
						<th style="text-align:left;">Label</th>
						<th style="text-align:left;">## of Leads</th>
					</tr>');
				rowCount+=3;
				for(row in qTrack){
					if(row.count NEQ 0){
						echo('<tr>
							<td>#row.track_user_source#</td>
							<td>#row.count#</td>
						</tr>'); 
						rowCount++;
					}
				}
				for(row in qTrack2){
					if(row.count NEQ 0){
						echo('<tr>
							<td>Organic Search</td>
							<td>#row.count#</td>
						</tr>');
						rowCount++;
					}
				}
				echo('</table>');
			}
			</cfscript>
			 
			<cfif request.leadData.qWebLead.recordcount>
				<h3 style="margin-top:30px;">Web Form Leads by Lead Type</h3>
				<cfscript>
				echo('<table style="font-size:12px;">');
				rowCount+=6;
				arrGroupSort=structsort(request.leadData.webFormGroup, "numeric", "desc", "count");
				for(i=1;i<=arraylen(arrGroupSort);i++){
					c=request.leadData.webFormGroup[arrGroupSort[i]]; 
					if(rowCount > 30){
						if(structkeyexists(form, 'print')){
							echo('</table>');

							showFooter();
							echo('<h3>Phone Calls by Tracking Label</h3><table style="font-size:12px;">');
						}else{
							request.leadData.pageCount++; if(request.zos.isdeveloper and structkeyexists(form, 'debugpage')){ echo('page: #request.leadData.pageCount#<br>'); }
						}
						rowCount=0;
					} 
					echo('<tr><td style="width:1%; white-space:nowrap;">');
					echo(numberformat(c.count));
					echo(' leads</td>
					<td style=" padding-left:10px;">#c.label#</td></tr>');
					rowCount++;
				}
				echo('</table>');

				</cfscript>
			</cfif> 
		</cfif>
	</cfsavecontent>
	<cfscript>
	return leadSummaryOut;
	</cfscript>
</cffunction>

<cffunction name="newsletterStats" localmode="modern" access="public">
	
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("newsletter_email", request.zos.zcoreDatasource)# WHERE 
	newsletter_email_sent_datetime>=#db.param(request.leadData.startDate)# and 
	newsletter_email_sent_datetime<#db.param(request.leadData.endDate)# and 
	site_id =#db.param(request.zos.globals.id)# and 
	newsletter_email_deleted=#db.param(0)#  
	ORDER BY newsletter_email_sent_datetime ASC"; 
	qN=db.execute("qN");

	db.sql="select *, DATE_FORMAT(newsletter_month_datetime, #db.param('%Y-%m')#) date  
	from #db.table("newsletter_month", request.zos.zcoreDatasource)# WHERE 
	newsletter_month_datetime>=#db.param(request.leadData.startDate)# and 
	newsletter_month_datetime<#db.param(request.leadData.endDate)# and 
	site_id =#db.param(request.zos.globals.id)# and 
	newsletter_month_deleted=#db.param(0)#  
	GROUP BY DATE_FORMAT(newsletter_month_datetime, #db.param('%Y-%m')#) 
	ORDER BY date ASC 
	";
	qMonth=db.execute("qMonth"); 
	
	if(request.leadData.disableContentSection["newsletterLog"] or (qMonth.recordcount EQ 0 and qN.recordcount EQ 0)){
		return "";
	}

	showFooter();

	rowCount=0;
	request.leadData.contentSection.newsletterLog=request.leadData.pageCount; 
	</cfscript>	
	<h2 id="newsletterStats" style="margin-top:0px;">Email Marketing</h2>

	<cfscript>
	if(qMonth.recordcount NEQ 0){
		rowCount+=8;
		monthStruct={};
		for(row in qMonth){ 
			monthStruct[row.date]=row;
		}
		arrMonth=structkeyarray(monthStruct);
		arraySort(arrMonth, "text", "asc");

		echo('<table class="leadTable1">');
		echo('<tr>');
		echo('<th>&nbsp;</th>');
		for(month in arrMonth){
			echo('<th>#dateformat(month&"-01", "mmm yy")#</th>');
		}
		echo('</tr>');
		echo('<tr>
		<th>Total Subscribers</th>');
		for(month in arrMonth){
			ms=monthStruct[month];
			echo('<td>#numberformat(ms.newsletter_month_total_subscribers)#</td>');
		}
		echo('</tr>');
		echo('<tr>
		<th>New Subscribers</th>');
		for(month in arrMonth){
			ms=monthStruct[month];
			echo('<td>#numberformat(ms.newsletter_month_new_subscribers)#</td>');
		}
		echo('</tr>');
		echo('<tr>
		<th>Unsubscribed</th>');
		for(month in arrMonth){
			ms=monthStruct[month];
			echo('<td>#numberformat(ms.newsletter_month_unsubscribed)#</td>');
		}
		echo('</tr>');
		echo('<tr>
		<th>Bounces</th>');
		for(month in arrMonth){
			ms=monthStruct[month];
			echo('<td>#numberformat(ms.newsletter_month_bounces)#</td>');
		}
		echo('</tr>'); 
		echo('</table>');
		echo('<p>Total subscribers is the number of people on the mailing list at the end of the month excluding anyone who unsubscribed.</p>');
	}
	</cfscript>

	<cfif qN.recordcount>
		<cfscript>
	
		savecontent variable="newsletterHeader"{
			echo(' 
			<h2>Newsletters</h2>
			<table class="leadTable1">
			<tr>
				<th style="width:1%; white-space:nowrap;">Name</th>
				<th>Sent On</th>
				<th>Sent to</th>
				<th>Opens</th>
				<th>Clicks</th>
				<th>Bounces</th>
				<th>Unsubscribes</th>  
			</tr>');
		}
		</cfscript>
	
		<table class="leadTable1">
			<tr>
				<th style="width:1%; white-space:nowrap;">Name</th>
				<th>Sent On</th>
				<th>Sent to</th>
				<th>Opens</th>
				<th>Clicks</th>
				<th>Bounces</th>
				<th>Unsubscribes</th> 
				<!--- <th>Leads</th> Requires links to have zsource=newsletter in url --->
			</tr>
			<cfscript>  
			for(row in qN){
				if(rowCount>32){ 
					if(structkeyexists(form, 'print')){
						echo('</table>');
						showFooter();
						echo(newsletterHeader); 
					}else{
						request.leadData.pageCount++; if(request.zos.isdeveloper and structkeyexists(form, 'debugpage')){ echo('page: #request.leadData.pageCount#<br>'); }
					}
					rowCount=0;
				}
				echo('<tr>
					<td style="width:1%; white-space:nowrap;"><a title="Click to view newsletter" href="#request.zos.interspireEmailDomain#display.php?N=#row.newsletter_email_external_newsletter_id#&forcePreview=1" target="_blank">#row.newsletter_email_name#</a></td>
					<td>#dateformat(row.newsletter_email_sent_datetime, "m/d/yyyy")#</td> 
					<td>#numberformat(row.newsletter_email_sent_count, "_")# emails</td>
					<td>#numberformat(row.newsletter_email_opens, "_")# (#numberformat((row.newsletter_email_opens/row.newsletter_email_sent_count)*100, "_")#%)</td>
					<td>#numberformat(row.newsletter_email_clicks, "_")#</td>
					<td>#numberformat(row.newsletter_email_bounces, "_")#</td>
					<td>#numberformat(row.newsletter_email_unsubscribes, "_")#</td>
				</tr>'); 
				rowCount++;
			} 
			</cfscript> 
		</table>

	</cfif>
	 
</cffunction>

<cffunction name="blogLog" localmode="modern" access="public">
	<cfscript>
	db=request.zos.queryObject;
	// you must have a group by in your query or it may miss rows
	ts=structnew();
	ts.image_library_id_field="blog.blog_image_library_id";
	ts.count = 0; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="select * 
	#db.trustedsql(rs2.select)#
	from #db.table("blog", request.zos.zcoreDatasource)# blog
	#db.trustedsql(rs2.leftJoin)#  
	WHERE
	 blog_datetime>=#db.param(dateformat(request.leadData.startMonthDate,'yyyy-mm-dd')&" 00:00:00")# and 
	blog_datetime<#db.param(dateformat(request.leadData.endDate,'yyyy-mm-dd')&" 00:00:00")# and 
	blog_status <> #db.param(2)# and 
	blog_deleted =#db.param(0)# and 
	blog.site_id=#db.param(request.zos.globals.id)# 
	GROUP BY blog.blog_id
	order by blog_datetime ASC ";
	qArticle=db.execute("qArticle");  
	rowCount=0;
	if(request.leadData.disableContentSection["blogLog"] or qArticle.recordcount EQ 0){
		return "";
	} 
	showFooter();
	request.leadData.contentSection.blogLog=request.leadData.pageCount; 
	savecontent variable="blogHeader"{
		echo('<h2 style="margin-top:0px;">Blog Articles</h2>');
	}
	echo(blogHeader);
	for(row in qArticle){

		link=application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id,row.blog_id,"html",row.blog_title,row.blog_datetime);

		ts =structnew();
		ts.image_library_id=row.blog_image_library_id;
		ts.size="90x70";
		ts.crop=0; 
		ts.offset=0; 
		ts.output=false; 
		ts.limit=1; 
		ts.layoutType='';
		arrImage=application.zcore.imageLibraryCom.displayImages(ts); 

		if(rowCount GTE 30){
			if(structkeyexists(form, 'print')){
				showFooter();
				echo(blogHeader);
			}else{
				request.leadData.pageCount++; if(request.zos.isdeveloper and structkeyexists(form, 'debugpage')){ echo('page: #request.leadData.pageCount#<br>'); }
			}
			rowCount=0; 
		}
		rowCount+=7;
		if(row.blog_unique_name NEQ ''){
			viewlink= application.zcore.functions.zvar('domain')&row.blog_unique_name;
		}else{
			viewlink=application.zcore.functions.zvar('domain')&application.zcore.app.getAppCFC("blog").getBlogLink(application.zcore.app.getAppData("blog").optionStruct.blog_config_url_article_id, row.blog_id,"html",row.blog_title,row.blog_datetime);
		}
		echo('<div style="width:100%; float:left; padding-bottom:20px; border-bottom:1px solid ##999; margin-bottom:20px;">
			<div style="width:100px; min-height:1px; float:left;">');
			if(arrayLen(arrImage)){
				echo('<a href="#viewLink#" target="_blank"><img src="#request.zos.globals.domain##arrImage[1].link#" style="border:none;">');
			}
			echo('</div>
			<div style="width:550px; float:left;">
				<h4><a href="#viewLink#" target="_blank">#row.blog_title#</a></h4>
			</div>
		</div>');
			//	<p>#application.zcore.functions.zLimitStringLength(qArticle.blog_summary, 150)#</p>


	}
	</cfscript>
	
</cffunction>

<cffunction name="facebookLog" localmode="modern" access="public">
	
	<cfscript>
	/*if(not request.zos.isdeveloper){
		return;
	}*/
	arrId=listToArray(application.zcore.functions.zso(request.zos.globals, 'facebookPageIdList'), ",");

	for(i=1;i LTE arraylen(arrId);i++){
		arrId[i]=application.zcore.functions.zescape(arrId[i]);
	}
	pageIdList=arrayToList(arrId, ",");
	if(pageIdList EQ ""){
		return "";
	}
	db=request.zos.queryObject;

	db.sql="select * from #db.table("facebook_page", request.zos.zcoreDatasource)# WHERE  
	facebook_page_external_id IN (#db.param(pageIdList)#) and 
	facebook_page_deleted=#db.param(0)#   ";
	qPost=db.execute("qPost"); 
	arrIdNew=[];
	for(row in qPost){
		arrayAppend(arrIdNew, row.facebook_page_id);
	}
	pageInternalIdList=arrayToList(arrIdNew, ",");


	db.sql="select * from #db.table("facebook_post", request.zos.zcoreDatasource)# WHERE 
	facebook_post_created_datetime>=#db.param(request.leadData.startMonthDate)# and 
	facebook_post_created_datetime<#db.param(request.leadData.endDate)# and 
	facebook_page_id IN (#db.param(pageInternalIdList)#) and 
	facebook_post_deleted=#db.param(0)#  
	ORDER BY facebook_post_reach DESC 
	LIMIT #db.param(0)#, #db.param(5)#";
	qN=db.execute("qN"); 

	db.sql="select * from #db.table("facebook_month", request.zos.zcoreDatasource)# WHERE 
	facebook_month_datetime>=#db.param(request.leadData.startDate)# and 
	facebook_month_datetime<#db.param(request.leadData.endDate)# and 
	site_id =#db.param(request.zos.globals.id)# and 
	facebook_month_deleted=#db.param(0)#  
	ORDER BY facebook_month_datetime ASC  ";
	qMonth=db.execute("qMonth");  
	

	db.sql="select * from #db.table("facebook_month", request.zos.zcoreDatasource)# WHERE "; 
	if(form.yearToDateLeadLog EQ 1 or form.yearToDateLeadLog EQ 2){
		db.sql&=" site_id = #db.param(0)# and ";
	}else{
		db.sql&=" facebook_month_datetime>=#db.param(dateformat(dateadd("yyyy", -1, dateadd("m", -1, request.leadData.endDate)), "yyyy-mm-dd"))# and 
		facebook_month_datetime<#db.param(dateformat(dateadd("yyyy", -1, dateadd("d", -1, request.leadData.endDate)), "yyyy-mm-dd"))# and ";
	}
	db.sql&=" site_id =#db.param(request.zos.globals.id)# and 
	facebook_month_deleted=#db.param(0)#  
	ORDER BY facebook_month_datetime ASC 
	LIMIT #db.param(0)#, #db.param(1)# ";
	qMonthPreviousYear=db.execute("qMonthPreviousYear");    

	db.sql="select * from #db.table("facebook_month", request.zos.zcoreDatasource)# WHERE ";  
	db.sql&=" facebook_month_datetime>=#db.param(dateformat(dateadd("yyyy", -1, dateadd("d", -1, request.leadData.endDate)), "yyyy-mm-01"))# and 
		facebook_month_datetime<=#db.param(request.leadData.startMonthDate)# and "; 
	db.sql&=" site_id =#db.param(request.zos.globals.id)# and 
	facebook_month_deleted=#db.param(0)#  
	ORDER BY facebook_month_datetime ASC  ";
	qMonthChart=db.execute("qMonthChart");   


	
	// build json for the javascript line chart
	js=[];
	jsReach=[];
	for(row in qMonthChart){
		ts={
			date:dateformat(row.facebook_month_datetime, "mm/dd/yyyy"),
			close: row.facebook_month_fans
		};
		arrayAppend(js, ts); 
		ts={
			date:dateformat(row.facebook_month_datetime, "mm/dd/yyyy"),
			close: row.facebook_month_reach
		};
		arrayAppend(jsReach, ts); 
	}
	
	//writedump(qmonthchart);
	
	if(request.leadData.disableContentSection["facebookLog"] or (qMonth.recordcount EQ 0 and qN.recordcount EQ 0)){
		return "";
	} 
	showFooter();
	request.leadData.contentSection.facebookLog=request.leadData.pageCount; 
	request.leadData.contentSection.facebookReach=request.leadData.pageCount; 
	</cfscript>	
 
	<cfif arrayLen(js) NEQ 0> 
		<h2 style="margin-top:0px;">Facebook Fans</h2>  
		<div style="float:left; width:100%;">
		<svg data-json-vertical-label="Facebook Fans" data-chart-area-color="0044af" data-jsondata="#htmleditformat(serializeJson(js))#" width="680" height="230"></svg> 
		</div>

		<cfif not request.leadData.disableContentSection["facebookReach"]>
			<h2 style="margin-top:0px;">Facebook Reach</h2>  
			<div style="float:left; width:100%;">
			<svg data-json-vertical-label="Facebook Reach" data-chart-area-color="d6610c" data-jsondata="#htmleditformat(serializeJson(jsReach))#" width="680" height="230"></svg> 
			</div>
		</cfif>
	</cfif>
	<!--- <div style="float:left; width:100%;">
	<svg data-json-vertical-label="Facebook Likes" data-jsondata="#htmleditformat(serializeJson(chartData))#" width="680" height="230"></svg>
	</div>
	<div style="float:left; width:100%;">
	<svg data-json-vertical-label="Facebook Reach" data-jsondata="#htmleditformat(serializeJson(chartData))#" width="680" height="230"></svg>
	</div> --->
	<h2>Facebook Marketing This Month</h2> 
 
	<cfscript>
	/*if(request.zos.isdeveloper){
		writedump(qMonthChart);
		abort;
	}*/
	echo('<table class="leadTable1">');
	echo('<tr><th>&nbsp;</th>');

	if(form.facebookQuarters){
		n=1;
		for(row in qMonthChart){ 
			if(n MOD 4 EQ 1){
				echo('<th>#dateformat(row.facebook_month_datetime, "mmmm yyyy")#</th>');
			}
			n++;
		}
	}else{
		for(row in qMonthPreviousYear){ 
			echo('<th>#dateformat(row.facebook_month_datetime, "mmmm yyyy")#</th>');
		}
		for(row in qMonth){ 
			echo('<th>#dateformat(row.facebook_month_datetime, "mmmm yyyy")#</th>');
		}
	}
	echo('</tr>');
	echo('<tr><th>Total Fans</th>');
	if(form.facebookQuarters){
		n=1;
		for(row in qMonthChart){ 
			if(n MOD 4 EQ 1){
				echo('<td>#numberformat(row.facebook_month_fans, "_")#</td>');
			}
			n++;
		}
	}else{
		for(row in qMonthPreviousYear){ 
	  		echo('<td>#numberformat(row.facebook_month_fans, "_")#</td>');
	  	}
		for(row in qMonth){ 
  			echo('<td>#numberformat(row.facebook_month_fans, "_")#</td>');
  		}
  	}
	echo('</tr>');
	echo('<tr><th>Likes</th>');
	if(form.facebookQuarters){
		n=1;
		for(row in qMonthChart){ 
			if(n MOD 4 EQ 1){
				echo('<td>#numberformat(row.facebook_month_paid_likes+row.facebook_month_organic_likes, "_")#</td>');
			}
			n++;
		}
	}else{
		for(row in qMonthPreviousYear){ 
	  		echo('<td>#numberformat(row.facebook_month_paid_likes+row.facebook_month_organic_likes, "_")#</td>');
	  	}
		for(row in qMonth){ 
  			echo('<td>#numberformat(row.facebook_month_paid_likes+row.facebook_month_organic_likes, "_")#</td>');
  		}
  	}
	echo('</tr>'); 

	if(not request.leadData.disableContentSection["facebookReach"]){
		//echo('<tr><th>Unlikes</th><td>#numberformat(row.facebook_month_unlikes, "_")#</td></tr>');
		echo('<tr><th style="white-space:nowrap; width:1%;">Page Reach</th>');
		if(form.facebookQuarters){
			n=1;
			for(row in qMonthChart){ 
				if(n MOD 4 EQ 1){
					echo('<td>#numberformat(row.facebook_month_reach, "_")#</td>');
				}
				n++;
			}
		}else{
			for(row in qMonthPreviousYear){ 
				echo('<td>#numberformat(row.facebook_month_reach, "_")#</td>');
			}
			for(row in qMonth){  
				echo('<td>#numberformat(row.facebook_month_reach, "_")#</td>');
			}
		}
		echo('</tr>');
	}
	/*echo('<tr><th>Page Views</th>');
	for(row in qMonthPreviousYear){ 
		echo('<td>#numberformat(row.facebook_month_views, "_")#</td>');
	}
	for(row in qMonth){ 
		echo('<td>#numberformat(row.facebook_month_views, "_")#</td>');
	}
	echo('</tr>');*/
	//echo('<tr><th>Followers</th><td>#numberformat(row.facebook_month_followers, "_")#</td></tr>'); 
	echo('</table>');  
	</cfscript>

	<!--- <cfif qN.recordcount>
		<h2>Top 5 Facebook Posts By Reach</h2>
	
		<table class="leadTable1">
			<tr>
				<th style="vertical-align:top; width:1%; white-space:nowrap;">Name / Date / Type</th>  
				<th style="vertical-align:top; ">Clicks</th>
				<th style="vertical-align:top; ">Reactions</th>
				<th style="vertical-align:top; ">Impressions</th>
				<th style="vertical-align:top; ">Comments</th>
				<th style="vertical-align:top; ">Reach</th>
				<th style="vertical-align:top; ">Shares</th> 
				<th style="vertical-align:top; ">Video Views 
</th> 
				<!--- <th>Leads</th> Requires links to have zsource=newsletter in url --->
			</tr>
			<cfscript> 
			for(row in qN){
			/* 
			facebook_post_external_id 
			*/
				echo('<tr>
					<td style="width:1%; white-space:nowrap;">#application.zcore.functions.zLimitStringLength(row.facebook_post_text, 60)#<br>#dateformat(row.facebook_post_created_datetime, "m/d/yyyy")# - #row.facebook_post_type#</td>  
					<td>#numberformat(row.facebook_post_link_click, "_")#</td>
					<td>#numberformat(row.facebook_post_reactions, "_")#</td>
					<td>#numberformat(row.facebook_post_impressions, "_")#</td>
					<td>#numberformat(row.facebook_post_comments, "_")#</td>
					<td>#numberformat(row.facebook_post_reach, "_")#</td> 
					<td>#numberformat(row.facebook_post_shares, "_")#</td>
					<td>#numberformat(row.facebook_post_video_views, "_")#</td>
				</tr>'); 
			}
			</cfscript> 
		</table>

	</cfif> --->
</cffunction> 

<cffunction name="reportFooter" localmode="modern" access="public">
	
	 
		<cfscript> 

		request.leadData.notUpToDate=false;
		</cfscript>

		#showFooter(true)#

		<div class="hide-on-print"> 
			<a id="generatedInfo">&nbsp;</a>
			<h2>About This Report</h2>
			<p>The displayed search volume for keywords is the highest number during that month.  This data comes from semrush.com or moz.com.</p>
			<p>The displayed ranking for keywords is the lowest number during that month.</p>
			<p>"Visits" are visits.  They are not unique, and they are not sessions or users.</p>
			<p>Search Console and Google Analytics are combined to report the keywords people used to find the site. The majority of keywords for bing/yahoo can't be collected.</p>
			<p>There is permanently going to be less keyword traffic data available before October 2016 because Search Console only goes back 90 days and this report system went into use in January 2017.</p>
			<p>Parts of the report will not show if there is no data being collected for that part during the selected time period.</p>
			<p>There is no separation between paid traffic and other traffic.  Most reports except for "organic search" are showing all sources of traffic combined.</p>
			<h2>Technical Notes</h2>
			<h3>SEMRush Stuff</h3>
			<p>To group keywords by account label: you must do these steps</p>
			<ul style="padding-left:25px;"><li>Enter both "Semrush.com Label List" and "Semrush.com Primary Label" in site globals.</li>
			<li>Delete all of the SEMRush data for the site with a query like this: deletse FROM keyword_ranking WHERE site_id = 'X' AND keyword_ranking_source='3'  ;</li>
			<li>Change the site table semrush last import date to be an empty string to force it to redownload all time: UPDATE site SET site_semrush_last_import_datetime='' WHERE site_id = 'X';</li>
			<li>Reimport SEMRush data with a url like this: https://sa.farbeyondcode.com/z/inquiries/admin/import-keyword-ranking/semrush?sid=X</li>
			<li>Most of the SEMRush projects are named opposite logic, and national is actually the local one.</li>
			</ul>
			<h2>Data Integration Status:</h2>      
			<cfif request.leadData.qSite.site_webposition_id_list EQ "">
				<p>Webposition backup import not enabled</p>
			<cfelse>
				<p>Webposition backup was imported</p>
			</cfif>


			<cfscript>
			if(form.yearToDateLeadLog EQ 2){
				checkMonth=request.leadData.endDate;
			}else{
				checkMonth=request.leadData.selectedMonth;
			}
			</cfscript>
			<cfif request.leadData.qSite.site_semrush_id_list EQ "">
				<p>SEMRush.com: not enabled</p>
			<cfelse>
				<cfscript>
				if(request.leadData.qSite.site_semrush_last_import_datetime NEQ "" and datecompare(dateformat(request.leadData.qSite.site_semrush_last_import_datetime, "yyyy-mm-dd"), checkMonth) GTE 0){
					request.leadData.notUpToDate=true;
				}
				</cfscript>
				<p>SEMRush.com: #showDate(request.leadData.qSite.site_semrush_last_import_datetime)#</p> 
			</cfif>
			<cfif request.leadData.qSite.site_google_search_console_domain EQ "">
				<p>Google Webmaster Search Analytics: not enabled</p>
			<cfelse>
				<cfscript>
				if(request.leadData.qSite.site_google_search_console_last_import_datetime NEQ "" and datecompare(dateformat(request.leadData.qSite.site_google_search_console_last_import_datetime, "yyyy-mm-dd"), checkMonth) GTE 0){
					request.leadData.notUpToDate=true;
				}
				</cfscript>
				<p>Google Webmaster Search Analytics: #showDate(request.leadData.qSite.site_google_search_console_last_import_datetime)#</p>
			</cfif>
			<cfif request.leadData.qSite.site_google_api_account_email EQ "">
				<p>Google Analytics API: not enabled</p>
			<cfelse>
				<cfscript>
				if(request.leadData.qSite.site_google_analytics_keyword_last_import_datetime NEQ "" and datecompare(dateformat(request.leadData.qSite.site_google_analytics_keyword_last_import_datetime, "yyyy-mm-dd"), checkMonth) GTE 0){
					request.leadData.notUpToDate=true;
				}
				if(request.leadData.qSite.site_google_analytics_organic_last_import_datetime NEQ "" and datecompare(dateformat(request.leadData.qSite.site_google_analytics_organic_last_import_datetime, "yyyy-mm-dd"), checkMonth) GTE 0){
					request.leadData.notUpToDate=true;
				}
				</cfscript>
				<p>Google Analytics Organic Keywords: #showDate(request.leadData.qSite.site_google_analytics_keyword_last_import_datetime)#</p>  
				<p>Google Analytics Organic Overview: #showDate(request.leadData.qSite.site_google_analytics_organic_last_import_datetime)#</p>
			</cfif>

			<cfif request.leadData.qSite.site_campaign_monitor_user_id_list EQ "" or request.leadData.qSite.site_campaign_monitor_last_import_datetime EQ "">
				<p>Campaign Monitor Import: not enabled</p>
			<cfelse>
				<cfscript>
				if(request.leadData.qSite.site_campaign_monitor_last_import_datetime NEQ "" and datecompare(dateformat(request.leadData.qSite.site_campaign_monitor_last_import_datetime, "yyyy-mm-dd"), checkMonth) GTE 0){
					request.leadData.notUpToDate=true;
				}
				</cfscript>
				<p>Campaign Monitor Import: #showDate(request.leadData.qSite.site_campaign_monitor_last_import_datetime)#</p> 
			</cfif> 

			<cfif request.leadData.qSite.site_interspire_email_owner_id_list EQ "" or request.leadData.qSite.site_interspire_email_last_import_datetime EQ "">
				<p>Interspire Email Import: not enabled</p>
			<cfelse>
				<cfscript>
				if(request.leadData.qSite.site_interspire_email_last_import_datetime NEQ "" and datecompare(dateformat(request.leadData.qSite.site_interspire_email_last_import_datetime, "yyyy-mm-dd"), checkMonth) GTE 0){
					request.leadData.notUpToDate=true;
				}
				</cfscript>
				<p>Interspire Email Import: #showDate(request.leadData.qSite.site_interspire_email_last_import_datetime)#</p> 
			</cfif>

			<cfif request.leadData.qSite.site_seomoz_id_list EQ "">
				<p>moz.com: not enabled</p>
			<cfelse>
				<cfscript>
				if(request.leadData.qSite.site_seomoz_last_import_datetime NEQ "" and datecompare(dateformat(request.leadData.qSite.site_seomoz_last_import_datetime, "yyyy-mm-dd"), checkMonth) GTE 0){
					request.leadData.notUpToDate=true;
				}
				</cfscript>
				<p>moz.com: #showDate(request.leadData.qSite.site_seomoz_last_import_datetime)#</p>
			</cfif>
			<cfif request.leadData.qSite.site_calltrackingmetrics_enable_import NEQ 1>
				<p>CallTrackingMetrics.com: not enabled</p>
			<cfelse>
				<cfscript>
				if(request.leadData.qSite.site_calltrackingmetrics_import_datetime NEQ "" and datecompare(dateformat(request.leadData.qSite.site_calltrackingmetrics_import_datetime, "yyyy-mm-dd"), checkMonth) GTE 0){
					request.leadData.notUpToDate=true;
				}
				</cfscript>
				<p>CallTrackingMetrics.com: #showDate(request.leadData.qSite.site_calltrackingmetrics_import_datetime)#</p>
			</cfif>
		</div>

	</div>
	</div>


	<script type="text/javascript">
	$(document).ready(function(){ 
		//$("##myClass1").css("color", "##F00"); 
	});
	</script>
</body>
</html>
</cffunction> 



<cffunction name="processAndDisplayReport" localmode="modern" access="public">
	<cfargument name="htmlOut" type="string" required="yes">
	<cfscript>
	htmlOut=arguments.htmlOut;
	if(structkeyexists(form, 'print')){ 
		htmlOut=replace(htmlOut, '{pagecount}', request.leadData.pagecount, 'all'); 
	}
	htmlOut=replace(htmlOut, '{totalPageCount}', request.leadData.pageCount, 'all');  

	if(request.leadData.notUpToDate){
		htmlOut=replace(htmlOut, 'class="uptodateDiv"', 'class="uptodateDiv"  style="display:none;" ');
	}

	for(i in request.leadData.contentSection){
		v=request.leadData.contentSection[i]; 
		if(v EQ 0){
			htmlOut=replace(htmlOut, '{#i#Style}', 'display:none;');
		}else{
			htmlOut=replace(htmlOut, '{#i#Style}', ' '); 
			htmlOut=replace(htmlOut, '{#i#PageNumber}', v+1);
		}
	}  
	if(structkeyexists(form, 'print')){ 
		debug=false; 
		pdfFile=request.zos.globals.privateHomeDir&"#form.selectedMonth#-Lead-Report-#request.zos.globals.shortDomain#.pdf";
		r=application.zcore.functions.zConvertHTMLTOPDF(htmlOut, pdfFile, 1000);
		if(r EQ false){

			ts={
				type:"Custom",
				errorHTML:'HTML to PDF Failed.  User saw the raw html instead of a pdf.  Error message: '&request.zos.htmlToPDFErrorMessage&"<br /><br />Full HTML: "&htmlOut,
				scriptName:'/builder-pdf/index',
				url:request.zos.originalURL,
				exceptionMessage:'HTML to PDF Failed.  User saw the raw html instead of a pdf.  Error message: '&request.zos.htmlToPDFErrorMessage,
				// optional
				lineNumber:'1'
			}
			application.zcore.functions.zLogError(ts);
			if(form.returnJSON EQ 1){
				return {success:false, errorMessage="HTML to PDF Failed"}
			}else{
				echo(htmlOut);
				abort;
			}
		}
		if(debug){
			echo(htmlOut);
			application.zcore.functions.zdeletefile(pdfFile);
			echo('html to pdf result: '&r);
			abort;
		}
		if(form.returnJSON EQ 1){
			return {success:true, filePath:pdfFile, html:htmlOut };
		}else{
			// if this ever stops working for file download in chrome, we can redirect to a different function and turn off deletefile
		    header name="Content-Disposition" value="inline; filename=#getfilefrompath(pdfFile)#" charset="utf-8";
		    content type="application/pdf" deletefile="yes" file="#pdfFile#";
		}
	}else{
		if(form.returnJSON EQ 1){
			return {success:true, filePath:"", html:htmlOut };
		}else{
			echo(htmlOut);
		}
	}
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>