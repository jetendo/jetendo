<cfcomponent>
<cfoutput>
<cfscript>
this.app_id=18;
</cfscript>

<cffunction name="jobTypeToString" localmode="modern" output="no" returntype="any">
	<cfargument name="jobTypeId" type="numeric" required="yes">
	<cfscript>
		jobTypeId = arguments.jobTypeId;

		jobTypes = {
			0: 'Not Provided',
			1: 'Full-Time',
			2: 'Part-Time',
			3: 'Commission',
			4: 'Temporary',
			5: 'Temporary to Hire',
			6: 'Contract',
			7: 'Contract to Hire',
			8: 'Internship',
			9: 'Volunteer',
			10:'Per Diem'
		};

		if ( ! structKeyExists( jobTypes, jobTypeId ) ) {
			throw( 'Invalid job type ID "' & jobTypeId & '" when getting jobTypeToString.' );
		}

		return jobTypes[ jobTypeId ];
	</cfscript>
</cffunction>

<cffunction name="jobTypeStringToId" localmode="modern" output="no" returntype="any">
	<cfargument name="jobType" type="string" required="yes">
	<cfscript>
		jobType = arguments.jobType;

		jobTypes = {
			'':0,
			'Not Provided':0,
			'Full-Time':1,
			'Part-Time':2,
			'Commission':3,
			'Temporary':4 ,
			'Temporary to Hire':5,
			'Contract':6,
			'Contract to Hire':7,
			'Internship':8,
			'Volunteer':9,
			'Per Diem':10
		};

		if ( ! structKeyExists( jobTypes, jobType ) ) {
			throw( 'Invalid job type "' & jobType & '" when getting jobTypeStringToId.' );
		}

		return jobTypes[ jobType ];
	</cfscript>
</cffunction>


<cffunction name="getCSSJSIncludes" localmode="modern" output="no" returntype="any">
	<cfargument name="ss" type="struct" required="yes">
</cffunction>

<cffunction name="initAdmin" localmode="modern" output="no" access="public" returntype="any">
	<cfscript>
	</cfscript>
</cffunction>

<cffunction name="getRobotsTxt" localmode="modern" output="no" access="public" returntype="string" hint="Generate the Robots.txt file as a string">
	<cfargument name="site_id" type="numeric" required="yes">
	<cfscript>
	var qa="";
	var rs="";
	var c1="";
	var db=request.zos.queryObject;

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getSiteMap" localmode="modern" output="no" access="public" returntype="array" hint="add links to sitemap array">
	<cfargument name="arrUrl" type="array" required="yes">
	<cfscript>
	ts=application.zcore.app.getInstance(this.app_id);
	db=request.zos.queryObject;

	if(ts.optionstruct.job_config_job_index_url NEQ "{default}"){
		// jobs root url 
		t2=StructNew();
		t2.groupName="Job";
		t2.url=request.zos.currentHostName&ts.optionStruct.job_config_job_index_url;
		t2.title=ts.optionStruct.job_config_title;
		arrayappend(arguments.arrUrl,t2);
	}else{
		// default home url
		t2=StructNew();
		t2.groupName="Job";
		t2.url=request.zos.currentHostName&this.getJobLink(ts.optionStruct.job_config_misc_url_id,1,"html",ts.optionStruct.job_config_title);
		t2.title=ts.optionStruct.job_config_title;
		arrayappend(arguments.arrUrl,t2);
	}




	db.sql="SELECT * from #db.table("job_category", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and  
	job_category_deleted = #db.param(0)# ";
	db.sql&="ORDER BY job_category_unique_url DESC";
	qF=db.execute("qF");
	for(row in qF){
		t2=StructNew();
		t2.groupName="Job Category";
		t2.url=request.zos.currentHostName&getCategoryURL(row);
		t2.title=row.job_category_name;
		arrayappend(arguments.arrUrl,t2);
	}

	db.sql="SELECT * from #db.table("job", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and  
	job_deleted = #db.param(0)# and
	job_status = #db.param(1)# ";
	db.sql&="ORDER BY job_title ASC";
	qF=db.execute("qF");
	for(row in qF){
		t2=StructNew();
		t2.groupName="Job";

		t2.url=request.zos.currentHostName&getJobURL(row);

		t2.title=row.job_title;
		arrayappend(arguments.arrUrl,t2);
	}
	return arguments.arrURL;
	</cfscript>
</cffunction>



