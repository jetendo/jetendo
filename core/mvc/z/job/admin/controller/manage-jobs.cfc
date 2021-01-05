<cfcomponent>
<cfoutput>


<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Jobs", true);	
	db.sql="SELECT * FROM #db.table("job", request.zos.zcoreDatasource)# job
	WHERE job_id= #db.param(application.zcore.functions.zso(form,'job_id'))# and 
	job_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";

	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "job_return"&form.job_id, request.zos.CGI.HTTP_REFERER, true);		
	}
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Job no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/job/admin/manage-jobs/index?zsid=#request.zsid#');
	}
	jobCom=application.zcore.app.getAppCFC("job");
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript> 
		for(row in qCheck){
			jobCom.deleteJobByStruct(row);
		}

		if(structkeyexists(request.zsession, 'job_return'&form.job_id)){
			a=request.zsession['job_return'&form.job_id];
			structdelete(request.zsession, 'job_return'&form.job_id);
			application.zcore.functions.zRedirect(a);
		}else{
			if(form.returnJson EQ 1){
				application.zcore.functions.zReturnJson({success:true});
			}else{
				application.zcore.status.setStatus(Request.zsid, 'Job deleted');
				application.zcore.functions.zRedirect('/z/job/admin/manage-jobs/index?zsid=#request.zsid#');
			}
		}
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this Job?<br />
			<br />
			#qCheck.job_title#<br />
			<br />
			<a href="/z/job/admin/manage-jobs/delete?confirm=1&amp;job_id=#form.job_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/job/admin/manage-jobs/index">No</a> 
		</div>
	</cfif>
</cffunction>



