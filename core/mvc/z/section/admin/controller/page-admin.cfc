<cfcomponent extends="zcorerootmapping.com.app.manager-base"> 	
<cfoutput>

<!--- 
// TODO: must make the urlId dynamic per site, and update in init
 --->
<cffunction name="getQuickLinks" localmode="modern" access="public">
	<cfscript>
	links=[];
	/*
	// This is an example of making quick links.  Change Section Link to the right feature
	variables.hasAccess=application.zcore.adminSecurityFilter.checkFeatureAccess("Section Link");
	if(variables.hasAccess){
		arrayAppend(links, { link:"/z/section/admin/page-admin/index?zManagerAddOnLoad=1", label:"Add Section Link" }); 
	}
	*/
	return links;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="private">
	<cfscript>  
	db=request.zos.queryObject;
	if(not application.zcore.app.siteHasApp("section")){
		application.zcore.functions.z404("Section app not enabled on this site.");
	}

	form.section_id=application.zcore.functions.zso(form, "section_id", true);
	db.sql="SELECT * 
	 from #db.table("section", request.zos.zcoreDatasource)#  
	WHERE  
	section_deleted = #db.param(0)# and 
	section_id = #db.param(form.section_id)#  and 
		site_id=#db.param(request.zos.globals.id)# "; 
	request.qsection=db.execute("qsection"); 
	
	if(request.qsection.recordcount EQ 0){
		application.zcore.status.setStatus(request.zsid, "Invalid Section", form, true);
		application.zcore.functions.zRedirect("/z/section/admin/section-admin/index?zsid=#request.zsid#");
	}

	variables.uploadPath=request.zos.globals.privateHomeDir&"zupload/page/";
	variables.displayPath="/zupload/page/";
	ts={
		// required 
		label:"Page Link",
		pluralLabel:"Page Links",
		tableName:"page",
		datasource:request.zos.zcoreDatasource,
		deletedField:"page_deleted",
		primaryKeyField:"page_id",
		methods:{ // callback functions to customize the manager data and layout
			getListData:"getListData", 
			getListReturnData:"getListReturnData",
			getListRow:"getListRow", // function receives struct named row 
			getEditData:"getEditData",
			getEditForm:"getEditForm",
			beforeUpdate:"beforeUpdate",
			afterUpdate:"afterUpdate",
			beforeInsert:"beforeInsert",
			afterInsert:"afterInsert",
			getDeleteData:"getDeleteData",
			executeDelete:"executeDelete"
		},
		listAdminWidth:260,

		searchIndexFields:{
			title:"page_name", 
			summary:"page_summary",
			fullText:"fullText",
			// image or image_library_id can be used
			// image:"", 
			image_library_id:"page_image_library_id",
			datetime:"page_updated_datetime",
			app_id:"page",
		},
		uniqueURLField:"page_unique_url",
		urlID:application.zcore.app.getAppData("section").optionStruct.section_config_url_page_id, 
		viewScriptName:"/z/section/page/view",
		activeField:"page_status",
		metaFields:{
			title:"page_metatitle",
			keywords:"page_metakey",
			description:"page_metadesc",
		},
		//optional
		requiredParams:["section_id" ],
		requiredEditParams:[],

		customInsertUpdate:false,
		hasSiteId:true,
		sortField:"page_sort",
		rowSortingEnabled:true,
		quickLinks:getQuickLinks(),
		imageLibraryFields:["page_image_library_id"],
		validateFields:{
			"page_name":{ required:true } 
		},
		imageFields:[],
		fileFields:[],
		// optional
		requireFeatureAccess:"Pages",
		pagination:false,
		paginationIndex:"zIndex",
		pageZSID:"zPageId",
		perpage:10,
		title:"Pages",
		prefixURL:"/z/section/admin/page-admin/",
		navLinks:[{
			label:"Sections",
			link:"/z/section/admin/section-admin/index"
		}],
		titleLinks:[],
		columnSortingEnabled:false,
		columns:[{
				label:"ID",
				field:"page_id"
			}, 
			{
				label:"Name",
				field:"page_name"
			},
			{
				label:"Updated",
				field:"page_updated_datetime"
			},
			{
				label:"Admin",
				field:""
			}
		]
	};
	
	// these are the foreign table breadcrumbs
	if(request.qsection.recordcount NEQ 0){
		arrayAppend(ts.navLinks, {
			label:"Pages",
			link:"/z/section/admin/section-admin/index"
		});
		arrayAppend(ts.navLinks, {
			label:"#request.qsection.section_name# Pages"
		});
	}
	super.init(ts);
	</cfscript>
