<cfcomponent>
<cfoutput>
<cffunction name="submit" localmode="modern" access="remote">
	<cfscript>
	if(application.zcore.functions.zso(application.zcore.app.getAppData( 'job' ).optionStruct, 'job_config_disable_apply_online', true, 0) EQ 1){
		application.zcore.functions.z404("Apply online is disabled");
	}
		// This function is split up so that in the future we can add logic here
		// to determine how to handle processing the form.

		// Handle processing the form as a general inquiry.
		this.submitInquiry();
	</cfscript>
</cffunction>

<cffunction name="submitInquiry" localmode="modern" access="public">
	<cfscript>
	if(application.zcore.functions.zso(application.zcore.app.getAppData( 'job' ).optionStruct, 'job_config_disable_apply_online', true, 0) EQ 1){
		application.zcore.functions.z404("Apply online is disabled");
	}
		jobId = application.zcore.functions.zso(form, 'jobId');

		jobCom = application.zcore.app.getAppCFC( 'job' );

		job = jobCom.getJobById( jobId );

		if ( NOT structKeyExists( job, 'job_status' ) ) {
			application.zcore.functions.z404( 'Job not found' );
		}

		if ( job.job_status NEQ 1 ) {
			application.zcore.functions.z404( 'Job not active' );
		}

		if ( application.zcore.functions.zFakeFormFieldsNotEmpty() ) {
			application.zcore.functions.z404( 'Invalid request' );
		}

		form.first_name = application.zcore.functions.zRemoveHTMLForSearchIndexer( application.zcore.functions.zso( form, 'first_name' ) );
		form.last_name  = application.zcore.functions.zRemoveHTMLForSearchIndexer( application.zcore.functions.zso( form, 'last_name' ) );
		form.email      = application.zcore.functions.zRemoveHTMLForSearchIndexer( application.zcore.functions.zso( form, 'email' ) );
		form.phone      = application.zcore.functions.zRemoveHTMLForSearchIndexer( application.zcore.functions.zso( form, 'phone' ) );

		if ( form.first_name EQ "" ) {
			application.zcore.status.setStatus( request.zsid, "First Name is required", form, true );
			application.zcore.functions.zRedirect( "/z/job/apply/index?jobId=#jobId#&zsid=#request.zsid#" );
		}

		if ( form.last_name EQ "" ) {
			application.zcore.status.setStatus( request.zsid, "Last Name is required", form, true );
			application.zcore.functions.zRedirect( "/z/job/apply/index?jobId=#jobId#&zsid=#request.zsid#" );
		}

		if ( not application.zcore.functions.zEmailValidate( form.email ) ) {
			application.zcore.status.setStatus(request.zsid, "Invalid email address", form, true);
			application.zcore.functions.zRedirect( "/z/job/apply/index?jobId=#jobId#&zsid=#request.zsid#" );
		}

		if ( form.phone EQ "" ) {
			application.zcore.status.setStatus( request.zsid, "Phone is required", form, true );
			application.zcore.functions.zRedirect( "/z/job/apply/index?jobId=#jobId#&zsid=#request.zsid#" );
		}

		form.resumeFile  = application.zcore.functions.zso( form, 'resumeFile' );
		form.coverLetter = application.zcore.functions.zRemoveHTMLForSearchIndexer( application.zcore.functions.zso( form, 'coverLetter' ) );

		ts = {};
		ts.to = application.zcore.functions.zvarso( 'zofficeemail' );

		if ( request.zos.istestserver or ts.to EQ "" ) {
			ts.to = request.zos.developerEmailTo;
		}

		link = job.__url;

		ts.replyto = form.email;
		ts.from    = request.zos.globals.emailCampaignFrom;
		ts.subject = "Resume submitted for job listed on #request.zos.globals.shortDomain#";

		savecontent variable = "ts.html" {
			echo( '<!DOCTYPE html>
				<html>
				<head><title>Job Application</title>
				</head>
				<body>
					<h2>Resume submitted for job listed on #request.zos.globals.shortDomain#</h2>
					<h3>Job applied for: <a href="#request.zos.globals.domain & link#">#job.job_title#</a> (#job.job_location#)</h3>
					<hr />
					<p>Please reply to this email to contact the applicant.</p>
					<p>Name: #form.first_name# #form.last_name#</p>
					<p>Email: #form.email#</p>
					<p>Phone: #application.zcore.functions.zFormatPhoneNumber( form.phone )#</p>
					<p>Cover Letter:<br />
						#form.cover_letter#
					</p>
				</body>
				</html>'
			);
		}

		ts.site_id = request.zos.globals.id;

		var jsonStruct = { arrCustom: [] };

		request.zos.arrForceEmailAttachment = [];

		uploadPath = request.zos.globals.privateHomeDir & "/zupload/resumes/";

		application.zcore.functions.zCreateDirectory( uploadPath );

		if ( form.resume_file NEQ "" ) {
			try {
				form.resume_file = application.zcore.functions.zUploadFile( "resume_file", uploadPath );
			} catch ( Any e ) {
				application.zcore.status.setStatus( request.zsid, "Invalid resume file type", form, true );
				application.zcore.functions.zRedirect( "/z/job/apply/index?jobId=#jobId#&zsid=#request.zsid#" );
			}

			if ( form.resume_file NEQ false ) {
				ts.attachments = [ uploadPath & form.resume_file ];

				arrayAppend( request.zos.arrForceEmailAttachment, uploadPath & form.resume_file );
				arrayAppend( jsonStruct.arrCustom, { label: "Resume", value: '<a href="#request.zos.globals.domain#/zupload/resumes/#form.resume_file#" target="_blank">Download Resume</a>' } );
			}
		}

		rCom = application.zcore.email.send( ts );

		if ( not rCom.isOK() ) {
			savecontent variable = "errorHTML" {
				a = rCom.getErrors( request.zsid );

				echo( arraytolist( a, "<br>" ) );

				application.zcore.status.setStatus( request.zsid, "Please complete the form and try again.", form, true );
				application.zcore.functions.zRedirect( "/z/job/apply/index?jobId=#jobId#&zsid=#request.zsid#" );
			}

			throw( "Failed to send log error email: " & errorHTML );
		}

		form.inquiries_first_name = application.zcore.functions.zso( form, 'first_name' );
		form.inquiries_last_name  = application.zcore.functions.zso( form, 'last_name' );
		form.inquiries_email      = form.email;
		form.inquiries_phone1     = form.phone;

		arrayAppend( jsonStruct.arrCustom, { label: "Job Title", value: job.job_title } );

		if ( form.cover_letter NEQ "" ) {
			arrayAppend( jsonStruct.arrCustom, { label: "Cover Letter", value: form.cover_letter } );
		}

		form.inquiries_datetime           = request.zos.mysqlnow;
		form.inquiries_custom_json        = serializeJson( jsonStruct );
		form.inquiries_type_id            = 17;
		form.inquiries_type_id_siteIdType = 4;
		form.inquiries_email              = form.email;
		form.inquiries_subject            = "New Job Application on #request.zos.globals.shortdomain#";

		application.zcore.functions.zRecordLead();

		application.zcore.functions.zRedirect( "/z/job/apply/thank-you?jobId=" & job.job_id );

	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	if(application.zcore.functions.zso(application.zcore.app.getAppData( 'job' ).optionStruct, 'job_config_disable_apply_online', true, 0) EQ 1){
		application.zcore.functions.z404("Apply online is disabled");
	}
		request.zos.currentURLISAJobPage = true;

		jobId = application.zcore.functions.zso(form, 'jobId');

		application.zcore.functions.zStatusHandler( request.zsid, true );

		jobCom     = application.zcore.app.getAppCFC( 'job' );
		jobComData = application.zcore.app.getAppData( 'job' );

		job = jobCom.getJobById( jobId );

		if ( NOT structKeyExists( job, 'job_status' ) ) {
			application.zcore.functions.z404( 'Job not found' );
		}
		if(job.job_apply_url NEQ ""){
			application.zcore.functions.zRedirect(job.job_apply_url);
		}

		if ( job.job_status NEQ 1 ) {
			application.zcore.functions.z404( 'Job not active' );
		}

		application.zcore.template.setTag( "title", 'Job Application - ' & jobComData.optionStruct.job_config_title );
		application.zcore.template.setTag( "pagetitle", jobComData.optionStruct.job_config_title );

		form.set9 = application.zcore.functions.zGetHumanFieldIndex();

	</cfscript>

	<div class="z-container">
		<div class="z-column">

			<form id="jobForm1" class="z-job-apply" action="" method="post" enctype="multipart/form-data" onsubmit="zSet9('zset9_#form.set9#');">
				<input type="hidden" name="zset9" id="zset9_#form.set9#" value="" />
				#application.zcore.functions.zFakeFormFields()#
				<input type="hidden" name="jobId" value="#job.job_id#" />

				<table class="table-list">
					<tr>
						<th>Applying for:</th>
						<td><strong class="z-t-24">#job.job_title#</strong><br />
							#job.job_location#
						</td>
					</tr>
					<tr>
						<th>First Name:</th>
						<td><input type="text" name="first_name" value="#htmlEditFormat( application.zcore.functions.zso( form, 'first_name' ) )#" /> <span style="color: ##FF0000;">*</span></td>
					</tr>
					<tr>
						<th>Last Name:</th>
						<td><input type="text" name="last_name" value="#htmlEditFormat( application.zcore.functions.zso( form, 'last_name' ) )#" /> <span style="color: ##FF0000;">*</span></td>
					</tr>
					<tr>
						<th>Email Address:</th>
						<td><input type="email" name="email" value="#htmlEditFormat( application.zcore.functions.zso( form, 'email' ) )#" /> <span style="color: ##FF0000;">*</span></td>
					</tr>
					<tr>
						<th>Phone Number:</th>
						<td><input type="text" name="phone" value="#htmlEditFormat( application.zcore.functions.zso( form, 'phone' ) )#" /> <span style="color: ##FF0000;">*</span></td>
					</tr>
					<tr>
						<th>Resume:</th>
						<td><input type="file" name="resume_file" /><br />
							<span style="color: ##999999;">Note: Please submit TXT, DOC, DOCX, RTF or PDF file. HTML and other formats may be blocked.</span>
						</td>
					</tr>
					<tr>
						<th>Cover Letter:</th>
						<td><textarea name="cover_letter" cols="60" rows="8">#htmlEditFormat( application.zcore.functions.zso( form, 'cover_letter' ) )#</textarea></td>
					</tr>
					<tr>
						<th>&nbsp;</th>
						<td><input type="submit" name="submit1" value="Submit Resume" class="z-button z-job-apply-submit" /></td>
					</tr>
				</table>
			</form>

		</div>
	</div>
	<div class="z-clear"></div>

	<script type="text/javascript">
		zArrDeferredFunctions.push( function() {
			$( '##jobForm1' ).bind( 'submit', function( event ) {
				this.action = '/z/job/apply/submit';
				return true;
			} );
		} );
	</script>

