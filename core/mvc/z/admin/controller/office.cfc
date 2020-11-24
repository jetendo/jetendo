<cfcomponent extends="zcorerootmapping.com.app.manager-base">
<cfoutput>   
<cffunction name="getQuickLinks" localmode="modern" access="public">
	<cfscript>
	links=[];
	variables.hasUserAccess=application.zcore.adminSecurityFilter.checkFeatureAccess("Users");
	variables.hasOfficeAccess=application.zcore.adminSecurityFilter.checkFeatureAccess("Locations");
	variables.hasLeadsAccess=application.zcore.adminSecurityFilter.checkFeatureAccess("Leads");
	if(variables.hasOfficeAccess){
		arrayAppend(links, { link:"/z/admin/office/index?zManagerAddOnLoad=1", label:"Add Location" }); 
	}
	if(variables.hasUserAccess){
		arrayAppend(links, { link:"/z/admin/member/add", label:"Add User" });
		arrayAppend(links, { link:"/z/admin/member/import", target:"_blank", label:"Import Users" });
	}
	if(variables.hasOfficeAccess){
		arrayAppend(links, { link:"/z/admin/office/index", label:"Locations" });
	}
	if(variables.hasUserAccess){
		arrayAppend(links, { link:"/z/admin/member/showPublicUsers", label:"Public Users" });
		arrayAppend(links, { link:"/z/admin/member/index", label:"Site Manager Users" });
		arrayAppend(links, { link:"/z/misc/members/index", target:"_blank", label:"View Public Profiles" });
		arrayAppend(links, { link:"/z/user/home/index", target:"_blank", label:"View Public User Home Page" });
	} 
	return links;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="private">
	<cfscript> 
	if(structkeyexists(request.zsession.user, "sync_site_id_list") and request.zsession.user.sync_site_id_list NEQ "" and request.zsession.user.sync_site_id_list NEQ ",,"){
		if(request.zsession.user.site_id EQ request.zos.globals.id){
			application.zcore.status.setStatus(request.zsid, "You may not manage users on this site, please contact the supervisor.", form, true);
			application.zcore.functions.zRedirect("/z/admin/admin-home/index?zsid=#request.zsid#");
		}

	}
	variables.uploadPath=request.zos.globals.privateHomeDir&"zupload/office/";
	variables.displayPath="/zupload/office/";
	ts={
		// required 
		label:"Location",
		pluralLabel:"Locations",
		tableName:"office",
		datasource:request.zos.zcoreDatasource,
		deletedField:"office_deleted",
		primaryKeyField:"office_id",
		methods:{ // callback functions to customize the manager data and layout
			getListData:'getListData', 
			getListReturnData:'getListReturnData',
			getListRow:'getListRow', // function receives struct named row 
			getEditData:'getEditData',
			getEditForm:'getEditForm',
			beforeUpdate:'beforeUpdate',
			afterUpdate:'afterUpdate',
			beforeInsert:'beforeInsert',
			afterInsert:'afterInsert',
			getDeleteData:'getDeleteData',
			executeDelete:'executeDelete',
			afterSort:'afterSort'
		},

		//optional
		requiredParams:[],

		customInsertUpdate:false,
		sortField:"office_sort",
		hasSiteId:true,
		rowSortingEnabled:true,
		metaField:"office_meta_json",
		quickLinks:getQuickLinks(),
		imageLibraryFields:["office_image_library_id"],

		validateFields:{
			"office_name":{	required:true }
		},
		imageFields:[],
		fileFields:[],
		// optional
		requireFeatureAccess:"Locations",
		pagination:false,
		paginationIndex:"zIndex",
		pageZSID:"zPageId",
		perpage:10000,
		title:"Locations",
		prefixURL:"/z/admin/office/",
		navLinks:[],
		titleLinks:[],
		columnSortingEnabled:true,
		columns:[{
			label:"ID"
		},{
			label:'Photo',
			field:'office_image_library_id'
		},{
			label:'Name',
			field:'office_name',
			sortable:true
		},{
			label:'Address',
			field:'office_address'
		},{
			label:'Phone',
			field:'office_phone'
		},{
			label:'Has Coordinates',
			field:'office_map_location'
		},{
			label:'Manager Email List',
			field:'office_manager_email_list'
		},{
			label:'Updated',
			field:'office_updated_datetime'
		},{
			label:'Admin'
		}]
};
	super.init(ts); 
	</cfscript>