</cffunction>


<cffunction name="delete" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	super.delete();
	</cfscript>
</cffunction>

<cffunction name="insert" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	update();
	</cfscript>
</cffunction>

<cffunction name="update" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	super.update();
	</cfscript>
</cffunction>

<cffunction name="add" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	edit();
	</cfscript>
</cffunction>

<cffunction name="edit" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	// TODO: need to get parent field to passthrough: page_parent_id
	super.edit();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
 	init();
	super.index();
	</cfscript>
</cffunction> 

<cffunction name="getDeleteData" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject; 
	rs={};
	db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)#
	WHERE page_id= #db.param(application.zcore.functions.zso(form,"page_id"))# and  
	page_deleted = #db.param(0)#   and 
		site_id=#db.param(request.zos.globals.id)# ";
	rs.qData=db.execute("qData");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="executeDelete" localmode="modern" access="private">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	var db=request.zos.queryObject;  
	for(row in ss.qData){  
		deleteRow(row);
	}
	return {success:true};
	</cfscript>
</cffunction>
 

<cffunction name="deleteRow" localmode="modern" access="remote" roles="administrator">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	var db=request.zos.queryObject; 
	row=arguments.row; 

	db.sql="UPDATE #db.table("page", request.zos.zcoreDatasource)# 
	SET page_deleted=#db.param(row.page_id)#, 
	page_updated_datetime=#db.param(request.zos.mysqlnow)#  
	WHERE page_id = #db.param(row.page_id)# and 
	section_id=#db.param(row.section_id)# and 
	site_id = #db.param(request.zos.globals.id)# and 
	page_deleted=#db.param(0)# ";
	db.execute("q"); 

	return true; 
	</cfscript> 
</cffunction>


<cffunction name="beforeUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	db=request.zos.queryObject;
	rs={success:true};

	// handle custom validation here
	error=false;
	 
	form.section_id=application.zcore.functions.zso(form, "section_id", true);
	if(form.section_id NEQ 0){ 
		if(request.qsection.recordcount EQ 0){
			application.zcore.status.setStatus(request.zsid, "Invalid Page selection.", form, true);
			error=true;
		}
	}   
	if(error){
		return {success:false};
	}
	csn=form.page_name&" "&form.page_id&" "& form.page_summary&" "& form.page_text&" "&form.page_text2&" "&form.page_text3;
	form.page_search=application.zcore.functions.zCleanSearchText(csn, true); 
	if(application.zcore.functions.zso(form, 'convertLinks') EQ 1){
		form.page_text=application.zcore.functions.zProcessAndStoreLinksInHTML(form.page_name, form.page_text);
		form.page_text2&"_2"=application.zcore.functions.zProcessAndStoreLinksInHTML(form.page_name&"_2", form.page_text2);
		form.page_text3&"_3"=application.zcore.functions.zProcessAndStoreLinksInHTML(form.page_name&"_3", form.page_text3);
		form.page_summary=application.zcore.functions.zProcessAndStoreLinksInHTML(form.page_name, form.page_summary);
	} 
	form.page_updated_datetime=request.zos.mysqlnow;

	ts={
		id:form.page_id,
		title:form.page_name, 
		summary:form.page_summary,
		fullText:form.page_search,
		// image or image_library_id can be used
		// image:"", 
		image_library_id:"page_image_library_id",
		datetime:form.page_updated_datetime,
		app_id:"page",
		url:application.zcore.app.getAppCFC("section").getPageURL(form),
		user_group_id:""
	};

	updateSearchIndex(ts);

	db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)#
	WHERE  
	page_deleted = #db.param(0)# and  
	section_id = #db.param(form.section_id)# and 
	page_id=#db.param(form.page_id)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	rs.qData=db.execute("qData"); 
	return rs;
	</cfscript>
