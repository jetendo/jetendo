+<cfcomponent>
<cfoutput>
<cffunction name="select" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.index();
	</cfscript>
</cffunction>

<cffunction name="getAssignLead" localmode="modern" access="remote">
	<cfargument name="form_type" type="string" required="yes">
	<cfscript>
		var db=request.zos.queryObject;
		var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
		var luid = "";
		if(structkeyexists(form, "user_id")){
			luid = "#form.user_id#";
		} else{    
			luid = "";
		}
		if(!structkeyexists(form, 'user_id_siteIDType')){
			form["user_id_siteIDType"] = "";
		}
		if(!structkeyexists(form, 'inquiries_admin_comments')){
			form["inquiries_admin_comments"] = "";
		}
		if(!structkeyexists(form, 'zPageId')){
			form["zPageId"] = 0;
		}
	</cfscript>
<div style="float:left;">
	<table style="width:100%; border-spacing:0px;"> 
		<!--- office search is only useful when there is more then one office --->
		<cfif application.zcore.user.checkGroupAccess("administrator") and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1> 
			<cfscript> 
			if(application.zcore.user.checkGroupAccess("administrator")){ 
				ts={
					sortBy:"name"
				}
				arrOffice=application.zcore.user.getOffices(ts);
			}else{
				ts={
					ids:listToArray(request.zsession.user.office_id, ","),
					sortBy:"name"
				}
				arrOffice=application.zcore.user.getOffices(ts); 
			} 
			</cfscript> 
			<cfif arrayLen(arrOffice) GT 0>
				<tr><th style="text-align:left;">1) Office:</th></tr>
				 <tr><td style="padding:10px;"> 
					<p>An office is a group of 1 or more users who will be able to access this lead.</p>
					<div style="float:left; max-width:100%; padding-right:10px; padding-bottom:10px; ">
						<cfscript> 
						selectStruct = StructNew();
						selectStruct.name = "office_id"; 
						selectStruct.arrData = arrOffice;
						selectStruct.size=1; 
						selectStruct.onChange="assignSelectOffice();";
						selectStruct.queryLabelField = "office_name";
						selectStruct.inlineStyle="width:100%; max-width:100%;";
						selectStruct.queryValueField = 'office_id';

						if(arrayLen(arrOffice) GT 3){
							echo('Type to filter offices: <input type="text" name="#selectStruct.name#_InputField" onkeyup="setTimeout(function(){ assignSelectOffice();}, 100); " id="#selectStruct.name#_InputField" value="" style="min-width:auto;width:200px; max-width:100%; margin-bottom:5px;"><br />Select Office:<br>');
							application.zcore.functions.zInputSelectBox(selectStruct);
							application.zcore.skin.addDeferredScript("  $('###selectStruct.name#').filterByText($('###selectStruct.name#_InputField'), true); ");
						}else{
							selectStruct.size=1;
							echo('<div style="width:50px; float:left;">Office:</div><div style="width:200px;float:left;">');
							application.zcore.functions.zInputSelectBox(selectStruct);
							echo('</div>');
						}
						</cfscript>
					</div>
				</td></tr>
			</cfif> 
		</cfif>
	

	<tr><th style="text-align:left;">
		<cfif application.zcore.user.checkGroupAccess("administrator") and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>2a) </cfif>
		Assign to a user on this web site:
	</th></tr>
	<tr>
	<td>
	<cfscript>
		if(form.method EQ arguments.form_type){ 
			// only allow assigning to people who belong to the same offices that this user does. 
			if(request.zsession.user.office_id NEQ ""){
				qAgents=application.zcore.user.getUsersByOfficeIdList(request.zsession.user.office_id, request.zos.globals.id);
			}else{
				db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
				WHERE site_id=#db.param(request.zos.globals.id)# and 
				user_deleted = #db.param(0)# and
				user_id =#db.param(-1)#";
				qAgents=db.execute("qAgents"); 
			} 
		}else{
			// TODO: find only the users this user should have access to 
			db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
			WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
			user_deleted = #db.param(0)# and
			user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# 
			 and (user_server_administrator=#db.param(0)#)
			ORDER BY member_first_name ASC, member_last_name ASC";
			qAgents=db.execute("qAgents");
		}
	
	</cfscript> 
	<script type="text/javascript">
	/* <![CDATA[ */
	function showAgentPhoto(id){
		var d1=document.getElementById("agentPhotoDiv");
		if(id!="" && arrAgentPhoto[id]!=""){
			d1.innerHTML='<img src="'+arrAgentPhoto[id]+'" width="100">';
		}else{
			d1.innerHTML="";    
		}
	}
	function assignSelectOffice(){ 
		var officeElement=document.getElementById("office_id");
		var userElement=document.getElementById("user_id"); 
		if(typeof officeElement.options != "undefined" && officeElement.options.length ==0){
			for(var i=0;i<userElement.options.length;i++){
				userElement.options[i].style.display="block"; 
			}
			return;
		}
		var officeId=officeElement.options[officeElement.selectedIndex].value;

		for(var i=0;i<userElement.options.length;i++){
			var optionOfficeId=userElement.options[i].getAttribute("data-office-id");
			if(userElement.options[i].value == ""){
				userElement.options[i].style.display="block"; 
			}else if(officeId == "" || optionOfficeId.indexOf(','+officeId+',') != -1){
				userElement.options[i].style.display="block"; 
			}else{
				userElement.options[i].style.display="none"; 
			}
		} 
		userElement.selectedIndex=0;
	}
	var arrAgentPhoto=new Array();
	<cfif qAgents.recordcount>
		<cfloop query="qAgents">
		arrAgentPhoto["#qAgents.user_id#|#qAgents.site_id#"]=<cfif qAgents.member_photo NEQ "">"#jsstringformat('#application.zcore.functions.zvar('domain',qAgents.userSiteId)##request.zos.memberImagePath##qAgents.member_photo#')#"<cfelse>""</cfif>;
		</cfloop>
	</cfif>
	/* ]]> */
	</script>  
	<cfif application.zcore.user.checkGroupAccess("administrator") and form.method EQ "index" and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>
		<!--- do nothing --->
	<cfelse>
		<div style="width:100%; float:left;">
			<div style="float:left; width:100%;">Type to filter users:</div>
			<div style="float:left; width:100%;"> 
				<input type="text" name="assignInputField" id="assignInputField" value="" style="width:240px; min-width:auto; max-width:auto; margin-bottom:5px;">
			</div>
		</div>
	</cfif>

	<div style="width:100%; margin-bottom:20px;float:left;">
		<div style="float:left; width:100%;">Select a user:</div>
		<div style="float:left; width:100%;"> 


			<cfscript> 
 
			// when user selects office, the user drop down should change to show only users in that office.
			form.user_id = form.user_id&"|"&application.zcore.functions.zGetSiteIdFromSiteIdType(form.user_id_siteIDType);
			echo('<select name="user_id" id="user_id" size="1" onchange="showAgentPhoto(this.options[this.selectedIndex].value);">');
			echo('<option value="" data-office-id="">-- Select --</option>');
			for(row in qAgents){
				userGroupName=userGroupCom.getGroupDisplayName(row.user_group_id, row.site_id);
				echo('<option value="'&row.user_id&"|"&row.site_id&'" data-office-id=",'&row.office_id&',"');
				if(luid EQ row.user_id &"|"&application.zcore.functions.zGetSiteIdType(row.site_id)){
					echo(' selected ');
				}
				arrName=[];
				if(trim(row.user_first_name&" "&row.user_last_name) NEQ ""){
					arrayAppend(arrName, row.user_first_name&" "&row.user_last_name);
				}
				if(row.user_username NEQ ""){
					arrayAppend(arrName, row.user_username)
				}
				if(row.member_company NEQ ""){
					arrayAppend(arrName, row.member_company);
				}
				echo('>'&arrayToList(arrName, " / ")&' / #userGroupName#</option>');
			}
			echo('</select>'); 
			application.zcore.skin.addDeferredScript("  $('##user_id').filterByText($('##assignInputField'), true); ");

			</cfscript>
		</div>
	</div>
	</tr>
	<tr><th style="text-align:left;">
		<cfif application.zcore.user.checkGroupAccess("administrator") and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>2b) </cfif>
		Or assign this lead to anyone outside the web site:</td></tr>
	<tr><td>
	<div style="width:100%; margin-bottom:20px;float:left;"> 
		<p>External Name:<br><input type="text" name="assign_name" style="min-width:100%; width:100%;" value="#application.zcore.functions.zso(form, 'assign_name')#" /></p>
		<p>External Email(s):<br>
		<input type="text" name="assign_email" style="min-width:100%; width:100%;" value="#application.zcore.functions.zso(form, 'assign_email')#" /><br>
		(Comma separate multiple emails)</p>
	</div>
	<div id="agentPhotoDiv"></div>
	</td>
	</tr>
	</table>
