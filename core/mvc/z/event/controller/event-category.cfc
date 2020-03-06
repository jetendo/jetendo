<cfcomponent>
<cfoutput>
<cffunction name="index" localmode="modern" access="remote">
	<cfscript>
	
	if(not request.zos.istestserver){
		application.zcore.functions.z404("Invalid request");
	}
	</cfscript>
</cffunction>

<cffunction name="viewCategory" localmode="modern" access="remote">
	<cfscript>
	request.zos.currentURLISAnEventPage=true;
    db=request.zos.queryObject;  
	application.zcore.functions.zRequireJqueryUI();

	form.event_category_id=application.zcore.functions.zso(form, 'event_category_id', true);


	db.sql="select * from #db.table("event_category", request.zos.zcoreDatasource)# 
	WHERE site_id = #db.param(request.zos.globals.id)# and 
	event_category_deleted=#db.param(0)# and 
	event_category_id = #db.param(form.event_category_id)# ";
	qCategory=db.execute("qCategory", "", 10000, "query", false);
	application.zcore.functions.zQueryToStruct(qCategory, form);
	if(qCategory.recordcount EQ 0){
		application.zcore.functions.z404("form.event_category_id, #form.event_category_id#,  doesn't exist.");
	}
	if(not application.zcore.app.getAppCFC("event").userHasAccessToEventCalendarID(qCategory.event_calendar_id)){
		application.zcore.status.setStatus(request.zsid, "You must login to view the calendar");
		application.zcore.functions.zRedirect("/z/user/preference/index?zsid=#request.zsid#&returnURL=#urlencodedformat(request.zos.originalURL)#");
	}
	categoryStruct={};
	for(row in qCategory){
		categoryStruct=row;
	} 
	application.zcore.template.setTag("meta", '<meta name="Keywords" content="#htmleditformat(qCategory.event_category_metakey)#" /><meta name="Description" content="#htmleditformat(qCategory.event_category_metadesc)#" />');
	if(qCategory.event_category_metatitle NEQ ""){
		application.zcore.template.setTag( "title", qCategory.event_category_metatitle);
	}else{
		application.zcore.template.setTag("title", qCategory.event_category_name);
	} 
	application.zcore.template.setTag("pagetitle", qCategory.event_category_name);
	echo(qCategory.event_category_description);
	if(structkeyexists(form, 'zUrlName')){
		if(categoryStruct.event_category_unique_url EQ ""){

			curLink=application.zcore.app.getAppCFC("event").getCategoryURL(categoryStruct); 
			urlId=application.zcore.app.getAppData("event").optionstruct.event_config_category_url_id;
			actualLink="/"&application.zcore.functions.zURLEncode(form.zURLName, '-')&"-"&urlId&"-"&categoryStruct.event_category_id&".html";

			if(compare(curLink,actualLink) neq 0){
				application.zcore.functions.z301Redirect(curLink);
			}
		}else{
			if(compare(categoryStruct.event_category_unique_url, request.zos.originalURL) NEQ 0){
				application.zcore.functions.z301Redirect(categoryStruct.event_category_unique_url);
			}
		}
	} 

	form.zview=application.zcore.functions.zso(form, 'zview');
	arrView=listToArray(qCategory.event_category_list_views, ",");

	ss={};
	ss.viewStruct={};
	for(i=1;i<=arrayLen(arrView);i++){
		ss.viewStruct[arrView[i]]=true;
	}
	ss.defaultView=form.event_category_list_default_view;
	if(form.zview NEQ ""){
		ss.defaultView=form.zview;
	}
	ss.jsonFullLink="/z/event/event-calendar/getFullCalendarJson?categories=#form.event_category_id#";
	ss.jsonListLink="/z/event/event-calendar/getListViewCalendarJson?categories=#form.event_category_id#";

	calendarCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.event.controller.event-calendar");
	if(qCategory.event_category_searchable){
		ss.searchable=true;
	}
	calendarCom.displayCalendar(ss);
	</cfscript> 

</cffunction>
</cfoutput>
</cfcomponent>