<cfcomponent>
<cfoutput>
<cffunction name="displayHeader" localmode="modern" access="public" output="yes">
	<cfscript>
	var selectStruct=0;
	var qAgents=0;
	var userGroupCom=0;
	var user_group_id=0;
	var db=request.zos.queryObject; 
	application.zcore.template.setTag("title", "Leads");
	</cfscript>
	<!--- <h2>Leads</h2> --->
	<!--- <a href="/z/inquiries/admin/manage-inquiries/index?zManagerAddOnLoad=1">Add Lead</a>
	<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator")>
		| <a href="/z/inquiries/admin/manage-inquiries/showAllFeedback">All Feedback</a> | 
	</cfif>
	
	<a href="/z/inquiries/admin/manage-inquiries/index##exportLeadDiv">Export Leads</a> | 
	<a href="/z/inquiries/admin/lead-source-report/index">Source Report</a> | 
		<a href="/z/inquiries/admin/search-engine-keyword-report/index">Keyword Report</a>
	<cfif structkeyexists(request.zos.userSession.groupAccess, "administrator")>
		|		
		<a href="/z/inquiries/admin/autoresponder/index">Autoresponders</a> | 
		<a href="/z/inquiries/admin/routing/index">Routing</a> | 
		<a href="/z/inquiries/admin/types/index">Types</a> | 
		<a href="/z/inquiries/admin/lead-template/index">Templates</a>
	</cfif>
	| <a href="/z/inquiries/admin/manage-inquiries/index">Leads</a>
	<br />
	<hr /> --->
</cffunction>

<cffunction name="getInquiryDataById" localmode="modern" access="public">
	<cfargument name="inquiries_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	inquiries_id = #db.param(arguments.inquiries_id)# and 
	inquiries_deleted=#db.param(0)# ";
	qInquiry=db.execute("qInquiry");
	struct={};
	for(row in qInquiry){
		struct=row;
		s=deserializeJson(row.inquiries_custom_json);
		for(i=1;i LTE arraylen(s.arrCustom);i++){
			struct[s.arrCustom[i].label]=s.arrCustom[i].value;
		}
	}
	return struct;
	</cfscript>
</cffunction>


<cffunction name="getEmailTemplate" localmode="modern" access="public">
	<cfscript>
	var tempText=0;
	var qinquiry=0;
	var tt2=0;
	var pos=0;
	var arrSMS=0;
	var running=0;
	var n=1;
	var cur=0;
	var g=0;
	var db=request.zos.queryObject;
	var viewIncludeCom=0;
        request.znotemplate=1;
        </cfscript>
	<cfsavecontent variable="tempText">#application.zcore.functions.zHTMLDoctype()#
	<head>
	<meta charset="utf-8" />
	<title>Inquiry</title>
	</head>
	
	<body> 
			<cfscript>
			db.sql="SELECT * FROM (#db.table("inquiries", request.zos.zcoreDatasource)# inquiries, 
			#db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status) 
			LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type ON 
			inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
			inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
			inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
			inquiries_type_deleted = #db.param(0)#
			LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
			user.user_id = inquiries.user_id and 
			user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
			user_deleted = #db.param(0)#
			WHERE inquiries.site_id = #db.param(request.zOS.globals.id)# and 	
			inquiries_deleted = #db.param(0)# and 
			inquiries_status_deleted = #db.param(0)# and 
			inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
			inquiries_id = #db.param(form.inquiries_id)# ";
			qinquiry=db.execute("qinquiry");

			application.zcore.functions.zQueryToStruct(qinquiry, form);
			</cfscript>
			<cfif form.user_id NEQ 0>
				<cfif structkeyexists(form, 'groupemail') and form.groupEmail>
					One of your leads has been updated by the client.<br />
					<br />
					<cfelse>
					A lead has been assigned to you.<br />
					<br />
				</cfif>
			</cfif>
			<cfif isDefined('request.noleadsystemlinks') EQ false>
				<cfscript>
				assignDomain=request.zos.currentHostName;
				loginURL="#assignDomain#/z/inquiries/admin/feedback/view";
				if(form.user_id NEQ 0 and form.user_id_siteIDType EQ 1){ 
					if(application.zcore.functions.zso(request.zos.globals, 'publicUserManagerDomain') NEQ ""){
						assignDomain=request.zos.globals.publicUserManagerDomain;
					}
					if(not application.zcore.user.groupIdHasAccessToGroup(form.user_group_id, "member")){ 
						loginURL="#assignDomain#/z/inquiries/admin/manage-inquiries/userView";
					}
				}
				</cfscript>
				You should leave feedback on the lead's status: <br />
				<a href="#loginURL#?inquiries_id=<cfif structkeyexists(form, 'groupemail') and form.groupEmail>#form.inquiries_parent_id#<cfelse>#form.inquiries_id#</cfif>"><strong>Click here to login and leave feedback</strong></a> <br />
				<br />
			</cfif>
			<cfscript>
			// move latest track_user to track_user so the email has the newest tracking information.
			application.zcore.tracking.updateLogs();
			</cfscript>
			<cfif structkeyexists(form, 'groupemail') and form.groupEmail>
				Updated Information:#chr(10)#
			</cfif>
			<cfscript>
			request.usestyleonly=true;
	        viewIncludeCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
			viewIncludeCom.getViewInclude(qinquiry);
			</cfscript> 
	</body>
	</html>
	</cfsavecontent>
	<cfscript>
    writeoutput(tempText);
    /*
	// splits email into multiple sms messages - not used anywhere.
    if(structkeyexists(request, 'cellSMSEmail')){
		tempText = replace(tempText, '  ', ' ','ALL');
		tempText=replace(temptext,"<th ",'<th style="text-align:left; vertical-align:top;" ',"ALL");
		tempText=replace(temptext,"<th>",'<th style="text-align:left;">',"ALL");
		tempText=replace(temptext,'href="/','href="#request.zos.currentHostName#/"',"ALL");
		tempText=replace(temptext,'src="/','src="#request.zos.currentHostName#/"',"ALL");
		tempText=replace(temptext,' class="',' classdis="',"ALL");
		tempText=replace(temptext,'<table ','<table style="font-family:Verdana, Arial, Helvetica, sans-serif; font-size:11px; line-height:18px;"',"ALL");
		tt2="<!-- beginplaintext -->";
		pos=find(tt2,tempText);
		tempText=removechars(tempText,1,pos-1);
		tempText=rereplace(tempText,"<[^>]*>","","ALL");
		tempText=replacelist(tempText,"&amp;,&nbsp;","&, ");
		tempText=replace(tempText,chr(10)," ","ALL");
		tempText=replace(tempText,chr(9)," ","ALL");
		tempText=replace(tempText,chr(13)," ","ALL");
		tempText=rereplacenocase(tempText,"\s*(\S*)", " \1", 'ALL');
		
		arrSMS=arraynew(1);
		running=true;
		t22=tempText;
		n=1;
		while(len(t22) NEQ 0){
		pos=find(" ",reverse(left(t22,140)));
		cur=left(t22,140-pos);
		t22=removechars(t22,1,len(cur));
		arrayappend(arrSMS,cur);
		if(n GTE 5){
			break;	
		}
		n++;
		}
		if(arraylen(arrSMS) EQ 5 and len(arrSMS[5]) GT 107){
			arrSMS[5]=left(arrSMS[5],107)&"| END LIMIT | More is online.";	
		}
		request.arrCellSMS=arrSMS;
		for(g=1;g LTE arraylen(arrSMS);g++){
			mail  to="#request.cellSMSEmail#" from="#request.fromemail#" replyto="#inquiries_email#" subject="###inquiries_id#:#g#of#arraylen(arrSMS)#"{
				writeoutput(arrSMS[g]);
			}
		}
	}*/
	</cfscript>
	<!--- T-Mobile: phonenumber@tmomail.net 
        Virgin Mobile: phonenumber@vmobl.com 
        Cingular: phonenumber@cingularme.com 
        Sprint: phonenumber@messaging.sprintpcs.com
        Verizon: phonenumber@vtext.com
        Nextel: phonenumber@messaging.nextel.com  --->