</cffunction>	 


<cffunction name="afterSort" localmode="modern" access="remote" roles="administrator">
	<cfscript>
	init();
	updateOfficeCache(); 
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
	super.edit();
	</cfscript>
</cffunction>

<cffunction name="index" localmode="modern" access="remote" roles="administrator">
	<cfscript> 
 	init();
	super.index();
	</cfscript>
</cffunction> 

<cffunction name="getOfficeCacheStruct" localmode="modern" access="public" returntype="struct">
	<cfargument name="site_id" type="string" required="yes">
	<cfscript>
	var db=request.zos.queryObject;  
	metaCom=createObject("component", "zcorerootmapping.com.zos.meta");
	db.sql="SELECT * 
	FROM #db.table("office", request.zos.zcoreDatasource)#  
	WHERE office.site_id = #db.param(arguments.site_id)# and 
	office_deleted = #db.param(0)# 
	ORDER BY office.office_name "; 
	qOffice=db.execute("qOffice");
	ts={};
	ts.arrOfficeSorted=[];
	ts.arrOfficeNameSorted=[];
	ts.officeLookupStruct={};
	for(row in qOffice){
		if(row.office_meta_json NEQ ""){
			row.metaData=metaCom.getData("office", row);
		}else{
			row.metaData={};
		}
		ts.officeLookupStruct[row.office_id]=row;
		arrayAppend(ts.arrOfficeNameSorted, row.office_id);
	}

	db.sql="SELECT * 
	FROM #db.table("office", request.zos.zcoreDatasource)#  
	WHERE office.site_id = #db.param(arguments.site_id)# and 
	office_deleted = #db.param(0)# 
	ORDER BY office.office_name "; 
	qOffice=db.execute("qOffice");
	arrOffice=[];
	for(row in qOffice){ 
		arrayAppend(ts.arrOfficeSorted, row.office_id);
	}
	return ts;
	</cfscript>
</cffunction>

<cffunction name="updateOfficeCache" localmode="modern" access="public">
	<cfscript>
	ts=getOfficeCacheStruct(request.zos.globals.id);
	application.siteStruct[request.zos.globals.id].offices=ts;
	</cfscript>
</cffunction>


<cffunction name="executeDelete" localmode="modern" access="private">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	var db=request.zos.queryObject; 
	db.sql="DELETE FROM #db.table("office", variables.datasource)#  
	WHERE office_id= #db.param(application.zcore.functions.zso(form, 'office_id'))# and 
	office_deleted = #db.param(0)# and 
	site_id = #db.param(request.zos.globals.id)# ";
	q=db.execute("q");

	updateOfficeCache();
	return {success:true};
	</cfscript>
</cffunction>

<cffunction name="getDeleteData" localmode="modern" access="private">
	<cfscript>
	var db=request.zos.queryObject; 
	rs={};
	db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# 
	WHERE office_id= #db.param(application.zcore.functions.zso(form,'office_id'))# and 
	office_deleted = #db.param(0)# and
	site_id = #db.param(request.zos.globals.id)#";
	rs.qData=db.execute("qData", "", 10000, "query", false);
	return rs;
	</cfscript>
</cffunction>

