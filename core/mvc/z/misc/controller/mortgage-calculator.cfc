<cfcomponent>
 <cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
 	<cfscript>
	var inquiryTextMissing=false;
	var ts=structnew();
	var r1=0;
	ts.content_unique_name='/z/misc/mortgage-calculator/index';
	r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
	if(r1 EQ false){
		inquiryTextMissing=true;
	}
	if(inquiryTextMissing){
		application.zcore.template.setTag("title","Mortgage Calculator");
		application.zcore.template.setTag("pagetitle","Mortgage Calculator");
		writeoutput('<p>Calculate your mortgage below.  Want to secure the best rates on today''s market?</p><p><a href="/z/misc/mortgage-quote/index">Click here for a free mortgage quote.</a></p>');
	}
	
	if(not structkeyexists(request, 'price')){
		request.price=250000;
	}
	if(not structkeyexists(request, 'taxes')){
		request.taxes=2300;
	}
	sidebarPaymentCalculator(request.price, request.taxes);
	</cfscript>

</cffunction>

<!--- 
mortgageCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.misc.controller.mortgage-calculator");
mortgageCom.sidebarPaymentCalculator();
 --->
<cffunction name="sidebarPaymentCalculator" access="remote" localmode="modern">
	<cfargument name="price" type="string" required="no" default="125000"> 
	<cfargument name="taxes" type="string" required="no" default="2300"> 
	
	<div class="zMortgagePaymentFieldDiv">
		Home Price<br />
		$<input type="text" size="12" name="homeprice" onchange="zCalculateMonthlyPayment();" id="homeprice" value="#htmleditformat(arguments.price)#" />
	</div>
	<div class="zMortgagePaymentFieldDiv">
		Percent Down<br />
		<input type="text" size="4" name="percentdown" onchange="zCalculateMonthlyPayment();" id="percentdown" value="20" />%
	</div>
	<div class="zMortgagePaymentFieldDiv">
		Loan Type:<br />
		<select name="loantype" id="loantype" onchange="zCalculateMonthlyPayment();" size="1">
		<option value="30.5" selected="selected">5/1 ARM</option>
		<option value="40">40 Year Fixed</option>
		<option value="30" selected="selected">30 Year Fixed</option>
		<option value="25">25 Year Fixed</option>
		<option value="20">20 Year Fixed</option>
		<option value="15">15 Year Fixed</option>
		<option value="10">10 Year Fixed</option>
	</select>
	</div>
	<div class="zMortgagePaymentFieldDiv">
		Current Rate<br />
		<input type="text" size="4" name="currentrate" onchange="zCalculateMonthlyPayment();" id="currentrate" value="4.5" />%
	
	</div>
	<div class="zMortgagePaymentFieldDiv">
		Annual Taxes<br />
		$<input type="text" size="7" name="hometax" onchange="zCalculateMonthlyPayment();" id="hometax" value="#htmleditformat(arguments.taxes)#" />
	
	</div>
	<div class="zMortgagePaymentFieldDiv">
		Annual Insurance<br />
		$<input type="text" size="7" name="homeinsurance" onchange="zCalculateMonthlyPayment();" id="homeinsurance" value="1200" />
	</div>
	<div class="zMortgagePaymentFieldDiv">
		Annual HOA Dues<br />
		$<input type="text" size="7" name="homehoa" onchange="zCalculateMonthlyPayment();" id="homehoa" value="500" />
	</div>
	<div class="zMortgagePaymentFieldDiv">
		<button name="calcbutton1">Estimate Payment</button>
	</div>
	<div id="zMortgagePaymentResults" class="zMortgagePaymentResults">
	</div>
	<script>
	/* <![CDATA[ */
	zArrDeferredFunctions.push(function(){ zCalculateMonthlyPayment(); });
	/* ]]> */
	</script>
	
	</cffunction>
</cfoutput>
</cfcomponent>