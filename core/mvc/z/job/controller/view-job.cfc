<cfcomponent>
<cfoutput>
<cffunction name="getSchemaJobType" localmode="modern" access="public">
	<cfargument name="job_type" type="string" required="yes">
	<cfscript>
	job_type=arguments.job_type;
	if(job_type EQ 1){
		return "FULL_TIME";
	}else if(job_type EQ 2){
		return "PART_TIME";
	}else if(job_type EQ 3){
		return "OTHER";
	}else if(job_type EQ 4){
		return "TEMPORARY";
	}else if(job_type EQ 5){
		return "OTHER";
	}else if(job_type EQ 6){
		return "CONTRACTOR";
	}else if(job_type EQ 7){
		return "OTHER";
	}else if(job_type EQ 8){
		return "INTERN";
	}else if(job_type EQ 9){
		return "VOLUNTEER";
	}else if(job_type EQ 10){
		return "PER_DIEM";
	}
	return "OTHER";
	</cfscript>
</cffunction>


<cffunction name="displayJob" localmode="modern" access="private">
	<cfargument name="struct" type="struct" required="yes">
	<cfscript>
		request.zos.currentURLISAJobPage = true;

		db=request.zos.queryObject;
		job=arguments.struct;

		if ( job.job_status NEQ 1 ) {
			application.zcore.template.prependTag("content", '<div class="zJobView-preview-message">This job is not active. The public can''t view it until it is made active.</div>');
		}
		optionStruct=application.zcore.app.getAppData( 'job' ).optionStruct;

		jobCom = application.zcore.app.getAppCFC("job");
		jobComData = application.zcore.app.getAppData("job");

		application.zcore.template.setTag("meta", '<meta name="Keywords" content="#htmleditformat(job.job_metakey)#" /><meta name="Description" content="#htmleditformat(job.job_metadesc)#" />');
		if(job.job_metatitle NEQ ""){
			application.zcore.template.setTag( "title", job.job_metatitle);
		}else{
			application.zcore.template.setTag( "title", job.job_title & ' - ' & jobComData.optionStruct.job_config_title );
		}
		application.zcore.template.setTag( "pagetitle", jobComData.optionStruct.job_config_title );


		// Determine whether or not we should display the company name.
		showCompanyName            = false;
		showCompanyNamePlaceholder = '';

		if ( optionStruct.job_config_this_company EQ 0 ) {
			showCompanyName = true;

			if ( optionStruct.job_config_company_names_hidden EQ 1 ) {
				showCompanyName = false;
				showCompanyNamePlaceholder = 'Confidential';
			}

			if ( job.job_company_name_hidden EQ 1 ) {
				showCompanyName = false;
				showCompanyNamePlaceholder = 'Confidential';
			}
		}

		// Get the first image in the job's image library.
		jobImage        = '';
		jobImageLibrary = structNew();

		jobImageLibrary.image_library_id = job.image_library_id;
		jobImageLibrary.output           = false;
		jobImageLibrary.size             = '320x240';
		jobImageLibrary.crop             = 1;
		jobImageLibrary.count            = 1;

		jobImages = application.zcore.imageLibraryCom.displayImages( jobImageLibrary );

		if ( arrayLen( jobImages ) GT 0 ) {
			jobImage = request.zos.currentHostName & jobImages[ 1 ].link;
		}
	countryName=application.zcore.functions.zCountryAbbrToFullName(job.job_country);
	</cfscript>
