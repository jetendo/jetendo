<cfcomponent>
<cfoutput>

<!--- 
 

ts={
	arrAmount:[
		// one time payment example
		{
			amount:2,
			label: "One Time Payment"
		},
		// subscription payment example
		{
			amount:2,
			label="Subscription Payment",
			frequency: 1, // ommitting this field or setting it to 0 disables the subscription feature for this payment option, 1 will collect a payment each subscriptionPeriod, 2+ will skip subscriptionPeriods (i.e. 2 is bimonthly, 3 is trimonthly etc)
			period: 'M', // M = month | Y = year | D = day,
		},
		// product purchase example
		{
			amount:30,
			label: "Product Purchase", 
			taxRate:6,
			shipping:10
		}
	],
	arrItem:[
		{
			name:'Product/Service',
			amount:2
		}
	],
	selectMessage: "Select Payment Option and Click Buy Now",
	buttonImage: "Buy now", // Must be "Buy now", "Checkout", "Donate" or "Custom"
	// buttonImageURL: "", // only used when buttonImage is "Custom"
	subscriptionPaymentLimit: 0, // 0 is unlimited, Otherwise you can set this between 2 and 52
	subscriptionRetry: true, // true will retry 2 times before cancelling subscription.
	subscriptionModifyEnabled: false, // true will allow the customer to change subscription - not recommended in most cases
	subscriptionTrialEnabled: false, // true will allow a different price or $0 price at the beginning of the subscription
	// subscriptionTrialPeriod: 'M', // M = month | Y = year | D = day | When subscriptionTrialEnabled is true, this value determine the length of the trial.
	// subscriptionTrialAmount: 0, // When subscriptionTrialEnabled is true, this value determine the price of the trial.  The price can be 0 or more.
	sandbox:false, // requires paypal developer sandbox account for "business" field if set to true
	business: "", // paypal merchant id (recommended) or paypal email address
	// invoice: 1, // must be unique on each transaction or don't specify one
	hideLabel: false,
	ipnURL: request.zos.currentHostName&"/z/misc/paypal/ipn", // It is better if this URL uses SSL
	returnURL: request.zos.currentHostName&"/z/misc/paypal/thank-you", // Note: The user is not sent to this URL automatically. They have to click a button after paying.
	returnLabel: "Continue shopping", // after payment, there is a button that will go to the return URL, this field changes the text on that button
	disableNote: true, // Set to false to allow the customer to enter notes in a comments field that is sent along with their payment.
	disableShipping: true, // Set to false to enable paypal's shipping features
	bottomMessage: "No PayPal account is required"
};
application.zcore.paypal.displayButton(ts);
 --->
