<cfcomponent>
<cfoutput>
<!--- 
TODO:  
cron job for import - can we combine it with another one to reduce active CFML threads?
sending of autoresponder - not sure if it works on test server, might work on live
not important yet: create contacts at same time as create lead (use same function to achieve it?) - avoid duplicates?

/z/inquiries/admin/import-leads/index
 --->

<cffunction name="init" access="remote" localmode="modern"> 
	<cfscript>
	db=request.zos.queryObject;
	manageInquiriesCom=createObject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
	manageInquiriescom.loadManageLeadGroupData();
	if(not application.zcore.user.checkGroupAccess("user")){
		manageInquiriesCom.checkManageLeadAccess({ errorMessage:"You don't have access or need to login."});
	}
	request.importPath=request.zos.globals.privateHomeDir&"inquiries-import-backup/";
	request.userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");

	request.arrRequired=["First Name", "Last Name", "Email", "Phone"];
	request.arrOptional=["Cell Phone", "Home Phone", "Address", "Address 2", "City", "State", "Country", "Postal Code", "Interested In Model", "Interested In Category"];  
	request.fieldMap={
		"First Name":"inquiries_first_name",
		"Last Name":"inquiries_last_name",
		"Email":"inquiries_email",
		"Phone":"inquiries_phone1",
		"Cell Phone":"inquiries_custom_json",
		"Home Phone":"inquiries_custom_json",
		"Address":"inquiries_address",
		"Address 2":"inquiries_address2",
		"City":"inquiries_city",
		"State":"inquiries_state",
		"Country":"inquiries_country",
		"Postal Code":"inquiries_custom_json",
		"Interested In Model":"inquiries_interested_in_model",
		"Interested In Category":"inquiries_interested_in_category"
	};
	db.sql="SELECT * from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
	WHERE  inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zOS.globals.id)#) and 
	inquiries_type_deleted = #db.param(0)# ";
	if(not application.zcore.app.siteHasApp("listing")){
		db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
	}
	if(not application.zcore.app.siteHasApp("rental")){
		db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
	}
	db.sql&=" ORDER BY inquiries_type_name ASC ";
	request.qTypes=db.execute("qTypes");
	db.sql="SELECT * 
	from #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# , 
	#db.table("inquiries_type", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_type.inquiries_type_id = inquiries_autoresponder.inquiries_type_id and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_autoresponder.inquiries_type_id_siteidtype"))# and 
	inquiries_autoresponder.site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_deleted = #db.param(0)# and 
	inquiries_type_deleted = #db.param(0)# ";
	if(not application.zcore.user.checkGroupAccess("administrator")){
		db.sql&=" and inquiries_autoresponder_allow_user_import=#db.param(1)# ";
	}
	db.sql&=" ORDER BY inquiries_type_name ASC ";
	request.qAutoresponder=db.execute("qAutoresponder", "", 10000, "query", false); 

	request.arrOffice=[];

	if(form.method EQ "userAssign"){
		form_type="user";
	}else{
		form_type="member";
	}
	if(application.zcore.user.checkGroupAccess("user")){
		if(request.zsession.user.office_id NEQ ""){
			request.qUser=application.zcore.user.getUsersByOfficeIdList(request.zsession.user.office_id, request.zos.globals.id);
		}else{
			if(form_type EQ "user"){
				// only allow assigning to themselves
				db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
				WHERE site_id=#db.param(application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id))# and 
				user_deleted = #db.param(0)# and
				user_id =#db.param(request.zsession.user.id)#";
				request.qUser=db.execute("qUser", "", 10000, "query", false);
			}else{
				// TODO: find only the users this user should have access to 
				db.sql="SELECT *, user.site_id userSiteId FROM  #db.table("user", request.zos.zcoreDatasource)#
				WHERE #db.trustedSQL(application.zcore.user.getUserSiteWhereSQL())# and 
				user_deleted = #db.param(0)# and
				user_group_id <> #db.param(request.userGroupCom.getGroupId('user',request.zos.globals.id))# 
				 and (user_server_administrator=#db.param(0)#)
				ORDER BY member_first_name ASC, member_last_name ASC";
				request.qUser=db.execute("qUser", "", 10000, "query", false);
			} 
		} 
		if(application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1){
			if(application.zcore.user.checkGroupAccess("administrator")){ 
				ts={
					sortBy:"name"
				};
				request.arrOffice=application.zcore.user.getOffices(ts);
			}else{
				ts={
					ids:listToArray(request.zsession.user.office_id, ","),
					sortBy:"name"
				};
				request.arrOffice=application.zcore.user.getOffices(ts);  
			} 
		} 
	}
	</cfscript>
</cffunction>

<cffunction name="userIndex" access="remote" localmode="modern" roles="user">  
	<cfscript> 
	index();
	</cfscript>
</cffunction>

<cffunction name="userSchedule" access="remote" localmode="modern" roles="user">  
	<cfscript> 
	schedule();
	</cfscript>
</cffunction>


<cffunction name="userDownloadFile" access="remote" localmode="modern" roles="user">  
	<cfscript> 
	downloadFile();
	</cfscript>
</cffunction>

<cffunction name="downloadFile" access="remote" localmode="modern" roles="administrator">  
	<cfscript> 
	init();
	form.inquiries_import_file_id=application.zcore.functions.zso(form, 'inquiries_import_file_id', true);
	db=request.zos.queryObject;
	db.sql="select * from #db.table("inquiries_import_file", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_import_file_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# 
	";
	getUserLeadFilterSQL(db);
	qImport=db.execute("qImport");
	if(qImport.recordcount EQ 0){
		application.zcore.functions.z404("Invalid file");
	}
	application.zcore.functions.zheader( 'Content-Disposition', 'attachment; filename=' & replace(urlencodedformat(replace(qImport.inquiries_import_file_filename, ",", " ", "all")), '%2E', '.', 'all') );
	content type="application/binary" deletefile="no" file="#request.importPath&qImport.inquiries_import_file_filename#";
	abort;
	</cfscript>
</cffunction>


<cffunction name="getUserLeadFilterSQL" localmode="modern" access="public">
	<cfargument name="db" type="component" required="yes">
	<cfscript>
	db=arguments.db;
	if(not application.zcore.user.checkGroupAccess("administrator")){
		// db.sql&=" and  ";
		//request.userIdList
		db.sql&=(' and ( ');

		if(request.zsession.user.office_id NEQ ""){
			db.sql&=(' (inquiries_import_file_import_user_id=#db.param(0)# and inquiries_import_file.office_id IN (#db.trustedSQL(request.zsession.user.office_id)#) ) or ');
		}
		if(request.userIdList NEQ ""){
			db.sql&=(' (inquiries_import_file_import_user_id IN (#db.trustedSQL(request.userIdList)#) and inquiries_import_file_import_user_id_siteIdType=#db.param(1)#) or ');
		}
		// current user 
		db.sql&=(' (inquiries_import_file_import_user_id = #db.param(request.zsession.user.id)# and 
		inquiries_import_file_import_user_id_siteIDType=#db.param(application.zcore.user.getSiteIdTypeFromLoggedOnUser())#)
		) ');
	}
	</cfscript>
</cffunction>


<cffunction name="index" access="remote" localmode="modern" roles="administrator">  
	<cfscript>
	init();
	db=request.zos.queryObject;
	db.sql="select *  from #db.table("inquiries_import_file", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("user", request.zos.zcoreDatasource)# user ON 
	user.user_id = inquiries_import_file.inquiries_import_file_import_user_id and 
	user.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_import_file.inquiries_import_file_import_user_id_siteidtype"))# and 
	user_deleted = #db.param(0)#
	WHERE 
	inquiries_import_file_deleted=#db.param(0)# and 
	inquiries_import_file.site_id = #db.param(request.zos.globals.id)# 
	";
	getUserLeadFilterSQL(db);
	qImport=db.execute("qImport");   

	application.zcore.functions.zStatusHandler(request.zsid);

	echo('<h2>Lead Import Log</h2>');
	echo('<p><a href="/z/inquiries/admin/import-leads/');
	if(form.method EQ "index"){
		echo("schedule");
	}else{
		echo("userSchedule");
	}
	echo('" class="z-manager-search-button">New Import</a>');
	if(request.zos.isTestServer){
		echo(' <a href="/z/inquiries/admin/import-leads/import" target="_blank" class="z-manager-search-button">Manually Run Import Cron Job</a>');
	}
	echo('</p>');

	if(qImport.recordcount EQ 0){
		echo('<p>No leads have been imported here before.</p>');
	}else{
		echo('<table class="table-list">
			<tr>
				<th>ID</th>
				<th>Uploaded By User</th>
				<th>Name</th>
				<th>File</th>
				<th>Leads Imported</th>
				<th>Leads with Errors</th>
				<th>Total Leads</th>
				<th>Status</th> 
				<th>Last Updated</th> 
				<th>Admin</th>
			</tr>');
		for(row in qImport){
			echo('<tr>');
			echo('<td>#row.inquiries_import_file_id#</td>');
			echo('<td>#row.user_first_name&" "&row.user_last_name# (<a href="mailto:#row.user_username#">#row.user_username#</a>)</td>');
			echo('<td>#row.inquiries_import_file_name#</td>');
			echo('<td>');
			if(form.method EQ "userIndex"){
				echo('<a href="/z/inquiries/admin/import-leads/userDownloadFile?inquiries_import_file_id=#row.inquiries_import_file_id#" target="_blank">#row.inquiries_import_file_filename#</a>');
			}else{
				echo('<a href="/z/inquiries/admin/import-leads/downloadFile?inquiries_import_file_id=#row.inquiries_import_file_id#" target="_blank">#row.inquiries_import_file_filename#</a>');
			}
			echo('</td>'); 
			echo('<td>#row.inquiries_import_file_import_count#</td>');
			echo('<td>#row.inquiries_import_file_error_count#</td>');
			echo('<td>#row.inquiries_import_file_record_count#</td>');
			echo('<td>');
			if(row.inquiries_import_file_status EQ 4){
				echo("Import cancelled");
			}else if(row.inquiries_import_file_status EQ 3){
				echo("Import completed");
			}else if(row.inquiries_import_file_status EQ 2){
				echo("Import failed with #row.inquiries_import_file_error_count# errors out of #row.inquiries_import_file_record_count# records.");
			}else if(row.inquiries_import_file_status EQ 1){
				echo("Import is running");
			}else if(row.inquiries_import_file_status EQ 0){
				echo("Import is scheduled");
			}
			echo('</td>');
			echo('<td>#dateformat(row.inquiries_import_file_updated_datetime, "m/d/yy")&" at "&timeformat(row.inquiries_import_file_updated_datetime, "h:mmtt")#</td>'); 
			echo('<td>');
			if(row.inquiries_import_file_status LTE 1){
				echo('<a href="/z/inquiries/admin/import-leads/cancelImport?inquiries_import_file_id=#row.inquiries_import_file_id#">Cancel</a>');
			}
			echo('</td>');
			echo('</tr>');
		}
		echo('</table>');
	}
	</cfscript>
</cffunction>

<cffunction name="userInstructions" access="remote" localmode="modern" roles="user">  
	<cfscript>
	init();
	</cfscript>
</cffunction>

<cffunction name="instructions" access="remote" localmode="modern" roles="administrator">  
	<cfscript>
	init();
	</cfscript>
	<h2>Import Lead Instructions</h2>
	<div class="z-float z-t-18">
		<p><strong>You must follow the instructions below.</strong></h3> 
		<p>The first row of the tab delimited file should contain the required fields and as many optional fields as you wish from the list of fields below. You must include the required field columns even if some of them will be empty.  You must save the spreadsheet as a tab delimited .txt format.  Typically, this is an option when you use the "Save as" feature of your spreadsheet software.  The file must have no fields with line breaks.  Any fields that are too long may be cut off at the end to fit the allowed size in the database.</p> 
		<p>If you upload an invalid format, the system will show there was an error and not import any data.</p>
		<p>You can't undo an import once it is submitted. Make sure you are uploading the correct information and not importing duplicate records.</p>
		<p>To protect our system, we schedule the leads to be imported on a first come first served basis.  You will receive an email when the import is complete and the status will also be listed in the import log in the manager.  Please don't submit the same data twice.  Usually the leads will finish importing in a few minutes for a file with less then 100 records.</p>
		<h3>Required File Format</h3>
		<p>Copy and paste these field names to the top row of your spreadsheet.  Any file without a correct header will be rejected.  Any extra columns that don't match exactly will not be imported. Any row that doesn't have at least one of the required fields filled in will not be skipped.</p>
		<h3>Supported Fields</h3>
		<p>Copy and paste the field names to the first row of your spreadsheet.</p>
		<p>Required fields:<br /><textarea type="text" cols="100" rows="2" name="a1">#arrayToList(request.arrRequired, chr(9))#</textarea></p>
		<p>Optional fields:<br /><textarea type="text" cols="100" rows="2" name="a2">#arrayToList(request.arrOptional, chr(9))#</textarea></p> 

		<h2>Example Files</h2>
		<p><a href="/z/a/member/spreadsheet-example.xlsx" target="_blank">Excel Format</a> - must be saved as tab delimited file with no field quotes</p> 
	</div>
	
</cffunction>

<cffunction name="schedule" access="remote" localmode="modern" roles="administrator">  
	<cfscript>
	init();
	db=request.zos.queryObject;  

	application.zcore.template.setTag("title", "Import Leads");
	// application.zcore.functions.zSetPageHelpId("2.7.1.1");  
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<p><a href="/z/inquiries/admin/import-leads/index">Import Log</a> / </p>
	<h2>Schedule New Lead Import</h2>
	<p>* denotes required field</p>
	<form id="importLeadForm" class="zFormCheckDirty" action="" enctype="multipart/form-data" method="post">
		<h3>Your Notification Email *</h3>
		<p>We will notify you at this email address when the leads are done importing and only for that purpose.</p>
		<p><input type="email" name="inquiries_import_file_email" style="width:250px; max-width:100%;" value="#htmleditformat(request.zsession.user.email)#" /></p> 
		<h3>Import Name</h3>
		<p>Enter a name for the import for future reference</h3>
		<p><input type="text" style="width:100%; max-width:350px;" name="inquiries_import_file_name" id="inquiries_import_file_name" value=""></p>
		<h3>Select Lead Type *</h3> 
		<p>
			<cfscript> 
			ts = StructNew();
			ts.name = "inquiries_type_id"; 
			ts.query = request.qTypes; // this can be an array of structs or a query
			ts.queryLabelField = "##inquiries_type_name##"; 
			ts.queryParseLabelVars = true;
			ts.queryParseValueVars = true;
			ts.queryValueField = "##inquiries_type_id##|##site_id##";  
			application.zcore.functions.zInputSelectBox(ts);
			</cfscript>
		</p> 

		<cfif request.qAutoresponder.recordcount NEQ 0>
			<h3>Select Autoresponder (Optional)</h3>
			<p>
			<!--- only the ones that are enabled for user import as regular user, otherwise all of them when administrator ---> 
			<cfscript> 
			ts = StructNew();
			ts.name = "inquiries_autoresponder_id"; 
			ts.query = request.qAutoresponder; // this can be an array of structs or a query
			ts.queryLabelField = "inquiries_type_name"; 
			ts.queryValueField = "inquiries_autoresponder_id";  
			application.zcore.functions.zInputSelectBox(ts);
			</cfscript>
			</p>
			<p>&nbsp;</p>
		</cfif>

		<h3>Select Assignment</h3>
		<p>If you need more then one assignment, you must import separate files.</p>
		<!--- office and user --->
		<cfif application.zcore.functions.zso(request.zos.globals, 'enableUserOfficeAssign', true, 0) EQ 1>  
			<cfif arrayLen(request.arrOffice) GT 0> 
				<h3>Select Office (Optional)</h3>
				<cfscript> 
				selectStruct = StructNew();
				selectStruct.name = "office_id"; 
				selectStruct.arrData = request.arrOffice;
				selectStruct.size=1; 
				selectStruct.onChange="assignSelectOffice();";
				selectStruct.queryLabelField = "office_name";
				selectStruct.inlineStyle=" max-width:100%;";
				selectStruct.queryValueField = 'office_id';

				if(arrayLen(request.arrOffice) GT 3){
					echo('Type to filter offices: <input type="text" name="#selectStruct.name#_InputField" onkeyup="setTimeout(function(){ assignSelectOffice();}, 100); " id="#selectStruct.name#_InputField" value="" style="min-width:auto;width:200px; max-width:100%; margin-bottom:5px;"><br />Select Office:<br>');
					application.zcore.functions.zInputSelectBox(selectStruct);
					application.zcore.skin.addDeferredScript("  $('###selectStruct.name#').filterByText($('###selectStruct.name#_InputField'), true); ");
				}else{
					selectStruct.size=1; 
					application.zcore.functions.zInputSelectBox(selectStruct); 
				}
				</cfscript> 
			</cfif> 
		</cfif>
		<p>&nbsp;</p> 
		
		<h3>Select User (Optional)</h3> 
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
				form.user_id = ""; 
				echo('<select name="user_id" id="user_id" size="1">');
				echo('<option value="" data-office-id="">-- Select --</option>');
				for(row in request.qUser){
					userGroupName=request.userGroupCom.getGroupDisplayName(row.user_group_id, row.site_id);
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
		<p>&nbsp;</p> 
		<script type="text/javascript">
		/* <![CDATA[ */ 
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
		<cfif request.qUser.recordcount>
			<cfloop query="request.qUser">
			arrAgentPhoto["#request.qUser.user_id#|#request.qUser.site_id#"]=<cfif request.qUser.member_photo NEQ "">"#jsstringformat('#application.zcore.functions.zvar('domain',request.qUser.userSiteId)##request.zos.memberImagePath##request.qUser.member_photo#')#"<cfelse>""</cfif>;
			</cfloop>
		</cfif>
		/* ]]> */
		</script>   

		<cfscript>
		if(application.zcore.functions.zvar("enableLeadUserReminder") EQ 1 or application.zcore.functions.zvar("enableLeadAdminReminder") EQ 1){
			form.inquiries_import_file_disable_reminders=1;
			echo('<h3>Disable lead reminders for the leads being imported?</h3>')
			echo("<p>"&application.zcore.functions.zInput_Boolean("inquiries_import_file_disable_reminders")&"</p><p>&nbsp;</p>");
		}
		</cfscript>


		<h3>Select Tab Delimited .txt File *</h3>
		<p>Use save as -> tab delimited in your spreadsheet software.</p>
		<p style="font-size:18px;"><strong>Important: </strong> <a href="/z/inquiries/admin/import-leads/instructions" target="_blank">Read Instructions First (Opens in New Window)</a></p> 

		<p><input type="file" name="filepath" value="" /></p>
		<p>&nbsp;</p> 
		 <p><input type="submit" name="submit1" id="submitFormButton1" value="Import Tab Delimited File" style="padding:10px; border-radius:5px;" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
		<div id="pleaseWait" style="display:none;">Please wait...</div></p>
	</form>


	<script>
	zArrDeferredFunctions.push(function(){
		$("##importLeadForm").on("submit", function(e){
			e.preventDefault(); 

			var tempObj={};
			tempObj.formId="importLeadForm";
			tempObj.id="zImportLeads";
			tempObj.method="POST"; 
			if(window.location.href.indexOf("import-leads/userSchedule")!=-1){
				tempObj.url="/z/inquiries/admin/import-leads/userScheduleImport";
			}else{
				tempObj.url="/z/inquiries/admin/import-leads/scheduleImport";
			}
			tempObj.callback=function(r){
				r=JSON.parse(r);
				if(r.success){
					if(window.location.href.indexOf("import-leads/userSchedule")!=-1){
						window.location.href="/z/inquiries/admin/import-leads/userIndex";
					}else{
						window.location.href="/z/inquiries/admin/import-leads/index";
					}
				}else{
					alert(r.errorMessage);
					resetForm();
				}
			};
			tempObj.errorCallback=function(){
				alert("Sorry, there was a temporary network problem, please try again later.");
				resetForm();
			}
			tempObj.cache=false;
			zAjax(tempObj);
		});
		function resetForm(){
			$("##submitFormButton1").show();
			$("##pleaseWait").hide();
		}
	});
	</script>
</cffunction>
 
<cffunction name="getHeader" access="public" localmode="modern"> 
	<cfargument name="fileName" type="string" required="yes"> 
	<cfscript> 
	request.arrLines=listToArray(replace(application.zcore.functions.zReadFile(arguments.filename), chr(13), "", "all"), chr(10));

	// first row has required fields? 
	arrHeader=listToArray(request.arrLines[1], chr(9), true);
	request.requiredStruct={};
	request.optionalStruct={};
	for(field in request.arrRequired){
		request.requiredStruct[field]=0;
	}
	for(field in request.arrOptional){
		request.optionalStruct[field]=0;
	} 
	matchCount=0;
	for(i=1;i<=arrayLen(arrHeader);i++){
		field=trim(arrHeader[i]); 
		for(requiredField in request.arrRequired){
			if(requiredField EQ field){
				request.requiredStruct[field]=i;
				matchCount++;
			}
		}
		for(optionalField in request.arrOptional){
			if(optionalField EQ field){
				request.optionalStruct[field]=i; 
			}
		} 
	}
	if(matchCount NEQ 4){
		request.error=true;
		application.zcore.status.setStatus(request.zsid, "All of the required fields must be in the file in the first row: "&arrayToList(request.arrRequired, ", "), form, true);
	}
	request.headerCount=arrayLen(arrHeader);
	</cfscript>
</cffunction>

<cffunction name="getRow" access="public" localmode="modern"> 
	<cfscript>
	request.offset++; 
	if(request.offset GT arrayLen(request.arrLines)){
		row={success:false};
	}else{
		arrRow=listToArray(request.arrLines[request.offset], chr(9), true);
		row={ success:true, data:ts};
	}
	return row;
	</cfscript>
</cffunction>

<cffunction name="getProcessedRow" access="public" localmode="modern"> 
	<cfscript>
	request.offset++; 
	if(request.offset GT arrayLen(request.arrLines)){
		row={success:false};
	}else{
		if(trim(request.arrLines[request.offset]) EQ ""){
			row={success:false};
		}
		arrRow=listToArray(request.arrLines[request.offset], chr(9), true); 
		ts={}; 
		if(arrayLen(arrRow) NEQ request.headerCount){
			return { success:true, data:ts};
		}
		for(field in request.requiredStruct){
			if(request.requiredStruct[field] NEQ 0){
				ts[field]=arrRow[request.requiredStruct[field]];
			}
		}
		for(field in request.optionalStruct){
			if(request.optionalStruct[field] NEQ 0){
				ts[field]=arrRow[request.optionalStruct[field]];
			}
		}
		row={ success:true, data:ts};
	}
	return row;
	</cfscript>
</cffunction>

<cffunction name="userScheduleImport" access="remote" localmode="modern" roles="user"> 
	<cfscript> 
	scheduleImport();
	</cfscript>
</cffunction>
<cffunction name="scheduleImport" access="remote" localmode="modern" roles="administrator"> 
	<cfscript> 
	// this function is meant to validate and store file reference in inquiries_import_file and return instantly.  processing is done later
	init();
	db=request.zos.queryObject;
	form.inquiries_import_file_disable_reminders=application.zcore.functions.zso(form, 'inquiries_import_file_disable_reminders', true, 1);
	form.inquiries_import_file_name=application.zcore.functions.zso(form, 'inquiries_import_file_name');
	form.inquiries_type_id=application.zcore.functions.zso(form, 'inquiries_type_id');
	form.inquiries_autoresponder_id=application.zcore.functions.zso(form, 'inquiries_autoresponder_id', true);
	form.inquiries_import_file_email=application.zcore.functions.zso(form, 'inquiries_import_file_email');
	form.office_id=application.zcore.functions.zso(form, 'office_id', true);
	form.uid=application.zcore.functions.zso(form, 'uid');
	form.filepath=application.zcore.functions.zso(form, 'filepath');  
	form.debug=application.zcore.functions.zso(form, 'debug', true, 0);
	

	if(arrayLen(request.arrOffice) EQ 0){
		form.office_id=0;
	}
	if(request.qUser.recordcount EQ 0){
		form.uid="";
	}
 
	application.zcore.functions.zCreateDirectory(request.importPath); 
	form.filepath=application.zcore.functions.zUploadFile("filepath", request.importPath); 
	if(form.filepath EQ false){
		application.zcore.functions.zReturnJson({success:false, errorMessage:"File upload failed"});
	}
	ext=application.zcore.functions.zGetFileExt(form.filepath);
	if(ext NEQ "txt" and ext NEQ "csv" and ext NEQ "tsv"){
		if(form.debug EQ 0){
			application.zcore.functions.zDeleteFile(request.importPath&form.filePath);
		}
		application.zcore.functions.zReturnJson({success:false, errorMessage:"File extension must be .csv, .txt or .tsv."});
	}
	request.offset=1;
	request.error=false;
	if(form.inquiries_import_file_name EQ ""){
		request.error=true;
		application.zcore.status.setStatus(request.zsid, "Import Name is required", form, true);
	}
	if(form.inquiries_import_file_email EQ "" or application.zcore.functions.zEmailValidate(form.inquiries_import_file_email) EQ false){
		request.error=true;
		application.zcore.status.setStatus(request.zsid, "Notification email is required and must be a valid email address.", form, true); 

	}
	// verify file format.
	if(not request.error){
		getHeader(request.importPath&form.filepath); 
	}

	if(not request.error){
		while(true){
			row=getProcessedRow();
			if(row.success EQ false){
				break;
			}
			if(structcount(row.data) NEQ request.headerCount){
				request.error=true;
				application.zcore.status.setStatus(request.zsid, "Every line of data must have the same number of columns as the first header line.  Line ###request.offset# is not the same.", form, true);
				break;
			}
			requiredEmpty=true; 
			for(field in request.requiredStruct){
				if(row.data[field] NEQ ""){
					requiredEmpty=false;
					break;
				}
			}
			if(requiredEmpty){
				request.error=true;
				application.zcore.status.setStatus(request.zsid, "Line ###request.offset# doesn't have required data. All lines must have data for at least 1 of the required fields.", form, true);
			}
		}
	}

	// validate inquiries_autoresponder_id 
	if(form.inquiries_autoresponder_id NEQ 0){ 
		found=false;
		for(row in request.qAutoresponder){
			if(row.inquiries_autoresponder_id EQ form.inquiries_autoresponder_id){
				found=true;
				break;
			}
		}
		if(not found){
			request.error=true;
			application.zcore.status.setStatus(request.zsid, "You don't have access to the selected autoresponder.", form, true);
		}
	}

	// validate inquiries_type_id
	arrType=listToArray(form.inquiries_type_id, "|");
	if(arraylen(arrType) NEQ 2){
		request.error=true;
		application.zcore.status.setStatus(request.zsid, "Invalid Lead Type.", form, true);
	}else{
		form.inquiries_type_id_siteidtype=application.zcore.functions.zGetSiteIdType(arrType[2]);
		form.inquiries_type_id=arrType[1];
		found=false;
		for(row in request.qTypes){
			if(row.site_id EQ arrType[2] and row.inquiries_type_id EQ arrType[1]){
				found=true;
				break;
			}
		}
		if(not found){
			request.error=true;
			application.zcore.status.setStatus(request.zsid, "You don't have access to the selected lead type.", form, true);
		}
	}


	// validate office_id
	if(form.office_id NEQ 0){ 
		found=false;
		for(row in request.arrOffice){
			if(row.office_id EQ form.office_id){
				found=true;
				break;
			}
		}
		if(not found){
			request.error=true;
			application.zcore.status.setStatus(request.zsid, "You don't have access to the selected office.", form, true);
		}
	}

	// validate user_id
	if(form.uid NEQ ""){
		arrUser=listToArray(form.uid, "|");
		if(arraylen(arrUser) NEQ 2){
			request.error=true;
			application.zcore.status.setStatus(request.zsid, "Invalid user.", form, true);
		}else{
			form.user_id_siteidtype=application.zcore.functions.zGetSiteIdType(arrUser[2]);
			form.user_id=arrUser[1];
			found=false;
			for(row in request.qUser){
				if(row.site_id EQ arrUser[2] and row.user_id EQ arrUser[1]){
					found=true;
					break;
				}
			}
			if(not found){
				request.error=true;
				application.zcore.status.setStatus(request.zsid, "You don't have access to the selected user.", form, true);
			}
		} 
	}
	if(request.error){
		if(form.debug EQ 0){
			application.zcore.functions.zDeleteFile(request.importPath&form.filePath);
		}
		arrError=application.zcore.status.getErrors(request.zsid);
		application.zcore.functions.zReturnJson({success:false, errorMessage: arrayToList(arrError, chr(10))});
	} 

	ts={
		table:"inquiries_import_file",
		datasource:request.zos.zcoreDatasource,
		struct:{
			site_id:request.zos.globals.id,
			office_id:form.office_id,
			user_id:request.zsession.user.id,
			user_id_siteidtype:application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id),
			inquiries_autoresponder_id:form.inquiries_autoresponder_id,
			inquiries_type_id:form.inquiries_type_id,
			inquiries_type_id_siteidtype:form.inquiries_type_id_siteidtype,
			inquiries_import_file_name:form.inquiries_import_file_name,
			inquiries_import_file_filename:form.filePath,
			inquiries_import_file_email:form.inquiries_import_file_email,
			inquiries_import_file_record_count:0,
			inquiries_import_file_import_count:0,
			inquiries_import_file_error_count:0,
			inquiries_import_file_status:0,
			inquiries_import_file_updated_datetime:request.zos.mysqlnow,
			inquiries_import_file_completed_datetime:"",
			inquiries_import_file_deleted:0,
			inquiries_import_file_is_administrator:0,
			inquiries_import_file_import_user_id:request.zsession.user.id,
			inquiries_import_file_import_user_id_siteidtype:application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id),
			inquiries_import_file_disable_reminders:form.inquiries_import_file_disable_reminders
		}
	};
	if(application.zcore.user.checkGroupAccess("administrator")){
		ts.struct.inquiries_import_file_is_administrator=1;
	}
	inquiries_import_file_id=application.zcore.functions.zInsert(ts);  

	application.zcore.functions.zReturnJson({success:true});
	</cfscript>
</cffunction>

<cffunction name="cancelImport" access="remote" localmode="modern" roles="user">  
	<cfscript>
	init();
	form.inquiries_import_file_id=application.zcore.functions.zso(form, "inquiries_import_file_id", true, 0);
	if(form.inquiries_import_file_id EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid import id", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/import-leads/index?zsid=#request.zsid#");
	}
	application["inquiriesImportLogCancel"&request.zos.globals.id&"-"&form.inquiries_import_file_id]=true;
	db=request.zos.queryObject;
	db.sql="update #db.table("inquiries_import_file", request.zos.zcoreDatasource)# SET 
	inquiries_import_file_status=#db.param(4)#, 
	inquiries_import_file_completed_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE 
	inquiries_import_file_id=#db.param(form.inquiries_import_file_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_import_file_deleted=#db.param(0)# 
	";
	getUserLeadFilterSQL(db);
	qUpdate=db.execute("qUpdate");

	application.zcore.status.setStatus(request.zsid, "Cancelling import", form, true);
	application.zcore.functions.zRedirect("/z/inquiries/admin/import-leads/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="importAll" access="remote" localmode="modern"> 
	<cfscript> 
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	setting requesttimeout="10000";
	request.ignoreSlowScript=true;
	db=request.zos.queryObject;   
	db.sql="select * from 
	#db.table("site", request.zos.zcoreDatasource)#, 
	#db.table("inquiries_import_file", request.zos.zcoreDatasource)# 
	WHERE inquiries_import_file.site_id<>#db.param(-1)# and 
	inquiries_import_file_deleted=#db.param(0)# and 
	inquiries_import_file_status in (#db.param(0)#) and 
	inquiries_import_file.site_id = site.site_id and 
	site.site_id <> #db.param(-1)# and 
	site_active = #db.param(1)# and 
	site_deleted = #db.param(0)# ";
	qImport=db.execute("qImport");
	for(row in qImport){
		link=row.site_domain&"/z/inquiries/admin/import-leads/import";
		rs=application.zcore.functions.zdownloadlink(link, 10000, true); 
		echo("Ran import: "&link&": "&rs.success&"<br>");
		echo(rs.cfhttp.filecontent&"<hr>");
		// ignore failures to avoid flooding logs with double the errors.
	}
	echo("done");
	abort;
	</cfscript>
</cffunction>

<cffunction name="import" access="remote" localmode="modern"> 
	<cfscript> 
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	request.ignoreSlowScript=true;
	init();
	// must guarantee only one is ever running.  It may need to be able to resume to achieve that, with small 1 to 5 minute runtimes.

	setting requesttimeout="10000";
	db=request.zos.queryObject; 
	if(structkeyexists(application, 'leadImportLastDate') and application.leadImportLastDate-dateformat(now(), "yyyymmdd")&timeformat(now(), "HHmmss") LTE 60){
		echo("Import is already running.");
	}

	leadAssigned=0;
	db=request.zos.queryObject;  
	debug=false;
	db.sql="select * from #db.table("inquiries_import_file", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	inquiries_import_file_deleted=#db.param(0)# and 
	inquiries_import_file_status in (#db.param(1)#, #db.param(0)#)
	ORDER BY inquiries_import_file_id ASC ";
	qImport=db.execute("qImport", "", 10000, "query", false);


	for(importRow in qImport){
		application.leadImportLastDate=dateformat(now(), "yyyymmdd")&timeformat(now(), "HHmmss");

		request.offset=1;
		importCount=0;
		errorCount=0;
		totalCount=0;
		request.error=false;
		// verify file format.
		getHeader(request.importPath&importRow.inquiries_import_file_filename);  
		if(not request.error){
			while(true){
				d=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
				if(structkeyexists(application, "inquiriesImportLogCancel"&request.zos.globals.id&"-"&importRow.inquiries_import_file_id)){
					db.sql="update #db.table("inquiries_import_file", request.zos.zcoreDatasource)# SET 
					inquiries_import_file_import_count=#db.param(importCount)#,
					inquiries_import_file_record_count=#db.param(totalCount)#, 
					inquiries_import_file_error_count=#db.param(errorCount)#, 
					inquiries_import_file_updated_datetime=#db.param(d)# , 
					inquiries_import_file_completed_datetime=#db.param(d)# 
					WHERE site_id = #db.param(0)# and 
					inquiries_import_file_id=#db.param(importRow.inquiries_import_file_id)# and 
					inquiries_import_file_deleted=#db.param(0)# ";
					db.execute("qLog");
					echo("Import ###importRow.inquiries_import_file_id# cancelled<br>");
					structdelete(application, "inquiriesImportLogCancel"&request.zos.globals.id&"-"&importRow.inquiries_import_file_id);
					break;
				} 
				row=getProcessedRow();
				if(row.success EQ false){
					break;
				} 
				totalCount++;
				// import each row, use request.fieldMap to determine if custom_json or not
				// 
				ts={
					inquiries_external_id:"lead-import-file-"&importRow.inquiries_import_file_id,
					inquiries_import_file_id:importRow.inquiries_import_file_id,
					inquiries_datetime:d, 
					site_id:request.zos.globals.id,
					inquiries_primary:1,
					inquiries_status_id:1,
					inquiries_type_id:importRow.inquiries_type_id, // this is discoverboating id - better as a function call
					inquiries_type_id_siteidtype:importRow.inquiries_type_id_siteidtype,
					inquiries_deleted:0,
					inquiries_updated_datetime:d,
					inquiries_session_id:createUUID(),
					inquiries_optin:1
				};
				if(importRow.inquiries_import_file_disable_reminders EQ 1){
					ts.inquiries_reminder_count=99;
				}
				ts2={};
				for(field in request.fieldMap){
					if(request.fieldMap[field] EQ "inquiries_custom_json"){
						ts2[field]=trim(row.data[field]);
					}else{
						ts[request.fieldMap[field]]=trim(row.data[field]);
					}
				} 
				assignStruct=structnew();    
				office_id="";
				form.dealer="";

				// this is probably not possible?
				request.autoresponderDealerName="";
				request.autoresponderDealerFullInfo=""; 
				// request.autoresponderDealerName=struct.name;
				// request.autoresponderDealerFullInfo="#struct["name"]#<br>#struct["address"]#<br>#struct["city"]# #struct["state/province"]#, #struct["postal code"]#<br/>#struct["phone"]#";
				
				if(importRow.office_id NEQ 0){
					assignStruct.office_id=importRow.office_id;
					assignStruct.forceAssign=true;
				}
				if(importRow.user_id NEQ 0){ 
					assignStruct.assignUserId=importRow.user_id;
					assignStruct.assignUserIdSiteIDType=importRow.user_id_siteidtype;   
					assignStruct.forceAssign=true;
				}
  
				ts.inquiries_custom_json=application.zcore.functions.zSetInquiryCustomJsonFromStruct(ts2); 
				// writedump(assignStruct);
				// writedump(ts);
				// abort;
				if(importRow.inquiries_autoresponder_id NEQ 0){
					ts.sendAutoresponder=true;
				}
				form.inquiries_id=application.zcore.functions.zImportLead(ts);     
				if(form.inquiries_id EQ false){
					errorCount++; 
				}else{
					assignStruct.inquiries_id=form.inquiries_id;
					assignStruct.subject="New Lead on #request.zos.globals.shortdomain#";  

					if(request.zos.isTestServer){
						ts.inquiries_comments=application.zcore.functions.zso(ts, 'inquiries_comments')&"Test Server Mode: This lead would have been assigned to office_id: #importRow.office_id# and user_id: #importRow.user_id#|#importRow.user_id_siteidtype#";
					}else{
					}
					rs=application.zcore.functions.zAssignAndEmailLead(assignStruct);
			  		// application.zcore.functions.zSetOfficeIdForInquiryId(form.inquiries_id, importRow.office_id);
					importCount++;
				} 
			}
			// notify user the import was completed
			ts={};
			ts.subject="Lead import named: #importRow.inquiries_import_file_name# was completed";
			ts.html='#application.zcore.functions.zHTMLDoctype()#
				<head>
				<meta charset="utf-8" />
				<title></title>
				</head> 
				<body>
				<h2>Lead Import Complete</h2>
				<p>Import Name: #importRow.inquiries_import_file_name#</p>
				<p>#importCount# of #totalCount# leads were imported.  There were #errorCount# errors.</p>';
				if(importRow.inquiries_import_file_is_administrator EQ 1){ 
					domain=application.zcore.functions.zVar("publicUserManagerDomain", importRow.site_id, application.zcore.functions.zvar("domain", importRow.site_id)); 
					ts.html&='<p><a href="#domain#/z/inquiries/admin/manage-inquiries/userIndex">Manage Leads</a> | <a href="#domain#/z/inquiries/admin/import-leads/userIndex">Lead Import Log</a></p>';
				}else{ 
					ts.html&='<p><a href="#request.zos.globals.domain#/z/inquiries/admin/manage-inquiries/index">Manage Leads</a> | <a href="#request.zos.globals.domain#/z/inquiries/admin/import-leads/index">Lead Import Log</a></p>';
				}
				ts.html&'</body>
			</html>';
			ts.to=importRow.inquiries_import_file_email; 
			ts.from=request.officeEmail;
		 
			rCom=application.zcore.email.send(ts); 

			if(errorCount GT 0){
				newStatus=2;
			}else{
				newStatus=3;
			}
			db.sql="update #db.table("inquiries_import_file", request.zos.zcoreDatasource)# SET 
			inquiries_import_file_import_count=#db.param(importCount)#,
			inquiries_import_file_record_count=#db.param(totalCount)#, 
			inquiries_import_file_error_count=#db.param(errorCount)#,
			inquiries_import_file_status=#db.param(newStatus)#,
			inquiries_import_file_updated_datetime=#db.param(d)#,
			inquiries_import_file_completed_datetime=#db.param(d)#
			WHERE site_id = #db.param(importRow.site_id)# and 
			inquiries_import_file_id=#db.param(importRow.inquiries_import_file_id)# and 
			inquiries_import_file_deleted=#db.param(0)# ";
			db.execute("qUpdate");
		}
	}
	echo("import complete");
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>