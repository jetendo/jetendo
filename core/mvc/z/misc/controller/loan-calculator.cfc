<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote" output="yes">
	<cfscript>
	outputLoanCalculatorJavascript();
	form.loan_amount=application.zcore.functions.zso(form, 'loan_amount', true, 1000);
	form.loan_interest=application.zcore.functions.zso(form, 'loan_interest', true, 8);
	form.loan_term=application.zcore.functions.zso(form, 'loan_term', true, 36);
	form.loan_down=application.zcore.functions.zso(form, 'loan_down', true, 0);

	inquiryTextMissing=false;
	ts=structnew();
	ts.content_unique_name='/z/misc/loan-calculator/index';
	if(request.zos.originalURL EQ "/z/misc/loan-calculator/index"){
		application.zcore.template.setTag("title", "Loan Calculator");
		application.zcore.template.setTag("pagetitle", "Loan Calculator");
		r1=application.zcore.app.getAppCFC("content").includePageContentByName(ts);
		if(r1 EQ false){
			inquiryTextMissing=true;
		}
	}else{
		r1=application.zcore.app.getAppCFC("content").includeContentByName(ts);
		if(r1 EQ false){
			inquiryTextMissing=true;
			echo('<h2>Loan Calculator</h2>');
		}
	}
	if(inquiryTextMissing){
		echo('<p>Calculate your estimated monthly payment below. 
		Want to apply for financing? 
		<a href="/z/misc/inquiry/index?inquiries_comments=#urlencodedformat("I'd like to apply for financing.")#">Click here.</a></p>');
	}
	</cfscript>
	<table class="table-list">
		<tr>
		<td>Loan Amount</td>
		<td>$</td><td>
		<input type="text" name="loan_amount" class="loanInputClass" id="loan_amount" value="#form.loan_amount#" />
		</td> 
		<tr><td>Interest (APR)</td>
		<td>&nbsp;</td><td><input type="text" name="loan_interest" class="loanInputClass" id="loan_interest" value="#form.loan_interest#" /> %</td>
		</tr> 
		<tr><td>Term</td>
		<td>&nbsp;</td><td><input type="text" name="loan_term" class="loanInputClass" id="loan_term" value="#form.loan_term#" /></td>
		</tr>
		<tr><td>Down Payment</td>
		<td>$</td><td><input type="text" name="loan_down" class="loanInputClass" id="loan_down" value="#form.loan_down#" /></td>
		</tr> 
		<tr><td>Payment</td>
		<td>&nbsp;</td><td><div id="loanMonthlyPaymentDiv"></div></td>
		</tr> 
		<tr><td>Cost of Loan</td>
		<td>&nbsp;</td><td><div id="loanCostDiv"></div></td>
		</tr> 
		<tr><td>&nbsp;</td>
		<td>&nbsp;</td><td><input type="button" name="loanSubmit" class="zLoanCalculatorButton" onclick="zCalculateLoanPayment();" value="Calculate" /></td>
		</tr>
	</table>

</cffunction>

<!---
form.loan_amount=100000;
form.loan_interest=5;
form.loan_term=240;
form.loan_down=0; 
loanCalcCom=createobject("component", "zcorerootmapping.mvc.z.misc.controller.loan-calculator");
loanCalcCom.customExample();
 --->
<cffunction name="customExample" localmode="modern" access="remote" output="yes">
	<cfscript>
	outputLoanCalculatorJavascript();
	form.loan_amount=application.zcore.functions.zso(form, 'loan_amount', true, 100000);
	form.loan_interest=application.zcore.functions.zso(form, 'loan_interest', true, 5);
	form.loan_term=application.zcore.functions.zso(form, 'loan_term', true, 240);
	form.loan_down=application.zcore.functions.zso(form, 'loan_down', true, 0);
 
	</cfscript>
	<table class="table-list">
		<tr>
		<td>Loan Amount</td>
		<td>$</td><td>
		<input type="text" name="loan_amount" class="loanInputClass" id="loan_amount" value="#form.loan_amount#" />
		</td> 
		</tr>
		<tr><td>Interest (APR)</td>
		<td>&nbsp;</td><td><input type="text" name="loan_interest" class="loanInputClass" id="loan_interest" value="#form.loan_interest#" /> %</td>
		</tr> 
		<tr><td>Term</td>
		<td>&nbsp;</td><td><input type="text" name="loan_term" class="loanInputClass" id="loan_term" value="#form.loan_term#" /></td>
		</tr>
		<tr><td>Down Payment</td>
		<td>$</td><td><input type="text" name="loan_down" class="loanInputClass" id="loan_down" value="#form.loan_down#" /></td>
		</tr> 
		<tr><td>Payment</td>
		<td>&nbsp;</td><td><div id="loanMonthlyPaymentDiv"></div></td>
		</tr> 
		<tr><td>Cost of Loan</td>
		<td>&nbsp;</td><td><div id="loanCostDiv"></div></td>
		</tr> 
		<tr><td>&nbsp;</td>
		<td>&nbsp;</td><td><input type="button" name="loanSubmit" class="zLoanCalculatorButton" onclick="zCalculateLoanPayment();" value="Calculate" /></td>
		</tr>
	</table>

</cffunction>


<cffunction name="outputLoanCalculatorJavascript" localmode="modern" access="public">
	<script type="text/javascript">
	function zCalculateLoanPayment(){
		var amount=parseInt(document.getElementById("loan_amount").value);
		var interest=parseFloat(document.getElementById("loan_interest").value);
		var term=parseInt(document.getElementById("loan_term").value);
		var down=parseInt(document.getElementById("loan_down").value);
		var paymentDiv=document.getElementById("loanMonthlyPaymentDiv");
		var loanCostDiv=document.getElementById("loanCostDiv");
		if(isNaN(amount)){
			alert("Loan amount must be a number without any letters or punctuation.");
		}
		if(isNaN(interest)){
			alert("Loan amount must be a decimal number.");
		}
		if(isNaN(term)){
			alert("Term must be a number without any letters or punctuation.");
		}
		if(isNaN(down)){
			alert("Down Payment must be a number without any letters or punctuation.");
		}
		amount-=down;
		var i=interest/100.0/12.0;
		var tau=1.0 + i;
		var tauToTheN = Math.pow(tau, term ) ;
		var mn = tauToTheN * i / (tauToTheN - 1.0 );
		var monthlyPayment=amount * mn;
		var totalInterest = amount * mn * term - amount;
		paymentDiv.innerHTML="$"+(Math.round(monthlyPayment*100)/100)+" per month";
		loanCostDiv.innerHTML="$"+(Math.round(totalInterest*100)/100)+" total interest";
	}
	zArrDeferredFunctions.push(function(){
		$(".loanInputClass").bind("change", function(){
			zCalculateLoanPayment();
		});
		zCalculateLoanPayment();
	});
	</script>
</cffunction>
</cfoutput>
</cfcomponent>