</div>

</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript> 
	var db=request.zos.queryObject;
	application.zcore.skin.includeJS("/z/a/scripts/tiny_mce/tinymce.min.js"); 
	var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	application.zcore.functions.zSetPageHelpId("4.1.2");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Leads");
	form.inquiries_id=application.zcore.functions.zso(form, 'inquiries_id');
	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	</cfscript>
	<cfsavecontent variable="db.sql">
	SELECT * FROM (#db.table("inquiries_status", request.zos.zcoreDatasource)# inquiries_status
	, #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
	) 
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type
	ON inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	inquiries_type_deleted = #db.param(0)#
	WHERE inquiries.site_id = #db.param(request.zos.globals.id)#  and 		
	inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
	inquiries_deleted = #db.param(0)# and 
	inquiries_status_deleted = #db.param(0)# and 
	inquiries.inquiries_status_id NOT IN (#db.trustedSQL("4,5,0,7")#) and 
	 inquiries_id = #db.param(form.inquiries_id)#  
	</cfsavecontent><cfscript>
	qinquiry=db.execute("qinquiry");
		if(qinquiry.recordcount EQ 0){		
			request.zsid = application.zcore.status.setStatus(Request.zsid, "This inquiry doesn't exist.", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zQueryToStruct(qinquiry);
		}
		application.zcore.functions.zstatushandler(request.zsid,true);
	</cfscript>
	<span class="form-view">
	<h2>Selected Lead</h2>
	<!--- <p>Leads are matched by email and phone number to help you assign to the same agent if desired.</p> --->
	<table style="width:100%; border-spacing:0px;" class="table-list">
	<tr>
	<th style="width:150px;">Name</th>
	<th style="width:150px;">Email</th>
	<th>&nbsp;</th>
	<th>Date Received</th>
	<th>Previously Assigned To:</th>
	<th>Previous Lead Date:</th>
	</tr>
	<tr >
	<td style="width:150px;">#form.inquiries_first_name# #form.inquiries_last_name#</td>
	<td style="width:150px;"><cfif len(form.inquiries_email) NEQ 0>#form.inquiries_email#</cfif></td>
	<td></td>
	<td style="width:150px;">#DateFormat(form.inquiries_datetime,'m/d/yy')&' '&TimeFormat(form.inquiries_datetime,'h:mm tt')#</td> 
	<cfscript>
	if(qinquiry.user_id NEQ 0){
		db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user
		WHERE user_id = #db.param(qinquiry.user_id)# and 
		user_deleted=#db.param(0)# and 
		site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdFromSiteIdType(qinquiry.user_id_siteIDType))#";
		local.qUserTemp=db.execute("qUserTemp");
		if(local.qUserTemp.recordcount NEQ 0){
			writeoutput('<td>'); 
			writeoutput(local.qUserTemp.user_first_name&" "&local.qUserTemp.user_last_name&" "&local.qUserTemp.user_username);
		   writeoutput('</td><td>'&dateformat(qinquiry.inquiries_datetime, "m/d/yy ")&timeformat(qinquiry.inquiries_datetime, 'h:mm tt')&'</td>');
		}
	}else if(qinquiry.inquiries_assign_email NEQ ""){
		writeoutput('<td>'); 
		writeoutput('#qinquiry.inquiries_assign_name# #qinquiry.inquiries_assign_email# ');
		writeoutput('</td><td>'&dateformat(qinquiry.inquiries_datetime, "m/d/yy ")&timeformat(qinquiry.inquiries_datetime, 'h:mm tt')&'</td>');
	}else{
		db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
		WHERE inquiries_id <> #db.param(form.inquiries_id)# and 
		inquiries_email = #db.param(form.inquiries_email)# and
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted = #db.param(0)# and 
		(user_id <> #db.param(0)# or 
		inquiries_assign_email <> #db.param('')#) 
		ORDER BY inquiries_datetime DESC   ";
		local.qPrevious=db.execute("qPrevious");
		if(local.qPrevious.recordcount NEQ 0){
			writeoutput('<td>'); 
			if(local.qPrevious.user_id NEQ 0){
				db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# user
				WHERE user_id = #db.param(local.qPrevious.user_id)# and 
				user_deleted=#db.param(0)# and 
				site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdFromSiteIdType(local.qPrevious.user_id_siteIDType))#";
				local.qUserTemp=db.execute("qUserTemp");
				if(local.qUserTemp.recordcount NEQ 0){
					writeoutput(local.qUserTemp.user_first_name&" "&local.qUserTemp.user_last_name&" "&local.qUserTemp.user_username);
				}
			}else{
				writeoutput('#local.qPrevious.inquiries_assign_name# #local.qPrevious.inquiries_assign_email# ');
			} 
			writeoutput('</td><td>'&dateformat(local.qPrevious.inquiries_datetime, "m/d/yy ")&timeformat(local.qPrevious.inquiries_datetime, 'h:mm tt')&'</td>');
		}else{
		   writeoutput('<td>N/A</td><td>&nbsp;</td>');    
		}
	}
	</cfscript>
	</tr>
	</table><br />
  
	<h2><cfif form.user_id NEQ 0 or form.inquiries_assign_email NEQ "">Re-</cfif>Assign Lead</h2>
	<!--- 
	Note: The agents in the drop down menu are sorted in the sequence they are due to receive a lead. Agent will be notified of assignment by email.<br /><br /> --->
	
	<form class="zFormCheckDirty" action="/z/inquiries/admin/assign/<cfif form.method EQ "index">assign<cfelse>userAssign</cfif>?inquiries_id=#form.inquiries_id#&amp;zPageId=#form.zPageId#" method="post"> 
	<table style="width:100%; border-spacing:0px;"> 
		<!--- office search is only useful when there is more then one office --->
		<cfif application.zcore.user.checkGroupAccess("administrator") and form.method EQ "index" and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1> 
			<cfscript> 
			if(application.zcore.user.checkGroupAccess("administrator")){ 
				db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# 
				WHERE site_id = #db.param(request.zos.globals.id)# and 
				office_deleted = #db.param(0)# 
				ORDER BY office_name ASC"; 
				qOffice=db.execute("qOffice"); 
			}else{
				qOffice=application.zcore.user.getOfficesByOfficeIdList(request.zsession.user.office_id, request.zos.globals.id); 
			}
			</cfscript> 
			<cfif qOffice.recordcount GT 0>
				<tr><th style="text-align:left;">1) Office:</th></tr>
				 <tr><td style="padding:10px;"> 
					<p>An office is a group of 1 or more users who will be able to access this lead.</p>
					<div style="float:left; max-width:100%; padding-right:10px; padding-bottom:10px; ">
						<cfscript> 
						selectStruct = StructNew();
						selectStruct.name = "office_id"; 
						selectStruct.query = qOffice;
						selectStruct.size=1; 
						selectStruct.onChange="assignSelectOffice();";
						selectStruct.queryLabelField = "office_name";
						selectStruct.inlineStyle="width:100%; max-width:100%;";
						selectStruct.queryValueField = 'office_id';

						if(qOffice.recordcount GT 3){
							echo('Type to filter offices: <input type="text" name="#selectStruct.name#_InputField" onkeyup="setTimeout(function(){ assignSelectOffice();}, 100); " id="#selectStruct.name#_InputField" value="" style="min-width:auto;width:200px; max-width:100%; margin-bottom:5px;"><br />Select Office:<br>');
							application.zcore.functions.zInputSelectBox(selectStruct);
							application.zcore.skin.addDeferredScript("  $('###selectStruct.name#').filterByText($('###selectStruct.name#_InputField'), true); ");
						}else{
							selectStruct.size=1;
							echo('<div style="width:50px; float:left;">Office:</div><div style="width:200px;float:left;">');
							application.zcore.functions.zInputSelectBox(selectStruct);
							echo('</div>');
						}
						</cfscript>
					</div>
				</td></tr>
			</cfif> 
		</cfif>
	

	<tr><th style="text-align:left;">
		<cfif application.zcore.user.checkGroupAccess("administrator") and form.method EQ "index" and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>2a) </cfif>
		Assign to a user on this web site:
	</th></tr>
	<tr>
	<td>
	<cfscript>
	if(form.method EQ "userIndex"){ 
		// only allow assigning to people who belong to the same offices that this user does. 
		if(request.zsession.user.office_id NEQ ""){
			qAgents=application.zcore.user.getUsersByOfficeIdList(request.zsession.user.office_id, request.zos.globals.id);
		}else{
			db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
			WHERE site_id=#db.param(request.zos.globals.id)# and 
			user_deleted = #db.param(0)# and
			user_id =#db.param(-1)#";
			qAgents=db.execute("qAgents"); 
		} 
	}else{
		// TODO: find only the users this user should have access to 
		db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
		WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
		user_deleted = #db.param(0)# and
		user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# 
		 and (user_server_administrator=#db.param(0)#)
		ORDER BY member_first_name ASC, member_last_name ASC";
		qAgents=db.execute("qAgents");
	}
	
	</cfscript> 
	<script type="text/javascript">
	/* <![CDATA[ */
	function showAgentPhoto(id){
		var d1=document.getElementById("agentPhotoDiv");
		if(id!="" && arrAgentPhoto[id]!=""){
			d1.innerHTML='<img src="'+arrAgentPhoto[id]+'" width="100">';
		}else{
			d1.innerHTML="";	
		}
	}
	function assignSelectOffice(){ 
		var officeElement=document.getElementById("office_id");
		var userElement=document.getElementById("user_id"); 
		if(typeof officeElement.options != "undefined" && officeElement.options.length ==0){
			for(var i=0;i<userElement.options.length;i++){
				userElement.options[i].style.display="block"; 
			}
			return;
		}
		var officeId=officeElement.options[officeElement.selectedIndex].value;

		for(var i=0;i<userElement.options.length;i++){
			var optionOfficeId=userElement.options[i].getAttribute("data-office-id");
			if(userElement.options[i].value == ""){
				userElement.options[i].style.display="block"; 
			}else if(officeId == "" || optionOfficeId.indexOf(','+officeId+',') != -1){
				userElement.options[i].style.display="block"; 
			}else{
				userElement.options[i].style.display="none"; 
			}
		} 
		userElement.selectedIndex=0;
	}
	var arrAgentPhoto=new Array();
	<cfif qAgents.recordcount>
		<cfloop query="qAgents">
		arrAgentPhoto["#qAgents.user_id#|#qAgents.site_id#"]=<cfif qAgents.member_photo NEQ "">"#jsstringformat('#application.zcore.functions.zvar('domain',qAgents.userSiteId)##request.zos.memberImagePath##qAgents.member_photo#')#"<cfelse>""</cfif>;
		</cfloop>
	</cfif>
	/* ]]> */
	</script>  
	<cfif application.zcore.user.checkGroupAccess("administrator") and form.method EQ "index" and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>
		<!--- do nothing --->
	<cfelse>
		<div style="width:100%; float:left;">
			<div style="float:left; width:100%;">Type to filter users:</div>
			<div style="float:left; width:100%;"> 
				<input type="text" name="assignInputField" id="assignInputField" value="" style="width:240px; min-width:auto; max-width:auto; margin-bottom:5px;">
			</div>
		</div>
	</cfif>

	<div style="width:100%; margin-bottom:20px;float:left;">
		<div style="float:left; width:100%;">Select a user:</div>
		<div style="float:left; width:100%;"> 


			<cfscript> 
			// when user selects office, the user drop down should change to show only users in that office.
			form.user_id = form.user_id&"|"&application.zcore.functions.zGetSiteIdFromSiteIdType(form.user_id_siteIDType);
			echo('<select name="user_id" id="user_id" size="1" onchange="showAgentPhoto(this.options[this.selectedIndex].value);">');
			echo('<option value="" data-office-id="">-- Select --</option>');
			for(row in qAgents){
				userGroupName=userGroupCom.getGroupDisplayName(row.user_group_id, row.site_id);
				echo('<option value="'&row.user_id&"|"&row.site_id&'" data-office-id=",'&row.office_id&',"');
				if(form.user_id EQ row.user_id&"|"&row.site_id){
					echo(' selected="selected" ');
				}
				arrName=[];
				if(trim(row.user_first_name&" "&row.user_last_name) NEQ ""){
					arrayAppend(arrName, row.user_first_name&" "&row.user_last_name);
				}
				if(row.user_username NEQ ""){
					arrayAppend(arrName, row.user_username)
				}
				if(row.member_company NEQ ""){
					arrayAppend(arrName, row.member_company);
				}
				echo('>'&arrayToList(arrName, " / ")&' / #userGroupName#</option>');
			}
			echo('</select>'); 
			application.zcore.skin.addDeferredScript("  $('##user_id').filterByText($('##assignInputField'), true); ");

			</cfscript>
		</div>
	</div>
	</tr>
	<tr><th style="text-align:left;">
		<cfif application.zcore.user.checkGroupAccess("administrator") and form.method EQ "index" and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>2b) </cfif>
		Or assign this lead to anyone outside the web site:</td></tr>
	<tr><td>
	<div style="width:100%; margin-bottom:20px;float:left;"> 
		<p>External Name:<br><input type="text" name="assign_name" style="min-width:100%; width:100%;" value="#application.zcore.functions.zso(form, 'assign_name')#" /></p>
		<p>External Email(s):<br>
		<input type="text" name="assign_email" style="min-width:100%; width:100%;" value="#application.zcore.functions.zso(form, 'assign_email')#" /><br>
		(Comma separate multiple emails)</p>
	</div>
	<div id="agentPhotoDiv"></div>
	</td>
	</tr>
	<tr>
	<th style="text-align:left;">Private Comments</th></tr>
	<tr>
	<td>
		(Optional) Add some notes that won't be visible to the public customer.<br>
		<cfscript>
		htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
		htmlEditor.instanceName	= "inquiries_admin_comments";
		htmlEditor.value			= form.inquiries_admin_comments;
		htmlEditor.width			= "100%";
		htmlEditor.height		= 150;
		htmlEditor.createSimple();
		</cfscript>
	</td></tr>
	<tr>
		<td><button type="submit" name="submitForm" class="z-manager-search-button">Assign Lead</button> <button type="button" name="cancel" onclick="window.location.href = '/z/inquiries/admin/manage-inquiries/<cfif form.method EQ "index">index<cfelse>userIndex</cfif>?zPageId=#form.zPageId#';" class="z-manager-search-button">Cancel</button></td>
	</tr>
	</table>
	</form>
	</span>
	
	<script type="text/javascript">
	zArrDeferredFunctions.push( function() {  
		/*function emailSentCallback(r){
			window.parent.location.reload();
		}
		$("##sendEmailForm").on("submit", function(e){ 
			var valid3=true;
			if($("##inquiries_subject").val()=="" || $("##inquiries_message").val()==""){
				alert("Subject and message are required.");
				valid3=false;
			}
			if(!valid3){
				return false;
			}
			return zSubmitManagerEditForm(this, emailSentCallback); 
		});*/
	});
	</script> 