<cffunction name="beforeUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	db=request.zos.queryObject;
	rs={success:true};

	form.office_manager_email_list=application.zcore.functions.zso(form, 'office_manager_email_list');
	arrEmail=listToArray(form.office_manager_email_list, ",");
	arrNewEmail=[];

	for(email in arrEmail){
		email=trim(email);
		if(email EQ ""){
			// skip
		}else if(not application.zcore.functions.zEmailValidate(email)){
			rs.success=false;
			application.zcore.status.setStatus(request.zsid, "You must enter valid email address list for the manager email list.", form, true);
		}else{
			arrayAppend(arrNewEmail, trim(email));
		}
	}
	form.office_manager_email_list=arrayToList(arrNewEmail, ",");

	db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)#
	WHERE office_deleted = #db.param(0)# and  
	office_id=#db.param(form.office_id)# and 
	site_id=#db.param(request.zos.globals.id)# ";
	rs.qData=db.execute("qData");
	return rs;
	</cfscript>
</cffunction>

<cffunction name="afterUpdate" localmode="modern" access="private" returntype="struct">
	<cfscript>
	rs={success:true};
	updateOfficeCache();
	return rs;
	</cfscript>
</cffunction>

<cffunction name="beforeInsert" localmode="modern" access="private" returntype="struct">
	<cfscript> 
	rs=beforeUpdate();
	return rs;
	</cfscript>
</cffunction>

<cffunction name="afterInsert" localmode="modern" access="private" returntype="struct">
	<cfscript>
	rs={success:true};
	updateOfficeCache();
	return rs;
	</cfscript>
</cffunction>




