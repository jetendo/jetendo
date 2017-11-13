<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var arrId=0;
	var qMember=0;
	var qinquiries=0;
	var qInquiriesActive=0;

	var db=request.zos.queryObject;
	var qinquiriesFirst=0;
	var qinquiriesLast=0;
	var searchNav=0;
	var searchStruct=0;
	var inquiryFirstDate=0;
	var hCom=0;
	application.zcore.functions.zSetPageHelpId("4.10");
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Reports");
	form.keywordsearch=application.zcore.functions.zso(form, 'keywordsearch');
	form.negativekeywordsearch=application.zcore.functions.zso(form, 'negativekeywordsearch');
	form.search=application.zcore.functions.zso(form, 'search',false,false);
	form.searchOn=application.zcore.functions.zso(form, 'searchOn',false,false);
	form.inquiries_status_id=application.zcore.functions.zso(form, 'inquiries_status_id');
	form.uid=application.zcore.functions.zso(form, 'uid');
	arrU=listToArray(form.uid, '|');
	form.selected_user_id=0;
	if(arrayLen(arrU) EQ 2){
		form.selected_user_id=arrU[1];
		form.selected_user_id_siteIDType=arrU[2];
	}

	

	if(structkeyexists(form, 'inquiries_end_date') EQ false){
		form.inquiries_end_date = application.zcore.functions.zGetDateSelect("inquiries_end_date");
	}
	if(structkeyexists(form, 'inquiries_start_date') EQ false){
		form.inquiries_start_date = application.zcore.functions.zGetDateSelect("inquiries_start_date");
	}
	if(form.inquiries_start_date EQ false or form.inquiries_end_date EQ false){
		form.inquiries_start_date = dateformat(dateadd("d", -30, now()), "yyyy-mm-dd");
		form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
	}
	if(dateCompare(form.inquiries_start_date, form.inquiries_end_date) EQ 1){
		form.inquiries_end_date = form.inquiries_start_date;
	}
	
	if(structkeyexists(form, 'zIndex') EQ false or isnumeric(form.zIndex) EQ false){
		form.zIndex = 1;
	}
	Request.zScriptName = "/z/inquiries/admin/search-engine-keyword-report/index?searchOn=#urlencodedformat(form.searchOn)#&negativekeywordsearch=#urlencodedformat(form.negativekeywordsearch)#&keywordsearch=#urlencodedformat(form.keywordsearch)#&inquiries_start_date=#urlencodedformat(dateformat(form.inquiries_start_date,'yyyy-mm-dd'))#&inquiries_end_date=#urlencodedformat(dateformat(form.inquiries_end_date,'yyyy-mm-dd'))#&search=#urlencodedformat(form.search)#";
	hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	</cfscript>
	<h2 style="display:inline;">Search Engine Keyword Inquiry Search | </h2>
	<a href="/z/inquiries/admin/manage-inquiries/index">Back to Inquiries</a><br />
	<br />
	<cfsavecontent variable="db.sql"> 
	select min(inquiries_datetime) as inquiries_datetime 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	where site_id = #db.param(request.zOS.globals.id)# and 
	inquiries_deleted = #db.param(0)# and 
	<cfif form.inquiries_status_id EQ ""> 
		inquiries.inquiries_status_id <> #db.param(0)# and 
	<cfelse>
		inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# and 
	</cfif>
	inquiries_parent_id = #db.param(0)#
	<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false>
		AND user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#
	</cfif>
	<cfif form.selected_user_id NEQ 0>
		and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#
	</cfif>
	</cfsavecontent>
	<cfscript>
	qinquiriesFirst=db.execute("qinquiriesFirst");
	if(isnull(qinquiriesFirst.inquiries_datetime) EQ false and isdate(qinquiriesFirst.inquiries_datetime)){
		inquiryFirstDate=qinquiriesFirst.inquiries_datetime;
	}else{
		inquiryFirstDate=dateFormat(now(), "yyyy-mm-dd")&" 00:00:00";
	}
	</cfscript>
	<cfsavecontent variable="db.sql">
	select max(inquiries_datetime) as inquiries_datetime 
	from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	where site_id = #db.param(request.zOS.globals.id)# and 
	inquiries_deleted = #db.param(0)# and
	<cfif form.inquiries_status_id EQ ""> 
		inquiries.inquiries_status_id <> #db.param(0)# and 
	<cfelse>
		inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# and 
	</cfif>
	inquiries_parent_id = #db.param(0)#
	<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false>
		AND user_id = #db.param(request.zsession.user.id)# and 
		user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#
	</cfif>
	<cfif form.selected_user_id NEQ 0>
		and inquiries.user_id = #db.param(form.selected_user_id)# and 
		user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#
	</cfif>
	</cfsavecontent>
	<cfscript>
	qinquiriesLast=db.execute("qinquiriesLast");
	</cfscript>
	<form action="/z/inquiries/admin/search-engine-keyword-report/index?search=true" method="post">
		<input type="hidden" name="searchOn" value="true" />
		<table style="border-spacing:0px; width:100%;" class="table-list">
			<tr>
				<th colspan="4">Search inquiries for keywords that people typed to find your web site.</th>
			</tr>
			<tr>
				<td style="white-space:nowrap;">Keyword:
					<input type="text" name="keywordsearch" value="#htmleditformat(application.zcore.functions.zso(form, 'keywordsearch'))#" style="min-width:300px; width:300px;max-width:100%; margin-bottom:5px;" />
					<br />
					Negative Keyword:
					<input type="text" name="negativekeywordsearch" style="min-width:300px; width:300px;max-width:100%;" value="#htmleditformat(application.zcore.functions.zso(form, 'negativekeywordsearch'))#" /></td>
				<td style="white-space:nowrap;">Start:#application.zcore.functions.zDateSelect("inquiries_start_date", "inquiries_start_date", year(inquiryFirstDate), year(now()))#</td>
				<td style="white-space:nowrap;">End:#application.zcore.functions.zDateSelect("inquiries_end_date", "inquiries_end_date", year(inquiryFirstDate), year(now()))#</td>
				<td><button type="submit" name="submitForm">Search</button></td>
			</tr>
		</table>
	</form>
	<cfif form.search>
		<cfif len(form.keywordsearch) LTE 2>
			<br />
			<h2>Keyword must be 3 characters or more. Please type a longer keyword and search again.</h2>
			<br />
			<cfset form.search=false>
		</cfif>
		<cfsavecontent variable="db.sql"> SELECT count(inquiries.inquiries_id) count 
		from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
		#db.table("track_user", request.zos.zcoreDatasource)# track_user 
		WHERE inquiries.inquiries_email = track_user.track_user_email AND 
		track_user_deleted = #db.param(0)# and 
		inquiries_deleted = #db.param(0)# and 
		inquiries.site_id = track_user.site_id AND 
		track_user.site_id = #db.param(request.zOS.globals.id)# AND 
		track_user_keywords <> #db.param('')# and 
		track_user_email <> #db.param('')# and 
		(track_user_keywords LIKE #db.param('%#form.keywordsearch#%')# or 
		track_user_keywords LIKE #db.param('%#application.zcore.functions.zurlencode(form.keywordsearch,"%")#%')#)
		<cfif len(form.negativekeywordsearch) GT 2>
			and (track_user_keywords NOT LIKE #db.param('%#form.negativekeywordsearch#%')# and 
			track_user_keywords NOT LIKE #db.param('%#application.zcore.functions.zurlencode(form.negativekeywordsearch,"%")#%')#)
		</cfif>
		<cfif form.inquiries_status_id EQ ""> 
			and inquiries.inquiries_status_id <> #db.param(0)# 
		<cfelse>
			and inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# 
		</cfif>
		 and inquiries_parent_id = #db.param(0)#
		<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false>
			AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
			user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#
		</cfif>
		<cfif form.selected_user_id NEQ 0>
			and inquiries.user_id = #db.param(form.selected_user_id)# and 
			user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#
		</cfif>
		<cfif form.inquiries_start_date EQ false>
			and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
			inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)
			<cfelse>
			and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
			inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)
		</cfif>
		</cfsavecontent>
		<cfscript>
		qInquiriesActive=db.execute("qInquiriesActive");
		</cfscript>
		<cfsavecontent variable="db.sql"> SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
		#db.table("track_user", request.zos.zcoreDatasource)# track_user 
		WHERE inquiries.inquiries_email = track_user.track_user_email AND 
		track_user_deleted = #db.param(0)# and 
		inquiries_deleted = #db.param(0)# and
		inquiries.site_id = track_user.site_id AND 
		track_user.site_id = #db.param(request.zOS.globals.id)# AND 
		track_user_keywords <> #db.param('')# and 
		track_user_email <> #db.param('')# AND 
		(track_user_keywords LIKE #db.param('%#form.keywordsearch#%')# or 
		track_user_keywords LIKE #db.param('%#application.zcore.functions.zurlencode(form.keywordsearch,"%")#%')#)
		<cfif len(form.negativekeywordsearch) GT 2>
			and (track_user_keywords NOT LIKE #db.param('%#form.negativekeywordsearch#%')# and 
			track_user_keywords NOT LIKE #db.param('%#application.zcore.functions.zurlencode(form.negativekeywordsearch,"%")#%')#)
		</cfif>
		<cfif form.inquiries_status_id EQ ""> 
			and inquiries.inquiries_status_id <> #db.param(0)# 
		<cfelse>
			and inquiries.inquiries_status_id = #db.param(form.inquiries_status_id)# 
		</cfif>
		 and inquiries_parent_id = #db.param(0)#
		<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator") EQ false>
			AND inquiries.user_id = #db.param(request.zsession.user.id)# and 
			user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#
		</cfif>
		<cfif form.selected_user_id NEQ 0>
			and inquiries.user_id = #db.param(form.selected_user_id)# and 
			user_id_siteIDType = #db.param(form.selected_user_id_siteidtype)#
		</cfif>
		<cfif form.inquiries_start_date EQ false>
			and (inquiries_datetime >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd")&' 00:00:00')# and 
			inquiries_datetime <= #db.param(dateformat(now(), "yyyy-mm-dd")&' 23:59:59')#)
			<cfelse>
			and (inquiries_datetime >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd")&' 00:00:00')# and 
			inquiries_datetime <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd")&' 23:59:59')#)
		</cfif>
		LIMIT #db.param((form.zIndex-1)*10)#,#db.param(10)# </cfsavecontent>
		<cfscript>
		qinquiries=db.execute("qinquiries");
		</cfscript>
		<script type="text/javascript">
		/* <![CDATA[ */
		function loadExport(){
			var wf=document.getElementById("whichfields1");	
			var whichfields="0";
			if(wf.checked){
				whichfields="1";
			}
			var et=document.getElementById("exporttype1");	
			var et2=document.getElementById("exporttype2");	
			var exporttype="0";
			if(et.checked){
				exporttype="1";
			}else if(et2.checked){
				exporttype="2";
			}
			var format="html";
			et=document.getElementById("exportformat1");	
			if(et.checked){
				format="csv";	
			}
			window.open("/z/inquiries/admin/export?keywordexport=1&negativekeywordsearch=#urlencodedformat(form.negativekeywordsearch)#&keywordsearch=#urlencodedformat(form.keywordsearch)#&inquiries_start_date=#urlencodedformat(dateformat(form.inquiries_start_date,'yyyy-mm-dd'))#&inquiries_end_date=#urlencodedformat(dateformat(form.inquiries_end_date,'yyyy-mm-dd'))#&format="+format+"&exporttype="+exporttype+"&whichfields="+whichfields);
		}/* ]]> */
		</script> 
		<br />
		<!--- if(form.whichfields EQ 0){  --->
		<h3>Export Options</h3>
		<p>Format:
		<input type="radio" name="exportformat" id="exportformat1" value="1" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 1>checked="checked"</cfif> style="vertical-align:middle; background:none; border:none;" />
		CSV
		<input type="radio" name="exportformat" value="0" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 0>checked="checked"</cfif> style="vertical-align:middle; background:none; border:none;" />
		HTML</p> 

		<p>Fields: 
		<input type="radio" name="whichfields" id="whichfields1" value="1" <cfif application.zcore.functions.zso(form, 'whichfields',false,1) EQ 1>checked="checked"</cfif> style="vertical-align:middle; margin:0px; background:none; border:none;" />
		All Fields
		<!--- <input type="radio" name="whichfields" value="0" <cfif application.zcore.functions.zso(form, 'whichfields',false,1) EQ 0>checked="checked"</cfif> style="vertical-align:middle; background:none; margin:0px;margin-left:10px; border:none;" /> Basic Fields ---></p>
		<p>
		Filter:
		<input type="radio" name="exporttype" id="exporttype1" value="1" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 1>checked="checked"</cfif> style="vertical-align:middle; background:none; border:none;" />
		Unique Emails Only
		<input type="radio" name="exporttype" id="exporttype2" value="2" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 2>checked="checked"</cfif> style="vertical-align:middle; background:none; border:none;" />
		Unique Phone Numbers Only
		<input type="radio" name="exporttype" value="0" <cfif application.zcore.functions.zso(form, 'exporttype',false,0) EQ 0>checked="checked"</cfif> style="vertical-align:middle; background:none; border:none;" />
		Export All Results</p>

		<button type="button" name="submit11" onclick="loadExport();">Export</button>

		 <br />
		<br />
		<cfscript>
		// required
		searchStruct = StructNew();
		searchStruct.count = qinquiriesActive.count;
		searchStruct.index = form.zIndex;
		searchStruct.showString = "Results ";
		searchStruct.url = Request.zScriptName;
		searchStruct.indexName = "zIndex";
		searchStruct.buttons = 5;
		if(structkeyexists(form, 'searchOn')){		
			searchStruct.perpage = 10;
		}else{
			searchStruct.perpage = 50;
		}
		if(searchStruct.count LTE searchStruct.perpage){
			searchNav="";
		}else{
			searchNav = '<table class="table-list" style="width:100%; border-spacing:0px;" >		
		<tr><td style="padding:0px;">'&application.zcore.functions.zSearchResultsNav(searchStruct)&'</td></tr></table>';
		}
		</cfscript>
		#searchNav#
		<table class="table-list" style="width:100%; border-spacing:0px;" >
			<tr>
				<th>First / Last Name</th>
				<th>Phone</th>
				<th>Email</th>
				<th style="width:120px;">Received</th>
				<th style="width:140px;">Admin</th>
			</tr>
			<cfsavecontent variable="db.sql"> 
			SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
			WHERE user_id = #db.param(request.zsession.user.id)# and 
			site_id = #db.param(request.zsession.user.site_id)# </cfsavecontent>
			<cfscript>
			qMember=db.execute("qMember");
			</cfscript>
			<cfset arrId=ArrayNew(1)>
			<cfloop query="qinquiries">
				<cfset ArrayAppend(arrId,qinquiries.inquiries_id)>
				<tr <cfif qinquiries.inquiries_status_id EQ 1 or qinquiries.inquiries_status_id EQ 2><cfif qinquiries.currentrow mod 2 EQ 0>class="row1"<cfelse>class="row2"</cfif><cfelse><cfif qinquiries.currentrow mod 2 EQ 0>class="row2"<cfelse>class="row1"</cfif></cfif>>
					<td><a href="/z/inquiries/admin/feedback/view?inquiries_id=#qinquiries.inquiries_id#">#qinquiries.inquiries_first_name# #qinquiries.inquiries_last_name#</a></td>
					<td>#qinquiries.inquiries_phone1#&nbsp;</td>
					<td><cfif qinquiries.inquiries_email NEQ "">
							<a href="mailto:#qinquiries.inquiries_email#">#qinquiries.inquiries_email#</a>
						</cfif>
						&nbsp;</td>
					<td style="width:120px; white-space:nowrap;">#DateFormat(qinquiries.inquiries_datetime, "m/d/yy")# #TimeFormat(qinquiries.inquiries_datetime, "h:mm tt")#</td>
					<td style="width:140px; white-space:nowrap;"><a href="/z/inquiries/admin/feedback/view?inquiries_id=#qinquiries.inquiries_id#" target="_blank">View</a></td>
				</tr>
			</cfloop>
		</table>
		#searchNav#
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>
