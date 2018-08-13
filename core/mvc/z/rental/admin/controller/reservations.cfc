<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	</cfscript>
	<h2 style="padding:5px; display:inline; padding-left:0px; margin:0px;">Reservations | </h2>
	<a href="/z/inquiries/admin/inquiry/add?inquiries_reservation=1">Add Reservation</a><br />
	<br />
</cffunction>

<cffunction name="cancel" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var r=0;
	var qUpdate=0;
	var qInquiry=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Reservations", true);
	db.sql="SELECT * from #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE inquiries_id = #db.param(application.zcore.functions.zso(form, 'inquiries_id'))# and 
	site_id = #db.param(request.zOS.globals.id)#";
	qInquiry=db.execute("qInquiry");
	if(qInquiry.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'Unable to delete reservation because it doesn''t exist.');
		application.zcore.functions.zRedirect('/z/rental/admin/reservations/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>		
		db.sql="DELETE FROM #request.zos.queryObject.table("availability", request.zos.zcoreDatasource)#  
		WHERE  site_id = #db.param(request.zOS.globals.id)# and 
		rental_id = #db.param(qinquiry.rental_id)# and 
		inquiries_id = #db.param(form.inquiries_id)#"; 
		r=db.execute("r");
		db.sql=" UPDATE #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# inquiries 
		SET inquiries_reservation_status = #db.param(2)# WHERE inquiries_id = #db.param(form.inquiries_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		qUpdate=db.execute("qUpdate");
		application.zcore.status.setStatus(request.zsid, 'Reservation cancelled and calendar dates have been made available.');
		application.zcore.functions.zRedirect('/z/rental/admin/reservations/index?zsid=#request.zsid#');
		</cfscript>
	<cfelse>
		<h2 style="font-size:14px; line-height:21px; font-weight:bold;">Are you sure you want to cancel this reservation?<br />
		<br />
		Name: #qInquiry.inquiries_first_name# #qInquiry.inquiries_last_name#<br />
		Start: #DateFormat(qinquiry.inquiries_start_date, 'm/d/yyyy')# <br />
		End: #DateFormat(qinquiry.inquiries_end_date, 'm/d/yyyy')#<br />
		<br />
		<a href="/z/rental/admin/reservations/cancel?confirm=1&amp;inquiries_id=#form.inquiries_id#">Yes</a>&nbsp;&nbsp;&nbsp;
		<a href="/z/rental/admin/reservations/index">No</a></h2>
	</cfif>
</cffunction>

<cffunction name="view" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qprop=0;
	var qinquiry=0;
	var i=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Reservations");
	writeoutput('disabled');
	application.zcore.functions.zabort();
	</cfscript>
	<!--- 
	<cfscript>
	db.sql="
	SELECT * from #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE inquiries_id = #db.param(form.inquiries_id)# and 
	site_id = #db.param(request.zOS.globals.id)# and 
	inquiries_deleted = #db.param(0)#";
	qinquiry=db.execute("qinquiry");
	if(qInquiry.recordcount EQ 0){
		location url="/z/inquiries/admin/manage-inquiries/index?message=#URLEncodedFormat('This inquiry doesn''t exist.')#";
	}
	for(i=1;i LTE listlen(qinquiry.columnlist);i=i+1){
		StructInsert(variables, listgetat(qinquiry.columnlist,i), qinquiry[listgetat(qinquiry.columnlist,i)][1], true);
	}
	db.sql="
	SELECT * FROM #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental 
	WHERE rental_id = #db.param(form.rental_id)# and 
	site_id = #db.param(request.zOS.globals.id)# and 
	rental_deleted = #db.param(0)#";
	qprop=db.execute("qprop");
	</cfscript>
	<span class="small">
	<a href="javascript:history.go(-1);">Back to Inquiries</a><br /><br />	
	</span>
	
	<table style="border-spacing:0px; width:100%;" class="table-highlight">	
	<tr>
		<td>Date Received:</td>
		<td class="table-white">#DateFormat(form.inquiries_datetime, "m/dd/yyyy")# #TimeFormat(form.inquiries_datetime, "h:mm tt")#</td>
	</tr>
	<cfif qprop.recordcount NEQ 0>
	<tr>
		<td>rental:</td>
		<td class="table-white"><a href="#qprop.rental_url#" target="_blank">#qprop.rental_name#</a></td>
	</tr>
	</cfif>
	<tr>
		<td>Start Date:</td>
		<td class="table-white">#DateFormat(form.inquiries_start_date, "m/dd/yyyy")#</td>
	</tr>
	<tr>
		<td>End Date:</td>
		<td class="table-white">#DateFormat(form.inquiries_end_date, "m/dd/yyyy")#</td>
	</tr>
	<tr>
		<td style="width:120px;">Name:</td>
		<td class="table-white">#form.inquiries_first_name# #form.inquiries_last_name#&nbsp;</td>
	</tr>
	<tr>
		<td>Email:</td>
		<td class="table-white">#form.inquiries_email#&nbsp;</td>
	</tr>
	<tr>
		<td>Phone:</td>
		<td class="table-white">#form.inquiries_phone1#&nbsp;</td>
	</tr>
	<tr>
		<td style="width:120px;">Adults:</td>
		<td class="table-white">#form.inquiries_adults#&nbsp;</td>
	</tr>
	<tr>
		<td style="width:120px;">Children:</td>
		<td class="table-white">#form.inquiries_children#&nbsp;</td>
	</tr>
	<tr>
		<td style="vertical-align:top; ">Comments:</td>
		<td class="table-white">#trim(ParagraphFormat(form.inquiries_comments))#&nbsp;</td>
	</tr>
	<script type="text/javascript">
	/* <![CDATA[ */
	function updateTotal(){
		var t1=document.getElementById("total1");
		var t2=document.getElementById("inquiries_nights_total");
		var t3=document.getElementById("inquiries_tax");
		var t4=document.getElementById("inquiries_cleaning");
		var t5=parseFloat(t2.value)+parseFloat(t3.value)+parseFloat(t4.value);
		
		t1.innerHTML=t5;
	}
	/* ]]> */
	</script>
	<tr>
		<td>Nights Total:</td>
		<td class="table-white">#DollarFormat(form.inquiries_nights_total)#</td>
	</tr>
	<tr>
		<td>Tax:</td>
		<td class="table-white">#DollarFormat(form.inquiries_tax)#</td>
	</tr>
	<tr>
		<td>Cleaning Fee:</td>
		<td class="table-white">#DollarFormat(form.inquiries_cleaning)#</td>
	</tr>
	<tr>
		<td>Total:</td>
		<td class="table-white">#DollarFormat(application.zcore.functions.zso(form, 'inquiries_nights_total',true)+application.zcore.functions.zso(form, 'inquiries_tax',true)+application.zcore.functions.zso(form, 'inquiries_cleaning',true))#</td>
	</tr>
	<tr>
		<td>Amount Deposited:</td>
		<td class="table-white">#DollarFormat(form.inquiries_deposit)#</td>
	</tr>
	<tr>
		<td>Balance Due:</td>
		<td class="table-white">#DollarFormat(form.inquiries_balance_due)#</td>
	</tr>
	</table> --->
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qinquiries=0;
	var searchnav=0;
	var zperpage=0;
	var qinquiriestFirst=0;
	var futureMessage=0;
	var qInquiriesNew=0;
	var qinquiriesCount=0;
	var qinquiriesRange=0;
	var searchStruct=0;
	var qinquiriesLast=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Reservations");
	var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	db.sql=" select min(inquiries_datetime) as inquiries_start_date 
	from #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE inquiries_reservation<> #db.param(0)# and 
	inquiries_reservation_status <> #db.param(0)# and 
	inquiries_deleted = #db.param(0)# and 
	site_id = #db.param(request.zOS.globals.id)# ";
	qinquiriesFirst=db.execute("qinquiriesFirst");
	application.zcore.functions.zStatusHandler(request.zsid);
	zperpage=10;
	form.zPageId = application.zcore.functions.zso(form, 'zpageid');
	if(form.zPageId EQ ""){
		form.zPageId=application.zcore.status.getNewId();
	}
	if(structkeyexists(form, 'zIndex')){
		application.zcore.status.setField(form.zPageId, "zIndex", form.zIndex);
	}else{
		form.zIndex = application.zcore.status.getField(form.zPageId, "zIndex");
		if(form.zIndex EQ ""){
			form.zIndex = 1;
		}
	}
	</cfscript>
	<cfif qinquiriesFirst.inquiries_start_date EQ "" or  qinquiriesFirst.recordcount EQ 0>
		There are currently no inquiries.
	<cfelse>
		<cfscript>
		db.sql=" select max(inquiries_datetime) as inquiries_end_date from #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# inquiries 
		WHERE inquiries_reservation<> #db.param(0)# and 
		inquiries_deleted = #db.param(0)# and
		inquiries_reservation_status <> #db.param(0)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		qinquiriesLast=db.execute("qinquiriesLast");
		db.sql=" select inquiries_id from #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# inquiries
		WHERE inquiries_reservation<> #db.param(0)# and 
		inquiries_deleted = #db.param(0)# and 
		inquiries_reservation_status <> #db.param(0)# and 
		inquiries_datetime >= #db.param(dateformat(qinquiriesfirst.inquiries_start_date,"YYYY-mm-dd")&' 00:00:00')# and 
		inquiries_datetime <= #db.param(dateformat(qinquiriesLast.inquiries_end_date,"YYyy-mm-dd"))# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		qinquiriesRange=db.execute("qinquiriesRange");
		futureMessage = "";
		if(structkeyexists(form, 'inquiries_name') EQ false){
			if(qinquiriesRange.recordcount EQ 0){
				form.inquiries_start_date = dateFormat(now(), "yyyy-mm-dd");
				form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
			}else{
				form.inquiries_start_date = dateFormat(qinquiriesFirst.inquiries_start_date, "yyyy-mm-dd");
				form.inquiries_end_date = dateFormat(qinquiriesLast.inquiries_end_date, "yyyy-mm-dd");
			}		
		}else{
			form.inquiries_end_date = application.zcore.functions.zGetDateSelect("inquiries_end_date");
			form.inquiries_start_date = application.zcore.functions.zGetDateSelect("inquiries_start_date");
			if(form.inquiries_start_date EQ false or form.inquiries_end_date EQ false){
				form.inquiries_start_date = dateFormat(now(), "yyyy-mm-dd");
				form.inquiries_end_date = dateFormat(now(), "yyyy-mm-dd");
				futureMessage = 'Now showing all inquiries with future stay dates ';
			}else{	
			}
		}
		if(dateCompare(form.inquiries_start_date, form.inquiries_end_date) EQ 1){
			form.inquiries_end_date = form.inquiries_start_date;
		}	
		if(futureMessage EQ ''){
			futureMessage = 'Now showing reservations between #DateFormat(inquiries_start_date,'m/d/yyyy')&' and '&DateFormat(inquiries_end_date,'m/d/yyyy')# ';	
		}
		
		if(application.zcore.functions.zso(form, 'inquiries_name') NEQ ""){
			futureMessage = futureMessage&'and containing "#inquiries_name#".';
		}
		db.sql=" SELECT count(inquiries_id) as count from #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# inquiries
		WHERE inquiries.inquiries_manager_read = #db.param(0)# and 
		inquiries_deleted = #db.param(0)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		qinquiriesNew=db.execute("qinquiriesNew");
		db.sql=" SELECT count(inquiries_id) count from #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# inquiries
		WHERE inquiries_reservation<> #db.param(0)# and 
		inquiries_deleted = #db.param(0)# and 
		inquiries_reservation_status <> #db.param(0)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		if(application.zcore.functions.zso(form, 'inquiriessearchid') NEQ ''){
			db.sql&=" and inquiries_id = #db.param(inquiriessearchid)#";
		}
		if(application.zcore.functions.zso(form, 'inquiries_name') NEQ ""){
			db.sql&=" and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name,#db.param(' ')#,inquiries_email) LIKE #db.param('%#inquiries_name#%')#";
		}
		if(application.zcore.functions.zso(form, 'searchType',true) EQ 0){
			if(inquiries_start_date EQ false){
				db.sql&=" and (DATE_FORMAT(inquiries_datetime,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd"))# and DATE_FORMAT(inquiries_datetime,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(now(), "yyyy-mm-dd"))#)";
			}else{
				db.sql&=" and (DATE_FORMAT(inquiries_datetime,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(inquiries_start_date, "yyyy-mm-dd"))# and 
				DATE_FORMAT(inquiries_datetime,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(inquiries_end_date, "yyyy-mm-dd"))#)";
			}
		}else{
			if(inquiries_start_date EQ false){
				db.sql&=" and (DATE_FORMAT(inquiries_start_date,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(now(), "yyyy-mm-dd"))# and 
				DATE_FORMAT(inquiries_end_date,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(inquiries_end_date, "yyyy-mm-dd"))#)";
			}else{
				db.sql&=" and (DATE_FORMAT(inquiries_start_date,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(inquiries_start_date, "yyyy-mm-dd"))# and 
				DATE_FORMAT(inquiries_end_date,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(inquiries_end_date, "yyyy-mm-dd"))#)";
			}
		}
		qinquiriesCount=db.execute("qinquiriesCount");
		db.sql=" SELECT * from #request.zos.queryObject.table("inquiries", request.zos.zcoreDatasource)# inquiries 
		LEFT JOIN #request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental on 
		inquiries.rental_id = rental.rental_id and 
		rental_deleted = #db.param(0)#
		WHERE inquiries_reservation<> #db.param(0)# and 
		inquiries_deleted = #db.param(0)# and 
		inquiries_reservation_status <> #db.param(0)# and 
		site_id = #db.param(request.zOS.globals.id)#";
		if(application.zcore.functions.zso(form, 'inquiriessearchid') NEQ ''){
			db.sql&=" and inquiries_id = #db.param(form.inquiriessearchid)#";
		}
		if(application.zcore.functions.zso(form, 'inquiries_name') NEQ ""){
			db.sql&=" and concat(inquiries_first_name, #db.param(" ")#, inquiries_last_name,#db.param(' ')#,inquiries_email) LIKE #db.param('%#form.inquiries_name#%')#";
		}
		if(application.zcore.functions.zso(form, 'searchType',true) EQ 0){
			if(form.inquiries_start_date EQ false){
				db.sql&=" and (DATE_FORMAT(inquiries_datetime,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(dateadd("d", -14, now()), "yyyy-mm-dd"))# and 
				DATE_FORMAT(form.inquiries_datetime,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(now(), "yyyy-mm-dd"))#)";
			}else{
				db.sql&=" and (DATE_FORMAT(inquiries_datetime,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd"))# and 
				DATE_FORMAT(form.inquiries_datetime,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(inquiries_end_date, "yyyy-mm-dd"))#)";
			}
		}else{
			if(form.inquiries_start_date EQ false){
				db.sql&=" and (DATE_FORMAT(inquiries_start_date,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(now(), "yyyy-mm-dd"))# and 
				DATE_FORMAT(form.inquiries_end_date,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(form.inquiries_end_date, "yyyy-mm-dd"))#)";
			}else{
				db.sql&=" and (DATE_FORMAT(inquiries_start_date,#db.param("%Y-%m-%d")#) >= #db.param(dateformat(form.inquiries_start_date, "yyyy-mm-dd"))# and 
				DATE_FORMAT(form.inquiries_end_date,#db.param("%Y-%m-%d")#) <= #db.param(dateformat(inquiries_end_date, "yyyy-mm-dd"))#)";
			}
		}
		if(application.zcore.functions.zso(form, "sort") NEQ ""){
			db.sql&=" ORDER BY #db.param(sort)# #db.param(sort_order)#";
		}else{
			if(application.zcore.functions.zso(form, 'searchType',true) EQ 0){
				db.sql&=" ORDER BY inquiries.inquiries_datetime DESC";
			}else{
				db.sql&=" ORDER BY inquiries.inquiries_start_date DESC";
			}
		}
		if(structkeyexists(form, 'searchOn')){
			db.sql&=" LIMIT #db.param((form.zIndex-1)*50)#,#db.param(50)#";
		}else{
			db.sql&=" LIMIT #db.param((form.zIndex-1)*zperpage)#,#db.param(zperpage)#";
		}
		qinquiries=db.execute("qinquiries");
		</cfscript>
		<cfif structkeyexists(form, 'message')>
			<h2>#message#</h2>
		</cfif>
		<form action="/z/rental/admin/reservations/index?zPageId=#form.zPageId#" method="post" id="manager">
			<table style="border-spacing:0px; width:100%;" class="table-list">
				<tr>
					<th colspan="3"><strong>Search by inquiry id, start/end date or tenant name or email.</strong></th>
				</tr>
				<tr>
					<td><input type="hidden" name="searchOn" value="1" />
						ID:
						<input type="text" name="inquiriessearchid" value="#application.zcore.functions.zso(form, 'inquiriessearchid')#" size="3" />
						Name:
						<input type="text" name="inquiries_name" value="#application.zcore.functions.zso(form, 'inquiries_name')#" size="18" />
						Start: #application.zcore.functions.zDateSelect("inquiries_start_date", "inquiries_start_date", year(qinquiriesFirst.inquiries_start_date), year(now()))# End: #application.zcore.functions.zDateSelect("inquiries_end_date", "inquiries_end_date", year(qinquiriesFirst.inquiries_start_date), year(now()))#</td>
					<td><input type="radio" name="searchtype" value="0" <cfif application.zcore.functions.zso(form, 'searchtype',true) EQ 0>checked="checked"</cfif> style="background:none; border:none;">
						Received Date<br  />
						<input type="radio" name="searchtype" value="1" <cfif application.zcore.functions.zso(form, 'searchtype',true) EQ 1>checked="checked"</cfif> style="background:none; border:none;">
						Proposed Occupancy.</td>
					<td><button type="submit" name="submitForm">Search</button></td>
				</tr>
			</table>
			<input type="hidden" name="sort" value="#application.zcore.functions.zso(form, 'sort')#" />
			<input type="hidden" name="sort_order" value="#application.zcore.functions.zso(form, 'sort_order')#" />
			<cfif application.zcore.functions.zso(form, "sort_order") EQ "ASC">
				<cfset form.sort_order = "DESC">
				<cfset form.sort_indicator = "^">
			<cfelse>
				<cfset form.sort_order = "ASC">
				<cfset form.sort_indicator = "v">
			</cfif>
		</form>
		<span style="font-weight:bold">#futureMessage#</span>
		<cfif structkeyexists(form, 'searchOn')>
			| <a href="/z/rental/admin/reservations/index?zPageId=#form.zPageId#">Show All</a>
		</cfif>
		<br />
		<br />
		<style type="text/css">
		/* <![CDATA[ */
		.table-highlight{
			background-color:##DDDDDD;
		}
		.table-highlight th{
		background-color:##666666;
		color:##FFFFFF;
		font-weight:bold;
		}
		.table-highlight-bold{
			background-color:##FFFFFF;
			font-weight:bold;
		}
		/* ]]> */
		</style>
		<cfscript>
		searchStruct = StructNew();
		searchStruct.count = qinquiriesCount.count;
		searchStruct.index = form.zIndex;
		searchStruct.showString = "Results ";
		searchStruct.url = "/z/rental/admin/reservations/index?zPageId=#form.zPageId#";
		searchStruct.indexName = "zIndex";
		searchStruct.buttons = 5;
		if(structkeyexists(form, 'searchOn')){		
			searchStruct.perpage = 50;
		}else{
			searchStruct.perpage = zperpage;
		}
		if(searchStruct.count LTE searchStruct.perpage){
			searchNav="";
		}else{
			searchNav = '<table class="table-list" style="width:100%; border-spacing:0px;" >		
		<tr><td style="padding:0px;">'&application.zcore.functions.zSearchResultsNav(searchStruct)&'</td></tr></table>';
		}
		</cfscript>
		#searchNav#
		<table style="border-spacing:0px; width:100%;"  class="table-list">
			<th>ID</th>
				<th><a href="##" onclick="document.manager.sort.value='inquiries_last_name';document.manager.sort_order.value = '#form.sort_order#';document.manager.submit();" style="color:##FFFFFF;">Name</a></th>
				<th><a href="##" onclick="document.manager.sort.value='inquiries_email';document.manager.sort_order.value = '#form.sort_order#';document.manager.submit();" style="color:##FFFFFF;">Email</a>
					<cfif application.zcore.functions.zso(form, "sort") EQ "inquiries_email">
						#form.sort_indicator#
					</cfif></th>
				<th>Cabin</th>
				<th>Start Date</th>
				<th>End Date</th>
				<th>Received</th>
				<th>Admin</th>
			</tr>
			<cfif qinquiries.recordcount EQ 0>
				<tr>
					<td colspan="8" class="table-highlight">No inquiries.</td>
				</tr>
			</cfif>
			<cfloop query="qinquiries">
				<tr <cfif qinquiries.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<td>#qinquiries.inquiries_id#</td>
					<td><a href="mailto:#inquiries_email#">#qinquiries.inquiries_first_name# #qinquiries.inquiries_last_name#</a>&nbsp;</td>
					<td><a href="mailto:#inquiries_email#">#qinquiries.inquiries_email#</a>&nbsp;</td>
					<td>#qinquiries.rental_name#</td>
					<td style="white-space:nowrap;">#DateFormat(qinquiries.inquiries_start_date, "m/d/yy")#</td>
					<td style="white-space:nowrap;">#DateFormat(qinquiries.inquiries_end_date, "m/d/yy")#</td>
					<td style="white-space:nowrap;">#DateFormat(qinquiries.inquiries_datetime, "m/d/yy")# #TimeFormat(qinquiries.inquiries_datetime, "h:mm tt")#&nbsp;</td>
					<td style="white-space:nowrap;">
						<a href="/z/inquiries/admin/manage-inquiries/view?inquiries_id=#qinquiries.inquiries_id#">View</a> | 
						<!--- <a href="/z/inquiries/admin/manage-inquiries/edit?inquiries_id=#qinquiries.inquiries_id#&amp;zpageid=#form.zPageId#">Edit</a> | --->
						<cfif qinquiries.inquiries_reservation_status EQ 2>
							Cancelled
						<cfelse>
							<a href="/z/rental/admin/reservations/cancel?zPageId=#form.zPageId#&amp;inquiries_id=#qinquiries.inquiries_id#">Cancel</a>
						</cfif>
						<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator")>
							<cfif qinquiries.inquiries_status_id NEQ 4 and qinquiries.inquiries_status_id NEQ 5 and qinquiries.inquiries_status_id NEQ 7>
								| <a href="/z/inquiries/admin/assign/index?inquiries_id=#qinquiries.inquiries_id#&amp;zPageId=#form.zPageId#">
								<cfif qinquiries.user_id NEQ 0 or qinquiries.inquiries_assign_email NEQ "">
									Re-
								</cfif>
								Assign</a>
							</cfif>
						</cfif></td>
				</tr>
			</cfloop>
		</table>
		#searchNav#
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>
