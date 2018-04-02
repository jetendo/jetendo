<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="administrator">
	<cfscript>
		application.zcore.adminSecurityFilter.requireFeatureAccess("Lead Autoresponders");

		variables.queueSortStruct = StructNew();
		// required
		variables.queueSortStruct.tableName = "inquiries_autoresponder_drip";
		variables.queueSortStruct.sortFieldName = "inquiries_autoresponder_drip_sort";
		variables.queueSortStruct.primaryKeyName = "inquiries_autoresponder_drip_id";
		// optional 
		variables.queueSortStruct.datasource=request.zos.zcoreDatasource; 
		variables.queueSortWhere="site_id = '#application.zcore.functions.zescape(request.zos.globals.id)#' and inquiries_autoresponder_id=#application.zcore.functions.zescape(form.inquiries_autoresponder_id)# and inquiries_autoresponder_drip_deleted=0 ";
		variables.queueSortStruct.where = variables.queueSortWhere&"  ";
		variables.queueSortStruct.disableRedirect=true;

		variables.queueSortStruct.ajaxTableId='sortRowTable';
		variables.queueSortStruct.ajaxURL='/z/inquiries/admin/autoresponder-drips/#form.method#?inquiries_autoresponder_id=#urlencodedformat(form.inquiries_autoresponder_id)#';
		
		variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
		variables.queueSortCom.init(variables.queueSortStruct);

		if ( structKeyExists( form, 'zQueueSort' ) ) {
			application.zcore.functions.zMenuClearCache( { content = true } );
			application.zcore.functions.zredirect( '/z/inquiries/admin/autoresponder-drips/index?' & replaceNoCase( request.zos.cgi.query_string, 'zQueueSort=', 'ztv=', 'all' ) );
		}
		if ( structKeyExists( form, 'zQueueSortAjax' ) ) {
			application.zcore.functions.zMenuClearCache( { content = true } );
			variables.queueSortCom.returnJson();
		}
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject; 
	init();  

	form.mode=application.zcore.functions.zso(form, 'mode', false, 'sorting');

	qSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.querySort");

	form.zPageId = qSortCom.init("zPageId");
	form.zLogIndex = application.zcore.status.getField(form.zPageId, "zLogIndex", 1, true);

	db.sql="SELECT * 
	from #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)# , 
	#db.table("inquiries_type", request.zos.zcoreDatasource)# 
	WHERE 
	inquiries_type.inquiries_type_id = inquiries_autoresponder.inquiries_type_id and 
	inquiries_type.site_id = #db.trustedSQL(application.zcore.functions.zGetSiteIdTypeSQL("inquiries_autoresponder.inquiries_type_id_siteidtype"))# and 
	inquiries_autoresponder.site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_deleted = #db.param(0)# and 
	inquiries_autoresponder_id=#db.param(form.inquiries_autoresponder_id)# and 
	inquiries_type_deleted = #db.param(0)# 
	ORDER BY inquiries_type_name ASC ";
	qAutoresponder=db.execute("qAutoresponder"); 
	if(qAutoresponder.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "The selected autoresponder doesn't exist.", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder-drips/index?zsid=#request.zsid#");
	}

	var hCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.inquiriesFunctions");
	hCom.displayHeader();
	application.zcore.functions.zStatusHandler(request.zsid); 
 	searchOn=false; 
	db.sql="SELECT * 
	from #db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)#
	WHERE 
	inquiries_autoresponder_drip.inquiries_autoresponder_id = #db.param( form.inquiries_autoresponder_id )# and 
	inquiries_autoresponder_drip.site_id = inquiries_autoresponder_drip.site_id and
	inquiries_autoresponder_drip.site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_drip.inquiries_autoresponder_drip_deleted = #db.param(0)# and 
	inquiries_autoresponder_drip.inquiries_autoresponder_drip_deleted = #db.param(0)# 
	ORDER BY inquiries_autoresponder_drip.inquiries_autoresponder_drip_sort ASC ";
	qAutoresponderDrip=db.execute("qAutoresponderDrip"); 
	</cfscript>

	<p><a href="/z/inquiries/admin/autoresponder/index">Autoresponders</a> /  	</p>
	<h2 style="display:inline-block;">Drip Emails For Autoresponder</h2> &nbsp;&nbsp;
	<a href="/z/inquiries/admin/autoresponder-drips/add?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#" class="z-manager-search-button">Add</a>
	<br> 
	<h3>Lead Type: #qAutoresponder.inquiries_type_name#</h3>
	<h3>Autoresponder Subject: #qAutoresponder.inquiries_autoresponder_subject#</h3>
	<p>Drip emails are sent in sequence with specified time delays measured in ## of days.  Each subscriber receives these emails on their own schedule relative to when they signed up.</p>
	<p>Note: If you wish to further customize how drip autoresponders work, please contact your web developer.</p> 
 
	<cfif qAutoresponderDrip.recordcount EQ 0>
		<p>No drip emails found.</p>
	<cfelse> 
		<table <cfif form.mode EQ "sorting">id="sortRowTable"</cfif> class="table-list">
			<thead>
				<tr>
					<th>ID</th>
					<th>Subject</th>  
					<th>Days to Wait</th>
					<th>Updated Date</th>  
					<th>Active</th>  
					<cfif form.mode EQ "sorting">
						<cfif application.zcore.functions.zso(form, 'searchtext') EQ '' and qsortcom.getorderby(false) EQ ''>
							<th style="width:60px;">
								Sort 
							</th>
						</cfif>
					</cfif>
					<th>Admin</th>
				</tr>
			</thead>
			<tbody>
				<cfloop query="qAutoresponderDrip">
					<tr <cfif form.mode EQ "sorting">#variables.queueSortCom.getRowHTML(qAutoresponderDrip.inquiries_autoresponder_drip_id)#</cfif> <cfif qAutoresponderDrip.currentRow MOD 2 EQ 0>class="row2"<cfelse>class="row1"</cfif> >
						<td>#qAutoresponderDrip.inquiries_autoresponder_drip_id#</td> 
						<td>#qAutoresponderDrip.inquiries_autoresponder_drip_subject#</td> 
						<td>#qAutoresponderDrip.inquiries_autoresponder_drip_days_to_wait# days</td> 
						<td>#dateformat(qAutoresponderDrip.inquiries_autoresponder_drip_updated_datetime, "m/d/yy")#</td>
						<td><cfif qAutoresponderDrip.inquiries_autoresponder_drip_active EQ 1>Yes<cfelse>No</cfif></td>
						<cfif form.mode EQ "sorting">
							<cfif application.zcore.functions.zso(form, 'searchtext') EQ '' and qsortcom.getorderby(false) EQ ''> 
								<td style="vertical-align:top; white-space:nowrap;" >
								#variables.queueSortCom.getAjaxHandleButton(qAutoresponderDrip.inquiries_autoresponder_drip_id)#
								</td>
							</cfif>
						</cfif>
						<td class="z-manager-admin">

							<div class="z-manager-button-container"> 
								<a href="##" class="z-manager-edit" id="z-manager-edit#qAutoresponderDrip.inquiries_autoresponder_drip_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
								<div class="z-manager-edit-menu">
									<a href="/z/inquiries/admin/autoresponder-drips/edit?inquiries_autoresponder_drip_id=#qAutoresponderDrip.inquiries_autoresponder_drip_id#&inquiries_autoresponder_id=#qAutoresponderDrip.inquiries_autoresponder_id#">Edit</a>
									<a href="/z/inquiries/admin/autoresponder-drips/test?inquiries_autoresponder_drip_id=#qAutoresponderDrip.inquiries_autoresponder_drip_id#&inquiries_autoresponder_id=#form.inquiries_autoresponder_id#">Test Drip Email</a> 
								</div>
							</div>
							<div class="z-manager-button-container">
								<a href="/z/inquiries/admin/autoresponder-drips/delete?inquiries_autoresponder_drip_id=#qAutoresponderDrip.inquiries_autoresponder_drip_id#&inquiries_autoresponder_id=#qAutoresponderDrip.inquiries_autoresponder_id#" onclick="return window.confirm('Are you sure you want to remove this drip email?');" class="z-manager-delete" title="Delete"><i class="fa fa-trash" aria-hidden="true"></i></a> 
							</div>  
						</td>
					</tr>
				</cfloop>
			</tbody>
		</table> 
	</cfif>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	var db=request.zos.queryObject; 
	var currentMethod=form.method; 

	var inquiries_autoresponder_id = form.inquiries_autoresponder_id;

	if(application.zcore.functions.zso(form,'inquiries_autoresponder_drip_id') EQ ''){
		form.inquiries_autoresponder_drip_id = -1;
	}
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)# inquiries_autoresponder_drip 
	WHERE  
	inquiries_autoresponder_drip_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_drip_id=#db.param(form.inquiries_autoresponder_drip_id)#";
	qAutoresponderDrip=db.execute("qAutoresponderDrip");
	application.zcore.functions.zQueryToStruct(qAutoresponderDrip, form, 'inquiries_autoresponder_id');
	application.zcore.functions.zStatusHandler(request.zsid,true);

	if(form.inquiries_autoresponder_drip_active EQ ""){
		form.inquiries_autoresponder_drip_active=1;
	}
	</cfscript>
	<h2><cfif currentMethod EQ "add">
		Add
		<cfscript>
		application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
		</cfscript>
	<cfelse>
		Edit
	</cfif>
	Drip Email</h2>

	<cfscript>
	tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
			tabCom.init();
	tabCom.setTabs(["Basic"]);
	tabCom.setMenuName("admin-list"); 
	cancelURL="/z/inquiries/admin/autoresponder-drips/index?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#"; 
	tabCom.setCancelURL(cancelURL);
	tabCom.enableSaveButtons();

	variableStruct={
		firstName:"John",
		interestedInModel:"Model",
		email:"test@test.com"
	};

	if(structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'getAutoresponderTemplate')){
		rs=application.sitestruct[request.zos.globals.id].zcorecustomfunctions.getAutoresponderTemplate({inquiries_type_name:''});
		if(structkeyexists(rs, 'defaultStruct')){
			structappend(variableStruct, rs.defaultStruct, true);
		}
	}
	
	</cfscript>

	<p>Be sure to use a simple one column plain text layout with no embedded assets to ensure users can read your content in any email client.  Colors/tables/videos/images may fail to load in an autoresponder.  Be sure to test the autoresponder after you make changes to it.</p>
	<p>The following variables can be included in the Body text. They will be replaced with the user's personal information when the autoresponder is sent.</p>
	<p>If the data for the variable is not available, a default value will be shown such as "Customer" for %firstName%</p>
	<ul>
		<cfscript>
		arrKey=structkeyarray(variableStruct);
		arraySort(arrKey, "text", "asc");
		for(field in arrKey){
			echo('<li>%#field#%</li>');
		}
		</cfscript>
	</ul>
	<p>If you need to insert a literal percent sign in the email, like 100%, you must type it twice so that it is not removed.  For example: 100%%.</p>
	<p>%unsubscribeLink% can be inserted into the Link URL in the Footer HTML or it will be added automatically to the bottom of the email.</p>
	<p>* denotes required field</p>
	<form id="listForm1" action="/z/inquiries/admin/autoresponder-drips/<cfif currentMethod EQ 'add'>insert<cfelse>update</cfif>?inquiries_autoresponder_id=#inquiries_autoresponder_id#&inquiries_autoresponder_drip_id=#form.inquiries_autoresponder_drip_id#" method="post" enctype="multipart/form-data">
	#tabCom.beginTabMenu()#
	#tabCom.beginFieldSet("Basic")#

	<table style="width:100%;" class="table-list">  
		<tr>
			<th>Subject *</th>
			<td><input type="text" name="inquiries_autoresponder_drip_subject" id="inquiries_autoresponder_drip_subject" value="#htmleditformat(form.inquiries_autoresponder_drip_subject)#" /></td>
		</tr>
		<tr>
			<th>From Address</th>
			<td><input type="text" name="inquiries_autoresponder_drip_from" id="inquiries_autoresponder_drip_from" value="#htmleditformat(form.inquiries_autoresponder_drip_from)#" /><br />(will default to autoresponder from address or &lt;#request.officeEmail#&gt; if both left empty)</td>
		</tr>
		<tr>
			<th>Days to Wait *</th>
			<td>
				<cfscript>
					ts=StructNew();
					ts.label="";
					ts.name="inquiries_autoresponder_drip_days_to_wait";
					ts.style="width: 50px; min-width: auto;";
					ts.className="";
					ts.multiline=false;
					ts.size=20;
					ts.maxlength=3;
					ts.allowNull=false;
					ts.email=false;
					ts.required=true;
					ts.number=true;
					ts.output=true;
					ts.onkeyup="";
					ts.onchange="";
					ts.defaultValue="";
					application.zcore.functions.zInput_Text(ts);
				</cfscript> (days to wait after last email was sent)
			</td>
		</tr>
		<tr>
			<th>Header Image</th>
			<td>
				#application.zcore.functions.zInputImage('inquiries_autoresponder_drip_header_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.autoresponderImagePath,1,1), request.zos.globals.siteroot&request.zos.autoresponderImagePath)#<br><br>
				Maximum size is 650x2000.
			</td>
		</tr>
		<tr>
			<th>Header Link</th>
			<td>
				<cfscript>
					ts=StructNew();
					ts.label="";
					ts.name="inquiries_autoresponder_drip_header_link";
					ts.style="";
					ts.className="";
					ts.multiline=false;
					ts.size=20;
					ts.maxlength=255;
					ts.allowNull=false;
					ts.email=false;
					ts.required=true;
					ts.number=false;
					ts.output=true;
					ts.onkeyup="";
					ts.onchange="";
					ts.defaultValue="";
					application.zcore.functions.zInput_Text(ts);
				</cfscript>
			</td>
		</tr>
		<tr>
			<th>Main Image</th>
			<td> 
				#application.zcore.functions.zInputImage('inquiries_autoresponder_drip_main_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.autoresponderImagePath,1,1), request.zos.globals.siteroot&request.zos.autoresponderImagePath)#<br><br>
				Maximum size is 650x2000. </td>
		</tr>
		<tr>
			<th>Main Image Link</th>
			<td>
				<cfscript>
					ts=StructNew();
					ts.label="";
					ts.name="inquiries_autoresponder_drip_main_link";
					ts.style="";
					ts.className="";
					ts.multiline=false;
					ts.size=20;
					ts.maxlength=255;
					ts.allowNull=false;
					ts.email=false;
					ts.required=true;
					ts.number=false;
					ts.output=true;
					ts.onkeyup="";
					ts.onchange="";
					ts.defaultValue="";
					application.zcore.functions.zInput_Text(ts);
				</cfscript>
			</td>
		</tr>
		<tr>
			<th>Body *</th>
			<td>
				<p><cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.html-editor");
				htmlEditor.instanceName	= "inquiries_autoresponder_drip_body_content";
				htmlEditor.value			= form.inquiries_autoresponder_drip_body_content;
				htmlEditor.basePath		= '/';
				htmlEditor.width			= "100%";
				htmlEditor.height		= 300;
				htmlEditor.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
				htmlEditor.create();
				</cfscript></p>
			</td>
		</tr>
		<tr>
			<th>Footer Image</th>
			<td>
				#application.zcore.functions.zInputImage('inquiries_autoresponder_drip_footer_image', application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.autoresponderImagePath,1,1), request.zos.globals.siteroot&request.zos.autoresponderImagePath)#<br><br>
				Maximum size is 650x2000.
			</td>
		</tr>
		<tr>
			<th>Footer Image Link</th>
			<td>
				<cfscript>
					ts=StructNew();
					ts.label="";
					ts.name="inquiries_autoresponder_drip_footer_link";
					ts.style="";
					ts.className="";
					ts.multiline=false;
					ts.size=20;
					ts.maxlength=255;
					ts.allowNull=false;
					ts.email=false;
					ts.required=true;
					ts.number=false;
					ts.output=true;
					ts.onkeyup="";
					ts.onchange="";
					ts.defaultValue="";
					application.zcore.functions.zInput_Text(ts);
				</cfscript>
			</td>
		</tr>
		<tr>
			<th>Footer Text</th>
			<td>
				<p><cfscript>
				htmlEditor = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.app.html-editor");
				htmlEditor.instanceName	= "inquiries_autoresponder_drip_footer_text";
				htmlEditor.value			= form.inquiries_autoresponder_drip_footer_text;
				htmlEditor.basePath		= '/';
				htmlEditor.width			= "100%";
				htmlEditor.height		= 300;
				htmlEditor.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
				htmlEditor.create();
				</cfscript></p>
			</td>
		</tr>




		<!--- <tr>
			<th>Text Version</th>
			<td><textarea type="text" cols="50" rows="5" name="inquiries_autoresponder_text" id="inquiries_autoresponder_text">#htmleditformat(form.inquiries_autoresponder_text)#</textarea></td>
		</tr> --->
		<tr>
			<th>Active</th>
			<td><!--- No <input type="hidden" name="inquiries_autoresponder_drip_active" value="0">  --->
				#application.zcore.functions.zInput_Boolean("inquiries_autoresponder_drip_active")# <!--- --->
			</td>
		</tr> 
	</table> 
	#tabCom.endFieldSet()#  
	#tabCom.endTabMenu()#    
	</form>

</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	this.update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	db=request.zos.queryObject;
	var ts={}; 
	init(); 

	ts.inquiries_autoresponder_drip_subject.required=true;
	ts.inquiries_autoresponder_drip_days_to_wait.required=true;
	ts.inquiries_autoresponder_drip_body_content.required=true;
	error = application.zcore.functions.zValidateStruct(form, ts, Request.zsid,true);

	form.inquiries_autoresponder_drip_days_to_wait=application.zcore.functions.zso(form, 'inquiries_autoresponder_drip_days_to_wait', true);
	if(form.inquiries_autoresponder_drip_days_to_wait LTE 0){
		application.zcore.status.setStatus(request.zsid, "Days to wait must be 1 or more.", form, true);
		error=true;
	}
	if(error){	
		application.zcore.status.setStatus(Request.zsid, false,form,true);
		if(form.method EQ 'insert'){
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder-drips/add?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#');
		}else{
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder-drips/edit?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#');
		}
	}  

	form.inquiries_autoresponder_drip_header_link=request.zos.originalFormScope.inquiries_autoresponder_drip_header_link;
	form.inquiries_autoresponder_drip_footer_link=request.zos.originalFormScope.inquiries_autoresponder_drip_footer_link;
	form.inquiries_autoresponder_drip_main_link=request.zos.originalFormScope.inquiries_autoresponder_drip_main_link;

	application.zcore.functions.zCreateDirectory(request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath, 1, 1));

	// Main image
	StructDelete(variables,'inquiries_autoresponder_drip_main_image');
	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("inquiries_autoresponder_drip_main_image", application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.autoresponderImagePath,1,1), '650x2000');
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("inquiries_autoresponder_drip_main_image", application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.autoresponderImagePath,1,1), '650x2000', 'user', 'user_id', "inquiries_autoresponder_drip_main_image_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'inquiries_autoresponder_drip_main_image');
		StructDelete(variables,'inquiries_autoresponder_drip_main_image');
	}else if(ArrayLen(arrList) NEQ 0){
		form.inquiries_autoresponder_drip_main_image=arrList[1];
	}else{
		StructDelete(form,'inquiries_autoresponder_drip_main_image');
	}
	if(application.zcore.functions.zso(form,'inquiries_autoresponder_drip_main_image_delete',true) EQ 1){
		form.inquiries_autoresponder_drip_main_image='';	
	}

	// Header image
	StructDelete(variables,'inquiries_autoresponder_drip_header_image');
	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("inquiries_autoresponder_drip_header_image", application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.autoresponderImagePath,1,1), '650x2000');
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("inquiries_autoresponder_drip_header_image", application.zcore.functions.zVar('privatehomedir')&removechars(request.zos.autoresponderImagePath,1,1), '650x2000', 'user', 'user_id', "inquiries_autoresponder_drip_header_image_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'inquiries_autoresponder_drip_header_image');
		StructDelete(variables,'inquiries_autoresponder_drip_header_image');
	}else if(ArrayLen(arrList) NEQ 0){
		form.inquiries_autoresponder_drip_header_image=arrList[1];
	}else{
		StructDelete(form,'inquiries_autoresponder_drip_header_image');
	}
	if(application.zcore.functions.zso(form,'inquiries_autoresponder_drip_header_image_delete',true) EQ 1){
		form.inquiries_autoresponder_drip_header_image='';	
	}

	// Footer image
	StructDelete(variables,'inquiries_autoresponder_drip_footer_image');
	arrList=ArrayNew(1);
	if(form.method EQ 'insert'){
		arrList = application.zcore.functions.zUploadResizedImagesToDb("inquiries_autoresponder_drip_footer_image", request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath,1,1), '650x2000');
	}else{
		arrList = application.zcore.functions.zUploadResizedImagesToDb("inquiries_autoresponder_drip_footer_image", request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath,1,1), '650x2000', 'user', 'user_id', "inquiries_autoresponder_drip_footer_image_delete",request.zos.zcoreDatasource);
	}
	if(isarray(arrList) EQ false){
		application.zcore.status.setStatus(request.zsid, '<strong>PHOTO ERROR:</strong> invalid format or corrupted.  Please upload a small to medium size JPEG (i.e. a file that ends with ".jpg").');	
		StructDelete(form,'inquiries_autoresponder_drip_footer_image');
		StructDelete(variables,'inquiries_autoresponder_drip_footer_image');
	}else if(ArrayLen(arrList) NEQ 0){
		form.inquiries_autoresponder_drip_footer_image=arrList[1];
	}else{
		StructDelete(form,'inquiries_autoresponder_drip_footer_image');
	}
	if(application.zcore.functions.zso(form,'inquiries_autoresponder_drip_footer_image_delete',true) EQ 1){
		form.inquiries_autoresponder_drip_footer_image='';	
	}

	form.inquiries_autoresponder_drip_deleted=0;
	form.inquiries_autoresponder_drip_updated_datetime=request.zos.mysqlnow;
	form.site_id=request.zos.globals.id;
	ts=StructNew();
	ts.table='inquiries_autoresponder_drip';
	ts.datasource=request.zos.zcoreDatasource;
	ts.datasource=request.zos.zcoreDatasource;
	ts.struct=form;
 
	if(form.method EQ 'insert'){
		form.inquiries_autoresponder_drip_id = application.zcore.functions.zInsert(ts);

		if(form.inquiries_autoresponder_drip_id EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to create autoresponder drip.',form,true);
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder-drips/add?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#');
		}else{
			variables.queueSortCom.init( variables.queueSortStruct );
			variables.queueSortCom.sortAll();

			application.zcore.status.setStatus(request.zsid, 'Autoresponder drip created.'); 
		}
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, 'Failed to save autoresponder drip.',form,true);
			application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder-drips/edit?inquiries_autoresponder_drip_id=#form.inquiries_autoresponder_drip_id#&zsid=#request.zsid#');
		}else{
			variables.queueSortCom.init( variables.queueSortStruct );
			variables.queueSortCom.sortAll();

			application.zcore.status.setStatus(request.zsid, 'Autoresponder drip updated.');
		} 
	} 
	db.sql="select * from #db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)# WHERE 
	inquiries_autoresponder_drip_deleted=#db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_drip_id=#db.param(form.inquiries_autoresponder_drip_id)# ";
	qAutoresponder=db.execute("qAutoresponder");
	imageChanged=false;
	if(qAutoresponder.inquiries_autoresponder_drip_footer_image NEQ ""){
		footerNew=qAutoresponder.inquiries_autoresponder_drip_id&"_footer.jpg";
		footerFilePath=request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath,1,1)&qAutoresponder.inquiries_autoresponder_drip_footer_image;
		footerNewFilePath=request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath,1,1)&qAutoresponder.inquiries_autoresponder_drip_id&"_footer.jpg";
		if(footerFilePath NEQ footerNewFilePath){
			if(fileexists(footerFilePath)){
				if(fileexists(footerNewFilePath)){
					application.zcore.functions.zDeleteFile(footerNewFilePath);
				}
				application.zcore.functions.zRenameFile(footerFilePath, footerNewFilePath);
				imageChanged=true;
			}
		}
	}else{
		footerNew="";
	}
	if(qAutoresponder.inquiries_autoresponder_drip_header_image NEQ ""){
		headerNew=qAutoresponder.inquiries_autoresponder_drip_id&"_header.jpg";
		headerFilePath=request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath,1,1)&qAutoresponder.inquiries_autoresponder_drip_header_image;
		headerNewFilePath=request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath,1,1)&qAutoresponder.inquiries_autoresponder_drip_id&"_header.jpg";
		if(headerFilePath NEQ headerNewFilePath){
			if(fileexists(headerFilePath)){
				if(fileexists(headerNewFilePath)){
					application.zcore.functions.zDeleteFile(headerNewFilePath);
				}
				application.zcore.functions.zRenameFile(headerFilePath, headerNewFilePath);
				imageChanged=true;
			}
		}
	}else{
		headerNew="";
	}
	if(qAutoresponder.inquiries_autoresponder_drip_main_image NEQ ""){
		mainNew=qAutoresponder.inquiries_autoresponder_drip_id&"_main.jpg";
		mainFilePath=request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath,1,1)&qAutoresponder.inquiries_autoresponder_drip_main_image;
		mainNewFilePath=request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath,1,1)&qAutoresponder.inquiries_autoresponder_drip_id&"_main.jpg";
		if(mainFilePath NEQ mainNewFilePath){
			if(fileexists(mainFilePath)){
				if(fileexists(mainNewFilePath)){
					application.zcore.functions.zDeleteFile(mainNewFilePath);
				}
				application.zcore.functions.zRenameFile(mainFilePath, mainNewFilePath);
				imageChanged=true;
			}
		}
	}else{
		mainNew="";
	} 
	if(imageChanged){
		db.sql="update #db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)# SET 
		inquiries_autoresponder_drip_footer_image=#db.param(footerNew)#, 
		inquiries_autoresponder_drip_header_image=#db.param(headerNew)#, 
		inquiries_autoresponder_drip_main_image=#db.param(mainNew)#, 
		inquiries_autoresponder_drip_updated_datetime=#db.param(request.zos.mysqlnow)# 
		WHERE 
		inquiries_autoresponder_drip_deleted=#db.param(0)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		inquiries_autoresponder_drip_id=#db.param(form.inquiries_autoresponder_drip_id)# ";
		db.execute("qUpdate"); 
	}
	application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder-drips/index?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#');
	</cfscript>
