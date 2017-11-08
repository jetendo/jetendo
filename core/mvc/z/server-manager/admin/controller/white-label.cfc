<cfcomponent>
<cfoutput>
<cffunction name="save" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	
	form.whitelabel_id=application.zcore.functions.zso(form, 'whitelabel_id',true);
	form.site_id=application.zcore.functions.zso(form, 'sid', true);
	form.user_id=application.zcore.functions.zso(form, 'uid', true);

	imagePath=application.zcore.functions.zvar('privateHomedir', form.site_id)&"zupload/whitelabel/";
	application.zcore.functions.zcreatedirectory(imagePath);

	arrList = application.zcore.functions.zUploadResizedImagesToDb("whitelabel_dashboard_header_image_960", imagePath, "960x300",'whitelabel', 'whitelabel_id', "whitelabel_dashboard_header_image_960_delete",request.zos.zcoreDatasource, '', form.site_id);
	if(isArray(arrList) and ArrayLen(arrList) NEQ 0){
		form.whitelabel_dashboard_header_image_960=arrList[1];
	}else{
		application.zcore.functions.zDeleteFile(form.whitelabel_dashboard_header_image_960);
		form.whitelabel_dashboard_header_image_960='';
	}

	arrList = application.zcore.functions.zUploadResizedImagesToDb("whitelabel_dashboard_header_image_640", imagePath, "640x300",'whitelabel', 'whitelabel_id', "whitelabel_dashboard_header_image_640_delete",request.zos.zcoreDatasource, '', form.site_id);
	if(isArray(arrList) and ArrayLen(arrList) NEQ 0){
		form.whitelabel_dashboard_header_image_640=arrList[1];
	}else{
		application.zcore.functions.zDeleteFile(form.whitelabel_dashboard_header_image_640);
		form.whitelabel_dashboard_header_image_640='';
	}

	arrList = application.zcore.functions.zUploadResizedImagesToDb("whitelabel_dashboard_header_image_320", imagePath, "320x300",'whitelabel', 'whitelabel_id', "whitelabel_dashboard_header_image_320_delete",request.zos.zcoreDatasource, '', form.site_id);
	if(isArray(arrList) and ArrayLen(arrList) NEQ 0){
		form.whitelabel_dashboard_header_image_320=arrList[1];
	}else{
		application.zcore.functions.zDeleteFile(form.whitelabel_dashboard_header_image_320);
		form.whitelabel_dashboard_header_image_320='';
	}


	arrList = application.zcore.functions.zUploadResizedImagesToDb("whitelabel_login_header_image_960", imagePath, "960x300",'whitelabel', 'whitelabel_id', "whitelabel_login_header_image_960_delete",request.zos.zcoreDatasource, '', form.site_id);
	if(isArray(arrList) and ArrayLen(arrList) NEQ 0){
		form.whitelabel_login_header_image_960=arrList[1];
	}else{
		application.zcore.functions.zDeleteFile(form.whitelabel_login_header_image_960);
		form.whitelabel_login_header_image_960='';
	}


	arrList = application.zcore.functions.zUploadResizedImagesToDb("whitelabel_login_header_image_640", imagePath, "640x300",'whitelabel', 'whitelabel_id', "whitelabel_login_header_image_640_delete",request.zos.zcoreDatasource, '', form.site_id);
	if(isArray(arrList) and ArrayLen(arrList) NEQ 0){
		form.whitelabel_login_header_image_640=arrList[1];
	}else{
		application.zcore.functions.zDeleteFile(form.whitelabel_login_header_image_640);
		form.whitelabel_login_header_image_640='';
	}

	arrList = application.zcore.functions.zUploadResizedImagesToDb("whitelabel_login_header_image_320", imagePath, "320x300",'whitelabel', 'whitelabel_id', "whitelabel_login_header_image_320_delete",request.zos.zcoreDatasource, '', form.site_id);
	if(isArray(arrList) and ArrayLen(arrList) NEQ 0){
		form.whitelabel_login_header_image_320=arrList[1];
	}else{
		application.zcore.functions.zDeleteFile(form.whitelabel_login_header_image_320);
		form.whitelabel_login_header_image_320='';
	}
 
	ts={
		table:"whitelabel",
		datasource:request.zos.zcoreDatasource,
		struct:form
	};
	if(form.whitelabel_id NEQ "0"){
		application.zcore.functions.zUpdate(ts);
	}else{
		application.zcore.functions.zInsert(ts);
	}
	clearMenuCache(form.site_id);

	application.zcore.status.setStatus(request.zsid, "Whitelabel settings saved");
	application.zcore.functions.zRedirect("/z/server-manager/admin/white-label/index?sid=#form.sid#&zsid=#request.zsid#");
	</cfscript> 
</cffunction>
	
<cffunction name="clearMenuCache" localmode="modern" access="remote" roles="serveradministrator">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	db=request.zos.queryObject;
	if(structkeyexists(application.siteStruct, arguments.site_id)){
		application.siteStruct[arguments.site_id].administratorTemplateMenuCache={};
	}
	db.sql="select site_id from #db.table("site", request.zos.zcoreDatasource)# WHERE 
	site_parent_id=#db.param(arguments.site_id)# and 
	site_id <> #db.param(-1)# and 
	site_deleted=#db.param(0)#";
	qSite=db.execute("qSite");
	for(row in qSite){
		if(structkeyexists(application.siteStruct, row.site_id)){
			application.siteStruct[row.site_id].administratorTemplateMenuCache={};
			structdelete(application.siteStruct[row.site_id], 'whiteLabelStruct');
		}
	}
	</cfscript>
