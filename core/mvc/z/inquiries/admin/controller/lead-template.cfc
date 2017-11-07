<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private">
	<cfscript>
    application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Templates");
	var hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	</cfscript>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qTypes=0;
	var qImages=0;
	variables.init();
	form.sid=application.zcore.functions.zGetSiteIdFromSiteIdType(form.siteIdType);
	db.sql="SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template 
	WHERE inquiries_lead_template.inquiries_lead_template_id = #db.param(form.inquiries_lead_template_id)# and 
	inquiries_lead_template_deleted=#db.param(0)# and
	site_id =#db.param(form.sid)#";
	if(application.zcore.user.checkServerAccess() EQ false){
		db.sql&=" and site_id=#db.param(request.zos.globals.id)#";
	}
	qTypes=db.execute("qTypes");
	if(qTypes.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, 'Template doesn''t exist.',false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/lead-template/index?zsid=#request.zsid#');
	}
	</cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		db.sql="DELETE from #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)#  
		WHERE inquiries_lead_template_id=#db.param(form.inquiries_lead_template_id)# and 
		inquiries_lead_template_x_site_siteidtype=#db.param(form.siteIdType)# and  
		inquiries_lead_template_x_site_deleted=#db.param(0)# and
		site_id =#db.param(request.zos.globals.id)#";
		db.execute("qDelete");

		db.sql="DELETE from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# 
		WHERE inquiries_lead_template_id = #db.param(form.inquiries_lead_template_id)# and 
		inquiries_lead_template_deleted=#db.param(0)# and
		site_id =#db.param(form.sid)# ";
		db.execute("qDelete");
 
		request.zsid = application.zcore.status.setStatus(Request.zsid, "Template deleted.");
		application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/index?zsid="&request.zsid);
		</cfscript>
	<cfelse>
		<div style="text-align:center;">
			<h2>Are you sure you want to delete this template?<br />
				<br />
				#qTypes.inquiries_lead_template_name#<br />
				<br />
				<a href="/z/inquiries/admin/lead-template/delete?confirm=1&amp;inquiries_lead_template_id=#form.inquiries_lead_template_id#&amp;siteIDType=#form.siteIdType#">Yes</a>&nbsp;&nbsp;&nbsp;
				<a href="/z/inquiries/admin/lead-template/index">No</a></h2>
		</div>
	</cfif>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var myForm={};
	var result=0;
	var qCheck=0;
	var inputStruct=0;
	variables.init();
	form.site_id=application.zcore.functions.zGetSiteIdFromSiteIdType(form.siteIdType);
	if(form.method EQ 'update'){
		db.sql="SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template 
		WHERE inquiries_lead_template_id = #db.param(application.zcore.functions.zso(form,'inquiries_lead_template_id'))# and 
		site_id =#db.param(form.site_id)# and 
		inquiries_lead_template_deleted=#db.param(0)# ";
		if(application.zcore.user.checkServerAccess() EQ false){
			db.sql&=" and site_id=#db.param(request.zos.globals.id)#";
		}
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount NEQ 0){
			form.site_id=qcheck.site_id;	
		}
	}
	if(application.zcore.user.checkServerAccess(request.zos.globals.id)){
		if(application.zcore.functions.zso(form,'force_global') EQ 1){
			form.site_id=0;	
		}else if(application.zcore.functions.zso(form,'force_global') EQ 0){
			form.site_id=request.zos.globals.id;	
		}
	}
	myForm.inquiries_lead_template_type.required = true;
	myForm.inquiries_lead_template_type.friendlyName = "Type";
	myForm.inquiries_lead_template_name.required = true;
	myForm.inquiries_lead_template_name.friendlyName = "Template Name";
	result = application.zcore.functions.zValidateStruct(form, myForm, Request.zsid,true);
	if(result){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/add?zsid=#Request.zsid#");
		}else{
			application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/edit?zsid=#Request.zsid#&inquiries_lead_template_id=#form.inquiries_lead_template_id#");
		}
	}
	
	inputStruct = StructNew();
	inputStruct.table = "inquiries_lead_template";
	inputStruct.datasource=request.zos.zcoreDatasource;
	inputStruct.struct=form;
	if(form.method EQ 'insert'){
		form.inquiries_id = application.zcore.functions.zInsert(inputStruct); 
		if(form.inquiries_id EQ false){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Template name must be unique.", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/add?zsid="&request.zsid);
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Template Added.");
		}
	}else{
		if(application.zcore.functions.zUpdate(inputStruct) EQ false){
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Template name must be unique.", false,true);
			application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/edit?zsid=#Request.zsid#&inquiries_lead_template_id=#form.inquiries_lead_template_id#");
		}else{
			request.zsid = application.zcore.status.setStatus(Request.zsid, "Template updated.");
		}
	}
	application.zcore.functions.zRedirect('/z/inquiries/admin/lead-template/index?zsid='&request.zsid);
	</cfscript>