</cffunction>

<cffunction name="afterUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	rs={success:true};
  
	return rs;
	</cfscript>
</cffunction>

<cffunction name="beforeInsert" localmode="modern" access="private" returntype="struct">
	<cfscript> 
	// you can optional make insert have custom validation

	rs=beforeUpdate();
	return rs;
	</cfscript>
</cffunction>

<cffunction name="afterInsert" localmode="modern" access="private" returntype="struct">
	<cfscript>
	rs={success:true};
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getEditData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 

	form.page_id=application.zcore.functions.zso(form, "page_id", true, 0);
	db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)#
	WHERE  
	page_deleted = #db.param(0)# and  
	section_id=#db.param(form.section_id)# and 
	page_id=#db.param(form.page_id)# and 
	site_id=#db.param(request.zos.globals.id)# "; 
	rs={}; 
	rs.qData=db.execute("qData");

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListReturnData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 
	form.page_id=application.zcore.functions.zso(form, "page_id", true, 0);
	
	db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)#
	WHERE  
	page_deleted = #db.param(0)# and  
	section_id=#db.param(form.section_id)# and 
	page_id=#db.param(form.page_id)# and 
	site_id=#db.param(request.zos.globals.id)# ";
		
	rs={};
	rs.qData=db.execute("qData");

	return rs;
	</cfscript>
</cffunction>


<cffunction name="getEditForm" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject; 

	rs={
		javascriptChangeCallback:"",
		javascriptLoadCallback:"",
		tabs:{
			"Basic":{
				fields:[]
			},
			"Advanced":{
				fields:[]
			}
		}
	};
	// basic fields
	fs=[];
 
	savecontent variable="field"{
		echo('<input type="hidden" name="section_id" id="section_id" value="#htmleditformat(application.zcore.functions.zso(form, "section_id"))#" /> '); 
	}
	arrayAppend(fs, {label:"", hidden:true, required:true, field:field});
	   
	savecontent variable="field"{
		echo('<input type="text" name="page_name" id="page_name"  style="width:95%;"   value="#htmleditformat(application.zcore.functions.zso(form, "page_name"))#" /> ');
	}
	arrayAppend(fs, {label:"Name", required: true,  field:field});
		 
	
	savecontent variable="field"{
		htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
		htmlEditor.instanceName	= "page_summary";
		htmlEditor.value			= form.page_summary;
		htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
		htmlEditor.height		= 250;
		htmlEditor.create();
	}
	arrayAppend(fs, {label:"Summary Text", field:field});
	
	savecontent variable="field"{
		htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
		htmlEditor.instanceName	= "page_text";
		htmlEditor.value			= form.page_text;
		htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
		htmlEditor.height		= 400;
		htmlEditor.create();
	}
	arrayAppend(fs, {label:"Body Column 1", field:field});
	
	savecontent variable="field"{
		htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
		htmlEditor.instanceName	= "page_text2";
		htmlEditor.value			= form.page_text2;
		htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
		htmlEditor.height		= 400;
		htmlEditor.create();
	}
	arrayAppend(fs, {label:"Body Column 2", field:field});
	
	savecontent variable="field"{
		htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
		htmlEditor.instanceName	= "page_text3";
		htmlEditor.value			= form.page_text3;
		htmlEditor.width			= "#request.zos.globals.maximagewidth#px";//"100%";
		htmlEditor.height		= 400;
		htmlEditor.create();
	}
	arrayAppend(fs, {label:"Body Column 3", field:field});
	
	savecontent variable="field"{
		form.convertLinks=application.zcore.functions.zso(form, 'convertLinks', true, 0); 
		ts = StructNew();
		ts.name = "convertLinks";
		ts.radio=true;
		ts.separator=" ";
		ts.listValuesDelimiter="|";
		ts.listLabelsDelimiter="|";
		ts.listLabels="Yes|No";
		ts.listValues="1|0";
		application.zcore.functions.zInput_Checkbox(ts);
		echo(' | Selecting "Yes", will cache the external images in the html editor to this domain.');
	}
	arrayAppend(fs, {label:"Cache External Images", field:field});
	
	savecontent variable="field"{
		ts=structnew();
		ts.name="page_image_library_id";
		ts.value=form.page_image_library_id;
		application.zcore.imageLibraryCom.getLibraryForm(ts);
	}
	arrayAppend(fs, {label:"Photos", field:field});
	
	savecontent variable="field"{
		ts=structnew();
		ts.name="page_image_library_layout";
		ts.value=form.page_image_library_layout;
		application.zcore.imageLibraryCom.getLayoutTypeForm(ts);
	}
	arrayAppend(fs, {label:"Photo Layout", field:field});
	/*
	savecontent variable="field"{
		echo('');
	}
	arrayAppend(fs, {label:"", field:field});
  	*/
	rs.tabs.basic.fields=fs;
	// advanced fields
	/*
	fs=[];
	savecontent variable="field"{
		echo('<input type="text" name="page_advanced" value="#htmleditformat(form.page_advanced)#" />');
	}
	arrayAppend(fs, {label:"Advanced Field", field:field});

	rs.tabs.advanced.fields=fs; 
	*/

	return rs;
	</cfscript> 
