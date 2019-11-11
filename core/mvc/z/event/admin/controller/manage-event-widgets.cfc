<cfcomponent>
<cfoutput> 	
<cffunction name="index" access="remote" localmode="modern" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.adminSecurityFilter.requireFeatureAccess("Event Widgets");
	application.zcore.functions.zSetPageHelpId("10.7");
	form.heading=request.zos.functions.zso(form, 'heading');
	form.calendarids=request.zos.functions.zso(form, 'calendarids');
	form.categories=request.zos.functions.zso(form, 'categories'); 
	if(form.categories NEQ ""){
		form.calendarids="";
	}
	form.limit=min(20,request.zos.functions.zso(form, 'limit', true, 4));
	form.width=request.zos.functions.zso(form, 'width', true, 300);
	form.height=request.zos.functions.zso(form, 'height', true, 500);
	link='#request.zos.globals.domain#/z/event/event-widget?limit=#form.limit#';
	if(form.heading NEQ ""){
		link&="&amp;heading=#urlencodedformat(form.heading)#";
	}
	if(form.calendarids NEQ ""){
		link&="&amp;calendarids=#form.calendarids#";
	}
	if(form.categories NEQ ""){
		link&="&amp;categories=#form.categories#";
	}
	output='<iframe width="#form.width#" height="#form.height#" style="margin:0px;overflow:auto; border:none;" seamless="seamless" src="#link#"></iframe>';
	</cfscript>
	<h2>Calendar Widget Code</h2>
	<p>If you select a category, the calendars will be unselected.</p>

	<form action="/z/event/admin/manage-event-widgets/index" method="get">
	<div style="width:100%; margin-bottom:10px; float:left;">
	<div style="width:90px; float:left;">
	Calendars: 
	</div>
	<div style="width:70%; float:left;">

		<cfscript>
		db.sql="select * from #db.table("event_calendar", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		event_calendar_deleted=#db.param(0)#  
		ORDER BY event_calendar_name ASC";
		qCalendar=db.execute("qCalendar"); 
		ts = StructNew();
		ts.name = "calendarids"; 
		ts.size = 1; 
		ts.selectLabel="-- All --";
		ts.multiple = true; 
		ts.query = qCalendar;
		ts.queryLabelField = "event_calendar_name";
		ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
		ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
		ts.queryValueField = "event_calendar_id"; 
		application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'calendarids'));
		application.zcore.functions.zInputSelectBox(ts);
		</cfscript>
	</div>
	</div>
	<div style="width:100%; margin-bottom:10px; float:left;">
	<div style="width:90px; float:left;">
	Categories: 
	</div>
	<div style="width:70%; float:left;">
		<cfscript>
		db.sql="select *, concat(event_calendar_name, #db.param(' -> ')#, event_category_name) calendarCategoryName from 
		#db.table("event_calendar", request.zos.zcoreDatasource)#,
		#db.table("event_category", request.zos.zcoreDatasource)# WHERE 
		event_calendar.site_id = event_category.site_id and 
		event_category_deleted=#db.param(0)# and 
		event_calendar.site_id = #db.param(request.zos.globals.id)# and 
		event_calendar_deleted=#db.param(0)# 
		ORDER BY event_calendar_name ASC, event_category_name ASC";
		qCalendar=db.execute("qCalendar"); 
		ts = StructNew();
		ts.name = "categories"; 
		ts.selectLabel="-- All --";
		ts.size = 1; 
		//ts.multiple = true; 
		ts.query = qCalendar;
		ts.queryLabelField = "calendarCategoryName";
		ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
		ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
		ts.queryValueField = "event_category_id"; 
		//application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'categories'));
		application.zcore.functions.zInputSelectBox(ts);
		</cfscript>
		
	</div>
	</div>
	<div style="width:100%; margin-bottom:10px; float:left;">
	<div style="width:90px; float:left;">
	## of Events: 
	</div>
	<div style="width:70%; float:left;">
	<input type="text" name="limit" value="#form.limit#" /> (A number 20 or less)
	</div>
	</div>
	<div style="width:100%; margin-bottom:10px; float:left;">
	<div style="width:90px; float:left;">
	Heading: 
	</div>
	<div style="width:70%; float:left;"><input type="text" name="heading" value="Upcoming Events" />
	</div>
	</div>

	<div style="width:100%; margin-bottom:10px; float:left;">
	<div style="width:90px; float:left;">
	Width: 
	</div>
	<div style="width:70%; float:left;"><input type="text" name="width" value="#form.width#" />
	</div>
	</div>
	<div style="width:100%; margin-bottom:10px; float:left;">
	<div style="width:90px; float:left;">
	Height:
	</div>
	<div style="width:70%; float:left;"> <input type="text" name="height" value="#form.height#" />
	</div>
	</div>
	<div style="width:100%; float:left;">
	<div style="width:90px; float:left;">
	&nbsp;
	</div>
	<div style="width:70%; margin-bottom:10px; float:left;">
	<input type="submit" name="submit1" value="Generate Widget Code" />
	</div></div>
	</form>
	<p>Copy and paste the following code into the source code of another web page to embed it.</p>
	<textarea name="widget1" cols="100" rows="3" onclick="this.select();">#htmleditformat(trim(output))#</textarea>
	<br /><br />
	#output#
</cffunction>
</cfoutput>
</cfcomponent>