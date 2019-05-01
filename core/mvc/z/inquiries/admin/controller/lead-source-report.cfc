<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var arrKey=0;
	var timeofdayStruct=0;
	var keywordStruct=0;
	var i=0;
	var qC=0;
	var engineStruct=0;
	application.zcore.functions.zSetPageHelpId("4.8");
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Reports");

	var db=request.zos.queryObject;
	var hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	form.end_date = application.zcore.functions.zGetDateSelect("end_date");
	form.start_date = application.zcore.functions.zGetDateSelect("start_date");
	if(form.start_date EQ false or form.end_date EQ false){
		if(dateformat(dateadd("d", -30, now()),"yyyymmdd") LT "20100114"){
			form.start_date = "2010-01-14";
		}else{
			form.start_date = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");
		}
		form.end_date = dateFormat(now(), "yyyy-mm-dd");
	}
	</cfscript>
	<h1>Inquiries Source Report</h1>
	<form action="/z/inquiries/admin/lead-source-report/index?search=true" method="post">
		<input type="hidden" name="searchOn" value="true">
		<table style="border-spacing:0px;" class="table-list">
			<tr>
				<th>Search Leads</th>
				<td style="white-space:nowrap;">Start:#application.zcore.functions.zDateSelect("start_date", "start_date", (2010), year(now()))#</td>
				<td style="white-space:nowrap;">End:#application.zcore.functions.zDateSelect("end_date", "end_date", (2010), year(now()))#</td>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">Search</button>
					<button type="button" onclick="window.location.href='/z/inquiries/admin/lead-source-report/index';" name="submitForm22" class="z-manager-search-button">Clear</button></td>
			</tr>
		</table>
	</form>
	<cfsavecontent variable="db.sql"> 
	SELECT track_user.*, IF(track_user_first_page not like #db.param('%gclid=%')# and track_page.track_user_id IS NULL, #db.param(0)#,#db.param(1)#) adwordsLead 
	FROM #db.table("track_user", request.zos.zcoreDatasource)# track_user 
	LEFT JOIN #db.table("track_page", request.zos.zcoreDatasource)# track_page ON 
	track_user.track_user_id=track_page.track_user_id AND 
	track_page_deleted = #db.param(0)# and 
	(track_page_qs LIKE #db.param('%gclid=%')#) and 
	track_page.site_id = track_user.site_id 
	
	WHERE  track_user_conversions >#db.param(0)# AND 
	track_user_deleted = #db.param(0)# and 
	track_user.site_id = #db.param(request.zos.globals.id)# AND track_user_email <> #db.param('')# and 
	(DATE_FORMAT(track_user_recent_datetime,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(form.start_date, "yyyy-mm-dd"))# and 
	DATE_FORMAT(track_user_datetime,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(form.end_date, "yyyy-mm-dd"))#)
	GROUP BY track_user.track_user_id </cfsavecontent>
	<cfscript>
	qC=db.execute("qC");
	engineStruct=structnew();
	keywordStruct=structnew();
	timeofdayStruct=structnew();
	</cfscript>
	<br />
	<p>This report doesn't include phone call leads</p>
	<p>The same user submitting more then one lead counts as only one lead on this report.</p>
	<cfloop query="qC">
		<cfscript>
		ref="";
		seconds=0;
		if(isnull(qC.track_user_datetime) EQ false and isdate(qC.track_user_datetime) and isdate(qC.track_user_recent_datetime)){
			formattedDate=DateFormat(qC.track_user_datetime,'yyyy-mm-dd')&' '&TimeFormat(qC.track_user_datetime,'HH:mm:ss');
			firstDate=parsedatetime(formattedDate);
			formattedDate2=DateFormat(qC.track_user_recent_datetime,'yyyy-mm-dd')&' '&TimeFormat(qC.track_user_recent_datetime,'HH:mm:ss');
			lastDate=parsedatetime(formattedDate2);
			seconds=DateDiff("s", formattedDate, formattedDate2);
			leadTime=timeformat(dateadd("s",seconds/2,formattedDate),"HH");
			if(structkeyexists(timeofdayStruct,leadTime) EQ false){
				timeofdayStruct[leadTime]=structnew();	
				timeofdayStruct[leadTime].count=0;
				timeofdayStruct[leadTime].clicks=arraynew(1);
				timeofdayStruct[leadTime].length=arraynew(1);
			}
			timeofdayStruct[leadTime].count++;
			arrayappend(timeofdayStruct[leadTime].clicks,qC.track_user_hits);
			arrayappend(timeofdayStruct[leadTime].length,seconds);
		}
		if(qC.track_user_referer NEQ ""){
			ref=replacenocase(replacenocase(replacenocase(qC.track_user_referer,"http://",""),"www.",""),"https://","");
			pos=find("/",ref);
			if(pos NEQ 0){
				ref=left(ref,pos-1);
			}
			if(qC.adwordsLead EQ 1){
				ref&=" (adwords pay per click)";	
			}
			if(structkeyexists(engineStruct,ref) EQ false){
				engineStruct[ref]=structnew();	
				engineStruct[ref].count=0;
				engineStruct[ref].clicks=arraynew(1);
				engineStruct[ref].length=arraynew(1);
			}
			engineStruct[ref].count++;
			arrayappend(engineStruct[ref].clicks,qC.track_user_hits);
			arrayappend(engineStruct[ref].length,seconds);
		}
		if(qC.track_user_keywords NEQ ""){
			if(structkeyexists(keywordStruct,qC.track_user_keywords) EQ false){
					keywordStruct[qC.track_user_keywords]=structnew();	
					keywordStruct[qC.track_user_keywords].count=0;
					keywordStruct[qC.track_user_keywords].clicks=arraynew(1);
					keywordStruct[qC.track_user_keywords].length=arraynew(1);
			}
			keywordStruct[qC.track_user_keywords].count++;
			arrayappend(keywordStruct[qC.track_user_keywords].clicks,qC.track_user_hits);
			formattedDate=DateFormat(qC.track_user_datetime,'yyyy-mm-dd')&' '&TimeFormat(qC.track_user_datetime,'HH:mm:ss');
			firstDate=parsedatetime(formattedDate);
			formattedDate2=DateFormat(qC.track_user_recent_datetime,'yyyy-mm-dd')&' '&TimeFormat(qC.track_user_recent_datetime,'HH:mm:ss');
			lastDate=parsedatetime(formattedDate2);
			seconds=DateDiff("s", formattedDate, formattedDate2);
			arrayappend(keywordStruct[qC.track_user_keywords].length,seconds);
		}
		</cfscript>
	</cfloop>
	<h2>Lead Source Report</h2>
	<table style="border-spacing:0px;" class="table-list">
		<tr>
			<th>Lead Source</th>
			<th>## of Leads</th>
			<th>Average Clicks</th>
			<th>Average Length of Visit</th>
		</tr>
		<cfscript>
		arrKey=structkeyarray(engineStruct);
		arraysort(arrKey,"text","asc");
		if(arraylen(arrKey) EQ 0){
			writeoutput('<tr><td colspan="4">No lead data available.</td></tr>');
		}
		for(i=1;i LTE arraylen(arrKey);i++){
			writeoutput('<tr');
			if(i MOD 2 EQ 0){ writeoutput(' style="" '); }
			seconds=round(arrayavg(engineStruct[arrKey[i]].length));
			minutes=fix(seconds/60)&'mins ';
			if(fix(seconds/60) EQ 0){
				minutes="";
			}
			if(seconds MOD 60 NEQ 0){
				minutes=minutes&(seconds MOD 60)&'secs';
			}
			writeoutput('><td>#arrKey[i]#</td><td>#engineStruct[arrKey[i]].count#</td><td>#round(arrayavg(engineStruct[arrKey[i]].clicks))#</td><td>#minutes#</td></tr>');	
		}
		</cfscript>
	</table>

	<cfscript>
	db.sql="SELECT track_user_source, COUNT(track_user_id) `count` 
	FROM #db.table("track_user", request.zos.zcoreDatasource)# 
	WHERE track_user_source<>#db.param('')# AND 
	track_user_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#
	AND  
	(DATE_FORMAT(track_user_recent_datetime,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(form.start_date, "yyyy-mm-dd"))# AND 
	DATE_FORMAT(track_user_datetime,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(form.end_date, "yyyy-mm-dd"))#) 
	GROUP BY track_user_source 
	ORDER BY track_user_source ASC
	 LIMIT #db.param(0)#, #db.param(1000)# ";
	 qTrack=db.execute("qTrack");

	db.sql="SELECT COUNT(track_user_id) `count` 
	FROM #db.table("track_user", request.zos.zcoreDatasource)# 
	WHERE  
	site_id = #db.param(request.zos.globals.id)# AND 
	track_user_deleted=#db.param(0)# and 
	(DATE_FORMAT(track_user_recent_datetime,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(form.start_date, "yyyy-mm-dd"))# AND 
	DATE_FORMAT(track_user_datetime,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(form.end_date, "yyyy-mm-dd"))#)  AND 
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
		<h2>Tracking Label Report</h2>
		<table style="border-spacing:0px;" class="table-list">
			<tr>
				<th>Tracking Source</th>
				<th>## of Leads</th>
			</tr>');
		for(row in qTrack){
			echo('<tr>
				<td>#row.track_user_source#</td>
				<td>#row.count#</td>
			</tr>'); 
		}
		for(row in qTrack2){
			echo('<tr>
				<td>Organic Search</td>
				<td>#row.count#</td>
			</tr>'); 
		}
		echo('</table>');
	}
	</cfscript>

	<br />
	<h2>Keyword Report</h2>
	<table style="border-spacing:0px;" class="table-list">
		<tr>
			<th>Keyword Phrase</th>
			<th>## of Leads</th>
			<th>Average Clicks</th>
			<th>Average Length of Visit</th>
		</tr>
		<cfscript>
		arrKey=structkeyarray(keywordStruct);
		arraysort(arrKey,"text","asc");
		if(arraylen(arrKey) EQ 0){
			writeoutput('<tr><td colspan="4">No lead data available.</td></tr>');
		}
		for(i=1;i LTE arraylen(arrKey);i++){
			writeoutput('<tr');
			if(i MOD 2 EQ 0){ writeoutput(' style="" '); }
			seconds=round(arrayavg(keywordStruct[arrKey[i]].length));
			minutes=fix(seconds/60)&'mins ';
			if(fix(seconds/60) EQ 0){
				minutes="";
			}
			if(seconds MOD 60 NEQ 0){
				minutes=minutes&(seconds MOD 60)&'secs';
			}
			writeoutput('><td>#arrKey[i]#</td><td>#keywordStruct[arrKey[i]].count#</td><td>#round(arrayavg(keywordStruct[arrKey[i]].clicks))#</td><td>#minutes#</td></tr>');	
		}
		</cfscript>
	</table>
	<br />
	<h2>Time of Day Report</h2>
	<table style="border-spacing:0px;" class="table-list">
		<tr>
			<th>Time of Day</th>
			<th>## of Leads</th>
			<th>Average Clicks</th>
			<th>Average Length of Visit</th>
		</tr>
		<cfscript>
		arrKey=structkeyarray(timeofdayStruct);
		arraysort(arrKey,"text","asc");
		if(arraylen(arrKey) EQ 0){
			writeoutput('<tr><td colspan="4">No lead data available.</td></tr>');
		}
		for(i=1;i LTE arraylen(arrKey);i++){
			writeoutput('<tr');
			if(i MOD 2 EQ 0){ writeoutput(' style="" '); }
			seconds=round(arrayavg(timeofdayStruct[arrKey[i]].length));
			minutes=fix(seconds/60)&'mins ';
			if(fix(seconds/60) EQ 0){
				minutes="";
			}
			if(seconds MOD 60 NEQ 0){
				minutes=minutes&(seconds MOD 60)&'secs';
			}
			writeoutput('><td>#timeformat(arrKey[i]&":00:00","h tt")#</td><td>#timeofdayStruct[arrKey[i]].count#</td><td>#round(arrayavg(timeofdayStruct[arrKey[i]].clicks))#</td><td>#minutes#</td></tr>');	
		}
		</cfscript>
	</table>
	<br />


	<cfscript>
	db.sql="SELECT 
	inquiries_type_name, 
	inquiries.inquiries_type_id, 
	DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, 
	COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM (#db.table("inquiries", request.zos.zcoreDatasource)# , 
	#db.table("inquiries_type", request.zos.zcoreDatasource)#)
	WHERE 
	inquiries_deleted=#db.param(0)# and 
	inquiries_type_deleted=#db.param(0)# and 
	inquiries_type.inquiries_type_id = inquiries.inquiries_type_id and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	inquiries.site_id = #db.param(request.zos.globals.id)#
	GROUP BY inquiries.inquiries_type_id, inquiries.inquiries_type_id_siteIDType, DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date, inquiries_type_name asc ";
	qType=db.execute("qType", "", 10000, "query", false);


	db.sql="SELECT  inquiries.inquiries_type_id, DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) date, COUNT(DISTINCT inquiries.inquiries_id) count 
	FROM #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE   
	inquiries_deleted=#db.param(0)# and 
	inquiries.site_id = #db.param(request.zos.globals.id)# 
	GROUP BY DATE_FORMAT(inquiries_datetime, #db.param('%Y-%m')#) 
	ORDER BY date";
	qMonth=db.execute("qMonth");
	

	typeNameStruct={};
	typeStruct2={};
	typeStruct={};
	for(row in qType){
		if(not structkeyexists(typeStruct, row.date)){
			typeStruct[row.date]={};
		}
		if(not structkeyexists(typeStruct2, row.inquiries_type_name)){
			typeStruct2[row.inquiries_type_name]=true;
		}
		typeStruct[row.date][row.inquiries_type_name]=row.count;
	}
	for(row in qType){
		typeNameStruct[row.inquiries_type_name]=true;
	} 
	</cfscript> 
	<br />
	<h2>Monthly Lead Type Report</h2>
	<table style="border-spacing:0px;" class="table-list">
		<tr> 
			<th>Month</th>
			<cfscript>
			arrType=structkeyarray(typeNameStruct);
			arraySort(arrType, "text", "asc");
			arrMonth=structkeyarray(typeStruct);
			arraySort(arrMonth, "text", "asc");
			for(type in arrType){
				echo('<th>#type#</th>');
			}
			</cfscript>
			<td>Total</td>
		</tr> 
		<cfscript>
		for(month in arrMonth){
			echo('<tr>');
			echo('<td>#month#</td>');
			total=0;
			for(type in arrType){
				if(structkeyexists(typeStruct[month], type)){
					total+=typeStruct[month][type];
					echo('<td>#typeStruct[month][type]#</td>');
				}else{
					echo('<td>0</td>');
				}
			}
			echo('<td>#total#</td>');
			echo('</tr>');
		}
		</cfscript>  
	</table> 
	<br />
	<br />
	<h2>Monthly Total Lead Report</h2>
	<table style="border-spacing:0px;" class="table-list">
		<tr> 
			<th>Month</th>
			<th>Total Leads</th>
		</tr>
		<cfloop query="qMonth"> 
			<tr> 
				<th>#qMonth.date#</th>
				<th>#qMonth.count#</th>
			</tr>
		</cfloop>
	</table> 
	<br />
</cffunction>
</cfoutput>
</cfcomponent>