</cffunction>

<cffunction name="test" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	var db=request.zos.queryObject;  
	form.email=application.zcore.functions.zso(form, 'email');
	form.officeId=application.zcore.functions.zso(form, 'officeId');
	form.interestedInModel=application.zcore.functions.zso(form, 'interestedInModel');
	form.format=application.zcore.functions.zso(form, 'format', true, 1);
	if(application.zcore.functions.zso(form,'inquiries_autoresponder_drip_id') EQ ''){
		form.inquiries_autoresponder_drip_id = -1;
	}

	db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#
	WHERE
	inquiries_autoresponder_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_id=#db.param(form.inquiries_autoresponder_id)#";
	qAutoresponder=db.execute("qAutoresponder");

	if ( qAutoresponder.recordcount EQ 0 ) {
		throw( 'Autoresponder does not exist.' );
	}
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)#  
	WHERE  
	inquiries_autoresponder_drip_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_drip_id=#db.param(form.inquiries_autoresponder_drip_id)#";
	qAutoresponderDrip=db.execute("qAutoresponderDrip");

	if ( qAutoresponderDrip.recordcount EQ 0 ) {
		throw( 'Autoresponder drip does not exist.' );
	}

	application.zcore.functions.zQueryToStruct(qAutoresponderDrip);
	application.zcore.functions.zStatusHandler(request.zsid,true); 

	fromEmail = qAutoresponderDrip.inquiries_autoresponder_drip_from;

	if ( fromEmail EQ '' ) {
		fromEmail = qAutoresponder.inquiries_autoresponder_from;
	}

	if ( fromEmail EQ '' ) {
		fromEmail = request.officeEmail;
	}
	</cfscript>
	<p><a href="/z/inquiries/admin/autoresponder/index">Autoresponders</a> / <a href="/z/inquiries/admin/autoresponder-drips/index?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#">Autoresponder: #qAutoresponder.inquiries_autoresponder_subject#</a> / </p>
	<h2>Test Autoresponder Drip</h2>
	<p>You can preview the autoresponder drip by sending it to your email address with this form.</p>
	<p>If the variables fail to insert during testing, there may be html tags in between the % and the keyword which must be manually fixed in the code.</p>
	<p>Subject: #form.inquiries_autoresponder_drip_subject#</p>
	<p>From: #fromEmail#</p>

	<h2>Send Test Email</h2>
	<form action="/z/inquiries/admin/autoresponder-drips/sendTest" method="get">
		<input type="hidden" name="inquiries_autoresponder_id" value="#htmleditformat(form.inquiries_autoresponder_id)#">
		<input type="hidden" name="inquiries_autoresponder_drip_id" value="#htmleditformat(form.inquiries_autoresponder_drip_id)#">
		<p>Office ID: <input type="text" name="officeId" id="officeId" style="width:500px; max-width:100%;" value="#htmleditformat(form.officeId)#"></p>
		<p>Interested In Model: <input type="text" name="interestedInModel" id="interestedInModel" style="width:500px; max-width:100%;" value="#htmleditformat(form.interestedInModel)#"></p>
		<p>Your Email: <input type="text" name="email" id="email" style="width:500px; max-width:100%;" value="#htmleditformat(form.email)#"></p>
		<!--- <p>HTML Format? #application.zcore.functions.zInput_Boolean("format")#</p> --->
		<p><input type="submit" name="Submit1" value="Send" class="z-manager-search-button"> 
		<input type="button" name="preview" value="Preview" class="z-manager-search-button" onclick="window.location.href='/z/inquiries/admin/autoresponder-drips/test?inquiries_autoresponder_drip_id=#form.inquiries_autoresponder_drip_id#&amp;inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&amp;officeId='+escape($('##officeId').val())+'&amp;interestedInModel='+escape($('##interestedInModel').val());">
		<input type="button" name="cancel" value="Cancel" class="z-manager-search-button" onclick="window.location.href='/z/inquiries/admin/autoresponder-drips/index?inquiries_autoresponder_id=#form.inquiries_autoresponder_id#';"></p>
	</form>
 
	<h2>or Preview as HTML below</h2> 
	<cfscript>
	for ( row in qAutoresponder ) {
		autoresponder = row;
	}

	for ( row in qAutoresponderDrip ) {
		autoresponderDrip = row;
	}
	if(form.interestedInModel EQ ""){
		form.interestedInModel=autoresponder.inquiries_autoresponder_interested_in_model;
	}


	ts={
		// required
		inquiries_type_id: autoresponder.inquiries_type_id,
		inquiries_type_id_siteidtype: autoresponder.inquiries_type_id_siteidtype,
		inquiries_autoresponder_id: autoresponderDrip.inquiries_autoresponder_id,
		inquiries_autoresponder_drip_id: autoresponderDrip.inquiries_autoresponder_drip_id,
		to: request.officeEmail,
		from: request.officeEmail,
		dataStruct: {
			firstName: "John",
			lastName: "Doe",
			interestedInModel: form.interestedInModel,
			officeId:form.officeId,
			email: request.officeEmail
		},
		layoutStruct: {
			headerHTML: this.getHeaderHTML( autoresponderDrip ),
			mainHTML: this.getMainHTML( autoresponderDrip ),
			footerHTML: this.getFooterHTML( autoresponderDrip ),
			footerTextHTML: this.getFooterTextHTML( autoresponderDrip )
		},
		preview: true
		// optional
		//cc:""
	};
	rs=sendAutoresponderDrip(ts);
	if(rs.success){
		echo('<p>Subject: #rs.data.subject#</p><hr>');

		// convert to absolute links
		echo(rs.data.html);
	}else{
		echo('Failed to generate preview');
	}
	</cfscript>


