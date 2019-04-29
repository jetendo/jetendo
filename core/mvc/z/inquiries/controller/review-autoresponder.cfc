<cfcomponent>
<cfoutput>
<!--- 
need image to work in html editor fields (absolute url them before sending and test it)

multiple locations
	have to get county from the lead

inquiries
	inquiries_rating_email_sent_count int 0
	inquiries_rating_email_set char(1) 0
	inquiries_rating
	inquiries_rating_hash

sendEmail
rate
 --->

<!--- 
on live server only, this should run once a day or a minute
/z/inquiries/review-autoresponder/cron
 --->
<cffunction name="cron" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	setting requesttimeout="80000";
	request.ignoreSlowScript=true;
	db=request.zos.queryobject; 
	form.sid=application.zcore.functions.zso(form, 'sid', true, 0);

	db.sql="select site.site_id, site_domain, if(inquiries_rating_setting_id IS NULL, #db.param(0)#, #db.param(1)#) hasAutoresponder from #db.table("site", request.zos.zcoreDatasource)#, #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_rating_setting.site_id = site.site_id and 
	inquiries_rating_setting_deleted=#db.param(0)# and 
	site.site_id <> #db.param(-1)# and 
	site_deleted = #db.param(0)# and 
	site_active = #db.param(1)#";
	if(form.sid NEQ 0){
		db.sql&=" and site.site_id = #db.param(form.sid)# ";
	}
	db.sql&=" GROUP BY site.site_id ";
	qSite=db.execute("qSite");
	for(row in qSite){
		u=row.site_domain&"/z/inquiries/review-autoresponder/cronSend";
		rs=application.zcore.functions.zdownloadlink(u, 5000);
		if(not rs.success){ 
			throw("Failed to download: #u#");
		}else{
			echo("Downloaded: #u#<br />");
			echo(rs.cfhttp.filecontent&"<hr />");
		}
	}
	echo('Send Lead Review Autoresponders complete');
	abort;
	</cfscript>
</cffunction>

<!--- 
// this is called on each site that has autoresponders and that has them ready to send
/z/inquiries/review-autoresponder/cronSend
 --->
<cffunction name="cronSend" localmode="modern" access="remote">
	<cfscript>
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	setting requesttimeout="80000";
	request.ignoreSlowScript=true;
	db=request.zos.queryobject; 
	form.sid=application.zcore.functions.zso(form, 'sid', true, 0);

	db.sql="select * FROM #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_rating_setting_deleted=#db.param(0)# and 
	inquiries_rating_setting_active=#db.param(1)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qSetting=db.execute("qSetting");

	sentCount=0;
	errorCount=0;
	// find inquiries that need a rating email sent
	for(setting in qSetting){
		arrType=listToArray(setting.inquiries_rating_setting_type_id_list, ",");
		for(type in arrType){
			inquiries_type_id=listGetAt(type, 1, "|");
			inquiries_type_id_siteIDType=listGetAt(type, 2, "|");
			db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
			WHERE inquiries_type_id=#db.param(inquiries_type_id)# and 
			inquiries_type_id_siteIDType=#db.param(inquiries_type_id_siteIDType)# and 
			site_id=#db.param(request.zos.globals.id)# and 
			inquiries_email <> #db.param("")# and 
			inquiries_rating = #db.param(0)# and 
			inquiries_rating_email_sent_count<>#db.param(10000)# and 
			inquiries_deleted=#db.param(0)# ";
			if(setting.inquiries_rating_setting_email_resend_limit > 0){
				db.sql&=" and inquiries_rating_email_sent_count < #db.param(setting.inquiries_rating_setting_email_resend_limit)# ";
			}
			if(setting.inquiries_rating_setting_start_date NEQ ""){
				db.sql&=" and inquiries_datetime >= #db.param(dateformat(setting.inquiries_rating_setting_start_date, "yyyy-mm-dd")&" 00:00:00")# ";
			}
			if(request.zos.isTestServer){
				db.sql&=" LIMIT #db.param(0)#, #db.param(5)# ";
			}
			qInquiry=db.execute("qInquiry");
			if(request.zos.isTestServer){
				echo("Limited to sending 5 emails on the test server<br>");
			}
			// inquiries_rating_email_set because you can get the email from phone json sometimes?
			for(inquiry in qInquiry){
				// check if user was unsubscribed already
				db.sql="SELECT * FROM #db.table("contact", request.zos.zcoreDatasource)# WHERE 
				contact_email =#db.param(qInquiry.inquiries_email)# and 
				site_id = #db.param(request.zos.globals.id)# and 
				contact_opt_out=#db.param(1)# and 
				contact_deleted=#db.param(0)# ";
				qContact=db.execute("qContact");
				if(qContact.recordcount NEQ 0){
					db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# 
					SET 
					inquiries_rating_email_sent_count=#db.param(10000)#
					WHERE inquiries_id=#db.param(inquiry.inquiries_id)# and 
					site_id=#db.param(request.zos.globals.id)# and 
					inquiries_deleted=#db.param(0)#  ";
					continue; // this user has unsubscribed, stop trying to send the email
				}
				tempHash=inquiry.inquiries_rating_hash;
				if(tempHash EQ ""){
					tempHash=hash(application.zcore.functions.zGenerateStrongPassword(80,200), 'sha-256');
				}
				db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# 
				SET 
				inquiries_rating_email_sent_datetime=#db.param(dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"))#,
				inquiries_rating_email_sent_count=#db.param(inquiry.inquiries_rating_email_sent_count+1)#, 
				inquiries_rating_hash=#db.param(tempHash)#
				WHERE inquiries_id=#db.param(inquiry.inquiries_id)# and 
				site_id=#db.param(request.zos.globals.id)# and 
				inquiries_deleted=#db.param(0)#  ";
				db.execute("qUpdate");
				fromEmail=request.fromEmail;
				if(setting.inquiries_rating_setting_from_email NEQ ""){
					fromEmail=setting.inquiries_rating_setting_from_email;
				}
				toEmail=inquiry.inquiries_email;
				if(request.zos.isTestServer){
					email=request.zos.developerEmailTo;
				}
				echo("sendEmail: "&inquiries_type_id&", "& inquiries_type_id_siteIDType&", "& false&", "&fromEmail&", "& email&", "& inquiry.inquiries_id&", "& false&", "& false&"<br>");
				result=0;
				//result=sendEmail(inquiries_type_id, inquiries_type_id_siteIDType, false, fromEmail, email, inquiry.inquiries_id, false, false);
				if(result NEQ 0){
					errorCount++;
					echo("Error for inquiries_id: #inquiry.inquiries_id# | #result#<br>");
				}else{
					sentCount++;
				}
			}
		}
	}
	echo("#sentCount# emails sent | #errorCount# errors");
	abort;
	</cfscript>