<cffunction name="getAdminLinks" localmode="modern" output="no" access="public" returntype="struct" hint="links for member area">
	<cfargument name="linkStruct" type="struct" required="yes">
	<cfscript>
		var ts = 0;

		if ( structKeyExists( request.zos.userSession.groupAccess, 'administrator' ) ) {
			if ( structKeyExists( arguments.linkStruct, 'Jobs' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Jobs';
				ts.link        = '/z/job/admin/manage-jobs/index';
				ts.children    = structNew();

				arguments.linkStruct['Jobs'] = ts;
			}

			if ( structKeyExists( arguments.linkStruct['Jobs'].children, 'Add Job' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Jobs';
				ts.link        = '/z/job/admin/manage-jobs/add';

				arguments.linkStruct['Jobs'].children['Add Job'] = ts;
			}

			if ( structKeyExists( arguments.linkStruct['Jobs'].children, 'Add Job Category' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Jobs';
				ts.link        = '/z/job/admin/manage-job-category/add';

				arguments.linkStruct['Jobs'].children['Add Job Category'] = ts;
			}

			if ( structKeyExists( arguments.linkStruct['Jobs'].children, 'Jobs' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Jobs';
				ts.link        = '/z/job/admin/manage-jobs/index';

				arguments.linkStruct['Jobs'].children['Jobs'] = ts;
			}

			if ( structKeyExists( arguments.linkStruct['Jobs'].children, 'Job Categories' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Jobs';
				ts.link        = '/z/job/admin/manage-job-category/index';

				arguments.linkStruct['Jobs'].children['Job Categories'] = ts;
			}

			if(application.zcore.user.checkServerAccess()){
				if ( structKeyExists( arguments.linkStruct['Jobs'].children, 'Job Import' ) EQ false ) {
					ts = structNew();

					ts.featureName = 'Job Import';
					ts.link        = '/z/job/admin/job-import/index';

					arguments.linkStruct['Jobs'].children['Job Import'] = ts;
				}
			}
			if ( structKeyExists( arguments.linkStruct['Jobs'].children, 'View Jobs Home Page' ) EQ false ) {
				ts = structNew();

				ts.featureName = 'Jobs';
				ts.link        = this.getJobsHomePageLink();

				arguments.linkStruct['Jobs'].children['View Jobs Home Page'] = ts;
			}
		}

		return arguments.linkStruct;
	</cfscript>
</cffunction>


<cffunction name="getAdminNavMenu" localmode="modern" access="public">
	<cfscript>
		application.zcore.template.setTag("title", "Jobs");
	</cfscript>
<!--- 
	<p>Manage: <a href="/z/job/admin/manage-job-category/index">Categories</a> | 
		<a href="/z/job/admin/manage-jobs/index">Jobs</a> 
		| Add:
		<a href="/z/job/admin/manage-job-category/add">Category</a> | 
		<a href="/z/job/admin/manage-jobs/add">Job</a>
	</p> --->
</cffunction>

<cffunction name="getCacheStruct" localmode="modern" output="no" access="public" returntype="struct" hint="publish the application cache">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfscript>
	var qdata=0;
	var ts=StructNew();
	var qdata=0;
	var arrcolumns=0;
	var i=0;
	var db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("job_config", request.zos.zcoreDatasource)# 
	where 
	site_id = #db.param(arguments.site_id)# and 
	job_config_deleted = #db.param(0)#";
	qData=db.execute("qData"); 
	for(row in qData){
		return row;
	}
	throw("job_config record is missing for site_id=#arguments.site_id#.");
	</cfscript>
</cffunction>


<!--- job category search indexing --->
	
<!--- application.zcore.app.getAppCFC("job").searchReindexCategory(false, true); --->
<cffunction name="searchReindexCategory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexEverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT job_category.*, job_config_job_url_id FROM #db.table("job_category", request.zos.zcoreDatasource)#,
		#db.table("job_config", request.zos.zcoreDatasource)# 
		WHERE 
		job_config.site_id = job_category.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and job_category.site_id = #db.param(request.zos.globals.id)# ";
		}else{
			db.sql&=" and job_category.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and job_category_id = #db.param(arguments.id)# ";
		}
		db.sql&=" and job_category_deleted=#db.param(0)# and 
		job_config_deleted =#db.param(0)#	
		LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteJob(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.job_category_name&" "&row.job_category_description;
				ds.search_title=row.job_category_name;
				//if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.job_category_description;
				//}
				ds.search_summary=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(ds.search_summary), 150);
				
				ds.search_url=getCategoryURL(row);
				ds.search_table_id="job-category-"&row.job_category_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=dateformat(row.job_category_updated_datetime, "yyyy-mm-dd")&" "&timeformat(row.job_category_updated_datetime, "HH:mm:ss");
				ds.site_id=row.site_id;
				
				searchCom.saveSearchIndex(ds); 
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and  
		search_table_id LIKE #db.param('job-category-%')# and
		search_deleted = #db.param(0)# and
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>


<!--- job search reindexing --->

<!--- application.zcore.app.getAppCFC("job").searchReindexJob(false, true); --->
<cffunction name="searchReindexJob" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="any" required="no" default="#false#">
	<cfargument name="indexEverything" type="boolean" required="no" default="#false#">
	<cfscript>
	db=request.zos.queryObject;
	startDate=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	searchCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.searchFunctions");
	
	offset=0;
	limit=30;
	while(true){
		db.sql="SELECT job.*, job_config_job_url_id FROM #db.table("job", request.zos.zcoreDatasource)#,
		#db.table("job_config", request.zos.zcoreDatasource)# 
		WHERE 
		job_config.site_id = job.site_id ";
		if(arguments.indexeverything EQ false){
			db.sql&=" and job.site_id = #db.param(request.zos.globals.id)# ";
		}else{
			db.sql&=" and job.site_id <> #db.param(-1)#  ";
		}
		if(arguments.id NEQ false){
			db.sql&=" and job_id = #db.param(arguments.id)# ";
		}
		db.sql&=" and job_status = #db.param(1)# and  
		job_deleted=#db.param(0)# and 
		job_config_deleted =#db.param(0)#	
		LIMIT #db.param(offset)#, #db.param(limit)#";
		qC=db.execute("qC");
		offset+=limit;
		if(qC.recordcount EQ 0){
			if(arguments.id NEQ false){
				this.searchIndexDeleteJob(arguments.id);
			}
			break;
		}else{
			for(row in qC){
				ds=searchCom.getSearchIndexStruct();
				ds.search_fulltext=row.job_title&" "&row.job_city&" "&row.job_summary&" "&row.job_overview;
				ds.search_title=row.job_title;
				//if(len(ds.search_summary) EQ 0){
					ds.search_summary=row.job_overview;
				//}
				ds.search_summary=application.zcore.functions.zLimitStringLength(application.zcore.functions.zRemoveHTMLForSearchIndexer(ds.search_summary), 150);
				
				ds.search_url=getJobURL(row);
				ds.search_table_id="job-"&row.job_id;
				ds.app_id=this.app_id;
				ds.search_content_datetime=dateformat(row.job_updated_datetime, "yyyy-mm-dd")&" "&timeformat(row.job_updated_datetime, "HH:mm:ss");
				ds.site_id=row.site_id;
				
				searchCom.saveSearchIndex(ds); 
				if(arguments.id NEQ false){
					return;
				}
			}
		}
	}
	if(arguments.indexeverything){
		db.sql="delete from #db.table("search", request.zos.zcoreDatasource)# WHERE 
		site_id <> #db.param(-1)# and 
		app_id = #db.param(this.app_id)# and  
		search_table_id LIKE #db.param('job-%')# and
		search_deleted = #db.param(0)# and
		search_updated_datetime < #db.param(startDate)#";
		db.execute("qDelete");
	}
	</cfscript>
</cffunction>
	
	
<!--- application.zcore.app.getAppCFC("job").searchIndexDeleteContent(job_id); --->
<cffunction name="searchIndexDeleteJob" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_table_id = #db.param("job-"&arguments.id)# and 
	search_deleted = #db.param(0)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>

	
<!--- application.zcore.app.getAppCFC("job").searchIndexDeleteContent(job_category_id); --->
<cffunction name="searchIndexDeleteCategory" localmode="modern" output="no" returntype="any">
	<cfargument name="id" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="DELETE FROM #db.table("search", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	app_id = #db.param(this.app_id)# and 
	search_table_id = #db.param("job-category-"&arguments.id)# and 
	search_deleted = #db.param(0)#";
	db.execute("qDelete");
	</cfscript>
</cffunction>

	

<cffunction name="setURLRewriteStruct" localmode="modern" output="no" access="public" returntype="any" hint="Generate the URL rewrite rules as a string">
	<cfargument name="site_id" type="numeric" required="yes" hint="site_id that need to be cached.">
	<cfargument name="sharedStruct" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject;
	var theText="";
	var qconfig=0;
	var t9=0;
	var qcontent=0;
	var link=0;
	var t999=0;
	var pos=0;

	db.sql="SELECT * FROM #db.table("job_config", request.zos.zcoreDatasource)# job_config, 
	#db.table("app_x_site", request.zos.zcoreDatasource)# app_x_site, 
	#db.table("site", request.zos.zcoreDatasource)# site 
	WHERE site.site_id = app_x_site.site_id and 
	app_x_site.site_id = job_config.site_id and 
	job_config.site_id = #db.param(arguments.site_id)# and 
	job_config_deleted = #db.param(0)# and 
	app_x_site_deleted = #db.param(0)# and 
	app_id = #db.param(this.app_id)# and
	site_deleted = #db.param(0)#";
	qConfig=db.execute("qConfig");  

	loop query="qConfig"{
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.job_config_job_url_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.job_config_misc_url_id]=[];
		arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.job_config_category_url_id]=[];

		if(qConfig.job_config_job_index_url NEQ "{default}"){
			t9=structnew();
			t9.scriptName="/z/job/job/index";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/job/job/index";
			
			arguments.sharedStruct.uniqueURLStruct[trim(qConfig.job_config_job_index_url)]=t9;
		}else{
			// ## job home
			//  /#name#-#appid#-#id#.#ext#
			t9=structnew();
			t9.type=1;
			t9.scriptName="/z/job/job/index";
			t9.ifStruct=structnew();
			t9.ifStruct.dataId="1";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/job/job/index";
			t9.mapStruct=structnew();
			t9.mapStruct.urlTitle="zURLName";
			arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.job_config_misc_url_id],t9);
		}

		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/job/view-job/viewJob";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/job/view-job/viewJob";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="job_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.job_config_job_url_id],t9); 

		t9=structnew();
		t9.type=1;
		t9.scriptName="/z/job/job-category/viewCategory";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/job/job-category/viewCategory";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="job_category_id";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.job_config_category_url_id],t9); 

		t9=structnew();
		t9.type=3;
		t9.scriptName="/z/job/job/index";
		t9.ifStruct=structnew();
		t9.ifStruct.dataId="1";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/job/job/index";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="urlid";
		t9.mapStruct.dataId2="zIndex";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.job_config_misc_url_id],t9);

		t9=structnew();
		t9.type=3;
		t9.scriptName="/z/job/job-category/viewCategory";
		t9.ifStruct=structnew();
		t9.ifStruct.ext="html";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/job/job-category/viewCategory";
		t9.urlStruct.method="index";
		t9.mapStruct=structnew();
		t9.mapStruct.urlTitle="zURLName";
		t9.mapStruct.dataId="job_category_id";
		t9.mapStruct.dataId2="zindex";
		arrayappend(arguments.sharedStruct.reservedAppUrlIdStruct[qConfig.job_config_category_url_id],t9);

		db.sql="SELECT * from #db.table("job", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(arguments.site_id)# and 
		job_unique_url<>#db.param('')# and 
		job_deleted = #db.param(0)#
		ORDER BY job_unique_url DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/job/view-job/viewJob";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/job/view-job/viewJob";
			t9.urlStruct.job_id=qF.job_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.job_unique_url)]=t9;
		}

		db.sql="SELECT * from #db.table("job_category", request.zos.zcoreDatasource)# 
		WHERE site_id=#db.param(arguments.site_id)# and 
		job_category_unique_url<>#db.param('')# and 
		job_category_deleted = #db.param(0)#
		ORDER BY job_category_unique_url DESC";
		qF=db.execute("qF");
		loop query="qF"{
			t9=structnew();
			t9.scriptName="/z/job/job-category/viewCategory";
			t9.urlStruct=structnew();
			t9.urlStruct[request.zos.urlRoutingParameter]="/z/job/job-category/viewCategory";
			t9.urlStruct.job_category_id=qF.job_category_id;
			arguments.sharedStruct.uniqueURLStruct[trim(qF.job_category_unique_url)]=t9;
		}
	} 
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRuleJob" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * from #db.table("job", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	job_unique_url<>#db.param('')# and 
	job_id=#db.param(arguments.id)# and 
	job_deleted = #db.param(0)#
	ORDER BY job_unique_url DESC";
	qF=db.execute("qF");
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/job/view-job/viewJob";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/job/view-job/viewJob";
		t9.urlStruct.job_id=qF.job_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.job_unique_url)]=t9;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRuleCategory" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="oldURL" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	s=application.sitestruct[request.zos.globals.id];

	db.sql="SELECT * from #db.table("job_category", request.zos.zcoreDatasource)# 
	WHERE site_id=#db.param(request.zos.globals.id)# and 
	job_category_unique_url<>#db.param('')# and 
	job_category_id=#db.param(arguments.id)# and 
	job_category_deleted = #db.param(0)#
	ORDER BY job_category_unique_url DESC";
	qF=db.execute("qF");
	if(qF.recordcount EQ 0){
		structdelete(s.urlRewriteStruct.uniqueURLStruct, arguments.oldURL);
	}
	loop query="qF"{
		t9=structnew();
		t9.scriptName="/z/job/job-category/viewCategory";
		t9.urlStruct=structnew();
		t9.urlStruct[request.zos.urlRoutingParameter]="/z/job/job-category/viewCategory";
		t9.urlStruct.job_category_id=qF.job_category_id;
		s.urlRewriteStruct.uniqueURLStruct[trim(qF.job_category_unique_url)]=t9;
	}
	return true;
	</cfscript>