</cffunction> 

<cffunction name="sendTest" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
	var db=request.zos.queryObject; 
	form.email=application.zcore.functions.zso(form, 'email');
	form.officeId=application.zcore.functions.zso(form, 'officeId');
	form.interestedInModel=application.zcore.functions.zso(form, 'interestedInModel');
	form.format=application.zcore.functions.zso(form, 'format', true, 1);
 	form.inquiries_autoresponder_id=application.zcore.functions.zso(form, 'inquiries_autoresponder_id');
 	form.inquiries_autoresponder_drip_id=application.zcore.functions.zso(form, 'inquiries_autoresponder_drip_id');

 	if(not application.zcore.functions.zEmailValidate(form.email)){
		application.zcore.status.setStatus(request.zsid, "You must enter a valid email.", form, true);
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder-drips/test?inquiries_autoresponder_drip_id=#form.inquiries_autoresponder_drip_id#&inquiries_autoresponder_id=#form.inquiries_autoresponder_id#&zsid=#request.zsid#");
 	}

	db.sql="SELECT * FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#
	WHERE
	inquiries_autoresponder_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_id=#db.param(form.inquiries_autoresponder_id)#";
	qAutoresponder=db.execute("qAutoresponder");

	db.sql="SELECT * FROM #db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)# 
	WHERE  
	inquiries_autoresponder_drip_deleted = #db.param(0)# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_drip_id=#db.param(form.inquiries_autoresponder_drip_id)#";
	qAutoresponderDrip=db.execute("qAutoresponderDrip");
	if(qAutoresponderDrip.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Autoresponder drip doesn't exist.");
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder-drips/index?zsid=#request.zsid#");
	}

	for ( row in qAutoresponder ) {
		autoresponder = row;
	}

	for ( row in qAutoresponderDrip ) {
		autoresponderDrip = row;
	}

	if(qAutoresponder.inquiries_autoresponder_from NEQ ""){
		fromEmail=qAutoresponder.inquiries_autoresponder_from;
	}
	if(qAutoresponderDrip.inquiries_autoresponder_drip_from NEQ ""){
		fromEmail=qAutoresponderDrip.inquiries_autoresponder_drip_from;
	} 

	if ( fromEmail EQ '' ) {
		fromEmail = request.officeEmail;
	}

	ts={
		// required
		inquiries_type_id:autoresponder.inquiries_type_id,
		inquiries_type_id_siteidtype:autoresponder.inquiries_type_id_siteidtype,
		inquiries_autoresponder_id:autoresponderDrip.inquiries_autoresponder_id,
		inquiries_autoresponder_drip_id:autoresponderDrip.inquiries_autoresponder_drip_id,
		to:form.email,
		from: fromEmail,
		dataStruct:{
			firstName:"John",
			lastName:"Doe",
			interestedInModel: form.interestedInModel,
			officeId:form.officeId,
			email:request.zos.developerEmailTo
		},
		layoutStruct:{
			headerHTML: this.getHeaderHTML( autoresponderDrip ),
			mainHTML: this.getMainHTML( autoresponderDrip ),
			footerHTML: this.getFooterHTML( autoresponderDrip ),
			footerTextHTML: this.getFooterTextHTML( autoresponderDrip )
		},
		preview:false,
		forceSend:true
		// optional
		//cc:""
	};
	rs=sendAutoresponderDrip(ts);
	if(rs.success EQ false){ 
		application.zcore.status.setStatus(request.zsid, "Autoresponder drip test failed");
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder-drips/index?inquiries_autoresponder_id=#qAutoresponderDrip.inquiries_autoresponder_id#&zsid=#request.zsid#"); 
	}
	application.zcore.status.setStatus(request.zsid, "Autoresponder drip test sent");
	application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder-drips/index?inquiries_autoresponder_id=#qAutoresponderDrip.inquiries_autoresponder_id#&zsid=#request.zsid#"); 
	</cfscript> 