<cffunction name="getEditData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 

	form.office_id=application.zcore.functions.zso(form, 'office_id', true);
	rs={};
	db.sql="SELECT * FROM #db.table("office", request.zos.zcoreDatasource)# office 
	WHERE site_id =#db.param(request.zos.globals.id)# and 
	office_deleted = #db.param(0)# and 
	office_id=#db.param(form.office_id)#";
	rs.qData=db.execute("qData");

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListReturnData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject;  

	ts=structnew();
	ts.image_library_id_field="office.office_image_library_id";
	ts.count = 1; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="SELECT * #db.trustedsql(rs.select)# 
	FROM #db.table("office", request.zos.zcoreDatasource)# 
	#db.trustedsql(rs.leftJoin)# 
	WHERE office.site_id = #db.param(request.zos.globals.id)# and 
	office_deleted = #db.param(0)# and 
	office_id=#db.param(form.office_id)#
	GROUP BY office.office_id "; 
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
		echo('<input type="text" name="office_name" value="#htmleditformat(form.office_name)#" />');
	}
	arrayAppend(fs, {label:'Location Name', required:true, field:field});
	savecontent variable="field"{
		echo('<input type="text" name="office_manager_email_list" value="#htmleditformat(form.office_manager_email_list)#" />');
		if(application.zcore.functions.zso(request.zos.globals, 'enableLeadReminderOfficeManagerCC', true, 0) EQ 1){
			echo('<br>Note: Managers are CC''d on lead notifications if this feature is enabled.');
		}
	}
	arrayAppend(fs, {label:'Manager Email List', field:field});

	savecontent variable="field"{
		htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
		htmlEditor.instanceName	= "office_description";
		htmlEditor.value			= form.office_description;
		htmlEditor.basePath		= '/';
		htmlEditor.width			= "100%";
		htmlEditor.height		= 300;
		htmlEditor.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
		htmlEditor.create();
	}
	arrayAppend(fs, {label:'Description', field:field});
	savecontent variable="field"{
		htmlEditor = application.zcore.functions.zcreateobject("component", "/zcorerootmapping/com/app/html-editor");
		htmlEditor.instanceName	= "office_hours";
		htmlEditor.value			= form.office_hours;
		htmlEditor.basePath		= '/';
		htmlEditor.width			= "100%";
		htmlEditor.height		= 200;
		htmlEditor.config.EditorAreaCSS=request.zos.globals.editorStylesheet;
		htmlEditor.create();
	}
	arrayAppend(fs, {label:'Hours', field:field});
				
	savecontent variable="field"{
		echo('<input type="text" name="office_phone" value="#htmleditformat(form.office_phone)#" />');
	}
	arrayAppend(fs, {label:'Phone', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="office_phone2" value="#htmleditformat(form.office_phone2)#" />');
	}
	arrayAppend(fs, {label:'Phone 2', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="office_fax" value="#htmleditformat(form.office_fax)#" />');
	}
	arrayAppend(fs, {label:'Fax', field:field});


	savecontent variable="field"{
		echo('<input type="text" name="office_address" id="office_address" value="#htmleditformat(form.office_address)#" />');
	}
	arrayAppend(fs, {label:'Address', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="office_address2" id="office_address2" value="#htmleditformat(form.office_address2)#" />');
	}
	arrayAppend(fs, {label:'Address 2', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="office_city" id="office_city" value="#htmleditformat(form.office_city)#" />');
	}
	arrayAppend(fs, {label:'City', field:field});

	savecontent variable="field"{
		echo(application.zcore.functions.zStateSelect("office_state", application.zcore.functions.zso(form,'office_state')));
	}
	arrayAppend(fs, {label:'State', field:field});

	savecontent variable="field"{
		echo('<input type="text" name="office_zip" id="office_zip" value="#htmleditformat(form.office_zip)#" />');
	}
	arrayAppend(fs, {label:'Postal Code', field:field});
	savecontent variable="field"{
		echo(application.zcore.functions.zCountrySelect("office_country", application.zcore.functions.zso(form,'office_country')));
	}
	arrayAppend(fs, {label:'Country', field:field});
	savecontent variable="field"{
		ts={
			name:"office_map_location",
			fields:{
				address:"office_address",
				city:"office_city",
				state:"office_state",
				zip:"office_zip",
				country:"office_country",
			}
		};
		echo(application.zcore.functions.zMapLocationPicker(ts)); 
	}
	arrayAppend(fs, {label:'Map Location', field:field}); 
  
	savecontent variable="field"{
		ts=structnew();
		ts.name="office_image_library_id";
		ts.value=form["office_image_library_id"];
		application.zcore.imageLibraryCom.getLibraryForm(ts); 
	}
	arrayAppend(fs, {label:'Photos', field:field});
	rs.tabs.basic.fields=fs;
	// advanced fields
	/*
	fs=[];
	savecontent variable="field"{
		echo('<input type="text" name="office_advanced" value="#htmleditformat(form.office_advanced)#" />');
	}
	arrayAppend(fs, {label:'Advanced Field', field:field});

	rs.tabs.advanced.fields=fs; 
	*/

	return rs;
	</cfscript> 
</cffunction>

<cffunction name="getListData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject; 

	form.search_name=application.zcore.functions.zso(form, 'search_name');

	ts=structnew();
	ts.image_library_id_field="office.office_image_library_id";
	ts.count = 1; // how many images to get
	rs=application.zcore.imageLibraryCom.getImageSQL(ts);
	db.sql="SELECT * #db.trustedsql(rs.select)# 
	FROM #db.table("office", request.zos.zcoreDatasource)# 
	#db.trustedsql(rs.leftJoin)# 
	WHERE office.site_id = #db.param(request.zos.globals.id)# and 
	office_deleted = #db.param(0)# ";
	if(form.search_name NEQ ""){
		db.sql&=" and office_name LIKE #db.param('%'&form.search_name&'%')# ";
	}
	db.sql&=" GROUP BY office.office_id "; 
	sortColumnSQL=getSortColumnSQL();
	if(sortColumnSQL NEQ ''){
		db.sql&=" ORDER BY #sortColumnSQL# office_sort, office_name ";
	}else{
		db.sql&=" order by office_sort, office_name ";
	}
	// db.sql&=" LIMIT #db.param((form.zIndex-1)*variables.perpage)#, #db.param(variables.perpage)# ";
	rs={};
	rs.searchFields=[{
		fields:[{
			formField:'<input type="search" name="search_name" id="search_name" placeholder="Name" value="#htmleditformat(form.search_name)#"> ',
			field:"search_name"
		}]
	}];
	rs.qData=db.execute("qData");

	db.sql="SELECT count(*) count
	FROM #db.table("office", request.zos.zcoreDatasource)# 
	WHERE office.site_id = #db.param(request.zos.globals.id)# and 
	office_deleted = #db.param(0)# ";
	if(form.search_name NEQ ""){
		db.sql&=" and office_name LIKE #db.param('%'&form.search_name&'%')# ";
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
	arrayAppend(columns, {field: row.office_id});
	savecontent variable="field"{
		ts=structnew();
		ts.image_library_id=row.office_image_library_id;
		ts.output=false;
		ts.struct=row;
		ts.size="100x70";
		ts.crop=0;
		ts.count = 1; // how many images to get
		//zdump(ts);
		arrImages=application.zcore.imageLibraryCom.displayImageFromStruct(ts); 
		for(i=1;i LTE arraylen(arrImages);i++){
			writeoutput('<img src="'&arrImages[i].link&'">');
		} 
	}
	arrayAppend(columns, {field: field, style:"width:100px; vertical-align:top; " });

	arrayAppend(columns, {field: row.office_name});

	savecontent variable="field"{
		echo('#row.office_address#<br />');
		if(row.office_address2 NEQ ""){
			echo('#row.office_address2#<br />');
		}
		if(row.office_city NEQ ""){
			echo('#row.office_city#, ');
		}
		echo('#row.office_state# 
		#row.office_zip# #row.office_country#');
	}
	arrayAppend(columns, {field: field});
	arrayAppend(columns, {field: row.office_phone});  
	if(row.office_map_location EQ ""){
		arrayAppend(columns, {field: "No"});  
	}else{
		arrayAppend(columns, {field: "Yes"});  
	}
	arrayAppend(columns, {field: row.office_manager_email_list});
	arrayAppend(columns, {field: application.zcore.functions.zTimeSinceDate(row.office_updated_datetime)}); 
	savecontent variable="field"{
		displayRowSortButton(row.office_id);
		editLinks=[{
					label:"Edit Location",
					link:variables.prefixURL&"edit?office_id=#row.office_id#&modalpopforced=1",
					enableEditAjax:true // only possible for the link that replaces the current row
				}];
		if(variables.hasLeadsAccess){
			arrayAppend(editLinks, {
				label:"Manage Leads",
				link:"/z/inquiries/admin/manage-inquiries/index?search_office_id=#row.office_id#"
			});
		}
		arrayAppend(editLinks, {
			label:"Public Users",
			link:"/z/admin/member/showPublicUsers?office_id=#row.office_id#"
		});
		if(application.zcore.user.checkGroupAccess("administrator")){
			arrayAppend(editLinks, {
				label:"Site Manager Users",
				link:"/z/admin/member/index?office_id=#row.office_id#"
			});
		}
 
		ts={
			buttons:[/*{
				icon:"",
				link:"",
				label:"Text by itself"
			},{
				title:"View",
				icon:"eye",
				link:'##',
				label:"",
				target:"_blank"
			},*/{
				title:"Edit",
				icon:"cog",
				links:editLinks,
				label:""
			},{
				title:"Delete",
				icon:"trash",
				link:variables.prefixURL&"delete?office_id=#row.office_id#&returnJson=1",
				label:'',
				enableDeleteAjax:true
			}]
		}; 
		displayAdminMenu(ts);

	}
	arrayAppend(columns, {field: field, class:"z-manager-admin", style:"width:280px; max-width:100%;"});
	</cfscript> 
</cffunction>	

</cfoutput>
</cfcomponent>
