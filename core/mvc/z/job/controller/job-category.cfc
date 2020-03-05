<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	
	if ( not request.zos.istestserver ) {
		application.zcore.functions.z404("Invalid request");
	}
	</cfscript>
</cffunction>

<cffunction name="viewCategory" localmode="modern" access="remote">
	<cfscript>
		request.zos.currentURLISAJobPage = true;

		db = request.zos.queryObject;

		form.zIndex = application.zcore.functions.zso( form, 'zIndex', true, 1 );

		if ( form.zIndex LTE 0 ) {
			form.zIndex = 1;
		}

		form.job_category_id = application.zcore.functions.zso( form, 'job_category_id', true );

		db.sql = "SELECT * FROM #db.table( "job_category", request.zos.zcoreDatasource )#
		WHERE site_id = #db.param( request.zos.globals.id )#
			AND job_category_deleted=#db.param( 0 )#
			AND job_category_id = #db.param( form.job_category_id )# ";
		qCategory=db.execute( "qCategory", "", 10000, "query", false ); 

		application.zcore.functions.zQueryToStruct( qCategory, form );

		if ( qCategory.recordcount EQ 0 ) {
			application.zcore.functions.z404( "form.job_category_id, #form.job_category_id#,  doesn't exist." );
		}

		categoryStruct = {};
		for ( row in qCategory ) {
			categoryStruct = row;
		} 

		jobCom     = application.zcore.app.getAppCFC("job");
		jobComData = application.zcore.app.getAppData("job");

		application.zcore.template.setTag("meta", '<meta name="Keywords" content="#htmleditformat(qCategory.job_category_metakey)#" /><meta name="Description" content="#htmleditformat(qCategory.job_category_metadesc)#" />');
		if(qCategory.job_category_metatitle NEQ ""){
			application.zcore.template.setTag( "title", qCategory.job_category_metatitle);
		}else{
			application.zcore.template.setTag( "title", qCategory.job_category_name & ' - ' & jobComData.optionStruct.job_config_title );
		}
		application.zcore.template.setTag( "pagetitle", jobComData.optionStruct.job_config_title );

		if ( structkeyexists( form, 'zUrlName' ) ) {
			if ( categoryStruct.job_category_unique_url EQ "" ) {

				curLink = application.zcore.app.getAppCFC( "job" ).getCategoryURL( categoryStruct ); 
				urlId = application.zcore.app.getAppData( "job" ).optionstruct.job_config_category_url_id;
				actualLink = "/" & application.zcore.functions.zURLEncode( form.zURLName, '-' ) & "-" & urlId & "-" & categoryStruct.job_category_id & ".html";

				if( compare( curLink,actualLink ) neq 0 ){
					application.zcore.functions.z301Redirect( curLink );
				}
			} else {
				if ( form.zIndex EQ 1 ) {
					if( compare( categoryStruct.job_category_unique_url, request.zos.originalURL ) NEQ 0 ){
						application.zcore.functions.z301Redirect( categoryStruct.job_category_unique_url );
					}
				}
			}
		}
	</cfscript>

	<div class="z-float z-job-category-title">
		<div class="z-column">
			<h1>#htmlEditFormat( categoryStruct.job_category_name )#</h1>
		</div>
	</div>

	<cfif categoryStruct.job_category_description NEQ ''>
		<div class="z-float z-job-category-description">
			<div class="z-column">
				#categoryStruct.job_category_description#
			</div>
		</div>
	</cfif>

	<div class="z-float z-job-category-jobs">
		<cfscript>
			countLimit = 5;

			jobSearch = {
				perpage: countLimit,
				categories: form.job_category_id,
				offset: ( ( form.zIndex - 1 ) * countLimit )
			};

			jobResults = application.zcore.app.getAppCFC( "job" ).searchJobs( jobSearch );

			ts = {
				jobResults: jobResults,
				countLimit: countLimit,
				searchView: 'category',
				currentPageStruct: categoryStruct
			};

			application.zcore.app.getAppCFC( "job" ).outputJobResults( ts );

		</cfscript>
	</div>
	<div class="z-clear"></div>

</cffunction>
</cfoutput>
</cfcomponent>