</cffunction> 

<cffunction name="sendAutoresponderDrip" localmode="modern" access="public" roles="administrator">
	<cfargument name="ss" type="struct" required="yes">
	<cfargument name="dripData" type="struct" required="no" default="#structnew()#">
	<cfscript> 
	ss=arguments.ss;
	dripData=arguments.dripData;
	var db=request.zos.queryObject;   
	if(not structkeyexists(ss, 'to')){
		throw("arguments.ss.to is required");
	}
	if(not structkeyexists(ss, 'from')){
		ss.from = '';
	}
	if(not structkeyexists(ss, 'inquiries_type_id')){
		throw("arguments.ss.inquiries_type_id is required");
	}
	if(not structkeyexists(ss, 'inquiries_type_id_siteidtype')){
		throw("arguments.ss.inquiries_type_id_siteidtype is required");
	}
	if(not structkeyexists(ss, 'inquiries_autoresponder_id')){
		throw("arguments.ss.inquiries_autoresponder_id is required");
	}
	if(not structkeyexists(ss, 'inquiries_autoresponder_drip_id')){
		throw("arguments.ss.inquiries_autoresponder_drip_id is required");
	}
	if(not structkeyexists(ss, 'forceSend')){
		ss.forceSend=false;
	}
	if(not structkeyexists(ss, 'preview')){
		ss.preview=false;
	}
	if(not structkeyexists(ss, 'dataStruct')){
		ss.dataStruct={};
	} 
	if(not structkeyexists(ss, 'layoutStruct')){
		ss.layoutStruct={};
	}
	if(not structkeyexists(ss.dataStruct, 'officeId')){
		ss.dataStruct.officeId=0;
	}
	defaultDataStruct={
		firstName:"Customer",
		interestedInModel:"Unspecified Model",
		email:ss.to
	};
	structappend(ss.dataStruct, defaultDataStruct, false);

	defaultLayoutStruct={
		headerHTML: '',
		mainHTML: '',
		footerHTML: '',
		footerTextHTML: ''
	};
	structappend(ss.layoutStruct, defaultLayoutStruct, false);

	if ( ss.dataStruct.interestedInModel EQ '' ) {
		ss.dataStruct.interestedInModel = 'Unspecified Model';
	}
	if(structcount(dripData) EQ 0){
		db.sql="SELECT *
			FROM #db.table("inquiries_autoresponder", request.zos.zcoreDatasource)#
			WHERE inquiries_autoresponder_id = #db.param(ss.inquiries_autoresponder_id)#
				AND site_id = #db.param(request.zos.globals.id)#
				AND inquiries_autoresponder_deleted = #db.param(0)#";
		if(not ss.preview and not ss.forceSend){
			db.sql&=" and inquiries_autoresponder_active=#db.param(1)# ";
		}
		qAutoresponder=db.execute("qAutoresponder"); 
		//ss.dataStruct.interestedInModel = qAutoresponder.inquiries_autoresponder_interested_in_model;


		db.sql="SELECT *
			FROM #db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)#
			WHERE inquiries_autoresponder_drip_id = #db.param(ss.inquiries_autoresponder_drip_id)#
				AND inquiries_autoresponder_id = #db.param(ss.inquiries_autoresponder_id)#
				AND site_id = #db.param(request.zos.globals.id)#
				AND inquiries_autoresponder_drip_deleted = #db.param(0)#";
		if(not ss.preview and not ss.forceSend){
			db.sql&=" AND inquiries_autoresponder_drip_active=#db.param(1)# ";
		}
		qAutoresponderDrip=db.execute("qAutoresponderDrip");

		if(qAutoresponderDrip.recordcount EQ 0){  
			return {success:false}; 
		}
		for(row in qAutoresponder){
			structappend(dripData, row, true);
		}
		for(row in qAutoresponderDrip){
			structappend(dripData, row, true);
		}
	}

	ts={};
	ts.subject=dripData.inquiries_autoresponder_drip_subject;
 
	if(structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'getAutoresponderDripOfficeInfo')){   
		rsOffice=application.sitestruct[request.zos.globals.id].zcorecustomfunctions.getAutoresponderDripOfficeInfo(ss.dataStruct.officeId);
  
		ss.dataStruct.officeName=rsOffice.officeName;
		ss.dataStruct.officeFullInfo=rsOffice.officeFullInfo; 
	}
	if(structkeyexists(application.sitestruct[request.zos.globals.id].zcorecustomfunctions, 'getAutoresponderDripTemplate')){ 
		rs=application.sitestruct[request.zos.globals.id].zcorecustomfunctions.getAutoresponderDripTemplate(dripData, ss); 
		if(structkeyexists(rs, 'dataStruct')){
			for(i in rs.dataStruct){
				if(application.zcore.functions.zso(ss.dataStruct, i) EQ ""){
					ss.dataStruct[i]=rs.dataStruct[i];
				}
			}
		}
		if(ss.preview or ss.forceSend){ 
			if(structkeyexists(rs, 'defaultDataStruct')){
				structappend(ss.dataStruct, rs.defaultDataStruct, true);
			}	 
			ss.dataStruct.email=ss.to;
		}
	}else{
		rs={
			htmlStart:'#application.zcore.functions.zHTMLDoctype()#
				<head>
				<meta charset="utf-8" />
				<title></title>
				</head> 
				<body>',
			htmlEnd:'
			<p><a href="%unsubscribeLink%">Unsubscribe</a></p>
			</body>
			</html>'
		};
	} 
	ts.html=rs.htmlStart&dripData.inquiries_autoresponder_drip_body_content&rs.htmlEnd;


	if ( NOT findNoCase( '%unsubscribeLink%', rs.htmlEnd ) ) {
		throw( 'Unsubscribe link missing.<br />You must include the variable %unsubscribeLink% somewhere in htmlEnd (see getAutoresponderDripTemplate function located in zCoreCustomFunctions.cfc)' );
	}

	// replace variables
	ts.html = replaceNoCase( ts.html, "%unsubscribeLink%", request.zos.globals.domain & '/z/inquiries/autoresponder-unsubscribe/index?email=' & ss.to & '&autoresponder_id=' & dripData.inquiries_autoresponder_id, 'all' );

	for(field in ss.dataStruct){
		value=ss.dataStruct[field];
		ts.html=replaceNoCase(ts.html, "%"&field&"%", value, "all");
	}
	ts.html=rereplace(ts.html, '%[^%]+%', '', 'all');
	ts.html=replace(ts.html, '%%', '%', 'all');
 
	ts.html=application.zcore.email.forceAbsoluteURLs(ts.html); 
	ts.to=ss.to;

	fromEmail = ss.from;

	if(dripData.inquiries_autoresponder_from NEQ ""){
		fromEmail=dripData.inquiries_autoresponder_from;
	}
	if(dripData.inquiries_autoresponder_drip_from NEQ ""){
		fromEmail=dripData.inquiries_autoresponder_drip_from;
	} 
	if ( fromEmail EQ '' ) {
		fromEmail = request.officeEmail;
	}
	if(dripData.inquiries_autoresponder_bcc NEQ ""){
		ts.bcc=dripData.inquiries_autoresponder_bcc;
	}

	ts.from=fromEmail;

	if(application.zcore.functions.zso(ss, 'cc') NEQ ""){
		ts.cc=ss.cc;
	}
	if(request.zos.istestserver){
		// prevent emailing external people on test server
		ts.to=request.zos.developerEmailTo;
		ts.cc="";
	}
	if(ss.preview){
		return {success:true, data:ts};
	}
  
	rCom=application.zcore.email.send(ts);
	if(rCom.isOK() EQ false){
		rCom.setStatusErrors(request.zsid); 
		application.zcore.status.setStatus(request.zsid, "Autoresponder drip test failed");
		application.zcore.functions.zRedirect("/z/inquiries/admin/autoresponder-drips/index?zsid=#request.zsid#"); 
	}
	return {success:true, data:ts};
	</cfscript> 