</cffunction>


<cffunction name="userIndex" localmode="modern" access="remote">
	<cfscript> 
	inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
	inquiriesCom.userInit();
	index();
	</cfscript>
</cffunction>

<cffunction name="userAssign" localmode="modern" access="remote">
	<cfscript> 
	inquiriesCom=createobject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
	inquiriesCom.userInit();
	assign();
	</cfscript>
</cffunction>

<cffunction name="assign" localmode="modern" access="remote" roles="member">
	<cfscript> 
	var db=request.zos.queryObject;
	if(form.method EQ "assign"){ 
		application.zcore.adminSecurityFilter.requireFeatureAccess("Leads", true);
	}
	form.office_id=application.zcore.functions.zso(form, 'office_id', true);

	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	if(application.zcore.functions.zso(form, 'user_id') EQ '' and application.zcore.functions.zso(form, 'assign_email') EQ ''){
		application.zcore.status.setStatus(request.zsid,"You forgot to type an email address or select a user from the drop down menu.",form,true);
		if(form.method EQ "userAssign"){
			application.zcore.functions.zRedirect("/z/inquiries/admin/assign/userIndex?inquiries_id=#form.inquiries_id#&zPageId=#form.zPageId#&zsid=#request.zsid#");  
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/assign/index?inquiries_id=#form.inquiries_id#&zPageId=#form.zPageId#&zsid="&request.zsid);
		}
	}
	if(application.zcore.functions.zso(form, 'user_id') CONTAINS "|"){
		local.assignUserId=listGetAt(form.user_id, 1, "|");
		local.assignSiteId=listGetAt(form.user_id, 2, "|");
	}else{
		local.assignUserId=0;
		local.assignSiteId=0;
	} 
	local.assignSiteIdType=application.zcore.functions.zGetSiteIdType(local.assignSiteId);
	if(application.zcore.functions.zso(form, 'assign_email') NEQ ''){
		arrEmail=listToArray(form.assign_email, ",");
		arrEmailFinal=[];
		for(i=1;i LTE arraylen(arrEmail);i++){
			e=trim(arrEmail[i]);
			if(e NEQ ""){
				if(application.zcore.functions.zEmailValidate(e) EQ false){
					application.zcore.status.setStatus(request.zsid,"Invalid email address format: #arrEmail[i]#",form,true);
					if(form.method EQ "userAssign"){
						application.zcore.functions.zRedirect("/z/inquiries/admin/assign/userIndex?inquiries_id=#form.inquiries_id#&zPageId=#form.zPageId#&zsid=#request.zsid#");  
					}else{
						application.zcore.functions.zRedirect("/z/inquiries/admin/assign/index?inquiries_id=#form.inquiries_id#&zPageId=#form.zPageId#&zsid=#request.zsid#");  
					}
				}
				arrayAppend(arrEmailFinal, e);
			}
		}
		form.assign_email=arraytolist(arrEmailFinal, ", ");
	}
	</cfscript>
	<cfif application.zcore.functions.zso(form, 'assign_email') NEQ ''>
		<cfscript>
		request.noleadsystemlinks=true;
		db.sql="SELECT inquiries_email from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
		WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)#";
		qGetInquiry=db.execute("qGetInquiry");
		db.sql="SELECT count(inquiries_feedback_id) count 
		from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
		WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
		inquiries_feedback_deleted = #db.param(0)# and
		site_id = #db.param(request.zos.globals.id)#";
		qFeedback=db.execute("qFeedback");
		</cfscript>
		<cfsavecontent variable="db.sql">
		UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
		 SET inquiries_assign_email = #db.param(form.assign_email)#,  
		<cfif application.zcore.user.checkGroupAccess("administrator") and form.method EQ "assign"  and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>
			office_id=#db.param(form.office_id)#,
		</cfif>
		 <cfif structkeyexists(form, 'assign_name') and form.assign_name neq ''>inquiries_assign_name=#db.param(form.assign_name)#,</cfif>  
		 user_id = #db.param("")#, 
		 inquiries_admin_comments = #db.param(form.inquiries_admin_comments)#, 
		 <cfif qFeedback.count NEQ 0>inquiries_status_id = #db.param(3)#<cfelse>inquiries_status_id = #db.param(2)#</cfif> 
		 WHERE inquiries_id = #db.param(form.inquiries_id)# and 
		 site_id = #db.param(request.zos.globals.id)# and 
		 inquiries_deleted=#db.param(0)#
		</cfsavecontent><cfscript>qInquiry=db.execute("qInquiry");</cfscript>
		<cfset form.groupEmail=false>
		<cfscript>
		toEmail=form.assign_email; 
		</cfscript>

		<cfmail  to="#toEmail#" from="#request.fromemail#" replyto="#qGetInquiry.inquiries_email#" subject="A new lead assigned to you" type="html">
			<cfscript>
			iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
			iemailCom.getEmailTemplate();
			</cfscript>
		</cfmail>
		<cfscript>
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead assigned to #form.assign_email#, An email has been sent to notify them.");
		if(form.method EQ "userAssign"){
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/userIndex?zPageId=#form.zPageId#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
		}
		</cfscript>
	<cfelse>
		<cfsavecontent variable="db.sql">
		SELECT inquiries_email from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
		WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)# 
		</cfsavecontent><cfscript>qGetInquiry=db.execute("qGetInquiry");</cfscript> 
		<cfsavecontent variable="db.sql">
		SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# user
		WHERE site_id =#db.param(local.assignSiteId)# and 
		user_id = #db.param(local.assignUserId)#  and 
		user_deleted=#db.param(0)# 
		</cfsavecontent><cfscript>qMember=db.execute("qMember");</cfscript>
		<cfsavecontent variable="db.sql">
		SELECT count(inquiries_feedback_id) count 
		from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
		WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
		site_id = #db.param(request.zos.globals.id)#  and 
		inquiries_feedback_deleted=#db.param(0)# 
		</cfsavecontent><cfscript>qFeedback=db.execute("qFeedback");
		if(qMember.recordcount EQ 0){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "User doesn't exist.",form,true);
			if(form.method EQ "userAssign"){
				application.zcore.functions.zRedirect("/z/inquiries/admin/assign/userIndex?inquiries_id=#inquiries_id#&zPageId=#form.zPageId#&zsid="&request.zsid);
			}else{
				application.zcore.functions.zRedirect("/z/inquiries/admin/assign/index?inquiries_id=#inquiries_id#&zPageId=#form.zPageId#&zsid="&request.zsid);
			}
		}
		form.inquiries_admin_comments = trim(application.zcore.functions.zso(form, 'inquiries_admin_comments'));
		</cfscript>
		<cfsavecontent variable="db.sql">
		UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# inquiries
		 SET inquiries_assign_email = #db.param("")#,  
		<cfif form.method EQ "assign">
			office_id=#db.param(form.office_id)#,
		</cfif>
		 user_id = #db.param(qMember.user_id)#, 
		 user_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(local.assignSiteId))#, 
		 inquiries_admin_comments = #db.param(form.inquiries_admin_comments)#, 
		 <cfif qFeedback.count NEQ 0>inquiries_status_id = #db.param(3)#<cfelse>inquiries_status_id = #db.param(2)#</cfif> 
		 WHERE inquiries_id = #db.param(form.inquiries_id)#  and
		 site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)#  and 
		 inquiries_deleted=#db.param(0)#
		</cfsavecontent><cfscript>qInquiry=db.execute("qInquiry");</cfscript> 
		<cfset form.groupEmail=false>
		<cfscript>
		toEmail=qMember.user_username; 

		// processMessage here - same as note 
		savecontent variable="customNote"{
			// TODO: maybe later if i convert admin comments to feedback
			if(request.zos.isTestServer){
				echo('<table cellpadding="0" cellspacing="0" border="0"><tr><td style="background:##f7df9e; font-size:12px; padding:5px 15px 5px 15px; color:##b68500;">PRIVATE NOTE</td></tr></table>');
				echo('<p>#request.zsession.user.first_name# #request.zsession.user.last_name# (#request.zsession.user.email#) assigned you to lead ###form.inquiries_id#:</p>');
				if(form.inquiries_admin_comments NEQ ""){
					echo(form.inquiries_admin_comments);
				}
			}
		}
		if(request.zos.isTestServer){
			// this should be happening on live server when the new lead interface is all done
			request.noleadsystemlinks=true;
		}
		savecontent variable="emailHTML"{
			iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
			iemailCom.getEmailTemplate(customNote, true);
		} 
		db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)#  
		WHERE inquiries_id = #db.param(form.inquiries_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_deleted=#db.param(0)#"; 
		qInquiry=db.execute("qInquiry"); 
		if(false and request.zos.isTestServer){
			ts={  
				contact_id:request.zsession.user.contact_id,  
				debug:false,
				inquiries_id:form.inquiries_id,
				validHash:true, 
				jsonStruct:{
				   "headers":{
					  "raw":"",
					  "parsed":{ 
					  }
				   },
				   "from":{
					  "name":request.zsession.user.first_name&" "&request.zsession.user.last_name,
					  "email":request.zsession.user.email
				   },
				   "to":[
					  {
						 "name":request.zsession.user.first_name&" "&request.zsession.user.last_name,
						 "email":request.zsession.user.email,
						 "plusId":"",
						 "originalEmail":request.zsession.user.email
					  }
				   ],
				   "cc":[],
				   "bcc":[],
				   "subject":"#form.inquiries_feedback_subject#", //[Lead ###form.inquiries_id# Updated] 
				   "html":emailHTML,
				   "htmlWeb":form.inquiries_feedback_comments,
				   "htmlProcessed":"",
				   "files":[/*
					  {
						 "size":2715,
						 "filePath":"elkdgjicjkbkdbjf2.jpg",
						 "fileName":"elkdgjicjkbkdbjf.jpg"
					  }*/
				   ],
				   "plusId":"", // nothing for internal mail
				   "size":0, // measure below
				   "date":request.zos.mysqlnow,
				   "version":1,
				   "humanReplyStruct":{
					  "isHumanReply":true,
					  "humanTriggers":[],
					  "roboScore":0,
					  "roboTriggers":[],
					  "score":1,
					  "humanScore":1
				   } 
				},
				messageStruct:{
					site_id:request.zos.globals.id
				},
				filterContacts:{ managers:true },
				inquiries_status_id:form.inquiries_status_id,
				privateMessage:true,
				enableCopyToSelf:true
			};  

			// slightly inaccurate since it doesn't include all fields and attachment sizes
			ts.jsonStruct.size=len(ts.jsonStruct.subject&ts.jsonStruct.html);  
			//ts.debug=true;
			if(qInquiry.office_id NEQ "0"){
				ts.filterContacts.offices=[qInquiry.office_id];
			}
			if(structkeyexists(request.zos, 'manageLeadGroupIdList')){
				ts.filterContacts.userGroupIds=listToArray(request.zos.manageLeadGroupIdList, ",");
			}  
			//writedump(ts);    abort; 
		 
			contactCom=createobject("component", "zcorerootmapping.com.app.contact");
			rs=contactCom.processMessage(ts);  
		}else{
			// send email to the assigned user.
			toEmail=qMember.user_email;
			if(request.zos.isTestServer){
				toEmail=request.zos.developerEmailTo;
			}
			ts={
				to:toEmail,
				from:request.fromEmail,
				subject:"You're assigned to lead ###form.inquiries_id# on #request.zos.globals.shortDomain#", //#form.inquiries_feedback_subject#",
				html:emailHTML
			};
			application.zcore.email.send(ts);
		}
		</cfscript>

		<!--- <cfmail  to="#toEmail#" cc="#qMember.user_alternate_email#" from="#request.fromemail#" replyto="#qGetInquiry.inquiries_email#" subject="A new lead assigned to you" type="html">
			<cfscript>
			iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
			iemailCom.getEmailTemplate();
			</cfscript>
		</cfmail> --->
		<cfscript>
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead assigned to #qMember.member_first_name# #qMember.member_last_name#, An email has been sent to this user to notify them."); 
		if(form.method EQ "userAssign"){
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/userIndex?zPageId=#form.zPageId#&zsid="&request.zsid);
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
		}
		</cfscript>
	</cfif>
</cffunction>
</cfoutput>
</cfcomponent>