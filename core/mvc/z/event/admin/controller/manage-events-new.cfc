<cfcomponent extends="zcorerootmapping.com.app.manager-base">
<cfoutput>   
<!--- 
TODO: getEditData and down are not complete yet.
 --->

<cffunction name="getQuickLinks" localmode="modern" access="public">
	<cfscript>
	links=[];
	return links;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="private">
	<cfscript> 
	variables.uploadPath=request.zos.globals.privateHomeDir&"zupload/event/";
	variables.displayPath="/zupload/event/";
	ts={
		// required 
		label:"Event",
		pluralLabel:"Events",
		tableName:"event",
		viewScriptName:"/z/event/view-event/viewEvent",
		uniqueURLField:"event_unique_url",
		activeField:"event_status", // boolean that automates some search/indexing/url routing changes
		searchIndexFields:{
			title:"event_name", 
			summary:"event_summary",
			fullText:"event_description",
			// image or image_library_id can be used
			//image:"", 
			image_library_id:"event_image_library_id",
			datetime:"event_updated_datetime",
			app_id:"17"
		},
		metaFields:{
			title:"event_metatitle",
			keywords:"event_metakey",
			description:"event_metadesc"
		},
		datasource:request.zos.zcoreDatasource,
		deletedField:"event_deleted",
		primaryKeyField:"event_id",
		methods:{ // callback functions to customize the manager data and layout
			getListData:'getListData', 
			getListReturnData:'getListReturnData',
			getListRow:'getListRow', // function receives struct named row 
			getEditData:'getEditData',
			getEditForm:'getEditForm',
			beforeUpdate:'beforeUpdate',
			afterUpdate:'afterUpdate',
			beforeInsert:'beforeInsert',
			afterInsert:'afterInsert',
			getDeleteData:'getDeleteData',
			executeDelete:'executeDelete',
			beforeReturnInsertUpdate:''
		},

		//optional
		requiredParams:[],

		customInsertUpdate:false,
		sortField:"event_sort",
		hasSiteId:true,
		rowSortingEnabled:true,
		metaField:"event_meta_json",
		quickLinks:getQuickLinks(),
		imageLibraryFields:["event_image_library_id"],

		validateFields:{
			"event_name":{	required:true }
		},
		imageFields:[],
		fileFields:[],
		// optional
		requireFeatureAccess:"Events",
		pagination:true,
		paginationIndex:"zIndex",
		pageZSID:"zPageId",
		perpage:10,
		title:"Events",
		prefixURL:"/z/event/admin/manage-events/",
		navLinks:[],
		titleLinks:[],
		columnSortingEnabled:true,
		columns:[{
			label:"ID"
		},{
			label:'Photo',
			field:'event_image_library_id'
		},{
			label:'Name',
			field:'event_name',
			sortable:true
		},{
			label:'Address',
			field:'event_address'
		},{
			label:'Phone',
			field:'event_phone'
		},{
			label:'Updated',
			field:'event_updated_datetime'
		},{
			label:'Admin'
		}]
	};
	if(form.method EQ "publicInsertEvent"){
		ts.requireFeatureAccess="";
		ts.methods.beforeReturnInsertUpdate="beforeReturnInsertUpdate";
	}
	super.init(ts); 
	</cfscript>
</cffunction>	 

<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	super.delete();
	</cfscript>
</cffunction>


<cffunction name="publicInsertEvent" localmode="modern" access="remote" roles="member">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	super.update();
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	super.edit();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
 	init();
	super.index();
	</cfscript>
</cffunction> 