</cffunction>

<cffunction name="thank-you" localmode="modern" access="remote">
	<cfscript>
	if(application.zcore.functions.zso(application.zcore.app.getAppData( 'job' ).optionStruct, 'job_config_disable_apply_online', true, 0) EQ 1){
		application.zcore.functions.z404("Apply online is disabled");
	}
		jobId = application.zcore.functions.zso(form, 'jobId');

		jobCom     = application.zcore.app.getAppCFC( 'job' );
		jobComData = application.zcore.app.getAppData( 'job' );

		job = jobCom.getJobById( jobId );

		if ( NOT structKeyExists( job, 'job_status' ) ) {
			application.zcore.functions.z404( 'Job not found' );
		}

		if ( job.job_status NEQ 1 ) {
			application.zcore.functions.z404( 'Job not active' );
		}

		ts = structnew();

		ts.content_unique_name = '/z/job/apply/thank-you';
		ts.disableContentMeta  = false;
		ts.disableLinks        = true;

		if ( request.zos.originalURL EQ '/z/job/apply/thank-you' ) {
			r1 = application.zcore.app.getAppCFC( "content" ).includePageContentByName( ts );
			application.zcore.template.prependTag( 'meta', '<meta name="robots" content="noindex,follow" />' );
		} else {
			r1 = application.zcore.app.getAppCFC( "content" ).includeContentByName( ts );
		}

		if ( r1 EQ false ) {
			inquiryTextMissing = true;
		} else {
			inquiryTextMissing = false;
		}
	</cfscript>

	<cfif inquiryTextMissing>
		<cfscript>
			if ( request.zos.originalURL EQ '/z/job/apply/thank-you' ) {
				application.zcore.template.setTag( "title", "Thank you for submitting your resume" );
				application.zcore.template.setTag( "pagetitle", jobComData.optionStruct.job_config_title );
			}
		</cfscript>

		<p>Thank you for applying for the #job.job_title# position.<br />
			We have receieved your resume and will review your application.
		</p>
		<p><a href="#jobCom.getJobsHomePageLink()#" class="z-button z-job-apply-view-more">View More Jobs</a></p>
		<div class="z-clear"></div>
	</cfif>

</cffunction>

</cfoutput>
</cfcomponent>
