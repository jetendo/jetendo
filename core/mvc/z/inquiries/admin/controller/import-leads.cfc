<cfcomponent>
<cfoutput>
<!--- 
TODO: validation of uploaded file
 schedule save not done
actual import queue not done
assignment
sending of autoresponder
create contacts at same time as create lead (use same function to achieve it?) - avoid duplicates?

/z/inquiries/admin/import-leads/index
 --->

<cffunction name="init" access="remote" localmode="modern"> 
	<cfscript>
	db=request.zos.queryObject;
	manageInquiriesCom=createObject("component", "zcorerootmapping.mvc.z.inquiries.admin.controller.manage-inquiries");
	if(not application.zcore.user.checkGroupAccess("administrator")){
		manageInquiriesCom.checkManageLeadAccess({ errorMessage:"You don't have access or need to login."});
	}

	request.arrRequired=["First Name", "Last Name", "Email", "Phone"];
	request.arrOptional=["Cell Phone", "Home Phone", "Address", "Address 2", "City", "State", "Country", "Postal Code", "Interested In Model", "Interested In Category"]; 
	// request.fieldMap={
	// 	"First Name":"inquiries_first_name",
	// 	"Last Name":"inquiries_last_name",
	// 	"Email":"inquiries_email",
	// 	"Phone":"inquiries_phone1",
	// 	"Cell Phone":"Cell Phone",
	// 	"Home Phone":"Home Phone",
	// 	"Company":"inquiries_company",
	// 	"Address":"inquiries_address",
	// 	"Address 2":"inquiries_address2",
	// 	"City":"inquiries_city",
	// 	"State":"inquiries_state",
	// 	"Country":"inquiries_country",
	// 	"Postal Code":"inquiries_zip",
	// 	"Interested In Model":"inquiries_interested_in_model",
	// 	"Interested In Category":"inquiries_interested_in_category"
	// }; 
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


