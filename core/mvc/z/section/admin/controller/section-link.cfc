<cfcomponent extends="zcorerootmapping.com.app.manager-base"> 	 
<cfoutput>  
<cffunction name="getQuickLinks" localmode="modern" access="public">
	<cfscript>
	links=[];
	/*
	// This is an example of making quick links.  Change Section Link to the right feature
	variables.hasAccess=application.zcore.adminSecurityFilter.checkFeatureAccess("Section Link");
	if(variables.hasAccess){
		arrayAppend(links, { link:"/z/section/admin/section-link/index?zManagerAddOnLoad=1", label:"Add Section Link" }); 
	}
	*/
	return links;
	</cfscript>
</cffunction>

<cffunction name="init" localmode="modern" access="public">
	<cfscript>
	var db=request.zos.queryObject; 
	application.zcore.template.setTag("title", "Manager | Section Links");

	
	form.section_link_parent_id=application.zcore.functions.zso(form, "section_link_parent_id", true);
	
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
			
	variables.uploadPath=request.zos.globals.privateHomeDir&"zupload/link/";
	variables.displayPath="/zupload/link/";
	ts={
		// required 
		label:"Section Link",
		pluralLabel:"Section Links",
		tableName:"section_link",
		datasource:request.zos.zcoreDatasource,
		deletedField:"section_link_deleted",
		primaryKeyField:"section_link_id",
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

		//optional
		requiredParams:["section_id" , "section_link_parent_id" ],
		requiredEditParams:[],

		customInsertUpdate:false,
		hasSiteId:true,
			sortField:"section_link_sort",
			rowSortingEnabled:true,
			quickLinks:getQuickLinks(),
		imageLibraryFields:[],
		validateFields:{
			"section_link_link_text":{ required:true } , "section_link_url":{ required:true } 
		},
		imageFields:[],
		fileFields:[],
		// optional
		requireFeatureAccess:"",
		pagination:false,
		paginationIndex:"zIndex",
		pageZSID:"zPageId",
		perpage:10,
		title:"Section Links",
		prefixURL:"/z/section/admin/section-link/",
		navLinks:[],
		titleLinks:[],
		columnSortingEnabled:false,
		columns:[{
			label:"ID",
			field:"section_link_id"
		},
			/*{
				label:"Parent",
				field:"section_link_parent_id"
			}
			,*/
			{
				label:"Link Text",
				field:"section_link_link_text"
			},{
				label:"URL",
				field:"section_link_url"
			},
			{
				label:"Updated",
				field:"section_link_updated_datetime"
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
				label:"Sections",
				link:"/z/section/admin/section-admin/index"
			});
			if(form.section_link_parent_id NEQ 0){
				arrayAppend(ts.navLinks, {
					label:"#request.qsection.section_name# Links",
					link:"/z/section/admin/section-link/index?section_id=#form.section_id#"
				});
			}else{
				arrayAppend(ts.navLinks, {
					label:"#request.qsection.section_name# Links"
				});
			}
		}
		 
		// these are the parent id (same table) breadcrumbs
		for(row in request.qsection){
			lookupStruct[row.section_link_id]={
				parentId:row.section_link_parent_id,
				name:"#replace(replace(row.section_link_link_text, '"', '""', "all"), "##", "####", "all")#"
			};
		}
		// get parent records in a loop
		i=1;
		arrParent=[];
		currentParent=form.section_link_parent_id;
		while(true){
			i++;
			if(currentParent EQ 0){
				break;
			}
			if(structkeyexists(lookupStruct, currentParent)){ 
				arrayprepend(arrParent, {
					//link:"/z/section/admin/section-link/index?section_link_id=#row.section_link_id#&section_link_parent_id=#lookupStruct[currentParent].parentId#&&section_id=#form.section_id#&ztv1=#form.section_link_parent_id#",
					label:lookupStruct[currentParent].name
				}); 
				currentParent=lookupStruct[currentParent].parentId;
			}else{
				break;
			}
			if(i GT 25){
				throw("Possible infinite loop detected in section_link_parent_id");
			}
		}
		if(arrayLen(arrParent) NEQ 0){ 
			for(link in arrParent){
				arrayAppend(ts.navLinks, link);
			}
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
	// TODO: need to get parent field to passthrough: section_link_parent_id
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
	db.sql="SELECT * FROM #db.table("section_link", request.zos.zcoreDatasource)#
	WHERE section_link_id= #db.param(application.zcore.functions.zso(form,"section_link_id"))# and  
	section_link_deleted = #db.param(0)#   and 
		site_id=#db.param(request.zos.globals.id)# ";
	rs.qData=db.execute("qData", "", 10000, "query", false);
	return rs;
	</cfscript>
</cffunction>

<cffunction name="executeDelete" localmode="modern" access="private">
	<cfargument name="ss" type="struct" required="yes">
	<cfscript>
	ss=arguments.ss;
	var db=request.zos.queryObject;  
	for(row in ss.qData){
		
		childCom=createobject("component", "zcorerootmapping.mvc.z.section.admin.controller.section-admin-link");

		// select all children
		db.sql="select * from #db.table("section_link", request.zos.zcoreDatasource)# 
		WHERE 
		section_link_id = #row.section_link_id# ";
		
		db.sql&=" and site_id = #db.param(request.zos.globals.id)# ";
		
		qChildren=db.execute("qChildren");
		for(childRow in qChildren){
			childCom.deleteRow(childRow);
		}

		
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

	/*
	// this code is here if you need to handle files in a custom way.  by default, the manager API will automatically handle deleting these files, unless you remove the field names from the init config.
	
	*/
	db.sql="DELETE FROM #db.table("section_link", request.zos.zcoreDatasource)# WHERE 
	section_link_id= #db.param(application.zcore.functions.zso(form, "section_link_id"))# and  
	section_link_deleted = #db.param(0)#    and 
		site_id=#db.param(request.zos.globals.id)# ";
	db.execute("qDelete");

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
			application.zcore.status.setStatus(request.zsid, "Invalid Section selection.", form, true);
			error=true;
		}
	}
	if(not application.zcore.functions.zValidateURL(form.section_link_url, false, false)){
		error=true;
		application.zcore.status.setStatus(request.zsid, "URL must be valid.", form, true);
	}
	if(error){
		return {success:false};
	}
	db.sql="SELECT * FROM #db.table("section_link", request.zos.zcoreDatasource)#
	WHERE  
	section_link_deleted = #db.param(0)# and  
	section_link_id=#db.param(form.section_link_id)# and 
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

	form.section_link_id=application.zcore.functions.zso(form, "section_link_id", true, 0);
	db.sql="SELECT * FROM #db.table("section_link", request.zos.zcoreDatasource)#
	WHERE  
	section_link_deleted = #db.param(0)# and  
	section_link_id=#db.param(form.section_link_id)# and 
		site_id=#db.param(request.zos.globals.id)# "; 
	rs={}; 
	rs.qData=db.execute("qData");

	return rs;
	</cfscript>
