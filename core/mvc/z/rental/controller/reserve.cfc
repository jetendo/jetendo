<cfcomponent><cfoutput>
  <!--- <cfparam name="inquiries_adults" type="any" default="">
  <cfparam name="inquiries_children" type="any" default="">
  <cfparam name="inquiries_children_age" type="any" default="">
  <cfparam name="calc" type="any" default="">
  <cfparam name="theTotal" type="any" default=0>
  <cfparam name="security_deposit" type="any" default="">
  <cfparam name="reserve" type="any" default="true">
	  
  <cfscript>
tax = .1;
if(request.zos.istestserver EQ false){
if((structkeyexists(form, 'secure') AND request.zos.CGI.SERVER_PORT NEQ '443')){
	application.zcore.functions.zRedirect(request.zos.globals.securedomain&request.cgi_script_name&'?'&request.zos.CGI.QUERY_STRING);
}
}
application.zcore.functions.zstatushandler(request.zsid,true,true);
if (structkeyexists(form, 'secure') and structkeyexists(form, 'reserve') and (isDefined('inquiries_adults') EQ false or inquiries_adults eq "")){
application.zcore.status.setStatus(request.zsid, 'At least 1 adult is required to make a reservation.',form); 	application.zcore.functions.zRedirect(request.zos.globals.securedomain&"/z/_a/rental/calendar-results"&'?zsid=#request.zsid#&rental_id=#rental_id#&reserve=1&secure=1&search_start_date=#urlencodedformat(inquiries_start_date)#&search_end_date=#urlencodedformat(inquiries_end_date)#'); 
}
</cfscript>
  <!--- <cfif request.cgi_script_name EQ '/rental_action.cfm'> --->
  

  
  <cfif (request.CGI_SCRIPT_NAME EQ '/z/_a/rental/reserve')OR(reserve EQ true)>
    <cfif structkeyexists(form, 'action') EQ false>
      <cfset form.action = "form">
    </cfif>
    <cfif structkeyexists(form, 'action') and  form.action EQ "send">
      <cfscript>
	error=false;
	if(application.zcore.functions.zFakeFormFieldsNotEmpty()){
		application.zcore.functions.zRedirect(request.cgi_script_name&"?action=sent&zsid="&request.zsid);
	}
	</cfscript>
      <cfif structkeyexists(form, 'secure')>
        <!--- <cfscript>
		if(request.zos.cgi.remote_addr NEQ '71.41.117.181'){
			application.zcore.status.setStatus(request.zsid, 'Sorry, but the reservation system is temporarily under maintenance, please call us to make your reservation.',form,true);
			application.zcore.functions.zRedirect(request.cgi_script_name&'?zsid=#request.zsid#');
		}
		</cfscript> --->
        <cfscript>
	myForm=StructNew();
	
	myForm.inquiries_email.required = true;
	myForm.inquiries_email.friendlyName = "Email Address";
	myForm.inquiries_email.email = true;
	myForm.inquiries_first_name.required = true;
	myForm.inquiries_first_name.allowNull = false;
	myForm.inquiries_first_name.friendlyName = "First Name";
	myForm.inquiries_phone1.required = true;
	myForm.inquiries_phone1.allowNull = false;
	myForm.inquiries_phone1.friendlyName = "Home Phone";
	myform.c_name.required=true;
	myform.c_name.friendlyName="Cardholder Name";
	myForm.c_name.allowNull = false;
	myform.c_address.required=true;
	myform.c_address.friendlyName="Billing Address";
	myForm.c_address.allowNull = false;
	myform.c_city.required=true;
	myform.c_city.friendlyName="City";
	myForm.c_city.allowNull = false;
	myform.c_zip.required=true;
	myform.c_zip.friendlyName="Zip";
	myForm.c_zip.allowNull = false;
	myform.c_cardnumber.required=true;
	myform.c_cardnumber.friendlyName="Credit Card Number";
	myForm.c_cardnumber.allowNull = false;
	myform.C_CVV.required=true;
	myform.C_CVV.friendlyName="Security Code (CVV)";
	myForm.C_CVV.allowNull = false;
	
	inquiries_type_id = 1;
		inquiries_type_id_siteIdType=4;
	inquiries_status_id = 1;
	result = zValidateStruct(form, myForm, Request.zsid,true);
	site_id = request.zOS.globals.id;
	
	