<cffunction name="index" access="remote" localmode="modern" roles="administrator">  
	<cfscript>
	init();
	db=request.zos.queryObject;
	db.sql="select * from #db.table("inquiries_import_log", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_import_log_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# 
	";
	qImport=db.execute("qImport");
	echo('<h2>Lead Import Log</h2>');
	echo('<p><a href="/z/inquiries/admin/import-leads/schedule" class="z-manager-search-button">New Import</a></p>');

	if(qImport.recordcount EQ 0){
		echo('<p>No leads have been imported here before.</p>');
	}else{
		echo('<table class="table-list">
			<tr>
				<th>Name</th>
				<th>Filename</th>
				<th>Status</th>
				<th>Admin</th>
			</tr>');
		for(row in qImport){
			echo('<tr>');
			echo('<td>#row.inquiries_import_log_id#</td>');
			echo('<td>#row.inquiries_import_log_name#</td>');
			echo('<td>#row.inquiries_import_log_filename#</td>');
			echo('<td>');
			if(row.inquiries_import_log_error_status EQ 4){
				echo("Import cancelled on "&dateformat(row.inquiries_import_log_completed_datetime, "m/d/yy")&" at "&timeformat(row.inquiries_import_log_completed_datetime, "h:mmtt"));
			}else if(row.inquiries_import_log_error_status EQ 3){
				echo("Import completed on "&dateformat(row.inquiries_import_log_completed_datetime, "m/d/yy")&" at "&timeformat(row.inquiries_import_log_completed_datetime, "h:mmtt"));
			}else if(row.inquiries_import_log_error_status EQ 2){
				echo("Import failed on "&dateformat(row.inquiries_import_log_completed_datetime, "m/d/yy")&" at "&timeformat(row.inquiries_import_log_completed_datetime, "h:mmtt")&" with #row.inquiries_import_log_error_count# errors out of #row.inquiries_import_log_record_count# records.");
			}else if(row.inquiries_import_log_error_status EQ 1){
				echo("Import is running");
			}else if(row.inquiries_import_log_error_status EQ 0){
				echo("Import is scheduled");
			}
			echo('</td>');
			echo('<td>');
			if(row.inquiries_import_log_error_status LTE 1){
				echo('<a href="/z/inquiries/admin/import-leads/cancelImport">Cancel</a>');
			}
			echo('</td>');
			echo('</tr>');
		}
		echo('</table>');
	}
	</cfscript>
</cffunction>

<cffunction name="userInstructions" access="remote" localmode="modern" roles="administrator">  
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
		<p>The first row of the CSV file should contain the required fields and as many optional fields as you wish from the list of fields below. You must include the required field columns even if some of them will be empty.  You must save the spreadsheet as a tab delimited .csv format.  Typically, this is an option when you use the "Save as" feature of your spreadsheet software.  The file must have no fields with line breaks.  Any fields that are too long may be cut off at the end to fit the allowed size in the database.</p> 
		<p>If you upload an invalid format, the system will show there was an error and not import any data.</p>
		<p>You can't undo an import once it is submitted. Make sure you are uploading the correct information and not importing duplicate records.</p>
		<p>To protect our system, we schedule the leads to be imported on a first come first served basis.  You will receive an email when the import is complete and the status will also be listed in the import log in the manager.  Please don't submit the same data twice.  Usually the leads will finish importing in a few minutes for a file with less then 100 records.</p>
		<h3>Required File Format</h3>
		<p>Copy and paste these field names to the top row of your spreadsheet.  Any file without a correct header will be rejected.  Any extra columns that don't match exactly will not be imported. Any row that doesn't have at least one of the required fields filled in will not be skipped.</p>
		<h3>Supported Fields</h3>
		<p>Required fields:<br /><textarea type="text" cols="100" rows="2" name="a1">#arrayToList(request.arrRequired, chr(9))#</textarea></p>
		<p>Optional fields:<br /><textarea type="text" cols="100" rows="2" name="a2">#arrayToList(request.arrOptional, chr(9))#</textarea></p> 

		<h2>Example Files</h2>
		<p><a href="/z/a/member/spreadsheet-example.xlsx" target="_blank">Excel Format</a> - must be saved as tab delimited file with no field quotes</p>
		<p><a href="/z/a/member/spreadsheet-example.csv" target="_blank">Tab Delimited CSV Format</a></p>
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
		<p><input type="email" name="importEmail" style="width:250px; max-width:100%;" value="#htmleditformat(request.zsession.user.email)#" /></p> 
		<h3>Import Name</h3>
		<p>Enter a name for the import for future reference</h3>
		<p><input type="text" style="width:100%; max-width:350px;" name="inquiries_import_log_name" id="inquiries_import_log_name" value=""></p>
		<h3>Select Lead Type *</h3> 
		<p>
			<cfscript> 
			ts = StructNew();
			ts.name = "inquiries_type_id"; 
			ts.query = request.qTypes; // this can be an array of structs or a query
			ts.queryLabelField = "inquiries_type_name"; 
			ts.queryValueField = "inquiries_type_id";  
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
		<h3>Select Office (Optional)</h3>
		<p><select name="office_id" size="1">
			<option value="">No office assignment</option>
		</select></p>
		<p>&nbsp;</p>
		<!--- need javascript method --->
		<h3>Select User (Optional)</h3>
		<p><select name="uid" size="1">
			<option value="">No user assignment</option>
		</select></p>
		<p>&nbsp;</p>

		<h3>Select Tab Delimited CSV File *</h3>
		<p style="font-size:18px;"><strong>Important: </strong> <a href="/z/inquiries/admin/import-leads/instructions" target="_blank">Read Instructions First (Opens in New Window)</a></p> 

		<p><input type="file" name="filepath" value="" /></p>
		<p>&nbsp;</p>
		<!--- <cfif request.zos.isDeveloper>
			<h3>Specify optional CFC filter.</h3>
			<p>A struct with each column name as a key will be passed as the first argument to your custom function.</p>
			<p>Code example<br />
			<textarea type="text" cols="100" rows="4" name="a3">#htmleditformat('<cfcomponent>
			<cffunction name="importFilter" localmode="modern" roles="member">
			<cfargument name="struct" type="struct" required="yes">
			<cfscript>
			if(arguments.struct["column1"] EQ "bad value"){
				arguments.struct["column1"]="correct value";
			}
			return true; /* return false if you do not want to import this record. */
			</cfscript>
			</cffunction>
			</cfcomponent>')#</textarea></p>
			<p>Filter CFC CreateObject Path: <input type="text" name="cfcPath" value="" /> (i.e. root.myImportFilter)</p>
			<p>Filter CFC Method: <input type="text" name="cfcMethod" value="" /> (i.e. functionName)</p>
		</cfif>
		<p>&nbsp;</p> --->
		 <p><input type="submit" name="submit1" value="Import CSV" style="padding:10px; border-radius:5px;" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
		<div id="pleaseWait" style="display:none;">Please wait...</div></p>
	</form>


	<script>
	zArrDeferredFunctions.push(function(){
		$("##importLeadForm").on("submit", function(e){
			e.preventDefault();
			// zAjax
			var postObj=zGetFormDataByFormId("importLeadForm");
			var tempObj={};
			tempObj.id="zImportLeads";
			tempObj.method="POST";
			tempObj.url="/z/inquiries/admin/import-leads/scheduleImport";
			tempObj.callback=function(r){
				r=JSON.parse(r);
				if(r.success){
					window.location.href="/z/inquiries/admin/import-leads/log";
				}else{
					alert(r.errorMessage);
				}
			};
			tempObj.errorCallback=function(){
				alert("Sorry, there was a temporary network problem, please try again later.");
			}
			tempObj.cache=false;
			zAjax(tempObj);
		});
	});
	</script>
</cffunction>


<cffunction name="userImport" access="remote" localmode="modern" roles="user">  
	<cfscript>
	// TODO: verify user has access
	import();
	</cfscript>
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
	for(i=1;i<=arrayLen(arrHeader);i++){
		field=arrHeader[i];
		match=false;
		for(requiredField in request.arrRequired){
			if(requiredField EQ field){
				request.requiredStruct[field]=i;
				match=true;
			}
		}
		for(optionalField in request.arrOptional){
			if(optionalField EQ field){
				request.optionalStruct[field]=i;
				match=true;
			}
		}
		if(not match){
			request.error=true;
			application.zcore.status.setStatus(request.zsid, requiredField&" is required and wasn't in the column headers.", form, true);
		}
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
		arrRow=listToArray(request.arrLines[request.offset], chr(9), true); 
		ts={};
		for(field in request.requiredStruct){
			ts[field]=row.data[request.requiredStruct[field]]
		}
		for(field in request.optionalStruct){
			ts[field]=row.data[request.optionalStruct[field]]
		}
		row={ success:true, data:ts};
	}
	return row;
	</cfscript>
</cffunction>

<cffunction name="scheduleImport" access="remote" localmode="modern" roles="administrator"> 
	<cfscript> 
	init();
	db=request.zos.queryObject;
	form.inquiries_import_log_name=application.zcore.functions.zso(form, 'inquiries_import_log_name');
	form.inquiries_type_id=application.zcore.functions.zso(form, 'inquiries_type_id');
	form.inquiries_autoresponder_id=application.zcore.functions.zso(form, 'inquiries_autoresponder_id');
	form.office_id=application.zcore.functions.zso(form, 'office_id');
	form.uid=application.zcore.functions.zso(form, 'uid');
	form.filename=application.zcore.functions.zso(form, 'filename');
	// form.cfcPath=application.zcore.functions.zso(form, 'cfcPath');
	// form.cfcMethod=application.zcore.functions.zso(form, 'cfcMethod');
	// store file reference and initial data in inquiries_import_log and return instantly.
 
	path=request.zos.globals.privateHomeDir&"inquiries-import-backup/";
	form.filename=application.zcore.functions.zUploadFile(form.filename, path);
	if(form.filename EQ false){
		application.zcore.functions.zReturnJson({success:false, errorMessage:"File upload failed"});
	}
	ext=application.zcore.functions.zGetFileExt(form.filename);
	if(ext NEQ "csv" and ext NEQ "tsv"){
		application.zcore.functions.zDeleteFile(path&form.fileName);
		application.zcore.functions.zReturnJson({success:false, errorMessage:"File must be .csv or .tsv.  Other formats are not accepted."});
	}
	request.offset=1;
	request.error=false;
	// verify file format.
	getHeader(form.filename);

	if(not request.error){
		while(true){
			row=getRow();
			if(row.success EQ false){
				break;
			}
			requiredEmpty=true;
			for(field in request.requiredStruct){
				offset=request.requiredStruct[field];
				if(row.data[offset] NEQ ""){
					requiredEmpty=false;
					break;
				}
			}
			if(requiredEmpty){
				request.error=true;
				application.zcore.status.setStatus(request.zsid, "Line ###i# doesn't have required data. All lines must have data for at least 1 of the required fields.", form, true);
			}
			if(arrayLen(row.data) NEQ headerCount){
				request.error=true;
				application.zcore.status.setStatus(request.zsid, "Every line of data must have the same number of columns as the first header line.  Line ###i# is not the same.", form, true);
				break;
			}
		}
	}
	if(request.error){
		application.zcore.functions.zDeleteFile(path&form.filename);
		application.zcore.functions.zRedirect("/z/inquiries/admin/import-leads/index?zsid=#request.zsid#");
	}

	request.arrRequired=["First Name", "Last Name", "Email", "Phone"];
	request.arrOptional=["Cell Phone", "Home Phone", "Address", "Address 2", "City", "State", "Country", "Postal Code", "Interested In Model", "Interested In Category"]; 


	ts={
		table:"inquiries_import_log",
		datasource:request.zos.zcoreDatasource,
		struct:{
			site_id:request.zos.globals.id,
			user_id:request.zsession.user.id,
			user_id_siteidtype:application.zcore.functions.zGetSiteIdType(request.zsession.user.site_id),
			inquiries_import_log_filename:form.filename,
			inquiries_import_log_record_count:0,
			inquiries_import_log_error_count:0,
			inquiries_import_log_error_status:0,
			inquiries_import_log_updated_datetime:request.zos.mysqlnow,
			inquiries_import_log_completed_datetime:"",
			inquiries_import_log_deleted:0
		}
	};
	application.zcore.functions.zInsert(ts);

	application.zcore.functions.zReturnJson({success:true});
	</cfscript>
</cffunction>

<cffunction name="cancelImport" access="remote" localmode="modern" roles="user">  
	<cfscript>
	init();
	form.inquiries_import_log_id=application.zcore.functions.zso(form, "inquiries_import_log_id", true, 0);
	if(form.inquiries_import_log_id EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid import id", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/import-leads/index?zsid=#request.zsid#");
	}
	application["inquiriesImportLogCancel"&request.zos.globals.id&"-"&form.inquiries_import_log_id]=true;
	db=request.zos.queryObject;
	db.sql="update #db.table("inquiries_import_log", request.zos.zcoreDatasource)# SET 
	inquiries_import_log_error_status=#db.param(4)#, 
	inquiries_import_log_completed_datetime=#db.param(request.zos.mysqlnow)# 
	WHERE 
	inquiries_import_log_id=#db.param(form.inquiries_import_log_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_import_log_deleted=#db.param(0)# 
	";
	qUpdate=db.execute("qUpdate");

	application.zcore.status.setStatus(request.zsid, "Cancelling import", form, true);
	application.zcore.functions.zRedirect("/z/inquiries/admin/import-leads/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="import" access="remote" localmode="modern"> 
	<cfscript> 
	if(not request.zos.isDeveloper and not request.zos.isServer and not request.zos.isTestServer){
		application.zcore.functions.z404("Can't be executed except on test server or by server/developer ips.");
	}
	// must guarantee only one is ever running.  It may need to be able to resume to achieve that, with small 1 to 5 minute runtimes.

	setting requesttimeout="5000";
	db=request.zos.queryObject;
	// read from inquiries_import_log table for status =0
	form.filename=application.zcore.functions.zso(form, 'filename');
	form.cfcPath=application.zcore.functions.zso(form, 'cfcPath');
	form.cfcMethod=application.zcore.functions.zso(form, 'cfcMethod');

	leadAssigned=0;
	db=request.zos.queryObject; 
	// path=request.zos.globals.privateHomeDir&"inquiries-import-backup/";
	// application.zcore.functions.zCreateDirectory(path);
	// filepath=path&"import-#dateformat(now(), "yyyy-mm-dd")&"-"&timeformat(now(), "HH-mm-ss")#.txt";
	debug=false;
	db.sql="select * from #db.table("inquiries_import_log", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	inquiries_import_log_deleted=#db.param(0)# and 
	inquiries_import_log_error_status=#db.param(0)# 
	ORDER BY inquiries_import_log_id ASC ";
	qImport=db.execute("qImport");

	for(importRow in qImport){

		request.offset=1;
		request.error=false;
		// verify file format.
		getHeader(importRow.inquiries_import_log_filename);

		if(not request.error){
			while(true){
				// TODO: change to use filereadline instead
				row=getProcessedRow();
				if(row.success EQ false){
					break;
				} 
				// import each row, use request.fieldMap to determine if custom_json or not
				writedump(row);
				break;
			}
		}
	}
	abort;


	throw("Mark inquiries record with the file that was used during import to make it easier to remove mistakes.");
	throw("need to implement inquiries_autoresponder_allow_user_import");
	// this was the discover boating import below.  Need to make it a background process instead, and make it general based on the file upload.

	// need a table that tracks the imports per user, so we can display a global and user specific log status, and recover from mistakes.

	// need to store the inquiries_import_file_id in this table.
// request.fieldMap

	if(structkeyexists(application, "inquiriesImportLogCancel"&request.zos.globals.id&"-"&form.inquiries_import_log_id)){
		echo("Import cancelled");
		structdelete(application, "inquiriesImportLogCancel"&request.zos.globals.id&"-"&form.inquiries_import_log_id);
		abort;
	}

  
	arrDealer=application.zcore.siteOptionCom.optionGroupStruct("Dealer");
	dealerStateLookup={};
	montereyDealer={};
	for(dealer in arrDealer){ 
		if(dealer["state/province"] NEQ ""){
			if(not structkeyexists(dealerStateLookup, dealer["state/province"])){
				dealerStateLookup[dealer["state/province"]]=[];
			}
			arrayAppend(dealerStateLookup[dealer["state/province"]], dealer);
		}
	}
	userGroupCom = application.zcore.functions.zcreateobject("component","zcorerootmapping.com.user.user_group_admin");
	dealerGroupId = userGroupCom.getGroupId('Dealer_Manager',request.zos.globals.id); 

	dealerCom=createobject("component", request.zRootCFCPath&"mvc.controller.dealer");
	leadCount=0;
	if(structkeyexists(x.processsaleslead.dataarea, 'salesLead')){
		xs=x.processsaleslead.dataarea.salesLead;
		for(i=1;i<=arraylen(xs);i++){
			lead=xs[i];
			d=replace(left(lead.header.documentDateTime.xmltext, len(lead.header.documentDateTime.xmltext)-6), "T", " ");  
			d=parseDatetime(d);  
			ps=lead.header.IndividualProspect;
			
			ts={
				inquiries_external_id:"lead-import-"&lead.header.documentId.xmltext,
				inquiries_datetime:dateformat(d, "yyyy-mm-dd")&" "&timeformat(d, "HH:mm:ss"),
				inquiries_first_name:ps.personname.givenName.xmltext,
				inquiries_last_name:ps.personname.familyName.xmltext,
				site_id:request.zos.globals.id,
				inquiries_primary:1,
				inquiries_status_id:1,
				inquiries_type_id:20, // this is discoverboating id - better as a function call
				inquiries_type_id_siteidtype:1,
				inquiries_deleted:0,
				inquiries_updated_datetime:request.zos.mysqlnow,
				inquiries_session_id:createUUID()
			};

			inquiryStruct=application.zcore.functions.zGetInquiryByExternalId(ts.inquiries_external_id);
			leadExists=false;
			if(structcount(inquiryStruct) NEQ 0){
				// skip lead already imported.
				leadExists=true;
				continue;
			} 
			//throw("test discover boating import");		abort;

			assignStruct=structnew();
			// assignStruct.assignUserId=481;
			// assignStruct.assignUserIdSiteIdType=1; 
			if(ps.marketingMailInd EQ 1){
				ts["inquiries_optin"]=1;
			}
			if(structkeyexists(ps, 'address') and structkeyexists(ps.address, 'addressLine')){
				if(arraylen(ps.address.addressLine) GTE 1){
					ts.inquiries_address=ps.address.addressLine[1].xmltext;
				}
				arrayDeleteAt(ps.address.addressLine, 1);
				if(structkeyexists(ps.address, 'addressLine') and arraylen(ps.address.addressLine) GTE 1){
					arrAddress=[];
					for(n in ps.address.addressLine){
						arrayAppend(arrAddress, n.xmltext);
					}
					ts.inquiries_address2=arrayToList(arrAddress, ", ");
				}
			}
			if(structkeyexists(ps, 'address') and structkeyexists(ps.address, 'city')){
				ts.inquiries_city=ps.address.city.xmltext;
			}
			ts.inquiries_state="";
			if(structkeyexists(ps, 'address') and structkeyexists(ps.address, 'StateOrProvince')){
				ts.inquiries_state=ps.address.StateOrProvince.xmltext;
			}
			ts.inquiries_zip="";
			if(structkeyexists(ps, 'address') and structkeyexists(ps.address, 'PostalCode')){
				ts.inquiries_zip=ps.address.PostalCode.xmltext;
			}
			ts2={};
			office_id="";
			form.dealer="";
			arrOffice=[];
			findDealer=false;

			request.autoresponderDealerName="";
			request.autoresponderDealerFullInfo="";
			if(structkeyexists(ps, 'address') and structkeyexists(ps.address, 'Country')){
				ts.inquiries_country=ps.address.Country.xmltext;
				findRandomStateDealer=false;
				if(ts.inquiries_country EQ "US" or ts.inquiries_country EQ "CA"){
					if(structkeyexists(ps.address, 'PostalCode')){
						// find dealer based on zip code distance - server side.
						findDealer=true;
						request.international=false;
						form.query=ts.inquiries_zip;
						form.lat="";
						form.lng="";
						form.country=ts.inquiries_country;
						form.quote_model=""; 
					}else{
						findDealer=true;
						findRandomStateDealer=true;
					}
				}else{
					request.international=true;
					findDealer=true;
					form.query=ts.inquiries_country;
					form.lat="";
					form.lng="";
					form.country=ts.inquiries_country;
					form.quote_model="";
				}
				if(findDealer){
					if(ts.inquiries_state NEQ "" and findRandomStateDealer and structkeyexists(dealerStateLookup, ts.inquiries_state)){
						tempDealer=dealerStateLookup[ts.inquiries_state][randrange(1, arraylen(dealerStateLookup[ts.inquiries_state]))];
						data={dealers:[ { data: tempDealer }] };
						echo('forced random state dealer<br>');
					}else{
						data=dealerCom.getDealerData();

						if(arrayLen(data.dealers) EQ 0 and structcount(montereyDealer) NEQ 0){
							data={dealers:[ { data: montereyDealer }] };
							echo('forced monterey dealer<br>');
						}
					} 
					if(arrayLen(data.dealers) GTE 1){
						form.dealer=data.dealers[1].data.__setId;
						struct=application.zcore.siteOptionCom.getOptionGroupSetById(["Dealer"],form["Dealer"]); 
						if(structcount(struct)){
							ts2["Dealer ID"]=struct.__setID;

							ts2["Dealer Info"]="#struct["name"]#<br/>
							#struct["address"]#, #struct["city"]# #struct["state/province"]#, #struct["postal code"]#<br/>
							#struct["phone"]#";
							request.autoresponderDealerName=struct.name;
							request.autoresponderDealerFullInfo="#struct["name"]#<br>#struct["address"]#<br>#struct["city"]# #struct["state/province"]#, #struct["postal code"]#<br/>#struct["phone"]#";
							 

							ts4={
								"DealerID":{value:form.dealer, listDelimiter:","}
							};
							application.zcore.functions.zSetOfficeIdForAutoresponder(form.dealer);
							arrOffice=application.zcore.user.searchOfficesByStruct(ts4);
							if(arrayLen(arrOffice) NEQ 0){
								ts.office_id=arrOffice[1].office_id;
								office_id=ts.office_id;

								// how to get the user for this dealer?
								db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# WHERE 
								concat(#db.param(',')#, office_id, #db.param(',')#) LIKE #db.param("%,"&ts.office_id&",%")# and 
								user_username=#db.param(struct["ARI Email"])# and 
								user_active=#db.param(1)# and 
								site_id = #db.param(request.zos.globals.id)# and 
								user_deleted=#db.param(0)# and 
								user_group_id=#db.param(dealerGroupId)# 
								LIMIT #db.param(0)#, #db.param(1)#";
								// we are only pulling the first dealer manager.  if there is more then one, it could be a problem, but we are ignoring this problem for now.
								// we would need a way to set the "primary" user in a group to fix
								qUser=db.execute("qUser");  
								if(qUser.recordcount NEQ 0){
									// assign should be here
									structdelete(assignStruct, 'assignEmail');
									assignStruct.assignUserId=qUser.user_id;
									assignStruct.assignUserIdSiteIDType=1;  
								} 
							} 
							request.autoresponderDealerName=struct.name;
							request.autoresponderDealerFullInfo="#struct["name"]#<br>#struct["address"]#<br>#struct["city"]# #struct["state/province"]#, #struct["postal code"]#<br/>#struct["phone"]#";
						}
					}
				}
			}  


			if(structkeyexists(ps, 'contact') and structkeyexists(ps.contact, 'telephone')){
				ts.inquiries_phone1=ps.contact.telephone.xmltext;
				ts.inquiries_phone1_formatted=application.zcore.functions.zFormatInquiryPhone(ts.inquiries_phone1);
			}
			if(structkeyexists(ps, 'contact') and structkeyexists(ps.contact, 'emailAddress')){
				ts.inquiries_email=ps.contact.emailAddress.xmltext;
			}

			// convert into custom fields
			if(structkeyexists(ps, 'purchaseEarliestDate')){
				ts2["Purchase Earliest Date"]=ps.purchaseEarliestDate.xmltext;
			}
			if(structkeyexists(ps, 'ownedVehicle') and structkeyexists(ps.ownedVehicle, 'ownedType')){
				ts2["Owned Vehicle Type"]=ps.ownedVehicle.ownedType.xmltext;
			}
			if(structkeyexists(ps, 'ownedVehicle') and structkeyexists(ps.ownedVehicle, 'ModelDescription')){
				ts2["Owned Vehicle Description"]=ps.ownedVehicle.ModelDescription.xmltext;
			} 
			if(structkeyexists(ps, 'Detail') and structkeyexists(ps.Detail, 'SalesVehicle') and structkeyexists(ps.Detail.SalesVehicle, 'ModelDescription')){
				ts2["Interested In Category"]=ps.Detail.SalesVehicle.ModelDescription.xmltext;
			}
			if(structkeyexists(ps, 'Detail') and structkeyexists(ps.Detail, 'LeadRequestType')){
				ts2["Lead Request Type"]=ps.Detail.LeadRequestType.xmltext;
			}
			if(structkeyexists(ps, 'Detail') and structkeyexists(ps.Detail, 'LeadIndustryType')){
				ts2["Lead Industry Type"]=ps.Detail.LeadIndustryType.xmltext;
			}

			ts.inquiries_custom_json=application.zcore.functions.zSetInquiryCustomJsonFromStruct(ts2); 
			if(findDealer){
				// TODO: maybe set the customer_id later too
				if(office_id EQ "" or office_id EQ "0"){
					savecontent variable="out"{
						echo('<h2>lead with external id: #ts.inquiries_external_id# will be missing office_id</h2>');
						writedump("office_id:"&office_id);
						writedump("leadExists:"&leadExists);
						writedump("dealer: "&form.dealer);
						writedump(ts);
						writedump(arrOffice);
						writedump(ps);
					}
					throw(out);
				} 
			}
			if(not leadExists){
				leadCount++;
				form.inquiries_id=application.zcore.functions.zImportLead(ts);   
			}else{
				form.inquiries_id=inquiryStruct.inquiries_id;
			}   

			if(findDealer){
				assignStruct.office_id=office_id;
				assignStruct.forceAssign=true;
			}
			assignStruct.inquiries_id=form.inquiries_id;
			assignStruct.subject="New Lead on #request.zos.globals.shortdomain#"; 
			leadAssigned++;
			rs=application.zcore.functions.zAssignAndEmailLead(assignStruct);
			if(findDealer){
	    		application.zcore.functions.zSetOfficeIdForInquiryId(form.inquiries_id, office_id);
	    	}

    		db.sql="select * from #db.table("inquiries", request.zos.zcoreDatasource)# where inquiries_id = #db.param(form.inquiries_id)# and site_id =#db.param(request.zos.globals.id)# and inquiries_deleted=#db.param(0)#";
    		qCheck=db.execute("qCheck");
    		if(qCheck.recordcount NEQ 0){
				if(findDealer){
	    			if(qCheck.office_id EQ 0){
	    				throw("discoverboating - zAssignAndEmailLead or zSetOfficeIdForInquiryId failed to set office_id to #office_id# for inquiries_id=#form.inquiries_id#");
	    			}
	    		}
    		}
			if(rs.success EQ false){
				// failed to assign/email lead
				//zdump(local.rs);
			}   
		}
	}
	echo('Imported #leadCount# leads | assigned #leadAssigned# leads');
	abort;
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>