</cffunction>



<cffunction name="getViewInclude" localmode="modern" access="public">
	<cfargument name="qinquiry" type="query" required="yes">
	<cfscript> 
 	var db=request.zos.queryObject; 
	var t=structnew();
	thstyle="";
	tdstyle="";
	application.zcore.functions.zquerytostruct(arguments.qinquiry, t);
	tablestyle=' style="border-spacing:0px; width:100%;" ';
	if(isDefined('request.usestyleonly')){
		tdstyle = ' font-size:12px; text-align:left;  padding:3px; width: 520px;';
		thstyle = 'white-space:nowrap; font-size:12px; text-align:left; font-weight:bold; padding:3px; background-color:##EFEFEF; width:120px;';
		tablestyle=' width="640" style="font-family:Verdana, Arial, Geneva, sans-serif; font-size:12px; width:640px;" ';
	}
	ts=structnew();
	ts.tablestyle=tablestyle;
	application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts);
	</cfscript>



	<cfscript>
		application.zcore.skin.includeJS( '/z/javascript/jquery/Tokenize2/tokenize2.min.js' );
		application.zcore.skin.includeCSS( '/z/javascript/jquery/Tokenize2/tokenize2.min.css' );
		application.zcore.skin.includeCSS( '/z/javascript/jquery/Tokenize2/custom.css' );
	</cfscript>
	<script type="text/javascript">
		zArrDeferredFunctions.push( function() {
			$('##feedback_to').attr( 'multiple', 'multiple' );
			$('##feedback_to').tokenize2( {
				dataSource: '/z/inquiries/admin/inquiry/tokenTest',
				searchFromStart: false
			} );

			$('##feedback_cc').attr( 'multiple', 'multiple' );
			$('##feedback_cc').tokenize2( {
				dataSource: '/z/inquiries/admin/inquiry/tokenTest',
				searchFromStart: false
			} );
		} );
	</script>

	<span #tablestyle#>
	<table #tablestyle# class="table-list">



		<tr>
			<th style="#thstyle#">To:</th>
			<td style="#tdstyle#">
				<cfscript>
					// The selected options are pulled from the inquiries_x_contact table
					// inquiries_x_contact_type = to or cc respectively

					db.sql = 'SELECT inquiries_x_contact.inquiries_x_contact_type, contact.contact_id, contact.contact_email, contact.contact_first_name, contact.contact_last_name
						FROM #db.table( 'inquiries_x_contact', request.zos.zcoreDatasource )# AS inquiries_x_contact,
							#db.table( 'contact', request.zos.zcoreDatasource )# AS contact
						WHERE inquiries_x_contact.site_id = #db.param( request.zos.globals.id )#
							AND inquiries_x_contact.inquiries_x_contact_deleted = #db.param( 0 )#
							AND contact.contact_id = inquiries_x_contact.contact_id
							AND contact.site_id = inquiries_x_contact.site_id
							AND contact.contact_deleted = #db.param( 0 )#
						ORDER BY contact.contact_email ASC';
					qContact = db.execute( 'qContact' );

					toArray = [];
					ccArray = [];

					if ( qContact.recordcount GT 0 ) {
						for ( row in qContact ) {
							if ( row.inquiries_x_contact_type EQ 'to' ) {
								arrayAppend( toArray, row );
							} else if ( row.inquiries_x_contact_type EQ 'cc' ) {
								arrayAppend( ccArray, row );
							}
						}
					}
				</cfscript>

				<select id="feedback_to" name="feedback_to" multiple="multiple">
					<cfloop from="1" to="#arrayLen( toArray )#" index="toItemIndex">
						<cfscript>toItem = toArray[ toItemIndex ];</cfscript>
						<cfif toItem.contact_first_name NEQ ''>
							<cfif toItem.contact_last_name NEQ ''>
								<option value="#toItem.contact_id#" selected="selected">#toItem.contact_first_name# #toItem.contact_last_name# (#toItem.contact_email#)</option>
							<cfelse>
								<option value="#toItem.contact_id#" selected="selected">#toItem.contact_first_name# (#toItem.contact_email#)</option>
							</cfif>
						<cfelse>
							<option value="#toItem.contact_id#" selected="selected">(#toItem.contact_email#)</option>
						</cfif>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<th style="#thstyle#">CC:</th>
			<td style="#tdstyle#">
				<select id="feedback_cc" name="feedback_cc" multiple="multiple">
					<cfloop from="1" to="#arrayLen( ccArray )#" index="ccItemIndex">
						<cfscript>ccItem = ccArray[ ccItemIndex ];</cfscript>
						<cfif ccItem.contact_first_name NEQ ''>
							<cfif ccItem.contact_last_name NEQ ''>
								<option value="#ccItem.contact_id#" selected="selected">#ccItem.contact_first_name# #ccItem.contact_last_name# (#ccItem.contact_email#)</option>
							<cfelse>
								<option value="#ccItem.contact_id#" selected="selected">#ccItem.contact_first_name# (#ccItem.contact_email#)</option>
							</cfif>
						<cfelse>
							<option value="#ccItem.contact_id#" selected="selected">(#ccItem.contact_email#)</option>
						</cfif>
					</cfloop>
				</select>

				<button type="button" onclick="javascript:alert($('##feedback_to').val());">Test</button>

<!---
				<cfscript>
					userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
					db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
					WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
					user_deleted = #db.param(0)# and
					user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# and (user_server_administrator=#db.param(0)# )
					ORDER BY member_first_name ASC, member_last_name ASC ";
					qAgents=db.execute("qAgents");
					selectStruct = StructNew();
					selectStruct.name = "feedback_cc";
					selectStruct.query = qAgents;
					selectStruct.queryLabelField = "##user_first_name## ##user_last_name## (##user_username##)";
					selectStruct.queryParseLabelVars = true;
					selectStruct.queryValueField = 'user_id';
					application.zcore.functions.zInputSelectBox(selectStruct);
				</cfscript>
--->
			</td>
		</tr>



		<!-- startadmincomments -->
		<!--- <cfif isReservationSystem EQ false> --->
		<cfif t.inquiries_referer NEQ '' or t.inquiries_referer2 NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left; ">Last 2 Pages:</th>
				<td style="#tdstyle#">Clicking on these links can help you understand what the user was looking at when submitting the inquiry.<br />
					<cfif t.inquiries_referer CONTAINS 'google.com/aclk'>
Link 1 disabled since this may cause a duplicate google adwords PPC click						<br />
						<cfelseif t.inquiries_referer NEQ ''>
						<a href="#t.inquiries_referer#" target="_blank">Click to view referring page 1</a><br />
					</cfif>
					<cfif t.inquiries_referer2 CONTAINS 'google.com/aclk'>
Link 2 disabled since this may cause a duplicate google adwords PPC click						<br />
						<cfelseif t.inquiries_referer2 NEQ ''>
						<a href="#t.inquiries_referer2#" target="_blank">Click to view referring page 2</a><br />
					</cfif></td>
			</tr>
		</cfif>
		<cfif t.inquiries_email NEQ "">
			<cfscript>
			db.sql="SELECT * FROM #db.table("track_user", request.zos.zcoreDatasource)# track_user 
			WHERE track_user.site_id =#db.param(request.zOS.globals.id)# AND 
			((track_user_email =#db.param(t.inquiries_email)# and 
			track_user_datetime BETWEEN #db.param(dateformat(t.inquiries_datetime, 'yyyy-mm-dd')&' 00:00:00')# and #db.param(dateformat(t.inquiries_datetime, 'yyyy-mm-dd')&' 23:59:59')#) or 
			inquiries_id=#db.param(t.inquiries_id)#)  and 
			track_user_deleted = #db.param(0)#
			LIMIT #db.param(0)#,#db.param(1)#";
			qTrack=db.execute("qTrack");


			</cfscript>
			<cfif qTrack.recordcount NEQ 0>
				<cfloop query="qTrack">
				<tr>
					<th style="#thstyle# text-align:left;">Tracking:</th>
					<td style="#tdstyle#">
						
					<cfif dateformat(qTrack.track_user_datetime,'yyyymmdd') GT 20111121>
						<cfif qTrack.track_user_ppc EQ 1 or qTrack.track_user_first_page CONTAINS "gclid=">
							<strong>Google Adwords Pay Per Click Lead</strong><br />
						</cfif>
						<cfif qTrack.track_user_source NEQ "">
						<strong>Source: #qTrack.track_user_source#</strong><br />
						</cfif>
					<cfelse>
						<cfscript>
						db.sql="SELECT count(track_page_id) count 
						FROM #db.table("track_page", request.zos.zcoreDatasource)# track_page 
						WHERE site_id =#db.param(request.zOS.globals.id)# and 
						track_user_id =#db.param(track_user_id)# and 
						track_page_deleted = #db.param(0)# and 
						track_page_qs LIKE #db.param('%gclid=%')#";
						qPage=db.execute("qPage");
						</cfscript>
						<cfif qPage.recordcount NEQ 0 and qPage.count NEQ 0>
							<strong>Google Adwords Pay Per Click Lead</strong><br />
						</cfif>
					</cfif>
					
					<cfif qTrack.track_user_referer NEQ "">
						<cfif qTrack.track_user_ppc EQ 1>
							<cfscript>
							    arrU=listtoarray(qTrack.track_user_referer,"&");
							    for(i894=1;i894 LTE arraylen(arrU);i894++){
								if(left(arrU[i894],2) EQ "q="){
								    writeoutput("Google PPC Keyword: "&urldecode(removechars(arrU[i894],1,2))&"<br />");
								}
							    }
							    </cfscript>
						<cfelse>
							Source URL: <a href="#qTrack.track_user_referer#" target="_blank">#left(qTrack.track_user_referer,50)#...</a><br />
						</cfif>
					</cfif>
					<cfif qTrack.track_user_keywords NEQ "">
						Keyword:#qTrack.track_user_keywords#<br />
					</cfif>
					<cfscript>

						formattedDate=DateFormat(qTrack.track_user_datetime,'yyyy-mm-dd')&' '&TimeFormat(qTrack.track_user_datetime,'HH:mm:ss');
						firstDate=parsedatetime(formattedDate);
						formattedDate2=DateFormat(qTrack.track_user_recent_datetime,'yyyy-mm-dd')&' '&TimeFormat(qTrack.track_user_recent_datetime,'HH:mm:ss');
						if(isdate(formattedDate2)){
						lastDate=parsedatetime(formattedDate2);
						}else{
							lastDate=firstDate;	
						}
						seconds=DateDiff("s", formattedDate, formattedDate2);

						if(qTrack.track_user_session_length NEQ 0){
							seconds=qTrack.track_user_session_length;
							if(seconds GT 86400){
								minutes=fix(seconds/60/60/24)&' days ';
							}else{
								minutes=fix(seconds/60)&' minutes ';
								if(fix(seconds/60) EQ 0){
									minutes="";
								}
								if(seconds MOD 60 NEQ 0){
									minutes=minutes&(seconds MOD 60)&' seconds';
								}
							}
							echo('Length of visit: #minutes#<br />');
						}
						if(qTrack.track_user_seconds_since_first_visit NEQ 0){
							seconds=qTrack.track_user_seconds_since_first_visit;
							if(seconds GT 86400){
								minutes=fix(seconds/60/60/24)&' days ';
							}else{
								minutes=fix(seconds/60)&' minutes ';
								if(fix(seconds/60) EQ 0){
									minutes="";
								}
								if(seconds MOD 60 NEQ 0){
									minutes=minutes&(seconds MOD 60)&' seconds';
								}
							}
							echo('Time since first visit: #minutes#<br />');
						}
						if(qTrack.track_user_hits GT 1){
							echo('Clicks: #qTrack.track_user_hits#<br />');
						}
						if(qTrack.track_user_first_page NEQ ""){
							echo('Landing Page: <a href="#request.zos.globals.domain##qTrack.track_user_first_page#" target="_blank">Click here</a> to view the first page they visited on the web site.');
						}
					/*
					// this code was inefficient.  The new cookie "Enable User Stats Cookies" feature is able to be enabled per site instead to reduce server load for tracking.
					db.sql="SELECT count(track_page_id) count, min(track_page_datetime) minDate , max(track_page_datetime) maxDate 
					FROM #db.table("track_page", request.zos.zcoreDatasource)#  
					WHERE site_id =#db.param(request.zOS.globals.id)# and 
					track_user_id =#db.param(qTrack.track_user_id)# and 
					track_page_datetime BETWEEN #db.param(dateformat(t.inquiries_datetime, 'yyyy-mm-dd')&' 00:00:00')# and #db.param(dateformat(t.inquiries_datetime, 'yyyy-mm-dd')&' 23:59:59')# and 
					track_page_deleted = #db.param(0)#
					LIMIT #db.param(0)#,#db.param(1)#";
					qTrackPage=db.execute("qTrackPage"); 

					if(qTrackPage.recordcount and qTrackPage.count GT 1){ 
						formattedDate=DateFormat(qTrackPage.minDate,'yyyy-mm-dd')&' '&TimeFormat(qTrackPage.minDate,'HH:mm:ss');
						firstDate=parsedatetime(formattedDate);
						formattedDate2=DateFormat(qTrackPage.maxDate,'yyyy-mm-dd')&' '&TimeFormat(qTrackPage.maxDate,'HH:mm:ss');
						if(isdate(formattedDate2)){
						lastDate=parsedatetime(formattedDate2);
						}else{
							lastDate=firstDate;	
						}
						seconds=DateDiff("s", formattedDate, formattedDate2);
						minutes=fix(seconds/60)&'mins ';
						if(fix(seconds/60) EQ 0){
							minutes="";
						}
						if(seconds MOD 60 NEQ 0){
							minutes=minutes&(seconds MOD 60)&'secs';
						}
						echo('Length of Visit:#minutes#<br />');
						echo('Clicks:#qTrackPage.count#<br />');
						db.sql="SELECT * FROM #db.table("track_page", request.zos.zcoreDatasource)# track_page 
						WHERE site_id =#db.param(request.zOS.globals.id)# AND 
						track_user_id =#db.param(qTrack.track_user_id)# and 
						track_page_datetime <=#db.param(dateformat(qTrack.track_user_recent_datetime, 'yyyy-mm-dd')&' '&timeformat(qTrack.track_user_recent_datetime,'HH:mm:ss'))# and 
						track_page_deleted = #db.param(0)# 
						ORDER BY track_page_datetime ASC 
						LIMIT #db.param(0)#,#db.param(1)#";
						qTrack2=db.execute("qTrack2");
						echo('Landing Page:<a href="#qTrack2.track_page_script#?#htmleditformat(qTrack2.track_page_qs)#" target="_blank">Click here</a> to view the first page they visited on the web site.');


					} */
					</cfscript>
					</td>
				</tr>
				</cfloop>
			</cfif>
		</cfif>
		<tr>
			<th style="#thstyle# text-align:left;">Type:</th>
			<td style="#tdstyle#"><cfif arguments.qinquiry.inquiries_type_name EQ ''>
#t.inquiries_type_other#
					<cfelse>
					#arguments.qinquiry.inquiries_type_name#
				</cfif>
				&nbsp;
				<cfif trim(t.inquiries_phone_time) NEQ ''>
/					<strong>Forced</strong>
				</cfif></td>
		</tr>
		<tr>
			<th style="#thstyle# text-align:left;" >Status:</th>
			<td style="#tdstyle#">
						#t.inquiries_status_name#
			</td>
		</tr>
		<tr>
			<th style="#thstyle# text-align:left;" >Assigned&nbsp;To:</th>
			<td style="#tdstyle#"> 
			 <cfif t.inquiries_assign_email NEQ ''> 
				<cfscript>
				arrEmail=listToArray(t.inquiries_assign_email, ",");
				for(i=1;i<=arraylen(arrEmail);i++){
					e=arrEmail[i];
					if(i NEQ 1){
						echo(', ');
					}
					echo('<a href="mailto:#e#">');
					if(structkeyexists(t, 'inquiries_assign_name') and t.inquiries_assign_name neq '' and arraylen(arrEmail) EQ 1){
						echo(t.inquiries_assign_name);
					}else{
						echo(e);
					}
					echo('</a>');
				}
				</cfscript> 
			<cfelse>
				<cfif t.user_id NEQ 0>
					<cfif t.user_first_name NEQ "">
						<a href="mailto:#t.user_username#">#t.user_first_name# #t.user_last_name# 
						<cfif t.member_company NEQ "">
							(#t.member_company#)
						</cfif></a>
					<cfelse>
						<a href="mailto:#t.user_username#">#t.user_username#</a>
					</cfif> 
				</cfif>
			</cfif></td>
		</tr>
		<!-- endadmincomments -->
		<cfif t.inquiries_spam EQ 1>
		<tr>
			<th style="#thstyle# text-align:left;" >&nbsp;</th>
			<td style="#tdstyle# width:90%;"><strong>This inquiry may be SPAM</strong><br>
				Spam Filter Reported: #t.inquiries_spam_description#
			</td>
		</tr>
		</cfif>
		<tr>
			<th style="#thstyle# text-align:left;" >Date Received:</th>
			<td style="#tdstyle# width:90%;">#DateFormat(t.inquiries_datetime, "m/dd/yyyy")# at #Timeformat(t.inquiries_datetime, "h:mm tt")#</td>
		</tr>
		<!-- beginplaintext -->
		<cfif application.zcore.functions.zso(t, 'inquiries_image') NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Image:</th>
				<td style="#tdstyle#"><a href="/z/misc/download/index?fp=#urlencodedformat('/zupload/user/#t.inquiries_image#')#">Download File</a></td>
			</tr>
		</cfif>
		<!--- <cfif isReservationSystem>
	<tr>
		<th style="#thstyle# text-align:left;" width="80">Reservation:</th>
		<td style="#tdstyle#"><cfif t.inquiries_reservation EQ 1>Yes<cfelse>No</cfif></td>
	</tr>
	<cfsavecontent variable="db.sql">
	SELECT * FROM #db.table("property", request.zos.zcoreDatasource)# property 
	WHERE property_id = #db.param(t.property_id)# and 
	property_deleted = #db.param(0)# 
	</cfsavecontent><cfscript>qprop=db.execute("qprop");</cfscript>
	
	<cfif qprop.recordcount NEQ 0>
	<tr>
		<th style="#thstyle# text-align:left;" >Property:</th>
		<td style="#tdstyle#"><a href="#qprop.property_url#" target="_blank">#qprop.property_name#</a></td>
	</tr>
	</cfif>
	</cfif> --->
		<cfif application.zcore.functions.zso(t, 'inquiries_start_date') NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Start Date:</th>
				<td style="#tdstyle#">#DateFormat(t.inquiries_start_date, "m/dd/yyyy")#</td>
			</tr>
		</cfif>
		<cfif application.zcore.functions.zso(t, 'inquiries_end_date') NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >End Date:</th>
				<td style="#tdstyle#">#DateFormat(t.inquiries_end_date, "m/dd/yyyy")#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_buyer')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;">Looking to:</th>
				<td style="#tdstyle#"><cfif t.inquiries_buyer EQ 1 or t.inquiries_type_id NEQ 6>
Buy Real Estate
						<cfelse>
						<strong>Sell Real Estate</strong>
					</cfif></td>
			</tr>
		</cfif>
		<cfif trim(t.inquiries_first_name) NEQ '' or trim(t.inquiries_last_name) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;">Name:</th>
				<td style="#tdstyle#">#application.zcore.functions.zFirstLetterCaps(t.inquiries_first_name)# #application.zcore.functions.zFirstLetterCaps(t.inquiries_last_name)#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(t.inquiries_email) NEQ ''>
			<cfif isDefined('request.zsession.user.id')>
				<cfscript>
				db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user 
				WHERE user_id =#db.param(request.zsession.user.id)# and 
				user_deleted = #db.param(0)# and 
				site_id =#db.param(request.zsession.user.site_id)#";
				qmem2=db.execute("qmem2");
				</cfscript>
			</cfif>
			<tr>
				<th style="#thstyle# text-align:left;" >Email:</th>
				<td style="#tdstyle#"><a href="mailto:#t.inquiries_email#<cfif isDefined('request.zsession.user.id')>?subject=#URLEncodedFormat('RE: Your web site inquiry')#&body=#URLEncodedFormat('Dear '&trim(t.inquiries_first_name&' '&t.inquiries_last_name)&','&chr(10)&chr(10)&chr(9))#<cfif trim(t.inquiries_comments) NEQ ''>#URLEncodedFormat(chr(10)&chr(10)&'------------------------------------------------------'&chr(10)&'On '&DateFormat(t.inquiries_datetime, "mmmm d")&', you wrote: '&chr(10)&chr(10)&replacenocase(left(t.inquiries_comments,1200),"<br />",chr(10),"ALL"))#<cfif len(t.inquiries_comments) GT 1200>...</cfif></cfif></cfif>">#t.inquiries_email#</a>&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(t.inquiries_phone_time) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Contact by:</th>
				<td style="#tdstyle#"><cfif t.inquiries_phone_time EQ 'email'>
Email Only
						<cfelseif t.inquiries_phone_time EQ 'evening'>
						Phone in the Evening
						<cfelseif t.inquiries_phone_time EQ 'day'>
						Phone during the day
					</cfif>
					&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(t.inquiries_phone1) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Phone 1:</th>
				<td style="#tdstyle#">#t.inquiries_phone1#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(t.inquiries_fax) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Fax:</th>
				<td style="#tdstyle#">#t.inquiries_fax#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(t.inquiries_company) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Company:</th>
				<td style="#tdstyle#">#t.inquiries_company#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(t.inquiries_phone2) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Phone 2:</th>
				<td style="#tdstyle#">#t.inquiries_phone2#(cell)&nbsp;</td>
			</tr>
		</cfif>
		<cfif isDefined('t.inquiries_phone3') and trim(t.inquiries_phone3) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Phone 3:</th>
				<td style="#tdstyle#">#t.inquiries_phone3#(home)&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_address')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Address:</th>
				<td style="#tdstyle#">#t.inquiries_address#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_address2')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Address 2:</th>
				<td style="#tdstyle#">#t.inquiries_address2#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_property_address')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Address:</th>
				<td style="#tdstyle#">#t.inquiries_property_address#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_city')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >City:</th>
				<td style="#tdstyle#">#t.inquiries_city#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_state')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >State:</th>
				<td style="#tdstyle#">#t.inquiries_state#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_zip')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Zip Code:</th>
				<td style="#tdstyle#">#t.inquiries_zip#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_owner_relationship')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;">Relation:</th>
				<td style="#tdstyle#">#t.inquiries_owner_relationship#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_owner')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;">Taxpayer&nbsp;Name:</th>
				<td style="#tdstyle#">#t.inquiries_owner#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_sponsor')) EQ '1'>
			<tr>
				<th style="#thstyle# text-align:left;" >&nbsp;</th>
				<td style="#tdstyle#"><strong>Wants to become a sponsor</strong></td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_year_built')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Year Built:</th>
				<td style="#tdstyle#">#t.inquiries_year_built#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_country')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Country:</th>
				<td style="#tdstyle#">#t.inquiries_country#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_adults')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Adults:</th>
				<td style="#tdstyle#">#t.inquiries_adults#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_children')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Children:</th>
				<td style="#tdstyle#">#t.inquiries_children#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_children_age')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left; white-space:nowrap;">Children&nbsp;Under&nbsp;3:</th>
				<td style="#tdstyle#">#t.inquiries_children_age#&nbsp;</td>
			</tr>
		</cfif>
		<cfif application.zcore.functions.zso(t, 'inquiries_pets',true) NEQ '0'>
			<tr>
				<th style="#thstyle# text-align:left;white-space:nowrap;">##of pets:</th>
				<td style="#tdstyle#">#t.inquiries_pets#</td>
			</tr>
		</cfif>
		<cfif trim(t.inquiries_interest_level) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Interest Level:</th>
				<td style="#tdstyle#">#t.inquiries_interest_level#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(t.inquiries_interested_in_category) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Interested In Category:</th>
				<td style="#tdstyle#">#t.inquiries_interested_in_category#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(t.inquiries_interested_in_model) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Interested In Model:</th>
				<td style="#tdstyle#">#t.inquiries_interested_in_model#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_comments')) NEQ ''>
			<tr>
				<th style="#thstyle# vertical-align:top;text-align:left;">Comments:</th>
				<td style="#tdstyle#">
					<cfif t.inquiries_comments does not contain "</">
						#wrap(replace(t.inquiries_comments, chr(10), "<br>", "all"), 120)#
					<cfelse>
						#replace(t.inquiries_comments, chr(10), "<br>", "all")#
					</cfif></td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_custom_json')) NEQ ''>
			<cfscript>
			var jsonStruct=deserializejson(t.inquiries_custom_json);
			for(var i=1;i LTE arrayLen(jsonStruct.arrCustom);i++){
				if(jsonStruct.arrCustom[i].value EQ ""){
					continue;
				}
				if(len(jsonStruct.arrCustom[i].label) GT 30){
					writeoutput('
					<tr>
						<th style="#thstyle# vertical-align:top;text-align:left;">&nbsp;</th>
						<td style="#tdstyle#">
						<p>'&htmleditformat(jsonStruct.arrCustom[i].label)&'</p>
						<p>'&replace(jsonStruct.arrCustom[i].value, chr(10), "<br>", "all")&'</p></td>
					</tr>
					');	
				}else{
					writeoutput('
					<tr>
						<th style="#thstyle# vertical-align:top;text-align:left;">'&htmleditformat(jsonStruct.arrCustom[i].label)&'</th>
						<td style="#tdstyle#">'&replace(jsonStruct.arrCustom[i].value, chr(10), "<br>", "all")&'</td>
					</tr>
					');	
				}
			}
			</cfscript>
		</cfif>
		
		
		<cfif trim(application.zcore.functions.zso(t,'region')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Region:</th>
				<td style="#tdstyle#">#t.region#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t,'services')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Services:</th>
				<td style="#tdstyle#">#t.services#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t,'water_activities')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Water Activities:</th>
				<td style="#tdstyle#">#t.water_activities#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_apartment_size')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Apartment Size:</th>
				<td style="#tdstyle#">#t.inquiries_apartment_size#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_move_date')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Move Date:</th>
				<td style="#tdstyle#">#t.inquiries_move_date#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_number_occupants')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Number of Occupants:</th>
				<td style="#tdstyle#">#t.inquiries_number_occupants#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_referred_by')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Referred By:</th>
				<td style="#tdstyle#">#t.inquiries_referred_by#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t,'date_of_trip')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Trip Date:</th>
				<td style="#tdstyle#">#t.date_of_trip#</td>
			</tr>
		</cfif>
		<cfsavecontent variable="propInfo222">
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_property_type')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Property Type:</th>
				<td style="#tdstyle#">#t.inquiries_property_type#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_view')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >View/Frontage:</th>
				<td style="#tdstyle#">#t.inquiries_view#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_type_other')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Other Property Type:</th>
				<td style="#tdstyle#">#t.inquiries_type_other#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_property_city')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >City:</th>
				<td style="#tdstyle#">#t.inquiries_property_city#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_price_low',true)) NEQ '0'>
			<tr>
				<th style="#thstyle# text-align:left;" >Price:</th>
				<td style="#tdstyle#">#DollarFormat(t.inquiries_price_low)#-#DollarFormat(t.inquiries_price_high)#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_bedrooms')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Bedrooms:</th>
				<td style="#tdstyle#">#t.inquiries_bedrooms#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_bathrooms')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Bathrooms:</th>
				<td style="#tdstyle#">#t.inquiries_bathrooms#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_sqfoot')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >
					<cfif t.inquiries_type_id EQ 6>
						Home Sq/Ft
					<cfelse>
						Square Foot
					</cfif>
					:</th>
				<td style="#tdstyle#">#t.inquiries_sqfoot#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_lot_sqfoot')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Lot Sq/Ft:</th>
				<td style="#tdstyle#">#t.inquiries_lot_sqfoot#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_location')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Location:</th>
				<td style="#tdstyle#">#t.inquiries_location#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_location2')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Location 2:</th>
				<td style="#tdstyle#">#t.inquiries_location2#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_location3')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Location 3:</th>
				<td style="#tdstyle#">#t.inquiries_location3#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_garage')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >Garage:</th>
				<td style="#tdstyle#">#t.inquiries_garage#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_pool')) EQ '1'>
			<tr>
				<th style="#thstyle# text-align:left;" >Pool:</th>
				<td style="#tdstyle#">Yes&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_target_price', true)) NEQ '0'>
			<tr>
				<th style="#thstyle# text-align:left;" >Target Price:</th>
				<td style="#tdstyle#">$#numberformat(t.inquiries_target_price)#</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_prequalified')) EQ '1'>
			<tr>
				<th style="#thstyle# text-align:left;" >Prequalified:</th>
				<td style="#tdstyle#">Yes&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_when_move')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >&nbsp;</th>
				<td style="#tdstyle#">Wants to move in:#t.inquiries_when_move#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_own_home')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >&nbsp;</th>
				<td style="#tdstyle#">
					<cfif t.inquiries_own_home EQ 1>
						Owns a home
					<cfelseif t.inquiries_own_home EQ 0>
						Doesn't own a home
					</cfif></td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_sell_home')) NEQ '' and t.inquiries_sell_home EQ 1>
			<tr>
				<th style="#thstyle# text-align:left;" >&nbsp;</th>
				<td style="#tdstyle#">Would like to sell their home </td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_referred_by')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >&nbsp;</th>
				<td style="#tdstyle#">Referred By:#t.inquiries_referred_by#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_look_time')) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" >&nbsp;</th>
				<td style="#tdstyle#">Has been looking for a property for:#t.inquiries_look_time#&nbsp;</td>
			</tr>
		</cfif>
		<cfif trim(application.zcore.functions.zso(t, 'inquiries_other_realtors')) EQ '1'>
			<tr>
				<th style="#thstyle# text-align:left;" >&nbsp;</th>
				<td style="#tdstyle#">Working with another agent: Yes&nbsp;</td>
			</tr>
		</cfif>
		</cfsavecontent>
		<cfif trim(propInfo222) NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" colspan="2">Property Information</th>
			</tr>
			#propInfo222#
		</cfif>
		<!--- </cfif> --->
		<cfif isDefined('t.inquiries_loan_city') and trim(t.inquiries_loan_city&t.inquiries_loan_own&t.inquiries_loan_price) NEQ "">
			<tr>
				<th style="#thstyle# text-align:left;" width="120">Loan Property Location</th>
				<td style="#tdstyle#">#t.inquiries_loan_city#</td>
			</tr>
			<tr>
				<th style="#thstyle# text-align:left;" width="120">Loan Rent or Own:</th>
				<td style="#tdstyle#">#t.inquiries_loan_own#</td>
			</tr>
			<tr>
				<th style="#thstyle# text-align:left;" width="120">Loan Purchase Price</th>
				<td style="#tdstyle#">#t.inquiries_loan_price#</td>
			</tr>
			<tr>
				<th style="#thstyle# text-align:left;" width="120">Loan Amount</th>
				<td style="#tdstyle#">#t.inquiries_loan_amount#</td>
			</tr>
			<tr>
				<th style="#thstyle# text-align:left;" width="120">Loan Program</th>
				<td style="#tdstyle#">#t.inquiries_loan_program#</td>
			</tr>
			<tr>
				<th style="#thstyle# text-align:left;" width="120">Loan Property Use</th>
				<td style="#tdstyle#">#t.inquiries_loan_property_use#</td>
			</tr>
			<tr>
				<th style="#thstyle# text-align:left;" width="120">Loan Property Type</th>
				<td style="#tdstyle#">#t.inquiries_loan_property_type#</td>
			</tr>
		</cfif> 
		<!-- startadmincomments -->
		<cfif t.inquiries_admin_comments NEQ ''>
			<tr>
				<th style="#thstyle# text-align:left;" colspan="2">Office Administrative Comments</th>
			</tr>
			<tr>
				<td colspan="2">#application.zcore.functions.zParagraphFormat(t.inquiries_admin_comments)#</td>
			</tr>
		</cfif>
		<!-- endadmincomments -->
	</table>
	<br />
	<cfif t.rental_id NEQ "" and t.rental_id NEQ "0">
		<h2>Selected Rental</h2>
		<cfscript>
		ts=structnew();
		ts.rental_id_list=t.rental_id;
		ts.email=true;
		var rentalFrontCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.mvc.z.rental.controller.rental-front");
		rentalFrontCom.includeRentalById(ts);
		</cfscript>
	</cfif>
	<cfif application.zcore.app.siteHasApp("listing")>
		<cfscript>
		db.sql="SELECT * FROM #db.table("mls_saved_search", request.zos.zcoreDatasource)# mls_saved_search 
		WHERE saved_search_email<>#db.param('')# and 
		mls_saved_search_deleted = #db.param(0)# and 
		saved_search_email =#db.param(t.inquiries_email)# and 
		site_id =#db.param(request.zOS.globals.id)#";
		qSearch=db.execute("qSearch");
		</cfscript>
		<cfif qSearch.recordcount NEQ 0>
			<table class="table-list" #tablestyle#>
				<tr>
					<th style="#thstyle# text-align:left;" >Saved Searches</th>
				</tr>
				<tr>
					<td style="#tdstyle#"><cfloop from="1" to="#qsearch.recordcount#" index="i">
						<cfscript>
searchStr=StructNew();
application.zcore.functions.zquerytostruct(qsearch,searchStr,'',i);
</cfscript>
						Saved Search #i#: #ArrayToList(request.zos.listing.functions.getSearchCriteriaDisplay(searchStr),', ')#<br />
						<br />
						</cfloop></td>
				</tr>
			</table>
		</cfif>
	</cfif>
	<cfif application.zcore.app.siteHasApp("content")>
		<cfscript>
	ts4=structnew();
	ts4.contentEmailFormat=true;
	ts4.showmlsnumber=true;
	application.zcore.app.getAppCFC("content").setContentIncludeConfig(ts4);
		propertyDataCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyData");
		propDisplayCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.listing.controller.propertyDisplay");
	</cfscript>
		<cfif application.zcore.functions.zso(t,'content_id') NEQ 0 and application.zcore.functions.zso(t,'content_id') NEQ "">
			<br />
			<h2>Inquiring about
				<cfif t.content_id CONTAINS ",">
					these page(s)
				<cfelse>
					this page
				</cfif>
				:</h2>
			<cfscript>
			contentIdList="'"&replace(replace(application.zcore.functions.zso(t,'content_id'),"'","","ALL"),",","','","ALL")&"'";
			db.sql="SELECT * FROM #db.table("content", request.zos.zcoreDatasource)# content 
			WHERE content.site_id =#db.param(request.zOS.globals.id)# and 
			content_id IN (#db.trustedSQL(contentIdList)#)  and 
			content_for_sale <>#db.param(2)# and 
			content_deleted =#db.param(0)#
			ORDER BY content_sort ASC, content_datetime DESC, content_created_datetime DESC 
			LIMIT #db.param(0)# , #db.param(1)#";
			qC39821n=db.execute("qC39821n");
			for(local.row in qC39821n){
				propDisplayCom.contentEmailTemplate(local.row);
			}
			</cfscript>
		</cfif>
		<br />
		<cfscript>
	
		if(application.zcore.functions.zso(t,'property_id') NEQ '' and application.zcore.functions.zso(t,'property_id') NEQ '0'){
			writeoutput('<h2>Property Inquiry</h2>');
			writeoutput('<p>The listings below were selected by this contact.</p>');
			arrP=listtoarray(t.property_id);
			for(i=1;i LTE arraylen(arrP);i++){
				ts = StructNew();
				ts.offset = 0;
				ts.perpage = 100;
				ts.distance = 30; // in miles
				ts.arrMLSPID=ArrayNew(1);
				ArrayAppend(ts.arrMLSPID, arrP[i]);
				if(listlen(arrP[i],"-") NEQ 2){
					application.zcore.template.fail("Inquiry ###t.inquiries_id# has the wrong listing_id format, ""#ts.arrMLSPid[i]#""");
				}
				tempMlsId=listgetat(arrP[i],1,"-");
				tempMlsPid=listgetat(arrP[i],2,"-");
				tempMLSStruct=application.zcore.listingCom.getMLSStruct(tempMLSId);
				if(isStruct(tempMLSStruct)){
					if(tempMLSStruct.mls_login_url NEQ ''){
						writeoutput('MLS ###tempMLSPid# found in #tempMLSStruct.mls_name# MLS, <a href="#tempMLSStruct.mls_login_url#" target="_blank">click here to login to MLS</a><br />');
					}else{
						writeoutput('MLS ###tempMLSPid# found in #tempMLSStruct.mls_name# MLS<br />');
					}
					returnStruct = propertyDataCom.getProperties(ts);
					structdelete(variables,'ts');
					//	zdump(returnstruct);
					if(returnStruct.count NEQ 0){	
						ts = StructNew();
						//ts.showInactive=true;
						ts.searchScript=false;
						ts.emailFormat=true;
						ts.hideMLSNumber=true;
						ts.compact=true;
						ts.permanentImages=true;
						ts.dataStruct = returnStruct;
						propDisplayCom.init(ts);
						res=propDisplayCom.display();
						writeoutput(res);
					}else{
						writeoutput('This listing is no longer active, please look in the MLS for more information.<hr /><br />');
					}
				}
			}
		}
		</cfscript>
	</cfif>
	<br />
	</span>
</cffunction>
</cfoutput>
</cfcomponent>