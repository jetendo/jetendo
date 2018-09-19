<cfcomponent>
<cfoutput>


<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Jobs", true);	
	db.sql="SELECT * FROM #db.table("job_category", request.zos.zcoreDatasource)# job_category
	WHERE job_category_id= #db.param(application.zcore.functions.zso(form,'job_category_id'))# and 
	job_category_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Job category no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/job/admin/manage-job-category/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript> 
		application.zcore.functions.zDeleteUniqueRewriteRule(qCheck.job_category_unique_url);

		db.sql="DELETE FROM #db.table("job_category", request.zos.zcoreDatasource)#  
		WHERE job_category_id= #db.param(application.zcore.functions.zso(form, 'job_category_id'))# and 
		job_category_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q"); 

		db.sql="DELETE FROM #db.table("job_x_category", request.zos.zcoreDatasource)#  
		WHERE job_category_id= #db.param(application.zcore.functions.zso(form, 'job_category_id'))# and 
		job_x_category_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");

		jobCom=application.zcore.app.getAppCFC("job");
		jobCom.searchIndexDeleteCategory(form.job_category_id);

		if(form.returnJson EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else{
			application.zcore.status.setStatus(Request.zsid, 'Job category deleted');
			application.zcore.functions.zRedirect('/z/job/admin/manage-job-category/index?zsid=#request.zsid#');
		}
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this job category?<br />
			<br />
			#qCheck.job_category_name#<br />
			<br />
			<a href="/z/job/admin/manage-job-category/delete?confirm=1&amp;job_category_id=#form.job_category_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/job/admin/manage-job-category/index">No</a> 
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="member">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="member">
	<cfscript>
	var ts={};
	db=request.zos.queryObject;
	var result=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Jobs", true);	
	form.site_id = request.zos.globals.id;
	ts.job_category_name.required = true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(application.zcore.functions.zso(form,'job_category_unique_url') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'job_category_unique_url'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		result=true;
	}
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/job/admin/manage-job-category/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/job/admin/manage-job-category/edit?job_category_id=#form.job_category_id#&zsid=#request.zsid#');
		}
	}


	uniqueChanged=false;
	oldURL='';
	if(form.method EQ 'insert' and application.zcore.functions.zso(form, 'job_category_unique_url') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ 'update'){
		db.sql="SELECT * FROM #db.table("job_category", request.zos.zcoreDatasource)# 
		WHERE job_category_id = #db.param(form.job_category_id)# and 
		job_category_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this job category.',form,true);
			application.zcore.functions.zRedirect('/z/job/admin/manage-job-category/index?zsid=#request.zsid#');
		}
		oldURL=qCheck.job_category_unique_url;
		if(structkeyexists(form, 'job_category_unique_url') and qcheck.job_category_unique_url NEQ form.job_category_unique_url){
			uniqueChanged=true;	
		}
	}

	ts=StructNew();
	ts.table='job_category';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.job_category_id = application.zcore.functions.zInsert(ts);
		if(form.job_category_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save job category.',form,true);
			application.zcore.functions.zRedirect('/z/job/admin/manage-job-category/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Job category saved.');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save job category.',form,true);
			application.zcore.functions.zRedirect('/z/job/admin/manage-job-category/edit?job_category_id=#form.job_category_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Job category updated.');
		}
		
	} 
	jobCom=application.zcore.app.getAppCFC("job");

	if(uniqueChanged){
		jobCom.updateRewriteRuleCategory(form.job_category_id, oldURL);	
	}
	jobCom.searchReindexCategory(form.job_category_id, false);

	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect('/z/job/admin/manage-job-category/getReturnJobCategoryRowHTML?job_category_id=#form.job_category_id#');
	}else{
		application.zcore.functions.zRedirect('/z/job/admin/manage-job-category/index?zsid=#request.zsid#');
	}
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
	application.zcore.functions.zSetPageHelpId("11.4");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Jobs");	
	if(application.zcore.functions.zso(form,'job_category_id') EQ ''){
		form.job_category_id = -1;
	}
	db.sql="SELECT * FROM #db.table("job_category", request.zos.zcoreDatasource)# job_category 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	job_category_deleted = #db.param(0)# and 
	job_category_id=#db.param(form.job_category_id)#";
	qJob=db.execute("qJob");
	application.zcore.functions.zQueryToStruct(qJob);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced',true, 0);
	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}
	</cfscript>
	<h2>
		<cfif currentMethod EQ "add">
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		<cfelse>
			Edit
		</cfif> Job Category</h2>
		<p>* Denotes required field.</p>
	<form class="zFormCheckDirty" action="/z/job/admin/manage-job-category/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?job_category_id=#form.job_category_id#" method="post">
		<input type="hidden" name="modalpopforced" value="#form.modalpopforced#" />
		<table style="width:100%;" class="table-list">
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">Save</button>
					
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<cfscript>
						cancelLink="/z/job/admin/manage-job-category/index";
						</cfscript>
						<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href='#cancelLink#';">Cancel</button>
					</cfif>
				</td></td>
			</tr>
			<tr>
				<th>Name</th>
				<td><input type="text" name="job_category_name" value="#htmleditformat(form.job_category_name)#" /> *</td>
			</tr> 
			<tr>
				<th>Description</th>
				<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "job_category_description";
					htmlEditor.value			= form.job_category_description;
					htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
					htmlEditor.height		= 350;
					htmlEditor.create();
					</cfscript>   
				</td>
			</tr>
				<tr>
					<th style="vertical-align:top; width:120px; ">Meta Title</th>
					<td>
						<input type="text" name="job_category_metatitle" style="width:95%;" value="#htmleditformat(form.job_category_metatitle)#">
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; width:120px; ">Meta Keywords</th>
					<td>
						<textarea name="job_category_metakey" style="width:95%; height:60px; ">#htmleditformat(form.job_category_metakey)#</textarea>
					</td>
				</tr>
				<tr>
					<th style="vertical-align:top; width:120px; ">Meta Description</th>
					<td>
						<textarea name="job_category_metadesc" style="width:95%; height:60px; ">#htmleditformat(form.job_category_metadesc)#</textarea>
					</td>
				</tr>
			<tr>
				<th>Unique URL</th>
				<td>
					<cfif form.method EQ "add">
						#application.zcore.functions.zInputUniqueUrl("job_category_unique_url", true)#
					<cfelse>
						#application.zcore.functions.zInputUniqueUrl("job_category_unique_url")#
					</cfif>
				<br />
				It is not recommended to use this feature unless you know what you are doing regarding SEO and broken links.  It is used to change the URL of this record within the site.</td>
			</tr> 
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">Save</button>
					
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<cfscript>
						cancelLink="/z/job/admin/manage-job-category/index";
						</cfscript>
						<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href='#cancelLink#';">Cancel</button>
					</cfif>
				</td></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Jobs");	
	application.zcore.functions.zSetPageHelpId("11.3");
	searchOn=false;
	db.sql="select job_category.*, COUNT(job.job_id) COUNT 
	from #db.table("job_category", request.zos.zcoreDatasource)# 
	LEFT JOIN 
	#db.table("job", request.zos.zcoreDatasource)# ON 
	LOCATE(CONCAT(#db.param(',')#, job_category.job_category_id, #db.param(',')#), CONCAT(#db.param(',')#, job.job_category_id, #db.param(',')#)) <> #db.param(0)# 
	AND 
	job.site_id = job_category.site_id and 
	job_deleted=#db.param(0)# 
	WHERE 
	job_category.site_id = #db.param(request.zos.globals.id)# and 
	job_category_deleted=#db.param(0)# 
	GROUP BY job_category.job_category_id 
	ORDER BY job_category_name ASC";
	qList=db.execute("qList");

	request.jobCom=application.zcore.app.getAppCFC("job");
	request.jobCom.getAdminNavMenu();

	echo('<div class="z-manager-list-view">');
	echo('<div class="z-float z-mb-10">'); 
	echo('<h2 style="display:inline-block;">');
	echo('Job Categories');

	echo('</h2> &nbsp;&nbsp; <a href="/z/job/admin/manage-job-category/add" class="z-button">Add</a>
	</div>');
	</cfscript> 

	<!--- <hr />
	<div style="width:100%; float:left;">
		<form action="/z/job/admin/manage-job-category/index" method="get">
		<div style="width:150px;margin-bottom:10px; float:left; "><h2>Search</h2>
		</div>
		
		<div style="width:150px;margin-bottom:10px;float:left;">&nbsp;<br />
			<input type="submit" name="search1" value="Search" class="z-manager-search-button" />
			<cfif searchOn>
				<input type="button" name="search2" value="Show All" class="z-manager-search-button" onclick="window.location.href='/z/job/admin/manage-job-category/index';">
			</cfif>
		</div>
		</form>
	</div>
	<hr /> --->
	<table class="table-list">
		<tr>
			<th>ID</th>
			<th>Category Name</th>
			<th>## of Jobs</th>
			<th>Last Updated</th>
			<!--- TODO: Category Sorting - see content-admin.cfc "queueSortCom" and "queueSortStruct" --->
			<th>Admin</th>
		</tr>
		<cfscript> 
		for(row in qList){
			echo('<tr>');
			getJobCategoryRowHTML(row);
			echo('</tr>');
		}
		</cfscript>  
	</table>
	<cfscript>
	if(qList.recordcount EQ 0){
		echo('<p>No job categories found</p>');
	}
	</cfscript>
	</div>
</cffunction>

<cffunction name="getReturnJobCategoryRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="select job_category.*, COUNT(job.job_id) COUNT 
	from #db.table("job_category", request.zos.zcoreDatasource)# 
	LEFT JOIN 
	#db.table("job", request.zos.zcoreDatasource)# ON 
	LOCATE(CONCAT(#db.param(',')#, job_category.job_category_id, #db.param(',')#), CONCAT(#db.param(',')#, job.job_category_id, #db.param(',')#)) <> #db.param(0)# 
	AND 
	job.site_id = job_category.site_id and 
	job_deleted=#db.param(0)#  
	WHERE 
	job_category.site_id =#db.param(request.zos.globals.id)# and 
	job_category_deleted = #db.param(0)# and 
	job_category.job_category_id=#db.param(form.job_category_id)#";
	qCategoryJobs=db.execute("qCategoryJobs"); 
	
	request.jobCom=application.zcore.app.getAppCFC("job");
	savecontent variable="rowOut"{
		for(row in qCategoryJobs){
			getJobCategoryRowHTML(row);
		}
	}

	echo('done.<script type="text/javascript">
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>
	
<cffunction name="getJobCategoryRowHTML" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	echo('
		<td>#row.job_category_id#</td>
		<td>#row.job_category_name#</td>
		<td>#row.count#</td>
		<td>#application.zcore.functions.zGetLastUpdatedDescription(row.job_category_updated_datetime)#</td>
		<td>
			<a href="#request.jobCom.getCategoryURL(row)#" target="_blank">View</a> | 
			<a href="/z/job/admin/manage-jobs/add?job_category_id=#row.job_category_id#">Add Job</a> | 
			<a href="/z/job/admin/manage-jobs/index?job_category_id=#row.job_category_id#">Manage Jobs</a> | ');
		echo('<a href="/z/job/admin/manage-job-category/edit?job_category_id=#row.job_category_id#&amp;modalpopforced=1"  onclick="zTableRecordEdit(this);  return false;">Edit</a>');

		echo(' | ');

		if ( not application.zcore.functions.zIsForceDeleteEnabled(row.job_category_unique_url) ) {
			echo( 'Locked' );
		} else {
			echo( '<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/job/admin/manage-job-category/delete?job_category_id=#row.job_category_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a>');
		}

		echo( '</td>' );

	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>