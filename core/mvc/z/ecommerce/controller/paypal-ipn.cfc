<cfcomponent>
<cfoutput>
<!--- 
To debug a specific ipn message, you can add the value of paypal_ipn_log_data in the database and &test_ipn=1 to the end of this url when you are logged in to the site as a developer.  Be sure to visit this url on the site, and not the server manager!

/z/ecommerce/paypal-ipn/index
 --->

<cffunction name="setDebugData" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	arguments.struct.option_selection1="One time payment";
	arguments.struct.ipn_track_id="576f2e315ffd1";
	arguments.struct.charset="windows-1252";
	arguments.struct.receiver_id="DPCMATR4C2RE4";
	arguments.struct.protection_eligibility="Ineligible";
	arguments.struct.resend="true";
	arguments.struct.payment_type="instant";
	arguments.struct.payment_status="Completed";
	arguments.struct.shipping="0.00";
	arguments.struct.payer_status="verified";
	arguments.struct.tax="0.00";
	arguments.struct.payment_gross="150.00";
	arguments.struct.handling_amount="0.00";
	arguments.struct.receiver_email="receiver@yourcompany.com";
	arguments.struct.first_name="First";
	arguments.struct.last_name="Last";
	arguments.struct.item_number="";
	arguments.struct.verify_sign="Ai1PaghZh5FmBLCDCTQpwG8jB264AdJXSW248UAUciEPzCLnAhBdy4G.";
	arguments.struct.quantity="1";
	arguments.struct.residence_country="US";
	arguments.struct.custom="";
	arguments.struct.payment_date="09:01:26 Jul 21, 2014 PDT";
	arguments.struct.payer_email="client@email.com";
	arguments.struct.payer_id="RY9Q8EYMZXGSQ";
	arguments.struct.payment_fee="4.65";
	arguments.struct.notify_version="3.8";
	arguments.struct.txn_type="web_accept";
	arguments.struct.mc_currency="USD";
	arguments.struct.payer_business_name="Client";
	arguments.struct.txn_id="0WF11855YK1274414";
	arguments.struct.option_name1="Payment Option";
	arguments.struct.invoice="1146";
	arguments.struct.mc_fee="4.65";
	arguments.struct.mc_gross="150.00";
	arguments.struct.item_name="Invoice ##1";
	arguments.struct.transaction_subject="";
	arguments.struct.business=request.zos.paypalSandboxMerchantID;
	</cfscript>
</cffunction>

<cffunction name="verifyIPN" localmode="modern" access="public" returntype="struct">
	<cfargument name="struct" type="struct" required="yes">
	<cfargument name="sandboxEnabled" type="boolean" required="yes">
	<cfscript>
	ss=arguments.struct;
	postURL="https://www.paypal.com/cgi-bin/webscr";
	if(arguments.sandboxEnabled){
		postURL="https://www.sandbox.paypal.com/cgi-bin/webscr";
	} 

	if(cgi.http_user_agent CONTAINS 'paypal'){
		arrField=listToArray(application.zcore.functions.zso(form, 'fieldnames'), ",");
		arrForm=[];
		for(i=1;i<=arraylen(arrField);i++){
			f=arrField[i];
			if(f EQ "fieldnames" or f EQ "zdebugurl" or f EQ "zdebug1" or f EQ request.zos.urlRoutingParameter or not structkeyexists(ss, f)){
				continue;
			}
			arrayAppend(arrForm, { key:f, val:ss[f]});
		}
	}else{
		return { postedData:"", errorMessage:"Failed to verify IPN due to HTTP user agent not being paypal: #cgi.http_user_agent#", success:false}; 
	} 
	arrForm2=[];

	http url="#postURL#" charset="#ss.charset#" port="443" method="POST" throwonerror="no" timeout="30"{
		httpparam type="formfield" name="cmd" encoded="yes" value="_notify-validate";
		for(i=1;i<=arraylen(arrForm);i++){
			s=arrForm[i];
			arrayAppend(arrForm2, s.key&"="&urlencodedformat(s.val));
			httpparam type="formfield" name="#lcase(s.key)#" encoded="yes" value="#s.val#";
		}
	}
	//writedump(form);writedump(cfhttp);abort;
	if(left(CFHTTP.statusCode,3) NEQ '200'){
		// failed.
		return { postedData:arraytolist(arrForm2, "&"), errorMessage:"Failed to verify IPN due to HTTP failure: "&cfhttp.statusCode, success:false};
	}else{
		if(trim(cfhttp.FileContent) EQ "VERIFIED"){
			return { postedData:arraytolist(arrForm2, "&"), errorMessage:"", success:true};
		}else{
			if(structkeyexists(ss, 'for_auction') and ss.for_auction EQ true){
				return { postedData:arraytolist(arrForm2, "&"), errorMessage:"Ignoring auction ipn errors on purpose now.", success:true};
			}else{
				return { postedData:arraytolist(arrForm2, "&"), errorMessage:"Failed to verify IPN with result being: #cfhttp.FileContent#", success:false};
			}
		}
	} 
	</cfscript>
