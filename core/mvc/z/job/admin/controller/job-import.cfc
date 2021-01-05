<cfcomponent>
<cfoutput> 
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Job Import");
	if(not application.zcore.app.siteHasApp("job")){
		application.zcore.functions.z404("Job application not enabled for this site");
	}
	request.jobImportFields="Category,Title,Unique URL,Status,Location,Address,Address2,City,State,Country,Zip,Map Coordinates,Company Name,Hide Company Name,Phone,Website,Featured,Type,Posted Datetime,Closed Datetime,Position Title,Summary,Full Description,Suggested By Name,Suggested By Email,Suggested By Phone,External ID";
	</cfscript>
</cffunction>

<cffunction name="index" access="remote" localmode="modern" roles="serveradministrator">
	<!--- 
	not needed on first version:
		delete cfc path & method - remove all records no longer in the calendar 
	 --->
	<cfscript>
	init();
	var db=request.zos.queryObject;  
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2>Job Import</h2> 
	<p>Please upload a file with at least these fields.</p>
	<p>Title,Posted Datetime,Type</p>
	<h3>All Fields Supported</h3>
	<p>#request.jobImportFields#</p>

	<form class="zFormCheckDirty" action="/z/job/admin/job-import/process" enctype="multipart/form-data" method="post">  
		<h2>Select an existing category</h2>
		<p>Only do this if you excluded the category field in your CSV file and want to map the jobs to a specific category.</p>
		<cfscript>
		db.sql="select * from #db.table("job_category", request.zos.zcoreDatasource)# WHERE 
		job_category_deleted=#db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# 
		ORDER BY job_category_name ASC ";
		qCategory=db.execute("qCategory");

		if(qCategory.recordcount EQ 1){
			form.job_category_id=qCategory.job_category_id;
		}
		ts = StructNew();
		ts.name = "job_category_id"; 
		ts.size = 1;  
		ts.query = qCategory;
		ts.queryLabelField = "job_category_name"; 
		ts.queryValueField = "job_category_id";  
		application.zcore.functions.zInputSelectBox(ts);
		</cfscript></p> 
		<h2>Select a properly formatted default Excel CSV file to upload</h2>
		<p><input type="file" name="filepath" value="" /></p>
		<cfif request.zos.isDeveloper>
			<h2>Specify Import CFC filter.</h2>
			<p>Code example<br />
			<textarea type="text" cols="100" rows="4" name="a3">#htmleditformat('<cfcomponent>
			<cffunction name="importFilter" localmode="modern" access="public">
			<cfargument name="struct" type="struct" required="yes">
				<cfscript>
				writedump(arguments.struct);
				abort;
				</cfscript>
			</cffunction>
			<cffunction name="importComplete" localmode="modern" access="public">
				<cfscript>
				// clean up
				</cfscript>
			</cffunction>
			</cfcomponent>')#</textarea></p> 

			<cfscript>
			form.cfcImportPath=application.zcore.functions.zso(form, 'cfcImportPath', false, 'zcorerootmapping.mvc.z.job.admin.controller.jobImportFilter');
			form.cfcImportMethod=application.zcore.functions.zso(form, 'cfcImportMethod', false, 'importFilter');
			form.cfcImportCompleteMethod=application.zcore.functions.zso(form, 'cfcImportCompleteMethod', false, 'importComplete');
			</cfscript> 
			<p>Import CFC CreateObject Path: 
			<input type="text" name="cfcImportPath" style="width:500px; max-width:100%;" value="#htmleditformat(form.cfcImportPath)#" /> 
			(i.e. root.importFilter)</p> 

			<p>Import CFC Method: <input type="text" name="cfcImportMethod" value="#htmleditformat(form.cfcImportMethod)#" /> (i.e. importFilter)</p>
			<p>Import Complete CFC Method: <input type="text" name="cfcImportCompleteMethod" value="#htmleditformat(form.cfcImportCompleteMethod)#" /> (i.e. importComplete)</p> 
		</cfif>
		<h2>Then Click Import CSV</h2>
		<p><input type="submit" name="submit1" value="Import CSV" onclick="this.style.display='none';document.getElementById('pleaseWait').style.display='block';" />
		<div id="pleaseWait" style="display:none;">Please wait...</div>
		</p>

		<h2>Need to delete the existing jobs?</h2>
		<p>Run these queries:</p>
		<p>DELETE FROM `job` where site_id=#request.zos.globals.id#;</p>
		<p>DELETE FROM `job_x_category` where site_id=#request.zos.globals.id#;</p> 


		<h3>Data Formatting Notes:</h3>
		<p>Category should be comma separated full category name or empty.</p>
		<p>Unique URL should be a root relative URL excluding the domain, i.e. /path/to/job</p>
		<p>Status should be set to Y or N.</p>
		<p>State should be the 2 letter abbreviation (US only)</p>
		<p>Country should be the 2 letter abbreviation</p>
		<p>Hide Company Name should be set to Y or N.</p>
		<p>Map Coordinates should be set formatted like: latitude,longitude</p>
		<p>Hide Company Name should be set to Y or N.</p>
		<p>Featured should be set to Y or N.</p>
		<p>Website should be a complete url including http:// or https://, i.e. https://www.google.com/</p>
		<p>Posted Datetime and Closed Datetime should be in this format: yyyy-mm-dd HH:mm:ss</p>
		<p>Summary should be HTML format</p>
		<p>Full Description should be HTML format</p>
		<p>Type must be one of these values: Not provided,Full-time,Part-time,Commission,Temporary,Temporary to hire,Contract,Contract to hire,Internship,Volunteer,Per Diem</p>
	 
	</form>