</cffunction>

<cffunction name="sendTest" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	form.inquiries_type_id=application.zcore.functions.zso(form, "inquiries_type_id");
	form.inquiries_type_id_siteIDType=application.zcore.functions.zso(form, "inquiries_type_id_siteIDType"); 
	result=sendEmail(form.inquiries_type_id, form.inquiries_type_id_siteIDType, false, request.fromEmail, form.email, 0, true, true);
	if(result NEQ 0){
		application.zcore.status.setStatus(request.zsid, "Test email was not sent | Result: #result#");
	}else{
		application.zcore.status.setStatus(request.zsid, "Test email was sent");
	}
	application.zcore.functions.zRedirect("/z/inquiries/review-autoresponder/testAutoresponder?inquiries_type_id=#form.inquiries_type_id#&inquiries_type_id_siteidtype=#form.inquiries_type_id_siteIDType#&zsid=#request.zsid#&email=#urlencodedformat(form.email)#");
	</cfscript>
</cffunction>

<cffunction name="testAutoresponder" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	application.zcore.functions.zStatusHandler(request.zsid);
	form.inquiries_type_id=application.zcore.functions.zso(form, "inquiries_type_id");
	form.inquiries_type_id_siteIDType=application.zcore.functions.zso(form, "inquiries_type_id_siteIDType");
	echo('<p><a href="/z/inquiries/admin/review-autoresponder-settings/index">Lead Review Autoresponders</a> /</p>');
	echo("<h2>Test Lead Review Autoresponder</h2> ");
	result=sendEmail(form.inquiries_type_id, form.inquiries_type_id_siteIDType, true, "", "", 0, false, true); 

	</cfscript>
	<p>&nbsp;</p>
	<h2>Send Test Email</h2>
	<form action="/z/inquiries/review-autoresponder/sendTest" method="get">
		<input type="hidden" name="inquiries_type_id" value="#htmleditformat(form.inquiries_type_id)#">
		<input type="hidden" name="inquiries_type_id_siteIDType" value="#htmleditformat(form.inquiries_type_id_siteIDType)#">
		<p>Your Email: <input type="text" name="email" id="email" style="width:500px; max-width:100%;" value="#htmleditformat(application.zcore.functions.zso(form, "email", false, request.zsession.user.email))#"></p>
		<p><input type="submit" name="Submit1" value="Send" class="z-manager-search-button"></p>
	</form>