//add fields to inquiry table. 
inquiries_reservation='1';
inquiries_reservation_status=0; // (unauthorized) | 1 (authorized) | 2 (cancelled)
inquiries_company=application.zcore.functions.zso(form, 'inquiries_company');
inquiries_c_card4digit=right(c_cardnumber,4);
inquiries_c_name=c_name;
inquiries_c_address=c_address;
inquiries_c_address2=c_address2;
inquiries_c_city=c_city;
inquiries_c_country=c_country;
inquiries_c_state=c_state;
inquiries_c_zip=c_zip;

		
C_ADDRESS=application.zcore.functions.zso(form, 'c_address');
C_ADDRESS2=application.zcore.functions.zso(form, 'c_address2');
C_CARDNUMBER=application.zcore.functions.zso(form, 'C_CARDNUMBER');
C_CITY=application.zcore.functions.zso(form, 'C_CITY');
C_COUNTRY=application.zcore.functions.zso(form, 'C_COUNTRY');
C_CVV=application.zcore.functions.zso(form, 'C_CVV');
C_NAME=application.zcore.functions.zso(form, 'C_NAME');
C_STATE=application.zcore.functions.zso(form, 'C_STATE');
C_ZIP=application.zcore.functions.zso(form, 'C_ZIP');
/*INQUIRIES_ADULTS=application.zcore.functions.zso(form, 'INQUIRIES_ADULTS');
INQUIRIES_CHILDREN=application.zcore.functions.zso(form, 'INQUIRIES_CHILDREN');
INQUIRIES_CHILDREN_AGE=application.zcore.functions.zso(form, 'INQUIRIES_CHILDREN_AGE');*/
INQUIRIES_COMMENTS=application.zcore.functions.zso(form, 'INQUIRIES_COMMENTS');
INQUIRIES_EMAIL=application.zcore.functions.zso(form, 'INQUIRIES_EMAIL');
INQUIRIES_FIRST_NAME=application.zcore.functions.zso(form, 'INQUIRIES_FIRST_NAME');
INQUIRIES_LAST_NAME=application.zcore.functions.zso(form, 'INQUIRIES_LAST_NAME');
INQUIRIES_PHONE1=application.zcore.functions.zso(form, 'INQUIRIES_PHONE1');
INQUIRIES_RESERVATION=application.zcore.functions.zso(form, 'INQUIRIES_RESERVATION');
inquiries_start_date=application.zcore.functions.zso(form, 'inquiries_start_date');
inquiries_end_date=application.zcore.functions.zso(form, 'inquiries_end_date');
INQUIRIES_TYPE_ID=application.zcore.functions.zso(form, 'INQUIRIES_TYPE_ID');
if(rental_id EQ 26 or rental_id EQ 47 or rental_id EQ 49 or rental_id EQ 52){
	inquiries_pets=zso(form, 'inquiries_pets',true);
	inquiries_pet_total_fee=zso(form, 'inquiries_pet_total_fee');
}
cardexpmonth=application.zcore.functions.zso(form, 'month');
rental_ID=application.zcore.functions.zso(form, 'rental_ID');
form.rental_id=rental_id;
cardexpyear=application.zcore.functions.zso(form, 'year');



		error=false;
		inquiries_deposit=0;
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form);
		error=true;
	}
	if(isDefined('inquiries_first_name') and Find("@", inquiries_first_name) NEQ 0){
		application.zcore.status.setStatus(Request.zsid, "Invalid Request",form);
		error=true;
	}
	if(isDefined('inquiries_comments') EQ false or findnocase("[/url]", inquiries_comments) NEQ 0 or findnocase("http://", inquiries_comments) NEQ 0 ){
		application.zcore.status.setStatus(Request.zsid, "Invalid Request",form,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#Request.zsid#&rental_id=#rental_id#&action=form&secure=1&reserve=1");
	}
	if(inquiries_start_date EQ false or inquiries_end_date EQ false or DateCompare(inquiries_start_date, inquiries_end_date) GTE 0 or DateCompare(inquiries_start_date, now()) EQ -1){
		application.zcore.status.setStatus(request.zsid, 'Please select a valid start and end date in the future for your stay and submit your reservation again.  If you are trying to reserve a last minute cabin for tonight, please call our office during business hours to schedule your reservation.',form);
		error=true;
	}
	if(application.zcore.functions.zEmailValidate(inquiries_email) EQ false){
		application.zcore.status.setStatus(request.zsid, 'You must provide a valid email address.',form);
		error=true;
	}
	if(isDefined('agreetocharge') EQ false){
		application.zcore.status.setStatus(request.zsid, 'You must check the box to agree to our TERMS before submitting your reservation, please go back and try again.',form);
		error=true;
	}

</cfscript>

        <cfsavecontent variable="db.sql">
SELECT * FROM rental WHERE rental_id = #db.param(rental_id)#
        </cfsavecontent><cfscript>qprop=db.execute("qprop");
if(qprop.recordcount EQ 0){
	application.zcore.status.setStatus(request.zsid, 'You must select a cabin rental before submitting your reservation, please go back and try again.',form);
	error=true;
}

inquiries_address=c_address;
inquiries_address2=c_address2;
// parse the reservation start/end date 



db.sql="SELECT * FROM availability 
WHERE rental_id = #db.param(rental_id)# and 
availability_date >=#db.param(DateFormat(inquiries_start_date,'yyyy-mm-dd'))# and 
availability_date <= #db.param(DateFormat(inquiries_end_date,'yyyy-mm-dd'))# and 
availability_deleted = #db.param(0)#";
qAvail=db.execute("qAvail"); 

if(qAvail.recordcount NEQ 0){
	application.zcore.status.setStatus(request.zsid, 'This cabin is not available during the selected dates, please try a different cabin or date range.',form);
	error=true;
}

if(error){
	application.zcore.functions.zRedirect(request.cgi_script_name&'?reserve=1&secure=1&rental_id=#rental_id#&zsid=#request.zsid#');
}


// recalculate the rates here:
ts=StructNew();
ts.rental_id=rental_id;
ts.startDate=inquiries_start_date;
ts.endDate=inquiries_end_date;
ts.adults=inquiries_adults;
ts.children=inquiries_children;
ts.pets=zso(form, 'inquiries_pets',true);
ts.couponCode=inquiries_coupon_code;
rs=application.zcore.app.getAppCFC("rental").rateCalc(ts);
if(rs.error){
	application.zcore.status.setStatus(request.zsid, 'Invalid Date Range');
	writeoutput("invalid date range or rental");
	zabort();
	/	application.zcore.functions.zRedirect(request.cgi_script_name&'?zsid=#request.zsid#');
}
for(i in rs){
	structInsert(variables,i,rs[i],true);
}
if(rental_id EQ 26 or rental_id EQ 47 or rental_id EQ 49 or rental_id EQ 52){
	inquiries_pets=zso(form, 'inquiries_pets',true);
	inquiries_pet_total_fee=rs.inquiries_pet_total_fee;
}
ordertype = "SALE"; // also PREAUTH POSTAUTH VOID CREDIT CALCSHIPPING CALCTAX
cardnumber = c_cardnumber; // force 2 digit
chargetotal=rs.inquiries_deposit;
security_deposit=rs.inquiries_deposit;
/*if(thetotal neq "" & rental_id EQ 18 or rental_id EQ 42){
	chargetotal = numberformat(thetotal/2,'_.__');
	security_deposit=chargetotal;
}else {
	chargetotal = "250.00";
}// later 250.00
*/
addrnum = val(c_address);
zip = c_zip;
// max
//oid = "reservation_id"; // use reservation_id - pad it?
ip = request.zos.cgi.remote_addr;
inquiries_ip = request.zos.cgi.remote_addr;
// BILLING INFO
name = c_name;
company = inquiries_company;
address1 = C_ADDRESS;
address2 = C_ADDRESS2;
city = C_City;
state = C_state;
country = c_country;
phone = INQUIRIES_PHONE1;
//fax = "8059876543";
email = inquiries_email;
 
// ADDITIONAL INFO ---;
comments = "Reservation for #qprop.rental_name# from "&DateFormat(inquiries_start_date,'m/d/yyyy')&" to "&DateFormat(inquiries_end_date,'m/d/yyyy');

if(request.zos.istestserver){
	debugNow=true;
}else{
	debugNow=false;
}
</cfscript>
do remote transaction
        <cfscript>
inquiries_datetime=request.zos.mysqlnow;
if(isDefined('inquiries_email_opt_in') EQ false){
	inquiries_email_opt_in=0;
}
if(debugNow){
	r_approved = "APPROVED";
}
if(r_approved EQ 'APPROVED'){
	/*if(security_deposit neq "" and rental_id EQ 18 or rental_id EQ 42){
		inquiries_deposit=numberformat(thetotal/2,"_.__");
	}else{
		inquiries_deposit="250.00";
	}*/
	// set response
	if(debugNow){
		inquiries_c_response="";
	}else{
		inquiries_c_response = "R_APPROVED:#R_APPROVED##chr(10)#R_CODE:#R_CODE##chr(10)#R_ERROR:#R_ERROR##chr(10)#R_ORDERNUM:#R_ORDERNUM##chr(10)#R_TIME:#R_TIME##chr(10)#R_REF:#R_REF##chr(10)#R_AVS:#R_AVS##chr(10)#R_SCORE:#R_SCORE##chr(10)#R_vpasresponse:#R_vpasresponse##chr(10)#R_CSP:#R_CSP##chr(10)#R_AUTHRESPONSE:#R_AUTHRESPONSE##chr(10)#R_MESSAGE:#R_MESSAGE##chr(10)#R_APIVERSION:#R_APIVERSION#";
	}
	inquiries_reservation_status='1';
	inquiries_start_date=DateFormat(inquiries_start_date,'yyyy-mm-dd');
	inquiries_end_date=DateFormat(inquiries_end_date,'yyyy-mm-dd');
	// create reservation as inquiries record 
	inquiries_id=application.zcore.functions.zInsertLead();
	if(inquiries_id EQ false){
		// failed but deposit was made - yikes.
	}else{
		// success!
	}
	// set availability calendar
	nights=DateDiff("d",inquiries_start_date, inquiries_end_date);
	for(i=1;i LTE nights;i=i+1){
		curDay=dateadd("d",i-1,inquiries_start_date);
		db.sql="INSERT INTO availability 
		SET rental_id = #db.param(rental_id)#,
		availability_date = #db.param(DateFormat(curDay, 'yyyy-mm-dd'))#, 
		availability_updated_datetime = #db.param(request.zos.mysqlnow)#, 
		inquiries_id = #db.param(inquiries_id)#";
		db.execute("q");  
	}
}else{
	application.zcore.status.setStatus(request.zsid, 'Your credit card was not approved.  Please review your information and try again.  If your continue to have a problem, please call our office during business hours.',form);
	application.zcore.functions.zRedirect(request.cgi_script_name&'?reserve=1&secure=1&rental_id=#rental_id#&zsid=#request.zsid#');
}

</cfscript>
        <cfelse>
        
        <!--- Display inquiry form --->
        
        <cfsavecontent variable="db.sql">
		SELECT * FROM rental WHERE rental_id = #db.param(application.zcore.functions.zso(form, 'rental_id'))#
        </cfsavecontent><cfscript>qprop=db.execute("qprop");
			myForm=StructNew();
			myForm.inquiries_email.required = true;
			myForm.inquiries_email.friendlyName = "Email Address";
			myForm.inquiries_email.email = true;
			myForm.inquiries_first_name.required = true;
			myForm.inquiries_first_name.allowNull = false;
			myForm.inquiries_first_name.friendlyName = "First Name";
			myForm.inquiries_phone1.required = true;
			myForm.inquiries_phone1.allowNull = false;
			myForm.inquiries_phone1.friendlyName = "Phone";
			inquiries_type_id = 1;
		inquiries_type_id_siteIdType=4;
			inquiries_status_id = 1;
			result = zValidateStruct(form, myForm, Request.zsid,true);
			site_id = request.zOS.globals.id;
			if(result){	
				application.zcore.status.setStatus(Request.zsid, false,form);
				error=true;
			}
			if(isDefined('inquiries_first_name') and Find("@", inquiries_first_name) NEQ 0){
				application.zcore.status.setStatus(Request.zsid, "Invalid Request",form);
				error=true;
			}
	if(isDefined('inquiries_comments') EQ false or findnocase("[/url]", inquiries_comments) NEQ 0 or findnocase("http://", inquiries_comments) NEQ 0 ){
		application.zcore.status.setStatus(Request.zsid, "Invalid Request",form,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&"?zsid=#Request.zsid#&action=form");
	}
			if(error){
				application.zcore.functions.zRedirect(request.cgi_script_name&'?rental_id='&application.zcore.functions.zso(form, 'rental_id')&'&zsid=#request.zsid#');
			}
			if(inquiries_start_date NEQ false){
				inquiries_start_date=DateFormat(inquiries_start_date,'yyyy-mm-dd');
			}
			if(inquiries_end_date NEQ false){
				inquiries_end_date=DateFormat(inquiries_end_date,'yyyy-mm-dd');
			}
			inquiries_datetime=request.zos.mysqlnow;
			if(isDefined('inquiries_email_opt_in') EQ false){
				inquiries_email_opt_in=0;
			}
			inquiries_reservation_status='0';
			 
			inquiries_id=application.zcore.functions.zInsertLead();
			if(inquiries_id EQ false){
				// failed but deposit was made - yikes.
			}else{
				// success!
			}			
			</cfscript>
      </cfif>
      <cfif isDefined('inquiries_reservation') and inquiries_reservation EQ 1>
        <cfset subject=request.zos.globals.shortdomain&": Reservation Inquiry from #inquiries_first_name# #inquiries_last_name#">
        <cfelse>
        <cfset subject=request.zos.globals.shortdomain&": Inquiry from #inquiries_first_name# #inquiries_last_name#">
      </cfif>
	  <cfscript>
		local.tempEmail=application.zcore.functions.zvarso('zofficeemail');
		</cfscript>
<cfdisabledmail  charset="utf-8" from="#local.tempEmail#" to="#local.tempEmail#" subject="#subject#">
<cfif structkeyexists(form, 'secure')>This person has already paid the #DollarFormat(security_deposit)# deposit and the availability calendar has been updated.  Please send them a confirmation email with the final total of their stay listed.#chr(10)##chr(10)#</cfif>
<!--- <cfif isDefined('inquiries_reservation') and inquiries_reservation EQ 1>This person is interested in making a reservation, please contact them immediately.#chr(10)#</cfif> --->
<cfif isDefined('inquiries_reservation_status') and inquiries_reservation_status EQ 1>Total charged to credit card: #DollarFormat(security_deposit)# 
IP Address:#request.zos.cgi.remote_addr#
Timestamp: #dateformat(inquiries_datetime, 'm/d/yyyy')&' '&TimeFormat(inquiries_datetime,'HH:mm:ss')#

BILLING INFO:
cardholder name: #c_name#
address1: #C_ADDRESS#
address2: #C_ADDRESS2#
city: #C_City#
state: #C_state#
country: #c_country#
phone: #INQUIRIES_PHONE1#
last 4 digits cardnumber: #right(c_cardnumber,4)##chr(10)#
</cfif>
<cfscript>
inquiries_start_date=DateFormat(inquiries_start_date,'m/d/yyyy');
inquiries_end_date=DateFormat(inquiries_end_date,'m/d/yyyy');
</cfscript>
Cabin Rental:<cfif isDefined('rental_id') and trim(rental_id) NEQ ''>#qprop.rental_name#<cfelse>No rental Selected</cfif>
Start Date:#application.zcore.functions.zso(form, 'inquiries_start_date')#
End Date:#application.zcore.functions.zso(form, 'inquiries_end_date')#
Name:#inquiries_first_name##application.zcore.functions.zso(form, 'inquiries_last_name')#
company:#inquiries_company#
Email:#application.zcore.functions.zso(form, 'inquiries_email')#
Phone:#application.zcore.functions.zso(form, 'inquiries_phone1')#
Adults:#application.zcore.functions.zso(form, 'inquiries_adults')#
Children Age 3+:#application.zcore.functions.zso(form, 'inquiries_children')#
Children Under 3:#application.zcore.functions.zso(form, 'inquiries_children_age')##chr(10)#
<cfif zso(form, 'inquiries_pets',true) NEQ '0' and (rental_id EQ 26 or rental_id EQ 47 or rental_id EQ 52)>## of Pets:#inquiries_pets##chr(10)#Pet Fees:#dollarformat(rs.inquiries_pet_total_fee)##chr(10)#</cfif>
Comments:#application.zcore.functions.zso(form, 'inquiries_comments')#
Email Opt-in: <cfif isDefined('inquiries_email_opt_in')>Yes</cfif>#chr(10)##chr(10)#


<cfif inquiries_reservation EQ 1>
Nights Breakdown: #inquiries_night_breakdown##chr(10)#
Nights Total: #DollarFormat(inquiries_nights_total)##chr(10)#
Cleaning Fee: #Dollarformat(inquiries_cleaning)# <!--- (not taxed) --->#chr(10)#
Additional Guests: #inquiries_addl_guest##chr(10)#
<!--- Additional Cleaning Fee: #dollarformat(inquiries_addl_cleaning)# <!--- (not taxed) --->#chr(10)# --->
Additional Rental: #dollarformat(inquiries_addl_rate)##chr(10)#
Subtotal: #dollarformat(inquiries_subtotal)##chr(10)#
Tax: #DollarFormat(inquiries_tax)##chr(10)#
<cfif inquiries_discount NEQ 0>
Discount: #DollarFormat(inquiries_discount)##chr(10)#
Discount Description: #inquiries_discount_desc##chr(10)#
</cfif>
Total: #dollarformat(inquiries_total)##chr(10)#
Amount Deposited: #DollarFormat(inquiries_deposit)##chr(10)#
Balance Due: #DollarFormat(inquiries_balance_due)##chr(10)#
</cfif>

Login and view inquiry:
#request.zos.currentHostName#/member/inquiries/<cfif isDefined('inquiries_reservation_status') and inquiries_reservation_status EQ 1>index<cfelse>feedback</cfif>.cfm?action=view&inquiries_id=#inquiries_id#
</cfmail>

		
	<cfscript>
	if(inquiries_email_opt_in EQ 0){
		// force opt-out
		request.zUserOptOut=true;
	}
	application.zcore.tracking.setEmailConversion(2);
	user_id=application.zcore.user.automaticAddUser(application.zcore.functions.zUserMapFormFields(structnew()));</cfscript>


      <cfif isDefined('inquiries_reservation') and inquiries_reservation EQ 1>
        <cfsavecontent variable="db.sql">
		SELECT * FROM (inquiries_status, 
		inquiries) 
        LEFT JOIN inquiries_type ON 
		inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
		inquiries_type.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#) and 
		inquiries.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
		inquiries_type_deleted = #db.param(0)#
        LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
		user.user_id = inquiries.user_id and 
		user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
		user_deleted = #db.param(0)#
        WHERE inquiries.site_id = #db.param(request.zOS.globals.id)#  and 		
		inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
        inquiries_id = #db.param(inquiries_id)# and 
        inquiries_status_deleted = #db.param(0)# and 
        inquiries_deleted = #db.param(0)#
        </cfsavecontent><cfscript>qinquiry2=db.execute("qinquiry2");
	zquerytostruct(qinquiry2);
	</cfscript>
        <cfmail to="#inquiries_email#" from="#request.fromemail#" bcc="#request.officeemail#" subject="Reservation Confirmation ###inquiries_id#" type="html">
          #application.zcore.functions.zHTMLDoctype()#
          <body>
          <span style="font-family:Verdana,Arial,Helvetica, sans-serif;font-size:12px;">
          <h2>Your Confirmation Number is : #inquiries_id#</h2>
          <h2>Reservation Confirmation Details</h2>
		  <p>Please ensure all  information below is accurate.&nbsp; If there  is a discrepancy in the information please call our office immediately.&nbsp; Make sure you scroll to the end of the  statement to read important information.&nbsp;  The statement will end with our address and phone numbers.</p>
          <cfif datediff("h", createdate(year(now()), month(now()), day(now())),inquiries_start_date) LTE 48>
            <span style="font-size:14px; line-height:24px;"><strong>THIS IS A LAST MINUTE BOOKING:</strong> <br />
            <!--- When booking our cabins within 48 hours of arrival, we ask that you <strong>CALL 1-706-455-7400</strong> to ensure someone is there to help you check-in especially over the weekend. <br />
            <strong style="font-size:18px;">Please call 1-706-455-7400 and leave a message to confirm your reservation now.</strong></span><br /> --->
            <br />
          </cfif>
          <cfset request.usestyleonly=true>
			<cfscript>
			iEmailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
			iEmailCom.getEmailTemplate("", false);
			</cfscript>
          <cfset StructDelete(request,'usestyleonly')>
		  
		Terms, conditions, company contact info here...</span>
          </body>
          </html>
        </cfmail>
            

		
	<cfscript> 
		if( resetvrve ?){
			if(structkeyexists(form, 'secure')){
			  application.zcore.functions.zredirect('/z/_a/rental/reserve?action=securesent&inquiries_id=#inquiries_id#&inquiries_email=#urlencodedformat(inquiries_email)#';
			}else{
				application.zcore.functions.zredirect('/z/_a/rental/reserve?action=sent&reserve=1';
			}
        }else{
        	application.zcore.functions.zredirect('/z/_a/rental/reserve?action=sent');
		}
		</cfscript>
    </cfif>
    <cfif structkeyexists(form, 'action') and form.action EQ "securesent">
      <cfsavecontent variable="zoverridemetakey">
      <meta name="keywords" content="inquiry blue ridge cabin rental">
      </cfsavecontent>
      <cfsavecontent variable="zoverridemetadesc">
      <meta name="description" content="Inquiry form for our blue ridge cabin rentals">
      </cfsavecontent>
      <cfscript>
				zoverridetitle = "Reservation Confirmation";
				zPageTitle = "Reservation Confirmation";
			</cfscript>
      <cfsavecontent variable="zpagenav">
      <a href="#request.zos.currentHostName#/">Home</a> / <a href="#request.zos.currentHostName#/cabin_rentals/index.html">Cabin Rentals</a> /
      </cfsavecontent>
      <h2>Thank you! Your reservation has been made successfully.</h2>
      <br />
      <h2>Your Confirmation Number is :#inquiries_id#</h2>
      <br />
      Please save or <a href="JavaScript:window.print();">print this page</a> for your records. A copy of your reservation has been sent to your email address.<br />
      <br />
      <h2>Reservation Confirmation Details</h2>
		  <p>Please ensure all  information below is accurate.&nbsp; If there  is a discrepancy in the information please call our office immediately.&nbsp; Make sure you scroll to the end of the  statement to read important information.&nbsp;  The statement will end with our address and phone numbers.</p>
      <cfsavecontent variable="db.sql">
		SELECT * FROM (inquiries_status, inquiries) 
      LEFT JOIN inquiries_type ON 
	  inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and 
	  inquiries_type.site_id IN (#db.param('0')#,#db.param(request.zos.globals.id)#) and 
	  inquiries.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	  inquiries_type_deleted = #db.param(0)#
      LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	  user.user_id = inquiries.user_id and 
	  user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.user_id_siteIDType"))# and 
	  user_deleted = #db.param(0)#
      WHERE inquiries.site_id = #db.param(request.zOS.globals.id)#  and 	
      inquiries_deleted = #db.param(0)# and 
      inquiries_status_deleted = #db.param(0)# and 	
	  inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
      inquiries_id = #db.param(application.zcore.functions.zso(form, 'inquiries_id'))# and 
		inquiries_email = #db.param(application.zcore.functions.zso(form, 'inquiries_email'))#
      </cfsavecontent><cfscript>qInquiry=db.execute("qInquiry");
			if(qInquiry.recordcount EQ 0){
				application.zcore.status.setStatus(request.zsid, 'Invalid request');
				application.zcore.functions.zRedirect('/inquiry.cfm?zsid=#request.zsid#');
			}
			zQueryToStruct(qinquiry);
			inquiries_datetime2=parsedatetime(dateformat(inquiries_datetime,"yyyy-mm-dd")&" "&timeformat(inquiries_datetime, "HH:mm:ss"));
			</cfscript>
      <cfif datediff("h", createdate(year(inquiries_datetime2), month(inquiries_datetime2), day(inquiries_datetime2)),inquiries_start_date) LTE 48>
        <span style="font-size:14px; line-height:24px;"><strong>THIS IS A LAST MINUTE BOOKING:</strong><br />
        When booking our cabins within 48 hours of arrival, we ask that you <strong>CALL 1-706-455-7400</strong> to ensure someone is there to help you check-in especially over the weekend.<br />
        <strong style="font-size:18px;">Please call 1-706-455-7400 and leave a message to confirm your reservation now.</strong></span><br />
        <br />
      </cfif>
        <cfscript>
		viewIncludeCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		viewIncludeCom.getViewInclude(qinquiry, true);
		</cfscript>
      <br />
	   
		<p>If you need to make changes to the number of guests, let us know so we can adjust your payment fees.</p>

		  
		 <p><strong>Payment Agreement: </strong>&nbsp;#dollarformat(inquiries_deposit)# was charged to your credit card to hold your reservation.  This amount will be deducted from your rental fee.&nbsp; The remaining balance will  be due at time of check in and can only be paid by money order, cash, check, or  traveler's checks.&nbsp;&nbsp; *In the event you  forget to bring any of the said items for payment and have to pay with a credit  card,&nbsp; a $25 processing fee will be  charged to the balance.*&nbsp; </p>
<p><strong>Deposit:</strong>&nbsp; At  time of check in a credit card hold will be required.&nbsp; The card will not be charged but will be held  for 10 days and released provided no damage is found evident to the cabin and  all policy procedures are met.&nbsp; *In the  event you must cancel your reservation, the #dollarformat(inquiries_deposit)# down payment will be considered  your deposit and will not be refunded.&nbsp;  If reservation is canceled within our cancellation time period, deposit  will be refunded back to you minus a $25 processing fee.*</p>
<p><strong>Cancellations: </strong>&nbsp;To cancel a reservation we require a phone  call to our office.&nbsp; You will need to  mail a certified letter stating you are canceling the reservation.&nbsp; Cancellations are only accepted by certified  mail to the address below.&nbsp; <br />
  *Reservations cancelled with less than a 1 month notice  are subject to a $100 fee.&nbsp; Any  reservation cancelled with less than a 2 week notice forfeits #dollarformat(inquiries_deposit)#  deposit.&nbsp; No shows are subject to the  entire rental fees.&nbsp; Cancellation policy  applies to last minute bookings as well.&nbsp;  Sorry, No Exceptions. *&nbsp; </p>
		  
		  
		  
		  
          <br />
          If you have any questions regarding your reservation, please call us at #request.realestatephone# or reply to this email.  Please note we are closed on Sundays. <br />
          <br />
		  
		  <p><strong><u>Directions  from Atlanta:</u></strong> <br />
  Go 75 North to 575  North.&nbsp; This is a direct route to Blue  Ridge.&nbsp; Once in Blue Ridge at the traffic  light at McDonalds, counting that red light, go through the 5th red light which  is at a Marathon Station. Get in the right hand turning lane and turn right onto  Tammen Drive. If you will look on the hill to your right you will see a  billboard &quot;Mountain Country Realty&quot;. Our office is a glass front log  home.&nbsp; Just follow the office signs.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </p>
<p>NOTE:&nbsp; Check in is at 4:00 P.M.&nbsp; If you arrive after 5:00 p.m or on Sunday the  office will be closed.&nbsp; In this case, you  will have a package with keys and directions to your cabin in the WHITE RENTAL  INFO box in front of the Office on the lower level.&nbsp; You will need to read and sign the Liability  Release form before check in.&nbsp; Every  person in your party must sign the Release Form.&nbsp; If you plan on having any visitors during  your stay they must also sign the Release Form.&nbsp;  You may fax it to us or send it by regular mail.&nbsp;&nbsp; If you are sure you will be arriving before  5pm, you may bring along the form in order to pick up your package.&nbsp; If you have questions, please call our  office.</p>
<p><strong>Please Note: Kaylor Mtn Cabins has a strict NO PET, NO  SMOKING Policy in every cabin except for "Truly Blessed" which allows pets (2 pet limit).&nbsp; You will  automatically forfeit your deposit by bringing Pets to a cabin or Smoking in a  cabin.</strong></p>
<p>Toll-Free:  1-888-452-9567 <br />
  Cell Phone:  1-706-455-7100 or 7400.&nbsp; <br />
  Fax: 1-706-258-2039<br />
  Website:&nbsp; <a href="#zvar('domain')#/">www.kaylormtncabins.com</a></p>
<p><strong>Mailing address: P.O.  Box 647 Mineral Bluff, GA 30559</strong><br />
  Our physical address is  181 Tammen Drive, Blue Ridge GA. 30513<br />
  You can view our website  for more information at <a href="#zvar('domain')#/">www.kaylormtncabins.com</a></p>
<p>Thank You,<br />
  Kaylor Mtn Cabin Rentals </p>
  
    </cfif>
  </cfif>
  <cfif structkeyexists(form, 'action') and form.action EQ "sent">
    <cfsavecontent variable="zoverridemetakey">
    <meta name="keywords" content="inquiry blue ridge cabin rental">
    </cfsavecontent>
    <cfsavecontent variable="zoverridemetadesc">
    <meta name="description" content="Inquiry form for our blue ridge cabin rentals">
    </cfsavecontent>
    <cfscript>
			if(structkeyexists(form, 'reserve')){
				zoverridetitle = "Online Reservation";
				zPageTitle = "Online Reservation";
			}else{
				zoverridetitle = "Inquiry for Blue Ridge Cabin Rentals";
				zPageTitle = "Inquiry for Blue Ridge Cabin Rentals";
			}
			</cfscript>
    <cfsavecontent variable="zpagenav">
    <a href="#request.zos.currentHostName#/">Home</a> / <a href="#request.zos.currentHostName#/cabin_rentals/index.html">Cabin Rentals</a> /
    </cfsavecontent>
    <cfif structkeyexists(form, 'reserve')>
      <h2>Thank you! Your reservation request has been sent.</h2>
      Someone will contact you soon to get your billing information and answer any questions you may have about the cabin rental.<br />
      <br />
      <cfelse>
      <h2>Thank you for submitting an inquiry.</h2>
      We will be in contact soon.  If you have any additional questions, please feel free to call or inquire again.<br />
      <br />
    </cfif>
    NEED CONVERSION TRACKING CODE HERE FOR tracking.cfc and google
  </cfif>
  <cfif  ((structkeyexists(form, 'action') and form.action EQ "form") or request.CGI_SCRIPT_NAME NEQ '/z/_a/rental/reserve')>
    <cfscript>
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
   <!---  <cfsavecontent variable="db.sql">
	SELECT *
    from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
    WHERE inquiries_id = #db.param(-1)# and 
    inquiries_deleted = #db.param(0)# and 
    site_id=#db.param(request.zos.globals.id)# 
    </cfsavecontent><cfscript>qInquiries=db.execute("qInquiries");
		for(i=1;i LTE listlen(qInquiries.columnlist);i=i+1){
			StructInsert(variables, listgetat(qInquiries.columnlist,i), qInquiries[listgetat(qInquiries.columnlist,i)][1], true);
		}
		</cfscript> --->
    <cfif request.CGI_SCRIPT_NAME EQ '/z/_a/rental/reserve'>
      <cfsavecontent variable="zoverridemetakey">
      <meta name="keywords" content="inquiry blue ridge cabin rental">
      </cfsavecontent>
      <cfsavecontent variable="zoverridemetadesc">
      <meta name="description" content="Inquiry form for our blue ridge cabin rentals">
      </cfsavecontent>
      <cfscript>
			if(structkeyexists(form, 'reserve')){
				zoverridetitle = "Online Reservation";
				zPageTitle = "Online Reservation";
			}else{
				zoverridetitle = "Inquiry for Blue Ridge Cabin Rentals";
				zPageTitle = "Inquiry for Blue Ridge Cabin Rentals";
			}
			</cfscript>
      <cfsavecontent variable="zpagenav">
      <a href="#request.zos.currentHostName#/">Home</a> / <a href="#request.zos.currentHostName#/cabin_rentals/index.html">Cabin Rentals</a> /
      </cfsavecontent>
      <cfscript>
	  if(structkeyexists(form, 'ifmdisable')){
		application.zcore.template.setPlainTemplate();
	  }
	  </cfscript>
    </cfif>
    <cfif structkeyexists(form, 'reserve')>
      <cfscript>
if(structkeyexists(form, 'rental_id') EQ false){
	application.zcore.status.setStatus(request.zsid, 'You must select a rental before making a reservation.',false,true);
	application.zcore.functions.zRedirect(request.cgi_script_name&'?zsid=#request.zsid#');
}
startDateFieldName="inquiries_start_date";
endDateFieldName="inquiries_end_date";

sd2=inquiries_start_date;
ed2=inquiries_end_date;
if(application.zcore.functions.zso(form, 'sd2') EQ '' or isdate(sd2) EQ false or zso(form, 'ed2') EQ '' or isdate(ed2) EQ false){
	application.zcore.status.setStatus(request.zsid, 'Please enter a valid date range.');
	zstatushandler(request.zsid);
	/	application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(replacenocase(request.zos.cgi.http_referer,'zsid=','z1sid=','ALL'),'zsid=#request.zsid#'));
	zabort();
}
sd2=parsedatetime(DateFormat(sd2,'yyyy-mm-dd')&' 00:00:00');
ed2=parsedatetime(DateFormat(ed2,'yyyy-mm-dd')&' 00:00:00');
if(DateCompare(sd2, ed2) GTE 0){
	application.zcore.status.setStatus(request.zsid, 'The end date must be after the start date.');
	//zstatushandler(request.zsid);
	/	application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(replacenocase(request.zos.cgi.http_referer,'zsid=','z1sid=','ALL'),'zsid=#request.zsid#'));
}else if(DateDiff("d",sd2, ed2) LTE 1){
	application.zcore.status.setStatus(request.zsid, 'There is a two night minimum stay required on all cabin rentals.');
	//zstatushandler(request.zsid);
	/	application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(replacenocase(request.zos.cgi.http_referer,'zsid=','z1sid=','ALL'),'zsid=#request.zsid#'));
}else if(DateCompare(sd2, now()) EQ -1){
	application.zcore.status.setStatus(request.zsid, 'The start date must be at least one day into the future.');
	//zstatushandler(request.zsid);
	/	application.zcore.functions.zRedirect(application.zcore.functions.zurlappend(replacenocase(request.zos.cgi.http_referer,'zsid=','z1sid=','ALL'),'zsid=#request.zsid#'));

}else{
	searching=true;
}	
if(sd2 NEQ false and ed2 NEQ false){
	request.zsession.inquiries_start_date=sd2;
	request.zsession.inquiries_end_date=ed2;
	variables[startDateFieldName]=sd2;
	variables[endDateFieldName]=ed2;
}
</cfscript>
<cfif isDefined('searching') EQ false or searching EQ false>
<h2>Search Cabin Rental Availability &amp; Make a Reservation</h2>
<cfscript>
urlpropertyid=zso(form, 'property_id');
structdelete(form, "property_id");
</cfscript>
<cfset calendarInclude=true>
<cfset request.hideCalendar=true>
show availability calendar
<cfscript>
form.property_id=urlpropertyid;
</cfscript>
</cfif>
      <cfscript>
	na=false;
	tsd=inquiries_start_date;
	ted=inquiries_end_date;
if(rental_id EQ 18 or rental_id EQ 42){
	na=2;
	tsd=dateadd("d",-1,inquiries_start_date);
	ted=dateadd("d",1,inquiries_end_date);
	writeoutput('Please note this cabin must be available one day before and after your stay in order for it to be reserved.<br /><br /><br />');
}
if(rental_id EQ 36 and zso(form, 'inquiries_adults',true) + zso(form, 'inquiries_children',true) GT 6){
	na=1;
	ted=dateadd("d",1,inquiries_end_date);
}
</cfscript>
      <cfsavecontent variable="db.sql">
		SELECT * FROM rental 
      LEFT JOIN availability a1 ON 
	  (a1.availability_date BETWEEN #db.param(DateFormat(tsd, "yyyy-mm-dd"))# and 
		#db.param(DateFormat(ted, "yyyy-mm-dd"))# and 
		a1.rental_id = rental.rental_id) and a1_deleted = #db.param(0)# 
      LEFT JOIN availability a2 ON 
	  (a2.availability_date >= #db.param(DateFormat(now(), "yyyy-mm-dd"))#  and 
	  a2.rental_id = rental.rental_id)
      <!--- WHERE rental.rental_active=#db.param(1)#  ---> and a2_deleted = #db.param(0)#
      WHERE a1.rental_id IS NULL and 
	  rental.rental_active=#db.param(1)# and  
	  rental_deleted = #db.param(0)# 
      and rental.rental_id = #db.param(form.rental_id)#
      </cfsavecontent><cfscript>qAvail=db.execute("qAvail");</cfscript>
      <cfif qAvail.recordcount EQ 0>
	<cfscript>
    if(na EQ 1){
        application.zcore.status.setStatus(request.zsid,"This rental is not available during the selected dates. Please note this cabin must be available one day after your stay in order for it to be reserved when there are more then 6 guests.",form);
    }else if(na EQ 2){
        application.zcore.status.setStatus(request.zsid,"This rental is not available during the selected dates. Please note this cabin must be available one day before and after your stay in order for it to be reserved.",form);
    }
	if(na NEQ 0){
        application.zcore.functions.zRedirect(application.zcore.functions.zvar('domain')&'/z/_a/rental/calendar-results?rental_id=#rental_id#&reserve=1&secure=1&search_start_date=#urlencodedformat(inquiries_start_date)#&search_end_date=#urlencodedformat(inquiries_end_date)#&inquiries_adults=#inquiries_adults#&inquiries_children=#inquiries_children#&zsid=#request.zsid#');
    }
	application.zcore.status.setStatus(request.zsid, 'This rental is no longer available.');
	application.zcore.functions.zRedirect(request.cgi_script_name&'?zsid=#request.zsid#');
	</cfscript>
        <cfelse>
        <cfscript>
zQueryToStruct(qavail);
</cfscript>
      </cfif>
    </cfif>
    <cfif structkeyexists(form, 'secure') EQ false>
      <cfif structkeyexists(form, 'reserve')>
        <h2>Please Confirm &amp; Submit Your Reservation Below</h2>
        <p>Please feel free to contact our office with any questions or concerns you may have.</p>
        <p><strong>Realty Office Address:</strong>181 Tammen Drive, Blue Ridge, GA 30513<br />
          <strong>Toll-Free Phone:</strong>1-888-452-9567<br />
          <strong>Office Phone:</strong>1-706-632-7100<br />
        </p>
        <hr size="1" />
        <table style="width:100%; border-spacing:10px;border:1px solid ##990000; background-color:##FFFFFF;">
          <tr>
            <td><h2>#rental_name# Cabin Rental Reservation</h2>
              <table style="border-spacing:5px; width:100%;">
                <tr>
                  <td colspan="2"><strong>Please note only the
                    <cfif rental_id neq 18>
$250
                    </cfif>
                    security deposit will be required to reserve the cabin.<br />
                    The total booking amount is due at check-in.<br />
                    Refer to our <a href="#request.zos.currentHostName#/reservation-information-policies.html" target="_blank">cabin rental policies</a> for more information.</strong></td>
                </tr>
              </table>
              <table style="border-spacing:5px; width:100%;">
                <tr>
                  <td style="width:90px;">Start Date:</td>
                  <td>#DateFormat(inquiries_start_date,'mmmm d, yyyy')#</td>
                </tr>
                <tr>
                  <td style="width:90px;">End Date:</td>
                  <td>#DateFormat(inquiries_end_date,'mmmm d, yyyy')#</td>
                </tr>
                <cfscript>
	nights=DateDiff("d",inquiries_start_date,inquiries_end_date);
	
	</cfscript>
                <tr>
                  <td style="width:90px;">##of Nights:</td>
                  <td>#nights#</td>
                </tr>
              </table></td>
          </tr>
        </table>
        <br />
        <cfelse>
        <cfscript>
ts=structnew();
ts.content_id="329";
ts.disableContentMeta=true;
application.zcore.app.getAppCFC("content").includePageContent(ts);
</cfscript> 
        <cfif structkeyexists(form, 'secure') EQ false>
          <p style="font-size:18px; font-weight:bold;"><a href="/online-cabin-rental-reservation.html" target="_top">Click Here to make an online reservation</a><br />
            <br />
            or to ask a question, fill out the form below.</p>
        </cfif>
      </cfif>
      <cfelse>
      <h2>#rental_name# Cabin Rental Reservation</h2>
      <hr size="1">
    </cfif>
    <cfscript>
	application.zcore.functions.zStatusHandler(request.zsid,true,true);
	</cfscript>
  </cfif>
  <cfif structkeyexists(form, 'secure')>
    <h2>Nightly Rate Breakdown</h2>
    <br />
	<cfscript>
	ts=StructNew();
	ts.rental_id=rental_id;
	ts.startDate=inquiries_start_date;
	ts.endDate=inquiries_end_date;
	ts.adults=inquiries_adults;
	ts.children=inquiries_children;
	ts.pets=application.zcore.functions.zso(form, 'inquiries_pets');
	ts.couponCode=application.zcore.functions.zso(form, 'inquiries_coupon_code');
	rs=application.zcore.app.getAppCFC("rental").rateCalc(ts);
	if(rs.error){
		application.zcore.status.setStatus(request.zsid, 'Invalid Date Range');
		writeoutput("invalid date range");
		zabort();
		/	application.zcore.functions.zRedirect(request.cgi_script_name&'?zsid=#request.zsid#');
	}
if(rental_id EQ 26 or rental_id EQ 47 or rental_id EQ 49 or rental_id EQ 52){
	inquiries_pets=zso(form, 'inquiries_pets',true);
	inquiries_pet_total_fee=rs.inquiries_pet_total_fee;
}
	</cfscript>
	<table style="border-spacing:5px;">
	<tr><th>Day</th><th>Date</th><th>Regular Rate</th><th>Your Rate</th><th>Type</th></tr>
	<cfloop index="x" from="1" to="#arrayLen(rs.arrNights)#">
	<tr><td>#rs.arrNights[x].night#</td><td>#DateFormat(rs.arrNights[x].date,'mm-dd-yyyy ddd')#</td>
    <td><span style="text-decoration:line-through; color:##999999;">#dollarFormat(rs.arrRegularNights[x])#</span></td>
    <td><span style="color:##990000; font-weight:bold;">#dollarFormat(rs.arrNights[x].rate)#</span></td>
	<td>#rs.arrNights[x].type#</td></tr>
	</cfloop>
	</table>
    <table style="border-spacing:5px; width:100%;">
      <tr>
        <td style="width:90px;">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <th colspan="2"><h2>Your Reservation Information</h2></th>
      </tr>
      <tr>
        <td colspan="2"><strong>Please note only the initial down payment will be charged to your credit card to reserve the cabin.<br />
          Refer to our <a href="/reservation-information-policies.html" target="_blank">cabin rental policies</a> for more information.</strong></td>
      </tr>
    </table>
    <table style="border-spacing:5px;">
      <tr>
        <td style="width:110px;">Start&nbsp;Date:</td>
        <td style="text-align:left;">#DateFormat(inquiries_start_date,'mmmm d, yyyy')#</td>
      </tr>
      <tr>
        <td style="width:120px;">End Date:</td>
        <td style="text-align:left;">#DateFormat(inquiries_end_date,'mmmm d, yyyy')#</td>
      </tr>
      <tr>
        <td style="width:120px;">## of Nights:</td>
        <td style="width:90px;" >#rs.nights#</td>
      </tr>
      <tr>
        <td style="width:120px;">Night&nbsp;Subtotal:</td>
        <td style="width:90px;" >#dollarformat(rs.inquiries_nights_total)#</td>
      </tr>
      <tr>
        <td style="width:1%;white-space:nowrap">## of guests:</td>
        <td style="width:90px;" >#rs.guests# (age 3+)</td>
      </tr>
	  <cfif inquiries_children_age NEQ ''>
      <tr>
        <td>&nbsp;</td>
        <td style="width:90px;" >#inquiries_children_age# (under age 3)</td>
      </tr>
	  </cfif>
	  <cfif zso(form, 'inquiries_pets',true) NEQ '0'>
      <tr>
        <td style="width:120px;">## of pets:</td>
        <td style="width:90px;" >#inquiries_pets#</td>
      </tr>
      <tr>
        <td style="width:120px;">Pet Fees:</td>
        <td style="width:90px;" >#dollarformat(rs.inquiries_pet_total_fee)#</td>
      </tr>
	  </cfif>
      <tr>
        <td style="width:120px;">cleaning fee:</td>
        <td style="text-align:left;">#DollarFormat(rs.inquiries_cleaning)# <!--- (not taxed) ---></td>
      </tr>
	  <cfif rs.inquiries_addl_guest NEQ 0>
          <tr>
            <td colspan = "2" style="border-top:1px solid ##999999;">Fees for #rs.inquiries_addl_guest# additional guests:</td>
          </tr>
          <tr>
            <td style="<cfif rs.inquiries_addl_cleaning EQ 0>border-bottom:1px solid ##999999;</cfif> width:120px;">additional rental:</td>
            <td <cfif rs.inquiries_addl_cleaning EQ 0>style="border-bottom:1px solid ##999999;"</cfif>>#DollarFormat(rs.inquiries_addl_rate)#</td>
          </tr>
		</cfif>
          <cfif rs.inquiries_addl_cleaning NEQ 0>
         <tr>
            <td style="width:120px;border-bottom:1px solid ##999999;">additional cleaning:</td>
            <td style="border-bottom:1px solid ##999999;">#DollarFormat(rs.inquiries_addl_cleaning)# <!--- (not taxed) ---></td>
          </tr>
          </cfif>
	  <cfif rs.inquiries_discount NEQ 0>
      <tr>
        <td style="width:120px;">Discount Applied:</td>
        <td>-#DollarFormat(rs.inquiries_discount)# #rs.inquiries_discount_desc# </td>
      </tr>
	  </cfif>
      <tr>
        <td style="width:120px;">Subtotal:</td>
        <td style="width:120px;"><span id="totalBeforeTax">#DollarFormat(rs.inquiries_subtotal)#</span></td>
      </tr>
      <tr>
        <td style="width:120px;">Tax: (#tax * 100#%)</td>
        <td style="width:120px;"><div id="thetax">#DollarFormat(rs.inquiries_tax)#</div></td>
      </tr>
      </tr>
      <tr>
        <td style="width:120px;font-weight:bold; font-size:14px;">Total:</td>
        <td style="font-weight:bold; font-size:14px;"><span id="thetotal">#DollarFormat(rs.inquiries_total)#</span></td>
      </tr>
      <tr>
        <td colspan="2" style="font-weight:bold; font-size:18px; line-height:24px; color:##FF0000;"><span id="totalsavings"><span style="font-size:14px;">After combining the savings with our new low rates and our current specials:</span><br />You save #DollarFormat(rs.inquiries_total_savings)# by booking online with us today.</span></td>
      </tr>
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
    </table>
    <table style="border-spacing:5px;">
      <tr>
        <th colspan="2"><h2>Deposit to Hold Reservation</h2></th>
      </tr>
      <tr>
        <td colspan="2"><strong style="font-size:14px;">#dollarformat(rs.inquiries_deposit)# will be billed to your credit card to reserve the cabin on the selected dates and will be applied as a down payment to your total cost of stay.</strong></td>
      </tr>
    </table>
  </cfif>
  <cfif (structkeyexists(form, 'action') EQ false or form.action EQ 'form')>
  <form class="zFormCheckDirty" name="myForm" id="myForm" target="_top" action="/z/_a/rental/reserve?action=send<cfif structkeyexists(form, 'secure')>&secure=1</cfif><cfif structkeyexists(form, 'reserve')>&reserve=1</cfif>" method="post" enctype="multipart/form-data">
  	#application.zcore.functions.zFakeFormFields()#
  <table style="border-spacing:5px;">
    <cfif structkeyexists(form, 'reserve') EQ false>
      <tr>
        <td>Select Cabin</td>
        <td><cfsavecontent variable="db.sql">
			SELECT * FROM rental WHERE rental_active=#db.param(1)# and 
			rental_id <> #db.param('7')# and 
			rental_deleted = #db.param(0)#
          ORDER BY rental_name ASC
          </cfsavecontent><cfscript>qProperties=db.execute("qProperties");
if(structkeyexists(form, 'rental_id')){
	rental_id = form.rental_id;
}else if(isDefined('request.rental_id')){
	rental_id = request.rental_id;
}
selectStruct = StructNew();
selectStruct.name = "rental_id";
selectStruct.query = qProperties;
selectStruct.queryLabelField = "rental_name";
selectStruct.queryValueField = "rental_id";
application.zcore.functions.zInputSelectBox(selectStruct);
</cfscript></td>
      </tr>
      <cfelse>
      <input type="hidden" name="rental_id" value="#rental_id#" />
	  <cfif isDefined('inquiries_pets') and (rental_id EQ '26' or rental_id EQ '47' or rental_id EQ 52)>
      <input type="hidden" name="inquiries_pets" value="#inquiries_pets#" />
	  </cfif>
      <input type="hidden" name="inquiries_start_date" value="#dateformat(inquiries_start_date,'yyyy-mm-dd')#" />
      <input type="hidden" name="inquiries_end_date" value="#dateformat(inquiries_end_date,'yyyy-mm-dd')#" />
      <input type="hidden" name="inquiries_adults" value= "#inquiries_adults#"> 
	  <input type="hidden" name="inquiries_children" value= "#inquiries_children#">
      <input type="hidden" name="inquiries_children_age" value= "#inquiries_children_age#">
      <input type="hidden" name="inquiries_coupon_code" value= "#zso(form, 'inquiries_coupon_code')#">
    </cfif>
  <script language="javascript">
function updateOffset(val,type){
	setDateOffset("myForm","inquiries_start_date","inquiries_end_date", "day",1);
	<!--- <cfif structkeyexists(form, 'reserve')>
	calculateCost();
	</cfif> --->
}
function updateOffset2(){
	<!--- <cfif structkeyexists(form, 'reserve')>
	calculateCost();
	</cfif> --->
}
</script>
    <cfif structkeyexists(form, 'reserve') EQ false>
      <tr>
        <td>Check-In Date:</td>
        <td><cfscript>
		/*
		if(application.zcore.functions.zso(form, 'inquiries_start_date') EQ ''){
			form.inquiries_start_date = application.zcore.functions.zGetDateSelect("inquiries_start_date");
			if(form.inquiries_start_date EQ false){
				form.inquiries_start_date = dateFormat(dateadd("d",1,now()), "yyyy-mm-dd");
			}
		}*/
		firstYear = dateFormat(now(), "yyyy");
		</cfscript>
          #application.zcore.functions.zDateSelect("inquiries_start_date","inquiries_start_date", firstYear, firstYear+3, "updateOffset")#</td>
      </tr>
      <tr>
        <td>Check-Out Date:</td>
        <td><cfscript>	
		/*	
		if(application.zcore.functions.zso(form, 'inquiries_end_date') EQ ''){
			inquiries_end_date = application.zcore.functions.zGetDateSelect("inquiries_end_date");
			if(inquiries_end_date EQ false){
				inquiries_end_date = dateFormat(dateadd("d",3,now()), "yyyy-mm-dd");
			}
		}*/
		</cfscript>
          #application.zcore.functions.zDateSelect("inquiries_end_date","inquiries_end_date", firstYear, firstYear+3, "updateOffset2")#</td>
      </tr>
      <cfelse>
      <tr>
        <td colspan="2"><h2>Your Contact &amp; Reservation Information</h2></td>
      </tr>
    </cfif>
    <tr>
      <td style="width:90px;">First Name:</td>
      <td><input name="inquiries_first_name" type="text" size="30" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_first_name')#">
        <span class="highlight">* Required</span></td>
    </tr>
    <tr>
      <td>Last Name:</td>
      <td><input name="inquiries_last_name" type="text" size="30" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_last_name')#"></td>
    </tr>
    <tr>
      <td>Company:</td>
      <td><input name="inquiries_company" type="text" size="30" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_company')#"></td>
    </tr>
    <tr>
      <td>Email:</td>
      <td><input name="inquiries_email" type="text" size="30" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_email')#">
        <span class="highlight">* Required</span></td>
    </tr>
    <tr>
      <td>Home Phone:</td>
      <td><input name="inquiries_phone1" type="text" size="30" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_phone1')#">
        <span class="highlight">* Required</span></td>
    </tr>
    <tr>
      <td>Work Phone:</td>
      <td><input name="inquiries_phone2" type="text" size="30" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_phone2')#">
        Ext.
        <input name="inquiries_phone2ext" type="text" size="5" maxlength="50" value="#application.zcore.functions.zso(form, 'inquiries_phone2ext')#"></td>
    </tr>
    <cfif isDefined('inquiries_adults') eq false>
      <tr>
        <td>Adults:</td>
        <td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_adults";
		selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript></td>
      </tr>
      <tr>
        <td>Children (3 and up):</td>
        <td><cfscript>
			selectStruct = StructNew();
			selectStruct.name = "inquiries_children";
			selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
			application.zcore.functions.zInputSelectBox(selectStruct);
		  </cfscript></td>
      </tr>
      <tr>
        <td style="vertical-align:top; ">Children (under age 3):</td>
        <td style="vertical-align:top; "><cfscript> 
selectStruct = StructNew(); 
	 selectStruct.name = "inquiries_children_age"; 
	selectStruct.listValues = "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
	 application.zcore.functions.zInputSelectBox(selectStruct); 
</cfscript>
          <br />
          <strong>Note:</strong>Children under age 3 are free.</td>
      </tr>
    </cfif>
    <tr>
      <td style="vertical-align:top; ">Comments:</td>
      <td><textarea name="inquiries_comments" cols="50" rows="5">#application.zcore.functions.zso(form, 'inquiries_comments')#</textarea>
        <input type="hidden" name="inquiries_type_id" value="1"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><input type="checkbox" name="inquiries_email_opt_in" value="1"   <cfif application.zcore.functions.zso(form, 'inquiries_email_opt_in') EQ 1>checked="checked"</cfif>>
        Yes! Send me periodic news and specials from kaylormtncabins.com.</td>
    </tr>
    <cfif structkeyexists(form, 'reserve')>
      <input type="hidden" name="inquiries_reservation" value="1" />
      <cfif structkeyexists(form, 'secure')>
        </table>
        <br />
        <table style="border-spacing:5px;">
          <tr>
            <th colspan="2"><h2>Billing Information</h2></th>
          </tr>
          <tr>
            <td class="table-highlight" style="width:120px;">Cardholder Name<span class="highlight">*</span></td>
            <td><input type="text" name="C_name" value="#zso(form, 'C_name')#"></td>
          </tr>
          <tr>
            <td class="table-highlight" style="width:120px;">Billing Address<span class="highlight">*</span></td>
            <td><input type="text" name="C_address" value="#zso(form, 'C_address')#"></td>
          </tr>
          <tr>
            <td class="table-highlight" style="width:120px;">Address 2</td>
            <td><input type="text" name="C_address2" value="#zso(form, 'C_address2')#"></td>
          </tr>
          <tr>
            <td class="table-highlight" style="width:120px;">City<span class="highlight">*</span></td>
            <td><input type="text" name="C_city" value="#zso(form, 'C_city')#"></td>
          </tr>
          <cfsavecontent variable="db.sql">
			SELECT * FROM state ORDER BY state_state ASC
          </cfsavecontent><cfscript>qState=db.execute("qState");</cfscript>
          <tr>
            <td class="table-highlight" style="width:120px;">US State</td>
            <td colspan="2"><cfscript>
		selectStruct = StructNew();
		selectStruct.name = "c_state";
		selectStruct.query = qState;
		selectStruct.queryLabelField = "state_state";
		selectStruct.queryValueField = "state_code";
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript></td>
          </tr>
          <tr>
            <td class="table-highlight" style="width:120px;">Zip<span class="highlight">*</span></td>
            <td><input type="text" name="C_zip" size="6" value="#zso(form, 'C_zip')#"></td>
            <td rowspan="4" style="text-align:left;"><img src="/images/cvv.gif" style="padding-left:5px; padding-right:5px;"><span class="highlight">What is a CVV code?</span><br />
              <br />
              <span class="tiny" style="line-height:normal; ">The CVV code is the last group of 3 or 4 digits found printed on the signature strip on the reverse (amex is on front) side of the card. On some cards, the complete credit card number is shown on the signature strip, followed by the CVV code.</span></td>
          </tr>
          <cfsavecontent variable="db.sql">
			SELECT * FROM country ORDER BY country_name ASC
          </cfsavecontent><cfscript>qcountry=db.execute("qcountry");</cfscript>
          <tr>
            <td class="table-highlight" style="width:120px;">Country</td>
            <td><cfscript>
		selectStruct = StructNew();
		selectStruct.name = "c_country";
		selectStruct.query = qcountry;
		selectStruct.queryLabelField = "country_name";
		selectStruct.queryValueField = "country_code";
		application.zcore.functions.zInputSelectBox(selectStruct);
		</cfscript></td>
          </tr>
          <tr>
            <td class="table-highlight" style="width:120px;">Credit Card Number<span class="highlight">*</span></td>
            <td><input type="text" name="C_cardnumber" value="#zso(form, 'C_cardnumber')#"></td>
          </tr>
          <tr>
            <td class="table-highlight" style="width:120px;">Security Code (CVV)<span class="highlight">*</span></td>
            <td><input type="text" name="C_cvv" value="#zso(form, 'C_cvv')#" size="5"></td>
          </tr>
          <tr>
            <td class="table-highlight" style="width:120px;">Card Exp. Date<span class="highlight">*</span></td>
            <td style="white-space:nowrap;">Month
              <select size="1" name="Month">
                <option <cfif zso(form, 'Month') EQ "01">selected="selected"</cfif>>01</option>
                <option <cfif zso(form, 'Month') EQ "02">selected="selected"</cfif>>02</option>
                <option <cfif zso(form, 'Month') EQ "03">selected="selected"</cfif>>03</option>
                <option <cfif zso(form, 'Month') EQ "04">selected="selected"</cfif>>04</option>
                <option <cfif zso(form, 'Month') EQ "05">selected="selected"</cfif>>05</option>
                <option <cfif zso(form, 'Month') EQ "06">selected="selected"</cfif>>06</option>
                <option <cfif zso(form, 'Month') EQ "07">selected="selected"</cfif>>07</option>
                <option <cfif zso(form, 'Month') EQ "08">selected="selected"</cfif>>08</option>
                <option <cfif zso(form, 'Month') EQ "09">selected="selected"</cfif>>09</option>
                <option <cfif zso(form, 'Month') EQ "10">selected="selected"</cfif>>10</option>
                <option <cfif zso(form, 'Month') EQ "11">selected="selected"</cfif>>11</option>
                <option <cfif zso(form, 'Month') EQ "12">selected="selected"</cfif>>12</option>
              </select>
              Year
              <select size="1" name="Year">
                <cfset currentYear = year(now())>
                <cfloop from="#currentYear#" to="#currentYear+6#" step="1" index="i">
                  <option value="#right(i,2)#" <cfif zso(form, 'Year') EQ i>selected="selected"</cfif>>#i#</option>
                </cfloop>
              </select></td>
          </tr>
        </table>
        <table style="border-spacing:5px;">
      </cfif>
      <cfelse>
      <input type="hidden" name="inquiries_reservation" value="0" checked="checked" />
    </cfif>
    <script>
	<cfif structkeyexists(form, 'secure') and DateCompare(inquiries_end_date,now()) EQ 1>
	//calculateCost();
	<cfelseif application.zcore.functions.zso(form, 'inquiries_end_date') EQ ''>
	updateOffset();
	</cfif>
	</script>
    <cfif structkeyexists(form, 'secure')>
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2" style="border:1px solid ##990000; background-color:##FFFFFF;"><h2>TERMS</h2>
          By submitting this form, we will charge the #dollarformat(rs.inquiries_deposit)# down payment to your credit card to reserve this cabin rental for the selected dates.  You agree to pay the "Total" listed above at time of check-in.  You will receive a confirmation email at the address you provide and a Reservation Confirmation Number if your credit card is approved.  If you are having trouble submitting your reservation, please call us<br />
          <br />
          You can review our complete reservation policies by <a href="##NEEDLINKHERE">clicking here</a><br />
          <br />
          <input type="checkbox" name="agreeToCharge" value="1" <cfif isDefined('agreetocharge')>checked="checked"</cfif> />
          <strong>Check this box to agree to our reservation policy and the terms listed above.</strong></td>
      </tr>
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
    </cfif>
    <tr>
      <cfif structkeyexists(form, 'reserve')>
        <td>&nbsp;</td>
        <td><button type="submit" name="submit">
          <cfif structkeyexists(form, 'secure')>
Submit Reservation Via Secure Server
            <cfelse>
            Make Reservation
          </cfif>
          </button>&nbsp;&nbsp;
          <br />
          <br /></td>
        <cfelse>
        <td>&nbsp;</td>
        <td><button type="submit" name="submit">Send Inquiry</button>&nbsp;&nbsp;</td>
      </cfif>
    </tr>
    <tr>
      <td colspan="2"><cfif structkeyexists(form, 'secure') EQ false and structkeyexists(form, 'reserve')>
          <strong>Note:</strong>We will contact you later to collect the security deposit and confirm your reservation.  Your reservation is not guaranteed until you pay the security deposit and receive our confirmation.<br />
          <br />
        </cfif>
        <cfif structkeyexists(form, 'secure')>
          <strong>All billing information is sent via our secure server</strong>.<br />
          <br />
        </cfif></td>
    </tr>
  </table>
  </form>
  </cfif>
 --->
</cfoutput>
</cfcomponent>