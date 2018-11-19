<cfcomponent>
<!--- <cfoutput>
<!--- disabled until i'm ready. --->
disabled<cfscript>application.zcore.functions.zabort();</cfscript>
<!--- <CFPOP 
ACTION="getall"
NAME="qHeader"
SERVER=""
USERNAME=""
PASSWORD="" 
timeout="100"
>
<cfscript>
application.mypopquery=qheader;
</cfscript>
done
<cfscript>application.zcore.functions.zabort();</cfscript> --->

<cfscript> 
db=request.zos.queryObject;
form.action=application.zcore.functions.zso(form, 'action',false,'list');
emailCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.app.email");
if(application.zcore.user.checkServerAccess() EQ false){
	form.sid=request.zos.globals.id;
}
if(structkeyexists(form, 'zid') EQ false){
	form.zid = application.zcore.status.getNewId();
	if(structkeyexists(form, 'sid')){
		application.zcore.status.setField(form.zid, 'site_id',form.sid);
	}
}
if(isDefined('zCampaignIndex')){
	application.zcore.status.setField(form.zid, "zCampaignIndex", zCampaignIndex);
}else{
	zCampaignIndex = application.zcore.status.getField(form.zid, "zCampaignIndex");
	if(zCampaignIndex EQ ""){
		zCampaignIndex = 1;
	}
}
form.sid = application.zcore.status.getField(form.zid, 'site_id');
if(form.sid EQ '1'){
	application.zcore.functions.zRedirect(request.cgi_script_name);
} 
request.zscriptname=request.cgi_script_name&"?zid=#form.zid#&sid=#form.sid#";

	application.zcore.functions.zstatushandler(request.zsid);
	</cfscript>
    <!--- <a href="#request.cgi_script_name#?action=importinquiries">Import Inquiries to User table</a> --->
    
	<script type="text/javascript">
    function gotoSite(id){
       // if(id != ''){
            window.location.href='#request.cgi_script_name#?sid='+escape(id);
       // }
    }
    </script>
            <cfsavecontent variable="db.sql">

            SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site WHERE 
            site_id =#db.param(form.sid)# and 
            site_deleted = #db.param(0)#
            ORDER BY site_domain asc
            
</cfsavecontent><cfscript>qSite=db.execute("qSite");</cfscript>
    <cfif application.zcore.user.checkServerAccess()>
    <table style="border-spacing:0px; width:100%;" class="table-list">
            <cfsavecontent variable="db.sql">

            SELECT * FROM #db.table("site", request.zos.zcoreDatasource)# site WHERE 
            site_id <> #db.param('1')# and 
            site_deleted = #db.param(0)# 
            ORDER BY site_domain asc
            
            </cfsavecontent><cfscript>qSites=db.execute("qSites");</cfscript>
            <tr>
                <td class="table-white">
                Select a site: 
                <cfscript>
                selectStruct = StructNew();
                selectStruct.name = "sid";
                // options for query data
                selectStruct.onChange="gotoSite(this.options[this.selectedIndex].value);";
                selectStruct.query = qSites;
                selectStruct.queryLabelField = "site_domain";
                selectStruct.queryValueField = "site_id";	
                application.zcore.functions.zInputSelectBox(selectStruct);
                </cfscript></td>
            </tr>
    </table><br /> 
    <cfif qSite.recordcount NEQ 0 OR form.action NEQ 'list'>
    <a href="#request.cgi_script_name#">Email Campaigns</a> / 
    <cfif qSite.recordcount NEQ 0 and form.action NEQ 'list'><a href="#request.zscriptname#">#qsite.site_short_domain# Campaigns</a> /</cfif>
    <br />
<br />
    </cfif>
    <cfelse>
    <cfif qSite.recordcount NEQ 0 OR form.action NEQ 'list'>
    <a href="#request.cgi_script_name#">Email Campaigns</a> / 
    <br />
<br />
    	</cfif>
    </cfif>

	<h2 style="display:inline; ">Email Campaigns | </h2> <a href="#request.zscriptname#&action=new&zCampaignIndex=#zCampaignIndex#">New Campaign</a>
    <hr />
