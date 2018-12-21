<cfcomponent>
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
		<!--- office search is only useful when there is more then one office --->
		<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1> 
			<cfscript> 
			if(application.zcore.user.checkGroupAccess("administrator")){ 
				ts={
					sortBy:"name"
				};
				arrOffice=application.zcore.user.getOffices(ts);
			}else{
				ts={
					ids:listToArray(request.zsession.user.office_id, ","),
					sortBy:"name"
				};
				arrOffice=application.zcore.user.getOffices(ts); 
			} 
			</cfscript> 
			<cfif arrayLen(arrOffice) GT 0>
		 		<div class="z-float">
		 			<h3 style="color:##369; font-weight:normal;">1) Select An Office:</h3>
		 		</div>

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
			</cfif> 
		</cfif>
	

	 	<div class="z-float">
			<h3 style="color:##369; font-weight:normal;">
				<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>2a) </cfif>
				Assign to a user on this web site:
			</h3>
		</div>
		<cfscript> 
		if(request.zsession.user.office_id NEQ ""){
			qAgents=application.zcore.user.getUsersByOfficeIdList(request.zsession.user.office_id, request.zos.globals.id);
		}else{
			if(arguments.form_type EQ "user"){
				// only allow assigning to themselves
				db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
				WHERE site_id=#db.param(application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id))# and 
				user_deleted = #db.param(0)# and
				user_id =#db.param(request.zsession.user.id)#";
				qAgents=db.execute("qAgents", "", 10000, "query", false);
			}else{
				// TODO: find only the users this user should have access to 
				db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
				WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
				user_deleted = #db.param(0)# and
				user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# 
				 and (user_server_administrator=#db.param(0)#)
				ORDER BY member_first_name ASC, member_last_name ASC";
				qAgents=db.execute("qAgents", "", 10000, "query", false);
			} 
		} 
		</cfscript> 
		<script type="text/javascript">
		/* <![CDATA[ */
		function showAgentPhoto(id){
			var d1=document.getElementById("agentPhotoDiv");
			if(id!="" && arrAgentPhoto[id]!=""){
				$(d1).show();
				d1.innerHTML='<img src="'+arrAgentPhoto[id]+'" width="100">';
			}else{
				$(d1).hide();
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
		<cfif form.method EQ "index" and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>
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
				form.user_id=application.zcore.functions.zso(form, 'user_id');
				// when user selects office, the user drop down should change to show only users in that office.
				if(form.user_id NEQ 0){
					form.inquiries_assign_email="";
					form.inquiries_assign_name="";
				}
				form.user_id = form.user_id&"|"&form.user_id_siteIDType; 
				echo('<select name="user_id" id="user_id" size="1" onchange="showAgentPhoto(this.options[this.selectedIndex].value);">');
				echo('<option value="" data-office-id="">-- Select --</option>');
				for(row in qAgents){
					userGroupName=userGroupCom.getGroupDisplayName(row.user_group_id, row.site_id);
					echo('<option value="'&row.user_id&"|"&row.site_id&'" data-office-id=",'&row.office_id&',"');
					if(form.user_id EQ row.user_id&"|"&application.zcore.functions.zGetSiteIdType(row.site_id)){
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
		<div class="z-float">
			<h3 style="color:##369; font-weight:normal;">
			<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>2b) </cfif>
			Or assign this lead to anyone outside the web site:</h3>
		</div>
		<div style="width:100%; margin-bottom:20px;float:left;"> 
			<p>External Name:<br><input type="text" name="assign_name" style="min-width:100%; width:100%;" value="#application.zcore.functions.zso(form, 'inquiries_assign_name')#" /></p>
			<p>External Email(s):<br>
			<input type="text" name="assign_email" style="min-width:100%; width:100%;" value="#application.zcore.functions.zso(form, 'inquiries_assign_email')#" /><br>
			(Comma separate multiple emails)</p>
		</div>
		<div id="agentPhotoDiv"></div> 
	</div>

</cffunction>

<cffunction name="getAssignContact" localmode="modern" access="remote">
	<cfscript>
		form.contact_assigned_user_id = application.zcore.functions.zso(form, 'contact_assigned_user_id', true);
		var db=request.zos.queryObject;
		var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin"); 
	</cfscript>
	<div style="float:left;"> 
		<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1> 
			<cfscript> 
			if(application.zcore.user.checkGroupAccess("administrator")){ 
				ts={
					sortBy:"name"
				};
				arrOffice=application.zcore.user.getOffices(ts);
			}else{
				ts={
					ids:listToArray(request.zsession.user.office_id, ","),
					sortBy:"name"
				};
				arrOffice=application.zcore.user.getOffices(ts); 
			} 
			</cfscript> 
			<cfif arrayLen(arrOffice) GT 0>
		 		<div class="z-float">
		 			<h3 style="color:##369; font-weight:normal;">1) Select An Office:</h3>
		 		</div>

				<p>An office is a group of 1 or more users who will be able to access this lead.</p>
				<div style="float:left; max-width:100%; padding-right:10px; padding-bottom:10px; ">
					<cfscript> 
					selectStruct = StructNew();
					selectStruct.name = "office_id"; 
					selectStruct.arrData = arrOffice;
					selectStruct.size=1; 
					selectStruct.onChange="assignLeadSelectOffice();";
					selectStruct.queryLabelField = "office_name";
					selectStruct.inlineStyle="width:100%; max-width:100%;";
					selectStruct.queryValueField = 'office_id';

					if(arrayLen(arrOffice) GT 3){
						echo('Type to filter offices: <input type="text" name="#selectStruct.name#_InputField" onkeyup="setTimeout(function(){ assignLeadSelectOffice();}, 100); " id="#selectStruct.name#_InputField" value="" style="min-width:auto;width:200px; max-width:100%; margin-bottom:5px;"><br />Select Office:<br>');
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
			</cfif> 
		</cfif>
	

	 	<div class="z-float">
			<h3 style="color:##369; font-weight:normal;">
				<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>2a) </cfif>
				Assign to a user on this web site:
			</h3>
		</div>
		<cfscript>
		if(request.zsession.user.office_id NEQ "" ){
			qAgents=application.zcore.user.getUsersByOfficeIdList(request.zsession.user.office_id, request.zos.globals.id);
		}else{
			if(form.method NEQ "userEdit"){
				db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
				WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# 
				AND site_id=#db.param(request.zos.globals.id)#
				AND user_deleted = #db.param(0)#";
				qAgents=db.execute("qAgents");
			}else{

				db.sql="SELECT A.*, A.site_id userSiteId 
				FROM  #db.table("user", request.zos.zcoreDatasource)# A,
					#db.table("user", request.zos.zcoreDatasource)# B
				WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL("A"))# 
				AND	A.user_deleted = #db.param(0)# 
				AND A.site_id=#db.param(request.zos.globals.id)#
				AND B.site_id=#db.param(request.zos.globals.id)#
				AND A.user_group_id <> #db.param(userGroupCom.getGroupId('user',request.zos.globals.id))# 
			 	AND (A.user_server_administrator=#db.param(0)#)
			 	AND B.user_id = #db.param(request.zsession.user.id)#
			 	AND A.office_id = B.office_id
				ORDER BY member_first_name ASC, member_last_name ASC";
				qAgents=db.execute("qAgents"); 
			} 
		} 
		</cfscript> 
		<script type="text/javascript">
			function showAgentPhoto(id){
				var d1=document.getElementById("agentPhotoDiv");
				if(id!="" && arrAgentPhoto[id]!=""){
					$(d1).show();
					d1.innerHTML='<img src="'+arrAgentPhoto[id]+'" width="100">';
				}else{
					$(d1).hide();
					d1.innerHTML="";    
				}
			}
			function assignLeadSelectOffice(){ 
				var officeElement = document.getElementById("office_id");
				var userElement=document.getElementById("contact_assigned_user_id"); 
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
				userElement.selectedIndex = 0;
			}
			var arrAgentPhoto=new Array();
			<cfif qAgents.recordcount>
				<cfloop query="qAgents">
				arrAgentPhoto["#qAgents.user_id#|#qAgents.site_id#"]=<cfif qAgents.member_photo NEQ "">"#jsstringformat('#application.zcore.functions.zvar('domain',qAgents.userSiteId)##request.zos.memberImagePath##qAgents.member_photo#')#"<cfelse>""</cfif>;
				</cfloop>
			</cfif>
		</script>  
		<cfif form.method EQ "index" and application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>
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
			echo('<select name="contact_assigned_user_id" id="contact_assigned_user_id" size="1" onchange="showAgentPhoto(this.options[this.selectedIndex].value);">');
			echo('<option value="" data-office-id="">-- Select --</option>');
			for(row in qAgents){
				userGroupName=userGroupCom.getGroupDisplayName(row.user_group_id, row.site_id);
				echo('<option value="'&row.user_id&"|"&row.site_id&'" data-office-id=",'&row.office_id&',"');
				if(form.contact_assigned_user_id EQ row.user_id AND form.contact_assigned_user_id_siteidtype EQ application.zcore.functions.zGetSiteIdType(row.site_id)){
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
	<div class="z-float">
		<h3 style="color:##369; font-weight:normal;">
		<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>2b) </cfif>
		Or assign this lead to anyone outside the web site:</h3>
	</div>
	<div style="width:100%; margin-bottom:20px;float:left;"> 
		<p>External Name:<br><input type="text" name="assign_name" style="min-width:100%; width:100%;" value="#application.zcore.functions.zso(form, 'inquiries_assign_name')#" /></p>
		<p>External Email(s):<br>
		<input type="text" name="assign_email" style="min-width:100%; width:100%;" value="#application.zcore.functions.zso(form, 'inquiries_assign_email')#" /><br>
		(Comma separate multiple emails)</p>
	</div>
	<div id="agentPhotoDiv"></div> 
</div>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>  
	var db=request.zos.queryObject;  
	application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
	application.zcore.functions.zSetModalWindow();  
	var userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	application.zcore.functions.zSetPageHelpId("4.1.2");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Leads");
	form.inquiries_id=application.zcore.functions.zso(form, 'inquiries_id');
	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	db.sql="SELECT * FROM (#db.table("inquiries_status", request.zos.zcoreDatasource)# 
	, #db.table("inquiries", request.zos.zcoreDatasource)# 
	) 
	LEFT JOIN #db.table("inquiries_type", request.zos.zcoreDatasource)# 
	ON inquiries.inquiries_type_id = inquiries_type.inquiries_type_id and inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries.inquiries_type_id_siteIDType"))# and 
	inquiries_type_deleted = #db.param(0)#
	WHERE inquiries.site_id = #db.param(request.zos.globals.id)#  and 		
	inquiries.inquiries_status_id = inquiries_status.inquiries_status_id and 
	inquiries_deleted = #db.param(0)# and 
	inquiries_status_deleted = #db.param(0)# and 
	inquiries.inquiries_status_id NOT IN (#db.trustedSQL("4,5,0,7")#) and 
	 inquiries_id = #db.param(form.inquiries_id)#  ";
	qinquiry=db.execute("qinquiry"); 
	if(qinquiry.recordcount EQ 0){		
		request.zsid = application.zcore.status.setStatus(Request.zsid, "This inquiry doesn't exist.", false,true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/manage-inquiries/index?zPageId=#form.zPageId#&zsid="&request.zsid);
	}else{
		application.zcore.functions.zQueryToStruct(qinquiry);
	}
	application.zcore.functions.zstatushandler(request.zsid,true);

	db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE inquiries_id <> #db.param(form.inquiries_id)# and 
	inquiries_email = #db.param(form.inquiries_email)# and
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_deleted = #db.param(0)# and 
	(user_id <> #db.param(0)# or 
	inquiries_assign_email <> #db.param('')#) 
	ORDER BY inquiries_datetime DESC   ";
	qPrevious=db.execute("qPrevious");
	if(qPrevious.recordcount NEQ 0){ 
		if(qPrevious.user_id NEQ 0){
			db.sql="select * from #db.table("user", request.zos.zcoreDatasource)#
			WHERE user_id = #db.param(qPrevious.user_id)# and 
			user_deleted=#db.param(0)# and 
			site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdFromSiteIdType(qPrevious.user_id_siteIDType))#";
			qUserTemp=db.execute("qUserTemp");
			if(qUserTemp.recordcount NEQ 0){
				previousAssignee=qUserTemp.user_first_name&" "&qUserTemp.user_last_name&" "&qUserTemp.user_username;
			}else{
				previousAssignee="N/A";
			}
		}else{
			previousAssignee='#qPrevious.inquiries_assign_name# #qPrevious.inquiries_assign_email# ';
		} 
		previousDate=dateformat(qPrevious.inquiries_datetime, "m/d/yy ")&timeformat(qPrevious.inquiries_datetime, 'h:mm tt');
	}else{
	  previousAssignee="N/A";
	  previousDate="";
	}
	//}
	</cfscript>
	<form class="zFormCheckDirty" name="sendEmailForm" id="sendEmailForm" action="/z/inquiries/admin/assign/<cfif form.method EQ "index">assign<cfelse>userAssign</cfif>?inquiries_id=#form.inquiries_id#&amp;zPageId=#form.zPageId#" method="post"> 
		<div class="z-float z-p-10 z-bg-white z-index-3" style="visibility:hidden;">
			<button type="submit" name="submitForm" class="z-manager-search-button" style="font-size:150%;">Assign</button>
			<button type="button" name="cancel" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Cancel</button> 
		</div> 
		<div class="z-float z-p-10 z-bg-white z-index-3" style="position:fixed;">
			<button type="submit" name="submitForm" class="z-manager-search-button" style="font-size:150%;">Assign</button>
			<button type="button" name="cancel" onclick="window.parent.zCloseModal();" class="z-manager-search-button">Cancel</button> 
		</div> 
		<div class="z-manager-edit-errors z-float"></div>
	  	<div class="z-1of2 z-fluid-at-767 z-p-0" style="padding:5px;"> 
		 	<cfscript>
			if(form.method EQ "userAssign"){
				getAssignLead("user");
			}else{
				getAssignLead("member");
			}
			</cfscript> 
		
 		<div class="z-float">
			<h3 style="color:##369; font-weight:normal;">Private Comments (Optional)</h3>
			<cfif application.zcore.functions.zvar("enablePlusEmailRouting", request.zos.globals.id, 0) EQ 1>
				<p>Only people who can manage this lead will see these comments.</p>
			<cfelse>
				<p>To prevent accidental sharing of private notes with public contacts, these notes will not be visible unless the assigned user logs in to view the lead online.  If you assign the lead to an email instead of a user, they won't be able to see the note at all.</p>
			</cfif> 
			<cfscript>
			htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
			htmlEditor.instanceName	= "inquiries_admin_comments";
			htmlEditor.value			= "";
			htmlEditor.width			= "100%";
			htmlEditor.height		= 150;
			htmlEditor.createSimple();
			</cfscript> 
		</div>
	</div>
	<div class="z-1of2 z-fluid-at-767 z-p-0" style="padding:5px;"> 
		<h2 style="font-weight:normal; color:##369;">Selected Lead</h2>
		<!--- <p>Leads are matched by email and phone number to help you assign to the same agent if desired.</p> --->
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
			<th style="width:150px;">Name</th>
			<td>#form.inquiries_first_name# #form.inquiries_last_name#</td>
			</tr>
			<tr>
			<th>Phone</th>
			<td>#form.inquiries_phone1#</td>
			</tr>
			<tr>
				<th>Email</th>
				<td><cfif len(form.inquiries_email) NEQ 0>#form.inquiries_email#</cfif></td>
			</tr>
			<tr> 
				<th>Date Received</th>
				<td>#DateFormat(form.inquiries_datetime,'m/d/yy')&' '&TimeFormat(form.inquiries_datetime,'h:mm tt')#</td> 
			</tr>
		</table>
		<cfif previousDate NEQ "">
			<div class="z-float z-mt-10">
				<h3 style="color:##369; font-weight:normal">Previously Assigned To:</h3>
			</div>
			<table style="width:100%; border-spacing:0px;" class="table-list">
			<cfscript>
			if(qPrevious.office_id NEQ 0){
				ts={
					ids=[qPrevious.office_id]
				};
				arrOffice=application.zcore.user.getOffices(ts);
				if(arrayLen(arrOffice)){
					echo('<tr>
					<th>Office:</th>
					<td>#arrOffice[1].office_name#</td>
					</tr>');
				}
			}
			</cfscript>
			<tr>
			<th style="width:150px;">Name:</th>
			<td>#previousAssignee#</td>
			</tr>
			<tr>
			<th>Date:</th>
			<td>#previousDate#</td>
			<tr>
			<cfscript>
			</cfscript>
			</tr>
		</cfif>
		</table>
  	</div>
	</form>
	
	
	<script type="text/javascript">
	zArrDeferredFunctions.push( function() {  
		function emailSentCallback(r){
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
		});
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
	form.fromSource=application.zcore.functions.zso(form, 'fromSource');
	form.office_id=application.zcore.functions.zso(form, 'office_id', true);
	form.assign_name=application.zcore.functions.zso(form, 'assign_name'); 
	form.assign_email=application.zcore.functions.zso(form, 'assign_email');
 
	form.zPageId=application.zcore.functions.zso(form, 'zPageId');
	if(application.zcore.functions.zso(form, 'user_id') EQ '' and application.zcore.functions.zso(form, 'assign_email') EQ ''){
		application.zcore.status.setStatus(request.zsid,"You forgot to type an email address or select a user from the drop down menu.",form,true);
		application.zcore.status.displayReturnJson(request.zsid);
	}
	if(application.zcore.functions.zso(form, 'user_id') CONTAINS "|"){
		form.user_id_siteIDType=listGetAt(form.user_id, 2, "|");
		form.user_id=listGetAt(form.user_id, 1, "|");
		form.contact_assigned_user_id=form.user_id;
		form.contact_assigned_user_id_siteIdType=form.user_id_siteIdType;
	}else{
		form.user_id=0;
		form.user_id_siteIDType=0;
		form.contact_assigned_user_id=0;
		form.contact_assigned_user_id_siteIdType=0;
	} 

	db.sql="SELECT * from #db.table("inquiries", request.zos.zcoreDatasource)#  
	WHERE inquiries_id = #db.param(form.inquiries_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_deleted=#db.param(0)#"; 
	qInquiry=db.execute("qInquiry");  
	
	db.sql="SELECT count(inquiries_feedback_id) count 
	from #db.table("inquiries_feedback", request.zos.zcoreDatasource)# inquiries_feedback 
	WHERE inquiries_id = #db.param(form.inquiries_id)#  and 
	inquiries_feedback_deleted = #db.param(0)# and 
	inquiries_feedback_type=#db.param(1)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qFeedback=db.execute("qFeedback");
	if(qFeedback.recordcount NEQ 0 and qFeedback.count NEQ 0){
		newStatusId=3;
	}else{
		newStatusId=2;
	}

 
	if(application.zcore.functions.zso(form, 'assign_email') NEQ ''){
		arrEmail=listToArray(form.assign_email, ",");
		arrEmailFinal=[];
		for(i=1;i LTE arraylen(arrEmail);i++){
			e=trim(arrEmail[i]);
			if(e NEQ ""){
				if(application.zcore.functions.zEmailValidate(e) EQ false){
					application.zcore.status.setStatus(request.zsid,"Invalid email address format: #arrEmail[i]#",form,true);
					application.zcore.status.displayReturnJson(request.zsid); 
				}
				arrayAppend(arrEmailFinal, e);
			}
		}
		form.assign_email=arraytolist(arrEmailFinal, ", ");
	}else{
		db.sql="SELECT * FROM #db.table("user", request.zos.zcoreDatasource)# 
		WHERE site_id =#db.param(application.zcore.functions.zGetSiteIdFromSiteIdType(form.user_id_siteIDType))# and 
		user_id = #db.param(form.user_id)#  and 
		user_deleted=#db.param(0)# ";
		qMember=db.execute("qMember");

 
		if(qMember.recordcount EQ 0){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "User doesn't exist.",form,true);
			if(form.method EQ "userAssign"){
				application.zcore.functions.zRedirect("/z/inquiries/admin/assign/userIndex?inquiries_id=#inquiries_id#&zPageId=#form.zPageId#&zsid="&request.zsid);
			}else{
				application.zcore.functions.zRedirect("/z/inquiries/admin/assign/index?inquiries_id=#inquiries_id#&zPageId=#form.zPageId#&zsid="&request.zsid);
			}
		}
		form.assign_name=qMember.user_first_name&" "&qMember.user_last_name;
		form.assign_email=qMember.user_username;
	}
	if(structkeyexists(request.zos, 'enableNewLeadManagement')){
		if(qInquiry.contact_id NEQ 0){
			db.sql="UPDATE #db.table("contact", request.zos.zcoreDatasource)# SET 
			contact_assigned_user_id=#db.param(form.contact_assigned_user_id)#, 
			contact_assigned_user_id_siteIdType=#db.param(form.contact_assigned_user_id_siteIdType)# 
			WHERE contact_id = #db.param(qInquiry.contact_id)# and 
			contact_deleted=#db.param(0)# and 
			site_id=#db.param(request.zos.globals.id)#";
			db.execute("qUpdateContact");
		}
	}
		 
	db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# SET ";
	if(form.user_id EQ 0){
		db.sql&=" inquiries_assign_email = #db.param(form.assign_email)#, 
		inquiries_assign_name=#db.param(form.assign_name)#, 
		user_id = #db.param("")#, ";
	}else{
		db.sql&=" 
		inquiries_assign_name=#db.param("")#,
		inquiries_assign_email = #db.param("")#, 
		user_id = #db.param(form.user_id)#, 
		user_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIdType(form.user_id_siteIDType))#, "; 
	}
	if(application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1){
		db.sql&=" office_id=#db.param(form.office_id)#, ";   
	} 
	db.sql&=" inquiries_status_id = #db.param(newStatusId)#,";
	db.sql&=" inquiries_updated_datetime=#db.param(request.zos.mysqlnow)# ";
	db.sql&=" WHERE inquiries_id = #db.param(form.inquiries_id)# and 
	 site_id = #db.param(request.zos.globals.id)# and 
	 inquiries_deleted=#db.param(0)# ";
	db.execute("qUpdate");

	form.groupEmail=false;
	toEmail=form.assign_email;   

	if(application.zcore.functions.zvar("enablePlusEmailRouting", request.zos.globals.id, 0) EQ 1){
		// this should be happening on live server when the new lead interface is all done
		request.noleadsystemlinks=true;
	}

	if(form.assign_name EQ ""){
		name=form.assign_email;
	}else{
		name=form.assign_name;
	}
	subject="Lead ###form.inquiries_id# assigned to #name# on #request.zos.globals.shortDomain#";
	savecontent variable="customNote"{ 
		echo('<p>#subject#</p>');
		if(application.zcore.functions.zvar("enablePlusEmailRouting", request.zos.globals.id, 0) EQ 1){
			echo('<table cellpadding="0" cellspacing="0" border="0"><tr><td style="background:##f7df9e; font-size:12px; padding:5px 15px 5px 15px; color:##b68500;">PRIVATE NOTE</td></tr></table>');
			if(form.inquiries_admin_comments NEQ ""){
				echo(form.inquiries_admin_comments);
			} 
		}
	}
	savecontent variable="htmlWeb"{ 
		echo('<p>&nbsp;</p>');
		echo(form.inquiries_admin_comments);
	} 
	savecontent variable="emailHTML"{
		iemailCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
		iemailCom.getEmailTemplate(customNote, true);
	} 

	contactCom=createobject("component", "zcorerootmapping.com.app.contact");
	ts=contactCom.getDefaultMessageConfig();
	ts.contact_id=request.zsession.user.contact_id;
	//ts.debug=false;
	ts.inquiries_id=form.inquiries_id;
	ts.jsonStruct.subject=subject;
	ts.jsonStruct.html=emailHTML;
	ts.jsonStruct.htmlWeb=htmlWeb;
	ts.messageStruct.site_id=request.zos.globals.id;
	ts.filterContacts.managers=true; 
	ts.privateMessage=true;
	ts.dontEmailFromContact=true;
	ts.enableCopyToSelf=true;
	ts.jsonStruct.to=[{
		name:form.assign_name,
		email:form.assign_email
	}];

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
 
	rs=contactCom.processMessage(ts);   
	application.zcore.functions.zReturnJson({success:true});
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>