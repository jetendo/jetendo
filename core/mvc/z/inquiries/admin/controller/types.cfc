<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Types");
	var hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qTypes=0;
	var qInquiryCheck=0;
	var qImages=0;
	init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Types", true);
	form.sid=application.zcore.functions.zGetSiteIdFromSiteIdType(form.siteIdType);
	db.sql="SELECT * from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type  
	WHERE inquiries_type_id = #db.param(form.inquiries_type_id)# and 
	inquiries_type_deleted=#db.param(0)# and 
	site_id = #db.param(form.sid)#";
	qTypes=db.execute("qTypes");
	db.sql="SELECT inquiries_id from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE inquiries_type_id = #db.param(form.inquiries_type_id)# and 
	inquiries_deleted=#db.param(0)# and 
	site_id = #db.param(form.sid)# LIMIT #db.param(0)#,#db.param(1)#";
	qInquiryCheck=db.execute("qInquiryCheck");
	if((qInquiryCheck.recordcount NEQ 0 or qTypes.recordcount EQ 0) and form.method EQ 'edit'){ 
		application.zcore.status.setStatus(request.zsid, 'Lead type is locked and can''t be deleted.',false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/types/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		db.sql="DELETE from #db.table("inquiries_type", request.zos.zcoreDatasource)# 
		WHERE inquiries_type_id = #db.param(form.inquiries_type_id)# and 
		inquiries_type_deleted=#db.param(0)# and 
		site_id = #db.param(form.sid)#";
		qImages=db.execute("qImages");
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Lead type deleted.");
		application.zcore.functions.zRedirect("/z/inquiries/admin/types/index?zsid="&request.zsid);
		</cfscript>
	<cfelse>
		<div style="text-align:center;">
			<h2>Are you sure you want to delete this lead type?<br />
			<br />
			#qTypes.inquiries_type_name# 					<br />
			<br />
			<a href="/z/inquiries/admin/types/delete?confirm=1&amp;inquiries_type_id=#form.inquiries_type_id#&amp;siteIdType=#form.siteIdType#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/inquiries/admin/types/index">No</a></h2>
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
	var result=0;
	var qTypes=0;
	var myForm={};
	var inputStruct=0;
	init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Types", true);
	form.site_id=application.zcore.functions.zGetSiteIdFromSiteIdType(form.siteIdType);
	if(form.method EQ 'update'){
		db.sql="SELECT *, if(inquiries_type_locked = #db.param(1)#,#db.param(1)#,#db.param(0)#) locked 
		from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
		WHERE inquiries_type.inquiries_type_id = #db.param(form.inquiries_type_id)# and 
		inquiries_type_deleted=#db.param(0)# and 
		inquiries_type.site_id=#db.param(form.site_id)# 
		GROUP BY inquiries_type.inquiries_type_id";
		qTypes=db.execute("qTypes");
		if(qTypes.recordcount EQ 0 or qTypes.locked EQ 1){
			application.zcore.status.setStatus(request.zsid, 'Group is locked.',false,true);
			application.zcore.functions.zRedirect('/z/inquiries/admin/types/index?zsid=#request.zsid#');
		}
	}
	myForm.inquiries_type_name.required = true;
	myForm.inquiries_type_name.friendlyName = "Type";
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect("/z/inquiries/admin/types/add?zsid=#Request.zsid#&siteIdType=#form.siteIdType#");
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/types/edit?zsid=#Request.zsid#&inquiries_type_id=#form.inquiries_type_id#&siteIdType=#form.siteIdType#");
		}
	}
	
	inputStruct = StructNew();
	inputStruct.table = "inquiries_type";
	inputStruct.datasource=request.zos.zcoreDatasource;
	inputStruct.struct=form;
	if(form.method EQ 'insert'){
		form.inquiries_id = application.zcore.functions.zInsert(inputStruct); 
		if(form.inquiries_id EQ false){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Group must be unique.", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/types/add?zsid="&request.zsid);
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Group Added.");
			// success
		}
	}else{
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Group must be unique.", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/types/edit?zsid=#Request.zsid#&inquiries_type_id=#form.inquiries_type_id#&siteIdType=#form.siteIdType#");
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Group updated.");
			// success
		}
	}
	application.zcore.functions.zRedirect('/z/inquiries/admin/types/index?zsid='&request.zsid);
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
	var sid=0;
	var qTypes=0;
	var qInquiryCheck=0;
	var currentMethod=form.method;
	variables.init();
	application.zcore.functions.zSetPageHelpId("4.2");
	form.siteIdType=application.zcore.functions.zso(form,'siteIdType',false,1);
	form.sid=application.zcore.functions.zGetSiteIdFromSiteIdType(form.siteIdType);
	db.sql="SELECT * from #db.table("inquiries_type", request.zos.zcoreDatasource)# inquiries_type 
	WHERE inquiries_type_id = #db.param(application.zcore.functions.zso(form, 'inquiries_type_id'))# and 
	inquiries_type_deleted = #db.param(0)# and 
	site_id=#db.param(form.sid)# GROUP BY inquiries_type_id
	ORDER BY inquiries_type_name ASC";
	qTypes=db.execute("qTypes");
	db.sql="SELECT inquiries_id from #db.table("inquiries", request.zos.zcoreDatasource)# inquiries 
	WHERE inquiries_type_id = #db.param(application.zcore.functions.zso(form, 'inquiries_type_id'))# and 
	inquiries_type_id_siteIDType=#db.param(application.zcore.functions.zGetSiteIDType(form.sid))# and 
	inquiries_deleted = #db.param(0)# and 
	site_id = #db.param(request.zOS.globals.id)# 
	LIMIT #db.param(0)#,#db.param(1)#";
	qInquiryCheck=db.execute("qInquiryCheck");
	if((qInquiryCheck.recordcount NEQ 0 or qTypes.recordcount EQ 0) and currentMethod EQ 'edit'){
		application.zcore.status.setStatus(request.zsid, 'Lead type is locked and can''t be edited.',false,true);
		application.zcore.functions.zRedirect(request.cgi_script_name&'?zsid=#request.zsid#');
	}
	application.zcore.functions.zQueryToStruct(qTypes);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	</cfscript>
	<h2><cfif currentMethod EQ 'add'>
		Add
	<cfelse>
		Edit
	</cfif>
		Lead Type</h2>
	<p>Please enter a unique type name.</p>
	<form class="zFormCheckDirty" action="/z/inquiries/admin/types/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>&amp;inquiries_type_id=#form.inquiries_type_id#&siteIdType=#form.siteIdType#" method="post">
		<table style="border-spacing:0px;" class="table-list">
			<tr>
				<th>Type:</th>
				<td><input type="text" name="inquiries_type_name" value="#form.inquiries_type_name#" /></td>
			</tr>
			<tr>
				<th>&nbsp;</th>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">
				<cfif currentMethod EQ 'add'>
					Add
					<cfelse>
					Update
				</cfif>
				Type</button>
				<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href = '/z/inquiries/admin/types/index';">Cancel</button></td>
			</tr>
		</table>
	</form>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var qTypes=0;
	var siteIdType=0;
	var qInquiryCheck=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("4.3");
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
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2 style="display:inline; ">Lead Types</h2> &nbsp;&nbsp;
	<a href="/z/inquiries/admin/types/add?inquiries_type_id_siteIdType=1" class="z-manager-search-button">Add Lead Type</a> <br />
	<br />
	When you add a lead, you must specify what type the lead is.  The system has several built-in, but you can add others to manually track magazine, phone calls and other marketing. Locked types have leads associated and can't be deleted.<br />
	<br />
	<table style="border-spacing:0px;" class="table-list">
		<tr>
			<th>ID</th>
			<th>Name</th> 
			<th>Has Autoresponder?</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qTypes">
			<cfscript>
			siteIdType=application.zcore.functions.zGetSiteIDType(qTypes.site_id);
			db.sql="SELECT inquiries_id from #db.table("inquiries", request.zos.zcoreDatasource)#  
			WHERE inquiries_type_id = #db.param(qTypes.inquiries_type_id)# and 
			site_id = #db.param(request.zOS.globals.id)# and 
			inquiries_deleted = #db.param(0)# and
			inquiries_type_id_siteIDType=#db.param(siteIdType)# 
			LIMIT #db.param(0)#,#db.param(1)#";
			qInquiryCheck=db.execute("qInquiryCheck");


			db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#  
			WHERE  
			inquiries_autoresponder_deleted = #db.param(0)# and 
			site_id=#db.param(request.zos.globals.id)# and 
			inquiries_type_id=#db.param(qTypes.inquiries_type_id)# and 
			inquiries_type_id_siteidtype=#db.param(application.zcore.functions.zGetSiteIdType(qTypes.site_id))# ";
			qAutoresponder=db.execute("qAutoresponder");
			</cfscript>
			<tr <cfif qTypes.currentRow mod 2 EQ 0>style="background-color:##EEEEEE;"</cfif>>
				<td>#qTypes.inquiries_type_id#|#application.zcore.functions.zGetSiteIdType(qTypes.site_id)#</td> 
				<td>#qTypes.inquiries_type_name#</td> 
				<td><cfif qAutoresponder.recordcount EQ 1>Yes<cfelse>No</cfif></td>
				<td class="z-manager-admin">
					<cfif qTypes.site_id EQ 0>
						<div class="z-manager-button-container" style="padding-top:5px;">
							<span>Built-in System Type</span>
						</div>
					<cfelseif qInquiryCheck.recordcount NEQ 0>
						<div class="z-manager-button-container" style="padding-top:5px;">
							<span>Delete disabled</span>
						</div>
					<cfelse>
						<div class="z-manager-button-container">
							<a href="/z/inquiries/admin/types/edit?inquiries_type_id=#qTypes.inquiries_type_id#&amp;siteIdType=#siteIdType#" class="z-manager-edit" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a>
						</div>
						<div class="z-manager-button-container">
							<a href="/z/inquiries/admin/types/delete?inquiries_type_id=#qTypes.inquiries_type_id#&amp;siteIdType=#siteIdType#" class="z-manager-delete" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></a>
						</div>
					</cfif>
				</td>
			</tr>
		</cfloop>
	</table>
</cffunction>
</cfoutput>
</cfcomponent>
