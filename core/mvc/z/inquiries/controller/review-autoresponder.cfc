<cfcomponent>
<!--- 

inquiries_rating_setting_id
	inquiries_type_id
	inquiries_type_id_siteidtype
	inquiries_rating_setting_id
	site_id
	inquiries_rating_setting_email_subject
	inquiries_rating_setting_header_text
	inquiries_rating_setting_body_text
	inquiries_rating_setting_footer_text
	inquiries_rating_setting_email_delay_in_minutes
	inquiries_rating_setting_email_resend_limit
	inquiries_rating_setting_type (0= every inquiries_id (default), 1=every day, 2=once)
	inquiries_rating_setting_thanks_heading # used if thanks_cfc_object is not
	inquiries_rating_setting_thanks_body
	inquiries_rating_setting_thanks_cfc_object # used to write the custom logic needed for showing google/etc reviews.
	inquiries_rating_setting_thanks_cfc_method
	inquiries_rating_setting_deleted


inquiries
	inquiries_rating_email_sent_count int 0
	inquiries_rating_email_set char(1) 0

inquiries_rating_setting_thanks_cfc_method
	the callback needs to receive the inquiries_rating data as a struct, so we can show different info based on which rating was given.

inquiries_rating
	inquiries_rating_id
	site_id
	inquiries_id
	inquiries_rating_rating
	inquiries_rating_updated_datetime
	inquiries_rating_deleted
	inquiries_rating_hash varchar 64 sha-256 - use to secure the email review links.

sendEmail
rate


 --->

<!--- <cffunction name="index" localmode="modern" access="remote">
	<cfscript>

	</cfscript>
</cffunction> --->


<!--- 
add autoresponder cron job a check for rating setting, and then send the ones that are not sent.

reviewCom=createObject("component", "zcorerootmapping.mvc.z.inquiries.controller.review-autoresponder");
reviewCom.sendEmail(inquiries_type_id, inquiries_type_id_siteIDType);
 --->
<cffunction name="sendEmail" localmode="modern" access="public">
	<cfargument type="inquiries_type_id" type="string" required="yes">
	<cfargument type="inquiries_type_id_siteIDType" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="select * from #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# 
	WHERE inquiries_type_id=#db.param(form.inquiries_type_id)# and 
	inquiries_type_id_siteidtype=#db.param(form.inquiries_type_id_siteidtype)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_deleted=#db.param(0)# ";
	qRating=db.execute("qRating");
	if(qRating.recordcount EQ 0){
		return; // there is no rating email setup for this inquiries_type_id
	}
	ts={};
	ts.subject=qRating.inquiries_rating_setting_email_subject;
	savecontent variable="ts.html"{
		echo('<!DOCTYPE html><html><head><title></title></head><body>');
		echo(qRating.inquiries_rating_setting_header_text);
		echo(qRating.inquiries_rating_setting_body_text);
		
		echo('<p>');
		for(i=1;i<=5;i++){
			link=request.zos.globals.domain&"/z/inquiries/review-autoresponder/rate?rating=#i#&email=#urlencodedformat(qRating.inquiries_rating_email)#&key=#qRating.inquiries_rating_hash#";
			echo('<a href="#link#" style="font-size:24px;">#i#</a>');
		}
		echo('</p>');
		echo(qRating.inquiries_rating_setting_footer_text);
		echo('</body></html>');
	}
	</cfscript>
</cffunction>

<cffunction name="rate" localmode="modern" access="remote">
	<cfscript>
	form.id=application.zcore.functions.zso(form, "id", true);
	form.email=application.zcore.functions.zso(form, "email");
	form.rating=ceiling(application.zcore.functions.zso(form, "rating", true));
	if(form.rating LT 1 or form.rating GT 5){
		application.zcore.functions.z404("Invalid rating: #form.rating#");
	}

	db=request.zos.queryObject;
	db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE inquiries_id=#db.param(form.id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_deleted=#db.param(0)# ";
	qInquiry=db.execute("qInquiry");

	if(qInquiry.recordcount EQ 0){
		application.zcore.functions.z404("Invalid inquiries_id: #form.id#");
	}

	db.sql="select * from #db.table("inquiries_rating", request.zos.zcoreDatasource)# 
	WHERE inquiries_id=#db.param(form.id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_deleted=#db.param(0)# ";
	qRating=db.execute("qRating");
	ts={
		table:"inquiries_rating",
		datasource:request.zos.zcoreDatasource,
		struct:{
			site_id:request.zos.globals.id,
			inquiries_id:form.id,
			inquiries_rating_email:form.inquiries_rating_email,
			inquiries_rating_rating:form.rating,
			inquiries_rating_updated_datetime:request.zos.mysqlnow,
			inquiries_rating_deleted:0,
			inquiries_rating_hash:hash(application.zcore.functions.zGenerateStrongPassword(80,200),'sha-256')
		}
	};

	if(qRating.recordcount EQ 0){
		application.zcore.functions.z404("Invalid inquiries_id: #form.id#");
		form.inquiries_rating_id=application.zcore.functions.zInsert(ts);
		if(not form.inquiries_rating_id){
			db.sql="select * from #db.table("inquiries_rating", request.zos.zcoreDatasource)# 
			WHERE inquiries_id=#db.param(form.id)# and 
			site_id = #db.param(request.zos.globals.id)# and 
			inquiries_deleted=#db.param(0)# ";
			qRating=db.execute("qRating");
		}
	}else{
		ts.struct.inquiries_rating_id=qRating.inquiries_rating_id;
		if(not application.zcore.functions.zUpdate(ts)){
			throw("Failed to store rating");
		}
	}
	for(row in qRating){
		if(row.inquiries_rating_setting_thanks_cfc_object NEQ "" and row.inquiries_rating_setting_thanks_cfc_method NEQ	""){
			// custom callback for thank you page.
			objectPath=replace(row.inquiries_rating_setting_thanks_cfc_object, "root.", request.zRootCFCPath&".");
			objectCom=createobject("component", objectPath);
			objectCom[row.inquiries_rating_setting_thanks_cfc_method]();
		}else{
			// display the 2 fields instead
			application.zcore.template.setTag("title", row.inquiries_rating_setting_thanks_heading);
			application.zcore.template.setTag("pagetitle", row.inquiries_rating_setting_thanks_heading);
			echo(row.inquiries_rating_setting_thanks_body);
		}
	}
	</cfscript>
</cffunction>
</cfcomponent>