</cffunction>

<cffunction name="getListReturnData" localmode="modern" access="private" returntype="struct">
	<cfscript>
	var db=request.zos.queryObject;
	/*db.sql="SELECT *  FROM #db.table("section_link", request.zos.zcoreDatasource)#  
	WHERE  
	section_link_deleted = #db.param(0)# and   
	section_link_parent_id = #db.param(0)#  and 
		site_id=#db.param(request.zos.globals.id)#  "; 
	qRootLinks=db.execute("qRootLinks");  
	variables.rootLinkStruct={};
	for(row in qRootLinks){
		variables.rootLinkStruct[row.section_link_id]=row.section_link_link_text;
	}*/
	form.section_link_id=application.zcore.functions.zso(form, "section_link_id", true, 0);
	
		db.sql="SELECT * FROM #db.table("section_link", request.zos.zcoreDatasource)#
		WHERE  
		section_link_deleted = #db.param(0)# and  
		section_link_id=#db.param(form.section_link_id)# and 
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
			db.sql="select * from #db.table("section_link", request.zos.zcoreDatasource)# 
			WHERE section_id=#db.param(form.section_id)# and 
			section_link_parent_id=#db.param(0)# and 
			site_id = #db.param(request.zos.globals.id)# and 
			section_link_deleted=#db.param(0)# 
			ORDER BY section_link_link_text asc";
			qParent=db.execute("qParent"); 
			ts = StructNew();
			ts.name = "section_link_parent_id"; 
			ts.size = 1; // more for multiple select 
			ts.query = qParent; 
			ts.onchange="for(var i in this.options){ if(this.options[i].selected && this.options[i].value != '' && this.options[i].value=='#application.zcore.functions.zso(form, "section_link_id")#'){alert('You can\'t select the same item you are editing.');this.selectedIndex=0;}; }";
			ts.queryLabelField = "section_link_link_text";
			ts.queryParseLabelVars = false; // set to true if you want to have a custom formated label
			ts.queryParseValueVars = false; // set to true if you want to have a custom formated value
			ts.queryValueField = "section_link_id"; 
			application.zcore.functions.zInputSelectBox(ts);
		}
		arrayAppend(fs, {label:"Parent Link", field:field});
		  
		</cfscript>
		<cfsavecontent variable="field">
		<input type="text" name="section_link_link_text" id="section_link_link_text"  style="width:95%;"   value="#htmleditformat(application.zcore.functions.zso(form, "section_link_link_text"))#" /> 
		</cfsavecontent>
		<cfscript>
		arrayAppend(fs, {label:"Link Text", required: true,  field:field});
		  
		</cfscript>
		<cfsavecontent variable="field">
		<input type="text" name="section_link_url" id="section_link_url"  style="width:95%;"  value="#htmleditformat(application.zcore.functions.zso(form, "section_link_url"))#" /> 
		</cfsavecontent>
		<cfscript>
		arrayAppend(fs, {label:"URL", required: true,  field:field});
		
	rs.tabs.basic.fields=fs;
	// advanced fields
	/*
	fs=[];
	savecontent variable="field"{
		echo('<input type="text" name="section_link_advanced" value="#htmleditformat(form.section_link_advanced)#" />');
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

	form.section_link_id=application.zcore.functions.zso(form, "section_link_id", true, 0);
	/*
	db.sql="SELECT *  FROM #db.table("section_link", request.zos.zcoreDatasource)#  
	WHERE  
	section_link_deleted = #db.param(0)# and   
	section_link_parent_id = #db.param(0)#  and 
		site_id=#db.param(request.zos.globals.id)#  "; 
	qRootLinks=db.execute("qRootLinks");  
	variables.rootLinkStruct={};
	for(row in qRootLinks){
		variables.rootLinkStruct[row.section_link_id]=row.section_link_link_text;
	}
*/
	db.sql="SELECT * FROM #db.table("section_link", request.zos.zcoreDatasource)#  
	WHERE  
	section_id=#db.param(form.section_id)# and 
	section_link_deleted = #db.param(0)# and   
	section_link_parent_id = #db.param(form.section_link_parent_id)#  and 
		site_id=#db.param(request.zos.globals.id)#  "; 
	
	db.sql&=" ORDER BY section_link.section_link_sort ASC ";
	
	db.sql&=" LIMIT #db.param((form.zIndex-1)*variables.perpage)#, #db.param(variables.perpage)# ";
	rs={};
	rs.qData=db.execute("qData");  

	rs.searchFields=[ ];
 
	db.sql="SELECT count(*) count FROM #db.table("section_link", request.zos.zcoreDatasource)#
	WHERE  
	section_id=#db.param(form.section_id)# and 
	section_link_deleted = #db.param(0)# and  
	section_link_parent_id = #db.param(form.section_link_parent_id)#  and 
		site_id=#db.param(request.zos.globals.id)# "; 
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
	arrayAppend(columns, {field: row.section_link_id}); 
	/*if(row.section_link_parent_id NEQ 0 and structkeyexists(variables.rootLinkStruct, row.section_link_parent_id)){
		arrayAppend(columns, {field: variables.rootLinkStruct[row.section_link_parent_id] }); 
	}else{
		arrayAppend(columns, {field: "" }); 
	}*/
			arrayAppend(columns, {field: row.section_link_link_text });
			if(row.section_link_url EQ ""){ 
				field="&nbsp;";
			}else{
				field='<a href="#row.section_link_url#" target="_blank">'&application.zcore.functions.zLimitStringLength(row.section_link_url, 50)&'</a>';
			}
			arrayAppend(columns, {field: field });
			

	arrayAppend(columns, {field: application.zcore.functions.zTimeSinceDate(row.section_link_updated_datetime)});  
	savecontent variable="field"{ 
	 displayRowSortButton(row.section_link_id);
		 
		ts={
			buttons:[{
				title:"View",
				icon:"eye",
				link:"#row.section_link_url#",
				label:"",
				target:"_blank"
			}, {
				title:"Edit",
				icon:"cog",
				link:variables.prefixURL&"edit?section_link_id=#row.section_link_id#&modalpopforced=1&&section_id=#form.section_id#&section_link_parent_id=#form.section_link_parent_id#",
				label:"",
				enableEditAjax:true
			}]
		}; 
		if(form.section_link_parent_id EQ 0){
			arrayAppend(ts.buttons, {
				title:"Manage Sub-Links",
				label:"",
				icon:"sitemap",
				link:"/z/section/admin/section-link/index?section_link_id=#row.section_link_id#&section_link_parent_id=#row.section_link_id#&&section_id=#form.section_id#&ztv1=#form.section_link_parent_id#",
			});
		}
		arrayAppend(ts.buttons, {
				title:"Delete",
				icon:"trash",
				link:"/z/section/admin/section-link/delete?section_link_id=#row.section_link_id#&amp;returnJson=1&amp;confirm=1&section_id=#form.section_id#&section_link_parent_id=#form.section_link_parent_id#",
				label:"",
				enableDeleteAjax:true
			});
		displayAdminMenu(ts);

	}
	arrayAppend(columns, {field: field, class:"z-manager-admin", style:"width:250px; max-width:100%;"});
	</cfscript> 
</cffunction>	

</cfoutput>
</cfcomponent>
