<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Autoresponders");
	var hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Autoresponders", true); 
	db.sql="SELECT * from #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)#   
	WHERE inquiries_rating_setting_id = #db.param(form.inquiries_rating_setting_id)# and 
	inquiries_rating_setting_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)#";
	qSetting=db.execute("qSetting");
	if(qSetting.recordcount EQ 0){ 
		application.zcore.status.setStatus(request.zsid, 'Lead Review Autoresponder doesn''t exist.',false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/review-autoresponder-settings/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		db.sql="DELETE from #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# 
		WHERE inquiries_rating_setting_id = #db.param(form.inquiries_rating_setting_id)# and 
		inquiries_rating_setting_deleted=#db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)#";
		db.execute("qDelete");
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead Review Autoresponder deleted.");
		application.zcore.functions.zRedirect("/z/inquiries/admin/review-autoresponder-settings/index?zsid="&request.zsid);
		</cfscript>
	<cfelse>
		<div style="text-align:center;">
			<h2>Are you sure you want to delete this Lead Review Autoresponder?<br />
			<br />
			Email Subject: #qSetting.inquiries_rating_setting_email_subject# 					<br />
			<br />
			<a href="/z/inquiries/admin/review-autoresponder-settings/delete?confirm=1&amp;inquiries_rating_setting_id=#form.inquiries_rating_setting_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/inquiries/admin/review-autoresponder-settings/index">No</a></h2>
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
	var db=request.zos.queryObject;
	var myForm={};
	init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Autoresponders", true);
	if(form.method EQ 'update'){
		db.sql="SELECT * from #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# 
		WHERE inquiries_rating_setting.inquiries_rating_setting_id = #db.param(form.inquiries_rating_setting_id)# and 
		inquiries_rating_setting_deleted=#db.param(0)# and 
		inquiries_rating_setting.site_id=#db.param(request.zos.globals.id)#";
		qSetting=db.execute("qSetting");
		if(qSetting.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, 'Review autoresponder doesn''t exist.',false,true);
			application.zcore.functions.zRedirect('/z/inquiries/admin/review-autoresponder-settings/index?zsid=#request.zsid#');
		}
	}
	myForm.inquiries_rating_setting_email_subject.required = true;
	myForm.inquiries_rating_setting_email_subject.friendlyName = "Email Subject";
	myForm.inquiries_rating_setting_type_id_list.required=true;
	myForm.inquiries_rating_setting_header_text.required=true;
	myForm.inquiries_rating_setting_footer_text.required=true;
	myForm.inquiries_rating_setting_email_delay_in_minutes.required=true;
	myForm.inquiries_rating_setting_email_resend_limit.required=true;
	myForm.inquiries_rating_setting_type.required=true;
	myForm.inquiries_rating_setting_low_rating_number.required=true;

	typeStruct=getTypeStruct();

	hasErrors = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);

	db.sql="select group_concat(inquiries_rating_setting_type_id_list SEPARATOR #db.param(",")#) idlist from #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# 
	WHERE
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_rating_setting_deleted=#db.param(0)# ";
	qRating=db.execute("qRating");
	arrId=listToArray(form.inquiries_rating_setting_type_id_list, ",");
	if(qRating.recordcount NEQ 0){
		arrExistingId=listToArray(qRating.idlist, ",");
		for(existingId in arrExistingId){
			for(id in arrId){
				if(existingId EQ id){
					typeName="Missing Lead Type";
					if(structkeyexists(typeStruct, id)){
						typeName=typeStruct[id].inquiries_type_name;
					}
					application.zcore.status.setStatus(request.zsid, "Lead type, ""#typeName#"", already has a Review Autoresponder, and there can be only one per lead type.", form, true);
					hasErrors=true;
				}
			}
		}
	}
	if(hasErrors){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect("/z/inquiries/admin/review-autoresponder-settings/add?zsid=#Request.zsid#");
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/review-autoresponder-settings/edit?zsid=#Request.zsid#&inquiries_rating_setting_id=#form.inquiries_rating_setting_id#");
		}
	}
	
	inputStruct = StructNew();
	inputStruct.table = "inquiries_rating_setting";
	inputStruct.datasource=request.zos.zcoreDatasource;
	inputStruct.struct=form;
	if(form.method EQ 'insert'){
		form.inquiries_id = application.zcore.functions.zInsert(inputStruct); 
		if(form.inquiries_id EQ false){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Failed to insert Review Autoresponder", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/review-autoresponder-settings/add?zsid="&request.zsid);
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Saved Review Autoresponder.");
			// success
		}
	}else{
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Failed to save Review Autoresponder.", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/review-autoresponder-settings/edit?zsid=#Request.zsid#&inquiries_rating_setting_id=#form.inquiries_rating_setting_id#");
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Saved Review Autoresponder.");
			// success
		}
	}
	application.zcore.functions.zRedirect('/z/inquiries/admin/review-autoresponder-settings/index?zsid='&request.zsid);
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="member">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 
	var currentMethod=form.method;
	init();
	application.zcore.functions.zSetPageHelpId("4.2");
	db.sql="SELECT * from #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# 
	WHERE inquiries_rating_setting_id = #db.param(application.zcore.functions.zso(form, 'inquiries_rating_setting_id'))# and 
	inquiries_rating_setting_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)#";
	qSetting=db.execute("qSetting");
	if(qSetting.recordcount EQ 0 and currentMethod EQ 'edit'){
		application.zcore.status.setStatus(request.zsid, 'Lead Review Autoresponder doesn''t exist.',false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/review-autoresponder-settings/index?zsid=#request.zsid#');
	}
	application.zcore.functions.zQueryToStruct(qSetting);
	application.zcore.functions.zStatusHandler(request.zsid,true);

	typeStruct=getTypeStruct();
	</cfscript>
	<h2><cfif currentMethod EQ 'add'>
		Add
	<cfelse>
		Edit
	</cfif>
		Lead Review Autoresponder</h2>
	<form class="zFormCheckDirty" action="/z/inquiries/admin/review-autoresponder-settings/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?inquiries_rating_setting_id=#form.inquiries_rating_setting_id#" method="post">
		<table style="border-spacing:0px;" class="table-list">
			
			<cfscript>
			if(form.inquiries_rating_setting_type EQ ""){
				form.inquiries_rating_setting_type=0;
			}
			if(form.inquiries_rating_setting_low_rating_number EQ "" or form.inquiries_rating_setting_low_rating_number EQ 0){
				form.inquiries_rating_setting_low_rating_number=3;
			}
			if(form.inquiries_rating_setting_email_resend_limit EQ "" or form.inquiries_rating_setting_email_resend_limit EQ 0){
				form.inquiries_rating_setting_email_resend_limit=3;
			}
			if(form.inquiries_rating_setting_email_delay_in_minutes EQ "" or form.inquiries_rating_setting_email_delay_in_minutes EQ "0"){
				form.inquiries_rating_setting_email_delay_in_minutes=86400;
			}
			if(form.inquiries_rating_setting_start_date EQ "" and form.method EQ "add"){
				form.inquiries_rating_setting_start_date=dateadd("d", -30, now());
			}
			</cfscript>
			<tr>
				<th>Lead Types: *</th>
				<td>
					<cfscript> 
					typeStruct=getTypeStruct();
					arrType=[];
					for(typeId in typeStruct){
						arrayAppend(arrType, typeStruct[typeId]);
					}
					ts = StructNew();
					ts.name = "inquiries_rating_setting_type_id_list"; 
					ts.query = arrType; // this can be an array of structs or a query
					ts.queryLabelField = "##inquiries_type_name##"; 
					ts.queryParseLabelVars = true;
					ts.queryParseValueVars = true;
					ts.queryValueField = "##inquiries_type_id##|##siteidtype##";  
					ts.multiple=true;
					application.zcore.functions.zSetupMultipleSelect(ts.name, application.zcore.functions.zso(form, 'inquiries_rating_setting_type_id_list'));
					application.zcore.functions.zInputSelectBox(ts);
					</cfscript> 
				</td>
			</tr>
			<tr>
				<th>Send On:</th>
				<td>
					<cfscript>
					ts = StructNew();
					ts.name = "inquiries_rating_setting_type";
					ts.labelList = "Every Lead|Every Day|First Lead Only";
					ts.valueList = "0|1|2";
					ts.delimiter="|";
					ts.output=true;
					ts.struct=form;
					application.zcore.functions.zInput_RadioGroup(ts);
					</cfscript>
				</td>
			</tr>
			<tr>
				<th>Email Subject: *</th>
				<td><input type="text" name="inquiries_rating_setting_email_subject" value="#htmleditformat(form.inquiries_rating_setting_email_subject)#" /></td>
			</tr>
			<tr>
				<th>Header:</th>
				<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "inquiries_rating_setting_header_text";
					htmlEditor.value			= form.inquiries_rating_setting_header_text;
					htmlEditor.width			= "100%";
					htmlEditor.height		= 350;
					htmlEditor.create();
					</cfscript>
				</td>
			</tr>
			<tr>
				<th>Body:</th>
				<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "inquiries_rating_setting_body_text";
					htmlEditor.value			= form.inquiries_rating_setting_body_text;
					htmlEditor.width			= "100%";
					htmlEditor.height		= 350;
					htmlEditor.create();
					</cfscript>
				</td>
			</tr>
			<tr>
				<th>Footer:</th>
				<td>
					<cfscript>
					htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
					htmlEditor.instanceName	= "inquiries_rating_setting_footer_text";
					htmlEditor.value			= form.inquiries_rating_setting_footer_text;
					htmlEditor.width			= "100%";
					htmlEditor.height		= 350;
					htmlEditor.create();
					</cfscript>
				</td>
			</tr>
			<tr>
				<th>Delay In Minutes: *</th>
				<td>
					<input type="number" name="inquiries_rating_setting_email_delay_in_minutes" value="#htmleditformat(form.inquiries_rating_setting_email_delay_in_minutes)#" /><br>
					I.e. 1 Day would be 86400 minutes
				</td>
			</tr>
			<tr>
				<th>## of Times To Resend: *</th>
				<td>
					<input type="number" name="inquiries_rating_setting_email_resend_limit" value="#htmleditformat(form.inquiries_rating_setting_email_resend_limit)#" /><br>
					Note: 0 will send forever until they unsubscribe or post a review.
				</td>
			</tr>
			<tr>
				<th>Start Date:</th>
				<td>
					<input type="date" name="inquiries_rating_setting_start_date" value="#htmleditformat(dateformat(form.inquiries_rating_setting_start_date, "yyyy-mm-dd"))#" />
					<br>
					Note: Review autoresponders will only be sent to leads created on or after the date specified.  Leaving this field blank will send the email to all existing leads.
				</td>
			</tr>
			<tr>
				<th>Low Rating Threshold:</th>
				<td>
					<input type="number" name="inquiries_rating_setting_low_rating_number" value="#htmleditformat(form.inquiries_rating_setting_low_rating_number)#" /><br>
					Reviews at or below this number will see the Low Rating confirmation page instead of the High Rating confirmation page.
				</td>
			</tr>
			<cfsavecontent variable="out">
				<tr>
					<th>Low Rating Heading:</th>
					<td>
						<input type="text" name="inquiries_rating_setting_low_rating_thanks_heading" value="#htmleditformat(form.inquiries_rating_setting_low_rating_thanks_heading)#" />
					</td>
				</tr>
				<tr>
					<th>Low Rating Body:</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "inquiries_rating_setting_low_rating_thanks_body";
						htmlEditor.value			= form.inquiries_rating_setting_low_rating_thanks_body;
						htmlEditor.width			= "100%";
						htmlEditor.height		= 350;
						htmlEditor.create();
						</cfscript>
					</td>
				</tr>
				<tr>
					<th>High Rating Heading:</th>
					<td>
						<input type="text" name="inquiries_rating_setting_high_rating_thanks_heading" value="#htmleditformat(form.inquiries_rating_setting_high_rating_thanks_heading)#" />
					</td>
				</tr>
				<tr>
					<th>High Rating Body:</th>
					<td>
						<cfscript>
						htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
						htmlEditor.instanceName	= "inquiries_rating_setting_high_rating_thanks_body";
						htmlEditor.value			= form.inquiries_rating_setting_high_rating_thanks_body;
						htmlEditor.width			= "100%";
						htmlEditor.height		= 350;
						htmlEditor.create();
						</cfscript>
					</td>
				</tr>
			</cfsavecontent>
			<cfif not request.zos.isDeveloper>
				<cfif form.inquiries_rating_setting_thanks_cfc_object NEQ "">
					<tr><th>Confirmation Page</th><td>Overridden by the developer</td></tr>
				<cfelse>
					#out#

				</cfif>
			<cfelse>
				#out#
				<tr>
					<th>Confirmation CFC Object:</th>
					<td>
						<input type="text" name="inquiries_rating_setting_thanks_cfc_object" value="#htmleditformat(form.inquiries_rating_setting_thanks_cfc_object)#" /><br>
						Note: If these fields are specified, the low/high rating confirmation information page be overriden with the output of the CFC Object/Method (i.e. root.mvc.controller.reviewThanks)
					</td>
				</tr>
				<tr>
					<th>Confirmation CFC Method:</th>
					<td>
						<input type="text" name="inquiries_rating_setting_thanks_cfc_method" value="#htmleditformat(form.inquiries_rating_setting_thanks_cfc_method)#" />
					</td>
				</tr>
			</cfif>
			<tr>
				<th>&nbsp;</th>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">Save</button>
				<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href = '/z/inquiries/admin/review-autoresponder-settings/index';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>


<cffunction name="getTypeStruct" localmode="modern" access="public">
	<cfscript>
	var db=request.zos.queryObject;

	db.sql="SELECT * from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
	WHERE  inquiries_type.site_id IN (#db.param(0)#,#db.param(request.zOS.globals.id)#) and 
	inquiries_type_deleted = #db.param(0)# ";
	if(not application.zcore.app.siteHasApp("listing")){
		db.sql&=" and inquiries_type_realestate = #db.param(0)# ";
	}
	if(not application.zcore.app.siteHasApp("rental")){
		db.sql&=" and inquiries_type_rentals = #db.param(0)# ";
	}
	db.sql&=" ORDER BY inquiries_type_name ASC ";
	qTypes=db.execute("qTypes");
	typeStruct=structnew("linked");
	for(row in qTypes){
		row.siteidtype=application.zcore.functions.zGetSiteIdType(row.site_id);
		typeStruct[row.inquiries_type_id&"|"&row.siteidtype]=row;
	}
	return typeStruct;
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	init();
	//application.zcore.functions.zSetPageHelpId("4.3");
	db.sql="SELECT * from #db.table("inquiries_rating_setting", request.zos.zcoreDatasource)# 
	WHERE  inquiries_rating_setting.site_id IN (#db.param(0)#,#db.param(request.zOS.globals.id)#) and 
	inquiries_rating_setting_deleted = #db.param(0)# "; 
	db.sql&=" ORDER BY inquiries_rating_setting_email_subject ASC ";
	qSetting=db.execute("qSetting");

	typeStruct=getTypeStruct();

	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2 style="display:inline; ">Lead Review Autoresponders</h2> &nbsp;&nbsp;
	<a href="/z/inquiries/admin/review-autoresponder-settings/add" class="z-manager-search-button">Add Review Autoresponder</a> <br />
	<br />
	<table style="border-spacing:0px;" class="table-list">
		<tr>
			<th>ID</th>
			<th>Email Subject</th> 
			<th>Lead Types</th> 
			<th>Admin</th>
		</tr>
		<cfloop query="qSetting">
			<tr <cfif qSetting.currentRow mod 2 EQ 0>style="background-color:##EEEEEE;"</cfif>>
				<td>#qSetting.inquiries_rating_setting_id#</td> 
				<td>#qSetting.inquiries_rating_setting_email_subject#</td> 
				<td>
					<cfscript>
					arrType=listToArray(qSetting.inquiries_rating_setting_type_id_list, ",");
					arrTypeName=[]; 
					for(typeId in arrType){
						if(structkeyexists(typeStruct, typeId)){
							arrayAppend(arrTypeName, typeStruct[typeId].inquiries_type_name);
						}
					}
					arraySort(arrTypeName, "text", "asc");
					echo(arrayToList(arrTypeName, ", "));
					</cfscript>

				</td>
				<td class="z-manager-admin">
					<div class="z-manager-button-container">
						<a href="/z/inquiries/admin/review-autoresponder-settings/edit?inquiries_rating_setting_id=#qSetting.inquiries_rating_setting_id#" class="z-manager-edit" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a>
					</div>
					<div class="z-manager-button-container">
						<a href="/z/inquiries/admin/review-autoresponder-settings/delete?inquiries_rating_setting_id=#qSetting.inquiries_rating_setting_id#" class="z-manager-delete" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></a>
					</div>
				</td>
			</tr>
		</cfloop>
	</table>
</cffunction>
</cfoutput>
</cfcomponent>