<cfif application.zcore.functions.zso(jobComData.optionStruct, "job_config_enable_schema_data", true, 0) EQ 1>
	<cfsavecontent variable="meta">
		<script type="application/ld+json">
		<!--- required --->
		{
			"@context": "https://schema.org",
			"@type": "JobPosting",
			"datePosted": "#dateformat(job.job_posted_datetime, "YYYY-MM-DD")#",
			"description": "#jsstringformat(application.zcore.email.convertHTMLToText(job.job_summary))#",
			"hiringOrganization": {
			  "@type": "Organization",
			  "name": "#jobComData.optionStruct.job_config_schema_company#",
			  "sameAs": "#jobComData.optionStruct.job_config_schema_website#",
			  "logo": "#request.zos.globals.domain#/zupload/settings/#jobComData.optionStruct.job_config_schema_logo#"
			},
			"jobLocation": {
			  "@type": "Place",
			  "address": {
			    "@type": "PostalAddress",
			    "streetAddress": "#job.job_address#<cfif job.job_address2 NEQ "">, #job.job_address2#</cfif>",
			    "addressLocality": "#job.job_city#",
			    "addressRegion": "#job.job_state#",
			    "postalCode": "#job.job_zip#",
			    "addressCountry": "#job.job_country#"
			  }
			},
			"title": "#job.job_title#",
			<cfif job.job_closed_datetime NEQ "">
			"validThrough": "#dateformat(job.job_closed_datetime, "YYYY-MM-DD")#T00:00",
			<cfelse>
			"validThrough": "#dateformat(dateadd("d", 365, now()), "YYYY-MM-DD")#T00:00",
			</cfif>


			<!--- optional --->
			<cfif job.job_work_hours NEQ "">
				"workHours": "#job.job_work_hours#",
			</cfif>
			<cfif job.job_telecommute EQ 1>
				"jobLocationType": "TELECOMMUTE",
			</cfif>

			"employmentType": "#getSchemaJobType(job.job_type)#",
			<!--- FULL_TIME|PART_TIME|CONTRACTOR|TEMPORARY|INTERN|VOLUNTEER|PER_DIEM|OTHER --->

			"identifier": {
			  "@type": "PropertyValue",
			  "name": "#jobComData.optionStruct.job_config_schema_company#",
			  "value": "job-#job.job_id#"
			}

			<!--- 
			skip these:
			"applicantLocationRequirements": {
			    "@type": "Country",
			    "name": "United States"
			 }, 

			"baseSalary": {
			  "@type": "MonetaryAmount",
			  "currency": "USD",
			  "value": {
			    "@type": "QuantitativeValue",
			    "value": 40.00,
			    "unitText": "HOUR"
			  }
			}
			--->
		}
</script>
	</cfsavecontent>
	<cfscript>
	application.zcore.template.appendTag("meta", meta);
	</cfscript>