</cffunction> 
 

<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	var db=request.zos.queryObject;
	var qCheck=0;
	var q=0; 
	db.sql="SELECT * FROM #db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)#
	WHERE inquiries_autoresponder_drip_id= #db.param(application.zcore.functions.zso(form,'inquiries_autoresponder_drip_id'))# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_drip_deleted = #db.param(0)#  ";
	qCheck=db.execute("qCheck");
	
	if(qCheck.recordcount EQ 0){
		application.zcore.status.setStatus(Request.zsid, 'Autoresponder drip doesn''t exist or was already removed', false,true);
		application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder-drips/index?inquiries_autoresponder_id=#application.zcore.functions.zso(form,'inquiries_autoresponder_id')#&zsid=#request.zsid#');
	} 

	if(qCheck.inquiries_autoresponder_drip_header_image NEQ ""){
		application.zcore.functions.zDeleteFile(request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath, 1, 1)&qCheck.inquiries_autoresponder_drip_header_image);
	}

	if(qCheck.inquiries_autoresponder_drip_main_image NEQ ""){
		application.zcore.functions.zDeleteFile(request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath, 1, 1)&qCheck.inquiries_autoresponder_drip_main_image);
	}

	if(qCheck.inquiries_autoresponder_drip_footer_image NEQ ""){
		application.zcore.functions.zDeleteFile(request.zos.globals.privateHomeDir&removechars(request.zos.autoresponderImagePath, 1, 1)&qCheck.inquiries_autoresponder_drip_footer_image);
	}

	db.sql="DELETE FROM #db.table("inquiries_autoresponder_drip", request.zos.zcoreDatasource)# WHERE 
	inquiries_autoresponder_drip_id= #db.param(application.zcore.functions.zso(form, 'inquiries_autoresponder_drip_id'))# and 
	site_id=#db.param(request.zos.globals.id)# and 
	inquiries_autoresponder_drip_deleted = #db.param(0)#   ";
	q=db.execute("q");

	variables.queueSortCom.init( variables.queueSortStruct );
	variables.queueSortCom.sortAll();

	application.zcore.status.setStatus(Request.zsid, 'Autoresponder drip deleted');
	application.zcore.functions.zRedirect('/z/inquiries/admin/autoresponder-drips/index?inquiries_autoresponder_id=#application.zcore.functions.zso(form,'inquiries_autoresponder_id')#&zsid=#request.zsid#');
	</cfscript> 
