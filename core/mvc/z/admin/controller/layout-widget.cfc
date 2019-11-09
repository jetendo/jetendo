<cfcomponent extends="zcorerootmapping.com.zos.controller"> 
<cfoutput>
<!--- 
/z/admin/layout-widget/index
/z/admin/layout-widget/addWidgetInstanceLayout?widget_id=1&widget_instance_id=
/z/admin/layout-widget/loadWidgets 
/z/admin/layout-widget/listWidgetInstances?widget_id=1
 --->
<!--- <cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	widgetCom=createobject("component", "zcorerootmapping.com.widget.widget-example");

	widgetCom.baseUpgrade();

	ds={
		widget_instance_id:1,
		layoutFields:{
			"Font Scale":1,
			"Container Padding":1,
			"Left Column Size":0.4,
			"Column Gap":20
		}
	};
	widgetCom.init(ds); 


	dataFields={
		"Heading":"Heading",
		"Body Text":"Body Text",
		"Image":"/z/a/images/broker_reciprocity.jpg"
	};
	widgetCom.render([dataFields]);

	ds={
		widget_instance_id:2,
		layoutFields:{
			"Font Scale":.5,
			"Container Padding":.5,
			"Left Column Size":0.6,
			"Column Gap":100
		}
	};
	widgetCom.init(ds); 

	dataFields={
		"Heading":"Example 2",
		"Body Text":"Example Text 2",
		"Image":"/z/a/images/redarrow.jpg"
	};
	widgetCom.render([dataFields]);


	</cfscript>
</cffunction> --->



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


<cffunction name="addWidgetLayout" localmode="modern" access="remote" roles="member">
	<cfscript> 
	displayWidgetForm("layout");
	</cfscript>
</cffunction>

<cffunction name="editWidgetLayout" localmode="modern" access="remote" roles="member">
	<cfscript> 
	displayWidgetForm("layout");
	</cfscript>
</cffunction>

<cffunction name="addWidgetData" localmode="modern" access="remote" roles="member">
	<cfscript> 
	displayWidgetForm("data");
	</cfscript>
</cffunction>
<cffunction name="editWidgetData" localmode="modern" access="remote" roles="member">
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
	