</cffunction>

<cffunction name="index" access="remote" localmode="modern"> 
<cfscript>
db=request.zos.queryObject;
// /z/ecommerce/paypal-ipn/index?debug1=1
debug=false;
if(structkeyexists(form, 'debug1')){ 
	debug=true; 
	form.option_selection1="One time payment";
	form.ipn_track_id="576f2e315ffd1";
	form.charset="windows-1252";
	form.receiver_id="DPCMATR4C2RE4";
	form.protection_eligibility="Ineligible";
	form.resend="true";
	form.payment_type="instant";
	form.payment_status="Completed";
	form.shipping="0.00";
	form.payer_status="verified";
	form.tax="0.00";
	form.payment_gross="150.00";
	form.handling_amount="0.00";
	form.receiver_email="my@business.com";
	form.first_name="First";
	form.last_name="Last";
	form.item_number="";
	form.verify_sign="Ai1PaghZh5FmBLCDCTQpwG8jB264AdJXSW248UAUciEPzCLnAhBdy4G.";
	form.quantity="1";
	form.residence_country="US";
	form.custom="";
	form.payment_date="09:01:26 Jul 21, 2014 PDT";
	form.payer_email="test@test.com";
	form.payer_id="RY9Q8EYMZXGSQ";
	form.payment_fee="4.65";
	form.notify_version="3.8";
	form.txn_type="web_accept";
	form.mc_currency="USD";
	form.payer_business_name="Business";
	form.txn_id="0WF11855YK1274414";
	form.option_name1="Payment Option";
	form.invoice="7-1-1";
	form.mc_fee="4.65";
	form.mc_gross="150.00";
	form.item_name="Test Invoice";
	form.transaction_subject="";
	form.business="my@business.com"; 
}
form.txn_type=application.zcore.functions.zso(form, 'txn_type');
/*
if(form.txn_type EQ ""){
	application.zcore.functions.z404("Invalid Request");
}*/

testMode=false;
if(application.zcore.functions.zso(form, 'test_ipn',false,0) EQ 1){
	// force test if paypal post is a test.
	testMode=true;	
}
postURL="https://www.paypal.com/cgi-bin/webscr";
if(testMode){
	postURL="https://www.sandbox.paypal.com/cgi-bin/webscr";
}

// force off test mode so I can test database updates.
//testMode=false;

arrFieldOrder=structkeyarray(form);

statusMessage="";
failedIpn=false;  
form.charset=application.zcore.functions.zso(form, 'charset', false, 'utf-8');

if(debug or structkeyexists(form, 'test_ipn')){

	failedIpn=false; 

	// uncomment to test failure:
	//failedIpn=true; 
	arrForm=[];
	for(i in form){
		arrayAppend(arrForm, i&'='&urlencodedformat(form[i]));
	}
	postedData=arrayToList(arrForm, '&');
}else{
	rs=verifyIPN(form, testMode);
	if(not rs.success){
		failedIpn=true;
		statusMessage=rs.errorMessage;
	}
	postedData=rs.postedData;
} 
ts=structnew();
ts.datasource=request.zos.zcoreDatasource;
ts.table="paypal_ipn_log";
ts.struct=structnew();
ts.struct.paypal_ipn_log_invoice=application.zcore.functions.zso(form, 'invoice');
if(failedIpn){
	ts.struct.paypal_ipn_log_verified=0;
}else{
	ts.struct.paypal_ipn_log_verified=1;
}
ts.struct.paypal_ipn_log_deleted=0;
ts.struct.paypal_ipn_log_updated_datetime=dateformat(now(),"yyyy-mm-dd")&" "&timeformat(now(),"HH:mm:ss");
ts.struct.paypal_ipn_log_datetime=dateformat(now(),"yyyy-mm-dd")&" "&timeformat(now(),"HH:mm:ss");
ts.struct.paypal_ipn_log_data=postedData;
paypal_ipn_log_id=application.zcore.functions.zInsert(ts);
ts.struct.struct=form;
ts.struct.paypal_ipn_log_id=paypal_ipn_log_id;