</cffunction>

<cffunction name="getListData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 

	form.page_id=application.zcore.functions.zso(form, "page_id", true, 0); 
	form.page_status=application.zcore.functions.zso(form, "page_status", false, "1"); 
	db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)#  
	WHERE  
	section_id=#db.param(form.section_id)# and 
	page_deleted = #db.param(0)# and    
	site_id=#db.param(request.zos.globals.id)#  "; 
	if(form.page_status NEQ ""){
		db.sql&=" and page_status = #db.param(form.page_status)# ";
	}
	db.sql&=" ORDER BY page.page_sort ASC 
	LIMIT #db.param((form.zIndex-1)*variables.perpage)#, #db.param(variables.perpage)# ";
	rs={};
	rs.qData=db.execute("qData");  

	rs.searchFields=[ 
		// TODO: add search fields{
	{
		fields:[{
			formField:"Active: "&application.zcore.functions.zInput_Boolean("page_status"),
			field:variables.activeField
		}]
	}
	];
 
	db.sql="SELECT count(*) count FROM #db.table("page", request.zos.zcoreDatasource)#
	WHERE  
	section_id=#db.param(form.section_id)# and 
	page_deleted = #db.param(0)# and   
		site_id=#db.param(request.zos.globals.id)# "; 
	if(form.page_status NEQ ""){
		db.sql&=" and page_status = #db.param(form.page_status)# ";
	}
	rs.qCount=db.execute("qCount");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListRow" localmode="modern" access="private">
	<cfargument name="row" type="struct" required="yes">
	<cfargument name="columns" type="array" required="yes">
	<cfscript>
	row=arguments.row;
	columns=arguments.columns; 
	arrayAppend(columns, {field: row.page_id});  

	arrayAppend(columns, {field: row.page_name }); 
	arrayAppend(columns, {field: application.zcore.functions.zTimeSinceDate(row.page_updated_datetime)});  
	savecontent variable="field"{ 
	 displayRowSortButton(row.page_id);
		 
		ts={
			buttons:[{
				title:"View",
				icon:"eye",
				link:application.zcore.app.getAppCFC("section").getPageURL(row),
				label:"",
				target:"_blank"
			}, {
				title:"Edit",
				icon:"cog",
				link:variables.prefixURL&"edit?page_id=#row.page_id#&modalpopforced=1&&section_id=#form.section_id#",
				label:"",
				enableEditAjax:true
			}]
		};  
		arrayAppend(ts.buttons, {
			title:"Delete",
			icon:"trash",
			link:"/z/section/admin/page-admin/delete?page_id=#row.page_id#&amp;returnJson=1&amp;confirm=1&section_id=#form.section_id#",
			label:"",
			enableDeleteAjax:true
		});
		displayAdminMenu(ts);

	}
	arrayAppend(columns, {field: field, class:"z-manager-admin", style:"width:200px; max-width:100%;"});
	</cfscript> 