<cffunction name="publicInsertJob" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.z404('Public Insert Job is not implemented');

	this.update();
	</cfscript>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	var ts={};
	var result=0;
	if (form.method EQ "insert") {
		form.job_id="";
	}

	form.job_category_id = application.zcore.functions.zso( form, 'job_category_id' );
	form.job_company_name = application.zcore.functions.zso( form, 'job_company_name' );
	form.job_company_name_hidden = application.zcore.functions.zso( form, 'job_company_name_hidden' );

	if(form.method EQ "insert" or form.method EQ "publicInsertJob"){
		form.job_id="";
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', true, 0);

	errors=false;
/*
	if(form.method EQ "publicInsertJob"){
		form.job_unique_url='';
		form.job_status=0;
		form.job_featured='0';
		form.job_summary=application.zcore.functions.zStripHTMLTags(application.zcore.functions.zso(form, 'job_summary'));
		form.job_overview=application.zcore.functions.zStripHTMLTags(application.zcore.functions.zso(form, 'job_overview'));
		if(request.zos.globals.recaptchaSecretkey NEQ ""){
			if(not application.zcore.functions.zVerifyRecaptcha()){
				application.zcore.status.setStatus(request.zsid, "The ReCaptcha security phrase wasn't entered correctly. Please try again.", form, true);
				errors=true;
			}
		}
		form.inquiries_spam=0;
		if(application.zcore.functions.zFakeFormFieldsNotEmpty()){ 
			application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
			errors=true;
		}
		if(form.modalpopforced EQ 1){
			if(application.zcore.functions.zso(form, 'js3811') NEQ "j219"){
				application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
				errors=true;
			}
			if(application.zcore.functions.zCheckFormHashValue(application.zcore.functions.zso(form, 'js3812')) EQ false){
				application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
				errors=true;
			}
		}
		//if(application.zcore.functions.zso(form, 'zset9') NEQ "9989"){
			//application.zcore.status.setStatus(request.zsid, "Invalid submission.  Please submit the form again.",form,true);
			//errors=true;
		//}
		if(errors){
			application.zcore.functions.zRedirect("/z/job/suggest-an-job/index?zsid=#request.zsid#");
		}
	}else{

*/
		application.zcore.adminSecurityFilter.requireFeatureAccess("Jobs", true);	

/*	} */

	form.site_id = request.zos.globals.id;
	ts.job_title.required = true;



	if ( form.job_posted_datetime_date EQ '' ) {
		form.job_posted_datetime_date = DateFormat(request.zos.now,'yyyy-mm-dd');
	}

	if ( form.job_posted_datetime_time EQ '' ) {
		form.job_posted_datetime_time = TimeFormat(request.zos.now,'HH:mm:ss');
	}


	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);

	if(application.zcore.functions.zso(form,'job_unique_url') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'job_unique_url'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		result=true;
	}

	if ( form.job_website NEQ '' ) {
		success=application.zcore.functions.zValidateURL(form.job_website, false, false); 
		if(not success){ 
			application.zcore.status.setStatus(request.zsid, "Website must be a valid URL beginning with / or ##, starting with http:// or a link within this site.", form, true); 
			result=true; 
		}
	}


	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'publicInsertJob'){
			application.zcore.functions.zRedirect("/z/job/suggest-an-job/index?zsid=#request.zsid#");
		}else if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/job/admin/manage-jobs/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/job/admin/manage-jobs/edit?job_id=#form.job_id#&zsid=#request.zsid#');
		}
	}
	form.job_posted_datetime="";
	if(form.job_posted_datetime_date NEQ "" and isdate(form.job_posted_datetime_date)){
		form.job_posted_datetime=dateformat(form.job_posted_datetime_date, 'yyyy-mm-dd');
	}
	if(form.job_posted_datetime_time NEQ "" and isdate(form.job_posted_datetime_time)){
		form.job_posted_datetime=form.job_posted_datetime&" "&timeformat(form.job_posted_datetime_time, 'HH:mm:ss');
	}
	form.job_closed_datetime="";
	if(form.job_closed_datetime_date NEQ "" and isdate(form.job_closed_datetime_date)){
		form.job_closed_datetime=dateformat(form.job_closed_datetime_date, 'yyyy-mm-dd');
	}
	if(form.job_closed_datetime_time NEQ "" and isdate(form.job_closed_datetime_time)){
		form.job_closed_datetime=form.job_closed_datetime&" "&timeformat(form.job_closed_datetime_time, 'HH:mm:ss');
	}

	form.job_updated_datetime=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');


	// Build the full text search for the job.
	search_job_type = application.zcore.app.getAppCFC( 'job' ).jobTypeToString( form.job_type );

	search_full_text = form.job_title & ' ' & search_job_type & ' ' & form.job_city & ' ' & form.job_summary & ' ' & form.job_overview;

	form.job_search = application.zcore.functions.zRemoveHTMLForSearchIndexer( search_full_text );


	uniqueChanged=false;
	oldURL='';
	if(form.method EQ 'insert' and application.zcore.functions.zso(form, 'job_unique_url') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ 'update'){
		db.sql="SELECT * FROM #db.table("job", request.zos.zcoreDatasource)# 
		WHERE job_id = #db.param(form.job_id)# and 
		job_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this job.',form,true);
			application.zcore.functions.zRedirect('/z/job/admin/manage-jobs/index?zsid=#request.zsid#');
		}
		oldURL=qCheck.job_unique_url;
		if(structkeyexists(form, 'job_unique_url') and qcheck.job_unique_url NEQ form.job_unique_url){
			uniqueChanged=true;	
		}
	} 

	ts=StructNew();
	ts.table='job';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert' or form.method EQ "publicInsertJob"){
		form.job_id = application.zcore.functions.zInsert(ts);
		if(form.job_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save Job.',form,true);
			if(form.method EQ "publicInsertJob"){
				application.zcore.functions.zRedirect("/z/job/suggest-an-job/index?zsid=#request.zsid#");
			}else{
				application.zcore.functions.zRedirect('/z/job/admin/manage-jobs/add?zsid=#request.zsid#');
			}
		}else{
			application.zcore.status.setStatus(request.zsid, 'Job saved.');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save Job.',form,true);
			application.zcore.functions.zRedirect('/z/job/admin/manage-jobs/edit?job_id=#form.job_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Job updated.');
		}
	}

	db.sql="delete from #db.table("job_x_category", request.zos.zcoreDatasource)# WHERE 
	job_id = #db.param(form.job_id)# and 
	job_x_category_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qDelete=db.execute("qDelete");

	if(form.job_category_id NEQ ""){
		arrCategory=listToArray(form.job_category_id, ',');
		for(i=1;i LTE arraylen(arrCategory);i++){
			ts={
				struct:{
					job_id:form.job_id,
					site_id:request.zos.globals.id,
					job_x_category_deleted:0,
					job_x_category_updated_datetime:dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'),
					job_category_id:arrCategory[i]
				},
				table:"job_x_category",
				datasource:request.zos.zcoreDatasource
			}
			application.zcore.functions.zInsert(ts);
		}
	}
 
	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'job_image_library_id'));


	// echo('stop');abort;
	if(uniqueChanged){
		application.zcore.app.getAppCFC("job").updateRewriteRuleJob(form.job_id, oldURL);	
	}
	application.zcore.app.getAppCFC("job").searchReindexJob(form.job_id, false);

	if(form.method EQ "publicInsertJob"){

		// send email to admin about the job

		ts={};
		ts.subject="Suggest an job submission on #request.zos.globals.shortDomain#";
		savecontent variable="output"{
			echo('#application.zcore.functions.zHTMLDoctype()#
			<head>
			<meta charset="utf-8" />
			<title>Suggest An Job</title>
			</head>
			
			<body>
				<h2>Suggest An Job Submission</h2>
				<p>Job Name: #form.job_title#</p>
				<p>Start Date: #dateformat(form.job_posted_datetime, "m/d/yyyy")# at #timeformat(form.job_posted_datetime, "h:mm tt")#</p>
				<p>End Date: #dateformat(form.job_closed_datetime, "m/d/yyyy")# at #timeformat(form.job_closed_datetime, "h:mm tt")#</p>');
				if(form.job_recur_ical_rules NEQ ""){
					echo('<p>This is a recurring job</p>');
				}else{
					echo('<p>This is NOT a recurring job</p>');
				}
				echo('<p>Suggested By Name: #form.job_suggested_by_name#</p>
				<p>Suggested By Email: <a href="mailto:#form.job_suggested_by_email#">#form.job_suggested_by_email#</a></p>
				<p>Suggested By Phone: #form.job_suggested_by_phone#</p>
				<p>This job will not appear on the public calendar until you edit it in the manager and set the "Active" field to "Yes".</p>
				<p>It is wise not to trust the information submitted by a user.  Please make an attempt to verify the information and ensure it doesn''t contain any malicious or illegal information such as HTML code or stolen images.  You are ultimately responsible for the content on your web site.</p>
				<h2><a href="/z/job/admin/manage-jobs/edit?job_id=#form.job_id#">Edit This Job</a></h2>
				<h2><a href="/z/job/admin/manage-jobs/index">Manage Jobs</a></h2>

				<p>This email was sent from the web site:<br /><a href="#request.zos.globals.domain#">#request.zos.globals.domain#</a></p>');
				

			echo('</body>
			</html>');
		}
		ts.html=output;
		ts.to=request.officeEmail;
		ts.from=request.fromEmail; 
		rCom=application.zcore.email.send(ts);
		if(rCom.isOK() EQ false){
			rCom.setStatusErrors(request.zsid);
			application.zcore.functions.zstatushandler(request.zsid);
			application.zcore.functions.zabort();
		}

		application.zcore.functions.zRedirect("/z/job/suggest-an-job/complete?modalpopforced=#form.modalpopforced#&zsid=#request.zsid#");
	}else{
		if(structkeyexists(request.zsession, 'job_return'&form.job_id)){
			a=request.zsession['job_return'&form.job_id];
			structdelete(request.zsession, 'job_return'&form.job_id);
			application.zcore.functions.zRedirect(a);
		}else{
			if(form.modalpopforced EQ 1){
				application.zcore.functions.zRedirect('/z/job/admin/manage-jobs/getReturnJobRowHTML?job_id=#form.job_id#');
			}else{
				application.zcore.functions.zRedirect('/z/job/admin/manage-jobs/index?zsid=#request.zsid#');
			}
		}
	}
	</cfscript>
</cffunction>


	
<cffunction name="publicAddJob" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.functions.z404('Public Add Job is not implemented');

	form.job_id="";
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript> 
	var db=request.zos.queryObject; 
	var currentMethod=form.method;
	var htmlEditor=0;

	if(currentMethod EQ "publicAddJob"){
       	form.set9=application.zcore.functions.zGetHumanFieldIndex();
		notPublic=false;
	}else{
		notPublic=true;
	}

	if(notPublic){
		application.zcore.functions.zSetPageHelpId("11.2");
		application.zcore.adminSecurityFilter.requireFeatureAccess("Jobs");	
	}
	if(application.zcore.functions.zso(form,'job_id') EQ ''){
		form.job_id = -1;
	}
	if(structkeyexists(form, 'return')){
		StructInsert(request.zsession, "job_return"&form.job_id, request.zos.CGI.HTTP_REFERER, true);		
	}

	db.sql="SELECT * FROM #db.table("job", request.zos.zcoreDatasource)# job 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	job_deleted = #db.param(0)# and 
	job_id=#db.param(form.job_id)#";
	qJob=db.execute("qJob"); 
	application.zcore.functions.zQueryToStruct(qJob, form, 'job_category_id');  
	application.zcore.functions.zRequireJqueryUI();
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	if(currentMethod EQ "add" or currentMethod EQ "publicAddJob"){
		form.job_uid='';
		form.job_id="";
		form.job_file1="";
		form.job_file2="";
		form.job_image_library_id="";
		form.job_unique_url="";
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
	}
	application.zcore.functions.zStatusHandler(request.zsid,true); 

	if ( ! structKeyExists( form, 'job_company_name_hidden' ) ) {
		form.job_company_name_hidden = 0;
	}

	if(currentMethod EQ "publicAddJob"){
		application.zcore.template.setTag("title", "Suggest An Job");
		application.zcore.template.setTag("pagetitle", "Suggest An Job");
		action='/z/job/suggest-an-job/submit';
	}else{
		action='/z/job/admin/manage-jobs/';
		echo('<h2>');
		if(currentMethod EQ "add"){
			echo('Add');
			action&="insert";
		}else{
			echo('Edit');
			action&="update?job_id=#form.job_id#";
		}
		echo(' Job</h2>');
	}

	</cfscript>
	<p>* Denotes required field.</p>
	<form class="zFormCheckDirty" action="#action#" method="post" enctype="multipart/form-data" <cfif not notPublic>onsubmit="zSet9('zset9_#form.set9#');"</cfif>>
		<cfif notPublic>
			
		<cfelse>
			<input type="hidden" name="job_image_library_layout" value="3">
			<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
			#application.zcore.functions.zFakeFormFields()#
		</cfif>
		<input type="hidden" name="modalpopforced" value="#form.modalpopforced#" />
		<table style="width:100%;" class="table-list">  

			<cfif notPublic>
				<tr>
					<th style="width:1%;">&nbsp;</th>
					<td><button type="submit" name="submitForm" class="z-manager-search-button">Save</button>

						<cfif form.modalpopforced EQ 1>
							<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.zCloseModal();">Cancel</button>
						<cfelse>
							<cfscript>
							cancelLink="/z/job/admin/manage-jobs/index";
							</cfscript>
							<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href='#cancelLink#';">Cancel</button>
						</cfif>
					</td>
				</tr> 
			<cfelse>
				<tr>
					<td colspan="2"><h2>Your Contact Information</h2>
						<p>Please provide some contact information in case we have a question about your submission.  This information will not be displayed on our web site.  It will only be used to communicate with you about your submission. </p>
						<p>These fields are optional if you wish to remain anonymous.</p>

				<tr>
					<th>Name</th>
					<td><input type="text" name="job_suggested_by_name" style="width:95%;" value="#htmleditformat(form.job_suggested_by_name)#" /></td>
				</tr>  
				<tr>
					<th>Email</th>
					<td><input type="text" name="job_suggested_by_email" style="width:95%;" value="#htmleditformat(form.job_suggested_by_email)#" /></td>
				</tr>  
				<tr>
					<th>Phone</th>
					<td><input type="text" name="job_suggested_by_phone" style="width:95%;" value="#htmleditformat(form.job_suggested_by_phone)#" /> </td>
				</tr>  
				<tr>
					<td colspan="2"><h2>Job Information</h2></td>
				</tr>
			</cfif>

			<tr>
				<th>Job Title</th>
				<td><input type="text" name="job_title" style="width:95%;" value="#htmleditformat(form.job_title)#" /> *</td>
			</tr>
			<tr>
				<th>Category</th>
				<td>
					<cfscript>
					db.sql="select * from #db.table("job_category", request.zos.zcoreDatasource)# WHERE 
					job_category.site_id = #db.param(request.zos.globals.id)# and 
					job_category_deleted=#db.param(0)#
					ORDER BY job_category_name ASC";
					qCategory=db.execute("qCategory");

					ts = StructNew();
					ts.name = "job_category_id"; 
					ts.size = 1; 
					ts.multiple = true; 
					ts.query = qCategory;
					ts.queryLabelField = "job_category_name";
					ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
					ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
					ts.queryValueField = "job_category_id"; 
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'job_category_id'));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript> 
				</td>
			</tr>    
			<cfscript> 
			jobStartDate=form.job_posted_datetime;
			jobStartTime=form.job_posted_datetime;
			if(jobStartDate EQ ""){
				jobStartDate=application.zcore.functions.zso(form, 'job_posted_datetime_date');
				jobStartTime=application.zcore.functions.zso(form, 'job_posted_datetime_time');
			}  
			jobEndDate=form.job_closed_datetime;
			jobEndTime=form.job_closed_datetime;
			if(jobEndDate EQ ""){
				jobEndDate=application.zcore.functions.zso(form, 'job_closed_datetime_date');
				jobEndTime=application.zcore.functions.zso(form, 'job_closed_datetime_time');
			}
			onChangeJavascript='';
			application.zcore.functions.zRequireTimePicker();  
			application.zcore.skin.addDeferredScript('  
				$("##job_posted_datetime_time").timePicker({
					show24Hours: false,
					step: 15
				});
				$("##job_closed_datetime_time").timePicker({
					show24Hours: false,
					step: 15
				});
				$( "##job_posted_datetime_date" ).datepicker();
				$( "##job_closed_datetime_date" ).datepicker();
			'); 
			</cfscript>
			<tr>
				<th>Job Type</th>
				<td>
					<cfscript>
						ts = StructNew();
						ts.name = "job_type";
						ts.label="";
						ts.labelStyle="";
						ts.size = 1; // more for multiple select
						ts.hideSelect = true;
						ts.listLabels = "Not provided,Full-time,Part-time,Commission,Temporary,Temporary to hire,Contract,Contract to hire,Internship,Volunteer,Per Diem";
						ts.listValues = "0,1,2,3,4,5,6,7,8,9,10";
						ts.listLabelsDelimiter = ","; 
						ts.listValuesDelimiter = ",";
						
						application.zcore.functions.zInputSelectBox(ts);
					</cfscript> *
				</td>
			</tr>
			<tr>
				<th>Posted Date</th>
				<td>
					<cfscript>
					if ( jobStartDate EQ "" ) {
						jobStartDate = now();
					}
					if ( jobStartTime EQ "" ) {
						jobStartTime = now();
					}
					</cfscript>
					<input type="text" name="job_posted_datetime_date" style="max-width:80px;min-width:80px;" onchange="#onChangeJavascript#" onkeyup="#onChangeJavascript#" onpaste="#onChangeJavascript#" id="job_posted_datetime_date" value="#htmleditformat(dateformat(jobStartDate, 'm/dd/yyyy'))#" size="10" />
					<input type="text" name="job_posted_datetime_time" style="max-width:80px;min-width:80px;" id="job_posted_datetime_time" value="<cfif isdate(jobStartTime) and timeformat(jobStartTime, 'h:mm tt') NEQ "12:00 am">#htmleditformat(timeformat(jobStartTime, 'h:mm tt'))#</cfif>" size="9" />
					 * <br /><br />
					 You can set the date to be in the future and the job will not be visible until that time has passed.
				</td>
			</tr>  
			<tr>
				<th>Closed Date</th>
				<td><input type="text" name="job_closed_datetime_date" style="max-width:80px;min-width:80px;" onchange="#onChangeJavascript#" onkeyup="#onChangeJavascript#" onpaste="#onChangeJavascript#" id="job_closed_datetime_date" value="#htmleditformat(dateformat(jobEndDate, 'm/dd/yyyy'))#" size="10" />
					<input type="text" name="job_closed_datetime_time" style="max-width:80px;min-width:80px;" id="job_closed_datetime_time" value="<cfif isdate(jobEndTime) and timeformat(jobEndTime, 'h:mm tt') NEQ "12:00 am">#htmleditformat(timeformat(jobEndTime, 'h:mm tt'))#</cfif>" size="9" />
					<br /><br />
					Date in which a job would no longer be listed anymore.
				</td>
			</tr>
			<cfif notPublic>
				<tr>
					<th>Featured Job?</th>
					<td>#application.zcore.functions.zInput_Boolean("job_featured", application.zcore.functions.zso(form, 'job_featured'))# (Yes, will force the job to be displayed first)</td>
				</tr>  
			</cfif>

			<cfif application.zcore.app.getAppData( 'job' ).optionStruct.job_config_this_company NEQ 1>
				<tr>
					<th>Company Name</th>
					<td><input type="text" name="job_company_name" style="width:95%;" value="#htmleditformat(form.job_company_name)#" /><br /><br />
						<cfif application.zcore.app.getAppData( 'job' ).optionStruct.job_config_company_names_hidden NEQ 1>
							Hide company name? #application.zcore.functions.zInput_Boolean("job_company_name_hidden", application.zcore.functions.zso(form, 'job_company_name_hidden'))#
						</cfif>
					</td>
				</tr>
			</cfif>

			<tr>
				<th>Summary</th>
				<td>
					<cfscript>
					if(notPublic){
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "job_summary";
						htmlEditor.value			= form.job_summary;
						htmlEditor.width			= "100%";
						htmlEditor.height		= 150;
						htmlEditor.create();
					}else{

						ts=StructNew();
						ts.name="job_summary";
						ts.style="width:95%; height:100px;";
						ts.multiline=true;
						application.zcore.functions.zInput_Text(ts);
					}
					</cfscript>   
				</td>
			</tr> 
			<tr>
				<th>Full Description</th>
				<td>
					<cfscript>
					if(notPublic){
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "job_overview";
						htmlEditor.value			= form.job_overview;
						htmlEditor.width			= "100%";
						htmlEditor.height		= 350;
						htmlEditor.create();
					}else{
						ts=StructNew();
						ts.name="job_overview";
						ts.style="width:95%; height:200px;";
						ts.multiline=true;
						application.zcore.functions.zInput_Text(ts);
					}
					</cfscript>   
				</td>
			</tr> 
			<tr>
				<th>Work Hours</th>
				<td><input type="text" name="job_work_hours" id="job_work_hours" style="width:95%;" value="#htmleditformat(form.job_work_hours)#" /> (i.e. 40 hours per week)</td>
			</tr> 
			<tr>
				<th>Telecommute</th>
				<td>
					<cfscript>
					if(form.job_telecommute EQ ""){
						form.job_telecommute='0';
					} 
					</cfscript>#application.zcore.functions.zInput_Boolean("job_telecommute")# 
					<br>Only click yes if this job is exclusively a remote telecommuting position</td>
			</tr> 
			<tr>
				<th>Location Name</th>
				<td><input type="text" name="job_location" style="width:95%;" value="#htmleditformat(form.job_location)#" /><br /><br />
					Optionally describe the area/location the job is in.
				</td>
			</tr> 
			<tr>
				<th>Address</th>
				<td><input type="text" name="job_address" id="job_address" style="width:95%;" value="#htmleditformat(form.job_address)#" /></td>
			</tr> 
			<tr>
				<th>Address 2</th>
				<td><input type="text" name="job_address2" id="job_address2" style="width:95%;" value="#htmleditformat(form.job_address2)#" /></td>
			</tr> 
			<tr>
				<th>City</th>
				<td><input type="text" name="job_city" id="job_city" style="width:95%;" value="#htmleditformat(form.job_city)#" /></td>
			</tr> 
			<tr>
				<th>State</th>
				<td>#application.zcore.functions.zStateSelect("job_state", application.zcore.functions.zso(form, 'job_state'))#</td>
			</tr> 
			<tr>
				<th>Zip/Postal Code</th>
				<td><input type="text" name="job_zip" id="job_zip" value="#htmleditformat(form.job_zip)#" /></td>
			</tr> 
			<tr>
				<th>Country</th>
				<td>#application.zcore.functions.zCountrySelect("job_country", application.zcore.functions.zso(form, 'job_country'))#</	td>
			</tr> 
			<tr>
				<th>Map Location</th>
				<td> 
					<cfscript>
					ts={
						name:"job_map_coordinates",
						fields:{
							address:"job_address",
							city:"job_city",
							state:"job_state",
							zip:"job_zip",
							country:"job_country",
						}
					};
					echo(application.zcore.functions.zMapLocationPicker(ts));
					</cfscript>
				</td>
			</tr> 
			<tr>
				<th>Phone</th>
				<td><input type="text" name="job_phone" style="width:95%;" value="#htmleditformat(form.job_phone)#" /></td>
			</tr> 

			<tr>
				<th>Web Site URL</th>
				<td><input type="text" name="job_website" style="width:95%;" value="#htmleditformat(form.job_website)#" /></td>
			</tr>
			<tr>
				<th>Override Application URL</th>
				<td><input type="text" name="job_apply_url" style="width:95%;" value="#htmleditformat(form.job_apply_url)#" /></td>
			</tr>

			
			<tr>
				<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photos","member.job.edit job_image_library_id")#</th>
				<td>
					<cfscript>
					ts=structnew();
					ts.name="job_image_library_id";
					ts.value=form.job_image_library_id;

					ts.allowPublicEditing=true;
					application.zcore.imageLibraryCom.getLibraryForm(ts);
					</cfscript>
				</td>
			</tr>
			<cfif notPublic>
	
				<tr>
					<th style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photo Layout","member.job.edit job_image_library_layout")#</th>
					<td>
						<cfscript>
						ts=structnew();
						ts.name="job_image_library_layout";
						ts.value=form.job_image_library_layout;
						application.zcore.imageLibraryCom.getLayoutTypeForm(ts);
						</cfscript>
					</td>
				</tr>
			</cfif>
			<cfif notPublic>
 			
				<tr>
					<th>Active</th>
					<td><cfscript>
		
					if(form.job_status EQ ""){
						form.job_status='1';
					} 
					</cfscript>#application.zcore.functions.zInput_Boolean("job_status")#</td>
				</tr> 
				<tr>
					<th style="vertical-align:top; width:120px; ">Meta Title</th>
					<td>
						<input type="text" name="job_metatitle" style="width:95%;" value="#htmleditformat(form.job_metatitle)#">
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; width:120px; ">Meta Keywords</th>
					<td>
						<textarea name="job_metakey" style="width:95%; height:60px; ">#htmleditformat(form.job_metakey)#</textarea>
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; width:120px; ">Meta Description</th>
					<td>
						<textarea name="job_metadesc" style="width:95%; height:60px; ">#htmleditformat(form.job_metadesc)#</textarea>
					</td>
				</tr>
	  

				<tr>
					<th>Unique URL</th>
					<td>
					<cfif form.method EQ "add">
						#application.zcore.functions.zInputUniqueUrl("job_unique_url", true)#
					<cfelse>
						#application.zcore.functions.zInputUniqueUrl("job_unique_url")#
					</cfif>
					<br />
				It is not recommended to use this feature unless you know what you are doing regarding SEO and broken links.  It is used to change the URL of this record within the site.</td>
				</tr> 

				<cfif application.zcore.functions.zso(application.zcore.app.getAppData("job").optionStruct, 'job_config_enable_suggest_job', true) EQ 1>
		
					<tr>
						<td colspan="2"><h2>Suggested By Information</h2>
							<p>These fields will be populated when a user has submitted the job and choose to provide this optional information.  These fields are not to be displayed to the public. You can use this information to follow-up with the user to ask questions or let them know the job was posted.</p>
						</td>
					</tr>
					<tr>
						<th>Name</th>
						<td><input type="text" name="job_suggested_by_name" style="width:95%;" value="#htmleditformat(form.job_suggested_by_name)#" /></td>
					</tr>  
					<tr>
						<th>Email</th>
						<td><input type="text" name="job_suggested_by_email" style="width:95%;" value="#htmleditformat(form.job_suggested_by_email)#" /></td>
					</tr>  
					<tr>
						<th>Phone</th>
						<td><input type="text" name="job_suggested_by_phone" style="width:95%;" value="#htmleditformat(form.job_suggested_by_phone)#" /></td>
					</tr>  
				</cfif>
			</cfif>

			<cfif not notPublic and request.zos.globals.recaptchaSecretkey NEQ "">
				<tr>
					<td colspan="2">
					#application.zcore.functions.zDisplayRecaptcha()#
					</td>
				</tr>
			</cfif>
	
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td>
					<cfif notPublic>
						<button type="submit" name="submitForm" class="z-manager-search-button">Save</button>
						<cfif form.modalpopforced EQ 1>
							<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.zCloseModal();">Cancel</button>
						<cfelse>
							<cfscript>
							cancelLink="/z/job/admin/manage-jobs/index";
							</cfscript>
							<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href='#cancelLink#';">Cancel</button>
						</cfif>
					<cfelse>
						<button type="submit" name="submitForm" class="z-manager-search-button">Submit</button>
					</cfif>
				</td></td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;

	application.zcore.functions.zRequireJqueryUI();

	form.jobStatus=application.zcore.functions.zso(form, 'jobStatus', true, 1);
 	form.job_start_date=application.zcore.functions.zso(form, 'job_start_date');
 	form.job_end_date=application.zcore.functions.zso(form, 'job_end_date');
 	form.job_searchtext=application.zcore.functions.zso(form, 'job_searchtext');
 	form.job_category_id=application.zcore.functions.zso(form, 'job_category_id');

	application.zcore.adminSecurityFilter.requireFeatureAccess("Jobs");

	form.job_searchtext=replace(replace(form.job_searchtext, '+', ' ', 'all'), ' ', '%', 'all');

	perpage=10;
	form.zIndex=application.zcore.functions.zso(form, 'zIndex', true, 1);
	if(form.zIndex LT 1){
		form.zIndex=1;
	}

	searchOn=false;
	application.zcore.functions.zSetPageHelpId("11.1");


	// By default we feel that most sites will be set up for 'this company' so
	// we don't need to include the company name in the search query.
	// This variable changes how the SQL query is built below.
	searching_for_company_name = false;

	// However, if this site is set up to list jobs for other companies...
	if ( application.zcore.app.getAppData( 'job' ).optionStruct.job_config_this_company EQ 0 ) {
		// Then include the company name in the __MANAGER__ search query by default.
		searching_for_company_name = true;

		// ... BUT if we want the company names hidden...
		if ( application.zcore.app.getAppData( 'job' ).optionStruct.job_config_company_names_hidden EQ 1 ) {
			/*
				WE WANT TO ALLOW THE MANAGER TO STILL BE ABLE TO SEARCH BY THE
				COMPANY NAME REGARDLESS IF THE COMPANY NAME IS HIDDEN OR NOT ON
				THE FRONT END OF THE WEBSITE.
			*/
		}
	}


	db.sql="select *";

	if ( form.job_searchtext NEQ "" ) {
		if ( searching_for_company_name ) {
			db.sql &= ", IF ( concat(job.job_id, #db.param(' ')#, job_title, #db.param(' ')#, job_company_name, #db.param(' ')#, job_city, #db.param(' ')#, job_summary, #db.param(' ')#, job_overview) LIKE #db.param( '%' & application.zcore.functions.zURLEncode( form.job_searchtext, '%' ) & '%' )#, #db.param( '1' )#, #db.param( '0' )# ) exactMatch,
				MATCH( `job_search` ) AGAINST( #db.param( form.job_searchtext )# ) relevance ";
		} else {
			db.sql &= ", IF ( `job_search` LIKE #db.param( '%' & application.zcore.functions.zURLEncode( form.job_searchtext, '%' ) & '%' )#, #db.param( '1' )#, #db.param( '0' )# ) exactMatch,
				MATCH( `job_search` ) AGAINST( #db.param( form.job_searchtext )# ) relevance ";
		}
	}

	db.sql &= " from 
	#db.table("job", request.zos.zcoreDatasource)#";
	db.sql&=" WHERE ";
	db.sql&=" job.site_id = #db.param(request.zos.globals.id)# and 
	job_deleted=#db.param(0)# ";

	if(form.jobStatus NEQ 2){
		db.sql&=" and job_status = #db.param(form.jobStatus)# ";
	}else{
		searchOn=true;
	}

	if(form.job_start_date NEQ "" and isdate(form.job_start_date)){
		db.sql&=" and job_posted_datetime >= #db.param(dateformat(form.job_start_date, 'yyyy-mm-dd'))# ";
	}
	if(form.job_end_date NEQ "" and isdate(form.job_end_date)){
		db.sql&=" and job_posted_datetime <= #db.param(dateformat(form.job_end_date, 'yyyy-mm-dd'))# ";
	}


	if(form.job_searchtext NEQ ""){
		searchOn=true;

		if ( searching_for_company_name ) {
			db.sql &= " and ( MATCH( `job_search` ) AGAINST ( #db.param( form.job_searchtext )# ) ";
			db.sql &= " or concat(job.job_id, #db.param(' ')#, job_title, #db.param(' ')#, job_company_name, #db.param(' ')#, job_city, #db.param(' ')#, job_summary, #db.param(' ')#, job_overview)  like #db.param('%#form.job_searchtext#%')# ";
			db.sql &= " ) ";
		} else {
			db.sql &= " and ( MATCH( `job_search` ) AGAINST ( #db.param( form.job_searchtext )# ) ";
			db.sql &= " or job_search LIKE #db.param( '%' & form.job_searchtext & '%' )# ) ";
		}
	}

	if(form.job_category_id NEQ ""){
		searchOn=true;
		db.sql&=" and CONCAT(#db.param(',')#,job_category_id, #db.param(',')#) LIKE #db.param('%,'&form.job_category_id&',%')# ";
	}

	if ( form.job_searchtext NEQ "" ) {
		db.sql &= " ORDER BY exactMatch DESC, relevance DESC";
	} else {
		db.sql &= " ORDER BY job_title ASC";
	}

	db.sql&=" LIMIT #db.param((form.zIndex-1)*perpage)#, #db.param(perpage)# ";
	qList=db.execute("qList");

	db.sql="select count(job.job_id) count from 
	#db.table("job", request.zos.zcoreDatasource)#";
	db.sql&=" WHERE ";
	db.sql&=" job.site_id = #db.param(request.zos.globals.id)# and 
	job_deleted=#db.param(0)# ";
	if(form.jobStatus NEQ 2){
		db.sql&=" and job_status = #db.param(form.jobStatus)# ";
	}

	if(form.job_start_date NEQ "" and isdate(form.job_start_date)){
		db.sql&=" and job_posted_datetime >= #db.param(dateformat(form.job_start_date, 'yyyy-mm-dd'))# ";
	}
	if(form.job_end_date NEQ "" and isdate(form.job_end_date)){
		db.sql&=" and job_posted_datetime <= #db.param(dateformat(form.job_end_date, 'yyyy-mm-dd'))# ";
	}

	if(form.job_searchtext NEQ ""){
		if ( searching_for_company_name ) {
			db.sql &= " and ( MATCH( `job_search` ) AGAINST ( #db.param( form.job_searchtext )# ) ";
			db.sql &= " or concat(job.job_id, #db.param(' ')#, job_title, #db.param(' ')#, job_company_name, #db.param(' ')#, job_city, #db.param(' ')#, job_summary, #db.param(' ')#, job_overview)  like #db.param('%#form.job_searchtext#%')# ";
			db.sql &= " ) ";
		} else {
			db.sql &= " and ( MATCH( `job_search` ) AGAINST ( #db.param( form.job_searchtext )# ) ";
			db.sql &= " or job_search LIKE #db.param( '%' & form.job_searchtext & '%' )# ) ";
		}
	}

	if(form.job_category_id NEQ ""){ 
		db.sql&=" and CONCAT(#db.param(',')#,job_category_id, #db.param(',')#) LIKE #db.param('%,'&form.job_category_id&',%')# ";
	}
	qCount=db.execute("qCount");
	
	echo('<div class="z-manager-list-view">');
	request.jobCom=application.zcore.app.getAppCFC("job");
	request.jobCom.getAdminNavMenu();
	echo('<div class="z-float z-mb-10">'); 
	echo('<h2 style="display:inline-block;">');
	if(searchOn){
		echo('Jobs | Search Results');
	}else{
		echo('Jobs');
	}
	echo('</h2>'); 
	echo(' &nbsp;&nbsp; <a href="/z/job/admin/manage-jobs/add" class="z-button">Add</a>
	</div>');


	application.zcore.skin.addDeferredScript('   
		$( "##job_start_date" ).datepicker();
		$( "##job_end_date" ).datepicker();
	'); 
	</cfscript> 
	<div style="width:100%; float:left;">
		<form action="/z/job/admin/manage-jobs/index" method="get"> 
		<div style="width:170px; margin-bottom:10px;float:left;">
			Keyword:<br /> 
			<input type="text" name="job_searchtext" value="#replace(replace(form.job_searchtext, '+', ' ', 'all'), '%', ' ', 'all')#" style="width:150px; " />
		</div>
		<div style="width:90px;margin-bottom:10px;float:left;">
			Start: <br />
			<input type="text" name="job_start_date" id="job_start_date" value="#form.job_start_date#" style="width:70px; " />
		</div>
		<div style="width:90px;margin-bottom:10px;float:left;">
			End: <br />
			<input type="text" name="job_end_date" id="job_end_date" value="#form.job_end_date#" style="width:70px; " />
		</div>
		<div style="width:145px;margin-bottom:10px;float:left;">
			Status: <br />
			<cfscript> 
			ts = StructNew();
			ts.name = "jobStatus"; 
			ts.size = 1; 
			ts.inlineStyle="width:100px;";
			ts.multiple = false; 
			ts.listLabels = "Active|Inactive|All";
			ts.listValues = "1|0|2";
			ts.listLabelsDelimiter = "|"; // tab delimiter
			ts.listValuesDelimiter = "|";
			application.zcore.functions.zInputSelectBox(ts);
			</cfscript> 

		</div>

		<div style="width:120px;margin-bottom:10px;float:left;">
			Category: <br />
			<cfscript>
			db.sql="select * from #db.table("job_category", request.zos.zcoreDatasource)# WHERE 
			site_id = #db.param(request.zos.globals.id)# and 
			job_category_deleted=#db.param(0)# 
			ORDER BY job_category_name ASC";
			qCategory=db.execute("qCategory");

			ts = StructNew();
			ts.name = "job_category_id"; 
			ts.size = 1; 
			ts.multiple = false; 
			ts.inlineStyle="width:100px;";
			ts.query = qCategory;
			ts.queryLabelField = "job_category_name";
			ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
			ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
			ts.queryValueField = "job_category_id"; 
			//application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'job_category_id'));
			application.zcore.functions.zInputSelectBox(ts);
			</cfscript> 


		</div>
		<div style="width:150px;margin-bottom:10px;float:left;">&nbsp;<br />
			<input type="submit" name="search1" value="Search" class="z-manager-search-button" />
			<cfif searchOn>
				<input type="button" name="search2" value="Show All" class="z-manager-search-button" onclick="window.location.href='/z/job/admin/manage-jobs/index';">
			</cfif>
		</div>
		</form>
	</div>
	<hr />
	<cfscript>
	searchStruct = StructNew(); 
	searchStruct.showString = "Results ";
	searchStruct.url = "/z/job/admin/manage-jobs/index?job_searchtext=#form.job_searchtext#&job_category_id=#form.job_category_id#&job_start_date=#form.job_start_date#&job_end_date=#form.job_end_date#";
	searchStruct.indexName = "zIndex";
	searchStruct.buttons = 5;
	searchStruct.count = qCount.count;
	searchStruct.index = form.zIndex;
	searchStruct.perpage = perpage; 
	
	searchNav = application.zcore.functions.zSearchResultsNav(searchStruct);
	if(qCount.count GT perpage){
		echo(searchNav);
	}

	request.uniqueJob={};
	</cfscript>
	<table class="table-list">
		<tr>
			<th>ID</th>
			<th>Name</th>

			<cfif application.zcore.app.getAppData( 'job' ).optionStruct.job_config_this_company EQ 0>
				<cfif application.zcore.app.getAppData( 'job' ).optionStruct.job_config_company_names_hidden EQ 1>
					<th>Company <span style="color: ##000000; font-weight: bold; font-style: italic;">(globally hidden)</span></th>
				<cfelse>
					<th>Company</th>
				</cfif>
			</cfif>

			<th>Active</th>
			<th>Posted Date</th>
			<th>Closed Date</th>
			<th>Last Updated</th>
			<th>Admin</th>
		</tr>
		<cfscript>

		for(row in qList){
			echo('<tr>');
			getJobRowHTML(row);
			echo('</tr>');
			request.uniqueJob[row.job_id]=true;
		}
		</cfscript>  
	</table>
	<cfscript>
	
	if(qList.recordcount EQ 0){
		echo('<p>No jobs found</p>');
	}
	if(qCount.count GT perpage){
		echo(searchNav);
	}
	</cfscript>
	</div>
</cffunction>

<cffunction name="getReturnJobRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;  
	
	db.sql="SELECT * FROM #db.table("job", request.zos.zcoreDatasource)# job
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	job_deleted = #db.param(0)# and 
	job_id=#db.param(form.job_id)#";
	qJob=db.execute("qJob"); 
	
	request.jobCom=application.zcore.app.getAppCFC("job");
	request.uniqueJob={};
	savecontent variable="rowOut"{
		for(row in qJob){
			getJobRowHTML(row);
			request.uniqueJob[row.job_id]=true;
		}
	}

	echo('done.<script>
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>
	
<cffunction name="getJobRowHTML" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;

	echo('
		<td>#row.job_id#</td>
		<td>#row.job_title#</td>');

	if ( application.zcore.app.getAppData( 'job' ).optionStruct.job_config_this_company NEQ 1 ) {
		if ( row.job_company_name_hidden EQ 1 ) {
			echo('<td>#row.job_company_name# <span style="color: ##000000; font-weight: bold; font-style: italic;">(hidden)</span></td>');
		} else {
			echo('<td>#row.job_company_name#</td>');
		}
	}

	echo('
		<td>');

	if(row.job_status EQ 1){
		echo('<span style="color: ##009900; font-weight: bold;">Yes</span>');
	}else{
		echo('<span style="color: ##990000; font-weight: bold;">No</span>');
	}

	echo('</td>
		<td>#dateformat(row.job_posted_datetime, 'm/d/yyyy')#</td>
		<td>#dateformat(row.job_closed_datetime, 'm/d/yyyy')#</td>
		<td>#application.zcore.functions.zGetLastUpdatedDescription(row.job_updated_datetime)#</td>
		<td>');

		echo('<a href="#request.jobCom.getJobURL(row)#" target="_blank">View</a> | 
		<a href="/z/job/admin/manage-jobs/add?job_id=#row.job_id#">Copy</a> | ');
		echo('<a href="/z/job/admin/manage-jobs/edit?job_id=#row.job_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit</a>');

		echo(' | ');

		if (not application.zcore.functions.zIsForceDeleteEnabled(row.job_unique_url) ) {
			echo( 'Locked' );
		} else {
			echo( '<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/job/admin/manage-jobs/delete?job_id=#row.job_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a>');
		}
	echo('</td>');

	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>