<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var rateCom=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Categories");
	form.start=application.zcore.functions.zso(form, 'start',false,'');
	if(not application.zcore.app.siteHasApp("rental")){
		application.zcore.status.setStatus(request.zsid,"Access denied");
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	
	form.rental_category_parent_id=application.zcore.functions.zso(form, 'rental_category_parent_id');
	if(structkeyexists(form, 'return') and structkeyexists(form, 'rental_category_id')){
		StructInsert(request.zsession, "rental_category_return"&form.rental_category_id, request.zos.cgi.http_referer, true);		
	}
	variables.queueSortStruct = StructNew();
	// required
	variables.queueSortStruct.tableName = "rental_category";
	variables.queueSortStruct.sortFieldName = "rental_category_sort";
	variables.queueSortStruct.primaryKeyName = "rental_category_id";
	// optional
	variables.queueSortStruct.ajaxTableId='sortRowTable';
	variables.queueSortStruct.ajaxURL='/z/rental/admin/rental-category/#form.method#?rental_category_parent_id=#form.rental_category_parent_id#&action=#form.method#';
	variables.queueSortStruct.datasource = request.zos.zcoreDatasource;

	
	variables.queueSortStruct.where ="  site_id = '#application.zcore.functions.zescape(request.zOS.globals.id)#' and rental_category_deleted='0' ";
	
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	variables.queueSortCom.init(variables.queueSortStruct);
	variables.queueSortCom.returnJson();

	if(structkeyexists(request.zsession, 'enableRentalCategorySortingMode')){
		db.sql=" SELECT *, 
		if(rc2.rental_category_id IS NOT NULL,#db.param(1)#,#db.param(0)#) hasChildren FROM 
		#request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category 
		LEFT JOIN #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rc2 
		on rc2.rental_category_parent_id = rental_category.rental_category_id and 
		rental_category.site_id = rc2.site_id and 
		rc2.rental_category_deleted = #db.param(0)#
		WHERE";
		if(form.rental_category_parent_id NEQ ""){
			db.sql&=" rental_category.rental_category_parent_id = #db.param(form.rental_category_parent_id)# and";
		}
		db.sql&=" rental_category.site_id = #db.param(request.zOS.globals.id)# and 
		rental_category.rental_category_deleted = #db.param(0)#
		GROUP BY rental_category.rental_category_id 
		order by rental_category.rental_category_sort ASC, rental_category.rental_category_name ASC";
		qProp=db.execute("qProp");
		variables.qProp=qProp;
		for(row in qProp){
			variables.queueSortStruct2 = StructNew();
			// required
			variables.queueSortStruct2.tableName = "rental_x_category";
			variables.queueSortStruct2.sortFieldName = "rental_x_category_sort";
			variables.queueSortStruct2.primaryKeyName = "rental_id";
			// optional
			variables.queueSortStruct2.datasource = request.zos.zcoreDatasource;
			variables.queueSortStruct2.sortVarName="rentalQueueSort"&row.rental_category_id;
			variables.queueSortStruct2.sortVarNameAjax="rentalQueueSortAjax"&row.rental_category_id;
			variables.queueSortStruct2.ajaxTableId='sortRowTable'&row.rental_category_id;
			variables.queueSortStruct2.ajaxURL='/z/rental/admin/rental-category/#form.method#?rental_category_parent_id=#form.rental_category_parent_id#&rental_category_id=#row.rental_category_id#';
			
			variables.queueSortStruct2.where ="rental_x_category.rental_category_id='#application.zcore.functions.zescape(row.rental_category_id)#' and  site_id = '#application.zcore.functions.zescape(request.zOS.globals.id)#'  ";
			
			variables["queueSortCom"&row.rental_category_id] = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
			variables["queueSortCom"&row.rental_category_id].init(variables.queueSortStruct2);
			if(structkeyexists(form, "rentalQueueSortAjax"&row.rental_category_id)){
				variables["queueSortCom"&row.rental_category_id].returnJson();
			}
		}
	}
	</cfscript>
	<h2 style="display:inline;">Manage Rental Categories | </h2>
	<cfscript>
	rateCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.rental.admin.controller.rates");
	rateCom.displayNavigation();
	
	application.zcore.functions.zstatushandler(request.zsid);
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var ts=0;
	var arrNav=0;
	var cpi=0;
	var arrName=0;
	var parentparentid=0;
	var parentChildGroupId=0;
	var g=0;
	var qpar=0;
	var qProp=0;
	var i=0;
	var qProp2=0;
	var rs2=0;
	variables.init();
	application.zcore.functions.zSetPageHelpId("7.4");
	ts=structnew();
	ts.image_library_id_field="rental_category.rental_category_image_library_id";
	ts.count = 1; // how many images to get
	var rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	form.rental_category_parent_id=application.zcore.functions.zso(form, 'rental_category_parent_id',true);
	if(structkeyexists(form, 'enableRentalCategorySortingMode')){
		if(form.enableRentalCategorySortingMode EQ 0){
			structdelete(request.zsession, 'enableRentalCategorySortingMode');
		}else{
			request.zsession.enableRentalCategorySortingMode=true;
		}
	}
	if(structkeyexists(request.zsession, 'enableRentalCategorySortingMode')){
		qProp=variables.qProp;
	}

	</cfscript>
	<cfif form.rental_category_parent_id NEQ 0>
		<a href="/z/rental/admin/rental-category/index">Rental Category Root</a> /
		<cfscript>
		arrNav=ArrayNew(1);
		cpi=form.rental_category_parent_id;
		arrName=ArrayNew(1);
		parentparentid='0';
		parentChildGroupId=0; // general rental_category
		for(g=1;g LTE 255;g++){
			db.sql=" SELECT * FROM #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category
			where rental_category_id = #db.param(cpi)# and 
			site_id = #db.param(request.zOS.globals.id)# and 
			rental_category_deleted = #db.param(0)#";
			qpar=db.execute("qpar");
			if(qpar.recordcount EQ 0){
				break;
			}
			if(g EQ 1){
				parentParentId=qpar.rental_category_parent_id;
			}
			ArrayAppend(arrName, qpar.rental_category_name);
			arrayappend(arrNav, '<a href="/z/rental/admin/rental-category/index?rental_category_parent_id=#qpar.rental_category_id#">#qPar.rental_category_name#</a> / ');
			cpi=qpar.rental_category_parent_id;
			if(cpi EQ 0){
				break;
			}
		}
		db.sql=" SELECT * FROM #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category
		where rental_category_id = #db.param(form.rental_category_parent_id)# and 
		site_id = #db.param(request.zOS.globals.id)# and 
		rental_category_deleted = #db.param(0)# ";
		qpar=db.execute("qpar");
		if(qpar.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "The selected rental category doesn't exist.");
			application.zcore.functions.zRedirect('/z/rental/admin/rental-category/index?zsid=#request.zsid#');
		}
		</cfscript>
		<strong>#qpar.rental_category_name#</strong><br />
		<br />
	</cfif>
	
	<p><cfif structkeyexists(request.zsession, 'enableRentalCategorySortingMode')>
		<a href="/z/rental/admin/rental-category/index?rental_category_parent_id=#form.rental_category_parent_id#&enableRentalCategorySortingMode=0">Disable Rental Sorting Mode</a>
	<cfelse>
		<a href="/z/rental/admin/rental-category/index?rental_category_parent_id=#form.rental_category_parent_id#&enableRentalCategorySortingMode=1">Enable Rental Sorting Mode</a>
	</cfif><p>
	
	<cfif structkeyexists(request.zsession, 'enableRentalCategorySortingMode')>
		<table class="table-list" style="border-spacing:0px; width:100%;">
			<tr>
				<th>Rental Category</th>
			</tr>
			<cfloop query="qProp">
				<tr <cfif qProp.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<td><h2>
						#qProp.rental_category_name#
						</h2></td>
					
				</tr>
				<cfscript>
				// you must have a group by in your query or it may miss rows
				ts=structnew();
				ts.image_library_id_field="rental.rental_image_library_id";
				ts.count = 1; // how many images to get
				rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
				db.sql=" SELECT * #db.trustedSQL(rs2.select)# 
				FROM (#request.zos.queryObject.table("rental", request.zos.zcoreDatasource)# rental, 
				#request.zos.queryObject.table("rental_x_category", request.zos.zcoreDatasource)# rental_x_category) 
				#db.trustedSQL(rs2.leftJoin)# 
				where rental.site_id = rental_x_category.site_id and 
				rental_deleted = #db.param(0)# and 
				rental_x_category_deleted = #db.param(0)# and 
				rental_x_category.rental_category_id= #db.param(qProp.rental_category_id)# and 
				rental.rental_id = rental_x_category.rental_id and 
				rental_x_category.site_id = #db.param(request.zOS.globals.id)# 
				group by rental.rental_id 
				order by rental_x_category.rental_x_category_sort ASC, rental_sort ASC ";
				qProp2=db.execute("qProp2");
				</cfscript>
				<cfif qProp2.recordcount NEQ 0>
					<tr style="background-color:##FFF;">
						<td colspan="3" style="padding:15px; border-bottom:none;padding-top:15px;"><p>Sort Rentals In This Category</p>
							<table id="sortRowTable#qProp.rental_category_id#" class="table-list" style="border-spacing:0px; padding:5px; ">
								<thead>
								<tr>
									<th>Photo</th>
									<th>Rental Title</th>
									<th>Sort</th>
								</tr>
								</thead>
								<tbody>
									<cfloop query="qProp2">
										<tr #variables["queueSortCom"&qProp.rental_category_id].getRowHTML(qProp2.rental_id)# <cfif qProp2.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
											<td><cfscript>
											ts=structnew();
											ts.image_library_id=qProp2.rental_image_library_id;
											ts.output=false;
											ts.query=qProp2;
											ts.row=qProp2.currentrow;
											ts.size="100x70";
											ts.crop=0;
											ts.count = 1; // how many images to get
											//application.zcore.functions.zdump(ts);
											var arrImages=application.zcore.imageLibraryCom.displayImageFromSQL(ts); 
											for(i=1;i LTE arraylen(arrImages);i++){
												writeoutput('<img src="'&arrImages[i].link&'">');
											}
											</cfscript></td>
											<td>#qProp2.rental_name#
												<cfif qProp2.rental_active NEQ '1'>
													<br />
													<strong><em>(Inactive)</em></strong>
												</cfif></td>
											<td style="vertical-align:top; ">#variables["queueSortCom"&qProp.rental_category_id].getAjaxHandleButton(qProp.rental_category_id)#</td>
											<!--- <td>#variables.queueSortCom2.getLinks(qProp2.recordcount, qProp2.currentrow, '/z/rental/admin/rental-category/#form.method#?rental_category_parent_id=#form.rental_category_parent_id#&amp;rental_category_id=#qProp2.rental_category_id#&amp;rental_id=#qProp2.rental_id#', "vertical-arrows")# </td> --->
										</tr>
									</cfloop>
								</table></td>
							</tr>
						</tbody>
					</table>
				</cfif>
			</cfloop>
			</tbody>
		</table>
	<cfelse>
		<cfscript>	
		db.sql=" SELECT *  , 
		if(rc2.rental_category_id IS NOT NULL,#db.param(1)#,#db.param(0)#) hasChildren FROM 
		#request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category  
		LEFT JOIN #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rc2 
		on rc2.rental_category_parent_id = rental_category.rental_category_id and 
		rental_category.site_id = rc2.site_id and 
		rc2.rental_category_deleted = #db.param(0)#
		WHERE";
		if(form.rental_category_parent_id NEQ ""){
			db.sql&=" rental_category.rental_category_parent_id = #db.param(form.rental_category_parent_id)# and";
		}
		db.sql&=" rental_category.site_id = #db.param(request.zOS.globals.id)# and 
		rental_category.rental_category_deleted = #db.param(0)#
		GROUP BY rental_category.rental_category_id 
		order by rental_category.rental_category_sort ASC, rental_category.rental_category_name ASC";
		qProp=db.execute("qProp");
		</cfscript>
		<table id="sortRowTable" class="table-list" style="border-spacing:0px; width:100%;">
			<thead>
			<tr>
				<th>Rental Category</th>
				<th>Sort</th>
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
			<cfloop query="qProp">
				<cfscript>

				variables.queueSortCom.getRowStruct(qProp.rental_category_id);
				</cfscript>
				<tr #variables.queueSortCom.getRowHTML(qProp.rental_category_id)# <cfif qProp.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
					<td>#qProp.rental_category_name#</td>
					<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(qProp.rental_category_id)#</td>
					<td><!--- #variables.queueSortCom.getLinks(qProp.recordcount, qProp.currentrow, '/z/rental/admin/rental-category/#form.method#?rental_category_parent_id=#form.rental_category_parent_id#&rental_category_id=#qProp.rental_category_id#&action=#form.method#', "vertical-arrows")#  --->
					<a href="#application.zcore.app.getAppCFC("rental").getCategoryLink(qProp.rental_category_id,qProp.rental_category_name,qProp.rental_category_url)#">View</a> | 
					<cfif qProp.hasChildren EQ 1>
						<a href="/z/rental/admin/rental-category/index?rental_category_parent_id=#qProp.rental_category_id#">Sub-Categories</a> | 
					</cfif>
					<a href="/z/rental/admin/rental-category/edit?rental_category_id=#qProp.rental_category_id#&amp;return=1">Edit</a> | 
					<cfif not application.zcore.functions.zIsForceDeleteEnabled(qProp.rental_category_url)>
						Delete disabled
					<cfelse>
						<a href="/z/rental/admin/rental-category/delete?rental_category_id=#qProp.rental_category_id#&amp;return=1">Delete</a>
					</cfif>
				</td>
				</tr> 
			</cfloop>
			</tbody>
		</table>
	</cfif>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var tempLink=0;
	var qCheck=0;
	var result=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Categories");
	form.rental_category_id=application.zcore.functions.zso(form, 'rental_category_id');
	db.sql=" SELECT * FROM #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category 
	WHERE rental_category_id = #db.param(form.rental_category_id)# and 
	site_id = #db.param(request.zOS.globals.id)# and 
	rental_category_deleted=#db.param(0)#";
	qCheck=db.execute("qCheck");
    if(qCheck.recordcount EQ 0){
        application.zcore.status.setStatus(request.zsid, "Rental Category is missing");
        application.zcore.functions.zRedirect("/z/rental/admin/rental-category/index?zsid="&request.zsid);
    }
    </cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.rental_category_image_library_id);
        db.sql="DELETE FROM #request.zos.queryObject.table("rental_x_category", request.zos.zcoreDatasource)#  
		WHERE  rental_category_id=#db.param(form.rental_category_id)# and 
		site_id = #db.param(request.zOS.globals.id)# and 
		rental_x_category_deleted = #db.param(0)#";
		result = db.execute("result");
        db.sql="DELETE FROM #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)#  
		WHERE  rental_category_id=#db.param(form.rental_category_id)# and 
		site_id = #db.param(request.zOS.globals.id)# and 
		rental_category_deleted = #db.param(0)#";
		result = db.execute("result");
		application.zcore.app.getAppCFC("rental").searchIndexDeleteRentalCategory(form.rental_category_id, false);
		variables.queueSortCom.sortAll();
		application.zcore.app.getAppCFC("rental").updateRewriteRules();	
        application.zcore.status.setStatus(request.zsid, "Rental Category deleted successfully.");
		if(structkeyexists(request.zsession, "rental_category_return"&form.rental_category_id)){
			tempLink=request.zsession["rental_category_return"&form.rental_category_id];
			structdelete(request.zsession,"rental_category_return"&form.rental_category_id);
			application.zcore.functions.z301Redirect(tempLink);
		}else{
			application.zcore.functions.zRedirect("/z/rental/admin/rental-category/index?rental_category_id="&form.rental_category_id&"&zsid="&request.zsid);
		}
        </cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this rental category?<br />
			<br />
			Rental Category: #qcheck.rental_category_name#<br />
			<br />
			<a href="/z/rental/admin/rental-category/delete?confirm=1&amp;rental_category_id=#form.rental_category_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/rental/admin/rental-category/index">No</a> </h2>
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
	var uniqueChanged=0;
	var tempLink=0;
	var ts=0;
	var myForm=structnew();
	var errors=0;
	var qCheck=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Rental Categories");
	uniqueChanged=false;
	if(form.method EQ 'insert' and application.zcore.functions.zso(form, 'rental_category_url') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ "update"){
		db.sql=" SELECT * FROM #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category 
		WHERE rental_category_id = #db.param(form.rental_category_id)# and 
		site_id = #db.param(request.zOS.globals.id)# and 
		rental_category_deleted = #db.param(0)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Rental Category is missing");
			application.zcore.functions.zRedirect("/z/rental/admin/rental-category/index?zsid="&request.zsid);
		}
		if(structkeyexists(form,'rental_category_url') and qcheck.rental_category_url NEQ form.rental_category_url){
			uniqueChanged=true;	
		}
	}else{
		db.sql=" SELECT max(rental_category_sort) sort 
		FROM #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category 
		WHERE  site_id = #db.param(request.zOS.globals.id)# and 
		rental_category_deleted = #db.param(0)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0 or qCheck.sort EQ ""){
			form.rental_category_sort=1;
		}else{
			form.rental_category_sort=qCheck.sort+1;
		}
	}
	myForm.rental_category_name.required=true;
	myForm.rental_category_metakey.allowNull=true;
	myForm.rental_category_metadesc.allowNull=true;
	myForm.rental_category_name.required=true;
	myForm.rental_category_name.friendlyName="Title";
	//myForm.rental_category_name.html=false;
	myForm.rental_category_metakey.html=true;
	myForm.rental_category_metadesc.html=true;
	errors=application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	 
	if(application.zcore.functions.zso(form,'rental_category_url') NEQ "" and not application.zcore.functions.zValidateURL(application.zcore.functions.zso(form,'rental_category_url'), true, true)){
		application.zcore.status.setStatus(request.zsid, "Override URL must be a valid URL beginning with / or ##, such as ""/z/misc/inquiry/index"" or ""##namedAnchor"". No special characters allowed except for this list of characters: a-z 0-9 . _ - and /.", form, true);
		errors=true;
	}

	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rental-category/add?zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/rental/admin/rental-category/edit?rental_category_id=#form.rental_category_id#&zsid=#request.zsid#");
		}
	} 
	form.rental_category_deleted = 0;
	form.rental_category_updated_datetime=request.zos.mysqlnow;
	
	if(trim(application.zcore.functions.zso(form, 'rental_category_metakey')) EQ ""){
		form.rental_category_metakey=replace(replace(form.rental_category_name,"|"," ","ALL"),","," ","ALL");
	}
	if(trim(application.zcore.functions.zso(form, 'rental_category_metadesc')) EQ ""){
		form.rental_category_metadesc=left(replace(replace(rereplacenocase(trim(form.rental_category_text),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
	}
	if(form.method EQ "update"){
		if(application.zcore.functions.zso(form, 'rental_category_metakey') EQ qCheck.rental_category_metakey and qCheck.rental_category_metakey NEQ ""){
			if(replace(replace(qCheck.rental_category_name,"|"," ","ALL"),","," ","ALL") EQ qCheck.rental_category_metakey){
				form.rental_category_metakey=replace(replace(form.rental_category_name,"|"," ","ALL"),","," ","ALL");
			}
		}
		if(application.zcore.functions.zso(form, 'rental_category_metadesc') EQ qCheck.rental_category_metadesc and qCheck.rental_category_metadesc NEQ ""){
			if(left(replace(replace(rereplacenocase(trim(qcheck.rental_category_text),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150) EQ qCheck.rental_category_metakey){
				form.rental_category_metadesc=left(replace(replace(rereplacenocase(trim(form.rental_category_text),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
			}
		}
	}
	 
	form.site_id=request.zos.globals.id;
	 var redirecturl=0;
	ts=StructNew();
	ts.table="rental_category";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insert"){
		form.rental_category_id = application.zcore.functions.zInsert(ts);
		if(form.rental_category_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Rental Category couldn't be added at this time.",form,true);
			application.zcore.functions.zredirect("/z/rental/admin/rental-category/add?zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Rental Category added successfully.");
			redirecturl=("/z/rental/admin/rental-category/index?zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Rental Category failed to update.",form,true);
			application.zcore.functions.zredirect("/z/rental/admin/rental-category/edit?rental_category_id=#form.rental_category_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Rental Category updated successfully.");
			redirecturl=("/z/rental/admin/rental-category/index?zsid="&request.zsid);
		}
	}
	
	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'rental_category_image_library_id'));
	application.zcore.app.getAppCFC("rental").searchReindexRentalCategory(form.rental_category_id, false);
	if(uniqueChanged){
		res=application.zcore.app.getAppCFC("rental").updateRewriteRules();	
		if(res EQ false){
			application.zcore.template.fail("Failed to process rewrite URLs for rental_category_id = #db.param(form.rental_category_id)# and rental_category_url = #db.param(application.zcore.functions.zso(form,'rental_category_url'))#.");
		}
	}
	if(structkeyexists(request.zsession, "rental_category_return"&form.rental_category_id)){
		tempLink=request.zsession["rental_category_return"&form.rental_category_id];
		structdelete(request.zsession,"rental_category_return"&form.rental_category_id);
		application.zcore.functions.z301Redirect(tempLink);
	}else{
		application.zcore.functions.zredirect(redirecturl);
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
	var qslide=0;
	var htmlEditor=0;
	var selectStruct=0;
	var qAll=0;
	var defaultCategoryId=0;
	var childStruct=0;
	var tabCom=0;
	var cancelURL=0;
	var qRate=0;
	var currentMethod=form.method;
	variables.init();
	application.zcore.functions.zSetPageHelpId("7.5");
	form.rental_category_id=application.zcore.functions.zso(form, 'rental_category_id',true);
	db.sql=" SELECT * FROM #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category 
	WHERE rental_category_id = #db.param(form.rental_category_id)# and 
	site_id = #db.param(request.zOS.globals.id)# and 
	rental_category_deleted = #db.param(0)#";
	qRate=db.execute("qRate");
	application.zcore.functions.zQueryToStruct(qRate,form,'rental_category_id,site_id'); 
	application.zcore.functions.zStatusHandler(request.zsid, true,true);
	</cfscript>
	<h2>
		<cfif currentMethod EQ "edit">
			Edit
		<cfelse>
			Add
			<cfscript>
			application.zcore.functions.zCheckIfPageAlreadyLoadedOnce();
			</cfscript>
		</cfif>
		Rental Category</h2>
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/rental/admin/rental-category/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?rental_category_id=#form.rental_category_id#" method="post">
		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-rental-category-edit");
		cancelURL="/z/rental/admin/rental-category/index";
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<cfscript>
			db.sql=" SELECT *  FROM #request.zos.queryObject.table("rental_category", request.zos.zcoreDatasource)# rental_category 
			WHERE site_id = #db.param(request.zOS.globals.id)# and 
			rental_category_parent_id = #db.param(0)# and 
			rental_category_deleted = #db.param(0)#
			ORDER BY rental_category_name ASC ";
			qAll=db.execute("qAll");
			defaultCategoryId=0;
			request.allTempIds=StructNew();
			childStruct=application.zcore.app.getAppCFC("rental").getAllCategory(qAll,0,form.rental_category_id);
			</cfscript>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Name","member.rental.category.edit rental_category_name")#</th>
				<td class="table-white"><input name="rental_category_name" size="50" type="text" value="#form.rental_category_name#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Lead Email","member.rental.category.edit rental_category_email")#</th>
				<td class="table-white"><input name="rental_category_email" size="50" type="text" value="#form.rental_category_email#" maxlength="100" /><br />
					(Leave blank to use default system routing)</td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photos","member.rental.category.edit rental_category_image_library_id")#</th>
				<td colspan="2" class="table-white"><cfscript>
				var ts=structnew();
				ts.name="rental_category_image_library_id";
				ts.value=form.rental_category_image_library_id;
				application.zcore.imageLibraryCom.getLibraryForm(ts);
				</cfscript></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Full Text","member.rental.category.edit rental_category_text")#</th>
				<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "rental_category_text";
            htmlEditor.value			= form.rental_category_text;
            htmlEditor.basePath		= '/';
            htmlEditor.width			= "#request.zos.globals.maximagewidth#px";
            htmlEditor.height		= 400;
            htmlEditor.create();
            </cfscript></td>
			</tr>
			<cfscript>
			db.sql=" SELECT * FROM #request.zos.queryObject.table("slideshow", request.zos.zcoreDatasource)# slideshow 
			WHERE site_id = #db.param(request.zOS.globals.id)# and 
			slideshow_deleted = #db.param(0)#
			ORDER BY slideshow_name ASC ";
			qslide=db.execute("qslide");
			</cfscript>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Slideshow","member.rental.category.edit rental_category_slideshow_id")#</th>
				<td style="vertical-align:top; "><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "rental_category_slideshow_id";
					selectStruct.query = qslide;
					selectStruct.selectLabel="-- Select --";
					selectStruct.queryLabelField = "slideshow_name";
					selectStruct.queryValueField = "slideshow_id";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					| <a href="/z/admin/slideshow/add" target="_blank">Create a slideshow</a></td>
			</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.beginFieldSet("Advanced")#
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Change Parent Category","member.rental.category.edit rental_category_parent_id")#</th>
				<td style="vertical-align:top; "><script>
				  /* <![CDATA[ */
				  function preventSameParent(o,id){
					if(o.options[o.selectedIndex].value == id){
						alert('You can\'t select the same page you are editing.\nPlease select a different page.');
						o.selectedIndex--;
					}
				  }
				  /* ]]> */
				  </script>
					<cfscript>
					selectStruct = StructNew();
					selectStruct.name = "rental_category_parent_id";
					selectStruct.selectLabel ="-- Rental Home Page --";
					selectStruct.listLabels = ArrayToList(childStruct.arrCategoryName,chr(9));
					selectStruct.listValues = ArrayToList(childStruct.arrCategoryId,chr(9));
					selectStruct.listLabelsDelimiter = chr(9); // tab delimiter
					selectStruct.listValuesDelimiter = chr(9);
					if(currentMethod EQ 'edit'){
						selectStruct.onChange="preventSameParent(this, #form.rental_category_id#);";
					}
					//selectStruct.style="monodrop";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					<br />
					Associate this category with another category. </td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Keywords","member.rental.category.edit rental_category_metakey")#</th>
				<td style="vertical-align:top; "><textarea name="rental_category_metakey" rows="5" cols="60">#form.rental_category_metakey#</textarea></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Description","member.rental.category.edit rental_category_metadesc")#</th>
				<td style="vertical-align:top; "><textarea name="rental_category_metadesc" cols="60" rows="5">#form.rental_category_metadesc#</textarea></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Searchable","member.rental.category.edit rental_category_searchable")#</th>
				<td colspan="2" ><input type="radio" name="rental_category_searchable" <cfif application.zcore.functions.zso(form, 'rental_category_searchable',false,1) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
					Yes
					<input type="radio" name="rental_category_searchable" <cfif application.zcore.functions.zso(form, 'rental_category_searchable',false,1) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
					No </td>
			</tr>
			<tr>
				<th style="white-space:nowrap; width:1%;vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Override URL","member.rental.category.edit rental_category_url")#</th>
				<td colspan="2" class="table-white"  style="white-space:nowrap;">ADVANCED USERS ONLY:<br />
					<input name="rental_category_url" type="text" value="#form.rental_category_url#" size="50" /></td>
			</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.endTabMenu()#
	</form>
</cffunction>
</cfoutput>
</cfcomponent>