form.invoice=application.zcore.functions.zso(form, 'invoice');
if(form.invoice CONTAINS "-"){
	form.appId=listgetat(form.invoice,1,"-");	
	form.invoice=listgetat(form.invoice,2,"-");
}else{
	form.appId="0";	
}
if(failedIpn){ 
	mail spoolenable="no"  to="#request.zos.developerEmailTo#" from="#request.zos.developerEmailFrom#" subject="Paypal IPN Alert on #request.zos.globals.domain# Invoice ###form.invoice#" type="html" charset="windows-1252"{
		echo('<!DOCTYPE html><html><head><title>Error</title></head><body>
	There was a failed IPN on #request.zos.globals.domain#<br>
	 <a href="#request.zos.globals.domain#/z/ecommerce/paypal-ipn/view?paypal_ipn_log_id=#paypal_ipn_log_id#">View Error</a><br><br>
	Error Message: #statusMessage#
	</body></html>'); 
	} 
	abort;
} 
if(request.zos.isdeveloper){
	writedump(ts.struct);
}
customAppID=application.zcore.app.getAppData("ecommerce").optionStruct.ecommerce_config_paypal_custom_ipn_url_id;
if(customAppID EQ form.appId){
	if(customAppID NEQ 0){
		if(structkeyexists(application.siteStruct[request.zos.globals.id].zcoreCustomFunctions, 'processPaypalIPN')){ 
			result=application.siteStruct[request.zos.globals.id].zcoreCustomFunctions.processPaypalIPN(ts.struct);
			if(result){
				processed=1;
			}else{
				processed=0;
			}
			db.sql="update #db.table("paypal_ipn_log", request.zos.zcoreDatasource)# SET 
			paypal_ipn_log_processed=#db.param(processed)#, 
			paypal_ipn_log_updated_datetime=#db.param(dateformat(now(),"yyyy-mm-dd")&" "&timeformat(now(),"HH:mm:ss"))# 
			WHERE 
			paypal_ipn_log_id=#db.param(paypal_ipn_log_id)# and 
			paypal_ipn_log_deleted=#db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)#";
			db.execute("qUpdate");
		}
	}
}else{
	// TODO: process ipn via ecommerce function
	result=true;
	if(result){
		processed=1;
	}else{
		processed=0;
	}
	db.sql="update #db.table("paypal_ipn_log", request.zos.zcoreDatasource)# SET 
	paypal_ipn_log_processed=#db.param(processed)#, 
	paypal_ipn_log_updated_datetime=#db.param(dateformat(now(),"yyyy-mm-dd")&" "&timeformat(now(),"HH:mm:ss"))# 
	WHERE 
	paypal_ipn_log_id=#db.param(paypal_ipn_log_id)# and 
	paypal_ipn_log_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	db.execute("qUpdate");
} 
/* 
txn_type 
	"subscr_signup" This Instant Payment Notification is for a subscription sign-up. 
	"subscr_cancel" This Instant Payment Notification is for a subscription cancellation. 
	"subscr_modify" This Instant Payment Notification is for a subscription modification. 
	"subscr_failed" This Instant Payment Notification is for a subscription payment failure. 
	"subscr_payment" This Instant Payment Notification is for a subscription payment. 
	"subscr_eot" This Instant Payment Notification is for a subscription's end of term.  
	"web_accept" non subscription payment 
*/ 
echo('IPN Processed');
abort;
</cfscript>
</cffunction>



<cffunction name="view" access="remote" localmode="modern" roles="serveradministrator">
	<cfscript>
	form.paypal_ipn_log_id=application.zcore.functions.zso(form, 'paypal_ipn_log_id');
	db=request.zos.queryObject;
	db.sql="select * from #db.table("paypal_ipn_log", request.zos.zcoreDatasource)# WHERE 
	paypal_ipn_log_id=#db.param(form.paypal_ipn_log_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	paypal_ipn_log_deleted=#db.param(0)# ";
	qIpn=db.execute("qIpn");
	echo('<h2>View IPN</h2>');
	for(row in qIpn){
		echo('<table class="table-list">');
		for(i in row){
			if(i EQ "paypal_ipn_log_data"){
				echo('<tr><th>'&i&'</th><td>'&replace(row[i], chr(10), "<br />", "all")&'</td></tr>');
			}else{
				echo('<tr><th>'&i&'</th><td>'&row[i]&'</td></tr>');
			}
		}
		echo('</table>');

		echo('<h2><a href="#request.zos.globals.domain#/z/ecommerce/paypal-ipn/index?#replace(row.paypal_ipn_log_data, chr(10), '&', 'all')#">Retry Processing of this IPN</a>');
		if(request.zos.istestserver){
			echo('<h2><a href="https://www.sandbox.paypal.com/us/cgi-bin/webscr?cmd=%5fdisplay%2dipns%2dhistory&nav=0%2e3%2e5">Visit paypal ipn history</a></h2>');
		}else{
			echo('<h2><a href="https://www.paypal.com/us/cgi-bin/webscr?cmd=%5fdisplay%2dipns%2dhistory&nav=0%2e3%2e5">Visit paypal ipn history</a></h2>');
		}
	}
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>