</cffunction>

<cffunction name="getHeaderHTML" localmode="modern" access="public" roles="administrator">
	<cfargument name="autoresponderDrip" type="struct" required="yes">
	<cfscript>
		var autoresponderDrip = arguments.autoresponderDrip;

		headerHTML = '';

		if ( autoresponderDrip.inquiries_autoresponder_drip_header_image NEQ '' ) {
			if ( autoresponderDrip.inquiries_autoresponder_drip_header_link NEQ '' ) {
				headerHTML = '<a href="#autoresponderDrip.inquiries_autoresponder_drip_header_link#"><img src="#this.getDripImageURL( autoresponderDrip.inquiries_autoresponder_drip_header_image )#" style="float:left;"></a>';
			} else {
				headerHTML = '<img src="#this.getDripImageURL( autoresponderDrip.inquiries_autoresponder_drip_header_image )#" style="float:left;">';
			}
		}

		return headerHTML;
	</cfscript>
</cffunction>

<cffunction name="getMainHTML" localmode="modern" access="public" roles="administrator">
	<cfargument name="autoresponderDrip" type="struct" required="yes">
	<cfscript>
		var autoresponderDrip = arguments.autoresponderDrip;

		mainHTML = '';

		if ( autoresponderDrip.inquiries_autoresponder_drip_main_image NEQ '' ) {
			if ( autoresponderDrip.inquiries_autoresponder_drip_main_link NEQ '' ) {
				mainHTML = '<a href="#autoresponderDrip.inquiries_autoresponder_drip_main_link#"><img src="#this.getDripImageURL( autoresponderDrip.inquiries_autoresponder_drip_main_image )#" style="float:left;"></a>';
			} else {
				mainHTML = '<img src="#this.getDripImageURL( autoresponderDrip.inquiries_autoresponder_drip_main_image )#" style="float:left;">';
			}
		}

		return mainHTML;
	</cfscript>