<cffunction name="executeDelete" localmode="modern" access="private">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	var db=request.zos.queryObject; 


	db.sql="DELETE FROM #db.table("event_x_category", request.zos.zcoreDatasource)#  
	WHERE event_id= #db.param(application.zcore.functions.zso(form, 'event_id'))# and 
	event_x_category_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	q=db.execute("q");
  
	db.sql="DELETE FROM #db.table("event_recur", request.zos.zcoreDatasource)#  
	WHERE event_id= #db.param(application.zcore.functions.zso(form, 'event_id'))# and 
	event_recur_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	q=db.execute("q");

	db.sql="DELETE FROM #db.table("event", request.zos.zcoreDatasource)#  
	WHERE event_id= #db.param(application.zcore.functions.zso(form, 'event_id'))# and 
	event_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	q=db.execute("q");


	eventCom=application.zcore.app.getAppCFC("event");
	eventCom.searchIndexDeleteEvent(form.event_id);

	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="getDeleteData" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject; 
	rs={};
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# 
	WHERE event_id= #db.param(application.zcore.functions.zso(form,'event_id'))# and 
	event_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	rs.qData=db.execute("qData");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="beforeUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	db=request.zos.queryObject;
	rs={success:true};



	if(form.method EQ "insert" or form.method EQ "publicInsertEvent"){
		form.event_id="";
	}
	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', true, 0);

	errors=false;
	if(form.method EQ "publicInsertEvent"){ 
		form.event_status=0;
		form.event_featured='0';
		form.event_summary=application.zcore.functions.zStripHTMLTags(application.zcore.functions.zso(form, 'event_summary'));
		form.event_description=application.zcore.functions.zStripHTMLTags(application.zcore.functions.zso(form, 'event_description'));
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
		if(errors){
			application.zcore.functions.zRedirect("/z/event/suggest-an-event/index?zsid=#request.zsid#");
		}
	}else{
		application.zcore.adminSecurityFilter.requireFeatureAccess("Events", true);	
	}



	form.site_id = request.zos.globals.id;
	ts={};
	ts.event_name.required = true;
	ts.event_calendar_id.required = true;
	ts.event_start_datetime_date.required = true;
	ts.event_end_datetime_date.required = true;
	errors = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
 
	if(application.zcore.functions.zso(form, 'event_website') NEQ ""){
		success=application.zcore.functions.zValidateURL(form.event_website, false, false);
		if(not success){
			application.zcore.status.setStatus(request.zsid, "Website must be a valid URL beginning with / or ##, starting with http:// or a link within this site.", form, true);
			result=true;
		}
	}
	if(errors){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'publicInsertEvent'){
			application.zcore.functions.zRedirect("/z/event/suggest-an-event/index?zsid=#request.zsid#");
		}else{
			return {success:false};
		}
	}
	if(application.zcore.functions.zso(form, 'event_uid') EQ ""){
		form.event_uid=createuuid();
	}
	form.event_category_id=application.zcore.functions.zso(form, 'event_category_id');

	if(form.event_start_datetime_date NEQ "" and isdate(form.event_start_datetime_date)){
		form.event_start_datetime=dateformat(form.event_start_datetime_date, 'yyyy-mm-dd');
	}
	if(form.event_start_datetime_time NEQ "" and isdate(form.event_start_datetime_time)){
		form.event_start_datetime=form.event_start_datetime&" "&timeformat(form.event_start_datetime_time, 'HH:mm:ss');
	}
	if(form.event_end_datetime_date NEQ "" and isdate(form.event_end_datetime_date)){
		form.event_end_datetime=dateformat(form.event_end_datetime_date, 'yyyy-mm-dd');
	}
	if(form.event_end_datetime_time NEQ "" and isdate(form.event_end_datetime_time)){
		form.event_end_datetime=form.event_end_datetime&" "&timeformat(form.event_end_datetime_time, 'HH:mm:ss');
	} 

	if(datediff("d", form.event_start_datetime, form.event_end_datetime) LT 0){
		application.zcore.status.setStatus(request.zsid, "The end date must be after the start date", form, true);
		if(form.method EQ 'publicInsertEvent'){
			application.zcore.functions.zRedirect("/z/event/suggest-an-event/index?zsid=#request.zsid#"); 
		}else{
			return {success:false};
		}
	}
	if(form.method EQ 'insert'){
		form.event_created_datetime=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
	}

	if(form.event_recur_until_datetime NEQ ""){
		form.event_recur_until_datetime=dateformat(form.event_recur_until_datetime, 'yyyy-mm-dd')&' '&timeformat(form.event_recur_until_datetime, 'HH:mm:ss');
	}

	form.event_updated_datetime=dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss');
 
	application.zcore.functions.zcreatedirectory(request.zos.globals.privateHomedir&"zupload/event/");
 
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# 
	WHERE event_id = #db.param(form.event_id)# and 
	event_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	rs.qData=db.execute("qData");
	if(form.method EQ "update" and rs.qData.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this event.',form,true);
		application.zcore.functions.zRedirect('/z/event/admin/manage-events/index?zsid=#request.zsid#');
	} 
	form.event_file1=application.zcore.functions.zUploadFileToDb("event_file1", request.zos.globals.privateHomedir&"zupload/event/", 'event', 'event_id', application.zcore.functions.zso(form, 'event_file1_deleted', true, 0), request.zos.zcoreDatasource); 
	form.event_file2=application.zcore.functions.zUploadFileToDb("event_file2", request.zos.globals.privateHomedir&"zupload/event/", 'event', 'event_id', application.zcore.functions.zso(form, 'event_file2_deleted', true, 0), request.zos.zcoreDatasource); 
 
	return rs;
	</cfscript>
