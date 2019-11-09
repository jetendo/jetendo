<cfcomponent>
<cfoutput>


<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.adminSecurityFilter.requireFeatureAccess("Event Calendars", true);
	db.sql="SELECT * FROM #db.table("event_calendar", request.zos.zcoreDatasource)# event_calendar
	WHERE event_calendar_id= #db.param(application.zcore.functions.zso(form,'event_calendar_id'))# and 
	event_calendar_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	qCheck=db.execute("qCheck");
	
	form.returnJson=application.zcore.functions.zso(form, 'returnJson', true, 0);
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Event calendar no longer exists', false,true);
		application.zcore.functions.zRedirect('/z/event/admin/manage-event-calendar/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form,'confirm')>
		<cfscript> 
		application.zcore.functions.zDeleteUniqueRewriteRule(qCheck.event_calendar_unique_url);

		db.sql="DELETE FROM #db.table("event_calendar", request.zos.zcoreDatasource)#  
		WHERE event_calendar_id= #db.param(application.zcore.functions.zso(form, 'event_calendar_id'))# and 
		event_calendar_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# ";
		q=db.execute("q");

		eventCom=application.zcore.app.getAppCFC("event");
		ss=application.zcore.app.getAppData("event").sharedStruct;
		eventCom.updateEventCalendarCache(ss);
		eventCom.searchIndexDeleteCalendar(form.event_calendar_id);

		// also delete the categories and events, image libraries, and event_x_category attached to this calendar?

		if(form.returnJson EQ 1){
			application.zcore.functions.zReturnJson({success:true});
		}else{
			application.zcore.status.setStatus(Request.zsid, 'Event calendar deleted');
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-calendar/index?zsid=#request.zsid#');
		}
		</cfscript>
	<cfelse>
		<div style="font-size:14px; font-weight:bold; text-align:center; "> Are you sure you want to delete this event calendar?<br />
			<br />
			#qCheck.event_calendar_name#br />
			<br />
			<a href="/z/event/admin/manage-event-calendar/delete?confirm=1&amp;event_calendar_id=#form.event_calendar_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/event/admin/manage-event-calendar/index">No</a> 
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
	db=request.zos.queryObject;
	var ts={};
	var result=0;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Event Calendars", true);
	form.site_id = request.zos.globals.id;
	ts.event_calendar_name.required = true;
	ts.event_calendar_list_views.required=true;
	ts.event_calendar_list_perpage.required=true;
	result = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);
	if(application.zcore.functions.zso(form,'event_calendar_unique_url') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'event_calendar_unique_url'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		result=true;
	}
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-calendar/add?zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-calendar/edit?event_calendar_id=#form.event_calendar_id#&zsid=#request.zsid#');
		}
	}
	if(form.event_calendar_list_perpage EQ "" or form.event_calendar_list_perpage EQ 0){
		form.event_calendar_list_perpage=10;
	}
	form.event_calendar_user_group_idlist=application.zcore.functions.zso(form, 'event_calendar_user_group_idlist');

	uniqueChanged=false;
	oldURL='';
	if(form.method EQ 'insert' and application.zcore.functions.zso(form, 'event_calendar_unique_url') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ 'update'){
		db.sql="SELECT * FROM #db.table("event_calendar", request.zos.zcoreDatasource)# 
		WHERE event_calendar_id = #db.param(form.event_calendar_id)# and 
		event_calendar_deleted = #db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'You don''t have permission to edit this event calendar.',form,true);
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-calendar/index?zsid=#request.zsid#');
		}
		oldURL=qCheck.event_calendar_unique_url;
		if(structkeyexists(form, 'event_calendar_unique_url') and qcheck.event_calendar_unique_url NEQ form.event_calendar_unique_url){
			uniqueChanged=true;	
		}
	}


	ts=StructNew();
	ts.table='event_calendar';
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
	if(form.method EQ 'insert'){
		form.event_calendar_id = application.zcore.functions.zInsert(ts);
		if(form.event_calendar_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save event calendar.',form,true);
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-calendar/add?zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Event calendar saved.');
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save event calendar.',form,true);
			application.zcore.functions.zRedirect('/z/event/admin/manage-event-calendar/edit?event_calendar_id=#form.event_calendar_id#&zsid=#request.zsid#');
		}else{
			application.zcore.status.setStatus(request.zsid, 'Event calendar updated.');
		}
		
	} 
	eventCom=application.zcore.app.getAppCFC("event");
	ss=application.zcore.app.getAppData("event").sharedStruct;
	eventCom.updateEventCalendarCache(ss);
	if(uniqueChanged){
		eventCom.updateRewriteRuleCalendar(form.event_calendar_id, oldURL);	
	}
	eventCom.searchReindexCalendar(form.event_calendar_id, false);


	if(form.modalpopforced EQ 1){
		application.zcore.functions.zRedirect('/z/event/admin/manage-event-calendar/getReturnEventCalendarRowHTML?event_calendar_id=#form.event_calendar_id#');
	}else{
		application.zcore.functions.zRedirect('/z/event/admin/manage-event-calendar/index?zsid=#request.zsid#');
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
	application.zcore.functions.zSetPageHelpId("10.4");
	application.zcore.adminSecurityFilter.requireFeatureAccess("Event Calendars");	
	if(application.zcore.functions.zso(form,'event_calendar_id') EQ ''){
		form.event_calendar_id = -1;
	}
	db.sql="SELECT * FROM #db.table("event_calendar", request.zos.zcoreDatasource)# event_calendar 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	event_calendar_deleted = #db.param(0)# and 
	event_calendar_id=#db.param(form.event_calendar_id)#";
	qEvent=db.execute("qEvent");
	application.zcore.functions.zQueryToStruct(qEvent);
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
		</cfif> Event Calendar</h2>
		<p>* Denotes required field.</p>
	<form class="zFormCheckDirty" action="/z/event/admin/manage-event-calendar/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?event_calendar_id=#form.event_calendar_id#" method="post">
		<input type="hidden" name="modalpopforced" value="#form.modalpopforced#" />
		<table style="width:100%;" class="table-list">
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">Save</button>
				
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<cfscript>
						cancelLink="/z/event/admin/manage-event-calendar/index";
						</cfscript>
						<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href='#cancelLink#';">Cancel</button>
					</cfif>
				</td></td>
			</tr>
			<tr>
				<th>Name</th>
				<td><input type="text" name="event_calendar_name" value="#htmleditformat(form.event_calendar_name)#" /> *</td>
			</tr> 


			
			<tr>
				<th>Description</th>
				<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "event_calendar_description";
					htmlEditor.value			= form.event_calendar_description;
					htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
					htmlEditor.height		= 350;
					htmlEditor.create();
					</cfscript>   
				</td>
			</tr> 
			<tr>
				<th>List Views</th>
				<td>
					<cfscript>
					ts = StructNew();
					ts.name = "event_calendar_list_views"; 
					ts.size = 1; // more for multiple select
					ts.hideSelect=true;
					ts.listLabels = "List,Month";
					ts.listValues = "List,Month";
					//ts.listLabels = "List,2 Months,Month,Week,Day";
					//ts.listValues = "List,2 Months,Month,Week,Day";
					ts.listLabelsDelimiter = ","; 
					ts.listValuesDelimiter = ",";
					
					if(form.event_calendar_list_views EQ ""){
						form.event_calendar_list_views="List,Month";
					}
					ts.multiple = true; 
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'event_calendar_list_views'));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript> *
				</td>
			</tr> 
			<tr>
				<th>List Default View</th>
				<td>
					<cfscript>
					ts = StructNew();
					ts.name = "event_calendar_list_default_view"; 
					ts.size = 1; // more for multiple select
					ts.hideSelect=true;
					ts.listLabels = "List,Calendar";
					ts.listValues = "List,Calendar";
					ts.listLabelsDelimiter = ","; 
					ts.listValuesDelimiter = ",";
					
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript>
				</td>
			</tr> 
			<tr>
				<th>Events Per Page</th>
				<td>
					<cfscript>
					if(form.event_calendar_list_perpage EQ "" or form.event_calendar_list_perpage EQ 0){
						form.event_calendar_list_perpage=10;
					}
					</cfscript>
					<input type="text" name="event_calendar_list_perpage" value="#htmleditformat(form.event_calendar_list_perpage)#" /> * (Applies to list view only)
				</td>
			</tr> 
			<tr>
				<th>User Access Rights:</th>
				<td>
					<cfscript>
					db.sql="SELECT *FROM #db.table("user_group", request.zos.zcoreDatasource)# user_group 
					WHERE site_id = #db.param(request.zos.globals.id)# and 
					user_group_deleted = #db.param(0)# 
					ORDER BY user_group_name asc"; 
					var qGroup2=db.execute("qGroup2"); 
					ts = StructNew();
					ts.name = "event_calendar_user_group_idlist";
					ts.friendlyName="";
					ts.multiple=true;
					// options for query data
					ts.query = qGroup2;
					ts.queryLabelField = "user_group_friendly_name";
					ts.queryValueField = "user_group_id";
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'event_calendar_user_group_idlist'));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript>
					(Leave empty unless you want to disable public access to this calendar and all its categories and events.)
				</td>
			</tr>
			<cfscript>
			if(application.zcore.functions.zso(form,'event_calendar_searchable') EQ ""){
				event_calendar_searchable="1";
			}
			</cfscript>
			<tr>
				<th>Searchable</th>
				<td>#application.zcore.functions.zInput_Boolean("event_calendar_searchable")#</td>
			</tr> 
			
			<tr>
				<th style="vertical-align:top; width:120px; ">Meta Title</th>
				<td>
					<input type="text" name="event_calendar_metatitle" style="width:95%;" value="#htmleditformat(form.event_calendar_metatitle)#">
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; width:120px; ">Meta Keywords</th>
				<td>
					<textarea name="event_calendar_metakey" style="width:95%; height:60px; ">#htmleditformat(form.event_calendar_metakey)#</textarea>
				</td>
			</tr>
			<tr>
				<th style="vertical-align:top; width:120px; ">Meta Description</th>
				<td>
					<textarea name="event_calendar_metadesc" style="width:95%; height:60px; ">#htmleditformat(form.event_calendar_metadesc)#</textarea>
				</td>
			</tr>
			<tr>
				<th>Unique URL</th>
				<td>
					<cfif currentmethod EQ "add">
						#application.zcore.functions.zInputUniqueUrl("event_calendar_unique_url", true)#
					<cfelse>
						#application.zcore.functions.zInputUniqueUrl("event_calendar_unique_url")#
					</cfif>
				</td>
			</tr> 
			<tr>
				<th style="width:1%;">&nbsp;</th>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">Save</button>
					
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" class="z-manager-search-button" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<cfscript>
						cancelLink="/z/event/admin/manage-event-calendar/index";
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
	application.zcore.adminSecurityFilter.requireFeatureAccess("Event Calendars");	
	application.zcore.functions.zSetPageHelpId("10.3");
	db.sql="select *, if(event.event_id IS NULL, #db.param(0)#, #db.param(1)#) hasEvents 
	from #db.table("event_calendar", request.zos.zcoreDatasource)#
	LEFT JOIN #db.table("event", request.zos.zcoreDatasource)# ON 
	CONCAT(#db.param(',')#, event.event_calendar_id, #db.param(',')#) LIKE concat(#db.param('%,')#, event_calendar.event_calendar_id, #db.param(',%')#) and 
	event_deleted=#db.param(0)# and 
	event.site_id = event_calendar.site_id 
	WHERE event_calendar.site_id =#db.param(request.zos.globals.id)# and 
	event_calendar_deleted=#db.param(0)# 
	GROUP BY event_calendar.event_calendar_id 
	ORDER BY event_calendar_name ASC";
	qList=db.execute("qList"); 
	echo('<div class="z-manager-list-view">');
	request.eventCom=application.zcore.app.getAppCFC("event");
	request.eventCom.getAdminNavMenu();
	echo('<div class="z-float z-mb-10">'); 
	echo('<h2 style="display:inline-block;">Event Calendars</h2>'); 
	echo(' &nbsp;&nbsp; <a href="/z/event/admin/manage-event-calendar/add" class="z-button">Add</a>
	</div>');
	</cfscript> 
 
	<table class="table-list">
		<tr>
			<th>Name</th>
			<th>Access</th>
			<th>Last Updated</th>
			<th>Admin</th>
		</tr>
		<cfscript>
		for(row in qList){
			echo('<tr>');
			getEventCalendarRowHTML(row);
			echo('</tr>');
		}
		</cfscript>  
	</table>
	<cfscript>
	if(qList.recordcount EQ 0){
		echo('<p>No event calendars found</p>');
	}
	</cfscript>
	</div>
</cffunction>

<cffunction name="getReturnEventCalendarRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	db.sql="SELECT *, if(event.event_id IS NULL, #db.param(0)#, #db.param(1)#) hasEvents 
	FROM #db.table("event_calendar", request.zos.zcoreDatasource)# 
	LEFT JOIN #db.table("event", request.zos.zcoreDatasource)# ON 
	CONCAT(#db.param(',')#, event.event_calendar_id, #db.param(',')#) LIKE #db.param('%,'&form.event_calendar_id&',%')# and 
	event_deleted=#db.param(0)# and 
	event.site_id = event_calendar.site_id 
	WHERE event_calendar.site_id =#db.param(request.zos.globals.id)# and 
	event_calendar_deleted = #db.param(0)# and 
	event_calendar.event_calendar_id=#db.param(form.event_calendar_id)# 
	GROUP BY event_calendar.event_calendar_id ";
	qCalendar=db.execute("qCalendar"); 
	
	request.eventCom=application.zcore.app.getAppCFC("event");
	savecontent variable="rowOut"{
		for(row in qCalendar){
			getEventCalendarRowHTML(row);
		}
	}

	echo('done.<script>
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>
	
<cffunction name="getEventCalendarRowHTML" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	echo('<td>#row.event_calendar_name#</td>
	<td>');
	if(row.event_calendar_user_group_idlist EQ ""){
		echo('Public');
	}else{
		echo('Private');
	}
	echo('</td>
	<td>#application.zcore.functions.zGetLastUpdatedDescription(row.event_calendar_updated_datetime)#</td>
	<td>
		<a href="#request.eventCom.getCalendarURL(row)#" target="_blank">View Calendar</a> | 
		<a href="#request.eventCom.getCalendarListURL(row)#" target="_blank">View List</a> | 
		<a href="/z/event/admin/manage-events/add?event_calendar_id=#row.event_calendar_id#">Add Event</a> | 
		<a href="/z/event/admin/manage-events/index?event_calendar_id=#row.event_calendar_id#">Manage Events</a> | 
		<a href="/z/event/admin/manage-event-category/index?event_calendar_id=#row.event_calendar_id#">Manage Categories</a> | ');
	if(row.event_calendar_user_group_idlist EQ ""){
		echo('<a href="/z/event/admin/manage-event-widgets/index?calendarids=#row.event_calendar_id#">Embed</a> | ');
	}
		echo('<a href="/z/event/admin/manage-event-calendar/edit?event_calendar_id=#row.event_calendar_id#&amp;modalpopforced=1"  onclick="zTableRecordEdit(this);  return false;">Edit</a>');
		if(not row.hasEvents){
			if(not application.zcore.functions.zIsForceDeleteEnabled(row.event_calendar_unique_url)){
				echo(' | Delete disabled');
			}else{
				echo(' | <a href="##" onclick="zDeleteTableRecordRow(this, ''/z/event/admin/manage-event-calendar/delete?event_calendar_id=#row.event_calendar_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a>');
			} 
		}else{
			echo(' | Delete disabled');
		}
	echo('</td>');

	</cfscript>
</cffunction>
</cfoutput>
</cfcomponent>