<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>  

<cffunction name="addWidgetInstanceData" localmode="modern" access="remote" roles="member">
	<cfscript> 
	displayWidgetForm("data");
	</cfscript>
</cffunction>

<cffunction name="editWidgetInstanceData" localmode="modern" access="remote" roles="member">
	<cfscript> 
	displayWidgetForm("data");
	</cfscript>
</cffunction>

<cffunction name="addWidgetInstanceLayout" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript> 
	displayWidgetForm("layout");
	</cfscript>
</cffunction>

<cffunction name="editWidgetInstanceLayout" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	displayWidgetForm("layout");
	</cfscript>
</cffunction>
	
 
<cffunction name="displayWidgetForm" localmode="modern" access="public">
	<cfargument name="type" type="string" required="yes" hint="layout or data are valid values"> 
	<cfscript>
	initInstance();
	form.layout_column_x_widget_instance_id=application.zcore.functions.zso(form, 'layout_column_x_widget_instance_id');
	form.widget_instance_id=application.zcore.functions.zso(form, 'widget_instance_id');
	form.widget_id=application.zcore.functions.zso(form, 'widget_id');
	form.layout_column_x_widget_id=application.zcore.functions.zso(form, 'layout_column_x_widget_id');

	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', true);
	methodbackup=form.method;

	layoutWidgetCom=createObject("component", "layout-widget");
	rs=layoutWidgetCom.getWidgetCFC(form.widget_id);
	if(not rs.success){
		application.zcore.status.setStatus(request.zsid, "Invalid widget id", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	widgetCom=rs.cfc;
	comPath=rs.comPath;
	arrEnd=[];
	db=request.zos.queryObject; 


	ds={
		widget_instance_id:form.widget_instance_id,
		cssData:{}
	};
	widgetCom.init(ds);
	configStruct=widgetCom.getBaseConfig();
	fields=configStruct[arguments.type&"Fields"];

	application.zcore.functions.zStatusHandler(request.zsid, true);

	if(methodbackup EQ "editWidgetInstanceLayout" or methodbackup EQ "editWidgetInstanceData"){
		db.sql="select * from #db.table("widget_instance", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		widget_instance_deleted=#db.param(0)# and 
		widget_id =#db.param(form.widget_id)# and 
		widget_instance_id=#db.param(form.widget_instance_id)#";
		qWidget=db.execute("qWidget");
		if(qWidget.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid widget instance id", form, true);
			application.zcore.functions.zRedirect("/z/admin/landing-page-widget?landing_page_id=#form.landing_page_id#&widget_id=#form.widget_id#&amp;layout_column_id=#form.layout_column_id#&zsid=#request.zsid#");
		}
		jsonStruct=deserializeJson(qWidget.widget_instance_json_data);
		jsonFields=application.zcore.functions.zso(jsonStruct, arguments.type&'Fields', false, {});
		for(i=1;i<=arraylen(fields);i++){
			if(structkeyexists(jsonFields, fields[i].label)){
				fields[i].value=jsonFields[fields[i].label];
				form["newvalue"&fields[i].id]=jsonFields[fields[i].label];
			}
		}
		form.widget_instance_name=application.zcore.functions.zso(form, 'widget_instance_name', false, qWidget.widget_instance_name);
	}else{
		form.widget_instance_name=application.zcore.functions.zso(form, 'widget_instance_name');
	} 
	currentRowIndex=0;
	optionStruct={};
	dataStruct={};
	labelStruct={};
	posted=false;

	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}


	echo('<form id="siteOptionGroupForm" action="'); 
	echo('/z/admin/landing-page-widget/');
	if(methodbackup EQ "addWidgetInstanceLayout"){
		echo('insertWidgetInstanceLayout');
	}else if(methodbackup EQ "editWidgetInstanceLayout"){
		echo('updateWidgetInstanceLayout');
	}else if(methodbackup EQ "addWidgetInstanceData"){
		echo('insertWidgetInstanceData');
	}else if(methodbackup EQ "editWidgetInstanceData"){
		echo('updateWidgetInstanceData');
	} 
	echo('" method="post" enctype="multipart/form-data" >');
	</cfscript>
	 
	<input type="hidden" name="widget_id" value="#htmleditformat(form.widget_id)#" />
	<input type="hidden" name="widget_instance_id" value="#htmleditformat(form.widget_instance_id)#" /> 
	<input type="hidden" name="layout_column_id" value="#htmleditformat(form.layout_column_id)#" />  
	<input type="hidden" name="layout_row_id" value="#htmleditformat(form.layout_row_id)#" />   
	<input type="hidden" name="landing_page_id" value="#htmleditformat(form.landing_page_id)#" />  
	<input type="hidden" name="layout_column_x_widget_id" value="#htmleditformat(form.layout_column_x_widget_id)#" />
	<input type="hidden" name="layout_column_x_widget_instance_id" value="#htmleditformat(form.layout_column_x_widget_instance_id)#" />

	<table style="border-spacing:0px;" class="table-list">
 
		<tr><td>&nbsp;</td><td>
		<button type="submit" name="submitForm">Save</button>
			&nbsp;
			<cfif form.modalpopforced EQ 1>
				<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
			<cfelse>
				<cfscript>
				cancelLink="/z/admin/landing-page-widget/index?layout_row_id=#form.layout_row_id#&layout_column_x_widget_id=#form.layout_column_x_widget_id#&landing_page_id=#form.landing_page_id#&widget_id=#form.widget_id#&amp;layout_column_id=#form.layout_column_id#";
				</cfscript>
				<button type="button" name="cancel" onclick="window.location.href='#cancelLink#';">Cancel</button>
			</cfif>
		</td></tr> 
		<tr>
			<th>Instance Name</th>
			<td><input type="text" name="widget_instance_name" value="#htmleditformat(form.widget_instance_name)#">
			</td>
		</tr>
	<cfscript>
	/*typeStruct={}; 
	typeCFCStruct=application.zcore.siteOptionCom.getTypeCFCStruct();
	for(i in typeCFCStruct){ 
		typeCFC=application.zcore.siteOptionCom.getTypeCFC(i);
		options=typeCFC.getOptionFieldStruct();
		typeStruct[typeCFCStruct[i].getTypeName()]={id:i, typeCFC: typeCFC, options:options };		
	}*/
	layoutWidgetCom.validateWidgetConfig(comPath, configStruct);
	for(i=1;i<=arraylen(fields);i++){
		currentRowIndex++; 
		field=fields[i];
		id=fields[i].id;
		if(not structkeyexists(form, "newvalue"&id)){
			if(structkeyexists(form, field.label)){
				posted=true;
				form["newvalue"&id]=form[field.label];
			}else{
				if(structkeyexists(field,'value') and field.value NEQ ""){
					form["newvalue"&id]=field.value;
				}else{
					form["newvalue"&id]=field.defaultValue;
				}
			}
		}else{
			posted=true;
		}
		form[field.label]=form["newvalue"&id];    
		typeCFC=application.zcore.siteOptionCom.getTypeCFC(field.typeId);
		dataStruct=typeCFC.onBeforeListView(field, field.options, form);
		if((methodBackup EQ "addWidgetInstanceLayout" or methodBackup EQ "addWidgetInstanceData") and not posted and not typeCFC.isCopyable()){
			form["newvalue"&id]='';
		}
		value=typeCFC.getListValue(dataStruct, field.options, form["newvalue"&id]);
		if(value EQ ""){
			value=field.defaultValue;
		}
		labelStruct[field.label]=value;
	}
	currentRowIndex=0;
	for(i=1;i<=arraylen(fields);i++){
		currentRowIndex++; 
		field=fields[i];
		id=fields[i].id;
	 
		typeCFC=application.zcore.siteOptionCom.getTypeCFC(field.typeId);
		field.site_option_id=id;
		if(field.required EQ 1){
			field.site_option_required=1;
		}else{
			field.site_option_required=0;
		}
		rs=typeCFC.getFormField(field, field.options, 'newvalue', form);
		if(rs.hidden){
			arrayAppend(arrEnd, '<input type="hidden" name="site_option_id" value="'&id&'" />');
			arrayAppend(arrEnd, rs.value);
		}else{
			writeoutput('<tr class="siteOptionFormField#id# ');
			if(currentRowIndex MOD 2 EQ 0){
				writeoutput('row1');
			}else{
				writeoutput('row2');
			}
			writeoutput('">');
			if(rs.label and field.hideLabel EQ 0){
				tdOutput="";
				if(field.smallWidth EQ 1){
					tdOutput=' width:1%; white-space:nowrap; ';
				}
				writeoutput('<th style="vertical-align:top;#tdOutput#"><div style="padding-bottom:0px;float:left;">'&field.label&'<a id="soid_#id#" style="display:block; float:left;"></a>
				</div></th>
				<td style="vertical-align:top;white-space: nowrap;"><input type="hidden" name="site_option_id" value="#htmleditformat(id)#" />');
			}else{
				if(field.type EQ "HTML Separator"){
					writeoutput('<td style="vertical-align:top; padding-top:15px; padding-bottom:0px;" colspan="2">');
				}else{
					writeoutput('<td style="vertical-align:top; padding-top:5px;" colspan="2">');
				}
				if(rs.label){
					writeoutput('<input type="hidden" name="site_option_id" value="#htmleditformat(id)#" />');
				}
			} 
			if(field.readonly EQ 1 and labelStruct[field.label] NEQ ""){
				echo('<div class="zHideReadOnlyField" id="zHideReadOnlyField#currentRowIndex#">'&rs.value);
			}else{
				echo(rs.value);
			}
		}
		if(field.required){
			writeoutput(' * ');
		} 

		if(field.readonly EQ 1){// and labelStruct[field.label] NEQ ""){
			echo('</div>');
			echo('<div id="zReadOnlyButton#currentRowIndex#" class="zReadOnlyButton">#labelStruct[field.label]#');
			if(labelStruct[field.label] NEQ ""){
				echo('<hr />');
			}
			echo('<strong>Read only value</strong> | <a href="##" class="zEditReadOnly" data-readonlyid="zReadOnlyButton#currentRowIndex#" data-fieldid="zHideReadOnlyField#currentRowIndex#">Edit Anyway</a></div> ')
		}
		if(rs.label){
			writeoutput('</td>');	
			writeoutput('</tr>');
		}
	}
	</cfscript>
			<tr>
				<td>&nbsp;</td>
				<td>
					#arraytolist(arrEnd, '')# 
					<button type="submit" name="submitForm">Save</button>
					&nbsp;
					<cfif form.modalpopforced EQ 1>
						<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
					<cfelse>
						<button type="button" name="cancel" onclick="window.location.href='#cancelLink#';">Cancel</button>
					</cfif> 
				</td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="deleteLayoutColumnWidgetInstance" localmode="modern" access="remote" roles="member">
	<cfscript>
	initInstance(); 
	db=request.zos.queryObject; 
	db.sql="select c.* from 
	#db.table("layout_column_x_widget_instance", request.zos.zcoreDatasource)# c
	WHERE  
	layout_column_x_widget_instance_deleted=#db.param(0)# and 
	c.site_id = #db.param(request.zos.globals.id)# and 
	layout_column_x_widget_instance_id=#db.param(form.layout_column_x_widget_instance_id)# ";
	qWidget=db.execute("qWidget");
	if(qWidget.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid layout column widget instance id", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	} 
	deleteWidgetInstance(qWidget.widget_instance_id); 

	db.sql="delete from #db.table("layout_column_x_widget_instance", request.zos.zcoreDatasource)# WHERE 
	layout_column_x_widget_instance_id=#db.param(form.layout_column_x_widget_instance_id)# and 
	layout_column_x_widget_instance_deleted=#db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# "; 
	db.execute("qDelete");

	variables.queueSortCom.sortAll(); 
 
	rs={success:true};
	application.zcore.functions.zReturnJson(rs);
</cfscript>
</cffunction>

<cffunction name="deleteWidgetInstance" localmode="modern" access="public"> 
	<cfargument name="widget_instance_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject; 
	// select data
	db.sql="select * from 
	#db.table("widget_instance", request.zos.zcoreDatasource)#
	WHERE  
	widget_instance_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	widget_instance_id=#db.param(arguments.widget_instance_id)#";
	qWidget=db.execute("qWidget");
	if(qWidget.recordcount EQ 0){
		return false;
	}

	layoutWidgetCom=createObject("component", "layout-widget");
	rs=layoutWidgetCom.getWidgetCFC(qWidget.widget_id);
	if(not rs.success){
		return false;
	}
	widgetCom=rs.cfc;
	comPath=rs.comPath; 

	jsonStruct=deserializeJson(qWidget.widget_instance_json_data);

	ds={
		widget_instance_id:form.widget_instance_id,
		cssData:{}
	};
	widgetCom.init(ds);
	configStruct=widgetCom.getBaseConfig();
	layoutWidgetCom.validateWidgetConfig(comPath, configStruct); 

	arrType=["layout","data"];
	for(n=1;n<=arraylen(arrType);n++){
		fields=configStruct[arrType[n]&"Fields"];
		jsonFields=application.zcore.functions.zso(jsonStruct, arrType[n]&'Fields', false, {}); 
		for(i=1;i<=arraylen(fields);i++){
			field=fields[i];
			if(structkeyexists(jsonFields, fields[i].label)){
				field.value=jsonFields[fields[i].label];
			}else{
				field.value="";
			}
			typeCFC=application.zcore.siteOptionCom.getTypeCFC(field.typeId); 
			if(typeCFC.hasCustomDelete()){ 
				row2={
					site_x_option_group_id:0,
					site_option_group_id:0,
					site_option_id:field.id,
					site_x_option_group_value:field.value,
					site_x_option_group_original:"",
					site_id:request.zos.globals.id 
				};
				if(structkeyexists(jsonFields, fields[i].label&"_original")){
					row2.site_x_option_group_original=jsonFields[fields[i].label&"_original"];
				} 
				typeCFC.onDelete(row2, field.options); 
			}
		}
	}

	// delete widget_instance
	db.sql="delete from #db.table("widget_instance", request.zos.zcoreDatasource)# WHERE 
	widget_instance_id=#db.param(qWidget.widget_instance_id)# and 
	widget_instance_deleted=#db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	db.execute("qDelete");
 	
 	return true;
	</cfscript>
</cffunction>

<cffunction name="saved" localmode="modern" access="remote" roles="member">
	<cfscript>
	</cfscript>
	Close modal now.
</cffunction>

<cffunction name="insertWidgetInstanceLayout" localmode="modern" access="remote" roles="member">
	<cfscript>
	saveWidgetInstance();
	</cfscript>
</cffunction>
 
<cffunction name="updateWidgetInstanceLayout" localmode="modern" access="remote" roles="member">
	<cfscript> 
	saveWidgetInstance();
	</cfscript>
</cffunction>

<cffunction name="insertWidgetInstanceData" localmode="modern" access="remote" roles="member">
	<cfscript>
	saveWidgetInstance();
	</cfscript>
</cffunction>


<cffunction name="updateWidgetInstanceData" localmode="modern" access="remote" roles="member">
	<cfscript>
	saveWidgetInstance();
	</cfscript>
</cffunction>

<cffunction name="saveWidgetInstance" localmode="modern" access="public">
	<cfscript>
	initInstance();
	//writedump(form);	abort;
	db=request.zos.queryObject;  

	widgetCom=createobject("component", "zcorerootmapping.com.widget.widget-example");

	layoutWidgetCom=createObject("component", "layout-widget");
	ts={
		table:"widget_instance",
		datasource:request.zos.zcoreDatasource,
		struct:{}
	};
	if(form.method EQ "insertWidgetInstanceLayout" or form.method EQ "updateWidgetInstanceLayout"){
		if(not application.zcore.user.checkServerAccess()){
			application.zcore.status.setStatus(request.zsid, "Access denied - must be server administrator", form, true);
			application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
		}
	}
	if(form.method EQ "insertWidgetInstanceLayout"){
		failMethod="addWidgetInstanceLayout";
		type="layout";
	}else if(form.method EQ "updateWidgetInstanceLayout"){
		failMethod="editWidgetInstanceLayout";
		type="layout";
	}else if(form.method EQ "insertWidgetInstanceData"){
		failMethod="addWidgetInstanceData";
		type="data";
	}else if(form.method EQ "updateWidgetInstanceData"){
		failMethod="editWidgetInstanceData";
		type="data";
	}
	failLink="/z/admin/landing-page-widget/#failMethod#?layout_row_id=#form.layout_row_id#&layout_column_x_widget_id=#form.layout_column_x_widget_id#&landing_page_id=#form.landing_page_id#&layout_column_id=#form.layout_column_id#&widget_id=#form.widget_id#&widget_instance_id=#form.widget_instance_id#";
	t9={
		layoutFields:{},
		dataFields:{}
	};
	rs=layoutWidgetCom.getWidgetCFC(form.widget_id);
	if(not rs.success){
		application.zcore.status.setStatus(request.zsid, "Invalid widget id", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	oldData={};
	if(form.method EQ "updateWidgetInstanceLayout" or form.method EQ "updateWidgetInstanceData"){
		db.sql="select * from #db.table("widget_instance", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		widget_instance_deleted=#db.param(0)# and 
		widget_id =#db.param(form.widget_id)# and 
		widget_instance_id=#db.param(form.widget_instance_id)#";
		qWidget=db.execute("qWidget"); 
		if(qWidget.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid widget instance id", form, true);
			application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
		}
		t9=deserializeJson(qWidget.widget_instance_json_data);
		oldData=t9[type&"Fields"];
		t9[type&"Fields"]={}; 
	}  
	widgetCom=rs.cfc;
	comPath=rs.comPath; 
	ds={
		widget_instance_id:form.widget_instance_id,
		cssData:{}
	};
	widgetCom.init(ds);
	configStruct=widgetCom.getBaseConfig();
	layoutWidgetCom.validateWidgetConfig(comPath, configStruct);
	fields=configStruct[type&"Fields"];
 
	fail=false;
	for(i=1;i<=arraylen(configStruct["#type#Fields"]);i++){
		field=configStruct["#type#Fields"][i]; 
		if(structkeyexists(form, 'newvalue'&field.id)){
			v=form['newvalue'&field.id];
		}else{
			v="";
		}
		if(field.required EQ 1 and v EQ ""){
			application.zcore.status.setStatus(request.zsid, "#field.label# is required", form, true);
			fail=true;
			continue;
		}

		typeCFC=application.zcore.siteOptionCom.getTypeCFC(field.typeId); 
		row={
			site_x_option_group_id:1,
			site_option_id:field.id,
			site_option_group_id:0,
			site_x_option_group_set_id:0,
			site_id:request.zos.globals.id,
			site_x_option_group_value:application.zcore.functions.zso(oldData, field.label),
			site_x_option_group_updated_datetime:request.zos.mysqlnow,
			site_x_option_group_sort:1,
			site_option_id_siteIDType:1,
			site_option_app_id:0,
			site_x_option_group_date_value:"",
			site_x_option_group_disable_time:0,
			site_x_option_group_deleted:0,
			site_x_option_group_original:application.zcore.functions.zso(oldData, field.label&"_original"),
 		}
		if(field.type EQ "date" or field.type EQ "datetime"){
			row.site_x_option_group_date_value=application.zcore.functions.zso(oldData, field.label);
		}
		var rs=typeCFC.onBeforeUpdate(row, field.options, 'newvalue', form);
		if(not rs.success){
			fail=true;
			continue; 
		}
		nv=rs.value;
		var nvDate=rs.dateValue;
		if(field.type EQ "date" or field.type EQ "datetime"){
			nv=nvDate;
		}
		t9[type&"Fields"][field.label]=nv;
		if(structkeyexists(rs, 'originalFile')){
			t9[type&"Fields"][field.label&"_original"]=rs.originalFile;
		}
	}
	if(fail){
		application.zcore.functions.zRedirect("#failLink#&zsid=#request.zsid#");
	}
	if(type EQ "layout"){
		type2="data";
	}else{
		type2="layout";
	}
	fields=configStruct["#type2#Fields"];
	for(i=1;i<=arraylen(fields);i++){ 
		t9[type2&'Fields'][fields[i].label]=fields[i].defaultValue;
	}
	if(form.widget_instance_name EQ ""){
		application.zcore.status.setStatus(request.zsid, "Instance name is required", form, true);
		application.zcore.functions.zRedirect("#failLink#&zsid=#request.zsid#");
	}
	ts.struct.widget_instance_name=form.widget_instance_name;
	ts.struct.widget_instance_deleted=0;
	ts.struct.widget_instance_json_data=serializeJson(t9);
	ts.struct.widget_instance_updated_datetime=request.zos.mysqlnow;
	ts.struct.site_id=request.zos.globals.id;
	ts.struct.widget_id=form.widget_id;
	ts.struct.widget_instance_version=widgetCom.getWidgetVersion();

	ts2={
		table:"layout_column_x_widget_instance",
		datasource:request.zos.zcoreDatasource, 
		struct:{
			widget_id:form.widget_id,
			layout_column_x_widget_id:form.layout_column_x_widget_id,
			layout_column_id:form.layout_column_id,
			layout_column_x_widget_instance_uuid:createuuid(), 
			site_id:request.zos.globals.id,
			layout_column_x_widget_instance_sort:0, 
			layout_column_x_widget_instance_updated_datetime:request.zos.mysqlnow,
			layout_column_x_widget_instance_deleted:0
		}
	};
	if(form.method EQ "insertWidgetInstanceLayout" or form.method EQ "insertWidgetInstanceData"){
		form.widget_instance_id=application.zcore.functions.zInsert(ts);
		if(form.widget_instance_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save widget instance", form, true);
			application.zcore.functions.zRedirect("#failLink#&zsid=#request.zsid#");
		}
		ts2.struct.widget_instance_id=form.widget_instance_id;
		form.layout_column_x_widget_instance_id=application.zcore.functions.zInsert(ts2);
		if(form.layout_column_x_widget_instance_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save column widget instance", form, true);
			application.zcore.functions.zRedirect("#failLink#&zsid=#request.zsid#");
		}

		variables.queueSortCom.sortAll();
	}else{
		ts2.struct.widget_instance_id=form.widget_instance_id;
		ts2.struct.layout_column_x_widget_instance_id=form.layout_column_x_widget_instance_id;
		ts.struct.widget_instance_id=form.widget_instance_id;
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save widget instance", form, true);
			application.zcore.functions.zRedirect("#failLink#&zsid=#request.zsid#");
		}
		if(application.zcore.functions.zUpdate(ts2) EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save column widget instance", form, true);
			application.zcore.functions.zRedirect("#failLink#&zsid=#request.zsid#");
		}
	} 
	application.zcore.status.setStatus(request.zsid, "Saved");
	application.zcore.functions.zRedirect("/z/admin/landing-page-widget/index?layout_row_id=#form.layout_row_id#&layout_column_x_widget_id=#form.layout_column_x_widget_id#&landing_page_id=#form.landing_page_id#&layout_column_id=#form.layout_column_id#&widget_id=#form.widget_id#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

 

<cffunction name="initInstance" localmode="modern" access="private" roles="member">
	<cfscript> 
	form.widget_id=application.zcore.functions.zso(form, 'widget_id', true);
	form.layout_page_id=application.zcore.functions.zso(form, 'layout_page_id', true);
	form.layout_column_id=application.zcore.functions.zso(form, 'layout_column_id', true); 

	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	var queueSortStruct = StructNew(); 
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	queueSortStruct.tableName = "layout_column_x_widget_instance";
	queueSortStruct.datasource="#request.zos.zcoreDatasource#";
	queueSortStruct.sortFieldName = "layout_column_x_widget_instance_sort";
	queueSortStruct.primaryKeyName = "layout_column_x_widget_instance_id";
	queueSortStruct.where="site_id = '#request.zos.globals.id#' and 
	widget_id='#application.zcore.functions.zescape(form.widget_id)#' and 
	layout_column_id = '#application.zcore.functions.zEscape(form.layout_column_id)#' and  
	layout_column_x_widget_instance_deleted='0' ";
	queueSortStruct.ajaxURL="/z/admin/landing-page-widget/index?widget_id=#form.widget_id#&layout_column_id=#form.layout_column_id#&layout_page_id=#form.layout_page_id#";
	queueSortStruct.ajaxTableId="sortRowTable";
	variables.queueSortCom.init(queueSortStruct);
	variables.queueSortCom.returnJson();
	</cfscript>
</cffunction>




<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	//application.zcore.functions.zSetPageHelpId("5.4");
  
	db.sql="select * from #db.table("landing_page", request.zos.zcoreDatasource)# 
	WHERE 
	landing_page_id=#db.param(form.landing_page_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	landing_page_deleted = #db.param(0)#  ";
	qLanding=db.execute("qLanding");  

	form.section_id=qLanding.section_id;

	db.sql="select * from #db.table("section", request.zos.zcoreDatasource)# 
	WHERE 
	section_id=#db.param(form.section_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)#  ";
	qSection=db.execute("qSection");  

	form.layout_page_id=qLanding.layout_page_id;

	db.sql="select * from #db.table("layout_page", request.zos.zcoreDatasource)# 
	WHERE 
	layout_page_id=#db.param(form.layout_page_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_page_deleted = #db.param(0)# ";
	qPage=db.execute("qPage");  
	db.sql="select * from #db.table("layout_column", request.zos.zcoreDatasource)# 
	WHERE 
	layout_page_id=#db.param(form.layout_page_id)# and 
	layout_column_id=#db.param(form.layout_column_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_column_deleted = #db.param(0)#   ";
	qColumn=db.execute("qColumn");  
	db.sql="select * from #db.table("layout_row", request.zos.zcoreDatasource)# 
	WHERE 
	layout_page_id=#db.param(form.layout_page_id)# and 
	layout_row_id=#db.param(qColumn.layout_row_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_row_deleted = #db.param(0)#  ";
	qRow=db.execute("qRow");  
	db.sql="select * from #db.table("layout_column_x_widget", request.zos.zcoreDatasource)# 
	WHERE 
	layout_column_id=#db.param(form.layout_column_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_column_x_widget_deleted = #db.param(0)#  
	ORDER BY layout_column_x_widget_sort ASC ";
	qLayout=db.execute("qLayout");  
	application.zcore.functions.zStatusHandler(request.zsid); 
	echo('
	<a href="/z/section/admin/section-admin/index">Sections</a> / 
		<a href="/z/admin/landing-page/index?section_id=#form.section_id#">#qLanding.landing_page_meta_title#</a> /   
		<a href="/z/admin/landing-page-row/index?section_id=#form.section_id#&landing_page_id=#form.landing_page_id#&layout_row_id=#form.layout_row_id#">Row #qRow.layout_row_sort#</a> /
		<a href="/z/admin/landing-page-column/index?section_id=#form.section_id#&landing_page_id=#form.landing_page_id#&layout_row_id=#form.layout_row_id#&layout_column_id=#form.layout_column_id#">Column #qColumn.layout_column_sort#</a> / </p>'); 
	</cfscript>
	<h2>Manage Widgets for Custom Layout Page Column</h2>
	<!--- <p><a href="/z/admin/layout-page/index?layout_page_id=#qPage.layout_page_id#">#qPage.layout_page_name#</a> / 
	<a href="/z/admin/layout-row/index?layout_row_id=#qRow.layout_row_id#&amp;layout_page_id=#qPage.layout_page_id#">Row ###qRow.layout_row_sort# (ID###qRow.layout_row_id#)</a> /
<a href="/z/admin/layout-column/index?layout_column_id=#form.layout_column_id#&amp;layout_row_id=#qRow.layout_row_id#&amp;layout_page_id=#qPage.layout_page_id#">Column ###qColumn.layout_column_sort# (ID###qColumn.layout_column_id#)</a> /</h2>  --->

	<cfif qLayout.recordcount EQ 0>
		<p>No widgets have been added to this column.</p>
	<cfelse>
		<table class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Widget Name</th>   
				<th>Preview</th>    
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfscript>
				for(row in qLayout){ 
					echo('<tr  ');
					if(qLayout.currentRow MOD 2 EQ 0){
						echo('class="row2"');
					}else{
						echo('class="row1"');
					}
					echo('>');
					getLayoutRowHTML(row); 
					echo('</tr>');
				}
				</cfscript> 
			</tbody>
		</table>
	</cfif>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript> 
	db=request.zos.queryObject; 
	initInstance(); 

	form.widget_id=application.zcore.functions.zso(form, 'widget_id');
	form.layout_column_id=application.zcore.functions.zso(form, 'layout_column_id');
	layoutWidgetCom=createObject("component", "layout-widget");

	rs=layoutWidgetCom.getWidgetCFC(form.widget_id);
	if(not rs.success){
		application.zcore.status.setStatus(request.zsid, "Invalid widget id", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	widgetCom=rs.cfc;
	comPath=rs.comPath; 
	configStruct=widgetCom.getConfig(); 


	db.sql="select * from #db.table("landing_page", request.zos.zcoreDatasource)# 
	WHERE 
	landing_page_id=#db.param(form.landing_page_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	landing_page_deleted = #db.param(0)#  ";
	qLanding=db.execute("qLanding");  

	form.section_id=qLanding.section_id;

	db.sql="select * from #db.table("section", request.zos.zcoreDatasource)# 
	WHERE 
	section_id=#db.param(form.section_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	section_deleted = #db.param(0)#  ";
	qSection=db.execute("qSection");  

	form.layout_page_id=qLanding.layout_page_id;
  
	db.sql="select * from #db.table("layout_page", request.zos.zcoreDatasource)# 
	WHERE 
	layout_page_id=#db.param(form.layout_page_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_page_deleted = #db.param(0)# ";
	qPage=db.execute("qPage");  
	db.sql="select * from #db.table("layout_column", request.zos.zcoreDatasource)# 
	WHERE 
	layout_page_id=#db.param(form.layout_page_id)# and 
	layout_row_id=#db.param(form.layout_row_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_column_deleted = #db.param(0)#  
	ORDER BY layout_column_sort ASC ";
	qColumn=db.execute("qColumn");  

	form.layout_row_id=qColumn.layout_row_id;
	form.layout_column_id=qColumn.layout_column_id;
	db.sql="select * from #db.table("layout_row", request.zos.zcoreDatasource)# 
	WHERE 
	layout_page_id=#db.param(form.layout_page_id)# and 
	layout_row_id=#db.param(form.layout_row_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	layout_row_deleted = #db.param(0)#  ";
	qRow=db.execute("qRow");  

	// TODO: show breadcrumb for the layout column instead of this  
	echo('<p> 
		<a href="/z/section/admin/section-admin/index">Sections</a> / 
		<a href="/z/admin/landing-page/index?section_id=#form.section_id#">#qLanding.landing_page_meta_title#</a> /   
		<a href="/z/admin/landing-page-row/index?section_id=#form.section_id#&landing_page_id=#form.landing_page_id#&layout_row_id=#form.layout_row_id#">Row #qRow.layout_row_sort#</a> /
		<a href="/z/admin/landing-page-column/index?section_id=#form.section_id#&landing_page_id=#form.landing_page_id#&layout_row_id=#form.layout_row_id#&layout_column_id=#form.layout_column_id#">Column #qColumn.layout_column_sort#</a> /
		<a href="/z/admin/landing-page-widget/edit?section_id=#form.section_id#&landing_page_id=#form.landing_page_id#&layout_row_id=#form.layout_row_id#&layout_column_id=#form.layout_column_id#">Widget Instances</a> /
		</p>');
	echo('<h2>Manage Layout Page Column Widget Instances Of "#configStruct.name#"</h2>');

	ts=structnew();
	ts.widget_instance_id_field="c.widget_instance_id"; 
	ts.count=1;
	rs=layoutWidgetCom.getWidgetInstanceSQL(ts);
	db.sql="select c.*
	#db.trustedsql(rs.select)# from 
	#db.table("layout_column_x_widget_instance", request.zos.zcoreDatasource)# c
	#db.trustedsql(rs.leftJoin)# 
	WHERE  
	layout_column_x_widget_instance_deleted=#db.param(0)# and 
	c.site_id = #db.param(request.zos.globals.id)# 
	GROUP BY c.layout_column_x_widget_instance_id 
	ORDER BY layout_column_x_widget_instance_sort ASC ";
	qWidget=db.execute("qWidget");

	application.zcore.functions.zStatusHandler(request.zsid);

	echo('<p><a href="/z/admin/landing-page-widget/addWidgetInstanceLayout?layout_column_x_widget_id=#form.layout_column_x_widget_id#&amp;landing_page_id=#form.landing_page_id#&amp;widget_id=#form.widget_id#&amp;layout_column_id=#form.layout_column_id#&amp;layout_row_id=#form.layout_row_id#">Add Widget Instance</a></p>');
	echo('<table id="sortRowTable" class="table-list">
		<thead>
		<tr>
			<th>ID</th>
			<th>Name</th>
			<th>Sort</th>
			<th>Admin</th>
		</tr>
		</thead>
		<tbody>');
	for(row in qWidget){
		echo('<tr #variables.queueSortCom.getRowHTML(row.widget_instance_id)#>
			<td>#row.layout_column_x_widget_instance_id#</td>
			<td>#row.widget_instance_name#</td>
			<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(row.layout_column_x_widget_instance_id)#</td>
			<td><a href="/z/admin/landing-page-widget/editWidgetInstanceData?layout_row_id=#form.layout_row_id#&amp;layout_column_id=#row.layout_column_id#&layout_column_x_widget_instance_id=#row.layout_column_x_widget_instance_id#&amp;landing_page_id=#form.landing_page_id#&amp;widget_id=#row.widget_id#&amp;layout_column_x_widget_id=#row.layout_column_x_widget_id#&amp;widget_instance_id=#row.widget_instance_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit Data</a> | 
			<a href="/z/admin/landing-page-widget/editWidgetInstanceLayout?layout_row_id=#form.layout_row_id#&amp;layout_column_id=#row.layout_column_id#&layout_column_x_widget_instance_id=#row.layout_column_x_widget_instance_id#&amp;landing_page_id=#form.landing_page_id#&amp;widget_id=#row.widget_id#&amp;layout_column_x_widget_id=#row.layout_column_x_widget_id#&amp;widget_instance_id=#row.widget_instance_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit Layout</a> | 
			<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/admin/landing-page-widget/deleteLayoutColumnWidgetInstance?layout_column_id=#row.layout_column_id#&amp;widget_id=#row.widget_id#&amp;layout_column_x_widget_instance_id=#row.layout_column_x_widget_instance_id#&amp;widget_instance_id=#row.widget_instance_id#''); return false;">Delete</a></td>
		</tr>');
	}
	echo('</tbody></table>');
	if(qWidget.recordcount EQ 0){
		echo('<p>No instances found.</p>');
	}
	</cfscript>
</cffunction>
	 
<cffunction name="getReturnLayoutRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject; 
	init();
	var db=request.zos.queryObject; 
	form.layout_column_x_widget_id=application.zcore.functions.zso(form, 'layout_column_x_widget_id');
	db.sql="SELECT * FROM #db.table("layout_column_x_widget", request.zos.zcoreDatasource)# 
	WHERE site_id =#db.param(request.zos.globals.id)# and  
	layout_column_x_widget_deleted = #db.param(0)# and 
	layout_column_id=#db.param(form.layout_column_id)# and 
	layout_column_x_widget_id=#db.param(form.layout_column_x_widget_id)#";
	qLayout=db.execute("qLayout"); 
	 
	savecontent variable="rowOut"{
		for(row in qLayout){ 
			getLayoutRowHTML(row);
		}
	}

	echo('done.<script>
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>


<cffunction name="getLayoutRowHTML" localmode="modern" access="public" roles="member">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;
	echo('<td>#row.layout_column_x_widget_id#</td>  
	<td>');
	echo('Widget Name');
	echo('</td> 
	<td>Preview Not Implemented</td>  
	<td>
	<a href="/z/admin/landing-page-widget/index?widget_id=#row.widget_id#&amp;layout_row_id=#form.layout_row_id#&amp;landing_page_id=#form.landing_page_id#&amp;layout_column_x_widget_id=#row.layout_column_x_widget_id#&amp;layout_column_id=#row.layout_column_id#">Manage Instances</a> 
	</td>');
	</cfscript>
</cffunction>
 

<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>

	form.layout_page_id=application.zcore.functions.zso(form, 'layout_page_id', true);
	form.layout_column_id=application.zcore.functions.zso(form, 'layout_column_id', true); 

	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	 
	</cfscript>
</cffunction> 
 
	
</cfoutput>
</cfcomponent>