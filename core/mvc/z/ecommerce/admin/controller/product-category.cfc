<cfcomponent>
<cfoutput>
<cffunction name="init" localmode="modern" access="private" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var rateCom=0;
    application.zcore.adminSecurityFilter.requireFeatureAccess("Product Categories");
	form.start=application.zcore.functions.zso(form, 'start',false,'');
	if(not application.zcore.app.siteHasApp("Product")){
		application.zcore.status.setStatus(request.zsid,"Access denied");
		application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
	}
	form.parent_category_parent_id=application.zcore.functions.zso(form, 'parent_category_parent_id', true);
	if(structkeyexists(form, 'return') and structkeyexists(form, 'product_category_id')){
		StructInsert(request.zsession, "product_category_return"&form.product_category_id, request.zos.cgi.http_referer, true);		
	}
	variables.queueSortStruct = StructNew();
	// required
	variables.queueSortStruct.tableName = "product_category";
	variables.queueSortStruct.sortFieldName = "product_category_sort";
	variables.queueSortStruct.primaryKeyName = "product_category_id";
	// optional
	variables.queueSortStruct.datasource = request.zos.zcoreDatasource;
	
	variables.queueSortStruct.ajaxTableId='sortRowTable';
	variables.queueSortStruct.ajaxURL='/z/ecommerce/admin/product-category/#form.method#?product_category_parent_id=#form.product_category_parent_id#&action=#form.method#';
	variables.queueSortStruct.where ="  site_id = '#application.zcore.functions.zescape(request.zOS.globals.id)#' and product_category_deleted='0' ";
	
	variables.queueSortCom = application.zcore.functions.zcreateobject("component", "zcorerootmapping.com.display.queueSort");
	variables.queueSortCom.init(variables.queueSortStruct);
	variables.queueSortCom.returnJson();
	</cfscript>
	<h2 style="display:inline;">Manage Product Categories | </h2>
	<cfscript>
	rateCom=application.zcore.functions.zcreateobject("component", "zcorerootmapping.mvc.z.Product.admin.controller.rates");
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
	//application.zcore.functions.zSetPageHelpId("7.4");
	ts=structnew();
	ts.image_library_id_field="product_category.product_category_image_library_id";
	ts.count = 1; // how many images to get
	var rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	form.product_category_parent_id=application.zcore.functions.zso(form, 'product_category_parent_id',true);
	if(structkeyexists(form, 'enableProductCategorySortingMode')){
		if(form.enableProductCategorySortingMode EQ 0){
			structdelete(request.zsession, 'enableProductCategorySortingMode');
		}else{
			request.zsession.enableProductCategorySortingMode=true;
		}
	}
	</cfscript>
	<cfif form.product_category_parent_id NEQ 0>
		<a href="/z/ecommerce/admin/product-category/index">Product Category Root</a> /
		<cfscript>
		arrNav=ArrayNew(1);
		cpi=form.product_category_parent_id;
		arrName=ArrayNew(1);
		parentparentid='0';
		parentChildGroupId=0; // general product_category
		for(g=1;g LTE 255;g++){
			db.sql=" SELECT * FROM #request.zos.queryObject.table("product_category", request.zos.zcoreDatasource)# product_category
			where product_category_id = #db.param(cpi)# and 
			site_id = #db.param(request.zOS.globals.id)# and 
			product_category_deleted = #db.param(0)#";
			qpar=db.execute("qpar");
			if(qpar.recordcount EQ 0){
				break;
			}
			if(g EQ 1){
				parentParentId=qpar.product_category_parent_id;
			}
			ArrayAppend(arrName, qpar.product_category_name);
			arrayappend(arrNav, '<a href="/z/ecommerce/admin/product-category/index?product_category_parent_id=#qpar.product_category_id#">#qPar.product_category_name#</a> / ');
			cpi=qpar.product_category_parent_id;
			if(cpi EQ 0){
				break;
			}
		}
		db.sql=" SELECT * FROM #request.zos.queryObject.table("product_category", request.zos.zcoreDatasource)# product_category
		where product_category_id = #db.param(form.product_category_parent_id)# and 
		site_id = #db.param(request.zOS.globals.id)# and 
		product_category_deleted = #db.param(0)# ";
		qpar=db.execute("qpar");
		if(qpar.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "The selected Product category doesn't exist.");
			application.zcore.functions.zRedirect('/z/ecommerce/admin/product-category/index?zsid=#request.zsid#');
		}
		</cfscript>
		<strong>#qpar.product_category_name#</strong><br />
		<br />
	</cfif>
	
	<p><cfif structkeyexists(request.zsession, 'enableProductCategorySortingMode')>
		<a href="/z/ecommerce/admin/product-category/index?product_category_parent_id=#form.product_category_parent_id#&enableProductCategorySortingMode=0">Disable Product Sorting Mode</a>
	<cfelse>
		<a href="/z/ecommerce/admin/product-category/index?product_category_parent_id=#form.product_category_parent_id#&enableProductCategorySortingMode=1">Enable Product Sorting Mode</a>
	</cfif><p>

	<cfscript>	
	db.sql=" SELECT *  , 
	if(rc2.product_category_id IS NOT NULL,#db.param(1)#,#db.param(0)#) hasChildren FROM 
	#request.zos.queryObject.table("product_category", request.zos.zcoreDatasource)# product_category  
	LEFT JOIN #request.zos.queryObject.table("product_category", request.zos.zcoreDatasource)# rc2 
	on rc2.product_category_parent_id = product_category.product_category_id and 
	product_category.site_id = rc2.site_id and 
	rc2.product_category_deleted = #db.param(0)#
	WHERE";
	if(form.product_category_parent_id NEQ ""){
		db.sql&=" product_category.product_category_parent_id = #db.param(form.product_category_parent_id)# and";
	}
	db.sql&=" product_category.site_id = #db.param(request.zOS.globals.id)# and 
	product_category.product_category_deleted = #db.param(0)#
	GROUP BY product_category.product_category_id 
	order by product_category.product_category_sort ASC, product_category.product_category_name ASC";
	qProp=db.execute("qProp");
	</cfscript>
	<table id="sortRowTable" class="table-list" style="border-spacing:0px; width:100%;">
		<thead>
		<tr>
			<th>Product Category</th>
			<th>Sort</th>
			<th>Admin</th>
		</tr>
		</thead>
		<tbody>
		<cfloop query="qProp">
			<cfscript>
	
			variables.queueSortCom.getRowStruct(qProp.property_category_id);
			</cfscript>
			<tr <cfif qProp.currentRow MOD 2 EQ 0>class="row1"<cfelse>class="row2"</cfif>>
			<td>#qProp.product_category_name#</td>
			<td style="vertical-align:top; ">#variables.queueSortCom.getAjaxHandleButton(qProp.product_category_id)#</td>
			<td><!--- #variables.queueSortCom.getLinks(qProp.recordcount, qProp.currentrow, '/z/ecommerce/admin/product-category/#form.method#?product_category_parent_id=#form.product_category_parent_id#&product_category_id=#qProp.product_category_id#&action=#form.method#', "vertical-arrows")#  --->
			<a href="#application.zcore.app.getAppCFC("ecommerce").getCategoryLink(qProp.product_category_id,qProp.product_category_name,qProp.product_category_url)#">View</a> | 
			<cfif qProp.hasChildren EQ 1>
				<a href="/z/ecommerce/admin/product-category/index?product_category_parent_id=#qProp.product_category_id#">Sub-Categories</a> | 
			</cfif>
			<a href="/z/ecommerce/admin/product-category/edit?product_category_id=#qProp.product_category_id#&amp;return=1">Edit</a> | 
				<cfif not application.zcore.functions.zIsForceDeleteEnabled(qProp.product_category_url)>
					Delete disabled
				<cfelse> 
					<a href="/z/ecommerce/admin/product-category/delete?product_category_id=#qProp.product_category_id#&amp;return=1">Delete</a>
				</cfif>
			</td>
			</tr> 
		</cfloop>
		</tbody>
	</table>
</cffunction>

<cffunction name="delete" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject;
	var tempLink=0;
	var qCheck=0;
	var result=0;
	variables.init();
    application.zcore.adminSecurityFilter.requireFeatureAccess("Product Categories");
	form.product_category_id=application.zcore.functions.zso(form, 'product_category_id');
	db.sql=" SELECT * FROM #request.zos.queryObject.table("product_category", request.zos.zcoreDatasource)# product_category 
	WHERE product_category_id = #db.param(form.product_category_id)# and 
	site_id = #db.param(request.zOS.globals.id)# ";
	qCheck=db.execute("qCheck");
    if(qCheck.recordcount EQ 0){
        application.zcore.status.setStatus(request.zsid, "Product Category is missing");
        application.zcore.functions.zRedirect("/z/ecommerce/admin/product-category/index?zsid="&request.zsid);
    }
    </cfscript>
	<cfif structkeyexists(form, 'confirm')>
		<cfscript>
		application.zcore.imageLibraryCom.deleteImageLibraryId(qCheck.product_category_image_library_id);
        db.sql="DELETE FROM #request.zos.queryObject.table("product_x_category", request.zos.zcoreDatasource)#  
		WHERE  product_category_id=#db.param(form.product_category_id)# and 
		site_id = #db.param(request.zOS.globals.id)#";
		result = db.execute("result");
        db.sql="DELETE FROM #request.zos.queryObject.table("product_category", request.zos.zcoreDatasource)#  
		WHERE  product_category_id=#db.param(form.product_category_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		result = db.execute("result");
		application.zcore.app.getAppCFC("ecommerce").searchIndexDeleteProductCategory(form.product_category_id, false);
		variables.queueSortCom.sortAll();
        application.zcore.status.setStatus(request.zsid, "Product Category deleted successfully.");
		if(structkeyexists(request.zsession, "product_category_return"&form.product_category_id)){
			tempLink=request.zsession["product_category_return"&form.product_category_id];
			structdelete(request.zsession,"product_category_return"&form.product_category_id);
			application.zcore.functions.z301Redirect(tempLink);
		}else{
			application.zcore.functions.zRedirect("/z/ecommerce/admin/product-category/index?product_category_id="&form.product_category_id&"&zsid="&request.zsid);
		}
        </cfscript>
	<cfelse>
		<h2> Are you sure you want to delete this Product category?<br />
			<br />
			Product Category: #qcheck.product_category_name#<br />
			<br />
			<a href="/z/ecommerce/admin/product-category/delete?confirm=1&amp;product_category_id=#form.product_category_id#">Yes</a>&nbsp;&nbsp;&nbsp;
			<a href="/z/ecommerce/admin/product-category/index">No</a> </h2>
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
    application.zcore.adminSecurityFilter.requireFeatureAccess("Product Categories");
	uniqueChanged=false;
	if(form.method EQ 'insert' and application.zcore.functions.zso(form, 'product_category_url') NEQ ""){
		uniqueChanged=true;
	}
	if(form.method EQ "update"){
		db.sql=" SELECT * FROM #request.zos.queryObject.table("product_category", request.zos.zcoreDatasource)# product_category 
		WHERE product_category_id = #db.param(form.product_category_id)# and 
		site_id = #db.param(request.zOS.globals.id)# ";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Product Category is missing");
			application.zcore.functions.zRedirect("/z/ecommerce/admin/product-category/index?zsid="&request.zsid);
		}
		if(structkeyexists(form,'product_category_url') and qcheck.product_category_url NEQ form.product_category_url){
			uniqueChanged=true;	
		}
	}else{
		db.sql=" SELECT max(product_category_sort) sort 
		FROM #request.zos.queryObject.table("product_category", request.zos.zcoreDatasource)# product_category 
		WHERE  site_id = #db.param(request.zOS.globals.id)# and 
		product_category_deleted = #db.param(0)#";
		qCheck=db.execute("qCheck");
		if(qCheck.recordcount EQ 0 or qCheck.sort EQ ""){
			form.product_category_sort=1;
		}else{
			form.product_category_sort=qCheck.sort+1;
		}
	}
	myForm.product_category_name.required=true;
	myForm.product_category_metakey.allowNull=true;
	myForm.product_category_metadesc.allowNull=true;
	myForm.product_category_name.required=true;
	myForm.product_category_name.friendlyName="Title";
	//myForm.product_category_name.html=false;
	myForm.product_category_metakey.html=true;
	myForm.product_category_metadesc.html=true;
	errors=application.zcore.functions.zValidateStruct(form, myForm, request.zsid, true);
	 
	if(errors){
		if(form.method EQ 'insert'){
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/ecommerce/admin/product-category/add?zsid=#request.zsid#");
		}else{
			application.zcore.status.setStatus(request.zsid, false, form,true);
			application.zcore.functions.zRedirect("/z/ecommerce/admin/product-category/edit?product_category_id=#form.product_category_id#&zsid=#request.zsid#");
		}
	} 
	form.product_category_updated_datetime=request.zos.mysqlnow;
	
	if(trim(application.zcore.functions.zso(form, 'product_category_metakey')) EQ ""){
		form.product_category_metakey=replace(replace(form.product_category_name,"|"," ","ALL"),","," ","ALL");
	}
	if(trim(application.zcore.functions.zso(form, 'product_category_metadesc')) EQ ""){
		form.product_category_metadesc=left(replace(replace(rereplacenocase(trim(form.product_category_text),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
	}
	if(form.method EQ "update"){
		if(application.zcore.functions.zso(form, 'product_category_metakey') EQ qCheck.product_category_metakey and qCheck.product_category_metakey NEQ ""){
			if(replace(replace(qCheck.product_category_name,"|"," ","ALL"),","," ","ALL") EQ qCheck.product_category_metakey){
				form.product_category_metakey=replace(replace(form.product_category_name,"|"," ","ALL"),","," ","ALL");
			}
		}
		if(application.zcore.functions.zso(form, 'product_category_metadesc') EQ qCheck.product_category_metadesc and qCheck.product_category_metadesc NEQ ""){
			if(left(replace(replace(rereplacenocase(trim(qcheck.product_category_text),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150) EQ qCheck.product_category_metakey){
				form.product_category_metadesc=left(replace(replace(rereplacenocase(trim(form.product_category_text),"<[^>]*>","","ALL"),"|"," ","ALL"),","," ","ALL"),150);
			}
		}
	}
	 
	form.site_id=request.zos.globals.id;
	 var redirecturl=0;
	ts=StructNew();
	ts.table="product_category";
	ts.struct=form;
	ts.datasource=request.zos.zcoreDatasource;
	if(form.method EQ "insert"){
		form.product_category_id = application.zcore.functions.zInsert(ts);
		if(form.product_category_id EQ false){
			application.zcore.status.setStatus(request.zsid, "Product Category couldn't be added at this time.",form,true);
			application.zcore.functions.zredirect("/z/ecommerce/admin/product-category/add?zsid="&request.zsid);
		}else{ 
			application.zcore.status.setStatus(request.zsid, "Product Category added successfully.");
			redirecturl=("/z/ecommerce/admin/product-category/index?zsid="&request.zsid);
		}
	
	}else{
		if(application.zcore.functions.zUpdate(ts) EQ false){
			application.zcore.status.setStatus(request.zsid, "Product Category failed to update.",form,true);
			application.zcore.functions.zredirect("/z/ecommerce/admin/product-category/edit?product_category_id=#form.product_category_id#&zsid="&request.zsid);
		}else{
			application.zcore.status.setStatus(request.zsid, "Product Category updated successfully.");
			redirecturl=("/z/ecommerce/admin/product-category/index?zsid="&request.zsid);
		}
	}
	
	application.zcore.imageLibraryCom.activateLibraryId(application.zcore.functions.zso(form, 'product_category_image_library_id'));
	application.zcore.app.getAppCFC("ecommerce").searchReindexProductCategory(form.product_category_id, false);
	if(uniqueChanged){
		res=application.zcore.app.getAppCFC("ecommerce").updateRewriteRules();	
		if(res EQ false){
			application.zcore.template.fail("Failed to process rewrite URLs for product_category_id = #db.param(form.product_category_id)# and product_category_url = #db.param(application.zcore.functions.zso(form,'product_category_url'))#.");
		}
	}
	if(structkeyexists(request.zsession, "product_category_return"&form.product_category_id)){
		tempLink=request.zsession["product_category_return"&form.product_category_id];
		structdelete(request.zsession,"product_category_return"&form.product_category_id);
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
	//application.zcore.functions.zSetPageHelpId("7.5");
	form.product_category_id=application.zcore.functions.zso(form, 'product_category_id',true);
	db.sql=" SELECT * FROM #request.zos.queryObject.table("product_category", request.zos.zcoreDatasource)# product_category 
	WHERE product_category_id = #db.param(form.product_category_id)# and 
	site_id = #db.param(request.zOS.globals.id)# ";
	qRate=db.execute("qRate");
	application.zcore.functions.zQueryToStruct(qRate,form,'product_category_id,site_id'); 
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
		Product Category</h2>
	<form class="zFormCheckDirty" name="myForm" id="myForm" action="/z/ecommerce/admin/product-category/<cfif currentMethod EQ "edit">update<cfelse>insert</cfif>?product_category_id=#form.product_category_id#" method="post">
		<cfscript>
		tabCom=application.zcore.functions.zcreateobject("component","zcorerootmapping.com.display.tab-menu");
		tabCom.init();
		tabCom.setTabs(["Basic","Advanced"]);//,"Plug-ins"]);
		tabCom.setMenuName("member-Product-category-edit");
		cancelURL="/z/ecommerce/admin/product-category/index";
		tabCom.setCancelURL(cancelURL);
		tabCom.enableSaveButtons();
		</cfscript>
		#tabCom.beginTabMenu()# 
		#tabCom.beginFieldSet("Basic")#
		<table style="width:100%; border-spacing:0px;" class="table-list">
			<cfscript>
			db.sql=" SELECT *  FROM #request.zos.queryObject.table("product_category", request.zos.zcoreDatasource)# product_category 
			WHERE site_id = #db.param(request.zOS.globals.id)# and 
			product_category_parent_id = #db.param(0)# and 
			product_category_deleted = #db.param(0)#
			ORDER BY product_category_name ASC ";
			qAll=db.execute("qAll");
			defaultCategoryId=0;
			request.allTempIds=StructNew();
			childStruct=application.zcore.app.getAppCFC("ecommerce").getAllCategory(qAll,0,form.product_category_id);
			</cfscript>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Name","member.product.category.edit product_category_name")#</th>
				<td class="table-white"><input name="product_category_name" size="50" type="text" value="#form.product_category_name#" maxlength="100" /></td>
			</tr>
			<tr>
				<th style="white-space:nowrap; vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Lead Email","member.product.category.edit product_category_email")#</th>
				<td class="table-white"><input name="product_category_email" size="50" type="text" value="#form.product_category_email#" maxlength="100" />
					(Leave blank to use default system routing)</td>
			</tr>
			<tr>
				<th class="table-white" style="width:1%; white-space:nowrap;">#application.zcore.functions.zOutputHelpToolTip("Photos","member.product.category.edit product_category_image_library_id")#</th>
				<td colspan="2" class="table-white"><cfscript>
				var ts=structnew();
				ts.name="product_category_image_library_id";
				ts.value=form.product_category_image_library_id;
				application.zcore.imageLibraryCom.getLibraryForm(ts);
				</cfscript></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Full Text","member.product.category.edit product_category_text")#</th>
				<td style="vertical-align:top; "><cfscript>
            
            htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
            htmlEditor.instanceName	= "product_category_text";
            htmlEditor.value			= form.product_category_text;
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
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Slideshow","member.product.category.edit product_category_slideshow_id")#</th>
				<td style="vertical-align:top; "><cfscript>
					selectStruct = StructNew();
					selectStruct.name = "product_category_slideshow_id";
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
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Change Parent Category","member.product.category.edit product_category_parent_id")#</th>
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
					selectStruct.name = "product_category_parent_id";
					selectStruct.selectLabel ="-- Product Home Page --";
					selectStruct.listLabels = ArrayToList(childStruct.arrCategoryName,chr(9));
					selectStruct.listValues = ArrayToList(childStruct.arrCategoryId,chr(9));
					selectStruct.listLabelsDelimiter = chr(9); // tab delimiter
					selectStruct.listValuesDelimiter = chr(9);
					if(currentMethod EQ 'edit'){
						selectStruct.onChange="preventSameParent(this, #form.product_category_id#);";
					}
					//selectStruct.style="monodrop";
					application.zcore.functions.zInputSelectBox(selectStruct);
					</cfscript>
					<br />
					Associate this category with another category. </td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Keywords","member.product.category.edit product_category_metakey")#</th>
				<td style="vertical-align:top; "><textarea name="product_category_metakey" rows="5" cols="60">#form.product_category_metakey#</textarea></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Meta Description","member.product.category.edit product_category_metadesc")#</th>
				<td style="vertical-align:top; "><textarea name="product_category_metadesc" cols="60" rows="5">#form.product_category_metadesc#</textarea></td>
			</tr>
			<tr>
				<th style="vertical-align:top; ">#application.zcore.functions.zOutputHelpToolTip("Searchable","member.product.category.edit product_category_searchable")#</th>
				<td colspan="2" class="table-white"><input type="radio" name="product_category_searchable" <cfif application.zcore.functions.zso(form, 'product_category_searchable',false,1) EQ 1>checked="checked"</cfif> value="1" style="border:none; background:none;" />
					Yes
					<input type="radio" name="product_category_searchable" <cfif application.zcore.functions.zso(form, 'product_category_searchable',false,1) EQ 0>checked="checked"</cfif> value="0" style="border:none; background:none;" />
					No </td>
			</tr>
			<tr>
				<th style="white-space:nowrap; width:1%;vertical-align:top;">#application.zcore.functions.zOutputHelpToolTip("Override URL","member.product.category.edit product_category_url")#</th>
				<td colspan="2" class="table-white"  style="white-space:nowrap;">ADVANCED USERS ONLY:<br />
					<input name="product_category_url" type="text" value="#form.product_category_url#" size="50" /></td>
			</tr>
		</table>
		#tabCom.endFieldSet()#
		#tabCom.endTabMenu()#
	</form>
</cffunction>
</cfoutput>
</cfcomponent>