</cffunction>

<cffunction name="updateRewriteRules" localmode="modern" output="no" access="public" returntype="boolean">
	<cfscript>
	application.zcore.routing.initRewriteRuleApplicationStruct(application.sitestruct[request.zos.globals.id]);
	return true;
	</cfscript>
</cffunction>

<cffunction name="configDelete" localmode="modern" output="no" access="public" returntype="any" hint="delete the record from config table.">
	<!--- delete all content and content_group and images? --->
	<cfscript>
	var db=request.zos.queryObject;
	var qconfig=0;
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	db.sql="DELETE FROM #db.table("job_config", request.zos.zcoreDatasource)#  
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	job_config_deleted = #db.param(0)#	";
	qConfig=db.execute("qConfig");
	return rCom;
	</cfscript>   
</cffunction>

<cffunction name="loadDefaultConfig" localmode="modern" output="no" access="public" returntype="boolean">
	<cfargument name="validate" required="no" type="boolean" default="#false#">
	<cfscript>
	var field="";
	var i=0;
	var error=false;
	var df=structnew();

	// Set config defaults here
	df.job_config_title = "Jobs";
	df.job_config_job_index_url = "{default}";

	for(i in df){	
		if(arguments.validate){
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){	
				error=true;
				field=trim(lcase(replacenocase(replacenocase(i,"job_config_",""),"_"," ","ALL")));
				application.zcore.status.setStatus(request.zsid,"#field# is required.",form);
			}
		}else{
			if(structkeyexists(form,i) EQ false or form[i] EQ ""){			
				form[i]=df[i];
			}
		}
	}
	if(error){
		return false;
	}else{
		return true;
	}
	</cfscript>
</cffunction>