</cfif>

	<div id="zcidspan#application.zcore.functions.zGetUniqueNumber()#" class="zOverEdit zEditorHTML" data-editurl="/z/job/admin/manage-jobs/edit?job_id=#job.job_id#&amp;return=1">
		<div class="z-job">
			<div class="z-column">
				<h1 class="z-job-title"><a href="#job.__url#">#job.job_title#</a></h1>
				<div class="z-job-details">
					<div class="z-job-view-row">
						<cfif job.job_type NEQ 0>
							<span class="z-job-job-type">#jobCom.jobTypeToString( job.job_type )#</span> - 
						</cfif>
						<span class="z-job-posted">Posted <span class="z-job-posted-date">#application.zcore.functions.zTimeSinceDate( job.job_posted_datetime, true )#</span></span> 
					</div>
					<cfif job.job_telecommute EQ 1>
						<div class="z-job-view-row z-bold">
						Telecommute Position
						</div>
					</cfif>

					<cfif showCompanyName EQ true AND job.job_company_name NEQ ''>
						<div class="z-job-view-row">
						Company: <a href="#jobCom.getJobsHomePageLink()#?company=#urlEncodedFormat( job.job_company_name )#" class="z-job-company-name">#htmleditformat(job.job_company_name)#</a>
						</div>
					<cfelse>
						<cfif showCompanyNamePlaceholder NEQ ''>
							<div class="z-job-view-row">
								<span class="z-job-company-name-placeholder">Company: #htmleditformat(showCompanyNamePlaceholder)#</span>
							</div>
						</cfif>
					</cfif>
	 
					<cfif job.job_address NEQ "" or job.job_location NEQ "">
						<div class="z-job-view-row">Job Location:</div>
						<div class="z-job-view-row">
							<div class="zJobView1-2">
								<cfif job.job_location NEQ "">
									#htmleditformat(job.job_location)#<br />
								</cfif>
								<cfif job.job_address NEQ ""> 
									#htmleditformat(job.job_address)#<br />
								</cfif>
								#htmleditformat(job.job_city)# #htmleditformat(job.job_state)# #htmleditformat(job.job_zip)# 
								<cfif job.job_country NEQ "US">
									#countryName#
								</cfif>
							</div>
						</div>
					</cfif> 
					<cfif job.job_work_hours NEQ "">
						<div class="z-job-view-row">
						Work Hours: #job.job_work_hours#
						</div>
					</cfif>
					<cfif job.job_phone NEQ "">
						<div class="z-job-view-row">Phone: <a class="zPhoneLink">#htmleditformat(job.job_phone)#</a></div> 
					</cfif>

					<cfif job.job_category_id NEQ ''>
						<cfscript>
							jobCategories = jobCom.getJobCategories( job.job_category_id );
						</cfscript>
						<div class="z-job-view-row">
							<span class="z-job-categories">Categories:
							<cfloop from="1" to="#arrayLen( jobCategories )#" index="jobCategoryIndex">
								<cfscript>jobCategory = jobCategories[ jobCategoryIndex ];</cfscript>
								<a href="#jobCategory.__url#">#jobCategory.job_category_name#</a><cfif jobCategoryIndex LT arrayLen( jobCategories )>, </cfif>
							</cfloop>
						</div>
					</cfif>
				</div>

				<cfif left(job.job_website, 7) EQ "http://" or left(job.job_website, 8) EQ "https://">
					<div class="z-job-view-row z-job-website">
						Website: <a href="#htmleditformat(job.job_website)#" target="_blank">#htmleditformat(job.job_website)#</a> 
					</div>
				</cfif>
				<cfif application.zcore.functions.zso(optionStruct, 'job_config_disable_apply_online', true, 0) EQ 0>
					<div class="z-job-buttons">
						<cfif job.job_apply_url NEQ "">
							<a href="#job.job_apply_url#" class="z-button z-job-row-button apply-now" target="_blank"><div class="z-t-16">Apply Now</div></a>
						<cfelse>
							<a href="#request.zos.globals.domain#/z/job/apply/index?jobId=#job.job_id#" class="z-button z-job-button apply-now"><div class="z-t-16">Apply Now</div></a>
						</cfif>
						
					</div>
				</cfif>
				<div class="z-t-16 z-job-overview">
					<cfif job.job_overview NEQ ''>
						#job.job_overview#
					<cfelseif job.job_summary NEQ ''>
						#job.job_summary#
					</cfif>
				</div>

				<cfif structKeyExists( job, 'image_library_id' ) AND job.image_library_id NEQ ''>
					<div class="z-job-images">
						<cfscript>
							ts = structnew();

							ts.defaultAltText   = "Image";
							ts.output           = true;
							ts.image_library_id = job.job_image_library_id;
							ts.forceSize        = true;
							ts.size="1920x1080";
							ts.thumbSize             = "320x240"; 
							ts.layoutType       = "thumbnails-and-lightbox";
							ts.crop             = 1;
							ts.offset           = 0;
							ts.limit            = 0; // zero will return all images

							request.zos.imageLibraryCom.displayImages( ts );
						</cfscript>
					</div>
				</cfif>
			</div>
		</div>
	</div>
	<div class="z-float">
		<div class="z-job">
			<div class="z-column">
				<cfif job.job_map_coordinates NEQ "">
					<div class="z-job-map">
						<cfscript>
							google_map_info = job.job_city & ", " & job.job_state;
						</cfscript>
						<cfsavecontent variable="scriptOutput">
							<cfscript>
							application.zcore.functions.zRequireGoogleMaps();
							</cfscript> 
							<script>
							/* <![CDATA[ */
							var curMap=false;
							var arrAdditionalLocationLatLng=[];
							<cfscript> 
							arrLocation=[];
							ts={
								coordinates:job.job_map_coordinates,
								info:"#google_map_info#"
							};
							arrayAppend(arrLocation, ts);   
							echo('arrAdditionalLocationLatLng=#serializeJson(arrLocation)#');
							</cfscript>  
							var markerCompleteCount=0;
							var arrMarker=[];
							function markerCallback(markerObj, location){  
								markerCompleteCount++;
								if(markerCompleteCount ==arrAdditionalLocationLatLng.length){
									zMapFitMarkers(curMap, arrMarker);
								}
							} 
							zArrMapFunctions.push(function(){ 
								if(arrAdditionalLocationLatLng.length){
									var optionsObj={ 
										zoom: 8
									};
									var mapOptions = {
										zoom: 8,
										mapTypeId: google.maps.MapTypeId.ROADMAP
									}
									for(var i in optionsObj){
										mapOptions[i]=optionsObj[i];
									} 
									$("##mapContainerDiv").show();
									curMap=zCreateMap("mapDivId", mapOptions);  
									for(var i=0;i<arrAdditionalLocationLatLng.length;i++){ 
										var c=arrAdditionalLocationLatLng[i];
										var markerObj={};
										markerObj.infoWindowHTML=c.info;
										var arrLatLng=arrAdditionalLocationLatLng[i].coordinates.split(","); 
										var marker=zAddMapMarkerByLatLng(curMap, markerObj, arrLatLng[0], arrLatLng[1], markerCallback);  
										arrMarker.push(marker);
									}  
								}
							});
							/* ]]> */
							</script> 
						</cfsavecontent>
						<cfscript>
						request.zos.template.appendTag("scripts", scriptOutput);
						</cfscript>
						<div id="mapContainerDiv" style="width:100%; display:none; margin-bottom:20px; float:left;">
							<div style="width:100%; float:left; height:420px;" id="mapDivId"></div> 
						</div> 
					</div>
				</cfif>

				<div class="z-job-buttons">
					<a href="#jobCom.getJobsHomePageLink()#" class="z-button z-job-button more-jobs"><div class="z-t-16">More Jobs</div></a>
				</div>

			</div>
		</div>
		<div class="z-clear"></div>
	</div>



