<cfcomponent>
<cfoutput>
<cffunction name="process" access="remote" localmode="modern" roles="user">
	<cfscript>
	db=request.zos.queryObject;
	// store the agreement
	ts={
		success:true
	};
	application.zcore.functions.zReturnJson(ts);
	</cfscript>
</cffunction>

<cffunction name="printContract" access="remote" localmode="modern" roles="user">
	<cfscript>
	application.zcore.template.setPlainTemplate();
	request.zPageDebugDisabled=true;
	</cfscript>
	<div style="width:100%; float:left; padding:20px;">
		<cfloop from="1" to="40" index="i">
			I agree to the terms set therein therefore and forthright and otherness. #i# 
		</cfloop>
	</div>
	<script>
	zArrDeferredFunctions.push(function(){
		window.print();
	});
	</script> 
</cffunction>
	
<cffunction name="displayContract" access="remote" localmode="modern" roles="user">
	<cfscript>
	application.zcore.template.setPlainTemplate();
	request.zPageDebugDisabled=true;
	</cfscript>
	<form  class="zFormCheckDirty" id="contractForm" onsubmit="return submitContract();" action="" method="post">
	<div id="contractFormContainerDiv" style="width:100%; display:none; float:left;">
		<div style="width:100%; float:left; font-size:120%; padding-bottom:5px; ">
			<div style="width:100px; float:right; text-align:right; "><a href="/z/admin/contract/printContract" target="_blank">Print</a></div>
			Terms of Use Agreement</div>
		<div id="contractDiv" style="width:100%;padding-right:5px; padding-left:5px; margin-bottom:5px; border:1px solid ##000; float:left; overflow:auto; height:200px;">
			<cfloop from="1" to="40" index="i">
				I agree to the terms set therein therefore and forthright and otherness. #i# 
			</cfloop>
		</div>

		<div id="beforeReadDiv" style="width:100%; float:left;">
				<p>You must read and completely scroll to the bottom of the agreement.</p>
		</div>
		<div id="afterReadDiv" style="width:100%; float:left; display:none;">
			<div style="width:100%; float:left; padding-bottom:5px;">
				<input type="checkbox" name="contract_agree" id="contract_agree" value="1" /> 
				<label for="contract_agree" style="cursor:pointer;">I agree to the terms of use.</label>
			</div>
			<div style="width:100%; float:left; padding-bottom:5px;">
				<label for="contract_name">Type Your Full Name:</label>
				<input type="text" name="contract_name" id="contract_name" size="40"  value="" style="width:50%; min-width:200px;" /> 
			</div>
		</div>
		<div id="afterAgreeDiv" style="width:100%; float:left; display:none;">
			<input type="button" onclick="submitContract();"	 name="contract_submit" id="contract_submit" value="Submit" /> 
		</div>
	</div>
	</form>

	<script>
	function ajaxContractError(){
		alert("Failed to process agreement. Please check your input and try again. Contact the web developer if the problem persists.");
	}
	function ajaxContractCallback(r){
		var r=eval('(' + r + ')'); 
		if(r.success){
			// close window
			window.parent.zCloseModal();
		}else{
			alert("Failed to process agreement. Please check your input and try again. Contact the web developer if the problem persists.");
		}
	}
	function submitContract(){
		//$("contractForm").
		var postObj=zGetFormDataByFormId("contractForm");
		if(postObj.contract_agree != "1" || postObj.contract_name == "" || postObj.contract_name.indexOf(" ") == -1){
			alert("You must check the box to agree and type your full name.");
			return false;
		}
		var obj={
			id:"ajaxProcessContract",
			method:"post",
			postObj:postObj,
			ignoreOldRequests:false,
			callback:ajaxContractCallback,
			errorCallback:ajaxContractError,
			url:'/z/admin/contract/process'
		}; 
		zAjax(obj);
		return true;
	}
	function checkContractForm(){
		var n=document.getElementById("contract_name").value;
		var agree=document.getElementById("contract_agree").checked;
		var a=document.getElementById("afterAgreeDiv");
		if(agree && n.length){
			if(a.style.display=='none'){
				a.style.display='block';
			}
		}else{
			if(a.style.display=='block'){
				a.style.display='none';
			}
		}
		return true;
	}
	function setupContractEvents(){
		var windowSize=zGetClientWindowSize();
		$("##contract_name").bind("paste", function(){
			checkContractForm();
		});
		$("##contract_name").bind("keyup", function(){
			checkContractForm();
		});
		$("##contract_name").bind("change", function(){
			checkContractForm();
		});
		$("##contract_agree").bind("change", function(){
			checkContractForm();
		});
 		$('##contractDiv').css({
 			"height":(Math.min(450, windowSize.height-50)-70)+"px",
 			"width": (windowSize.width-5)+"px"
 		}).bind('scroll', function(){
			if(($(this).scrollTop() + $(this).innerHeight() + 5) >= $(this)[0].scrollHeight){

				$("##beforeReadDiv").hide();
				$("##afterReadDiv").show();
			}
		});
		$("##contractFormContainerDiv").show();

	}
	function resizeContractDiv(){
		var windowSize=zGetClientWindowSize();
		$('##contractDiv').css({
 			"height":(Math.min(450, windowSize.height-50)-70)+"px",
 			"width": (windowSize.width-5)+"px"
 		});
	}
	zArrDeferredFunctions.push(function(){
		$('body').css('overflow','hidden');
		setupContractEvents();
		zArrResizeFunctions.push(resizeContractDiv);
	});
	</script> 
</cffunction>
	
<cffunction name="index" access="remote" localmode="modern" roles="user">
	<script>
	zArrDeferredFunctions.push(function(){
		var windowSize=zGetClientWindowSize();
 	  	var modalContent1='<iframe src="/z/admin/contract/displayContract"  style="margin:0px;border:none; overflow:hidden;" seamless="seamless" width="100%" height="100%"><\/iframe>';
 		zShowModal(modalContent1,{'width': Math.min(600, windowSize.width-100),'height':Math.min(450, windowSize.height-50), 'maxWidth': 600, 'maxHeight':500,  disableClose:true});
	});
	</script>
</cffunction>
</cfoutput>
</cfcomponent>