<cffunction name="configSave" localmode="modern" output="no" access="remote" returntype="any" hint="saves the application data submitted by the change() form.">
	<cfscript>
	var ts=StructNew();
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");
	var result='';

	if(this.loadDefaultConfig(true) EQ false){
		rCom.setError("Please correct the above validation errors and submit again.",1);
		return rCom;
	}	

	form.site_id=form.sid; 

	ts=StructNew();
	ts.arrId=arrayNew(1);

	// Processing/validation of config options before save/update
	// Display error
	// application.zcore.status.setStatus(Request.zsid, 'Job no longer exists', form, true);

	arrayappend(ts.arrId,trim(form.job_config_job_url_id));
	arrayappend(ts.arrId,trim(form.job_config_misc_url_id));
	arrayappend(ts.arrId,trim(form.job_config_category_url_id));

	ts.site_id=form.site_id;
	ts.app_id=this.app_id;

	rCom=application.zcore.app.reserveAppUrlId(ts);


	// job_config_schema_logo
	StructDelete(variables,'job_config_schema_logo');
	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("job_config_schema_logo", application.zcore.functions.zVar('privatehomedir', form.site_id)&'zupload/settings/', '165x300');
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("job_config_schema_logo", application.zcore.functions.zVar('privatehomedir', form.site_id)&'zupload/settings/', '165x300', 'job_config', 'job_config_id', "job_config_schema_logo_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'job_config_schema_logo');
		StructDelete(variables,'job_config_schema_logo');
	}else if(ArrayLen(arrList) NEQ 0){
		form.job_config_schema_logo=arrList[1];
	}else{
		StructDelete(form,'job_config_schema_logo');
	}
	if(application.zcore.functions.zso(form,'job_config_schema_logo_delete',true) EQ 1){
		form.job_config_schema_logo='';	
	} 
	if(rCom.isOK() EQ false){
		return rCom;
		application.zcore.functions.zstatushandler(request.zsid);
		application.zcore.functions.zReturnRedirect(request.cgi_script_name&"?method=configForm&app_x_site_id=#this.app_x_site_id#&zsid=#request.zsid#");
		application.zcore.functions.zabort();
	} 
	form.job_config_deleted=0;
	form.job_config_updated_datetime=request.zos.mysqlnow;
	ts.table="job_config";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(application.zcore.functions.zso(form, 'job_config_id',true) EQ 0){ // insert
		result=application.zcore.functions.zInsert(ts);  
		if(result EQ false){
			rCom.setError("Failed to save configuration.",2);
			return rCom;
		}
	}else{ // update
		result=application.zcore.functions.zUpdate(ts);
		if(result EQ false){
			rCom.setError("Failed to save configuration.",3);
			return rCom;
		}
	}
	application.zcore.status.setStatus(request.zsid,"Configuration saved.");
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="configForm" localmode="modern" output="no" access="remote" returntype="any" hint="displays a form to add/edit applications.">
   	<cfscript>
	var db=request.zos.queryObject;
	var ts='';
	var selectStruct='';
	var rs=structnew();
	var qConfig='';
	var theText='';
	var rCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.zos.return");

	// Build the config form.

	savecontent variable="theText"{
		db.sql="SELECT * FROM #db.table("job_config", request.zos.zcoreDatasource)# job_config 
		WHERE site_id = #db.param(form.sid)# and 
		job_config_deleted = #db.param(0)#";
		qConfig=db.execute("qConfig");
		application.zcore.functions.zQueryToStruct(qConfig);//, "configStruct");
		if(qConfig.recordcount EQ 0){
			this.loadDefaultConfig();
		}
		application.zcore.functions.zStatusHandler(request.zsid,true);
		echo('<input type="hidden" name="job_config_id" value="#form.job_config_id#" />
		<table style="border-spacing:0px;" class="table-list">');

		echo('
		<tr>
		<th>Job Home Page Title:</th>
		<td>');
		ts = StructNew();
		ts.name = "job_config_title";
		ts.required = true;
		ts.defaultValue = "Jobs";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Job Home Page Meta Title:</th>
		<td>');
		ts = StructNew();
		ts.name = "job_config_home_metatitle";
		ts.required = true; 
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Job Home Page Meta Keywords:</th>
		<td>');
		ts = StructNew();
		ts.name = "job_config_home_metakey";
		ts.required = true; 
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Job Home Page Meta Description:</th>
		<td>');
		ts = StructNew();
		ts.name = "job_config_home_metadesc";
		ts.required = true; 
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Job Home Page URL:</th>
		<td>');
		ts = StructNew();
		ts.name = "job_config_job_index_url";
		ts.required = true;
		ts.defaultValue = "{default}";
		application.zcore.functions.zInput_Text(ts);
		echo('<br />(URL for listing all jobs in all categories) <a href="##" onclick=" document.getElementById(''job_config_job_index_url'').value=''{default}''; return false;">Restore default</a></td>
		</tr>
		<tr>
		<th>Job URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("job_config_job_url_id", form.job_config_job_url_id, this.app_id));
		echo('</td>
		</tr>
		<tr>
		<th>Category URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("job_config_category_url_id", form.job_config_category_url_id, this.app_id));
		echo('</td>
		</tr> 
		<tr>
		<th>Job Misc URL ID</th>
		<td>');
		writeoutput(application.zcore.app.selectAppUrlId("job_config_misc_url_id", form.job_config_misc_url_id, this.app_id));
		echo('</td>
		</tr>
		<tr>
		<th>Jobs are for this company only?</th>
		<td>');

		if(form.job_config_this_company EQ ""){
			form.job_config_this_company=1;
		}

		echo(application.zcore.functions.zInput_Boolean("job_config_this_company"));
		echo('<br /><br />Set to "No" if this site is listing jobs on behalf of other companies (enables the use of the "Company Name" field). Default: "Yes"</td>
		</tr>
		<tr>
		<th>Disable Apply Online?</th>
		<td>');

		if(form.job_config_disable_apply_online EQ ""){
			form.job_config_disable_apply_online=0;
		}

		echo(application.zcore.functions.zInput_Boolean("job_config_disable_apply_online"));
		echo('</td>
		</tr>

		
		<tr>
		<th>Company names globally hidden?</th>
		<td>');

		if(form.job_config_company_names_hidden EQ ""){
			form.job_config_company_names_hidden=0;
		}
		echo(application.zcore.functions.zInput_Boolean("job_config_company_names_hidden"));
		echo('<br /><br />Set to "Yes" to hide all job listing company names globally (only applies if "this company only?" is set to "No"). Default: "No"</td>
		</tr>
		<tr>
		<th>Enable Schema Data?</th>
		<td>');

		if(form.job_config_enable_schema_data EQ ""){
			form.job_config_enable_schema_data=0;
		}

		echo(application.zcore.functions.zInput_Boolean("job_config_enable_schema_data"));
		echo('</td>
		</tr>
		<tr>
		<th>Schema Company</th>
		<td>');
		ts = StructNew();
		ts.name = "job_config_schema_company";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Schema Website</th>
		<td>');
		ts = StructNew();
		ts.name = "job_config_schema_website";
		application.zcore.functions.zInput_Text(ts);
		echo('</td>
		</tr>
		<tr>
		<th>Schema Logo</th>
		<td>');
		echo(application.zcore.functions.zInputImage('job_config_schema_logo', application.zcore.functions.zVar('privatehomedir', form.sid)&'settings/', application.zcore.functions.zvar('domain', form.sid)&'/zupload/settings/'));
		echo('</td>
		</tr>
		');
		echo('</table>');


	}
	rs.output=theText;
	rCom.setData(rs);
	return rCom;
	</cfscript>
</cffunction>


<cffunction name="onRequestStart" localmode="modern" output="yes" returntype="void">
	<cfscript>

	// application.zcore.skin.includeJS("/z/javascript/jetendo-job/calendar.js");
	</cfscript>
</cffunction>

<cffunction name="onRequestEnd" localmode="modern" output="yes" returntype="void" hint="Runs after zos end file.">
	<cfscript>
	
	</cfscript>
</cffunction>


<cffunction name="getJobURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.job_unique_url NEQ ""){
		return row.job_unique_url;
	}else{
		urlId=application.zcore.app.getAppData("job").optionstruct.job_config_job_url_id;
		return "/"&application.zcore.functions.zURLEncode(row.job_title, '-')&"-"&urlId&"-"&row.job_id&".html";
	}
	</cfscript>
</cffunction>


<cffunction name="getCategoryURL" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	if(row.job_category_unique_url NEQ ""){
		return row.job_category_unique_url;
	}else{
		urlId=application.zcore.app.getAppData("job").optionstruct.job_config_category_url_id;
		return "/"&application.zcore.functions.zURLEncode(row.job_category_name, '-')&"-"&urlId&"-"&row.job_category_id&".html";
	}
	</cfscript>
</cffunction>



<cffunction name="onSiteStart" access="public" localmode="modern">
	<cfargument name="sharedStruct" type="struct" required="yes" hint="Exclusive application scope structure for this application.">
	<cfscript>
	ts={}; 

	// Cached data

	arguments.sharedStruct=ts;
	return arguments.sharedStruct;
	</cfscript>
</cffunction>


<cffunction name="isCurrentPageInJob" localmode="modern" returntype="boolean" access="remote">
	<cfscript>
	if(structkeyexists(request.zos, 'currentURLISAJobPage')){
		return true;
	}else{
		return false;
	}
	</cfscript>
</cffunction>

<cffunction name="getJobLink" localmode="modern" returntype="string" output="no">
	<cfargument name="appid" type="string" required="yes">
	<cfargument name="id" type="string" required="yes">
	<cfargument name="ext" type="string" required="yes">
	<cfargument name="name" type="string" required="yes">
	<cfscript>
	return "/"&application.zcore.functions.zURLEncode(arguments.name,'-')&"-"&arguments.appid&"-"&arguments.id&"."&arguments.ext;
	</cfscript>
</cffunction>

<cffunction name="getJobsHomePageLink" localmode="modern" returntype="string" output="no">
	<cfscript>
		ts2 = application.zcore.app.getInstance( this.app_id );

		if ( ts2.optionStruct.job_config_job_index_url NEQ '{default}' ) {
			return request.zos.currentHostName & ts2.optionStruct.job_config_job_index_url;
		} else {
			// Default home url
			return this.getJobLink( ts2.optionStruct.job_config_misc_url_id, 1, 'html', ts2.optionStruct.job_config_title );
		}
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
		request.zos.currentURLISAJobPage = true;

		jobHomePageTitle = application.zcore.app.getAppData( 'job' ).optionStruct.job_config_title;

		form.zIndex = application.zcore.functions.zso( form, 'zIndex', true, 1 );

		if ( form.zIndex LTE 0 ) {
			form.zIndex = 1;
		}

		form.job_category_id = application.zcore.functions.zso( form, 'job_category_id' );
		form.company         = application.zcore.functions.zso( form, 'company' );

		if ( form.company NEQ '' ) {
			showCompanyNamePageTitle = false;

			if ( application.zcore.app.getAppData( 'job' ).optionStruct.job_config_this_company EQ 0 ) {
				showCompanyNamePageTitle = true;

				if ( application.zcore.app.getAppData( 'job' ).optionStruct.job_config_company_names_hidden EQ 1 ) {
					// If company names are hidden globally, then we should 404.
					application.zcore.functions.z404( 'Not found' );
				}
			}

			if ( showCompanyNamePageTitle ) {
				jobHomePageTitle = form.company & ' Jobs';
			}
		}

		optionStruct=application.zcore.app.getAppData( 'job' ).optionStruct;
		job_config_home_metatitle=application.zcore.functions.zso(optionStruct, 'job_config_home_metatitle');
		job_config_home_metakey=application.zcore.functions.zso(optionStruct, 'job_config_home_metakey');
		job_config_home_metadesc=application.zcore.functions.zso(optionStruct, 'job_config_home_metadesc');
		application.zcore.template.setTag( "title", jobHomePageTitle ); 
		if (job_config_home_metatitle NEQ "") {
			application.zcore.template.setTag( "title", job_config_home_metatitle );
		}
		application.zcore.template.setTag("meta", '<meta name="keywords" content="#htmleditformat(job_config_home_metakey)#" />
			<meta name="description" content="#htmlEditFormat(job_config_home_metadesc)#" />');
		application.zcore.template.setTag( "pagetitle", jobHomePageTitle );

		// TODO: Get all the job categories and show as a list in a sidebar.
	</cfscript>

	<div class="z-job-rows">
		<cfscript>
			countLimit = 10;

			jobSearch = {
				perpage: countLimit,
				// categories: form.job_category_id,
				company: form.company,
				offset: ( ( form.zIndex - 1 ) * countLimit )
			};

			jobResults = this.searchJobs( jobSearch );

			ts = {
				jobResults: jobResults,
				countLimit: countLimit,
				searchView: 'index'
			};

			this.outputJobResults( ts );
		</cfscript>
		<div class="z-clear"></div>
	</div>

</cffunction>

<!--- 
ts={
	// all criteria optional
	job_id:"",
	categories:"",
	keyword:"",
	company:"",
	offset:"0",
	perpage:"10", 
	showInactive:false
};
searchJobs(ts);
 --->
<cffunction name="searchJobs" access="public" localmode="modern">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	db=request.zos.queryObject;
	ss.perpage=application.zcore.functions.zso(ss, 'perpage', true, 10);
	ss.offset=application.zcore.functions.zso(ss, 'offset', true);
	ss.job_id=application.zcore.functions.zso(ss, 'job_id', true);
	ss.categories=application.zcore.functions.zso(ss, 'categories');
	ss.keyword=application.zcore.functions.zso(ss, 'keyword');
	ss.company=application.zcore.functions.zso(ss, 'company');
 	ss.showInactive=application.zcore.functions.zso(ss, 'showInactive');

	if(not application.zcore.user.checkGroupAccess("member")){
		ts.showInactive=false;
	}

	ss.keyword=replace(replace(ss.keyword, '+', '%', 'all'), ' ', '%', 'all');

	arrCategory=listToArray(ss.categories, ',');
	if(arraylen(arrCategory)){
		arrCategory2=[];
		for(i=1;i LTE arraylen(arrCategory);i++){
			if(isnumeric(trim(arrCategory[i]))){
				arrayAppend(arrCategory2, arrCategory[i]);
			}
		}
		arrCategory=arrCategory2;
	}

	ts=structnew();
	ts.image_library_id_field="job.job_image_library_id";
	ts.count = 1; // how many images to get
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);

	// By default we feel that most sites will be set up for 'this company' so
	// we don't need to include the company name in the search query.
	// This variable changes how the SQL query is built below.
	searchingForCompanyName = false;

	// However, if this site is set up to list jobs for other companies...
	if ( application.zcore.app.getAppData( 'job' ).optionStruct.job_config_this_company EQ 0 ) {
		// Then include the company name in the __FRONT END__ search query by default.
		searchingForCompanyName = true;

		// ... BUT if we want the company names hidden...
		if ( application.zcore.app.getAppData( 'job' ).optionStruct.job_config_company_names_hidden EQ 1 ) {
			// Then do not include the company name in the __FRONT END__ search query.
			searchingForCompanyName = false;
		}
	}


	if ( searchingForCompanyName EQ false ) {
		ss.company = '';
	}


	db.sql="select * ";

	if ( ss.keyword NEQ "" ) {

		if ( searchingForCompanyName ) {
			db.sql &= ", IF ( concat(job.job_id, #db.param(' ')#, job_title, #db.param(' ')#, job_company_name, #db.param(' ')#, job_city, #db.param(' ')#, job_summary, #db.param(' ')#, job_overview) LIKE #db.param( '%' & application.zcore.functions.zURLEncode( ss.keyword, '%' ) & '%' )#, #db.param( '1' )#, #db.param( '0' )# ) exactMatch,
				MATCH( `job_search` ) AGAINST( #db.param( ss.keyword )# ) relevance ";
		} else {
			db.sql &= ", IF ( `job_search` LIKE #db.param( '%' & application.zcore.functions.zURLEncode( ss.keyword, '%' ) & '%' )#, #db.param( '1' )#, #db.param( '0' )# ) exactMatch,
				MATCH( `job_search` ) AGAINST( #db.param( ss.keyword )# ) relevance ";
		}
	}

	db.sql &= "
	#db.trustedsql(rs2.select)# from 
	#db.table("job", request.zos.zcoreDatasource)#
	#db.trustedsql(rs2.leftJoin)#
	WHERE 
	job.site_id = #db.param(request.zos.globals.id)# and 
	job_deleted=#db.param(0)# ";
	if(ss.showInactive NEQ 1){
		db.sql&=" and job.job_status=#db.param(1)# ";
	}
	if(ss.job_id NEQ 0){
		db.sql&=" and job.job_id = #db.param(ss.job_id)# ";
	}

	// Only display jobs where the posted date is before right now and the closed date is after right now (or not set).
	db.sql&=" and job_posted_datetime <= #db.param(request.zos.mysqlnow)# ";
	db.sql&=" and ( job_closed_datetime >= #db.param(request.zos.mysqlnow)# OR job_closed_datetime = #db.param('0000-00-00 00:00:00')# ) ";

	if ( ss.company NEQ "" ) {
		if ( searchingForCompanyName ) {
			db.sql &= " and ( job_company_name LIKE #db.param( '%' & ss.company & '%' )# AND job_company_name_hidden = #db.param( 0 )# ) ";
		}
	}

	if(ss.keyword NEQ ""){
		searchOn=true;

		if ( searchingForCompanyName ) {
			db.sql &= " and ( MATCH( `job_search` ) AGAINST ( #db.param( ss.keyword )# ) ";
			db.sql &= " or concat(job.job_id, #db.param(' ')#, job_title, #db.param(' ')#, job_company_name, #db.param(' ')#, job_city, #db.param(' ')#, job_summary, #db.param(' ')#, job_overview)  like #db.param('%#ss.keyword#%')# ";
			db.sql &= " ) ";
		} else {
			db.sql &= " and ( MATCH( `job_search` ) AGAINST ( #db.param( ss.keyword )# ) ";
			db.sql &= " or job_search LIKE #db.param( '%' & ss.keyword & '%' )# ) ";
		}

		db.sql &= " and ( MATCH( `job_search` ) AGAINST ( #db.param( ss.keyword )# ) ";
		db.sql &= " or concat(job.job_id, #db.param(' ')#, job_title, #db.param(' ')#, job_company_name, #db.param(' ')#, job_city, #db.param(' ')#, job_summary, #db.param(' ')#, job_overview)  like #db.param('%#ss.keyword#%')# ";
		db.sql &= " ) ";
	}

	if(arraylen(arrCategory)){
		db.sql&=" and ( ";
		searchOn=true;
		for(i=1;i LTE arraylen(arrCategory);i++){
			if(i NEQ 1){
				db.sql&=" or ";
			}
			db.sql&=" CONCAT(#db.param(',')#,job_category_id, #db.param(',')#) LIKE #db.param('%,'&arrCategory[i]&',%')# ";
		}
		db.sql&=" ) ";
	}

	db.sql &= " GROUP BY job.job_id ";

	if ( ss.keyword NEQ "" ) {
		db.sql &= " ORDER BY exactMatch DESC, relevance DESC";
	} else {
		db.sql &= " ORDER BY job_featured DESC, job_posted_datetime DESC";
	}

	db.sql&="
	 LIMIT #db.param(ss.offset)#, #db.param(ss.perpage)# ";

	qList=db.execute("qList");

	if(request.zos.isdeveloper and structkeyexists(form, 'zdebug')){
		writedump(qList);
	}

	if(ss.offset EQ 0 and ( qList.recordcount LT ss.perpage)){
		qCount={count:qList.recordcount};
	}else{

		db.sql="select count(job_id) count from 
		#db.table("job", request.zos.zcoreDatasource)#
		WHERE job.site_id = #db.param(request.zos.globals.id)# and 
		job_deleted=#db.param(0)# ";

		if(ss.showInactive NEQ 1){
			db.sql&=" and job.job_status=#db.param(1)# ";
		}

		if(ss.job_id NEQ 0){
			db.sql&=" and job.job_id = #db.param(ss.job_id)# ";
		}

		// Only display jobs where the posted date is before right now and the closed date is after right now (or not set).
		db.sql&=" and job_posted_datetime <= #db.param(request.zos.mysqlnow)# ";
		db.sql&=" and ( job_closed_datetime >= #db.param(request.zos.mysqlnow)# OR job_closed_datetime = #db.param('0000-00-00 00:00:00')# ) ";

		if ( ss.company NEQ "" ) {
			if ( searchingForCompanyName ) {
				db.sql &= " and ( job_company_name LIKE #db.param( '%' & ss.company & '%' )# AND job_company_name_hidden = #db.param( 0 )# ) ";
			}
		}

		if(ss.keyword NEQ ""){
			searchOn=true;

			if ( searchingForCompanyName ) {
				db.sql &= " and ( MATCH( `job_search` ) AGAINST ( #db.param( ss.keyword )# ) ";
				db.sql &= " or concat(job.job_id, #db.param(' ')#, job_title, #db.param(' ')#, job_company_name, #db.param(' ')#, job_city, #db.param(' ')#, job_summary, #db.param(' ')#, job_overview)  like #db.param('%#ss.keyword#%')# ";
				db.sql &= " ) ";
			} else {
				db.sql &= " and MATCH( `job_search` ) AGAINST ( #db.param( ss.keyword )# ) ";
			}
		}

		if(arraylen(arrCategory)){
			db.sql&=" and ( ";
			searchOn=true;
			for(i=1;i LTE arraylen(arrCategory);i++){
				if(i NEQ 1){
					db.sql&=" or ";
				}
				db.sql&=" CONCAT(#db.param(',')#,job_category_id, #db.param(',')#) LIKE #db.param('%,'&arrCategory[i]&',%')# ";
			}
			db.sql&=" ) ";
		}

		qCount=db.execute("qCount"); 
	}
	arrData=[];
	jobCom=application.zcore.app.getAppCFC("job");
	hasPhotos=false;
	for(row in qList){
		row.__url=jobCom.getJobURL(row);

		hasPhotos=true;
		arrayAppend(arrData, row);
	}
	return { count: qCount.count, hasPhotos:hasPhotos, arrData: arrData };
	</cfscript>
</cffunction>

<cffunction name="outputJobResults" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
		ss = arguments.ss;

		jobResults        = application.zcore.functions.zso( ss, 'jobResults' );
		countLimit        = application.zcore.functions.zso( ss, 'countLimit' );
		searchView        = application.zcore.functions.zso( ss, 'searchView' );
		currentPageStruct = application.zcore.functions.zso( ss, 'currentPageStruct' );

		form.job_category_id = application.zcore.functions.zso( form, 'job_category_id' );

		db = request.zos.queryObject;

		countTotal = jobResults.count;

		if ( countTotal GT 0 ) {
			jobs = jobResults.arrData;

			// Loop through the jobs that were found and output each.
			for ( job in jobs ) {
				this.outputJobRow( job );
			}

			// required
			searchStruct = StructNew();

			searchStruct.count             = countTotal;
			searchStruct.index             = form.zIndex;
			searchStruct.indexName         = "zIndex";
			searchStruct.buttons           = 5;
			searchStruct.perpage           = countLimit;
			searchStruct.parseURLVariables = true;
			searchStruct.firstPageHack     = true;

			if ( searchView EQ 'index' ) {
				searchStruct.url          = this.getJobLink( application.zcore.app.getAppData("job").optionStruct.job_config_misc_url_id, '1_##zIndex##', "html", application.zcore.app.getAppData("job").optionStruct.job_config_title );
				searchStruct.firstpageurl = this.getJobLink( application.zcore.app.getAppData("job").optionStruct.job_config_misc_url_id, 1, "html", application.zcore.app.getAppData("job").optionStruct.job_config_title );
			} else if ( searchView EQ 'category' ) {
				searchStruct.url          = this.getJobLink( application.zcore.app.getAppData("job").optionStruct.job_config_category_url_id, currentPageStruct.job_category_id & '_##zIndex##', "html", currentPageStruct.job_category_name );
				searchStruct.firstpageurl = this.getJobLink( application.zcore.app.getAppData("job").optionStruct.job_config_category_url_id, currentPageStruct.job_category_id, "html", currentPageStruct.job_category_name );
			} else {
				// Same as index
				searchStruct.url          = this.getJobLink( application.zcore.app.getAppData("job").optionStruct.job_config_misc_url_id, '1_##zIndex##', "html", application.zcore.app.getAppData("job").optionStruct.job_config_title );
				searchStruct.firstpageurl = this.getJobLink( application.zcore.app.getAppData("job").optionStruct.job_config_misc_url_id, 1, "html", application.zcore.app.getAppData("job").optionStruct.job_config_title );
			}


			var searchNav = application.zcore.functions.zSearchResultsNav( searchStruct );
			echo( '<div class="z-column z-pv-40 z-job-pagination">' );

			writeoutput(searchNav);

			echo( '</div>' );
		} else {
			echo( '<div class="z-column">No jobs were found.</div><div class="z-clear"></div>' );
		}
	</cfscript>
</cffunction>

<cffunction name="outputJobRow" localmode="modern" access="public">
	<cfargument name="job" type="struct" required="yes">
	<cfscript>
		job = arguments.job;

		// Only active jobs can be displayed using this function.
		if ( job.job_status NEQ 1 ) {
			return;
		}

		// Determine whether or not we should display the company name.
		showCompanyName            = false;
		showCompanyNamePlaceholder = '';

		if ( application.zcore.app.getAppData( 'job' ).optionStruct.job_config_this_company EQ 0 ) {
			showCompanyName = true;

			if ( application.zcore.app.getAppData( 'job' ).optionStruct.job_config_company_names_hidden EQ 1 ) {
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
		jobImageLibrary.crop             = 0;
		jobImageLibrary.count            = 1;

		jobImages = application.zcore.imageLibraryCom.displayImages( jobImageLibrary );

		if ( arrayLen( jobImages ) GT 0 ) {
			jobImage = request.zos.currentHostName & jobImages[ 1 ].link;
		}
	</cfscript>

	<div class="z-column z-job-row <cfif job.job_featured EQ 1>z-job-featured</cfif> z-center-children-at-992">
		<cfif jobImage NEQ ''>
			<div class="z-1of4 z-m-0 z-p-0 z-job-row-image">
				<a href="#job.__url#"><img src="#jobImage#" alt="#htmlEditFormat( job.job_title )#" class="z-fluid" /></a>
			</div>
			<div class="z-3of4 z-job-row-content">
		<cfelse>
			<div class="z-1of1 z-job-row-content">
		</cfif>

			<h2 class="z-job-row-title"><a href="#job.__url#">#job.job_title#</a></h2>

			<div class="z-job-row-details">
				<cfif job.job_type NEQ 0>
					<span class="z-job-row-job-type">#this.jobTypeToString( job.job_type )#</span> - 
				</cfif>
				<span class="z-job-row-posted">Posted <span class="z-job-row-posted-date">#application.zcore.functions.zTimeSinceDate( job.job_posted_datetime, true )#</span></span><br />

				<cfif showCompanyName EQ true AND job.job_company_name NEQ ''>
					<a href="#this.getJobsHomePageLink()#?company=#urlEncodedFormat( job.job_company_name )#" class="z-job-row-company-name">#job.job_company_name#</a>
				<cfelse>
					<cfif showCompanyNamePlaceholder NEQ ''>
						<span class="z-job-row-company-name-placeholder">#showCompanyNamePlaceholder#</span>
					</cfif>
				</cfif>

				<cfif job.job_location NEQ ''>
					- <span class="z-job-row-location">#htmlEditFormat( job.job_location )#</span>
				</cfif>

				<cfif job.job_category_id NEQ ''>
					<cfscript>
						jobCategories = this.getJobCategories( job.job_category_id );
					</cfscript>
					- <span class="z-job-row-categories">Categories:
					<cfloop from="1" to="#arrayLen( jobCategories )#" index="jobCategoryIndex">
						<cfscript>jobCategory = jobCategories[ jobCategoryIndex ];</cfscript>
						<a href="#jobCategory.__url#">#jobCategory.job_category_name#</a><cfif jobCategoryIndex LT arrayLen( jobCategories )>, </cfif>
					</cfloop>
				</cfif>

			</div>

			<cfif job.job_summary NEQ ''>
				<div class="z-t-16 z-job-row-summary">
					#job.job_summary#
				</div>
			</cfif>

			<div class="z-job-row-buttons">
				<cfif application.zcore.functions.zso(application.zcore.app.getAppData( 'job' ).optionStruct, 'job_config_disable_apply_online', true, 0) EQ 0>
	
					<cfif job.job_apply_url NEQ "">
						<a href="#job.job_apply_url#" class="z-button z-job-row-button apply-now" target="_blank"><div class="z-t-16">Apply Now</div></a>
					<cfelse>
						<a href="#request.zos.globals.domain#/z/job/apply/index?jobId=#job.job_id#" class="z-button z-job-row-button apply-now"><div class="z-t-16">Apply Now</div></a>
					</cfif>
				</cfif>
				<a href="#job.__url#" class="z-button z-job-row-button view-details"><div class="z-t-16">View Details</div></a>
			</div>
		</div>
	</div>
</cffunction>

<cffunction name="getJobCategories" localmode="modern" access="public">
	<cfargument name="categoryIdList" type="string" required="no" default="0">
	<cfargument name="getJobCount" type="string" required="no" default="#false#">
	<cfscript>
	getJobCount=arguments.getJobCount;
	categoryIdList = arguments.categoryIdList;

	ts = application.zcore.app.getInstance( this.app_id );

	db = request.zos.queryObject;

	// TODO - Category sorting - currently sorting by name, needs to sort by job_category_sort when implemented.
	if ( categoryIdList EQ 0 ) {
		db.sql = "SELECT job_category.* ";
		if(getJobCount){
			db.sql&=" , COUNT(job.job_id) COUNT ";
		}
		db.sql&="FROM #db.table( 'job_category', request.zos.zcoreDatasource )# ";
		if(getJobCount){
			db.sql&=" LEFT JOIN 
			#db.table("job", request.zos.zcoreDatasource)# ON 
			LOCATE(CONCAT(#db.param(',')#, job_category.job_category_id, #db.param(',')#), CONCAT(#db.param(',')#, job.job_category_id, #db.param(',')#)) <> #db.param(0)# 
			AND 
			job.site_id = job_category.site_id and 
			job_deleted=#db.param(0)# ";
		}
		db.sql&="
		WHERE job_category.site_id = #db.param( request.zos.globals.id )#
			AND job_category_deleted = #db.param( 0 )#
		GROUP BY job_category.job_category_id 
		ORDER BY job_category_name ASC ";
	} else {
		categoryIdArray = listToArray( categoryIdList, ',' );
		for(i=1;i<=arrayLen(categoryIdArray);i++){
			categoryIdArray[i]="'"&application.zcore.functions.zEscape(categoryIdArray[i])&"'";
		}

		db.sql = "SELECT job_category.*";
		if(getJobCount){
			db.sql&=", COUNT(job.job_id) COUNT ";
		}
		db.sql&=" FROM #db.table( 'job_category', request.zos.zcoreDatasource )# ";
		if(getJobCount){
			db.sql&=" LEFT JOIN 
			#db.table("job", request.zos.zcoreDatasource)# ON 
			LOCATE(CONCAT(#db.param(',')#, job_category.job_category_id, #db.param(',')#), CONCAT(#db.param(',')#, job.job_category_id, #db.param(',')#)) <> #db.param(0)# 
			AND 
			job.site_id = job_category.site_id and 
			job_deleted=#db.param(0)# ";
		}
		db.sql&="
		WHERE job_category.site_id = #db.param( request.zos.globals.id )#
			AND job_category.job_category_id IN ( #db.trustedSQL( arrayToList( categoryIdArray, ',' ) )# )
			AND job_category_deleted = #db.param( 0 )#
		GROUP BY job_category.job_category_id 
		ORDER BY job_category_name ASC ";
	}

	qCategories = db.execute( 'qCategories' );

	categories = [];

	for ( category in qCategories ) {

		if ( category.job_category_unique_url NEQ '' ) {
			category.__url = category.job_category_unique_url;
		} else {
			category.__url = this.getJobLink( ts.optionStruct.job_config_category_url_id, category.job_category_id, 'html', category.job_category_name );
		}

		arrayAppend( categories, category );
	}

	return categories;
	</cfscript>
</cffunction>

<cffunction name="getJobById" localmode="modern" access="public">
	<cfargument name="jobId" type="string" required="yes">
	<cfscript>
		jobId = arguments.jobId;

		jobSearch = {
			job_id: jobId,
			perpage:1
		};

		jobs = this.searchJobs( jobSearch );

		job = {};
		if ( structKeyExists( jobs, 'count' ) ) {
			if ( jobs.count GT 0 ) {
				job = jobs.arrData[ 1 ];
				if(job.job_id NEQ jobId){
					return {};
				}
			}
		}

		return job;
	</cfscript>
</cffunction>

<cffunction name="deleteJobsOlderThenDate" localmode="modern" access="public">
	<cfargument name="d" type="date" required="yes">
	<cfscript>
	d=dateformat(arguments.d, "yyyy-mm-dd")&" "&timeformat(arguments.d, "HH:mm:ss");
	db=request.zos.queryObject;
 
	db.sql="select * from #db.table("job", request.zos.zcoreDatasource)# WHERE 
	site_id=#db.param(request.zos.globals.id)# and 
	job_deleted=#db.param(0)# and 
	job_updated_datetime<#db.param(d)#";
	qJob=db.execute("qJob");
	for(row in qJob){
		deleteJobByStruct(row);
	}  
	</cfscript>
</cffunction>

<cffunction name="deleteJobByStruct" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	var db=request.zos.queryObject; 

	application.zcore.imageLibraryCom.deleteImageLibraryId(ss.job_image_library_id);

	db.sql="DELETE FROM #db.table("job_x_category", request.zos.zcoreDatasource)#  
	WHERE job_id= #db.param(ss.job_id)# and 
	job_x_category_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	q=db.execute("q");

	application.zcore.functions.zDeleteUniqueRewriteRule(ss.job_unique_url);

	db.sql="DELETE FROM #db.table("job", request.zos.zcoreDatasource)#  
	WHERE job_id= #db.param(ss.job_id)# and 
	job_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	q=db.execute("q");


	searchIndexDeleteJob(ss.job_id);
	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>