<!---
	<cfsavecontent variable="scriptOutput">
		<cfscript>
		application.zcore.functions.zRequireGoogleMaps();
		</cfscript>  
		<script>
		/* <![CDATA[ */
		function zJobMapSuccessCallback(){
			$("##zJobViewMapContainer").show();
		}
		zArrMapFunctions.push(function(){
			//$("##zJobSlideshowDiv").cycle({timeout:3000, speed:1200});
			//$( "##startdate" ).datepicker();
			//$( "##enddate" ).datepicker();
			<cfif struct.job_address NEQ "">
				var optionsObj={ zoom: 13 };
				var markerObj={
					infoWindowHTML:'<a href="https://maps.google.com/maps?q=#urlencodedformat(struct.job_address&", "&struct.job_city&", "&struct.job_state&" "&struct.job_zip&" "&struct.job_country)#" target="_blank">Get Directions on Google Maps</a>'
				};
				<cfif struct.job_map_coordinates NEQ "">
					arrLatLng=[#struct.job_map_coordinates#]; 
					zCreateMapWithLatLng("zJobMapDivId", arrLatLng[0], arrLatLng[1], optionsObj, zJobMapSuccessCallback, markerObj);  
				<cfelse>
					zCreateMapWithAddress("zJobMapDivId", "#jsstringformat(struct.job_address&', '&struct.job_city&", "&struct.job_state&" "&struct.job_zip&" "&application.zcore.functions.zCountryAbbrToFullName(struct.job_country))#", optionsObj, zJobMapSuccessCallback); 
				</cfif>
			</cfif> 
		});
		/* ]]> */
		</script> 
	</cfsavecontent>
	<cfscript>
	request.zos.template.appendTag("meta", scriptOutput); 
	request.zos.template.setTag("title", struct.job_title);
	request.zos.template.setTag("pagetitle", struct.job_title);


	</cfscript>


	<div class="zJobView1-4">
		<div class="zJobView1-1">Date:</div>
		<div class="zJobView1-2">
		#jobCom.getDateTimeRangeString(struct)# 
		</div>
	</div>

	<cfscript>

	savecontent variable="slideShowOut"{
		echo('<div class="zJobView1-3">');
		ts=structnew();
		ts.output=true;
		ts.size=request.zos.globals.maximagewidth&"x"&(request.zos.globals.maximagewidth*.6);
		ts.image_library_id=struct.job_image_library_id;
		ts.layoutType=application.zcore.imageLibraryCom.getLayoutType(struct.job_image_library_layout);
		ts.forceSize=true; 
		ts.crop=0;
		ts.offset=0;
		ts.limit=0;  
		arrImage=request.zos.imageLibraryCom.displayImages(ts); 
		ts.layoutType="";
		ts.output=false;
		ts.size="1900x1080";
		arrImage2=request.zos.imageLibraryCom.displayImages(ts); 
		echo('<div id="zJobViewLightGallery" class="zJobView1-larger">  ');
		for(i=1;i LTE arraylen(arrImage2);i++){
			echo('<a href="#arrImage2[i].link#" title="Image #i#" onclick="return false;" ');
			if(i NEQ 1){
				echo('style="display:none;"');
			}
			echo('>View larger images</a>');
		}
		echo('</div>');
		application.zcore.functions.zSetupLightbox("zJobViewLightGallery");
		echo('</div>');
	}
	if(application.zcore.imageLibraryCom.isBottomLayoutType(struct.job_image_library_layout)){
		slideshowOutBottom=slideshowOut;
		slideshowOutTop="";
	}else{
		slideshowOutTop=slideshowOut;
		slideshowOutBottom="";
	}
	</cfscript>
	

	#slideshowOutTop#
	<div style="width:100%; float:left;">
		<cfif struct.job_overview NEQ "">
	
			<div class="zJobView1-3">
				<h2>Job Description</h2>
				#struct.job_overview#
			</div>
		</cfif>
		<div class="zJobView1-3">
			<cfif struct.job_address NEQ "">
				<div class="zJobView1-0">
					<div class="zJobView1-1">Location:</div>
					<div class="zJobView1-2">
						<cfif struct.job_location NEQ "">
							#struct.job_location#<br />
						</cfif>
						#htmleditformat(struct.job_address)#<br />
						#struct.job_city#

						#htmleditformat(struct.job_state&" "&struct.job_zip)# 
						<cfif struct.job_country NEQ "US">
							#countryName#
						</cfif>
					</div>
				</div>
			</cfif> 
			<cfif struct.job_phone NEQ "">
				<div class="zJobView1-0">
					<div class="zJobView1-1">Phone:</div>
					<div class="zJobView1-2"><a class="zPhoneLink">#htmleditformat(struct.job_phone)#</a></div>
				</div>
			</cfif>
			<cfif left(struct.job_website, 7) EQ "http://" or left(struct.job_website, 8) EQ "https://">
				<div class="zJobView1-0">
					<div class="zJobView1-1">Website:</div>
					<div class="zJobView1-2"><a href="#htmleditformat(struct.job_website)#" target="_blank">#htmleditformat(struct.job_website)#</a></div>
				</div>
			</cfif>
			<cfif struct.job_file1 NEQ "" or struct.job_file2 NEQ "">
				<div class="zJobView1-0">
					<div class="zJobView1-1">Download Files:</div>
					<div class="zJobView1-2">
						<cfif struct.job_file1 NEQ "">
							<a href="#htmleditformat("/zupload/job/"&struct.job_file1)#" target="_blank">
								<cfif struct.job_file1label NEQ "">
									#struct.job_file1label#
								<cfelse>
									File 1
								</cfif>
							</a>
						</cfif>
						<cfif struct.job_file2 NEQ "">
							<br /><a href="#htmleditformat("/zupload/job/"&struct.job_file2)#" target="_blank">
								<cfif struct.job_file2label NEQ "">
									#struct.job_file2label#
								<cfelse>
									File 2
								</cfif>
							</a>
						</cfif>
					</div>
				</div>
			</cfif>
			<div class="zJobView1-0">
				<div class="zJobView1-1">Share:</div>
				<div class="zJobView1-2"> 
					<a href="##"  data-ajax="false" onclick="zShowModalStandard('/z/misc/share-with-friend/index?title=#urlencodedformat(struct.job_title)#&amp;link=#urlencodedformat(request.zos.currentHostName&struct.__url)#', 540, 630);return false;" rel="nofollow" style="display:block; float:left; margin-right:10px;"><img src="/z/images/job/share_03.jpg" alt="Share by email" width="30" height="30" /></a>
					<a href="https://www.facebook.com/sharer/sharer.php?u=#urlencodedformat(request.zos.currentHostName&struct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/job/share_05.jpg" alt="Share on facebook" width="30" height="30" /></a>
					<a href="https://twitter.com/share?url=#urlencodedformat(request.zos.currentHostName&struct.__url)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/job/share_07.jpg" alt="Share on twitter" width="30" height="30" /></a>
					<a href="http://www.linkedin.com/shareArticle?mini=true&amp;url=#urlencodedformat(request.zos.currentHostName&struct.__url)#&amp;title=#urlencodedformat(struct.job_title)#&amp;summary=&amp;source=#urlencodedformat(request.zos.globals.shortDomain)#" target="_blank" style="display:block; float:left; margin-right:10px;"><img src="/z/images/job/share_09.jpg" alt="Share on linkedin" width="30" height="30" /></a> 
					<a href="##" onclick="window.print(); return false;" target="_blank" class="zJobView1-print" rel="nofollow">Print</a>
				</div>
			</div>

			<cfif application.zcore.functions.zso(application.zcore.app.getAppData("job").optionStruct, 'job_config_add_to_calendar_enabled') EQ "1">
				<cfscript>
				application.zcore.skin.includeJS("//addthisjob.com/libs/1.6.0/ate.min.js");
				arrLocation=[];
				if(struct.job_location NEQ ""){
					arrayAppend(arrLocation, struct.job_location);
				}
				if(struct.job_address NEQ ""){
					arrayAppend(arrLocation, struct.job_address&", ");
				}
				if(struct.job_city NEQ ""){
					arrayAppend(arrLocation, struct.job_city&", ");
				}
				if(struct.job_state NEQ ""){
					arrayAppend(arrLocation, struct.job_state);
				}
				if(struct.job_zip NEQ ""){
					arrayAppend(arrLocation, struct.job_zip);
				}
				if(struct.job_country NEQ "" and struct.job_country NEQ "US"){
					arrayAppend(arrLocation, countryName);
				}
				locationText=arrayToList(arrLocation, " ");
				</cfscript>
				<div class="zJobView1-0">
					<div class="zJobView1-1">&nbsp;</div>
					<div class="zJobView1-2"> 

						<div title="Add to Calendar" class="addthisjob">
							Add to Your Calendar
							<span class="start">#dateformat(struct.job_posted_datetime, "mm/dd/yyyy")# #timeformat(struct.job_posted_datetime, "HH:mm tt")#</span>
							<span class="end">#dateformat(struct.job_closed_datetime, "mm/dd/yyyy")# #timeformat(struct.job_closed_datetime, "HH:mm tt")#</span>
							<span class="timezone">America/New_York</span>
							<span class="title">#struct.job_title#</span>
							<span class="description">#application.zcore.functions.zRemoveHTMLForSearchIndexer(struct.job_overview)#</span>
							<cfif locationText NEQ "">
								<span class="location">#locationText#</span>
							</cfif>
							<span class="all_day_job"><cfif struct.job_allday EQ 1>true<cfelse>false</cfif></span>
							<span class="date_format">MM/DD/YYYY</span>
						</div>
				
					</div>
				</div>
			</cfif>

		</div>
		<cfif struct.job_address NEQ "">
			<div id="zJobViewMapContainer">
				<div class="zJobView1-Map"  id="zJobMapDivId"></div>
				<div style="width:100%; float:left;padding-top:10px; padding-bottom:10px;"> <a href="https://maps.google.com/maps?q=#urlencodedformat(struct.job_address&", "&struct.job_city&", "&struct.job_state&" "&struct.job_zip&" "&struct.job_country)#" target="_blank">Launch In Google Maps</a></div>
			</div>
		</cfif>
	</div>  
	#slideshowOutBottom#

	<a href="#calendarLink#" class="zJobView1-backToCalendar">Back To Calendar</a>
	<cfif application.zcore.user.checkGroupAccess("member") and application.zcore.adminSecurityFilter.checkFeatureAccess("Jobs", true)>
		<a href="/z/job/admin/manage-jobs/edit?job_id=#struct.job_id#&amp;return=1" class="zNoContentTransition zJobView1-backToCalendar" style="margin-left:10px;">Edit</a>
	</cfif>

--->
 	
</cffunction>
</cfoutput>

<cffunction name="viewJob" localmode="modern" access="remote">
	<cfscript>
		db=request.zos.queryObject; 
		form.job_id=application.zcore.functions.zso(form, 'job_id', true);
		ts.job_id=form.job_id;
		ts.perpage=1;

		if(application.zcore.user.checkGroupAccess("member")){
			ts.showInactive=true;
		}
		jobCom=application.zcore.app.getAppCFC("job");
		rs=jobCom.searchJobs(ts);
		if(rs.count EQ 0){
			jobCom=application.zcore.app.getAppCFC("job");
			rs=jobCom.searchJobs(ts);
		} 
		if(rs.count NEQ 1){
			application.zcore.functions.z404("Job, #form.job_id#, is missing");
		}

		row=rs.arrData[1];


		if(structkeyexists(form, 'zUrlName')){
			if(row.job_unique_url EQ ""){

				curLink=row.__url; 
				urlId=application.zcore.app.getAppData("job").optionstruct.job_config_job_url_id;
				actualLink="/"&application.zcore.functions.zURLEncode(form.zURLName, '-')&"-"&urlId&"-"&row.job_id&".html";

				if(compare(curLink,actualLink) neq 0){
					application.zcore.functions.z301Redirect(curLink);
				}
			}else{
				if(compare(row.job_unique_url, request.zos.originalURL) NEQ 0){
					application.zcore.functions.z301Redirect(row.job_unique_url);
				}
			}
		}

		displayJob( row );

	</cfscript>
</cffunction>
</cfcomponent>