</cffunction>

<!--- 
/z/inquiries/admin/lead-template/fixAdminComments --->
<!--- <cffunction name="fixAdminComments" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("inquiries", request.zos.zcoreDatasource)# 
	WHERE inquiries_admin_comments<>#db.param('')# and 
	site_id <> #db.param(-1)# and 
	inquiries_deleted=#db.param(0)#  ";
	qD=db.execute("qD");
	updateCount=0;
	skipCount=0;
	for(row in qD){
		if(row.inquiries_admin_comments CONTAINS '<p>'){
			skipCount++;
			continue;
		}
		t=application.zcore.functions.zparagraphformat(row.inquiries_admin_comments);  
		db.sql="UPDATE #db.table("inquiries", request.zos.zcoreDatasource)# SET 
		inquiries_admin_comments=#db.param(t)# 
		WHERE inquiries_id=#db.param(row.inquiries_id)# and 
		site_id =#db.param(row.site_id)# and 
		inquiries_deleted=#db.param(0)#  ";
		db.execute("qUpdate"); 
		updateCount++;
	}
	echo(updateCount&" updated | skipCount:"&skipCount);
	abort;
	</cfscript>
</cffunction> --->

<!--- 
<cffunction name="fixLeadTemplates" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	db=request.zos.queryObject;
	db.sql="SELECT * FROM #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# 
	WHERE inquiries_lead_template_message<>#db.param('')# and 
	site_id <> #db.param(-1)# and 
	inquiries_lead_template_deleted=#db.param(0)#  ";
	qD=db.execute("qD");
	updateCount=0;
	skipCount=0;
	for(row in qD){
		if(row.inquiries_lead_template_message CONTAINS '<p>'){
			skipCount++;
			continue;
		}
		t=application.zcore.functions.zparagraphformat(row.inquiries_lead_template_message);  
		db.sql="UPDATE #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# SET 
		inquiries_lead_template_message=#db.param(t)#, 
		inquiries_lead_template_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE inquiries_lead_template_id=#db.param(row.inquiries_lead_template_id)# and 
		site_id =#db.param(row.site_id)# and 
		inquiries_lead_template_deleted=#db.param(0)#  ";
		db.execute("qUpdate"); 
		updateCount++;
	}
	echo(updateCount&" updated | skipCount:"&skipCount);
	abort;
	</cfscript>
</cffunction> --->