</cffunction>

<cffunction name="afterUpdate" localmode="modern" access="private" returntype="struct">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	rs={success:true};

	db.sql="delete from #db.table("event_x_category", request.zos.zcoreDatasource)# WHERE 
	event_id = #db.param(form.event_id)# and 
	event_x_category_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qDelete=db.execute("qDelete");

	if(form.event_category_id NEQ ""){
		arrCategory=listToArray(form.event_category_id, ',');
		for(i=1;i LTE arraylen(arrCategory);i++){
			ts={
				struct:{
					event_id:form.event_id,
					site_id:request.zos.globals.id,
					event_x_category_deleted:0,
					event_x_category_updated_datetime:dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'),
					event_category_id:arrCategory[i]
				},
				table:"event_x_category",
				datasource:request.zos.zcoreDatasource
			}
			application.zcore.functions.zInsert(ts);
		}
	}
  
	updateRecurRecords=false;
	if(form.method EQ 'update'){
		if(dateformat(ss.qData.event_start_datetime, "yyyy-mm-dd")&" "&timeformat(ss.qData.event_start_datetime, "HH:mm:ss") NEQ form.event_start_datetime){
			updateRecurRecords=true;
		} 
		if(dateformat(ss.qData.event_end_datetime, "yyyy-mm-dd")&" "&timeformat(ss.qData.event_end_datetime, "HH:mm:ss") NEQ form.event_end_datetime){
			updateRecurRecords=true;
		}
		if(ss.qData.event_recur_ical_rules NEQ form.event_recur_ical_rules){
			updateRecurRecords=true;
		}
		if(ss.qData.event_excluded_date_list NEQ form.event_excluded_date_list){
			updateRecurRecords=true;
		}
	}else{
		updateRecurRecords=true;
	} 
	if(updateRecurRecords){
		db.sql="select * from #db.table("event_recur", request.zos.zcoreDatasource)#
		WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		event_recur_deleted=#db.param(0)# and 
		event_id=#db.param(form.event_id)#";
		qEventRecur=db.execute("qEventRecur");
		recurStruct={};
		for(row2 in qEventRecur){
			recurStruct[dateformat(row2.event_recur_start_datetime, "yyyy-mm-dd")&" "&timeformat(row2.event_recur_start_datetime, "HH:mm:ss")&" to "&dateformat(row2.event_recur_end_datetime, "yyyy-mm-dd")&" "&timeformat(row2.event_recur_end_datetime, "HH:mm:ss")]=row2.event_recur_id;
		}
		//writedump(recurStruct);
		if(form.event_recur_ical_rules EQ ""){

			mysqlStartDate=dateformat(form.event_start_datetime, "yyyy-mm-dd")&" "&timeformat(form.event_start_datetime, "HH:mm:ss")&" to "&dateformat(form.event_end_datetime, "yyyy-mm-dd")&" "&timeformat(form.event_end_datetime, "HH:mm:ss");
			//writedump(mysqlStartDate);
			if(not structkeyexists(recurStruct, mysqlStartDate)){
				ts={
					table:"event_recur",
					datasource:request.zos.zcoreDatasource,
					struct:{
						event_id:form.event_id,
						site_id:request.zos.globals.id,
						event_recur_datetime:dateformat(form.event_start_datetime, "yyyy-mm-dd")&" "&timeformat(form.event_start_datetime, "HH:mm:ss"),
						event_recur_start_datetime:dateformat(form.event_start_datetime, "yyyy-mm-dd")&" "&timeformat(form.event_start_datetime, "HH:mm:ss"),
						event_recur_end_datetime:dateformat(form.event_end_datetime, "yyyy-mm-dd")&" "&timeformat(form.event_end_datetime, "HH:mm:ss"),
						event_recur_updated_datetime:dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'),
						event_recur_deleted:0
					}
				};
				form.event_recur_id=application.zcore.functions.zInsert(ts);
				db.sql="delete from #db.table("event_recur", request.zos.zcoreDatasource)# WHERE 
				event_recur_deleted=#db.param(0)# and 
				site_id=#db.param(request.zos.globals.id)# and 
				event_id=#db.param(form.event_id)# and 
				event_recur_id <> #db.param(form.event_recur_id)# ";
				qDelete=db.execute("qDelete");
			}else{
				form.event_recur_id=recurStruct[mysqlStartDate];
				db.sql="delete from #db.table("event_recur", request.zos.zcoreDatasource)# WHERE 
				event_recur_deleted=#db.param(0)# and 
				site_id=#db.param(request.zos.globals.id)# and 
				event_id=#db.param(form.event_id)# and 
				event_recur_id <> #db.param(form.event_recur_id)# ";
				qDelete=db.execute("qDelete");
			}
		}else{
			// project event 
			ical=application.zcore.app.getAppCFC("event").getIcalCFC();
			projectDays=application.zcore.functions.zso(application.zcore.app.getAppData("event").optionStruct, 'event_config_project_recurrence_days', true);
			echo('project event #projectDays# days into future: rrule: #form.event_recur_ical_rules#<br />');

			daysAfterStartDate=datediff("d", form.event_start_datetime, now());
			tempProjectDays=projectDays;
			if(daysAfterStartDate GT 0){
				tempProjectDays+=daysAfterStartDate;
			}

			arrDate=ical.getRecurringDates(form.event_start_datetime, form.event_recur_ical_rules, form.event_excluded_date_list, tempProjectDays);
			minutes=datediff("n", form.event_start_datetime, form.event_end_datetime);
			//writedump(arrDate);
			for(i=1;i LTE arraylen(arrDate);i++){
				startDate=arrDate[i];
				endDate=dateadd("n", minutes, startDate);
				mysqlStartDate=dateformat(startDate, "yyyy-mm-dd")&" "&timeformat(startDate, "HH:mm:ss")&" to "&dateformat(endDate, "yyyy-mm-dd")&" "&timeformat(endDate, "HH:mm:ss");

				if(structkeyexists(recurStruct, mysqlStartDate)){
					structdelete(recurStruct, mysqlStartDate);
					//echo('skip '&mysqlStartDate&'<br>');
				}else{
					//echo('insert: #mysqlStartDate#<br>');
					ts={
						table:"event_recur",
						datasource:request.zos.zcoreDatasource,
						struct:{
							event_id:form.event_id,
							site_id:request.zos.globals.id,
							event_recur_datetime:dateformat(startDate, "yyyy-mm-dd")&" "&timeformat(startDate, "HH:mm:ss"),
							event_recur_start_datetime:dateformat(startDate, "yyyy-mm-dd")&" "&timeformat(startDate, "HH:mm:ss"),
							event_recur_end_datetime:dateformat(endDate, "yyyy-mm-dd")&" "&timeformat(endDate, "HH:mm:ss"),
							event_recur_updated_datetime:dateformat(now(), 'yyyy-mm-dd')&' '&timeformat(now(), 'HH:mm:ss'),
							event_recur_deleted:0
						}
					}
					//writedump(ts);
					application.zcore.functions.zInsert(ts);
				}
			}
			arrDelete=[];
			for(i in recurStruct){
				arrayAppend(arrDelete, recurStruct[i]);
			}
			if(arraylen(arrDelete)){
				//writedump("deleting: "&arrayToList(arrDelete,  ", "));
				db.sql="delete from #db.table("event_recur", request.zos.zcoreDatasource)# WHERE 
				event_recur_deleted=#db.param(0)# and 
				site_id=#db.param(request.zos.globals.id)# and 
				event_id=#db.param(form.event_id)# and 
				event_recur_id IN (#db.trustedSQL(arrayToList(arrDelete,  ", "))#) ";
				qDelete=db.execute("qDelete");
			}
		}
	} 
	application.zcore.app.getAppCFC("event").searchReindexEvent(form.event_id, false);
	 

	return rs;
	</cfscript>
</cffunction>

<cffunction name="beforeInsert" localmode="modern" access="private" returntype="struct">
	<cfscript> 
	rs=beforeUpdate();
	return rs;
	</cfscript>
</cffunction>

<cffunction name="afterInsert" localmode="modern" access="private" returntype="struct">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	rs={success:true};
	rs=afterUpdate();
	return rs;
	</cfscript>
</cffunction>

<cffunction name="beforeReturnInsertUpdate" localmode="modern" access="private" returntype="struct"> 
	<cfscript>
	rs={success:true};   

	ts={};
	ts.subject="Suggest an event submission on #request.zos.globals.shortDomain#";
	savecontent variable="output"{
		echo('#application.zcore.functions.zHTMLDoctype()#
		<head>
		<meta charset="utf-8" />
		<title>Suggest An Event</title>
		</head>
		
		<body>
			<h2>Suggest An Event Submission</h2>
			<p>Event Name: #form.event_name#</p>
			<p>Start Date: #dateformat(form.event_start_datetime, "m/d/yyyy")# at #timeformat(form.event_start_datetime, "h:mm tt")#</p>
			<p>End Date: #dateformat(form.event_end_datetime, "m/d/yyyy")# at #timeformat(form.event_end_datetime, "h:mm tt")#</p>');
			if(form.event_recur_ical_rules NEQ ""){
				echo('<p>This is a recurring event</p>');
			}else{
				echo('<p>This is NOT a recurring event</p>');
			}
			echo('<p>Suggested By Name: #form.event_suggested_by_name#</p>
			<p>Suggested By Email: <a href="mailto:#form.event_suggested_by_email#">#form.event_suggested_by_email#</a></p>
			<p>Suggested By Phone: #form.event_suggested_by_phone#</p>
			<p>This event will not appear on the public calendar until you edit it in the manager and set the "Active" field to "Yes".</p>
			<p>It is wise not to trust the information submitted by a user.  Please make an attempt to verify the information and ensure it doesn''t contain any malicious or illegal information such as HTML code or stolen images.  You are ultimately responsible for the content on your web site.</p>
			<h2><a href="/z/event/admin/manage-events/edit?event_id=#form.event_id#">Edit This Event</a></h2>
			<h2><a href="/z/event/admin/manage-events/index">Manage Events</a></h2>

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

	application.zcore.functions.zRedirect("/z/event/suggest-an-event/complete?modalpopforced=#form.modalpopforced#&zsid=#request.zsid#");
	return rs;
	</cfscript>
</cffunction>



<cffunction name="getEditData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 

	form.event_id=application.zcore.functions.zso(form, 'event_id', true);
	rs={};
	db.sql="SELECT * FROM #db.table("event", request.zos.zcoreDatasource)# event 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	event_deleted = #db.param(0)# and 
	event_id=#db.param(form.event_id)#";
	rs.qData=db.execute("qData");

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListReturnData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject;  

	ts=structnew();
	ts.image_library_id_field="event.event_image_library_id";
	ts.count = 1; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="SELECT * #db.trustedsql(rs.select)# 
	FROM #db.table("event", request.zos.zcoreDatasource)# 
	#db.trustedsql(rs.leftJoin)# 
	WHERE event.site_id = #db.param(request.zos.globals.id)# and 
	event_deleted = #db.param(0)# and 
	event_id=#db.param(form.event_id)#
	GROUP BY event.event_id "; 
	rs={};
	rs.qData=db.execute("qData");

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getEditForm" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject; 

	rs={
		javascriptChangeCallback:"",
		javascriptLoadCallback:"",
		tabs:{
			"Basic":{
				fields:[]
			},
			"Advanced":{
				fields:[]
			}
		}
	};
	// basic fields
	fs=[];

	savecontent variable="field"{
		echo('<input type="text" name="event_name" value="#htmleditformat(form.event_name)#" />');
	}
	arrayAppend(fs, {label:'Event Name', required:true, field:field});
	if(application.zcore.functions.zso(request.zos.globals, 'enableLeadReminderEventManagerCC', true, 0) EQ 1){
		savecontent variable="field"{
		echo('<input type="text" name="event_manager_email_list" value="#htmleditformat(form.event_manager_email_list)#" />
		<br>Note: Managers are CC''d on lead notifications if this feature is enabled.');
		}
	}
	arrayAppend(fs, {label:'Manager Email List', field:field});

	savecontent variable="field"{
		htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
		htmlEditor.instanceName	= "event_description";
		htmlEditor.value			= form.event_description;
		htmlEditor.basePath		= '/';
		htmlEditor.width			= "100%";
		htmlEditor.height		= 300;
		htmlEditor.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
		htmlEditor.create();
	}
	arrayAppend(fs, {label:'Description', field:field});
				

	savecontent variable="field"{
		echo('<input type="text" name="event_address" value="#htmleditformat(form.event_address)#" />');
	}
	arrayAppend(fs, {label:'Address', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="event_address2" value="#htmleditformat(form.event_address2)#" />');
	}
	arrayAppend(fs, {label:'Address 2', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="event_phone" value="#htmleditformat(form.event_phone)#" />');
	}
	arrayAppend(fs, {label:'Phone', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="event_phone2" value="#htmleditformat(form.event_phone2)#" />');
	}
	arrayAppend(fs, {label:'Phone 2', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="event_fax" value="#htmleditformat(form.event_fax)#" />');
	}
	arrayAppend(fs, {label:'Fax', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="event_city" value="#htmleditformat(form.event_city)#" />');
	}
	arrayAppend(fs, {label:'City', field:field});

	savecontent variable="field"{
		echo(application.zcore.functions.zStateSelect("event_state", application.zcore.functions.zso(form,'event_state')));
	}
	arrayAppend(fs, {label:'State', field:field});

	savecontent variable="field"{
		echo(application.zcore.functions.zCountrySelect("event_country", application.zcore.functions.zso(form,'event_country')));
	}
	arrayAppend(fs, {label:'Country', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="event_zip" value="#htmleditformat(form.event_zip)#" />');
	}
	arrayAppend(fs, {label:'Postal Code', field:field});
  
	savecontent variable="field"{
		ts=structnew();
		ts.name="event_image_library_id";
		ts.value=form["event_image_library_id"];
		application.zcore.imageLibraryCom.getLibraryForm(ts); 
	}
	arrayAppend(fs, {label:'Photos', field:field});
	rs.tabs.basic.fields=fs;
	// advanced fields
	/*
	fs=[];
	savecontent variable="field"{
		echo('<input type="text" name="event_advanced" value="#htmleditformat(form.event_advanced)#" />');
	}
	arrayAppend(fs, {label:'Advanced Field', field:field});

	rs.tabs.advanced.fields=fs; 
	*/

	return rs;
	</cfscript> 
</cffunction>

<cffunction name="getListData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 

	form.search_name=application.zcore.functions.zso(form, 'search_name');

	ts=structnew();
	ts.image_library_id_field="event.event_image_library_id";
	ts.count = 1; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="SELECT * #db.trustedsql(rs.select)# 
	FROM #db.table("event", request.zos.zcoreDatasource)# 
	#db.trustedsql(rs.leftJoin)# 
	WHERE event.site_id = #db.param(request.zos.globals.id)# and 
	event_deleted = #db.param(0)# ";
	if(form.search_name NEQ ""){
		db.sql&=" and event_name LIKE #db.param('%'&form.search_name&'%')# ";
	}
	db.sql&=" GROUP BY event.event_id "; 
	sortColumnSQL=getSortColumnSQL();
	if(sortColumnSQL NEQ ''){
		db.sql&=" ORDER BY #sortColumnSQL# event_sort, event_name ";
	}else{
		db.sql&=" order by event_sort, event_name ";
	}
	db.sql&=" LIMIT #db.param((form.zIndex-1)*variables.perpage)#, #db.param(variables.perpage)# ";
	rs={};
	rs.searchFields=[{
		fields:[{
			formField:'<input type="search" name="search_name" id="search_name" placeholder="Name" value="#htmleditformat(form.search_name)#"> ',
			field:"search_name"
		}]
	}];
	rs.qData=db.execute("qData");

	db.sql="SELECT count(*) count
	FROM #db.table("event", request.zos.zcoreDatasource)# 
	WHERE event.site_id = #db.param(request.zos.globals.id)# and 
	event_deleted = #db.param(0)# ";
	if(form.search_name NEQ ""){
		db.sql&=" and event_name LIKE #db.param('%'&form.search_name&'%')# ";
	} 
	rs.qCount=db.execute("qCount");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListRow" localmode="modern" access="private">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="columns" type="array" required="yes">
	<cfscript>
	row=arguments.row;
	columns=arguments.columns; 
	arrayAppend(columns, {field: row.event_id});
	savecontent variable="field"{
		ts=structnew();
		ts.image_library_id=row.event_image_library_id;
		ts.output=false;
		ts.struct=row;
		ts.size="100x70";
		ts.crop=0;
		ts.count = 1; // how many images to get
		//zdump(ts);
		arrImages=application.zcore.imageLibraryCom.displayImageFromStruct(ts); 
		for(i=1;i LTE arraylen(arrImages);i++){
			writeoutput('<img src="'&arrImages[i].link&'">');
		} 
	}
	arrayAppend(columns, {field: field, style:"width:100px; vertical-align:top; " });

	arrayAppend(columns, {field: row.event_name});

	savecontent variable="field"{
		echo('#row.event_address#<br />
		#row.event_address#<br />
		#row.event_city#, #row.event_state# 
		#row.event_zip# #row.event_country#');
	}
	arrayAppend(columns, {field: field});
	arrayAppend(columns, {field: row.event_phone});  
	arrayAppend(columns, {field: application.zcore.functions.zTimeSinceDate(row.event_updated_datetime)}); 
	savecontent variable="field"{
		displayRowSortButton(row.event_id);
		editLinks=[{
					label:"Edit Event",
					link:variables.prefixURL&"edit?event_id=#row.event_id#&modalpopforced=1",
					enableEditAjax:true // only possible for the link that replaces the current row
				}];
		if(variables.hasLeadsAccess){
			arrayAppend(editLinks, {
				label:"Manage Leads",
				link:"/z/inquiries/admin/manage-inquiries/index?search_event_id=#row.event_id#"
			});
		}
		ts={
			buttons:[/*{
				icon:"",
				link:"",
				label:"Text by itself"
			},{
				title:"View",
				icon:"eye",
				link:'##',
				label:"",
				target:"_blank"
			},*/{
				title:"Edit",
				icon:"cog",
				links:editLinks,
				label:""
			},{
				title:"Delete",
				icon:"trash",
				link:variables.prefixURL&"delete?event_id=#row.event_id#&returnJson=1",
				label:'',
				enableDeleteAjax:true
			}]
		}; 
		displayAdminMenu(ts);

	}
	arrayAppend(columns, {field: field, class:"z-manager-admin", style:"width:280px; max-width:100%;"});
	</cfscript> 
</cffunction>	

</cfoutput>
</cfcomponent>