</cffunction>

<cffunction name="customProcess" localmode="modern" access="public">
	<cfscript>
	process();
	</cfscript>
</cffunction>

<cffunction name="process" localmode="modern" access="remote">
	<cfsetting requesttimeout="3000">
	<cfscript>
	debug=false;
	if(form.method EQ "process"){
		if(not application.zcore.user.checkServerAccess()){
			application.zcore.functions.z404("Only serveradministrator can access this.");
		}
	} 
	init();

	if(not structkeyexists(form, 'returnURL')){
		form.returnURL="/z/job/admin/job-import/index?zsid=#request.zsid#";
	}

	db=request.zos.queryObject;
	db.sql="select * from #db.table("job_category", request.zos.zcoreDatasource)# WHERE 
	job_category_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# 
	ORDER BY job_category_name ASC ";
	qCategory=db.execute("qCategory");
	request.jobCategoryStruct={};
	for(row in qCategory){
		request.jobCategoryStruct[row.job_category_name]=row.job_category_id;
	}
	application.zcore.adminSecurityFilter.requireFeatureAccess("Job Import", true);

	if(debug){
		fileName=request.zos.globals.privateHomedir&"jobs-temp.csv";
		newPath=request.zos.globals.privateHomedir&"jobs-temp.csv";
		fileName=request.zos.globals.privateHomedir&"jobs.csv";
		newPath=request.zos.globals.privateHomedir&"jobs.csv";
		form.cfcImportPath="zcorerootmapping.mvc.z.job.admin.controller.jobImportFilter";
		form.cfcImportMethod="importFilter";
		form.cfcImportCompleteMethod="importComplete";
	}else{
		tempPath=request.zos.globals.serverprivatehomedir&'_cache/temp_files/';
		fileName=application.zcore.functions.zUploadFile("filepath", tempPath);
		newPath=tempPath&fileName; 
	}

 
	if(isBoolean(fileName) or not fileExists(newPath)){
		application.zcore.status.setStatus(request.zsid, "Failed to upload CSV file.", form, true);
		application.zcore.functions.zRedirect(form.returnURL);
	}
	//data=application.zcore.functions.zreadfile(newPath);
	//application.zcore.functions.zdeletefile(newPath); 
	if(form.cfcImportPath EQ "" or form.cfcImportMethod EQ ""){
		application.zcore.status.setStatus(request.zsid, "Import CFC Path and Method are required.", form, true);
		application.zcore.functions.zRedirect(form.returnURL);
	}
	if(left(form.cfcImportPath, 5) EQ "root."){
		form.cfcImportPath=request.zrootcfcpath&removechars(form.cfcImportPath, 1, 5);
	}
	cfcImportObject=application.zcore.functions.zcreateobject("component", form.cfcImportPath, true);
	
	arrFields=listToArray(request.jobImportFields, ",");
	defaultStruct={};
	for(field in arrFields){
		defaultStruct[field]="";
	}
 
 	for(n=1;n<=2;n++){ 
		dataImportCom = createobject( 'component', 'zcorerootmapping.com.app.dataImport' );
		ts={};
		ts.escapedBy               = '"';
		ts.textQualifier           = '"';
		ts.seperator               = ",";
		ts.lineDelimiter           = chr(10);
		ts.allowUnequalColumnCount = false;
		ts.bufferedReadEnabled=true; 
		ts.filename=newPath;
		dataImportCom.init(ts);

		//dataImportCom.parseCSV( data );
		while(true){
			dataImportCom.getFirstRowAsColumns();
			if(dataImportCom.arrColumns[1] NEQ ""){
				break;
			}
		}
		//dataImportCom.arrColumns = expectedColumns;

		columns = dataImportCom.arrColumns;

		mappedColumns = {};

		for ( columnsIndex = 1; columnsIndex LTE arraylen( columns ); columnsIndex++ ) {
			mappedColumns[ columns[ columnsIndex ] ] = columns[ columnsIndex ];
		}

		dataImportCom.mapColumns( mappedColumns );
	  
		db.sql="select * from #db.table("job", request.zos.zcoreDatasource)# WHERE 
		site_id=#db.param(request.zos.globals.id)# and 
		job_deleted=#db.param(0)# and 
		job_id=#db.param(-1)# ";
		qJob=db.execute("qJob");
		defaultJobStruct={};
		application.zcore.functions.zQueryToStruct(qJob, defaultJobStruct); 
		try{
			while(true){
				ts = dataImportCom.getRow();   
				if(isStruct(ts) EQ false){ 
					break;
				}
				structappend(ts, defaultStruct, false);
				ts=cfcImportObject[form.cfcImportMethod](ts);
				if(structkeyexists(ts, 'errorMessage')){ 
					dataImportCom.close();
					if(not debug){
						application.zcore.functions.zdeletefile(newPath); 
					}
					echo(ts.errorMessage);
					abort;
				}
				structappend(ts, defaultJobStruct, false);

				if(ts.job_title EQ "" or ts.job_type EQ ""){
					continue;
				}
				if(ts.job_status EQ ""){
					ts.job_status="1";
				}
				if(ts.job_posted_datetime EQ ""){
					ts.job_posted_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");
				}

				ts.site_id=request.zos.globals.id; 

				search_full_text = ts.job_title & ' ' & application.zcore.app.getAppCFC( 'job' ).jobTypeToString(ts.job_type) & ' ' & ts.job_city & ' ' & ts.job_summary & ' ' & ts.job_overview;

				form.job_search = application.zcore.functions.zRemoveHTMLForSearchIndexer( search_full_text );
				ts.job_deleted=0;
				ts.job_updated_datetime=dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss");

				if(debug){
			 		writedump(ts);
			 		dataImportCom.close();
			 		abort;
		 		}

		 		if(n EQ 2){ 
					t9={
						table:"job",
						datasource:request.zos.zcoredatasource,
						struct:ts
					}; 

					if(ts.job_external_id NEQ ""){
						db.sql="select job_id, job_unique_url from #db.table("job", request.zos.zcoreDatasource)# WHERE 
						site_id=#db.param(request.zos.globals.id)# and 
						job_deleted=#db.param(0)# and 
						job_external_id=#db.param(ts.job_external_id)# ";
						qJob=db.execute("qJob");
					}else{
						qJob={recordcount:0};
					}
  
					if(qJob.recordcount NEQ 0){
						t9.struct.job_id=qJob.job_id;
						job_id=qJob.job_id;
						result=application.zcore.functions.zUpdate(t9);
						if(not result){
							throw("Failed to update job");
						}
						db.sql="delete from #db.table("job_x_category", request.zos.zcoreDatasource)# WHERE 
						site_id=#db.param(request.zos.globals.id)# and 
						job_x_category_deleted=#db.param(0)# ";
						db.execute("qDelete");

						if(qJob.job_unique_url NEQ ts.job_unique_url){
							application.zcore.app.getAppCFC("job").updateRewriteRuleJob(job_id, qJob.job_unique_url);	
						}
					}else{ 
						job_id=application.zcore.functions.zInsert(t9); 
						if(job_id EQ false){
							throw("Failed to insert job");
						}
						if(ts.job_unique_url NEQ ""){
							application.zcore.app.getAppCFC("job").updateRewriteRuleJob(job_id, "");	
						}
					} 
					application.zcore.app.getAppCFC("job").searchReindexJob(job_id, false);
					arrCategory=listToArray(ts.job_category_id, ",");
					for(id in arrCategory){
						if(trim(id) NEQ ""){
							t9={
								table:"job_x_category",
								datasource:request.zos.zcoredatasource,
								struct:{
									job_id:job_id,
									job_category_id:trim(id),
									job_x_category_updated_datetime:dateformat(now(), "yyyy-mm-dd")&" "&timeformat(now(), "HH:mm:ss"),
									job_x_category_deleted:0
								}
							}; 
							application.zcore.functions.zInsert(t9);
						}
					}
				}
			}
		}catch(Any e){
			dataImportCom.close();
			if(not debug){
				application.zcore.functions.zdeletefile(newPath); 
			}
			rethrow;
		}
	}
	dataImportCom.close();
	if(not debug){
		application.zcore.functions.zdeletefile(newPath); 
	}
 
	if(form.cfcImportCompleteMethod NEQ ""){
		cfcImportObject[form.cfcImportCompleteMethod]();
	}

	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>