</cffunction>

<cffunction name="getFooterHTML" localmode="modern" access="public" roles="administrator">
	<cfargument name="autoresponderDrip" type="struct" required="yes">
	<cfscript>
		var autoresponderDrip = arguments.autoresponderDrip;

		footerHTML = '';

		if ( autoresponderDrip.inquiries_autoresponder_drip_footer_image NEQ '' ) {
			if ( autoresponderDrip.inquiries_autoresponder_drip_footer_link NEQ '' ) {
				footerHTML = '<a href="#autoresponderDrip.inquiries_autoresponder_drip_footer_link#"><img src="#this.getDripImageURL( autoresponderDrip.inquiries_autoresponder_drip_footer_image )#" style="float:left;"></a>';
			} else {
				footerHTML = '<img src="#this.getDripImageURL( autoresponderDrip.inquiries_autoresponder_drip_footer_image )#" style="float:left;">';
			}
		}

		return footerHTML;
	</cfscript>
</cffunction>

<cffunction name="getFooterTextHTML" localmode="modern" access="public" roles="administrator">
	<cfargument name="autoresponderDrip" type="struct" required="yes">
	<cfscript>
		var autoresponderDrip = arguments.autoresponderDrip;

		footerTextHTML = '';

		if ( autoresponderDrip.inquiries_autoresponder_drip_footer_text NEQ '' ) {
			footerTextHTML = autoresponderDrip.inquiries_autoresponder_drip_footer_text;
		}

		return footerTextHTML;
	</cfscript>
</cffunction>

<cffunction name="getDripImageURL" localmode="modern" access="public" roles="administrator">
	<cfargument name="image" type="string" required="yes">
	<cfscript>
		return request.zos.globals.domain & request.zos.autoresponderImagePath & arguments.image;
	</cfscript>
</cffunction>

<cffunction name="subscribe" localmode="modern" access="public">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
		ss = arguments.ss;

		if ( NOT structKeyExists( ss, 'email' ) ) {
			throw( 'arguments.ss.email is required' );
		}
		if ( NOT structKeyExists( ss, 'inquiries_type_id' ) ) {
			throw( 'arguments.ss.inquiries_type_id is required' );
		}
		if ( NOT structKeyExists( ss, 'autoresponder_id' ) ) {
			throw( 'arguments.ss.autoresponder_id is required' );
		}
		if ( NOT structKeyExists( ss, 'officeId' ) ) {
			ss.officeId = '';
		}

		if ( NOT structKeyExists( ss, 'interested_in_model' ) ) {
			ss.interested_in_model = '';
		}
		if ( NOT structKeyExists( ss, 'first_name' ) ) {
			ss.first_name = '';
		}
		if ( NOT structKeyExists( ss, 'last_name' ) ) {
			ss.last_name = '';
		}
		if ( NOT structKeyExists( ss, 'datetime' ) ) {
			ss.datetime = request.zos.mysqlnow;
		}

		subscribeStruct = {
			'email': ss.email,
			'inquiries_type_id': ss.inquiries_type_id,
			'autoresponder_id': ss.autoresponder_id,
			'interested_in_model': ss.interested_in_model
		};

		if ( this.isEmailSubscribedToDrip( subscribeStruct ) ) {
			logStruct = {
				'inquiries_type_id': ss.inquiries_type_id,
				'inquiries_autoresponder_id': ss.autoresponder_id,
				'inquiries_autoresponder_drip_id': 0,
				'inquiries_autoresponder_drip_log_email': ss.email,
				'inquiries_autoresponder_drip_log_status': 'alreadysubscribed'
			};

			this.logEmailStatus( logStruct );

			return;
		}

		subscriberStruct = {
			'site_id': request.zos.globals.id,
			'inquiries_type_id': ss.inquiries_type_id,
			'inquiries_autoresponder_id': ss.autoresponder_id,
			'inquiries_autoresponder_last_drip_id': 0,
			'inquiries_autoresponder_last_drip_datetime': ss.datetime,
			'inquiries_autoresponder_subscriber_email': ss.email,
			'inquiries_autoresponder_subscriber_first_name': ss.first_name,
			'inquiries_autoresponder_subscriber_last_name': ss.last_name,
			'inquiries_autoresponder_subscriber_interested_in_model': ss.interested_in_model,
			'inquiries_autoresponder_subscriber_subscribed': 1,
			'inquiries_autoresponder_subscriber_completed': 0,
			'inquiries_autoresponder_subscriber_updated_datetime': request.zOS.mysqlnow,
			'inquiries_autoresponder_subscriber_deleted': 0,
			'inquiries_autoresponder_subscriber_officeid':ss.officeId
		};

		ts = structNew();

		ts.table      = 'inquiries_autoresponder_subscriber';
		ts.datasource = request.zos.zcoreDatasource; 
		ts.struct     = subscriberStruct;

		rs = application.zcore.functions.zInsert( ts );

		if ( rs EQ false ) {
			throw( 'Failed to subscribe user to autoresponder drip' );
		}

		logStruct = {
			'inquiries_type_id': ss.inquiries_type_id,
			'inquiries_autoresponder_id': ss.autoresponder_id,
			'inquiries_autoresponder_drip_id': 0,
			'inquiries_autoresponder_drip_log_email': ss.email,
			'inquiries_autoresponder_drip_log_status': 'subscribed'
		};

		this.logEmailStatus( logStruct );
	</cfscript>