</cffunction>	
<!--- 
<cffunction name="index" localmode="modern" access="remote" roles="member">
	<cfscript>
	var db=request.zos.queryObject; 

	application.zcore.template.setTag("title", "Pages");
 
	if(not application.zcore.adminSecurityFilter.checkFeatureAccess("Pages")){
		return;
	} 
	init();  
	application.zcore.functions.zStatusHandler(request.zsid,true, false, form);  
	form.searchText=replace(application.zcore.functions.zso(form, 'searchText'), '+', ' ', 'all');
	form.searchTextOriginal=replace(replace(replace(form.searchText, '+', ' ', 'all'), '@', '_', 'all'), '"', '', "all");
	form.searchText=application.zcore.functions.zCleanSearchText(form.searchText, true);
	if(form.searchText NEQ "" and isNumeric(form.searchText) EQ false and len(form.searchText) LTE 2){
		application.zcore.status.setStatus(request.zsid,"The search searchText must be 3 or more characters.",form);
		application.zcore.functions.zRedirect("/z/section/admin/page-admin/index?zsid=#request.zsid#");
	}
	searchTextReg=rereplace(form.searchText,"[^A-Za-z0-9[[:white:]]]*",".","ALL");
	searchTextOReg=rereplace(form.searchTextOriginal,"[^A-Za-z0-9 ]*",".","ALL");
	Request.zScriptName2 = "/z/section/admin/page-admin/index?pageStatus=#form.pageStatus#&searchtext=#urlencodedformat(application.zcore.functions.zso(form, 'searchtext'))#&page_parent_id=#application.zcore.functions.zso(form, 'page_parent_id')#";
	 
	writeoutput('
	<div class="z-manager-list-view">
		<div class="z-float">
			<h2 id="pages_regular" style="display:inline-block;">Pages</h2>');
 
	echo(' &nbsp;&nbsp; ');
	echo('<a href="/z/section/admin/page-admin/add?page_parent_id=#application.zcore.functions.zso(form, 'page_parent_id')#&amp;return=#urlencodedformat(request.zos.originalURL&"?"&replace(request.zos.cgi.query_string, "zsid=", "ztv=", "all"))#" class="z-button">Add</a> '); 
	writeoutput('	</div>');
 
	ts=structnew();
	ts.image_library_id_field="page.page_image_library_id";
	ts.count =  1; 
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="SELECT * ";
	if(form.searchText NEQ ''){
		db.sql&="MATCH(page.page_search) AGAINST (#db.param(form.searchText)#) as score , 
			MATCH(page.page_search) AGAINST (#db.param(form.searchTextOriginal)#) as score2 , 
		if(page.page_id = #db.param(form.searchText)#, #db.param(1)#,#db.param(0)#) matchingId, ";
	}
	db.sql&=" 
	#db.trustedSQL(rs2.select)#  
	FROM ( #db.table("page", request.zos.zcoreDatasource)# page ) 
	#db.trustedSQL(rs2.leftJoin)# 
	WHERE 
	page.site_id = #db.param(request.zos.globals.id)# ";
	if(form.searchText NEQ ''){
		db.sql&=" and 
		
		(#db.trustedSQL("concat(page.page_id)")# like 
		#db.param('%#form.searchTextOriginal#%')#  or 
		page.page_text like #db.param('%#form.searchTextOriginal#%')# or 
		(
		(( "; 
			db.sql&=" MATCH(page.page_search) AGAINST (#db.param(form.searchText)#) or 
			MATCH(page.page_search) AGAINST (#db.param('+#replace(trim(replace(replace(form.searchText, '-', ' ', 'all'), '  ', ' ', 'all')),' ','* +','ALL')#*')# IN BOOLEAN MODE) "; 
		db.sql&=" ) or ( ";
		 
			db.sql&=" MATCH(page.page_search) AGAINST (#db.param(form.searchTextOriginal)#) or 
			MATCH(page.page_search) AGAINST (#db.param('+#replace(trim(replace(replace(form.searchTextOriginal, '-', ' ', 'all'), '  ', ' ', 'all')),' ','* +','ALL')#*')# IN BOOLEAN MODE) "; 
		db.sql&=" 
		)) 
		)) "; 
	}
	if(form.pageStatus EQ 1){
		db.sql&=" and page.page_status<>#db.param('2')# ";
	}else if(form.pageStatus EQ 0){
		db.sql&=" and page.page_status=#db.param('2')# ";
	}
	db.sql&=" and page.page_deleted = #db.param('0')#   ";
 
	db.sql&=" 
	GROUP BY page.page_id 
	ORDER BY  page.page_name ASC "; 
	qSite=db.execute("qSite");
	form.searchText=form.searchTextOriginal; 
	g="";
	arrNav=ArrayNew(1);
	/*if(application.zcore.functions.zso(form, 'searchtext') EQ ''){
		if(qsite.recordcount EQ 0){
			cpi=application.zcore.functions.zso(form, 'page_parent_id',true);
		}else{
			cpi=qsite.page_parent_id;
		}
	}else{
		cpi=0;
	}*/
	arrName=ArrayNew(1);
	parentparentid='0';
	parentChildGroupId=0; 
	/*for(g=1;g LTE 255;g++){
		db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)# page 
		WHERE page_id = #db.param(cpi)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		page_deleted=#db.param(0)# ";
		qpar=db.execute("qpar");
		if(qpar.recordcount EQ 0){
			break;
		}
		if(g EQ 1){
			parentParentId=qpar.page_parent_id;
		}
		ArrayAppend(arrName, qpar.page_name);
		arrayappend(arrNav, '<a href="/z/section/admin/page-admin/index?page_parent_id=#qpar.page_id#">#qPar.page_name#</a> / ');
		cpi=qpar.page_parent_id;
		if(cpi EQ 0){
			break;
		}
	} */
	arrSearch=listtoarray(form.searchtext," ");
	if(arraylen(arrSearch) EQ 0){
		arrSearch[1]="";	
	}
	</cfscript>
	 

	<form name="myForm22" action="/z/section/admin/page-admin/index" method="GET" style="margin:0px;">  
		#application.zcore.siteOptionCom.setIdHiddenField()#
		<div class="z-float-left z-pr-10 z-pb-10">
			Search: 
			<input type="text" name="searchtext" id="searchtext" value="#htmleditformat(application.zcore.functions.zso(form, 'searchtext'))#" style="min-width:100px; width:300px;max-width:100%; min-width:auto;" size="20" maxchars="10" /> 
		</div>
		<div class="z-float-left z-pr-10 z-pb-10">
			Active: #application.zcore.functions.zInput_Boolean("pageStatus")# 
			</div>
			<div class="z-float-left z-pr-10 z-pb-10">
			<input type="submit" name="searchForm" value="Search" class="z-manager-search-button" /> 
			<cfif application.zcore.functions.zso(form, 'searchtext') NEQ ''>
				<input type="button" name="searchForm2" value="Clear Search" class="z-manager-search-button" onclick="window.location.href='/z/section/admin/page-admin/index';" />
			</cfif>
		</div>
		<input type="hidden" name="zIndex" value="1" />
	</form>
	<cfif qSite.recordcount EQ 0>
		<div class="z-float z-mb-10">No page added yet. </div>
	<cfelse>
		<table id="sortRowTable" style="border-spacing:0px; width:100%;" class="table-list">
			<thead>
			<tr>
				<th class="z-hide-at-767">ID</th>
				<th class="z-hide-at-767">Photo</th>
				<th>
					Title
				 </th> 
				<th>Last Updated</th> 
				<th>Admin</th>
			</tr>
			</thead>
			<tbody>
			<cfscript>
			pageLookupStruct={}; 
			request.parentLookupStruct={}; 
			arrOrder=[];
			currentRow=0;
  
			for(row in qSite){  
				currentRow++;
				echo('<tr '); 
				if(currentrow MOD 2 EQ 0){
					echo('class="row1"');
				}else{
					echo('class="row2"');
				}
				echo('>');
				getLayoutRowHTML(row);
				echo('</tr>');
			}
			</cfscript>
			</tbody>
		</table> 
	</cfif> 
 
	</div>
</cffunction>

<cffunction name="getReturnLayoutRowHTML" localmode="modern" access="remote" roles="member">
	<cfscript> 
	init();


	var db=request.zos.queryObject; 
	form.site_x_option_group_set_id=application.zcore.functions.zso(form, 'site_x_option_group_set_id', true, 0);
	form.page_id=application.zcore.functions.zso(form, "page_id", true, 0);
	form.mode=application.zcore.functions.zso(form, 'mode', false, 'sorting');

	ts=structnew();
	ts.image_library_id_field="page.page_image_library_id";
	ts.count =  1; 
	rs2=application.zcore.imageLibraryCom.getImageSQL(ts);  
	db.sql="SELECT *, 
	count(c2.page_id) children 
	#db.trustedSQL(rs2.select)#  
	FROM #db.table("page", request.zos.zcoreDatasource)#

	LEFT JOIN #db.table("page", request.zos.zcoreDatasource)# c2 ON 
	c2.page_parent_id = page.page_id and 
	c2.page_deleted= #db.param(0)# and 
	c2.site_id = page.site_id 
	#db.trustedSQL(rs2.leftJoin)#
	WHERE   
	page.page_deleted = #db.param(0)# and  
	page.page_id=#db.param(form.page_id)# and 
	page.site_id=#db.param(request.zos.globals.id)# 
	GROUP BY page.page_id ";
	qpage=db.execute("qpage");

	if(qpage.page_parent_id NEQ 0){
		db.sql="SELECT * FROM #db.table("page", request.zos.zcoreDatasource)# page 
		WHERE page_id = #db.param(qpage.page_parent_id)# and 
		site_id = #db.param(request.zos.globals.id)# and 
		site_x_option_group_set_id = #db.param(form.site_x_option_group_set_id)# and 
		page_deleted=#db.param(0)#  ";
		qpagep=db.execute("qpagep");
		if(qpagep.recordcount EQ 0){
			application.zcore.functions.zredirect("/z/section/admin/page-admin/index");
		}
		request.parentChildSorting=qpagep.page_child_sorting;
	}else{
		request.parentChildSorting=0;
	}
	 
	savecontent variable="rowOut"{
		for(row in qpage){
			getLayoutRowHTML(row);
		}
	}

	echo('done.<script type="text/javascript">
	window.parent.zReplaceTableRecordRow("#jsstringformat(rowOut)#");
	window.parent.zCloseModal();
	</script>');
	abort;
	</cfscript>
</cffunction>

<cffunction name="getLayoutRowHTML" localmode="modern" access="public">
	<cfargument name="row" type="struct" required="yes">
	<cfscript>
	row=arguments.row;  
	indentCount=0; 
	loopCount=0;
	indentChars=""; 
	ts=structnew();
	ts.image_library_id=row.page_image_library_id;
	ts.output=false;
	ts.struct=row;
	ts.size="100x70";
	ts.crop=1;
	ts.count = 1;
	arrImages=application.zcore.imageLibraryCom.displayImageFromStruct(ts);
	pagephoto99=""; 
	if(arraylen(arrImages) NEQ 0){
		pagephoto99=(arrImages[1].link);
	}
	</cfscript>
	<td class="z-hide-at-767" style="vertical-align:top; width:30px; ">#row.page_id#</td>
	<td class="z-hide-at-767" style="vertical-align:top; width:100px; ">
		<cfif pagephoto99 NEQ "">
			<img alt="Image" src="#request.zos.currentHostName&pagephoto99#" style="max-width:100%;" /></a>
		<cfelse>
			&nbsp;
		</cfif></td>
	<td style="vertical-align:top; padding-left:#indentCount*20#px;"> 
			#row.page_name# 
	</td> 

	<td>#application.zcore.functions.zTimeSinceDate(row.page_updated_datetime)#</td>
	<td style="vertical-align:top; " class="z-manager-admin">

		<cfif application.zcore.functions.zso(form, 'searchtext') EQ ''> 
			<div class="z-manager-button-container">
				#variables.queueSortCom.getAjaxHandleButton(row.page_id)#
			</div>
			
		</cfif> 
		<cfif row.page_status EQ 2>
			<div class="z-manager-button-container">
				<a title="Inactive"><i class="fa fa-times-circle" aria-hidden="true" style="color:##900;"></i></a>
			</div>
		<cfelse> 
			<div class="z-manager-button-container">
				<a title="<cfif row.page_status EQ '3'>Sold<cfelseif row.page_status EQ '4'>Under Contract<cfelse>Active</cfif>"><i class="fa fa-check-circle" aria-hidden="true" style="color:##090;"></i></a>
			</div>
		</cfif>
		<div class="z-manager-button-container"> 
			<a href="<cfif row.page_unique_url_only NEQ ''>#row.page_unique_url_only#<cfelse><cfif row.page_unique_url NEQ ''>#row.page_unique_url#<cfelse>/#application.zcore.functions.zURLEncode(row.page_name,'-')#-#application.zcore.app.getAppData("page").optionStruct.page_config_url_article_id#-#row.page_id#.html</cfif></cfif><cfif row.page_status EQ 2>?preview=1</cfif>" class="z-manager-view" target="_blank" title="View"><i class="fa fa-eye" aria-hidden="true"></i></a> 
		</div>
		<cfscript>
		deleteDisabled=true;
		if(row.page_locked EQ 0 or application.zcore.user.checkSiteAccess()){
			if(row.children EQ 0){
				deleteDisabled=false;
			}
		}
		</cfscript>
		<div class="z-manager-button-container">

			<a href="##" class="z-manager-edit" id="z-manager-edit#row.page_id#" title="Edit"><i class="fa fa-cog" aria-hidden="true"></i></a> 
			<div class="z-manager-edit-menu">
				<a href="/z/section/admin/page-admin/edit?page_id=#row.page_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#&amp;modalpopforced=1&amp;mode=#form.mode#" onclick="zTableRecordEdit(this);  return false;">Edit Page</a>
				<cfif (structkeyexists(form, 'qpagep') EQ false or qpagep.page_featured_listing_parent_page NEQ 1)>
					<a href="/z/section/admin/page-admin/add?page_parent_id=#row.page_id#&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#">New Child Page</a>
				</cfif>
				<cfif form.mode EQ "sorting" and row.children NEQ 0>
					<a href="/z/section/admin/page-admin/index?page_parent_id=#row.page_id#">Manage #row.children# Sub-Pages</a>
				</cfif>
				<cfif request.zos.isTestServer>
					<cfscript>
					ts=structnew();
					ts.saveIdURL="/z/section/admin/page-admin/saveGridId?page_id=#row.page_id#";
					ts.grid_id=row.page_grid_id;
					application.zcore.grid.getGridForm(ts); 
					</cfscript> 
				</cfif> 

				<cfif application.zcore.user.checkServerAccess()>
					<cfif row.page_hide_edit EQ 1>
						<a href="/z/section/admin/page-admin/changeEdit?show=0&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#&amp;page_id=#row.page_id#">Show This Page</a>
					<cfelse>
						<a href="/z/section/admin/page-admin/changeEdit?show=1&amp;returnURL=#urlencodedformat(request.zos.originalURL&"?"&request.zos.cgi.query_string)#&amp;page_id=#row.page_id#">Hide This Page</a>
					</cfif> 
				</cfif>
				<cfif deleteDisabled>
					<a href="##">Delete Disabled</a>
				</cfif>

			</div>
		</div> 
		<cfif form.mode EQ "sorting" and row.children NEQ 0>
			<div class="z-manager-button-container">
				<a class="z-manager-edit" title="Manage #row.children# pages connected to this page" href="/z/section/admin/page-admin/index?page_parent_id=#row.page_id#"><i class="fa fa-sitemap" aria-hidden="true"></i></a>
			</div>
		</cfif>

		<cfif not deleteDisabled>
			<div class="z-manager-button-container">
				<a href="##" class="z-manager-delete" title="Delete" onclick="zDeleteTableRecordRow(this, '/z/section/admin/page-admin/delete?page_id=#row.page_id#&amp;returnJson=1&amp;confirm=1'); return false;"><i class="fa fa-trash" aria-hidden="true"></i></a>
			</div>
		</cfif>
	</td>
</cffunction>
 

 --->
</cfoutput>
</cfcomponent>