<cffunction name="validateWidgetConfig" localmode="modern" access="public">
	<cfargument name="comPath" type="string" required="yes">
	<cfargument name="configStruct" type="struct" required="yes">
	<cfscript> 
	comPath=arguments.comPath;
	configStruct=arguments.configStruct;
	typeStruct={}; 
	typeCFCStruct=application.zcore.siteOptionCom.getTypeCFCStruct();
	for(i in typeCFCStruct){ 
		typeCFC=application.zcore.siteOptionCom.getTypeCFC(i);
		options=typeCFC.getOptionFieldStruct();
		typeStruct[typeCFCStruct[i].getTypeName()]={id:i, typeCFC: typeCFC, options:options };		
	}

	//writedump(structkeyarray(typeStruct));abort;
	fail=false;
	arrValidate=["layoutFields", "dataFields"];
	for(n=1;n<=arraylen(arrValidate);n++){
		key=arrValidate[n];
		for(i3=1;i3<=arraylen(configStruct[key]);i3++){ 
			field=configStruct[key][i3];
			if(not structkeyexists(field, 'label')){
				application.zcore.status.setStatus(request.zsid, "#key# | field ###i# is missing a label key in #comPath# -> getConfig().", form, true); 
				fail=true;
				continue;
			}
			if(not structkeyexists(field, 'previewValue')){
				application.zcore.status.setStatus(request.zsid, "#key# | field ###i# is missing a previewValue key in #comPath# -> getConfig().", form, true); 
				fail=true;
				continue;
			}
			if(not structkeyexists(typeStruct, application.zcore.functions.zso(field, 'type'))){
				application.zcore.status.setStatus(request.zsid, "#key# | """&field.label&""" with type: ""#field.type#"" in #comPath# -> getConfig() is not a valid optionType name.", form, true); 
				fail=true;
				continue;
			}
			typeStruct2=typeStruct[field.type]; 
			for(i2 in typeStruct2.options){
				if(not structkeyexists(field.options, i2)){
					application.zcore.status.setStatus(request.zsid, "#key# | The options for field: """&field.label&""" in #comPath# -> getConfig() is missing this option: #i2#.", form, true); 
					fail=true;
					continue;
				}
			}
			if(fail){
				continue;
			}
			try{
				rs=typeStruct2.typeCFC.onUpdate(field.options);
			}catch(Any e){ 
				application.zcore.status.setStatus(request.zsid, "#key# | """&field.label&""" with type: ""#field.type#"" in #comPath# -> onUpdate() failed with this error:<br />"&e.message, form, true); 
				continue;
			}
			if(not rs.success){
				fail=true;
				continue;
			}
			field.value=""; 
			field.options=rs.optionStruct;
			field.typeId=typeStruct2.id;
			defaultStruct={
				readonly:0,
				smallWidth:0,
				hideLabel:0,
				required:0,
				defaultValue:''
			};
			structappend(field, defaultStruct, false);
			field.site_option_id=field.id;


		}
	}
	if(fail){
		arrError=application.zcore.status.getErrors(request.zsid);
		throw(arrayToList(arrError, "<hr />"));
	}

	</cfscript>
</cffunction>
 
 
<cffunction name="getWidgetCFC" localmode="modern" access="public">
	<cfargument name="widget_id" type="string" required="yes">
	<cfscript> 
	if(not structkeyexists(application.zcore, 'widgetIndexStruct')){
		indexCom=createObject("component", "zcorerootmapping.com.widget.widget-index");
		indexCom.loadIndex();
	} 
	if(structkeyexists(application.zcore.widgetIndexStruct, arguments.widget_id)){ 
		return {success:true, comPath: application.zcore.widgetIndexStruct[arguments.widget_id], cfc:createObject("component", application.zcore.widgetIndexStruct[arguments.widget_id])};
	}else{
		return {success:false, errorMessage:"Widget doesn't exist."};
	}
	</cfscript>
</cffunction>

<cffunction name="displayWidgetForm" localmode="modern" access="public">
	<cfargument name="type" type="string" required="yes" hint="layout or data are valid values"> 
	<cfscript>
	form.widget_instance_id=application.zcore.functions.zso(form, 'widget_instance_id');
	form.widget_id=application.zcore.functions.zso(form, 'widget_id');

	form.modalpopforced=application.zcore.functions.zso(form, 'modalpopforced', true);
	methodbackup=form.method;

	rs=getWidgetCFC(form.widget_id);
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

	if(methodbackup EQ "editWidgetInstanceLayout" or methodbackup EQ "editWidgetInstanceData"){
		db.sql="select * from #db.table("widget_instance", request.zos.zcoreDatasource)# WHERE 
		site_id = #db.param(request.zos.globals.id)# and 
		widget_instance_deleted=#db.param(0)# and 
		widget_id =#db.param(form.widget_id)# and 
		widget_instance_id=#db.param(form.widget_instance_id)#";
		qWidget=db.execute("qWidget");
		if(qWidget.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid widget instance id", form, true);
			application.zcore.functions.zRedirect("/z/admin/layout-widget?widget_id=#form.widget_id#&zsid=#request.zsid#");
		}
		structappend(form, qWidget);
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
	application.zcore.functions.zStatusHandler(request.zsid, true);
	currentRowIndex=0;
	optionStruct={};
	dataStruct={};
	labelStruct={};
	posted=false;

	if(form.modalpopforced EQ 1){
		application.zcore.skin.includeCSS("/z/a/stylesheets/style.css");
		application.zcore.functions.zSetModalWindow();
	}


	echo('<form class="zFormCheckDirty" id="siteOptionGroupForm" action="'); 
	echo('/z/admin/layout-widget/');
	if(methodbackup EQ "addWidgetInstanceLayout"){
		echo('insertWidgetInstanceLayout');
	}else if(methodbackup EQ "editWidgetInstanceLayout"){
		echo('updateWidgetInstanceLayout');
	}else if(methodbackup EQ "addWidgetInstanceData"){
		echo('insertWidgetInstanceData');
	}else if(methodbackup EQ "editWidgetInstanceData"){
		echo('updateWidgetInstanceData');
	}else if(methodbackup EQ "editWidgetData"){
		echo('updateWidgetData');
	}else if(methodbackup EQ "editWidgetLayout"){
		echo('updateWidgetLayout');
	} 
	echo('" method="post" enctype="multipart/form-data" >');
	</cfscript>
	<input type="hidden" name="widget_instance_standalone" value="#application.zcore.functions.zso(form, 'widget_instance_standalone', true, 0)#">
	<input type="hidden" name="widget_id" value="#htmleditformat(form.widget_id)#" />
	<input type="hidden" name="widget_instance_id" value="#htmleditformat(form.widget_instance_id)#" /> 
	<table style="border-spacing:0px;" class="table-list">
 
		<tr><td>&nbsp;</td><td>
		<button type="submit" name="submitForm">Save</button>
			&nbsp;
			<cfif form.modalpopforced EQ 1>
				<button type="button" name="cancel" onclick="window.parent.zCloseModal();">Cancel</button>
			<cfelse>
				<cfscript>
				cancelLink="/z/admin/layout-widget/listWidgetInstances?widget_id=#form.widget_id#";
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
	validateWidgetConfig(comPath, configStruct);
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
				<th>&nbsp;</th>
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

<cffunction name="deleteWidgetInstance" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	form.returnJson=1;
	db.sql="select * FROM #db.table("widget_instance", request.zos.zcoreDatasource)#
	WHERE widget_instance_deleted=#db.param(0)# and 
	widget_instance_id=#db.param(form.widget_instance_id)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	qI=db.execute("qI");
	if(qI.recordcount EQ 0){ 
		application.zcore.functions.zReturnJson({success:false, errorMessage:'Widget instance no longer exists.'}); 
	}
	db.sql="delete FROM #db.table("widget_instance", request.zos.zcoreDatasource)#
	WHERE widget_instance_deleted=#db.param(0)# and 
	widget_instance_id=#db.param(form.widget_instance_id)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	db.execute("qDelete");

	// TODO: need to delete files/images/slideshows too
  
	application.zcore.functions.zReturnJson({success:true}); 
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

<!--- 
<cffunction name="updateWidgetData" localmode="modern" access="remote" roles="member">
	<cfscript>
	saveWidgetInstance();
	</cfscript>
</cffunction> --->

<cffunction name="updateWidgetInstanceData" localmode="modern" access="remote" roles="member">
	<cfscript>
	saveWidgetInstance();
	</cfscript>
</cffunction>

<cffunction name="saveWidgetInstance" localmode="modern" access="public">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	db=request.zos.queryObject; 
	//writedump(form); 

	// get widget cfc path using widget_id
	if(not structkeyexists(application.zcore.widgetIndexStruct, form.widget_id)){
		application.zcore.status.setStatus(request.zsid, "Invalid widget id", form, true);
		application.zcore.functions.zRedirect("/z/admin/widget/index?zsid=#request.zsid#");
	}

	widgetCom=createobject("component", application.zcore.widgetIndexStruct[form.widget_id]);

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
	t9={
		layoutFields:{},
		dataFields:{}
	};
	rs=getWidgetCFC(form.widget_id);
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
	validateWidgetConfig(comPath, configStruct);
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
			site_x_option_group_original:"",
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
	}
	if(fail){
		application.zcore.functions.zRedirect("/z/admin/layout-widget/#failMethod#?widget_id=#form.widget_id#&widget_instance_id=#form.widget_instance_id#&zsid=#request.zsid#");
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
		application.zcore.functions.zRedirect("/z/admin/layout-widget/#failMethod#?widget_id=#form.widget_id#&widget_instance_id=#form.widget_instance_id#&zsid=#request.zsid#");
	}
	ts.struct.widget_instance_standalone=form.widget_instance_standalone;

	ts.struct.widget_instance_name=form.widget_instance_name;
	ts.struct.widget_instance_deleted=0;
	ts.struct.widget_instance_json_data=serializeJson(t9);
	ts.struct.widget_instance_updated_datetime=request.zos.mysqlnow;
	ts.struct.site_id=request.zos.globals.id;
	ts.struct.widget_id=form.widget_id;
	ts.struct.widget_instance_version=widgetCom.getWidgetVersion();

	if(form.method EQ "insertWidgetInstanceLayout" or form.method EQ "insertWidgetInstanceData"){
		form.widget_instance_id=application.zcore.functions.zInsert(ts);
		if(form.widget_instance_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save widget instance", form, true);
			application.zcore.functions.zRedirect("/z/admin/layout-widget/#failMethod#?widget_id=#form.widget_id#&widget_instance_id=#form.widget_instance_id#&zsid=#request.zsid#");
		}
	}else{
		ts.struct.widget_instance_id=form.widget_instance_id;
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Failed to save widget instance", form, true);
			application.zcore.functions.zRedirect("/z/admin/layout-widget/#failMethod#?widget_id=#form.widget_id#&widget_instance_id=#form.widget_instance_id#&zsid=#request.zsid#");
		}
	}

	application.zcore.status.setStatus(request.zsid, "Saved");
	if(ts.struct.widget_instance_standalone EQ 1){
		application.zcore.functions.zRedirect("/z/admin/widget/listWidgetInstances?widget_id=#form.widget_id#&zsid=#request.zsid#");
	}else{
		application.zcore.functions.zRedirect("/z/admin/layout-widget/listWidgetInstances?widget_id=#form.widget_id#&zsid=#request.zsid#");
	}
	</cfscript>
</cffunction>

<cffunction name="initInstance" localmode="modern" access="private" roles="member">
	<cfscript>
	if(form.method EQ ""){
		form.editType="";
	}

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
	layout_column_id = '#application.zcore.functions.zEscape(form.layout_column_id)#' and  
	layout_column_x_widget_instance_deleted='0' ";
	queueSortStruct.ajaxURL="/z/admin/layout-widget/listWidgetInstances?widget_id=#form.widget_id#&layout_column_id=#form.layout_column_id#&layout_page_id=#form.layout_page_id#";
	queueSortStruct.ajaxTableId="sortRowTable";
	variables.queueSortCom.init(queueSortStruct);
	variables.queueSortCom.returnJson();
	</cfscript>
</cffunction>



<!--- 
// you must have a group by in your query or it may miss rows
ts=structnew();
ts.widget_instance_id_field="layout_column_x_widget.widget_instance_id"; 
ts.count=1;
getWidgetInstanceSQL(ts);
 --->
<cffunction name="getWidgetInstanceSQL" localmode="modern" returntype="any" output="yes">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	var qImages=0;
	var arrOutput=arraynew(1);
	var ts=structnew();
	var rs=structnew();
	var i=0;
	var db=request.zos.queryObject;
	ts.widget_instance_id_field="";
	ts.count=1;
	structappend(arguments.ss,ts,false);
	if(not structkeyexists(request.zos, 'getWidgetInstanceSQLIndex')){
		request.zos.getWidgetInstanceSQLIndex=0;
	}
	request.zos.getWidgetInstanceSQLIndex++;
	i=request.zos.getWidgetInstanceSQLIndex;
	if(arguments.ss.widget_instance_id_field EQ ""){
		application.zcore.template.fail("Error: getWidgetInstanceSQL() failed because arguments.ss.widget_instance_id_field is required.");	
	}
	rs.leftJoin="LEFT JOIN "&db.table("widget_instance", request.zos.zcoreDatasource)&" widget_instance#i# ON 
	"&arguments.ss.widget_instance_id_field&" = widget_instance#i#.widget_instance_id and ";
	/*if(arguments.ss.count){
		rs.leftJoin&=" widget_instance#i#.image_sort <= '#application.zcore.functions.zescape(arguments.ss.count)#' and ";
	}*/
	rs.leftJoin&=" widget_instance#i#.site_id = '#application.zcore.functions.zescape(request.zos.globals.id)#' and 
	widget_instance#i#.widget_instance_deleted = 0 ";
	rs.select=", widget_instance#i#.*";
	/*
	rs.select=", cast(GROUP_CONCAT(widget_instance#i#.image_id ORDER BY image#i#.image_sort SEPARATOR '\t') as char) imageIdList, 
	cast(GROUP_CONCAT(image#i#.image_caption ORDER BY image#i#.image_sort SEPARATOR '\t') as char) imageCaptionList, 
	cast(GROUP_CONCAT(image#i#.image_file ORDER BY image#i#.image_sort SEPARATOR '\t') as char) imageFileList, 
	cast(GROUP_CONCAT(image#i#.image_approved ORDER BY image#i#.image_sort SEPARATOR '\t') as char) imageApprovedList, 
	cast(GROUP_CONCAT(image#i#.image_updated_datetime ORDER BY image#i#.image_sort SEPARATOR '\t') as char) imageUpdatedDateList";*/
	return rs;
	</cfscript>
</cffunction>

<cffunction name="listWidgetInstances" localmode="modern" access="remote" roles="member">
	<cfscript> 
	db=request.zos.queryObject; 
	initInstance();
	// layout_column_x_widget_id
	// layout_column_x_widget_instance_id
	// landing_page_x_widget_instance_id
	// landing_page_x_widget_id

	form.widget_id=application.zcore.functions.zso(form, 'widget_id');
	form.layout_column_id=application.zcore.functions.zso(form, 'layout_column_id');

	rs=getWidgetCFC(form.widget_id);
	if(not rs.success){
		application.zcore.status.setStatus(request.zsid, "Invalid widget id", form, true);
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	widgetCom=rs.cfc;
	comPath=rs.comPath; 
	configStruct=widgetCom.getConfig(); 

	// TODO: show breadcrumb for the layout column instead of this
	echo('<p><a href="/z/admin/widget/index">Manage Widgets</a> /</p>'); 
	echo('<h2>Manage Layout Page Column Widget Instances Of "#configStruct.name#"</h2>'); 

	ts=structnew();
	ts.widget_instance_id_field="c.widget_instance_id"; 
	ts.count=1;
	rs=getWidgetInstanceSQL(ts);
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

	echo('<p><a href="/z/admin/layout-widget/addWidgetInstanceLayout?widget_id=#form.widget_id#&layout_column_id=#form.layout_column_id#">Add Widget Instance</a></p>');
	echo('<table class="table-list">
		<tr>
			<th>ID</th>
			<th>Name</th>
			<th>Sort</th>
			<th>Admin</th>
		</tr>');
	for(row in qWidget){
		echo('<tr #variables.queueSortCom.getRowHTML(row.layout_column_x_widget_instance_id)#>
			<td>#row.widget_instance_id#</td>
			<td>#row.widget_instance_name#</td>
			<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(row.layout_column_x_widget_id)#</td>
			<td><a href="/z/admin/layout-widget/editWidgetInstanceData?widget_id=#row.widget_id#&amp;layout_column_x_widget_id=#row.layout_column_x_widget_id#&amp;widget_instance_id=#row.widget_instance_id#">Edit Data</a> | 
			<a href="/z/admin/layout-widget/editWidgetInstanceLayout?widget_id=#row.widget_id#&amp;layout_column_x_widget_id=#row.layout_column_x_widget_id#&amp;widget_instance_id=#row.widget_instance_id#">Edit Layout</a> | 
			<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/admin/layout-widget/deleteWidgetInstance?layout_column_x_widget_id=#row.layout_column_x_widget_id#&amp;widget_id=#row.widget_id#&amp;widget_instance_id=#row.widget_instance_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a></td>
		</tr>');
	}
	echo('</table>');
	if(qWidget.recordcount EQ 0){
		echo('<p>No instances found.</p>');
	}
	</cfscript>
</cffunction>
	
<cffunction name="compileAllWidgets" localmode="modern" access="remote" roles="member">
	<cfscript>
	if(request.zos.isTestServer){
		throw("This should only run on a production server");
	}
	if(not request.zos.isDeveloper and not request.zos.isServer){
		application.zcore.functions.z404("Only developer/server can access this url.");
	}
	// force compile all widget instances (has to be done on live server only because the data is site specific and editable by user)
	</cfscript>
</cffunction>



<cffunction name="loadWidgets" localmode="modern" access="remote" roles="member">
	<cfscript>
	// this function not in use yet.
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	// load all widgets in the widgets directory
	// getWidgetId() to get their id.

	ts={};
	indexCom=createObject("component", "zcorerootmapping.com.widget.widget-index");
	indexCom.loadIndex();

	for(id in application.zcore.widgetIndexStruct){ 
		comPath=application.zcore.widgetIndexStruct[id];
		widgetCom=createObject("component", comPath);
		widgetCom.init({});
		configStruct=widgetCom.getBaseConfig();
		validateWidgetConfig(comPath, configStruct);
		ts[configStruct.id]=configStruct;
	}

	/*
	maybe use this for site specific widgets someday
	arrWidget=directoryList("#request.zos.installPath#core/com/widget/", true, 'path');
	for(i=1;i<=arrayLen(arrWidget);i++){
		comPath=arrWidget[i];
		if(right(comPath, 4) NEQ ".cfc" or right(comPath, 14) EQ "baseWidget.cfc"){
			continue;
		}
		comPath=replace(replace(comPath, '#request.zos.installPath#core/', 'zcorerootmapping/'), '/', '.', 'all');
		comPath=left(comPath, len(comPath)-4); 
		widgetCom=createObject("component", comPath); 
		widgetCom.init({});
		configStruct=widgetCom.getBaseConfig();
		validateWidgetConfig(comPath, configStruct);
		ts[configStruct.id]=configStruct;

		writedump(ts);abort;
	}
	*/
	application.zcore.widgetDataCache=ts;
	echo('done');
	</cfscript>
</cffunction>


<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	db=request.zos.queryObject;
	init();
	//application.zcore.functions.zSetPageHelpId("5.4");
  
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
	</cfscript>
	<h2>Manage Widgets for Custom Layout Page Column</h2>
	<p><a href="/z/admin/layout-page/index?layout_page_id=#qPage.layout_page_id#">#qPage.layout_page_name#</a> / 
	<a href="/z/admin/layout-row/index?layout_row_id=#qRow.layout_row_id#&amp;layout_page_id=#qPage.layout_page_id#">Row ###qRow.layout_row_sort# (ID###qRow.layout_row_id#)</a> /
<a href="/z/admin/layout-column/index?layout_column_id=#form.layout_column_id#&amp;layout_row_id=#qRow.layout_row_id#&amp;layout_page_id=#qPage.layout_page_id#">Column ###qColumn.layout_column_sort# (ID###qColumn.layout_column_id#)</a> /</h2>
	<p><a href="/z/admin/layout-widget/addWidget?layout_column_id=#form.layout_column_id#&amp;layout_page_id=#form.layout_page_id#">Add Widget</a></p>

	<p>Someday this page should let the developer define the default layout and data options for this widget.</p>
	<cfif qLayout.recordcount EQ 0>
		<p>No widgets have been added to this column.</p>
	<cfelse>
		<table id="sortRowTable" class="table-list">
			<thead>
			<tr>
				<th>ID</th>
				<th>Widget Name</th>   
				<th>Preview</th>   
				<th>Sort</th>
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfscript>
				for(row in qLayout){ 
					echo('<tr #variables.queueSortCom.getRowHTML(row.layout_column_id)# ');
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


<cffunction name="getReturnLayoutRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript>
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
	<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(row.layout_column_x_widget_id)#</td>
	<td> 
	<a href="##" onclick="zDeleteTableRecordRow(this, ''/z/admin/layout-widget/deleteWidget?layout_column_x_widget_id=#row.layout_column_x_widget_id#&amp;layout_page_id=#form.layout_page_id#&amp;layout_column_id=#row.layout_column_id#&amp;returnJson=1&amp;confirm=1''); return false;">Delete</a></td>');
	/*<a href="/z/admin/layout-widget/editWidgetLayout?widget_id=#row.widget_id#&amp;layout_column_x_widget_id=#row.layout_column_x_widget_id#&amp;layout_column_id=#row.layout_column_id#&amp;modalpopforced=1" onclick="zTableRecordEdit(this);  return false;">Edit Layout</a> | 
	<a href="/z/admin/layout-widget/editWidgetData?widget_id=#row.widget_id#&amp;layout_column_x_widget_id=#row.layout_column_x_widget_id#&amp;layout_column_id=#row.layout_column_id#&amp;modalpopforced=1">Edit Data</a> | */
	</cfscript>
</cffunction>


<cffunction name="deleteWidget" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts",true);	
	init();
	db=request.zos.queryObject;
	form.layout_page_id=application.zcore.functions.zso(form, 'layout_page_id');
	form.layout_column_id=application.zcore.functions.zso(form, 'layout_column_id');
	form.widget_id=application.zcore.functions.zso(form, 'widget_id');
	form.layout_column_x_widget_id=application.zcore.functions.zso(form, 'layout_column_x_widget_id');
	db.sql="delete from #db.table("layout_column_x_widget")# where 
	layout_column_x_widget_id=#db.param(form.layout_column_x_widget_id)# and 
	layout_column_x_widget_deleted=#db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	db.execute("qdelete");
	variables.queueSortCom.sortAll();
	rs={success:true};
	application.zcore.functions.zReturnJson(rs);
	</cfscript>
</cffunction>


<cffunction name="addWidget" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	db=request.zos.queryObject;  
	form.layout_page_id=application.zcore.functions.zso(form, 'layout_page_id');
	form.layout_column_id=application.zcore.functions.zso(form, 'layout_column_id');
	ts={};
	indexCom=createObject("component", "zcorerootmapping.com.widget.widget-index");
	indexCom.loadIndex();

	for(id in application.zcore.widgetIndexStruct){ 
		comPath=application.zcore.widgetIndexStruct[id];
		widgetCom=createObject("component", comPath);
		widgetCom.init({});
		configStruct=widgetCom.getConfig();

		ts[id]={
			id:configStruct.id,
			name:configStruct.name,
			version:configStruct.version,
		}
	}
	arrKey=structsort(ts, "text", "asc", "name"); 
	echo('<h2>Add Widget to Custom Layout Page Column</h2>');
	echo('<p>Set the repeat limit to limit how many widget instances can be created.  Set to 0 to make it unlimited.</p>');
	echo('<p>Repeat Limit: <input type="number" id="repeatLimit" step="1" value="0"></p>');
	echo('<table class="table-list">
		<tr>
			<th>ID</th> 
			<th>Category</th>
			<th>Name</th>
			<th>Version</th>
			<th>Admin</th>
		</tr>');
	for(i=1;i<=arraylen(arrKey);i++){
		row=ts[arrKey[i]];
		echo('<tr>
			<td>#row.id#</td>
			<td>Category</td>
			<td>#row.name#</td>
			<td>#row.version#</td>
			<td>
				<a href="##" onclick="window.location.href=''/z/admin/layout-widget/insertWidget?widget_id=#row.id#&amp;layout_page_id=#form.layout_page_id#&amp;layout_column_id=#form.layout_column_id#&amp;layout_column_x_widget_repeat_limit=''+document.getElementById(''repeatLimit'').value; return false;">Add</a> | 
				<a href="/z/admin/widget/previewWidget?widget_id=#row.id#" target="_blank">Preview</a>
			</td>
		</tr>');
	}
	echo('</table>');
	</cfscript>
</cffunction>


<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>

	form.layout_page_id=application.zcore.functions.zso(form, 'layout_page_id', true);
	form.layout_column_id=application.zcore.functions.zso(form, 'layout_column_id', true); 

	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts");	
	var queueSortStruct = StructNew(); 
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	queueSortStruct.tableName = "layout_column_x_widget";
	queueSortStruct.datasource="#request.zos.zcoreDatasource#";
	queueSortStruct.sortFieldName = "layout_column_x_widget_sort";
	queueSortStruct.primaryKeyName = "layout_column_x_widget_id";
	queueSortStruct.where="site_id = '#request.zos.globals.id#' and 
	layout_column_id = '#application.zcore.functions.zEscape(form.layout_column_id)#' and  
	layout_column_x_widget_deleted='0' ";
	queueSortStruct.ajaxURL="/z/admin/layout-widget/edit?layout_column_id=#form.layout_column_id#&layout_page_id=#form.layout_page_id#";
	queueSortStruct.ajaxTableId="sortRowTable";
	variables.queueSortCom.init(queueSortStruct);
	variables.queueSortCom.returnJson();
	</cfscript>
</cffunction>

<cffunction name="insertWidget" localmode="modern" access="remote" roles="member">
	<cfscript>
	application.zcore.adminSecurityFilter.requireFeatureAccess("Layouts", true);	
	init();
	form.widget_id=application.zcore.functions.zso(form, 'widget_id'); 
	ts={
		table:"layout_column_x_widget",
		datasource:request.zos.zcoreDatasource,
		struct:{
			widget_id:form.widget_id,
			layout_column_id:form.layout_column_id,
			layout_column_x_widget_uuid:createuuid(), 
			site_id:request.zos.globals.id,
			layout_column_x_widget_sort:0,
			layout_column_x_widget_repeat_limit:1,
			layout_column_x_widget_updated_datetime:request.zos.mysqlnow,
			layout_column_x_widget_deleted:0
		}
	}; 
	application.zcore.functions.zInsert(ts);

	variables.queueSortCom.sortAll();

	application.zcore.status.setStatus(request.zsid, "Widget added");
	application.zcore.functions.zRedirect("/z/admin/layout-widget/edit?layout_column_id=#form.layout_column_id#&layout_page_id=#form.layout_page_id#&zsid=#request.zsid#");
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>