<cffunction name="displayButton" localmode="modern" access="public">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
	ts={
		buttonImage: "Buy now",
		// buttonImageURL: "",
		subscriptionPaymentLimit: 0,
		subscriptionRetry: true,
		subscriptionModifyEnabled: false,
		subscriptionTrialEnabled: false,
		// subscriptionTrialPeriod: 'M', 
		// subscriptionTrialAmount: 0,
		sandbox:false,
		business: "",
		hideLabel: false,
		ipnURL: request.zos.currentHostName&"/z/misc/paypal/ipn", 
		returnURL: request.zos.currentHostName&"/z/misc/paypal/thank-you",
		returnLabel: "Continue shopping", 
		selectMessage: "Select Payment Option and Click Buy Now",
		disableNote: true,
		disableShipping: true,
		bottomMessage: "No PayPal account is required"
	};
	ss=arguments.struct;
	structappend(ss, ts, false);
	if(not structkeyexists(ss, 'business')){
		throw("arguments.struct.business is required");
	}
	if(not structkeyexists(ss, 'arrAmount') or arraylen(ss.arrAmount) EQ 0){
		throw("arguments.struct.arrAmount is required");
	}
	if(not structkeyexists(ss, 'hideLabel')){
		ss.hideLabel=false;
	}
	if(ss.hideLabel and arraylen(ss.arrAmount) NEQ 1){
		throw("arguments.ss.arrAmount must have only 1 amount struct in the array when arguments.struct.hideLabel is true.");
	}
	if(structkeyexists(ss, 'buttonImage')){
		if(ss.buttonImage EQ "Buy now"){
			image='https://www.paypal.com/en_US/i/btn/btn_buynowCC_LG.gif';
		}else if(ss.buttonImage EQ "Checkout"){
			image='https://www.paypal.com/en_US/i/btn/btn_xpressCheckout.gif';
		}else if(ss.buttonImage EQ "Donate"){
			image='https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif';
		}else if(ss.buttonImage EQ "Custom"){
			if(not structkeyexists(ss, 'buttonImageURL')){
				throw("arguments.struct.buttonImageURL is required when arguments.buttonImage is Custom");
			}
			image=ss.buttonImageURL;
		}else{
			throw('arguments.struct.buttonImage must be "Buy now", "Checkout", "Donate" or "Custom"');
		}
	}else{
		image='https://www.paypal.com/en_US/i/btn/btn_buynowCC_LG.gif';
	}
	subscriptionEnabled=false;
	arrHidden=[];
	arrSelect=[];
	selectHidden='';
	for(i=1;i LTE arraylen(ss.arrAmount);i++){
		c=ss.arrAmount[i];
		if(structkeyexists(c, 'period')){
			if(c.period NEQ "M" and c.period NEQ "Y" and c.period NEQ "D"){
				throw("period must be M, Y, or D");
			}
			subscriptionEnabled=true; 
		}else{
			c.period='M';
		}
		if(not structkeyexists(c, 'frequency')){
			c.frequency=1;
		}
		if(not isnumeric(c.frequency)){
			throw("frequency must be an integer 0 or higher.");
		}
		if(not ss.hideLabel and not structkeyexists(c, 'label')){
			throw("Each arrAmount struct must have a label if arguments.struct.hideLabel is false.");
		}
		arrayAppend(arrHidden, '<input type="hidden" name="option_select#i-1#" value="#htmleditformat(c.label)#">
		<input type="hidden" name="option_amount#i-1#" value="#c.amount#">
		<input type="hidden" name="option_period#i-1#" value="#c.period#">
		<input type="hidden" name="option_frequency#i-1#" value="#c.frequency#">');
		if(ss.hideLabel){
			selectHidden='<input type="hidden" name="os0" value="#htmleditformat(c.label)#" />';
		}else{
			arrayAppend(arrSelect, '<option value="#htmleditformat(c.label)#">#htmleditformat(c.label)#</option>');
		}
	} 
	sandboxEnabled=false;
	if(request.zOS.thisIsTestServer or ss.sandbox){
		sandboxEnabled=true;	
	}
	paypalUrl="https://www.paypal.com/cgi-bin/webscr";
	if(sandboxEnabled){
		if(not structkeyexists(request.zos, 'paypalSandboxMerchantID') or request.zos.paypalSandboxMerchantID EQ ""){
			throw("request.zos.paypalSandboxMerchantID is required to be setup in config.cfc when sandbox is true");
		}
		ss.business=request.zos.paypalSandboxMerchantID;
		paypalUrl="https://www.sandbox.paypal.com/cgi-bin/webscr";
	}
	</cfscript> 
	<form name="paypalForm" action="#paypalUrl#" method="post" style="margin:0px; padding:0px;">
		<cfif subscriptionEnabled>
			<input type="hidden" name="cmd" id="paypal_cmd" value="_xclick-subscriptions" /><!--- subscriptions checkout --->
		<cfelse>
			<input type="hidden" name="cmd" id="paypal_cmd" value="_xclick" /><!--- regular checkout --->
		</cfif>
		<cfif sandboxEnabled>
			<input type="hidden" name="business" value="#htmleditformat(request.zos.paypalSandboxMerchantID)#" />
		
		<cfelse>
			<input type="hidden" name="business" value="#ss.business#" /><!--- merchant id --->
		</cfif>
		<input type="hidden" name="lc" value="US" /><!--- language --->
		<cfif structkeyexists(ss, 'invoice')>
	
			<input type="hidden" name="invoice" value="#htmleditformat(ss.invoice)#" /><!--- invoice_id number --->
		</cfif>

		<cfscript>
		if(arraylen(ss.arrItem) EQ 0){
			throw("arguments.struct.arrItem is required");
		}
		if(arraylen(ss.arrItem) EQ 1){
			echo('<input type="hidden" name="item_name" value="#htmleditformat(ss.arrItem[1].name)#" />');
			if(structkeyexists(ss.arrItem[1], 'number')){
				echo('<input type="hidden" name="item_number" value="#htmleditformat(ss.arrItem[1].number)#" />');
			}
		}else{
			for(i=1;i LTE arraylen(ss.arrItem);i++){
				echo('<input type="hidden" name="item_name_#i#" value="#htmleditformat(ss.arrItem[i].name)#" />
				<input type="hidden" name="amount_#i#" value="#htmleditformat(ss.arrItem[i].amount)#" />');
				if(structkeyexists(ss.arrItem[i], 'number')){
					echo('<input type="hidden" name="item_number" value="#htmleditformat(ss.arrItem[i].number)#" />');
				}
			}
		}
		</cfscript>

		<input type="hidden" name="modify" value="<cfif ss.subscriptionModifyEnabled>1<cfelse>0</cfif>" /><!--- prevent users from modifying subscriptions ---> 
		<cfif ss.disableNote>
			<input type="hidden" name="no_note" value="1" /><!--- disable notes --->
		</cfif>
		<cfif ss.disableShipping>
			<input type="hidden" name="no_shipping" value="1" /><!--- disable shipping --->
		</cfif>
		
		<cfscript>
		if(ss.subscriptionTrialEnabled){
			if(not structkeyexists(ss, 'subscriptionTrialPeriod')){
				throw("arguments.struct.subscriptionTrialPeriod is required when arguments.struct.subscriptionTrialEnabled is true");
			}
			if(not structkeyexists(ss, 'subscriptionTrialAmount')){
				throw("arguments.struct.subscriptionTrialAmount is required when arguments.struct.subscriptionTrialEnabled is true");
			}
			if(not structkeyexists(ss, 'subscriptionTrialLength')){
				throw("arguments.struct.subscriptionTrialLength is required when arguments.struct.subscriptionTrialEnabled is true");
			}
			echo('<input type="hidden" name="a1" value="#ss.subscriptionTrialAmount#" />
			<input type="hidden" name="p1" value="#ss.subscriptionTrialLength#" />
			<input type="hidden" name="t1" value="#ss.subscriptionTrialPeriod#" />');
		}
		if(structkeyexists(ss, 'subscriptionPaymentLimit') and ss.subscriptionPaymentLimit NEQ 0){
			if(ss.subscriptionPaymentLimit GTE 2 and ss.subscriptionPaymentLimit LTE 52){
				echo('<input type="hidden" name="srt" id="paypal_srt" value="#ss.subscriptionPaymentLimit#" />');
			}else{
				throw("arguments.struct.subscriptionPaymentLimit must be between 2 and 52");
			}
		}
		</cfscript>
		<input type="hidden" name="src" id="paypal_src" value="1" /><!--- 1 for recurring, 0 for not recurring --->
		<cfif ss.subscriptionPaymentLimit NEQ 0>
		<input type="hidden" name="srt" id="paypal_srt" value="#ss.subscriptionPaymentLimit#" /><!--- limit recurring billing cycles --->
		</cfif>
		<cfif ss.subscriptionRetry>
			<input type="hidden" name="sra" value="1" /><!--- reattempt failed subscription payment --->
		</cfif>
		<input type="hidden" name="currency_code" value="USD" />
		<input type="hidden" name="bn" value="PP-SubscriptionsBF:btn_buynowCC_LG.gif:NonHosted" />
		<input type="hidden" name="notify_url" value="#htmleditformat(ss.ipnURL)#" />
		<input type="hidden" name="return" id="paypal_return_url" value="#htmleditformat(ss.returnURL)#" />
		<input type="hidden" name="rm" value="2" />
		<input type="hidden" name="cbt" value="#htmleditformat(ss.returnLabel)#" />	 
		
		<input type="hidden" name="option_index" value="0" /> 
		
		<div class="zPaypalButton">
			<cfif selectHidden NEQ "">
				#selectHidden#
			<cfelse>
				<div class="zPaypalSelectMessage"><input type="hidden" name="on0" value="Payment Option">#ss.selectMessage#</div>
				<div class="zPaypalSelect">
					<select name="os0" id="paypal_optionselect" onChange="updatePaypalForm(this);" size="1">
						#arrayToList(arrSelect, chr(10))#
					</select>
				</div>
			</cfif>
			<div class="zPaypalImageDiv">
				<input type="image" src="#image#" name="submit" alt="PayPal - The safer, easier way to pay online!" />
		   	</div>
		   	<cfif ss.bottomMessage NEQ "">
				<div class="zPaypalBottomMessage">#ss.bottomMessage#</div>
			</cfif>
		</div>
	</form>
</cffunction>



<cffunction name="redirectToPaypalNVPExpressCheckout" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	rs=callPaypalNVPAPI(arguments.ss);
	paypalUrl="https://api-3t.paypal.com/nvp";
	if(request.paypalTestMode){
		paypalUrl="https://api-3t.sandbox.paypal.com/nvp";
	} 

	if(not rs.success or not structkeyexists(rs.struct, 'ack') or rs.struct.ack NEQ "SUCCESS"){ 

		savecontent variable="out"{
			echo('<h2>Paypal Checkout NVP API Call Failed</h2>
			<p>API URL: #paypalUrl#</p>');
			writedump(ss); 
			writedump(rs);
		}
		ts={
			type:"Custom",
			errorHTML:out,
			scriptName:'/create-listings/index',
			url:request.zos.globals.domain&request.zos.originalURL,
			exceptionMessage:"Paypal Checkout NVP API Call Failed",
			// optional
			lineNumber:'1'
		}
		application.zcore.functions.zLogError(ts);
		return false;
	}
	/*
	// uncomment to debug api responses
	echo(cfhttp.filecontent);
	writedump(ss);
	writedump(form);
	writedump(cfhttp);
	abort;*/

	//application.zcore.functions.zRedirect(cfhttp.filecontent);

	checkoutLink="https://www.paypal.com/cgi-bin/webscr?cmd=_express-checkout&useraction=commit&token="&rs.struct.token;
	if(request.paypalTestMode){
		checkoutLink="https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&useraction=commit&token="&rs.struct.token;
	}
	// redirect with javascript to disable back button from working without the POST warning message
	</cfscript>
	<h2>Redirecting to PayPal.com Checkout</h2>  
	<p>Please don't use the back button.</p>
	<script>
	setTimeout(function(){
		var a=window.location;
		a.href='#checkoutLink#';
	}, 2000);
	</script> 
	<cfscript>
	return true;
	</cfscript>
</cffunction>


<cffunction name="callPaypalNVPAPI" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;

	paypalUrl="https://api-3t.paypal.com/nvp";
	if(request.paypalTestMode){
		paypalUrl="https://api-3t.sandbox.paypal.com/nvp";
	} 

	http url="#paypalURL#" method="post" timeout="15"{
		for(i in ss.paypalData){
			httpparam type="formfield" name="#i#" value="#ss.paypalData[i]#"{};
		}
	}
	if(cfhttp.statuscode NEQ "200 OK"){
		savecontent variable="out"{
			echo('<h2>Paypal Checkout NVP API Call Failed</h2>
			<p>API URL: #paypalUrl#</p>');
			writedump(ss); 
			writedump(rs);
		}
		ts={
			type:"Custom",
			errorHTML:out,
			scriptName:request.zos.originalURL,
			url:request.zos.globals.domain&request.zos.originalURL,
			exceptionMessage:"Paypal Checkout NVP API Call Failed",
			// optional
			lineNumber:'1'
		}
		application.zcore.functions.zLogError(ts);
		return {success:false};
	}

	ts={};
	application.zcore.functions.zParseQueryStringToStruct(cfhttp.filecontent, ts);
	return {success:true, struct:ts}; 
	</cfscript>
	
</cffunction>

 
</cfoutput>
</cfcomponent>