</cffunction>

<!--- 
add autoresponder cron job a check for rating setting, and then send the ones that are not sent.

reviewCom=createObject("component", "zcorerootmapping.mvc.z.inquiries.controller.review-autoresponder");
reviewCom.sendEmail(inquiries_type_id, inquiries_type_id_siteIDType, true, request.fromEmail, toEmail, false);
 --->
<cffunction name="sendEmail" localmode="modern" access="public">
	<cfargument name="inquiries_type_id" type="string" required="yes">
	<cfargument name="inquiries_type_id_siteIDType" type="string" required="yes">
	<cfargument name="enableTestMode" type="boolean" required="yes">
	<cfargument name="fromEmail" type="string" required="yes">
	<cfargument name="toEmail" type="string" required="yes">
	<cfargument name="inquiries_id" type="string" required="yes">
	<cfargument name="forceSendEmail" type="string" required="yes">
	<cfargument name="enableReviewTestMode" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;

	if(arguments.inquiries_id NEQ "" and arguments.inquiries_id NEQ 0){
		db.sql="select inquiries_rating_hash from #db.table("inquiries", request.zos.zcoreDatasource)# WHERE 
		inquiries_id = #db.param(arguments.inquiries_id)# and 
		inquiries_deleted=#db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		qInquiry=db.execute("qInquiry");
		if(qInquiry.recordcount EQ 0){
			return 1; // can't send email without a valid inquiries_id
		}
		key=qInquiry.inquiries_rating_hash;
		if(key EQ ""){
			key=hash(application.zcore.functions.zGenerateStrongPassword(80,200), 'sha-256');
			db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# 
			set inquiries_rating_hash=#db.param(key)# 
			WHERE 
			inquiries_id = #db.param(arguments.inquiries_id)# and 
			inquiries_deleted=#db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# ";
			db.execute("qUpdate");
		}
	}else if(not arguments.enableTestMode and not arguments.forceSendEmail){
		return 2; // can't send email without a valid inquiries_id
	}else{
		key=hash(application.zcore.functions.zGenerateStrongPassword(80,200), 'sha-256');
	}
	db.sql="select * from #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# 
	WHERE concat(#db.param(",")#, inquiries_rating_setting_type_id_list, #db.param(",")#) LIKE #db.param("%,"&arguments.inquiries_type_id&"|"&arguments.inquiries_type_id_siteIDType&",%")# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_rating_setting_deleted=#db.param(0)# ";
	qRating=db.execute("qRating"); 
	if(qRating.recordcount EQ 0){
		return 3; // there is no rating email setup for this inquiries_type_id
	}
	ts={};
	ts.subject=qRating.inquiries_rating_setting_email_subject;
	savecontent variable="ts.html"{
		if(not arguments.enableTestMode){
			echo('<!DOCTYPE html><html><head><title></title></head><body>');
		}
		echo(qRating.inquiries_rating_setting_header_text);
		echo(qRating.inquiries_rating_setting_body_text);
		
		echo('<p style="text-align:center;">');
		for(i=1;i<=5;i++){
			link=request.zos.globals.domain&"/z/inquiries/review-autoresponder/rate?rating=#i#&id=#arguments.inquiries_id#&key=#key#";
			if(arguments.enableReviewTestMode){
				link&="&testMode=1&inquiries_rating_setting_id=#qRating.inquiries_rating_setting_id#";
			}
			echo('<a href="#link#" style="font-size:48px;text-decoration:none;">&##9733;</a> ');
		}
		echo('</p>');
		echo(qRating.inquiries_rating_setting_footer_text);

		echo('<p><a href="/z/user/out/index?e=#urlencodedformat(arguments.toEmail)#">Unsubscribe</a></p>');
		if(not arguments.enableTestMode){
			echo('</body></html>');
		}
	}
	if(arguments.enableTestMode){
		echo('<h3>Subject: #qRating.inquiries_rating_setting_email_subject#</h3> 

		<h3>Email Body</h3>
		<div style="width:100%; float:left; background-color:##333; padding:10px; text-align:center;">
			<div style="width:640px;  margin:0 auto; text-align:left; background-color:##FFF; padding:10px;">#ts.HTML#</div>
		</div>');
		if(request.zos.isTestServer){
			ts.from=request.zos.developerEmailFrom;
			ts.to=request.zos.developerEmailTo;
		}
		return 4;
	}
	// continue to send email
	ts.to=arguments.toEmail;
	ts.from=arguments.fromEmail;
	if(request.zos.isTestServer){
		ts.from=request.zos.developerEmailFrom;
		ts.to=request.zos.developerEmailTo;
	}else{
		if(not arguments.forceSendEmail){
			return 5;
		}
	}
	rCom=application.zcore.email.send(ts);
	if(rCom.isOK() EQ false){
		// ignore
	}
	return 0;
	</cfscript>
</cffunction>

<cffunction name="rate" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	form.id=application.zcore.functions.zso(form, "id", true); // inquiries_id
	form.key=application.zcore.functions.zso(form, "key");
	form.testMode=application.zcore.functions.zso(form, "testMode", true, 0);
	form.rating=ceiling(application.zcore.functions.zso(form, "rating", true));
	if(not request.zos.isTestServer){
		echo("<h2>Storage of ratings is disabled until system is made live</h2>");
	}
	if(form.rating LT 1 or form.rating GT 5){
		application.zcore.functions.z404("Invalid rating: #form.rating#");
	}

	if(form.testMode EQ 1){
		echo("<h2>Test Mode Enabled: This rating was not stored</h2>");
		db.sql="select * from #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# 
		WHERE inquiries_rating_setting_id=#db.param(form.inquiries_rating_setting_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_rating_setting_deleted=#db.param(0)# ";
		qSetting=db.execute("qSetting");
		if(qSetting.recordcount EQ 0){
			application.zcore.functions.z404("inquiries_rating_setting_id: #form.inquiries_rating_setting_id# doesn't exist.");
		}

	}else{
		db=request.zos.queryObject;
		db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
		WHERE inquiries_id=#db.param(form.id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)# ";
		qInquiry=db.execute("qInquiry", "", 10000, "query", false);

		if(qInquiry.recordcount EQ 0){
			application.zcore.functions.z404("Invalid inquiries_id: #form.id#");
		}
		if(qInquiry.inquiries_rating_hash EQ "" or form.key NEQ qInquiry.inquiries_rating_hash){
			application.zcore.functions.z404("Invalid key for inquiries_id: #form.id#");
		}
		// lookup the inquiries_rating_setting using the inquiries_type_id of the inquiries_id
		db.sql="select * from #db.table("inquiries_rating", request.zos.zcoreDatasource)# 
		WHERE concat(#db.param(",")#, inquiries_rating_setting_type_id_list, #db.param(",")#) LIKE #db.param("%,"&qInquiry.inquiries_type_id&"|"&qInquiry.inquiries_type_id_siteIDType&",%")# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_rating_setting_deleted=#db.param(0)# ";
		qSetting=db.execute("qSetting", "", 10000, "query", false);
		if(qSetting.recordcount EQ 0){
			application.zcore.functions.z404("There is no inquiries_rating_setting record for the inquiries_type_id (#qInquiry.inquiries_type_id&"|"&qInquiry.inquiries_type_id_siteIDType#) of inquiries_id: #form.id#");
		}
	}



	db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# 
	SET 
	inquiries_rating=#db.param(form.rating)#, 
	inquiries_updated_datetime=#db.param(request.zos.mysqlnow)# 
	where inquiries_id = #db.param(form.id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_deleted=#db.param(0)# ";

	savecontent variable="formHTML"{
		echo('<form action="/z/inquiries/review-autoresponder/saveComments" method="post">
			<input type="hidden" name="inquiries_id" value="#form.id#">
			<input type="hidden" name="inquiries_rating_hash" value="#form.key#">
			<p><textarea cols="100" rows="5" style="width:100%;" name="comments"></textarea></p>
			<p><input type="submit" name="submit" value="Send Comments"></p>
		</form>');
	}
	for(row in qSetting){
		if(row.inquiries_rating_setting_thanks_cfc_object NEQ "" and row.inquiries_rating_setting_thanks_cfc_method NEQ	""){
			// custom callback for thank you page.
			objectPath=replace(row.inquiries_rating_setting_thanks_cfc_object, "root.", request.zRootCFCPath&".");
			objectCom=createobject("component", objectPath);
			objectCom[row.inquiries_rating_setting_thanks_cfc_method]();
			if(qSetting.inquiries_rating_setting_low_rating_number GTE form.rating){
				if(qSetting.inquiries_rating_setting_low_rating_comments_form EQ 1){
					echo(formHTML);
				}
			}else{
				if(qSetting.inquiries_rating_setting_high_rating_comments_form EQ 1){
					echo(formHTML);
				}
			}
		}else{
			// display the 2 fields instead
			if(qSetting.inquiries_rating_setting_low_rating_number GTE form.rating){
				application.zcore.template.setTag("title", row.inquiries_rating_setting_low_rating_thanks_heading);
				application.zcore.template.setTag("pagetitle", row.inquiries_rating_setting_low_rating_thanks_heading);
				echo(row.inquiries_rating_setting_low_rating_thanks_body);

				if(qSetting.inquiries_rating_setting_low_rating_comments_form EQ 1){
					echo(formHTML);
				}
			}else{
				application.zcore.template.setTag("title", row.inquiries_rating_setting_high_rating_thanks_heading);
				application.zcore.template.setTag("pagetitle", row.inquiries_rating_setting_high_rating_thanks_heading);
				echo(row.inquiries_rating_setting_high_rating_thanks_body);
				if(qSetting.inquiries_rating_setting_high_rating_comments_form EQ 1){
					echo(formHTML);
				}
			}
		}
	}
	</cfscript>
</cffunction>


<!--- 
/z/inquiries/review-autoresponder/saveComments?id=0&key=1&comments=Testing
 --->
<cffunction name="saveComments" localmode="modern" access="remote">
	<cfscript>
	db=request.zos.queryObject;
	form.id=application.zcore.functions.zso(form, "id", true); // inquiries_id
	form.key=application.zcore.functions.zso(form, "key");
	if(form.id EQ 0){
		echo("Comments are not saved when in test mode.");
		return;
	}
	// avoid html attacks
	form.comments=application.zcore.functions.zRemoveHTMLForSearchIndexer(form.comments);
	if(form.comments NEQ ""){
		db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
		WHERE inquiries_id=#db.param(form.id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)# ";
		qInquiry=db.execute("qInquiry");

		if(qInquiry.recordcount EQ 0){
			application.zcore.functions.z404("Invalid inquiries_id: #form.id#");
		}else{
			// append new comments to old comments
			if(qInquiry.inquiries_rating_comments NEQ ""){
				form.comments=qInquiry.inquiries_rating_comments&chr(10)&chr(10)&form.comments;
			}
		}
		if(qInquiry.inquiries_rating_hash EQ "" or form.key NEQ qInquiry.inquiries_rating_hash){
			application.zcore.functions.z404("Invalid key for inquiries_id: #form.id#");
		}

		ts={};
		ts.subject="Feedback for lead ###form.id#";
		savecontent variable="ts.html"{
			echo('<!DOCTYPE html><html><head><title></title></head><body>');
			echo('<h2>Feedback for lead ###form.id#</h2>');
			if(qInquiry.recordcount NEQ 0){
				echo("<p>Rating: "&qInquiry.inquiries_rating&"</p>");
			}
			echo(application.zcore.functions.zParagraphFormat(form.comments));
			echo('</body></html>');
		}
		// continue to send email
		ts.from=request.fromEmail;
		ts.to=application.zcore.functions.zvarso("zofficeemail");
		if(qInquiry.recordcount NEQ 0){
			db.sql="select * from #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# WHERE 
			concat(#db.param(",")#, inquiries_rating_setting_type_id_list, #db.param(",")#) LIKE #db.param("%,"&qInquiry.inquiries_type_id&"|"&qInquiry.inquiries_type_id_siteIDType&",%")# and 
			";
			qSetting=db.execute("qSetting");
			if(qSetting.recordcount EQ 0){
				if(qSetting.inquiries_rating_setting_from_email NEQ ""){
					ts.from=qSetting.inquiries_rating_setting_from_email;
				}
				if(qSetting.inquiries_rating_setting_comments_email NEQ ""){
					ts.to=qSetting.inquiries_rating_setting_comments_email;
				}
			}
		}
		if(request.zos.isTestServer){
			ts.from=request.zos.developerEmailFrom;
			ts.to=request.zos.developerEmailTo;
		}
		rCom=application.zcore.email.send(ts);
		if(rCom.isOK() EQ false){
			// ignore
		}
		db.sql="update #db.table("inquiries", request.zos.zcoreDatasource)# 
		SET 
		inquiries_rating_comments=#db.param(form.comments)# 
		WHERE inquiries_id=#db.param(form.id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)# ";
		db.execute("qUpdate");
	}
	application.zcore.functions.zRedirect("/z/inquiries/review-autoresponder/commentsThanks");
	</cfscript>
</cffunction>

<cffunction name="commentsThanks" localmode="modern" access="remote">
	<cfscript>
	application.zcore.template.setTag("title", "Thank you for your feedback.");
	application.zcore.template.setTag("pagetitle", "Thank you for your feedback.");
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>