</cffunction>

<cffunction name="isEmailSubscribedToDrip" localmode="modern" access="public">
	<cfargument name="subscribeStruct" type="struct" required="yes">
	<cfscript>
		var db = request.zos.queryObject;

		subscribeStruct = arguments.subscribeStruct;

		if ( NOT structKeyExists( subscribeStruct, 'email' ) ) {
			throw( 'arguments.subscribeStruct.email is required' );
		}
		if ( NOT structKeyExists( subscribeStruct, 'inquiries_type_id' ) ) {
			throw( 'arguments.subscribeStruct.inquiries_type_id is required' );
		}
		if ( NOT structKeyExists( subscribeStruct, 'autoresponder_id' ) ) {
			throw( 'arguments.subscribeStruct.autoresponder_id is required' );
		}
		if ( NOT structKeyExists( subscribeStruct, 'interested_in_model' ) ) {
			throw( 'arguments.subscribeStruct.interested_in_model is required' );
		}

		// Make sure that the autoresponder is active.
		db.sql = 'SELECT inquiries_autoresponder_id
			FROM #db.table( 'inquiries_autoresponder_drip', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zOS.globals.id )#
				AND inquiries_autoresponder_id = #db.param( subscribeStruct.autoresponder_id )#
				AND inquiries_autoresponder_drip_active = #db.param( 1 )#
				AND inquiries_autoresponder_drip_deleted = #db.param( 0 )#
			LIMIT #db.param( 1 )#';
		qAutoresponderDrip = db.execute( 'qAutoresponderDrip' );

		if ( qAutoresponderDrip.recordcount EQ 0 ) {
			// We did not find any autoresponders with the above query, so
			// consider the email address already subscribed (do nothing).
			return true;
		}

		var dripCampaignSubscribeIndex = application.zcore.functions.zso( request.zos.globals, 'dripCampaignSubscribeIndex', true, 0 );

		// 0 = No index
		if ( dripCampaignSubscribeIndex EQ 0 ) {
			// Always subscribe or re-subscribe the user.
			return false;
		}
		// 1 = Email
		else if ( dripCampaignSubscribeIndex EQ 1 ) {
			// Only subscribe if the email address isn't already subscribed.
			db.sql = 'SELECT inquiries_autoresponder_subscriber_email
				FROM #db.table( 'inquiries_autoresponder_subscriber', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zOS.globals.id )#
					AND inquiries_autoresponder_subscriber_email = #db.param( subscribeStruct.email )#
					AND inquiries_autoresponder_subscriber_deleted = #db.param( 0 )#';
			qSubscriber = db.execute( 'qSubscriber' );

			if ( qSubscriber.recordcount EQ 0 ) {
				// Email address does not appear to be subscribed on this site yet.
				return false;
			}

			return true;
		}
		// 2 = Email + Lead Type
		else if ( dripCampaignSubscribeIndex EQ 2 ) {
			// Only subscribe if the email address isn't already subscribed
			// and they have not subscribed to this Lead Type yet.
			db.sql = 'SELECT inquiries_autoresponder_subscriber_email
				FROM #db.table( 'inquiries_autoresponder_subscriber', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zOS.globals.id )#
					AND inquiries_type_id = #db.param( subscribeStruct.inquiries_type_id )#
					AND inquiries_autoresponder_subscriber_email = #db.param( subscribeStruct.email )#
					AND inquiries_autoresponder_subscriber_deleted = #db.param( 0 )#';
			qSubscriber = db.execute( 'qSubscriber' );

			if ( qSubscriber.recordcount EQ 0 ) {
				// Email address does not appear to be subscribed on this site
				// for the Lead Type they are trying to subscribe to.
				return false;
			}

			return true;
		}
		// 3 = Email + Lead Type + Interested In Model
		else if ( dripCampaignSubscribeIndex EQ 3 ) {
			// Only subscribe if the email address isn't already subscribed
			// and they have not subscribed to this Lead Type
			// and the Interested In Model is different.
			db.sql = 'SELECT inquiries_autoresponder_subscriber_email
				FROM #db.table( 'inquiries_autoresponder_subscriber', request.zos.zcoreDatasource )#
				WHERE site_id = #db.param( request.zOS.globals.id )#
					AND inquiries_type_id = #db.param( subscribeStruct.inquiries_type_id )#
					AND inquiries_autoresponder_subscriber_interested_in_model = #db.param( subscribeStruct.interested_in_model )#
					AND inquiries_autoresponder_subscriber_email = #db.param( subscribeStruct.email )#
					AND inquiries_autoresponder_subscriber_deleted = #db.param( 0 )#';
			qSubscriber = db.execute( 'qSubscriber' );

			if ( qSubscriber.recordcount EQ 0 ) {
				// Email address does not appear to be subscribed on this site
				// for the Lead Type or Interested In Model they are trying to
				// subscribe to.
				return false;
			}

			return true;
		} else {
			throw( 'Invalid dripCampaignSubscribeIndex value' );
		}

	</cfscript>
</cffunction>

<cffunction name="autoresponderHasDrips" localmode="modern" access="public">
	<cfargument name="autoresponder_id" type="numeric" required="yes">
	<cfscript>
		var db = request.zos.queryObject;

		autoresponder_id = arguments.autoresponder_id;

		db.sql = 'SELECT inquiries_autoresponder_id
			FROM #db.table( 'inquiries_autoresponder_drip', request.zos.zcoreDatasource )#
			WHERE site_id = #db.param( request.zOS.globals.id )#
				AND inquiries_autoresponder_id = #db.param( autoresponder_id )#
				AND inquiries_autoresponder_drip_active = #db.param( 1 )#
				AND inquiries_autoresponder_drip_deleted = #db.param( 0 )#
			LIMIT #db.param( 1 )#';
		qAutoresponderDrip = db.execute( 'qAutoresponderDrip' );

		if ( qAutoresponderDrip.recordcount EQ 0 ) {
			return false;
		}

		return true;
	</cfscript>
</cffunction>

<cffunction name="logEmailStatus" localmode="modern" access="private">
	<cfargument name="logStruct" type="struct" required="yes">
	<cfscript>
		logStruct = arguments.logStruct;

		if ( NOT structKeyExists( logStruct, 'inquiries_type_id' ) ) {
			throw( 'arguments.logStruct.inquiries_type_id is required' );
		}
		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_id' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_id is required' );
		}
		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_drip_id' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_drip_id is required' );
		}
		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_drip_log_email' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_drip_log_email is required' );
		}
		if ( NOT structKeyExists( logStruct, 'inquiries_autoresponder_drip_log_status' ) ) {
			throw( 'arguments.logStruct.inquiries_autoresponder_drip_log_status is required' );
		}

		logStruct.site_id = request.zos.globals.id;
		logStruct.inquiries_autoresponder_drip_log_datetime = request.zOS.mysqlnow;

		ts = structNew();

		ts.table      = 'inquiries_autoresponder_drip_log';
		ts.datasource = request.zos.zcoreDatasource;
		ts.datasource = request.zos.zcoreDatasource;
		ts.struct     = logStruct;

		rs = application.zcore.functions.zInsert( ts );

		if ( rs EQ false ) {
			throw( 'Failed to log ' & logStruct.inquiries_autoresponder_drip_log_status & ' status' );
		}
	</cfscript>
</cffunction>

</cfoutput>
</cfcomponent>