<cfif form.action EQ 'list'>
    <cfif qSite.recordcount NEQ 0>
	
        <cfsavecontent variable="db.sql">

        SELECT count(zemail_campaign_id) count FROM #db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign 
        WHERE site_id =#db.param(form.sid)# and 
        zemail_campaign_deleted = #db.param(0)#
        
        </cfsavecontent><cfscript>qCampaignCount=db.execute("");</cfscript>
        <cfsavecontent variable="db.sql">

        SELECT * FROM (#db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign, 
        #db.table("zemail_template", request.zos.zcoreDatasource)# zemail_template, 
        #db.table("zemail_template_type", request.zos.zcoreDatasource)# zemail_template_type) WHERE 
        zemail_campaign.zemail_template_id=zemail_template.zemail_template_id and  
        zemail_template.zemail_template_type_id= zemail_template_type.zemail_template_type_id and 
        zemail_template_deleted = #db.param(0)# and 
        zemail_campaign_deleted = #db.param(0)#
        zemail_template_type_deleted = #db.param(0)# and 
        zemail_campaign.site_id =#db.param(form.sid)# ORDER BY zemail_campaign_created_datetime desc
        
        </cfsavecontent><cfscript>qCampaign=db.execute("qCampaign");
        if(qCampaignCount.count GT 30){
            // required
            searchStruct = StructNew();
            searchStruct.count = qCampaignCount.count;
            searchStruct.index = zCampaignIndex;
            // optional
            searchStruct.url = request.zscriptname;
            searchStruct.buttons = 5;
            searchStruct.perpage = 10;
            searchStruct.indexName= "zCampaignIndex";
            // stylesheet overriding
            searchStruct.tableStyle = "table-highlight tiny";
            searchStruct.linkStyle = "tiny";
            searchStruct.textStyle = "tiny";
            searchStruct.highlightStyle = "highlight tiny";
            
            searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
        }else{
            searchNav = "";
        }
        writeoutput(searchNav);</cfscript>
        <form name="myForm" id="myForm" action="#Request.zScriptName#" method="post">
        <input type="hidden" name="action" id="action" value="addHostFilter">
        <table style="width:100%;"  class="table-list">
        <tr class="table-highlight">
        <th>Name</th>
        <th>Template Type</th>
        <th>Status</th>
        <th>Scheduled Datetime</th>
        <th>Completed Datetime</th>
        <th>Admin</th>
        </tr>
        <cfloop query="qCampaign">
          <tr <cfif qCampaign.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif>>
                <td>#qCampaign.zemail_campaign_name#</td>
                <cfscript>
                status="unknown";
                if(qCampaign.zemail_campaign_status EQ 0){
					if(qCampaign.zemail_campaign_scheduled EQ 0){
                    	status="draft";
					}else{
						status="scheduled";
					}
                }else if(qCampaign.zemail_campaign_status EQ 1){
                    status="running";
                }else if(qCampaign.zemail_campaign_status EQ 2){
                    status="error";
                }else if(qCampaign.zemail_campaign_status EQ 3){
                    status="complete";
                }else if(qCampaign.zemail_campaign_status EQ 4){
                    status="paused";
                }
                </cfscript>
                <td>#qCampaign.zemail_template_type_name#</td>
                <td>#qCampaign.status#</td>
                <td>#dateformat(qCampaign.zemail_campaign_scheduled_datetime,'m/d/yyyy')&' '&timeformat(qCampaign.zemail_campaign_scheduled_datetime,'h:mm tt')#</td>
                <td>#dateformat(qCampaign.zemail_campaign_completed_datetime,'m/d/yyyy')&' '&timeformat(qCampaign.zemail_campaign_completed_datetime,'h:mm tt')#</td>
                <td><a href="#application.zcore.functions.zvar('domain', qCampaign.site_id)#/z/-evm1.#qCampaign.zemail_campaign_id#" target="_blank">View</a> | 
                <cfif request.zos.istestserver EQ false>
                <cfif qCampaign.zemail_campaign_status EQ 0 and qCampaign.zemail_campaign_scheduled EQ 0>
                <a href="#request.zscriptname#&action=resume&zemail_campaign_id=#qCampaign.zemail_campaign_id#">Start</a> | 
                <cfelseif qCampaign.zemail_campaign_status EQ 1>
                <a href="#request.zscriptname#&action=pause&zemail_campaign_id=#qCampaign.zemail_campaign_id#">Pause</a> | 
                <cfelseif qCampaign.zemail_campaign_status NEQ 3>
                <a href="#request.zscriptname#&action=resume&zemail_campaign_id=#qCampaign.zemail_campaign_id#">Resume</a> | 
                </cfif>
                <cfif qCampaign.currentrow EQ 1>
                <a href="#request.zscriptname#&action=processBounce&zemail_campaign_id=#qCampaign.zemail_campaign_id#">Process Bounces</a> | 
                </cfif>
                </cfif>
                <a href="#request.zscriptname#&action=edit&zemail_campaign_id=#qCampaign.zemail_campaign_id#">Edit</a> | 
                <a href="#request.zscriptname#&action=statistics&zemail_campaign_id=#qCampaign.zemail_campaign_id#">Statistics</a></td>
            </tr>
        </cfloop>
        </table>
        </form>
        <cfscript>writeoutput(searchNav);</cfscript>
    </cfif>
</cfif>

<cfif form.action EQ 'pause'>disabled.
<cfscript>application.zcore.functions.zabort();
	result=emailCom.setEmailCampaignStatus(zemail_campaign_id, 4, sid);
	if(result){
		application.zcore.status.setStatus(request.zsid,"Email Campaign is now paused.");
	}else{
		application.zcore.status.setStatus(request.zsid,"Email Campaign doesn't exist.");
	}
	application.zcore.functions.zRedirect(request.zscriptname&"&zsid=#request.zsid#");
	</cfscript>
</cfif>
<cfif form.action EQ 'resume'>disabled.
<cfscript>application.zcore.functions.zabort();
	emailCom.runEmailCampaign();
	application.zcore.status.setStatus(request.zsid,"Email Campaign is now running.");
	application.zcore.functions.zRedirect(request.zscriptname&"&zsid=#request.zsid#");
	</cfscript>
</cfif>

 

<cfif form.action EQ 'processBounce'>

	<cfscript>
    ts=StructNew();
    ts.popserver=application.zcore.functions.zvar('emailpopserver', form.sid);
    ts.username=zvar('emailcampaignfrom', form.sid);
    ts.password="2008blast";
    ts.siteIdDefault=form.sid;
    ts.emailCampaignDefault=zemail_campaign_id;
    emailCom.processBounces(ts);
    application.zcore.status.setStatus(request.zsid,"Bounces processed");
    application.zcore.functions.zRedirect(request.zscriptname&"&zsid=#request.zsid#");
    </cfscript>
</cfif>

<cfif form.action EQ 'statistics'>

    <cfsavecontent variable="statstext">
    <table style="color:##000000;">
    <tr>
    <td style="text-align:left;">
    <span style="font-weight:bold; font-size:14px;">#zvar('domain', form.sid)# email campaign:</span><br /><br />
    <cfsavecontent variable="db.sql">

    select * from #db.table("zemail_campaign", request.zos.zcoreDatasource)# zemail_campaign where 
    zemail_campaign_id = #db.param(zemail_campaign_id)# and 
    zemail_campaign_deleted = #db.param(0)#
    
    </cfsavecontent><cfscript>qcampaign=db.execute("qcampaign");</cfscript>
    <a href="#zvar('domain', form.sid)#/z/-evm1.#zemail_campaign_id#" target="_blank">Click here to view example of the sent email</a><br />
    <br />
    
    <cfsavecontent variable="db.sql">

    select count(user_id) count from #db.table("zemail_campaign_x_user", request.zos.zcoreDatasource)# zemail_campaign_x_user where 
    zemail_campaign_id = #db.param(zemail_campaign_id)# and 
    zemail_campaign_x_user_deleted = #db.param(0)#
    
    </cfsavecontent><cfscript>q=db.execute("q");</cfscript>
    <cfif q.recordcount neq 0 and q.count neq 0>
    <strong>Total emails sent: #q.count#</strong><br />
    Email campaign started on #dateformat(qcampaign.zemail_campaign_scheduled_datetime,'m/d/yyyy')# at #timeformat(qcampaign.zemail_campaign_scheduled_datetime,'h:mm tt')# and completed on #dateformat(qcampaign.zemail_campaign_completed_datetime,'m/d/yyyy')# at #timeformat(qcampaign.zemail_campaign_completed_datetime,'h:mm tt')#<br style="clear:both;" />
    <cfset totalemails=q.count>
    <cfsavecontent variable="db.sql">

    select zemail_campaign_click_type, count(distinct user_id) count from 
    #db.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click where 
    zemail_campaign_id = #db.param(zemail_campaign_id)# and 
    zemail_campaign_click_deleted = #db.param(0)# 
    group by zemail_campaign_click_type order by zemail_campaign_click_type asc
    
    </cfsavecontent><cfscript>q=db.execute("q");
    arrType=["opens","unsubscribes", "bounces", "clicks", "conversions", "out of office", "temporary bounce", "challenge response", "anti-spam bounce", "other/replies"];
    </cfscript>
    <table style="border-spacing:0px;  color:##000000; text-align:left;">
    <tr>
    <td><strong>Statistic</strong></td>
    <td><strong>Count</strong></td>
    <td><strong>Percentage</strong></td>
    </tr>
    <cfloop query="q">
        <cfif arraylen(arrType) GTE zemail_campaign_click_type and zemail_campaign_click_type NEQ 0>
            <tr>
            <td>#arrType[zemail_campaign_click_type]#</td>
            <td>#count#</td>
            <td><cfif count EQ 0>0%<cfelse>#round((count/totalemails)*100)#%</cfif></td>
            </tr>
        </cfif>
    </cfloop>
    </table><br />
    
    
    <cfsavecontent variable="db.sql">
    select zemail_campaign_click_offset, count(distinct user_id) count from 
    #db.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click where 
    zemail_campaign_id = #db.param(zemail_campaign_id)# and 
    zemail_campaign_click_type=#db.param('5')# and 
    zemail_campaign_click_deleted = #db.param(0)# 
    group by zemail_campaign_click_offset
    </cfsavecontent><cfscript>q=db.execute("q");</cfscript>
    <cfif q.recordcount NEQ 0 and q.count NEQ 0>
        <strong>Conversion Type Breakdown:</strong><br />
        <cfloop query="q">
            <cfif zemail_campaign_click_offset EQ 1> Inquiry : #count#<br />
            <cfelseif zemail_campaign_click_offset EQ 2> Reservation : #count#<br />
            </cfif>
        </cfloop>
    </cfif>
    <cfelse>
    No statistics have been collected for this campaign yet.
    
    </cfif></td>
    </tr>
    <tr><td>&nbsp;<br />
    <strong>Explanation of Email Types:</strong><br />
    <strong>Opens</strong> occur when a user opens the email and has enabled images to be shown in his mail client.  Many users don't show images, so there are usually more opens then reported.
    <strong>Bounces</strong> occurs when an email can't be delivered.<br />
    
    <strong>Temporary Bounces</strong> occur when an email can't be delivered temporarily.  The individual may be able to receive email for future campaigns.<br />
    <strong>Other/Replies</strong> occur when a user replies to the email or this was an autoresponder that the system couldn't detect as another type.
    <!--- arrType=["opens","unsubscribes", "bounces", "clicks", "conversions", "out of office", "temporary bounce", "challenge response", "anti-spam bounce", "other/replies"]; --->
    </td></tr>
    </table>
    </cfsavecontent>
    #statstext#
</cfif>



<cfif form.action EQ 'new' or form.action EQ 'edit'>
	<!--- 
    form fields to make this editable
    Email Campaign Name
    HTML
    Plain Text
    Script
    Subject
    Schedule: date field that is set to now, but can be changed to another date/time
    From: drop down of verified email addresses
    
     --->
     FORM HERE <br /><br />
     
	disabled.
    
    form action=save
<cfscript>application.zcore.functions.zabort();</cfscript> 
	<a href="#request.cgi_script_name#?action=sendcampaign">Save Email Campaign</a>
</cfif>

<cfif form.action EQ 'save'>
<!--- --->disabled.
<cfscript>application.zcore.functions.zabort();</cfscript> 
<!--- 
Site: site_id
Campaign Name: zemail_campaign_name
From: zemail_campaign_from

Script Path: zemail_template_script 
<!--- <input type="text" name="zemail_template_script" value="#zemail_template_script#"> --->
OR
HTML: zemail_template_html
Text: zemail_template_text

Subject: zemail_template_subject
Template Type: zemail_template_type_id

optional:
Scheduling: checkbox Draft 
hide datetime when draft is saved.
zemail_campaign_scheduled_datetime
zemail_campaign_scheduled

special list considerations:
selectAll or zemail_campaign_force_optin_datetime

 --->

	<cfscript>
    // /z/_com/app/email.cfc?method=runEmailCampaign

    /**/
    // save email template
    ts=structnew();
    ts.validate=true;
	// required for updating
    //ts.update=true;
    //ts.zemail_template_id=9;
	
	
    ts.zemail_template_script="/util/email/2008-05-15.cfm";
    ts.zemail_template_subject="Bear Mountain Ridge Phase II priced under recently appraised value.";
    // get global type_id
    qEmailTemplate=emailCom.getEmailTemplateTypeByName("email mailing",0);
    ts.zemail_template_type_id=qEmailTemplate.zemail_template_type_id;
    
    rCom=emailCom.saveEmailTemplate(ts);
    if(rCom.isOK() EQ false){
        rCom.setStatusErrors(request.zsid);
        zstatushandler(request.zsid);
        zabort();
    }
    zemail_template_id=rCom.getData().zemail_template_id;
    
    
    
    // save email_campaign
    ts=StructNew();
    // required for updating
    //ts.update=true;
    //ts.zemail_campaign_id="4";
    // required for inserting
    ts.zemail_campaign_name="May 2008 Email"; // doesn't have to be unique
    ts.zemail_template_id=zemail_template_id; // will be copied to a new record
	ts.zemail_campaign_force_optin_datetime=dateformat(createdate(2008,2,12),'yyyy-mm-dd')&' 00:00:00';
    // optional
    //ts.zemail_campaign_scheduled=1; // set to 1 to run ASAP or set zemail_campaign_scheduled_datetime to a future date below
    //ts.zemail_campaign_scheduled_datetime=dateformat(dateadd("d",0,now()),'yyyy-mm-dd')&' '&timeformat(now(),'HH:mm:ss'); // will be scheduled to run in next available slot after the scheduled time.
    rCom=emailCom.saveEmailCampaign(ts);
    if(rCom.isOK() EQ false){
        rCom.setStatusErrors(request.zsid);
        zstatushandler(request.zsid);
        zabort();
    }
    zemail_campaign_id=rCom.getData().zemail_campaign_id;
   
	
    // get the list ids
    t2=structnew();
    t2.arrEmailListNames=["everyone"];
    t2.site_id=0;
    t2.selectAll=false;
    rCom=emailCom.getEmailList(t2);
    if(rCom.isOK() EQ false){
        rCom.setStatusErrors(request.zsid);
        zstatushandler(request.zsid);
        zabort();
    }
    rs=rCom.getData();
    
    // set the lists
    ts=StructNew();
    ts.arrEmailListIds=arraynew(1);
    for(i=1;i lte rs.query.recordcount;i++){
        arrayappend(ts.arrEmailListIds,rs.query.zemail_list_id[i]);
    }
    ts.zemail_campaign_id=zemail_campaign_id;
    rs=emailCom.setEmailList(ts);
    if(rCom.isOK() EQ false){
        rCom.setStatusErrors(request.zsid);
        zstatushandler(request.zsid);
        zabort();
    }
	application.zcore.status.setStatus(request.zsid,'Email campaign has been scheduled successfully');
	application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#request.zsid#");
    </cfscript>
</cfif>
</cfoutput>



<!--- <cfsavecontent variable="db.sql">
select count(distinct user_id) count from #db.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click 
where zemail_campaign_id = #db.param('5')# and 
zemail_campaign_click_type=#db.param('3')# and 
zemail_campaign_click_deleted = #db.param(0)#
</cfsavecontent><cfscript>q=db.execute("q");</cfscript>
## of bounces:  #q.count#<br />
<cfsavecontent variable="db.sql">
select count(distinct user_id) count from #db.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click 
where zemail_campaign_id = #db.param('5')# and 
zemail_campaign_click_type=#db.param('2')# and 
zemail_campaign_click_deleted = #db.param(0)#
</cfsavecontent><cfscript>q=db.execute("q");</cfscript>
## of unsubscribes:  #q.count#<br />
<cfsavecontent variable="db.sql">
select count(distinct user_id) count from #db.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click 
where zemail_campaign_id = #db.param('5')# and 
zemail_campaign_click_type=#db.param('1')# and 
zemail_campaign_click_deleted = #db.param(0)#
</cfsavecontent><cfscript>q=db.execute("q");</cfscript>
## of opens:  #q.count#<br />
<cfsavecontent variable="db.sql">
select count(distinct user_id) count from #db.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click 
where zemail_campaign_id = #db.param('5')# and 
zemail_campaign_click_type=#db.param('4')# and 
zemail_campaign_click_deleted = #db.param(0)#
</cfsavecontent><cfscript>q=db.execute("q");</cfscript>
## of clicks:  #q.count#<br />

<cfsavecontent variable="db.sql">
select count(distinct user_id) count from #db.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click 
where zemail_campaign_id = #db.param('5')# and 
zemail_campaign_click_type=#db.param('10')# and 
zemail_campaign_click_deleted = #db.param(0)#
</cfsavecontent><cfscript>q=db.execute("q");</cfscript>
## of total conversions:  #q.count#<br />

<cfsavecontent variable="db.sql">
select count(distinct user_id) count from #db.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click 
where zemail_campaign_id = #db.param('5')# and 
zemail_campaign_click_type=#db.param('5')# and 
zemail_campaign_click_deleted = #db.param(0)#
</cfsavecontent><cfscript>q=db.execute("q");</cfscript>
## of total conversions:  #q.count#<br />
<cfif q.count neq 0>
<cfsavecontent variable="db.sql">
select zemail_campaign_click_offset, count(distinct user_id) count from 
#db.table("zemail_campaign_click", request.zos.zcoreDatasource)# zemail_campaign_click where 
zemail_campaign_id = #db.param('5')# and 
zemail_campaign_click_deleted = #db.param(0)# and 
zemail_campaign_click_type=#db.param('5')# group by zemail_campaign_click_offset;
</cfsavecontent><cfscript>q=db.execute("q");</cfscript>
<cfif q.recordcount NEQ 0 and q.count NEQ 0>
    Conversion Type Breakdown:<br />
    <cfloop query="q">
        <cfif zemail_campaign_click_offset EQ 1> Inquiry : #count#<br />
        <cfelseif zemail_campaign_click_offset EQ 2> Reservation : #count#<br />
        </cfif>
    </cfloop>
</cfif>

</cfif>

<br />
the rest is disabled<cfscript>application.zcore.functions.zabort();</cfscript>
 --->
<!--- let's build a cfmail replacement tag today
<cf_zmail>
	<cf_zmailparam>
	<cf_zmailpart>
</cf_zmail>
<cfmail>
<cfmailparam
<cfmailpart

write an email scheduler that prevents sending to the same domain more then x times a minute

zemail_smtp_domain
	zemail_smtp_domain_id
	zemail_smtp_domain_name
	zemail_smtp_domain_datetime
	zemail_smtp_domain_daily_count
	zemail_smtp_domain_weekly_count
	zemail_smtp_domain_monthly_count

 --->
 
<!--- 
when sending email, i'll need to cache all the user_ids immediately and then rerun through them
SELECT user_username, user_id
 ---> 
<!--- 
<cfsavecontent variable="domainlist">
bellsouth
yahoo
yahoo
yahoo
yahoo
yahoo
yahoo
yahoo
yahoo
msn
msn
msn
msn
aol
aol
aol
aol
aol
aol
aol
hotmail
</cfsavecontent>
<cfscript>
// sort emails for least amount of repetition to same domain
arrDomain=listtoarray(trim(domainList),chr(10));
arrDomain2=listtoarray(trim(domainList),chr(10));
arrOrder=arraynew(1);
cur="";
while(true){
	found=false;
	us=structnew();
	for(i=1;i LTE arraylen(arrDomain);i++){
		if(structkeyexists(us,arrDomain[i]) EQ false){
			cur=arrDomain[i];
			us[cur]=true;
			arrayAppend(arrOrder,cur);
			arrayDeleteAt(arrDomain,i);
			found=true;
			//i--;
		}
	}
	if(arraylen(arrDomain) eq 0){
		break;
	}
	//g+=structcount(us)+1;
}
writeoutput('length of order and domain: '&arraylen(arrorder)&' '&arraylen(arrdomain2)&' '&arraylen(arrdomain)&'<br />');
//zdump(arrdomain);
//zdump(arrOrder);
zabort();
</cfscript>
 

 right(inquiries_email,length(inquiries_email)-locate("@",inquiries_email)) emailDomain
<cfscript>
nowDate=request.zos.mysqlnow;
// wait 30 seconds before sending to this domain again.
oldDate=DateFormat(dateAdd("s",-30,now()),"yyyy-mm-dd")&" "&TimeFormat(dateAdd("s",-30,now()),"HH:mm:ss");
</cfscript>
<cfsavecontent variable="db.sql">
SELECT zemail_smtp_domain_id FROM #db.table("zemail_smtp_domain", request.zos.zcoreDatasource)#  WHERE 
site_id = #db.param(request.zos.globals.id)# and zemail_smtp_domain_name=#db.param(domain)# and 
zemail_smtp_domain_deleted = #db.param(0)# and 
zemail_smtp_domain_datetime < #db.param(nowDate)#
</cfsavecontent><cfscript>qC=db.execute("qU");</cfscript>
<cfif qC.recordcount NEQ 0>
	
	<!--- update domain stats --->
    <cfsavecontent variable="db.sql">
    UPDATE #db.table("zemail_smtp_domain", request.zos.zcoreDatasource)#  SET
    zemail_smtp_domain_datetime=#db.param(nowDate)#,
    zemail_smtp_domain_daily_count=zemail_smtp_domain_daily_count+#db.param(1)#, 
    zemail_smtp_domain_weekly_count=zemail_smtp_domain_weekly_count+#db.param(1)#, 
    zemail_smtp_domain_monthly_count=zemail_smtp_domain_monthly_count+#db.param(1)#, 
    zemail_smtp_domain_updated_datetime=#db.param(request.zos.mysqlnow)#
    WHERE  zemail_smtp_domain_id =#db.param(zemail_smtp_domain_id)# and 
    zemail_smtp_domain_deleted = #db.param(0)# and 
    site_id = #db.param(request.zos.globals.id)#
    </cfsavecontent><cfscript>qU=db.execute("qU");</cfscript>
<cfelse>
    <cfsavecontent variable="db.sql">
    INSERT INTO #db.table("zemail_smtp_domain", request.zos.zcoreDatasource)#  SET 
    zemail_smtp_domain_name=#db.param(domain)#,
    zemail_smtp_domain_datetime=#db.param(nowDate)#,
    zemail_smtp_domain_daily_count=#db.param(1)#, 
    zemail_smtp_domain_weekly_count=#db.param(1)#, 
    zemail_smtp_domain_monthly_count=#db.param(1)#, 
    zemail_smtp_domain_updated_datetime=#db.param(request.zos.mysqlnow)#,
    site_id = #db.param(request.zos.globals.id)#
    </cfsavecontent><cfscript>qU=db.execute("dU");</cfscript>
</cfif>
cfqzemail_smtp_domain_id --->
<!---
<cfscript>
 // test invalid domains
// test sending to gmail/yahoo/hotmail/aol

select right(inquiries_email,length(inquiries_email)-locate("@",inquiries_email)) emailDomain, count(inquiries_id) count from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries group by right(inquiries_email,length(inquiries_email)-locate("@",inquiries_email)) order by count desc;limit 0,1

// add custom headers with <cfmailparam name="Reply-To" value="widget_master@YourCompany.com">

// Delivery Status Notification rfc: http://tools.ietf.org/html/rfc3463

// stats http://www.emaillabs.com/tools/email-marketing-statistics.html

// bounce detection system 
// disable forwarding on the news@ emails

// X-MessageId header causes message to be marked as spam delivery
// X-mailer header 

// make a script that lets you manage bounces like constant contact (export & remove)

// removing X-mailer is what competitors do
// X-Mailer: Microsoft Outlook, Build 10.0.6838 - might get through spam filters better
// http://www.intrafoundation.com/software/TCPClient.htm

// might need to use com objects for smtp to do what i want and faster.
// http://www.aspemail.com/
// http://www.serverobjects.com/products.html


</cfscript> ---> --->
</cfcomponent>