</cffunction>
	

<cffunction name="delete" localmode="modern" access="remote" roles="serveradministrator">
	
	<cfscript>
	var db=request.zos.queryObject;
	form.whitelabel_id=application.zcore.functions.zso(form, 'whitelabel_id',true);
	form.site_id=application.zcore.functions.zso(form, 'sid', true);
	form.user_id=application.zcore.functions.zso(form, 'uid', true);
	db.sql="SELECT * FROM #request.zos.queryObject.table("whitelabel", request.zos.zcoreDatasource)# whitelabel 
	WHERE whitelabel_id = #db.param(form.whitelabel_id)# and 
	whitelabel_deleted=#db.param(0)# and  
	user_id = #db.param(form.user_id)# and
	site_id = #db.param(form.site_id)# ";
	qData=db.execute("qData");
	if(qData.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Record doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/white-label/index?sid=#form.site_id#&zsid=#request.zsid#");
	}
	if(structkeyexists(form, 'confirm')){
		imagePath=application.zcore.functions.zvar('privateHomedir', qData.site_id)&"/zupload/whitelabel/"; 
		if(qData.whitelabel_dashboard_header_image_320 NEQ ""){
			application.zcore.functions.zdeletefile(imagePath&qData.whitelabel_dashboard_header_image_320);
		}
		if(qData.whitelabel_dashboard_header_image_640 NEQ ""){
			application.zcore.functions.zdeletefile(imagePath&qData.whitelabel_dashboard_header_image_640);
		}
		if(qData.whitelabel_dashboard_header_image_960 NEQ ""){
			application.zcore.functions.zdeletefile(imagePath&qData.whitelabel_dashboard_header_image_960);
		}
		if(qData.whitelabel_login_header_image_320 NEQ ""){
			application.zcore.functions.zdeletefile(imagePath&qData.whitelabel_login_header_image_320);
		}
		if(qData.whitelabel_login_header_image_640 NEQ ""){
			application.zcore.functions.zdeletefile(imagePath&qData.whitelabel_login_header_image_640);
		}
		if(qData.whitelabel_login_header_image_960 NEQ ""){
			application.zcore.functions.zdeletefile(imagePath&qData.whitelabel_login_header_image_960);
		}
		application.zcore.functions.zDeleteRecord("whitelabel", "whitelabel_id,site_id,user_id", request.zos.zcoreDatasource);

		db.sql="SELECT * FROM #request.zos.queryObject.table("whitelabel_button", request.zos.zcoreDatasource)# whitelabel_button 
		WHERE whitelabel_id = #db.param(qData.whitelabel_id)# and 
		whitelabel_button_deleted=#db.param(0)# and  
		site_id = #db.param(qData.site_id)# ";
		qButton=db.execute("qButton");
		for(row in qButton){
			if(row.whitelabel_button_image128 NEQ ""){
				application.zcore.functions.zdeletefile(imagePath&row.whitelabel_button_image128);
			}
			if(row.whitelabel_button_image64 NEQ ""){
				application.zcore.functions.zdeletefile(imagePath&row.whitelabel_button_image64);
			}
			if(row.whitelabel_button_image32 NEQ ""){
				application.zcore.functions.zdeletefile(imagePath&row.whitelabel_button_image32);
			}
			form.whitelabel_button_id=row.whitelabel_button_id;
			application.zcore.functions.zDeleteRecord("whitelabel_button", "whitelabel_button_id,site_id", request.zos.zcoreDatasource);
		}
		clearMenuCache(form.site_id);

		application.zcore.status.setStatus(request.zsid, "Record deleted.");
		application.zcore.functions.zRedirect("/z/server-manager/admin/white-label/index?sid=#form.site_id#&zsid=#request.zsid#");
	}else{
		echo('<h2>Are you sure you want to delete this record?<br /><br />');
		if(qData.user_id EQ 0){
			echo('Site whitelabel settings<br />#application.zcore.functions.zvar('shortDomain', qData.site_id)#');
		}else{
			db.sql="select * from #db.table("user", request.zos.zcoreDatasource)# WHERE 
			site_id = #db.param(qData.site_id)# and 
			user_id = #db.param(qData.user_id)# and 
			user_deleted = #db.param(0)# ";
			qUser=db.execute("qUser");
			echo('User whitelabel settings<br />#qUser.user_first_name# #qUser.user_last_name# (#qUser.user_email#)');
		}
			echo('<br /><br />
			<a href="/z/server-manager/admin/white-label/delete?confirm=1&amp;whitelabel_id=#form.whitelabel_id#&amp;sid=#form.site_id#&amp;uid=#form.user_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/white-label/index?sid=#form.site_id#">No</a></h2>');
	}
	</cfscript>
	
</cffunction>

<cffunction name="deleteButton" localmode="modern" access="remote" roles="serveradministrator">
	
	<cfscript>
	var db=request.zos.queryObject;
	form.whitelabel_id=application.zcore.functions.zso(form, 'whitelabel_id',true);
	form.site_id=application.zcore.functions.zso(form, 'sid', true);
	form.user_id=application.zcore.functions.zso(form, 'uid', true);
	db.sql="SELECT * FROM #request.zos.queryObject.table("whitelabel_button", request.zos.zcoreDatasource)# whitelabel_button
	WHERE whitelabel_button_id = #db.param(form.whitelabel_id)# and 
	whitelabel_button_deleted=#db.param(0)# and  
	site_id = #db.param(form.site_id)# ";
	qData=db.execute("qData");
	if(qData.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Record doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/white-label/index?sid=#form.site_id#&zsid=#request.zsid#");
	}
	initSort();
	if(structkeyexists(form, 'confirm')){
		imagePath=application.zcore.functions.zvar('privateHomedir', qData.site_id)&"/zupload/whitelabel/"; 
		if(qData.whitelabel_button_image128 NEQ ""){
			application.zcore.functions.zdeletefile(imagePath&qData.whitelabel_button_image128);
		}
		if(qData.whitelabel_button_image64 NEQ ""){
			application.zcore.functions.zdeletefile(imagePath&qData.whitelabel_button_image64);
		}
		if(qData.whitelabel_button_image32 NEQ ""){
			application.zcore.functions.zdeletefile(imagePath&qData.whitelabel_button_image32);
		}
		application.zcore.functions.zDeleteRecord("whitelabel_button", "whitelabel_button_id,site_id", request.zos.zcoreDatasource);

		variables["queueSortCom"&qData.whitelabel_button_public].sortAll();
		clearMenuCache(form.site_id);

		application.zcore.status.setStatus(request.zsid, "Record deleted.");
		application.zcore.functions.zRedirect("/z/server-manager/admin/white-label/manageButtons?whitelabel_id=#form.whitelabel_id#&sid=#form.site_id#&zsid=#request.zsid#");
	}else{
		echo('<h2>Are you sure you want to delete this button?<br /><br />');
			echo(qData.whitelabel_button_label);
			echo('<br /><br />
			<a href="/z/server-manager/admin/white-label/deleteButton?confirm=1&amp;whitelabel_id=#form.whitelabel_id#&amp;sid=#form.site_id#&amp;whitelabel_button_id=#form.whitelabel_button_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/server-manager/admin/white-label/manageButtons?whitelabel_id=#form.whitelabel_id#&sid=#form.site_id#&zsid=#request.zsid#">No</a></h2>');
	}
	</cfscript>
</cffunction>
	
<cffunction name="insertButton" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	updateButton();
	</cfscript>
</cffunction>

<cffunction name="updateButton" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	form.site_id=form.sid;
	form.whitelabel_button_updated_datetime=request.zos.mysqlnow;
	initSort();

	imagePath=application.zcore.functions.zvar('privateHomedir', form.site_id)&"zupload/whitelabel/";
	application.zcore.functions.zcreatedirectory(imagePath); 
	arrList = application.zcore.functions.zUploadResizedImagesToDb("whitelabel_button_image128,whitelabel_button_image64,whitelabel_button_image32", imagePath, "128x128,64x64,32x32",'whitelabel_button', 'whitelabel_button_id', "whitelabel_button_image128_delete",request.zos.zcoreDatasource, '1,1,1', form.site_id);
	if(isArray(arrList) and ArrayLen(arrList) EQ 3){
		form.whitelabel_button_image128=arrList[1];
		form.whitelabel_button_image64=arrList[2];
		form.whitelabel_button_image32=arrList[3];
	}else{
		application.zcore.functions.zDeleteFile(form.whitelabel_button_image128);
		form.whitelabel_button_image128='';
		form.whitelabel_button_image64='';
		form.whitelabel_button_image32='';
	} 
	ts={
		table:"whitelabel_button",
		datasource:request.zos.zcoreDatasource,
		struct:form
	};
	if(form.method EQ "insertButton"){
		application.zcore.functions.zInsert(ts);
	}else{
		application.zcore.functions.zUpdate(ts);
	}
	variables["queueSortCom"&form.whitelabel_button_public].sortAll();
	clearMenuCache(form.site_id);
	application.zcore.status.setStatus(request.zsid, "Button saved");
	application.zcore.functions.zRedirect("/z/server-manager/admin/white-label/manageButtons?zsid=#request.zsid#&whitelabel_id=#form.whitelabel_id#&sid=#form.sid#");
	</cfscript>
</cffunction>



<cffunction name="addButton" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	editButton();
	</cfscript>
</cffunction>

<cffunction name="editButton" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	
	db=request.zos.queryObject;
	application.zcore.functions.zStatusHandler(request.zsid);
	form.whitelabel_button_id=application.zcore.functions.zso(form, 'whitelabel_button_id',true);
	form.whitelabel_id=application.zcore.functions.zso(form, 'whitelabel_id',true);
	form.sid=application.zcore.functions.zso(form, 'sid', true);
	form.uid=application.zcore.functions.zso(form, 'uid', true);
	imagePath=application.zcore.functions.zvar('privateHomeDir', form.sid)&"zupload/whitelabel/";
	imageDisplayPath=application.zcore.functions.zvar('domain', form.sid);
	db.sql="select * from #request.zos.queryObject.table("whitelabel_button", request.zos.zcoreDatasource)# whitelabel_button 
	WHERE whitelabel_id = #db.param(form.whitelabel_id)# and 
	whitelabel_button_id = #db.param(form.whitelabel_button_id)# and 
	whitelabel_button_deleted=#db.param(0)# and   
	site_id = #db.param(form.sid)# ";
	qButton=db.execute("qButton");
	if(form.method EQ "editButton" and qButton.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Whitelabel Button doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/white-label/index?sid=#form.sid#&zsid=#request.zsid#");
	}

	if(form.method EQ "addButton"){
		newMethod="insertButton";
	}else{
		newMethod="updateButton";
	}
	application.zcore.functions.zQueryToStruct(qButton, form, 'whitelabel_button_id,whitelabel_id,site_id,whitelabel_button_public');
	</cfscript>
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/server-manager/admin/white-label/#newMethod#?whitelabel_button_id=#form.whitelabel_button_id#&amp;whitelabel_id=#form.whitelabel_id#&amp;sid=#form.sid#" method="post" enctype="multipart/form-data">
		<cfscript>
		tabCom=createobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic"]);//,"Advanced"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-whitelabel-button-edit");
		cancelURL="/z/server-manager/admin/white-label/manageButtons?whitelabel_id=#form.whitelabel_id#&sid=#form.sid#";
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table style="width:100%; border-spacing:0px;" class="table-list">

			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Type","member.whitelabel.editButton whitelabel_button_public")#</th>
				<td style="vertical-align:top; "><cfscript>
				form.whitelabel_button_public=application.zcore.functions.zso(form, 'whitelabel_button_public', true, 0);
				ts = StructNew();
				ts.name = "whitelabel_button_public";
				ts.labelList = "Public,Admin";
				ts.valueList = "1,0";
				writeoutput(application.zcore.functions.zInput_RadioGroup(ts));
				</cfscript></td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Label","member.whitelabel.editButton whitelabel_button_label")#</th>
				<td style="vertical-align:top; "><input type="text" name="whitelabel_button_label" style="width:95%;" value="#HTMLEditFormat(form.whitelabel_button_label)#"></td>
			</tr> 
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Built-in","member.whitelabel.editButton whitelabel_button_builtin")#</th>
				<td style="vertical-align:top; "><cfscript>

					// this has to be able to be retrieved by site_id argument instead of global.  much harder!  might want to hardcode a structure with all of these links instead.  but the custom ones - too many.  need to use http request or API to retrieve the data from each site.
					sharedMenuStruct=structnew();
					//sharedMenuStruct=application.zcore.app.getAdminMenu(sharedMenuStruct); 
					arrLink=[];
					arrLabel=[];
					for(i in sharedMenuStruct){
						c=sharedMenuStruct[i];
						arrayAppend(arrLink, c.link);
						arrayAppend(arrLabel, replace(i, '&amp;', '&', 'all'));
						for(n in c.children){
							arrayAppend(arrLink, c.link);
							arrayAppend(arrLabel, replace(n, '&amp;', '&', 'all'));
						}
					}
					ts = structNew();
					ts.name = "whitelabel_button_builtin";
					ts.selectLabel="-- Select --";
					ts.listLabels = arrayToList(arrLabel, ",");
					ts.listValues = arrayToList(arrLink, ",");
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("URL","member.whitelabel.editButton whitelabel_button_url")#</th>
				<td style="vertical-align:top; "><input type="text" name="whitelabel_button_url" style="width:95%;" value="#HTMLEditFormat(form.whitelabel_button_url)#" /><br />
				(This field is ignored if you selected a built-in link.)</td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Summary","member.whitelabel.editButton whitelabel_button_summary")#</th>
				<td style="vertical-align:top; "><input type="text" name="whitelabel_button_summary" style="width:95%;" value="#HTMLEditFormat(form.whitelabel_button_summary)#"></td>
			</tr> 
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Target","member.whitelabel.editButton whitelabel_button_target")#</th>
				<td style="vertical-align:top; "><cfscript>
					ts = structNew();
					ts.name = "whitelabel_button_target";
					ts.selectLabel="-- Normal Link --";
					ts.listLabels = "New Window";
					ts.listValues = "_blank";
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Image","member.whitelabel.editButton whitelabel_button_image128")#</th>
  				<td>#application.zcore.functions.zInputImage('whitelabel_button_image128', imagePath, imageDisplayPath&'/zupload/whitelabel/')# </td>
  			</tr>
		</table>
		#tabCom.endFieldSet()#
		<!--- #tabCom.beginFieldSet("Advanced")#
		#tabCom.endFieldSet()# --->
		#tabCom.endTabMenu()#
	</form>
</cffunction>

<cffunction name="initSort" localmode="modern" access="private" roles="serveradministrator">
	<cfscript>

	var queueSortStruct = StructNew();
	queueSortStruct.tableName = "whitelabel_button";
	queueSortStruct.datasource=request.zos.zcoreDatasource;
	queueSortStruct.sortFieldName = "whitelabel_button_sort";
	queueSortStruct.primaryKeyName = "whitelabel_button_id";
	queueSortStruct.where="site_id = '#application.zcore.functions.zescape(form.sid)#' and 
	whitelabel_id = '#application.zcore.functions.zescape(form.whitelabel_id)#' and 
	whitelabel_button_public=0 and 
	whitelabel_button_deleted='0' ";
	queueSortStruct.ajaxURL="/z/server-manager/admin/white-label/manageButtons?whitelabel_id=#form.whitelabel_id#&sid=#form.sid#";
	queueSortStruct.ajaxTableId="sortRowTable0";
	queueSortStruct.sortVarNameAjax="zQueueSortAjax0";
	variables.queueSortCom0 = CreateObject("component", "zcorerootmapping.com.display.queueSort");
	variables.queueSortCom0.init(queueSortStruct);
	variables.queueSortCom0.returnJson();

	queueSortStruct2=duplicate(queueSortStruct);
	queueSortStruct2.sortVarNameAjax="zQueueSortAjax1";
	queueSortStruct2.where="site_id = '#application.zcore.functions.zescape(form.sid)#' and 
	whitelabel_id = '#application.zcore.functions.zescape(form.whitelabel_id)#' and whitelabel_button_public=1 ";
	queueSortStruct2.ajaxTableId="sortRowTable1";
	variables.queueSortCom1 = CreateObject("component", "zcorerootmapping.com.display.queueSort");
	variables.queueSortCom1.init(queueSortStruct2);
	variables.queueSortCom1.returnJson();
	</cfscript>
</cffunction>

<cffunction name="manageButtons" localmode="modern" access="remote" roles="serveradministrator">
	<cfscript>
	db=request.zos.queryObject;
	application.zcore.functions.zStatusHandler(request.zsid);
	form.whitelabel_id=application.zcore.functions.zso(form, 'whitelabel_id',true);
	form.sid=application.zcore.functions.zso(form, 'sid', true); 
	imagePath=application.zcore.functions.zvar('privateHomeDir', form.sid)&"zupload/whitelabel/";
	db.sql=" SELECT * FROM #request.zos.queryObject.table("whitelabel", request.zos.zcoreDatasource)# whitelabel 
	WHERE whitelabel_id = #db.param(form.whitelabel_id)# and 
	whitelabel_deleted=#db.param(0)# and  
	site_id = #db.param(form.sid)# ";
	qData=db.execute("qData");
	if(qData.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Whitelabel Record doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/white-label/index?sid=#form.sid#&zsid=#request.zsid#");
	}
	initSort();
	</cfscript>
	<p><a href="/z/server-manager/admin/white-label/index?sid=#form.sid#">White-Label Settings</a> /</p>
	<h2>Manage Buttons</h2>
	<p><a href="/z/server-manager/admin/white-label/addButton?whitelabel_id=#form.whitelabel_id#&amp;sid=#form.sid#">Add Admin Button</a> | <a href="/z/server-manager/admin/white-label/addButton?whitelabel_button_public=1&amp;whitelabel_id=#form.whitelabel_id#&amp;sid=#form.sid#">Add Public Button</a></p>

	<h3>Manager Dashboard Buttons</h3>
	#listButtonTable(0)#
	<h3>Public Dashboard Buttons</h3>
	
	#listButtonTable(1)#
</cffunction>

<cffunction name="listButtonTable" localmode="modern" access="private" roles="serveradministrator">
	<cfargument name="public" type="numeric" required="yes">
	<cfscript>
	db=request.zos.queryObject; 
	db.sql="select * from #request.zos.queryObject.table("whitelabel_button", request.zos.zcoreDatasource)# whitelabel_button 
	WHERE whitelabel_id = #db.param(form.whitelabel_id)# and 
	whitelabel_button_deleted=#db.param(0)# and 
	whitelabel_button_public = #db.param(arguments.public)# and 
	site_id = #db.param(form.sid)# 
	ORDER BY whitelabel_button_sort ASC";
	qButton=db.execute("qButton");
	</cfscript>
	<cfif qButton.recordcount EQ 0>
		<p>No buttons added</p>
	<cfelse>
		<table id="sortRowTable#arguments.public#" class="table-list">
			<thead>
			<tr>
				<th>Label</th>
				<th>URL</th>
				<th>Built-in</th>
				<th>Sort</th>
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
				<cfscript>
				for(row in qButton){
					echo('<tr #variables["queueSortCom"&arguments.public].getRowHTML(row.whitelabel_button_id)#> 
					<td>'&row.whitelabel_button_label&'</td>
					<td>');
					if(row.whitelabel_button_builtin NEQ ""){
						echo('<a href="'&row.whitelabel_button_builtin&'" target="_blank">'&application.zcore.functions.zLimitStringLength(row.whitelabel_button_builtin, 40)&'</a>');
					}else{
						echo('<a href="'&row.whitelabel_button_url&'" target="_blank">'&row.whitelabel_button_url&'</a>');
					}
					echo('</td>
					<td>');
					if(row.whitelabel_button_builtin NEQ ""){
						echo('Yes');
					}else{
						echo('No');
					}
					variables["queueSortCom"&arguments.public].getRowStruct(row.whitelabel_button_id);
					echo('</td>
					<td>#variables["queueSortCom"&arguments.public].getAjaxHandleButton(row.whitelabel_button_id)#</td>
					<td><a href="/z/server-manager/admin/white-label/editButton?whitelabel_button_id=#row.whitelabel_button_id#&amp;whitelabel_id=#form.whitelabel_id#&amp;sid=#form.sid#">Edit</a> |  
					<a href="/z/server-manager/admin/white-label/deleteButton?whitelabel_button_id=#row.whitelabel_button_id#&amp;whitelabel_id=#form.whitelabel_id#&amp;sid=#form.sid#">Delete</a></td></tr>');
				}
				</cfscript>
			</tbody>
		</table><br />
	</cfif>
</cffunction>
	
<cffunction name="edit" localmode="modern" access="remote" roles="serveradministrator">

	<cfscript>
	var db=request.zos.queryObject;
	var currentMethod=form.method; 
	imageDisplayPath=application.zcore.functions.zvar('domain', form.sid);
	//application.zcore.functions.zSetPageHelpId("7.5");
	form.whitelabel_id=application.zcore.functions.zso(form, 'whitelabel_id',true);
	form.sid=application.zcore.functions.zso(form, 'sid', true);
	form.uid=application.zcore.functions.zso(form, 'uid', true);
	imagePath=application.zcore.functions.zvar('privateHomeDir', form.sid)&"zupload/whitelabel/";
	db.sql=" SELECT * FROM #request.zos.queryObject.table("whitelabel", request.zos.zcoreDatasource)# whitelabel 
	WHERE whitelabel_id = #db.param(form.whitelabel_id)# and 
	whitelabel_deleted=#db.param(0)# and 
	user_id = #db.param(form.uid)# and 
	site_id = #db.param(form.sid)# ";
	qData=db.execute("qData");
	application.zcore.functions.zQueryToStruct(qData,form,'whitelabel_id,site_id'); 
	application.zcore.functions.zStatusHandler(request.zsid, true);

	application.zcore.skin.includeJS("/z/javascript/jscolor.js");
	</cfscript>
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/server-manager/admin/white-label/save?whitelabel_id=#form.whitelabel_id#&amp;sid=#form.sid#&amp;uid=#form.uid#" method="post" enctype="multipart/form-data">
		<cfscript>
		tabCom=createobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic"]);//,"Advanced"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-whitelabel-edit");
		cancelURL="/z/server-manager/admin/white-label/index?sid=#form.sid#";
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table style="width:100%; border-spacing:0px;" class="table-list"> 
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Admin Raw Header HTML","member.whitelabel.edit whitelabel_dashboard_header_raw_html")#</th>
				<td style="vertical-align:top; "><textarea name="whitelabel_dashboard_header_raw_html" rows="5" cols="5" style="width:95%;">#htmleditformat(form.whitelabel_dashboard_header_raw_html)#</textarea></td>
			</tr> 
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Admin Raw Footer HTML","member.whitelabel.edit whitelabel_dashboard_footer_raw_html")#</th>
				<td style="vertical-align:top; "><textarea name="whitelabel_dashboard_footer_raw_html" rows="5" cols="5" style="width:95%;">#htmleditformat(form.whitelabel_dashboard_footer_raw_html)#</textarea></td>
			</tr> 
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Admin Dashboard Header HTML","member.whitelabel.edit whitelabel_dashboard_header_html")#</th>
				<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "whitelabel_dashboard_header_html";
            htmlEditor.value			= form.whitelabel_dashboard_header_html;
            htmlEditor.basePath		= '/';
            htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
            htmlEditor.height		= 400;
            htmlEditor.create();
            </cfscript></td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Admin Dashboard Footer HTML","member.whitelabel.edit whitelabel_dashboard_footer_html")#</th>
				<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "whitelabel_dashboard_footer_html";
            htmlEditor.value			= form.whitelabel_dashboard_footer_html;
            htmlEditor.basePath		= '/';
            htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
            htmlEditor.height		= 400;
            htmlEditor.create();
            </cfscript></td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Admin Dashboard Sidebar HTML","member.whitelabel.edit whitelabel_dashboard_sidebar_html")#</th>
				<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "whitelabel_dashboard_sidebar_html";
            htmlEditor.value			= form.whitelabel_dashboard_sidebar_html;
            htmlEditor.basePath		= '/';
            htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
            htmlEditor.height		= 400;
            htmlEditor.create();
            </cfscript></td>
			</tr>
	
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Admin Login Header HTML","member.whitelabel.edit whitelabel_login_header_html")#</th>
				<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "whitelabel_login_header_html";
            htmlEditor.value			= form.whitelabel_login_header_html;
            htmlEditor.basePath		= '/';
            htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
            htmlEditor.height		= 400;
            htmlEditor.create();
            </cfscript></td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Admin Login Footer HTML","member.whitelabel.edit whitelabel_login_footer_html")#</th>
				<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "whitelabel_login_footer_html";
            htmlEditor.value			= form.whitelabel_login_footer_html;
            htmlEditor.basePath		= '/';
            htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
            htmlEditor.height		= 400;
            htmlEditor.create();
            </cfscript></td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Admin Login Sidebar HTML","member.whitelabel.edit whitelabel_login_sidebar_html")#</th>
				<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "whitelabel_login_sidebar_html";
            htmlEditor.value			= form.whitelabel_login_sidebar_html;
            htmlEditor.basePath		= '/';
            htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
            htmlEditor.height		= 400;
            htmlEditor.create();
            </cfscript></td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Dashboard Header HTML","member.whitelabel.edit whitelabel_public_dashboard_header_html")#</th>
				<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "whitelabel_public_dashboard_header_html";
            htmlEditor.value			= form.whitelabel_public_dashboard_header_html;
            htmlEditor.basePath		= '/';
            htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
            htmlEditor.height		= 400;
            htmlEditor.create();
            </cfscript></td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Public Dashboard Footer HTML","member.whitelabel.edit whitelabel_public_dashboard_footer_html")#</th>
				<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = createObject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "whitelabel_public_dashboard_footer_html";
            htmlEditor.value			= form.whitelabel_public_dashboard_footer_html;
            htmlEditor.basePath		= '/';
            htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
            htmlEditor.height		= 400;
            htmlEditor.create();
            </cfscript></td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Admin Header Background Color","member.whitelabel.edit whitelabel_dashboard_header_background_color")#</th>
				<td style="vertical-align:top; "><input class="zColorInput" type="text" name="whitelabel_dashboard_header_background_color" value="#HTMLEditFormat(form.whitelabel_dashboard_header_background_color)#" style="width:90px;"></td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Login Header Background Color","member.whitelabel.edit whitelabel_login_header_background_color")#</th>
				<td style="vertical-align:top; "><input class="zColorInput" type="text" name="whitelabel_login_header_background_color" value="#HTMLEditFormat(form.whitelabel_login_header_background_color)#" style="width:90px;"></td>
			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Admin Header Image 960","member.whitelabel.edit whitelabel_dashboard_header_image_960")#</th>
  				<td>#application.zcore.functions.zInputImage('whitelabel_dashboard_header_image_960', imagePath, imageDisplayPath&'/zupload/whitelabel/')# </td>
  			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Admin Header Image 640","member.whitelabel.edit whitelabel_dashboard_header_image_640")#</th>
  				<td>#application.zcore.functions.zInputImage('whitelabel_dashboard_header_image_640', imagePath, imageDisplayPath&'/zupload/whitelabel/')# </td>
  			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Admin Header Image 320","member.whitelabel.edit whitelabel_dashboard_header_image_320")#</th>
  				<td>#application.zcore.functions.zInputImage('whitelabel_dashboard_header_image_320', imagePath, imageDisplayPath&'/zupload/whitelabel/')# </td>
  			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Login Header Image 960","member.whitelabel.edit whitelabel_login_header_image_960")#</th>
  				<td>#application.zcore.functions.zInputImage('whitelabel_login_header_image_960', imagePath, imageDisplayPath&'/zupload/whitelabel/')# </td>
  			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Login Header Image 640","member.whitelabel.edit whitelabel_login_header_image_640")#</th>
  				<td>#application.zcore.functions.zInputImage('whitelabel_login_header_image_640', imagePath, imageDisplayPath&'/zupload/whitelabel/')# </td>
  			</tr>
			<tr>
				<th>#application.zcore.functions.zOutputHelpToolTip("Login Header Image 320","member.whitelabel.edit whitelabel_login_header_image_320")#</th>
  				<td>#application.zcore.functions.zInputImage('whitelabel_login_header_image_320', imagePath, imageDisplayPath&'/zupload/whitelabel/')# </td>
  			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("CSS","member.whitelabel.edit whitelabel_css")#</th>
				<td style="vertical-align:top; "><textarea type="text" cols="10" rows="5"  name="whitelabel_css" style="width:95%; height:400px;">#HTMLEditFormat(form.whitelabel_css)#</textarea></td>
			</tr> 
		</table>
		#tabCom.endFieldSet()#
		<!--- #tabCom.beginFieldSet("Advanced")#
		#tabCom.endFieldSet()# --->
		#tabCom.endTabMenu()#
	</form>
</cffunction>

	
<cffunction name="index" localmode="modern" access="remote" roles="serveradministrator">
	<!--- 

	allow statistics on bottom right
		Unassigned leads 
		Open leads


I will plan and/or make some statistics features that link to the report view for that which can be turned on/off in bottom right or in the main content area.   This will vary based on the features of the site, and the level of integration they have.   Like real estate vs ecommerce.  This is likely to be the last thing I build and it's hardly useful with current features.

	 --->
	 <h2>White-Label Settings</h2>
	 <p>This feature allows you to customize the login page, the site manager dashboard, and the public user dashboard in a multi-developer environment or for specific customers to find features and support information more easily.</p>
	 <p>You can whitelabel the parent site, which will be inherited by all its child sites.  You can also set whitelabel settings for the specific site or specific users which will be used instead of the parent site settings. To begin click add/edit next to one of the records below. After creating the initial settings, you'll be able to click "Edit Buttons" to add links to the admin and public user dashboard pages.</p>
	<cfscript>
	db=request.zos.queryObject;
	form.sid=application.zcore.functions.zso(form, 'sid');
	if(form.sid EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid request", form, true);
		application.zcore.functions.zRedirect("/z/server-manager/admin/server-home/index?zsid=#request.zsid#");
	}
	application.zcore.functions.zStatusHandler(request.zsid);
	echo('<table class="table-list">
		<tr>
			<th>User</th>
			<th>Email</th>
			<th>Admin</th>
		</tr>');
	parentSid=application.zcore.functions.zvar('parentId', form.sid);
	if(parentSid NEQ 0 and parentSid NEQ ""){
		db.sql="select * from #db.table("whitelabel", request.zos.zcoreDatasource)# 
		WHERE whitelabel_deleted = #db.param(0)# and 
		user_id = #db.param(0)# and 
		site_id = #db.param(parentSid)# ";
		qWhiteLabelParent=db.execute("qWhiteLabelParent");
		if(qWhiteLabelParent.recordcount EQ 0){
				echo('<tr><td>Parent Site (#application.zcore.functions.zvar('shortDomain', parentSid)#)</td>
						<td>&nbsp;</td>');
				echo('<td><a href="/z/server-manager/admin/white-label/edit?sid=#parentSid#&amp;whitelabel_id=&amp;uid=">Add</a></td>
				</tr>');
		}else{
			for(row in qWhiteLabelParent){
				echo('<tr><td>Parent Site (#application.zcore.functions.zvar('shortDomain', parentSid)#)</td>
						<td>&nbsp;</td>');
				echo('<td><a href="/z/server-manager/admin/white-label/edit?sid=#row.site_id#&amp;whitelabel_id=#row.whitelabel_id#&amp;uid=#row.user_id#">Edit</a> | 
					<a href="/z/server-manager/admin/white-label/manageButtons?sid=#row.site_id#&amp;whitelabel_id=#row.whitelabel_id#">Edit Buttons</a></td>
				</tr>');
			}
		}
	} 
	db.sql="select * from #db.table("whitelabel", request.zos.zcoreDatasource)# whitelabel  
	WHERE whitelabel_deleted = #db.param(0)# and 
	user_id = #db.param(0)# and 
	whitelabel.site_id = #db.param(form.sid)#  ";
	qWhiteLabel=db.execute("qWhiteLabel");
	if(qWhiteLabel.recordcount EQ 0){
		echo('<tr><td>Site (#application.zcore.functions.zvar('shortDomain', form.sid)#)</td>
			<td>&nbsp;</td>');
		echo('<td><a href="/z/server-manager/admin/white-label/edit?sid=#form.sid#&amp;whitelabel_id=&amp;uid=">Add</a></td>
		</tr>');
	}else{
		for(row in qWhiteLabel){
			echo('<tr><td>Site (#application.zcore.functions.zvar('shortDomain', form.sid)#)</td>
				<td>&nbsp;</td>');
			echo('<td><a href="/z/server-manager/admin/white-label/edit?sid=#row.site_id#&amp;whitelabel_id=#row.whitelabel_id#&amp;uid=">Edit</a> | 
					<a href="/z/server-manager/admin/white-label/manageButtons?sid=#row.site_id#&amp;whitelabel_id=#row.whitelabel_id#">Edit Buttons</a> | 
				<a href="/z/server-manager/admin/white-label/delete?sid=#row.site_id#&amp;whitelabel_id=#row.whitelabel_id#&amp;uid=">Delete</a></td>
			</tr>');
		}
	}
	db.sql="select * from #db.table("whitelabel", request.zos.zcoreDatasource)# whitelabel
	left join #db.table("user", request.zos.zcoreDatasource)# user ON 
	whitelabel.user_id = user.user_id and 
	user_deleted = #db.param(0)# and 
	whitelabel.site_id = user.site_id
	WHERE whitelabel_deleted = #db.param(0)# and 
	whitelabel.user_id <> #db.param(0)# and 
	whitelabel.site_id = #db.param(form.sid)# 
	ORDER BY user_first_name ASC, user_last_name ASC";
	qWhiteLabel=db.execute("qWhiteLabel");
	arrUser=["'0'"];
	for(row in qWhiteLabel){
		arrayAppend(arrUser, "'"&row.user_id&"'");
		echo('<tr><td>#row.user_first_name# #row.user_last_name#</td>
			<td>#row.user_username#</td>');
		echo('<td><a href="/z/server-manager/admin/white-label/edit?sid=#row.site_id#&amp;whitelabel_id=#row.whitelabel_id#&amp;uid=#row.user_id#">Edit</a> | 
			<a href="/z/server-manager/admin/white-label/manageButtons?sid=#row.site_id#&amp;whitelabel_id=#row.whitelabel_id#&amp;uid=#row.user_id#">Edit Buttons</a> | 
			<a href="/z/server-manager/admin/white-label/delete?sid=#row.site_id#&amp;whitelabel_id=#row.whitelabel_id#&amp;uid=#row.user_id#">Delete</a></td>
		</tr>');
	}


	var userGroupCom = CreateObject("component","zcorerootmapping.com.user.user_group_admin");
	userUserGroupId = userGroupCom.getGroupId('user',request.zos.globals.id);
	db.sql=" SELECT * FROM #request.zos.queryObject.table("user", request.zos.zcoreDatasource)# user
	left join #db.table("whitelabel", request.zos.zcoreDatasource)# whitelabel on 

		whitelabel.user_id = user.user_id and 
		whitelabel_deleted = #db.param(0)# and 
		whitelabel.site_id = user.site_id 
	WHERE user.site_id = #db.param(form.sid)# and 
	whitelabel.whitelabel_id IS NULL and 
	user_group_id <> #db.param(userUserGroupId)# and
	user.user_id NOT IN (#db.trustedSQL(arrayToList(arrUser, ","))#) and 
	user_deleted = #db.param(0)# and 
	user_active = #db.param(1)# 
	ORDER BY user_first_name asc, user_last_name ASC ";
	quser=db.execute("quser");

	for(row in quser){
		echo('<tr><td>#row.user_first_name# #row.user_last_name#</td>
				<td>#row.user_username#</td>');
		echo('<td><a href="/z/server-manager/admin/white-label/edit?sid=#row.site_id#&whitelabel_id=&amp;uid=#row.user_id#">Add</a>'); 
		echo('</td>
		</tr>');
	}
	echo('</table>');

	</cfscript>
	
</cffunction>
	
</cfoutput>
</cfcomponent>