<cffunction name="add" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qTypes=0;
	var currentMethod=form.method;
	application.zcore.skin.includeJS("/z/a/scripts/tiny_mce/tinymce.min.js"); 
	variables.init();
	application.zcore.functions.zSetPageHelpId("4.6");
	form.sid=application.zcore.functions.zGetSiteIdFromSiteIdType(application.zcore.functions.zso(form, 'siteIdType',false,1));
	db.sql="
	SELECT * from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template 
	WHERE inquiries_lead_template_id = #db.param(application.zcore.functions.zso(form, 'inquiries_lead_template_id'))# and 
	site_id =#db.param(form.sid)# and 
	inquiries_lead_template_deleted=#db.param(0)# ";
	if(application.zcore.user.checkServerAccess() EQ false){
		db.sql&=" and site_id=#db.param(request.zos.globals.id)# ";
	}
	qTypes=db.execute("qTypes");
	if(qTypes.recordcount EQ 0 and currentMethod EQ 'edit'){
		application.zcore.status.setStatus(request.zsid, 'Lead template doesn''t exist or you don''t have permission to edit it.',false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/lead-template/index?zsid=#request.zsid#');
	}
	application.zcore.functions.zQueryToStruct(qTypes, form);
	application.zcore.functions.zStatusHandler(request.zsid,true);
	if(form.inquiries_lead_template_type EQ ''){
		form.inquiries_lead_template_type=application.zcore.functions.zso(form, 'inquiries_lead_template_type');
	}
	</cfscript>
	<h2>
		<cfif currentMethod EQ 'add'>
			Add
		<cfelse>
			Edit
		</cfif>
		Template</h2>
	Please enter a unique template name.  You can insert &quot;{agent name}&quot; or &quot;{agent's company}&quot; without the quotes to have the system automatically insert those variables into the text based on the agent that is logged in. All templates are shared between all agents.<br />
	<br />
	<table style="width:600px; border-spacing:0px;" class="table-list">
		<form class="zFormCheckDirty" action="/z/inquiries/admin/lead-template/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?inquiries_lead_template_id=#form.inquiries_lead_template_id#&amp;siteIdType=#form.siteIdType#" method="post">
			<tr>
				<th>Type:</th>
				<td><input type="radio" name="inquiries_lead_template_type" value="1" <cfif application.zcore.functions.zso(form, 'inquiries_lead_template_type',true) EQ 1 or application.zcore.functions.zso(form, 'inquiries_lead_template_type',true) EQ 0>checked="checked"</cfif> style="border:none; background:none;" />
					Note
					<input type="radio" name="inquiries_lead_template_type" value="2" <cfif application.zcore.functions.zso(form, 'inquiries_lead_template_type',true) EQ 2>checked="checked"</cfif> style="border:none; background:none;" />
					Email </td>
			</tr>
			<tr>
				<th>Template Name:</th>
				<td><input type="text" name="inquiries_lead_template_name" value="#htmleditformat(form.inquiries_lead_template_name)#" /></td>
			</tr>
			<tr>
				<th>Subject:</th>
				<td><input name="inquiries_lead_template_subject" id="inquiries_lead_template_subject" type="text" size="50" maxlength="50" value="#htmleditformat(form.inquiries_lead_template_subject)#" /></td>
			</tr>
			<tr>
				<th>Message:</th>
				<td><textarea name="inquiries_lead_template_message" id="inquiries_lead_template_message" style="width:100%; height:250px; ">#htmleditformat(form.inquiries_lead_template_message)#</textarea></td>
			</tr>
			<cfif application.zcore.user.checkServerAccess(request.zos.globals.id)>
				<tr>
					<th>Real Estate:</th>
					<td><input type="radio" name="inquiries_lead_template_realestate" value="1" <cfif form.inquiries_lead_template_realestate EQ 1>checked="checked"</cfif> style="border:none; background:none;" />
						Yes
						<input type="radio" name="inquiries_lead_template_realestate" value="0" <cfif application.zcore.functions.zso(form, 'inquiries_lead_template_realestate',true) EQ 0>checked="checked"</cfif> style="border:none; background:none;" />
						No (This will hide it on web sites without request.zos.listing defined.) </td>
				</tr>
				<tr>
					<th>Global:</th>
					<td><input type="radio" name="force_global" value="1" <cfif form.site_id EQ 0 or application.zcore.functions.zso(form, 'force_global',true) EQ 1>checked="checked"</cfif> style="border:none; background:none;" />
						Yes
						<input type="radio" name="force_global" value="0" <cfif form.site_id NEQ 0 and application.zcore.functions.zso(form, 'force_global',true) EQ 0>checked="checked"</cfif> style="border:none; background:none;" />
						No (Only server administrator can set this.) </td>
				</tr>
			</cfif>
			<tr>
				<th>&nbsp;</th>
				<td><button type="submit" name="submitForm" class="z-manager-search-button">
					<cfif currentMethod EQ 'add'>
						Add
					<cfelse>
						Update
					</cfif>
					Template</button>
					<button type="button" name="cancel" class="z-manager-search-button" onclick="window.location.href = '/z/inquiries/admin/lead-template/index';">Cancel</button></td>
			</tr>
		</form>
	</table>

	<script type="text/javascript">
	zArrDeferredFunctions.push( function() {
		tinymce.init({
		  selector: '##inquiries_lead_template_message', 
		  menubar: false,
		  autoresize_min_height: 100,
		  plugins: [
		    'autoresize advlist autolink lists link image charmap print preview anchor textcolor',
		    'searchreplace visualblocks code fullscreen',
		    'insertdatetime media table contextmenu paste code'
		  ],
		  toolbar: 'undo redo |  formatselect | bold italic | alignleft aligncenter alignright alignjustify | link bullist numlist outdent indent | removeformat',
		  content_css: []
		}); 
	});
	</script>
</cffunction>

<cffunction name="hide" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.show();
	</cfscript>
</cffunction>

<cffunction name="show" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var r=0;
	init(); 
	if(form.method EQ 'hide'){
		db.sql="REPLACE INTO #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)#  
		SET inquiries_lead_template_id=#db.param(form.inquiries_lead_template_id)#, 
		inquiries_lead_template_x_site_deleted = #db.param(0)#,
		inquiries_lead_template_x_site_updated_datetime=#db.param(request.zos.mysqlnow)#,
		inquiries_lead_template_x_site_siteidtype=#db.param(form.siteIdType)#, 
		site_id = #db.param(request.zos.globals.id)# ";
		r=db.execute("r");
		application.zcore.status.setStatus(request.zsid,"Lead template is now hidden");
	}else{
		db.sql="DELETE from #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)#  
		WHERE inquiries_lead_template_id=#db.param(form.inquiries_lead_template_id)# and 
		inquiries_lead_template_x_site_siteidtype=#db.param(form.siteIdType)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_lead_template_x_site_deleted=#db.param(0)# ";
		r=db.execute("r");
		application.zcore.status.setStatus(request.zsid,"Lead template is now visible");
	}
	application.zcore.functions.zRedirect("/z/inquiries/admin/lead-template/index?zsid=#request.zsid#");
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject;
	var qTypes=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("4.5");
	</cfscript>
	<cfsavecontent variable="db.sql"> 
	SELECT *, if(inquiries_lead_template_x_site.site_id IS NULL,#db.param(0)#,#db.param(1)#) hideTemplate 
	from #db.table("inquiries_lead_template", request.zos.zcoreDatasource)# inquiries_lead_template
	LEFT JOIN #db.table("inquiries_lead_template_x_site", request.zos.zcoreDatasource)# inquiries_lead_template_x_site ON 
	inquiries_lead_template_x_site.inquiries_lead_template_id = inquiries_lead_template.inquiries_lead_template_id and 
	inquiries_lead_template_x_site_siteidtype=#db.trustedSQL(application.zcore.functions.zGetSiteIdSQL("inquiries_lead_template.site_id"))# and 
	inquiries_lead_template_x_site.site_id = #db.param(request.zos.globals.id)# and 
	inquiries_lead_template_x_site_deleted = #db.param(0)#
	WHERE inquiries_lead_template.site_id IN (#db.param(0)#,#db.param(request.zos.globals.id)#) and 
	inquiries_lead_template_deleted = #db.param(0)# 
	<cfif application.zcore.app.siteHasApp("listing") EQ false>
		and inquiries_lead_template_realestate = #db.param(0)#
	</cfif>
	ORDER BY inquiries_lead_template_name ASC </cfsavecontent>
	<cfscript>
	qTypes=db.execute("qTypes");   
	application.zcore.functions.zStatusHandler(request.zsid);
	</cfscript>
	<h2 style="display:inline; ">Lead Templates </h2>
	<a href="/z/inquiries/admin/lead-template/add?siteIDType=1" class="z-manager-search-button">Add</a>
	<a href="/z/inquiries/admin/manage-inquiries/index" class="z-manager-search-button">Back to Leads</a> <br />
	<br />
	All templates are shared between all agents.<br />
	<br />
	<table style="border-spacing:0px;" class="table-list">
		<tr>
			<th>Name</th>
			<th>Type</th>
			<th>Admin</th>
		</tr>
		<cfloop query="qTypes">
			<cfscript>
			form.siteIdType=application.zcore.functions.zGetSiteIDType(qTypes.site_id);
			</cfscript>
			<tr <cfif qTypes.currentRow mod 2 EQ 0>style="background-color:##EEEEEE;"</cfif>>
				<td>#qTypes.inquiries_lead_template_name#</td>
				<td><cfif qTypes.inquiries_lead_template_type EQ 1>
						Note
					<cfelse>
						Email
					</cfif></td>
				<td class="z-manager-admin">
					<cfif qTypes.hideTemplate EQ 0>
						<div class="z-manager-button-container">
							<a href="/z/inquiries/admin/lead-template/hide?inquiries_lead_template_id=#qTypes.inquiries_lead_template_id#&amp;siteIDType=#form.siteIdType#" class="z-manager-view" title="Visible, click to hide"><i class="fa fa-check-circle" aria-hidden="true" style="color:##090;"></i></a> 
						</div>
					<cfelse>
						<div class="z-manager-button-container">
							<a href="/z/inquiries/admin/lead-template/show?inquiries_lead_template_id=#qTypes.inquiries_lead_template_id#&amp;siteIDType=#form.siteIdType#" class="z-manager-view" title="Hidden, click to show"><i class="fa fa-times-circle" aria-hidden="true" style="color:##900;"></i></a> 
						</div>
					</cfif>
 

					<cfif qTypes.site_id NEQ 0 or application.zcore.user.checkServerAccess(request.zos.globals.id)>
						<div class="z-manager-button-container">
							<a href="/z/inquiries/admin/lead-template/edit?inquiries_lead_template_id=#qTypes.inquiries_lead_template_id#&amp;siteIDType=#form.siteIdType#" class="z-manager-edit" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
						</div>
						<div class="z-manager-button-container">
							<a href="/z/inquiries/admin/lead-template/delete?inquiries_lead_template_id=#qTypes.inquiries_lead_template_id#&amp;siteIDType=#form.siteIdType#" class="z-manager-delete" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></a>
						</div>
					<cfelse>
						<!--- <div class="z-manager-button-container">
							Delete disabled
						</div> --->
					</cfif>
				</td>
			</tr>
		</cfloop>
	</table>
</cffunction>
</cfoutput>
</cfcomponent>
